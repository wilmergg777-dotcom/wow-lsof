// ============================================================
// API de registro de cuentas de Violetero
// POST /api/auth/register  { name, password, role }
// Roles posibles al registrarse: comprador o repartidor (turbo).
// El administrador es una cuenta que ya viene creada.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { ensureUsersSeed, hashPassword } from '@/lib/auth'

export async function POST(req: Request) {
  const body = await req.json()
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
    select: { name: true, role: true },
  })
  return NextResponse.json(user, { status: 201 })
}
