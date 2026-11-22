// backend/middlewares/auth.js
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { JWT_SECRET } = require('../config');
const pool = require('../db');

const TOKEN_TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7 días (igual que antes)

function hashToken(token) {
    return crypto.createHash('sha256').update(token).digest('hex');
}

// Registra/reemplaza la sesión activa del usuario en la BD
async function registerSession(userId, token) {
    const tokenHash = hashToken(token);
    const expiresAt = new Date(Date.now() + TOKEN_TTL_MS);
    await pool.query(
        `INSERT INTO active_sessions (user_id, token_hash, expires_at)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE
            token_hash = VALUES(token_hash),
            expires_at = VALUES(expires_at),
            created_at = CURRENT_TIMESTAMP`,
        [userId, tokenHash, expiresAt]
    );
}

// Elimina la sesión activa (para logout o reset de password)
async function invalidateSession(userId) {
    await pool.query('DELETE FROM active_sessions WHERE user_id = ?', [userId]);
}

async function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    if (!authHeader) return res.status(401).json({ error: 'Token requerido' });
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const tokenHash = hashToken(token);

        const [rows] = await pool.query(
            'SELECT token_hash FROM active_sessions WHERE user_id = ? AND expires_at > NOW()',
            [decoded.id]
        );

        // Si existe una sesión registrada y NO coincide con este token → kickear
        if (rows.length === 0 || rows[0].token_hash !== tokenHash) {
			return res.status(401).json({
				error: 'SESSION_EXPIRED',
				message: 'Sesion expirada. Vuelve a iniciar sesion.'
			});
		}

        req.user = decoded;
        next();
    } catch (error) {
        res.status(401).json({ error: 'Token invalido' });
    }
}

function requireAdmin(req, res, next) {
    if (!req.user || !['admin', 'superadmin'].includes(req.user.role)) {
        return res.status(403).json({ error: 'No autorizado' });
    }
    next();
}

function requireSuperAdmin(req, res, next) {
    if (!req.user || req.user.role !== 'superadmin') {
        return res.status(403).json({ error: 'Solo superadmin' });
    }
    next();
}

// al final
module.exports = { verifyToken, requireAdmin, requireSuperAdmin, registerSession, invalidateSession };