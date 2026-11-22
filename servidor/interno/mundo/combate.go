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
		aplicarCuracion(m, j, def, ahora)
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
func aplicarDañoHabilidad(m *Mundo, j *Jugador, def DefHabilidad, objetivoID string, ahora int64) {
	obj, ok := m.entidadPorID(objetivoID)
	if !ok || !obj.EstaVivo() {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "objetivo inválido"})
		// Reembolsar: no cobramos cooldown ni energía.
		delete(j.cooldowns, def.ID)
		j.energiaActual += def.CostoEnergia
		return
	}
	// MVP: solo se puede dañar mobs.
	if obj.EsJugador() {
		j.enviarNoBloqueante(proto.MensajeServidor{Tipo: "error", Mensaje: "PvP no disponible en MVP"})
		delete(j.cooldowns, def.ID)
		j.energiaActual += def.CostoEnergia
		return
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
	}
	j.ultimoDanoMs = ahora
	j.enCombate = true
}

// aplicarCuracion restaura HP al propio jugador.
func aplicarCuracion(m *Mundo, j *Jugador, def DefHabilidad, ahora int64) {
	antes := j.hpActual
	j.hpActual += def.DañoBase // reusamos DañoBase como magnitud de curación
	if j.hpActual > j.hpMax {
		j.hpActual = j.hpMax
	}
	curado := j.hpActual - antes
	j.enviarNoBloqueante(proto.MensajeServidor{
		Tipo:       "curacion",
		OrigenID:   j.id,
		ObjetivoID: j.id,
		Cantidad:   curado,
	})
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

// broadcastCercano envía un mensaje a todos los jugadores cuyo personaje
// está dentro de RadioInteresMetros de pos. Debe llamarse con el lock tomado.
func (m *Mundo) broadcastCercano(msg proto.MensajeServidor, pos proto.Vec3) {
	for _, j := range m.jugadores {
		if distancia2D(j.pos, pos) <= RadioInteresMetros {
			j.enviarNoBloqueante(msg)
		}
	}
}
