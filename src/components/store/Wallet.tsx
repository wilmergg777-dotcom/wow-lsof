'use client'
// ============================================================
// MI BILLETERA — monedas internas de Violetero
// - Muestra el saldo de monedas del usuario
// - RECARGA: el usuario hace una transferencia real a la
//   cuenta/tarjeta del administrador y registra el ID de la
//   transferencia. La solicitud queda "pendiente de revisión"
//   y el administrador la aprueba desde su panel.
// - Historial de solicitudes de recarga
// ============================================================
import { useCallback, useEffect, useState } from 'react'
import {
  ArrowRightLeft,
  Check,
  Coins,
  Copy,
  CreditCard,
  Send,
  Wallet as WalletIcon,
} from 'lucide-react'
import { toast } from 'sonner'
import { useStore } from '@/lib/store'
import {
  api,
  TOPUP_STATUS,
  type PaymentMethod,
  type Settings,
  type TopUpRequest,
  type Wallet,
} from '@/lib/api'
import { formatCoins, formatPrice } from '@/lib/products'

export function WalletView() {
  const user = useStore((s) => s.user)
  const setUser = useStore((s) => s.setUser)

  const [wallet, setWallet] = useState<Wallet | null>(null)
  const [methods, setMethods] = useState<PaymentMethod[]>([])
  const [requests, setRequests] = useState<TopUpRequest[]>([])
  const [rate, setRate] = useState(100)
  const [loading, setLoading] = useState(true)
  const [sending, setSending] = useState(false)

  // Formulario de recarga
  const [methodId, setMethodId] = useState('')
  const [amount, setAmount] = useState('')
  const [transferId, setTransferId] = useState('')
  // Nombre provisional si es Invitado
  const [nameDraft, setNameDraft] = useState('')

  const isGuest = !user.name || user.name === 'Invitado'

  const loadAll = useCallback(() => {
    const nameParam = isGuest ? '' : `?name=${encodeURIComponent(user.name)}`
    Promise.all([
      api<Wallet>(`/api/wallet${nameParam ? nameParam : '?name='}`),
      api<PaymentMethod[]>('/api/payment-methods'),
      api<Settings>('/api/settings'),
      ...(isGuest ? [] : [api<TopUpRequest[]>(`/api/topups${nameParam}`)]),
    ])
      .then((res) => {
        setWallet(res[0] as Wallet)
        const ms = res[1] as PaymentMethod[]
        setMethods(ms)
        setRate((res[2] as Settings).coinRate || 100)
        if (!isGuest) setRequests(res[3] as TopUpRequest[])
        setMethodId((cur) => cur || (ms[0]?.id ?? ''))
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [isGuest, user.name])

  useEffect(() => {
    loadAll()
  }, [loadAll])

  const coinsPreview = parseFloat(amount) > 0 ? Math.round(parseFloat(amount) * rate) : 0

  const submitTopUp = async () => {
    const amountNum = parseFloat(amount)
    if (!methodId) {
      toast.error('Elige la cuenta donde hiciste la transferencia')
      return
    }
    if (!amountNum || amountNum <= 0) {
      toast.error('Escribe cuánto dinero enviaste')
      return
    }
    if (!transferId.trim()) {
      toast.error('Escribe el ID de la transferencia (aparece en tu app del banco)')
      return
    }
    setSending(true)
    try {
      await api('/api/topups', {
        method: 'POST',
        body: JSON.stringify({
          userName: user.name,
          methodName: methods.find((m) => m.id === methodId)?.label ?? '',
          amountCash: amountNum,
          transferId,
        }),
      })
      setAmount('')
      setTransferId('')
      loadAll()
      toast.success(
        'Solicitud enviada: queda pendiente hasta que el administrador revise tu transferencia'
      )
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSending(false)
    }
  }

  if (loading) return <p className="text-center py-16 text-[#565959]">Abriendo tu billetera…</p>

  return (
    <div className="p-4 max-w-[1100px] mx-auto flex flex-col gap-4">
      {/* Saldo */}
      <div
        className="rounded-lg p-6 text-white"
        style={{ background: 'linear-gradient(120deg, #5B21B6, #4C1D95)' }}
      >
        <div className="flex items-center justify-between flex-wrap gap-3">
          <div>
            <p className="text-[13px] text-white/80 flex items-center gap-1.5">
              <WalletIcon className="w-4 h-4" /> Mi billetera · {user.name}
            </p>
            <p className="text-[40px] font-bold leading-none mt-2 flex items-center gap-2">
              <Coins className="w-9 h-9" /> {formatCoins(wallet?.coins ?? 0)}
              <span className="text-[16px] font-bold text-white/80">monedas</span>
            </p>
            <p className="text-[13px] text-white/80 mt-1">
              Cambio actual: 1 $ = {rate} monedas · También puedes pagar en efectivo al recibir
            </p>
          </div>
          <div className="bg-white/10 border border-white/20 rounded-lg px-4 py-3 text-[13px]">
            <p className="font-bold">¿Cómo uso las monedas?</p>
            <p className="text-white/80 mt-1">
              Recarga con una transferencia real y paga tus compras con monedas. Las tiendas
              muestran los dos precios siempre.
            </p>
          </div>
        </div>
      </div>

      {isGuest && (
        <div className="bg-[#FEF3C7] border border-[#B45309]/30 rounded-lg p-5">
          <p className="text-[14px] font-bold text-[#B45309]">
            Pónle nombre a tu usuario para abrir tu billetera
          </p>
          <div className="flex gap-2 mt-3 max-w-md">
            <input
              value={nameDraft}
              onChange={(e) => setNameDraft(e.target.value)}
              placeholder="Ej: Luis"
              className="flex-1 border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
            />
            <button
              onClick={() => {
                const n = nameDraft.trim()
                if (!n) {
                  toast.error('Escribe tu nombre')
                  return
                }
                setUser({ name: n, role: user.role })
                toast.success(`Hola, ${n}. Ya puedes usar tu billetera`)
                setLoading(true)
                setTimeout(loadAll, 50)
              }}
              className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-6 cursor-pointer"
            >
              Guardar
            </button>
          </div>
        </div>
      )}

      {/* Recargar saldo */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
          <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
            <ArrowRightLeft className="w-5 h-5 text-[#5B21B6]" /> Recargar saldo (transferencia
            real → monedas)
          </h2>
          <p className="text-[13px] text-[#565959] mt-1 mb-4">
            Transfiere el dinero a la cuenta del administrador, luego registra aquí el ID de tu
            transferencia. Cuando se revise y apruebe, las monedas se acreditan solas.
          </p>

          {/* Cuentas donde enviar el dinero */}
          <h3 className="text-[13px] font-bold text-[#0F1111] mb-2">
            1. Transfiere a una de estas cuentas:
          </h3>
          {methods.length === 0 ? (
            <p className="text-[13px] text-[#565959] mb-4">
              El administrador todavía no configuró sus cuentas de cobro.
            </p>
          ) : (
            <div className="flex flex-col gap-2 mb-5">
              {methods.map((m) => (
                <label
                  key={m.id}
                  className={`flex items-start gap-3 border-2 rounded-lg p-3 cursor-pointer ${
                    methodId === m.id ? 'border-[#5B21B6] bg-[#f6f1fd]' : 'border-[#d5d9d9] hover:border-[#888c8c]'
                  }`}
                >
                  <input
                    type="radio"
                    name="method"
                    checked={methodId === m.id}
                    onChange={() => setMethodId(m.id)}
                    className="mt-1 accent-[#5B21B6]"
                  />
                  <CreditCard className="w-5 h-5 text-[#5B21B6] mt-0.5 shrink-0" />
                  <span className="flex-1 min-w-0 text-[13px]">
                    <span className="font-bold text-[#0F1111]">{m.label}</span>
                    <span className="block mt-0.5 text-[#0F1111] font-mono select-all">
                      {m.details}
                    </span>
                    <span className="block text-[#565959]">Titular: {m.holder}</span>
                    {m.instructions && (
                      <span className="block text-[#565959] mt-0.5">{m.instructions}</span>
                    )}
                  </span>
                  <button
                    onClick={(e) => {
                      e.preventDefault()
                      navigator.clipboard
                        ?.writeText(m.details)
                        .then(() => toast.success('Número copiado'))
                        .catch(() => {})
                    }}
                    aria-label={`Copiar número de ${m.label}`}
                    className="text-[#565959] hover:text-[#0F1111] cursor-pointer shrink-0 mt-0.5"
                  >
                    <Copy className="w-4 h-4" />
                  </button>
                </label>
              ))}
            </div>
          )}

          <h3 className="text-[13px] font-bold text-[#0F1111] mb-2">
            2. Registra tu transferencia:
          </h3>
          <label className="block text-[12px] font-bold text-[#0F1111] mb-1">
            ¿Cuánto dinero enviaste? ($)
          </label>
          <input
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            type="number"
            min="0.01"
            step="0.01"
            placeholder="Ej: 10.00"
            disabled={isGuest}
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-2 disabled:bg-[#f0f2f2]"
          />
          <p className="text-[13px] text-[#5B21B6] font-bold flex items-center gap-1 mb-3">
            <Coins className="w-4 h-4" />
            {coinsPreview > 0
              ? `Recibirás ${formatCoins(coinsPreview)} monedas`
              : `Equivale a monedas con el cambio 1 $ = ${rate}`}
          </p>
          <label className="block text-[12px] font-bold text-[#0F1111] mb-1">
            ID de la transferencia
          </label>
          <input
            value={transferId}
            onChange={(e) => setTransferId(e.target.value)}
            placeholder="Ej: TRF-20241231-00982"
            disabled={isGuest}
            className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-4 disabled:bg-[#f0f2f2]"
          />
          <button
            onClick={submitTopUp}
            disabled={sending || isGuest}
            className="w-full bg-[#FFD814] hover:bg-[#F7CA00] disabled:opacity-60 text-[#0F1111] text-[14px] font-bold rounded-full py-2.5 flex items-center justify-center gap-2 cursor-pointer"
          >
            <Send className="w-4 h-4" />
            {sending ? 'Enviando…' : 'Enviar solicitud de recarga'}
          </button>
        </section>

        {/* Historial */}
        <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
          <h2 className="text-[18px] font-bold text-[#0F1111] mb-1">Mis solicitudes de recarga</h2>
          <p className="text-[13px] text-[#565959] mb-4">
            Cada solicitud pasa a <b>pendiente de revisión</b> hasta que el administrador verifique
            la transferencia.
          </p>
          {requests.length === 0 ? (
            <div className="text-center py-8">
              <Coins className="w-12 h-12 text-[#ddd] mx-auto" strokeWidth={1.2} />
              <p className="text-[13px] text-[#565959] mt-3">
                Todavía no solicitaste recargas. Cuando lo hagas verás aquí su estado.
              </p>
            </div>
          ) : (
            <ul className="flex flex-col gap-2 max-h-[420px] overflow-y-auto">
              {requests.map((r) => {
                const st = TOPUP_STATUS[r.status]
                return (
                  <li key={r.id} className="border border-[#e3e6e6] rounded-lg p-3 text-[13px]">
                    <div className="flex items-center justify-between gap-2 flex-wrap">
                      <span className="font-bold text-[#0F1111]">
                        {formatPrice(r.amountCash)} → {formatCoins(r.coins)} monedas
                      </span>
                      <span
                        className="rounded-full px-3 py-1 font-bold text-[12px]"
                        style={{ color: st.color, backgroundColor: st.bg }}
                      >
                        {st.label}
                      </span>
                    </div>
                    <p className="text-[#565959] mt-1">
                      {r.methodName} · ID: <span className="font-mono">{r.transferId}</span>
                    </p>
                    <p className="text-[11px] text-[#8a8a8a] mt-0.5">
                      {new Date(r.createdAt).toLocaleString('es')}
                    </p>
                    {r.status === 'approved' && (
                      <p className="text-[#007600] font-bold mt-1 flex items-center gap-1">
                        <Check className="w-3.5 h-3.5" /> Monedas acreditadas en tu saldo
                      </p>
                    )}
                    {r.status === 'rejected' && r.adminNote && (
                      <p className="text-[#C7511F] mt-1">Nota del administrador: {r.adminNote}</p>
                    )}
                  </li>
                )
              })}
            </ul>
          )}
        </section>
      </div>
    </div>
  )
}
