'use client'
// ============================================================
// ENTREGAS (repartidor): pedidos por entregar con el mini mapa
// El repartidor ve dónde debe entregar cada compra y marca la
// entrega al finalizar. El comprador recibe notificaciones.
// ============================================================
import { useCallback, useEffect, useState } from 'react'
import { Bike, MapPin, PackageOpen } from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import { api, ORDER_STATUS, type Order } from '@/lib/api'
import { formatPrice } from '@/lib/products'
import { MiniMap } from './MiniMap'

export function DeliveriesView() {
  const user = useStore((s) => s.user)
  const [available, setAvailable] = useState<Order[]>([])
  const [mine, setMine] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)

  const load = useCallback(() => {
    Promise.all([
      api<Order[]>('/api/orders?status=placed'),
      api<Order[]>(`/api/orders?worker=${encodeURIComponent(user.name)}`),
    ])
      .then(([a, m]) => {
        setAvailable(a)
        setMine(m)
      })
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [user.name])

  useEffect(() => {
    load()
    const t = setInterval(load, 8000) // se actualiza solo cada 8 segundos
    return () => clearInterval(t)
  }, [load])

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

  return (
    <div className="p-4 max-w-[1100px] mx-auto flex flex-col gap-4">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h1 className="text-[28px] font-bold text-[#0F1111] flex items-center gap-2">
          <Bike className="w-7 h-7 text-[#5B21B6]" /> Mis entregas
        </h1>
        <p className="text-[14px] text-[#565959] mt-1">
          Hola {user.name}. Toma pedidos disponibles y usa el mini mapa para llegar al punto de
          entrega marcado por el comprador.
        </p>
      </div>

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
                          o.paymentMethod === 'coins' ? 'text-[#5B21B6]' : 'text-[#B45309]'
                        }`}
                      >
                        {o.paymentMethod === 'coins'
                          ? `Ya pagado con monedas: no cobrar dinero`
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

      {/* Pedidos disponibles */}
      <section>
        <h2 className="text-[18px] font-bold text-[#0F1111] mb-3">
          Pedidos disponibles ({available.length})
        </h2>
        {available.length === 0 ? (
          <p className="bg-white rounded-lg border border-[#e3e6e6] p-5 text-[14px] text-[#565959] flex items-center gap-2">
            <PackageOpen className="w-5 h-5 text-[#ddd]" /> No hay pedidos esperando repartidor
            ahora mismo.
          </p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {available.map((o) => (
              <div key={o.id} className="bg-white rounded-lg border border-[#e3e6e6] p-5">
                <p className="text-[15px] font-bold text-[#0F1111]">
                  Pedido {o.code} · {formatPrice(o.total)}
                </p>
                <p
                  className={`text-[13px] font-bold mt-0.5 ${
                    o.paymentMethod === 'coins' ? 'text-[#5B21B6]' : 'text-[#B45309]'
                  }`}
                >
                  {o.paymentMethod === 'coins'
                    ? 'Ya pagado con monedas'
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
    </div>
  )
}
