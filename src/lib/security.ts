// ============================================================
// UTILIDADES DE SEGURIDAD DE VIOLETERO
// - Límite de peticiones por IP (anti fuerza bruta)
// - Bloqueo temporal de cuentas tras demasiados intentos
// - Códigos de verificación de 6 dígitos (solo se guarda el hash)
// - Registro de eventos de seguridad (auditoría de ataques)
// ============================================================
import { createHash, randomInt, randomBytes } from 'crypto'
import { db } from './db'

// ---------- IP del cliente ----------
export function getClientIp(req: Request): string {
  const fwd = req.headers.get('x-forwarded-for')
  if (fwd) return fwd.split(',')[0].trim()
  return req.headers.get('x-real-ip') || 'local'
}

// ---------- Límite de peticiones (rate limit) ----------
// Memoria local del servidor: clave -> [marca de tiempo, contador]
type Bucket = { count: number; resetAt: number }
const buckets = new Map<string, Bucket>()

// Limpieza periódica para que el mapa no crezca sin fin
let lastCleanup = Date.now()
function cleanup() {
  const now = Date.now()
  if (now - lastCleanup < 60_000) return
  lastCleanup = now
  for (const [k, b] of buckets) if (b.resetAt < now) buckets.delete(k)
}

/**
 * Devuelve true si la petición está permitida. `max` peticiones
 * por cada `windowMs` milisegundos. Si se pasa, el bloqueo dura
 * más (lockMs) cuando se agota el límite.
 */
export function rateLimit(key: string, max: number, windowMs: number): boolean {
  cleanup()
  const now = Date.now()
  const b = buckets.get(key)
  if (!b || b.resetAt < now) {
    buckets.set(key, { count: 1, resetAt: now + windowMs })
    return true
  }
  b.count += 1
  return b.count <= max
}

// Límites por acción (parches anti-ataque)
export const RATE = {
  login: { max: 10, windowMs: 10 * 60_000 }, // 10 intentos de sesión cada 10 min por IP
  forgot: { max: 5, windowMs: 15 * 60_000 }, // 5 códigos de recuperación cada 15 min
  verify: { max: 12, windowMs: 15 * 60_000 }, // 12 comprobaciones de código cada 15 min
  register: { max: 5, windowMs: 15 * 60_000 }, // 5 registros cada 15 min por IP
  write: { max: 30, windowMs: 10 * 60_000 }, // cambios de perfil / sesiones
}

// ---------- Bloqueo de cuenta por intentos fallidos ----------
export const MAX_FAILED_ATTEMPTS = 5
export const LOCK_MINUTES = 15

export function lockUntil(): Date {
  return new Date(Date.now() + LOCK_MINUTES * 60_000)
}

// ---------- Códigos y tokens ----------
export const genCode = () => String(randomInt(0, 1_000_000)).padStart(6, '0')
export const genToken = () => randomBytes(32).toString('hex')
export const hashValue = (v: string) => createHash('sha256').update(v).digest('hex')

export const CODE_TTL_MIN = 10 // el código caduca a los 10 minutos
export const RESET_TOKEN_TTL_MIN = 15 // el token para fijar la nueva contraseña dura 15 min
export const MAX_CODE_ATTEMPTS = 5 // 5 intentos por código, luego se anula

// ---------- Enmascarar datos para mostrarlos ----------
export function maskEmail(email: string): string {
  const [user, domain] = email.split('@')
  if (!domain) return '***'
  const head = user.slice(0, Math.min(2, user.length))
  return `${head}${'*'.repeat(Math.max(3, user.length - 2))}@${domain}`
}

export function maskPhone(phone: string): string {
  const clean = phone.replace(/\s+/g, '')
  return `${'*'.repeat(Math.max(0, clean.length - 3))}${clean.slice(-3)}`
}

// ---------- Describir el dispositivo desde el User-Agent ----------
export function describeDevice(ua: string): string {
  const s = ua || ''
  const browser =
    /Edg\//.test(s) ? 'Edge'
    : /OPR\//.test(s) ? 'Opera'
    : /Chrome\//.test(s) ? 'Chrome'
    : /Firefox\//.test(s) ? 'Firefox'
    : /Safari\//.test(s) ? 'Safari'
    : 'Navegador'
  const os =
    /Windows/.test(s) ? 'Windows'
    : /Android/.test(s) ? 'Android'
    : /iPhone|iPad/.test(s) ? 'iOS'
    : /Mac OS/.test(s) ? 'Mac'
    : /Linux/.test(s) ? 'Linux'
    : 'Dispositivo'
  return `${browser} · ${os}`
}

// ---------- Registro de eventos de seguridad ----------
export async function logSecurityEvent(data: {
  userId?: string | null
  userName?: string
  type: string
  detail?: string
  ip?: string
}) {
  try {
    await db.securityEvent.create({
      data: {
        userId: data.userId || null,
        userName: data.userName || '',
        type: data.type,
        detail: data.detail || '',
        ip: data.ip || '',
      },
    })
  } catch {
    // el registro de seguridad nunca debe romper la petición principal
  }
}
