// ============================================================
// API de productos de una mini tienda: agregar producto
// PARCHES DE SEGURIDAD:
// - Exige sesión y que la cuenta sea el dueño real de la tienda.
// - Límite de tamaño de la foto y de los textos.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { clip, validPhoto, bodyTooLarge, logSecurityEvent } from '@/lib/security'

// POST /api/ministores/[id]/products — el dueño agrega un producto
export async function POST(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para administrar tu tienda' }, { status: 401 })
  }
  if (bodyTooLarge(req)) {
    return NextResponse.json({ error: 'La foto es demasiado grande' }, { status: 413 })
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}))
  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (!isSelfOrAdmin(sess, store.ownerName)) {
    return NextResponse.json({ error: 'Solo el dueño puede agregar productos' }, { status: 403 })
  }
  const { name, description, price, priceCoins, emoji, photo, stock } = body
  if (!name || typeof price !== 'number' || price <= 0 || price > 10_000_000) {
    return NextResponse.json({ error: 'El producto necesita nombre y precio válido' }, { status: 400 })
  }
  const settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  const rate = settings?.coinRate || 100
  // Si el dueño no pone precio en monedas, se calcula con la tasa de cambio
  const coins =
    typeof priceCoins === 'number' && priceCoins > 0
      ? Math.round(priceCoins)
      : Math.round(price * rate)
  const product = await db.miniProduct.create({
    data: {
      storeId: id,
      name: clip(name, 100),
      description: clip(description, 500),
      price,
      priceCoins: Math.min(1_000_000_000, coins),
      emoji: clip(emoji || '📦', 8),
      photo: validPhoto(photo),
      stock: Number(stock) > 0 ? Math.min(100_000, Number(stock)) : 20,
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'product_created',
    detail: `Agregó el producto "${product.name}" a "${store.name}"`,
  })
  return NextResponse.json(product, { status: 201 })
}
