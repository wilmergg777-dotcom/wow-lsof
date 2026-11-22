// ============================================================
// API de métodos de cobro del administrador (cuentas/tarjetas
// donde los usuarios envían el dinero real para recargar)
// PARCHES DE SEGURIDAD:
// - Crear/editar/eliminar SOLO el administrador (antes cualquier
//   visitante podía publicar una tarjeta falsa para estafar).
// - La consulta pública sigue abierta: los compradores necesitan
//   ver las cuentas para poder transferir.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { requireAdmin } from '@/lib/session'
import { clip, bodyTooLarge, logSecurityEvent } from '@/lib/security'

// GET /api/payment-methods          — métodos activos (público)
// GET /api/payment-methods?all=1    — todos (panel del administrador)
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const all = searchParams.get('all')
  const methods = await db.paymentMethod.findMany({
    where: all ? {} : { active: true },
    orderBy: { id: 'asc' },
  })
  // Si el administrador todavía no configuró ninguna cuenta, se
  // crea una de ejemplo para que el sistema funcione desde ya.
  if (methods.length === 0) {
    const seed = await db.paymentMethod.create({
      data: {
        label: 'Tarjeta monetaria (ejemplo)',
        details: '0000 0000 0000 0000',
        holder: 'Administrador de Violetero',
        phone: '+53 5 000 0000',
        instructions: 'Edita esta tarjeta en el panel del administrador con tu cuenta real.',
        active: true,
      },
    })
    return NextResponse.json(all ? [seed] : [seed].filter((m) => m.active))
  }
  return NextResponse.json(methods)
}

// POST /api/payment-methods — agregar un método de cobro (solo admin)
export async function POST(req: Request) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Solo el administrador puede configurar las cuentas de cobro' },
      { status: 403 }
    )
  }
  if (bodyTooLarge(req)) {
    return NextResponse.json({ error: 'Datos demasiado grandes' }, { status: 413 })
  }
  const body = await req.json().catch(() => ({}))
  const { label, details, holder } = body
  if (!label || !details || !holder) {
    return NextResponse.json(
      { error: 'Faltan datos: nombre de la cuenta, número y titular' },
      { status: 400 }
    )
  }
  const method = await db.paymentMethod.create({
    data: {
      label: clip(label, 60),
      details: clip(details, 120),
      holder: clip(holder, 80),
      phone: clip(body.phone, 30),
      instructions: clip(body.instructions, 300),
      active: body.active !== false,
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'payment_method_created',
    detail: `Agregó el método de cobro "${method.label}"`,
  })
  return NextResponse.json(method, { status: 201 })
}
