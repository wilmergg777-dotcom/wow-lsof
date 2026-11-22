const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config');

const activeSessions = {};

function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    if (!authHeader) return res.status(401).json({ error: 'Token requerido' });
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, JWT_SECRET);

        if (activeSessions[decoded.id] && activeSessions[decoded.id] !== token) {
            return res.status(401).json({ error: 'SESSION_EXPIRED', message: 'Has iniciado sesion en otro dispositivo.' });
        }

        req.user = decoded;
        next();
    } catch (error) {
        res.status(401).json({ error: 'Token invalido' });
    }
}

function requireAdmin(req, res, next) {
    if (!req.user || req.user.role !== 'superadmin') {
        return res.status(403).json({ error: 'No autorizado' });
    }
    next();
}

module.exports = { verifyToken, requireAdmin, activeSessions };