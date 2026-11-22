// servidor.go define el listener TCP que acepta conexiones y lanza sesiones.
package conexion

import (
	"fmt"
	"log"
	"net"
	"strconv"
	"sync"

	"aethelgard/servidor/interno/auth"
	"aethelgard/servidor/interno/mundo"
	"aethelgard/servidor/interno/persistencia"
)

// Servidor reúne el listener y las dependencias compartidas.
type Servidor struct {
	puerto     int
	authGestor *auth.Gestor
	mundo      *mundo.Mundo
	persist    *persistencia.Gestor
	listener   net.Listener
	wg         sync.WaitGroup
}

// NuevoServidor construye un servidor listo para Escuchar().
func NuevoServidor(
	puerto int,
	a *auth.Gestor,
	m *mundo.Mundo,
	p *persistencia.Gestor,
) *Servidor {
	return &Servidor{
		puerto:     puerto,
		authGestor: a,
		mundo:      m,
		persist:    p,
	}
}

// Escuchar arranca el listener TCP y empieza a aceptar conexiones.
// Bloquea hasta que se llame a Detener().
func (s *Servidor) Escuchar() error {
	addr := ":" + strconv.Itoa(s.puerto)
	l, err := net.Listen("tcp", addr)
	if err != nil {
		return fmt.Errorf("listen tcp %s: %w", addr, err)
	}
	s.listener = l
	log.Printf("[servidor] escuchando en %s", l.Addr())

	for {
		conn, err := l.Accept()
		if err != nil {
			// Si el listener se cerró, salimos limpiamente.
			if esCerraduraEsperada(err) {
				s.wg.Wait()
				return nil
			}
			log.Printf("[servidor] accept: %v", err)
			continue
		}
		s.wg.Add(1)
		go func() {
			defer s.wg.Done()
			ses := NuevaSesion(conn, s.authGestor, s.mundo, s.persist)
			ses.Manejar()
		}()
	}
}

// Detener cierra el listener y espera a que todas las sesiones terminen.
func (s *Servidor) Detener() {
	if s.listener != nil {
		_ = s.listener.Close()
	}
	s.wg.Wait()
}
