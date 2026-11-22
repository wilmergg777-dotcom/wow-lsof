// src/config.js
const host = window.location.hostname; 
const isLocal = host === 'localhost' || host === '127.0.0.1';

// 1. API URL
// En local usa el puerto 3000. En el VPS (dominio) usa ruta relativa vacía ("")
// para que Apache haga el proxy internamente y evite el error de Mixed Content.
export const API_URL = isLocal ? 'http://localhost:3000' : '';

// 2. WebSockets (Sockets)
// En local usa los puertos. En el VPS usa el origen actual (https://...)
// para que automáticamente use wss:// (WebSocket Seguro) a través de Apache.
export const SOCKET_PRACTICE_URL = isLocal ? 'http://localhost:3000' : window.location.origin;
export const SOCKET_REAL_URL = isLocal ? 'http://localhost:3001' : window.location.origin;