// backend/services/funds.js
// ============================================================
// 🔥 MOTOR DE FONDOS — RoyalBet
// Centraliza TODO el reparto de porcentajes del sistema:
//   Rake de mesas cash  ──►  X% al Sistema de Referidos (25%)
//                            resto al Fondo del Proyecto
//   Comisión de torneos ──►  mismo reparto (10% de la entrada)
// Los porcentajes se leen de wallet_settings (panel admin):
//   rake_percent            (default 5)
//   referral_rake_share     (default 25  → % del rake que va a referidos)
//   tournament_commission   (default 10  → % de la entrada que es comisión)
// Todo queda registrado en rake_ledger para poder AUDITAR el flujo.
// ============================================================
const pool = require('../db');

// ------------------------------------------------------------
// Config con caché (evita consultar la BD en cada mano)
// ------------------------------------------------------------
const CONFIG_TTL_MS = 60 * 1000;
let configCache = null;
let configLoadedAt = 0;

const CONFIG_DEFAULTS = {
    rake_percent: 5,
    referral_rake_share: 25,
    tournament_commission: 10,
};

async function getFundConfig(force = false) {
    const now = Date.now();
    if (!force && configCache && (now - configLoadedAt) < CONFIG_TTL_MS) {
        return configCache;
    }
    const [rows] = await pool.query(
        "SELECT setting_key, setting_value FROM wallet_settings WHERE setting_key IN ('rake_percent','referral_rake_share','tournament_commission')"
    );
    const cfg = { ...CONFIG_DEFAULTS };
    for (const r of rows) {
        const v = Number(r.setting_value);
        if (Number.isFinite(v) && v >= 0) cfg[r.setting_key] = v;
    }
    // Sanidad: el share de referidos no puede ser mayor al 100%
    if (cfg.referral_rake_share > 100) cfg.referral_rake_share = 100;
    configCache = cfg;
    configLoadedAt = now;
    return cfg;
}

// ------------------------------------------------------------
// Reparto puro (función testeable, sin BD)
// referralShare = rake * referral_rake_share / 100
// projectShare  = rake - referralShare
// ------------------------------------------------------------
function computeRakeSplit(rakeAmount, referralSharePct) {
    const rake = Math.max(0, Number(rakeAmount) || 0);
    const pct = Math.min(100, Math.max(0, Number(referralSharePct) || 0));
    const referralShare = Number(((rake * pct) / 100).toFixed(2));
    const projectShare = Number((rake - referralShare).toFixed(2));
    return { rake, referralShare, projectShare };
}

// ------------------------------------------------------------
// Reparto del rake de UNA mano / registro de torneo:
//  - Si el generador del rake tiene referido ──► referral_earnings (pending)
//  - Lo que va al proyecto + lo del referido sin referido ──► bank_reserves
//  - Todo se registra en rake_ledger
// DEBE llamarse dentro de una transacción ya abierta (connection).
// ------------------------------------------------------------
async function applyRake(connection, {
    source = 'cash',            // 'cash' | 'tournament'
    tableId = null,
    handNumber = null,
    winnerUserId = null,        // jugador que generó el rake
    rakeAmount = 0,
}) {
    const cfg = await getFundConfig();
    const rake = Math.round((Number(rakeAmount) || 0) * 100) / 100;
    if (rake <= 0) return { ok: true, referralShare: 0, projectShare: 0, referrerId: null };

    const { referralShare, projectShare } = computeRakeSplit(rake, cfg.referral_rake_share);

    // 1. ¿Tiene referido el jugador que generó el rake?
    let referrerId = null;
    if (winnerUserId) {
        const [users] = await connection.query(
            'SELECT referred_by FROM users WHERE id = ?',
            [winnerUserId]
        );
        referrerId = users[0]?.referred_by || null;
        if (referrerId === winnerUserId) referrerId = null; // nunca auto-referido
    }

    // 2. Parte de referidos → referral_earnings (pending) si hay referido;
    //    si no hay referido, esa parte se queda en el Fondo del Proyecto.
    let referralCredited = 0;
    if (referrerId && referralShare > 0) {
        await connection.query(
            "INSERT INTO referral_earnings (referrer_id, referred_id, amount, status) VALUES (?, ?, ?, 'pending')",
            [referrerId, winnerUserId, referralShare]
        );
        referralCredited = referralShare;
    }

    // 3. Fondo del Proyecto = projectShare + referralShare no reclamable
    const toProject = Number((projectShare + (referralShare - referralCredited)).toFixed(2));
    if (toProject > 0) {
        await connection.query(
            'UPDATE bank_reserves SET balance_ntx = balance_ntx + ? WHERE id = 1',
            [toProject]
        );
    }

    // 4. Ledger auditable
    await connection.query(
        `INSERT INTO rake_ledger (source, table_id, hand_number, winner_user_id, rake_amount,
            referral_share, project_share, referrer_id)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            source, tableId, handNumber, winnerUserId,
            rake, referralCredited, toProject, referrerId,
        ]
    );

    return { ok: true, rake, referralShare: referralCredited, projectShare: toProject, referrerId };
}

module.exports = {
    getFundConfig,
    computeRakeSplit,
    applyRake,
    CONFIG_DEFAULTS,
};
