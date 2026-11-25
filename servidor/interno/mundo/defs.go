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

// ─── Razas (WoW 3.3.5a) ──────────────────────────────────────────────────
//
// 10 razas, 5 por facción, con la matriz raza-clase COMPLETA de 3.3.5a
// (las 10 clases jugables: guerrero, paladín, cazador, pícaro, sacerdote,
// mago, brujo, chamán, druida y caballero de la muerte). El DK está
// disponible para TODAS las razas. Cada raza lista TODOS sus raciales
// (activos y pasivos) fieles al 3.3.5a; los de efecto numérico directo se
// aplican al crear el PJ via ModHP/ModMana/ModDano, y los raciales de
// bonificación de profesión (Cultivo, Especialización Ingeniería, Tallar
// Gemas, Afinidad Arcana) via BonusProfesionID/Puntos.

// Racial describe un racial de raza. Los raciales son datos de diseño: los
// activos tienen cooldown y efecto (Elusividad, Forma de Piedra, Furia
// Sangrienta...); los pasivos son modificaciones permanentes (Diplomacia,
// Aguante, Mente Expansiva...). La mayoría no se aplican mecánicamente aquí
// (pertenecen al sistema de combate/CC, no al de razas): se almacenan como
// catálogo fiel al 3.3.5a.
type Racial struct {
	Nombre string `json:"nombre"`
	Desc   string `json:"desc"`
	Tipo   string `json:"tipo"` // "activo" | "pasivo"
}

// DefRaza define una raza jugable.
type DefRaza struct {
	ID           string   `json:"id"`
	Nombre       string   `json:"nombre"`
	Faccion      string   `json:"faccion"` // "alianza" | "horda"
	Clases       []string `json:"clases"`  // IDs de clase permitidos
	Raciales     []Racial `json:"raciales"`
	// RacialNombre/RacialDesc: racial principal destacado (para UI compacta).
	RacialNombre string `json:"racial_nombre"`
	RacialDesc   string `json:"racial_desc"`
	// Mods numéricos aplicados al crear el PJ (raciales pasivos con efecto
	// directo sobre HP/energía/daño).
	ModHP   float64 `json:"mod_hp"`   // +0.05 = +5% HP
	ModMana float64 `json:"mod_mana"` // +0.05 = +5% maná/energía
	ModDano float64 `json:"mod_dano"` // +0.05 = +5% daño
	// Bonus racial de profesión: al aprender esa profesión el jugador arranca
	// con BonusProfesionPuntos de skill (refleja Cultivo del Tauren +15
	// Herboristería, etc.).
	BonusProfesionID     string `json:"bonus_profesion_id,omitempty"`
	BonusProfesionPuntos int    `json:"bonus_profesion_puntos,omitempty"`
}

// razasPredefinidas devuelve las 10 razas jugables (5 Alianza + 5 Horda),
// cada una con su matriz raza-clase completa de 3.3.5a (incluido el DK,
// disponible para todas) y todos sus raciales (activos + pasivos).
func razasPredefinidas() map[string]DefRaza {
	return map[string]DefRaza{
		// ─── Alianza ───
		"humano": {
			ID: "humano", Nombre: "Humano", Faccion: FaccionAlianza,
			Clases: []string{"guerrero", "paladin", "picaro", "sacerdote", "mago", "brujo", "caballero_muerte"},
			Raciales: []Racial{
				{"Elusividad", "Elimina todos los efectos que limitan el movimiento y de pérdida de control. CD 2 min.", "activo"},
				{"Diplomacia", "+10% reputación obtenida.", "pasivo"},
				{"Espíritu Humano", "+3% Espíritu.", "pasivo"},
				{"Especialización en Espadas/Mazas", "+3 pericia con espadas y mazas (a una y dos manos).", "pasivo"},
				{"Percepción", "Detecta enemigos en sigilo de forma permanente.", "pasivo"},
			},
			RacialNombre: "Elusividad",
			RacialDesc:   "Elimina efectos de limitación de movimiento y pérdida de control (CD 2 min). +3% Espíritu.",
			ModMana:      0.03,
		},
		"enano": {
			ID: "enano", Nombre: "Enano", Faccion: FaccionAlianza,
			Clases: []string{"guerrero", "picaro", "cazador", "sacerdote", "caballero_muerte"},
			Raciales: []Racial{
				{"Forma de Piedra", "Inmuniza contra sangrado, veneno y enfermedad y +10% armadura durante 8 s. CD 3 min.", "activo"},
				{"Resistencia a la Escarcha", "-2% probabilidad de ser golpeado por hechizos de Escarcha.", "pasivo"},
				{"Especialización en Armas de Fuego", "+1% golpe crítico con armas de fuego.", "pasivo"},
				{"Especialización en Mazas", "+3 pericia con mazas (a una y dos manos).", "pasivo"},
				{"Buscador de Tesoros", "Detecta cofres y los muestra en el minimapa.", "activo"},
			},
			RacialNombre: "Forma de Piedra",
			RacialDesc:   "Inmune a sangrado/veneno/enfermedad y +10% armadura 8 s (CD 3 min). Representado como +5% HP.",
			ModHP:        0.05,
		},
		"elfo_nocturno": {
			ID: "elfo_nocturno", Nombre: "Elfo de la Noche", Faccion: FaccionAlianza,
			Clases: []string{"guerrero", "cazador", "picaro", "sacerdote", "druida", "caballero_muerte"},
			Raciales: []Racial{
				{"Fusión con las Sombras", "Entra en sigilo estacionario; se cancela al moverse o atacar.", "activo"},
				{"Espíritu Fatuo", "Al morir te transformas en fuego fatuo con +75% velocidad de movimiento.", "pasivo"},
				{"Resistencia a la Naturaleza", "-2% probabilidad de ser golpeado por hechizos de Naturaleza.", "pasivo"},
				{"Esquiva", "+2% esquiva a ataques cuerpo a cuerpo y a distancia.", "pasivo"},
			},
			RacialNombre: "Fusión con las Sombras",
			RacialDesc:   "Sigilo estacionario. +2% esquiva (representado como +2% HP de supervivencia).",
			ModHP:        0.02,
		},
		"gnomo": {
			ID: "gnomo", Nombre: "Gnomo", Faccion: FaccionAlianza,
			Clases: []string{"guerrero", "picaro", "mago", "brujo", "caballero_muerte"},
			Raciales: []Racial{
				{"Escape Artista", "Elimina todos los efectos que limitan el movimiento. CD 1 min 45 s.", "activo"},
				{"Mente Expansiva", "+5% Intelecto.", "pasivo"},
				{"Resistencia Arcana", "-2% probabilidad de ser golpeado por hechizos Arcanos.", "pasivo"},
				{"Especialización en Ingeniería", "+15 puntos de habilidad de Ingeniería.", "pasivo"},
			},
			RacialNombre: "Escape Artista",
			RacialDesc:   "Elimina efectos de limitación de movimiento. +5% Intelecto (representado como +5% maná).",
			ModMana:      0.05,
			BonusProfesionID: "ingenieria", BonusProfesionPuntos: 15,
		},
		"draenei": {
			ID: "draenei", Nombre: "Draenei", Faccion: FaccionAlianza,
			Clases: []string{"guerrero", "paladin", "cazador", "sacerdote", "chaman", "mago", "caballero_muerte"},
			Raciales: []Racial{
				{"Don de los Naaru", "Sana al objetivo durante 15 s; escala con poder de hechizo o de ataque.", "activo"},
				{"Presencia Heroica", "+1% probabilidad de golpe del grupo.", "pasivo"},
				{"Resistencia a las Sombras", "-2% probabilidad de ser golpeado por hechizos de Sombras.", "pasivo"},
				{"Tallar Gemas", "+5 puntos de habilidad de Joyería.", "pasivo"},
			},
			RacialNombre: "Don de los Naaru",
			RacialDesc:   "Hot de 15 s que escala con poder. +1% golpe del grupo (representado como +2% daño).",
			ModDano:      0.02,
			BonusProfesionID: "joyeria", BonusProfesionPuntos: 5,
		},
		// ─── Horda ───
		"orco": {
			ID: "orco", Nombre: "Orco", Faccion: FaccionHorda,
			Clases: []string{"guerrero", "cazador", "picaro", "chaman", "brujo", "caballero_muerte"},
			Raciales: []Racial{
				{"Furia Sangrienta", "+322 poder de ataque o +163 poder de hechizo (el mayor) durante 15 s. CD 2 min.", "activo"},
				{"Especialización en Hachas", "+5 pericia con hachas y armas de puño.", "pasivo"},
				{"Comando", "+5% daño infligido por las mascotas.", "pasivo"},
				{"Dureza", "-15% duración de los efectos de aturdimiento.", "pasivo"},
			},
			RacialNombre: "Furia Sangrienta",
			RacialDesc:   "+AP/PH durante 15 s (CD 2 min). Representado como +5% daño.",
			ModDano:      0.05,
		},
		"no_muerto": {
			ID: "no_muerto", Nombre: "Renegado", Faccion: FaccionHorda,
			Clases: []string{"guerrero", "picaro", "sacerdote", "mago", "brujo", "caballero_muerte"},
			Raciales: []Racial{
				{"Voluntad de los Renegados", "Elimina efectos de miedo, encanto y sueño. CD 2 min.", "activo"},
				{"Canibalizar", "Consume un cadáver cercano para sanar 7%/2 s durante 10 s (35% total).", "activo"},
				{"Resistencia a las Sombras", "-2% probabilidad de ser golpeado por hechizos de Sombras.", "pasivo"},
				{"Respiración Acuática", "+233% tiempo bajo el agua.", "pasivo"},
			},
			RacialNombre: "Voluntad de los Renegados",
			RacialDesc:   "Elimina miedo/encanto/sueño (CD 2 min). Sin modificador de stats directo.",
		},
		"tauren": {
			ID: "tauren", Nombre: "Tauren", Faccion: FaccionHorda,
			Clases: []string{"guerrero", "cazador", "chaman", "druida", "caballero_muerte"},
			Raciales: []Racial{
				{"Pisotón de Guerra", "Aturde a los enemigos en 8 yardas durante 2 s. CD 2 min.", "activo"},
				{"Aguante", "+5% salud base.", "pasivo"},
				{"Resistencia a la Naturaleza", "-2% probabilidad de ser golpeado por hechizos de Naturaleza.", "pasivo"},
				{"Cultivo", "+15 puntos de habilidad de Herboristería.", "pasivo"},
			},
			RacialNombre: "Pisotón de Guerra",
			RacialDesc:   "AoE stun 2 s en 8 yd (CD 2 min). +5% salud base.",
			ModHP:        0.05,
			BonusProfesionID: "herboristeria", BonusProfesionPuntos: 15,
		},
		"troll": {
			ID: "troll", Nombre: "Troll", Faccion: FaccionHorda,
			Clases: []string{"guerrero", "cazador", "picaro", "sacerdote", "chaman", "mago", "druida", "caballero_muerte"},
			Raciales: []Racial{
				{"Berserker", "+20% velocidad de ataque y de lanzamiento durante 10 s. CD 3 min.", "activo"},
				{"Matanza de Bestias", "+5% daño infligido a bestias.", "pasivo"},
				{"Especialización en Arcos/Arrojadizas", "+1% golpe crítico con arcos y armas arrojadizas.", "pasivo"},
				{"Regeneración", "+10% regeneración de salud; permite regenerar al 10% en combate.", "pasivo"},
				{"Paso Vudú", "-15% duración de efectos de ralentización e inmovilización.", "pasivo"},
			},
			RacialNombre: "Berserker",
			RacialDesc:   "+20% velocidad de ataque/lanzado 10 s (CD 3 min). Representado como +5% daño.",
			ModDano:      0.05,
		},
		"elfo_de_sangre": {
			ID: "elfo_de_sangre", Nombre: "Elfo de Sangre", Faccion: FaccionHorda,
			Clases: []string{"paladin", "cazador", "picaro", "sacerdote", "mago", "brujo", "caballero_muerte"},
			Raciales: []Racial{
				{"Torrente Arcano", "Silencia enemigos en 8 yardas durante 2 s y restaura 15 energía/poder rúnico o 6% maná. CD 2 min.", "activo"},
				{"Resistencia Mágica", "-2% probabilidad de ser golpeado por cualquier hechizo.", "pasivo"},
				{"Afinidad Arcana", "+10 puntos de habilidad de Encantamiento.", "pasivo"},
			},
			RacialNombre: "Torrente Arcano",
			RacialDesc:   "Silencia en área 2 s y restaura recursos (CD 2 min). +10 Encantamiento.",
			BonusProfesionID: "encantamiento", BonusProfesionPuntos: 10,
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

// clasesPredefinidas devuelve las 10 clases jugables del juego (las 9 de WoW
// LK clásicas + el Caballero de la Muerte heroico de WotLK). Cubren la
// trinidad de roles:
//   - Tanque: guerrero, paladín, caballero de la muerte
//   - DPS: mago, cazador, brujo, pícaro
//   - Soporte: sacerdote, chamán, druida
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
		// Chamán: soporte (sanador) híbrido. DPS a distancia (Elemental) o
		// cuerpo a cuerpo (Mejora); aquí rol soporte por su capacidad de
		// sanación. Disponible para draenei, orco, tauren y troll.
		"chaman": {
			ID: "chaman", Nombre: "Chamán", Rol: RolSoporte,
			HPBase: 90, HPPorNivel: 13, EnergiaBase: 100, EnergiaPorNivel: 5,
			TipoEnergia: "mana", RegenEnergia: 5,
			DañoAutoAtaque: 6, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 2.0,
			Habilidades: []DefHabilidad{
				{ID: "descarga_de_rayos", Nombre: "Descarga de Rayos", Tipo: "dano", CostoEnergia: 15, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 24, Icono: "descarga_de_rayos"},
				{ID: "ola_de_sanacion", Nombre: "Ola de Sanación", Tipo: "curacion", CostoEnergia: 25, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 35, Icono: "ola_de_sanacion"},
			},
		},
		// Druida: la clase más flexible (tanque Oso, sanador Restauración,
		// DPS Feral/Equilibrio). Aquí rol soporte por su sanación. Disponible
		// para elfo de la noche, tauren y troll.
		"druida": {
			ID: "druida", Nombre: "Druida", Rol: RolSoporte,
			HPBase: 85, HPPorNivel: 12, EnergiaBase: 100, EnergiaPorNivel: 5,
			TipoEnergia: "mana", RegenEnergia: 5,
			DañoAutoAtaque: 6, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 2.0,
			Habilidades: []DefHabilidad{
				{ID: "fuego_lunar", Nombre: "Fuego Lunar", Tipo: "dano", CostoEnergia: 18, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 26, Icono: "fuego_lunar"},
				{ID: "rejuvenecimiento", Nombre: "Rejuvenecimiento", Tipo: "curacion", CostoEnergia: 25, CooldownMs: 1500, RangoMetros: 30.0, DañoBase: 30, Icono: "rejuvenecimiento"},
			},
		},
		// Caballero de la Muerte (DK): tanque heroico introducido en WotLK,
		// disponible para TODAS las razas. Usa poder rúnico (aproximado como
		// "ira" en este modelo). Empieza a nivel 55 en WoW real (no modelado
		// aquí: se crea a nivel 1 como el resto).
		"caballero_muerte": {
			ID: "caballero_muerte", Nombre: "Caballero de la Muerte", Rol: RolTanque,
			HPBase: 130, HPPorNivel: 19, EnergiaBase: 100, EnergiaPorNivel: 0,
			TipoEnergia: "ira", RegenEnergia: 0,
			DañoAutoAtaque: 9, IntervaloAutoAtaqueMs: 2000, RangoCuerpoACuerpo: 2.5,
			Habilidades: []DefHabilidad{
				{ID: "golpe_de_plaga", Nombre: "Golpe de Plaga", Tipo: "dano", CostoEnergia: 15, CooldownMs: 1500, RangoMetros: 2.5, DañoBase: 24, Icono: "golpe_de_plaga"},
				{ID: "presencia_de_sangre", Nombre: "Presencia de Sangre", Tipo: "buff", CostoEnergia: 30, CooldownMs: 12000, RangoMetros: 0, DuracionBuffMs: 10000, MagnitudBuff: 0.10, IDBuff: "presencia_de_sangre", Icono: "presencia_de_sangre"},
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

// spawnEnemigosIniciales puebla el mundo abierto con los mobs definidos en
// el catálogo de zonas (DefZona.Spawns). Cada zona define su pool de mobs
// por nivel; los mobs del open world tienen instanciaID = "" (cadena vacía)
// y se separan de otras zonas por coordenadas de región (≥3000 entre sí).
// Sustituye a los 5 mobs de prueba hardcodeados del MVP inicial.
func (m *Mundo) spawnEnemigosIniciales() {
	i := 0
	for _, z := range m.zonas {
		for _, s := range z.Spawns {
			e := nuevoEnemigo(s.Nombre, s.Familia, s.Nivel, s.Pos)
			e.spawnPos = s.Pos
			e.id = sprintID("mob_", i+1)
			m.entidades[e.id] = e
			m.enemigos[e.id] = e
			i++
		}
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
