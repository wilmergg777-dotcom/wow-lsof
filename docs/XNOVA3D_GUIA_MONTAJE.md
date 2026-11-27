# XNOVA 3D — Guía de montaje en el servidor

> Fecha: 2026-11-27 · Rama: xnova3d · Versión extendida en
> `download/XNOVA3D_Guia_Montaje_Servidor.docx`

## 1. Rutas de archivos (todo dentro de la raíz del juego)

La raíz es el directorio donde están `game.php`, `includes/`, `scripts/`,
`styles/` y `api/`.

| Ruta | Contenido |
|---|---|
| `scripts/game/three.min.js`, `OrbitControls.js` | Librerías 3D |
| `scripts/game/x3d/core.js` | Núcleo del escritorio 3D |
| `scripts/game/x3d/{base,hangar,lab,imperio,flotas}.js` | Una escena por módulo |
| `scripts/game/galaxy3d.js` | Galaxia 3D |
| `includes/classes/X3dService.class.php` | Router del servicio 3D |
| `includes/classes/x3d/X3dCore.php` | Núcleo de datos (imágenes, costos, esquinas) |
| `includes/classes/x3d/X3d{Base,Hangar,Lab,Imperio,Flotas}.php` | Datos por módulo |
| `includes/classes/Galaxy3dService.php` | Datos de la galaxia |
| `includes/pages/game/ShowX3dPage.class.php` | Página `page=x3d` y `mode=fetch` |
| `styles/templates/game/page.x3d.tpl` | Plantilla del escritorio |
| `styles/templates/game/page.x3d.mods.tpl` | Catálogo de módulos |
| `api/index.php` | API JSON (r=ping, login, x3d, galaxy, top, me…) |
| `docs/XNOVA3D_*.md` | Plan, cobertura y esta guía |

Flujo: navegador → `game.php?page=x3d` → JS (`x3d/core.js` + módulo) →
`game.php?page=x3d&mode=fetch&modo=…` → `X3dService` → clase del módulo →
`Database::get()` → **la misma BD MySQL del juego** → JSON → escena 3D con
imágenes reales. Las acciones van por POST a las páginas clásicas
(buildings/research/shipyard), que son quienes escriben en la BD.

## 2. Subir el código

- **Git (recomendado):** en la raíz del juego: `git fetch origin` →
  `git checkout xnova3d` → `git pull origin xnova3d`.
  Volver al clásico: `git checkout main`.
- **FTP/cPanel:** subir la tabla anterior creando las subcarpetas
  `scripts/game/x3d/` e `includes/classes/x3d/`; permisos 644/755; **borrar**
  `scripts/game/xnova3d.js` si existía (ya no se usa).
- Sin compilación ni instalación: recargar con **Ctrl+F5**.

## 3. Base de datos

**No se configura nada nuevo.** El 3D usa `Database::get()` y el array
`$database` de `includes/config.php` (host, port, user, userpw, databasename,
tableprefix). Lee (solo lectura): `uni1_planets`, `uni1_users`, `uni1_fleets`,
`uni1_session` y config. Toda escritura la hacen las páginas clásicas.
Comprobador rápido: abrir `game.php?page=x3d` y ver tus recursos reales en el HUD.

## 4. Pruebas

1. **Web:** `game.php?page=x3d` → recorrer el dock (Base → Naves →
   Investigación → Imperio → Flotas), clic en un edificio → Mejorar → comprobar
   en la página clásica; catálogo ☰ Módulos; Galaxia 3D con un espionaje.
2. **Fetch JSON (con sesión):** `game.php?page=x3d&mode=fetch&modo=base`
   (y hangar, lab, imperio, flotas) → debe devolver JSON.
3. **API / APK:**
   - `GET /api/?r=ping` → estado
   - `POST /api/` con `r=login`, `username`, `password` → `{token}`
   - `GET /api/?r=x3d&modo=base` con header `Authorization: Bearer TOKEN`
     (o `?token=TOKEN`) → mismo JSON del fetch.
   El token es la sesión real del juego (`uni1_session`); CORS ya incluido.

## 5. Primeros errores y corrección

Mirar siempre: **F12** (Consola/Red) para el cliente y **error_log** del
hosting para PHP. Regla modular: se corrige SOLO el archivo del módulo que falla.

| Síntoma | Causa | Corrección |
|---|---|---|
| Página en blanco / 500 en page=x3d | Falta un PHP del 3D | Ver error_log y subir el archivo |
| Queda en "CARGANDO XNOVA 3D…" | 404 de three.min.js / x3d/*.js | F12 Red: subir el archivo que falta |
| "No se pudieron cargar los datos" | Error PHP en el fetch del módulo | Abrir el fetch, leer el error, corregir SU clase |
| Objetos grises sin imagen | 404 de gebaeude/NN.gif | Completar las imágenes del tema gow |
| Botón Mejorar sin efecto | POST devolvió error o login | F12 Red: sesión expirada, reentrar |
| API sin sesión | Token caducado | r=login de nuevo, Bearer nuevo |
| Cambios JS no se ven | Caché del navegador | Ctrl+F5 (?v=REV) |
| CORS desde otra web | Petición sin credenciales | La API ya admite cualquier origen; revisar fetch |
| Horas raras en colas | Timezone del servidor | Ajustar timezone en config.php |

## 6. Checklist final

1. Rama xnova3d actualizada en el servidor.
2. `scripts/game/xnova3d.js` antiguo borrado.
3. `game.php?page=x3d` abre con estrellas y HUD con recursos reales.
4. Las 5 escenas del dock cargan sin avisos.
5. Fetch JSON OK para los 5 modos.
6. Una orden real funciona (mejorar edificio y verlo en la cola clásica).
7. Catálogo abre paneles dentro del 3D.
8. Galaxia 3D navega y espía con sonda real.
9. API: ping + login + x3d con Bearer OK.
10. Probado en móvil/WebView.
