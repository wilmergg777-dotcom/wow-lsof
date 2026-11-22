// ============================================================
// API de una mini tienda concreta: ver y eliminar
// PARCHES DE SEGURIDAD:
// - Editar o eliminar exige sesión y que la cuenta sea el dueño
//   real de la tienda (o el administrador). Antes el dueño se
//   tomaba del cuerpo de la petición y se podía suplantar.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { bodyTooLarge, clip, logSecurityEvent } from '@/lib/security'

// GET /api/ministores/[id] — detalle con productos
export async function GET(
  _req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const store = await db.miniStore.findUnique({
    where: { id },
    include: { products: { orderBy: { createdAt: 'desc' } } },
  })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  return NextResponse.json(store)
}

// DELETE /api/ministores/[id] — solo el dueño puede eliminarla
export async function DELETE(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para administrar tu tienda' }, { status: 401 })
  }
  const { id } = await params
  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (!isSelfOrAdmin(sess, store.ownerName)) {
    return NextResponse.json({ error: 'Solo el dueño puede eliminar la tienda' }, { status: 403 })
  }
  await db.miniStore.delete({ where: { id } })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'store_deleted',
    detail: `Eliminó la mini tienda "${store.name}"`,
  })
  return NextResponse.json({ ok: true })
}

// PATCH /api/ministores/[id] — el dueño edita su tienda
// (por ahora: la tarifa que gana el mensajero por entrega)
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para administrar tu tienda' }, { status: 401 })
  }
  if (bodyTooLarge(req)) {
    return NextResponse.json({ error: 'Datos demasiado grandes' }, { status: 413 })
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}) as Record<string, unknown>)
  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (!isSelfOrAdmin(sess, store.ownerName)) {
    return NextResponse.json(
      { error: 'Solo el dueño puede editar la tienda' },
      { status: 403 }
    )
  }
  const data: { courierFee?: number; description?: string } = {}
  if (body.courierFee !== undefined) {
    const f = Math.round(Number(body.courierFee) || 0)
    if (f < 0 || f > 10_000) {
      return NextResponse.json({ error: 'La tarifa no es válida' }, { status: 400 })
    }
    data.courierFee = f
  }
  if (body.description !== undefined) {
    data.description = clip(body.description, 300)
  }
  const updated = await db.miniStore.update({ where: { id }, data })
  return NextResponse.json(updated)
}
