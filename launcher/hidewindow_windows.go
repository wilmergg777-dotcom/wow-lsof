//go:build windows

package main

import "syscall"

// hideWindow evita que el launcher abra una consola negra en Windows
func hideWindow() *syscall.SysProcAttr {
	return &syscall.SysProcAttr{HideWindow: true}
}
