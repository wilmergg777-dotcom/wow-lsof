// ============================================================
// SESIONES ACTIVAS DE LA CUENTA (multi-dispositivo)
// GET  /api/auth/sessions -> lista de sesiones activas
// POST /api/auth/sessions { sessionId } -> cierra una sesión
// POST /api/auth/sessions { allOthers: true } -> cierra las demás
// Protección si la cuenta está abierta en dos dispositivos a la
// vez: el usuario ve cada sesión y puede cerrar la que no reconoce.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getClientIp, rateLimit, RATE, logSecurityEvent } from '@/lib/security'
import {
  getSessionUser,
  revokeSessionById,
  revokeOtherSessions,
  readSessionToken,
} from '@/lib/session'
import { hashValue } from '@/lib/security'

export async function GET(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'No hay sesión activa' }, { status: 401 })
  }
  const sessions = await db.userSession.findMany({
    where: { userId: sess.user.id, revokedAt: null },
    orderBy: { lastSeenAt: 'desc' },
    select: {
      id: true,
      device: true,
      ip: true,
      createdAt: true,
      lastSeenAt: true,
    },
  })
  const currentToken = readSessionToken(req)
  const currentHash = currentToken ? hashValue(currentToken) : null
  const currentSession = await db.userSession.findUnique({
    where: { tokenHash: currentHash || '' },
    select: { id: true },
  })
  return NextResponse.json({
    sessions: sessions.map((s) => ({ ...s, current: s.id === currentSession?.id })),
  })
}

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'No hay sesión activa' }, { status: 401 })
  }
  if (!rateLimit(`sessions:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))

  if (body.allOthers) {
    const closed = await revokeOtherSessions(sess.user.id, sess.session.id)
    await logSecurityEvent({ userId: sess.user.id, userName: sess.user.name, type: 'session_revoked', detail: `Cerró ${closed} sesión(es) en otros dispositivos`, ip })
    return NextResponse.json({
      ok: true,
      closed,
      message: closed > 0 ? `Cerramos ${closed} sesión(es) en otros dispositivos.` : 'No había otras sesiones abiertas.',
    })
  }

  const sessionId = String(body.sessionId || '')
  if (!sessionId) {
    return NextResponse.json({ error: 'Falta la sesión a cerrar' }, { status: 400 })
  }
  if (sessionId === sess.session.id) {
    return NextResponse.json(
      { error: 'Esa es la sesión actual: usa "Cerrar sesión" del menú' },
      { status: 400 }
    )
  }
  const closed = await revokeSessionById(sess.user.id, sessionId)
  if (!closed) {
    return NextResponse.json({ error: 'Esa sesión ya estaba cerrada' }, { status: 404 })
  }
  await logSecurityEvent({ userId: sess.user.id, userName: sess.user.name, type: 'session_revoked', detail: 'Cerró una sesión desde los ajustes', ip })
  return NextResponse.json({ ok: true, message: 'Sesión cerrada en ese dispositivo.' })
}
