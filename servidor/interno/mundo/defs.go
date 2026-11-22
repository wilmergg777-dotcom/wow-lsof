// defs.go contiene definiciones de datos y utilidades del mundo:
// clases predefinidas, facciones, masmoras, arenas PvP y helpers matemáticos.
package mundo

import (
	"math"

	"aethelgard/servidor/interno/proto"
)

// ─── Facciones ───────────────────────────────────────────────────────────
//
// El mundo tiene dos facciones jugables. Por diseño, las facciones NO
// impiden agruparse: el buscador de masmorras (PvE) y las arenas (PvP)
// son cross-faction — jugadores de facciones distintas pueden estar en
// el mismo grupo PvE o en el mismo equipo PvP. La facción es sobre todo
// narrativa y de identidad visual para el cliente.

const (
	FaccionForjasol = "forjasol" // herreros del sol, facción militar
	FaccionLunagris = "lunagris" // vigías de la luna, facción arcana
)

// DefFaccion describe una facción jugable.
type DefFaccion struct {
	ID     string `json:"id"`
	Nombre string `json:"nombre"`
}

// faccionesPredefinidas devuelve las facciones jugables.
func faccionesPredefinidas() map[string]DefFaccion {
	return map[string]DefFaccion{
		FaccionForjasol: {ID: FaccionForjasol, Nombre: "Forjasol"},
		FaccionLunagris: {ID: FaccionLunagris, Nombre: "Lunagris"},
	}
}

// ─── Roles (para buscador de masmorras) ──────────────────────────────────
//
// Cada clase tiene un rol derivado. El buscador forma grupos PvE
// cubriendo la trinidad: 1 tanque + 1 soporte + N dps.

const (
	RolTanque  = "tanque"
	RolDPS     = "dps"
	RolSoporte = "soporte"
)

// sqrtF es math.Sqrt envuelto para evitar import disperso.
func sqrtF(x float64) float64 {
	return math.Sqrt(x)
}

// clasesPredefinidas devuelve las clases jugables del MVP.
// Se diseñan como datos para que añadir clases nuevas sea trivial.
//
// MVP: tres clases — guerrero (tanque, ira), mago (dps, maná) y
// sacerdote (soporte, maná). Cada una tiene 2 habilidades activas +
// auto-ataque pasivo.
func clasesPredefinidas() map[string]DefClase {
	return map[string]DefClase{
		"guerrero": {
			ID:                   "guerrero",
			Nombre:               "Guerrero",
			Rol:                  RolTanque,
			HPBase:               120,
			HPPorNivel:           18,
			EnergiaBase:          100,
			EnergiaPorNivel:      0,
			TipoEnergia:          "ira",
			RegenEnergia:         0, // la ira NO regenera sola; se genera en combate
			DañoAutoAtaque:       8,
			IntervaloAutoAtaqueMs: 2000,
			RangoCuerpoACuerpo:   2.0,
			Habilidades: []DefHabilidad{
				{
					ID:           "golpe_heroico",
					Nombre:       "Golpe Heroico",
					Tipo:         "dano",
					CostoEnergia: 15,
					CooldownMs:   1500,
					RangoMetros:  2.5,
					TiempoCastMs: 0,
					DañoBase:     22,
					Icono:        "golpe_heroico",
				},
				{
					ID:             "grito_guerra",
					Nombre:         "Grito de Guerra",
					Tipo:           "buff",
					CostoEnergia:   0,
					CooldownMs:     30000,
					RangoMetros:    0,
					TiempoCastMs:   0,
					DuracionBuffMs: 30000,
					MagnitudBuff:   0.10,
					IDBuff:         "grito_guerra",
					Icono:          "grito_guerra",
				},
			},
		},
		"mago": {
			ID:                   "mago",
			Nombre:               "Mago",
			Rol:                  RolDPS,
			HPBase:               70,
			HPPorNivel:           10,
			EnergiaBase:          100,
			EnergiaPorNivel:      5,
			TipoEnergia:          "mana",
			RegenEnergia:         5, // 5% por segundo
			DañoAutoAtaque:       4,
			IntervaloAutoAtaqueMs: 2000,
			RangoCuerpoACuerpo:   1.5,
			Habilidades: []DefHabilidad{
				{
					ID:           "flecha_de_hielo",
					Nombre:       "Flecha de Hielo",
					Tipo:         "dano",
					CostoEnergia: 20,
					CooldownMs:   1500,
					RangoMetros:  30.0,
					TiempoCastMs: 0,
					DañoBase:     28,
					Icono:        "flecha_de_hielo",
				},
				{
					ID:           "nova_de_escarcha",
					Nombre:       "Nova de Escarcha",
					Tipo:         "dano",
					CostoEnergia: 40,
					CooldownMs:   25000,
					RangoMetros:  12.0,
					TiempoCastMs: 0,
					DañoBase:     35,
					Icono:        "nova_de_escarcha",
				},
			},
		},
		"sacerdote": {
			ID:                   "sacerdote",
			Nombre:               "Sacerdote",
			Rol:                  RolSoporte,
			HPBase:               80,
			HPPorNivel:           12,
			EnergiaBase:          100,
			EnergiaPorNivel:      5,
			TipoEnergia:          "mana",
			RegenEnergia:         5, // 5% por segundo
			DañoAutoAtaque:       3,
			IntervaloAutoAtaqueMs: 2000,
			RangoCuerpoACuerpo:   1.5,
			Habilidades: []DefHabilidad{
				{
					ID:           "sanacion_rapida",
					Nombre:       "Sanación Rápida",
					Tipo:         "curacion",
					CostoEnergia: 25,
					CooldownMs:   1500,
					RangoMetros:  30.0, // alcance de curación
					TiempoCastMs: 0,
					DañoBase:     35, // magnitud de curación
					Icono:        "sanacion_rapida",
				},
				{
					ID:             "escudo_de_fe",
					Nombre:         "Escudo de Fe",
					Tipo:           "buff",
					CostoEnergia:   30,
					CooldownMs:     12000,
					RangoMetros:    30.0,
					TiempoCastMs:   0,
					DuracionBuffMs: 10000,
					MagnitudBuff:   0.15, // +15% defensa (interpretado como reducción de daño)
					IDBuff:         "escudo_de_fe",
					Icono:          "escudo_de_fe",
				},
			},
		},
	}
}

// ─── Masmoras (PvE instanciado) ──────────────────────────────────────────
//
// Una masmora es una instancia PvE creada a petición del buscador.
// Se puebla con mobs definidos en DefMasmora.Mobs. La condición de
// victoria es matar al boss (mob con EsBoss = true).
//
// Las masmoras usan coordenadas desplazadas (offset X >= 1000) para
// que sus entidades no colisionen visualmente con el mundo abierto
// en caso de un bug de filtrado por instancia.

// DefSpawnMob describe un mob a instanciar dentro de una masmora.
type DefSpawnMob struct {
	Nombre string `json:"nombre"`
	Tipo   string `json:"tipo"` // "lobo" | "jabali" | "esqueleto" | "boss"
	Nivel  int    `json:"nivel"`
	Pos    proto.Vec3 `json:"pos"`
	EsBoss bool   `json:"es_boss"`
}

// DefMasmora define una masmora jugable.
type DefMasmora struct {
	ID          string `json:"id"`
	Nombre      string `json:"nombre"`
	NivelMin    int    `json:"nivel_min"`
	TamanoGrupo int    `json:"tamano_grupo"` // 3 = 1 tanque + 1 soporte + 1 dps
	PosSpawn    proto.Vec3 `json:"pos_spawn"` // dónde aparecen los jugadores
	Mobs        []DefSpawnMob `json:"mobs"`
	BossID      string `json:"boss_id"` // ID del mob que es el boss (asignado al spawn)
}

// masmorasPredefinidas devuelve las masmoras disponibles para el buscador.
func masmorasPredefinidas() map[string]DefMasmora {
	return map[string]DefMasmora{
		"cripta_pinargos": {
			ID:          "cripta_pinargos",
			Nombre:      "Cripta de Pinargos",
			NivelMin:    1,
			TamanoGrupo: 3,
			PosSpawn:    proto.Vec3{X: 1000, Y: 0, Z: 0},
			Mobs: []DefSpawnMob{
				{Nombre: "Guardián Putrido", Tipo: "esqueleto", Nivel: 2, Pos: proto.Vec3{X: 1005, Y: 0, Z: 5}, EsBoss: false},
				{Nombre: "Acolito Oscuro", Tipo: "esqueleto", Nivel: 2, Pos: proto.Vec3{X: 1005, Y: 0, Z: -5}, EsBoss: false},
				{Nombre: "Señor de la Cripta", Tipo: "boss", Nivel: 4, Pos: proto.Vec3{X: 1020, Y: 0, Z: 0}, EsBoss: true},
			},
		},
		"cuevas_elderen": {
			ID:          "cuevas_elderen",
			Nombre:      "Cuevas de Elderen",
			NivelMin:    3,
			TamanoGrupo: 3,
			PosSpawn:    proto.Vec3{X: 2000, Y: 0, Z: 0},
			Mobs: []DefSpawnMob{
				{Nombre: "Murmurador", Tipo: "lobo", Nivel: 4, Pos: proto.Vec3{X: 2005, Y: 0, Z: 8}, EsBoss: false},
				{Nombre: "Murmurador", Tipo: "lobo", Nivel: 4, Pos: proto.Vec3{X: 2005, Y: 0, Z: -8}, EsBoss: false},
				{Nombre: "Trol de Cueva", Tipo: "jabali", Nivel: 5, Pos: proto.Vec3{X: 2015, Y: 0, Z: 0}, EsBoss: false},
				{Nombre: "Elderen el Antiguo", Tipo: "boss", Nivel: 7, Pos: proto.Vec3{X: 2030, Y: 0, Z: 0}, EsBoss: true},
			},
		},
	}
}

// ─── Arenas PvP ──────────────────────────────────────────────────────────
//
// Una arena es una instancia PvP con dos equipos. Los equipos son
// cross-faction: el buscador mezcla jugadores de cualquier facción en
// cualquier equipo. Victoria cuando un equipo queda sin vivos.
// Las arenas usan offset X >= 5000.

// DefArena define una arena PvP.
type DefArena struct {
	ID           string `json:"id"`
	Nombre       string `json:"nombre"`
	TamanoEquipo int    `json:"tamano_equipo"` // 2 = arena 2v2
	PosEquipoA   proto.Vec3 `json:"pos_equipo_a"`
	PosEquipoB   proto.Vec3 `json:"pos_equipo_b"`
	Radio        float64 `json:"radio"`        // tamaño de la arena
	TiempoMaxMs  int     `json:"tiempo_max_ms"` // timeout; al expirar, gana el equipo con más vivos
}

// arenasPredefinidas devuelve las arenas PvP disponibles.
func arenasPredefinidas() map[string]DefArena {
	return map[string]DefArena{
		"arena_skolm": {
			ID:           "arena_skolm",
			Nombre:       "Arena de Skolm",
			TamanoEquipo: 2, // 2v2
			PosEquipoA:   proto.Vec3{X: 5000, Y: 0, Z: -8},
			PosEquipoB:   proto.Vec3{X: 5000, Y: 0, Z: 8},
			Radio:        25.0,
			TiempoMaxMs:  300_000, // 5 minutos
		},
	}
}

// ─── Spawn del mundo abierto ─────────────────────────────────────────────

// spawnEnemigosIniciales puebla el mundo abierto con mobs de prueba.
// Para MVP, algunos lobos y jabalíes alrededor del punto de aparición.
// Los mobs del mundo abierto tienen instanciaID = "" (cadena vacía).
func (m *Mundo) spawnEnemigosIniciales() {
	// El jugador aparece cerca de (0, 0, 0). Ponemos lobos a unos 15-25m.
	spawns := []struct {
		nombre string
		pos    proto.Vec3
		nivel  int
	}{
		{"Lobo Salvaje", proto.Vec3{X: 15, Y: 0, Z: 5}, 1},
		{"Lobo Salvaje", proto.Vec3{X: -12, Y: 0, Z: 18}, 1},
		{"Lobo Alfa", proto.Vec3{X: 25, Y: 0, Z: -20}, 2},
		{"Jabalí Huraño", proto.Vec3{X: -25, Y: 0, Z: -8}, 1},
		{"Jabalí Huraño", proto.Vec3{X: 8, Y: 0, Z: -22}, 1},
	}
	for i, s := range spawns {
		e := nuevoEnemigo(s.nombre, "lobo", s.nivel, s.pos)
		e.spawnPos = s.pos
		// ID estable: lobo_<indice>
		e.id = sprintID("mob_", i+1)
		m.entidades[e.id] = e
		m.enemigos[e.id] = e
	}
}

// sprintID devuelve "prefijo" + número como string. Helper simple.
func sprintID(prefijo string, n int) string {
	return prefijo + itoaSimple(n)
}

// itoaSimple convierte un entero positivo a string sin usar fmt para evitar
// importar fmt en este archivo (mantener dependencias mínimas).
func itoaSimple(n int) string {
	if n == 0 {
		return "0"
	}
	neg := n < 0
	if neg {
		n = -n
	}
	var buf [20]byte
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	if neg {
		i--
		buf[i] = '-'
	}
	return string(buf[i:])
}
