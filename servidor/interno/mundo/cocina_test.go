// cocina_test.go valida Cocina, la PRIMERA profesión SECUNDARIA del juego
// (Primaria=false). No cuenta contra el límite de MaxProfesionesPrimarias,
// así todo jugador puede aprenderla además de sus dos primarias. Produce
// comidas con buff de atributo a partir de pescado y especias.
package mundo

import "testing"

// TestCocinaCatalogo valida el catálogo de Cocina.
func TestCocinaCatalogo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("cocina")
	if !ok {
		t.Fatal("cocina no existe")
	}
	if p.Primaria {
		t.Error("cocina debe ser SECUNDARIA (Primaria=false)")
	}
	if len(p.Recetas) != 17 {
		t.Errorf("recetas de cocina = %d, esperaba 17", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos = %d, esperaba 6", len(p.Rangos))
	}
	for _, rc := range p.Recetas {
		if _, ok := m.Item(rc.ResultadoID); !ok {
			t.Errorf("receta %s produce item desconocido %q", rc.ID, rc.ResultadoID)
		}
		for _, mat := range rc.Materiales {
			if _, ok := m.Item(mat.ItemID); !ok {
				t.Errorf("receta %s consume item desconocido %q", rc.ID, mat.ItemID)
			}
		}
	}
	// Cobertura contigua 0→450.
	for skill := 0; skill < 450; skill++ {
		cubre := false
		for _, rc := range p.Recetas {
			if rc.SkillReq <= skill && skill < rc.SkillHasta {
				cubre = true
				break
			}
		}
		if !cubre {
			t.Errorf("hueco de cobertura en skill %d", skill)
		}
	}
}

// TestCocinaEsSecundaria valida que Cocina NO cuenta contra el límite de 2
// profesiones primarias: un jugador con 2 primarias puede aprender Cocina.
func TestCocinaEsSecundaria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Chef", "mago", FaccionAlianza, "humano")
	// Aprender dos profesiones primarias (llena el cupo).
	if !j.AprenderProfesion(m, "herreria").OK {
		t.Fatal("no pudo aprender herreria")
	}
	if !j.AprenderProfesion(m, "minería").OK {
		t.Fatal("no pudo aprender minería")
	}
	// Una tercera primaria debería fallar (límite de 2).
	if j.AprenderProfesion(m, "desuello").OK {
		t.Error("no debería poder aprender una tercera primaria")
	}
	// Pero Cocina (secundaria) SÍ se puede aprender sin contar el límite.
	if !j.AprenderProfesion(m, "cocina").OK {
		t.Fatal("no pudo aprender cocina siendo secundaria con 2 primarias")
	}
	if j.profesiones["cocina"] == nil {
		t.Error("cocina no se añadió al jugador")
	}
}

// TestCocinar valida que Craftear consume el pescado y produce la comida.
func TestCocinar(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Chef", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "cocina")
	j.AgregarItem("pececito_luminoso_crudo", 3)
	res := j.Craftear(m, "pececito_luminoso")
	if !res.OK {
		t.Fatalf("cocinar pececito_luminoso: %s", res.Error)
	}
	if res.ResultadoItemID != "pececito_luminoso" {
		t.Errorf("produce %q, esperaba pececito_luminoso", res.ResultadoItemID)
	}
	if j.CantidadItem("pececito_luminoso_crudo") != 2 {
		t.Errorf("debería consumir 1 pescado crudo: quedan %d", j.CantidadItem("pececito_luminoso_crudo"))
	}
	if j.CantidadItem("pececito_luminoso") != 1 {
		t.Errorf("pececito_luminoso = %d, esperaba 1", j.CantidadItem("pececito_luminoso"))
	}
}

// cocinarA450 sube la habilidad a 450 crafteando la secuencia de recetas,
// dando el pescado/especias necesario y aprendiendo rangos pendientes.
func cocinarA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	// Dar el material de cada receta en cantidad suficiente.
	j.AgregarItem("pececito_luminoso_crudo", 100)
	j.AgregarItem("pargo_loco_boquilargo_crudo", 100)
	j.AgregarItem("siluro_mostacherizo_crudo", 100)
	j.AgregarItem("trucha_cabeza_mitril_crudo", 100)
	j.AgregarItem("serviola_moteada_crudo", 100)
	j.AgregarItem("salmon_escama_sol_crudo", 100)
	j.AgregarItem("vigorpez_crudo_grande", 100)
	j.AgregarItem("pecespora_zangar", 100)
	j.AgregarItem("dardo_dorado", 100)
	j.AgregarItem("trucha_branquias_barbadas_enorme", 100)
	j.AgregarItem("bayas_tundra", 100)
	j.AgregarItem("ciruela_blanca_sabrosa", 100)
	j.AgregarItem("northern_spice", 100)
	secuencia := []struct {
		receta string
		hasta  int
	}{
		{"pececito_luminoso", 50},
		{"pargo_lodo_boquilargo", 100},
		{"siluro_mostacherizo", 175},
		{"trucha_cabeza_mitril", 225},
		{"serviola_moteada", 250},
		{"salmon_escama_sol_pochado", 275},
		{"filete_vigorpez", 315},
		{"pescado_esporas_ennegrecido", 340},
		{"palitos_pez_dorado", 360},
		{"trucha_mantequilla_caliente", 375},
		{"kungaloosh", 400},
		{"guiso_pecespora", 425},
		{"filete_dardo_picante", 450},
	}
	p, _ := m.Profesione("cocina")
	contiene := func(lista []string, id string) bool {
		for _, s := range lista {
			if s == id {
				return true
			}
		}
		return false
	}
	aprendePendientes := func() {
		ep := j.profesiones["cocina"]
		for _, rg := range p.Rangos {
			if ep.Skill >= rg.SkillReq && !contiene(ep.RangosAprendidos, rg.ID) {
				res := j.AprenderRango(m, "cocina", rg.ID)
				if !res.OK {
					t.Fatalf("aprender rango %s (skill=%d): %s", rg.ID, ep.Skill, res.Error)
				}
				ep = j.profesiones["cocina"]
			}
		}
	}
	for _, s := range secuencia {
		for j.profesiones["cocina"].Skill < s.hasta {
			aprendePendientes()
			res := j.Craftear(m, s.receta)
			if !res.OK {
				t.Fatalf("craftear %s (skill=%d): %s", s.receta, j.profesiones["cocina"].Skill, res.Error)
			}
			if j.profesiones["cocina"].Skill >= 450 {
				break
			}
		}
		if j.profesiones["cocina"].Skill >= 450 {
			break
		}
	}
	if j.profesiones["cocina"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450", j.profesiones["cocina"].Skill)
	}
}

// TestCocinaA450Completo valida la cadena completa 0→450.
func TestCocinaA450Completo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Chef", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "cocina")
	cocinarA450(t, m, j)
	for _, comida := range []string{"pececito_luminoso", "filete_vigorpez", "kungaloosh"} {
		if j.CantidadItem(comida) == 0 {
			t.Errorf("no se crafteó %s durante la secuencia", comida)
		}
	}
}

// TestPersistenciaCocina valida que la profesión secundaria se guarda y carga.
func TestPersistenciaCocina(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Chef", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "cocina")
	cocinarA450(t, m, j)
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Chef")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "cocina" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["cocina"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["cocina"].Skill)
	}
	j2.AgregarItem("pececito_luminoso_crudo", 5)
	if !j2.Craftear(m, "pececito_luminoso").OK {
		t.Errorf("tras carga, cocinar pececito_luminoso falló")
	}
}
