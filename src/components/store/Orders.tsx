'use client'
// ============================================================
// MIS PEDIDOS (comprador): estado, tiempo estimado y mapa
// ============================================================
import { useEffect, useState } from 'react'
import { PackageCheck } from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import { api, ORDER_STATUS, type Order } from '@/lib/api'
import { formatCoins, formatPrice } from '@/lib/products'
import { MiniMap } from './MiniMap'

export function OrdersView() {
  const user = useStore((s) => s.user)
  const [orders, setOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api<Order[]>(`/api/orders?buyer=${encodeURIComponent(user.name)}`)
      .then(setOrders)
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [user.name])

  if (loading) return <p className="text-center py-16 text-[#565959]">Cargando pedidos…</p>

  return (
    <div className="p-4 max-w-[1000px] mx-auto">
      <h1 className="text-[28px] font-bold text-[#0F1111] mb-4">Mis pedidos</h1>

      {orders.length === 0 ? (
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-12 text-center">
          <PackageCheck className="w-16 h-16 text-[#ddd] mx-auto" strokeWidth={1.2} />
          <p className="text-[16px] font-bold text-[#0F1111] mt-4">Todavía no hiciste pedidos</p>
          <p className="text-[14px] text-[#565959] mt-1">
            Cuando compres en {STORE_NAME}, aquí verás el estado y el tiempo de entrega.
          </p>
        </div>
      ) : (
        <div className="flex flex-col gap-4">
          {orders.map((o) => {
            const items = JSON.parse(o.items) as { name: string; price: number; qty: number; store: string }[]
            const st = ORDER_STATUS[o.status]
            return (
              <div key={o.id} className="bg-white rounded-lg border border-[#e3e6e6] p-5">
                <div className="flex flex-wrap items-center gap-3 justify-between border-b border-[#e3e6e6] pb-3">
                  <div>
                    <p className="text-[16px] font-bold text-[#0F1111]">Pedido {o.code}</p>
                    <p className="text-[12px] text-[#565959]">
                      {new Date(o.createdAt).toLocaleString('es')}
                    </p>
                  </div>
                  <span
                    className="text-[13px] font-bold rounded-full px-4 py-1.5"
                    style={{ backgroundColor: st.color + '1A', color: st.color }}
                  >
                    {st.label}
                  </span>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-3">
                  <div>
                    <ul className="text-[13px] divide-y divide-[#e3e6e6]">
                      {items.map((i, idx) => (
                        <li key={idx} className="py-1.5 flex justify-between gap-2">
                          <span className="text-[#0F1111]">
                            {i.qty}× {i.name}
                            <span className="block text-[11px] text-[#565959]">
                              Vendido por {i.store}
                            </span>
                          </span>
                          <span className="font-bold text-[#0F1111]">
                            {formatPrice(i.price * i.qty)}
                          </span>
                        </li>
                      ))}
                    </ul>
                    <p className="text-[15px] font-bold text-[#0F1111] mt-2">
                      Total: {formatPrice(o.total)}
                    </p>
                    <p
                      className={`text-[13px] font-bold mt-1 ${
                        o.paymentMethod === 'coins' ? 'text-[#5B21B6]' : 'text-[#007600]'
                      }`}
                    >
                      {o.paymentMethod === 'coins'
                        ? `Pagado con ${formatCoins(o.totalCoins ?? 0)} monedas`
                        : 'Pago en efectivo al recibir'}
                    </p>
                    <p className="text-[13px] text-[#565959] mt-1">
                      Entrega en: <b>{o.address}</b>
                      {o.workerName && (
                        <>
                          {' '}
                          · Repartidor: <b>{o.workerName}</b>
                        </>
                      )}
                    </p>
                    <p className="text-[13px] font-bold text-[#007600] mt-1">
                      Tiempo estimado: {o.etaMinutes} minutos
                    </p>
                  </div>
                  <MiniMap x={o.mapX} y={o.mapY} height={220} />
                </div>
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
