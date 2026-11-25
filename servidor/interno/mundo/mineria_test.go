// mineria_test.go valida la segunda profesión de recolección y la PRIMERA
// HÍBRIDA del juego: Minería combina Nodos (picar vetas, verbo Recolectar,
// sin consumo) con Recetas de FUNDICIÓN (mena → barra, verbo Craftear,
// consume menas). Las barras producidas son los materiales que consumen
// Herrería, Joyería e Ingeniería — el eslabón cross-profesión más importante.
package mundo

import "testing"

// TestMineriaCatalogo valida el catálogo híbrido de Minería (nodos + recetas).
func TestMineriaCatalogo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("minería")
	if !ok {
		t.Fatal("minería no existe")
	}
	if len(p.Nodos) != 14 {
		t.Errorf("nodos de minería = %d, esperaba 14", len(p.Nodos))
	}
	if len(p.Recetas) != 15 {
		t.Errorf("recetas (fundición) = %d, esperaba 15", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos = %d, esperaba 6", len(p.Rangos))
	}
	// Minería es la primera profesión con AMBOS Nodos y Recetas.
	if len(p.Nodos) == 0 || len(p.Recetas) == 0 {
		t.Errorf("minería debería ser híbrida (nodos Y recetas), nodos=%d recetas=%d", len(p.Nodos), len(p.Recetas))
	}
	// Cada nodo produce una mena registrada; el primer nodo desde skill 0.
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
	// Cada receta de fundición produce una barra y consume menas/barras.
	for _, rc := range p.Recetas {
		if _, ok := m.Item(rc.ResultadoID); !ok {
			t.Errorf("receta %s produce item desconocido %q", rc.ID, rc.ResultadoID)
		}
		if len(rc.Materiales) == 0 {
			t.Errorf("receta de fundición %s no consume materiales", rc.ID)
		}
	}
	// Cobertura contigua 0→450 por NODOS (la vía principal de la guía).
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

// TestAprenderMineria valida el aprendizaje inicial.
func TestAprenderMineria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Minero", "guerrero", FaccionAlianza, "enano")
	res := j.AprenderProfesion(m, "minería")
	if !res.OK {
		t.Fatalf("aprender minería: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if j.AprenderProfesion(m, "minería").OK {
		t.Errorf("no debería poder aprender minería dos veces")
	}
}

// TestPicarVetaMineria valida que Recolectar (picar veta) produce la mena y
// sube skill SIN consumir materiales — igual que Herboristería.
func TestPicarVetaMineria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Minero", "guerrero", FaccionHorda, "orco")
	j.AprenderProfesion(m, "minería")
	res := j.Recolectar(m, "nodo_cobre")
	if !res.OK {
		t.Fatalf("picar nodo_cobre: %s", res.Error)
	}
	if !res.SubioSkill {
		t.Errorf("debería subir skill picando dentro de la banda")
	}
	if j.profesiones["minería"].Skill != 1 {
		t.Errorf("skill tras picar = %d, esperaba 1", j.profesiones["minería"].Skill)
	}
	if j.CantidadItem("mena_cobre") != 1 {
		t.Errorf("mena_cobre = %d, esperaba 1", j.CantidadItem("mena_cobre"))
	}
	// Picar no consume materiales: el inventario solo tiene la mena.
	if len(j.inventario) != 1 {
		t.Errorf("inventario debería tener solo la mena (sin consumo), tiene %d", len(j.inventario))
	}
	// Gating por skill: no puede picar saronita (req 400) con skill 1.
	if j.Recolectar(m, "nodo_saronita").OK {
		t.Errorf("no debería poder picar saronita con skill 1")
	}
}

// TestFundirMenaEnBarra valida que una receta de FUNDICIÓN consume la mena y
// produce la barra (vía Craftear). Demuestra que Minería es híbrida: Recolectar
// produce menas, Craftear las funde en barras.
func TestFundirMenaEnBarra(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Minero", "guerrero", FaccionAlianza, "enano")
	j.AprenderProfesion(m, "minería")
	// Dar menas de cobre y fundir.
	j.AgregarItem("mena_cobre", 3)
	antes := j.CantidadItem("mena_cobre")
	res := j.Craftear(m, "fundir_cobre")
	if !res.OK {
		t.Fatalf("fundir cobre: %s", res.Error)
	}
	if res.ResultadoItemID != "barra_cobre" {
		t.Errorf("fundir_cobre produce %q, esperaba barra_cobre", res.ResultadoItemID)
	}
	if j.CantidadItem("mena_cobre") != antes-1 {
		t.Errorf("fundir debería consumir 1 mena_cobre: antes=%d después=%d", antes, j.CantidadItem("mena_cobre"))
	}
	if j.CantidadItem("barra_cobre") != 1 {
		t.Errorf("barra_cobre = %d, esperaba 1", j.CantidadItem("barra_cobre"))
	}
}

// TestAleacionFundicion valida las aleaciones (bronce = cobre+estaño,
// acero = hierro+carbón): consumen BARRAS (no menas) y producen la barra
// de aleación.
func TestAleacionFundicion(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Minero", "guerrero", FaccionAlianza, "enano")
	j.AprenderProfesion(m, "minería")
	// Forzar skill 75 (rango de fundir_bronce) sin pasar por todo el leveling.
	j.profesiones["minería"].Skill = 75
	// Bronce: 1 barra_cobre + 1 barra_estaño → 1 barra_bronce.
	j.AgregarItem("barra_cobre", 1)
	j.AgregarItem("barra_estaño", 1)
	res := j.Craftear(m, "fundir_bronce")
	if !res.OK {
		t.Fatalf("fundir bronce: %s", res.Error)
	}
	if res.ResultadoItemID != "barra_bronce" {
		t.Errorf("fundir_bronce produce %q, esperaba barra_bronce", res.ResultadoItemID)
	}
	if j.CantidadItem("barra_cobre") != 0 || j.CantidadItem("barra_estaño") != 0 {
		t.Errorf("la aleación debería consumir ambas barras: cobre=%d estaño=%d", j.CantidadItem("barra_cobre"), j.CantidadItem("barra_estaño"))
	}
}

// picarA450 sube la habilidad de minería a 450 picando vetas (la vía de la
// guía), aprendiendo rangos pendientes tras cada recolección.
func picarA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	secuencia := []struct {
		nodo  string
		hasta int
	}{
		{"nodo_cobre", 65},
		{"nodo_estaño", 125},
		{"nodo_hierro", 175},
		{"nodo_mitril", 250},
		{"nodo_torio", 300},
		{"nodo_hierro_vil", 330},
		{"nodo_adamantita", 375},
		{"nodo_cobalto", 400},
		{"nodo_saronita", 450},
	}
	p, _ := m.Profesione("minería")
	contiene := func(lista []string, id string) bool {
		for _, s := range lista {
			if s == id {
				return true
			}
		}
		return false
	}
	aprendePendientes := func() {
		ep := j.profesiones["minería"]
		for _, rg := range p.Rangos {
			if ep.Skill >= rg.SkillReq && !contiene(ep.RangosAprendidos, rg.ID) {
				res := j.AprenderRango(m, "minería", rg.ID)
				if !res.OK {
					t.Fatalf("aprender rango %s (skill=%d): %s", rg.ID, ep.Skill, res.Error)
				}
				ep = j.profesiones["minería"]
			}
		}
	}
	for _, s := range secuencia {
		aprendePendientes()
		for j.profesiones["minería"].Skill < s.hasta {
			res := j.Recolectar(m, s.nodo)
			if !res.OK {
				t.Fatalf("picar %s (skill=%d): %s", s.nodo, j.profesiones["minería"].Skill, res.Error)
			}
			aprendePendientes()
			if j.profesiones["minería"].Skill >= 450 {
				break
			}
		}
		if j.profesiones["minería"].Skill >= 450 {
			break
		}
	}
	if j.profesiones["minería"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["minería"].Skill)
	}
}

// TestPicarA450Completo valida la cadena completa 0→450 solo picando vetas.
func TestPicarA450Completo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Minero", "guerrero", FaccionAlianza, "enano")
	j.AprenderProfesion(m, "minería")
	picarA450(t, m, j)
	// El jugador acumula menas de cada banda crítica.
	for _, mena := range []string{"mena_cobre", "mena_estaño", "mena_hierro", "mena_mitril", "mena_torio", "mena_cobalto", "mena_saronita"} {
		if j.CantidadItem(mena) == 0 {
			t.Errorf("no se picó %s durante la secuencia", mena)
		}
	}
}

// TestMineriaAlimentaHerreria valida el eslabón cross-profesión completo:
// picar mena (Recolectar) → fundir barra (Craftear fundición) → la barra la
// consume una receta de Herrería (Craftear herrería). Es el bucle económico
// central del juego: recolección → fundición → crafteo metálico.
func TestMineriaAlimentaHerreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herrero", "paladín", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "minería")
	j.AprenderProfesion(m, "herreria")
	// Encontrar una receta de Herrería que use barra_cobalto (o barra_de_saronita
	// / barra_hierro_vil) — las barras que Herrería realmente consume.
	pHer, _ := m.Profesione("herreria")
	recetaID := ""
	barraUsada := ""
	for _, rc := range pHer.Recetas {
		for _, mat := range rc.Materiales {
			if mat.ItemID == "barra_cobalto" || mat.ItemID == "barra_de_saronita" || mat.ItemID == "barra_hierro_vil" {
				recetaID = rc.ID
				barraUsada = mat.ItemID
				break
			}
		}
		if recetaID != "" {
			break
		}
	}
	if recetaID == "" {
		t.Skip("ninguna receta de herrería usa barra_cobalto/saronita/hierro_vil — ajustar el test")
	}
	// Mapear la barra a la mena y a la receta de fundición correspondientes.
	barraAMena := map[string]string{
		"barra_cobalto":      "mena_cobalto",
		"barra_de_saronita":  "mena_saronita",
		"barra_hierro_vil":   "mena_hierro_vil",
	}
	barraARecetaFundicion := map[string]string{
		"barra_cobalto":      "fundir_cobalto",
		"barra_de_saronita":  "fundir_saronita",
		"barra_hierro_vil":   "fundir_hierro_vil",
	}
	mena := barraAMena[barraUsada]
	recetaFund := barraARecetaFundicion[barraUsada]
	// Cantidad de barras que la receta de herrería pide.
	cantBarras := 0
	for _, rc := range pHer.Recetas {
		if rc.ID == recetaID {
			for _, mat := range rc.Materiales {
				if mat.ItemID == barraUsada {
					cantBarras = mat.Cantidad
				}
			}
		}
	}
	// Menas por barra según la receta de fundición (saronita = 2, resto = 1).
	menasPorBarra := 1
	pMin, _ := m.Profesione("minería")
	for _, rc := range pMin.Recetas {
		if rc.ID == recetaFund {
			for _, mat := range rc.Materiales {
				if mat.ItemID == mena {
					menasPorBarra = mat.Cantidad
				}
			}
		}
	}
	nodoMena := ""
	for _, nd := range pMin.Nodos {
		if nd.ResultadoID == mena {
			nodoMena = nd.ID
			break
		}
	}
	if nodoMena == "" {
		t.Fatalf("no hay nodo que produzca %s", mena)
	}
	// Aprender rangos para poder picar el nodo (si es de skill alto).
	j.AprenderRango(m, "minería", "gran_maestro")
	// Si el nodo requiere skill alto, forzar la habilidad de minería al rango
	// del nodo para poder picarlo (el test es del eslabón, no del leveling).
	for _, nd := range pMin.Nodos {
		if nd.ID == nodoMena {
			if j.profesiones["minería"].Skill < nd.SkillReq {
				j.profesiones["minería"].Skill = nd.SkillReq
			}
			break
		}
	}
	// 1. Picar menas suficientes para todas las barras necesarias.
	menasNecesarias := cantBarras * menasPorBarra
	for j.CantidadItem(mena) < menasNecesarias {
		res := j.Recolectar(m, nodoMena)
		if !res.OK {
			t.Fatalf("picar %s: %s", nodoMena, res.Error)
		}
	}
	// 2. Fundir las menas en barras (Craftear fundición).
	for j.CantidadItem(barraUsada) < cantBarras {
		res := j.Craftear(m, recetaFund)
		if !res.OK {
			t.Fatalf("fundir %s: %s", recetaFund, res.Error)
		}
	}
	if j.CantidadItem(barraUsada) < cantBarras {
		t.Fatalf("barras insuficientes: %d < %d", j.CantidadItem(barraUsada), cantBarras)
	}
	// Dar los demás materiales de la receta de herrería.
	for _, rc := range pHer.Recetas {
		if rc.ID == recetaID {
			for _, mat := range rc.Materiales {
				if mat.ItemID != barraUsada {
					j.AgregarItem(mat.ItemID, mat.Cantidad)
				}
			}
		}
	}
	// Asegurar skill de herrería suficiente para la receta.
	recetaHer := func() DefReceta {
		for _, rc := range pHer.Recetas {
			if rc.ID == recetaID {
				return rc
			}
		}
		return DefReceta{}
	}()
	if j.profesiones["herreria"].Skill < recetaHer.SkillReq {
		j.AprenderRango(m, "herreria", "gran_maestro")
		j.profesiones["herreria"].Skill = recetaHer.SkillReq
	}
	// 3. Craftear la receta de Herrería con la barra fundida.
	res := j.Craftear(m, recetaID)
	if !res.OK {
		t.Fatalf("craftear %s de herrería con barra fundida: %s", recetaID, res.Error)
	}
}

// TestPersistenciaMineria valida que la profesión híbrida se guarda y carga.
func TestPersistenciaMineria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Minero", "guerrero", FaccionAlianza, "enano")
	j.AprenderProfesion(m, "minería")
	picarA450(t, m, j)
	// Acumular algunas barras vía fundición para persistir items también.
	j.AgregarItem("mena_cobre", 5)
	for i := 0; i < 5; i++ {
		j.Craftear(m, "fundir_cobre")
	}
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Minero")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "minería" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["minería"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["minería"].Skill)
	}
	// Tras cargar, puede seguir picando y fundiendo.
	if !j2.Recolectar(m, "nodo_saronita").OK {
		t.Errorf("tras carga, picar saronita falló")
	}
}
