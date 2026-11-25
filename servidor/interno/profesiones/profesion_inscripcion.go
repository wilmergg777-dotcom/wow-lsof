// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionInscripcion construye Inscripción (WoW 3.3.5, 1-450), profesión de
// producción introducida en WotLK. Su rasgo distintivo es la CADENA DE TRES
// PASOS, la más larga del juego: moler hierbas → pigmento, combinar pigmento
// → tinta, fabricar tinta → glifo/pergamino. Los tres pasos usan el verbo
// Craftear (moler = craftear hierbas→pigmento; no hace falta un verbo nuevo),
// igual que las cadenas de intermedios de Ingeniería (pólvora→tornillo→gadget)
// o Encantamiento (vara→encantar), pero con un eslabón más.
//
// Segundo rasgo: la Investigación de inscripción de Rasganorte, una receta
// que "descubre" un glifo (aquí modelada como receta que produce
// glifo_descubierto y da skill; el cooldown diario real no se modela).
//
// Inscripción consume las hierbas de Herboristería (el eslabón cross-profesión
// recolección→producción, igual que Alquimia). Sin especializaciones. 6 rangos.
// 43 recetas (8 moliendas + 13 tintas + 8 glifos + 11 pergaminos + 2 vitelas
// + 1 tarot + 1 investigación) cubren 0→450 de forma contigua.
func profesionInscripcion() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz escribano", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial escribano", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto escribano", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Escribano artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro escribano", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro escribano", SkillReq: 350, SkillMax: 450},
	}
	// r construye una receta con materiales en pares (id, cantidad).
	r := func(id, nombre, resultado string, req, hasta int, materiales ...interface{}) DefReceta {
		mats := make([]MaterialRec, 0, len(materiales)/2)
		for i := 0; i+1 < len(materiales); i += 2 {
			mats = append(mats, MaterialRec{ItemID: materiales[i].(string), Cantidad: materiales[i+1].(int)})
		}
		return DefReceta{
			ID: id, Nombre: nombre, ResultadoID: resultado, ResultadoCantidad: 1,
			SkillReq: req, SkillHasta: hasta, Materiales: mats,
		}
	}
	recetas := []DefReceta{
		// ─── Paso 1: MOLER hierbas → pigmento (8 moliendas, una por tier).
		r("moler_alabastro", "Moler hierbas (pigmento alabastro)", "pigmento_alabastro", 0, 75, "flor_de_paz", 5),
		r("moler_oscurecido", "Moler hierbas (pigmento oscurecido)", "pigmento_oscurecido", 75, 150, "brezospina", 5),
		r("moler_dorado", "Moler hierbas (pigmento dorado)", "pigmento_dorado", 125, 200, "sangrerregia", 5),
		r("moler_esmeralda", "Moler hierbas (pigmento esmeralda)", "pigmento_esmeralda", 150, 225, "espina_de_oro", 5),
		r("moler_violeta", "Moler hierbas (pigmento violeta)", "pigmento_violeta", 175, 250, "carolina", 5),
		r("moler_plata", "Moler hierbas (pigmento de plata)", "pigmento_plata", 200, 275, "sansam_dorado", 5),
		r("moler_abisal", "Moler hierbas (pigmento abisal)", "pigmento_abisal", 275, 350, "hierba_vil", 5),
		r("moler_azur", "Moler hierbas (pigmento azur)", "pigmento_azur", 350, 450, "espina_de_hielo", 5),
		// ─── Paso 2: COMBINAR pigmento → tinta (13 tintas).
		r("tinta_marfil", "Tinta de marfil", "tinta_marfil", 0, 75, "pigmento_alabastro", 1),
		r("tinta_resplandor_lunar", "Tinta de resplandor lunar", "tinta_resplandor_lunar", 35, 130, "pigmento_oscurecido", 2),
		r("tinta_medianoche", "Tinta de medianoche", "tinta_medianoche", 75, 130, "pigmento_verdeante", 1),
		r("tinta_león", "Tinta de león", "tinta_león", 100, 150, "pigmento_dorado", 1),
		r("tinta_estrella_alba", "Tinta Estrella del Alba", "tinta_estrella_alba", 125, 175, "pigmento_esmeralda", 1),
		r("tinta_fuego_jade", "Tinta de fuego de jade", "tinta_fuego_jade", 150, 200, "pigmento_violeta", 1),
		r("tinta_real", "Tinta real", "tinta_real", 175, 225, "pigmento_rubí", 1),
		r("tinta_celestial", "Tinta celestial", "tinta_celestial", 200, 250, "pigmento_plata", 1),
		r("tinta_fulgurante", "Tinta fulgurante", "tinta_fulgurante", 250, 300, "pigmento_zafiro", 1),
		r("tinta_cielo", "Tinta del cielo", "tinta_cielo", 275, 350, "pigmento_abisal", 1),
		r("tinta_etérea", "Tinta etérea", "tinta_etérea", 290, 350, "pigmento_ébano", 1),
		r("tinta_mar", "Tinta del mar", "tinta_mar", 350, 400, "pigmento_azur", 1),
		r("tinta_avalancha", "Tinta de avalancha", "tinta_avalancha", 375, 400, "pigmento_helado", 1),
		// ─── Paso 3: FABRICAR tinta → glifo/pergamino/vitela/tarot.
		// Glifos (consumen tinta).
		r("glifo_inicial", "Glifo menor (inicial)", "glifo_inicial", 80, 130, "tinta_marfil", 1),
		r("glifo_porrazo", "Glifo de Porrazo", "glifo_porrazo", 185, 225, "tinta_celestial", 1),
		r("glifo_revancha", "Glifo de Revancha", "glifo_revancha", 190, 225, "tinta_celestial", 1),
		r("glifo_mayor", "Glifo mayor", "glifo_mayor", 205, 250, "tinta_celestial", 1),
		r("glifo_tbc", "Glifo de Terrallende", "glifo_tbc", 305, 350, "tinta_etérea", 1),
		r("glifo_wotlk", "Glifo de Rasganorte", "glifo_wotlk", 380, 400, "tinta_mar", 1),
		r("glifo_final", "Glifo mayor (avanzado)", "glifo_final", 430, 450, "tinta_avalancha", 1),
		// Pergaminos de atributo (consumen tinta).
		r("pergamino_aguante", "Pergamino de aguante", "pergamino_aguante", 19, 100, "tinta_marfil", 1),
		r("pergamino_espiritu_v", "Pergamino de espíritu V", "pergamino_espiritu_v", 255, 300, "tinta_fulgurante", 1),
		r("pergamino_espiritu_vii", "Pergamino de espíritu VII", "pergamino_espiritu_vii", 355, 375, "tinta_mar", 1),
		r("pergamino_intelecto_vii", "Pergamino de intelecto VII", "pergamino_intelecto_vii", 360, 375, "tinta_mar", 1),
		r("pergamino_fuerza_vii", "Pergamino de fuerza VII", "pergamino_fuerza_vii", 365, 375, "tinta_mar", 1),
		r("pergamino_agilidad_vii", "Pergamino de agilidad VII", "pergamino_agilidad_vii", 370, 375, "tinta_mar", 1),
		r("pergamino_aguante_viii", "Pergamino de aguante VIII", "pergamino_aguante_viii", 400, 450, "tinta_avalancha", 1),
		r("pergamino_espiritu_viii", "Pergamino de espíritu VIII", "pergamino_espiritu_viii", 405, 450, "tinta_avalancha", 1),
		r("pergamino_intelecto_viii", "Pergamino de intelecto VIII", "pergamino_intelecto_viii", 410, 450, "tinta_avalancha", 1),
		r("pergamino_fuerza_viii", "Pergamino de fuerza VIII", "pergamino_fuerza_viii", 415, 450, "tinta_avalancha", 1),
		r("pergamino_agilidad_viii", "Pergamino de agilidad VIII", "pergamino_agilidad_viii", 420, 450, "tinta_avalancha", 1),
		// Vitelas (consumen tinta).
		r("vitela_armadura", "Vitela de armadura", "vitela_armadura", 53, 130, "tinta_marfil", 1),
		r("vitela_arma_ii", "Vitela de arma II", "vitela_arma_ii", 245, 275, "tinta_celestial", 1),
		// Tarot (consume tinta).
		r("tarot_extrano", "Tarot extraño", "tarot_extrano", 147, 175, "tinta_resplandor_lunar", 1),
		// Investigación de Rasganorte: descubre un glifo (cooldown diario real
		// no modelado; aquí es una receta que produce glifo_descubierto).
		r("investigacion_rasganorte", "Investigación de inscripción de Rasganorte", "glifo_descubierto", 385, 400, "tinta_avalancha", 1),
	}
	return DefProfesion{
		ID:       "inscripción",
		Nombre:   "Inscripción",
		Primaria: true,
		MaxSkill: 450,
		Rangos:   rangos,
		Recetas:  recetas,
	}
}
