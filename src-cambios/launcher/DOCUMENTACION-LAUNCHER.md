# AstroIO — DOCUMENTACIÓN TÉCNICA DEL LAUNCHER DE PC
### Versión documentada: 2.4.13 (build 10) · Rama: Xnovaaaa · Complementa a `apk/DOCUMENTACION-APK.md`

> Documento hermano de la documentación de la APK: explica cómo está
> programado el LAUNCHER de Windows/Linux por completo y dónde vive cada
> cosa. Se actualiza con cada versión importante.

---

## 1. Qué es el launcher

El launcher de PC es una **aplicación de ventana propia escrita en Go**
(sin frameworks de GUI): en Windows abre su propia ventana con **WebView2**
(el motor de Edge que trae Windows 10/11) y en Linux abre Chromium/Chrome/
Edge/Brave en **modo app con perfil propio**. Es decir: un programa real con
el juego dentro, equivalente al WebView de la APK. **NO instala nada**: es
portable (doble clic y funciona); el `AstroIO-Setup-Windows.exe` es opcional.

Como la APK, lleva **las imágenes del juego dentro** (proxy local
127.0.0.1 que las sirve desde el propio exe + caché de disco para el resto
de estáticos): jugar no gasta datos de imágenes.

## 2. Qué cambió en la v8 (2.4.11) — el rework "igual que la APK"

| Antes (v7 / 2.4.10) | Ahora (v8 / 2.4.11) |
|---|---|
| Al abrir, comprobaba la versión y se auto-descargaba **antes** de entrar (en Windows sin consola: nada visible durante minutos) | La ventana abre AL INSTANTE con la **pantalla de carga con el logo** y "Comprobando versión…" |
| Si había versión nueva: descarga forzada, sin preguntar | **Aviso con dos botones: Continuar / Actualizar** — nunca bloquea |
| Descarga sin progreso visible | **Barra con %, MB, velocidad por momento y tiempo restante** |
| Al terminar se reemplazaba y relanzaba en silencio | Igual (autoinstalación), pero avisando ("Instalando…") |

### Qué cambió en la v9 (2.4.12) — conexión robusta

| Antes (v8 / 2.4.11) | Ahora (v9 / 2.4.12) |
|---|---|
| UN solo intento de version.json con timeout de 8 s: un mal intento aislado (DNS lento, servidor ocupado un instante) sacaba "Sin conexión" **aunque el servidor estuviera online** — había que dar a Reintentar 3-5 veces | **3 intentos** de version.json (12 s cada uno, esperando 1 s y 2 s entre intentos) |
| Si version.json fallaba → "Sin conexión" directamente | Si version.json sigue sin responder se comprueba si **el JUEGO responde** (GET a game.php): si responde, **se ENTRA igual** — solo se pierde el aviso de actualización de esa sesión |
| La pantalla "Sin conexión" ofrecía Reintentar + Continuar | "Sin conexión" ofrece **SOLO Reintentar** (entrar a un servidor caído no lleva a ningún sitio); el botón **Continuar queda reservado a cuando hay una versión nueva** — igual que en la APK |

## 3. Mapa de archivos

```
launcher/
├── main.go              ← versión (launcherVersionCode/Name), arranque,
│                          ofuscación XOR 0x5A del dominio, httpGet,
│                          fileSha256, cleanupOld, findBrowser, main()
├── ui_launcher.go       ← NUEVO en v8: TODO el sistema de UI y actualización:
│                          estado compartido, pantalla de carga (HTML embebido),
│                          rutas __launcher__/__logo__/__estado__/__reintentar__/
│                          __actualizar__, comprobación en goroutine, descarga
│                          con progreso (velocidad EWMA + ETA) y autoinstalación
├── proxy.go             ← proxy local 127.0.0.1: imágenes embebidas
│                          (assets/game) + caché de disco + reescritura de
│                          cookies/HTML; registra las rutas de la UI
├── window_windows.go    ← ventana propia WebView2 (IconId 1: icono rsrc)
├── window_linux.go      ← navegador en modo app con perfil propio
├── hidewindow_windows.go / hidewindow_other.go ← ocultar consola de procesos hijos
├── assets/
│   ├── astroio.ico      ← ICONO del exe/ventana/accesos (el favicon oficial)
│   ├── logo.png         ← LOGO 192px para la pantalla de carga (go:embed)
│   └── game/…           ← imágenes del juego (copiadas por build.sh)
├── setup/               ← fuentes del Setup opcional (instala WebView2 si falta)
├── build.sh             ← compila los 3 exes + incrusta icono (.syso con rsrc)
├── go.mod               ← go 1.24.0 + go-webview2 + x/sys (toolchain automático)
├── LEEME-LAUNCHER.txt   ← instrucciones para el usuario/servidor
└── DOCUMENTACION-LAUNCHER.md ← ESTE documento
```

## 4. Flujo de arranque (main.go)

1. `--version` → imprime versión y sale (verificación/soporte).
2. `cleanupOld()` borra restos de actualizaciones anteriores (`.old`, `.download`).
3. `--borrar-datos` → limpia sesión, caché y perfil (como la APK).
4. Arranca el **proxy local** (puerto libre en 127.0.0.1). Desde la v8
   también sirve la UI del launcher.
5. `iniciarVerificacion()` (goroutine, NO bloqueante).
6. `openWindow(uiURL())` → la ventana abre la **pantalla de carga**
   (`/__launcher__`) en vez de abrir el juego a ciegas; la propia página
   pasa sola al juego (`/game.php` por el proxy) cuando la comprobación
   termina o el jugador decide.

## 5. La pantalla de carga y el aviso de actualización (ui_launcher.go)

La página `__launcher__` es HTML/CSS embebido en el exe con los colores de
la APK (`#0A0F1A` fondo, `#131A2A` tarjetas, `#00E0FF` cian, `#00CC66` verde)
y el logo (`/__logo__`, PNG 192px con go:embed, el mismo favicon oficial).
Un JS simple consulta `__estado__` cada 500 ms y dibuja el estado:

- `comprobando` → logo + "Comprobando versión…"
- `al_dia` → "Todo al día · Entrando…" y redirige al juego solo
- `sin_conexion` → "Sin conexión con el servidor. Revisa tu Internet e
  inténtalo de nuevo." + botón **SOLO Reintentar** (v9: el Continuar
  desaparece de este estado)
- `actualizacion` → "Hay una versión nueva (X.Y.Z)" + botones
  **Actualizar / Continuar** (Continuar entra al juego sin actualizar)
- `descargando` → barra de progreso + "N de M MB · V MB/s · Faltan ~T"
- `listo` → "Verificado ✓ · Instalando…" (el launcher se reemplaza y
  abre la versión nueva; la ventana vieja se cierra sola)
- `error_dl` → mensaje del error + Reintentar / Continuar (aquí sí hay
  Continuar: en este estado SÍ existe una versión nueva)

## 6. La actualización paso a paso

1. `iniciarVerificacion()` consulta `apk/version.json` (v9: **3 intentos**
   de 12 s esperando 1 s y 2 s entre ellos) y compara **SOLO el
   bloque `launcher`** (`launcherVersionCode`): las versiones de la APK y
   del launcher son INDEPENDIENTES — una APK nueva no avisa al launcher y
   viceversa.
2. Si hay versión nueva, se guarda `svNueva` y se avisa (no se descarga
   nada sin permiso).
3. "Actualizar" → `descargarActualizacion()`: descarga al exe `.download`
   con **velocidad suavizada (EWMA 40/60)** y **ETA** (`etaTexto`), igual
   que la APK; SIN timeout total (el exe pesa ~140 MB por las imágenes).
4. Verifica **SHA-256** contra el JSON (si falla, borra y avisa).
5. Reemplazo seguro: mueve el exe actual a `.old.exe`, pone el nuevo,
   lo lanza (`hideWindow()` en Windows) y sale. El nuevo borra el `.old`
   al arrancar (`cleanupOld`). Si algo falla, restaura el original.
6. Si version.json no responde tras los 3 intentos, se comprueba si el
   JUEGO responde (`juegoResponde()`, GET a game.php): si responde el
   servidor está ONLINE y **se entra igual** — solo se pierde el aviso
   de actualización de esa sesión. Si tampoco responde el juego, es un
   apagón real: "Sin conexión" y SOLO Reintentar (las imágenes embebidas
   se ven; el juego necesita conexión).

## 7. El proxy local con imágenes embebidas (proxy.go)

Igual que la APK: rutas `/styles/…` se buscan primero en `assets/game`
(go:embed), luego en la caché de disco, y si no están van al servidor por
HTTPS y se cachean. Las cookies del servidor se reescriben para
127.0.0.1 (la sesión funciona igual) y el HTML se reescribe para que los
links absolutos apunten al proxy. Las rutas `__*` de la UI se registran
antes del reenvío al juego.

## 8. Compilación (build.sh) y publicación

1. `go mod tidy` → `assets/game` (copia desde `styles/theme/gow`, mismas
   carpetas que la APK) → descarga el bootstrapper de WebView2 para el Setup.
2. Linux: `GOOS=linux go build` estático.
3. Windows: icono con `rsrc` (`.syso` desde `assets/astroio.ico`) + build
   con `-H=windowsgui` (SIN consola: es una app de ventana, "PE32+ (GUI)").
4. Setup: go:embed del launcher + bootstrapper (instala WebView2 si falta).
5. El workflow calcula SHA-256 de los 3 archivos y actualiza el bloque
   `launcher` de `version.json` → **Release `apk-v<versionCode de la APK>`**.

Para publicar versión nueva del launcher: subir `launcherVersionCode` y
`launcherVersionName` en `main.go` + push. No toca la versión de la APK.

## 9. Historial

| Build | Versión | Cambios |
|---|---|---|
| 4 | 2.4.7 | Setup en Go (adiós al error SxS del NSIS) |
| 5 | 2.4.8 | Icono incrustado en los exes de Windows |
| 6 | 2.4.9 | Ventana propia WebView2 + imágenes embebidas + caché + Borrar datos |
| 7 | 2.4.10 | Icono corregido al favicon oficial del sitio |
| 8 | 2.4.11 | **Pantalla de carga con el logo + actualización NO bloqueante (Continuar/Actualizar) con %, velocidad y tiempo restante + autoinstalación + `--version`** |
| 9 | 2.4.12 | **Conexión robusta: 3 intentos de version.json + comprobación de si el JUEGO responde antes de marcar "Sin conexión" + botón Continuar eliminado de ese estado (queda SOLO para cuando hay versión nueva, igual que la APK)** |

## 10. Cómo se verificó (v8 y v9)

- `go vet` limpio para linux y windows.
- `go build` OK: Linux estático y Windows GUI (`file` confirma
  "PE32+ executable … (GUI)", sin consola).
- `--version` → `AstroIO Launcher 2.4.12 (build 9)`.
- Prueba funcional real del binario Linux (v9): el proxy sube,
  `__estado__` devuelve `{"fase":"al_dia", …}` con el mecanismo nuevo
  de 3 intentos + probe contra el servidor real, `__launcher__` sirve
  el HTML con el estado `sin_conexion` mostrando SOLO Reintentar.
- La descarga con progreso reutiliza el mismo mecanismo de descarga +
  SHA-256 + reemplazo que ya actualizó en producción de 2.4.9 → 2.4.10,
  con los cálculos de velocidad/ETA añadidos (idénticos a los de la APK).

## 11. Limitaciones conocidas

- La notificación/alarma estilo APK no existe en el launcher: el juego en
  la ventana ya trae su propia alarma web (sirena del check_attacks) sonando
  mientras juegas, que es el equivalente en PC. Avisos con el juego cerrado
  requerirían un icono de bandeja de sistema (posible trabajo futuro).
- En Linux sin Chromium/derivados cae a Firefox/xdg-open (pestaña normal
  con el proxy local; el juego funciona igual).
- Si el exe vive en una carpeta sin permisos de escritura (p. ej.
  Program Files sin admin), la autoinstalación avisa y no rompe nada
  (restaura el original).


---

## 11. Qué cambió en la v10 (2.4.13) — AUTO-RECONECTA

| Antes (v9 / 2.4.12) | Ahora (v10 / 2.4.13) |
|---|---|
| Si version.json fallaba 3 veces y el juego no respondía, la pantalla "Sin conexión" quedaba esperando clicks de Reintentar. | **AUTO-RECONECTA**: un bucle en segundo plano reintenta cada 6 s (hasta 60 intentos ≈ 8 min) con cuenta atrás e "intento N" visibles; en cuanto el servidor contesta, pasa a `al_dia` y **la página entra sola**. |
| Al entrar se navegaba directo al juego por el proxy: si el upstream fallaba justo ahí, WebView2 mostraba SU página de error. | Ruta nueva **`/__entrar__`**: antes de navegar se comprueba que el juego responde POR EL PROXY (6 s) y, si no, DIRECTO al servidor; si tampoco, se relanza la verificación con auto-recconexión y la página se queda en el loader. Nunca una página de error de WebView a medio camino. |

Detalles técnicos:
- `estadoUI` lleva 2 campos nuevos: `intento` (intento N de la
  auto-recconexión, 0 = sin auto) y `cuenta` (cuenta atrás para el próximo).
- El bucle vive en `conectarEnBucle(gen)`: se cancela por **generación**
  (`verGen`, contador atómico): dar a Reintentar o pasar por `/__entrar__`
  sube la generación y el bucle viejo aborta solo (nunca dos bucles a la vez).
- Sondeo del bucle con timeout corto: `juegoRespondeRapido()` = 6 s
  (`juegoRespondeEn(url, seg)` es la versión genérica; `juegoResponde()` = 10 s).
- El botón Continuar SIGUE reservado a cuando HAY una versión nueva
  (aviso Continuar/Actualizar y error de descarga), igual que v2.4.12.
- Verificado: `go vet` limpio (Linux y Windows), `--version` →
  "AstroIO Launcher 2.4.13 (build 10)", y prueba funcional REAL contra el
  servidor: `__estado__` → `{"fase":"al_dia","intento":0,"cuenta":0}`,
  `__entrar__` → URL del juego por el proxy, página con el aviso de
  auto-recconexión y logo PNG servido.
