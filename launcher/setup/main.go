// ═══════════════════════════════════════════════════════════════
// AstroIO Setup — instalador de Windows hecho en Go (SIN NSIS)
//
// Un exe de Go es estático: no depende de ningún runtime de C++,
// así que el error "la configuración en paralelo no es correcta"
// (SxS) es imposible por construcción.
//
// Qué hace (doble click):
//   1) Instala el launcher (embebido aquí dentro) en
//      %LOCALAPPDATA%\Programs\AstroIO\AstroIO.exe
//   2) Si falta el runtime de WebView2 (el motor de ventana del
//      juego), lo INSTALA desde el instalador oficial de Microsoft
//      embebido aquí dentro (permite trabajar sin el navegador).
//   3) Crea accesos directos: Escritorio + menú Inicio, además de
//      "AstroIO - Borrar datos" y "Desinstalar AstroIO" en Inicio.
//   4) Pregunta si quieres abrir el juego ahora.
//
// Se compila SOLO con build.sh (necesita launcher.exe y
// webview2bootstrapper.exe embebidos).
// ═══════════════════════════════════════════════════════════════
package main

import (
	_ "embed"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"golang.org/x/sys/windows/registry"
)

// El launcher Windows se copia aquí por build.sh antes de compilar.
//
//go:embed launcher.exe
var launcherBin []byte

// Instalador oficial del runtime WebView2 (bootstrapper de
// Microsoft). build.sh lo descarga antes de compilar.
//
//go:embed webview2bootstrapper.exe
var wv2Setup []byte

const setupVersion = "2.4.9"

// Clave del runtime WebView2 en el registro de Windows
const wv2Reg = `SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}`

func main() {
	if runtime.GOOS != "windows" {
		fmt.Println("Este instalador es solo para Windows.")
		os.Exit(1)
	}

	local := os.Getenv("LocalAppData")
	if local == "" {
		fatal("No se pudo encontrar la carpeta de datos del usuario (%LOCALAPPDATA%).")
		return
	}

	installDir := filepath.Join(local, "Programs", "AstroIO")
	exePath := filepath.Join(installDir, "AstroIO.exe")

	// 1) Carpeta de instalación
	if err := os.MkdirAll(installDir, 0755); err != nil {
		fatal("No se pudo crear la carpeta de instalación:\n" + err.Error())
		return
	}

	// 2) Limpiar restos de versiones anteriores (por si acaso)
	os.Remove(exePath + ".download")
	os.Remove(exePath + ".old.exe")

	// 3) Escribir el launcher
	if err := os.WriteFile(exePath, launcherBin, 0755); err != nil {
		fatal("No se pudo escribir AstroIO.exe (¿está el juego abierto?\nCierra AstroIO e inténtalo de nuevo):\n" + err.Error())
		return
	}

	// 4) Runtime WebView2: si falta, instalarlo (motor de la ventana)
	if !webview2Installed() {
		messageBox("AstroIO",
			"Falta un componente de Windows (WebView2) que el juego\n" +
			"necesita para abrir su ventana.\n\nSe instala ahora — puede pedir permiso de administrador.")
		installWebView2()
		if !webview2Installed() {
			messageBox("AstroIO",
				"No se pudo instalar el componente WebView2.\n" +
				"Comprueba tu conexión a Internet y vuelve a ejecutar el instalador.")
		}
	}

	// 5) Desinstalador (script en la carpeta de instalación)
	writeUninstaller(installDir)

	// 6) Accesos directos (Escritorio + menú Inicio + extras)
	if err := createShortcuts(installDir, exePath); err != nil {
		// no es fatal: el juego funciona aunque fallen los accesos
		_ = err
	}

	// 7) ¿Abrir ahora?
	if messageBox("AstroIO",
		"AstroIO "+setupVersion+" se instaló correctamente.\n\n"+
			"Accesos directos creados en el Escritorio y en el menú Inicio\n"+
			"(también \"AstroIO - Borrar datos\" y \"Desinstalar AstroIO\").\n\n"+
			"¿Abrir el juego ahora?") == 6 { // 6 = IDYES
		cmd := exec.Command(exePath)
		cmd.Dir = installDir
		_ = cmd.Start()
	}
}

// webview2Installed comprueba en el registro si el runtime ya está.
func webview2Installed() bool {
	for _, root := range []registry.Key{registry.LOCAL_MACHINE, registry.CURRENT_USER} {
		for _, sub := range []string{wv2Reg, `SOFTWARE\WOW6432Node\` + wv2Reg} {
			k, err := registry.OpenKey(root, sub, registry.QUERY_VALUE)
			if err != nil {
				continue
			}
			pv, _, err := k.GetStringValue("pv")
			k.Close()
			if err == nil && pv != "" && pv != "0.0.0.0" {
				return true
			}
		}
	}
	return false
}

// installWebView2 ejecuta el instalador oficial embebido en silencio.
func installWebView2() {
	tmp := filepath.Join(os.TempDir(), "AstroIO-WebView2-Setup.exe")
	if err := os.WriteFile(tmp, wv2Setup, 0755); err != nil {
		return
	}
	defer os.Remove(tmp)
	// "start /wait" dispara el UAC si hace falta y espera el resultado
	cmd := exec.Command("cmd", "/c", "start", "/wait", "", tmp, "/silent", "/install")
	cmd.SysProcAttr = hideWindow()
	_ = cmd.Run()
}

// writeUninstaller deja el script que borra accesos, datos y archivos.
func writeUninstaller(installDir string) {
	ps := `$lnks = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))
foreach ($d in $lnks) {
  foreach ($n in @('AstroIO.lnk','AstroIO - Borrar datos.lnk','Desinstalar AstroIO.lnk')) {
    Remove-Item (Join-Path $d $n) -ErrorAction SilentlyContinue
  }
}
Remove-Item "$env:LOCALAPPDATA\AstroIO" -Recurse -Force -ErrorAction SilentlyContinue
Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-Command',"Start-Sleep 1; Remove-Item '$PSScriptRoot' -Recurse -Force -ErrorAction SilentlyContinue"
`
	_ = os.WriteFile(filepath.Join(installDir, "desinstalar.ps1"), []byte(ps), 0644)
}

// createShortcuts genera los .lnk con PowerShell (COM WScript.Shell).
func createShortcuts(installDir, exePath string) error {
	ps := `
$ws = New-Object -ComObject WScript.Shell
$exe = $args[0]
$ps1 = $args[1]
$wdir = Split-Path $exe
$desk = [Environment]::GetFolderPath('Desktop')
$sm   = [Environment]::GetFolderPath('Programs')
$mk = {
  param($dir, $name, $target, $largs)
  $lnk = $ws.CreateShortcut((Join-Path $dir $name))
  $lnk.TargetPath = $target
  if ($largs) { $lnk.Arguments = $largs }
  $lnk.WorkingDirectory = $wdir
  $lnk.IconLocation = "$exe,0"
  $lnk.Description = 'AstroIO'
  $lnk.Save()
}
foreach ($dir in @($desk, $sm)) { & $mk $dir 'AstroIO.lnk' $exe $null }
& $mk $sm 'AstroIO - Borrar datos.lnk' $exe '--borrar-datos'
& $mk $sm 'Desinstalar AstroIO.lnk' 'powershell.exe' ('-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $ps1 + '"')
`
	tmp := filepath.Join(os.TempDir(), "astroio-setup-shortcuts.ps1")
	if err := os.WriteFile(tmp, []byte(ps), 0644); err != nil {
		return err
	}
	defer os.Remove(tmp)

	cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
		"-WindowStyle", "Hidden", "-File", tmp, exePath,
		filepath.Join(installDir, "desinstalar.ps1"))
	cmd.SysProcAttr = hideWindow()
	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("powershell: %v: %s", err, strings.TrimSpace(string(out)))
	}
	return nil
}

func fatal(msg string) {
	messageBox("AstroIO — Instalador", msg)
	os.Exit(1)
}
