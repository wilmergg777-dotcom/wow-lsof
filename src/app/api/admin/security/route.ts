// ============================================================
// SEGURIDAD DEL SISTEMA (solo administradores)
// GET  /api/admin/security -> estado de canales, token del bot
//      (enmascarado), registro de eventos, bandeja de salida y
//      cuentas bloqueadas.
// POST /api/admin/security { botToken } -> guarda el token del
//      bot de Telegram (validándolo con Telegram) o lo borra.
// El bot envía los códigos cuando el SMS no llega al teléfono.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getClientIp, logSecurityEvent } from '@/lib/security'
import { getSessionUser } from '@/lib/session'
import { getBotToken } from '@/lib/notify'

async function requireAdmin(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess || sess.user.role !== 'administrador') return null
  return sess
}

function maskToken(token: string) {
  if (token.length <= 12) return '••••••'
  return `${token.slice(0, 6)}••••••${token.slice(-4)}`
}

export async function GET(req: Request) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json({ error: 'Solo el administrador puede ver esto' }, { status: 403 })
  }

  const [token, botUsername, events, outbox, lockedUsers] = await Promise.all([
    getBotToken(),
    db.systemConfig.findUnique({ where: { key: 'telegram_bot_username' } }),
    db.securityEvent.findMany({ orderBy: { createdAt: 'desc' }, take: 40 }),
    db.outboxMessage.findMany({ orderBy: { createdAt: 'desc' }, take: 40 }),
    db.user.findMany({ where: { lockedUntil: { gt: new Date() } }, select: { name: true, lockedUntil: true } }),
  ])

  return NextResponse.json({
    telegram: {
      configured: Boolean(token),
      maskedToken: token ? maskToken(token) : null,
      botUsername: botUsername?.value || null,
    },
    channels: {
      email: Boolean(process.env.RESEND_API_KEY),
      sms: Boolean(process.env.SMS_API_URL),
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
    return NextResponse.json({ error: 'Solo el administrador puede cambiar esto' }, { status: 403 })
  }

  const body = await req.json().catch(() => ({}))
  const botToken = String(body.botToken || '').trim()

  if (!botToken) {
    // Vacío = desconectar el bot
    await db.systemConfig.deleteMany({
      where: { key: { in: ['telegram_bot_token', 'telegram_bot_username'] } },
    })
    await logSecurityEvent({ userId: sess.user.id, userName: sess.user.name, type: 'security_config', detail: 'Desconectó el bot de Telegram', ip })
    return NextResponse.json({ ok: true, message: 'Bot de Telegram desconectado.' })
  }

  // Valida el token con Telegram (getMe) antes de guardarlo
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
