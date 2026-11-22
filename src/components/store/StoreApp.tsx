'use client'
// ============================================================
// APLICACIÓN PRINCIPAL DE LA TIENDA
// Cambia entre: inicio, búsqueda, categoría, producto, carrito,
// mini tiendas, trabajo de domicilio, pedidos, entregas,
// mini correo y panel del administrador.
// PARCHES DE SEGURIDAD: al abrir la web, la identidad del
// navegador se comprueba con el servidor (/api/auth/me). Si el
// servidor no confirma la sesión, vuelve a Invitado; así nadie
// puede hacerse pasar por administrador editando el navegador.
// ============================================================
import { useEffect } from 'react'
import { Toaster } from 'sonner'
import { useStore, type Role } from '@/lib/store'
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
import { SettingsView } from './Settings'
import { AdminView } from './AdminPanel'
import { AuthView } from './Auth'
import { Footer } from './Footer'

export default function StoreApp() {
  const view = useStore((s) => s.view)
  const productId = useStore((s) => s.productId)
  const searchQuery = useStore((s) => s.searchQuery)
  const category = useStore((s) => s.category)
  const setUser = useStore((s) => s.setUser)

  // Sincronización de identidad con el servidor (una vez al cargar).
  // Manda el servidor: si no hay sesión válida, el navegador vuelve
  // a Invitado aunque tenga un rol falso guardado.
  useEffect(() => {
    let live = true
    const check = async () => {
      // Espera a que el almacen local termine de rehidratarse
      // (el usuario guardado llega después del primer render)
      const persisted = (useStore as unknown as {
        persist?: { hasHydrated: () => boolean }
      }).persist
      for (let i = 0; i < 20 && persisted && !persisted.hasHydrated(); i++) {
        await new Promise((r) => setTimeout(r, 50))
      }
      if (!live) return
      try {
        const r = await fetch('/api/auth/me')
        const d = r.ok
          ? ((await r.json()) as { user: { name: string; role: Role } | null })
          : { user: null }
        if (!live) return
        // El estado ACTUAL del almacen (ya rehidratado) manda en la comparación
        const cur = useStore.getState().user
        if (d.user) {
          if (d.user.name !== cur.name || d.user.role !== cur.role) {
            setUser({ name: d.user.name, role: d.user.role })
          }
        } else if (cur.name !== 'Invitado') {
          setUser({ name: 'Invitado', role: 'comprador' })
        }
      } catch {
        // sin conexión: no tocamos la identidad guardada
      }
    }
    check()
    return () => {
      live = false
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

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
        {view === 'settings' && <SettingsView />}
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
