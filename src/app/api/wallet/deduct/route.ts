// ============================================================
// DEDUCCIÓN DEL SALDO DE LA BILLETERA
// POST /api/wallet/deduct  { coins, reason }
// PARCHES DE SEGURIDAD:
// - Exige sesión iniciada: cada usuario solo puede gastar SU
//   propio saldo (antes el nombre venía del navegador y se
//   podía suplantar para vaciar la cuenta de otro).
// - Solo el administrador puede deducir el saldo de otra cuenta.
// - La deducción es atómica: si el saldo cambia a la vez que se
//   paga algo, nunca queda en negativo.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser } from '@/lib/session'
import { rateLimit, RATE, logSecurityEvent } from '@/lib/security'

export async function POST(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para usar tu saldo' }, { status: 401 })
  }
  if (!rateLimit(`deduct:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const coins = Math.floor(Number(body.coins) || 0)

  if (coins <= 0) {
    return NextResponse.json({ error: 'Cantidad inválida' }, { status: 400 })
  }

  let wallet = await db.wallet.findUnique({ where: { ownerName: sess.user.name } })
  if (!wallet) {
    wallet = await db.wallet.create({ data: { ownerName: sess.user.name } })
  }
  if (wallet.coins < coins) {
    return NextResponse.json(
      {
        error: `Saldo insuficiente: tienes ${wallet.coins} monedas y necesitas ${coins}`,
      },
      { status: 400 }
    )
  }

  // Actualización atómica: solo descuenta si aún hay saldo suficiente
  const result = await db.wallet.updateMany({
    where: { ownerName: sess.user.name, coins: { gte: coins } },
    data: { coins: { decrement: coins } },
  })
  if (result.count === 0) {
    return NextResponse.json({ error: 'Saldo insuficiente' }, { status: 400 })
  }

  const updated = await db.wallet.findUnique({ where: { ownerName: sess.user.name } })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'wallet_deduct',
    detail: `Se dedujeron ${coins} monedas${body.reason ? ` (${String(body.reason).slice(0, 80)})` : ''}`,
  })
  return NextResponse.json(updated)
}
