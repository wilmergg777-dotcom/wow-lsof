//go:build windows

package main

import (
	"syscall"
	"unsafe"
)

// hideWindow evita que los procesos auxiliares abran consola negra.
func hideWindow() *syscall.SysProcAttr {
	return &syscall.SysProcAttr{HideWindow: true}
}

// messageBox muestra un cuadro de diálogo nativo (sin CGO).
// Devuelve el botón pulsado: 6 = IDYES, 7 = IDNO, 1 = IDOK.
func messageBox(title, text string) int {
	user32 := syscall.NewLazyDLL("user32.dll")
	mb := user32.NewProc("MessageBoxW")
	t, _ := syscall.UTF16PtrFromString(title)
	m, _ := syscall.UTF16PtrFromString(text)
	// MB_ICONINFORMATION (0x40) | MB_YESNO (0x4)
	ret, _, _ := mb.Call(0,
		uintptr(unsafe.Pointer(m)),
		uintptr(unsafe.Pointer(t)),
		uintptr(0x40|0x4))
	return int(ret)
}
