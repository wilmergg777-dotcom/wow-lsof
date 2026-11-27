# XNOVA 3D — Arquitectura (rama `xnova3d`)

## La idea en una frase

El **Xnova tradicional sigue siendo el juego verdadero**. La rama `xnova3d`
es **el mismo proyecto, en el mismo servidor y con las mismas tablas de la
base de datos**; lo único que cambia es la forma de jugar: vista clásica
(tablas) o vista 3D, y **el usuario escoge**. El 3D no reemplaza el proyecto:
es una capa aparte (visor + API) que consume el mismo juego, y todo lo que
se hace en un cliente se ve en el otro porque comparten
`uni1_planets`, `uni1_fleets`, `uni1_users`, `uni1_statpoints`… y la misma
sesión.

## Selector de vista (clásico ↔ 3D)

Misma instalación, dos entornos:

| URL | Entorno |
|---|---|
| `game.php?page=galaxy` (por defecto en esta rama) | Visor 3D |
| `game.php?page=galaxy&vista=clasico` | Tabla clásica original |
| `game.php?page=galaxy&vista=3d` | Visor 3D |

- La elección se **recuerda en la sesión** del usuario (`ag3d_vista`).
- La vista clásica tiene el botón **🌐 GALAXIA 3D** en su barra de
  navegación (conserva galaxia:sistema al cambiar).
- El visor 3D tiene el botón **🖥 CLÁSICO** en su barra superior
  (también conserva galaxia:sistema).
- Ninguna de las dos vistas duplica lógica: ambas usan
  `Galaxy3dService::cargarGalaxia()` para los datos del sistema.

## API v1 — `api/index.php`

Capa aparte para que las APKs (clásica y 3D) consuman el juego sin
reemplazarlo. Usa el **bootstrap real del juego** (`includes/common.php`),
por lo que corre con las **mismas reglas**: sesión, universo, desactivación
del servidor, baneos y costos de deuterio.

### Autenticación (la misma sesión del juego)

| Cliente | Cómo se autentica |
|---|---|
| Web (mismo dominio) | Cookie de sesión `2Moons` (la de siempre) |
| APK nativa | `Authorization: Bearer <token>` o `?token=<token>` |

- El token lo devuelve `r=login` y **es el session_id real del juego**
  (tabla `uni1_session`): la APK y la web comparten la misma sesión, así
  que lo que haga la APK aparece en la web al instante.
- Peticiones sin sesión válida → `401 {"ok":false,"err":"no_auth"}`.
- `OPTIONS` (preflight CORS) respondido; `Access-Control-Allow-Credentials`
  activado para clientes web externos.

### Endpoints

| Endpoint | Descripción | Reglas del juego |
|---|---|---|
| `GET ?r=ping` | Estado de la API y de la sesión | — |
| `POST ?r=login` (`username`, `password`) | Login → devuelve `token` (session_id real) | Mismo hash + fallback md5 que `ShowLoginPage`; bloquea si el servidor está cerrado |
| `POST ?r=logout` | Cierra la sesión | Igual que el juego |
| `GET ?r=galaxy&galaxy=G&system=S` | Paquete completo del sistema (filas, asteroides, flotas entrantes, climas, TOP 10) | **Cobra deuterio** como la vista clásica y lo descuenta en la BD |
| `GET ?r=top` | TOP 10 del universo + tu puntuación/rank | Misma tabla `%%STATPOINTS%%` que las estadísticas |
| `GET ?r=me` | Perfil: usuario, planeta, flotas, naves del planeta actual | — |
| `GET ?r=missions&galaxy&system&planet` | Misiones permitidas en una posición (para pintar botones) | Mismos flags que la galaxia clásica |
| `GET ?r=action&mission=6&planetID=123` | Pasarela **real** al `fleetAjax` del juego | Espionaje 6, escombros 8, asteroide 32 (`galaxy`,`system`,`planet`); mismo handler, mismo JSON |

Todo responde JSON (`{"ok":true,...}`) y los errores van con código HTTP
(401 sin sesión, 402 sin deuterio, 403 servidor cerrado, 400 endpoint
desconocido, 500 excepción capturada).

## Archivos de la rama `xnova3d`

```
api/index.php                              (NUEVO) API v1 (ping/login/logout/
                                           galaxy/top/me/missions/action)
includes/classes/Galaxy3dService.class.php (NUEVO) servicio compartido:
                                           UNA sola fuente de datos para la
                                           página 3D, el modo fetch y la API
includes/pages/game/ShowGalaxyPage.class.php (MODIFICADO)
                                           + elegirVista() (3d|clasico, en sesión)
                                           + delega en Galaxy3dService
                                           + fetch() API AJAX del visor
styles/templates/game/page.galaxy.default.tpl (MODIFICADO)
                                           visor 3D + botón 🖥 CLÁSICO
styles/templates/game/page.galaxy.clasico.tpl (NUEVO)
                                           la tabla clásica ORIGINAL restaurada
                                           + botón 🌐 GALAXIA 3D
scripts/game/galaxy3d.js                   (NUEVO) motor 3D + HUD + 2 tablas
                                           + acciones reales + API fetch
scripts/game/three.min.js                  (NUEVO, vendor) Three.js r128
scripts/game/OrbitControls.js              (NUEVO, vendor) OrbitControls r128
scripts/game/galaxy.js                     (INTACTO) doit()/doitAst()/toast
docs/XNOVA3D_ARQUITECTURA.md               (NUEVO) este documento
```

## Reglas visuales aprobadas en la maqueta (v3)

1. **Dos tablas por defecto**: `TABLA DE GALAXIA · POSICIONES 1-16` y
   `PUNTUACIÓN · TOP DEL UNIVERSO`. En móvil, pestañas GALAXIA/PUNTUACIÓN.
2. Alternador **1-16 / Pts** en la tabla de galaxia.
3. Cada fila del TOP es clicable: la cámara viaja a las coordenadas del
   jugador y lo selecciona. La fila TÚ lleva a tu planeta.
4. **♻ Reciclar** solo con escombros (misión 8) y **♻️ Reciclar asteroide**
   solo con asteroide (misión 32).
5. **🚀 Colonizar** solo en posiciones libres sin asteroide (misión 7).
6. **🌙 Destruir luna** solo si hay luna (misión 9).
7. Estados por color + iconos: luna, escombros, asteroide, depósito, clima
   y alertas de flota entrante (⚔️/👁️/📦).

## Plan de las dos APKs (mismo servidor, misma BD)

| | APK CLÁSICA | APK 3D |
|---|---|---|
| UI | WebView a `game.php` (tablas) | Visor 3D (canvas + HUD) |
| Datos | Las propias páginas del juego + `api/?r=missions` para pintar botones | `api/?r=galaxy` + `api/?r=top` + `api/?r=me` |
| Acciones | `game.php?page=fleetAjax…` y `fleetTable` | `api/?r=action` y `api/?r=galaxy` |
| Login | `api/?r=login` → token | idem |
| Sesión | El mismo token de la APK es la misma sesión de la web | idem |

Ambas APKs pueden usar el MISMO token simultáneamente: son dos ventanas a
la misma cuenta.

## Plan de correcciones (poco a poco)

- **Fase A (en la rama)**: galaxia 3D funcional + selector de vista + API v1.
- **Fase B — sincronía viva**: polling (~5 s) de `r=galaxy` o SSE/WebSocket
  para ver moverse las flotas entrantes sin recargar; cuenta atrás de llegada.
- **Fase C — flotas en 3D**: dibujar las flotas en movimiento dentro del
  sistema (misma tabla `uni1_fleets`).
- **Fase D — resto del juego en 3D**: imperio, construcción, investigación,
  flotas; cada página clásica obtiene su modo `fetch` JSON / endpoint API.
- **Fase E — endurecimiento de la API**: rate-limit del login, verificación
  IP del token como `Session`, y `refresh tokens`.

## Notas técnicas

- Three.js r128 + OrbitControls se sirven locales (`scripts/game/`), sin CDN.
- Los planetas usan la imagen real del juego como textura
  (`{dpath}planeten/small/s_*.jpg`); si la imagen falla, textura procedural.
- El visor respeta `max_galaxy`, `max_system` y `max_planets` de la config.
- `MaxFleetSetting` y los ids `#slots`/`#elementID210/209/219`/`#missiles`
  se conservan para que `galaxy.js` siga actualizando contadores en ambas
  vistas.
- La tabla de estado de flota (`#fleetstatusrow`) sigue existiendo (oculta)
  en la vista 3D para compatibilidad con `astrogxFleetAjax`.
- La API descuenta el deuterio con SQL explícito porque no usa `ecoObj`
  (el descuento de la página 3D sigue persistiendo por `save()` del juego).
- El pre-chequeo de sesión de la API lee `uni1_session` directamente
  (la validación completa — IP e inactividad — la hace `Session::load()`).
