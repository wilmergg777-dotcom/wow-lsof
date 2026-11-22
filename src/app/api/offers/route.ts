// ============================================================
// API de ofertas de la web (las publica el dueño de la página)
// GET  /api/offers       — ofertas activas (público)
// GET  /api/offers?all=1 — todas, incluso desactivadas (panel)
// POST /api/offers       — publicar una nueva oferta
// PARCHES DE SEGURIDAD:
// - SOLO el administrador puede publicar ofertas.
// - Límite de tamaño del cuerpo (anti DoS con fotos gigantes).
// La primera vez que se leen, si la web es una instalación
// nueva, se publican las ofertas de bienvenida (src/lib/seed.ts)
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { ensureCatalogSeed } from '@/lib/seed'
import { requireAdmin } from '@/lib/session'
import { clip, validPhoto, bodyTooLarge, logSecurityEvent } from '@/lib/security'

export async function GET(req: Request) {
  await ensureCatalogSeed().catch(() => {})
  const url = new URL(req.url)
  const all = url.searchParams.get('all') === '1'
  const offers = await db.offer.findMany({
    where: all ? {} : { active: true },
    orderBy: { createdAt: 'desc' },
  })
  return NextResponse.json(offers)
}

export async function POST(req: Request) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json({ error: 'Solo el administrador puede publicar ofertas' }, { status: 403 })
  }
  if (bodyTooLarge(req)) {
    return NextResponse.json({ error: 'La foto es demasiado grande' }, { status: 413 })
  }
  const body = await req.json().catch(() => ({}))
  const { title, description, category, price, priceCoins, oldPrice, photo, stock } = body

  if (!title || !String(title).trim()) {
    return NextResponse.json({ error: 'La oferta necesita un nombre' }, { status: 400 })
  }
  const priceNum = Number(price)
  if (!priceNum || priceNum <= 0 || priceNum > 10_000_000) {
    return NextResponse.json(
      { error: 'Pon el precio en dinero (CUP) mayor que 0' },
      { status: 400 }
    )
  }
  const coinsNum = Number(priceCoins) || 0
  if (coinsNum < 0 || coinsNum > 1_000_000_000) {
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
      title: clip(title, 100),
      description: clip(description, 500),
      category: clip(category || 'Electrónica', 40),
      price: priceNum,
      priceCoins: coinsNum,
      oldPrice: oldNum,
      photo: validPhoto(photo),
      stock: Number(stock) > 0 ? Math.min(100_000, Math.floor(Number(stock))) : 20,
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'offer_created',
    detail: `Publicó la oferta "${offer.title}"`,
  })

  return NextResponse.json(offer, { status: 201 })
}
