// ============================================================
// API de registro de cuentas de Violetero
// POST /api/auth/register  { name, password, role }
// Roles posibles al registrarse: comprador o repartidor (turbo).
// El administrador es una cuenta que ya viene creada.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { ensureUsersSeed, hashPassword } from '@/lib/auth'
import { rateLimit, RATE, getClientIp, logSecurityEvent } from '@/lib/security'
import { createSession, SESSION_COOKIE, SESSION_MAX_AGE } from '@/lib/session'

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const body = await req.json().catch(() => ({}))
  const name = String(body.name || '').trim()
  const password = String(body.password || '')
  const role = body.role === 'repartidor' ? 'repartidor' : 'comprador'

  if (name.length < 3 || name.length > 20) {
    return NextResponse.json(
      { error: 'El nombre debe tener entre 3 y 20 caracteres' },
      { status: 400 }
    )
  }
  if (name.toLowerCase() === 'invitado') {
    return NextResponse.json(
      { error: 'No puedes usar el nombre "Invitado": crea tu propio nombre' },
      { status: 400 }
    )
  }
  if (password.length < 4) {
    return NextResponse.json(
      { error: 'La contraseña debe tener al menos 4 caracteres' },
      { status: 400 }
    )
  }

  // Anti-abuso: máx. 5 cuentas cada 15 min por IP
  if (!rateLimit(`register:${ip}`, RATE.register.max, RATE.register.windowMs)) {
    await logSecurityEvent({ type: 'attack_blocked', detail: 'Demasiados registros desde esta IP', ip })
    return NextResponse.json(
      { error: 'Demasiadas cuentas creadas desde esta conexión. Espera unos minutos.' },
      { status: 429 }
    )
  }

  await ensureUsersSeed()

  const exists = await db.user.findUnique({ where: { name } })
  if (exists) {
    return NextResponse.json(
      { error: `El nombre "${name}" ya está registrado. Inicia sesión.` },
      { status: 400 }
    )
  }

  const user = await db.user.create({
    data: { name, password: hashPassword(password), role },
    select: { name: true, role: true, id: true },
  })
  await logSecurityEvent({ userId: user.id, userName: user.name, type: 'account_created', detail: `Nueva cuenta (${role})`, ip })

  // La cuenta recién creada entra con sesión iniciada
  const { token } = await createSession(user.id, user.name, req.headers.get('user-agent') || '', ip)
  const res = NextResponse.json({ name: user.name, role: user.role }, { status: 201 })
  res.cookies.set(SESSION_COOKIE, token, {
    httpOnly: true,
    sameSite: 'lax',
    path: '/',
    maxAge: SESSION_MAX_AGE,
  })
  return res
}
