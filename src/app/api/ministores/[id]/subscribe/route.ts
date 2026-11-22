// ============================================================
// SUSCRIPCIÓN DE LA MINI TIENDA
// POST /api/ministores/[id]/subscribe  { ownerName }
// 5 días de prueba gratis desde la creación; después la tienda
// se mantiene con una suscripción de 200 CUP al mes que se
// descuenta del saldo en monedas de la billetera del dueño
// (200 CUP x tasa de cambio del sitio).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// Precio de la suscripción en CUP y duración en días
export const SUBSCRIPTION_CUP = 200
export const SUBSCRIPTION_DAYS = 30

export async function POST(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const body = await req.json().catch(() => ({}) as Record<string, unknown>)
  const ownerName = String(body.ownerName || '').trim()

  const store = await db.miniStore.findUnique({ where: { id } })
  if (!store) return NextResponse.json({ error: 'La tienda no existe' }, { status: 404 })
  if (store.ownerName !== ownerName) {
    return NextResponse.json(
      { error: 'Solo el dueño puede pagar la suscripción de su tienda' },
      { status: 403 }
    )
  }

  const settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  const rate = settings?.coinRate || 100
  const cost = SUBSCRIPTION_CUP * rate

  // Descuenta el saldo de la billetera del dueño
  let wallet = await db.wallet.findUnique({ where: { ownerName } })
  if (!wallet) wallet = await db.wallet.create({ data: { ownerName } })
  if (wallet.coins < cost) {
    return NextResponse.json(
      {
        error: `Saldo insuficiente: la suscripción cuesta ${cost} monedas (${SUBSCRIPTION_CUP} CUP) y tienes ${wallet.coins}. Recarga tu billetera.`,
      },
      { status: 400 }
    )
  }
  const updatedWallet = await db.wallet.update({
    where: { ownerName },
    data: { coins: { decrement: cost } },
  })

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
  return NextResponse.json({ store: updated, paidCup: SUBSCRIPTION_CUP, paidCoins: cost, balance: updatedWallet.coins })
}
