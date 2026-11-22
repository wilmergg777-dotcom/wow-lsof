const nodemailer = require('nodemailer');
const pool = require('../db');

async function enviarCorreoVerificacion(emailDestino, codigo) {
    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        const config = rows[0];
        if (!config || !config.smtp_host) throw new Error('El administrador no ha configurado el servidor SMTP.');

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
            to: emailDestino,
            subject: 'Código de Verificación - RoyalBET',
            html: `
                <div style="font-family: Arial, sans-serif; background-color: #0a0a0a; color: #fff; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #00e676; text-align: center;">RoyalBET</h2>
                    <p>Hemos detectado un inicio de sesión desde una ubicación desconocida.</p>
                    <p>Tu código de verificación es:</p>
                    <h1 style="text-align: center; letter-spacing: 5px; color: #e2b04a; background: #121212; padding: 15px; border-radius: 8px;">${codigo}</h1>
                    <p>Este código expirará en 15 minutos.</p>
                    <p>Si no fuiste tú, por favor cambia tu contraseña inmediatamente.</p>
                </div>
            `
        });
        return true;
    } catch (error) {
        console.error("Error al enviar correo de verificación:", error);
        return false;
    }
}

// 🔥 Código de verificación para retiros
async function enviarCodigoRetiro(emailDestino, codigo, amount, bankName) {
    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        const config = rows[0];
        if (!config || !config.smtp_host) throw new Error('El administrador no ha configurado el servidor SMTP.');

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
            to: emailDestino,
            subject: 'Código de Verificación de Retiro - RoyalBET',
            html: `
                <div style="font-family: Arial, sans-serif; background-color: #0a0a0a; color: #fff; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #00e676; text-align: center;">RoyalBET</h2>
                    <p>Has solicitado un retiro de <strong style="color: #e2b04a;">${amount} NTX</strong> hacia tu cuenta de <strong>${bankName}</strong>.</p>
                    <p>Para confirmar la operación, ingresa el siguiente código:</p>
                    <h1 style="text-align: center; letter-spacing: 5px; color: #e2b04a; background: #121212; padding: 15px; border-radius: 8px;">${codigo}</h1>
                    <p>Este código expirará en 15 minutos.</p>
                    <p>Si no fuiste tú, por favor ignora este correo y cambia tu PIN de seguridad inmediatamente.</p>
                </div>
            `
        });
        return true;
    } catch (error) {
        console.error("Error al enviar correo de retiro:", error);
        return false;
    }
}

// 🔥 Retiro aprobado
async function enviarCorreoRetiroAprobado(emailDestino, amount, bankName) {
    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        const config = rows[0];
        if (!config || !config.smtp_host) throw new Error('El administrador no ha configurado el servidor SMTP.');

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
            to: emailDestino,
            subject: '✅ Retiro aprobado - RoyalBET',
            html: `
                <div style="font-family: Arial, sans-serif; background-color: #0a0a0a; color: #fff; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #00e676; text-align: center;">RoyalBET</h2>
                    <p>¡Buenas noticias!</p>
                    <p>Tu retiro de <strong style="color: #e2b04a;">${amount} NTX</strong> hacia tu cuenta de <strong>${bankName}</strong> ha sido <strong style="color: #00e676;">aprobado y procesado</strong>.</p>
                    <p>El dinero será transferido a tu cuenta bancaria en las próximas horas.</p>
                    <p>Gracias por jugar en RoyalBET.</p>
                </div>
            `
        });
        return true;
    } catch (error) {
        console.error("Error al enviar correo de retiro aprobado:", error);
        return false;
    }
}

// 🔥 Retiro rechazado
async function enviarCorreoRetiroRechazado(emailDestino, amount) {
    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        const config = rows[0];
        if (!config || !config.smtp_host) throw new Error('El administrador no ha configurado el servidor SMTP.');

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
            to: emailDestino,
            subject: '❌ Retiro rechazado - RoyalBET',
            html: `
                <div style="font-family: Arial, sans-serif; background-color: #0a0a0a; color: #fff; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #00e676; text-align: center;">RoyalBET</h2>
                    <p>Tu solicitud de retiro de <strong style="color: #e2b04a;">${amount} NTX</strong> ha sido <strong style="color: #ef4444;">rechazada</strong>.</p>
                    <p>El saldo fue devuelto automáticamente a tu billetera.</p>
                    <p>Si tienes dudas, contacta al administrador.</p>
                </div>
            `
        });
        return true;
    } catch (error) {
        console.error("Error al enviar correo de retiro rechazado:", error);
        return false;
    }
}

// 🔥 Depósito aprobado
async function enviarCorreoDepositoAprobado(emailDestino, amountCup, amountNtx) {
    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        const config = rows[0];
        if (!config || !config.smtp_host) throw new Error('El administrador no ha configurado el servidor SMTP.');

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
            to: emailDestino,
            subject: '✅ Depósito acreditado - RoyalBET',
            html: `
                <div style="font-family: Arial, sans-serif; background-color: #0a0a0a; color: #fff; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #00e676; text-align: center;">RoyalBET</h2>
                    <p>Tu depósito de <strong style="color: #e2b04a;">${amountCup} CUP</strong> ha sido <strong style="color: #00e676;">verificado y aprobado</strong>.</p>
                    <p>Se acreditaron <strong style="color: #00e676;">${amountNtx} NTX</strong> a tu billetera.</p>
                    <p>Ya puedes usar tus fichas para jugar.</p>
                </div>
            `
        });
        return true;
    } catch (error) {
        console.error("Error al enviar correo de depósito aprobado:", error);
        return false;
    }
}

// 🔥 NUEVO (Paso 4.4): Recuperación de contraseña
async function enviarCorreoRecuperacion(emailDestino, codigo) {
    try {
        const [rows] = await pool.query('SELECT * FROM smtp_config WHERE id = 1');
        const config = rows[0];
        if (!config || !config.smtp_host) throw new Error('El administrador no ha configurado el servidor SMTP.');

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
            to: emailDestino,
            subject: '🔐 Recuperación de contraseña - RoyalBET',
            html: `
                <div style="font-family: Arial, sans-serif; background-color: #0a0a0a; color: #fff; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #00e676; text-align: center;">RoyalBET</h2>
                    <p>Has solicitado restablecer tu contraseña.</p>
                    <p>Tu código de recuperación es:</p>
                    <h1 style="text-align: center; letter-spacing: 5px; color: #e2b04a; background: #121212; padding: 15px; border-radius: 8px;">${codigo}</h1>
                    <p>Este código expirará en 15 minutos y solo puede usarse una vez.</p>
                    <p>Si no fuiste tú, ignora este correo. Tu contraseña actual no cambiará.</p>
                </div>
            `
        });
        return true;
    } catch (error) {
        console.error("Error al enviar correo de recuperación:", error);
        return false;
    }
}

module.exports = {
    enviarCorreoVerificacion,
    enviarCodigoRetiro,
    enviarCorreoRetiroAprobado,
    enviarCorreoRetiroRechazado,
    enviarCorreoDepositoAprobado,
    enviarCorreoRecuperacion
};