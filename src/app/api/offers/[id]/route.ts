// ============================================================
// API de una oferta de la web
// PATCH  /api/offers/[id] — editar o activar/desactivar
// DELETE /api/offers/[id] — eliminar
// PARCHES DE SEGURIDAD: SOLO el administrador puede editar o
// eliminar ofertas de la web.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { requireAdmin } from '@/lib/session'
import { clip, validPhoto, bodyTooLarge, logSecurityEvent } from '@/lib/security'

export async function PATCH(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json({ error: 'Solo el administrador puede editar ofertas' }, { status: 403 })
  }
  if (bodyTooLarge(req)) {
    return NextResponse.json({ error: 'La foto es demasiado grande' }, { status: 413 })
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}))

  const existing = await db.offer.findUnique({ where: { id } })
  if (!existing) {
    return NextResponse.json({ error: 'La oferta ya no existe' }, { status: 404 })
  }

  const data: Record<string, unknown> = {}
  if (body.title !== undefined) {
    if (!String(body.title).trim()) {
      return NextResponse.json({ error: 'El nombre no puede quedar vacío' }, { status: 400 })
    }
    data.title = clip(body.title, 100)
  }
  if (body.description !== undefined) data.description = clip(body.description, 500)
  if (body.category !== undefined) data.category = clip(body.category, 40)
  if (body.price !== undefined) {
    const p = Number(body.price)
    if (!p || p <= 0 || p > 10_000_000) {
      return NextResponse.json({ error: 'Precio inválido' }, { status: 400 })
    }
    // Al cambiar el precio se guarda el precio anterior
    // automáticamente (para mostrarlo tachado y el % de cambio)
    if (body.oldPrice === undefined && p !== existing.price) {
      data.oldPrice = existing.price
    }
    data.price = p
  }
  if (body.priceCoins !== undefined) data.priceCoins = Math.max(0, Math.floor(Number(body.priceCoins) || 0))
  if (body.oldPrice !== undefined) {
    const o = body.oldPrice === null || body.oldPrice === '' ? null : Number(body.oldPrice)
    data.oldPrice = o && o > 0 ? o : null
  }
  if (body.photo !== undefined) data.photo = validPhoto(body.photo)
  if (body.stock !== undefined) data.stock = Math.max(0, Math.min(100_000, Math.floor(Number(body.stock) || 0)))
  if (body.active !== undefined) data.active = Boolean(body.active)

  try {
    const offer = await db.offer.update({ where: { id }, data })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'offer_updated',
      detail: `Editó la oferta "${offer.title}"`,
    })
    return NextResponse.json(offer)
  } catch {
    return NextResponse.json({ error: 'La oferta ya no existe' }, { status: 404 })
  }
}

export async function DELETE(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json({ error: 'Solo el administrador puede eliminar ofertas' }, { status: 403 })
  }
  const { id } = await params
  try {
    const offer = await db.offer.delete({ where: { id } })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'offer_deleted',
      detail: `Eliminó la oferta "${offer.title}"`,
    })
    return NextResponse.json({ ok: true })
  } catch {
    return NextResponse.json({ error: 'La oferta ya no existe' }, { status: 404 })
  }
}
