//go:build !windows

// ═══════════════════════════════════════════════════════════════
// AstroIO Launcher — ventana en Linux: navegador Chromium/Chrome/
// Edge/Brave en MODO APP con PERFIL PROPIO del launcher (igual que
// los datos de la APK): la sesión y la caché no se mezclan con las
// del navegador normal y "Borrar datos" limpia solo el juego.
// El proxy local con las imágenes embebidas funciona igual.
// ═══════════════════════════════════════════════════════════════
package main

import (
	"os/exec"
	"path/filepath"
	"time"
)

func openWindow(localURL, datosDir string) {
	browser := findBrowser()
	perfil := filepath.Join(filepath.Dir(datosDir), "perfil")

	if browser != "" {
		cmd := exec.Command(browser,
			"--app="+localURL, "--window-size=1280,860",
			"--user-data-dir="+perfil,
			"--no-first-run", "--no-default-browser-check")
		if cmd.Start() == nil {
			cmd.Wait() // el proxy sigue vivo hasta cerrar la ventana
			return
		}
	}

	// Respaldo: Firefox o el navegador por defecto del sistema
	if p, err := exec.LookPath("firefox"); err == nil {
		c := exec.Command(p, "--new-window", localURL)
		if c.Start() == nil {
			c.Wait()
			return
		}
	}
	exec.Command("xdg-open", localURL).Start()
	// Mantener el proxy vivo mientras se juega
	time.Sleep(8 * time.Hour)
}
