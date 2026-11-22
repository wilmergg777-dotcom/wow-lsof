// ============================================================
// SESIONES DE VIOLETERO (multi-dispositivo)
// Al iniciar sesión se crea una sesión en la base de datos y se
// deja una cookie httpOnly con el token (nunca se guarda en
// claro). Desde los ajustes el usuario ve sus sesiones activas
// y puede cerrar las demás (protección si dos dispositivos
// están conectados a la vez).
// ============================================================
import { db } from './db'
import { genToken, hashValue, describeDevice, logSecurityEvent } from './security'

export const SESSION_COOKIE = 'vio_session'
export const SESSION_MAX_AGE = 60 * 60 * 24 * 30 // 30 días

// Crea la sesión en la base y devuelve el token para la cookie
export async function createSession(userId: string, userName: string, userAgent: string, ip: string) {
  const token = genToken()
  const device = describeDevice(userAgent)
  const session = await db.userSession.create({
    data: { userId, tokenHash: hashValue(token), device, ip },
  })
  await logSecurityEvent({
    userId,
    userName,
    type: 'session_created',
    detail: `Nuevo inicio de sesión desde ${device}`,
    ip,
  })
  return { token, sessionId: session.id, device }
}

// Lee el token de la cookie de la petición
export function readSessionToken(req: Request): string | null {
  const cookie = req.headers.get('cookie') || ''
  for (const part of cookie.split(';')) {
    const [k, ...rest] = part.trim().split('=')
    if (k === SESSION_COOKIE) return decodeURIComponent(rest.join('='))
  }
  return null
}

// Usuario de la sesión actual (o null si no hay sesión válida)
export async function getSessionUser(req: Request) {
  const token = readSessionToken(req)
  if (!token) return null
  const session = await db.userSession.findUnique({
    where: { tokenHash: hashValue(token) },
    include: { user: true },
  })
  if (!session || session.revokedAt) return null
  // Actualiza la marca de actividad (como máximo una vez cada 5 min)
  if (Date.now() - session.lastSeenAt.getTime() > 5 * 60_000) {
    await db.userSession.update({
      where: { id: session.id },
      data: { lastSeenAt: new Date() },
    })
  }
  return { session, user: session.user }
}

// Cierra TODAS las sesiones del usuario (tras cambiar/resetear contraseña)
export async function revokeAllSessions(userId: string) {
  await db.userSession.updateMany({
    where: { userId, revokedAt: null },
    data: { revokedAt: new Date() },
  })
}

// Cierra las demás sesiones dejando la actual activa
export async function revokeOtherSessions(userId: string, keepSessionId: string) {
  const r = await db.userSession.updateMany({
    where: { userId, revokedAt: null, id: { not: keepSessionId } },
    data: { revokedAt: new Date() },
  })
  return r.count
}

// Cierra una sesión concreta
export async function revokeSessionById(userId: string, sessionId: string) {
  const r = await db.userSession.updateMany({
    where: { userId, id: sessionId, revokedAt: null },
    data: { revokedAt: new Date() },
  })
  return r.count
}

// ============================================================
// PARCHES DE SEGURIDAD: control de acceso del servidor
// Antes las rutas confiaban en el nombre que enviaba el
// navegador (se podía suplantar). Ahora la identidad SIEMPRE
// sale de la cookie de sesión httpOnly.
// ============================================================

// Exige una sesión válida. Devuelve la sesión o null (-> 401).
export async function requireUser(req: Request) {
  return getSessionUser(req)
}

// Exige sesión de administrador. Devuelve la sesión o null (-> 401/403).
export async function requireAdmin(req: Request) {
  const sess = await getSessionUser(req)
  if (!sess) return null
  if (sess.user.role !== 'administrador') return null
  return sess
}

// ¿El nombre que pide la petición coincide con la cuenta de la
// sesión (o es el administrador)? Evita que un usuario actúe en
// nombre de otro.
export function isSelfOrAdmin(sess: { user: { name: string; role: string } }, name: string) {
  return sess.user.name === name || sess.user.role === 'administrador'
}
