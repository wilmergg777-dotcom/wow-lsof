// ============================================================
// ENVÍO DE MENSAJES DE SEGURIDAD (códigos de verificación)
// Canales: correo electrónico -> SMS (teléfono) -> Telegram (plan B)
// Cada intento queda registrado en la bandeja de salida
// (OutboxMessage) para que el administrador pueda auditarlo.
//
// Si el administrador aún no ha configurado los canales reales,
// los mensajes se marcan como "simulated" y la web muestra el
// código en pantalla con el aviso de MODO DEMOSTRACIÓN, para
// que el flujo se pueda probar hasta configurar el bot.
// ============================================================
import { db } from './db'

export type Channel = 'email' | 'sms' | 'telegram'

export const CHANNEL_LABELS: Record<Channel, string> = {
  email: 'correo electrónico',
  sms: 'SMS (mensaje de texto)',
  telegram: 'bot de Telegram',
}

// ---------- Configuración del bot de Telegram ----------
export async function getBotToken(): Promise<string | null> {
  if (process.env.TELEGRAM_BOT_TOKEN) return process.env.TELEGRAM_BOT_TOKEN
  const row = await db.systemConfig.findUnique({ where: { key: 'telegram_bot_token' } })
  return row?.value || null
}

export async function getBotUsername(): Promise<string | null> {
  const row = await db.systemConfig.findUnique({ where: { key: 'telegram_bot_username' } })
  return row?.value || null
}

// ¿Hay algún canal REAL configurado? (decide si se muestra el código en pantalla)
export async function hasRealChannel(): Promise<boolean> {
  if (process.env.TELEGRAM_BOT_TOKEN) return true
  if (process.env.SMS_API_URL) return true
  if (process.env.RESEND_API_KEY) return true
  const bot = await db.systemConfig.findUnique({ where: { key: 'telegram_bot_token' } })
  return Boolean(bot?.value)
}

// ---------- Registro en la bandeja de salida ----------
async function logOutbox(m: {
  channel: Channel
  target: string
  subject?: string
  body: string
  status: 'sent' | 'failed' | 'simulated'
  error?: string
}) {
  await db.outboxMessage.create({
    data: {
      channel: m.channel,
      target: m.target,
      subject: m.subject || '',
      body: m.body,
      status: m.status,
      error: m.error || null,
      sentAt: m.status === 'sent' ? new Date() : null,
    },
  })
}

// ---------- Telegram (el plan B cuando el SMS no llega) ----------
export async function sendTelegram(chatId: string, text: string, maskedTarget: string) {
  const token = await getBotToken()
  if (!token) {
    await logOutbox({ channel: 'telegram', target: maskedTarget, body: text, status: 'simulated' })
    return { ok: false, simulated: true }
  }
  try {
    const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chat_id: chatId, text }),
    })
    const data = (await res.json().catch(() => ({}))) as { ok?: boolean; description?: string }
    if (res.ok && data.ok) {
      await logOutbox({ channel: 'telegram', target: maskedTarget, body: text, status: 'sent' })
      return { ok: true, simulated: false }
    }
    await logOutbox({
      channel: 'telegram',
      target: maskedTarget,
      body: text,
      status: 'failed',
      error: data.description || `HTTP ${res.status}`,
    })
    return { ok: false, simulated: false }
  } catch (e) {
    await logOutbox({
      channel: 'telegram',
      target: maskedTarget,
      body: text,
      status: 'failed',
      error: (e as Error).message,
    })
    return { ok: false, simulated: false }
  }
}

// ---------- SMS al número de teléfono ----------
export async function sendSms(phone: string, text: string, maskedTarget: string) {
  const url = process.env.SMS_API_URL
  if (!url) {
    await logOutbox({ channel: 'sms', target: maskedTarget, body: text, status: 'simulated' })
    return { ok: false, simulated: true }
  }
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(process.env.SMS_API_KEY ? { Authorization: `Bearer ${process.env.SMS_API_KEY}` } : {}),
      },
      body: JSON.stringify({ to: phone, text }),
    })
    if (res.ok) {
      await logOutbox({ channel: 'sms', target: maskedTarget, body: text, status: 'sent' })
      return { ok: true, simulated: false }
    }
    await logOutbox({
      channel: 'sms',
      target: maskedTarget,
      body: text,
      status: 'failed',
      error: `HTTP ${res.status}`,
    })
    return { ok: false, simulated: false }
  } catch (e) {
    await logOutbox({
      channel: 'sms',
      target: maskedTarget,
      body: text,
      status: 'failed',
      error: (e as Error).message,
    })
    return { ok: false, simulated: false }
  }
}

// ---------- Correo electrónico ----------
export async function sendEmail(to: string, subject: string, body: string, maskedTarget: string) {
  const key = process.env.RESEND_API_KEY
  if (!key) {
    await logOutbox({ channel: 'email', target: maskedTarget, subject, body, status: 'simulated' })
    return { ok: false, simulated: true }
  }
  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: process.env.EMAIL_FROM || 'Violetero <onboarding@resend.dev>',
        to: [to],
        subject,
        text: body,
      }),
    })
    if (res.ok) {
      await logOutbox({ channel: 'email', target: maskedTarget, subject, body, status: 'sent' })
      return { ok: true, simulated: false }
    }
    await logOutbox({
      channel: 'email',
      target: maskedTarget,
      subject,
      body,
      status: 'failed',
      error: `HTTP ${res.status}`,
    })
    return { ok: false, simulated: false }
  } catch (e) {
    await logOutbox({
      channel: 'email',
      target: maskedTarget,
      subject,
      body,
      status: 'failed',
      error: (e as Error).message,
    })
    return { ok: false, simulated: false }
  }
}

// ---------- Textos de los mensajes ----------
export function codeText(purpose: string, code: string, minutes: number): { subject: string; body: string } {
  const what =
    purpose === 'reset_password'
      ? 'restablecer tu contraseña'
      : purpose === 'verify_email'
        ? 'verificar tu correo electrónico'
        : purpose === 'verify_phone'
          ? 'verificar tu número de teléfono'
          : 'confirmar que eres tú'
  const subject = `Violetero · código ${code} para ${what}`
  const body = [
    `Tu código de Violetero para ${what} es:`,
    ``,
    `   ${code}`,
    ``,
    `Caduca en ${minutes} minutos. Si no fuiste tú, ignora este mensaje.`,
    `Nunca compartas este código con nadie.`,
  ].join('\n')
  return { subject, body }
}

// ---------- Entrega con plan B ----------
export type DeliveryTarget = {
  email?: string | null
  emailVerified?: boolean
  phone?: string | null
  telegramChatId?: string | null
}

export type DeliveryResult = {
  delivered: boolean // ¿llegó por un canal real (o se simuló)?
  channel: Channel | null
  target: string // destino enmascarado para mostrar al usuario
  simulated: boolean // sin canales reales configurados -> el código se muestra en pantalla
  realSent: boolean // llegó de verdad por un canal configurado
  note: string // explicación para el usuario
}

/**
 * Envía un código de verificación al usuario probando canales en
 * orden: el preferido primero y los demás como plan B.
 * Orden por defecto: SMS -> Telegram -> correo (el SMS es el
 * principal y el bot de Telegram es el respaldo si no llega).
 */
export async function deliverCode(opts: {
  userId: string
  userName: string
  purpose: string
  codeHash: string
  code: string
  preferred?: Channel
  target: DeliveryTarget
  mask: (t: string) => string
}): Promise<DeliveryResult> {
  const { subject, body } = codeText(opts.purpose, opts.code, 10)

  // Canales disponibles con su destino
  const options: { channel: Channel; to: string; mask: string }[] = []
  if (opts.target.phone) {
    options.push({ channel: 'sms', to: opts.target.phone, mask: opts.mask(opts.target.phone) })
  }
  if (opts.target.telegramChatId) {
    options.push({
      channel: 'telegram',
      to: opts.target.telegramChatId,
      mask: opts.target.telegramUsername ? `@${opts.target.telegramUsername}` : 'Telegram',
    })
  }
  if (opts.target.email) {
    options.push({ channel: 'email', to: opts.target.email, mask: opts.mask(opts.target.email) })
  }

  // El canal preferido va primero; el resto conserva el orden SMS -> Telegram -> correo
  const preferred = opts.preferred
  const ordered = preferred
    ? [...options.filter((o) => o.channel === preferred), ...options.filter((o) => o.channel !== preferred)]
    : options

  let simulated = false
  for (const o of ordered) {
    const r =
      o.channel === 'sms'
        ? await sendSms(o.to, body, o.mask)
        : o.channel === 'telegram'
          ? await sendTelegram(o.to, body, o.mask)
          : await sendEmail(o.to, subject, body, o.mask)

    await db.verificationCode.create({
      data: {
        userId: opts.userId,
        purpose: opts.purpose,
        codeHash: opts.codeHash,
        channel: o.channel,
        target: o.mask,
        expiresAt: new Date(Date.now() + 10 * 60_000),
      },
    })

    if (r.simulated) {
      // Sin canal real: registrar y devolver el código para MODO DEMOSTRACIÓN
      simulated = true
      return {
        delivered: true,
        channel: o.channel,
        target: o.mask,
        simulated: true,
        realSent: false,
        note:
          o.channel === 'sms'
            ? 'El SMS se registró en modo demostración (el administrador aún no configura el envío real).'
            : o.channel === 'telegram'
              ? 'El mensaje de Telegram se registró en modo demostración (el administrador aún no configura el bot).'
              : 'El correo se registró en modo demostración (el administrador aún no configura el envío real).',
      }
    }
    if (r.ok) {
      return {
        delivered: true,
        channel: o.channel,
        target: o.mask,
        simulated: false,
        realSent: true,
        note: `Código enviado por ${CHANNEL_LABELS[o.channel]} a ${o.mask}.`,
      }
    }
    // Canal real configurado pero falló el envío -> prueba el plan B
    simulated = false
  }

  // Ningún canal disponible ni funcionó: se devuelve el código en modo demostración
  if (ordered.length === 0) {
    await db.verificationCode.create({
      data: {
        userId: opts.userId,
        purpose: opts.purpose,
        codeHash: opts.codeHash,
        channel: 'sms',
        target: 'sin datos de contacto',
        expiresAt: new Date(Date.now() + 10 * 60_000),
      },
    })
  }
  return {
    delivered: false,
    channel: null,
    target: '',
    simulated: true,
    realSent: false,
    note: 'No hay datos de contacto configurados: el código se muestra en modo demostración.',
  }
}
