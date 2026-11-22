// ============================================================
// API de un método de cobro: editar o eliminar
// PARCHES DE SEGURIDAD: SOLO el administrador puede editar o
// eliminar las cuentas de cobro.
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'
import { requireAdmin } from '@/lib/session'
import { clip, bodyTooLarge, logSecurityEvent } from '@/lib/security'

// PATCH /api/payment-methods/[id] — editar
export async function PATCH(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Solo el administrador puede editar las cuentas de cobro' },
      { status: 403 }
    )
  }
  if (bodyTooLarge(req)) {
    return NextResponse.json({ error: 'Datos demasiado grandes' }, { status: 413 })
  }
  const { id } = await params
  const body = await req.json().catch(() => ({}))
  const existing = await db.paymentMethod.findUnique({ where: { id } })
  if (!existing) {
    return NextResponse.json({ error: 'Método de cobro no encontrado' }, { status: 404 })
  }
  const updated = await db.paymentMethod.update({
    where: { id },
    data: {
      label: body.label !== undefined ? clip(body.label, 60) : existing.label,
      details: body.details !== undefined ? clip(body.details, 120) : existing.details,
      holder: body.holder !== undefined ? clip(body.holder, 80) : existing.holder,
      phone: body.phone !== undefined ? clip(body.phone, 30) : existing.phone,
      instructions:
        body.instructions !== undefined ? clip(body.instructions, 300) : existing.instructions,
      active: typeof body.active === 'boolean' ? body.active : existing.active,
    },
  })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'payment_method_updated',
    detail: `Editó el método de cobro "${updated.label}"`,
  })
  return NextResponse.json(updated)
}

// DELETE /api/payment-methods/[id] — eliminar
export async function DELETE(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const sess = await requireAdmin(req)
  if (!sess) {
    return NextResponse.json(
      { error: 'Solo el administrador puede eliminar las cuentas de cobro' },
      { status: 403 }
    )
  }
  const { id } = await params
  const existing = await db.paymentMethod.findUnique({ where: { id } })
  if (!existing) {
    return NextResponse.json({ error: 'Método de cobro no encontrado' }, { status: 404 })
  }
  await db.paymentMethod.delete({ where: { id } })
  await logSecurityEvent({
    userId: sess.user.id,
    userName: sess.user.name,
    type: 'payment_method_deleted',
    detail: `Eliminó el método de cobro "${existing.label}"`,
  })
  return NextResponse.json({ ok: true })
}
