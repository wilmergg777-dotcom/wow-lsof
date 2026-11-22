// backend/tests/test-funds.js
// ============================================================
// Test del motor de fondos (services/funds.js) — SIN base de datos:
// valida el reparto de porcentajes referidos/proyecto y la lógica
// de rake del motor (pokerGame.js) con casos concretos.
// Ejecutar: node tests/test-funds.js
// ============================================================
const assert = require('assert');
const { computeRakeSplit, CONFIG_DEFAULTS } = require('../services/funds');

let passed = 0;
let failed = 0;

function test(name, fn) {
    try {
        fn();
        passed++;
        console.log(`  ✅ ${name}`);
    } catch (err) {
        failed++;
        console.error(`  ❌ ${name}\n     ${err.message}`);
    }
}

console.log('\n=== Test: reparto de fondos (computeRakeSplit) ===');

test('Rake 100 con 25% → 25 referidos / 75 proyecto', () => {
    const r = computeRakeSplit(100, 25);
    assert.strictEqual(r.referralShare, 25);
    assert.strictEqual(r.projectShare, 75);
});

test('Rake 5 (bote 100, 5%) con 25% → 1.25 / 3.75', () => {
    const r = computeRakeSplit(5, 25);
    assert.strictEqual(r.referralShare, 1.25);
    assert.strictEqual(r.projectShare, 3.75);
});

test('El reparto SIEMPRE suma exactamente el rake', () => {
    for (const rake of [1, 3, 7.77, 13.33, 250, 999.99]) {
        const r = computeRakeSplit(rake, 25);
        assert.strictEqual(Number((r.referralShare + r.projectShare).toFixed(2)), Number(rake.toFixed(2)),
            `Fallo con rake=${rake}: ${r.referralShare}+${r.projectShare} != ${rake}`);
    }
});

test('Sin referido (share 0) → todo al proyecto', () => {
    const r = computeRakeSplit(100, 0);
    assert.strictEqual(r.referralShare, 0);
    assert.strictEqual(r.projectShare, 100);
});

test('100% a referidos → proyecto 0', () => {
    const r = computeRakeSplit(100, 100);
    assert.strictEqual(r.referralShare, 100);
    assert.strictEqual(r.projectShare, 0);
});

test('Valores negativos o inválidos → 0 en todo', () => {
    assert.deepStrictEqual(computeRakeSplit(-50, 25), { rake: 0, referralShare: 0, projectShare: 0 });
    assert.deepStrictEqual(computeRakeSplit('abc', 25), { rake: 0, referralShare: 0, projectShare: 0 });
    assert.deepStrictEqual(computeRakeSplit(0, 25), { rake: 0, referralShare: 0, projectShare: 0 });
});

test('Porcentaje > 100 se satura a 100', () => {
    const r = computeRakeSplit(100, 250);
    assert.strictEqual(r.referralShare, 100);
    assert.strictEqual(r.projectShare, 0);
});

test('Defaults de configuración correctos', () => {
    assert.strictEqual(CONFIG_DEFAULTS.rake_percent, 5);
    assert.strictEqual(CONFIG_DEFAULTS.referral_rake_share, 25);
    assert.strictEqual(CONFIG_DEFAULTS.tournament_commission, 10);
});

// ── Flujo de porcentajes completo (como llega a la BD) ──
console.log('\n=== Test: flujo completo de porcentajes ===');

test('Mesa cash: bote 1000 → fondo 37.5 + referido 12.5', () => {
    // Bote 1000, rake 5% = 50 NTX → 25% de 50 = 12.5 al referido, 37.5 al fondo
    const rake = Math.floor(1000 * 0.05);
    const r = computeRakeSplit(rake, 25);
    assert.strictEqual(rake, 50);
    assert.strictEqual(r.referralShare, 12.5);
    assert.strictEqual(r.projectShare, 37.5);
});

test('Torneo: entrada 30 → comisión 3 → referido 0.75 + fondo 2.25', () => {
    // Comisión 10% de 30 = 3 NTX → 25% de 3 = 0.75 referido / 2.25 fondo
    const commission = 30 * 0.10;
    const r = computeRakeSplit(commission, 25);
    assert.strictEqual(commission, 3);
    assert.strictEqual(r.referralShare, 0.75);
    assert.strictEqual(r.projectShare, 2.25);
});

test('Torneo 10 jugadores (entrada 10) → fondo 7.5 + referidos 2.5', () => {
    const totalEntries = 10 * 10;           // 100
    const commission = totalEntries * 0.10; // 10
    const r = computeRakeSplit(commission, 25);
    assert.strictEqual(r.referralShare, 2.5);
    assert.strictEqual(r.projectShare, 7.5);
    assert.strictEqual(commission + totalEntries * 0.90, totalEntries); // premio 90 + comisión 10
});

// ── Motor: rake no aplica en práctica ni torneos ──
console.log('\n=== Test: rake del motor (pokerGame) ===');
const mockIo = { to: () => ({ emit: () => {} }), emit: () => {} };
const PokerTable = require('../pokerGame');

test('awardPot en mesa de práctica NO genera rake ni llama a la API', () => {
    const t = new PokerTable(mockIo, { tableId: 'sala-practica-400', isPractice: true });
    t.seats[0] = { socketId: 's1', userId: 1, username: 'A', chips: 100, cards: [], status: 'waiting', currentBet: 0, totalBet: 0, hasActed: false, handsPlayed: 0 };
    t.pot = 500;
    t.awardPot(['s1']);
    // Fichas del ganador = 100 + 500 (sin rake en práctica)
    assert.strictEqual(t.seats[0].chips, 600, 'En práctica el ganador recibe el bote COMPLETO');
});

test('awardPot en torneo NO genera rake (la comisión es la de la entrada)', () => {
    const t = new PokerTable(mockIo, { tableId: 'mtt-1-t1', isTournament: true, autoStart: false });
    t.seats[0] = { socketId: 's1', userId: 1, username: 'A', chips: 1000, cards: [], status: 'waiting', currentBet: 0, totalBet: 0, hasActed: false, handsPlayed: 0 };
    t.pot = 2000;
    t.awardPot(['s1']);
    assert.strictEqual(t.seats[0].chips, 3000, 'En torneo el ganador recibe el bote COMPLETO (sin rake)');
});

console.log(`\nResultado: ${passed} pasados, ${failed} fallidos`);
process.exit(failed > 0 ? 1 : 0);
