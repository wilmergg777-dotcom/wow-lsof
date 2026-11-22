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

// ¿La petición viene de la propia máquina (el dueño probando en
// local)? En modo demostración el código se muestra SOLO ahí.
// En un dominio público jamás se devuelve el código: si no hay
// canal real configurado, el usuario debe contactar al admin.
function isLocalRequest(req: Request): boolean {
  if (process.env.DEMO_RESET_CODES === '1') return true
  const host = (req.headers.get('host') || '').split(':')[0].toLowerCase()
  return host === 'localhost' || host === '127.0.0.1' || host === '[::1]' || host === '0.0.0.0'
}

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

  // Busca la cuenta por nombre, correo o teléfono (sin exponer si existe).
  // findFirst evita errores de runtime si la base de datos vieja
  // todavía no tiene las columnas marcadas como únicas.
  const user = EMAIL_RE.test(identifier)
    ? await db.user.findFirst({ where: { email: identifier } })
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
  // (MODO DEMOSTRACIÓN) PERO SOLO en pruebas locales del dueño.
  // En un sitio público nunca se devuelve el código en la
  // respuesta: un atacante podría pedir el código de una cuenta
  // ajena y apropiarse de ella.
  const demoChannel = !(await hasRealChannel())
  const local = isLocalRequest(req)
  const demo = demoChannel && local
  return NextResponse.json({
    ...okResponse,
    channel: delivery.channel,
    channelLabel: delivery.channel ? CHANNEL_LABELS[delivery.channel] : null,
    target: delivery.target,
    note: demo
      ? delivery.note
      : demoChannel
        ? 'El administrador todavía no configuró el envío real de códigos. Contacta con el administrador de la tienda para recuperar tu contraseña.'
        : delivery.note,
    needsAdminHelp: demoChannel && !local,
    demo,
    demoCode: demo ? code : undefined,
    fallbackHint:
      delivery.channel === 'sms'
        ? 'Si el SMS no te llega, te enviaremos el código por el bot de Telegram o al correo.'
        : 'Si no te llega el código, puedes pedirlo de nuevo y llegará por otro canal disponible.',
  })
}
