// profesiones_test.go valida el sistema de profesiones con Joyería:
// aprender profesión/rango, crafteo (consume materiales, produce ítem,
// sube skill con techo SkillHasta y techo SkillMax), límite de 2 primarias,
// y persistencia de inventario + profesiones.
package mundo

import (
	"path/filepath"
	"testing"

	"aethelgard/servidor/interno/auth"
	"aethelgard/servidor/interno/persistencia"
)

// nuevoMundoProfTest construye un Mundo con persistencia/auth en tmp.
func nuevoMundoProfTest(t *testing.T) *Mundo {
	t.Helper()
	dir := t.TempDir()
	authG, err := auth.NuevoGestor(filepath.Join(dir, "cuentas"))
	if err != nil {
		t.Fatalf("auth: %v", err)
	}
	persist, err := persistencia.NuevoGestor(filepath.Join(dir, "personajes"))
	if err != nil {
		t.Fatalf("persist: %v", err)
	}
	return NuevoMundo(ConfigMundo{Persist: persist, Auth: authG, Hz: 20})
}

// TestAprenderJoyeria valida el aprendizaje inicial y el duplicado.
func TestAprenderJoyeria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Joyero", "mago", FaccionAlianza, "gnomo")

	res := j.AprenderProfesion(m, "joyeria")
	if !res.OK {
		t.Fatalf("aprender joyería: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if res.RangoID != "aprendiz" {
		t.Errorf("rango = %s, esperaba aprendiz", res.RangoID)
	}
	// Duplicado → error.
	res2 := j.AprenderProfesion(m, "joyeria")
	if res2.OK {
		t.Errorf("no debería poder aprender joyería dos veces")
	}
}

// TestMaxProfesionesPrimarias valida el límite de 2 profesiones primarias.
func TestMaxProfesionesPrimarias(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Artesano", "guerrero", FaccionHorda, "orco")
	// Inyectar dos profesiones dummy primarias para tener 3 candidatas.
	m.mu.Lock()
	m.profesiones["dummy_a"] = DefProfesion{ID: "dummy_a", Nombre: "A", Primaria: true, MaxSkill: 75, Rangos: []DefRango{{ID: "aprendiz", SkillReq: 0, SkillMax: 75}}}
	m.profesiones["dummy_b"] = DefProfesion{ID: "dummy_b", Nombre: "B", Primaria: true, MaxSkill: 75, Rangos: []DefRango{{ID: "aprendiz", SkillReq: 0, SkillMax: 75}}}
	m.mu.Unlock()

	if !j.AprenderProfesion(m, "joyeria").OK {
		t.Fatal("aprender joyería")
	}
	if !j.AprenderProfesion(m, "dummy_a").OK {
		t.Fatal("aprender dummy_a")
	}
	// Tercera primaria → debe fallar.
	res := j.AprenderProfesion(m, "dummy_b")
	if res.OK {
		t.Errorf("no debería poder aprender una 3ª profesión primaria")
	}
}

// TestCraftearSubeSkill valida el crafteo: consume materiales, produce el
// ítem y sube la habilidad hasta el techo SkillHasta.
func TestCraftearSubeSkill(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Joyero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "joyeria")

	// Dar 30 barras de cobre (15 crafteos de hilo_cobre_delicado, req 1 hasta 20).
	j.AgregarItem("barra_cobre", 30)

	// Craftear hilo_cobre_delicado (mats: 2 barra_cobre, hasta skill 20) 15 veces.
	for i := 0; i < 15; i++ {
		res := j.Craftear(m, "hilo_cobre_delicado")
		if !res.OK {
			t.Fatalf("crafteo %d falló: %s", i, res.Error)
		}
		if res.ResultadoItemID != "hilo_cobre_delicado" {
			t.Errorf("resultado = %s, esperaba hilo_cobre_delicado", res.ResultadoItemID)
		}
	}
	// Skill debe ser 15 (15 crafteos, todos suben porque < 20).
	if j.profesiones["joyeria"].Skill != 15 {
		t.Errorf("skill = %d, esperaba 15", j.profesiones["joyeria"].Skill)
	}
	// Quedaron 0 barras de cobre (30 - 15*2 = 0) y 15 hilos.
	if j.CantidadItem("barra_cobre") != 0 {
		t.Errorf("barras de cobre restantes = %d, esperaba 0", j.CantidadItem("barra_cobre"))
	}
	if j.CantidadItem("hilo_cobre_delicado") != 15 {
		t.Errorf("hilos = %d, esperaba 15", j.CantidadItem("hilo_cobre_delicado"))
	}

	// Dar más cobre y craftear hasta pasar el techo (hasta 20).
	j.AgregarItem("barra_cobre", 20)
	for i := 0; i < 10; i++ {
		j.Craftear(m, "hilo_cobre_delicado")
	}
	// Skill debe ser 20 (techo SkillHasta), no 25.
	if j.profesiones["joyeria"].Skill != 20 {
		t.Errorf("skill = %d, esperaba 20 (techo SkillHasta)", j.profesiones["joyeria"].Skill)
	}
	// El último crafteo no subió skill.
	ult := j.Craftear(m, "hilo_cobre_delicado")
	if ult.SubioSkill {
		t.Errorf("no debería subir skill por encima de SkillHasta")
	}
}

// TestCraftearSinMateriales valida que el crafteo falla si faltan materiales.
func TestCraftearSinMateriales(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Joyero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "joyeria")
	// Sin materiales.
	res := j.Craftear(m, "hilo_cobre_delicado")
	if res.OK {
		t.Errorf("crafteo sin materiales debería fallar")
	}
	if res.Error == "" {
		t.Errorf("debería incluir mensaje de error")
	}
}

// TestCraftearSkillInsuficiente valida que no se puede craftear una receta
// por encima de la habilidad actual.
func TestCraftearSkillInsuficiente(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Joyero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "joyeria")
	j.AgregarItem("barra_torio", 10) // mats para engarce_torio (req 225)
	res := j.Craftear(m, "engarce_torio")
	if res.OK {
		t.Errorf("no debería poder craftear receta req 225 con skill 0")
	}
}

// TestRangoGating valida que aprender un rango requiere la habilidad mínima
// y sube el techo SkillMax.
func TestRangoGating(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Joyero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "joyeria")
	// Intentar aprender oficial (req 50) con skill 0 → falla.
	if j.AprenderRango(m, "joyeria", "oficial").OK {
		t.Errorf("no debería poder aprender oficial con skill 0")
	}
	// Subir skill a 50 (craftear hilo hasta 20, luego estatua_piedra_ferrica req 20 hasta 30,
	// luego engarce_bronce req 50... pero engarce_bronce req 50 necesita skill 50).
	// Para llegar a 50: hilo (1-20), estatua_ferrica (20-30), sortija_ojo_tigre (30-50).
	j.AgregarItem("barra_cobre", 40)   // 20 hilos
	j.AgregarItem("piedra_ferrica", 80) // 10 estatúas
	j.AgregarItem("ojo_tigre", 25)      // 25 sortijas (necesita hilo_cobre_delicado)
	for i := 0; i < 20; i++ {
		j.Craftear(m, "hilo_cobre_delicado") // sube a 20
	}
	for i := 0; i < 10; i++ {
		j.Craftear(m, "estatua_piedra_ferrica") // sube a 30
	}
	for i := 0; i < 20; i++ {
		j.Craftear(m, "sortija_ojo_tigre") // sube a 50
	}
	if j.profesiones["joyeria"].Skill != 50 {
		t.Fatalf("skill = %d, esperaba 50", j.profesiones["joyeria"].Skill)
	}
	// Ahora sí se puede aprender oficial (req 50) → max 150.
	res := j.AprenderRango(m, "joyeria", "oficial")
	if !res.OK {
		t.Fatalf("aprender oficial: %s", res.Error)
	}
	if res.SkillMax != 150 {
		t.Errorf("skillMax tras oficial = %d, esperaba 150", res.SkillMax)
	}
}

// TestPersistenciaProfesiones valida que el inventario y las profesiones
// se guardan y cargan correctamente.
func TestPersistenciaProfesiones(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Joyero", "mago", FaccionAlianza, "gnomo")
	j.AprenderProfesion(m, "joyeria")
	j.AgregarItem("barra_cobre", 5)
	j.AgregarItem("ojo_tigre", 3)
	// Subir skill a 10.
	j.AgregarItem("barra_cobre", 20) // total 25 → suficientes para ~12 hilos
	for i := 0; i < 12; i++ {
		j.Craftear(m, "hilo_cobre_delicado")
	}

	// Guardar.
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	// Cargar.
	p, err := m.persist.Cargar("Joyero")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.InventarioStacks) == 0 {
		t.Errorf("inventario persistido vacío")
	}
	// Verificar que el cobre restante y los hilos están.
	cobre := 0
	hilos := 0
	for _, st := range p.InventarioStacks {
		if st.ItemID == "barra_cobre" {
			cobre = st.Cantidad
		}
		if st.ItemID == "hilo_cobre_delicado" {
			hilos = st.Cantidad
		}
	}
	if cobre != 1 { // 25 - 12*2 = 1
		t.Errorf("cobre persistido = %d, esperaba 1", cobre)
	}
	if hilos != 12 {
		t.Errorf("hilos persistidos = %d, esperaba 12", hilos)
	}
	// Verificar profesión persistida.
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "joyeria" {
		t.Errorf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 12 {
		t.Errorf("skill persistida = %d, esperaba 12", p.Profesiones[0].Skill)
	}

	// Reconstruir el jugador desde persistencia y verificar estado.
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.CantidadItem("hilo_cobre_delicado") != 12 {
		t.Errorf("hilos tras carga = %d, esperaba 12", j2.CantidadItem("hilo_cobre_delicado"))
	}
	if j2.profesiones["joyeria"] == nil {
		t.Fatalf("profesión joyería no cargada")
	}
	if j2.profesiones["joyeria"].Skill != 12 {
		t.Errorf("skill tras carga = %d, esperaba 12", j2.profesiones["joyeria"].Skill)
	}
}

// TestRecetasJoyeriaCompletas valida que la profesión de Joyería tiene las
// 34 recetas esperadas y los 6 rangos, cubriendo 1-450.
func TestRecetasJoyeriaCompletas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("joyeria")
	if !ok {
		t.Fatal("joyería no existe")
	}
	if len(p.Recetas) != 36 {
		t.Errorf("recetas de joyería = %d, esperaba 36", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos de joyería = %d, esperaba 6", len(p.Rangos))
	}
	// La primera receta empieza en skill 0 (se craftea desde el inicio), la última llega hasta 450.
	if p.Recetas[0].SkillReq != 0 {
		t.Errorf("primera receta req = %d, esperaba 0", p.Recetas[0].SkillReq)
	}
	ultimoHasta := p.Recetas[len(p.Recetas)-1].SkillHasta
	if ultimoHasta != 450 {
		t.Errorf("última receta hasta = %d, esperaba 450", ultimoHasta)
	}
	// Gran Maestro req 350 max 450.
	var gm DefRango
	for _, rg := range p.Rangos {
		if rg.ID == "gran_maestro" {
			gm = rg
		}
	}
	if gm.SkillReq != 350 || gm.SkillMax != 450 {
		t.Errorf("gran_maestro = %+v, esperaba req 350 max 450", gm)
	}
}
