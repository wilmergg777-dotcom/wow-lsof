// Package mundo contiene el estado autoritativo del mundo del juego:
// entidades (jugadores y enemigos), combate, IA de mobs, persistencia
// periódica y generación de snapshots por tick.
//
// El mundo corre a 20 Hz (50 ms por tick). El bucle de tick:
//   1. Procesa intents encolados por cada jugador.
//   2. Actualiza IA de mobs (patrulla, agro, ataque).
//   3. Resuelve auto-ataques (jugadores y mobs).
//   4. Actualiza cooldowns y buffs.
//   5. Maneja muertes y respawns.
//   6. Genera y envía snapshots a cada jugador.
//   7. Persiste personajes cada N ticks.
package mundo

import (
	"log"
	"sync"
	"time"

	"aethelgard/servidor/interno/auth"
	"aethelgard/servidor/interno/persistencia"
	"aethelgard/servidor/interno/proto"
)

// Hz predeterminado del servidor.
const HzPredeterminado = 20

// RadioInteresMetros define qué tan lejos un jugador "ve" entidades.
// Entidades fuera de este radio no se incluyen en su snapshot.
const RadioInteresMetros = 60.0

// IntervaloGuardadoTicks es cada cuántos ticks se persisten todos los personajes.
// A 20 Hz, 200 ticks = 10 segundos.
const IntervaloGuardadoTicks = 200

// Entidad es la interfaz común a todo lo que vive en el mundo.
type Entidad interface {
	ID() string
	Nombre() string
	Clase() string
	Nivel() int
	Pos() proto.Vec3
	SetPos(proto.Vec3)
	Rot() proto.Vec4
	SetRot(proto.Vec4)
	HPActual() int
	HPMax() int
	EnergiaActual() int
	EnergiaMax() int
	EstaVivo() bool
	EsJugador() bool
	ObjetivoID() string
	SetObjetivo(string)
}

// Mundo es el estado autoritativo del juego.
type Mundo struct {
	mu          sync.RWMutex
	entidades   map[string]Entidad
	jugadores   map[string]*Jugador
	enemigos    map[string]*Enemigo
	persist     *persistencia.Gestor
	authGestor  *auth.Gestor
	clases      map[string]DefClase
	tick        uint64
	tickInterval time.Duration
	parar       chan struct{}
	hecho       chan struct{}
}

// DefClase define una clase jugable en términos de stats base y habilidades.
type DefClase struct {
	ID              string        `json:"id"`
	Nombre          string        `json:"nombre"`
	HPBase          int           `json:"hp_base"`
	HPPorNivel      int           `json:"hp_por_nivel"`
	EnergiaBase     int           `json:"energia_base"`
	EnergiaPorNivel int           `json:"energia_por_nivel"`
	TipoEnergia     string        `json:"tipo_energia"` // "ira" | "mana" | "energia"
	RegenEnergia    int           `json:"regen_energia"` // % por segundo
	Habilidades     []DefHabilidad `json:"habilidades"`
	DañoAutoAtaque  int           `json:"dano_auto_ataque"`
	IntervaloAutoAtaqueMs int     `json:"intervalo_auto_ataque_ms"`
	RangoCuerpoACuerpo float64    `json:"rango_cuerpo_a_cuerpo"` // metros
	RangoInicial    proto.Vec3      `json:"rango_inicial"`
}

// DefHabilidad define una habilidad jugable.
type DefHabilidad struct {
	ID            string  `json:"id"`
	Nombre        string  `json:"nombre"`
	Tipo          string  `json:"tipo"` // "dano" | "buff" | "curacion" | "carga"
	CostoEnergia  int     `json:"costo_energia"`
	CooldownMs    int     `json:"cooldown_ms"`
	RangoMetros   float64 `json:"rango_metros"`
	TiempoCastMs  int     `json:"tiempo_cast_ms"` // 0 = instantáneo
	DañoBase      int     `json:"dano_base"`
	DuracionBuffMs int    `json:"duracion_buff_ms"`
	MagnitudBuff  float64 `json:"magnitud_buff"` // p.ej. 0.10 para +10%
	IDBuff        string  `json:"id_buff"`
	Icono         string  `json:"icono"`
}

// ConfigMundo reúne las dependencias necesarias para construir un Mundo.
type ConfigMundo struct {
	Persist *persistencia.Gestor
	Auth    *auth.Gestor
	Hz      int
}

// NuevoMundo construye el mundo con las clases predefinidas y dependencias inyectadas.
func NuevoMundo(cfg ConfigMundo) *Mundo {
	hz := cfg.Hz
	if hz <= 0 {
		hz = HzPredeterminado
	}
	m := &Mundo{
		entidades:     make(map[string]Entidad),
		jugadores:     make(map[string]*Jugador),
		enemigos:      make(map[string]*Enemigo),
		persist:       cfg.Persist,
		authGestor:    cfg.Auth,
		clases:        clasesPredefinidas(),
		tickInterval:  time.Duration(1000/hz) * time.Millisecond,
		parar:         make(chan struct{}),
		hecho:         make(chan struct{}),
	}
	m.spawnEnemigosIniciales()
	return m
}

// Clases devuelve las definiciones de clase disponibles.
func (m *Mundo) Clases() map[string]DefClase {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefClase, len(m.clases))
	for k, v := range m.clases {
		out[k] = v
	}
	return out
}

// Iniciar arranca el bucle de tick en una goroutine.
// Detener() lo para de forma sincronizada.
func (m *Mundo) Iniciar() {
	go m.bucleTick()
}

// Detener para el bucle de tick y espera a que termine.
func (m *Mundo) Detener() {
	close(m.parar)
	<-m.hecho
}

// Tick devuelve el número de tick actual (para diagnóstico).
func (m *Mundo) Tick() uint64 {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.tick
}

// bucleTick corre el loop principal hasta que se llame a Detener().
func (m *Mundo) bucleTick() {
	defer close(m.hecho)
	ticker := time.NewTicker(m.tickInterval)
	defer ticker.Stop()
	for {
		select {
		case <-m.parar:
			m.guardarTodo()
			return
		case t := <-ticker.C:
			m.step(t)
		}
	}
}

// step ejecuta un tick completo del mundo.
func (m *Mundo) step(t time.Time) {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.tick++

	// 1. Procesar intents encolados por cada jugador.
	for _, j := range m.jugadores {
		j.procesarIntentsPendientes(m)
	}

	// 2. IA de mobs.
	for _, e := range m.enemigos {
		e.actualizar(m, t)
	}

	// 3. Auto-ataques y regen.
	for _, j := range m.jugadores {
		j.actualizarCombate(m, t)
	}

	// 4-5. Cooldowns, buffs, muertes y respawns se manejan inline arriba.

	// 6. Snapshots.
	for _, j := range m.jugadores {
		j.enviarSnapshot(m)
	}

	// 7. Persistencia periódica.
	if m.tick%IntervaloGuardadoTicks == 0 {
		m.guardarJugadores()
	}
}

// guardarTodo persiste a todos los jugadores (usado al apagar).
func (m *Mundo) guardarTodo() {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.guardarJugadores()
}

// guardarJugadores persiste el estado de todos los jugadores activos.
// Debe llamarse con el lock tomado.
func (m *Mundo) guardarJugadores() {
	for _, j := range m.jugadores {
		if err := j.guardar(m.persist); err != nil {
			log.Printf("[mundo] error guardando %s: %v", j.nombre, err)
		}
	}
}

// AgregarJugador registra un jugador en el mundo. Se llama tras validar
// que el personaje existe y pertenece a la cuenta.
func (m *Mundo) AgregarJugador(j *Jugador) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.entidades[j.id] = j
	m.jugadores[j.id] = j
	log.Printf("[mundo] jugador conectado: %s (%s)", j.nombre, j.clase)
}

// QuitarJugador elimina un jugador del mundo y persiste su estado.
func (m *Mundo) QuitarJugador(id string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[id]
	if !ok {
		return
	}
	if err := j.guardar(m.persist); err != nil {
		log.Printf("[mundo] error guardando %s al salir: %v", j.nombre, err)
	}
	delete(m.entidades, id)
	delete(m.jugadores, id)
	log.Printf("[mundo] jugador desconectado: %s", j.nombre)
}

// buscarJugador devuelve el jugador por ID.
// NO adquiere el lock: el llamador debe tener m.mu (Lock o RLock).
func (m *Mundo) buscarJugador(id string) (*Jugador, bool) {
	j, ok := m.jugadores[id]
	return j, ok
}

// entidadPorID devuelve cualquier entidad (jugador o enemigo) por ID.
// NO adquiere el lock: el llamador debe tener m.mu (Lock o RLock).
// Esto evita deadlocks cuando se llama desde dentro del tick loop.
func (m *Mundo) entidadPorID(id string) (Entidad, bool) {
	e, ok := m.entidades[id]
	return e, ok
}

// entidadesCercanas devuelve las entidades dentro de RadioInteresMetros de pos.
// Útil para generar snapshots y para IA de agro.
// Debe llamarse con el lock tomado (RLock o Lock).
func (m *Mundo) entidadesCercanas(pos proto.Vec3, excluirID string) []Entidad {
	var out []Entidad
	for _, e := range m.entidades {
		if e.ID() == excluirID {
			continue
		}
		if distancia2D(e.Pos(), pos) <= RadioInteresMetros {
			out = append(out, e)
		}
	}
	return out
}

// distancia2D es distancia euclídea en el plano XZ (ignorando Y).
func distancia2D(a, b proto.Vec3) float64 {
	dx := a.X - b.X
	dz := a.Z - b.Z
	return sqrtF(dx*dx + dz*dz)
}
