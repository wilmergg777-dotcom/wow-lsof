// Package geometria define tipos geométricos básicos (Vec3 y Vec4)
// compartidos por varios paquetes del servidor, sin dependencias.
// Esto evita ciclos de import entre red, persistencia y mundo.
package geometria

// Vec3 es un vector de 3 componentes para posición en el mundo.
// Convención: Y es arriba, X y Z son el plano horizontal.
type Vec3 struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
	Z float64 `json:"z"`
}

// Vec4 es un quaternion para rotación.
type Vec4 struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
	Z float64 `json:"z"`
	W float64 `json:"w"`
}
