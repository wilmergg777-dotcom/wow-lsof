// sastreria_test.go valida la profesión de Sastrería: catálogo completo
// (36 recetas, 6 rangos, 3 especializaciones a 350), crafteo 1-350 por la
// cadena completa de la guía, y el sistema de especializaciones.
package mundo

import (
	"testing"
)

// TestRecetasSastreriaCompletas valida el catálogo de Sastrería.
func TestRecetasSastreriaCompletas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("sastreria")
	if !ok {
		t.Fatal("sastrería no existe")
	}
	if len(p.Recetas) != 36 {
		t.Errorf("recetas de sastrería = %d, esperaba 36", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos de sastrería = %d, esperaba 6", len(p.Rangos))
	}
	if len(p.Especializaciones) != 3 {
		t.Errorf("especializaciones de sastrería = %d, esperaba 3", len(p.Especializaciones))
	}
	if p.Recetas[0].SkillReq != 0 {
		t.Errorf("primera receta req = %d, esperaba 0", p.Recetas[0].SkillReq)
	}
	if p.Recetas[len(p.Recetas)-1].SkillHasta != 450 {
		t.Errorf("última receta hasta = %d, esperaba 450", p.Recetas[len(p.Recetas)-1].SkillHasta)
	}
	// Las 3 especializaciones deben estar y requerir skill 350.
	ids := map[string]bool{}
	for _, e := range p.Especializaciones {
		if e.SkillReq != 350 {
			t.Errorf("especialización %s skill_req = %d, esperaba 350", e.ID, e.SkillReq)
		}
		ids[e.ID] = true
	}
	for _, want := range []string{"tela_lunar", "fuego_hechizo", "tejido_sombra"} {
		if !ids[want] {
			t.Errorf("falta especialización %s", want)
		}
	}
}

// TestAprenderSastreria valida el aprendizaje inicial.
func TestAprenderSastreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Sastre", "mago", FaccionAlianza, "humano")
	res := j.AprenderProfesion(m, "sastreria")
	if !res.OK {
		t.Fatalf("aprender sastrería: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if j.AprenderProfesion(m, "sastreria").OK {
		t.Errorf("no debería poder aprender sastrería dos veces")
	}
}

// TestCraftearSastreria valida el crafteo inicial: consume materiales,
// produce el ítem y sube la habilidad.
func TestCraftearSastreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Sastre", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "sastreria")
	j.AgregarItem("paño_lino", 20)
	// Descarga de paño de lino: req 0, hasta 45, mats {paño_lino:2}.
	for i := 0; i < 10; i++ {
		res := j.Craftear(m, "descarga_paño_lino")
		if !res.OK {
			t.Fatalf("crafteo %d falló: %s", i, res.Error)
		}
	}
	if j.profesiones["sastreria"].Skill != 10 {
		t.Errorf("skill = %d, esperaba 10", j.profesiones["sastreria"].Skill)
	}
	if j.CantidadItem("paño_lino") != 0 {
		t.Errorf("paño_lino restante = %d, esperaba 0", j.CantidadItem("paño_lino"))
	}
	if j.CantidadItem("descarga_paño_lino") != 10 {
		t.Errorf("descargas = %d, esperaba 10", j.CantidadItem("descarga_paño_lino"))
	}
}

// subirSastreriaA350 sube la habilidad de sastrería a 350 crafteando la
// secuencia completa de la guía, aprendiendo los rangos en los puntos
// correctos y stockeando los materiales intermedios (descargas/madejas)
// que consumen las recetas posteriores.
func subirSastreriaA350(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	// Materiales generosos para toda la secuencia 0→350 + especialización.
	j.AgregarItem("paño_lino", 100)
	j.AgregarItem("paño_lana", 160)
	j.AgregarItem("paño_seda", 760)
	j.AgregarItem("paño_mágico", 220)
	j.AgregarItem("cuero_basto", 70)
	j.AgregarItem("paño_rúnico", 500)
	j.AgregarItem("paño_tejido_abisal", 1200)
	j.AgregarItem("polvo_arcano", 110)
	j.AgregarItem("tela_lunar_primigenia", 1)
	crafts := func(receta string, n int) {
		for i := 0; i < n; i++ {
			res := j.Craftear(m, receta)
			if !res.OK {
				t.Fatalf("craftear %s #%d (skill=%d): %s", receta, i, j.profesiones["sastreria"].Skill, res.Error)
			}
		}
	}
	aprende := func(rango string) {
		res := j.AprenderRango(m, "sastreria", rango)
		if !res.OK {
			t.Fatalf("aprender rango %s (skill=%d): %s", rango, j.profesiones["sastreria"].Skill, res.Error)
		}
	}
	// Classic 0→300
	crafts("descarga_paño_lino", 45)        // 0→45 (produce 45 descarga)
	crafts("camisa_lino_roja", 20)          // 45→65
	crafts("manteo_lino_reforzado", 10)     // 65→75
	aprende("oficial")                       // req 50, max 150
	crafts("descarga_paño_lana", 50)        // 75→105 + material (produce 50)
	crafts("camisa_lana_gris", 5)           // 105→110
	crafts("hombreras_lana_doble_pespunte", 15) // 110→125
	aprende("experto")                       // req 125, max 225
	crafts("descarga_paño_seda", 185)       // 125→145 + material (produce 185)
	crafts("caperuza_seda_azur", 15)        // 145→160
	crafts("cinta_seda", 10)                // 160→170
	crafts("camisa_blanca_formal", 5)       // 170→175
	crafts("descarga_paño_mágico", 70)      // 175→185 + material (produce 70)
	crafts("jubon_seda_carmesi", 20)        // 185→205
	crafts("pantalones_bombacho_seda_carmesi", 10) // 205→215
	crafts("leotardos_paño_mágico_negro", 5) // 215→220
	aprende("artesano")                      // req 200, max 300
	crafts("guantes_paño_mágico_negro", 10) // 220→230
	crafts("cinta_negra_paño_mágico", 20)   // 230→250
	crafts("descarga_paño_rúnico", 120)     // 250→260 + material (produce 120)
	crafts("cinturon_paño_rúnico", 15)      // 260→275
	aprende("maestro")                       // req 275, max 375
	crafts("guantes_paño_rúnico", 25)       // 275→300
	// TBC 300→350
	crafts("madeja_tejido_abisal", 230)     // 300→325 + material (produce 230)
	crafts("madeja_tejido_abisal_imbuido", 50) // 325→340
	crafts("toga_tejido_abisal", 10)        // 340→350
	if j.profesiones["sastreria"].Skill != 350 {
		t.Fatalf("skill = %d, esperaba 350 tras la secuencia", j.profesiones["sastreria"].Skill)
	}
}

// TestSubirSastreriaCompleta valida la cadena completa 0→350 de la guía.
func TestSubirSastreriaCompleta(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Sastre", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "sastreria")
	subirSastreriaA350(t, m, j)
	// Verificar que se produjeron algunos objetos finales.
	if j.CantidadItem("toga_tejido_abisal") != 10 {
		t.Errorf("togas de tejido abisal = %d, esperaba 10", j.CantidadItem("toga_tejido_abisal"))
	}
}

// TestEspecializacionSastreriaTelaLunar valida que se aprende tela lunar a
// 350 consumiendo 1 tela lunar primigenia, y que no se puede aprender una
// segunda especialización.
func TestEspecializacionSastreriaTelaLunar(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Sastre", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "sastreria")
	subirSastreriaA350(t, m, j)
	antes := j.CantidadItem("tela_lunar_primigenia")
	res := j.AprenderEspecializacion(m, "sastreria", "tela_lunar")
	if !res.OK {
		t.Fatalf("aprender tela lunar: %s", res.Error)
	}
	if res.Especializacion != "tela_lunar" {
		t.Errorf("especializacion = %s, esperaba tela_lunar", res.Especializacion)
	}
	if j.CantidadItem("tela_lunar_primigenia") != antes-1 {
		t.Errorf("tela_lunar_primigenia = %d, esperaba %d", j.CantidadItem("tela_lunar_primigenia"), antes-1)
	}
	if j.profesiones["sastreria"].Especializacion != "tela_lunar" {
		t.Errorf("estado especializacion = %s, esperaba tela_lunar", j.profesiones["sastreria"].Especializacion)
	}
	// No se puede aprender una segunda especialización.
	if j.AprenderEspecializacion(m, "sastreria", "fuego_hechizo").OK {
		t.Errorf("no debería poder aprender una segunda especialización")
	}
}

// TestEspecializacionSastreriaSkillReq valida que no se puede aprender una
// especialización de sastrería por debajo de 350.
func TestEspecializacionSastreriaSkillReq(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Sastre", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "sastreria")
	j.AprenderRango(m, "sastreria", "gran_maestro") // max 450, pero skill sigue 0
	j.AgregarItem("tela_lunar_primigenia", 1)
	// skill 0 → tela_lunar (req 350) debe fallar.
	if j.AprenderEspecializacion(m, "sastreria", "tela_lunar").OK {
		t.Errorf("no debería poder aprender tela lunar con skill 0")
	}
}

// TestPersistenciaSastreria valida que la profesión y su especialización se
// guardan y cargan correctamente.
func TestPersistenciaSastreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Sastre", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "sastreria")
	subirSastreriaA350(t, m, j)
	j.AprenderEspecializacion(m, "sastreria", "tela_lunar")
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Sastre")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "sastreria" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Especializacion != "tela_lunar" {
		t.Errorf("especializacion persistida = %q, esperaba tela_lunar", p.Profesiones[0].Especializacion)
	}
	if p.Profesiones[0].Skill != 350 {
		t.Errorf("skill persistida = %d, esperaba 350", p.Profesiones[0].Skill)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["sastreria"].Especializacion != "tela_lunar" {
		t.Errorf("especializacion tras carga = %q, esperaba tela_lunar", j2.profesiones["sastreria"].Especializacion)
	}
}
