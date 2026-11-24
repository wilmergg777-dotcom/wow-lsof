-- ============================================================
-- AstroIO — migration_12.sql (v2.4.2)
-- CORRECCIÓN DE MISILES (regla final confirmada):
--   502 (Misil de intercepción)   → NO pide Norium
--   503 (Misil interplanetario)   → NO pide Norium
--   504 (Misil Antimateria)       → SÍ pide Norium (1200)
--   505 (Interceptor Avanzado)    → SÍ pide Norium (800)
--
-- Esta migración es IDEMPOTENTE: puedes ejecutarla aunque ya
-- hayas corrido la migration_11; fija los valores finales.
-- Después de ejecutarla: limpiar la caché del juego
-- (Panel Admin → Limpiar Caché, o vaciar la carpeta cache/).
-- ============================================================

-- Sin Norium:
UPDATE `%PREFIX%vars` SET `cost932` = 0 WHERE `elementID` = 502;  -- Misil de intercepción
UPDATE `%PREFIX%vars` SET `cost932` = 0 WHERE `elementID` = 503;  -- Misil interplanetario

-- Con Norium:
UPDATE `%PREFIX%vars` SET `cost932` = 1200 WHERE `elementID` = 504;  -- Misil Antimateria
UPDATE `%PREFIX%vars` SET `cost932` =  800 WHERE `elementID` = 505;  -- Interceptor Avanzado

-- ============================================================
-- FIN migration_12
-- ============================================================
