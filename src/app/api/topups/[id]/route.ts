// ============================================================
// API de una solicitud de recarga: el administrador la revisa
// y aprueba (acredita las monedas) o la rechaza.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

async function getWallet(name: string) {
  let wallet = await db.wallet.findUnique({ where: { ownerName: name } })
  if (!wallet) wallet = await db.wallet.create({ data: { ownerName: name } })
  return wallet
}

// PATCH /api/topups/[id] — aprobar o rechazar la recarga
export async function PATCH(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const body = await req.json()
  const { status, adminNote } = body

  if (status !== 'approved' && status !== 'rejected') {
    return NextResponse.json({ error: 'El estado debe ser approved o rejected' }, { status: 400 })
  }

  const request = await db.topUpRequest.findUnique({ where: { id } })
  if (!request) {
    return NextResponse.json({ error: 'Solicitud de recarga no encontrada' }, { status: 404 })
  }
  if (request.status !== 'pending') {
    return NextResponse.json({ error: 'Esta solicitud ya fue revisada' }, { status: 400 })
  }

  const updated = await db.topUpRequest.update({
    where: { id },
    data: {
      status,
      adminNote: adminNote ? String(adminNote).trim() : null,
      reviewedAt: new Date(),
    },
  })

  if (status === 'approved') {
    // Acreditar las monedas en la billetera del usuario
    const wallet = await getWallet(request.userName)
    await db.wallet.update({
      where: { ownerName: request.userName },
      data: { coins: wallet.coins + request.coins },
    })
    await db.notification.create({
      data: {
        toName: request.userName,
        title: '¡Recarga aprobada!',
        body: `El administrador verificó tu transferencia (ID: ${request.transferId}) y acreditó ${request.coins} monedas en tu billetera. Saldo anterior: ${wallet.coins} · Saldo nuevo: ${wallet.coins + request.coins}.`,
        kind: 'recarga',
      },
    })
  } else {
    await db.notification.create({
      data: {
        toName: request.userName,
        title: 'Recarga rechazada',
        body: `El administrador no encontró la transferencia con ID ${request.transferId} por $${request.amountCash.toFixed(2)}.${adminNote ? ` Nota: ${adminNote}` : ' Revisa el ID e inténtalo de nuevo.'}`,
        kind: 'recarga',
      },
    })
  }

  return NextResponse.json(updated)
}
