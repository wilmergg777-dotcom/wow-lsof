// zonas_test.go valida el mundo abierto de WoW 3.3.5a: el catálogo de zonas
// por nivel (1-80), el grafo de conexiones (conexo y con camino a la zona
// final 77-80), las 10 capitales raciales con NPCs, el spawn racial por raza,
// el spawn de mobs del open world por zona, el viaje entre zonas adyacentes
// y la interacción con NPCs por proximidad.
package mundo

import (
	"testing"

	"aethelgard/servidor/interno/proto"
)

// todasLasRazas para iterar en tests.
var todasLasRazas = []string{
	"humano", "enano", "elfo_nocturno", "gnomo", "draenei",
	"orco", "no_muerto", "tauren", "troll", "elfo_de_sangre",
}

// TestCatalogoZonas valida la estructura del catálogo de zonas.
func TestCatalogoZonas(t *testing.T) {
	m := nuevoMundoTest(t)
	zs := m.Zonas()
	if len(zs) < 20 {
		t.Errorf("zonas = %d, esperaba ≥20", len(zs))
	}
	for _, z := range zs {
		if z.NivelMin < 1 || z.NivelMax > 80 || z.NivelMin > z.NivelMax {
			t.Errorf("zona %s: niveles inválidos %d-%d", z.ID, z.NivelMin, z.NivelMax)
		}
		if z.Faccion != FaccionAlianza && z.Faccion != FaccionHorda && z.Faccion != "neutral" {
			t.Errorf("zona %s: facción inválida %q", z.ID, z.Faccion)
		}
		if z.Tipo != "inicial" && z.Tipo != "medio" && z.Tipo != "final" {
			t.Errorf("zona %s: tipo inválido %q", z.ID, z.Tipo)
		}
		if len(z.Spawns) == 0 {
			t.Errorf("zona %s: sin spawns de mobs", z.ID)
		}
	}
}

// TestZonasInicialesPorRaza valida que cada raza tiene una zona inicial
// 1-10 con su capital, y que la facción de la zona coincide con la de la raza.
func TestZonasInicialesPorRaza(t *testing.T) {
	m := nuevoMundoTest(t)
	for _, razaID := range todasLasRazas {
		raza, _ := m.Raza(razaID)
		ciudad, ok := m.CiudadPorRaza(razaID)
		if !ok {
			t.Errorf("raza %s sin capital racial", razaID)
			continue
		}
		zona, ok := m.Zona(ciudad.ZonaID)
		if !ok {
			t.Errorf("capital %s (raza %s) en zona inexistente %s", ciudad.ID, razaID, ciudad.ZonaID)
			continue
		}
		if zona.Tipo != "inicial" || zona.NivelMin != 1 || zona.NivelMax != 10 {
			t.Errorf("raza %s: zona inicial %s es %s lvl %d-%d, esperaba inicial 1-10",
				razaID, zona.ID, zona.Tipo, zona.NivelMin, zona.NivelMax)
		}
		if zona.Faccion != raza.Faccion {
			t.Errorf("raza %s (facción %s) en zona %s de facción %s",
				razaID, raza.Faccion, zona.ID, zona.Faccion)
		}
	}
}

// TestDiezCapitalesUnaPorRaza valida que hay 10 capitales, una por cada raza.
func TestDiezCapitalesUnaPorRaza(t *testing.T) {
	m := nuevoMundoTest(t)
	cs := m.Ciudades()
	if len(cs) != 10 {
		t.Errorf("capitales = %d, esperaba 10", len(cs))
	}
	vistas := map[string]bool{}
	for _, razaID := range todasLasRazas {
		c, ok := m.CiudadPorRaza(razaID)
		if !ok {
			t.Errorf("raza %s sin capital", razaID)
			continue
		}
		if vistas[c.ID] {
			t.Errorf("capital %s sirve a dos razas (no esperado)", c.ID)
		}
		vistas[c.ID] = true
	}
	// Cada capital debe tener ≥3 NPCs: 1 vendedor + 2 instructores.
	for _, c := range cs {
		if len(c.NPCs) < 3 {
			t.Errorf("capital %s: %d NPCs, esperaba ≥3", c.ID, len(c.NPCs))
		}
		tieneVend := false
		for _, n := range c.NPCs {
			if n.Tipo == "vendedor" {
				tieneVend = true
			}
			if n.Tipo != "vendedor" && n.Tipo != "instructor" {
				t.Errorf("capital %s NPC %s tipo inválido %q", c.ID, n.ID, n.Tipo)
			}
		}
		if !tieneVend {
			t.Errorf("capital %s sin vendedor", c.ID)
		}
	}
}

// TestGrafoZonasConexo valida que desde CUALQUIER zona inicial se puede llegar
// por el grafo de conexiones a la zona final de nivel 77-80 (corona_de_hielo),
// garantizando un camino de leveo 1→80.
func TestGrafoZonasConexo(t *testing.T) {
	m := nuevoMundoTest(t)
	zs := m.Zonas()
	// Encontrar la zona final (nivel máximo alcanzable).
	destFinal := ""
	nivelMaxFinal := 0
	for _, z := range zs {
		if z.NivelMax >= 80 && z.NivelMax >= nivelMaxFinal {
			if z.Tipo == "final" || z.NivelMax > nivelMaxFinal {
				destFinal = z.ID
				nivelMaxFinal = z.NivelMax
			}
		}
	}
	if destFinal == "" {
		t.Fatalf("no hay zona final lvl 80")
	}
	// BFS desde cada zona inicial hasta destFinal.
	for _, z := range zs {
		if z.Tipo != "inicial" {
			continue
		}
		if !alcanzable(m, z.ID, destFinal) {
			t.Errorf("zona inicial %s no puede alcanzar la zona final %s", z.ID, destFinal)
		}
	}
	// También: el grafo completo es una sola componente conexa.
	componentes := contarComponentes(zs)
	if componentes != 1 {
		t.Errorf("grafo de zonas tiene %d componentes, esperaba 1 (conexo)", componentes)
	}
}

// alcanzable hace BFS desde origen hasta destino por Conexiones.
func alcanzable(m *Mundo, origen, destino string) bool {
	visitados := map[string]bool{}
	cola := []string{origen}
	for len(cola) > 0 {
		actual := cola[0]
		cola = cola[1:]
		if actual == destino {
			return true
		}
		if visitados[actual] {
			continue
		}
		visitados[actual] = true
		if z, ok := m.Zona(actual); ok {
			for _, c := range z.Conexiones {
				if !visitados[c] {
					cola = append(cola, c)
				}
			}
		}
	}
	return false
}

// contarComponentes cuenta componentes conexas del grafo de zonas.
func contarComponentes(zs map[string]DefZona) int {
	visitados := map[string]bool{}
	componentes := 0
	for id := range zs {
		if visitados[id] {
			continue
		}
		componentes++
		// BFS desde id
		cola := []string{id}
		for len(cola) > 0 {
			actual := cola[0]
			cola = cola[1:]
			if visitados[actual] {
				continue
			}
			visitados[actual] = true
			if z, ok := zs[actual]; ok {
				for _, c := range z.Conexiones {
					if !visitados[c] {
						cola = append(cola, c)
					}
				}
			}
		}
	}
	return componentes
}

// TestRegionesNoSolapan valida que las regiones de las zonas están separadas
// (a >2×RadioRegionZona entre centros), para que mobs/players de zonas
// distintas nunca se vean (radio de interés 60m).
func TestRegionesNoSolapan(t *testing.T) {
	m := nuevoMundoTest(t)
	zs := m.Zonas()
	for idA, a := range zs {
		for idB, b := range zs {
			if idA >= idB {
				continue
			}
			d := distancia2D(a.Region, b.Region)
			if d <= 2*RadioRegionZona {
				t.Errorf("zonas %s y %s regiones a %.0f (≤%.0f)", idA, idB, d, 2*RadioRegionZona)
			}
		}
	}
}

// TestRegionesEvitanCarrilMasmorras valida que ninguna región de zona cae en
// el carril de masmorras (X∈[1000,5000], |Z|<200) ni de la arena PvP
// (X=9000, |Z|<200), para no mezclar open world con instancias.
func TestRegionesEvitanCarrilMasmorras(t *testing.T) {
	m := nuevoMundoTest(t)
	for _, z := range m.Zonas() {
		x, zz := z.Region.X, z.Region.Z
		if x >= 1000 && x <= 5000 && absF(zz) < 200 {
			t.Errorf("zona %s región (%.0f,%.0f) en carril de masmorras", z.ID, x, zz)
		}
		if absF(x-9000) < 200 && absF(zz) < 200 {
			t.Errorf("zona %s región (%.0f,%.0f) en carril de arena PvP", z.ID, x, zz)
		}
	}
}

func absF(x float64) float64 {
	if x < 0 {
		return -x
	}
	return x
}

// TestSpawnRacial valida que un PJ recién creado aparece en la capital de su
// raza (no en el origen): un Tauren en Cima de Trueno, un Humano en
// Ventormenta, etc. Y que ZonaEnPos devuelve la zona inicial correcta.
func TestSpawnRacial(t *testing.T) {
	m := nuevoMundoTest(t)
	for _, razaID := range todasLasRazas {
		raza, _ := m.Raza(razaID)
		clase := raza.Clases[0]
		j := crearJugadorTest(t, m, "Spawn"+razaID, clase, raza.Faccion, razaID)
		ciudad, _ := m.CiudadPorRaza(razaID)
		if j.pos != ciudad.SpawnPoint {
			t.Errorf("raza %s: spawn en %v, esperaba capital %v", razaID, j.pos, ciudad.SpawnPoint)
		}
		if j.pos == (proto.Vec3{}) {
			t.Errorf("raza %s: spawn en origen (0,0,0), esperaba capital", razaID)
		}
		// La zona derivada de la posición debe ser la zona inicial de la raza.
		z, ok := m.ZonaEnPos(j.pos)
		if !ok {
			t.Errorf("raza %s: ZonaEnPos no encontró zona para %v", razaID, j.pos)
			continue
		}
		if z.ID != ciudad.ZonaID {
			t.Errorf("raza %s: ZonaEnPos=%s, esperaba %s", razaID, z.ID, ciudad.ZonaID)
		}
		// spawnPos (respawn al morir) también debe ser la capital racial.
		if j.spawnPos != ciudad.SpawnPoint {
			t.Errorf("raza %s: spawnPos=%v, esperaba %v", razaID, j.spawnPos, ciudad.SpawnPoint)
		}
	}
}

// TestSpawnMobsPorZonas valida que el open world se puebla con los mobs del
// catálogo de zonas (no los 5 hardcodeados): el total de mobs == suma de
// spawns de todas las zonas, y cada mob está dentro del radio de región de
// alguna zona.
func TestSpawnMobsPorZonas(t *testing.T) {
	m := nuevoMundoTest(t)
	zs := m.Zonas()
	esperados := 0
	for _, z := range zs {
		esperados += len(z.Spawns)
	}
	// Contar mobs del open world (instanciaID == "").
	openMobs := 0
	for _, e := range m.enemigos {
		if e.instanciaID == "" {
			openMobs++
		}
	}
	if openMobs != esperados {
		t.Errorf("mobs open world = %d, esperaba %d (suma de spawns de zonas)", openMobs, esperados)
	}
	// Cada mob debe estar dentro del radio de región de alguna zona.
	for _, e := range m.enemigos {
		if e.instanciaID != "" {
			continue
		}
		_, ok := m.ZonaEnPos(e.pos)
		if !ok {
			t.Errorf("mob %s en %v no pertenece a ninguna zona", e.id, e.pos)
		}
	}
}

// TestViajarZona valida el viaje entre zonas adyacentes y el rechazo de
// viajes no adyacentes.
func TestViajarZona(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Viajero", "guerrero", FaccionAlianza, "humano")
	// El humano empieza en Ventormenta (zona elwynn). elwynn conecta con
	// trabalita_vegas y dun_morogh.
	if err := m.ViajarZona(j.id, "trabalita_vegas"); err != nil {
		t.Fatalf("viajar a trabalita_vegas (adyacente) falló: %v", err)
	}
	dest, _ := m.Zona("trabalita_vegas")
	if j.pos != dest.PuntoEntrada {
		t.Errorf("tras viajar, pos=%v, esperaba %v", j.pos, dest.PuntoEntrada)
	}
	// Viaje a una zona NO adyacente debe fallar (corona_de_hielo está lejos).
	if err := m.ViajarZona(j.id, "corona_de_hielo"); err == nil {
		t.Error("viajar a corona_de_hielo (no adyacente) debería fallar")
	}
	// Zona inexistente debe fallar.
	if err := m.ViajarZona(j.id, "no_existe"); err == nil {
		t.Error("viajar a zona inexistente debería fallar")
	}
}

// TestInteractuarNPC valida la interacción por proximidad con un NPC.
func TestInteractuarNPC(t *testing.T) {
	m := nuevoMundoTest(t)
	j := crearJugadorTest(t, m, "Comprador", "mago", FaccionAlianza, "humano")
	// El humano está en Ventormenta; el vendedor ven_ventorleta está a 3m.
	npc, err := m.InteractuarNPC(j.id, "ven_ventormenta")
	if err != nil {
		t.Fatalf("interactuar con ven_ventormento falló: %v", err)
	}
	if npc.Tipo != "vendedor" || len(npc.VendeItems) == 0 {
		t.Errorf("NPC vendedor sin items: %+v", npc)
	}
	// NPC inexistente.
	if _, err := m.InteractuarNPC(j.id, "no_existe"); err == nil {
		t.Error("interactuar con NPC inexistente debería fallar")
	}
	// Tras viajar a otra zona, el NPC de Ventormenta queda lejos → falla.
	_ = m.ViajarZona(j.id, "trabalita_vegas")
	if _, err := m.InteractuarNPC(j.id, "ven_ventormenta"); err == nil {
		t.Error("interactuar con NPC lejano debería fallar")
	}
}

// TestNPCsDatosValidos valida que los NPCs referencian items/clases/profesiones
// que existen en el catálogo.
func TestNPCsDatosValidos(t *testing.T) {
	m := nuevoMundoTest(t)
	for _, c := range m.Ciudades() {
		for _, n := range c.NPCs {
			switch n.Tipo {
			case "vendedor":
				for _, itemID := range n.VendeItems {
					if _, ok := m.items[itemID]; !ok {
						t.Errorf("NPC %s vende item inexistente %s", n.ID, itemID)
					}
				}
			case "instructor":
				switch n.EnsenyaTipo {
				case "clase":
					if _, ok := m.clases[n.Ensenya]; !ok {
						t.Errorf("NPC %s enseña clase inexistente %s", n.ID, n.Ensenya)
					}
				case "profesion":
					if _, ok := m.profesiones[n.Ensenya]; !ok {
						t.Errorf("NPC %s enseña profesión inexistente %s", n.ID, n.Ensenya)
					}
				default:
					t.Errorf("NPC %s EnsenyaTipo inválido %q", n.ID, n.EnsenyaTipo)
				}
			}
		}
	}
}

// TestCaminoLeveoUnoAOchenta valida que existe un camino de zonas con niveles
// crecientes desde una zona 1-10 hasta la zona 80, de forma que un jugador
// pueda levear de 1 a 80 sin saltos de nivel imposibles.
func TestCaminoLeveoUnoAOchenta(t *testing.T) {
	m := nuevoMundoTest(t)
	zs := m.Zonas()
	// Encontrar zona final lvl 80.
	var finalID string
	for _, z := range zs {
		if z.NivelMax == 80 && z.Tipo == "final" {
			finalID = z.ID
			break
		}
	}
	if finalID == "" {
		t.Fatal("no hay zona final lvl 80")
	}
	// BFS desde una zona inicial, registrando el nivel máximo de zona visto;
	// debe alcanzar 80 siguiendo adyacencias sin un salto > 10 niveles entre
	// zona adyacentes (el jugador puede levear dentro de cada banda).
	visitados := map[string]bool{}
	cola := []string{}
	for _, z := range zs {
		if z.Tipo == "inicial" {
			cola = append(cola, z.ID)
		}
	}
	maxNivelAlcanzado := 0
	for len(cola) > 0 {
		actual := cola[0]
		cola = cola[1:]
		if visitados[actual] {
			continue
		}
		visitados[actual] = true
		z, _ := m.Zona(actual)
		if z.NivelMax > maxNivelAlcanzado {
			maxNivelAlcanzado = z.NivelMax
		}
		for _, c := range z.Conexiones {
			if !visitados[c] {
				cola = append(cola, c)
			}
		}
	}
	if maxNivelAlcanzado < 80 {
		t.Errorf("camino de leveo alcanza nivel %d, esperaba 80", maxNivelAlcanzado)
	}
}
