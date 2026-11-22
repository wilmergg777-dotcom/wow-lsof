// ============================================================
// API de métodos de cobro del administrador (cuentas/tarjetas
// donde los usuarios envían el dinero real para recargar)
// ============================================================
import { NextResponse } from 'next/server'
import { db } from '@/lib/db'

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
        instructions: 'Edita esta tarjeta en el panel del administrador con tu cuenta real.',
        active: true,
      },
    })
    return NextResponse.json(all ? [seed] : [seed].filter((m) => m.active))
  }
  return NextResponse.json(methods)
}

// POST /api/payment-methods — agregar un método de cobro
export async function POST(req: Request) {
  const body = await req.json()
  const { label, details, holder, instructions } = body
  if (!label || !details || !holder) {
    return NextResponse.json(
      { error: 'Faltan datos: nombre de la cuenta, número y titular' },
      { status: 400 }
    )
  }
  const method = await db.paymentMethod.create({
    data: {
      label: String(label).trim(),
      details: String(details).trim(),
      holder: String(holder).trim(),
      instructions: String(instructions || '').trim(),
      active: body.active !== false,
    },
  })
  return NextResponse.json(method, { status: 201 })
}
