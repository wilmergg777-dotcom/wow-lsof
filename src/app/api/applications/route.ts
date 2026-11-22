// ============================================================
// API de postulaciones a ofertas de trabajo
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// GET /api/applications?jobId=... — postulaciones de una oferta
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const jobId = searchParams.get('jobId')
  const applications = await db.application.findMany({
    where: jobId ? { jobId } : undefined,
    orderBy: { createdAt: 'desc' },
    include: { job: { include: { store: { select: { name: true, emoji: true } } } } },
  })
  return NextResponse.json(applications)
}

// POST /api/applications — un repartidor postula a una oferta
export async function POST(req: Request) {
  const body = await req.json()
  const { jobId, applicantName, phone, email, vehicle, message } = body
  const job = await db.jobOffer.findUnique({ where: { id: jobId }, include: { store: true } })
  if (!job || !job.open) {
    return NextResponse.json({ error: 'La oferta no está disponible' }, { status: 404 })
  }
  if (!applicantName || !phone || !email || !vehicle) {
    return NextResponse.json(
      { error: 'Completa todos los campos del formulario' },
      { status: 400 }
    )
  }
  const application = await db.application.create({
    data: {
      jobId,
      applicantName: String(applicantName).trim(),
      phone: String(phone).trim(),
      email: String(email).trim(),
      vehicle: String(vehicle),
      message: String(message || '').trim(),
    },
  })

  // Notificar al dueño de la mini tienda
  await db.notification.create({
    data: {
      toName: job.store.ownerName,
      title: 'Nueva postulación para tu oferta',
      body: `${applicantName} quiere trabajar como repartidor en "${job.store.name}" (${job.title}). Revísala en tu mini tienda.`,
      kind: 'trabajo',
    },
  })

  return NextResponse.json(application, { status: 201 })
}
