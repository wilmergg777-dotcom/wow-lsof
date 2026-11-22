-- ============================================================
-- AstroIO — migration_7.sql (v6.0 — rifas por lugar + país)
-- Ejecutar en TODOS los universos con el prefijo correspondiente.
-- NOTA: si una columna ya existe, el ALTER correspondiente falla con
-- "Duplicate column name" — es inofensivo, ignora esa línea.
-- ============================================================

-- 1) Rifas: lugar explícito por premio (varios premios al MISMO lugar
--    se los lleva el mismo boleto ganador). Premios legacy quedan con
--    lugar=0 y el código los trata por su orden (comportamiento antiguo).
ALTER TABLE `%PREFIX%raffle_prizes`
  ADD COLUMN `lugar` INT(11) NOT NULL DEFAULT 0 AFTER `orden`;

-- 2) País del jugador (ISO 3166-1 alpha-2, ej: CU, VE, ES).
--    Se elige en el registro y la tabla de puntuación muestra la bandera.
ALTER TABLE `%PREFIX%users`
  ADD COLUMN `country` CHAR(2) NOT NULL DEFAULT '' AFTER `lang`;

ALTER TABLE `%PREFIX%users_valid`
  ADD COLUMN `country` CHAR(2) NOT NULL DEFAULT '' AFTER `language`;
