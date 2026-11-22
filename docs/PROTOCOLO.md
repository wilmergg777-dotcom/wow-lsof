# Protocolo de red de Aethelgard

## Transporte

TCP. Cada mensaje es un **frame longitud-prefijada**:

```
┌──────────────────┬─────────────────────────────────────────┐
│ 4 bytes (uint32) │ N bytes (JSON UTF-8)                    │
│ longitud N (LE)  │ payload                                 │
└──────────────────┴─────────────────────────────────────────┘
```

- La longitud es `uint32` **little-endian**, en bytes.
- `N = 0` es un frame vacío válido (se descarta).
- `N > 1 MiB` se rechaza (protección contra payloads maliciosos).
- El payload es un objeto JSON con un campo `tipo` que identifica el mensaje.

Implementación de referencia:
- Servidor: `servidor/interno/proto/proto.go` (`EscribirMensaje`, `LeerMensaje`).
- Cliente: `cliente/guiones/red.gd` (`enviar`, `_procesar_buffer`).

## Mensajes cliente → servidor

### `login`
```json
{"tipo": "login", "usuario": "x", "password": "y"}
```
Respuesta: `login_resp` o `error`.

### `registro`
```json
{"tipo": "registro", "usuario": "x", "password": "y"}
```
Respuesta: `registro_resp`. Crea una cuenta nueva (bcrypt).

### `crear_pj`
```json
{"tipo": "crear_pj", "nombre": "Aragorn", "clase": "guerrero", "faccion": "alianza", "raza": "humano"}
```
- `nombre`: 3–16 caracteres, sin prefijos reservados (`mob_`, `pj_`, `inst_`).
- `clase`: una de 7 — `"guerrero"`/`"paladin"` (tanque), `"mago"`/`"cazador"`/`"brujo"`/`"picaro"` (dps), `"sacerdote"` (soporte).
- `faccion`: `"alianza"` o `"horda"` (WoW 3.3.5). Narrativa; **no restringe el agrupamiento** — el buscador es cross-faction.
- `raza`: una de 10 razas (5 por facción). Debe pertenecer a `faccion` y permitir `clase` (matriz raza-clase de 3.3.5a). El servidor valida la coherencia.

Respuesta: `lista_pj` con la lista actualizada.

### `sel_pj`
```json
{"tipo": "sel_pj", "nombre": "Aragorn"}
```
Carga el personaje del disco y lo mete al mundo. Respuesta: `sel_resp` con
`personaje_propio` (snapshot inicial).

### `mov`
```json
{"tipo": "mov",
 "pos": {"x": 12.0, "y": 0.0, "z": 5.0},
 "rot": {"x": 0.0, "y": 0.7, "z": 0.0, "w": 0.7}}
```
- `pos`: posición 3D del personaje. El servidor valida que el desplazamiento
  por tick no supere `MaxMetrosPorTick = 1.0` (≈20 m/s).
- `rot`: quaternion. El servidor lo acepta tal cual (no valida rotación).

### `cambiar_obj`
```json
{"tipo": "cambiar_obj", "objetivo": "mob_1"}
```
- `objetivo`: ID de la entidad a targetear. Vacío = deseleccionar.
- El servidor valida que el objetivo exista, esté vivo y esté en la misma
  zona (instanciaID) que el jugador.
- **Mobs**: siempre targeteables en la misma zona.
- **Jugadores**: solo dentro de una instancia (masmora o arena). En masmora
  se puede targetear a un aliado (para curarlo); en arena, a un enemigo
  (para atacarlo) o a un aliado (para curarlo). En mundo abierto no se
  puede targetear a otros jugadores.

### `habilidad`
```json
{"tipo": "habilidad", "habilidad": "golpe_heroico", "objetivo": "mob_1"}
```
- `habilidad`: ID de la habilidad (debe ser una conocida por la clase).
- `objetivo`: ID del objetivo (tab-target). Para `sanacion_rapida`
  (sacerdote), puede ser un aliado o vacío (self).

### `auto_ataque`
```json
{"tipo": "auto_ataque", "activo": true}
```
Toggle del auto-ataque sobre el objetivo actual. En arena PvP también
auto-ataca a jugadores del equipo contrario.

### `logout`
```json
{"tipo": "logout"}
```
Vuelve al estado `esperando_pj` sin cerrar la conexión. El jugador se saca
del mundo y se persiste. Si estaba en una instancia o en cola, se saca
limpiamente.

### `cola_pve_entrar`
```json
{"tipo": "cola_pve_entrar", "masmora_id": "hollow_crypt"}
```
Encola al jugador para el buscador de masmorras PvE. El servidor valida
que la masmora exista y que el jugador tenga nivel suficiente. Respuesta
periódica: `cola_estado`. Al formar grupo: `buscador_match`.

### `cola_pve_salir`
```json
{"tipo": "cola_pve_salir"}
```
Saca al jugador de la cola PvE.

### `cola_pvp_entrar`
```json
{"tipo": "cola_pvp_entrar", "arena_id": "arena_skolm"}
```
Encola al jugador para una arena PvP (cross-faction).

### `cola_pvp_salir`
```json
{"tipo": "cola_pvp_salir"}
```
Saca al jugador de la cola PvP.

## Mensajes servidor → cliente

### `login_resp`
```json
{"tipo": "login_resp", "ok": true,
 "personajes": [
   {"nombre": "Aragorn", "clase": "guerrero", "nivel": 1}
 ],
 "facciones": [
   {"id": "alianza", "nombre": "Alianza"},
   {"id": "horda", "nombre": "Horda"}
 ],
 "razas": [
   {"id":"humano","nombre":"Humano","faccion":"alianza","clases":["guerrero","paladin","picaro","sacerdote","mago","brujo"],"racial_nombre":"Voluntad Humana","racial_desc":"+5% HP"}
 ],
 "clases": [
   {"id":"guerrero","nombre":"Guerrero","rol":"tanque"},
   {"id":"sacerdote","nombre":"Sacerdote","rol":"soporte"}
 ]}
```
Si `ok = false`, incluye `error`. `facciones`, `razas` y `clases` van siempre
que el login sea válido, para que el cliente pueble los selectores de
facción → raza → clase al crear PJ (con la matriz raza-clase).

### `registro_resp`
```json
{"tipo": "registro_resp", "ok": true}
```
Si `ok = false`, incluye `error` (usuario ya existe, password muy corta, etc.).

### `lista_pj`
```json
{"tipo": "lista_pj", "personajes": [...]}
```
Lista actualizada tras crear o borrar un personaje.

### `sel_resp`
```json
{"tipo": "sel_resp", "ok": true,
 "personaje_propio": {
   "id": "pj_Aragorn", "nombre": "Aragorn", "clase": "guerrero",
   "nivel": 1, "pos": {"x":0,"y":0,"z":0}, "rot": {"x":0,"y":0,"z":0,"w":1},
   "hp_actual": 120, "hp_max": 120, "es_jugador": true,
   "faccion": "alianza", "raza": "humano", "rol": "tanque"
 },
 "masmoras": [
   {"id": "hollow_crypt", "nombre": "La Cripta Hueca",
    "nivel_min": 5, "tamano_grupo": 3},
    "nivel_min": 1, "tamano_grupo": 3}
 ],
 "arenas": [
   {"id": "arena_skolm", "nombre": "Arena de Skolm", "tamano_equipo": 2}
 ]}
```
`masmoras` y `arenas` van solo en el `sel_resp` de entrada al mundo, para
que el cliente pueble el panel del buscador.

### `snapshot`
Mensaje principal, enviado a 20 Hz a cada jugador conectado.
```json
{"tipo": "snapshot", "tick": 1234,
 "entidades": [
   {"id":"mob_1", "nombre":"Lobo Salvaje", "clase":"lobo", "nivel":1,
    "pos":{"x":15,"y":0,"z":5}, "rot":{"x":0,"y":0,"z":0,"w":1},
    "hp_actual":55, "hp_max":55, "es_jugador":false, "en_combate":false}
 ],
 "estado_pj": {
   "hp_actual":85, "hp_max":120,
   "energia_actual":30, "energia_max":100,
   "pos":{"x":12,"y":0,"z":4}, "rot":{"x":0,"y":0,"z":0,"w":1},
   "objetivo_id":"mob_1", "auto_ataque_activo":true,
   "cooldowns":{"golpe_heroico":1200},
   "buffs_activos":{"grito_guerra":28000},
   "muerto":false,
   "faccion":"alianza", "raza":"humano", "rol":"tanque",
   "instancia_id":"", "instancia_tipo":"", "equipo":-1
 }}
```

- `entidades`: solo las que están dentro de `RadioInteresMetros = 60` del
  jugador **y en la misma zona** (mismo `instanciaID`). No se incluye al
  propio jugador en esta lista (su estado va en `estado_pj`). Cada entidad
  jugador trae `faccion`, `rol` y `equipo` (PvP).
- `estado_pj.pos` y `estado_pj.rot` son la posición autoritativa. El cliente
  debe reconciliar si la diferencia con su posición local supera el umbral.
- `estado_pj.muerto = true` indica que el jugador está muerto;
  `respawn_ms` indica cuántos ms faltan para el respawn (en arena PvP los
  muertos no respawnean hasta el fin de la partida).
- `instancia_id`: vacío = mundo abierto; otherwise el ID de la masmora/arena
  actual. `instancia_tipo`: `"masmora"` | `"arena_pvp"`. `equipo`: -1 = sin
  equipo (mundo abierto o masmora); 0|1 = equipo PvP.

### `dano`
```json
{"tipo":"dano", "origen_id":"pj_Aragorn", "objetivo_id":"mob_1",
 "cantidad":22, "critico":false}
```
Evento de daño. Broadcast a todos los jugadores cercanos al objetivo.

### `muerte`
```json
{"tipo":"muerte", "entidad_id":"mob_1"}
```
Una entidad murió. Broadcast a jugadores cercanos.

### `respawn`
```json
{"tipo":"respawn", "entidad_id":"pj_Aragorn", "mensaje":"has reaparecido"}
```
El propio jugador ha reaparecido tras morir.

### `buff`
```json
{"tipo":"buff", "origen_id":"pj_Aragorn", "objetivo_id":"pj_Aragorn",
 "mensaje":"grito_guerra"}
```
Un buff se aplicó. El `mensaje` es el ID del buff.

### `curacion`
```json
{"tipo":"curacion", "origen_id":"pj_Aragorn", "objetivo_id":"pj_Aragorn",
 "cantidad":30}
```

### `error`
```json
{"tipo": "error", "mensaje": "energía insuficiente"}
```
Errores de validación de habilidades, targeteo, etc.

### `cola_estado`
```json
{"tipo": "cola_estado", "en_cola": true,
 "tiempo_cola_ms": 12500, "jugadores_en_cola": 3,
 "masmora_id": "cripta_pinargos", "mensaje": "cripta_pinargos"}
```
Estado periódico (cada ~1 s) para jugadores en cola. `en_cola = false`
confirma la salida de la cola. El campo `mensaje` repite el ID de destino
cuando es un update periódico (para que el cliente sepa a qué cola
corresponde).

### `buscador_match`
```json
{"tipo": "buscador_match",
 "instancia_id": "inst_1", "instancia_tipo": "masmora",
 "equipo": -1, "grupo": ["Aragorn", "Elyssa", "Kael"],
 "mensaje": "Cripta de Pinargos"}
```
Se envía a cada jugador del grupo cuando el buscador forma un partido.
`instancia_tipo`: `"masmora"` (PvE) o `"arena_pvp"` (PvP). `equipo`: -1 en
masmora; 0|1 en arena (equipo asignado, cross-faction). `grupo`: nombres de
todos los participantes. `mensaje`: nombre legible del destino.

### `instancia_fin`
```json
{"tipo": "instancia_fin", "instancia_id": "inst_1",
 "resultado": "victoria", "razon": "boss_derrotado"}
```
Fin de la instancia. `resultado`: `"victoria"`, `"derrota"` o `"empate"`
(en PvP, cada jugador recibe su propio resultado según su equipo).
`razon`: `"boss_derrotado"`, `"grupo_dizmado"`, `"equipo_0_gana"`,
`"equipo_1_gana"`, `"timeout"`, `"doble_wipe"`, `"abandono_total"`, etc.
Tras este mensaje, el jugador es devuelto al mundo abierto automáticamente.

## IDs de entidades

- Jugadores: `"pj_" + nombre` (p. ej. `"pj_Aragorn"`).
- Mobs del mundo abierto: `"mob_" + N` (p. ej. `"mob_1"`, `"mob_2"`).
- Mobs de instancia: `"inst_" + instanciaID + "_mob_" + N`
  (p. ej. `"inst_inst_3_mob_1"`).
- Instancias: `"inst_" + N` (p. ej. `"inst_1"`). IDs asignados por un
  contador atómico ascendente.

El cliente NO debe asumir nada sobre la estructura del ID; solo lo usa
para targetear y para correlacionar entidades entre snapshots.

## Convenciones

- **Coordenadas**: Y es arriba, X y Z son el plano horizontal. Distancias
  se calculan en 2D (XZ) para movimiento y combate.
- **Quaternions**: `(x, y, z, w)`, normalizados. Para MVP el servidor no
  valida rotación; el cliente orienta el modelo según la dirección de
  movimiento.
- **Tiempos**: todos los campos `*_ms` son Unix milliseconds.
- **Encoding**: UTF-8. Los strings pueden contener cualquier carácter
  válido UTF-8 (los nombres de personaje se validan a 3–16 caracteres al
  crearlos, pero no se restringen a ASCII).
