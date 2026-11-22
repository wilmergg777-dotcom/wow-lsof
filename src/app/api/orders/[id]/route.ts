// ============================================================
// API de un pedido: el repartidor lo toma o lo entrega
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { formatPrice } from '@/lib/products'

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
    // Si el pago fue en EFECTIVO, el mensajero lleva el dinero y
    // queda PENDIENTE DE PAGO al dueño de la mini tienda (o al
    // dueño de la web). Se avisa al dueño para su liquidación.
    if (order.paymentMethod === 'cash') {
      const storeIds = order.storeIds.split(',').filter(Boolean)
      const pending = Math.max(0, order.total - order.courierFee)
      for (const sid of storeIds) {
        const store = await db.miniStore.findUnique({ where: { id: sid } })
        if (!store) continue
        await db.notification.create({
          data: {
            toName: store.ownerName,
            title: `Pedido ${order.code}: pago pendiente de liquidación`,
            body: `El mensajero${order.workerName ? ` ${order.workerName}` : ''} cobró ${formatPrice(order.total)} en efectivo. Te debe entregar ${formatPrice(pending)} (tu parte: el total menos ${formatPrice(order.courierFee)} de tarifa del mensajero). Líquida el pedido en tu panel cuando recibas el dinero.`,
            kind: 'pedido',
            orderId: order.id,
          },
        })
      }
      if (order.workerName) {
        await db.notification.create({
          data: {
            toName: order.workerName,
            title: `Pedido ${order.code} entregado con dinero en mano`,
            body: `Cobraste ${formatPrice(order.total)} en efectivo. Tu ganancia es ${formatPrice(order.courierFee)} y debes entregar ${formatPrice(pending)} al dueño de la tienda cuando te pague.`,
            kind: 'pedido',
            orderId: order.id,
          },
        })
      }
    }
    return NextResponse.json(updated)
  }

  // LIQUIDACIÓN: el mensajero ya entregó el dinero cobrado al
  // dueño de la mini tienda (o al dueño de la web)
  if (body.action === 'settle') {
    const name = String(body.ownerName || '').trim()
    if (!name) return NextResponse.json({ error: 'Falta el nombre del dueño' }, { status: 400 })
    const user = await db.user.findUnique({ where: { name } })
    const storeIds = order.storeIds.split(',').filter(Boolean)
    let allowed = user?.role === 'administrador'
    if (!allowed && storeIds.length) {
      const myStores = await db.miniStore.findMany({ where: { ownerName: name } })
      allowed = myStores.some((s) => storeIds.includes(s.id))
    }
    // Pedidos solo de la web (sin tiendas): solo el administrador
    if (!allowed) {
      return NextResponse.json(
        { error: 'Solo el dueño de la tienda o el administrador puede liquidar este pedido' },
        { status: 403 }
      )
    }
    if (order.settled) {
      return NextResponse.json({ error: 'Este pedido ya está liquidado' }, { status: 400 })
    }
    const updated = await db.order.update({
      where: { id },
      data: { settled: true, settledAt: new Date() },
    })
    const pending = Math.max(0, order.total - order.courierFee)
    if (order.workerName) {
      await db.notification.create({
        data: {
          toName: order.workerName,
          title: `Pedido ${order.code}: liquidación confirmada`,
          body: `El dueño de la tienda confirmó que le entregaste el dinero cobrado. Ya te pagaron tus ${formatPrice(order.courierFee)} de ganancia por la entrega.`,
          kind: 'pedido',
          orderId: order.id,
        },
      })
    }
    return NextResponse.json({ order: updated, pendingHandedOver: pending })
  }

  return NextResponse.json({ error: 'Acción no válida' }, { status: 400 })
}
