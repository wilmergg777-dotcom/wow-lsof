const express = require('express');
const router = express.Router();
const fetch = require('node-fetch');

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');
const { getGames, getGameById, LATE_REG_MS } = require('../services/futures');
const { getSeats } = require('../services/practice-table');

router.get('/futures-games', (req, res) => {
    const gamesConPremios = getGames().map(game => {
        const totalRecaudado = game.entry * game.players.length;
        const prizePool = (totalRecaudado * 0.90).toFixed(0);
        return {
            ...game,
            prize: Number(prizePool) > 0 ? prizePool : (game.entry * 4 * 0.9).toFixed(0)
        };
    });
    res.json(gamesConPremios);
});

router.post('/futures-games/register', verifyToken, async (req, res) => {
    const { gameId } = req.body;
    const userId = req.user.id;

    const game = getGameById(gameId);
    if (!game) return res.status(404).json({ error: 'Torneo no encontrado' });
    if (game.status !== 'OPEN') return res.status(400).json({ error: 'Registro cerrado para este torneo' });

    const now = Date.now();
    const lateRegEnd = game.startTime + LATE_REG_MS;

    if (now > lateRegEnd) return res.status(400).json({ error: 'Registro cerrado para este torneo' });
    if (game.players.includes(userId)) return res.status(400).json({ error: 'Ya estas registrado en este torneo' });
    if (game.players.length >= game.maxPlayers) return res.status(400).json({ error: 'Torneo lleno' });

    game.players.push(userId);

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [wallet] = await connection.query("SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE", [userId]);
        if (!wallet[0] || wallet[0].balance_ntx < game.entry) {
            throw new Error('Saldo insuficiente para pagar la entrada');
        }

        await connection.query("UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?", [game.entry, userId]);

        await connection.commit();
        res.json({ message: 'Registro exitoso', newBalance: wallet[0].balance_ntx - game.entry, game });
    } catch (error) {
        await connection.rollback();
        const i = game.players.indexOf(userId);
        if (i >= 0) game.players.splice(i, 1);
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.post('/poker/buy-in', verifyToken, async (req, res) => {
    const { amount, tableId } = req.body;
    const userId = req.user.id;

    if (!amount || amount <= 0) return res.status(400).json({ error: 'Monto invalido' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [wallet] = await connection.query("SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE", [userId]);
        if (!wallet[0] || wallet[0].balance_ntx < amount) {
            throw new Error('Saldo insuficiente para esta entrada');
        }

        await connection.query("UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?", [amount, userId]);

        await connection.commit();
        res.json({ message: 'Buy-in exitoso', newBalance: wallet[0].balance_ntx - amount });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.post('/poker/cash-out', async (req, res) => {
    const { userId, amount } = req.body;
    if (!userId || !amount || amount <= 0) {
        return res.status(400).json({ error: 'Datos invalidos para procesar el retiro' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        await connection.query("UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?", [amount, userId]);
        await connection.commit();
        res.json({ message: 'Cash-out exitoso', amount });
    } catch (error) {
        await connection.rollback();
        console.error("Error al procesar el cash-out:", error);
        res.status(500).json({ error: 'Error al procesar el cash-out' });
    } finally {
        connection.release();
    }
});

router.post('/poker/process-rake', async (req, res) => {
    const { rakeAmount, playerId } = req.body;
    if (!rakeAmount || !playerId || rakeAmount <= 0) {
        return res.status(400).json({ error: 'Datos invalidos para procesar el rake' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [users] = await connection.query('SELECT referred_by FROM users WHERE id = ?', [playerId]);
        const referrerId = users[0]?.referred_by;

        const referrerShare = Number((rakeAmount * 0.25).toFixed(2));
        const projectShare = Number((rakeAmount * 0.75).toFixed(2));

        await connection.query("UPDATE bank_reserves SET balance_ntx = balance_ntx + ? WHERE id = 1", [projectShare]);

        if (referrerId) {
            await connection.query(
                "INSERT INTO referral_earnings (referrer_id, referred_id, amount, status) VALUES (?, ?, ?, 'pending')",
                [referrerId, playerId, referrerShare]
            );
        } else {
            await connection.query("UPDATE bank_reserves SET balance_ntx = balance_ntx + ? WHERE id = 1", [referrerShare]);
        }

        await connection.commit();
        res.json({ message: 'Rake procesado correctamente', projectShare, referrerShare });
    } catch (error) {
        await connection.rollback();
        console.error("Error al procesar el rake:", error);
        res.status(500).json({ error: 'Error al procesar el rake' });
    } finally {
        connection.release();
    }
});

router.get('/tables/casual', async (req, res) => {
    try {
        let liveTables = {};
        try {
            const liveRes = await fetch('http://localhost:3001/api/tables/live');
            if (liveRes.ok) liveTables = await liveRes.json();
        } catch (e) {
            console.log("Servidor de mesas reales apagado, mostrando 0 jugadores.");
        }

        const practicePlayers = getSeats().filter(p => p !== null).map(p => p.userId);

        const casualTables = [
            { id: 'omaha-05-1', name: 'OMAHA', blinds: '0.25/0.5 NTX-20', maxPlayers: 12, timer: '15s', tableType: '6-Max', players: liveTables['omaha-05-1'] || [] },
            { id: 'holdem-1-2', name: "HOLD'EM", blinds: '1/2 NTX-20', maxPlayers: 12, timer: '15s', tableType: '6-Max', players: liveTables['holdem-1-2'] || [] },
            { id: 'holdem-2-4', name: "HOLD'EM", blinds: '5/10 NTX-20', maxPlayers: 12, timer: '15s', tableType: '9-Max', players: liveTables['holdem-2-4'] || [] },
            { id: 'holdem-5-10', name: "HOLD'EM", blinds: '10/20 NTX-20', maxPlayers: 12, timer: '15s', tableType: '6-Max', players: liveTables['holdem-5-10'] || [] },
            { id: 'shortdeck-10-20', name: "SHORT DECK", blinds: '20/40 NTX-20', maxPlayers: 12, timer: '15s', tableType: '6-Max', players: liveTables['shortdeck-10-20'] || [] },
            {
                id: 'sala-practica-400',
                name: 'SALA DE PRACTICA',
                blinds: '400 Fichas - Freeroll',
                maxPlayers: 9,
                timer: '15s',
                tableType: '9-Max',
                image: '/img/sala-practica.jpg',
                players: practicePlayers,
                isPractice: true
            }
        ];

        res.json(casualTables);
    } catch (error) {
        console.error("Error al obtener mesas casuales:", error);
        res.status(500).json({ error: 'Error al cargar las mesas' });
    }
});

module.exports = router;