// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionSastreria construye la profesión de Sastrería completa (1-450),
// siguiendo la guía de WoW 3.3.5: 6 rangos, 36 recetas (Classic 1-300,
// TBC 300-350, WotLK 350-450) y 3 especializaciones (tela lunar, fuego de
// hechizo, tejido de sombra) que se aprenden a partir de 350 consumiendo
// los materiales de la misión de la guía.
func profesionSastreria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz sastre", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial sastre", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto sastre", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Artesano sastre", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro sastre", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro sastre", SkillReq: 350, SkillMax: 450},
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
			ID: id, Nombre: nombre, ProfesionID: "sastreria",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		// Descargas/madejas son recetas intermedias: producen el material
		// que consumen las recetas posteriores.
		r("descarga_paño_lino", "Descarga de paño de lino", "descarga_paño_lino", 0, 45, mat("paño_lino", 2)),
		r("camisa_lino_roja", "Camisa de lino roja", "camisa_lino_roja", 45, 65, mat("descarga_paño_lino", 1)),
		r("manteo_lino_reforzado", "Manteo de lino reforzado", "manteo_lino_reforzado", 65, 75, mat("descarga_paño_lino", 2)),
		r("descarga_paño_lana", "Descarga de paño de lana", "descarga_paño_lana", 75, 105, mat("paño_lana", 3)),
		r("camisa_lana_gris", "Camisa de lana gris", "camisa_lana_gris", 105, 110, mat("descarga_paño_lana", 1)),
		r("hombreras_lana_doble_pespunte", "Hombreras de lana con doble pespunte", "hombreras_lana_doble_pespunte", 110, 125, mat("descarga_paño_lana", 3)),
		r("descarga_paño_seda", "Descarga de paño de seda", "descarga_paño_seda", 125, 145, mat("paño_seda", 4)),
		r("caperuza_seda_azur", "Caperuza de seda azur", "caperuza_seda_azur", 145, 160, mat("descarga_paño_seda", 2)),
		r("cinta_seda", "Cinta de seda", "cinta_seda", 160, 170, mat("descarga_paño_seda", 3)),
		r("camisa_blanca_formal", "Camisa blanca formal", "camisa_blanca_formal", 170, 175, mat("descarga_paño_seda", 1)),
		r("descarga_paño_mágico", "Descarga de paño mágico", "descarga_paño_mágico", 175, 185, mat("paño_mágico", 3)),
		r("jubon_seda_carmesi", "Jubón de seda carmesí", "jubon_seda_carmesi", 185, 205, mat("descarga_paño_seda", 4)),
		r("pantalones_bombacho_seda_carmesi", "Pantalones bombacho de seda carmesí", "pantalones_bombacho_seda_carmesi", 205, 215, mat("descarga_paño_seda", 4)),
		r("leotardos_paño_mágico_negro", "Leotardos de paño mágico negro", "leotardos_paño_mágico_negro", 215, 220, mat("descarga_paño_mágico", 2, "cuero_basto", 1)),
		r("guantes_paño_mágico_negro", "Guantes de paño mágico negro", "guantes_paño_mágico_negro", 220, 230, mat("descarga_paño_mágico", 2, "cuero_basto", 1)),
		r("cinta_negra_paño_mágico", "Cinta negra paño mágico", "cinta_negra_paño_mágico", 230, 250, mat("descarga_paño_mágico", 2, "cuero_basto", 1)),
		r("descarga_paño_rúnico", "Descarga de paño rúnico", "descarga_paño_rúnico", 250, 260, mat("paño_rúnico", 4)),
		r("cinturon_paño_rúnico", "Cinturón de paño rúnico", "cinturon_paño_rúnico", 260, 275, mat("descarga_paño_rúnico", 3)),
		r("guantes_paño_rúnico", "Guantes de paño rúnico", "guantes_paño_rúnico", 275, 300, mat("descarga_paño_rúnico", 3, "cuero_basto", 1)),
		r("bolsa_paño_rúnico", "Bolsa de paño rúnico", "bolsa_paño_rúnico", 275, 300, mat("descarga_paño_rúnico", 4, "cuero_basto", 1)),
		// ─── TBC 300-350 ───
		r("madeja_tejido_abisal", "Madeja de tejido abisal", "madeja_tejido_abisal", 300, 325, mat("paño_tejido_abisal", 5)),
		r("madeja_tejido_abisal_imbuido", "Madeja de tejido abisal imbuido", "madeja_tejido_abisal_imbuido", 325, 340, mat("madeja_tejido_abisal", 3, "polvo_arcano", 2)),
		r("toga_tejido_abisal", "Toga de tejido abisal", "toga_tejido_abisal", 340, 350, mat("madeja_tejido_abisal", 8)),
		// ─── WotLK 350-450 ───
		r("madeja_escarcha", "Madeja de tejido de Escarcha", "madeja_escarcha", 350, 375, mat("tela_escarcha", 5)),
		r("cinturon_tejido_escarcha", "Cinturón tejido con Escarcha", "cinturon_tejido_escarcha", 375, 380, mat("madeja_escarcha", 4)),
		r("botas_tejidas_escarcha", "Botas tejidas con Escarcha", "botas_tejidas_escarcha", 380, 385, mat("madeja_escarcha", 5)),
		r("capucha_tejida_escarcha", "Capucha tejida con Escarcha", "capucha_tejida_escarcha", 385, 395, mat("madeja_escarcha", 5)),
		r("cinturon_tejido_alba", "Cinturón de tejido del alba", "cinturon_tejido_alba", 395, 400, mat("madeja_escarcha", 5)),
		r("madeja_escarcha_imbuido", "Madeja de tejido de Escarcha imbuido", "madeja_escarcha_imbuido", 400, 405, mat("madeja_escarcha", 2, "polvo_infinito", 1)),
		r("cubremuñecas_tejido_alba", "Cubremuñecas de tejido del alba", "cubremuñecas_tejido_alba", 405, 410, mat("madeja_escarcha_imbuido", 5)),
		r("guantes_tejido_alba", "Guantes de tejido del alba", "guantes_tejido_alba", 410, 415, mat("madeja_escarcha_imbuido", 5)),
		r("botas_tejido_alba", "Botas de tejido del alba", "botas_tejido_alba", 415, 425, mat("madeja_escarcha_imbuido", 5)),
		r("bolsa_tejido_escarcha", "Bolsa de tejido de Escarcha", "bolsa_tejido_escarcha", 425, 440, mat("madeja_escarcha_imbuido", 4)),
		// Recta final 440-450: recetas épicas (alternativas).
		r("toga_tejido_hechizos", "Toga de tejido de hechizos", "toga_tejido_hechizos", 440, 450, mat("madeja_escarcha_imbuido", 8, "orbe_congelado", 1)),
		r("guantes_velo_lunar", "Guantes de velo lunar", "guantes_velo_lunar", 440, 450, mat("madeja_escarcha_imbuido", 6, "orbe_congelado", 1)),
		r("guantes_tejido_ebano", "Guantes de tejido de ébano", "guantes_tejido_ebano", 440, 450, mat("madeja_escarcha_imbuido", 6, "orbe_congelado", 1)),
	}
	// Especializaciones (se aprenden a partir de 350, consumiendo los
	// materiales de la misión de la guía). Solo se puede elegir una.
	especializaciones := []DefEspecializacion{
		{
			ID: "tela_lunar", Nombre: "Sastrería con tela lunar", SkillReq: 350,
			Descripcion: "Recetas únicas de tela lunar; crea tela lunar primigenia adicional en una Poza de la Luna.",
			Materiales:  mat("tela_lunar_primigenia", 1),
		},
		{
			ID: "fuego_hechizo", Nombre: "Sastrería con fuego de hechizo", SkillReq: 350,
			Descripcion: "Recetas únicas de fuego de hechizo; crea paño de hechizos adicional en Tormenta Abisal.",
			Materiales:  mat("esencia_anima_abisal", 1),
		},
		{
			ID: "tejido_sombra", Nombre: "Sastrería con tejido de sombra", SkillReq: 350,
			Descripcion: "Recetas únicas de tejido de sombra; crea paño de las Sombras adicional en el Altar de las Sombras.",
			Materiales:  mat("cristal_sombras_profundas", 1),
		},
	}
	return DefProfesion{
		ID:               "sastreria",
		Nombre:           "Sastrería",
		Primaria:         true,
		MaxSkill:         450,
		Rangos:           rangos,
		Recetas:          recetas,
		Especializaciones: especializaciones,
	}
}
