// peleteria_test.go valida la profesión de Peletería: catálogo completo
// (30 recetas, 6 rangos, 3 especializaciones), crafteo 1-300, y el sistema
// de especializaciones (materiales, skill req, única por profesión,
// persistencia).
package mundo

import (
	"testing"
)

// TestRecetasPeleteriaCompletas valida el catálogo de Peletería.
func TestRecetasPeleteriaCompletas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("peleteria")
	if !ok {
		t.Fatal("peletería no existe")
	}
	if len(p.Recetas) != 30 {
		t.Errorf("recetas de peletería = %d, esperaba 30", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos de peletería = %d, esperaba 6", len(p.Rangos))
	}
	if len(p.Especializaciones) != 3 {
		t.Errorf("especializaciones de peletería = %d, esperaba 3", len(p.Especializaciones))
	}
	// La primera receta empieza en skill 0, la última llega hasta 450.
	if p.Recetas[0].SkillReq != 0 {
		t.Errorf("primera receta req = %d, esperaba 0", p.Recetas[0].SkillReq)
	}
	if p.Recetas[len(p.Recetas)-1].SkillHasta != 450 {
		t.Errorf("última receta hasta = %d, esperaba 450", p.Recetas[len(p.Recetas)-1].SkillHasta)
	}
	// Las 3 especializaciones deben estar y requerir skill 225.
	ids := map[string]bool{}
	for _, e := range p.Especializaciones {
		if e.SkillReq != 225 {
			t.Errorf("especialización %s skill_req = %d, esperaba 225", e.ID, e.SkillReq)
		}
		ids[e.ID] = true
	}
	for _, want := range []string{"dragontina", "elemental", "tribal"} {
		if !ids[want] {
			t.Errorf("falta especialización %s", want)
		}
	}
}

// TestAprenderPeleteria valida el aprendizaje inicial.
func TestAprenderPeleteria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Peletero", "druida", FaccionAlianza, "elfo_noche")
	res := j.AprenderProfesion(m, "peleteria")
	if !res.OK {
		t.Fatalf("aprender peletería: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	// Duplicado → error.
	if j.AprenderProfesion(m, "peleteria").OK {
		t.Errorf("no debería poder aprender peletería dos veces")
	}
}

// TestCraftearPeleteria valida el crafteo inicial: consume materiales,
// produce el ítem y sube la habilidad.
func TestCraftearPeleteria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Peletero", "druida", FaccionAlianza, "elfo_noche")
	j.AprenderProfesion(m, "peleteria")
	j.AgregarItem("cuero_ligero", 10)
	// Complemento para armadura ligera: req 0, hasta 45, mats {cuero_ligero:1}.
	for i := 0; i < 10; i++ {
		res := j.Craftear(m, "complemento_armadura_ligera")
		if !res.OK {
			t.Fatalf("crafteo %d falló: %s", i, res.Error)
		}
	}
	if j.profesiones["peleteria"].Skill != 10 {
		t.Errorf("skill = %d, esperaba 10", j.profesiones["peleteria"].Skill)
	}
	if j.CantidadItem("cuero_ligero") != 0 {
		t.Errorf("cuero_ligero restante = %d, esperaba 0", j.CantidadItem("cuero_ligero"))
	}
	if j.CantidadItem("complemento_armadura_ligera") != 10 {
		t.Errorf("complementos = %d, esperaba 10", j.CantidadItem("complemento_armadura_ligera"))
	}
}

// subirPeleteriaA225 sube la habilidad de peletería a 225 crafteando la
// secuencia de recetas de la guía, aprendiendo los rangos en los puntos
// correctos (oficial a 50, experto a 125, artesano a 200) para no topar
// con el SkillMax de cada rango.
func subirPeleteriaA225(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	// Materiales generosos para toda la secuencia 0→225 + especialización.
	j.AgregarItem("cuero_ligero", 70)
	j.AgregarItem("cuero_fino", 240)
	j.AgregarItem("cuero_pesado", 350)
	j.AgregarItem("pellejo_pesado_curado", 12)
	j.AgregarItem("cuero_grueso", 140)
	crafts := func(receta string, n int) {
		for i := 0; i < n; i++ {
			res := j.Craftear(m, receta)
			if !res.OK {
				t.Fatalf("craftear %s #%d (skill=%d): %s", receta, i, j.profesiones["peleteria"].Skill, res.Error)
			}
		}
	}
	aprende := func(rango string) {
		res := j.AprenderRango(m, "peleteria", rango)
		if !res.OK {
			t.Fatalf("aprender rango %s: %s", rango, res.Error)
		}
	}
	// 0→45 (max 75 aprendiz)
	crafts("complemento_armadura_ligera", 45)
	crafts("capa_cuero_cosida_mano", 10) // →55
	aprende("oficial")                    // req 50, max 150
	crafts("guantes_cuero_relieve", 45)   // →100
	crafts("cinturon_cuero_refinado", 25) // →125
	aprende("experto")                    // req 125, max 225
	crafts("botas_cuero_oscuro", 12)      // →137
	crafts("pantalones_cuero_oscuro", 18) // →155
	crafts("guantes_cuero_montanero", 10) // →165
	crafts("complemento_pesado_armadura", 15) // →180
	crafts("hombreras_barbaricas", 15)    // →195
	crafts("brazales_oscurecidos", 10)    // →205
	aprende("artesano")                   // req 200, max 300
	crafts("cinta_nochefugaz", 20)        // →225
	if j.profesiones["peleteria"].Skill != 225 {
		t.Fatalf("skill = %d, esperaba 225 tras la secuencia", j.profesiones["peleteria"].Skill)
	}
}

// TestEspecializacionTribal valida que se aprende tribal a 225 consumiendo
// 10 cuero_grueso, y que no se puede aprender una segunda especialización.
func TestEspecializacionTribal(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Peletero", "druida", FaccionAlianza, "elfo_noche")
	j.AprenderProfesion(m, "peleteria")
	subirPeleteriaA225(t, m, j)
	// tribal cuesta 10 cuero_grueso. Quedan ~140-120=20 de la secuencia.
	antes := j.CantidadItem("cuero_grueso")
	res := j.AprenderEspecializacion(m, "peleteria", "tribal")
	if !res.OK {
		t.Fatalf("aprender tribal: %s", res.Error)
	}
	if res.Especializacion != "tribal" {
		t.Errorf("especializacion = %s, esperaba tribal", res.Especializacion)
	}
	if j.CantidadItem("cuero_grueso") != antes-10 {
		t.Errorf("cuero_grueso = %d, esperaba %d (consumió 10)", j.CantidadItem("cuero_grueso"), antes-10)
	}
	if j.profesiones["peleteria"].Especializacion != "tribal" {
		t.Errorf("estado especializacion = %s, esperaba tribal", j.profesiones["peleteria"].Especializacion)
	}
	// No se puede aprender una segunda especialización.
	if j.AprenderEspecializacion(m, "peleteria", "elemental").OK {
		t.Errorf("no debería poder aprender una segunda especialización")
	}
}

// TestEspecializacionSkillReq valida que no se puede aprender una
// especialización por debajo de 225.
func TestEspecializacionSkillReq(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Peletero", "druida", FaccionAlianza, "elfo_noche")
	j.AprenderProfesion(m, "peleteria")
	j.AgregarItem("cuero_grueso", 20)
	// skill 0 → tribal (req 225) debe fallar.
	if j.AprenderEspecializacion(m, "peleteria", "tribal").OK {
		t.Errorf("no debería poder aprender tribal con skill 0")
	}
}

// TestEspecializacionSinMateriales valida que falla si faltan materiales.
func TestEspecializacionSinMateriales(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Peletero", "druida", FaccionAlianza, "elfo_noche")
	j.AprenderProfesion(m, "peleteria")
	subirPeleteriaA225(t, m, j)
	// elemental requiere corazon_fuego/globo_agua/nucleo_tierra/aliento_viento (2 c/u).
	// No los tenemos → debe fallar.
	res := j.AprenderEspecializacion(m, "peleteria", "elemental")
	if res.OK {
		t.Errorf("no debería poder aprender elemental sin materiales")
	}
	if j.profesiones["peleteria"].Especializacion != "" {
		t.Errorf("no debería haber fijado especialización al fallar")
	}
}

// TestPersistenciaEspecializacion valida que la especialización se guarda
// y carga correctamente.
func TestPersistenciaEspecializacion(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Peletero", "druida", FaccionAlianza, "elfo_noche")
	j.AprenderProfesion(m, "peleteria")
	subirPeleteriaA225(t, m, j)
	j.AprenderEspecializacion(m, "peleteria", "tribal")
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Peletero")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "peleteria" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Especializacion != "tribal" {
		t.Errorf("especializacion persistida = %q, esperaba tribal", p.Profesiones[0].Especializacion)
	}
	if p.Profesiones[0].Skill != 225 {
		t.Errorf("skill persistida = %d, esperaba 225", p.Profesiones[0].Skill)
	}
	// Reconstruir y verificar.
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["peleteria"].Especializacion != "tribal" {
		t.Errorf("especializacion tras carga = %q, esperaba tribal", j2.profesiones["peleteria"].Especializacion)
	}
}
