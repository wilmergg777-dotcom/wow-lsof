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
	return m
}
