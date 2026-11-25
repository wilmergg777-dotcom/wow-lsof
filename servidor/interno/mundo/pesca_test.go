// pesca_test.go valida Pesca, la SEGUNDA profesión SECUNDARIA (Primaria=false).
// Es recolección como Herboristería/Desuello (verbo Recolectar, sin consumo,
// sin recetas), pero sin nodos fijos en el mundo — se pesca en cualquier masa
// de agua, modelado aquí como un "nodo" por banda/zona. Los pescados que
// produce son exactamente los que Cocina consume (bucle Pesca→Cocina).
package mundo

import "testing"

// TestPescaCatalogo valida el catálogo de Pesca.
func TestPescaCatalogo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("pesca")
	if !ok {
		t.Fatal("pesca no existe")
	}
	if p.Primaria {
		t.Error("pesca debe ser SECUNDARIA (Primaria=false)")
	}
	if len(p.Nodos) != 10 {
		t.Errorf("nodos de pesca = %d, esperaba 10", len(p.Nodos))
	}
	if len(p.Recetas) != 0 {
		t.Errorf("pesca es recolección pura, no debería tener recetas: %d", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos = %d, esperaba 6", len(p.Rangos))
	}
	// Cada nodo produce un pescado crudo registrado; el primero desde skill 0.
	primero := true
	for _, nd := range p.Nodos {
		if primero && nd.SkillReq != 0 {
			t.Errorf("primer nodo %s SkillReq=%d, esperaba 0", nd.ID, nd.SkillReq)
		}
		primero = false
		if _, ok := m.Item(nd.ResultadoID); !ok {
			t.Errorf("nodo %s produce item desconocido %q", nd.ID, nd.ResultadoID)
		}
	}
	// Cobertura contigua 0→450.
	for skill := 0; skill < 450; skill++ {
		cubre := false
		for _, nd := range p.Nodos {
			if nd.SkillReq <= skill && skill < nd.SkillHasta {
				cubre = true
				break
			}
		}
		if !cubre {
			t.Errorf("hueco de cobertura en skill %d", skill)
		}
	}
}

// TestPescaEsSecundaria valida que Pesca NO cuenta contra el límite de 2
// primarias, y que un jugador puede tener 2 primarias + AMBAS secundarias
// (Cocina + Pesca).
func TestPescaEsSecundaria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Pescador", "mago", FaccionAlianza, "humano")
	// 2 primarias (llena el cupo).
	j.AprenderProfesion(m, "herreria")
	j.AprenderProfesion(m, "minería")
	// Ambas secundarias se pueden aprender sin contar el límite.
	if !j.AprenderProfesion(m, "cocina").OK {
		t.Fatal("no pudo aprender cocina (secundaria) con 2 primarias")
	}
	if !j.AprenderProfesion(m, "pesca").OK {
		t.Fatal("no pudo aprender pesca (secundaria) con 2 primarias + cocina")
	}
	if j.profesiones["pesca"] == nil || j.profesiones["cocina"] == nil {
		t.Error("las secundarias no se añadieron al jugador")
	}
}

// TestPescar valida que Recolectar produce el pescado y sube skill SIN
// consumir materiales.
func TestPescar(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Pescador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "pesca")
	res := j.Recolectar(m, "nodo_pececito_luminoso")
	if !res.OK {
		t.Fatalf("pescar nodo_pececito_luminoso: %s", res.Error)
	}
	if !res.SubioSkill {
		t.Errorf("debería subir skill pescando dentro de la banda")
	}
	if j.CantidadItem("pececito_luminoso_crudo") != 1 {
		t.Errorf("pececito_luminoso_crudo = %d, esperaba 1", j.CantidadItem("pececito_luminoso_crudo"))
	}
	if len(j.inventario) != 1 {
		t.Errorf("pescar no consume materiales: inventario tiene %d", len(j.inventario))
	}
	// Gating por skill: no puede pescar en Rasganorte (req 375) con skill 1.
	if j.Recolectar(m, "nodo_dardo_dorado").OK {
		t.Errorf("no debería poder pescar dardo dorado con skill 1")
	}
}

// pescarA450 sube la habilidad a 450 pescando, aprendiendo rangos pendientes.
func pescarA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	secuencia := []struct {
		nodo  string
		hasta int
	}{
		{"nodo_pececito_luminoso", 50},
		{"nodo_pargo_boquilargo", 100},
		{"nodo_siluro_mostacherizo", 175},
		{"nodo_trucha_cabeza_mitril", 225},
		{"nodo_serviola_moteada", 250},
		{"nodo_salmon_escama_sol", 275},
		{"nodo_vigorpez", 315},
		{"nodo_pecespora_zangar", 375},
		{"nodo_dardo_dorado", 400},
		{"nodo_trucha_branquias", 450},
	}
	p, _ := m.Profesione("pesca")
	contiene := func(lista []string, id string) bool {
		for _, s := range lista {
			if s == id {
				return true
			}
		}
		return false
	}
	aprendePendientes := func() {
		ep := j.profesiones["pesca"]
		for _, rg := range p.Rangos {
			if ep.Skill >= rg.SkillReq && !contiene(ep.RangosAprendidos, rg.ID) {
				res := j.AprenderRango(m, "pesca", rg.ID)
				if !res.OK {
					t.Fatalf("aprender rango %s (skill=%d): %s", rg.ID, ep.Skill, res.Error)
				}
				ep = j.profesiones["pesca"]
			}
		}
	}
	for _, s := range secuencia {
		for j.profesiones["pesca"].Skill < s.hasta {
			aprendePendientes()
			res := j.Recolectar(m, s.nodo)
			if !res.OK {
				t.Fatalf("pescar %s (skill=%d): %s", s.nodo, j.profesiones["pesca"].Skill, res.Error)
			}
			aprendePendientes()
			if j.profesiones["pesca"].Skill >= 450 {
				break
			}
		}
		if j.profesiones["pesca"].Skill >= 450 {
			break
		}
	}
	if j.profesiones["pesca"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450", j.profesiones["pesca"].Skill)
	}
}

// TestPescarA450Completo valida la cadena completa 0→450 solo pescando.
func TestPescarA450Completo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Pescador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "pesca")
	pescarA450(t, m, j)
	for _, pez := range []string{"pececito_luminoso_crudo", "siluro_mostacherizo_crudo", "pecespora_zangar", "trucha_branquias_barbadas_enorme"} {
		if j.CantidadItem(pez) == 0 {
			t.Errorf("no se pescó %s durante la secuencia", pez)
		}
	}
}

// TestPescaAlimentaCocina valida el bucle de las dos secundarias: pescar
// (Recolectar) → cocinar (Craftear). El pescado crudo de Pesca es el material
// de Cocina. Cierra el bucle Pesca→Cocina.
func TestPescaAlimentaCocina(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "ChefPescador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "pesca")
	j.AprenderProfesion(m, "cocina")
	// 1. Pescar pececito_luminoso_crudo (Recolectar).
	for j.CantidadItem("pececito_luminoso_crudo") < 3 {
		res := j.Recolectar(m, "nodo_pececito_luminoso")
		if !res.OK {
			t.Fatalf("pescar: %s", res.Error)
		}
	}
	antes := j.CantidadItem("pececito_luminoso_crudo")
	// 2. Cocinar el pescado (Craftear Cocina).
	res := j.Craftear(m, "pececito_luminoso")
	if !res.OK {
		t.Fatalf("cocinar pececito pescado: %s", res.Error)
	}
	if res.ResultadoItemID != "pececito_luminoso" {
		t.Errorf("produce %q, esperaba pececito_luminoso", res.ResultadoItemID)
	}
	if j.CantidadItem("pececito_luminoso_crudo") != antes-1 {
		t.Errorf("cocinar debería consumir 1 pescado crudo: antes=%d después=%d", antes, j.CantidadItem("pececito_luminoso_crudo"))
	}
	if j.CantidadItem("pececito_luminoso") != 1 {
		t.Errorf("pececito_luminoso cocinado = %d, esperaba 1", j.CantidadItem("pececito_luminoso"))
	}
}

// TestPersistenciaPesca valida que la profesión secundaria se guarda y carga.
func TestPersistenciaPesca(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Pescador", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "pesca")
	pescarA450(t, m, j)
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Pescador")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "pesca" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["pesca"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["pesca"].Skill)
	}
	if !j2.Recolectar(m, "nodo_trucha_branquias").OK {
		t.Errorf("tras carga, pescar trucha_branquias falló")
	}
}
