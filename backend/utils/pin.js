// backend/utils/pin.js
// ============================================================
// PIN de pago con hash bcrypt.
// - Los PIN nuevos se guardan SIEMPRE hasheados.
// - Los PIN legacy (texto plano de la BD vieja) se verifican por
//   comparación directa y se MIGRAN a hash automáticamente en el
//   primer login/uso correcto (migración progresiva sin romper a
//   los usuarios actuales).
// ============================================================
const bcrypt = require('bcryptjs');

function isBcryptHash(value) {
    return typeof value === 'string' && /^\$2[aby]\$/.test(value);
}

async function hashPin(pin) {
    const salt = await bcrypt.genSalt(10);
    return bcrypt.hash(String(pin), salt);
}

/**
 * Verifica el PIN y devuelve si era legacy (texto plano).
 * { ok, wasLegacy }
 */
async function verifyPin(pin, stored) {
    if (!pin || !stored) return { ok: false, wasLegacy: false };
    if (isBcryptHash(stored)) {
        const ok = await bcrypt.compare(String(pin), stored);
        return { ok, wasLegacy: false };
    }
    // Legacy: comparación directa
    return { ok: String(pin) === String(stored), wasLegacy: true };
}

module.exports = { hashPin, verifyPin, isBcryptHash };
