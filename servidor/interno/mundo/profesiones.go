// profesiones.go define el sistema de profesiones: cada profesión tiene
// rangos (Aprendiz → Gran Maestro) y recetas que consumen materiales y
// producen ítems, subiendo la habilidad.
//
// La primera profesión implementada es Joyería (Jewelcrafting) siguiendo
// la guía de WoW 3.3.5 (1-450): materiales y recetas Classic, TBC y WotLK.
// El sistema es extensible: añadir Herrería, Minería, etc. es solo añadir
// otra DefProfesion al registro.
package mundo

// MaxProfesionesPrimarias es el límite de profesiones primarias por
// personaje (regla de WoW: 2 primarias).
const MaxProfesionesPrimarias = 2

// DefRango define un rango de una profesión (Aprendiz, Oficial, ...).
// Aprender un rango sube el techo de habilidad (SkillMax) del personaje.
type DefRango struct {
	ID       string `json:"id"`
	Nombre   string `json:"nombre"`
	SkillReq int    `json:"skill_req"` // habilidad mínima para aprenderlo
	SkillMax int    `json:"skill_max"` // techo de habilidad al aprenderlo
}

// DefReceta define una receta de crafteo.
// SkillReq: habilidad mínima para craftearla.
// SkillHasta: habilidad a partir de la cual ya NO sube (se pone gris).
type DefReceta struct {
	ID              string         `json:"id"`
	Nombre          string         `json:"nombre"`
	ProfesionID     string         `json:"profesion_id"`
	ResultadoID     string         `json:"resultado_id"`
	ResultadoCantidad int          `json:"resultado_cantidad"`
	Materiales      []MaterialRec  `json:"materiales"`
	SkillReq        int            `json:"skill_req"`
	SkillHasta      int            `json:"skill_hasta"`
	Especializacion string         `json:"especializacion,omitempty"` // si requiere una especialización concreta
}

// MaterialRec es un material requerido por una receta.
type MaterialRec struct {
	ItemID   string `json:"item_id"`
	Cantidad int    `json:"cantidad"`
}

// DefEspecializacion define una rama de especialización de una profesión
// (p.ej. Peletería dragontina/elemental/tribal). Se aprende a partir de
// SkillReq consumiendo Materiales (abstracción de la misión de la guía).
type DefEspecializacion struct {
	ID          string        `json:"id"`
	Nombre      string        `json:"nombre"`
	SkillReq    int           `json:"skill_req"`
	Descripcion string        `json:"descripcion"`
	Materiales  []MaterialRec `json:"materiales"`
}

// DefProfesion define una profesión jugable.
type DefProfesion struct {
	ID             string             `json:"id"`
	Nombre         string             `json:"nombre"`
	Primaria       bool               `json:"primaria"` // true = cuenta para el límite de 2
	MaxSkill       int                `json:"max_skill"`
	Rangos         []DefRango         `json:"rangos"`
	Recetas        []DefReceta        `json:"recetas"`
	Especializaciones []DefEspecializacion `json:"especializaciones,omitempty"`
}

// EstadoProfesion es el estado de una profesión que aprendió un jugador.
// Se persiste con el personaje.
type EstadoProfesion struct {
	ProfesionID      string   `json:"profesion_id"`
	Skill            int      `json:"skill"`
	RangosAprendidos []string `json:"rangos_aprendidos"`
	Especializacion  string   `json:"especializacion,omitempty"` // ID de la especialización elegida ("" si ninguna)
}

// SkillMax devuelve el techo de habilidad actual del jugador en esta
// profesión: el SkillMax del rango más alto aprendido.
func (e *EstadoProfesion) SkillMax(def DefProfesion) int {
	max := 0
	for _, rid := range e.RangosAprendidos {
		for _, rg := range def.Rangos {
			if rg.ID == rid && rg.SkillMax > max {
				max = rg.SkillMax
			}
		}
	}
	return max
}

// RangoAprendido devuelve true si el rango con ese ID ya se aprendió.
func (e *EstadoProfesion) RangoAprendido(rangoID string) bool {
	for _, rid := range e.RangosAprendidos {
		if rid == rangoID {
			return true
		}
	}
	return false
}

// profesionesPredefinidas devuelve las profesiones jugables.
// Por ahora: Joyería (Jewelcrafting) 1-450.
func profesionesPredefinidas() map[string]DefProfesion {
	return map[string]DefProfesion{
		"joyeria":       profesionJoyeria(),
		"peleteria":     profesionPeleteria(),
		"sastreria":     profesionSastreria(),
		"encantamiento": profesionEncantamiento(),
	}
}

// profesionJoyeria construye la profesión de Joyería completa (1-450),
// siguiendo la guía de WoW 3.3.5: 6 rangos y 34 recetas repartidas entre
// Classic (1-300), TBC (300-375) y WotLK (350-450).
func profesionJoyeria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz joyero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial joyero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto joyero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Artesano joyero", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro joyero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro joyero", SkillReq: 350, SkillMax: 450},
	}
	// mat es un helper para construir listas de materiales compactas.
	mat := func(pares ...interface{}) []MaterialRec {
		out := make([]MaterialRec, 0, len(pares)/2)
		for i := 0; i+1 < len(pares); i += 2 {
			out = append(out, MaterialRec{ItemID: pares[i].(string), Cantidad: pares[i+1].(int)})
		}
		return out
	}
	// r es un helper para construir recetas.
	r := func(id, nombre, resultado string, req, hasta int, mats []MaterialRec) DefReceta {
		return DefReceta{
			ID: id, Nombre: nombre, ProfesionID: "joyeria",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		r("hilo_cobre_delicado", "Hilo de cobre delicado", "hilo_cobre_delicado", 0, 20, mat("barra_cobre", 2)),
		r("estatua_piedra_ferrica", "Estatua de piedra férrea", "estatua_piedra_ferrica", 20, 30, mat("piedra_ferrica", 8)),
		r("sortija_ojo_tigre", "Sortija de ojo de tigre", "sortija_ojo_tigre", 30, 50, mat("ojo_tigre", 1, "hilo_cobre_delicado", 1)),
		r("colgante_malaquita", "Colgante de malaquita", "colgante_malaquita", 30, 50, mat("malaquita", 1, "hilo_cobre_delicado", 1)),
		r("engarce_bronce", "Engarce de bronce", "engarce_bronce", 50, 70, mat("barra_bronce", 2)),
		r("anillo_bronce_solido", "Anillo de bronce sólido", "anillo_bronce_solido", 70, 80, mat("barra_bronce", 4)),
		r("anillo_poderio_plata", "Anillo del poderío de la plata", "anillo_poderio_plata", 80, 110, mat("barra_plata", 2)),
		r("estatua_piedra_pesada", "Estatua de piedra pesada", "estatua_piedra_pesada", 110, 120, mat("piedra_pesada", 8)),
		r("colgante_escudo_agata", "Colgante del escudo de ágata", "colgante_escudo_agata", 120, 150, mat("agata_musgosa", 1, "engarce_bronce", 1)),
		r("filigrana_mitril", "Filigrana de mitril", "filigrana_mitril", 150, 180, mat("barra_mitril", 2)),
		r("anillo_veraplata_grabado", "Anillo de veraplata grabado", "anillo_veraplata_grabado", 180, 200, mat("barra_veraplata", 2, "filigrana_mitril", 1)),
		r("anillo_citrino_sanacion", "Anillo de citrino de sanación rápida", "anillo_citrino_sanacion", 200, 210, mat("citrino", 1, "filigrana_mitril", 1)),
		r("sello_aguamarina", "Sello de aguamarina", "sello_aguamarina", 210, 225, mat("aguamarina", 1, "filigrana_mitril", 1)),
		r("engarce_torio", "Engarce de torio", "engarce_torio", 225, 250, mat("barra_torio", 3)),
		r("colgante_rubi_fuego", "Colgante de rubí de fuego", "colgante_rubi_fuego", 250, 260, mat("rubi_estrella", 1, "engarce_torio", 1)),
		r("anillo_opalo_sencillo", "Anillo de ópalo sencillo", "anillo_opalo_sencillo", 260, 275, mat("opalo_grande", 1, "engarce_torio", 1)),
		r("anillo_diamante_enfoque", "Anillo de diamante de enfoque", "anillo_diamante_enfoque", 275, 285, mat("diamante_azerot", 1, "engarce_torio", 1)),
		r("sortija_torio_resplandeciente", "Sortija de torio resplandeciente", "sortija_torio_resplandeciente", 285, 290, mat("frasco_mojo", 2, "barra_torio", 1)),
		r("anillo_leon_esmeralda", "Anillo de león de esmeralda", "anillo_leon_esmeralda", 290, 300, mat("esmeralda_enorme", 1, "engarce_torio", 1)),
		// ─── TBC 300-375 ───
		r("gema_granate_sangre", "Gema cortada: Granate de sangre", "gema_granate_sangre", 300, 310, mat("granate_sangre", 1)),
		r("anillo_sangre_hierro_vil", "Anillo de sangre de hierro vil", "anillo_sangre_hierro_vil", 310, 315, mat("granate_sangre", 1, "barra_hierro_vil", 1)),
		r("espesartita_destellante", "Espesartita de llamas destellante", "espesartita_destellante", 315, 325, mat("espesartita_llamas", 1, "particulas_adamantita", 1)),
		r("adamantita_mercurica", "Adamantita mercúrica", "adamantita_mercurica", 325, 335, mat("particulas_adamantita", 4)),
		r("anillo_adamantita_pesado", "Anillo de adamantita pesado", "anillo_adamantita_pesado", 335, 350, mat("barra_adamantita", 2, "tierra_primigenia", 1)),
		// ─── WotLK 350-450 ───
		r("gema_sangrita", "Gema cortada: Sangrita", "gema_sangrita", 350, 395, mat("sangrita", 1)),
		r("gema_calcedonia", "Gema cortada: Calcedonia", "gema_calcedonia", 350, 395, mat("calcedonia", 1)),
		r("gema_jade_oscuro", "Gema cortada: Jade oscuro", "gema_jade_oscuro", 350, 395, mat("jade_oscuro", 1)),
		r("gema_citrino_enorme", "Gema cortada: Citrino enorme", "gema_citrino_enorme", 350, 395, mat("citrino_enorme", 1)),
		r("gema_cristal_sombras", "Gema cortada: Cristal de sombras", "gema_cristal_sombras", 350, 395, mat("cristal_sombras", 1)),
		r("gema_cristal_sol", "Gema cortada: Cristal de sol", "gema_cristal_sol", 350, 395, mat("cristal_sol", 1)),
		r("amuleto_calcedonia_cristal", "Amuleto de calcedonia de cristal", "amuleto_calcedonia_cristal", 395, 400, mat("calcedonia", 2, "tierra_cristalizada", 1)),
		r("sortija_sangrita", "Sortija de sangrita", "sortija_sangrita", 400, 420, mat("sangrita", 1, "tierra_eterna", 1)),
		r("sortija_guardapiedra", "Sortija guardapiedra", "sortija_guardapiedra", 420, 450, mat("cristal_sol", 2, "tierra_eterna", 1)),
		r("anillo_poder_sombra", "Anillo de poder de sombra", "anillo_poder_sombra", 420, 450, mat("cristal_sombras", 2, "sombra_eterna", 1)),
		r("prisma_helado", "Prisma helado", "prisma_helado", 420, 450, mat("diamante_asedio_tierra", 1, "tierra_eterna", 1, "sombra_eterna", 1)),
		r("sello_onirico", "Sello onírico", "sello_onirico", 420, 450, mat("diamante_llama_celeste", 2, "tierra_eterna", 1, "sombra_eterna", 1)),
	}
	return DefProfesion{
		ID:       "joyeria",
		Nombre:   "Joyería",
		Primaria: true,
		MaxSkill: 450,
		Rangos:   rangos,
		Recetas:  recetas,
	}
}

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
