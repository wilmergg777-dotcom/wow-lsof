-- ============================================================
-- AstroIO — migration_15.sql (v2.4.9 — LOGROS: MINAS NORIO/GERMANIO)
-- ============================================================
-- QUE HACE:
--   Anade 2 cadenas nuevas de logros (10 niveles cada una) a la
--   pestana Tareas -> Logros (game.php?page=tasks&tab=achievements):
--     * Minero Norio     : Mina de norio     niveles 2,4,...,20
--     * Minero Germanio  : Mina de germanio  niveles 2,4,...,20
--   Mismo formato que las cadenas clasicas (Minero Metales, Minero
--   Cristales, Minero Deuterio): requisito tipo building, progreso
--   por nivel MAXIMO de la mina entre todos los planetas, recompensa
--   en Materia Oscura 100..550 y 10 niveles por cadena.
--
--   REQUISITO: migration_10 (expansion Norium/Germanium) aplicada en
--   ese universo. Si falta la columna norium_mine, el universo se
--   salta solo (aparece un mensaje informativo).
--
--   TODOS LOS UNIVERSOS: detecta uni1..uni5 (information_schema) y
--   salta los que no existan. IDEMPOTENTE: se puede ejecutar varias
--   veces sin dano (ON DUPLICATE KEY UPDATE por code+level). Los
--   niveles ya reclamados por los jugadores NO se tocan.
--
--   DESPUES DE EJECUTAR: no hace falta borrar cache (los logros se
--   leen de la BD en cada vista). Entra al juego -> Tareas -> Logros.
-- ============================================================

-- -----------------------------------------------------------
-- 0) ¿Qué universos tengo? (solo informativo)
-- -----------------------------------------------------------
SELECT DISTINCT REPLACE(TABLE_NAME, '_planets', '') AS universos_de_tu_bd
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME LIKE 'uni%\_planets'
ORDER BY universos_de_tu_bd;

-- ============================================================
-- UNI1 (se ejecuta solo si el universo existe y tiene la expansion)
-- ============================================================
-- 1) Insertar las 20 filas nuevas (2 cadenas x 10 niveles:
--    miner_norium sort_order 1401-1410, miner_germanium sort_order 1411-1420)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_achievements_catalog') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets' AND COLUMN_NAME='norium_mine') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets' AND COLUMN_NAME='germanium_mine'), 'INSERT INTO `uni1_achievements_catalog` (`code`, `title`, `description`, `requirement_type`, `requirement_key`, `level`, `requirement_value`, `reward_type`, `reward_amount`, `icon`, `sort_order`, `is_active`, `created_at`) VALUES 
(''miner_norium'', ''Minero Norio I'', ''Mina de norio nivel 2'', ''building'', ''norium_mine'', 1, 2, ''darkmatter'', 100, ''norium_mine'', 1401, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio II'', ''Mina de norio nivel 4'', ''building'', ''norium_mine'', 2, 4, ''darkmatter'', 150, ''norium_mine'', 1402, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio III'', ''Mina de norio nivel 6'', ''building'', ''norium_mine'', 3, 6, ''darkmatter'', 200, ''norium_mine'', 1403, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IV'', ''Mina de norio nivel 8'', ''building'', ''norium_mine'', 4, 8, ''darkmatter'', 250, ''norium_mine'', 1404, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio V'', ''Mina de norio nivel 10'', ''building'', ''norium_mine'', 5, 10, ''darkmatter'', 300, ''norium_mine'', 1405, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VI'', ''Mina de norio nivel 12'', ''building'', ''norium_mine'', 6, 12, ''darkmatter'', 350, ''norium_mine'', 1406, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VII'', ''Mina de norio nivel 14'', ''building'', ''norium_mine'', 7, 14, ''darkmatter'', 400, ''norium_mine'', 1407, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VIII'', ''Mina de norio nivel 16'', ''building'', ''norium_mine'', 8, 16, ''darkmatter'', 450, ''norium_mine'', 1408, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IX'', ''Mina de norio nivel 18'', ''building'', ''norium_mine'', 9, 18, ''darkmatter'', 500, ''norium_mine'', 1409, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio X'', ''Mina de norio nivel 20'', ''building'', ''norium_mine'', 10, 20, ''darkmatter'', 550, ''norium_mine'', 1410, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio I'', ''Mina de germanio nivel 2'', ''building'', ''germanium_mine'', 1, 2, ''darkmatter'', 100, ''germanium_mine'', 1411, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio II'', ''Mina de germanio nivel 4'', ''building'', ''germanium_mine'', 2, 4, ''darkmatter'', 150, ''germanium_mine'', 1412, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio III'', ''Mina de germanio nivel 6'', ''building'', ''germanium_mine'', 3, 6, ''darkmatter'', 200, ''germanium_mine'', 1413, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IV'', ''Mina de germanio nivel 8'', ''building'', ''germanium_mine'', 4, 8, ''darkmatter'', 250, ''germanium_mine'', 1414, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio V'', ''Mina de germanio nivel 10'', ''building'', ''germanium_mine'', 5, 10, ''darkmatter'', 300, ''germanium_mine'', 1415, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VI'', ''Mina de germanio nivel 12'', ''building'', ''germanium_mine'', 6, 12, ''darkmatter'', 350, ''germanium_mine'', 1416, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VII'', ''Mina de germanio nivel 14'', ''building'', ''germanium_mine'', 7, 14, ''darkmatter'', 400, ''germanium_mine'', 1417, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VIII'', ''Mina de germanio nivel 16'', ''building'', ''germanium_mine'', 8, 16, ''darkmatter'', 450, ''germanium_mine'', 1418, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IX'', ''Mina de germanio nivel 18'', ''building'', ''germanium_mine'', 9, 18, ''darkmatter'', 500, ''germanium_mine'', 1419, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio X'', ''Mina de germanio nivel 20'', ''building'', ''germanium_mine'', 10, 20, ''darkmatter'', 550, ''germanium_mine'', 1420, 1, UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE `title`=VALUES(`title`), `description`=VALUES(`description`), `requirement_type`=VALUES(`requirement_type`), `requirement_key`=VALUES(`requirement_key`), `requirement_value`=VALUES(`requirement_value`), `reward_type`=VALUES(`reward_type`), `reward_amount`=VALUES(`reward_amount`), `icon`=VALUES(`icon`), `sort_order`=VALUES(`sort_order`)', 'SELECT "uni1: sin expansion Norium/Germanium o sin tabla de logros (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Marcar version del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni1_config` SET `VERSION` = ''2.4.9''', 'SELECT "uni1: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI2 (se ejecuta solo si el universo existe y tiene la expansion)
-- ============================================================
-- 1) Insertar las 20 filas nuevas (2 cadenas x 10 niveles:
--    miner_norium sort_order 1401-1410, miner_germanium sort_order 1411-1420)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_achievements_catalog') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets' AND COLUMN_NAME='norium_mine') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets' AND COLUMN_NAME='germanium_mine'), 'INSERT INTO `uni2_achievements_catalog` (`code`, `title`, `description`, `requirement_type`, `requirement_key`, `level`, `requirement_value`, `reward_type`, `reward_amount`, `icon`, `sort_order`, `is_active`, `created_at`) VALUES 
(''miner_norium'', ''Minero Norio I'', ''Mina de norio nivel 2'', ''building'', ''norium_mine'', 1, 2, ''darkmatter'', 100, ''norium_mine'', 1401, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio II'', ''Mina de norio nivel 4'', ''building'', ''norium_mine'', 2, 4, ''darkmatter'', 150, ''norium_mine'', 1402, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio III'', ''Mina de norio nivel 6'', ''building'', ''norium_mine'', 3, 6, ''darkmatter'', 200, ''norium_mine'', 1403, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IV'', ''Mina de norio nivel 8'', ''building'', ''norium_mine'', 4, 8, ''darkmatter'', 250, ''norium_mine'', 1404, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio V'', ''Mina de norio nivel 10'', ''building'', ''norium_mine'', 5, 10, ''darkmatter'', 300, ''norium_mine'', 1405, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VI'', ''Mina de norio nivel 12'', ''building'', ''norium_mine'', 6, 12, ''darkmatter'', 350, ''norium_mine'', 1406, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VII'', ''Mina de norio nivel 14'', ''building'', ''norium_mine'', 7, 14, ''darkmatter'', 400, ''norium_mine'', 1407, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VIII'', ''Mina de norio nivel 16'', ''building'', ''norium_mine'', 8, 16, ''darkmatter'', 450, ''norium_mine'', 1408, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IX'', ''Mina de norio nivel 18'', ''building'', ''norium_mine'', 9, 18, ''darkmatter'', 500, ''norium_mine'', 1409, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio X'', ''Mina de norio nivel 20'', ''building'', ''norium_mine'', 10, 20, ''darkmatter'', 550, ''norium_mine'', 1410, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio I'', ''Mina de germanio nivel 2'', ''building'', ''germanium_mine'', 1, 2, ''darkmatter'', 100, ''germanium_mine'', 1411, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio II'', ''Mina de germanio nivel 4'', ''building'', ''germanium_mine'', 2, 4, ''darkmatter'', 150, ''germanium_mine'', 1412, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio III'', ''Mina de germanio nivel 6'', ''building'', ''germanium_mine'', 3, 6, ''darkmatter'', 200, ''germanium_mine'', 1413, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IV'', ''Mina de germanio nivel 8'', ''building'', ''germanium_mine'', 4, 8, ''darkmatter'', 250, ''germanium_mine'', 1414, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio V'', ''Mina de germanio nivel 10'', ''building'', ''germanium_mine'', 5, 10, ''darkmatter'', 300, ''germanium_mine'', 1415, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VI'', ''Mina de germanio nivel 12'', ''building'', ''germanium_mine'', 6, 12, ''darkmatter'', 350, ''germanium_mine'', 1416, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VII'', ''Mina de germanio nivel 14'', ''building'', ''germanium_mine'', 7, 14, ''darkmatter'', 400, ''germanium_mine'', 1417, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VIII'', ''Mina de germanio nivel 16'', ''building'', ''germanium_mine'', 8, 16, ''darkmatter'', 450, ''germanium_mine'', 1418, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IX'', ''Mina de germanio nivel 18'', ''building'', ''germanium_mine'', 9, 18, ''darkmatter'', 500, ''germanium_mine'', 1419, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio X'', ''Mina de germanio nivel 20'', ''building'', ''germanium_mine'', 10, 20, ''darkmatter'', 550, ''germanium_mine'', 1420, 1, UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE `title`=VALUES(`title`), `description`=VALUES(`description`), `requirement_type`=VALUES(`requirement_type`), `requirement_key`=VALUES(`requirement_key`), `requirement_value`=VALUES(`requirement_value`), `reward_type`=VALUES(`reward_type`), `reward_amount`=VALUES(`reward_amount`), `icon`=VALUES(`icon`), `sort_order`=VALUES(`sort_order`)', 'SELECT "uni2: sin expansion Norium/Germanium o sin tabla de logros (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Marcar version del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni2_config` SET `VERSION` = ''2.4.9''', 'SELECT "uni2: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI3 (se ejecuta solo si el universo existe y tiene la expansion)
-- ============================================================
-- 1) Insertar las 20 filas nuevas (2 cadenas x 10 niveles:
--    miner_norium sort_order 1401-1410, miner_germanium sort_order 1411-1420)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_achievements_catalog') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets' AND COLUMN_NAME='norium_mine') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets' AND COLUMN_NAME='germanium_mine'), 'INSERT INTO `uni3_achievements_catalog` (`code`, `title`, `description`, `requirement_type`, `requirement_key`, `level`, `requirement_value`, `reward_type`, `reward_amount`, `icon`, `sort_order`, `is_active`, `created_at`) VALUES 
(''miner_norium'', ''Minero Norio I'', ''Mina de norio nivel 2'', ''building'', ''norium_mine'', 1, 2, ''darkmatter'', 100, ''norium_mine'', 1401, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio II'', ''Mina de norio nivel 4'', ''building'', ''norium_mine'', 2, 4, ''darkmatter'', 150, ''norium_mine'', 1402, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio III'', ''Mina de norio nivel 6'', ''building'', ''norium_mine'', 3, 6, ''darkmatter'', 200, ''norium_mine'', 1403, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IV'', ''Mina de norio nivel 8'', ''building'', ''norium_mine'', 4, 8, ''darkmatter'', 250, ''norium_mine'', 1404, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio V'', ''Mina de norio nivel 10'', ''building'', ''norium_mine'', 5, 10, ''darkmatter'', 300, ''norium_mine'', 1405, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VI'', ''Mina de norio nivel 12'', ''building'', ''norium_mine'', 6, 12, ''darkmatter'', 350, ''norium_mine'', 1406, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VII'', ''Mina de norio nivel 14'', ''building'', ''norium_mine'', 7, 14, ''darkmatter'', 400, ''norium_mine'', 1407, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VIII'', ''Mina de norio nivel 16'', ''building'', ''norium_mine'', 8, 16, ''darkmatter'', 450, ''norium_mine'', 1408, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IX'', ''Mina de norio nivel 18'', ''building'', ''norium_mine'', 9, 18, ''darkmatter'', 500, ''norium_mine'', 1409, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio X'', ''Mina de norio nivel 20'', ''building'', ''norium_mine'', 10, 20, ''darkmatter'', 550, ''norium_mine'', 1410, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio I'', ''Mina de germanio nivel 2'', ''building'', ''germanium_mine'', 1, 2, ''darkmatter'', 100, ''germanium_mine'', 1411, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio II'', ''Mina de germanio nivel 4'', ''building'', ''germanium_mine'', 2, 4, ''darkmatter'', 150, ''germanium_mine'', 1412, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio III'', ''Mina de germanio nivel 6'', ''building'', ''germanium_mine'', 3, 6, ''darkmatter'', 200, ''germanium_mine'', 1413, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IV'', ''Mina de germanio nivel 8'', ''building'', ''germanium_mine'', 4, 8, ''darkmatter'', 250, ''germanium_mine'', 1414, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio V'', ''Mina de germanio nivel 10'', ''building'', ''germanium_mine'', 5, 10, ''darkmatter'', 300, ''germanium_mine'', 1415, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VI'', ''Mina de germanio nivel 12'', ''building'', ''germanium_mine'', 6, 12, ''darkmatter'', 350, ''germanium_mine'', 1416, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VII'', ''Mina de germanio nivel 14'', ''building'', ''germanium_mine'', 7, 14, ''darkmatter'', 400, ''germanium_mine'', 1417, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VIII'', ''Mina de germanio nivel 16'', ''building'', ''germanium_mine'', 8, 16, ''darkmatter'', 450, ''germanium_mine'', 1418, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IX'', ''Mina de germanio nivel 18'', ''building'', ''germanium_mine'', 9, 18, ''darkmatter'', 500, ''germanium_mine'', 1419, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio X'', ''Mina de germanio nivel 20'', ''building'', ''germanium_mine'', 10, 20, ''darkmatter'', 550, ''germanium_mine'', 1420, 1, UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE `title`=VALUES(`title`), `description`=VALUES(`description`), `requirement_type`=VALUES(`requirement_type`), `requirement_key`=VALUES(`requirement_key`), `requirement_value`=VALUES(`requirement_value`), `reward_type`=VALUES(`reward_type`), `reward_amount`=VALUES(`reward_amount`), `icon`=VALUES(`icon`), `sort_order`=VALUES(`sort_order`)', 'SELECT "uni3: sin expansion Norium/Germanium o sin tabla de logros (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Marcar version del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni3_config` SET `VERSION` = ''2.4.9''', 'SELECT "uni3: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI4 (se ejecuta solo si el universo existe y tiene la expansion)
-- ============================================================
-- 1) Insertar las 20 filas nuevas (2 cadenas x 10 niveles:
--    miner_norium sort_order 1401-1410, miner_germanium sort_order 1411-1420)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_achievements_catalog') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets' AND COLUMN_NAME='norium_mine') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets' AND COLUMN_NAME='germanium_mine'), 'INSERT INTO `uni4_achievements_catalog` (`code`, `title`, `description`, `requirement_type`, `requirement_key`, `level`, `requirement_value`, `reward_type`, `reward_amount`, `icon`, `sort_order`, `is_active`, `created_at`) VALUES 
(''miner_norium'', ''Minero Norio I'', ''Mina de norio nivel 2'', ''building'', ''norium_mine'', 1, 2, ''darkmatter'', 100, ''norium_mine'', 1401, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio II'', ''Mina de norio nivel 4'', ''building'', ''norium_mine'', 2, 4, ''darkmatter'', 150, ''norium_mine'', 1402, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio III'', ''Mina de norio nivel 6'', ''building'', ''norium_mine'', 3, 6, ''darkmatter'', 200, ''norium_mine'', 1403, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IV'', ''Mina de norio nivel 8'', ''building'', ''norium_mine'', 4, 8, ''darkmatter'', 250, ''norium_mine'', 1404, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio V'', ''Mina de norio nivel 10'', ''building'', ''norium_mine'', 5, 10, ''darkmatter'', 300, ''norium_mine'', 1405, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VI'', ''Mina de norio nivel 12'', ''building'', ''norium_mine'', 6, 12, ''darkmatter'', 350, ''norium_mine'', 1406, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VII'', ''Mina de norio nivel 14'', ''building'', ''norium_mine'', 7, 14, ''darkmatter'', 400, ''norium_mine'', 1407, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VIII'', ''Mina de norio nivel 16'', ''building'', ''norium_mine'', 8, 16, ''darkmatter'', 450, ''norium_mine'', 1408, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IX'', ''Mina de norio nivel 18'', ''building'', ''norium_mine'', 9, 18, ''darkmatter'', 500, ''norium_mine'', 1409, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio X'', ''Mina de norio nivel 20'', ''building'', ''norium_mine'', 10, 20, ''darkmatter'', 550, ''norium_mine'', 1410, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio I'', ''Mina de germanio nivel 2'', ''building'', ''germanium_mine'', 1, 2, ''darkmatter'', 100, ''germanium_mine'', 1411, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio II'', ''Mina de germanio nivel 4'', ''building'', ''germanium_mine'', 2, 4, ''darkmatter'', 150, ''germanium_mine'', 1412, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio III'', ''Mina de germanio nivel 6'', ''building'', ''germanium_mine'', 3, 6, ''darkmatter'', 200, ''germanium_mine'', 1413, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IV'', ''Mina de germanio nivel 8'', ''building'', ''germanium_mine'', 4, 8, ''darkmatter'', 250, ''germanium_mine'', 1414, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio V'', ''Mina de germanio nivel 10'', ''building'', ''germanium_mine'', 5, 10, ''darkmatter'', 300, ''germanium_mine'', 1415, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VI'', ''Mina de germanio nivel 12'', ''building'', ''germanium_mine'', 6, 12, ''darkmatter'', 350, ''germanium_mine'', 1416, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VII'', ''Mina de germanio nivel 14'', ''building'', ''germanium_mine'', 7, 14, ''darkmatter'', 400, ''germanium_mine'', 1417, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VIII'', ''Mina de germanio nivel 16'', ''building'', ''germanium_mine'', 8, 16, ''darkmatter'', 450, ''germanium_mine'', 1418, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IX'', ''Mina de germanio nivel 18'', ''building'', ''germanium_mine'', 9, 18, ''darkmatter'', 500, ''germanium_mine'', 1419, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio X'', ''Mina de germanio nivel 20'', ''building'', ''germanium_mine'', 10, 20, ''darkmatter'', 550, ''germanium_mine'', 1420, 1, UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE `title`=VALUES(`title`), `description`=VALUES(`description`), `requirement_type`=VALUES(`requirement_type`), `requirement_key`=VALUES(`requirement_key`), `requirement_value`=VALUES(`requirement_value`), `reward_type`=VALUES(`reward_type`), `reward_amount`=VALUES(`reward_amount`), `icon`=VALUES(`icon`), `sort_order`=VALUES(`sort_order`)', 'SELECT "uni4: sin expansion Norium/Germanium o sin tabla de logros (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Marcar version del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni4_config` SET `VERSION` = ''2.4.9''', 'SELECT "uni4: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI5 (se ejecuta solo si el universo existe y tiene la expansion)
-- ============================================================
-- 1) Insertar las 20 filas nuevas (2 cadenas x 10 niveles:
--    miner_norium sort_order 1401-1410, miner_germanium sort_order 1411-1420)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_achievements_catalog') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets' AND COLUMN_NAME='norium_mine') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets' AND COLUMN_NAME='germanium_mine'), 'INSERT INTO `uni5_achievements_catalog` (`code`, `title`, `description`, `requirement_type`, `requirement_key`, `level`, `requirement_value`, `reward_type`, `reward_amount`, `icon`, `sort_order`, `is_active`, `created_at`) VALUES 
(''miner_norium'', ''Minero Norio I'', ''Mina de norio nivel 2'', ''building'', ''norium_mine'', 1, 2, ''darkmatter'', 100, ''norium_mine'', 1401, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio II'', ''Mina de norio nivel 4'', ''building'', ''norium_mine'', 2, 4, ''darkmatter'', 150, ''norium_mine'', 1402, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio III'', ''Mina de norio nivel 6'', ''building'', ''norium_mine'', 3, 6, ''darkmatter'', 200, ''norium_mine'', 1403, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IV'', ''Mina de norio nivel 8'', ''building'', ''norium_mine'', 4, 8, ''darkmatter'', 250, ''norium_mine'', 1404, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio V'', ''Mina de norio nivel 10'', ''building'', ''norium_mine'', 5, 10, ''darkmatter'', 300, ''norium_mine'', 1405, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VI'', ''Mina de norio nivel 12'', ''building'', ''norium_mine'', 6, 12, ''darkmatter'', 350, ''norium_mine'', 1406, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VII'', ''Mina de norio nivel 14'', ''building'', ''norium_mine'', 7, 14, ''darkmatter'', 400, ''norium_mine'', 1407, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio VIII'', ''Mina de norio nivel 16'', ''building'', ''norium_mine'', 8, 16, ''darkmatter'', 450, ''norium_mine'', 1408, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio IX'', ''Mina de norio nivel 18'', ''building'', ''norium_mine'', 9, 18, ''darkmatter'', 500, ''norium_mine'', 1409, 1, UNIX_TIMESTAMP()),
(''miner_norium'', ''Minero Norio X'', ''Mina de norio nivel 20'', ''building'', ''norium_mine'', 10, 20, ''darkmatter'', 550, ''norium_mine'', 1410, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio I'', ''Mina de germanio nivel 2'', ''building'', ''germanium_mine'', 1, 2, ''darkmatter'', 100, ''germanium_mine'', 1411, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio II'', ''Mina de germanio nivel 4'', ''building'', ''germanium_mine'', 2, 4, ''darkmatter'', 150, ''germanium_mine'', 1412, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio III'', ''Mina de germanio nivel 6'', ''building'', ''germanium_mine'', 3, 6, ''darkmatter'', 200, ''germanium_mine'', 1413, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IV'', ''Mina de germanio nivel 8'', ''building'', ''germanium_mine'', 4, 8, ''darkmatter'', 250, ''germanium_mine'', 1414, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio V'', ''Mina de germanio nivel 10'', ''building'', ''germanium_mine'', 5, 10, ''darkmatter'', 300, ''germanium_mine'', 1415, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VI'', ''Mina de germanio nivel 12'', ''building'', ''germanium_mine'', 6, 12, ''darkmatter'', 350, ''germanium_mine'', 1416, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VII'', ''Mina de germanio nivel 14'', ''building'', ''germanium_mine'', 7, 14, ''darkmatter'', 400, ''germanium_mine'', 1417, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio VIII'', ''Mina de germanio nivel 16'', ''building'', ''germanium_mine'', 8, 16, ''darkmatter'', 450, ''germanium_mine'', 1418, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio IX'', ''Mina de germanio nivel 18'', ''building'', ''germanium_mine'', 9, 18, ''darkmatter'', 500, ''germanium_mine'', 1419, 1, UNIX_TIMESTAMP()),
(''miner_germanium'', ''Minero Germanio X'', ''Mina de germanio nivel 20'', ''building'', ''germanium_mine'', 10, 20, ''darkmatter'', 550, ''germanium_mine'', 1420, 1, UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE `title`=VALUES(`title`), `description`=VALUES(`description`), `requirement_type`=VALUES(`requirement_type`), `requirement_key`=VALUES(`requirement_key`), `requirement_value`=VALUES(`requirement_value`), `reward_type`=VALUES(`reward_type`), `reward_amount`=VALUES(`reward_amount`), `icon`=VALUES(`icon`), `sort_order`=VALUES(`sort_order`)', 'SELECT "uni5: sin expansion Norium/Germanium o sin tabla de logros (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Marcar version del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni5_config` SET `VERSION` = ''2.4.9''', 'SELECT "uni5: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- -----------------------------------------------------------
-- 3) VERIFICACIÓN (revisar los resultados)
-- -----------------------------------------------------------
-- Debe devolver 10 filas por cada cadena en cada universo:
SELECT `code`, `level`, `title`, `requirement_value`, `reward_amount`, `sort_order`
FROM `uni1_achievements_catalog` WHERE `code` IN ('miner_norium','miner_germanium') ORDER BY `code`, `level`;
-- Total por cadena (debe ser 10 y 10):
SELECT `code`, COUNT(*) AS filas FROM `uni1_achievements_catalog` WHERE `code` IN ('miner_norium','miner_germanium') GROUP BY `code`;
-- Version del juego (universo 1):
SELECT `VERSION` FROM `uni1_config`;
-- ============================================================
-- FIN migration_15.sql
-- ============================================================
