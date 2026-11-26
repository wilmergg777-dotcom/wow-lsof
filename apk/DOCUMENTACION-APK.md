# AstroIO — DOCUMENTACIÓN TÉCNICA COMPLETA DE LA APK
### Versión documentada: 2.4.4 (versionCode 6) · Rama: Xnovaaaa

> Este documento explica CÓMO está programada la APK por completo y DÓNDE
> vive cada cosa dentro del proyecto y dentro del paquete APK final.
> Está pensado para retomar el trabajo en cualquier momento sin tener que
> volver a analizar el código. Se actualiza con cada versión importante.

---

## 1. Qué es la APK

La APK de AstroIO es un **envoltorio WebView nativo** (Java, Android puro,
**sin androidx y sin ninguna biblioteca externa**) alrededor del juego web
(2Moons/Xnovaa fork). Le añade al juego:

1. **Imágenes del juego embebidas** — no gastan datos al jugar.
2. **Auto-actualización propia** — descarga e instala versiones nuevas.
3. **Notificaciones en segundo plano** — mensaje nuevo y ataques, con la
   app minimizada o cerrada.
4. **Alarma sonora de ataque** — sirena a volumen de alarma, en bucle,
   mientras hay flotas enemigas en vuelo.
5. **Protecciones anti-manipulación** — anti APK Editor/Lucky Patcher,
   detección de depuración y firma verificada.

## 2. Mapa del proyecto (dónde vive cada cosa)

```
apk/
├── android/                       ← proyecto Android (Gradle puro)
│   ├── app/build.gradle           ← versión (versionCode/versionName), firma, minify
│   ├── keystore/astroio-release.p12 ← clave de firma (contraseñas en build.gradle)
│   └── app/src/main/
│       ├── AndroidManifest.xml    ← permisos, MainActivity, EstadoService, proveedor
│       ├── java/com/astroio/game/
│       │   ├── MainActivity.java   ← pantalla principal: WebView + verificación
│       │   │                          de versión + descarga/instalación de updates
│       │   ├── EstadoService.java  ← servicio en SEGUNDO PLANO (v2.4.4):
│       │   │                          notificaciones + alarma de ataque
│       │   ├── Servidor.java       ← URLs ofuscadas (XOR 0x5A), cookies y GET
│       │   │                          compartido (Activity + Service)
│       │   ├── SecurityGuard.java  ← protecciones anti-modificación
│       │   └── UpdateFileProvider.java ← ContentProvider propio (sin androidx)
│       │                              para entregar la APK nueva al instalador
│       ├── res/
│       │   ├── mipmap-*/ic_launcher.png ← ICONO de la app (todas las
│       │   │                              densidades, generado del favicon
│       │   │                              oficial del sitio, logo azul)
│       │   ├── drawable/logo_astroio.png ← LOGO 512px para la pantalla de
│       │   │                              carga/actualización (mismo logo)
│       │   ├── raw/alarma_ataque.wav ← SIRENA de la alarma de ataque
│       │   │                          (4,4 s generada sintéticamente,
│       │   │                          barrido 550→1150 Hz, sin copyright)
│       │   ├── raw/isrgrootx1.pem  ← certificado raíz ISRG (Let's Encrypt)
│       │   ├── layout/activity_main.xml ← WebView + pantalla de estado
│       │   │                          (logo + título + barra de progreso + botones)
│       │   └── values/strings.xml  ← TODOS los textos visibles al jugador
│       └── assets/game/…           ← IMÁGENES DEL JUEGO (styles/… del servidor)
│                                      copiadas al compilar por apk/copiar_assets.sh
│                                      → son las que evitan gastar datos
├── copiar_assets.sh               ← pasa las imágenes del repo a assets/game/
├── server/LEEME-SERVIDOR.txt      ← qué subir por FTP al servidor
└── DOCUMENTACION-APK.md           ← ESTE documento
```

**En la raíz del servidor web (fuera de la APK):**
- `api_estado.php` — endpoint de estado para el servicio en segundo plano
  (mensajes sin leer + ataques). SIN él, la app funciona pero sin
  notificaciones.

## 3. La configuración del servidor: Servidor.java

- El dominio del juego **no aparece en texto plano**: va en hexadecimal
  `XOR 0x5A` en `Servidor.HOST_ENC` (se desofusca en tiempo de ejecución).
  Así ni la descompilación ni las pantallas de error revelan el servidor.
- `Servidor` expone: `host()`, `basePath()` (vacío, el juego está en la
  raíz), `juegoUrl()` (game.php), `versionUrl()` (apk/version.json),
  `estadoUrl()` (api_estado.php), `cookieSesion()` (la PHPSESSID del
  WebView) y `get(url, cookie, timeout)` (GET textual compartido).
- **MainActivity y EstadoService usan la MISMA clase**: si algún día
  cambia el dominio, se cambia SOLO en Servidor.java.
- Para cambiar de dominio: cifrar la cadena nueva con XOR 0x5A y pegar el
  hex en `HOST_ENC`. El User-Agent lleva además `AstroIOMobile/<versión>`.

## 4. Arranque de la app (MainActivity.java)

Flujo en `onCreate`:

1. `setContentView(R.layout.activity_main)` — WebView oculto + pantalla
   de estado visible (logo 120dp + título + barra + botones).
2. `SecurityGuard.performChecks()` — si detecta manipulación (APK Editor,
   debuggable, firma cambiada) muestra error fatal y cierra.
3. `pedirPermisoNotificaciones()` — en Android 13+ (API 33) pide el
   permiso POST_NOTIFICATIONS una vez. Si se deniega, todo lo demás
   funciona igual (solo sin avisos). NO bloquea.
4. `arrancarServicioEstado()` — arranca EstadoService (servicio en primer
   plano). NO bloquea.
5. `runVersionCheck()` — verificación de versión (ver §5).

## 5. Actualización NO bloqueante (v2.4.4, cambio grande)

Antes (≤2.4.3): si había versión nueva, la descargaba a la fuerza y **no
dejaba entrar al juego hasta actualizar**.

Ahora (v2.4.4):

1. `runVersionCheck()` descarga `apk/version.json` y compara **SOLO el
   campo `versionCode` de nivel superior** con `BuildConfig.VERSION_CODE`.
   - El bloque `"launcher"` del JSON se IGNORA: las versiones de la APK y
     de los launchers de PC son **independientes** (un launcher nuevo no
     dispara la actualización de la APK y viceversa).
   - Si no hay `version.json` (primera puesta en marcha) → entra al juego.
2. Si hay versión nueva → `preguntarActualizar()` muestra un **diálogo con
   dos opciones**:
   - **Continuar** → `loadGame()` y a jugar sin actualizar.
   - **Actualizar** → `downloadUpdate()`.
3. `downloadUpdate()` (la descarga ya existía, ahora con más info):
   - Descarga en `filesDir/AstroIO-update.apk.part` con **reanudación por
     HTTP Range** (si se corta, continúa donde iba; el `.part` se conserva).
   - Barra de progreso con **porcentaje + MB descargados + VELOCIDAD por
     momento** (media exponencial suavizada, "12.3 MB/s") + **TIEMPO
     RESTANTE estimado** ("Faltan ~1m 20s", helper `etaTexto()`).
   - Al terminar verifica el **SHA-256** contra el JSON (si falla, borra
     el `.part` y avisa).
   - `promptInstall()` → si Android 8+ y falta el permiso de "instalar
     apps desconocidas", lo pide con el botón "Permitir instalación";
     si está, lanza el instalador del sistema con la APK vía
     `UpdateFileProvider` (content://com.astroio.game.update/…).
   - Tras instalar, `onResume` re-comprueba la versión y entra al juego.
4. Errores de red durante la comprobación → pantalla con "Reintentar" y
   "Entrar de todas formas" (el juego necesita internet de todas formas,
   pero nada queda bloqueado en un bucle).

**Para publicar versión nueva de la APK:** subir `versionCode +1` y
`versionName` en `apk/android/app/build.gradle` y hacer push. El workflow
calcula el SHA-256 y regenera `version.json` solo.

## 6. El juego: WebView con imágenes locales (ahorro de datos)

- `loadGame()` configura el WebView (JS, DOM storage, cookies aceptadas,
  `MIXED_CONTENT_NEVER_ALLOW`, User-Agent marcado) y carga `game.php`.
- `shouldInterceptRequest` → `interceptAsset(url)`:
  - Si la URL pertenece al dominio del juego y su ruta contiene
    `/styles/…`, busca la MISMA ruta dentro de `assets/game/styles/…`.
  - Si existe, sirve el archivo **desde la APK** (0 datos móviles) con su
    MIME correcto; si no existe, deja que se descargue de internet
    (así las imágenes nuevas entran sin actualizar la APK).
- Las imágenes se meten en la APK con `apk/copiar_assets.sh` al compilar
  (lo llama el workflow). Por eso la APK pesa ~131 MB.
- Los enlaces externos (fuera del dominio) se abren en el navegador del
  sistema, no dentro de la app.

## 7. Servicio en segundo plano: EstadoService.java (v2.4.4, NUEVO)

Es un **servicio en primer plano** (foreground service, tipo `dataSync`)
con notificación fija "AstroIO activo · Vigilando mensajes y ataques"
(canal silencioso, obligatorio por Android). Arranca al abrir la app y es
`START_STICKY` (si el sistema lo mata, se reinicia). **Sigue trabajando con
la APK minimizada o cerrada.**

Cada **60 segundos** (`INTERVALO_MS`) hace un ciclo:

1. Toma la cookie de sesión del WebView (`CookieManager` global) →
   consulta `api_estado.php` **como el mismo jugador**. Si aún no hay
   sesión, espera al siguiente ciclo sin hacer nada.
2. La consulta va en un hilo propio (la red no puede ir en el hilo
   principal de un servicio).
3. `procesar(mensajes, ataque)` decide:
   - **Mensaje nuevo**: si el contador de mensajes sin leer SUBE respecto
     al ciclo anterior → notificación flotante (heads-up) "💬 Mensaje
     nuevo · Tienes N mensajes sin leer" (canal IMPORTANCE_HIGH; en Android
     <8 lo logra setPriority HIGH). Al tocarla se abre la app.
   - **Ataque**: transición sin-ataque→ataque →
     notificación "🚨 ¡Estás siendo atacado!" (PRIORITY_MAX, flotante) +
     **SIRENA** (ver §8). Transición ataque→sin-ataque → se para la sirena
     y se retira la notificación.
   - PVE y espionajes NO suenan (igual que en la web; solo el juego los
     muestra visualmente). Es la misma semántica de check_attacks.php v3.9.
4. Si el jugador denegó las notificaciones (Android 13+), el servicio
   sigue vivo pero no notifica (`areNotificationsEnabled()`).

**Permisos nuevos en el manifest**: POST_NOTIFICATIONS,
FOREGROUND_SERVICE, FOREGROUND_SERVICE_DATA_SYNC; el servicio se declara
con `android:foregroundServiceType="dataSync"`.

## 8. La sirena de ataque

- El audio vive en `res/raw/alarma_ataque.wav` — 4,4 s, 22050 Hz mono
  16-bit, **generado sintéticamente** (barrido senoidal 550→1150→550 Hz,
  dos ciclos con fundidos anti-clic). No pesa (~189 KB) y no tiene
  copyright.
- Se reproduce con `MediaPlayer` en **bucle** (`setLooping(true)`) usando
  `AudioAttributes.USAGE_ALARM`: sale por el **volumen de alarma**, no por
  el de multimedia.
- El canal de notificaciones "Alarmas de ataque" tiene `setBypassDnd(true)`
  y sin sonido propio (el sonido lo da la sirena).
- Para cambiar el sonido: reemplazar ese WAV y subir `versionCode`.

## 9. api_estado.php (servidor, v1.0, NUEVO)

Endpoint en la **raíz del servidor** (junto a game.php). Requiere la
sesión del juego (la APK manda la PHPSESSID del WebView). Devuelve JSON:

```json
{"mensajes": 3, "hasAttack": true, "total": 1, "hasPve": false, "hasSpy": false, "ts": 1730000000}
```

- `mensajes`: `SELECT COUNT(*) FROM messages WHERE message_owner = yo
  AND message_unread = 1 AND message_deleted IS NULL` (mismo criterio que
  ShowMessagesPage).
- `hasAttack`: MISMA consulta que check_attacks.php v3.9 (misión 1/2/9,
  `fleet_mess = 0` ida, `fleet_owner <> yo`, `fleet_end_time > now`).
- `hasPve`/`hasSpy`: informativos (20/21/22 y misión 6) — la APK NO suena
  con ellos.
- Sin sesión → `{"reason":"no_session", …}` inofensivo.
- Ojo: hay que subirlo por FTP a la raíz (está en el LEEME-SERVIDOR.txt y
  en el cuerpo del Release para no olvidarlo).

## 10. Icono y pantalla de carga (v2.4.4, NUEVO)

- **Icono de la app**: `res/mipmap-*/ic_launcher.png` (48/72/96/144/192 px,
  mdpi→xxxhdpi), generado desde el **favicon.ico oficial del sitio** (el
  logo azul, el mismo de la web y de los launchers de PC).
- **Pantalla de carga/actualización**: `res/drawable/logo_astroio.png`
  (512 px, mismo logo) sobre fondo oscuro, con el título, la barra de
  progreso y los botones debajo. Es el primer impacto visual de la app.

## 11. Versiones: APK y launchers son INDEPENDIENTES

| Producto | Dónde vive su versión | Qué compara para actualizarse |
|---|---|---|
| APK Android | `apk/android/app/build.gradle` (top-level de version.json) | su propio versionCode |
| Launcher Windows/Linux | `launcher/main.go` (bloque "launcher" de version.json) | su propio launcherVersionCode |

El workflow genera version.json con los dos bloques y los SHA-256 de todo.
Cada producto solo mira SU bloque → nunca se avisan actualizaciones ajenas.

## 12. Compilación y publicación (resumen operativo)

1. Cambios en `apk/**` o `launcher/**` + push a `Xnovaaaa`.
2. GitHub Actions (`build-apk.yml`): copia assets → `gradle assembleRelease`
   (firmada con `apk/android/keystore/astroio-release.p12`) → compila
   launchers → genera `version.json` → publica **Release `apk-v<code>`**.
3. Descargar del Release: `AstroIO.apk`, `version.json`, `api_estado.php`
   (del repo) y los launchers.
4. FTP: `AstroIO.apk` + `version.json` → `/apk/`; `api_estado.php` → raíz;
   launchers → `/launcher/`.
5. Los móviles se actualizan solos (diálogo Continuar/Actualizar) y los
   launchers de PC también (selfUpdate).

## 13. Historial de versiones de la APK

| Versión | versionCode | Cambios principales |
|---|---|---|
| 2.4.1 | 3 | Juego en la raíz del dominio |
| 2.4.2 | 4 | Protecciones, User-Agent, certificado |
| 2.4.3 | 5 | Descarga reanudable (Range), timeouts grandes, % + MB |
| 2.4.4 | 6 | **Icono y logo oficiales del sitio** · **actualización NO bloqueante (Continuar/Actualizar) con velocidad y tiempo restante** · **servicio en segundo plano** con notificación flotante de mensaje nuevo y **alarma de ataque con sirena** · `api_estado.php` · versiones APK/launcher independientes |

## 14. Limitaciones conocidas (honestas)

- En modo Doze profundo (teléfono horas sin usar, pantalla apagada) Android
  puede retrasar los ciclos de 60 s del servicio; al volver a abrir la app
  el estado se refresca de inmediato. Para garantía total habría que añadir
  AlarmManager exacto + batería exenta, no incluido a propósito (cuesta
  batería y permisos raros).
- La notificación de mensaje usa el número total de sin leer: si el jugador
  marca como leídos desde la web y luego llegan otros N, el aviso salta
  cuando el contador sube.
- La sirena suena en bucle MIENTRAS haya ataque en vuelo (como la alarma de
  la web). Si dura horas, se puede pausar silenciando el volumen de alarma
  o tocando la notificación (que abre el juego).
