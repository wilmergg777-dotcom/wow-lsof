// ============================================================
// PASO 3 DEL RESTABLECIMIENTO: fijar la nueva contraseña
// POST /api/auth/reset/confirm  { resetToken, password }
// Requiere el token temporal del paso 2. Al terminar se cierran
// TODAS las sesiones activas de la cuenta (multi-dispositivo).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getClientIp, hashValue, logSecurityEvent } from '@/lib/security'
import { hashPassword } from '@/lib/auth'
import { revokeAllSessions } from '@/lib/session'

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const body = await req.json().catch(() => ({}))
  const resetToken = String(body.resetToken || '')
  const password = String(body.password || '')

  if (password.length < 6) {
    return NextResponse.json(
      { error: 'La contraseña nueva debe tener al menos 6 caracteres' },
      { status: 400 }
    )
  }

  const record = await db.verificationCode.findFirst({
    where: {
      purpose: 'reset_password',
      resetTokenHash: hashValue(resetToken),
      resetTokenExpiresAt: { gt: new Date() },
      usedAt: { not: null },
    },
    orderBy: { createdAt: 'desc' },
    include: { user: true },
  })

  if (!record) {
    return NextResponse.json(
      { error: 'El enlace de recuperación no es válido o ya caducó. Empieza de nuevo.' },
      { status: 400 }
    )
  }

  await db.$transaction([
    db.user.update({
      where: { id: record.userId },
      data: {
        password: hashPassword(password),
        failedLoginAttempts: 0,
        lockedUntil: null,
        lastPasswordChangeAt: new Date(),
      },
    }),
    db.verificationCode.update({
      where: { id: record.id },
      data: { resetTokenHash: null, resetTokenExpiresAt: null },
    }),
  ])

  await revokeAllSessions(record.userId)
  await logSecurityEvent({
    userId: record.userId,
    userName: record.user.name,
    type: 'password_reset',
    detail: 'Contraseña restablecida con código de recuperación. Se cerraron todas las sesiones.',
    ip,
  })

  return NextResponse.json({
    ok: true,
    message: 'Contraseña actualizada. Ya puedes iniciar sesión con la nueva.',
  })
}
