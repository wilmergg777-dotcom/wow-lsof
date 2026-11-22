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

// crearJugadorTest crea un Jugador con clase/faccion dados y lo agrega al mundo.
func crearJugadorTest(t *testing.T, m *Mundo, nombre, clase, faccion string) *Jugador {
	t.Helper()
	j := NuevoJugadorCreado(nombre, clase, faccion, "cuenta_test", m)
	m.AgregarJugador(j)
	return j
}

func TestBuscadorPvEMatchCrossFaction(t *testing.T) {
	m := nuevoMundoTest(t)

	// Tres jugadores de facciones Y roles distintos: guerrero/forjasol
	// (tanque), sacerdote/lunagris (soporte), mago/forjasol (dps).
	tanque := crearJugadorTest(t, m, "Tanque", "guerrero", FaccionForjasol)
	soporte := crearJugadorTest(t, m, "Curandero", "sacerdote", FaccionLunagris)
	dps := crearJugadorTest(t, m, "Dannador", "mago", FaccionForjasol)

	// Los tres a la cola de la misma masmora (cross-faction).
	if err := m.Buscador().EntrarColaPvE(tanque, "cripta_pinargos"); err != nil {
		t.Fatalf("entrar tanque: %v", err)
	}
	if err := m.Buscador().EntrarColaPvE(soporte, "cripta_pinargos"); err != nil {
		t.Fatalf("entrar soporte: %v", err)
	}
	if err := m.Buscador().EntrarColaPvE(dps, "cripta_pinargos"); err != nil {
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
		t.Logf("%s (%s, %s) en instancia %s", j.nombre, j.faccion, j.rol, j.instanciaID)
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
	if boss.hpMax < 100 {
		t.Errorf("boss debería tener HP boosteado, tiene %d", boss.hpMax)
	}
	t.Logf("boss %s (HP %d) + %d mobs en la instancia", boss.nombre, boss.hpMax, mobCount)
}

func TestBuscadorPvPMatchCrossFaction(t *testing.T) {
	m := nuevoMundoTest(t)

	// 4 jugadores para arena 2v2 (cross-faction).
	j1 := crearJugadorTest(t, m, "J1", "guerrero", FaccionForjasol)
	j2 := crearJugadorTest(t, m, "J2", "mago", FaccionLunagris)
	j3 := crearJugadorTest(t, m, "J3", "sacerdote", FaccionForjasol)
	j4 := crearJugadorTest(t, m, "J4", "guerrero", FaccionLunagris)

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
		equipos[j.equipo] = append(equipos[j.equipo], j.nombre+"("+j.faccion+")")
	}
	if len(equipos[0]) != 2 || len(equipos[1]) != 2 {
		t.Errorf("esperaba 2v2, equipos: %v", equipos)
	}
	t.Logf("equipo 0: %v", equipos[0])
	t.Logf("equipo 1: %v", equipos[1])
}
