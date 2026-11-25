// auras.go integra el sistema de auras (paquete interno/auras) con el
// mundo: aplicación/stacking, ticking periódico (Hot/DoT), expiración,
// modificación de stats, limpieza al morir, persistencia y exposición al
// cliente. También implementa UsarItem, que consume un ítem consumible
// (pociones, frascos, elixires, comida, pergaminos, bebida) y aplica su
// efecto, respetando las reglas de WoW 3.3.5:
//   - Pociones: efecto instantáneo + cooldown compartido de 60 s (1 por
//     combate; fuera de combate el CD corre normal).
//   - Frascos: 1 h, sobreviven a la muerte, slot único (reemplaza frasco).
//   - Elixires: 1 h, 2 slots (batalla + guardián); reemplaza el del mismo slot.
//   - Comida: 1 h "bien alimentado", NO se puede comer en combate.
//   - Pergaminos: 1 h, 1 por atributo (reemplaza el del mismo atributo).
//   - Bebida: restaura maná, NO se puede beber en combate.
package mundo

import (
	"errors"
	"time"

	"aethelgard/servidor/interno/auras"
	"aethelgard/servidor/interno/persistencia"
	"aethelgard/servidor/interno/proto"
)

// CooldownPocionMs es el cooldown compartido de pociones (60 s en WoW).
const CooldownPocionMs int64 = 60_000

// ResultadoUsoItem describe el efecto de usar un consumible.
type ResultadoUsoItem struct {
	ItemID        string         `json:"item_id"`
	Curado        int            `json:"curado,omitempty"`         // HP curado (pociones)
	Restaurado    int            `json:"restaurado,omitempty"`     // maná restaurado (pociones/bebida)
	AuraAplicada  string         `json:"aura_aplicada,omitempty"`  // aura ID aplicada (frasco/elixir/comida/pergamino)
	AurasActivas  []proto.AuraRes `json:"auras_activas,omitempty"` // snapshot de auras tras el uso
}

// ─── Helpers de catálogo ──────────────────────────────────────────────

// defAura obtiene una DefAura del catálogo por ID (ok=false si no existe).
func defAura(id string) (auras.DefAura, bool) {
	d, ok := auras.CatalogoAuras()[id]
	return d, ok
}

// quitarAurasCategoria devuelve el slice sin las auras de la categoría dada.
// Reutiliza el array subyacente (filtro in-place, solo lectura de lo ya leído).
func quitarAurasCategoria(as []*auras.AuraActiva, cat auras.CategoriaStack) []*auras.AuraActiva {
	kept := as[:0]
	for _, a := range as {
		if d, ok := defAura(a.DefID); ok && d.Categoria == cat {
			continue
		}
		kept = append(kept, a)
	}
	return kept
}

// ─── Jugador: auras ───────────────────────────────────────────────────

// aplicarAura aplica una aura al jugador. Si la aura tiene categoría de
// stacking, elimina las auras activas de esa categoría (regla WoW). Si
// modifica máximos (aguante/hp_max/mana_max), recalcula hpMax/energiaMax
// y sube la vida/maná actuales en el delta (un frasco +1300 HP añade 1300
// a la vida actual, no solo al techo).
func (j *Jugador) aplicarAura(def auras.DefAura, origen string, ahora int64, m *Mundo) {
	if def.Categoria != "" {
		j.auras = quitarAurasCategoria(j.auras, def.Categoria)
	}
	a := &auras.AuraActiva{
		DefID:       def.ID,
		InicioMs:    ahora,
		FinMs:       ahora + def.DuracionMs,
		AplicadoPor: origen,
	}
	if def.Periodico != nil {
		a.ProximoTickMs = ahora + def.Periodico.IntervaloMs
	}
	j.auras = append(j.auras, a)
	if def.AfectaMaximos() {
		j.recalcMaximosConBuff(m)
	}
}

// recalcMaximosConBuff recalcula hpMax/energiaMax e incrementa la
// vida/maná actuales en el delta positivo del recalculo (para que un buff
// de +vida_max cure esa cantidad al aplicarse).
func (j *Jugador) recalcMaximosConBuff(m *Mundo) {
	oldHP, oldMana := j.hpMax, j.energiaMax
	j.recalcularStatsMaximos(m) // solo clampea hacia abajo
	if d := j.hpMax - oldHP; d > 0 {
		j.hpActual += d
		if j.hpActual > j.hpMax {
			j.hpActual = j.hpMax
		}
	}
	if d := j.energiaMax - oldMana; d > 0 {
		j.energiaActual += d
		if j.energiaActual > j.energiaMax {
			j.energiaActual = j.energiaMax
		}
	}
}

// removerAurasExpiradas elimina las auras vencidas y recalcula máximos si
// alguna expirada afectaba hp/mana máx (pierde el HP buffeado).
func (j *Jugador) removerAurasExpiradas(ahora int64, m *Mundo) {
	recalc := false
	kept := j.auras[:0]
	for _, a := range j.auras {
		if a.Expirada(ahora) {
			if d, ok := defAura(a.DefID); ok && d.AfectaMaximos() {
				recalc = true
			}
			continue
		}
		kept = append(kept, a)
	}
	j.auras = kept
	if recalc {
		j.recalcularStatsMaximos(m)
	}
}

// tickAurasPeriodicos aplica los efectos periódicos (Hot/DoT) pendientes
// del jugador. Los Hot curan vida; un DoT auto-infligido daña al jugador.
// No re-aplica auras expiradas (removerAurasExpiradas se llama antes).
func (j *Jugador) tickAurasPeriodicos(m *Mundo, ahora int64) {
	for _, a := range j.auras {
		if !a.TieneTick() || a.ProximoTickMs > ahora {
			continue
		}
		def, ok := defAura(a.DefID)
		if !ok || def.Periodico == nil {
			continue
		}
		cant := def.Periodico.CantidadPorTick
		if cant > 0 {
			j.hpActual += cant
			if j.hpActual > j.hpMax {
				j.hpActual = j.hpMax
			}
		} else if cant < 0 {
			j.recibirDaño(a.AplicadoPor, -cant, false, m, ahora)
		}
		a.ProximoTickMs += def.Periodico.IntervaloMs
		if a.ProximoTickMs < ahora {
			a.ProximoTickMs = ahora + def.Periodico.IntervaloMs
		}
	}
}

// limpiarAurasAlMorir elimina las auras que NO sobreviven a la muerte
// (todo salvo frascos). Llamado desde morir().
func (j *Jugador) limpiarAurasAlMorir(m *Mundo) {
	recalc := false
	kept := j.auras[:0]
	for _, a := range j.auras {
		if d, ok := defAura(a.DefID); ok && d.PersisteMuerte {
			kept = append(kept, a)
		} else if d, ok := defAura(a.DefID); ok && d.AfectaMaximos() {
			recalc = true
		}
	}
	j.auras = kept
	if recalc {
		j.recalcularStatsMaximos(m)
	}
}

// bonusStatAura suma todos los modificadores de `stat` de las auras activas.
// Usado por statPrincipalTotal, armaduraTotal y recalcularStatsMaximos.
func (j *Jugador) bonusStatAura(stat string) int {
	total := 0
	for _, a := range j.auras {
		def, ok := defAura(a.DefID)
		if !ok {
			continue
		}
		for _, mm := range def.Mods {
			if mm.Stat == stat {
				total += mm.Valor
			}
		}
	}
	return total
}

// aurasRes construye la lista de auras activas para el snapshot del cliente.
func (j *Jugador) aurasRes(ahora int64) []proto.AuraRes {
	if len(j.auras) == 0 {
		return nil
	}
	out := make([]proto.AuraRes, 0, len(j.auras))
	for _, a := range j.auras {
		def, ok := defAura(a.DefID)
		if !ok {
			continue
		}
		r := proto.AuraRes{
			ID:          def.ID,
			Nombre:      def.Nombre,
			Tipo:        string(def.Tipo),
			AplicadoPor: a.AplicadoPor,
		}
		if a.FinMs != 0 {
			r.RestanteMs = a.FinMs - ahora
			if r.RestanteMs < 0 {
				r.RestanteMs = 0
			}
		}
		out = append(out, r)
	}
	return out
}

// ─── Jugador: pociones / curación ─────────────────────────────────────

// pocionLista indica si el cooldown compartido de pociones ha expirado.
func (j *Jugador) pocionLista(ahora int64) bool {
	return j.ultimoUsoPocionMs == 0 || (ahora-j.ultimoUsoPocionMs) >= CooldownPocionMs
}

// curarHP añade `cant` a la vida actual (clampeada al máximo) y devuelve
// lo efectivamente curado.
func (j *Jugador) curarHP(cant int) int {
	antes := j.hpActual
	j.hpActual += cant
	if j.hpActual > j.hpMax {
		j.hpActual = j.hpMax
	}
	return j.hpActual - antes
}

// restaurarMana añade `cant` al maná actual (clampeado al máximo).
func (j *Jugador) restaurarMana(cant int) int {
	antes := j.energiaActual
	j.energiaActual += cant
	if j.energiaActual > j.energiaMax {
		j.energiaActual = j.energiaMax
	}
	return j.energiaActual - antes
}

// consumirItem reduce la cantidad del ítem en el inventario (elimina la
// entrada al llegar a 0). No valida existencia; el llamador debe comprobar.
func (j *Jugador) consumirItem(itemID string, n int) {
	if j.inventario == nil {
		return
	}
	j.inventario[itemID] -= n
	if j.inventario[itemID] <= 0 {
		delete(j.inventario, itemID)
	}
}

// ─── UsarItem (API pública del Mundo) ─────────────────────────────────

// UsarItem consume un ítem consumible del inventario del jugador y aplica
// su efecto. Ver ResultadoUsoItem. Devuelve error si el ítem no es usable,
// no está en el inventario, o no se cumplen las precondiciones (p. ej.
// comer en combate, poción en cooldown).
func (m *Mundo) UsarItem(jugadorID, itemID string) (*ResultadoUsoItem, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	j, ok := m.jugadores[jugadorID]
	if !ok {
		return nil, errors.New("jugador no encontrado")
	}
	it, ok := m.items[itemID]
	if !ok || it.Uso == nil {
		return nil, errors.New("este ítem no es usable")
	}
	if j.CantidadItem(itemID) <= 0 {
		return nil, errors.New("no tienes ese ítem en el inventario")
	}

	ahora := time.Now().UnixMilli()
	uso := it.Uso
	res := &ResultadoUsoItem{ItemID: itemID}

	switch uso.Tipo {
	case "pocion_curacion":
		if !j.pocionLista(ahora) {
			return nil, errors.New("poción en cooldown (" +
				segundosRestantes(j.ultimoUsoPocionMs, ahora, CooldownPocionMs) + " s)")
		}
		res.Curado = j.curarHP(uso.Cantidad)
		j.ultimoUsoPocionMs = ahora
	case "pocion_mana":
		if !j.pocionLista(ahora) {
			return nil, errors.New("poción en cooldown")
		}
		res.Restaurado = j.restaurarMana(uso.Cantidad)
		j.ultimoUsoPocionMs = ahora
	case "bebida":
		if j.enCombate {
			return nil, errors.New("no puedes beber en combate")
		}
		res.Restaurado = j.restaurarMana(uso.Cantidad)
	case "frasco", "elixir", "comida", "pergamino":
		if uso.Tipo == "comida" && j.enCombate {
			return nil, errors.New("no puedes comer en combate")
		}
		def, ok := defAura(uso.AuraID)
		if !ok {
			return nil, errors.New("aura del consumible no existe: " + uso.AuraID)
		}
		j.aplicarAura(def, itemID, ahora, m)
		res.AuraAplicada = def.ID
	default:
		return nil, errors.New("tipo de consumible desconocido: " + uso.Tipo)
	}

	j.consumirItem(itemID, 1)
	res.AurasActivas = j.aurasRes(ahora)
	return res, nil
}

// segundosRestantes devuelve, como string, los segundos que faltan para que
// un cooldown (definido por ultimoUsoMs + duracionMs) expire respecto a ahora.
func segundosRestantes(ultimoUsoMs, ahora, duracionMs int64) string {
	restante := duracionMs - (ahora - ultimoUsoMs)
	if restante < 0 {
		restante = 0
	}
	return intToString(int(restante / 1000))
}

// intToString convierte un entero a su representación decimal (sin fmt
// para evitar importarlo solo por esto).
func intToString(n int) string {
	if n == 0 {
		return "0"
	}
	neg := n < 0
	if neg {
		n = -n
	}
	var buf [20]byte
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	if neg {
		i--
		buf[i] = '-'
	}
	return string(buf[i:])
}

// ─── Enemigo: auras (debuffs / DoT) ───────────────────────────────────

// aplicarAuraEnemigo aplica una aura (típicamente un debuff/DoT) a un mob.
// Soporta las mismas reglas de stacking por categoría que el jugador.
func (e *Enemigo) aplicarAuraEnemigo(def auras.DefAura, origen string, ahora int64) {
	if def.Categoria != "" {
		e.auras = quitarAurasCategoria(e.auras, def.Categoria)
	}
	a := &auras.AuraActiva{
		DefID:       def.ID,
		InicioMs:    ahora,
		FinMs:       ahora + def.DuracionMs,
		AplicadoPor: origen,
	}
	if def.Periodico != nil {
		a.ProximoTickMs = ahora + def.Periodico.IntervaloMs
	}
	e.auras = append(e.auras, a)
}

// removerAurasExpiradasEnemigo elimina las auras vencidas del mob.
func (e *Enemigo) removerAurasExpiradasEnemigo(ahora int64) {
	kept := e.auras[:0]
	for _, a := range e.auras {
		if !a.Expirada(ahora) {
			kept = append(kept, a)
		}
	}
	e.auras = kept
}

// tickAurasPeriodicosEnemigo aplica los DoT pendientes del mob (daño al
// propio mob, con crédito al origen AplicadoPor) y los Hot (curación).
// Llamado desde Enemigo.actualizar.
func (e *Enemigo) tickAurasPeriodicosEnemigo(m *Mundo, ahora int64) {
	for _, a := range e.auras {
		if !a.TieneTick() || a.ProximoTickMs > ahora {
			continue
		}
		def, ok := defAura(a.DefID)
		if !ok || def.Periodico == nil {
			continue
		}
		cant := def.Periodico.CantidadPorTick
		if cant < 0 {
			// DoT: dañar al mob (origen = quien la aplicó, para crédito de muerte).
			e.recibirDaño(a.AplicadoPor, -cant, false, m, ahora)
		} else if cant > 0 {
			e.hpActual += cant
			if e.hpActual > e.hpMax {
				e.hpActual = e.hpMax
			}
		}
		a.ProximoTickMs += def.Periodico.IntervaloMs
		if a.ProximoTickMs < ahora {
			a.ProximoTickMs = ahora + def.Periodico.IntervaloMs
		}
	}
}

// ─── Persistencia ─────────────────────────────────────────────────────

// aurasParaPersist devuelve las auras a persistir. Solo se guardan las que
// sobreviven a la muerte (frascos); el resto es efímero y se descarta.
func (j *Jugador) aurasParaPersist() []persistencia.AuraPersist {
	out := make([]persistencia.AuraPersist, 0, len(j.auras))
	for _, a := range j.auras {
		def, ok := defAura(a.DefID)
		if !ok || !def.PersisteMuerte {
			continue
		}
		out = append(out, persistencia.AuraPersist{
			DefID:         a.DefID,
			FinMs:         a.FinMs,
			ProximoTickMs: a.ProximoTickMs,
			AplicadoPor:   a.AplicadoPor,
		})
	}
	return out
}

// cargarAurasDesdePersist restaura las auras guardadas (frascos) al cargar
// el personaje. Descarta las ya expiradas mientras estuvo offline, y
// recalcula máximos con buff si alguna afecta hp/mana máx (para que el
// jugador cargue con el HP buffeado).
func (j *Jugador) cargarAurasDesdePersist(guardadas []persistencia.AuraPersist, m *Mundo, ahora int64) {
	j.auras = make([]*auras.AuraActiva, 0, len(guardadas))
	recalc := false
	for _, g := range guardadas {
		def, ok := defAura(g.DefID)
		if !ok {
			continue // aura desconocida (catálogo cambió): descartar
		}
		if g.FinMs != 0 && g.FinMs <= ahora {
			continue // expiró offline
		}
		j.auras = append(j.auras, &auras.AuraActiva{
			DefID:         g.DefID,
			InicioMs:      ahora,
			FinMs:         g.FinMs,
			ProximoTickMs: g.ProximoTickMs,
			AplicadoPor:   g.AplicadoPor,
		})
		if def.AfectaMaximos() {
			recalc = true
		}
	}
	if recalc {
		j.recalcMaximosConBuff(m)
	}
}
