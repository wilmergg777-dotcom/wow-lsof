// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionHerboristeria construye la primera profesión de RECOLECCIÓN del
// juego (WoW 3.3.5, 1-450). A diferencia de las 7 profesiones de crafteo,
// Herboristería no tiene Recetas: sube recogiendo hierbas de Nodos en el
// mundo (verbo Recolectar, sin consumo de materiales). Cada nodo produce
// una hierba y da habilidad mientras skill < SkillHasta (el "verde" de
// WoW). Los nodos se encadenan de forma contigua para cubrir 0→450 sin
// huecos, siguiendo las zonas de la guía: Mulgore/Elwynn (1-75),
// Loch Modan/Baldíos (75-115), Tierras Altas de Arathi (115-205),
// Garganta de Fuego (205-230), Feralas (230-275), Tierras de la Peste del
// Oeste (275-300), Frondavil/Peste del Este TBC (300-330), Marisma de
// Zangar (330-375), Rasganorte/Cuenca de Sholazar (375-435) y Las Cumbres
// Tormentosas (435-450). Las hierbas recolectadas son los materiales que
// consume Alquimia (y la futura Inscripción): reutiliza las 21 hierbas que
// Alquimia ya registró y solo añade Raíz de tierra (Earthroot, nombrada
// explícitamente en la guía 1-75). 6 rangos, 21 nodos, sin recetas ni
// especializaciones.
func profesionHerboristeria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz herborista", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial herborista", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto herborista", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Herborista artesanal", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro herborista", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro herborista", SkillReq: 350, SkillMax: 450},
	}
	n := func(id, nombre, resultado, zona string, req, hasta int) DefNodo {
		return DefNodo{
			ID: id, Nombre: nombre, ProfesionID: "herboristeria",
			Zona: zona, ResultadoID: resultado, ResultadoCantidad: 1,
			SkillReq: req, SkillHasta: hasta,
		}
	}
	nodos := []DefNodo{
		// ─── Classic 1-300 ───
		// 1-75: Mulgore (Horda) / Bosque de Elwynn (Alianza) / Teldrassil.
		n("nodo_hojaplata", "Nodo de Hojaplata", "hojaplata", "Mulgore / Bosque de Elwynn", 0, 65),
		n("nodo_flor_de_paz", "Nodo de Flor de paz", "flor_de_paz", "Mulgore / Bosque de Elwynn", 0, 70),
		n("nodo_raíz_de_tierra", "Nodo de Raíz de tierra", "raíz_de_tierra", "Mulgore / Bosque de Elwynn", 15, 90),
		n("nodo_marregal", "Nodo de Marregal", "marregal", "Mulgore / Bosque de Elwynn", 50, 115),
		// 75-115: Loch Modan / Los Baldíos.
		n("nodo_brezospina", "Nodo de Brezospina", "brezospina", "Loch Modan / Los Baldíos", 70, 130),
		n("nodo_alga_estranguladora", "Nodo de Alga estranguladora", "alga_estranguladora", "Loch Modan / Los Baldíos", 85, 135),
		// 115-205: Tierras Altas de Arathi.
		n("nodo_vidarraíz", "Nodo de Vidarraíz", "vidarraíz", "Tierras Altas de Arathi", 120, 175),
		n("nodo_sangrerregia", "Nodo de Sangrerregia", "sangrerregia", "Tierras Altas de Arathi", 125, 180),
		n("nodo_espina_de_oro", "Nodo de Espina de oro", "espina_de_oro", "Tierras Altas de Arathi", 150, 200),
		n("nodo_acérita_salvaje", "Nodo de Acérita salvaje", "acérita_salvaje", "Tierras Altas de Arathi", 160, 205),
		n("nodo_solea", "Nodo de Solea", "solea", "Tierras Altas de Arathi", 170, 215),
		n("nodo_mostacho_de_khadgar", "Nodo de Mostacho de Khadgar", "mostacho_de_khadgar", "Tierras Altas de Arathi", 185, 230),
		// 205-230: Garganta de Fuego.
		n("nodo_carolina", "Nodo de Carolina", "carolina", "Garganta de Fuego", 205, 245),
		// 230-275: Feralas / Frondavil.
		n("nodo_lágrimas_de_arthas", "Nodo de Lágrimas de Arthas", "lágrimas_de_arthas", "Feralas", 210, 250),
		n("nodo_sansam_dorado", "Nodo de Sansam dorado", "sansam_dorado", "Feralas", 230, 275),
		// 275-300: Tierras de la Peste del Oeste / Peste del Este / Un'Goro.
		n("nodo_salviargenta_de_montaña", "Nodo de Salviargenta de montaña", "salviargenta_de_montaña", "Tierras de la Peste del Oeste", 250, 300),
		// ─── TBC 300-375 ───
		// 300-330: Frondavil / Tierras de la Peste del Este (no Fuego Infernal).
		n("nodo_hierba_vil", "Nodo de Hierba vil", "hierba_vil", "Frondavil / Tierras de la Peste del Este", 300, 335),
		// 330-375: Marisma de Zangar (+ cadáveres de Señores de las Marismas).
		n("nodo_gloria_de_ensueño", "Nodo de Gloria de ensueño", "gloria_de_ensueño", "Marisma de Zangar", 315, 355),
		n("nodo_flor_abisal", "Nodo de Flor abisal", "flor_abisal", "Marisma de Zangar", 325, 365),
		n("nodo_velada", "Nodo de Velada", "velada", "Marisma de Zangar", 340, 375),
		// ─── WotLK 375-450 ───
		// 375-400: Rasganorte (Trébol de oro desde 350).
		n("nodo_trébol_de_oro", "Nodo de Trébol de oro", "trébol_de_oro", "Fiordo Aquilonal / Tundra Boreal", 375, 410),
		// 400-435: Cuenca de Sholazar.
		n("nodo_lirio_atigrado", "Nodo de Lirio atigrado", "lirio_atigrado", "Cuenca de Sholazar", 390, 430),
		n("nodo_lengua_de_víboris", "Nodo de Lengua de víporis", "lengua_de_víboris", "Cuenca de Sholazar", 400, 435),
		// 435-450: Las Cumbres Tormentosas.
		n("nodo_espina_de_hielo", "Nodo de Espina de hielo", "espina_de_hielo", "Las Cumbres Tormentosas", 430, 450),
		n("nodo_flor_exánime", "Nodo de Flor exánime", "flor_exánime", "Las Cumbres Tormentosas", 435, 450),
	}
	return DefProfesion{
		ID:       "herboristeria",
		Nombre:   "Herboristería",
		Primaria: true,
		MaxSkill: 450,
		Rangos:   rangos,
		Nodos:    nodos,
	}
}
