// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionAlquimia construye la profesión de Alquimia completa (1-450),
// siguiendo la guía de WoW 3.3.5. Consume hierbas (de herboristería) para
// crear pociones, elixires, frascos y transmutaciones. Algunas recetas son
// intermedias: la Poción de curación menor y el Aceite de pigmeo se
// consumen en recetas posteriores. 6 rangos, 30 recetas y 3
// especializaciones (Maestro en pociones, elixires y transmutación) que se
// aprenden a partir de skill 325 (la guía indica nivel 68; en WoW real es
// alquimia 325 + nivel 68; el framework válida skill).
func profesionAlquimia() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz alquimista", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial alquimista", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto alquimista", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Alquimista artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro alquimista", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro alquimista", SkillReq: 350, SkillMax: 450},
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
			ID: id, Nombre: nombre, ProfesionID: "alquimia",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		// Poción de curación menor: producto intermedio (la consume la
		// Poción de curación inferior).
		r("poción_curación_menor", "Poción de curación menor", "poción_curación_menor", 0, 60, mat("flor_de_paz", 1, "hojaplata", 1)),
		r("poción_curación_inferior", "Poción de curación inferior", "poción_curación_inferior", 60, 110, mat("poción_curación_menor", 1, "brezospina", 1)),
		r("poción_curación", "Poción de curación", "poción_curación", 110, 140, mat("brezospina", 1, "hierba_cardenal", 1)),
		r("poción_maná_inferior", "Poción de maná inferior", "poción_maná_inferior", 140, 155, mat("marregal", 1, "alga_estranguladora", 1)),
		r("poción_curación_superior", "Poción de curación superior", "poción_curación_superior", 155, 185, mat("vidarraíz", 1, "sangrerregia", 1)),
		r("elixir_agilidad", "Elixir de agilidad", "elixir_agilidad", 185, 210, mat("alga_estranguladora", 1, "espina_de_oro", 1)),
		r("elixir_defensa_superior", "Elixir de defensa superior", "elixir_defensa_superior", 210, 215, mat("acérita_salvaje", 1, "espina_de_oro", 1)),
		r("poción_curación_excelente", "Poción de curación excelente", "poción_curación_excelente", 215, 230, mat("solea", 1, "mostacho_de_khadgar", 1)),
		r("elixir_detectar_muertos", "Elixir de detención de muertos", "elixir_detectar_muertos", 230, 250, mat("lágrimas_de_arthas", 1)),
		r("elixir_agilidad_superior", "Elixir de agilidad superior", "elixir_agilidad_superior", 250, 265, mat("solea", 1, "espina_de_oro", 1)),
		r("poción_maná_excelente", "Poción de maná excelente", "poción_maná_excelente", 265, 285, mat("solea", 1, "carolina", 1)),
		r("poción_curación_sublime", "Poción de curación sublime", "poción_curación_sublime", 285, 300, mat("sansam_dorado", 1, "salviargenta_de_montaña", 1)),
		// ─── TBC 300-350 ───
		r("poción_sanación_volátil", "Poción de sanación volátil", "poción_sanación_volátil", 300, 315, mat("hierba_vil", 1)),
		r("poción_maná_inestable", "Poción de maná inestable", "poción_maná_inestable", 315, 325, mat("hierba_vil", 1, "velada", 1)),
		r("poción_alquimista_loco", "Poción de alquimista loco", "poción_alquimista_loco", 325, 335, mat("hierba_vil", 1)),
		r("superpoción_sanación", "Superpoción de sanación", "superpoción_sanación", 335, 340, mat("velada", 2)),
		r("superpoción_maná", "Superpoción de maná", "superpoción_maná", 340, 350, mat("gloria_de_ensueño", 2, "flor_abisal", 1)),
		// ─── WotLK 350-450 ───
		r("poción_sanación_resurgente", "Poción de sanación resurgente", "poción_sanación_resurgente", 350, 360, mat("trébol_de_oro", 1)),
		r("poción_maná_helada", "Poción de maná helada", "poción_maná_helada", 360, 365, mat("trébol_de_oro", 2, "lirio_atigrado", 1)),
		r("elixir_poder_hechizos", "Elixir de poder con hechizos", "elixir_poder_hechizos", 365, 375, mat("trébol_de_oro", 2)),
		// Aceite de pigmeo: producto intermedio (lo consume la Investigación).
		r("aceite_pigmeo", "Aceite de pigmeo", "aceite_pigmeo", 375, 380, mat("rémora_pigmea", 1)),
		r("poción_pesadillas", "Poción de pesadillas", "poción_pesadillas", 380, 385, mat("rosa_de_talandra", 2)),
		r("elixir_fuerza_poderosa", "Elixir de fuerza poderosa", "elixir_fuerza_poderosa", 385, 395, mat("lirio_atigrado", 2)),
		r("elixir_agilidad_poderosa", "Elixir de agilidad poderosa", "elixir_agilidad_poderosa", 395, 405, mat("lirio_atigrado", 2, "flor_exánime", 1)),
		// Investigación: insertada en medio de la banda del elixir de
		// agilidad poderosa (craftear 5 → 400, investigación → 401,
		// continuar 4 → 405). Consume el aceite de pigmeo anterior.
		r("investigación_alquimia_norte", "Investigación de alquimia de Rasganorte", "investigación_alquimia_norte", 400, 401, mat("rosa_de_talandra", 1, "aceite_pigmeo", 1)),
		r("poción_indestructible", "Poción indestructible", "poción_indestructible", 405, 415, mat("espina_de_hielo", 2)),
		r("poción_maná_rúnica", "Poción de maná rúnica", "poción_maná_rúnica", 415, 425, mat("trébol_de_oro", 2, "espina_de_hielo", 1)),
		r("transmutar_titanio", "Transmutar: titanio", "titanio", 425, 430, mat("barra_de_saronita", 8)),
		r("transmutar_diamante_llama_celeste", "Transmutar: diamante de llama celeste", "diamante_llama_celeste", 430, 435, mat("aire_eterno", 1, "sangrita", 1, "calcedonia", 1, "barra_de_saronita", 1)),
		r("frasco_ira_infinita", "Frasco de ira infinita", "frasco_ira_infinita", 435, 450, mat("lengua_de_víboris", 2, "flor_exánime", 1)),
		// ─── WotLK: consumibles usables (frascos/elixires/pociones) ───
		// Producen ítems con Uso (ver mundo.itemsPredefinidos) que aplican
		// auras del catálogo (auras.CatalogoAuras) al usarlos. Ordenadas por
		// skill ascendente; los frascos cierran la banda en 450.
		r("pocion_curacion_runica_rec", "Poción de curación rúnica", "pocion_curacion_runica", 350, 400, mat("lirio_atigrado", 2, "espina_de_hielo", 1)),
		r("pocion_mana_runica_rec", "Poción de maná rúnica", "pocion_mana_runica", 365, 415, mat("lirio_atigrado", 2, "espina_de_hielo", 1)),
		r("elixir_agilidad_poderosa_rec", "Elixir de agilidad poderosa", "elixir_agilidad_poderosa", 375, 425, mat("lirio_atigrado", 2, "frasco_mojo", 1)),
		r("elixir_fuerza_poderosa_rec", "Elixir de fuerza poderosa", "elixir_fuerza_poderosa", 380, 430, mat("lirio_atigrado", 2, "frasco_mojo", 1)),
		r("frasco_iracolosal_rec", "Frasco de ira colosal", "frasco_iracolosal", 435, 450, mat("lirio_atigrado", 7, "espina_de_hielo", 3, "frasco_mojo", 1)),
		r("frasco_vidrio_escarcha_rec", "Frasco de vidrio de escarcha", "frasco_vidrio_escarcha", 435, 450, mat("lirio_atigrado", 7, "espina_de_hielo", 3, "frasco_mojo", 1)),
		r("frasco_sangre_piedra_rec", "Frasco de sangre de piedra", "frasco_sangre_piedra", 435, 450, mat("lirio_atigrado", 7, "espina_de_hielo", 3, "frasco_mojo", 1)),
		r("frasco_mojo_puro_rec", "Frasco de mojo puro", "frasco_mojo_puro", 435, 450, mat("flor_abisal", 7, "espina_de_hielo", 3, "frasco_mojo", 1)),
	}
	especializaciones := []DefEspecializacion{
		{
			ID: "pociones", Nombre: "Maestro en pociones", SkillReq: 325,
			Descripcion: "Permite crear a veces una poción extra al preparar pociones de alto nivel.",
			Materiales: mat(
				"superpoción_sanación", 5,
				"superpoción_maná", 5,
				"poción_letargo_sin_sueños_sublime", 5,
				"guía_de_campo_botánicos", 1,
			),
		},
		{
			ID: "elixires", Nombre: "Maestro en elixires", SkillReq: 325,
			Descripcion: "Permite crear a veces un elixir extra al preparar elixires de alto nivel.",
			Materiales: mat(
				"elixir_defensa_sublime", 5,
				"elixir_maestría", 5,
				"elixir_agilidad_sublime", 5,
				"esencia_de_infinidad", 10,
			),
		},
		{
			ID: "transmutación", Nombre: "Maestro de transmutación", SkillReq: 325,
			Descripcion: "Permite obtener resultados superiores a veces al transmutar materiales.",
			Materiales: mat("poderío_primigenio", 4),
		},
	}
	return DefProfesion{
		ID:               "alquimia",
		Nombre:           "Alquimia",
		Primaria:         true,
		MaxSkill:         450,
		Rangos:           rangos,
		Recetas:          recetas,
		Especializaciones: especializaciones,
	}
}
