// ═══════════════════════════════════════════════════════════════
// AstroIO Launcher — Windows + Linux (v8)
//
// Launcher REAL, igual que la APK:
//   - Abre una VENTANA PROPIA (WebView2 en Windows; navegador en
//     modo app con perfil propio en Linux). No abre el navegador
//     "pelado" del sistema.
//   - PANTALLA DE CARGA con el logo oficial (el mismo del icono):
//     la ventana abre al instante; antes había que esperar a
//     ciegas hasta que el juego cargaba.
//   - ACTUALIZACIÓN NO BLOQUEANTE (v2.4.11, igual que la APK):
//     si hay versión nueva SE AVISA con dos opciones (Continuar /
//     Actualizar) y la descarga muestra %, velocidad y tiempo
//     restante; al terminar se instala sola y abre la versión
//     nueva. Antes se descargaba a la fuerza antes de entrar y en
//     Windows no se veía nada (consola oculta).
//   - Lleva las IMÁGENES DEL JUEGO DENTRO (igual que la APK) para
//     no gastar datos por gusto: un proxy local en 127.0.0.1 las
//     sirve desde el propio exe; lo estático que no lleva, lo
//     guarda en caché de disco la primera vez y ya no se baja más.
//   - Atajo/menu "Borrar datos" (--borrar-datos): limpia sesión,
//     caché y ajustes igual que la APK.
//   - NO INSTALA NADA: es portable (doble clic y funciona); el
//     Setup de Windows sigue siendo opcional.
//
// Compilar (ver build.sh): el Windows con -H=windowsgui e icono
// incrustado (.syso con rsrc); el Linux estático normal.
// ═══════════════════════════════════════════════════════════════
package main

import (
        "crypto/sha256"
        "encoding/hex"
        "fmt"
        "io"
        "net/http"
        "os"
        "os/exec"
        "path/filepath"
        "runtime"
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
// v7 (2.4.10): icono correcto — el favicon oficial del sitio
//             (logo azul), antes llevaba el de la APK.
// v8 (2.4.11): REWORK COMO LA APK v2.4.4 — pantalla de carga con
//             el logo, actualización NO bloqueante (Continuar /
//             Actualizar) con barra de %, velocidad y tiempo
//             restante, y autoinstalación. Independiente de la
//             versión de la APK (solo mira el bloque "launcher").
const launcherVersionCode = 8
const launcherVersionName = "2.4.11"

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
        // --version: muestra la versión instalada y sale (comprobaciones)
        if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "-v") {
                fmt.Printf("AstroIO Launcher %s (build %d)\n", launcherVersionName, launcherVersionCode)
                return
        }
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

        // 1) Proxy local con las imágenes embebidas + caché de disco.
        //    Desde la v2.4.11 también sirve la pantalla de carga del
        //    launcher (__launcher__). Si el proxy no pudiera arrancar
        //    (caso rarísimo), se abre la URL real del servidor.
        juegoURLLa = "https://" + serverHost() + "/game.php"
        if p, err := startProxy(cacheDir); err == nil {
                proxyActivo = p
                juegoURLLa = p.local + "/game.php"
        } else {
                fmt.Println("No se pudo iniciar el proxy local:", err)
        }

        // 2) Comprobación de versión NO BLOQUEANTE (igual que la APK):
        //    va en segundo plano y SOLO AVISA. La ventana abre YA.
        iniciarVerificacion()

        // 3) Ventana propia: WebView2 en Windows, navegador en modo
        //    app con perfil propio en Linux (ver window_*.go). Abre
        //    primero la pantalla de carga con el logo; la propia
        //    página pasa al juego cuando la comprobación termina.
        openWindow(uiURL(), datosDir)
}
