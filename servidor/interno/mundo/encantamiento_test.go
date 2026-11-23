// encantamiento_test.go valida la profesión de Encantamiento: catálogo
// completo (43 recetas, 6 rangos, sin especializaciones), la cadena de
// varas rúnicas (cada una consume la anterior) y el crafteo 0-450.
package mundo

import (
	"testing"
)

// TestRecetasEncantamientoCompletas valida el catálogo de Encantamiento.
func TestRecetasEncantamientoCompletas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("encantamiento")
	if !ok {
		t.Fatal("encantamiento no existe")
	}
	if len(p.Recetas) != 43 {
		t.Errorf("recetas de encantamiento = %d, esperaba 43", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos de encantamiento = %d, esperaba 6", len(p.Rangos))
	}
	if len(p.Especializaciones) != 0 {
		t.Errorf("encantamiento no debe tener especializaciones, tiene %d", len(p.Especializaciones))
	}
	if p.Recetas[0].SkillReq != 0 {
		t.Errorf("primera receta req = %d, esperaba 0 (vara de cobre rúnico)", p.Recetas[0].SkillReq)
	}
	if p.Recetas[len(p.Recetas)-1].SkillHasta != 450 {
		t.Errorf("última receta hasta = %d, esperaba 450", p.Recetas[len(p.Recetas)-1].SkillHasta)
	}
	// Debe haber exactamente 9 varas rúnicas.
	varas := 0
	for _, r := range p.Recetas {
		if d, ok := m.Item(r.ResultadoID); ok && d.Tipo == TipoVara {
			varas++
		}
	}
	if varas != 9 {
		t.Errorf("varas rúnicas = %d, esperaba 9", varas)
	}
}

// TestAprenderEncantamiento valida el aprendizaje inicial.
func TestAprenderEncantamiento(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Encantador", "mago", FaccionAlianza, "humano")
	res := j.AprenderProfesion(m, "encantamiento")
	if !res.OK {
		t.Fatalf("aprender encantamiento: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if j.AprenderProfesion(m, "encantamiento").OK {
		t.Errorf("no debería poder aprender encantamiento dos veces")
	}
}

// TestCraftearEncantamiento valida el crafteo de un encantamiento: consume
// materiales, produce el encantamiento y sube la habilidad.
func TestCraftearEncantamiento(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Encantador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "encantamiento")
	// Vara de cobre rúnico primero (req 1, hasta 2).
	j.AgregarItem("vara_cobre", 1)
	j.AgregarItem("esencia_mágica_inferior", 1)
	res := j.Craftear(m, "vara_cobre_rúnico")
	if !res.OK {
		t.Fatalf("craftear vara de cobre rúnico: %s", res.Error)
	}
	if j.CantidadItem("vara_cobre_rúnico") != 1 {
		t.Errorf("vara de cobre rúnico = %d, esperaba 1", j.CantidadItem("vara_cobre_rúnico"))
	}
	// Encantar brazal: salud menor (req 2, hasta 75, mats {polvo_extraño:1}).
	j.AgregarItem("polvo_extraño", 10)
	for i := 0; i < 10; i++ {
		res := j.Craftear(m, "encanto_brazal_salud_menor")
		if !res.OK {
			t.Fatalf("crafteo %d falló: %s", i, res.Error)
		}
	}
	if j.CantidadItem("encanto_brazal_salud_menor") != 10 {
		t.Errorf("encantamientos = %d, esperaba 10", j.CantidadItem("encanto_brazal_salud_menor"))
	}
	if j.CantidadItem("polvo_extraño") != 0 {
		t.Errorf("polvo_extraño restante = %d, esperaba 0", j.CantidadItem("polvo_extraño"))
	}
}

// TestCadenaVarasRúnicas valida que las varas rúnicas se encadenan: cada
// una consume la anterior. Tras craftear las 9 en orden, solo debe quedar
// la vara de titanio rúnica.
func TestCadenaVarasRúnicas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Encantador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "encantamiento")
	j.AprenderRango(m, "encantamiento", "gran_maestro") // max 450
	j.profesiones["encantamiento"].Skill = 425          // todas las varas son crafteables
	// Materiales para la cadena completa de varas.
	for id, n := range map[string]int{
		"vara_cobre": 1, "vara_plata": 1, "vara_dorado": 1, "vara_veraplata": 1,
		"vara_arcanita": 1, "vara_hierro_vil": 1, "vara_adamantita": 1,
		"vara_eternio": 1, "vara_titanio": 1,
		"esencia_mágica_inferior": 1, "esencia_astral_inferior": 2,
		"esencia_mística_inferior": 2, "perla_iridiscente": 1,
		"esencia_mística_superior": 1, "gema_sombras": 1,
		"esencia_eterna_superior": 2, "perla_oro": 1,
		"esencia_bidimensional_superior": 14, "fragmento_centelleante_grande": 7,
		"poderío_primigenio": 1,
		"esencia_cósmica_superior": 12, "fragmento_onírico": 4, "tierra_eterna": 2,
	} {
		j.AgregarItem(id, n)
	}
	orden := []string{
		"vara_cobre_rúnico", "vara_rúnica_plateada", "vara_rúnica_dorada",
		"vara_veraplata_runas", "vara_arcanita_rúnica", "vara_hierro_vil_rúnica",
		"vara_adamantita_rúnica", "vara_eternio_rúnica", "vara_titanio_rúnica",
	}
	for i, id := range orden {
		res := j.Craftear(m, id)
		if !res.OK {
			t.Fatalf("craftear %s (#%d): %s", id, i, res.Error)
		}
	}
	// Solo la última vara debe quedar; las anteriores se consumieron.
	if j.CantidadItem("vara_titanio_rúnica") != 1 {
		t.Errorf("vara de titanio rúnica = %d, esperaba 1", j.CantidadItem("vara_titanio_rúnica"))
	}
	for _, id := range orden[:8] {
		if j.CantidadItem(id) != 0 {
			t.Errorf("%s restante = %d, esperaba 0 (debe consumirse por la siguiente vara)", id, j.CantidadItem(id))
		}
	}
	// No se puede craftear una vara sin la anterior disponible.
	j.AgregarItem("vara_plata", 1)
	if j.Craftear(m, "vara_rúnica_plateada").OK {
		t.Errorf("no debería poder craftear vara rúnica plateada sin vara de cobre rúnico")
	}
}

// subirEncantamientoA450 sube la habilidad de encantamiento a 450 crafteando
// la secuencia completa de la guía, insertando las varas rúnicas en los
// puntos correctos (cada vara da +1 skill y consume la anterior) y
// aprendiendo los rangos cuando la habilidad alcanza el techo del rango.
func subirEncantamientoA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	// Materiales generosos para toda la secuencia 0→450.
	j.AgregarItem("vara_cobre", 2)
	j.AgregarItem("vara_plata", 2)
	j.AgregarItem("vara_dorado", 2)
	j.AgregarItem("vara_veraplata", 2)
	j.AgregarItem("vara_arcanita", 2)
	j.AgregarItem("vara_hierro_vil", 2)
	j.AgregarItem("vara_adamantita", 2)
	j.AgregarItem("vara_eternio", 2)
	j.AgregarItem("vara_titanio", 2)
	j.AgregarItem("esencia_mágica_inferior", 15)
	j.AgregarItem("esencia_astral_inferior", 20)
	j.AgregarItem("esencia_mística_inferior", 15)
	j.AgregarItem("esencia_mística_superior", 3)
	j.AgregarItem("esencia_eterna_superior", 4)
	j.AgregarItem("esencia_abisal_superior", 30)
	j.AgregarItem("esencia_bidimensional_superior", 50)
	j.AgregarItem("esencia_cósmica_superior", 40)
	j.AgregarItem("polvo_extraño", 220)
	j.AgregarItem("polvo_alma", 100)
	j.AgregarItem("polvo_visión", 160)
	j.AgregarItem("polvo_onírico", 100)
	j.AgregarItem("polvo_ilusión", 80)
	j.AgregarItem("polvo_arcano", 300)
	j.AgregarItem("polvo_infinito", 600)
	j.AgregarItem("gema_sombras", 2)
	j.AgregarItem("perla_iridiscente", 2)
	j.AgregarItem("perla_oro", 2)
	j.AgregarItem("vid_pesadilla", 6)
	j.AgregarItem("fragmento_centelleante_grande", 8)
	j.AgregarItem("poderío_primigenio", 2)
	j.AgregarItem("fragmento_onírico", 40)
	j.AgregarItem("tierra_eterna", 80)
	j.AgregarItem("agua_cristalizada", 11)
	crafts := func(receta string, n int) {
		for i := 0; i < n; i++ {
			res := j.Craftear(m, receta)
			if !res.OK {
				t.Fatalf("craftear %s #%d (skill=%d): %s", receta, i, j.profesiones["encantamiento"].Skill, res.Error)
			}
		}
	}
	aprende := func(rango string) {
		res := j.AprenderRango(m, "encantamiento", rango)
		if !res.OK {
			t.Fatalf("aprender rango %s (skill=%d): %s", rango, j.profesiones["encantamiento"].Skill, res.Error)
		}
	}
	// Classic 1-300
	crafts("vara_cobre_rúnico", 1)              // 0→1
	crafts("encanto_brazal_salud_menor", 74)    // 1→75
	aprende("oficial")                           // req 50, max 150
	crafts("encanto_brazal_desvío_menor", 10)   // 75→85
	crafts("encanto_brazal_aguante_menor", 15)  // 85→100
	crafts("vara_rúnica_plateada", 1)           // 100→101
	crafts("encanto_brazal_aguante_menor", 4)   // 101→105
	crafts("encanto_brazal_agilidad_menor", 15) // 105→120
	crafts("encanto_escudo_aguante_menor", 10)  // 120→130
	crafts("encanto_brazal_aguante_inferior", 20) // 130→150 (techo oficial)
	aprende("experto")                           // req 125, max 225
	crafts("vara_rúnica_dorada", 1)            // 150→151
	crafts("encanto_brazal_aguante_inferior", 9) // 151→160
	crafts("encanto_escudo_aguante_inferior", 5) // 160→165
	crafts("encanto_brazal_espíritu", 15)      // 165→180
	crafts("encanto_brazal_fuerza", 20)        // 180→200
	crafts("vara_veraplata_runas", 1)          // 200→201
	crafts("encanto_brazal_fuerza", 5)         // 201→205
	crafts("encanto_capa_defensa_superior", 20) // 205→225 (techo experto)
	aprende("artesano")                         // req 200, max 300
	crafts("encanto_guantes_agilidad", 10)     // 225→235
	crafts("encanto_pechera_salud_excelente", 10) // 235→245
	crafts("encanto_brazal_fuerza_superior", 20) // 245→265
	crafts("encanto_escudo_aguante_superior", 25) // 265→290
	crafts("vara_arcanita_rúnica", 1)          // 290→291
	crafts("encanto_capa_defensa_excelente", 9) // 291→300 (techo artesano)
	aprende("maestro")                          // req 275, max 375
	// TBC 300-350
	crafts("vara_hierro_vil_rúnica", 1)        // 300→301
	crafts("encanto_brazal_asalto", 9)         // 301→310
	crafts("encanto_brazal_lozanía", 5)        // 310→315
	crafts("encanto_capa_armadura_sublime", 5) // 315→320
	crafts("encanto_pechera_espíritu_sublime", 15) // 320→335
	crafts("encanto_escudo_aguante_sublime", 5) // 335→340
	crafts("aceite_zahorí_excelente", 5)       // 340→345
	crafts("encanto_guantes_fuerza_sublime", 5) // 345→350
	crafts("vara_adamantita_rúnica", 1)        // 350→351
	aprende("gran_maestro")                     // req 350, max 450
	// WotLK 350-450
	crafts("encanto_capa_velocidad", 9)        // 351→360
	crafts("encanto_brazales_golpear", 15)     // 360→375
	crafts("vara_eternio_rúnica", 1)           // 375→376
	crafts("encanto_brazales_golpear", 4)      // 376→380
	crafts("encanto_brazales_intelecto_excepcional", 5) // 380→385
	crafts("encanto_botas_caminante_hielo", 10) // 385→395
	crafts("encanto_capa_agilidad_excelente", 15) // 395→410
	crafts("encanto_guantes_pericia", 5)       // 410→415
	crafts("encanto_botas_espíritu_superior", 5) // 415→420
	crafts("encanto_escudo_defensa", 5)        // 420→425
	crafts("vara_titanio_rúnica", 1)           // 425→426
	crafts("encanto_escudo_defensa", 4)        // 426→430
	crafts("encanto_capa_armadura_poderosa", 5) // 430→435
	crafts("encanto_guantes_armero", 10)       // 435→445
	crafts("fragmento_abisal", 2)              // 445→447
	crafts("encanto_botas_asalto_superior", 3) // 447→450
	if j.profesiones["encantamiento"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["encantamiento"].Skill)
	}
}

// TestSubirEncantamientoCompleto valida la cadena completa 0→450 de la guía,
// incluyendo las 9 varas rúnicas encadenadas insertadas en sus puntos.
func TestSubirEncantamientoCompleto(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Encantador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "encantamiento")
	subirEncantamientoA450(t, m, j)
	// La última vara rúnica debe estar en el inventario (cadena completa).
	if j.CantidadItem("vara_titanio_rúnica") != 1 {
		t.Errorf("vara de titanio rúnica = %d, esperaba 1", j.CantidadItem("vara_titanio_rúnica"))
	}
	// El último encantamiento crafteado.
	if j.CantidadItem("encanto_botas_asalto_superior") != 3 {
		t.Errorf("asalto superior = %d, esperaba 3", j.CantidadItem("encanto_botas_asalto_superior"))
	}
}

// TestPersistenciaEncantamiento valida que la profesión se guarda y carga.
func TestPersistenciaEncantamiento(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Encantador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "encantamiento")
	subirEncantamientoA450(t, m, j)
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Encantador")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "encantamiento" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	if p.Profesiones[0].Especializacion != "" {
		t.Errorf("encantamiento no debe tener especialización, persistió %q", p.Profesiones[0].Especializacion)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["encantamiento"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["encantamiento"].Skill)
	}
}
