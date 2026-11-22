// ============================================================
// API de una oferta de trabajo: cerrar o eliminar
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// PATCH /api/joboffers/[id] — cerrar la oferta { open: false }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json()
  const offer = await db.jobOffer.findUnique({
    where: { id },
    include: { store: true },
  })
  if (!offer) return NextResponse.json({ error: 'Oferta no encontrada' }, { status: 404 })
  if (offer.store.ownerName !== body.ownerName) {
    return NextResponse.json({ error: 'Solo el dueño puede cerrar la oferta' }, { status: 403 })
  }
  const updated = await db.jobOffer.update({
    where: { id },
    data: { open: !!body.open },
  })
  return NextResponse.json(updated)
}

// DELETE /api/joboffers/[id] — eliminar la oferta
export async function DELETE(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const { ownerName } = await req.json().catch(() => ({ ownerName: '' }))
  const offer = await db.jobOffer.findUnique({ where: { id }, include: { store: true } })
  if (!offer) return NextResponse.json({ error: 'Oferta no encontrada' }, { status: 404 })
  if (offer.store.ownerName !== ownerName) {
    return NextResponse.json({ error: 'Solo el dueño puede eliminar la oferta' }, { status: 403 })
  }
  await db.jobOffer.delete({ where: { id } })
  return NextResponse.json({ ok: true })
}
