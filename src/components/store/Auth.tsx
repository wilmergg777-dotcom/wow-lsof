'use client'
// ============================================================
// REGISTRO E INICIO DE SESIÓN DE VIOLETERO
// Como en Amazon: mirar ofertas y mini tiendas es libre, pero
// para comprar hay que tener cuenta y estar logueado.
// Al registrarse eliges: Comprador o Mensajero (turbo).
// Incluye el flujo "¿Olvidaste tu contraseña?" en 3 pasos:
// 1) identificas tu cuenta (nombre, correo o teléfono)
// 2) escribes el código de 6 dígitos (SMS -> Telegram si no llega)
// 3) pones la contraseña nueva
// ============================================================
import { useState } from 'react'
import { ArrowLeft, KeyRound, LockKeyhole, Mail, MessageSquareText, Send, ShieldCheck, UserRound } from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME, type Role } from '@/lib/store'
import { api } from '@/lib/api'

// Respuesta del paso 1 del restablecimiento
type ForgotResponse = {
  ok: boolean
  message: string
  channel: string | null
  channelLabel: string | null
  target: string
  note: string
  demo: boolean
  demoCode?: string
  needsAdminHelp?: boolean
  fallbackHint: string
}

export function AuthView() {
  const setUser = useStore((s) => s.setUser)
  const goHome = useStore((s) => s.goHome)
  const [tab, setTab] = useState<'login' | 'register' | 'forgot'>('login')

  // Formulario común
  const [name, setName] = useState('')
  const [pw, setPw] = useState('')
  const [pw2, setPw2] = useState('')
  const [role, setRole] = useState<'comprador' | 'repartidor'>('comprador')
  const [busy, setBusy] = useState(false)

  // Restablecimiento de contraseña (3 pasos)
  const [fpStep, setFpStep] = useState(1)
  const [fpIdentifier, setFpIdentifier] = useState('')
  const [fpInfo, setFpInfo] = useState<ForgotResponse | null>(null)
  const [fpCode, setFpCode] = useState('')
  const [fpToken, setFpToken] = useState('')
  const [fpPw, setFpPw] = useState('')
  const [fpPw2, setFpPw2] = useState('')

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
    if (pw.length < 6) {
      toast.error('La contraseña debe tener al menos 6 caracteres')
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

  // ---------- Restablecimiento ----------
  const askCode = async () => {
    if (!fpIdentifier.trim()) {
      toast.error('Escribe tu nombre, tu correo o tu teléfono')
      return
    }
    setBusy(true)
    try {
      const r = await api<ForgotResponse>('/api/auth/forgot', {
        method: 'POST',
        body: JSON.stringify({ identifier: fpIdentifier.trim() }),
      })
      setFpInfo(r)
      setFpStep(2)
      if (r.demoCode) {
        toast.info(`MODO DEMOSTRACIÓN · tu código es ${r.demoCode}`)
      }
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setBusy(false)
    }
  }

  const checkCode = async () => {
    if (!/^\d{6}$/.test(fpCode.trim())) {
      toast.error('El código tiene 6 dígitos')
      return
    }
    setBusy(true)
    try {
      const r = await api<{ ok: boolean; resetToken: string }>('/api/auth/reset/verify', {
        method: 'POST',
        body: JSON.stringify({ identifier: fpIdentifier.trim(), code: fpCode.trim() }),
      })
      setFpToken(r.resetToken)
      setFpStep(3)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setBusy(false)
    }
  }

  const saveNewPassword = async () => {
    if (fpPw.length < 6) {
      toast.error('La contraseña nueva debe tener al menos 6 caracteres')
      return
    }
    if (fpPw !== fpPw2) {
      toast.error('Las dos contraseñas no coinciden')
      return
    }
    setBusy(true)
    try {
      const r = await api<{ ok: boolean; message: string }>('/api/auth/reset/confirm', {
        method: 'POST',
        body: JSON.stringify({ resetToken: fpToken, password: fpPw }),
      })
      toast.success(r.message)
      // Vuelve al inicio de sesión con la contraseña ya lista
      setTab('login')
      setFpStep(1)
      setFpIdentifier('')
      setFpInfo(null)
      setFpCode('')
      setFpToken('')
      setFpPw('')
      setFpPw2('')
      setPw('')
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setBusy(false)
    }
  }

  // ---------- Vista del restablecimiento ----------
  if (tab === 'forgot') {
    return (
      <div className="p-4 max-w-md mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
          <button
            onClick={() => {
              setTab('login')
              setFpStep(1)
              setFpInfo(null)
            }}
            className="flex items-center gap-1 text-[13px] text-[#007185] hover:text-[#C7511F] hover:underline mb-3 cursor-pointer"
          >
            <ArrowLeft className="w-3.5 h-3.5" /> Volver al inicio de sesión
          </button>
          <h1 className="text-[24px] font-bold text-[#0F1111] text-center">
            ¿Olvidaste tu contraseña?
          </h1>
          <p className="text-[13px] text-[#565959] text-center mt-1 mb-4">
            Te enviaremos un código de 6 dígitos para crear una contraseña nueva.
          </p>

          {/* Paso 1: identificar la cuenta */}
          {fpStep === 1 && (
            <>
              <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
                Nombre de usuario, correo o teléfono
              </label>
              <input
                value={fpIdentifier}
                onChange={(e) => setFpIdentifier(e.target.value)}
                placeholder="Ej: MariaGP · maria@gmail.com · +53 5xx xxxxx"
                aria-label="Nombre de usuario, correo o teléfono"
                onKeyDown={(e) => e.key === 'Enter' && askCode()}
                className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
              />
              <button
                onClick={askCode}
                disabled={busy}
                className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 cursor-pointer disabled:opacity-60"
              >
                {busy ? 'Enviando el código…' : 'Enviar el código'}
              </button>
              <p className="text-[12px] text-[#565959] mt-4 flex items-start gap-1.5">
                <MessageSquareText className="w-4 h-4 text-[#5B21B6] shrink-0 mt-0.5" />
                El código llega por SMS al teléfono; si el SMS no llega, lo envía el bot de
                Telegram o al correo que tengas guardado en tu cuenta.
              </p>
            </>
          )}

          {/* Paso 2: escribir el código */}
          {fpStep === 2 && (
            <>
              {fpInfo?.demo && fpInfo.demoCode && (
                <div className="border-2 border-dashed border-[#e77600] bg-[#FFF8EE] rounded-lg p-3 mb-3 text-[13px] text-[#0F1111]">
                  <p className="font-bold flex items-center gap-1.5 text-[#B45309]">
                    <ShieldCheck className="w-4 h-4" /> MODO DEMOSTRACIÓN
                  </p>
                  <p className="mt-1 text-[#565959]">
                    El administrador aún no configura el envío real (SMS/correo/bot). Tu código es:
                  </p>
                  <p className="text-[22px] font-bold tracking-[0.3em] text-center text-[#0F1111] mt-1">
                    {fpInfo.demoCode}
                  </p>
                </div>
              )}
              {!fpInfo?.demo && fpInfo?.channelLabel && (
                <div className="border border-[#e3e6e6] bg-[#f7fafa] rounded-lg p-3 mb-3 text-[13px]">
                  <p className="flex items-center gap-1.5 font-bold text-[#007600]">
                    {fpInfo.channel === 'telegram' ? <Send className="w-4 h-4" /> : <Mail className="w-4 h-4" />}
                    Código enviado por {fpInfo.channelLabel} a {fpInfo.target}
                  </p>
                </div>
              )}
              {!fpInfo?.demo && !fpInfo?.channelLabel && fpInfo?.needsAdminHelp && (
                <div className="border border-[#B45309]/40 bg-[#FEF3C7] rounded-lg p-3 mb-3 text-[13px]">
                  <p className="flex items-center gap-1.5 font-bold text-[#B45309]">
                    <ShieldCheck className="w-4 h-4" /> El envío de códigos no está configurado
                  </p>
                  <p className="mt-1 text-[#565959]">
                    Por seguridad, en la web pública el código nunca se muestra en pantalla. El
                    administrador debe conectar el bot de Telegram (Panel → Seguridad) para que
                    los códigos puedan llegar. Si necesitas entrar hoy, contacta con el
                    administrador de la tienda.
                  </p>
                </div>
              )}
              <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
                Código de 6 dígitos
              </label>
              <input
                value={fpCode}
                onChange={(e) => setFpCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="· · · · · ·"
                inputMode="numeric"
                aria-label="Código de verificación"
                onKeyDown={(e) => e.key === 'Enter' && checkCode()}
                className="w-full border border-[#888c8c] rounded px-3 py-2 text-[18px] tracking-[0.3em] text-center outline-none focus:border-[#e77600] mb-3"
              />
              <button
                onClick={checkCode}
                disabled={busy}
                className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 cursor-pointer disabled:opacity-60"
              >
                {busy ? 'Comprobando…' : 'Comprobar el código'}
              </button>
              <div className="flex items-center justify-between mt-3">
                <button
                  onClick={askCode}
                  className="text-[13px] text-[#007185] hover:underline cursor-pointer"
                >
                  No llegó: enviar de nuevo
                </button>
                <button
                  onClick={() => setFpStep(1)}
                  className="text-[13px] text-[#007185] hover:underline cursor-pointer"
                >
                  Cambiar cuenta
                </button>
              </div>
              {fpInfo?.fallbackHint && (
                <p className="text-[12px] text-[#565959] mt-3">{fpInfo.fallbackHint}</p>
              )}
            </>
          )}

          {/* Paso 3: contraseña nueva */}
          {fpStep === 3 && (
            <>
              <p className="text-[13px] font-bold text-[#007600] mb-3 flex items-center gap-1.5">
                <KeyRound className="w-4 h-4" /> Código correcto. Pon tu contraseña nueva.
              </p>
              <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
                Contraseña nueva
              </label>
              <input
                value={fpPw}
                onChange={(e) => setFpPw(e.target.value)}
                type="password"
                placeholder="Mínimo 6 caracteres"
                aria-label="Contraseña nueva"
                className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
              />
              <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
                Repite la contraseña nueva
              </label>
              <input
                value={fpPw2}
                onChange={(e) => setFpPw2(e.target.value)}
                type="password"
                aria-label="Repetir contraseña nueva"
                onKeyDown={(e) => e.key === 'Enter' && saveNewPassword()}
                className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-4"
              />
              <button
                onClick={saveNewPassword}
                disabled={busy}
                className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 cursor-pointer disabled:opacity-60"
              >
                {busy ? 'Guardando…' : 'Guardar la contraseña nueva'}
              </button>
              <p className="text-[12px] text-[#565959] mt-4">
                Al terminar se cierran todas las sesiones abiertas de tu cuenta (por ejemplo,
                si estaba conectada en otro teléfono).
              </p>
            </>
          )}
        </div>
      </div>
    )
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
          placeholder={tab === 'register' ? 'Mínimo 6 caracteres' : 'Tu contraseña'}
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

        {tab === 'login' && (
          <button
            onClick={() => setTab('forgot')}
            className="mt-2 text-[13px] text-[#007185] hover:text-[#C7511F] hover:underline cursor-pointer"
          >
            ¿Olvidaste tu contraseña? Recupérala con un código por SMS, Telegram o correo
          </button>
        )}

        <p className="text-[12px] text-[#565959] mt-4 flex items-start gap-1.5">
          <ShieldCheck className="w-4 h-4 text-[#007600] shrink-0 mt-0.5" />
          Tu contraseña se guarda encriptada: nadie puede leerla, ni siquiera los administradores.
        </p>
      </div>
    </div>
  )
}
