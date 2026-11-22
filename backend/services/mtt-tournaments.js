// backend/services/mtt-tournaments.js
// ============================================================
// 🔥 MOTOR MTT (Multi-Table Tournament) — RoyalBet
// Cuando un torneo Futures llega a su hora de inicio:
//   1. Crea 1..N mesas de 9 jugadores según los inscritos
//   2. Sienta a todos con el stack inicial (3000 fichas de torneo)
//   3. Ciegas suben +25% cada 10 min (motor pokerGame)
//   4. Al quedar 1 jugador con fichas → PAGA PREMIOS en NTX-20
//      (1º 55% · 2º 30% · 3º 15% del prize pool = entradas x 0.90)
// ============================================================
const pool = require('../db');
const PokerTable = require('../pokerGame');

const TABLES_MAX_PLAYERS = 9;
const STARTING_STACK = 3000;      // fichas de torneo
const MTT_SMALL_BLIND = 25;       // ciegas iniciales 25/50
const MTT_BIG_BLIND = 50;
const PRIZE_SPLITS = {
  2: [0.65, 0.35],
  3: [0.55, 0.30, 0.15],
};
const DEFAULT_SPLIT_3PLUS = [0.55, 0.30, 0.15];

let io = null;
const activeMTTs = new Map(); // gameId -> mtt instance

function init(socketIo) {
  io = socketIo;
}

// ------------------------------------------------------------
// Reparto de premios en NTX-20 + registro en game_history
// ------------------------------------------------------------
async function payoutTournament(mtt, podium) {
  const game = mtt.game;
  const prizePool = Math.floor(game.entry * mtt.registeredCount * 0.90);
  const splits = PRIZE_SPLITS[podium.length] || DEFAULT_SPLIT_3PLUS;

  console.log(`[MTT] Torneo ${game.id} terminado. Podio: ${podium.map(p => `${p.position}º ${p.username}`).join(' | ')} — Prize pool: ${prizePool} NTX-20`);

  if (prizePool <= 0) {
    if (game) game.status = 'FINISHED';
    return;
  }

  // 🔥 Calcular premios ENTEROS y dar el redondeo restante al 1º lugar
  const prizes = podium.map((p, i) => {
    const split = splits[i];
    return split ? Math.floor(prizePool * split) : 0;
  });
  const paidSum = prizes.reduce((s, v) => s + v, 0);
  if (prizes.length > 0 && paidSum < prizePool) prizes[0] += prizePool - paidSum; // resto al campeón

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    for (let i = 0; i < podium.length; i++) {
      const p = podium[i];
      const prize = prizes[i];
      if (!p.userId || !prize || prize <= 0) continue;

      await connection.query(
        'UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?',
        [prize, p.userId]
      );
      await connection.query(
        'INSERT INTO game_history (user_id, table_id, amount_won) VALUES (?, ?, ?)',
        [p.userId, `mtt-${game.id}`, prize]
      );
      await connection.query(
        `INSERT INTO user_notifications (user_id, title, message, type)
         VALUES (?, ?, ?, 'success')`,
        [p.userId, '🏆 Premio de torneo',
          `Terminaste en el lugar ${p.position}º del torneo ${game.title}. Premio: ${prize} NTX-20`]
      );
      p.prize = prize;
    }

    await connection.commit();
    if (game) game.status = 'FINISHED';
    console.log(`[MTT] Premios pagados para ${game.id}`);
  } catch (err) {
    await connection.rollback();
    console.error(`[MTT] Error pagando premios de ${game.id}:`, err);
  } finally {
    connection.release();
  }

  // Avisar a TODAS las mesas del torneo con el podio final (con premios)
  for (const t of mtt.tables) {
    t.emitToTable('tournamentFinished', {
      gameId: game.id,
      title: game.title,
      podium,
      prizePool,
    });
  }
  // Liberar las mesas tras unos minutos
  setTimeout(() => {
    for (const t of mtt.tables) {
      t.seats = t.seats.map(() => null);
      t.phase = 'waiting';
      t.broadcast();
    }
    activeMTTs.delete(game.id);
    console.log(`[MTT] Torneo ${game.id} archivado.`);
  }, 5 * 60 * 1000);
}

// ------------------------------------------------------------
// Creación de mesas y reparto de asientos
// ------------------------------------------------------------
async function startTournament(game) {
  if (!io) return { ok: false, error: 'MTT no inicializado' };
  if (activeMTTs.has(game.id)) return { ok: true, message: 'Ya en juego' };
  if (!game.players || game.players.length < 2) {
    return { ok: false, error: 'Se necesitan al menos 2 jugadores' };
  }

  // Nombres de usuario desde la DB
  let users = [];
  try {
    const [rows] = await pool.query(
      `SELECT id, username FROM users WHERE id IN (${game.players.map(() => '?').join(',')})`,
      game.players
    );
    users = rows;
  } catch (err) {
    console.error('[MTT] Error obteniendo usuarios:', err);
    return { ok: false, error: 'Error de base de datos' };
  }

  const playerMap = new Map(users.map(u => [u.id, u.username]));
  const seatedIds = [];
  for (const userId of game.players) {
    if (playerMap.has(userId)) seatedIds.push(userId);
  }

  if (seatedIds.length < 2) {
    return { ok: false, error: 'Jugadores registrados no válidos' };
  }

  const numTables = Math.max(1, Math.ceil(seatedIds.length / TABLES_MAX_PLAYERS));
  const mtt = {
    game,
    registeredCount: seatedIds.length,
    tables: [],
  };

  for (let t = 0; t < numTables; t++) {
    const tableId = `mtt-${game.id}-t${t + 1}`;
    const table = new PokerTable(io, {
      smallBlind: MTT_SMALL_BLIND,
      bigBlind: MTT_BIG_BLIND,
      maxPlayers: TABLES_MAX_PLAYERS,
      tableId,
      isTournament: true,
      isPractice: false,
      tournamentId: game.id,
      startingStack: STARTING_STACK,
      blindUpPercent: 1.25,
      autoStart: false, // 🔥 MTT: no arrancar hasta sentar a TODOS los inscritos
      onTournamentEnd: (podium) => payoutTournament(mtt, podium),
    });
    mtt.tables.push(table);
  }

  // Sentar a los jugadores repartidos entre las mesas
  let idx = 0;
  for (const userId of seatedIds) {
    const table = mtt.tables[Math.floor(idx / TABLES_MAX_PLAYERS)];
    const seatIdx = table.seats.findIndex(s => s === null);
    if (seatIdx !== -1) {
      // 🔥 FIX: socketId sintético ÚNICO por jugador ('pending-<id>').
      // Si todos tuvieran null, el motor confundiría asientos al buscar por
      // socketId (turnos perdidos / auto-fold al jugador equivocado).
      // Al conectarse, reconnectPlayer() lo sustituye por su socket real.
      table.seat(`pending-${userId}`, userId, playerMap.get(userId), STARTING_STACK, seatIdx, null);
      // En torneo, la mano no debe arrancar hasta que TODOS estén sentados
      if (table.nextHandTimeout) clearTimeout(table.nextHandTimeout);
    }
    idx++;
  }

  activeMTTs.set(game.id, mtt);
  console.log(`[MTT] Torneo ${game.id} INICIADO: ${seatedIds.length} jugadores en ${numTables} mesa(s).`);

  // Arrancar la primera mano en cada mesa tras un breve margen de conexión
  setTimeout(() => {
    for (const table of mtt.tables) {
      if (table.phase === 'waiting') table.startHand();
    }
  }, 8000);

  return { ok: true, tables: numTables };
}

// ------------------------------------------------------------
// Búsqueda para reconexión / acciones
// ------------------------------------------------------------
function getMTTByGame(gameId) {
  return activeMTTs.get(gameId) || null;
}

function findTableByUser(userId) {
  for (const mtt of activeMTTs.values()) {
    for (const table of mtt.tables) {
      const seat = table.seats.find(p => p !== null && p.userId === userId);
      if (seat) return { mtt, table, seat };
    }
  }
  return null;
}

function findTableBySocket(socketId) {
  for (const mtt of activeMTTs.values()) {
    for (const table of mtt.tables) {
      const seat = table.seats.find(p => p !== null && p.socketId === socketId);
      if (seat) return { mtt, table, seat };
    }
  }
  return null;
}

function findMTTByTableId(tableId) {
  for (const mtt of activeMTTs.values()) {
    if (mtt.tables.some(t => t.tableId === tableId)) return mtt;
  }
  return null;
}

// Conectar el socket de un jugador a su mesa de torneo (reconexión)
function attachPlayer(socket, userId) {
  const found = findTableByUser(userId);
  if (!found) return null;
  const { table, seat: player } = found;
  if (player.socketId && player.socketId !== socket.id) {
    // cancelar grace period del socket viejo si existe
    player.socketId = socket.id;
  }
  const r = table.reconnectPlayer(socket.id, userId);
  if (!r.ok) return null;
  socket.join(table.tableId);
  return table;
}

function getActiveTournamentSummaries() {
  const out = [];
  for (const [gameId, mtt] of activeMTTs.entries()) {
    let alive = 0;
    for (const t of mtt.tables) alive += t.seats.filter(p => p !== null && p.chips > 0).length;
    out.push({
      gameId,
      title: mtt.game.title,
      entry: mtt.game.entry,
      playersAlive: alive,
      registered: mtt.registeredCount,
      tables: mtt.tables.map(t => ({
        tableId: t.tableId,
        blindLevel: t.blindLevel,
        smallBlind: t.smallBlind,
        bigBlind: t.bigBlind,
        players: t.seats.filter(p => p !== null).length,
      })),
    });
  }
  return out;
}

module.exports = {
  init,
  startTournament,
  getMTTByGame,
  findTableByUser,
  findTableBySocket,
  findMTTByTableId,
  attachPlayer,
  getActiveTournamentSummaries,
  STARTING_STACK,
};
