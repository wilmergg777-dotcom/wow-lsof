'use client'
// ============================================================
// ENTREGAS (mensajero): pedidos por entregar con el mini mapa
// - TURBO: pedidos públicos para TODOS los mensajeros; el
//   primero que lo coge lo lleva (el que lo coge, hace la
//   mensajería). La tarifa que gana la define el dueño de la
//   mini tienda o el dueño de la web.
// - POR TIENDA: pedidos solo de las tiendas que te contrataron.
// ============================================================
import { useCallback, useEffect, useState } from 'react'
import { Bike, MapPin, PackageOpen, Zap } from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import { api, ORDER_STATUS, type Application, type JobOffer, type Order } from '@/lib/api'
import { formatPrice } from '@/lib/products'
import { MiniMap } from './MiniMap'

export function DeliveriesView() {
  const user = useStore((s) => s.user)
  const openView = useStore((s) => s.openView)
  const [turbo, setTurbo] = useState<Order[]>([])
  const [storeOrders, setStoreOrders] = useState<Order[]>([])
  const [mine, setMine] = useState<Order[]>([])
  const [myStores, setMyStores] = useState<string[]>([])
  const [loading, setLoading] = useState(true)

  const load = useCallback(() => {
    // Parches de seguridad: las entregas propias y las postulaciones
    // solo se consultan con sesión iniciada. El tablero turbo es público.
    const logged = Boolean(user.name) && user.name !== 'Invitado'
    Promise.all([
      api<Order[]>('/api/orders?status=placed&mode=turbo'),
      logged
        ? api<Order[]>(`/api/orders?worker=${encodeURIComponent(user.name)}`)
        : Promise.resolve([] as Order[]),
      logged
        ? api<Application[]>('/api/applications')
        : Promise.resolve([] as Application[]),
      api<JobOffer[]>('/api/joboffers'),
    ])
      .then(([t, m, apps, jobs]) => {
        setTurbo(t)
        setMine(m)
        // Tiendas que me contrataron (postulaciones aceptadas)
        const myJobIds = apps
          .filter((a) => a.applicantName === user.name && a.status === 'accepted')
          .map((a) => a.jobId)
        const storeIds = jobs
          .filter((j) => myJobIds.includes(j.id))
          .map((j) => j.storeId)
        setMyStores([...new Set(storeIds)])
      })
      .catch((e) => {
        if (logged) toast.error(e.message)
      })
      .finally(() => setLoading(false))
  }, [user.name])

  useEffect(() => {
    load()
    const t = setInterval(load, 8000) // se actualiza solo cada 8 segundos
    return () => clearInterval(t)
  }, [load])

  // Pedidos de las tiendas que me contrataron (modo normal)
  useEffect(() => {
    if (myStores.length === 0) {
      // Limpieza diferida para no llamar a setState de forma sincrónica en el efecto
      const id = setTimeout(() => setStoreOrders([]), 0)
      return () => clearTimeout(id)
    }
    let live = true
    api<Order[]>(
      `/api/orders?status=placed&mode=normal&stores=${encodeURIComponent(myStores.join(','))}`
    )
      .then((r) => {
        if (live) setStoreOrders(r)
      })
      .catch(() => {
        if (live) setStoreOrders([])
      })
    return () => {
      live = false
    }
  }, [myStores, turbo, mine])

  const takeOrder = async (o: Order) => {
    try {
      await api(`/api/orders/${o.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ action: 'take', workerName: user.name }),
      })
      toast.success(`Tomaste el pedido ${o.code}. ¡El comprador ya fue avisado!`)
      load()
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  const deliverOrder = async (o: Order) => {
    try {
      await api(`/api/orders/${o.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ action: 'deliver' }),
      })
      toast.success(`Pedido ${o.code} marcado como entregado`)
      load()
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  if (loading) return <p className="text-center py-16 text-[#565959]">Cargando entregas…</p>

  // Los entregas son para cuentas de mensajero (turbo)
  if (user.role !== 'repartidor') {
    return (
      <div className="p-6 max-w-2xl mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-10 text-center">
          <Bike className="w-14 h-14 text-[#5B21B6] mx-auto" strokeWidth={1.4} />
          <h1 className="text-[22px] font-bold text-[#0F1111] mt-4">Entregas para mensajeros</h1>
          <p className="text-[14px] text-[#565959] mt-2">
            Para hacer domicilios y ganar por cada entrega necesitas una cuenta de mensajero
            (turbo). Regístrate eligiendo "Mensajero (turbo)" e inicia sesión.
          </p>
          <button
            onClick={() => openView('login')}
            className="mt-5 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-8 py-2 cursor-pointer"
          >
            Iniciar sesión o registrarme
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="p-4 max-w-[1100px] mx-auto flex flex-col gap-4">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h1 className="text-[28px] font-bold text-[#0F1111] flex items-center gap-2">
          <Bike className="w-7 h-7 text-[#5B21B6]" /> Mis entregas
        </h1>
        <p className="text-[14px] text-[#565959] mt-1">
          Hola {user.name}. Los pedidos <b>turbo</b> son públicos: el primero que los coge los
          lleva. Los pedidos de tiendas solo los ven los mensajeros contratados. Cada entrega
          indica cuánto ganas.
        </p>
      </div>

      {/* Dinero en mano pendiente de entregar al dueño (pagos en efectivo) */}
      {mine.filter((o) => o.status === 'delivered' && o.paymentMethod === 'cash' && !o.settled)
        .length > 0 && (
        <section className="bg-[#FEF3C7] border border-[#B45309]/40 rounded-lg p-5">
          <h2 className="text-[18px] font-bold text-[#B45309] mb-1">
            Dinero en mano pendiente de entregar
          </h2>
          <p className="text-[13px] text-[#B45309] mb-3">
            Cobraste estos pedidos en efectivo. Debes entregarle al dueño de la tienda su parte
            (el total menos tu tarifa). Cuando te pague, el dueño confirma la liquidación desde
            su panel.
          </p>
          <ul className="flex flex-col gap-2">
            {mine
              .filter((o) => o.status === 'delivered' && o.paymentMethod === 'cash' && !o.settled)
              .map((o) => (
                <li
                  key={o.id}
                  className="bg-white border border-[#B45309]/30 rounded-lg p-3 text-[13px] flex flex-wrap items-center gap-2"
                >
                  <span className="font-bold text-[#0F1111]">Pedido {o.code}</span>
                  <span className="text-[#565959]">
                    Cobraste {formatPrice(o.total)} · Tu ganancia:{' '}
                    <b className="text-[#007600]">{formatPrice(o.courierFee)}</b> · Debes entregar:{' '}
                    <b className="text-[#B45309]">{formatPrice(Math.max(0, o.total - o.courierFee))}</b>
                  </span>
                </li>
              ))}
          </ul>
        </section>
      )}

      {/* Pedidos en camino (mis entregas activas) */}
      <section>
        <h2 className="text-[18px] font-bold text-[#0F1111] mb-3">
          En camino ({mine.filter((o) => o.status === 'in_delivery').length})
        </h2>
        {mine.filter((o) => o.status === 'in_delivery').length === 0 ? (
          <p className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-[14px] text-[#565959]">
            No tienes entregas activas. Toma una de abajo.
          </p>
        ) : (
          <div className="flex flex-col gap-4">
            {mine
              .filter((o) => o.status === 'in_delivery')
              .map((o) => (
                <div key={o.id} className="bg-white rounded-lg border border-[#e3e6e6] p-5">
                  <div className="flex flex-wrap justify-between gap-3 items-start">
                    <div className="flex-1 min-w-0">
                      <p className="text-[16px] font-bold text-[#0F1111]">
                        Pedido {o.code} · {formatPrice(o.total)}
                      </p>
                      <p
                        className={`text-[13px] font-bold mt-1 flex items-center gap-1 ${
                          o.paymentMethod === 'coins'
                            ? 'text-[#5B21B6]'
                            : o.paymentMethod === 'transfer'
                              ? 'text-[#007600]'
                              : 'text-[#B45309]'
                        }`}
                      >
                        {o.paymentMethod === 'coins'
                          ? `Ya pagado con monedas: no cobrar dinero`
                          : o.paymentMethod === 'transfer'
                            ? `Ya pagado por transferencia (ID: ${o.transferId ?? '—'}): no cobrar dinero`
                            : `Cobrar ${formatPrice(o.total)} en efectivo al entregar`}
                      </p>
                      <p className="text-[13px] text-[#0F1111] mt-1 flex items-start gap-1.5">
                        <MapPin className="w-4 h-4 text-[#C7511F] shrink-0 mt-0.5" />
                        <span>
                          Entregar a <b>{o.buyerName}</b> en <b>{o.address}</b>
                          {o.notes && (
                            <span className="block text-[#565959]">Indicaciones: {o.notes}</span>
                          )}
                        </span>
                      </p>
                      <p className="text-[13px] font-bold text-[#007600] mt-1">
                        Estimado: {o.etaMinutes} minutos desde la salida
                      </p>
                      <p className="text-[13px] text-[#565959] mt-2">
                        {JSON.parse(o.items).length} artículo(s) ·{' '}
                        {ORDER_STATUS[o.status].label}
                      </p>
                      <button
                        onClick={() => deliverOrder(o)}
                        className="mt-3 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-6 py-2 cursor-pointer"
                      >
                        Marcar como entregado
                      </button>
                    </div>
                    <div className="w-full sm:w-[300px]">
                      <MiniMap x={o.mapX} y={o.mapY} height={200} label="Punto de entrega" />
                    </div>
                  </div>
                </div>
              ))}
          </div>
        )}
      </section>

      {/* Pedidos turbo disponibles (públicos, primero en llegar) */}
      <section>
        <h2 className="text-[18px] font-bold text-[#0F1111] mb-3 flex items-center gap-2">
          <Zap className="w-5 h-5 text-[#5B21B6]" /> Pedidos turbo disponibles ({turbo.length})
        </h2>
        {turbo.length === 0 ? (
          <p className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-[14px] text-[#565959] flex items-center gap-2">
            <PackageOpen className="w-5 h-5 text-[#ddd]" /> No hay pedidos turbo esperando
            mensajero ahora mismo.
          </p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {turbo.map((o) => (
              <div key={o.id} className="bg-white rounded-lg border-2 border-[#5B21B6]/40 p-5">
                <p className="text-[15px] font-bold text-[#0F1111]">
                  Pedido {o.code} · {formatPrice(o.total)}
                </p>
                <p className="text-[13px] font-bold text-[#007600] mt-0.5">
                  Ganas {formatPrice(o.courierFee)} por esta entrega
                </p>
                <p
                  className={`text-[13px] font-bold mt-0.5 ${
                    o.paymentMethod === 'coins'
                      ? 'text-[#5B21B6]'
                      : o.paymentMethod === 'transfer'
                        ? 'text-[#007600]'
                        : 'text-[#B45309]'
                  }`}
                >
                  {o.paymentMethod === 'coins'
                    ? 'Ya pagado con monedas'
                    : o.paymentMethod === 'transfer'
                      ? 'Ya pagado por transferencia'
                      : `Cobrar ${formatPrice(o.total)} en efectivo al entregar`}
                </p>
                <p className="text-[13px] text-[#565959] mt-1">
                  Para <b>{o.buyerName}</b> · {o.address}
                </p>
                <p className="text-[13px] text-[#565959] mt-0.5">
                  {JSON.parse(o.items).length} artículo(s) · estimado {o.etaMinutes} min
                </p>
                <div className="my-3">
                  <MiniMap x={o.mapX} y={o.mapY} height={180} label="Punto de entrega" />
                </div>
                <button
                  onClick={() => takeOrder(o)}
                  className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full py-2 cursor-pointer"
                >
                  Tomar este pedido
                </button>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Pedidos de las tiendas que me contrataron (modo normal) */}
      <section>
        <h2 className="text-[18px] font-bold text-[#0F1111] mb-3">
          Pedidos de mis tiendas contratadas ({storeOrders.length})
        </h2>
        {storeOrders.length === 0 ? (
          <p className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-[14px] text-[#565959] flex items-center gap-2">
            <PackageOpen className="w-5 h-5 text-[#ddd]" />{' '}
            {myStores.length === 0
              ? 'Aún no te contrató ninguna mini tienda: postúlate en Trabajo de Domicilio.'
              : 'Tus tiendas contratadas no tienen pedidos esperando ahora mismo.'}
          </p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {storeOrders.map((o) => (
              <div key={o.id} className="bg-white rounded-lg border border-[#e3e6e6] p-5">
                <p className="text-[15px] font-bold text-[#0F1111]">
                  Pedido {o.code} · {formatPrice(o.total)}
                </p>
                <p className="text-[13px] font-bold text-[#007600] mt-0.5">
                  Ganas {formatPrice(o.courierFee)} por esta entrega
                </p>
                <p className="text-[13px] text-[#565959] mt-1">
                  Para <b>{o.buyerName}</b> · {o.address}
                </p>
                <p className="text-[13px] text-[#565959] mt-0.5">
                  {JSON.parse(o.items).length} artículo(s) · estimado {o.etaMinutes} min
                </p>
                <div className="my-3">
                  <MiniMap x={o.mapX} y={o.mapY} height={180} label="Punto de entrega" />
                </div>
                <button
                  onClick={() => takeOrder(o)}
                  className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full py-2 cursor-pointer"
                >
                  Tomar este pedido
                </button>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  )
}
