// masmorras_test.go valida el catálogo completo de masmorras (Classic + TBC
// + WotLK), el desbloqueo progresivo por nivel, el loot mejorado de bosses,
// la recompensa de completar, y el no-respawn de mobs de instancia.
package mundo

import (
	"testing"
	"time"

	"aethelgard/servidor/interno/proto"
)

// TestCatalogoMasmorras valida el catálogo completo de masmorras.
func TestCatalogoMasmorras(t *testing.T) {
	m := nuevoMundoTest(t)
	if len(m.masmoras) < 40 {
		t.Errorf("catálogo de masmorras = %d, esperaba ≥40", len(m.masmoras))
	}
	vistos := map[string]bool{}
	for id, def := range m.masmoras {
		if id != def.ID {
			t.Errorf("masmora %q: ID mismatch %q", id, def.ID)
		}
		if vistos[id] {
			t.Errorf("masmora duplicada %q", id)
		}
		vistos[id] = true
		if def.NivelMin < 1 || def.NivelMin > NivelMax {
			t.Errorf("masmora %s NivelMin inválido %d", id, def.NivelMin)
		}
		if def.NivelMax < def.NivelMin || def.NivelMax > NivelMax {
			t.Errorf("masmora %s NivelMax inválido %d (min %d)", id, def.NivelMax, def.NivelMin)
		}
		if def.TamanoGrupo != 5 && def.TamanoGrupo != 10 {
			t.Errorf("masmora %s TamanoGrupo inválido %d", id, def.TamanoGrupo)
		}
		if def.PosSpawn.X < OffsetXPlanoMasmorras {
			t.Errorf("masmora %s PosSpawn.X=%v debe ser ≥%v (plano aislado)", id, def.PosSpawn.X, OffsetXPlanoMasmorras)
		}
		// Cada masmora tiene exactamente 1 boss y ≥3 mobs.
		bosses := 0
		for _, sm := range def.Mobs {
			if sm.EsBoss {
				bosses++
			}
		}
		if bosses != 1 {
			t.Errorf("masmora %s: %d bosses, esperaba 1", id, bosses)
		}
		if len(def.Mobs) < 4 {
			t.Errorf("masmora %s: %d mobs, esperaba ≥4", id, len(def.Mobs))
		}
	}
	// Algunas masmorras representativas de cada expansión.
	cases := []struct {
		id                            string
		nivelMin, nivelMax, tamano    int
	}{
		{"sima_ignea", 13, 20, 5},
		{"las_minas_de_la_muerte", 17, 23, 5},
		{"profundidades_de_roca_negra", 48, 60, 5},
		{"cumbre_de_roca_negra_superior", 58, 60, 10}, // 10-man
		{"murallas_del_fuego_infernal", 60, 62, 5},     // TBC
		{"bancal_del_magister", 70, 70, 5},             // TBC lvl 70
		{"fortaleza_de_utgarde", 70, 72, 5},            // WotLK
		{"salas_de_relampagos", 79, 80, 5},             // WotLK
		{"el_exterminio_de_stratholme", 80, 80, 5},     // WotLK lvl 80
	}
	for _, c := range cases {
		def, ok := m.masmoras[c.id]
		if !ok {
			t.Errorf("masmora %s no existe en el catálogo", c.id)
			continue
		}
		if def.NivelMin != c.nivelMin || def.NivelMax != c.nivelMax {
			t.Errorf("masmora %s: nivel %d-%d, esperaba %d-%d", c.id, def.NivelMin, def.NivelMax, c.nivelMin, c.nivelMax)
		}
		if def.TamanoGrupo != c.tamano {
			t.Errorf("masmora %s: TamanoGrupo %d, esperaba %d", c.id, def.TamanoGrupo, c.tamano)
		}
	}
}

// TestDesbloqueoProgresivoNivel valida que MasmorrasDisponibles crece
// monótonamente con el nivel (desbloqueo progresivo).
func TestDesbloqueoProgresivoNivel(t *testing.T) {
	m := nuevoMundoTest(t)
	b := m.Buscador()
	prev := 0
	for nivel := 1; nivel <= NivelMax; nivel += 5 {
		disp := b.MasmorrasDisponibles(nivel)
		if len(disp) < prev {
			t.Errorf("nivel %d: %d disponibles < %d del nivel anterior (no monótono)", nivel, len(disp), prev)
		}
		prev = len(disp)
		// Todas las devueltas deben tener NivelMin <= nivel.
		for _, d := range disp {
			if d.NivelMin > nivel {
				t.Errorf("nivel %d: masmora %s (NivelMin %d) no debería estar disponible", nivel, d.ID, d.NivelMin)
			}
		}
	}
	// A lvl 80 están todas disponibles.
	todas := b.MasmorrasDisponibles(NivelMax)
	if len(todas) != len(m.masmoras) {
		t.Errorf("nivel 80: %d disponibles, esperaba %d (todas)", len(todas), len(m.masmoras))
	}
	// A lvl 1 no hay ninguna (la mínima es Sima Ígnea lvl 13).
	if len(b.MasmorrasDisponibles(1)) != 0 {
		t.Error("nivel 1 debería tener 0 masmorras disponibles")
	}
	// La lista está ordenada por NivelMin.
	for i := 1; i < len(todas); i++ {
		if todas[i].NivelMin < todas[i-1].NivelMin {
			t.Error("MasmorrasDisponibles no está ordenada por NivelMin")
			break
		}
	}
}

// TestEntrarColaNivelInsuficiente valida el gate de desbloqueo por nivel.
func TestEntrarColaNivelInsuficiente(t *testing.T) {
	m := nuevoMundoTest(t)
	// Deadmines NivelMin 17: un lvl 16 no puede, un lvl 17 sí.
	j16 := crearJugadorTest(t, m, "Bajo", "guerrero", FaccionAlianza, "humano")
	j16.nivel = 16
	if err := m.Buscador().EntrarColaPvE(j16, "las_minas_de_la_muerte"); err == nil {
		t.Error("lvl 16 debería NO poder entrar a Deadmines (NivelMin 17)")
	}
	j17 := crearJugadorTest(t, m, "Justo", "guerrero", FaccionAlianza, "humano")
	j17.nivel = 17
	if err := m.Buscador().EntrarColaPvE(j17, "las_minas_de_la_muerte"); err != nil {
		t.Errorf("lvl 17 debería poder entrar a Deadmines: %v", err)
	}
}

// TestBossLootMejorado valida que el boss da más oro y drop de equipo
// garantizado, frente a un trash mob del mismo nivel.
func TestBossLootMejorado(t *testing.T) {
	m := nuevoMundoTest(t)
	jBoss := crearJugadorTest(t, m, "MatadorBoss", "cazador", FaccionAlianza, "humano")
	jTrash := crearJugadorTest(t, m, "MatadorTrash", "cazador", FaccionAlianza, "humano")
	// Un boss lvl 23 humanoide y un trash lvl 23 humanoide.
	boss := nuevoEnemigo("Edwin VanCleef", "humanoide", 23, proto.Vec3{})
	boss.esBoss = true
	trash := nuevoEnemigo("Súbdito", "humanoide", 23, proto.Vec3{})

	m.mu.Lock()
	oroBossIni := jBoss.oro
	boss.ultimoAtacanteID = jBoss.id
	m.otorgarLootMuerte(jBoss.id, boss)
	oroBoss := jBoss.oro - oroBossIni

	oroTrashIni := jTrash.oro
	trash.ultimoAtacanteID = jTrash.id
	m.otorgarLootMuerte(jTrash.id, trash)
	oroTrash := jTrash.oro - oroTrashIni
	m.mu.Unlock()

	// El boss da ≥5× el oro del trash (multOro=5).
	if oroBoss <= oroTrash {
		t.Errorf("oro boss=%d no supera al trash=%d (esperaba ×5)", oroBoss, oroTrash)
	}
	// El boss garantiza un drop de equipo: el inventario del matador del boss
	// tiene al menos un ítem equipable. El trash (1 kill, 3%) probablemente no.
	equipoBoss := 0
	m.mu.RLock()
	for id := range jBoss.inventario {
		if it, ok := m.items[id]; ok && it.Equipable {
			equipoBoss++
		}
	}
	m.mu.RUnlock()
	if equipoBoss == 0 {
		t.Error("boss no soltó ningún ítem equipable (debería ser garantizado)")
	}
}

// TestFamiliaDragonLoot valida que la familia dragon suelta escamas.
func TestFamiliaDragonLoot(t *testing.T) {
	tabla := lootTablePorFamilia("dragon")
	if len(tabla.Entradas) == 0 {
		t.Fatal("familia dragon sin entradas de loot")
	}
	if tabla.Entradas[0].ItemID != "escamas_dragon_desgastadas" {
		t.Errorf("familia dragon suelta %s, esperaba escamas_dragon_desgastadas", tabla.Entradas[0].ItemID)
	}
}

// TestRecompensaCompletarMasmora valida que derrotar al boss finaliza la
// instancia con victoria y da XP + oro bonus a cada miembro del grupo.
func TestRecompensaCompletarMasmora(t *testing.T) {
	m := nuevoMundoTest(t)
	// Grupo 5-man para Deadmines (NivelMin 17).
	js := []*Jugador{
		crearJugadorTest(t, m, "T5", "guerrero", FaccionAlianza, "humano"),
		crearJugadorTest(t, m, "H5", "sacerdote", FaccionHorda, "no_muerto"),
		crearJugadorTest(t, m, "D51", "mago", FaccionAlianza, "gnomo"),
		crearJugadorTest(t, m, "D52", "cazador", FaccionHorda, "troll"),
		crearJugadorTest(t, m, "D53", "picaro", FaccionAlianza, "elfo_noche"),
	}
	for _, j := range js {
		j.nivel = 18
	}
	for _, j := range js {
		if err := m.Buscador().EntrarColaPvE(j, "las_minas_de_la_muerte"); err != nil {
			t.Fatalf("entrar %s: %v", j.nombre, err)
		}
	}
	m.Buscador().procesar(time.Now())

	m.mu.RLock()
	var inst *Instancia
	for _, in := range m.instancias {
		inst = in
	}
	m.mu.RUnlock()
	if inst == nil {
		t.Fatal("no se creó la instancia")
	}

	// Registrar XP/oro antes de matar al boss.
	xpAntes := make(map[string]int, len(js))
	oroAntes := make(map[string]int, len(js))
	for _, j := range js {
		xpAntes[j.id] = xpTotalJugador(j)
		oroAntes[j.id] = j.oro
	}

	// Matar al boss de un golpe (crédito al tanque). Usar un timestamp real
	// no nulo: EstaVivo() se basa en muertoDesdeMs==0, así que ahora=0 lo
	// dejaría aparentemente "vivo".
	ahoraKill := time.Now().UnixMilli()
	m.mu.Lock()
	boss := m.enemigos[inst.bossID]
	boss.ultimoAtacanteID = js[0].id
	boss.recibirDaño(js[0].id, boss.hpActual, false, m, ahoraKill)
	m.mu.Unlock()
	if boss.EstaVivo() {
		t.Fatal("el boss no murió")
	}

	// Tick de la instancia → debe finalizar con victoria y dar recompensas.
	m.mu.Lock()
	inst.tick(m, time.Now())
	m.mu.Unlock()

	// Cada jugador debe haber recibido XP + oro bonus.
	bossNivel := 23
	xpEsperado := bossNivel * 40
	oroEsperado := bossNivel * 15
	for _, j := range js {
		ganadoXP := xpTotalJugador(j) - xpAntes[j.id]
		if ganadoXP < xpEsperado {
			t.Errorf("%s: XP ganada %d < bonus esperado %d", j.nombre, ganadoXP, xpEsperado)
		}
		ganadoOro := j.oro - oroAntes[j.id]
		if ganadoOro < oroEsperado {
			t.Errorf("%s: oro ganado %d < bonus esperado %d", j.nombre, ganadoOro, oroEsperado)
		}
	}
	// La instancia se devolvió al mundo abierto.
	for _, j := range js {
		if j.instanciaID != "" {
			t.Errorf("%s sigue en instancia tras finalizar", j.nombre)
		}
	}
}

// TestNoRespawnInstancia valida que los mobs de instancia NO respawnean
// (los del mundo abierto sí). Tras morir y pasar el tiempo de respawn, el
// mob de instancia sigue muerto.
func TestNoRespawnInstancia(t *testing.T) {
	m := nuevoMundoTest(t)
	// Un mob de instancia (instanciaID != "") y uno del mundo abierto.
	instMob := nuevoEnemigo("Súbdito inst", "humanoide", 20, proto.Vec3{X: 10500, Y: 0, Z: 0})
	instMob.id = "inst_test_mob"
	instMob.instanciaID = "inst_test"
	worldMob := nuevoEnemigo("Lobo mundo", "lobo", 2, proto.Vec3{X: -3000, Y: 0, Z: 0})
	worldMob.id = "world_test_mob"
	m.mu.Lock()
	m.entidades[instMob.id] = instMob
	m.enemigos[instMob.id] = instMob
	m.entidades[worldMob.id] = worldMob
	m.enemigos[worldMob.id] = worldMob
	// Matar ambos.
	ahora := time.Now().UnixMilli()
	instMob.hpActual = 0
	instMob.muertoDesdeMs = ahora
	worldMob.hpActual = 0
	worldMob.muertoDesdeMs = ahora
	// Tick muy posterior al respawn (30s + margen).
	futuro := time.UnixMilli(ahora + RespawnEnemigoMs + 5000)
	instMob.actualizar(m, futuro)
	worldMob.actualizar(m, futuro)
	m.mu.Unlock()
	if instMob.EstaVivo() {
		t.Error("mob de instancia respawneó (no debería)")
	}
	if !worldMob.EstaVivo() {
		t.Error("mob del mundo abierto no respawneó (debería)")
	}
}
