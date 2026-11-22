// ============================================================
// API de un método de cobro: editar o eliminar
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

// PATCH /api/payment-methods/[id] — editar
export async function PATCH(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const body = await req.json()
  const existing = await db.paymentMethod.findUnique({ where: { id } })
  if (!existing) {
    return NextResponse.json({ error: 'Método de cobro no encontrado' }, { status: 404 })
  }
  const updated = await db.paymentMethod.update({
    where: { id },
    data: {
      label: body.label !== undefined ? String(body.label).trim() : existing.label,
      details: body.details !== undefined ? String(body.details).trim() : existing.details,
      holder: body.holder !== undefined ? String(body.holder).trim() : existing.holder,
      instructions:
        body.instructions !== undefined ? String(body.instructions).trim() : existing.instructions,
      active: typeof body.active === 'boolean' ? body.active : existing.active,
    },
  })
  return NextResponse.json(updated)
}

// DELETE /api/payment-methods/[id] — eliminar
export async function DELETE(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const existing = await db.paymentMethod.findUnique({ where: { id } })
  if (!existing) {
    return NextResponse.json({ error: 'Método de cobro no encontrado' }, { status: 404 })
  }
  await db.paymentMethod.delete({ where: { id } })
  return NextResponse.json({ ok: true })
}
