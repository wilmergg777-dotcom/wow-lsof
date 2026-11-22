// ============================================================
// API de una postulación: aceptar o rechazar (decide el dueño)
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// PATCH /api/applications/[id] — { status: 'accepted' | 'rejected', ownerName }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json()
  const application = await db.application.findUnique({
    where: { id },
    include: { job: { include: { store: true } } },
  })
  if (!application) {
    return NextResponse.json({ error: 'Postulación no encontrada' }, { status: 404 })
  }
  if (application.job.store.ownerName !== body.ownerName) {
    return NextResponse.json({ error: 'Solo el dueño puede decidir' }, { status: 403 })
  }

  const status = body.status === 'accepted' ? 'accepted' : 'rejected'
  const updated = await db.application.update({ where: { id }, data: { status } })

  // Notificar al postulante con el resultado
  await db.notification.create({
    data: {
      toName: application.applicantName,
      title:
        status === 'accepted'
          ? `¡Fuiste aceptado en ${application.job.store.name}!`
          : `Tu postulación en ${application.job.store.name} fue rechazada`,
      body:
        status === 'accepted'
          ? `Felicidades ${application.applicantName}. ${body.ownerName} te aceptó como repartidor de "${application.job.store.name}" (${application.job.title}, zona ${application.job.zone}). Ya puedes ver los pedidos de entrega desde la opción "Entregas".`
          : `Lo sentimos, ${body.ownerName} no seleccionó tu postulación para "${application.job.title}". ¡Sigue intentando con otras ofertas!`,
      kind: 'trabajo',
    },
  })

  return NextResponse.json(updated)
}
