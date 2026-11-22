// ============================================================
// AUTENTICACIÓN DE VIOLETERO (lado servidor)
// Contraseñas con sal y scrypt (nunca texto plano). Como en
// Amazon: mirar es libre, comprar exige cuenta.
// ============================================================
import { randomBytes, scryptSync, timingSafeEqual } from 'crypto'
import { db } from './db'

// Genera "sal:hash" para guardar en la base de datos
export const hashPassword = (pw: string) => {
  const salt = randomBytes(16).toString('hex')
  const hash = scryptSync(pw, salt, 64).toString('hex')
  return `${salt}:${hash}`
}

// Compara una contraseña con el hash guardado
export const verifyPassword = (pw: string, stored: string) => {
  const [salt, hash] = stored.split(':')
  if (!salt || !hash) return false
  const test = scryptSync(pw, salt, 64)
  const orig = Buffer.from(hash, 'hex')
  return orig.length === test.length && timingSafeEqual(orig, test)
}

// Cuenta del administrador que viene con la web. Se crea sola
// la primera vez que alguien entra a registrarse o iniciar
// sesión. Cambia la contraseña desde el panel cuando quieras.
export const ADMIN_SEED_PASSWORD = 'admin123'

export async function ensureUsersSeed() {
  const admin = await db.user.findUnique({ where: { name: 'Administrador' } })
  if (!admin) {
    await db.user.create({
      data: {
        name: 'Administrador',
        password: hashPassword(ADMIN_SEED_PASSWORD),
        role: 'administrador',
      },
    })
    // Aviso de seguridad: la cuenta inicial usa la contraseña de
    // fábrica hasta que el dueño la cambie desde los ajustes.
    await db.securityEvent
      .create({
        data: {
          userName: 'Administrador',
          type: 'admin_default_password',
          detail:
            'Se creó la cuenta del administrador con la contraseña inicial "admin123". CÁMBIALA YA en Ajustes → Cambiar contraseña.',
        },
      })
      .catch(() => {})
  }
}
