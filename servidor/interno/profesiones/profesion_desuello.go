// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionDesuello construye Desuello (WoW 3.3.5, 1-450), la tercera y
// última profesión de recolección pura (verbo Recolectar, sin consumo, sin
// recetas). Como Herboristería, usa solo Nodos. A diferencia de Minería no
// tiene fundición: lo que se desuella es ya el material de crafteo.
//
// Cierra el triángulo de recolección del juego: Herboristería (hierbas →
// Alquimia), Minería (menas → lingotes → Herrería/Joyería/Ingeniería) y
// Desuello (cueros → Peletería). Los cueros que produce son EXACTAMENTE los
// que Peletería consume (cuero ligero, fino, pesado, grueso, basto, pellejo
// nudoso, boreal) más las rarezas escamas viles y pelaje ártico. Sin
// recetas ni especializaciones. Requiere cuchillo para desollar (no modelado:
// pertenece al sistema de herramientas, no al de profesiones).
//
// 9 nodos cubren 0→450 de forma contigua siguiendo las zonas/criaturas de
// la guía: zonas iniciales (1-75 cuero ligero), El Cruce/Loch Modan
// (75-130 fino), Campamento Taurajo/Humedales/Trabalomas (130-205 pesado),
// Vega de Tuercespina (205-260 grueso), Isla Jaguero/Un'Goro (260-300
// basto), Península de Fuego Infernal/Nagrand (300-355 pellejo nudoso +
// escamas viles raras), Tundra Boreal/Cuenca de Sholazar (355-450 boreal +
// pelaje ártico raro). 6 rangos.
func profesionDesuello() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz desollador", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial desollador", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto desollador", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Desollador artesanal", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro desollador", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro desollador", SkillReq: 350, SkillMax: 450},
	}
	n := func(id, nombre, resultado, zona string, req, hasta int) DefNodo {
		return DefNodo{
			ID: id, Nombre: nombre, ProfesionID: "desuello",
			Zona: zona, ResultadoID: resultado, ResultadoCantidad: 1,
			SkillReq: req, SkillHasta: hasta,
		}
	}
	nodos := []DefNodo{
		// ─── Classic 1-300 ───
		// 1-75: jabalíes, escórpidos, lobos, osos en zonas iniciales.
		n("nodo_cuero_ligero", "Bestia de cuero ligero", "cuero_ligero", "Mulgore / Bosque de Elwynn / Dun Morogh (zonas iniciales)", 0, 75),
		// 75-130: crocoliscos, osos, jabalíes (El Cruce, Loch Modan, Humedales).
		n("nodo_cuero_fino", "Bestia de cuero fino", "cuero_fino", "El Cruce / Loch Modan / Páramos de Poniente", 75, 130),
		// 130-205: Tronatesta, raptor, osos, yetis (Campamento Taurajo, Humedales, Trabalomas).
		n("nodo_cuero_pesado", "Bestia de cuero pesado", "cuero_pesado", "Campamento Taurajo / Humedales / Laderas de Trabalomas (yetis de Colinas de Darrow)", 130, 205),
		// 205-260: tigres, panteras, raptor, gorilas (Vega de Tuercespina).
		n("nodo_cuero_grueso", "Bestia de cuero grueso", "cuero_grueso", "Vega de Tuercespina (Expedición Nesingwary / Arena Gurabashi)", 205, 260),
		// 260-300: panteras, gorilas, hienas, dinosaurios.
		n("nodo_cuero_basto", "Bestia de cuero basto", "cuero_basto", "Isla Jaguero / Tierras Devastadas / Cráter de Un'Goro", 260, 300),
		// ─── TBC 300-375 ───
		// 300-355: Jabinferno, Devastadores, talbuks, uñagrietas (Fuego Infernal, Nagrand).
		n("nodo_pellejo_nodoso", "Bestia de pellejo nudoso", "cuero_pellejo_nodoso", "Península del Fuego Infernal / Nagrand", 300, 355),
		// 340-355: escamas viles (rarezas de dragones en Nagrand).
		n("nodo_escamas_viles", "Dragón de escamas viles", "escamas_viles", "Nagrand (Uñagrieta dominante)", 340, 355),
		// ─── WotLK 350-450 ───
		// 355-450: rinocerontes (Tundra Boreal), primates (Cuenca de Sholazar).
		n("nodo_cuero_boreal", "Bestia de cuero boreal", "cuero_boreal", "Tundra Boreal (rinocerontes) / Cuenca de Sholazar (primates)", 355, 450),
		// 390-450: pelaje ártico (rareza de bestias de Rasganorte).
		n("nodo_pelaje_artico", "Bestia de pelaje ártico", "pelaje_artico", "Cuenca de Sholazar / Corona de Hielo", 390, 450),
	}
	return DefProfesion{
		ID:       "desuello",
		Nombre:   "Desuello",
		Primaria: true,
		MaxSkill: 450,
		Rangos:   rangos,
		Nodos:    nodos,
	}
}
