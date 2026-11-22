// ============================================================
// API de solicitudes de recarga de saldo
// El usuario envía una transferencia real a la cuenta del
// administrador y registra el ID de la transferencia. Queda
// "pendiente" hasta que el administrador la revisa y aprueba.
// PARCHES DE SEGURIDAD:
// - GET exige sesión: el administrador ve todas, cada usuario
//   solo las suyas (antes se podían leer TODAS las recargas).
// - POST exige sesión y la recarga se registra a nombre de la
//   cuenta de la sesión (no del nombre que mande el navegador).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { formatPrice } from '@/lib/products'
import { getSessionUser } from '@/lib/session'
import { rateLimit, RATE, clip, logSecurityEvent } from '@/lib/security'

async function getSettings() {
  let settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  if (!settings) settings = await db.siteSettings.create({ data: { id: 'main' } })
  return settings
}

// GET /api/topups — el administrador ve todas; el usuario solo las suyas
export async function GET(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para ver tus recargas' }, { status: 401 })
  }
  const isAdmin = sess.user.role === 'administrador'
  const requests = await db.topUpRequest.findMany({
    where: isAdmin ? {} : { userName: sess.user.name },
    orderBy: { createdAt: 'desc' },
    take: 100,
  })
  return NextResponse.json(requests)
}

// POST /api/topups — el usuario registra su transferencia
export async function POST(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Inicia sesión para solicitar una recarga' },
      { status: 401 }
    )
  }
  if (!rateLimit(`topup:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const methodName = clip(body.methodName, 40)
  const amount = Number(body.amountCash)
  const transferId = clip(body.transferId, 60)

  if (!methodName || !amount || !transferId) {
    return NextResponse.json(
      { error: 'Faltan datos: método, monto enviado e ID de transferencia' },
      { status: 400 }
    )
  }
  if (!amount || amount <= 0 || amount > 1_000_000) {
    return NextResponse.json({ error: 'El monto enviado debe ser mayor que 0' }, { status: 400 })
  }

  const settings = await getSettings()
  const coins = Math.round(amount * settings.coinRate)

  const request = await db.topUpRequest.create({
    data: {
      userName: sess.user.name,
      methodName,
      amountCash: amount,
      coins,
      transferId,
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'topup_requested',
    detail: `Solicitud de recarga de ${formatPrice(amount)} por "${methodName}" (ID ${transferId})`,
  })

  // Notificación al administrador para que revise la recarga
  await db.notification.create({
    data: {
      toName: 'Administrador',
      title: 'Nueva solicitud de recarga',
      body: `${request.userName} envió ${formatPrice(amount)} por "${request.methodName}". ID de transferencia: ${request.transferId}. Revisa y acredita ${coins} monedas desde el panel de administración.`,
      kind: 'recarga',
    },
  })

  return NextResponse.json(request, { status: 201 })
}
