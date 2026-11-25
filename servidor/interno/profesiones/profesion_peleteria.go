// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionPeleteria construye la profesión de Peletería completa (1-450),
// siguiendo la guía de WoW 3.3.5: 6 rangos, 30 recetas (Classic 1-300,
// TBC 300-350, WotLK 350-450) y 3 especializaciones (dragontina,
// elemental, tribal) que se aprenden a partir de 225 consumiendo los
// materiales de la misión de la guía.
func profesionPeleteria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz peletero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial peletero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto peletero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Artesano peletero", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro peletero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro peletero", SkillReq: 350, SkillMax: 450},
	}
	// Helpers compactos (mismos que en joyería, replicados para mantener el
	// archivo de profesiones autocontenido).
	mat := func(pares ...interface{}) []MaterialRec {
		out := make([]MaterialRec, 0, len(pares)/2)
		for i := 0; i+1 < len(pares); i += 2 {
			out = append(out, MaterialRec{ItemID: pares[i].(string), Cantidad: pares[i+1].(int)})
		}
		return out
	}
	r := func(id, nombre, resultado string, req, hasta int, mats []MaterialRec) DefReceta {
		return DefReceta{
			ID: id, Nombre: nombre, ProfesionID: "peleteria",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		r("complemento_armadura_ligera", "Complemento para armadura ligera", "complemento_armadura_ligera", 0, 45, mat("cuero_ligero", 1)),
		r("capa_cuero_cosida_mano", "Capa de cuero cosida a mano", "capa_cuero_cosida_mano", 45, 55, mat("cuero_ligero", 2)),
		r("guantes_cuero_relieve", "Guantes de cuero en relieve", "guantes_cuero_relieve", 55, 100, mat("cuero_fino", 3)),
		r("cinturon_cuero_refinado", "Cinturón de cuero refinado", "cinturon_cuero_refinado", 100, 125, mat("cuero_fino", 4)),
		r("botas_cuero_oscuro", "Botas de cuero oscuro", "botas_cuero_oscuro", 125, 137, mat("cuero_pesado", 4)),
		r("pantalones_cuero_oscuro", "Pantalones de cuero oscuro", "pantalones_cuero_oscuro", 137, 155, mat("cuero_pesado", 4)),
		r("guantes_cuero_montanero", "Guantes de cuero de montañero", "guantes_cuero_montanero", 155, 165, mat("cuero_pesado", 3, "pellejo_pesado_curado", 1)),
		r("complemento_pesado_armadura", "Complemento pesado para armadura", "complemento_pesado_armadura", 165, 180, mat("cuero_pesado", 5)),
		r("hombreras_barbaricas", "Hombreras barbáricas", "hombreras_barbaricas", 180, 195, mat("cuero_pesado", 8)),
		r("brazales_oscurecidos", "Brazales oscurecidos", "brazales_oscurecidos", 195, 205, mat("cuero_grueso", 2)),
		r("cinta_nochefugaz", "Cinta Nochefugaz", "cinta_nochefugaz", 205, 225, mat("cuero_grueso", 5)),
		r("faltriquera_municion_cuero_grueso", "Faltriquera de munición de cuero grueso", "faltriquera_municion_cuero_grueso", 225, 235, mat("cuero_grueso", 6)),
		r("pantalones_nochefugaz", "Pantalones Nochefugaz", "pantalones_nochefugaz", 235, 250, mat("cuero_grueso", 6)),
		r("botas_nochefugaz", "Botas Nochefugaz", "botas_nochefugaz", 250, 260, mat("cuero_grueso", 6)),
		r("guanteletes_cuero_maligno", "Guanteletes de cuero maligno", "guanteletes_cuero_maligno", 260, 270, mat("cuero_basto", 4)),
		r("brazales_cuero_maligno", "Brazales de cuero maligno", "brazales_cuero_maligno", 270, 280, mat("cuero_basto", 4)),
		r("cinta_cuero_maligno", "Cinta de cuero maligno", "cinta_cuero_maligno", 280, 300, mat("cuero_basto", 5)),
		// ─── TBC 300-350 ───
		r("cuero_pellejo_nodoso", "Cuero de pellejo nudoso", "cuero_pellejo_nodoso", 300, 310, mat("restos_cuero_pellejo_nodoso", 5)),
		r("refuerzo_armadura_pellejo_nodoso", "Refuerzo para armadura de pellejo nudoso", "refuerzo_armadura_pellejo_nodoso", 310, 325, mat("cuero_pellejo_nodoso", 4)),
		r("cuero_pellejo_nodoso_grueso", "Cuero de pellejo nudoso grueso", "cuero_pellejo_nodoso_grueso", 325, 335, mat("cuero_pellejo_nodoso", 5)),
		r("jubon_draenico_grueso", "Jubón draénico grueso", "jubon_draenico_grueso", 335, 340, mat("cuero_pellejo_nodoso_grueso", 5)),
		r("coraza_escamas_viles", "Coraza de escamas viles", "coraza_escamas_viles", 340, 350, mat("cuero_pellejo_nodoso_grueso", 6, "escamas_viles", 2)),
		// ─── WotLK 350-450 ───
		r("refuerzo_armadura_boreal", "Refuerzo para armadura boreal", "refuerzo_armadura_boreal", 350, 380, mat("cuero_boreal", 4)),
		r("botas_articas", "Botas árticas", "botas_articas", 380, 390, mat("cuero_boreal", 6)),
		r("cuero_boreal_pesado", "Cuero boreal pesado", "cuero_boreal_pesado", 390, 405, mat("cuero_boreal", 4)),
		r("leotardos_escamas_escarcha_oscuros", "Leotardos de escamas de escarcha oscuros", "leotardos_escamas_escarcha_oscuros", 405, 420, mat("cuero_boreal_pesado", 4, "agua_cristalizada", 2)),
		r("brazales_encapotados", "Brazales encapotados", "brazales_encapotados", 420, 425, mat("cuero_boreal_pesado", 3, "pelaje_artico", 1)),
		r("manijas_encapotadas", "Manijas encapotadas", "manijas_encapotadas", 425, 435, mat("cuero_boreal_pesado", 3, "quitina_nerubiana", 1)),
		r("armadura_pierna_pellejo_escarcha", "Armadura para pierna de pellejo de escarcha", "armadura_pierna_pellejo_escarcha", 435, 440, mat("cuero_boreal_pesado", 2, "agua_eterna", 1)),
		r("coraza_cuero_boreal_pesado", "Coraza de cuero boreal pesado", "coraza_cuero_boreal_pesado", 440, 450, mat("cuero_boreal_pesado", 6, "orbe_congelado", 1)),
	}
	// Especializaciones (se aprenden a partir de 225, consumiendo los
	// materiales de la misión de la guía). Solo se puede elegir una.
	especializaciones := []DefEspecializacion{
		{
			ID: "dragontina", Nombre: "Peletería dragontina", SkillReq: 225,
			Descripcion: "Crea objetos de malla, ideal para cazadores y chamanes.",
			Materiales:  mat("escamas_dragon_desgastadas", 10),
		},
		{
			ID: "elemental", Nombre: "Peletería elemental", SkillReq: 225,
			Descripcion: "Crea objetos de cuero, ideal para druidas feral y pícaros.",
			Materiales:  mat("corazon_fuego", 2, "globo_agua", 2, "nucleo_tierra", 2, "aliento_viento", 2),
		},
		{
			ID: "tribal", Nombre: "Peletería tribal", SkillReq: 225,
			Descripcion: "Crea objetos de cuero para druidas basados en intelecto y espíritu.",
			Materiales:  mat("cuero_grueso", 10),
		},
	}
	return DefProfesion{
		ID:               "peleteria",
		Nombre:           "Peletería",
		Primaria:         true,
		MaxSkill:         450,
		Rangos:           rangos,
		Recetas:          recetas,
		Especializaciones: especializaciones,
	}
}
