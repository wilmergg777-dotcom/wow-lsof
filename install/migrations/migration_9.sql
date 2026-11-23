-- ============================================================
-- AstroIO — migration_9.sql (sistema de clima completo)
-- Ejecutar en TODOS los universos con el prefijo correspondiente.
-- NOTA: si una columna ya existe, el ALTER falla con
-- "Duplicate column name" — es inofensivo, ignora esa línea.
-- Las semillas usan INSERT IGNORE (la clave UNIQUE uq_clave evita duplicados).
-- ============================================================
-- ============================================================
-- AstroIO — SISTEMA DE CLIMA (ClimaEngine v6.5 / buffs v1.2)
-- 4 tablas + 14 climas semilla + columnas de flotas/jugadores.
-- Esquema idéntico al servidor live (backup_xnova.sql, uni1_).
-- ============================================================

CREATE TABLE IF NOT EXISTS `{P}climas` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `clave` varchar(40) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `factor_ataque` decimal(4,2) NOT NULL DEFAULT 1.00,
  `factor_defensa` decimal(4,2) NOT NULL DEFAULT 1.00,
  `factor_bajas` decimal(4,2) NOT NULL DEFAULT 1.00,
  `factor_botin` decimal(4,2) NOT NULL DEFAULT 1.00,
  `peso` tinyint(3) unsigned NOT NULL DEFAULT 10,
  `categoria` enum('suave','medio','raro') NOT NULL DEFAULT 'medio',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_clave` (`clave`),
  KEY `idx_activo` (`activo`),
  KEY `idx_categoria` (`categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO `{P}climas` (clave, nombre, descripcion, factor_ataque, factor_defensa, factor_bajas, factor_botin, peso, categoria, activo) VALUES
('despejado','Cielo Despejado','Sin interferencias. El combate se desarrolla con normalidad.',1.00,1.00,1.00,1.00,18,'suave',1),
('brisa_solar','Brisa Solar','Vientos suaves favorecen la puntería de los atacantes.',1.05,0.95,1.00,1.00,12,'suave',1),
('viento_estelar','Viento Estelar Suave','El viento cósmico refuerza los escudos defensivos.',0.95,1.05,1.00,1.00,12,'suave',1),
('cristalino','Cielo Cristalino','Los escombros brillan. Se pueden recuperar más recursos.',1.00,1.00,1.00,1.10,10,'suave',1),
('niebla','Niebla Densísima','Los sensores no funcionan. El ataque pierde precisión.',0.70,1.00,1.00,1.00,8,'medio',1),
('tormenta_solar','Tormenta Solar','Oleadas de plasma desestabilizan los generadores de escudo.',1.00,0.70,1.00,1.00,8,'medio',1),
('meteoros','Lluvia de Meteoros','Meteoros cruzan el campo de batalla, sembrando caos.',1.00,1.00,1.15,1.00,6,'medio',1),
('nebulosa','Nebulosa Mineral','Vetas de mineral flotan en el espacio. Botín abundante.',1.00,1.00,1.00,1.50,6,'medio',1),
('plasma','Nube de Plasma','El plasma ionizado potencia los rayos ofensivos.',1.20,0.80,1.00,1.00,5,'medio',1),
('eclipse','Eclipse Solar','La oscuridad permite maniobras furtivas, defensa resiente.',1.15,0.90,1.00,1.00,4,'medio',1),
('campo_mag','Campo Magnético','Los campos erráticos desvían los proyectiles defensivos.',1.00,0.80,1.10,1.00,4,'medio',1),
('aurora','Aurora Cósmica','Sincronización perfecta. Atacante y defensor luchan mejor.',1.10,1.10,1.00,1.20,3,'raro',1),
('agujero','Agujero de Gusano','Un vórtice inestable transporta naves fuera de la batalla.',1.00,1.00,1.20,1.00,2,'raro',1),
('singularidad','Singularidad','La gravedad extrema afecta a todo. Caos total.',0.50,0.50,1.25,1.00,1,'raro',1);

CREATE TABLE IF NOT EXISTS `{P}clima_planeta` (
  `planeta_id` int(11) unsigned NOT NULL,
  `clima_id` tinyint(3) unsigned NOT NULL,
  `clima_previsto_id` tinyint(3) unsigned DEFAULT NULL,
  `fecha_asignacion` datetime NOT NULL,
  `fecha_expiracion` datetime NOT NULL,
  `fecha_prediccion` datetime DEFAULT NULL,
  PRIMARY KEY (`planeta_id`),
  KEY `idx_expiracion` (`fecha_expiracion`),
  KEY `idx_clima` (`clima_id`),
  KEY `idx_prediccion` (`clima_previsto_id`),
  CONSTRAINT `fk_clima_planeta_clima` FOREIGN KEY (`clima_id`) REFERENCES `{P}climas` (`id`),
  CONSTRAINT `fk_clima_planeta_previsto` FOREIGN KEY (`clima_previsto_id`) REFERENCES `{P}climas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `{P}clima_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tipo` enum('rotacion','prediccion','forzado_admin','limpieza') NOT NULL,
  `planetas_afectados` int(10) unsigned NOT NULL DEFAULT 0,
  `duracion_segundos` decimal(6,2) NOT NULL DEFAULT 0.00,
  `admin_id` int(11) DEFAULT NULL,
  `detalle` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tipo` (`tipo`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `{P}users_clima_buff` (
  `user_id` int(11) unsigned NOT NULL,
  `buff_type` enum('estabilizador_menor','estabilizador_mayor','dominio') NOT NULL,
  `activated_from` varchar(20) NOT NULL DEFAULT 'unknown',
  `expires_at` int(11) unsigned NOT NULL,
  `created_at` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`),
  KEY `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Columnas de clima en tablas existentes (si ya existen, el ALTER
-- falla con "Duplicate column name" — es inofensivo, ignora esa línea).
ALTER TABLE `{P}fleets`
  ADD COLUMN `clima_id` tinyint(3) unsigned DEFAULT NULL,
  ADD COLUMN `buff_id` tinyint(3) unsigned DEFAULT NULL,
  ADD KEY `idx_clima` (`clima_id`),
  ADD KEY `idx_buff` (`buff_id`);
ALTER TABLE `{P}users`
  ADD COLUMN `rpg_astronomo` tinyint(2) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `{P}users_market`
  ADD COLUMN `box_climate_minor` int(11) NOT NULL DEFAULT 0,
  ADD COLUMN `box_climate_major` int(11) NOT NULL DEFAULT 0,
  ADD COLUMN `box_climate_dominion` int(11) NOT NULL DEFAULT 0;
