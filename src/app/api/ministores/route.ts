// ============================================================
// API de mini tiendas: listar y crear
// PARCHES DE SEGURIDAD:
// - Crear tienda exige sesión: la tienda queda a nombre de la
//   cuenta de la sesión (no del nombre que mande el navegador).
// - Límite de tamaño del logotipo y de los textos.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { getSessionUser } from '@/lib/session'
import { rateLimit, RATE, clip, validPhoto, bodyTooLarge, logSecurityEvent } from '@/lib/security'

// GET /api/ministores — lista todas las mini tiendas (con productos)
export async function GET() {
  const stores = await db.miniStore.findMany({
    orderBy: { createdAt: 'desc' },
    include: { products: true },
  })
  return NextResponse.json(stores)
}

// POST /api/ministores — crear una mini tienda
export async function POST(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Inicia sesión para crear tu mini tienda' },
      { status: 401 }
    )
  }
  if (!rateLimit(`store:${sess.user.id}`, RATE.write.max, RATE.write.windowMs)) {
    return NextResponse.json({ error: 'Demasiadas acciones seguidas. Espera unos minutos.' }, { status: 429 })
  }

  // Comprobar si el administrador permite las mini tiendas
  let settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  if (!settings) settings = await db.siteSettings.create({ data: { id: 'main' } })
  if (!settings.miniStoresEnabled) {
    return NextResponse.json(
      { error: 'El administrador ha desactivado las mini tiendas' },
      { status: 403 }
    )
  }

  if (bodyTooLarge(req)) {
    return NextResponse.json({ error: 'El logotipo es demasiado grande' }, { status: 413 })
  }
  const body = await req.json().catch(() => ({}))
  const { name, description, category } = body
  if (!name || !description || !category) {
    return NextResponse.json(
      { error: 'Faltan datos: nombre, descripción y categoría son obligatorios' },
      { status: 400 }
    )
  }

  const store = await db.miniStore.create({
    data: {
      name: clip(name, 60),
      ownerName: sess.user.name,
      description: clip(description, 300),
      category: clip(category, 40),
      emoji: clip(body.emoji || '🏪', 8),
      logo: validPhoto(body.logo),
      color: typeof body.color === 'string' && /^#[0-9A-Fa-f]{6}$/.test(body.color) ? body.color : '#5B21B6',
      // 5 días de prueba gratis desde hoy
      trialEndsAt: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
      // Tarifa del mensajero por entrega (CUP), la define el dueño
      courierFee: Number(body.courierFee) > 0 ? Math.min(10_000, Math.round(Number(body.courierFee))) : 200,
    },
    include: { products: true },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'store_created',
    detail: `Creó la mini tienda "${store.name}"`,
  })

  // Notificar al administrador
  await db.notification.create({
    data: {
      toName: 'Administrador',
      title: 'Nueva mini tienda creada',
      body: `${sess.user.name} creó la mini tienda "${store.name}" (${store.category}).`,
      kind: 'tienda',
    },
  })

  return NextResponse.json(store, { status: 201 })
}
