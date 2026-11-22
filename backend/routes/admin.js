const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');

const pool = require('../db');
const { crearNotificacion } = require('../utils/notifications');
const {
    enviarCorreoDepositoAprobado,
    enviarCorreoRetiroAprobado,
    enviarCorreoRetiroRechazado
} = require('../utils/email');
// ===========================================================
// VALIDADOR
// ===========================================================
const {
  validateRequestId, validateAdminSettingsToggle, validateFundAdmin,
  validateServerConfig, validateSmtpConfig, validateSmtpTest,
  validateAnnouncement, validateIdParam,
} = require('../middlewares/validators');
// ===========================================================
// ADMIN
// ===========================================================
const { verifyToken, requireAdmin, requireSuperAdmin } = require('../middlewares/auth');

// ?? FIX: solo aplica auth a rutas que empiecen con /admin,
// as赤 no bloquea /futures-games, /tables/casual, etc. de otros routers.
router.use('/admin', verifyToken, requireAdmin);

router.get('/admin/pending', async (req, res) => {
    try {
        const [deposits] = await pool.query(
            "SELECT d.*, u.username FROM deposit_requests d JOIN users u ON d.user_id = u.id WHERE d.status = 'pending'"
        );
        const [withdrawals] = await pool.query(
            "SELECT w.*, u.username FROM withdraw_requests w JOIN users u ON w.user_id = u.id WHERE w.status = 'pending'"
        );
        const [reserves] = await pool.query("SELECT * FROM bank_reserves WHERE id = 1");
        res.json({ deposits, withdrawals, reserves: reserves[0] || { balance_ntx: 0 } });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener datos' });
    }
});

router.post('/admin/deposits/take', validateRequestId, async (req, res) => {
    const { request_id } = req.body;
    const adminId = req.user.id;
    if (!request_id) return res.status(400).json({ error: 'ID de solicitud requerido' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [reqData] = await connection.query(
            "SELECT * FROM deposit_requests WHERE id = ? AND status = 'pending' FOR UPDATE",
            [request_id]
        );
        if (reqData.length === 0) throw new Error('La solicitud ya fue tomada o no existe');

        await connection.query(
            "UPDATE deposit_requests SET status = 'taken', admin_id = ? WHERE id = ?",
            [adminId, request_id]
        );

        await connection.commit();
        res.json({ message: 'Solicitud tomada correctamente', request_id });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.post('/admin/withdrawals/take', validateRequestId, async (req, res) => {
    const { request_id } = req.body;
    const adminId = req.user.id;
    if (!request_id) return res.status(400).json({ error: 'ID de solicitud requerido' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [reqData] = await connection.query(
            "SELECT * FROM withdraw_requests WHERE id = ? AND status = 'pending' FOR UPDATE",
            [request_id]
        );
        if (reqData.length === 0) throw new Error('La solicitud ya fue tomada o no existe');

        await connection.query(
            "UPDATE withdraw_requests SET status = 'taken', admin_id = ? WHERE id = ?",
            [adminId, request_id]
        );

        await connection.commit();
        res.json({ message: 'Solicitud tomada correctamente', request_id });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.get('/admin/my-taken', async (req, res) => {
    const adminId = req.user.id;
    try {
        const [deposits] = await pool.query(
            "SELECT d.*, u.username FROM deposit_requests d JOIN users u ON d.user_id = u.id WHERE d.status = 'taken' AND d.admin_id = ?",
            [adminId]
        );
        const [withdrawals] = await pool.query(
            "SELECT w.*, u.username FROM withdraw_requests w JOIN users u ON w.user_id = u.id WHERE w.status = 'taken' AND w.admin_id = ?",
            [adminId]
        );
        res.json({ deposits, withdrawals });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener tus solicitudes' });
    }
});

router.get('/admin/audit-log', async (req, res) => {
    try {
        const [deposits] = await pool.query(`
            SELECT d.id, d.amount_cup AS amount, 'Deposito' AS type, d.created_at, d.status,
                COALESCE(u.username, 'Sin asignar') AS admin
            FROM deposit_requests d
            LEFT JOIN users u ON d.admin_id = u.id
        `);
        const [withdrawals] = await pool.query(`
            SELECT w.id, w.amount_ntx AS amount, 'Retiro' AS type, w.created_at, w.status,
                COALESCE(u.username, 'Sin asignar') AS admin
            FROM withdraw_requests w
            LEFT JOIN users u ON w.admin_id = u.id
        `);
        const combined = [...deposits, ...withdrawals].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        res.json(combined);
    } catch (error) {
        console.error("Error al obtener auditoria:", error);
        res.status(500).json({ error: 'Error al obtener historial de auditoria' });
    }
});

// ?? MODIFICADO: L車gica del Bono de Inversi車n integrada
router.post('/admin/deposits/approve', validateRequestId, async (req, res) => {
    const { request_id } = req.body;
    const adminId = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [reqData] = await connection.query(
            "SELECT * FROM deposit_requests WHERE id = ? AND status = 'taken' AND admin_id = ? FOR UPDATE",
            [request_id, adminId]
        );
        if (reqData.length === 0) throw new Error('No puedes aprobar esta solicitud. No la tomaste tu o ya fue procesada.');

        const amount = Number(reqData[0].amount_cup);
        const userId = reqData[0].user_id;

        // ?? L車GICA DEL BONO DE INVERSI車N
        let bonoAplicado = 0;
        let totalAcreditado = amount;

        const [settingsRows] = await connection.query(
            "SELECT setting_key, setting_value FROM wallet_settings WHERE setting_key IN ('bonus_porcentaje', 'bonus_limite_total', 'bonus_usado')"
        );
        const settings = {};
        settingsRows.forEach(r => settings[r.setting_key] = Number(r.setting_value));

        const bonusPorcentaje = settings['bonus_porcentaje'] || 0;
        const bonusLimite = settings['bonus_limite_total'] || 0;
        const bonusUsado = settings['bonus_usado'] || 0;

        if (bonusPorcentaje > 0 && bonusLimite > bonusUsado) {
            let bonoCalculado = amount * (bonusPorcentaje / 100);
            let bonoDisponible = bonusLimite - bonusUsado;

            // Se entrega el bono calculado, o lo que quede en la bolsa si el bono es mayor
            bonoAplicado = bonoCalculado <= bonoDisponible ? bonoCalculado : bonoDisponible;
            
            // Redondear a 2 decimales
            bonoAplicado = Number(bonoAplicado.toFixed(2));
            totalAcreditado = amount + bonoAplicado;

            let nuevoBonusUsado = bonusUsado + bonoAplicado;

            // Guardar en la base de datos cu芍nto se ha usado
            await connection.query(`
                INSERT INTO wallet_settings (setting_key, setting_value) VALUES ('bonus_usado', ?)
                ON DUPLICATE KEY UPDATE setting_value = ?
            `, [nuevoBonusUsado, nuevoBonusUsado]);

            // Si la bolsa se agot車, apagar el bono
            if (nuevoBonusUsado >= bonusLimite) {
                await connection.query(`
                    INSERT INTO wallet_settings (setting_key, setting_value) VALUES ('bonus_porcentaje', 0)
                    ON DUPLICATE KEY UPDATE setting_value = 0
                `);
            }
        }

        // Sumar al jugador el dep車sito + su bono
        await connection.query("UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?", [totalAcreditado, userId]);
        
        // Las reservas y el balance del admin se actualizan con el monto real depositado (amount)
        await connection.query("UPDATE bank_reserves SET balance_ntx = balance_ntx + ? WHERE id = 1", [amount]);
        await connection.query(`
            INSERT INTO admin_balances (admin_id, total_recibido, total_retirado, fondo)
            VALUES (?, ?, 0, 0)
            ON DUPLICATE KEY UPDATE total_recibido = total_recibido + ?
        `, [adminId, amount, amount]);

        await connection.query("UPDATE deposit_requests SET status = 'approved' WHERE id = ?", [request_id]);

        await connection.commit();

        // Notificaci車n interna al jugador
        const msjNotificacion = bonoAplicado > 0 
            ? `Tu dep車sito de ${amount} CUP ha sido aprobado. Se acreditaron ${totalAcreditado} NTX a tu billetera (Incluye un Bono de Inversi車n de ${bonoAplicado} NTX).`
            : `Tu dep車sito de ${amount} CUP ha sido aprobado. Se acreditaron ${amount} NTX a tu billetera.`;

        await crearNotificacion(
            userId,
            'Dep車sito aprobado',
            msjNotificacion,
            'deposit_approved',
            { amount, bonoAplicado, request_id }
        );

        // Enviar correo al jugador
        try {
            const [userRows] = await pool.query("SELECT email FROM users WHERE id = ?", [userId]);
            if (userRows[0]?.email) {
                await enviarCorreoDepositoAprobado(userRows[0].email, amount, totalAcreditado);
            }
        } catch (mailErr) {
            console.error('[admin/deposits/approve] Error al enviar correo:', mailErr);
        }

        res.json({ message: 'Deposito aprobado y saldo acreditado al jugador.', bonoAplicado, totalAcreditado });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.post('/admin/withdrawals/approve', validateRequestId, async (req, res) => {
    const { request_id } = req.body;
    const adminId = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [reqData] = await connection.query(
            "SELECT * FROM withdraw_requests WHERE id = ? AND status = 'taken' AND admin_id = ? FOR UPDATE",
            [request_id, adminId]
        );
        if (reqData.length === 0) throw new Error('No puedes aprobar esta solicitud. No la tomaste tu o ya fue procesada.');

        const amount = Number(reqData[0].amount_ntx);
        const userId = reqData[0].user_id;
        const bankName = reqData[0].bank_name;

        await connection.query("UPDATE bank_reserves SET balance_ntx = GREATEST(0, balance_ntx - ?) WHERE id = 1", [amount]);
        await connection.query(`
            INSERT INTO admin_balances (admin_id, total_recibido, total_retirado, fondo)
            VALUES (?, 0, ?, 0)
            ON DUPLICATE KEY UPDATE total_retirado = total_retirado + ?
        `, [adminId, amount, amount]);

        await connection.query("UPDATE withdraw_requests SET status = 'approved' WHERE id = ?", [request_id]);

        await connection.commit();

        await crearNotificacion(
            userId,
            'Retiro completado',
            `Tu retiro de ${amount} NTX ha sido procesado y aprobado. El dinero ser芍 transferido a tu cuenta bancaria.`,
            'withdraw_approved',
            { amount, request_id }
        );

        try {
            const [userRows] = await pool.query("SELECT email FROM users WHERE id = ?", [userId]);
            if (userRows[0]?.email) {
                await enviarCorreoRetiroAprobado(userRows[0].email, amount, bankName);
            }
        } catch (mailErr) {
            console.error('[admin/withdrawals/approve] Error al enviar correo:', mailErr);
        }

        res.json({ message: 'Retiro completado' });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.post('/admin/withdrawals/reject', validateRequestId, async (req, res) => {
    const { request_id } = req.body;
    const adminId = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [reqData] = await connection.query(
            "SELECT * FROM withdraw_requests WHERE id = ? AND status = 'taken' AND admin_id = ? FOR UPDATE",
            [request_id, adminId]
        );
        if (reqData.length === 0) throw new Error('No puedes rechazar esta solicitud. No la tomaste tu o ya fue procesada.');

        const amount = Number(reqData[0].amount_ntx);
        const userId = reqData[0].user_id;

        await connection.query(
            "UPDATE wallets SET balance_ntx = balance_ntx + ? WHERE user_id = ?",
            [amount, userId]
        );
        await connection.query("UPDATE withdraw_requests SET status = 'rejected' WHERE id = ?", [request_id]);

        await connection.commit();

        await crearNotificacion(
            userId,
            'Retiro rechazado',
            `Tu retiro de ${amount} NTX fue rechazado. El saldo fue devuelto a tu billetera.`,
            'withdraw_rejected',
            { amount, request_id }
        );

        try {
            const [userRows] = await pool.query("SELECT email FROM users WHERE id = ?", [userId]);
            if (userRows[0]?.email) {
                await enviarCorreoRetiroRechazado(userRows[0].email, amount);
            }
        } catch (mailErr) {
            console.error('[admin/withdrawals/reject] Error al enviar correo:', mailErr);
        }

        res.json({ message: 'Retiro rechazado y saldo devuelto al jugador' });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// ?? MODIFICADO: Ahora devuelve tambi谷n los datos del bono
router.get('/admin/settings', async (req, res) => {
    try {
        const [rows] = await pool.query("SELECT setting_key, setting_value FROM wallet_settings");
        const settings = {};
        rows.forEach(r => { settings[r.setting_key] = r.setting_value; });
        
        res.json({
            retiros_activos: settings.retiros_activos === 1 || settings.retiros_activos === '1' || settings.retiros_activos === undefined,
            inversiones_activas: settings.inversiones_activas === 1 || settings.inversiones_activas === '1' || settings.inversiones_activas === undefined,
            bonus_porcentaje: Number(settings.bonus_porcentaje) || 0,
            bonus_limite_total: Number(settings.bonus_limite_total) || 0,
            bonus_usado: Number(settings.bonus_usado) || 0
        });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener ajustes' });
    }
});

// ?? MODIFICADO: Ahora tambi谷n guarda los n迆meros del bono
router.post('/admin/settings/toggle', requireSuperAdmin, validateAdminSettingsToggle, async (req, res) => {
    const { setting, value } = req.body;
    
    if (!['retiros_activos', 'inversiones_activas', 'bonus_porcentaje', 'bonus_limite_total'].includes(setting)) {
        return res.status(400).json({ error: 'Ajuste invalido' });
    }
    
    try {
        // Si es un switch (on/off), guardamos 1 o 0. Si es n迆mero, lo guardamos tal cual.
        let valToSave = value;
        if (setting === 'retiros_activos' || setting === 'inversiones_activas') {
            valToSave = value ? 1 : 0;
        }

        await pool.query(
            `INSERT INTO wallet_settings (setting_key, setting_value) VALUES (?, ?)
             ON DUPLICATE KEY UPDATE setting_value = ?`,
            [setting, valToSave, valToSave]
        );
        res.json({ success: true, setting, value: valToSave });
    } catch (error) {
        res.status(500).json({ error: 'Error al guardar ajuste' });
    }
});

router.get('/admin/bank', async (req, res) => {
    try {
        const [admins] = await pool.query(`
            SELECT u.id, u.username,
                COALESCE(ab.total_recibido, 0) as recibido,
                COALESCE(ab.total_retirado, 0) as retirado,
                COALESCE(ab.fondo, 0) as fondo,
                (COALESCE(ab.total_recibido, 0) - COALESCE(ab.total_retirado, 0)) as saldo,
                ((COALESCE(ab.total_recibido, 0) - COALESCE(ab.total_retirado, 0)) + COALESCE(ab.fondo, 0)) as disponible
            FROM users u
            LEFT JOIN admin_balances ab ON ab.admin_id = u.id
            WHERE u.role IN ('admin', 'superadmin')
        `);

        let total_recibido = 0, total_retirado = 0, total_fondo = 0;
        admins.forEach(a => {
            total_recibido += Number(a.recibido);
            total_retirado += Number(a.retirado);
            total_fondo += Number(a.fondo);
        });

        const total_saldo = total_recibido - total_retirado;
        const total_disponible = total_saldo + total_fondo;

        res.json({
            total_disponible, total_saldo, total_fondo, total_recibido, total_retirado,
            admins: admins.map(a => ({
                id: a.id,
                nombre: a.username,
                disponible: Number(a.disponible),
                saldo: Number(a.saldo),
                fondo: Number(a.fondo),
                recibido: Number(a.recibido),
                retirado: Number(a.retirado)
            }))
        });
    } catch (error) {
        console.error("Error en /api/admin/bank:", error);
        res.status(500).json({ error: 'Error al obtener datos del banco' });
    }
});

router.post('/admin/bank/fund', requireSuperAdmin, validateFundAdmin, async (req, res) => {
    const { admin_id, amount } = req.body;
    const superAdminId = req.user.id;

    if (!admin_id || !amount || Number(amount) <= 0) {
        return res.status(400).json({ error: 'Admin y monto v芍lido son obligatorios' });
    }

    const fundAmount = Number(amount);

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [admins] = await connection.query(
            "SELECT id, username FROM users WHERE id = ? AND role IN ('admin', 'superadmin') FOR UPDATE",
            [admin_id]
        );
        if (admins.length === 0) throw new Error('El usuario destino no es administrador');

        await connection.query(`
            INSERT INTO admin_balances (admin_id, total_recibido, total_retirado, fondo)
            VALUES (?, 0, 0, ?)
            ON DUPLICATE KEY UPDATE fondo = fondo + ?
        `, [admin_id, fundAmount, fundAmount]);

        await connection.commit();

        await crearNotificacion(
            admin_id,
            'Fondo agregado',
            `El superadmin te agreg車 ${fundAmount} NTX de fondo a tu cuenta.`,
            'info',
            { amount: fundAmount, by: superAdminId }
        );

        res.json({
            message: `Se agregaron ${fundAmount} NTX al fondo de ${admins[0].username}`,
            admin_id,
            admin_name: admins[0].username,
            amount: fundAmount
        });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// ==========================================
// NUEVA RUTA: LIQUIDAR FONDO DEL PROYECTO (RAKE)
// ==========================================
router.post('/admin/bank/liquidate-rake', requireSuperAdmin, async (req, res) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        
        // Obtenemos cu芍nto es lo que se va a liquidar (opcional, para devolverlo en la respuesta)
        const [reserves] = await connection.query("SELECT balance_ntx FROM bank_reserves WHERE id = 1 FOR UPDATE");
        const amountToLiquidate = reserves[0]?.balance_ntx || 0;

        if (amountToLiquidate > 0) {
            // Ponemos el balance del rake en 0
            await connection.query("UPDATE bank_reserves SET balance_ntx = 0 WHERE id = 1");
        }

        await connection.commit();
        res.json({ 
            message: 'Fondo del Proyecto liquidado a 0 correctamente.', 
            amount_liquidated: amountToLiquidate 
        });
    } catch (error) {
        await connection.rollback();
        console.error("Error al liquidar el fondo:", error);
        res.status(500).json({ error: 'Error al liquidar el fondo del proyecto' });
    } finally {
        connection.release();
    }
});

router.get('/admin/server-config', requireSuperAdmin, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM server_config WHERE id = 1');
        if (rows.length === 0) {
            return res.json({ discord_client_id: '', discord_client_secret: '', discord_redirect_uri: '' });
        }
        res.json(rows[0]);
    } catch (error) {
        console.error("Error al obtener config:", error);
        res.status(500).json({ error: 'Error al obtener la configuracion' });
    }
});

router.put('/admin/server-config', requireSuperAdmin, validateServerConfig, async (req, res) => {
    const { discord_client_id, discord_client_secret, discord_redirect_uri } = req.body;
    try {
        await pool.query(
            `INSERT INTO server_config (id, discord_client_id, discord_client_secret, discord_redirect_uri)
             VALUES (1, ?, ?, ?)
             ON DUPLICATE KEY UPDATE
             discord_client_id=?, discord_client_secret=?, discord_redirect_uri=?`,
            [discord_client_id, discord_client_secret, discord_redirect_uri, discord_client_id, discord_client_secret, discord_redirect_uri]
        );
        res.json({ message: 'Configuracion guardada correctamente' });
    } catch (error) {
        console.error("ERROR MYSQL AL GUARDAR CONFIG:", error);
        res.status(500).json({ error: 'Error al guardar en la base de datos' });
    }
});

router.get('/admin/smtp-config', requireSuperAdmin, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        if (rows.length === 0) {
            return res.json({ smtp_host: '', smtp_port: 587, smtp_user: '', smtp_pass: '', smtp_from_email: '', smtp_from_name: 'RoyalBET', smtp_secure: 0 });
        }
        res.json(rows[0]);
    } catch (error) {
        console.error("Error al obtener SMTP config:", error);
        res.status(500).json({ error: 'Error al obtener la configuracion SMTP' });
    }
});

router.put('/admin/smtp-config', requireSuperAdmin, validateSmtpConfig, async (req, res) => {
    const { smtp_host, smtp_port, smtp_user, smtp_pass, smtp_from_email, smtp_from_name, smtp_secure } = req.body;
    try {
        await pool.query(
            `INSERT INTO smtp_config (id, smtp_host, smtp_port, smtp_user, smtp_pass, smtp_from_email, smtp_from_name, smtp_secure)
             VALUES (1, ?, ?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE smtp_host=?, smtp_port=?, smtp_user=?, smtp_pass=?, smtp_from_email=?, smtp_from_name=?, smtp_secure=?`,
            [smtp_host, smtp_port, smtp_user, smtp_pass, smtp_from_email, smtp_from_name, smtp_secure ? 1 : 0,
             smtp_host, smtp_port, smtp_user, smtp_pass, smtp_from_email, smtp_from_name, smtp_secure ? 1 : 0]
        );
        res.json({ message: 'Configuracion SMTP guardada correctamente' });
    } catch (error) {
        console.error("Error al guardar SMTP:", error);
        res.status(500).json({ error: 'Error al guardar la configuracion SMTP' });
    }
});

router.post('/admin/smtp-test', requireSuperAdmin, validateSmtpTest, async (req, res) => {
    const { test_email } = req.body;
    if (!test_email) return res.status(400).json({ error: 'Debes proporcionar un correo de destino para la prueba' });

    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        const config = rows[0];
        if (!config || !config.smtp_host) {
            return res.status(400).json({ error: 'Primero debes guardar la configuracion SMTP' });
        }

        const transporter = nodemailer.createTransport({
            host: config.smtp_host,
            port: config.smtp_port,
            secure: config.smtp_secure === 1,
            auth: { user: config.smtp_user, pass: config.smtp_pass },
            tls: { rejectUnauthorized: false },
            connectionTimeout: 10000
        });

        await transporter.sendMail({
            from: `"${config.smtp_from_name}" <${config.smtp_from_email}>`,
            to: test_email,
            subject: 'Prueba de Servidor de Correos - RoyalBET',
            text: 'Este es un mensaje de prueba. Si recibes este correo, tu configuracion SMTP es correcta.',
            html: '<h3>?Hola!</h3><p>Este es un correo de prueba enviado desde <b>RoyalBET</b>.</p><p>Si est芍s viendo esto, tu configuraci車n SMTP est芍 funcionando perfectamente.</p>'
        });

        res.json({ message: 'Correo de prueba enviado exitosamente. Revisa tu bandeja de entrada.' });
    } catch (error) {
        console.error("Error al enviar correo de prueba:", error);
        res.status(500).json({ error: `Error: ${error.message || 'Error desconocido al conectar con el servidor SMTP'}` });
    }
});

// ==========================================
// ?? NUEVA RUTA: ANUNCIOS GLOBALES
// ==========================================
router.post('/admin/announcements', requireSuperAdmin, validateAnnouncement, async (req, res) => {
    const { title, message, sendToWeb, sendToEmail } = req.body;

    if (!title || !message) {
        return res.status(400).json({ error: 'El t赤tulo y el mensaje son obligatorios' });
    }
    if (!sendToWeb && !sendToEmail) {
        return res.status(400).json({ error: 'Debes seleccionar al menos un m谷todo de env赤o' });
    }

    try {
        // 1. Obtener todos los usuarios registrados
        const [users] = await pool.query("SELECT id, email, username FROM users");
        if (users.length === 0) {
            return res.status(400).json({ error: 'No hay usuarios registrados en el sistema' });
        }

        // 2. Enviar al Buz車n Web (usando tu funci車n crearNotificacion)
        if (sendToWeb) {
            for (const user of users) {
                await crearNotificacion(
                    user.id,
                    title,
                    message,
                    'announcement',
                    {} // Sin metadata extra
                );
            }
        }

        // 3. Enviar por Correo Electr車nico
        if (sendToEmail) {
            const [smtpRows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
            const smtpConfig = smtpRows[0];

            if (!smtpConfig || !smtpConfig.smtp_host) {
                return res.status(400).json({ error: 'Configuraci車n SMTP no encontrada. No se pudieron enviar los correos.' });
            }

            const transporter = nodemailer.createTransport({
                host: smtpConfig.smtp_host,
                port: smtpConfig.smtp_port,
                secure: smtpConfig.smtp_secure === 1,
                auth: { user: smtpConfig.smtp_user, pass: smtpConfig.smtp_pass },
                tls: { rejectUnauthorized: false }
            });

            // Enviamos los correos en segundo plano para no bloquear la petici車n HTTP
            (async () => {
                for (const user of users) {
                    if (user.email) {
                        try {
                            await transporter.sendMail({
                                from: `"${smtpConfig.smtp_from_name}" <${smtpConfig.smtp_from_email}>`,
                                to: user.email,
                                subject: title,
                                text: message,
                                html: `
                                    <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f9f9f9; color: #333;">
                                        <h2 style="color: #00e676;">${title}</h2>
                                        <p style="font-size: 16px; line-height: 1.5;">${message.replace(/\n/g, '<br>')}</p>
                                        <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                                        <p style="color: #888; font-size: 12px;">Este es un mensaje autom芍tico de RoyalBET. Por favor no respondas a este correo.</p>
                                    </div>
                                `
                            });
                        } catch (err) {
                            console.error(`Error enviando correo a ${user.email}:`, err.message);
                        }
                    }
                }
                console.log(`[Admin] Correos de anuncio enviados a ${users.length} usuarios.`);
            })();
        }

        res.json({ message: 'Anuncio enviado a todos los usuarios correctamente.' });
    } catch (error) {
        console.error("Error al enviar anuncio:", error);
        res.status(500).json({ error: 'Error interno al procesar el anuncio' });
    }
});

// ==========================================
// ?? NUEVAS RUTAS PARA GESTI車N DE JUGADORES
// ==========================================

router.get('/admin/users', async (req, res) => {
    try {
        const [users] = await pool.query(`
            SELECT u.id, u.username, u.email, u.phone, u.role, u.created_at, u.is_blocked,
                   COALESCE(w.balance_ntx, 0) as balance
            FROM users u
            LEFT JOIN wallets w ON u.id = w.user_id
            ORDER BY u.created_at DESC
        `);
        res.json(users);
    } catch (error) {
        console.error("Error al obtener usuarios:", error);
        res.status(500).json({ error: 'Error al obtener la lista de jugadores' });
    }
});

router.post('/admin/users/:id/toggle-block', validateIdParam, async (req, res) => {
    const userId = req.params.id;
    try {
        if (Number(userId) === req.user.id) {
            return res.status(400).json({ error: 'No puedes bloquearte a ti mismo' });
        }

        const [users] = await pool.query("SELECT is_blocked, role FROM users WHERE id = ?", [userId]);
        if (users.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
        
        if (users[0].role === 'superadmin') {
            return res.status(403).json({ error: 'No puedes bloquear a otro superadmin' });
        }

        const newStatus = users[0].is_blocked === 1 ? 0 : 1;
        await pool.query("UPDATE users SET is_blocked = ? WHERE id = ?", [newStatus, userId]);

        res.json({ 
            message: newStatus === 1 ? 'Jugador bloqueado correctamente' : 'Jugador desbloqueado correctamente', 
            is_blocked: newStatus 
        });
    } catch (error) {
        console.error("Error al cambiar estado del jugador:", error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.delete('/admin/users/:id', validateIdParam, async (req, res) => {
    const userId = req.params.id;
    const connection = await pool.getConnection();
    
    try {
        if (Number(userId) === req.user.id) {
            return res.status(400).json({ error: 'No puedes eliminar tu propia cuenta' });
        }

        const [users] = await connection.query("SELECT role FROM users WHERE id = ?", [userId]);
        if (users.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
        if (users[0].role === 'superadmin') return res.status(403).json({ error: 'No puedes eliminar a un superadmin' });

        await connection.beginTransaction();
        
        await connection.query("DELETE FROM wallets WHERE user_id = ?", [userId]);
        await connection.query("DELETE FROM users WHERE id = ?", [userId]);
        
        await connection.commit();
        res.json({ message: 'Cuenta de jugador eliminada permanentemente' });
    } catch (error) {
        await connection.rollback();
        console.error("Error al eliminar jugador:", error);
        res.status(500).json({ error: 'Error al eliminar la cuenta' });
    } finally {
        connection.release();
    }
});

module.exports = router;