// ============================================================
// API de inicio de sesión de Violetero
// POST /api/auth/login  { name, password } -> { name, role }
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { ensureUsersSeed, verifyPassword } from '@/lib/auth'

export async function POST(req: Request) {
  const body = await req.json()
  const name = String(body.name || '').trim()
  const password = String(body.password || '')

  if (!name || !password) {
    return NextResponse.json(
      { error: 'Escribe tu nombre y tu contraseña' },
      { status: 400 }
    )
  }

  await ensureUsersSeed()

  const user = await db.user.findUnique({ where: { name } })
  if (!user || !verifyPassword(password, user.password)) {
    return NextResponse.json(
      { error: 'Nombre o contraseña incorrectos' },
      { status: 401 }
    )
  }

  return NextResponse.json({ name: user.name, role: user.role })
}
