// tipos.go define los tipos base del sistema de profesiones: rangos
// (Aprendiz → Gran Maestro), recetas que consumen materiales y producen
// ítems, especializaciones, nodos de recolección, y el estado de una
// profesión aprendida por un personaje (skill + rangos).
//
// El catálogo completo (13 profesiones de WoW 3.3.5: Herrería, Alquimia,
// Joyería, Ingeniería, Sastrería, Encantamiento, Peletería, Herboristería,
// Minería, Desuello, Inscripción, Cocina, Pesca) se define en un archivo
// por profesión (profesion_*.go) y se registra en registro.go (Catalogo).
package profesiones

// MaxProfesionesPrimarias es el límite de profesiones primarias por
// personaje (regla de WoW: 2 primarias).
const MaxProfesionesPrimarias = 2

// DefRango define un rango de una profesión (Aprendiz, Oficial, ...).
// Aprender un rango sube el techo de habilidad (SkillMax) del personaje.
type DefRango struct {
	ID       string `json:"id"`
	Nombre   string `json:"nombre"`
	SkillReq int    `json:"skill_req"` // habilidad mínima para aprenderlo
	SkillMax int    `json:"skill_max"` // techo de habilidad al aprenderlo
}

// DefReceta define una receta de crafteo.
// SkillReq: habilidad mínima para craftearla.
// SkillHasta: habilidad a partir de la cual ya NO sube (se pone gris).
type DefReceta struct {
	ID              string         `json:"id"`
	Nombre          string         `json:"nombre"`
	ProfesionID     string         `json:"profesion_id"`
	ResultadoID     string         `json:"resultado_id"`
	ResultadoCantidad int          `json:"resultado_cantidad"`
	Materiales      []MaterialRec  `json:"materiales"`
	SkillReq        int            `json:"skill_req"`
	SkillHasta      int            `json:"skill_hasta"`
	Especializacion string         `json:"especializacion,omitempty"` // si requiere una especialización concreta
}

// MaterialRec es un material requerido por una receta.
type MaterialRec struct {
	ItemID   string `json:"item_id"`
	Cantidad int    `json:"cantidad"`
}

// DefEspecializacion define una rama de especialización de una profesión
// (p.ej. Peletería dragontina/elemental/tribal, o Herrería forjador de
// armaduras/armas). Se aprende a partir de SkillReq consumiendo Materiales
// (abstracción de la misión de la guía). Las especializaciones pueden
// anidarse: si RequiereEspecializacion != "", solo se puede aprender tras
// haber elegido esa especialización padre (p.ej. Herrería forjador de
// armas → maestro forjador de hachas/martillos/invocador). El estado del
// jugador guarda siempre el ID de la especialización hoja elegida.
type DefEspecializacion struct {
	ID                      string        `json:"id"`
	Nombre                  string        `json:"nombre"`
	SkillReq                int           `json:"skill_req"`
	Descripcion             string        `json:"descripcion"`
	Materiales              []MaterialRec `json:"materiales"`
	RequiereEspecializacion string        `json:"requiere_especializacion,omitempty"` // ID del padre ("" si es de nivel superior)
}

// DefNodo describe un nodo de recurso recolectable en el mundo (nodo de
// hierba, veta de mineral, piel, etc.). Las profesiones de recolección
// (Herboristería, futuras Minería / Desuello) usan Nodos en lugar de
// Recetas: el jugador Recolecta del nodo (sin consumir materiales de la
// bolsa), produce el item del nodo y gana habilidad mientras skill <
// SkillHasta. SkillReq es la habilidad mínima para poder recolectar;
// SkillHasta es el umbral a partir del cual el nodo deja de dar skill
// (equivalente al "verde" de WoW). Zona es la zona recomendada por la
// guía (solo informativo, para el cliente).
type DefNodo struct {
	ID                 string `json:"id"`
	Nombre             string `json:"nombre"`
	ProfesionID        string `json:"profesion_id"`
	Zona               string `json:"zona,omitempty"`
	ResultadoID        string `json:"resultado_id"`
	ResultadoCantidad  int    `json:"resultado_cantidad"`
	SkillReq           int    `json:"skill_req"`
	SkillHasta         int    `json:"skill_hasta"`
}

// DefProfesion define una profesión jugable.
type DefProfesion struct {
	ID             string             `json:"id"`
	Nombre         string             `json:"nombre"`
	Primaria       bool               `json:"primaria"` // true = cuenta para el límite de 2
	MaxSkill       int                `json:"max_skill"`
	Rangos         []DefRango         `json:"rangos"`
	Recetas        []DefReceta        `json:"recetas"`
	Nodos          []DefNodo          `json:"nodos,omitempty"` // profesiones de recolección (Herboristería, etc.)
	Especializaciones []DefEspecializacion `json:"especializaciones,omitempty"`
}

// EstadoProfesion es el estado de una profesión que aprendió un jugador.
// Se persiste con el personaje.
type EstadoProfesion struct {
	ProfesionID      string   `json:"profesion_id"`
	Skill            int      `json:"skill"`
	RangosAprendidos []string `json:"rangos_aprendidos"`
	Especializacion  string   `json:"especializacion,omitempty"` // ID de la especialización elegida ("" si ninguna)
}

// SkillMax devuelve el techo de habilidad actual del jugador en esta
// profesión: el SkillMax del rango más alto aprendido.
func (e *EstadoProfesion) SkillMax(def DefProfesion) int {
	max := 0
	for _, rid := range e.RangosAprendidos {
		for _, rg := range def.Rangos {
			if rg.ID == rid && rg.SkillMax > max {
				max = rg.SkillMax
			}
		}
	}
	return max
}

// RangoAprendido devuelve true si el rango con ese ID ya se aprendió.
func (e *EstadoProfesion) RangoAprendido(rangoID string) bool {
	for _, rid := range e.RangosAprendidos {
		if rid == rangoID {
			return true
		}
	}
	return false
}

