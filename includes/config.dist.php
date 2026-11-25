<?php
/**
 * ============================================================
 * CONFIGURACIÓN DE VIOLETERO (PHP + MySQL)
 * ============================================================
 * CÓMO INSTALAR EN TU VPS:
 *   1) Copia este archivo como "config.php" (mismo directorio).
 *   2) Pon los datos de tu base de datos MySQL.
 *   3) Abre la web en el navegador: se instala sola.
 * ============================================================
 */

// ---- Zona horaria (Cuba) ----
date_default_timezone_set('America/Havana');

// ---- Base de datos (MySQL en el VPS) ----
define('DB_DRIVER', 'mysql');      // 'mysql' (recomendado en VPS) o 'sqlite' (para pruebas rápidas)
define('DB_HOST', '127.0.0.1');    // Servidor de MySQL (normalmente 127.0.0.1 o localhost)
define('DB_PORT', '3306');         // Puerto de MySQL (por defecto 3306)
define('DB_NAME', 'violetero');    // Nombre de la base de datos (créala en tu panel)
define('DB_USER', 'violetero');    // Usuario de MySQL
define('DB_PASS', 'CAMBIA-ESTA-CONTRASENA'); // Contraseña de MySQL

// SQLite solo se usa si DB_DRIVER = 'sqlite' (archivo dentro de db/)
define('DB_SQLITE_PATH', __DIR__ . '/../db/violetero.sqlite');

// ---- Datos generales de la tienda ----
define('SITE_NAME', 'Violetero');
define('SITE_URL', (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' ? 'https' : 'http') . '://' . ($_SERVER['HTTP_HOST'] ?? 'localhost') . rtrim(dirname($_SERVER['SCRIPT_NAME'] ?? ''), '/\\'));
define('CURRENCY', 'CUP');

// ---- Suscripción de las mini tiendas ----
define('TRIAL_DAYS', 5);           // Días de prueba gratis al crear una mini tienda
define('SUBSCRIPTION_CUP', 200);   // Precio mensual de la suscripción en CUP
define('SUBSCRIPTION_DAYS', 30);   // Días que cubre cada pago de suscripción

// ---- Seguridad ----
define('MAX_LOGIN_ATTEMPTS', 5);   // Intentos fallidos antes de bloquear la cuenta
define('LOCK_MINUTES', 15);        // Minutos de bloqueo de la cuenta
define('RESET_CODE_MINUTES', 15);  // Vigencia del código para recuperar contraseña
define('DEMO_CODES', true);       // true = los códigos se muestran en pantalla cuando no hay correo configurado (modo demostración)

// ---- Subida de fotos ----
define('MAX_UPLOAD_MB', 5);        // Tamaño máximo por foto
define('ALLOWED_IMAGE_EXT', 'jpg,jpeg,png,webp,gif');

// Modo depuración: en producción déjalo en false
define('DEBUG', false);
