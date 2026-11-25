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

// IntervaloBuscadorTicks es cada cuántos ticks el buscador intenta formar
// grupos. A 20 Hz, 20 ticks = 1 segundo. Suficiente para que el match se
// sienta rápido sin consumir CPU de más.
const IntervaloBuscadorTicks = 20

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
//
// Coordina dos capas:
//   - El mundo abierto: entidades con instanciaID == "" que todos ven
//     por proximidad (jugadores en campo libre, mobs patrullando).
//   - Las instancias: masmorras PvE y arenas PvP aisladas, cada una con
//     su propio set de entidades etiquetadas con un instanciaID único.
//
// Los mapas son planos (una sola entidades/enemigos/jugadores) pero
// cada entidad lleva un instanciaID; las consultas (snapshot, agro,
// broadcasts) filtran por ese tag para que dos instancias nunca se vean
// entre sí ni con el mundo abierto.
type Mundo struct {
	mu          sync.RWMutex
	entidades   map[string]Entidad
	jugadores   map[string]*Jugador
	enemigos    map[string]*Enemigo
	instancias  map[string]*Instancia
	buscador    *Buscador
	persist     *persistencia.Gestor
	authGestor  *auth.Gestor
	clases      map[string]DefClase
	facciones   map[string]DefFaccion
	razas       map[string]DefRaza
	masmoras    map[string]DefMasmora
	arenas      map[string]DefArena
	items       map[string]DefItem
	profesiones map[string]DefProfesion
	zonas       map[string]DefZona
	ciudades    map[string]DefCiudad
	misiones    map[string]DefMision
	tick        uint64
	tickInterval time.Duration
	parar       chan struct{}
	hecho       chan struct{}
}

// DefClase define una clase jugable en términos de stats base y habilidades.
type DefClase struct {
	ID              string        `json:"id"`
	Nombre          string        `json:"nombre"`
	Rol             string        `json:"rol"` // "tanque" | "dps" | "soporte"
	HPBase          int           `json:"hp_base"`
	HPPorNivel      int           `json:"hp_por_nivel"`
	EnergiaBase     int           `json:"energia_base"`
	EnergiaPorNivel int           `json:"energia_por_nivel"`
	TipoEnergia     string        `json:"tipo_energia"` // "ira" | "mana" | "energia"
	RegenEnergia    int           `json:"regen_energia"` // % por segundo
	StatPrincipal   string        `json:"stat_principal"` // StatFuerza|StatAgilidad|StatIntelecto: escala el daño
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
		instancias:    make(map[string]*Instancia),
		persist:       cfg.Persist,
		authGestor:    cfg.Auth,
		clases:        clasesPredefinidas(),
		facciones:     faccionesPredefinidas(),
		razas:         razasPredefinidas(),
		masmoras:      masmorasPredefinidas(),
		arenas:        arenasPredefinidas(),
		items:         itemsPredefinidos(),
		profesiones:   profesionesPredefinidas(),
		zonas:         zonasPredefinidas(),
		ciudades:      ciudadesPredefinidas(),
		misiones:      misionesPredefinidas(),
		tickInterval:  time.Duration(1000/hz) * time.Millisecond,
		parar:         make(chan struct{}),
		hecho:         make(chan struct{}),
	}
	m.buscador = nuevoBuscador(m)
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

// Facciones devuelve las facciones jugables.
func (m *Mundo) Facciones() map[string]DefFaccion {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefFaccion, len(m.facciones))
	for k, v := range m.facciones {
		out[k] = v
	}
	return out
}

// Razas devuelve las razas jugables.
func (m *Mundo) Razas() map[string]DefRaza {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefRaza, len(m.razas))
	for k, v := range m.razas {
		out[k] = v
	}
	return out
}

// Raza devuelve la definición de una raza por ID.
func (m *Mundo) Raza(id string) (DefRaza, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	r, ok := m.razas[id]
	return r, ok
}

// RazaPermiteClase comprueba que una raza puede ser de una clase dada, según
// la matriz raza-clase de WoW 3.3.5a (DefRaza.Clases). Es la validación de
// coherencia al crear un personaje: raza+facción+clase deben encajar.
func (m *Mundo) RazaPermiteClase(razaID, claseID string) bool {
	m.mu.RLock()
	defer m.mu.RUnlock()
	r, ok := m.razas[razaID]
	if !ok {
		return false
	}
	for _, c := range r.Clases {
		if c == claseID {
			return true
		}
	}
	return false
}

// Item devuelve la definición de un ítem por ID.
func (m *Mundo) Item(id string) (DefItem, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	it, ok := m.items[id]
	return it, ok
}

// Items devuelve una copia del catálogo de ítems.
func (m *Mundo) Items() map[string]DefItem {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefItem, len(m.items))
	for k, v := range m.items {
		out[k] = v
	}
	return out
}

// Profesiones devuelve las profesiones jugables (con sus rangos y recetas).
func (m *Mundo) Profesiones() map[string]DefProfesion {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefProfesion, len(m.profesiones))
	for k, v := range m.profesiones {
		out[k] = v
	}
	return out
}

// Profesione devuelve una profesión por ID.
func (m *Mundo) Profesione(id string) (DefProfesion, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	p, ok := m.profesiones[id]
	return p, ok
}

// Masmoras devuelve las definiciones de masmoras disponibles.
func (m *Mundo) Masmoras() map[string]DefMasmora {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefMasmora, len(m.masmoras))
	for k, v := range m.masmoras {
		out[k] = v
	}
	return out
}

// Arenas devuelve las definiciones de arenas PvP disponibles.
func (m *Mundo) Arenas() map[string]DefArena {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefArena, len(m.arenas))
	for k, v := range m.arenas {
		out[k] = v
	}
	return out
}

// Buscador devuelve el buscador de masmorras/PvP.
func (m *Mundo) Buscador() *Buscador {
	return m.buscador
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

	// 2. IA de mobs (mundo abierto + instancias; el filtrado por
	// instanciaID dentro de actualizar() garantiza que cada mob solo
	// agroa jugadores de su propia zona).
	for _, e := range m.enemigos {
		e.actualizar(m, t)
	}

	// 3. Auto-ataques y regen.
	for _, j := range m.jugadores {
		j.actualizarCombate(m, t)
	}

	// 4-5. Cooldowns, buffs, muertes y respawns se manejan inline arriba.

	// 6. Snapshots (filtrados por instanciaID).
	for _, j := range m.jugadores {
		j.enviarSnapshot(m)
	}

	// 7. Tick de instancias: comprobar condiciones de fin (boss muerto,
	// equipo wipeado, timeout). Las que terminen limpian sus entidades
	// y devuelven a los jugadores al mundo abierto.
	for id, inst := range m.instancias {
		if inst.tick(m, t) {
			delete(m.instancias, id)
		}
	}

	// 8. Buscador de masmorras / PvP (cada segundo aprox).
	if m.tick%IntervaloBuscadorTicks == 0 {
		m.buscador.procesar(t)
	}

	// 9. Persistencia periódica.
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
// Si estaba en una instancia, lo saca de ella (posiblemente finalizando
// la instancia si queda vacía o un equipo sin vivos). También lo saca
// de cualquier cola del buscador.
func (m *Mundo) QuitarJugador(id string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[id]
	if !ok {
		return
	}
	// Sacar de la cola del buscador si estaba encolado.
	m.buscador.Cancelar(j)
	// Sacar de la instancia si estaba en una.
	if j.instanciaID != "" {
		if inst, ok := m.instancias[j.instanciaID]; ok {
			if inst.sacarJugador(m, j.id, time.Now().UnixMilli()) {
				delete(m.instancias, j.instanciaID)
			}
		}
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

// entidadesCercanasZona devuelve las entidades dentro de RadioInteresMetros
// de pos Y que pertenezcan a la misma zona (instanciaID). instanciaID == ""
// significa mundo abierto. Útil para generar snapshots y para IA de agro.
// Debe llamarse con el lock tomado (RLock o Lock).
func (m *Mundo) entidadesCercanasZona(pos proto.Vec3, excluirID, instanciaID string) []Entidad {
	var out []Entidad
	for _, e := range m.entidades {
		if e.ID() == excluirID {
			continue
		}
		if !mismaZona(e, instanciaID) {
			continue
		}
		if distancia2D(e.Pos(), pos) <= RadioInteresMetros {
			out = append(out, e)
		}
	}
	return out
}

// mismaZona devuelve true si la entidad pertenece a la zona indicada.
// Las entidades tienen un método InstanciaID() que devuelve "" para
// el mundo abierto o el ID de su instancia.
func mismaZona(e Entidad, instanciaID string) bool {
	return instanciaDe(e) == instanciaID
}

// instanciaDe extrae el instanciaID de una Entidad sin depender de la
// interfaz (que no lo expone para mantenerla mínima). Devuelve "" para
// entidades del mundo abierto.
func instanciaDe(e Entidad) string {
	if j, ok := e.(*Jugador); ok {
		return j.instanciaID
	}
	if en, ok := e.(*Enemigo); ok {
		return en.instanciaID
	}
	return ""
}

// distancia2D es distancia euclídea en el plano XZ (ignorando Y).
func distancia2D(a, b proto.Vec3) float64 {
	dx := a.X - b.X
	dz := a.Z - b.Z
	return sqrtF(dx*dx + dz*dz)
}
