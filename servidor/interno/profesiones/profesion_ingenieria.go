// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionIngenieria construye la profesión de Ingeniería completa
// (1-450), siguiendo la guía de WoW 3.3.5. Su rasgo distintivo son las
// cadenas de productos intermedios: pólvoras → bombas, tornillos →
// bombas/mosquetes, tubos → mosquetes/gafas/gadgets, envolturas → bombas y
// capacitor → señuelos. Muchos intermedios son a la vez producto y material
// de recetas posteriores (p.ej. el Overcharged Capacitor se consume en el
// Señuelo explosivo). El escalón TBC 300-310 fabrica en masa tres
// intermedios (envoltura, tornillos y pólvora elemental): la envoltura da
// los 10 puntos de skill y los otros dos son recetas "pure-material"
// (SkillReq == SkillHasta, nunca dan skill) que se craftean solo como
// material. 6 rangos, 42 recetas y 2 especializaciones (Goblin / Gnómica).
func profesionIngenieria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz ingeniero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial ingeniero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto ingeniero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Ingeniero artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro ingeniero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro ingeniero", SkillReq: 350, SkillMax: 450},
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
			ID: id, Nombre: nombre, ProfesionID: "ingenieria",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		// Aprendiz 0-75: pólvora y tornillos (intermedios) → tubo → trabuco.
		r("pólvora_basta", "Pólvora basta", "pólvora_basta", 0, 40, mat("piedra_basta", 1)),
		r("tornillos_cobre", "Puñado de tornillos de cobre", "tornillos_cobre", 40, 54, mat("lingote_cobre", 1)),
		r("llave_arcoluz", "Llave inglesa Arcoluz", "llave_arcoluz", 54, 55, mat("lingote_cobre", 6)),
		r("tubo_cobre", "Tubo de cobre", "tubo_cobre", 55, 65, mat("lingote_cobre", 1)),
		r("trabuco_basto", "Trabuco basto", "trabuco_basto", 65, 75, mat("tubo_cobre", 1, "pólvora_basta", 1)),
		// Oficial 75-150: pólvora burda → bombas de bronce.
		r("pólvora_burda", "Pólvora burda", "pólvora_burda", 75, 95, mat("piedra_burda", 1)),
		r("contacto_plata", "Contacto de plata", "contacto_plata", 95, 105, mat("lingote_plata", 1)),
		r("tubo_bronce", "Tubo de bronce", "tubo_bronce", 105, 120, mat("lingote_bronce", 1)),
		r("bomba_bronce_pequeña", "Bomba de bronce pequeña", "bomba_bronce_pequeña", 120, 125, mat("tubo_bronce", 1, "tornillos_cobre", 1, "pólvora_burda", 1, "paño_lana", 1)),
		r("pólvora_pesada", "Pólvora pesada", "pólvora_pesada", 125, 145, mat("piedra_pesada", 1)),
		r("bomba_bronce_grande", "Bomba de bronce grande", "bomba_bronce_grande", 145, 150, mat("tubo_bronce", 1, "pólvora_pesada", 2, "paño_lana", 1)),
		// Experto 150-225: fuego artificial, pólvora sólida → bomba de hierro,
		// tubo de mitril, disparador, balas.
		r("fuego_artificial_rojo", "Fuego artificial rojo", "fuego_artificial_rojo", 150, 175, mat("cuero_pesado", 1, "piedra_sólida", 1)),
		r("microajustador_giromático", "Microajustador giromático", "microajustador_giromático", 175, 176, mat("lingote_acero", 4)),
		r("pólvora_sólida", "Pólvora sólida", "pólvora_sólida", 176, 190, mat("piedra_sólida", 1)),
		r("bomba_hierro_grande", "Bomba de hierro grande", "bomba_hierro_grande", 190, 195, mat("lingote_hierro", 1, "pólvora_sólida", 2, "paño_lana", 1)),
		r("tubo_mitril", "Tubo de mitril", "tubo_mitril", 195, 205, mat("lingote_mitril", 1)),
		r("disparador_inestable", "Disparador inestable", "disparador_inestable", 205, 210, mat("lingote_mitril", 1, "pólvora_sólida", 1, "tela_paño_mágico", 1)),
		r("balas_mitril_gran_impacto", "Balas de mitril de gran impacto", "balas_mitril_gran_impacto", 210, 225, mat("lingote_mitril", 2)),
		// Artesano 225-300: envoltura → bomba de gran carga, pólvora densa →
		// trastos de torio, tubo de torio.
		r("envoltura_mitril", "Envoltura de mitril", "envoltura_mitril", 225, 235, mat("lingote_mitril", 3)),
		r("bomba_gran_carga", "Bomba de gran carga", "bomba_gran_carga", 235, 245, mat("envoltura_mitril", 1, "pólvora_sólida", 1)),
		r("girotiro_mitril", "Girotiro de mitril", "girotiro_mitril", 245, 250, mat("lingote_mitril", 1, "pólvora_sólida", 1)),
		r("pólvora_densa", "Pólvora densa", "pólvora_densa", 250, 260, mat("piedra_densa", 1)),
		r("trastos_wow_torio", "Trastos wow de torio", "trastos_wow_torio", 260, 290, mat("lingote_torio", 1, "pólvora_densa", 1, "paño_rúnico", 1)),
		r("tubo_torio", "Tubo de torio", "tubo_torio", 290, 300, mat("lingote_torio", 2)),
		// ─── TBC 300-350 ───
		// Escalón 300-310: fabricación en masa de tres intermedios. La
		// envoltura da los 10 puntos de skill; los tornillos y la pólvora
		// elemental son recetas "pure-material" (SkillReq == SkillHasta:
		// nunca dan skill, se craftean solo como material para las bombas,
		// el mosquete y la bengala).
		r("envoltura_hierro_vil", "Envoltura de hierro vil", "envoltura_hierro_vil", 300, 310, mat("barra_hierro_vil", 3)),
		r("tornillos_hierro_vil", "Puñado de tornillos de hierro vil", "tornillos_hierro_vil", 300, 300, mat("barra_hierro_vil", 1)),
		r("pólvora_elemental", "Pólvora elemental", "pólvora_elemental", 300, 300, mat("barra_hierro_vil", 1)),
		r("bomba_hierro_vil", "Bomba de hierro vil", "bomba_hierro_vil", 310, 320, mat("envoltura_hierro_vil", 1, "tornillos_hierro_vil", 2, "pólvora_elemental", 1)),
		r("mosquete_hierro_vil", "Mosquete de hierro vil", "mosquete_hierro_vil", 320, 335, mat("envoltura_hierro_vil", 1, "tornillos_hierro_vil", 2, "pólvora_elemental", 1)),
		r("bengala_humo_blanco", "Bengala de humo blanco", "bengala_humo_blanco", 335, 350, mat("tornillos_hierro_vil", 1, "paño_tejido_abisal", 1, "pólvora_elemental", 1)),
		// ─── WotLK 350-450 ───
		// 350-375: prep de tornillos de cobalto y gatillo volátil.
		r("tornillos_cobalto", "Puñado de tornillos de cobalto", "tornillos_cobalto", 350, 360, mat("barra_cobalto", 1)),
		r("gatillo_explosivo_volátil", "Gatillo explosivo volátil", "gatillo_explosivo_volátil", 360, 375, mat("barra_cobalto", 1)),
		// El Capacitor sobrecargado es producto Y material (se consume en el
		// Señuelo explosivo).
		r("capacitor_sobrecargado", "Capacitor sobrecargado", "capacitor_sobrecargado", 375, 385, mat("barra_cobalto", 2, "fuego_cristalizado", 1)),
		r("señuelo_explosivo", "Señuelo explosivo", "señuelo_explosivo", 385, 390, mat("capacitor_sobrecargado", 1, "paño_escarcha", 1)),
		// El Tubo de acero frío es intermedio de scope, soldador, inyector,
		// gafas y máquina de ruido.
		r("tubo_acero_frío", "Tubo de acero frío", "tubo_acero_frío", 390, 400, mat("barra_cobalto", 2)),
		r("mira_refractora_diamante", "Mira refractora de corte diamante", "mira_refractora_diamante", 400, 405, mat("tubo_acero_frío", 1, "barra_de_saronita", 1)),
		r("caja_de_bombas", "Caja de bombas", "caja_de_bombas", 405, 410, mat("gatillo_explosivo_volátil", 1, "barra_de_saronita", 2)),
		r("soldador_rayo_goblin", "Soldador de rayo goblin", "soldador_rayo_goblin", 410, 415, mat("tubo_acero_frío", 1, "barra_de_saronita", 2, "tierra_eterna", 1)),
		r("kit_inyector_mana", "Kit inyector de maná", "kit_inyector_mana", 415, 425, mat("tubo_acero_frío", 1, "agua_cristalizada", 2)),
		r("gafas_nieve_mecanizadas", "Gafas de nieve mecanizadas", "gafas_nieve_mecanizadas", 425, 430, mat("tubo_acero_frío", 1, "barra_de_saronita", 2)),
		r("máquina_ruido", "Máquina de ruido", "máquina_ruido", 430, 435, mat("tubo_acero_frío", 1, "barra_de_saronita", 2, "tierra_cristalizada", 1)),
		r("navaja_ejército_gnómica", "Navaja del ejército gnómico", "navaja_ejército_gnómica", 435, 450, mat("barra_de_saronita", 2, "tornillos_cobalto", 1)),
	}
	especializaciones := []DefEspecializacion{
		// Binaria (sin padre): Goblin o Gnómica, skill 200.
		{
			ID: "goblin", Nombre: "Ingeniería goblin", SkillReq: 200,
			Descripcion: "Maestría en explosivos: bombas potentes, cohetes y petardos.",
			Materiales: mat(
				"bomba_hierro_grande", 20,
				"dinamita_sólida", 20,
				"oveja_explosiva", 5,
			),
		},
		{
			ID: "gnómica", Nombre: "Ingeniería gnómica", SkillReq: 200,
			Descripcion: "Maestría en gadgets: dispositivos, trampas y útiles de cabeza.",
			Materiales: mat(
				"tubo_mitril", 6,
				"mira_precisión", 1,
				"muñeco_diana_avanzado", 2,
			),
		},
	}
	return DefProfesion{
		ID:               "ingenieria",
		Nombre:           "Ingeniería",
		Primaria:         true,
		MaxSkill:         450,
		Rangos:           rangos,
		Recetas:          recetas,
		Especializaciones: especializaciones,
	}
}
