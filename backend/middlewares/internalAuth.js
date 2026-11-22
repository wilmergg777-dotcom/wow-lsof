// backend/middlewares/internalAuth.js
// ============================================================
// Protección de endpoints INTERNOS de dinero:
//   - /api/poker/internal/process-rake   (llamado por el motor de poker)
//   - /api/poker/internal/cash-out       (llamado por el motor de poker)
// El motor (server.js y pokerServer.js) envía el header
//   X-Internal-Token: <INTERNAL_API_TOKEN>
// Si INTERNAL_API_TOKEN no está definido en el .env se usa un valor
// por defecto (con aviso en consola) para no romper despliegues,
// pero SE RECOMIENDA definirlo en producción.
// ============================================================
const FALLBACK_TOKEN = 'royalbet-internal-default';
let warned = false;

function getInternalToken() {
    const t = process.env.INTERNAL_API_TOKEN;
    if (!t && !warned) {
        warned = true;
        console.warn('⚠️  INTERNAL_API_TOKEN no definido: los endpoints internos usan el token por defecto. Define INTERNAL_API_TOKEN en tu .env de producción.');
    }
    return t || FALLBACK_TOKEN;
}

function requireInternal(req, res, next) {
    const provided = req.get('x-internal-token') || '';
    if (provided && provided === getInternalToken()) return next();
    return res.status(403).json({ error: 'Token interno inválido' });
}

module.exports = { requireInternal, getInternalToken };
