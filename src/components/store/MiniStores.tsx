'use client'
// ============================================================
// MINI TIENDAS DE VIOLETERO (diseño nuevo con fotos)
// - MiniStoresView:   lista de mini tiendas + botón de crear
// - MiniStoreDetail:  productos de la tienda (comprar)
// - ManageStoreView:  panel del dueño (productos con FOTO y
//                     precios en las dos monedas, ofertas de
//                     trabajo y postulaciones)
// Cada tienda tiene logotipo y color de marca. Cada producto
// puede subir una foto real y se publica su precio en CUP
// y en monedas internas de la tienda.
// ============================================================
import { useEffect, useState } from 'react'
import {
  Briefcase,
  Building2,
  Check,
  Coins,
  Package,
  Plus,
  Store,
  Tag,
  Trash2,
  UserCheck,
  X,
} from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import { CATEGORIES, formatPrice, formatCoins } from '@/lib/products'
import { PhotoInput } from './PhotoInput'
import {
  api,
  storeStatus,
  type Application,
  type JobOffer,
  type MiniProduct,
  type MiniStore,
  type Settings,
  type Wallet,
} from '@/lib/api'

// Colores de marca que puede elegir el dueño de la tienda
const STORE_COLORS = ['#5B21B6', '#C7511F', '#007600', '#0F1111', '#B45309', '#0F766E', '#9D174D']

// ---------- Piezas visuales compartidas ----------
// Logotipo de la tienda: foto subida o iniciales sobre el color
export function StoreLogo({
  store,
  size = 48,
  rounded = 'rounded-lg',
}: {
  store: Pick<MiniStore, 'name' | 'logo' | 'color' | 'emoji'>
  size?: number
  rounded?: string
}) {
  const initials = store.name
    .split(' ')
    .map((w) => w[0])
    .filter(Boolean)
    .slice(0, 2)
    .join('')
    .toUpperCase()
  if (store.logo) {
    return (
       
      <img
        src={store.logo}
        alt={`Logotipo de ${store.name}`}
        className={`${rounded} object-cover shrink-0`}
        style={{ width: size, height: size }}
      />
    )
  }
  return (
    <div
      className={`${rounded} flex items-center justify-center shrink-0 text-white font-bold select-none`}
      style={{
        width: size,
        height: size,
        background: `linear-gradient(135deg, ${store.color}, ${store.color}CC)`,
        fontSize: size * 0.36,
      }}
      aria-label={`Logotipo de ${store.name}`}
    >
      {initials || <Store style={{ width: size * 0.5, height: size * 0.5 }} />}
    </div>
  )
}

// Foto del producto: foto real subida o, si no tiene, un fondo
// elegante con el color de la marca y la inicial del producto
// (se acabaron los dibujos pobres: siempre se ve bien)
function ProductPhoto({
  product,
  color = '#5B21B6',
  className = '',
}: {
  product: MiniProduct
  color?: string
  className?: string
}) {
  if (product.photo) {
    return (
      <img
        src={product.photo}
        alt={product.name}
        className={`w-full h-full object-cover ${className}`}
      />
    )
  }
  const initial = (product.name || '?').trim().charAt(0).toUpperCase()
  return (
    <div
      className={`w-full h-full flex items-center justify-center relative overflow-hidden ${className}`}
      style={{ background: `linear-gradient(135deg, ${color}14, ${color}30)` }}
      role="img"
      aria-label={product.name}
    >
      <span
        className="font-black select-none leading-none"
        style={{ color: `${color}4D`, fontSize: 'clamp(48px, 40%, 96px)' }}
      >
        {initial}
      </span>
      <Package
        className="absolute bottom-2 right-2 w-5 h-5"
        style={{ color: `${color}59` }}
        strokeWidth={1.6}
      />
    </div>
  )
}

// Flores decorativas para los encabezados (igual que el icono de
// Violetero: una flor de 5 pétalos) sobre el color de la tienda
function HeroFlowers({ tall = false }: { tall?: boolean }) {
  const Flower = ({ x, y, r, o }: { x: number; y: number; r: number; o: number }) => (
    <g transform={`translate(${x} ${y})`} opacity={o}>
      <circle cx="0" cy={-r} r={r * 0.62} fill="#fff" />
      <circle cx={r * 0.95} cy={-r * 0.31} r={r * 0.62} fill="#fff" />
      <circle cx={r * 0.59} cy={r * 0.81} r={r * 0.62} fill="#fff" />
      <circle cx={-r * 0.59} cy={r * 0.81} r={r * 0.62} fill="#fff" />
      <circle cx={-r * 0.95} cy={-r * 0.31} r={r * 0.62} fill="#fff" />
      <circle cx="0" cy="0" r={r * 0.5} fill="#fff" opacity="0.9" />
    </g>
  )
  return (
    <svg
      className="absolute inset-0 w-full h-full"
      viewBox={`0 0 800 ${tall ? 170 : 96}`}
      preserveAspectRatio="xMidYMid slice"
      aria-hidden="true"
    >
      <Flower x={700} y={tall ? 46 : 28} r={tall ? 26 : 16} o={0.16} />
      <Flower x={756} y={tall ? 128 : 72} r={tall ? 18 : 12} o={0.12} />
      <Flower x={624} y={tall ? 138 : 80} r={tall ? 14 : 10} o={0.1} />
      <Flower x={44} y={tall ? 148 : 84} r={tall ? 22 : 13} o={0.1} />
    </svg>
  )
}

// Precios en las dos monedas: dinero real + monedas internas.
// Si el producto tiene precio anterior, se muestra tachado con
// el % de cambio (subió en rojo, bajó en verde)
function DualPrice({
  cash,
  coins,
  oldPrice,
  big = false,
}: {
  cash: number
  coins: number
  oldPrice?: number | null
  big?: boolean
}) {
  const changed = oldPrice && oldPrice > 0 && oldPrice !== cash
  const pct = changed ? Math.abs(Math.round((1 - cash / (oldPrice as number)) * 100)) : 0
  return (
    <div className="mt-2">
      <div className="flex items-baseline gap-2 flex-wrap">
        {changed && (
          <span className="text-[12px] text-[#565959] line-through">
            {formatPrice(oldPrice as number)}
          </span>
        )}
        <p className={`${big ? 'text-[21px]' : 'text-[17px]'} font-bold text-[#0F1111] leading-none`}>
          {formatPrice(cash)}
        </p>
      </div>
      {changed && pct > 0 && (
        <p
          className={`text-[12px] font-bold mt-0.5 ${
            cash < (oldPrice as number) ? 'text-[#007600]' : 'text-[#CC0C39]'
          }`}
        >
          {cash < (oldPrice as number) ? 'Bajó' : 'Subió'} {pct}% frente al precio anterior
        </p>
      )}
      <p
        className="text-[13px] font-bold text-[#5B21B6] flex items-center gap-1 mt-1"
        title="Precio en monedas internas de la tienda"
      >
        <Coins className="w-3.5 h-3.5" /> {formatCoins(coins)} monedas
      </p>
    </div>
  )
}

// ============================================================
// SECCIÓN DE INICIO: mini tiendas destacadas
// ============================================================
// Editor de la cantidad en el almacén de un producto (solo el dueño)
function StockEditor({
  productId,
  ownerName,
  current,
  onSaved,
}: {
  productId: string
  ownerName: string
  current: number
  onSaved: () => void
}) {
  const [val, setVal] = useState(String(current))
  const [saving, setSaving] = useState(false)
  useEffect(() => setVal(String(current)), [current])
  const save = async () => {
    const n = parseInt(val, 10)
    if (isNaN(n) || n < 0) {
      toast.error('La cantidad debe ser 0 o más')
      return
    }
    setSaving(true)
    try {
      await api(`/api/miniproducts/${productId}`, {
        method: 'PATCH',
        body: JSON.stringify({ stock: n, ownerName }),
      })
      toast.success('Cantidad del almacén actualizada')
      onSaved()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }
  return (
    <div className="flex items-center gap-1 shrink-0">
      <input
        value={val}
        onChange={(e) => setVal(e.target.value)}
        type="number"
        min="0"
        aria-label="Cantidad en el almacén"
        className="w-16 border border-[#888c8c] rounded px-2 py-1 text-[13px] outline-none focus:border-[#e77600]"
      />
      <button
        onClick={save}
        disabled={saving}
        className="text-[12px] font-bold bg-[#FFD814] hover:bg-[#F7CA00] rounded-full px-3 py-1 cursor-pointer disabled:opacity-60"
      >
        Guardar
      </button>
    </div>
  )
}

// Editor de precio del producto: al cambiarlo, el precio anterior
// queda guardado automáticamente y se muestra tachado con el %
// de cambio en las tarjetas (subió o bajó)
function PriceEditor({
  productId,
  ownerName,
  current,
  onSaved,
}: {
  productId: string
  ownerName: string
  current: number
  onSaved: () => void
}) {
  const [open, setOpen] = useState(false)
  const [val, setVal] = useState(String(current))
  const [saving, setSaving] = useState(false)
  useEffect(() => setVal(String(current)), [current])
  const save = async () => {
    const p = parseFloat(val)
    if (!p || p <= 0) {
      toast.error('El precio debe ser mayor que 0')
      return
    }
    if (p === current) {
      setOpen(false)
      return
    }
    setSaving(true)
    try {
      await api(`/api/miniproducts/${productId}`, {
        method: 'PATCH',
        body: JSON.stringify({ ownerName, price: p }),
      })
      toast.success(
        `Precio actualizado a ${formatPrice(p)}: el precio anterior queda guardado y se ve tachado`
      )
      setOpen(false)
      onSaved()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }
  if (!open) {
    return (
      <button
        onClick={() => setOpen(true)}
        className="text-[12px] font-bold text-[#5B21B6] hover:underline flex items-center gap-1 cursor-pointer shrink-0"
      >
        <Tag className="w-3.5 h-3.5" /> Cambiar precio
      </button>
    )
  }
  return (
    <div className="flex items-center gap-1 shrink-0">
      <input
        value={val}
        onChange={(e) => setVal(e.target.value)}
        type="number"
        min="1"
        aria-label="Precio nuevo en CUP"
        className="w-24 border border-[#888c8c] rounded px-2 py-1 text-[13px] outline-none focus:border-[#e77600]"
      />
      <button
        onClick={save}
        disabled={saving}
        className="text-[12px] font-bold bg-[#FFD814] hover:bg-[#F7CA00] rounded-full px-3 py-1 cursor-pointer disabled:opacity-60"
      >
        Guardar
      </button>
      <button
        onClick={() => setOpen(false)}
        aria-label="Cerrar editor de precio"
        className="text-[#565959] hover:text-[#0F1111] cursor-pointer p-1"
      >
        <X className="w-3.5 h-3.5" />
      </button>
    </div>
  )
}

export function HomeMiniStores() {
  const openView = useStore((s) => s.openView)
  const openMiniStore = useStore((s) => s.openMiniStore)
  const [stores, setStores] = useState<MiniStore[]>([])
  const [enabled, setEnabled] = useState(true)

  useEffect(() => {
    api<Settings>('/api/settings')
      .then((st) => setEnabled(st.miniStoresEnabled))
      .catch(() => {})
    api<MiniStore[]>('/api/ministores')
      .then(setStores)
      .catch(() => {})
  }, [])

  if (!enabled) return null

  return (
    <section className="max-w-[1600px] mx-auto px-3 mb-3">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-5">
        <div className="flex items-center justify-between flex-wrap gap-2 mb-3">
          <h2 className="text-[21px] font-bold text-[#0F1111]">Mini tiendas dentro de Violetero</h2>
          <button
            onClick={() => openView('ministores')}
            className="text-[13px] text-[#5B21B6] font-bold hover:underline cursor-pointer"
          >
            Ver todas las mini tiendas →
          </button>
        </div>
        {stores.length === 0 ? (
          <button
            onClick={() => openView('manage-store')}
            className="w-full text-left bg-[#f7fafa] border border-dashed border-[#d5d9d9] rounded-lg p-5 hover:border-[#5B21B6] cursor-pointer"
          >
            <p className="text-[15px] font-bold text-[#0F1111]">
              ¿Vendes algo? Abre tu mini tienda hoy mismo
            </p>
            <p className="text-[13px] text-[#565959] mt-1">
              Publica productos con foto, cobra en efectivo o en monedas, contrata repartidores y
              entrega a domicilio con el mini mapa.
            </p>
          </button>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {stores
              .filter((s) => storeStatus(s).status !== 'expired')
              .slice(0, 4)
              .map((s) => (
              <button
                key={s.id}
                onClick={() => openMiniStore(s.id)}
                className="border border-[#e3e6e6] rounded-lg overflow-hidden text-left hover:shadow-md transition-shadow cursor-pointer group"
              >
                {/* Tapa con el color de la marca y logotipo superpuesto */}
                <div
                  className="relative h-11"
                  style={{ background: `linear-gradient(115deg, ${s.color}, ${s.color}B3)` }}
                >
                  <HeroFlowers />
                  <div className="absolute -bottom-4 left-3 rounded-lg border-2 border-white shadow-sm">
                    <StoreLogo store={s} size={40} />
                  </div>
                </div>
                <div className="pt-6 px-3 pb-3">
                  <p className="text-[14px] font-bold text-[#0F1111] truncate group-hover:underline">
                    {s.name}
                  </p>
                  <p className="text-[12px] text-[#565959]">
                    {s.products.length} {s.products.length === 1 ? 'producto' : 'productos'}
                  </p>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>
    </section>
  )
}

// ============================================================
// LISTA DE MINI TIENDAS
// ============================================================
export function MiniStoresView() {
  const openView = useStore((s) => s.openView)
  const openMiniStore = useStore((s) => s.openMiniStore)
  const [stores, setStores] = useState<MiniStore[]>([])
  const [settings, setSettings] = useState<Settings | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([api<MiniStore[]>('/api/ministores'), api<Settings>('/api/settings')])
      .then(([s, st]) => {
        setStores(s)
        setSettings(st)
      })
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [])

  return (
    <div className="p-4 max-w-[1300px] mx-auto">
      {/* Encabezado */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6 mb-4 flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
        <div>
          <h1 className="text-[28px] font-bold text-[#0F1111]">Mini tiendas de {STORE_NAME}</h1>
          <p className="text-[14px] text-[#565959] mt-1">
            Pequeños emprendedores que venden dentro de {STORE_NAME}. ¡Apoya lo local!
          </p>
        </div>
        {settings?.miniStoresEnabled ? (
          <button
            onClick={() => openView('manage-store')}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-6 py-2.5 flex items-center gap-2 cursor-pointer shrink-0"
          >
            <Plus className="w-4 h-4" /> Crear mi mini tienda
          </button>
        ) : (
          <span className="bg-[#f0f2f2] border border-[#d5d9d9] text-[#565959] text-[13px] rounded-lg px-4 py-2.5 shrink-0">
            Las mini tiendas están desactivadas por el administrador
          </span>
        )}
      </div>

      {loading ? (
        <p className="text-center text-[#565959] py-10 text-[14px]">Cargando mini tiendas…</p>
      ) : stores.length === 0 || !settings?.miniStoresEnabled ? (
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-12 text-center">
          <Store className="w-16 h-16 text-[#ddd] mx-auto" strokeWidth={1.2} />
          <p className="text-[16px] text-[#0F1111] font-bold mt-4">
            {settings?.miniStoresEnabled
              ? 'Aún no hay mini tiendas'
              : 'Las mini tiendas están desactivadas'}
          </p>
          <p className="text-[14px] text-[#565959] mt-1">
            {settings?.miniStoresEnabled
              ? '¡Sé el primero en abrir la tuya y empezar a vender!'
              : 'Vuelve más tarde: el administrador puede reactivarlas cuando quiera.'}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {stores
            .filter((store) => storeStatus(store).status !== 'expired')
            .map((store) => (
            <button
              key={store.id}
              onClick={() => openMiniStore(store.id)}
              className="bg-white rounded-lg border border-[#e3e6e6] text-left hover:shadow-lg transition-shadow cursor-pointer overflow-hidden group"
            >
              {/* Tapa con el color de marca y flores, logotipo superpuesto */}
              <div
                className="relative h-16"
                style={{
                  background: `linear-gradient(115deg, ${store.color}, ${store.color}B3)`,
                }}
              >
                <HeroFlowers />
                <div className="absolute -bottom-6 left-4 rounded-xl border-[3px] border-white shadow-md">
                  <StoreLogo store={store} size={56} />
                </div>
              </div>
              <div className="px-4 pb-4 pt-8">
                <h3 className="text-[17px] font-bold text-[#0F1111] truncate group-hover:underline">
                  {store.name}
                </h3>
                <p className="text-[12px] text-[#565959] mt-0.5">
                  De {store.ownerName} · {store.category}
                </p>
                <p className="text-[13px] text-[#565959] mt-2 line-clamp-2">{store.description}</p>
                <p className="text-[13px] text-[#007600] font-bold mt-3">
                  {store.products.length}{' '}
                  {store.products.length === 1 ? 'producto' : 'productos'} a la venta · Ver tienda →
                </p>
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

// ============================================================
// DETALLE DE UNA MINI TIENDA (comprar)
// ============================================================
export function MiniStoreDetail() {
  const storeId = useStore((s) => s.storeId)
  const addToCart = useStore((s) => s.addToCart)
  const [store, setStore] = useState<MiniStore | null>(null)
  const [loading, setLoading] = useState(true)

  const load = () => {
    if (!storeId) return
    api<MiniStore>(`/api/ministores/${storeId}`)
      .then(setStore)
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }
  useEffect(load, [storeId])

  if (loading) return <p className="text-center py-16 text-[#565959]">Cargando tienda…</p>
  if (!store)
    return <p className="text-center py-16 text-[#565959]">Esta mini tienda ya no existe.</p>

  return (
    <div className="p-4 max-w-[1300px] mx-auto">
      {/* Encabezado tipo héroe con el color de la marca */}
      <div className="rounded-lg overflow-hidden border border-[#e3e6e6] mb-4 bg-white">
        <div
          className="relative h-[150px] sm:h-[170px]"
          style={{
            background: `linear-gradient(115deg, ${store.color}, ${store.color}CC 55%, ${store.color}99)`,
          }}
        >
          <HeroFlowers tall />
          {/* Nombre y etiquetas elevados para no chocar con el logotipo */}
          <div className="absolute inset-x-0 bottom-0 px-4 sm:px-6 pb-12 sm:pb-14 flex flex-wrap items-center gap-x-4 gap-y-2">
            <h1 className="text-[30px] sm:text-[34px] font-black text-white leading-tight drop-shadow-sm truncate max-w-full">
              {store.name}
            </h1>
            <div className="flex flex-wrap items-center gap-2">
              <span className="bg-white/20 backdrop-blur-sm text-white text-[12px] font-bold rounded-full px-3 py-1">
                {store.category}
              </span>
              <span className="bg-white/20 backdrop-blur-sm text-white text-[12px] font-bold rounded-full px-3 py-1">
                Mini tienda de {store.ownerName}
              </span>
            </div>
          </div>
        </div>
        <div className="px-5 sm:px-6 pb-5 flex flex-col sm:flex-row gap-4 items-start">
          <div className="rounded-xl border-4 border-white shadow-md -mt-10 relative z-10">
            <StoreLogo store={store} size={84} rounded="rounded-xl" />
          </div>
          <p className="flex-1 text-[14px] text-[#0F1111] sm:mt-2">{store.description}</p>
          <div className="bg-[#f7fafa] border border-[#d5d9d9] rounded-lg px-4 py-3 text-[13px] shrink-0 sm:mt-2">
            <p className="font-bold text-[#0F1111]">
              {store.products.length}{' '}
              {store.products.length === 1 ? 'producto publicado' : 'productos publicados'}
            </p>
            <p className="text-[#007600] font-bold mt-0.5">
              Envío por repartidor de {STORE_NAME}
            </p>
          </div>
        </div>
      </div>

      {/* Productos */}
      {storeStatus(store).status === 'expired' ? (
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-12 text-center">
          <Store className="w-16 h-16 text-[#ddd] mx-auto" strokeWidth={1.2} />
          <p className="text-[16px] font-bold text-[#0F1111] mt-4">
            Esta mini tienda está suspendida temporalmente
          </p>
          <p className="text-[14px] text-[#565959] mt-1">
            Su prueba gratis terminó y la suscripción mensual no está pagada. Vuelve más tarde:
            cuando el dueño la renueve, sus productos volverán a verse aquí y en el catálogo.
          </p>
        </div>
      ) : store.products.length === 0 ? (
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-12 text-center">
          <Package className="w-16 h-16 text-[#ddd] mx-auto" strokeWidth={1.2} />
          <p className="text-[15px] text-[#565959] mt-4">
            Esta mini tienda todavía no publicó productos.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {store.products.map((p: MiniProduct) => (
            <div
              key={p.id}
              className="group bg-white rounded-lg border border-[#e3e6e6] overflow-hidden flex flex-col hover:shadow-lg transition-shadow"
            >
              <div className="relative aspect-square overflow-hidden">
                <ProductPhoto
                  product={p}
                  color={store.color}
                  className="group-hover:scale-105 transition-transform duration-300"
                />
                {p.stock <= 0 && (
                  <div className="absolute inset-0 bg-white/70 flex items-center justify-center">
                    <span className="bg-[#0F1111] text-white text-[12px] font-bold rounded px-3 py-1">
                      Agotado
                    </span>
                  </div>
                )}
                {p.stock > 0 && p.stock <= 5 && (
                  <span className="absolute top-2 left-2 bg-[#C7511F] text-white text-[11px] font-bold rounded px-2 py-0.5 shadow-sm">
                    ¡Últimas {p.stock}!
                  </span>
                )}
              </div>
              <div className="p-3 flex flex-col flex-1">
                <h3 className="text-[15px] font-bold text-[#0F1111] line-clamp-2">{p.name}</h3>
                <p className="text-[12px] text-[#565959] line-clamp-2 mt-1 flex-1">
                  {p.description}
                </p>
                <div className="mt-2">
                  <DualPrice cash={p.price} coins={p.priceCoins} oldPrice={p.oldPrice} />
                </div>
                <p
                  className={`text-[12px] font-bold mt-1 ${
                    p.stock <= 0 ? 'text-[#C7511F]' : 'text-[#007600]'
                  }`}
                >
                  {p.stock <= 0
                    ? 'Sin unidades por ahora'
                    : p.stock <= 5
                      ? `¡Solo quedan ${p.stock}!`
                      : `Hay ${p.stock} en el almacén`}
                </p>
                <button
                  onClick={() => {
                    if (p.stock <= 0) {
                      toast.error(`"${p.name}" está agotado: no hay unidades disponibles`)
                      return
                    }
                    addToCart(`mini-${p.id}`, 1, {
                      name: p.name,
                      price: p.price,
                      priceCoins: p.priceCoins,
                      photo: p.photo ?? undefined,
                      storeName: store.name,
                      productId: p.id,
                      kind: 'mini',
                      stock: p.stock,
                    })
                    toast.success(`"${p.name}" se agregó al carrito`)
                  }}
                  disabled={p.stock <= 0}
                  className={`mt-3 w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full py-2 ${
                    p.stock <= 0 ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
                  }`}
                >
                  {p.stock <= 0 ? 'Agotado' : 'Agregar al carrito'}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

// ============================================================
// PANEL DEL DUEÑO DE LA MINI TIENDA
// Crear tienda (logo + color), publicar productos (FOTO +
// precio en CUP y monedas), ofertas de trabajo y postulaciones
// ============================================================
export function ManageStoreView() {
  const user = useStore((s) => s.user)

  const [store, setStore] = useState<MiniStore | null>(null)
  const [settings, setSettings] = useState<Settings | null>(null)
  const [loading, setLoading] = useState(true)

  // Formulario de creación de tienda
  const [fName, setFName] = useState('')
  const [fDesc, setFDesc] = useState('')
  const [fCat, setFCat] = useState(CATEGORIES[0])
  const [fLogo, setFLogo] = useState<string | null>(null)
  const [fColor, setFColor] = useState(STORE_COLORS[0])

  // Formulario de producto (dos monedas + foto)
  const [pName, setPName] = useState('')
  const [pPrice, setPPrice] = useState('')
  const [pCoins, setPCoins] = useState('')
  const [pDesc, setPDesc] = useState('')
  const [pPhoto, setPPhoto] = useState<string | null>(null)
  const [pStock, setPStock] = useState('')

  // Ofertas de trabajo de esta tienda + postulaciones
  const [offers, setOffers] = useState<JobOffer[]>([])
  const [applications, setApplications] = useState<Application[]>([])
  // Saldo del dueño para pagar la suscripción de la tienda
  const [wallet, setWallet] = useState<Wallet | null>(null)
  const [payingSub, setPayingSub] = useState(false)
  // Tarifa que gana el mensajero por entrega (la define el dueño)
  const [feeDraft, setFeeDraft] = useState('200')
  const [savingFee, setSavingFee] = useState(false)
  // Formulario de oferta de trabajo
  const [oTitle, setOTitle] = useState('')
  const [oZone, setOZone] = useState('')
  const [oPayment, setOPayment] = useState('')
  const [oDesc, setODesc] = useState('')

  const loadAll = (store: MiniStore) => {
    Promise.all([api<JobOffer[]>('/api/joboffers'), api<Application[]>('/api/applications')])
      .then(([offs, apps]) => {
        setOffers(offs.filter((o) => o.storeId === store.id))
        const myJobIds = offs.filter((o) => o.storeId === store.id).map((o) => o.id)
        setApplications(apps.filter((a) => myJobIds.includes(a.jobId)))
      })
      .catch((e) => toast.error(e.message))
  }

  useEffect(() => {
    Promise.all([api<MiniStore[]>('/api/ministores'), api<Settings>('/api/settings')])
      .then(([stores, st]) => {
        setSettings(st)
        const mine = stores.find((s) => s.ownerName === user.name)
        setStore(mine || null)
        if (mine) loadAll(mine)
      })
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
    // Saldo del dueño (para la suscripción de la tienda)
    if (user.name && user.name !== 'Invitado') {
      api<Wallet>(`/api/wallet?name=${encodeURIComponent(user.name)}`)
        .then(setWallet)
        .catch(() => {})
    }
  }, [user.name])

  const createStore = async () => {
    if (!fName.trim() || !fDesc.trim()) {
      toast.error('Escribe el nombre y la descripción de tu mini tienda')
      return
    }
    try {
      const created = await api<MiniStore>('/api/ministores', {
        method: 'POST',
        body: JSON.stringify({
          name: fName,
          description: fDesc,
          category: fCat,
          emoji: '🏪',
          logo: fLogo,
          color: fColor,
          ownerName: user.name,
        }),
      })
      setStore(created)
      toast.success(`¡Tu mini tienda "${created.name}" está abierta!`)
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const refreshStore = () => {
    if (!store) return
    api<MiniStore>(`/api/ministores/${store.id}`)
      .then(setStore)
      .catch(() => {})
  }

  useEffect(() => {
    if (store) setFeeDraft(String(store.courierFee))
  }, [store?.id, store?.courierFee])

  const saveFee = async () => {
    if (!store) return
    const f = Math.round(Number(feeDraft) || 0)
    if (f < 0) {
      toast.error('La tarifa no puede ser negativa')
      return
    }
    setSavingFee(true)
    try {
      const updated = await api<MiniStore>(`/api/ministores/${store.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ ownerName: user.name, courierFee: f }),
      })
      setStore((prev) => (prev ? { ...prev, courierFee: updated.courierFee } : prev))
      toast.success(`Tarifa guardada: el mensajero gana ${formatPrice(updated.courierFee)} por entrega`)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSavingFee(false)
    }
  }

  // Paga la suscripción mensual de la tienda con el saldo interno
  const paySubscription = async () => {
    if (!store) return
    setPayingSub(true)
    try {
      const res = await api<{
        store: MiniStore
        paidCoins: number
        balance: number
      }>(`/api/ministores/${store.id}/subscribe`, {
        method: 'POST',
        body: JSON.stringify({ ownerName: user.name }),
      })
      setStore(res.store)
      setWallet((w) => (w ? { ...w, coins: res.balance } : w))
      toast.success('Suscripción pagada: tu mini tienda sigue activa 30 días más')
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setPayingSub(false)
    }
  }

  const addProduct = async () => {
    if (!store) return
    const price = parseFloat(pPrice)
    const coins = pCoins.trim() ? parseInt(pCoins, 10) : NaN
    if (!pName.trim() || !price || price <= 0) {
      toast.error('El producto necesita nombre y un precio en CUP mayor que 0')
      return
    }
    if (pCoins.trim() && (!coins || coins <= 0)) {
      toast.error('El precio en monedas debe ser mayor que 0')
      return
    }
    try {
      await api(`/api/ministores/${store.id}/products`, {
        method: 'POST',
        body: JSON.stringify({
          ownerName: user.name,
          name: pName,
          description: pDesc,
          price,
          priceCoins: pCoins.trim() ? coins : undefined,
          photo: pPhoto,
          stock: pStock.trim() ? Math.max(1, Math.floor(Number(pStock))) : 20,
        }),
      })
      setPName('')
      setPPrice('')
      setPCoins('')
      setPDesc('')
      setPPhoto(null)
      setPStock('')
      const updated = await api<MiniStore>(`/api/ministores/${store.id}`)
      setStore(updated)
      toast.success(`Producto "${pName}" publicado con sus dos precios`)
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const removeProduct = async (id: string, name: string) => {
    try {
      await api(`/api/miniproducts/${id}`, {
        method: 'DELETE',
        body: JSON.stringify({ ownerName: user.name }),
      })
      const updated = await api<MiniStore>(`/api/ministores/${store!.id}`)
      setStore(updated)
      toast.success(`"${name}" eliminado`)
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const createOffer = async () => {
    if (!store) return
    const payment = parseFloat(oPayment)
    if (!oTitle.trim() || !oZone.trim() || !payment || payment <= 0) {
      toast.error('La oferta necesita título, zona y pago por entrega')
      return
    }
    try {
      await api('/api/joboffers', {
        method: 'POST',
        body: JSON.stringify({
          storeId: store.id,
          ownerName: user.name,
          title: oTitle,
          zone: oZone,
          payment,
          description: oDesc,
        }),
      })
      setOTitle('')
      setOZone('')
      setOPayment('')
      setODesc('')
      loadAll(store)
      toast.success('Oferta de trabajo publicada: ya puedes recibir postulaciones')
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const closeOffer = async (offerId: string) => {
    try {
      await api(`/api/joboffers/${offerId}`, {
        method: 'PATCH',
        body: JSON.stringify({ open: false, ownerName: user.name }),
      })
      loadAll(store!)
      toast.success('Oferta cerrada')
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const decideApplication = async (appId: string, status: 'accepted' | 'rejected') => {
    try {
      await api(`/api/applications/${appId}`, {
        method: 'PATCH',
        body: JSON.stringify({ status, ownerName: user.name }),
      })
      loadAll(store!)
      toast.success(
        status === 'accepted'
          ? 'Postulante aceptado: le llegó la notificación al mini correo'
          : 'Postulación rechazada: se avisó al postulante'
      )
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  if (loading) return <p className="text-center py-16 text-[#565959]">Cargando…</p>

  // Las mini tiendas están desactivadas por el administrador
  if (settings && !settings.miniStoresEnabled) {
    return (
      <div className="p-6 max-w-2xl mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-10 text-center">
          <X className="w-14 h-14 text-[#C7511F] mx-auto" strokeWidth={1.6} />
          <h1 className="text-[22px] font-bold text-[#0F1111] mt-4">Mini tiendas desactivadas</h1>
          <p className="text-[14px] text-[#565959] mt-2">
            El administrador de {STORE_NAME} desactivó temporalmente la función de mini tiendas.
            Vuelve a intentarlo más tarde.
          </p>
        </div>
      </div>
    )
  }

  const rate = settings?.coinRate || 100

  // ---------- SIN TIENDA: formulario para crearla ----------
  if (!store) {
    return (
      <div className="p-4 max-w-2xl mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
          <h1 className="text-[26px] font-bold text-[#0F1111]">Crea tu mini tienda</h1>
          <p className="text-[14px] text-[#565959] mt-1 mb-5">
            Abre tu propio espacio dentro de {STORE_NAME}: sube un logotipo, publica productos con
            foto y cobra en CUP o en monedas de la tienda.
          </p>

          <div className="mb-4">
            <PhotoInput
              value={fLogo}
              onChange={setFLogo}
              label="Logotipo de la tienda (opcional)"
              shape="circle"
              width={112}
              maxSize={320}
            />
          </div>

          <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Nombre de la tienda</label>
          <input
            value={fName}
            onChange={(e) => setFName(e.target.value)}
            placeholder="Ej: Dulces de Camila"
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] focus:ring-2 focus:ring-[#f5deb3] mb-4"
          />

          <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Descripción</label>
          <textarea
            value={fDesc}
            onChange={(e) => setFDesc(e.target.value)}
            placeholder="¿Qué vendes? Cuéntalo para atraer clientes"
            rows={3}
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] focus:ring-2 focus:ring-[#f5deb3] mb-4 resize-none"
          />

          <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Categoría</label>
          <select
            value={fCat}
            onChange={(e) => setFCat(e.target.value)}
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] bg-white outline-none mb-4 cursor-pointer"
          >
            {CATEGORIES.map((c) => (
              <option key={c}>{c}</option>
            ))}
            <option value="Otro">Otro / Artesanía</option>
          </select>

          <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
            Color de tu marca
          </label>
          <div className="flex flex-wrap gap-2 mb-6">
            {STORE_COLORS.map((c) => (
              <button
                key={c}
                onClick={() => setFColor(c)}
                aria-label={`Color ${c}`}
                className={`w-10 h-10 rounded-full cursor-pointer border-2 ${
                  fColor === c ? 'border-[#0F1111] ring-2 ring-[#f5deb3]' : 'border-white'
                } shadow-sm`}
                style={{ backgroundColor: c }}
              />
            ))}
          </div>

          <button
            onClick={createStore}
            className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 cursor-pointer"
          >
            Abrir mi mini tienda
          </button>
          <p className="text-[12px] text-[#565959] text-center mt-3">
            Abrirás la tienda con tu nombre de usuario: <b>{user.name}</b>
          </p>
        </div>
      </div>
    )
  }

  // ---------- CON TIENDA: panel de gestión ----------
  return (
    <div className="p-4 max-w-[1300px] mx-auto flex flex-col gap-4">
      {/* Cabecera tipo héroe compacta */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] overflow-hidden">
        <div
          className="relative h-24"
          style={{ background: `linear-gradient(115deg, ${store.color}, ${store.color}B3)` }}
        >
          <HeroFlowers />
          <span className="absolute top-2.5 right-4 text-white/40 text-[12px] font-bold tracking-wide">
            PANEL DEL DUEÑO
          </span>
        </div>
        <div className="px-6 pb-5 -mt-8 flex items-center gap-3 flex-wrap relative z-10">
          <div className="rounded-xl border-4 border-white shadow-md">
            <StoreLogo store={store} size={64} rounded="rounded-lg" />
          </div>
          <div className="flex-1 min-w-0 pt-4">
            <h1 className="text-[24px] font-bold text-[#0F1111]">Mi mini tienda: {store.name}</h1>
            <p className="text-[13px] text-[#565959]">
              {store.category} · Dueño: {store.ownerName}
            </p>
          </div>
          <span className="bg-[#007600]/10 text-[#007600] text-[13px] font-bold rounded-full px-4 py-2 flex items-center gap-1.5">
            <Check className="w-4 h-4" /> Tienda activa
          </span>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Estado de la suscripción: 5 días de prueba gratis, luego 200 CUP/mes del saldo */}
        {(() => {
          const st = storeStatus(store)
          const cost = 200 * rate
          const balance = wallet?.coins ?? 0
          if (st.status === 'trial') {
            return (
              <div className="lg:col-span-2 bg-[#f6f1fd] border border-[#5B21B6]/30 rounded-lg p-4 text-[13px] flex flex-col sm:flex-row sm:items-center gap-3">
                <div className="flex-1">
                  <p className="font-bold text-[#5B21B6]">
                    Prueba gratis: te quedan {st.daysLeft}{' '}
                    {st.daysLeft === 1 ? 'día' : 'días'}
                  </p>
                  <p className="text-[#565959] mt-0.5">
                    Después, tu mini tienda se mantiene con una suscripción de{' '}
                    <b>200 CUP ({formatCoins(cost)} monedas) al mes</b>, que se descuenta de tu
                    saldo automáticamente al pagarla. Tu saldo actual:{' '}
                    {formatCoins(balance)} monedas.
                  </p>
                </div>
                <button
                  onClick={paySubscription}
                  disabled={payingSub}
                  className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-5 py-2 cursor-pointer disabled:opacity-60 shrink-0"
                >
                  {payingSub ? 'Pagando…' : 'Pagar la suscripción ahora'}
                </button>
              </div>
            )
          }
          if (st.status === 'active') {
            return (
              <div className="lg:col-span-2 bg-[#f0faf0] border border-[#007600]/30 rounded-lg p-3 text-[13px]">
                <p className="font-bold text-[#007600]">
                  Suscripción al día: tu tienda está activa hasta{' '}
                  {new Date(store.subscribedUntil as string).toLocaleDateString('es')}
                </p>
                <p className="text-[#565959] mt-0.5">
                  La renovación cuesta 200 CUP ({formatCoins(cost)} monedas) y se descuenta de tu
                  saldo al pagarla. Saldo actual: {formatCoins(balance)} monedas.
                </p>
              </div>
            )
          }
          return (
            <div className="lg:col-span-2 bg-[#FEF3C7] border border-[#B45309]/40 rounded-lg p-4 text-[13px] flex flex-col sm:flex-row sm:items-center gap-3">
              <div className="flex-1">
                <p className="font-bold text-[#B45309]">
                  ¡Tu prueba de 5 días terminó! Tu tienda está suspendida para el público
                </p>
                <p className="text-[#B45309] mt-0.5">
                  Paga la suscripción de <b>200 CUP ({formatCoins(cost)} monedas)</b> con tu saldo
                  para volver a vender. Tu saldo: {formatCoins(balance)} monedas.
                </p>
              </div>
              <button
                onClick={paySubscription}
                disabled={payingSub}
                className="bg-[#B45309] hover:bg-[#92400e] text-white text-[13px] font-bold rounded-full px-5 py-2 cursor-pointer disabled:opacity-60 shrink-0"
              >
                {payingSub ? 'Pagando…' : 'Pagar 200 CUP con mi saldo'}
              </button>
            </div>
          )
        })()}

        {/* PUBLICAR PRODUCTO */}
        <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
          <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2 mb-1">
            <Package className="w-5 h-5 text-[#5B21B6]" /> Publicar un producto
          </h2>
          <p className="text-[13px] text-[#565959] mb-4">
            Sube una foto de lo que vendes (o elige una de las fotos guardadas en la tienda si no
            tienes) y pon el precio en CUP y en monedas de la tienda.
          </p>

          <div className="mb-4">
            <PhotoInput
              value={pPhoto}
              onChange={setPPhoto}
              label="Foto del producto (opcional)"
              width={96}
              withGallery
            />
          </div>

          <input
            value={pName}
            onChange={(e) => setPName(e.target.value)}
            placeholder="Nombre del producto"
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
          />
          <div className="flex gap-3 mb-3">
            <div className="flex-1">
              <label className="block text-[12px] font-bold text-[#0F1111] mb-1">
                Precio en dinero (CUP)
              </label>
              <input
                value={pPrice}
                onChange={(e) => setPPrice(e.target.value)}
                type="number"
                min="0.01"
                step="0.01"
                placeholder="Ej: 500"
                aria-label="Precio en dinero"
                className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
              />
            </div>
            <div className="flex-1">
              <label className="block text-[12px] font-bold text-[#5B21B6] mb-1">
                Precio en monedas
              </label>
              <input
                value={pCoins}
                onChange={(e) => setPCoins(e.target.value)}
                type="number"
                min="1"
                step="1"
                placeholder={`Ej: ${rate}`}
                aria-label="Precio en monedas"
                className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#5B21B6]"
              />
            </div>
          </div>
          <p className="text-[12px] text-[#565959] mb-3 flex items-center gap-1">
            <Coins className="w-3.5 h-3.5 text-[#5B21B6]" /> Cambio actual: 1 CUP = {rate} monedas.
            Si dejas el precio en monedas vacío se calcula solo.
          </p>
          <label className="block text-[12px] font-bold text-[#0F1111] mb-1">
            Cantidad a la venta (almacén)
          </label>
          <input
            value={pStock}
            onChange={(e) => setPStock(e.target.value)}
            type="number"
            min="1"
            step="1"
            placeholder="Ej: 10 (se descuenta solo al vender)"
            aria-label="Cantidad a la venta"
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
 />
          <textarea
            value={pDesc}
            onChange={(e) => setPDesc(e.target.value)}
            placeholder="Descripción corta (opcional)"
            rows={2}
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3 resize-none"
          />
          <button
            onClick={addProduct}
            className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full py-2 cursor-pointer"
          >
            Publicar producto
          </button>

          {/* Lista de productos publicados */}
          <h3 className="text-[15px] font-bold text-[#0F1111] mt-6 mb-2">
            Mis productos ({store.products.length})
          </h3>
          {store.products.length === 0 ? (
            <p className="text-[13px] text-[#565959]">Todavía no publicaste productos.</p>
          ) : (
            <ul className="divide-y divide-[#e3e6e6]">
              {store.products.map((p) => (
                <li key={p.id} className="py-2.5 flex items-center gap-3">
                  <div className="w-12 h-12 rounded-md overflow-hidden shrink-0 border border-[#e3e6e6]">
                    <ProductPhoto product={p} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-[14px] font-bold text-[#0F1111] truncate">{p.name}</p>
                    <p className="text-[12px] text-[#565959] flex items-center gap-1.5 flex-wrap">
                      {formatPrice(p.price)}
                      {p.oldPrice && p.oldPrice !== p.price && (
                        <span className="line-through">{formatPrice(p.oldPrice)}</span>
                      )}
                      {p.oldPrice && p.oldPrice !== p.price && (
                        <span
                          className={`font-bold ${
                            p.price < p.oldPrice ? 'text-[#007600]' : 'text-[#CC0C39]'
                          }`}
                        >
                          {p.price < p.oldPrice ? 'Bajó' : 'Subió'}{' '}
                          {Math.abs(Math.round((1 - p.price / p.oldPrice) * 100))}%
                        </span>
                      )}
                      <span className="text-[#5B21B6] font-bold flex items-center gap-0.5">
                        <Coins className="w-3 h-3" /> {formatCoins(p.priceCoins)}
                      </span>
                    </p>
                    <p
                      className={`text-[12px] font-bold mt-0.5 ${
                        p.stock <= 0 ? 'text-[#C7511F]' : 'text-[#007600]'
                      }`}
                    >
                      {p.stock <= 0 ? 'Agotado' : `Almacén: ${p.stock}`} · Vendidos: {p.sold}
                    </p>
                    <div className="mt-1">
                      <PriceEditor
                        productId={p.id}
                        ownerName={user.name}
                        current={p.price}
                        onSaved={refreshStore}
                      />
                    </div>
                  </div>
                  <StockEditor
                    productId={p.id}
                    ownerName={user.name}
                    current={p.stock}
                    onSaved={refreshStore}
                  />
                  <button
                    onClick={() => removeProduct(p.id, p.name)}
                    className="text-[#C7511F] hover:underline text-[13px] flex items-center gap-1 cursor-pointer"
                  >
                    <Trash2 className="w-3.5 h-3.5" /> Quitar
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>

        {/* TRABAJO DE DOMICILIO */}
        <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
          <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2 mb-1">
            <Briefcase className="w-5 h-5 text-[#5B21B6]" /> Contratar repartidor
          </h2>
          <p className="text-[13px] text-[#565959] mb-4">
            Publica una oferta de trabajo de domicilio. Los repartidores postulan con un formulario
            y tú decides quién trabaja para ti.
          </p>

          {/* Tarifa del mensajero por entrega (la define el dueño) */}
          <div className="bg-[#f6f1fd] border border-[#5B21B6]/30 rounded-lg p-3 mb-4">
            <p className="text-[13px] font-bold text-[#5B21B6]">
              Tarifa que gana el mensajero por entregar tus pedidos
            </p>
            <div className="flex items-center gap-2 mt-2 flex-wrap">
              <input
                value={feeDraft}
                onChange={(e) => setFeeDraft(e.target.value)}
                type="number"
                min="0"
                aria-label="Tarifa del mensajero en CUP"
                className="w-28 border border-[#888c8c] rounded px-3 py-1.5 text-[14px] outline-none focus:border-[#5B21B6]"
              />
              <span className="text-[13px] font-bold text-[#0F1111]">CUP por entrega</span>
              <button
                onClick={saveFee}
                disabled={savingFee}
                className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[12px] font-bold rounded-full px-4 py-1.5 cursor-pointer disabled:opacity-60"
              >
                {savingFee ? 'Guardando…' : 'Guardar tarifa'}
              </button>
            </div>
            <p className="text-[12px] text-[#565959] mt-1.5">
              Los pedidos turbo muestran esta tarifa en el tablero público de los mensajeros.
            </p>
          </div>

          <input
            value={oTitle}
            onChange={(e) => setOTitle(e.target.value)}
            placeholder="Título: Ej: Repartidor de fines de semana"
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
          />
          <div className="flex gap-3 mb-3">
            <input
              value={oZone}
              onChange={(e) => setOZone(e.target.value)}
              placeholder="Zona de entrega: Ej: Centro y alrededores"
              className="flex-1 border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
            />
            <input
              value={oPayment}
              onChange={(e) => setOPayment(e.target.value)}
              type="number"
              min="0.5"
              step="0.5"
              placeholder="CUP por entrega"
              aria-label="Pago por entrega en CUP"
              className="w-36 border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
            />
          </div>
          <textarea
            value={oDesc}
            onChange={(e) => setODesc(e.target.value)}
            placeholder="Detalles del trabajo (opcional)"
            rows={2}
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3 resize-none"
          />
          <button
            onClick={createOffer}
            className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full py-2 cursor-pointer"
          >
            Publicar oferta de trabajo
          </button>

          {/* Mis ofertas publicadas */}
          <h3 className="text-[15px] font-bold text-[#0F1111] mt-6 mb-2">
            Mis ofertas ({offers.length})
          </h3>
          {offers.length === 0 ? (
            <p className="text-[13px] text-[#565959]">No publicaste ofertas todavía.</p>
          ) : (
            <ul className="space-y-3">
              {offers.map((o) => (
                <li key={o.id} className="border border-[#e3e6e6] rounded-lg p-3">
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <p className="text-[14px] font-bold text-[#0F1111]">{o.title}</p>
                      <p className="text-[12px] text-[#565959]">
                        Zona: {o.zone} · {formatPrice(o.payment)} por entrega
                      </p>
                    </div>
                    {o.open && (
                      <button
                        onClick={() => closeOffer(o.id)}
                        className="text-[12px] text-[#C7511F] hover:underline cursor-pointer shrink-0"
                      >
                        Cerrar
                      </button>
                    )}
                  </div>
                  {/* Postulaciones de esta oferta */}
                  <div className="mt-2 border-t border-[#e3e6e6] pt-2">
                    <p className="text-[12px] font-bold text-[#565959] mb-1.5">
                      Postulaciones: {applications.filter((a) => a.jobId === o.id).length}
                    </p>
                    {applications
                      .filter((a) => a.jobId === o.id)
                      .map((a) => (
                        <div
                          key={a.id}
                          className="flex items-center gap-2 py-1.5 flex-wrap text-[13px]"
                        >
                          <UserCheck className="w-4 h-4 text-[#565959] shrink-0" />
                          <span className="font-bold text-[#0F1111]">{a.applicantName}</span>
                          <span className="text-[#565959]">
                            · {a.vehicle} · {a.phone}
                          </span>
                          {a.status === 'pending' && (
                            <span className="ml-auto flex gap-1.5">
                              <button
                                onClick={() => decideApplication(a.id, 'accepted')}
                                className="bg-[#007600] hover:bg-[#005e00] text-white text-[12px] font-bold rounded-full px-3 py-1 cursor-pointer"
                              >
                                Aceptar
                              </button>
                              <button
                                onClick={() => decideApplication(a.id, 'rejected')}
                                className="bg-[#f0f2f2] hover:bg-[#e3e6e6] text-[#0F1111] text-[12px] font-bold rounded-full px-3 py-1 cursor-pointer"
                              >
                                Rechazar
                              </button>
                            </span>
                          )}
                          {a.status === 'accepted' && (
                            <span className="ml-auto text-[12px] font-bold text-[#007600] flex items-center gap-1">
                              <Check className="w-3.5 h-3.5" /> Aceptado
                            </span>
                          )}
                          {a.status === 'rejected' && (
                            <span className="ml-auto text-[12px] font-bold text-[#C7511F]">
                              Rechazado
                            </span>
                          )}
                        </div>
                      ))}
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>

      {/* Equipo contratado */}
      {applications.filter((a) => a.status === 'accepted').length > 0 && (
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
          <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2 mb-3">
            <Building2 className="w-5 h-5 text-[#5B21B6]" /> Mi personal de reparto
          </h2>
          <div className="flex flex-wrap gap-3">
            {applications
              .filter((a) => a.status === 'accepted')
              .map((a) => (
                <div
                  key={a.id}
                  className="border border-[#d5d9d9] bg-[#f7fafa] rounded-lg px-4 py-2.5 text-[13px]"
                >
                  <p className="font-bold text-[#0F1111]">{a.applicantName}</p>
                  <p className="text-[#565959]">
                    {a.vehicle} · {a.email}
                  </p>
                </div>
              ))}
          </div>
        </div>
      )}
    </div>
  )
}
