const express = require('express');
const router = express.Router();
const fetch = require('node-fetch');

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');
const { requireInternal } = require('../middlewares/internalAuth');
const { getFundConfig, applyRake } = require('../services/funds');
const { getGames, getGameById, LATE_REG_MS } = require('../services/futures');
const { getSeats, getTable } = require('../services/practice-table');
const mtt = require('../services/mtt-tournaments');
const { authLimiter, betLimiter } = require('../middlewares/rateLimiter');
// ===========================================================
// VALIDADOR
// ===========================================================
const {
  validateGameRegister, validateBuyIn, validateCashOut, validateProcessRake,
} = require('../middlewares/validators');
// ===========================================================


// ============================================================
// CONFIGURACIÓN DE CASUAL ROOMS
// ============================================================
// Cada "sala" tiene 2 mesas de 9 jugadores = 18 por sala.
// - Cuando Mesa 1 se llena (9/9) → se desbloquea Mesa 2.
// - Cuando la sala se llena (18/18) → se crea la siguiente sala
//   con la misma configuración (auto-spawn 24/7).
// ============================================================

const PLAYERS_PER_MESA = 9;
const MESAS_PER_SALA = 2;
const PLAYERS_PER_SALA = PLAYERS_PER_MESA * MESAS_PER_SALA; // 18

const SALA_CONFIGS = [
    {
        configKey: 'omaha-05-1',
        baseTableId: 'omaha-05-1',
        name: 'OMAHA',
        blinds: '0.25/0.5',
        minBuyIn: 20,
        maxBuyIn: 100,
        tableType: 'No Limit Omaha',
    },
    {
        configKey: 'holdem-1-2',
        baseTableId: 'holdem-1-2',
        name: "HOLD'EM",
        blinds: '1/2',
        minBuyIn: 100,
        maxBuyIn: 250,
        tableType: 'No Limit Holdem',
    },
    {
        configKey: 'holdem-2-4',
        baseTableId: 'holdem-2-4',
        name: "HOLD'EM",
        blinds: '5/10',
        minBuyIn: 250,
        maxBuyIn: 500,
        tableType: 'No Limit Holdem',
    },
    {
        configKey: 'holdem-5-10',
        baseTableId: 'holdem-5-10',
        name: "HOLD'EM",
        blinds: '10/20',
        minBuyIn: 500,
        maxBuyIn: 1000,
        tableType: 'No Limit Holdem',
    },
    {
        configKey: 'shortdeck-10-20',
        baseTableId: 'shortdeck-10-20',
        name: 'SHORT DECK',
        blinds: '20/40',
        minBuyIn: 1000,
        maxBuyIn: 2000,
        tableType: 'No Limit Short Deck',
    },
];

// ------------------------------------------------------------
// Estado en memoria de salas activas por config
// Al reiniciar el proceso se resetea a [1]. Se reconcilia con
// liveTables para detectar salas en curso (ver reconcileActiveSalas).
// ------------------------------------------------------------
const activeSalas = {}; // { [configKey]: number[] }

function initActiveSalas() {
    for (const cfg of SALA_CONFIGS) {
        if (!activeSalas[cfg.configKey]) activeSalas[cfg.configKey] = [1];
    }
}
initActiveSalas();

// Genera el ID de mesa para pokerServer.
// - Sala 1 Mesa 1 conserva el ID viejo para retrocompatibilidad.
// - Sala 1 Mesa 2 → "{base}-m2"
// - Sala N (N>=2) → "{base}-sN-mM"
function buildTableId(baseTableId, salaNumber, mesaNumber) {
    if (salaNumber === 1 && mesaNumber === 1) return baseTableId;
    if (salaNumber === 1) return `${baseTableId}-m${mesaNumber}`;
    return `${baseTableId}-s${salaNumber}-m${mesaNumber}`;
}

function escapeRegex(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function getPlayersInTable(tableId, liveTables) {
    const arr = liveTables[tableId];
    return Array.isArray(arr) ? arr.length : 0;
}

function getSalaTotal(baseTableId, salaNumber, liveTables) {
    let total = 0;
    for (let m = 1; m <= MESAS_PER_SALA; m++) {
        total += getPlayersInTable(buildTableId(baseTableId, salaNumber, m), liveTables);
    }
    return total;
}

// Reconcilia el estado en memoria con lo que pokerServer reporta.
// Se usa al arrancar (o cuando hay jugadores en salas "huérfanas").
function reconcileActiveSalas(liveTables) {
    for (const cfg of SALA_CONFIGS) {
        let maxSala = 1;
        const re = new RegExp(`^${escapeRegex(cfg.baseTableId)}-s(\\d+)-m\\d+$`);
        for (const tableId of Object.keys(liveTables)) {
            const m = tableId.match(re);
            if (m) maxSala = Math.max(maxSala, parseInt(m[1], 10));
        }
        const salas = activeSalas[cfg.configKey];
        while (salas[salas.length - 1] < maxSala) {
            salas.push(salas[salas.length - 1] + 1);
        }
    }
}

// Auto-spawn: si la última sala activa de una config está llena
// (18/18), agrega la siguiente y avisa a pokerServer (best-effort).
async function maybeSpawnNextSala(cfg, liveTables) {
    const salas = activeSalas[cfg.configKey];
    const lastSala = salas[salas.length - 1];
    const total = getSalaTotal(cfg.baseTableId, lastSala, liveTables);

    if (total < PLAYERS_PER_SALA) return;

    const newSala = lastSala + 1;
    salas.push(newSala);
    console.log(
        `[casual] Auto-spawn: ${cfg.name} — Sala ${newSala} creada ` +
        `(Sala ${lastSala} llena con ${total}/${PLAYERS_PER_SALA})`
    );

    // Best-effort: pedir a pokerServer que cree las mesas físicas.
    // Si el endpoint no existe, solo se loguea un warning y las mesas
    // se mostrarán en la UI pero el join fallará hasta que se agregue.
    for (let m = 1; m <= MESAS_PER_SALA; m++) {
        const tableId = buildTableId(cfg.baseTableId, newSala, m);
        notifyPokerServerNewTable(tableId, cfg).catch(err => {
            console.warn(`[casual] No se pudo notificar pokerServer para ${tableId}: ${err.message}`);
        });
    }
}

// Notifica a pokerServer la creación de una mesa nueva.
// TODO: implementar /api/tables/create en pokerServer.js
async function notifyPokerServerNewTable(tableId, cfg) {
    try {
        const resp = await fetch('http://localhost:3001/api/tables/create', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                tableId,
                maxPlayers: PLAYERS_PER_MESA,
                blinds: cfg.blinds,
                tableType: cfg.tableType,
            }),
        });
        if (!resp.ok && resp.status !== 404) {
            console.warn(`[casual] pokerServer rechazó crear ${tableId} (HTTP ${resp.status})`);
        }
    } catch (e) {
        // pokerServer apagado o sin endpoint — log y seguir
        throw e;
    }
}

// Una mesa está "locked" si es Mesa >=2 y la Mesa anterior de la MISMA sala
// todavía no llegó a 9/9. Mesa 1 de cualquier sala siempre está disponible.
function isMesaLocked(cfg, salaNumber, mesaNumber, liveTables) {
    if (mesaNumber === 1) return false;
    const prevMesaId = buildTableId(cfg.baseTableId, salaNumber, mesaNumber - 1);
    return getPlayersInTable(prevMesaId, liveTables) < PLAYERS_PER_MESA;
}

// Busca la config a la que pertenece un tableId (para validar buy-in).
function findConfigByTableId(tableId) {
    if (!tableId) return null;
    return SALA_CONFIGS.find(cfg =>
        tableId === cfg.baseTableId || tableId.startsWith(cfg.baseTableId + '-')
    ) || null;
}

// ============================================================
// ENDPOINTS — sin cambios salvo buy-in (validación de límites)
// ============================================================

router.get('/futures-games', (req, res) => {
    const gamesConPremios = getGames().map(game => {
        const totalRecaudado = game.entry * game.players.length;
        const prizePool = (totalRecaudado * 0.90).toFixed(0);
        return {
            ...game,
            prize: Number(prizePool) > 0 ? prizePool : (game.entry * 4 * 0.9).toFixed(0),
        };
    });
    res.json(gamesConPremios);
});

// 🔥 MTT NUEVO: resumen de torneos en juego (jugadores vivos, ciegas por mesa)
router.get('/futures-games/mtt-live', (req, res) => {
    res.json(mtt.getActiveTournamentSummaries());
});

// 🔥 MTT NUEVO: ¿en qué mesa de torneo está este jugador? (para reconectar al entrar)
router.get('/futures-games/my-seat', verifyToken, (req, res) => {
    const found = mtt.findTableByUser(req.user.id);
    if (!found) return res.json({ seated: false });
    res.json({
        seated: true,
        gameId: found.mtt.game.id,
        tableId: found.table.tableId,
        chips: found.seat.chips,
        title: found.mtt.game.title,
    });
});

// 🔥 MULTIMESA / RECONEXIÓN: todas las mesas activas de este jugador
// (cash + práctica + todas las mesas de torneo). El frontend usa esto para
// restaurar la partida automáticamente al abrir la app o volver al lobby.
router.get('/poker/my-tables', verifyToken, async (req, res) => {
    try {
        const out = [];

        // Mesas de TORNEO (todas las que tenga)
        for (const f of mtt.findTablesByUser(req.user.id)) {
            out.push({
                tableId: f.table.tableId,
                kind: 'tournament',
                gameId: f.mtt.game.id,
                title: f.mtt.game.title,
                chips: f.seat.chips,
                blindLevel: f.table.blindLevel,
                smallBlind: f.table.smallBlind,
                bigBlind: f.table.bigBlind,
                phase: f.table.phase,
                myTurn: f.table.currentTurn === f.seat.socketId,
            });
        }

        // Mesa de PRÁCTICA (silla viva)
        const practice = getTable();
        const pSeat = practice?.seats.find(p => p !== null && p.userId === req.user.id);
        if (pSeat) {
            out.push({
                tableId: 'sala-practica-400',
                kind: 'practice',
                title: 'Sala de Práctica',
                chips: pSeat.chips,
                smallBlind: practice.smallBlind,
                bigBlind: practice.bigBlind,
                phase: practice.phase,
                myTurn: practice.currentTurn === pSeat.socketId,
            });
        }

        // 🔥 MESAS CASH: mesas reales registradas en active_player_tables
        // (server_type='real'). El registro existe mientras el jugador esté
        // sentado o dentro del periodo de gracia de desconexión, así que
        // aquí SOLO aparecen mesas donde de verdad tiene silla pendiente.
        try {
            const [rows] = await pool.query(
                "SELECT table_id FROM active_player_tables WHERE user_id = ? AND server_type = 'real'",
                [req.user.id]
            );
            const cashIds = [...new Set(rows.map(r => r.table_id))];
            if (cashIds.length > 0) {
                for (const tableId of cashIds) {
                    if (out.some(t => t.tableId === tableId)) continue;
                    const config = findConfigByTableId(tableId);
                    if (!config) continue;
                    const [sb, bb] = String(config.blinds).split('/').map(Number);
                    out.push({
                        tableId,
                        kind: 'cash',
                        title: `${config.name} ${config.blinds}`,
                        smallBlind: Number.isFinite(sb) ? sb : null,
                        bigBlind: Number.isFinite(bb) ? bb : null,
                        phase: null,
                        myTurn: false,
                    });
                }
            }
        } catch (e) {
            console.warn('[my-tables] No se pudieron leer mesas cash:', e.message);
        }

        res.json(out);
    } catch (err) {
        console.error('[my-tables] Error:', err);
        res.status(500).json({ error: 'Error obteniendo mesas activas' });
    }
});

router.post('/futures-games/register', verifyToken, authLimiter, validateGameRegister, async (req, res) => {
    const { gameId } = req.body;
    const userId = req.user.id;

    const game = getGameById(gameId);
    if (!game) return res.status(404).json({ error: 'Torneo no encontrado' });
    if (game.status !== 'OPEN') return res.status(400).json({ error: 'Registro cerrado para este torneo' });

    const now = Date.now();
    const lateRegEnd = game.startTime + LATE_REG_MS;
    if (now > lateRegEnd) return res.status(400).json({ error: 'Registro cerrado para este torneo' });
    if (game.players.includes(userId)) return res.status(400).json({ error: 'Ya estas registrado en este torneo' });
    if (game.players.length >= game.maxPlayers) return res.status(400).json({ error: 'Torneo lleno' });

    game.players.push(userId);

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [wallet] = await connection.query(
            'SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE',
            [userId]
        );
        if (!wallet[0] || wallet[0].balance_ntx < game.entry) {
            throw new Error('Saldo insuficiente para pagar la entrada');
        }

        await connection.query(
            'UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?',
            [game.entry, userId]
        );

        // 🔥 FONDOS: la COMISIÓN del torneo (10% de la entrada) NO se reparte aquí.
        // Se reparte en mtt.startTournament() (al arrancar el torneo), porque si el
        // torneo se cancela con reembolso total, repartir la comisión antes crearía
        // dinero de la nada. Aquí solo registramos la inscripción para auditoría.
        // 🔥 PERSISTENCIA: registrar la inscripción en la BD (auditoría + recuperación)
        try {
            await connection.query(
                "INSERT INTO tournament_registrations (game_id, user_id, entry_amount, status) VALUES (?, ?, ?, 'paid')",
                [String(game.id), userId, game.entry]
            );
        } catch (regErr) {
            console.warn('[register] No se pudo registrar en tournament_registrations:', regErr.message);
        }

        await connection.commit();
        res.json({
            message: 'Registro exitoso',
            newBalance: wallet[0].balance_ntx - game.entry,
            game,
        });
    } catch (error) {
        await connection.rollback();
        const i = game.players.indexOf(userId);
        if (i >= 0) game.players.splice(i, 1);
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// 🔥 CAMBIO: ahora valida que el monto esté dentro de min/max de la mesa
// y RECHAZA explícitamente la Sala de Práctica (no debe cobrar NTX-20).
// También permite RE-BUYS: un jugador que se quedó sin fichas y está en
// modo espectador puede volver a comprar fichas sin problema.
router.post('/poker/buy-in', verifyToken, betLimiter, validateBuyIn, async (req, res) => {
    const { amount, tableId } = req.body;
    const userId = req.user.id;

    if (!amount || amount <= 0) return res.status(400).json({ error: 'Monto invalido' });
    if (!tableId) return res.status(400).json({ error: 'tableId requerido' });

    // 🔥 FIX CRÍTICO: La Sala de Práctica NO debe cobrar NTX-20.
    // El frontend ya maneja la recarga de práctica con `rebuy_practice`.
    if (tableId === 'sala-practica-400') {
        return res.status(400).json({ error: 'La Sala de Práctica no requiere compra de fichas (es gratis).' });
    }

    // Validar límites de buy-in según la config de la mesa
    const config = findConfigByTableId(tableId);
    if (!config) {
        return res.status(400).json({ error: 'Mesa no válida para buy-in con NTX-20.' });
    }
    if (amount < config.minBuyIn || amount > config.maxBuyIn) {
        return res.status(400).json({
            error: `Buy-in debe estar entre ${config.minBuyIn} y ${config.maxBuyIn} NTX-20`,
        });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [wallet] = await connection.query(
            'SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE',
            [userId]
        );
        if (!wallet[0] || wallet[0].balance_ntx < amount) {
            throw new Error('Saldo insuficiente para esta entrada');
        }

        await connection.query(
            'UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?',
            [amount, userId]
        );

        // 🔥 SEGURIDAD: registrar el buy-in en poker_buys. Si el sitDown falla,
        // el reembolso por /poker/cash-out SOLO se permite contra este registro
        // (mismo monto, últimos 15 min). Así nadie puede acreditar dinero libremente.
        await connection.query(
            "INSERT INTO poker_buys (user_id, table_id, amount, status) VALUES (?, ?, ?, 'paid')",
            [userId, String(tableId).slice(0, 80), amount]
        );

        await connection.commit();
        res.json({ message: 'Buy-in exitoso', newBalance: wallet[0].balance_ntx - amount });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// 🔥 SEGURIDAD (REEMBOLSO ONLY):
// El cash-out PÚBLICO ya NO acredita dinero libremente. Solo sirve para
// reembolsar un buy-in cuyo sitDown falló (el flujo del frontend en
// PokerTable.jsx). Se valida contra la tabla poker_buys: mismo monto,
// últimos 15 minutos, una sola vez.
router.post('/poker/cash-out', verifyToken, validateCashOut, async (req, res) => {
    const { amount } = req.body;
    const userId = req.user.id;

    if (!amount || amount <= 0) {
        return res.status(400).json({ error: 'Datos invalidos para procesar el retiro' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // Buscar un buy-in reciente SIN reembolsar con el mismo monto
        const [buys] = await connection.query(
            `SELECT id FROM poker_buys
              WHERE user_id = ? AND amount = ? AND status = 'paid'
                AND created_at > (NOW() - INTERVAL 15 MINUTE)
              ORDER BY created_at ASC LIMIT 1 FOR UPDATE`,
            [userId, amount]
        );
        if (buys.length === 0) {
            throw new Error('No hay un buy-in reciente para reembolsar con ese monto');
        }

        await connection.query("UPDATE poker_buys SET status = 'refunded' WHERE id = ?", [buys[0].id]);
        await connection.query(
            'UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?',
            [amount, userId]
        );

        await connection.commit();
        res.json({ message: 'Buy-in reembolsado correctamente', amount });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// 🔥 NUEVO — ENDPOINT INTERNO (motor de poker → API):
// Acredita al jugador las fichas retiradas al levantarse de una mesa cash.
// Protegido con X-Internal-Token; NO es accesible para usuarios normales.
router.post('/poker/internal/cash-out', requireInternal, async (req, res) => {
    const { userId, amount } = req.body;
    const uid = Number(userId);
    const amt = Number(amount);
    if (!Number.isInteger(uid) || uid <= 0 || !Number.isFinite(amt) || amt <= 0) {
        return res.status(400).json({ error: 'Datos invalidos para el cash-out interno' });
    }
    try {
        await pool.query(
            'UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?',
            [amt, uid]
        );
        res.json({ message: 'Cash-out interno exitoso', amount: amt });
    } catch (error) {
        console.error('Error al procesar el cash-out interno:', error);
        res.status(500).json({ error: 'Error al procesar el cash-out' });
    }
});

// 🔥 SEGURIDAD — el rake ahora llega SOLO por el endpoint interno con
// X-Internal-Token (antes era público y cualquiera podía fabricar ganancias
// de referidos). El reparto lo centraliza services/funds.js y queda
// auditado en rake_ledger.
const processRakeHandler = async (req, res) => {
    const { rakeAmount, playerId, tableId, handNumber } = req.body;
    const rake = Number(rakeAmount);
    const player = Number(playerId);
    if (!Number.isFinite(rake) || rake <= 0 || !Number.isInteger(player) || player <= 0) {
        return res.status(400).json({ error: 'Datos invalidos para procesar el rake' });
    }

    try {
        const split = await pool.getConnection().then(async (connection) => {
            try {
                await connection.beginTransaction();
                const result = await applyRake(connection, {
                    source: 'cash',
                    tableId: tableId ? String(tableId).slice(0, 80) : null,
                    handNumber: Number.isInteger(Number(handNumber)) ? Number(handNumber) : null,
                    winnerUserId: player,
                    rakeAmount: rake,
                });
                await connection.commit();
                return result;
            } catch (e) {
                await connection.rollback();
                throw e;
            } finally {
                connection.release();
            }
        });
        res.json({ message: 'Rake procesado correctamente', ...split });
    } catch (error) {
        console.error('Error al procesar el rake:', error);
        res.status(500).json({ error: 'Error al procesar el rake' });
    }
};

router.post('/poker/internal/process-rake', requireInternal, validateProcessRake, processRakeHandler);
// Compatibilidad con el motor viejo: misma lógica, pero también protegida
router.post('/poker/process-rake', requireInternal, validateProcessRake, processRakeHandler);

// ============================================================
// 🔥 ENDPOINT REFACTORIZADO: Casual Rooms (salas + auto-spawn)
// ============================================================
router.get('/tables/casual', async (req, res) => {
    try {
        // 1. Obtener datos vivos de pokerServer
        let liveTables = {};
        try {
            const liveRes = await fetch('http://localhost:3001/api/tables/live');
            if (liveRes.ok) liveTables = await liveRes.json();
        } catch (e) {
            console.log('Servidor de mesas reales apagado, mostrando 0 jugadores.');
        }

        // 2. Reconcilia salas activas con lo que hay en pokerServer
        //    (por si el proceso se reinició con salas en curso).
        reconcileActiveSalas(liveTables);

        // 3. Auto-spawn: si la última sala de cada config está llena, crear la siguiente.
        for (const cfg of SALA_CONFIGS) {
            await maybeSpawnNextSala(cfg, liveTables);
        }

        // 4. Armar respuesta con TODAS las mesas de TODAS las salas activas.
        const casualTables = [];

        for (const cfg of SALA_CONFIGS) {
            const salas = activeSalas[cfg.configKey];
            for (const salaNumber of salas) {
                for (let mesaNumber = 1; mesaNumber <= MESAS_PER_SALA; mesaNumber++) {
                    const tableId = buildTableId(cfg.baseTableId, salaNumber, mesaNumber);
                    const players = Array.isArray(liveTables[tableId]) ? liveTables[tableId] : [];
                    const locked = isMesaLocked(cfg, salaNumber, mesaNumber, liveTables);

                    casualTables.push({
                        id: tableId,
                        sala: salaNumber,
                        mesa: mesaNumber,
                        name: cfg.name,
                        baseName: cfg.name,
                        blinds: cfg.blinds,
                        minBuyIn: cfg.minBuyIn,
                        maxBuyIn: cfg.maxBuyIn,
                        maxPlayers: PLAYERS_PER_MESA,
                        timer: '15s',
                        tableType: cfg.tableType,
                        players,
                        locked,
                    });
                }
            }
        }

        // 5. Sala de práctica (siempre una sola, sin auto-spawn)
        const practicePlayers = getSeats()
            .filter(p => p !== null)
            .map(p => p.userId);

        casualTables.push({
            id: 'sala-practica-400',
            sala: null,
            mesa: null,
            name: 'SALA DE PRACTICA',
            blinds: '400 Fichas - Freeroll',
            minBuyIn: 0,
            maxBuyIn: 0,
            maxPlayers: 9,
            timer: '15s',
            tableType: '9-Max',
            image: '/img/sala-practica.jpg',
            players: practicePlayers,
            isPractice: true,
            locked: false,
        });

        res.json(casualTables);
    } catch (error) {
        console.error('Error al obtener mesas casuales:', error);
        res.status(500).json({ error: 'Error al cargar las mesas' });
    }
});

module.exports = router;