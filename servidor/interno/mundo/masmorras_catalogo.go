// masmorras_catalogo.go define el catálogo completo de masmorras de WoW 3.3.5
// (Classic + The Burning Crusade + Wrath of the Lich King), ~47 instancias,
// con desbloqueo progresivo por nivel: cada masmora se abre al alcanzar su
// NivelMin y abarca un rango de leveo [NivelMin, NivelMax].
//
// Las masmorras se generan a partir de una tabla compacta (specMasmora): cada
// entrada define id, nombre, rango de nivel, tamaño de grupo (5 estándar, 10
// para Cumbre de Roca Negra Superior), familia de trash y familia+nombre del
// boss. El generador crea 3 mobs de trash (familiaTrash, niveles crecientes)
// + 1 boss (familiaBoss, nivel máximo, EsBoss). Las coordenadas viven en un
// plano aislado X >= 10000 (OffsetXPlanoMasmorras), separado del mundo abierto
// (|X| < 6000) y de las arenas (X = 9000).
//
// Las familias usan las claves en español de lootTablePorFamilia (humanoide,
// bestia, zombi, elemental, demonio, dragon, murloc, lobo, jabali) para que
// los mobs de masmora también suelten materiales temáticos.
package mundo

import (
	"fmt"

	"aethelgard/servidor/interno/proto"
)

// OffsetXPlanoMasmorras es la coordenada X inicial del plano de instancias
// de masmorra. Cada masmora ocupa 200 unidades en X a partir de aquí.
const OffsetXPlanoMasmorras = 10000.0

// specMasmora es la especificación compacta de una masmora para el generador.
type specMasmora struct {
	id           string
	nombre       string
	nivelMin     int
	nivelMax     int
	tamano       int // 5 (estándar) o 10 (Cumbre de Roca Negra Superior)
	familiaTrash string
	familiaBoss  string
	nombreBoss   string
}

// catalogoSpecs es la tabla de especificaciones de las masmorras, ordenadas
// por nivel de desbloqueo (progresivo Classic -> TBC -> WotLK).
var catalogoSpecs = []specMasmora{
	// ─── Classic (Azeroth), niveles 13-60 ───────────────────────────────
	{id: "sima_ignea", nombre: "Sima Ígnea", nivelMin: 13, nivelMax: 20, tamano: 5, familiaTrash: "demonio", familiaBoss: "demonio", nombreBoss: "Taragaman el Sediento de Sangre"},
	{id: "cuevas_de_los_lamentos", nombre: "Cuevas de los Lamentos", nivelMin: 17, nivelMax: 23, tamano: 5, familiaTrash: "bestia", familiaBoss: "bestia", nombreBoss: "Mutanus el Devorador"},
	{id: "las_minas_de_la_muerte", nombre: "Las Minas de la Muerte", nivelMin: 17, nivelMax: 23, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Edwin VanCleef"},
	{id: "castillo_de_colmillo_oscuro", nombre: "Castillo de Colmillo Oscuro", nivelMin: 18, nivelMax: 23, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Archimago Arugal"},
	{id: "cavernas_de_brazanegra", nombre: "Cavernas de Brazanegra", nivelMin: 22, nivelMax: 27, tamano: 5, familiaTrash: "murloc", familiaBoss: "elemental", nombreBoss: "Aku'mai"},
	{id: "las_mazmorras_ventormenta", nombre: "Las Mazmorras de Ventormenta", nivelMin: 23, nivelMax: 27, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Bazil Thredd"},
	{id: "horado_rajacieno", nombre: "Horado Rajacieno", nivelMin: 22, nivelMax: 31, tamano: 5, familiaTrash: "bestia", familiaBoss: "bestia", nombreBoss: "Charlton Razorflank"},
	{id: "gnomeregan", nombre: "Gnomeregan", nivelMin: 25, nivelMax: 32, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Mekgineer Thermaplugg"},
	{id: "zahurda_rajacieno", nombre: "Zahurda Rajacieno", nivelMin: 33, nivelMax: 37, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Mordressa la Guardiana"},
	{id: "monasterio_escarlata_armeria", nombre: "Monasterio Escarlata: Armería", nivelMin: 33, nivelMax: 37, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Herod el Castigador"},
	{id: "uldaman", nombre: "Uldaman", nivelMin: 37, nivelMax: 44, tamano: 5, familiaTrash: "elemental", familiaBoss: "elemental", nombreBoss: "Archaedas"},
	{id: "zul_farrak", nombre: "Zul'Farrak", nivelMin: 42, nivelMax: 46, tamano: 5, familiaTrash: "humanoide", familiaBoss: "bestia", nombreBoss: "Gahz'rilla"},
	{id: "maraudon", nombre: "Maraudon", nivelMin: 42, nivelMax: 52, tamano: 5, familiaTrash: "elemental", familiaBoss: "elemental", nombreBoss: "Princesa Theradras"},
	{id: "templo_de_atal_hakkar", nombre: "Templo de Atal'Hakkar", nivelMin: 47, nivelMax: 52, tamano: 5, familiaTrash: "dragon", familiaBoss: "zombi", nombreBoss: "Sombra de Eranikus"},
	{id: "profundidades_de_roca_negra", nombre: "Profundidades de Roca Negra", nivelMin: 48, nivelMax: 60, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Emperador Thaurissan"},
	{id: "cumbre_de_roca_negra_inferior", nombre: "Cumbre de Roca Negra (Inferior)", nivelMin: 54, nivelMax: 60, tamano: 10, familiaTrash: "humanoide", familiaBoss: "dragon", nombreBoss: "Señor de Guerra Wyrmthalak"},
	{id: "la_masacre", nombre: "La Masacre", nivelMin: 55, nivelMax: 60, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Rey Gordok"},
	{id: "stratholme", nombre: "Stratholme", nivelMin: 56, nivelMax: 60, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Barón Osahendido"},
	{id: "scholomance", nombre: "Scholomance", nivelMin: 56, nivelMax: 60, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Maestro Oscuro Gandling"},
	{id: "cumbre_de_roca_negra_superior", nombre: "Cumbre de Roca Negra (Superior)", nivelMin: 58, nivelMax: 60, tamano: 10, familiaTrash: "dragon", familiaBoss: "dragon", nombreBoss: "General Drakkisath"},

	// ─── The Burning Crusade (Terrallende), niveles 60-70 ───────────────
	{id: "murallas_del_fuego_infernal", nombre: "Murallas del Fuego Infernal", nivelMin: 60, nivelMax: 62, tamano: 5, familiaTrash: "demonio", familiaBoss: "demonio", nombreBoss: "Vigía Gargolmar"},
	{id: "forja_de_sangre", nombre: "Forja de Sangre", nivelMin: 61, nivelMax: 63, tamano: 5, familiaTrash: "demonio", familiaBoss: "demonio", nombreBoss: "Keli'dan el Rompedor"},
	{id: "recinto_de_los_esclavos", nombre: "Recinto de los Esclavos", nivelMin: 62, nivelMax: 64, tamano: 5, familiaTrash: "murloc", familiaBoss: "elemental", nombreBoss: "Mennu el Traidor"},
	{id: "la_sotienaga", nombre: "La Sotiénaga", nivelMin: 63, nivelMax: 65, tamano: 5, familiaTrash: "bestia", familiaBoss: "bestia", nombreBoss: "la Acechadora Negra"},
	{id: "tumbas_de_mana", nombre: "Tumbas de Maná", nivelMin: 64, nivelMax: 66, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Príncipe-nexo Shaffar"},
	{id: "fuga_de_durnholde", nombre: "Fuga de Durnholde", nivelMin: 66, nivelMax: 68, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Cazadora del Tiempo"},
	{id: "salas_sethekk", nombre: "Salas Sethekk", nivelMin: 67, nivelMax: 69, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Tejedora Oscura Syth"},
	{id: "el_invernadero", nombre: "El Invernadero", nivelMin: 67, nivelMax: 70, tamano: 5, familiaTrash: "elemental", familiaBoss: "elemental", nombreBoss: "Comandante Sarannis"},
	{id: "el_mechanar", nombre: "El Mechanar", nivelMin: 67, nivelMax: 70, tamano: 5, familiaTrash: "elemental", familiaBoss: "elemental", nombreBoss: "Pathaleon el Calculador"},
	{id: "el_arcatraz", nombre: "El Arcatraz", nivelMin: 67, nivelMax: 70, tamano: 5, familiaTrash: "demonio", familiaBoss: "demonio", nombreBoss: "Presagiador Skyriss"},
	{id: "laberinto_de_las_sombras", nombre: "Laberinto de las Sombras", nivelMin: 69, nivelMax: 70, tamano: 5, familiaTrash: "demonio", familiaBoss: "elemental", nombreBoss: "Murmullo"},
	{id: "la_camara_de_vapor", nombre: "La Cámara de Vapor", nivelMin: 68, nivelMax: 70, tamano: 5, familiaTrash: "murloc", familiaBoss: "humanoide", nombreBoss: "Kalithresh"},
	{id: "apertura_del_portal_oscuro", nombre: "Apertura del Portal Oscuro", nivelMin: 68, nivelMax: 70, tamano: 5, familiaTrash: "demonio", familiaBoss: "demonio", nombreBoss: "Aeonus"},
	{id: "salas_arrasadas", nombre: "Salas Arrasadas", nivelMin: 69, nivelMax: 70, tamano: 5, familiaTrash: "humanoide", familiaBoss: "humanoide", nombreBoss: "Kargath Filo Sangriento"},
	{id: "bancal_del_magister", nombre: "Bancal del Magister", nivelMin: 70, nivelMax: 70, tamano: 5, familiaTrash: "humanoide", familiaBoss: "demonio", nombreBoss: "Kael'thas Caminante del Sol"},

	// ─── Wrath of the Lich King (Rasganorte), niveles 70-80 ────────────
	{id: "fortaleza_de_utgarde", nombre: "Fortaleza de Utgarde", nivelMin: 70, nivelMax: 72, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Ingvar el Desvalijador"},
	{id: "el_nexo", nombre: "El Nexo", nivelMin: 71, nivelMax: 73, tamano: 5, familiaTrash: "dragon", familiaBoss: "dragon", nombreBoss: "Keristrasza"},
	{id: "azjol_nerub", nombre: "Azjol-Nerub", nivelMin: 72, nivelMax: 74, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Krik'thir el Guardián de la Puerta"},
	{id: "el_antiguo_reino", nombre: "El Antiguo Reino (Ahn'kahet)", nivelMin: 73, nivelMax: 75, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Heraldo Volazj"},
	{id: "fortaleza_de_drak_tharon", nombre: "Fortaleza de Drak'Tharon", nivelMin: 74, nivelMax: 76, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "El Profeta Tharon'ja"},
	{id: "el_bastion_violeta", nombre: "El Bastión Violeta", nivelMin: 75, nivelMax: 77, tamano: 5, familiaTrash: "demonio", familiaBoss: "dragon", nombreBoss: "Cyanigosa"},
	{id: "gundrak", nombre: "Gundrak", nivelMin: 76, nivelMax: 78, tamano: 5, familiaTrash: "bestia", familiaBoss: "bestia", nombreBoss: "Gal'darah el Alto Profeta"},
	{id: "salas_de_piedra", nombre: "Salas de Piedra", nivelMin: 77, nivelMax: 79, tamano: 5, familiaTrash: "elemental", familiaBoss: "elemental", nombreBoss: "Sjonnir el Forjador"},
	{id: "el_oculus", nombre: "El Oculus", nivelMin: 77, nivelMax: 79, tamano: 5, familiaTrash: "dragon", familiaBoss: "dragon", nombreBoss: "Guardián de las Líneas Eregos"},
	{id: "salas_de_relampagos", nombre: "Salas de Relámpagos", nivelMin: 79, nivelMax: 80, tamano: 5, familiaTrash: "elemental", familiaBoss: "elemental", nombreBoss: "Loken"},
	{id: "cumbre_de_utgarde", nombre: "Cumbre de Utgarde", nivelMin: 80, nivelMax: 80, tamano: 5, familiaTrash: "zombi", familiaBoss: "zombi", nombreBoss: "Rey Ymiron"},
	{id: "el_exterminio_de_stratholme", nombre: "El Exterminio de Stratholme", nivelMin: 80, nivelMax: 80, tamano: 5, familiaTrash: "zombi", familiaBoss: "demonio", nombreBoss: "Mal'Ganis"},
}

// nombreTrashFamilia devuelve el nombre base de un mob de trash por familia.
func nombreTrashFamilia(familia string) string {
	switch familia {
	case "humanoide":
		return "Súbdito"
	case "bestia":
		return "Bestia"
	case "zombi":
		return "No-muerto"
	case "elemental":
		return "Elemental"
	case "demonio":
		return "Demonio"
	case "dragon":
		return "Dracónido"
	case "murloc":
		return "Murloc"
	case "lobo":
		return "Lobo"
	case "jabali":
		return "Jabalí"
	}
	return "Criatura"
}

// generarMasmora construye una DefMasmora a partir de una especificación:
// 3 mobs de trash (familiaTrash, niveles NivelMin..NivelMin+2) + 1 boss
// (familiaBoss, nivel NivelMax, EsBoss). PosSpawn en el plano aislado.
func generarMasmora(s specMasmora, i int) DefMasmora {
	x := OffsetXPlanoMasmorras + float64(i)*200
	t1 := s.nivelMin
	t2 := s.nivelMin + 1
	t3 := s.nivelMin + 2
	if t2 > s.nivelMax {
		t2 = s.nivelMax
	}
	if t3 > s.nivelMax {
		t3 = s.nivelMax
	}
	base := nombreTrashFamilia(s.familiaTrash)
	mobs := []DefSpawnMob{
		{Nombre: fmt.Sprintf("%s de la masmora", base), Tipo: s.familiaTrash, Nivel: t1, Pos: proto.Vec3{X: x + 5, Y: 0, Z: 6}},
		{Nombre: fmt.Sprintf("%s veterano", base), Tipo: s.familiaTrash, Nivel: t2, Pos: proto.Vec3{X: x + 5, Y: 0, Z: -6}},
		{Nombre: fmt.Sprintf("%s guardián", base), Tipo: s.familiaTrash, Nivel: t3, Pos: proto.Vec3{X: x + 12, Y: 0, Z: 0}},
		{Nombre: s.nombreBoss, Tipo: s.familiaBoss, Nivel: s.nivelMax, Pos: proto.Vec3{X: x + 25, Y: 0, Z: 0}, EsBoss: true},
	}
	tamano := s.tamano
	if tamano == 0 {
		tamano = 5
	}
	return DefMasmora{
		ID:          s.id,
		Nombre:      s.nombre,
		NivelMin:    s.nivelMin,
		NivelMax:    s.nivelMax,
		TamanoGrupo: tamano,
		PosSpawn:    proto.Vec3{X: x, Y: 0, Z: 0},
		Mobs:        mobs,
	}
}

// catalogoMasmorras devuelve el catálogo completo de masmorras generado
// desde catalogoSpecs. Cada entrada es una DefMasmora lista para instanciar.
func catalogoMasmorras() map[string]DefMasmora {
	out := make(map[string]DefMasmora, len(catalogoSpecs))
	for i, s := range catalogoSpecs {
		out[s.id] = generarMasmora(s, i)
	}
	return out
}

// nivelBossMasmora devuelve el nivel del boss de una masmora (el mob con
// EsBoss), o 0 si no lo encuentra. Usado para la recompensa de completar.
func nivelBossMasmora(def DefMasmora) int {
	for _, sm := range def.Mobs {
		if sm.EsBoss {
			return sm.Nivel
		}
	}
	return 0
}
