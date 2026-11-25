// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionEncantamiento construye la profesión de Encantamiento completa
// (1-450), siguiendo la guía de WoW 3.3.5. No tiene especializaciones.
// Produce encantamientos (aplicables a ranuras de equipo), aceites de
// zahorí y varas rúnicas encadenadas (cada vara consume la anterior).
// 6 rangos y 43 recetas (Classic 1-300, TBC 300-350, WotLK 350-450).
func profesionEncantamiento() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz encantador", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial encantador", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto encantador", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Encantador artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro encantador", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro encantador", SkillReq: 350, SkillMax: 450},
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
			ID: id, Nombre: nombre, ProfesionID: "encantamiento",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Varas rúnicas (cadena: cada una consume la anterior) ───
		r("vara_cobre_rúnico", "Vara de cobre rúnico", "vara_cobre_rúnico", 0, 2,
			mat("vara_cobre", 1, "esencia_mágica_inferior", 1)),
		r("vara_rúnica_plateada", "Vara rúnica plateada", "vara_rúnica_plateada", 100, 101,
			mat("vara_plata", 1, "vara_cobre_rúnico", 1, "esencia_astral_inferior", 2)),
		r("vara_rúnica_dorada", "Vara rúnica dorada", "vara_rúnica_dorada", 150, 151,
			mat("vara_dorado", 1, "vara_rúnica_plateada", 1, "esencia_mística_inferior", 2, "perla_iridiscente", 1)),
		r("vara_veraplata_runas", "Vara de veraplata con runas", "vara_veraplata_runas", 200, 201,
			mat("vara_veraplata", 1, "vara_rúnica_dorada", 1, "esencia_mística_superior", 1, "gema_sombras", 1)),
		r("vara_arcanita_rúnica", "Vara de arcanita rúnica", "vara_arcanita_rúnica", 290, 291,
			mat("vara_arcanita", 1, "vara_veraplata_runas", 1, "esencia_eterna_superior", 2, "perla_oro", 1)),
		r("vara_hierro_vil_rúnica", "Vara rúnica de hierro vil", "vara_hierro_vil_rúnica", 300, 301,
			mat("vara_hierro_vil", 1, "vara_arcanita_rúnica", 1, "esencia_bidimensional_superior", 4)),
		r("vara_adamantita_rúnica", "Vara rúnica de adamantita", "vara_adamantita_rúnica", 350, 351,
			mat("vara_adamantita", 1, "vara_hierro_vil_rúnica", 1, "esencia_bidimensional_superior", 4, "fragmento_centelleante_grande", 1, "poderío_primigenio", 1)),
		r("vara_eternio_rúnica", "Vara rúnica de eternio", "vara_eternio_rúnica", 375, 376,
			mat("vara_eternio", 1, "vara_adamantita_rúnica", 1, "esencia_bidimensional_superior", 6, "fragmento_centelleante_grande", 6)),
		r("vara_titanio_rúnica", "Vara rúnica de titanio", "vara_titanio_rúnica", 425, 426,
			mat("vara_titanio", 1, "vara_eternio_rúnica", 1, "esencia_cósmica_superior", 12, "fragmento_onírico", 4, "tierra_eterna", 2)),
		// ─── Encantamientos Classic 1-300 ───
		r("encanto_brazal_salud_menor", "Encantar brazal: salud menor", "encanto_brazal_salud_menor", 1, 75, mat("polvo_extraño", 1)),
		r("encanto_brazal_desvío_menor", "Encantar brazal: desvío menor", "encanto_brazal_desvío_menor", 75, 85, mat("polvo_extraño", 1)),
		r("encanto_brazal_aguante_menor", "Encantar brazal: aguante menor", "encanto_brazal_aguante_menor", 85, 105, mat("polvo_extraño", 3)),
		r("encanto_brazal_agilidad_menor", "Encantar brazal: agilidad menor", "encanto_brazal_agilidad_menor", 105, 120, mat("polvo_extraño", 2, "esencia_astral_inferior", 1)),
		r("encanto_escudo_aguante_menor", "Encantar escudo: aguante menor", "encanto_escudo_aguante_menor", 120, 130, mat("polvo_alma", 2)),
		r("encanto_brazal_aguante_inferior", "Encantar brazal: aguante inferior", "encanto_brazal_aguante_inferior", 130, 160, mat("polvo_alma", 2)),
		r("encanto_escudo_aguante_inferior", "Encantar escudo: aguante inferior", "encanto_escudo_aguante_inferior", 160, 165, mat("polvo_alma", 2)),
		r("encanto_brazal_espíritu", "Encantar brazal: espíritu", "encanto_brazal_espíritu", 165, 180, mat("polvo_visión", 2)),
		r("encanto_brazal_fuerza", "Encantar brazal: fuerza", "encanto_brazal_fuerza", 180, 205, mat("polvo_visión", 2)),
		r("encanto_capa_defensa_superior", "Encantar capa: defensa superior", "encanto_capa_defensa_superior", 205, 225, mat("polvo_visión", 3)),
		r("encanto_guantes_agilidad", "Encantar guantes: agilidad", "encanto_guantes_agilidad", 225, 235, mat("polvo_onírico", 1, "esencia_mística_inferior", 1)),
		r("encanto_pechera_salud_excelente", "Encantar pechera: salud excelente", "encanto_pechera_salud_excelente", 235, 245, mat("polvo_onírico", 3)),
		r("encanto_brazal_fuerza_superior", "Encantar brazal: fuerza superior", "encanto_brazal_fuerza_superior", 245, 265, mat("polvo_onírico", 2)),
		r("encanto_escudo_aguante_superior", "Encantar escudo: aguante superior", "encanto_escudo_aguante_superior", 265, 290, mat("polvo_ilusión", 2, "esencia_abisal_superior", 1)),
		r("encanto_capa_defensa_excelente", "Encantar capa: defensa excelente", "encanto_capa_defensa_excelente", 291, 300, mat("polvo_ilusión", 2)),
		// ─── Encantamientos TBC 300-350 ───
		r("encanto_brazal_asalto", "Encantar brazal: asalto", "encanto_brazal_asalto", 300, 310, mat("polvo_arcano", 6)),
		r("encanto_brazal_lozanía", "Encantar brazal: lozanía", "encanto_brazal_lozanía", 310, 315, mat("polvo_arcano", 4, "esencia_bidimensional_superior", 1)),
		r("encanto_capa_armadura_sublime", "Encantar capa: armadura sublime", "encanto_capa_armadura_sublime", 315, 320, mat("polvo_arcano", 6)),
		r("encanto_pechera_espíritu_sublime", "Encantar pechera: espíritu sublime", "encanto_pechera_espíritu_sublime", 320, 335, mat("polvo_arcano", 8)),
		r("encanto_escudo_aguante_sublime", "Encantar escudo: aguante sublime", "encanto_escudo_aguante_sublime", 335, 340, mat("polvo_arcano", 6)),
		r("aceite_zahorí_excelente", "Aceite de zahorí excelente", "aceite_zahorí_excelente", 340, 345, mat("vid_pesadilla", 1)),
		r("encanto_guantes_fuerza_sublime", "Encantar guantes: fuerza sublime", "encanto_guantes_fuerza_sublime", 345, 350, mat("polvo_arcano", 4, "esencia_bidimensional_superior", 1)),
		// ─── Encantamientos WotLK 350-450 ───
		r("encanto_capa_velocidad", "Encantar capa: velocidad", "encanto_capa_velocidad", 350, 360, mat("polvo_infinito", 6)),
		r("encanto_brazales_golpear", "Encantar brazales: golpear", "encanto_brazales_golpear", 360, 380, mat("polvo_infinito", 6)),
		r("encanto_brazales_intelecto_excepcional", "Encantar brazales: intelecto excepcional", "encanto_brazales_intelecto_excepcional", 380, 385, mat("polvo_infinito", 6)),
		r("encanto_botas_caminante_hielo", "Encantar botas: caminante de hielo", "encanto_botas_caminante_hielo", 385, 395, mat("polvo_infinito", 6, "agua_cristalizada", 1)),
		r("encanto_capa_agilidad_excelente", "Encantar capa: agilidad excelente", "encanto_capa_agilidad_excelente", 395, 410, mat("polvo_infinito", 6, "esencia_cósmica_superior", 1)),
		r("encanto_guantes_pericia", "Encantar guantes: pericia", "encanto_guantes_pericia", 410, 415, mat("polvo_infinito", 6, "tierra_eterna", 2)),
		r("encanto_botas_espíritu_superior", "Encantar botas: espíritu superior", "encanto_botas_espíritu_superior", 415, 420, mat("polvo_infinito", 6, "esencia_cósmica_superior", 1)),
		r("encanto_escudo_defensa", "Encantar escudo: defensa", "encanto_escudo_defensa", 420, 430, mat("polvo_infinito", 6, "tierra_eterna", 2)),
		r("encanto_capa_armadura_poderosa", "Encantar capa: Armadura poderosa", "encanto_capa_armadura_poderosa", 430, 435, mat("polvo_infinito", 6, "tierra_eterna", 2)),
		r("encanto_guantes_armero", "Encantar guantes: armero", "encanto_guantes_armero", 435, 445, mat("polvo_infinito", 6, "tierra_eterna", 2, "fragmento_onírico", 1)),
		r("fragmento_abisal", "Fragmento abisal", "fragmento_abisal", 445, 447, mat("tierra_eterna", 4, "esencia_cósmica_superior", 2)),
		r("encanto_botas_asalto_superior", "Encantar botas: asalto superior", "encanto_botas_asalto_superior", 447, 450, mat("polvo_infinito", 6, "tierra_eterna", 2, "fragmento_onírico", 1)),
	}
	return DefProfesion{
		ID:       "encantamiento",
		Nombre:   "Encantamiento",
		Primaria: true,
		MaxSkill: 450,
		Rangos:   rangos,
		Recetas:  recetas,
	}
}
