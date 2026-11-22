-- ============================================================================
-- RoyalBET — MIGRACIÓN PARA TU BASE DE DATOS EN VIVO (poker_db)
-- ============================================================================
-- Esta migración NO borra NI modifica datos existentes.
-- Agrega las 4 tablas nuevas del flujo de fondos y los porcentajes
-- de configuración que faltan en tu poker_db actual.
--
-- IMPORTAR (consola):    mysql -u root -p poker_db < migracion_poker_db.sql
-- IMPORTAR (phpMyAdmin): seleccionar la BD poker_db → Importar → Ejecutar
--
-- Tablas nuevas:
--   rake_ledger               → registro auditable de cada reparto de %
--   fund_movements            → recogidas del Fondo del Proyecto
--   poker_buys                → buy-ins reales (reembolsos seguros)
--   tournament_registrations  → inscripciones de torneos pagadas
-- ============================================================================

USE poker_db;

-- ----------------------------------------------------------------------------
-- LEDGER AUDITABLE DEL RAKE
-- Cada vez que se reparte el porcentaje del rake o la comisión de un torneo,
-- queda una fila aquí: cuánto fue a referidos, cuánto al fondo y de quién.
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- MOVIMIENTOS DE FONDOS
-- Cada "Liquidar fondo del proyecto" del superadmin queda registrado aquí.
-- ----------------------------------------------------------------------------
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
-- COMPRAS DE FICHAS (buy-ins de mesas cash)
-- El reembolso por /poker/cash-out SOLO funciona contra un registro de aquí,
-- así que nadie puede acreditar dinero arbitrario a su billetera.
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- INSCRIPCIONES DE TORNEOS PAGADAS
-- ----------------------------------------------------------------------------
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
-- CONFIGURACIÓN DE PORCENTAJES (solo agrega las que falten)
--   rake_percent          = 5   → % del bote que se cobra de rake en mesas cash
--   referral_rake_share   = 25  → % del rake para el sistema de referidos
--   tournament_commission = 10  → % de comisión de la entrada de torneos
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO wallet_settings (setting_key, setting_value) VALUES
  ('rake_percent', '5'),
  ('referral_rake_share', '25'),
  ('tournament_commission', '10');

-- ----------------------------------------------------------------------------
-- (RECOMENDADO) Ampliar columnas para PIN con hash y fondos con decimales:
-- El sistema ya funciona sin esto, pero es lo correcto a futuro.
-- Descomenta SOLO si quieres aplicarlas ya:
--
-- ALTER TABLE users MODIFY pay_pin VARCHAR(255) DEFAULT NULL;
-- ALTER TABLE bank_reserves MODIFY balance_ntx DECIMAL(18,2) DEFAULT 0.00;
-- ALTER TABLE admin_balances MODIFY fondo DECIMAL(18,2) DEFAULT 0.00;
-- ============================================================================
