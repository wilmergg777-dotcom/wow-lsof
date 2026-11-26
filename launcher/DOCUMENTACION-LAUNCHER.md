# AstroIO — DOCUMENTACIÓN TÉCNICA DEL LAUNCHER DE PC
### Versión documentada: 2.4.11 (build 8) · Rama: Xnovaaaa · Complementa a `apk/DOCUMENTACION-APK.md`

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
- `sin_conexion` → botones **Reintentar / Continuar** (entrar igual)
- `actualizacion` → "Hay una versión nueva (X.Y.Z)" + botones
  **Actualizar / Continuar** (Continuar entra al juego sin actualizar)
- `descargando` → barra de progreso + "N de M MB · V MB/s · Faltan ~T"
- `listo` → "Verificado ✓ · Instalando…" (el launcher se reemplaza y
  abre la versión nueva; la ventana vieja se cierra sola)
- `error_dl` → mensaje del error + Reintentar / Continuar

## 6. La actualización paso a paso

1. `iniciarVerificacion()` consulta `apk/version.json` y compara **SOLO el
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
6. Sin conexión en el paso 1, no hay aviso: la ventana abre igual
   (las imágenes embebidas se ven; el juego necesita conexión).

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

## 10. Cómo se verificó (v8)

- `go vet` limpio para linux y windows.
- `go build` OK: Linux estático y Windows GUI (`file` confirma
  "PE32+ executable … (GUI)", sin consola).
- `--version` → `AstroIO Launcher 2.4.11 (build 8)`.
- Prueba funcional real del binario Linux: el proxy sube, `__estado__`
  devuelve `{"fase":"al_dia", …}` tras comparar con el servidor real
  (launcher local 8 > servidor 7 → no avisa ✓), `__launcher__` sirve el
  HTML y `__logo__` el PNG 192px válido.
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
