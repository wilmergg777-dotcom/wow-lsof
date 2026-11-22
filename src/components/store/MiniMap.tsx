'use client'
// ============================================================
// MINI MAPA INTERACTIVO DE VIOLETERO
// Un mapa de la ciudad dibujado con SVG. Al hacer clic se
// coloca el pin del lugar de entrega. El centro es el punto
// de partida de los repartidores (Centro Violetero).
// ============================================================
import { useState } from 'react'

export const MAP_CENTER = { x: 50, y: 50 }

type Props = {
  x: number | null // posición del pin (0-100)
  y: number | null
  onPick?: (x: number, y: number) => void // si se pasa, el mapa es clicable
  height?: number
  label?: string
}

export function MiniMap({ x, y, onPick, height = 300, label }: Props) {
  const [hover, setHover] = useState(false)

  // Convierte la posición del clic en coordenadas 0-100
  const handleClick = (e: React.MouseEvent<SVGSVGElement>) => {
    if (!onPick) return
    const rect = e.currentTarget.getBoundingClientRect()
    const px = ((e.clientX - rect.left) / rect.width) * 100
    const py = ((e.clientY - rect.top) / rect.height) * 100
    onPick(Math.round(Math.min(97, Math.max(3, px))), Math.round(Math.min(97, Math.max(3, py))))
  }

  return (
    <div className="relative rounded-lg overflow-hidden border border-[#d5d9d9] select-none">
      <svg
        viewBox="0 0 100 100"
        preserveAspectRatio="none"
        style={{ width: '100%', height, display: 'block', cursor: onPick ? 'crosshair' : 'default' }}
        onClick={handleClick}
        onMouseEnter={() => setHover(true)}
        onMouseLeave={() => setHover(false)}
        role="img"
        aria-label="Mini mapa de la ciudad para elegir el punto de entrega"
      >
        {/* Fondo (tierra) */}
        <rect width="100" height="100" fill="#E8EFE4" />

        {/* Manzanas de la ciudad */}
        {[
          [6, 8], [22, 8], [38, 8], [70, 8], [86, 8],
          [6, 24], [22, 24], [54, 24], [70, 24], [86, 24],
          [6, 40], [38, 40], [54, 40], [86, 40],
          [6, 56], [22, 56], [38, 56], [70, 56], [86, 56],
          [6, 72], [22, 72], [54, 72], [70, 72], [86, 72],
          [6, 88], [38, 88], [54, 88], [70, 88], [86, 88],
        ].map(([bx, by], i) => (
          <g key={i}>
            <rect x={bx} y={by} width="12" height="10" rx="1.5" fill="#D6E0CF" stroke="#C3D0B8" strokeWidth="0.4" />
            <rect x={bx + 2} y={by + 2} width="3.5" height="2.5" fill="#B9C8AC" rx="0.5" />
            <rect x={bx + 6.5} y={by + 5} width="3.5" height="2.5" fill="#B9C8AC" rx="0.5" />
          </g>
        ))}

        {/* Parque central */}
        <rect x="54" y="40" width="12" height="10" rx="2" fill="#9CC98A" stroke="#7FB36C" strokeWidth="0.5" />
        <circle cx="58" cy="43.5" r="1.6" fill="#5E9E4C" />
        <circle cx="61.5" cy="46" r="1.4" fill="#5E9E4C" />

        {/* Río diagonal */}
        <path d="M0 92 C 25 84, 40 96, 62 88 S 90 78, 100 84 L 100 100 L 0 100 Z" fill="#A9CCE3" opacity="0.85" />
        <path d="M0 92 C 25 84, 40 96, 62 88 S 90 78, 100 84" fill="none" stroke="#7FB3D5" strokeWidth="0.7" />

        {/* Calles principales (más anchas) */}
        <rect x="0" y="20" width="100" height="3" fill="white" />
        <rect x="0" y="52" width="100" height="3.4" fill="white" />
        <rect x="0" y="84" width="100" height="2.6" fill="white" />
        <rect x="34" y="0" width="3.2" height="100" fill="white" />
        <rect x="66" y="0" width="3.2" height="100" fill="white" />
        {/* Línea central de las avenidas */}
        <rect x="0" y="21.4" width="100" height="0.25" fill="#E0C149" />
        <rect x="0" y="53.6" width="100" height="0.25" fill="#E0C149" />
        <rect x="35.5" y="0" width="0.25" height="100" fill="#E0C149" />
        <rect x="67.5" y="0" width="0.25" height="100" fill="#E0C149" />

        {/* Centro Violetero (punto de partida) */}
        <g>
          <rect x="46" y="42" width="8" height="8" rx="1.6" fill="#5B21B6" />
          <path d="M50 44.2 v3.6 M48.2 46 h3.6" stroke="white" strokeWidth="0.9" strokeLinecap="round" />
          <text x="50" y="41.6" textAnchor="middle" fontSize="2.6" fill="#3B0764" fontWeight="bold">
            Centro Violetero
          </text>
        </g>

        {/* Pin del lugar de entrega */}
        {x !== null && y !== null && (
          <g>
            <ellipse cx={x} cy={y + 2.2} rx="2.2" ry="0.9" fill="rgba(0,0,0,0.25)" />
            <path
              d={`M ${x} ${y} c -3 -4.2, -3.6 -6.2, -3.6 -8 a 3.6 3.6 0 1 1 7.2 0 c 0 1.8 -0.6 3.8 -3.6 8 z`}
              fill="#D6231F"
              stroke="#8A130F"
              strokeWidth="0.35"
            />
            <circle cx={x} cy={y - 8} r="1.5" fill="white" />
          </g>
        )}
      </svg>

      {/* Pista de uso */}
      {onPick && (
        <div
          className={`absolute bottom-2 left-1/2 -translate-x-1/2 px-3 py-1.5 rounded-full text-[12px] font-bold transition-opacity pointer-events-none ${
            x !== null ? 'bg-[#0F1111]/80 text-white' : 'bg-white/95 text-[#0F1111] shadow'
          }`}
        >
          {x !== null
            ? label || 'Punto de entrega elegido'
            : hover
              ? 'Haz clic en el mapa para colocar el pin'
              : 'Haz clic en el mapa para elegir el lugar de entrega'}
        </div>
      )}
    </div>
  )
}
