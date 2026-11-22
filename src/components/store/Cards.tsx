'use client'
// ============================================================
// SECCIONES DEL INICIO (estilo Violetero/Amazon)
// Todo se construye con las ofertas publicadas de verdad:
// - Si no hay ofertas, el inicio muestra una bienvenida limpia
//   para que el administrador o las mini tiendas publiquen.
// - Cuando hay ofertas: tarjetas de categorías, filas por
//   departamento y ofertas con descuento.
// ============================================================
import { useEffect, useRef, useState } from 'react'
import { ChevronRight, ChevronLeft, Coins, Package, Plus, Store } from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import { itemChange, itemCoins, itemDiscount, useCatalog, type CatalogItem } from '@/lib/catalog'
import { api, type Settings } from '@/lib/api'
import { formatCoins, formatPrice } from '@/lib/products'
import { HeroCarousel } from './HeroCarousel'
import { HomeMiniStores } from './MiniStores'

// ---------- Foto de un artículo (o recuadro neutro) ----------
function ItemPhoto({
  src,
  alt,
  className = '',
}: {
  src: string | null
  alt: string
  className?: string
}) {
  if (src) {
    return <img src={src} alt={alt} loading="lazy" className={`object-cover ${className}`} />
  }
  return (
    <div
      className={`w-full h-full flex items-center justify-center bg-gradient-to-br from-[#f7fafa] to-[#eceff1] ${className}`}
      aria-label={alt}
    >
      <Package className="w-10 h-10 text-[#c8cdcd]" strokeWidth={1.3} />
    </div>
  )
}

// ---------- Tarjeta de oferta ----------
export function ProductCard({ item, rate = 0 }: { item: CatalogItem; rate?: number }) {
  const openProduct = useStore((s) => s.openProduct)
  const addToCart = useStore((s) => s.addToCart)
  const pct = itemDiscount(item)
  const coins = rate > 0 ? itemCoins(item, rate) : item.priceCoins

  return (
    <div className="group relative bg-white rounded-md p-3 border border-transparent hover:border-[#c8cdcd] hover:shadow-lg transition-all flex flex-col">
      <button
        onClick={() => openProduct(item.id)}
        className="text-left cursor-pointer flex flex-col flex-1"
        aria-label={`Ver ${item.name}`}
      >
        <div className="h-44 w-full flex items-center justify-center overflow-hidden rounded bg-white mb-2">
          <ItemPhoto
            src={item.photo}
            alt={item.name}
            className={`max-h-44 w-full rounded transition-transform ${
              item.stock <= 0 ? 'opacity-60 grayscale' : 'group-hover:scale-[1.04]'
            }`}
          />
        </div>
        {item.stock <= 0 ? (
          <span className="self-start bg-[#565959] text-white text-[11px] font-bold px-1.5 py-0.5 rounded-sm mb-1">
            Agotado
          </span>
        ) : item.stock <= 5 ? (
          <span className="self-start bg-[#FEF3C7] text-[#B45309] text-[11px] font-bold px-1.5 py-0.5 rounded-sm mb-1">
            ¡Últimas {item.stock} unidades!
          </span>
        ) : null}
        {pct > 0 && (
          <span className="self-start bg-[#CC0C39] text-white text-[11px] font-bold px-1.5 py-0.5 rounded-sm mb-1">
            -{pct}% Oferta
          </span>
        )}
        {/* Cambio de precio frente al anterior: bajó (verde) o subió (rojo) */}
        {(() => {
          const ch = itemChange(item)
          if (!ch || pct > 0) return null
          return ch.dir === 'down' ? (
            <span className="self-start bg-[#007600]/10 text-[#007600] text-[11px] font-bold px-1.5 py-0.5 rounded-sm mb-1">
              Bajó {ch.pct}%
            </span>
          ) : (
            <span className="self-start bg-[#CC0C39]/10 text-[#CC0C39] text-[11px] font-bold px-1.5 py-0.5 rounded-sm mb-1">
              Subió {ch.pct}%
            </span>
          )
        })()}
        <p className="text-[14px] text-[#0F1111] leading-snug line-clamp-2">{item.name}</p>
        <p
          className={`text-[12px] font-bold mt-1 ${
            item.kind === 'mini' ? 'text-[#5B21B6]' : 'text-[#007600]'
          }`}
        >
          {item.kind === 'mini' ? `Mini tienda: ${item.store}` : `Vendido por ${STORE_NAME}`}
        </p>
        <div className="mt-1 flex items-baseline gap-2 flex-wrap">
          {item.oldPrice && (
            <span className="text-[12px] text-[#565959] line-through">
              {formatPrice(item.oldPrice)}
            </span>
          )}
          <span className="text-[18px] font-medium text-[#0F1111]">
            {formatPrice(item.price)}
          </span>
        </div>
        {coins > 0 && (
          <span className="text-[12px] text-[#5B21B6] font-bold flex items-center gap-1 mt-0.5">
            <Coins className="w-3.5 h-3.5" /> {formatCoins(coins)} monedas
          </span>
        )}
        <span className="text-[12px] text-[#565959] mt-0.5">
          <span className="text-[#0F1111] font-bold">Entrega a domicilio</span> con repartidor de{' '}
          {STORE_NAME}
        </span>
      </button>
      <button
        onClick={() => {
          if (item.stock <= 0) {
            toast.error(`"${item.name}" está agotado: no hay unidades en el almacén`)
            return
          }
          addToCart(item.id, 1, {
            name: item.name,
            price: item.price,
            priceCoins: item.priceCoins > 0 ? item.priceCoins : undefined,
            photo: item.photo ?? undefined,
            storeName: item.store,
            productId: item.id.replace(/^(web|mini)-/, ''),
            kind: item.kind,
            stock: item.stock,
          })
          toast.success('Agregado al carrito', { description: item.name })
        }}
        className="absolute right-2 bottom-2 w-9 h-9 rounded-full bg-white border border-[#ddd] shadow flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer hover:bg-[#FFD814]"
        aria-label={`Agregar ${item.name} al carrito`}
      >
        <Plus className="w-4 h-4 text-[#0F1111]" />
      </button>
    </div>
  )
}

// ---------- Tarjeta de categoría construida con ofertas reales ----------
type CategoryCardData = {
  title: string
  target: string
  tiles: { label: string; img: string | null; target: string }[]
}

function CategoryCard({ data }: { data: CategoryCardData }) {
  const openCategory = useStore((s) => s.openCategory)
  return (
    <div className="bg-white rounded-md p-5 border border-[#e3e6e6] flex flex-col">
      <button
        onClick={() => openCategory(data.target)}
        className="flex items-start gap-1 text-left cursor-pointer group/t"
        aria-label={`Ver ${data.title}`}
      >
        <h3 className="text-[17px] font-bold text-[#0F1111] leading-snug group-hover/t:underline">
          {data.title}
        </h3>
        <ChevronRight className="w-5 h-5 text-[#0F1111] mt-0.5 shrink-0" />
      </button>
      <div className="grid grid-cols-2 gap-3 mt-3 flex-1">
        {data.tiles.map((t, i) => (
          <button
            key={`${t.label}-${i}`}
            onClick={() => openCategory(t.target)}
            className="text-left cursor-pointer group/tile"
            aria-label={`Ver ${t.label}`}
          >
            <div className="aspect-[1/1.05] rounded overflow-hidden bg-[#f5f5f5]">
              <ItemPhoto
                src={t.img}
                alt={t.label}
                className="w-full h-full transition-transform group-hover/tile:scale-[1.04]"
              />
            </div>
            <p className="text-[12px] text-[#0F1111] mt-1.5 group-hover/tile:underline line-clamp-1">
              {t.label}
            </p>
          </button>
        ))}
      </div>
    </div>
  )
}

// Categorías con ofertas publicadas (máximo 8 tarjetas)
export function CategorySections({ items }: { items: CatalogItem[] }) {
  const groups = new Map<string, CatalogItem[]>()
  for (const it of items) {
    const list = groups.get(it.category) || []
    list.push(it)
    groups.set(it.category, list)
  }
  const cards: CategoryCardData[] = [...groups.entries()]
    .sort((a, b) => b[1].length - a[1].length)
    .slice(0, 8)
    .map(([cat, list]) => ({
      title: `Explora ${cat}`,
      target: cat,
      tiles: list.slice(0, 2).map((it) => ({
        label: it.name,
        img: it.photo,
        target: cat,
      })),
    }))

  if (cards.length === 0) return null

  return (
    <section className="px-4 space-y-5" aria-label="Departamentos con ofertas">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {cards.map((c) => (
          <CategoryCard key={c.title} data={c} />
        ))}
      </div>
    </section>
  )
}

// ---------- Fila horizontal de ofertas ----------
export function ProductRow({
  title,
  items,
  rate = 0,
}: {
  title: string
  items: CatalogItem[]
  rate?: number
}) {
  const trackRef = useRef<HTMLDivElement>(null)
  if (items.length === 0) return null

  const scroll = (dir: 1 | -1) =>
    trackRef.current?.scrollBy({ left: dir * 500, behavior: 'smooth' })

  return (
    <section className="relative bg-white py-4" aria-label={title}>
      <h2 className="text-[20px] font-bold text-[#0F1111] px-5 mb-2">{title}</h2>
      <div className="relative">
        <div
          ref={trackRef}
          className="flex gap-3 overflow-x-auto px-5 snap-x pb-2"
          style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
        >
          {items.map((it) => (
            <div key={it.id} className="shrink-0 w-[190px] snap-start">
              <ProductCard item={it} rate={rate} />
            </div>
          ))}
        </div>
        <button
          onClick={() => scroll(-1)}
          className="absolute left-1 top-1/2 -translate-y-1/2 bg-white rounded-full w-10 h-10 flex items-center justify-center shadow-lg border border-[#ddd] cursor-pointer z-10"
          aria-label="Desplazar a la izquierda"
        >
          <ChevronLeft className="w-5 h-5" />
        </button>
        <button
          onClick={() => scroll(1)}
          className="absolute right-1 top-1/2 -translate-y-1/2 bg-white rounded-full w-10 h-10 flex items-center justify-center shadow-lg border border-[#ddd] cursor-pointer z-10"
          aria-label="Desplazar a la derecha"
        >
          <ChevronRight className="w-5 h-5" />
        </button>
      </div>
    </section>
  )
}

// ---------- Bienvenida cuando aún no hay ofertas ----------
function EmptyHome() {
  const openView = useStore((s) => s.openView)
  return (
    <section className="px-4 pb-2" aria-label="Bienvenida a Violetero">
      <div className="max-w-[1000px] mx-auto bg-white rounded-lg border border-[#e3e6e6] p-10 text-center">
        <Store className="w-16 h-16 text-[#5B21B6]/30 mx-auto" strokeWidth={1.2} />
        <h2 className="text-[24px] font-bold text-[#0F1111] mt-4">
          {STORE_NAME} está listo para sus primeras ofertas
        </h2>
        <p className="text-[14px] text-[#565959] mt-2 max-w-xl mx-auto">
          El inicio está vacío a propósito: aquí aparecerán las ofertas que publiques, cada una con
          su foto, su nombre y su precio en las dos monedas (dinero y monedas de la tienda). Si no
          tienes foto, puedes elegir una de las fotos guardadas en la tienda.
        </p>
        <div className="flex flex-col sm:flex-row gap-3 justify-center mt-6">
          <button
            onClick={() => openView('admin')}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-6 py-2.5 cursor-pointer"
          >
            Soy el administrador: publicar una oferta
          </button>
          <button
            onClick={() => openView('manage-store')}
            className="border-2 border-[#5B21B6] text-[#5B21B6] hover:bg-[#f6f1fd] text-[14px] font-bold rounded-full px-6 py-2.5 cursor-pointer"
          >
            Quiero vender: abrir mi mini tienda
          </button>
        </div>
        <p className="text-[13px] text-[#565959] mt-4">
          También puedes explorar las mini tiendas y el trabajo de domicilio en el menú de arriba.
        </p>
      </div>
    </section>
  )
}

// Esqueletos mientras carga el catálogo
function HomeSkeleton() {
  return (
    <div className="px-4 space-y-4" aria-label="Cargando ofertas">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {Array.from({ length: 4 }, (_, i) => (
          <div key={i} className="bg-white rounded-md border border-[#e3e6e6] p-5 animate-pulse">
            <div className="h-5 bg-[#e9ecec] rounded w-3/4 mb-4" />
            <div className="grid grid-cols-2 gap-3">
              <div className="aspect-[1/1.05] bg-[#e9ecec] rounded" />
              <div className="aspect-[1/1.05] bg-[#e9ecec] rounded" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

// ---------- INICIO COMPLETO (según lo que se haya publicado) ----------
export function HomeCatalog() {
  const { items } = useCatalog()
  const [rate, setRate] = useState(0)

  useEffect(() => {
    api<Settings>('/api/settings')
      .then((st) => setRate(st.coinRate || 0))
      .catch(() => {})
  }, [])

  const deals = items?.filter((it) => itemDiscount(it) > 0) ?? []
  const latest = items?.slice(0, 10) ?? []

  // Categorías con más ofertas para las filas de abajo
  const topCategories = (() => {
    if (!items) return []
    const counts = new Map<string, number>()
    for (const it of items) counts.set(it.category, (counts.get(it.category) || 0) + 1)
    return [...counts.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([cat]) => cat)
  })()

  return (
    <>
      {items && <HeroCarousel items={items} />}
      <div className="mt-3">
        <HomeMiniStores />
        {items === null ? (
          <HomeSkeleton />
        ) : items.length === 0 ? (
          <EmptyHome />
        ) : (
          <>
            <CategorySections items={items} />
            <div className="h-1" />
            <ProductRow title="Recién publicadas" items={latest} rate={rate} />
            {deals.length > 0 && (
              <ProductRow title="Ofertas con descuento" items={deals} rate={rate} />
            )}
            {topCategories.map((cat) => (
              <ProductRow
                key={cat}
                title={`Todo en ${cat}`}
                items={items.filter((it) => it.category === cat)}
                rate={rate}
              />
            ))}
            <div className="h-6" />
          </>
        )}
      </div>
    </>
  )
}
