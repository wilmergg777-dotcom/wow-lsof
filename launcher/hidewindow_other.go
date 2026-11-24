//go:build !windows

package main

import "syscall"

// En Linux/macOS no hay ventana de consola que ocultar
func hideWindow() *syscall.SysProcAttr {
	return nil
}
