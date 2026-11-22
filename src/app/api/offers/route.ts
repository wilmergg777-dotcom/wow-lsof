// ============================================================
// API de ofertas de la web (las publica el dueño de la página)
// GET  /api/offers       — ofertas activas (público)
// GET  /api/offers?all=1 — todas, incluso desactivadas (panel)
// POST /api/offers       — publicar una nueva oferta
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

export async function GET(req: Request) {
  const url = new URL(req.url)
  const all = url.searchParams.get('all') === '1'
  const offers = await db.offer.findMany({
    where: all ? {} : { active: true },
    orderBy: { createdAt: 'desc' },
  })
  return NextResponse.json(offers)
}

export async function POST(req: Request) {
  const body = await req.json()
  const { title, description, category, price, priceCoins, oldPrice, photo, stock } = body

  if (!title || !String(title).trim()) {
    return NextResponse.json({ error: 'La oferta necesita un nombre' }, { status: 400 })
  }
  const priceNum = Number(price)
  if (!priceNum || priceNum <= 0) {
    return NextResponse.json(
      { error: 'Pon el precio en dinero (CUP) mayor que 0' },
      { status: 400 }
    )
  }
  const coinsNum = Number(priceCoins) || 0
  if (coinsNum < 0) {
    return NextResponse.json({ error: 'El precio en monedas no puede ser negativo' }, { status: 400 })
  }
  const oldNum = oldPrice === undefined || oldPrice === null || oldPrice === '' ? null : Number(oldPrice)
  if (oldNum !== null && (!oldNum || oldNum <= priceNum)) {
    return NextResponse.json(
      { error: 'El precio anterior debe ser mayor que el precio de oferta' },
      { status: 400 }
    )
  }

  const offer = await db.offer.create({
    data: {
      title: String(title).trim(),
      description: String(description || '').trim(),
      category: String(category || 'Electrónica'),
      price: priceNum,
      priceCoins: coinsNum,
      oldPrice: oldNum,
      photo:
        typeof photo === 'string' && (photo.startsWith('data:image') || photo.startsWith('/gallery/'))
          ? photo
          : null,
      stock: Number(stock) > 0 ? Math.floor(Number(stock)) : 20,
    },
  })

  return NextResponse.json(offer, { status: 201 })
}
