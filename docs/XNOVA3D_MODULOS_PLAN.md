# XNOVA 3D — Inventario y plan de migración módulo por módulo

## ESTADO ACTUAL (rama xnova3d)

✅ **Galaxia 3D completa** con imágenes reales (`page=galaxy&vista=3d`).
✅ **ESCRITORIO 3D completo** (`page=x3d`, enlace 🌌 XNOVA 3D en el menú):
   - Escenas 3D con las **imágenes reales del juego**: BASE (planeta real +
     edificios `gebaeude/{id}.gif`), NAVES (hangar de naves y defensas),
     INVESTIGACIÓN (laboratorio), IMPERIO (todos tus mundos con sus texturas
     `planeten/{img}.jpg`), FLOTAS (flotas en vuelo con la imagen de su nave).
   - Acciones reales por POST al juego clásico (mejorar/demoler edificio,
     investigar, construir naves/defensas, cancelar colas).
   - **Dock de MÓDULOS**: TODOS los módulos del juego abren como paneles
     dentro del app 3D (nada queda sin pasar a 3D).
   - API: `api/index.php?r=x3d&modo=...` para las APKs.
   - Archivos: `X3dService.class.php`, `ShowX3dPage.class.php`,
     `page.x3d.tpl`, `scripts/game/xnova3d.js`.

## El principio (acordado)

El Xnova clásico **no se reemplaza**: se pasa a 3D **por piezas**. Cada
módulo clásico conserva su página PHP y su lógica; a 3D se pasa así:

1. **Analizar** el módulo clásico: clase (`includes/pages/game/Show*Page.class.php`),
   plantilla (`styles/templates/game/page.*.tpl`) e **imágenes reales que usa**.
2. **Extraer los datos** a un servicio compartido (patrón `Galaxy3dService`):
   la misma fuente para la página clásica, el modo `fetch` JSON y la API v1.
3. **Pantalla 3D** en la app del visor (canvas Three.js + HUD) usando las
   **imágenes reales del tema** (`styles/theme/gow/…`), nunca gráficos hechos
   por código cuando exista una imagen del juego.
4. **Acciones reales** por `fleetAjax` / API — todo se ve igual en la web
   clásica y en la APK porque es el mismo servidor y la misma base de datos.
5. Probar con el usuario y **corregir poco a poco**; el clásico sigue
   disponible con el selector de vista (`vista=3d` / `vista=clasico`).

## Librería de imágenes reales disponibles (inventario del tema)

| Carpeta del tema (`styles/theme/gow/`) | Conteo | Qué hay ahí |
|---|---|---|
| `gebaeude/` | **136** | Edificios, investigaciones, naves y defensas (la usan Buildings, Research, Shipyard, Defense, Information) |
| `planeten/` | **75** | 61 miniaturas `small/s_*.jpg`, planetas grandes (`dschjungelplanet01..12`, `eisplanet…`, `wasserplanet…`, `trockenplanet…`, `wuestenplanet…`), `mond.jpg`, `debris.jpg`, `s_asteroid.jpg` |
| `images/` | 12 | Recursos (901 metal, 902 cristal, 903 deuterio, 911 energía, 921 materia oscura…) |
| `img/` | 25 | Extras de interfaz |
| `facciones/` | 6 | Escudos/emblemas de facciones |
| `razas/` | 6 | Imágenes de razas |
| `mercado/` | 8 | Mercado |
| `premios/`, `minijuego/`, `tourney/`, `ultimate/` | 14 | Eventos y minijuegos |

✅ **Galaxia 3D ya usa las imágenes reales** (commit `53803ad`): planetas
grandes + relieve, luna `mond.jpg`, asteroide `s_asteroid.jpg`, escombros
`debris.jpg` y miniaturas en el HUD.

## Inventario de módulos (79 páginas) y su plan 3D

### FASE 1 — Núcleo de juego (la base del jugador)

| Módulo | URL clásica | Imágenes reales | Plan 3D | Estado |
|---|---|---|---|---|
| Galaxy (galaxia) | `page=galaxy` | `planeten/` | Visor 3D a pantalla completa + HUD 2 tablas + API | ✅ HECHO |
| Overview (resumen) | `page=overview` | `planeten/{img}.jpg` | **BASE 3D**: tu planeta como esfera gigante con su imagen real; edificios emergen del suelo; recursos al HUD | ⏳ siguiente pieza |
| Buildings (edificios) | `page=buildings` | `gebaeude/{id}.gif` | Edificios 3D sobre la Base (mina, hangar, laboratorio…) con su imagen real como billboard/placa; cola de construcción en el HUD | ⏳ |
| Research (investigación) | `page=research` | `gebaeude/{id}.gif` | Laboratorio 3D: cada investigación con su imagen real; cola como naves de datos | ⏳ |
| Shipyard (naves) | `page=shipyard` | `gebaeude/{id}.gif` | Hangar 3D: naves en rampas con su imagen real; cola con barras | ⏳ |
| Defense (defensas) | `page=shipyard&mode=defense` (mismo módulo) | `gebaeude/{id}.gif` | Torretas/cañones alrededor de la Base | ⏳ |
| Resources (ajuste producción) | `page=resources` | `images/` (recursos) | Panel de sliders sobre la Base 3D | ⏳ |
| Information (info elemento) | `page=information` | `gebaeude/` | Ficha 3D con la imagen real grande + stats + requisitos | ⏳ |
| Settings del planeta | `page=planet` | `planeten/` | Panel (renombrar/borrar) sobre la Base | ⏳ |

### FASE 2 — Flotas y operaciones

| Módulo | URL clásica | Imágenes reales | Plan 3D |
|---|---|---|---|
| FleetTable (despacho) | `page=fleetTable` | `gebaeude/` (naves) | Mapa de despacho 3D: elegir destino mirando la galaxia, naves con casillas reales |
| FleetStep1-3 | `page=fleetStep1/2/3` | `gebaeude/` | Mismo flujo en overlay 3D (velocidad, recursos, misión) |
| FleetMissile | `page=fleetMissile` | — | Selector de misiles en overlay |
| Phalanx | `page=phalanx` | `planeten/` | Sensor 3D sobre el planeta objetivo |
| Fleettools | `page=fleettools` | `gebaeude/` | Gestor de flotas en vuelo como trazas 3D en la galaxia |
| Events / flotas en vuelo | `page=events` | `gebaeude/` | Flotas dibujadas moviéndose en el sistema (misma tabla `uni1_fleets`) |
| Imperium (imperio) | `page=imperium` | `planeten/` + `gebaeude/` | "Tu sistema solar": tus planetas en una fila 3D con resumen por planeta |
| BattleHall / BattleSimulator | `page=battlehall` / `page=battleSimulator` | `gebaeude/` | Simulador 3D: dos flotas enfrentadas con imágenes reales |

### FASE 3 — Economía y comercio

| Módulo | Imágenes reales | Plan 3D |
|---|---|---|
| Trader / ResourceTrader | `images/`, `mercado/` | Cambio de recursos con panel 3D |
| Market / Crossmarket | `mercado/` | Vitrina 3D de ofertas |
| FleetDealer | `gebaeude/` | Vender naves: desguace 3D |
| Lottery / Raffles | `premios/` | Ruleta/tómbola 3D |
| Shop / Vip / Officier / Improvements | `img/`, `premios/` | Tienda HUD con imágenes reales |
| Wallet | `img/` | Cartera como panel |

### FASE 4 — Social y meta (paneles HTML sobre el canvas 3D)

Messages, Alliance (+Bank/Talent), BuddyList, Chat, PlayerCard, Search,
Statistics, Records, Referral(+Rewards), Faction/Race/Racefaction/RaceTalent,
Tasks, Questions, Notes, Settings, BanList, Bugreport/Bugtrack, Ticket,
Board, Changelog, Scan, Containers, Logout, Error.
→ Estos módulos **no necesitan 3D puro**: se muestran como paneles HTML
dentro de la app 3D (igual que hoy los diálogos de Mensaje/Amigo), con su
plantilla clásica intacta.

### FASE 5 — Extras / minijuegos (popups dentro de la app 3D)

Cueva (lobby/ajedrez/flota/partida), Minijuegonavidad, Minijuegotopo,
Tourney, Battlepass, War, Pve, Pvp, Lottery-especiales, Ntx20Admin,
Walletadmin, ExternalAuth.
→ Quedan como popups/HTML sobre el 3D; migración 3D completa solo si el
usuario la pide (por ejemplo War/Pve/Pvp como arenas 3D).

## Patrón técnico por módulo (el mismo que la galaxia)

```
ShowXPage.class.php
  ├── show()   -> vista clásica (tpl original, intacto) o vista 3D (selector)
  └── fetch()  -> JSON para el visor 3D (cobra reglas del juego igual)
X3dService.class.php (compartido página + API)
api/index.php -> r=x  (para las APKs clásica y 3D)
scripts/game/x3d.js -> módulo 3D en la app (reusa el motor de galaxia3d.js)
```

- La **app 3D** es un "escritorio espacial": la galaxia es la pantalla
  principal y cada módulo nuevo se abre como pantalla/panel dentro de la
  misma escena (sin recargar, tipo SPA), o como vista aparte si se prefiere.
- Toda regla del juego (costos, colas, tiempos) la calcula el **PHP del
  juego** — el 3D solo muestra y envía acciones. Así el clásico y el 3D
  nunca divergen.

## Orden de la primera pila (propuesto)

1. ✅ **Galaxia 3D con imágenes reales** (hecho, commit `53803ad`)
2. ⏳ **Overview → BASE 3D** (tu planeta con imagen real + recursos)
3. ⏳ **Buildings 3D** (edificios reales sobre la base + cola)
4. ⏳ **Shipyard 3D** (naves reales en hangar)
5. ⏳ **Research 3D**
6. ⏳ **FleetTable/Step en 3D** (despachar flotas mirando la galaxia)
7. ⏳ **Imperium 3D** (todos tus planetas)
8. Resto por fases, corrigiendo errores poco a poco con cada pieza probada.

> Después de cada pieza: probar en el servidor real, anotar errores y
> corregir antes de pasar a la siguiente. El clásico siempre queda como
> respaldo con el selector de vista.
