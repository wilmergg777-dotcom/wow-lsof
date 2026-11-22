// ============================================================
// API de una oferta de trabajo: cerrar o eliminar
// PARCHES DE SEGURIDAD: solo el dueño de la tienda (verificado
// con su sesión) o el administrador.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { logSecurityEvent } from '@/lib/security'

// PATCH /api/joboffers/[id] — cerrar la oferta { open: false }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para administrar tus ofertas' }, { status: 401 })
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}))
  const offer = await db.jobOffer.findUnique({
    where: { id },
    include: { store: true },
  })
  if (!offer) return NextResponse.json({ error: 'Oferta no encontrada' }, { status: 404 })
  if (!isSelfOrAdmin(sess, offer.store.ownerName)) {
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
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para administrar tus ofertas' }, { status: 401 })
  }
  const { id } = await params
  const offer = await db.jobOffer.findUnique({ where: { id }, include: { store: true } })
  if (!offer) return NextResponse.json({ error: 'Oferta no encontrada' }, { status: 404 })
  if (!isSelfOrAdmin(sess, offer.store.ownerName)) {
    return NextResponse.json({ error: 'Solo el dueño puede eliminar la oferta' }, { status: 403 })
  }
  await db.jobOffer.delete({ where: { id } })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'joboffer_deleted',
    detail: `Eliminó la oferta de trabajo "${offer.title}"`,
  })
  return NextResponse.json({ ok: true })
}
