const express = require('express');
const router = express.Router();

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');
const { enviarCodigoRetiro } = require('../utils/email');

router.get('/wallet', verifyToken, async (req, res) => {
    const [wallets] = await pool.query('SELECT balance_ntx FROM wallets WHERE user_id = ?', [req.user.id]);
    res.json({ balance_ntx: wallets[0]?.balance_ntx || 0 });
});

router.get('/wallet/admin-details', verifyToken, async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT b.* FROM bank_accounts b JOIN users u ON b.user_id = u.id WHERE u.role = "superadmin" LIMIT 1'
        );
        if (rows.length === 0) return res.status(404).json({ error: 'El admin no ha configurado sus datos aun' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener datos del admin' });
    }
});

router.post('/wallet/deposit', verifyToken, async (req, res) => {
    const { amount_cup, transaction_id } = req.body;
    const userId = req.user.id;

    if (!amount_cup || !transaction_id) {
        return res.status(400).json({ error: 'Debes ingresar el monto y el ID de la transferencia' });
    }

    try {
        await pool.query(
            'INSERT INTO deposit_requests (user_id, amount_cup, transaction_id, status) VALUES (?, ?, ?, "pending")',
            [userId, amount_cup, transaction_id]
        );
        res.json({ message: 'Solicitud enviada correctamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al procesar la solicitud' });
    }
});

// 🔥 PASO 1 del retiro: valida PIN + saldo, genera código, envía correo.
// NO descuenta saldo ni crea la solicitud todavía.
router.post('/wallet/withdraw', verifyToken, async (req, res) => {
    const { amount_ntx, card_number, holder_name, bank_name, pin } = req.body;
    const userId = req.user.id;
    const amount = Number(amount_ntx);

    if (amount <= 0) return res.status(400).json({ error: 'Monto invalido' });
    if (!card_number || !holder_name || !bank_name) return res.status(400).json({ error: 'Faltan datos bancarios' });
    if (!pin) return res.status(400).json({ error: 'Debes ingresar tu PIN de seguridad para retirar' });

    try {
        const [userData] = await pool.query("SELECT pay_pin, pay_pin_enabled, email FROM users WHERE id = ?", [userId]);
        const userPin = userData[0]?.pay_pin;
        const userEmail = userData[0]?.email;

        if (!userPin) return res.status(400).json({ error: 'No tienes un PIN configurado. Ve a Seguridad para configurarlo.' });
        if (userPin !== pin) return res.status(400).json({ error: 'PIN de seguridad incorrecto. Intentalo de nuevo.' });
        if (!userEmail) return res.status(400).json({ error: 'Necesitas un correo registrado para verificar el retiro. Actualiza tu perfil.' });

        const [wallet] = await pool.query("SELECT balance_ntx FROM wallets WHERE user_id = ?", [userId]);
        if (!wallet[0] || wallet[0].balance_ntx < amount) {
            return res.status(400).json({ error: 'Saldo insuficiente' });
        }

        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + 15);

        // Borrar códigos viejos y guardar el nuevo con TODO el payload en la DB
        await pool.query('DELETE FROM withdraw_verification_codes WHERE user_id = ?', [userId]);
        await pool.query(
            `INSERT INTO withdraw_verification_codes 
                (user_id, code, amount_ntx, card_number, holder_name, bank_name, expires_at) 
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [userId, code, amount, card_number, holder_name, bank_name, expiresAt]
        );

        const enviado = await enviarCodigoRetiro(userEmail, code, amount, bank_name);
        if (!enviado) {
            await pool.query('DELETE FROM withdraw_verification_codes WHERE user_id = ? AND code = ?', [userId, code]);
            return res.status(500).json({ error: 'No se pudo enviar el correo. Contacta al administrador.' });
        }

        const maskedEmail = userEmail.replace(/(.{2}).+(@.+)/, '$1***$2');
        res.json({
            requires_verification: true,
            email: maskedEmail,
            message: `Hemos enviado un código de verificación a ${maskedEmail}. Ingrésalo para completar el retiro de ${amount} NTX.`
        });
    } catch (error) {
        console.error("ERROR withdraw step 1:", error);
        res.status(500).json({ error: 'Error al procesar la solicitud' });
    }
});

// 🔥 PASO 2 del retiro: valida código, descuenta saldo, crea la solicitud.
// Usa los datos guardados en la DB (no los que manda el cliente).
router.post('/wallet/withdraw/verify', verifyToken, async (req, res) => {
    const { code } = req.body;
    const userId = req.user.id;

    if (!code || code.length !== 6) return res.status(400).json({ error: 'Código inválido' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [codes] = await connection.query(
            "SELECT * FROM withdraw_verification_codes WHERE user_id = ? AND code = ? AND expires_at > NOW() FOR UPDATE",
            [userId, code]
        );

        if (codes.length === 0) {
            await connection.rollback();
            return res.status(400).json({ error: 'Código incorrecto o expirado. Solicita uno nuevo.' });
        }

        const record = codes[0];
        const amount = Number(record.amount_ntx);

        // Re-verificar saldo (por si cambió entre el paso 1 y el paso 2)
        const [wallet] = await connection.query("SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE", [userId]);
        if (!wallet[0] || wallet[0].balance_ntx < amount) {
            await connection.query('DELETE FROM withdraw_verification_codes WHERE user_id = ?', [userId]);
            throw new Error('Saldo insuficiente');
        }

        await connection.query("UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?", [amount, userId]);
        await connection.query(
            "INSERT INTO withdraw_requests (user_id, amount_ntx, card_number, holder_name, bank_name) VALUES (?, ?, ?, ?, ?)",
            [userId, amount, record.card_number, record.holder_name, record.bank_name]
        );
        await connection.query('DELETE FROM withdraw_verification_codes WHERE user_id = ?', [userId]);

        await connection.commit();
        res.json({ message: 'Retiro solicitado correctamente. Espera la transferencia.' });
    } catch (error) {
        await connection.rollback();
        console.error("ERROR withdraw verify:", error);
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.post('/wallet/transfer', verifyToken, async (req, res) => {
    const { receiverUsername, amount } = req.body;
    const senderId = req.user.id;

    if (amount <= 0) return res.status(400).json({ error: 'Monto invalido' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [senderWallet] = await connection.query('SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE', [senderId]);
        if (!senderWallet[0] || senderWallet[0].balance_ntx < amount) throw new Error('Saldo insuficiente');

        const [receiver] = await connection.query('SELECT id FROM users WHERE username = ?', [receiverUsername]);
        if (receiver.length === 0) throw new Error('Usuario destino no encontrado');
        const receiverId = receiver[0].id;

        if (senderId === receiverId) throw new Error('No puedes transferirte a ti mismo');

        await connection.query('UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?', [amount, senderId]);
        await connection.query('UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?', [amount, receiverId]);

        await connection.commit();
        res.json({ message: 'Transferencia exitosa' });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.get('/wallet/history', verifyToken, async (req, res) => {
    try {
        const [deposits] = await pool.query(
            "SELECT id, amount_cup as amount, 'Deposito' as type, created_at, status FROM deposit_requests WHERE user_id = ?",
            [req.user.id]
        );
        const [withdrawals] = await pool.query(
            "SELECT id, amount_ntx as amount, 'Retiro' as type, created_at, status FROM withdraw_requests WHERE user_id = ?",
            [req.user.id]
        );
        const history = [...deposits, ...withdrawals].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        res.json(history);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener historial' });
    }
});

router.get('/wallet/system-status', async (req, res) => {
    try {
        const [rows] = await pool.query("SELECT setting_key, setting_value FROM wallet_settings");
        const settings = {};
        rows.forEach(r => { settings[r.setting_key] = r.setting_value === 1; });
        res.json({
            retiros_activos: settings.retiros_activos !== false,
            inversiones_activas: settings.inversiones_activas !== false
        });
    } catch (error) {
        console.error("ERROR system-status:", error.message, "| code:", error.code);
        res.status(500).json({ error: 'Error al obtener estado', detail: error.message, code: error.code });
    }
});

module.exports = router;