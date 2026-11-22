// ============================================================
// API de un pedido: el repartidor lo toma o lo entrega
// PARCHES DE SEGURIDAD:
// - Tomar un pedido exige sesión: el repartidor es SIEMPRE la
//   cuenta de la sesión (no el nombre que mande el navegador).
// - Marcar entregado: solo el repartidor asignado o el admin.
// - Liquidar: solo el dueño real de la tienda (por su sesión)
//   o el administrador.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { logSecurityEvent } from '@/lib/security'
import { formatPrice } from '@/lib/products'

// PATCH /api/orders/[id] — { action: 'take' | 'deliver' | 'settle' }
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Inicia sesión para trabajar como repartidor' },
      { status: 401 }
    )
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}))
  const order = await db.order.findUnique({ where: { id } })
  if (!order) return NextResponse.json({ error: 'Pedido no encontrado' }, { status: 404 })

  if (body.action === 'take') {
    if (order.status !== 'placed') {
      return NextResponse.json({ error: 'El pedido ya no está disponible' }, { status: 400 })
    }
    // Carrera por el pedido: solo gana la primera sesión que lo toma
    const taken = await db.order.updateMany({
      where: { id, status: 'placed' },
      data: { status: 'in_delivery', workerName: sess.user.name },
    })
    if (taken.count === 0) {
      return NextResponse.json({ error: 'El pedido ya no está disponible' }, { status: 400 })
    }
    const updated = await db.order.findUnique({ where: { id } })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'order_taken',
      detail: `Tomó el pedido ${order.code} para entrega`,
    })
    // Notificar al comprador: su pedido salió para entrega
    await db.notification.create({
      data: {
        toName: order.buyerName,
        title: `Pedido ${order.code} en camino`,
        body: `${sess.user.name} salió a entregar tu pedido. Entrega estimada en ${order.etaMinutes} minutos en: ${order.address}`,
        kind: 'pedido',
        orderId: order.id,
      },
    })
    return NextResponse.json(updated)
  }

  if (body.action === 'deliver') {
    // Solo el repartidor asignado (o el administrador) puede marcar entregado
    if (!isSelfOrAdmin(sess, order.workerName || '')) {
      return NextResponse.json(
        { error: 'Solo el repartidor asignado puede marcar este pedido como entregado' },
        { status: 403 }
      )
    }
    const updated = await db.order.update({
      where: { id },
      data: { status: 'delivered' },
    })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'order_delivered',
      detail: `Pedido ${order.code} entregado`,
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
    const storeIds = order.storeIds.split(',').filter(Boolean)
    let allowed = sess.user.role === 'administrador'
    if (!allowed && storeIds.length) {
      const myStores = await db.miniStore.findMany({ where: { ownerName: sess.user.name } })
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
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'order_settled',
      detail: `Liquidó el pedido ${order.code}`,
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
