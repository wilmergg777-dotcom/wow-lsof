const express = require('express');
const router = express.Router();

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');
const { enviarCodigoRetiro, enviarCodigoTransferencia } = require('../utils/email');
const { verifyPin, hashPin } = require('../utils/pin');
// ===========================================================
// VALIDADOR
// ===========================================================
const {
  validateDeposit, validateWithdraw, validateWithdrawVerify,
  validateTransferLegacy, validateTransferRequest, validateTransferVerify,
} = require('../middlewares/validators');

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

router.post('/wallet/deposit', verifyToken, validateDeposit, async (req, res) => {
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

// ?? PASO 1 del retiro: valida PIN + saldo, genera c¨®digo, env¨ªa correo.
// NO descuenta saldo ni crea la solicitud todav¨ªa.
router.post('/wallet/withdraw', verifyToken, validateWithdraw, async (req, res) => {
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
        // ?? SEGURIDAD: verificación con bcrypt + migración automática de PIN legacy
        const pinCheck = await verifyPin(pin, userPin);
        if (!pinCheck.ok) return res.status(400).json({ error: 'PIN de seguridad incorrecto. Intentalo de nuevo.' });
        if (pinCheck.wasLegacy) {
            // Migración progresiva: el PIN viejo en texto plano se guarda hasheado
            try {
                await pool.query('UPDATE users SET pay_pin = ? WHERE id = ?', [await hashPin(pin), userId]);
            } catch (migErr) { console.warn('[withdraw] Migración de PIN legacy falló:', migErr.message); }
        }
        if (!userEmail) return res.status(400).json({ error: 'Necesitas un correo registrado para verificar el retiro. Actualiza tu perfil.' });

        const [wallet] = await pool.query("SELECT balance_ntx FROM wallets WHERE user_id = ?", [userId]);
        if (!wallet[0] || wallet[0].balance_ntx < amount) {
            return res.status(400).json({ error: 'Saldo insuficiente' });
        }

        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + 15);

        // Borrar c¨®digos viejos y guardar el nuevo con TODO el payload en la DB
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
            message: `Hemos enviado un c¨®digo de verificaci¨®n a ${maskedEmail}. Ingr¨¦salo para completar el retiro de ${amount} NTX.`
        });
    } catch (error) {
        console.error("ERROR withdraw step 1:", error);
        res.status(500).json({ error: 'Error al procesar la solicitud' });
    }
});

// ?? PASO 2 del retiro: valida c¨®digo, descuenta saldo, crea la solicitud.
// Usa los datos guardados en la DB (no los que manda el cliente).
router.post('/wallet/withdraw/verify', verifyToken, validateWithdrawVerify, async (req, res) => {
    const { code } = req.body;
    const userId = req.user.id;

    if (!code || code.length !== 6) return res.status(400).json({ error: 'C¨®digo inv¨¢lido' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [codes] = await connection.query(
            "SELECT * FROM withdraw_verification_codes WHERE user_id = ? AND code = ? AND expires_at > NOW() FOR UPDATE",
            [userId, code]
        );

        if (codes.length === 0) {
            await connection.rollback();
            return res.status(400).json({ error: 'C¨®digo incorrecto o expirado. Solicita uno nuevo.' });
        }

        const record = codes[0];
        const amount = Number(record.amount_ntx);

        // Re-verificar saldo (por si cambi¨® entre el paso 1 y el paso 2)
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

// ?? FLUJO VIEJO DE TRANSFERENCIA (por username, sin PIN ni correo).
// Se mantiene por compatibilidad, pero el frontend ya NO lo usa.
router.post('/wallet/transfer', verifyToken, validateTransferLegacy, async (req, res) => {
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

// ==========================================
// ?? NUEVO FLUJO DE TRANSFERENCIA CON VALIDACI¨®N DE 24 HORAS
// ==========================================

router.post('/wallet/transfer/request', verifyToken, validateTransferRequest, async (req, res) => {
    const { receiverUniqueId, amount, pin } = req.body;
    const senderId = req.user.id;
    const amountNum = Number(amount);

    // --- Validaciones de entrada ---
    if (!receiverUniqueId) return res.status(400).json({ error: 'Debes especificar el ID del destinatario.' });
    if (!Number.isFinite(amountNum) || amountNum <= 0) return res.status(400).json({ error: 'Monto inv¨¢lido.' });
    if (!pin) return res.status(400).json({ error: 'Debes ingresar tu PIN de pago.' });

    try {
        // --- Obtener datos del emisor + Fechas de cambios de seguridad ---
        const [senderData] = await pool.query(
            "SELECT pay_pin, pay_pin_enabled, email, pin_changed_at, email_changed_at FROM users WHERE id = ?",
            [senderId]
        );
        const senderPin = senderData[0]?.pay_pin;
        const senderEmail = senderData[0]?.email;
        const pinChangedAt = senderData[0]?.pin_changed_at;
        const emailChangedAt = senderData[0]?.email_changed_at;

        if (!senderPin) return res.status(400).json({ error: 'No tienes un PIN configurado. Ve a Seguridad para configurarlo.' });
        // ?? SEGURIDAD: verificación con bcrypt + migración automática de PIN legacy
        const pinCheck = await verifyPin(pin, senderPin);
        if (!pinCheck.ok) return res.status(400).json({ error: 'PIN de pago incorrecto. Intentalo de nuevo.' });
        if (pinCheck.wasLegacy) {
            try {
                await pool.query('UPDATE users SET pay_pin = ? WHERE id = ?', [await hashPin(pin), senderId]);
            } catch (migErr) { console.warn('[transfer] Migración de PIN legacy falló:', migErr.message); }
        }
        if (!senderEmail) return res.status(400).json({ error: 'Necesitas un correo registrado para verificar la transferencia. Actualiza tu perfil.' });

        // ?? VALIDACI¨®N DE 24 HORAS
        const now = new Date();
        const restrictMs = 24 * 60 * 60 * 1000; // 24 horas en milisegundos

        if (pinChangedAt) {
            const diffPin = now - new Date(pinChangedAt);
            if (diffPin < restrictMs) {
                return res.status(403).json({ error: 'Transferencias bloqueadas por 24h tras cambio de PIN.' });
            }
        }
        if (emailChangedAt) {
            const diffEmail = now - new Date(emailChangedAt);
            if (diffEmail < restrictMs) {
                return res.status(403).json({ error: 'Transferencias bloqueadas por 24h tras cambio de Correo.' });
            }
        }
        // FIN DE VALIDACI¨®N 24H

        // --- Buscar al receptor por ID ¨²nico (sin el @) ---
        const cleanReceiverId = String(receiverUniqueId).replace('@', '').trim();
        const [receivers] = await pool.query(
            'SELECT id, username FROM users WHERE unique_id = ?',
            [cleanReceiverId]
        );
        if (receivers.length === 0) {
            return res.status(404).json({ error: 'Jugador destino no encontrado.' });
        }
        const receiver = receivers[0];

        if (senderId === receiver.id) {
            return res.status(400).json({ error: 'No puedes transferirte dinero a ti mismo.' });
        }

        // --- Verificar saldo del emisor ---
        const [wallet] = await pool.query(
            "SELECT balance_ntx FROM wallets WHERE user_id = ?",
            [senderId]
        );
        if (!wallet[0] || wallet[0].balance_ntx < amountNum) {
            return res.status(400).json({ error: 'Saldo insuficiente para esta transferencia.' });
        }

        // --- Generar c¨®digo de 6 d¨ªgitos y guardarlo en DB (15 min de vida) ---
        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + 15);

        // Borrar c¨®digos viejos del mismo usuario y guardar el nuevo
        await pool.query('DELETE FROM transfer_verification_codes WHERE user_id = ?', [senderId]);
        await pool.query(
            `INSERT INTO transfer_verification_codes 
                (user_id, code, amount_ntx, receiver_id, expires_at) 
             VALUES (?, ?, ?, ?, ?)`,
            [senderId, code, amountNum, receiver.id, expiresAt]
        );

        // --- Enviar correo (funci¨®n espec¨ªfica para transferencias) ---
        const enviado = await enviarCodigoTransferencia(senderEmail, code, amountNum, receiver.username);
        if (!enviado) {
            await pool.query('DELETE FROM transfer_verification_codes WHERE user_id = ? AND code = ?', [senderId, code]);
            return res.status(500).json({ error: 'No se pudo enviar el correo. Contacta al administrador.' });
        }

        const maskedEmail = senderEmail.replace(/(.{2}).+(@.+)/, '$1***$2');
        res.json({
            requires_verification: true,
            email: maskedEmail,
            message: `Hemos enviado un c¨®digo de verificaci¨®n a ${maskedEmail}. Ingr¨¦salo para confirmar la transferencia de ${amountNum} NTX a ${receiver.username}.`
        });
    } catch (error) {
        console.error("ERROR transfer/request:", error);
        res.status(500).json({ error: 'Error al procesar la solicitud de transferencia.' });
    }
});

// ?? PASO 3 del nuevo flujo: valida c¨®digo, ejecuta la transferencia at¨®micamente.
router.post('/wallet/transfer/verify', verifyToken, validateTransferVerify, async (req, res) => {
    const { receiverUniqueId, amount, code } = req.body;
    const senderId = req.user.id;
    const amountNum = Number(amount);

    if (!code || code.length !== 6) return res.status(400).json({ error: 'El c¨®digo debe tener 6 d¨ªgitos.' });
    if (!Number.isFinite(amountNum) || amountNum <= 0) return res.status(400).json({ error: 'Monto inv¨¢lido.' });
    if (!receiverUniqueId) return res.status(400).json({ error: 'Falta el ID del destinatario.' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // --- 1. Validar c¨®digo ---
        const [codes] = await connection.query(
            "SELECT * FROM transfer_verification_codes WHERE user_id = ? AND code = ? AND expires_at > NOW() FOR UPDATE",
            [senderId, code]
        );
        if (codes.length === 0) {
            await connection.rollback();
            return res.status(400).json({ error: 'C¨®digo incorrecto o expirado. Solicita uno nuevo.' });
        }
        const record = codes[0];

        // --- 2. Re-verificar receptor (no confiar en el cliente) ---
        const cleanReceiverId = String(receiverUniqueId).replace('@', '').trim();
        const [receivers] = await connection.query(
            'SELECT id, username FROM users WHERE unique_id = ?',
            [cleanReceiverId]
        );
        if (receivers.length === 0) {
            await connection.query('DELETE FROM transfer_verification_codes WHERE user_id = ?', [senderId]);
            throw new Error('Jugador destino no encontrado.');
        }
        const receiver = receivers[0];

        if (Number(record.receiver_id) !== Number(receiver.id)) {
            throw new Error('El destinatario no coincide con la solicitud original.');
        }

        if (senderId === receiver.id) {
            throw new Error('No puedes transferirte dinero a ti mismo.');
        }

        // --- 3. Verificar que el monto coincida con el de la solicitud original ---
        if (Number(record.amount_ntx) !== amountNum) {
            throw new Error('El monto no coincide con la solicitud original.');
        }

        // --- 4. Re-verificar saldo del emisor ---
        const [wallet] = await connection.query(
            "SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE",
            [senderId]
        );
        if (!wallet[0] || wallet[0].balance_ntx < amountNum) {
            await connection.query('DELETE FROM transfer_verification_codes WHERE user_id = ?', [senderId]);
            throw new Error('Saldo insuficiente.');
        }

        // --- 5. Ejecutar la transferencia (at¨®mica) ---
        await connection.query(
            "UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?",
            [amountNum, senderId]
        );
        await connection.query(
            "UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?",
            [amountNum, receiver.id]
        );

        // --- 6. Registrar en el historial de transferencias ---
        try {
            await connection.query(
                "INSERT INTO transfers (sender_id, receiver_id, amount_ntx) VALUES (?, ?, ?)",
                [senderId, receiver.id, amountNum]
            );
        } catch (errInsert) {
            console.warn('[transfer/verify] No se pudo insertar en tabla transfers:', errInsert.message);
        }

        // --- 7. Borrar el c¨®digo usado ---
        await connection.query('DELETE FROM transfer_verification_codes WHERE user_id = ?', [senderId]);

        await connection.commit();
        res.json({
            message: 'Transferencia realizada con ¨¦xito.',
            receiver: receiver.username,
            amount: amountNum
        });
    } catch (error) {
        await connection.rollback();
        console.error("ERROR transfer/verify:", error);
        res.status(400).json({ error: error.message || 'Error al procesar la transferencia.' });
    } finally {
        connection.release();
    }
});

// ==========================================
// HISTORIAL (dep¨®sitos + retiros + transferencias enviadas/recibidas)
// ==========================================
router.get('/wallet/history', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const [deposits] = await pool.query(
            "SELECT id, amount_cup as amount, 'deposit' as type, created_at, status FROM deposit_requests WHERE user_id = ?",
            [userId]
        );
        const [withdrawals] = await pool.query(
            "SELECT id, amount_ntx as amount, 'withdraw' as type, created_at, status FROM withdraw_requests WHERE user_id = ?",
            [userId]
        );

        // ?? Transferencias enviadas (type: transfer_out)
        let transfersOut = [];
        try {
            const [rows] = await pool.query(
                `SELECT t.id, t.amount_ntx as amount, 'transfer_out' as type, t.created_at, 'approved' as status, u.username as counterparty
                 FROM transfers t
                 JOIN users u ON t.receiver_id = u.id
                 WHERE t.sender_id = ?`,
                [userId]
            );
            transfersOut = rows;
        } catch (e) {
            console.warn('[wallet/history] Tabla transfers no existe, omitiendo transferencias enviadas.');
        }

        // ?? Transferencias recibidas (type: transfer_in)
        let transfersIn = [];
        try {
            const [rows] = await pool.query(
                `SELECT t.id, t.amount_ntx as amount, 'transfer_in' as type, t.created_at, 'approved' as status, u.username as counterparty
                 FROM transfers t
                 JOIN users u ON t.sender_id = u.id
                 WHERE t.receiver_id = ?`,
                [userId]
            );
            transfersIn = rows;
        } catch (e) {
            console.warn('[wallet/history] Tabla transfers no existe, omitiendo transferencias recibidas.');
        }

        const history = [...deposits, ...withdrawals, ...transfersOut, ...transfersIn]
            .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

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