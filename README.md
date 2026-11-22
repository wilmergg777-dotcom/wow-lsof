# 🃏 RoyalBet — Casino de Poker Online (NTX-20)

Proyecto corregido y ampliado. Moneda del sistema: **NTX-20** (columna `balance_ntx`).

## 📦 Estructura

```
RoyalBet/
├── backend/              # API Express (:3000) + Socket.IO (práctica y torneos MTT)
│   ├── server.js         # API principal + mesas de práctica + MTT
│   ├── pokerServer.js    # Servidor de mesas con dinero real (:3001)
│   ├── pokerGame.js      # Motor Texas Hold'em (turnos, side pots, ciegas, torneos)
│   ├── pokerEngine.js    # Evaluador de manos
│   ├── services/
│   │   ├── practice-table.js     # Sala de práctica (400 fichas gratis)
│   │   ├── futures.js            # Programador de torneos (4/día, 10:30-16:00)
│   │   └── mtt-tournaments.js    # 🔥 NUEVO: motor MTT multi-mesa + payout automático
│   ├── routes/           # auth, user, wallet, admin, clubs, games
│   ├── middlewares/      # auth JWT, validators, rateLimiter
│   ├── init_db.sql       # 🔥 COMPLETO (24 tablas)
│   └── tests/test-engine.js      # 🔥 NUEVO: tests funcionales del motor
└── frontend/             # React 19 + Vite (mobile-first)
    └── src/
        ├── App.jsx               # Navegación + 🔥 barra inferior móvil
        ├── PokerTable.jsx        # 🔥 Mesa rediseñada para móvil + torneos + sonidos
        ├── TournamentHub.jsx     # 🔥 NUEVO: lobby de torneos estilo MTT
        └── ...
```

## 🚀 Despliegue

### 1. Base de datos (MySQL/MariaDB)
```bash
mysql -u root -p < backend/init_db.sql
```
Crea las 24 tablas que usa el código (users, wallets, sesiones, IPs de confianza,
mesas activas, rake/referidos, notificaciones, etc.).

### 2. Backend
```bash
cd backend
cp .env.example .env   # si no existe, crea .env con las variables de abajo
npm install
npm start              # puerto 3000
npm run poker          # en otra terminal: mesas de dinero real (puerto 3001)
```

Variables de entorno (.env):
```
JWT_SECRET=<secreto-largo>
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=<clave>
DB_NAME=royalbet
PORT=3000
FRONTEND_URL=https://tudominio.com
BACKEND_URL=http://localhost:3000
```

### 3. Frontend
```bash
cd frontend
npm install
npm run dev      # desarrollo (:5173)
npm run build    # producción → dist/
```

## ✅ Qué se corrigió en esta versión

**Bugs críticos (el proyecto NO arrancaba):**
1. `helmet`, `express-rate-limit` y `express-validator` se usaban pero NO estaban en
   package.json → añadidos.
2. `init_db.sql` solo creaba 3 tablas y el código usa 24 → esquema completo.
3. Saltos de línea CRLF normalizados a LF.

**Motor de poker y torneos:**
4. Motor MTT completo: los torneos Futures ahora CREAN MESAS REALES al llegar la hora,
   sientan a los inscritos con 3000 fichas, suben ciegas +25% cada 10 min y PAGAN
   premios automáticos (1º 55% · 2º 30% · 3º 15% del prize pool en NTX-20).
5. Los torneos ya no se reembolsan "sin motor" si siguen en juego.
6. SocketIds sintéticos únicos para jugadores sin conectar (evita turnos perdidos).
7. Guard: no se puede iniciar una mano sobre otra en curso.
8. Auto-inicio desactivado durante el seeding de mesas MTT.

**Frontend móvil (prioridad principal):**
9. Mesa de poker rediseñada mobile-first: mesa fluida (sin `transform: scale(0.55)`),
   botones táctiles grandes (Pasar / Igualar / Subir), chat como cajón lateral,
   cartas propias siempre visibles sobre el panel de acciones, safe-area iPhone.
10. Barra de navegación inferior estilo app nativa (Inicio · Torneos · Mesas · Mail · Perfil).
11. Nueva página **Torneos** estilo MTT: filtros, cards con countdown/Late Reg,
    prize pool, registro funcional y entrada directa a la mesa.

**Sonidos (WebAudio, sin archivos):**
12. Al llegar tu turno, aviso en los últimos 5s, al pasar (fold), igualar, all-in,
    subida de ciegas, victoria y derrota (antes sonaba lo mismo al ganar que al perder).

## 🧪 Tests
```bash
cd backend && node tests/test-engine.js
```
41 comprobaciones: evaluador de manos, flujo de turnos 1v1, side pots,
MTT completo con eliminaciones y pago exacto del prize pool.
