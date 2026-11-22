// ============================================================
// API de postulaciones a ofertas de trabajo
// PARCHES DE SEGURIDAD (importante: aquí hay datos personales):
// - GET exige sesión. El dueño de la tienda ve las postulaciones
//   de SUS ofertas; el administrador las ve todas; un repartidor
//   solo ve las SUYAS. Antes CUALQUIERA podía leer teléfono y
//   correo de todos los postulantes sin cuenta.
// - POST exige sesión y la postulación queda a nombre de la
//   cuenta de la sesión.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser } from '@/lib/session'
import { clip, rateLimit, RATE, logSecurityEvent } from '@/lib/security'

// GET /api/applications — según quién pregunta:
//   administrador -> todas
//   dueño de tienda -> las de sus tiendas
//   repartidor/comprador -> solo las suyas
export async function GET(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para ver las postulaciones' }, { status: 401 })
  }

  if (sess.user.role === 'administrador') {
    const applications = await db.application.findMany({
      orderBy: { createdAt: 'desc' },
      include: { job: { include: { store: { select: { name: true, emoji: true } } } } },
    })
    return NextResponse.json(applications)
  }

  // Tiendas de las que es dueño esta cuenta
  const myStores = await db.miniStore.findMany({
    where: { ownerName: sess.user.name },
    select: { id: true },
  })
  const myStoreIds = myStores.map((s) => s.id)

  const applications = await db.application.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      job: {
        include: { store: { select: { name: true, emoji: true, ownerName: true, id: true } } },
      },
    },
  })
  const visible = applications.filter(
    (a) =>
      a.applicantName === sess.user.name ||
      (a.job?.store && myStoreIds.includes(a.job.store.id))
  )
  return NextResponse.json(visible)
}

// POST /api/applications — un repartidor postula a una oferta
export async function POST(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para postular a una oferta' }, { status: 401 })
  }
  if (!rateLimit(`application:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const { jobId, phone, email, vehicle, message } = body
  const job = await db.jobOffer.findUnique({ where: { id: String(jobId || '') }, include: { store: true } })
  if (!job || !job.open) {
    return NextResponse.json({ error: 'La oferta no está disponible' }, { status: 404 })
  }
  if (!phone || !email || !vehicle) {
    return NextResponse.json(
      { error: 'Completa todos los campos del formulario' },
      { status: 400 }
    )
  }
  // Un repartidor solo puede postular una vez a cada oferta
  const already = await db.application.findFirst({
    where: { jobId: job.id, applicantName: sess.user.name },
  })
  if (already) {
    return NextResponse.json(
      { error: 'Ya postulaste a esta oferta. Espera la respuesta de la tienda.' },
      { status: 400 }
    )
  }
  const application = await db.application.create({
    data: {
      jobId: job.id,
      applicantName: sess.user.name,
      phone: clip(phone, 25),
      email: clip(email, 80),
      vehicle: clip(vehicle, 30),
      message: clip(message, 500),
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'application_created',
    detail: `Postuló a la oferta "${job.title}" de "${job.store.name}"`,
  })

  // Notificar al dueño de la mini tienda
  await db.notification.create({
    data: {
      toName: job.store.ownerName,
      title: 'Nueva postulación para tu oferta',
      body: `${sess.user.name} quiere trabajar como repartidor en "${job.store.name}" (${job.title}). Revísala en tu mini tienda.`,
      kind: 'trabajo',
    },
  })

  return NextResponse.json(application, { status: 201 })
}
