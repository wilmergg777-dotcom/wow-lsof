// profesiones_alias.go expone los tipos del subpaquete interno/profesiones
// como aliases dentro del paquete mundo. Esto permite que todo el código
// existente (jugador.go, mundo.go, conexion/sesion.go, tests) siga usando
// los nombres sin cualificar (DefProfesion, EstadoProfesion, etc.) mientras
// las definiciones viven en un paquete dedicado y modular.
//
// Los aliases (`type X = profesiones.X`) son el MISMO tipo (no una copia),
// así que los métodos definidos en el paquete profesiones son accesibles
// directamente, y las conversiones/literales funcionan sin fricción.
package mundo

import "aethelgard/servidor/interno/profesiones"

// Aliases de tipos del subpaquete profesiones.
type (
	DefRango           = profesiones.DefRango
	DefReceta          = profesiones.DefReceta
	MaterialRec        = profesiones.MaterialRec
	DefEspecializacion = profesiones.DefEspecializacion
	DefNodo            = profesiones.DefNodo
	DefProfesion       = profesiones.DefProfesion
	EstadoProfesion    = profesiones.EstadoProfesion
)

// MaxProfesionesPrimarias es el límite de profesiones primarias por PJ (2).
const MaxProfesionesPrimarias = profesiones.MaxProfesionesPrimarias

// profesionesPredefinidas devuelve el catálogo completo de profesiones,
// delegando en profesiones.Catalogo(). Mantiene la API interna que usa
// mundo.go (m.profesiones = profesionesPredefinidas()).
func profesionesPredefinidas() map[string]DefProfesion {
	return profesiones.Catalogo()
}
