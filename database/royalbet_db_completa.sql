-- ============================================================================
-- RoyalBET — BASE DE DATOS NUEVA COMPLETA (poker_db)
-- ============================================================================
-- Moneda del sistema: NTX-20
-- Compatible con MariaDB 10.4+ / MySQL 8 (probado con MariaDB 10.11)
--
-- IMPORTAR (consola):   mysql -u root -p < royalbet_db_completa.sql
-- IMPORTAR (phpMyAdmin): Importar → elegir este archivo → Ejecutar
--
-- INCLUYE:
--   ✔ Todas las tablas del sistema actual (usuarios, billetera, clubes,
--     mesas, torneos, seguridad, depósitos/retiros, transferencias...)
--   ✔ Tablas NUEVAS del flujo de fondos:
--       rake_ledger               → cada reparto de porcentajes (auditable)
--       fund_movements            → recogidas del Fondo del Proyecto
--       poker_buys                → buy-ins reales (reembolsos seguros)
--       tournament_registrations  → inscripciones de torneos pagadas
--   ✔ Configuración inicial de porcentajes en wallet_settings:
--       rake_percent = 5          (rake del bote en mesas cash)
--       referral_rake_share = 25  (% del rake para el sistema de referidos)
--       tournament_commission = 10 (% de comisión de la entrada de torneos)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS poker_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE poker_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- USUARIOS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id INT(11) NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) DEFAULT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  discord_id VARCHAR(100) DEFAULT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'player',
  status VARCHAR(20) DEFAULT 'active',
  last_login TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  avatar_url VARCHAR(255) DEFAULT NULL,
  referred_by INT(11) DEFAULT NULL,
  pay_pin VARCHAR(255) DEFAULT NULL,
  pay_pin_enabled TINYINT(1) DEFAULT 0,
  is_blocked TINYINT(1) DEFAULT 0,
  unique_id VARCHAR(10) DEFAULT NULL,
  pin_changed_at DATETIME DEFAULT NULL,
  email_changed_at DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY username (username),
  UNIQUE KEY email (email),
  UNIQUE KEY phone (phone),
  UNIQUE KEY discord_id (discord_id),
  UNIQUE KEY unique_id (unique_id),
  KEY fk_referrer (referred_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wallets (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  balance_ntx DECIMAL(18,2) DEFAULT 0,
  balance_locked DECIMAL(18,2) DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (id),
  KEY user_id (user_id),
  CONSTRAINT wallets_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- RESERVAS / FONDOS
-- ----------------------------------------------------------------------------
-- Reserva bancaria central = FONDO DEL PROYECTO
-- (aquí llega el porcentaje del rake y de las comisiones de torneos;
--  el superadmin lo recoge desde el panel con "Liquidar fondo del proyecto")
CREATE TABLE IF NOT EXISTS bank_reserves (
  id INT(11) NOT NULL DEFAULT 1,
  balance_ntx DECIMAL(18,2) DEFAULT 0.00,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reservas por moneda (esquema histórico, se mantiene por compatibilidad)
CREATE TABLE IF NOT EXISTS reserves (
  id INT(11) NOT NULL AUTO_INCREMENT,
  currency VARCHAR(20) DEFAULT 'NTX20',
  balance_jugadores BIGINT(20) DEFAULT 0,
  balance_proyecto BIGINT(20) DEFAULT 0,
  balance_clubes BIGINT(20) DEFAULT 0,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ledger auditable del rake: CADA reparto de porcentajes queda registrado aquí
CREATE TABLE IF NOT EXISTS rake_ledger (
  id INT(11) NOT NULL AUTO_INCREMENT,
  source VARCHAR(20) NOT NULL DEFAULT 'cash',  -- cash | tournament
  table_id VARCHAR(80) DEFAULT NULL,
  hand_number INT(11) DEFAULT NULL,
  winner_user_id INT(11) DEFAULT NULL,
  rake_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
  referral_share DECIMAL(18,2) NOT NULL DEFAULT 0,
  project_share DECIMAL(18,2) NOT NULL DEFAULT 0,
  referrer_id INT(11) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_rl_source (source, created_at),
  KEY idx_rl_winner (winner_user_id),
  KEY idx_rl_referrer (referrer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Movimientos de fondos (recogidas del fondo del proyecto por el superadmin)
CREATE TABLE IF NOT EXISTS fund_movements (
  id INT(11) NOT NULL AUTO_INCREMENT,
  fund VARCHAR(20) NOT NULL DEFAULT 'project',  -- project | referrals
  type VARCHAR(10) NOT NULL DEFAULT 'in',       -- in | out
  amount DECIMAL(18,2) NOT NULL DEFAULT 0,
  description VARCHAR(255) DEFAULT NULL,
  admin_id INT(11) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_fm_fund (fund, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- SEGURIDAD / SESIONES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS active_sessions (
  user_id INT(11) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  created_at TIMESTAMP NULL DEFAULT current_timestamp(),
  expires_at TIMESTAMP NOT NULL,
  PRIMARY KEY (user_id),
  KEY idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Mesas activas por jugador (regla: máximo 2 mesas simultáneas)
CREATE TABLE IF NOT EXISTS active_player_tables (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  table_id VARCHAR(100) NOT NULL,
  socket_id VARCHAR(100) NOT NULL,
  server_type ENUM('practice','real','tournament') NOT NULL DEFAULT 'real',
  joined_at TIMESTAMP NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  UNIQUE KEY uniq_active_user_table (user_id, table_id),
  KEY idx_apt_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_trusted_ips (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  ip_address VARCHAR(45) NOT NULL,
  last_used_at TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY user_id (user_id),
  CONSTRAINT fk_trusted_ips_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS user_verification_codes (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  code VARCHAR(10) NOT NULL,
  ip_address VARCHAR(45) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY user_id (user_id),
  CONSTRAINT fk_verification_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS password_reset_codes (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  code VARCHAR(6) NOT NULL,
  expires_at DATETIME NOT NULL,
  used TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_user (user_id),
  KEY idx_code (code),
  CONSTRAINT password_reset_codes_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS withdraw_verification_codes (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  code VARCHAR(6) NOT NULL,
  amount_ntx DECIMAL(18,2) NOT NULL,
  card_number VARCHAR(50) NOT NULL,
  holder_name VARCHAR(100) NOT NULL,
  bank_name VARCHAR(50) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS transfer_verification_codes (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  code VARCHAR(6) NOT NULL,
  amount_ntx DECIMAL(15,2) NOT NULL,
  receiver_id INT(11) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_user (user_id),
  KEY idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- REFERIDOS (sistema que recoge su % del rake)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS referral_earnings (
  id INT(11) NOT NULL AUTO_INCREMENT,
  referrer_id INT(11) NOT NULL,
  referred_id INT(11) NOT NULL,
  amount DECIMAL(18,2) NOT NULL DEFAULT 0,
  status ENUM('pending','claimed') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY referrer_id (referrer_id, status),
  KEY referred_id (referred_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS referral_claims (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  amount DECIMAL(18,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- JUEGO: historial, buy-ins, inscripciones de torneos
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS game_history (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  table_id VARCHAR(80) DEFAULT NULL,
  amount_won DECIMAL(18,2) DEFAULT 0,
  played_at TIMESTAMP DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_gh_user (user_id, played_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Buy-ins reales de mesas cash (permite reembolsos seguros de sitDown fallido)
CREATE TABLE IF NOT EXISTS poker_buys (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  table_id VARCHAR(80) NOT NULL,
  amount DECIMAL(18,2) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'paid',  -- paid | refunded
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_pb_user (user_id, status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inscripciones de torneos pagadas (auditoría)
CREATE TABLE IF NOT EXISTS tournament_registrations (
  id INT(11) NOT NULL AUTO_INCREMENT,
  game_id VARCHAR(80) NOT NULL,
  user_id INT(11) NOT NULL,
  entry_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'paid',
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  UNIQUE KEY uk_tr_game_user (game_id, user_id),
  KEY idx_tr_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- WALLET: transferencias, depósitos, retiros, cuentas bancarias, admin
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transfers (
  id INT(11) NOT NULL AUTO_INCREMENT,
  sender_id INT(11) NOT NULL,
  receiver_id INT(11) NOT NULL,
  amount_ntx DECIMAL(15,2) NOT NULL,
  created_at TIMESTAMP NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_sender (sender_id),
  KEY idx_receiver (receiver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deposit_requests (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  amount_cup DECIMAL(10,2) NOT NULL,
  transaction_id VARCHAR(255) NOT NULL,
  status ENUM('pending','taken','approved','rejected') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  admin_id INT(11) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS withdraw_requests (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  amount_ntx DECIMAL(10,2) NOT NULL,
  card_number VARCHAR(50) NOT NULL,
  holder_name VARCHAR(100) NOT NULL,
  bank_name VARCHAR(100) NOT NULL,
  status ENUM('pending','taken','approved','rejected') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  admin_id INT(11) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bank_accounts (
  user_id INT(11) NOT NULL,
  card_number VARCHAR(50) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  holder_name VARCHAR(100) NOT NULL,
  bank_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS admin_balances (
  admin_id INT(11) NOT NULL,
  total_recibido DECIMAL(15,2) DEFAULT 0.00,
  total_retirado DECIMAL(15,2) DEFAULT 0.00,
  fondo DECIMAL(18,2) DEFAULT 0.00,
  updated_at TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (admin_id),
  CONSTRAINT admin_balances_ibfk_1 FOREIGN KEY (admin_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- NOTIFICACIONES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_notifications (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  title VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(30) DEFAULT 'info',
  is_read TINYINT(1) DEFAULT 0,
  metadata LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  created_at DATETIME DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_user (user_id),
  KEY idx_user_unread (user_id, is_read),
  CONSTRAINT user_notifications_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- CONFIGURACIÓN
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS smtp_config (
  id INT(11) NOT NULL DEFAULT 1,
  smtp_host VARCHAR(255) DEFAULT NULL,
  smtp_port INT(11) DEFAULT 587,
  smtp_user VARCHAR(255) DEFAULT NULL,
  smtp_pass VARCHAR(255) DEFAULT NULL,
  smtp_from_email VARCHAR(255) DEFAULT NULL,
  smtp_from_name VARCHAR(100) DEFAULT 'RoyalBET',
  smtp_secure TINYINT(1) DEFAULT 0,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS server_config (
  id INT(11) NOT NULL DEFAULT 1,
  discord_client_id VARCHAR(255) DEFAULT NULL,
  discord_client_secret VARCHAR(255) DEFAULT NULL,
  discord_redirect_uri VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wallet_settings (
  setting_key VARCHAR(50) NOT NULL,
  setting_value VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- CLUBES Y MESAS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clubs (
  id INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20) NOT NULL,
  owner_id INT(11) NOT NULL,
  max_players INT(11) DEFAULT 10,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  description TEXT DEFAULT NULL,
  avatar_url VARCHAR(255) DEFAULT '?',
  discord_client_id VARCHAR(255) DEFAULT NULL,
  discord_client_secret VARCHAR(255) DEFAULT NULL,
  discord_redirect_uri VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY code (code),
  KEY owner_id (owner_id),
  CONSTRAINT clubs_ibfk_1 FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS club_members (
  id INT(11) NOT NULL AUTO_INCREMENT,
  club_id INT(11) NOT NULL,
  user_id INT(11) NOT NULL,
  role ENUM('owner','player','member') DEFAULT 'player',
  joined_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  UNIQUE KEY unique_user_club (club_id, user_id),
  KEY club_id (club_id),
  KEY uk_club_user_user (user_id),
  CONSTRAINT club_members_ibfk_1 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE,
  CONSTRAINT club_members_ibfk_2 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS table_templates (
  id INT(11) NOT NULL AUTO_INCREMENT,
  club_id INT(11) NOT NULL,
  title VARCHAR(100) NOT NULL,
  type VARCHAR(20) NOT NULL,
  mode VARCHAR(20) NOT NULL,
  settings LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`settings`)),
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY club_id (club_id),
  CONSTRAINT table_templates_ibfk_1 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS active_tables (
  id INT(11) NOT NULL AUTO_INCREMENT,
  club_id INT(11) NOT NULL,
  title VARCHAR(100) NOT NULL,
  type VARCHAR(20) NOT NULL,
  mode VARCHAR(20) NOT NULL,
  settings LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`settings`)),
  status ENUM('OPEN','PLAYING','CLOSED') DEFAULT 'OPEN',
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY club_id (club_id),
  CONSTRAINT active_tables_ibfk_1 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- DATOS INICIALES
-- ============================================================================
INSERT IGNORE INTO bank_reserves (id, balance_ntx) VALUES (1, 0.00);
INSERT IGNORE INTO reserves (id, currency) VALUES (1, 'NTX20');
INSERT IGNORE INTO smtp_config (id) VALUES (1);
INSERT IGNORE INTO server_config (id) VALUES (1);

-- Porcentajes del flujo de fondos (editables desde el panel admin / BD)
INSERT IGNORE INTO wallet_settings (setting_key, setting_value) VALUES
  ('min_deposit_cup', '200'),
  ('min_withdraw_ntx', '100'),
  ('rake_percent', '5'),
  ('referral_rake_share', '25'),
  ('tournament_commission', '10'),
  ('bonus_limite_total', '0'),
  ('bonus_porcentaje', '0'),
  ('bonus_usado', '0'),
  ('retiros_activos', '1'),
  ('inversiones_activas', '1');

-- ============================================================================
-- (OPCIONAL) CREAR EL SUPERADMIN INICIAL
-- Descomenta y ajusta los valores antes de ejecutar:
--
-- INSERT INTO users (username, email, password_hash, role, unique_id)
-- VALUES ('TU_USUARIO', 'tu@correo.com', '$2b$10$REEMPLAZA_POR_UN_HASH_BCRYPT', 'superadmin', '100001');
-- INSERT INTO wallets (user_id, balance_ntx) VALUES (LAST_INSERT_ID(), 0);
--
-- Nota: el hash bcrypt debe generarlo la propia aplicación (registro normal)
-- o con una herramienta bcrypt. Lo más fácil: registrar la cuenta desde la
-- web y luego ejecutar:
--   UPDATE users SET role='superadmin' WHERE username='TU_USUARIO';
-- ============================================================================

-- ============================================================================
-- RESUMEN DEL FLUJO DE PORCENTAJES (referencia rápida)
-- ============================================================================
-- Mesa cash (bote de la mano):
--   rake = 5% del bote (rake_percent)
--     ├── 25% del rake → referral_earnings (pending) del padrino del ganador
--     │                  (el padrino lo RECUGE con /user/referral-earnings/claim)
--     └── 75% del rake → bank_reserves (FONDO DEL PROYECTO)
--                        (el superadmin lo RECUGE con /admin/bank/liquidate-rake)
-- Sin padrino: el 100% del rake va al Fondo del Proyecto.
--
-- Torneo (entrada):
--   comisión = 10% de la entrada (tournament_commission)
--     ├── 25% → referidos del inscrito   (se reparte al ARRANCAR el torneo)
--     └── 75% → Fondo del Proyecto
--   prize pool = 90% de las entradas (paga automático al terminar)
--
-- Todo queda registrado en rake_ledger y se puede verificar con:
--   GET /api/admin/funds   (panel admin)
-- ============================================================================
