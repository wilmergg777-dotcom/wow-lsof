// ============================================================
// API de ajustes del sitio de Violetero
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { requireAdmin } from '@/lib/session'
import { logSecurityEvent } from '@/lib/security'

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
// PARCHES DE SEGURIDAD: SOLO el administrador (antes cualquiera
// podía cambiar la tasa de cambio y falsear todos los precios).
export async function PATCH(req: Request) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Solo el administrador puede cambiar los ajustes del sitio' },
      { status: 403 }
    )
  }
  const body = await req.json().catch(() => ({}))
  if (
    typeof body.miniStoresEnabled !== 'boolean' &&
    typeof body.coinRate !== 'number' &&
    typeof body.courierFee !== 'number'
  ) {
    return NextResponse.json(
      { error: 'Falta miniStoresEnabled, coinRate o courierFee' },
      { status: 400 }
    )
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
      ...(typeof body.courierFee === 'number' && body.courierFee >= 0
        ? { courierFee: Math.round(body.courierFee) }
        : {}),
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'settings_changed',
    detail: 'Ajustes del sitio actualizados (tasa de cambio, mini tiendas o tarifa)',
  })
  return NextResponse.json(updated)
}
