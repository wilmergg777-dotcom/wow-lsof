// misiones_catalogo.go define el catálogo de misiones de WoW 3.3.5a y los
// NPCs misioneros (quest givers) que las ofrecen.
//
// Estructura del catálogo (48 misiones):
//   - Banda 1-10: 2 misiones por capital racial (10 capitales × 2 = 20):
//     una de "hablar" (lvl 1, hablar con el vendedor de la capital) y una
//     de "matar" (lvl 2, matar los mobs de la zona inicial).
//   - Bandas 10-20, 20-30, 30-40, 40-50, 50-60, 58-70, 70-80: 4 misiones
//     cada una (3 de matar + 1 de cadena que requiere la primera), dadas
//     por un NPC misionero en una zona representativa de cada banda.
//
// Recompensas: XP escalada (~30% del nivel objetivo vía xpRecompensa), oro
// ~nivelObj·10, y algún item en las misiones iniciales (comida).
package mundo

import (
	"aethelgard/servidor/interno/proto"
)

// ─── Helpers de construcción ─────────────────────────────────────────────

// mis construye una DefMision. nivelObj escala la recompensa de XP.
func mis(id, nombre, desc string, nivelMin int, zonaID, npcInicial, npcEntrega string,
	objetivos []DefObjetivoMision, nivelObj int, oro int, items []string, requiere string) DefMision {
	return DefMision{
		ID:              id,
		Nombre:          nombre,
		Descripcion:     desc,
		NivelMin:        nivelMin,
		ZonaID:          zonaID,
		NPCInicial:      npcInicial,
		NPCEntrega:      npcEntrega,
		Objetivos:       objetivos,
		XPRecompensa:    xpRecompensa(nivelObj),
		OroRecompensa:   oro,
		ItemsRecompensa: items,
		RequiereMision:  requiere,
	}
}

// matar construye un objetivo de matar.
func matar(familia string, cantidad int, desc string) DefObjetivoMision {
	return DefObjetivoMision{Tipo: "matar", MobFamilia: familia, Cantidad: cantidad, Descripcion: desc}
}

// hablar construye un objetivo de hablar con un NPC.
func hablar(npcID, desc string) DefObjetivoMision {
	return DefObjetivoMision{Tipo: "hablar", NPCDestino: npcID, Descripcion: desc}
}

// npcM construye un NPC misionero (quest giver) en posición absoluta.
func npcM(id, nombre string, rx, rz, dx, dz float64, misionIDs []string) DefNPC {
	return DefNPC{
		ID:        id,
		Nombre:    nombre,
		Tipo:      "misionero",
		Misiones:  misionIDs,
		Pos:       proto.Vec3{X: rx + dx, Y: 0, Z: rz + dz},
	}
}

// ─── Catálogo de misiones ────────────────────────────────────────────────

// misionesPredefinidas devuelve las 48 misiones del mundo (1-80).
func misionesPredefinidas() map[string]DefMision {
	ms := []DefMision{
		// ─── Banda 1-10: 2 por capital racial (20 misiones) ───
		// Ventormenta (humano, elwynn)
		mis("m_ventormenta_1", "Saludos al comercio", "Habla con el comerciante Aldwin en Ventormenta.", 1, "elwynn", "mis_ventormenta", "mis_ventormenta",
			[]DefObjetivoMision{hablar("ven_ventormenta", "Habla con el comerciante Aldwin")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_ventormenta_2", "Lobos en Elwynn", "Mata 5 lobos forestales en el Bosque de Elwynn.", 2, "elwynn", "mis_ventormenta", "mis_ventormenta",
			[]DefObjetivoMision{matar("lobo", 5, "Lobos forestales matados")}, 2, 20, nil, ""),
		// Forjaz (enano, dun_morogh)
		mis("m_forjaz_1", "Reunión con el herrero", "Habla con el herrero Argus en Forjaz.", 1, "dun_morogh", "mis_forjaz", "mis_forjaz",
			[]DefObjetivoMision{hablar("ins_forjaz_mineria", "Habla con el minero Bell")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_forjaz_2", "Troggs en Dun Morogh", "Mata 5 troggs en Dun Morogh.", 2, "dun_morogh", "mis_forjaz", "mis_forjaz",
			[]DefObjetivoMision{matar("trogg", 5, "Troggs matados")}, 2, 20, nil, ""),
		// Darnassus (elfo_nocturno, teldrassil)
		mis("m_darnassus_1", "La sabiduría de la druida", "Habla con Clarisáctur Nessa en Darnassus.", 1, "teldrassil", "mis_darnassus", "mis_darnassus",
			[]DefObjetivoMision{hablar("ven_darnassus", "Habla con la comerciante Sallien")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_darnassus_2", "Furbolgs de Teldrassil", "Mata 4 furbolgs en Teldrassil.", 2, "teldrassil", "mis_darnassus", "mis_darnassus",
			[]DefObjetivoMision{matar("furbolg", 4, "Furbolgs matados")}, 2, 20, nil, ""),
		// Nuevo Tinkertown (gnomo, dun_morogh)
		mis("m_tinkertown_1", "El comerciente gnomo", "Habla con el comerciante Gnazle en Nuevo Tinkertown.", 1, "dun_morogh", "mis_tinkertown", "mis_tinkertown",
			[]DefObjetivoMision{hablar("ven_tinkertown", "Habla con el comerciante Gnazle")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_tinkertown_2", "Jabalíes de Dun Morogh", "Mata 5 jabalíes de nieve en Dun Morogh.", 2, "dun_morogh", "mis_tinkertown", "mis_tinkertown",
			[]DefObjetivoMision{matar("jabali", 5, "Jabalíes de nieve matados")}, 2, 20, nil, ""),
		// El Exodar (draenei, islas_bruma_azure)
		mis("m_exodar_1", "La luz del Exodar", "Habla con el chamán Aandul en El Exodar.", 1, "islas_bruma_azure", "mis_exodar", "mis_exodar",
			[]DefObjetivoMision{hablar("ven_exodar", "Habla con el comerciante Vorel")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_exodar_2", "Elementales de fuego", "Mata 3 elementales de fuego en la Isla Bruma Azure.", 2, "islas_bruma_azure", "mis_exodar", "mis_exodar",
			[]DefObjetivoMision{matar("elemental", 3, "Elementales de fuego matados")}, 2, 20, nil, ""),
		// Orgrimmar (orco, durotar)
		mis("m_orgrimmar_1", "Fuerzas de Orgrimmar", "Habla con el maestro de armas Sorek en Orgrimmar.", 1, "durotar", "mis_orgrimmar", "mis_orgrimmar",
			[]DefObjetivoMision{hablar("ven_orgrimmar", "Habla con el comerciante Gromash")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_orgrimmar_2", "Jabalíes espinosos", "Mata 5 jabalíes espinosos en Durotar.", 2, "durotar", "mis_orgrimmar", "mis_orgrimmar",
			[]DefObjetivoMision{matar("jabali", 5, "Jabalíes espinosos matados")}, 2, 20, nil, ""),
		// Aldea Sen'jin (troll, durotar)
		mis("m_senjin_1", "Voces de Sen'jin", "Habla con el maestro de caza Takar en la Aldea Sen'jin.", 1, "durotar", "mis_senjin", "mis_senjin",
			[]DefObjetivoMision{hablar("ven_senjin", "Habla con el comerciante Zanshara")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_senjin_2", "Saurok de Durotar", "Mata 4 sauroks en Durotar.", 2, "durotar", "mis_senjin", "mis_senjin",
			[]DefObjetivoMision{matar("humanoide", 4, "Sauroks matados")}, 2, 20, nil, ""),
		// Entrañas (no_muerto, tirisfal)
		mis("m_entranas_1", "Susurros en Entrañas", "Habla con la bruja Roca en Entrañas.", 1, "tirisfal", "mis_entranas", "mis_entranas",
			[]DefObjetivoMision{hablar("ven_entranas", "Habla con el comerciante Sheldon")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_entranas_2", "Zombis de Tirisfal", "Mata 5 zombis en el Claro de Tirisfal.", 2, "tirisfal", "mis_entranas", "mis_entranas",
			[]DefObjetivoMision{matar("zombi", 5, "Zombis matados")}, 2, 20, nil, ""),
		// Cima de Trueno (tauren, mulgore)
		mis("m_cima_trueno_1", "Espíritu de Cima de Trueno", "Habla con el chamán Tavak en Cima de Trueno.", 1, "mulgore", "mis_cima_trueno", "mis_cima_trueno",
			[]DefObjetivoMision{hablar("ven_cima_trueno", "Habla con el comerciante Ahanu")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_cima_trueno_2", "Lobos de pradera", "Mata 5 lobos de pradera en Mulgore.", 2, "mulgore", "mis_cima_trueno", "mis_cima_trueno",
			[]DefObjetivoMision{matar("lobo", 5, "Lobos de pradera matados")}, 2, 20, nil, ""),
		// Lunargenta (elfo_de_sangre, bosque_eterno)
		mis("m_lunargenta_1", "El paladín de Lunargenta", "Habla con el paladín Aeldon en Lunargenta.", 1, "bosque_eterno", "mis_lunargenta", "mis_lunargenta",
			[]DefObjetivoMision{hablar("ven_lunargenta", "Habla con el comerciante Sathis")}, 1, 10, []string{"ciruela_blanca_sabrosa"}, ""),
		mis("m_lunargenta_2", "Marchitos del Bosque Canción", "Mata 5 marchitos en el Bosque Canción Eterna.", 2, "bosque_eterno", "mis_lunargenta", "mis_lunargenta",
			[]DefObjetivoMision{matar("humanoide", 5, "Marchitos matados")}, 2, 20, nil, ""),

		// ─── Banda 10-20 (trabalita_vegas) ───
		mis("m_trab_1", "Bandidos Defias", "Mata 6 Defias en las Vegas de Trabalita.", 10, "trabalita_vegas", "mis_trabalita_vegas", "mis_trabalita_vegas",
			[]DefObjetivoMision{matar("humanoide", 6, "Defias matados")}, 11, 110, nil, ""),
		mis("m_trab_2", "Murlocs de la costa", "Mata 6 murlocs en las Vegas de Trabalita.", 12, "trabalita_vegas", "mis_trabalita_vegas", "mis_trabalita_vegas",
			[]DefObjetivoMision{matar("murloc", 6, "Murlocs matados")}, 13, 130, nil, ""),
		mis("m_trab_3", "Plaga de jabalíes", "Mata 8 jabalíes en las Vegas de Trabalita.", 14, "trabalita_vegas", "mis_trabalita_vegas", "mis_trabalita_vegas",
			[]DefObjetivoMision{matar("jabali", 8, "Jabalíes matados")}, 15, 150, nil, ""),
		mis("m_trab_4", "Limpiar los campos", "Mata 10 Defias para limpiar las Vegas de Trabalita.", 17, "trabalita_vegas", "mis_trabalita_vegas", "mis_trabalita_vegas",
			[]DefObjetivoMision{matar("humanoide", 10, "Defias matados")}, 18, 180, nil, "m_trab_1"),

		// ─── Banda 20-30 (crepusculo) ───
		mis("m_crep_1", "Arañas del Crepúsculo", "Mata 6 arañas en los Páramos de Crepúsculo.", 20, "crepusculo", "mis_crepusculo", "mis_crepusculo",
			[]DefObjetivoMision{matar("bestia", 6, "Arañas matadas")}, 21, 210, nil, ""),
		mis("m_crep_2", "Worgs nocturnos", "Mata 6 worgs en los Páramos de Crepúsculo.", 22, "crepusculo", "mis_crepusculo", "mis_crepusculo",
			[]DefObjetivoMision{matar("lobo", 6, "Worgs matados")}, 23, 230, nil, ""),
		mis("m_crep_3", "Zombis errantes", "Mata 8 zombis en los Páramos de Crepúsculo.", 24, "crepusculo", "mis_crepusculo", "mis_crepusculo",
			[]DefObjetivoMision{matar("zombi", 8, "Zombis matados")}, 25, 250, nil, ""),
		mis("m_crep_4", "El nido de arañas", "Mata 10 arañas para despejar el nido.", 27, "crepusculo", "mis_crepusculo", "mis_crepusculo",
			[]DefObjetivoMision{matar("bestia", 10, "Arañas matadas")}, 28, 280, nil, "m_crep_1"),

		// ─── Banda 30-40 (vega_tyris) ───
		mis("m_vega_1", "Tigres de la Vega", "Mata 6 tigres en la Vega de Tyris.", 30, "vega_tyris", "mis_vega_tyris", "mis_vega_tyris",
			[]DefObjetivoMision{matar("bestia", 6, "Tigres matados")}, 31, 310, nil, ""),
		mis("m_vega_2", "Cazadores enemigos", "Mata 6 cazadores en la Vega de Tyris.", 32, "vega_tyris", "mis_vega_tyris", "mis_vega_tyris",
			[]DefObjetivoMision{matar("humanoide", 6, "Cazadores matados")}, 33, 330, nil, ""),
		mis("m_vega_3", "Raptores salvajes", "Mata 8 raptores en la Vega de Tyris.", 34, "vega_tyris", "mis_vega_tyris", "mis_vega_tyris",
			[]DefObjetivoMision{matar("bestia", 8, "Raptores matados")}, 35, 350, nil, ""),
		mis("m_vega_4", "La cacería mayor", "Mata 10 cazadores para asegurar la Vega.", 37, "vega_tyris", "mis_vega_tyris", "mis_vega_tyris",
			[]DefObjetivoMision{matar("humanoide", 10, "Cazadores matados")}, 38, 380, nil, "m_vega_1"),

		// ─── Banda 40-50 (tanaris) ───
		mis("m_tan_1", "Buitres de Tanaris", "Mata 6 buitres en Tanaris.", 40, "tanaris", "mis_tanaris", "mis_tanaris",
			[]DefObjetivoMision{matar("bestia", 6, "Buitres matados")}, 41, 410, nil, ""),
		mis("m_tan_2", "Elementales de tierra", "Mata 6 elementales de tierra en Tanaris.", 42, "tanaris", "mis_tanaris", "mis_tanaris",
			[]DefObjetivoMision{matar("elemental", 6, "Elementales matados")}, 43, 430, nil, ""),
		mis("m_tan_3", "Nómadas del desierto", "Mata 8 nómadas en Tanaris.", 44, "tanaris", "mis_tanaris", "mis_tanaris",
			[]DefObjetivoMision{matar("humanoide", 8, "Nómadas matados")}, 45, 450, nil, ""),
		mis("m_tan_4", "Rituales elementales", "Mata 10 elementales para frenar los rituales.", 47, "tanaris", "mis_tanaris", "mis_tanaris",
			[]DefObjetivoMision{matar("elemental", 10, "Elementales matados")}, 48, 480, nil, "m_tan_1"),

		// ─── Banda 50-60 (tierras_plaga_oeste) ───
		mis("m_plaga_1", "Zombis de la Peste", "Mata 6 zombis en las Tierras de la Peste del Oeste.", 50, "tierras_plaga_oeste", "mis_tierras_plaga_oeste", "mis_tierras_plaga_oeste",
			[]DefObjetivoMision{matar("zombi", 6, "Zombis matados")}, 51, 510, nil, ""),
		mis("m_plaga_2", "Plagados", "Mata 6 plagados en las Tierras de la Peste.", 52, "tierras_plaga_oeste", "mis_tierras_plaga_oeste", "mis_tierras_plaga_oeste",
			[]DefObjetivoMision{matar("humanoide", 6, "Plagados matados")}, 53, 530, nil, ""),
		mis("m_plaga_3", "Espectros", "Mata 8 espectros en las Tierras de la Peste.", 54, "tierras_plaga_oeste", "mis_tierras_plaga_oeste", "mis_tierras_plaga_oeste",
			[]DefObjetivoMision{matar("zombi", 8, "Espectros matados")}, 55, 550, nil, ""),
		mis("m_plaga_4", "Purificar la Peste", "Mata 10 plagados para purgar la Peste.", 57, "tierras_plaga_oeste", "mis_tierras_plaga_oeste", "mis_tierras_plaga_oeste",
			[]DefObjetivoMision{matar("humanoide", 10, "Plagados matados")}, 58, 580, nil, "m_plaga_1"),

		// ─── Banda 58-70 Terrallende (peninsula_fuego_infernal) ───
		mis("m_fuego_1", "Demonios del Fuego Infernal", "Mata 6 demonios en la Península del Fuego Infernal.", 59, "peninsula_fuego_infernal", "mis_peninsula_fuego_infernal", "mis_peninsula_fuego_infernal",
			[]DefObjetivoMision{matar("demonio", 6, "Demonios matados")}, 60, 600, nil, ""),
		mis("m_fuego_2", "Elementales de fuego", "Mata 6 elementales de fuego en Terrallende.", 62, "peninsula_fuego_infernal", "mis_peninsula_fuego_infernal", "mis_peninsula_fuego_infernal",
			[]DefObjetivoMision{matar("elemental", 6, "Elementales matados")}, 63, 630, nil, ""),
		mis("m_fuego_3", "Orcs viles", "Mata 8 orcs viles en la Península.", 64, "peninsula_fuego_infernal", "mis_peninsula_fuego_infernal", "mis_peninsula_fuego_infernal",
			[]DefObjetivoMision{matar("humanoide", 8, "Orcs viles matados")}, 65, 650, nil, ""),
		mis("m_fuego_4", "Asalto a la Legión", "Mata 10 demonios para romper la Legión.", 67, "peninsula_fuego_infernal", "mis_peninsula_fuego_infernal", "mis_peninsula_fuego_infernal",
			[]DefObjetivoMision{matar("demonio", 10, "Demonios matados")}, 68, 680, nil, "m_fuego_1"),

		// ─── Banda 70-80 Rasganorte (tundra_boreal) ───
		mis("m_tundra_1", "No-muertos de Rasganorte", "Mata 6 no-muertos en la Tundra Boreal.", 70, "tundra_boreal", "mis_tundra_boreal", "mis_tundra_boreal",
			[]DefObjetivoMision{matar("zombi", 6, "No-muertos matados")}, 71, 710, nil, ""),
		mis("m_tundra_2", "Elementales de hielo", "Mata 6 elementales de hielo en Rasganorte.", 72, "tundra_boreal", "mis_tundra_boreal", "mis_tundra_boreal",
			[]DefObjetivoMision{matar("elemental", 6, "Elementales matados")}, 73, 730, nil, ""),
		mis("m_tundra_3", "Nerubianos", "Mata 8 nerubianos en la Tundra Boreal.", 74, "tundra_boreal", "mis_tundra_boreal", "mis_tundra_boreal",
			[]DefObjetivoMision{matar("humanoide", 8, "Nerubianos matados")}, 75, 750, nil, ""),
		mis("m_tundra_4", "El corazón del invierno", "Mata 10 elementales para romper el invierno.", 77, "tundra_boreal", "mis_tundra_boreal", "mis_tundra_boreal",
			[]DefObjetivoMision{matar("elemental", 10, "Elementales matados")}, 78, 780, nil, "m_tundra_1"),
	}
	mm := make(map[string]DefMision, len(ms))
	for _, m := range ms {
		mm[m.ID] = m
	}
	return mm
}

// ─── NPCs misioneros (quest givers) ──────────────────────────────────────

// npcsMisioneroCapital devuelve el NPC misionero de una capital racial.
// Posición: spawnpoint de la capital + offset (0,-4) (dentro del rango de
// interacción de 5m del punto de aparición racial).
func npcsMisioneroCapital(capitalID string) []DefNPC {
	tabla := map[string]struct {
		nombre     string
		misID      string
		rx, rz     float64
		misionIDs  []string
	}{
		"ventormenta":      {"Guardia Paulson", "mis_ventormenta", -3000, -3000, []string{"m_ventormenta_1", "m_ventormenta_2"}},
		"forjaz":           {"Capitán Tharras", "mis_forjaz", -6000, -3000, []string{"m_forjaz_1", "m_forjaz_2"}},
		"darnassus":        {"Centinela Alynna", "mis_darnassus", -3000, -6000, []string{"m_darnassus_1", "m_darnassus_2"}},
		"nuevo_tinkertown": {"Técrico Razzie", "mis_tinkertown", -5950, -3000, []string{"m_tinkertown_1", "m_tinkertown_2"}},
		"el_exodar":        {"Vindicador Aesom", "mis_exodar", -6000, -6000, []string{"m_exodar_1", "m_exodar_2"}},
		"orgrimmar":        {"Guardia Grommash", "mis_orgrimmar", 6000, -3000, []string{"m_orgrimmar_1", "m_orgrimmar_2"}},
		"aldea_senjin":     {"Líder Vol'jin", "mis_senjin", 6050, -3000, []string{"m_senjin_1", "m_senjin_2"}},
		"entranas":         {"Guardia de la Muerte", "mis_entranas", 6000, -6000, []string{"m_entranas_1", "m_entranas_2"}},
		"cima_trueno":      {"Guardián Baine", "mis_cima_trueno", 9000, -3000, []string{"m_cima_trueno_1", "m_cima_trueno_2"}},
		"lunargenta":       {"Guardián Loralen", "mis_lunargenta", 9000, -6000, []string{"m_lunargenta_1", "m_lunargenta_2"}},
	}
	d, ok := tabla[capitalID]
	if !ok {
		return nil
	}
	return []DefNPC{npcM(d.misID, d.nombre, d.rx, d.rz, 0, -4, d.misionIDs)}
}

// npcsMisioneroZona devuelve el NPC misionero de una zona representativa de
// banda. Posición: centro de región de la zona.
func npcsMisioneroZona(zonaID string) []DefNPC {
	tabla := map[string]struct {
		nombre     string
		rx, rz     float64
		misionIDs  []string
	}{
		"trabalita_vegas":            {"Comandante Althea", -3000, 3000, []string{"m_trab_1", "m_trab_2", "m_trab_3", "m_trab_4"}},
		"crepusculo":                 {"Alguacil Bligh", -9000, -3000, []string{"m_crep_1", "m_crep_2", "m_crep_3", "m_crep_4"}},
		"vega_tyris":                 {"Cazarrecompensas Krazek", -9000, -9000, []string{"m_vega_1", "m_vega_2", "m_vega_3", "m_vega_4"}},
		"tanaris":                    {"Mariscal Piraña", -6000, -9000, []string{"m_tan_1", "m_tan_2", "m_tan_3", "m_tan_4"}},
		"tierras_plaga_oeste":        {"Comandante Valorfist", -3000, -9000, []string{"m_plaga_1", "m_plaga_2", "m_plaga_3", "m_plaga_4"}},
		"peninsula_fuego_infernal":   {"Machacador de la Horda", -6000, 9000, []string{"m_fuego_1", "m_fuego_2", "m_fuego_3", "m_fuego_4"}},
		"tundra_boreal":              {"Embajador Valiente", 6000, 9000, []string{"m_tundra_1", "m_tundra_2", "m_tundra_3", "m_tundra_4"}},
	}
	d, ok := tabla[zonaID]
	if !ok {
		return nil
	}
	return []DefNPC{npcM("mis_"+zonaID, d.nombre, d.rx, d.rz, 0, 0, d.misionIDs)}
}
