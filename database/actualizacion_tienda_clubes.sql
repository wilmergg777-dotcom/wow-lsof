-- ============================================================================
-- RoyalBET — ACTUALIZACIÓN: TIENDA (emojis + estilos de cartas) y CLUBES completos
-- ============================================================================
-- Moneda del sistema: NTX-20  |  Moneda de club: Fichas de Club (1 NTX-20 = 1 ficha)
--
-- IMPORTAR (consola):    mysql -u root -p poker_db < actualizacion_tienda_clubes.sql
-- IMPORTAR (phpMyAdmin): elegir la base poker_db → Importar → este archivo → Ejecutar
--
-- INCLUYE:
--   TIENDA
--     shop_items        → catálogo (emojis 1-4 NTX-20, estilos de cartas 1-3 NTX-20)
--     user_items        → inventario de compras por usuario
--     user_preferences  → estilo de cartas equipado por usuario
--   CLUBES
--     clubs.tier / clubs.chip_balance          → niveles 0-3 y fichas del club
--     club_members.club_chips + rol moderator  → fichas personales y moderador
--     club_chip_tx                             → ledger de fichas del club (auditable)
--     club_tier_payments                       → pagos de niveles (70 / 100 / 300 NTX-20)
--     club_tournaments                         → torneos del club (miembros o públicos)
--   FONDOS
--     rake_ledger.club_id                      → rake de mesas de club (3% fondo / 97% dueño)
--   SEMILLA del catálogo de la tienda (12 emojis + 6 estilos de cartas)
--
-- NIVELES DE CLUB (tiers):
--   0  Gratis    → máx 10 jugadores,  torneos SOLO para miembros
--   1  70 NTX-20 → máx 50 jugadores,  torneos SOLO para miembros
--   2  100 NTX-20 → máx 100 jugadores, 1 torneo activo VISIBLE en el lobby del casino
--   3  300 NTX-20 → máx 250 jugadores, 3 torneos activos VISIBLES en el lobby del casino
-- ============================================================================

USE poker_db;

-- ----------------------------------------------------------------------------
-- TIENDA: catálogo
-- item_type: 'emote' (emoji para usar en las mesas) | 'card_style' (visual de las cartas)
-- value: el emoji (para emotes) o la clave CSS del estilo (para card_style)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS shop_items (
  id INT(11) NOT NULL AUTO_INCREMENT,
  item_type ENUM('emote','card_style') NOT NULL,
  name VARCHAR(60) NOT NULL,
  value VARCHAR(40) NOT NULL,
  price_ntx DECIMAL(6,2) NOT NULL DEFAULT 0,
  sort_order INT(11) NOT NULL DEFAULT 0,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  UNIQUE KEY uk_shop_type_value (item_type, value),
  KEY idx_shop_type (item_type, active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- TIENDA: inventario del jugador (compras únicas — no se puede comprar dos veces)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_items (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  item_id INT(11) NOT NULL,
  acquired_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_item (user_id, item_id),
  KEY idx_ui_user (user_id),
  CONSTRAINT fk_ui_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_ui_item FOREIGN KEY (item_id) REFERENCES shop_items (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- TIENDA: preferencias del jugador (estilo de cartas equipado)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_preferences (
  user_id INT(11) NOT NULL,
  equipped_card_style INT(11) DEFAULT NULL,   -- NULL = Clásico (gratis)
  updated_at TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (user_id),
  CONSTRAINT fk_up_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_up_item FOREIGN KEY (equipped_card_style) REFERENCES shop_items (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- CLUBES: niveles (tier) y fichas del club
-- ----------------------------------------------------------------------------
ALTER TABLE clubs
  ADD COLUMN IF NOT EXISTS tier TINYINT(4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS chip_balance DECIMAL(18,2) NOT NULL DEFAULT 0;

-- club_members: nuevo rol 'moderator' + fichas personales del socio
ALTER TABLE club_members
  MODIFY COLUMN role ENUM('owner','moderator','player','member') DEFAULT 'player',
  ADD COLUMN IF NOT EXISTS club_chips DECIMAL(18,2) NOT NULL DEFAULT 0;

-- ----------------------------------------------------------------------------
-- CLUBES: ledger auditable de fichas del club
-- type: purchase (dueño compra 1:1) | grant (dueño/mod reparte a socio)
--       deposit (socio invierte al club) | rake_owner (97% del rake para el club)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS club_chip_tx (
  id INT(11) NOT NULL AUTO_INCREMENT,
  club_id INT(11) NOT NULL,
  actor_id INT(11) NOT NULL,                 -- quien ejecuta la operación
  target_user_id INT(11) DEFAULT NULL,       -- socio que recibe/entrega (si aplica)
  type ENUM('purchase','grant','deposit','rake_owner') NOT NULL,
  amount DECIMAL(18,2) NOT NULL DEFAULT 0,
  club_balance_after DECIMAL(18,2) NOT NULL DEFAULT 0,
  member_balance_after DECIMAL(18,2) DEFAULT NULL,
  note VARCHAR(160) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_cct_club (club_id, created_at),
  KEY idx_cct_target (target_user_id),
  CONSTRAINT fk_cct_club FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- CLUBES: pagos de niveles (auditoría de 70 / 100 / 300 NTX-20)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS club_tier_payments (
  id INT(11) NOT NULL AUTO_INCREMENT,
  club_id INT(11) NOT NULL,
  tier TINYINT(4) NOT NULL,
  amount_ntx DECIMAL(18,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_ctp_club (club_id, created_at),
  CONSTRAINT fk_ctp_club FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- CLUBES: torneos del club
-- visibility: 'members' (solo socios) | 'public' (lobby del casino, tier 2-3)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS club_tournaments (
  id INT(11) NOT NULL AUTO_INCREMENT,
  club_id INT(11) NOT NULL,
  name VARCHAR(100) NOT NULL,
  type VARCHAR(20) NOT NULL DEFAULT 'MTT',
  mode VARCHAR(20) NOT NULL DEFAULT 'NLH',
  settings LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`settings`)),
  visibility ENUM('members','public') NOT NULL DEFAULT 'members',
  status ENUM('open','running','finished','cancelled') NOT NULL DEFAULT 'open',
  created_by INT(11) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  KEY idx_ct_club (club_id, status),
  KEY idx_ct_public (visibility, status),
  CONSTRAINT fk_ct_club FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- FONDOS: rake_ledger gana club_id para el reparto de mesas de club
-- (3% al Fondo del Proyecto / 97% al dueño del club)
-- ----------------------------------------------------------------------------
ALTER TABLE rake_ledger
  ADD COLUMN IF NOT EXISTS club_id INT(11) DEFAULT NULL AFTER source,
  ADD KEY IF NOT EXISTS idx_rl_club (club_id);

-- ============================================================================
-- SEMILLA: catálogo de la Tienda
-- Emojis: precios de 1 a 4 NTX-20   |   Estilos de cartas: precios de 1 a 3 NTX-20
-- ============================================================================
INSERT INTO shop_items (item_type, name, value, price_ntx, sort_order)
SELECT * FROM (SELECT 'emote' AS item_type, 'Risa' AS name, '😂' AS value, 1.00 AS price_ntx, 1 AS sort_order UNION ALL
               SELECT 'emote', 'Fuego', '🔥', 1.00, 2 UNION ALL
               SELECT 'emote', 'Me gusta', '👍', 1.00, 3 UNION ALL
               SELECT 'emote', 'Sorpresa', '😮', 1.00, 4 UNION ALL
               SELECT 'emote', 'Corazón', '❤️', 2.00, 5 UNION ALL
               SELECT 'emote', 'Llanto', '😢', 2.00, 6 UNION ALL
               SELECT 'emote', 'Fiesta', '🎉', 2.00, 7 UNION ALL
               SELECT 'emote', 'Calavera', '💀', 2.00, 8 UNION ALL
               SELECT 'emote', 'Payaso', '🤡', 3.00, 9 UNION ALL
               SELECT 'emote', 'Trébol', '🍀', 3.00, 10 UNION ALL
               SELECT 'emote', 'Diamante', '💎', 4.00, 11 UNION ALL
               SELECT 'emote', 'Corona', '👑', 4.00, 12) AS e
WHERE NOT EXISTS (SELECT 1 FROM shop_items WHERE item_type = 'emote');

INSERT INTO shop_items (item_type, name, value, price_ntx, sort_order)
SELECT * FROM (SELECT 'card_style' AS item_type, 'Clásico' AS name, 'clasico' AS value, 0.00 AS price_ntx, 1 AS sort_order UNION ALL
               SELECT 'card_style', 'Neón', 'neon', 1.00, 2 UNION ALL
               SELECT 'card_style', 'Vintage', 'vintage', 1.00, 3 UNION ALL
               SELECT 'card_style', 'Esmeralda', 'esmeralda', 2.00, 4 UNION ALL
               SELECT 'card_style', 'Dorado', 'dorado', 3.00, 5 UNION ALL
               SELECT 'card_style', 'Real Púrpura', 'royal', 3.00, 6) AS c
WHERE NOT EXISTS (SELECT 1 FROM shop_items WHERE item_type = 'card_style');

-- ============================================================================
-- RESUMEN DEL FLUJO DE FONDOS (referencia rápida)
-- ============================================================================
-- Mesas casuales (rake = 5% del bote, configurable en wallet_settings):
--   ├── 25% del rake → referral_earnings del padrino del ganador (los Socios lo
--   │                  RECOGEN con /user/referral-earnings/claim → a su billetera)
--   └── 75% del rake → bank_reserves (FONDO DEL PROYECTO; el superadmin lo recoge
--                      con /admin/bank/liquidate-rake)
--
-- Mesas de CLUB (rake = 5% del bote):
--   ├── 3%  del rake → bank_reserves (FONDO DEL PROYECTO, siempre)
--   └── 97% del rake → billetera NTX-20 del dueño del club
--
-- Tienda: el NTX-20 pagado por emojis/estilos se suma al Fondo del Proyecto.
-- Niveles de club y fichas de club: el NTX-20 pagado se suma al Fondo del Proyecto.
-- ============================================================================
