// jugador.go define la entidad Jugador y toda su lógica:
// - implementación de la interfaz Entidad
// - procesamiento de intents encolados por la capa de red
// - actualización de combate por tick (auto-ataque, regen, buffs, muerte/respawn)
// - generación del snapshot que se envía al cliente
// - guardado a persistencia
package mundo

import (
	"log"
	"time"

	"aethelgard/servidor/interno/auth"
	"aethelgard/servidor/interno/persistencia"
	"aethelgard/servidor/interno/proto"
)

// MaxMetrosPorTick cuánto puede moverse un jugador en un tick sin ser
// considerado teleport hack. 1m a 20Hz = 20 m/s, generoso pero atrapa
// saltos imposibles.
const MaxMetrosPorTick = 1.0

// VelocidadCaminarMps se usa para calcular HP/energía inicial y clamp suave.
const VelocidadCaminarMps = 7.0

// RespawnJugadorMs es el tiempo que un jugador muerto espera antes de reaparecer.
const RespawnJugadorMs = 10_000

// TiempoCombateMs define cuánto después del último daño se sigue "en combate".
const TiempoCombateMs = 5_000

// TamañoBufferSalida cuántos mensajes puede tener encolados el jugador antes
// de que se empiecen a descartar snapshots.
const TamañoBufferSalida = 64

// TamañoColaIntents cuántos intents puede tener encolados.
const TamañoColaIntents = 64

// Jugador es la entidad controlada por un cliente humano.
type Jugador struct {
	// Identidad
	id     string
	cuenta string
	nombre string
	clase  string
	nivel  int

	// Estado espacial
	pos proto.Vec3
	rot proto.Vec4

	// Estado de combate
	hpActual          int
	hpMax             int
	energiaActual     int
	energiaMax        int
	objetivoID        string
	autoAtaqueActivo  bool
	enCombate         bool
	ultimoDanoMs      int64 // último ms en que tomó o hizo daño
	ultimoAutoAtaqueMs int64
	cooldowns         map[string]int64 // hab_id → ms fin cooldown
	buffs             map[string]int64 // buff_id → ms fin buff
	muertoDesdeMs     int64            // 0 si vivo

	// Spawn
	spawnPos proto.Vec3

	// Comunicación con capa de red
	colaIntents chan proto.MensajeCliente
	salida      chan proto.MensajeServidor

	// Backrefs (no se serializan)
	persist     *persistencia.Gestor
	authGestor  *auth.Gestor
	claseDef    DefClase
}

// ─── Implementación de Entidad ──────────────────────────────────────────

func (j *Jugador) ID() string           { return j.id }
func (j *Jugador) Nombre() string       { return j.nombre }
func (j *Jugador) Clase() string        { return j.clase }
func (j *Jugador) Nivel() int           { return j.nivel }
func (j *Jugador) Pos() proto.Vec3        { return j.pos }
func (j *Jugador) SetPos(p proto.Vec3)    { j.pos = p }
func (j *Jugador) Rot() proto.Vec4        { return j.rot }
func (j *Jugador) SetRot(r proto.Vec4)    { j.rot = r }
func (j *Jugador) HPActual() int        { return j.hpActual }
func (j *Jugador) HPMax() int           { return j.hpMax }
func (j *Jugador) EnergiaActual() int   { return j.energiaActual }
func (j *Jugador) EnergiaMax() int      { return j.energiaMax }
func (j *Jugador) EstaVivo() bool       { return j.muertoDesdeMs == 0 }
func (j *Jugador) EsJugador() bool      { return true }
func (j *Jugador) ObjetivoID() string   { return j.objetivoID }
func (j *Jugador) SetObjetivo(id string) { j.objetivoID = id }

// ─── Construcción ──────────────────────────────────────────────────────

// NuevoJugadorDesdePersistencia construye un Jugador vivo a partir del
// personaje persistido. Lo deja listo para entrar al mundo.
func NuevoJugadorDesdePersistencia(
	p *persistencia.Personaje,
	m *Mundo,
	cuenta string,
) *Jugador {
	def, ok := m.clases[p.Clase]
	if !ok {
		def = m.clases["guerrero"] // fallback
	}
	hpMax := def.HPBase + def.HPPorNivel*(p.Nivel-1)
	energiaMax := def.EnergiaBase + def.EnergiaPorNivel*(p.Nivel-1)

	j := &Jugador{
		id:                "pj_" + p.Nombre,
		cuenta:            cuenta,
		nombre:            p.Nombre,
		clase:             p.Clase,
		nivel:             p.Nivel,
		pos:               p.PosMundo,
		rot:               p.RotMundo,
		hpActual:          hpMax,
		hpMax:             hpMax,
		energiaActual:     energiaMax,
		energiaMax:        energiaMax,
		spawnPos:          proto.Vec3{X: 0, Y: 0, Z: 0},
		cooldowns:         make(map[string]int64),
		buffs:             make(map[string]int64),
		colaIntents:       make(chan proto.MensajeCliente, TamañoColaIntents),
		salida:            make(chan proto.MensajeServidor, TamañoBufferSalida),
		persist:           m.persist,
		authGestor:        m.authGestor,
		claseDef:          def,
	}
	// Si la posición guardada es (0,0,0), lo dejamos en el spawn default.
	if p.PosMundo == (proto.Vec3{}) {
		j.pos = j.spawnPos
	}
	return j
}

// NuevoJugadorCreado construye un Jugador recién creado (nivel 1, spawn).
func NuevoJugadorCreado(
	nombre, claseID, cuenta string,
	m *Mundo,
) *Jugador {
	def, ok := m.clases[claseID]
	if !ok {
		def = m.clases["guerrero"]
	}
	j := &Jugador{
		id:                "pj_" + nombre,
		cuenta:            cuenta,
		nombre:            nombre,
		clase:             claseID,
		nivel:             1,
		pos:               proto.Vec3{X: 0, Y: 0, Z: 0},
		rot:               proto.Vec4{X: 0, Y: 0, Z: 0, W: 1},
		hpActual:          def.HPBase,
		hpMax:             def.HPBase,
		energiaActual:     def.EnergiaBase,
		energiaMax:        def.EnergiaBase,
		spawnPos:          proto.Vec3{X: 0, Y: 0, Z: 0},
		cooldowns:         make(map[string]int64),
		buffs:             make(map[string]int64),
		colaIntents:       make(chan proto.MensajeCliente, TamañoColaIntents),
		salida:            make(chan proto.MensajeServidor, TamañoBufferSalida),
		persist:           m.persist,
		authGestor:        m.authGestor,
		claseDef:          def,
	}
	return j
}

// ─── Comunicación con la capa de red ────────────────────────────────────

// EncolarIntent es llamado por la goroutine de sesión cuando llega un mensaje.
// No bloquea: si la cola está llena, descarta el intent (la próxima posición
// del cliente corregirá el estado).
func (j *Jugador) EncolarIntent(m proto.MensajeCliente) {
	select {
	case j.colaIntents <- m:
	default:
		log.Printf("[jugador %s] cola de intents llena, descartando %s", j.nombre, m.Tipo)
	}
}

// Salida devuelve el canal del que la sesión lee mensajes para enviar al cliente.
func (j *Jugador) Salida() <-chan proto.MensajeServidor { return j.salida }

// enviarNoBloqueante mete un mensaje al canal de salida sin bloquear.
// Si está lleno, descarta y loggea (la próxima snapshot reemplaza).
func (j *Jugador) enviarNoBloqueante(msg proto.MensajeServidor) {
	select {
	case j.salida <- msg:
	default:
		log.Printf("[jugador %s] salida llena, descartando %s", j.nombre, msg.Tipo)
	}
}

// SalidaCerrada indica al cliente que la conexión se va a cerrar.
func (j *Jugador) SalidaCerrada() {
	// Best-effort: meter un mensaje de error y cerrar el canal.
	j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "desconectado del mundo"})
}

// CerrarSalida cierra el canal de salida. La sesión lo detecta y termina.
// Debe llamarse después de que el jugador haya sido quitado del mundo.
func (j *Jugador) CerrarSalida() {
	close(j.salida)
}

// ─── Procesamiento por tick ─────────────────────────────────────────────

// procesarIntentsPendientes drena la cola de intents y aplica cada uno.
// Debe llamarse con el lock del mundo tomado.
func (j *Jugador) procesarIntentsPendientes(m *Mundo) {
	for {
		select {
		case msg, ok := <-j.colaIntents:
			if !ok {
				return
			}
			j.aplicarIntent(m, msg)
		default:
			return
		}
	}
}

// aplicarIntent ejecuta un intent individual.
func (j *Jugador) aplicarIntent(m *Mundo, msg proto.MensajeCliente) {
	switch msg.Tipo {
	case "mov":
		j.aplicarMovimiento(msg)
	case "cambiar_obj":
		j.aplicarCambiarObjetivo(m, msg)
	case "habilidad":
		j.aplicarHabilidad(m, msg)
	case "auto_ataque":
		j.autoAtaqueActivo = msg.Activo
	case "logout":
		// El logout real lo maneja la sesión al cerrar la conexión.
		// Aquí solo aseguramos que no esté en combate.
		j.autoAtaqueActivo = false
	default:
		log.Printf("[jugador %s] intent desconocido: %s", j.nombre, msg.Tipo)
	}
}

// aplicarMovimiento valida y aplica un movimiento del cliente.
// Anti-cheat básico: si el desplazamiento supera MaxMetrosPorTick, se rechaza.
// El cliente se reconcilia al recibir el siguiente snapshot (que trae la pos
// autoritativa en EstadoPJ.Pos).
func (j *Jugador) aplicarMovimiento(msg proto.MensajeCliente) {
	if !j.EstaVivo() {
		return // muerto no se mueve
	}
	if msg.Pos == nil {
		return
	}
	d := distancia2D(j.pos, *msg.Pos)
	if d > MaxMetrosPorTick {
		// Rechazar silenciosamente; el snapshot siguiente reconcilia al cliente.
		return
	}
	j.pos = *msg.Pos
	if msg.Rot != nil {
		j.rot = *msg.Rot
	}
}

// aplicarCambiarObjetivo valida que el objetivo exista y sea atacable.
func (j *Jugador) aplicarCambiarObjetivo(m *Mundo, msg proto.MensajeCliente) {
	if msg.Objetivo == "" {
		j.objetivoID = ""
		return
	}
	e, ok := m.entidadPorID(msg.Objetivo)
	if !ok {
		j.objetivoID = ""
		return
	}
	if !e.EstaVivo() {
		j.objetivoID = ""
		return
	}
	// MVP: solo se puede targetear mobs (no otros jugadores).
	if e.EsJugador() {
		j.objetivoID = ""
		return
	}
	j.objetivoID = msg.Objetivo
}

// actualizarCombate ejecuta la lógica de combate por tick para este jugador.
// Debe llamarse con el lock del mundo tomado.
func (j *Jugador) actualizarCombate(m *Mundo, t time.Time) {
	if !j.EstaVivo() {
		// ¿Es hora de respawn?
		if j.muertoDesdeMs > 0 && (t.UnixMilli()-j.muertoDesdeMs) >= RespawnJugadorMs {
			j.respawn()
		}
		return
	}

	ahora := t.UnixMilli()

	// Marcar fuera de combate si ha pasado el tiempo.
	if j.enCombate && (ahora-j.ultimoDanoMs) > TiempoCombateMs {
		j.enCombate = false
	}

	// Regeneración de energía (solo clases que regeneran).
	if j.claseDef.RegenEnergia > 0 && j.energiaActual < j.energiaMax {
		// % por segundo → por tick: regen * max / 100 / Hz
		regenPorTick := j.claseDef.RegenEnergia * j.energiaMax / 100 / HzPredeterminado
		if regenPorTick < 1 {
			regenPorTick = 1 // mínimo 1 por tick para que se sienta
		}
		j.energiaActual += regenPorTick
		if j.energiaActual > j.energiaMax {
			j.energiaActual = j.energiaMax
		}
	}

	// Auto-ataque.
	if j.autoAtaqueActivo && j.objetivoID != "" {
		obj, ok := m.entidadPorID(j.objetivoID)
		if !ok || !obj.EstaVivo() {
			j.objetivoID = ""
			j.autoAtaqueActivo = false
		} else if distancia2D(j.pos, obj.Pos()) <= j.claseDef.RangoCuerpoACuerpo+0.5 {
			if (ahora - j.ultimoAutoAtaqueMs) >= int64(j.claseDef.IntervaloAutoAtaqueMs) {
				j.ejecutarAutoAtaque(m, obj, ahora)
				j.ultimoAutoAtaqueMs = ahora
			}
		}
	}

	// Limpieza de buffs expirados (los cooldowns se checkean al usar).
	for b, fin := range j.buffs {
		if fin <= ahora {
			delete(j.buffs, b)
		}
	}
}

// respawn revive al jugador en su punto de aparición con HP/energía al máximo.
func (j *Jugador) respawn() {
	j.hpActual = j.hpMax
	j.energiaActual = j.energiaMax
	j.pos = j.spawnPos
	j.rot = proto.Vec4{X: 0, Y: 0, Z: 0, W: 1}
	j.muertoDesdeMs = 0
	j.objetivoID = ""
	j.autoAtaqueActivo = false
	j.enCombate = false
	j.cooldowns = make(map[string]int64)
	j.buffs = make(map[string]int64)
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:    "respawn",
		EntidadID: j.id,
		Mensaje: "has reaparecido",
	})
}

// ejecutarAutoAtaque aplica daño al objetivo y propaga el evento.
// Genera ira si la clase es guerrero.
func (j *Jugador) ejecutarAutoAtaque(m *Mundo, obj Entidad, ahora int64) {
	if !obj.EsJugador() {
		// Es un mob.
		e, ok := m.enemigos[obj.ID()]
		if !ok || !e.EstaVivo() {
			return
		}
		dano := j.calcularDaño(j.claseDef.DañoAutoAtaque)
		e.recibirDaño(j.id, dano, false, m, ahora)
		j.postDañoAnotado(dano, ahora)
	} else {
		// MVP: sin PvP. Auto-ataque a otro jugador no hace nada.
	}
}

// postDañoAnotado actualiza estado tras hacer daño.
func (j *Jugador) postDañoAnotado(dano int, ahora int64) {
	j.ultimoDanoMs = ahora
	j.enCombate = true
	// Ira: cada auto-ataque genera 5 de ira (solo guerrero).
	if j.claseDef.TipoEnergia == "ira" {
		j.energiaActual += 5
		if j.energiaActual > j.energiaMax {
			j.energiaActual = j.energiaMax
		}
	}
}

// calcularDaño aplica multiplicador de buffs activos al daño base.
func (j *Jugador) calcularDaño(base int) int {
	mult := 1.0
	if _, ok := j.buffs["grito_guerra"]; ok {
		mult += 0.10
	}
	return int(float64(base) * mult)
}

// recibirDaño es llamado cuando un mob hiere al jugador.
func (j *Jugador) recibirDaño(origenID string, cantidad int, critico bool, m *Mundo, ahora int64) {
	if !j.EstaVivo() {
		return
	}
	j.hpActual -= cantidad
	j.ultimoDanoMs = ahora
	j.enCombate = true

	// Evento al propio jugador.
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:       "dano",
		OrigenID:   origenID,
		ObjetivoID: j.id,
		Cantidad:   cantidad,
		Critico:    critico,
	})

	if j.hpActual <= 0 {
		j.hpActual = 0
		j.morir(m, ahora)
	}
}

// morir pone al jugador en estado muerto y notifica.
func (j *Jugador) morir(m *Mundo, ahora int64) {
	j.muertoDesdeMs = ahora
	j.autoAtaqueActivo = false
	j.objetivoID = ""
	// Broadcast death event a jugadores cercanos.
	m.broadcastCercano(proto.MensajeServidor{
		Tipo:      "muerte",
		EntidadID: j.id,
		OrigenID:  j.id,
	}, j.pos)
}

// aplicarHabilidad valida y dispara una habilidad. Ver combate.go para
// la resolución detallada.
func (j *Jugador) aplicarHabilidad(m *Mundo, msg proto.MensajeCliente) {
	if !j.EstaVivo() {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "estás muerto"})
		return
	}
	usarHabilidad(m, j, msg.Habilidad, msg.Objetivo, time.Now().UnixMilli())
}

// ─── Snapshot ───────────────────────────────────────────────────────────

// enviarSnapshot construye y envía el snapshot del tick al cliente.
// Debe llamarse con el lock del mundo tomado.
func (j *Jugador) enviarSnapshot(m *Mundo) {
	cercanas := m.entidadesCercanas(j.pos, j.id)
	entidades := make([]proto.EntidadSnapshot, 0, len(cercanas))
	for _, e := range cercanas {
		entidades = append(entidades, snapshotDeEntidad(e))
	}

	estado := proto.EstadoCombate{
		HPActual:           j.hpActual,
		HPMax:              j.hpMax,
		EnergiaActual:      j.energiaActual,
		EnergiaMax:         j.energiaMax,
		Pos:                j.pos,
		Rot:                j.rot,
		ObjetivoID:         j.objetivoID,
		AutoAtaqueActivo:   j.autoAtaqueActivo,
		Cooldowns:          cooldownsRestantes(j.cooldowns, time.Now().UnixMilli()),
		BuffsActivos:       cooldownsRestantes(j.buffs, time.Now().UnixMilli()),
		Muerto:             !j.EstaVivo(),
	}
	if !j.EstaVivo() && j.muertoDesdeMs > 0 {
		restante := RespawnJugadorMs - (time.Now().UnixMilli() - j.muertoDesdeMs)
		if restante < 0 {
			restante = 0
		}
		estado.RespawnMs = int(restante)
	}

	msg := proto.MensajeServidor{
		Tipo:      "snapshot",
		Tick:      m.tick,
		Entidades: entidades,
		EstadoPJ:  &estado,
	}
	j.enviarNoBloqueante(msg)
}

// snapshotDeEntidad convierte cualquier Entidad a su representación de red.
func snapshotDeEntidad(e Entidad) proto.EntidadSnapshot {
	s := proto.EntidadSnapshot{
		ID:        e.ID(),
		Nombre:    e.Nombre(),
		Clase:     e.Clase(),
		Nivel:     e.Nivel(),
		Pos:       e.Pos(),
		Rot:       e.Rot(),
		HPActual:  e.HPActual(),
		HPMax:     e.HPMax(),
		EsJugador: e.EsJugador(),
		ObjetivoID: e.ObjetivoID(),
	}
	if j, ok := e.(*Jugador); ok {
		s.EnCombate = j.enCombate
	}
	if en, ok := e.(*Enemigo); ok {
		s.EnCombate = en.enCombate
	}
	return s
}

// cooldownsRestantes convierte un mapa hab_id → fin_ms en hab_id → ms_restantes.
func cooldownsRestantes(m map[string]int64, ahora int64) map[string]int {
	out := make(map[string]int, len(m))
	for k, fin := range m {
		r := int(fin - ahora)
		if r < 0 {
			r = 0
		}
		if r > 0 {
			out[k] = r
		}
	}
	return out
}

// ─── Persistencia ───────────────────────────────────────────────────────

// guardar serializa el jugador a persistencia.Personaje y lo escribe a disco.
func (j *Jugador) guardar(p *persistencia.Gestor) error {
	pj := persistencia.Personaje{
		Nombre:      j.nombre,
		Cuenta:      j.cuenta,
		Clase:       j.clase,
		Nivel:       j.nivel,
		Experiencia: 0,
		PosMundo:    j.pos,
		RotMundo:    j.rot,
		Habilidad:   idsHabilidades(j.claseDef),
		Inventario:  []string{},
		Oro:         0,
		CreadoUnixMs: 0, // se preserva al cargar; al crear nuevo se pone al guardar la primera vez
	}
	// Si ya existe en disco, preservar creado y otros campos no modificados.
	existente, err := p.Cargar(j.nombre)
	if err == nil && existente != nil {
		pj.CreadoUnixMs = existente.CreadoUnixMs
		pj.Oro = existente.Oro
		pj.Inventario = existente.Inventario
		pj.Experiencia = existente.Experiencia
	} else {
		pj.CreadoUnixMs = time.Now().UnixMilli()
	}
	return p.Guardar(pj)
}

// idsHabilidades extrae los IDs de habilidades de una DefClase.
func idsHabilidades(d DefClase) []string {
	out := make([]string, 0, len(d.Habilidades))
	for _, h := range d.Habilidades {
		out = append(out, h.ID)
	}
	return out
}
