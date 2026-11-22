const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config');
const { getTable } = require('../services/practice-table');
const mtt = require('../services/mtt-tournaments');
// ?? IMPORTANTE: Ajusta esta ruta a donde tengas tu conexion a MySQL (ej. pool de mysql2)
const db = require('../db'); 

const disconnectTimeouts = {};
// 🔥 RECONEXIÓN: 90s de gracia para recuperar la sesión sin perder la silla
// (antes 15s: con una simple recarga de página se perdía el asiento y el bote)
const GRACE_PERIOD_MS = 90000;
const MAX_CHAT_LENGTH = 280;

// ?? CONSTANTE DE REGLA DE NEGOCIO
const MAX_TABLES_ALLOWED = 2;
const PRACTICE_TABLE_ID = 'sala-practica-400';

function cancelDisconnectTimeout(socketId) {
    if (disconnectTimeouts[socketId]) {
        clearTimeout(disconnectTimeouts[socketId]);
        delete disconnectTimeouts[socketId];
    }
}

// ?? FUNCIoN AUXILIAR: Eliminar registro de mesa activa
// ?? FIX MULTIMESA: usar el tableId REAL (antes borraba siempre la fila de práctica)
async function removeActiveTable(userId, tableId, socketId) {
    try {
        await db.query(
            'DELETE FROM active_player_tables WHERE user_id = ? AND table_id = ? AND socket_id = ?',
            [userId, tableId || PRACTICE_TABLE_ID, socketId]
        );
    } catch (err) {
        console.error('[DB Error] No se pudo eliminar la mesa activa:', err);
    }
}

// ?? FUNCIoN AUXILIAR: Extraer token del handshake
function getSocketToken(socket) {
    return socket.handshake.auth?.token || socket.handshake.query?.token || null;
}

// ?? MTT: resolver la mesa a la que pertenece este socket.
// Busca primero en mesas de TORNEO (por socket o por userId) y luego en la de PRÁCTICA.
function resolveTableForSocket(socket, user) {
    if (user?.id) {
        const t = mtt.findTableBySocket(socket.id);
        if (t) return { table: t.table, kind: 'tournament' };
        const tu = mtt.findTableByUser(user.id);
        if (tu) return { table: tu.table, kind: 'tournament' };
    }
    const practice = getTable();
    if (practice) {
        const bySocket = practice.seats.find(p => p !== null && p.socketId === socket.id);
        if (bySocket) return { table: practice, kind: 'practice' };
        if (user?.id) {
            const byUser = practice.seats.find(p => p !== null && p.userId === user.id);
            if (byUser) return { table: practice, kind: 'practice' };
        }
    }
    return null;
}

module.exports = function setupPokerSockets(io) {
    // ?? FIX 1: middleware de auth (JWT)
    io.use((socket, next) => {
        const token =
            socket.handshake.auth?.token ||
            socket.handshake.query?.token;

        if (!token) {
            socket.data.user = null;
            return next();
        }
        try {
            const payload = jwt.verify(token, JWT_SECRET);
            socket.data.user = { id: payload.id, username: payload.username };
            next();
        } catch (err) {
            socket.data.user = null;
            next();
        }
    });

    io.on('connection', (socket) => {
        const user = socket.data.user;
        console.log(
            `Jugador conectado: ${socket.id}` +
            (user ? ` (${user.username})` : ' (anonimo)')
        );

        // ?? FIX 2: chat scoped a la sala ?? acepta string u objeto { user, text, type }
        // ?? SEGURIDAD: el nombre SIEMPRE viene de la sesión autenticada.
        // Antes el cliente podía mandar { user: 'otro' } y hacerse pasar por
        // cualquier jugador (suplantación en el chat).
        socket.on('chatMessage', (msg) => {
            const username = user?.username || 'Anonimo';
            let text = '';

            if (typeof msg === 'string') {
                text = msg.trim().slice(0, MAX_CHAT_LENGTH);
            } else if (msg && typeof msg === 'object') {
                text = String(msg.text || '').trim().slice(0, MAX_CHAT_LENGTH);
            }

            if (!text) return;

            const rooms = Array.from(socket.rooms).filter(r => r !== socket.id);
            const room = rooms[0];
            if (!room) return;

            io.to(room).emit('chatMessage', {
                user: username,
                username,
                text,
                type: 'user',
                ts: Date.now(),
            });
        });

        socket.on('join_practice_table', async (userData) => {
            if (!user) return socket.emit('error_mesa', 'Debes iniciar sesion');

            const userId = user.id;
            const username = user.username;
            // ?? FIX AVATAR: Extraemos el avatar_url que enviara el frontend
            const avatarUrl = userData?.avatar_url || null;

            const practiceTable = getTable();
            if (!practiceTable) return socket.emit('error_mesa', 'Mesa no inicializada');

            // 1. Verificar si es una RECONEXIoN (ya tiene silla)
            const existingPlayer = practiceTable.seats.find(
                p => p !== null && p.userId === userId
            );
            if (existingPlayer) {
                cancelDisconnectTimeout(existingPlayer.socketId);
                const r = practiceTable.reconnectPlayer(socket.id, userId);
                if (!r.ok) {
                    socket.emit('error_mesa', r.error);
                } else {
                    socket.join(PRACTICE_TABLE_ID);
                    socket.to(PRACTICE_TABLE_ID).emit('player_reconnected', { userId, username });
                    console.log(`[Practica] ${username} reconectado.`);

                    // ?? Actualizar socket_id en la DB para la reconexion
                    try {
                        await db.query(
                            `INSERT INTO active_player_tables (user_id, table_id, socket_id, server_type) 
                             VALUES (?, ?, ?, ?) 
                             ON DUPLICATE KEY UPDATE socket_id = VALUES(socket_id), server_type = VALUES(server_type)`,
                            [userId, PRACTICE_TABLE_ID, socket.id, 'practice']
                        );
                    } catch (dbErr) {
                        console.error('[DB Error] Error al actualizar socket en reconexion:', dbErr);
                    }
                }
                return;
            }

            // 2. Si es un jugador NUEVO, validar la regla de MaXIMO 2 MESAS
            try {
                const [rows] = await db.query(
                    'SELECT COUNT(*) AS total FROM active_player_tables WHERE user_id = ?',
                    [userId]
                );

                if (rows[0].total >= MAX_TABLES_ALLOWED) {
                    return socket.emit('error_mesa', 'Limite alcanzado: No puedes estar en mas de 2 mesas a la vez.');
                }

                // 3. Buscar silla libre
                const emptySeat = practiceTable.seats.findIndex(s => s === null);
                if (emptySeat === -1) {
                    return socket.emit('error_mesa', 'La Sala de Practica esta llena.');
                }

                // 4. Sentar al jugador en el juego
                // ?? FIX AVATAR: Le pasamos el avatarUrl como 6to parametro
                const res = practiceTable.seat(socket.id, userId, username, 400, emptySeat, avatarUrl);
                if (!res.ok) {
                    socket.emit('error_mesa', res.error);
                } else {
                    // 5. GUARDAR EN LA BASE DE DATOS (Mesa Activa) - UPSERT para evitar duplicados
                    await db.query(
                        `INSERT INTO active_player_tables (user_id, table_id, socket_id, server_type) 
                         VALUES (?, ?, ?, ?) 
                         ON DUPLICATE KEY UPDATE socket_id = VALUES(socket_id), server_type = VALUES(server_type)`,
                        [userId, PRACTICE_TABLE_ID, socket.id, 'practice']
                    );
                    
                    socket.join(PRACTICE_TABLE_ID);
                    console.log(`[Practica] ${username} se sento.`);
                }
            } catch (error) {
                console.error('[DB Error] Error al verificar/insertar mesa activa:', error);
                socket.emit('error_mesa', 'Error interno del servidor al intentar sentarse.');
            }
        });

        socket.on('reconnect_player', async () => {
            if (!user) return socket.emit('errorMsg', 'Debes iniciar sesion');
            const practiceTable = getTable();
            if (!practiceTable) return;

            const player = practiceTable.seats.find(
                p => p !== null && p.userId === user.id
            );
            if (!player) {
                console.log('[Practica] Jugador no encontrado para reconectar.');
                return;
            }

            cancelDisconnectTimeout(player.socketId);
            const r = practiceTable.reconnectPlayer(socket.id, user.id);
            if (!r.ok) {
                socket.emit('errorMsg', r.error);
                console.log(`[Practica] Error al reconectar: ${r.error}`);
            } else {
                socket.join(PRACTICE_TABLE_ID);
                socket.to(PRACTICE_TABLE_ID).emit('player_reconnected', {
                    userId: user.id, username: user.username,
                });
                console.log(`[Practica] ${user.username} reconectado exitosamente.`);

                // ?? Actualizar socket_id en la DB para la reconexion
                try {
                    await db.query(
                        `INSERT INTO active_player_tables (user_id, table_id, socket_id, server_type) 
                         VALUES (?, ?, ?, ?) 
                         ON DUPLICATE KEY UPDATE socket_id = VALUES(socket_id), server_type = VALUES(server_type)`,
                        [user.id, PRACTICE_TABLE_ID, socket.id, 'practice']
                    );
                } catch (dbErr) {
                    console.error('[DB Error] Error al actualizar socket en reconexion:', dbErr);
                }
            }
        });

        // ?? MTT NUEVO: unirse a la mesa de TORNEO donde el jugador tiene silla asignada
        // ?? MULTIMESA: acepta tableId para elegir la mesa concreta (hasta 2 mesas por jugador)
        socket.on('join_tournament_table', (data) => {
            if (!user) return socket.emit('error_mesa', 'Debes iniciar sesion');
            const tableId = data?.tableId || data?.tableData?.id || null;
            const table = mtt.attachPlayer(socket, user.id, tableId);
            if (!table) {
                return socket.emit('error_mesa', 'No tienes silla en ningún torneo en juego.');
            }
            console.log(`[MTT] ${user.username} conectado a su mesa de torneo ${table.tableId}.`);
        });

        // ?? MULTIMESA / RECONEXIÓN: lista de mesas activas del jugador
        // (práctica + todas las mesas de torneo) para retomar donde se quedó.
        socket.on('get_my_tables', async () => {
            if (!user) return socket.emit('my_tables', []);
            const out = [];

            // Mesas de TORNEO (todas las que tenga)
            for (const f of mtt.findTablesByUser(user.id)) {
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
            try {
                const practice = getTable();
                const pSeat = practice?.seats.find(p => p !== null && p.userId === user.id);
                if (pSeat) {
                    out.push({
                        tableId: PRACTICE_TABLE_ID,
                        kind: 'practice',
                        title: 'Sala de Práctica',
                        chips: pSeat.chips,
                        smallBlind: practice.smallBlind,
                        bigBlind: practice.bigBlind,
                        phase: practice.phase,
                        myTurn: practice.currentTurn === pSeat.socketId,
                    });
                }
            } catch (e) { /* mesa no inicializada */ }

            socket.emit('my_tables', out);
        });

        socket.on('playerAction', (data) => {
            // ?? MTT: enrutar la acción a la mesa correcta (torneo o práctica)
            const resolved = resolveTableForSocket(socket, user);
            const table = resolved?.table || getTable();
            if (!table) return;

            // ?? Salvaguarda: Si el jugador tiene 0 fichas (espectador), ignorar acciones
            const player = table.seats.find(
                p => p !== null && p.socketId === socket.id
            );
            if (player && player.chips === 0) {
                return socket.emit('errorMsg', 'No tienes fichas para actuar. Estas en modo espectador.');
            }

            const action = typeof data === 'string' ? data : data?.action;
            const amount = typeof data === 'object' ? (data?.amount || 0) : 0;
            if (!action) return;

            const res = table.action(socket.id, action, amount);
            if (!res.ok) socket.emit('errorMsg', res.error);
        });

        // ?? FIX: usar addChips del motor para que gestione el inicio automatico de mano
        // (solo aplica a la mesa de PRÁCTICA; en torneo no hay recargas)
        socket.on('rebuy_practice', () => {
            const resolved = resolveTableForSocket(socket, user);
            if (resolved?.kind === 'tournament') {
                return socket.emit('errorMsg', 'En un torneo no se puede recargar fichas.');
            }
            const practiceTable = getTable();
            if (!practiceTable) return;

            const player = practiceTable.seats.find(
                p => p !== null && p.socketId === socket.id
            );
            if (!player) {
                return socket.emit('errorMsg', 'No estas en la mesa para recargar.');
            }

            const result = practiceTable.addChips(player.userId, 400);
            if (!result.ok) {
                return socket.emit('errorMsg', result.error);
            }
            console.log(`[Practica] ${player.username} recargo 400 fichas.`);
        });

        // ?? NUEVO EVENTO: Levantarse para ser espectador sin salir de la sala
        socket.on('standUp', async () => {
            const resolved = resolveTableForSocket(socket, user);
            const table = resolved?.table;
            if (!table) return;
            cancelDisconnectTimeout(socket.id);

            // Buscamos al jugador ANTES de llamar a leave()
            const player = table.seats.find(p => p !== null && p.socketId === socket.id);
            if (!player) return; // Si no esta sentado, no hace nada

            const token = getSocketToken(socket);
            // Lo quitamos de la mesa (true = ignorar regla de 5 manos)
            const result = table.leave(socket.id, true, token);

            if (!result.ok) {
                socket.emit('errorMsg', result.error);
                return;
            }

            // Limpiamos la DB con la mesa correcta
            const resolvedKind = resolved?.kind || 'practice';
            await removeActiveTable(player.userId, resolvedKind === 'tournament' ? table.tableId : PRACTICE_TABLE_ID, player.socketId);

            // ?? IMPORTANTE: NO emitimos leaveSuccess. El jugador se queda en la sala.
            console.log(`[Mesa] ${player.username} se levanto para ver de espectador.`);
        });

        // ?? FIX: pasar authToken a leave() para el cash-out autenticado,
        // manejar errores del motor, y borrar de la DB solo si tuvo exito.
        socket.on('leaveTable', async () => {
            const resolved = resolveTableForSocket(socket, user);
            const table = resolved?.table || getTable();
            if (!table) return;
            cancelDisconnectTimeout(socket.id);

            // Buscamos al jugador ANTES de llamar a leave()
            const player = table.seats.find(p => p !== null && p.socketId === socket.id);

            const token = getSocketToken(socket);
            const result = table.leave(socket.id, false, token);

            if (!result.ok) {
                socket.emit('errorMsg', result.error);
                return;
            }

            // Solo borrar de la DB si el motor confirmo la salida (con la mesa correcta)
            if (player) {
                const resolvedKind = resolved?.kind || 'practice';
                await removeActiveTable(player.userId, resolvedKind === 'tournament' ? table.tableId : PRACTICE_TABLE_ID, player.socketId);
            }

            // ?? Emitir leaveSuccess para que el frontend vuelva al lobby
            socket.emit('leaveSuccess');
        });

        // ?? FIX: mismo tratamiento para la salida de practica
        socket.on('leave_practice_table', async () => {
            const resolved = resolveTableForSocket(socket, user);
            const table = resolved?.table || getTable();
            if (!table) return;
            cancelDisconnectTimeout(socket.id);

            // Buscamos al jugador ANTES de llamar a leave()
            const player = table.seats.find(p => p !== null && p.socketId === socket.id);

            const token = getSocketToken(socket);
            const result = table.leave(socket.id, true, token);

            if (!result.ok) {
                socket.emit('errorMsg', result.error);
                return;
            }

            // Solo borrar de la DB si el motor confirmo la salida (con la mesa correcta)
            if (player) {
                const resolvedKind = resolved?.kind || 'practice';
                await removeActiveTable(player.userId, resolvedKind === 'tournament' ? table.tableId : PRACTICE_TABLE_ID, player.socketId);
            }

            // ?? Emitir leaveSuccess para que el frontend vuelva al lobby
            socket.emit('leaveSuccess');
        });

        // ?? MTT NUEVO: salir del torneo = abandonar (las fichas se pierden, sin cash-out)
        socket.on('leave_tournament_table', async () => {
            const found = mtt.findTableBySocket(socket.id) || (user ? mtt.findTableByUser(user.id) : null);
            if (!found) return socket.emit('leaveSuccess');
            const { table, seat: player } = found;
            cancelDisconnectTimeout(socket.id);

            const token = getSocketToken(socket);
            const result = table.leave(socket.id, true, token); // abandono forzado
            if (!result.ok) {
                socket.emit('errorMsg', result.error);
                return;
            }
            socket.emit('leaveSuccess');
            console.log(`[MTT] ${player?.username || user?.username} abandono el torneo.`);
        });

        socket.on('disconnect', async () => {
            console.log('[Sockets] desconectado:', socket.id);
            cancelDisconnectTimeout(socket.id);

            // ?? MTT: buscar primero en mesas de torneo, luego en práctica
            const tFound = mtt.findTableBySocket(socket.id);
            const practiceTable = tFound ? null : getTable();
            const player = tFound
                ? tFound.table.seats.find(p => p !== null && p.socketId === socket.id)
                : practiceTable?.seats.find(p => p !== null && p.socketId === socket.id);

            if (player) {
                // ?? FIX RECONEXIÓN: NO borrar la fila de la DB al desconectar.
                // La fila queda como "sesión activa" para poder retomar la partida
                // automáticamente al volver al lobby / recargar la página.
                const room = tFound ? tFound.table.tableId : PRACTICE_TABLE_ID;
                socket.to(room).emit('player_disconnected', {
                    userId: player.userId,
                    username: player.username,
                    graceMs: GRACE_PERIOD_MS,
                });
            }

            disconnectTimeouts[socket.id] = setTimeout(() => {
                console.log('[Sockets] Tiempo de gracia agotado:', socket.id);
                if (tFound) {
                    // ?? TORNEO: NUNCA se elimina la silla por desconexión.
                    // El jugador conserva sus fichas y puede reconectar cuando quiera;
                    // si le llega el turno, el temporizador le hace fold/check automático.
                    console.log(`[MTT] ${player?.username || '?'} desconectado: silla conservada en ${tFound.table.tableId}`);
                } else if (practiceTable) {
                    // Práctica: liberar la silla tras la gracia y limpiar la DB
                    practiceTable.leave(socket.id, true, null);
                    if (player) removeActiveTable(player.userId, PRACTICE_TABLE_ID, player.socketId);
                }
                delete disconnectTimeouts[socket.id];
            }, GRACE_PERIOD_MS);
        });
    });
};