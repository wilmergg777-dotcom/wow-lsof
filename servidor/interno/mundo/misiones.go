// misiones.go implementa el sistema de experiencia, subida de nivel y
// misiones de WoW 3.3.5a: la curva de XP 1→80, el crédito de muerte (XP +
// progreso de misiones al matar mobs), las misiones con objetivos (matar /
// hablar) y recompensas (XP, oro, items), y la aceptación/entrega de
// misiones vía NPCs misioneros.
//
// Concurrencia: Mundo.step mantiene m.mu.Lock() durante TODO el tick, así
// que el crédito de muerte (llamado desde Enemigo.morir dentro del tick) NO
// toma ningún lock: accede directo a los campos del jugador (el tick ya
// tiene m.mu). Las acciones de red (AceptarMision/EntregarMision/InteractuarNPC)
// toman m.mu.Lock/RLock una sola vez y acceden directo a los maps (NO via
// accessores Mision()/NPC() que re-lockearían y harían deadlock). Go no tiene
// mutex reentrante.
package mundo

import (
	"errors"
)

// ─── Curva de XP 1→80 ────────────────────────────────────────────────────

// NivelMax es el nivel máximo alcanzable (tope de Rasganorte, WoW 3.3.5a).
const NivelMax = 80

// MargenMobGris: un mob ≥ esta cantidad de niveles por debajo del jugador no
// otorga XP (mob "gris").
const MargenMobGris = 7

// xpParaNivel devuelve el XP necesario para avanzar DESDE el nivel n al n+1.
// Curva cuadrática: 50·n². Nivel 1→2 = 50, 10→11 = 5000, 40→41 = 80000,
// 79→80 = 312050. Total 1→80 ≈ 8,37M XP. Las misiones dan recompensas
// escaladas (~30% del nivel objetivo) para que el leveo sea viable.
func xpParaNivel(n int) int {
	if n < 1 {
		return 0
	}
	return 50 * n * n
}

// xpPorMob devuelve el XP que otorga matar un mob de nivelMob siendo el
// jugador de nivelJugador. 0 si el mob es gris (≥MargenMobGris por debajo).
// Pequeña bonificación si el mob supera al jugador.
func xpPorMob(nivelMob, nivelJugador int) int {
	if nivelMob <= nivelJugador-MargenMobGris {
		return 0 // mob gris
	}
	base := 8 + nivelMob*3
	if nivelMob > nivelJugador {
		base += (nivelMob - nivelJugador) * 2
	}
	return base
}

// xpRecompensa devuelve el XP de recompensa para una misión de nivelObjetivo:
// ~30% del XP necesario para subir ese nivel.
func xpRecompensa(nivelObjetivo int) int {
	return xpParaNivel(nivelObjetivo) * 3 / 10
}

// ─── Misiones: definiciones ──────────────────────────────────────────────

// DefObjetivoMision describe un objetivo de misión.
type DefObjetivoMision struct {
	Tipo        string `json:"tipo"` // "matar" | "hablar"
	Descripcion string `json:"descripcion"`
	MobFamilia  string `json:"mob_familia,omitempty"` // para "matar"
	Cantidad    int    `json:"cantidad,omitempty"`    // para "matar"
	NPCDestino  string `json:"npc_destino,omitempty"` // para "hablar"
}

// DefMision describe una misión del mundo.
type DefMision struct {
	ID              string              `json:"id"`
	Nombre          string              `json:"nombre"`
	Descripcion     string              `json:"descripcion"`
	NivelMin        int                 `json:"nivel_min"`
	ZonaID          string              `json:"zona_id"`
	NPCInicial      string              `json:"npc_inicial"` // quest giver
	NPCEntrega      string              `json:"npc_entrega"`
	Objetivos       []DefObjetivoMision `json:"objetivos"`
	XPRecompensa    int                 `json:"xp_recompensa"`
	OroRecompensa   int                 `json:"oro_recompensa"`
	ItemsRecompensa []string            `json:"items_recompensa,omitempty"`
	RequiereMision  string              `json:"requiere_mision,omitempty"`
}

// EstadoMision es el estado de una misión activa para un jugador.
type EstadoMision struct {
	MisionID   string         `json:"mision_id"`
	Progreso   map[string]int `json:"progreso"`   // clave: obj_<i> → contador
	Completada bool           `json:"completada"` // listo para entregar
}

// ─── XP y subida de nivel (Jugador) ──────────────────────────────────────
// Sin locks: el caller (tick con m.mu, o EntregarMision con m.mu.Lock) ya
// protege el acceso. ganarXP/subirNivel leen m.razas (catálogo inmutable).

// ganarXP añade XP al jugador y sube de nivel cuantas veces corresponda.
func (j *Jugador) ganarXP(cantidad int, m *Mundo) {
	if cantidad <= 0 || j.nivel >= NivelMax {
		return
	}
	j.xp += cantidad
	for j.nivel < NivelMax && j.xp >= xpParaNivel(j.nivel) {
		j.xp -= xpParaNivel(j.nivel)
		j.subirNivel(m)
	}
	if j.nivel >= NivelMax {
		j.xp = 0
	}
}

// subirNivel incrementa el nivel (hasta NivelMax) y recalcula HP/energía
// máximos con la fórmula de la clase más el racial pasivo, curando al
// completo. El código base no recalculaba stats al subir; este lo añade.
func (j *Jugador) subirNivel(m *Mundo) {
	if j.nivel >= NivelMax {
		return
	}
	j.nivel++
	def := j.claseDef
	hpMax := def.HPBase + def.HPPorNivel*(j.nivel-1)
	energiaMax := def.EnergiaBase + def.EnergiaPorNivel*(j.nivel-1)
	if razaDef, ok := m.razas[j.raza]; ok {
		hpMax = int(float64(hpMax) * (1 + razaDef.ModHP))
		energiaMax = int(float64(energiaMax) * (1 + razaDef.ModMana))
	}
	j.hpMax = hpMax
	j.energiaMax = energiaMax
	j.hpActual = hpMax
	j.energiaActual = energiaMax
}

// XP devuelve la experiencia actual del jugador.
func (j *Jugador) XP() int { return j.xp }

// XPParaSiguienteNivel devuelve el XP necesario para el siguiente nivel.
func (j *Jugador) XPParaSiguienteNivel() int { return xpParaNivel(j.nivel) }

// Oro devuelve el oro del jugador.
func (j *Jugador) Oro() int { return j.oro }

// ─── Accesores de catálogo (Mundo, lock propio para uso externo) ─────────

// Misiones devuelve el catálogo completo de misiones.
func (m *Mundo) Misiones() map[string]DefMision {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefMision, len(m.misiones))
	for k, v := range m.misiones {
		out[k] = v
	}
	return out
}

// Mision devuelve una misión por ID.
func (m *Mundo) Mision(id string) (DefMision, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	mi, ok := m.misiones[id]
	return mi, ok
}

// MisionesOfrecidasPorNPC devuelve todas las misiones que ofrece un NPC
// misionero (sin filtrar por jugador).
func (m *Mundo) MisionesOfrecidasPorNPC(npcID string) []DefMision {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.misionesOfrecidas(npcID)
}

// misionesOfrecidas es el lookup sin lock (el caller tiene m.mu).
func (m *Mundo) misionesOfrecidas(npcID string) []DefMision {
	npc, ok := m.npcPorID(npcID)
	if !ok {
		return nil
	}
	out := make([]DefMision, 0, len(npc.Misiones))
	for _, mid := range npc.Misiones {
		if mi, ok := m.misiones[mid]; ok {
			out = append(out, mi)
		}
	}
	return out
}

// MisionesDisponiblesNPC devuelve las misiones que el jugador puede aceptar
// de un NPC: ofrece el NPC, nivel suficiente, prerequisito de cadena
// cumplido, y no activa ni ya completada.
func (m *Mundo) MisionesDisponiblesNPC(jugadorID, npcID string) []DefMision {
	m.mu.RLock()
	defer m.mu.RUnlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return nil
	}
	ofertas := m.misionesOfrecidas(npcID)
	out := make([]DefMision, 0, len(ofertas))
	for _, mi := range ofertas {
		if j.nivel < mi.NivelMin {
			continue
		}
		if mi.RequiereMision != "" && !j.misionesCompletadas[mi.RequiereMision] {
			continue
		}
		if j.misionesActivas[mi.ID] != nil || j.misionesCompletadas[mi.ID] {
			continue
		}
		out = append(out, mi)
	}
	return out
}

// ─── Aceptar / Entregar misiones (camino de red: m.mu.Lock) ──────────────

// AceptarMision valida que el jugador esté junto al NPC inicial de la
// misión, cumpla el prerrequisito de nivel/cadena, y no la tenga ya activa
// o completada; la añade a misionesActivas con progreso cero.
func (m *Mundo) AceptarMision(jugadorID, misionID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return errors.New("jugador no encontrado")
	}
	mi, ok := m.misiones[misionID]
	if !ok {
		return errors.New("misión inexistente")
	}
	npcIni, ok := m.npcPorID(mi.NPCInicial)
	if !ok {
		return errors.New("NPC inicial de misión inexistente")
	}
	if distancia2D(j.pos, npcIni.Pos) > RangoInteraccionNPC {
		return errors.New("estás demasiado lejos del NPC que da la misión")
	}
	if j.nivel < mi.NivelMin {
		return errors.New("nivel insuficiente para esta misión")
	}
	if mi.RequiereMision != "" && !j.misionesCompletadas[mi.RequiereMision] {
		return errors.New("debes completar primero la misión previa de la cadena")
	}
	if j.misionesActivas[misionID] != nil {
		return errors.New("ya tienes esta misión activa")
	}
	if j.misionesCompletadas[misionID] {
		return errors.New("ya completaste esta misión")
	}
	est := &EstadoMision{MisionID: misionID, Progreso: map[string]int{}}
	for i := range mi.Objetivos {
		if mi.Objetivos[i].Tipo == "matar" {
			est.Progreso[objClave(i)] = 0
		}
	}
	j.misionesActivas[misionID] = est
	return nil
}

// EntregarMision valida que todos los objetivos estén completos y el
// jugador esté junto al NPC de entrega; otorga recompensas (XP, oro, items)
// y mueve la misión a completadas. Mantiene m.mu.Lock durante todo
// (ganarXP/subirNivel no toman locks internos).
func (m *Mundo) EntregarMision(jugadorID, misionID string) (DefMision, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return DefMision{}, errors.New("jugador no encontrado")
	}
	mi, ok := m.misiones[misionID]
	if !ok {
		return DefMision{}, errors.New("misión inexistente")
	}
	npcEnt, ok := m.npcPorID(mi.NPCEntrega)
	if !ok {
		return DefMision{}, errors.New("NPC de entrega inexistente")
	}
	if distancia2D(j.pos, npcEnt.Pos) > RangoInteraccionNPC {
		return DefMision{}, errors.New("estás demasiado lejos del NPC de entrega")
	}
	est, activa := j.misionesActivas[misionID]
	if !activa {
		return DefMision{}, errors.New("no tienes esta misión activa")
	}
	if !est.Completada {
		return DefMision{}, errors.New("la misión no está completa")
	}
	// Otorgar recompensas (ganarXP/subirNivel acceden a m.razas, sin locks).
	j.ganarXP(mi.XPRecompensa, m)
	j.oro += mi.OroRecompensa
	for _, itemID := range mi.ItemsRecompensa {
		j.inventario[itemID]++
	}
	delete(j.misionesActivas, misionID)
	j.misionesCompletadas[misionID] = true
	return mi, nil
}

// MisionesActivasJugador devuelve el estado de las misiones activas.
func (m *Mundo) MisionesActivasJugador(jugadorID string) []EstadoMision {
	m.mu.RLock()
	defer m.mu.RUnlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return nil
	}
	out := make([]EstadoMision, 0, len(j.misionesActivas))
	for _, est := range j.misionesActivas {
		out = append(out, *est)
	}
	return out
}

// MisionesCompletadasJugador devuelve los IDs de misiones completadas.
func (m *Mundo) MisionesCompletadasJugador(jugadorID string) []string {
	m.mu.RLock()
	defer m.mu.RUnlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return nil
	}
	out := make([]string, 0, len(j.misionesCompletadas))
	for id := range j.misionesCompletadas {
		out = append(out, id)
	}
	return out
}

// ─── Progreso de objetivos (camino del tick: SIN lock, m.mu ya tomada) ───

// objClave es la clave de progreso para el objetivo de índice i.
func objClave(i int) string {
	return "obj_" + itoaSimple(i)
}

// progresoMisionPorKill incrementa el progreso de los objetivos "matar"
// cuya familia coincide con la del mob muerto, y marca Completada si todos
// los objetivos lo están. Llamado desde el crédito de muerte (tick).
func (m *Mundo) progresoMisionPorKill(j *Jugador, familiaMob string) {
	for mid, est := range j.misionesActivas {
		mi, ok := m.misiones[mid]
		if !ok {
			continue
		}
		cambio := false
		for i, obj := range mi.Objetivos {
			if obj.Tipo != "matar" || obj.MobFamilia != familiaMob {
				continue
			}
			clave := objClave(i)
			if est.Progreso[clave] < obj.Cantidad {
				est.Progreso[clave]++
				cambio = true
			}
		}
		if cambio {
			est.Completada = misionObjetivosCompletos(mi, est)
		}
	}
}

// progresoHablar marca completado el objetivo "hablar" cuyo NPCDestino
// coincide, y recalcula Completada. Llamado desde InteractuarNPC (red).
// El caller ya tiene m.mu.Lock.
func (m *Mundo) progresoHablar(j *Jugador, npcID string) {
	for mid, est := range j.misionesActivas {
		mi, ok := m.misiones[mid]
		if !ok {
			continue
		}
		cambio := false
		for i, obj := range mi.Objetivos {
			if obj.Tipo == "hablar" && obj.NPCDestino == npcID {
				clave := objClave(i)
				if est.Progreso[clave] < 1 {
					est.Progreso[clave] = 1
					cambio = true
				}
			}
		}
		if cambio {
			est.Completada = misionObjetivosCompletos(mi, est)
		}
	}
}

// misionObjetivosCompletos devuelve true si todos los objetivos están cumplidos.
func misionObjetivosCompletos(mi DefMision, est *EstadoMision) bool {
	for i, obj := range mi.Objetivos {
		switch obj.Tipo {
		case "matar":
			if est.Progreso[objClave(i)] < obj.Cantidad {
				return false
			}
		case "hablar":
			if est.Progreso[objClave(i)] < 1 {
				return false
			}
		}
	}
	return true
}

// ─── Crédito de muerte (hook desde Enemigo.morir, dentro del tick) ───────
// SIN locks: step ya tiene m.mu.Lock. Acceso directo a j y m.misiones.

// otorgarXPMuerte otorga XP al último atacante (si es jugador) y progresa
// sus misiones de "matar". Llamado desde Enemigo.morir.
func (m *Mundo) otorgarXPMuerte(jugadorID string, nivelMob int, familiaMob string) {
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return
	}
	xp := xpPorMob(nivelMob, j.nivel)
	if xp > 0 {
		j.ganarXP(xp, m)
	}
	m.progresoMisionPorKill(j, familiaMob)
}

// npcPorID busca un NPC por ID en todas las capitales y zonas. Sin lock:
// los catálogos son inmutables tras la construcción; el caller tiene m.mu.
func (m *Mundo) npcPorID(npcID string) (DefNPC, bool) {
	for _, c := range m.ciudades {
		for _, n := range c.NPCs {
			if n.ID == npcID {
				return n, true
			}
		}
	}
	for _, z := range m.zonas {
		for _, n := range z.NPCs {
			if n.ID == npcID {
				return n, true
			}
		}
	}
	return DefNPC{}, false
}
