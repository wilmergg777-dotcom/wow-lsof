// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionMineria construye Minería (WoW 3.3.5, 1-450), la segunda
// profesión de recolección y la PRIMERA HÍBRIDA del juego: combina Nodos
// (picar vetas, verbo Recolectar, sin consumo) con Recetas de FUNDICIÓN
// (mena → barra, verbo Craftear, consume menas). La guía sube picando
// vetas ( gathering ); la fundición es la vía secundaria que además cierra
// el eslabón cross-profesión más importante del juego: minar mena → fundir
// barra → la barra la consumen Herrería, Joyería e Ingeniería.
//
// 14 nodos cubren 0→450 de forma contigua siguiendo las zonas de la guía:
// Mulgore/Dun Morogh (1-65 cobre), Laderas de Trabalomas (66-125 estaño y
// plata), Tierras Altas de Arathi (125-175 hierro y oro), Tierras del
// Interior/Tanaris (175-250 mitril y veraplata, artesano a 200), Cráter de
// Un'Goro/Cuna del Invierno (251-300 torio), Península de Fuego
// Infernal/Marisma de Zangar (300-330 hierro vil, maestro a 275), Nagrand
// (330-375 adamantita y korio, 365+), Tundra Boreal/Fiordo Aquilonal
// (375-400 cobalto, gran_maestro a 350) y Corona de Hielo/Cuenca de
// Sholazar (400-450 saronita y titanio).
//
// 15 recetas de fundición producen las barras que ya consumen las
// profesiones de crafteo (más las aleaciones bronce = cobre+estaño y
// acero = hierro+carbón). Sin especializaciones. 6 rangos.
func profesionMineria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz minero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial minero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto minero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Minero artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro minero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro minero", SkillReq: 350, SkillMax: 450},
	}
	n := func(id, nombre, resultado, zona string, req, hasta int) DefNodo {
		return DefNodo{
			ID: id, Nombre: nombre, ProfesionID: "minería",
			Zona: zona, ResultadoID: resultado, ResultadoCantidad: 1,
			SkillReq: req, SkillHasta: hasta,
		}
	}
	nodos := []DefNodo{
		// ─── Classic 1-300 ───
		// 1-65: Mulgore (Horda) / Dun Morogh (Alianza) / Costa Oscura.
		n("nodo_cobre", "Filón de cobre", "mena_cobre", "Mulgore / Dun Morogh / Costa Oscura", 0, 65),
		// 66-125: Laderas de Trabalomas (cuevas con estaño y plata).
		n("nodo_estaño", "Filón de estaño", "mena_estaño", "Laderas de Trabalomas", 65, 125),
		n("nodo_plata", "Filón de plata", "mena_plata", "Laderas de Trabalomas", 75, 130),
		// 125-175: Tierras Altas de Arathi (hierro y oro).
		n("nodo_hierro", "Filón de hierro", "mena_hierro", "Tierras Altas de Arathi", 125, 175),
		n("nodo_oro", "Filón de oro", "mena_oro", "Tierras Altas de Arathi", 155, 175),
		// 175-250: Tierras del Interior / Tanaris (mitril y veraplata).
		n("nodo_mitril", "Filón de mitril", "mena_mitril", "Tierras del Interior", 175, 250),
		n("nodo_veraplata", "Filón de veraplata", "mena_veraplata", "Tierras del Interior", 175, 230),
		// 251-300: Cráter de Un'Goro / Cuna del Invierno.
		n("nodo_torio", "Filón de torio", "mena_torio", "Cráter de Un'Goro / Cuna del Invierno", 250, 300),
		// ─── TBC 300-375 ───
		// 300-330: Península de Fuego Infernal / Marisma de Zangar.
		n("nodo_hierro_vil", "Filón de hierro vil", "mena_hierro_vil", "Península de Fuego Infernal / Marisma de Zangar", 300, 330),
		// 330-375: Nagrand (adamantita y, desde 365, korio de depósitos ricos).
		n("nodo_adamantita", "Filón de adamantita", "mena_adamantita", "Nagrand", 330, 375),
		n("nodo_korio", "Filón de korio", "mena_korio", "Nagrand / Valle Sombraluna", 355, 375),
		// ─── WotLK 375-450 ───
		// 375-400: Tundra Boreal / Fiordo Aquilonal / Colinas Pardas / Zul'Drak.
		n("nodo_cobalto", "Filón de cobalto", "mena_cobalto", "Tundra Boreal / Fiordo Aquilonal", 375, 400),
		// 400-450: Corona de Hielo / Conquista del Invierno / Cuenca de Sholazar.
		n("nodo_saronita", "Filón de saronita", "mena_saronita", "Corona de Hielo / Cuenca de Sholazar", 400, 450),
		n("nodo_titanio", "Filón de titanio", "mena_titanio", "Corona de Hielo / Cuenca de Sholazar", 425, 450),
	}
	// Recetas de FUNDICIÓN: mena → barra (vía secundaria de subir habilidad
	// y cierre del bucle cross-profesión). Las aleaciones (bronce, acero)
	// consumen barras en vez de menas.
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
		// Classic.
		r("fundir_cobre", "Fundir cobre", "barra_cobre", 0, 65, "mena_cobre", 1),
		r("fundir_estaño", "Fundir estaño", "barra_estaño", 50, 125, "mena_estaño", 1),
		r("fundir_bronce", "Fundir bronce (aleación)", "barra_bronce", 75, 90, "barra_cobre", 1, "barra_estaño", 1),
		r("fundir_plata", "Fundir plata", "barra_plata", 75, 130, "mena_plata", 1),
		r("fundir_hierro", "Fundir hierro", "barra_hierro", 125, 175, "mena_hierro", 1),
		r("fundir_oro", "Fundir oro", "barra_oro", 155, 175, "mena_oro", 1),
		r("fundir_acero", "Fundir acero (aleación)", "barra_acero", 155, 175, "barra_hierro", 1, "carbón", 1),
		r("fundir_mitril", "Fundir mitril", "barra_mitril", 175, 250, "mena_mitril", 1),
		r("fundir_veraplata", "Fundir veraplata", "barra_veraplata", 175, 250, "mena_veraplata", 1),
		r("fundir_torio", "Fundir torio", "barra_torio", 250, 300, "mena_torio", 1),
		// TBC.
		r("fundir_hierro_vil", "Fundir hierro vil", "barra_hierro_vil", 300, 330, "mena_hierro_vil", 1),
		r("fundir_adamantita", "Fundir adamantita", "barra_adamantita", 325, 375, "mena_adamantita", 1),
		r("fundir_korio", "Fundir korio", "barra_korio", 350, 375, "mena_korio", 1),
		// WotLK.
		r("fundir_cobalto", "Fundir cobalto", "barra_cobalto", 350, 400, "mena_cobalto", 1),
		r("fundir_saronita", "Fundir saronita", "barra_de_saronita", 400, 450, "mena_saronita", 2),
	}
	return DefProfesion{
		ID:       "minería",
		Nombre:   "Minería",
		Primaria: true,
		MaxSkill: 450,
		Rangos:   rangos,
		Recetas:  recetas,
		Nodos:    nodos,
	}
}
