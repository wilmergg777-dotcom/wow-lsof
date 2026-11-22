// ============================================================
// API de una mini tienda concreta: ver y eliminar
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

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
  const { id } = await params
  const { ownerName } = await req.json().catch(() => ({ ownerName: '' }))
  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (store.ownerName !== ownerName) {
    return NextResponse.json({ error: 'Solo el dueño puede eliminar la tienda' }, { status: 403 })
  }
  await db.miniStore.delete({ where: { id } })
  return NextResponse.json({ ok: true })
}

// PATCH /api/ministores/[id] — el dueño edita su tienda
// (por ahora: la tarifa que gana el mensajero por entrega)
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json().catch(() => ({}) as Record<string, unknown>)
  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (store.ownerName !== String(body.ownerName || '')) {
    return NextResponse.json(
      { error: 'Solo el dueño puede editar la tienda' },
      { status: 403 }
    )
  }
  const data: { courierFee?: number } = {}
  if (body.courierFee !== undefined) {
    const f = Math.round(Number(body.courierFee) || 0)
    if (f < 0) {
      return NextResponse.json({ error: 'La tarifa no puede ser negativa' }, { status: 400 })
    }
    data.courierFee = f
  }
  const updated = await db.miniStore.update({ where: { id }, data })
  return NextResponse.json(updated)
}
