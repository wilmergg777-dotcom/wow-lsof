// catalogo.go define el catálogo de auras del juego: consumibles producidos
// por profesiones (frascos y elixires de Alquimia, comidas de Cocina,
// pergaminos de Inscripción) y efectos periódicos (DoTs) para futuras
// habilidades. CatalogoAuras() devuelve el mapa ID → DefAura.
package auras

import "sync"

// Catálogo central. Las duraciones están en milisegundos:
//   - Frascos/elixires/comida/pergaminos: 1h (3_600_000 ms).
//   - Frascos sobreviven a la muerte (PersisteMuerte=true); el resto no.
//   - DoTs: cortos (12-15s), tick cada 3s.
const duracionHora int64 = 3_600_000

// a construye una DefAura de forma compacta.
func a(id, nombre string, tipo TipoAura, dur int64, cat CategoriaStack, mods []ModStat, pers bool, desc string) DefAura {
	return DefAura{
		ID: id, Nombre: nombre, Tipo: tipo, DuracionMs: dur,
		Categoria: cat, Mods: mods, PersisteMuerte: pers, Descripcion: desc,
	}
}

// periodico construye un EfectoPeriodico (do:t si dano<0, hot si >0).
func periodico(esc Escuela, cantPorTick int, intMs int64) *EfectoPeriodico {
	return &EfectoPeriodico{Escuela: esc, CantidadPorTick: cantPorTick, IntervaloMs: intMs}
}

// El catálogo es estático; se construye una sola vez y se reutiliza (la
// consulta es frecuente: calcularDaño, bonusStatAura, ticks).
var (
	catalogoOnce sync.Once
	catalogoCache map[string]DefAura
)

// CatalogoAuras devuelve el catálogo completo de auras (23 entradas).
// El mapa devuelto es compartido y de solo lectura: no mutar.
func CatalogoAuras() map[string]DefAura {
	catalogoOnce.Do(func() { catalogoCache = construirCatalogo() })
	return catalogoCache
}

func construirCatalogo() map[string]DefAura {
	return map[string]DefAura{
		// ─── Frascos (Alquimia, WotLK) — 1h, sobreviven a muerte ───
		"frasco_iracolosal": a("frasco_iracolosal", "Frasco de ira colosal", TipoBuff, duracionHora, CatFrasco,
			[]ModStat{{StatDanoPct, 100}}, true, "+10% daño (≈+180 poder de ataque)."),
		"frasco_vidrio_escarcha": a("frasco_vidrio_escarcha", "Frasco de vidrio de escarcha", TipoBuff, duracionHora, CatFrasco,
			[]ModStat{{StatDanoPct, 80}}, true, "+8% daño mágico (≈+125 poder de hechizo)."),
		"frasco_sangre_piedra": a("frasco_sangre_piedra", "Frasco de sangre de piedra", TipoBuff, duracionHora, CatFrasco,
			[]ModStat{{StatHPMax, 1300}}, true, "+1300 vida máxima."),
		"frasco_mojo_puro": a("frasco_mojo_puro", "Frasco de mojo puro", TipoBuff, duracionHora, CatFrasco,
			[]ModStat{{StatMP5, 40}}, true, "+40 maná cada 5 s."),

		// ─── Elixires de batalla (Alquimia) — 1h, slot batalla ───
		"elixir_agilidad_poderosa": a("elixir_agilidad_poderosa", "Elixir de agilidad poderosa", TipoBuff, duracionHora, CatElixirBatalla,
			[]ModStat{{StatAgilidad, 35}}, false, "+35 agilidad."),
		"elixir_fuerza_poderosa": a("elixir_fuerza_poderosa", "Elixir de fuerza poderosa", TipoBuff, duracionHora, CatElixirBatalla,
			[]ModStat{{StatFuerza, 35}}, false, "+35 fuerza."),
		"elixir_pensamientos_poderosos": a("elixir_pensamientos_poderosos", "Elixir de pensamientos poderosos", TipoBuff, duracionHora, CatElixirBatalla,
			[]ModStat{{StatIntelecto, 35}}, false, "+35 intelecto."),
		"elixir_espiritu": a("elixir_espiritu", "Elixir de espíritu", TipoBuff, duracionHora, CatElixirBatalla,
			[]ModStat{{StatEspiritu, 35}}, false, "+35 espíritu."),
		"elixir_guru": a("elixir_guru", "Elixir de gurú", TipoBuff, duracionHora, CatElixirBatalla,
			[]ModStat{{StatFuerza, 20}, {StatAgilidad, 20}, {StatIntelecto, 20}, {StatEspiritu, 20}, {StatAguante, 20}},
			false, "+20 a todos los atributos."),

		// ─── Elixires guardián (Alquimia) — 1h, slot guardián ───
		"elixir_proteccion": a("elixir_proteccion", "Elixir de protección", TipoBuff, duracionHora, CatElixirGuardian,
			[]ModStat{{StatArmadura, 800}}, false, "+800 armadura."),
		"elixir_fortaleza_poderosa": a("elixir_fortaleza_poderosa", "Elixir de fortaleza poderosa", TipoBuff, duracionHora, CatElixirGuardian,
			[]ModStat{{StatHPMax, 300}}, false, "+300 vida máxima."),
		"elixir_regen_mana_poderosa": a("elixir_regen_mana_poderosa", "Elixir de regeneración de maná poderosa", TipoBuff, duracionHora, CatElixirGuardian,
			[]ModStat{{StatMP5, 30}}, false, "+30 maná cada 5 s."),

		// ─── Comida "bien alimentado" (Cocina) — 1h, slot comida ───
		"comida_rinoceronte": a("comida_rinoceronte", "Riñón de rinoceronte asado", TipoBuff, duracionHora, CatComida,
			[]ModStat{{StatFuerza, 40}}, false, "+40 fuerza (bien alimentado)."),
		"comida_sabalo": a("comida_sabalo", "Cabeza de sábalo picante", TipoBuff, duracionHora, CatComida,
			[]ModStat{{StatIntelecto, 40}}, false, "+40 intelecto (bien alimentado)."),
		"comida_mamut": a("comida_mamut", "Golosinas de mamut especiadas", TipoBuff, duracionHora, CatComida,
			[]ModStat{{StatAguante, 40}}, false, "+40 aguante (+400 vida)."),
		"comida_banquete": a("comida_banquete", "Gran banquete", TipoBuff, duracionHora, CatComida,
			[]ModStat{{StatFuerza, 20}, {StatAgilidad, 20}, {StatIntelecto, 20}, {StatEspiritu, 20}, {StatAguante, 20}},
			false, "+20 a todos los atributos (bien alimentado)."),

		// ─── Pergaminos (Inscripción) — 1h, 1 por stat ───
		"pergamino_aguante_viii": a("pergamino_aguante_viii", "Pergamino de aguante VIII", TipoBuff, duracionHora, CatPergaminoAguante,
			[]ModStat{{StatAguante, 30}}, false, "+30 aguante."),
		"pergamino_intelecto_viii": a("pergamino_intelecto_viii", "Pergamino de intelecto VIII", TipoBuff, duracionHora, CatPergaminoIntelecto,
			[]ModStat{{StatIntelecto, 30}}, false, "+30 intelecto."),
		"pergamino_fuerza_viii": a("pergamino_fuerza_viii", "Pergamino de fuerza VIII", TipoBuff, duracionHora, CatPergaminoFuerza,
			[]ModStat{{StatFuerza, 30}}, false, "+30 fuerza."),
		"pergamino_agilidad_viii": a("pergamino_agilidad_viii", "Pergamino de agilidad VIII", TipoBuff, duracionHora, CatPergaminoAgilidad,
			[]ModStat{{StatAgilidad, 30}}, false, "+30 agilidad."),
		"pergamino_espiritu_viii": a("pergamino_espiritu_viii", "Pergamino de espíritu VIII", TipoBuff, duracionHora, CatPergaminoEspiritu,
			[]ModStat{{StatEspiritu, 30}}, false, "+30 espíritu."),

		// ─── DoTs (debuff, para habilidades futuras y pruebas) ───
		"sangrado": {
			ID: "sangrado", Nombre: "Sangrado", Tipo: TipoDebuff, DuracionMs: 15_000,
			Categoria: "", Periodico: periodico(EscuelaFisica, -60, 3000),
			Descripcion: "60 de daño físico cada 3 s durante 15 s.",
		},
		"veneno_naturaleza": {
			ID: "veneno_naturaleza", Nombre: "Veneno mortal", Tipo: TipoDebuff, DuracionMs: 12_000,
			Categoria: "", Periodico: periodico(EscuelaNaturaleza, -90, 3000),
			Descripcion: "90 de daño de naturaleza cada 3 s durante 12 s.",
		},
	}
}

// CantidadAuras devuelve el número de entradas del catálogo (para tests).
func CantidadAuras() int { return len(CatalogoAuras()) }
