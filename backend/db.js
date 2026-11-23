const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    timezone: 'Z',              // ✅ CAMBIO: fuerza UTC en todas las conexiones (arregla el bug del código expirado)
    charset: 'utf8mb4',         // ✅ CAMBIO: asegura UTF-8 para tildes, eñes y emojis
    dateStrings: false,         // ✅ CAMBIO: devuelve objetos Date reales (no strings)
    supportBigNumbers: true,    // ✅ CAMBIO: soporta IDs grandes y DECIMAL sin perder precisión
    bigNumberStrings: false,    // ✅ CAMBIO: devuelve números nativos cuando es seguro
    namedPlaceholders: false    // ✅ CAMBIO: mantiene el uso de '?' en las queries
});

module.exports = pool;