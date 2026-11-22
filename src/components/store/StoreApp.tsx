'use client'
// ============================================================
// APLICACIÓN PRINCIPAL DE LA TIENDA
// Cambia entre: inicio, búsqueda, categoría, producto, carrito,
// mini tiendas, trabajo de domicilio, pedidos, entregas,
// mini correo y panel del administrador.
// ============================================================
import { useEffect } from 'react'
import { Toaster } from 'sonner'
import { useStore } from '@/lib/store'
import { TopNav, SubNav } from './TopNav'
import { HomeCatalog } from './Cards'
import { SearchView, CategoryView, ProductDetail, CartView } from './Views'
import { MiniStoresView, MiniStoreDetail, ManageStoreView } from './MiniStores'
import { JobsView } from './Jobs'
import { CheckoutView } from './Checkout'
import { OrdersView } from './Orders'
import { DeliveriesView } from './Deliveries'
import { InboxView } from './Inbox'
import { WalletView } from './Wallet'
import { AdminView } from './AdminPanel'
import { AuthView } from './Auth'
import { Footer } from './Footer'

export default function StoreApp() {
  const view = useStore((s) => s.view)
  const productId = useStore((s) => s.productId)
  const searchQuery = useStore((s) => s.searchQuery)
  const category = useStore((s) => s.category)

  // Al cambiar de vista, subir al inicio de la página
  useEffect(() => {
    window.scrollTo({ top: 0 })
  }, [view, productId, searchQuery, category])

  return (
    <div
      className="min-h-screen flex flex-col bg-white text-[#0F1111]"
      style={{ fontFamily: 'Arial, Helvetica, sans-serif' }}
    >
      <TopNav />
      <SubNav />

      <main className="flex-1 flex flex-col">
        {view === 'home' && <HomeCatalog />}
        {view === 'search' && <SearchView />}
        {view === 'category' && <CategoryView />}
        {view === 'product' && <ProductDetail />}
        {view === 'cart' && <CartView />}
        {view === 'login' && <AuthView />}
        {view === 'ministores' && <MiniStoresView />}
        {view === 'ministore' && <MiniStoreDetail />}
        {view === 'manage-store' && <ManageStoreView />}
        {view === 'jobs' && <JobsView />}
        {view === 'checkout' && <CheckoutView />}
        {view === 'orders' && <OrdersView />}
        {view === 'deliveries' && <DeliveriesView />}
        {view === 'inbox' && <InboxView />}
        {view === 'wallet' && <WalletView />}
        {view === 'admin' && <AdminView />}
      </main>

      <Footer />

      {/* Notificaciones (toast) */}
      <Toaster
        position="top-center"
        richColors
        toastOptions={{
          style: { fontFamily: 'Arial, Helvetica, sans-serif' },
        }}
      />
    </div>
  )
}
