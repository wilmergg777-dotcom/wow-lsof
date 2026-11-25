// razas_clases_test.go valida el sistema de razas y clases de WoW 3.3.5a:
// las 10 razas (5 Alianza + 5 Horda) con su matriz raza-clase COMPLETA
// (incluido el DK universal), los raciales (activos + pasivos) como catálogo
// fiel al 3.3.5a, las 10 clases con roles, el bonus racial de profesión y la
// validación RazaPermiteClase.
package mundo

import "testing"

// matrizRazaClaseEsperada es la matriz raza-clase de WoW 3.3.5a tal como la
// especifica el diseño del juego (DK disponible para todas las razas).
var matrizRazaClaseEsperada = map[string][]string{
	// Alianza
	"humano":          {"guerrero", "paladin", "picaro", "sacerdote", "mago", "brujo", "caballero_muerte"},
	"enano":           {"guerrero", "picaro", "cazador", "sacerdote", "caballero_muerte"},
	"elfo_nocturno":   {"guerrero", "cazador", "picaro", "sacerdote", "druida", "caballero_muerte"},
	"gnomo":           {"guerrero", "picaro", "mago", "brujo", "caballero_muerte"},
	"draenei":         {"guerrero", "paladin", "cazador", "sacerdote", "chaman", "mago", "caballero_muerte"},
	// Horda
	"orco":            {"guerrero", "cazador", "picaro", "chaman", "brujo", "caballero_muerte"},
	"no_muerto":       {"guerrero", "picaro", "sacerdote", "mago", "brujo", "caballero_muerte"},
	"tauren":          {"guerrero", "cazador", "chaman", "druida", "caballero_muerte"},
	"troll":           {"guerrero", "cazador", "picaro", "sacerdote", "chaman", "mago", "druida", "caballero_muerte"},
	"elfo_de_sangre":  {"paladin", "cazador", "picaro", "sacerdote", "mago", "brujo", "caballero_muerte"},
}

// todasLasClases es el conjunto de las 10 clases jugables.
var todasLasClases = []string{
	"guerrero", "paladin", "cazador", "picaro", "sacerdote", "mago", "brujo",
	"chaman", "druida", "caballero_muerte",
}

// contiene helper.
func contieneStr(lista []string, s string) bool {
	for _, x := range lista {
		if x == s {
			return true
		}
	}
	return false
}

// TestDiezRazasYDiezClases valida que el catálogo tiene exactamente 10 razas
// (5+5) y 10 clases.
func TestDiezRazasYDiezClases(t *testing.T) {
	m := nuevoMundoProfTest(t)
	razas := m.Razas()
	if len(razas) != 10 {
		t.Errorf("razas = %d, esperaba 10", len(razas))
	}
	ali, hor := 0, 0
	for _, r := range razas {
		switch r.Faccion {
		case FaccionAlianza:
			ali++
		case FaccionHorda:
			hor++
		default:
			t.Errorf("raza %s facción inválida %q", r.ID, r.Faccion)
		}
	}
	if ali != 5 || hor != 5 {
		t.Errorf("facciones: alianza=%d horda=%d, esperaba 5+5", ali, hor)
	}
	clases := m.Clases()
	if len(clases) != 10 {
		t.Errorf("clases = %d, esperaba 10", len(clases))
	}
	for _, c := range todasLasClases {
		if _, ok := clases[c]; !ok {
			t.Errorf("clase %q no existe", c)
		}
	}
}

// TestMatrizRazaClase valida que RazaPermiteClase coincide EXACTAMENTE con la
// matriz esperada de 3.3.5a: cada combinación permitida devuelve true, y cada
// combinación NO permitida devuelve false. Recorre las 10 razas × 10 clases.
func TestMatrizRazaClase(t *testing.T) {
	m := nuevoMundoProfTest(t)
	for razaID, permitidas := range matrizRazaClaseEsperada {
		r, ok := m.Raza(razaID)
		if !ok {
			t.Fatalf("raza %q no existe", razaID)
		}
		// La raza debe listar exactamente las clases permitidas.
		if len(r.Clases) != len(permitidas) {
			t.Errorf("raza %s: %d clases listadas, esperaba %d", razaID, len(r.Clases), len(permitidas))
		}
		for _, clase := range todasLasClases {
			esperado := contieneStr(permitidas, clase)
			obtenido := m.RazaPermiteClase(razaID, clase)
			if obtenido != esperado {
				t.Errorf("RazaPermiteClase(%s, %s) = %v, esperaba %v", razaID, clase, obtenido, esperado)
			}
		}
	}
}

// TestDKUniversal valida que el Caballero de la Muerte está disponible para
// TODAS las 10 razas (rasgo heroico de WotLK).
func TestDKUniversal(t *testing.T) {
	m := nuevoMundoProfTest(t)
	for razaID := range matrizRazaClaseEsperada {
		if !m.RazaPermiteClase(razaID, "caballero_muerte") {
			t.Errorf("el DK debería estar disponible para la raza %s", razaID)
		}
	}
}

// TestClasesNuevasRoles valida que las 3 clases añadidas (Chamán, Druida, DK)
// existen con el rol correcto para la trinidad del buscador de masmorras.
func TestClasesNuevasRoles(t *testing.T) {
	m := nuevoMundoProfTest(t)
	casos := []struct {
		clase, rol string
		habs       int
	}{
		{"chaman", RolSoporte, 2},
		{"druida", RolSoporte, 2},
		{"caballero_muerte", RolTanque, 2},
	}
	for _, c := range casos {
		cl, ok := m.Clases()[c.clase]
		if !ok {
			t.Errorf("clase %q no existe", c.clase)
			continue
		}
		if cl.Rol != c.rol {
			t.Errorf("clase %s rol=%q, esperaba %q", c.clase, cl.Rol, c.rol)
		}
		if len(cl.Habilidades) != c.habs {
			t.Errorf("clase %s tiene %d habilidades, esperaba %d", c.clase, len(cl.Habilidades), c.habs)
		}
	}
	// La trinidad queda cubierta por la adición del DK y Chamán/Drida:
	// tanques (guerrero, paladin, DK), soportes (sacerdote, chaman, druida),
	// dps (cazador, picaro, mago, brujo).
	roles := map[string]int{}
	for _, cl := range m.Clases() {
		roles[cl.Rol]++
	}
	if roles[RolTanque] < 3 {
		t.Errorf("tanques = %d, esperaba ≥3 (guerrero, paladin, DK)", roles[RolTanque])
	}
	if roles[RolSoporte] < 3 {
		t.Errorf("soportes = %d, esperaba ≥3 (sacerdote, chaman, druida)", roles[RolSoporte])
	}
	if roles[RolDPS] < 4 {
		t.Errorf("dps = %d, esperaba ≥4 (cazador, picaro, mago, brujo)", roles[RolDPS])
	}
}

// TestRacialesCatalogo valida que cada raza lista sus raciales (activos +
// pasivos) fieles al 3.3.5a, con tipos válidos y al menos un racial.
func TestRacialesCatalogo(t *testing.T) {
	m := nuevoMundoProfTest(t)
	// Mínimo de raciales por raza (según el 3.3.5a).
	esperados := map[string]int{
		"humano": 5, "enano": 5, "elfo_nocturno": 4, "gnomo": 4, "draenei": 4,
		"orco": 4, "no_muerto": 4, "tauren": 4, "troll": 5, "elfo_de_sangre": 3,
	}
	for razaID, n := range esperados {
		r, ok := m.Raza(razaID)
		if !ok {
			t.Errorf("raza %q no existe", razaID)
			continue
		}
		if len(r.Raciales) < n {
			t.Errorf("raza %s: %d raciales, esperaba ≥%d", razaID, len(r.Raciales), n)
		}
		tieneActivo := false
		tienePasivo := false
		for _, rc := range r.Raciales {
			if rc.Tipo != "activo" && rc.Tipo != "pasivo" {
				t.Errorf("raza %s racial %q tipo inválido %q", razaID, rc.Nombre, rc.Tipo)
			}
			if rc.Tipo == "activo" {
				tieneActivo = true
			} else {
				tienePasivo = true
			}
		}
		if !tieneActivo {
			t.Errorf("raza %s debería tener al menos un racial activo", razaID)
		}
		if !tienePasivo {
			t.Errorf("raza %s debería tener al menos un racial pasivo", razaID)
		}
	}
}

// TestRacialesBonusProfesion valida que los raciales de bonus de profesión se
// aplican al aprender la profesión: el jugador arranca con esa cantidad de
// skill. Tauren+Herboristería=15, Gnomo+Ingeniería=15, Draenei+Joyería=5,
// Elfo de Sangre+Encantamiento=10.
func TestRacialesBonusProfesion(t *testing.T) {
	m := nuevoMundoProfTest(t)
	casos := []struct {
		raza, prof string
		bonus      int
	}{
		{"tauren", "herboristeria", 15},
		{"gnomo", "ingenieria", 15},
		{"draenei", "joyeria", 5},
		{"elfo_de_sangre", "encantamiento", 10},
	}
	for _, c := range casos {
		// La raza debe declarar el bonus.
		r, _ := m.Raza(c.raza)
		if r.BonusProfesionID != c.prof || r.BonusProfesionPuntos != c.bonus {
			t.Errorf("raza %s bonus=%q/%d, esperaba %q/%d", c.raza, r.BonusProfesionID, r.BonusProfesionPuntos, c.prof, c.bonus)
			continue
		}
		// Crear un PJ de esa raza (con una clase permitida) y aprender la prof.
		clase := r.Clases[0] // primera clase permitida
		fac := r.Faccion
		j := crearJugadorTest(t, m, "Bonus"+c.raza, clase, fac, c.raza)
		res := j.AprenderProfesion(m, c.prof)
		if !res.OK {
			t.Errorf("raza %s: aprender %s falló: %s", c.raza, c.prof, res.Error)
			continue
		}
		if res.Skill != c.bonus {
			t.Errorf("raza %s + %s: skill inicial = %d, esperaba %d (bonus racial)", c.raza, c.prof, res.Skill, c.bonus)
		}
		if j.profesiones[c.prof].Skill != c.bonus {
			t.Errorf("raza %s + %s: skill persistida = %d, esperaba %d", c.raza, c.prof, j.profesiones[c.prof].Skill, c.bonus)
		}
	}
}

// TestBonusProfesionSoloAplicaARazaCorrecta valida que el bonus racial NO se
// aplica a una raza sin ese bonus (un humano aprendiendo herboristería arranca
// a 0, no a 15).
func TestBonusProfesionSoloAplicaARazaCorrecta(t *testing.T) {
	m := nuevoMundoProfTest(t)
	// Humano no tiene bonus de herboristería → skill inicial 0.
	j := crearJugadorTest(t, m, "HumanoHerb", "mago", FaccionAlianza, "humano")
	res := j.AprenderProfesion(m, "herboristeria")
	if !res.OK {
		t.Fatalf("aprender herboristeria: %s", res.Error)
	}
	if res.Skill != 0 {
		t.Errorf("humano sin bonus racial debería arrancar a 0, tiene %d", res.Skill)
	}
}

// TestCrearPJClasesNuevas valida que se puede crear un PJ de cada clase nueva
// con una raza permitida (NuevoJugadorCreado no falla y aplica el rol).
func TestCrearPJClasesNuevas(t *testing.T) {
	m := nuevoMundoProfTest(t)
	casos := []struct {
		raza, clase string
	}{
		{"draenei", "chaman"},
		{"elfo_nocturno", "druida"},
		{"orco", "caballero_muerte"},       // DK de Horda
		{"humano", "caballero_muerte"},     // DK de Alianza
	}
	for _, c := range casos {
		if !m.RazaPermiteClase(c.raza, c.clase) {
			t.Errorf("matriz: %s no permite %s", c.raza, c.clase)
			continue
		}
		r, _ := m.Raza(c.raza)
		j := NuevoJugadorCreado("Test"+c.raza+c.clase, c.clase, r.Faccion, c.raza, "cuenta_test", m)
		if j == nil {
			t.Errorf("NuevoJugadorCreado devolvió nil para %s %s", c.raza, c.clase)
			continue
		}
		if j.Rol() == "" {
			t.Errorf("PJ %s %s sin rol", c.raza, c.clase)
		}
	}
}
