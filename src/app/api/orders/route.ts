// ============================================================
// API de pedidos (compras con entrega a domicilio)
// PARCHES DE SEGURIDAD:
// - Comprar exige sesión iniciada (como en Amazon: mirar es
//   libre, comprar con cuenta). El comprador es SIEMPRE la
//   cuenta de la sesión.
// - El total se RECALCULA en el servidor con los precios de la
//   base de datos (antes el navegador mandaba el precio y se
//   podía comprar un televisor por 1 moneda).
// - El stock y el cobro de monedas se descuentan de forma
//   atómica (dos compras a la vez nunca venden de más ni
//   dejan el saldo en negativo).
// - Límites de tamaño en dirección, notas y artículos.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { formatPrice } from '@/lib/products'
import { getSessionUser } from '@/lib/session'
import { rateLimit, RATE, clip, logSecurityEvent } from '@/lib/security'

// Tiempo estimado según la distancia en el mini mapa (0-100, centro = 50,50)
function calcEta(mapX: number, mapY: number) {
  const dist = Math.sqrt((mapX - 50) ** 2 + (mapY - 50) ** 2)
  return Math.round(dist * 1.4) + 15 // entre 15 y ~95 minutos
}

// GET /api/orders?buyer=Nombre | ?status=placed | ?worker=Nombre
// ?mode=turbo -> pedidos turbo públicos (tablero para mensajeros)
// ?mode=normal&stores=id1,id2 -> pedidos por tienda (solo repartidores contratados)
// PARCHES: consultar los pedidos de UNA persona (buyer/worker)
// exige sesión y que sea uno mismo o el administrador. El
// tablero turbo sigue siendo público.
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const buyer = searchParams.get('buyer')
  const worker = searchParams.get('worker')
  const status = searchParams.get('status')
  const mode = searchParams.get('mode')
  const stores = searchParams.get('stores')

  // Consultar pedidos de una persona concreta: solo uno mismo o el admin
  if (buyer || worker) {
    const sess = await getSessionUser(req)
    if (!sess) {
      return NextResponse.json({ error: 'Inicia sesión para ver tus pedidos' }, { status: 401 })
    }
    const isAdmin = sess.user.role === 'administrador'
    if (!isAdmin) {
      if (buyer && buyer !== sess.user.name) {
        return NextResponse.json({ error: 'Solo puedes ver tus propios pedidos' }, { status: 403 })
      }
      if (worker && worker !== sess.user.name) {
        return NextResponse.json({ error: 'Solo puedes ver tus propias entregas' }, { status: 403 })
      }
    }
  }

  // Pedidos por tienda (modo normal): solo repartidores aceptados
  // por esas tiendas o el administrador.
  if (mode === 'normal' && stores) {
    const sess = await getSessionUser(req)
    if (!sess) {
      return NextResponse.json({ error: 'Inicia sesión para ver las entregas' }, { status: 401 })
    }
    if (sess.user.role !== 'administrador') {
      const wanted = stores.split(',').filter(Boolean)
      const accepted = await db.application.findMany({
        where: { applicantName: sess.user.name, status: 'accepted' },
        include: { job: { select: { storeId: true } } },
      })
      const allowed = new Set(accepted.map((a) => a.job.storeId))
      const ok = wanted.every((sid) => allowed.has(sid))
      if (!ok) {
        return NextResponse.json(
          { error: 'Solo los repartidores aceptados por la tienda pueden ver estos pedidos' },
          { status: 403 }
        )
      }
    }
  }

  // La lista COMPLETA de pedidos (sin filtros) es solo del administrador.
  // El tablero turbo (?mode=turbo) sigue siendo público por diseño.
  if (!buyer && !worker && mode !== 'turbo') {
    const sess = await getSessionUser(req)
    if (!sess || sess.user.role !== 'administrador') {
      return NextResponse.json(
        { error: 'Solo el administrador puede ver la lista completa de pedidos' },
        { status: 403 }
      )
    }
  }

  const orders = await db.order.findMany({
    where: {
      ...(buyer ? { buyerName: buyer } : {}),
      ...(worker ? { workerName: worker } : {}),
      ...(status ? { status } : {}),
      ...(mode ? { deliveryMode: mode } : {}),
      ...(stores
        ? {
            OR: stores
              .split(',')
              .filter(Boolean)
              .map((sid) => ({ storeIds: { contains: sid } })),
          }
        : {}),
    },
    orderBy: { createdAt: 'desc' },
  })
  return NextResponse.json(orders)
}

// POST /api/orders — crear pedido desde el carrito
// paymentMethod: "cash" (efectivo al recibir) | "coins" (monedas internas)
//                | "transfer" (transferencia bancaria en CUP con su ID)
export async function POST(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Inicia sesión para completar la compra' },
      { status: 401 }
    )
  }
  if (!rateLimit(`order:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const { address, notes, mapX, mapY, items, paymentMethod, transferId } = body
  if (!address || !Array.isArray(items) || items.length === 0) {
    return NextResponse.json(
      { error: 'Faltan datos del pedido (dirección o artículos)' },
      { status: 400 }
    )
  }
  if (items.length > 50) {
    return NextResponse.json({ error: 'Demasiados artículos en un solo pedido' }, { status: 400 })
  }
  const addressText = clip(address, 200)
  const notesText = notes ? clip(notes, 300) : null
  const method = ['coins', 'transfer'].includes(paymentMethod) ? paymentMethod : 'cash'
  const transferRef = clip(transferId, 60)
  if (method === 'transfer' && !transferRef) {
    return NextResponse.json(
      { error: 'Falta el ID de la transferencia: escribe el número que te dio el banco' },
      { status: 400 }
    )
  }

  // ------- ALMACÉN: validar el inventario y RECALCULAR el total -------
  // El precio SIEMPRE sale de la base de datos, nunca del navegador.
  type CartItem = { productId: string; kind: 'web' | 'mini'; qty: number; name: string; price: number; priceCoins: number; store: string }
  const cart: CartItem[] = []
  const feeBuckets = new Map<string, number>()
  const settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  const webFee = settings?.courierFee ?? 200

  for (const it of items as Array<Record<string, unknown>>) {
    const pid = String(it?.productId || '')
    const kind = String(it?.kind || '')
    const q = Math.max(1, Math.min(99, Math.floor(Number(it?.qty) || 1)))
    if (!pid || (kind !== 'web' && kind !== 'mini')) continue
    if (kind === 'web') {
      const o = await db.offer.findUnique({ where: { id: pid } })
      if (!o) {
        return NextResponse.json({ error: 'Un artículo del carrito ya no existe. Actualiza la página.' }, { status: 400 })
      }
      if (o.stock < q) {
        return NextResponse.json(
          { error: `Solo quedan ${o.stock} unidad(es) de "${o.title}" en el almacén` },
          { status: 400 }
        )
      }
      cart.push({
        productId: o.id,
        kind: 'web',
        qty: q,
        name: o.title,
        price: o.price,
        priceCoins: o.priceCoins > 0 ? o.priceCoins : Math.round(o.price * (settings?.coinRate || 100)),
        store: 'Violetero',
      })
      feeBuckets.set('web', webFee)
    } else {
      const p = await db.miniProduct.findUnique({ where: { id: pid }, include: { store: true } })
      if (!p) {
        return NextResponse.json({ error: 'Un artículo del carrito ya no existe. Actualiza la página.' }, { status: 400 })
      }
      if (p.stock < q) {
        return NextResponse.json(
          { error: `Solo quedan ${p.stock} unidad(es) de "${p.name}" en la mini tienda` },
          { status: 400 }
        )
      }
      cart.push({
        productId: p.id,
        kind: 'mini',
        qty: q,
        name: p.name,
        price: p.price,
        priceCoins: p.priceCoins > 0 ? p.priceCoins : Math.round(p.price * (settings?.coinRate || 100)),
        store: p.store.name,
      })
      // La tarifa del mensajero la define el dueño de la mini tienda
      if (!feeBuckets.has(p.storeId)) feeBuckets.set(p.storeId, p.store.courierFee)
    }
  }
  if (cart.length === 0) {
    return NextResponse.json({ error: 'El carrito está vacío o los artículos ya no existen' }, { status: 400 })
  }

  // Totales recalculados por el servidor (CUP y monedas)
  const serverTotal = cart.reduce((acc, it) => acc + it.price * it.qty, 0)
  const serverCoins = cart.reduce((acc, it) => acc + it.priceCoins * it.qty, 0)
  const buyer = sess.user.name
  const x = Number(mapX) || 50
  const y = Number(mapY) || 50
  const etaMinutes = calcEta(x, y)
  const code = 'VIO-' + Math.floor(10000 + Math.random() * 90000)

  // Si el pago es con monedas: comprobar y descontar el saldo (atómico)
  let coinsToPay = 0
  let newBalance = 0
  if (method === 'coins') {
    coinsToPay = Math.max(0, Math.round(serverCoins))
    if (coinsToPay <= 0) {
      return NextResponse.json({ error: 'El total en monedas no es válido' }, { status: 400 })
    }
    const paid = await db.wallet.updateMany({
      where: { ownerName: buyer, coins: { gte: coinsToPay } },
      data: { coins: { decrement: coinsToPay } },
    })
    if (paid.count === 0) {
      const wallet = await db.wallet.findUnique({ where: { ownerName: buyer } })
      return NextResponse.json(
        {
          error: `Saldo insuficiente: tienes ${wallet?.coins ?? 0} monedas y el pedido cuesta ${coinsToPay}. Recarga saldo en Mi Billetera.`,
        },
        { status: 400 }
      )
    }
    const wallet = await db.wallet.findUnique({ where: { ownerName: buyer } })
    newBalance = wallet?.coins ?? 0
  }

  // Descontar del almacén de forma atómica (nadie compra sin stock)
  const soldOps: { table: 'web' | 'mini'; id: string; qty: number }[] = []
  for (const it of cart) {
    const result =
      it.kind === 'web'
        ? await db.offer.updateMany({
            where: { id: it.productId, stock: { gte: it.qty } },
            data: { stock: { decrement: it.qty }, sold: { increment: it.qty } },
          })
        : await db.miniProduct.updateMany({
            where: { id: it.productId, stock: { gte: it.qty } },
            data: { stock: { decrement: it.qty }, sold: { increment: it.qty } },
          })
    if (result.count === 0) {
      // Devolver las monedas si ya se descontaron y falla el stock
      if (method === 'coins' && coinsToPay > 0) {
        await db.wallet.update({
          where: { ownerName: buyer },
          data: { coins: { increment: coinsToPay } },
        })
      }
      // Revertir los artículos ya descontados en este pedido
      for (const done of soldOps) {
        if (done.table === 'web') {
          await db.offer.update({
            where: { id: done.id },
            data: { stock: { increment: done.qty }, sold: { decrement: done.qty } },
          })
        } else {
          await db.miniProduct.update({
            where: { id: done.id },
            data: { stock: { increment: done.qty }, sold: { decrement: done.qty } },
          })
        }
      }
      return NextResponse.json(
        { error: `Alguien compró primero y ya no hay stock de "${it.name}". Te devolvimos el saldo. Actualiza la página.` },
        { status: 409 }
      )
    }
    soldOps.push({ table: it.kind, id: it.productId, qty: it.qty })
  }

  const order = await db.order.create({
    data: {
      code,
      buyerName: buyer,
      address: addressText,
      notes: notesText,
      mapX: x,
      mapY: y,
      items: JSON.stringify(cart.map((it) => ({ name: it.name, price: it.price, qty: it.qty, store: it.store }))),
      total: serverTotal,
      totalCoins: method === 'coins' ? coinsToPay : null,
      paymentMethod: method,
      transferId: method === 'transfer' ? transferRef : null,
      deliveryMode: body.deliveryMode === 'turbo' ? 'turbo' : 'normal',
      courierFee: [...feeBuckets.values()].reduce((a, b) => a + b, 0),
      storeIds: [...feeBuckets.keys()].filter((k) => k !== 'web').join(','),
      etaMinutes,
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'order_created',
    detail: `Pedido ${code} por ${formatPrice(serverTotal)} (${method === 'coins' ? `${coinsToPay} monedas` : method === 'transfer' ? 'transferencia' : 'efectivo'})`,
  })

  // Notificación al comprador con el resumen de su compra
  const payText =
    method === 'coins'
      ? `Pagaste ${coinsToPay} monedas (saldo restante: ${newBalance}).`
      : method === 'transfer'
        ? `Pagas ${formatPrice(serverTotal)} por transferencia bancaria. Registraste el ID ${transferRef}: el vendedor confirmará el pago.`
        : `Pagas ${formatPrice(serverTotal)} en efectivo al recibir el pedido.`
  await db.notification.create({
    data: {
      toName: order.buyerName,
      title: `Pedido ${code} recibido`,
      body: `Gracias por tu compra. ${cart.length} artículo(s). ${payText} Entrega estimada en ${etaMinutes} minutos a: ${addressText}.`,
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
        body: `${buyer} registró una transferencia de ${formatPrice(serverTotal)} para el pedido ${code}. ID de la transferencia: ${transferRef}. Verifícala en tu banco y confirma el pago con el comprador.`,
        kind: 'pedido',
        orderId: order.id,
      },
    })
  }

  return NextResponse.json(order, { status: 201 })
}
