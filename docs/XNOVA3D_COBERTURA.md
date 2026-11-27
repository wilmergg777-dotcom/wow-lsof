# XNOVA 3D — Cobertura de módulos (análisis completo)

> Fecha: 2026-11-27 · Rama: xnova3d · Versión extendida en
> `download/XNOVA3D_Informe_Cobertura_Modulos.docx`

## Cifras del inventario (calculadas con script sobre el código)

- **78** páginas clásicas de jugador (`includes/pages/game/Show*Page.class.php`)
- **6** módulos con **escena 3D propia** (datos + acciones reales)
- **51** páginas distintas en el **catálogo de paneles** del 3D (`page.x3d.mods.tpl`)
- **Cobertura: 52 de 78 (67%)** — con P1+P2 sube al **88%**
- **14 huecos reales** · 12 páginas de sistema/sub-flujos que no cuentan

## Nivel 1 — Escenas 3D propias

| Módulo clásico | Escena | JS | Datos PHP |
|---|---|---|---|
| buildings | BASE | `scripts/game/x3d/base.js` | `includes/classes/x3d/X3dBase.php` |
| shipyard | NAVES | `scripts/game/x3d/hangar.js` | `includes/classes/x3d/X3dHangar.php` |
| research | INVESTIGACIÓN | `scripts/game/x3d/lab.js` | `includes/classes/x3d/X3dLab.php` |
| imperium | IMPERIO | `scripts/game/x3d/imperio.js` | `includes/classes/x3d/X3dImperio.php` |
| fleetTable | FLOTAS | `scripts/game/x3d/flotas.js` | `includes/classes/x3d/X3dFlotas.php` |
| galaxy | GALAXIA 3D | `scripts/game/galaxy3d.js` | `includes/classes/Galaxy3dService.php` |

La Galaxia 3D además **actúa**: espía (fleetAjax), recicla asteroides/escombros,
coloniza, lanza misiles y abre el flujo de flota clásico con la misión
preseleccionada (atacar, transportar, desplegar, retener, expedir, destruir luna).

## Nivel 2 — Catálogo de paneles (52 entradas / 51 páginas)

Juego (12): buildings, research, shipyard×2, resources, fleetTable, techtree,
imperium, information, trader, resourceTrader, officier · Alianza/social (9):
alliance, messages, buddyList, chat, statistics, search, playerCard, notes,
referral · Combate (9): battleSimulator, battleHall, fleettools, events, raport,
records, pve, pvp, war · Economía (10): market, crossmarket, fleetDealer,
lottery, raffles, shop, wallet, vip, improvements, battlepass · Extras (12):
cueva, minijuegonavidad, minijuegotopo, tourney, race, faction, tasks,
questions, settings, banList, ticket, bugreport.

## Nivel 3 — Los 14 huecos reales

| page= | Qué es | Propuesta |
|---|---|---|
| overview | Inicio clásico | Panel ya (P1); escena Inicio futura |
| planet | Renombrar/borrar planeta | Panel ya (P1) |
| fleet1/2/3 | Envío de flota (3 pasos) | **Escena nativa 3D (P2)** |
| fleetMissile | Misiles interplanetarios | Panel (P1), escena (P5) |
| phalanx | Sensor de luna | **Escena nativa 3D (P3)** |
| changelog | Novedades de versión | Panel ya (P1) |
| board | Foro externo | Panel ya (P1) |
| allianceBank / allianceTalent | Banco y talentos de alianza | Panel ya (P1) |
| raceTalent / racefaction | Talentos y facción de raza | Panel ya (P1) |
| bugtrack | Tracker de errores | Panel ya (P1) |

No cuentan como huecos: sub-flujos de la Cueva (se abren desde dentro),
fleetAjax/cuevaAjax (AJAX), externalAuth, scan, error, logout, containers,
walletadmin, ntx20admin y la propia x3d.

## Huecos funcionales dentro de lo ya 3D

1. Producción por hora en el HUD (`x3d/core.js` + `X3dCore.php`).
2. Posición en el ranking en el HUD.
3. Badge de mensajes/informes nuevos en el dock.
4. Botón "enviar flota" directo desde la escena FLOTAS.
5. Refresco automático cuando termina una cola.

## Plan priorizado

- **P1 (minutos):** añadir los 10 módulos del hueco al catálogo
  (`page.x3d.mods.tpl`) → todo el juego alcanzable desde el 3D.
- **P2:** escena nativa de envío de flota (`x3d/flota-envio.js`, POST real a
  fleet1/2/3).
- **P3:** phalanx como radar 3D sobre la luna.
- **P4:** HUD enriquecido.
- **P5:** misiles como escena.
