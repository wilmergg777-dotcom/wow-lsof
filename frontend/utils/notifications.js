const pool = require('../db');

async function crearNotificacion(userId, title, message, type = 'info', metadata = null) {
    try {
        await pool.query(
            `INSERT INTO user_notifications (user_id, title, message, type, metadata) 
             VALUES (?, ?, ?, ?, ?)`,
            [userId, title, message, type, metadata ? JSON.stringify(metadata) : null]
        );
        return true;
    } catch (error) {
        console.error('[notifications] Error creando notificación:', error);
        return false;
    }
}

module.exports = { crearNotificacion };