// Package proto define el protocolo de red compartido entre el servidor
// y los clientes. El transporte es TCP con frames de longitud prefijada:
//
//   [4 bytes: uint32 little-endian = longitud N][N bytes: JSON]
//
// Todos los mensajes llevan un campo "tipo" que identifica su kind.
// El cliente Godot replica exactamente estos structs en GDScript.
//
// Este paquete NO depende de mundo/auth/persistencia para evitar ciclos
// de import: solo depende de geometria.
package proto

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"

	"aethelgard/servidor/interno/geometria"
)

// LongitudMáximaMensaje protege contra frames maliciosos o corruptos.
const LongitudMáximaMensaje = 1 << 20 // 1 MiB

// Vec3 y Vec4 se reexportan desde geometria para que los consumidores de
// proto no tengan que importar geometria también.
type Vec3 = geometria.Vec3
type Vec4 = geometria.Vec4

// ─── Mensajes cliente → servidor ────────────────────────────────────────

// MensajeCliente es la unión discriminada de mensajes que envía el cliente.
// El campo Tipo determina qué struct de payload interpretar.
type MensajeCliente struct {
	Tipo      string          `json:"tipo"`
	Payload   json.RawMessage `json:"payload,omitempty"`
	Usuario   string          `json:"usuario,omitempty"`
	Password  string          `json:"password,omitempty"`
	Nombre    string          `json:"nombre,omitempty"`
	Clase     string          `json:"clase,omitempty"`
	Faccion   string          `json:"faccion,omitempty"`   // "alianza" | "horda" (crear_pj)
	Raza      string          `json:"raza,omitempty"`      // "humano" | "orco" | ... (crear_pj)
	Pos       *Vec3           `json:"pos,omitempty"`
	Rot       *Vec4           `json:"rot,omitempty"`
	Objetivo  string          `json:"objetivo,omitempty"`   // ID del objetivo (tab-target)
	Habilidad string          `json:"habilidad,omitempty"`  // ID de la habilidad
	Activo    bool            `json:"activo,omitempty"`     // Para toggles como auto-ataque
	MasmoraID string          `json:"masmora_id,omitempty"` // cola_pve_entrar
	ArenaID   string          `json:"arena_id,omitempty"`   // cola_pvp_entrar
	ProfesionID string        `json:"profesion_id,omitempty"` // aprender_profesion / craftear
	RecetaID  string          `json:"receta_id,omitempty"`  // craftear
	RangoID   string          `json:"rango_id,omitempty"`   // aprender_rango
	EspecializacionID string  `json:"especializacion_id,omitempty"` // aprender_especializacion
}

// ─── Mensajes servidor → cliente ────────────────────────────────────────

type MensajeServidor struct {
	Tipo            string            `json:"tipo"`
	OK              bool              `json:"ok,omitempty"`
	Error           string            `json:"error,omitempty"`
	Personajes      []PersonajeRes    `json:"personajes,omitempty"`
	PersonajePropio *EntidadSnapshot  `json:"personaje_propio,omitempty"`
	Tick            uint64            `json:"tick,omitempty"`
	Entidades       []EntidadSnapshot `json:"entidades,omitempty"`
	EstadoPJ        *EstadoCombate    `json:"estado_pj,omitempty"`
	OrigenID        string            `json:"origen_id,omitempty"`
	ObjetivoID      string            `json:"objetivo_id,omitempty"`
	Cantidad        int               `json:"cantidad,omitempty"`
	Critico         bool              `json:"critico,omitempty"`
	EntidadID       string            `json:"entidad_id,omitempty"`
	Mensaje         string            `json:"mensaje,omitempty"`
	// Facciones / razas / clases / masmoras / arenas (metadata enviada al cliente)
	Facciones       []FaccionRes      `json:"facciones,omitempty"`
	Razas           []RazaRes         `json:"razas,omitempty"`
	Clases          []ClaseRes        `json:"clases,omitempty"`
	Masmoras        []MasmoraRes      `json:"masmoras,omitempty"`
	Arenas          []ArenaRes        `json:"arenas,omitempty"`
	// Profesiones / recetas / items / inventario (metadata + estado)
	Profesiones     []ProfesionRes    `json:"profesiones,omitempty"`     // catálogo completo (login)
	Recetas         []RecetaRes       `json:"recetas,omitempty"`         // catálogo de recetas (login)
	Items           []ItemRes         `json:"items,omitempty"`           // catálogo de ítems (login)
	EstadoProfesiones []EstadoProfesionRes `json:"estado_profesiones,omitempty"` // estado del PJ (sel_pj / cambios)
	Inventario      []ItemStackRes    `json:"inventario,omitempty"`      // inventario del PJ (sel_pj / cambios)
	// Resultados de crafteo / aprender profesión
	Crafteo         *CrafteoRes       `json:"crafteo,omitempty"`
	Aprendido       *AprendidoRes     `json:"aprendido,omitempty"`
	// Buscador de masmorras / PvP
	InstanciaID     string            `json:"instancia_id,omitempty"`
	InstanciaTipo   string            `json:"instancia_tipo,omitempty"` // "masmora" | "arena_pvp"
	Equipo          int               `json:"equipo,omitempty"`        // 0 | 1 (PvP)
	Grupo           []string          `json:"grupo,omitempty"`         // nombres en el grupo
	EnCola          bool              `json:"en_cola,omitempty"`
	TiempoColaMs    int               `json:"tiempo_cola_ms,omitempty"`
	JugadoresEnCola int               `json:"jugadores_en_cola,omitempty"`
	MasmoraID       string            `json:"masmora_id,omitempty"`
	ArenaID         string            `json:"arena_id,omitempty"`
	Resultado       string            `json:"resultado,omitempty"` // "victoria" | "derrota" | "empate"
	Razon           string            `json:"razon,omitempty"`     // por qué terminó la instancia
}

// FaccionRes es la representación de una facción jugable para el cliente.
type FaccionRes struct {
	ID     string `json:"id"`
	Nombre string `json:"nombre"`
}

// RazaRes es la representación de una raza jugable para el cliente.
type RazaRes struct {
	ID           string   `json:"id"`
	Nombre       string   `json:"nombre"`
	Faccion      string   `json:"faccion"`
	Clases       []string `json:"clases"`
	RacialNombre string   `json:"racial_nombre"`
	RacialDesc   string   `json:"racial_desc"`
}

// ClaseRes es la representación de una clase jugable para el cliente.
type ClaseRes struct {
	ID       string `json:"id"`
	Nombre   string `json:"nombre"`
	Rol      string `json:"rol"`
}

// ItemRes es la representación de un ítem para el cliente.
type ItemRes struct {
	ID      string `json:"id"`
	Nombre  string `json:"nombre"`
	Tipo    string `json:"tipo"`
	Calidad string `json:"calidad"`
	Stack   int    `json:"stack"`
}

// ItemStackRes es una pila del inventario del jugador.
type ItemStackRes struct {
	ItemID   string `json:"item_id"`
	Cantidad int    `json:"cantidad"`
}

// RangoRes es la representación de un rango de profesión.
type RangoRes struct {
	ID       string `json:"id"`
	Nombre   string `json:"nombre"`
	SkillReq int    `json:"skill_req"`
	SkillMax int    `json:"skill_max"`
}

// MaterialRes es un material requerido por una receta.
type MaterialRes struct {
	ItemID   string `json:"item_id"`
	Cantidad int    `json:"cantidad"`
}

// RecetaRes es la representación de una receta para el cliente.
type RecetaRes struct {
	ID                string        `json:"id"`
	Nombre            string        `json:"nombre"`
	ProfesionID       string        `json:"profesion_id"`
	ResultadoID       string        `json:"resultado_id"`
	ResultadoCantidad int           `json:"resultado_cantidad"`
	Materiales        []MaterialRes `json:"materiales"`
	SkillReq          int           `json:"skill_req"`
	SkillHasta        int           `json:"skill_hasta"`
	Especializacion   string        `json:"especializacion,omitempty"`
}

// EspecializacionRes es la representación de una rama de especialización.
type EspecializacionRes struct {
	ID          string        `json:"id"`
	Nombre      string        `json:"nombre"`
	SkillReq    int           `json:"skill_req"`
	Descripcion string        `json:"descripcion"`
	Materiales  []MaterialRes `json:"materiales"`
	// RequiereEspecializacion es el ID del padre ("" si es de nivel
	// superior). Permite al cliente renderizar árboles anidados (Herrería).
	RequiereEspecializacion string `json:"requiere_especializacion,omitempty"`
}

// ProfesionRes es la representación de una profesión (catálogo) para el cliente.
type ProfesionRes struct {
	ID             string               `json:"id"`
	Nombre         string               `json:"nombre"`
	Primaria       bool                 `json:"primaria"`
	MaxSkill       int                  `json:"max_skill"`
	Rangos         []RangoRes           `json:"rangos"`
	Especializaciones []EspecializacionRes `json:"especializaciones,omitempty"`
}

// EstadoProfesionRes es el estado de una profesión que aprendió un PJ.
type EstadoProfesionRes struct {
	ProfesionID      string   `json:"profesion_id"`
	Skill            int      `json:"skill"`
	SkillMax         int      `json:"skill_max"`
	RangosAprendidos []string `json:"rangos_aprendidos"`
	Especializacion  string   `json:"especializacion,omitempty"`
}

// CrafteoRes es el resultado de un crafteo.
type CrafteoRes struct {
	OK                bool   `json:"ok"`
	Error             string `json:"error,omitempty"`
	RecetaID          string `json:"receta_id"`
	ResultadoID       string `json:"resultado_id,omitempty"`
	ResultadoCantidad int    `json:"resultado_cantidad,omitempty"`
	Skill             int    `json:"skill,omitempty"`
	SkillMax          int    `json:"skill_max,omitempty"`
	SubioSkill        bool   `json:"subio_skill,omitempty"`
}

// AprendidoRes es el resultado de aprender una profesión, rango o especialización.
type AprendidoRes struct {
	OK             bool   `json:"ok"`
	Error          string `json:"error,omitempty"`
	ProfesionID    string `json:"profesion_id"`
	RangoID        string `json:"rango_id,omitempty"`
	Especializacion string `json:"especializacion,omitempty"`
	Skill          int    `json:"skill"`
	SkillMax       int    `json:"skill_max"`
}

// MasmoraRes es el resumen de una masmora para el panel del buscador.
type MasmoraRes struct {
	ID          string `json:"id"`
	Nombre      string `json:"nombre"`
	NivelMin    int    `json:"nivel_min"`
	TamanoGrupo int    `json:"tamano_grupo"`
}

// ArenaRes es el resumen de una arena PvP para el panel del buscador.
type ArenaRes struct {
	ID           string `json:"id"`
	Nombre       string `json:"nombre"`
	TamanoEquipo int    `json:"tamano_equipo"`
}

// PersonajeRes es la información resumida de un personaje para la pantalla de selección.
type PersonajeRes struct {
	Nombre string `json:"nombre"`
	Clase  string `json:"clase"`
	Nivel  int    `json:"nivel"`
}

// EntidadSnapshot es el estado visible de una entidad en un tick.
// Se envía a todos los clientes que tengan a esta entidad en su área de interés.
type EntidadSnapshot struct {
	ID          string `json:"id"`
	Nombre      string `json:"nombre"`
	Clase       string `json:"clase"`
	Nivel       int    `json:"nivel"`
	Pos         Vec3   `json:"pos"`
	Rot         Vec4   `json:"rot"`
	HPActual    int    `json:"hp_actual"`
	HPMax       int    `json:"hp_max"`
	EsJugador   bool   `json:"es_jugador"`
	ObjetivoID  string `json:"objetivo_id,omitempty"`
	EnCombate   bool   `json:"en_combate,omitempty"`
	Canalizando string `json:"canalizando,omitempty"` // ID de habilidad en cooldown
	Faccion     string `json:"faccion,omitempty"`     // "alianza" | "horda"
	Raza        string `json:"raza,omitempty"`        // "humano" | "orco" | ...
	Rol         string `json:"rol,omitempty"`         // "tanque" | "dps" | "soporte"
	Equipo      int    `json:"equipo,omitempty"`      // 0 | 1 en PvP; omitido en PvE/mundo
}

// EstadoCombate es el estado propio del personaje del cliente (no visible para otros).
type EstadoCombate struct {
	HPActual           int            `json:"hp_actual"`
	HPMax              int            `json:"hp_max"`
	EnergiaActual      int            `json:"energia_actual"`
	EnergiaMax         int            `json:"energia_max"`
	Pos                Vec3           `json:"pos"`
	Rot                Vec4           `json:"rot"`
	ObjetivoID         string         `json:"objetivo_id,omitempty"`
	AutoAtaqueActivo   bool           `json:"auto_ataque_activo"`
	Cooldowns          map[string]int `json:"cooldowns,omitempty"`     // habilidad_id → ms restantes
	BuffsActivos       map[string]int `json:"buffs_activos,omitempty"` // buff_id → ms restantes
	AurasActivas       []AuraRes      `json:"auras_activas,omitempty"`  // auras (frascos, elixires, comida, DoT...)
	Muerto             bool           `json:"muerto,omitempty"`
	RespawnMs          int            `json:"respawn_ms,omitempty"` // ms hasta respawn si muerto
	Faccion            string         `json:"faccion,omitempty"`
	Raza               string         `json:"raza,omitempty"`
	Rol                string         `json:"rol,omitempty"`
	InstanciaID        string         `json:"instancia_id,omitempty"` // vacío = mundo abierto
	InstanciaTipo      string         `json:"instancia_tipo,omitempty"`
	Equipo             int            `json:"equipo,omitempty"` // -1 = sin equipo; 0|1 = PvP
}

// AuraRes es la representación de un aura activa enviada al cliente.
type AuraRes struct {
	ID          string `json:"id"`
	Nombre      string `json:"nombre"`
	Tipo        string `json:"tipo"`           // "buff" | "debuff"
	RestanteMs  int64  `json:"restante_ms"`    // ms hasta expirar (0 = permanente)
	AplicadoPor string `json:"aplicado_por,omitempty"` // origen (itemID/habilidadID)
}

// ─── Codificación de frames ─────────────────────────────────────────────

// EscribirMensaje serializa un MensajeServidor y lo envía como frame
// longitud-prefijada sobre el writer.
func EscribirMensaje(w io.Writer, m MensajeServidor) error {
	data, err := json.Marshal(m)
	if err != nil {
		return fmt.Errorf("marshal mensaje: %w", err)
	}
	if len(data) > LongitudMáximaMensaje {
		return fmt.Errorf("mensaje demasiado grande: %d bytes", len(data))
	}
	var cab [4]byte
	binary.LittleEndian.PutUint32(cab[:], uint32(len(data)))
	if _, err := w.Write(cab[:]); err != nil {
		return fmt.Errorf("escribir cabecera: %w", err)
	}
	if _, err := w.Write(data); err != nil {
		return fmt.Errorf("escribir payload: %w", err)
	}
	return nil
}

// LeerMensaje lee un frame longitud-prefijado y lo decodifica como MensajeCliente.
func LeerMensaje(r io.Reader) (MensajeCliente, error) {
	var cab [4]byte
	if _, err := io.ReadFull(r, cab[:]); err != nil {
		return MensajeCliente{}, fmt.Errorf("leer cabecera: %w", err)
	}
	n := binary.LittleEndian.Uint32(cab[:])
	if n == 0 {
		return MensajeCliente{}, nil
	}
	if n > LongitudMáximaMensaje {
		return MensajeCliente{}, fmt.Errorf("frame demasiado grande: %d bytes", n)
	}
	buf := make([]byte, n)
	if _, err := io.ReadFull(r, buf); err != nil {
		return MensajeCliente{}, fmt.Errorf("leer payload: %w", err)
	}
	var m MensajeCliente
	if err := json.Unmarshal(buf, &m); err != nil {
		return MensajeCliente{}, fmt.Errorf("unmarshal mensaje: %w", err)
	}
	return m, nil
}
