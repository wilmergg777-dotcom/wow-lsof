# Guía de desarrollo de Aethelgard

## Requisitos

| Herramienta | Versión | Uso |
|---|---|---|
| Go | 1.23+ | Servidor |
| Godot Engine | 4.3+ | Cliente |
| Python 3 | 3.10+ | Scripts de prueba (opcional) |
| Git | cualquiera | Control de versiones |

Godot se descarga desde https://godotengine.org/download (la versión
**Standard**, no la .NET). No requiere instalación: descomprime y ejecuta
el binario.

## Compilar y correr el servidor

```bash
cd servidor
go build -o aethelgard-server ./cmd/servidor/
./aethelgard-server -puerto 7777 -datos ./datos
```

Flags:
- `-puerto N` (default 7777): puerto TCP.
- `-datos DIR` (default `./datos`): directorio de datos. Se crea si no existe.
  Subdirs: `cuentas/` y `personajes/`.

Para parar: `Ctrl-C` (SIGINT). El servidor persiste a todos los jugadores
activos antes de salir.

### Cross-compile

Para compilar el servidor para otra plataforma desde Linux:

```bash
# Windows (64-bit)
GOOS=windows GOARCH=amd64 go build -o aethelgard-server.exe ./cmd/servidor/

# Linux ARM64 (para un VPS ARM)
GOOS=linux GOARCH=arm64 go build -o aethelgard-server-arm64 ./cmd/servidor/

# macOS Apple Silicon
GOOS=darwin GOARCH=arm64 go build -o aethelgard-server-macos ./cmd/servidor/
```

El binario es estático (no requiere librerías del sistema salvo libc en
Linux), así que puedes copiarlo al VPS y correrlo directamente.

## Probar el servidor sin el cliente

Hay un script Python que simula un cliente completo: registro → login →
crear personaje → caminar → targetear → auto-ataque → habilidades.

```bash
# Asumiendo que el servidor ya está corriendo en 127.0.0.1:7777.
python3 -I /ruta/scripts/prueba_sync.py 127.0.0.1 7777
```

Verás los snapshots imprimirse en consola con HP, posición, cooldowns y
eventos de daño. El script está en
`/home/z/my-project/scripts/prueba_sync.py` (fuera del repo del juego).

## Abrir el cliente en Godot

1. Abre Godot.
2. **Import** → selecciona `cliente/project.godot`.
3. Espera a que importe los recursos (debería tardar <5s).
4. Pulsa **F5** para correr (la escena inicial es `pantalla_login.tscn`).
5. Si Godot pide seleccionar una escena principal, elige
   `res://escenas/pantalla_login.tscn`.

### Conectar al servidor

En la pantalla de login:
- **Host**: `127.0.0.1` (default, para pruebas locales) o la IP de tu VPS.
- **Puerto**: `7777`.
- **Usuario** y **password**. Pulsa **Registrar** la primera vez.

### Depuración

- **Godot Output dock**: muestra los `print` de `red.gd` (conexión, mensajes).
- **Errores de parsing**: si ves `[Red] JSON inválido`, hay un mismatch entre
  el servidor y el cliente. Verifica que los tipos del protocolo coincidan
  (ver `docs/PROTOCOLO.md`).
- **Servidor no responde**: verifica con `ss -tln | grep 7777` que esté
  escuchando. Si el cliente no logra conectar, puede ser firewall del VPS
  (abre el puerto 7777 TCP).

## Exportar el cliente

1. En Godot: **Editor → Manage Export Templates → Download**.
2. **Project → Export…** → selecciona un preset.
3. Pulsa **Export Project**. El binario se guarda en `cliente/export/`.

### Android (APK)

Necesitas:
- Android SDK (instalado vía Android Studio o `sdkmanager`).
- Un keystore de debug (Godot lo genera automáticamente) o uno de release.
- Export templates de Android instaladas.

El preset en `export_presets.cfg` ya tiene:
- `package/unique_name = "com.aethelgard.cliente"`
- `gradle_build/use_gradle_build = true` (recomendado en Godot 4).
- `assets_permission/network = true` (permiso de Internet).

Para instalar en un dispositivo conectado:
```bash
adb install export/aethelgard-android.apk
```

### Windows / Linux / macOS

Los presets están listos. Para Windows y macOS, si quieres distribuir
públicamente necesitas firmar el binario (Windows: certificado Authenticode;
macOS: cuenta de desarrollador Apple + notarización). Para pruebas locales
no hace falta.

## Cómo extender el juego

### Añadir una clase nueva

Edita `servidor/interno/mundo/defs.go` y añade una entrada a
`clasesPredefinidas()`:

```go
"picaro": {
    ID: "picaro",
    Nombre: "Pícaro",
    HPBase: 90, HPPorNivel: 14,
    EnergiaBase: 100, EnergiaPorNivel: 0,
    TipoEnergia: "energia",  // regenera sola
    RegenEnergia: 4,         // 4% por segundo
    DañoAutoAtaque: 6,
    IntervaloAutoAtaqueMs: 1500,  // rápido
    RangoCuerpoACuerpo: 1.8,
    Habilidades: []DefHabilidad{
        {ID: "apunalar", Nombre: "Apuñalar", Tipo: "dano",
         CostoEnergia: 40, CooldownMs: 6000, RangoMetros: 1.8,
         DañoBase: 35, Icono: "apunalar"},
        {ID: "evasion", Nombre: "Evasión", Tipo: "buff",
         CostoEnergia: 0, CooldownMs: 60000, RangoMetros: 0,
         DuracionBuffMs: 10000, MagnitudBuff: 0.50,  // +50% dodge
         IDBuff: "evasion", Icono: "evasion"},
    },
},
```

Para que el cliente la ofrezca al crear un personaje, edita el `OptionButton`
`Clase` en `cliente/escenas/pantalla_seleccion.tscn` (añade el item) y mapea
el texto al ID en `seleccion.gd` (`_on_crear`).

### Añadir un mob

Edita `spawnEnemigosIniciales()` en `defs.go`:

```go
spawns = append(spawns, struct {
    nombre string; pos red.Vec3; nivel int
}{"Oso Pardo", geometria.Vec3{X: -30, Y: 0, Z: 30}, 3})
```

Para tipos de mob con comportamiento distinto, crea un nuevo `tipo` y
ramifica en `Enemigo.actualizar`. Para MVP todos los mobs usan la misma IA.

### Añadir una habilidad

1. Añádela a la `DefClase` correspondiente en `defs.go`.
2. Si es un tipo nuevo (`"curacion"`, `"carga"`, etc.), implementa la
   resolución en `combate.go` (`aplicarCuracion`, `aplicarCarga`, etc.).
3. En el cliente, configura los slots del HUD en `mundo.gd::_cargar_personaje`.

### Cambiar el tick rate

Edita `mundo.go`:

```go
const HzPredeterminado = 30  // era 20
```

O pásalo por flag:

```go
// cmd/servidor/main.go
hz := flag.Int("hz", 20, "tick rate del mundo")
m := mundo.NuevoMundo(mundo.ConfigMundo{Hz: *hz, ...})
```

**Ojo**: subir el Hz aumenta el cómputo del servidor linealmente y el
tráfico de red proporcionalmente. Para un VPS pequeño, 20 Hz es un buen
punto.

## Performance y tuning para VPS

### Cuánto consume el servidor (mediciones del MVP)

- **CPU**: con 1 jugador activo y 5 mobs, el tick loop a 20 Hz consume
  <1% de un core moderno. La mayor parte del tiempo está en
  `time.Sleep` (esperando el próximo tick).
- **Memoria**: ~20 MB residentes (Go runtime + mundo + 1 jugador).
- **Ancho de banda por jugador**: ~20 snapshots/s × ~500 bytes = 10 KB/s
  de bajada + ~100 bytes/s de subida (intents a 10 Hz). Para 100 jugadores
  concurrentes: ~1 MB/s de bajada total, ~10 KB/s de subida.
- **Disco**: cada personaje ocupa ~500 bytes en JSON. Una cuenta con 3
  personajes: ~1.5 KB.

### Qué escalar primero cuando el VPS se sature

1. **Persistencia**: migrar de JSON a Postgres. Cada guardado a 10s con
   100 jugadores es 100 fsync/s, que es donde el disco se vuelve cuello de
   botella.
2. **Interest management**: la grilla espacial actual es O(n²) en entidades.
   Con cientos de mobs por zona, mudar a una grilla hash.
3. **Sharding**: cada zona en su propio proceso, con un router que mande
   al jugador al shard correcto al cruzar fronteras.
4. **UDP + delta compression**: para reducir el tráfico de snapshots, mandar
   deltas en vez de snapshots completos.
5. **Modo offline para PvE**: empujar el questing y leveling a una versión
   offline del cliente (sin servidor), reservando el online solo para
   grouping, dungeons, PvP y market. Esto es lo que más reduce costos.

### Qué NO escalar cambiando la app nativa por web

**La app nativa ya es la opción de menor consumo cliente→servidor.**
Volver a web empeoraría:
- Ancho de banda de assets (la web recarga assets en cada visita).
- Reconexiones (las pestañas se suspenden).
- No reduce el cómputo del Sim (siempre corre en el servidor autoritativo).

## Tests

El MVP no incluye tests automatizados formales. La validación se hace con:

1. **Script Python `prueba_sync.py`**: prueba end-to-end del protocolo.
2. **Inspección manual de los JSON guardados** en `datos/personajes/`.
3. **Logs del servidor**: `log.Printf` en puntos clave (conexión, error de
   escritor, desconexión).

Para añadir tests en Go (recomendado para producción):

```bash
cd servidor
go test ./...
```

Crear tests en `interno/mundo/mundo_test.go` para:
- Combate: dado un jugador con HP X y un mob con HP Y, después de N ticks
  con auto-ataque, ambos HP son los esperados.
- Persistencia: guardar y cargar un personaje preserva todos los campos.
- Auth: bcrypt funciona, usuario duplicado falla, password incorrecto falla.

## Problemas conocidos

- **Godot 4.3 específico**: el `export_presets.cfg` usa el formato de 4.3.
  Si usas Godot 4.0/4.1/4.2, puede haber leves diferencias en los campos
  (p. ej. `architecture/arm64-v8a` se llamaba distinto en 4.0).
- **macOS sin firma**: al abrir el .app por primera vez, macOS te dirá que
  no se puede abrir porque viene de un desarrollador no identificado.
  Click derecho → Abrir → Confirmar.
- **Linux Wayland**: Godot 4 corre nativamente en Wayland, pero el
  capturar el mouse (`Input.MOUSE_MODE_CAPTURED`) puede comportarse
  distinto. Si tienes problemas, prueba con `GDK_BACKEND=x11` antes de
  lanzar Godot.
