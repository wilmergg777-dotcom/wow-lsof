-- ============================================================
-- RoyalBet — Esquema COMPLETO de base de datos (MySQL)
-- Moneda del sistema: NTX-20 (balance_ntx)
-- Ejecutar: mysql -u root -p < init_db.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(30) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    unique_id VARCHAR(10) UNIQUE,
    referred_by INT,
    avatar_url VARCHAR(255) DEFAULT NULL,
    discord_id VARCHAR(50) DEFAULT NULL,
    is_blocked TINYINT(1) DEFAULT 0,
    pay_pin VARCHAR(255) DEFAULT NULL,
    pay_pin_enabled TINYINT(1) DEFAULT 0,
    pin_changed_at TIMESTAMP NULL,
    email_changed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_referred (referred_by),
    INDEX idx_users_discord (discord_id)
);

CREATE TABLE IF NOT EXISTS wallets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    balance_ntx DECIMAL(18,2) DEFAULT 0,
    balance_locked DECIMAL(18,2) DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Reserva bancaria central del proyecto
CREATE TABLE IF NOT EXISTS bank_reserves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    balance_ntx DECIMAL(18,2) DEFAULT 0
);
INSERT IGNORE INTO bank_reserves (id, balance_ntx) VALUES (1, 0);

-- Reservas por moneda (esquema original, se mantiene por compatibilidad)
CREATE TABLE IF NOT EXISTS reserves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    currency VARCHAR(20) DEFAULT 'NTX20',
    balance_jugadores BIGINT DEFAULT 0,
    balance_proyecto BIGINT DEFAULT 0,
    balance_clubes BIGINT DEFAULT 0
);
INSERT IGNORE INTO reserves (id, currency) VALUES (1, 'NTX20');

-- Sesiones activas (cerrar sesion desde otro dispositivo / limpieza horaria)
CREATE TABLE IF NOT EXISTS active_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token_hash VARCHAR(128) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sessions_user (user_id),
    INDEX idx_sessions_expires (expires_at)
);

-- Mesas activas por jugador (regla: max 2 mesas simultaneas)
CREATE TABLE IF NOT EXISTS active_player_tables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    table_id VARCHAR(80) NOT NULL,
    socket_id VARCHAR(80) NOT NULL,
    server_type VARCHAR(20) DEFAULT 'real',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_table (user_id, table_id),
    INDEX idx_apt_user (user_id)
);

-- IPs de confianza por usuario (verificacion por codigo al cambiar de IP)
CREATE TABLE IF NOT EXISTS user_trusted_ips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(64) NOT NULL,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_ip (user_id, ip_address)
);

-- Codigos de verificacion de login por IP nueva
CREATE TABLE IF NOT EXISTS user_verification_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    code VARCHAR(10) NOT NULL,
    ip_address VARCHAR(64),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_uvc_user (user_id)
);

-- Codigos de recuperacion de contrasena
CREATE TABLE IF NOT EXISTS password_reset_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    code VARCHAR(10) NOT NULL,
    used TINYINT(1) DEFAULT 0,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_prc_user (user_id)
);

-- Codigos de verificacion para retiros (con PIN/2FA de retiro)
CREATE TABLE IF NOT EXISTS withdraw_verification_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    code VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_wvc_user (user_id)
);

-- Codigos de verificacion para transferencias
CREATE TABLE IF NOT EXISTS transfer_verification_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    code VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tvc_user (user_id)
);

-- Historial de manos jugadas (centro de actividades)
CREATE TABLE IF NOT EXISTS game_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    table_id VARCHAR(80),
    amount_won DECIMAL(18,2) DEFAULT 0,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_gh_user (user_id, played_at)
);

-- Referidos: ganancias por rake 25/75
CREATE TABLE IF NOT EXISTS referral_earnings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    referrer_id INT NOT NULL,
    referred_id INT NOT NULL,
    amount DECIMAL(18,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_re_referrer (referrer_id, status)
);

-- Reclamos de ganancias de referidos
CREATE TABLE IF NOT EXISTS referral_claims (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(18,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rc_user (user_id)
);

-- Transferencias entre usuarios
CREATE TABLE IF NOT EXISTS transfers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    amount_ntx DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'approved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tr_sender (sender_id),
    INDEX idx_tr_receiver (receiver_id)
);

-- Solicitudes de deposito (CUP)
CREATE TABLE IF NOT EXISTS deposit_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount_cup DECIMAL(18,2) NOT NULL,
    transaction_id VARCHAR(120),
    status VARCHAR(20) DEFAULT 'pending',
    admin_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    INDEX idx_dr_user (user_id, status)
);

-- Solicitudes de retiro (NTX-20)
CREATE TABLE IF NOT EXISTS withdraw_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount_ntx DECIMAL(18,2) NOT NULL,
    card_number VARCHAR(40),
    holder_name VARCHAR(100),
    bank_name VARCHAR(100),
    phone VARCHAR(30),
    status VARCHAR(20) DEFAULT 'pending',
    admin_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    INDEX idx_wr_user (user_id, status)
);

-- Cuentas bancarias guardadas del usuario
CREATE TABLE IF NOT EXISTS bank_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    card_number VARCHAR(40) NOT NULL,
    phone VARCHAR(30),
    holder_name VARCHAR(100),
    bank_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ba_user (user_id)
);

-- Balances de administradores (billetera admin)
CREATE TABLE IF NOT EXISTS admin_balances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL UNIQUE,
    total_recibido DECIMAL(18,2) DEFAULT 0,
    total_retirado DECIMAL(18,2) DEFAULT 0,
    fondo DECIMAL(18,2) DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Notificaciones in-app (buzon)
CREATE TABLE IF NOT EXISTS user_notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150),
    message TEXT,
    type VARCHAR(30) DEFAULT 'info',
    metadata JSON,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_un_user (user_id, is_read)
);

-- Configuracion SMTP (panel admin)
CREATE TABLE IF NOT EXISTS smtp_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    smtp_host VARCHAR(150),
    smtp_port INT DEFAULT 587,
    smtp_user VARCHAR(150),
    smtp_pass VARCHAR(150),
    smtp_from_email VARCHAR(150),
    smtp_from_name VARCHAR(100) DEFAULT 'RoyalBet',
    smtp_secure TINYINT(1) DEFAULT 0
);
INSERT IGNORE INTO smtp_config (id) VALUES (1);

-- Configuracion del servidor (Discord OAuth, etc.)
CREATE TABLE IF NOT EXISTS server_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    discord_client_id VARCHAR(80),
    discord_client_secret VARCHAR(120),
    discord_redirect_uri VARCHAR(255)
);
INSERT IGNORE INTO server_config (id) VALUES (1);

-- Ajustes de billetera (min deposito, min retiro, etc.)
CREATE TABLE IF NOT EXISTS wallet_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(60) NOT NULL UNIQUE,
    setting_value VARCHAR(255)
);

-- Clubes
CREATE TABLE IF NOT EXISTS clubs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE,
    description TEXT,
    avatar_url VARCHAR(255),
    owner_id INT NOT NULL,
    max_players INT DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_clubs_owner (owner_id)
);

CREATE TABLE IF NOT EXISTS club_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    club_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(20) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_club_user (club_id, user_id)
);

-- Plantillas de mesas por club
CREATE TABLE IF NOT EXISTS table_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    club_id INT NOT NULL,
    title VARCHAR(100),
    type VARCHAR(40) DEFAULT 'NLHE',
    mode VARCHAR(40) DEFAULT 'cash',
    settings JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tt_club (club_id)
);

-- Mesas activas de club
CREATE TABLE IF NOT EXISTS active_tables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    club_id INT NOT NULL,
    title VARCHAR(100),
    type VARCHAR(40) DEFAULT 'NLHE',
    mode VARCHAR(40) DEFAULT 'cash',
    settings JSON,
    status VARCHAR(20) DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_at_club (club_id, status)
);

-- ============================================================
-- Datos iniciales
-- ============================================================
INSERT IGNORE INTO wallet_settings (setting_key, setting_value) VALUES
    ('min_deposit_cup', '200'),
    ('min_withdraw_ntx', '100'),
    ('rake_percent', '5'),
    ('referral_rake_share', '25');
