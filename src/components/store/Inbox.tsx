'use client'
// ============================================================
// MINI CORREO INTERNO DE VIOLETERO
// Bandeja de notificaciones. Al abrir un mensaje de pedido se
// ve el detalle de la compra: artículos, total, estado y el
// tiempo estimado de entrega con el mini mapa.
// ============================================================
import { useCallback, useEffect, useRef, useState } from 'react'
import { Bell, Briefcase, Coins, MailOpen, Package, Store } from 'lucide-react'
import { toast } from 'sonner'
import { useStore } from '@/lib/store'
import { api, ORDER_STATUS, type Notification, type Order } from '@/lib/api'
import { formatPrice } from '@/lib/products'
import { MiniMap } from './MiniMap'

export function InboxView() {
  const user = useStore((s) => s.user)
  const [messages, setMessages] = useState<Notification[]>([])
  const [selected, setSelected] = useState<Notification | null>(null)
  const [order, setOrder] = useState<Order | null>(null)
  const [loading, setLoading] = useState(true)
  const timer = useRef<ReturnType<typeof setInterval> | null>(null)

  const load = useCallback(() => {
    api<Notification[]>(`/api/notifications?toName=${encodeURIComponent(user.name)}`)
      .then(setMessages)
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [user.name])

  useEffect(() => {
    load()
    timer.current = setInterval(load, 7000) // revisa el correo cada 7 segundos
    return () => {
      if (timer.current) clearInterval(timer.current)
    }
  }, [load])

  const openMessage = async (n: Notification) => {
    setSelected(n)
    setOrder(null)
    if (!n.read) {
      api(`/api/notifications/${n.id}`, { method: 'PATCH', body: JSON.stringify({ read: true }) })
        .then(load)
        .catch(() => {})
    }
    if (n.orderId) {
      try {
        // El pedido se busca entre los pedidos del comprador actual
        const list = await api<Order[]>(`/api/orders?buyer=${encodeURIComponent(user.name)}`)
        setOrder(list.find((o) => o.id === n.orderId) || null)
      } catch {
        setOrder(null)
      }
    }
  }

  if (loading) return <p className="text-center py-16 text-[#565959]">Abriendo el mini correo…</p>

  const unread = messages.filter((m) => !m.read).length

  return (
    <div className="p-4 max-w-[1000px] mx-auto">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6 mb-4 flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-[28px] font-bold text-[#0F1111] flex items-center gap-2">
            <MailOpen className="w-7 h-7 text-[#5B21B6]" /> Mini correo
          </h1>
          <p className="text-[14px] text-[#565959] mt-1">
            Las notificaciones de {user.name}: pedidos, respuestas de trabajo y noticias de tus
            tiendas.
          </p>
        </div>
        <span className="bg-[#5B21B6]/10 text-[#5B21B6] text-[13px] font-bold rounded-full px-4 py-2">
          {unread > 0 ? `${unread} sin leer` : 'Todo leído'}
        </span>
      </div>

      {messages.length === 0 ? (
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-12 text-center">
          <Bell className="w-16 h-16 text-[#ddd] mx-auto" strokeWidth={1.2} />
          <p className="text-[16px] font-bold text-[#0F1111] mt-4">Tu mini correo está vacío</p>
          <p className="text-[14px] text-[#565959] mt-1">
            Cuando compres o postules a un trabajo, aquí recibirás las novedades.
          </p>
        </div>
      ) : (
        <div className="bg-white rounded-lg border border-[#e3e6e6] divide-y divide-[#e3e6e6]">
          {messages.map((m) => (
            <button
              key={m.id}
              onClick={() => openMessage(m)}
              className={`w-full text-left px-5 py-4 hover:bg-[#f7fafa] cursor-pointer flex gap-3 ${
                selected?.id === m.id ? 'bg-[#f7fafa]' : ''
              }`}
            >
              <span
                className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${
                  m.kind === 'pedido'
                    ? 'bg-[#007600]/10 text-[#007600]'
                    : m.kind === 'trabajo'
                      ? 'bg-[#5B21B6]/10 text-[#5B21B6]'
                      : m.kind === 'recarga'
                        ? 'bg-[#B45309]/10 text-[#B45309]'
                        : 'bg-[#f0f2f2] text-[#565959]'
                }`}
              >
                {m.kind === 'pedido' ? (
                  <Package className="w-5 h-5" />
                ) : m.kind === 'trabajo' ? (
                  <Briefcase className="w-5 h-5" />
                ) : m.kind === 'recarga' ? (
                  <Coins className="w-5 h-5" />
                ) : (
                  <Store className="w-5 h-5" />
                )}
              </span>
              <span className="flex-1 min-w-0">
                <span className="flex items-center gap-2">
                  <span
                    className={`text-[15px] ${m.read ? 'font-normal text-[#0F1111]' : 'font-bold text-[#0F1111]'}`}
                  >
                    {m.title}
                  </span>
                  {!m.read && <span className="w-2 h-2 rounded-full bg-[#C7511F] shrink-0" />}
                </span>
                <span className="block text-[13px] text-[#565959] line-clamp-1 mt-0.5">
                  {m.body}
                </span>
                <span className="block text-[11px] text-[#8a8a8a] mt-1">
                  {new Date(m.createdAt).toLocaleString('es')}
                </span>
              </span>
            </button>
          ))}
        </div>
      )}

      {/* Detalle del mensaje (modal) */}
      {selected && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
          onClick={() => setSelected(null)}
        >
          <div
            className="bg-white rounded-lg max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between gap-3">
              <h2 className="text-[20px] font-bold text-[#0F1111]">{selected.title}</h2>
              <button
                onClick={() => setSelected(null)}
                className="text-[13px] border border-[#d5d9d9] rounded-full px-4 py-1.5 hover:bg-[#f7fafa] cursor-pointer shrink-0"
              >
                Cerrar
              </button>
            </div>
            <p className="text-[14px] text-[#565959] mt-1">
              {new Date(selected.createdAt).toLocaleString('es')}
            </p>
            <p className="text-[14px] text-[#0F1111] mt-4 leading-relaxed">{selected.body}</p>

            {/* Detalle del pedido asociado */}
            {selected.orderId && (
              <div className="mt-5 border-t border-[#e3e6e6] pt-4">
                <h3 className="text-[16px] font-bold text-[#0F1111] mb-3">
                  Resumen de tu compra
                </h3>
                {!order ? (
                  <p className="text-[13px] text-[#565959]">Cargando detalles del pedido…</p>
                ) : (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <p className="text-[13px] font-bold text-[#0F1111] mb-1">
                        Pedido {order.code}
                      </p>
                      <ul className="text-[13px] divide-y divide-[#e3e6e6] border-y border-[#e3e6e6]">
                        {(JSON.parse(order.items) as { name: string; price: number; qty: number; store: string }[]).map(
                          (i, idx) => (
                            <li key={idx} className="py-1.5 flex justify-between gap-2">
                              <span className="text-[#0F1111]">
                                {i.qty}× {i.name}
                                <span className="block text-[11px] text-[#565959]">
                                  {i.store}
                                </span>
                              </span>
                              <span className="font-bold text-[#0F1111]">
                                {formatPrice(i.price * i.qty)}
                              </span>
                            </li>
                          )
                        )}
                      </ul>
                      <p className="text-[15px] font-bold text-[#0F1111] mt-2">
                        Total: {formatPrice(order.total)}
                      </p>
                      <p className="text-[13px] text-[#0F1111] mt-1">
                        Entrega en: <b>{order.address}</b>
                      </p>
                      <p
                        className="text-[13px] font-bold mt-1"
                        style={{ color: ORDER_STATUS[order.status].color }}
                      >
                        {ORDER_STATUS[order.status].label} · Tiempo estimado:{' '}
                        {order.etaMinutes} minutos
                      </p>
                    </div>
                    <div>
                      <MiniMap x={order.mapX} y={order.mapY} height={200} label="Punto de entrega" />
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

// Contador de notificaciones sin leer (para la campana del menú)
export function useUnreadCount() {
  const user = useStore((s) => s.user)
  const view = useStore((s) => s.view)
  const [count, setCount] = useState(0)

  const load = useCallback(() => {
    api<Notification[]>(`/api/notifications?toName=${encodeURIComponent(user.name)}`)
      .then((list) => setCount(list.filter((n) => !n.read).length))
      .catch(() => {})
  }, [user.name])

  useEffect(() => {
    load()
    const t = setInterval(load, 7000)
    return () => clearInterval(t)
  }, [load, view])

  return count
}
