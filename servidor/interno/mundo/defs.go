// defs.go contiene definiciones de datos y utilidades del mundo:
// clases predefinidas, spawn inicial de mobs, y helpers matemáticos.
package mundo

import (
	"math"

	"aethelgard/servidor/interno/proto"
)

// sqrtF es math.Sqrt envuelto para evitar import disperso.
func sqrtF(x float64) float64 {
	return math.Sqrt(x)
}

// clasesPredefinidas devuelve las clases jugables del MVP.
// Se diseñan como datos para que añadir clases nuevas sea trivial.
//
// MVP: dos clases — guerrero (cuerpo a cuerpo, ira) y mago (rango, maná).
// Cada una tiene 2 habilidades activas + auto-ataque pasivo.
func clasesPredefinidas() map[string]DefClase {
	return map[string]DefClase{
		"guerrero": {
			ID:                   "guerrero",
			Nombre:               "Guerrero",
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
					ID:            "grito_guerra",
					Nombre:        "Grito de Guerra",
					Tipo:          "buff",
					CostoEnergia:  0,
					CooldownMs:    30000,
					RangoMetros:   0,
					TiempoCastMs:  0,
					DuracionBuffMs: 30000,
					MagnitudBuff:  0.10,
					IDBuff:        "grito_guerra",
					Icono:         "grito_guerra",
				},
			},
		},
		"mago": {
			ID:                   "mago",
			Nombre:               "Mago",
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
	}
}

// spawnEnemigosIniciales puebla el mundo con algunos mobs de prueba.
// Para MVP, tres lobos alrededor del punto de aparición de los jugadores.
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
