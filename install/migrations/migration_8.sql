-- ============================================================
-- AstroIO — migration_8.sql (avatar de jugador 100% funcional)
-- Ejecutar en TODOS los universos con el prefijo correspondiente.
-- NOTA: si una columna ya existe, el ALTER falla con
-- "Duplicate column name" — es inofensivo, ignora esa línea.
-- (El juego TAMBIÉN se auto-migra: al abrir cualquier página crea
--  la columna sola si no existe, así que este SQL es solo respaldo.)
-- ============================================================

-- Foto de perfil del jugador (ruta relativa, ej: styles/avatars/u5_1730000000.jpg).
-- Se sube desde Configuración → Perfil → "Editar foto" (máx 2 MB, JPG/PNG/GIF/WEBP).
-- Vacío = avatar por defecto (globo). Los demás jugadores lo ven en el
-- ranking, la tarjeta de jugador y el menú de usuario.
ALTER TABLE `%PREFIX%users`
  ADD COLUMN `avatar` VARCHAR(255) NOT NULL DEFAULT '' AFTER `email`;
