# XNOVA 3D — Arquitectura (rama `xnova3d`)

## La idea en una frase

El **Xnova tradicional sigue siendo el juego verdadero** (rama `main`/`testeo`).
La rama `xnova3d` es **el mismo juego con un cliente 3D para la galaxia**:
no es un juego aparte, es la misma instalación, la **misma base de datos**
y el **mismo servidor PHP**. El jugador elige cómo jugar: por el cliente
clásico (tablas) o por el cliente 3D, y ambos ven lo mismo en tiempo real
porque leen las mismas tablas (`uni1_planets`, `uni1_fleets`, `uni1_users`,
`uni1_statpoints`…).

## Cómo se conecta el 3D al juego (API)

Todo pasa por el `ShowGalaxyPage` del propio juego — sin duplicar lógica:

| Canal | Qué hace | Cobro / reglas |
|---|---|---|
| `game.php?page=galaxy` | Renderiza el visor 3D con los datos del sistema inyectados (`window.ASTRO_G3D`) | Cobra deuterio como siempre |
| `game.php?page=galaxy&mode=fetch&galaxy=G&system=S` | **API JSON**: devuelve el sistema completo (filas, asteroides, flotas entrantes, climas, TOP 10 de puntuación) para navegar sin recargar | Cobra deuterio igual que la vista clásica |
| `fleetAjax` (`doit()` / `doitAst()` de `scripts/game/galaxy.js`) | Acciones instantáneas: 6 espionaje, 8 reciclar escombros, 32 reciclar asteroide | El flujo real del juego |
| `?page=fleetTable&...&target_mission=N` | Envío de flota clásico para: 1 atacar, 3 transportar, 4 desplegar, 5 retener, **7 colonizar**, 9 destruir luna, 15 expedir, 32 asteroide | Flujo real del juego |
| `Dialog.Playercard / PM / Buddy`, `OpenPopup` (phalanx) | Diálogos estándar del juego | — |

Como los dos clientes comparten la base de datos, **lo que se hace en uno
se ve en el otro**: una flota lanzada desde la tabla clásica aparece en el
3D (alertas de ataque/espionaje/transporte), un escombro reciclado en 3D
descuenta los recicladores en el clásico, una colonización hecha en el
clásico ocupa la posición en el 3D, y la puntuación del TOP es la misma
tabla `%%STATPOINTS%%` que alimenta las estadísticas.

## Archivos de la rama `xnova3d`

```
scripts/game/three.min.js                  (NUEVO, vendor) Three.js r128
scripts/game/OrbitControls.js              (NUEVO, vendor) OrbitControls r128
scripts/game/galaxy3d.js                   (NUEVO) motor 3D + HUD + 2 tablas
                                           + acciones reales + API fetch
scripts/game/galaxy.js                     (INTACTO) doit()/doitAst()/toast
includes/pages/game/ShowGalaxyPage.class.php (MODIFICADO)
                                           + cargarGalaxia() compartido
                                           + buildAstro3d() filas JSON + TOP 10
                                           + fetch() — API JSON del visor
styles/templates/game/page.galaxy.default.tpl (MODIFICADO)
                                           visor 3D a pantalla completa,
                                           sin la tabla antigua, conserva el
                                           formulario de misiles y los ids de
                                           contadores (#slots, #elementID210…)
docs/XNOVA3D_ARQUITECTURA.md               (NUEVO) este documento
```

## Reglas visuales aprobadas en la maqueta (v3)

1. **Dos tablas por defecto**: `TABLA DE GALAXIA · POSICIONES 1-16` (el
   sistema donde está tu planeta) y `PUNTUACIÓN · TOP DEL UNIVERSO`
   (ordenada por los puntos del juego). En escritorio se ven las dos; en
   móvil cambian con pestañas GALAXIA / PUNTUACIÓN.
2. La tabla de galaxia tiene alternador **1-16 / Pts** para seguir por
   puntuación.
3. Cada fila del TOP es clicable: la cámara viaja a las coordenadas del
   jugador (su planeta principal) y lo selecciona. La fila TÚ lleva a tu
   planeta.
4. **♻ Reciclar** solo aparece si la posición tiene escombros (misión 8) y
   **♻️ Reciclar asteroide** solo si hay asteroide (misión 32).
5. **🚀 Colonizar** solo en posiciones libres sin asteroide (misión 7,
   flujo clásico `fleetTable`).
6. **🌙 Destruir luna** solo si hay luna (misión 9).
7. Estados por color (propio azul, novato verde, fuerte rojo, inactivo
   gris, vacaciones naranja) + iconos: luna, escombros, asteroide,
   depósito de alianza, clima y alertas de flota entrante (⚔️/👁️/📦).

## Plan de correcciones (poco a poco)

- **Fase A (ya en la rama)**: galaxia 3D funcional con datos reales,
  navegación por API, acciones reales de flota, 2 tablas.
- **Fase B — sincronía viva**: `fetch` con `mode=fetch&galaxy=G&system=S`
  en bucle (polling ~5 s) o SSE/WebSocket del propio servidor para ver
  moverse las flotas entrantes sin recargar; contador de tiempo de llegada.
- **Fase C — flotas en 3D**: dibujar las flotas en movimiento dentro del
  sistema (misma tabla `uni1_fleets`), animación de ataque/expedición.
- **Fase D — el resto del juego en 3D**: imperio, construcción, investigación
  y flotas con paneles HUD 3D, siempre contra las mismas páginas PHP
  (cada página clásica obtiene su modo `fetch` JSON).
- **Fase E — APK/móvil**: la misma API sirve para el cliente móvil (rama `apk`).

## Notas técnicas

- Three.js r128 + OrbitControls se sirven locales (`scripts/game/`), sin CDN.
- Los planetas usan la imagen real del juego como textura
  (`{dpath}planeten/small/s_*.jpg`); si la imagen falla, textura procedural.
- El visor respeta `max_galaxy`, `max_system` y `max_planets` de la config.
- `MaxFleetSetting` y los ids `#slots`/`#elementID210/209/219`/`#missiles`
  se conservan para que `galaxy.js` siga actualizando contadores.
- La tabla de estado de flota (`#fleetstatusrow`) sigue existiendo (oculta)
  para compatibilidad con `astrogxFleetAjax`.
