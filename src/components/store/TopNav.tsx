'use client'
// ============================================================
// BARRA SUPERIOR + SUB-NAVEGACIÓN (estilo Violetero)
// Incluye: mini correo, selector de rol y accesos a mini tiendas
// ============================================================
import { useState, useSyncExternalStore } from 'react'
import {
  MapPin,
  Menu,
  Search,
  ShoppingCart,
  ChevronDown,
  MailOpen,
  UserRound,
} from 'lucide-react'
import { useStore, STORE_NAME, ROLE_LABELS, type Role } from '@/lib/store'
import { CATEGORIES } from '@/lib/products'
import { useUnreadCount } from './Inbox'

// Paleta violeta de la marca
const VIOLET_TOP = '#5B21B6'
const VIOLET_SUB = '#4C1D95'

// Logotipo: texto + sonrisa con flecha (estilo amazon)
function Logo({ onClick, small = false }: { onClick: () => void; small?: boolean }) {
  return (
    <button
      onClick={onClick}
      className="flex flex-col items-start leading-none px-2 py-1 rounded hover:outline hover:outline-1 hover:outline-white/70 cursor-pointer"
      aria-label="Ir a la página principal"
    >
      <span
        className={`text-white font-bold tracking-tight ${small ? 'text-xl' : 'text-[28px]'}`}
        style={{ fontFamily: 'Arial, Helvetica, sans-serif', letterSpacing: '-0.05em' }}
      >
        {STORE_NAME.toLowerCase()}
      </span>
      <svg
        viewBox="0 0 100 16"
        className={`-mt-1 ${small ? 'w-14' : 'w-[86px]'}`}
        aria-hidden="true"
      >
        <path
          d="M2 4 C 30 14, 72 14, 90 6"
          stroke="white"
          strokeWidth="3.2"
          fill="none"
          strokeLinecap="round"
        />
        <path d="M84 1 L 95 6 L 82 10 Z" fill="white" />
      </svg>
    </button>
  )
}

function USFlag() {
  return (
    <svg viewBox="0 0 20 14" className="w-6 h-4 rounded-[2px] shadow-sm" aria-hidden="true">
      <rect width="20" height="14" fill="#B22234" />
      {[2, 4, 6, 8, 10, 12].map((y) => (
        <rect key={y} y={y} width="20" height="1" fill="white" />
      ))}
      <rect width="9" height="7" fill="#3C3B6E" />
      {[1.5, 3.5, 5.5].map((x) =>
        [1.5, 3.5, 5.5].map((y) => (
          <circle key={`${x}-${y}`} cx={x + 1} cy={y + 0.8} r="0.55" fill="white" />
        ))
      )}
    </svg>
  )
}

function NavBlock({
  top,
  bottom,
  onClick,
}: {
  top: string
  bottom: string
  onClick?: () => void
}) {
  return (
    <button
      onClick={onClick}
      className="hidden md:flex flex-col items-start px-2 py-1 rounded hover:outline hover:outline-1 hover:outline-white/70 cursor-pointer text-white leading-tight"
    >
      <span className="text-[11px]">{top}</span>
      <span className="text-[13px] font-bold flex items-center gap-0.5">{bottom}</span>
    </button>
  )
}

export function TopNav() {
  const cart = useStore((s) => s.cart)
  const user = useStore((s) => s.user)
  const setUser = useStore((s) => s.setUser)
  const openSearch = useStore((s) => s.openSearch)
  const goHome = useStore((s) => s.goHome)
  const openCart = useStore((s) => s.openCart)
  const openView = useStore((s) => s.openView)
  const searchCategory = useStore((s) => s.searchCategory)
  const setSearchCategory = useStore((s) => s.setSearchCategory)

  const [query, setQuery] = useState('')
  const [nameOpen, setNameOpen] = useState(false)
  const [nameDraft, setNameDraft] = useState(user.name)
  // Detecta si ya montamos en el cliente (evita desajuste de hidratación con el carrito guardado)
  const mounted = useSyncExternalStore(
    () => () => {},
    () => true,
    () => false
  )
  const unread = useUnreadCount()

  const cartCount = cart.reduce((acc, i) => acc + i.qty, 0)

  const doSearch = () => openSearch(query)

  return (
    <header
      className="sticky top-0 z-40 shadow-md"
      style={{ fontFamily: 'Arial, Helvetica, sans-serif', backgroundColor: VIOLET_TOP }}
    >
      <div className="flex items-center gap-2 px-3 py-2 max-w-[1600px] mx-auto">
        <Logo onClick={goHome} />

        {/* Enviar a */}
        <button className="hidden lg:flex flex-col items-start px-2 py-1 rounded hover:outline hover:outline-1 hover:outline-white/70 text-white leading-tight cursor-pointer">
          <span className="text-[11px]">Enviar a</span>
          <span className="text-[13px] font-bold flex items-center gap-1">
            <MapPin className="w-3.5 h-3.5" /> Cuba
          </span>
        </button>

        {/* Buscador (pastilla blanca) */}
        <form
          className="flex-1 min-w-0"
          onSubmit={(e) => {
            e.preventDefault()
            doSearch()
          }}
        >
          <div className="flex items-center bg-white rounded-full h-10 overflow-hidden">
            <select
              value={searchCategory}
              onChange={(e) => setSearchCategory(e.target.value)}
              className="hidden sm:block pl-4 pr-1 py-1.5 text-[12px] font-semibold text-[#444] bg-transparent outline-none cursor-pointer max-w-[130px] shrink-0"
              aria-label="Departamento"
            >
              <option value="Todos">Todos</option>
              {CATEGORIES.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
            <span className="hidden sm:block h-6 w-px bg-gray-300 shrink-0" aria-hidden="true" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder={`Buscar en ${STORE_NAME}`}
              className="flex-1 min-w-0 px-3 text-[14px] text-[#0F1111] outline-none placeholder:text-[#8a8a8a]"
              aria-label="Buscar productos"
            />
            <button
              type="submit"
              className="px-4 h-full flex items-center justify-center hover:bg-gray-100 cursor-pointer"
              aria-label="Buscar"
            >
              <Search className="w-5 h-5 text-[#333]" strokeWidth={2.4} />
            </button>
          </div>
        </form>

        {/* Idioma */}
        <button className="hidden xl:flex items-center gap-1.5 px-2 py-1 rounded hover:outline hover:outline-1 hover:outline-white/70 text-white text-[13px] font-bold cursor-pointer">
          <USFlag /> ES <ChevronDown className="w-3 h-3" />
        </button>

        {/* Identidad: cuenta del usuario (invitado mira, logueado compra) */}
        <div className="relative hidden md:block">
          <button
            onClick={() => {
              setNameDraft(user.name)
              setNameOpen((v) => !v)
            }}
            className="flex flex-col items-start px-2 py-1 rounded hover:outline hover:outline-1 hover:outline-white/70 cursor-pointer text-white leading-tight"
          >
            <span className="text-[11px]">Hola, {user.name}</span>
            <span className="text-[13px] font-bold flex items-center gap-0.5">
              <UserRound className="w-3.5 h-3.5" />{' '}
              {user.name === 'Invitado' ? 'Entrar' : ROLE_LABELS[user.role]}{' '}
              <ChevronDown className="w-3 h-3" />
            </span>
          </button>

          {/* Panel de la cuenta */}
          {nameOpen && user.name === 'Invitado' && (
            <div className="absolute right-0 top-full mt-1 w-72 bg-white rounded-lg shadow-xl border border-[#d5d9d9] p-4 text-[#0F1111] z-50">
              <p className="text-[14px] font-bold">¿Ya tienes cuenta?</p>
              <p className="text-[12px] text-[#565959] mt-1 mb-3">
                Puedes mirar todo sin cuenta, pero para comprar y usar el carrito necesitas
                iniciar sesión.
              </p>
              <button
                onClick={() => {
                  setNameOpen(false)
                  openView('login')
                }}
                className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full py-2 cursor-pointer mb-2"
              >
                Iniciar sesión
              </button>
              <button
                onClick={() => {
                  setNameOpen(false)
                  openView('login')
                }}
                className="w-full border border-[#d5d9d9] hover:bg-[#f7fafa] text-[#0F1111] text-[13px] font-bold rounded-full py-2 cursor-pointer"
              >
                Crear cuenta nueva
              </button>
            </div>
          )}
          {nameOpen && user.name !== 'Invitado' && (
            <div className="absolute right-0 top-full mt-1 w-64 bg-white rounded-lg shadow-xl border border-[#d5d9d9] p-4 text-[#0F1111] z-50">
              <p className="text-[14px] font-bold">{user.name}</p>
              <p className="text-[12px] text-[#565959] mt-0.5 mb-3">
                Cuenta de {ROLE_LABELS[user.role].toLowerCase()} de {STORE_NAME}
              </p>
              <button
                onClick={() => {
                  setUser({ name: 'Invitado', role: 'comprador' })
                  setNameOpen(false)
                  goHome()
                  toastIdentity()
                }}
                className="w-full border border-[#d5d9d9] hover:bg-[#f7fafa] text-[#0F1111] text-[13px] font-bold rounded-full py-2 cursor-pointer"
              >
                Cerrar sesión
              </button>
              <p className="text-[11px] text-[#565959] mt-2">
                Tu carrito se guarda aunque cierres sesión.
              </p>
            </div>
          )}
        </div>

        <NavBlock top="Devoluciones" bottom="y pedidos" />

        {/* Mini correo interno */}
        <button
          onClick={() => openView('inbox')}
          className="relative flex items-center px-2 py-1 rounded hover:outline hover:outline-1 hover:outline-white/70 cursor-pointer text-white"
          aria-label="Abrir mini correo"
        >
          <span className="relative">
            <MailOpen className="w-6 h-6" strokeWidth={1.8} />
            {mounted && unread > 0 && (
              <span className="absolute -top-1.5 -right-1.5 bg-[#FFD814] text-[#0F1111] text-[11px] font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">
                {unread}
              </span>
            )}
          </span>
          <span className="hidden xl:inline text-[13px] font-bold ml-1">Correo</span>
        </button>

        {/* Carrito */}
        <button
          onClick={openCart}
          className="flex items-end gap-0.5 px-2 py-1 rounded hover:outline hover:outline-1 hover:outline-white/70 cursor-pointer text-white"
          aria-label="Abrir carrito"
        >
          <span className="relative">
            <ShoppingCart className="w-8 h-8" strokeWidth={1.8} />
            {mounted && cartCount > 0 && (
              <span className="absolute -top-1.5 left-4 bg-white text-[#5B21B6] text-[12px] font-bold rounded-full min-w-[20px] h-5 flex items-center justify-center px-1 border border-[#5B21B6]/40">
                {cartCount}
              </span>
            )}
          </span>
          <span className="hidden sm:inline text-[13px] font-bold mb-1.5">Carrito</span>
        </button>
      </div>
    </header>
  )
}

function toastIdentity() {
  // Pequeño aviso de confirmación (importado aquí para evitar ciclos)
  import('sonner').then(({ toast }) => toast.success('Identidad actualizada'))
}

const SUB_LINKS: { label: string; view?: 'ministores' | 'jobs' | 'orders' | 'wallet' }[] = [
  { label: 'Prime Video' },
  { label: 'Servicio al Cliente' },
  { label: 'Mini Tiendas', view: 'ministores' },
  { label: 'Trabajo de Domicilio', view: 'jobs' },
  { label: 'Mis Pedidos', view: 'orders' },
  { label: 'Mi Billetera', view: 'wallet' },
  { label: 'Tarjetas de Regalo' },
]

export function SubNav() {
  const openView = useStore((s) => s.openView)
  const openCategory = useStore((s) => s.openCategory)
  const user = useStore((s) => s.user)

  // Enlaces extra según la cuenta (el rol viene del registro/login)
  const roleLinks: { label: string; view: Parameters<typeof openView>[0] }[] = []
  if (user.name !== 'Invitado')
    roleLinks.push({ label: 'Mi Mini Tienda', view: 'manage-store' })
  if (user.role === 'repartidor') roleLinks.push({ label: 'Entregas', view: 'deliveries' })
  if (user.role === 'administrador') roleLinks.push({ label: 'Administración', view: 'admin' })

  return (
    <nav
      className="text-white px-3 py-1.5"
      style={{ fontFamily: 'Arial, Helvetica, sans-serif', backgroundColor: VIOLET_SUB }}
    >
      <div className="flex items-center gap-1 max-w-[1600px] mx-auto overflow-x-auto">
        <button
          onClick={() => openCategory('Todos')}
          className="flex items-center gap-1.5 px-2 py-1.5 rounded hover:outline hover:outline-1 hover:outline-white/70 text-[14px] font-bold cursor-pointer shrink-0"
        >
          <Menu className="w-5 h-5" /> Todo
        </button>
        {SUB_LINKS.map((l) => (
          <button
            key={l.label}
            onClick={() => (l.view ? openView(l.view) : undefined)}
            className="px-2 py-1.5 rounded hover:outline hover:outline-1 hover:outline-white/70 text-[14px] cursor-pointer shrink-0 whitespace-nowrap"
          >
            {l.label}
          </button>
        ))}
        {roleLinks.map((l) => (
          <button
            key={l.label}
            onClick={() => openView(l.view)}
            className="px-2 py-1.5 rounded hover:outline hover:outline-1 hover:outline-white/70 text-[14px] font-bold cursor-pointer shrink-0 whitespace-nowrap bg-white/15 rounded-lg"
          >
            {l.label}
          </button>
        ))}
        <span className="hidden md:block ml-auto pl-4 pr-2 text-[14px] font-bold whitespace-nowrap">
          Mini tiendas con entrega a domicilio en toda la ciudad
        </span>
      </div>
    </nav>
  )
}
