-- ============================================================
-- AstroIO — migration_14.sql (v2.4.8 — REGLA DE BALANCE MINAS)
-- ============================================================
-- REGLA (pedida por el dueño del juego):
--   * Mina de Norio (elementID 7): produce como la mina de DEUTERIO
--     pero 20% MENOS (x0.8). Misma fórmula que el deuterio real de
--     tu BD, incluido el factor de temperatura (-0.002*temp + 1.28):
--         deuterio: (10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor))
--         norio   : ((10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor)) * 0.8)
--   * Mina de Germanio (elementID 17): produce como la mina de CRISTAL
--     pero 30% MENOS (x0.7). El cristal no lleva factor de temperatura:
--         cristal : (20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)
--         germanio: ((20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor) * 0.7)
--   * Consumo de energía y de deuterio de las dos minas: SIN CAMBIOS.
--   * Además: porcentaje de producción 0 -> 10 (100%) y DEFAULT 10 en
--     TODOS los universos, y VERSION = 2.4.8.
--
-- TODOS LOS UNIVERSOS: el script detecta automáticamente uni1..uni5
-- (information_schema) y salta los que no existan. Idempotente: se
-- puede ejecutar varias veces sin daño. Sin procedures ni DELIMITER.
--
-- CÓMO EJECUTAR: phpMyAdmin -> base de datos del juego (xnova_db)
-- -> pestaña SQL -> pegar este archivo COMPLETO -> Continuar.
-- DESPUÉS: borrar cache/cache.vars.php del VPS y recargar el juego.
-- ============================================================

-- -----------------------------------------------------------
-- 0) ¿Qué universos tengo? (solo informativo)
-- -----------------------------------------------------------
SELECT DISTINCT REPLACE(TABLE_NAME, '_planets', '') AS universos_de_tu_bd
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME LIKE 'uni%\_planets'
ORDER BY universos_de_tu_bd;

-- ============================================================
-- UNI1 (se ejecuta solo si el universo existe)
-- ============================================================
-- 1) DEFAULT correcto (10 = 100%) para planetas nuevos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'ALTER TABLE `uni1_planets` MODIFY COLUMN `norium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10'', MODIFY COLUMN `germanium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10''', 'SELECT "uni1: porcent ya correcto o expansion no instalada (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Minas ya construidas a 0%: activar al 100%
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'UPDATE `uni1_planets` SET `norium_mine_porcent` = IF(`norium_mine_porcent` = ''0'', ''10'', `norium_mine_porcent`), `germanium_mine_porcent` = IF(`germanium_mine_porcent` = ''0'', ''10'', `germanium_mine_porcent`)', 'SELECT "uni1: sin planetas que corregir (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 3) REGLA DE BALANCE: norio = deuterio -20%, germanio = cristal -30%
--    (consumo de energia y deuterio sin cambios)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_vars') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_vars' AND COLUMN_NAME='production932') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_vars' AND COLUMN_NAME='production933'), 'UPDATE `uni1_vars` SET `production932` = IF(`elementID` = 7, ''((10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor)) * 0.8)'', `production932`), `production933` = IF(`elementID` = 17, ''((20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor) * 0.7)'', `production933`), `production911` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'', `production903` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'' WHERE `elementID` IN (7, 17)', 'SELECT "uni1: vars sin expansion norium/germanium (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 4) Marcar versión del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni1_config` SET `VERSION` = ''2.4.8''', 'SELECT "uni1: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI2 (se ejecuta solo si el universo existe)
-- ============================================================
-- 1) DEFAULT correcto (10 = 100%) para planetas nuevos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'ALTER TABLE `uni2_planets` MODIFY COLUMN `norium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10'', MODIFY COLUMN `germanium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10''', 'SELECT "uni2: porcent ya correcto o expansion no instalada (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Minas ya construidas a 0%: activar al 100%
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'UPDATE `uni2_planets` SET `norium_mine_porcent` = IF(`norium_mine_porcent` = ''0'', ''10'', `norium_mine_porcent`), `germanium_mine_porcent` = IF(`germanium_mine_porcent` = ''0'', ''10'', `germanium_mine_porcent`)', 'SELECT "uni2: sin planetas que corregir (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 3) REGLA DE BALANCE: norio = deuterio -20%, germanio = cristal -30%
--    (consumo de energia y deuterio sin cambios)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_vars') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_vars' AND COLUMN_NAME='production932') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_vars' AND COLUMN_NAME='production933'), 'UPDATE `uni2_vars` SET `production932` = IF(`elementID` = 7, ''((10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor)) * 0.8)'', `production932`), `production933` = IF(`elementID` = 17, ''((20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor) * 0.7)'', `production933`), `production911` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'', `production903` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'' WHERE `elementID` IN (7, 17)', 'SELECT "uni2: vars sin expansion norium/germanium (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 4) Marcar versión del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni2_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni2_config` SET `VERSION` = ''2.4.8''', 'SELECT "uni2: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI3 (se ejecuta solo si el universo existe)
-- ============================================================
-- 1) DEFAULT correcto (10 = 100%) para planetas nuevos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'ALTER TABLE `uni3_planets` MODIFY COLUMN `norium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10'', MODIFY COLUMN `germanium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10''', 'SELECT "uni3: porcent ya correcto o expansion no instalada (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Minas ya construidas a 0%: activar al 100%
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'UPDATE `uni3_planets` SET `norium_mine_porcent` = IF(`norium_mine_porcent` = ''0'', ''10'', `norium_mine_porcent`), `germanium_mine_porcent` = IF(`germanium_mine_porcent` = ''0'', ''10'', `germanium_mine_porcent`)', 'SELECT "uni3: sin planetas que corregir (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 3) REGLA DE BALANCE: norio = deuterio -20%, germanio = cristal -30%
--    (consumo de energia y deuterio sin cambios)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_vars') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_vars' AND COLUMN_NAME='production932') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_vars' AND COLUMN_NAME='production933'), 'UPDATE `uni3_vars` SET `production932` = IF(`elementID` = 7, ''((10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor)) * 0.8)'', `production932`), `production933` = IF(`elementID` = 17, ''((20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor) * 0.7)'', `production933`), `production911` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'', `production903` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'' WHERE `elementID` IN (7, 17)', 'SELECT "uni3: vars sin expansion norium/germanium (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 4) Marcar versión del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni3_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni3_config` SET `VERSION` = ''2.4.8''', 'SELECT "uni3: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI4 (se ejecuta solo si el universo existe)
-- ============================================================
-- 1) DEFAULT correcto (10 = 100%) para planetas nuevos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'ALTER TABLE `uni4_planets` MODIFY COLUMN `norium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10'', MODIFY COLUMN `germanium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10''', 'SELECT "uni4: porcent ya correcto o expansion no instalada (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Minas ya construidas a 0%: activar al 100%
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'UPDATE `uni4_planets` SET `norium_mine_porcent` = IF(`norium_mine_porcent` = ''0'', ''10'', `norium_mine_porcent`), `germanium_mine_porcent` = IF(`germanium_mine_porcent` = ''0'', ''10'', `germanium_mine_porcent`)', 'SELECT "uni4: sin planetas que corregir (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 3) REGLA DE BALANCE: norio = deuterio -20%, germanio = cristal -30%
--    (consumo de energia y deuterio sin cambios)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_vars') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_vars' AND COLUMN_NAME='production932') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_vars' AND COLUMN_NAME='production933'), 'UPDATE `uni4_vars` SET `production932` = IF(`elementID` = 7, ''((10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor)) * 0.8)'', `production932`), `production933` = IF(`elementID` = 17, ''((20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor) * 0.7)'', `production933`), `production911` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'', `production903` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'' WHERE `elementID` IN (7, 17)', 'SELECT "uni4: vars sin expansion norium/germanium (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 4) Marcar versión del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni4_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni4_config` SET `VERSION` = ''2.4.8''', 'SELECT "uni4: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- ============================================================
-- UNI5 (se ejecuta solo si el universo existe)
-- ============================================================
-- 1) DEFAULT correcto (10 = 100%) para planetas nuevos
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'ALTER TABLE `uni5_planets` MODIFY COLUMN `norium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10'', MODIFY COLUMN `germanium_mine_porcent` enum(''0'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'') NOT NULL DEFAULT ''10''', 'SELECT "uni5: porcent ya correcto o expansion no instalada (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 2) Minas ya construidas a 0%: activar al 100%
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets' AND COLUMN_NAME='norium_mine_porcent') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_planets' AND COLUMN_NAME='germanium_mine_porcent'), 'UPDATE `uni5_planets` SET `norium_mine_porcent` = IF(`norium_mine_porcent` = ''0'', ''10'', `norium_mine_porcent`), `germanium_mine_porcent` = IF(`germanium_mine_porcent` = ''0'', ''10'', `germanium_mine_porcent`)', 'SELECT "uni5: sin planetas que corregir (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 3) REGLA DE BALANCE: norio = deuterio -20%, germanio = cristal -30%
--    (consumo de energia y deuterio sin cambios)
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_vars') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_vars' AND COLUMN_NAME='production932') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_vars' AND COLUMN_NAME='production933'), 'UPDATE `uni5_vars` SET `production932` = IF(`elementID` = 7, ''((10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor)) * 0.8)'', `production932`), `production933` = IF(`elementID` = 17, ''((20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor) * 0.7)'', `production933`), `production911` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'', `production903` = ''-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)'' WHERE `elementID` IN (7, 17)', 'SELECT "uni5: vars sin expansion norium/germanium (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- 4) Marcar versión del juego
SET @sql := IF((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_config') > 0 AND EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni5_config' AND COLUMN_NAME='VERSION'), 'UPDATE `uni5_config` SET `VERSION` = ''2.4.8''', 'SELECT "uni5: sin tabla config (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- -----------------------------------------------------------
-- 5) VERIFICACIÓN (ejecutar y revisar los resultados)
-- -----------------------------------------------------------
-- Fórmulas nuevas de las dos minas (universo 1):
SELECT `elementID`, `production932`, `production933`, `production911`, `production903`
FROM `uni1_vars` WHERE `elementID` IN (7, 17);
-- Debe devolver 0 (ningún planeta con minas al 0%):
SET @sql := IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='uni1_planets' AND COLUMN_NAME='norium_mine_porcent'), 'SELECT COUNT(*) AS planetas_con_porcent_a_0_uni1 FROM `uni1_planets` WHERE `norium_mine_porcent` = ''0'' OR `germanium_mine_porcent` = ''0''', 'SELECT "uni1: sin columnas porcent (omitido)"');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
-- Versión del juego (universo 1):
SELECT `VERSION` FROM `uni1_config`;
-- ============================================================
-- FIN migration_14.sql — recuerda borrar cache/cache.vars.php
-- ============================================================
