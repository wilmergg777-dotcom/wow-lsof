// instancia.go implementa las instancias aisladas: masmorras PvE y
// arenas PvP. Cada instancia tiene su propio set de entidades (todas
// etiquetadas con el misma instanciaID) y sus propias condiciones de fin.
//
// Las instancias se crean bajo demanda cuando el buscador forma un grupo.
// El ciclo de vida:
//   1. Crear Instancia (masmora o arena).
//   2. Poblar mobs (solo masmora) dentro del mundo con instanciaID = inst.id.
//   3. Mover jugadores adentro: set instanciaID, equipo (PvP), teleport a spawn.
//   4. tick() cada frame: comprobar fin (boss muerto / wipe / timeout).
//   5. Al terminar: enviar instancia_fin a todos, devolver jugadores al
//      mundo abierto, eliminar mobs de la instancia.
//
// El filtrado por instanciaID en entidadesCercanasZona / broadcastCercanoZona
// garantiza que dos instancias nunca se vean entre sí ni con el mundo abierto.
package mundo

import (
	"sync/atomic"
	"time"

	"aethelgard/servidor/interno/proto"
)

// Tipos de instancia.
const (
	InstanciaMasmora  = "masmora"
	InstanciaArenaPvP = "arena_pvp"
)

// Estados de instancia.
const (
	InstanciaActiva      = "activa"
	InstanciaFinalizada  = "finalizada"
)

// Resultados posibles al finalizar.
const (
	ResultadoVictoria = "victoria"
	ResultadoDerrota  = "derrota"
	ResultadoEmpate   = "empate"
)

// MultiplicadorBossHP aplica a los mobs marcados como boss en masmorras.
// Los bosses deben sentirse como un pico de dificultad.
const MultiplicadorBossHP = 3

// contadorInstancia genera IDs únicos para cada instancia.
var contadorInstancia uint64

// Instancia es una zona aislada (masmora PvE o arena PvP).
type Instancia struct {
	id         string
	tipo       string // InstanciaMasmora | InstanciaArenaPvP
	defMasmora *DefMasmora // nil si no es masmora
	defArena   *DefArena   // nil si no es arena
	estado     string
	jugadores  map[string]*Jugador
	equipos    map[string]int // pjID → 0|1 (solo arena)
	creadoMs   int64
	finMs      int64 // 0 = sin timeout; >0 = deadline
	bossID     string // mob boss (solo masmora)
	razonFin   string
}

// nuevoIDInstancia genera un ID estable y único.
func nuevoIDInstancia() string {
	n := atomic.AddUint64(&contadorInstancia, 1)
	return "inst_" + itoaSimple(int(n))
}

// ─── Construcción ────────────────────────────────────────────────────────

// nuevaInstanciaMasmora crea una instancia PvE para una masmora dada,
// con la lista de jugadores que entrarán (ya validados por el buscador).
// NO la registra en el mundo: el llamador debe llamar a iniciar(m).
func nuevaInstanciaMasmora(def *DefMasmora, grupo []*Jugador, ahora int64) *Instancia {
	inst := &Instancia{
		id:        nuevoIDInstancia(),
		tipo:      InstanciaMasmora,
		defMasmora: def,
		estado:    InstanciaActiva,
		jugadores: make(map[string]*Jugador, len(grupo)),
		equipos:   make(map[string]int),
		creadoMs:  ahora,
	}
	for _, j := range grupo {
		inst.jugadores[j.id] = j
		inst.equipos[j.id] = -1 // PvE: sin equipos
	}
	return inst
}

// nuevaInstanciaArena crea una instancia PvP para una arena dada.
// equipos mapea pjID → 0|1. El llamador garantiza que hay exactamente
// 2*TamanoEquipo jugadores y que ambos equipos están completos.
func nuevaInstanciaArena(def *DefArena, grupo []*Jugador, equipos map[string]int, ahora int64) *Instancia {
	inst := &Instancia{
		id:        nuevoIDInstancia(),
		tipo:      InstanciaArenaPvP,
		defArena:  def,
		estado:    InstanciaActiva,
		jugadores: make(map[string]*Jugador, len(grupo)),
		equipos:   make(map[string]int, len(equipos)),
		creadoMs:  ahora,
		finMs:     ahora + int64(def.TiempoMaxMs),
	}
	for _, j := range grupo {
		inst.jugadores[j.id] = j
		inst.equipos[j.id] = equipos[j.id]
	}
	return inst
}

// ID devuelve el identificador de la instancia.
func (in *Instancia) ID() string { return in.id }

// Tipo devuelve el tipo de instancia.
func (in *Instancia) Tipo() string { return in.tipo }

// iniciar registra la instancia en el mundo, puebla sus mobs (masmora)
// y mueve a los jugadores adentro. Debe llamarse con el lock de m tomado.
func (in *Instancia) iniciar(m *Mundo) {
	m.instancias[in.id] = in

	if in.tipo == InstanciaMasmora {
		in.poblarMobs(m)
	}

	// Mover jugadores adentro.
	for _, j := range in.jugadores {
		// Guardar posición pre-instancia para restaurar al salir.
		j.posPreInstancia = j.pos
		j.instanciaID = in.id
		j.equipo = in.equipos[j.id]
		// Teleport al spawn según tipo.
		switch in.tipo {
		case InstanciaMasmora:
			j.pos = in.defMasmora.PosSpawn
		case InstanciaArenaPvP:
			if j.equipo == 0 {
				j.pos = in.defArena.PosEquipoA
			} else {
				j.pos = in.defArena.PosEquipoB
			}
		}
		j.objetivoID = ""
		j.autoAtaqueActivo = false
		// Refrescar HP/energía al entrar (entrada limpia).
		j.hpActual = j.hpMax
		j.energiaActual = j.energiaMax
		j.muertoDesdeMs = 0
		j.cooldowns = make(map[string]int64)
		j.buffs = make(map[string]int64)
	}

	// Notificar a cada jugador del match.
	in.notificarMatch(m)
}

// poblarMobs genera los mobs definidos en la masmora dentro del mundo,
// todos con instanciaID = in.id. Usa los stats explícitos de DefSpawnMob
// (HPBase/HPPorNivel/DanoBase, estilo wocc) y marca el bossID.
func (in *Instancia) poblarMobs(m *Mundo) {
	for i, sm := range in.defMasmora.Mobs {
		e := nuevoEnemigoMasmora(sm)
		e.spawnPos = sm.Pos
		e.id = "inst_" + in.id + "_mob_" + itoaSimple(i+1)
		e.instanciaID = in.id
		if sm.EsBoss {
			// Boss: más HP y marca para condición de victoria + loot mejorado.
			e.hpMax = e.hpMax * MultiplicadorBossHP
			e.hpActual = e.hpMax
			e.esBoss = true
			in.bossID = e.id
		}
		m.entidades[e.id] = e
		m.enemigos[e.id] = e
	}
}

// notificarMatch envía a cada jugador el mensaje de match encontrado.
func (in *Instancia) notificarMatch(m *Mundo) {
	nombres := make([]string, 0, len(in.jugadores))
	for _, j := range in.jugadores {
		nombres = append(nombres, j.nombre)
	}
	for _, j := range in.jugadores {
		j.enviarNoBloqueante(proto.MensajeServidor{
			Tipo:          "buscador_match",
			InstanciaID:   in.id,
			InstanciaTipo: in.tipo,
			Equipo:        in.equipos[j.id],
			Grupo:         nombres,
			Mensaje:       in.descripcion(),
		})
	}
}

// descripcion devuelve un texto humano del destino del grupo.
func (in *Instancia) descripcion() string {
	switch in.tipo {
	case InstanciaMasmora:
		return in.defMasmora.Nombre
	case InstanciaArenaPvP:
		return in.defArena.Nombre
	}
	return ""
}

// ─── Tick ────────────────────────────────────────────────────────────────

// tick comprueba las condiciones de fin de la instancia.
// Devuelve true si la instancia terminó y ya limpió sus entidades
// (el llamador debe eliminarla de m.instancias).
// Debe llamarse con el lock de m tomado.
func (in *Instancia) tick(m *Mundo, t time.Time) bool {
	if in.estado == InstanciaFinalizada {
		return true
	}
	ahora := t.UnixMilli()

	switch in.tipo {
	case InstanciaMasmora:
		// Victoria: boss muerto.
		if in.bossID != "" {
			boss, ok := m.enemigos[in.bossID]
			if !ok || !boss.EstaVivo() {
				in.finalizar(m, ResultadoVictoria, "boss_derrotado")
				return true
			}
		}
		// Derrota: todos los jugadores muertos simultáneamente.
		if in.todosJugadoresMuertos() {
			in.finalizar(m, ResultadoDerrota, "grupo_dizmado")
			return true
		}

	case InstanciaArenaPvP:
		// Victoria por wipe: un equipo sin vivos.
		eq0vivos, eq1vivos := in.contarVivosPorEquipo()
		if eq0vivos == 0 && eq1vivos == 0 {
			in.finalizar(m, ResultadoEmpate, "doble_wipe")
			return true
		}
		if eq0vivos == 0 {
			in.finalizarEquipos(m, 1, "equipo_1_gana")
			return true
		}
		if eq1vivos == 0 {
			in.finalizarEquipos(m, 0, "equipo_0_gana")
			return true
		}
		// Timeout: gana el equipo con más vivos; empate si hay igualdad.
		if in.finMs > 0 && ahora >= in.finMs {
			if eq0vivos > eq1vivos {
				in.finalizarEquipos(m, 0, "timeout")
			} else if eq1vivos > eq0vivos {
				in.finalizarEquipos(m, 1, "timeout")
			} else {
				in.finalizar(m, ResultadoEmpate, "timeout")
			}
			return true
		}
	}
	return false
}

// todosJugadoresMuertos devuelve true si ningún jugador de la instancia está vivo.
func (in *Instancia) todosJugadoresMuertos() bool {
	for _, j := range in.jugadores {
		if j.EstaVivo() {
			return false
		}
	}
	return true
}

// contarVivosPorEquipo cuenta cuántos jugadores vivos hay en cada equipo (arena).
func (in *Instancia) contarVivosPorEquipo() (int, int) {
	var eq0, eq1 int
	for _, j := range in.jugadores {
		if !j.EstaVivo() {
			continue
		}
		switch in.equipos[j.id] {
		case 0:
			eq0++
		case 1:
			eq1++
		}
	}
	return eq0, eq1
}

// ─── Finalización ────────────────────────────────────────────────────────

// finalizar termina la instancia dando el mismo resultado a todos los
// jugadores (caso masmora: victoria o derrota colectiva). En victoria de
// masmora otorga una recompensa de completar (XP + oro) a cada miembro.
func (in *Instancia) finalizar(m *Mundo, resultado, razon string) {
	in.estado = InstanciaFinalizada
	in.razonFin = razon
	if in.tipo == InstanciaMasmora && resultado == ResultadoVictoria {
		in.otorgarRecompensaCompletar(m)
	}
	for _, j := range in.jugadores {
		j.enviarNoBloqueante(proto.MensajeServidor{
			Tipo:        "instancia_fin",
			InstanciaID: in.id,
			Resultado:   resultado,
			Razon:       razon,
		})
	}
	in.devolverJugadoresAlMundo(m)
	in.limpiarEntidades(m)
}

// otorgarRecompensaCompletar da a cada jugador de la masmora un bonus de XP
// + oro por derrotar al boss. XP = nivelBoss*40, oro = nivelBoss*15. Llamado
// desde finalizar (m.mu Lock).
func (in *Instancia) otorgarRecompensaCompletar(m *Mundo) {
	nivelBoss := nivelBossMasmora(*in.defMasmora)
	if nivelBoss == 0 {
		nivelBoss = in.defMasmora.NivelMax
	}
	xpBonus := nivelBoss * 40
	oroBonus := nivelBoss * 15
	for _, j := range in.jugadores {
		j.ganarXP(xpBonus, m)
		j.oro += oroBonus
	}
}

// finalizarEquipos termina una arena declarando ganador al equipoGanador.
// Los jugadores del equipo ganador reciben "victoria", los del perdedor "derrota".
func (in *Instancia) finalizarEquipos(m *Mundo, equipoGanador int, razon string) {
	in.estado = InstanciaFinalizada
	in.razonFin = razon
	for _, j := range in.jugadores {
		res := ResultadoDerrota
		if in.equipos[j.id] == equipoGanador {
			res = ResultadoVictoria
		}
		j.enviarNoBloqueante(proto.MensajeServidor{
			Tipo:        "instancia_fin",
			InstanciaID: in.id,
			Resultado:   res,
			Razon:       razon,
		})
	}
	in.devolverJugadoresAlMundo(m)
	in.limpiarEntidades(m)
}

// devolverJugadoresAlMundo restaura a cada jugador al mundo abierto:
// limpia instanciaID/equipo, restaura posición pre-instancia, full HP.
func (in *Instancia) devolverJugadoresAlMundo(m *Mundo) {
	for _, j := range in.jugadores {
		j.instanciaID = ""
		j.equipo = -1
		// Restaurar posición pre-instancia (si era cero, spawn default).
		if j.posPreInstancia != (proto.Vec3{}) {
			j.pos = j.posPreInstancia
		} else {
			j.pos = j.spawnPos
		}
		j.posPreInstancia = proto.Vec3{}
		j.objetivoID = ""
		j.autoAtaqueActivo = false
		j.hpActual = j.hpMax
		j.energiaActual = j.energiaMax
		j.muertoDesdeMs = 0
		j.cooldowns = make(map[string]int64)
		j.buffs = make(map[string]int64)
	}
}

// limpiarEntidades elimina del mundo todos los mobs que pertenecían a
// esta instancia. Los jugadores NO se tocan (siguen en m.jugadores/m.entidades).
func (in *Instancia) limpiarEntidades(m *Mundo) {
	for _, e := range m.enemigos {
		if e.instanciaID == in.id {
			delete(m.entidades, e.id)
			delete(m.enemigos, e.id)
		}
	}
}

// ─── Bajas y abandonos ───────────────────────────────────────────────────

// sacarJugador elimina a un jugador de la instancia (p. ej. al desconectarse).
// Si la instancia queda vacía o (en arena) un equipo queda sin nadie, la
// instancia se finaliza inmediatamente.
// Debe llamarse con el lock de m tomado. Devuelve true si la instancia terminó.
func (in *Instancia) sacarJugador(m *Mundo, pjID string, ahora int64) bool {
	j, ok := in.jugadores[pjID]
	if !ok {
		return false
	}
	delete(in.jugadores, pjID)
	delete(in.equipos, pjID)
	// Limpiar estado de instancia del jugador (queda en mundo abierto).
	j.instanciaID = ""
	j.equipo = -1
	j.autoAtaqueActivo = false
	if j.posPreInstancia != (proto.Vec3{}) {
		j.pos = j.posPreInstancia
	}
	j.posPreInstancia = proto.Vec3{}

	if in.estado == InstanciaFinalizada {
		return true
	}

	switch in.tipo {
	case InstanciaMasmora:
		if len(in.jugadores) == 0 {
			in.finalizar(m, ResultadoDerrota, "grupo_abandono")
			return true
		}
	case InstanciaArenaPvP:
		eq0, eq1 := in.contarVivosPorEquipo()
		// Si un equipo ya no tiene jugadores vivos ni en la instancia, gana el otro.
		if eq0 == 0 && eq1 == 0 {
			in.finalizar(m, ResultadoEmpate, "abandono_total")
			return true
		}
		if eq0 == 0 {
			in.finalizarEquipos(m, 1, "equipo_0_abandono")
			return true
		}
		if eq1 == 0 {
			in.finalizarEquipos(m, 0, "equipo_1_abandono")
			return true
		}
	}
	return false
}
