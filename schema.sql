-- ============================================================
-- VIOLETERO — Esquema de base de datos MySQL
-- ============================================================
-- Normalmente NO necesitas importar este archivo: al abrir la web
-- por primera vez, install.php crea todas las tablas automáticamente.
-- Este archivo es por si prefieres crear la base de datos a mano
-- (phpMyAdmin, Adminer o consola MySQL).
--
-- Pasos:
--   1) Crea la base de datos:  CREATE DATABASE violetero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
--   2) Selecciona:             USE violetero;
--   3) Importa este archivo.
--   4) Abre la web: install.php pondrá los datos de ejemplo.
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(160) NULL UNIQUE,
    phone VARCHAR(40) NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'customer',
    balance_cup INT NOT NULL DEFAULT 0,
    failed_attempts INT NOT NULL DEFAULT 0,
    locked_until DATETIME NULL,
    last_login DATETIME NULL,
    created_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_sessions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    token VARCHAR(128) NOT NULL,
    ip VARCHAR(45) NULL,
    user_agent VARCHAR(250) NULL,
    created_at DATETIME NOT NULL,
    last_seen DATETIME NULL,
    INDEX (user_id), INDEX (token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS password_resets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    code VARCHAR(10) NOT NULL,
    expires_at DATETIME NOT NULL,
    used TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    INDEX (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS stores (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    owner_id INT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    slug VARCHAR(140) NOT NULL,
    description TEXT NULL,
    photo VARCHAR(300) NULL,
    trial_until DATE NULL,
    subscription_until DATE NULL,
    created_at DATETIME NOT NULL,
    INDEX (owner_id), INDEX (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    slug VARCHAR(90) NOT NULL,
    emoji VARCHAR(10) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS products (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    store_id INT UNSIGNED NULL,
    category_id INT UNSIGNED NULL,
    title VARCHAR(160) NOT NULL,
    description TEXT NULL,
    price_cup INT NOT NULL,
    old_price_cup INT NULL,
    stock INT NOT NULL DEFAULT 0,
    photos TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    views INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    INDEX (store_id), INDEX (category_id), INDEX (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS cart_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    qty INT NOT NULL DEFAULT 1,
    UNIQUE KEY uq_cart (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS orders (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    buyer_id INT UNSIGNED NOT NULL,
    total_cup INT NOT NULL,
    payment_method VARCHAR(20) NOT NULL DEFAULT 'efectivo',
    transfer_id VARCHAR(80) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    address VARCHAR(240) NULL,
    phone VARCHAR(40) NULL,
    note VARCHAR(300) NULL,
    created_at DATETIME NOT NULL,
    INDEX (buyer_id), INDEX (status), INDEX (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NULL,
    store_id INT UNSIGNED NULL,
    title VARCHAR(160) NOT NULL,
    price_cup INT NOT NULL,
    qty INT NOT NULL DEFAULT 1,
    photo VARCHAR(300) NULL,
    INDEX (order_id), INDEX (store_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS topups (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    amount_cup INT NOT NULL,
    transfer_id VARCHAR(80) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    admin_note VARCHAR(300) NULL,
    created_at DATETIME NOT NULL,
    processed_at DATETIME NULL,
    INDEX (user_id), INDEX (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payment_settings (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bank_name VARCHAR(120) NULL,
    card_number VARCHAR(60) NULL,
    holder VARCHAR(120) NULL,
    phone VARCHAR(40) NULL,
    updated_by INT UNSIGNED NULL,
    updated_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS notifications (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    title VARCHAR(160) NOT NULL,
    body VARCHAR(600) NULL,
    link VARCHAR(240) NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    INDEX (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS security_log (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NULL,
    ip VARCHAR(45) NULL,
    event VARCHAR(60) NOT NULL,
    detail VARCHAR(500) NULL,
    created_at DATETIME NOT NULL,
    INDEX (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rate_limits (
    ip_action VARCHAR(100) PRIMARY KEY,
    count INT NOT NULL DEFAULT 0,
    window_start DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS settings (
    k VARCHAR(80) PRIMARY KEY,
    value VARCHAR(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
