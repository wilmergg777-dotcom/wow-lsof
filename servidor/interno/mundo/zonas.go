// zonas.go implementa el mundo abierto de WoW 3.3.5a: el catálogo de zonas
// por nivel (1-80) con grafo de conexiones, las 10 capitales raciales (una
// por raza) con NPCs vendedores e instructores, el spawn de mobs del open
// world por zona y el viaje entre zonas adyacentes.
//
// Diseño:
//   - El open world sigue siendo un plano único con instanciaID="" y
//     filtrado por proximidad (RadioInteresMetros=60). Las zonas se separan
//     por COORDENADAS DE REGIÓN: cada zona ocupa un bloque centrado en
//     Region, a ≥3000 unidades de cualquier otra zona, así los mobs/players
//     de zonas distintas nunca se ven (más allá del radio de interés).
//     Las coordenadas de región evitan el carril de masmorras (X∈[1000,5000],
//     Z≈0) y la arena PvP (X=9000, Z≈0).
//   - Las capitales raciales son datos (DefCiudad) con NPCs (DefNPC): los
//     NPCs son estacionarios y se acceden por ID con validación de
//     proximidad (InteractuarNPC), sin pasar por el tick de IA.
//   - El spawn del open world se genera a partir del catálogo de zonas
//     (Zona.Spawns), reemplazando los 5 mobs de prueba hardcodeados.
//   - ViajarZona valida la adyacencia (grafo Zona.Conexiones) y teletransporta
//     al jugador al punto de entrada de la zona destino.

package mundo

import (
	"errors"

	"aethelgard/servidor/interno/proto"
)

// RadioRegionZona define el radio (en metros del plano XZ) alrededor del
// centro de región de una zona que pertenece a esa zona. Las regiones están
// a ≥3000 unidades entre sí, así 1000 es inequívoco.
const RadioRegionZona = 1000.0

// RangoInteraccionNPC es la distancia máxima (metros XZ) para interactuar
// con un NPC (vendedor/instructor).
const RangoInteraccionNPC = 5.0

// ─── Zonas ───────────────────────────────────────────────────────────────

// DefZona describe una zona del mundo abierto.
type DefZona struct {
	ID           string         `json:"id"`
	Nombre       string         `json:"nombre"`
	NivelMin     int            `json:"nivel_min"`
	NivelMax     int            `json:"nivel_max"`
	Faccion      string         `json:"faccion"` // "alianza" | "horda" | "neutral"
	Tipo         string         `json:"tipo"`    // "inicial" | "medio" | "final"
	CiudadID     string         `json:"ciudad_id,omitempty"`
	Conexiones   []string       `json:"conexiones"` // zonas adyacentes (grafo)
	Region       proto.Vec3     `json:"region"`     // centro de región (separación ≥3000)
	PuntoEntrada proto.Vec3     `json:"punto_entrada"`
	Spawns       []DefSpawnZona `json:"spawns"`
}

// DefSpawnZona describe un mob del open world dentro de una zona.
type DefSpawnZona struct {
	Nombre  string     `json:"nombre"`
	Familia string     `json:"familia"` // label cosmético: "lobo"|"jabali"|"murloc"|...
	Nivel   int        `json:"nivel"`
	Pos     proto.Vec3 `json:"pos"` // posición absoluta
}

// DefCiudad describe una capital racial con sus NPCs.
type DefCiudad struct {
	ID         string    `json:"id"`
	Nombre     string    `json:"nombre"`
	Faccion    string    `json:"faccion"`
	RazaID     string    `json:"raza_id"` // raza asociada (una por capital)
	ZonaID     string    `json:"zona_id"`
	SpawnPoint proto.Vec3 `json:"spawn_point"` // donde aparecen los PJs de esa raza
	NPCs       []DefNPC  `json:"npcs"`
}

// DefNPC describe un NPC amistoso (vendedor o instructor).
type DefNPC struct {
	ID          string   `json:"id"`
	Nombre      string   `json:"nombre"`
	Tipo        string   `json:"tipo"` // "vendedor" | "instructor"
	VendeItems  []string `json:"vende_items,omitempty"`
	EnsenyaTipo string   `json:"ensenya_tipo,omitempty"` // "clase" | "profesion"
	Ensenya     string   `json:"ensenya,omitempty"`      // claseID o profID
	Pos         proto.Vec3 `json:"pos"`
}

// ─── Helpers de construcción (compactan el catálogo) ─────────────────────

// sp construye un spawn relativo al centro de región (dx,dz); la posición
// absoluta la calcula zona() sumando Region.
func sp(nombre, familia string, nivel int, dx, dz float64) DefSpawnZona {
	return DefSpawnZona{Nombre: nombre, Familia: familia, Nivel: nivel,
		Pos: proto.Vec3{X: dx, Y: 0, Z: dz}}
}

// zona construye una DefZona, traduciendo los spawns relativos a absolutos.
func zona(id, nombre string, nmin, nmax int, faccion, tipo, ciudadID string,
	rx, rz float64, conexiones []string, spawns []DefSpawnZona) DefZona {
	region := proto.Vec3{X: rx, Y: 0, Z: rz}
	out := DefZona{
		ID: id, Nombre: nombre, NivelMin: nmin, NivelMax: nmax,
		Faccion: faccion, Tipo: tipo, CiudadID: ciudadID,
		Conexiones:   conexiones,
		Region:       region,
		PuntoEntrada: region,
		Spawns:       make([]DefSpawnZona, len(spawns)),
	}
	for i, s := range spawns {
		s.Pos = proto.Vec3{X: rx + s.Pos.X, Y: 0, Z: rz + s.Pos.Z}
		out.Spawns[i] = s
	}
	return out
}

// npcV construye un NPC vendedor.
func npcV(id, nombre string, rx, rz, dx, dz float64, items []string) DefNPC {
	return DefNPC{ID: id, Nombre: nombre, Tipo: "vendedor",
		VendeItems: items,
		Pos:        proto.Vec3{X: rx + dx, Y: 0, Z: rz + dz}}
}

// npcIC construye un NPC instructor de clase.
func npcIC(id, nombre string, rx, rz, dx, dz float64, claseID string) DefNPC {
	return DefNPC{ID: id, Nombre: nombre, Tipo: "instructor",
		EnsenyaTipo: "clase", Ensenya: claseID,
		Pos: proto.Vec3{X: rx + dx, Y: 0, Z: rz + dz}}
}

// npcIP construye un NPC instructor de profesión.
func npcIP(id, nombre string, rx, rz, dx, dz float64, profID string) DefNPC {
	return DefNPC{ID: id, Nombre: nombre, Tipo: "instructor",
		EnsenyaTipo: "profesion", Ensenya: profID,
		Pos: proto.Vec3{X: rx + dx, Y: 0, Z: rz + dz}}
}

// venderGeneral es el catálogo de bienes genéricos de un vendedor (comida +
// pergaminos). Todos los IDs existen en itemsPredefinidos().
var venderGeneral = []string{
	"ciruela_blanca_sabrosa",
	"trucha_mantequilla_caliente",
	"pergamino_aguante",
	"pergamino_agilidad_viii",
	"pergamino_intelecto_viii",
	"pergamino_fuerza_viii",
}

// zonasPredefinidas devuelve el catálogo de zonas del mundo (1-80).
// 8 zonas iniciales (una por raza, las compartidas dun_morogh/durotar
// alojan 2 capitales) + zonas de leveo 10-80 con grafo conexo.
func zonasPredefinidas() map[string]DefZona {
	zs := []DefZona{
		// ─── Zonas iniciales (1-10) ───
		zona("elwynn", "Bosque de Elwynn", 1, 10, FaccionAlianza, "inicial", "ventormenta",
			-3000, -3000, []string{"trabalita_vegas", "dun_morogh"},
			[]DefSpawnZona{
				sp("Lobo Forestal", "lobo", 2, 40, 30),
				sp("Jabalí Pardo", "jabali", 1, -50, 20),
				sp("Kobold Minero", "kobold", 3, 60, -40),
			}),
		zona("dun_morogh", "Dun Morogh", 1, 10, FaccionAlianza, "inicial", "forjaz",
			-6000, -3000, []string{"elwynn", "loch_modan"},
			[]DefSpawnZona{
				sp("Lobo Invernal", "lobo", 2, 40, -30),
				sp("Jabalí de Nieve", "jabali", 1, -50, 40),
				sp("Trogg", "trogg", 3, 60, 50),
			}),
		zona("teldrassil", "Teldrassil", 1, 10, FaccionAlianza, "inicial", "darnassus",
			-3000, -6000, []string{"costa_oscura"},
			[]DefSpawnZona{
				sp("Tejón Vicioso", "bestia", 2, 40, 30),
				sp("Furbolg Joven", "furbolg", 4, -60, -40),
				sp("Sable de la Noche", "bestia", 3, 50, -50),
			}),
		zona("islas_bruma_azure", "Isla Bruma Azure", 1, 10, FaccionAlianza, "inicial", "el_exodar",
			-6000, -6000, []string{"costa_oscura"},
			[]DefSpawnZona{
				sp("Acechador Modalén", "bestia", 2, 40, -30),
				sp("Elemental de Fuego", "elemental", 5, -60, 50),
				sp("Sable Modalén", "bestia", 3, 50, 40),
			}),
		zona("durotar", "Durotar", 1, 10, FaccionHorda, "inicial", "orgrimmar",
			6000, -3000, []string{"los_baldios"},
			[]DefSpawnZona{
				sp("Jabalí Espinoso", "jabali", 2, 40, 30),
				sp("Escórpido", "bestia", 3, -50, -40),
				sp("Saurok", "humanoide", 4, 60, 50),
			}),
		zona("tirisfal", "Claro de Tirisfal", 1, 10, FaccionHorda, "inicial", "entranas",
			6000, -6000, []string{"pinargenta"},
			[]DefSpawnZona{
				sp("Zombi Podrido", "zombi", 2, 40, -30),
				sp("Murloc", "murloc", 4, -60, 50),
				sp("Espectro", "zombi", 5, 50, 40),
			}),
		zona("mulgore", "Mulgore", 1, 10, FaccionHorda, "inicial", "cima_trueno",
			9000, -3000, []string{"los_baldios"},
			[]DefSpawnZona{
				sp("Aveztruz", "bestia", 2, 40, 30),
				sp("Lobo de Pradera", "lobo", 3, -50, -40),
				sp("Kodo Joven", "bestia", 5, 60, 50),
			}),
		zona("bosque_eterno", "Bosque Canción Eterna", 1, 10, FaccionHorda, "inicial", "lunargenta",
			9000, -6000, []string{"tierras_fantasmales"},
			[]DefSpawnZona{
				sp("Manábestia", "bestia", 2, 40, -30),
				sp("Marchito", "humanoide", 4, -60, 50),
				sp("Lince", "bestia", 3, 50, 40),
			}),

		// ─── Zonas 10-20 ───
		zona("trabalita_vegas", "Vegas de Trabalita", 10, 20, FaccionAlianza, "medio", "",
			-3000, 3000, []string{"elwynn", "loch_modan", "crepusculo"},
			[]DefSpawnZona{
				sp("Defias", "humanoide", 12, 40, 30),
				sp("Jabalí Pardo", "jabali", 11, -50, -40),
				sp("Murloc", "murloc", 13, 60, 50),
			}),
		zona("loch_modan", "Loch Modan", 10, 20, FaccionAlianza, "medio", "",
			-6000, 3000, []string{"dun_morogh", "trabalita_vegas", "laderas_trabalita"},
			[]DefSpawnZona{
				sp("Trogg", "trogg", 12, 40, -30),
				sp("Oso Pardo", "bestia", 14, -60, 50),
				sp("Kobold", "kobold", 11, 50, 40),
			}),
		zona("costa_oscura", "Costa Oscura", 10, 20, FaccionAlianza, "medio", "",
			-3000, 6000, []string{"teldrassil", "islas_bruma_azure", "valle_gris"},
			[]DefSpawnZona{
				sp("Furbolg", "furbolg", 12, 40, 30),
				sp("Murloc", "murloc", 14, -50, -40),
				sp("Acechador", "bestia", 13, 60, 50),
			}),
		zona("los_baldios", "Los Baldíos", 10, 25, "neutral", "medio", "",
			6000, 3000, []string{"durotar", "mulgore", "pinargenta", "valle_gris"},
			[]DefSpawnZona{
				sp("Raptor", "bestia", 14, 40, -30),
				sp("Jabalí Espinoso", "jabali", 12, -60, 50),
				sp("Centauro", "humanoide", 16, 50, 40),
			}),
		zona("pinargenta", "Bosque de Pinargenta", 10, 20, FaccionHorda, "medio", "",
			6000, 6000, []string{"tirisfal", "los_baldios", "tierras_fantasmales", "laderas_trabalita"},
			[]DefSpawnZona{
				sp("Murloc", "murloc", 12, 40, 30),
				sp("Zombi", "zombi", 14, -50, -40),
				sp("Worg", "lobo", 13, 60, 50),
			}),
		zona("tierras_fantasmales", "Tierras Fantasmales", 10, 20, FaccionHorda, "medio", "",
			9000, 3000, []string{"bosque_eterno", "pinargenta"},
			[]DefSpawnZona{
				sp("Marchito", "humanoide", 16, 40, -30),
				sp("Demonio Menor", "demonio", 18, -60, 50),
				sp("Guardián Caído", "humanoide", 17, 50, 40),
			}),

		// ─── Zonas 20-30 ───
		zona("crepusculo", "Páramos de Crepúsculo", 20, 30, "neutral", "medio", "",
			-9000, -3000, []string{"trabalita_vegas", "loch_modan", "valle_gris"},
			[]DefSpawnZona{
				sp("Araña", "bestia", 24, 40, 30),
				sp("Worg", "lobo", 25, -50, -40),
				sp("Zombi", "zombi", 22, 60, 50),
			}),
		zona("valle_gris", "Valle Gris", 20, 30, "neutral", "medio", "",
			-9000, -6000, []string{"costa_oscura", "los_baldios", "crepusculo", "desolace"},
			[]DefSpawnZona{
				sp("Furbolg", "furbolg", 24, 40, -30),
				sp("Demonio", "demonio", 27, -60, 50),
				sp("Sable", "bestia", 22, 50, 40),
			}),
		zona("laderas_trabalita", "Laderas de Trabalita", 20, 30, "neutral", "medio", "",
			-9000, 3000, []string{"loch_modan", "pinargenta", "tierras_altas_arathi"},
			[]DefSpawnZona{
				sp("Yeti", "bestia", 26, 40, 30),
				sp("Murloc", "murloc", 24, -50, -40),
				sp("Bandido", "humanoide", 28, 60, 50),
			}),

		// ─── Zonas 30-40 ───
		zona("tierras_altas_arathi", "Tierras Altas de Arathi", 30, 40, "neutral", "medio", "",
			-9000, 6000, []string{"laderas_trabalita", "vega_tyris"},
			[]DefSpawnZona{
				sp("Elemental de Tierra", "elemental", 35, 40, -30),
				sp("Oso", "bestia", 33, -60, 50),
				sp("Bandido", "humanoide", 37, 50, 40),
			}),
		zona("vega_tyris", "Vega de Tyris", 30, 45, "neutral", "medio", "",
			-9000, -9000, []string{"tierras_altas_arathi", "desolace", "tanaris"},
			[]DefSpawnZona{
				sp("Tigre", "bestia", 35, 40, 30),
				sp("Raptor", "bestia", 37, -50, -40),
				sp("Cazador", "humanoide", 40, 60, 50),
			}),
		zona("desolace", "Desolace", 30, 40, "neutral", "medio", "",
			6000, -9000, []string{"valle_gris", "vega_tyris", "feralas"},
			[]DefSpawnZona{
				sp("Centauro", "humanoide", 35, 40, -30),
				sp("Demonio", "demonio", 37, -60, 50),
				sp("Basilisco", "bestia", 33, 50, 40),
			}),

		// ─── Zonas 40-50 ───
		zona("tanaris", "Tanaris", 40, 50, "neutral", "medio", "",
			-6000, -9000, []string{"vega_tyris", "feralas", "tierras_plaga_oeste"},
			[]DefSpawnZona{
				sp("Buitre", "bestia", 44, 40, 30),
				sp("Elemental de Tierra", "elemental", 46, -50, -40),
				sp("Nómada", "humanoide", 45, 60, 50),
			}),
		zona("feralas", "Feralas", 40, 50, "neutral", "medio", "",
			9000, -9000, []string{"desolace", "tanaris", "tierras_plaga_oeste"},
			[]DefSpawnZona{
				sp("Oso", "bestia", 44, 40, -30),
				sp("Demonio", "demonio", 46, -60, 50),
				sp("Harpía", "humanoide", 45, 50, 40),
			}),

		// ─── Zonas 50-60 (Tierras de la Peste) ───
		zona("tierras_plaga_oeste", "Tierras de la Peste del Oeste", 50, 60, "neutral", "medio", "",
			-3000, -9000, []string{"tanaris", "feralas", "tierras_plaga_este", "peninsula_fuego_infernal"},
			[]DefSpawnZona{
				sp("Zombi", "zombi", 54, 40, 30),
				sp("Espectro", "zombi", 56, -50, -40),
				sp("Plagado", "humanoide", 55, 60, 50),
			}),
		zona("tierras_plaga_este", "Tierras de la Peste del Este", 53, 60, "neutral", "medio", "",
			-9000, 9000, []string{"tierras_plaga_oeste", "peninsula_fuego_infernal"},
			[]DefSpawnZona{
				sp("Zombi", "zombi", 56, 40, -30),
				sp("Espectro", "zombi", 58, -60, 50),
				sp("Plagado", "humanoide", 57, 50, 40),
			}),

		// ─── Zonas 58-70 (Terrallende / Outland) ───
		zona("peninsula_fuego_infernal", "Península del Fuego Infernal", 58, 70, "neutral", "medio", "",
			-6000, 9000, []string{"tierras_plaga_oeste", "tierras_plaga_este", "nagrand"},
			[]DefSpawnZona{
				sp("Demonio", "demonio", 60, 40, 30),
				sp("Elemental de Fuego", "elemental", 62, -50, -40),
				sp("Orc Vil", "humanoide", 61, 60, 50),
			}),
		zona("nagrand", "Nagrand", 64, 70, "neutral", "medio", "",
			-3000, 9000, []string{"peninsula_fuego_infernal", "tundra_boreal"},
			[]DefSpawnZona{
				sp("Talbuk", "bestia", 66, 40, -30),
				sp("Elemental de Aire", "elemental", 68, -60, 50),
				sp("Ogre", "humanoide", 65, 50, 40),
			}),

		// ─── Zonas 70-80 (Rasganorte / Northrend) ───
		zona("tundra_boreal", "Tundra Boreal", 70, 80, "neutral", "medio", "",
			6000, 9000, []string{"nagrand", "corona_de_hielo"},
			[]DefSpawnZona{
				sp("No-muerto", "zombi", 72, 40, 30),
				sp("Elemental de Hielo", "elemental", 74, -50, -40),
				sp("Nerubiano", "humanoide", 71, 60, 50),
			}),
		zona("corona_de_hielo", "Corona de Hielo", 77, 80, "neutral", "final", "",
			9000, 9000, []string{"tundra_boreal"},
			[]DefSpawnZona{
				sp("Caballero de la Muerte Vil", "humanoide", 78, 40, -30),
				sp("Espectro", "zombi", 80, -60, 50),
				sp("Nerubiano", "humanoide", 79, 50, 40),
			}),
	}
	m := make(map[string]DefZona, len(zs))
	for _, z := range zs {
		m[z.ID] = z
	}
	return m
}

// ciudadesPredefinidas devuelve las 10 capitales raciales (una por raza),
// cada una con un vendedor, un instructor de clase y un instructor de
// profesión (la de bonus racial cuando aplica: Gnomo→Ingeniería,
// Draenei→Joyería, Tauren→Herboristería, Elfo de Sangre→Encantamiento).
func ciudadesPredefinidas() map[string]DefCiudad {
	cs := []DefCiudad{
		// ─── Alianza ───
		{
			ID: "ventormenta", Nombre: "Ventormenta", Faccion: FaccionAlianza,
			RazaID: "humano", ZonaID: "elwynn",
			SpawnPoint: proto.Vec3{X: -3000, Y: 0, Z: -3000},
			NPCs: []DefNPC{
				npcV("ven_ventormenta", "Comerciante Aldwin", -3000, -3000, 3, 0, venderGeneral),
				npcIC("ins_ventormenta_guerrero", "Maestro de Armas Harval", -3000, -3000, -3, 0, "guerrero"),
				npcIP("ins_ventormenta_herreria", "Herrero Argus", -3000, -3000, 0, 4, "herreria"),
			},
		},
		{
			ID: "forjaz", Nombre: "Forjaz", Faccion: FaccionAlianza,
			RazaID: "enano", ZonaID: "dun_morogh",
			SpawnPoint: proto.Vec3{X: -6000, Y: 0, Z: -3000},
			NPCs: []DefNPC{
				npcV("ven_forjaz", "Comerciante Brugar", -6000, -3000, 3, 0, venderGeneral),
				npcIC("ins_forjaz_cazador", "Maestro de Caza Thorgas", -6000, -3000, -3, 0, "cazador"),
				npcIP("ins_forjaz_mineria", "Minero Bell", -6000, -3000, 0, 4, "minería"),
			},
		},
		{
			ID: "darnassus", Nombre: "Darnassus", Faccion: FaccionAlianza,
			RazaID: "elfo_nocturno", ZonaID: "teldrassil",
			SpawnPoint: proto.Vec3{X: -3000, Y: 0, Z: -6000},
			NPCs: []DefNPC{
				npcV("ven_darnassus", "Comerciante Sallien", -3000, -6000, 3, 0, venderGeneral),
				npcIC("ins_darnassus_drida", "Clarisáctur Nessa", -3000, -6000, -3, 0, "druida"),
				npcIP("ins_darnassus_peleteria", "Peletera Cyndanes", -3000, -6000, 0, 4, "peleteria"),
			},
		},
		{
			ID: "nuevo_tinkertown", Nombre: "Nuevo Tinkertown", Faccion: FaccionAlianza,
			RazaID: "gnomo", ZonaID: "dun_morogh",
			SpawnPoint: proto.Vec3{X: -5950, Y: 0, Z: -3000},
			NPCs: []DefNPC{
				npcV("ven_tinkertown", "Comerciante Gnazle", -5950, -3000, 3, 0, venderGeneral),
				npcIC("ins_tinkertown_mago", "Maga Milli", -5950, -3000, -3, 0, "mago"),
				npcIP("ins_tinkertown_ingenieria", "Ingeniera Mekel", -5950, -3000, 0, 4, "ingenieria"),
			},
		},
		{
			ID: "el_exodar", Nombre: "El Exodar", Faccion: FaccionAlianza,
			RazaID: "draenei", ZonaID: "islas_bruma_azure",
			SpawnPoint: proto.Vec3{X: -6000, Y: 0, Z: -6000},
			NPCs: []DefNPC{
				npcV("ven_exodar", "Comerciante Vorel", -6000, -6000, 3, 0, venderGeneral),
				npcIC("ins_exodar_chaman", "Chamán Aandul", -6000, -6000, -3, 0, "chaman"),
				npcIP("ins_exodar_joyeria", "Joyera Erich", -6000, -6000, 0, 4, "joyeria"),
			},
		},
		// ─── Horda ───
		{
			ID: "orgrimmar", Nombre: "Orgrimmar", Faccion: FaccionHorda,
			RazaID: "orco", ZonaID: "durotar",
			SpawnPoint: proto.Vec3{X: 6000, Y: 0, Z: -3000},
			NPCs: []DefNPC{
				npcV("ven_orgrimmar", "Comerciante Gromash", 6000, -3000, 3, 0, venderGeneral),
				npcIC("ins_orgrimmar_guerrero", "Maestro de Armas Sorek", 6000, -3000, -3, 0, "guerrero"),
				npcIP("ins_orgrimmar_desuello", "Desolladora Thuusca", 6000, -3000, 0, 4, "desuello"),
			},
		},
		{
			ID: "aldea_senjin", Nombre: "Aldea Sen'jin", Faccion: FaccionHorda,
			RazaID: "troll", ZonaID: "durotar",
			SpawnPoint: proto.Vec3{X: 6050, Y: 0, Z: -3000},
			NPCs: []DefNPC{
				npcV("ven_senjin", "Comerciante Zanshara", 6050, -3000, 3, 0, venderGeneral),
				npcIC("ins_senjin_cazador", "Maestro de Caza Takur", 6050, -3000, -3, 0, "cazador"),
				npcIP("ins_senjin_cocina", "Cocinera Washia", 6050, -3000, 0, 4, "cocina"),
			},
		},
		{
			ID: "entranas", Nombre: "Entrañas", Faccion: FaccionHorda,
			RazaID: "no_muerto", ZonaID: "tirisfal",
			SpawnPoint: proto.Vec3{X: 6000, Y: 0, Z: -6000},
			NPCs: []DefNPC{
				npcV("ven_entranas", "Comerciante Sheldon", 6000, -6000, 3, 0, venderGeneral),
				npcIC("ins_entranas_brujo", "Bruja Roca", 6000, -6000, -3, 0, "brujo"),
				npcIP("ins_entranas_sastreria", "Sastre Maris", 6000, -6000, 0, 4, "sastreria"),
			},
		},
		{
			ID: "cima_trueno", Nombre: "Cima de Trueno", Faccion: FaccionHorda,
			RazaID: "tauren", ZonaID: "mulgore",
			SpawnPoint: proto.Vec3{X: 9000, Y: 0, Z: -3000},
			NPCs: []DefNPC{
				npcV("ven_cima_trueno", "Comerciante Ahanu", 9000, -3000, 3, 0, venderGeneral),
				npcIC("ins_cima_trueno_chaman", "Chamán Tavak", 9000, -3000, -3, 0, "chaman"),
				npcIP("ins_cima_trueno_herboristeria", "Herborista Brago", 9000, -3000, 0, 4, "herboristeria"),
			},
		},
		{
			ID: "lunargenta", Nombre: "Lunargenta", Faccion: FaccionHorda,
			RazaID: "elfo_de_sangre", ZonaID: "bosque_eterno",
			SpawnPoint: proto.Vec3{X: 9000, Y: 0, Z: -6000},
			NPCs: []DefNPC{
				npcV("ven_lunargenta", "Comerciante Sathis", 9000, -6000, 3, 0, venderGeneral),
				npcIC("ins_lunargenta_paladin", "Paladín Aeldon", 9000, -6000, -3, 0, "paladin"),
				npcIP("ins_lunargenta_encantamiento", "Encantadora Neophra", 9000, -6000, 0, 4, "encantamiento"),
			},
		},
	}
	m := make(map[string]DefCiudad, len(cs))
	for _, c := range cs {
		m[c.ID] = c
	}
	return m
}

// ─── Accesores de Mundo ──────────────────────────────────────────────────

// Zonas devuelve el catálogo completo de zonas.
func (m *Mundo) Zonas() map[string]DefZona {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefZona, len(m.zonas))
	for k, v := range m.zonas {
		out[k] = v
	}
	return out
}

// Zona devuelve la definición de una zona por ID.
func (m *Mundo) Zona(id string) (DefZona, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	z, ok := m.zonas[id]
	return z, ok
}

// Ciudades devuelve las 10 capitales raciales.
func (m *Mundo) Ciudades() map[string]DefCiudad {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]DefCiudad, len(m.ciudades))
	for k, v := range m.ciudades {
		out[k] = v
	}
	return out
}

// Ciudad devuelve una capital por ID.
func (m *Mundo) Ciudad(id string) (DefCiudad, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	c, ok := m.ciudades[id]
	return c, ok
}

// CiudadPorRaza devuelve la capital racial de una raza (una por raza).
func (m *Mundo) CiudadPorRaza(razaID string) (DefCiudad, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	for _, c := range m.ciudades {
		if c.RazaID == razaID {
			return c, true
		}
	}
	return DefCiudad{}, false
}

// SpawnRacial devuelve el punto de aparición de una raza (su capital).
// Fallback a origen si la raza no tiene capital.
func (m *Mundo) SpawnRacial(razaID string) proto.Vec3 {
	if c, ok := m.CiudadPorRaza(razaID); ok {
		return c.SpawnPoint
	}
	return proto.Vec3{}
}

// ZonaEnPos devuelve la zona cuya región contiene la posición dada (a
// ≤RadioRegionZona del centro de región). false si no está en ninguna zona
// (p.ej. está en una masmora/arena, X≥1000 con Z≈0).
func (m *Mundo) ZonaEnPos(pos proto.Vec3) (DefZona, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	for _, z := range m.zonas {
		if distancia2D(pos, z.Region) <= RadioRegionZona {
			return z, true
		}
	}
	return DefZona{}, false
}

// NPCsDeCiudad devuelve los NPCs de una capital.
func (m *Mundo) NPCsDeCiudad(ciudadID string) []DefNPC {
	m.mu.RLock()
	defer m.mu.RUnlock()
	c, ok := m.ciudades[ciudadID]
	if !ok {
		return nil
	}
	out := make([]DefNPC, len(c.NPCs))
	copy(out, c.NPCs)
	return out
}

// NPC busca un NPC por ID en todas las capitales.
func (m *Mundo) NPC(npcID string) (DefNPC, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	for _, c := range m.ciudades {
		for _, n := range c.NPCs {
			if n.ID == npcID {
				return n, true
			}
		}
	}
	return DefNPC{}, false
}

// InteractuarNPC valida que el jugador está a distancia de interacción de un
// NPC y devuelve su definición (catálogo de venta / enseñanza). Requiere
// estar en el mundo abierto (no en instancia).
func (m *Mundo) InteractuarNPC(jugadorID, npcID string) (DefNPC, error) {
	m.mu.RLock()
	j, ok := m.jugadores[jugadorID]
	m.mu.RUnlock()
	if !ok {
		return DefNPC{}, errors.New("jugador no encontrado")
	}
	if j.instanciaID != "" {
		return DefNPC{}, errors.New("no puedes interactuar con NPCs dentro de una instancia")
	}
	npc, ok := m.NPC(npcID)
	if !ok {
		return DefNPC{}, errors.New("NPC no encontrado")
	}
	if distancia2D(j.pos, npc.Pos) > RangoInteraccionNPC {
		return DefNPC{}, errors.New("estás demasiado lejos del NPC")
	}
	return npc, nil
}

// ViajarZona teletransporta al jugador a la zona destino, validando que sea
// adyacente a su zona actual (grafo de conexiones) y que esté en el mundo
// abierto. El jugador aparece en el punto de entrada de la zona destino.
func (m *Mundo) ViajarZona(jugadorID, zonaDestinoID string) error {
	m.mu.RLock()
	j, ok := m.jugadores[jugadorID]
	m.mu.RUnlock()
	if !ok {
		return errors.New("jugador no encontrado")
	}
	if j.instanciaID != "" {
		return errors.New("no puedes viajar estando en una instancia")
	}
	dest, ok := m.Zona(zonaDestinoID)
	if !ok {
		return errors.New("zona destino inválida")
	}
	actual, ok := m.ZonaEnPos(j.pos)
	if !ok {
		return errors.New("no estás en una zona conocida")
	}
	// Validar adyacencia en el grafo.
	adyacente := false
	for _, c := range actual.Conexiones {
		if c == zonaDestinoID {
			adyacente = true
			break
		}
	}
	if !adyacente {
		return errors.New("la zona destino no es adyacente a tu zona actual")
	}
	m.mu.Lock()
	j.pos = dest.PuntoEntrada
	m.mu.Unlock()
	return nil
}
