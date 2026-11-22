// ============================================================
// ENLAZAR LA CUENTA CON EL BOT DE TELEGRAM (plan B de los códigos)
// POST /api/profile/telegram { action: 'start' | 'check' | 'unlink' }
//
// - start: genera un código de enlace (el usuario lo ve en los
//   ajustes) y devuelve las instrucciones con el nombre del bot.
// - check: consulta al bot (getUpdates) buscando "/start <código>"
//   y enlaza el chat de Telegram del usuario.
// - unlink: desconecta el Telegram de la cuenta.
//
// Requiere que el administrador haya guardado el token del bot
// en Seguridad del sistema (panel de administración).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { rateLimit, RATE, getClientIp, genCode, logSecurityEvent } from '@/lib/security'
import { getSessionUser } from '@/lib/session'
import { getBotToken, getBotUsername } from '@/lib/notify'

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'No hay sesión activa' }, { status: 401 })
  }
  if (!rateLimit(`tg:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const action = String(body.action || '')

  // ---------- Generar el código de enlace ----------
  if (action === 'start') {
    const token = await getBotToken()
    const botUsername = await getBotUsername()
    const code = genCode()
    await db.verificationCode.create({
      data: {
        userId: sess.user.id,
        purpose: 'link_telegram',
        codeHash: code, // se compara en claro con el mensaje del bot
        channel: 'telegram',
        target: sess.user.telegramUsername ? `@${sess.user.telegramUsername}` : 'enlace de Telegram',
        expiresAt: new Date(Date.now() + 15 * 60_000),
      },
    })
    await logSecurityEvent({ userId: sess.user.id, userName: sess.user.name, type: 'telegram_link_started', detail: 'Generó un código para enlazar su Telegram', ip })
    return NextResponse.json({
      ok: true,
      code,
      botConfigured: Boolean(token),
      botUsername,
      instructions: token
        ? `Abre Telegram, busca ${botUsername ? '@' + botUsername : 'el bot de Violetero'} y envíale el mensaje: /start ${code}`
        : 'El administrador aún no ha configurado el bot de Telegram: guárdalo en Panel de administración > Seguridad.',
    })
  }

  // ---------- Comprobar si el usuario ya escribió al bot ----------
  if (action === 'check') {
    const token = await getBotToken()
    if (!token) {
      return NextResponse.json(
        { error: 'El administrador aún no configura el bot de Telegram. Guarda el token en Seguridad del sistema.' },
        { status: 400 }
      )
    }
    const pending = await db.verificationCode.findFirst({
      where: { userId: sess.user.id, purpose: 'link_telegram', usedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
    })
    if (!pending) {
      return NextResponse.json({ error: 'El código de enlace ya no es válido. Genera uno nuevo.' }, { status: 400 })
    }

    // Lee los últimos mensajes que llegaron al bot
    let updates: {
      message?: { chat?: { id: number | string; username?: string }; text?: string; from?: { username?: string } }
    }[] = []
    try {
      const res = await fetch(`https://api.telegram.org/bot${token}/getUpdates?limit=100`)
      const data = (await res.json().catch(() => ({}))) as { ok?: boolean; result?: unknown }
      if (res.ok && data.ok) updates = (data.result || []) as typeof updates
    } catch {
      return NextResponse.json(
        { error: 'No se pudo conectar con Telegram ahora mismo. Prueba otra vez.' },
        { status: 502 }
      )
    }

    // Busca el mensaje "/start CÓDIGO" (el más nuevo primero).
    // En link_telegram guardamos el código en claro (codeHash)
    // porque aquí no hay que comparar contra un hash secreto.
    for (const u of [...updates].reverse()) {
      const text = (u.message?.text || '').trim()
      if (text === `/start ${codeFrom(pending.codeHash)}`) {
        const chat = u.message?.chat
        if (!chat?.id) continue
        const username = u.message?.from?.username || chat.username || null
        const user = await db.user.update({
          where: { id: sess.user.id },
          data: {
            telegramChatId: String(chat.id),
            telegramUsername: username,
            telegramLinkedAt: new Date(),
          },
        })
        await db.verificationCode.update({ where: { id: pending.id }, data: { usedAt: new Date() } })
        await logSecurityEvent({ userId: user.id, userName: user.name, type: 'telegram_linked', detail: `Cuenta enlazada con Telegram ${username ? '@' + username : ''}`, ip })
        return NextResponse.json({
          ok: true,
          message: `¡Telegram enlazado! ${username ? `(@${username}) ` : ''}Ahora los códigos pueden llegar al bot si el SMS no llega.`,
          user: {
            name: user.name,
            role: user.role,
            email: user.email,
            emailVerified: Boolean(user.emailVerifiedAt),
            phone: user.phone,
            phoneVerified: Boolean(user.phoneVerifiedAt),
            telegramLinked: true,
            telegramUsername: user.telegramUsername,
            createdAt: user.createdAt,
            lastPasswordChangeAt: user.lastPasswordChangeAt,
          },
        })
      }
    }
    return NextResponse.json(
      { error: 'Todavía no ha llegado ningún mensaje con ese código. Envía /start al bot y pulsa Comprobar otra vez.' },
      { status: 404 }
    )
  }

  // ---------- Desenlazar ----------
  if (action === 'unlink') {
    const user = await db.user.update({
      where: { id: sess.user.id },
      data: { telegramChatId: null, telegramUsername: null, telegramLinkedAt: null },
    })
    await logSecurityEvent({ userId: user.id, userName: user.name, type: 'telegram_unlinked', detail: 'Desenlazó su Telegram', ip })
    return NextResponse.json({
      ok: true,
      message: 'Telegram desconectado de tu cuenta.',
      user: {
        name: user.name,
        role: user.role,
        email: user.email,
        emailVerified: Boolean(user.emailVerifiedAt),
        phone: user.phone,
        phoneVerified: Boolean(user.phoneVerifiedAt),
        telegramLinked: false,
        telegramUsername: null,
        createdAt: user.createdAt,
        lastPasswordChangeAt: user.lastPasswordChangeAt,
      },
    })
  }

  return NextResponse.json({ error: 'Acción no válida' }, { status: 400 })
}

// Para link_telegram guardamos el código en claro (no hay que
// comparar contra un mensaje conocido por el usuario)
function codeFrom(stored: string) {
  return stored
}
