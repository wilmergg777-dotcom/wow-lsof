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
- **Joyería** (WoW 3.3.5): 6 rangos (Aprendiz 0-75, Oficial 50-150,
  Experto 125-225, Artesano 200-300, Maestro 275-375, Gran Maestro 350-450)
  y 36 recetas repartidas entre Classic (1-300), TBC (300-375) y WotLK
  (350-450), con los materiales y nombres de la guía.
- **Peletería** (WoW 3.3.5): 6 rangos y 30 recetas (Classic 1-300, TBC
  300-350, WotLK 350-450) con los materiales de la guía (cueros, pellejos,
  escamas, cuero boreal...). Además tiene **3 especializaciones**
  (dragontina, elemental, tribal) que se aprenden a partir de 225
  consumiendo los materiales de la misión de la guía; solo se puede elegir
  una por profesión. Las recetas pueden requerir una especialización concreta.
- **Sastrería** (WoW 3.3.5): 6 rangos y 36 recetas (Classic 1-300, TBC
  300-350, WotLK 350-450) con los materiales de la guía (paños de lino,
  lana, seda, mágico, rúnico; tejido abisal + polvo arcano; tejido de
  Escarcha + polvo infinito). Las descargas/madejas son recetas intermedias
  que producen el material que consumen las recetas posteriores. Además
  tiene **3 especializaciones** (tela lunar, fuego de hechizo, tejido de
  sombra) que se aprenden a partir de 350.
- **Encantamiento** (WoW 3.3.5): 6 rangos y 43 recetas (Classic 1-300, TBC
  300-350, WotLK 350-450) con los materiales de desencantamiento de la guía
  (polvos, esencias, fragmentos y gemas/perlas Classic; polvo arcano +
  esencia bidimensional + fragmentos TBC; polvo infinito + esencia cósmica +
  tierra eterna WotLK). No tiene especializaciones. Produce encantamientos
  (tipo `encantamiento`, aplicables a ranuras de equipo), aceites de zahorí
  y **varas rúnicas encadenadas** (tipo `vara`): cada vara consume la
  anterior como material (cobre → plata → dorada → veraplata → arcanita →
  hierro vil → adamantita → eternio → titanio), de modo que deben craftearse
  en orden.
- **Alquimia** (WoW 3.3.5): 6 rangos y 30 recetas (Classic 1-300, TBC
  300-350, WotLK 350-450) con las hierbas de la guía (16 Classic, 4 TBC,
  7 WotLK + barra de saronita y gemas/eternos para transmutaciones).
  Produce pociones (tipo `poción`), elixires (`elixir`), frascos (`frasco`),
  transmutaciones (materiales) y la Investigación de alquimia de Rasganorte.
  Tiene **cadenas de productos intermedios**: la Poción de curación menor
  (receta 1) se consume al craftear la Poción de curación inferior (receta
  2), y el Aceite de pigmeo (375) se consume en la Investigación (400).
  Además tiene **3 especializaciones** (Maestro en pociones, elixires y
  transmutación) que se aprenden a partir de skill 325 — la guía indica
  nivel 68; en WoW real es alquimia 325 + nivel 68, y el framework válida
  skill.
- **Herrería** (WoW 3.3.5): 6 rangos y 38 recetas (Classic 1-300, TBC
  300-350, WotLK 350-450) con lingotes y piedras de la guía (Plata, Bronce,
  Oro, Hierro, Acero, Mitril, Torio; Piedra basta/burda/pesada/sólida/densa;
  Cobalto y Saronita; eternos y titanio). Produce piezas de armadura
  (TipoArmadura), armas (TipoArma, hachas/dagas), piedras de afilar/pulir
  (TipoMaterial, algunas son a la vez material de recetas posteriores) y
  refuerzos (TipoRefuerzo: puntas de escudo, hebillas de cinturón, cadenas
  de arma, runas). Reutiliza items de otras profesiones: las Varas de
  plata/oro (de Encantamiento), la Barra de saronita y el Titanio (de
  Alquimia), el Cuero basto (de Peletería). Tiene dos inserciones en mitad
  de banda como la guía: la Piedra de pulir sólida dentro de los Brazales
  de escamas de oro (185→200, piedra 200→210, brazales 210→215) y el
  aprendizaje de artesano dentro del Yelmo de placas de acero (215→225
  experto, artesano, 225→235).
- **Especializaciones**: `DefEspecializacion` (id, nombre, skill_req,
  descripción, materiales, requiere_especializacion). Soporta árboles
  anidados de dos niveles: una especialización con `requiere_especializacion
  != ""` solo se aprende si el jugador ya eligió ese padre, y al aprenderla
  la hoja reemplaza al padre en el estado (siempre se guarda el ID hoja).
  Herrería lo usa con 2 ramas superiores (Forjador de armaduras / armas,
  skill 200) y 3 sub-maestrías bajo armas (hachas / martillos / invocador,
  skill 225). `AprenderEspecializacion()` valida skill >= req, la relación
  padre/hoja, y consume los materiales.
- **Ingeniería** (WoW 3.3.5): 6 rangos y 42 recetas (Classic 1-300, TBC
  300-350, WotLK 350-450). Su rasgo distintivo son las **cadenas de
  productos intermedios**: pólvoras → bombas, tornillos →
  bombas/mosquetes, tubos → mosquetes/gafas/gadgets, envolturas → bombas,
  capacitor → señuelo. Muchos intermedios son a la vez producto y material
  de recetas posteriores (p.ej. el Capacitor sobrecargado se consume en el
  Señuelo explosivo). El escalón TBC 300-310 fabrica en masa tres
  intermedios: la Envoltura de hierro vil da los 10 puntos de skill y los
  otros dos (tornillos y pólvora elemental) son **recetas "pure-material"**
  (`SkillReq == SkillHasta`: nunca dan skill, se craftean solo como
  material para las bombas, el mosquete y la bengala). El framework lo
  soporta de forma natural: `Craftear` siempre produce el item (línea de
  producir resultado) y solo sube skill si `skill < SkillHasta`. Produce
  explosivos (TipoExplosivo: bombas, bengalas, fuegos artificiales,
  señuelos), armas (TipoArma: trabucos, mosquetes), gafas (TipoArmadura) y
  gadgets/herramientas (TipoMaterial: navaja del ejército gnómico, miras,
  inyectores). Reutiliza items de otras profesiones: lingotes de
  plata/bronce/hierro/acero/mitril/torio (Herrería), saronita y titanio
  (Alquimia), cuero pesado y paños (Peletería). 2 especializaciones
  binarias (Ingeniería goblin / gnómica, skill 200) que consumen
  productos crafteados de la propia profesión (20 Bomba de hierro grande
  para goblin, 6 Tubo de mitril para gnómica).
- **Herboristería** (WoW 3.3.5): la primera profesión de **RECOLECCIÓN** del
  juego. A diferencia de las 7 profesiones de crafteo, no tiene `Recetas`:
  sube recogiendo hierbas de **Nodos** en el mundo con el verbo
  `Recolectar(nodoID)` — que produce la hierba y da habilidad mientras
  `skill < SkillHasta` **sin consumir materiales** (el nodo es la fuente, no
  la bolsa). El framework diferencia ambos verbos: `Craftear` busca en
  `Recetas` y consume materiales; `Recolectar` busca en `Nodos` (campo
  `[]DefNodo` de `DefProfesion`) y no consume nada. 6 rangos y 25 nodos que
  cubren 0→450 de forma **contigua** (cada nivel de skill tiene al menos un
  nodo que la da), siguiendo las zonas de la guía: Mulgore/Elwynn (1-75),
  Loch Modan/Baldíos (75-115), Tierras Altas de Arathi (115-205), Garganta
  de Fuego (205-230), Feralas (230-275), Tierras de la Peste del Oeste
  (275-300), Frondavil/Peste del Este TBC (300-330), Marisma de Zangar
  (330-375), Rasganorte/Cuenca de Sholazar (375-435) y Las Cumbres
  Tormentosas (435-450). Es el **eslabón cross-profesión recolección →
  crafteo**: las hierbas recolectadas son los materiales que consume
  Alquimia (y la futura Inscripción). Reutiliza las 21 hierbas que Alquimia
  ya registró y solo añade Raíz de tierra (Earthroot, nombrada en la guía
  1-75). Sin especializaciones. Cada nodo guarda su `Zona` recomendada
  (informativo, para el cliente).
- **Minería** (WoW 3.3.5): la segunda profesión de recolección y la PRIMERA
  **HÍBRIDA** del juego: combina `Nodos` (picar vetas, verbo `Recolectar`,
  sin consumo) con `Recetas` de **FUNDICIÓN** (mena → barra, verbo
  `Craftear`, consume menas). Es la primera profesión con AMBOS `Nodos` y
  `Recetas` a la vez. La guía sube picando vetas (gathering, la vía
  principal); la fundición es la vía secundaria que además cierra el
  **eslabón cross-profesión más importante del juego**: minar mena → fundir
  barra → la barra la consumen Herrería, Joyería e Ingeniería. 14 nodos
  cubren 0→450 de forma contigua siguiendo las zonas de la guía:
  Mulgore/Dun Morogh (1-65 cobre), Laderas de Trabalomas (66-125 estaño y
  plata), Tierras Altas de Arathi (125-175 hierro y oro), Tierras del
  Interior/Tanaris (175-250 mitril y veraplata, artesano a 200), Cráter de
  Un'Goro/Cuna del Invierno (251-300 torio), Península de Fuego
  Infernal/Marisma de Zangar (300-330 hierro vil, maestro a 275), Nagrand
  (330-375 adamantita y korio), Tundra Boreal/Fiordo Aquilonal (375-400
  cobalto, gran_maestro a 350) y Corona de Hielo/Cuenca de Sholazar
  (400-450 saronita y titanio). 15 recetas de fundición producen las barras
  que ya consumen las profesiones de crafteo (más las **aleaciones** bronce
  = cobre+estaño y acero = hierro+carbón, que consumen BARRAS en vez de
  menas). Registra 14 menas nuevas y 5 barras que faltaban (estaño, hierro,
  oro, acero, korio) más el carbón. Sin especializaciones. 6 rangos.
- **Desuello** (WoW 3.3.5): la tercera y última profesión de recolección
  PURA (verbo `Recolectar`, sin consumo, sin recetas). Como Herboristería
  usa solo `Nodos`. A diferencia de Minería no tiene fundición: lo que se
  desuella ya es el material de crafteo. Cierra el **triángulo de
  recolección** del juego: Herboristería (hierbas→Alquimia), Minería
  (menas→lingotes→Herrería/Joyería/Ingeniería) y Desuello (cueros→Peletería).
  Los cueros que produce son EXACTAMENTE los que Peletería consume (ligero,
  fino, pesado, grueso, basto, pellejo nudoso, boreal) más las rarezas
  escamas viles y pelaje ártico. 9 nodos cubren 0→450 de forma contigua.
  Sin recetas ni especializaciones. 6 rangos.
- **Inscripción** (WoW 3.3.5): profesión de producción introducida en WotLK.
  Su rasgo distintivo es la **CADENA DE TRES PASOS**, la más larga del juego:
  moler hierbas → pigmento, combinar pigmento → tinta, fabricar tinta →
  glifo/pergamino. Los tres pasos usan el verbo `Craftear` (moler = craftear
  hierbas→pigmento; no hace falta un verbo nuevo), igual que las cadenas de
  intermedios de Ingeniería (pólvora→tornillo→gadget) o Encantamiento
  (vara→encantar), pero con un eslabón más. Segundo rasgo: la **Investigación
  de inscripción de Rasganorte**, receta que "descubre" un glifo (modelada
  como receta que produce `glifo_descubierto`; el cooldown diario real no se
  modela). Consume las hierbas de Herboristería (eslabón
  recolección→producción, como Alquimia). 43 recetas (8 moliendas + 13 tintas
  + 8 glifos + 11 pergaminos + 2 vitelas + 1 tarot + 1 investigación) cubren
  0→450 de forma contigua. Sin especializaciones. 6 rangos.
- **Cocina** (WoW 3.3.5): la PRIMERA profesión **SECUNDARIA** del juego
  (`Primaria=false`, no cuenta contra el límite de `MaxProfesionesPrimarias`).
  Todo jugador puede aprenderla además de sus dos primarias. Es de producción
  pura: consume pescado/carne/especias y produce comidas con buff de
  atributo. Requiere una fuente de calor (lumbre/estufa — no modelado). Los
  WotLK 400-450 usan `northern_spice` (recompensa de misiones diarias — el
  cooldown diario real no se modela). 13 recetas cubren 0→450. Sin
  especializaciones. 6 rangos. Eslabón: consume el pescado de Pesca.
- **Pesca** (WoW 3.3.5): la SEGUNDA profesión **SECUNDARIA**
  (`Primaria=false`). Recolección como Herboristería/Desuello (verbo
  `Recolectar`, sin consumo, sin recetas), pero **sin nodos fijos** en el
  mundo — se pesca en cualquier masa de agua, modelado aquí como un "nodo"
  por banda/zona de pesca. El equipo (caña con +habilidad y cebos
  consumibles) mejora la pesca — no modelado. Rangos experto (libro),
  artesano (misión de 4 peces raros) y maestro (libro) están quest-gated —
  simplificado: se aprenden normalmente al alcanzar el skill. 10 nodos
  cubren 0→450 de forma contigua. Eslabón: los pescados que produce son
  EXACTAMENTE los que Cocina consume — cierra el **bucle de las dos
  secundarias** (pescar → cocinar). Sin especializaciones. 6 rangos.

Con esto el sistema de profesiones cubre las **13 profesiones** de WotLK:
9 primarias (Joyería, Peletería, Sastrería, Encantamiento, Alquimia,
Herrería, Ingeniería, Inscripción, + 3 de recolección: Herboristería,
Minería, Desuello) y 2 secundarias (Cocina, Pesca). Total: ~340 recetas +
49 nodos, 16 especializaciones, 6 rangos por profesión. Los tres eslabones
cross-profesión están cerrados: recolección→crafteo (hierbas, lingotes,
cueros), recolección→producción (Herboristería→Alquimia/Inscripción) y el
bucle de secundarias (Pesca→Cocina).

El cliente abre el panel de profesiones con la tecla **P**; muestra las
profesiones conocidas (barra de habilidad + botón para aprender el
siguiente rango y, si aplica, las especializaciones disponibles con sus
materiales), permite aprender profesiones nuevas y lista las recetas
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
