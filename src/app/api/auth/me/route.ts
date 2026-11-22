// ============================================================
// DATOS DE LA CUENTA ACTUAL (ajustes)
// GET /api/auth/me -> perfil con correo, teléfono, Telegram y
// verificaciones de la sesión activa (cookie httpOnly).
// ============================================================
import { NextResponse } from 'next/server'
import { getSessionUser } from '@/lib/session'

export async function GET(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ user: null }, { status: 401 })
  }
  const u = sess.user
  return NextResponse.json({
    user: {
      name: u.name,
      role: u.role,
      email: u.email,
      emailVerified: Boolean(u.emailVerifiedAt),
      phone: u.phone,
      phoneVerified: Boolean(u.phoneVerifiedAt),
      telegramLinked: Boolean(u.telegramChatId),
      telegramUsername: u.telegramUsername,
      createdAt: u.createdAt,
      lastPasswordChangeAt: u.lastPasswordChangeAt,
    },
  })
}
