// backend/middlewares/rateLimiter.js
const rateLimit = require('express-rate-limit');

// Global: protege toda la API de scraping/DoS básico
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 300,                 // 300 req/IP/15min
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Demasiadas peticiones, intenta más tarde.' },
});

// Estricto para login/register: frena fuerza bruta
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,                  // 10 intentos/IP/15min
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // solo cuenta los fallos
  message: { error: 'Demasiados intentos de autenticación. Espera 15 minutos.' },
});

// Para endpoints sensibles de apuestas
const betLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Demasiadas apuestas en poco tiempo.' },
});

module.exports = { globalLimiter, authLimiter, betLimiter };