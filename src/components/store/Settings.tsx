'use client'
// ============================================================
// AJUSTES DE LA CUENTA DE VIOLETERO
// - Perfil de contacto: correo electrónico y teléfono (con
//   verificación por código; el del teléfono llega por SMS y,
//   si no llega, por el bot de Telegram)
// - Telegram: enlazar el bot como plan B de los códigos
// - Seguridad: cambiar contraseña (exige la actual)
// - Sesiones activas: ver los dispositivos conectados y cerrar
//   los que no reconoces (protección multi-sesión)
// ============================================================
import { useCallback, useEffect, useState } from 'react'
import {
  BadgeCheck,
  CircleAlert,
  KeyRound,
  LogOut,
  Mail,
  MonitorSmartphone,
  Phone,
  Send,
  ShieldCheck,
} from 'lucide-react'
import { toast } from 'sonner'
import { useStore, STORE_NAME, ROLE_LABELS } from '@/lib/store'
import { api } from '@/lib/api'

type Profile = {
  name: string
  role: string
  email: string | null
  emailVerified: boolean
  phone: string | null
  phoneVerified: boolean
  telegramLinked: boolean
  telegramUsername: string | null
  createdAt: string
  lastPasswordChangeAt: string | null
}

type SessionRow = {
  id: string
  device: string
  ip: string
  createdAt: string
  lastSeenAt: string
  current: boolean
}

type VerifyResponse = {
  ok: boolean
  channel: string | null
  channelLabel: string | null
  target: string
  note: string
  demo: boolean
  demoCode?: string
}

const when = (iso: string) =>
  new Date(iso).toLocaleString('es', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })

export function SettingsView() {
  const user = useStore((s) => s.user)
  const setUser = useStore((s) => s.setUser)
  const openView = useStore((s) => s.openView)

  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)

  // Formularios de contacto
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [savingContact, setSavingContact] = useState(false)

  // Verificación con código (email | phone | null)
  const [verifying, setVerifying] = useState<'email' | 'phone' | null>(null)
  const [verifyInfo, setVerifyInfo] = useState<VerifyResponse | null>(null)
  const [verifyCode, setVerifyCode] = useState('')
  const [verifyBusy, setVerifyBusy] = useState(false)

  // Telegram
  const [tgCode, setTgCode] = useState('')
  const [tgBotUsername, setTgBotUsername] = useState<string | null>(null)
  const [tgBotConfigured, setTgBotConfigured] = useState(false)
  const [tgBusy, setTgBusy] = useState(false)

  // Cambiar contraseña
  const [curPw, setCurPw] = useState('')
  const [newPw, setNewPw] = useState('')
  const [newPw2, setNewPw2] = useState('')
  const [pwBusy, setPwBusy] = useState(false)

  // Sesiones activas
  const [sessions, setSessions] = useState<SessionRow[]>([])
  const [sessionsBusy, setSessionsBusy] = useState(false)

  const loadSessions = useCallback(async () => {
    try {
      const r = await api<{ sessions: SessionRow[] }>('/api/auth/sessions')
      setSessions(r.sessions)
    } catch {
      setSessions([])
    }
  }, [])

  const loadProfile = useCallback(async () => {
    try {
      const r = await api<{ user: Profile }>('/api/auth/me')
      setProfile(r.user)
      setEmail(r.user.email || '')
      setPhone(r.user.phone || '')
      await loadSessions()
    } catch {
      setProfile(null)
    } finally {
      setLoading(false)
    }
  }, [loadSessions])

  useEffect(() => {
    if (user.name === 'Invitado') {
      setLoading(false)
      return
    }
    loadProfile()
  }, [user.name, loadProfile])

  // ---------- Guardar contacto ----------
  const saveContact = async (field: 'email' | 'phone') => {
    const value = (field === 'email' ? email : phone).trim()
    setSavingContact(true)
    try {
      const r = await api<{
        ok: boolean
        needsVerification: string[]
        message: string
        user: Profile
      }>('/api/profile', {
        method: 'POST',
        body: JSON.stringify({ [field]: value }),
      })
      setProfile(r.user)
      toast.success(r.message)
      if (r.needsVerification.includes(field)) {
        await sendVerifyCode(field)
      }
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSavingContact(false)
    }
  }

  // ---------- Verificar con código ----------
  const sendVerifyCode = async (field: 'email' | 'phone') => {
    setVerifyBusy(true)
    try {
      const r = await api<VerifyResponse>('/api/profile/verify', {
        method: 'POST',
        body: JSON.stringify({ action: 'start', field }),
      })
      setVerifying(field)
      setVerifyInfo(r)
      setVerifyCode('')
      if (r.demoCode) toast.info(`MODO DEMOSTRACIÓN · tu código es ${r.demoCode}`)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setVerifyBusy(false)
    }
  }

  const confirmVerify = async () => {
    if (!verifying) return
    if (!/^\d{6}$/.test(verifyCode.trim())) {
      toast.error('El código tiene 6 dígitos')
      return
    }
    setVerifyBusy(true)
    try {
      const r = await api<{ ok: boolean; message: string; user: Profile }>(
        '/api/profile/verify',
        {
          method: 'POST',
          body: JSON.stringify({ action: 'confirm', field: verifying, code: verifyCode.trim() }),
        }
      )
      setProfile(r.user)
      toast.success(r.message)
      setVerifying(null)
      setVerifyInfo(null)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setVerifyBusy(false)
    }
  }

  // ---------- Telegram ----------
  const tgStart = async () => {
    setTgBusy(true)
    try {
      const r = await api<{ ok: boolean; code: string; botConfigured: boolean; botUsername: string | null; instructions: string }>(
        '/api/profile/telegram',
        { method: 'POST', body: JSON.stringify({ action: 'start' }) }
      )
      setTgCode(r.code)
      setTgBotUsername(r.botUsername)
      setTgBotConfigured(r.botConfigured)
      toast.info(r.botConfigured ? 'Código de enlace generado. Sigue las instrucciones.' : 'El bot aún no está configurado por el administrador.')
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setTgBusy(false)
    }
  }

  const tgCheck = async () => {
    setTgBusy(true)
    try {
      const r = await api<{ ok: boolean; message: string; user: Profile }>('/api/profile/telegram', {
        method: 'POST',
        body: JSON.stringify({ action: 'check' }),
      })
      setProfile(r.user)
      toast.success(r.message)
      setTgCode('')
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setTgBusy(false)
    }
  }

  const tgUnlink = async () => {
    setTgBusy(true)
    try {
      const r = await api<{ ok: boolean; message: string; user: Profile }>('/api/profile/telegram', {
        method: 'POST',
        body: JSON.stringify({ action: 'unlink' }),
      })
      setProfile(r.user)
      toast.success(r.message)
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setTgBusy(false)
    }
  }

  // ---------- Cambiar contraseña ----------
  const changePassword = async () => {
    if (!curPw) {
      toast.error('Escribe tu contraseña actual')
      return
    }
    if (newPw.length < 4) {
      toast.error('La contraseña nueva debe tener al menos 4 caracteres')
      return
    }
    if (newPw !== newPw2) {
      toast.error('Las dos contraseñas nuevas no coinciden')
      return
    }
    setPwBusy(true)
    try {
      const r = await api<{ ok: boolean; message: string }>('/api/auth/change-password', {
        method: 'POST',
        body: JSON.stringify({ currentPassword: curPw, newPassword: newPw }),
      })
      toast.success(r.message)
      setCurPw('')
      setNewPw('')
      setNewPw2('')
      await loadSessions()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setPwBusy(false)
    }
  }

  // ---------- Sesiones ----------
  const closeSession = async (id: string) => {
    setSessionsBusy(true)
    try {
      const r = await api<{ ok: boolean; message: string }>('/api/auth/sessions', {
        method: 'POST',
        body: JSON.stringify({ sessionId: id }),
      })
      toast.success(r.message)
      await loadSessions()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSessionsBusy(false)
    }
  }

  const closeOthers = async () => {
    setSessionsBusy(true)
    try {
      const r = await api<{ ok: boolean; message: string }>('/api/auth/sessions', {
        method: 'POST',
        body: JSON.stringify({ allOthers: true }),
      })
      toast.success(r.message)
      await loadSessions()
    } catch (e) {
      toast.error((e as Error).message)
    } finally {
      setSessionsBusy(false)
    }
  }

  const logout = async () => {
    try {
      await api('/api/auth/logout', { method: 'POST' })
    } catch {
      // aunque falle la red, la identidad del navegador se limpia
    }
    setUser({ name: 'Invitado', role: 'comprador' })
    openView('home')
    toast.success('Sesión cerrada')
  }

  // ---------- Invitado ----------
  if (!loading && (user.name === 'Invitado' || !profile)) {
    return (
      <div className="p-4 max-w-md mx-auto">
        <div className="bg-white rounded-lg border border-[#e3e6e6] p-6 text-center">
          <ShieldCheck className="w-10 h-10 text-[#5B21B6] mx-auto mb-2" />
          <h1 className="text-[22px] font-bold text-[#0F1111]">Ajustes de la cuenta</h1>
          <p className="text-[13px] text-[#565959] mt-2 mb-4">
            Inicia sesión para gestionar tu correo, tu teléfono, tu Telegram, tu contraseña y
            las sesiones activas de {STORE_NAME}.
          </p>
          <button
            onClick={() => openView('login')}
            className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 cursor-pointer"
          >
            Iniciar sesión
          </button>
        </div>
      </div>
    )
  }

  if (loading || !profile) {
    return <div className="p-8 text-center text-[14px] text-[#565959]">Cargando ajustes…</div>
  }

  return (
    <div className="p-4 max-w-3xl mx-auto flex flex-col gap-4">
      {/* Cabecera */}
      <div className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h1 className="text-[24px] font-bold text-[#0F1111]">Ajustes de la cuenta</h1>
        <p className="text-[13px] text-[#565959] mt-1">
          {profile.name} · {ROLE_LABELS[profile.role as keyof typeof ROLE_LABELS] || profile.role} ·
          cuenta creada el {when(profile.createdAt)}
        </p>
        {profile.lastPasswordChangeAt && (
          <p className="text-[12px] text-[#565959] mt-0.5">
            Último cambio de contraseña: {when(profile.lastPasswordChangeAt)}
          </p>
        )}
      </div>

      {/* ---------- Perfil de contacto ---------- */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Mail className="w-5 h-5 text-[#5B21B6]" /> Correo electrónico y teléfono
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Los códigos de seguridad llegan al teléfono por SMS y, si el SMS no llega, por el bot
          de Telegram o al correo.
        </p>

        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Correo electrónico</label>
        <div className="flex gap-2 mb-1">
          <input
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="tucorreo@gmail.com"
            aria-label="Correo electrónico"
            className="flex-1 border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
          />
          <button
            onClick={() => saveContact('email')}
            disabled={savingContact}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded px-4 cursor-pointer disabled:opacity-60"
          >
            Guardar
          </button>
        </div>
        <p className="text-[12px] mb-4 flex items-center gap-1">
          {profile.emailVerified ? (
            <span className="text-[#007600] font-bold flex items-center gap-1">
              <BadgeCheck className="w-4 h-4" /> Correo verificado
            </span>
          ) : profile.email ? (
            <span className="text-[#B45309] flex items-center gap-1">
              <CircleAlert className="w-4 h-4" /> Sin verificar —{' '}
              <button onClick={() => sendVerifyCode('email')} className="text-[#007185] hover:underline cursor-pointer" disabled={verifyBusy}>
                enviar código
              </button>
            </span>
          ) : (
            <span className="text-[#565959]">Guarda tu correo para recibir códigos y avisos.</span>
          )}
        </p>

        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Número de teléfono</label>
        <div className="flex gap-2 mb-1">
          <input
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="+53 5xx xxx xx"
            aria-label="Número de teléfono"
            className="flex-1 border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600]"
          />
          <button
            onClick={() => saveContact('phone')}
            disabled={savingContact}
            className="bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded px-4 cursor-pointer disabled:opacity-60"
          >
            Guardar
          </button>
        </div>
        <p className="text-[12px] flex items-center gap-1">
          {profile.phoneVerified ? (
            <span className="text-[#007600] font-bold flex items-center gap-1">
              <BadgeCheck className="w-4 h-4" /> Teléfono verificado
            </span>
          ) : profile.phone ? (
            <span className="text-[#B45309] flex items-center gap-1">
              <CircleAlert className="w-4 h-4" /> Sin verificar —{' '}
              <button onClick={() => sendVerifyCode('phone')} className="text-[#007185] hover:underline cursor-pointer" disabled={verifyBusy}>
                enviar código por SMS
              </button>
            </span>
          ) : (
            <span className="text-[#565959]">Guarda tu teléfono para recibir los códigos por SMS.</span>
          )}
        </p>

        {/* Caja de verificación con código */}
        {verifying && (
          <div className="mt-4 border-2 rounded-lg p-4" style={{ borderColor: verifyInfo?.demo ? '#e77600' : '#5B21B6' }}>
            {verifyInfo?.demo && verifyInfo.demoCode ? (
              <div className="mb-3">
                <p className="text-[13px] font-bold text-[#B45309] flex items-center gap-1.5">
                  <ShieldCheck className="w-4 h-4" /> MODO DEMOSTRACIÓN — tu código es{' '}
                  <span className="text-[18px] tracking-[0.2em]">{verifyInfo.demoCode}</span>
                </p>
                <p className="text-[12px] text-[#565959] mt-1">
                  El administrador aún no configura el envío real (SMS/correo/bot de Telegram).
                </p>
              </div>
            ) : (
              verifyInfo?.channelLabel && (
                <p className="text-[13px] text-[#007600] font-bold mb-2">
                  Código enviado por {verifyInfo.channelLabel} a {verifyInfo.target}
                </p>
              )
            )}
            <label className="block text-[13px] font-bold text-[#0F1111] mb-1">
              Código para verificar tu {verifying === 'email' ? 'correo' : 'teléfono'}
            </label>
            <div className="flex gap-2">
              <input
                value={verifyCode}
                onChange={(e) => setVerifyCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                inputMode="numeric"
                aria-label="Código de verificación"
                className="flex-1 border border-[#888c8c] rounded px-3 py-2 text-[16px] tracking-[0.25em] text-center outline-none focus:border-[#e77600]"
              />
              <button
                onClick={confirmVerify}
                disabled={verifyBusy}
                className="bg-[#5B21B6] hover:bg-[#4C1D95] text-white text-[13px] font-bold rounded px-4 cursor-pointer disabled:opacity-60"
              >
                Verificar
              </button>
            </div>
            <button
              onClick={() => sendVerifyCode(verifying)}
              className="text-[12px] text-[#007185] hover:underline mt-2 cursor-pointer"
              disabled={verifyBusy}
            >
              No llegó: enviar de nuevo
            </button>
          </div>
        )}
      </section>

      {/* ---------- Telegram ---------- */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <Send className="w-5 h-5 text-[#5B21B6]" /> Bot de Telegram (plan B)
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Si el SMS no te llega, el bot de Telegram te envía el código. Enlaza tu cuenta una vez
          y listo.
        </p>

        {profile.telegramLinked ? (
          <div className="flex flex-wrap items-center gap-3">
            <span className="bg-[#E7F7E7] text-[#007600] text-[13px] font-bold rounded-full px-3 py-1.5 flex items-center gap-1.5">
              <BadgeCheck className="w-4 h-4" /> Enlazado {profile.telegramUsername ? `(@${profile.telegramUsername})` : ''}
            </span>
            <button
              onClick={tgUnlink}
              disabled={tgBusy}
              className="text-[13px] text-[#C7511F] hover:underline cursor-pointer disabled:opacity-60"
            >
              Desconectar Telegram
            </button>
          </div>
        ) : (
          <>
            <button
              onClick={tgStart}
              disabled={tgBusy}
              className="border border-[#d5d9d9] hover:bg-[#f7fafa] text-[#0F1111] text-[13px] font-bold rounded-full px-4 py-2 cursor-pointer disabled:opacity-60"
            >
              {tgBusy ? 'Un momento…' : 'Generar código de enlace'}
            </button>
            {tgCode && (
              <div className="mt-3 border border-[#e3e6e6] bg-[#f7fafa] rounded-lg p-4 text-[13px]">
                {tgBotConfigured ? (
                  <>
                    <p className="text-[#0F1111]">
                      1. Abre Telegram y busca el bot{' '}
                      <b>{tgBotUsername ? `@${tgBotUsername}` : 'de Violetero'}</b>.
                    </p>
                    <p className="mt-1 text-[#0F1111]">
                      2. Envíale este mensaje:{' '}
                      <code className="bg-white border border-[#e3e6e6] rounded px-2 py-0.5 font-bold text-[#5B21B6]">
                        /start {tgCode}
                      </code>
                    </p>
                    <button
                      onClick={tgCheck}
                      disabled={tgBusy}
                      className="mt-3 bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[13px] font-bold rounded-full px-4 py-2 cursor-pointer disabled:opacity-60"
                    >
                      {tgBusy ? 'Comprobando…' : '3. Ya envié el mensaje: comprobar'}
                    </button>
                  </>
                ) : (
                  <p className="text-[#B45309] flex items-start gap-1.5">
                    <CircleAlert className="w-4 h-4 shrink-0 mt-0.5" />
                    El administrador aún no guarda el token del bot en{' '}
                    <b>Administración → Seguridad</b>. Cuando lo guarde, tu código de enlace
                    será <b>{tgCode}</b>.
                  </p>
                )}
              </div>
            )}
          </>
        )}
      </section>

      {/* ---------- Cambiar contraseña ---------- */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <KeyRound className="w-5 h-5 text-[#5B21B6]" /> Cambiar contraseña
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Se te pedirá la contraseña actual. Al cambiarla se cierran las sesiones de los demás
          dispositivos para proteger tu cuenta.
        </p>

        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Contraseña actual</label>
        <input
          value={curPw}
          onChange={(e) => setCurPw(e.target.value)}
          type="password"
          aria-label="Contraseña actual"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
        />
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Contraseña nueva</label>
        <input
          value={newPw}
          onChange={(e) => setNewPw(e.target.value)}
          type="password"
          placeholder="Mínimo 4 caracteres"
          aria-label="Contraseña nueva"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-3"
        />
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">Repite la contraseña nueva</label>
        <input
          value={newPw2}
          onChange={(e) => setNewPw2(e.target.value)}
          type="password"
          aria-label="Repetir contraseña nueva"
          className="w-full border border-[#888c8c] rounded px-3 py-2 text-[14px] outline-none focus:border-[#e77600] mb-4"
        />
        <button
          onClick={changePassword}
          disabled={pwBusy}
          className="w-full bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[15px] font-bold rounded-full py-2.5 cursor-pointer disabled:opacity-60"
        >
          {pwBusy ? 'Guardando…' : 'Guardar la contraseña nueva'}
        </button>
      </section>

      {/* ---------- Sesiones activas ---------- */}
      <section className="bg-white rounded-lg border border-[#e3e6e6] p-6">
        <h2 className="text-[18px] font-bold text-[#0F1111] flex items-center gap-2">
          <MonitorSmartphone className="w-5 h-5 text-[#5B21B6]" /> Sesiones activas
        </h2>
        <p className="text-[13px] text-[#565959] mt-1 mb-4">
          Si tu cuenta está abierta en dos dispositivos a la vez (dos navegadores, dos teléfonos),
          aquí los ves y puedes cerrar los que no reconozcas.
        </p>

        <div className="flex flex-col gap-2 mb-4">
          {sessions.length === 0 && (
            <p className="text-[13px] text-[#565959]">No hay sesiones activas para mostrar.</p>
          )}
          {sessions.map((s) => (
            <div
              key={s.id}
              className={`flex items-center justify-between gap-3 border rounded-lg p-3 ${
                s.current ? 'border-[#5B21B6] bg-[#f6f1fd]' : 'border-[#e3e6e6]'
              }`}
            >
              <div className="min-w-0">
                <p className="text-[14px] font-bold text-[#0F1111] flex items-center gap-2">
                  {s.device}
                  {s.current && (
                    <span className="bg-[#5B21B6] text-white text-[11px] font-bold rounded-full px-2 py-0.5">
                      Esta sesión
                    </span>
                  )}
                </p>
                <p className="text-[12px] text-[#565959]">
                  Actividad: {when(s.lastSeenAt)} · Entró: {when(s.createdAt)}
                  {s.ip && s.ip !== 'local' ? ` · IP ${s.ip}` : ''}
                </p>
              </div>
              {!s.current && (
                <button
                  onClick={() => closeSession(s.id)}
                  disabled={sessionsBusy}
                  className="shrink-0 text-[13px] text-[#C7511F] hover:underline cursor-pointer disabled:opacity-60"
                >
                  Cerrar
                </button>
              )}
            </div>
          ))}
        </div>

        {sessions.some((s) => !s.current) && (
          <button
            onClick={closeOthers}
            disabled={sessionsBusy}
            className="w-full border border-[#d5d9d9] hover:bg-[#f7fafa] text-[#0F1111] text-[13px] font-bold rounded-full py-2.5 cursor-pointer disabled:opacity-60"
          >
            Cerrar las demás sesiones (otros dispositivos)
          </button>
        )}

        <button
          onClick={logout}
          className="mt-3 w-full bg-[#f0f2f2] hover:bg-[#e3e6e6] text-[#0F1111] text-[13px] font-bold rounded-full py-2.5 cursor-pointer flex items-center justify-center gap-2"
        >
          <LogOut className="w-4 h-4" /> Cerrar sesión en este dispositivo
        </button>
      </section>
    </div>
  )
}
