// misiones_test.go valida el sistema de XP, subida de nivel y misiones:
// la curva de XP 1→80, el crédito de muerte (XP + progreso al matar), el
// catálogo de 48 misiones con NPCs misioneros, la aceptación/entrega con
// prerrequisitos, y la persistencia de XP/misiones.
package mundo

import (
	"testing"

	"aethelgard/servidor/interno/proto"
)

// matarMobTest simula que un jugador mata un mob de un golpe (dentro de
// m.mu.Lock, como el tick real).
func matarMobTest(t *testing.T, m *Mundo, mobID, jugadorID string) {
	t.Helper()
	m.mu.Lock()
	defer m.mu.Unlock()
	e, ok := m.enemigos[mobID]
	if !ok {
		t.Fatalf("mob %s no existe", mobID)
	}
	e.recibirDaño(jugadorID, e.hpActual, false, m, 0)
}

// mobDeFamiliaZona encuentra el ID del primer mob del open world con la
// familia dada (en cualquier zona).
func mobDeFamiliaZona(t *testing.T, m *Mundo, familia string) string {
	t.Helper()
	for id, e := range m.enemigos {
		if e.instanciaID == "" && e.clase == familia {
			return id
		}
	}
	t.Fatalf("no hay mob de familia %q en el open world", familia)
	return ""
}

// TestCurvaXP valida la curva de XP y la regla de mob gris.
func TestCurvaXP(t *testing.T) {
	// Monótona creciente hasta 80.
	prev := 0
	for n := 1; n <= NivelMax; n++ {
		xp := xpParaNivel(n)
		if xp <= prev {
			t.Errorf("nivel %d: xp=%d no crece (prev=%d)", n, xp, prev)
		}
		prev = xp
	}
	if xpParaNivel(1) != 50 {
		t.Errorf("xpParaNivel(1)=%d, esperaba 50", xpParaNivel(1))
	}
	if xpParaNivel(80) != 50*80*80 {
		t.Errorf("xpParaNivel(80)=%d, esperaba %d", xpParaNivel(80), 50*80*80)
	}
	// Mob gris: 7+ niveles por debajo → 0 XP.
	if xp := xpPorMob(1, 8); xp != 0 {
		t.Errorf("mob gris lvl1 por jugador lvl8 da %d, esperaba 0", xp)
	}
	// Mob mismo nivel → >0.
	if xp := xpPorMob(5, 5); xp <= 0 {
		t.Errorf("mob lvl5 por jugador lvl5 da %d, esperaba >0", xp)
	}
	// Mob por encima → bonificación.
	if xp := xpPorMob(10, 5); xp <= xpPorMob(5, 5) {
		t.Errorf("mob superior debería dar más XP")
	}
}

// TestGanarXPSubirNivel valida que ganarXP sube de nivel y recalcula
// HP/energía máximos curando al completo.
func TestGanarXPSubirNivel(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Subidor", "guerrero", FaccionAlianza, "humano")
	nivelIni := j.nivel
	hpMaxIni := j.hpMax
	// Dañar al jugador para verificar que subir cura.
	m.mu.Lock()
	j.hpActual = 5
	m.mu.Unlock()
	// Dar XP suficiente para subir al menos 1 nivel.
	m.mu.Lock()
	j.ganarXP(xpParaNivel(nivelIni)+1, m)
	m.mu.Unlock()
	if j.nivel != nivelIni+1 {
		t.Errorf("nivel=%d, esperaba %d", j.nivel, nivelIni+1)
	}
	if j.hpMax <= hpMaxIni {
		t.Errorf("hpMax=%d no creció (era %d)", j.hpMax, hpMaxIni)
	}
	// Subir cura al completo.
	if j.hpActual != j.hpMax {
		t.Errorf("tras subir, hpActual=%d != hpMax=%d", j.hpActual, j.hpMax)
	}
}

// TestKillOtorgaXP valida que matar un mob otorga XP al último atacante.
func TestKillOtorgaXP(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Cazador", "cazador", FaccionAlianza, "humano")
	xpIni := j.XP()
	mobID := mobDeFamiliaZona(t, m, "lobo")
	mobNivel := m.enemigos[mobID].nivel
	esperado := xpPorMob(mobNivel, j.nivel)
	matarMobTest(t, m, mobID, j.id)
	if j.XP() != xpIni+esperado {
		t.Errorf("XP tras matar=%d, esperaba %d+%d=%d", j.XP(), xpIni, esperado, xpIni+esperado)
	}
}

// TestKillMobGrisSinXP valida que un mob gris (≥7 niveles por debajo) no da XP.
func TestKillMobGrisSinXP(t *testing.T) {
	m := nuevoMundoTest(t)
	// Crear un jugador de nivel alto.
	j := crearJugadorTest(t, m, "Alto", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	for j.nivel < 20 {
		j.subirNivel(m)
	}
	m.mu.Unlock()
	xpIni := j.XP()
	// Matar un mob lvl 1-2 (gris para un lvl 20).
	mobID := mobDeFamiliaZona(t, m, "lobo")
	matarMobTest(t, m, mobID, j.id)
	if j.XP() != xpIni {
		t.Errorf("mob gris dio XP: %d → %d, esperaba sin cambio", xpIni, j.XP())
	}
}

// TestCatalogoMisiones valida la estructura del catálogo de misiones.
func TestCatalogoMisiones(t *testing.T) {
	m := nuevoMundoTest(t)
	ms := m.Misiones()
	if len(ms) < 40 {
		t.Errorf("misiones = %d, esperaba ≥40", len(ms))
	}
	for _, mi := range ms {
		if mi.NivelMin < 1 || mi.NivelMin > NivelMax {
			t.Errorf("misión %s: NivelMin inválido %d", mi.ID, mi.NivelMin)
		}
		if mi.ZonaID != "" {
			if _, ok := m.Zona(mi.ZonaID); !ok {
				t.Errorf("misión %s: zona %s inexistente", mi.ID, mi.ZonaID)
			}
		}
		// NPCs inicial y entrega deben existir.
		if _, ok := m.NPC(mi.NPCInicial); !ok {
			t.Errorf("misión %s: NPCInicial %s inexistente", mi.ID, mi.NPCInicial)
		}
		if _, ok := m.NPC(mi.NPCEntrega); !ok {
			t.Errorf("misión %s: NPCEntrega %s inexistente", mi.ID, mi.NPCEntrega)
		}
		if len(mi.Objetivos) == 0 {
			t.Errorf("misión %s: sin objetivos", mi.ID)
		}
		for i, obj := range mi.Objetivos {
			switch obj.Tipo {
			case "matar":
				if obj.MobFamilia == "" || obj.Cantidad <= 0 {
					t.Errorf("misión %s obj %d: matar mal formado", mi.ID, i)
				}
			case "hablar":
				if obj.NPCDestino == "" {
					t.Errorf("misión %s obj %d: hablar sin NPCDestino", mi.ID, i)
				}
				if _, ok := m.NPC(obj.NPCDestino); !ok {
					t.Errorf("misión %s obj %d: NPCDestino %s inexistente", mi.ID, i, obj.NPCDestino)
				}
			default:
				t.Errorf("misión %s obj %d: tipo inválido %q", mi.ID, i, obj.Tipo)
			}
		}
		if mi.XPRecompensa <= 0 {
			t.Errorf("misión %s: XP recompensa ≤0", mi.ID)
		}
		// Cadena: RequiereMision debe existir en el catálogo.
		if mi.RequiereMision != "" {
			if _, ok := m.Mision(mi.RequiereMision); !ok {
				t.Errorf("misión %s: RequiereMision %s inexistente", mi.ID, mi.RequiereMision)
			}
		}
		// Items de recompensa deben existir.
		for _, itemID := range mi.ItemsRecompensa {
			if _, ok := m.items[itemID]; !ok {
				t.Errorf("misión %s: item recompensa %s inexistente", mi.ID, itemID)
			}
		}
	}
}

// TestNPCsMisioneros valida que cada capital tiene un NPC misionero y que
// las misiones que ofrece existen y tienen al NPC como inicial.
func TestNPCsMisioneros(t *testing.T) {
	m := nuevoMundoTest(t)
	// Cada capital racial tiene un misionero.
	for _, razaID := range todasLasRazas {
		ciudad, _ := m.CiudadPorRaza(razaID)
		tiene := false
		for _, n := range ciudad.NPCs {
			if n.Tipo == "misionero" {
				tiene = true
				for _, mid := range n.Misiones {
					mi, ok := m.Mision(mid)
					if !ok {
						t.Errorf("capital %s: ofrece misión inexistente %s", ciudad.ID, mid)
					}
					if mi.NPCInicial != n.ID {
						t.Errorf("misión %s NPCInicial=%s, esperaba %s", mid, mi.NPCInicial, n.ID)
					}
				}
			}
		}
		if !tiene {
			t.Errorf("capital %s (raza %s) sin NPC misionero", ciudad.ID, razaID)
		}
	}
	// Zonas representativas de banda tienen misionero.
	zonasConMisionero := []string{
		"trabalita_vegas", "crepusculo", "vega_tyris", "tanaris",
		"tierras_plaga_oeste", "peninsula_fuego_infernal", "tundra_boreal",
	}
	for _, zid := range zonasConMisionero {
		z, _ := m.Zona(zid)
		tiene := false
		for _, n := range z.NPCs {
			if n.Tipo == "misionero" {
				tiene = true
			}
		}
		if !tiene {
			t.Errorf("zona %s sin NPC misionero", zid)
		}
	}
}

// TestAceptarMision valida los prerrequisitos de aceptación.
func TestAceptarMision(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Aventurero", "guerrero", FaccionAlianza, "humano")
	// El humano (lvl 1) está en Ventormenta, junto a mis_ventormenta.
	// m_ventormenta_2 (lvl 2) debería poder aceptarse... pero lvl 1 < 2.
	if err := m.AceptarMision(j.id, "m_ventormenta_2"); err == nil {
		t.Error("aceptar misión lvl 2 siendo lvl 1 debería fallar")
	}
	// Subir a lvl 2 y aceptar.
	m.mu.Lock()
	j.subirNivel(m)
	m.mu.Unlock()
	if err := m.AceptarMision(j.id, "m_ventormenta_2"); err != nil {
		t.Fatalf("aceptar m_ventormenta_2 falló: %v", err)
	}
	// Doble aceptación falla.
	if err := m.AceptarMision(j.id, "m_ventormenta_2"); err == nil {
		t.Error("aceptar misión ya activa debería fallar")
	}
	// Cadena: m_trab_4 requiere m_trab_1. Viajar a trabalita_vegas y probar.
	_ = m.ViajarZona(j.id, "trabalita_vegas")
	// m_trab_4 requiere nivel 17. Subir a 17.
	m.mu.Lock()
	for j.nivel < 17 {
		j.subirNivel(m)
	}
	m.mu.Unlock()
	// Sin la previa completada → falla (cadena).
	if err := m.AceptarMision(j.id, "m_trab_4"); err == nil {
		t.Error("aceptar misión de cadena sin previa completada debería fallar")
	}
	// Marcar m_trab_1 como completada (el flujo de completar se testa en
	// TestMisionMatarCompleta; aquí aislamos la lógica de prerrequisito).
	m.mu.Lock()
	j.misionesCompletadas["m_trab_1"] = true
	m.mu.Unlock()
	// Ahora m_trab_4 debería poder aceptarse (prereq + nivel cumplidos).
	if err := m.AceptarMision(j.id, "m_trab_4"); err != nil {
		t.Errorf("aceptar m_trab_4 con prereq cumplido falló: %v", err)
	}
}

// TestMisionMatarCompleta valida el ciclo completo de una misión de matar:
// aceptar → matar → progresar → completar → entregar → recompensas.
func TestMisionMatarCompleta(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Matador", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	j.subirNivel(m) // lvl 2 para aceptar m_ventormenta_2
	m.mu.Unlock()
	if err := m.AceptarMision(j.id, "m_ventormenta_2"); err != nil {
		t.Fatalf("aceptar: %v", err)
	}
	// m_ventormenta_2: matar 5 lobos. Matar 5 lobos del open world.
	for i := 0; i < 5; i++ {
		mobID := mobDeFamiliaZona(t, m, "lobo")
		matarMobTest(t, m, mobID, j.id)
	}
	// La misión debe estar completada.
	activas := m.MisionesActivasJugador(j.id)
	var est *EstadoMision
	for k := range activas {
		if activas[k].MisionID == "m_ventormenta_2" {
			est = &activas[k]
		}
	}
	if est == nil {
		t.Fatal("misión no está activa tras matar")
	}
	if !est.Completada {
		t.Errorf("misión no completada tras matar 5 lobos: %+v", est.Progreso)
	}
	// Entregar (jugador sigue junto a mis_ventormenta en Ventormenta).
	xpIni := j.XP()
	oroIni := j.Oro()
	mi, _ := m.Mision("m_ventormenta_2")
	if _, err := m.EntregarMision(j.id, "m_ventormenta_2"); err != nil {
		t.Fatalf("entregar: %v", err)
	}
	if j.XP() != xpIni+mi.XPRecompensa {
		t.Errorf("XP tras entregar=%d, esperaba %d", j.XP(), xpIni+mi.XPRecompensa)
	}
	if j.Oro() != oroIni+mi.OroRecompensa {
		t.Errorf("oro tras entregar=%d, esperaba %d", j.Oro(), oroIni+mi.OroRecompensa)
	}
	// Ya no está activa, está completada.
	if len(m.MisionesActivasJugador(j.id)) != 0 {
		t.Error("misión sigue activa tras entregar")
	}
	completadas := m.MisionesCompletadasJugador(j.id)
	encontrada := false
	for _, id := range completadas {
		if id == "m_ventormenta_2" {
			encontrada = true
		}
	}
	if !encontrada {
		t.Error("misión no marcada como completada tras entregar")
	}
}

// TestMisionHablarCompleta valida una misión de hablar: aceptar →
// interactuar con el NPC destino → completar → entregar.
func TestMisionHablarCompleta(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Diplomatico", "mago", FaccionAlianza, "humano")
	// m_ventormenta_1 (lvl 1): hablar con ven_ventormenta.
	if err := m.AceptarMision(j.id, "m_ventormenta_1"); err != nil {
		t.Fatalf("aceptar: %v", err)
	}
	// Interactuar con ven_ventormenta progresa el objetivo hablar.
	if _, err := m.InteractuarNPC(j.id, "ven_ventormenta"); err != nil {
		t.Fatalf("interactuar: %v", err)
	}
	activas := m.MisionesActivasJugador(j.id)
	completada := false
	for _, est := range activas {
		if est.MisionID == "m_ventormenta_1" && est.Completada {
			completada = true
		}
	}
	if !completada {
		t.Error("misión de hablar no completada tras interactuar con el NPC")
	}
	// Entregar.
	xpIni := j.XP()
	mi, _ := m.Mision("m_ventormenta_1")
	if _, err := m.EntregarMision(j.id, "m_ventormenta_1"); err != nil {
		t.Fatalf("entregar: %v", err)
	}
	if j.XP() != xpIni+mi.XPRecompensa {
		t.Errorf("XP tras entregar misión hablar=%d, esperaba %d", j.XP(), xpIni+mi.XPRecompensa)
	}
	// La misión inicial daba un item (ciruela_blanca_sabrosa).
	if j.inventario["ciruela_blanca_sabrosa"] < 1 {
		t.Error("item de recompensa no añadido al inventario")
	}
}

// TestProgresoMisionSoloFamilia valida que matar un mob de familia distinta
// no progresa la misión.
func TestProgresoMisionSoloFamilia(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Preciso", "cazador", FaccionAlianza, "humano")
	m.mu.Lock()
	j.subirNivel(m)
	m.mu.Unlock()
	_ = m.AceptarMision(j.id, "m_ventormenta_2") // matar 5 lobos
	// Matar un jabalí (familia distinta) no debe progresar la misión de lobos.
	mobID := mobDeFamiliaZona(t, m, "jabali")
	matarMobTest(t, m, mobID, j.id)
	for _, est := range m.MisionesActivasJugador(j.id) {
		if est.MisionID == "m_ventormenta_2" {
			for k, v := range est.Progreso {
				if v != 0 {
					t.Errorf("matar jabalí progresó objetivo de lobos (%s=%d)", k, v)
				}
			}
		}
	}
}

// TestMisionesDisponiblesNPC valida el filtrado por nivel/cadena/completado.
func TestMisionesDisponiblesNPC(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Novato", "guerrero", FaccionAlianza, "humano")
	// Lvl 1 en Ventormenta: m_ventormenta_1 (lvl1) disponible, m_ventormenta_2 (lvl2) no.
	disp := m.MisionesDisponiblesNPC(j.id, "mis_ventormenta")
	if len(disp) != 1 || disp[0].ID != "m_ventormenta_1" {
		t.Errorf("lvl 1: disponibles=%v, esperaba solo m_ventormenta_1", idsDeMisiones(disp))
	}
	// Subir a lvl 2: m_ventormenta_2 también disponible.
	m.mu.Lock()
	j.subirNivel(m)
	m.mu.Unlock()
	disp = m.MisionesDisponiblesNPC(j.id, "mis_ventormenta")
	if len(disp) != 2 {
		t.Errorf("lvl 2: disponibles=%v, esperaba 2", idsDeMisiones(disp))
	}
	// Aceptar m_ventormenta_1 → ya no disponible.
	_ = m.AceptarMision(j.id, "m_ventormenta_1")
	disp = m.MisionesDisponiblesNPC(j.id, "mis_ventormenta")
	for _, mi := range disp {
		if mi.ID == "m_ventormenta_1" {
			t.Error("misión activa sigue apareciendo como disponible")
		}
	}
}

func idsDeMisiones(ms []DefMision) []string {
	out := make([]string, len(ms))
	for i, mi := range ms {
		out[i] = mi.ID
	}
	return out
}

// TestPersistenciaMisionesXP valida el round-trip de XP, nivel, oro y estado
// de misiones (activas con progreso + completadas) a través de guardar/cargar.
func TestPersistenciaMisionesXP(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Persistente", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	j.subirNivel(m) // lvl 2
	m.mu.Unlock()
	_ = m.AceptarMision(j.id, "m_ventormenta_2") // matar 5 lobos
	// Matar 2 lobos (progreso parcial).
	for i := 0; i < 2; i++ {
		mobID := mobDeFamiliaZona(t, m, "lobo")
		matarMobTest(t, m, mobID, j.id)
	}
	// Completar otra misión para tener una completada persistida.
	_ = m.AceptarMision(j.id, "m_ventormenta_1")
	_, _ = m.InteractuarNPC(j.id, "ven_ventormenta")
	_, _ = m.EntregarMision(j.id, "m_ventormenta_1")

	xpEsperado := j.XP()
	nivelEsperado := j.nivel
	oroEsperado := j.Oro()
	// Guardar y recargar.
	if err := j.guardar(m.persist); err != nil {
		t.Fatalf("guardar: %v", err)
	}
	p, err := m.persist.Cargar(j.nombre)
	if err != nil {
		t.Fatalf("cargar: %v", err)
	}
	j2 := NuevoJugadorDesdePersistencia(p, m, j.cuenta)
	if j2.XP() != xpEsperado {
		t.Errorf("XP round-trip: %d → %d", xpEsperado, j2.XP())
	}
	if j2.Nivel() != nivelEsperado {
		t.Errorf("nivel round-trip: %d → %d", nivelEsperado, j2.Nivel())
	}
	if j2.Oro() != oroEsperado {
		t.Errorf("oro round-trip: %d → %d", oroEsperado, j2.Oro())
	}
	// Misión activa con progreso 2 persistida.
	activas2 := m.MisionesActivasJugador(j2.id)
	encontrada := false
	for _, est := range activas2 {
		if est.MisionID == "m_ventormenta_2" {
			encontrada = true
			// Progreso obj_0 = 2.
			if est.Progreso["obj_0"] != 2 {
				t.Errorf("progreso round-trip: obj_0=%d, esperaba 2", est.Progreso["obj_0"])
			}
		}
	}
	if !encontrada {
		t.Error("misión activa no persistió")
	}
	// Misión completada persistida.
	completadas2 := m.MisionesCompletadasJugador(j2.id)
	complOk := false
	for _, id := range completadas2 {
		if id == "m_ventormenta_1" {
			complOk = true
		}
	}
	if !complOk {
		t.Error("misión completada no persistió")
	}
}

// TestCapNivelMax valida que no se sube de nivel por encima de NivelMax.
func TestCapNivelMax(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Tope", "guerrero", FaccionAlianza, "humano")
	m.mu.Lock()
	// Forzar al nivel máximo.
	for j.nivel < NivelMax {
		j.subirNivel(m)
	}
	m.mu.Unlock()
	xpIni := j.XP()
	// Dar XP enorme: no debe subir ni acumular (cap).
	m.mu.Lock()
	j.ganarXP(99999999, m)
	m.mu.Unlock()
	if j.nivel != NivelMax {
		t.Errorf("nivel=%d, esperaba tope %d", j.nivel, NivelMax)
	}
	if j.XP() != 0 {
		t.Errorf("XP en tope debería ser 0, es %d", j.XP())
	}
	_ = xpIni
}

// TestNivelesStatsCrecen valida que hpMax crece con cada nivel para todas
// las clases (recálculo de stats al subir).
func TestNivelesStatsCrecen(t *testing.T) {
	m := nuevoMundoTest(t)
	for _, claseID := range []string{"guerrero", "mago", "sacerdote", "cazador"} {
		j := crearJugadorTest(t, m, "Stat"+claseID, claseID, FaccionAlianza, "humano")
		hpNivel1 := j.hpMax
		m.mu.Lock()
		for j.nivel < 10 {
			j.subirNivel(m)
		}
		m.mu.Unlock()
		if j.hpMax <= hpNivel1 {
			t.Errorf("clase %s: hpMax lvl10=%d no creció desde lvl1=%d", claseID, j.hpMax, hpNivel1)
		}
	}
}

// auxiliar para evitar import no usado de proto si se añaden campos.
var _ = proto.Vec3{}
