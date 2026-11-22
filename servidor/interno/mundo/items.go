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
	// Tipos de Sastrería
	TipoCamisa = "camisa" // prendas decorativas
	// Tipos de Encantamiento
	TipoEncantamiento = "encantamiento" // pergaminos de encantamiento aplicables a ranuras
	TipoVara          = "vara"           // varas rúnicas encantadoras (herramienta + material encadenado)
	TipoAceite        = "aceite"         // aceites de zahorí (recubrimiento temporal de arma)
	// Tipos de Alquimia
	TipoPoción = "poción" // consumibles de un solo uso (sanación, maná, efectos)
	TipoElixir = "elixir" // consumibles con efecto duradero (batalla/guardián)
	TipoFrasco = "frasco" // consumibles potentes que cuentan como elixir de batalla y guardián
	// Tipos de Herrería
	TipoArma = "arma" // armas crafteadas (hachas, mazas, espadas, dagas)
	// Tipos de Ingeniería
	TipoExplosivo = "explosivo" // bombas, dinamita, fuegos artificiales, bengalas, señuelos
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

	// ─── Materiales de Sastrería (Classic) ───
	for id, n := range map[string]string{
		"paño_lino":     "Paño de lino",
		"paño_lana":     "Paño de lana",
		"paño_seda":     "Paño de seda",
		"paño_mágico":   "Tela de paño mágico",
		"paño_rúnico":   "Paño rúnico",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de Sastrería (TBC) ───
	// madeja_tejido_abisal y su imbuido son también productos crafteados
	// (recetas intermedias), pero se registran como material.
	for id, n := range map[string]string{
		"paño_tejido_abisal":            "Paño de tejido abisal",
		"polvo_arcano":                  "Polvo Arcano",
		"madeja_tejido_abisal":          "Madeja de tejido abisal",
		"madeja_tejido_abisal_imbuido":  "Madeja de tejido abisal imbuido",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de Sastrería (WotLK) ───
	// madeja_escarcha y su imbuido son también productos crafteados.
	for id, n := range map[string]string{
		"tela_escarcha":                "Tela de tejido de Escarcha",
		"polvo_infinito":               "Polvo infinito",
		"madeja_escarcha":              "Madeja de tejido de Escarcha",
		"madeja_escarcha_imbuido":      "Madeja de tejido de Escarcha imbuido",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de especialización de Sastrería ───
	for id, n := range map[string]string{
		"tela_lunar_primigenia":        "Tela lunar primigenia",
		"esencia_anima_abisal":         "Esencia de ánima abisal",
		"cristal_sombras_profundas":    "Cristal de sombras profundas",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadRaro)
	}

	// ─── Productos crafteados de Sastrería (1-450) ───
	// Las descargas/madejas intermedias son materiales registrados arriba;
	// aquí van las prendas, capas, camisas y bolsas finales.
	craftedSastreria := []struct {
		id, nombre, tipo, calidad string
	}{
		// Classic 1-300
		{"camisa_lino_roja", "Camisa de lino roja", TipoCamisa, CalidadComun},
		{"manteo_lino_reforzado", "Manteo de lino reforzado", TipoCapa, CalidadComun},
		{"camisa_lana_gris", "Camisa de lana gris", TipoCamisa, CalidadComun},
		{"hombreras_lana_doble_pespunte", "Hombreras de lana con doble pespunte", TipoArmadura, CalidadComun},
		{"caperuza_seda_azur", "Caperuza de seda azur", TipoArmadura, CalidadComun},
		{"cinta_seda", "Cinta de seda", TipoArmadura, CalidadComun},
		{"camisa_blanca_formal", "Camisa blanca formal", TipoCamisa, CalidadComun},
		{"jubon_seda_carmesi", "Jubón de seda carmesí", TipoArmadura, CalidadRaro},
		{"pantalones_bombacho_seda_carmesi", "Pantalones bombacho de seda carmesí", TipoArmadura, CalidadRaro},
		{"leotardos_paño_mágico_negro", "Leotardos de paño mágico negro", TipoArmadura, CalidadRaro},
		{"guantes_paño_mágico_negro", "Guantes de paño mágico negro", TipoArmadura, CalidadRaro},
		{"cinta_negra_paño_mágico", "Cinta negra paño mágico", TipoArmadura, CalidadRaro},
		{"cinturon_paño_rúnico", "Cinturón de paño rúnico", TipoArmadura, CalidadRaro},
		{"guantes_paño_rúnico", "Guantes de paño rúnico", TipoArmadura, CalidadRaro},
		{"bolsa_paño_rúnico", "Bolsa de paño rúnico", TipoBolsa, CalidadRaro},
		// TBC 300-350
		{"toga_tejido_abisal", "Toga de tejido abisal", TipoArmadura, CalidadRaro},
		// WotLK 350-450
		{"cinturon_tejido_escarcha", "Cinturón tejido con Escarcha", TipoArmadura, CalidadRaro},
		{"botas_tejidas_escarcha", "Botas tejidas con Escarcha", TipoArmadura, CalidadRaro},
		{"capucha_tejida_escarcha", "Capucha tejida con Escarcha", TipoArmadura, CalidadRaro},
		{"cinturon_tejido_alba", "Cinturón de tejido del alba", TipoArmadura, CalidadRaro},
		{"cubremuñecas_tejido_alba", "Cubremuñecas de tejido del alba", TipoArmadura, CalidadRaro},
		{"guantes_tejido_alba", "Guantes de tejido del alba", TipoArmadura, CalidadRaro},
		{"botas_tejido_alba", "Botas de tejido del alba", TipoArmadura, CalidadRaro},
		{"bolsa_tejido_escarcha", "Bolsa de tejido de Escarcha", TipoBolsa, CalidadRaro},
		{"toga_tejido_hechizos", "Toga de tejido de hechizos", TipoArmadura, CalidadEpico},
		{"guantes_velo_lunar", "Guantes de velo lunar", TipoArmadura, CalidadEpico},
		{"guantes_tejido_ebano", "Guantes de tejido de ébano", TipoArmadura, CalidadEpico},
	}
	for _, c := range craftedSastreria {
		m[c.id] = def(c.id, c.nombre, c.tipo, c.calidad)
	}

	// ─── Materiales de Encantamiento (Classic) ───
	// Polvos, esencias, fragmentos y gemas/perlas obtenidos al desencantar.
	for id, n := range map[string]string{
		"polvo_extraño":              "Polvo extraño",
		"esencia_mágica_inferior":    "Esencia mágica inferior",
		"esencia_mágica_superior":    "Esencia mágica superior",
		"esencia_astral_inferior":    "Esencia astral inferior",
		"polvo_alma":                 "Polvo de alma",
		"esencia_astral_superior":    "Esencia astral superior",
		"esencia_mística_inferior":   "Esencia mística inferior",
		"polvo_visión":               "Polvo de visión",
		"esencia_mística_superior":   "Esencia mística superior",
		"polvo_onírico":              "Polvo onírico",
		"esencia_abisal_superior":    "Esencia abisal superior",
		"polvo_ilusión":              "Polvo de ilusión",
		"esencia_eterna_superior":    "Esencia eterna superior",
		"fragmento_luminoso_pequeño": "Fragmento luminoso pequeño",
		"fragmento_luminoso_grande":  "Fragmento luminoso grande",
		"gema_sombras":               "Gema de las Sombras",
		"perla_iridiscente":          "Perla iridiscente",
		"perla_negra":                "Perla negra",
		"perla_oro":                  "Perla de oro",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de Encantamiento (TBC) ───
	// polvo_arcano ya existe (Sastrería). Las varas de adamantita/hierro
	// vil/etc. son productos de herrería; aquí se registran como material.
	for id, n := range map[string]string{
		"esencia_bidimensional_superior":  "Esencia bidimensional superior",
		"vid_pesadilla":                   "Vid pesadilla",
		"fragmento_centelleante_grande":   "Fragmento centelleante grande",
		"poderío_primigenio":              "Poderío primigenio",
		"vara_adamantita":                 "Vara de adamantita",
		"vara_hierro_vil":                 "Vara de hierro vil",
		"vara_arcanita":                   "Vara de arcanita",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de Encantamiento (WotLK) ───
	// polvo_infinito ya existe (Sastrería).
	for id, n := range map[string]string{
		"esencia_cósmica_superior": "Esencia cósmica superior",
		"fragmento_onírico":        "Fragmento onírico",
		"tierra_eterna":            "Tierra eterna",
		"agua_cristalizada":        "Agua cristalizada",
		"vara_titanio":             "Vara de titanio",
		"vara_eternio":             "Vara de eternio",
		"vara_veraplata":           "Vara de veraplata",
		"vara_dorado":              "Vara dorada",
		"vara_plata":               "Vara de plata",
		"vara_cobre":               "Vara de cobre",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// fragmento_abisal es un material de alto nivel que también se craftea
	// (receta 445-447); se registra como material aquí.
	m["fragmento_abisal"] = def("fragmento_abisal", "Fragmento abisal", TipoMaterial, CalidadRaro)

	// ─── Productos crafteados de Encantamiento (1-450) ───
	// 9 varas rúnicas (encadenadas: cada una consume la anterior) + 32
	// encantamientos + 1 aceite de zahorí.
	craftedEncantamiento := []struct {
		id, nombre, tipo, calidad string
	}{
		// Varas rúnicas (cadena)
		{"vara_cobre_rúnico", "Vara de cobre rúnico", TipoVara, CalidadComun},
		{"vara_rúnica_plateada", "Vara rúnica plateada", TipoVara, CalidadComun},
		{"vara_rúnica_dorada", "Vara rúnica dorada", TipoVara, CalidadComun},
		{"vara_veraplata_runas", "Vara de veraplata con runas", TipoVara, CalidadRaro},
		{"vara_arcanita_rúnica", "Vara de arcanita rúnica", TipoVara, CalidadRaro},
		{"vara_hierro_vil_rúnica", "Vara rúnica de hierro vil", TipoVara, CalidadRaro},
		{"vara_adamantita_rúnica", "Vara rúnica de adamantita", TipoVara, CalidadRaro},
		{"vara_eternio_rúnica", "Vara rúnica de eternio", TipoVara, CalidadRaro},
		{"vara_titanio_rúnica", "Vara rúnica de titanio", TipoVara, CalidadEpico},
		// Aceite de zahorí
		{"aceite_zahorí_excelente", "Aceite de zahorí excelente", TipoAceite, CalidadComun},
		// Encantamientos Classic 1-300
		{"encanto_brazal_salud_menor", "Encantar brazal: salud menor", TipoEncantamiento, CalidadComun},
		{"encanto_brazal_desvío_menor", "Encantar brazal: desvío menor", TipoEncantamiento, CalidadComun},
		{"encanto_brazal_aguante_menor", "Encantar brazal: aguante menor", TipoEncantamiento, CalidadComun},
		{"encanto_brazal_agilidad_menor", "Encantar brazal: agilidad menor", TipoEncantamiento, CalidadComun},
		{"encanto_escudo_aguante_menor", "Encantar escudo: aguante menor", TipoEncantamiento, CalidadComun},
		{"encanto_brazal_aguante_inferior", "Encantar brazal: aguante inferior", TipoEncantamiento, CalidadComun},
		{"encanto_escudo_aguante_inferior", "Encantar escudo: aguante inferior", TipoEncantamiento, CalidadComun},
		{"encanto_brazal_espíritu", "Encantar brazal: espíritu", TipoEncantamiento, CalidadComun},
		{"encanto_brazal_fuerza", "Encantar brazal: fuerza", TipoEncantamiento, CalidadComun},
		{"encanto_capa_defensa_superior", "Encantar capa: defensa superior", TipoEncantamiento, CalidadComun},
		{"encanto_guantes_agilidad", "Encantar guantes: agilidad", TipoEncantamiento, CalidadComun},
		{"encanto_pechera_salud_excelente", "Encantar pechera: salud excelente", TipoEncantamiento, CalidadComun},
		{"encanto_brazal_fuerza_superior", "Encantar brazal: fuerza superior", TipoEncantamiento, CalidadRaro},
		{"encanto_escudo_aguante_superior", "Encantar escudo: aguante superior", TipoEncantamiento, CalidadRaro},
		{"encanto_capa_defensa_excelente", "Encantar capa: defensa excelente", TipoEncantamiento, CalidadRaro},
		// Encantamientos TBC 300-350
		{"encanto_brazal_asalto", "Encantar brazal: asalto", TipoEncantamiento, CalidadRaro},
		{"encanto_brazal_lozanía", "Encantar brazal: lozanía", TipoEncantamiento, CalidadRaro},
		{"encanto_capa_armadura_sublime", "Encantar capa: armadura sublime", TipoEncantamiento, CalidadRaro},
		{"encanto_pechera_espíritu_sublime", "Encantar pechera: espíritu sublime", TipoEncantamiento, CalidadRaro},
		{"encanto_escudo_aguante_sublime", "Encantar escudo: aguante sublime", TipoEncantamiento, CalidadRaro},
		{"encanto_guantes_fuerza_sublime", "Encantar guantes: fuerza sublime", TipoEncantamiento, CalidadRaro},
		// Encantamientos WotLK 350-450
		{"encanto_capa_velocidad", "Encantar capa: velocidad", TipoEncantamiento, CalidadRaro},
		{"encanto_brazales_golpear", "Encantar brazales: golpear", TipoEncantamiento, CalidadRaro},
		{"encanto_brazales_intelecto_excepcional", "Encantar brazales: intelecto excepcional", TipoEncantamiento, CalidadRaro},
		{"encanto_botas_caminante_hielo", "Encantar botas: caminante de hielo", TipoEncantamiento, CalidadRaro},
		{"encanto_capa_agilidad_excelente", "Encantar capa: agilidad excelente", TipoEncantamiento, CalidadRaro},
		{"encanto_guantes_pericia", "Encantar guantes: pericia", TipoEncantamiento, CalidadRaro},
		{"encanto_botas_espíritu_superior", "Encantar botas: espíritu superior", TipoEncantamiento, CalidadRaro},
		{"encanto_escudo_defensa", "Encantar escudo: defensa", TipoEncantamiento, CalidadRaro},
		{"encanto_capa_armadura_poderosa", "Encantar capa: Armadura poderosa", TipoEncantamiento, CalidadRaro},
		{"encanto_guantes_armero", "Encantar guantes: armero", TipoEncantamiento, CalidadRaro},
		{"encanto_botas_asalto_superior", "Encantar botas: asalto superior", TipoEncantamiento, CalidadEpico},
	}
	for _, c := range craftedEncantamiento {
		m[c.id] = def(c.id, c.nombre, c.tipo, c.calidad)
	}

	// ─── Hierbas y materiales de Alquimia (Classic) ───
	for id, n := range map[string]string{
		"flor_de_paz":             "Flor de paz",
		"hojaplata":               "Hojaplata",
		"brezospina":              "Brezospina",
		"hierba_cardenal":         "Hierba cardenal",
		"marregal":                "Marregal",
		"alga_estranguladora":     "Alga estranguladora",
		"vidarraíz":               "Vidarraíz",
		"sangrerregia":            "Sangrerregia",
		"espina_de_oro":           "Espina de oro",
		"acérita_salvaje":         "Acérita salvaje",
		"solea":                   "Solea",
		"mostacho_de_khadgar":     "Mostacho de Khadgar",
		"lágrimas_de_arthas":      "Lágrimas de Arthas",
		"carolina":                "Carolina",
		"sansam_dorado":           "Sansam dorado",
		"salviargenta_de_montaña": "Salviargenta de montaña",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Hierbas y materiales de Alquimia (TBC) ───
	for id, n := range map[string]string{
		"hierba_vil":          "Hierba vil",
		"velada":              "Velada",
		"flor_abisal":         "Flor abisal",
		"gloria_de_ensueño":   "Gloria de ensueño",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Hierbas y materiales de Alquimia (WotLK) ───
	for id, n := range map[string]string{
		"rosa_de_talandra": "Rosa de Talandra",
		"rémora_pigmea":    "Rémora pigmea",
		"trébol_de_oro":    "Trébol de oro",
		"lirio_atigrado":   "Lirio atigrado",
		"lengua_de_víboris": "Lengua de víporis",
		"espina_de_hielo":  "Espina de hielo",
		"flor_exánime":     "Flor exánime",
		"barra_de_saronita": "Barra de saronita",
		"jade_oscuro":      "Jade oscuro",
		"citrino_enorme":   "Citrino enorme",
		"fuego_eterno":     "Fuego eterno",
		"sangrita":         "Sangrita",
		"calcedonia":       "Calcedonia",
		"aire_eterno":      "Aire eterno",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}

	// ─── Productos crafteados de Alquimia (1-450) ───
	// 30 recetas: pociones, elixires, un frasco, transmutaciones, un aceite
	// (cadena) y la Investigación de alquimia de Rasganorte. Las pociones
	// intermedias (poción de curación menor, aceite de pigmeo) se consumen
	// en recetas posteriores.
	craftedAlquimia := []struct {
		id, nombre, tipo, calidad string
	}{
		// Pociones intermedias y de sanación/maná Classic
		{"poción_curación_menor", "Poción de curación menor", TipoPoción, CalidadComun},
		{"poción_curación_inferior", "Poción de curación inferior", TipoPoción, CalidadComun},
		{"poción_curación", "Poción de curación", TipoPoción, CalidadComun},
		{"poción_maná_inferior", "Poción de maná inferior", TipoPoción, CalidadComun},
		{"poción_curación_superior", "Poción de curación superior", TipoPoción, CalidadComun},
		{"elixir_agilidad", "Elixir de agilidad", TipoElixir, CalidadComun},
		{"elixir_defensa_superior", "Elixir de defensa superior", TipoElixir, CalidadComun},
		{"poción_curación_excelente", "Poción de curación excelente", TipoPoción, CalidadComun},
		{"elixir_detectar_muertos", "Elixir de detención de muertos", TipoElixir, CalidadComun},
		{"elixir_agilidad_superior", "Elixir de agilidad superior", TipoElixir, CalidadRaro},
		{"poción_maná_excelente", "Poción de maná excelente", TipoPoción, CalidadComun},
		{"poción_curación_sublime", "Poción de curación sublime", TipoPoción, CalidadRaro},
		// TBC 300-350
		{"poción_sanación_volátil", "Poción de sanación volátil", TipoPoción, CalidadRaro},
		{"poción_maná_inestable", "Poción de maná inestable", TipoPoción, CalidadRaro},
		{"poción_alquimista_loco", "Poción de alquimista loco", TipoPoción, CalidadRaro},
		{"superpoción_sanación", "Superpoción de sanación", TipoPoción, CalidadRaro},
		{"superpoción_maná", "Superpoción de maná", TipoPoción, CalidadRaro},
		// WotLK 350-450
		{"poción_sanación_resurgente", "Poción de sanación resurgente", TipoPoción, CalidadRaro},
		{"poción_maná_helada", "Poción de maná helada", TipoPoción, CalidadRaro},
		{"elixir_poder_hechizos", "Elixir de poder con hechizos", TipoElixir, CalidadRaro},
		{"aceite_pigmeo", "Aceite de pigmeo", TipoAceite, CalidadComun},
		{"poción_pesadillas", "Poción de pesadillas", TipoPoción, CalidadRaro},
		{"elixir_fuerza_poderosa", "Elixir de fuerza poderosa", TipoElixir, CalidadRaro},
		{"elixir_agilidad_poderosa", "Elixir de agilidad poderosa", TipoElixir, CalidadRaro},
		{"investigación_alquimia_norte", "Investigación de alquimia de Rasganorte", TipoMaterial, CalidadRaro},
		{"poción_indestructible", "Poción indestructible", TipoPoción, CalidadRaro},
		{"poción_maná_rúnica", "Poción de maná rúnica", TipoPoción, CalidadRaro},
		{"titanio", "Barra de titanio", TipoMaterial, CalidadRaro},
		{"diamante_llama_celeste", "Diamante de llama celeste", TipoMaterial, CalidadEpico},
		{"frasco_ira_infinita", "Frasco de ira infinita", TipoFrasco, CalidadEpico},
	}
	for _, c := range craftedAlquimia {
		m[c.id] = def(c.id, c.nombre, c.tipo, c.calidad)
	}
	// ─── Materiales de las especializaciones de Alquimia ───
	// Pociones/elixires no incluidos en el camino 1-450 y objetos de misión
	// (drops) necesarios para aprender cada maestría.
	for id, n := range map[string]string{
		"poción_letargo_sin_sueños_sublime": "Poción de letargo sin sueños sublime",
		"elixir_defensa_sublime":            "Elixir de defensa sublime",
		"elixir_maestría":                   "Elixir de maestría",
		"elixir_agilidad_sublime":           "Elixir de agilidad sublime",
		"esencia_de_infinidad":              "Esencia de infinidad",
		"guía_de_campo_botánicos":           "Guía de Campo para Botánicos",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadRaro)
	}

	// ─── Materiales de Herrería (Classic): lingotes y piedras ───
	for id, n := range map[string]string{
		"lingote_plata":     "Lingote de plata",
		"lingote_bronce":    "Lingote de bronce",
		"lingote_oro":       "Lingote de oro",
		"lingote_hierro":    "Lingote de hierro",
		"lingote_acero":     "Lingote de acero",
		"lingote_mitril":    "Lingote de mitril",
		"lingote_torio":     "Lingote de torio",
		"piedra_basta":      "Piedra basta",
		"piedra_burda":      "Piedra burda",
		"piedra_sólida":     "Piedra sólida",
		"piedra_densa":      "Piedra densa",
		"tela_paño_mágico": "Tela de paño mágico",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}
	// ─── Materiales de Herrería (WotLK) ───
	for id, n := range map[string]string{
		"barra_cobalto":     "Barra de cobalto",
		"aire_cristalizado": "Aire cristalizado",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}

	// ─── Productos crafteados de Herrería (1-450) ───
	// 36 recetas: piedras de afilar/pulir, varas (de plata/oro, reutilizando
	// los items de Encantamiento), piezas de armadura, armas, refuerzos
	// (puntas de escudo, hebillas, cadenas) y runas. Las piedras de pulir
	// pesadas/sólidas son a la vez producto y material de recetas posteriores.
	craftedHerreria := []struct {
		id, nombre, tipo, calidad string
	}{
		// Piedras (Classic) — productos y materiales intermedios
		{"piedra_afilar_basta", "Piedra de afilar basta", TipoMaterial, CalidadComun},
		{"piedra_pulir_basta", "Piedra de pulir basta", TipoMaterial, CalidadComun},
		{"piedra_afilar_burda", "Piedra de afilar burda", TipoMaterial, CalidadComun},
		{"piedra_pulir_burda", "Piedra de pulir burda", TipoMaterial, CalidadComun},
		{"piedra_pulir_pesada", "Piedra de pulir pesada", TipoMaterial, CalidadComun},
		{"piedra_pulir_sólida", "Piedra de pulir sólida", TipoMaterial, CalidadComun},
		{"piedra_afilar_densa", "Piedra de afilar densa", TipoMaterial, CalidadComun},
		// Armadura Classic (malla/placas)
		{"leotardos_bronce_basto", "Leotardos de bronce basto", TipoArmadura, CalidadComun},
		{"leotardos_hierro_verde", "Leotardos de hierro verde", TipoArmadura, CalidadComun},
		{"brazales_hierro_verde", "Brazales de hierro verde", TipoArmadura, CalidadComun},
		{"brazales_escamas_oro", "Brazales de escamas de oro", TipoArmadura, CalidadComun},
		{"yelmo_placas_acero", "Yelmo de placas de acero", TipoArmadura, CalidadComun},
		{"almofar_mitril", "Almófar de mitril", TipoArmadura, CalidadComun},
		{"brazales_torio", "Brazales de torio", TipoArmadura, CalidadRaro},
		{"brazales_placas_imperiales", "Brazales de placas imperiales", TipoArmadura, CalidadRaro},
		{"botas_torio", "Botas de torio", TipoArmadura, CalidadRaro},
		// TBC 300-350 (malla + refuerzos)
		{"almofar_anillas_hierro_vil", "Almófar de anillas de hierro vil", TipoArmadura, CalidadRaro},
		{"guantes_anillas_hierro_vil", "Guantes de anillas de hierro vil", TipoArmadura, CalidadRaro},
		{"brazales_anillas_hierro_vil", "Brazales de anillas de hierro vil", TipoArmadura, CalidadRaro},
		{"runa_amparo_inferior", "Runa de amparo inferior", TipoRefuerzo, CalidadComun},
		{"coraza_hierro_vil", "Coraza de hierro vil", TipoArmadura, CalidadRaro},
		{"resguardo_escudo_inferior", "Resguardo de escudo inferior", TipoRefuerzo, CalidadComun},
		// WotLK 350-450 (placas, armas, refuerzos)
		{"botas_cobalto", "Botas de cobalto", TipoArmadura, CalidadRaro},
		{"escudo_triangular_cobalto", "Escudo triangular de cobalto", TipoArmadura, CalidadRaro},
		{"quijotes_cobalto", "Quijotes de cobalto", TipoArmadura, CalidadRaro},
		{"guantesletes_cobalto", "Guantesletes de cobalto", TipoArmadura, CalidadRaro},
		{"botas_cobalto_con_púas", "Botas de cobalto con púas", TipoArmadura, CalidadRaro},
		{"hombreras_cobalto_con_púas", "Hombreras de cobalto con púas", TipoArmadura, CalidadRaro},
		{"hacha_guerra_cobalto_dentada", "Hacha de guerra de cobalto dentada", TipoArma, CalidadRaro},
		{"cinturón_saronita_brillante", "Cinturón de saronita brillante", TipoArmadura, CalidadRaro},
		{"yelmo_cobalto_cuernudo", "Yelmo de cobalto cuernudo", TipoArmadura, CalidadRaro},
		{"daga_saronita_mortal", "Daga de saronita mortal", TipoArma, CalidadRaro},
		{"hebilla_cinturón_eterna", "Hebilla de cinturón eterna", TipoRefuerzo, CalidadEpico},
		{"cadena_arma_titanio", "Cadena de arma de titanio", TipoRefuerzo, CalidadEpico},
		{"guampolas_imponentes", "Guampolas imponentes", TipoArmadura, CalidadEpico},
		{"quijotes_imponentes", "Quijotes imponentes", TipoArmadura, CalidadEpico},
	}
	for _, c := range craftedHerreria {
		m[c.id] = def(c.id, c.nombre, c.tipo, c.calidad)
	}
	// ─── Materiales de las especializaciones de Herrería ───
	// Piezas de mitril ornamentado y armas (para Forjador de armaduras /
	// armas) y objetos de misión (drops) para las sub-maestrías de armas.
	for id, n := range map[string]string{
		"yelmo_mitril_ornamentado":           "Yelmo de mitril ornamentado",
		"botas_mitril_ornamentadas":          "Botas de mitril ornamentadas",
		"peto_mitril_ornamentado":            "Peto de mitril ornamentado",
		"sable_acero_lunar":                  "Sable de acero lunar",
		"maza_negra_grande":                  "Maza negra grande",
		"hacha_mitril_pesado":                "Hacha de mitril pesado",
		"hacha_hierro_macizo":                "Hacha de hierro macizo",
		"piedra_serpiente_voshgajin":         "Piedra serpiente de Vosh'gajin",
		"delantal_herrero_martillos_carmesi": "Delantal de herrero de martillos carmesí",
		"insignia_guarda_negra":              "Insignia de la Guarda Negra",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadRaro)
	}

	// ─── Materiales de Ingeniería (no compartidos) ───
	// Lingote de cobre (la familia de lingotes de Herrería no incluye cobre;
	// Joyería usa "barra_cobre", aquí se registra el lingote para la guía),
	// Paño de Escarcha (WotLK) y Fuego cristalizado.
	for id, n := range map[string]string{
		"lingote_cobre":       "Lingote de cobre",
		"paño_escarcha":       "Paño de Escarcha",
		"fuego_cristalizado":  "Fuego cristalizado",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadComun)
	}

	// ─── Productos crafteados de Ingeniería (1-450) ───
	// 42 recetas. Ingeniería se caracteriza por cadenas de productos
	// intermedios: pólvoras → bombas, tornillos → bombas/mosquetes, tubos →
	// mosquetes/gafas/gadgets, envolturas → bombas, capacitor → señuelos.
	// Muchos intermedios son a la vez producto y material de recetas
	// posteriores (p.ej. el Overcharged Capacitor se consume en el
	// Explosive Decoy). Los "pure-material" (tornillos/pólvora elemental del
	// escalón TBC 300-310) se craftean en masa sin dar skill.
	craftedIngenieria := []struct {
		id, nombre, tipo, calidad string
	}{
		// Intermedios Classic (pólvoras, tornillos, tubos) — materiales
		{"pólvora_basta", "Pólvora basta", TipoMaterial, CalidadComun},
		{"tornillos_cobre", "Puñado de tornillos de cobre", TipoMaterial, CalidadComun},
		{"tubo_cobre", "Tubo de cobre", TipoMaterial, CalidadComun},
		{"pólvora_burda", "Pólvora burda", TipoMaterial, CalidadComun},
		{"contacto_plata", "Contacto de plata", TipoMaterial, CalidadComun},
		{"tubo_bronce", "Tubo de bronce", TipoMaterial, CalidadComun},
		{"pólvora_pesada", "Pólvora pesada", TipoMaterial, CalidadComun},
		{"pólvora_sólida", "Pólvora sólida", TipoMaterial, CalidadComun},
		{"tubo_mitril", "Tubo de mitril", TipoMaterial, CalidadComun},
		{"disparador_inestable", "Disparador inestable", TipoMaterial, CalidadRaro},
		{"pólvora_densa", "Pólvora densa", TipoMaterial, CalidadComun},
		{"girotiro_mitril", "Girotiro de mitril", TipoMaterial, CalidadComun},
		{"envoltura_mitril", "Envoltura de mitril", TipoMaterial, CalidadComun},
		{"tubo_torio", "Tubo de torio", TipoMaterial, CalidadRaro},
		// Intermedios TBC
		{"envoltura_hierro_vil", "Envoltura de hierro vil", TipoMaterial, CalidadComun},
		{"tornillos_hierro_vil", "Puñado de tornillos de hierro vil", TipoMaterial, CalidadComun},
		{"pólvora_elemental", "Pólvora elemental", TipoMaterial, CalidadComun},
		// Intermedios WotLK
		{"tornillos_cobalto", "Puñado de tornillos de cobalto", TipoMaterial, CalidadComun},
		{"gatillo_explosivo_volátil", "Gatillo explosivo volátil", TipoMaterial, CalidadComun},
		{"capacitor_sobrecargado", "Capacitor sobrecargado", TipoMaterial, CalidadRaro},
		{"tubo_acero_frío", "Tubo de acero frío", TipoMaterial, CalidadRaro},
		// Productos Classic: herramientas, armas, explosivos
		{"llave_arcoluz", "Llave inglesa Arcoluz", TipoMaterial, CalidadComun},
		{"trabuco_basto", "Trabuco basto", TipoArma, CalidadComun},
		{"bomba_bronce_pequeña", "Bomba de bronce pequeña", TipoExplosivo, CalidadComun},
		{"bomba_bronce_grande", "Bomba de bronce grande", TipoExplosivo, CalidadComun},
		{"fuego_artificial_rojo", "Fuego artificial rojo", TipoExplosivo, CalidadComun},
		{"microajustador_giromático", "Microajustador giromático", TipoMaterial, CalidadComun},
		{"bomba_hierro_grande", "Bomba de hierro grande", TipoExplosivo, CalidadComun},
		{"balas_mitril_gran_impacto", "Balas de mitril de gran impacto", TipoMaterial, CalidadComun},
		// Productos Artesano
		{"bomba_gran_carga", "Bomba de gran carga", TipoExplosivo, CalidadRaro},
		{"trastos_wow_torio", "Trastos wow de torio", TipoMaterial, CalidadRaro},
		// Productos TBC
		{"bomba_hierro_vil", "Bomba de hierro vil", TipoExplosivo, CalidadRaro},
		{"mosquete_hierro_vil", "Mosquete de hierro vil", TipoArma, CalidadRaro},
		{"bengala_humo_blanco", "Bengala de humo blanco", TipoExplosivo, CalidadComun},
		// Productos WotLK: gadgets, gafas, navaja
		{"señuelo_explosivo", "Señuelo explosivo", TipoExplosivo, CalidadRaro},
		{"mira_refractora_diamante", "Mira refractora de corte diamante", TipoMaterial, CalidadRaro},
		{"caja_de_bombas", "Caja de bombas", TipoExplosivo, CalidadRaro},
		{"soldador_rayo_goblin", "Soldador de rayo goblin", TipoMaterial, CalidadRaro},
		{"kit_inyector_mana", "Kit inyector de maná", TipoMaterial, CalidadRaro},
		{"gafas_nieve_mecanizadas", "Gafas de nieve mecanizadas", TipoArmadura, CalidadRaro},
		{"máquina_ruido", "Máquina de ruido", TipoMaterial, CalidadRaro},
		{"navaja_ejército_gnómica", "Navaja del ejército gnómico", TipoMaterial, CalidadEpico},
	}
	for _, c := range craftedIngenieria {
		m[c.id] = def(c.id, c.nombre, c.tipo, c.calidad)
	}
	// ─── Materiales de las especializaciones de Ingeniería ───
	// Goblin entrega 20 Bomba de hierro grande (producto, reutilizado), 20
	// Dinamita sólida y 5 Oveja explosiva. Gnómica entrega 6 Tubo de mitril
	// (producto, reutilizado), 1 Mira de precisión y 2 Muñeco-diana avanzado.
	for id, n := range map[string]string{
		"dinamita_sólida":      "Dinamita sólida",
		"oveja_explosiva":      "Oveja explosiva",
		"mira_precisión":       "Mira de precisión",
		"muñeco_diana_avanzado": "Muñeco-diana avanzado",
	} {
		m[id] = def(id, n, TipoMaterial, CalidadRaro)
	}
	return m
}
