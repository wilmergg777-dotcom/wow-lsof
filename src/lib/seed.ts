// ============================================================
// SEMILLA DEL CATÁLOGO DE VIOLETERO
// La web NUNCA arranca vacía: la primera vez que alguien abre
// la tienda (o el panel) y todavía no hay ofertas publicadas,
// se publican automáticamente ofertas de bienvenida con fotos
// de la galería guardada (public/gallery). El administrador
// puede editarlas, ocultarlas o borrarlas como cualquier otra.
// El marcador catalogSeeded en SiteSettings garantiza que solo
// se haga UNA vez: si el administrador borra todo a propósito,
// no se vuelve a sembrar.
// ============================================================
import { db } from './db'

// Ofertas de bienvenida: fotos de la galería de la tienda,
// precios en CUP y descripciones listas para vender.
const SEED_OFFERS = [
  {
    title: 'Audífonos inalámbricos TWS',
    description:
      'Audífonos Bluetooth con estuche de carga, sonido claro y llamadas sin cables. Ideales para música, estudios y trabajo. Entrega a domicilio en toda la ciudad.',
    category: 'Electrónica',
    price: 3500,
    oldPrice: 4200,
    photo: '/gallery/audifonos-1.jpg',
    stock: 12,
  },
  {
    title: 'Altavoz Bluetooth portátil',
    description:
      'Altavoz resistente con buen volumen y batería de larga duración. Perfecto para fiestas, la playa o el patio de la casa.',
    category: 'Electrónica',
    price: 4800,
    oldPrice: null,
    photo: '/gallery/altavoz-1.jpg',
    stock: 10,
  },
  {
    title: 'Laptop lista para trabajar',
    description:
      'Computadora portátil ligera con buena batería, ideal para estudiar, trabajar y navegar. Se entrega con su cargador.',
    category: 'Computadoras',
    price: 32000,
    oldPrice: 36000,
    photo: '/gallery/laptop-1.jpg',
    stock: 5,
  },
  {
    title: 'Teclado mecánico retroiluminado',
    description:
      'Teclado mecánico con luces, teclas resistentes y cable reforzado. Muy cómodo para escribir y jugar.',
    category: 'Computadoras',
    price: 5600,
    oldPrice: null,
    photo: '/gallery/teclado-1.webp',
    stock: 8,
  },
  {
    title: 'Cafetera espresso 20 bares',
    description:
      'Cafetera con presión profesional, vaporizador para leche y portafiltro. Un café rico cada mañana sin salir de casa.',
    category: 'Hogar y cocina',
    price: 12500,
    oldPrice: 15000,
    photo: '/gallery/cafetera-1.jpg',
    stock: 6,
  },
  {
    title: 'Batidora de pie profesional',
    description:
      'Batidora con bol de acero, varias velocidades y motor potente. Para panadería, repostería y las mejores recetas de la casa.',
    category: 'Hogar y cocina',
    price: 8900,
    oldPrice: null,
    photo: '/gallery/batidora-1.jpg',
    stock: 7,
  },
  {
    title: 'Perfume floral 100 ml',
    description:
      'Fragancia fresca y duradera para el día a día o para regalar. Viene en su caja original con sellado.',
    category: 'Belleza',
    price: 4200,
    oldPrice: 5000,
    photo: '/gallery/perfume-1.jpeg',
    stock: 15,
  },
  {
    title: 'Zapatillas de correr',
    description:
      'Zapatillas ligeras con buena suela y plantilla cómoda. Para correr, caminar o usarlas todos los días.',
    category: 'Deportes',
    price: 6800,
    oldPrice: null,
    photo: '/gallery/zapatillas-1.jpg',
    stock: 9,
  },
  {
    title: 'Vestido de verano',
    description:
      'Vestido fresco de tela ligera, corte bonito y colores alegres. Tallas disponibles al confirmar el pedido.',
    category: 'Ropa',
    price: 3200,
    oldPrice: 3900,
    photo: '/gallery/vestido-1.jpg',
    stock: 10,
  },
  {
    title: 'Peluche grande de regalo',
    description:
      'Peluche suave y grande, ideal para cumpleaños, San Valentín o cualquier detalle. Se entrega limpio y en bolsa.',
    category: 'Juguetes',
    price: 1900,
    oldPrice: null,
    photo: '/gallery/juguete-1.jpg',
    stock: 14,
  },
]

// Garantiza que el catálogo tenga contenido la primera vez.
// Se llama al leer /api/catalog y /api/offers; si ya se sembró
// antes, solo hace una lectura barata y no vuelve a crear nada.
export async function ensureCatalogSeed() {
  const settings = await db.siteSettings.findUnique({ where: { id: 'main' } })
  if (settings?.catalogSeeded) return

  // Crea los ajustes si no existen (instalación recién hecha)
  const st =
    settings ??
    (await db.siteSettings.create({
      data: { id: 'main', catalogSeeded: false },
    }))
  if (st.catalogSeeded) return

  // Publica las ofertas de bienvenida en bloque
  await db.offer.createMany({
    data: SEED_OFFERS.map((o) => ({
      title: o.title,
      description: o.description,
      category: o.category,
      price: o.price,
      oldPrice: o.oldPrice,
      photo: o.photo,
      stock: o.stock,
    })),
  })

  await db.siteSettings.update({
    where: { id: 'main' },
    data: { catalogSeeded: true },
  })
}
