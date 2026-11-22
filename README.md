# Aethelgard

> MMO WoW-like multiplataforma (Android + Windows + Linux + macOS), **sin web**.
> Cliente en Godot 4 + servidor autoritativo en Go.

![Aethelgard](cliente/icon.svg)

## Qué es

Aethelgard es un prototipo jugable (MVP) de un MMO RPG estilo World of Warcraft
(Wrath 3.3.5 como referencia), construido **desde cero** con un objetivo claro:
**reducir el consumo del VPS eliminando el cliente web** y empujando a los
usuarios hacia apps nativas multiplataforma. El servidor es **autoritativo**:
corre el `Sim` del juego a 20 Hz, resuelve todo el combate y persiste los
personajes. El cliente es solo renderer + input.

### Por qué no web

- Cada cliente web recalienta cache de assets, recarga escenas y mantiene
  pestañas que se suspenden al cambiar de ventana → reconexiones constantes.
- Las apps nativas traen **todos los assets empacados**, mantienen la conexión
  TCP mejor, y no descargan nada del CDN en cada visita.
- Resultado: **menos ancho de banda de assets, menos reconexiones, menos
  handshakes de auth** y una experiencia mucho más fluida en móvil.

> ⚠️ Importante: la app nativa **no alivia el cómputo del servidor** (el `Sim`
> autoritativo siempre corre server-side). Lo que alivia es el tráfico de
> assets y la estabilidad de la conexión. Esto es un MVP; el path real para
> bajar costos de cómputo es modo offline para PvE solitario (no incluido aquí).

## Estado del MVP

Implementado y probado:

- ✅ Servidor Go TCP, 20 Hz, autoritativo, con bcrypt + persistencia JSON.
- ✅ Login, registro de cuenta, crear personaje (2 clases: Guerrero y Mago).
- ✅ Mundo con 5 mobs iniciales (Lobos, Jabalíes) con IA de patrulla y agro.
- ✅ Combate tab-target + auto-ataque + 2 habilidades por clase + buffs.
- ✅ Sistema de cooldowns, regen de ira/maná, daño crítico, muerte y respawn.
- ✅ HUD con HP, energía, objetivo, barra de habilidades con cooldowns.
- ✅ Cliente Godot 4 con login, selección de personaje, mundo 3D con cámara
  tercera persona, movimiento WASD, mouse para orbitar cámara.
- ✅ Presets de exportación para Android, Windows, Linux y macOS.
- ✅ Protocolo de red documentado (frames JSON longitud-prefijada).

Pendiente (no está en este MVP):

- ❌ PvP (los jugadores no pueden dañarse entre sí — solo PvE).
- ❌ Inventario, equipamiento, loot, vendors, quests.
- ❌ Grouping, raid, dungeons instanciados, trading.
- ❌ Multi-zona (solo un mundo plano por ahora).
- ❌ Clases adicionales (solo Guerrero y Mago).
- ❌ Persistencia con Postgres (MVP usa JSON en disco).
- ❌ Anti-cheat avanzado (solo validación de velocidad de movimiento).

## Estructura del proyecto

```
aethelgard/
├── README.md                    ← este archivo
├── docs/
│   ├── ARQUITECTURA.md          ← diseño del sistema
│   ├── PROTOCOLO.md             ← protocolo de red cliente↔servidor
│   └── DESARROLLO.md            ← cómo compilar, probar y extender
├── servidor/                    ← servidor en Go
│   ├── go.mod / go.sum
│   ├── cmd/servidor/main.go     ← entry point
│   └── interno/
│       ├── geometria/           ← Vec3/Vec4 sin dependencias
│       ├── proto/               ← tipos de mensajes + frame helpers
│       ├── auth/                ← cuentas con bcrypt
│       ├── persistencia/        ← guardado de personajes en JSON
│       ├── mundo/               ← mundo autoritativo: tick, IA, combate
│       └── conexion/            ← TCP listener + sesión por conexión
└── cliente/                     ← cliente en Godot 4
    ├── project.godot            ← config del proyecto + input actions
    ├── export_presets.cfg       ← presets Android/Win/Linux/macOS
    ├── icon.svg
    ├── escenas/
    │   ├── pantalla_login.tscn
    │   ├── pantalla_seleccion.tscn
    │   ├── mundo.tscn           ← escena 3D principal + HUD
    │   └── hud.tscn
    ├── guiones/
    │   ├── red.gd               ← autoload: conexión TCP + protocolo
    │   ├── login.gd
    │   ├── seleccion.gd
    │   ├── mundo.gd             ← orquestador de la escena 3D
    │   ├── jugador.gd           ← control del personaje local
    │   ├── entidad_remota.gd    ← renderer de mobs/otros jugadores
    │   └── hud.gd               ← barras de vida, cooldowns, etc.
    └── recursos/
        ├── cielo.tres           ← cielo procedural
        └── tema.tres            ← tema de UI
```

## Quickstart

### Servidor (Go)

Requiere Go 1.23+ (o usa el binario compilado):

```bash
cd servidor
go build -o aethelgard-server ./cmd/servidor/
./aethelgard-server -puerto 7777 -datos ./datos
```

El servidor escucha en `0.0.0.0:7777` y guarda cuentas y personajes en
`./datos/`. Ver `docs/DESARROLLO.md` para detalles.

### Cliente (Godot 4)

1. Instala **Godot 4.3+** desde https://godotengine.org/download
2. Abre Godot → **Import** → selecciona `cliente/project.godot`
3. Pulsa **F5** para correr (la escena inicial es `pantalla_login.tscn`)
4. En la pantalla de login: host `127.0.0.1`, puerto `7777`, usuario y
   password. Pulsa **Registrar** la primera vez, luego **Entrar**.

### Controles (en el mundo)

| Tecla | Acción |
|---|---|
| W A S D | Moverse (relativo a la cámara) |
| Mouse | Orbitar la cámara |
| Tab | Targetear el enemigo más cercano |
| T | Auto-ataque on/off |
| 1 | Habilidad del slot 1 |
| 2 | Habilidad del slot 2 |
| Esc | Liberar/capturar mouse |

### Clases MVP

| Clase | Recurso | Habilidad 1 | Habilidad 2 | Estilo |
|---|---|---|---|---|
| Guerrero | Ira (0–100, se genera pegando) | Golpe Heroico (15 ira, +22 daño) | Grito de Guerra (buff +10% daño 30s) | Cuerpo a cuerpo |
| Mago | Maná (0–100, regen 5%/s) | Flecha de Hielo (20 maná, +28 daño, 30m) | Nova de Escarcha (40 maná, +35 daño AoE) | Rango |

## Exportar a las plataformas

Desde Godot: **Project → Export…** y selecciona el preset. Verifica tener
instalados los export templates (**Editor → Manage Export Templates**).

- **Windows**: produce `aethelgard-windows.exe`
- **Linux**: produce `aethelgard-linux.x86_64`
- **macOS**: produce `aethelgard-macos.zip` (necesitas firmar/notarize para
  distribución; para pruebas locales, ejecuta desde el .app extraído)
- **Android**: produce `aethelgard-android.apk` (necesitas Android SDK +
  un keystore de debug o release)

> **Importante**: en `cliente/project.godot` el autoload `Red` ya está
> configurado, y los presets de exportación incluyen los permisos de red.

## Documentación

- [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) — diseño del sistema, paquetes,
  flujo del tick loop, modelo de threading, decisiones clave.
- [docs/PROTOCOLO.md](docs/PROTOCOLO.md) — formato de frames, mensajes
  cliente→servidor y servidor→cliente, semántica de cada campo.
- [docs/DESARROLLO.md](docs/DESARROLLO.md) — cómo compilar, probar,
  extender clases, añadir mobs, depurar el servidor.

## Licencia

MIT. Ver `LICENSE` para el texto completo.

## Crédito

Inspirado en el diseño general de World of Warcraft (Blizzard) y del proyecto
World of ClaudeCraft (Levy Street). El código de Aethelgard se escribió desde
cero; no comparte código con ninguno de los dos.
