// ============================================================
// API de un producto de mini tienda: editar y eliminar
// PARCHES DE SEGURIDAD:
// - Exige sesión y que la cuenta sea el dueño real de la tienda
//   (antes el dueño se tomaba del cuerpo y se podía suplantar).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { bodyTooLarge, logSecurityEvent } from '@/lib/security'

// PATCH /api/miniproducts/[id] — editar datos del almacén (solo el dueño):
// cantidad a la venta, precio en CUP y precio en monedas
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
  const product = await db.miniProduct.findUnique({ where: { id }, include: { store: true } })
  if (!product) return NextResponse.json({ error: 'Producto no encontrado' }, { status: 404 })
  if (!isSelfOrAdmin(sess, product.store.ownerName)) {
    return NextResponse.json(
      { error: 'Solo el dueño de la tienda puede editar el almacén' },
      { status: 403 }
    )
  }
  const data: {
    stock?: number
    price?: number
    oldPrice?: number | null
    priceCoins?: number
  } = {}
  if (body.stock !== undefined) {
    data.stock = Math.max(0, Math.min(100_000, Math.floor(Number(body.stock) || 0)))
  }
  if (body.price !== undefined) {
    const p = Number(body.price)
    if (p > 0 && p <= 10_000_000) {
      // Al cambiar el precio se guarda el precio anterior
      // automáticamente (para mostrarlo tachado y el % de cambio)
      if (body.oldPrice === undefined && p !== product.price) {
        data.oldPrice = product.price
      }
      data.price = p
    }
  }
  if (body.oldPrice !== undefined) {
    const o = body.oldPrice === null || body.oldPrice === '' ? null : Number(body.oldPrice)
    data.oldPrice = o && o > 0 && o <= 10_000_000 ? o : null
  }
  if (body.priceCoins !== undefined) {
    data.priceCoins = Math.max(0, Math.min(1_000_000_000, Math.floor(Number(body.priceCoins) || 0)))
  }
  const updated = await db.miniProduct.update({ where: { id }, data })
  return NextResponse.json(updated)
}

// DELETE /api/miniproducts/[id] — solo el dueño de la tienda
export async function DELETE(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para administrar tu tienda' }, { status: 401 })
  }
  const { id } = await params
  const product = await db.miniProduct.findUnique({ where: { id }, include: { store: true } })
  if (!product) return NextResponse.json({ error: 'Producto no encontrado' }, { status: 404 })
  if (!isSelfOrAdmin(sess, product.store.ownerName)) {
    return NextResponse.json({ error: 'Solo el dueño puede eliminar productos' }, { status: 403 })
  }
  await db.miniProduct.delete({ where: { id } })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'product_deleted',
    detail: `Eliminó el producto "${product.name}"`,
  })
  return NextResponse.json({ ok: true })
}
