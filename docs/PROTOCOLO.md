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
{"tipo": "crear_pj", "nombre": "Aragorn", "clase": "guerrero"}
```
- `nombre`: 3–16 caracteres, sin prefijos reservados (`mob_`, `pj_`).
- `clase`: `"guerrero"` o `"mago"`.

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
- El servidor valida que el objetivo exista, esté vivo, y sea un mob
  (en MVP no se puede targetear otros jugadores).

### `habilidad`
```json
{"tipo": "habilidad", "habilidad": "golpe_heroico", "objetivo": "mob_1"}
```
- `habilidad`: ID de la habilidad (debe ser una conocida por la clase).
- `objetivo`: ID del objetivo (tab-target).

### `auto_ataque`
```json
{"tipo": "auto_ataque", "activo": true}
```
Toggle del auto-ataque sobre el objetivo actual.

### `logout`
```json
{"tipo": "logout"}
```
Vuelve al estado `esperando_pj` sin cerrar la conexión. El jugador se saca
del mundo y se persiste.

## Mensajes servidor → cliente

### `login_resp`
```json
{"tipo": "login_resp", "ok": true, "personajes": [
  {"nombre": "Aragorn", "clase": "guerrero", "nivel": 1}
]}
```
Si `ok = false`, incluye `error`.

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
{"tipo": "sel_resp", "ok": true, "personaje_propio": {
  "id": "pj_Aragorn", "nombre": "Aragorn", "clase": "guerrero",
  "nivel": 1, "pos": {"x":0,"y":0,"z":0}, "rot": {"x":0,"y":0,"z":0,"w":1},
  "hp_actual": 120, "hp_max": 120, "es_jugador": true
}}
```

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
   "muerto":false
 }}
```

- `entidades`: solo las que están dentro de `RadioInteresMetros = 60` del
  jugador. No se incluye al propio jugador en esta lista (su estado va en
  `estado_pj`).
- `estado_pj.pos` y `estado_pj.rot` son la posición autoritativa. El cliente
  debe reconciliar si la diferencia con su posición local supera el umbral.
- `estado_pj.muerto = true` indica que el jugador está muerto;
  `respawn_ms` indica cuántos ms faltan para el respawn.

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
{"tipo":"error", "mensaje":"energía insuficiente"}
```
Errores de validación de habilidades, targeteo, etc.

## IDs de entidades

- Jugadores: `"pj_" + nombre` (p. ej. `"pj_Aragorn"`).
- Mobs: `"mob_" + N` (p. ej. `"mob_1"`, `"mob_2"`).

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
