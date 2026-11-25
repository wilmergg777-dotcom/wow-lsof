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
// (p.ej. Peletería dragontina/elemental/tribal, o Herrería forjador de
// armaduras/armas). Se aprende a partir de SkillReq consumiendo Materiales
// (abstracción de la misión de la guía). Las especializaciones pueden
// anidarse: si RequiereEspecializacion != "", solo se puede aprender tras
// haber elegido esa especialización padre (p.ej. Herrería forjador de
// armas → maestro forjador de hachas/martillos/invocador). El estado del
// jugador guarda siempre el ID de la especialización hoja elegida.
type DefEspecializacion struct {
	ID                      string        `json:"id"`
	Nombre                  string        `json:"nombre"`
	SkillReq                int           `json:"skill_req"`
	Descripcion             string        `json:"descripcion"`
	Materiales              []MaterialRec `json:"materiales"`
	RequiereEspecializacion string        `json:"requiere_especializacion,omitempty"` // ID del padre ("" si es de nivel superior)
}

// DefNodo describe un nodo de recurso recolectable en el mundo (nodo de
// hierba, veta de mineral, piel, etc.). Las profesiones de recolección
// (Herboristería, futuras Minería / Desuello) usan Nodos en lugar de
// Recetas: el jugador Recolecta del nodo (sin consumir materiales de la
// bolsa), produce el item del nodo y gana habilidad mientras skill <
// SkillHasta. SkillReq es la habilidad mínima para poder recolectar;
// SkillHasta es el umbral a partir del cual el nodo deja de dar skill
// (equivalente al "verde" de WoW). Zona es la zona recomendada por la
// guía (solo informativo, para el cliente).
type DefNodo struct {
	ID                 string `json:"id"`
	Nombre             string `json:"nombre"`
	ProfesionID        string `json:"profesion_id"`
	Zona               string `json:"zona,omitempty"`
	ResultadoID        string `json:"resultado_id"`
	ResultadoCantidad  int    `json:"resultado_cantidad"`
	SkillReq           int    `json:"skill_req"`
	SkillHasta         int    `json:"skill_hasta"`
}

// DefProfesion define una profesión jugable.
type DefProfesion struct {
	ID             string             `json:"id"`
	Nombre         string             `json:"nombre"`
	Primaria       bool               `json:"primaria"` // true = cuenta para el límite de 2
	MaxSkill       int                `json:"max_skill"`
	Rangos         []DefRango         `json:"rangos"`
	Recetas        []DefReceta        `json:"recetas"`
	Nodos          []DefNodo          `json:"nodos,omitempty"` // profesiones de recolección (Herboristería, etc.)
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
		"alquimia":      profesionAlquimia(),
		"herreria":      profesionHerreria(),
		"ingenieria":    profesionIngenieria(),
		"herboristeria": profesionHerboristeria(),
		"minería":       profesionMineria(),
		"desuello":      profesionDesuello(),
		"inscripción":   profesionInscripcion(),
		"cocina":        profesionCocina(),
		"pesca":         profesionPesca(),
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

// profesionHerreria construye la profesión de Herrería completa (1-450),
// siguiendo la guía de WoW 3.3.5. Consume lingotes y piedras (de minería)
// para crear piezas de armadura, armas, piedras de afilar/pulir y refuerzos.
// Algunas piedras de pulir son a la vez producto y material de recetas
// posteriores (p.ej. la Piedra de pulir sólida se inserta en mitad de la
// banda de los Brazales de escamas de oro). 6 rangos, 38 recetas y un árbol
// de especializaciones anidado de dos niveles: Forjador de armaduras /
// Forjador de armas (nivel superior, skill 200) y, bajo este último,
// Maestro forjador de hachas / martillos / invocador (skill 225).
func profesionHerreria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz herrero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial herrero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto herrero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Herrero artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro herrero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro herrero", SkillReq: 350, SkillMax: 450},
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
			ID: id, Nombre: nombre, ProfesionID: "herreria",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		// Piedras de afilar/pulir (algunas son material de recetas posteriores).
		r("piedra_afilar_basta", "Piedra de afilar basta", "piedra_afilar_basta", 0, 25, mat("piedra_basta", 1)),
		r("piedra_pulir_basta", "Piedra de pulir basta", "piedra_pulir_basta", 25, 65, mat("piedra_basta", 1)),
		r("piedra_afilar_burda", "Piedra de afilar burda", "piedra_afilar_burda", 65, 75, mat("piedra_burda", 1)),
		r("piedra_pulir_burda", "Piedra de pulir burda", "piedra_pulir_burda", 75, 100, mat("piedra_burda", 1)),
		// Vara de plata: produce el item vara_plata (compartido con Encantamiento).
		r("vara_plata_herreria", "Vara de plata", "vara_plata", 100, 105, mat("lingote_plata", 1)),
		r("leotardos_bronce_basto", "Leotardos de bronce basto", "leotardos_bronce_basto", 105, 125, mat("lingote_bronce", 6)),
		r("piedra_pulir_pesada", "Piedra de pulir pesada", "piedra_pulir_pesada", 125, 150, mat("piedra_pesada", 3)),
		// Vara de oro: produce el item vara_dorado (compartido con Encantamiento).
		r("vara_oro_herreria", "Vara de oro", "vara_dorado", 150, 155, mat("lingote_oro", 1)),
		r("leotardos_hierro_verde", "Leotardos de hierro verde", "leotardos_hierro_verde", 155, 165, mat("lingote_hierro", 4, "tela_paño_mágico", 1)),
		r("brazales_hierro_verde", "Brazales de hierro verde", "brazales_hierro_verde", 165, 185, mat("lingote_hierro", 2)),
		// Brazales de escamas de oro: banda 185-215 interrumpida por la
		// Piedra de pulir sólida (200-210) en mitad, como en la guía.
		r("brazales_escamas_oro", "Brazales de escamas de oro", "brazales_escamas_oro", 185, 215, mat("lingote_acero", 5)),
		r("piedra_pulir_sólida", "Piedra de pulir sólida", "piedra_pulir_sólida", 200, 210, mat("piedra_sólida", 3)),
		// Yelmo de placas de acero: banda 215-235 que cruza el límite
		// experto→artesano (se aprende artesano a 225 entre medias).
		r("yelmo_placas_acero", "Yelmo de placas de acero", "yelmo_placas_acero", 215, 235, mat("lingote_acero", 8)),
		r("almofar_mitril", "Almófar de mitril", "almofar_mitril", 235, 250, mat("lingote_mitril", 4)),
		r("piedra_afilar_densa", "Piedra de afilar densa", "piedra_afilar_densa", 250, 260, mat("piedra_densa", 1)),
		r("brazales_torio", "Brazales de torio", "brazales_torio", 260, 275, mat("lingote_torio", 4)),
		r("brazales_placas_imperiales", "Brazales de placas imperiales", "brazales_placas_imperiales", 275, 295, mat("lingote_torio", 8)),
		r("botas_torio", "Botas de torio", "botas_torio", 295, 300, mat("lingote_torio", 8)),
		// ─── TBC 300-350 ───
		r("almofar_anillas_hierro_vil", "Almófar de anillas de hierro vil", "almofar_anillas_hierro_vil", 300, 315, mat("barra_hierro_vil", 4)),
		r("guantes_anillas_hierro_vil", "Guantes de anillas de hierro vil", "guantes_anillas_hierro_vil", 315, 320, mat("barra_hierro_vil", 4)),
		r("brazales_anillas_hierro_vil", "Brazales de anillas de hierro vil", "brazales_anillas_hierro_vil", 320, 325, mat("barra_hierro_vil", 4)),
		r("runa_amparo_inferior", "Runa de amparo inferior", "runa_amparo_inferior", 325, 330, mat("barra_hierro_vil", 1)),
		r("coraza_hierro_vil", "Coraza de hierro vil", "coraza_hierro_vil", 330, 340, mat("barra_hierro_vil", 4)),
		r("resguardo_escudo_inferior", "Resguardo de escudo inferior", "resguardo_escudo_inferior", 340, 350, mat("barra_hierro_vil", 2)),
		// ─── WotLK 350-450 ───
		r("botas_cobalto", "Botas de cobalto", "botas_cobalto", 350, 360, mat("barra_cobalto", 2)),
		r("escudo_triangular_cobalto", "Escudo triangular de cobalto", "escudo_triangular_cobalto", 360, 370, mat("barra_cobalto", 3)),
		r("quijotes_cobalto", "Quijotes de cobalto", "quijotes_cobalto", 370, 375, mat("barra_cobalto", 4)),
		r("guantesletes_cobalto", "Guantesletes de cobalto", "guantesletes_cobalto", 375, 380, mat("barra_cobalto", 2)),
		r("botas_cobalto_con_púas", "Botas de cobalto con púas", "botas_cobalto_con_púas", 380, 385, mat("barra_cobalto", 3, "cuero_basto", 1)),
		r("hombreras_cobalto_con_púas", "Hombreras de cobalto con púas", "hombreras_cobalto_con_púas", 385, 390, mat("barra_cobalto", 3, "cuero_basto", 1)),
		r("hacha_guerra_cobalto_dentada", "Hacha de guerra de cobalto dentada", "hacha_guerra_cobalto_dentada", 390, 395, mat("barra_cobalto", 4, "cuero_basto", 1)),
		r("cinturón_saronita_brillante", "Cinturón de saronita brillante", "cinturón_saronita_brillante", 395, 400, mat("barra_de_saronita", 2, "tierra_eterna", 1)),
		r("yelmo_cobalto_cuernudo", "Yelmo de cobalto cuernudo", "yelmo_cobalto_cuernudo", 400, 405, mat("barra_cobalto", 4, "cuero_basto", 1)),
		r("daga_saronita_mortal", "Daga de saronita mortal", "daga_saronita_mortal", 405, 416, mat("barra_de_saronita", 3)),
		r("hebilla_cinturón_eterna", "Hebilla de cinturón eterna", "hebilla_cinturón_eterna", 416, 425, mat("barra_de_saronita", 4, "tierra_eterna", 1, "aire_cristalizado", 1)),
		r("cadena_arma_titanio", "Cadena de arma de titanio", "cadena_arma_titanio", 425, 430, mat("titanio", 2, "sombra_eterna", 1)),
		r("guampolas_imponentes", "Guampolas imponentes", "guampolas_imponentes", 430, 435, mat("barra_de_saronita", 8, "tierra_eterna", 1, "sombra_eterna", 1)),
		r("quijotes_imponentes", "Quijotes imponentes", "quijotes_imponentes", 435, 450, mat("barra_de_saronita", 14, "tierra_eterna", 2, "agua_eterna", 1)),
	}
	especializaciones := []DefEspecializacion{
		// Nivel superior (skill 200): elegir una de las dos ramas.
		{
			ID: "armaduras", Nombre: "Forjador de armaduras", SkillReq: 200,
			Descripcion: "Maestría en armaduras de placas; recetas exclusivas de pecho, piernas y botas.",
			Materiales: mat(
				"yelmo_mitril_ornamentado", 4,
				"botas_mitril_ornamentadas", 2,
				"peto_mitril_ornamentado", 1,
			),
		},
		{
			ID: "armas", Nombre: "Forjador de armas", SkillReq: 200,
			Descripcion: "Maestría en armas; desbloquea tres sub-maestrías (hachas, martillos, invocador).",
			Materiales: mat(
				"sable_acero_lunar", 4,
				"maza_negra_grande", 2,
				"hacha_mitril_pesado", 2,
				"hacha_hierro_macizo", 4,
			),
		},
		// Nivel inferior (skill 225): requieren ser Forjador de armas.
		{
			ID: "hachas", Nombre: "Maestro forjador de hachas", SkillReq: 225,
			Descripcion: "Recetas exclusivas de hachas (p.ej. Filo del Alba).",
			Materiales: mat("piedra_serpiente_voshgajin", 1),
			RequiereEspecializacion: "armas",
		},
		{
			ID: "martillos", Nombre: "Maestro forjador de martillos", SkillReq: 225,
			Descripcion: "Recetas exclusivas de mazas (p.ej. Martillo de batalla encantado).",
			Materiales: mat("delantal_herrero_martillos_carmesi", 1),
			RequiereEspecializacion: "armas",
		},
		{
			ID: "invocador", Nombre: "Maestro invocador", SkillReq: 225,
			Descripcion: "Recetas exclusivas de espadas y estoques (p.ej. Estoque llameante).",
			Materiales: mat("insignia_guarda_negra", 1),
			RequiereEspecializacion: "armas",
		},
	}
	return DefProfesion{
		ID:               "herreria",
		Nombre:           "Herrería",
		Primaria:         true,
		MaxSkill:         450,
		Rangos:           rangos,
		Recetas:          recetas,
		Especializaciones: especializaciones,
	}
}

// profesionIngenieria construye la profesión de Ingeniería completa
// (1-450), siguiendo la guía de WoW 3.3.5. Su rasgo distintivo son las
// cadenas de productos intermedios: pólvoras → bombas, tornillos →
// bombas/mosquetes, tubos → mosquetes/gafas/gadgets, envolturas → bombas y
// capacitor → señuelos. Muchos intermedios son a la vez producto y material
// de recetas posteriores (p.ej. el Overcharged Capacitor se consume en el
// Señuelo explosivo). El escalón TBC 300-310 fabrica en masa tres
// intermedios (envoltura, tornillos y pólvora elemental): la envoltura da
// los 10 puntos de skill y los otros dos son recetas "pure-material"
// (SkillReq == SkillHasta, nunca dan skill) que se craftean solo como
// material. 6 rangos, 42 recetas y 2 especializaciones (Goblin / Gnómica).
func profesionIngenieria() DefProfesion {
	rangos := []DefRango{
		{ID: "aprendiz", Nombre: "Aprendiz ingeniero", SkillReq: 0, SkillMax: 75},
		{ID: "oficial", Nombre: "Oficial ingeniero", SkillReq: 50, SkillMax: 150},
		{ID: "experto", Nombre: "Experto ingeniero", SkillReq: 125, SkillMax: 225},
		{ID: "artesano", Nombre: "Ingeniero artesano", SkillReq: 200, SkillMax: 300},
		{ID: "maestro", Nombre: "Maestro ingeniero", SkillReq: 275, SkillMax: 375},
		{ID: "gran_maestro", Nombre: "Gran Maestro ingeniero", SkillReq: 350, SkillMax: 450},
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
			ID: id, Nombre: nombre, ProfesionID: "ingenieria",
			ResultadoID: resultado, ResultadoCantidad: 1,
			Materiales: mats, SkillReq: req, SkillHasta: hasta,
		}
	}
	recetas := []DefReceta{
		// ─── Classic 1-300 ───
		// Aprendiz 0-75: pólvora y tornillos (intermedios) → tubo → trabuco.
		r("pólvora_basta", "Pólvora basta", "pólvora_basta", 0, 40, mat("piedra_basta", 1)),
		r("tornillos_cobre", "Puñado de tornillos de cobre", "tornillos_cobre", 40, 54, mat("lingote_cobre", 1)),
		r("llave_arcoluz", "Llave inglesa Arcoluz", "llave_arcoluz", 54, 55, mat("lingote_cobre", 6)),
		r("tubo_cobre", "Tubo de cobre", "tubo_cobre", 55, 65, mat("lingote_cobre", 1)),
		r("trabuco_basto", "Trabuco basto", "trabuco_basto", 65, 75, mat("tubo_cobre", 1, "pólvora_basta", 1)),
		// Oficial 75-150: pólvora burda → bombas de bronce.
		r("pólvora_burda", "Pólvora burda", "pólvora_burda", 75, 95, mat("piedra_burda", 1)),
		r("contacto_plata", "Contacto de plata", "contacto_plata", 95, 105, mat("lingote_plata", 1)),
		r("tubo_bronce", "Tubo de bronce", "tubo_bronce", 105, 120, mat("lingote_bronce", 1)),
		r("bomba_bronce_pequeña", "Bomba de bronce pequeña", "bomba_bronce_pequeña", 120, 125, mat("tubo_bronce", 1, "tornillos_cobre", 1, "pólvora_burda", 1, "paño_lana", 1)),
		r("pólvora_pesada", "Pólvora pesada", "pólvora_pesada", 125, 145, mat("piedra_pesada", 1)),
		r("bomba_bronce_grande", "Bomba de bronce grande", "bomba_bronce_grande", 145, 150, mat("tubo_bronce", 1, "pólvora_pesada", 2, "paño_lana", 1)),
		// Experto 150-225: fuego artificial, pólvora sólida → bomba de hierro,
		// tubo de mitril, disparador, balas.
		r("fuego_artificial_rojo", "Fuego artificial rojo", "fuego_artificial_rojo", 150, 175, mat("cuero_pesado", 1, "piedra_sólida", 1)),
		r("microajustador_giromático", "Microajustador giromático", "microajustador_giromático", 175, 176, mat("lingote_acero", 4)),
		r("pólvora_sólida", "Pólvora sólida", "pólvora_sólida", 176, 190, mat("piedra_sólida", 1)),
		r("bomba_hierro_grande", "Bomba de hierro grande", "bomba_hierro_grande", 190, 195, mat("lingote_hierro", 1, "pólvora_sólida", 2, "paño_lana", 1)),
		r("tubo_mitril", "Tubo de mitril", "tubo_mitril", 195, 205, mat("lingote_mitril", 1)),
		r("disparador_inestable", "Disparador inestable", "disparador_inestable", 205, 210, mat("lingote_mitril", 1, "pólvora_sólida", 1, "tela_paño_mágico", 1)),
		r("balas_mitril_gran_impacto", "Balas de mitril de gran impacto", "balas_mitril_gran_impacto", 210, 225, mat("lingote_mitril", 2)),
		// Artesano 225-300: envoltura → bomba de gran carga, pólvora densa →
		// trastos de torio, tubo de torio.
		r("envoltura_mitril", "Envoltura de mitril", "envoltura_mitril", 225, 235, mat("lingote_mitril", 3)),
		r("bomba_gran_carga", "Bomba de gran carga", "bomba_gran_carga", 235, 245, mat("envoltura_mitril", 1, "pólvora_sólida", 1)),
		r("girotiro_mitril", "Girotiro de mitril", "girotiro_mitril", 245, 250, mat("lingote_mitril", 1, "pólvora_sólida", 1)),
		r("pólvora_densa", "Pólvora densa", "pólvora_densa", 250, 260, mat("piedra_densa", 1)),
		r("trastos_wow_torio", "Trastos wow de torio", "trastos_wow_torio", 260, 290, mat("lingote_torio", 1, "pólvora_densa", 1, "paño_rúnico", 1)),
		r("tubo_torio", "Tubo de torio", "tubo_torio", 290, 300, mat("lingote_torio", 2)),
		// ─── TBC 300-350 ───
		// Escalón 300-310: fabricación en masa de tres intermedios. La
		// envoltura da los 10 puntos de skill; los tornillos y la pólvora
		// elemental son recetas "pure-material" (SkillReq == SkillHasta:
		// nunca dan skill, se craftean solo como material para las bombas,
		// el mosquete y la bengala).
		r("envoltura_hierro_vil", "Envoltura de hierro vil", "envoltura_hierro_vil", 300, 310, mat("barra_hierro_vil", 3)),
		r("tornillos_hierro_vil", "Puñado de tornillos de hierro vil", "tornillos_hierro_vil", 300, 300, mat("barra_hierro_vil", 1)),
		r("pólvora_elemental", "Pólvora elemental", "pólvora_elemental", 300, 300, mat("barra_hierro_vil", 1)),
		r("bomba_hierro_vil", "Bomba de hierro vil", "bomba_hierro_vil", 310, 320, mat("envoltura_hierro_vil", 1, "tornillos_hierro_vil", 2, "pólvora_elemental", 1)),
		r("mosquete_hierro_vil", "Mosquete de hierro vil", "mosquete_hierro_vil", 320, 335, mat("envoltura_hierro_vil", 1, "tornillos_hierro_vil", 2, "pólvora_elemental", 1)),
		r("bengala_humo_blanco", "Bengala de humo blanco", "bengala_humo_blanco", 335, 350, mat("tornillos_hierro_vil", 1, "paño_tejido_abisal", 1, "pólvora_elemental", 1)),
		// ─── WotLK 350-450 ───
		// 350-375: prep de tornillos de cobalto y gatillo volátil.
		r("tornillos_cobalto", "Puñado de tornillos de cobalto", "tornillos_cobalto", 350, 360, mat("barra_cobalto", 1)),
		r("gatillo_explosivo_volátil", "Gatillo explosivo volátil", "gatillo_explosivo_volátil", 360, 375, mat("barra_cobalto", 1)),
		// El Capacitor sobrecargado es producto Y material (se consume en el
		// Señuelo explosivo).
		r("capacitor_sobrecargado", "Capacitor sobrecargado", "capacitor_sobrecargado", 375, 385, mat("barra_cobalto", 2, "fuego_cristalizado", 1)),
		r("señuelo_explosivo", "Señuelo explosivo", "señuelo_explosivo", 385, 390, mat("capacitor_sobrecargado", 1, "paño_escarcha", 1)),
		// El Tubo de acero frío es intermedio de scope, soldador, inyector,
		// gafas y máquina de ruido.
		r("tubo_acero_frío", "Tubo de acero frío", "tubo_acero_frío", 390, 400, mat("barra_cobalto", 2)),
		r("mira_refractora_diamante", "Mira refractora de corte diamante", "mira_refractora_diamante", 400, 405, mat("tubo_acero_frío", 1, "barra_de_saronita", 1)),
		r("caja_de_bombas", "Caja de bombas", "caja_de_bombas", 405, 410, mat("gatillo_explosivo_volátil", 1, "barra_de_saronita", 2)),
		r("soldador_rayo_goblin", "Soldador de rayo goblin", "soldador_rayo_goblin", 410, 415, mat("tubo_acero_frío", 1, "barra_de_saronita", 2, "tierra_eterna", 1)),
		r("kit_inyector_mana", "Kit inyector de maná", "kit_inyector_mana", 415, 425, mat("tubo_acero_frío", 1, "agua_cristalizada", 2)),
		r("gafas_nieve_mecanizadas", "Gafas de nieve mecanizadas", "gafas_nieve_mecanizadas", 425, 430, mat("tubo_acero_frío", 1, "barra_de_saronita", 2)),
		r("máquina_ruido", "Máquina de ruido", "máquina_ruido", 430, 435, mat("tubo_acero_frío", 1, "barra_de_saronita", 2, "tierra_cristalizada", 1)),
		r("navaja_ejército_gnómica", "Navaja del ejército gnómico", "navaja_ejército_gnómica", 435, 450, mat("barra_de_saronita", 2, "tornillos_cobalto", 1)),
	}
	especializaciones := []DefEspecializacion{
		// Binaria (sin padre): Goblin o Gnómica, skill 200.
		{
			ID: "goblin", Nombre: "Ingeniería goblin", SkillReq: 200,
			Descripcion: "Maestría en explosivos: bombas potentes, cohetes y petardos.",
			Materiales: mat(
				"bomba_hierro_grande", 20,
				"dinamita_sólida", 20,
				"oveja_explosiva", 5,
			),
		},
		{
			ID: "gnómica", Nombre: "Ingeniería gnómica", SkillReq: 200,
			Descripcion: "Maestría en gadgets: dispositivos, trampas y útiles de cabeza.",
			Materiales: mat(
				"tubo_mitril", 6,
				"mira_precisión", 1,
				"muñeco_diana_avanzado", 2,
			),
		},
	}
	return DefProfesion{
		ID:               "ingenieria",
		Nombre:           "Ingeniería",
		Primaria:         true,
		MaxSkill:         450,
		Rangos:           rangos,
		Recetas:          recetas,
		Especializaciones: especializaciones,
	}
}

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
