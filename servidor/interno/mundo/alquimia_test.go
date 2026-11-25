// alquimia_test.go valida la profesión de Alquimia: catálogo completo (38
// recetas, 6 rangos, 3 especializaciones), la cadena de pociones
// intermedias (poción de curación menor y aceite de pigmeo se consumen en
// recetas posteriores), el crafteo 0-450 con la Investigación insertada en
// mitad de la banda del elixir de agilidad poderosa, y las 3 maestrías.
package mundo

import (
	"testing"
)

// TestRecetasAlquimiaCompletas valida el catálogo de Alquimia.
func TestRecetasAlquimiaCompletas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("alquimia")
	if !ok {
		t.Fatal("alquimia no existe")
	}
	if len(p.Recetas) != 38 {
		t.Errorf("recetas de alquimia = %d, esperaba 38", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos de alquimia = %d, esperaba 6", len(p.Rangos))
	}
	if len(p.Especializaciones) != 3 {
		t.Errorf("especializaciones de alquimia = %d, esperaba 3", len(p.Especializaciones))
	}
	if p.Recetas[0].SkillReq != 0 {
		t.Errorf("primera receta req = %d, esperaba 0 (poción de curación menor)", p.Recetas[0].SkillReq)
	}
	if p.Recetas[len(p.Recetas)-1].SkillHasta != 450 {
		t.Errorf("última receta hasta = %d, esperaba 450 (frasco de ira infinita)", p.Recetas[len(p.Recetas)-1].SkillHasta)
	}
	// La primera receta produce un item de tipo poción.
	if d, ok := m.Item(p.Recetas[0].ResultadoID); !ok || d.Tipo != TipoPoción {
		t.Errorf("primera receta no produce una poción")
	}
	// Debe haber al menos un frasco y una transmutación (titanio).
	tipos := map[string]bool{}
	for _, r := range p.Recetas {
		if d, ok := m.Item(r.ResultadoID); ok {
			tipos[d.Tipo] = true
		}
	}
	if !tipos[TipoFrasco] {
		t.Errorf("alquimia debería producir al menos un frasco")
	}
}

// TestAprenderAlquimia valida el aprendizaje inicial.
func TestAprenderAlquimia(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	res := j.AprenderProfesion(m, "alquimia")
	if !res.OK {
		t.Fatalf("aprender alquimia: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if j.AprenderProfesion(m, "alquimia").OK {
		t.Errorf("no debería poder aprender alquimia dos veces")
	}
}

// TestCraftearAlquimia valida el crafteo básico y la primera cadena: la
// Poción de curación menor se crea y luego se consume al craftear la
// Poción de curación inferior.
func TestCraftearAlquimia(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "alquimia")
	j.AgregarItem("flor_de_paz", 5)
	j.AgregarItem("hojaplata", 5)
	for i := 0; i < 5; i++ {
		res := j.Craftear(m, "poción_curación_menor")
		if !res.OK {
			t.Fatalf("craftear poción de curación menor #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("poción_curación_menor") != 5 {
		t.Errorf("poción de curación menor = %d, esperaba 5", j.CantidadItem("poción_curación_menor"))
	}
	if j.CantidadItem("flor_de_paz") != 0 || j.CantidadItem("hojaplata") != 0 {
		t.Errorf("las hierbas no se consumieron correctamente")
	}
	// Cadena: Poción de curación inferior consume 1 poción de curación menor.
	j.AprenderRango(m, "alquimia", "oficial")
	j.profesiones["alquimia"].Skill = 60 // la inferior requiere 60
	j.AgregarItem("brezospina", 3)
	for i := 0; i < 3; i++ {
		res := j.Craftear(m, "poción_curación_inferior")
		if !res.OK {
			t.Fatalf("craftear poción de curación inferior #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("poción_curación_menor") != 2 {
		t.Errorf("poción de curación menor = %d, esperaba 2 (3 consumidas por la inferior)", j.CantidadItem("poción_curación_menor"))
	}
	if j.CantidadItem("poción_curación_inferior") != 3 {
		t.Errorf("poción de curación inferior = %d, esperaba 3", j.CantidadItem("poción_curación_inferior"))
	}
}

// TestCadenaPocionesAlquimia valida la segunda cadena: el Aceite de pigmeo
// se crea a 375 y se consume en la Investigación de alquimia de Rasganorte.
func TestCadenaPocionesAlquimia(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "alquimia")
	j.AprenderRango(m, "alquimia", "gran_maestro")
	j.profesiones["alquimia"].Skill = 400 // ambas recetas crafteables
	j.AgregarItem("rémora_pigmea", 2)
	for i := 0; i < 2; i++ {
		res := j.Craftear(m, "aceite_pigmeo")
		if !res.OK {
			t.Fatalf("craftear aceite de pigmeo #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("aceite_pigmeo") != 2 {
		t.Errorf("aceite de pigmeo = %d, esperaba 2", j.CantidadItem("aceite_pigmeo"))
	}
	// La investigación consume 1 aceite de pigmeo.
	j.AgregarItem("rosa_de_talandra", 1)
	antes := j.CantidadItem("aceite_pigmeo")
	res := j.Craftear(m, "investigación_alquimia_norte")
	if !res.OK {
		t.Fatalf("craftear investigación: %s", res.Error)
	}
	if j.CantidadItem("aceite_pigmeo") != antes-1 {
		t.Errorf("aceite de pigmeo = %d, esperaba %d (la investigación consume 1)", j.CantidadItem("aceite_pigmeo"), antes-1)
	}
	if j.CantidadItem("investigación_alquimia_norte") != 1 {
		t.Errorf("investigación = %d, esperaba 1", j.CantidadItem("investigación_alquimia_norte"))
	}
}

// subirAlquimiaA450 sube la habilidad de alquimia a 450 crafteando la
// secuencia completa de la guía, con la Investigación de alquimia de
// Rasganorte insertada en mitad de la banda del elixir de agilidad
// poderosa (5 elixires → 400, investigación → 401, 4 elixires → 405) y
// aprendiendo los rangos cuando la habilidad alcanza el techo del rango.
func subirAlquimiaA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	// Materiales generosos para toda la secuencia 0→450.
	for id, n := range map[string]int{
		"flor_de_paz": 70, "hojaplata": 70, "brezospina": 100, "hierba_cardenal": 35,
		"marregal": 25, "alga_estranguladora": 55, "vidarraíz": 35, "sangrerregia": 35,
		"espina_de_oro": 55, "acérita_salvaje": 6, "solea": 80, "mostacho_de_khadgar": 30,
		"lágrimas_de_arthas": 25, "carolina": 25, "sansam_dorado": 20, "salviargenta_de_montaña": 20,
		"hierba_vil": 40, "velada": 25, "flor_abisal": 10, "gloria_de_ensueño": 20,
		"rosa_de_talandra": 20, "rémora_pigmea": 5, "trébol_de_oro": 90, "lirio_atigrado": 50,
		"lengua_de_víboris": 35, "espina_de_hielo": 35, "flor_exánime": 40, "barra_de_saronita": 56,
		"aire_eterno": 5, "sangrita": 5, "calcedonia": 5,
	} {
		j.AgregarItem(id, n)
	}
	crafts := func(receta string, n int) {
		for i := 0; i < n; i++ {
			res := j.Craftear(m, receta)
			if !res.OK {
				t.Fatalf("craftear %s #%d (skill=%d): %s", receta, i, j.profesiones["alquimia"].Skill, res.Error)
			}
		}
	}
	aprende := func(rango string) {
		res := j.AprenderRango(m, "alquimia", rango)
		if !res.OK {
			t.Fatalf("aprender rango %s (skill=%d): %s", rango, j.profesiones["alquimia"].Skill, res.Error)
		}
	}
	// Classic 1-300
	crafts("poción_curación_menor", 60)        // 0→60
	aprende("oficial")                          // req 50, max 150
	crafts("poción_curación_inferior", 50)     // 60→110
	crafts("poción_curación", 30)              // 110→140
	aprende("experto")                          // req 125, max 225
	crafts("poción_maná_inferior", 15)         // 140→155
	crafts("poción_curación_superior", 30)     // 155→185
	crafts("elixir_agilidad", 25)              // 185→210
	aprende("artesano")                         // req 200, max 300
	crafts("elixir_defensa_superior", 5)       // 210→215
	crafts("poción_curación_excelente", 15)    // 215→230
	crafts("elixir_detectar_muertos", 20)      // 230→250
	crafts("elixir_agilidad_superior", 15)     // 250→265
	crafts("poción_maná_excelente", 20)        // 265→285
	crafts("poción_curación_sublime", 15)      // 285→300 (techo artesano)
	aprende("maestro")                          // req 275, max 375
	// TBC 300-350
	crafts("poción_sanación_volátil", 15)      // 300→315
	crafts("poción_maná_inestable", 10)        // 315→325
	crafts("poción_alquimista_loco", 10)       // 325→335
	crafts("superpoción_sanación", 5)          // 335→340
	crafts("superpoción_maná", 10)             // 340→350
	aprende("gran_maestro")                     // req 350, max 450
	// WotLK 350-450
	crafts("poción_sanación_resurgente", 10)   // 350→360
	crafts("poción_maná_helada", 5)            // 360→365
	crafts("elixir_poder_hechizos", 10)        // 365→375
	crafts("aceite_pigmeo", 5)                 // 375→380
	crafts("poción_pesadillas", 5)             // 380→385
	crafts("elixir_fuerza_poderosa", 10)       // 385→395
	crafts("elixir_agilidad_poderosa", 5)      // 395→400
	crafts("investigación_alquimia_norte", 1)  // 400→401
	crafts("elixir_agilidad_poderosa", 4)      // 401→405
	crafts("poción_indestructible", 10)        // 405→415
	crafts("poción_maná_rúnica", 10)           // 415→425
	crafts("transmutar_titanio", 5)            // 425→430
	crafts("transmutar_diamante_llama_celeste", 5) // 430→435
	crafts("frasco_ira_infinita", 15)          // 435→450
	if j.profesiones["alquimia"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["alquimia"].Skill)
	}
}

// TestSubirAlquimiaCompleto valida la cadena completa 0→450 de la guía,
// incluyendo las dos cadenas de pociones intermedias y la Investigación
// insertada en mitad de la banda del elixir de agilidad poderosa.
func TestSubirAlquimiaCompleto(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "alquimia")
	subirAlquimiaA450(t, m, j)
	// El frasco final debe estar en el inventario.
	if j.CantidadItem("frasco_ira_infinita") != 15 {
		t.Errorf("frasco de ira infinita = %d, esperaba 15", j.CantidadItem("frasco_ira_infinita"))
	}
	// La investigación se crafteó (consume aceite de pigmeo).
	if j.CantidadItem("investigación_alquimia_norte") != 1 {
		t.Errorf("investigación = %d, esperaba 1", j.CantidadItem("investigación_alquimia_norte"))
	}
}

// TestEspecializacionAlquimiaPociones valida que se aprende Maestro en
// pociones a partir de skill 325 consumiendo los materiales de la misión,
// y que no se puede aprender una segunda especialización.
func TestEspecializacionAlquimiaPociones(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "alquimia")
	j.AprenderRango(m, "alquimia", "gran_maestro")
	j.profesiones["alquimia"].Skill = 350 // ≥ 325 (req de la maestría)
	j.AgregarItem("superpoción_sanación", 5)
	j.AgregarItem("superpoción_maná", 5)
	j.AgregarItem("poción_letargo_sin_sueños_sublime", 5)
	j.AgregarItem("guía_de_campo_botánicos", 1)
	antes := j.CantidadItem("superpoción_sanación")
	res := j.AprenderEspecializacion(m, "alquimia", "pociones")
	if !res.OK {
		t.Fatalf("aprender maestro en pociones: %s", res.Error)
	}
	if res.Especializacion != "pociones" {
		t.Errorf("especializacion = %s, esperaba pociones", res.Especializacion)
	}
	if j.CantidadItem("superpoción_sanación") != antes-5 {
		t.Errorf("superpoción de sanación = %d, esperaba %d", j.CantidadItem("superpoción_sanación"), antes-5)
	}
	if j.profesiones["alquimia"].Especializacion != "pociones" {
		t.Errorf("estado especializacion = %s, esperaba pociones", j.profesiones["alquimia"].Especializacion)
	}
	// No se puede aprender una segunda especialización.
	j.AgregarItem("elixir_defensa_sublime", 5)
	j.AgregarItem("elixir_maestría", 5)
	j.AgregarItem("elixir_agilidad_sublime", 5)
	j.AgregarItem("esencia_de_infinidad", 10)
	if j.AprenderEspecializacion(m, "alquimia", "elixires").OK {
		t.Errorf("no debería poder aprender una segunda especialización")
	}
}

// TestEspecializacionAlquimiaTransmutacion valida que se aprende Maestro de
// transmutación consumiendo 4 poderío primigenio.
func TestEspecializacionAlquimiaTransmutacion(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "alquimia")
	j.AprenderRango(m, "alquimia", "gran_maestro")
	j.profesiones["alquimia"].Skill = 350
	j.AgregarItem("poderío_primigenio", 4)
	res := j.AprenderEspecializacion(m, "alquimia", "transmutación")
	if !res.OK {
		t.Fatalf("aprender maestro de transmutación: %s", res.Error)
	}
	if j.CantidadItem("poderío_primigenio") != 0 {
		t.Errorf("poderío primigenio = %d, esperaba 0", j.CantidadItem("poderío_primigenio"))
	}
}

// TestEspecializacionAlquimiaSkillReq valida que no se puede aprender una
// especialización de alquimia por debajo de 325.
func TestEspecializacionAlquimiaSkillReq(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "alquimia")
	j.AprenderRango(m, "alquimia", "gran_maestro") // max 450, pero skill sigue 0
	j.AgregarItem("poderío_primigenio", 4)
	// skill 0 → transmutación (req 325) debe fallar.
	if j.AprenderEspecializacion(m, "alquimia", "transmutación").OK {
		t.Errorf("no debería poder aprender una maestría con skill 0")
	}
}

// TestPersistenciaAlquimia valida que la profesión y su especialización se
// guardan y cargan correctamente tras subir a 450.
func TestPersistenciaAlquimia(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "alquimia")
	subirAlquimiaA450(t, m, j)
	// Aprende una especialización tras llegar a 450.
	j.AgregarItem("poderío_primigenio", 4)
	if res := j.AprenderEspecializacion(m, "alquimia", "transmutación"); !res.OK {
		t.Fatalf("aprender transmutación: %s", res.Error)
	}
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Alquimista")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "alquimia" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	if p.Profesiones[0].Especializacion != "transmutación" {
		t.Errorf("especializacion persistida = %q, esperaba transmutación", p.Profesiones[0].Especializacion)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["alquimia"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["alquimia"].Skill)
	}
	if j2.profesiones["alquimia"].Especializacion != "transmutación" {
		t.Errorf("especializacion tras carga = %q, esperaba transmutación", j2.profesiones["alquimia"].Especializacion)
	}
}
