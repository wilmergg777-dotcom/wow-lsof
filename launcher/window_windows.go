//go:build windows

// ═══════════════════════════════════════════════════════════════
// AstroIO Launcher — ventana PROPIA en Windows con WebView2
// (el motor de Edge, que ya trae Windows 10/11). NO abre el
// navegador del sistema: es una ventana de aplicación con el juego
// dentro, igual que la APK tiene su WebView.
// Si el runtime de WebView2 no estuviera disponible, cae al
// navegador en modo app apuntando al MISMO proxy local.
// ═══════════════════════════════════════════════════════════════
package main

import (
	"os/exec"
	"time"

	"github.com/jchv/go-webview2"
)

func openWindow(localURL, datosDir string) {
	w := webview2.NewWithOptions(webview2.WebViewOptions{
		Debug:     false,
		DataPath:  datosDir, // los datos/sesión van a la carpeta del launcher
		AutoFocus: true,
		WindowOptions: webview2.WindowOptions{
			Title:  "AstroIO",
			Width:  1280,
			Height: 860,
			Center: true,
			IconId: 1, // icono incrustado con rsrc (build.sh)
		},
	})
	if w == nil {
		// WebView2 no disponible: navegador en modo app (respaldo)
		fallbackBrowser(localURL)
		return
	}
	w.SetTitle("AstroIO")
	w.Navigate(localURL)
	w.Run()
	w.Destroy()
}

// fallbackBrowser abre el juego en modo app del Edge/Chrome local.
// El launcher se queda vivo (espera la ventana) para que el proxy
// local con las imágenes siga sirviendo mientras se juega.
func fallbackBrowser(localURL string) {
	browser := findBrowser()
	if browser != "" {
		cmd := exec.Command(browser, "--app="+localURL, "--window-size=1280,860")
		cmd.SysProcAttr = hideWindow()
		if cmd.Start() == nil {
			cmd.Wait()
			return
		}
	}
	exec.Command("cmd", "/c", "start", "", localURL).Start()
	// Sin forma de esperar la ventana del navegador por defecto:
	// mantener el proxy vivo mientras se juega.
	time.Sleep(8 * time.Hour)
}
