// ═══════════════════════════════════════════════════════════════
// AstroIO Launcher — UI propia (v10 / 2.4.13), IGUAL QUE LA APK:
//
//   1) PANTALLA DE CARGA con el logo oficial (el mismo del icono):
//      la ventana abre AL INSTANTE mostrando el logo y
//      "Comprobando versión…" — antes el jugador hacía doble clic
//      y no veía nada hasta que el juego cargaba.
//   2) ACTUALIZACIÓN NO BLOQUEANTE: si hay versión nueva se AVISA
//      con dos opciones (Continuar / Actualizar). Nada impide
//      entrar al juego. Antes se descargaba a la fuerza ANTES de
//      abrir la ventana y en Windows no se veía nada (sin consola).
//   3) BARRA DE PROGRESO con porcentaje, MB, VELOCIDAD por momento
//      y TIEMPO RESTANTE, y al terminar se reemplaza solo y abre
//      la versión nueva (autoinstalación, como la APK).
//   4) CONEXIÓN ROBUSTA (v9 / 2.4.12): 3 intentos de version.json
//      (12 s cada uno) + comprobación de si el juego responde antes
//      de marcar "Sin conexión". Con el servidor online ya NO aparece
//      el aviso por gusto; y si el servidor está caído de verdad, la
//      pantalla de error solo ofrece Reintentar (el botón Continuar
//      queda reservado a cuando HAY una versión nueva).
//
// Todo funciona por el proxy local ya existente (127.0.0.1): la
// ventana (WebView2 en Windows / modo app en Linux) carga una
// página __launcher__ que consulta el estado por JSON.
// ═══════════════════════════════════════════════════════════════
package main

import (
        "encoding/json"
        "fmt"
        "io"
        "net/http"
        "os"
        "os/exec"
        "path/filepath"
        "runtime"
        "strings"
        "sync"
        "sync/atomic"
        "time"

        _ "embed"
)

//go:embed assets/logo.png
var logoPNG []byte // logo oficial (el mismo del icono/favicon)

// Estado compartido entre la comprobación/descarga y la página UI.
type estadoUI struct {
        Fase         string `json:"fase"` // comprobando|al_dia|actualizacion|sin_conexion|descargando|listo|error_dl
        VersionNueva string `json:"versionNueva,omitempty"`
        Juego        string `json:"juego"`          // URL del juego (por el proxy local)
        Pct          int    `json:"pct"`            // 0..100
        Descargado   int64  `json:"descargadoMB"`   // MB descargados
        Total        int64  `json:"totalMB"`        // MB totales
        Velocidad    string `json:"velocidad"`      // "3,4 MB/s" (suavizada)
        Eta          string `json:"eta"`            // "1m 20s"
        Error        string `json:"error,omitempty"`
        Intento      int    `json:"intento"`        // v10: intento N de la auto-recconexión (0 = sin auto)
        Cuenta       int    `json:"cuenta"`         // v10: cuenta atrás para el próximo intento (s)
}

var (
        muEstado    sync.Mutex
        est         estadoUI
        proxyActivo *proxyServer // lo asigna main() tras arrancar el proxy
        juegoURLLa  string       // URL del juego (proxy local o servidor directo)
        svNueva     *serverVersion
        descargando bool
        verGen      int64 // v10: generación de la verificación en curso (cancela bucles viejos)
)

func estadoActual() estadoUI {
        muEstado.Lock()
        defer muEstado.Unlock()
        e := est
        e.Juego = juegoURLLa
        return e
}

func ponerEstado(e estadoUI) {
        muEstado.Lock()
        est = e
        muEstado.Unlock()
}

// uiURL devuelve la URL de la pantalla de carga (si no hay proxy,
// se abre el juego directo como antes: caso rarísimo).
func uiURL() string {
        if proxyActivo != nil {
                return proxyActivo.local + "/__launcher__"
        }
        return juegoURLLa
}

// ═══════════════════════════════════════════════════════════════
//  Rutas que el proxy sirve ANTES de reenviar al servidor
// ═══════════════════════════════════════════════════════════════

func launcherRoutes(mux *http.ServeMux) {
        mux.HandleFunc("/__launcher__", func(w http.ResponseWriter, r *http.Request) {
                w.Header().Set("Content-Type", "text/html; charset=utf-8")
                w.Header().Set("Cache-Control", "no-store")
                io.WriteString(w, paginaLauncher)
        })
        mux.HandleFunc("/__logo__", func(w http.ResponseWriter, r *http.Request) {
                w.Header().Set("Content-Type", "image/png")
                w.Header().Set("Cache-Control", "public, max-age=86400")
                w.Write(logoPNG)
        })
        mux.HandleFunc("/__estado__", func(w http.ResponseWriter, r *http.Request) {
                respondeJSON(w, estadoActual())
        })
        mux.HandleFunc("/__reintentar__", func(w http.ResponseWriter, r *http.Request) {
                e := estadoActual()
                if e.Fase == "sin_conexion" || e.Fase == "error_dl" {
                        iniciarVerificacion()
                }
                respondeJSON(w, estadoActual())
        })
        mux.HandleFunc("/__actualizar__", func(w http.ResponseWriter, r *http.Request) {
                e := estadoActual()
                if e.Fase == "actualizacion" && svNueva != nil && !descargando {
                        descargando = true
                        go descargarActualizacion(svNueva)
                }
                respondeJSON(w, estadoActual())
        })
        // v10 (2.4.13): antes de navegar al juego se comprueba que
        // responde (por el proxy local y, si no, directo al servidor).
        // Devuelve {"url": ...} para navegar, o {"url": ""} si no hay
        // forma (en cuyo caso el launcher ya relanzó la verificación
        // con auto-recconexión y la página se queda esperando).
        mux.HandleFunc("/__entrar__", func(w http.ResponseWriter, r *http.Request) {
                respondeJSON(w, map[string]string{"url": urlParaEntrar()})
        })
}

func respondeJSON(w http.ResponseWriter, v interface{}) {
        w.Header().Set("Content-Type", "application/json; charset=utf-8")
        w.Header().Set("Cache-Control", "no-store")
        json.NewEncoder(w).Encode(v)
}

// ═══════════════════════════════════════════════════════════════
//  Comprobación de versión (NO bloqueante, en goroutine)
// ═══════════════════════════════════════════════════════════════

// iniciarVerificacion consulta version.json comparando SOLO el
// bloque launcher (las versiones de la APK y del launcher son
// independientes: una APK nueva NO avisa al launcher y viceversa).
//
// v10 (2.4.13) — AUTO-RECONECTA: esa pantalla ya no se queda muerta
//   esperando clicks. Un bucle en segundo plano reintenta cada 6 s
//   (muestra "intento N · reintento en Xs") y en cuanto el servidor
//   contesta pasa a "al_dia" y la página ENTRA SOLA. Reintentar
//   sigue para forzar un intento inmediato: reinicia la verificación
//   (y con ella el contador de generación, que cancela el bucle
//   anterior para que nunca haya dos bucles a la vez).
func iniciarVerificacion() {
        gen := atomic.AddInt64(&verGen, 1)
        ponerEstado(estadoUI{Fase: "comprobando"})
        go func() {
                var body []byte
                for intento := 1; intento <= 3; intento++ {
                        resp, e := httpGet(versionURL(), 12)
                        if e == nil {
                                b, errRead := io.ReadAll(resp.Body)
                                resp.Body.Close()
                                if errRead == nil {
                                        body = b
                                        break
                                }
                        }
                        if genCancelado(gen) {
                                return
                        }
                        if intento < 3 {
                                time.Sleep(time.Duration(intento) * time.Second)
                        }
                }
                if genCancelado(gen) {
                        return
                }
                if len(body) == 0 {
                        // version.json inaccesible tras 3 intentos:
                        // ¿responde el juego en sí?
                        if juegoResponde() {
                                ponerEstado(estadoUI{Fase: "al_dia"})
                                return
                        }
                        conectarEnBucle(gen) // v10: auto-recconexión en segundo plano
                        return
                }
                var sv serverVersion
                if json.Unmarshal(body, &sv) != nil || sv.Launcher.VersionCode <= launcherVersionCode {
                        // Al día (o sin archivo de versiones aún): entrar al juego.
                        ponerEstado(estadoUI{Fase: "al_dia"})
                        return
                }
                // Hay versión nueva: SE AVISA, no se fuerza nada.
                muEstado.Lock()
                svNueva = &sv
                muEstado.Unlock()
                ponerEstado(estadoUI{Fase: "actualizacion", VersionNueva: sv.Launcher.VersionName})
        }()
}

// genCancelado dice si esta verificación ya fue sustituida por otra
// (Reintentar manual, /__entrar__...) y por tanto debe abortar.
func genCancelado(gen int64) bool { return atomic.LoadInt64(&verGen) != gen }

// conectarEnBucle es la AUTO-RECONECCIÓN (v10 / 2.4.13): reintenta
// cada 6 s hasta 60 veces (≈ 8 min) mientras el jugador vea la
// pantalla. Cada ciclo actualiza el intento y la cuenta atrás para
// que el jugador vea que la app está trabajando; en cuanto el juego
// responde pasa a "al_dia" y la UI entra sola. Si llega al final se
// queda en "Sin conexión" con el botón Reintentar (intento manual).
func conectarEnBucle(gen int64) {
        for intento := 1; intento <= 60; intento++ {
                for cuenta := 6; cuenta > 0; cuenta-- {
                        if genCancelado(gen) {
                                return
                        }
                        muEstado.Lock()
                        est = estadoUI{Fase: "sin_conexion", Intento: intento, Cuenta: cuenta}
                        muEstado.Unlock()
                        time.Sleep(1 * time.Second)
                }
                if genCancelado(gen) {
                        return
                }
                if juegoRespondeRapido() {
                        ponerEstado(estadoUI{Fase: "al_dia"})
                        return
                }
        }
        muEstado.Lock()
        est = estadoUI{Fase: "sin_conexion"}
        muEstado.Unlock()
}

// juegoResponde comprueba si el servidor del juego está ONLINE.
// Cualquier respuesta HTTP cuenta (200, 302, 403...): lo único que
// cuenta como "caído" es que no haya respuesta (DNS/TCP/TLS/timeout).
// Sirve para no marcar "Sin conexión" cuando version.json falla por
// un mal intento aislado pero el juego va bien.
func juegoResponde() bool {
        return juegoRespondeEn("https://"+serverHost()+"/game.php", 10)
}

// juegoRespondeRapido es la versión CORTA para el bucle de
// auto-recconexión (6 s): si el servidor no contesta en 6 s se pasa
// al siguiente intento sin bloquear demasiado.
func juegoRespondeRapido() bool {
        return juegoRespondeEn("https://"+serverHost()+"/game.php", 6)
}

// juegoRespondeEn comprueba si una URL responde con cualquier código
// HTTP dentro de un límite de segundos.
func juegoRespondeEn(url string, segundos int) bool {
        resp, err := httpGet(url, segundos)
        if err != nil {
                return false
        }
        resp.Body.Close()
        return true
}

// urlParaEntrar (v10 / 2.4.13) decide POR DÓNDE entrar al juego
// ANTES de navegar, para que nunca aparezca una página de error de
// WebView a medio camino:
//   1) Por el proxy local (el camino normal: sirve las imágenes
//      embebidas y cachea estáticos).
//   2) Si el juego no responde por el proxy, DIRECTO al servidor
//      (por si el proxy local se quedó sin puerto o algo puntual).
//   3) Si tampoco responde directo, se relanza la verificación con
//      auto-recconexión y se devuelve "": la página se queda en el
//      loader en vez de navegar a una pantalla de error.
func urlParaEntrar() string {
        if proxyActivo != nil && juegoRespondeEn(proxyActivo.local+"/game.php", 6) {
                return proxyActivo.local + "/game.php"
        }
        if juegoRespondeEn("https://"+serverHost()+"/game.php", 6) {
                return "https://" + serverHost() + "/game.php"
        }
        iniciarVerificacion()
        return ""
}

// ═══════════════════════════════════════════════════════════════
//  Descarga de la versión nueva con progreso (% + velocidad + ETA)
//  y reemplazo del launcher (autoinstalación, como la APK)
// ═══════════════════════════════════════════════════════════════

func descargarActualizacion(sv *serverVersion) {
        var target launcherTarget
        switch runtime.GOOS {
        case "windows":
                target = sv.Launcher.Windows
        case "linux":
                target = sv.Launcher.Linux
        default:
                descargando = false
                return
        }
        if target.URL == "" {
                ponerEstado(estadoUI{Fase: "error_dl", Error: "El servidor no publica todavía la versión nueva para este sistema."})
                descargando = false
                return
        }

        // SIN timeout total (el launcher es grande, lleva las imágenes
        // del juego dentro, como la APK): el SHA-256 garantiza la
        // descarga completa y auténtica.
        req, err := http.NewRequest("GET", target.URL, nil)
        if err != nil {
                falloDescarga("No se pudo iniciar la descarga.")
                return
        }
        req.Header.Set("User-Agent", "AstroIOLauncher/"+launcherVersionName)
        resp, err := (&http.Client{}).Do(req)
        if err != nil || resp.StatusCode != 200 {
                falloDescarga("Sin conexión con el servidor de descargas.")
                return
        }
        defer resp.Body.Close()
        total := resp.ContentLength // si llega <=0, la barra muestra solo velocidad

        exePath, err := os.Executable()
        if err != nil {
                falloDescarga("No se encontró el launcher.")
                return
        }
        if resolved, err := filepath.EvalSymlinks(exePath); err == nil {
                exePath = resolved
        }
        tmpPath := filepath.Join(filepath.Dir(exePath), filepath.Base(exePath)+".download")

        out, err := os.Create(tmpPath)
        if err != nil {
                falloDescarga("No se pudo escribir en la carpeta del launcher (¿permisos?).")
                return
        }

        // Copia con progreso: % + velocidad suavizada + tiempo restante
        buf := make([]byte, 65536)
        var leidos int64
        var tMuestra = time.Now()
        var leidosMuestra int64
        var velocidad float64
        var ultimaUI time.Time
        pct := -1
        for {
                n, errRead := resp.Body.Read(buf)
                if n > 0 {
                        out.Write(buf[:n])
                        leidos += int64(n)
                        ahora := time.Now()
                        dt := ahora.Sub(tMuestra).Seconds()
                        if dt >= 0.3 {
                                vInst := float64(leidos-leidosMuestra) / dt
                                if velocidad <= 0 {
                                        velocidad = vInst
                                } else {
                                        velocidad = 0.4*vInst + 0.6*velocidad
                                }
                                tMuestra = ahora
                                leidosMuestra = leidos
                        }
                        if total > 0 {
                                p := int(leidos * 100 / total)
                                if p != pct || ahora.Sub(ultimaUI) >= time.Second {
                                        pct = p
                                        ultimaUI = ahora
                                        e := estadoActual()
                                        e.Fase = "descargando"
                                        e.Pct = p
                                        e.Descargado = leidos / 1048576
                                        e.Total = total / 1048576
                                        e.Velocidad = textoVelocidad(velocidad)
                                        if velocidad > 0 {
                                                e.Eta = etaTexto(int64(float64(total-leidos) / velocidad))
                                        } else {
                                                e.Eta = "…"
                                        }
                                        ponerEstado(e)
                                }
                        }
                }
                if errRead != nil {
                        if errRead == io.EOF {
                                break
                        }
                        out.Close()
                        os.Remove(tmpPath)
                        falloDescarga("La descarga se cortó. Revisa tu Internet y reintenta.")
                        descargando = false
                        return
                }
        }
        out.Close()

        // Verificar SHA-256 ANTES de tocar nada
        got, err := fileSha256(tmpPath)
        if err != nil || strings.ToLower(got) != strings.ToLower(strings.TrimSpace(target.Sha)) {
                os.Remove(tmpPath)
                falloDescarga("El paquete descargado no pasó la verificación de integridad.")
                descargando = false
                return
        }

        // "Instalando": reemplazarse a sí mismo y relanzar la versión nueva
        e := estadoActual()
        e.Fase = "listo"
        ponerEstado(e)

        var oldPath string
        if runtime.GOOS == "windows" {
                oldPath = exePath + ".old.exe"
        } else {
                oldPath = exePath + ".old"
        }
        os.Remove(oldPath)
        if err := os.Rename(exePath, oldPath); err != nil {
                os.Remove(tmpPath)
                falloDescarga("No se pudo reemplazar el launcher (¿está en una carpeta protegida?).")
                descargando = false
                return
        }
        if err := os.Rename(tmpPath, exePath); err != nil {
                os.Rename(oldPath, exePath) // restaurar para no romper el launcher
                os.Remove(tmpPath)
                falloDescarga("No se pudo instalar la versión nueva.")
                descargando = false
                return
        }
        os.Chmod(exePath, 0755)

        // Lanzar la versión nueva y salir: la ventana nueva aparece sola
        cmd := exec.Command(exePath)
        if runtime.GOOS == "windows" {
                cmd.SysProcAttr = hideWindow()
        }
        if err := cmd.Start(); err != nil {
                // La versión ya está instalada: que el jugador la abra de nuevo
                ponerEstado(estadoUI{Fase: "al_dia"})
                descargando = false
                return
        }
        os.Exit(0)
}

func falloDescarga(msg string) {
        e := estadoActual()
        e.Fase = "error_dl"
        e.Error = msg
        ponerEstado(e)
}

// textoVelocidad formatea bytes/s ("3,4 MB/s"; "…" mientras mide).
func textoVelocidad(v float64) string {
        if v <= 0 {
                return "…"
        }
        if v < 1048576 {
                return fmt.Sprintf("%.0f KB/s", v/1024)
        }
        return fmt.Sprintf("%.1f MB/s", v/1048576)
}

// etaTexto convierte segundos a texto corto ("45s", "2m 05s", "1h 12m").
func etaTexto(seg int64) string {
        if seg < 0 {
                seg = 0
        }
        if seg < 60 {
                return fmt.Sprintf("%ds", seg)
        }
        m := seg / 60
        s := seg % 60
        if m < 60 {
                if s < 10 {
                        return fmt.Sprintf("%dm 0%ds", m, s)
                }
                return fmt.Sprintf("%dm %ds", m, s)
        }
        h := m / 60
        m = m % 60
        if m < 10 {
                return fmt.Sprintf("%dh 0%dm", h, m)
        }
        return fmt.Sprintf("%dh %dm", h, m)
}

// ═══════════════════════════════════════════════════════════════
//  Página de la UI (pantalla de carga + aviso + barra de progreso)
//  Colores IGUALES que la APK: fondo #0A0F1A, tarjetas #131A2A,
//  cian #00E0FF, verde #00CC66.
// ═══════════════════════════════════════════════════════════════

const paginaLauncher = `<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>AstroIO</title>
<link rel="icon" href="/__logo__">
<style>
  html,body{margin:0;height:100%;background:#0A0F1A;color:#fff;
    font-family:'Segoe UI',system-ui,sans-serif;display:flex;
    align-items:center;justify-content:center;user-select:none}
  .caja{width:min(560px,92vw);background:#131A2A;border:1px solid #223050;
    border-radius:16px;padding:36px 32px;text-align:center;
    box-shadow:0 12px 40px rgba(0,0,0,.5)}
  .logo{width:120px;height:120px}
  h1{margin:14px 0 4px;font-size:26px;letter-spacing:1px}
  .sub{color:#8fa0b8;font-size:13px;margin-bottom:22px}
  #mensaje{font-size:15px;color:#cfe2ff;min-height:22px;margin-bottom:14px}
  .punto{display:inline-block;width:9px;height:9px;border-radius:50%;
    background:#00E0FF;margin-right:8px;animation:par 1s infinite alternate}
  @keyframes par{from{opacity:.25}to{opacity:1}}
  .barra{height:12px;background:#0A0F1A;border-radius:8px;overflow:hidden;
    margin:10px 0 8px;display:none}
  .barra>div{height:100%;width:0%;background:linear-gradient(90deg,#00E0FF,#0080ff);
    transition:width .4s}
  #datos{color:#8fa0b8;font-size:12.5px;display:none;margin-bottom:16px;white-space:pre-line}
  .botones{display:none;gap:12px;justify-content:center;margin-top:6px}
  button{padding:11px 26px;border:0;border-radius:10px;font-size:15px;
    font-weight:600;cursor:pointer;color:#04121f}
  #bSi{background:#00E0FF}#bNo{background:#00CC66}
  #bRe{background:#2a3a5a;color:#cfe2ff}
  button:hover{filter:brightness(1.12)}
  .version{position:fixed;bottom:10px;left:0;right:0;text-align:center;
    color:#44547a;font-size:11px}
</style></head><body>
<div class="caja">
  <img class="logo" src="/__logo__" alt="AstroIO">
  <h1>AstroIO</h1>
  <div class="sub">Lanzador oficial del juego</div>
  <div id="mensaje"><span class="punto"></span>Comprobando versión…</div>
  <div class="barra" id="barra"><div id="relleno"></div></div>
  <div id="datos"></div>
  <div class="botones" id="botones">
    <button id="bRe">Reintentar</button>
    <button id="bSi">Actualizar</button>
    <button id="bNo">Continuar</button>
  </div>
</div>
<div class="version" id="pie"></div>
<script>
var juego = "";
var fase = "";
function $(id){return document.getElementById(id)}
function texto(m){$("mensaje").innerHTML = '<span class="punto"></span>' + m}
function botones(si,no,re){
  $("botones").style.display = "flex";
  $("bSi").style.display = si ? "" : "none";
  $("bNo").style.display = no ? "" : "none";
  $("bRe").style.display = re ? "" : "none";
}
function entrar(){                                // v10: entrada con pre-vuelo
  texto("Preparando entrada…");
  fetch("/__entrar__").then(function(r){return r.json()})
    .then(function(d){
      if (d.url){ location.href = d.url; }
      // si no hay url: el launcher ya relanzó la verificación con
      // auto-recconexión; el ciclo() sigue y muestra el avance.
    })
    .catch(function(){ location.href = juego; }); // último recurso
}
$("bNo").onclick = entrar;                       // Continuar: entra normal
$("bRe").onclick = function(){                   // Reintentar tras un error
  botones(false,false,false); texto("Comprobando versión…");
  fetch("/__reintentar__");
};
$("bSi").onclick = function(){                   // Actualizar
  botones(false,false,false); texto("Preparando descarga…");
  fetch("/__actualizar__");
};
function refresco(e){
  fase = e.fase; juego = e.juego || juego;
  $("pie").textContent = "AstroIO Launcher " + (e.versionNueva ? ("· versión nueva " + e.versionNueva + " disponible") : "");
  if (fase == "comprobando"){ texto("Comprobando versión…"); }
  else if (fase == "al_dia"){
    texto("Todo al día · Entrando al juego…");
    setTimeout(entrar, 500);
  }
  else if (fase == "actualizacion"){
    texto("Hay una versión nueva (" + e.versionNueva + ") disponible.");
    botones(true, true, false);                  // Actualizar | Continuar
  }
  else if (fase == "descargando"){
    $("barra").style.display = "block";
    $("datos").style.display = "block";
    $("relleno").style.width = e.pct + "%";
    texto("Descargando actualización… " + e.pct + "%");
    $("datos").textContent = e.descargadoMB + " de " + e.totalMB +
      " MB · " + (e.velocidad || "…") + "\nFaltan ~" + (e.eta || "…");
    botones(false,false,false);
  }
  else if (fase == "listo"){
    texto("Verificado ✓ · Instalando versión nueva…");
    $("datos").style.display = "none";
  }
  else if (fase == "sin_conexion"){
    // v2.4.12: SOLO Reintentar. v2.4.13: además AUTO-RECONECTA sola
    // (intento N + cuenta atrás visibles): no hay que dar clicks.
    var extra = "";
    if (e.intento > 0) {
      extra = "<br><span style='color:#8fa0b8;font-size:12.5px'>Reconectando automáticamente… intento " +
        e.intento + (e.cuenta > 0 ? (" · reintento en " + e.cuenta + "s") : "") + "</span>";
    }
    texto("Sin conexión con el servidor." + extra +
      "<br><span style='color:#8fa0b8;font-size:12.5px'>Revisa tu Internet e inténtalo de nuevo.</span>");
    botones(false, false, true);
  }
  else if (fase == "error_dl"){
    texto(e.error || "No se pudo actualizar.");
    botones(false, true, true);                  // Continuar | Reintentar
  }
}
function ciclo(){
  fetch("/__estado__").then(function(r){return r.json()})
    .then(refresco).catch(function(){});
}
ciclo();
setInterval(ciclo, 500);
</script></body></html>`
