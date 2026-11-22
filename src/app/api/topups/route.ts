// ============================================================
// API de solicitudes de recarga de saldo
// El usuario envía una transferencia real a la cuenta del
// administrador y registra el ID de la transferencia. Queda
// "pendiente" hasta que el administrador la revisa y aprueba.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

async function getSettings() {
  let settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  if (!settings) settings = await db.siteSettings.create({ data: { id: 'main' } })
  return settings
}

// GET /api/topups           — todas (panel del administrador)
// GET /api/topups?name=X    — solo las del usuario X
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const name = searchParams.get('name')
  const requests = await db.topUpRequest.findMany({
    where: name ? { userName: name } : {},
    orderBy: { createdAt: 'desc' },
    take: 100,
  })
  return NextResponse.json(requests)
}

// POST /api/topups — el usuario registra su transferencia
export async function POST(req: Request) {
  const body = await req.json()
  const { userName, methodName, amountCash, transferId } = body
  if (!userName || !methodName || !amountCash || !transferId) {
    return NextResponse.json(
      { error: 'Faltan datos: usuario, método, monto enviado e ID de transferencia' },
      { status: 400 }
    )
  }
  const amount = Number(amountCash)
  if (!amount || amount <= 0) {
    return NextResponse.json({ error: 'El monto enviado debe ser mayor que 0' }, { status: 400 })
  }
  const settings = await getSettings()
  const coins = Math.round(amount * settings.coinRate)

  const request = await db.topUpRequest.create({
    data: {
      userName: String(userName).trim(),
      methodName: String(methodName).trim(),
      amountCash: amount,
      coins,
      transferId: String(transferId).trim(),
    },
  })

  // Notificación al administrador para que revise la recarga
  await db.notification.create({
    data: {
      toName: 'Administrador',
      title: 'Nueva solicitud de recarga',
      body: `${request.userName} envió $${amount.toFixed(2)} por "${request.methodName}". ID de transferencia: ${request.transferId}. Revisa y acredita ${coins} monedas desde el panel de administración.`,
      kind: 'recarga',
    },
  })

  return NextResponse.json(request, { status: 201 })
}
