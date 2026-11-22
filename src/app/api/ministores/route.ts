// ============================================================
// API de mini tiendas: listar y crear
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

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
  // Comprobar si el administrador permite las mini tiendas
  let settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  if (!settings) settings = await db.siteSettings.create({ data: { id: 'main' } })
  if (!settings.miniStoresEnabled) {
    return NextResponse.json(
      { error: 'El administrador ha desactivado las mini tiendas' },
      { status: 403 }
    )
  }

  const body = await req.json()
  const { name, ownerName, description, category, emoji, logo, color } = body
  if (!name || !ownerName || !description || !category) {
    return NextResponse.json(
      { error: 'Faltan datos: nombre, dueño, descripción y categoría son obligatorios' },
      { status: 400 }
    )
  }

  const store = await db.miniStore.create({
    data: {
      name: String(name).trim(),
      ownerName: String(ownerName).trim(),
      description: String(description).trim(),
      category: String(category),
      emoji: String(emoji || '🏪'),
      logo: typeof logo === 'string' && logo.startsWith('data:image') ? logo : null,
      color: typeof color === 'string' && /^#[0-9A-Fa-f]{6}$/.test(color) ? color : '#5B21B6',
    },
    include: { products: true },
  })

  // Notificar al administrador
  await db.notification.create({
    data: {
      toName: 'Administrador',
      title: 'Nueva mini tienda creada',
      body: `${ownerName} creó la mini tienda "${name}" (${category}).`,
      kind: 'tienda',
    },
  })

  return NextResponse.json(store, { status: 201 })
}
