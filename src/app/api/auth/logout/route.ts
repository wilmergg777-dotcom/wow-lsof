// ============================================================
// CIERRE DE SESIÓN: revoca la sesión del servidor y borra la
// cookie. Así "Cerrar sesión" también apaga la sesión real,
// no solo la identidad del navegador.
// POST /api/auth/logout
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { readSessionToken, SESSION_COOKIE } from '@/lib/session'
import { hashValue } from '@/lib/security'

export async function POST(req: Request) {
  const token = readSessionToken(req)
  if (token) {
    await db.userSession.updateMany({
      where: { tokenHash: hashValue(token), revokedAt: null },
      data: { revokedAt: new Date() },
    })
  }
  const res = NextResponse.json({ ok: true })
  res.cookies.set(SESSION_COOKIE, '', { httpOnly: true, path: '/', maxAge: 0 })
  return res
}
