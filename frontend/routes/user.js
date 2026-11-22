const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');

router.get('/user/profile', verifyToken, async (req, res) => {
    try {
        const [users] = await pool.query('SELECT id, username, email, phone, avatar_url, discord_id FROM users WHERE id = ?', [req.user.id]);
        if (users.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
        res.json(users[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error al cargar perfil' });
    }
});

router.put('/user/profile', verifyToken, async (req, res) => {
    const { username, email, phone, avatar_url } = req.body;
    try {
        const [existing] = await pool.query(
            'SELECT id FROM users WHERE (username = ? OR email = ?) AND id != ?',
            [username, email, req.user.id]
        );
        if (existing.length > 0) return res.status(400).json({ error: 'El nombre o correo ya esta en uso' });

        await pool.query(
            'UPDATE users SET username = ?, email = ?, phone = ?, avatar_url = ? WHERE id = ?',
            [username, email || null, phone || null, avatar_url || null, req.user.id]
        );
        res.json({ message: 'Perfil actualizado' });
    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar' });
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

router.put('/user/password', verifyToken, async (req, res) => {
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

router.put('/user/paypin', verifyToken, async (req, res) => {
    const { pin } = req.body;
    if (!pin || pin.length < 4) return res.status(400).json({ error: 'El PIN debe tener al menos 4 digitos' });
    try {
        await pool.query('UPDATE users SET pay_pin = ? WHERE id = ?', [pin, req.user.id]);
        res.json({ message: 'PIN configurado correctamente', has_pin: true });
    } catch (error) {
        res.status(500).json({ error: 'Error al guardar PIN' });
    }
});

router.put('/user/paypin/toggle', verifyToken, async (req, res) => {
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

router.post('/user/bank-data', verifyToken, async (req, res) => {
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
// 📬 NOTIFICACIONES INTERNAS (BUZÓN)
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

router.post('/user/notifications/:id/read', verifyToken, async (req, res) => {
    try {
        const [result] = await pool.query(
            `UPDATE user_notifications SET is_read = 1 WHERE id = ? AND user_id = ?`,
            [req.params.id, req.user.id]
        );
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Notificación no encontrada' });
        res.json({ message: 'Notificación marcada como leída' });
    } catch (error) {
        console.error('[notifications] Error marcando:', error);
        res.status(500).json({ error: 'Error al marcar notificación' });
    }
});

router.post('/user/notifications/read-all', verifyToken, async (req, res) => {
    try {
        await pool.query(
            `UPDATE user_notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0`,
            [req.user.id]
        );
        res.json({ message: 'Todas las notificaciones marcadas como leídas' });
    } catch (error) {
        console.error('[notifications] Error marcando todas:', error);
        res.status(500).json({ error: 'Error al marcar notificaciones' });
    }
});

router.delete('/user/notifications/:id', verifyToken, async (req, res) => {
    try {
        const [result] = await pool.query(
            `DELETE FROM user_notifications WHERE id = ? AND user_id = ?`,
            [req.params.id, req.user.id]
        );
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Notificación no encontrada' });
        res.json({ message: 'Notificación eliminada' });
    } catch (error) {
        console.error('[notifications] Error eliminando:', error);
        res.status(500).json({ error: 'Error al eliminar notificación' });
    }
});

module.exports = router;