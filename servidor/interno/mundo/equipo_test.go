// equipo_test.go valida el sistema de equipamiento, stats, loot y comercio:
// el catálogo de ítems equipables, equipar/quitar con recálculo de HP/daño/
// armadura, el scaling de stat principal en el daño, la mitigación de
// armadura, las tablas de botín, y la compra/venta con vendedores.
package mundo

import (
	"testing"
)

// TestCatalogoEquipo valida los ítems equipables del catálogo.
func TestCatalogoEquipo(t *testing.T) {
	m := nuevoMundoTest(t)
	equipo := 0
	for _, it := range m.items {
		if it.Equipable {
			equipo++
			if it.Slot == "" {
				t.Errorf("ítem %s equipable sin Slot", it.ID)
			}
			if it.NivelReq < 1 || it.NivelReq > NivelMax {
				t.Errorf("ítem %s NivelReq inválido %d", it.ID, it.NivelReq)
			}
			if it.Precio <= 0 {
				t.Errorf("ítem %s sin Precio", it.ID)
			}
			// Al menos un stat o armadura.
			if it.Fuerza+it.Agilidad+it.Intelecto+it.Espiritu+it.Aguante+it.Armadura == 0 {
				t.Errorf("ítem %s equipable sin stats ni armadura", it.ID)
			}
		}
	}
	if equipo < 30 {
		t.Errorf("ítems equipables = %d, esperaba ≥30", equipo)
	}
	// Los ítems no-equipables siguen siéndolo (p. ej. comida).
	if it, ok := m.items["ciruela_blanca_sabrosa"]; ok && it.Equipable {
		t.Error("la ciruela no debería ser equipable")
	}
	// Cada ranura tiene al menos un ítem equipable.
	for _, slot := range []string{SlotCabeza, SlotPecho, SlotPies, SlotArma, SlotDedo, SlotCapa, SlotCuello} {
		encontrado := false
		for _, it := range m.items {
			if it.Equipable && it.Slot == slot {
				encontrado = true
				break
			}
		}
		if !encontrado {
			t.Errorf("ranura %s sin ítems equipables", slot)
		}
	}
}

// TestEquiparStats valida que equipar un ítem bonusa HP (aguante), armadura
// y el stat principal, con recálculo de hpMax.
func TestEquiparStats(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Equiper", "guerrero", FaccionAlianza, "humano")
	hpMaxIni := j.hpMax
	armaduraIni := j.armaduraTotal()
	statIni := j.statPrincipalTotal()
	// Dar y equipar pecho_tela (aguante 2, armadura 10, fuerza 1).
	m.mu.Lock()
	j.AgregarItem("pecho_tela", 1)
	m.mu.Unlock()
	if _, err := m.EquiparItem(j.id, "pecho_tela"); err != nil {
		t.Fatalf("equipar pecho_tela: %v", err)
	}
	if j.hpMax != hpMaxIni+20 { // aguante 2 * 10
		t.Errorf("hpMax=%d, esperaba %d (+20 por aguante)", j.hpMax, hpMaxIni+20)
	}
	if j.armaduraTotal() != armaduraIni+10 {
		t.Errorf("armadura=%d, esperaba %d (+10)", j.armaduraTotal(), armaduraIni+10)
	}
	if j.statPrincipalTotal() != statIni+1 { // fuerza 1
		t.Errorf("statPrincipal=%d, esperaba %d (+1)", j.statPrincipalTotal(), statIni+1)
	}
	// El ítem ya no está en el inventario.
	if j.CantidadItem("pecho_tela") != 0 {
		t.Error("el ítem equipado sigue en el inventario")
	}
}

// TestEquiparDesplaza valida que equipar en una ranura ocupada devuelve el
// ítem viejo al inventario.
func TestEquiparDesplaza(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Cambista", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	j.AgregarItem("pecho_tela", 2)
	m.mu.Unlock()
	if _, err := m.EquiparItem(j.id, "pecho_tela"); err != nil {
		t.Fatalf("equipar 1: %v", err)
	}
	// Inventario: 1 restante. Equipar otra vez desplaza la primera.
	desplazado, err := m.EquiparItem(j.id, "pecho_tela")
	if err != nil {
		t.Fatalf("equipar 2: %v", err)
	}
	if desplazado != "pecho_tela" {
		t.Errorf("desplazado=%q, esperaba pecho_tela", desplazado)
	}
	// El slot sigue ocupado y el inventario tiene 1 (el desplazado).
	if m.Equipado(j.id)[SlotPecho] != "pecho_tela" {
		t.Error("el slot pecho no está ocupado tras desplazar")
	}
	if j.CantidadItem("pecho_tela") != 1 {
		t.Errorf("inventario=%d, esperaba 1", j.CantidadItem("pecho_tela"))
	}
}

// TestEquiparNivelReq valida que no se puede equipar un ítem de nivel alto.
func TestEquiparNivelReq(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Novato", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	j.AgregarItem("arma_cuero", 1) // NivelReq 10
	m.mu.Unlock()
	if _, err := m.EquiparItem(j.id, "arma_cuero"); err == nil {
		t.Error("equipar arma lvl 10 siendo lvl 1 debería fallar")
	}
}

// TestQuitarEquipo valida que quitar un ítem revierte los stats y lo devuelve
// al inventario.
func TestQuitarEquipo(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Quitador", "guerrero", FaccionAlianza, "humano")
	hpMaxBase := j.hpMax
	m.mu.Lock()
	j.AgregarItem("pecho_tela", 1)
	m.mu.Unlock()
	_, _ = m.EquiparItem(j.id, "pecho_tela")
	if j.hpMax <= hpMaxBase {
		t.Fatal("equipar no subió hpMax")
	}
	if _, err := m.QuitarItemEquipo(j.id, SlotPecho); err != nil {
		t.Fatalf("quitar: %v", err)
	}
	if j.hpMax != hpMaxBase {
		t.Errorf("tras quitar hpMax=%d, esperaba %d", j.hpMax, hpMaxBase)
	}
	if j.CantidadItem("pecho_tela") != 1 {
		t.Error("el ítem quitado no volvió al inventario")
	}
}

// TestStatScalingDaño valida que el stat principal escala el daño.
func TestStatScalingDaño(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Dps", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	danoSin := j.calcularDaño(200)
	j.AgregarItem("arma_tela", 1) // fuerza +3
	m.mu.Unlock()
	_, _ = m.EquiparItem(j.id, "arma_tela")
	m.mu.Lock()
	danoCon := j.calcularDaño(200)
	m.mu.Unlock()
	if danoCon <= danoSin {
		t.Errorf("daño con equipo (%d) no supera al sin equipo (%d)", danoCon, danoSin)
	}
}

// TestMitigacionArmadura valida que la armadura reduce el daño recibido.
func TestMitigacionArmadura(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Tanque", "guerrero", FaccionAlianza, "humano")
	// Sin armadura: daño 100 íntegro.
	m.mu.Lock()
	j.hpActual = j.hpMax
	j.recibirDaño("mob_test", 100, false, m, 0)
	perdidaSin := j.hpMax - j.hpActual
	m.mu.Unlock()
	// Con armadura (pecho_tela armadura 10).
	m.mu.Lock()
	j.AgregarItem("pecho_tela", 1)
	m.mu.Unlock()
	_, _ = m.EquiparItem(j.id, "pecho_tela")
	m.mu.Lock()
	j.hpActual = j.hpMax
	j.recibirDaño("mob_test", 100, false, m, 0)
	perdidaCon := j.hpMax - j.hpActual
	m.mu.Unlock()
	if perdidaCon >= perdidaSin {
		t.Errorf("armadura no mitigó: sin=%d, con=%d", perdidaSin, perdidaCon)
	}
}

// TestLootOro valida que matar un mob da oro al último atacante.
func TestLootOro(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Saqueador", "cazador", FaccionAlianza, "humano")
	oroIni := j.Oro()
	mobID := mobDeFamiliaZona(t, m, "lobo")
	matarMobTest(t, m, mobID, j.id)
	if j.Oro() <= oroIni {
		t.Errorf("oro tras matar=%d, esperaba > %d", j.Oro(), oroIni)
	}
}

// TestLootMateriales valida que el loot suelta materiales de la familia.
func TestLootMateriales(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Peller", "cazador", FaccionAlianza, "humano")
	// Simular 100 muertes de lobo (prob. 0.5 de cuero_ligero c/u).
	m.mu.Lock()
	for i := 0; i < 100; i++ {
		m.otorgarLootMuerte(j.id, 2, "lobo")
	}
	m.mu.Unlock()
	if j.CantidadItem("cuero_ligero") <= 0 {
		t.Error("100 loot de lobo no soltó cuero_ligero")
	}
}

// TestLootTableFamilia valida que las tablas de botín usan IDs existentes.
func TestLootTableFamilia(t *testing.T) {
	m := nuevoMundoTest(t)
	for _, fam := range []string{"lobo", "jabali", "zombi", "murloc", "humanoide", "bestia", "elemental", "demonio"} {
		tabla := lootTablePorFamilia(fam)
		for _, e := range tabla.Entradas {
			if _, ok := m.items[e.ItemID]; !ok {
				t.Errorf("familia %s: loot item %s inexistente", fam, e.ItemID)
			}
		}
	}
}

// TestDropEquipoAleatorio valida que el drop de equipo elige un ítem
// equipable con NivelReq <= nivel.
func TestDropEquipoAleatorio(t *testing.T) {
	m := nuevoMundoTest(t)
	for _, nivel := range []int{1, 30, 70} {
		id := m.dropEquipoAleatorio(nivel)
		if id == "" {
			continue // puede no haber candidato; acceptable
		}
		it, ok := m.items[id]
		if !ok {
			t.Errorf("drop nivel %d: item %s inexistente", nivel, id)
		}
		if !it.Equipable {
			t.Errorf("drop nivel %d: item %s no equipable", nivel, id)
		}
		if it.NivelReq > nivel {
			t.Errorf("drop nivel %d: item %s NivelReq %d", nivel, id, it.NivelReq)
		}
	}
}

// TestComprarItem valida la compra: gasta oro y añade al inventario.
func TestComprarItem(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Comprador", "mago", FaccionAlianza, "humano")
	m.mu.Lock()
	j.oro = 1000
	m.mu.Unlock()
	precio := m.items["arma_tela"].Precio
	oroIni := j.Oro()
	if err := m.ComprarItem(j.id, "ven_ventormenta", "arma_tela", 1); err != nil {
		t.Fatalf("comprar: %v", err)
	}
	if j.Oro() != oroIni-precio {
		t.Errorf("oro tras comprar=%d, esperaba %d", j.Oro(), oroIni-precio)
	}
	if j.CantidadItem("arma_tela") != 1 {
		t.Error("el ítem comprado no está en el inventario")
	}
}

// TestComprarOroInsuficiente valida que no se compra sin oro.
func TestComprarOroInsuficiente(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Pobre", "mago", FaccionAlianza, "humano")
	m.mu.Lock()
	j.oro = 1
	m.mu.Unlock()
	if err := m.ComprarItem(j.id, "ven_ventormenta", "arma_tela", 1); err == nil {
		t.Error("comprar sin oro debería fallar")
	}
}

// TestVenderItem valida la venta: retira del inventario y da oro.
func TestVenderItem(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Vendedor", "mago", FaccionAlianza, "humano")
	m.mu.Lock()
	j.AgregarItem("ciruela_blanca_sabrosa", 3)
	oroIni := j.oro
	m.mu.Unlock()
	if err := m.VenderItem(j.id, "ven_ventormenta", "ciruela_blanca_sabrosa", 2); err != nil {
		t.Fatalf("vender: %v", err)
	}
	if j.oro <= oroIni {
		t.Error("vender no dio oro")
	}
	if j.CantidadItem("ciruela_blanca_sabrosa") != 1 {
		t.Errorf("tras vender 2 queda %d, esperaba 1", j.CantidadItem("ciruela_blanca_sabrosa"))
	}
}

// TestVendedorVendeEquipo valida que los vendedores venden equipo básico.
func TestVendedorVendeEquipo(t *testing.T) {
	m := nuevoMundoTest(t)
	npc, ok := m.NPC("ven_ventormenta")
	if !ok {
		t.Fatal("ven_ventormenta no existe")
	}
	tiene := false
	for _, id := range npc.VendeItems {
		if id == "arma_tela" {
			tiene = true
		}
	}
	if !tiene {
		t.Error("el vendedor no vende arma_tela")
	}
}

// TestPersistenciaEquipo valida el round-trip del equipo equipado y el
// recálculo de stats al cargar.
func TestPersistenciaEquipo(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "PersistenteEq", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	j.AgregarItem("pecho_tela", 1)
	m.mu.Unlock()
	_, _ = m.EquiparItem(j.id, "pecho_tela")
	hpMaxConEquipo := j.hpMax
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar(j.nombre)
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, j.cuenta)
	if m.Equipado(j2.id)[SlotPecho] != "pecho_tela" {
		t.Error("equipo no persistió tras guardar/cargar")
	}
	if j2.hpMax != hpMaxConEquipo {
		t.Errorf("hpMax tras recargar=%d, esperaba %d (con bonus de equipo)", j2.hpMax, hpMaxConEquipo)
	}
}
