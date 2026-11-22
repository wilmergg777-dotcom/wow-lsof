// items.go contiene el registro de ítems del juego: materiales de
// profesiones (barras, gemas, piedras, polvos) y los ítems crafteados
// (anillos, colgantes, engarces, gemas cortadas).
//
// Los materiales siguen la guía de Joyería de WoW 3.3.5 (Classic, TBC y
// Wrath of the Lich King). Cada ítem es un dato; añadir materiales nuevos
// es trivial.
package mundo

// Tipos de ítem.
const (
	TipoMaterial    = "material"     // barra, piedra, polvo, componente
	TipoGema        = "gema"         // gema sin cortar (materia prima)
	TipoGemaCortada = "gema_cortada" // gema cortada (producto de joyería)
	TipoAnillo      = "anillo"
	TipoColgante    = "colgante"
	TipoSortija     = "sortija"
	TipoEngarce     = "engarce"     // componente intermedio de joyería
	TipoEstatua     = "estatua"     // estatua de piedra (consumible)
	TipoAmuleto     = "amuleto"
	TipoCollar      = "collar"
	TipoPrisma      = "prisma"
	TipoSello       = "sello"
	// Tipos de Peletería
	TipoArmadura = "armadura" // piezas de cuero/malla
	TipoCapa     = "capa"
	TipoBolsa    = "bolsa"
	TipoRefuerzo = "refuerzo" // parches/mejoras de armadura
)

// Calidades.
const (
	CalidadComun = "comun"
	CalidadRaro  = "raro"
	CalidadEpico = "epico"
)

// DefItem define un ítem del juego.
type DefItem struct {
	ID      string `json:"id"`
	Nombre  string `json:"nombre"`
	Tipo    string `json:"tipo"`
	Calidad string `json:"calidad"`
	Stack   int    `json:"stack"` // tamaño máximo de pila
	Icono   string `json:"icono"`
}

// itemsPredefinidos devuelve el registro de todos los ítems del juego.
// Incluye materiales (consumidos por profesiones) y productos crafteados.
func itemsPredefinidos() map[string]DefItem {
	stk := func(t string) int {
		if t == TipoMaterial || t == TipoGema || t == TipoGemaCortada {
			return 20
		}
		return 1
	}
	def := func(id, nombre, tipo, calidad string) DefItem {
		return DefItem{ID: id, Nombre: nombre, Tipo: tipo, Calidad: calidad, Stack: stk(tipo), Icono: id}
	}
	m := map[string]DefItem{}

	// ─── Materiales Classic ───
	for id, n := range map[string]string{
		"barra_cobre":      "Barra de cobre",
		"piedra_ferrica":   "Piedra férrea",
		"ojo_tigre":        "Ojo de tigre",
		"barra_bronce":     "Barra de bronce",
		"barra_plata":      "Barra de plata",
		"piedra_pesada":    "Piedra pesada",
		"agata_musgosa":    "Ágata musgosa",
		"barra_mitril":     "Barra de mitril",
		"barra_veraplata":  "Barra de veraplata",
		"citrino":          "Citrino",
		"agua_elemental":   "Agua elemental",
		"aguamarina":       "Aguamarina",
		"frasco_mojo":      "Frasco de mojo",
		"barra_torio":      "Barra de torio",
		"rubi_estrella":    "Rubí estrella",
		"opalo_grande":     "Ópalo grande",
		"diamante_azerot":  "Diamante de Azeroth",
		"esmeralda_enorme": "Esmeralda enorme",
		"malaquita":        "Malaquita",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// Las gemas sin cortar son TipoGema.
	for id, n := range map[string]string{
		"ojo_tigre":        "Ojo de tigre",
		"agata_musgosa":    "Ágata musgosa",
		"citrino":          "Citrino",
		"aguamarina":       "Aguamarina",
		"rubi_estrella":    "Rubí estrella",
		"opalo_grande":     "Ópalo grande",
		"diamante_azerot":  "Diamante de Azeroth",
		"esmeralda_enorme": "Esmeralda enorme",
		"malaquita":        "Malaquita",
	} {
		m[id] = def(id, n, TipoGema, CalidadComun)
	}

	// ─── Materiales Burning Crusade ───
	for id, n := range map[string]string{
		"granate_sangre":      "Granate de sangre",
		"barra_hierro_vil":    "Barra de hierro vil",
		"espesartita_llamas":  "Espesartita de llamas",
		"particulas_adamantita": "Partículas de adamantita",
		"tierra_primigenia":   "Tierra primigenia",
		"barra_adamantita":    "Barra de adamantita",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// Granate y espesartita son gemas.
	m["granate_sangre"] = def("granate_sangre", "Granate de sangre", TipoGema, CalidadComun)
	m["espesartita_llamas"] = def("espesartita_llamas", "Espesartita de llamas", TipoGema, CalidadComun)

	// ─── Materiales Wrath of the Lich King ───
	for id, n := range map[string]string{
		"sangrita":              "Sangrita",
		"calcedonia":            "Calcedonia",
		"jade_oscuro":           "Jade oscuro",
		"citrino_enorme":        "Citrino enorme",
		"cristal_sombras":       "Cristal de sombras",
		"cristal_sol":           "Cristal de sol",
		"tierra_cristalizada":   "Tierra cristalizada",
		"tierra_eterna":         "Tierra eterna",
		"sombra_eterna":         "Sombra eterna",
		"diamante_asedio_tierra": "Diamante de asedio de tierra",
		"diamante_llama_celeste": "Diamante de llama celeste",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// Gemas WotLK.
	for _, id := range []string{"sangrita", "calcedonia", "jade_oscuro", "citrino_enorme", "cristal_sombras", "cristal_sol", "diamante_asedio_tierra", "diamante_llama_celeste"} {
		it := m[id]
		it.Tipo = TipoGema
		m[id] = it
	}

	// ─── Productos crafteados de Joyería (Classic 1-300) ───
	crafted := []struct {
		id, nombre, tipo, calidad string
	}{
		{"hilo_cobre_delicado", "Hilo de cobre delicado", TipoEngarce, CalidadComun},
		{"estatua_piedra_ferrica", "Estatua de piedra férrea", TipoEstatua, CalidadComun},
		{"sortija_ojo_tigre", "Sortija de ojo de tigre", TipoSortija, CalidadRaro},
		{"colgante_malaquita", "Colgante de malaquita", TipoColgante, CalidadRaro},
		{"engarce_bronce", "Engarce de bronce", TipoEngarce, CalidadComun},
		{"anillo_bronce_solido", "Anillo de bronce sólido", TipoAnillo, CalidadComun},
		{"anillo_poderio_plata", "Anillo del poderío de la plata", TipoAnillo, CalidadRaro},
		{"estatua_piedra_pesada", "Estatua de piedra pesada", TipoEstatua, CalidadComun},
		{"colgante_escudo_agata", "Colgante del escudo de ágata", TipoColgante, CalidadRaro},
		{"filigrana_mitril", "Filigrana de mitril", TipoEngarce, CalidadComun},
		{"anillo_veraplata_grabado", "Anillo de veraplata grabado", TipoAnillo, CalidadRaro},
		{"anillo_citrino_sanacion", "Anillo de citrino de sanación rápida", TipoAnillo, CalidadRaro},
		{"sello_aguamarina", "Sello de aguamarina", TipoSello, CalidadRaro},
		{"engarce_torio", "Engarce de torio", TipoEngarce, CalidadComun},
		{"colgante_rubi_fuego", "Colgante de rubí de fuego", TipoColgante, CalidadEpico},
		{"anillo_opalo_sencillo", "Anillo de ópalo sencillo", TipoAnillo, CalidadRaro},
		{"anillo_diamante_enfoque", "Anillo de diamante de enfoque", TipoAnillo, CalidadRaro},
		{"sortija_torio_resplandeciente", "Sortija de torio resplandeciente", TipoSortija, CalidadRaro},
		{"anillo_leon_esmeralda", "Anillo de león de esmeralda", TipoAnillo, CalidadEpico},
		// ─── TBC 300-375 ───
		{"gema_granate_sangre", "Gema cortada: Granate de sangre", TipoGemaCortada, CalidadRaro},
		{"anillo_sangre_hierro_vil", "Anillo de sangre de hierro vil", TipoAnillo, CalidadRaro},
		{"espesartita_destellante", "Espesartita de llamas destellante", TipoGemaCortada, CalidadRaro},
		{"adamantita_mercurica", "Adamantita mercúrica", TipoMaterial, CalidadRaro},
		{"anillo_adamantita_pesado", "Anillo de adamantita pesado", TipoAnillo, CalidadRaro},
		// ─── WotLK 350-450 ───
		{"gema_sangrita", "Gema cortada: Sangrita", TipoGemaCortada, CalidadRaro},
		{"gema_calcedonia", "Gema cortada: Calcedonia", TipoGemaCortada, CalidadRaro},
		{"gema_jade_oscuro", "Gema cortada: Jade oscuro", TipoGemaCortada, CalidadRaro},
		{"gema_citrino_enorme", "Gema cortada: Citrino enorme", TipoGemaCortada, CalidadRaro},
		{"gema_cristal_sombras", "Gema cortada: Cristal de sombras", TipoGemaCortada, CalidadRaro},
		{"gema_cristal_sol", "Gema cortada: Cristal de sol", TipoGemaCortada, CalidadRaro},
		{"amuleto_calcedonia_cristal", "Amuleto de calcedonia de cristal", TipoAmuleto, CalidadRaro},
		{"collar_cristal_citrino", "Collar de cristal citrino", TipoCollar, CalidadRaro},
		{"anillo_roca_sol", "Anillo de roca al sol", TipoAnillo, CalidadRaro},
		{"sortija_sangrita", "Sortija de sangrita", TipoSortija, CalidadRaro},
		{"sortija_guardapiedra", "Sortija guardapiedra", TipoSortija, CalidadEpico},
		{"anillo_poder_sombra", "Anillo de poder de sombra", TipoAnillo, CalidadEpico},
		{"prisma_helado", "Prisma helado", TipoPrisma, CalidadEpico},
		{"sello_onirico", "Sello onírico", TipoSello, CalidadEpico},
	}
	for _, c := range crafted {
		m[c.id] = def(c.id, c.nombre, c.tipo, c.calidad)
	}

	// ─── Materiales de Peletería (Classic) ───
	for id, n := range map[string]string{
		"cuero_ligero":          "Cuero ligero",
		"cuero_fino":            "Cuero fino",
		"cuero_pesado":          "Cuero pesado",
		"pellejo_pesado_curado": "Pellejo pesado curado",
		"cuero_grueso":          "Cuero grueso",
		"pellejo_grueso_curado": "Pellejo grueso curado",
		"cuero_basto":           "Cuero basto",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de Peletería (TBC) ───
	// Cuero de pellejo nudoso y grueso son también productos crafteados
	// (recetas intermedias), pero se registran como material.
	for id, n := range map[string]string{
		"restos_cuero_pellejo_nodoso":    "Restos de cuero de pellejo nudoso",
		"cuero_pellejo_nodoso":           "Cuero de pellejo nudoso",
		"escamas_viles":                  "Escamas viles",
		"cuero_pellejo_nodoso_grueso":    "Cuero de pellejo nudoso grueso",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de Peletería (WotLK) ───
	// Cuero boreal pesado es también producto crafteado (receta intermedia).
	for id, n := range map[string]string{
		"cuero_boreal":        "Cuero boreal",
		"agua_cristalizada":   "Agua cristalizada",
		"agua_eterna":         "Agua eterna",
		"orbe_congelado":      "Orbe congelado",
		"quitina_nerubiana":   "Quitina nerubiana",
		"pelaje_artico":       "Pelaje ártico",
		"cuero_boreal_pesado": "Cuero boreal pesado",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de especialización de Peletería ───
	for id, n := range map[string]string{
		"escamas_dragon_desgastadas": "Escamas de dragón desgastadas",
		"corazon_fuego":              "Corazón de fuego",
		"globo_agua":                 "Globo de agua",
		"nucleo_tierra":              "Núcleo de tierra",
		"aliento_viento":             "Aliento de viento",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadRaro)
	}

	// ─── Productos crafteados de Peletería (1-450) ───
	craftedPeleteria := []struct {
		id, nombre, tipo, calidad string
	}{
		// Classic 1-300
		{"complemento_armadura_ligera", "Complemento para armadura ligera", TipoRefuerzo, CalidadComun},
		{"capa_cuero_cosida_mano", "Capa de cuero cosida a mano", TipoCapa, CalidadComun},
		{"guantes_cuero_relieve", "Guantes de cuero en relieve", TipoArmadura, CalidadComun},
		{"cinturon_cuero_refinado", "Cinturón de cuero refinado", TipoArmadura, CalidadComun},
		{"botas_cuero_oscuro", "Botas de cuero oscuro", TipoArmadura, CalidadComun},
		{"pantalones_cuero_oscuro", "Pantalones de cuero oscuro", TipoArmadura, CalidadComun},
		{"guantes_cuero_montanero", "Guantes de cuero de montañero", TipoArmadura, CalidadComun},
		{"complemento_pesado_armadura", "Complemento pesado para armadura", TipoRefuerzo, CalidadComun},
		{"hombreras_barbaricas", "Hombreras barbáricas", TipoArmadura, CalidadRaro},
		{"brazales_oscurecidos", "Brazales oscurecidos", TipoArmadura, CalidadComun},
		{"cinta_nochefugaz", "Cinta Nochefugaz", TipoArmadura, CalidadRaro},
		{"faltriquera_municion_cuero_grueso", "Faltriquera de munición de cuero grueso", TipoBolsa, CalidadComun},
		{"pantalones_nochefugaz", "Pantalones Nochefugaz", TipoArmadura, CalidadRaro},
		{"botas_nochefugaz", "Botas Nochefugaz", TipoArmadura, CalidadRaro},
		{"guanteletes_cuero_maligno", "Guanteletes de cuero maligno", TipoArmadura, CalidadRaro},
		{"brazales_cuero_maligno", "Brazales de cuero maligno", TipoArmadura, CalidadRaro},
		{"cinta_cuero_maligno", "Cinta de cuero maligno", TipoArmadura, CalidadRaro},
		// TBC 300-350
		{"refuerzo_armadura_pellejo_nodoso", "Refuerzo para armadura de pellejo nudoso", TipoRefuerzo, CalidadComun},
		{"jubon_draenico_grueso", "Jubón draénico grueso", TipoArmadura, CalidadRaro},
		{"coraza_escamas_viles", "Coraza de escamas viles", TipoArmadura, CalidadRaro},
		// WotLK 350-450
		{"refuerzo_armadura_boreal", "Refuerzo para armadura boreal", TipoRefuerzo, CalidadComun},
		{"botas_articas", "Botas árticas", TipoArmadura, CalidadRaro},
		{"leotardos_escamas_escarcha_oscuros", "Leotardos de escamas de escarcha oscuros", TipoArmadura, CalidadRaro},
		{"brazales_encapotados", "Brazales encapotados", TipoArmadura, CalidadRaro},
		{"manijas_encapotadas", "Manijas encapotadas", TipoArmadura, CalidadRaro},
		{"armadura_pierna_pellejo_escarcha", "Armadura para pierna de pellejo de escarcha", TipoRefuerzo, CalidadRaro},
		{"coraza_cuero_boreal_pesado", "Coraza de cuero boreal pesado", TipoArmadura, CalidadEpico},
	}
	for _, c := range craftedPeleteria {
		m[c.id] = def(c.id, c.nombre, c.tipo, c.calidad)
	}
	return m
}
