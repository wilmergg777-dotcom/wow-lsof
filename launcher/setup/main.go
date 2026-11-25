// ═══════════════════════════════════════════════════════════════
// AstroIO Setup — instalador de Windows hecho en Go (SIN NSIS)
//
// ¿Por qué Go y no NSIS/exe de C++? El Setup anterior (NSIS de
// 249 MB) instalaba un AstroIO.exe con un manifest SxS roto y
// Windows mostraba "la configuración en paralelo no es correcta".
// Un exe de Go es estático: no depende de ningún runtime de C++,
// así que este error es imposible por construcción.
//
// Qué hace (doble click, sin permisos de administrador):
//   1) Instala el launcher (embebido aquí dentro) en
//      %LOCALAPPDATA%\Programs\AstroIO\AstroIO.exe
//   2) Crea el acceso directo en el Escritorio y en el menú Inicio
//   3) Limpia restos de instalaciones/actualizaciones anteriores
//   4) Pregunta si quieres abrir el juego ahora
//
// Se compila SOLO con build.sh (necesita launcher.exe embebido).
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
)

// El launcher Windows se copia aquí por build.sh antes de compilar.
//
//go:embed launcher.exe
var launcherBin []byte

const setupVersion = "2.4.7"

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

	// 4) Accesos directos (Escritorio + menú Inicio) con PowerShell
	if err := createShortcuts(installDir, exePath); err != nil {
		// no es fatal: el juego funciona aunque fallen los accesos
		_ = err
	}

	// 5) ¿Abrir ahora?
	if messageBox("AstroIO",
		"AstroIO "+setupVersion+" se instaló correctamente.\n\n"+
			"Accesos directos creados en el Escritorio y en el menú Inicio.\n\n"+
			"¿Abrir el juego ahora?") == 6 { // 6 = IDYES
		cmd := exec.Command(exePath)
		cmd.Dir = installDir
		_ = cmd.Start()
	}
}

// createShortcuts genera los .lnk con PowerShell (COM WScript.Shell).
// Se escribe un .ps1 temporal para evitar problemas de escapado.
func createShortcuts(installDir, exePath string) error {
	ps := `
$ws = New-Object -ComObject WScript.Shell
$exe = $args[0]
$wdir = Split-Path $exe
$desk = [Environment]::GetFolderPath('Desktop')
$sm   = [Environment]::GetFolderPath('Programs')
foreach ($dir in @($desk, $sm)) {
  $lnk = $ws.CreateShortcut((Join-Path $dir 'AstroIO.lnk'))
  $lnk.TargetPath = $exe
  $lnk.WorkingDirectory = $wdir
  $lnk.IconLocation = "$exe,0"
  $lnk.Description = 'AstroIO'
  $lnk.Save()
}
`
	tmp := filepath.Join(os.TempDir(), "astroio-setup-shortcuts.ps1")
	if err := os.WriteFile(tmp, []byte(ps), 0644); err != nil {
		return err
	}
	defer os.Remove(tmp)

	cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
		"-WindowStyle", "Hidden", "-File", tmp, exePath)
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
