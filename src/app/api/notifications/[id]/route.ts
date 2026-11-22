// ============================================================
// API de una notificación: marcar como leída
// PARCHES DE SEGURIDAD: solo el destinatario del mensaje (o el
// administrador) puede marcarlo como leído.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'

// PATCH /api/notifications/[id] — marcar leída { read: true }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para usar tu mini correo' }, { status: 401 })
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}))
  const notification = await db.notification.findUnique({ where: { id } })
  if (!notification) {
    return NextResponse.json({ error: 'Mensaje no encontrado' }, { status: 404 })
  }
  if (!isSelfOrAdmin(sess, notification.toName)) {
    return NextResponse.json({ error: 'Ese mensaje no es tuyo' }, { status: 403 })
  }
  const updated = await db.notification.update({
    where: { id },
    data: { read: body.read !== false },
  })
  return NextResponse.json(updated)
}
