// ============================================================
// API de una oferta de la web
// PATCH  /api/offers/[id] — editar o activar/desactivar
// DELETE /api/offers/[id] — eliminar
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

export async function PATCH(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const body = await req.json()

  const data: Record<string, unknown> = {}
  if (body.title !== undefined) {
    if (!String(body.title).trim()) {
      return NextResponse.json({ error: 'El nombre no puede quedar vacío' }, { status: 400 })
    }
    data.title = String(body.title).trim()
  }
  if (body.description !== undefined) data.description = String(body.description).trim()
  if (body.category !== undefined) data.category = String(body.category)
  if (body.price !== undefined) {
    const p = Number(body.price)
    if (!p || p <= 0) {
      return NextResponse.json({ error: 'Precio inválido' }, { status: 400 })
    }
    data.price = p
  }
  if (body.priceCoins !== undefined) data.priceCoins = Math.max(0, Math.floor(Number(body.priceCoins) || 0))
  if (body.oldPrice !== undefined) {
    const o = body.oldPrice === null || body.oldPrice === '' ? null : Number(body.oldPrice)
    data.oldPrice = o && o > 0 ? o : null
  }
  if (body.photo !== undefined) {
    data.photo =
      typeof body.photo === 'string' &&
      (body.photo.startsWith('data:image') || body.photo.startsWith('/gallery/'))
        ? body.photo
        : null
  }
  if (body.stock !== undefined) data.stock = Math.max(0, Math.floor(Number(body.stock) || 0))
  if (body.active !== undefined) data.active = Boolean(body.active)

  try {
    const offer = await db.offer.update({ where: { id }, data })
    return NextResponse.json(offer)
  } catch {
    return NextResponse.json({ error: 'La oferta ya no existe' }, { status: 404 })
  }
}

export async function DELETE(_req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  try {
    await db.offer.delete({ where: { id } })
    return NextResponse.json({ ok: true })
  } catch {
    return NextResponse.json({ error: 'La oferta ya no existe' }, { status: 404 })
  }
}
