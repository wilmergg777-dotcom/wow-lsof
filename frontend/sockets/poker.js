const { getTable } = require('../services/practice-table');

const disconnectTimeouts = {};

function cancelDisconnectTimeout(socketId) {
    if (disconnectTimeouts[socketId]) {
        clearTimeout(disconnectTimeouts[socketId]);
        delete disconnectTimeouts[socketId];
    }
}

module.exports = function setupPokerSockets(io) {
    io.on('connection', (socket) => {
        console.log('Jugador conectado al servidor de juego:', socket.id);

        socket.on('chatMessage', (msg) => {
            io.emit('chatMessage', msg);
        });

        socket.on('join_practice_table', (userData) => {
            const practiceTable = getTable();
            if (!practiceTable) return socket.emit('error_mesa', 'Mesa no inicializada');

            if (!userData || !userData.id) {
                socket.emit('error_mesa', 'Datos de usuario invalidos');
                return;
            }

            const existingPlayer = practiceTable.seats.find(p => p !== null && p.userId === userData.id);
            if (existingPlayer) {
                cancelDisconnectTimeout(existingPlayer.socketId);
                const r = practiceTable.reconnectPlayer(socket.id, userData.id);
                if (!r.ok) {
                    socket.emit('error_mesa', r.error);
                } else {
                    socket.join('sala-practica-400');
                    console.log(`[Practica] ${userData.username} reconectado.`);
                }
                return;
            }

            const emptySeat = practiceTable.seats.findIndex(s => s === null);
            if (emptySeat === -1) {
                socket.emit('error_mesa', 'La Sala de Practica esta llena.');
                return;
            }

            const res = practiceTable.seat(socket.id, userData.id, userData.username, 400, emptySeat);
            if (!res.ok) {
                socket.emit('error_mesa', res.error);
            } else {
                socket.join('sala-practica-400');
                console.log(`[Practica] ${userData.username} se sento.`);
            }
        });

        socket.on('reconnect_player', (data) => {
            const practiceTable = getTable();
            if (!practiceTable) return;

            const { userId } = data || {};
            if (!userId) {
                socket.emit('errorMsg', 'userId requerido para reconectar');
                return;
            }

            const player = practiceTable.seats.find(p => p !== null && p.userId === userId);
            if (!player) {
                console.log('[Practica] Jugador no encontrado en la mesa para reconectar.');
                return;
            }

            cancelDisconnectTimeout(player.socketId);
            const r = practiceTable.reconnectPlayer(socket.id, userId);
            if (!r.ok) {
                socket.emit('errorMsg', r.error);
                console.log(`[Practica] Error al reconectar: ${r.error}`);
            } else {
                socket.join('sala-practica-400');
                console.log(`[Practica] ${player.username} reconectado exitosamente.`);
            }
        });

        socket.on('playerAction', (data) => {
            const practiceTable = getTable();
            if (!practiceTable) return;

            const action = typeof data === 'string' ? data : data.action;
            const amount = typeof data === 'object' ? (data.amount || 0) : 0;

            const res = practiceTable.action(socket.id, action, amount);
            if (!res.ok) socket.emit('errorMsg', res.error);
        });

        socket.on('rebuy_practice', () => {
            const practiceTable = getTable();
            if (!practiceTable) return;

            const player = practiceTable.seats.find(p => p !== null && p.socketId === socket.id);
            if (player) {
                player.chips += 400;
                player.status = 'waiting';
                practiceTable.broadcast();
                console.log(`[Practica] ${player.username} recargo 400 fichas.`);
            } else {
                socket.emit('errorMsg', 'No estas en la mesa para recargar.');
            }
        });

        socket.on('leaveTable', () => {
            const practiceTable = getTable();
            if (!practiceTable) return;
            cancelDisconnectTimeout(socket.id);
            practiceTable.leave(socket.id, false);
        });

        socket.on('leave_practice_table', () => {
            const practiceTable = getTable();
            if (!practiceTable) return;
            cancelDisconnectTimeout(socket.id);
            practiceTable.leave(socket.id, true);
        });

        socket.on('disconnect', () => {
            console.log('[Practica] desconectado:', socket.id);
            cancelDisconnectTimeout(socket.id);

            disconnectTimeouts[socket.id] = setTimeout(() => {
                console.log('[Practica] Tiempo de gracia agotado. Eliminando jugador:', socket.id);
                const practiceTable = getTable();
                if (practiceTable) practiceTable.leave(socket.id, true);
                delete disconnectTimeouts[socket.id];
            }, 15000);
        });
    });
};