// ia_mobs.go implementa la IA avanzada de los mobs (Fase 8):
//   - Patrulla por waypoints: los mobs con ruta predefinida la siguen en
//     bucle en lugar de moverse aleatoriamente.
//   - Agro social: al agroar (por proximidad o al recibir daño), los mobs
//     cercanos en patrulla le asisten (chain pull).
//   - Leash + evade: si un mob en combate se aleja demasiado de su
//     spawnPos, suelta el objetivo, se cura a full y vuelve al spawn.
//   - Huida en HP bajo: los mobs cobardes (bestias/humanoides no élite ni
//     boss) huyen al quedar con HP < 20%, pidiendo ayuda al hacerlo.
//   - Escalado de élites: HP x3 y daño x2 respecto a un mob normal.
package mundo

import (
	"aethelgard/servidor/interno/proto"
)

// ─── Agro social ──────────────────────────────────────────────────────

// agroSocial hace que los mobs cercanos (en patrulla, misma zona, dentro
// de RangoSocialAgroMetros de este mob) agroen al mismo objetivo. Modela
// el "chain pull" de WoW: al pullar un mob, sus vecinos le asisten.
// Solo afecta a mobs en estado "patrullando" (los ya en combate se ignoran
// para no re-asignarles objetivo).
func (e *Enemigo) agroSocial(m *Mundo, targetID string, ahora int64) {
	for _, otro := range m.enemigos {
		if otro == e || !otro.EstaVivo() {
			continue
		}
		if otro.instanciaID != e.instanciaID {
			continue
		}
		if otro.estado != "patrullando" {
			continue
		}
		if distancia2D(otro.pos, e.pos) <= RangoSocialAgroMetros {
			otro.objetivoID = targetID
			otro.estado = "persiguiendo"
			otro.enCombate = true
		}
	}
}

// ─── Leash + evade ────────────────────────────────────────────────────

// evadir hace que el mob suelte el objetivo, salga de combate, se cure a
// full y entre en estado "evade" para volver al spawn. Modela el leash de
// WoW: arrastrar un mob lejos de su spawn provoca un reset.
func (e *Enemigo) evadir(m *Mundo, ahora int64) {
	e.objetivoID = ""
	e.enCombate = false
	e.estado = "evade"
	e.hpActual = e.hpMax // evade cura a full (regla WoW)
	e.auras = nil        // limpia debuffs/DoT al resetear
}

// aiEvade mueve al mob hacia su spawnPos; al llegar vuelve a patrullar.
func (e *Enemigo) aiEvade(m *Mundo, ahora int64) {
	if distancia2D(e.pos, e.spawnPos) < 1.0 {
		e.estado = "patrullando"
		return
	}
	e.moverHacia(e.spawnPos, VelocidadEnemigoMps)
}

// ─── Huida en HP bajo ─────────────────────────────────────────────────

// iniciarHuida pone al mob en estado "huyendo" y pide ayuda (agro social).
// Los mobs cobardes huyen al quedar con HP < 20%.
func (e *Enemigo) iniciarHuida(m *Mundo, ahora int64) {
	e.estado = "huyendo"
	e.huyeHastaMs = ahora + FleeDuracionMs
	e.agroSocial(m, e.objetivoID, ahora) // pide ayuda al huir
}

// aiHuir aleja al mob de su objetivo a velocidad de huida. Tras
// FleeDuracionMs o si el objetivo desaparece, suelta y evade al spawn.
func (e *Enemigo) aiHuir(m *Mundo, ahora int64) {
	if ahora >= e.huyeHastaMs || e.objetivoID == "" {
		e.evadir(m, ahora)
		return
	}
	obj, ok := m.entidadPorID(e.objetivoID)
	if !ok || !obj.EstaVivo() {
		e.evadir(m, ahora)
		return
	}
	// Dirección ALEJÁNDOSE del objetivo, a 1.2x velocidad de persecución.
	away := proto.Vec3{X: e.pos.X - obj.Pos().X, Y: 0, Z: e.pos.Z - obj.Pos().Z}
	norm := sqrtF(away.X*away.X + away.Z*away.Z)
	if norm > 0.001 {
		away.X /= norm
		away.Z /= norm
	}
	desplazamiento := (VelocidadEnemigoMps * 1.2) / float64(HzPredeterminado)
	e.pos = proto.Vec3{
		X: e.pos.X + away.X*desplazamiento,
		Y: e.pos.Y,
		Z: e.pos.Z + away.Z*desplazamiento,
	}
	e.rot = rotHaciaDireccion(away)
}

// ─── Patrulla por waypoints ───────────────────────────────────────────

// patrolWaypoint mueve al mob hacia el waypoint actual; al llegar avanza
// al siguiente (en bucle) y pausa PausaWaypointMs. Los waypoints son
// posiciones absolutas (como Pos en DefSpawnMob/DefSpawnZona).
func (e *Enemigo) patrolWaypoint(ahora int64) {
	if len(e.waypoints) == 0 {
		return
	}
	if e.waypointPausaHastaMs > ahora {
		return // esperando en el waypoint
	}
	wp := e.waypoints[e.waypointIdx]
	if distancia2D(e.pos, wp) < 0.8 {
		e.waypointIdx = (e.waypointIdx + 1) % len(e.waypoints)
		e.waypointPausaHastaMs = ahora + PausaWaypointMs
		return
	}
	e.moverHacia(wp, 2.0) // 2 m/s, como la patrulla aleatoria
}

// moverHacia desplaza al mob hacia `dest` a `mps` m/s (un tick) y rota
// hacia la dirección de movimiento. Helper compartido por evade/persec.
func (e *Enemigo) moverHacia(dest proto.Vec3, mps float64) {
	dir := proto.Vec3{X: dest.X - e.pos.X, Y: 0, Z: dest.Z - e.pos.Z}
	norm := sqrtF(dir.X*dir.X + dir.Z*dir.Z)
	if norm <= 0.001 {
		return
	}
	dir.X /= norm
	dir.Z /= norm
	desplazamiento := mps / float64(HzPredeterminado)
	e.pos = proto.Vec3{
		X: e.pos.X + dir.X*desplazamiento,
		Y: e.pos.Y,
		Z: e.pos.Z + dir.Z*desplazamiento,
	}
	e.rot = rotHaciaDireccion(dir)
}

// ─── Escalado de élites ───────────────────────────────────────────────

// aplicarEscaladoElite escala HP (x3) y daño (x2) de un mob élite, y marca
// esElite. Llamado por los constructores cuando el spawn lo indica.
func (e *Enemigo) aplicarEscaladoElite() {
	if !e.esElite {
		return
	}
	e.hpMax *= MultiplicadorEliteHP
	e.hpActual = e.hpMax
	if e.danoBase > 0 {
		e.danoBase *= MultiplicadorEliteDano
	}
}

// ─── Familias cobardes (huyen a HP bajo) ──────────────────────────────

// familiaEsCobarde indica si un mob de esta familia/tipo huye al quedar
// con HP bajo. Bestias y humanoides sí; no-muertos, elementales,
// dragones y mecánicos no (son implacables). Acepta tanto la categoría
// de DefSpawnMob.Tipo ("beast","humanoid",...) como etiquetas cosméticas
// de DefSpawnZona.Familia ("lobo","jabali",...).
func familiaEsCobarde(familia string) bool {
	switch familia {
	case "beast", "humanoid", "lobo", "jabali", "murloc", "oso", "venado",
		"talbuk", "rinoceronte", "mamut", "sable":
		return true
	}
	return false
}
