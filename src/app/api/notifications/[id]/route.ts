// ============================================================
// API de una notificación: marcar como leída
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// PATCH /api/notifications/[id] — marcar leída { read: true }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json().catch(() => ({}))
  const updated = await db.notification.update({
    where: { id },
    data: { read: body.read !== false },
  })
  return NextResponse.json(updated)
}
