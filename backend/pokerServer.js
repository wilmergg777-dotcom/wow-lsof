// pokerServer.js — Servidor de póker independiente (puerto 3001)
const http = require('http');
const express = require('express');
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const PokerTable = require('./pokerGame');
// 🔥 CONEXIÓN A BASE DE DATOS
const db = require('./db');

const PORT = 3001;
const PLAYERS_PER_MESA = 9; // 🔥 default global

// 🔥 SEGURIDAD: JWT (igual que el backend principal) y CORS restringido
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  console.error('❌ FATAL: JWT_SECRET no está definido (pokerServer).');
  process.exit(1);
}
const ALLOWED_ORIGINS = [
  'http://localhost:5173',
  'http://localhost:3000',
  'https://royalbet.duckdns.org',
];

const app = express();
app.use(express.json());
const httpServer = http.createServer(app);
const io = new Server(httpServer, { cors: { origin: ALLOWED_ORIGINS } });

// 🔥 SEGURIDAD: exigir JWT en TODAS las conexiones de socket.
// Antes cualquiera podía conectarse y suplantar a otro jugador (robo de silla).
io.use((socket, next) => {
  const token = socket.handshake?.auth?.token || socket.handshake?.query?.token || null;
  if (!token) return next(new Error('unauthorized: token requerido'));
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    socket.data.user = { id: payload.id, username: payload.username };
    return next();
  } catch (err) {
    return next(new Error('unauthorized: token inválido'));
  }
});

const activeTables = {};
const socketToTable = {};
const disconnectTimeouts = {};

// 🔥 RECONEXIÓN: 60s de gracia en mesas cash (antes 15s). Durante la gracia
// la silla se conserva y la fila de active_player_tables NO se borra, para
// que /poker/my-tables pueda restaurar la partida al volver al lobby.
const GRACE_PERIOD_MS = 60000;

const TABLE_CONFIGS = {
  'omaha-05-1':     { smallBlind: 0.25, bigBlind: 0.5,  maxPlayers: PLAYERS_PER_MESA },
  'holdem-1-2':     { smallBlind: 1,    bigBlind: 2,    maxPlayers: PLAYERS_PER_MESA },
  'holdem-2-4':     { smallBlind: 5,    bigBlind: 10,   maxPlayers: PLAYERS_PER_MESA },
  'holdem-5-10':    { smallBlind: 10,   bigBlind: 20,   maxPlayers: PLAYERS_PER_MESA },
  'shortdeck-10-20':{ smallBlind: 20,   bigBlind: 40,   maxPlayers: PLAYERS_PER_MESA },
};

// ============================================================
// Helpers de IDs auto-spawneados
// ============================================================
function parseTableId(tableId) {
  if (typeof tableId !== 'string') return null;

  let m = tableId.match(/^(.+)-s(\d+)-m(\d+)$/);
  if (m) return { base: m[1], sala: parseInt(m[2], 10), mesa: parseInt(m[3], 10) };

  m = tableId.match(/^(.+)-m(\d+)$/);
  if (m) return { base: m[1], sala: 1, mesa: parseInt(m[2], 10) };

  if (TABLE_CONFIGS[tableId]) return { base: tableId, sala: 1, mesa: 1 };

  return null;
}

function isValidTableId(tableId) {
  const parsed = parseTableId(tableId);
  return !!parsed && !!TABLE_CONFIGS[parsed.base];
}

function getConfigForTable(tableId) {
  if (TABLE_CONFIGS[tableId]) return TABLE_CONFIGS[tableId];
  const parsed = parseTableId(tableId);
  if (parsed && TABLE_CONFIGS[parsed.base]) return TABLE_CONFIGS[parsed.base];
  return { smallBlind: 1, bigBlind: 2, maxPlayers: PLAYERS_PER_MESA };
}

function prevMesaId(parsed) {
  const { base, sala, mesa } = parsed;
  if (mesa > 1) {
    if (sala === 1) {
      return mesa === 2 ? base : `${base}-m${mesa - 1}`;
    }
    return `${base}-s${sala}-m${mesa - 1}`;
  }
  return `${base}-s${sala - 1}-m2`;
}

function getPlayersCount(tableId) {
  const t = activeTables[tableId];
  if (!t) return 0;
  return t.seats.filter(p => p !== null).length;
}

function isTableLocked(tableId) {
  const parsed = parseTableId(tableId);
  if (!parsed) return true;
  if (parsed.mesa <= 1) return false;

  const prevId = prevMesaId(parsed);
  const prevConfig = getConfigForTable(prevId);
  return getPlayersCount(prevId) < prevConfig.maxPlayers;
}

function getOrCreateTable(tableId) {
  if (!activeTables[tableId]) {
    const config = getConfigForTable(tableId);
    console.log(`[Poker] Creando mesa: ${tableId} (${config.smallBlind}/${config.bigBlind}, ${config.maxPlayers} seats)`);
    activeTables[tableId] = new PokerTable(io, { ...config, tableId });
  }
  return activeTables[tableId];
}

function findTableOfUser(userId) {
  for (const [id, table] of Object.entries(activeTables)) {
    const seat = table.seats.find(p => p !== null && p.userId === userId);
    if (seat) return id;
  }
  return null;
}

// 🔥 NUEVO: helper para extraer el token del handshake del socket.
// Necesario para que el motor pueda hacer cash-out autenticado.
function getSocketToken(socket) {
  return socket.handshake?.auth?.token || socket.handshake?.query?.token || null;
}

// ============================================================
// REST: lobby + creación (on-demand)
// ============================================================
app.get('/api/tables/live', (req, res) => {
  const counts = {};
  for (const [id, table] of Object.entries(activeTables)) {
    counts[id] = table.seats.filter(p => p !== null).map(p => p.userId);
  }
  res.json(counts);
});

app.post('/api/tables/create', (req, res) => {
  const { tableId } = req.body || {};
  if (!tableId || !isValidTableId(tableId)) {
    return res.status(400).json({ error: 'tableId inválido' });
  }
  getOrCreateTable(tableId);
  res.json({ ok: true, tableId });
});

// ============================================================
// Sockets
// ============================================================
io.on('connection', (socket) => {
  console.log('[Poker] conectado:', socket.id);

  socket.on('joinTableRoom', (tableId) => {
    if (!isValidTableId(tableId)) {
      socket.emit('errorMsg', 'Mesa inválida');
      return;
    }
    socket.join(tableId);
    socketToTable[socket.id] = tableId;
    console.log(`[Poker] ${socket.id} se unió a la sala ${tableId}`);
  });

  // 🔥 SEGURIDAD: identidad SIEMPRE del JWT (antes se confiaba en data.userId
  // que el cliente enviaba → cualquier usuario podía sentarse como otro).
  socket.on('sitDown', async (data, ack) => {
    const respond = (ok, error) => {
      if (typeof ack === 'function') ack({ ok, error });
      if (!ok && error) socket.emit('errorMsg', error);
    };

    const authUser = socket.data.user;
    if (!authUser || !authUser.id) return respond(false, 'Debes iniciar sesión');
    if (!data) return respond(false, 'Datos de usuario inválidos');

    const userId = authUser.id;            // ✅ del JWT, NO del cliente
    const username = authUser.username;
    const tableId = data.tableId || 'omaha-05-1';
    if (!isValidTableId(tableId)) return respond(false, 'Mesa inválida');

    let buyInAmount = Number(data.buyInAmount);
    if (!Number.isFinite(buyInAmount) || buyInAmount <= 0) {
      buyInAmount = 1000;
      console.warn(`[Poker] buyInAmount inválido para ${username}, usando 1000 por defecto`);
    }

    const config = getConfigForTable(tableId);
    const existingTable = activeTables[tableId];

    // 1) ¿Ya está sentado en ESTA mesa? → reconexión + rebuy
    // 🔥 FLUJO RE-BUY: cuando un jugador se queda sin fichas (modo espectador)
    // y pulsa "Comprar más", el frontend emite sitDown con seatIndex = su propia silla.
    // Esta rama detecta que ya existe y añade fichas con addChips().
    const existingPlayer = existingTable?.seats.find(
      p => p !== null && p.userId === userId
    );
    if (existingPlayer) {
      socketToTable[socket.id] = tableId;
      socket.join(tableId);

      if (existingPlayer.socketId !== socket.id) {
        if (disconnectTimeouts[existingPlayer.socketId]) {
          clearTimeout(disconnectTimeouts[existingPlayer.socketId]);
          delete disconnectTimeouts[existingPlayer.socketId];
        }
        const rr = existingTable.reconnectPlayer(socket.id, userId);
        if (!rr.ok) return respond(false, rr.error);
      }

      const r = existingTable.addChips(userId, buyInAmount);
      if (!r.ok) return respond(false, r.error);

      // 🔥 Actualizar/crear el registro de mesa activa sin duplicados
      try {
        await db.query(
          `INSERT INTO active_player_tables (user_id, table_id, socket_id, server_type)
           VALUES (?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE socket_id = VALUES(socket_id), server_type = VALUES(server_type)`,
          [userId, tableId, socket.id, 'real']
        );
      } catch (err) {
        console.error('[DB Error] Error actualizando mesa activa en rebuy/reconexión:', err);
      }

      console.log(`[Poker] ${username} rebuy en ${tableId} (+${buyInAmount})`);
      return respond(true);
    }

    // 🔥 VALIDACIÓN CROSS-TABLE EN MEMORIA (Evita 2 mesas en el mismo servidor 3001)
    const otherTableId = findTableOfUser(userId);
    if (otherTableId) {
      return respond(false, `Ya estás sentado en la mesa ${otherTableId}. Salí primero.`);
    }

    // 2) ¿La mesa está bloqueada? (mesa 2 esperando que mesa 1 se llene)
    if (isTableLocked(tableId)) {
      return respond(false, 'Esta mesa se abre cuando la mesa anterior esté llena');
    }

    // 3) Crear mesa si no existe y validar cupo
    const table = getOrCreateTable(tableId);

    const occupied = table.seats.filter(p => p !== null).length;
    if (occupied >= config.maxPlayers) {
      return respond(false, 'La mesa está llena');
    }

    // 4) Validar seatIndex si viene (defensa contra clientes maliciosos)
    if (data.seatIndex != null) {
      if (
        !Number.isInteger(data.seatIndex) ||
        data.seatIndex < 0 ||
        data.seatIndex >= config.maxPlayers
      ) {
        return respond(false, 'Índice de silla inválido');
      }
      if (table.seats[data.seatIndex] !== null) {
        return respond(false, 'Esa silla ya está ocupada');
      }
    }

    // 🔥 5) VALIDACIÓN EN BASE DE DATOS (Regla Máximo 2 Mesas Globales)
    try {
      const [rows] = await db.query(
        'SELECT COUNT(*) AS total FROM active_player_tables WHERE user_id = ?',
        [userId]
      );

      if (rows[0].total >= 2) {
        return respond(false, 'Límite alcanzado: No puedes estar en más de 2 mesas a la vez.');
      }
    } catch (err) {
      console.error('[DB Error] Error validando límite de mesas:', err);
      return respond(false, 'Error del servidor al validar el límite de mesas.');
    }

    // 6) Sentar
    socketToTable[socket.id] = tableId;
    socket.join(tableId);

    // 🔥 AGREGADO: data.avatar_url || null
    const r = table.seat(
      socket.id,
      userId,
      username,
      buyInAmount,
      data.seatIndex,
      data.avatar_url || null
    );
    if (!r.ok) return respond(false, r.error);

    // 🔥 7) GUARDAR EN BASE DE DATOS QUE SE SENTÓ (UPSERT para evitar duplicados)
    try {
      await db.query(
        `INSERT INTO active_player_tables (user_id, table_id, socket_id, server_type)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE socket_id = VALUES(socket_id), server_type = VALUES(server_type)`,
        [userId, tableId, socket.id, 'real']
      );
    } catch (err) {
      console.error('[DB Error] Error guardando mesa activa:', err);
    }

    // 8) ¿Mesa llena? → log para diagnóstico
    const newOccupied = table.seats.filter(p => p !== null).length;
    if (newOccupied >= config.maxPlayers) {
      console.log(`[Poker] ✅ Mesa LLENA: ${tableId} (${newOccupied}/${config.maxPlayers}).`);
    }

    return respond(true);
  });

  // 🔥 NUEVO EVENTO: Levantarse para ser espectador sin salir de la sala
  socket.on('standUp', async () => {
    const tableId = socketToTable[socket.id];
    if (!tableId) return;
    const table = activeTables[tableId];
    if (!table) return;

    if (disconnectTimeouts[socket.id]) {
      clearTimeout(disconnectTimeouts[socket.id]);
      delete disconnectTimeouts[socket.id];
    }

    // Buscamos al jugador ANTES de quitarlo de la mesa
    const player = table.seats.find(p => p !== null && p.socketId === socket.id);
    if (!player) return; // Si no está sentado, no hace nada

    const token = getSocketToken(socket);
    // Lo quitamos de la mesa (true = ignorar regla de 5 manos)
    // Se le hará cash-out automáticamente en el motor
    const r = table.leave(socket.id, true, token);

    if (!r.ok) {
      socket.emit('errorMsg', r.error);
      return;
    }

    // Limpiamos la DB solo del registro de este socket
    try {
      await db.query(
        'DELETE FROM active_player_tables WHERE user_id = ? AND table_id = ? AND socket_id = ? AND server_type = "real"',
        [player.userId, tableId, player.socketId]
      );
    } catch (err) {
      console.error('[DB Error] Error al eliminar mesa activa en standUp:', err);
    }

    // ⚠️ IMPORTANTE: NO emitimos leaveSuccess. El jugador se queda en la sala.
    // Tampoco hacemos socket.leave(tableId) ni borramos socketToTable[socket.id]
    console.log(`[Poker] ${player.username} se levantó para ver de espectador.`);
  });

  // 🔥 FIX: pasar authToken a leave() para cash-out autenticado,
  // manejar errores del motor, y borrar de la DB solo si tuvo éxito.
  socket.on('leaveTable', async () => {
    const tableId = socketToTable[socket.id];
    if (!tableId) return;
    const table = activeTables[tableId];
    if (!table) return;

    if (disconnectTimeouts[socket.id]) {
      clearTimeout(disconnectTimeouts[socket.id]);
      delete disconnectTimeouts[socket.id];
    }

    // Buscamos al jugador ANTES de quitarlo de la mesa
    const player = table.seats.find(p => p !== null && p.socketId === socket.id);

    const token = getSocketToken(socket);
    const r = table.leave(socket.id, false, token);

    if (!r.ok) {
      // 🔥 Si el motor rechaza la salida (ej. "Debes jugar al menos 5 manos"),
      // NO salimos de la sala ni borramos de la DB. Solo emitimos el error.
      socket.emit('errorMsg', r.error);
      return;
    }

    // 🔥 Solo borrar de la DB si el motor confirmó la salida
    if (player) {
      try {
        await db.query(
          'DELETE FROM active_player_tables WHERE user_id = ? AND table_id = ? AND socket_id = ? AND server_type = "real"',
          [player.userId, tableId, player.socketId]
        );
      } catch (err) {
        console.error('[DB Error] Error al eliminar mesa activa:', err);
      }
    }

    socket.leave(tableId);
    delete socketToTable[socket.id];

    // 🔥 Emitir leaveSuccess para que el frontend vuelva al lobby
    socket.emit('leaveSuccess');
  });

  socket.on('startGame', () => {
    const tableId = socketToTable[socket.id];
    if (!tableId || !activeTables[tableId]) return;
    const r = activeTables[tableId].startHand();
    if (!r.ok) socket.emit('errorMsg', r.error);
  });

  socket.on('playerAction', (data) => {
    const socketTableId = socketToTable[socket.id];
    if (!socketTableId) return;

    let tableId = socketTableId;
    if (typeof data === 'object' && data?.tableId) {
      if (data.tableId !== socketTableId) {
        socket.emit('errorMsg', 'Acción enviada a mesa incorrecta');
        return;
      }
      tableId = data.tableId;
    }

    const table = activeTables[tableId];
    if (!table) return;

    // 🔥 Salvaguarda: si el jugador tiene 0 fichas (espectador), ignorar acciones
    const player = table.seats.find(p => p !== null && p.socketId === socket.id);
    if (player && player.chips === 0) {
      return socket.emit('errorMsg', 'No tienes fichas para actuar. Estás en modo espectador.');
    }

    const action = typeof data === 'string' ? data : data?.action;
    const amount = typeof data === 'object' ? (data?.amount || 0) : 0;
    if (!action) return;

    const r = table.action(socket.id, action, amount);
    if (!r.ok) socket.emit('errorMsg', r.error);
  });

  // 🔥 FIX: aceptar string u objeto { user, text, type }
  socket.on('chatMessage', (msg) => {
    let username = 'Jugador';
    let text = '';

    if (typeof msg === 'string') {
      text = msg.trim().slice(0, 280);
    } else if (msg && typeof msg === 'object') {
      username = msg.user || username;
      text = String(msg.text || '').trim().slice(0, 280);
    }

    if (!text) return;

    const tableId = socketToTable[socket.id];
    const payload = { user: username, username, text, type: 'user', ts: Date.now() };
    if (tableId) io.to(tableId).emit('chatMessage', payload);
    else socket.emit('chatMessage', payload);
  });

  socket.on('reconnect_player', async (data) => {
    // 🔥 SEGURIDAD: el userId viene SIEMPRE del JWT (evita robo de silla).
    const authUser = socket.data.user;
    if (!authUser || !authUser.id) return socket.emit('errorMsg', 'Debes iniciar sesión');
    const tableId = data?.tableId;
    if (!tableId) return;
    if (!isValidTableId(tableId)) return;

    const userId = authUser.id;
    console.log(`[Poker] Reconexión userId=${userId} en ${tableId}`);
    const table = activeTables[tableId];
    if (!table) return;

    const player = table.seats.find(p => p !== null && p.userId === userId);
    if (!player) return;

    socketToTable[socket.id] = tableId;
    if (disconnectTimeouts[player.socketId]) {
      clearTimeout(disconnectTimeouts[player.socketId]);
      delete disconnectTimeouts[player.socketId];
    }
    const r = table.reconnectPlayer(socket.id, userId);
    if (!r.ok) {
      socket.emit('errorMsg', r.error);
    } else {
      socket.join(tableId);

      // 🔥 Actualizar/crear el registro de mesa activa sin duplicados
      try {
        await db.query(
          `INSERT INTO active_player_tables (user_id, table_id, socket_id, server_type)
           VALUES (?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE socket_id = VALUES(socket_id), server_type = VALUES(server_type)`,
          [userId, tableId, socket.id, 'real']
        );
      } catch (err) {
        console.error('[DB Error] Error actualizando mesa activa en reconnect_player:', err);
      }
    }
  });

  // 🔥 FIX: extraer el token ANTES de que se cierre el socket y pasarlo a leave().
  // Sin esto, en dinero real el motor intentaría cash-out con null y el jugador
  // perdería sus fichas al desconectarse.
  // 🔥 REANUDACIÓN: la fila de active_player_tables NO se borra al desconectar;
  // se conserva durante la gracia para que /poker/my-tables restaure la mesa.
  socket.on('disconnect', async () => {
    console.log('[Poker] desconectado:', socket.id);
    const tableId = socketToTable[socket.id];
    delete socketToTable[socket.id];

    if (!tableId || !activeTables[tableId]) return;
    const table = activeTables[tableId];

    // Buscamos al jugador ANTES de quitarlo de la mesa
    const player = table.seats.find(p => p !== null && p.socketId === socket.id);

    // 🔥 Extraer token antes de que se cierre el socket (el handshake sigue disponible)
    const token = getSocketToken(socket);

    if (player) {
      socket.to(tableId).emit('player_disconnected', {
        userId: player.userId,
        username: player.username,
        graceMs: GRACE_PERIOD_MS,
      });
    }

    disconnectTimeouts[socket.id] = setTimeout(() => {
      console.log(`[Poker] Grace agotado en ${tableId}. Eliminando:`, socket.id);
      table.leave(socket.id, true, token);
      // 🔥 La fila se limpia SOLO cuando la gracia expira (mismo flujo que
      // la sala de práctica del backend principal).
      if (player) {
        db.query(
          'DELETE FROM active_player_tables WHERE user_id = ? AND table_id = ? AND socket_id = ? AND server_type = "real"',
          [player.userId, tableId, socket.id]
        ).catch(err => console.error('[DB Error] Error al eliminar mesa activa tras gracia:', err));
      }
      delete disconnectTimeouts[socket.id];
    }, GRACE_PERIOD_MS);
  });
});

httpServer.listen(PORT, () => {
  console.log(`🃏 Poker server en http://localhost:${PORT}`);
});