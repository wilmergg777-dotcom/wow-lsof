// ============================================================
// DEDUCCIÓN DEL SALDO DE LA BILLETERA
// POST /api/wallet/deduct  { name, coins, reason }
// Se usa para cobros dentro de la web (ej: la suscripción de la
// mini tienda). Rechaza si el saldo no alcanza.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

export async function POST(req: Request) {
  const body = await req.json()
  const name = String(body.name || '').trim()
  const coins = Math.floor(Number(body.coins) || 0)

  if (!name || name.toLowerCase() === 'invitado') {
    return NextResponse.json(
      { error: 'Inicia sesión para usar tu saldo' },
      { status: 400 }
    )
  }
  if (coins <= 0) {
    return NextResponse.json({ error: 'Cantidad inválida' }, { status: 400 })
  }

  let wallet = await db.wallet.findUnique({ where: { ownerName: name } })
  if (!wallet) {
    wallet = await db.wallet.create({ data: { ownerName: name } })
  }
  if (wallet.coins < coins) {
    return NextResponse.json(
      {
        error: `Saldo insuficiente: tienes ${wallet.coins} monedas y necesitas ${coins}`,
      },
      { status: 400 }
    )
  }

  const updated = await db.wallet.update({
    where: { ownerName: name },
    data: { coins: { decrement: coins } },
  })
  return NextResponse.json(updated)
}
