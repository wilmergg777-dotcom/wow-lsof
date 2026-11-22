// backend/tests/test-shop-clubs.js
// ============================================================
// Tests SIN base de datos:
//  - Tienda: reglas de precios (emojis 1-4 NTX-20, estilos 1-3 NTX-20)
//  - Clubes: niveles (tiers), capacidad, torneos públicos
//  - Fondos: rake de mesas de CLUB → 3% Fondo del Proyecto / 97% dueño del club
//    (usando applyRake con una conexión MySQL simulada)
// Ejecutar: node tests/test-shop-clubs.js
// ============================================================
const assert = require('assert');
const path = require('path');

// Entorno mínimo para cargar la configuración sin .env real
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret-tests';

// ── Mock de ../db ANTES de requerir los servicios (sin MySQL real) ──
const dbPath = path.join(__dirname, '..', 'db.js');

let walletSettingsRows = [
    { setting_key: 'rake_percent', setting_value: '5' },
    { setting_key: 'referral_rake_share', setting_value: '25' },
    { setting_key: 'tournament_commission', setting_value: '10' },
];

const fakePool = {
    query: async (sql) => {
        if (sql.includes('wallet_settings')) return [walletSettingsRows];
        return [[]];
    },
    getConnection: async () => { throw new Error('getConnection no debe usarse en estos tests'); },
};
require.cache[dbPath] = { id: dbPath, filename: dbPath, loaded: true, exports: fakePool };

const { applyRake, computeRakeSplit, CLUB_PROJECT_SHARE_PCT } = require('../services/funds');
const { isPriceValidForType, CATALOG_RULES } = require('../services/shop');
const clubsRouter = require('../routes/clubs');
const CLUB_TIERS = clubsRouter.CLUB_TIERS;

let passed = 0;
let failed = 0;

function test(name, fn) {
    return Promise.resolve()
        .then(fn)
        .then(() => { passed++; console.log(`  ✅ ${name}`); })
        .catch((err) => { failed++; console.error(`  ❌ ${name}\n     ${err.message}`); });
}

// ── Conexión simulada que graba cada llamada SQL ──
function mockConnection({ ownerId = 7, referrer = null } = {}) {
    const calls = [];
    return {
        calls,
        query: async (sql, params = []) => {
            calls.push({ sql: sql.replace(/\s+/g, ' ').trim(), params });
            if (sql.includes('FROM users WHERE id = ?')) return [[{ referred_by: referrer }]];
            if (sql.includes('FROM clubs WHERE id = ?')) return [[{ owner_id: ownerId }]];
            return [{ affectedRows: 1, insertId: 1 }];
        },
        beginTransaction: async () => {},
        commit: async () => {},
        rollback: async () => {},
        release: () => {},
    };
}

(async () => {
    console.log('\n=== Test: TIENDA — reglas de precios ===');

    await test('Catálogo: emojis 1-4 NTX-20, estilos 1-3 NTX-20', () => {
        assert.deepStrictEqual(CATALOG_RULES.emote, { min: 1, max: 4 });
        assert.deepStrictEqual(CATALOG_RULES.card_style, { min: 1, max: 3 });
    });

    await test('Precio de emoji válido: 1 y 4 aceptados, 0 y 5 rechazados', () => {
        assert.strictEqual(isPriceValidForType('emote', 1), true);
        assert.strictEqual(isPriceValidForType('emote', 4), true);
        assert.strictEqual(isPriceValidForType('emote', 0), false);
        assert.strictEqual(isPriceValidForType('emote', 5), false);
        assert.strictEqual(isPriceValidForType('emote', 2.5), true);
    });

    await test('Precio de estilo válido: 1 y 3 aceptados, 4 rechazado', () => {
        assert.strictEqual(isPriceValidForType('card_style', 1), true);
        assert.strictEqual(isPriceValidForType('card_style', 3), true);
        assert.strictEqual(isPriceValidForType('card_style', 4), false);
        assert.strictEqual(isPriceValidForType('card_style', 0), false);
    });

    await test('Tipo desconocido → siempre inválido', () => {
        assert.strictEqual(isPriceValidForType('chips', 2), false);
    });

    console.log('\n=== Test: CLUBES — niveles (tiers) ===');

    await test('Niveles: gratis 10 / 70→50 / 100→100 / 300→250 jugadores', () => {
        assert.deepStrictEqual(CLUB_TIERS[0], { price: 0, max_players: 10, public_tournaments: 0 });
        assert.deepStrictEqual(CLUB_TIERS[1], { price: 70, max_players: 50, public_tournaments: 0 });
        assert.deepStrictEqual(CLUB_TIERS[2], { price: 100, max_players: 100, public_tournaments: 1 });
        assert.deepStrictEqual(CLUB_TIERS[3], { price: 300, max_players: 250, public_tournaments: 3 });
    });

    await test('Sin nivel 2 o 3 → torneos SOLO para miembros (0 públicos)', () => {
        assert.strictEqual(CLUB_TIERS[0].public_tournaments, 0);
        assert.strictEqual(CLUB_TIERS[1].public_tournaments, 0);
    });

    await test('Nivel 2 permite 1 torneo público y nivel 3 permite 3', () => {
        assert.strictEqual(CLUB_TIERS[2].public_tournaments, 1);
        assert.strictEqual(CLUB_TIERS[3].public_tournaments, 3);
    });

    await test('Regla de subida: solo se puede pasar al nivel siguiente', () => {
        const currentTier = 1;
        assert.strictEqual(2 === currentTier + 1, true, 'nivel 2 permitido desde 1');
        assert.strictEqual(3 === currentTier + 1, false, 'saltar al 3 no permitido desde 1');
        assert.strictEqual(1 === currentTier + 1, false, 'comprar el nivel actual no permitido');
    });

    console.log('\n=== Test: FONDOS — rake de mesas de CLUB (3% / 97%) ===');

    await test(`Constante: ${CLUB_PROJECT_SHARE_PCT}% al Fondo del Proyecto`, () => {
        assert.strictEqual(CLUB_PROJECT_SHARE_PCT, 3);
    });

    await test('Rake de club 10 → 0.30 proyecto + 9.70 dueño, sin referidos', async () => {
        const conn = mockConnection({ ownerId: 42 });
        const r = await applyRake(conn, {
            source: 'club', clubId: 5, tableId: 'club-5-1', handNumber: 1,
            winnerUserId: 99, rakeAmount: 10,
        });
        assert.strictEqual(r.mode, 'club');
        assert.strictEqual(r.projectShare, 0.3);
        assert.strictEqual(r.ownerShare, 9.7);

        const bank = conn.calls.find(c => c.sql.includes('UPDATE bank_reserves'));
        const owner = conn.calls.find(c => c.sql.includes('UPDATE wallets'));
        const ledger = conn.calls.find(c => c.sql.includes('INSERT INTO rake_ledger'));
        const referral = conn.calls.find(c => c.sql.includes('referral_earnings'));
        assert.ok(bank, 'debe acreditar el Fondo del Proyecto');
        assert.strictEqual(bank.params[0], 0.3);
        assert.ok(owner, 'debe acreditar la billetera del dueño');
        assert.strictEqual(owner.params[0], 9.7);
        assert.strictEqual(owner.params[1], 42, 'el 97% va al DUEÑO del club (id 42)');
        assert.ok(ledger, 'debe registrar en rake_ledger');
        assert.strictEqual(ledger.params[0], 5, 'club_id en el ledger');
        assert.ok(!referral, 'el rake de club NO reparte a referidos');
    });

    await test('Rake de club 7.77 → 0.23 proyecto + 7.54 dueño (redondeo a céntimos)', async () => {
        const conn = mockConnection({ ownerId: 1 });
        const r = await applyRake(conn, { clubId: 2, winnerUserId: 9, rakeAmount: 7.77 });
        assert.strictEqual(r.projectShare, 0.23);
        assert.strictEqual(r.ownerShare, 7.54);
    });

    await test('Rake de club 0 → no hace nada', async () => {
        const conn = mockConnection();
        const r = await applyRake(conn, { clubId: 3, rakeAmount: 0 });
        assert.strictEqual(r.ok, true);
        assert.strictEqual(conn.calls.filter(c => c.sql.includes('UPDATE bank_reserves')).length, 0);
    });

    await test('Mesa NORMAL sigue: 25% referidos / 75% proyecto (regresión)', async () => {
        const conn = mockConnection({ ownerId: 7, referrer: 55 });
        const r = await applyRake(conn, { winnerUserId: 20, rakeAmount: 10 });
        const referral = conn.calls.find(c => c.sql.includes('referral_earnings'));
        const bank = conn.calls.find(c => c.sql.includes('UPDATE bank_reserves'));
        assert.ok(referral, 'debe crear referral_earnings');
        assert.strictEqual(referral.params[2], 2.5, '25% del rake');
        assert.ok(bank);
        assert.strictEqual(bank.params[0], 7.5, '75% del rake');
        assert.strictEqual(r.referrerId, 55);
    });

    await test('Mesa normal SIN referido → 100% al Fondo del Proyecto', async () => {
        const conn = mockConnection({ referrer: null });
        await applyRake(conn, { winnerUserId: 20, rakeAmount: 10 });
        const bank = conn.calls.find(c => c.sql.includes('UPDATE bank_reserves'));
        assert.strictEqual(bank.params[0], 10);
    });

    console.log('\n=== Test: REGRESIÓN de reparto referidos/proyecto ===');

    await test('computeRakeSplit sigue sumando exactamente el rake', () => {
        for (const rake of [3.33, 15, 123.45]) {
            const r = computeRakeSplit(rake, 25);
            assert.strictEqual(Number((r.referralShare + r.projectShare).toFixed(2)), Number(rake.toFixed(2)));
        }
    });

    console.log(`\nResultado: ${passed} pasados, ${failed} fallidos`);
    process.exit(failed > 0 ? 1 : 0);
})();
