// ============================================================
// API de pedidos (compras con entrega a domicilio)
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { formatPrice } from '@/lib/products'

// Tiempo estimado según la distancia en el mini mapa (0-100, centro = 50,50)
function calcEta(mapX: number, mapY: number) {
  const dist = Math.sqrt((mapX - 50) ** 2 + (mapY - 50) ** 2)
  return Math.round(dist * 1.4) + 15 // entre 15 y ~95 minutos
}

// GET /api/orders?buyer=Nombre  |  ?status=placed  |  ?worker=Nombre
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const buyer = searchParams.get('buyer')
  const worker = searchParams.get('worker')
  const status = searchParams.get('status')

  const orders = await db.order.findMany({
    where: {
      ...(buyer ? { buyerName: buyer } : {}),
      ...(worker ? { workerName: worker } : {}),
      ...(status ? { status } : {}),
    },
    orderBy: { createdAt: 'desc' },
  })
  return NextResponse.json(orders)
}

// POST /api/orders — crear pedido desde el carrito
// paymentMethod: "cash" (efectivo al recibir) | "coins" (monedas internas)
//                | "transfer" (transferencia bancaria en CUP con su ID)
export async function POST(req: Request) {
  const body = await req.json()
  const { buyerName, address, notes, mapX, mapY, items, total, paymentMethod, totalCoins, transferId } = body
  if (!buyerName || !address || !Array.isArray(items) || items.length === 0) {
    return NextResponse.json(
      { error: 'Faltan datos del pedido (comprador, dirección o artículos)' },
      { status: 400 }
    )
  }
  const method = ['coins', 'transfer'].includes(paymentMethod) ? paymentMethod : 'cash'
  const transferRef = String(transferId || '').trim()
  if (method === 'transfer' && !transferRef) {
    return NextResponse.json(
      { error: 'Falta el ID de la transferencia: escribe el número que te dio el banco' },
      { status: 400 }
    )
  }
  const buyer = String(buyerName).trim()
  const x = Number(mapX) || 50
  const y = Number(mapY) || 50
  const etaMinutes = calcEta(x, y)
  const code = 'VIO-' + Math.floor(10000 + Math.random() * 90000)

  // Si el pago es con monedas: comprobar y descontar el saldo
  let coinsToPay = 0
  let newBalance = 0
  if (method === 'coins') {
    coinsToPay = Math.round(Number(totalCoins) || 0)
    if (coinsToPay <= 0) {
      return NextResponse.json({ error: 'El total en monedas no es válido' }, { status: 400 })
    }
    let wallet = await db.wallet.findUnique({ where: { ownerName: buyer } })
    if (!wallet) wallet = await db.wallet.create({ data: { ownerName: buyer } })
    if (wallet.coins < coinsToPay) {
      return NextResponse.json(
        {
          error: `Saldo insuficiente: tienes ${wallet.coins} monedas y el pedido cuesta ${coinsToPay}. Recarga saldo en Mi Billetera.`,
        },
        { status: 400 }
      )
    }
    newBalance = wallet.coins - coinsToPay
    await db.wallet.update({ where: { ownerName: buyer }, data: { coins: newBalance } })
  }

  const order = await db.order.create({
    data: {
      code,
      buyerName: buyer,
      address: String(address).trim(),
      notes: notes ? String(notes).trim() : null,
      mapX: x,
      mapY: y,
      items: JSON.stringify(items),
      total: Number(total),
      totalCoins: method === 'coins' ? coinsToPay : null,
      paymentMethod: method,
      transferId: method === 'transfer' ? transferRef : null,
      etaMinutes,
    },
  })

  // Notificación al comprador con el resumen de su compra
  const payText =
    method === 'coins'
      ? `Pagaste ${coinsToPay} monedas (saldo restante: ${newBalance}).`
      : method === 'transfer'
        ? `Pagas ${formatPrice(Number(total))} por transferencia bancaria. Registraste el ID ${transferRef}: el vendedor confirmará el pago.`
        : `Pagas ${formatPrice(Number(total))} en efectivo al recibir el pedido.`
  await db.notification.create({
    data: {
      toName: order.buyerName,
      title: `Pedido ${code} recibido`,
      body: `Gracias por tu compra. ${items.length} artículo(s). ${payText} Entrega estimada en ${etaMinutes} minutos a: ${address}.`,
      kind: 'pedido',
      orderId: order.id,
    },
  })

  // Si pagó por transferencia: aviso automático al vendedor (administrador)
  // con los datos de la transferencia para que la verifique.
  if (method === 'transfer') {
    await db.notification.create({
      data: {
        toName: 'Administrador',
        title: `Pago por transferencia en el pedido ${code}`,
        body: `${buyer} registró una transferencia de ${formatPrice(Number(total))} para el pedido ${code}. ID de la transferencia: ${transferRef}. Verifícala en tu banco y confirma el pago con el comprador.`,
        kind: 'pedido',
        orderId: order.id,
      },
    })
  }

  return NextResponse.json(order, { status: 201 })
}
