// ═══════════════════════════════════════════════════════════════
// AstroIO Launcher — Windows + Linux (v6)
//
// Launcher REAL, igual que la APK:
//   - Abre una VENTANA PROPIA (WebView2 en Windows; navegador en
//     modo app con perfil propio en Linux). No abre el navegador
//     "pelado" del sistema.
//   - Lleva las IMÁGENES DEL JUEGO DENTRO (igual que la APK) para
//     no gastar datos por gusto: un proxy local en 127.0.0.1 las
//     sirve desde el propio exe; lo estático que no lleva, lo
//     guarda en caché de disco la primera vez y ya no se baja más.
//   - Atajo/menu "Borrar datos" (--borrar-datos): limpia sesión,
//     caché y ajustes igual que la APK.
//   - Se AUTO-ACTUALIZA consultando version.json en el servidor
//     (descarga, verifica SHA-256 y se reemplaza sola).
//
// Compilar (ver build.sh): el Windows con -H=windowsgui e icono
// incrustado (.syso con rsrc); el Linux estático normal.
// ═══════════════════════════════════════════════════════════════
package main

import (
        "crypto/sha256"
        "encoding/hex"
        "encoding/json"
        "fmt"
        "io"
        "net/http"
        "os"
        "os/exec"
        "path/filepath"
        "runtime"
        "strings"
        "time"
)

// ── Configuración (misma ofuscación XOR 0x5A que la APK) ───────
const xorKey = 0x5A
const hostEnc = "3b292e28353335743e2f39313e34297435283d" // astroio.duckdns.org

// Versión de ESTE launcher (subir +1 y recompilar para publicar)
// v5 (2.4.8): icono incrustado en los exes de Windows.
// v6 (2.4.9): ventana PROPIA con WebView2 (no abre el navegador),
//             imágenes del juego embebidas + caché de disco (no
//             gastan datos), atajo "Borrar datos" como la APK.
const launcherVersionCode = 6
const launcherVersionName = "2.4.9"

func deobf(hexStr string) string {
        raw := make([]byte, len(hexStr)/2)
        for i := 0; i < len(raw); i++ {
                hi := hexVal(hexStr[i*2])
                lo := hexVal(hexStr[i*2+1])
                raw[i] = ((hi << 4) | lo) ^ xorKey
        }
        return string(raw)
}

func hexVal(c byte) byte {
        switch {
        case c >= '0' && c <= '9':
                return c - '0'
        case c >= 'a' && c <= 'f':
                return c - 'a' + 10
        case c >= 'A' && c <= 'F':
                return c - 'A' + 10
        }
        return 0
}

func serverHost() string { return deobf(hostEnc) }

func versionURL() string { return "https://" + serverHost() + "/apk/version.json" }

// ── Carpetas de datos del launcher (como los datos de la APK) ──
// Windows: %LOCALAPPDATA%\AstroIO\{datos,cache}
// Linux:   ~/.local/share/AstroIO/{datos,cache,perfil}
func dataRoot() string {
        if runtime.GOOS == "windows" {
                local := os.Getenv("LocalAppData")
                if local == "" {
                        local = "."
                }
                return filepath.Join(local, "AstroIO")
        }
        home, err := os.UserHomeDir()
        if err != nil {
                home = "."
        }
        return filepath.Join(home, ".local", "share", "AstroIO")
}

// ── Estructura de version.json ─────────────────────────────────
type launcherTarget struct {
        URL string `json:"url"`
        Sha string `json:"sha256"`
}
type launcherBlock struct {
        VersionCode int            `json:"versionCode"`
        VersionName string         `json:"versionName"`
        Windows     launcherTarget `json:"windows"`
        Linux       launcherTarget `json:"linux"`
}
type serverVersion struct {
        VersionCode int           `json:"versionCode"`
        VersionName string        `json:"versionName"`
        URL         string        `json:"url"`
        Sha256      string        `json:"sha256"`
        Launcher    launcherBlock `json:"launcher"`
}

// ── HTTP con límite de tiempo (comprobaciones cortas) ──────────
func httpGet(url string, seconds int) (*http.Response, error) {
        client := &http.Client{Timeout: time.Duration(seconds) * time.Second}
        req, err := http.NewRequest("GET", url, nil)
        if err != nil {
                return nil, err
        }
        req.Header.Set("User-Agent", "AstroIOLauncher/"+launcherVersionName)
        return client.Do(req)
}

// ── Verificación SHA-256 de un archivo ─────────────────────────
func fileSha256(path string) (string, error) {
        f, err := os.Open(path)
        if err != nil {
                return "", err
        }
        defer f.Close()
        h := sha256.New()
        if _, err := io.Copy(h, f); err != nil {
                return "", err
        }
        return hex.EncodeToString(h.Sum(nil)), nil
}

// ── Auto-actualización ─────────────────────────────────────────
func selfUpdate(sv *serverVersion) bool {
        var target launcherTarget
        switch runtime.GOOS {
        case "windows":
                target = sv.Launcher.Windows
        case "linux":
                target = sv.Launcher.Linux
        default:
                return false
        }
        if target.URL == "" {
                return false
        }

        fmt.Println("Descargando nueva version del launcher...")
        // SIN timeout total: el launcher ahora es grande porque lleva
        // las imágenes del juego dentro (como la APK). El SHA-256
        // garantiza que lo descargado esté completo y sea auténtico.
        req, err := http.NewRequest("GET", target.URL, nil)
        if err != nil {
                fmt.Println("No se pudo descargar la actualizacion:", err)
                return false
        }
        req.Header.Set("User-Agent", "AstroIOLauncher/"+launcherVersionName)
        resp, err := (&http.Client{}).Do(req)
        if err != nil || resp.StatusCode != 200 {
                fmt.Println("No se pudo descargar la actualizacion:", err)
                return false
        }
        defer resp.Body.Close()

        exePath, err := os.Executable()
        if err != nil {
                return false
        }
        if resolved, err := filepath.EvalSymlinks(exePath); err == nil {
                exePath = resolved
        }
        dir := filepath.Dir(exePath)
        tmpPath := filepath.Join(dir, filepath.Base(exePath)+".download")

        out, err := os.Create(tmpPath)
        if err != nil {
                return false
        }
        _, copyErr := io.Copy(out, resp.Body)
        closeErr := out.Close()
        if copyErr != nil || closeErr != nil {
                os.Remove(tmpPath)
                return false
        }

        // Verificar SHA-256 antes de tocar nada
        got, err := fileSha256(tmpPath)
        if err != nil || strings.ToLower(got) != strings.ToLower(strings.TrimSpace(target.Sha)) {
                fmt.Println("SHA-256 no coincide, se cancela la actualizacion")
                os.Remove(tmpPath)
                return false
        }

        // Reemplazarse a sí mismo:
        //   1) mover el exe actual a .old
        //   2) mover el nuevo al lugar del original
        //   3) ejecutar el nuevo y salir (el .old se borra en el próximo arranque)
        var oldPath string
        if runtime.GOOS == "windows" {
                oldPath = exePath + ".old.exe"
        } else {
                oldPath = exePath + ".old"
        }
        os.Remove(oldPath)
        if err := os.Rename(exePath, oldPath); err != nil {
                os.Remove(tmpPath)
                fmt.Println("No se pudo reemplazar el launcher:", err)
                return false
        }
        if err := os.Rename(tmpPath, exePath); err != nil {
                // restaurar el original para no dejar el launcher roto
                os.Rename(oldPath, exePath)
                os.Remove(tmpPath)
                return false
        }
        os.Chmod(exePath, 0755)

        // Lanzar la versión nueva y salir
        cmd := exec.Command(exePath)
        if runtime.GOOS == "windows" {
                cmd.SysProcAttr = hideWindow()
        }
        if err := cmd.Start(); err != nil {
                // si falla, seguimos y abrimos el juego con esta versión
                return false
        }
        fmt.Println("Launcher actualizado a la version", sv.Launcher.VersionName)
        os.Exit(0)
        return true
}

func cleanupOld() {
        exePath, err := os.Executable()
        if err != nil {
                return
        }
        os.Remove(exePath + ".old.exe")
        os.Remove(exePath + ".old")
        os.Remove(filepath.Join(filepath.Dir(exePath), filepath.Base(exePath)+".download"))
}

// ── Buscar navegador con modo --app (respaldo) ─────────────────
func findBrowser() string {
        if runtime.GOOS == "windows" {
                candidates := []string{
                        // Edge y Chrome: rutas estándar de instalación
                        filepath.Join(os.Getenv("ProgramFiles(x86)"), "Microsoft", "Edge", "Application", "msedge.exe"),
                        filepath.Join(os.Getenv("ProgramFiles"), "Microsoft", "Edge", "Application", "msedge.exe"),
                        filepath.Join(os.Getenv("LocalAppData"), "Google", "Chrome", "Application", "chrome.exe"),
                        filepath.Join(os.Getenv("ProgramFiles"), "Google", "Chrome", "Application", "chrome.exe"),
                        filepath.Join(os.Getenv("ProgramFiles(x86)"), "Google", "Chrome", "Application", "chrome.exe"),
                        filepath.Join(os.Getenv("LocalAppData"), "Microsoft", "Edge", "Application", "msedge.exe"),
                }
                for _, p := range candidates {
                        if p != "" && fileExists(p) {
                                return p
                        }
                }
                return ""
        }
        // Linux: chromium y derivados soportan --app
        names := []string{
                "chromium", "chromium-browser", "google-chrome", "google-chrome-stable",
                "brave-browser", "microsoft-edge", "microsoft-edge-stable", "vivaldi",
        }
        for _, n := range names {
                if p, err := exec.LookPath(n); err == nil {
                        return p
                }
        }
        return ""
}

func fileExists(p string) bool {
        _, err := os.Stat(p)
        return err == nil
}

func main() {
        cleanupOld()
        fmt.Printf("AstroIO Launcher v%s (build %d)\n", launcherVersionName, launcherVersionCode)

        root := dataRoot()
        datosDir := filepath.Join(root, "datos")
        cacheDir := filepath.Join(root, "cache")

        // 0) --borrar-datos: limpia sesión, caché y ajustes (igual que la APK).
        //    El Setup/Linux crean un acceso directo que pasa este flag.
        if len(os.Args) > 1 && (os.Args[1] == "--borrar-datos" || os.Args[1] == "--clear-data") {
                fmt.Println("Borrando datos del juego (sesión, caché y ajustes)...")
                os.RemoveAll(root)
        }
        os.MkdirAll(datosDir, 0755)
        os.MkdirAll(cacheDir, 0755)

        // 1) Comprobar si hay launcher nuevo (mismo mecanismo que la APK)
        resp, err := httpGet(versionURL(), 6)
        if err != nil {
                fmt.Println("Sin conexion con el servidor, abriendo el juego...")
        } else {
                body, err := io.ReadAll(resp.Body)
                resp.Body.Close()
                if err == nil {
                        var sv serverVersion
                        if json.Unmarshal(body, &sv) == nil && sv.Launcher.VersionCode > launcherVersionCode {
                                selfUpdate(&sv) // si reemplaza y relanza, no vuelve aquí
                        }
                }
        }

        // 2) Proxy local con las imágenes embebidas + caché de disco.
        //    Si el proxy no pudiera arrancar (caso rarísimo), se abre
        //    la URL real del servidor directamente.
        localURL := "https://" + serverHost() + "/game.php"
        if p, err := startProxy(cacheDir); err == nil {
                localURL = p.local + "/game.php"
        } else {
                fmt.Println("No se pudo iniciar el proxy local:", err)
        }

        // 3) Ventana propia: WebView2 en Windows, navegador en modo
        //    app con perfil propio en Linux (ver window_*.go).
        openWindow(localURL, datosDir)
}
