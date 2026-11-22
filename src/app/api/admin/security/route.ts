// ============================================================
// SEGURIDAD DEL SISTEMA (SOLO el dueño de la web: súper admin)
// GET  /api/admin/security -> estado de los canales (tokens y
//      claves SIEMPRE enmascarados), registro de eventos,
//      bandeja de salida y cuentas bloqueadas.
// POST /api/admin/security -> guarda o borra la configuración:
//      { botToken }                    -> bot de Telegram
//      { resendApiKey, emailFrom }     -> correo electrónico
//      { smsApiUrl, smsApiKey }        -> pasarela SMS
//      { action: 'clear_email'|'clear_sms'|'clear_bot' }
// Parches: sin sesión de administrador NADIE ve ni cambia nada.
// Los valores guardados jamás se devuelven completos.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getClientIp, logSecurityEvent, clip } from '@/lib/security'
import { requireAdmin } from '@/lib/session'
import {
  getBotToken,
  getBotUsername,
  getEmailConfig,
  getSmsConfig,
} from '@/lib/notify'

// Enmascara una clave para mostrarla: nadie debería verla completa
function maskKey(key: string) {
  if (key.length <= 12) return '••••••••'
  return `${key.slice(0, 4)}••••••••${key.slice(-4)}`
}

// ¿De dónde sale la configuración? (panel del dueño o variables del servidor)
async function configSource(keys: string[]): Promise<'panel' | 'servidor' | null> {
  const rows = await db.systemConfig.findMany({
    where: { key: { in: keys } },
  })
  return rows.some((r) => r.value) ? 'panel' : null
}

export async function GET(req: Request) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Solo el dueño de la web puede ver la seguridad del sistema' },
      { status: 403 }
    )
  }

  const [token, botUsername, email, sms, events, outbox, lockedUsers] = await Promise.all([
    getBotToken(),
    getBotUsername(),
    getEmailConfig(),
    getSmsConfig(),
    db.securityEvent.findMany({ orderBy: { createdAt: 'desc' }, take: 40 }),
    db.outboxMessage.findMany({ orderBy: { createdAt: 'desc' }, take: 40 }),
    db.user.findMany({
      where: { lockedUntil: { gt: new Date() } },
      select: { name: true, lockedUntil: true },
    }),
  ])

  const [emailSource, smsSource, botSource] = await Promise.all([
    configSource(['resend_api_key']),
    configSource(['sms_api_url']),
    configSource(['telegram_bot_token']),
  ])

  return NextResponse.json({
    telegram: {
      configured: Boolean(token),
      maskedToken: token ? maskKey(token) : null,
      botUsername: botUsername || null,
      source: token ? (botSource === 'panel' ? 'panel' : 'servidor') : null,
    },
    email: {
      configured: Boolean(email.key),
      maskedKey: email.key ? maskKey(email.key) : null,
      from: email.key ? email.from : null,
      source: email.key ? (emailSource === 'panel' ? 'panel' : 'servidor') : null,
    },
    sms: {
      configured: Boolean(sms.url),
      maskedUrl: sms.url,
      maskedKey: sms.key ? maskKey(sms.key) : null,
      source: sms.url ? (smsSource === 'panel' ? 'panel' : 'servidor') : null,
    },
    channels: {
      email: Boolean(email.key),
      sms: Boolean(sms.url),
      telegram: Boolean(token),
    },
    events,
    outbox: outbox.map((o) => ({ ...o, body: o.body.slice(0, 140) })),
    lockedUsers,
  })
}

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Solo el dueño de la web puede cambiar la seguridad del sistema' },
      { status: 403 }
    )
  }

  const body = await req.json().catch(() => ({}))

  // ---------- Borrar configuraciones ----------
  if (body.action === 'clear_email') {
    await db.systemConfig.deleteMany({ where: { key: { in: ['resend_api_key', 'email_from'] } } })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'security_config',
      detail: 'Desconectó el envío de correo electrónico',
      ip,
    })
    return NextResponse.json({ ok: true, message: 'Envío de correo desconectado.' })
  }
  if (body.action === 'clear_sms') {
    await db.systemConfig.deleteMany({ where: { key: { in: ['sms_api_url', 'sms_api_key'] } } })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'security_config',
      detail: 'Desconectó el envío de SMS',
      ip,
    })
    return NextResponse.json({ ok: true, message: 'Envío de SMS desconectado.' })
  }
  if (body.action === 'clear_bot' || (body.botToken !== undefined && !String(body.botToken).trim())) {
    await db.systemConfig.deleteMany({
      where: { key: { in: ['telegram_bot_token', 'telegram_bot_username'] } },
    })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'security_config',
      detail: 'Desconectó el bot de Telegram',
      ip,
    })
    return NextResponse.json({ ok: true, message: 'Bot de Telegram desconectado.' })
  }

  // ---------- Correo electrónico (Resend) ----------
  if (body.resendApiKey !== undefined) {
    const key = clip(body.resendApiKey, 200)
    const from = clip(body.emailFrom, 120)
    if (!key) {
      return NextResponse.json({ error: 'Pega la clave de API de Resend (empieza por "re_")' }, { status: 400 })
    }
    if (from && !from.includes('@')) {
      return NextResponse.json(
        { error: 'El remitente debe ser un correo válido, ej: Violetero <tienda@violetero.cu>' },
        { status: 400 }
      )
    }
    await db.systemConfig.upsert({
      where: { key: 'resend_api_key' },
      create: { key: 'resend_api_key', value: key },
      update: { value: key },
    })
    if (from) {
      await db.systemConfig.upsert({
        where: { key: 'email_from' },
        create: { key: 'email_from', value: from },
        update: { value: from },
      })
    }
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'security_config',
      detail: `Guardó la configuración del correo electrónico (${maskKey(key)})`,
      ip,
    })
    return NextResponse.json({
      ok: true,
      message: 'Correo electrónico conectado. Los códigos ya pueden llegar por correo.',
    })
  }

  // ---------- Pasarela SMS ----------
  if (body.smsApiUrl !== undefined) {
    const url = clip(body.smsApiUrl, 300)
    const key = clip(body.smsApiKey, 200)
    if (!/^https?:\/\/.+/i.test(url)) {
      return NextResponse.json(
        { error: 'La dirección del servicio SMS debe empezar por http:// o https://' },
        { status: 400 }
      )
    }
    await db.systemConfig.upsert({
      where: { key: 'sms_api_url' },
      create: { key: 'sms_api_url', value: url },
      update: { value: url },
    })
    if (key) {
      await db.systemConfig.upsert({
        where: { key: 'sms_api_key' },
        create: { key: 'sms_api_key', value: key },
        update: { value: key },
      })
    }
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'security_config',
      detail: 'Guardó la configuración de la pasarela SMS',
      ip,
    })
    return NextResponse.json({
      ok: true,
      message: 'Pasarela SMS conectada. Los códigos ya pueden llegar por mensaje de texto.',
    })
  }

  // ---------- Bot de Telegram (igual que antes: se valida con Telegram) ----------
  if (body.botToken === undefined) {
    return NextResponse.json(
      { error: 'No hay ninguna configuración que guardar' },
      { status: 400 }
    )
  }
  const botToken = clip(body.botToken, 200)
  let botUsername: string | null = null
  try {
    const res = await fetch(`https://api.telegram.org/bot${botToken}/getMe`)
    const data = (await res.json().catch(() => ({}))) as {
      ok?: boolean
      result?: { username?: string }
    }
    if (res.ok && data.ok && data.result?.username) {
      botUsername = data.result.username
    } else {
      return NextResponse.json(
        { error: 'Telegram no aceptó ese token. Copia el token completo que te dio @BotFather.' },
        { status: 400 }
      )
    }
  } catch {
    return NextResponse.json(
      { error: 'No se pudo conectar con Telegram para validar el token. Inténtalo otra vez.' },
      { status: 502 }
    )
  }

  await db.systemConfig.upsert({
    where: { key: 'telegram_bot_token' },
    create: { key: 'telegram_bot_token', value: botToken },
    update: { value: botToken },
  })
  if (botUsername) {
    await db.systemConfig.upsert({
      where: { key: 'telegram_bot_username' },
      create: { key: 'telegram_bot_username', value: botUsername },
      update: { value: botUsername },
    })
  }
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'security_config',
    detail: `Guardó el token del bot de Telegram (@${botUsername || 'desconocido'})`,
    ip,
  })

  return NextResponse.json({
    ok: true,
    message: `Bot de Telegram conectado (@${botUsername || 'desconocido'}). Los códigos ya pueden llegar por Telegram.`,
    botUsername,
  })
}
