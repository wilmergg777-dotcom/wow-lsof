// equipo_catalogo.go define los ítems equipables del juego: armas y piezas
// de armadura con bonus de stats (fuerza/agilidad/intelecto/espiritu/aguante/
// armadura), ranura, nivel mínimo y precio. Se mezclan en el catálogo
// general (itemsPredefinidos) para que m.items los incluya.
//
// Catálogo (~40 ítems):
//   - 8 bandas de nivel (1, 10, 20, 30, 40, 50, 60, 70) × 4 piezas (arma,
//     pecho, pies, anillo) = 32 ítems con stats escalados por banda.
//   - 8 piezas "starter" de nivel 1 (una por ranura: cabeza, hombros,
//     muñecas, manos, cintura, piernas, capa, cuello) = 8 ítems.
//
// Los vendedores de las capitales venden las piezas de tela (banda 1) más
// el arma starter, para que un PJ lvl 1 pueda comprar equipo básico.
package mundo

// itemEq construye un DefItem equipable con stats.
func itemEq(id, nombre, tipo, calidad, slot string, nivelReq, fuerza, agilidad, intelecto, espiritu, aguante, armadura, precio int) DefItem {
	return DefItem{
		ID:         id,
		Nombre:     nombre,
		Tipo:       tipo,
		Calidad:    calidad,
		Stack:      1,
		Icono:      id,
		Equipable:  true,
		Slot:       slot,
		NivelReq:   nivelReq,
		Precio:     precio,
		Fuerza:     fuerza,
		Agilidad:   agilidad,
		Intelecto:  intelecto,
		Espiritu:   espiritu,
		Aguante:    aguante,
		Armadura:   armadura,
	}
}

// itemsEquipoPredefinidos devuelve los ítems equipables del juego.
func itemsEquipoPredefinidos() map[string]DefItem {
	// Bandas de nivel: tag, nivelReq, stat, aguante, armadura, calidad.
	bandas := []struct {
		tag      string
		nivel    int
		stat     int
		aguante  int
		armadura int
		calidad  string
	}{
		{"tela", 1, 3, 2, 10, CalidadComun},
		{"cuero", 10, 8, 5, 40, CalidadComun},
		{"malla", 20, 15, 9, 70, CalidadPocoComun},
		{"adamantita", 30, 22, 13, 110, CalidadPocoComun},
		{"torio", 40, 30, 18, 160, CalidadPocoComun},
		{"nether", 50, 38, 22, 220, CalidadRaro},
		{"saronita", 60, 48, 28, 300, CalidadRaro},
		{"titano", 70, 60, 35, 400, CalidadEpico},
	}
	ms := make(map[string]DefItem, len(bandas)*4+8)
	for _, b := range bandas {
		// Arma: bonus al stat principal (los 3 para que sirva a cualquier
		// clase) + aguante, sin armadura.
		ms["arma_"+b.tag] = itemEq("arma_"+b.tag, "Arma de "+b.tag, TipoArma, b.calidad, SlotArma,
			b.nivel, b.stat, b.stat, b.stat, 0, b.aguante, 0, b.nivel*50)
		// Pecho: armadura + aguante + stat.
		ms["pecho_"+b.tag] = itemEq("pecho_"+b.tag, "Coraza de "+b.tag, TipoArmadura, b.calidad, SlotPecho,
			b.nivel, b.stat/2, b.stat/2, b.stat/2, 0, b.aguante, b.armadura, b.nivel*30)
		// Pies: armadura reducida + aguante + stat.
		ms["pies_"+b.tag] = itemEq("pies_"+b.tag, "Botas de "+b.tag, TipoArmadura, b.calidad, SlotPies,
			b.nivel, b.stat/3, b.stat/3, b.stat/3, 0, b.aguante*7/10, b.armadura*6/10, b.nivel*20)
		// Anillo: stat + espiritu + aguante.
		ms["anillo_"+b.tag] = itemEq("anillo_"+b.tag, "Anillo de "+b.tag, TipoAnillo, b.calidad, SlotDedo,
			b.nivel, b.stat, b.stat, b.stat, b.stat/2, b.aguante/2, 0, b.nivel*40)
	}
	// Starter lvl 1: una pieza por ranura restante (equipo básico de tela).
	starters := []DefItem{
		itemEq("yelmo_tela", "Yelmo de tela", TipoArmadura, CalidadComun, SlotCabeza, 1, 0, 0, 2, 0, 1, 5, 10),
		itemEq("hombreras_tela", "Hombreras de tela", TipoArmadura, CalidadComun, SlotHombros, 1, 0, 0, 2, 0, 1, 5, 8),
		itemEq("brazales_tela", "Brazales de tela", TipoArmadura, CalidadComun, SlotMuñecas, 1, 0, 0, 2, 0, 1, 4, 8),
		itemEq("guantes_tela", "Guantes de tela", TipoArmadura, CalidadComun, SlotManos, 1, 0, 0, 2, 0, 1, 4, 8),
		itemEq("cinturon_tela", "Cinturón de tela", TipoArmadura, CalidadComun, SlotCintura, 1, 0, 0, 2, 0, 1, 4, 8),
		itemEq("pantalones_tela", "Pantalones de tela", TipoArmadura, CalidadComun, SlotPiernas, 1, 0, 0, 2, 0, 1, 6, 10),
		itemEq("capa_tela", "Capa de tela", TipoCapa, CalidadComun, SlotCapa, 1, 0, 0, 1, 0, 1, 3, 10),
		itemEq("amuleto_tela", "Amuleto de tela", TipoAmuleto, CalidadComun, SlotCuello, 1, 0, 0, 2, 1, 1, 0, 12),
	}
	for _, it := range starters {
		ms[it.ID] = it
	}
	return ms
}
