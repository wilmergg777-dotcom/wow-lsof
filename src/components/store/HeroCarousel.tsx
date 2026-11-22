'use client'
// ============================================================
// CARRUSEL HÉROE DEL INICIO (estilo Violetero/Amazon)
// Se construye con las ofertas publicadas de verdad:
// - Sin ofertas: una sola tarjeta de bienvenida, sin fotos.
// - Con ofertas: tarjeta de ofertas con descuento y una
//   tarjeta por departamento con fotos reales publicadas.
// ============================================================
import { useEffect, useRef, useState } from 'react'
import { ChevronLeft, ChevronRight, Pause, Play, Sparkles } from 'lucide-react'
import { useStore, STORE_NAME } from '@/lib/store'
import { itemDiscount, type CatalogItem } from '@/lib/catalog'

type HeroCard = {
  eyebrow: string
  title: string
  sub?: string
  target: string | null // categoría a la que navega (null: no navega)
  images: string[]
}

// Construye las tarjetas del carrusel con el catálogo real
function buildCards(items: CatalogItem[]): HeroCard[] {
  const cards: HeroCard[] = []

  const deals = items.filter((it) => itemDiscount(it) > 0)
  if (deals.length > 0) {
    cards.push({
      eyebrow: 'Ahorra en Violetero',
      title: 'Ofertas con descuento',
      sub: 'Publicadas por la tienda y las mini tiendas',
      target: 'Ofertas',
      images: deals.map((d) => d.photo).filter(Boolean).slice(0, 3) as string[],
    })
  }

  const latest = {
    eyebrow: '',
    title: 'Recién publicadas',
    sub: `Lo último que salió a la venta en ${STORE_NAME}`,
    target: 'Todos',
    images: items.map((it) => it.photo).filter(Boolean).slice(0, 3) as string[],
  }
  cards.push(latest)

  // Una tarjeta por departamento con ofertas
  const counts = new Map<string, CatalogItem[]>()
  for (const it of items) {
    const list = counts.get(it.category) || []
    list.push(it)
    counts.set(it.category, list)
  }
  ;[...counts.entries()]
    .sort((a, b) => b[1].length - a[1].length)
    .slice(0, 4)
    .forEach(([cat, list]) => {
      cards.push({
        eyebrow: `Publicadas en ${cat}`,
        title: `Novedades en ${cat}`,
        target: cat,
        images: list.map((it) => it.photo).filter(Boolean).slice(0, 3) as string[],
      })
    })

  return cards
}

export function HeroCarousel({ items }: { items: CatalogItem[] }) {
  const openCategory = useStore((s) => s.openCategory)
  const openView = useStore((s) => s.openView)
  const trackRef = useRef<HTMLDivElement>(null)
  const [paused, setPaused] = useState(false)

  const cards = buildCards(items)

  // Desplazamiento automático cada 5 segundos (solo con varias tarjetas)
  useEffect(() => {
    if (paused || cards.length < 2) return
    const timer = setInterval(() => {
      const track = trackRef.current
      if (!track) return
      const atEnd =
        track.scrollLeft + track.clientWidth >= track.scrollWidth - 20
      track.scrollBy({ left: atEnd ? -track.scrollLeft : 366, behavior: 'smooth' })
    }, 5000)
    return () => clearInterval(timer)
  }, [paused, cards.length])

  const scroll = (dir: 1 | -1) =>
    trackRef.current?.scrollBy({ left: dir * 366, behavior: 'smooth' })

  // ---------- Sin ofertas: tarjeta de bienvenida sin fotos ----------
  if (items.length === 0) {
    return (
      <section className="relative bg-white pt-3 pb-2" aria-label="Bienvenida a Violetero">
        <div className="px-4">
          <div
            className="relative flex flex-col w-full max-w-[700px] mx-auto h-[280px] rounded-2xl overflow-hidden text-left"
            style={{
              background:
                'linear-gradient(140deg, #8B5CF6 0%, #6D28D9 55%, #5B21B6 100%)',
            }}
          >
            <div
              className="absolute inset-0 opacity-40"
              style={{
                background:
                  'radial-gradient(circle at 80% 20%, rgba(255,255,255,0.35), transparent 55%)',
              }}
              aria-hidden="true"
            />
            <div className="relative z-10 px-7 pt-8">
              <p className="text-white/90 text-[15px] font-semibold flex items-center gap-2">
                <Sparkles className="w-5 h-5" /> Bienvenido a {STORE_NAME}
              </p>
              <h2 className="text-white text-[32px] leading-[1.1] font-extrabold mt-2 max-w-[420px]">
                Tu tienda empieza hoy: publica la primera oferta
              </h2>
              <p className="text-white/95 text-[15px] font-semibold mt-2 max-w-[440px]">
                Con foto, nombre y precio en las dos monedas. Sin ofertas guardadas: aquí solo se
                muestra lo que publiques de verdad.
              </p>
              <button
                onClick={() => openView('admin')}
                className="mt-5 self-start bg-[#FFD814] hover:bg-[#F7CA00] text-[#0F1111] text-[14px] font-bold rounded-full px-6 py-2.5 cursor-pointer"
              >
                Publicar una oferta
              </button>
            </div>
          </div>
        </div>
      </section>
    )
  }

  // ---------- Con ofertas: tarjetas con fotos reales ----------
  return (
    <section className="relative bg-white pt-3 pb-2" aria-label="Ofertas publicadas">
      {/* Tarjetas */}
      <div
        ref={trackRef}
        className="flex gap-3 overflow-x-auto px-4 snap-x snap-mandatory"
        style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
      >
        {cards.map((card, i) => (
          <button
            key={i}
            onClick={() => card.target && openCategory(card.target)}
            className="relative flex flex-col shrink-0 w-[330px] md:w-[350px] h-[400px] rounded-2xl overflow-hidden text-left snap-start cursor-pointer transition-transform hover:scale-[1.015]"
            style={{
              background:
                'linear-gradient(140deg, #8B5CF6 0%, #6D28D9 55%, #5B21B6 100%)',
            }}
            aria-label={`${card.title} ${card.sub ?? ''}`}
          >
            {/* Brillo decorativo */}
            <div
              className="absolute inset-0 opacity-40"
              style={{
                background:
                  'radial-gradient(circle at 80% 20%, rgba(255,255,255,0.35), transparent 55%)',
              }}
              aria-hidden="true"
            />
            {/* Textos */}
            <div className="relative z-10 px-5 pt-5">
              {card.eyebrow && (
                <p className="text-white text-[17px] font-semibold leading-tight">
                  {card.eyebrow}
                </p>
              )}
              <h2
                className="text-[30px] leading-[1.05] font-extrabold mt-1 text-white"
                style={{ fontFamily: 'Arial, Helvetica, sans-serif' }}
              >
                {card.title}
              </h2>
              {card.sub && (
                <p className="text-white/95 text-[16px] font-semibold mt-1 line-clamp-2">
                  {card.sub}
                </p>
              )}
            </div>
            {/* Collage de fotos publicadas (solo si hay fotos) */}
            {card.images.length > 0 && (
              <div className="absolute inset-x-0 bottom-0 h-[230px]" aria-hidden="true">
                <img
                  src={card.images[0]}
                  alt=""
                  className="absolute left-1 bottom-8 w-[150px] h-[150px] object-cover rounded-xl shadow-[0_14px_28px_rgba(60,10,0,0.45)] -rotate-6"
                />
                {card.images[1] && (
                  <img
                    src={card.images[1]}
                    alt=""
                    className="absolute left-1/2 -translate-x-1/2 bottom-14 w-[170px] h-[170px] object-cover rounded-xl shadow-[0_16px_30px_rgba(60,10,0,0.5)] rotate-2"
                  />
                )}
                {card.images[2] && (
                  <img
                    src={card.images[2]}
                    alt=""
                    className="absolute right-1 bottom-6 w-[145px] h-[145px] object-cover rounded-xl shadow-[0_14px_28px_rgba(60,10,0,0.45)] rotate-6"
                  />
                )}
              </div>
            )}
          </button>
        ))}
      </div>

      {/* Flechas */}
      {cards.length > 1 && (
        <>
          <button
            onClick={() => scroll(-1)}
            className="absolute left-1 top-1/2 -translate-y-1/2 bg-white/95 hover:bg-white rounded-full w-11 h-11 flex items-center justify-center shadow-lg cursor-pointer z-10"
            aria-label="Tarjetas anteriores"
          >
            <ChevronLeft className="w-6 h-6 text-[#333]" />
          </button>
          <button
            onClick={() => scroll(1)}
            className="absolute right-1 top-1/2 -translate-y-1/2 bg-white/95 hover:bg-white rounded-full w-11 h-11 flex items-center justify-center shadow-lg cursor-pointer z-10"
            aria-label="Siguientes tarjetas"
          >
            <ChevronRight className="w-6 h-6 text-[#333]" />
          </button>

          {/* Pausa / reproducir */}
          <button
            onClick={() => setPaused((p) => !p)}
            className="absolute left-6 bottom-4 bg-white/95 hover:bg-white rounded-full w-9 h-9 flex items-center justify-center shadow-md cursor-pointer z-10"
            aria-label={paused ? 'Reproducir desplazamiento' : 'Pausar desplazamiento'}
          >
            {paused ? (
              <Play className="w-4 h-4 text-[#333]" />
            ) : (
              <Pause className="w-4 h-4 text-[#333]" />
            )}
          </button>
        </>
      )}
    </section>
  )
}
