'use client'
// ============================================================
// FINALIZAR COMPRA: dirección + MINI MAPA + pago + confirmación
// El comprador coloca el pin donde quiere recibir el pedido y
// elige pagar en EFECTIVO al recibir, con TRANSFERENCIA (CUP:
// las tarjetas del administrador se muestran solo en este paso)
// o con MONEDAS de la billetera interna.
// ============================================================
import { useEffect, useMemo, useState } from 'react'
import { Banknote, Check, Coins, Copy, CreditCard, MapPin, Package, Zap } from 'lucide-react'
import { toast } from 'sonner'
import { useStore } from '@/lib/store'
import { api, type MiniStore, type Order, type PaymentMethod, type Settings, type Wallet } from '@/lib/api'
import { cashToCoins, formatCoins, formatPrice } from '@/lib/products'
import { MiniMap, MAP_CENTER } from './MiniMap'

export function CheckoutView() {
  const cart = useStore((s) => s.cart)
  const user = useStore((s) => s.user)
  const clearCart = useStore((s) => s.clearCart)
  const openView = useStore((s) => s.openView)

  const [name, setName] = useState(user.name)
  const [address, setAddress] = useState('')
  const [notes, setNotes] = useState('')
  const [pin, setPin] = useState<{ x: number; y: number } | null>(null)
  const [sending, setSending] = useState(false)
  const [done, setDone] = useState<Order | null>(null)

  // Pago: efectivo, transferencia bancaria (CUP) o monedas internas
  const [method, setMethod] = useState<'cash' | 'coins' | 'transfer'>('cash')
  // Entrega: normal (repartidor de la tienda) o turbo (público al
  // primer mensajero que lo coge). La tarifa del mensajero la
  // definen el dueño de la mini tienda o el dueño de la web.
  const [deliveryMode, setDeliveryMode] = useState<'normal' | 'turbo'>('normal')
  const [rate, setRate] = useState(100)
  const [feeSetting, setFeeSetting] = useState(200)
  const [stores, setStores] = useState<MiniStore[]>([])
  const [wallet, setWallet] = useState<Wallet | null>(null)
  // Cuentas del administrador para recibir la transferencia + su ID
  const [methods, setMethods] = useState<PaymentMethod[]>([])
  const [transferId, setTransferId] = useState('')

  useEffect(() => {
    api<Settings>('/api/settings')
      .then((st) => {
        setRate(st.coinRate || 100)
        setFeeSetting(st.courierFee ?? 200)
      })
      .catch(() => {})
    // Tarifas de las mini tiendas (para mostrar lo que gana el mensajero)
    api<MiniStore[]>('/api/ministores')
      .then(setStores)
      .catch(() => {})
  }, [])

  // Cuentas/tarjetas donde se puede transferir: solo se usan
  // cuando el comprador elige pagar por transferencia.
  useEffect(() => {
    api<PaymentMethod[]>('/api/payment-methods')
      .then(setMethods)
      .catch(() => {})
  }, [])

  useEffect(() => {
    if (!user.name || user.name === 'Invitado') {
      setWallet(null)
      return
    }
    api<Wallet>(`/api/wallet?name=${encodeURIComponent(user.name)}`)
      .then(setWallet)
      .catch(() => {})
  }, [user.name, done])

  // Resumen del carrito. Cada artículo guarda su propio nombre,
  // precio en las dos monedas y tienda al agregarse al carrito.
  const items = useMemo(
    () =>
      cart
        .map((i) => {
          if (!i.mini) return null // artículos antiguos sin datos: se descartan
          return {
            name: i.mini.name,
            price: i.mini.price,
            coins: i.mini.priceCoins ?? cashToCoins(i.mini.price, rate),
            qty: i.qty,
            store: i.mini.storeName,
            productId: i.mini.productId,
            kind: i.mini.kind,
            stock: i.mini.stock,
          }
        })
        .filter((x) => x !== null),
    [cart, rate]
  )
  const total = items.reduce((acc, i) => acc + i.price * i.qty, 0)
  const totalCoins = items.reduce((acc, i) => acc + i.coins * i.qty, 0)
  const count = items.reduce((acc, i) => acc + i.qty, 0)
  const balance = wallet?.coins ?? 0
  const canPayWithCoins = wallet !== null && wallet.guest !== true && balance >= totalCoins

  // Tarifa que ganará el mensajero con este pedido: se suma la
  // tarifa de cada tienda involucrada (la web usa la tarifa
  // global del administrador). El servidor la recalcula al crear
  // el pedido: aquí es solo la vista previa.
  const courierFeePreview = useMemo(() => {
    const buckets = new Set<string>()
    let fee = 0
    for (const i of items) {
      const isWeb = i.kind === 'web'
      const bucket = isWeb ? 'web' : i.store || 'tienda'
      if (buckets.has(bucket)) continue
      buckets.add(bucket)
      if (isWeb) {
        fee += feeSetting
      } else {
        const st = stores.find((s) => s.name === i.store)
        fee += st?.courierFee ?? 200
      }
    }
    return fee
  }, [items, stores, feeSetting])

  // Tiempo estimado: distancia del pin al centro del mapa
  const eta = pin
    ? Math.round(Math.sqrt((pin.x - MAP_CENTER.x) ** 2 + (pin.y - MAP_CENTER.y) ** 2) * 1.4) + 15
    : null

  const confirm = async () => {
    // Como en Amazon: mirar es libre, comprar exige cuenta
    if (user.name === 'Invitado') {
      toast.error('Para completar la compra necesitas una cuenta: regístrate o inicia sesión')
      openView('login')
      return
    }
    if (!name.trim() || !address.trim()) {
      toast.error('Escribe tu nombre y la dirección de entrega')
      return
    }
    if (!pin) {
      toast.error('Coloca el pin en el mini mapa para marcar el punto de entrega')
      return
    }
    if (method === 'coins') {
      if (!wallet || wallet.guest) {
        toast.error('Pon tu nombre (arriba a la derecha) para usar tu billetera de monedas')
        return
      }
      if (!canPayWithCoins) {
        toast.error(
          `Saldo insuficiente: tienes ${formatCoins(balance)} monedas y el pedido cuesta ${formatCoins(totalCoins)}`
        )
        return
      }
    }
    if (method === 'transfer') {
      if (methods.length === 0) {
        toast.error('El administrador todavía no configuró cuentas para recibir transferencias')
        return
      }
      if (!transferId.trim()) {
        toast.error('Escribe el ID de la transferencia (aparece en tu app del banco)')
        return
      }
    }
    // Almacén: comprobar que hay unidades suficientes de cada artículo
    const sinStock = items.find(
      (i) => typeof i.stock === 'number' && i.qty > i.stock
    )
    if (sinStock) {
      toast.error(
        `Solo quedan ${sinStock.stock} unidad(es) de "${sinStock.name}". Ajusta la cantidad en el carrito.`
      )
      return
    }
    setSending(true)
    try {
      const order = await api<Order>('/api/orders', {
        method: 'POST',
        body: JSON.stringify({
          buyerName: name,
          address,
          notes,
          mapX: pin.x,
          mapY: pin.y,
          items,
          total,
          paymentMethod: method,
          totalCoins: method === 'coins' ? totalCoins : undefined,
          transferId: method === 'transfer' ? transferId.trim() : undefined,
          deliveryMode,
        }),
      })
      clearCart()
      setDone(order)
      toast.success(`¡Pedido ${order.code} realizado! Revisa el mini correo.`)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSending(false)
    }
  }

  // ---------- Confirmación ----------
  if (done) {
    return (
      <div className="p-6 max-w-2xl mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-8 text-center">
          <span className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-[#007600]/10">
            <Check className="w-8 h-8 text-[#007600]" strokeWidth={3} />
          </span>
          <h1 className="text-[28px] font-bold text-[#0F1111] mt-4">¡Pedido realizado!</h1>
          <p className="text-[14px] text-[#565959] mt-2">
            Tu pedido <span className="font-bold">{done.code}</span> llegará en aproximadamente{' '}
            <span className="font-bold">{done.etaMinutes} minutos</span> a {done.address}.
          </p>
          <p className="text-[14px] text-[#0F1111] font-bold mt-2">
            {done.paymentMethod === 'coins'
              ? `Pagado con ${formatCoins(done.totalCoins ?? 0)} monedas de tu billetera`
              : done.paymentMethod === 'transfer'
                ? `Transferencia registrada (ID: ${done.transferId}). El vendedor confirmará tu pago`
                : `Pagarás ${formatPrice(done.total)} en efectivo al recibir`}
          </p>
          <p className="text-[13px] text-[#565959] mt-1">
            Enviamos el resumen completo a tu mini correo interno.
          </p>
          <div className="flex flex-col sm:flex-row gap-3 justify-center mt-6">
            <button
              onClick={() => openView('inbox')}
              className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-6 py-2 cursor-pointer"
            >
              Ver mini correo
            </button>
            <button
              onClick={() => openView('orders')}
              className="border border-[#d5d9d9] rounded-full px-6 py-2 text-[14px] hover:bg-[#f7fafa] cursor-pointer"
            >
              Ver mis pedidos
            </button>
          </div>
        </div>
      </div>
    )
  }

  // ---------- Carrito vacío ----------
  if (items.length === 0) {
    return (
      <div className="p-6 max-w-2xl mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-10 text-center">
          <p className="text-[16px] font-bold text-[#0F1111]">Tu carrito está vacío</p>
          <button
            onClick={() => openView('home')}
            className="mt-6 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-8 py-2 cursor-pointer"
          >
            Ir a comprar
          </button>
        </div>
      </div>
    )
  }

  // ---------- Formulario ----------
  return (
    <div className="p-4 max-w-[1200px] mx-auto">
      <h1 className="text-[28px] font-bold text-[#0F1111] mb-4">Finalizar compra</h1>

      {/* Aviso para invitados: puedes mirar, pero comprar exige cuenta */}
      {user.name === 'Invitado' && (
        <div className="bg-[#FEF3C7] border border-[#B45309]/40 rounded-lg p-4 mb-4 flex flex-col sm:flex-row sm:items-center gap-3">
          <div className="flex-1">
            <p className="text-[14px] font-bold text-[#B45309]">
              Estás comprando como Invitado
            </p>
            <p className="text-[13px] text-[#B45309] mt-0.5">
              Como en Amazon: revisar ofertas es gratis, pero para confirmar el pedido necesitas
              una cuenta. Tus artículos ya están guardados en el carrito.
            </p>
          </div>
          <button
            onClick={() => openView('login')}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-6 py-2 cursor-pointer shrink-0"
          >
            Iniciar sesión o registrarme
          </button>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
        {/* Formulario + mapa */}
        <div className="lg:col-span-3 flex flex-col gap-4">
          <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
            <h2 className="text-[18px] font-bold text-[#0F1111] mb-4 flex items-center gap-2">
              <MapPin className="w-5 h-5 text-[#5B21B6]" /> ¿Dónde entregamos tu compra?
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
              <div>
                <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Tu nombre</label>
                <input
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
                />
              </div>
              <div>
                <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
                  Dirección exacta
                </label>
                <input
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  placeholder="Calle, número, apartamento…"
                  className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
                />
              </div>
            </div>
            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
              Indicaciones para el repartidor (opcional)
            </label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={2}
              placeholder="Ej: casa azul con portón verde, tocar el timbre 2"
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] resize-none"
            />
          </section>

          <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
            <h2 className="text-[18px] font-bold text-[#0F1111] mb-1">Mini mapa de entrega</h2>
            <p className="text-[13px] text-[#565959] mb-3">
              Haz clic en el mapa para colocar el pin donde quieres recibir el pedido. El repartidor
              verá ese punto en su pantalla.
            </p>
            <MiniMap
              x={pin?.x ?? null}
              y={pin?.y ?? null}
              onPick={(x, y) => setPin({ x, y })}
              height={340}
            />
          </section>
        </div>

        {/* Resumen */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg border border-[#e3e6e6] p-6 lg:sticky lg:top-28">
            <h2 className="text-[18px] font-bold text-[#0F1111] mb-3">Resumen del pedido</h2>
            <ul className="text-[13px] divide-y divide-[#e3e6e6] mb-3">
              {items.map((i, idx) => (
                <li key={idx} className="py-2 flex justify-between gap-2">
                  <span className="text-[#0F1111] truncate">
                    {i.qty}× {i.name}
                    <span className="block text-[11px] text-[#565959]">Vendido por {i.store}</span>
                  </span>
                  <span className="font-bold text-[#0F1111] shrink-0">
                    {formatPrice(i.price * i.qty)}
                  </span>
                </li>
              ))}
            </ul>
            <p className="text-[18px] text-[#0F1111] border-t border-[#e3e6e6] pt-3">
              Total ({count} {count === 1 ? 'artículo' : 'artículos'}):{' '}
              <span className="font-bold">{formatPrice(total)}</span>
            </p>

            {/* Pago en las dos monedas */}
            <h3 className="text-[15px] font-bold text-[#0F1111] mt-4 mb-2">Método de pago</h3>
            <div className="flex flex-col gap-2">
              <button
                onClick={() => setMethod('cash')}
                className={`text-left border-2 rounded-lg p-3 cursor-pointer transition-colors ${
                  method === 'cash' ? 'border-[#007600] bg-[#f0faf0]' : 'border-[#d5d9d9] hover:border-[#888c8c]'
                }`}
              >
                <span className="flex items-center gap-2 text-[14px] font-bold text-[#0F1111]">
                  <Banknote className="w-4.5 h-4.5 text-[#007600]" /> Efectivo al recibir
                </span>
                <span className="block text-[13px] text-[#565959] mt-0.5">
                  Pagas {formatPrice(total)} en mano al repartidor
                </span>
              </button>
              <button
                onClick={() => setMethod('transfer')}
                className={`text-left border-2 rounded-lg p-3 cursor-pointer transition-colors ${
                  method === 'transfer' ? 'border-[#C7511F] bg-[#FDF3EE]' : 'border-[#d5d9d9] hover:border-[#888c8c]'
                }`}
              >
                <span className="flex items-center gap-2 text-[14px] font-bold text-[#0F1111]">
                  <CreditCard className="w-4.5 h-4.5 text-[#C7511F]" /> Transferencia bancaria (CUP)
                </span>
                <span className="block text-[13px] text-[#565959] mt-0.5">
                  Transfiere {formatPrice(total)} a la cuenta de la tienda y registra el ID
                </span>
              </button>
              <button
                onClick={() => setMethod('coins')}
                className={`text-left border-2 rounded-lg p-3 cursor-pointer transition-colors ${
                  method === 'coins' ? 'border-[#5B21B6] bg-[#f6f1fd]' : 'border-[#d5d9d9] hover:border-[#888c8c]'
                }`}
              >
                <span className="flex items-center gap-2 text-[14px] font-bold text-[#0F1111]">
                  <Coins className="w-4.5 h-4.5 text-[#5B21B6]" /> Monedas de Violetero
                </span>
                <span className="block text-[13px] text-[#565959] mt-0.5">
                  Cuesta {formatCoins(totalCoins)} monedas ·
                  {!wallet || wallet.guest ? (
                    <b className="text-[#B45309]"> pon tu nombre para ver tu saldo</b>
                  ) : (
                    <> tu saldo: {formatCoins(balance)} monedas</>
                  )}
                </span>
              </button>
            </div>

            {/* Modo de entrega: normal por tienda o turbo público */}
            <h3 className="text-[15px] font-bold text-[#0F1111] mt-4 mb-2">Modo de entrega</h3>
            <div className="flex flex-col gap-2">
              <button
                onClick={() => setDeliveryMode('normal')}
                className={`text-left border-2 rounded-lg p-3 cursor-pointer transition-colors ${
                  deliveryMode === 'normal'
                    ? 'border-[#007600] bg-[#f0faf0]'
                    : 'border-[#d5d9d9] hover:border-[#888c8c]'
                }`}
              >
                <span className="flex items-center gap-2 text-[14px] font-bold text-[#0F1111]">
                  <Package className="w-4.5 h-4.5 text-[#007600]" /> Entrega por la tienda
                </span>
                <span className="block text-[13px] text-[#565959] mt-0.5">
                  Lo lleva el repartidor contratado por la tienda. El mensajero gana{' '}
                  {formatPrice(courierFeePreview)} por esta entrega.
                </span>
              </button>
              <button
                onClick={() => setDeliveryMode('turbo')}
                className={`text-left border-2 rounded-lg p-3 cursor-pointer transition-colors ${
                  deliveryMode === 'turbo'
                    ? 'border-[#5B21B6] bg-[#f6f1fd]'
                    : 'border-[#d5d9d9] hover:border-[#888c8c]'
                }`}
              >
                <span className="flex items-center gap-2 text-[14px] font-bold text-[#0F1111]">
                  <Zap className="w-4.5 h-4.5 text-[#5B21B6]" /> Modo turbo
                </span>
                <span className="block text-[13px] text-[#565959] mt-0.5">
                  Tu pedido sale al tablero público: cualquier mensajero puede cogerlo y el
                  primero que lo tome lo lleva. Ganará {formatPrice(courierFeePreview)} por
                  entregarte esta compra.
                </span>
              </button>
            </div>

            {/* Datos de la transferencia: SOLO se muestran al elegir este pago */}
            {method === 'transfer' && (
              <div className="bg-[#FDF3EE] border border-[#C7511F]/30 rounded-lg p-3 mt-3 text-[13px]">
                <p className="font-bold text-[#0F1111] flex items-center gap-1.5">
                  <CreditCard className="w-4 h-4 text-[#C7511F]" /> 1. Transfiere a una de estas
                  cuentas:
                </p>
                {methods.length === 0 ? (
                  <p className="text-[#C7511F] mt-2">
                    El administrador todavía no configuró sus cuentas de cobro.
                  </p>
                ) : (
                  <ul className="flex flex-col gap-2 mt-2">
                    {methods.map((m) => (
                      <li key={m.id} className="bg-white border border-[#e3e6e6] rounded-lg p-3">
                        <p className="font-bold text-[#0F1111]">{m.label}</p>
                        <div className="flex items-center justify-between gap-2">
                          <p className="font-mono text-[#0F1111] select-all">{m.details}</p>
                          <button
                            onClick={() =>
                              navigator.clipboard
                                ?.writeText(m.details)
                                .then(() => toast.success('Número copiado'))
                                .catch(() => {})
                            }
                            aria-label={`Copiar número de ${m.label}`}
                            className="text-[#565959] hover:text-[#0F1111] cursor-pointer shrink-0"
                          >
                            <Copy className="w-4 h-4" />
                          </button>
                        </div>
                        <p className="text-[#565959]">Titular: {m.holder}</p>
                        {m.phone && <p className="text-[#565959]">Teléfono: {m.phone}</p>}
                        {m.instructions && (
                          <p className="text-[#565959] mt-0.5">{m.instructions}</p>
                        )}
                      </li>
                    ))}
                  </ul>
                )}
                <p className="font-bold text-[#0F1111] mt-3">
                  2. Registra el ID de tu transferencia:
                </p>
                <input
                  value={transferId}
                  onChange={(e) => setTransferId(e.target.value)}
                  placeholder="Ej: TRF-20241231-00982"
                  className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mt-1 bg-white"
                />
              </div>
            )}

            {method === 'coins' && !canPayWithCoins && (
              <div className="bg-[#FEF3C7] border border-[#B45309]/30 rounded-lg p-3 mt-3 text-[13px]">
                {!wallet || wallet.guest ? (
                  <p className="text-[#B45309]">
                    Pon tu nombre arriba a la derecha (Hola, Invitado) para usar tu billetera.
                  </p>
                ) : (
                  <p className="text-[#B45309]">
                    Te faltan {formatCoins(totalCoins - balance)} monedas.{' '}
                    <button
                      onClick={() => openView('wallet')}
                      className="underline font-bold cursor-pointer"
                    >
                      Recargar en Mi Billetera
                    </button>
                  </p>
                )}
              </div>
            )}

            <div className="bg-[#f7fafa] border border-[#d5d9d9] rounded-lg p-3 mt-4 text-[13px]">
              <p className="font-bold text-[#0F1111]">Tiempo estimado de entrega</p>
              {eta !== null ? (
                <p className="text-[#007600] font-bold mt-1">
                  Llega en ~{eta} minutos según la distancia en el mapa
                </p>
              ) : (
                <p className="text-[#565959] mt-1">
                  Coloca el pin en el mapa para calcular el tiempo
                </p>
              )}
            </div>

            <button
              onClick={confirm}
              disabled={sending}
              className="w-full bg-[#FFD814] hover:bg-[#F7CA00] disabled:opacity-60 text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 mt-4 cursor-pointer"
            >
              {sending ? 'Procesando…' : 'Confirmar pedido'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
