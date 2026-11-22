// ============================================================
// API de un pedido: el repartidor lo toma o lo entrega
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// PATCH /api/orders/[id] — { action: 'take' | 'deliver', workerName }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json()
  const order = await db.order.findUnique({ where: { id } })
  if (!order) return NextResponse.json({ error: 'Pedido no encontrado' }, { status: 404 })

  if (body.action === 'take') {
    if (order.status !== 'placed') {
      return NextResponse.json({ error: 'El pedido ya no está disponible' }, { status: 400 })
    }
    const updated = await db.order.update({
      where: { id },
      data: { status: 'in_delivery', workerName: String(body.workerName || 'Repartidor') },
    })
    // Notificar al comprador: su pedido salió para entrega
    await db.notification.create({
      data: {
        toName: order.buyerName,
        title: `Pedido ${order.code} en camino`,
        body: `${body.workerName} salió a entregar tu pedido. Entrega estimada en ${order.etaMinutes} minutos en: ${order.address}`,
        kind: 'pedido',
        orderId: order.id,
      },
    })
    return NextResponse.json(updated)
  }

  if (body.action === 'deliver') {
    const updated = await db.order.update({
      where: { id },
      data: { status: 'delivered' },
    })
    // Notificar al comprador: pedido entregado
    await db.notification.create({
      data: {
        toName: order.buyerName,
        title: `Pedido ${order.code} entregado`,
        body: `Tu pedido fue entregado en ${order.address}. ¡Esperamos que lo disfrutes!`,
        kind: 'pedido',
        orderId: order.id,
      },
    })
    return NextResponse.json(updated)
  }

  return NextResponse.json({ error: 'Acción no válida' }, { status: 400 })
}
