// ============================================================
// API de inicio de sesión de Violetero
// POST /api/auth/login  { name, password } -> { name, role }
//
// Parches de seguridad anti-ataques:
// - Límite de intentos por IP (10 cada 10 minutos)
// - Bloqueo temporal de la cuenta tras 5 contraseñas fallidas
// - Sesión real en el servidor con cookie httpOnly
// - Todo queda en el registro de seguridad
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { ensureUsersSeed, verifyPassword } from '@/lib/auth'
import {
  rateLimit,
  RATE,
  getClientIp,
  lockUntil,
  MAX_FAILED_ATTEMPTS,
  logSecurityEvent,
  LOCK_MINUTES,
} from '@/lib/security'
import { createSession, SESSION_COOKIE, SESSION_MAX_AGE } from '@/lib/session'

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const body = await req.json().catch(() => ({}))
  const name = String(body.name || '').trim()
  const password = String(body.password || '')

  if (!name || !password) {
    return NextResponse.json(
      { error: 'Escribe tu nombre y tu contraseña' },
      { status: 400 }
    )
  }

  // Anti fuerza bruta: máx. 10 intentos de sesión cada 10 min por IP
  if (!rateLimit(`login:${ip}`, RATE.login.max, RATE.login.windowMs)) {
    await logSecurityEvent({ type: 'attack_blocked', detail: `Demasiados intentos de sesión desde esta IP (usuario "${name}")`, ip })
    return NextResponse.json(
      { error: 'Demasiados intentos desde esta conexión. Espera unos minutos y prueba otra vez.' },
      { status: 429 }
    )
  }

  await ensureUsersSeed()

  const user = await db.user.findUnique({ where: { name } })

  // Cuenta bloqueada temporalmente por intentos fallidos
  if (user?.lockedUntil && user.lockedUntil > new Date()) {
    const mins = Math.max(1, Math.ceil((user.lockedUntil.getTime() - Date.now()) / 60_000))
    await logSecurityEvent({ userId: user.id, userName: user.name, type: 'login_blocked', detail: `Intento de entrada con la cuenta bloqueada (${mins} min restantes)`, ip })
    return NextResponse.json(
      { error: `Cuenta bloqueada temporalmente por seguridad. Prueba en ${mins} minuto(s) o restablece tu contraseña.` },
      { status: 423 }
    )
  }

  if (!user || !verifyPassword(password, user.password)) {
    if (user) {
      const failed = user.failedLoginAttempts + 1
      const locked = failed >= MAX_FAILED_ATTEMPTS
      await db.user.update({
        where: { id: user.id },
        data: {
          failedLoginAttempts: failed,
          ...(locked ? { lockedUntil: lockUntil(), failedLoginAttempts: 0 } : {}),
        },
      })
      await logSecurityEvent({
        userId: user.id,
        userName: user.name,
        type: locked ? 'account_locked' : 'login_failed',
        detail: locked
          ? `Cuenta bloqueada ${LOCK_MINUTES} min tras ${MAX_FAILED_ATTEMPTS} contraseñas fallidas`
          : `Contraseña incorrecta (intento ${failed} de ${MAX_FAILED_ATTEMPTS})`,
        ip,
      })
      if (locked) {
        return NextResponse.json(
          { error: `Has superado el límite de intentos. Tu cuenta queda bloqueada ${LOCK_MINUTES} minutos. Puedes usar "¿Olvidaste tu contraseña?" para recuperarla.` },
          { status: 423 }
        )
      }
    }
    return NextResponse.json(
      { error: 'Nombre o contraseña incorrectos' },
      { status: 401 }
    )
  }

  // Entrada correcta: se limpia el contador y se crea la sesión
  await db.user.update({
    where: { id: user.id },
    data: { failedLoginAttempts: 0, lockedUntil: null },
  })
  await logSecurityEvent({ userId: user.id, userName: user.name, type: 'login_ok', detail: 'Inicio de sesión correcto', ip })

  const { token } = await createSession(user.id, user.name, req.headers.get('user-agent') || '', ip)

  const res = NextResponse.json({ name: user.name, role: user.role })
  res.cookies.set(SESSION_COOKIE, token, {
    httpOnly: true,
    sameSite: 'lax',
    path: '/',
    maxAge: SESSION_MAX_AGE,
  })
  return res
}
