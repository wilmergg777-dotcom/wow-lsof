// herreria_test.go valida la profesión de Herrería: catálogo completo (38
// recetas, 6 rangos, árbol de 5 especializaciones anidadas en 2 niveles),
// el crafteo 0-450 con dos inserciones en mitad de banda (la Piedra de
// pulir sólida dentro de los Brazales de escamas de oro, y el aprendizaje
// de artesano dentro del Yelmo de placas de acero) y el árbol de
// especializaciones Forjador de armaduras / Forjador de armas →
// (hachas / martillos / invocador).
package mundo

import (
	"testing"
)

// TestRecetasHerreriaCompletas valida el catálogo de Herrería.
func TestRecetasHerreriaCompletas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	p, ok := m.Profesione("herreria")
	if !ok {
		t.Fatal("herreria no existe")
	}
	if len(p.Recetas) != 38 {
		t.Errorf("recetas de herreria = %d, esperaba 38", len(p.Recetas))
	}
	if len(p.Rangos) != 6 {
		t.Errorf("rangos de herreria = %d, esperaba 6", len(p.Rangos))
	}
	if len(p.Especializaciones) != 5 {
		t.Errorf("especializaciones de herreria = %d, esperaba 5", len(p.Especializaciones))
	}
	// 2 de nivel superior (sin padre) + 3 sub-maestrías (con padre=armas).
	superiores, sub := 0, 0
	for _, e := range p.Especializaciones {
		if e.RequiereEspecializacion == "" {
			superiores++
		} else {
			sub++
		}
	}
	if superiores != 2 || sub != 3 {
		t.Errorf("árbol especializaciones = %d superiores / %d sub, esperaba 2/3", superiores, sub)
	}
	// Debe producir al menos un arma y refuerzos.
	tipos := map[string]bool{}
	for _, r := range p.Recetas {
		if d, ok := m.Item(r.ResultadoID); ok {
			tipos[d.Tipo] = true
		}
	}
	if !tipos[TipoArma] {
		t.Errorf("herreria debería producir al menos un arma")
	}
	if !tipos[TipoRefuerzo] {
		t.Errorf("herreria debería producir refuerzos (hebilla/cadena/punta)")
	}
}

// TestAprenderHerreria valida el aprendizaje inicial.
func TestAprenderHerreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herrero", "guerrero", FaccionAlianza, "humano")
	res := j.AprenderProfesion(m, "herreria")
	if !res.OK {
		t.Fatalf("aprender herreria: %s", res.Error)
	}
	if res.SkillMax != 75 {
		t.Errorf("skillMax tras aprendiz = %d, esperaba 75", res.SkillMax)
	}
	if j.AprenderProfesion(m, "herreria").OK {
		t.Errorf("no debería poder aprender herreria dos veces")
	}
}

// TestCraftearHerreria valida el crafteo básico y que la Piedra de pulir
// pesada es a la vez producto y material (se consume al craftear los
// Brazales de escamas de oro).
func TestCraftearHerreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herrero", "guerrero", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "herreria")
	j.AgregarItem("piedra_basta", 5)
	for i := 0; i < 5; i++ {
		res := j.Craftear(m, "piedra_afilar_basta")
		if !res.OK {
			t.Fatalf("craftear piedra de afilar basta #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("piedra_afilar_basta") != 5 {
		t.Errorf("piedra de afilar basta = %d, esperaba 5", j.CantidadItem("piedra_afilar_basta"))
	}
	if j.CantidadItem("piedra_basta") != 0 {
		t.Errorf("la piedra basta no se consumió correctamente")
	}
	// La Piedra de pulir pesada es producto (req 125) y material de los
	// Brazales de escamas de oro. Subimos skill a 185 y verificamos la
	// cadena de consumo.
	j.AprenderRango(m, "herreria", "gran_maestro")
	j.profesiones["herreria"].Skill = 185
	j.AgregarItem("piedra_pesada", 6) // 2 piedras de pulir pesada (cada una 3 piedra pesada)
	for i := 0; i < 2; i++ {
		if res := j.Craftear(m, "piedra_pulir_pesada"); !res.OK {
			t.Fatalf("craftear piedra de pulir pesada #%d: %s", i, res.Error)
		}
	}
	if j.CantidadItem("piedra_pulir_pesada") != 2 {
		t.Errorf("piedra de pulir pesada = %d, esperaba 2", j.CantidadItem("piedra_pulir_pesada"))
	}
}

// subirHerreriaA450 sube la habilidad de herrería a 450 crafteando la
// secuencia completa de la guía, con dos inserciones en mitad de banda:
// la Piedra de pulir sólida dentro de los Brazales de escamas de oro
// (185→200, piedra 200→210, brazales 210→215) y el aprendizaje de
// artesano dentro del Yelmo de placas de acero (215→225 experto,
// artesano, 225→235).
func subirHerreriaA450(t *testing.T, m *Mundo, j *Jugador) {
	t.Helper()
	for id, n := range map[string]int{
		"piedra_basta": 125, "piedra_burda": 128, "lingote_plata": 5, "lingote_bronce": 120,
		"piedra_pesada": 195, "lingote_oro": 5, "lingote_hierro": 200, "lingote_acero": 410,
		"piedra_sólida": 128, "lingote_mitril": 150, "tela_paño_mágico": 90, "piedra_densa": 15,
		"lingote_torio": 680, "barra_hierro_vil": 215, "barra_cobalto": 320, "cuero_basto": 40,
		"barra_de_saronita": 708, "tierra_eterna": 50, "aire_cristalizado": 32,
		"titanio": 10, "sombra_eterna": 14, "agua_eterna": 15,
	} {
		j.AgregarItem(id, n)
	}
	crafts := func(receta string, n int) {
		for i := 0; i < n; i++ {
			res := j.Craftear(m, receta)
			if !res.OK {
				t.Fatalf("craftear %s #%d (skill=%d): %s", receta, i, j.profesiones["herreria"].Skill, res.Error)
			}
		}
	}
	aprende := func(rango string) {
		res := j.AprenderRango(m, "herreria", rango)
		if !res.OK {
			t.Fatalf("aprender rango %s (skill=%d): %s", rango, j.profesiones["herreria"].Skill, res.Error)
		}
	}
	// Classic 1-75 (aprendiz)
	crafts("piedra_afilar_basta", 25) // 0→25
	crafts("piedra_pulir_basta", 40)  // 25→65
	crafts("piedra_afilar_burda", 10) // 65→75
	aprende("oficial")
	// 75-150 (oficial)
	crafts("piedra_pulir_burda", 25)      // 75→100
	crafts("vara_plata_herreria", 5)      // 100→105
	crafts("leotardos_bronce_basto", 20)  // 105→125
	crafts("piedra_pulir_pesada", 25)     // 125→150
	aprende("experto")
	// 150-225 (experto)
	crafts("vara_oro_herreria", 5)        // 150→155
	crafts("leotardos_hierro_verde", 10)  // 155→165
	crafts("brazales_hierro_verde", 20)   // 165→185
	crafts("brazales_escamas_oro", 15)    // 185→200
	crafts("piedra_pulir_sólida", 10)     // 200→210 (inserción)
	crafts("brazales_escamas_oro", 5)     // 210→215
	crafts("yelmo_placas_acero", 10)      // 215→225 (techo experto)
	aprende("artesano")
	// 225-300 (artesano)
	crafts("yelmo_placas_acero", 10)      // 225→235 (continúa tras artesano)
	crafts("almofar_mitril", 15)          // 235→250
	crafts("piedra_afilar_densa", 10)     // 250→260
	crafts("brazales_torio", 15)          // 260→275
	crafts("brazales_placas_imperiales", 20) // 275→295
	crafts("botas_torio", 5)              // 295→300 (techo artesano)
	aprende("maestro")
	// 300-350 (TBC)
	crafts("almofar_anillas_hierro_vil", 15) // 300→315
	crafts("guantes_anillas_hierro_vil", 5)  // 315→320
	crafts("brazales_anillas_hierro_vil", 5) // 320→325
	crafts("runa_amparo_inferior", 5)        // 325→330
	crafts("coraza_hierro_vil", 10)          // 330→340
	crafts("resguardo_escudo_inferior", 10)  // 340→350
	aprende("gran_maestro")
	// 350-450 (WotLK)
	crafts("botas_cobalto", 10)              // 350→360
	crafts("escudo_triangular_cobalto", 10)  // 360→370
	crafts("quijotes_cobalto", 5)            // 370→375
	crafts("guantesletes_cobalto", 5)        // 375→380
	crafts("botas_cobalto_con_púas", 5)      // 380→385
	crafts("hombreras_cobalto_con_púas", 5)  // 385→390
	crafts("hacha_guerra_cobalto_dentada", 5) // 390→395
	crafts("cinturón_saronita_brillante", 5) // 395→400
	crafts("yelmo_cobalto_cuernudo", 5)      // 400→405
	crafts("daga_saronita_mortal", 11)       // 405→416
	crafts("hebilla_cinturón_eterna", 9)     // 416→425
	crafts("cadena_arma_titanio", 5)         // 425→430
	crafts("guampolas_imponentes", 5)        // 430→435
	crafts("quijotes_imponentes", 15)        // 435→450
	if j.profesiones["herreria"].Skill != 450 {
		t.Fatalf("skill = %d, esperaba 450 tras la secuencia", j.profesiones["herreria"].Skill)
	}
}

// TestSubirHerreriaCompleto valida la cadena completa 0→450 de la guía,
// incluyendo las dos inserciones en mitad de banda.
func TestSubirHerreriaCompleto(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herrero", "guerrero", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "herreria")
	subirHerreriaA450(t, m, j)
	// Los Quijotes imponentes (producto final) deben estar en el inventario.
	if j.CantidadItem("quijotes_imponentes") != 15 {
		t.Errorf("quijotes imponentes = %d, esperaba 15", j.CantidadItem("quijotes_imponentes"))
	}
	// La Hebilla de cinturón eterna (refuerzo épico) se crafteó.
	if j.CantidadItem("hebilla_cinturón_eterna") != 9 {
		t.Errorf("hebilla eterna = %d, esperaba 9", j.CantidadItem("hebilla_cinturón_eterna"))
	}
}

// TestArbolEspecializacionesHerreria valida el árbol anidado de dos niveles:
// dos ramas de nivel superior (armaduras/armas), tres sub-maestrías bajo
// armas (hachas/martillos/invocador), el bloqueo de doble rama superior, el
// requisito de padre para las sub-maestrías, y el reemplazo del padre por la
// hoja al aprender una sub-maestría.
func TestArbolEspecializacionesHerreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	// (a) Rama superior Forjador de armaduras a skill 200.
	j := crearJugadorTest(t, m, "Herrero1", "guerrero", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "herreria")
	j.AprenderRango(m, "herreria", "artesano")
	j.profesiones["herreria"].Skill = 200
	j.AgregarItem("yelmo_mitril_ornamentado", 4)
	j.AgregarItem("botas_mitril_ornamentadas", 2)
	j.AgregarItem("peto_mitril_ornamentado", 1)
	if res := j.AprenderEspecializacion(m, "herreria", "armaduras"); !res.OK {
		t.Fatalf("aprender forjador de armaduras: %s", res.Error)
	}
	if j.profesiones["herreria"].Especializacion != "armaduras" {
		t.Errorf("estado = %q, esperaba armaduras", j.profesiones["herreria"].Especializacion)
	}
	// No se puede aprender una segunda rama superior (armas).
	if j.AprenderEspecializacion(m, "herreria", "armas").OK {
		t.Errorf("no debería poder aprender una segunda rama superior")
	}
	// Con armaduras no se puede aprender una sub-maestría (requiere armas).
	j.AgregarItem("piedra_serpiente_voshgajin", 1)
	if j.AprenderEspecializacion(m, "herreria", "hachas").OK {
		t.Errorf("no debería poder aprender hachas sin ser forjador de armas")
	}

	// (b) Rama superior Forjador de armas → sub-maestría hachas.
	j2 := crearJugadorTest(t, m, "Herrero2", "guerrero", FaccionHorda, "orco")
	j2.AprenderProfesion(m, "herreria")
	j2.AprenderRango(m, "herreria", "artesano")
	j2.profesiones["herreria"].Skill = 200
	j2.AgregarItem("sable_acero_lunar", 4)
	j2.AgregarItem("maza_negra_grande", 2)
	j2.AgregarItem("hacha_mitril_pesado", 2)
	j2.AgregarItem("hacha_hierro_macizo", 4)
	if res := j2.AprenderEspecializacion(m, "herreria", "armas"); !res.OK {
		t.Fatalf("aprender forjador de armas: %s", res.Error)
	}
	if j2.profesiones["herreria"].Especializacion != "armas" {
		t.Errorf("estado = %q, esperaba armas", j2.profesiones["herreria"].Especializacion)
	}
	// Sub-maestría hachas requiere skill 225; a 200 debe fallar.
	j2.AgregarItem("piedra_serpiente_voshgajin", 1)
	if j2.AprenderEspecializacion(m, "herreria", "hachas").OK {
		t.Errorf("no debería poder aprender hachas con skill 200 (req 225)")
	}
	// A 225 sí se puede: reemplaza armas por la hoja hachas.
	j2.profesiones["herreria"].Skill = 225
	if res := j2.AprenderEspecializacion(m, "herreria", "hachas"); !res.OK {
		t.Fatalf("aprender maestro forjador de hachas: %s", res.Error)
	}
	if j2.profesiones["herreria"].Especializacion != "hachas" {
		t.Errorf("estado = %q, esperaba hachas (hoja)", j2.profesiones["herreria"].Especializacion)
	}
	// Ya con la hoja hachas no se puede aprender otra sub-maestría
	// (martillos requiere estado=armas, pero es hachas).
	j2.AgregarItem("delantal_herrero_martillos_carmesi", 1)
	if j2.AprenderEspecializacion(m, "herreria", "martillos").OK {
		t.Errorf("no debería poder aprender martillos siendo hachas")
	}
	// Ni volver a una rama superior.
	j2.AgregarItem("yelmo_mitril_ornamentado", 4)
	j2.AgregarItem("botas_mitril_ornamentadas", 2)
	j2.AgregarItem("peto_mitril_ornamentado", 1)
	if j2.AprenderEspecializacion(m, "herreria", "armaduras").OK {
		t.Errorf("no debería poder aprender armaduras teniendo ya una especialización")
	}
}

// TestPersistenciaHerreria valida que la profesión y la especialización hoja
// se guardan y cargan correctamente tras subir a 450 y elegir una
// sub-maestría (armas → invocador).
func TestPersistenciaHerreria(t *testing.T) {
	m := nuevoMundoProfTest(t)
	j := crearJugadorTest(t, m, "Herrero", "guerrero", FaccionAlianza, "humano")
	j.AprenderProfesion(m, "herreria")
	subirHerreriaA450(t, m, j)
	// Armas (top) → invocador (sub).
	j.AgregarItem("sable_acero_lunar", 4)
	j.AgregarItem("maza_negra_grande", 2)
	j.AgregarItem("hacha_mitril_pesado", 2)
	j.AgregarItem("hacha_hierro_macizo", 4)
	if res := j.AprenderEspecializacion(m, "herreria", "armas"); !res.OK {
		t.Fatalf("aprender forjador de armas: %s", res.Error)
	}
	j.AgregarItem("insignia_guarda_negra", 1)
	if res := j.AprenderEspecializacion(m, "herreria", "invocador"); !res.OK {
		t.Fatalf("aprender maestro invocador: %s", res.Error)
	}
	if j.profesiones["herreria"].Especializacion != "invocador" {
		t.Fatalf("estado = %q, esperaba invocador", j.profesiones["herreria"].Especializacion)
	}
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar("Herrero")
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	if len(p.Profesiones) != 1 || p.Profesiones[0].ProfesionID != "herreria" {
		t.Fatalf("profesión no persistida: %+v", p.Profesiones)
	}
	if p.Profesiones[0].Skill != 450 {
		t.Errorf("skill persistida = %d, esperaba 450", p.Profesiones[0].Skill)
	}
	if p.Profesiones[0].Especializacion != "invocador" {
		t.Errorf("especializacion persistida = %q, esperaba invocador", p.Profesiones[0].Especializacion)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, "cuenta_test")
	if j2.profesiones["herreria"].Skill != 450 {
		t.Errorf("skill tras carga = %d, esperaba 450", j2.profesiones["herreria"].Skill)
	}
	if j2.profesiones["herreria"].Especializacion != "invocador" {
		t.Errorf("especializacion tras carga = %q, esperaba invocador", j2.profesiones["herreria"].Especializacion)
	}
}
