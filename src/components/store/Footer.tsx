'use client'
// ============================================================
// PIE DE PÁGINA ESTILO AMAZON
// ============================================================
import { useStore, STORE_NAME } from '@/lib/store'

const COLUMNS: { title: string; links: string[] }[] = [
  {
    title: 'Conócenos',
    links: ['Trabajar con nosotros', 'Información corporativa', 'Sostenibilidad', 'Comunidad', 'Prensa'],
  },
  {
    title: 'Gana dinero con nosotros',
    links: ['Vender en ' + STORE_NAME, 'Programa de afiliados', 'Anuncia tus productos', 'Publica tu libro', 'Vende internacionalmente'],
  },
  {
    title: 'Métodos de pago',
    links: ['Tarjetas de regalo', 'Recarga tu saldo', 'Pagos a plazos', 'Programas de pago', 'Monedero digital'],
  },
  {
    title: '¿Necesitas ayuda?',
    links: ['Rastrea tus pedidos', 'Envíos y entregas', 'Devoluciones y reemplazos', 'Atención al cliente', 'Ayuda con la cuenta'],
  },
]

export function Footer() {
  const goHome = useStore((s) => s.goHome)
  const openView = useStore((s) => s.openView)
  const scrollTop = () => window.scrollTo({ top: 0, behavior: 'smooth' })

  // Enlaces del pie que abren secciones reales de la tienda
  const FOOTER_ACTIONS: Record<string, 'wallet'> = {
    'Recarga tu saldo': 'wallet',
    'Monedero digital': 'wallet',
  }

  const handleLink = (label: string) => {
    const view = FOOTER_ACTIONS[label]
    if (view) {
      openView(view)
      window.scrollTo({ top: 0 })
    }
  }

  return (
    <footer className="mt-auto" style={{ fontFamily: 'Arial, Helvetica, sans-serif' }}>
      {/* Volver arriba */}
      <button
        onClick={scrollTop}
        className="w-full bg-[#37475A] hover:bg-[#485769] text-white text-[13px] py-4 cursor-pointer"
      >
        Volver arriba
      </button>

      {/* Columnas */}
      <div className="bg-[#232F3E] text-white">
        <div className="max-w-[1200px] mx-auto px-6 py-10 grid grid-cols-2 md:grid-cols-4 gap-8">
          {COLUMNS.map((col) => (
            <div key={col.title}>
              <h3 className="font-bold text-[16px] mb-2">{col.title}</h3>
              <ul className="space-y-1.5">
                {col.links.map((l) => (
                  <li key={l}>
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault()
                        handleLink(l)
                      }}
                      className={`text-[13px] text-[#DDD] hover:underline ${
                        FOOTER_ACTIONS[l] ? 'font-bold' : ''
                      }`}
                    >
                      {l}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="border-t border-[#3a4553]">
          <div className="max-w-[1200px] mx-auto px-6 py-8 flex flex-wrap items-center justify-center gap-6">
            <button onClick={goHome} className="cursor-pointer">
              <span className="text-white font-bold text-[22px] tracking-tight leading-none">
                {STORE_NAME}
              </span>
            </button>
            <span className="border border-[#485769] rounded px-3 py-1.5 text-[12px] text-[#DDD]">
              Español
            </span>
            <span className="border border-[#485769] rounded px-3 py-1.5 text-[12px] text-[#DDD]">
              CUP - Peso cubano
            </span>
            <span className="border border-[#485769] rounded px-3 py-1.5 text-[12px] text-[#DDD]">
              Cuba
            </span>
          </div>
        </div>
      </div>

      {/* Franja final */}
      <div className="bg-[#131A22] text-[#DDD] text-[11px] text-center py-6 px-4">
        <p className="mb-1">
          Condiciones de uso · Venta · Aviso de privacidad · Cookies · Publicidad basada en
          intereses
        </p>
        <p>© 2026, {STORE_NAME.charAt(0).toUpperCase() + STORE_NAME.slice(1)}.com, Inc. o sus filiales — Mini tiendas y entregas a domicilio</p>
      </div>
    </footer>
  )
}
