### AstroIO Beta v2.3.5 — 19.11.2026
**Versión actual de AstroIO**

-🚧 Avances en Desarrollo de AstroIO
  
  • 👨‍🚀 ** Nuevo Sistema de Oficiales:** Hemos comenzado la implementación de un nuevo Sistema de Oficiales, diseñado para integrarse con futuras mecánicas del juego y ofrecer nuevas formas de progresión para todos los jugadores.
    - 🌦️ ** Sistema de Clima Ampliado** → También estamos desarrollando una nueva expansión para el Sistema de Clima, incorporando nuevas características y eventos que tendrán impacto directo en la experiencia de juego.

  • 🚀 ** Nuevas Naves en Desarrollo:** Además, se encuentran en desarrollo tres nuevas naves:
    - 📦 1 nave de carga.
    - ⚔️ 2 nuevas naves de combate.
    Estas unidades estarán vinculadas al progreso de un nuevo oficial que actualmente se encuentra en fase de desarrollo e implementación.

-⚙️ Estado Actual

  • Todos estos sistemas continúan en desarrollo activo y aún pueden sufrir cambios, ajustes de balance y mejoras antes de su lanzamiento oficial.
  
  • Agradecemos vuestra paciencia y apoyo mientras seguimos trabajando para ofrecer una experiencia cada vez más completa y divertida dentro de AstroIO.

	
### AstroIO Beta v2.3.4 — 17.11.2026
- **🏆 Expansión del Sistema de Logros (Oficiales) — ✅ DISPONIBLE**
  Se ha ampliado el Sistema de Logros actual para incluir una nueva categoría basada en el progreso de los Oficiales. Ahora los jugadores recibirán recompensas adicionales de Materia Oscura al mejorar sus oficiales, igual que ocurría con edificios e investigaciones.
  
  • 🪐 **Nuevas cadenas añadidas:** Se añaden 5 cadenas de 10 niveles cada una, sumando **50 logros nuevos** al juego (Total general: 170 logros).
    - 🪐 **Geólogo Supremo** → Progresión del Nv.2 al Nv.20.
    - 🧭 **Almirante Supremo** → Progresión del Nv.2 al Nv.20.
    - ⚙️ **Ingeniero Maestro** → Progresión del Nv.1 al Nv.10.
    - 🧬 **Tecnócrata Legendario** → Progresión del Nv.1 al Nv.10.
    - 👑 **Consejo Imperial** → Logro especial que requiere combinar los oficiales anteriores.
  
  • 💎 **Recompensas:** Cada nivel superado otorga entre **100 MO y 550 MO**. Completar una cadena entera otorga **3.250 MO**.
  
  • ⚙️ **Mecánica de verificación:** El sistema funciona automáticamente. Al subir el nivel del oficial requerido, el logro se marca como completado y aparece el botón "Reclamar logro".
  
  • 👑 **Detalle del Consejo Imperial:** La interfaz ahora muestra los requisitos exactos de forma dinámica (Ej: *"Geo 2 + Alm 2"* o *"Geo 20 + Alm 20 + Ing 10 + Tec 10"*), permitiendo saber qué oficiales subir para desbloquear el siguiente nivel.
  
  • 🔄 **Progresión continua:** Al reclamar un logro, se desbloquea automáticamente el siguiente nivel de la cadena.

- **🛠️ Correcciones y mejoras generales**
  Se han aplicado ajustes de estabilidad y actualizaciones técnicas para soportar la nueva expansión de logros.
  
  • 🗄️ **Base de Datos:** Se ha modificado el `ENUM` de la tabla `uni1_achievements_catalog` para aceptar los nuevos tipos de requisito `officier` y `officier_all`.
  
  • 🧠 **Backend:** Actualización en `AchievementHelper.class.php` para la lectura dinámica de las columnas de oficiales (`rpg_geologue`, `rpg_amiral`, etc.) en la tabla de usuarios, y cálculo de la lógica combinada para el Consejo Imperial.
  
  • 🎨 **UI:** Renderizado automático de las 17 cadenas en el panel de logros, con textos de requisitos actualizados para los oficiales.

- **📝 Notas de la versión**
  • Esta actualización es **100% compatible** con el progreso actual. Si ya tienes oficiales subidos de nivel, es muy probable que tengas varias recompensas esperando en la pestaña de **Logros**.
  • Si detectas algún comportamiento extraño (logro que no se desbloquea a pesar de tener el nivel de oficial requerido), por favor repórtalo por el sistema de **🐛 Bugs** del juego indicando:
    - ID de jugador
    - Nombre del logro afectado
    - Captura de tu nivel de oficial actual
  • El **Mercado Negro de Colonias** y el **Sistema de Clima** de la versión 2.3.3 continúan estables y sin cambios.
  
### AstroIO Beta v2.3.3 — 16.11.2026
- **🏴‍☠️ Mercado Negro de Colonias — 🚧 EN DESARROLLO**
  Nueva pestaña dentro del Mercado que permitirá comprar y vender **colonias completas** entre jugadores por NTX-20. Actualmente en fase de pruebas internas — **visible para todos, pero puede sufrir cambios o reinicios antes del lanzamiento oficial**.
  
  • 🪐 **Solo colonias:** El **planeta principal NUNCA se puede vender**. Solo se pueden listar las colonias del jugador.
  
  • 📦 **Se vende TODO:** Al comprar una colonia, el comprador recibe **edificios, defensas, naves y recursos** tal como estaban. No hay pérdida de contenido.
  
  • 💰 **Pago en NTX-20:** El comprador paga en NTX-20 al vendedor. El sistema descuenta automáticamente la comisión del **5% normal / 3% VIP** al vendedor al concretarse la venta.
  
  • 🔒 **Validaciones automáticas:**
    - ❌ No se puede vender si hay **flotas en vuelo** o **estacionadas** en la colonia.
    - ❌ No se puede comprar tu **propia colonia**.
    - ❌ No se puede comprar si ya tienes el **máximo de planetas** (10).
    - ❌ No se puede vender en **modo vacaciones**.
  
  • 📊 **Preview antes de comprar:** El comprador puede ver un desplegable con los recursos, naves y defensas que incluye la colonia antes de confirmar la compra.
  
  • 🎨 **Interfaz integrada:** La pestaña aparece dentro del Market con acento dorado-pirata. El formulario de publicación, la tabla "Mis colonias en venta" y el grid "Colonias disponibles" usan el mismo estilo glassmorphism del resto del mercado.
  
  • ⚠️ **Aviso de desarrollo:** Esta funcionalidad está en **fase beta**. Se recomienda probar con precaución. Los listados activos y las ventas realizadas durante el período de pruebas **se conservarán**, pero la interfaz puede cambiar en próximas versiones.

- **🌦️ Sistema de Clima — ✅ DISPONIBLE**
  Ya está **totalmente funcional** el sistema climático global que afecta la producción de recursos y las operaciones de los jugadores.
  
  • ☀️ **Factores climáticos activos:** Cada planeta tiene un clima asignado que modifica su producción (positiva o negativamente).
  
  • 🎁 **Cofres Climáticos disponibles:** Ya se pueden obtener y usar los 3 cofres climáticos:
    - 🟢 **Cofre Climático Menor** → Reduce a la mitad los factores negativos del clima.
    - 🔵 **Cofre Climático Mayor** → Neutraliza todos los factores negativos del clima.
    - 🟣 **Cofre Climático Dominio** → Convierte los negativos en positivos.
  
  • 🛒 **Compra y venta en el Mercado:** Los cofres climáticos ya aparecen en el mercado dentro de la categoría **📦 Cofres**, tanto para **vender** como para **comprar**.
  
  • 🎲 **Drops en expediciones:** Además, los cofres climáticos pueden obtenerse como recompensa aleatoria en las misiones de expedición.
  
  • 🧪 **Accesible desde el menú:** Consulta el estado climático de tus planetas desde el panel de información del planeta.

- **🛠️ Correcciones y mejoras generales**
  Se han aplicado ajustes de estabilidad y limpieza en varios módulos del servidor.
  
  • 🧹 **Market:** Limpieza interna del sistema de ofertas y optimización de las consultas SQL del mercado para mejorar el rendimiento con muchas ofertas activas.
  
  • 🔒 **Seguridad:** Se ha revisado el control de acceso a las pestañas del Market. El Mercado Negro respeta el sistema de permisos y módulos activos del servidor.
  
  • 📝 **Log de auditoría NTX-20:** Las compras y ventas de colonias quedan registradas en el log de NTX-20 (`uni1_ntx20_log`) con el tipo correspondiente, permitiendo al admin auditar todas las transacciones.
  
  • 🎨 **UI:** Ajustes menores de estilos en la pestaña Colonias para que se adapte correctamente en móvil.

- **📝 Notas de la versión**
  • El **Mercado Negro de Colonias** se libera en **fase de pruebas** para que la comunidad pueda probarlo y reportar bugs antes del lanzamiento oficial.
  • Si detectas algún comportamiento extraño (colonia que no se transfiere, saldo que no cuadra, error al comprar), por favor repórtalo por el sistema de **🐛 Bugs** del juego indicando:
    - ID de la colonia o coordenadas
    - Captura del mensaje de error
    - Cuenta afectada
  • El sistema de **Clima** ya está estable y no sufrirá cambios disruptivos en próximas actualizaciones.
  
### _AstroIO Beta v2.3.2 — 08.11.2026_
- **🛡️ Límite Estricto de Miembros en Alianzas (Máximo 7)**
  Se ha implementado una restricción global para que ninguna alianza pueda superar los 7 miembros.
  
  • ⚙️ **Validación Backend:** El servidor rechaza automáticamente cualquier intento de enviar o aceptar una solicitud si la alianza ya está llena (incluso si se intenta hacer por URL).
  
  • 🎨 **Indicadores Visuales:** Se ha añadido el texto en rojo **(LLENA)** y contadores (ej: 7 / 7) en el buscador de alianzas, perfil de la alianza, lista de miembros y página principal.
  
  • 🚫 **Bloqueo de Formularios:** Si la alianza está llena, los formularios de solicitud y los botones de "Aceptar" en el panel de administración se desactivan u ocultan automáticamente.
  
  • 🔒 **Panel de Líder:** El campo para modificar el límite de miembros ahora es de solo lectura, forzando el valor a 7 de forma permanente.

- **🚫 Parches de Seguridad: Bloqueo Global de MOPs por URL**
  Se ha añadido una capa de seguridad en el enrutador principal para evitar el acceso a módulos desactivados.
  
  • 🔒 **Protección Total:** Si un administrador desactiva un módulo desde el panel (ej: Pase de Batalla, Mercado, Topo), los jugadores ya **no pueden acceder escribiendo la URL directamente**. El sistema detecta que el módulo está apagado y frena la carga.
  
  • ⚠️ **Nueva Interfaz Global de Errores:** Se ha rediseñado por completo la plantilla de errores (`error.default.tpl`). Ahora todos los errores (falta de recursos, módulos desactivados, etc.) muestran una ventana con estilo Glassmorphism, bordes cyan, el icono "⚠️ AVISO DEL SISTEMA" y un botón "Volver" centrado.

- **🛠️ Corrección de Errores en Módulos del Servidor**
  Se han solucionado errores lógicos y visuales para estabilizar el servidor.
  
  • 🎖️ **Menú MOP (Oficiales):** El botón ahora desaparece correctamente si se desactiva el módulo de Oficiales.
  
  • 🚀 **Menú MOP (Flota):** Se ha corregido la dependencia del botón. Ahora depende de su propio módulo (`MODULE_FLEET_TABLE`) y no del módulo del Comerciante.
  
  • 🧹 **FleetTools:** Se ha reajustado el módulo centralizado de herramientas de flota para asegurar que el cálculo de tiempo, capacidad de carga y consumo de deuterio sean exactos.

- **🎄 Implementación del Minijuego "Memoria Navideña"**
  Nuevo minijuego de memoria con temática navideña (accesible desde el menú MOP).
  
  • 🃏 **Mecánica:** 16 cartas (8 parejas) para encontrar antes de que termine el tiempo de 60 segundos.
  
  • 🎁 **Recompensas Dinámicas:** Al encontrar una pareja, se obtienen recompensas al instante: 1 hora de producción de recursos (Metal, Cristal o Deuterio), naves, defensas, Materia Oscura o Cofres Genéricos.
  
  • ⏱️ **Cooldown:** 5 horas de espera entre partidas.
  
  • 🔒 **Anti-Cheat:** Validación estricta de tiempo en el servidor y sistema de tokens para evitar trampas.
  
### _AstroIO Beta v2.3.1 — 07.11.2026_
- **🌦️ Implementación del Sistema de Clima de Combate (En desarrollo — Aún no disponible en el servidor)**
  Se añade una nueva capa táctica al juego que afecta exclusivamente a los combates PvP (no altera la economía, el PvE ni los misiles interplanetarios).
  
  • 🌦️ **14 Climas Únicos:** El universo cuenta ahora con 14 condiciones climáticas divididas en 3 categorías (Suaves, Medios y Raros). Cada clima modifica 4 factores clave en combate: Ataque, Defensa, Bajas y Botín.
  
  • ⏰ **Rotación y Predicción:** El clima de cada planeta y luna rota automáticamente todos los días a las 03:00 UTC. Además, a las 21:00 UTC se revela la predicción del clima para el día siguiente, permitiendo a los jugadores planificar sus estrategias con 6 horas de antelación.
  
  • ⚔️ **Fijación en Combate:** Para evitar abusos, el clima se congela en el momento exacto en que se lanza la flota. No importa si el clima rota mientras la flota está en vuelo; la batalla se resolverá con el clima que había al momento del despegue.
  
  • 👁️ **Visibilidad Total (5 Sitios):** Los jugadores tienen información táctica en todo momento:
    - **Espionaje:** Muestra el clima actual y la predicción del objetivo.
    - **Pantalla de Ataque:** Avisa si el clima favorece al atacante o al defensor antes de enviar la flota.
    - **Vista de Galaxia:** Iconos visuales del clima junto a cada planeta/luna.
    - **Informe de Batalla:** Indica qué clima se aplicó durante el combate.
    - **Overview:** Muestra el clima del planeta y la luna propia, junto con avisos automáticos (ej: "Tu defensa está debilitada hoy, haz fleetsave").
  
  • 🔮 **Simulador de Batalla:** Se integra un selector de climas en el simulador para que los jugadores puedan probar sus flotas bajo cualquier condición climática antes de arriesgar sus naves.
  
  • 📊 **Impacto Táctico:** Los climas extremos son raros (ej: "Singularidad" tiene solo un 1% de probabilidad de aparecer y reduce el ataque y defensa en un 50%), mientras que los climas suaves dominan la mayor parte del tiempo, manteniendo el equilibrio del servidor.

- **🌐 Nueva Integración de Chat Global (Discord y Telegram)**
  Se ha implementado un puente de comunicación bidireccional para unificar a toda la comunidad de AstroIO sin importar dónde se conecten.
  
  • 💬 **Chat del Juego Vinculado:** El chat interno del juego ahora envía y recibe mensajes en tiempo real hacia el servidor oficial de **Discord** y el grupo de **Telegram**.
  
  • 🔄 **Sincronización Total:** Los mensajes enviados desde el juego aparecen automáticamente en Discord y Telegram, y los mensajes escritos en esas plataformas se reflejan en el chat del juego.
  
  • 🛡️ **Sistema Anti-Flood:** Todos los mensajes cuentan con protección anti-spam y validación de usuarios para mantener el chat limpio y seguro.

- **🏴‍☠️ Corrección del Minijuego "Ajedrez Pirata" (La Cueva Pirata)**
  Se han solucionado varios errores críticos que afectaban a la experiencia de juego en las partidas de ajedrez 1v1.
  
  • ♟️ **Validación de Movimientos:** Se ha corregido un fallo que permitía a los jugadores mover piezas que no estaban en su turno o realizar movimientos ilegales (como saltar piezas o mover el rey a una posición de jaque).
  
  • ⏱️ **Control de Tiempo (Timeout):** El reloj de 60 segundos por turno ahora funciona correctamente. Si un jugador no realiza su movimiento a tiempo, el sistema declara automáticamente al rival como ganador y le entrega el pozo.
  
  • 🏆 **Fin de la Partida:** Se ha arreglado el sistema de detección de final de partida para que reconozca correctamente el "Jaque Mate", las "Tablas" (empate) y la "Rendición", entregando o devolviendo las apuestas (NTX-20 o recursos) de forma segura y sin pérdidas.
  
  • 🎨 **Estabilidad del Tablero:** Se ha corregido un error visual que hacía que el tablero se congelara o las piezas desaparecieran al recibir una actualización del servidor.

- **🛠️ Corrección de Errores en FleetTools (Herramientas de Flota)**
  Se ha reajustado el módulo centralizado de herramientas de flota para garantizar su correcto funcionamiento y estabilidad.
  
  • 🚀 **Reunir Flotas:** Se ha corregido un error que impedía seleccionar correctamente las naves de otros planetas y enviarlas al planeta de origen. Ahora el cálculo de tiempo y consumo de deuterio se actualiza en tiempo real.
  
  • 📦 **Reunir Recursos:** Se ha solucionado un fallo en el cálculo de la capacidad de carga de las naves, asegurando que los recursos se transporten correctamente sin exceder los límites de la bodega.
  
  • 🔄 **Distribuir Recursos:** Se ha corregido un problema que hacía que el sistema no detectara correctamente los recursos disponibles al momento de distribuirlos entre planetas. Ahora la validación es exacta y el envío se realiza sin errores.

---

### _AstroIO Beta v2.3.0 — 06.11.2026_
**Versión actual de AstroIO**
- Implementación del Sistema de Clima de Combate (Desarrollo todavia no disponible servidor)
  *(Nota: Este sistema fue anunciado en la v2.3.0 y se ha pulido en la v2.3.1. Aún sigue en fase de pruebas y no está activo en el servidor).*

### _AstroIO Beta v2.2.5 — 28.10.2026_
**Versión actual de AstroIO**
- Implementación de La Cueva Pirata
- Implementación de nueva moneda UNTX-20
- Implementación de siseta de Descarga
- Implementación de Mini Torneos 
- Implementación del sistema Misison para Faciones 
- Correcion error misiles interplanetarios
- Correcion error misión asteroides
- Correcion error Base de la Flotas
- Correcion error contenedor

  • Se reajusta sitema dropeo de Contenedores

### _AstroIO Beta v2.2.4 — 18.10.2026_
**Versión actual de AstroIO**
- Implementación del nuevo Interfas Movil
- Correcion error sistema de evento

  • Se reajusta el sistema de roatcion de misión
- Correcion error Base de la Flota

  • Se coriege los errores sigeintes botones (🚀 Reunir Flotas 📦 Reunir Recursos 🔄 Distribuir Recursos 🌌 Multi-Expediciones)
- Correcion error Mercado

  • Se soluciona el problema a crear un venta con MO
  
  • Se reajusta el Interfas de los Recurso Metal, Crsiatal, Dulterio y Materia Oscura MO.

### _AstroIO Beta v2.2.3 — 14.10.2026_
- Correcion sisteama Colas

  • Se corrige que las colas de las Defensa son difernets al Hangar
- Correcion de la Informacion del sitema VIP 
- Correcion error siseta de vuelo 
- Correcion sistema Comercisnte 

  • Se reajusta los precios del intercambio de Recurso
- Implementación del nuevo Interfas sisetma de Mensaje
- Correcion Sistema Reportes de bug

  • Se soluciona el problema que provocaba que los reportes enviados llegaran como mensajes del jugador en lugar de aparecer correctamente como mensajes de sistema.
- Correcion sistema alianza

  • Los jugadores que se encuentren en la misma alianza no se peuden realizar atakes entre si

  ### _AstroIO Beta v2.2.2 — 13.10.2026_
- Correcion sisteama Planetario

  • Creacion de luna 
- Correcion Sistema de Mercado

  • Renovacion del sitema de venta
- Correcion Sistema de Pase de Batalla

  • Entrega de recompensas
- Correcion Sistema de Misiones

  • Sisteama de Ataque
  
  • Sisteama de Tiempo de Vuelo
  
### _AstroIO Beta v2.2.1 — 9.10.2026_
- Correcion Potenciadores 
- Correcion de error en los oficiales
- Implementación del Boost Fin de Semana 
- Correcion de error Sitema de Baneo
- Correcion de error Interfas Prinicpla 
  
  • Cambio de Nombre de Planeta
- Correcion de error Oficiles 
  
  • Sitema Tienda de Bonus
- Correcion de los precios del sistema Planetario
 
### _AstroIO Beta v2.2.0 — 8.10.2026_
- Correcion error Sistema PVP
- Correcion error Sistema Banco
- Se reajusata el Interfas del Juego
  
  • Interfas de Edificios 
  
  • Interfas de Defenzas 
  
  • Interfas de Investigaciones 
- Implementación del Sitema Planetario 
- Renovacion del Sistema Banco
- Se renoava los premios
  
  • Se renoava los premios Sistema Tareas ya no dan NTX-20 si no Materias Oscura 
  
  • Se renoava los premios Sistema PVE ya no dan NTX-20 si no Materias Oscura
  
  • Se renoava los premios Sistema PVE ya no dan NTX-20 si no Materias Oscura
- Se cambia el sistema de pago Materia Oscura - Tienda
- Implementación del Torneo del Devorador Estelar
- Renovacion del Sistema VIP

  • Se reajusata la cantidad VIP a 3 tipos 
  
  • Se reajusata el precios de los VIP
- Renovacion del sietema de recompenas PVE 
  
  • Se Implementan nuevos logros al sisteama PVE  
  
### _AstroIO Beta v2.1.105 — 5.10.2026_
- Correcion error creacion nueva alaianza 
- Correcion error MOP de Repores de Bugs
- Correcion error Mop de Rifas 
- Correcion error Gaalxia
- Correcion error Sietma Puttuacion
- Correcion error Interfas Movil
- Implementación del Sitema PVP 
- Implementación del Sitema Rotacion de Eventos 

### _AstroIO Beta v2.1.97 — 1.10.2026_
- Implementación del Sitema PVE

### _AstroIO Beta v2.1.80 — 28.09.2026_
- Nuevo módulo que permite a los miembros de una alianza depositar recursos en un **pozo común** y al líder (o tesorero designado) retirarlos para lo que la alianza necesite:
  
  • 💰 **Depositar Recursos:** Cualquier miembro puede aportar Metal, Cristal, Deuterio, MO o NTX-20 al banco de la alianza sin límite diario.
  
  • ⬆️ **Retirar Recursos:** Solo el líder y el tesorero designado pueden retirar fondos, con límite diario global configurable por el líder.
  
  • 📈 **Ampliar Banco:** Sube el nivel del banco (0 a 25) pagando NTX-20, ya sea del propio banco o de la cuenta personal del líder. Aumenta la capacidad por recurso.
  
  • ✨ **Bonuses Activos:** Cada 2 niveles se desbloquea un hito de bonus que el líder asigna libremente entre 📦 Producción, ⚔️ Ataque, 🛡️ Defensa o 🚀 Velocidad. Se aplican a **todos los miembros** de la alianza automáticamente.
  
  • 👤 **Tesorero Designado:** El líder puede nombrar un único tesorero con permiso de retiro, sin necesidad de tocar el sistema de rangos de 2Moons.
  
  • 📜 **Historial Completo:** Registro de todas las transacciones (depósitos, retiros, ampliaciones, cambios de bonus y tesorero) visible para todos los miembros.

- Implementación de 4 naves nuevas de élite
Se añaden 4 naves de alto nivel que amplían la progresión del juego
entre el Acorazado y el Avatar:

  • 🚀 Titán Estelar (221)
  
  • ⚔️ Coloso de Guerra (222)
  
  • 🛡️ Acorazado de Élite (223)
  
  • 🛡️ Fragata Pesada (224)

- Implementación de 4 defensas nuevas
Se añaden 4 sistemas defensivos que equilibran el combate planetario:

  • 🎯 Torreta de Riel (412)
  
  • ☢️ Cañón de Antimateria (413)
  
  • 🏰 Bastión Estelar (414)
  
  • 🛡️ Escudo Deflector (415)

  Nota: Por el momento estas naves y defensas solo están disponibles
  para el sistema de ataques normales. No se pueden vender en el Mercado
  Negro ni usar en otras funciones.

- Implementación de 2 misiles nuevos
Se añaden 2 sistemas de misiles que aumentan la estrategia del combate
planetario entre ataque y defensa:

  • ☢️ **Misil Antimateria (504)** — Ofensivo de élite
    Destruye 3 sistemas de defensa enemigos por unidad. Costo 40.000 M + 30.000 C + 20.000 D.
    Requisitos: Silo 8, Hangar 6, Motor Impulso 5, Propulsor Hiperespacial 3, Militar 12, Blindaje 10.
  
  • 🛡️ **Interceptor Avanzado (505)** — Defensivo de élite
    Destruye 3 misiles interplanetarios enemigos por unidad. Costo 20.000 M + 10.000 C + 8.000 D.
    Requisitos: Silo 6, Hangar 5, Blindaje 12, Militar 10, Iónica 5.

  Nota: Aumentan la estrategia al introducir la decisión "cantidad vs calidad"
  tanto en ataque como en defensa.

- Correcion de error Panel Admin (sistema de modulo activo y desactivar)
- Correcion de error en isModuleAvailable() — ahora respeta módulos desactivados sin excepción admin
- Redirección a Overview en game.php cuando un módulo está inactivo (en vez de página de error)
- Ampliación del sistema MOP: de 55 módulos a 63 módulos registrados
- Añadidos 8 módulos nuevos al panel admin: Razas, Facciones, Contenedores, Tareas, Guerra WAR, Banco de Alianza, FleetTools, Comerciante

### _AstroIO Beta v2.1.70 — 25.09.2026_
- Implemenatcion del sistema tares y logros (todo en mismo susmenus)
- Implementación de FleetTools (Herramientas de Flota)
   Nuevo módulo centralizado con 4 herramientas de flota en un solo
  lugar, accesible desde la tabla de flotas:

  • 🚀 Reunir Flotas: Envía todas las naves de tus otros planetas
    al planeta donde estás ubicado.
  
  • 📦 Reunir Recursos: Trae los recursos de tus otros planetas al
    planeta destino que elijas.
  
  • 🔄 Distribuir Recursos: Envía recursos desde el planeta actual
    hacia otros planetas, con misión de Transportar o Desplegar.
  
  • 🌌 Multi-Expediciones: Envía múltiples flotas a expedición con
    un solo clic. Requiere VIP activo.
  
  Todas las herramientas incluyen cálculo de tiempo, consumo de
  deuterio y alertas visuales en tiempo real.
- Correcion de error tabla de Puntuacion
- 🔔 Sistema de Alerta de Ataques Entrantes
- Reporte de Batalla Restilizado.
- Implemenatcion del sistema login por Discord.

### _AstroIO Beta v2.1.40 — 20.09.2026_
- Implemenatcion del sistema Rifas
- Implemenatcion del sistema Loteria 
- Correcion error sistema Reprotes de Bog (los auto mesnjes llegaban al Informacion de Espionaje y deveria ser Mensajes del Sistema)

### _AstroIO Beta v2.1.20 — 17.09.2026_
- Implemenatcion del sistema VIP
- Implemenatcion del sistema Mercado Negro 
- Implemenatcion del sistema Banco
- Implemenatcion del sistema Referido
- Correcion error sistema Expediciones
- Correcion error Rediseño sistema de Mensaje

### _AstroIO Beta v2.1 — 15.09.2026_
[Nuevo — Estilo visual AstroIO] :
- Rediseño completo del proyecto con estilo moderno
- Paleta: fondo azul noche (#0f1624 → #1a2332) con acento cyan (#00e0ff)
- Menú lateral rediseñado con pestañas MC1 y MOP
- Barra superior rediseñada con badge de versión y selector de planeta
- Overview con contenedor de planeta, cajas de construcción/investigación/flota
- Scrollbars personalizadas y animaciones suaves
- Bordes redondeados, gradientes y glow en todos los módulos

[Nuevo — Sistema de Eventos] :
- 14 eventos en total: 8 diarios + 4 semanales + 2 élites
- 6 tipos de misiones: Cazador, Reciclador, Explorador, Magnate, Almirante, Científico
- Recompensas: metal, cristal, deuterio y contenedores
- Reset automático: Diarios cada 24h · Semanales cada 5 días · Élite cada 17 días
- Widget de eventos en el overview con barra de progreso en tiempo real
- Página completa en game.php?page=events con todos los eventos
- Historial de recompensas reclamadas por jugador
- Sistema de bonos y recompensas escalables

[Nuevo — Panel de Administración de Eventos] :
- Crear, editar y borrar eventos desde el panel admin
- Activar / desactivar eventos con 1 solo clic
- Resetear el progreso de todos los jugadores en 1 evento
- Estadísticas: cuántos jugadores han iniciado / reclamado cada evento
- Selector de tipo de evento, clase y recompensa

[Hooks Activos — Progreso automático] :
- Destruir unidades en combate → MissionCaseAttack
- Reciclar escombros → MissionCaseRecycling
- Expediciones → MissionCaseExpedition
- Construir naves → class.PlanetRessUpdate
- Investigar tecnologías → class.PlanetRessUpdate
- Conseguir recursos (producción) → class.PlanetRessUpdate

[Nuevo — Sistema de Potenciadores] :
- 5 tipos de potenciadores activos: Expedición, MO, Producción, Espionaje, Energía
- Boosters visibles en el overview con estado activo/inactivo
- Indicador de tiempo restante en tiempo real
- Panel admin para dar potenciadores a jugadores o a todos
- Bonos aplicados a producción, energía, expediciones y espionaje
- Iconos y colores personalizados por tipo

[Nuevo — Sistema de Razas y Facciones] :
- Sistema de razas con bonos únicos por raza
- Sistema de facciones con bonos adicionales
- Bonos aplicados a: recursos, energía, almacenamiento, expediciones, espionaje
- Página de selección de raza (game.php?page=race)
- Página de selección de facción (game.php?page=faction)
- Primera elección gratis, cambios con coste en MO

[Nuevo — Sistema de Contenedores] :
- Drop aleatorio en expediciones (25% de probabilidad)
- 1 a 5 contenedores por drop
- Contenedores como recurso acumulable por jugador
- Visible en la barra superior con icono y contador
- Uso futuro para abrir cajas de recompensas

[Nuevo — Recurso NTX-20] :
- Nuevo recurso premium del servidor
- Visible en la barra superior con icono propio
- Recompensa de eventos élite y semanales
- Sistema preparado para futuras funcionalidades premium

[Fixes técnicos] :
- Compatibilidad total con PHP 8.2
- Fix de Session.class.php para evitar acceso a arrays nulos
- Sistema de eventos con 3 tablas optimizadas y UNIQUE KEY
- Protección contra inyección SQL en todas las consultas nuevas
- Separación correcta de prefijos de tabla por universo

[Módulos integrados] :
- Potenciadores — Boosters activos en el overview
- Razas y Facciones — Bonos aplicados a producción, energía, expediciones
- Contenedores — Drop aleatorio en expediciones
- Eventos — Sistema completo de misiones con progreso automático
- NTX-20 — Recurso premium integrado en la barra superior

[Créditos] :
- Proyecto original: 2Moons 2.0.git por Jan-Otto Kröpke
- Diseño y desarrollo AstroIO: Equipo AstroIO 2026
- Sistemas nuevos: Eventos, Potenciadores, Razas/Facciones, Contenedores, NTX-20
- © Copyright AstroIO 2026

---

### _v2.0.1	Danter14 14.08.2018_
[Modules] :
- none

[Bugs] :
- none

[Improvements] :
- none

[Optimization] :
- none

[Design] :
- none

[Panel administration] :
- none

### _v2.0.0	Danter14 17.02.2018_
[Modules] :
- Percentage with bar and text for real-time resources
- Number of players connect
- Planet change with arrows

[Bugs] :
- Fix of the language buddyList
- Fix bug for debris fields on the moon that replace the fields already in place by byazrail
- Fix bug, with destroyed moon by Kaizoku

[Improvements] :
- Ability to make high speed server

[Optimization] :
- Switching to php version 7.2

[Design] :
- Redesign of the bootstrap 4 login page
- Redesign Ingame by Danter14

[Panel administration] :
- none