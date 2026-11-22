// ============================================================
// PASO 2 DEL RESTABLECIMIENTO: comprobar el código de 6 dígitos
// POST /api/auth/reset/verify  { identifier, code }
// El código caduca a los 10 minutos y admite 5 intentos (anti
// fuerza bruta). Si es correcto devuelve un token temporal
// (válido 15 min) para fijar la nueva contraseña.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import {
  rateLimit,
  RATE,
  getClientIp,
  genToken,
  hashValue,
  MAX_CODE_ATTEMPTS,
  RESET_TOKEN_TTL_MIN,
  logSecurityEvent,
} from '@/lib/security'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

async function findUser(identifier: string) {
  return (
    (await db.user.findUnique({ where: { name: identifier } })) ||
    (EMAIL_RE.test(identifier) ? await db.user.findUnique({ where: { email: identifier } }) : null) ||
    (await db.user.findFirst({ where: { phone: identifier } }))
  )
}

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const body = await req.json().catch(() => ({}))
  const identifier = String(body.identifier || '').trim()
  const code = String(body.code || '').trim()

  if (!rateLimit(`verify:${ip}`, RATE.verify.max, RATE.verify.windowMs)) {
    await logSecurityEvent({ type: 'attack_blocked', detail: 'Demasiadas comprobaciones de código desde esta IP', ip })
    return NextResponse.json(
      { error: 'Demasiados intentos. Espera unos minutos y prueba otra vez.' },
      { status: 429 }
    )
  }

  if (!identifier || !/^\d{6}$/.test(code)) {
    return NextResponse.json(
      { error: 'Escribe el código de 6 dígitos que te enviamos' },
      { status: 400 }
    )
  }

  const user = await findUser(identifier)
  if (!user) {
    return NextResponse.json({ error: 'El código no es válido o ya caducó' }, { status: 400 })
  }

  const record = await db.verificationCode.findFirst({
    where: {
      userId: user.id,
      purpose: 'reset_password',
      usedAt: null,
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: 'desc' },
  })

  if (!record) {
    return NextResponse.json(
      { error: 'El código no es válido o ya caducó. Pide uno nuevo.' },
      { status: 400 }
    )
  }

  // Máximo 5 intentos por código
  if (record.attempts >= MAX_CODE_ATTEMPTS) {
    await logSecurityEvent({ userId: user.id, userName: user.name, type: 'attack_blocked', detail: 'Código de restablecimiento anulado por demasiados intentos', ip })
    return NextResponse.json(
      { error: 'Demasiados intentos con este código. Pide uno nuevo.' },
      { status: 429 }
    )
  }

  if (record.codeHash !== hashValue(code)) {
    await db.verificationCode.update({
      where: { id: record.id },
      data: { attempts: { increment: 1 } },
    })
    await logSecurityEvent({ userId: user.id, userName: user.name, type: 'reset_code_failed', detail: `Código incorrecto (intento ${record.attempts + 1} de ${MAX_CODE_ATTEMPTS})`, ip })
    const left = MAX_CODE_ATTEMPTS - (record.attempts + 1)
    return NextResponse.json(
      { error: `El código no coincide. Te quedan ${left} intento(s).` },
      { status: 400 }
    )
  }

  // Código correcto: se consume y se emite el token temporal
  const resetToken = genToken()
  await db.verificationCode.update({
    where: { id: record.id },
    data: {
      usedAt: new Date(),
      resetTokenHash: hashValue(resetToken),
      resetTokenExpiresAt: new Date(Date.now() + RESET_TOKEN_TTL_MIN * 60_000),
    },
  })
  await logSecurityEvent({ userId: user.id, userName: user.name, type: 'reset_code_ok', detail: 'Código de restablecimiento validado', ip })

  return NextResponse.json({
    ok: true,
    resetToken,
    expiresIn: RESET_TOKEN_TTL_MIN,
  })
}
