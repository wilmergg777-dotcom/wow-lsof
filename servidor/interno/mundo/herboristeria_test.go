// herboristeria_test.go valida la primera profesión de RECOLECCIÓN del juego.
// A diferencia de las 7 profesiones de crafteo, Herboristería no tiene
// Recetas: sube recogiendo hierbas de Nodos con Recolectar (sin consumir
// materiales). Las hierbas recolectadas son los materiales que consume
// Alquimia — el eslabón cross-profesión recolección → crafteo.
package mundo

import (
	"testing"
)

// TestNodosHerboristeriaCompletos valida el catálogo de Herboristería.
func TestNodosHerboristeriaCompletos(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("herboristeria")
	if !ok {
		t.Fatal("herboristeria no existe")
	}
	if len(p.Nodos) != 25 {
		t.Errorf("nodos de herboristeria = %d, esperaba 25", len(p.Nodos))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos = %d, esperaba 6", len(p.Rangos))
	}
	if len(p.Recetas) != 0 {
		t.Errorf("herboristeria no debería tener recetas (es recolección), tiene %d", len(p.Recetas))
	}
	if len(p.Especializaciones) != 0 {
		t.Errorf("herboristeria no tiene especializaciones, tiene %d", len(p.Especializaciones))
	}
	// El primer nodo debe ser recolectable desde skill 0 (SkillReq == 0).
	primero := true
	for _, nd := range p.Nodos {
		if primero && nd.SkillReq != 0 {
			t.Errorf("primer nodo %s SkillReq=%d, esperaba 0 (skill inicial es 0)", nd.ID, nd.SkillReq)
		}
		primero = false
		// Cada nodo produce una hierba registrada.
		if _, ok := m.Item(nd.ResultadoID); !ok {
			t.Errorf("nodo %s produce item desconocido %q", nd.ID, nd.ResultadoID)
		}
		if nd.SkillHasta <= nd.SkillReq {
			t.Errorf("nodo %s SkillHasta=%d <= SkillReq=%d (debe dar skill)", nd.ID, nd.SkillHasta, nd.SkillReq)
		}
	}
	// Cobertura contigua 0→450: para cada skill 0..449 debe existir al menos
	// un nodo con SkillReq <= skill < SkillHasta.
	for skill := 0; skill < 450; skill++ {
		cubre := false
		for _, nd := range p.Nodos {
			if nd.SkillReq <= skill && skill < nd.SkillHasta {
				cubre = true
				break
			}
		}
		if !cubre {
			t.Errorf("hueco de cobertura en skill %d (ningún nodo da skill ahí)", skill)
		}
	}
}

// TestAprenderHerboristeria valida el aprendizaje inicial.
func TestAprenderHerboristeria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herborista", "druida", FaccionAlianza, "elfo_de_noche")
	res := j.AprenderProfesion(m, "herboristeria")
	if !res.OK {
		t.Fatalf("aprender herboristeria: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if j.AprenderProfesion(m, "herboristeria").OK {
		t.Errorf("no debería poder aprender herboristeria dos veces")
	}
}

// TestRecolectarHerboristeria valida que Recolectar produce la hierba y sube
// skill SIN consumir materiales (a diferencia de Craftear).
func TestRecolectarHerboristeria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herborista", "druida", FaccionAlianza, "elfo_de_noche")
	j.AprenderProfesion(m, "herboristeria")
	// Recolectar Hojaplata (SkillReq 0, SkillHasta 65) desde skill 0.
	res := j.Recolectar(m, "nodo_hojaplata")
	if !res.OK {
		t.Fatalf("recolectar nodo_hojaplata: %s", res.Error)
	}
	if !res.SubioSkill {
		t.Errorf("debería subir skill recolectando dentro de la banda")
	}
	if j.profesiones["herboristeria"].Skill != 1 {
		t.Errorf("skill tras recolectar = %d, esperaba 1", j.profesiones["herboristeria"].Skill)
	}
	// La hierba se añade al inventario.
	if j.CantidadItem("hojaplata") != 1 {
		t.Errorf("hojaplata = %d, esperaba 1", j.CantidadItem("hojaplata"))
	}
	// Recolectar no requiere/consume materiales: el inventario solo tiene la
	// hierba recién recolectada (no había nada antes).
	if len(j.inventario) != 1 {
		t.Errorf("inventario debería tener solo la hierba (sin consumo), tiene %d items", len(j.inventario))
	}
	// Gating por skill: no puede recolectar un nodo de skill alto.
	res = j.Recolectar(m, "nodo_espina_de_hielo") // SkillReq 430
	if res.OK {
		t.Errorf("no debería poder recolectar Espina de hielo con skill 1")
	}
	if res.Error == "" {
		t.Errorf("debería devolver error de habilidad insuficiente")
	}
}

// TestRecolectarSinSkillHasta valida que un nodo deja de dar skill al llegar
// a SkillHasta, pero sigue produciendo la hierba (farmerío de materiales).
func TestRecolectarSinSkillHasta(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herborista", "druida", FaccionHorda, "tauren")
	j.AprenderProfesion(m, "herboristeria")
	j.AprenderRango(m, "herboristeria", "gran_maestro")
	// Poner skill exactamente en SkillHasta de hojaplata (65).
	j.profesiones["herboristeria"].Skill = 65
	res := j.Recolectar(m, "nodo_hojaplata")
	if !res.OK {
		t.Fatalf("recolectar nodo_hojaplata en el tope: %s", res.Error)
	}
	if res.SubioSkill {
		t.Errorf("no debería subir skill en el SkillHasta (65)")
	}
	if j.profesiones["herboristeria"].Skill != 65 {
		t.Errorf("skill cambió a %d, esperaba 65 (tope del nodo)", j.profesiones["herboristeria"].Skill)
	}
	if j.CantidadItem("hojaplata") != 1 {
		t.Errorf("debería producir la hierba aunque no dé skill: hojaplata=%d", j.CantidadItem("hojaplata"))
	}
}

// recolectarA450 sube la habilidad de herboristería a 450 recogiendo el nodo
// adecuado para cada banda. Demuestra que la cobertura de nodos es contigua
// (siempre hay un nodo que da skill en cada nivel). Tras cada recolección
// aprende los rangos pendientes: cuando el skill alcanza el SkillMax del
// rango actual, gathering deja de dar skill, así que hay que aprender el
// rango superior antes de poder seguir subiendo.
func recolectarA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	// Secuencia de nodos para cubrir 0→450: cada uno se recolecta hasta su
	// SkillHasta, luego se pasa al siguiente que cubre el tramo siguiente.
	secuencia := []struct {
		nodo  string
		hasta int
	}{
		{"nodo_hojaplata", 65},
		{"nodo_raíz_de_tierra", 90},
		{"nodo_marregal", 115},
		{"nodo_brezospina", 130},
		{"nodo_vidarraíz", 175},
		{"nodo_espina_de_oro", 200},
		{"nodo_solea", 215},
		{"nodo_mostacho_de_khadgar", 230},
		{"nodo_carolina", 245},
		{"nodo_sansam_dorado", 275},
		{"nodo_salviargenta_de_montaña", 300},
		{"nodo_hierba_vil", 335},
		{"nodo_gloria_de_ensueño", 355},
		{"nodo_flor_abisal", 365},
		{"nodo_velada", 375},
		{"nodo_trébol_de_oro", 410},
		{"nodo_lirio_atigrado", 430},
		{"nodo_lengua_de_víboris", 435},
		{"nodo_espina_de_hielo", 450},
	}
	p, _ := m.Profesione("herboristeria")
	contiene := func(lista []string, id string) bool {
		for _, s := range lista {
			if s == id {
				return true
			}
		}
		return false
	}
	aprendePendientes := func() {
		ep := j.profesiones["herboristeria"]
		for _, rg := range p.Rangos {
			if ep.Skill >= rg.SkillReq && !contiene(ep.RangosAprendidos, rg.ID) {
				res := j.AprenderRango(m, "herboristeria", rg.ID)
				if !res.OK {
					t.Fatalf("aprender rango %s (skill=%d): %s", rg.ID, ep.Skill, res.Error)
				}
				ep = j.profesiones["herboristeria"]
			}
		}
	}
	for _, s := range secuencia {
		aprendePendientes()
		for j.profesiones["herboristeria"].Skill < s.hasta {
			res := j.Recolectar(m, s.nodo)
			if !res.OK {
				t.Fatalf("recolectar %s (skill=%d): %s", s.nodo, j.profesiones["herboristeria"].Skill, res.Error)
			}
			aprendePendientes()
			if j.profesiones["herboristeria"].Skill >= 450 {
				break
			}
		}
		if j.profesiones["herboristeria"].Skill >= 450 {
			break
		}
	}
	if j.profesiones["herboristeria"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["herboristeria"].Skill)
	}
}

// TestRecolectarA450Completo valida la cadena completa 0→450 solo recogiendo.
func TestRecolectarA450Completo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herborista", "druida", FaccionAlianza, "elfo_de_noche")
	j.AprenderProfesion(m, "herboristeria")
	recolectarA450(t, m, j)
	// El jugador ha acumulado hierbas (materiales para Alquimia) — al menos
	// una de cada banda crítica.
	for _, hierba := range []string{"hojaplata", "raíz_de_tierra", "brezospina", "hierba_vil", "trébol_de_oro", "espina_de_hielo"} {
		if j.CantidadItem(hierba) == 0 {
			t.Errorf("no se recolectó %s durante la secuencia", hierba)
		}
	}
}

// TestHerboristeriaAlimentaAlquimia valida el eslabón cross-profesión: una
// hierba recolectada con Herboristería sirve como material para craftear una
// poción de Alquimia. (Demuestra que recolección → crafteo funciona.)
func TestHerboristeriaAlimentaAlquimia(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Alquimista", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "herboristeria")
	j.AprenderProfesion(m, "alquimia")
	// Recolectar suficiente Flor de paz y Hojaplata (materiales de la Poción
	// menor de sanación de Alquimia). Miramos una receta de alquimia que use
	// hojaplata o flor_de_paz para confirmar el eslabón.
	pAlq, _ := m.Profesione("alquimia")
	recetaUsaHierba := ""
	hierbaNecesaria := ""
	for _, rc := range pAlq.Recetas {
		for _, mat := range rc.Materiales {
			if mat.ItemID == "hojaplata" || mat.ItemID == "flor_de_paz" || mat.ItemID == "marregal" {
				recetaUsaHierba = rc.ID
				hierbaNecesaria = mat.ItemID
				break
			}
		}
		if recetaUsaHierba != "" {
			break
		}
	}
	if recetaUsaHierba == "" {
		t.Skip("ninguna receta de alquimia usa hojaplata/flor_de_paz/marregal — ajustar el test")
	}
	// Recolectar la hierba necesaria: buscar un nodo que la produzca.
	pHerb, _ := m.Profesione("herboristeria")
	nodoHierba := ""
	for _, nd := range pHerb.Nodos {
		if nd.ResultadoID == hierbaNecesaria {
			nodoHierba = nd.ID
			break
		}
	}
	if nodoHierba == "" {
		t.Fatalf("no hay nodo que produzca %s", hierbaNecesaria)
	}
	// Recolectar hasta tener la cantidad que la receta pide.
	receta := func() DefReceta {
		for _, rc := range pAlq.Recetas {
			if rc.ID == recetaUsaHierba {
				return rc
			}
		}
		return DefReceta{}
	}()
	cantNecesaria := 0
	for _, mat := range receta.Materiales {
		if mat.ItemID == hierbaNecesaria {
			cantNecesaria = mat.Cantidad
		}
	}
	for j.CantidadItem(hierbaNecesaria) < cantNecesaria {
		res := j.Recolectar(m, nodoHierba)
		if !res.OK {
			t.Fatalf("recolectar %s: %s", nodoHierba, res.Error)
		}
	}
	// Dar los demás materiales de la receta y craftear.
	for _, mat := range receta.Materiales {
		if mat.ItemID != hierbaNecesaria {
			j.AgregarItem(mat.ItemID, mat.Cantidad)
		}
	}
	res := j.Craftear(m, recetaUsaHierba)
	if !res.OK {
		t.Fatalf("craftear %s con hierbas recolectadas: %s", recetaUsaHierba, res.Error)
	}
}

// TestPersistenciaHerboristeria valida que la profesión de recolección se
// guarda y carga tras subir a 450.
func TestPersistenciaHerboristeria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herborista", "druida", FaccionAlianza, "elfo_de_noche")
	j.AprenderProfesion(m, "herboristeria")
	recolectarA450(t, m, j)
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Herborista")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "herboristeria" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["herboristeria"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["herboristeria"].Skill)
	}
	// Tras cargar, puede seguir recolectando.
	res := j2.Recolectar(m, "nodo_espina_de_hielo")
	if !res.OK {
		t.Errorf("tras carga, recolectar espina de hielo: %s", res.Error)
	}
}
