// inscripcion_test.go valida Inscripción (Inscription), la profesión con la
// CADENA DE TRES PASOS más larga del juego: moler hierbas → pigmento,
// combinar pigmento → tinta, fabricar tinta → glifo/pergamino. Los tres
// pasos usan el verbo Craftear (moler = craftear hierbas→pigmento). Además
// consume las hierbas de Herboristería (eslabón recolección→producción).
package mundo

import "testing"

// TestInscripcionCatalogo valida el catálogo de Inscripción.
func TestInscripcionCatalogo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("inscripción")
	if !ok {
		t.Fatal("inscripción no existe")
	}
	if len(p.Recetas) != 43 {
		t.Errorf("recetas de inscripción = %d, esperaba 43", len(p.Recetas))
	}
	if len(p.Nodos) != 0 {
		t.Errorf("inscripción es producción pura, no debería tener nodos: %d", len(p.Nodos))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos = %d, esperaba 6", len(p.Rangos))
	}
	// Cada receta produce un item registrado y consume materiales.
	for _, rc := range p.Recetas {
		if _, ok := m.Item(rc.ResultadoID); !ok {
			t.Errorf("receta %s produce item desconocido %q", rc.ID, rc.ResultadoID)
		}
		if len(rc.Materiales) == 0 {
			t.Errorf("receta %s no consume materiales", rc.ID)
		}
		for _, mat := range rc.Materiales {
			if _, ok := m.Item(mat.ItemID); !ok {
				t.Errorf("receta %s consume item desconocido %q", rc.ID, mat.ItemID)
			}
		}
	}
	// Cobertura contigua 0→450 por recetas (la vía principal de la guía).
	for skill := 0; skill < 450; skill++ {
		cubre := false
		for _, rc := range p.Recetas {
			if rc.SkillReq <= skill && skill < rc.SkillHasta {
				cubre = true
				break
			}
		}
		if !cubre {
			t.Errorf("hueco de cobertura de recetas en skill %d", skill)
		}
	}
}

// TestAprenderInscripcion valida el aprendizaje.
func TestAprenderInscripcion(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Escribano", "mago", FaccionAlianza, "humano")
	res := j.AprenderProfesion(m, "inscripción")
	if !res.OK {
		t.Fatalf("aprender inscripción: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
}

// TestMolerHierbaAPigmento valida el PASO 1 de la cadena: moler (milling)
// consume 5 hierbas y produce 1 pigmento. Moler es Craftear con hierbas
// como material — no hace falta un verbo nuevo.
func TestMolerHierbaAPigmento(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Escribano", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "inscripción")
	j.AgregarItem("flor_de_paz", 5)
	res := j.Craftear(m, "moler_alabastro")
	if !res.OK {
		t.Fatalf("moler_alabastro: %s", res.Error)
	}
	if res.ResultadoItemID != "pigmento_alabastro" {
		t.Errorf("moler_alabastro produce %q, esperaba pigmento_alabastro", res.ResultadoItemID)
	}
	if j.CantidadItem("flor_de_paz") != 0 {
		t.Errorf("moler debería consumir 5 flor_de_paz: queda %d", j.CantidadItem("flor_de_paz"))
	}
	if j.CantidadItem("pigmento_alabastro") != 1 {
		t.Errorf("pigmento_alabastro = %d, esperaba 1", j.CantidadItem("pigmento_alabastro"))
	}
}

// TestCadenaMolerTintaGlifo valida la CADENA COMPLETA de 3 pasos: moler
// hierba → pigmento → tinta → glifo. Es la cadena de intermedios más larga
// del juego (3 eslabones vs. 2 de Ingeniería/Encantamiento). Además valida
// el eslabón cross-profesión: la hierba inicial es un producto de
// Herboristería.
func TestCadenaMolerTintaGlifo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Escribano", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "inscripción")
	j.AprenderRango(m, "inscripción", "oficial") // skillMax 150 para llegar a 80+
	j.profesiones["inscripción"].Skill = 80       // dentro de la banda de glifo_inicial
	// Paso 1: moler 5 flor_de_paz (hierba de Herboristería) → pigmento_alabastro.
	j.AgregarItem("flor_de_paz", 5)
	if !j.Craftear(m, "moler_alabastro").OK {
		t.Fatal("moler_alabastro falló en la cadena")
	}
	if j.CantidadItem("pigmento_alabastro") != 1 {
		t.Fatalf("paso 1: pigmento_alabastro = %d, esperaba 1", j.CantidadItem("pigmento_alabastro"))
	}
	// Paso 2: combinar pigmento → tinta_marfil.
	if !j.Craftear(m, "tinta_marfil").OK {
		t.Fatal("tinta_marfil falló en la cadena")
	}
	if j.CantidadItem("tinta_marfil") != 1 {
		t.Fatalf("paso 2: tinta_marfil = %d, esperaba 1", j.CantidadItem("tinta_marfil"))
	}
	if j.CantidadItem("pigmento_alabastro") != 0 {
		t.Errorf("paso 2 debería consumir el pigmento: queda %d", j.CantidadItem("pigmento_alabastro"))
	}
	// Paso 3: fabricar tinta → glifo_inicial.
	if !j.Craftear(m, "glifo_inicial").OK {
		t.Fatal("glifo_inicial falló en la cadena")
	}
	if j.CantidadItem("glifo_inicial") != 1 {
		t.Fatalf("paso 3: glifo_inicial = %d, esperaba 1", j.CantidadItem("glifo_inicial"))
	}
	if j.CantidadItem("tinta_marfil") != 0 {
		t.Errorf("paso 3 debería consumir la tinta: queda %d", j.CantidadItem("tinta_marfil"))
	}
}

// inscripcionA450 sube la habilidad a 450 crafteando la cadena de recetas
// (tintas + pergamino final), dando los pigmentos/tinta necesarios y
// aprendiendo rangos pendientes.
func inscripcionA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	// Dar pigmentos para las tintas de cada banda + tinta_avalancha para el
	// pergamino final (400-450).
	j.AgregarItem("pigmento_alabastro", 100)
	j.AgregarItem("pigmento_verdeante", 100)
	j.AgregarItem("pigmento_dorado", 100)
	j.AgregarItem("pigmento_esmeralda", 100)
	j.AgregarItem("pigmento_violeta", 100)
	j.AgregarItem("pigmento_rubí", 100)
	j.AgregarItem("pigmento_plata", 100)
	j.AgregarItem("pigmento_zafiro", 100)
	j.AgregarItem("pigmento_abisal", 100)
	j.AgregarItem("pigmento_azur", 100)
	j.AgregarItem("tinta_avalancha", 100)
	secuencia := []struct {
		receta string
		hasta  int
	}{
		{"tinta_marfil", 75},
		{"tinta_medianoche", 130},
		{"tinta_león", 150},
		{"tinta_estrella_alba", 175},
		{"tinta_fuego_jade", 200},
		{"tinta_real", 225},
		{"tinta_celestial", 250},
		{"tinta_fulgurante", 300},
		{"tinta_cielo", 350},
		{"tinta_mar", 400},
		{"pergamino_aguante_viii", 450},
	}
	p, _ := m.Profesione("inscripción")
	contiene := func(lista []string, id string) bool {
		for _, s := range lista {
			if s == id {
				return true
			}
		}
		return false
	}
	aprendePendientes := func() {
		ep := j.profesiones["inscripción"]
		for _, rg := range p.Rangos {
			if ep.Skill >= rg.SkillReq && !contiene(ep.RangosAprendidos, rg.ID) {
				res := j.AprenderRango(m, "inscripción", rg.ID)
				if !res.OK {
					t.Fatalf("aprender rango %s (skill=%d): %s", rg.ID, ep.Skill, res.Error)
				}
				ep = j.profesiones["inscripción"]
			}
		}
	}
	for _, s := range secuencia {
		for j.profesiones["inscripción"].Skill < s.hasta {
			aprendePendientes()
			res := j.Craftear(m, s.receta)
			if !res.OK {
				t.Fatalf("craftear %s (skill=%d): %s", s.receta, j.profesiones["inscripción"].Skill, res.Error)
			}
			if j.profesiones["inscripción"].Skill >= 450 {
				break
			}
		}
		if j.profesiones["inscripción"].Skill >= 450 {
			break
		}
	}
	if j.profesiones["inscripción"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["inscripción"].Skill)
	}
}

// TestInscripcionA450Completo valida la cadena completa 0→450.
func TestInscripcionA450Completo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Escribano", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "inscripción")
	inscripcionA450(t, m, j)
	// El jugador produce tintas de varias bandas.
	for _, tinta := range []string{"tinta_marfil", "tinta_celestial", "tinta_mar"} {
		if j.CantidadItem(tinta) == 0 {
			t.Errorf("no se crafteó %s durante la secuencia", tinta)
		}
	}
}

// TestInscripcionConsumeHerboristeria valida el eslabón cross-profesión: la
// hierba que Inscripción muele es un producto de Herboristería (su nodo la
// produce). Inscripción es el segundo consumidor de hierbas (con Alquimia).
func TestInscripcionConsumeHerboristeria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	// Verificar que la hierba flor_de_paz es producida por un nodo de
	// Herboristería (eslabón recolección→producción).
	pHerb, ok := m.Profesione("herboristeria")
	if !ok {
		t.Fatal("herboristeria no existe")
	}
	nodoFlor := ""
	for _, nd := range pHerb.Nodos {
		if nd.ResultadoID == "flor_de_paz" {
			nodoFlor = nd.ID
			break
		}
	}
	if nodoFlor == "" {
		t.Fatal("ningún nodo de herboristería produce flor_de_paz")
	}
	// Recoger la hierba con Herboristería y molerla con Inscripción.
	j := crearJugadorTest(t, m, "Escribano", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "herboristeria")
	j.AprenderProfesion(m, "inscripción")
	// Recoger 5 flor_de_paz (necesarias para moler).
	for j.CantidadItem("flor_de_paz") < 5 {
		res := j.Recolectar(m, nodoFlor)
		if !res.OK {
			t.Fatalf("recoger %s: %s", nodoFlor, res.Error)
		}
	}
	// Moler las hierbas recogidas → pigmento (eslabón cerrado).
	res := j.Craftear(m, "moler_alabastro")
	if !res.OK {
		t.Fatalf("moler flor_de_paz recogida por herboristería: %s", res.Error)
	}
	if j.CantidadItem("pigmento_alabastro") != 1 {
		t.Errorf("pigmento_alabastro = %d, esperaba 1 tras moler hierba de herboristería", j.CantidadItem("pigmento_alabastro"))
	}
}

// TestPersistenciaInscripcion valida que la profesión se guarda y carga.
func TestPersistenciaInscripcion(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Escribano", "mago", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "inscripción")
	inscripcionA450(t, m, j)
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Escribano")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "inscripción" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["inscripción"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["inscripción"].Skill)
	}
	// Tras cargar, puede seguir crafteando.
	j2.AgregarItem("pigmento_alabastro", 5)
	if !j2.Craftear(m, "tinta_marfil").OK {
		t.Errorf("tras carga, craftear tinta_marfil falló")
	}
}
