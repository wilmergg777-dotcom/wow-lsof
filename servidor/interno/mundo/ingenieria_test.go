// ingenieria_test.go valida la profesión de Ingeniería: catálogo completo
// (42 recetas, 6 rangos, 2 especializaciones), las cadenas de productos
// intermedios (pólvoras → bombas, tornillos → bombas/mosquetes, tubos →
// gadgets, capacitor → señuelo), las recetas "pure-material" del escalón
// TBC 300-310 (craftean sin dar skill), la cadena completa 0-450 y la
// especialización binaria Goblin / Gnómica.
package mundo

import (
	"testing"
)

// TestRecetasIngenieriaCompletas valida el catálogo de Ingeniería.
func TestRecetasIngenieriaCompletas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("ingenieria")
	if !ok {
		t.Fatal("ingenieria no existe")
	}
	if len(p.Recetas) != 42 {
		t.Errorf("recetas de ingenieria = %d, esperaba 42", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos de ingenieria = %d, esperaba 6", len(p.Rangos))
	}
	if len(p.Especializaciones) != 2 {
		t.Errorf("especializaciones de ingenieria = %d, esperaba 2", len(p.Especializaciones))
	}
	// Debe haber recetas "pure-material" (SkillReq == SkillHasta, sin skill)
	// para el escalón TBC 300-310.
	pureMaterial := 0
	for _, r := range p.Recetas {
		if r.SkillReq == r.SkillHasta {
			pureMaterial++
		}
	}
	if pureMaterial < 2 {
		t.Errorf("esperaba al menos 2 recetas pure-material (tornillos/pólvora elemental TBC), hay %d", pureMaterial)
	}
	// Debe producir explosivos, armas y al menos un gadget/gafa.
	tipos := map[string]bool{}
	for _, r := range p.Recetas {
		if d, ok := m.Item(r.ResultadoID); ok {
			tipos[d.Tipo] = true
		}
	}
	if !tipos[TipoExplosivo] {
		t.Errorf("ingenieria debería producir explosivos (bombas/bengalas)")
	}
	if !tipos[TipoArma] {
		t.Errorf("ingenieria debería producir armas (trabucos/mosquetes)")
	}
	if !tipos[TipoArmadura] {
		t.Errorf("ingenieria debería producir gafas (armadura de cabeza)")
	}
}

// TestAprenderIngenieria valida el aprendizaje inicial.
func TestAprenderIngenieria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Ingeniero", "mago", FaccionAlianza, "gnomo")
	res := j.AprenderProfesion(m, "ingenieria")
	if !res.OK {
		t.Fatalf("aprender ingenieria: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if j.AprenderProfesion(m, "ingenieria").OK {
		t.Errorf("no debería poder aprender ingenieria dos veces")
	}
}

// TestCadenasIngenieria valida que los intermedios se producen y luego se
// consumen en recetas posteriores (pólvora_basta → trabuco, capacitor →
// señuelo), y que las recetas "pure-material" del escalón TBC producen el
// item sin dar skill.
func TestCadenasIngenieria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Ingeniero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "ingenieria")
	j.AprenderRango(m, "ingenieria", "gran_maestro")

	// Cadena 1: pólvora_basta (intermedio) → consumida por trabuco_basto.
	j.profesiones["ingenieria"].Skill = 65
	j.AgregarItem("piedra_basta", 2)
	j.AgregarItem("lingote_cobre", 2)
	// Craftear pólvora_basta y tubo_cobre como materiales (skill 65 > sus
	// bandas, así que no dan skill pero producen el item).
	for i := 0; i < 2; i++ {
		if res := j.Craftear(m, "pólvora_basta"); !res.OK {
			t.Fatalf("craftear pólvora_basta #%d: %s", i, res.Error)
		}
		if res := j.Craftear(m, "tubo_cobre"); !res.OK {
			t.Fatalf("craftear tubo_cobre #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("pólvora_basta") != 2 || j.CantidadItem("tubo_cobre") != 2 {
		t.Errorf("intermedios: pólvora=%d tubo=%d, esperaba 2/2", j.CantidadItem("pólvora_basta"), j.CantidadItem("tubo_cobre"))
	}
	// Craftear trabuco: consume tubo_cobre + pólvora_basta.
	for i := 0; i < 2; i++ {
		if res := j.Craftear(m, "trabuco_basto"); !res.OK {
			t.Fatalf("craftear trabuco_basto #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("pólvora_basta") != 0 || j.CantidadItem("tubo_cobre") != 0 {
		t.Errorf("los intermedios no se consumieron: pólvora=%d tubo=%d", j.CantidadItem("pólvora_basta"), j.CantidadItem("tubo_cobre"))
	}

	// Cadena 2: capacitor_sobrecargado (intermedio) → consumido por
	// señuelo_explosivo.
	j.profesiones["ingenieria"].Skill = 385
	j.AgregarItem("barra_cobalto", 4)
	j.AgregarItem("fuego_cristalizado", 2)
	j.AgregarItem("paño_escarcha", 2)
	for i := 0; i < 2; i++ {
		if res := j.Craftear(m, "capacitor_sobrecargado"); !res.OK {
			t.Fatalf("craftear capacitor #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("capacitor_sobrecargado") != 2 {
		t.Errorf("capacitor = %d, esperaba 2", j.CantidadItem("capacitor_sobrecargado"))
	}
	for i := 0; i < 2; i++ {
		if res := j.Craftear(m, "señuelo_explosivo"); !res.OK {
			t.Fatalf("craftear señuelo #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("capacitor_sobrecargado") != 0 {
		t.Errorf("el capacitor no se consumió: queda %d", j.CantidadItem("capacitor_sobrecargado"))
	}

	// Pure-material: tornillos_hierro_vil (SkillReq==SkillHasta==300) debe
	// producir el item SIN dar skill.
	j.profesiones["ingenieria"].Skill = 300
	j.AgregarItem("barra_hierro_vil", 1)
	skillAntes := j.profesiones["ingenieria"].Skill
	res := j.Craftear(m, "tornillos_hierro_vil")
	if !res.OK {
		t.Fatalf("craftear tornillos_hierro_vil: %s", res.Error)
	}
	if res.SubioSkill {
		t.Errorf("tornillos_hierro_vil es pure-material y no debería dar skill")
	}
	if j.profesiones["ingenieria"].Skill != skillAntes {
		t.Errorf("skill cambió a %d, esperaba %d (pure-material)", j.profesiones["ingenieria"].Skill, skillAntes)
	}
	if j.CantidadItem("tornillos_hierro_vil") != 1 {
		t.Errorf("tornillos_hierro_vil = %d, esperaba 1 (se produce aunque no dé skill)", j.CantidadItem("tornillos_hierro_vil"))
	}
}

// subirIngenieriaA450 sube la habilidad de ingeniería a 450 crafteando la
// secuencia completa de la guía, incluyendo la fabricación en masa de
// intermedios (pólvoras, tornillos, tubos, envolturas, capacitor) donde
// muchos crafteos no dan skill (son material para recetas posteriores).
func subirIngenieriaA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	for id, n := range map[string]int{
		"piedra_basta": 62, "lingote_cobre": 50, "piedra_burda": 33, "lingote_plata": 10,
		"lingote_bronce": 69, "paño_lana": 15, "piedra_pesada": 75, "cuero_pesado": 61,
		"lingote_acero": 4, "piedra_sólida": 100, "lingote_hierro": 21, "lingote_mitril": 110,
		"tela_paño_mágico": 5, "piedra_densa": 44, "lingote_torio": 168, "paño_rúnico": 32,
		"barra_hierro_vil": 220, "paño_tejido_abisal": 52, "barra_cobalto": 280, "barra_de_saronita": 555,
		"paño_escarcha": 7, "agua_cristalizada": 68, "fuego_cristalizado": 15,
		"tierra_cristalizada": 10, "tierra_eterna": 5,
	} {
		j.AgregarItem(id, n)
	}
	crafts := func(receta string, n int) {
		for i := 0; i < n; i++ {
			res := j.Craftear(m, receta)
			if !res.OK {
				t.Fatalf("craftear %s #%d (skill=%d): %s", receta, i, j.profesiones["ingenieria"].Skill, res.Error)
			}
		}
	}
	aprende := func(rango string) {
		res := j.AprenderRango(m, "ingenieria", rango)
		if !res.OK {
			t.Fatalf("aprender rango %s (skill=%d): %s", rango, j.profesiones["ingenieria"].Skill, res.Error)
		}
	}
	// Classic 1-75 (aprendiz): pólvora/tornillos → tubo → trabuco
	crafts("pólvora_basta", 40)        // 0→40 (40 intermedios, solo 10 se consumen)
	crafts("tornillos_cobre", 14)      // 40→54
	crafts("llave_arcoluz", 1)         // 54→55
	crafts("tubo_cobre", 10)           // 55→65 (10, consumidos por trabuco)
	crafts("trabuco_basto", 10)        // 65→75 (consume tubo_cobre + pólvora_basta)
	aprende("oficial")
	// 75-150 (oficial): pólvora burda → bombas de bronce
	crafts("pólvora_burda", 20)        // 75→95
	crafts("contacto_plata", 10)       // 95→105
	crafts("tubo_bronce", 15)          // 105→120
	crafts("bomba_bronce_pequeña", 5)  // 120→125 (consume tubo+tornillos+pólvora+paño)
	crafts("pólvora_pesada", 20)       // 125→145
	crafts("bomba_bronce_grande", 5)   // 145→150 (consume tubo+pólvora+paño)
	aprende("experto")
	// 150-225 (experto)
	crafts("fuego_artificial_rojo", 25) // 150→175
	crafts("microajustador_giromático", 1) // 175→176
	crafts("pólvora_sólida", 30)        // 176→190 + 16 como material (para bomba_hierro, disparador, bomba_gran_carga, girotiro)
	crafts("bomba_hierro_grande", 5)    // 190→195
	crafts("tubo_mitril", 10)           // 195→205
	crafts("disparador_inestable", 5)   // 205→210
	crafts("balas_mitril_gran_impacto", 15) // 210→225
	aprende("artesano")
	// 225-300 (artesano)
	crafts("envoltura_mitril", 10)      // 225→235 (consumidos por bomba_gran_carga)
	crafts("bomba_gran_carga", 10)      // 235→245 (consume envoltura + pólvora_sólida)
	crafts("girotiro_mitril", 5)        // 245→250
	crafts("pólvora_densa", 30)         // 250→260 + 20 como material (para trastos_wow)
	crafts("trastos_wow_torio", 30)     // 260→290 (consume torio + pólvora_densa + paño_rúnico)
	crafts("tubo_torio", 10)            // 290→300
	aprende("maestro")
	// 300-350 (TBC): escalón 300-310 con fabricación en masa de intermedios
	crafts("envoltura_hierro_vil", 25)  // 300→310 + 15 como material (bomba + mosquete)
	crafts("tornillos_hierro_vil", 65)  // pure-material (bomba + mosquete + bengala)
	crafts("pólvora_elemental", 40)     // pure-material (bomba + mosquete + bengala)
	crafts("bomba_hierro_vil", 10)      // 310→320
	crafts("mosquete_hierro_vil", 15)   // 320→335
	crafts("bengala_humo_blanco", 15)   // 335→350
	aprende("gran_maestro")
	// 350-450 (WotLK)
	crafts("tornillos_cobalto", 15)     // 350→360 + 5 como material (navaja_ejército)
	crafts("gatillo_explosivo_volátil", 15) // 360→375 (5 consumidos por caja_de_bombas)
	crafts("capacitor_sobrecargado", 10) // 375→385 (5 consumidos por señuelo)
	crafts("señuelo_explosivo", 5)      // 385→390
	crafts("tubo_acero_frío", 30)       // 390→400 + 20 como material (scope/soldador/inyector/gafas/ruido)
	crafts("mira_refractora_diamante", 5) // 400→405
	crafts("caja_de_bombas", 5)         // 405→410
	crafts("soldador_rayo_goblin", 5)   // 410→415
	crafts("kit_inyector_mana", 10)     // 415→425
	crafts("gafas_nieve_mecanizadas", 5) // 425→430
	crafts("máquina_ruido", 5)          // 430→435
	crafts("navaja_ejército_gnómica", 15) // 435→450
	if j.profesiones["ingenieria"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["ingenieria"].Skill)
	}
}

// TestSubirIngenieriaCompleto valida la cadena completa 0→450, incluyendo
// las cadenas de intermedios y el escalón TBC 300-310 con pure-material.
func TestSubirIngenieriaCompleto(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Ingeniero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "ingenieria")
	subirIngenieriaA450(t, m, j)
	// La Navaja del ejército gnómico (producto final épico) debe estar.
	if j.CantidadItem("navaja_ejército_gnómica") != 15 {
		t.Errorf("navaja ejército gnómico = %d, esperaba 15", j.CantidadItem("navaja_ejército_gnómica"))
	}
	// El trabuco_basto (arma del inicio) se crafteó y NO se consumió.
	if j.CantidadItem("trabuco_basto") != 10 {
		t.Errorf("trabuco basto = %d, esperaba 10", j.CantidadItem("trabuco_basto"))
	}
}

// TestEspecializacionesIngenieria valida la especialización binaria: elegir
// Goblin bloquea Gnómica (y viceversa), y consume los materiales de misión.
func TestEspecializacionesIngenieria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Ingeniero", "mago", FaccionHorda, "no-muerto")
	j.AprenderProfesion(m, "ingenieria")
	j.AprenderRango(m, "ingenieria", "artesano")
	j.profesiones["ingenieria"].Skill = 200
	// Materiales de Goblin: 20 Bomba de hierro grande + 20 Dinamita sólida + 5 Oveja explosiva
	j.AgregarItem("bomba_hierro_grande", 20)
	j.AgregarItem("dinamita_sólida", 20)
	j.AgregarItem("oveja_explosiva", 5)
	if res := j.AprenderEspecializacion(m, "ingenieria", "goblin"); !res.OK {
		t.Fatalf("aprender ingeniería goblin: %s", res.Error)
	}
	if j.profesiones["ingenieria"].Especializacion != "goblin" {
		t.Errorf("estado = %q, esperaba goblin", j.profesiones["ingenieria"].Especializacion)
	}
	// Los materiales se consumieron.
	if j.CantidadItem("bomba_hierro_grande") != 0 || j.CantidadItem("dinamita_sólida") != 0 || j.CantidadItem("oveja_explosiva") != 0 {
		t.Errorf("los materiales de Goblin no se consumieron")
	}
	// No se puede aprender Gnómica después (especialización binaria).
	j.AgregarItem("tubo_mitril", 6)
	j.AgregarItem("mira_precisión", 1)
	j.AgregarItem("muñeco_diana_avanzado", 2)
	if j.AprenderEspecializacion(m, "ingenieria", "gnómica").OK {
		t.Errorf("no debería poder aprender gnómica teniendo ya goblin")
	}
	// Skill insuficiente (200 es el req, pero probamos con skill baja).
	j2 := crearJugadorTest(t, m, "Ingeniero2", "mago", FaccionAlianza, "gnomo")
	j2.AprenderProfesion(m, "ingenieria")
	j2.AprenderRango(m, "ingenieria", "oficial")
	j2.profesiones["ingenieria"].Skill = 150
	j2.AgregarItem("tubo_mitril", 6)
	j2.AgregarItem("mira_precisión", 1)
	j2.AgregarItem("muñeco_diana_avanzado", 2)
	if j2.AprenderEspecializacion(m, "ingenieria", "gnómica").OK {
		t.Errorf("no debería poder aprender gnómica con skill 150 (req 200)")
	}
}

// TestPersistenciaIngenieria valida que la profesión y la especialización
// se guardan y cargan tras subir a 450 y elegir Ingeniería goblin.
func TestPersistenciaIngenieria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Ingeniero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "ingenieria")
	subirIngenieriaA450(t, m, j)
	j.AgregarItem("bomba_hierro_grande", 20)
	j.AgregarItem("dinamita_sólida", 20)
	j.AgregarItem("oveja_explosiva", 5)
	if res := j.AprenderEspecializacion(m, "ingenieria", "goblin"); !res.OK {
		t.Fatalf("aprender goblin: %s", res.Error)
	}
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Ingeniero")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "ingenieria" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	if p.Profesiones[0].Especializacion != "goblin" {
		t.Errorf("especializacion persistida = %q, esperaba goblin", p.Profesiones[0].Especializacion)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["ingenieria"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["ingenieria"].Skill)
	}
	if j2.profesiones["ingenieria"].Especializacion != "goblin" {
		t.Errorf("especializacion tras carga = %q, esperaba goblin", j2.profesiones["ingenieria"].Especializacion)
	}
}
