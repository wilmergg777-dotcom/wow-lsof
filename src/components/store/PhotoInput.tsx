'use client'
// ============================================================
// ELEGIR FOTO PARA LAS PUBLICACIONES
// Dos formas de ponerle foto a una oferta:
// 1. Subir una foto propia del dispositivo (se comprime aquí)
// 2. Elegir una de las fotos guardadas en la tienda (galería)
//    para quienes no tienen foto de lo que venden.
// ============================================================
import { useRef, useState } from 'react'
import { ImagePlus, Loader2, Store, Trash2 } from 'lucide-react'
import { GALLERY } from '@/lib/gallery'

type Props = {
  value: string | null
  onChange: (dataUrl: string | null) => void
  label?: string
  shape?: 'square' | 'circle'
  width?: number // ancho del área de vista previa
  maxSize?: number // lado máximo tras comprimir (px)
  withGallery?: boolean // permitir elegir una foto guardada en la tienda
}

export function PhotoInput({
  value,
  onChange,
  label = 'Subir foto',
  shape = 'square',
  width = 128,
  maxSize = 640,
  withGallery = false,
}: Props) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [tab, setTab] = useState<'upload' | 'gallery'>('upload')

  const pick = (file: File | undefined) => {
    setError('')
    if (!file) return
    if (!file.type.startsWith('image/')) {
      setError('El archivo debe ser una imagen (JPG o PNG)')
      return
    }
    setBusy(true)
    const reader = new FileReader()
    reader.onload = () => {
      const img = new Image()
      img.onload = () => {
        // Redimensionar manteniendo proporciones
        const scale = Math.min(1, maxSize / Math.max(img.width, img.height))
        const w = Math.max(1, Math.round(img.width * scale))
        const h = Math.max(1, Math.round(img.height * scale))
        const canvas = document.createElement('canvas')
        canvas.width = w
        canvas.height = h
        const ctx = canvas.getContext('2d')
        if (!ctx) {
          setBusy(false)
          setError('No se pudo procesar la imagen')
          return
        }
        ctx.drawImage(img, 0, 0, w, h)
        onChange(canvas.toDataURL('image/jpeg', 0.78))
        setBusy(false)
      }
      img.onerror = () => {
        setBusy(false)
        setError('No se pudo leer la imagen')
      }
      img.src = String(reader.result)
    }
    reader.onerror = () => {
      setBusy(false)
      setError('No se pudo leer el archivo')
    }
    reader.readAsDataURL(file)
  }

  return (
    <div>
      {label && (
        <label className="block text-[13px] font-bold text-[#0F1111] mb-1">{label}</label>
      )}
      <div className="flex items-start gap-3">
        {/* Vista previa de la foto elegida */}
        {value ? (
          <div
            className={`relative shrink-0 overflow-hidden border border-[#d5d9d9] ${
              shape === 'circle' ? 'rounded-full' : 'rounded-lg'
            }`}
            style={{ width, height: width }}
          >
            <img src={value} alt="Foto elegida" className="w-full h-full object-cover" />
            <button
              onClick={() => onChange(null)}
              aria-label="Quitar foto"
              className="absolute top-1 right-1 bg-white/90 hover:bg-white rounded-full p-1 border border-[#d5d9d9] cursor-pointer"
            >
              <Trash2 className="w-3.5 h-3.5 text-[#C7511F]" />
            </button>
          </div>
        ) : (
          <div className="shrink-0" style={{ width }}>
            {/* Pestañas: subir propia o elegir de la tienda */}
            {withGallery && (
              <div className="flex mb-1.5" role="tablist" aria-label="Forma de elegir la foto">
                <button
                  type="button"
                  role="tab"
                  aria-selected={tab === 'upload'}
                  onClick={() => setTab('upload')}
                  className={`flex-1 text-[11px] font-bold rounded-l-md py-1.5 cursor-pointer border ${
                    tab === 'upload'
                      ? 'bg-[#5B21B6] text-white border-[#5B21B6]'
                      : 'bg-[#f7fafa] text-[#565959] border-[#d5d9d9] hover:border-[#5B21B6]'
                  }`}
                >
                  <ImagePlus className="w-3.5 h-3.5 inline mr-1 -mt-0.5" />
                  Subir
                </button>
                <button
                  type="button"
                  role="tab"
                  aria-selected={tab === 'gallery'}
                  onClick={() => setTab('gallery')}
                  className={`flex-1 text-[11px] font-bold rounded-r-md py-1.5 cursor-pointer border -ml-px ${
                    tab === 'gallery'
                      ? 'bg-[#5B21B6] text-white border-[#5B21B6]'
                      : 'bg-[#f7fafa] text-[#565959] border-[#d5d9d9] hover:border-[#5B21B6]'
                  }`}
                >
                  <Store className="w-3.5 h-3.5 inline mr-1 -mt-0.5" />
                  De la tienda
                </button>
              </div>
            )}

            {tab === 'upload' || !withGallery ? (
              /* Subir una foto desde el dispositivo */
              <button
                type="button"
                onClick={() => inputRef.current?.click()}
                className={`w-full bg-[#f7fafa] border-2 border-dashed border-[#d5d9d9] hover:border-[#5B21B6] flex flex-col items-center justify-center gap-1.5 cursor-pointer transition-colors ${
                  shape === 'circle' ? 'rounded-full' : 'rounded-lg'
                }`}
                style={{ width, height: width }}
              >
                {busy ? (
                  <Loader2 className="w-6 h-6 text-[#5B21B6] animate-spin" />
                ) : (
                  <ImagePlus className="w-6 h-6 text-[#565959]" />
                )}
                <span className="text-[11px] text-[#565959] px-2 text-center leading-tight">
                  {busy ? 'Procesando…' : label}
                </span>
              </button>
            ) : (
              /* Galería de fotos guardadas en la tienda */
              <div
                className="w-full rounded-lg border border-[#d5d9d9] bg-[#f7fafa] p-2 overflow-y-auto grid grid-cols-3 gap-2"
                style={{ maxHeight: width * 2 + 16 }}
                role="listbox"
                aria-label="Fotos guardadas en la tienda"
              >
                {GALLERY.map((g) => (
                  <button
                    key={g.src}
                    type="button"
                    onClick={() => onChange(g.src)}
                    title={g.label}
                    aria-label={`Usar foto de ${g.label}`}
                    className="aspect-square rounded-md overflow-hidden border border-[#d5d9d9] hover:ring-2 hover:ring-[#5B21B6] cursor-pointer bg-white"
                  >
                    <img
                      src={g.src}
                      alt={g.label}
                      loading="lazy"
                      className="w-full h-full object-cover"
                    />
                  </button>
                ))}
              </div>
            )}
          </div>
        )}

        <div className="text-[12px] text-[#565959] self-center">
          {withGallery ? (
            <p>
              Sube la foto de lo que vendes o elige una de las fotos guardadas en la tienda si no
              tienes una. JPG o PNG; se reduce automáticamente para cargar rápido.
            </p>
          ) : (
            <p>JPG o PNG. Se reduce automáticamente para cargar rápido.</p>
          )}
          {error && <p className="text-[#C7511F] font-bold mt-1">{error}</p>}
        </div>
      </div>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="sr-only"
        aria-label={label}
        onChange={(e) => {
          pick(e.target.files?.[0])
          e.target.value = '' // permite elegir la misma foto dos veces
        }}
      />
    </div>
  )
}
