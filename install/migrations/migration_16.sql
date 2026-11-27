-- ============================================================
-- AstroIO — migration_16.sql (v2.4.10 — TALENTOS DE RAZA + FOTOS)
-- ============================================================
-- QUE HACE (dos cosas, ambas idempotentes y con guardia):
--
--  A) TALENTOS DE RAZA (base v2.6, integrado en v2.4.10):
--     crea la tabla uniN_user_race_talents en TODOS los universos
--     que existan (uni1..uni5). Es la tabla del arbol de talentos
--     de raza (game.php?page=raceTalent). Al cambiar de raza el
--     juego BORRA las filas del jugador: el arbol empieza desde 0.
--
--  B) FOTOS DE RAZAS Y FACCIONES:
--     anade race_img / faction_img si faltan (migration_10) y las
--     rellena con las 12 fotos oficiales si estan vacias. Con esto
--     cada raza y cada faccion muestra su foto en page=race,
--     page=faction y page=racefaction (el codigo tambien tiene
--     fallback por nombre/ID, esto es cinturon y tirantes).
--
-- ANTI ERROR #1109: todas las sentencias son condicionales
-- (information_schema + PREPARE). Si te equivocas de base de datos,
-- NADA explota; la primera consulta te lista tus universos.
--
-- COMO EJECUTAR: phpMyAdmin -> base de datos del juego -> pestana
-- SQL -> pegar este archivo COMPLETO -> Continuar. Puedes ejecutarlo
-- varias veces sin dano.
--
-- DESPUES: vaciar el contenido de la carpeta cache/ del juego y
-- recargar (para que el servidor tome las plantillas nuevas).
-- ============================================================

-- -----------------------------------------------------------
-- 0) ¿Que universos tengo? (solo informativo)
-- -----------------------------------------------------------
SELECT DISTINCT REPLACE(TABLE_NAME, '_planets', '') AS universos_de_tu_bd
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME LIKE 'uni%\_planets'
ORDER BY universos_de_tu_bd;

-- ============================================================
-- UNI1
-- ============================================================
-- A) Tabla del arbol de talentos de raza
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_users') > 0, 'CREATE TABLE IF NOT EXISTS `uni1_user_race_talents` (`id` int(11) NOT NULL AUTO_INCREMENT, `user_id` int(11) NOT NULL, `race_id` int(11) NOT NULL DEFAULT 0, `talent_key` varchar(40) NOT NULL, `points` tinyint(3) NOT NULL DEFAULT 0, `updated_at` int(11) NOT NULL DEFAULT 0, PRIMARY KEY (`id`), UNIQUE KEY `uk_user_talent` (`user_id`,`talent_key`), KEY `idx_user` (`user_id`), KEY `idx_race` (`race_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8', 'SELECT "uni1: universo no existe (tabla talentos omitida)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- B) Columnas de foto (si faltan) + relleno con las 12 fotos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_races' AND COLUMN_NAME='race_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_races' AND COLUMN_NAME='race_icon') > 0, 'ALTER TABLE `uni1_races` ADD COLUMN `race_img` varchar(120) NOT NULL DEFAULT '''' AFTER `race_icon`', 'SELECT "uni1.races.race_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_factions' AND COLUMN_NAME='faction_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_factions' AND COLUMN_NAME='faction_icon') > 0, 'ALTER TABLE `uni1_factions` ADD COLUMN `faction_img` varchar(120) NOT NULL DEFAULT '''' AFTER `faction_icon`', 'SELECT "uni1.factions.faction_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_races' AND COLUMN_NAME='race_img') > 0, 'UPDATE `uni1_races` SET `race_img` = CASE `race_id` WHEN 1 THEN ''razas/raza_predators.jpg'' WHEN 2 THEN ''razas/raza_aliens.jpg'' WHEN 3 THEN ''razas/raza_charter.jpg'' WHEN 4 THEN ''razas/raza_sarcks.jpg'' WHEN 5 THEN ''razas/raza_espectros.jpg'' WHEN 6 THEN ''razas/raza_mercaderes.jpg'' END WHERE `race_id` BETWEEN 1 AND 6 AND (`race_img` IS NULL OR `race_img` = '''')', 'SELECT "uni1.races.race_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_factions' AND COLUMN_NAME='faction_img') > 0, 'UPDATE `uni1_factions` SET `faction_img` = CASE `faction_id` WHEN 1 THEN ''facciones/fac_pirata.jpg'' WHEN 2 THEN ''facciones/fac_mineros.jpg'' WHEN 3 THEN ''facciones/fac_defensores.jpg'' WHEN 4 THEN ''facciones/fac_tecnocratas.jpg'' WHEN 5 THEN ''facciones/fac_exploradores.jpg'' WHEN 6 THEN ''facciones/fac_comerciantes.jpg'' END WHERE `faction_id` BETWEEN 1 AND 6 AND (`faction_img` IS NULL OR `faction_img` = '''')', 'SELECT "uni1.factions.faction_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI2
-- ============================================================
-- A) Tabla del arbol de talentos de raza
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_users') > 0, 'CREATE TABLE IF NOT EXISTS `uni2_user_race_talents` (`id` int(11) NOT NULL AUTO_INCREMENT, `user_id` int(11) NOT NULL, `race_id` int(11) NOT NULL DEFAULT 0, `talent_key` varchar(40) NOT NULL, `points` tinyint(3) NOT NULL DEFAULT 0, `updated_at` int(11) NOT NULL DEFAULT 0, PRIMARY KEY (`id`), UNIQUE KEY `uk_user_talent` (`user_id`,`talent_key`), KEY `idx_user` (`user_id`), KEY `idx_race` (`race_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8', 'SELECT "uni2: universo no existe (tabla talentos omitida)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- B) Columnas de foto (si faltan) + relleno con las 12 fotos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_races' AND COLUMN_NAME='race_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_races' AND COLUMN_NAME='race_icon') > 0, 'ALTER TABLE `uni2_races` ADD COLUMN `race_img` varchar(120) NOT NULL DEFAULT '''' AFTER `race_icon`', 'SELECT "uni2.races.race_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_factions' AND COLUMN_NAME='faction_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_factions' AND COLUMN_NAME='faction_icon') > 0, 'ALTER TABLE `uni2_factions` ADD COLUMN `faction_img` varchar(120) NOT NULL DEFAULT '''' AFTER `faction_icon`', 'SELECT "uni2.factions.faction_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_races' AND COLUMN_NAME='race_img') > 0, 'UPDATE `uni2_races` SET `race_img` = CASE `race_id` WHEN 1 THEN ''razas/raza_predators.jpg'' WHEN 2 THEN ''razas/raza_aliens.jpg'' WHEN 3 THEN ''razas/raza_charter.jpg'' WHEN 4 THEN ''razas/raza_sarcks.jpg'' WHEN 5 THEN ''razas/raza_espectros.jpg'' WHEN 6 THEN ''razas/raza_mercaderes.jpg'' END WHERE `race_id` BETWEEN 1 AND 6 AND (`race_img` IS NULL OR `race_img` = '''')', 'SELECT "uni2.races.race_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_factions' AND COLUMN_NAME='faction_img') > 0, 'UPDATE `uni2_factions` SET `faction_img` = CASE `faction_id` WHEN 1 THEN ''facciones/fac_pirata.jpg'' WHEN 2 THEN ''facciones/fac_mineros.jpg'' WHEN 3 THEN ''facciones/fac_defensores.jpg'' WHEN 4 THEN ''facciones/fac_tecnocratas.jpg'' WHEN 5 THEN ''facciones/fac_exploradores.jpg'' WHEN 6 THEN ''facciones/fac_comerciantes.jpg'' END WHERE `faction_id` BETWEEN 1 AND 6 AND (`faction_img` IS NULL OR `faction_img` = '''')', 'SELECT "uni2.factions.faction_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI3
-- ============================================================
-- A) Tabla del arbol de talentos de raza
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_users') > 0, 'CREATE TABLE IF NOT EXISTS `uni3_user_race_talents` (`id` int(11) NOT NULL AUTO_INCREMENT, `user_id` int(11) NOT NULL, `race_id` int(11) NOT NULL DEFAULT 0, `talent_key` varchar(40) NOT NULL, `points` tinyint(3) NOT NULL DEFAULT 0, `updated_at` int(11) NOT NULL DEFAULT 0, PRIMARY KEY (`id`), UNIQUE KEY `uk_user_talent` (`user_id`,`talent_key`), KEY `idx_user` (`user_id`), KEY `idx_race` (`race_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8', 'SELECT "uni3: universo no existe (tabla talentos omitida)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- B) Columnas de foto (si faltan) + relleno con las 12 fotos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_races' AND COLUMN_NAME='race_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_races' AND COLUMN_NAME='race_icon') > 0, 'ALTER TABLE `uni3_races` ADD COLUMN `race_img` varchar(120) NOT NULL DEFAULT '''' AFTER `race_icon`', 'SELECT "uni3.races.race_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_factions' AND COLUMN_NAME='faction_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_factions' AND COLUMN_NAME='faction_icon') > 0, 'ALTER TABLE `uni3_factions` ADD COLUMN `faction_img` varchar(120) NOT NULL DEFAULT '''' AFTER `faction_icon`', 'SELECT "uni3.factions.faction_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_races' AND COLUMN_NAME='race_img') > 0, 'UPDATE `uni3_races` SET `race_img` = CASE `race_id` WHEN 1 THEN ''razas/raza_predators.jpg'' WHEN 2 THEN ''razas/raza_aliens.jpg'' WHEN 3 THEN ''razas/raza_charter.jpg'' WHEN 4 THEN ''razas/raza_sarcks.jpg'' WHEN 5 THEN ''razas/raza_espectros.jpg'' WHEN 6 THEN ''razas/raza_mercaderes.jpg'' END WHERE `race_id` BETWEEN 1 AND 6 AND (`race_img` IS NULL OR `race_img` = '''')', 'SELECT "uni3.races.race_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_factions' AND COLUMN_NAME='faction_img') > 0, 'UPDATE `uni3_factions` SET `faction_img` = CASE `faction_id` WHEN 1 THEN ''facciones/fac_pirata.jpg'' WHEN 2 THEN ''facciones/fac_mineros.jpg'' WHEN 3 THEN ''facciones/fac_defensores.jpg'' WHEN 4 THEN ''facciones/fac_tecnocratas.jpg'' WHEN 5 THEN ''facciones/fac_exploradores.jpg'' WHEN 6 THEN ''facciones/fac_comerciantes.jpg'' END WHERE `faction_id` BETWEEN 1 AND 6 AND (`faction_img` IS NULL OR `faction_img` = '''')', 'SELECT "uni3.factions.faction_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI4
-- ============================================================
-- A) Tabla del arbol de talentos de raza
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_users') > 0, 'CREATE TABLE IF NOT EXISTS `uni4_user_race_talents` (`id` int(11) NOT NULL AUTO_INCREMENT, `user_id` int(11) NOT NULL, `race_id` int(11) NOT NULL DEFAULT 0, `talent_key` varchar(40) NOT NULL, `points` tinyint(3) NOT NULL DEFAULT 0, `updated_at` int(11) NOT NULL DEFAULT 0, PRIMARY KEY (`id`), UNIQUE KEY `uk_user_talent` (`user_id`,`talent_key`), KEY `idx_user` (`user_id`), KEY `idx_race` (`race_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8', 'SELECT "uni4: universo no existe (tabla talentos omitida)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- B) Columnas de foto (si faltan) + relleno con las 12 fotos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_races' AND COLUMN_NAME='race_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_races' AND COLUMN_NAME='race_icon') > 0, 'ALTER TABLE `uni4_races` ADD COLUMN `race_img` varchar(120) NOT NULL DEFAULT '''' AFTER `race_icon`', 'SELECT "uni4.races.race_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_factions' AND COLUMN_NAME='faction_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_factions' AND COLUMN_NAME='faction_icon') > 0, 'ALTER TABLE `uni4_factions` ADD COLUMN `faction_img` varchar(120) NOT NULL DEFAULT '''' AFTER `faction_icon`', 'SELECT "uni4.factions.faction_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_races' AND COLUMN_NAME='race_img') > 0, 'UPDATE `uni4_races` SET `race_img` = CASE `race_id` WHEN 1 THEN ''razas/raza_predators.jpg'' WHEN 2 THEN ''razas/raza_aliens.jpg'' WHEN 3 THEN ''razas/raza_charter.jpg'' WHEN 4 THEN ''razas/raza_sarcks.jpg'' WHEN 5 THEN ''razas/raza_espectros.jpg'' WHEN 6 THEN ''razas/raza_mercaderes.jpg'' END WHERE `race_id` BETWEEN 1 AND 6 AND (`race_img` IS NULL OR `race_img` = '''')', 'SELECT "uni4.races.race_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_factions' AND COLUMN_NAME='faction_img') > 0, 'UPDATE `uni4_factions` SET `faction_img` = CASE `faction_id` WHEN 1 THEN ''facciones/fac_pirata.jpg'' WHEN 2 THEN ''facciones/fac_mineros.jpg'' WHEN 3 THEN ''facciones/fac_defensores.jpg'' WHEN 4 THEN ''facciones/fac_tecnocratas.jpg'' WHEN 5 THEN ''facciones/fac_exploradores.jpg'' WHEN 6 THEN ''facciones/fac_comerciantes.jpg'' END WHERE `faction_id` BETWEEN 1 AND 6 AND (`faction_img` IS NULL OR `faction_img` = '''')', 'SELECT "uni4.factions.faction_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI5
-- ============================================================
-- A) Tabla del arbol de talentos de raza
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_users') > 0, 'CREATE TABLE IF NOT EXISTS `uni5_user_race_talents` (`id` int(11) NOT NULL AUTO_INCREMENT, `user_id` int(11) NOT NULL, `race_id` int(11) NOT NULL DEFAULT 0, `talent_key` varchar(40) NOT NULL, `points` tinyint(3) NOT NULL DEFAULT 0, `updated_at` int(11) NOT NULL DEFAULT 0, PRIMARY KEY (`id`), UNIQUE KEY `uk_user_talent` (`user_id`,`talent_key`), KEY `idx_user` (`user_id`), KEY `idx_race` (`race_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8', 'SELECT "uni5: universo no existe (tabla talentos omitida)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- B) Columnas de foto (si faltan) + relleno con las 12 fotos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_races' AND COLUMN_NAME='race_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_races' AND COLUMN_NAME='race_icon') > 0, 'ALTER TABLE `uni5_races` ADD COLUMN `race_img` varchar(120) NOT NULL DEFAULT '''' AFTER `race_icon`', 'SELECT "uni5.races.race_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_factions' AND COLUMN_NAME='faction_img') = 0 AND (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_factions' AND COLUMN_NAME='faction_icon') > 0, 'ALTER TABLE `uni5_factions` ADD COLUMN `faction_img` varchar(120) NOT NULL DEFAULT '''' AFTER `faction_icon`', 'SELECT "uni5.factions.faction_img: ya existe o tabla no esta (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_races' AND COLUMN_NAME='race_img') > 0, 'UPDATE `uni5_races` SET `race_img` = CASE `race_id` WHEN 1 THEN ''razas/raza_predators.jpg'' WHEN 2 THEN ''razas/raza_aliens.jpg'' WHEN 3 THEN ''razas/raza_charter.jpg'' WHEN 4 THEN ''razas/raza_sarcks.jpg'' WHEN 5 THEN ''razas/raza_espectros.jpg'' WHEN 6 THEN ''razas/raza_mercaderes.jpg'' END WHERE `race_id` BETWEEN 1 AND 6 AND (`race_img` IS NULL OR `race_img` = '''')', 'SELECT "uni5.races.race_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_factions' AND COLUMN_NAME='faction_img') > 0, 'UPDATE `uni5_factions` SET `faction_img` = CASE `faction_id` WHEN 1 THEN ''facciones/fac_pirata.jpg'' WHEN 2 THEN ''facciones/fac_mineros.jpg'' WHEN 3 THEN ''facciones/fac_defensores.jpg'' WHEN 4 THEN ''facciones/fac_tecnocratas.jpg'' WHEN 5 THEN ''facciones/fac_exploradores.jpg'' WHEN 6 THEN ''facciones/fac_comerciantes.jpg'' END WHERE `faction_id` BETWEEN 1 AND 6 AND (`faction_img` IS NULL OR `faction_img` = '''')', 'SELECT "uni5.factions.faction_img: columna no esta (relleno omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- VERIFICACION FINAL (condicional: no explota si falta algo)
-- ============================================================
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_user_race_talents') > 0,
  'SELECT "uni1: OK" AS resultado',
  'SELECT "uni1: tabla user_race_talents NO creada (universo no existe o fallo previo)" AS resultado');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- FIN migration_16 (v2.4.10)
-- ============================================================
