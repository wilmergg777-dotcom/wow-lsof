// buscador.go implementa el buscador de masmorras (PvE) y arenas (PvP)
// con matchmaking cross-faction. Las facciones NUNCA restringen el
// agrupamiento: un grupo PvE o un equipo PvP puede mezclar Alianza y
// Horda libremente.
//
// El buscador no tiene su propio lock: opera bajo el lock del mundo (m.mu).
// Los métodos públicos (EntrarCola*/SalirCola*) lo adquieren; procesar()
// se llama desde step() que ya lo tiene tomado.
//
// Matchmaking PvE (másmorra 3-man):
//   - Fase estricta: 1 tanque + 1 soporte + 1 dps. Si se cubre, forma grupo.
//   - Fase relajada (tras TiempoRelajacionColaMs): cualquier 3 jugadores
//     encolados para esa masmora, sin importar roles. Evita esperas eternas
//     cuando falta un rol concreto.
//
// Matchmaking PvP (arena 2v2):
//   - Cuando hay 2*TamanoEquipo jugadores encolados, se reparten en dos
//     equipos. La asignación ignora facciones (cross-faction).
package mundo

import (
	"sort"
	"time"

	"aethelgard/servidor/interno/proto"
)

// TiempoRelajacionColaMs es el tiempo tras el cual el buscador PvE pasa
// de exigir la trinidad completa a aceptar cualquier combinación.
const TiempoRelajacionColaMs = 60_000

// Buscador gestiona las colas PvE y PvP y forma grupos bajo demanda.
type Buscador struct {
	m       *Mundo
	colaPvE map[string]map[string]*solicitudPvE // masmoraID → pjID → solicitud
	colaPvP map[string]map[string]*solicitudPvP // arenaID → pjID → solicitud
}

type solicitudPvE struct {
	j          *Jugador
	masmoraID  string
	rol        string
	faccion    string
	encoladoMs int64
}

type solicitudPvP struct {
	j          *Jugador
	arenaID    string
	faccion    string
	encoladoMs int64
}

// nuevoBuscador construye un buscador ligado a un mundo.
func nuevoBuscador(m *Mundo) *Buscador {
	return &Buscador{
		m:       m,
		colaPvE: make(map[string]map[string]*solicitudPvE),
		colaPvP: make(map[string]map[string]*solicitudPvP),
	}
}

// ─── API pública (llamada desde sesión, adquiere m.mu) ───────────────────

// EntrarColaPvE añade un jugador a la cola de una masmora.
// Valida que la masmora exista y que el jugador tenga nivel suficiente.
func (b *Buscador) EntrarColaPvE(j *Jugador, masmoraID string) error {
	b.m.mu.Lock()
	defer b.m.mu.Unlock()

	def, ok := b.m.masmoras[masmoraID]
	if !ok {
		return errBuscador("masmora no existe")
	}
	if j.nivel < def.NivelMin {
		return errBuscador("nivel insuficiente")
	}
	// No re-encolar si ya está en alguna cola.
	if b.enCola(j.id) {
		return errBuscador("ya estás en cola")
	}
	// No encolar si ya está en una instancia.
	if j.instanciaID != "" {
		return errBuscador("ya estás en una instancia")
	}

	cola, ok := b.colaPvE[masmoraID]
	if !ok {
		cola = make(map[string]*solicitudPvE)
		b.colaPvE[masmoraID] = cola
	}
	cola[j.id] = &solicitudPvE{
		j:          j,
		masmoraID:  masmoraID,
		rol:        j.rol,
		faccion:    j.faccion,
		encoladoMs: time.Now().UnixMilli(),
	}
	b.enviarEstadoColaPvE(j, masmoraID)
	return nil
}

// MasmorrasDisponibles devuelve las masmorras desbloqueadas para un nivel
// dado (NivelMin <= nivel), ordenadas por NivelMin. Es la vista de
// "desbloqueo progresivo": a medida que el jugador sube de nivel, más
// masmorras aparecen en la lista. No requiere lock (lee el catálogo, que es
// inmutable tras el arranque).
func (b *Buscador) MasmorrasDisponibles(nivel int) []DefMasmora {
	out := make([]DefMasmora, 0, len(b.m.masmoras))
	for _, def := range b.m.masmoras {
		if def.NivelMin <= nivel {
			out = append(out, def)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].NivelMin < out[j].NivelMin })
	return out
}

// SalirColaPvE saca a un jugador de la cola PvE (si estaba).
func (b *Buscador) SalirColaPvE(j *Jugador) {
	b.m.mu.Lock()
	defer b.m.mu.Unlock()
	for mid, cola := range b.colaPvE {
		if _, ok := cola[j.id]; ok {
			delete(cola, j.id)
			b.enviarEstadoSalida(j, mid, "masmora")
			return
		}
	}
}

// EntrarColaPvP añade un jugador a la cola de una arena.
func (b *Buscador) EntrarColaPvP(j *Jugador, arenaID string) error {
	b.m.mu.Lock()
	defer b.m.mu.Unlock()

	def, ok := b.m.arenas[arenaID]
	if !ok {
		return errBuscador("arena no existe")
	}
	_ = def // por futuro uso (nivel min, etc.)
	if b.enCola(j.id) {
		return errBuscador("ya estás en cola")
	}
	if j.instanciaID != "" {
		return errBuscador("ya estás en una instancia")
	}

	cola, ok := b.colaPvP[arenaID]
	if !ok {
		cola = make(map[string]*solicitudPvP)
		b.colaPvP[arenaID] = cola
	}
	cola[j.id] = &solicitudPvP{
		j:          j,
		arenaID:    arenaID,
		faccion:    j.faccion,
		encoladoMs: time.Now().UnixMilli(),
	}
	b.enviarEstadoColaPvP(j, arenaID)
	return nil
}

// SalirColaPvP saca a un jugador de la cola PvP.
func (b *Buscador) SalirColaPvP(j *Jugador) {
	b.m.mu.Lock()
	defer b.m.mu.Unlock()
	for aid, cola := range b.colaPvP {
		if _, ok := cola[j.id]; ok {
			delete(cola, j.id)
			b.enviarEstadoSalida(j, aid, "arena")
			return
		}
	}
}

// Cancelar elimina al jugador de cualquier cola (al desconectarse).
// NO adquiere el lock: el llamador (normalmente QuitarJugador) debe
// tener m.mu tomado.
func (b *Buscador) Cancelar(j *Jugador) {
	for _, cola := range b.colaPvE {
		delete(cola, j.id)
	}
	for _, cola := range b.colaPvP {
		delete(cola, j.id)
	}
}

// ─── Procesamiento por tick (llamado bajo m.mu desde step) ───────────────

// procesar intenta formar grupos PvE y PvP con los jugadores encolados.
// Se llama una vez por segundo desde step().
func (b *Buscador) procesar(t time.Time) {
	ahora := t.UnixMilli()
	b.procesarPvE(ahora)
	b.procesarPvP(ahora)
	b.enviarEstadosCola(ahora)
}

// procesarPvE recorre las colas de masmorras e intenta formar grupos.
func (b *Buscador) procesarPvE(ahora int64) {
	for mid, cola := range b.colaPvE {
		def := b.m.masmoras[mid]
		if def.TamanoGrupo == 0 {
			continue
		}
		grupo := b.formarGrupoPvE(cola, def.TamanoGrupo, ahora)
		if len(grupo) < def.TamanoGrupo {
			continue
		}
		// Grupo completo: crear instancia y mover jugadores.
		for _, s := range grupo {
			delete(cola, s.j.id)
		}
		inst := nuevaInstanciaMasmora(&def, solicitudesAJugadores(grupo), ahora)
		inst.iniciar(b.m)
	}
}

// formarGrupoPvE intenta cubrir la trinidad (1 tanque + 1 soporte + 1 dps).
// Si no se cubre y algún jugador lleva más de TiempoRelajacionColaMs en cola,
// relaja a "cualquier N jugadores".
func (b *Buscador) formarGrupoPvE(cola map[string]*solicitudPvE, tamano int, ahora int64) []*solicitudPvE {
	var tanques, soportes, dps []*solicitudPvE
	for _, s := range cola {
		switch s.rol {
		case RolTanque:
			tanques = append(tanques, s)
		case RolSoporte:
			soportes = append(soportes, s)
		default:
			dps = append(dps, s)
		}
	}

	// Fase estricta: 1 tanque + 1 soporte + (tamano-2) dps.
	if tamano >= 3 && len(tanques) >= 1 && len(soportes) >= 1 && len(dps) >= tamano-2 {
		out := []*solicitudPvE{tanques[0], soportes[0]}
		out = append(out, dps[:tamano-2]...)
		return out
	}

	// Fase relajada: si alguien lleva >TiempoRelajacionColaMs, tomar
	// cualquier tamano jugadores sin importar roles.
	relajar := false
	for _, s := range cola {
		if (ahora - s.encoladoMs) >= TiempoRelajacionColaMs {
			relajar = true
			break
		}
	}
	if !relajar {
		return nil
	}
	if len(cola) < tamano {
		return nil
	}
	// Tomar los tamano que más tiempo llevan en cola.
	todos := make([]*solicitudPvE, 0, len(cola))
	for _, s := range cola {
		todos = append(todos, s)
	}
	// Ordenar por encoladoMs ascendente (más antiguo primero).
	ordenarPorEncolado(todos)
	return todos[:tamano]
}

// procesarPvP recorre las colas de arenas e intenta formar partidos.
func (b *Buscador) procesarPvP(ahora int64) {
	for aid, cola := range b.colaPvP {
		def := b.m.arenas[aid]
		necesarios := def.TamanoEquipo * 2
		if len(cola) < necesarios {
			continue
		}
		// Tomar los necesarios que más tiempo llevan en cola.
		todos := make([]*solicitudPvP, 0, len(cola))
		for _, s := range cola {
			todos = append(todos, s)
		}
		ordenarPorEncoladoPvP(todos)
		elegidos := todos[:necesarios]
		for _, s := range elegidos {
			delete(cola, s.j.id)
		}
		// Asignar equipos cross-faction: simplemente partir a la mitad.
		// No se respeta facción para el equipo: cualquier mezcla vale.
		grupo := make([]*Jugador, 0, necesarios)
		equipos := make(map[string]int, necesarios)
		for i, s := range elegidos {
			grupo = append(grupo, s.j)
			if i < def.TamanoEquipo {
				equipos[s.j.id] = 0
			} else {
				equipos[s.j.id] = 1
			}
		}
		inst := nuevaInstanciaArena(&def, grupo, equipos, ahora)
		inst.iniciar(b.m)
	}
}

// ─── Helpers de estado ───────────────────────────────────────────────────

// enCola devuelve true si el jugador está en alguna cola (PvE o PvP).
// Debe llamarse con m.mu tomado.
func (b *Buscador) enCola(pjID string) bool {
	for _, cola := range b.colaPvE {
		if _, ok := cola[pjID]; ok {
			return true
		}
	}
	for _, cola := range b.colaPvP {
		if _, ok := cola[pjID]; ok {
			return true
		}
	}
	return false
}

// enviarEstadosCola envía un mensaje de estado a cada jugador en cola,
// con su tiempo de espera y cuántos están en su misma cola.
func (b *Buscador) enviarEstadosCola(ahora int64) {
	for mid, cola := range b.colaPvE {
		n := len(cola)
		for _, s := range cola {
			s.j.enviarNoBloqueante(proto.MensajeServidor{
				Tipo:            "cola_estado",
				EnCola:          true,
				MasmoraID:       "", // se infiere del mensaje
				TiempoColaMs:    int(ahora - s.encoladoMs),
				JugadoresEnCola: n,
				Mensaje:         mid,
			})
		}
	}
	for aid, cola := range b.colaPvP {
		n := len(cola)
		for _, s := range cola {
			s.j.enviarNoBloqueante(proto.MensajeServidor{
				Tipo:            "cola_estado",
				EnCola:          true,
				TiempoColaMs:    int(ahora - s.encoladoMs),
				JugadoresEnCola: n,
				Mensaje:         aid,
			})
		}
	}
}

// enviarEstadoColaPvE envía un mensaje inmediato de "encolado" a un jugador.
func (b *Buscador) enviarEstadoColaPvE(j *Jugador, masmoraID string) {
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:            "cola_estado",
		EnCola:          true,
		MasmoraID:       masmoraID,
		JugadoresEnCola: len(b.colaPvE[masmoraID]),
		Mensaje:         "encolado_pve",
	})
}

// enviarEstadoColaPvP envía un mensaje inmediato de "encolado" a un jugador.
func (b *Buscador) enviarEstadoColaPvP(j *Jugador, arenaID string) {
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:            "cola_estado",
		EnCola:          true,
		ArenaID:         arenaID,
		JugadoresEnCola: len(b.colaPvP[arenaID]),
		Mensaje:         "encolado_pvp",
	})
}

// enviarEstadoSalida confirma al jugador que salió de la cola.
func (b *Buscador) enviarEstadoSalida(j *Jugador, destID, tipoZona string) {
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:    "cola_estado",
		EnCola:  false,
		Mensaje: "salida_cola_" + tipoZona,
	})
}

// ─── Utilidades ──────────────────────────────────────────────────────────

// solicitudesAJugadores extrae los *Jugador de una lista de solicitudes PvE.
func solicitudesAJugadores(ss []*solicitudPvE) []*Jugador {
	out := make([]*Jugador, 0, len(ss))
	for _, s := range ss {
		out = append(out, s.j)
	}
	return out
}

// ordenarPorEncolado ordena solicitudes PvE por encoladoMs ascendente
// (las más antiguas primero). Insertion sort: las listas son pequeñas.
func ordenarPorEncolado(ss []*solicitudPvE) {
	for i := 1; i < len(ss); i++ {
		for k := i; k > 0 && ss[k-1].encoladoMs > ss[k].encoladoMs; k-- {
			ss[k-1], ss[k] = ss[k], ss[k-1]
		}
	}
}

// ordenarPorEncoladoPvP idem para PvP.
func ordenarPorEncoladoPvP(ss []*solicitudPvP) {
	for i := 1; i < len(ss); i++ {
		for k := i; k > 0 && ss[k-1].encoladoMs > ss[k].encoladoMs; k-- {
			ss[k-1], ss[k] = ss[k], ss[k-1]
		}
	}
}

// errBuscador devuelve un error tipado simple. Evita importar errors.
type errBuscadorTipo string

func (e errBuscadorTipo) Error() string { return string(e) }

func errBuscador(msg string) error { return errBuscadorTipo(msg) }
