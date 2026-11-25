// desuello_test.go valida Desuello (Skinning), la tercera y última profesión
// de recolección pura. Como Herboristería usa solo Nodos (verbo Recolectar,
// sin consumo, sin recetas). Cierra el triángulo de recolección del juego:
// los cueros que produce son exactamente los que Peletería consume.
package mundo

import "testing"

// TestDesuelloCatalogo valida el catálogo de Desuello (nodos, rangos).
func TestDesuelloCatalogo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("desuello")
	if !ok {
		t.Fatal("desuello no existe")
	}
	if len(p.Nodos) != 9 {
		t.Errorf("nodos de desuello = %d, esperaba 9", len(p.Nodos))
	}
	if len(p.Recetas) != 0 {
		t.Errorf("desuello es recolección pura, no debería tener recetas: %d", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos = %d, esperaba 6", len(p.Rangos))
	}
	// Cada nodo produce un cuero/piel registrado; el primero desde skill 0.
	primero := true
	for _, nd := range p.Nodos {
		if primero && nd.SkillReq != 0 {
			t.Errorf("primer nodo %s SkillReq=%d, esperaba 0", nd.ID, nd.SkillReq)
		}
		primero = false
		if _, ok := m.Item(nd.ResultadoID); !ok {
			t.Errorf("nodo %s produce item desconocido %q", nd.ID, nd.ResultadoID)
		}
		if nd.SkillHasta <= nd.SkillReq {
			t.Errorf("nodo %s SkillHasta=%d <= SkillReq=%d", nd.ID, nd.SkillHasta, nd.SkillReq)
		}
	}
	// Cobertura contigua 0→450 por nodos.
	for skill := 0; skill < 450; skill++ {
		cubre := false
		for _, nd := range p.Nodos {
			if nd.SkillReq <= skill && skill < nd.SkillHasta {
				cubre = true
				break
			}
		}
		if !cubre {
			t.Errorf("hueco de cobertura de nodos en skill %d", skill)
		}
	}
}

// TestAprenderDesuello valida el aprendizaje.
func TestAprenderDesuello(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Desollador", "guerrero", FaccionHorda, "orco")
	res := j.AprenderProfesion(m, "desuello")
	if !res.OK {
		t.Fatalf("aprender desuello: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
}

// TestDesuellar valida que Recolectar produce el cuero y sube skill SIN
// consumir materiales (igual que Herboristería).
func TestDesuellar(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Desollador", "guerrero", FaccionHorda, "orco")
	j.AprenderProfesion(m, "desuello")
	res := j.Recolectar(m, "nodo_cuero_ligero")
	if !res.OK {
		t.Fatalf("desuellar nodo_cuero_ligero: %s", res.Error)
	}
	if !res.SubioSkill {
		t.Errorf("debería subir skill desuellando dentro de la banda")
	}
	if j.profesiones["desuello"].Skill != 1 {
		t.Errorf("skill tras desuellar = %d, esperaba 1", j.profesiones["desuello"].Skill)
	}
	if j.CantidadItem("cuero_ligero") != 1 {
		t.Errorf("cuero_ligero = %d, esperaba 1", j.CantidadItem("cuero_ligero"))
	}
	// Desuellar no consume materiales.
	if len(j.inventario) != 1 {
		t.Errorf("inventario debería tener solo el cuero (sin consumo), tiene %d", len(j.inventario))
	}
	// Gating por skill: no puede desuello boreal (req 355) con skill 1.
	if j.Recolectar(m, "nodo_cuero_boreal").OK {
		t.Errorf("no debería poder desuellar cuero boreal con skill 1")
	}
}

// desuellarA450 sube la habilidad de desuello a 450 desollando bestias,
// aprendiendo rangos pendientes tras cada recolección.
func desuellarA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	secuencia := []struct {
		nodo  string
		hasta int
	}{
		{"nodo_cuero_ligero", 75},
		{"nodo_cuero_fino", 130},
		{"nodo_cuero_pesado", 205},
		{"nodo_cuero_grueso", 260},
		{"nodo_cuero_basto", 300},
		{"nodo_pellejo_nodoso", 355},
		{"nodo_cuero_boreal", 450},
	}
	p, _ := m.Profesione("desuello")
	contiene := func(lista []string, id string) bool {
		for _, s := range lista {
			if s == id {
				return true
			}
		}
		return false
	}
	aprendePendientes := func() {
		ep := j.profesiones["desuello"]
		for _, rg := range p.Rangos {
			if ep.Skill >= rg.SkillReq && !contiene(ep.RangosAprendidos, rg.ID) {
				res := j.AprenderRango(m, "desuello", rg.ID)
				if !res.OK {
					t.Fatalf("aprender rango %s (skill=%d): %s", rg.ID, ep.Skill, res.Error)
				}
				ep = j.profesiones["desuello"]
			}
		}
	}
	for _, s := range secuencia {
		aprendePendientes()
		for j.profesiones["desuello"].Skill < s.hasta {
			res := j.Recolectar(m, s.nodo)
			if !res.OK {
				t.Fatalf("desuellar %s (skill=%d): %s", s.nodo, j.profesiones["desuello"].Skill, res.Error)
			}
			aprendePendientes()
			if j.profesiones["desuello"].Skill >= 450 {
				break
			}
		}
		if j.profesiones["desuello"].Skill >= 450 {
			break
		}
	}
	if j.profesiones["desuello"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["desuello"].Skill)
	}
}

// TestDesuellarA450Completo valida la cadena completa 0→450 solo desollando.
func TestDesuellarA450Completo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Desollador", "guerrero", FaccionHorda, "orco")
	j.AprenderProfesion(m, "desuello")
	desuellarA450(t, m, j)
	for _, cuero := range []string{"cuero_ligero", "cuero_fino", "cuero_pesado", "cuero_grueso", "cuero_basto", "cuero_pellejo_nodoso", "cuero_boreal"} {
		if j.CantidadItem(cuero) == 0 {
			t.Errorf("no se desuelló %s durante la secuencia", cuero)
		}
	}
}

// TestDesuelloAlimentaPeleteria valida el eslabón cross-profesión del
// triángulo de recolección: desuellar cuero (Recolectar) → Peletería usa ese
// cuero para craftear. Desuello es la fuente de cueros de Peletería.
func TestDesuelloAlimentaPeleteria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Peletero", "druida", FaccionHorda, "tauren")
	j.AprenderProfesion(m, "desuello")
	j.AprenderProfesion(m, "peleteria")
	// Buscar una receta de Peletería que use un cuero de banda baja
	// (cuero_ligero/fino) para no tener que forzar skill alto.
	pPel, _ := m.Profesione("peleteria")
	recetaID := ""
	cueroUsado := ""
	for _, rc := range pPel.Recetas {
		for _, mat := range rc.Materiales {
			if mat.ItemID == "cuero_ligero" || mat.ItemID == "cuero_fino" {
				recetaID = rc.ID
				cueroUsado = mat.ItemID
				break
			}
		}
		if recetaID != "" {
			break
		}
	}
	if recetaID == "" {
		t.Skip("ninguna receta de peletería usa cuero_ligero/fino — ajustar el test")
	}
	// Mapear el cuero al nodo de desuello correspondiente.
	pDes, _ := m.Profesione("desuello")
	nodoCuero := ""
	for _, nd := range pDes.Nodos {
		if nd.ResultadoID == cueroUsado {
			nodoCuero = nd.ID
			break
		}
	}
	if nodoCuero == "" {
		t.Fatalf("no hay nodo de desuello que produzca %s", cueroUsado)
	}
	// Cantidad de cueros que la receta de peletería pide.
	cantCueros := 0
	for _, rc := range pPel.Recetas {
		if rc.ID == recetaID {
			for _, mat := range rc.Materiales {
				if mat.ItemID == cueroUsado {
					cantCueros = mat.Cantidad
				}
			}
		}
	}
	// 1. Desuellar cueros suficientes (Recolectar).
	for j.CantidadItem(cueroUsado) < cantCueros {
		res := j.Recolectar(m, nodoCuero)
		if !res.OK {
			t.Fatalf("desuellar %s: %s", nodoCuero, res.Error)
		}
	}
	// Dar los demás materiales de la receta de peletería.
	recetaPel := func() DefReceta {
		for _, rc := range pPel.Recetas {
			if rc.ID == recetaID {
				return rc
			}
		}
		return DefReceta{}
	}()
	for _, mat := range recetaPel.Materiales {
		if mat.ItemID != cueroUsado {
			j.AgregarItem(mat.ItemID, mat.Cantidad)
		}
	}
	// Asegurar skill de peletería suficiente.
	if j.profesiones["peleteria"].Skill < recetaPel.SkillReq {
		j.AprenderRango(m, "peleteria", "gran_maestro")
		j.profesiones["peleteria"].Skill = recetaPel.SkillReq
	}
	// 2. Craftear la receta de Peletería con el cuero desollado.
	res := j.Craftear(m, recetaID)
	if !res.OK {
		t.Fatalf("craftear %s de peletería con cuero desollado: %s", recetaID, res.Error)
	}
}

// TestPersistenciaDesuello valida que la profesión se guarda y carga.
func TestPersistenciaDesuello(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Desollador", "guerrero", FaccionHorda, "orco")
	j.AprenderProfesion(m, "desuello")
	desuellarA450(t, m, j)
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Desollador")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "desuello" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["desuello"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["desuello"].Skill)
	}
	if !j2.Recolectar(m, "nodo_cuero_boreal").OK {
		t.Errorf("tras carga, desuellar cuero boreal falló")
	}
}
