// Parte del catálogo de profesiones (paquete profesiones). Ver tipos.go
// para los tipos base y registro.go para el registro central.
package profesiones

// Catalogo devuelve las profesiones jugables.
// Por ahora: Joyería (Jewelcrafting) 1-450.
func Catalogo() map[string]DefProfesion {
	return map[string]DefProfesion{
		"joyeria":       profesionJoyeria(),
		"peleteria":     profesionPeleteria(),
		"sastreria":     profesionSastreria(),
		"encantamiento": profesionEncantamiento(),
		"alquimia":      profesionAlquimia(),
		"herreria":      profesionHerreria(),
		"ingenieria":    profesionIngenieria(),
		"herboristeria": profesionHerboristeria(),
		"minería":       profesionMineria(),
		"desuello":      profesionDesuello(),
		"inscripción":   profesionInscripcion(),
		"cocina":        profesionCocina(),
		"pesca":         profesionPesca(),
	}
}
