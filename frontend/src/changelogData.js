export const changelogData = [
  {
    version: "RoyalBET Beta v0.0.2",
    date: "12.11.2026",
    changes: [
      { title: "🎨 Rediseño visual estilo MTT Sports: Mesa de 6 asientos rotativa (siempre juegas desde abajo)." },
      { title: "🖼️ Avatares generados automáticamente para cada jugador en la mesa." },
      { title: "🃏 Ajuste en el tamaño de las cartas para una mejor legibilidad." },
      { title: "💬 Chat en vivo funcional en la mesa (con auto-scroll) tanto para Práctica como para Dinero Real." },
      { title: "🚀 Botón de ALL-IN añadido a la barra de acciones." },
      { title: "💰 Lógica de Side Pots (Botes Paralelos): Si un jugador va All-In con menos fichas, solo puede ganar la parte proporcional que aportó, protegiendo el resto del bote." },
      { title: "⚖️ Reparto de bote exacto en caso de empate (Split Pot), sin perder fichas sobrantes." },
      { title: "🔄 Sistema de Recarga (Rebuy) sin salir de la mesa: Si te quedas sin fichas, puedes comprar más en el mismo asiento." },
      { title: "🛠️ Fix crítico: La mesa ya no se queda en 'Esperando nueva mano' después de que un jugador recarga sus fichas." },
      { title: "🔒 Seguridad y Red: Configuración de Proxy Inverso en Apache (HTTPS) y reconexión de WebSockets para evitar bloqueos de contenido mixto." }
    ]
  },
  {
    version: "RoyalBET Beta v0.0.1",
    date: "08.11.2026",
    changes: [
      { title: "🛡️ Despliegue inicial del frontend en el VPS con certificados SSL." },
      { title: "🚫 Corrección de la base de datos y variables de entorno (.env) para el backend." },
      { title: "🛠️ Implementación del motor de juego base y sistema de apuestas." },
      { title: "🎄 Primeros avatares y diseño preliminar de la mesa de póker." }
    ]
  },
  {
    version: "RoyalBET Beta v0.0.0",
    date: "28.10.2026",
    changes: [
      { title: "🚧 Inicio del desarrollo de la plataforma RoyalBET." }
    ]
  }
];