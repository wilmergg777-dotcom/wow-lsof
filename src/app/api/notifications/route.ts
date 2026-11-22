// ============================================================
// API del mini correo interno (notificaciones)
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// GET /api/notifications?toName=Nombre — bandeja del usuario
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const toName = searchParams.get('toName')
  if (!toName) return NextResponse.json([])
  const notifications = await db.notification.findMany({
    where: { toName },
    orderBy: { createdAt: 'desc' },
    take: 50,
  })
  return NextResponse.json(notifications)
}

// POST /api/notifications — crear una notificación
export async function POST(req: Request) {
  const body = await req.json()
  const { toName, title, body: text, kind, orderId } = body
  if (!toName || !title) {
    return NextResponse.json({ error: 'Faltan destinatario o título' }, { status: 400 })
  }
  const notification = await db.notification.create({
    data: {
      toName: String(toName).trim(),
      title: String(title).trim(),
      body: String(text || '').trim(),
      kind: String(kind || 'sistema'),
      orderId: orderId || null,
    },
  })
  return NextResponse.json(notification, { status: 201 })
}
