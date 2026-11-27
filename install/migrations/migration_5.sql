-- ============================================================
-- AstroIO — migration_5.sql (v3.8 — fixes PVP/PVE)
-- Ejecutar en TODOS los universos (uni1, uni2, ...) con el
-- prefijo correspondiente (%PREFIX%).
-- ============================================================

-- 1) fleet_target_obj: smallint unsigned (máx 65535) → int unsigned.
--    La Crisis guarda crisis_id ahí y el Bastión guarda wave_id
--    (pve_bastion_waves.id es bigint AUTO_INCREMENT). Con
--    STRICT_ALL_TABLES, cuando el ID supera 65535 el INSERT de la
--    flota moría ("Out of range value"): la oleada quedaba marcada
--    resolved sin flota y el bastión dejaba de recibir ataques
--    (idem crisis a partir de la crisis 65536).
ALTER TABLE %PREFIX%fleets MODIFY `fleet_target_obj` int unsigned NOT NULL DEFAULT '0';

-- 2) UNIQUE anti-doble inscripción en torneos PVP: sin esta clave, un
--    doble click creaba DOS filas para el mismo jugador (doble cobro de
--    la entrada y cupo saltado). Nota: NO se añade UNIQUE en
--    (tournament_id, alliance_id) porque las filas 1v1 comparten
--    alliance_id = 0 y se bloquearían entre sí; el duplicado de alianzas
--    queda cubierto por (tournament_id, user_id) porque user_id es el
--    líder que inscribe.
ALTER TABLE %PREFIX%pvp_tournament_players
  ADD UNIQUE KEY `uniq_tournament_user` (`tournament_id`, `user_id`);
