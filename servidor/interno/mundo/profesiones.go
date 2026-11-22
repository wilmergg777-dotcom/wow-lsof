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
}

// MaterialRec es un material requerido por una receta.
type MaterialRec struct {
	ItemID   string `json:"item_id"`
	Cantidad int    `json:"cantidad"`
}

// DefProfesion define una profesión jugable.
type DefProfesion struct {
	ID        string      `json:"id"`
	Nombre    string      `json:"nombre"`
	Primaria  bool        `json:"primaria"` // true = cuenta para el límite de 2
	MaxSkill  int         `json:"max_skill"`
	Rangos    []DefRango  `json:"rangos"`
	Recetas   []DefReceta `json:"recetas"`
}

// EstadoProfesion es el estado de una profesión que aprendió un jugador.
// Se persiste con el personaje.
type EstadoProfesion struct {
	ProfesionID       string   `json:"profesion_id"`
	Skill             int      `json:"skill"`
	RangosAprendidos  []string `json:"rangos_aprendidos"`
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
		"joyeria": profesionJoyeria(),
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
