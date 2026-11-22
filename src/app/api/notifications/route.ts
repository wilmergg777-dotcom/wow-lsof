// ============================================================
// API del mini correo interno (notificaciones)
// PARCHES DE SEGURIDAD:
// - La bandeja es PRIVADA: cada usuario solo lee SUS mensajes
//   con su sesión (antes se podía leer el correo de cualquiera
//   poniendo su nombre en la dirección).
// - Enviar mensajes exige sesión y tiene límite de frecuencia.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { clip, rateLimit, RATE } from '@/lib/security'

// GET /api/notifications?toName=Nombre — bandeja del usuario
export async function GET(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para ver tu mini correo' }, { status: 401 })
  }
  const { searchParams } = new URL(req.url)
  const toName = searchParams.get('toName')
  // El nombre de la dirección se ignora si no coincide con la sesión
  const target = toName && isSelfOrAdmin(sess, toName) ? toName : sess.user.name
  const notifications = await db.notification.findMany({
    where: { toName: target },
    orderBy: { createdAt: 'desc' },
    take: 50,
  })
  return NextResponse.json(notifications)
}

// POST /api/notifications — crear una notificación (mensajes internos)
export async function POST(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para enviar mensajes' }, { status: 401 })
  }
  if (!rateLimit(`notify:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiados mensajes seguidos. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const { toName, title, body: text, kind, orderId } = body
  if (!toName || !title) {
    return NextResponse.json({ error: 'Faltan destinatario o título' }, { status: 400 })
  }
  const notification = await db.notification.create({
    data: {
      toName: clip(toName, 40),
      title: clip(title, 120),
      body: clip(text, 600),
      kind: clip(kind || 'sistema', 20),
      orderId: orderId || null,
    },
  })
  return NextResponse.json(notification, { status: 201 })
}
