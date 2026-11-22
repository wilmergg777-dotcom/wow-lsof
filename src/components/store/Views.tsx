'use client'
// ============================================================
// VISTAS: búsqueda, categoría, detalle de la oferta y carrito
// Todo se alimenta del catálogo real de la base de datos
// (ofertas del administrador + productos de mini tiendas).
// ============================================================
import { useMemo, useState, useEffect } from 'react'
import {
  ChevronLeft,
  Coins,
  Minus,
  Package,
  Plus,
  ShoppingBag,
  Trash2,
} from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import { cashToCoins, formatCoins, formatPrice, CATEGORIES } from '@/lib/products'
import { findItem, itemCoins, itemDiscount, searchCatalog, useCatalog, type CatalogItem } from '@/lib/catalog'
import { api, type Settings } from '@/lib/api'
import { ProductCard, ProductRow } from './Cards'

// ---------- Filtros laterales estilo Amazon ----------
function Filters({
  dept,
  setDept,
  onlyDeals,
  setOnlyDeals,
  priceRange,
  setPriceRange,
}: {
  dept: string
  setDept: (v: string) => void
  onlyDeals: boolean
  setOnlyDeals: (v: boolean) => void
  priceRange: string
  setPriceRange: (v: string) => void
}) {
  return (
    <aside className="hidden lg:block w-56 shrink-0 space-y-5 text-[14px]">
      <div>
        <h3 className="font-bold text-[16px] text-[#0F1111] mb-1.5">Departamento</h3>
        <ul className="space-y-1">
          {['Todos', ...CATEGORIES].map((c) => (
            <li key={c}>
              <button
                onClick={() => setDept(c)}
                className={`text-left cursor-pointer hover:underline ${
                  dept === c ? 'font-bold' : 'text-[#0F1111]/80'
                }`}
              >
                {c}
              </button>
            </li>
          ))}
        </ul>
      </div>
      <div>
        <h3 className="font-bold text-[16px] text-[#0F1111] mb-1.5">Ofertas</h3>
        <ul className="space-y-1">
          <li>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={onlyDeals}
                onChange={(e) => setOnlyDeals(e.target.checked)}
                className="accent-[#5B21B6] w-4 h-4"
              />
              Solo con descuento
            </label>
          </li>
        </ul>
      </div>
      <div>
        <h3 className="font-bold text-[16px] text-[#0F1111] mb-1.5">Precio</h3>
        <ul className="space-y-1">
          {[
            ['all', 'Todos los precios'],
            ['0-2000', 'Menos de 2.000 CUP'],
            ['2000-10000', '2.000 a 10.000 CUP'],
            ['10000-30000', '10.000 a 30.000 CUP'],
            ['30000+', '30.000 CUP y más'],
          ].map(([v, label]) => (
            <li key={v}>
              <button
                onClick={() => setPriceRange(v)}
                className={`text-left cursor-pointer hover:underline ${
                  priceRange === v ? 'font-bold' : 'text-[#0F1111]/80'
                }`}
              >
                {label}
              </button>
            </li>
          ))}
        </ul>
      </div>
    </aside>
  )
}

// Aplica los filtros de precio y descuento a una lista
function applyFilters(
  list: CatalogItem[],
  onlyDeals: boolean,
  priceRange: string
): CatalogItem[] {
  let out = list
  if (onlyDeals) out = out.filter((p) => itemDiscount(p) > 0)
  if (priceRange === '0-2000') out = out.filter((p) => p.price < 2000)
  if (priceRange === '2000-10000') out = out.filter((p) => p.price >= 2000 && p.price <= 10000)
  if (priceRange === '10000-30000') out = out.filter((p) => p.price > 10000 && p.price <= 30000)
  if (priceRange === '30000+') out = out.filter((p) => p.price > 30000)
  return out
}

function SortBar({ sort, setSort }: { sort: string; setSort: (v: string) => void }) {
  return (
    <label className="flex items-center gap-2 text-[13px]">
      Ordenar por:
      <select
        value={sort}
        onChange={(e) => setSort(e.target.value)}
        className="border border-[#ddd] rounded px-2 py-1.5 text-[13px] bg-[#f0f2f2] cursor-pointer"
      >
        <option value="featured">Destacados</option>
        <option value="price-asc">Precio: menor a mayor</option>
        <option value="price-desc">Precio: mayor a menor</option>
        <option value="newest">Más recientes</option>
      </select>
    </label>
  )
}

function sortItems(list: CatalogItem[], sort: string): CatalogItem[] {
  const copy = [...list]
  if (sort === 'price-asc') copy.sort((a, b) => a.price - b.price)
  if (sort === 'price-desc') copy.sort((a, b) => b.price - a.price)
  // "featured" y "newest": el catálogo ya viene con lo nuevo primero
  return copy
}

// ---------- Cuadrícula de resultados ----------
function ResultsGrid({ items, rate }: { items: CatalogItem[]; rate: number }) {
  const [sort, setSort] = useState('featured')
  const sorted = useMemo(() => sortItems(items, sort), [items, sort])

  return (
    <div className="flex-1">
      <div className="flex items-center justify-between mb-3 gap-3 flex-wrap">
        <p className="text-[14px] text-[#0F1111]">
          <span className="font-bold">{sorted.length}</span> {sorted.length === 1 ? 'resultado' : 'resultados'}
        </p>
        <SortBar sort={sort} setSort={setSort} />
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-5 gap-3">
        {sorted.map((p) => (
          <ProductCard key={p.id} item={p} rate={rate} />
        ))}
      </div>
      {sorted.length === 0 && (
        <div className="bg-white p-8 rounded text-center text-[#565959]">
          No encontramos ofertas para tu búsqueda. Prueba con otras palabras.
        </div>
      )}
    </div>
  )
}

// Aviso cuando la tienda todavía no tiene ninguna oferta publicada
function CatalogEmpty({ message }: { message: string }) {
  return (
    <div className="flex-1">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-12 text-center">
        <Package className="w-16 h-16 text-[#ddd] mx-auto" strokeWidth={1.2} />
        <p className="text-[16px] font-bold text-[#0F1111] mt-4">{message}</p>
        <p className="text-[14px] text-[#565959] mt-1">
          Cuando el administrador o las mini tiendas publiquen ofertas, aparecerán aquí.
        </p>
      </div>
    </div>
  )
}

// ---------- Vista de búsqueda ----------
export function SearchView() {
  const searchQuery = useStore((s) => s.searchQuery)
  const searchCategory = useStore((s) => s.searchCategory)
  const setSearchCategory = useStore((s) => s.setSearchCategory)
  const { items } = useCatalog()
  const [rate, setRate] = useState(0)
  useEffect(() => {
    api<Settings>('/api/settings')
      .then((st) => setRate(st.coinRate || 0))
      .catch(() => {})
  }, [])

  const [dept, setDept] = useState(searchCategory)
  const [onlyDeals, setOnlyDeals] = useState(false)
  const [priceRange, setPriceRange] = useState('all')

  // Si el usuario cambia el departamento en la pastilla del buscador, sincronizar aquí
  const [prevSearchCat, setPrevSearchCat] = useState(searchCategory)
  if (searchCategory !== prevSearchCat) {
    setPrevSearchCat(searchCategory)
    setDept(searchCategory)
  }

  const results = useMemo(
    () =>
      applyFilters(searchCatalog(items ?? [], searchQuery, dept), onlyDeals, priceRange),
    [items, searchQuery, dept, onlyDeals, priceRange]
  )

  if (items !== null && items.length === 0) {
    return (
      <div className="px-4 py-4 max-w-[1600px] mx-auto">
        <h1 className="text-[20px] text-[#0F1111] mb-3">
          {searchQuery ? (
            <>
              Resultados para <span className="font-bold text-[#C7511F]">&quot;{searchQuery}&quot;</span>
            </>
          ) : (
            'Todos los productos'
          )}
        </h1>
        <CatalogEmpty message={`${STORE_NAME} todavía no tiene ofertas publicadas`} />
      </div>
    )
  }

  return (
    <div className="px-4 py-4 max-w-[1600px] mx-auto flex gap-6">
      <Filters
        dept={dept}
        setDept={(c) => {
          setDept(c)
          setSearchCategory(c)
        }}
        onlyDeals={onlyDeals}
        setOnlyDeals={setOnlyDeals}
        priceRange={priceRange}
        setPriceRange={setPriceRange}
      />
      <div className="flex-1 min-w-0">
        <h1 className="text-[20px] text-[#0F1111] mb-3">
          {searchQuery ? (
            <>
              Resultados para <span className="font-bold text-[#C7511F]">&quot;{searchQuery}&quot;</span>
            </>
          ) : (
            'Todos los productos'
          )}
        </h1>
        <ResultsGrid items={results} rate={rate} />
      </div>
    </div>
  )
}

// ---------- Vista de categoría ----------
export function CategoryView() {
  const category = useStore((s) => s.category)
  const { items } = useCatalog()
  const [rate, setRate] = useState(0)
  useEffect(() => {
    api<Settings>('/api/settings')
      .then((st) => setRate(st.coinRate || 0))
      .catch(() => {})
  }, [])

  const [onlyDeals, setOnlyDeals] = useState(false)
  const [priceRange, setPriceRange] = useState('all')
  const [sort, setSort] = useState('featured')

  const results = useMemo(() => {
    let list =
      category === 'Ofertas'
        ? (items ?? []).filter((p) => itemDiscount(p) > 0)
        : category === 'Todos'
          ? (items ?? [])
          : (items ?? []).filter((p) => p.category === category)
    list = applyFilters(list, onlyDeals, priceRange)
    return sortItems(list, sort)
  }, [items, category, onlyDeals, priceRange, sort])

  const title =
    category === 'Ofertas'
      ? 'Ofertas con descuento'
      : category === 'Todos'
        ? 'Todos los departamentos'
        : category

  if (items !== null && items.length === 0) {
    return (
      <div className="px-4 py-4 max-w-[1600px] mx-auto">
        <h1 className="text-[24px] font-bold text-[#0F1111] mb-3">{title}</h1>
        <CatalogEmpty message={`${STORE_NAME} todavía no tiene ofertas publicadas`} />
      </div>
    )
  }

  return (
    <div className="px-4 py-4 max-w-[1600px] mx-auto flex gap-6">
      <Filters
        dept={category}
        setDept={() => {}}
        onlyDeals={onlyDeals}
        setOnlyDeals={setOnlyDeals}
        priceRange={priceRange}
        setPriceRange={setPriceRange}
      />
      <div className="flex-1 min-w-0">
        <h1 className="text-[24px] font-bold text-[#0F1111] mb-3">{title}</h1>
        <div className="flex items-center justify-end mb-3">
          <SortBar sort={sort} setSort={setSort} />
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-5 gap-3">
          {results.map((p) => (
            <ProductCard key={p.id} item={p} rate={rate} />
          ))}
        </div>
        {results.length === 0 && (
          <div className="bg-white p-8 rounded text-center text-[#565959]">
            Todavía no hay ofertas en este departamento.
          </div>
        )}
      </div>
    </div>
  )
}

// ---------- Detalle de la oferta (web o mini tienda) ----------
export function ProductDetail() {
  const productId = useStore((s) => s.productId)
  const addToCart = useStore((s) => s.addToCart)
  const openCart = useStore((s) => s.openCart)
  const goHome = useStore((s) => s.goHome)
  const { items } = useCatalog()
  const [rate, setRate] = useState(0)
  useEffect(() => {
    api<Settings>('/api/settings')
      .then((st) => setRate(st.coinRate || 0))
      .catch(() => {})
  }, [])

  const item = findItem(items, productId)
  const [qty, setQty] = useState(1)

  // Al abrir otra oferta, reiniciar la cantidad durante el render
  const [prevId, setPrevId] = useState<string | null>(productId)
  if (productId !== prevId) {
    setPrevId(productId)
    setQty(1)
  }

  if (items === null)
    return <p className="text-center py-16 text-[#565959]">Cargando oferta…</p>

  if (!item)
    return (
      <div className="p-10 text-center">
        Esta oferta ya no está disponible.{' '}
        <button onClick={goHome} className="text-[#C7511F] hover:underline cursor-pointer">
          Volver al inicio
        </button>
      </div>
    )

  const pct = itemDiscount(item)
  const coins = itemCoins(item, rate)
  const related = (items ?? []).filter(
    (p) => p.category === item.category && p.id !== item.id
  )

  const snapshot = {
    name: item.name,
    price: item.price,
    priceCoins: item.priceCoins > 0 ? item.priceCoins : undefined,
    photo: item.photo ?? undefined,
    storeName: item.store,
    productId: item.id.replace(/^(web|mini)-/, ''),
    kind: item.kind,
    stock: item.stock,
  }

  return (
    <div className="bg-white">
      <div className="px-4 py-3 max-w-[1500px] mx-auto">
        <button
          onClick={goHome}
          className="flex items-center gap-1 text-[14px] text-[#C7511F] hover:underline cursor-pointer"
        >
          <ChevronLeft className="w-4 h-4" /> Volver a la página principal
        </button>

        <div className="flex flex-col lg:flex-row gap-8 mt-4">
          {/* Foto */}
          <div className="lg:w-[45%]">
            <div className="border border-[#e3e6e6] rounded-lg overflow-hidden bg-white aspect-square">
              {item.photo ? (
                <img src={item.photo} alt={item.name} className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-[#f7fafa] to-[#eceff1]">
                  <Package className="w-24 h-24 text-[#c8cdcd]" strokeWidth={1.2} />
                </div>
              )}
            </div>
          </div>

          {/* Información */}
          <div className="lg:w-[33%]">
            <h1 className="text-[24px] leading-tight text-[#0F1111]">{item.name}</h1>
            <p
              className={`text-[14px] font-bold mt-1 ${
                item.kind === 'mini' ? 'text-[#5B21B6]' : 'text-[#007600]'
              }`}
            >
              {item.kind === 'mini'
                ? `Mini tienda: ${item.store}`
                : `Vendido por ${STORE_NAME} (dueño de la web)`}
            </p>
            <hr className="my-3 border-[#e3e6e6]" />
            {pct > 0 && (
              <div className="flex items-center gap-2">
                <span className="text-[28px] font-medium text-[#CC0C39]">-{pct}%</span>
                <span className="text-[13px] text-[#CC0C39]">Oferta con descuento</span>
              </div>
            )}
            {item.oldPrice && (
              <div className="flex items-baseline gap-2 mt-1">
                <span className="text-[13px] text-[#565959]">Precio anterior:</span>
                <span className="text-[13px] text-[#565959] line-through">
                  {formatPrice(item.oldPrice)}
                </span>
              </div>
            )}
            <p className="text-[32px] font-medium text-[#0F1111] leading-none mt-1">
              {formatPrice(item.price)}
            </p>
            <p className="text-[15px] font-bold text-[#5B21B6] mt-1.5 flex items-center gap-1.5">
              <Coins className="w-4 h-4" /> o {formatCoins(coins)} monedas de la tienda
            </p>
            <p className="text-[13px] text-[#565959] mt-1">
              Puedes pagar en <b>efectivo o transferencia (CUP)</b> al recibir o con tu{' '}
              <b>saldo en monedas</b> de la billetera interna.
            </p>
            <p className="text-[14px] mt-3">
              <span className="font-bold text-[#0F1111]">Entrega a domicilio</span> con un
              repartidor de {STORE_NAME}. Eliges el punto en el mini mapa.
            </p>
            <hr className="my-3 border-[#e3e6e6]" />
            {item.description && (
              <p className="text-[14px] text-[#0F1111] leading-relaxed">{item.description}</p>
            )}
            <ul className="text-[13px] text-[#0F1111] mt-3 space-y-1 list-disc pl-5">
              <li>Departamento: {item.category}</li>
              <li>Devolución gratuita durante 30 días</li>
              <li>Pago 100% seguro</li>
            </ul>
          </div>

          {/* Caja de compra */}
          <div className="lg:w-[22%]">
            <div className="border border-[#e3e6e6] rounded-lg p-4 space-y-3">
              <p className="text-[20px] font-medium text-[#0F1111]">{formatPrice(item.price)}</p>
              <p className="text-[13px] font-bold text-[#5B21B6] flex items-center gap-1">
                <Coins className="w-3.5 h-3.5" /> {formatCoins(coins)} monedas
              </p>
              <p className="text-[13px] text-[#565959]">
                <span className="text-[#007600] font-bold">Envío GRATIS</span> con repartidor de{' '}
                {STORE_NAME}
              </p>
              {item.stock <= 0 ? (
                <p className="text-[14px] font-bold text-[#C7511F] bg-[#FDE8E0] rounded px-3 py-2">
                  Agotado: no hay unidades en el almacén ahora mismo
                </p>
              ) : (
                <>
                  <p
                    className={`text-[13px] font-bold ${
                      item.stock <= 5 ? 'text-[#B45309]' : 'text-[#007600]'
                    }`}
                  >
                    {item.stock <= 5
                      ? `¡Últimas ${item.stock} unidades!`
                      : `Hay ${item.stock} unidades disponibles en el almacén`}
                  </p>
                  <label className="block text-[13px]">
                    Cantidad:
                    <select
                      value={qty}
                      onChange={(e) => setQty(Number(e.target.value))}
                      className="ml-2 border border-[#ddd] rounded px-2 py-1 bg-[#f0f2f2] cursor-pointer"
                    >
                      {Array.from({ length: Math.min(10, item.stock) }, (_, i) => i + 1).map((n) => (
                        <option key={n} value={n}>
                          {n}
                        </option>
                      ))}
                    </select>
                  </label>
                </>
              )}
              <button
                onClick={() => {
                  addToCart(item.id, qty, snapshot)
                  toast.success(`Agregado al carrito (${qty})`, { description: item.name })
                }}
                disabled={item.stock <= 0}
                className={`w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] rounded-full py-2 ${
                  item.stock <= 0 ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
                }`}
              >
                Agregar al carrito
              </button>
              <button
                onClick={() => {
                  addToCart(item.id, qty, snapshot)
                  openCart()
                }}
                disabled={item.stock <= 0}
                className={`w-full bg-[#FFA41C] hover:bg-[#FA8900] text-[#0F1111] text-[14px] rounded-full py-2 ${
                  item.stock <= 0 ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
                }`}
              >
                Comprar ahora
              </button>
            </div>
          </div>
        </div>

        {related.length > 0 && (
          <div className="mt-8 -mx-4">
            <ProductRow title={`Más ofertas en ${item.category}`} items={related} rate={rate} />
          </div>
        )}
      </div>
    </div>
  )
}

// ---------- Carrito ----------
export function CartView() {
  const cart = useStore((s) => s.cart)
  const setQty = useStore((s) => s.setQty)
  const removeFromCart = useStore((s) => s.removeFromCart)
  const openProduct = useStore((s) => s.openProduct)
  const openView = useStore((s) => s.openView)
  const goHome = useStore((s) => s.goHome)

  // Tasa de cambio dinero -> monedas (la configura el administrador)
  const [rate, setRate] = useState(0)
  useEffect(() => {
    api<Settings>('/api/settings')
      .then((st) => setRate(st.coinRate || 0))
      .catch(() => {})
  }, [])

  // Cada artículo del carrito lleva su "foto" con nombre, precio
  // en las dos monedas y tienda (sea web o mini tienda)
  const items = cart
    .map((i) => {
      if (!i.mini) return null // artículos antiguos sin datos: se descartan
      return {
        id: i.id,
        qty: i.qty,
        name: i.mini.name,
        price: i.mini.price,
        coins: i.mini.priceCoins ?? cashToCoins(i.mini.price, rate),
        store: i.mini.storeName,
        img: i.mini.photo ?? null,
      }
    })
    .filter((x) => x !== null)
  const subtotal = items.reduce((acc, i) => acc + i.price * i.qty, 0)
  const count = items.reduce((acc, i) => acc + i.qty, 0)

  // Carrito vacío
  if (items.length === 0)
    return (
      <div className="p-6 max-w-3xl mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-10 text-center">
          <ShoppingBag className="w-20 h-20 text-[#ddd] mx-auto" strokeWidth={1.2} />
          <h1 className="text-[24px] font-bold text-[#0F1111] mt-4">
            Tu carrito de {STORE_NAME} está vacío
          </h1>
          <button
            onClick={goHome}
            className="mt-6 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] rounded-full px-8 py-2 cursor-pointer"
          >
            Ir a comprar
          </button>
        </div>
      </div>
    )

  return (
    <div className="p-4 max-w-[1300px] mx-auto flex flex-col lg:flex-row gap-4">
      {/* Lista de artículos */}
      <div className="flex-1 bg-white rounded-lg border border-[#e3e6e6] p-6">
        <div className="flex justify-between text-[14px] text-[#565959]">
          <h1 className="text-[28px] font-normal text-[#0F1111]">Carrito de la compra</h1>
          <span className="hidden sm:block">Precio</span>
        </div>
        <hr className="my-3 border-[#e3e6e6]" />
        {items.map((entry) => (
          <div
            key={entry.id}
            className="py-4 border-b border-[#e3e6e6] flex gap-4 last:border-b-0"
          >
            <button
              onClick={() => openProduct(entry.id)}
              className="shrink-0 cursor-pointer"
              aria-label={`Ver ${entry.name}`}
            >
              {entry.img ? (
                <img
                  src={entry.img}
                  alt={entry.name}
                  className="w-28 h-28 sm:w-40 sm:h-40 object-cover rounded"
                />
              ) : (
                <div className="w-28 h-28 sm:w-40 sm:h-40 bg-gradient-to-br from-[#f7fafa] to-[#eceff1] rounded flex items-center justify-center">
                  <Package className="w-12 h-12 text-[#c8cdcd]" strokeWidth={1.3} />
                </div>
              )}
            </button>
            <div className="flex-1 min-w-0">
              <button
                onClick={() => openProduct(entry.id)}
                className="text-[16px] sm:text-[18px] text-[#0F1111] hover:underline cursor-pointer text-left line-clamp-2"
              >
                {entry.name}
              </button>
              <p className="text-[13px] mt-1">
                {entry.store !== STORE_NAME ? (
                  <span className="text-[#5B21B6] font-bold">
                    Mini tienda: {entry.store} · Envío con repartidor
                  </span>
                ) : (
                  <span className="text-[#007600] font-bold">Vendido por {STORE_NAME} · Envío con repartidor</span>
                )}
              </p>
              <p className="text-[13px] text-[#5B21B6] font-bold mt-0.5 flex items-center gap-1">
                <Coins className="w-3.5 h-3.5" /> {formatCoins(entry.coins)} monedas por unidad
              </p>
              <div className="flex items-center gap-2 mt-2 text-[13px]">
                <button
                  onClick={() => setQty(entry.id, entry.qty - 1)}
                  className="w-6 h-6 border border-[#ddd] rounded flex items-center justify-center hover:bg-[#f0f2f2] cursor-pointer"
                  aria-label="Reducir cantidad"
                >
                  <Minus className="w-3 h-3" />
                </button>
                <span className="w-8 text-center font-bold">{entry.qty}</span>
                <button
                  onClick={() => setQty(entry.id, entry.qty + 1)}
                  className="w-6 h-6 border border-[#ddd] rounded flex items-center justify-center hover:bg-[#f0f2f2] cursor-pointer"
                  aria-label="Aumentar cantidad"
                >
                  <Plus className="w-3 h-3" />
                </button>
                <span className="text-[#ddd]">|</span>
                <button
                  onClick={() => {
                    removeFromCart(entry.id)
                    toast('Artículo eliminado del carrito')
                  }}
                  className="text-[#C7511F] hover:underline flex items-center gap-1 cursor-pointer"
                >
                  <Trash2 className="w-3.5 h-3.5" /> Eliminar
                </button>
              </div>
            </div>
            <p className="text-[18px] font-bold text-[#0F1111] shrink-0">
              {formatPrice(entry.price * entry.qty)}
            </p>
          </div>
        ))}
        <p className="text-right text-[18px] mt-4 text-[#0F1111]">
          Subtotal ({count} {count === 1 ? 'artículo' : 'artículos'}):{' '}
          <span className="font-bold">{formatPrice(subtotal)}</span>
        </p>
        {rate > 0 && (
          <p className="text-right text-[13px] text-[#5B21B6] font-bold flex items-center justify-end gap-1 mt-1">
            <Coins className="w-3.5 h-3.5" /> o{' '}
            {formatCoins(items.reduce((acc, i) => acc + i.coins * i.qty, 0))} monedas desde tu
            billetera
          </p>
        )}
      </div>

      {/* Resumen */}
      <div className="lg:w-80 shrink-0">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-6 lg:sticky lg:top-28">
          {subtotal >= 35 && (
            <p className="text-[13px] text-[#007600] mb-2">
              Tu pedido califica para <span className="font-bold">envío GRATIS</span>.
            </p>
          )}
          <p className="text-[18px] text-[#0F1111]">
            Subtotal ({count} {count === 1 ? 'artículo' : 'artículos'}):{' '}
            <span className="font-bold">{formatPrice(subtotal)}</span>
          </p>
          {rate > 0 && (
            <p className="text-[13px] text-[#5B21B6] font-bold flex items-center gap-1 mt-1">
              <Coins className="w-4 h-4" /> o{' '}
              {formatCoins(items.reduce((acc, i) => acc + i.coins * i.qty, 0))} monedas con tu
              billetera
            </p>
          )}
          <label className="flex items-center gap-2 text-[13px] mt-3 cursor-pointer">
            <input type="checkbox" className="accent-[#5B21B6] w-4 h-4" />
            Este pedido contiene un regalo
          </label>
          <button
            onClick={() => openView('checkout')}
            className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] rounded-full py-2 mt-4 cursor-pointer"
          >
            Proceder al pago
          </button>
          <p className="text-[12px] text-[#565959] text-center mt-2">
            Elegirás el punto de entrega en el mini mapa
          </p>
        </div>
      </div>
    </div>
  )
}
