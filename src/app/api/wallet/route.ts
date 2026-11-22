// ============================================================
// API de la billetera de monedas internas del usuario
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

async function getWallet(name: string) {
  const ownerName = name.trim()
  let wallet = await db.wallet.findUnique({ where: { ownerName } })
  if (!wallet) {
    wallet = await db.wallet.create({ data: { ownerName } })
  }
  return wallet
}

// GET /api/wallet?name=Nombre — saldo de monedas del usuario
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const name = searchParams.get('name')
  if (!name || !name.trim() || name.trim().toLowerCase() === 'invitado') {
    return NextResponse.json({ ownerName: name || 'Invitado', coins: 0, guest: true })
  }
  const wallet = await getWallet(name)
  return NextResponse.json(wallet)
}
