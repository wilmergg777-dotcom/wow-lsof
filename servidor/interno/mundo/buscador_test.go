// buscador_test.go valida el matchmaking cross-faction del buscador:
// tres jugadores de facciones y roles distintos deben formar un grupo
// PvE y entrar en una instancia; cuatro jugadores deben formar un 2v2 PvP.
package mundo

import (
	"path/filepath"
	"testing"
	"time"

	"aethelgard/servidor/interno/auth"
	"aethelgard/servidor/interno/persistencia"
)

// nuevoMundoTest construye un Mundo con persistencia/auth en tmp.
// NO arranca el tick loop (no llama a Iniciar): el test controla el
// momento de llamar a procesar para evitar carreras con el tick.
func nuevoMundoTest(t *testing.T) *Mundo {
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

// crearJugadorTest crea un Jugador con clase/faccion/raza dados y lo agrega al mundo.
func crearJugadorTest(t *testing.T, m *Mundo, nombre, clase, faccion, raza string) *Jugador {
	t.Helper()
	j := NuevoJugadorCreado(nombre, clase, faccion, raza, "cuenta_test", m)
	m.AgregarJugador(j)
	return j
}

func TestBuscadorPvEMatchCrossFaction(t *testing.T) {
	m := nuevoMundoTest(t)

	// Tres jugadores de facciones Y roles distintos: guerrero/alianza/humano
	// (tanque), sacerdote/horda/no_muerto (soporte), mago/alianza/gnomo (dps).
	// Nivel 6 para cumplir NivelMin=5 de hollow_crypt (masmora lvl 7-10).
	tanque := crearJugadorTest(t, m, "Tanque", "guerrero", FaccionAlianza, "humano")
	soporte := crearJugadorTest(t, m, "Curandero", "sacerdote", FaccionHorda, "no_muerto")
	dps := crearJugadorTest(t, m, "Dannador", "mago", FaccionAlianza, "gnomo")
	for _, j := range []*Jugador{tanque, soporte, dps} {
		j.nivel = 6
	}

	// Los tres a la cola de la misma masmora (cross-faction).
	if err := m.Buscador().EntrarColaPvE(tanque, "hollow_crypt"); err != nil {
		t.Fatalf("entrar tanque: %v", err)
	}
	if err := m.Buscador().EntrarColaPvE(soporte, "hollow_crypt"); err != nil {
		t.Fatalf("entrar soporte: %v", err)
	}
	if err := m.Buscador().EntrarColaPvE(dps, "hollow_crypt"); err != nil {
		t.Fatalf("entrar dps: %v", err)
	}

	// Procesar el buscador (simula un tick de step()).
	m.Buscador().procesar(time.Now())

	// Debe existir exactamente una instancia con los 3 jugadores.
	m.mu.RLock()
	instCount := len(m.instancias)
	m.mu.RUnlock()
	if instCount != 1 {
		t.Fatalf("esperaba 1 instancia, hay %d", instCount)
	}

	// Validar que los 3 están en la instancia con equipo -1 (PvE).
	for _, j := range []*Jugador{tanque, soporte, dps} {
		if j.instanciaID == "" {
			t.Errorf("jugador %s no entró en instancia", j.nombre)
		}
		if j.equipo != -1 {
			t.Errorf("jugador %s debería tener equipo -1 (PvE), tiene %d", j.nombre, j.equipo)
		}
		t.Logf("%s (%s/%s, %s) en instancia %s", j.nombre, j.faccion, j.raza, j.rol, j.instanciaID)
	}

	// Validar que facciones distintas coexisten (cross-faction real).
	facciones := map[string]bool{}
	for _, j := range []*Jugador{tanque, soporte, dps} {
		facciones[j.faccion] = true
	}
	if len(facciones) < 2 {
		t.Errorf("esperaba al menos 2 facciones en el grupo (cross-faction), hay %d", len(facciones))
	}

	// Validar que la masmora tiene su boss (HP boosteado).
	m.mu.RLock()
	var boss *Enemigo
	bossCount := 0
	mobCount := 0
	for _, e := range m.enemigos {
		if e.instanciaID == tanque.instanciaID {
			mobCount++
		}
	}
	for _, inst := range m.instancias {
		if inst.bossID != "" {
			if b, ok := m.enemigos[inst.bossID]; ok {
				boss = b
				bossCount++
			}
		}
	}
	m.mu.RUnlock()
	if bossCount != 1 {
		t.Errorf("esperaba 1 boss, hay %d", bossCount)
	}
	if boss == nil {
		t.Fatalf("boss no encontrado")
	}
	// hollow_crypt boss: Morthen, hpBase 100 + 22*10 = 320, ×3 = 960.
	if boss.hpMax < 300 {
		t.Errorf("boss debería tener HP boosteado (~960), tiene %d", boss.hpMax)
	}
	t.Logf("boss %s (HP %d, danoBase %d) + %d mobs en la instancia", boss.nombre, boss.hpMax, boss.danoBase, mobCount)
}

func TestBuscadorPvPMatchCrossFaction(t *testing.T) {
	m := nuevoMundoTest(t)

	// 4 jugadores para arena 2v2 (cross-faction: 2 alianza + 2 horda).
	j1 := crearJugadorTest(t, m, "J1", "guerrero", FaccionAlianza, "humano")
	j2 := crearJugadorTest(t, m, "J2", "mago", FaccionHorda, "no_muerto")
	j3 := crearJugadorTest(t, m, "J3", "sacerdote", FaccionAlianza, "humano")
	j4 := crearJugadorTest(t, m, "J4", "guerrero", FaccionHorda, "orco")

	for _, j := range []*Jugador{j1, j2, j3, j4} {
		if err := m.Buscador().EntrarColaPvP(j, "arena_skolm"); err != nil {
			t.Fatalf("entrar %s: %v", j.nombre, err)
		}
	}

	m.Buscador().procesar(time.Now())

	m.mu.RLock()
	instCount := len(m.instancias)
	m.mu.RUnlock()
	if instCount != 1 {
		t.Fatalf("esperaba 1 arena, hay %d", instCount)
	}

	// Cada jugador debe tener equipo 0 o 1 (PvP), 2 por equipo.
	equipos := map[int][]string{}
	for _, j := range []*Jugador{j1, j2, j3, j4} {
		if j.instanciaID == "" {
			t.Errorf("jugador %s no entró en arena", j.nombre)
		}
		if j.equipo != 0 && j.equipo != 1 {
			t.Errorf("jugador %s equipo inválido %d", j.nombre, j.equipo)
		}
		equipos[j.equipo] = append(equipos[j.equipo], j.nombre+"("+j.faccion+"/"+j.raza+")")
	}
	if len(equipos[0]) != 2 || len(equipos[1]) != 2 {
		t.Errorf("esperaba 2v2, equipos: %v", equipos)
	}
	t.Logf("equipo 0: %v", equipos[0])
	t.Logf("equipo 1: %v", equipos[1])
}

// TestRazaClaseMatriz valida que la matriz raza-clase de WoW 3.3.5 esté
// bien definida: tauren solo guerrero/cazador, gnomo sin cazador, etc.
func TestRazaClaseMatriz(t *testing.T) {
	m := nuevoMundoTest(t)
	razas := m.Razas()

	casos := []struct {
		raza        string
		faccion     string
		tieneClase  string // debe tener
		noTieneClase string // no debe tener
	}{
		{"tauren", FaccionHorda, "guerrero", "picaro"},
		{"tauren", FaccionHorda, "cazador", "mago"},
		{"gnomo", FaccionAlianza, "mago", "cazador"},
		{"humano", FaccionAlianza, "paladin", "cazador"},
		{"elfo_de_sangre", FaccionHorda, "paladin", "guerrero"},
		{"draenei", FaccionAlianza, "cazador", "picaro"},
	}
	for _, c := range casos {
		r, ok := razas[c.raza]
		if !ok {
			t.Errorf("raza %s no existe", c.raza)
			continue
		}
		if r.Faccion != c.faccion {
			t.Errorf("raza %s facción %s, esperaba %s", c.raza, r.Faccion, c.faccion)
		}
		if !contiene(r.Clases, c.tieneClase) {
			t.Errorf("raza %s debería permitir %s, clases: %v", c.raza, c.tieneClase, r.Clases)
		}
		if contiene(r.Clases, c.noTieneClase) {
			t.Errorf("raza %s NO debería permitir %s, clases: %v", c.raza, c.noTieneClase, r.Clases)
		}
	}
}

// contiene busca un string en un slice.
func contiene(s []string, v string) bool {
	for _, x := range s {
		if x == v {
			return true
		}
	}
	return false
}
