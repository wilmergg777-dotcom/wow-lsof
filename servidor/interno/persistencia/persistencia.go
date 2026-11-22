// Package persistencia guarda y carga personajes como JSON en disco.
// Cada personaje es un archivo JSON en el directorio de datos.
// El guardado es atómico: escribe a .tmp y renombra.
package persistencia

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"

	"aethelgard/servidor/interno/geometria"
)

// ErrPersonajeNoExiste se devuelve cuando no se encuentra el archivo del personaje.
var ErrPersonajeNoExiste = errors.New("el personaje no existe")

// Personaje es el estado persistente de un personaje jugador.
// NO incluye estado efímero como HP actual (eso se recalcula al cargar).
type Personaje struct {
	Nombre       string  `json:"nombre"`
	Cuenta       string  `json:"cuenta"`       // usuario dueño
	Clase        string  `json:"clase"`
	Faccion      string  `json:"faccion"`      // "alianza" | "horda"
	Raza         string  `json:"raza"`         // "humano" | "orco" | ...
	Nivel        int     `json:"nivel"`
	Experiencia  int     `json:"experiencia"`
	PosMundo     geometria.Vec3 `json:"pos_mundo"`   // última posición guardada
	RotMundo     geometria.Vec4 `json:"rot_mundo"`
	Habilidad    []string `json:"habilidades"` // IDs de habilidades conocidas
	Inventario   []string `json:"inventario"`  // IDs de ítems (legacy, sin pila)
	InventarioStacks []ItemStack `json:"inventario_stacks,omitempty"` // inventario con pilas
	Profesiones  []ProfesionPersist `json:"profesiones,omitempty"`
	Oro          int     `json:"oro"`
	CreadoUnixMs int64    `json:"creado_unix_ms"`
	UltimoGuardadoUnixMs int64 `json:"ultimo_guardado_unix_ms"`
}

// ItemStack es una pila de un ítem en el inventario.
type ItemStack struct {
	ItemID   string `json:"item_id"`
	Cantidad int    `json:"cantidad"`
}

// ProfesionPersist es el estado persistible de una profesión de un PJ.
type ProfesionPersist struct {
	ProfesionID      string   `json:"profesion_id"`
	Skill            int      `json:"skill"`
	RangosAprendidos []string `json:"rangos_aprendidos"`
}

// Gestor persiste personajes en disco de forma thread-safe.
type Gestor struct {
	mu  sync.RWMutex
	dir string
}

// NuevoGestor crea el gestor y asegura que el directorio exista.
func NuevoGestor(dir string) (*Gestor, error) {
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return nil, fmt.Errorf("crear dir de personajes: %w", err)
	}
	return &Gestor{dir: dir}, nil
}

// Guardar escribe el personaje a disco de forma atómica.
func (g *Gestor) Guardar(p Personaje) error {
	g.mu.Lock()
	defer g.mu.Unlock()

	p.UltimoGuardadoUnixMs = tiempoAhoraUnixMs()
	data, err := json.MarshalIndent(p, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal personaje %s: %w", p.Nombre, err)
	}
	path := g.path(p.Nombre)
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o600); err != nil {
		return fmt.Errorf("escribir personaje %s: %w", p.Nombre, err)
	}
	return os.Rename(tmp, path)
}

// Cargar lee el personaje desde disco.
func (g *Gestor) Cargar(nombre string) (*Personaje, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	data, err := os.ReadFile(g.path(nombre))
	if err != nil {
		if os.IsNotExist(err) {
			return nil, ErrPersonajeNoExiste
		}
		return nil, fmt.Errorf("leer personaje %s: %w", nombre, err)
	}
	var p Personaje
	if err := json.Unmarshal(data, &p); err != nil {
		return nil, fmt.Errorf("unmarshal personaje %s: %w", nombre, err)
	}
	return &p, nil
}

// Existe devuelve true si el personaje ya tiene archivo.
func (g *Gestor) Existe(nombre string) bool {
	g.mu.RLock()
	defer g.mu.RUnlock()
	_, err := os.Stat(g.path(nombre))
	return err == nil
}

// Borrar elimina el archivo del personaje. Útil para tests.
func (g *Gestor) Borrar(nombre string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	err := os.Remove(g.path(nombre))
	if err != nil && !os.IsNotExist(err) {
		return err
	}
	return nil
}

func (g *Gestor) path(nombre string) string {
	return filepath.Join(g.dir, sanitizar(nombre)+".json")
}

// sanitizar igual que en auth: letras, números, guion bajo.
func sanitizar(s string) string {
	out := make([]byte, len(s))
	for i := 0; i < len(s); i++ {
		c := s[i]
		switch {
		case c >= 'a' && c <= 'z', c >= 'A' && c <= 'Z', c >= '0' && c <= '9', c == '_':
			out[i] = c
		default:
			out[i] = '_'
		}
	}
	return string(out)
}

func tiempoAhoraUnixMs() int64 {
	return time.Now().UnixMilli()
}
