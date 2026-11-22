// ============================================================
// PERFIL DE LA CUENTA
// GET  /api/auth/me -> datos de la cuenta actual (contacto,
//      verificaciones, Telegram)
// POST /api/profile { email?, phone? } -> guardar correo/teléfono
// Al cambiar un dato se quita su verificación hasta confirmar el
// código que se envía (correo o SMS).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getClientIp, rateLimit, RATE, logSecurityEvent } from '@/lib/security'
import { getSessionUser } from '@/lib/session'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const PHONE_RE = /^\+?\d[\d\s-]{5,17}$/

function profileOf(user: {
  name: string
  role: string
  email: string | null
  emailVerifiedAt: Date | null
  phone: string | null
  phoneVerifiedAt: Date | null
  telegramChatId: string | null
  telegramUsername: string | null
  telegramLinkedAt: Date | null
  createdAt: Date
  lastPasswordChangeAt: Date | null
}) {
  return {
    name: user.name,
    role: user.role,
    email: user.email,
    emailVerified: Boolean(user.emailVerifiedAt),
    phone: user.phone,
    phoneVerified: Boolean(user.phoneVerifiedAt),
    telegramLinked: Boolean(user.telegramChatId),
    telegramUsername: user.telegramUsername,
    createdAt: user.createdAt,
    lastPasswordChangeAt: user.lastPasswordChangeAt,
  }
}

export async function GET(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ user: null }, { status: 401 })
  }
  return NextResponse.json({ user: profileOf(sess.user) })
}

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'No hay sesión activa' }, { status: 401 })
  }
  if (!rateLimit(`profile:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const email = body.email === undefined ? undefined : String(body.email).trim().toLowerCase()
  const phone = body.phone === undefined ? undefined : String(body.phone).trim()

  if (email !== undefined && email !== '' && !EMAIL_RE.test(email)) {
    return NextResponse.json({ error: 'Escribe un correo electrónico válido' }, { status: 400 })
  }
  if (phone !== undefined && phone !== '' && !PHONE_RE.test(phone)) {
    return NextResponse.json({ error: 'Escribe un número de teléfono válido' }, { status: 400 })
  }

  // ¿Algún otro usuario ya usa ese correo o teléfono?
  if (email) {
    const taken = await db.user.findFirst({ where: { email, id: { not: sess.user.id } } })
    if (taken) {
      return NextResponse.json({ error: 'Ese correo ya lo usa otra cuenta' }, { status: 400 })
    }
  }
  if (phone) {
    const taken = await db.user.findFirst({ where: { phone, id: { not: sess.user.id } } })
    if (taken) {
      return NextResponse.json({ error: 'Ese teléfono ya lo usa otra cuenta' }, { status: 400 })
    }
  }

  const data: { email?: string | null; emailVerifiedAt?: null; phone?: string | null; phoneVerifiedAt?: null } = {}
  const changed: string[] = [] // claves técnicas: email | phone
  const changedEs: string[] = [] // nombres en español para el mensaje
  if (email !== undefined) {
    const value = email === '' ? null : email
    if (value !== sess.user.email) {
      data.email = value
      data.emailVerifiedAt = null
      changed.push('email')
      changedEs.push('correo')
    } else {
      data.email = value
    }
  }
  if (phone !== undefined) {
    const value = phone === '' ? null : phone
    if (value !== sess.user.phone) {
      data.phone = value
      data.phoneVerifiedAt = null
      changed.push('phone')
      changedEs.push('teléfono')
    } else {
      data.phone = value
    }
  }

  const user = await db.user.update({ where: { id: sess.user.id }, data })
  if (changed.length > 0) {
    await logSecurityEvent({
      userId: user.id,
      userName: user.name,
      type: 'contact_updated',
      detail: `Datos de contacto actualizados: ${changedEs.join(' y ')}. Pendiente de verificar con código.`,
      ip,
    })
  }
  return NextResponse.json({
    ok: true,
    needsVerification: changed,
    message:
      changed.length > 0
        ? `Guardado. Te enviaremos un código para verificar tu ${changedEs.join(' y tu ')}.`
        : 'Datos guardados.',
    user: profileOf(user),
  })
}
