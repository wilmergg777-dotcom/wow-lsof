// tipos.go define los tipos base del sistema de auras (efectos temporales
// sobre entidades: buffs, debuffs, DoTs, Hots). Una aura modifica stats del
// objetivo y/o aplica un efecto periódico (daño/curación por tick) durante
// un tiempo, sujeta a reglas de stacking por categoría.
//
// El paquete auras es DATA PURA: define DefAura (la plantilla) y AuraActiva
// (la instancia sobre una entidad). La aplicación, el ticking y la
// integración con stats viven en el paquete mundo (que conoce Jugador y
// Enemigo), importando este paquete. Así se evita el acoplamiento circular.
package auras

// TipoAura clasifica la naturaleza de la aura.
type TipoAura string

const (
	TipoBuff   TipoAura = "buff"   // beneficiosa (sobre aliado/self)
	TipoDebuff TipoAura = "debuff" // perjudicial (sobre enemigo)
)

// Escuela de daño/curación (para DoTs/Hots y resistencia futura).
type Escuela string

const (
	EscuelaFisica    Escuela = "fisica"
	EscuelaFuego     Escuela = "fuego"
	EscuelaEscarcha  Escuela = "escarcha"
	EscuelaNaturaleza Escuela = "naturaleza"
	EscuelaSagrado   Escuela = "sagrado"
	EscuelaSombra    Escuela = "sombra"
	EscuelaArcano    Escuela = "arcano"
)

// StatIDs soportados por ModStat. Los de tipo "_pct" van en por-mil
// (100 = +10%). El resto son valores planos añadidos al stat derivado.
const (
	StatFuerza        = "fuerza"
	StatAgilidad      = "agilidad"
	StatIntelecto     = "intelecto"
	StatEspiritu      = "espiritu"
	StatAguante       = "aguante"
	StatArmadura      = "armadura"
	StatHPMax         = "hp_max"
	StatManaMax       = "mana_max"
	StatDanoPct       = "dano_pct"       // por-mil, suma al multiplicador de daño
	StatCritPct       = "crit_pct"       // por-mil
	StatCeleridadPct  = "celeridad_pct"  // por-mil
	StatMP5           = "mp5"            // regen de maná cada 5s
)

// ModStat es una modificación de un stat que la aura aplica mientras activa.
type ModStat struct {
	Stat  string `json:"stat"`
	Valor int    `json:"valor"` // plano, o por-mil si el Stat es *_pct
}

// EfectoPeriodico aplica daño (CantidadPorTick < 0) o curación (> 0) al
// objetivo cada IntervaloMs. La escuela determina resistencias futuras.
type EfectoPeriodico struct {
	Escuela          Escuela `json:"escuela"`
	CantidadPorTick  int     `json:"cantidad_por_tick"` // <0 = daño, >0 = curación
	IntervaloMs      int64   `json:"intervalo_ms"`      // típicamente 3000
}

// CategoriaStack agrupa auras que NO pueden coexistir. Al aplicar una aura
// con categoría no vacía, se elimina cualquier aura activa de la misma
// categoría (regla de WoW: 1 frasco, 1 elixir de batalla + 1 guardián,
// 1 comida, 1 pergamino por stat). "" = sin límite (coexiste con todo).
type CategoriaStack string

const (
	CatFrasco          CategoriaStack = "frasco"
	CatElixirBatalla   CategoriaStack = "elixir_batalla"
	CatElixirGuardian  CategoriaStack = "elixir_guardian"
	CatComida          CategoriaStack = "comida"
	CatBebida          CategoriaStack = "bebida"
	CatPergaminoAguante   CategoriaStack = "pergamino_aguante"
	CatPergaminoIntelecto CategoriaStack = "pergamino_intelecto"
	CatPergaminoFuerza    CategoriaStack = "pergamino_fuerza"
	CatPergaminoAgilidad  CategoriaStack = "pergamino_agilidad"
	CatPergaminoEspiritu  CategoriaStack = "pergamino_espiritu"
)

// DefAura es la plantilla de una aura (inmutable, en el catálogo).
type DefAura struct {
	ID             string           `json:"id"`
	Nombre         string           `json:"nombre"`
	Tipo           TipoAura         `json:"tipo"`
	DuracionMs     int64            `json:"duracion_ms"` // 0 = instantáneo (pociones); >0 = duración
	Categoria      CategoriaStack   `json:"categoria,omitempty"`
	Mods           []ModStat        `json:"mods,omitempty"`
	Periodico      *EfectoPeriodico `json:"periodico,omitempty"`
	PersisteMuerte bool             `json:"persiste_muerte,omitempty"` // frascos sobreviven al morir
	Descripcion    string           `json:"descripcion,omitempty"`
}

// AuraActiva es una instancia de aura aplicada a una entidad. Vive en el
// estado del Jugador/Enemigo (paquete mundo).
type AuraActiva struct {
	DefID          string `json:"def_id"`           // ID del DefAura en el catálogo
	InicioMs       int64  `json:"inicio_ms"`
	FinMs          int64  `json:"fin_ms"`           // 0 = permanente (no expira)
	ProximoTickMs  int64  `json:"proximo_tick_ms"`  // 0 = sin tick periódico
	AplicadoPor    string `json:"aplicado_por"`     // itemID/habilidadID origen
}

// EsPermanente indica si la aura no expira por tiempo.
func (a *AuraActiva) EsPermanente() bool { return a.FinMs == 0 }

// Expirada indica si la aura ha vencido en el instante `ahora`.
func (a *AuraActiva) Expirada(ahora int64) bool {
	return a.FinMs != 0 && a.FinMs <= ahora
}

// TieneTick indica si la aura tiene efecto periódico y debe tickar.
func (a *AuraActiva) TieneTick() bool { return a.ProximoTickMs > 0 }

// AfectaMaximos indica si la aura modifica vida/maná máximos (y por tanto
// requiere recalcular hpMax/energiaMax al aplicarla/expirarla).
func (d DefAura) AfectaMaximos() bool {
	for _, m := range d.Mods {
		if m.Stat == StatAguante || m.Stat == StatHPMax || m.Stat == StatManaMax {
			return true
		}
	}
	return false
}

// TieneMods indica si la aura tiene modificadores de stat.
func (d DefAura) TieneMods() bool { return len(d.Mods) > 0 }
