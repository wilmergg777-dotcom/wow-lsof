-- ============================================================
-- AstroIO — migration_6.sql (v3.9 — sincronización de esquema)
-- Ejecutar en TODOS los universos con el prefijo correspondiente.
-- Crea las tablas que el código usa y producción puede no tener
-- (idempotente: IF NOT EXISTS / guardas por columna).
-- ============================================================


CREATE TABLE IF NOT EXISTS `%PREFIX%faction_bonuses` (

  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) unsigned NOT NULL,
  `bonus_type` varchar(30) NOT NULL,
  `bonus_value` float NOT NULL DEFAULT 0,
  `source_mission_id` int(11) unsigned NOT NULL DEFAULT 0,
  `expires_at` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_faction` (`faction_id`,`bonus_type`),
  KEY `idx_expires` (`expires_at`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%faction_daily_rotation` (

  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) unsigned NOT NULL,
  `mission_id` int(11) unsigned NOT NULL,
  `rotation_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_faction_date` (`faction_id`,`rotation_date`)

) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%faction_global_contributions` (

  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `global_mission_id` int(11) unsigned NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  `amount` bigint(20) unsigned NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_global` (`global_mission_id`),
  KEY `idx_user` (`user_id`)

) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%faction_global_missions` (

  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) unsigned NOT NULL,
  `mission_id` int(11) unsigned NOT NULL,
  `progress` bigint(20) unsigned NOT NULL DEFAULT 0,
  `target` bigint(20) unsigned NOT NULL DEFAULT 0,
  `status` enum('active','completed','bonus_active','expired') NOT NULL DEFAULT 'active',
  `bonus_end` int(11) NOT NULL DEFAULT 0,
  `bonus_type` varchar(30) DEFAULT NULL,
  `bonus_value` float NOT NULL DEFAULT 0,
  `cycle_start` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_faction_status` (`faction_id`,`status`)

) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%faction_missions` (

  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) unsigned NOT NULL,
  `mission_type` enum('personal','global') NOT NULL,
  `mission_key` varchar(64) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `icon` varchar(32) DEFAULT '',
  `action_type` varchar(40) NOT NULL,
  `target_type` varchar(40) NOT NULL DEFAULT 'any',
  `target_id` int(11) unsigned NOT NULL DEFAULT 0,
  `target_amount` bigint(20) unsigned NOT NULL DEFAULT 0,
  `reward_type` varchar(30) NOT NULL DEFAULT '',
  `reward_json` mediumtext DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_faction_type` (`faction_id`,`mission_type`,`active`),
  KEY `idx_key` (`mission_key`)

) ENGINE=InnoDB AUTO_INCREMENT=217 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%faction_missions_log` (

  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `faction_id` int(11) unsigned NOT NULL DEFAULT 0,
  `mission_id` int(11) unsigned NOT NULL DEFAULT 0,
  `action` varchar(64) NOT NULL,
  `amount` bigint(20) NOT NULL DEFAULT 0,
  `note` varchar(255) DEFAULT NULL,
  `created_at` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_time` (`user_id`,`created_at`),
  KEY `idx_faction_time` (`faction_id`,`created_at`)

) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%mistic_items` (

  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `cost_base_mo` int(11) NOT NULL DEFAULT 1000,
  `recycle_value_mo` int(11) NOT NULL DEFAULT 300,
  `bonus_json` text NOT NULL,
  `image` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)

) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%reserves` (

  `currency_code` varchar(20) NOT NULL,
  `balance` bigint(20) NOT NULL DEFAULT 0,
  `project_fund` bigint(20) NOT NULL DEFAULT 0,
  `min_required` bigint(20) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`currency_code`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%users_bank_data` (

  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `tarjeta_magnetica` varchar(50) DEFAULT NULL,
  `telefono` varchar(30) DEFAULT NULL,
  `titular` varchar(100) DEFAULT NULL,
  `banco` varchar(100) DEFAULT NULL,
  `fecha_creacion` int(11) DEFAULT NULL,
  `fecha_actualizacion` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_id` (`user_id`),
  KEY `idx_user_id` (`user_id`)

) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%users_bank_data_requests` (

  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `tarjeta_magnetica` varchar(50) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  `titular` varchar(100) DEFAULT NULL,
  `banco` varchar(100) DEFAULT NULL,
  `estado` enum('pendiente','aprobada','rechazada') NOT NULL DEFAULT 'pendiente',
  `fecha_creacion` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `motivo_rechazo` text DEFAULT NULL,
  `fecha_resolucion` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `estado` (`estado`)

) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%users_faction_missions` (

  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `faction_id` int(11) unsigned NOT NULL,
  `mission_id` int(11) unsigned NOT NULL,
  `progress` bigint(20) unsigned NOT NULL DEFAULT 0,
  `claimed` tinyint(1) NOT NULL DEFAULT 0,
  `claimed_at` int(11) NOT NULL DEFAULT 0,
  `rotation_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_mission_date` (`user_id`,`mission_id`,`rotation_date`),
  KEY `idx_user_date` (`user_id`,`rotation_date`)

) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%users_mistic` (

  `user_id` int(11) NOT NULL,
  `mistic_id` int(11) NOT NULL,
  `level` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`,`mistic_id`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%wallet_banco_historial` (

  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` int(11) NOT NULL,
  `kyber_banco` bigint(20) NOT NULL DEFAULT 0,
  `total_invertido` bigint(20) NOT NULL DEFAULT 0,
  `total_retirado` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fecha` (`fecha`)

) ENGINE=InnoDB AUTO_INCREMENT=713 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `%PREFIX%faction_buff_pool` (

  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `faction_id` int(11) unsigned NOT NULL,
  `buff_key` varchar(64) NOT NULL,
  `buff_name` varchar(100) NOT NULL,
  `buff_type` varchar(30) NOT NULL,
  `buff_value` float NOT NULL DEFAULT 0,
  `weight` int(11) NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_faction_active` (`faction_id`,`active`)

) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Config del mercado cruzado (el código las lee de {prefix}config; si
-- no existen, cae siempre a los defaults y el admin no puede cambiarlas)
ALTER TABLE `%PREFIX%config` ADD COLUMN `cross_spread_pct` DECIMAL(5,2) NOT NULL DEFAULT '5.00';
ALTER TABLE `%PREFIX%config` ADD COLUMN `cross_unit_usd` DECIMAL(10,4) NOT NULL DEFAULT '0.1000';

-- Semilla del fondo del mercado (fila id=1; sin ella las comisiones se
-- pierden silenciosamente en addToFund)
INSERT INTO `%PREFIX%market_fund` (`id`, `total_earned`, `from_seller`, `from_buyer`, `from_admin`, `last_update`)
SELECT 1, 0, 0, 0, 0, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `%PREFIX%market_fund` WHERE `id` = 1);
