-- ============================================================
-- AstroIO — migration_10.sql (v2.4.0 — Expansión Norium & Germanium)
-- Ejecutar en TODOS los universos con el prefijo correspondiente.
-- NOTA: si una columna ya existe, el ALTER falla con
-- "Duplicate column name" — es inofensivo, ignora esa línea.
-- Los INSERT usan claves explícitas; si un elemento ya existiera,
-- fallará con "Duplicate entry" — ignora esa línea también.
-- ============================================================

-- ============================================================
-- 1) RECURSOS PLANETARIOS: Norium (932) y Germanium (933)
-- ============================================================
ALTER TABLE `%PREFIX%planets`
  ADD COLUMN `norium` double unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `germanium` double unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `norium_max` double unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `germanium_max` double unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `norium_perhour` double NOT NULL DEFAULT 0,
  ADD COLUMN `germanium_perhour` double NOT NULL DEFAULT 0;

ALTER TABLE `%PREFIX%planets`
  ADD COLUMN `norium_mine` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `norium_mine_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '0',
  ADD COLUMN `germanium_mine` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `germanium_mine_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '0',
  ADD COLUMN `norium_store` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `germanium_store` bigint(20) NOT NULL DEFAULT 0;

-- Técnicas de procesado 134/135 (columnas de usuario, patrón metal_proc_tech 131)
ALTER TABLE `%PREFIX%users`
  ADD COLUMN `norium_proc_tech` tinyint(3) unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `germanium_proc_tech` tinyint(3) unsigned NOT NULL DEFAULT 0;

-- Columnas de coste/producción/almacenaje en el motor de variables
ALTER TABLE `%PREFIX%vars`
  ADD COLUMN `cost932` bigint(20) unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `cost933` bigint(20) unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `production932` varchar(255) DEFAULT NULL,
  ADD COLUMN `production933` varchar(255) DEFAULT NULL,
  ADD COLUMN `storage932` varchar(255) DEFAULT NULL,
  ADD COLUMN `storage933` varchar(255) DEFAULT NULL;

-- ============================================================
-- 2) COLUMNAS DE NAVES (228-237) Y DEFENSAS (416-422) EN uni1_planets
--    (patrón bigint como star_titan / assault_corvette)
-- ============================================================
ALTER TABLE `%PREFIX%planets`
  ADD COLUMN `stealth_hunter` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `plasma_frigate` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `armored_cruiser` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `light_carrier` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `norium_battleship` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `carrier_station` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `norium_driller` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `destroyer_corvette` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `general_frigate` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `emperor_dreadnought` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `heavy_plasma_cannon` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `advanced_ion_tower` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `orbital_antimissile_net` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `planet_shield` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `improved_graviton_cannon` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `defender_tower` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `bunker_bastion` bigint(20) NOT NULL DEFAULT 0;

-- ============================================================
-- 3) BANCO DE ALIANZA: columnas de los recursos nuevos
-- ============================================================
ALTER TABLE `%PREFIX%alliance_bank`
  ADD COLUMN `norium` bigint(20) NOT NULL DEFAULT 0,
  ADD COLUMN `germanium` bigint(20) NOT NULL DEFAULT 0;

-- ============================================================
-- 3b) LÍMITE DIARIO del Comerciante de Recursos (v2.6):
--     registro de lo recibido por jugador/día/recurso nuevo
-- ============================================================
CREATE TABLE IF NOT EXISTS `%PREFIX%trader_daily` (
  `user_id` int(11) unsigned NOT NULL,
  `fecha` date NOT NULL,
  `recurso` varchar(20) NOT NULL,
  `cantidad` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`, `fecha`, `recurso`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- 4) RAZAS Y FACciones: columna de imagen (futura personalización)
-- ============================================================
ALTER TABLE `%PREFIX%races`
  ADD COLUMN `race_img` varchar(120) NOT NULL DEFAULT '' AFTER `race_icon`;
ALTER TABLE `%PREFIX%factions`
  ADD COLUMN `faction_img` varchar(120) NOT NULL DEFAULT '' AFTER `faction_icon`;

UPDATE `%PREFIX%races` SET `race_img` = 'razas/raza_predators.jpg' WHERE `race_id` = 1;
UPDATE `%PREFIX%races` SET `race_img` = 'razas/raza_aliens.jpg' WHERE `race_id` = 2;
UPDATE `%PREFIX%races` SET `race_img` = 'razas/raza_charter.jpg' WHERE `race_id` = 3;
UPDATE `%PREFIX%races` SET `race_img` = 'razas/raza_sarcks.jpg' WHERE `race_id` = 4;
UPDATE `%PREFIX%races` SET `race_img` = 'razas/raza_espectros.jpg' WHERE `race_id` = 5;
UPDATE `%PREFIX%races` SET `race_img` = 'razas/raza_mercaderes.jpg' WHERE `race_id` = 6;

UPDATE `%PREFIX%factions` SET `faction_img` = 'facciones/fac_pirata.jpg' WHERE `faction_id` = 1;
UPDATE `%PREFIX%factions` SET `faction_img` = 'facciones/fac_mineros.jpg' WHERE `faction_id` = 2;
UPDATE `%PREFIX%factions` SET `faction_img` = 'facciones/fac_defensores.jpg' WHERE `faction_id` = 3;
UPDATE `%PREFIX%factions` SET `faction_img` = 'facciones/fac_tecnocratas.jpg' WHERE `faction_id` = 4;
UPDATE `%PREFIX%factions` SET `faction_img` = 'facciones/fac_exploradores.jpg' WHERE `faction_id` = 5;
UPDATE `%PREFIX%factions` SET `faction_img` = 'facciones/fac_comerciantes.jpg' WHERE `faction_id` = 6;

-- ============================================================
-- 5) CONTENIDO NUEVO en uni1_vars
--    Edificios: Mina de Norio (7), Mina de Germanio (17),
--               Almacén de Norio (25), Almacén de Germanio (26)
--    Técnicas : Procesado de Norio (134), Procesado de Germanio (135)
-- ============================================================
INSERT INTO `%PREFIX%vars`
  (elementID, name, class, onPlanetType, onePerPlanet, factor, maxLevel, cost901, cost902, cost903, production903, production932, production933, storage932, storage933)
VALUES
  (7,  'norium_mine',    0, '1', 0, 1.50, 255, 500, 150, 0,   '-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', '(15 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, NULL, NULL),
  (17, 'germanium_mine', 0, '1', 0, 1.60, 255, 400, 120, 200, '-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, '(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, NULL),
  (25, 'norium_store',   0, '1,3', 0, 2.00, 255, 1000, 3000, 0, NULL, NULL, NULL, 'floor(2.5 * pow(1.8331954764, $BuildLevel)) * 5000', NULL),
  (26, 'germanium_store',0, '1,3', 0, 2.00, 255, 1000, 3000, 0, NULL, NULL, NULL, NULL, 'floor(2.5 * pow(1.8331954764, $BuildLevel)) * 4000'),
  (134, 'norium_proc_tech',   100, '1,3', 0, 2.00, 255, 1000, 850, 610, NULL, NULL, NULL, NULL, NULL),
  (135, 'germanium_proc_tech',100, '1,3', 0, 2.00, 255, 1200, 900, 700, NULL, NULL, NULL, NULL, NULL);

-- ============================================================
-- 6) LAS 10 NAVES NUEVAS (228-237)
-- ============================================================
INSERT INTO `%PREFIX%vars`
  (elementID, name, class, onPlanetType, onePerPlanet, factor, maxLevel, cost901, cost902, cost903, cost911, cost921, consumption1, consumption2, speedTech, speed1, speed2, capacity, attack, defend, cost932, cost933)
VALUES
  (228, 'stealth_hunter', 200, '1,3', 0, 1.0, NULL, 8000, 4000, 0, 0, 0, 25, 25, 1, 14000, 28000, 60, 150, 40, NULL, NULL),
  (229, 'plasma_frigate', 200, '1,3', 0, 1.0, NULL, 18000, 14000, 3000, 0, 0, 60, 60, 3, 11000, 22000, 150, 500, 120, NULL, NULL),
  (230, 'armored_cruiser', 200, '1,3', 0, 1.0, NULL, 30000, 24000, 8000, 0, 0, 90, 90, 3, 9000, 18000, 400, 800, 700, NULL, NULL),
  (231, 'light_carrier', 200, '1,3', 0, 1.0, NULL, 45000, 35000, 12000, 0, 0, 140, 140, 3, 6000, 12000, 25000, 180, 400, NULL, NULL),
  (232, 'norium_battleship', 200, '1,3', 0, 1.0, NULL, 60000, 45000, 15000, 0, 0, 180, 180, 3, 9500, 19000, 2000, 1900, 500, 1500, NULL),
  (233, 'carrier_station', 200, '1,3', 0, 1.0, NULL, 120000, 90000, 40000, 0, 0, 250, 250, 3, 5000, 10000, 10000, 600, 1200, NULL, 8000),
  (234, 'norium_driller', 200, '1,3', 0, 1.0, NULL, 25000, 10000, 5000, 0, 0, 80, 80, 1, 7000, 14000, 500, 20, 60, NULL, NULL),
  (235, 'destroyer_corvette', 200, '1,3', 0, 1.0, NULL, 40000, 30000, 10000, 0, 0, 120, 120, 1, 13000, 26000, 300, 1200, 250, NULL, NULL),
  (236, 'general_frigate', 200, '1,3', 0, 1.0, NULL, 150000, 110000, 45000, 0, 0, 280, 280, 3, 10500, 21000, 1500, 5000, 900, 3000, 2000),
  (237, 'emperor_dreadnought', 200, '1,3', 0, 1.0, NULL, 220000000, 90000000, 35000000, 0, 0, 100000, 100000, 3, 30, 60, 8000000, 25000000, 900000, 2000000, 500000);


-- ============================================================
-- 7) LAS 7 DEFENSAS NUEVAS (416-422)
-- ============================================================
INSERT INTO `%PREFIX%vars`
  (elementID, name, class, onPlanetType, onePerPlanet, factor, maxLevel, cost901, cost902, cost903, cost911, cost921, capacity, attack, defend, cost932, cost933)
VALUES
  (416, 'heavy_plasma_cannon', 400, '1,3', 0, 1.0, NULL, 60000, 50000, 20000, 0, 0, 0, 4800, 500, NULL, NULL),
  (417, 'advanced_ion_tower', 400, '1,3', 0, 1.0, NULL, 12000, 26000, 5000, 0, 0, 0, 700, 1700, NULL, NULL),
  (418, 'orbital_antimissile_net', 400, '1,3', 0, 1.0, NULL, 15000, 10000, 0, 0, 0, 0, 60, 1000, NULL, NULL),
  (419, 'planet_shield', 400, '1,3', 0, 1.0, NULL, 80000, 80000, 0, 0, 0, 0, 1, 24000, NULL, 12000),
  (420, 'improved_graviton_cannon', 400, '1,3', 0, 1.0, NULL, 12000000, 10000000, 2000000, 0, 0, 0, 900000, 100000, 20000, NULL),
  (421, 'defender_tower', 400, '1,3', 0, 1.0, NULL, 45000, 35000, 8000, 0, 0, 0, 3400, 600, NULL, NULL),
  (422, 'bunker_bastion', 400, '1,3', 0, 1.0, NULL, 300000, 250000, 60000, 0, 0, 0, 20000, 7000, 5000, 3000);


-- ============================================================
-- 8) REQUISITOS (uni1_vars_require) — patrón de la tabla existente
-- ============================================================
INSERT IGNORE INTO `%PREFIX%vars_requriements` (elementID, requireID, requireLevel) VALUES
  -- Naves por investigación
  (228, 117, 5),  (228, 109, 8),
  (229, 124, 4),  (229, 117, 8),
  (230, 110, 12), (230, 121, 5),
  (231, 108, 10), (231, 114, 3),
  (232, 134, 3),  (232, 121, 10),
  (233, 114, 6),  (233, 108, 15),
  -- Naves por oficial
  (234, 611, 2),  (234, 21, 8),
  (235, 612, 1),
  (236, 613, 2),
  (237, 615, 1),  (237, 199, 5),
  -- Defensas por investigación
  (416, 124, 6),
  (417, 121, 12),
  (418, 110, 8),  (418, 44, 4),
  (419, 111, 15),
  (420, 199, 3),  (420, 124, 15),
  -- Defensas por oficial
  (421, 608, 3),
  (422, 609, 1),
  -- Técnicas de procesado nuevas (patrón 131/132/133: energía + computación)
  (134, 113, 5),  (134, 108, 8),
  (135, 113, 5),  (135, 108, 8),
  -- Desbloqueo de las minas nuevas (hangar 4 y laboratorio 3)
  (7,  21, 4),
  (17, 21, 4),
  (25, 22, 2),
  (26, 23, 2);

-- ============================================================
-- 9) FUEGO RÁPIDO (uni1_vars_rapidfire) — naves capitales y contras de defensas
-- ============================================================
INSERT IGNORE INTO `%PREFIX%vars_rapidfire` (elementID, rapidfireID, shoots) VALUES
  (237, 214, 5), (237, 218, 3),
  (236, 204, 4), (236, 206, 3),
  (235, 210, 6), (235, 204, 3),
  (232, 211, 3),
  (416, 211, 2), (416, 207, 1),
  (417, 204, 3), (417, 205, 2),
  (420, 214, 3), (420, 218, 1),
  (421, 204, 4), (421, 205, 2),
  (422, 206, 2), (422, 211, 1);

-- ============================================================
-- 10) COSTES EN NORIUM/Germanio SOBRE ELEMENTOS EXISTENTES (cap. 4.3)
-- ============================================================
UPDATE `%PREFIX%vars` SET `cost932` = CASE `elementID`
    WHEN 206 THEN 6000
    WHEN 207 THEN 10000
    WHEN 209 THEN 2000
    WHEN 211 THEN 30000
    WHEN 212 THEN 1000
    WHEN 213 THEN 40000
    WHEN 214 THEN 9000000
    WHEN 218 THEN 120000000
    WHEN 219 THEN 300000
    WHEN 404 THEN 3000
    WHEN 405 THEN 2000
    WHEN 406 THEN 20000
    WHEN 411 THEN 800000000
    ELSE `cost932` END
WHERE `elementID` IN (206, 207, 209, 211, 212, 213, 214, 218, 219, 404, 405, 406, 411);

UPDATE `%PREFIX%vars` SET `cost933` = CASE `elementID`
    WHEN 407 THEN 2000
    WHEN 408 THEN 8000
    WHEN 409 THEN 150000
    WHEN 415 THEN 30000
    WHEN 210 THEN 500
    WHEN 217 THEN 8000
    WHEN 106 THEN 100
    WHEN 108 THEN 150
    WHEN 114 THEN 2000
    ELSE `cost933` END
WHERE `elementID` IN (407, 408, 409, 415, 210, 217, 106, 108, 114);


-- ============================================================
-- 11) REESTRUCTURACIÓN DE BALANCE (cap. 7) — 8 ajustes
-- ============================================================
UPDATE `%PREFIX%vars` SET `attack` = 1400    WHERE `elementID` = 215; -- Acorazado 6.5 → 13.0 atk/k
UPDATE `%PREFIX%vars` SET `attack` = 2000    WHERE `elementID` = 223; -- Elite Battleship 7.3 → 14.6
UPDATE `%PREFIX%vars` SET `attack` = 2600    WHERE `elementID` = 224; -- Heavy Frigate 5.4 → 12.8
UPDATE `%PREFIX%vars` SET `attack` = 180000  WHERE `elementID` = 216; -- Lune Noir 10.9 → 13.1
UPDATE `%PREFIX%vars` SET `defend` = 1200000, `cost901` = 15000000, `cost903` = 4000000 WHERE `elementID` = 415; -- Deflector 3.5 → 40 esc/k
UPDATE `%PREFIX%vars` SET `attack` = 5000    WHERE `elementID` = 406; -- Buster Canyon 18 → 30.7
UPDATE `%PREFIX%vars` SET `attack` = 900000  WHERE `elementID` = 410; -- Graviton Canyon 18 → 31.3
UPDATE `%PREFIX%vars` SET `defend` = 1500000 WHERE `elementID` = 409; -- Planet Protector 23.5 → 35.3

-- ============================================================
-- FIN migration_10.sql — Tras aplicarla: rebuild de caché de
-- variables desde el panel de administración (OBLIGATORIO).
-- ============================================================
