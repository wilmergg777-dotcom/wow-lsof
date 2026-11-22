'use client'
// ============================================================
// CATÁLOGO UNIFICADO DE VIOLETERO (lado cliente)
// Reúne las ofertas del dueño de la web (administrador) y los
// productos de las mini tiendas. La web empieza VACÍA: solo
// se ve lo que alguien publique de verdad.
// ============================================================
import { useCallback, useEffect, useState } from 'react'
import { api } from './api'

// Artículo del catálogo (oferta web o producto de mini tienda)
export type CatalogItem = {
  id: string // "web-<id>" | "mini-<id>"
  kind: 'web' | 'mini'
  name: string
  description: string
  category: string
  price: number // dinero real (CUP)
  priceCoins: number // monedas internas (0 = se calcula con la tasa)
  oldPrice: number | null // precio anterior (para el descuento)
  photo: string | null
  stock: number
  store: string // "Violetero" o el nombre de la mini tienda
  storeId: string | null
}

// Descarga el catálogo y permite recargarlo tras publicar
export function useCatalog() {
  const [items, setItems] = useState<CatalogItem[] | null>(null) // null = cargando
  const load = useCallback(() => {
    api<CatalogItem[]>('/api/catalog')
      .then(setItems)
      .catch(() => setItems([]))
  }, [])
  useEffect(() => {
    load()
  }, [load])
  return { items, reload: load }
}

// Monedas efectivas de un artículo (0 = usar la tasa del sitio)
export const itemCoins = (it: CatalogItem, rate: number) =>
  it.priceCoins > 0 ? it.priceCoins : Math.round(it.price * rate)

// Porcentaje de descuento redondeado (ej: 40)
export const itemDiscount = (it: CatalogItem) =>
  it.oldPrice && it.oldPrice > it.price
    ? Math.round((1 - it.price / it.oldPrice) * 100)
    : 0

const normalize = (s: string) =>
  s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '')

// Búsqueda simple por nombre, categoría, tienda y descripción
export function searchCatalog(
  items: CatalogItem[],
  query: string,
  category?: string
): CatalogItem[] {
  const q = normalize(query.trim())
  return items.filter((it) => {
    const inCategory = !category || category === 'Todos' || it.category === category
    const matches =
      !q ||
      normalize(it.name).includes(q) ||
      normalize(it.category).includes(q) ||
      normalize(it.store).includes(q) ||
      normalize(it.description).includes(q)
    return inCategory && matches
  })
}

// Busca un artículo por id ("web-..." o "mini-...")
// Acepta items nulo (catálogo todavía cargando)
export const findItem = (items: CatalogItem[] | null, id: string | null) =>
  items && id ? items.find((it) => it.id === id) : undefined
