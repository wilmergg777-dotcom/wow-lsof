// ============================================================
// API de ofertas de trabajo de domicilio
// PARCHES DE SEGURIDAD:
// - Publicar una oferta exige sesión y ser el dueño real de la
//   tienda (el nombre ya no se acepta del navegador).
// - Cerrar/eliminar: solo el dueño o el administrador.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { clip, rateLimit, RATE, logSecurityEvent } from '@/lib/security'

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
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para publicar ofertas de trabajo' }, { status: 401 })
  }
  if (!rateLimit(`joboffer:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const { storeId, title, zone, payment, description } = body
  const store = await db.miniStore.findUnique({ where: { id: String(storeId || '') } })
  if (!store) return NextResponse.json({ error: 'Mini tienda no encontrada' }, { status: 404 })
  if (!isSelfOrAdmin(sess, store.ownerName)) {
    return NextResponse.json({ error: 'Solo el dueño puede publicar ofertas' }, { status: 403 })
  }
  const paymentNum = Number(payment)
  if (!title || !zone || !paymentNum || paymentNum <= 0 || paymentNum > 1_000_000) {
    return NextResponse.json(
      { error: 'La oferta necesita título, zona y pago válido' },
      { status: 400 }
    )
  }
  const offer = await db.jobOffer.create({
    data: {
      storeId,
      title: clip(title, 80),
      zone: clip(zone, 60),
      payment: paymentNum,
      description: clip(description, 300),
    },
    include: { store: { select: { name: true } } },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'joboffer_created',
    detail: `Publicó la oferta de trabajo "${offer.title}" en "${store.name}"`,
  })
  return NextResponse.json(offer, { status: 201 })
}
