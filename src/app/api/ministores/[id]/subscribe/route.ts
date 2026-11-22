// ============================================================
// SUSCRIPCIÓN DE LA MINI TIENDA
// POST /api/ministores/[id]/subscribe  { ownerName }
// 5 días de prueba gratis desde la creación; después la tienda
// se mantiene con una suscripción de 200 CUP al mes que se
// descuenta del saldo en monedas de la billetera del dueño
// (200 CUP x tasa de cambio del sitio).
// PARCHES DE SEGURIDAD:
// - Exige sesión y que la cuenta sea el dueño real de la tienda.
// - El cobro es atómico (nunca deja el saldo en negativo).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser, isSelfOrAdmin } from '@/lib/session'
import { logSecurityEvent } from '@/lib/security'

// Precio de la suscripción en CUP y duración en días
export const SUBSCRIPTION_CUP = 200
export const SUBSCRIPTION_DAYS = 30

export async function POST(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para pagar la suscripción' }, { status: 401 })
  }

  const { id } = await params
  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'La tienda no existe' }, { status: 404 })
  if (!isSelfOrAdmin(sess, store.ownerName)) {
    return NextResponse.json(
      { error: 'Solo el dueño puede pagar la suscripción de su tienda' },
      { status: 403 }
    )
  }
  const ownerName = store.ownerName

  const settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  const rate = settings?.coinRate || 100
  const cost = SUBSCRIPTION_CUP * rate

  // Descuenta el saldo de la billetera del dueño (atómico)
  const paid = await db.wallet.updateMany({
    where: { ownerName, coins: { gte: cost } },
    data: { coins: { decrement: cost } },
  })
  if (paid.count === 0) {
    const wallet = await db.wallet.findUnique({ where: { ownerName } })
    return NextResponse.json(
      {
        error: `Saldo insuficiente: la suscripción cuesta ${cost} monedas (${SUBSCRIPTION_CUP} CUP) y tienes ${wallet?.coins ?? 0}. Recarga tu billetera.`,
      },
      { status: 400 }
    )
  }
  const updatedWallet = await db.wallet.findUnique({ where: { ownerName } })

  // Suma 30 días desde hoy (o desde el final de la suscripción
  // vigente, si el dueño paga antes de que venza)
  const base =
    store.subscribedUntil && store.subscribedUntil > new Date()
      ? store.subscribedUntil
      : new Date()
  const until = new Date(base)
  until.setDate(until.getDate() + SUBSCRIPTION_DAYS)

  const updated = await db.miniStore.update({
    where: { id },
    data: { subscribedUntil: until },
    include: { products: true },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'store_subscribed',
    detail: `Pagó la suscripción de "${store.name}" (${SUBSCRIPTION_CUP} CUP)`,
  })
  return NextResponse.json({ store: updated, paidCup: SUBSCRIPTION_CUP, paidCoins: cost, balance: updatedWallet?.coins ?? 0 })
}
