// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionCocina construye Cocina (WoW 3.3.5, 1-450), la PRIMERA profesión
// SECUNDARIA del juego: Primaria=false, así no cuenta contra el límite de
// MaxProfesionesPrimarias (2). Todo jugador puede aprenderla además de sus
// dos primarias. Es de producción pura (verbo Craftear, recetas que
// consumen pescado/carne/especias y producen comidas con buff de atributo).
//
// Requiere una fuente de calor (lumbre/estufa) — no modelado (pertenece al
// sistema de mundo/posición, no al de profesiones). Rangos experto y maestro
// requieren comprar un libro, y artesano una misión — simplificado: se
// aprenden normalmente al alcanzar el skill. Los WotLK 400-450 usan
// northern_spice (recompensa de misiones diarias — el cooldown diario real
// no se modela). 13 recetas cubren 0→450 de forma contigua. Sin
// especializaciones. 6 rangos.
//
// Eslabón cross-profesión: consume el pescado de Pesca (la otra secundaria).
func profesionCocina() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz cocinero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial cocinero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto cocinero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Cocinero artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro cocinero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro cocinero", SkillReq: 350, SkillMax: 450},
	}
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
		// ─── Classic 1-300 ───
		r("pececito_luminoso", "Pececito luminoso", "pececito_luminoso", 0, 50, "pececito_luminoso_crudo", 1),
		r("pargo_lodo_boquilargo", "Pargo de lodo boquilargo", "pargo_lodo_boquilargo", 50, 100, "pargo_loco_boquilargo_crudo", 1),
		r("siluro_mostacherizo", "Siluro mostacherizo", "siluro_mostacherizo", 100, 175, "siluro_mostacherizo_crudo", 1),
		r("trucha_cabeza_mitril", "Trucha de cabeza de mitril", "trucha_cabeza_mitril", 175, 225, "trucha_cabeza_mitril_crudo", 1),
		r("serviola_moteada", "Serviola moteada", "serviola_moteada", 225, 250, "serviola_moteada_crudo", 1),
		r("salmon_escama_sol_pochado", "Salmón escama de sol pochado", "salmon_escama_sol_pochado", 250, 275, "salmon_escama_sol_crudo", 1),
		r("filete_vigorpez", "Filete de vigorpez", "filete_vigorpez", 275, 315, "vigorpez_crudo_grande", 1),
		// ─── TBC 300-375 ───
		r("pescado_esporas_ennegrecido", "Pescado con esporas ennegrecido", "pescado_esporas_ennegrecido", 315, 340, "pecespora_zangar", 1),
		r("palitos_pez_dorado", "Palitos de pez dorado", "palitos_pez_dorado", 340, 360, "dardo_dorado", 1),
		r("trucha_mantequilla_caliente", "Trucha con mantequilla caliente", "trucha_mantequilla_caliente", 360, 375, "trucha_branquias_barbadas_enorme", 1),
		// ─── WotLK 375-450 ───
		r("kungaloosh", "Kungaloosh", "kungaloosh", 375, 400, "bayas_tundra", 2, "ciruela_blanca_sabrosa", 1),
		r("guiso_pecespora", "Guiso de pecespora", "guiso_pecespora", 400, 425, "pecespora_zangar", 2, "northern_spice", 1),
		r("filete_dardo_picante", "Filete de dardo dorado picante", "filete_dardo_picante", 425, 450, "dardo_dorado", 2, "northern_spice", 1),
		// ─── WotLK: comidas usables (bien alimentado, 1h) ───
		r("comida_rinoceronte_rec", "Riñón de rinoceronte asado", "comida_rinoceronte", 400, 425, "carne_rinoceronte", 2, "northern_spice", 1),
		r("comida_sabalo_rec", "Cabeza de sábalo picante", "comida_sabalo", 400, 425, "sabalo", 2, "northern_spice", 1),
		r("comida_mamut_rec", "Golosinas de mamut especiadas", "comida_mamut", 415, 440, "carne_mamut", 2, "northern_spice", 1),
		r("comida_banquete_rec", "Gran banquete", "comida_banquete", 425, 450, "carne_mamut", 2, "northern_spice", 1, "especias_frescas", 1),
	}
	return DefProfesion{
		ID:       "cocina",
		Nombre:   "Cocina",
		Primaria: false, // SECUNDARIA: no cuenta contra el límite de 2 primarias.
		MaxSkill: 450,
		Rangos:   rangos,
		Recetas:  recetas,
	}
}
