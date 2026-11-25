// enemigo.go define los mobs hostiles controlados por IA simple.
// Estados: patrullando → persiguiendo → atacando → muerto → (respawn) → patrullando.
//
// MVP: mobs tipo "lobo" cuerpo a cuerpo, aggro por proximidad,
// respawn en su spawnPos tras RespawnEnemigoMs.
package mundo

import (
	"time"

	"aethelgard/servidor/interno/proto"
)

// RespawnEnemigoMs tiempo hasta reaparecer un mob muerto.
const RespawnEnemigoMs = 30_000

// RangoAgroMetros distancia a la que un mob agroa jugadores.
const RangoAgroMetros = 8.0

// RangoPatrullaMetros distancia máxima desde spawnPos durante patrulla.
const RangoPatrullaMetros = 5.0

// VelocidadEnemigoMps velocidad de persecución.
const VelocidadEnemigoMps = 4.0

// Enemigo es una entidad hostil controlada por IA.
type Enemigo struct {
	id            string
	nombre        string
	clase         string // tipo de mob: "lobo", "jabali", etc.
	nivel         int
	pos           proto.Vec3
	rot           proto.Vec4
	hpActual      int
	hpMax         int
	spawnPos      proto.Vec3
	instanciaID   string // "" = mundo abierto; inst.id = mob de instancia
	danoBase      int    // 0 = usar fórmula (5 + nivel*2); >0 = explícito
	estado        string // "patrullando" | "persiguiendo" | "atacando" | "muerto"
	objetivoID    string
	ultimoAtacanteID string // último jugador que dañó al mob (crédito de muerte/XP)
	ultimoAtaqueMs int64
	muertoDesdeMs int64
	enCombate     bool
	direccionPatrulla proto.Vec3 // dirección actual de patrulla
	ultimoCambioDirMs int64
}

// ─── Implementación de Entidad ──────────────────────────────────────────

func (e *Enemigo) ID() string            { return e.id }
func (e *Enemigo) Nombre() string        { return e.nombre }
func (e *Enemigo) Clase() string         { return e.clase }
func (e *Enemigo) Nivel() int            { return e.nivel }
func (e *Enemigo) Pos() proto.Vec3         { return e.pos }
func (e *Enemigo) SetPos(p proto.Vec3)     { e.pos = p }
func (e *Enemigo) Rot() proto.Vec4         { return e.rot }
func (e *Enemigo) SetRot(r proto.Vec4)     { e.rot = r }
func (e *Enemigo) HPActual() int         { return e.hpActual }
func (e *Enemigo) HPMax() int            { return e.hpMax }
func (e *Enemigo) EnergiaActual() int    { return 0 }
func (e *Enemigo) EnergiaMax() int       { return 0 }
func (e *Enemigo) EstaVivo() bool        { return e.muertoDesdeMs == 0 }
func (e *Enemigo) EsJugador() bool       { return false }
func (e *Enemigo) ObjetivoID() string    { return e.objetivoID }
func (e *Enemigo) SetObjetivo(id string) { e.objetivoID = id }

// ─── Construcción ──────────────────────────────────────────────────────

// nuevoEnemigo crea un mob de un tipo y nivel dados en la posición indicada.
// HP escala con nivel.
func nuevoEnemigo(nombre, tipo string, nivel int, pos proto.Vec3) *Enemigo {
	hpMax := 40 + nivel*15
	return &Enemigo{
		id:            "", // lo asigna spawnEnemigosIniciales
		nombre:        nombre,
		clase:         tipo,
		nivel:         nivel,
		pos:           pos,
		rot:           proto.Vec4{X: 0, Y: 0, Z: 0, W: 1},
		hpActual:      hpMax,
		hpMax:         hpMax,
		spawnPos:      pos,
		estado:        "patrullando",
		direccionPatrulla: proto.Vec3{X: 1, Y: 0, Z: 0},
	}
}

// nuevoEnemigoMasmora crea un mob de instancia con stats explícitos (estilo
// wocc: hpBase + hpPorNivel*nivel, danoBase). Si hpBase == 0, usa la
// fórmula por defecto. Si danoBase == 0, aiAtacar usará la fórmula.
func nuevoEnemigoMasmora(sm DefSpawnMob) *Enemigo {
	hpMax := sm.HPBase + sm.HPPorNivel*sm.Nivel
	if sm.HPBase == 0 {
		hpMax = 40 + sm.Nivel*15
	}
	e := nuevoEnemigo(sm.Nombre, sm.Tipo, sm.Nivel, sm.Pos)
	e.hpMax = hpMax
	e.hpActual = hpMax
	e.danoBase = sm.DanoBase
	return e
}

// ─── IA per tick ────────────────────────────────────────────────────────

// actualizar ejecuta un paso de IA para el enemigo.
// Debe llamarse con el lock del mundo tomado.
func (e *Enemigo) actualizar(m *Mundo, t time.Time) {
	ahora := t.UnixMilli()
	if !e.EstaVivo() {
		if (ahora - e.muertoDesdeMs) >= RespawnEnemigoMs {
			e.respawn()
		}
		return
	}

	switch e.estado {
	case "patrullando":
		e.aiPatrullar(m, ahora)
	case "persiguiendo":
		e.aiPerseguir(m, ahora)
	case "atacando":
		e.aiAtacar(m, ahora, t)
	}

	// Limpieza de objetivo si desapareció o murió.
	if e.objetivoID != "" {
		obj, ok := m.entidadPorID(e.objetivoID)
		if !ok || !obj.EstaVivo() {
			e.objetivoID = ""
			e.estado = "patrullando"
			e.enCombate = false
		}
	}
}

// aiPatrullar: camina lentamente alrededor del spawn. Si un jugador
// entra en rango de agro (y está en la misma zona), cambia a persiguiendo.
func (e *Enemigo) aiPatrullar(m *Mundo, ahora int64) {
	// ¿Jugador cercano para aggro? Solo de la misma zona (instanciaID).
	for _, j := range m.jugadores {
		if !j.EstaVivo() {
			continue
		}
		if j.instanciaID != e.instanciaID {
			continue
		}
		if distancia2D(j.pos, e.pos) <= RangoAgroMetros {
			e.objetivoID = j.id
			e.estado = "persiguiendo"
			e.enCombate = true
			return
		}
	}

	// Cambiar dirección de patrulla cada ~5s.
	if (ahora - e.ultimoCambioDirMs) > 5000 {
		e.direccionPatrulla = proto.Vec3{
			X: randFloatEntre(-1, 1),
			Y: 0,
			Z: randFloatEntre(-1, 1),
		}
		norm := sqrtF(e.direccionPatrulla.X*e.direccionPatrulla.X + e.direccionPatrulla.Z*e.direccionPatrulla.Z)
		if norm > 0.001 {
			e.direccionPatrulla.X /= norm
			e.direccionPatrulla.Z /= norm
		}
		e.ultimoCambioDirMs = ahora
	}

	// Moverse 2 m/s (lento, patrulla).
	desplazamiento := 2.0 / float64(HzPredeterminado)
	nuevaPos := proto.Vec3{
		X: e.pos.X + e.direccionPatrulla.X*desplazamiento,
		Y: e.pos.Y,
		Z: e.pos.Z + e.direccionPatrulla.Z*desplazamiento,
	}
	// Mantenerse dentro del radio de patrulla.
	if distancia2D(nuevaPos, e.spawnPos) > RangoPatrullaMetros {
		// Volver hacia el spawn.
		dirVuelta := proto.Vec3{X: e.spawnPos.X - e.pos.X, Y: 0, Z: e.spawnPos.Z - e.pos.Z}
		norm := sqrtF(dirVuelta.X*dirVuelta.X + dirVuelta.Z*dirVuelta.Z)
		if norm > 0.001 {
			dirVuelta.X /= norm
			dirVuelta.Z /= norm
		}
		nuevaPos = proto.Vec3{
			X: e.pos.X + dirVuelta.X*desplazamiento,
			Y: e.pos.Y,
			Z: e.pos.Z + dirVuelta.Z*desplazamiento,
		}
	}
	e.pos = nuevaPos
}

// aiPerseguir: se mueve hacia el objetivo. Si llega a rango de melee,
// cambia a atacando.
func (e *Enemigo) aiPerseguir(m *Mundo, ahora int64) {
	obj, ok := m.entidadPorID(e.objetivoID)
	if !ok || !obj.EstaVivo() {
		e.objetivoID = ""
		e.estado = "patrullando"
		return
	}
	d := distancia2D(e.pos, obj.Pos())
	if d <= 2.0 {
		e.estado = "atacando"
		return
	}
	// Si el objetivo se alejó demasiado, soltar.
	if d > RangoAgroMetros*3 {
		e.objetivoID = ""
		e.estado = "patrullando"
		e.enCombate = false
		return
	}
	// Moverse hacia el objetivo a VelocidadEnemigoMps.
	desplazamiento := VelocidadEnemigoMps / float64(HzPredeterminado)
	dir := proto.Vec3{X: obj.Pos().X - e.pos.X, Y: 0, Z: obj.Pos().Z - e.pos.Z}
	norm := sqrtF(dir.X*dir.X + dir.Z*dir.Z)
	if norm > 0.001 {
		dir.X /= norm
		dir.Z /= norm
	}
	e.pos = proto.Vec3{
		X: e.pos.X + dir.X*desplazamiento,
		Y: e.pos.Y,
		Z: e.pos.Z + dir.Z*desplazamiento,
	}
	// Rotación hacia el objetivo.
	e.rot = rotHaciaDireccion(dir)
}

// aiAtacar: si el objetivo sigue en rango, ataca cada 2s.
// Si se aleja, vuelve a perseguir.
func (e *Enemigo) aiAtacar(m *Mundo, ahora int64, t time.Time) {
	obj, ok := m.entidadPorID(e.objetivoID)
	if !ok || !obj.EstaVivo() {
		e.objetivoID = ""
		e.estado = "patrullando"
		e.enCombate = false
		return
	}
	d := distancia2D(e.pos, obj.Pos())
	if d > 2.5 {
		e.estado = "persiguiendo"
		return
	}
	if (ahora - e.ultimoAtaqueMs) >= 2000 {
		dano := e.danoBase
		if dano == 0 {
			dano = 5 + e.nivel*2
		}
		if j, ok := obj.(*Jugador); ok {
			j.recibirDaño(e.id, dano, false, m, ahora)
		}
		e.ultimoAtaqueMs = ahora
	}
}

// ─── Daño y muerte ──────────────────────────────────────────────────────

// recibirDaño aplica daño al mob, notifica al atacante (vía broadcast)
// y maneja muerte.
func (e *Enemigo) recibirDaño(origenID string, cantidad int, critico bool, m *Mundo, ahora int64) {
	if !e.EstaVivo() {
		return
	}
	e.hpActual -= cantidad
	e.enCombate = true

	// Track último atacante para crédito de muerte (XP + misiones).
	if _, ok := m.jugadores[origenID]; ok {
		e.ultimoAtacanteID = origenID
	}

	// Si no tiene objetivo, el atacante se vuelve su objetivo.
	if e.objetivoID == "" {
		if j, ok := m.jugadores[origenID]; ok && j.EstaVivo() {
			e.objetivoID = origenID
			e.estado = "persiguiendo"
		}
	}

	// Broadcast del evento de daño a jugadores cercanos en la misma zona.
	m.broadcastCercanoZona(proto.MensajeServidor{
		Tipo:       "dano",
		OrigenID:   origenID,
		ObjetivoID: e.id,
		Cantidad:   cantidad,
		Critico:    critico,
	}, e.pos, e.instanciaID)

	if e.hpActual <= 0 {
		e.hpActual = 0
		e.morir(m, ahora)
	}
}

// morir pone al mob en estado muerto y notifica a su zona.
func (e *Enemigo) morir(m *Mundo, ahora int64) {
	e.muertoDesdeMs = ahora
	e.estado = "muerto"
	e.objetivoID = ""
	e.enCombate = false
	m.broadcastCercanoZona(proto.MensajeServidor{
		Tipo:      "muerte",
		EntidadID: e.id,
	}, e.pos, e.instanciaID)

	// Otorgar XP, progresar misiones de "matar" y soltar botín al último
	// atacante (si es jugador). Estas funciones acceden directo a j/m sin
	// locks porque step ya tiene m.mu.Lock.
	if e.ultimoAtacanteID != "" {
		m.otorgarXPMuerte(e.ultimoAtacanteID, e.nivel, e.clase)
		m.otorgarLootMuerte(e.ultimoAtacanteID, e.nivel, e.clase)
		e.ultimoAtacanteID = ""
	}
}

// respawn revive al mob en su spawnPos.
func (e *Enemigo) respawn() {
	e.hpActual = e.hpMax
	e.pos = e.spawnPos
	e.rot = proto.Vec4{X: 0, Y: 0, Z: 0, W: 1}
	e.muertoDesdeMs = 0
	e.estado = "patrullando"
	e.objetivoID = ""
	e.enCombate = false
	e.ultimoAtaqueMs = 0
}

// ─── Helpers ────────────────────────────────────────────────────────────

// rotHaciaDireccion calcula un quaternion que mira en dir (XZ planar).
// Para MVP dejamos rot en identidad; el cliente orienta el modelo según
// la velocidad recibida en el snapshot. No afecta al gameplay.
func rotHaciaDireccion(dir proto.Vec3) proto.Vec4 {
	_ = dir
	return proto.Vec4{X: 0, Y: 0, Z: 0, W: 1}
}

// randFloatEntre devuelve un float pseudoaleatorio entre min y max.
// Usa un LCG determinístico sin dependencias externas.
// En producción se usaría math/rand/v2 con seed por mundo.
var lcgState uint64 = 0x12345678

func randFloatEntre(min, max float64) float64 {
	lcgState = lcgState*6364136223846793005 + 1442695040888963407
	u := float64(lcgState>>11) / float64(1<<53)
	return min + u*(max-min)
}
