-- ============================================================
-- AstroIO — migration_11.sql (v2.4.1)
-- 1) REORDENAR EDIFICIOS: las minas de Norio (7) y Germanio (17)
--    quedan justo DESPUÉS del Sintetizador de Deuterio (3);
--    los almacenes de Norio (25) y Germanio (26) quedan justo
--    DESPUÉS del Almacén de Deuterio (24).
-- 2) COSTES EN RECURSOS NUEVOS:
--    - TODAS las naves piden Norium EXCEPTO: 202 (Nave pequeña de
--      carga), 204 (Cazador ligero), 205 (Cazador pesado) y
--      212 (Satélite solar).
--    - TODAS las defensas piden Norium EXCEPTO: 401 (Lanzamisiles)
--      y 402 (Láser pequeño).
--    - MISILES (regla final v2.4.2): 502 (Misil de intercepción) y
--      503 (Misil interplanetario) NO piden Norium; 504 (Misil
--      Antimateria) y 505 (Interceptor Avanzado) SÍ lo piden.
--    - TODAS las investigaciones piden Germanium EXCEPTO:
--      113 (Energía), 115 (Motor de combustión) y 120 (Láser).
--    - Edificios que piden Germanium: 14 Robots, 15 Nanobots,
--      6 Universidad, 41 Base lunar, 42 Sensor Phalanx,
--      43 Salto cuántico, 33 Terraformer.
-- NOTA: los UPDATEs de costes usan guardas (COALESCE=0) para NO
-- sobrescribir costes que ya existan. El ALTER puede fallar con
-- "Duplicate column name" si ya ejecutaste esta migración:
-- es inofensivo, ignora esa línea.
-- ============================================================

-- ============================================================
-- 1) COLUMNA DE ORDEN en el motor de variables
--    (los elementos nuevos sin sort_order quedan al final: 100000)
-- ============================================================
ALTER TABLE `%PREFIX%vars`
  ADD COLUMN `sort_order` int(11) NOT NULL DEFAULT 100000;

-- ------------------------------------------------------------
-- Orden de edificios (se conserva el orden relativo original:
-- 1,2,3,[7,17],4,6,12,14,15,21,22,23,24,[25,26],31,33,34,41,42,43,44)
-- ------------------------------------------------------------
UPDATE `%PREFIX%vars` SET `sort_order` =  100 WHERE `elementID` = 1;   -- Mina de Metal
UPDATE `%PREFIX%vars` SET `sort_order` =  110 WHERE `elementID` = 2;   -- Mina de Cristal
UPDATE `%PREFIX%vars` SET `sort_order` =  120 WHERE `elementID` = 3;   -- Sintetizador de Deuterio
UPDATE `%PREFIX%vars` SET `sort_order` =  130 WHERE `elementID` = 7;   -- Mina de Norio          ← tras el sintetizador
UPDATE `%PREFIX%vars` SET `sort_order` =  140 WHERE `elementID` = 17;  -- Mina de Germanio       ← tras el sintetizador
UPDATE `%PREFIX%vars` SET `sort_order` =  150 WHERE `elementID` = 4;   -- Planta Solar
UPDATE `%PREFIX%vars` SET `sort_order` =  160 WHERE `elementID` = 6;   -- Universidad
UPDATE `%PREFIX%vars` SET `sort_order` =  170 WHERE `elementID` = 12;  -- Planta de Fusión
UPDATE `%PREFIX%vars` SET `sort_order` =  180 WHERE `elementID` = 14;  -- Fábrica de Robots
UPDATE `%PREFIX%vars` SET `sort_order` =  190 WHERE `elementID` = 15;  -- Fábrica de Nanobots
UPDATE `%PREFIX%vars` SET `sort_order` =  200 WHERE `elementID` = 21;  -- Hangar
UPDATE `%PREFIX%vars` SET `sort_order` =  210 WHERE `elementID` = 22;  -- Almacén de Metal
UPDATE `%PREFIX%vars` SET `sort_order` =  220 WHERE `elementID` = 23;  -- Almacén de Cristal
UPDATE `%PREFIX%vars` SET `sort_order` =  230 WHERE `elementID` = 24;  -- Almacén de Deuterio
UPDATE `%PREFIX%vars` SET `sort_order` =  240 WHERE `elementID` = 25;  -- Almacén de Norio       ← tras el de deuterio
UPDATE `%PREFIX%vars` SET `sort_order` =  250 WHERE `elementID` = 26;  -- Almacén de Germanio    ← tras el de deuterio
UPDATE `%PREFIX%vars` SET `sort_order` =  260 WHERE `elementID` = 31;  -- Laboratorio
UPDATE `%PREFIX%vars` SET `sort_order` =  270 WHERE `elementID` = 33;  -- Terraformer
UPDATE `%PREFIX%vars` SET `sort_order` =  280 WHERE `elementID` = 34;  -- Depósito de Alianza
UPDATE `%PREFIX%vars` SET `sort_order` =  290 WHERE `elementID` = 41;  -- Base Lunar
UPDATE `%PREFIX%vars` SET `sort_order` =  300 WHERE `elementID` = 42;  -- Sensor Phalanx
UPDATE `%PREFIX%vars` SET `sort_order` =  310 WHERE `elementID` = 43;  -- Salto Cuántico
UPDATE `%PREFIX%vars` SET `sort_order` =  320 WHERE `elementID` = 44;  -- Silo

-- ============================================================
-- 2) NAVES: coste en NORIUM (932)
--    EXENTAS: 202, 204, 205, 212 (no se tocan)
--    (232/236/237 ya tenían Norium; 233 ya tenía Germanium → se
--     añade su Norium; los demás se asignan ahora)
-- ============================================================
UPDATE `%PREFIX%vars` SET `cost932` =    300 WHERE `elementID` = 203 AND COALESCE(`cost932`,0) = 0;  -- Nave grande de carga
UPDATE `%PREFIX%vars` SET `cost932` =    800 WHERE `elementID` = 206 AND COALESCE(`cost932`,0) = 0;  -- Crucero
UPDATE `%PREFIX%vars` SET `cost932` =   1500 WHERE `elementID` = 207 AND COALESCE(`cost932`,0) = 0;  -- Nave de batalla
UPDATE `%PREFIX%vars` SET `cost932` =   1200 WHERE `elementID` = 208 AND COALESCE(`cost932`,0) = 0;  -- Colonizador
UPDATE `%PREFIX%vars` SET `cost932` =    800 WHERE `elementID` = 209 AND COALESCE(`cost932`,0) = 0;  -- Reciclador
UPDATE `%PREFIX%vars` SET `cost932` =     50 WHERE `elementID` = 210 AND COALESCE(`cost932`,0) = 0;  -- Sonda de espionaje
UPDATE `%PREFIX%vars` SET `cost932` =   2000 WHERE `elementID` = 211 AND COALESCE(`cost932`,0) = 0;  -- Bomber
UPDATE `%PREFIX%vars` SET `cost932` =   3500 WHERE `elementID` = 213 AND COALESCE(`cost932`,0) = 0;  -- Destructor
UPDATE `%PREFIX%vars` SET `cost932` = 150000 WHERE `elementID` = 214 AND COALESCE(`cost932`,0) = 0;  -- Estrella de la muerte
UPDATE `%PREFIX%vars` SET `cost932` =   2500 WHERE `elementID` = 215 AND COALESCE(`cost932`,0) = 0;  -- Acorazado
UPDATE `%PREFIX%vars` SET `cost932` =  80000 WHERE `elementID` = 216 AND COALESCE(`cost932`,0) = 0;  -- Lune Noir
UPDATE `%PREFIX%vars` SET `cost932` =   1500 WHERE `elementID` = 217 AND COALESCE(`cost932`,0) = 0;  -- Transportador EV
UPDATE `%PREFIX%vars` SET `cost932` = 4000000 WHERE `elementID` = 218 AND COALESCE(`cost932`,0) = 0; -- Star Crasher
UPDATE `%PREFIX%vars` SET `cost932` =  15000 WHERE `elementID` = 219 AND COALESCE(`cost932`,0) = 0;  -- Giga reciclador
UPDATE `%PREFIX%vars` SET `cost932` = 100000 WHERE `elementID` = 220 AND COALESCE(`cost932`,0) = 0;  -- DM Ship
UPDATE `%PREFIX%vars` SET `cost932` = 3500000 WHERE `elementID` = 221 AND COALESCE(`cost932`,0) = 0; -- Star Titan
UPDATE `%PREFIX%vars` SET `cost932` = 1500000 WHERE `elementID` = 222 AND COALESCE(`cost932`,0) = 0; -- War Colossus
UPDATE `%PREFIX%vars` SET `cost932` =   2500 WHERE `elementID` = 223 AND COALESCE(`cost932`,0) = 0;  -- Acorazado de élite
UPDATE `%PREFIX%vars` SET `cost932` =   3000 WHERE `elementID` = 224 AND COALESCE(`cost932`,0) = 0;  -- Fragata pesada
UPDATE `%PREFIX%vars` SET `cost932` =    300 WHERE `elementID` = 228 AND COALESCE(`cost932`,0) = 0;  -- Cazador sigiloso
UPDATE `%PREFIX%vars` SET `cost932` =    800 WHERE `elementID` = 229 AND COALESCE(`cost932`,0) = 0;  -- Fragata de plasma
UPDATE `%PREFIX%vars` SET `cost932` =   1200 WHERE `elementID` = 230 AND COALESCE(`cost932`,0) = 0;  -- Crucero blindado
UPDATE `%PREFIX%vars` SET `cost932` =   1800 WHERE `elementID` = 231 AND COALESCE(`cost932`,0) = 0;  -- Porta ligero
UPDATE `%PREFIX%vars` SET `cost932` =   4000 WHERE `elementID` = 233 AND COALESCE(`cost932`,0) = 0;  -- Estación porta (ya pedía Germanium 8000)
UPDATE `%PREFIX%vars` SET `cost932` =   1000 WHERE `elementID` = 234 AND COALESCE(`cost932`,0) = 0;  -- Taladrador de Norio
UPDATE `%PREFIX%vars` SET `cost932` =   1500 WHERE `elementID` = 235 AND COALESCE(`cost932`,0) = 0;  -- Corvette destructor

-- ============================================================
-- 3) DEFENSAS: coste en NORIUM (932)
--    EXENTAS: 401 (Lanzamisiles), 402 (Láser pequeño) → no se tocan
--    (420/422 ya tenían Norium → no se sobrescriben; 419 ya tenía
--     Germanium 12000 → se le añade su Norium)
-- ============================================================
UPDATE `%PREFIX%vars` SET `cost932` =    150 WHERE `elementID` = 403 AND COALESCE(`cost932`,0) = 0;  -- Láser grande
UPDATE `%PREFIX%vars` SET `cost932` =    500 WHERE `elementID` = 404 AND COALESCE(`cost932`,0) = 0;  -- Cañón Gauss
UPDATE `%PREFIX%vars` SET `cost932` =    200 WHERE `elementID` = 405 AND COALESCE(`cost932`,0) = 0;  -- Cañón de iones
UPDATE `%PREFIX%vars` SET `cost932` =   1500 WHERE `elementID` = 406 AND COALESCE(`cost932`,0) = 0;  -- Cañón de plasma
UPDATE `%PREFIX%vars` SET `cost932` =    300 WHERE `elementID` = 407 AND COALESCE(`cost932`,0) = 0;  -- Cúpula pequeña
UPDATE `%PREFIX%vars` SET `cost932` =   1000 WHERE `elementID` = 408 AND COALESCE(`cost932`,0) = 0;  -- Cúpula grande
UPDATE `%PREFIX%vars` SET `cost932` =  50000 WHERE `elementID` = 409 AND COALESCE(`cost932`,0) = 0;  -- Protector planetario
UPDATE `%PREFIX%vars` SET `cost932` =  80000 WHERE `elementID` = 410 AND COALESCE(`cost932`,0) = 0;  -- Cañón gravitón
UPDATE `%PREFIX%vars` SET `cost932` = 20000000 WHERE `elementID` = 411 AND COALESCE(`cost932`,0) = 0; -- Estación orbital
UPDATE `%PREFIX%vars` SET `cost932` =   2500 WHERE `elementID` = 416 AND COALESCE(`cost932`,0) = 0;  -- Cañón de plasma pesado
UPDATE `%PREFIX%vars` SET `cost932` =    800 WHERE `elementID` = 417 AND COALESCE(`cost932`,0) = 0;  -- Torre de iones avanzada
UPDATE `%PREFIX%vars` SET `cost932` =    400 WHERE `elementID` = 418 AND COALESCE(`cost932`,0) = 0;  -- Red orbital antimisiles
UPDATE `%PREFIX%vars` SET `cost932` =   1000 WHERE `elementID` = 419 AND COALESCE(`cost932`,0) = 0;  -- Escudo planetario (ya pedía Germanium 12000)
UPDATE `%PREFIX%vars` SET `cost932` =   1500 WHERE `elementID` = 421 AND COALESCE(`cost932`,0) = 0;  -- Torre defensora

-- ============================================================
-- 4) MISILES (v2.4.2 — regla corregida):
--    502 (Misil de intercepción) y 503 (Misil interplanetario):
--      NO piden Norium → quedan a 0.
--    504 (Misil Antimateria) y 505 (Interceptor Avanzado):
--      SÍ piden Norium.
-- ============================================================
UPDATE `%PREFIX%vars` SET `cost932` =       0 WHERE `elementID` = 502;  -- Misil de intercepción (SIN Norium)
UPDATE `%PREFIX%vars` SET `cost932` =       0 WHERE `elementID` = 503;  -- Misil interplanetario  (SIN Norium)
UPDATE `%PREFIX%vars` SET `cost932` =    1200 WHERE `elementID` = 504;  -- Misil Antimateria      (con Norium)
UPDATE `%PREFIX%vars` SET `cost932` =     800 WHERE `elementID` = 505;  -- Interceptor Avanzado   (con Norium)

-- ============================================================
-- 5) INVESTIGACIONES: coste en GERMANIUM (933)
--    EXENTAS: 113 (Energía), 115 (Motor de combustión), 120 (Láser)
-- ============================================================
UPDATE `%PREFIX%vars` SET `cost933` =    100 WHERE `elementID` = 106 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de espionaje
UPDATE `%PREFIX%vars` SET `cost933` =     60 WHERE `elementID` = 108 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de computación
UPDATE `%PREFIX%vars` SET `cost933` =     40 WHERE `elementID` = 109 AND COALESCE(`cost933`,0) = 0;  -- Tecnología militar
UPDATE `%PREFIX%vars` SET `cost933` =     40 WHERE `elementID` = 110 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de defensa
UPDATE `%PREFIX%vars` SET `cost933` =     50 WHERE `elementID` = 111 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de blindaje
UPDATE `%PREFIX%vars` SET `cost933` =    250 WHERE `elementID` = 114 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de hiperespacio
UPDATE `%PREFIX%vars` SET `cost933` =    200 WHERE `elementID` = 117 AND COALESCE(`cost933`,0) = 0;  -- Motor de impulso
UPDATE `%PREFIX%vars` SET `cost933` =    800 WHERE `elementID` = 118 AND COALESCE(`cost933`,0) = 0;  -- Motor de hiperespacio
UPDATE `%PREFIX%vars` SET `cost933` =     60 WHERE `elementID` = 121 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de iones
UPDATE `%PREFIX%vars` SET `cost933` =    150 WHERE `elementID` = 122 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de plasma
UPDATE `%PREFIX%vars` SET `cost933` =   4000 WHERE `elementID` = 123 AND COALESCE(`cost933`,0) = 0;  -- Red intergaláctica
UPDATE `%PREFIX%vars` SET `cost933` =    400 WHERE `elementID` = 124 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de expediciones
UPDATE `%PREFIX%vars` SET `cost933` =    150 WHERE `elementID` = 131 AND COALESCE(`cost933`,0) = 0;  -- Procesado de metal
UPDATE `%PREFIX%vars` SET `cost933` =    200 WHERE `elementID` = 132 AND COALESCE(`cost933`,0) = 0;  -- Procesado de cristal
UPDATE `%PREFIX%vars` SET `cost933` =    250 WHERE `elementID` = 133 AND COALESCE(`cost933`,0) = 0;  -- Procesado de deuterio
UPDATE `%PREFIX%vars` SET `cost933` =    200 WHERE `elementID` = 134 AND COALESCE(`cost933`,0) = 0;  -- Procesado de Norium
UPDATE `%PREFIX%vars` SET `cost933` =    200 WHERE `elementID` = 135 AND COALESCE(`cost933`,0) = 0;  -- Procesado de Germanium
UPDATE `%PREFIX%vars` SET `cost933` =   5000 WHERE `elementID` = 199 AND COALESCE(`cost933`,0) = 0;  -- Tecnología de gravitón

-- ============================================================
-- 6) EDIFICIOS que piden GERMANIUM (933) para subir de nivel
--    (solo los 7 que indicaste; el resto de edificios no lo piden)
-- ============================================================
UPDATE `%PREFIX%vars` SET `cost933` =    150 WHERE `elementID` = 14 AND COALESCE(`cost933`,0) = 0;   -- Fábrica de Robots
UPDATE `%PREFIX%vars` SET `cost933` =   5000 WHERE `elementID` = 15 AND COALESCE(`cost933`,0) = 0;   -- Fábrica de Nanobots
UPDATE `%PREFIX%vars` SET `cost933` =  50000 WHERE `elementID` = 6  AND COALESCE(`cost933`,0) = 0;   -- Universidad
UPDATE `%PREFIX%vars` SET `cost933` =   1000 WHERE `elementID` = 41 AND COALESCE(`cost933`,0) = 0;   -- Base Lunar
UPDATE `%PREFIX%vars` SET `cost933` =   1200 WHERE `elementID` = 42 AND COALESCE(`cost933`,0) = 0;   -- Sensor Phalanx
UPDATE `%PREFIX%vars` SET `cost933` =  20000 WHERE `elementID` = 43 AND COALESCE(`cost933`,0) = 0;   -- Salto Cuántico
UPDATE `%PREFIX%vars` SET `cost933` =  10000 WHERE `elementID` = 33 AND COALESCE(`cost933`,0) = 0;   -- Terraformer

-- ============================================================
-- FIN — Después de ejecutar: limpiar la caché del juego
-- (Panel Admin → Limpiar Caché, o borrar el contenido de cache/)
-- para que el motor de variables se reconstruya con el nuevo orden
-- y los nuevos costes.
-- ============================================================
