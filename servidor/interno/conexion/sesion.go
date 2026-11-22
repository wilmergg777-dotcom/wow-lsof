// sesion.go maneja una conexión TCP individual.
// Ciclo de vida:
//   1. Leer mensaje de login.
//   2. Si ok, esperar mensaje de selección/creación de personaje.
//   3. Cuando el personaje entra al mundo, arrancar la goroutine escritora.
//   4. Forward intents del cliente al jugador (cola) hasta que se cierre la conexión.
//   5. Al cerrar, sacar al jugador del mundo y persistir.
package conexion

import (
	"bufio"
	. "aethelgard/servidor/interno/proto"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	"aethelgard/servidor/interno/auth"
	"aethelgard/servidor/interno/mundo"
	"aethelgard/servidor/interno/persistencia"
)

// Sesion es el estado por conexión.
type Sesion struct {
	conn       net.Conn
	authGestor *auth.Gestor
	mundo      *mundo.Mundo
	persist    *persistencia.Gestor
	mu         sync.Mutex
	cuentaActual string
	jugador    *mundo.Jugador
	estado     string // "esperando_login" | "esperando_pj" | "en_juego" | "cerrado"
	cerrarOnce sync.Once
}

// NuevaSesion construye una sesión lista para manejar una conexión.
func NuevaSesion(conn net.Conn, a *auth.Gestor, m *mundo.Mundo, p *persistencia.Gestor) *Sesion {
	return &Sesion{
		conn:       conn,
		authGestor: a,
		mundo:      m,
		persist:    p,
		estado:     "esperando_login",
	}
}

// Manejar es el entry point de la goroutine de sesión.
// Bloquea hasta que la conexión se cierra o hay un error fatal.
func (s *Sesion) Manejar() {
	defer s.cerrar()
	r := bufio.NewReader(s.conn)
	for {
		msg, err := LeerMensaje(r)
		if err != nil {
			if !esCerraduraEsperada(err) {
				log.Printf("[sesion %s] error leyendo: %v", s.conn.RemoteAddr(), err)
			}
			return
		}
		if err := s.despachar(msg); err != nil {
			log.Printf("[sesion %s] despachar: %v", s.conn.RemoteAddr(), err)
			return
		}
	}
}

// despachar envía el mensaje al handler según el estado de la sesión.
func (s *Sesion) despachar(msg MensajeCliente) error {
	s.mu.Lock()
	estado := s.estado
	s.mu.Unlock()

	switch estado {
	case "esperando_login":
		return s.handleLogin(msg)
	case "esperando_pj":
		return s.handleSeleccion(msg)
	case "en_juego":
		return s.handleEnJuego(msg)
	case "cerrado":
		return fmt.Errorf("sesión cerrada")
	default:
		return fmt.Errorf("estado desconocido: %s", estado)
	}
}

// handleLogin procesa mensajes de tipo login o registro.
func (s *Sesion) handleLogin(msg MensajeCliente) error {
	switch msg.Tipo {
	case "login":
		c, err := s.authGestor.Login(msg.Usuario, msg.Password)
		if err != nil {
			return EscribirMensaje(s.conn, MensajeServidor{
				Tipo:  "login_resp",
				OK:    false,
				Error: err.Error(),
			})
		}
		s.mu.Lock()
		s.cuentaActual = c.Usuario
		s.estado = "esperando_pj"
		s.mu.Unlock()

		pjs := make([]PersonajeRes, 0, len(c.Personajes))
		for _, nombre := range c.Personajes {
			p, err := s.persist.Cargar(nombre)
			if err != nil {
				continue
			}
			pjs = append(pjs, PersonajeRes{
				Nombre: p.Nombre,
				Clase:  p.Clase,
				Nivel:  p.Nivel,
			})
		}
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo:       "login_resp",
			OK:         true,
			Personajes: pjs,
			Facciones:  faccionesRes(s.mundo),
			Razas:      razasRes(s.mundo),
			Clases:     clasesRes(s.mundo),
		})

	case "registro":
		if err := s.authGestor.Registrar(msg.Usuario, msg.Password); err != nil {
			return EscribirMensaje(s.conn, MensajeServidor{
				Tipo: "registro_resp", OK: false, Error: err.Error(),
			})
		}
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "registro_resp", OK: true,
		})

	default:
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "error", Mensaje: "debes hacer login primero",
		})
	}
}

// handleSeleccion procesa crear_pj y sel_pj.
func (s *Sesion) handleSeleccion(msg MensajeCliente) error {
	switch msg.Tipo {
	case "crear_pj":
		return s.crearPersonaje(msg)
	case "sel_pj":
		return s.seleccionarPersonaje(msg)
	case "logout":
		// Volver al login sin cerrar la conexión.
		s.mu.Lock()
		s.cuentaActual = ""
		s.estado = "esperando_login"
		s.mu.Unlock()
		return nil
	default:
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "error", Mensaje: "esperando crear_pj o sel_pj",
		})
	}
}

// crearPersonaje valida el nombre, la clase y la facción, persiste el
// personaje nuevo y lo asocia a la cuenta.
func (s *Sesion) crearPersonaje(msg MensajeCliente) error {
	nombre := msg.Nombre
	if len(nombre) < 3 || len(nombre) > 16 {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "nombre debe tener 3-16 caracteres",
		})
	}
	// Restricción de prefijo para evitar colisión con IDs internos de mobs.
	if tienePrefijoReservado(nombre) {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "nombre reservado",
		})
	}
	clases := s.mundo.Clases()
	if _, ok := clases[msg.Clase]; !ok {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "clase inválida",
		})
	}
	facciones := s.mundo.Facciones()
	if _, ok := facciones[msg.Faccion]; !ok {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "facción inválida",
		})
	}
	// Validar raza: debe existir y pertenecer a la facción elegida.
	razas := s.mundo.Razas()
	razaDef, razaOK := razas[msg.Raza]
	if !razaOK {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "raza inválida",
		})
	}
	if razaDef.Faccion != msg.Faccion {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "esa raza no pertenece a tu facción",
		})
	}
	// Validar matriz raza-clase: la clase debe estar permitida para la raza.
	clasePermitida := false
	for _, c := range razaDef.Clases {
		if c == msg.Clase {
			clasePermitida = true
			break
		}
	}
	if !clasePermitida {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "esa clase no está disponible para tu raza",
		})
	}
	if s.persist.Existe(nombre) {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "nombre ya existe",
		})
	}

	// Crear y guardar.
	claseDef := clases[msg.Clase]
	habilidades := make([]string, 0, len(claseDef.Habilidades))
	for _, h := range claseDef.Habilidades {
		habilidades = append(habilidades, h.ID)
	}
	ahora := time.Now().UnixMilli()
	pj := persistencia.Personaje{
		Nombre:       nombre,
		Cuenta:       s.cuentaActual,
		Clase:        msg.Clase,
		Faccion:      msg.Faccion,
		Raza:         msg.Raza,
		Nivel:        1,
		PosMundo:     Vec3{},
		Habilidad:    habilidades,
		Inventario:   []string{},
		CreadoUnixMs: ahora,
	}
	if err := s.persist.Guardar(pj); err != nil {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "error guardando personaje",
		})
	}
	if err := s.authGestor.AgregarPersonaje(s.cuentaActual, nombre); err != nil {
		log.Printf("[sesion] agregar personaje a cuenta: %v", err)
	}

	// Refrescar lista de personajes para el cliente.
	return s.enviarListaPersonajes()
}

// seleccionarPersonaje carga el personaje y lo mete al mundo.
func (s *Sesion) seleccionarPersonaje(msg MensajeCliente) error {
	p, err := s.persist.Cargar(msg.Nombre)
	if err != nil {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "personaje no existe",
		})
	}
	if p.Cuenta != s.cuentaActual {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "sel_resp", OK: false, Error: "personaje no pertenece a tu cuenta",
		})
	}
	j := mundo.NuevoJugadorDesdePersistencia(p, s.mundo, s.cuentaActual)
	s.mundo.AgregarJugador(j)

	s.mu.Lock()
	s.jugador = j
	s.estado = "en_juego"
	s.mu.Unlock()

	// Arrancar goroutine escritora.
	go s.escritor(j)

	// Confirmar al cliente.
	own := snapshotPropio(j)
	return EscribirMensaje(s.conn, MensajeServidor{
		Tipo:            "sel_resp",
		OK:              true,
		PersonajePropio: &own,
		Masmoras:        masmorasRes(s.mundo),
		Arenas:          arenasRes(s.mundo),
	})
}

// handleEnJuego encola el intent al jugador, o maneja directamente los
// mensajes del buscador de masmorras/PvP (que no son intents de tick).
func (s *Sesion) handleEnJuego(msg MensajeCliente) error {
	s.mu.Lock()
	j := s.jugador
	s.mu.Unlock()
	if j == nil {
		return fmt.Errorf("jugador nil en estado en_juego")
	}
	switch msg.Tipo {
	case "logout":
		// El cliente pide salir al selection screen.
		s.logoutAlSeleccion()
		return nil
	case "cola_pve_entrar":
		return s.colaPvEEntrar(j, msg)
	case "cola_pve_salir":
		s.mundo.Buscador().SalirColaPvE(j)
		return nil
	case "cola_pvp_entrar":
		return s.colaPvPEntrar(j, msg)
	case "cola_pvp_salir":
		s.mundo.Buscador().SalirColaPvP(j)
		return nil
	}
	j.EncolarIntent(msg)
	return nil
}

// colaPvEEntrar mete al jugador en la cola de una masmora.
func (s *Sesion) colaPvEEntrar(j *mundo.Jugador, msg MensajeCliente) error {
	if err := s.mundo.Buscador().EntrarColaPvE(j, msg.MasmoraID); err != nil {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "error", Mensaje: err.Error(),
		})
	}
	return nil
}

// colaPvPEntrar mete al jugador en la cola de una arena.
func (s *Sesion) colaPvPEntrar(j *mundo.Jugador, msg MensajeCliente) error {
	if err := s.mundo.Buscador().EntrarColaPvP(j, msg.ArenaID); err != nil {
		return EscribirMensaje(s.conn, MensajeServidor{
			Tipo: "error", Mensaje: err.Error(),
		})
	}
	return nil
}

// logoutAlSeleccion saca al jugador del mundo pero mantiene la conexión.
func (s *Sesion) logoutAlSeleccion() {
	s.mu.Lock()
	j := s.jugador
	s.jugador = nil
	s.estado = "esperando_pj"
	s.mu.Unlock()
	if j != nil {
		s.mundo.QuitarJugador(j.ID())
		j.CerrarSalida()
	}
	// Enviar lista actualizada.
	_ = s.enviarListaPersonajes()
}

// escritor drena el canal de salida del jugador y escribe al socket.
func (s *Sesion) escritor(j *mundo.Jugador) {
	for msg := range j.Salida() {
		if err := EscribirMensaje(s.conn, msg); err != nil {
			log.Printf("[sesion %s] escritor: %v", s.conn.RemoteAddr(), err)
			s.cerrar()
			return
		}
	}
}

// enviarListaPersonajes recarga la lista de personajes de la cuenta.
func (s *Sesion) enviarListaPersonajes() error {
	nombres, err := s.authGestor.ListarPersonajes(s.cuentaActual)
	if err != nil {
		return err
	}
	pjs := make([]PersonajeRes, 0, len(nombres))
	for _, n := range nombres {
		p, err := s.persist.Cargar(n)
		if err != nil {
			continue
		}
		pjs = append(pjs, PersonajeRes{Nombre: p.Nombre, Clase: p.Clase, Nivel: p.Nivel})
	}
	return EscribirMensaje(s.conn, MensajeServidor{
		Tipo: "lista_pj", Personajes: pjs,
	})
}

// cerrar limpia la sesión: saca al jugador del mundo, cierra el socket.
func (s *Sesion) cerrar() {
	s.cerrarOnce.Do(func() {
		s.mu.Lock()
		j := s.jugador
		s.jugador = nil
		s.estado = "cerrado"
		s.mu.Unlock()
		if j != nil {
			s.mundo.QuitarJugador(j.ID())
			j.CerrarSalida()
		}
		_ = s.conn.Close()
	})
}

// tienePrefijoReservado comprueba si el nombre empieza con un prefijo
// reservado para IDs internos.
func tienePrefijoReservado(s string) bool {
	return empiezaCon(s, "mob_") || empiezaCon(s, "pj_")
}

// empiezaCon es strings.HasPrefix sin importar strings (mantener imports mínimos).
func empiezaCon(s, pref string) bool {
	if len(s) < len(pref) {
		return false
	}
	for i := 0; i < len(pref); i++ {
		if s[i] != pref[i] {
			return false
		}
	}
	return true
}

// esCerraduraEsperada devuelve true si el error es EOF o reset.
func esCerraduraEsperada(err error) bool {
	if err == nil {
		return true
	}
	msg := err.Error()
	return contiene(msg, "EOF") || contiene(msg, "connection reset") ||
		contiene(msg, "broken pipe") || contiene(msg, "use of closed")
}

// contiene es strings.Contains sin import.
func contiene(s, sub string) bool {
	if len(sub) == 0 {
		return true
	}
	if len(s) < len(sub) {
		return false
	}
	for i := 0; i+len(sub) <= len(s); i++ {
		match := true
		for j := 0; j < len(sub); j++ {
			if s[i+j] != sub[j] {
				match = false
				break
			}
		}
		if match {
			return true
		}
	}
	return false
}

// snapshotPropio construye el snapshot inicial que se envía al cliente
// tras seleccionar el personaje.
func snapshotPropio(j *mundo.Jugador) EntidadSnapshot {
	return EntidadSnapshot{
		ID:        j.ID(),
		Nombre:    j.Nombre(),
		Clase:     j.Clase(),
		Nivel:     j.Nivel(),
		Pos:       j.Pos(),
		Rot:       j.Rot(),
		HPActual:  j.HPActual(),
		HPMax:     j.HPMax(),
		EsJugador: true,
		Faccion:   j.Faccion(),
		Raza:      j.Raza(),
		Rol:       j.Rol(),
	}
}

// faccionesRes convierte las facciones del mundo a la lista del protocolo.
func faccionesRes(m *mundo.Mundo) []FaccionRes {
	facs := m.Facciones()
	out := make([]FaccionRes, 0, len(facs))
	for _, f := range facs {
		out = append(out, FaccionRes{ID: f.ID, Nombre: f.Nombre})
	}
	return out
}

// razasRes convierte las razas del mundo a la lista del protocolo.
func razasRes(m *mundo.Mundo) []RazaRes {
	razas := m.Razas()
	out := make([]RazaRes, 0, len(razas))
	for _, r := range razas {
		// Copiar el slice de clases para no compartir la referencia interna.
		clases := make([]string, len(r.Clases))
		copy(clases, r.Clases)
		out = append(out, RazaRes{
			ID:           r.ID,
			Nombre:       r.Nombre,
			Faccion:      r.Faccion,
			Clases:       clases,
			RacialNombre: r.RacialNombre,
			RacialDesc:   r.RacialDesc,
		})
	}
	return out
}

// clasesRes convierte las clases del mundo a la lista del protocolo.
func clasesRes(m *mundo.Mundo) []ClaseRes {
	clases := m.Clases()
	out := make([]ClaseRes, 0, len(clases))
	for _, c := range clases {
		out = append(out, ClaseRes{ID: c.ID, Nombre: c.Nombre, Rol: c.Rol})
	}
	return out
}

// masmorasRes convierte las masmoras del mundo a la lista del protocolo.
func masmorasRes(m *mundo.Mundo) []MasmoraRes {
	ms := m.Masmoras()
	out := make([]MasmoraRes, 0, len(ms))
	for _, d := range ms {
		out = append(out, MasmoraRes{
			ID:          d.ID,
			Nombre:      d.Nombre,
			NivelMin:    d.NivelMin,
			TamanoGrupo: d.TamanoGrupo,
		})
	}
	return out
}

// arenasRes convierte las arenas del mundo a la lista del protocolo.
func arenasRes(m *mundo.Mundo) []ArenaRes {
	as := m.Arenas()
	out := make([]ArenaRes, 0, len(as))
	for _, d := range as {
		out = append(out, ArenaRes{
			ID:           d.ID,
			Nombre:       d.Nombre,
			TamanoEquipo: d.TamanoEquipo,
		})
	}
	return out
}
