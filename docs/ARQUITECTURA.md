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
    │   ├── mundo.go      Mundo struct + Entidad interface + tick loop + zonas.
    │   ├── defs.go       Facciones, razas, clases, masmoras, arenas + spawns iniciales.
    │   ├── items.go      Catálogo de ítems (materiales + productos crafteados).
    │   ├── profesiones.go Profesiones, rangos, recetas (Joyería 1-450).
    │   ├── jugador.go    Jugador (entidad + combate + inventario + profesiones + guardar).
    │   ├── enemigo.go    Enemigo (IA patrulla/aggro/ataque/respawn).
    │   ├── combate.go    Resolución de habilidades + broadcast por zona.
    │   ├── instancia.go  Instancias aisladas (masmorras PvE + arenas PvP).
    │   └── buscador.go   Colas + matchmaking cross-faction (PvE y PvP).
    └── conexion/         TCP listener + Sesión por conexión.
        ├── servidor.go   Accept loop + goroutine por sesión.
        └── sesion.go     State machine de sesión + escritor + handlers de cola.
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

    // 6. Tick de instancias: comprobar fin (boss muerto, wipe, timeout).
    for id, inst := range m.instancias {
        if inst.tick(m, t) {
            delete(m.instancias, id) // terminó y limpió sus entidades
        }
    }

    // 7. Buscador de masmorras/PvP cada ~1 s (20 ticks).
    if m.tick % 20 == 0 {
        m.buscador.procesar(t)
    }

    // 8. Persistencia cada 200 ticks (10s).
    if m.tick % 200 == 0 {
        m.guardarJugadores()
    }
}
```

### Interest management

Cada snapshot incluye solo las entidades dentro de `RadioInteresMetros = 60`
del jugador **y en la misma zona** (mismo `instanciaID`). Esto aísla
visualmente el mundo abierto de cada masmora/arena: dos instancias nunca
se ven entre sí. La función `entidadesCercanasZona(pos, excluir, instanciaID)`
itera todas las entidades y filtra por distancia 2D + tag de zona. Para MVP
con pocas entidades esto es trivial; en producción se reemplazaría por una
grilla espacial por zona.

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

## Facciones, instancias y buscador

### Facciones (WoW 3.3.5, cross-faction)

Existen dos facciones: **Alianza** y **Horda**. La facción se elige al
crear el personaje y se persiste. **Por diseño, la facción no restringe el
agrupamiento**: el buscador de masmorras y las arenas PvP mezclan jugadores
de cualquier facción en el mismo grupo o equipo (cross-faction). La facción
determina qué razas puede elegir el personaje y es narrativa/de identidad.

### Razas

10 razas (5 por facción) con la matriz raza-clase de WoW 3.3.5a, filtrada a
las 7 clases jugables. Cada raza tiene un **racial pasivo** que aplica
modificadores de stats al crear el personaje (HP/maná/daño):

| Facción  | Raza           | Clases permitidas (de las 7)                 | Racial               |
|----------|----------------|----------------------------------------------|----------------------|
| Alianza  | Humano         | guerrero, paladín, pícaro, sacerdote, mago, brujo | Voluntad Humana (+5% HP) |
| Alianza  | Enano          | guerrero, paladín, cazador, pícaro, sacerdote | Forma de Piedra (+5% HP) |
| Alianza  | Elfo Nocturno  | guerrero, cazador, pícaro, sacerdote         | Fusión en Sombras (+5% HP) |
| Alianza  | Gnomo          | guerrero, pícaro, mago, brujo                | Intelecto Expansivo (+5% maná) |
| Alianza  | Draenei        | guerrero, paladín, cazador, mago, sacerdote  | Toque Heroico (+5% daño) |
| Horda    | Orco           | guerrero, cazador, pícaro, brujo             | Sangre de Furia (+5% daño) |
| Horda    | Renegado       | guerrero, pícaro, sacerdote, mago, brujo     | Voluntad de los Renegados (+5% HP) |
| Horda    | Tauren         | guerrero, cazador                             | Resistencia Total (+5% HP) |
| Horda    | Troll          | guerrero, cazador, pícaro, sacerdote, mago   | Regeneración (+5% maná) |
| Horda    | Elfo de Sangre | paladín, cazador, pícaro, sacerdote, mago, brujo | Torrente Arcano (+5% daño) |

### Roles y clases

Cada clase tiene un rol derivado que el buscador usa para formar grupos PvE.
7 clases cubren la trinidad de WoW LK:

| Clase     | Rol       | Energía  | Función                       |
|-----------|-----------|----------|-------------------------------|
| Guerrero  | tanque    | ira      | Cuerpo a cuerpo, aguanta      |
| Paladín   | tanque    | maná     | Tanque sagrado, buffs         |
| Cazador   | dps       | maná     | Rango físico                  |
| Pícaro    | dps       | energía  | Cuerpo a cuerpo, evasión      |
| Mago      | dps       | maná     | Rango, daño AoE de escarcha   |
| Brujo     | dps       | maná     | Rango, sombra                 |
| Sacerdote | soporte   | maná     | Curación de aliados, buffs    |

### Profesiones, inventario y crafteo

El sistema de profesiones permite craftear ítems consumiendo materiales y
subir la habilidad. Está diseñado para crecer "poco a poco": añadir una
profesión nueva es solo añadir otra `DefProfesion` al registro.

- **Inventario**: map `itemID → cantidad` (pilas) en el `Jugador`, persistido
  como `InventarioStacks`.
- **Profesiones**: cada PJ puede tener hasta `MaxProfesionesPrimarias = 2`
  profesiones primarias (regla de WoW). Cada profesión tiene **rangos**
  (Aprendiz → Gran Maestro) que suben el techo de habilidad, y **recetas**
  que consumen materiales y producen ítems.
- **Skill**: cada receta tiene `SkillReq` (mínimo para craftear) y
  `SkillHasta` (a partir de ahí la receta ya no sube). Craftear sube +1
  mientras `skill < SkillHasta` y `skill < SkillMax` (techo del rango).
- **Joyería** (primera profesión, WoW 3.3.5): 6 rangos (Aprendiz 0-75,
  Oficial 50-150, Experto 125-225, Artesano 200-300, Maestro 275-375,
  Gran Maestro 350-450) y 36 recetas repartidas entre Classic (1-300),
  TBC (300-375) y WotLK (350-450), con los materiales y nombres de la guía.

El cliente abre el panel de profesiones con la tecla **P**; muestra las
profesiones conocidas (barra de habilidad + botón para aprender el
siguiente rango), permite aprender profesiones nuevas y lista las recetas
crafteables con sus materiales (tener/necesario) y un botón Craftear.

### Instancias

Una instancia es una zona aislada con su propio set de entidades. Hay dos
tipos:

- **Masmora (PvE)**: se puebla con mobs definidos en `DefMasmora`. Victoria
  al matar al boss. Derrota si todo el grupo muere. Los muertos respawnean
  en el spawn de la masmora tras `RespawnJugadorMs`.
- **Arena (PvP)**: dos equipos (cross-faction). Victoria cuando un equipo
  queda sin vivos. Timeout a los 5 min: gana el equipo con más vivos.
  Los muertos **no respawnean** hasta el fin de la partida.

Las instancias comparten los mapas planos del mundo (`entidades`,
`enemigos`, `jugadores`) pero cada entidad lleva un `instanciaID`. Las
consultas (`entidadesCercanasZona`, `broadcastCercanoZona`) filtran por ese
tag, aislando cada instancia. Coordenadas: las masmorras usan offset X ≥
1000, las arenas X ≥ 5000, para evitar colisiones visuales con el mundo
abierto en caso de un bug de filtrado.

Ciclo de vida de una instancia:
1. El buscador forma un grupo → `nuevaInstanciaMasmora`/`nuevaInstanciaArena`.
2. `inst.iniciar(m)`: registra la instancia, puebla mobs (masmora), mueve a
   los jugadores adentro (set `instanciaID`, `equipo`, teleport al spawn),
   envía `buscador_match` a todos.
3. Cada tick: `inst.tick(m, t)` comprueba condiciones de fin.
4. Al terminar: `finalizar`/`finalizarEquipos` envía `instancia_fin` a cada
   jugador (con su resultado), los devuelve al mundo abierto y limpia los
   mobs de la instancia.

### Buscador (matchmaking)

`Buscador` mantiene dos conjuntos de colas:

- **PvE**: `colaPvE[masmoraID]` map de solicitudes. Matchmaking:
  - Fase estricta: 1 tanque + 1 soporte + (tamano-2) dps.
  - Fase relajada (tras 60 s en cola): cualquier N jugadores sin importar
    roles. Evita esperas eternas cuando falta un rol.
- **PvP**: `colaPvP[arenaID]` map de solicitudes. Cuando hay
  `2*TamanoEquipo` jugadores, se reparten en dos equipos cross-faction
  (sin respetar facción — cualquier mezcla vale).

El buscador corre una vez por segundo desde `step()` (bajo el lock del
mundo). Los métodos `EntrarCola*`/`SalirCola*` (llamados desde la sesión)
adquieren el lock ellos mismos. `Cancelar` no lo adquiere (lo llama
`QuitarJugador` que ya lo tiene).

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

- **PvP solo en arenas**: el combate entre jugadores está habilitado
  únicamente dentro de instancias de arena (equipos 2v2 cross-faction). En
  el mundo abierto no hay PvP.
- **Mundo abierto + instancias**: el mundo abierto es un plano reducido con
  5 mobs fijos; 5 masmorras PvE (adaptadas de world-of-claudecraft: La
  Cripta Hueca, El Bastión Hundido, El Templo Anegado, Cuenca Corazón
  Salvaje, Santuario Gusanoso) y 1 arena PvP (Arena de Skolm) son
  instancias aisladas creadas por el buscador.
- **Sin loot ni experiencia formal**: los mobs no dropean items ni otorgan
  XP trackeada (placeholder para futuro).
- **Matchmaking simple**: la fase relajada del buscador PvE se activa a los
  60 s sin respetar roles; no hay backfill tras abandono.
- **JSON persistence**: no escala más allá de unos pocos cientos de
  personajes. Postgres es el siguiente paso.
- **Sin anti-cheat avanzado**: validación de velocidad de movimiento +
  validación de zona/instancia en combate. No hay detección de speedhacks
  finos ni de botting.
- **Sin threading en el cliente**: el polling del socket corre en
  `_process`, lo que puede causar lag si el frame rate cae. Para producción
  se movería a un Thread con `call_deferred` para emitir signals.
