require('dotenv').config();
process.env.TZ = 'America/Havana';

const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const { PORT } = require('./config');

const app = express();
app.set('trust proxy', 1);
app.use(cors());
app.use(express.json());

// ©¤©¤©¤©¤©¤ Rutas HTTP ©¤©¤©¤©¤©¤
app.use('/api', require('./routes/auth'));
app.use('/api', require('./routes/user'));
app.use('/api', require('./routes/wallet'));
app.use('/api', require('./routes/admin'));
app.use('/api', require('./routes/clubs'));
app.use('/api', require('./routes/games'));

// ©¤©¤©¤©¤©¤ Servidor + Socket.IO ©¤©¤©¤©¤©¤
const server = http.createServer(app);
const io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] }
});

const { init } = require('./services/practice-table');
init(io);

require('./sockets/poker')(io);

server.listen(PORT, () => console.log(`Servidor RoyalBET en http://localhost:${PORT}`));