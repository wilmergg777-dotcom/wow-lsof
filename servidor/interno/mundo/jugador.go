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
	faccion string // "alianza" | "horda"
	raza   string // "humano" | "orco" | ...
	rol    string // "tanque" | "dps" | "soporte"

	// Modificadores raciales pasivos (aplicados al crear)
	modDano float64 // +0.05 = +5% daño (p. ej. orco, draenei)

	// Estado espacial
	pos proto.Vec3
	rot proto.Vec4

	// Zona actual ("" = mundo abierto; inst.id = masmora/arena)
	instanciaID    string
	equipo         int  // -1 = sin equipo; 0|1 = equipo PvP
	posPreInstancia proto.Vec3 // posición guardada antes de entrar a instancia

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

	// Inventario y profesiones
	inventario map[string]int            // itemID → cantidad (pila)
	profesiones map[string]*EstadoProfesion // profID → estado

	// Experiencia, oro y misiones
	xp                  int                       // experiencia acumulada
	oro                 int                       // moneda
	misionesActivas     map[string]*EstadoMision  // misionID → estado
	misionesCompletadas map[string]bool           // misionID → entregada

	// Equipo equipado: slot → itemID (un ítem por ranura).
	equipado map[string]string

	// Spawn
	spawnPos proto.Vec3

	// Comunicación con capa de red
	colaIntents chan proto.MensajeCliente
	salida      chan proto.MensajeServidor

	// Backrefs (no se serializan)
	persist     *persistencia.Gestor
	authGestor  *auth.Gestor
	claseDef    DefClase
	items       map[string]DefItem // catálogo de ítems (para stats de equipo)
}

// ─── Implementación de Entidad ──────────────────────────────────────────

func (j *Jugador) ID() string           { return j.id }
func (j *Jugador) Nombre() string       { return j.nombre }
func (j *Jugador) Clase() string        { return j.clase }
func (j *Jugador) Nivel() int           { return j.nivel }
func (j *Jugador) Faccion() string      { return j.faccion }
func (j *Jugador) Raza() string         { return j.raza }
func (j *Jugador) Rol() string          { return j.rol }
func (j *Jugador) InstanciaID() string  { return j.instanciaID }
func (j *Jugador) Equipo() int          { return j.equipo }
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

// EnPvP devuelve true si el jugador está en una instancia de arena PvP
// (tiene equipo 0 o 1 asignado). En ese caso puede dañar y ser dañado
// por otros jugadores del equipo contrario.
func (j *Jugador) EnPvP() bool { return j.equipo >= 0 }

// esEnemigoDe devuelve true si ambos jugadores están en la misma
// instancia PvP y en equipos opuestos.
func (j *Jugador) esEnemigoDe(otro *Jugador) bool {
	if j.instanciaID == "" || j.instanciaID != otro.instanciaID {
		return false
	}
	return j.equipo != otro.equipo
}

// esAliadoDe devuelve true si están en la misma instancia y mismo equipo
// (o ambos en una masmora PvE, donde todos son aliados).
func (j *Jugador) esAliadoDe(otro *Jugador) bool {
	if j.instanciaID == "" || j.instanciaID != otro.instanciaID {
		return false
	}
	// En masmora (equipo -1) todos son aliados. En arena, mismo equipo.
	return j.equipo == otro.equipo
}

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

	// Facción: si el personaje persistido no trae facción (personajes
	// viejos pre-sistema de facciones), asignar Alianza por defecto.
	fac := p.Faccion
	if fac == "" {
		fac = FaccionAlianza
	}
	// Raza: si no trae raza (personajes viejos), humano por defecto.
	razaID := p.Raza
	if razaID == "" {
		razaID = "humano"
	}
	// Aplicar racial pasivo: modificar HP/energía máx y modDano.
	var modDano float64
	if razaDef, ok := m.razas[razaID]; ok {
		hpMax = int(float64(hpMax) * (1 + razaDef.ModHP))
		energiaMax = int(float64(energiaMax) * (1 + razaDef.ModMana))
		modDano = razaDef.ModDano
	}
	// Spawn racial: el punto de reaparición al morir es la capital de la raza.
	spawnRacial := m.SpawnRacial(razaID)

	j := &Jugador{
		id:                "pj_" + p.Nombre,
		cuenta:            cuenta,
		nombre:            p.Nombre,
		clase:             p.Clase,
		nivel:             p.Nivel,
		xp:                p.Experiencia,
		oro:               p.Oro,
		faccion:           fac,
		raza:              razaID,
		rol:               def.Rol,
		modDano:           modDano,
		instanciaID:       "",
		equipo:            -1,
		pos:               p.PosMundo,
		rot:               p.RotMundo,
		hpActual:          hpMax,
		hpMax:             hpMax,
		energiaActual:     energiaMax,
		energiaMax:        energiaMax,
		spawnPos:          spawnRacial,
		inventario:        make(map[string]int),
		profesiones:       make(map[string]*EstadoProfesion),
		misionesActivas:     make(map[string]*EstadoMision),
		misionesCompletadas: make(map[string]bool),
		equipado:            make(map[string]string),
		cooldowns:         make(map[string]int64),
		buffs:             make(map[string]int64),
		colaIntents:       make(chan proto.MensajeCliente, TamañoColaIntents),
		salida:            make(chan proto.MensajeServidor, TamañoBufferSalida),
		persist:           m.persist,
		authGestor:        m.authGestor,
		claseDef:          def,
		items:             m.items,
	}
	// Si la posición guardada es (0,0,0), lo dejamos en el spawn default.
	if p.PosMundo == (proto.Vec3{}) {
		j.pos = j.spawnPos
	}
	// Cargar inventario (pila: itemID → cantidad) desde la persistencia.
	for _, st := range p.InventarioStacks {
		if st.Cantidad > 0 {
			j.inventario[st.ItemID] = st.Cantidad
		}
	}
	// Cargar profesiones desde la persistencia.
	for _, pe := range p.Profesiones {
		ep := &EstadoProfesion{
			ProfesionID:      pe.ProfesionID,
			Skill:            pe.Skill,
			RangosAprendidos: append([]string(nil), pe.RangosAprendidos...),
			Especializacion:  pe.Especializacion,
		}
		j.profesiones[ep.ProfesionID] = ep
	}
	// Cargar misiones activas y completadas desde la persistencia.
	for _, mp := range p.MisionesActivas {
		est := &EstadoMision{
			MisionID:   mp.MisionID,
			Progreso:   make(map[string]int, len(mp.Progreso)),
			Completada: mp.Completada,
		}
		for k, v := range mp.Progreso {
			est.Progreso[k] = v
		}
		j.misionesActivas[mp.MisionID] = est
	}
	for _, mid := range p.MisionesCompletadas {
		j.misionesCompletadas[mid] = true
	}
	// Cargar equipo equipado y recalcular stats con los bonus de equipo.
	for _, es := range p.Equipado {
		if es.Slot != "" && es.ItemID != "" {
			j.equipado[es.Slot] = es.ItemID
		}
	}
	j.recalcularStatsMaximos(m)
	return j
}

// NuevoJugadorCreado construye un Jugador recién creado (nivel 1, spawn).
// faccion debe ser FaccionAlianza o FaccionHorda; raza debe ser una raza
// válida de esa facción. La coherencia raza-facción-clase la valida sesion.go.
func NuevoJugadorCreado(
	nombre, claseID, faccion, razaID, cuenta string,
	m *Mundo,
) *Jugador {
	def, ok := m.clases[claseID]
	if !ok {
		def = m.clases["guerrero"]
	}
	if faccion == "" {
		faccion = FaccionAlianza
	}
	if razaID == "" {
		razaID = "humano"
	}
	// Aplicar racial pasivo al HP/energía base y al modificador de daño.
	hpMax := def.HPBase
	energiaMax := def.EnergiaBase
	var modDano float64
	if razaDef, ok := m.razas[razaID]; ok {
		hpMax = int(float64(hpMax) * (1 + razaDef.ModHP))
		energiaMax = int(float64(energiaMax) * (1 + razaDef.ModMana))
		modDano = razaDef.ModDano
	}
	// Spawn racial: el personaje aparece en la capital de su raza (p.ej. un
	// Humano en Ventormenta, un Tauren en Cima de Trueno), no en el origen.
	spawnRacial := m.SpawnRacial(razaID)
	j := &Jugador{
		id:                "pj_" + nombre,
		cuenta:            cuenta,
		nombre:            nombre,
		clase:             claseID,
		nivel:             1,
		faccion:           faccion,
		raza:              razaID,
		rol:               def.Rol,
		modDano:           modDano,
		instanciaID:       "",
		equipo:            -1,
		pos:               spawnRacial,
		rot:               proto.Vec4{X: 0, Y: 0, Z: 0, W: 1},
		hpActual:          hpMax,
		hpMax:             hpMax,
		energiaActual:     energiaMax,
		energiaMax:        energiaMax,
		spawnPos:          spawnRacial,
		inventario:        make(map[string]int),
		profesiones:       make(map[string]*EstadoProfesion),
		misionesActivas:     make(map[string]*EstadoMision),
		misionesCompletadas: make(map[string]bool),
		equipado:            make(map[string]string),
		cooldowns:         make(map[string]int64),
		buffs:             make(map[string]int64),
		colaIntents:       make(chan proto.MensajeCliente, TamañoColaIntents),
		salida:            make(chan proto.MensajeServidor, TamañoBufferSalida),
		persist:           m.persist,
		authGestor:        m.authGestor,
		claseDef:          def,
		items:             m.items,
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

// aplicarCambiarObjetivo valida que el objetivo exista, esté vivo y sea
// atacable según el contexto (mundo abierto, masmora o arena PvP).
//
// Reglas:
//   - Mobs: se pueden targetear si están en la misma zona que el jugador.
//   - Jugadores: solo se pueden targetear en arena PvP, y solo si son
//     del equipo contrario (enemigos). En masmora o mundo abierto, no.
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
	// Filtro de zona: el objetivo debe estar en la misma instancia (o
	// ambos en mundo abierto).
	if instanciaDe(e) != j.instanciaID {
		j.objetivoID = ""
		return
	}
	if e.EsJugador() {
		// En mundo abierto no se puede targetear a otros jugadores.
		// En instancia (masmora o arena) sí: aliados para curar,
		// enemigos para atacar. Las reglas de daño/curación las impone
		// combate.go al ejecutar la habilidad.
		if j.instanciaID == "" {
			j.objetivoID = ""
			return
		}
	}
	j.objetivoID = msg.Objetivo
}

// actualizarCombate ejecuta la lógica de combate por tick para este jugador.
// Debe llamarse con el lock del mundo tomado.
func (j *Jugador) actualizarCombate(m *Mundo, t time.Time) {
	if !j.EstaVivo() {
		// En arena PvP, los muertos NO respawnean hasta que la partida
		// termina (condición de victoria por wipe). En masmora y mundo
		// abierto sí hay respawn automático.
		if j.EnPvP() {
			return
		}
		if j.muertoDesdeMs > 0 && (t.UnixMilli()-j.muertoDesdeMs) >= RespawnJugadorMs {
			j.respawn(m)
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

// respawn revive al jugador con HP/energía al máximo. La posición de
// respawn depende de la zona: masmora → spawn de la masmora; mundo
// abierto → spawnPos default. En arena PvP no se llama (los muertos
// esperan al fin de la partida).
func (j *Jugador) respawn(m *Mundo) {
	j.hpActual = j.hpMax
	j.energiaActual = j.energiaMax
	// Posición de respawn según zona.
	if j.instanciaID != "" {
		if inst, ok := m.instancias[j.instanciaID]; ok {
			switch inst.tipo {
			case InstanciaMasmora:
				j.pos = inst.defMasmora.PosSpawn
			case InstanciaArenaPvP:
				// Salvaguarda: al spawn del equipo.
				if j.equipo == 0 {
					j.pos = inst.defArena.PosEquipoA
				} else {
					j.pos = inst.defArena.PosEquipoB
				}
			}
		} else {
			j.pos = j.spawnPos
		}
	} else {
		j.pos = j.spawnPos
	}
	j.rot = proto.Vec4{X: 0, Y: 0, Z: 0, W: 1}
	j.muertoDesdeMs = 0
	j.objetivoID = ""
	j.autoAtaqueActivo = false
	j.enCombate = false
	j.cooldowns = make(map[string]int64)
	j.buffs = make(map[string]int64)
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:      "respawn",
		EntidadID: j.id,
		Mensaje:   "has reaparecido",
	})
}

// ejecutarAutoAtaque aplica daño al objetivo y propaga el evento.
// Genera ira si la clase es guerrero. En arena PvP también daña a
// jugadores del equipo contrario.
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
		// PvP: solo si el objetivo es enemigo (misma arena, equipo opuesto).
		otro, ok := obj.(*Jugador)
		if !ok || !j.esEnemigoDe(otro) {
			return
		}
		dano := j.calcularDaño(j.claseDef.DañoAutoAtaque)
		otro.recibirDaño(j.id, dano, false, m, ahora)
		j.postDañoAnotado(dano, ahora)
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

// calcularDaño aplica multiplicador de buffs activos, racial y stat
// principal al daño base. El stat principal de la clase (base por nivel +
// equipo) escala el daño: +1% por cada 2 puntos (stat/200).
func (j *Jugador) calcularDaño(base int) int {
	mult := 1.0 + j.modDano // racial pasivo (p. ej. orco/draenei +5%)
	if _, ok := j.buffs["grito_guerra"]; ok {
		mult += 0.10
	}
	mult += float64(j.statPrincipalTotal()) / 200.0
	return int(float64(base) * mult)
}

// recibirDaño es llamado cuando un mob hiere al jugador. La armadura
// equipada mitiga el daño físico: armadura/(armadura+200+nivel·50).
func (j *Jugador) recibirDaño(origenID string, cantidad int, critico bool, m *Mundo, ahora int64) {
	if !j.EstaVivo() {
		return
	}
	armadura := j.armaduraTotal()
	mitigacion := float64(armadura) / (float64(armadura) + 200.0 + float64(j.nivel)*50.0)
	cantidadFinal := int(float64(cantidad) * (1.0 - mitigacion))
	if cantidadFinal < 1 {
		cantidadFinal = 1 // mínimo 1 de daño
	}
	j.hpActual -= cantidadFinal
	j.ultimoDanoMs = ahora
	j.enCombate = true

	// Evento al propio jugador.
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:       "dano",
		OrigenID:   origenID,
		ObjetivoID: j.id,
		Cantidad:   cantidadFinal,
		Critico:    critico,
	})

	if j.hpActual <= 0 {
		j.hpActual = 0
		j.morir(m, ahora)
	}
}

// morir pone al jugador en estado muerto y notifica a su zona.
func (j *Jugador) morir(m *Mundo, ahora int64) {
	j.muertoDesdeMs = ahora
	j.autoAtaqueActivo = false
	j.objetivoID = ""
	// Broadcast death event a jugadores cercanos en la misma zona.
	m.broadcastCercanoZona(proto.MensajeServidor{
		Tipo:      "muerte",
		EntidadID: j.id,
		OrigenID:  j.id,
	}, j.pos, j.instanciaID)
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
	cercanas := m.entidadesCercanasZona(j.pos, j.id, j.instanciaID)
	entidades := make([]proto.EntidadSnapshot, 0, len(cercanas))
	for _, e := range cercanas {
		entidades = append(entidades, snapshotDeEntidad(e))
	}

	estado := proto.EstadoCombate{
		HPActual:         j.hpActual,
		HPMax:            j.hpMax,
		EnergiaActual:    j.energiaActual,
		EnergiaMax:       j.energiaMax,
		Pos:              j.pos,
		Rot:              j.rot,
		ObjetivoID:       j.objetivoID,
		AutoAtaqueActivo: j.autoAtaqueActivo,
		Cooldowns:        cooldownsRestantes(j.cooldowns, time.Now().UnixMilli()),
		BuffsActivos:     cooldownsRestantes(j.buffs, time.Now().UnixMilli()),
		Muerto:           !j.EstaVivo(),
		Faccion:          j.faccion,
		Raza:             j.raza,
		Rol:              j.rol,
		InstanciaID:      j.instanciaID,
		Equipo:           j.equipo,
	}
	// Tipo de instancia para que el cliente sepa en qué modo está.
	if j.instanciaID != "" {
		if inst, ok := m.instancias[j.instanciaID]; ok {
			estado.InstanciaTipo = inst.tipo
		}
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
		ID:         e.ID(),
		Nombre:     e.Nombre(),
		Clase:      e.Clase(),
		Nivel:      e.Nivel(),
		Pos:        e.Pos(),
		Rot:        e.Rot(),
		HPActual:   e.HPActual(),
		HPMax:      e.HPMax(),
		EsJugador:  e.EsJugador(),
		ObjetivoID: e.ObjetivoID(),
	}
	if j, ok := e.(*Jugador); ok {
		s.EnCombate = j.enCombate
		s.Faccion = j.faccion
		s.Raza = j.raza
		s.Rol = j.rol
		s.Equipo = j.equipo
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
// Si el jugador está en una instancia, se persiste su posición pre-instancia
// (la del mundo abierto), no la posición efímera dentro de la masmora/arena.
func (j *Jugador) guardar(p *persistencia.Gestor) error {
	// Posición a persistir: si está en instancia, usar la pre-instancia.
	posAGuardar := j.pos
	if j.instanciaID != "" && j.posPreInstancia != (proto.Vec3{}) {
		posAGuardar = j.posPreInstancia
	}
	pj := persistencia.Personaje{
		Nombre:      j.nombre,
		Cuenta:      j.cuenta,
		Clase:       j.clase,
		Faccion:     j.faccion,
		Raza:        j.raza,
		Nivel:       j.nivel,
		Experiencia: j.xp,
		PosMundo:    posAGuardar,
		RotMundo:    j.rot,
		Habilidad:   idsHabilidades(j.claseDef),
		Inventario:  []string{},
		InventarioStacks: j.stacksParaPersist(),
		Profesiones: j.profesionesParaPersist(),
		Oro:         j.oro,
		MisionesActivas:     j.misionesActivasParaPersist(),
		MisionesCompletadas: j.misionesCompletadasParaPersist(),
		Equipado:            j.equipadoParaPersist(),
		CreadoUnixMs: 0, // se preserva al cargar; al crear nuevo se pone al guardar la primera vez
	}
	// Si ya existe en disco, preservar creado y otros campos no modificados.
	existente, err := p.Cargar(j.nombre)
	if err == nil && existente != nil {
		pj.CreadoUnixMs = existente.CreadoUnixMs
		pj.Inventario = existente.Inventario
	} else {
		pj.CreadoUnixMs = time.Now().UnixMilli()
	}
	return p.Guardar(pj)
}

// misionesActivasParaPersist serializa las misiones activas para guardar.
func (j *Jugador) misionesActivasParaPersist() []persistencia.MisionPersist {
	out := make([]persistencia.MisionPersist, 0, len(j.misionesActivas))
	for _, est := range j.misionesActivas {
		mp := persistencia.MisionPersist{
			MisionID:   est.MisionID,
			Completada: est.Completada,
			Progreso:   make(map[string]int, len(est.Progreso)),
		}
		for k, v := range est.Progreso {
			mp.Progreso[k] = v
		}
		out = append(out, mp)
	}
	return out
}

// misionesCompletadasParaPersist serializa los IDs de misiones completadas.
func (j *Jugador) misionesCompletadasParaPersist() []string {
	out := make([]string, 0, len(j.misionesCompletadas))
	for id := range j.misionesCompletadas {
		out = append(out, id)
	}
	return out
}

// equipadoParaPersist serializa las ranuras de equipo equipadas.
func (j *Jugador) equipadoParaPersist() []persistencia.EquipSlot {
	out := make([]persistencia.EquipSlot, 0, len(j.equipado))
	for slot, itemID := range j.equipado {
		out = append(out, persistencia.EquipSlot{Slot: slot, ItemID: itemID})
	}
	return out
}

// idsHabilidades extrae los IDs de habilidades de una DefClase.
func idsHabilidades(d DefClase) []string {
	out := make([]string, 0, len(d.Habilidades))
	for _, h := range d.Habilidades {
		out = append(out, h.ID)
	}
	return out
}

// ─── Inventario y profesiones ───────────────────────────────────────────
//
// El inventario es un map itemID → cantidad (pila). Las profesiones se
// guardan como EstadoProfesion. Tanto Craftear como AprenderProfesion
// asumen que el lock del mundo (m.mu) está tomado por el llamador.

// ResultadoCrafteo es el resultado de un crafteo, para construir la
// respuesta al cliente.
type ResultadoCrafteo struct {
	OK                bool
	Error             string
	RecetaID          string
	ResultadoItemID   string
	ResultadoCantidad int
	Skill             int
	SkillMax          int
	SubioSkill        bool
}

// ResultadoProfesion es el resultado de aprender una profesión o rango.
type ResultadoProfesion struct {
	OK             bool
	Error          string
	ProfesionID    string
	Skill          int
	SkillMax       int
	RangoID        string
	Especializacion string
}

// Inventario devuelve una copia del inventario (itemID → cantidad).
func (j *Jugador) Inventario() map[string]int {
	out := make(map[string]int, len(j.inventario))
	for k, v := range j.inventario {
		out[k] = v
	}
	return out
}

// Profesiones devuelve una copia de los estados de profesión.
func (j *Jugador) Profesiones() []*EstadoProfesion {
	out := make([]*EstadoProfesion, 0, len(j.profesiones))
	for _, ep := range j.profesiones {
		cp := *ep
		out = append(out, &cp)
	}
	return out
}

// CantidadItem devuelve cuántas unidades de un ítem tiene el jugador.
func (j *Jugador) CantidadItem(itemID string) int {
	return j.inventario[itemID]
}

// AgregarItem añade unidades de un ítem al inventario.
func (j *Jugador) AgregarItem(itemID string, cantidad int) {
	if cantidad <= 0 {
		return
	}
	j.inventario[itemID] += cantidad
}

// stacksParaPersist convierte el inventario a la lista de pilas persistible.
func (j *Jugador) stacksParaPersist() []persistencia.ItemStack {
	out := make([]persistencia.ItemStack, 0, len(j.inventario))
	for id, cant := range j.inventario {
		if cant > 0 {
			out = append(out, persistencia.ItemStack{ItemID: id, Cantidad: cant})
		}
	}
	return out
}

// profesionesParaPersist convierte los estados de profesión a la lista
// persistible.
func (j *Jugador) profesionesParaPersist() []persistencia.ProfesionPersist {
	out := make([]persistencia.ProfesionPersist, 0, len(j.profesiones))
	for _, ep := range j.profesiones {
		out = append(out, persistencia.ProfesionPersist{
			ProfesionID:      ep.ProfesionID,
			Skill:            ep.Skill,
			RangosAprendidos: append([]string(nil), ep.RangosAprendidos...),
			Especializacion:  ep.Especializacion,
		})
	}
	return out
}

// AprenderProfesion enseña una profesión primaria al jugador (rango
// aprendiz incluido). Respeta el límite de MaxProfesionesPrimarias.
// Adquiere el lock del mundo internamente (se llama desde sesion.go).
func (j *Jugador) AprenderProfesion(m *Mundo, profID string) ResultadoProfesion {
	m.mu.Lock()
	defer m.mu.Unlock()
	def, ok := m.profesiones[profID]
	if !ok {
		return ResultadoProfesion{Error: "profesión inválida"}
	}
	if _, ya := j.profesiones[profID]; ya {
		return ResultadoProfesion{Error: "ya conoces esta profesión"}
	}
	// Límite de profesiones primarias.
	if def.Primaria {
		primarias := 0
		for pid, ep := range j.profesiones {
			if pd, ok := m.profesiones[pid]; ok && pd.Primaria {
				primarias++
				_ = ep
			}
		}
		if primarias >= MaxProfesionesPrimarias {
			return ResultadoProfesion{Error: "ya tienes el máximo de profesiones primarias"}
		}
	}
	// Encontrar el rango aprendiz (SkillReq == 0).
	rangoAprendiz := ""
	for _, rg := range def.Rangos {
		if rg.SkillReq == 0 {
			rangoAprendiz = rg.ID
			break
		}
	}
	if rangoAprendiz == "" {
		return ResultadoProfesion{Error: "la profesión no tiene rango aprendiz"}
	}
	// Bonus racial de profesión: si la raza del jugador tiene un bonus para
	// esta profesión (p.ej. Tauren +15 Herboristería, Gnomo +15 Ingeniería),
	// arranca con esa cantidad de skill en lugar de 0. Refleja los raciales
	// pasivos de bonificación de profesión de WoW 3.3.5a. Se topea al
	// skillMax del rango aprendiz para no saltarse el rango.
	skillInicial := 0
	if razaDef, ok := m.razas[j.raza]; ok && razaDef.BonusProfesionID == profID && razaDef.BonusProfesionPuntos > 0 {
		skillInicial = razaDef.BonusProfesionPuntos
	}
	ep := &EstadoProfesion{
		ProfesionID:      profID,
		Skill:            skillInicial,
		RangosAprendidos: []string{rangoAprendiz},
	}
	if max := ep.SkillMax(def); skillInicial > max {
		ep.Skill = max
		skillInicial = max
	}
	j.profesiones[profID] = ep
	return ResultadoProfesion{
		OK:          true,
		ProfesionID: profID,
		Skill:       skillInicial,
		SkillMax:    ep.SkillMax(def),
		RangoID:     rangoAprendiz,
	}
}

// AprenderRango enseña un rango superior de una profesión conocida.
// Requiere que la habilidad actual alcance el SkillReq del rango.
// Adquiere el lock del mundo internamente (se llama desde sesion.go).
func (j *Jugador) AprenderRango(m *Mundo, profID, rangoID string) ResultadoProfesion {
	m.mu.Lock()
	defer m.mu.Unlock()
	def, ok := m.profesiones[profID]
	if !ok {
		return ResultadoProfesion{Error: "profesión inválida"}
	}
	ep, ya := j.profesiones[profID]
	if !ya {
		return ResultadoProfesion{Error: "no conoces esa profesión"}
	}
	var rango DefRango
	encontrado := false
	for _, rg := range def.Rangos {
		if rg.ID == rangoID {
			rango = rg
			encontrado = true
			break
		}
	}
	if !encontrado {
		return ResultadoProfesion{Error: "rango inválido"}
	}
	if ep.RangoAprendido(rangoID) {
		return ResultadoProfesion{Error: "ya conoces ese rango"}
	}
	if ep.Skill < rango.SkillReq {
		return ResultadoProfesion{Error: "habilidad insuficiente para ese rango"}
	}
	ep.RangosAprendidos = append(ep.RangosAprendidos, rangoID)
	return ResultadoProfesion{
		OK:          true,
		ProfesionID: profID,
		Skill:       ep.Skill,
		SkillMax:    ep.SkillMax(def),
		RangoID:     rangoID,
	}
}

// AprenderEspecializacion elige una rama de especialización de una
// profesión (p.ej. Peletería dragontina/elemental/tribal, o Herrería
// forjador de armaduras/armas). Requiere habilidad >= SkillReq y consume
// los materiales de la misión (abstracción de la guía). Soporta árboles
// anidados de dos niveles (Herrería): una especialización con
// RequiereEspecializacion != "" solo se aprende si el jugador ya eligió
// ese padre; al aprenderla, la hoja reemplaza al padre en el estado. Una
// especialización de nivel superior (sin padre) requiere no tener ninguna.
// Adquiere el lock del mundo internamente (se llama desde sesion.go).
func (j *Jugador) AprenderEspecializacion(m *Mundo, profID, espID string) ResultadoProfesion {
	m.mu.Lock()
	defer m.mu.Unlock()
	def, ok := m.profesiones[profID]
	if !ok {
		return ResultadoProfesion{Error: "profesión inválida"}
	}
	ep, ya := j.profesiones[profID]
	if !ya {
		return ResultadoProfesion{Error: "no conoces esa profesión"}
	}
	var esp DefEspecializacion
	encontrado := false
	for _, e := range def.Especializaciones {
		if e.ID == espID {
			esp = e
			encontrado = true
			break
		}
	}
	if !encontrado {
		return ResultadoProfesion{Error: "especialización inválida"}
	}
	// Comprobación de árbol: si la especialización tiene padre, el jugador
	// debe tener exactamente ese padre elegido; si no tiene padre, no debe
	// tener ninguna especialización aún.
	if esp.RequiereEspecializacion != "" {
		if ep.Especializacion != esp.RequiereEspecializacion {
			return ResultadoProfesion{Error: "debes ser " + esp.RequiereEspecializacion + " antes de esta especialización"}
		}
	} else if ep.Especializacion != "" {
		return ResultadoProfesion{Error: "ya tienes una especialización en esta profesión"}
	}
	if ep.Skill < esp.SkillReq {
		return ResultadoProfesion{Error: "habilidad insuficiente para esa especialización"}
	}
	// Comprobar y consumir materiales de la misión.
	for _, mt := range esp.Materiales {
		if j.CantidadItem(mt.ItemID) < mt.Cantidad {
			nombre := mt.ItemID
			if d, ok := m.items[mt.ItemID]; ok {
				nombre = d.Nombre
			}
			return ResultadoProfesion{Error: "faltan materiales: " + nombre}
		}
	}
	for _, mt := range esp.Materiales {
		j.inventario[mt.ItemID] -= mt.Cantidad
		if j.inventario[mt.ItemID] <= 0 {
			delete(j.inventario, mt.ItemID)
		}
	}
	ep.Especializacion = espID
	return ResultadoProfesion{
		OK:             true,
		ProfesionID:    profID,
		Skill:          ep.Skill,
		SkillMax:       ep.SkillMax(def),
		Especializacion: espID,
	}
}

// Craftear ejecuta una receta: valida skill, comprueba materiales, los
// consume, produce el ítem resultado y (si procede) sube la habilidad.
// Adquiere el lock del mundo internamente (se llama desde sesion.go).
func (j *Jugador) Craftear(m *Mundo, recetaID string) ResultadoCrafteo {
	m.mu.Lock()
	defer m.mu.Unlock()
	// Buscar la receta en todas las profesiones.
	var receta DefReceta
	var profDef DefProfesion
	var ep *EstadoProfesion
	encontrado := false
	for pid, pd := range m.profesiones {
		for _, rc := range pd.Recetas {
			if rc.ID == recetaID {
				receta = rc
				profDef = pd
				ep = j.profesiones[pid]
				encontrado = true
				break
			}
		}
		if encontrado {
			break
		}
	}
	if !encontrado {
		return ResultadoCrafteo{RecetaID: recetaID, Error: "receta inválida"}
	}
	if ep == nil {
		return ResultadoCrafteo{RecetaID: recetaID, Error: "no conoces la profesión de esta receta"}
	}
	skillMax := ep.SkillMax(profDef)
	if ep.Skill < receta.SkillReq {
		return ResultadoCrafteo{RecetaID: recetaID, Error: "habilidad insuficiente para esta receta"}
	}
	if receta.Especializacion != "" && ep.Especializacion != receta.Especializacion {
		return ResultadoCrafteo{RecetaID: recetaID, Error: "requiere la especialización " + receta.Especializacion}
	}
	// Comprobar materiales.
	for _, mat := range receta.Materiales {
		if j.CantidadItem(mat.ItemID) < mat.Cantidad {
			nombre := mat.ItemID
			if d, ok := m.items[mat.ItemID]; ok {
				nombre = d.Nombre
			}
			return ResultadoCrafteo{RecetaID: recetaID, Error: "faltan materiales: " + nombre}
		}
	}
	// Consumir materiales.
	for _, mat := range receta.Materiales {
		j.inventario[mat.ItemID] -= mat.Cantidad
		if j.inventario[mat.ItemID] <= 0 {
			delete(j.inventario, mat.ItemID)
		}
	}
	// Producir resultado.
	j.AgregarItem(receta.ResultadoID, receta.ResultadoCantidad)
	// Subir habilidad si current < SkillHasta y current < skillMax.
	subio := false
	if ep.Skill < receta.SkillHasta && ep.Skill < skillMax {
		ep.Skill++
		subio = true
	}
	return ResultadoCrafteo{
		OK:                true,
		RecetaID:          recetaID,
		ResultadoItemID:   receta.ResultadoID,
		ResultadoCantidad: receta.ResultadoCantidad,
		Skill:             ep.Skill,
		SkillMax:          skillMax,
		SubioSkill:        subio,
	}
}

// Recolectar permite a un jugador con una profesión de recolección
// (Herboristería, futuras Minería / Desuello) recolectar de un nodo del
// mundo. A diferencia de Craftear, no consume materiales de la bolsa (el
// nodo es la fuente); simplemente comprueba la habilidad mínima, produce
// el item del nodo y sube la habilidad mientras skill < SkillHasta.
func (j *Jugador) Recolectar(m *Mundo, nodoID string) ResultadoCrafteo {
	m.mu.Lock()
	defer m.mu.Unlock()
	// Buscar el nodo en todas las profesiones.
	var nodo DefNodo
	var profDef DefProfesion
	var ep *EstadoProfesion
	encontrado := false
	for pid, pd := range m.profesiones {
		for _, nd := range pd.Nodos {
			if nd.ID == nodoID {
				nodo = nd
				profDef = pd
				ep = j.profesiones[pid]
				encontrado = true
				break
			}
		}
		if encontrado {
			break
		}
	}
	if !encontrado {
		return ResultadoCrafteo{RecetaID: nodoID, Error: "nodo inválido"}
	}
	if ep == nil {
		return ResultadoCrafteo{RecetaID: nodoID, Error: "no conoces la profesión de este nodo"}
	}
	skillMax := ep.SkillMax(profDef)
	if ep.Skill < nodo.SkillReq {
		return ResultadoCrafteo{RecetaID: nodoID, Error: "habilidad insuficiente para recolectar este nodo"}
	}
	// Producir resultado (sin consumir materiales).
	j.AgregarItem(nodo.ResultadoID, nodo.ResultadoCantidad)
	// Subir habilidad si current < SkillHasta y current < skillMax.
	subio := false
	if ep.Skill < nodo.SkillHasta && ep.Skill < skillMax {
		ep.Skill++
		subio = true
	}
	return ResultadoCrafteo{
		OK:                true,
		RecetaID:          nodoID,
		ResultadoItemID:   nodo.ResultadoID,
		ResultadoCantidad: nodo.ResultadoCantidad,
		Skill:             ep.Skill,
		SkillMax:          skillMax,
		SubioSkill:        subio,
	}
}
