// auras_test.go (paquete mundo) valida la integración del sistema de auras:
// UsarItem aplica auras y consume el ítem, reglas de stacking (frasco
// reemplaza frasco; elixir batalla+guardián coexisten), cooldown de
// pociones, comida prohibida en combate, DoT sobre enemigos, modificación
// de stats y daño, limpieza al morir (frascos sobreviven) y persistencia.
package mundo

import (
	"testing"

	"aethelgard/servidor/interno/auras"
	"aethelgard/servidor/interno/persistencia"
	"aethelgard/servidor/interno/proto"
)

// auraActivaDice devuelve true si el jugador tiene un aura con defID activa.
func auraActivaDice(j *Jugador, defID string) bool {
	for _, a := range j.auras {
		if a.DefID == defID {
			return true
		}
	}
	return false
}

// contarAurasCategoria cuenta las auras activas del jugador con la categoría.
func contarAurasCategoria(j *Jugador, cat auras.CategoriaStack) int {
	n := 0
	for _, a := range j.auras {
		if d, ok := auras.CatalogoAuras()[a.DefID]; ok && d.Categoria == cat {
			n++
		}
	}
	return n
}

// TestUsarFrascoAplicaAuraYSubeHP verifica que usar un frasco de +HP_max
// aplica el aura, sube hpMax en el delta Y sube hpActual en el delta (el
// buff "cura" esa cantidad), y consume el ítem.
func TestUsarFrascoAplicaAuraYSubeHP(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "tanque", "guerrero", "alianza", "humano")
	j.AgregarItem("frasco_sangre_piedra", 1)
	oldHP := j.hpMax
	oldActual := j.hpActual

	res, err := m.UsarItem(j.ID(), "frasco_sangre_piedra")
	if err != nil {
		t.Fatalf("UsarItem frasco: %v", err)
	}
	if res.AuraAplicada != "frasco_sangre_piedra" {
		t.Errorf("AuraAplicada=%q esperaba frasco_sangre_piedra", res.AuraAplicada)
	}
	if !auraActivaDice(j, "frasco_sangre_piedra") {
		t.Error("frasco no quedó como aura activa")
	}
	if j.hpMax != oldHP+1300 {
		t.Errorf("hpMax=%d esperaba %d (+1300)", j.hpMax, oldHP+1300)
	}
	if j.hpActual != oldActual+1300 {
		t.Errorf("hpActual=%d esperaba %d (+1300: el buff cura el delta)", j.hpActual, oldActual+1300)
	}
	if j.CantidadItem("frasco_sangre_piedra") != 0 {
		t.Error("el frasco no se consumió")
	}
}

// TestFrascoReemplazaFrasco verifica la regla de stacking: aplicar un
// segundo frasco elimina el primero (solo 1 frasco activo).
func TestFrascoReemplazaFrasco(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "mago", "mago", "alianza", "humano")
	ahora := int64(10000)
	j.aplicarAura(auras.CatalogoAuras()["frasco_iracolosal"], "test", ahora, m)
	j.aplicarAura(auras.CatalogoAuras()["frasco_sangre_piedra"], "test", ahora, m)
	if contarAurasCategoria(j, auras.CatFrasco) != 1 {
		t.Errorf("frascos activos=%d esperaba 1 (stacking)", contarAurasCategoria(j, auras.CatFrasco))
	}
	if auraActivaDice(j, "frasco_iracolosal") {
		t.Error("el primer frasco debería haber sido reemplazado")
	}
	if !auraActivaDice(j, "frasco_sangre_piedra") {
		t.Error("el segundo frasco debería estar activo")
	}
}

// TestElixirBatallaYGuardianCoexisten verifica que un elixir de batalla y
// uno guardián pueden coexistir (categorías distintas, 2 slots).
func TestElixirBatallaYGuardianCoexisten(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "sacer", "sacerdote", "alianza", "humano")
	ahora := int64(1000)
	j.aplicarAura(auras.CatalogoAuras()["elixir_agilidad_poderosa"], "test", ahora, m)
	j.aplicarAura(auras.CatalogoAuras()["elixir_proteccion"], "test", ahora, m)
	if contarAurasCategoria(j, auras.CatElixirBatalla) != 1 {
		t.Error("debe haber 1 elixir de batalla")
	}
	if contarAurasCategoria(j, auras.CatElixirGuardian) != 1 {
		t.Error("debe haber 1 elixir guardián")
	}
	if len(j.auras) != 2 {
		t.Errorf("auras activas=%d esperaba 2 (batalla+guardián)", len(j.auras))
	}
}

// TestPocionCooldown verifica que la primera poción cura y la segunda
// dentro de los 60s falla por cooldown compartido.
func TestPocionCooldown(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "rogue", "pícaro", "horda", "orco")
	j.AgregarItem("pocion_curacion_runica", 2)
	// Herir al jugador para que la curación tenga efecto.
	j.hpActual = j.hpMax / 2
	hpAntes := j.hpActual

	if _, err := m.UsarItem(j.ID(), "pocion_curacion_runica"); err != nil {
		t.Fatalf("primera poción: %v", err)
	}
	if j.hpActual <= hpAntes {
		t.Errorf("HP no subió tras poción: %d → %d", hpAntes, j.hpActual)
	}
	// Segunda poción inmediata: debe fallar por CD.
	_, err := m.UsarItem(j.ID(), "pocion_curacion_runica")
	if err == nil {
		t.Error("la segunda poción debería fallar por cooldown")
	}
}

// TestComidaEnCombateFalla verifica que no se puede comer en combate, pero
// sí fuera de él.
func TestComidaEnCombateFalla(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "hunter", "cazador", "horda", "tauren")
	j.AgregarItem("comida_rinoceronte", 1)

	j.enCombate = true
	if _, err := m.UsarItem(j.ID(), "comida_rinoceronte"); err == nil {
		t.Error("comer en combate debería fallar")
	}
	// El ítem NO se consume si el uso falla.
	if j.CantidadItem("comida_rinoceronte") != 1 {
		t.Error("la comida se consumió pese a fallar el uso")
	}

	j.enCombate = false
	if _, err := m.UsarItem(j.ID(), "comida_rinoceronte"); err != nil {
		t.Fatalf("comer fuera de combate: %v", err)
	}
	if !auraActivaDice(j, "comida_rinoceronte") {
		t.Error("la comida no aplicó el aura 'bien alimentado'")
	}
}

// TestDoTSobreEnemigo verifica que un DoT aplicado a un mob le hace daño
// por tick, con el crédito de muerte atribuido al origen (un jugador real).
func TestDoTSobreEnemigo(t *testing.T) {
	m := nuevoMundoTest(t)
	origen := crearJugadorTest(t, m, "origen", "guerrero", "alianza", "humano")
	e := nuevoEnemigo("lobo test", "lobo", 5, proto.Vec3{})
	// Dar HP suficiente para sobrevivir varios ticks de 60.
	e.hpMax = 1000
	e.hpActual = 1000
	hpInicial := e.hpActual

	ahora := int64(1000)
	def := auras.CatalogoAuras()["sangrado"] // 60 daño/tick cada 3s
	e.aplicarAuraEnemigo(def, origen.ID(), ahora)
	if len(e.auras) != 1 {
		t.Fatalf("DoT no se aplicó al enemigo (auras=%d)", len(e.auras))
	}
	// Avanzar 3s + 1ms y tickar.
	e.tickAurasPeriodicosEnemigo(m, ahora+3001)
	if e.hpActual != hpInicial-60 {
		t.Errorf("tras 1 tick: HP=%d esperaba %d (-60)", e.hpActual, hpInicial-60)
	}
	if e.ultimoAtacanteID != origen.ID() {
		t.Errorf("crédito de muerte=%q esperaba %s", e.ultimoAtacanteID, origen.ID())
	}
	// Segundo tick.
	e.tickAurasPeriodicosEnemigo(m, ahora+6001)
	if e.hpActual != hpInicial-120 {
		t.Errorf("tras 2 ticks: HP=%d esperaba %d (-120)", e.hpActual, hpInicial-120)
	}
}

// TestAuraDanoPctAumentaDano verifica que un frasco de +dano_pct incrementa
// el daño calculado respecto al mismo jugador sin el aura.
func TestAuraDanoPctAumentaDano(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "lock", "brujo", "horda", "no-muerto")
	base := 100
	sinAura := j.calcularDaño(base)
	j.aplicarAura(auras.CatalogoAuras()["frasco_iracolosal"], "test", 1000, m)
	conAura := j.calcularDaño(base)
	if conAura <= sinAura {
		t.Errorf("daño con frasco %d no supera al sin frasco %d", conAura, sinAura)
	}
	// +10% (dano_pct=100 → +0.10 al mult). Permitir tolerancia por redondeo.
	esperado := float64(sinAura) * 1.10
	if float64(conAura) < esperado*0.95 || float64(conAura) > esperado*1.05 {
		t.Errorf("daño con aura %d no está cerca de +10%% de %d (≈%.0f)", conAura, sinAura, esperado)
	}
}

// TestFrascosSobrevivenMuerte verifica que al morir se eliminan los
// elixires/comida pero los frascos persisten.
func TestFrascosSobrevivenMuerte(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "paladin", "paladín", "alianza", "humano")
	j.aplicarAura(auras.CatalogoAuras()["frasco_iracolosal"], "test", 1000, m)
	j.aplicarAura(auras.CatalogoAuras()["elixir_agilidad_poderosa"], "test", 1000, m)
	j.aplicarAura(auras.CatalogoAuras()["comida_rinoceronte"], "test", 1000, m)
	if len(j.auras) != 3 {
		t.Fatalf("setup: esperaba 3 auras, hay %d", len(j.auras))
	}
	j.limpiarAurasAlMorir(m)
	if !auraActivaDice(j, "frasco_iracolosal") {
		t.Error("el frasco debería sobrevivir a la muerte")
	}
	if auraActivaDice(j, "elixir_agilidad_poderosa") {
		t.Error("el elixir NO debería sobrevivir a la muerte")
	}
	if auraActivaDice(j, "comida_rinoceronte") {
		t.Error("la comida NO debería sobrevivir a la muerte")
	}
}

// TestPersistenciaAurasSoloFrascos verifica que aurasParaPersist solo
// guarda frascos, y cargarAurasDesdePersist los restaura (descartando los
// ya expirados).
func TestPersistenciaAurasSoloFrascos(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "dk", "caballero_de_la_muerte", "horda", "orco")
	ahora := int64(1_000_000)
	j.aplicarAura(auras.CatalogoAuras()["frasco_sangre_piedra"], "frasco_item", ahora, m)
	j.aplicarAura(auras.CatalogoAuras()["elixir_proteccion"], "elixir_item", ahora, m)

	guardadas := j.aurasParaPersist()
	if len(guardadas) != 1 {
		t.Fatalf("persist guardó %d auras, esperaba 1 (solo frasco)", len(guardadas))
	}
	if guardadas[0].DefID != "frasco_sangre_piedra" {
		t.Errorf("persist guardó %q, esperaba frasco_sangre_piedra", guardadas[0].DefID)
	}

	// Cargar en un jugador nuevo: solo el frasco debería restaurarse.
	j2 := crearJugadorTest(t, m, "dk2", "caballero_de_la_muerte", "horda", "orco")
	j2.cargarAurasDesdePersist(guardadas, m, ahora+5000) // 5s después, no expirado
	if !auraActivaDice(j2, "frasco_sangre_piedra") {
		t.Error("el frasco no se restauró al cargar")
	}
	// Y el HP buffeado debe estar presente en el max.
	hpBase := j2.hpMax - 1300
	if hpBase <= 0 {
		t.Errorf("hpMax=%d sospechosamente bajo tras cargar frasco", j2.hpMax)
	}
}

// TestCargarAurasDescartaExpiradas verifica que una aura guardada cuyo
// FinMs ya pasó al cargar NO se restaura (expiró offline).
func TestCargarAurasDescartaExpiradas(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "druida", "druida", "alianza", "elfo_de_la_noche")
	guardadas := []persistencia.AuraPersist{{
		DefID: "frasco_iracolosal", FinMs: 1000, // expiró hace tiempo
	}}
	j.cargarAurasDesdePersist(guardadas, m, 10_000_000)
	if len(j.auras) != 0 {
		t.Errorf("auras tras cargar expiradas=%d esperaba 0", len(j.auras))
	}
}
