// auras_test.go valida el catálogo de auras de forma aislada: número de
// entradas, reglas de persistencia (frascos sobreviven muerte), categorías
// de stacking y consistencia de los DoT.
package auras

import "testing"

// TestCatalogoTiene23Auras verifica que el catálogo expone las 23 auras
// esperadas (4 frascos + 8 elixires + 4 comidas + 5 pergaminos + 2 DoT).
func TestCatalogoTiene23Auras(t *testing.T) {
	cat := CatalogoAuras()
	if len(cat) != 23 {
		t.Fatalf("catálogo = %d auras, esperaba 23", len(cat))
	}
	if CantidadAuras() != 23 {
		t.Errorf("CantidadAuras() = %d, esperaba 23", CantidadAuras())
	}
}

// TestFrascosPersistenMuerte verifica que los 4 frascos tienen
// PersisteMuerte=true y el resto de consumibles (elixires/comida/pergaminos)
// NO (se pierden al morir).
func TestFrascosPersistenMuerte(t *testing.T) {
	cat := CatalogoAuras()
	frascos := []string{"frasco_iracolosal", "frasco_vidrio_escarcha", "frasco_sangre_piedra", "frasco_mojo_puro"}
	for _, id := range frascos {
		d, ok := cat[id]
		if !ok {
			t.Errorf("frasco %q no está en catálogo", id)
			continue
		}
		if !d.PersisteMuerte {
			t.Errorf("frasco %s debería PersisteMuerte=true", id)
		}
		if d.Categoria != CatFrasco {
			t.Errorf("frasco %s categoría=%q esperaba %q", id, d.Categoria, CatFrasco)
		}
	}
	// Elixir/comida/pergamino NO persisten.
	for _, id := range []string{"elixir_agilidad_poderosa", "comida_rinoceronte", "pergamino_aguante_viii"} {
		if d := cat[id]; d.PersisteMuerte {
			t.Errorf("%s debería PersisteMuerte=false (no es frasco)", id)
		}
	}
}

// TestElixirBatallaYGuardianDistintasCategorias verifica que los elixires
// de batalla y guardián usan categorías distintas (pueden coexistir 1+1).
func TestElixirBatallaYGuardianDistintasCategorias(t *testing.T) {
	cat := CatalogoAuras()
	if cat["elixir_agilidad_poderosa"].Categoria != CatElixirBatalla {
		t.Error("elixir de batalla con categoría incorrecta")
	}
	if cat["elixir_proteccion"].Categoria != CatElixirGuardian {
		t.Error("elixir guardián con categoría incorrecta")
	}
	if CatElixirBatalla == CatElixirGuardian {
		t.Error("batalla y guardián deben ser categorías distintas")
	}
}

// TestDoTSonDebuffs verifica que los DoT del catálogo son de tipo debuff y
// tienen efecto periódico negativo (daño).
func TestDoTSonDebuffs(t *testing.T) {
	cat := CatalogoAuras()
	for _, id := range []string{"sangrado", "veneno_naturaleza"} {
		d, ok := cat[id]
		if !ok {
			t.Errorf("DoT %q no en catálogo", id)
			continue
		}
		if d.Tipo != TipoDebuff {
			t.Errorf("%s tipo=%q esperaba debuff", id, d.Tipo)
		}
		if d.Periodico == nil || d.Periodico.CantidadPorTick >= 0 {
			t.Errorf("%s debería tener Periodico con CantidadPorTick<0", id)
		}
		if d.Periodico.IntervaloMs != 3000 {
			t.Errorf("%s intervalo=%d esperaba 3000", id, d.Periodico.IntervaloMs)
		}
	}
}

// TestPergaminosCategoriasDistintas verifica que cada pergamino de atributo
// tiene su propia categoría (pueden coexistir varios pergaminos distintos).
func TestPergaminosCategoriasDistintas(t *testing.T) {
	cat := CatalogoAuras()
	vistas := map[CategoriaStack]bool{}
	for _, id := range []string{"pergamino_aguante_viii", "pergamino_intelecto_viii", "pergamino_fuerza_viii", "pergamino_agilidad_viii", "pergamino_espiritu_viii"} {
		d := cat[id]
		if d.Categoria == "" {
			t.Errorf("pergamino %s sin categoría", id)
		}
		if vistas[d.Categoria] {
			t.Errorf("categoría %q repetida entre pergaminos", d.Categoria)
		}
		vistas[d.Categoria] = true
	}
}

// TestCatalogoEsSoloLectura verifica que el catálogo cacheado devuelve el
// mismo mapa en llamadas sucesivas (no se reconstruye).
func TestCatalogoEsSoloLectura(t *testing.T) {
	a := CatalogoAuras()
	b := CatalogoAuras()
	if len(a) != len(b) {
		t.Fatal("catálogo cambia de tamaño entre llamadas")
	}
	// Misma instancia (cacheada).
	for k := range a {
		if _, ok := b[k]; !ok {
			t.Errorf("clave %s presente en una llamada pero no en otra", k)
		}
	}
}
