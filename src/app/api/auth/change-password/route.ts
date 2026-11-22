// ============================================================
// CAMBIAR CONTRASEÑA DENTRO DE LA PLATAFORMA (ajustes de cuenta)
// POST /api/auth/change-password { currentPassword, newPassword }
// Exige la contraseña actual. Al cambiarla se cierran las DEMÁS
// sesiones activas (la actual se mantiene) para cortar accesos
// de dispositivos que no reconoces.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { verifyPassword, hashPassword } from '@/lib/auth'
import { getClientIp, rateLimit, RATE, logSecurityEvent } from '@/lib/security'
import { getSessionUser, revokeOtherSessions } from '@/lib/session'

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Tu sesión no es válida. Inicia sesión otra vez.' },
      { status: 401 }
    )
  }
  if (!rateLimit(`chpw:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const currentPassword = String(body.currentPassword || '')
  const newPassword = String(body.newPassword || '')

  if (!verifyPassword(currentPassword, sess.user.password)) {
    await logSecurityEvent({ userId: sess.user.id, userName: sess.user.name, type: 'password_change_failed', detail: 'Contraseña actual incorrecta al intentar cambiarla', ip })
    return NextResponse.json({ error: 'La contraseña actual no es correcta' }, { status: 400 })
  }
  if (newPassword.length < 6) {
    return NextResponse.json(
      { error: 'La contraseña nueva debe tener al menos 6 caracteres' },
      { status: 400 }
    )
  }
  if (newPassword === currentPassword) {
    return NextResponse.json(
      { error: 'La contraseña nueva debe ser distinta de la actual' },
      { status: 400 }
    )
  }

  await db.user.update({
    where: { id: sess.user.id },
    data: {
      password: hashPassword(newPassword),
      lastPasswordChangeAt: new Date(),
      failedLoginAttempts: 0,
      lockedUntil: null,
    },
  })

  const closed = await revokeOtherSessions(sess.user.id, sess.session.id)
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'password_changed',
    detail: closed > 0 ? `Contraseña cambiada desde los ajustes. Se cerraron ${closed} sesión(es) en otros dispositivos.` : 'Contraseña cambiada desde los ajustes.',
    ip,
  })

  return NextResponse.json({
    ok: true,
    message: closed > 0
      ? 'Contraseña cambiada. Por seguridad cerramos las sesiones de los demás dispositivos.'
      : 'Contraseña cambiada correctamente.',
  })
}
