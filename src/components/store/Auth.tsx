'use client'
// ============================================================
// REGISTRO E INICIO DE SESIÓN DE VIOLETERO
// Como en Amazon: mirar ofertas y mini tiendas es libre, pero
// para comprar hay que tener cuenta y estar logueado.
// Al registrarse eliges: Comprador o Mensajero (turbo).
// ============================================================
import { useState } from 'react'
import { LockKeyhole, ShieldCheck, UserRound } from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME, type Role } from '@/lib/store'
import { api } from '@/lib/api'

export function AuthView() {
  const setUser = useStore((s) => s.setUser)
  const goHome = useStore((s) => s.goHome)
  const [tab, setTab] = useState<'login' | 'register'>('login')

  // Formulario común
  const [name, setName] = useState('')
  const [pw, setPw] = useState('')
  const [pw2, setPw2] = useState('')
  const [role, setRole] = useState<'comprador' | 'repartidor'>('comprador')
  const [busy, setBusy] = useState(false)

  const finish = (u: { name: string; role: Role }, msg: string) => {
    setUser({ name: u.name, role: u.role })
    toast.success(msg)
    goHome()
  }

  const login = async () => {
    if (!name.trim() || !pw) {
      toast.error('Escribe tu nombre y tu contraseña')
      return
    }
    setBusy(true)
    try {
      const u = await api<{ name: string; role: Role }>('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ name, password: pw }),
      })
      finish(u as { name: string; role: Role }, `¡Hola de nuevo, ${u.name}!`)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setBusy(false)
    }
  }

  const register = async () => {
    if (name.trim().length < 3) {
      toast.error('El nombre debe tener al menos 3 caracteres')
      return
    }
    if (pw.length < 4) {
      toast.error('La contraseña debe tener al menos 4 caracteres')
      return
    }
    if (pw !== pw2) {
      toast.error('Las dos contraseñas no coinciden')
      return
    }
    setBusy(true)
    try {
      const u = await api<{ name: string; role: Role }>('/api/auth/register', {
        method: 'POST',
        body: JSON.stringify({ name, password: pw, role }),
      })
      finish(
        u as { name: string; role: Role },
        `¡Cuenta creada! Bienvenido a ${STORE_NAME}, ${u.name}`
      )
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="p-4 max-w-md mx-auto">
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h1 className="text-[24px] font-bold text-[#0F1111] text-center">
          {tab === 'login' ? 'Iniciar sesión' : 'Crear tu cuenta'}
        </h1>
        <p className="text-[13px] text-[#565959] text-center mt-1 mb-4">
          Mirar {STORE_NAME} es gratis. Con cuenta puedes comprar, recargar y más.
        </p>

        {/* Pestañas */}
        <div className="grid grid-cols-2 gap-2 mb-4">
          <button
            onClick={() => setTab('login')}
            className={`rounded-full py-2 text-[13px] font-bold cursor-pointer ${
              tab === 'login'
                ? 'bg-[#5B21B6] text-white'
                : 'border border-[#d5d9d9] text-[#0F1111] hover:bg-[#f7fafa]'
            }`}
          >
            Iniciar sesión
          </button>
          <button
            onClick={() => setTab('register')}
            className={`rounded-full py-2 text-[13px] font-bold cursor-pointer ${
              tab === 'register'
                ? 'bg-[#5B21B6] text-white'
                : 'border border-[#d5d9d9] text-[#0F1111] hover:bg-[#f7fafa]'
            }`}
          >
            Registrarme
          </button>
        </div>

        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
          Nombre de usuario
        </label>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Ej: MariaGP"
          aria-label="Nombre de usuario"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
        />

        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Contraseña</label>
        <input
          value={pw}
          onChange={(e) => setPw(e.target.value)}
          type="password"
          placeholder={tab === 'register' ? 'Mínimo 4 caracteres' : 'Tu contraseña'}
          aria-label="Contraseña"
          onKeyDown={(e) => {
            if (e.key === 'Enter' && tab === 'login') login()
          }}
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
        />

        {tab === 'register' && (
          <>
            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
              Repite la contraseña
            </label>
            <input
              value={pw2}
              onChange={(e) => setPw2(e.target.value)}
              type="password"
              aria-label="Repetir contraseña"
              className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-4"
            />

            <p className="text-[13px] font-bold text-[#0F1111] mb-2">
              ¿Qué vas a hacer en {STORE_NAME}?
            </p>
            <div className="flex flex-col gap-2 mb-4">
              <button
                onClick={() => setRole('comprador')}
                className={`text-left border-2 rounded-lg p-3 cursor-pointer ${
                  role === 'comprador'
                    ? 'border-[#5B21B6] bg-[#f6f1fd]'
                    : 'border-[#d5d9d9] hover:border-[#888c8c]'
                }`}
              >
                <span className="flex items-center gap-2 text-[14px] font-bold text-[#0F1111]">
                  <UserRound className="w-4.5 h-4.5 text-[#5B21B6]" /> Comprador
                </span>
                <span className="block text-[12px] text-[#565959] mt-0.5">
                  Compro en la web y en las mini tiendas, abrir mi propia mini tienda si quiero.
                </span>
              </button>
              <button
                onClick={() => setRole('repartidor')}
                className={`text-left border-2 rounded-lg p-3 cursor-pointer ${
                  role === 'repartidor'
                    ? 'border-[#5B21B6] bg-[#f6f1fd]'
                    : 'border-[#d5d9d9] hover:border-[#888c8c]'
                }`}
              >
                <span className="flex items-center gap-2 text-[14px] font-bold text-[#0F1111]">
                  <LockKeyhole className="w-4.5 h-4.5 text-[#5B21B6]" /> Mensajero (turbo)
                </span>
                <span className="block text-[12px] text-[#565959] mt-0.5">
                  Hacer domicilios: coger pedidos turbo públicos y ganar por cada entrega.
                </span>
              </button>
            </div>
          </>
        )}

        <button
          onClick={tab === 'login' ? login : register}
          disabled={busy}
          className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 cursor-pointer disabled:opacity-60"
        >
          {busy ? 'Un momento…' : tab === 'login' ? 'Entrar' : 'Crear mi cuenta'}
        </button>

        <p className="text-[12px] text-[#565959] mt-4 flex items-start gap-1.5">
          <ShieldCheck className="w-4 h-4 text-[#007600] shrink-0 mt-0.5" />
          Tu contraseña se guarda encriptada: nadie puede leerla, ni siquiera los administradores.
        </p>
      </div>
    </div>
  )
}
