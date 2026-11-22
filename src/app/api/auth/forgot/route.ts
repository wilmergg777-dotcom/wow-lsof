// ============================================================
// PASO 1 DEL RESTABLECIMIENTO DE CONTRASEÑA
// POST /api/auth/forgot  { identifier }
// El usuario escribe su nombre, correo o teléfono. Se genera un
// código de 6 dígitos y se envía:
//   teléfono -> SMS primero; si no llega -> bot de Telegram
//   correo   -> correo electrónico primero; si no -> Telegram
// Respuesta genérica para que un atacante no descubra qué
// cuentas existen.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import {
  rateLimit,
  RATE,
  getClientIp,
  genCode,
  hashValue,
  maskEmail,
  maskPhone,
  logSecurityEvent,
} from '@/lib/security'
import { deliverCode, hasRealChannel, CHANNEL_LABELS, type Channel } from '@/lib/notify'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const body = await req.json().catch(() => ({}))
  const identifier = String(body.identifier || '').trim()

  if (!identifier) {
    return NextResponse.json(
      { error: 'Escribe tu nombre de usuario, tu correo o tu teléfono' },
      { status: 400 }
    )
  }

  // Anti abuso: máx. 5 códigos cada 15 min por IP
  if (!rateLimit(`forgot:${ip}`, RATE.forgot.max, RATE.forgot.windowMs)) {
    await logSecurityEvent({ type: 'attack_blocked', detail: 'Demasiadas peticiones de restablecimiento desde esta IP', ip })
    return NextResponse.json(
      { error: 'Demasiadas peticiones. Espera unos minutos y prueba otra vez.' },
      { status: 429 }
    )
  }

  // Busca la cuenta por nombre, correo o teléfono (sin exponer si existe)
  const user = EMAIL_RE.test(identifier)
    ? await db.user.findUnique({ where: { email: identifier } })
    : (await db.user.findUnique({ where: { name: identifier } })) ||
      (await db.user.findFirst({ where: { phone: identifier } }))

  // Respuesta genérica aunque no exista la cuenta (anti enumeración)
  const okResponse = {
    ok: true,
    message:
      'Si la cuenta existe, acabamos de enviar un código para restablecer la contraseña. Revisa tus mensajes.',
  }

  if (!user) {
    await logSecurityEvent({ type: 'reset_requested_unknown', detail: `Petición de restablecimiento para "${identifier}" (cuenta no encontrada)`, ip })
    return NextResponse.json(okResponse)
  }

  const code = genCode()
  const preferred: Channel | undefined = EMAIL_RE.test(identifier)
    ? 'email'
    : user.phone
      ? 'sms'
      : user.email
        ? 'email'
        : undefined

  const delivery = await deliverCode({
    userId: user.id,
    userName: user.name,
    purpose: 'reset_password',
    codeHash: hashValue(code),
    code,
    preferred,
    target: {
      email: user.email,
      phone: user.phone,
      telegramChatId: user.telegramChatId,
      telegramUsername: user.telegramUsername,
    },
    mask: (t) => (EMAIL_RE.test(t) ? maskEmail(t) : maskPhone(t)),
  })

  await logSecurityEvent({
    userId: user.id,
    userName: user.name,
    type: 'reset_code_sent',
    detail: delivery.realSent
      ? `Código de restablecimiento enviado por ${CHANNEL_LABELS[delivery.channel as Channel]} a ${delivery.target}`
      : 'Código de restablecimiento generado (modo demostración, sin canales reales)',
    ip,
  })

  // Sin canales reales configurados el código se muestra en pantalla
  // (MODO DEMOSTRACIÓN) para que el flujo se pueda probar hasta
  // que el administrador configure el bot de Telegram / SMS / correo.
  const demo = !(await hasRealChannel())
  return NextResponse.json({
    ...okResponse,
    channel: delivery.channel,
    channelLabel: delivery.channel ? CHANNEL_LABELS[delivery.channel] : null,
    target: delivery.target,
    note: delivery.note,
    demo,
    demoCode: demo ? code : undefined,
    fallbackHint:
      delivery.channel === 'sms'
        ? 'Si el SMS no te llega, te enviaremos el código por el bot de Telegram o al correo.'
        : 'Si no te llega el código, puedes pedirlo de nuevo y llegará por otro canal disponible.',
  })
}
