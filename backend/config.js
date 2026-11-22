// backend/config.js
require('dotenv').config();

if (!process.env.JWT_SECRET) {
  console.error('❌ FATAL: JWT_SECRET no está definido en el entorno.');
  process.exit(1);
}

module.exports = {
  JWT_SECRET: process.env.JWT_SECRET,
  FRONTEND_URL: process.env.FRONTEND_URL || 'http://localhost:5173',
  PORT: process.env.PORT || 3000,
};