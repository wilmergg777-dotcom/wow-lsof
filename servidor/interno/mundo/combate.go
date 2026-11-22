// combate.go contiene la resolución de habilidades y el broadcast
// de eventos a jugadores cercanos.
package mundo

import (
	"log"

	"aethelgard/servidor/interno/proto"
)

// usarHabilidad valida y ejecuta una habilidad del jugador j.
// origen es el ms actual.
//
// Pasos:
//   1. Validar que la habilidad exista en la clase del jugador.
//   2. Validar cooldown.
//   3. Validar energía suficiente.
//   4. Validar objetivo (existe, vivo, atacable).
//   5. Validar rango.
//   6. Aplicar efecto según tipo.
//   7. Setear cooldown y restar energía.
//   8. Broadcast de evento de daño/curación si aplica.
func usarHabilidad(m *Mundo, j *Jugador, habID, objetivoID string, ahora int64) {
	def, ok := buscarHabilidad(j.claseDef, habID)
	if !ok {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "habilidad desconocida"})
		return
	}

	// Cooldown.
	if fin, ok := j.cooldowns[def.ID]; ok && fin > ahora {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "en cooldown"})
		return
	}

	// Energía.
	if j.energiaActual < def.CostoEnergia {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "energía insuficiente"})
		return
	}

	// Resolución por tipo.
	switch def.Tipo {
	case "buff":
		aplicarBuff(m, j, def, ahora)
	case "dano":
		aplicarDañoHabilidad(m, j, def, objetivoID, ahora)
	case "curacion":
		aplicarCuracion(m, j, def, objetivoID, ahora)
	case "carga":
		aplicarCarga(m, j, def, objetivoID, ahora)
	default:
		log.Printf("[combate] tipo de habilidad no soportado: %s", def.Tipo)
		return
	}

	// Costo y cooldown se aplican siempre que la habilidad se haya ejecutado.
	j.energiaActual -= def.CostoEnergia
	j.cooldowns[def.ID] = ahora + int64(def.CooldownMs)
}

// aplicarBuff aplica un buff al propio jugador.
func aplicarBuff(m *Mundo, j *Jugador, def DefHabilidad, ahora int64) {
	if def.IDBuff == "" {
		return
	}
	j.buffs[def.IDBuff] = ahora + int64(def.DuracionBuffMs)
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:       "buff",
		OrigenID:   j.id,
		ObjetivoID: j.id,
		Mensaje:    def.IDBuff,
	})
}

// aplicarDañoHabilidad valida objetivo, rango y aplica daño.
// Daño a mobs: siempre que estén en la misma zona que el caster.
// Daño a jugadores: solo en arena PvP, al equipo contrario.
func aplicarDañoHabilidad(m *Mundo, j *Jugador, def DefHabilidad, objetivoID string, ahora int64) {
	obj, ok := m.entidadPorID(objetivoID)
	if !ok || !obj.EstaVivo() {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "objetivo inválido"})
		delete(j.cooldowns, def.ID)
		j.energiaActual += def.CostoEnergia
		return
	}
	// Filtro de zona.
	if instanciaDe(obj) != j.instanciaID {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "objetivo en otra zona"})
		delete(j.cooldowns, def.ID)
		j.energiaActual += def.CostoEnergia
		return
	}
	if obj.EsJugador() {
		// PvP: solo si es enemigo (misma arena, equipo opuesto).
		otro, ok := obj.(*Jugador)
		if !ok || !j.esEnemigoDe(otro) {
			j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "no puedes dañar a ese jugador"})
			delete(j.cooldowns, def.ID)
			j.energiaActual += def.CostoEnergia
			return
		}
	}
	d := distancia2D(j.pos, obj.Pos())
	if d > def.RangoMetros {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "fuera de rango"})
		delete(j.cooldowns, def.ID)
		j.energiaActual += def.CostoEnergia
		return
	}
	dano := j.calcularDaño(def.DañoBase)
	critico := randFloatEntre(0, 1) > 0.85 // 15% crit
	if critico {
		dano = dano * 2
	}
	if e, ok := obj.(*Enemigo); ok {
		e.recibirDaño(j.id, dano, critico, m, ahora)
	} else if otro, ok := obj.(*Jugador); ok {
		otro.recibirDaño(j.id, dano, critico, m, ahora)
	}
	j.ultimoDanoMs = ahora
	j.enCombate = true
}

// aplicarCuracion restaura HP al objetivo. Si objetivoID está vacío o es
// el propio caster, se cura a sí mismo. Si apunta a otro jugador, debe
// ser aliado (misma instancia y mismo equipo, o ambos en masmora PvE)
// y estar dentro de rango. No se puede curar a mobs.
func aplicarCuracion(m *Mundo, j *Jugador, def DefHabilidad, objetivoID string, ahora int64) {
	objetivo := j // por defecto, self
	if objetivoID != "" && objetivoID != j.id {
		obj, ok := m.entidadPorID(objetivoID)
		if !ok || !obj.EstaVivo() {
			j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "objetivo inválido"})
			delete(j.cooldowns, def.ID)
			j.energiaActual += def.CostoEnergia
			return
		}
		otro, ok := obj.(*Jugador)
		if !ok {
			j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "no puedes curar a un mob"})
			delete(j.cooldowns, def.ID)
			j.energiaActual += def.CostoEnergia
			return
		}
		if !j.esAliadoDe(otro) {
			j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "objetivo no es aliado"})
			delete(j.cooldowns, def.ID)
			j.energiaActual += def.CostoEnergia
			return
		}
		if distancia2D(j.pos, otro.pos) > def.RangoMetros {
			j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "fuera de rango"})
			delete(j.cooldowns, def.ID)
			j.energiaActual += def.CostoEnergia
			return
		}
		objetivo = otro
	}
	antes := objetivo.hpActual
	objetivo.hpActual += def.DañoBase
	if objetivo.hpActual > objetivo.hpMax {
		objetivo.hpActual = objetivo.hpMax
	}
	curado := objetivo.hpActual - antes
	// Notificar al objetivo (si es otro) y al caster.
	objetivo.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:       "curacion",
		OrigenID:   j.id,
		ObjetivoID: objetivo.id,
		Cantidad:   curado,
	})
	if objetivo != j {
		j.enviarNoBloqueante(proto.MensajeServidor{
			Tipo:       "curacion",
			OrigenID:   j.id,
			ObjetivoID: objetivo.id,
			Cantidad:   curado,
		})
	}
	// Broadcast a la zona del evento de curación.
	m.broadcastCercanoZona(proto.MensajeServidor{
		Tipo:       "curacion",
		OrigenID:   j.id,
		ObjetivoID: objetivo.id,
		Cantidad:   curado,
	}, j.pos, j.instanciaID)
	_ = ahora
}

// aplicarCarga teletransporta al jugador junto al objetivo (MVP simplificado).
func aplicarCarga(m *Mundo, j *Jugador, def DefHabilidad, objetivoID string, ahora int64) {
	obj, ok := m.entidadPorID(objetivoID)
	if !ok || !obj.EstaVivo() {
		return
	}
	d := distancia2D(j.pos, obj.Pos())
	if d > def.RangoMetros*3 {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "fuera de rango"})
		delete(j.cooldowns, def.ID)
		j.energiaActual += def.CostoEnergia
		return
	}
	// Colocarse a 1.5m del objetivo.
	dir := proto.Vec3{X: j.pos.X - obj.Pos().X, Y: 0, Z: j.pos.Z - obj.Pos().Z}
	norm := sqrtF(dir.X*dir.X + dir.Z*dir.Z)
	if norm > 0.001 {
		dir.X /= norm
		dir.Z /= norm
	} else {
		dir = proto.Vec3{X: 0, Y: 0, Z: 1}
	}
	j.pos = proto.Vec3{
		X: obj.Pos().X + dir.X*1.5,
		Y: obj.Pos().Y,
		Z: obj.Pos().Z + dir.Z*1.5,
	}
}

// buscarHabilidad busca una habilidad por ID dentro de la definición de clase.
func buscarHabilidad(d DefClase, id string) (DefHabilidad, bool) {
	for _, h := range d.Habilidades {
		if h.ID == id {
			return h, true
		}
	}
	return DefHabilidad{}, false
}

// broadcastCercanoZona envía un mensaje a todos los jugadores cuyo personaje
// está dentro de RadioInteresMetros de pos Y en la misma zona (instanciaID).
// Debe llamarse con el lock tomado.
func (m *Mundo) broadcastCercanoZona(msg proto.MensajeServidor, pos proto.Vec3, instanciaID string) {
	for _, j := range m.jugadores {
		if j.instanciaID != instanciaID {
			continue
		}
		if distancia2D(j.pos, pos) <= RadioInteresMetros {
			j.enviarNoBloqueante(msg)
		}
	}
}
