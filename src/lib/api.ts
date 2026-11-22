// ============================================================
// Ayudante para llamar a las API de Violetero
// ============================================================
export async function api<T>(url: string, options?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  })
  const data = await res.json().catch(() => ({}))
  if (!res.ok) {
    throw new Error((data as { error?: string }).error || 'Error de conexión')
  }
  return data as T
}

// ---------- Tipos compartidos con la base de datos ----------
export type MiniStore = {
  id: string
  name: string
  ownerName: string
  description: string
  category: string
  emoji: string
  logo: string | null // foto/logotipo de la tienda
  color: string // color de marca
  createdAt: string
  products: MiniProduct[]
}

export type MiniProduct = {
  id: string
  storeId: string
  name: string
  description: string
  price: number // dinero real (CUP)
  priceCoins: number // monedas internas
  emoji: string
  photo: string | null
  stock: number
  createdAt: string
}

export type JobOffer = {
  id: string
  storeId: string
  title: string
  zone: string
  payment: number
  description: string
  open: boolean
  createdAt: string
  store: {
    id: string
    name: string
    emoji: string
    category: string
    ownerName: string
    logo: string | null
    color: string
  }
  applications?: { id: string; applicantName: string; status: string }[]
}

export type Application = {
  id: string
  jobId: string
  applicantName: string
  phone: string
  email: string
  vehicle: string
  message: string
  status: string // pending | accepted | rejected
  createdAt: string
  job?: JobOffer
}

export type OrderItem = { name: string; price: number; qty: number; store: string }

export type Order = {
  id: string
  code: string
  buyerName: string
  address: string
  notes: string | null
  mapX: number
  mapY: number
  items: string // JSON de OrderItem[]
  total: number
  totalCoins: number | null // monedas pagadas si el pago fue con billetera
  paymentMethod: 'cash' | 'coins' | 'transfer'
  transferId: string | null // ID de la transferencia si el pago fue por transferencia
  etaMinutes: number
  status: 'placed' | 'in_delivery' | 'delivered'
  workerName: string | null
  createdAt: string
}

export type Notification = {
  id: string
  toName: string
  title: string
  body: string
  kind: string // pedido | trabajo | tienda | sistema
  orderId: string | null
  read: boolean
  createdAt: string
}

export type Settings = {
  id: string
  miniStoresEnabled: boolean
  coinRate: number // monedas que valen 1 CUP real
  updatedAt: string
}

export type Wallet = {
  id: string
  ownerName: string
  coins: number
  guest?: boolean
}

export type TopUpRequest = {
  id: string
  userName: string
  methodName: string
  amountCash: number
  coins: number
  transferId: string
  status: 'pending' | 'approved' | 'rejected'
  adminNote: string | null
  createdAt: string
  reviewedAt: string | null
}

export type PaymentMethod = {
  id: string
  label: string
  details: string
  holder: string
  phone: string
  instructions: string
  active: boolean
}

// Oferta publicada por el dueño de la web (administrador)
export type Offer = {
  id: string
  title: string
  description: string
  category: string
  price: number // dinero real (CUP)
  priceCoins: number // monedas internas (0 = se calcula con la tasa)
  oldPrice: number | null // precio anterior para mostrar descuento
  photo: string | null // foto subida o elegida de la galería
  stock: number
  active: boolean
  createdAt: string
}

// Estados de una solicitud de recarga
export const TOPUP_STATUS: Record<TopUpRequest['status'], { label: string; color: string; bg: string }> = {
  pending: { label: 'Pendiente de revisión', color: '#B45309', bg: '#FEF3C7' },
  approved: { label: 'Aprobada', color: '#007600', bg: '#E7F7E7' },
  rejected: { label: 'Rechazada', color: '#C7511F', bg: '#FDE8E0' },
}

// Etiquetas de estado de pedido
export const ORDER_STATUS: Record<Order['status'], { label: string; color: string }> = {
  placed: { label: 'Esperando repartidor', color: '#B45309' },
  in_delivery: { label: 'En camino', color: '#1D6F42' },
  delivered: { label: 'Entregado', color: '#0F1111' },
}
