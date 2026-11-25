// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionHerreria construye la profesión de Herrería completa (1-450),
// siguiendo la guía de WoW 3.3.5. Consume lingotes y piedras (de minería)
// para crear piezas de armadura, armas, piedras de afilar/pulir y refuerzos.
// Algunas piedras de pulir son a la vez producto y material de recetas
// posteriores (p.ej. la Piedra de pulir sólida se inserta en mitad de la
// banda de los Brazales de escamas de oro). 6 rangos, 38 recetas y un árbol
// de especializaciones anidado de dos niveles: Forjador de armaduras /
// Forjador de armas (nivel superior, skill 200) y, bajo este último,
// Maestro forjador de hachas / martillos / invocador (skill 225).
func profesionHerreria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz herrero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial herrero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto herrero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Herrero artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro herrero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro herrero", SkillReq: 350, SkillMax: 450},
	}
	mat := func(pares ...interface{}) []MaterialRec {
		out := make([]MaterialRec, 0, len(pares)/2)
		for i := 0; i+1 < len(pares); i += 2 {
			out = append(out, MaterialRec{ItemID: pares[i].(string), Cantidad: pares[i+1].(int)})
		}
		return out
	}
	r := func(id, nombre, resultado string, req, hasta int, mats []MaterialRec) DefReceta {
		return DefReceta{
			ID: id, Nombre: nombre, ProfesionID: "herreria",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		// Piedras de afilar/pulir (algunas son material de recetas posteriores).
		r("piedra_afilar_basta", "Piedra de afilar basta", "piedra_afilar_basta", 0, 25, mat("piedra_basta", 1)),
		r("piedra_pulir_basta", "Piedra de pulir basta", "piedra_pulir_basta", 25, 65, mat("piedra_basta", 1)),
		r("piedra_afilar_burda", "Piedra de afilar burda", "piedra_afilar_burda", 65, 75, mat("piedra_burda", 1)),
		r("piedra_pulir_burda", "Piedra de pulir burda", "piedra_pulir_burda", 75, 100, mat("piedra_burda", 1)),
		// Vara de plata: produce el item vara_plata (compartido con Encantamiento).
		r("vara_plata_herreria", "Vara de plata", "vara_plata", 100, 105, mat("lingote_plata", 1)),
		r("leotardos_bronce_basto", "Leotardos de bronce basto", "leotardos_bronce_basto", 105, 125, mat("lingote_bronce", 6)),
		r("piedra_pulir_pesada", "Piedra de pulir pesada", "piedra_pulir_pesada", 125, 150, mat("piedra_pesada", 3)),
		// Vara de oro: produce el item vara_dorado (compartido con Encantamiento).
		r("vara_oro_herreria", "Vara de oro", "vara_dorado", 150, 155, mat("lingote_oro", 1)),
		r("leotardos_hierro_verde", "Leotardos de hierro verde", "leotardos_hierro_verde", 155, 165, mat("lingote_hierro", 4, "tela_paño_mágico", 1)),
		r("brazales_hierro_verde", "Brazales de hierro verde", "brazales_hierro_verde", 165, 185, mat("lingote_hierro", 2)),
		// Brazales de escamas de oro: banda 185-215 interrumpida por la
		// Piedra de pulir sólida (200-210) en mitad, como en la guía.
		r("brazales_escamas_oro", "Brazales de escamas de oro", "brazales_escamas_oro", 185, 215, mat("lingote_acero", 5)),
		r("piedra_pulir_sólida", "Piedra de pulir sólida", "piedra_pulir_sólida", 200, 210, mat("piedra_sólida", 3)),
		// Yelmo de placas de acero: banda 215-235 que cruza el límite
		// experto→artesano (se aprende artesano a 225 entre medias).
		r("yelmo_placas_acero", "Yelmo de placas de acero", "yelmo_placas_acero", 215, 235, mat("lingote_acero", 8)),
		r("almofar_mitril", "Almófar de mitril", "almofar_mitril", 235, 250, mat("lingote_mitril", 4)),
		r("piedra_afilar_densa", "Piedra de afilar densa", "piedra_afilar_densa", 250, 260, mat("piedra_densa", 1)),
		r("brazales_torio", "Brazales de torio", "brazales_torio", 260, 275, mat("lingote_torio", 4)),
		r("brazales_placas_imperiales", "Brazales de placas imperiales", "brazales_placas_imperiales", 275, 295, mat("lingote_torio", 8)),
		r("botas_torio", "Botas de torio", "botas_torio", 295, 300, mat("lingote_torio", 8)),
		// ─── TBC 300-350 ───
		r("almofar_anillas_hierro_vil", "Almófar de anillas de hierro vil", "almofar_anillas_hierro_vil", 300, 315, mat("barra_hierro_vil", 4)),
		r("guantes_anillas_hierro_vil", "Guantes de anillas de hierro vil", "guantes_anillas_hierro_vil", 315, 320, mat("barra_hierro_vil", 4)),
		r("brazales_anillas_hierro_vil", "Brazales de anillas de hierro vil", "brazales_anillas_hierro_vil", 320, 325, mat("barra_hierro_vil", 4)),
		r("runa_amparo_inferior", "Runa de amparo inferior", "runa_amparo_inferior", 325, 330, mat("barra_hierro_vil", 1)),
		r("coraza_hierro_vil", "Coraza de hierro vil", "coraza_hierro_vil", 330, 340, mat("barra_hierro_vil", 4)),
		r("resguardo_escudo_inferior", "Resguardo de escudo inferior", "resguardo_escudo_inferior", 340, 350, mat("barra_hierro_vil", 2)),
		// ─── WotLK 350-450 ───
		r("botas_cobalto", "Botas de cobalto", "botas_cobalto", 350, 360, mat("barra_cobalto", 2)),
		r("escudo_triangular_cobalto", "Escudo triangular de cobalto", "escudo_triangular_cobalto", 360, 370, mat("barra_cobalto", 3)),
		r("quijotes_cobalto", "Quijotes de cobalto", "quijotes_cobalto", 370, 375, mat("barra_cobalto", 4)),
		r("guantesletes_cobalto", "Guantesletes de cobalto", "guantesletes_cobalto", 375, 380, mat("barra_cobalto", 2)),
		r("botas_cobalto_con_púas", "Botas de cobalto con púas", "botas_cobalto_con_púas", 380, 385, mat("barra_cobalto", 3, "cuero_basto", 1)),
		r("hombreras_cobalto_con_púas", "Hombreras de cobalto con púas", "hombreras_cobalto_con_púas", 385, 390, mat("barra_cobalto", 3, "cuero_basto", 1)),
		r("hacha_guerra_cobalto_dentada", "Hacha de guerra de cobalto dentada", "hacha_guerra_cobalto_dentada", 390, 395, mat("barra_cobalto", 4, "cuero_basto", 1)),
		r("cinturón_saronita_brillante", "Cinturón de saronita brillante", "cinturón_saronita_brillante", 395, 400, mat("barra_de_saronita", 2, "tierra_eterna", 1)),
		r("yelmo_cobalto_cuernudo", "Yelmo de cobalto cuernudo", "yelmo_cobalto_cuernudo", 400, 405, mat("barra_cobalto", 4, "cuero_basto", 1)),
		r("daga_saronita_mortal", "Daga de saronita mortal", "daga_saronita_mortal", 405, 416, mat("barra_de_saronita", 3)),
		r("hebilla_cinturón_eterna", "Hebilla de cinturón eterna", "hebilla_cinturón_eterna", 416, 425, mat("barra_de_saronita", 4, "tierra_eterna", 1, "aire_cristalizado", 1)),
		r("cadena_arma_titanio", "Cadena de arma de titanio", "cadena_arma_titanio", 425, 430, mat("titanio", 2, "sombra_eterna", 1)),
		r("guampolas_imponentes", "Guampolas imponentes", "guampolas_imponentes", 430, 435, mat("barra_de_saronita", 8, "tierra_eterna", 1, "sombra_eterna", 1)),
		r("quijotes_imponentes", "Quijotes imponentes", "quijotes_imponentes", 435, 450, mat("barra_de_saronita", 14, "tierra_eterna", 2, "agua_eterna", 1)),
	}
	especializaciones := []DefEspecializacion{
		// Nivel superior (skill 200): elegir una de las dos ramas.
		{
			ID: "armaduras", Nombre: "Forjador de armaduras", SkillReq: 200,
			Descripcion: "Maestría en armaduras de placas; recetas exclusivas de pecho, piernas y botas.",
			Materiales: mat(
				"yelmo_mitril_ornamentado", 4,
				"botas_mitril_ornamentadas", 2,
				"peto_mitril_ornamentado", 1,
			),
		},
		{
			ID: "armas", Nombre: "Forjador de armas", SkillReq: 200,
			Descripcion: "Maestría en armas; desbloquea tres sub-maestrías (hachas, martillos, invocador).",
			Materiales: mat(
				"sable_acero_lunar", 4,
				"maza_negra_grande", 2,
				"hacha_mitril_pesado", 2,
				"hacha_hierro_macizo", 4,
			),
		},
		// Nivel inferior (skill 225): requieren ser Forjador de armas.
		{
			ID: "hachas", Nombre: "Maestro forjador de hachas", SkillReq: 225,
			Descripcion: "Recetas exclusivas de hachas (p.ej. Filo del Alba).",
			Materiales: mat("piedra_serpiente_voshgajin", 1),
			RequiereEspecializacion: "armas",
		},
		{
			ID: "martillos", Nombre: "Maestro forjador de martillos", SkillReq: 225,
			Descripcion: "Recetas exclusivas de mazas (p.ej. Martillo de batalla encantado).",
			Materiales: mat("delantal_herrero_martillos_carmesi", 1),
			RequiereEspecializacion: "armas",
		},
		{
			ID: "invocador", Nombre: "Maestro invocador", SkillReq: 225,
			Descripcion: "Recetas exclusivas de espadas y estoques (p.ej. Estoque llameante).",
			Materiales: mat("insignia_guarda_negra", 1),
			RequiereEspecializacion: "armas",
		},
	}
	return DefProfesion{
		ID:               "herreria",
		Nombre:           "Herrería",
		Primaria:         true,
		MaxSkill:         450,
		Rangos:           rangos,
		Recetas:          recetas,
		Especializaciones: especializaciones,
	}
}
