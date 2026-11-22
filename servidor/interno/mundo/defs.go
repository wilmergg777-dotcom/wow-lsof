// defs.go contiene definiciones de datos y utilidades del mundo:
// facciones (Alianza/Horda), razas, clases, masmorras, arenas PvP y
// helpers matemáticos.
//
// Las facciones, razas y matriz raza-clase siguen el modelo de WoW 3.3.5
// (Wrath of the Lich King). Las masmorras adapten contenido (mobs, bosses,
// niveles) del proyecto world-of-claudecraft — solo los DATOS de diseño,
// nunca los gráficos ni la presentación visual.
package mundo

import (
	"math"

	"aethelgard/servidor/interno/proto"
)

// ─── Facciones (WoW 3.3.5) ───────────────────────────────────────────────
//
// Dos facciones: Alianza y Horda. Por diseño del buscador, las facciones
// NO impiden agruparse (cross-faction): un grupo PvE o un equipo PvP
// puede mezclar Alianza y Horda libremente. La facción determina qué razas
// puede elegir el personaje y es narrativa/de identidad.

const (
	FaccionAlianza = "alianza"
	FaccionHorda   = "horda"
)

// DefFaccion describe una facción jugable.
type DefFaccion struct {
	ID     string `json:"id"`
	Nombre string `json:"nombre"`
}

// faccionesPredefinidas devuelve las facciones jugables.
func faccionesPredefinidas() map[string]DefFaccion {
	return map[string]DefFaccion{
		FaccionAlianza: {ID: FaccionAlianza, Nombre: "Alianza"},
		FaccionHorda:   {ID: FaccionHorda, Nombre: "Horda"},
	}
}

// ─── Razas (WoW 3.3.5) ───────────────────────────────────────────────────
//
// 10 razas, 5 por facción, con la matriz raza-clase de 3.3.5a (filtrada a
// las 7 clases jugables de este MVP: guerrero, paladín, cazador, pícaro,
// sacerdote, mago, brujo). Cada raza tiene un racial pasivo que aplica
// modificadores de stats al crear el personaje.

// DefRaza define una raza jugable.
type DefRaza struct {
	ID           string   `json:"id"`
	Nombre       string   `json:"nombre"`
	Faccion      string   `json:"faccion"` // "alianza" | "horda"
	Clases       []string `json:"clases"`  // IDs de clase permitidos
	RacialNombre string   `json:"racial_nombre"`
	RacialDesc   string   `json:"racial_desc"`
	ModHP        float64  `json:"mod_hp"`   // +0.05 = +5% HP
	ModMana      float64  `json:"mod_mana"` // +0.05 = +5% maná/energía
	ModDano      float64  `json:"mod_dano"` // +0.05 = +5% daño
}

// razasPredefinidas devuelve las 10 razas jugables (5 Alianza + 5 Horda).
func razasPredefinidas() map[string]DefRaza {
	return map[string]DefRaza{
		// ─── Alianza ───
		"humano": {
			ID: "humano", Nombre: "Humano", Faccion: FaccionAlianza,
			Clases:       []string{"guerrero", "paladin", "picaro", "sacerdote", "mago", "brujo"},
			RacialNombre: "Voluntad Humana",
			RacialDesc:   "Libre de efectos de control (historia); +5% HP.",
			ModHP:        0.05,
		},
		"enano": {
			ID: "enano", Nombre: "Enano", Faccion: FaccionAlianza,
			Clases:       []string{"guerrero", "paladin", "cazador", "picaro", "sacerdote"},
			RacialNombre: "Forma de Piedra",
			RacialDesc:   "+5% armadura (representado como +5% HP).",
			ModHP:        0.05,
		},
		"elfo_nocturno": {
			ID: "elfo_nocturno", Nombre: "Elfo Nocturno", Faccion: FaccionAlianza,
			Clases:       []string{"guerrero", "cazador", "picaro", "sacerdote"},
			RacialNombre: "Fusión en las Sombras",
			RacialDesc:   "+5% esquiva (representado como +5% HP).",
			ModHP:        0.05,
		},
		"gnomo": {
			ID: "gnomo", Nombre: "Gnomo", Faccion: FaccionAlianza,
			Clases:       []string{"guerrero", "picaro", "mago", "brujo"},
			RacialNombre: "Intelecto Expansivo",
			RacialDesc:   "+5% maná.",
			ModMana:      0.05,
		},
		"draenei": {
			ID: "draenei", Nombre: "Draenei", Faccion: FaccionAlianza,
			Clases:       []string{"guerrero", "paladin", "cazador", "mago", "sacerdote"},
			RacialNombre: "Toque Heroico",
			RacialDesc:   "+5% daño.",
			ModDano:      0.05,
		},
		// ─── Horda ───
		"orco": {
			ID: "orco", Nombre: "Orco", Faccion: FaccionHorda,
			Clases:       []string{"guerrero", "cazador", "picaro", "brujo"},
			RacialNombre: "Sangre de Furia",
			RacialDesc:   "+5% daño.",
			ModDano:      0.05,
		},
		"no_muerto": {
			ID: "no_muerto", Nombre: "Renegado", Faccion: FaccionHorda,
			Clases:       []string{"guerrero", "picaro", "sacerdote", "mago", "brujo"},
			RacialNombre: "Voluntad de los Renegados",
			RacialDesc:   "Inmune a miedo (historia); +5% HP.",
			ModHP:        0.05,
		},
		"tauren": {
			ID: "tauren", Nombre: "Tauren", Faccion: FaccionHorda,
			Clases:       []string{"guerrero", "cazador"},
			RacialNombre: "Resistencia Total",
			RacialDesc:   "+5% HP.",
			ModHP:        0.05,
		},
		"troll": {
			ID: "troll", Nombre: "Troll", Faccion: FaccionHorda,
			Clases:       []string{"guerrero", "cazador", "picaro", "sacerdote", "mago"},
			RacialNombre: "Regeneración",
			RacialDesc:   "+5% maná.",
			ModMana:      0.05,
		},
		"elfo_de_sangre": {
			ID: "elfo_de_sangre", Nombre: "Elfo de Sangre", Faccion: FaccionHorda,
			Clases:       []string{"paladin", "cazador", "picaro", "sacerdote", "mago", "brujo"},
			RacialNombre: "Torrente Arcano",
			RacialDesc:   "+5% daño.",
			ModDano:      0.05,
		},
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

// clasesPredefinidas devuelve las 7 clases jugables del juego.
// Cubren la trinidad de roles de WoW LK:
//   - Tanque: guerrero, paladín
//   - DPS: mago, cazador, brujo, pícaro
//   - Soporte: sacerdote
// Cada clase tiene 2 habilidades activas + auto-ataque pasivo.
func clasesPredefinidas() map[string]DefClase {
	return map[string]DefClase{
		"guerrero": {
			ID: "guerrero", Nombre: "Guerrero", Rol: RolTanque,
			HPBase: 120, HPPorNivel: 18, EnergiaBase: 100, EnergiaPorNivel: 0,
			TipoEnergia: "ira", RegenEnergia: 0,
			DañoAutoAtaque: 8, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 2.0,
			Habilidades: []DefHabilidad{
				{ID: "golpe_heroico", Nombre: "Golpe Heroico", Tipo: "dano", CostoEnergia: 15, CooldownMs: 1500, RangoMetros: 2.5, DañoBase: 22, Icono: "golpe_heroico"},
				{ID: "grito_guerra", Nombre: "Grito de Guerra", Tipo: "buff", CostoEnergia: 0, CooldownMs: 30000, RangoMetros: 0, DuracionBuffMs: 30000, MagnitudBuff: 0.10, IDBuff: "grito_guerra", Icono: "grito_guerra"},
			},
		},
		"paladin": {
			ID: "paladin", Nombre: "Paladín", Rol: RolTanque,
			HPBase: 115, HPPorNivel: 17, EnergiaBase: 100, EnergiaPorNivel: 5,
			TipoEnergia: "mana", RegenEnergia: 5,
			DañoAutoAtaque: 7, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 2.0,
			Habilidades: []DefHabilidad{
				{ID: "martillo_de_luz", Nombre: "Martillo de Luz", Tipo: "dano", CostoEnergia: 18, CooldownMs: 1500, RangoMetros: 20.0, DañoBase: 20, Icono: "martillo_de_luz"},
				{ID: "escudo_divino", Nombre: "Escudo Divino", Tipo: "buff", CostoEnergia: 30, CooldownMs: 12000, RangoMetros: 0, DuracionBuffMs: 8000, MagnitudBuff: 0.20, IDBuff: "escudo_divino", Icono: "escudo_divino"},
			},
		},
		"cazador": {
			ID: "cazador", Nombre: "Cazador", Rol: RolDPS,
			HPBase: 85, HPPorNivel: 12, EnergiaBase: 100, EnergiaPorNivel: 5,
			TipoEnergia: "mana", RegenEnergia: 5,
			DañoAutoAtaque: 6, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 5.0,
			Habilidades: []DefHabilidad{
				{ID: "disparo_arcano", Nombre: "Disparo Arcano", Tipo: "dano", CostoEnergia: 15, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 24, Icono: "disparo_arcano"},
				{ID: "disparo_congelante", Nombre: "Disparo Congelante", Tipo: "dano", CostoEnergia: 30, CooldownMs: 8000, RangoMetros: 30.0, DañoBase: 30, Icono: "disparo_congelante"},
			},
		},
		"picaro": {
			ID: "picaro", Nombre: "Pícaro", Rol: RolDPS,
			HPBase: 90, HPPorNivel: 13, EnergiaBase: 100, EnergiaPorNivel: 0,
			TipoEnergia: "energia", RegenEnergia: 20,
			DañoAutoAtaque: 7, IntervaloAutoAtaqueMs: 1800, RangoCuerpoACuerpo: 2.0,
			Habilidades: []DefHabilidad{
				{ID: "golpe_siniestro", Nombre: "Golpe Siniestro", Tipo: "dano", CostoEnergia: 40, CooldownMs: 1500, RangoMetros: 2.5, DañoBase: 26, Icono: "golpe_siniestro"},
				{ID: "evasion", Nombre: "Evasión", Tipo: "buff", CostoEnergia: 50, CooldownMs: 18000, RangoMetros: 0, DuracionBuffMs: 10000, MagnitudBuff: 0.50, IDBuff: "evasion", Icono: "evasion"},
			},
		},
		"mago": {
			ID: "mago", Nombre: "Mago", Rol: RolDPS,
			HPBase: 70, HPPorNivel: 10, EnergiaBase: 100, EnergiaPorNivel: 5,
			TipoEnergia: "mana", RegenEnergia: 5,
			DañoAutoAtaque: 4, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 1.5,
			Habilidades: []DefHabilidad{
				{ID: "flecha_de_hielo", Nombre: "Flecha de Hielo", Tipo: "dano", CostoEnergia: 20, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 28, Icono: "flecha_de_hielo"},
				{ID: "nova_de_escarcha", Nombre: "Nova de Escarcha", Tipo: "dano", CostoEnergia: 40, CooldownMs: 25000, RangoMetros: 12.0, DañoBase: 35, Icono: "nova_de_escarcha"},
			},
		},
		"brujo": {
			ID: "brujo", Nombre: "Brujo", Rol: RolDPS,
			HPBase: 75, HPPorNivel: 11, EnergiaBase: 100, EnergiaPorNivel: 5,
			TipoEnergia: "mana", RegenEnergia: 5,
			DañoAutoAtaque: 4, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 1.5,
			Habilidades: []DefHabilidad{
				{ID: "sastraburil", Nombre: "Sastraburil", Tipo: "dano", CostoEnergia: 22, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 30, Icono: "sastraburil"},
				{ID: "maldicion_de_agonia", Nombre: "Maldición de Agonía", Tipo: "dano", CostoEnergia: 35, CooldownMs: 12000, RangoMetros: 30.0, DañoBase: 38, Icono: "maldicion_de_agonia"},
			},
		},
		"sacerdote": {
			ID: "sacerdote", Nombre: "Sacerdote", Rol: RolSoporte,
			HPBase: 80, HPPorNivel: 12, EnergiaBase: 100, EnergiaPorNivel: 5,
			TipoEnergia: "mana", RegenEnergia: 5,
			DañoAutoAtaque: 3, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 1.5,
			Habilidades: []DefHabilidad{
				{ID: "sanacion_rapida", Nombre: "Sanación Rápida", Tipo: "curacion", CostoEnergia: 25, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 35, Icono: "sanacion_rapida"},
				{ID: "escudo_de_fe", Nombre: "Escudo de Fe", Tipo: "buff", CostoEnergia: 30, CooldownMs: 12000, RangoMetros: 30.0, DuracionBuffMs: 10000, MagnitudBuff: 0.15, IDBuff: "escudo_de_fe", Icono: "escudo_de_fe"},
			},
		},
	}
}

// ─── Masmoras (PvE instanciado) ──────────────────────────────────────────
//
// Las masmorras adapten contenido del proyecto world-of-claudecraft: los
// nombres, familias de mobs, niveles y bosses son de ahí (solo los DATOS
// de diseño, no los gráficos). Coordenadas con offset X >= 1000 para
// aislar las instancias del mundo abierto.

// DefSpawnMob describe un mob a instanciar dentro de una masmora.
// HPBase/HPPorNivel/DanoBase permiten stats explícitos (estilo wocc);
// si HPBase == 0 se usa la fórmula por defecto (40 + nivel*15).
type DefSpawnMob struct {
	Nombre     string     `json:"nombre"`
	Tipo       string     `json:"tipo"` // familia: "undead"|"humanoid"|"beast"|"elemental"|"dragonkin"
	Nivel      int        `json:"nivel"`
	Pos        proto.Vec3 `json:"pos"`
	EsBoss     bool       `json:"es_boss"`
	HPBase     int        `json:"hp_base,omitempty"`
	HPPorNivel int        `json:"hp_por_nivel,omitempty"`
	DanoBase   int        `json:"dano_base,omitempty"`
}

// DefMasmora define una masmora jugable.
type DefMasmora struct {
	ID          string        `json:"id"`
	Nombre      string        `json:"nombre"`
	NivelMin    int           `json:"nivel_min"`
	TamanoGrupo int           `json:"tamano_grupo"`
	PosSpawn    proto.Vec3    `json:"pos_spawn"`
	Mobs        []DefSpawnMob `json:"mobs"`
	BossID      string        `json:"boss_id"`
}

// masmorasPredefinidas devuelve las masmoras disponibles, adaptadas de
// world-of-claudecraft (hollow_crypt, sunken_bastion, gravewyrm_sanctum,
// drowned_temple, wildheart_basin). Niveles y bosses siguen los de wocc.
func masmorasPredefinidas() map[string]DefMasmora {
	return map[string]DefMasmora{
		// 1. La Cripta Hueca (hollow_crypt) — lvl 7-10
		"hollow_crypt": {
			ID: "hollow_crypt", Nombre: "La Cripta Hueca",
			NivelMin: 5, TamanoGrupo: 3,
			PosSpawn: proto.Vec3{X: 1000, Y: 0, Z: 0},
			Mobs: []DefSpawnMob{
				{Nombre: "Arrastrador de Cripta", Tipo: "undead", Nivel: 7, Pos: proto.Vec3{X: 1005, Y: 0, Z: 6}, HPBase: 30, HPPorNivel: 10, DanoBase: 4},
				{Nombre: "Acólito Hueco", Tipo: "humanoid", Nivel: 7, Pos: proto.Vec3{X: 1005, Y: 0, Z: -6}, HPBase: 30, HPPorNivel: 10, DanoBase: 4},
				{Nombre: "Viuda Huésped", Tipo: "beast", Nivel: 8, Pos: proto.Vec3{X: 1012, Y: 0, Z: 0}, HPBase: 35, HPPorNivel: 11, DanoBase: 5},
				{Nombre: "Morthen el Convocador de Tumbas", Tipo: "undead", Nivel: 10, Pos: proto.Vec3{X: 1025, Y: 0, Z: 0}, EsBoss: true, HPBase: 100, HPPorNivel: 22, DanoBase: 9},
			},
		},
		// 2. El Bastión Hundido (sunken_bastion) — lvl 12-13
		"sunken_bastion": {
			ID: "sunken_bastion", Nombre: "El Bastión Hundido",
			NivelMin: 10, TamanoGrupo: 3,
			PosSpawn: proto.Vec3{X: 2000, Y: 0, Z: 0},
			Mobs: []DefSpawnMob{
				{Nombre: "Revenante del Bastión", Tipo: "undead", Nivel: 12, Pos: proto.Vec3{X: 2005, Y: 0, Z: 8}, HPBase: 45, HPPorNivel: 13, DanoBase: 6},
				{Nombre: "Acólito Atado al Mar", Tipo: "humanoid", Nivel: 12, Pos: proto.Vec3{X: 2005, Y: 0, Z: -8}, HPBase: 45, HPPorNivel: 13, DanoBase: 6},
				{Nombre: "Thrall Anegado", Tipo: "undead", Nivel: 13, Pos: proto.Vec3{X: 2015, Y: 0, Z: 0}, HPBase: 50, HPPorNivel: 14, DanoBase: 7},
				{Nombre: "Vael el Llamador de Niebla", Tipo: "humanoid", Nivel: 13, Pos: proto.Vec3{X: 2030, Y: 0, Z: 0}, EsBoss: true, HPBase: 110, HPPorNivel: 24, DanoBase: 10},
			},
		},
		// 3. El Templo Anegado (drowned_temple) — lvl 14
		"drowned_temple": {
			ID: "drowned_temple", Nombre: "El Templo Anegado",
			NivelMin: 12, TamanoGrupo: 3,
			PosSpawn: proto.Vec3{X: 3000, Y: 0, Z: 0},
			Mobs: []DefSpawnMob{
				{Nombre: "Mordedor de Laguna", Tipo: "beast", Nivel: 14, Pos: proto.Vec3{X: 3005, Y: 0, Z: 8}, HPBase: 55, HPPorNivel: 15, DanoBase: 7},
				{Nombre: "Espectro de Hielo", Tipo: "elemental", Nivel: 14, Pos: proto.Vec3{X: 3005, Y: 0, Z: -8}, HPBase: 50, HPPorNivel: 14, DanoBase: 8},
				{Nombre: "Sirena Lunar", Tipo: "humanoid", Nivel: 14, Pos: proto.Vec3{X: 3015, Y: 0, Z: 0}, HPBase: 55, HPPorNivel: 15, DanoBase: 7},
				{Nombre: "Madre del Coro Selthe", Tipo: "humanoid", Nivel: 15, Pos: proto.Vec3{X: 3030, Y: 0, Z: 0}, EsBoss: true, HPBase: 120, HPPorNivel: 26, DanoBase: 11},
			},
		},
		// 4. Cuenca Corazón Salvaje (wildheart_basin) — lvl 16-18
		"wildheart_basin": {
			ID: "wildheart_basin", Nombre: "Cuenca Corazón Salvaje",
			NivelMin: 14, TamanoGrupo: 3,
			PosSpawn: proto.Vec3{X: 4000, Y: 0, Z: 0},
			Mobs: []DefSpawnMob{
				{Nombre: "Acechador Zarpa Vidriosa", Tipo: "beast", Nivel: 16, Pos: proto.Vec3{X: 4005, Y: 0, Z: 8}, HPBase: 60, HPPorNivel: 16, DanoBase: 8},
				{Nombre: "Despedazador Corazón Salvaje", Tipo: "beast", Nivel: 16, Pos: proto.Vec3{X: 4005, Y: 0, Z: -8}, HPBase: 60, HPPorNivel: 16, DanoBase: 8},
				{Nombre: "Brujo Corazón Salvaje", Tipo: "humanoid", Nivel: 17, Pos: proto.Vec3{X: 4015, Y: 0, Z: 0}, HPBase: 55, HPPorNivel: 16, DanoBase: 9},
				{Nombre: "Bestiarca Corazón Salvaje", Tipo: "humanoid", Nivel: 18, Pos: proto.Vec3{X: 4030, Y: 0, Z: 0}, EsBoss: true, HPBase: 130, HPPorNivel: 28, DanoBase: 12},
			},
		},
		// 5. Santuario Gusanoso (gravewyrm_sanctum) — lvl 18-20
		"gravewyrm_sanctum": {
			ID: "gravewyrm_sanctum", Nombre: "Santuario Gusanoso",
			NivelMin: 16, TamanoGrupo: 3,
			PosSpawn: proto.Vec3{X: 5000, Y: 0, Z: 0},
			Mobs: []DefSpawnMob{
				{Nombre: "Guardia de Hueso del Santuario", Tipo: "undead", Nivel: 18, Pos: proto.Vec3{X: 5005, Y: 0, Z: 8}, HPBase: 70, HPPorNivel: 18, DanoBase: 9},
				{Nombre: "Dracónido del Santuario", Tipo: "dragonkin", Nivel: 18, Pos: proto.Vec3{X: 5005, Y: 0, Z: -8}, HPBase: 70, HPPorNivel: 18, DanoBase: 9},
				{Nombre: "Guardia de Hueso del Santuario", Tipo: "undead", Nivel: 19, Pos: proto.Vec3{X: 5015, Y: 0, Z: 0}, HPBase: 75, HPPorNivel: 19, DanoBase: 10},
				{Nombre: "Korzul el Gusanoso", Tipo: "dragonkin", Nivel: 20, Pos: proto.Vec3{X: 5030, Y: 0, Z: 0}, EsBoss: true, HPBase: 150, HPPorNivel: 30, DanoBase: 13},
			},
		},
	}
}

// ─── Arenas PvP ──────────────────────────────────────────────────────────
//
// Arena PvP con dos equipos cross-faction. Coordenadas offset X >= 9000.

// DefArena define una arena PvP.
type DefArena struct {
	ID           string     `json:"id"`
	Nombre       string     `json:"nombre"`
	TamanoEquipo int        `json:"tamano_equipo"`
	PosEquipoA   proto.Vec3 `json:"pos_equipo_a"`
	PosEquipoB   proto.Vec3 `json:"pos_equipo_b"`
	Radio        float64    `json:"radio"`
	TiempoMaxMs  int        `json:"tiempo_max_ms"`
}

// arenasPredefinidas devuelve las arenas PvP disponibles.
func arenasPredefinidas() map[string]DefArena {
	return map[string]DefArena{
		"arena_skolm": {
			ID: "arena_skolm", Nombre: "Arena de Skolm",
			TamanoEquipo: 2,
			PosEquipoA:  proto.Vec3{X: 9000, Y: 0, Z: -8},
			PosEquipoB:  proto.Vec3{X: 9000, Y: 0, Z: 8},
			Radio:       25.0,
			TiempoMaxMs: 300_000,
		},
	}
}

// ─── Spawn del mundo abierto ─────────────────────────────────────────────

// spawnEnemigosIniciales puebla el mundo abierto con mobs de prueba.
// Los mobs del mundo abierto tienen instanciaID = "" (cadena vacía).
func (m *Mundo) spawnEnemigosIniciales() {
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
		e.id = sprintID("mob_", i+1)
		m.entidades[e.id] = e
		m.enemigos[e.id] = e
	}
}

// sprintID devuelve "prefijo" + número como string. Helper simple.
func sprintID(prefijo string, n int) string {
	return prefijo + itoaSimple(n)
}

// itoaSimple convierte un entero positivo a string sin usar fmt.
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
