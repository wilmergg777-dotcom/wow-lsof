require('dotenv').config();
process.env.TZ = 'America/Havana';

const express = require('express');
const cors = require('cors');
const http = require('http');
const helmet = require('helmet');
const { Server } = require('socket.io');

const { PORT } = require('./config');
const { globalLimiter } = require('./middlewares/rateLimiter');

const app = express();
app.set('trust proxy', 1);

const pool = require('./db');

// ═══════════ 1. Cabeceras de seguridad ═══════════
app.use(helmet({
  contentSecurityPolicy: false,                          // frontend en otro origen
  crossOriginResourcePolicy: { policy: 'cross-origin' }, // sirve assets cross-origin
}));

// ═══════════ 2. CORS restringido ═══════════
const allowedOrigins = [
  'http://localhost:5173',   // Vite dev
  'http://localhost:3000',   // por si usas otro puerto
  'https://royalbet.duckdns.org' // dominio
];

const corsOptions = {
  origin: (origin, callback) => {
    // Sin origin = curl, Postman, apps nativas. Si no quieres permitir, cambia a `false`.
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    return callback(new Error('Origen no permitido por CORS'));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};
app.use(cors(corsOptions));

// ═══════════ 3. Body parser con límite (mitiga DoS) ═══════════
app.use(express.json({ limit: '100kb' }));
app.use(express.urlencoded({ extended: true, limit: '100kb' }));

// ═══════════ 4. Rate limiting global ═══════════
app.use(globalLimiter);

// ═══════════ 5. Rutas HTTP (mantengo tu mount actual) ═══════════
app.use('/api', require('./routes/auth'));
app.use('/api', require('./routes/user'));
app.use('/api', require('./routes/wallet'));
app.use('/api', require('./routes/admin'));
app.use('/api', require('./routes/clubs'));
app.use('/api', require('./routes/games'));
app.use('/api', require('./routes/shop'));

// ═══════════ 6. Servidor + Socket.IO con CORS cerrado ═══════════
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

const { init } = require('./services/practice-table');
init(io);

// 🔥 MTT: inicializar el motor de torneos multimesa
require('./services/mtt-tournaments').init(io);

require('./sockets/poker')(io);

// Limpieza de sesiones expiradas cada hora
setInterval(async () => {
    try {
        const [result] = await pool.query('DELETE FROM active_sessions WHERE expires_at < NOW()');
        if (result.affectedRows > 0) {
            console.log(`[sessions] Limpiadas ${result.affectedRows} sesiones expiradas`);
        }
    } catch (err) {
        console.error('[sessions] Error en limpieza:', err.message);
    }
}, 60 * 60 * 1000);

server.listen(PORT, () => console.log(`Servidor RoyalBET en http://localhost:${PORT}`));