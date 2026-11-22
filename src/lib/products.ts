// ============================================================
// AYUDANTES DE LA TIENDA: categorías y formatos de las monedas
// El catálogo ahora vive en la base de datos (/api/catalog):
// las ofertas las publican el administrador y las mini tiendas.
// ============================================================

export const CATEGORIES = [
  'Electrónica',
  'Computadoras',
  'Hogar y cocina',
  'Belleza',
  'Deportes',
  'Ropa',
  'Juguetes',
]

// Precio en dinero real: la tienda funciona en CUP (peso cubano).
// Ej: 1250 -> "1.250 CUP" · 1250.5 -> "1.250,50 CUP"
export const formatPrice = (n: number) => {
  const v = Math.round(n * 100) / 100
  const s =
    v % 1 === 0
      ? v.toLocaleString('es')
      : v.toLocaleString('es', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  return `${s} CUP`
}

// Formato de las monedas internas de la tienda (ej: 1.500)
export const formatCoins = (n: number) => `${Math.round(n).toLocaleString('es')}`

// Convierte dinero real a monedas según la tasa de cambio del sitio
export const cashToCoins = (cash: number, rate: number) => Math.round(cash * rate)
