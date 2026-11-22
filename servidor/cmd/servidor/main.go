// Command servidor es el binario principal del servidor del juego Aethelgard.
//
// Uso:
//
//	servidor [-puerto 7777] [-datos ./datos]
//
// El flag -datos apunta al directorio donde se guardan cuentas y personajes.
// Se crea si no existe.
package main

import (
	"flag"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"

	"aethelgard/servidor/interno/auth"
	"aethelgard/servidor/interno/conexion"
	"aethelgard/servidor/interno/mundo"
	"aethelgard/servidor/interno/persistencia"
)

func main() {
	puerto := flag.Int("puerto", 7777, "puerto TCP del servidor")
	dirDatos := flag.String("datos", "./datos", "directorio de datos (cuentas y personajes)")
	flag.Parse()

	abs, err := filepath.Abs(*dirDatos)
	if err != nil {
		log.Fatalf("resolver ruta de datos: %v", err)
	}
	dirCuentas := filepath.Join(abs, "cuentas")
	dirPersonajes := filepath.Join(abs, "personajes")

	authGestor, err := auth.NuevoGestor(dirCuentas)
	if err != nil {
		log.Fatalf("auth: %v", err)
	}
	persist, err := persistencia.NuevoGestor(dirPersonajes)
	if err != nil {
		log.Fatalf("persistencia: %v", err)
	}

	m := mundo.NuevoMundo(mundo.ConfigMundo{
		Persist: persist,
		Auth:    authGestor,
		Hz:      mundo.HzPredeterminado,
	})
	m.Iniciar()

	srv := conexion.NuevoServidor(*puerto, authGestor, m, persist)

	// Captura de señales para apagado limpio.
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		sig := <-sigs
		log.Printf("[main] señal recibida: %v, apagando…", sig)
		srv.Detener()
		m.Detener()
	}()

	log.Printf("[main] servidor Aethelgard listo en puerto %d (datos: %s)", *puerto, abs)
	if err := srv.Escuchar(); err != nil {
		log.Fatalf("[main] servidor: %v", err)
	}
	log.Printf("[main] servidor detenido limpiamente")
}
