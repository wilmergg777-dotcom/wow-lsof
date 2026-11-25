//go:build !windows

package main

import "syscall"

// En Linux/macOS no hay ventana que ocultar (el Setup solo se
// usa en Windows; este stub existe para que el paquete compile
// en cualquier plataforma).
func hideWindow() *syscall.SysProcAttr {
	return nil
}

// Stub multiplataforma: siempre "Sí" para que el flujo sea probado.
func messageBox(title, text string) int {
	return 6
}
