// ============================================================
// API de una postulación: aceptar o rechazar (decide el dueño)
// PARCHES DE SEGURIDAD: la decisión exige sesión y que la cuenta
// sea el dueño real de la tienda (o el administrador).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { logSecurityEvent } from '@/lib/security'

// PATCH /api/applications/[id] — { status: 'accepted' | 'rejected' }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para revisar postulaciones' }, { status: 401 })
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}))
  const application = await db.application.findUnique({
    where: { id },
    include: { job: { include: { store: true } } },
  })
  if (!application) {
    return NextResponse.json({ error: 'Postulación no encontrada' }, { status: 404 })
  }
  if (!isSelfOrAdmin(sess, application.job.store.ownerName)) {
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
          ? `Felicidades ${application.applicantName}. ${sess.user.name} te aceptó como repartidor de "${application.job.store.name}" (${application.job.title}, zona ${application.job.zone}). Ya puedes ver los pedidos de entrega desde la opción "Entregas".`
          : `Lo sentimos, ${sess.user.name} no seleccionó tu postulación para "${application.job.title}". ¡Sigue intentando con otras ofertas!`,
      kind: 'trabajo',
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'application_reviewed',
    detail: `Postulación de ${application.applicantName} en "${application.job.store.name}": ${status}`,
  })

  return NextResponse.json(updated)
}
