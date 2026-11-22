// ============================================================
// ESTADO GLOBAL DE LA TIENDA (carrito + navegación + usuario)
// Usa Zustand. El carrito y el usuario se guardan en el
// navegador (localStorage), así que no se pierden al recargar.
// ============================================================
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// Nombre de tu tienda (cámbialo por el nombre que quieras)
export const STORE_NAME = 'Violetero'

export type View =
  | 'home'
  | 'search'
  | 'category'
  | 'product'
  | 'cart'
  | 'login' // registro e inicio de sesión
  | 'ministores' // lista de mini tiendas
  | 'ministore' // detalle de una mini tienda
  | 'manage-store' // panel del dueño de la mini tienda
  | 'jobs' // ofertas de trabajo de domicilio
  | 'checkout' // dirección + mini mapa + confirmar
  | 'orders' // mis pedidos (comprador)
  | 'deliveries' // entregas (repartidor)
  | 'inbox' // mini correo interno
  | 'wallet' // billetera de monedas + recargas
  | 'settings' // ajustes de cuenta: contacto, contraseña, sesiones
  | 'admin' // panel del administrador

export type Role = 'comprador' | 'vendedor' | 'repartidor' | 'administrador'

export const ROLE_LABELS: Record<Role, string> = {
  comprador: 'Comprador',
  vendedor: 'Vendedor',
  repartidor: 'Repartidor',
  administrador: 'Administrador',
}

// Artículo del carrito. Los productos de mini tiendas llevan
// una "foto" de sus datos (mini) para poder mostrarlos sin buscar.
export type CartItem = {
  id: string
  qty: number
  mini?: {
    name: string
    price: number
    priceCoins?: number
    photo?: string
    storeName: string
    productId?: string // id real en la base para descontar del almacén
    kind?: 'web' | 'mini' // oferta del administrador o producto de mini tienda
    stock?: number // unidades disponibles al agregar al carrito
  }
}

type StoreState = {
  cart: CartItem[]
  view: View
  productId: string | null // producto abierto en detalle
  storeId: string | null // mini tienda abierta en detalle
  searchQuery: string // texto del buscador
  category: string // categoría seleccionada
  searchCategory: string // categoría elegida en el buscador ("Todos" por defecto)
  orderPlaced: boolean // confirma la compra en el carrito
  user: { name: string; role: Role } // identidad simulada del usuario actual
  addToCart: (id: string, qty?: number, mini?: CartItem['mini']) => void
  removeFromCart: (id: string) => void
  setQty: (id: string, qty: number) => void
  clearCart: () => void
  goHome: () => void
  openProduct: (id: string) => void
  openSearch: (query: string) => void
  openCategory: (category: string) => void
  openCart: () => void
  setSearchCategory: (c: string) => void
  placeOrder: () => void
  openView: (view: View) => void
  openMiniStore: (id: string) => void
  setUser: (user: { name: string; role: Role }) => void
}

export const useStore = create<StoreState>()(
  persist(
    (set) => ({
      cart: [],
      view: 'home',
      productId: null,
      storeId: null,
      searchQuery: '',
      category: '',
      searchCategory: 'Todos',
      orderPlaced: false,
      user: { name: 'Invitado', role: 'comprador' },

      addToCart: (id, qty = 1, mini) =>
        set((state) => {
          const existing = state.cart.find((i) => i.id === id)
          const cart = existing
            ? state.cart.map((i) => (i.id === id ? { ...i, qty: i.qty + qty } : i))
            : [...state.cart, { id, qty, ...(mini ? { mini } : {}) }]
          return { cart }
        }),

      removeFromCart: (id) =>
        set((state) => ({ cart: state.cart.filter((i) => i.id !== id) })),

      setQty: (id, qty) =>
        set((state) => ({
          cart:
            qty <= 0
              ? state.cart.filter((i) => i.id !== id)
              : state.cart.map((i) => (i.id === id ? { ...i, qty } : i)),
        })),

      clearCart: () => set({ cart: [] }),

      goHome: () =>
        set({ view: 'home', productId: null, searchQuery: '', orderPlaced: false }),

      openProduct: (id) => set({ view: 'product', productId: id, orderPlaced: false }),

      openSearch: (query) =>
        set({ view: 'search', searchQuery: query, orderPlaced: false }),

      openCategory: (category) =>
        set({ view: 'category', category, orderPlaced: false }),

      openCart: () => set({ view: 'cart', orderPlaced: false }),

      setSearchCategory: (c) => set({ searchCategory: c }),

      placeOrder: () => set({ cart: [], orderPlaced: true }),

      openView: (view) => set({ view, orderPlaced: false }),

      openMiniStore: (id) => set({ view: 'ministore', storeId: id, orderPlaced: false }),

      setUser: (user) => set({ user }),
    }),
    {
      name: 'violetero-carrito', // clave en localStorage
      partialize: (state) => ({ cart: state.cart, user: state.user }), // guardar carrito y usuario
    }
  )
)
