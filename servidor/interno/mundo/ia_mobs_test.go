// ia_mobs_test.go valida la IA avanzada de los mobs (Fase 8): patrulla por
// waypoints, agro social (por proximidad y por daño/body pull), leash +
// evade (reset al alejarse del spawn, cura full), escalado de élites y
// huida en HP bajo con llamada de auxilio.
package mundo

import (
	"testing"
	"time"

	"aethelgard/servidor/interno/proto"
)

// agregarMobTest registra un Enemigo en el mundo (entidades + enemigos)
// para que agroSocial y entidadPorID lo encuentren.
func agregarMobTest(m *Mundo, e *Enemigo, id string) {
	e.id = id
	e.instanciaID = "" // mundo abierto, como los jugadores de test
	m.entidades[e.id] = e
	m.enemigos[e.id] = e
}

// TestPatrullaWaypointsAvanzaIdx verifica que al llegar a un waypoint el
// mob avanza al siguiente y pausa.
func TestPatrullaWaypointsAvanzaIdx(t *testing.T) {
	e := nuevoEnemigo("guardia", "humanoid", 5, proto.Vec3{X: 1.9})
	e.waypoints = []proto.Vec3{{X: 2}, {X: 0, Z: 2}}
	ahora := int64(1000)
	// Pos a 0.1m del waypoint 0 → dentro del umbral (0.8m).
	e.patrolWaypoint(ahora)
	if e.waypointIdx != 1 {
		t.Errorf("waypointIdx=%d esperaba 1 (avanzó al 2º waypoint)", e.waypointIdx)
	}
	if e.waypointPausaHastaMs != ahora+PausaWaypointMs {
		t.Errorf("pausa=%d esperaba %d", e.waypointPausaHastaMs, ahora+PausaWaypointMs)
	}
}

// TestPatrullaWaypointsHaceCiclo verifica que al avanzar past el último
// waypoint el índice vuelve a 0 (ciclo).
func TestPatrullaWaypointsHaceCiclo(t *testing.T) {
	e := nuevoEnemigo("guardia", "humanoid", 5, proto.Vec3{X: 2})
	e.waypoints = []proto.Vec3{{X: 2}, {X: 0, Z: 2}}
	e.waypointIdx = 1 // en el último
	// Pos cerca del waypoint 1.
	e.pos = proto.Vec3{Z: 1.9}
	e.patrolWaypoint(int64(1000))
	if e.waypointIdx != 0 {
		t.Errorf("waypointIdx=%d esperaba 0 (ciclo completado)", e.waypointIdx)
	}
}

// TestAgroSocialProximidad verifica que al agroar un mob por proximidad,
// los mobs cercanos en patrulla le asisten (chain pull).
func TestAgroSocialProximidad(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "puller", "guerrero", "alianza", "humano")
	j.pos = proto.Vec3{} // sobre el mob A

	a := nuevoEnemigo("lobo A", "lobo", 5, proto.Vec3{})
	b := nuevoEnemigo("lobo B", "lobo", 5, proto.Vec3{X: 3}) // a 3m de A, dentro de social (10)
	agregarMobTest(m, a, "mob_a")
	agregarMobTest(m, b, "mob_b")

	a.aiPatrullar(m, 1000)
	if a.estado != "persiguiendo" {
		t.Errorf("mob A estado=%q esperaba persiguiendo", a.estado)
	}
	if b.estado != "persiguiendo" {
		t.Errorf("mob B debería haber asistido (estado=%q)", b.estado)
	}
	if b.objetivoID != j.ID() {
		t.Errorf("mob B objetivo=%q esperaba %s", b.objetivoID, j.ID())
	}
}

// TestAgroSocialPorDaño verifica el body pull: al dañar un mob, los mobs
// cercanos en patrulla le asisten.
func TestAgroSocialPorDaño(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "hunter", "cazador", "horda", "orco")
	j.pos = proto.Vec3{}

	a := nuevoEnemigo("jabali A", "jabali", 5, proto.Vec3{})
	b := nuevoEnemigo("jabali B", "jabali", 5, proto.Vec3{X: 4}) // dentro de social
	agregarMobTest(m, a, "mob_a")
	agregarMobTest(m, b, "mob_b")

	a.recibirDaño(j.ID(), 5, false, m, 1000)
	if a.estado != "persiguiendo" {
		t.Errorf("mob A estado=%q esperaba persiguiendo tras daño", a.estado)
	}
	if b.estado != "persiguiendo" {
		t.Errorf("mob B debería asistir tras body pull (estado=%q)", b.estado)
	}
}

// TestAgroSocialNoAfectaEnCombate verifica que el agro social SOLO afecta
// a mobs en patrulla: un mob ya en combate conserva su objetivo original.
func TestAgroSocialNoAfectaEnCombate(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "puller", "guerrero", "alianza", "humano")
	j.pos = proto.Vec3{}

	a := nuevoEnemigo("lobo A", "lobo", 5, proto.Vec3{})
	b := nuevoEnemigo("lobo B", "lobo", 5, proto.Vec3{X: 3})
	b.estado = "persiguiendo"
	b.objetivoID = "objetivo_previo"
	b.enCombate = true
	agregarMobTest(m, a, "mob_a")
	agregarMobTest(m, b, "mob_b")

	a.aiPatrullar(m, 1000)
	if b.objetivoID != "objetivo_previo" {
		t.Errorf("mob B en combate cambió objetivo a %q (no debería)", b.objetivoID)
	}
}

// TestLeashEvade verifica que un mob arrastrado más allá de LeashMetros del
// spawn entra en evade: suelta objetivo, cura a full y sale de combate.
func TestLeashEvade(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "kiter", "mago", "alianza", "humano")
	e := nuevoEnemigo("elemental", "elemental", 5, proto.Vec3{})
	e.spawnPos = proto.Vec3{}
	e.pos = proto.Vec3{X: 50} // 50m del spawn (> LeashMetros=40)
	e.estado = "persiguiendo"
	e.objetivoID = j.ID()
	e.enCombate = true
	e.hpActual = 5 // herido
	hpMax := e.hpMax
	agregarMobTest(m, e, "mob_e")

	e.actualizar(m, time.UnixMilli(1000))
	if e.estado != "evade" {
		t.Errorf("estado=%q esperaba evade tras leash", e.estado)
	}
	if e.hpActual != hpMax {
		t.Errorf("HP=%d esperaba %d (evade cura a full)", e.hpActual, hpMax)
	}
	if e.enCombate {
		t.Error("el mob debería salir de combate al evadir")
	}
	if e.objetivoID != "" {
		t.Errorf("objetivo=%q esperaba vacío tras evade", e.objetivoID)
	}
}

// TestEvadeVuelveAlSpawn verifica que en estado evade el mob se mueve hacia
// el spawn y al llegar vuelve a patrullar.
func TestEvadeVuelveAlSpawn(t *testing.T) {
	m := nuevoMundoTest(t)
	e := nuevoEnemigo("elemental", "elemental", 5, proto.Vec3{})
	e.spawnPos = proto.Vec3{}
	e.pos = proto.Vec3{X: 0.5} // cerca del spawn pero >1m? no: 0.5 <1.0 → ya llegó
	e.estado = "evade"
	agregarMobTest(m, e, "mob_e")
	e.aiEvade(m, 1000)
	if e.estado != "patrullando" {
		t.Errorf("estado=%q esperaba patrullando al llegar al spawn", e.estado)
	}
}

// TestEscaladoElite verifica que un mob élite tiene HP x3 y daño x2.
func TestEscaladoElite(t *testing.T) {
	smNormal := DefSpawnMob{Nombre: "lobo", Tipo: "lobo", Nivel: 5, DanoBase: 20}
	smElite := DefSpawnMob{Nombre: "lobo élite", Tipo: "lobo", Nivel: 5, EsElite: true, DanoBase: 20}
	eN := nuevoEnemigoMasmora(smNormal)
	eE := nuevoEnemigoMasmora(smElite)

	hpBase := 40 + 15*5 // 115
	if eN.hpMax != hpBase {
		t.Errorf("normal hpMax=%d esperaba %d", eN.hpMax, hpBase)
	}
	if eE.hpMax != hpBase*MultiplicadorEliteHP {
		t.Errorf("élite hpMax=%d esperaba %d (x%d)", eE.hpMax, hpBase*MultiplicadorEliteHP, MultiplicadorEliteHP)
	}
	if eE.danoBase != 20*MultiplicadorEliteDano {
		t.Errorf("élite dano=%d esperaba %d (x%d)", eE.danoBase, 20*MultiplicadorEliteDano, MultiplicadorEliteDano)
	}
	if !eE.esElite {
		t.Error("esElite no se marcó")
	}
	if eN.esElite {
		t.Error("el mob normal se marcó como élite")
	}
}

// TestHuidaHPBajo verifica que un mob cobarde (lobo, no élite/boss) entra
// en huida al quedar con HP < 20% en combate.
func TestHuidaHPBajo(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "tanque", "guerrero", "alianza", "humano")
	j.pos = proto.Vec3{X: 1} // cerca pero no sobre el mob

	e := nuevoEnemigoMasmora(DefSpawnMob{Nombre: "lobo", Tipo: "lobo", Nivel: 5})
	if !e.huyeAPHPBajo {
		t.Fatal("el lobo debería ser cobarde (huyeAPHPBajo=true)")
	}
	e.pos = proto.Vec3{}
	e.spawnPos = proto.Vec3{}
	e.estado = "atacando"
	e.objetivoID = j.ID()
	e.hpActual = e.hpMax / 10 // 10% HP, < 20%
	agregarMobTest(m, e, "mob_e")

	e.actualizar(m, time.UnixMilli(1000))
	if e.estado != "huyendo" {
		t.Errorf("estado=%q esperaba huyendo (HP < 20%% y cobarde)", e.estado)
	}
}

// TestNoHuyeEliteNiBoss verifica que élites y bosses no huyen.
func TestNoHuyeEliteNiBoss(t *testing.T) {
	eElite := nuevoEnemigoMasmora(DefSpawnMob{Nombre: "lobo élite", Tipo: "lobo", Nivel: 5, EsElite: true})
	if eElite.huyeAPHPBajo {
		t.Error("un élite no debería huir")
	}
	eBoss := nuevoEnemigoMasmora(DefSpawnMob{Nombre: "jefe", Tipo: "dragonkin", Nivel: 5, EsBoss: true})
	if eBoss.huyeAPHPBajo {
		t.Error("un boss no debería huir")
	}
}

// TestFamiliaEsCobarde verifica la clasificación de familias cobardes.
func TestFamiliaEsCobarde(t *testing.T) {
	cobardes := []string{"beast", "humanoid", "lobo", "jabali", "murloc", "oso"}
	for _, f := range cobardes {
		if !familiaEsCobarde(f) {
			t.Errorf("%q debería ser cobarde", f)
		}
	}
	implacables := []string{"undead", "elemental", "dragonkin", "demonio", "mecánico"}
	for _, f := range implacables {
		if familiaEsCobarde(f) {
			t.Errorf("%q NO debería ser cobarde", f)
		}
	}
}
