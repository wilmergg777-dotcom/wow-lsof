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
	Pos       *Vec3           `json:"pos,omitempty"`
	Rot       *Vec4           `json:"rot,omitempty"`
	Objetivo  string          `json:"objetivo,omitempty"`   // ID del objetivo (tab-target)
	Habilidad string          `json:"habilidad,omitempty"`  // ID de la habilidad
	Activo    bool            `json:"activo,omitempty"`     // Para toggles como auto-ataque
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
	Muerto             bool           `json:"muerto,omitempty"`
	RespawnMs          int            `json:"respawn_ms,omitempty"` // ms hasta respawn si muerto
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
