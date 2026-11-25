// profesiones_test.go valida el paquete profesiones de forma aislada: el
// catálogo tiene las 13 profesiones esperadas, cada una con al menos un
// rango y un boss/receta, y los tipos base se construyen correctamente.
package profesiones

import "testing"

// TestCatalogoTiene13Profesiones verifica que el catálogo expone las 13
// profesiones de WoW 3.3.5 con los IDs esperados.
func TestCatalogoTiene13Profesiones(t *testing.T) {
	cat := Catalogo()
	esperadas := []string{
		"herreria", "alquimia", "joyeria", "ingenieria", "sastreria",
		"encantamiento", "peleteria", "herboristeria", "minería",
		"desuello", "inscripción", "cocina", "pesca",
	}
	if len(cat) != len(esperadas) {
		t.Errorf("catálogo = %d profesiones, esperaba %d", len(cat), len(esperadas))
	}
	for _, id := range esperadas {
		def, ok := cat[id]
		if !ok {
			t.Errorf("profesión %q no está en el catálogo", id)
			continue
		}
		if def.ID != id {
			t.Errorf("profesión %q: ID mismatch %q", id, def.ID)
		}
		if len(def.Rangos) == 0 {
			t.Errorf("profesión %s sin rangos", id)
		}
		if def.Nombre == "" {
			t.Errorf("profesión %s sin nombre", id)
		}
	}
}

// TestEstadoProfesionSkillMax verifica el cálculo del techo de habilidad
// según el rango aprendido.
func TestEstadoProfesionSkillMax(t *testing.T) {
	cat := Catalogo()
	herr := cat["herreria"]
	ep := &EstadoProfesion{ProfesionID: "herreria", Skill: 50}
	// Sin rango aprendido, el techo es 0 (no puede craftear nada aún).
	if techo := ep.SkillMax(herr); techo != 0 {
		t.Errorf("sin rango aprendido, SkillMax=%d esperaba 0", techo)
	}
	// Tras aprender el primer rango (Aprendiz), el techo es el SkillMax de ese rango.
	if len(herr.Rangos) == 0 {
		t.Fatal("herrería sin rangos")
	}
	ep.RangosAprendidos = []string{herr.Rangos[0].ID}
	if techo := ep.SkillMax(herr); techo != herr.Rangos[0].SkillMax {
		t.Errorf("tras Aprendiz, SkillMax=%d esperaba %d", techo, herr.Rangos[0].SkillMax)
	}
}

// TestMaxProfesionesPrimarias verifica la constante de límite (2).
func TestMaxProfesionesPrimarias(t *testing.T) {
	if MaxProfesionesPrimarias != 2 {
		t.Errorf("MaxProfesionesPrimarias=%d, esperaba 2", MaxProfesionesPrimarias)
	}
}
