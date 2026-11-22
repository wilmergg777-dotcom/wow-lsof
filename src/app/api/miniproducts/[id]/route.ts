// ============================================================
// API de un producto de mini tienda: editar y eliminar
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// PATCH /api/miniproducts/[id] — editar datos del almacén (solo el dueño):
// cantidad a la venta, precio en CUP y precio en monedas
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json().catch(() => ({}) as Record<string, unknown>)
  const product = await db.miniProduct.findUnique({ where: { id }, include: { store: true } })
  if (!product) return NextResponse.json({ error: 'Producto no encontrado' }, { status: 404 })
  if (product.store.ownerName !== String(body.ownerName || '')) {
    return NextResponse.json(
      { error: 'Solo el dueño de la tienda puede editar el almacén' },
      { status: 403 }
    )
  }
  const data: {
    stock?: number
    price?: number
    priceCoins?: number
  } = {}
  if (body.stock !== undefined) {
    data.stock = Math.max(0, Math.floor(Number(body.stock) || 0))
  }
  if (body.price !== undefined) {
    const p = Number(body.price)
    if (p > 0) data.price = p
  }
  if (body.priceCoins !== undefined) {
    data.priceCoins = Math.max(0, Math.floor(Number(body.priceCoins) || 0))
  }
  const updated = await db.miniProduct.update({ where: { id }, data })
  return NextResponse.json(updated)
}

// DELETE /api/miniproducts/[id] — solo el dueño de la tienda
export async function DELETE(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const { ownerName } = await req.json().catch(() => ({ ownerName: '' }))
  const product = await db.miniProduct.findUnique({ where: { id }, include: { store: true } })
  if (!product) return NextResponse.json({ error: 'Producto no encontrado' }, { status: 404 })
  if (product.store.ownerName !== ownerName) {
    return NextResponse.json({ error: 'Solo el dueño puede eliminar productos' }, { status: 403 })
  }
  await db.miniProduct.delete({ where: { id } })
  return NextResponse.json({ ok: true })
}
