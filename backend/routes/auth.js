const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const fetch = require('node-fetch');

const pool = require('../db');
const { JWT_SECRET, FRONTEND_URL } = require('../config');
const { verifyToken, registerSession, invalidateSession } = require('../middlewares/auth');
const { getClientIp } = require('../utils/ip');
const { enviarCorreoVerificacion, enviarCorreoRecuperacion } = require('../utils/email');
// ===========================================================
// VALIDADOR
// ===========================================================
const { validateRegister, validateLogin, validateSetEmail, validateLoginCode } = require('../middlewares/validators');

// ?? NUEVO: Funci車n para generar un ID 迆nico de 6 d赤gitos
async function generateUniqueId() {
    let uniqueId;
    let isUnique = false;
    while (!isUnique) {
        // Genera un n迆mero entre 100000 y 999999
        uniqueId = Math.floor(100000 + Math.random() * 900000).toString();
        const [rows] = await pool.query('SELECT id FROM users WHERE unique_id = ?', [uniqueId]);
        if (rows.length === 0) {
            isUnique = true;
        }
    }
    return uniqueId;
}

router.post('/register', validateRegister, async (req, res) => {
    const { username, email, phone, password, referred_by } = req.body;
    if (!username || !password) return res.status(400).json({ error: 'Usuario y contrasena obligatorios' });
    try {
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(password, salt);
        
        // ?? NUEVO: Generamos el unique_id antes de insertar
        const uniqueId = await generateUniqueId();

        // ?? MODIFICADO: Agregamos unique_id a la consulta INSERT
        const [result] = await pool.query(
            'INSERT INTO users (username, email, phone, password_hash, referred_by, unique_id) VALUES (?, ?, ?, ?, ?, ?)',
            [username, email || null, phone || null, passwordHash, referred_by || null, uniqueId]
        );
        // ?? Los usuarios nuevos empiezan con 0 fichas
        await pool.query('INSERT INTO wallets (user_id, balance_ntx) VALUES (?, 0)', [result.insertId]);
        res.status(201).json({ message: 'Usuario registrado correctamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'El usuario o correo ya existe' });
    }
});

router.post('/login', validateLogin, async (req, res) => {
    const { identifier, password } = req.body;
    try {
        const [users] = await pool.query(
            'SELECT * FROM users WHERE username = ? OR email = ? OR phone = ?',
            [identifier, identifier, identifier]
        );
        if (users.length === 0) return res.status(401).json({ error: 'Credenciales invalidas' });

        const user = users[0];
        const validPassword = await bcrypt.compare(password, user.password_hash);
        if (!validPassword) return res.status(401).json({ error: 'Contrasena incorrecta' });

        // ?? NUEVA VALIDACI車N: Cuenta bloqueada
        if (user.is_blocked === 1) {
            return res.status(403).json({ error: 'Tu cuenta ha sido bloqueada por un administrador. Contacta a soporte.' });
        }

        if (!user.email) {
            const tempToken = jwt.sign({ id: user.id, action: 'set_email' }, JWT_SECRET, { expiresIn: '15m' });
            return res.json({
                requires_email: true,
                temp_token: tempToken,
                message: 'Para mayor seguridad, debes configurar un correo electr車nico antes de ingresar al casino. As赤 podr芍s recuperar tu cuenta si cambias de IP.'
            });
        }

        const clientIp = getClientIp(req);

        const [trustedIps] = await pool.query(
            'SELECT ip_address FROM user_trusted_ips WHERE user_id = ? ORDER BY last_used_at DESC LIMIT 2',
            [user.id]
        );

        let requiresVerification = false;
        if (trustedIps.length > 0) {
            const isKnownIp = trustedIps.some(row => row.ip_address === clientIp);
            if (!isKnownIp) requiresVerification = true;
        }

        if (requiresVerification) {
            const code = Math.floor(100000 + Math.random() * 900000).toString();
            const expiresAt = new Date();
            expiresAt.setMinutes(expiresAt.getMinutes() + 15);

            await pool.query('DELETE FROM user_verification_codes WHERE user_id = ?', [user.id]);
            await pool.query(
                'INSERT INTO user_verification_codes (user_id, code, ip_address, expires_at) VALUES (?, ?, ?, ?)',
                [user.id, code, clientIp, expiresAt]
            );

            if (user.email) {
                const enviado = await enviarCorreoVerificacion(user.email, code);
                if (!enviado) return res.status(500).json({ error: 'No se pudo enviar el correo. Contacta al administrador.' });
            } else {
                return res.status(400).json({ error: 'No tienes un correo registrado para verificar tu identidad. Ve a tu perfil y agrega uno.' });
            }

            return res.json({
                requires_verification: true,
                email: user.email,
                message: 'Hemos enviado un c車digo de verificaci車n a tu correo debido a un inicio de sesi車n desde una ubicaci車n desconocida.'
            });
        }

        try {
            const [existingIp] = await pool.query(
                'SELECT id FROM user_trusted_ips WHERE user_id = ? AND ip_address = ?',
                [user.id, clientIp]
            );
            if (existingIp.length === 0) {
                await pool.query('INSERT INTO user_trusted_ips (user_id, ip_address) VALUES (?, ?)', [user.id, clientIp]);
            } else {
                await pool.query('UPDATE user_trusted_ips SET last_used_at = CURRENT_TIMESTAMP WHERE user_id = ? AND ip_address = ?', [user.id, clientIp]);
            }
        } catch (ipError) {
            console.error('Error al registrar IP:', ipError);
        }

        const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
		await registerSession(user.id, token);

        res.json({
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                phone: user.phone,
                role: user.role,
                discord_id: user.discord_id, // ?? AGREGADO
                unique_id: user.unique_id,   // ?? NUEVO: Enviamos el ID 迆nico al Frontend
                has_pin: user.pay_pin ? true : false,
                pin_enabled: user.pay_pin_enabled
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

router.post('/auth/set-email', validateSetEmail, async (req, res) => {
    const { email, temp_token } = req.body;
    if (!email || !temp_token) return res.status(400).json({ error: 'Faltan datos' });

    try {
        const decoded = jwt.verify(temp_token, JWT_SECRET);
        if (decoded.action !== 'set_email') return res.status(401).json({ error: 'Token inv芍lido' });

        const [existing] = await pool.query('SELECT id FROM users WHERE email = ? AND id != ?', [email, decoded.id]);
        if (existing.length > 0) return res.status(400).json({ error: 'Este correo ya est芍 en uso por otro usuario.' });

        await pool.query('UPDATE users SET email = ? WHERE id = ?', [email, decoded.id]);

        const [users] = await pool.query('SELECT * FROM users WHERE id = ?', [decoded.id]);
        const user = users[0];

        const clientIp = getClientIp(req);
        try {
            const [existingIp] = await pool.query('SELECT id FROM user_trusted_ips WHERE user_id = ? AND ip_address = ?', [user.id, clientIp]);
            if (existingIp.length === 0) await pool.query('INSERT INTO user_trusted_ips (user_id, ip_address) VALUES (?, ?)', [user.id, clientIp]);
            else await pool.query('UPDATE user_trusted_ips SET last_used_at = CURRENT_TIMESTAMP WHERE user_id = ? AND ip_address = ?', [user.id, clientIp]);
        } catch (e) { console.error('Error IP', e); }

        const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
        await registerSession(user.id, token);

        res.json({
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                phone: user.phone,
                role: user.role,
                discord_id: user.discord_id, // ?? AGREGADO
                unique_id: user.unique_id,   // ?? NUEVO: Enviamos el ID 迆nico al Frontend
                has_pin: user.pay_pin ? true : false,
                pin_enabled: user.pay_pin_enabled
            }
        });
    } catch (error) {
        res.status(401).json({ error: 'Sesi車n expirada o inv芍lida. Vuelve a iniciar sesi車n.' });
    }
});

router.post('/verify-login-code', validateLoginCode, async (req, res) => {
    const { identifier, code } = req.body;
    if (!identifier || !code) return res.status(400).json({ error: 'Faltan datos' });

    try {
        const [users] = await pool.query(
            'SELECT * FROM users WHERE username = ? OR email = ? OR phone = ?',
            [identifier, identifier, identifier]
        );
        if (users.length === 0) return res.status(401).json({ error: 'Usuario no encontrado' });

        const user = users[0];

        // ?? NUEVA VALIDACI車N: Cuenta bloqueada
        if (user.is_blocked === 1) {
            return res.status(403).json({ error: 'Tu cuenta ha sido bloqueada por un administrador. Contacta a soporte.' });
        }

        const clientIp = getClientIp(req);

        const [codes] = await pool.query(
            'SELECT * FROM user_verification_codes WHERE user_id = ? AND code = ? AND expires_at > NOW()',
            [user.id, code]
        );

        if (codes.length === 0) return res.status(400).json({ error: 'C車digo incorrecto o expirado.' });

        await pool.query('DELETE FROM user_verification_codes WHERE user_id = ?', [user.id]);

        const [existingIp] = await pool.query(
            'SELECT id FROM user_trusted_ips WHERE user_id = ? AND ip_address = ?',
            [user.id, clientIp]
        );
        if (existingIp.length === 0) {
            await pool.query('INSERT INTO user_trusted_ips (user_id, ip_address) VALUES (?, ?)', [user.id, clientIp]);
        } else {
            await pool.query('UPDATE user_trusted_ips SET last_used_at = CURRENT_TIMESTAMP WHERE user_id = ? AND ip_address = ?', [user.id, clientIp]);
        }

        const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
        await registerSession(user.id, token);

        res.json({
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                phone: user.phone,
                role: user.role,
                discord_id: user.discord_id, // ?? AGREGADO
                unique_id: user.unique_id,   // ?? NUEVO: Enviamos el ID 迆nico al Frontend
                has_pin: user.pay_pin ? true : false,
                pin_enabled: user.pay_pin_enabled
            }
        });
    } catch (error) {
        console.error("Error al verificar c車digo:", error);
        res.status(500).json({ error: 'Error al verificar el c車digo' });
    }
});

router.get('/verify-session', verifyToken, (req, res) => {
    res.json({ valid: true });
});

router.post('/logout', verifyToken, async (req, res) => {
    try {
        await invalidateSession(req.user.id);
        res.json({ message: 'Sesion cerrada correctamente' });
    } catch (error) {
        console.error('Error al cerrar sesion:', error);
        res.status(500).json({ error: 'Error al cerrar sesion' });
    }
});

// ?? NUEVO (Paso 4.4): Solicitar c車digo de recuperaci車n
router.post('/auth/forgot-password', async (req, res) => {
    const { identifier } = req.body;
    if (!identifier) return res.status(400).json({ error: 'Debes ingresar tu usuario o correo' });

    try {
        const [users] = await pool.query(
            'SELECT id, email FROM users WHERE username = ? OR email = ?',
            [identifier, identifier]
        );

        // Por seguridad, respondemos OK aunque no exista el usuario
        // (as赤 nadie puede "adivinar" qu谷 correos o usuarios existen)
        if (users.length === 0 || !users[0].email) {
            return res.json({ message: 'Si el usuario existe y tiene correo registrado, recibir芍s un c車digo en breve.' });
        }

        const user = users[0];
        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + 15);

        await pool.query('DELETE FROM password_reset_codes WHERE user_id = ?', [user.id]);
        await pool.query(
            'INSERT INTO password_reset_codes (user_id, code, expires_at) VALUES (?, ?, ?)',
            [user.id, code, expiresAt]
        );

        const enviado = await enviarCorreoRecuperacion(user.email, code);
        if (!enviado) {
            await pool.query('DELETE FROM password_reset_codes WHERE user_id = ? AND code = ?', [user.id, code]);
            return res.status(500).json({ error: 'No se pudo enviar el correo. Contacta al administrador.' });
        }

        const maskedEmail = user.email.replace(/(.{2}).+(@.+)/, '$1***$2');
        res.json({
            message: `Hemos enviado un c車digo de recuperaci車n a ${maskedEmail}.`,
            email: maskedEmail
        });
    } catch (error) {
        console.error("Error al procesar forgot-password:", error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// ?? NUEVO (Paso 4.4): Restablecer contrase?a con el c車digo
router.post('/auth/reset-password', async (req, res) => {
    const { identifier, code, newPassword } = req.body;
    if (!identifier || !code || !newPassword) {
        return res.status(400).json({ error: 'Faltan datos (usuario, c車digo y nueva contrase?a)' });
    }
    if (newPassword.length < 6) {
        return res.status(400).json({ error: 'La contrase?a debe tener al menos 6 caracteres' });
    }

    try {
        const [users] = await pool.query(
            'SELECT id FROM users WHERE username = ? OR email = ?',
            [identifier, identifier]
        );
        if (users.length === 0) return res.status(400).json({ error: 'C車digo incorrecto o expirado' });

        const user = users[0];

        const [codes] = await pool.query(
            'SELECT * FROM password_reset_codes WHERE user_id = ? AND code = ? AND used = 0 AND expires_at > NOW()',
            [user.id, code]
        );
        if (codes.length === 0) {
            return res.status(400).json({ error: 'C車digo incorrecto o expirado' });
        }

        const salt = await bcrypt.genSalt(10);
        const newHash = await bcrypt.hash(newPassword, salt);

        await pool.query('UPDATE users SET password_hash = ? WHERE id = ?', [newHash, user.id]);
        await pool.query('UPDATE password_reset_codes SET used = 1 WHERE user_id = ?', [user.id]);

        // Cerrar sesiones activas (obliga a loguearse de nuevo en cualquier dispositivo)
        await invalidateSession(user.id);

        res.json({ message: 'Contrase?a actualizada correctamente. Ya puedes iniciar sesi車n.' });
    } catch (error) {
        console.error("Error al reset-password:", error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// ?? MODIFICADO: Acepta link_token para vincular cuenta existente
router.get('/auth/discord', async (req, res) => {
    try {
        const [configs] = await pool.query('SELECT discord_client_id, discord_redirect_uri FROM server_config WHERE id = 1');
        if (configs.length === 0 || !configs[0].discord_client_id) {
            return res.status(400).send('El administrador no ha configurado Discord todavia.');
        }

        const { discord_client_id, discord_redirect_uri } = configs[0];
        
        // ?? Si viene link_token, lo pasamos como state para saber que es vinculaci車n
        const linkToken = req.query.link_token || '';
        const stateParam = linkToken ? `&state=${linkToken}` : '';
        
        const discordAuthUrl = `https://discord.com/api/oauth2/authorize?client_id=${discord_client_id}&redirect_uri=${encodeURIComponent(discord_redirect_uri)}&response_type=code&scope=identify${stateParam}`;
        res.redirect(discordAuthUrl);
    } catch (error) {
        console.error(error);
        res.status(500).send('Error al iniciar sesion con Discord');
    }
});

// ?? MODIFICADO: Detecta el state para saber si es vinculaci車n o login normal
router.get('/auth/discord/callback', async (req, res) => {
    const { code, state } = req.query;
    if (!code) return res.status(400).send('No se recibio el codigo de Discord');

    try {
        const [configs] = await pool.query('SELECT * FROM server_config WHERE id = 1');
        if (configs.length === 0) return res.status(500).send('Configuracion de Discord perdida');

        const config = configs[0];

        const params = new URLSearchParams({
            client_id: config.discord_client_id,
            client_secret: config.discord_client_secret,
            grant_type: 'authorization_code',
            code: code,
            redirect_uri: config.discord_redirect_uri
        });

        const tokenResponse = await fetch('https://discord.com/api/oauth2/token', {
            method: 'POST',
            body: params,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });

        const tokenData = await tokenResponse.json();
        if (tokenData.error) throw new Error('Error al obtener el token de Discord');

        const userResponse = await fetch('https://discord.com/api/users/@me', {
            headers: { Authorization: `Bearer ${tokenData.access_token}` }
        });
        const discordUser = await userResponse.json();

        // ?? SI HAY STATE, ES UNA VINCULACI車N, NO UN LOGIN
        if (state && state.length > 10) {
            try {
                const decoded = jwt.verify(state, JWT_SECRET);
                await pool.query('UPDATE users SET discord_id = ? WHERE id = ?', [discordUser.id, decoded.id]);
                return res.redirect(`${FRONTEND_URL}/?discord_linked=true`);
            } catch (e) {
                return res.redirect(`${FRONTEND_URL}/?discord_error=true`);
            }
        }

        // LOGIN NORMAL CON DISCORD
        const [users] = await pool.query('SELECT * FROM users WHERE discord_id = ?', [discordUser.id]);

        let user;
        if (users.length > 0) {
            user = users[0];
            // ?? NUEVA VALIDACI車N: Cuenta bloqueada
            if (user.is_blocked === 1) {
                return res.status(403).send('Tu cuenta ha sido bloqueada por un administrador. Contacta a soporte.');
            }
        } else {
            const dummyPassword = await bcrypt.hash(Math.random().toString(36).slice(-8), 10);
            const generatedUsername = discordUser.username + Math.floor(Math.random() * 1000);
            
            // ?? NUEVO: Generamos el unique_id para el nuevo usuario de Discord
            const uniqueId = await generateUniqueId();

            // ?? MODIFICADO: Agregamos unique_id a la consulta INSERT
            const [insertResult] = await pool.query(
                'INSERT INTO users (username, email, phone, password_hash, discord_id, unique_id) VALUES (?, ?, ?, ?, ?, ?)',
                [generatedUsername, null, null, dummyPassword, discordUser.id, uniqueId]
            );
            // ?? Los usuarios nuevos de Discord tambi谷n empiezan con 0 fichas
            await pool.query('INSERT INTO wallets (user_id, balance_ntx) VALUES (?, 0)', [insertResult.insertId]);

            user = { id: insertResult.insertId, username: generatedUsername, role: 'user' };
        }

        const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
        await registerSession(user.id, token);

        res.redirect(`${FRONTEND_URL}/?discord_token=${token}`);
    } catch (error) {
        console.error("ERROR EN DISCORD CALLBACK:", error);
        res.status(500).send(`Error interno: ${error.message}`);
    }
});

module.exports = router;