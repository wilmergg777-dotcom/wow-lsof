// ============================================================
// API de ofertas de trabajo de domicilio
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// GET /api/joboffers — todas las ofertas abiertas (con datos de la tienda)
export async function GET() {
  const offers = await db.jobOffer.findMany({
    where: { open: true },
    orderBy: { createdAt: 'desc' },
    include: {
      store: { select: { id: true, name: true, emoji: true, category: true, ownerName: true } },
      applications: { select: { id: true, applicantName: true, status: true } },
    },
  })
  return NextResponse.json(offers)
}

// POST /api/joboffers — el dueño de una mini tienda publica una oferta
export async function POST(req: Request) {
  const body = await req.json()
  const { storeId, ownerName, title, zone, payment, description } = body
  const store = await db.miniStore.findUnique({ where: { id: storeId } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (store.ownerName !== ownerName) {
    return NextResponse.json({ error: 'Solo el dueño puede publicar ofertas' }, { status: 403 })
  }
  if (!title || !zone || typeof payment !== 'number' || payment <= 0) {
    return NextResponse.json(
      { error: 'La oferta necesita título, zona y pago válido' },
      { status: 400 }
    )
  }
  const offer = await db.jobOffer.create({
    data: {
      storeId,
      title: String(title).trim(),
      zone: String(zone).trim(),
      payment,
      description: String(description || '').trim(),
    },
    include: { store: { select: { name: true } } },
  })
  return NextResponse.json(offer, { status: 201 })
}
