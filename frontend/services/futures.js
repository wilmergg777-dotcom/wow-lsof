const pool = require('../db');

let futuresGames = [];
const ENTRY_FEES = [10, 15, 30, 40];
const INTERVAL_MS = 110 * 60 * 1000;
const LATE_REG_MS = 10 * 60 * 1000;
const TOURNAMENT_MS = 2 * 60 * 60 * 1000;
const CLEANUP_MS = 3 * 60 * 60 * 1000;

function buildTournament(baseDate, indexInDay) {
    const startTime = baseDate.getTime() + indexInDay * INTERVAL_MS;
    const fee = ENTRY_FEES[indexInDay];
    return {
        id: `fg-${startTime}-${indexInDay}`,
        title: `Tournament - ${fee} NTX-20`,
        entry: fee,
        image: `/futures-${fee}.png`,
        startTime,
        players: [],
        maxPlayers: 100,
        status: 'OPEN'
    };
}

function generateFuturesGames() {
    const now = new Date();
    const existingIds = new Set(futuresGames.map(g => g.id));

    for (let offset = 0; offset < 4; offset++) {
        const base = new Date(now);
        base.setHours(10, 30, 0, 0);
        base.setDate(base.getDate() + offset);
        for (let i = 0; i < 4; i++) {
            const t = buildTournament(base, i);
            if (!existingIds.has(t.id)) futuresGames.push(t);
        }
    }

    futuresGames = futuresGames.filter(g => {
        const age = Date.now() - g.startTime;
        if (age < CLEANUP_MS) return true;
        return g.status === 'OPEN' || g.status === 'PLAYING';
    });
}

async function refundGame(game, reason) {
    if (game.players.length === 0) return true;
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        for (const userId of game.players) {
            await connection.query("UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?", [game.entry, userId]);
        }
        await connection.commit();
        console.log(`[Futures] Reembolsado ${game.entry} x ${game.players.length} jugadores (${reason}) en ${game.id}`);
        game.players = [];
        return true;
    } catch (err) {
        await connection.rollback();
        console.error(`[Futures] Error reembolsando ${game.id}:`, err);
        return false;
    } finally {
        connection.release();
    }
}

let checkingStatus = false;
async function checkTournamentsStatus() {
    if (checkingStatus) return;
    checkingStatus = true;
    try {
        const now = Date.now();
        for (const game of futuresGames) {
            const lateRegEnd = game.startTime + LATE_REG_MS;
            const tournamentEnd = game.startTime + TOURNAMENT_MS;

            if (game.status === 'OPEN' && now > lateRegEnd) {
                if (game.players.length < 2) {
                    const ok = await refundGame(game, 'menos de 2 jugadores');
                    if (ok) game.status = 'CANCELLED';
                } else {
                    game.status = 'PLAYING';
                    console.log(`[Futures] ${game.id} en juego con ${game.players.length} jugadores.`);
                }
            }

            if (game.status === 'PLAYING' && now > tournamentEnd) {
                const ok = await refundGame(game, 'cierre sin motor MTT');
                if (ok) game.status = 'FINISHED';
            }
        }
    } finally {
        checkingStatus = false;
    }
}

generateFuturesGames();
setInterval(generateFuturesGames, 30 * 60 * 1000);
setInterval(checkTournamentsStatus, 10000);

module.exports = {
    getGames: () => futuresGames,
    getGameById: (id) => futuresGames.find(g => g.id === id),
    LATE_REG_MS
};