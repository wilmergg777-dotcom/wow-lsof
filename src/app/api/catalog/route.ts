// ============================================================
// CATÁLOGO UNIFICADO DE VIOLETERO
// Une las ofertas del dueño de la web y los productos de las
// mini tiendas en una sola lista. Si nadie ha publicado nada,
// devuelve una lista vacía: la web empieza sin ofertas.
// GET /api/catalog
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

export type CatalogItem = {
  id: string // "web-<id>" | "mini-<id>"
  kind: 'web' | 'mini'
  name: string
  description: string
  category: string
  price: number // dinero real ($)
  priceCoins: number // monedas internas (0 = calcular con la tasa)
  oldPrice: number | null
  photo: string | null
  stock: number
  store: string // "Violetero" o el nombre de la mini tienda
  storeId: string | null
}

export async function GET() {
  const [offers, settings] = await Promise.all([
    db.offer.findMany({ where: { active: true }, orderBy: { createdAt: 'desc' } }),
    db.siteSettings.findUnique({ where: { id: 'main' } }),
  ])

  const items: CatalogItem[] = offers.map((o) => ({
    id: `web-${o.id}`,
    kind: 'web',
    name: o.title,
    description: o.description,
    category: o.category,
    price: o.price,
    priceCoins: o.priceCoins,
    oldPrice: o.oldPrice ?? null,
    photo: o.photo,
    stock: o.stock,
    store: 'Violetero',
    storeId: null,
  }))

  // Los productos de mini tiendas solo se muestran si el
  // administrador tiene las mini tiendas activadas
  if (!settings || settings.miniStoresEnabled) {
    const stores = await db.miniStore.findMany({
      include: { products: true },
    })
    for (const s of stores) {
      for (const p of s.products) {
        items.push({
          id: `mini-${p.id}`,
          kind: 'mini',
          name: p.name,
          description: p.description,
          category: s.category,
          price: p.price,
          priceCoins: p.priceCoins,
          oldPrice: null,
          photo: p.photo,
          stock: p.stock,
          store: s.name,
          storeId: s.id,
        })
      }
    }
  }

  return NextResponse.json(items)
}
