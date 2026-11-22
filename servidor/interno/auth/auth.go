// Package auth maneja la autenticación de cuentas de usuario.
// Las cuentas se persisten como JSON en el directorio de datos del servidor.
// Las contraseñas se guardan hasheadas con bcrypt (cost 10).
package auth

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// Errores conocidos del paquete auth.
var (
	ErrUsuarioYaExiste = errors.New("el usuario ya existe")
	ErrUsuarioNoExiste = errors.New("el usuario no existe")
	ErrPasswordInvalido = errors.New("contraseña incorrecta")
)

// Cuenta es la representación persistida de una cuenta de usuario.
type Cuenta struct {
	Usuario       string   `json:"usuario"`
	HashPassword  []byte   `json:"hash_password"`
	Personajes    []string `json:"personajes"` // lista de nombres de personajes de esta cuenta
	CreadoUnixMs  int64    `json:"creado_unix_ms"`
}

// Gestor es el gestor de cuentas thread-safe.
type Gestor struct {
	mu      sync.RWMutex
	dir     string // ruta al directorio donde se guardan las cuentas
}

// NuevoGestor crea un gestor que lee y escribe cuentas en dir.
// Crea el directorio si no existe.
func NuevoGestor(dir string) (*Gestor, error) {
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return nil, fmt.Errorf("crear dir de cuentas: %w", err)
	}
	return &Gestor{dir: dir}, nil
}

// Registrar crea una cuenta nueva. Devuelve ErrUsuarioYaExiste si ya existe.
func (g *Gestor) Registrar(usuario, password string) error {
	if usuario == "" || password == "" {
		return errors.New("usuario y password son obligatorios")
	}
	if len(usuario) < 3 || len(usuario) > 24 {
		return errors.New("el usuario debe tener entre 3 y 24 caracteres")
	}
	if len(password) < 6 {
		return errors.New("la contraseña debe tener al menos 6 caracteres")
	}

	g.mu.Lock()
	defer g.mu.Unlock()

	if g.existe(usuario) {
		return ErrUsuarioYaExiste
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("hashear password: %w", err)
	}

	c := Cuenta{
		Usuario:      usuario,
		HashPassword: hash,
		Personajes:   []string{},
		CreadoUnixMs: ahoraUnixMs(),
	}
	return g.guardar(c)
}

// Login valida credenciales. Devuelve la cuenta si ok.
func (g *Gestor) Login(usuario, password string) (*Cuenta, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	c, err := g.cargar(usuario)
	if err != nil {
		return nil, ErrUsuarioNoExiste
	}
	if bcrypt.CompareHashAndPassword(c.HashPassword, []byte(password)) != nil {
		return nil, ErrPasswordInvalido
	}
	return c, nil
}

// AgregarPersonaje añade un nombre de personaje a la cuenta y persiste.
// No valida unicidad del personaje; eso lo hace el paquete mundo.
func (g *Gestor) AgregarPersonaje(usuario, nombrePJ string) error {
	g.mu.Lock()
	defer g.mu.Unlock()

	c, err := g.cargar(usuario)
	if err != nil {
		return ErrUsuarioNoExiste
	}
	for _, n := range c.Personajes {
		if n == nombrePJ {
			return nil // idempotente
		}
	}
	c.Personajes = append(c.Personajes, nombrePJ)
	return g.guardar(*c)
}

// ListarPersonajes devuelve los nombres de personajes de una cuenta.
func (g *Gestor) ListarPersonajes(usuario string) ([]string, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()
	c, err := g.cargar(usuario)
	if err != nil {
		return nil, ErrUsuarioNoExiste
	}
	out := make([]string, len(c.Personajes))
	copy(out, c.Personajes)
	return out, nil
}

// ─── internos ───────────────────────────────────────────────────────────

func (g *Gestor) existe(usuario string) bool {
	_, err := g.cargar(usuario)
	return err == nil
}

func (g *Gestor) cargar(usuario string) (*Cuenta, error) {
	path := filepath.Join(g.dir, sanitizar(usuario)+".json")
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var c Cuenta
	if err := json.Unmarshal(data, &c); err != nil {
		return nil, fmt.Errorf("unmarshal cuenta %s: %w", usuario, err)
	}
	return &c, nil
}

func (g *Gestor) guardar(c Cuenta) error {
	path := filepath.Join(g.dir, sanitizar(c.Usuario)+".json")
	data, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal cuenta: %w", err)
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o600); err != nil {
		return fmt.Errorf("escribir cuenta: %w", err)
	}
	return os.Rename(tmp, path)
}

// sanitizar convierte un nombre de usuario en un nombre de archivo seguro.
// Permite letras, números y guion bajo; todo lo demás se vuelve '_'.
func sanitizar(s string) string {
	out := make([]byte, len(s))
	for i := 0; i < len(s); i++ {
		c := s[i]
		switch {
		case c >= 'a' && c <= 'z', c >= 'A' && c <= 'Z', c >= '0' && c <= '9', c == '_':
			out[i] = c
		default:
			out[i] = '_'
		}
	}
	return string(out)
}

// ahoraUnixMs está aquí para poder mockear en tests futuros.
var ahoraUnixMs = func() int64 {
	return time.Now().UnixMilli()
}
