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
│   ├── middlewares/      # auth JWT, validators, rateLimiter, internalAuth 🔥
│   ├── init_db.sql       # 🔥 COMPLETO (28 tablas)
│   └── tests/            # test-engine.js + test-funds.js (reparto de fondos)
├── database/             # 🔥 SQL para producción
│   ├── royalbet_db_completa.sql   # BD nueva completa (importar en phpMyAdmin)
│   └── migracion_poker_db.sql     # migración segura para la BD en vivo
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
INTERNAL_API_TOKEN=<token-largo-aleatorio>   # 🔥 OBLIGATORIO en producción
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

## 💰 Flujo de porcentajes (Fondo del Proyecto + Referidos)

Los porcentajes se configuran en `wallet_settings` (editables desde la BD o panel):

| Clave | Default | Significado |
|-------|---------|-------------|
| `rake_percent` | 5 | % del bote que se cobra en mesas cash |
| `referral_rake_share` | 25 | % del rake que va al sistema de referidos |
| `tournament_commission` | 10 | % de comisión de la entrada de torneos |

**Mesa cash (cada mano):** rake = 5% del bote → 25% del rake va a
`referral_earnings` (pendiente para el padrino del ganador) y el 75% restante
al **Fondo del Proyecto** (`bank_reserves`). Sin padrino, el 100% va al fondo.

**Torneos:** al ARRANCAR el torneo se reparte la comisión (10% de cada entrada)
con el mismo criterio (25% referidos / 75% fondo). El prize pool es el 90%.

**Recogida de fondos (los dos lados pueden recoger):**
- **Referido:** `POST /api/user/referral-earnings/claim` → acredita el pendiente
  en la billetera (mínimo 5 NTX, cada 24h). Queda en `referral_claims`.
- **Superadmin:** `POST /api/admin/bank/liquidate-rake` → vacía el fondo y lo
  acredita en `admin_balances.fondo`. Queda en `fund_movements`.
- **Verificación:** `GET /api/admin/funds` → fondo actual, pendientes de
  referidos, totales por origen (cash/torneo) y últimos movimientos.

Todo el reparto queda registrado en `rake_ledger` (auditable fila por fila).

## 🔐 Seguridad implementada

- Endpoints internos de dinero (`/api/poker/internal/*`) protegidos con
  `X-Internal-Token` (misma `INTERNAL_API_TOKEN` en los dos procesos).
- `/api/poker/cash-out` público SOLO reembolsa buy-ins reales de `poker_buys`.
- pokerServer (:3001) exige JWT: la identidad SIEMPRE viene del token
  (antes un cliente podía sentarse como otro usuario y robar la silla).
- PIN de pago con hash bcrypt (migración automática de los PIN legacy).
- Rate limiting anti fuerza bruta en login/registro/códigos/recuperación.
- Chat: el nombre siempre sale de la sesión autenticada (anti-spoofing).
- Práctica y torneos sin rake por bote (la comisión del torneo va en la entrada).

## 🧪 Tests
```bash
cd backend && node tests/test-engine.js   # motor de poker y torneos
cd backend && node tests/test-funds.js    # reparto de fondos y rake
```
41 comprobaciones del motor: evaluador de manos, flujo de turnos 1v1, side pots,
MTT completo con eliminaciones y pago exacto del prize pool.
13 comprobaciones de fondos: reparto 25/75 exacto, flujo cash y torneos,
rake nulo en práctica/torneos.
