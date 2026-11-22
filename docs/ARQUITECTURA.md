# Arquitectura de Aethelgard

## Visión general

Aethelgard sigue el modelo clásico de un MMO autoritativo:

```
┌──────────────────────┐     TCP (frames JSON)     ┌──────────────────────┐
│   Cliente Godot 4    │  ←───────────────────────→ │    Servidor Go       │
│ (renderer + input)   │                            │ (Sim autoritativo)   │
└──────────────────────┘                            └──────────────────────┘
        │                                                     │
        │ NATIVO:                                              │
        │ - Android (APK)                                      │
        │ - Windows (exe)                                      │
        │ - Linux (x86_64)                                     │
        │ - macOS (.app)                                       │
        │ - SIN WEB                                            │
                                                              │
                                                     ┌────────┴────────┐
                                                     │ Postgres        │
                                                     │ (MVP: JSON)     │
                                                     └─────────────────┘
```

El servidor corre el `Sim` del mundo a **20 Hz** (50 ms por tick). El cliente
manda **intents** (movimiento, targeteo, habilidades) y recibe **snapshots**
del mundo cercano. El combate se resuelve **siempre** en el servidor.

## Paquetes del servidor

```
servidor/
├── cmd/servidor/         Entry point. Parsea flags, arranca mundo y TCP.
└── interno/
    ├── geometria/        Vec3 y Vec4. Sin dependencias.
    ├── proto/            Tipos de mensajes + EscribirMensaje/LeerMensaje.
    ├── auth/             Cuentas de usuario. bcrypt cost 10. Archivos JSON.
    ├── persistencia/     Personajes. JSON atómico (.tmp + rename).
    ├── mundo/            El corazón del Sim.
    │   ├── mundo.go      Mundo struct + Entidad interface + tick loop.
    │   ├── defs.go       Clases predefinidas + spawns iniciales.
    │   ├── jugador.go    Jugador (entidad + combate + snapshot + guardar).
    │   ├── enemigo.go    Enemigo (IA patrulla/aggro/ataque/respawn).
    │   └── combate.go    Resolución de habilidades + broadcast cercano.
    └── conexion/         TCP listener + Sesión por conexión.
        ├── servidor.go   Accept loop + goroutine por sesión.
        └── sesion.go     State machine de sesión + escritor.
```

## Modelo de concurrencia

- **Mundo con `sync.RWMutex`**: el tick loop toma `Lock` (escritor) al
  empezar `step()` y lo suelta al final. Cualquier acceso concurrente al
  estado del mundo (jugadores, enemigos, entidades) debe tomar el lock.
- **Una goroutine por tick**: el bucle de tick es una sola goroutine que
  procesa todos los jugadores y mobs en secuencia. No hay paralelismo
  dentro del tick (intencional: simplifica el razonamiento sobre el Sim).
- **Una goroutine por sesión TCP**: lee mensajes del socket y los encola
  al jugador (`EncolarIntent`, no bloqueante).
- **Una goroutine escritora por jugador**: drena el canal de salida
  (`salida chan MensajeServidor`, buffer 64) y escribe al socket.
- **Anti-deadlock clave**: `entidadPorID` y `buscarJugador` **no adquieren
  el lock**. Se asume que el llamador ya lo tiene. Esto evita el deadlock
  clásico de `sync.RWMutex` (no es reentrante: si el goroutine que tiene
  `Lock` llama a `RLock`, se deadlocks).

## Ciclo de vida de una conexión

```
1. TCP accept → Nueva Sesion (estado=esperando_login).
2. Cliente envía "registro" → auth.Registrar (bcrypt) → respuesta.
3. Cliente envía "login" → auth.Login → lista de personajes.
   Sesion.estado = esperando_pj.
4. Cliente envía "crear_pj" (opcional) → persistencia.Guardar → lista_pj.
5. Cliente envía "sel_pj" → persistencia.Cargar → nuevo Jugador →
   Mundo.AgregarJugador → arrancar goroutine escritora → sel_resp con
   personaje_propio. Sesion.estado = en_juego.
6. Cada intent del cliente → EncolarIntent → procesado en el próximo tick.
7. Cada tick → snapshot enviado vía canal salida → escritor → socket.
8. Cliente cierra socket → Manejar() retorna EOF → defer cerrar() →
   QuitarJugador (persiste + borra del mundo) → CerrarSalida (cierra canal
   → escritor termina) → conn.Close().
```

## Tick loop (20 Hz)

```go
func (m *Mundo) step(t time.Time) {
    m.mu.Lock(); defer m.mu.Unlock()
    m.tick++

    // 1. Procesar intents encolados (mov, cambiar_obj, habilidad, auto_ataque).
    for _, j := range m.jugadores {
        j.procesarIntentsPendientes(m)
    }

    // 2. IA de mobs (patrulla, aggro, persecución, ataque).
    for _, e := range m.enemigos {
        e.actualizar(m, t)
    }

    // 3. Combate de jugadores (auto-ataque, regen de energía, buffs).
    for _, j := range m.jugadores {
        j.actualizarCombate(m, t)
    }

    // 4. Cooldowns, muerte/respawn — inline en (2) y (3).

    // 5. Snapshots: enviar a cada jugador las entidades cercanas + su estado.
    for _, j := range m.jugadores {
        j.enviarSnapshot(m)
    }

    // 6. Persistencia cada 200 ticks (10s).
    if m.tick % 200 == 0 {
        m.guardarJugadores()
    }
}
```

### Interest management

Cada snapshot incluye solo las entidades dentro de `RadioInteresMetros = 60`
del jugador. Esto reduce el tamaño de los snapshots en mundos grandes. La
función `entidadesCercanas(pos, excluir)` itera todas las entidades y filtra
por distancia 2D (ignora Y). Para MVP con 5 mobs y pocos jugadores esto es
trivial; en producción se reemplazaría por una grilla espacial.

## Combate híbrido

El combate es **tab-target** (estilo WoW Classic): el jugador selecciona un
objetivo con Tab y las habilidades van a ese objetivo. El componente
"híbrido" (dodge) está diseñado pero **no implementado en el MVP**: la idea
es que al recibir un ataque, el jugador pueda pulsar una tecla dentro de
una ventana de ~200 ms para esquivar (rolling). Para el MVP, el combate es
puro tab-target.

### Flujo de una habilidad

1. Cliente envía `habilidad` con `habilidad_id` y `objetivo`.
2. Sesion.handleEnJuego → `j.EncolarIntent(msg)`.
3. Próximo tick: `j.aplicarHabilidad` → `combate.usarHabilidad`.
4. Validación: cooldown, energía, objetivo vivo, rango.
5. Resolución: aplicar daño/buff/curación/carga.
6. Broadcast de evento `dano`/`buff` a jugadores cercanos.
7. Cooldown y costo se aplican (o se reembolsan si falló la validación).

## Persistencia

- **Cuentas**: JSON en `datos/cuentas/<usuario>.json`. Password con bcrypt.
- **Personajes**: JSON en `datos/personajes/<nombre>.json`. Posición, nivel,
  clase, oro, inventario (placeholder), habilidades conocidas.
- **Guardado atómico**: escribe a `.tmp` y renombra. No se corrompe si el
  servidor cae a mitad de escritura.
- **Frecuencia**: cada 200 ticks (10s) se guardan todos los jugadores activos.
  También al desconectarse y al apagar (SIGINT/SIGTERM).

## Cliente Godot 4

### Autoload

`Red` (en `guiones/red.gd`) es un singleton autoload que maneja toda la red:
- `conectar(host, puerto)`, `desconectar()`, `enviar(msg)`.
- Polling del socket en `_process` (sin threads).
- Buffer interno para parsear frames longitud-prefijadas.
- Signals: `conectado`, `desconectado`, `mensaje_recibido`.
- Cache de `ultimo_personaje_propio` para que mundo.gd lo lea al cargar.

### Escenas

- `pantalla_login.tscn` — host/puerto/usuario/password + Entrar/Registrar.
- `pantalla_seleccion.tscn` — lista de personajes + crear nuevo + Jugar.
- `mundo.tscn` — Node3D con luz, suelo, jugador (CharacterBody3D),
  cámara tercera persona (SpringArm3D), contenedor de entidades y HUD.
- `hud.tscn` — CanvasLayer con HP, energía, objetivo, barra de habilidades.

### Movement y cámara

- WASD se traduce a un vector 3D relativo al yaw de la cámara.
- El mouse orbita la cámara (yaw + pitch) alrededor del jugador.
- La posición se envía al servidor a 10 Hz (cada 100 ms).
- El servidor valida: si el desplazamiento por tick supera 1 m (≈20 m/s),
  rechaza el movimiento. El cliente reconcilia con `EstadoPJ.Pos` del
  snapshot si la diferencia supera 3 m.

## Decisiones de diseño

### ¿Por qué Go para el servidor?

- Concurrencia trivial (goroutines + channels).
- Compila a binario estático: deploy = un archivo, sin runtime.
- Tipado estático, performance predecible, stdlib sólida (net, encoding/json,
  crypto).
- Para un Sim autoritativo a 20 Hz, Go tiene el balance justo de ergonomics
  y performance.

### ¿Por qué Godot 4 para el cliente?

- Open source (MIT), sin royalties.
- Exporta nativo a Android/Win/Linux/macOS desde un solo proyecto.
- GDScript es accesible, lo que facilita que la comunidad extienda el juego.
- 3D decente para un MVP WoW-like sin necesidad de assets AAA.
- Sin dependencia de un editor cerrado o licensing restrictivo.

### ¿Por qué TCP y no UDP?

Para MVP, TCP es más simple y suficiente para un MMO de baja escala (cientos
de jugadores por servidor). UDP + fiabilidad custom es lo correcto para
escalar a miles, pero agrega complejidad que no se justifica para el MVP.

### ¿Por qué JSON y no un formato binario?

JSON es más fácil de depurar (puedes `tail -f` el tráfico con un proxy).
El overhead de parseo es despreciable a 20 Hz con payloads de ~500 bytes.
Para producción se migraría a un formato binario compacto (FlatBuffers,
MessagePack o un schema custom).

## Limitaciones conocidas

- **PvE only**: los jugadores no pueden dañarse entre sí.
- **Una sola zona**: el mundo es un plano de 200×200 m sin transiciones.
- **5 mobs fijos**: no hay sistema de spawn dinámico ni tablas de loot.
- **JSON persistence**: no escala más allá de unos pocos cientos de
  personajes. Postgres es el siguiente paso.
- **Sin anti-cheat avanzado**: solo validación de velocidad de movimiento.
- **Sin threading en el cliente**: el polling del socket corre en
  `_process`, lo que puede causar lag si el frame rate cae. Para producción
  se movería a un Thread con `call_deferred` para emitir signals.
