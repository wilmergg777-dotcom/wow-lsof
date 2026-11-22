'use client'
// ============================================================
// PANEL DEL ADMINISTRADOR DE VIOLETERO
// Pestañas:
// - General:    interruptor de mini tiendas + resumen
// - Ofertas:    publicar ofertas del dueño de la web con
//               foto (propia o de la galería de la tienda),
//               nombre y precio en las dos monedas
// - Recargas:   solicitudes de recarga (revisar, aprobar,
//               rechazar) — el sistema de saldo interno
// - Cobros:     cuentas/tarjetas donde llegan las
//               transferencias + tasa de cambio
// - Seguridad:  bot de Telegram (plan B de los códigos SMS),
//               registro de eventos de seguridad, bandeja de
//               salida de mensajes y cuentas bloqueadas
// ============================================================
import { useCallback, useEffect, useState } from 'react'
import {
  Banknote,
  Bot,
  Check,
  Coins,
  CreditCard,
  Mail,
  Megaphone,
  MessageSquareText,
  Package,
  Plus,
  ScrollText,
  ShieldAlert,
  ShieldCheck,
  ShoppingCart,
  Store,
  Trash2,
  X,
} from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import {
  api,
  TOPUP_STATUS,
  type MiniStore,
  type Offer,
  type Order,
  type PaymentMethod,
  type Settings,
  type TopUpRequest,
} from '@/lib/api'
import { formatCoins, formatPrice, CATEGORIES } from '@/lib/products'
import { PhotoInput } from './PhotoInput'

type Tab = 'general' | 'inventario' | 'ofertas' | 'recargas' | 'cobros' | 'seguridad'

export function AdminView() {
  const user = useStore((s) => s.user)
  const openView = useStore((s) => s.openView)
  const [tab, setTab] = useState<Tab>('general')
  const [settings, setSettings] = useState<Settings | null>(null)
  const [stores, setStores] = useState<MiniStore[]>([])
  const [orders, setOrders] = useState<Order[]>([])
  const [offers, setOffers] = useState<Offer[]>([])
  const [saving, setSaving] = useState(false)
  const [loading, setLoading] = useState(true)
  // Tarifa del mensajero para las ofertas de la web
  const [feeDraft, setFeeDraft] = useState('200')
  const [savingFee, setSavingFee] = useState(false)
  // Parche de seguridad: el panel solo se muestra si el SERVIDOR
  // confirma que esta sesión es la del dueño (súper admin).
  const [verified, setVerified] = useState<'checking' | 'ok' | 'no'>('checking')

  useEffect(() => {
    let live = true
    fetch('/api/auth/me')
      .then((r) => (r.ok ? r.json() : { user: null }))
      .then((d: { user?: { role: string } | null }) => {
        if (live) setVerified(d.user?.role === 'administrador' ? 'ok' : 'no')
      })
      .catch(() => {
        if (live) setVerified('no')
      })
    return () => {
      live = false
    }
  }, [])

  useEffect(() => {
    if (settings) setFeeDraft(String(settings.courierFee ?? 200))
  }, [settings?.courierFee])

  const saveFee = async () => {
    const f = Math.round(Number(feeDraft) || 0)
    if (f < 0) {
      toast.error('La tarifa no puede ser negativa')
      return
    }
    setSavingFee(true)
    try {
      const updated = await api<Settings>('/api/settings', {
        method: 'PATCH',
        body: JSON.stringify({ courierFee: f }),
      })
      setSettings(updated)
      toast.success(`Tarifa guardada: el mensajero gana ${formatPrice(updated.courierFee)} por entregar ofertas de la web`)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSavingFee(false)
    }
  }

  // Efectivo de pedidos de la web pendientes de liquidación
  const [settlingId, setSettlingId] = useState<string | null>(null)
  const webPendingCash = orders.filter(
    (o) =>
      o.status === 'delivered' &&
      o.paymentMethod === 'cash' &&
      !o.settled &&
      !o.storeIds.split(',').filter(Boolean).length
  )

  const settleWebOrder = async (o: Order) => {
    setSettlingId(o.id)
    try {
      await api(`/api/orders/${o.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ action: 'settle', ownerName: user.name }),
      })
      setOrders((prev) => prev.map((x) => (x.id === o.id ? { ...x, settled: true } : x)))
      toast.success(`Liquidación del pedido ${o.code} confirmada`)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSettlingId(null)
    }
  }

  const loadMain = useCallback(() => {
    Promise.all([
      api<Settings>('/api/settings'),
      api<MiniStore[]>('/api/ministores'),
      api<Order[]>('/api/orders'),
      api<Offer[]>('/api/offers?all=1'),
    ])
      .then(([st, s, o, of]) => {
        setSettings(st)
        setStores(s)
        setOrders(o)
        setOffers(of)
      })
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    loadMain()
  }, [loadMain])

  const toggleMiniStores = async (enabled: boolean) => {
    setSaving(true)
    try {
      const updated = await api<Settings>('/api/settings', {
        method: 'PATCH',
        body: JSON.stringify({ miniStoresEnabled: enabled }),
      })
      setSettings(updated)
      toast.success(
        enabled
          ? 'Mini tiendas activadas: los usuarios ya pueden crearlas'
          : 'Mini tiendas desactivadas: nadie puede crear ni vender en mini tiendas'
      )
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  // Solo la cuenta del administrador puede entrar al panel —
  // y solo si el servidor confirma el rol (no basta el navegador).
  if (verified !== 'ok' || user.role !== 'administrador') {
    if (verified === 'checking') {
      return <p className="text-center py-16 text-[#565959]">Comprobando tu cuenta…</p>
    }
    return (
      <div className="p-6 max-w-2xl mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-10 text-center">
          <ShieldCheck className="w-14 h-14 text-[#5B21B6] mx-auto" strokeWidth={1.4} />
          <h1 className="text-[22px] font-bold text-[#0F1111] mt-4">Zona del administrador</h1>
          <p className="text-[14px] text-[#565959] mt-2">
            Esta área es solo para la cuenta del administrador de {STORE_NAME}. Inicia sesión con
            esa cuenta para gestionar la web.
          </p>
          <button
            onClick={() => openView('login')}
            className="mt-5 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-8 py-2 cursor-pointer"
          >
            Iniciar sesión
          </button>
        </div>
      </div>
    )
  }

  if (loading) return <p className="text-center py-16 text-[#565959]">Cargando panel…</p>

  const products = stores.reduce((acc, s) => acc + s.products.length, 0)

  return (
    <div className="p-4 max-w-[1000px] mx-auto flex flex-col gap-4">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h1 className="text-[28px] font-bold text-[#0F1111] flex items-center gap-2">
          <ShieldCheck className="w-7 h-7 text-[#5B21B6]" /> Panel del administrador
        </h1>
        <p className="text-[14px] text-[#565959] mt-1">
          Controla la configuración de {STORE_NAME} para todos los usuarios.
        </p>
        {/* Pestañas */}
        <div className="flex gap-2 mt-4 flex-wrap">
          {(
            [
              ['general', 'General'],
              ['inventario', 'Almacén e inventario'],
              ['ofertas', 'Ofertas de la web'],
              ['recargas', 'Recargas de saldo'],
              ['cobros', 'Cobros y tasa de cambio'],
              ['seguridad', 'Seguridad del sistema'],
            ] as [Tab, string][]
          ).map(([id, label]) => (
            <button
              key={id}
              onClick={() => setTab(id)}
              className={`rounded-full px-5 py-2 text-[14px] font-bold cursor-pointer border-2 ${
                tab === id
                  ? 'bg-[#5B21B6] border-[#5B21B6] text-white'
                  : 'bg-white border-[#d5d9d9] text-[#0F1111] hover:border-[#5B21B6]'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {tab === 'general' && (
        <>
          {/* Interruptor de mini tiendas */}
          <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
            <h2 className="text-[18px] font-bold text-[#0F1111]">Permitir mini tiendas</h2>
            <p className="text-[13px] text-[#565959] mt-1 mb-4">
              Si lo desactivas, los usuarios no podrán crear mini tiendas ni vender productos. Las
              tiendas existentes quedan ocultas para el público.
            </p>
            <div className="flex items-center gap-4 flex-wrap">
              <button
                onClick={() => toggleMiniStores(true)}
                disabled={saving}
                className={`rounded-full px-6 py-2.5 text-[14px] font-bold cursor-pointer border-2 transition-colors ${
                  settings?.miniStoresEnabled
                    ? 'bg-[#007600] border-[#007600] text-white'
                    : 'bg-white border-[#d5d9d9] text-[#0F1111] hover:border-[#007600]'
                }`}
              >
                Sí, permitir
              </button>
              <button
                onClick={() => toggleMiniStores(false)}
                disabled={saving}
                className={`rounded-full px-6 py-2.5 text-[14px] font-bold cursor-pointer border-2 transition-colors ${
                  settings && !settings.miniStoresEnabled
                    ? 'bg-[#C7511F] border-[#C7511F] text-white'
                    : 'bg-white border-[#d5d9d9] text-[#0F1111] hover:border-[#C7511F]'
                }`}
              >
                No, desactivar
              </button>
              <span
                className={`text-[13px] font-bold rounded-full px-4 py-1.5 ${
                  settings?.miniStoresEnabled
                    ? 'bg-[#007600]/10 text-[#007600]'
                    : 'bg-[#C7511F]/10 text-[#C7511F]'
                }`}
              >
                Estado: {settings?.miniStoresEnabled ? 'Activadas' : 'Desactivadas'}
              </span>
            </div>
          </div>

          {/* Tarifa del mensajero para las ofertas de la web */}
          <div className="bg-[#f6f1fd] border border-[#5B21B6]/30 rounded-lg p-4 mt-4">
            <h2 className="text-[16px] font-bold text-[#0F1111]">
              Tarifa del mensajero (ofertas de la web)
            </h2>
            <p className="text-[13px] text-[#565959] mt-1 mb-3">
              Cuánto gana el mensajero por entregar un pedido de las ofertas del dueño de la web.
              Cada mini tienda define la suya en su panel.
            </p>
            <div className="flex items-center gap-2 flex-wrap">
              <input
                value={feeDraft}
                onChange={(e) => setFeeDraft(e.target.value)}
                type="number"
                min="0"
                aria-label="Tarifa del mensajero para la web en CUP"
                className="w-28 border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
              />
              <span className="text-[13px] font-bold text-[#0F1111]">CUP por entrega</span>
              <button
                onClick={saveFee}
                disabled={savingFee}
                className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-5 py-2 cursor-pointer disabled:opacity-60"
              >
                {savingFee ? 'Guardando…' : 'Guardar tarifa'}
              </button>
            </div>
          </div>

          {/* Efectivo de la web pendiente de liquidación */}
          {webPendingCash.length > 0 && (
            <div className="bg-[#FEF3C7] border border-[#B45309]/40 rounded-lg p-4 mt-4">
              <h2 className="text-[16px] font-bold text-[#B45309]">
                Cobros en efectivo pendientes de liquidación ({webPendingCash.length})
              </h2>
              <p className="text-[13px] text-[#B45309] mt-1 mb-3">
                Pedidos de las ofertas de la web cobrados en efectivo por el mensajero. El
                mensajero te debe entregar el total menos su tarifa.
              </p>
              <ul className="flex flex-col gap-2">
                {webPendingCash.map((o) => (
                  <li
                    key={o.id}
                    className="bg-white border border-[#B45309]/30 rounded-lg p-3 text-[13px] flex flex-col sm:flex-row sm:items-center gap-2"
                  >
                    <span className="font-bold text-[#0F1111]">Pedido {o.code}</span>
                    <span className="text-[#565959] flex-1">
                      Cobrado: {formatPrice(o.total)} · Mensajero ({o.workerName ?? '—'}):{' '}
                      {formatPrice(o.courierFee)} · Te deben:{' '}
                      <b className="text-[#B45309]">
                        {formatPrice(Math.max(0, o.total - o.courierFee))}
                      </b>
                    </span>
                    <button
                      onClick={() => settleWebOrder(o)}
                      disabled={settlingId === o.id}
                      className="bg-[#007600] hover:bg-[#005e00] text-white text-[12px] font-bold rounded-full px-4 py-1.5 cursor-pointer disabled:opacity-60 shrink-0"
                    >
                      {settlingId === o.id ? 'Confirmando…' : 'Liquidar'}
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Resumen de actividad */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
              <Megaphone className="w-6 h-6 text-[#5B21B6] mx-auto" />
              <p className="text-[28px] font-bold text-[#0F1111] mt-2">
                {offers.filter((o) => o.active).length}
              </p>
              <p className="text-[13px] text-[#565959]">Ofertas activas de la web</p>
            </div>
            <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
              <Store className="w-6 h-6 text-[#5B21B6] mx-auto" />
              <p className="text-[28px] font-bold text-[#0F1111] mt-2">{stores.length}</p>
              <p className="text-[13px] text-[#565959]">Mini tiendas creadas</p>
            </div>
            <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
              <Package className="w-6 h-6 text-[#5B21B6] mx-auto" />
              <p className="text-[28px] font-bold text-[#0F1111] mt-2">{products}</p>
              <p className="text-[13px] text-[#565959]">Productos en mini tiendas</p>
            </div>
            <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
              <ShoppingCart className="w-6 h-6 text-[#5B21B6] mx-auto" />
              <p className="text-[28px] font-bold text-[#0F1111] mt-2">{orders.length}</p>
              <p className="text-[13px] text-[#565959]">Pedidos totales</p>
            </div>
          </div>
        </>
      )}

      {tab === 'inventario' && <InventorySection onChanged={loadMain} />}

      {tab === 'ofertas' && <OffersSection onChanged={loadMain} />}

      {tab === 'recargas' && <TopUpsSection />}

      {tab === 'cobros' && <PaymentMethodsSection rate={settings?.coinRate || 100} onRateChange={(r) => setSettings((s) => (s ? { ...s, coinRate: r } : s))} />}
      {tab === 'seguridad' && <SecuritySection />}
    </div>
  )
}

// ============================================================
// PESTAÑA ALMACÉN: inventario de las ofertas de la web.
// La cantidad se descuenta sola al vender; en 0 se muestra
// AGOTADO y no se puede comprar. Aquí se gestiona la cantidad,
// los precios y la visibilidad de cada artículo.
// ============================================================
function InventorySection({ onChanged }: { onChanged: () => void }) {
  const [offers, setOffers] = useState<Offer[]>([])
  const [loading, setLoading] = useState(true)

  const load = useCallback(() => {
    api<Offer[]>('/api/offers?all=1')
      .then(setOffers)
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    load()
  }, [load])

  if (loading) return <p className="text-center py-10 text-[#565959]">Abriendo el almacén…</p>

  const totalUnits = offers.reduce((a, o) => a + o.stock, 0)
  const totalSold = offers.reduce((a, o) => a + o.sold, 0)
  const soldOut = offers.filter((o) => o.stock <= 0 && o.active).length

  return (
    <>
      {/* Resumen del almacén */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
          <p className="text-[28px] font-bold text-[#0F1111]">{offers.length}</p>
          <p className="text-[13px] text-[#565959]">Artículos publicados</p>
        </div>
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
          <p className="text-[28px] font-bold text-[#007600]">{totalUnits}</p>
          <p className="text-[13px] text-[#565959]">Unidades en el almacén</p>
        </div>
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
          <p className="text-[28px] font-bold text-[#C7511F]">{soldOut}</p>
          <p className="text-[13px] text-[#565959]">Artículos agotados</p>
        </div>
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-center">
          <p className="text-[28px] font-bold text-[#5B21B6]">{totalSold}</p>
          <p className="text-[13px] text-[#565959]">Unidades vendidas</p>
        </div>
      </div>

      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Package className="w-5 h-5 text-[#5B21B6]" /> Inventario de las ofertas de la web
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Cada compra descuenta las unidades solas. Con 0 unidades el artículo se muestra AGOTADO y
          nadie puede comprarlo. Aquí puedes cambiar la cantidad, el precio y ocultarlo cuando
          quieras.
        </p>
        {offers.length === 0 ? (
          <p className="text-[13px] text-[#565959]">
            Todavía no hay artículos. Publica la primera oferta en la pestaña Ofertas de la web.
          </p>
        ) : (
          <ul className="flex flex-col divide-y divide-[#e3e6e6]">
            {offers.map((o) => (
              <InventoryRow key={o.id} offer={o} onSaved={load} onChanged={onChanged} />
            ))}
          </ul>
        )}
      </section>
    </>
  )
}

// Fila del inventario: cantidad, precio y visibilidad de un artículo
function InventoryRow({
  offer,
  onSaved,
  onChanged,
}: {
  offer: Offer
  onSaved: () => void
  onChanged: () => void
}) {
  const [stock, setStock] = useState(String(offer.stock))
  const [price, setPrice] = useState(String(offer.price))
  const [saving, setSaving] = useState(false)
  useEffect(() => {
    setStock(String(offer.stock))
    setPrice(String(offer.price))
  }, [offer.stock, offer.price])

  const patch = async (data: Record<string, unknown>, okMsg: string) => {
    setSaving(true)
    try {
      await api(`/api/offers/${offer.id}`, { method: 'PATCH', body: JSON.stringify(data) })
      toast.success(okMsg)
      onSaved()
      onChanged()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const estado = !offer.active
    ? { label: 'Oculta', color: '#565959', bg: '#f0f2f2' }
    : offer.stock <= 0
      ? { label: 'Agotada', color: '#C7511F', bg: '#FDE8E0' }
      : offer.stock <= 5
        ? { label: 'Pocas unidades', color: '#B45309', bg: '#FEF3C7' }
        : { label: 'A la venta', color: '#007600', bg: '#E7F7E7' }

  return (
    <li className="py-4 flex flex-col sm:flex-row sm:items-center gap-4">
      <div className="w-14 h-14 rounded-md overflow-hidden bg-[#f7fafa] border border-[#e3e6e6] shrink-0 flex items-center justify-center">
        {offer.photo ? (
          <img src={offer.photo} alt={offer.title} className="w-full h-full object-cover" />
        ) : (
          <Package className="w-6 h-6 text-[#c8cdcd]" strokeWidth={1.3} />
        )}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-[15px] font-bold text-[#0F1111]">{offer.title}</p>
        <p className="text-[12px] text-[#565959]">
          {offer.category} ·{' '}
          {offer.priceCoins > 0
            ? `${formatCoins(offer.priceCoins)} monedas`
            : 'monedas automáticas'}{' '}
          · Vendidos: {offer.sold}
        </p>
        <span
          className="inline-block rounded-full px-3 py-0.5 font-bold text-[11px] mt-1"
          style={{ color: estado.color, backgroundColor: estado.bg }}
        >
          {estado.label}
        </span>
      </div>
      <div className="flex items-center gap-2 flex-wrap">
        <label className="text-[12px] font-bold text-[#0F1111]">
          Cantidad:
          <input
            value={stock}
            onChange={(e) => setStock(e.target.value)}
            type="number"
            min="0"
            aria-label={`Cantidad en el almacén de ${offer.title}`}
            className="w-16 border border-[#888c8c] rounded px-2 py-1 text-[13px] ml-1 outline-none focus:border-[#e77600]"
          />
        </label>
        <label className="text-[12px] font-bold text-[#0F1111]">
          Precio CUP:
          <input
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            type="number"
            min="1"
            aria-label={`Precio en CUP de ${offer.title}`}
            className="w-24 border border-[#888c8c] rounded px-2 py-1 text-[13px] ml-1 outline-none focus:border-[#e77600]"
          />
        </label>
        <button
          onClick={() => {
            const n = parseInt(stock, 10)
            const p = parseFloat(price)
            if (isNaN(n) || n < 0) {
              toast.error('La cantidad debe ser 0 o más')
              return
            }
            if (!p || p <= 0) {
              toast.error('El precio debe ser mayor que 0')
              return
            }
            patch({ stock: n, price: p }, 'Inventario actualizado')
          }}
          disabled={saving}
          className="text-[12px] font-bold bg-[#FFD814] hover:bg-[#F7CA00] rounded-full px-4 py-1.5 cursor-pointer disabled:opacity-60"
        >
          Guardar
        </button>
        <button
          onClick={() =>
            patch(
              { active: !offer.active },
              offer.active ? 'Oferta oculta: deja de verse en la tienda' : 'Oferta visible otra vez'
            )
          }
          disabled={saving}
          className="text-[12px] font-bold border border-[#d5d9d9] rounded-full px-4 py-1.5 cursor-pointer disabled:opacity-60 hover:bg-[#f7fafa]"
        >
          {offer.active ? 'Ocultar' : 'Mostrar'}
        </button>
      </div>
    </li>
  )
}

// ============================================================
// PESTAÑA OFERTAS: el dueño de la web publica sus ofertas.
// Cada oferta lleva foto (subida o elegida de la galería de
// la tienda), nombre, categoría y precio en las dos monedas.
// ============================================================
function OffersSection({ onChanged }: { onChanged: () => void }) {
  const [offers, setOffers] = useState<Offer[]>([])
  const [rate, setRate] = useState(100)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  // Formulario de publicación
  const [title, setTitle] = useState('')
  const [desc, setDesc] = useState('')
  const [cat, setCat] = useState(CATEGORIES[0])
  const [price, setPrice] = useState('')
  const [coins, setCoins] = useState('')
  const [oldPrice, setOldPrice] = useState('')
  const [stock, setStock] = useState('')
  const [photo, setPhoto] = useState<string | null>(null)

  const load = useCallback(() => {
    Promise.all([api<Offer[]>('/api/offers?all=1'), api<Settings>('/api/settings')])
      .then(([list, st]) => {
        setOffers(list)
        setRate(st.coinRate || 100)
      })
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    load()
  }, [load])

  const publish = async () => {
    const priceNum = parseFloat(price)
    if (!title.trim() || !priceNum || priceNum <= 0) {
      toast.error('La oferta necesita un nombre y un precio en CUP mayor que 0')
      return
    }
    const oldNum = oldPrice.trim() ? parseFloat(oldPrice) : null
    if (oldNum !== null && (!oldNum || oldNum <= priceNum)) {
      toast.error('El precio anterior debe ser mayor que el precio de la oferta')
      return
    }
    setSaving(true)
    try {
      await api('/api/offers', {
        method: 'POST',
        body: JSON.stringify({
          title,
          description: desc,
          category: cat,
          price: priceNum,
          priceCoins: coins.trim() ? parseInt(coins, 10) : 0,
          oldPrice: oldNum,
          photo,
          stock: stock.trim() ? parseInt(stock, 10) : undefined,
        }),
      })
      setTitle('')
      setDesc('')
      setPrice('')
      setCoins('')
      setOldPrice('')
      setStock('')
      setPhoto(null)
      load()
      onChanged()
      toast.success('Oferta publicada: ya aparece en el inicio de la tienda')
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const toggleActive = async (o: Offer) => {
    try {
      await api(`/api/offers/${o.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ active: !o.active }),
      })
      load()
      onChanged()
      toast.success(o.active ? 'Oferta ocultada del catálogo' : 'Oferta reactivada')
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const removeOffer = async (o: Offer) => {
    try {
      await api(`/api/offers/${o.id}`, { method: 'DELETE' })
      load()
      onChanged()
      toast.success(`"${o.title}" eliminada`)
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  if (loading) return <p className="text-center py-10 text-[#565959]">Cargando ofertas…</p>

  return (
    <>
      {/* Publicar una oferta */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2 mb-1">
          <Megaphone className="w-5 h-5 text-[#5B21B6]" /> Publicar una oferta (dueño de la web)
        </h2>
        <p className="text-[13px] text-[#565959] mb-4">
          Sube una foto de lo que vendes o elige una de las fotos guardadas en la tienda. Pon el
          precio en dinero y en monedas: la oferta sale al inicio junto con las de las mini
          tiendas.
        </p>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <div className="mb-4">
              <PhotoInput
                value={photo}
                onChange={setPhoto}
                label="Foto de la oferta (opcional)"
                width={96}
                withGallery
              />
            </div>

            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Nombre</label>
            <input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Ej: Mochila escolar reforzada"
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
            />

            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Departamento</label>
            <select
              value={cat}
              onChange={(e) => setCat(e.target.value)}
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] bg-white outline-none mb-3 cursor-pointer"
            >
              {CATEGORIES.map((c) => (
                <option key={c}>{c}</option>
              ))}
            </select>

            <div className="flex gap-3 mb-3">
              <div className="flex-1">
                <label className="block text-[12px] font-bold text-[#0F1111] mb-1">
                  Precio en dinero (CUP)
                </label>
                <input
                  value={price}
                  onChange={(e) => setPrice(e.target.value)}
                  type="number"
                  min="1"
                  step="1"
                  placeholder="Ej: 500"
                  aria-label="Precio en dinero (CUP)"
                  className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
                />
              </div>
              <div className="flex-1">
                <label className="block text-[12px] font-bold text-[#5B21B6] mb-1">
                  Precio en monedas
                </label>
                <input
                  value={coins}
                  onChange={(e) => setCoins(e.target.value)}
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
          </div>

          <div>
            <div className="flex gap-3 mb-3">
              <div className="flex-1">
                <label className="block text-[12px] font-bold text-[#0F1111] mb-1">
                  Precio anterior (opcional, para el descuento)
                </label>
                <input
                  value={oldPrice}
                  onChange={(e) => setOldPrice(e.target.value)}
                  type="number"
                  min="1"
                  step="1"
                  placeholder="Ej: 750"
                  aria-label="Precio anterior"
                  className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
                />
              </div>
              <div className="w-28">
                <label className="block text-[12px] font-bold text-[#0F1111] mb-1">Stock</label>
                <input
                  value={stock}
                  onChange={(e) => setStock(e.target.value)}
                  type="number"
                  min="1"
                  step="1"
                  placeholder="20"
                  aria-label="Stock"
                  className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
                />
              </div>
            </div>

            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
              Descripción (opcional)
            </label>
            <textarea
              value={desc}
              onChange={(e) => setDesc(e.target.value)}
              placeholder="Cuenta qué vende y por qué es buena compra"
              rows={4}
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-4 resize-none"
            />

            <button
              onClick={publish}
              disabled={saving}
              className="w-full bg-[#FFD814] hover:bg-[#F7CA00] disabled:opacity-60 text-[#0F1111] text-[14px] font-bold rounded-full py-2.5 cursor-pointer"
            >
              {saving ? 'Publicando…' : 'Publicar oferta'}
            </button>
          </div>
        </div>
      </div>

      {/* Lista de ofertas publicadas */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] mb-3">
          Ofertas de la web ({offers.length})
        </h2>
        {offers.length === 0 ? (
          <p className="text-[13px] text-[#565959]">
            Todavía no publicaste ninguna oferta. La web empieza vacía: la primera que publiques
            aparecerá en el inicio.
          </p>
        ) : (
          <ul className="divide-y divide-[#e3e6e6]">
            {offers.map((o) => (
              <li key={o.id} className="py-3 flex items-center gap-3">
                <div className="w-12 h-12 rounded-md overflow-hidden shrink-0 border border-[#e3e6e6] bg-[#f7fafa]">
                  {o.photo ? (
                    <img src={o.photo} alt={o.title} className="w-full h-full object-cover" />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <Package className="w-6 h-6 text-[#c8cdcd]" strokeWidth={1.3} />
                    </div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[14px] font-bold text-[#0F1111] truncate">{o.title}</p>
                  <p className="text-[12px] text-[#565959] flex items-center gap-2 flex-wrap">
                    <span>{o.category}</span>
                    <span className="font-bold text-[#0F1111]">{formatPrice(o.price)}</span>
                    <span className="text-[#5B21B6] font-bold flex items-center gap-0.5">
                      <Coins className="w-3 h-3" />
                      {formatCoins(o.priceCoins > 0 ? o.priceCoins : o.price * rate)} monedas
                    </span>
                    {!o.active && <span className="text-[#C7511F] font-bold">Oculta</span>}
                  </p>
                </div>
                <button
                  onClick={() => toggleActive(o)}
                  className={`rounded-full px-3 py-1 text-[12px] font-bold cursor-pointer border shrink-0 ${
                    o.active
                      ? 'bg-[#007600]/10 text-[#007600] border-[#007600]/40'
                      : 'bg-[#f0f2f2] text-[#565959] border-[#d5d9d9]'
                  }`}
                >
                  {o.active ? 'Visible' : 'Oculta'}
                </button>
                <button
                  onClick={() => removeOffer(o)}
                  aria-label={`Eliminar ${o.title}`}
                  className="text-[#C7511F] hover:underline text-[12px] flex items-center gap-1 cursor-pointer shrink-0"
                >
                  <Trash2 className="w-3.5 h-3.5" /> Quitar
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </>
  )
}

// ============================================================
// PESTAÑA RECARGAS: revisar solicitudes de los usuarios
// ============================================================
function TopUpsSection() {
  const [requests, setRequests] = useState<TopUpRequest[]>([])
  const [notes, setNotes] = useState<Record<string, string>>({})
  const [loading, setLoading] = useState(true)

  const load = useCallback(() => {
    api<TopUpRequest[]>('/api/topups')
      .then(setRequests)
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    load()
    const t = setInterval(load, 10000) // se refresca solo
    return () => clearInterval(t)
  }, [load])

  const decide = async (id: string, status: 'approved' | 'rejected') => {
    try {
      await api(`/api/topups/${id}`, {
        method: 'PATCH',
        body: JSON.stringify({ status, adminNote: notes[id] || undefined }),
      })
      load()
      toast.success(
        status === 'approved'
          ? 'Recarga aprobada: monedas acreditadas y aviso enviado al usuario'
          : 'Recarga rechazada: se avisó al usuario por el mini correo'
      )
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  if (loading) return <p className="text-center py-10 text-[#565959]">Cargando recargas…</p>

  const pending = requests.filter((r) => r.status === 'pending')
  const reviewed = requests.filter((r) => r.status !== 'pending')

  return (
    <>
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Coins className="w-5 h-5 text-[#5B21B6]" /> Solicitudes pendientes ({pending.length})
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Cada usuario transfirió dinero real a tu cuenta y puso el ID de la transferencia.
          Verifica en tu app del banco: si el ID existe y el monto coincide, aprueba la recarga y
          las monedas se acreditan solas.
        </p>
        {pending.length === 0 ? (
          <div className="text-center py-8">
            <Check className="w-12 h-12 text-[#007600]/40 mx-auto" strokeWidth={1.5} />
            <p className="text-[14px] text-[#565959] mt-2">
              No hay solicitudes pendientes. Te llega una notificación al mini correo cuando alguien
              envía una.
            </p>
          </div>
        ) : (
          <ul className="flex flex-col gap-3">
            {pending.map((r) => (
              <li key={r.id} className="border-2 border-[#B45309]/40 bg-[#FFFBEB] rounded-lg p-4">
                <div className="flex items-start justify-between gap-3 flex-wrap">
                  <div className="text-[14px]">
                    <p className="font-bold text-[#0F1111]">
                      {r.userName} envió {formatPrice(r.amountCash)}
                    </p>
                    <p className="text-[13px] text-[#565959] mt-0.5">
                      Cuenta usada: <b>{r.methodName}</b>
                    </p>
                    <p className="text-[13px] mt-1">
                      ID de transferencia:{' '}
                      <span className="font-mono font-bold text-[#0F1111] select-all">
                        {r.transferId}
                      </span>
                    </p>
                    <p className="text-[13px] text-[#5B21B6] font-bold mt-1 flex items-center gap-1">
                      <Coins className="w-4 h-4" /> A acreditar: {formatCoins(r.coins)} monedas
                    </p>
                    <p className="text-[11px] text-[#8a8a8a] mt-1">
                      {new Date(r.createdAt).toLocaleString('es')}
                    </p>
                  </div>
                  <span className="rounded-full px-3 py-1 font-bold text-[12px] bg-[#FEF3C7] text-[#B45309] self-start">
                    Pendiente
                  </span>
                </div>
                <input
                  value={notes[r.id] || ''}
                  onChange={(e) => setNotes((n) => ({ ...n, [r.id]: e.target.value }))}
                  placeholder="Nota para el usuario (opcional, se envía si rechazas)"
                  className="w-full border border-[#888c8c] rounded px-3 py-1.5 text-[13px] outline-none focus:border-[#e77600] mt-3"
                />
                <div className="flex gap-2 mt-3">
                  <button
                    onClick={() => decide(r.id, 'approved')}
                    className="bg-[#007600] hover:bg-[#005e00] text-white text-[13px] font-bold rounded-full px-5 py-2 flex items-center gap-1.5 cursor-pointer"
                  >
                    <Check className="w-4 h-4" /> Transferencia verificada, acreditar
                  </button>
                  <button
                    onClick={() => decide(r.id, 'rejected')}
                    className="bg-white hover:bg-[#f0f2f2] border-2 border-[#C7511F] text-[#C7511F] text-[13px] font-bold rounded-full px-5 py-2 flex items-center gap-1.5 cursor-pointer"
                  >
                    <X className="w-4 h-4" /> Rechazar
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Historial de recargas revisadas */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] mb-3">
          Historial ({reviewed.length})
        </h2>
        {reviewed.length === 0 ? (
          <p className="text-[13px] text-[#565959]">Todavía no revisaste ninguna recarga.</p>
        ) : (
          <ul className="divide-y divide-[#e3e6e6]">
            {reviewed.map((r) => {
              const st = TOPUP_STATUS[r.status]
              return (
                <li key={r.id} className="py-3 flex items-center gap-3 flex-wrap text-[13px]">
                  <span className="font-bold text-[#0F1111]">{r.userName}</span>
                  <span className="text-[#565959]">
                    {formatPrice(r.amountCash)} → {formatCoins(r.coins)} monedas
                  </span>
                  <span className="font-mono text-[#565959]">{r.transferId}</span>
                  <span
                    className="ml-auto rounded-full px-3 py-1 font-bold text-[12px]"
                    style={{ color: st.color, backgroundColor: st.bg }}
                  >
                    {st.label}
                  </span>
                </li>
              )
            })}
          </ul>
        )}
      </div>
    </>
  )
}

// ============================================================
// PESTAÑA COBROS: cuentas donde llega el dinero + tasa
// ============================================================
function PaymentMethodsSection({
  rate,
  onRateChange,
}: {
  rate: number
  onRateChange: (r: number) => void
}) {
  const [methods, setMethods] = useState<PaymentMethod[]>([])
  const [loading, setLoading] = useState(true)
  const [savingRate, setSavingRate] = useState(false)
  const [rateDraft, setRateDraft] = useState(String(rate))
  // Formulario de nuevo método
  const [label, setLabel] = useState('')
  const [details, setDetails] = useState('')
  const [holder, setHolder] = useState('')
  const [phone, setPhone] = useState('')
  const [instructions, setInstructions] = useState('')
  // Paso de confirmación: guardar los datos de cobro SIEMPRE
  // exige revisarlos y confirmar (evita equivocaciones con el
  // número de tarjeta que luego usan los compradores)
  const [confirming, setConfirming] = useState(false)
  const [saving, setSaving] = useState(false)

  const load = useCallback(() => {
    api<PaymentMethod[]>('/api/payment-methods?all=1')
      .then(setMethods)
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    load()
  }, [load])

  useEffect(() => {
    setRateDraft(String(rate))
  }, [rate])

  const addMethod = () => {
    if (!label.trim() || !details.trim() || !holder.trim() || !phone.trim()) {
      toast.error('Completa el nombre de la cuenta, el número, el titular y el teléfono')
      return
    }
    // No guarda todavía: primero muestra el resumen para confirmar
    setConfirming(true)
  }

  const confirmSave = async () => {
    setSaving(true)
    try {
      await api('/api/payment-methods', {
        method: 'POST',
        body: JSON.stringify({ label, details, holder, phone, instructions }),
      })
      setLabel('')
      setDetails('')
      setHolder('')
      setPhone('')
      setInstructions('')
      setConfirming(false)
      load()
      toast.success('Datos de cobro guardados y confirmados: ya se usan en las recargas y pagos')
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const toggleActive = async (m: PaymentMethod) => {
    try {
      await api(`/api/payment-methods/${m.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ active: !m.active }),
      })
      load()
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const removeMethod = async (m: PaymentMethod) => {
    try {
      await api(`/api/payment-methods/${m.id}`, { method: 'DELETE' })
      load()
      toast.success('Cuenta eliminada')
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const saveRate = async () => {
    const r = parseInt(rateDraft, 10)
    if (!r || r < 1) {
      toast.error('La tasa debe ser 1 o más')
      return
    }
    setSavingRate(true)
    try {
      await api('/api/settings', {
        method: 'PATCH',
        body: JSON.stringify({ coinRate: r }),
      })
      onRateChange(r)
      toast.success(`Tasa actualizada: 1 CUP = ${r} monedas`)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSavingRate(false)
    }
  }

  if (loading) return <p className="text-center py-10 text-[#565959]">Cargando cuentas…</p>

  return (
    <>
      {/* Tasa de cambio */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Banknote className="w-5 h-5 text-[#5B21B6]" /> Tasa de cambio de las monedas
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Cuántas monedas de la tienda vale 1 CUP de dinero real. Se usa para convertir las
          transferencias y los productos que no tienen precio en monedas.
        </p>
        <div className="flex items-center gap-3 flex-wrap">
          <span className="text-[14px] text-[#0F1111] font-bold">1 CUP =</span>
          <input
            value={rateDraft}
            onChange={(e) => setRateDraft(e.target.value)}
            type="number"
            min="1"
            className="w-32 border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
            aria-label="Monedas por CUP"
          />
          <span className="text-[14px] text-[#0F1111] font-bold flex items-center gap-1">
            <Coins className="w-4 h-4 text-[#5B21B6]" /> monedas
          </span>
          <button
            onClick={saveRate}
            disabled={savingRate}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
          >
            Guardar tasa
          </button>
        </div>
      </div>

      {/* Cuentas de cobro */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <CreditCard className="w-5 h-5 text-[#5B21B6]" /> Mis cuentas para recibir
          transferencias
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Estas cuentas aparecen solo en el momento de pagar: cuando un usuario elige transferencia
          en el carrito o va a recargar su billetera. En el resto de la web no se muestran.
        </p>

        {/* Aviso obligatorio: todo administrador necesita sus datos guardados */}
        {methods.filter((m) => m.active).length === 0 ? (
          <div className="bg-[#FEF3C7] border border-[#B45309]/40 rounded-lg p-4 mb-4">
            <p className="text-[14px] font-bold text-[#B45309]">
              ¡Falta configurar tus datos de cobro!
            </p>
            <p className="text-[13px] text-[#B45309] mt-1">
              Todo administrador debe guardar aquí su tarjeta o cuenta, el titular y el teléfono.
              Sin estos datos los usuarios no pueden transferir ni recargar su billetera.
            </p>
          </div>
        ) : (
          <div className="bg-[#f0faf0] border border-[#007600]/30 rounded-lg p-3 mb-4 text-[13px]">
            <p className="text-[#007600] font-bold flex items-center gap-1.5">
              <Check className="w-4 h-4" /> Datos de cobro listos: las recargas y los pagos por
              transferencia funcionan automáticamente.
            </p>
            <p className="text-[#565959] mt-1">
              Recuerda: si hay más administradores, cada uno debe verificar que estos datos sean
              correctos y estén actualizados.
            </p>
          </div>
        )}

        {methods.length === 0 ? (
          <p className="text-[13px] text-[#565959] mb-4">
            No hay cuentas configuradas todavía.
          </p>
        ) : (
          <ul className="flex flex-col gap-2 mb-6">
            {methods.map((m) => (
              <li
                key={m.id}
                className="border border-[#e3e6e6] rounded-lg p-3 flex items-start gap-3 flex-wrap"
              >
                <CreditCard className="w-5 h-5 text-[#5B21B6] mt-0.5 shrink-0" />
                <div className="flex-1 min-w-0 text-[13px]">
                  <p className="font-bold text-[#0F1111]">{m.label}</p>
                  {m.label.includes('ejemplo') && (
                    <p className="text-[12px] font-bold text-[#B45309] mt-0.5">
                      Son datos de ejemplo: quítalos y guarda tu cuenta real con el botón
                      "Revisar y guardar".
                    </p>
                  )}
                  <p className="font-mono text-[#0F1111]">{m.details}</p>
                  <p className="text-[#565959]">Titular: {m.holder}</p>
                  {m.phone && <p className="text-[#565959]">Teléfono: {m.phone}</p>}
                  {m.instructions && <p className="text-[#565959]">{m.instructions}</p>}
                </div>
                <button
                  onClick={() => toggleActive(m)}
                  className={`rounded-full px-3 py-1 text-[12px] font-bold cursor-pointer border ${
                    m.active
                      ? 'bg-[#007600]/10 text-[#007600] border-[#007600]/40'
                      : 'bg-[#f0f2f2] text-[#565959] border-[#d5d9d9]'
                  }`}
                >
                  {m.active ? 'Visible' : 'Oculta'}
                </button>
                <button
                  onClick={() => removeMethod(m)}
                  aria-label={`Eliminar ${m.label}`}
                  className="text-[#C7511F] hover:underline cursor-pointer text-[12px] flex items-center gap-1"
                >
                  <Trash2 className="w-3.5 h-3.5" /> Quitar
                </button>
              </li>
            ))}
          </ul>
        )}

        <h3 className="text-[14px] font-bold text-[#0F1111] flex items-center gap-1.5 mb-2">
          <Plus className="w-4 h-4" /> Agregar cuenta o tarjeta
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <input
            value={label}
            onChange={(e) => setLabel(e.target.value)}
            placeholder="Nombre: Ej: Tarjeta monetaria BPA"
            className="border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
          />
          <input
            value={details}
            onChange={(e) => setDetails(e.target.value)}
            placeholder="Número de tarjeta o cuenta"
            className="border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
          />
          <input
            value={holder}
            onChange={(e) => setHolder(e.target.value)}
            placeholder="Titular de la cuenta"
            className="border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
          />
          <input
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="Teléfono del titular (Transfermóvil/enZona)"
            className="border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
          />
          <input
            value={instructions}
            onChange={(e) => setInstructions(e.target.value)}
            placeholder="Instrucciones (opcional): banco, tipo de moneda…"
            className="border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
          />
        </div>
        <button
          onClick={addMethod}
          disabled={confirming}
          className="mt-3 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
        >
          Revisar y guardar
        </button>

        {/* Confirmación antes de guardar los datos de cobro */}
        {confirming && (
          <div className="mt-4 border-2 border-[#007600]/40 bg-[#f0faf0] rounded-lg p-4">
            <p className="text-[15px] font-bold text-[#0F1111] flex items-center gap-1.5">
              <Check className="w-5 h-5 text-[#007600]" /> Revisa los datos antes de confirmar
            </p>
            <p className="text-[13px] text-[#565959] mt-1">
              Estos datos se mostrarán a los usuarios SOLO al pagar por transferencia o al recargar
              su billetera. Confirma que todo esté correcto:
            </p>
            <ul className="mt-3 bg-white border border-[#e3e6e6] rounded-lg p-3 text-[13px] flex flex-col gap-1">
              <li>
                <b>Nombre de la cuenta:</b> {label}
              </li>
              <li>
                <b>Número de tarjeta o cuenta:</b>{' '}
                <span className="font-mono select-all">{details}</span>
              </li>
              <li>
                <b>Titular:</b> {holder}
              </li>
              <li>
                <b>Teléfono:</b> {phone}
              </li>
              {instructions.trim() && (
                <li>
                  <b>Instrucciones:</b> {instructions}
                </li>
              )}
            </ul>
            <div className="flex gap-2 mt-3 flex-wrap">
              <button
                onClick={confirmSave}
                disabled={saving}
                className="bg-[#007600] hover:bg-[#005e00] text-white text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
              >
                {saving ? 'Guardando…' : 'Confirmar y guardar'}
              </button>
              <button
                onClick={() => setConfirming(false)}
                disabled={saving}
                className="border border-[#d5d9d9] rounded-full px-6 py-2 text-[13px] hover:bg-[#f7fafa] cursor-pointer disabled:opacity-60"
              >
                Editar los datos
              </button>
            </div>
          </div>
        )}
      </div>
    </>
  )
}

// ============================================================
// SEGURIDAD DEL SISTEMA
// - Token del bot de Telegram (plan B de los códigos SMS):
//   se guarda SOLO tras revisarlo y confirmar
// - Estado de los canales de envío (correo / SMS / Telegram)
// - Registro de eventos de seguridad (ataques, bloqueos…)
// - Bandeja de salida de mensajes con su estado
// ============================================================
type AdminSecurity = {
  telegram: { configured: boolean; maskedToken: string | null; botUsername: string | null; source: 'panel' | 'servidor' | null }
  email: { configured: boolean; maskedKey: string | null; from: string | null; source: 'panel' | 'servidor' | null }
  sms: { configured: boolean; maskedUrl: string | null; maskedKey: string | null; source: 'panel' | 'servidor' | null }
  channels: { email: boolean; sms: boolean; telegram: boolean }
  events: { id: string; userName: string; type: string; detail: string; ip: string; createdAt: string }[]
  outbox: { id: string; channel: string; target: string; subject: string; body: string; status: string; error: string | null; createdAt: string }[]
  lockedUsers: { name: string; lockedUntil: string }[]
}

const EVENT_LABELS: Record<string, { label: string; color: string; bg: string }> = {
  login_ok: { label: 'Inicio de sesión', color: '#007600', bg: '#E7F7E7' },
  login_failed: { label: 'Contraseña fallida', color: '#B45309', bg: '#FEF3C7' },
  login_blocked: { label: 'Entrada con cuenta bloqueada', color: '#C7511F', bg: '#FDE8E0' },
  account_locked: { label: 'Cuenta bloqueada', color: '#C7511F', bg: '#FDE8E0' },
  account_created: { label: 'Cuenta creada', color: '#5B21B6', bg: '#f6f1fd' },
  attack_blocked: { label: 'Ataque bloqueado', color: '#FFFFFF', bg: '#B91C1C' },
  reset_code_sent: { label: 'Código de restablecimiento', color: '#5B21B6', bg: '#f6f1fd' },
  reset_code_ok: { label: 'Código validado', color: '#007600', bg: '#E7F7E7' },
  reset_code_failed: { label: 'Código incorrecto', color: '#B45309', bg: '#FEF3C7' },
  password_reset: { label: 'Contraseña restablecida', color: '#007600', bg: '#E7F7E7' },
  password_changed: { label: 'Contraseña cambiada', color: '#007600', bg: '#E7F7E7' },
  password_change_failed: { label: 'Cambio de contraseña fallido', color: '#B45309', bg: '#FEF3C7' },
  session_created: { label: 'Nueva sesión', color: '#0F1111', bg: '#f0f2f2' },
  session_revoked: { label: 'Sesión cerrada', color: '#0F1111', bg: '#f0f2f2' },
  contact_updated: { label: 'Contacto actualizado', color: '#5B21B6', bg: '#f6f1fd' },
  contact_verified: { label: 'Contacto verificado', color: '#007600', bg: '#E7F7E7' },
  verify_code_sent: { label: 'Código de verificación', color: '#5B21B6', bg: '#f6f1fd' },
  telegram_link_started: { label: 'Enlace Telegram iniciado', color: '#5B21B6', bg: '#f6f1fd' },
  telegram_linked: { label: 'Telegram enlazado', color: '#007600', bg: '#E7F7E7' },
  telegram_unlinked: { label: 'Telegram desconectado', color: '#0F1111', bg: '#f0f2f2' },
  security_config: { label: 'Configuración de seguridad', color: '#5B21B6', bg: '#f6f1fd' },
  reset_requested_unknown: { label: 'Restablecimiento (cuenta inexistente)', color: '#565959', bg: '#f0f2f2' },
}

const OUTBOX_STATUS: Record<string, { label: string; color: string; bg: string }> = {
  sent: { label: 'Enviado', color: '#007600', bg: '#E7F7E7' },
  simulated: { label: 'Simulado (sin canal real)', color: '#B45309', bg: '#FEF3C7' },
  failed: { label: 'Falló', color: '#C7511F', bg: '#FDE8E0' },
  queued: { label: 'En cola', color: '#565959', bg: '#f0f2f2' },
}

const CHANNEL_NAMES: Record<string, string> = {
  email: 'Correo',
  sms: 'SMS',
  telegram: 'Telegram',
}

function SecuritySection() {
  const [data, setData] = useState<AdminSecurity | null>(null)
  const [loading, setLoading] = useState(true)
  const [tokenDraft, setTokenDraft] = useState('')
  const [confirming, setConfirming] = useState<null | 'bot' | 'email' | 'sms'>(null)
  const [saving, setSaving] = useState(false)
  // Formularios de correo y SMS (solo el dueño de la web)
  const [emailKeyDraft, setEmailKeyDraft] = useState('')
  const [emailFromDraft, setEmailFromDraft] = useState('')
  const [smsUrlDraft, setSmsUrlDraft] = useState('')
  const [smsKeyDraft, setSmsKeyDraft] = useState('')

  const load = useCallback(async () => {
    try {
      const r = await api<AdminSecurity>('/api/admin/security')
      setData(r)
      if (r.email.configured && r.email.source === 'panel' && r.email.from) {
        setEmailFromDraft((cur) => cur || r.email.from || '')
      }
      if (r.sms.configured && r.sms.source === 'panel' && r.sms.maskedUrl) {
        setSmsUrlDraft((cur) => cur || r.sms.maskedUrl || '')
      }
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    load()
  }, [load])

  // Guardar el token: SIEMPRE pide revisión y confirmación
  const saveToken = async () => {
    if (tokenDraft.trim().length < 20) {
      toast.error('Pega el token completo que te dio @BotFather (empieza por "1…" o "2…" y es largo)')
      return
    }
    setConfirming('bot')
  }

  const saveEmail = async () => {
    if (emailKeyDraft.trim().length < 10) {
      toast.error('Pega la clave de API de Resend (empieza por "re_" y es larga)')
      return
    }
    setConfirming('email')
  }

  const saveSms = async () => {
    if (!/^https?:\/\/.+/i.test(smsUrlDraft.trim())) {
      toast.error('La dirección del servicio SMS debe empezar por http:// o https://')
      return
    }
    setConfirming('sms')
  }

  // Envía al servidor la configuración que se confirmó
  const confirmSave = async () => {
    setSaving(true)
    try {
      let payload: Record<string, unknown> = {}
      if (confirming === 'bot') payload = { botToken: tokenDraft.trim() }
      if (confirming === 'email')
        payload = { resendApiKey: emailKeyDraft.trim(), emailFrom: emailFromDraft.trim() }
      if (confirming === 'sms')
        payload = { smsApiUrl: smsUrlDraft.trim(), smsApiKey: smsKeyDraft.trim() }
      const r = await api<{ ok: boolean; message: string }>('/api/admin/security', {
        method: 'POST',
        body: JSON.stringify(payload),
      })
      toast.success(r.message)
      setTokenDraft('')
      setEmailKeyDraft('')
      setSmsKeyDraft('')
      setConfirming(null)
      await load()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const clearChannel = async (action: 'clear_bot' | 'clear_email' | 'clear_sms') => {
    const what = action === 'clear_bot' ? 'desconectar el bot de Telegram' : action === 'clear_email' ? 'desconectar el correo' : 'desconectar el SMS'
    if (!window.confirm(`¿Seguro que quieres ${what}? Los códigos dejarán de llegar por ese canal.`)) return
    setSaving(true)
    try {
      const r = await api<{ ok: boolean; message: string }>('/api/admin/security', {
        method: 'POST',
        body: JSON.stringify({ action }),
      })
      toast.success(r.message)
      setConfirming(null)
      await load()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  if (loading) return <p className="text-center py-10 text-[#565959]">Cargando seguridad…</p>
  if (!data) return null

  const when = (iso: string) =>
    new Date(iso).toLocaleString('es', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })

  return (
    <>
      {/* Estado de los canales */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <ShieldAlert className="w-5 h-5 text-[#5B21B6]" /> Canales de envío de códigos
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Los códigos de seguridad llegan al teléfono por SMS; si el SMS no llega, los envía el
          bot de Telegram; el correo es el tercer canal. Hasta que no haya ningún canal real
          configurado, los códigos se muestran en pantalla como MODO DEMOSTRACIÓN.
        </p>
        <div className="flex gap-2 flex-wrap">
          <span className={`text-[13px] font-bold rounded-full px-4 py-1.5 ${data.channels.email ? 'bg-[#E7F7E7] text-[#007600]' : 'bg-[#f0f2f2] text-[#565959]'}`}>
            Correo electrónico: {data.channels.email ? `activo (${data.email.source === 'panel' ? 'configurado por ti' : 'variables del servidor'})` : 'no configurado'}
          </span>
          <span className={`text-[13px] font-bold rounded-full px-4 py-1.5 ${data.channels.sms ? 'bg-[#E7F7E7] text-[#007600]' : 'bg-[#f0f2f2] text-[#565959]'}`}>
            SMS: {data.channels.sms ? `activo (${data.sms.source === 'panel' ? 'configurado por ti' : 'variables del servidor'})` : 'no configurado'}
          </span>
          <span className={`text-[13px] font-bold rounded-full px-4 py-1.5 ${data.channels.telegram ? 'bg-[#E7F7E7] text-[#007600]' : 'bg-[#FFF8EE] text-[#B45309]'}`}>
            Bot de Telegram: {data.telegram.configured ? `conectado${data.telegram.botUsername ? ` (@${data.telegram.botUsername})` : ''}${data.telegram.source === 'panel' ? ' · tuyo' : ' · del servidor'}` : 'no configurado'}
          </span>
        </div>
        {!data.channels.email && !data.channels.sms && !data.channels.telegram && (
          <p className="text-[13px] text-[#B45309] mt-3 flex items-start gap-1.5">
            <ShieldAlert className="w-4 h-4 shrink-0 mt-0.5" />
            Guarda abajo el token del bot de Telegram para que los códigos lleguen de verdad.
          </p>
        )}
        {data.lockedUsers.length > 0 && (
          <p className="text-[13px] text-[#C7511F] mt-3">
            Cuentas bloqueadas ahora mismo: {data.lockedUsers.map((u) => `${u.name} (hasta ${when(u.lockedUntil)})`).join(', ')}
          </p>
        )}
      </section>

      {/* Token del bot de Telegram */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Bot className="w-5 h-5 text-[#5B21B6]" /> Bot de Telegram
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Crea un bot con <b>@BotFather</b> en Telegram, copia el token y guárdalo aquí (con
          confirmación). El bot enviará los códigos cuando el SMS no llegue y permitirá a los
          usuarios enlazar su cuenta. <b>Esta configuración solo la ve el dueño de la web.</b>
        </p>
        {data.telegram.configured && (
          <p className="text-[13px] text-[#007600] font-bold mb-3">
            Token guardado: <span className="font-mono">{data.telegram.maskedToken}</span>
            {data.telegram.botUsername ? ` · bot @${data.telegram.botUsername}` : ''}
          </p>
        )}
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
          {data.telegram.configured ? 'Token nuevo (reemplaza al actual)' : 'Token del bot'}
        </label>
        <input
          value={tokenDraft}
          onChange={(e) => setTokenDraft(e.target.value)}
          placeholder="1234567890:AAE…"
          aria-label="Token del bot de Telegram"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] font-mono outline-none focus:border-[#e77600] mb-3"
        />
        <div className="flex gap-2 flex-wrap">
          <button
            onClick={saveToken}
            disabled={saving || confirming !== null}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
          >
            Revisar y guardar
          </button>
          {data.telegram.configured && (
            <button
              onClick={() => clearChannel('clear_bot')}
              disabled={saving || confirming !== null}
              className="border border-[#C7511F] text-[#C7511F] hover:bg-[#FDE8E0] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
            >
              Desconectar el bot
            </button>
          )}
        </div>

        {/* Confirmación antes de guardar el token */}
        {confirming === 'bot' && (
          <div className="mt-4 border-2 border-[#007600]/40 bg-[#f0faf0] rounded-lg p-4">
            <p className="text-[15px] font-bold text-[#0F1111] flex items-center gap-1.5">
              <Check className="w-5 h-5 text-[#007600]" /> Revisa el token antes de confirmar
            </p>
            <p className="text-[13px] text-[#565959] mt-1">
              Vamos a guardar este token en el sistema de seguridad. Los códigos de las cuentas
              empezarán a llegar por Telegram cuando el SMS no llegue.
            </p>
            <p className="mt-3 bg-white border border-[#e3e6e6] rounded-lg p-3 text-[13px] font-mono break-all select-all">
              {tokenDraft.trim()}
            </p>
            <div className="flex gap-2 mt-3 flex-wrap">
              <button
                onClick={confirmSave}
                disabled={saving}
                className="bg-[#007600] hover:bg-[#005e00] text-white text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
              >
                {saving ? 'Guardando…' : 'Confirmar y guardar'}
              </button>
              <button
                onClick={() => setConfirming(null)}
                disabled={saving}
                className="border border-[#d5d9d9] rounded-full px-6 py-2 text-[13px] hover:bg-[#f7fafa] cursor-pointer disabled:opacity-60"
              >
                Editar el token
              </button>
            </div>
          </div>
        )}
      </section>

      {/* Correo electrónico (Resend) — solo el dueño */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Mail className="w-5 h-5 text-[#5B21B6]" /> Correo electrónico (Resend)
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Crea una cuenta en <b>resend.com</b>, copia tu clave de API y guárdala aquí para que los
          códigos lleguen por correo. La clave se guarda en el sistema, nunca se devuelve completa
          y solo se muestra enmascarada. <b>Esta configuración solo la ve el dueño de la web.</b>
        </p>
        {data.email.configured && (
          <p className="text-[13px] text-[#007600] font-bold mb-3">
            Clave guardada: <span className="font-mono">{data.email.maskedKey}</span>
            {data.email.from ? ` · remitente: ${data.email.from}` : ''}
          </p>
        )}
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
          {data.email.configured ? 'Clave nueva (reemplaza a la actual)' : 'Clave de API de Resend'}
        </label>
        <input
          value={emailKeyDraft}
          onChange={(e) => setEmailKeyDraft(e.target.value)}
          placeholder="re_123456789…"
          aria-label="Clave de API de Resend"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] font-mono outline-none focus:border-[#e77600] mb-3"
        />
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
          Remitente (opcional)
        </label>
        <input
          value={emailFromDraft}
          onChange={(e) => setEmailFromDraft(e.target.value)}
          placeholder="Violetero <tienda@violetero.cu>"
          aria-label="Remitente del correo"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
        />
        <div className="flex gap-2 flex-wrap">
          <button
            onClick={saveEmail}
            disabled={saving || confirming !== null}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
          >
            Revisar y guardar
          </button>
          {data.email.configured && data.email.source === 'panel' && (
            <button
              onClick={() => clearChannel('clear_email')}
              disabled={saving || confirming !== null}
              className="border border-[#C7511F] text-[#C7511F] hover:bg-[#FDE8E0] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
            >
              Desconectar el correo
            </button>
          )}
        </div>

        {/* Confirmación antes de guardar la clave del correo */}
        {confirming === 'email' && (
          <div className="mt-4 border-2 border-[#007600]/40 bg-[#f0faf0] rounded-lg p-4">
            <p className="text-[15px] font-bold text-[#0F1111] flex items-center gap-1.5">
              <Check className="w-5 h-5 text-[#007600]" /> Revisa la clave antes de confirmar
            </p>
            <p className="text-[13px] text-[#565959] mt-1">
              Guardaremos esta clave de API para el envío de correos de seguridad.
              {emailFromDraft.trim() ? ` Remitente: ${emailFromDraft.trim()}.` : ''}
            </p>
            <p className="mt-3 bg-white border border-[#e3e6e6] rounded-lg p-3 text-[13px] font-mono break-all select-all">
              {emailKeyDraft.trim()}
            </p>
            <div className="flex gap-2 mt-3 flex-wrap">
              <button
                onClick={confirmSave}
                disabled={saving}
                className="bg-[#007600] hover:bg-[#005e00] text-white text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
              >
                {saving ? 'Guardando…' : 'Confirmar y guardar'}
              </button>
              <button
                onClick={() => setConfirming(null)}
                disabled={saving}
                className="border border-[#d5d9d9] rounded-full px-6 py-2 text-[13px] hover:bg-[#f7fafa] cursor-pointer disabled:opacity-60"
              >
                Editar la clave
              </button>
            </div>
          </div>
        )}
      </section>

      {/* Pasarela SMS — solo el dueño */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <MessageSquareText className="w-5 h-5 text-[#5B21B6]" /> Pasarela SMS
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Dirección del servicio que envía los mensajes de texto (el sistema llama a esa dirección
          con {'{ to, text }'} en JSON; si pones una clave, se envía como Bearer token). El SMS es
          el primer canal de los códigos. <b>Esta configuración solo la ve el dueño de la web.</b>
        </p>
        {data.sms.configured && (
          <p className="text-[13px] text-[#007600] font-bold mb-3">
            Servicio guardado: <span className="font-mono break-all">{data.sms.maskedUrl}</span>
            {data.sms.maskedKey ? ` · clave ${data.sms.maskedKey}` : ' · sin clave'}
          </p>
        )}
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
          {data.sms.configured && data.sms.source === 'panel' ? 'Dirección nueva (reemplaza la actual)' : 'Dirección del servicio SMS (URL)'}
        </label>
        <input
          value={smsUrlDraft}
          onChange={(e) => setSmsUrlDraft(e.target.value)}
          placeholder="https://tu-servicio.cu/sms"
          aria-label="Dirección del servicio SMS"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] font-mono outline-none focus:border-[#e77600] mb-3"
        />
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
          Clave de API del servicio (opcional)
        </label>
        <input
          value={smsKeyDraft}
          onChange={(e) => setSmsKeyDraft(e.target.value)}
          placeholder="clave que te dio tu proveedor SMS"
          aria-label="Clave de API del servicio SMS"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] font-mono outline-none focus:border-[#e77600] mb-3"
        />
        <div className="flex gap-2 flex-wrap">
          <button
            onClick={saveSms}
            disabled={saving || confirming !== null}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
          >
            Revisar y guardar
          </button>
          {data.sms.configured && data.sms.source === 'panel' && (
            <button
              onClick={() => clearChannel('clear_sms')}
              disabled={saving || confirming !== null}
              className="border border-[#C7511F] text-[#C7511F] hover:bg-[#FDE8E0] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
            >
              Desconectar el SMS
            </button>
          )}
        </div>

        {/* Confirmación antes de guardar la pasarela SMS */}
        {confirming === 'sms' && (
          <div className="mt-4 border-2 border-[#007600]/40 bg-[#f0faf0] rounded-lg p-4">
            <p className="text-[15px] font-bold text-[#0F1111] flex items-center gap-1.5">
              <Check className="w-5 h-5 text-[#007600]" /> Revisa la configuración antes de confirmar
            </p>
            <p className="text-[13px] text-[#565959] mt-1">
              Guardaremos esta dirección como pasarela de SMS para los códigos de seguridad.
            </p>
            <p className="mt-3 bg-white border border-[#e3e6e6] rounded-lg p-3 text-[13px] font-mono break-all select-all">
              {smsUrlDraft.trim()}
            </p>
            <div className="flex gap-2 mt-3 flex-wrap">
              <button
                onClick={confirmSave}
                disabled={saving}
                className="bg-[#007600] hover:bg-[#005e00] text-white text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer disabled:opacity-60"
              >
                {saving ? 'Guardando…' : 'Confirmar y guardar'}
              </button>
              <button
                onClick={() => setConfirming(null)}
                disabled={saving}
                className="border border-[#d5d9d9] rounded-full px-6 py-2 text-[13px] hover:bg-[#f7fafa] cursor-pointer disabled:opacity-60"
              >
                Editar la dirección
              </button>
            </div>
          </div>
        )}
      </section>

      {/* Registro de eventos de seguridad */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <ScrollText className="w-5 h-5 text-[#5B21B6]" /> Registro de seguridad (últimos 40)
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Inicios de sesión, contraseñas fallidas, bloqueos y ataques bloqueados. Si ves muchos
          eventos rojos seguidos, alguien puede estar intentando entrar a la fuerza.
        </p>
        <div className="max-h-96 overflow-y-auto flex flex-col gap-2 vio-scroll">
          {data.events.length === 0 && (
            <p className="text-[13px] text-[#565959]">Todavía no hay eventos registrados.</p>
          )}
          {data.events.map((ev) => {
            const info = EVENT_LABELS[ev.type] || { label: ev.type, color: '#565959', bg: '#f0f2f2' }
            return (
              <div key={ev.id} className="border border-[#e3e6e6] rounded-lg p-3 text-[13px]">
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="font-bold rounded-full px-2.5 py-0.5 text-[12px]" style={{ color: info.color, backgroundColor: info.bg }}>
                    {info.label}
                  </span>
                  <span className="text-[#0F1111] font-bold">{ev.userName || '—'}</span>
                  <span className="text-[#565959] ml-auto">{when(ev.createdAt)}</span>
                </div>
                <p className="text-[#565959] mt-1">
                  {ev.detail}
                  {ev.ip && ev.ip !== 'local' ? ` · IP ${ev.ip}` : ''}
                </p>
              </div>
            )
          })}
        </div>
      </section>

      {/* Bandeja de salida */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Bot className="w-5 h-5 text-[#5B21B6]" /> Bandeja de salida de mensajes (últimos 40)
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Cada código o aviso que el sistema intenta enviar queda aquí: canal, destinatario y si
          se envió de verdad, se simuló o falló.
        </p>
        <div className="max-h-96 overflow-y-auto flex flex-col gap-2 vio-scroll">
          {data.outbox.length === 0 && (
            <p className="text-[13px] text-[#565959]">Todavía no se ha enviado ningún mensaje.</p>
          )}
          {data.outbox.map((m) => {
            const st = OUTBOX_STATUS[m.status] || OUTBOX_STATUS.queued
            return (
              <div key={m.id} className="border border-[#e3e6e6] rounded-lg p-3 text-[13px]">
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="bg-[#f6f1fd] text-[#5B21B6] font-bold rounded-full px-2.5 py-0.5 text-[12px]">
                    {CHANNEL_NAMES[m.channel] || m.channel}
                  </span>
                  <span className="font-bold text-[#0F1111]">→ {m.target}</span>
                  <span className="font-bold rounded-full px-2.5 py-0.5 text-[12px]" style={{ color: st.color, backgroundColor: st.bg }}>
                    {st.label}
                  </span>
                  <span className="text-[#565959] ml-auto">{when(m.createdAt)}</span>
                </div>
                {m.error && <p className="text-[#C7511F] mt-1">Error: {m.error}</p>}
              </div>
            )
          })}
        </div>
      </section>
    </>
  )
}
