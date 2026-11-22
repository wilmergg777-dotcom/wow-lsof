const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');
// ===========================================================
// VALIDADOR
// ===========================================================
const {
  validateProfileUpdate, validatePhoneUpdate, validatePasswordChange,
  validatePayPin, validatePayPinToggle, validateBankData,
  validateIdParam, validateUniqueIdParam,
} = require('../middlewares/validators');

router.get('/user/profile', verifyToken, async (req, res) => {
    try {
        // ?? Agregamos unique_id y las fechas de seguridad a la consulta
        const [users] = await pool.query(
            'SELECT id, username, email, phone, avatar_url, discord_id, unique_id, pin_changed_at, email_changed_at FROM users WHERE id = ?', 
            [req.user.id]
        );
        if (users.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
        res.json(users[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error al cargar perfil' });
    }
});

router.put('/user/profile', verifyToken, validateProfileUpdate, async (req, res) => {
    const { username, email, phone, avatar_url } = req.body;
    try {
        // 1. Obtener el correo actual para saber si cambio
        const [currentUser] = await pool.query('SELECT email FROM users WHERE id = ?', [req.user.id]);
        const emailChanged = email && email !== currentUser[0]?.email;

        // 2. Validar que el nombre/correo no esten en uso
        const [existing] = await pool.query(
            'SELECT id FROM users WHERE (username = ? OR email = ?) AND id != ?',
            [username, email, req.user.id]
        );
        if (existing.length > 0) return res.status(400).json({ error: 'El nombre o correo ya esta en uso' });

        // 3. Actualizar el perfil
        await pool.query(
            'UPDATE users SET username = ?, email = ?, phone = ?, avatar_url = ? WHERE id = ?',
            [username, email || null, phone || null, avatar_url || null, req.user.id]
        );

        // ?? 4. Si el correo cambio, guardar la fecha para bloquear transferencias 24h
        if (emailChanged) {
            await pool.query('UPDATE users SET email_changed_at = NOW() WHERE id = ?', [req.user.id]);
        }

        res.json({ message: 'Perfil actualizado' });
    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar' });
    }
});

// ?? NUEVA RUTA PARA ACTUALIZAR EL TELeFONO
router.put('/user/phone', verifyToken, validatePhoneUpdate, async (req, res) => {
    const { phone } = req.body;
    if (!phone) return res.status(400).json({ error: 'El numero de telefono es obligatorio' });

    try {
        await pool.query('UPDATE users SET phone = ? WHERE id = ?', [phone, req.user.id]);
        res.json({ message: 'Telefono actualizado correctamente', phone });
    } catch (error) {
        console.error('Error al actualizar telefono:', error);
        res.status(500).json({ error: 'Error al guardar el telefono' });
    }
});

router.get('/user/referrals', verifyToken, async (req, res) => {
    try {
        const [referredUsers] = await pool.query(
            'SELECT id, username, created_at FROM users WHERE referred_by = ? ORDER BY created_at DESC',
            [req.user.id]
        );
        res.json({ total_referrals: referredUsers.length, referrals: referredUsers });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener referidos' });
    }
});

// ==========================================
// ?? NUEVA RUTA: CENTRO DE ACTIVIDADES
// ==========================================
router.get('/user/activity', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;

        // 1. Obtener las mesas activas (agrupadas para evitar duplicados visuales)
        const [activeTables] = await pool.query(
            `SELECT table_id, server_type, MIN(joined_at) as joined_at 
             FROM active_player_tables 
             WHERE user_id = ? 
             GROUP BY table_id, server_type`,
            [userId]
        );

        let history = [];
        try {
            const [rows] = await pool.query(
                `SELECT id, table_id, amount_won, played_at 
                 FROM game_history 
                 WHERE user_id = ? 
                 ORDER BY played_at DESC LIMIT 50`,
                [userId]
            );
            history = rows;
        } catch (e) {
            console.log('Tabla game_history no encontrada, devolviendo array vacio.');
        }

        res.json({ 
            activeTables: activeTables || [], 
            history: history || [] 
        });
    } catch (error) {
        console.error('Error al obtener actividad:', error);
        res.status(500).json({ error: 'Error al cargar el centro de actividades' });
    }
});

// ==========================================
// ?? RUTAS: GANANCIAS DE REFERIDOS (RAKE 25%)
// ==========================================

router.get('/user/referral-earnings', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const [pending] = await pool.query(
            "SELECT SUM(amount) as total FROM referral_earnings WHERE referrer_id = ? AND status = 'pending'",
            [userId]
        );
        const total_pending = Number(pending[0].total || 0);

        const [details] = await pool.query(
            `SELECT re.amount, u.username 
             FROM referral_earnings re 
             JOIN users u ON re.referred_id = u.id 
             WHERE re.referrer_id = ? AND re.status = 'pending'
             ORDER BY re.created_at DESC`,
            [userId]
        );

        const [lastClaim] = await pool.query(
            "SELECT created_at FROM referral_claims WHERE user_id = ? ORDER BY created_at DESC LIMIT 1",
            [userId]
        );

        let next_claim_time = null;
        if (lastClaim.length > 0) {
            const lastDate = new Date(lastClaim[0].created_at);
            const nextDate = new Date(lastDate.getTime() + 24 * 60 * 60 * 1000);
            if (nextDate > new Date()) {
                next_claim_time = nextDate.toISOString();
            }
        }

        res.json({
            total_pending,
            details,
            next_claim_time
        });
    } catch (error) {
        console.error('Error al obtener referral-earnings:', error);
        res.status(500).json({ error: 'Error al cargar ganancias' });
    }
});

router.post('/user/referral-earnings/claim', verifyToken, async (req, res) => {
    const userId = req.user.id;
    const connection = await pool.getConnection();
    
    try {
        await connection.beginTransaction();

        const [lastClaim] = await connection.query(
            "SELECT created_at FROM referral_claims WHERE user_id = ? ORDER BY created_at DESC LIMIT 1 FOR UPDATE",
            [userId]
        );

        if (lastClaim.length > 0) {
            const lastDate = new Date(lastClaim[0].created_at);
            const diffHours = (new Date() - lastDate) / (1000 * 60 * 60);
            
            if (diffHours < 24) {
                throw new Error('Debes esperar 24 horas entre cada reclamo.');
            }
        }

        const [pending] = await connection.query(
            "SELECT SUM(amount) as total FROM referral_earnings WHERE referrer_id = ? AND status = 'pending' FOR UPDATE",
            [userId]
        );
        const total = Number(pending[0].total || 0);

        if (total < 5) {
            throw new Error('El minimo para reclamar es de 5 NTX');
        }

        await connection.query(
            "UPDATE referral_earnings SET status = 'claimed' WHERE referrer_id = ? AND status = 'pending'",
            [userId]
        );

        await connection.query(
            "UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?",
            [total, userId]
        );

        await connection.query(
            "INSERT INTO referral_claims (user_id, amount) VALUES (?, ?)",
            [userId, total]
        );

        await connection.commit();
        res.json({ message: 'Reclamo exitoso', amount: total });

    } catch (error) {
        await connection.rollback();
        console.error('Error al reclamar ganancias:', error);
        res.status(400).json({ error: error.message || 'Error al procesar el reclamo' });
    } finally {
        connection.release();
    }
});

router.put('/user/password', verifyToken, validatePasswordChange, async (req, res) => {
    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) return res.status(400).json({ error: 'Ambas contrasenas son obligatorias' });

    try {
        const [users] = await pool.query('SELECT password_hash FROM users WHERE id = ?', [req.user.id]);
        const validPassword = await bcrypt.compare(oldPassword, users[0].password_hash);
        if (!validPassword) return res.status(401).json({ error: 'La contrasena actual es incorrecta' });

        const salt = await bcrypt.genSalt(10);
        const newHash = await bcrypt.hash(newPassword, salt);
        await pool.query('UPDATE users SET password_hash = ? WHERE id = ?', [newHash, req.user.id]);

        res.json({ message: 'Contrasena actualizada correctamente' });
    } catch (error) {
        res.status(500).json({ error: 'Error al cambiar contrasena' });
    }
});

// ?? ACTUALIZADO: Guarda la fecha en que se cambio el PIN
router.put('/user/paypin', verifyToken, validatePayPin, async (req, res) => {
    const { pin } = req.body;
    if (!pin || pin.length < 4) return res.status(400).json({ error: 'El PIN debe tener al menos 4 digitos' });
    try {
        await pool.query(
            'UPDATE users SET pay_pin = ?, pin_changed_at = NOW() WHERE id = ?', 
            [pin, req.user.id]
        );
        res.json({ message: 'PIN configurado correctamente', has_pin: true });
    } catch (error) {
        res.status(500).json({ error: 'Error al guardar PIN' });
    }
});

router.put('/user/paypin/toggle', verifyToken, validatePayPinToggle, async (req, res) => {
    const { enabled } = req.body;
    try {
        await pool.query('UPDATE users SET pay_pin_enabled = ? WHERE id = ?', [enabled, req.user.id]);
        res.json({ message: 'Estado del PIN actualizado', pin_enabled: enabled });
    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar PIN' });
    }
});

router.get('/user/bank-data', verifyToken, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM bank_accounts WHERE user_id = ?', [req.user.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'No hay datos bancarios' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener datos' });
    }
});

router.post('/user/bank-data', verifyToken, validateBankData, async (req, res) => {
    const { card_number, phone, holder_name, bank_name } = req.body;
    if (!card_number || !phone || !holder_name || !bank_name) {
        return res.status(400).json({ error: 'Todos los campos son obligatorios' });
    }
    try {
        await pool.query(
            `INSERT INTO bank_accounts (user_id, card_number, phone, holder_name, bank_name)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE card_number=?, phone=?, holder_name=?, bank_name=?`,
            [req.user.id, card_number, phone, holder_name, bank_name, card_number, phone, holder_name, bank_name]
        );
        res.json({ message: 'Datos bancarios guardados correctamente' });
    } catch (error) {
        res.status(500).json({ error: 'Error al guardar datos' });
    }
});

// ==========================================
// ?? NOTIFICACIONES INTERNAS (BUZoN)
// ==========================================

router.get('/user/notifications', verifyToken, async (req, res) => {
    try {
        const [rows] = await pool.query(
            `SELECT id, title, message, type, is_read, metadata, created_at 
             FROM user_notifications 
             WHERE user_id = ? 
             ORDER BY created_at DESC 
             LIMIT 50`,
            [req.user.id]
        );
        res.json(rows);
    } catch (error) {
        console.error('[notifications] Error listando:', error);
        res.status(500).json({ error: 'Error al obtener notificaciones' });
    }
});

router.get('/user/notifications/unread-count', verifyToken, async (req, res) => {
    try {
        const [rows] = await pool.query(
            `SELECT COUNT(*) AS count FROM user_notifications WHERE user_id = ? AND is_read = 0`,
            [req.user.id]
        );
        res.json({ count: rows[0].count });
    } catch (error) {
        console.error('[notifications] Error contando:', error);
        res.status(500).json({ error: 'Error al contar notificaciones' });
    }
});

router.post('/user/notifications/:id/read', verifyToken, validateIdParam, async (req, res) => {
    try {
        const [result] = await pool.query(
            `UPDATE user_notifications SET is_read = 1 WHERE id = ? AND user_id = ?`,
            [req.params.id, req.user.id]
        );
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Notificacion no encontrada' });
        res.json({ message: 'Notificacion marcada como leida' });
    } catch (error) {
        console.error('[notifications] Error marcando:', error);
        res.status(500).json({ error: 'Error al marcar notificacion' });
    }
});

router.post('/user/notifications/read-all', verifyToken, async (req, res) => {
    try {
        await pool.query(
            `UPDATE user_notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0`,
            [req.user.id]
        );
        res.json({ message: 'Todas las notificaciones marcadas como leidas' });
    } catch (error) {
        console.error('[notifications] Error marcando todas:', error);
        res.status(500).json({ error: 'Error al marcar notificaciones' });
    }
});

router.delete('/user/notifications/:id', verifyToken, validateIdParam, async (req, res) => {
    try {
        const [result] = await pool.query(
            `DELETE FROM user_notifications WHERE id = ? AND user_id = ?`,
            [req.params.id, req.user.id]
        );
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Notificacion no encontrada' });
        res.json({ message: 'Notificacion eliminada' });
    } catch (error) {
        console.error('[notifications] Error eliminando:', error);
        res.status(500).json({ error: 'Error al eliminar notificacion' });
    }
});

// ==========================================
// ?? RUTA PARA BUSCAR JUGADOR POR ID (Para transferencias)
// ==========================================
router.get('/user/find/:uniqueId', verifyToken, validateUniqueIdParam, async (req, res) => {
    try {
        const cleanId = String(req.params.uniqueId || '').replace('@', '').trim();
        if (!cleanId) return res.status(400).json({ error: 'Debes ingresar un ID valido.' });
        
        const [users] = await pool.query(
            'SELECT id, username, avatar_url, unique_id FROM users WHERE unique_id = ?', 
            [cleanId]
        );
        
        if (users.length === 0) return res.status(404).json({ error: 'Jugador no encontrado con ese ID.' });
        if (users[0].id === req.user.id) return res.status(400).json({ error: 'No puedes transferirte dinero a ti mismo.' });
        
        res.json(users[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error interno del servidor.' });
    }
});

module.exports = router;