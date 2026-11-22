'use client'
// ============================================================
// TRABAJO DE DOMICILIO: bolsa de ofertas para repartidores
// El repartidor elige una oferta y llena el formulario de
// postulación. El dueño de la mini tienda decide y el
// resultado llega por el mini correo interno.
// ============================================================
import { useEffect, useState } from 'react'
import { Briefcase, MapPin, Send } from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME } from '@/lib/store'
import { api, type JobOffer } from '@/lib/api'
import { formatPrice } from '@/lib/products'
import { StoreLogo } from './MiniStores'

const VEHICLES = ['Moto', 'Bicicleta', 'Auto', 'A pie']

export function JobsView() {
  const user = useStore((s) => s.user)
  const [offers, setOffers] = useState<JobOffer[]>([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState<JobOffer | null>(null)

  // Formulario de postulación
  const [fName, setFName] = useState(user.name)
  const [fPhone, setFPhone] = useState('')
  const [fEmail, setFEmail] = useState('')
  const [fVehicle, setFVehicle] = useState(VEHICLES[0])
  const [fMessage, setFMessage] = useState('')

  useEffect(() => {
    api<JobOffer[]>('/api/joboffers')
      .then(setOffers)
      .catch((e) => toast.error(e.message))
      .finally(() => setLoading(false))
  }, [])

  const apply = async () => {
    if (!selected) return
    if (!fName.trim() || !fPhone.trim() || !fEmail.trim()) {
      toast.error('Completa tu nombre, teléfono y correo en el formulario')
      return
    }
    try {
      await api('/api/applications', {
        method: 'POST',
        body: JSON.stringify({
          jobId: selected.id,
          applicantName: fName,
          phone: fPhone,
          email: fEmail,
          vehicle: fVehicle,
          message: fMessage,
        }),
      })
      toast.success(
        `¡Postulación enviada a "${selected.store.name}"! Te avisarán por el mini correo.`
      )
      setSelected(null)
      setFPhone('')
      setFEmail('')
      setFMessage('')
    } catch (e) {
      toast.error((e as Error).message)
    }
  }

  if (loading) return <p className="text-center py-16 text-[#565959]">Cargando ofertas…</p>

  return (
    <div className="p-4 max-w-[1100px] mx-auto">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6 mb-4">
        <h1 className="text-[28px] font-bold text-[#0F1111] flex items-center gap-2">
          <Briefcase className="w-7 h-7 text-[#5B21B6]" /> Trabajo de domicilio
        </h1>
        <p className="text-[14px] text-[#565959] mt-1">
          Las mini tiendas de {STORE_NAME} buscan repartidores. Postúlate y si el dueño te acepta
          recibirás una notificación en tu mini correo.
        </p>
      </div>

      {offers.length === 0 ? (
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-12 text-center">
          <Briefcase className="w-16 h-16 text-[#ddd] mx-auto" strokeWidth={1.2} />
          <p className="text-[16px] font-bold text-[#0F1111] mt-4">No hay ofertas abiertas</p>
          <p className="text-[14px] text-[#565959] mt-1">
            Vuelve más tarde: las mini tiendas publican cuando necesitan personal.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {offers.map((o) => (
            <div key={o.id} className="bg-white rounded-lg border border-[#e3e6e6] p-5">
              <div className="flex items-start gap-3">
                <StoreLogo store={o.store} size={44} />
                <div className="flex-1 min-w-0">
                  <h3 className="text-[17px] font-bold text-[#0F1111]">{o.title}</h3>
                  <p className="text-[12px] text-[#565959]">
                    {o.store.name} · de {o.store.ownerName}
                  </p>
                </div>
                <span className="bg-[#f7fafa] border border-[#d5d9d9] rounded-lg px-3 py-1.5 text-[14px] font-bold text-[#0F1111] shrink-0 text-center">
                  {formatPrice(o.payment)}
                  <span className="block text-[10px] font-normal text-[#565959]">por entrega</span>
                </span>
              </div>
              <p className="text-[13px] text-[#565959] mt-2 flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5" /> Zona: {o.zone}
              </p>
              {o.description && <p className="text-[13px] text-[#0F1111] mt-2">{o.description}</p>}
              <button
                onClick={() => setSelected(o)}
                className="mt-4 w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full py-2 cursor-pointer"
              >
                Postularme
              </button>
            </div>
          ))}
        </div>
      )}

      {/* Formulario de postulación (modal) */}
      {selected && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
          onClick={() => setSelected(null)}
        >
          <div
            className="bg-white rounded-lg max-w-lg w-full p-6 max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-[20px] font-bold text-[#0F1111]">Formulario de postulación</h2>
            <p className="text-[13px] text-[#565959] mt-1 mb-4">
              Oferta: <b>{selected.title}</b> en <b>{selected.store.name}</b> · Zona {selected.zone}
            </p>

            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Tu nombre</label>
            <input
              value={fName}
              onChange={(e) => setFName(e.target.value)}
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
            />
            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Teléfono</label>
            <input
              value={fPhone}
              onChange={(e) => setFPhone(e.target.value)}
              placeholder="Ej: +53 5555 5555"
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
            />
            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Correo</label>
            <input
              value={fEmail}
              onChange={(e) => setFEmail(e.target.value)}
              type="email"
              placeholder="tucorreo@ejemplo.com"
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
            />
            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
              Medio de transporte
            </label>
            <select
              value={fVehicle}
              onChange={(e) => setFVehicle(e.target.value)}
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] bg-white outline-none mb-3 cursor-pointer"
            >
              {VEHICLES.map((v) => (
                <option key={v}>{v}</option>
              ))}
            </select>
            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
              Mensaje para el dueño (opcional)
            </label>
            <textarea
              value={fMessage}
              onChange={(e) => setFMessage(e.target.value)}
              rows={2}
              placeholder="Cuéntale por qué eres buena opción"
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-4 resize-none"
            />

            <div className="flex gap-3">
              <button
                onClick={apply}
                className="flex-1 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full py-2.5 cursor-pointer flex items-center justify-center gap-2"
              >
                <Send className="w-4 h-4" /> Enviar postulación
              </button>
              <button
                onClick={() => setSelected(null)}
                className="px-6 border border-[#d5d9d9] rounded-full text-[14px] hover:bg-[#f7fafa] cursor-pointer"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
