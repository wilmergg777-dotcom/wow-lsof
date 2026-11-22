// ============================================================
// API de un producto de mini tienda: editar y eliminar
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

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
