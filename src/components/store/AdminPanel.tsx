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
// ============================================================
import { useCallback, useEffect, useState } from 'react'
import {
  Banknote,
  Check,
  Coins,
  CreditCard,
  Megaphone,
  Package,
  Plus,
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

type Tab = 'general' | 'ofertas' | 'recargas' | 'cobros'

export function AdminView() {
  const [tab, setTab] = useState<Tab>('general')
  const [settings, setSettings] = useState<Settings | null>(null)
  const [stores, setStores] = useState<MiniStore[]>([])
  const [orders, setOrders] = useState<Order[]>([])
  const [offers, setOffers] = useState<Offer[]>([])
  const [saving, setSaving] = useState(false)
  const [loading, setLoading] = useState(true)

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
              ['ofertas', 'Ofertas de la web'],
              ['recargas', 'Recargas de saldo'],
              ['cobros', 'Cobros y tasa de cambio'],
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

      {tab === 'ofertas' && <OffersSection onChanged={loadMain} />}

      {tab === 'recargas' && <TopUpsSection />}

      {tab === 'cobros' && <PaymentMethodsSection rate={settings?.coinRate || 100} onRateChange={(r) => setSettings((s) => (s ? { ...s, coinRate: r } : s))} />}
    </div>
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
                  Precio en dinero ($)
                </label>
                <input
                  value={price}
                  onChange={(e) => setPrice(e.target.value)}
                  type="number"
                  min="0.01"
                  step="0.01"
                  placeholder="Ej: 12.50"
                  aria-label="Precio en dinero"
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
                  min="0.01"
                  step="0.01"
                  placeholder="Ej: 19.99"
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

  const addMethod = async () => {
    if (!label.trim() || !details.trim() || !holder.trim() || !phone.trim()) {
      toast.error('Completa el nombre de la cuenta, el número, el titular y el teléfono')
      return
    }
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
      load()
      toast.success('Cuenta de cobro agregada: ya aparece en Mi Billetera')
    } catch (e) {
      toast.error((e as Error).message)
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
          Estas cuentas aparecen en Mi Billetera para que los usuarios te transfieran el dinero y
          registren su recarga.
        </p>

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
          className="mt-3 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer"
        >
          Agregar cuenta
        </button>
      </div>
    </>
  )
}
