// equipo.go implementa el sistema de equipamiento, stats, loot y comercio:
// ítems equipables con bonus de stats por ranura, equipar/quitar con
// recálculo de HP/daño/armadura, tablas de botín que sueltan los mobs al
// morir, y compra/venta con vendedores.
//
// Stats: cada ítem equipable bonusa Fuerza/Agilidad/Intelecto/Espíritu/
// Aguante/Armadura. El stat principal de la clase (DefClase.StatPrincipal)
// escala el daño (1 + stat/200). El aguante equipo añade HP (+10 c/u). La
// armadura mitiga daño físico (armadura/(armadura+200+nivel·50)).
//
// Concurrencia: EquiparItem/QuitarItem/ComprarItem/VenderItem son acciones
// de red (m.mu.Lock, acceso directo a maps). otorgarLootMuerte corre en el
// tick (m.mu ya Lock, sin locks propios).
package mundo

import (
	"errors"
	"math/rand"
	"sort"
)

// ─── Stats agregados del equipo ──────────────────────────────────────────

// statsEquipados suma los stats de todos los ítems equipados.
func (j *Jugador) statsEquipados() (fuerza, agilidad, intelecto, espiritu, aguante, armadura int) {
	for _, itemID := range j.equipado {
		it, ok := j.items[itemID]
		if !ok {
			continue
		}
		fuerza += it.Fuerza
		agilidad += it.Agilidad
		intelecto += it.Intelecto
		espiritu += it.Espiritu
		aguante += it.Aguante
		armadura += it.Armadura
	}
	return
}

// statDeEquipo devuelve el bonus equipado de un stat concreto.
func (j *Jugador) statDeEquipo(stat string) int {
	f, a, i, es, ag, _ := j.statsEquipados()
	switch stat {
	case StatFuerza:
		return f
	case StatAgilidad:
		return a
	case StatIntelecto:
		return i
	case StatEspiritu:
		return es
	case StatAguante:
		return ag
	}
	return 0
}

// statPrincipalTotal devuelve el stat principal de la clase del jugador
// (base por nivel + bonus de equipo). Base: 10 + nivel·3.
func (j *Jugador) statPrincipalTotal() int {
	base := 10 + j.nivel*3
	sp := j.claseDef.StatPrincipal
	if sp == "" {
		return base
	}
	return base + j.statDeEquipo(sp)
}

// armaduraTotal devuelve la armadura total equipada.
func (j *Jugador) armaduraTotal() int {
	_, _, _, _, _, arm := j.statsEquipados()
	return arm
}

// bonusAguanteEquip devuelve el aguante bonus del equipo.
func (j *Jugador) bonusAguanteEquip() int {
	_, _, _, _, ag, _ := j.statsEquipados()
	return ag
}

// recalcularStatsMaximos recalcula hpMax/energiaMax con la fórmula de la
// clase + racial + bonus de aguante del equipo (+10 HP c/u), y clampea los
// valores actuales al nuevo máximo. Llamado al equipar/quitar y al subir
// de nivel. NO cura (el equipo no cura; al subir nivel sí cura subirNivel).
func (j *Jugador) recalcularStatsMaximos(m *Mundo) {
	def := j.claseDef
	hpMax := def.HPBase + def.HPPorNivel*(j.nivel-1)
	energiaMax := def.EnergiaBase + def.EnergiaPorNivel*(j.nivel-1)
	if razaDef, ok := m.razas[j.raza]; ok {
		hpMax = int(float64(hpMax) * (1 + razaDef.ModHP))
		energiaMax = int(float64(energiaMax) * (1 + razaDef.ModMana))
	}
	hpMax += j.bonusAguanteEquip() * 10
	j.hpMax = hpMax
	j.energiaMax = energiaMax
	if j.hpActual > j.hpMax {
		j.hpActual = j.hpMax
	}
	if j.energiaActual > j.energiaMax {
		j.energiaActual = j.energiaMax
	}
}

// ─── Equipar / Quitar ────────────────────────────────────────────────────

// EquiparItem equipa un ítem del inventario en su ranura. Requiere tener el
// ítem en el inventario, que sea equipable y que el nivel sea suficiente.
// Si la ranura estaba ocupada, el ítem viejo vuelve al inventario. Devuelve
// el itemID desplazado ("" si ninguno).
func (m *Mundo) EquiparItem(jugadorID, itemID string) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return "", errors.New("jugador no encontrado")
	}
	it, ok := m.items[itemID]
	if !ok {
		return "", errors.New("ítem inexistente")
	}
	if !it.Equipable {
		return "", errors.New("este ítem no es equipable")
	}
	if j.inventario[itemID] <= 0 {
		return "", errors.New("no tienes ese ítem en el inventario")
	}
	if j.nivel < it.NivelReq {
		return "", errors.New("nivel insuficiente para equipar este ítem")
	}
	// Quitar del inventario.
	j.inventario[itemID]--
	if j.inventario[itemID] <= 0 {
		delete(j.inventario, itemID)
	}
	// Ranura ocupada: devolver el viejo al inventario.
	desplazado := j.equipado[it.Slot]
	if desplazado != "" {
		j.inventario[desplazado]++
	}
	j.equipado[it.Slot] = itemID
	j.recalcularStatsMaximos(m)
	return desplazado, nil
}

// QuitarItemEquipo retira el ítem de una ranura al inventario.
func (m *Mundo) QuitarItemEquipo(jugadorID, slot string) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return "", errors.New("jugador no encontrado")
	}
	itemID, ok := j.equipado[slot]
	if !ok {
		return "", errors.New("no hay ítem equipado en esa ranura")
	}
	delete(j.equipado, slot)
	j.inventario[itemID]++
	j.recalcularStatsMaximos(m)
	return itemID, nil
}

// Equipado devuelve los itemID equipados por ranura (copia).
func (m *Mundo) Equipado(jugadorID string) map[string]string {
	m.mu.RLock()
	j, ok := m.jugadores[jugadorID]
	m.mu.RUnlock()
	if !ok {
		return nil
	}
	out := make(map[string]string, len(j.equipado))
	for k, v := range j.equipado {
		out[k] = v
	}
	return out
}

// ─── Comercio: comprar / vender ──────────────────────────────────────────

// ComprarItem compra `cantidad` unidades de un ítem a un vendedor. Cobra
// precio·cantidad de oro y añade al inventario. El ítem debe estar en el
// catálogo VendeItems del NPC y el jugador debe tener oro suficiente.
func (m *Mundo) ComprarItem(jugadorID, npcID, itemID string, cantidad int) error {
	if cantidad <= 0 {
		return errors.New("cantidad inválida")
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return errors.New("jugador no encontrado")
	}
	npc, ok := m.npcPorID(npcID)
	if !ok {
		return errors.New("NPC no encontrado")
	}
	if distancia2D(j.pos, npc.Pos) > RangoInteraccionNPC {
		return errors.New("estás demasiado lejos del vendedor")
	}
	if npc.Tipo != "vendedor" {
		return errors.New("este NPC no vende ítems")
	}
	vende := false
	for _, id := range npc.VendeItems {
		if id == itemID {
			vende = true
			break
		}
	}
	if !vende {
		return errors.New("el vendedor no ofrece ese ítem")
	}
	it, ok := m.items[itemID]
	if !ok {
		return errors.New("ítem inexistente")
	}
	precio := it.Precio
	if precio <= 0 {
		precio = 1 // ítems sin precio definido valen 1 cobre
	}
	coste := precio * cantidad
	if j.oro < coste {
		return errors.New("oro insuficiente")
	}
	j.oro -= coste
	j.AgregarItem(itemID, cantidad)
	return nil
}

// VenderItem vende `cantidad` unidades de un ítem del inventario a un
// vendedor. Paga precio/4 por unidad (mín 1 cobre) y retira del inventario.
// Cualquier vendedor compra cualquier ítem (comportamiento MVP).
func (m *Mundo) VenderItem(jugadorID, npcID, itemID string, cantidad int) error {
	if cantidad <= 0 {
		return errors.New("cantidad inválida")
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return errors.New("jugador no encontrado")
	}
	npc, ok := m.npcPorID(npcID)
	if !ok {
		return errors.New("NPC no encontrado")
	}
	if distancia2D(j.pos, npc.Pos) > RangoInteraccionNPC {
		return errors.New("estás demasiado lejos del vendedor")
	}
	if npc.Tipo != "vendedor" {
		return errors.New("este NPC no comercia")
	}
	if j.inventario[itemID] < cantidad {
		return errors.New("no tienes suficientes unidades")
	}
	it, ok := m.items[itemID]
	precio := 1
	if ok && it.Precio > 0 {
		precio = it.Precio / 4
		if precio < 1 {
			precio = 1
		}
	}
	j.inventario[itemID] -= cantidad
	if j.inventario[itemID] <= 0 {
		delete(j.inventario, itemID)
	}
	j.oro += precio * cantidad
	return nil
}

// ─── Loot (tablas de botín) ──────────────────────────────────────────────

// DefLootEntry es una entrada de una tabla de botín.
type DefLootEntry struct {
	ItemID       string
	Probabilidad float64 // 0-1 probabilidad de caer
	CantidadMin  int
	CantidadMax  int
}

// DefLootTable es la tabla de botín de una familia de mobs.
type DefLootTable struct {
	Entradas []DefLootEntry
	OroMin   int // base, escalado por nivel del mob
	OroMax   int
}

// lootTablePorFamilia devuelve la tabla de botín de una familia de mob.
// Todas las familias sueltan oro + materiales cosméticos acorde al tipo.
func lootTablePorFamilia(familia string) DefLootTable {
	switch familia {
	case "lobo":
		return DefLootTable{
			OroMin: 1, OroMax: 3,
			Entradas: []DefLootEntry{
				{ItemID: "cuero_ligero", Probabilidad: 0.50, CantidadMin: 1, CantidadMax: 2},
			},
		}
	case "jabali":
		return DefLootTable{
			OroMin: 1, OroMax: 3,
			Entradas: []DefLootEntry{
				{ItemID: "trucha_cabeza_mitril_crudo", Probabilidad: 0.60, CantidadMin: 1, CantidadMax: 2},
			},
		}
	case "zombi":
		return DefLootTable{
			OroMin: 1, OroMax: 4,
			Entradas: []DefLootEntry{
				{ItemID: "tela_escarcha", Probabilidad: 0.45, CantidadMin: 1, CantidadMax: 2},
			},
		}
	case "murloc":
		return DefLootTable{
			OroMin: 2, OroMax: 5,
			Entradas: []DefLootEntry{
				{ItemID: "escamas_dragon_desgastadas", Probabilidad: 0.40, CantidadMin: 1, CantidadMax: 2},
			},
		}
	case "humanoide":
		return DefLootTable{
			OroMin: 2, OroMax: 6,
			Entradas: []DefLootEntry{
				{ItemID: "tela_escarcha", Probabilidad: 0.40, CantidadMin: 1, CantidadMax: 2},
			},
		}
	case "bestia":
		return DefLootTable{
			OroMin: 1, OroMax: 3,
			Entradas: []DefLootEntry{
				{ItemID: "cuero_ligero", Probabilidad: 0.45, CantidadMin: 1, CantidadMax: 2},
			},
		}
	case "elemental":
		return DefLootTable{
			OroMin: 2, OroMax: 5,
			Entradas: []DefLootEntry{
				{ItemID: "polvo_arcano", Probabilidad: 0.40, CantidadMin: 1, CantidadMax: 2},
			},
		}
	case "demonio":
		return DefLootTable{
			OroMin: 3, OroMax: 8,
			Entradas: []DefLootEntry{
				{ItemID: "tela_lunar_primigenia", Probabilidad: 0.45, CantidadMin: 1, CantidadMax: 2},
			},
		}
	default:
		return DefLootTable{OroMin: 1, OroMax: 3}
	}
}

// otorgarLootMuerte suelta el botín de un mob al último atacante (si es
// jugador): oro escalado por nivel, materiales por familia, y una pequeña
// probabilidad (~3%) de un ítem equipable adecuado al nivel. Llamado desde
// Enemigo.morir (tick, m.mu ya Lock).
func (m *Mundo) otorgarLootMuerte(jugadorID string, nivelMob int, familiaMob string) {
	j, ok := m.jugadores[jugadorID]
	if !ok {
		return
	}
	tabla := lootTablePorFamilia(familiaMob)
	// Oro escalado por nivel del mob.
	oroMin := tabla.OroMin + nivelMob*2
	oroMax := tabla.OroMax + nivelMob*4
	if oroMax < oroMin {
		oroMax = oroMin
	}
	j.oro += oroMin + rand.Intn(oroMax-oroMin+1)
	// Materiales.
	for _, e := range tabla.Entradas {
		if rand.Float64() < e.Probabilidad {
			cant := e.CantidadMin
			if e.CantidadMax > e.CantidadMin {
				cant += rand.Intn(e.CantidadMax - e.CantidadMin + 1)
			}
			j.AgregarItem(e.ItemID, cant)
		}
	}
	// Drop de equipo: 3% de un ítem equipable con NivelReq <= nivelMob.
	if rand.Float64() < 0.03 {
		if itemID := m.dropEquipoAleatorio(nivelMob); itemID != "" {
			j.AgregarItem(itemID, 1)
		}
	}
}

// dropEquipoAleatorio elige un ítem equipable al azar cuyo NivelReq <= nivel.
func (m *Mundo) dropEquipoAleatorio(nivel int) string {
	cands := make([]string, 0)
	ids := make([]string, 0, len(m.items))
	for id := range m.items {
		ids = append(ids, id)
	}
	sort.Strings(ids) // determinismo del recorrido
	for _, id := range ids {
		it := m.items[id]
		if it.Equipable && it.NivelReq <= nivel && it.NivelReq >= nivel-15 {
			cands = append(cands, id)
		}
	}
	if len(cands) == 0 {
		return ""
	}
	return cands[rand.Intn(len(cands))]
}
