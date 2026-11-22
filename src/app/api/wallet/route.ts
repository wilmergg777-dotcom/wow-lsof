// ============================================================
// API de la billetera de monedas internas del usuario
// PARCHES DE SEGURIDAD:
// - El saldo solo se consulta con sesión iniciada.
// - Cada usuario solo puede ver SU billetera (el administrador
//   puede consultar cualquier cuenta).
// - El nombre ya NO se acepta de la petición (se podía suplantar).
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser } from '@/lib/session'

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
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'Inicia sesión para ver tu saldo' }, { status: 401 })
  }
  const { searchParams } = new URL(req.url)
  const name = searchParams.get('name')
  // El administrador puede consultar cualquier billetera; el resto solo la suya
  const target =
    sess.user.role === 'administrador' && name ? name : sess.user.name
  if (target.trim().toLowerCase() === 'invitado') {
    return NextResponse.json({ ownerName: 'Invitado', coins: 0, guest: true })
  }
  const wallet = await getWallet(target)
  return NextResponse.json(wallet)
}
