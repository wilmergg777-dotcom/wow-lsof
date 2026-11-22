// pokerServer.js — Servidor de póker independiente (puerto 3001)
const http = require('http');
const express = require('express');
const { Server } = require('socket.io');
const PokerTable = require('./pokerGame');

const PORT = 3001;
const app = express();
const httpServer = http.createServer(app);
const io = new Server(httpServer, { cors: { origin: '*' } });

// 🔥 DICCIONARIO DE MESAS ACTIVAS 🔥
const activeTables = {};
const socketToTable = {};
const disconnectTimeouts = {};

const TABLE_CONFIGS = {
  'omaha-05-1': { smallBlind: 0.25, bigBlind: 0.5, maxPlayers: 6 },
  'holdem-1-2': { smallBlind: 1, bigBlind: 2, maxPlayers: 6 },
  'holdem-2-4': { smallBlind: 5, bigBlind: 10, maxPlayers: 9 },
  'holdem-5-10': { smallBlind: 10, bigBlind: 20, maxPlayers: 6 },
  'shortdeck-10-20': { smallBlind: 20, bigBlind: 40, maxPlayers: 6 }
};

function getOrCreateTable(tableId) {
  if (!activeTables[tableId]) {
    const config = TABLE_CONFIGS[tableId] || { smallBlind: 1, bigBlind: 2, maxPlayers: 6 };
    console.log(`[Poker] Creando nueva mesa: ${tableId} con ciegas ${config.smallBlind}/${config.bigBlind}`);
    activeTables[tableId] = new PokerTable(io, config);
  }
  return activeTables[tableId];
}

// 🔥 NUEVA RUTA PARA EL LOBBY: Devuelve cuántos jugadores hay en cada mesa 🔥
app.get('/api/tables/live', (req, res) => {
    const counts = {};
    for (const [id, table] of Object.entries(activeTables)) {
        counts[id] = table.seats.filter(p => p !== null).map(p => p.userId);
    }
    res.json(counts);
});

io.on('connection', (socket) => {
  console.log('[Poker] conectado:', socket.id);

  // 💬 UNIRSE A LA SALA DE LA MESA (Para el chat)
  socket.on('joinTableRoom', (tableId) => {
    socket.join(tableId);
    socketToTable[socket.id] = tableId;
    console.log(`[Poker] ${socket.id} se unió a la sala ${tableId}`);
  });

  socket.on('sitDown', (data) => {
    const tableId = data.tableId || 'omaha-05-1';
    const table = getOrCreateTable(tableId);
    socketToTable[socket.id] = tableId;
    socket.join(tableId);

    const existingPlayer = table.seats.find(p => p !== null && p.userId === data.userId);

    // 🔥 LÓGICA PARA RECARGAR FICHAS SIN SALIR DE LA MESA
    if (existingPlayer) {
      const r = table.addChips(data.userId, data.buyInAmount || 1000);
      if (!r.ok) socket.emit('errorMsg', r.error);
      else console.log(`[Poker] ${data.username} hizo Rebuy en ${tableId}`);
      return;
    }

    // LÓGICA PARA SENTARSE POR PRIMERA VEZ
    const r = table.seat(socket.id, data.userId, data.username, data.buyInAmount || 1000, data.seatIndex);
    if (!r.ok) socket.emit('errorMsg', r.error);
  });

  socket.on('leaveTable', () => {
    const tableId = socketToTable[socket.id];
    if (!tableId) return;
    const table = activeTables[tableId];
    if (!table) return;

    if (disconnectTimeouts[socket.id]) {
      clearTimeout(disconnectTimeouts[socket.id]);
      delete disconnectTimeouts[socket.id];
    }
    const r = table.leave(socket.id, false);
    if (!r.ok) socket.emit('errorMsg', r.error);
    socket.leave(tableId);
    delete socketToTable[socket.id];
  });

  socket.on('startGame', () => {
    const tableId = socketToTable[socket.id];
    if (!tableId || !activeTables[tableId]) return;
    const r = activeTables[tableId].startHand();
    if (!r.ok) socket.emit('errorMsg', r.error);
  });

  socket.on('playerAction', (data) => {
    const tableId = data.tableId || socketToTable[socket.id];
    if (!tableId || !activeTables[tableId]) return;
    const action = typeof data === 'string' ? data : data.action;
    const amount = typeof data === 'object' ? (data.amount || 0) : 0;
    const r = activeTables[tableId].action(socket.id, action, amount);
    if (!r.ok) socket.emit('errorMsg', r.error);
  });

  // 💬 SISTEMA DE CHAT 💬
  socket.on('chatMessage', (msg) => {
    const tableId = socketToTable[socket.id];
    if (tableId) {
      // Enviar el mensaje a todos en la mesa (incluyendo al que lo envía)
      io.to(tableId).emit('chatMessage', msg);
    } else {
      // Si no está en una mesa, devolvérselo a él mismo
      socket.emit('chatMessage', msg);
    }
  });

  socket.on('reconnect_player', (data) => {
    const { userId, tableId } = data;
    if (!tableId) return;
    console.log(`[Poker] Intento de reconexión para userId: ${userId} en mesa ${tableId}`);
    const table = activeTables[tableId];
    if (!table) return;

    const player = table.seats.find(p => p !== null && p.userId === userId);
    if (player) {
      socketToTable[socket.id] = tableId;
      if (disconnectTimeouts[player.socketId]) {
        clearTimeout(disconnectTimeouts[player.socketId]);
        delete disconnectTimeouts[player.socketId];
      }
      const r = table.reconnectPlayer(socket.id, userId);
      if (!r.ok) socket.emit('errorMsg', r.error);
      else socket.join(tableId);
    }
  });

  socket.on('disconnect', () => {
    console.log('[Poker] desconectado:', socket.id);
    const tableId = socketToTable[socket.id];
    if (!tableId || !activeTables[tableId]) return;
    const table = activeTables[tableId];

    disconnectTimeouts[socket.id] = setTimeout(() => {
      console.log(`[Poker] Tiempo de gracia agotado en ${tableId}. Eliminando jugador:`, socket.id);
      table.leave(socket.id, true);
      delete disconnectTimeouts[socket.id];
      delete socketToTable[socket.id];
    }, 15000);
  });
});

httpServer.listen(PORT, () => {
  console.log(`🃏 Poker server en http://localhost:${PORT}`);
});