// ============================================================
// VERIFICACIÓN DEL CORREO / TELÉFONO CON CÓDIGO
// POST /api/profile/verify { action: 'start' | 'confirm', field, code? }
// - start: envía el código (correo -> email; teléfono -> SMS con
//   plan B por el bot de Telegram)
// - confirm: comprueba el código y marca el dato como verificado
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import {
  rateLimit,
  RATE,
  getClientIp,
  genCode,
  hashValue,
  maskEmail,
  maskPhone,
  MAX_CODE_ATTEMPTS,
  logSecurityEvent,
} from '@/lib/security'
import { deliverCode, hasRealChannel, CHANNEL_LABELS, type Channel } from '@/lib/notify'
import { getSessionUser } from '@/lib/session'

export async function POST(req: Request) {
  const ip = getClientIp(req)
  const sess = await getSessionUser(req)
  if (!sess) {
    return NextResponse.json({ error: 'No hay sesión activa' }, { status: 401 })
  }
  if (!rateLimit(`profileverify:${sess.user.id}`, RATE.verify.max, RATE.verify.windowMs)) {
    return NextResponse.json({ error: 'Demasiados intentos. Espera unos minutos.' }, { status: 429 })
  }

  const body = await req.json().catch(() => ({}))
  const action = String(body.action || '')
  const field = body.field === 'phone' ? 'phone' : body.field === 'email' ? 'email' : null
  if (!field) {
    return NextResponse.json({ error: 'Dato a verificar no válido' }, { status: 400 })
  }

  const value = field === 'email' ? sess.user.email : sess.user.phone
  if (!value) {
    return NextResponse.json(
      { error: `Primero guarda tu ${field === 'email' ? 'correo electrónico' : 'número de teléfono'}` },
      { status: 400 }
    )
  }

  // ---------- Enviar el código ----------
  if (action === 'start') {
    const code = genCode()
    const preferred: Channel = field === 'email' ? 'email' : 'sms'
    const delivery = await deliverCode({
      userId: sess.user.id,
      userName: sess.user.name,
      purpose: field === 'email' ? 'verify_email' : 'verify_phone',
      codeHash: hashValue(code),
      code,
      preferred,
      target: {
        email: sess.user.email,
        phone: sess.user.phone,
        telegramChatId: sess.user.telegramChatId,
        telegramUsername: sess.user.telegramUsername,
      },
      mask: (t) => (t.includes('@') ? maskEmail(t) : maskPhone(t)),
    })
    await logSecurityEvent({
      userId: sess.user.id,
      userName: sess.user.name,
      type: 'verify_code_sent',
      detail: `Código de verificación de ${field} ${delivery.realSent ? `enviado por ${CHANNEL_LABELS[delivery.channel as Channel]}` : 'generado (modo demostración)'}`,
      ip,
    })
    const demo = !(await hasRealChannel())
    return NextResponse.json({
      ok: true,
      channel: delivery.channel,
      channelLabel: delivery.channel ? CHANNEL_LABELS[delivery.channel] : null,
      target: delivery.target,
      note: delivery.note,
      demo,
      demoCode: demo ? code : undefined,
    })
  }

  // ---------- Comprobar el código ----------
  if (action === 'confirm') {
    const code = String(body.code || '').trim()
    if (!/^\d{6}$/.test(code)) {
      return NextResponse.json({ error: 'Escribe el código de 6 dígitos' }, { status: 400 })
    }
    const record = await db.verificationCode.findFirst({
      where: {
        userId: sess.user.id,
        purpose: field === 'email' ? 'verify_email' : 'verify_phone',
        usedAt: null,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    })
    if (!record) {
      return NextResponse.json({ error: 'El código no es válido o ya caducó. Pide uno nuevo.' }, { status: 400 })
    }
    if (record.attempts >= MAX_CODE_ATTEMPTS) {
      return NextResponse.json({ error: 'Demasiados intentos con este código. Pide uno nuevo.' }, { status: 429 })
    }
    if (record.codeHash !== hashValue(code)) {
      await db.verificationCode.update({
        where: { id: record.id },
        data: { attempts: { increment: 1 } },
      })
      const left = MAX_CODE_ATTEMPTS - (record.attempts + 1)
      return NextResponse.json({ error: `El código no coincide. Te quedan ${left} intento(s).` }, { status: 400 })
    }
    await db.verificationCode.update({ where: { id: record.id }, data: { usedAt: new Date() } })
    const user = await db.user.update({
      where: { id: sess.user.id },
      data: field === 'email' ? { emailVerifiedAt: new Date() } : { phoneVerifiedAt: new Date() },
    })
    await logSecurityEvent({
      userId: user.id,
      userName: user.name,
      type: 'contact_verified',
      detail: `${field === 'email' ? 'Correo' : 'Teléfono'} verificado correctamente con código`,
      ip,
    })
    return NextResponse.json({
      ok: true,
      message: field === 'email' ? 'Correo verificado.' : 'Teléfono verificado.',
      user: {
        name: user.name,
        role: user.role,
        email: user.email,
        emailVerified: Boolean(user.emailVerifiedAt),
        phone: user.phone,
        phoneVerified: Boolean(user.phoneVerifiedAt),
        telegramLinked: Boolean(user.telegramChatId),
        telegramUsername: user.telegramUsername,
        createdAt: user.createdAt,
        lastPasswordChangeAt: user.lastPasswordChangeAt,
      },
    })
  }

  return NextResponse.json({ error: 'Acción no válida' }, { status: 400 })
}
