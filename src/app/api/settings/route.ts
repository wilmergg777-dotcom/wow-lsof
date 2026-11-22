// ============================================================
// API de mini tiendas de Violetero
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

async function getSettings() {
  let settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  if (!settings) settings = await db.siteSettings.create({ data: { id: 'main' } })
  return settings
}

// GET /api/settings — ajustes del sitio
export async function GET() {
  const settings = await getSettings()
  return NextResponse.json(settings)
}

// PATCH /api/settings — el administrador activa/desactiva mini tiendas
// y configura la tasa de cambio (monedas por 1 CUP real)
export async function PATCH(req: Request) {
  const body = await req.json()
  if (typeof body.miniStoresEnabled !== 'boolean' && typeof body.coinRate !== 'number') {
    return NextResponse.json({ error: 'Falta miniStoresEnabled o coinRate' }, { status: 400 })
  }
  const settings = await getSettings()
  const rate = Number(body.coinRate)
  if (typeof body.coinRate === 'number' && (!rate || rate < 1)) {
    return NextResponse.json({ error: 'La tasa de cambio debe ser 1 o más' }, { status: 400 })
  }
  const updated = await db.siteSettings.update({
    where: { id: settings.id },
    data: {
      ...(typeof body.miniStoresEnabled === 'boolean'
        ? { miniStoresEnabled: body.miniStoresEnabled }
        : {}),
      ...(typeof body.coinRate === 'number' ? { coinRate: Math.round(rate) } : {}),
    },
  })
  return NextResponse.json(updated)
}
