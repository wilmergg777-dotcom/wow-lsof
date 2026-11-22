// ============================================================
// API de productos de una mini tienda: agregar producto
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// POST /api/ministores/[id]/products — el dueño agrega un producto
export async function POST(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json()
  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (store.ownerName !== body.ownerName) {
    return NextResponse.json({ error: 'Solo el dueño puede agregar productos' }, { status: 403 })
  }
  const { name, description, price, priceCoins, emoji, photo, stock } = body
  if (!name || typeof price !== 'number' || price <= 0) {
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
      name: String(name).trim(),
      description: String(description || '').trim(),
      price,
      priceCoins: coins,
      emoji: String(emoji || '📦'),
      photo:
        typeof photo === 'string' &&
        (photo.startsWith('data:image') || photo.startsWith('/gallery/'))
          ? photo
          : null,
      stock: Number(stock) > 0 ? Number(stock) : 20,
    },
  })
  return NextResponse.json(product, { status: 201 })
}
