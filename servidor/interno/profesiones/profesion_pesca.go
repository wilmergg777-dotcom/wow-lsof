// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// profesionPesca construye Pesca (WoW 3.3.5, 1-450), la SEGUNDA profesión
// SECUNDARIA (Primaria=false). Es recolección como Herboristería/Desuello
// (verbo Recolectar, sin consumo, sin recetas), pero con dos diferencias:
// no hay nodos fijos en el mundo (se pesca en cualquier masa de agua — aquí
// modelado como un "nodo" por banda/zona de pesca) y el equipo (caña con
// +habilidad y cebos consumibles) mejora la pesca — no modelado.
//
// Rangos experto (libro), artesano (misión de 4 peces raros) y maestro
// (libro) están quest-gated — simplificado: se aprenden normalmente al
// alcanzar el skill. 10 nodos cubren 0→450 de forma contigua siguiendo las
// zonas de la guía: capitales (0-50), Vallefresno/Trabalomas (50-100),
// Marjal/Desolace (100-175), Azshara/Feralas (175-225), Tanaris/Un'Goro
// (225-275), Cuna del Invierno (275-315), Marisma de Zangar (315-375),
// Rasganorte (375-450).
//
// Eslabón cross-profesión: los pescados que produce son EXACTAMENTE los que
// Cocina consume (pececito_luminoso_crudo, siluro_mostacherizo_crudo, etc.).
// Cierra el bucle de las dos secundarias: pescar → cocinar. Sin
// especializaciones. 6 rangos.
func profesionPesca() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz pescador", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial pescador", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto pescador", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Pescador artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro pescador", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro pescador", SkillReq: 350, SkillMax: 450},
	}
	n := func(id, nombre, resultado, zona string, req, hasta int) DefNodo {
		return DefNodo{
			ID: id, Nombre: nombre, ProfesionID: "pesca",
			Zona: zona, ResultadoID: resultado, ResultadoCantidad: 1,
			SkillReq: req, SkillHasta: hasta,
		}
	}
	nodos := []DefNodo{
		// ─── Classic 1-300 ───
		n("nodo_pececito_luminoso", "Pesca de Pececito luminoso", "pececito_luminoso_crudo", "Capitales y zonas iniciales", 0, 50),
		n("nodo_pargo_boquilargo", "Pesca de Pargo boquilargo", "pargo_loco_boquilargo_crudo", "Vallefresno / Laderas de Trabalomas / Humedales", 50, 100),
		n("nodo_siluro_mostacherizo", "Pesca de Siluro mostacherizo", "siluro_mostacherizo_crudo", "Marjal Revolcafango / Desolace / Vega de Tuercespina", 100, 175),
		n("nodo_trucha_cabeza_mitril", "Pesca de Trucha cabeza de mitril", "trucha_cabeza_mitril_crudo", "Azshara / Frondavil / Feralas / Tanaris", 175, 225),
		n("nodo_serviola_moteada", "Pesca de Serviola moteada", "serviola_moteada_crudo", "Tanaris / Cráter de Un'Goro", 225, 250),
		n("nodo_salmon_escama_sol", "Pesca de Salmón escama de sol", "salmon_escama_sol_crudo", "Río del Veneno (Frondavil) / Cuna del Invierno", 250, 275),
		n("nodo_vigorpez", "Pesca de Vigorpez", "vigorpez_crudo_grande", "Cueva Barbaescama (Azshara) / Paso de la Muerte", 275, 315),
		// ─── TBC 300-375 ───
		n("nodo_pecespora_zangar", "Pesca de Pecespora de Zangar", "pecespora_zangar", "Marisma de Zangar (Refugio Cenarion)", 315, 375),
		// ─── WotLK 375-450 ───
		n("nodo_dardo_dorado", "Pesca de Dardo dorado", "dardo_dorado", "Tundra Boreal / Fiordo Aquilonal", 375, 400),
		n("nodo_trucha_branquias", "Pesca de Trucha de branquias barbadas", "trucha_branquias_barbadas_enorme", "Cuenca de Sholazar / Corona de Hielo", 400, 450),
	}
	return DefProfesion{
		ID:       "pesca",
		Nombre:   "Pesca",
		Primaria: false, // SECUNDARIA: no cuenta contra el límite de 2 primarias.
		MaxSkill: 450,
		Rangos:   rangos,
		Nodos:    nodos,
	}
}
