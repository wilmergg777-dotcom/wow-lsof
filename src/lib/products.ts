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

export const formatPrice = (n: number) => `$${n.toFixed(2)}`

// Formato de las monedas internas de la tienda (ej: 1.500)
export const formatCoins = (n: number) => `${Math.round(n).toLocaleString('es')}`

// Convierte dinero real a monedas según la tasa de cambio del sitio
export const cashToCoins = (cash: number, rate: number) => Math.round(cash * rate)
