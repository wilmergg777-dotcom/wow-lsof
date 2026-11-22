-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-10-2026 a las 15:09:51
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `xnova_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_achievements_catalog`
--

CREATE TABLE `uni1_achievements_catalog` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `requirement_type` enum('building','research') NOT NULL,
  `requirement_key` varchar(50) NOT NULL,
  `level` tinyint(2) NOT NULL DEFAULT 1,
  `requirement_value` int(11) NOT NULL DEFAULT 0,
  `reward_type` varchar(20) NOT NULL DEFAULT 'darkmatter',
  `reward_amount` int(11) NOT NULL DEFAULT 0,
  `icon` varchar(50) DEFAULT '',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_achievements_catalog`
--

INSERT INTO `uni1_achievements_catalog` (`id`, `code`, `title`, `description`, `requirement_type`, `requirement_key`, `level`, `requirement_value`, `reward_type`, `reward_amount`, `icon`, `sort_order`, `is_active`, `created_at`) VALUES
(1, 'miner_metal', 'Minero Metales I', 'Mina de metal nivel 2', 'building', 'metal_mine', 1, 2, 'darkmatter', 100, 'metal_mine', 1, 1, 1790173993),
(2, 'miner_metal', 'Minero Metales II', 'Mina de metal nivel 4', 'building', 'metal_mine', 2, 4, 'darkmatter', 150, 'metal_mine', 2, 1, 1790173993),
(3, 'miner_metal', 'Minero Metales III', 'Mina de metal nivel 6', 'building', 'metal_mine', 3, 6, 'darkmatter', 200, 'metal_mine', 3, 1, 1790173993),
(4, 'miner_metal', 'Minero Metales IV', 'Mina de metal nivel 8', 'building', 'metal_mine', 4, 8, 'darkmatter', 250, 'metal_mine', 4, 1, 1790173993),
(5, 'miner_metal', 'Minero Metales V', 'Mina de metal nivel 10', 'building', 'metal_mine', 5, 10, 'darkmatter', 300, 'metal_mine', 5, 1, 1790173993),
(6, 'miner_metal', 'Minero Metales VI', 'Mina de metal nivel 12', 'building', 'metal_mine', 6, 12, 'darkmatter', 350, 'metal_mine', 6, 1, 1790173993),
(7, 'miner_metal', 'Minero Metales VII', 'Mina de metal nivel 14', 'building', 'metal_mine', 7, 14, 'darkmatter', 400, 'metal_mine', 7, 1, 1790173993),
(8, 'miner_metal', 'Minero Metales VIII', 'Mina de metal nivel 16', 'building', 'metal_mine', 8, 16, 'darkmatter', 450, 'metal_mine', 8, 1, 1790173993),
(9, 'miner_metal', 'Minero Metales IX', 'Mina de metal nivel 18', 'building', 'metal_mine', 9, 18, 'darkmatter', 500, 'metal_mine', 9, 1, 1790173993),
(10, 'miner_metal', 'Minero Metales X', 'Mina de metal nivel 20', 'building', 'metal_mine', 10, 20, 'darkmatter', 550, 'metal_mine', 10, 1, 1790173993),
(11, 'miner_crystal', 'Minero Cristales I', 'Mina de cristal nivel 2', 'building', 'crystal_mine', 1, 2, 'darkmatter', 100, 'crystal_mine', 1, 1, 1790173993),
(12, 'miner_crystal', 'Minero Cristales II', 'Mina de cristal nivel 4', 'building', 'crystal_mine', 2, 4, 'darkmatter', 150, 'crystal_mine', 2, 1, 1790173993),
(13, 'miner_crystal', 'Minero Cristales III', 'Mina de cristal nivel 6', 'building', 'crystal_mine', 3, 6, 'darkmatter', 200, 'crystal_mine', 3, 1, 1790173993),
(14, 'miner_crystal', 'Minero Cristales IV', 'Mina de cristal nivel 8', 'building', 'crystal_mine', 4, 8, 'darkmatter', 250, 'crystal_mine', 4, 1, 1790173993),
(15, 'miner_crystal', 'Minero Cristales V', 'Mina de cristal nivel 10', 'building', 'crystal_mine', 5, 10, 'darkmatter', 300, 'crystal_mine', 5, 1, 1790173993),
(16, 'miner_crystal', 'Minero Cristales VI', 'Mina de cristal nivel 12', 'building', 'crystal_mine', 6, 12, 'darkmatter', 350, 'crystal_mine', 6, 1, 1790173993),
(17, 'miner_crystal', 'Minero Cristales VII', 'Mina de cristal nivel 14', 'building', 'crystal_mine', 7, 14, 'darkmatter', 400, 'crystal_mine', 7, 1, 1790173993),
(18, 'miner_crystal', 'Minero Cristales VIII', 'Mina de cristal nivel 16', 'building', 'crystal_mine', 8, 16, 'darkmatter', 450, 'crystal_mine', 8, 1, 1790173993),
(19, 'miner_crystal', 'Minero Cristales IX', 'Mina de cristal nivel 18', 'building', 'crystal_mine', 9, 18, 'darkmatter', 500, 'crystal_mine', 9, 1, 1790173993),
(20, 'miner_crystal', 'Minero Cristales X', 'Mina de cristal nivel 20', 'building', 'crystal_mine', 10, 20, 'darkmatter', 550, 'crystal_mine', 10, 1, 1790173993),
(21, 'miner_deuterium', 'Minero Deuterio I', 'Sintetizador de deuterio nivel 2', 'building', 'deuterium_sintetizer', 1, 2, 'darkmatter', 100, 'deuterium_sintetizer', 1, 1, 1790173993),
(22, 'miner_deuterium', 'Minero Deuterio II', 'Sintetizador de deuterio nivel 4', 'building', 'deuterium_sintetizer', 2, 4, 'darkmatter', 150, 'deuterium_sintetizer', 2, 1, 1790173993),
(23, 'miner_deuterium', 'Minero Deuterio III', 'Sintetizador de deuterio nivel 6', 'building', 'deuterium_sintetizer', 3, 6, 'darkmatter', 200, 'deuterium_sintetizer', 3, 1, 1790173993),
(24, 'miner_deuterium', 'Minero Deuterio IV', 'Sintetizador de deuterio nivel 8', 'building', 'deuterium_sintetizer', 4, 8, 'darkmatter', 250, 'deuterium_sintetizer', 4, 1, 1790173993),
(25, 'miner_deuterium', 'Minero Deuterio V', 'Sintetizador de deuterio nivel 10', 'building', 'deuterium_sintetizer', 5, 10, 'darkmatter', 300, 'deuterium_sintetizer', 5, 1, 1790173993),
(26, 'miner_deuterium', 'Minero Deuterio VI', 'Sintetizador de deuterio nivel 12', 'building', 'deuterium_sintetizer', 6, 12, 'darkmatter', 350, 'deuterium_sintetizer', 6, 1, 1790173993),
(27, 'miner_deuterium', 'Minero Deuterio VII', 'Sintetizador de deuterio nivel 14', 'building', 'deuterium_sintetizer', 7, 14, 'darkmatter', 400, 'deuterium_sintetizer', 7, 1, 1790173993),
(28, 'miner_deuterium', 'Minero Deuterio VIII', 'Sintetizador de deuterio nivel 16', 'building', 'deuterium_sintetizer', 8, 16, 'darkmatter', 450, 'deuterium_sintetizer', 8, 1, 1790173993),
(29, 'miner_deuterium', 'Minero Deuterio IX', 'Sintetizador de deuterio nivel 18', 'building', 'deuterium_sintetizer', 9, 18, 'darkmatter', 500, 'deuterium_sintetizer', 9, 1, 1790173993),
(30, 'miner_deuterium', 'Minero Deuterio X', 'Sintetizador de deuterio nivel 20', 'building', 'deuterium_sintetizer', 10, 20, 'darkmatter', 550, 'deuterium_sintetizer', 10, 1, 1790173993),
(31, 'energetic', 'Energetico I', 'Planta de energia solar nivel 2', 'building', 'solar_plant', 1, 2, 'darkmatter', 100, 'solar_plant', 1, 1, 1790173993),
(32, 'energetic', 'Energetico II', 'Planta de energia solar nivel 4', 'building', 'solar_plant', 2, 4, 'darkmatter', 150, 'solar_plant', 2, 1, 1790173993),
(33, 'energetic', 'Energetico III', 'Planta de energia solar nivel 6', 'building', 'solar_plant', 3, 6, 'darkmatter', 200, 'solar_plant', 3, 1, 1790173993),
(34, 'energetic', 'Energetico IV', 'Planta de energia solar nivel 8', 'building', 'solar_plant', 4, 8, 'darkmatter', 250, 'solar_plant', 4, 1, 1790173993),
(35, 'energetic', 'Energetico V', 'Planta de energia solar nivel 10', 'building', 'solar_plant', 5, 10, 'darkmatter', 300, 'solar_plant', 5, 1, 1790173993),
(36, 'energetic', 'Energetico VI', 'Planta de energia solar nivel 12', 'building', 'solar_plant', 6, 12, 'darkmatter', 350, 'solar_plant', 6, 1, 1790173993),
(37, 'energetic', 'Energetico VII', 'Planta de energia solar nivel 14', 'building', 'solar_plant', 7, 14, 'darkmatter', 400, 'solar_plant', 7, 1, 1790173993),
(38, 'energetic', 'Energetico VIII', 'Planta de energia solar nivel 16', 'building', 'solar_plant', 8, 16, 'darkmatter', 450, 'solar_plant', 8, 1, 1790173993),
(39, 'energetic', 'Energetico IX', 'Planta de energia solar nivel 18', 'building', 'solar_plant', 9, 18, 'darkmatter', 500, 'solar_plant', 9, 1, 1790173993),
(40, 'energetic', 'Energetico X', 'Planta de energia solar nivel 20', 'building', 'solar_plant', 10, 20, 'darkmatter', 550, 'solar_plant', 10, 1, 1790173993),
(41, 'scientist', 'Cientifico I', 'Laboratorio de investigacion nivel 2', 'building', 'laboratory', 1, 2, 'darkmatter', 100, 'laboratory', 1, 1, 1790173993),
(42, 'scientist', 'Cientifico II', 'Laboratorio de investigacion nivel 4', 'building', 'laboratory', 2, 4, 'darkmatter', 150, 'laboratory', 2, 1, 1790173993),
(43, 'scientist', 'Cientifico III', 'Laboratorio de investigacion nivel 6', 'building', 'laboratory', 3, 6, 'darkmatter', 200, 'laboratory', 3, 1, 1790173993),
(44, 'scientist', 'Cientifico IV', 'Laboratorio de investigacion nivel 8', 'building', 'laboratory', 4, 8, 'darkmatter', 250, 'laboratory', 4, 1, 1790173993),
(45, 'scientist', 'Cientifico V', 'Laboratorio de investigacion nivel 10', 'building', 'laboratory', 5, 10, 'darkmatter', 300, 'laboratory', 5, 1, 1790173993),
(46, 'scientist', 'Cientifico VI', 'Laboratorio de investigacion nivel 12', 'building', 'laboratory', 6, 12, 'darkmatter', 350, 'laboratory', 6, 1, 1790173993),
(47, 'scientist', 'Cientifico VII', 'Laboratorio de investigacion nivel 14', 'building', 'laboratory', 7, 14, 'darkmatter', 400, 'laboratory', 7, 1, 1790173993),
(48, 'scientist', 'Cientifico VIII', 'Laboratorio de investigacion nivel 16', 'building', 'laboratory', 8, 16, 'darkmatter', 450, 'laboratory', 8, 1, 1790173993),
(49, 'scientist', 'Cientifico IX', 'Laboratorio de investigacion nivel 18', 'building', 'laboratory', 9, 18, 'darkmatter', 500, 'laboratory', 9, 1, 1790173993),
(50, 'scientist', 'Cientifico X', 'Laboratorio de investigacion nivel 20', 'building', 'laboratory', 10, 20, 'darkmatter', 550, 'laboratory', 10, 1, 1790173993),
(51, 'spy', 'Espia I', 'Tecnologia de espionaje nivel 2', 'research', 'spy_tech', 1, 2, 'darkmatter', 100, 'spy_tech', 1, 1, 1790173993),
(52, 'spy', 'Espia II', 'Tecnologia de espionaje nivel 4', 'research', 'spy_tech', 2, 4, 'darkmatter', 150, 'spy_tech', 2, 1, 1790173993),
(53, 'spy', 'Espia III', 'Tecnologia de espionaje nivel 6', 'research', 'spy_tech', 3, 6, 'darkmatter', 200, 'spy_tech', 3, 1, 1790173993),
(54, 'spy', 'Espia IV', 'Tecnologia de espionaje nivel 8', 'research', 'spy_tech', 4, 8, 'darkmatter', 250, 'spy_tech', 4, 1, 1790173993),
(55, 'spy', 'Espia V', 'Tecnologia de espionaje nivel 10', 'research', 'spy_tech', 5, 10, 'darkmatter', 300, 'spy_tech', 5, 1, 1790173993),
(56, 'spy', 'Espia VI', 'Tecnologia de espionaje nivel 12', 'research', 'spy_tech', 6, 12, 'darkmatter', 350, 'spy_tech', 6, 1, 1790173993),
(57, 'spy', 'Espia VII', 'Tecnologia de espionaje nivel 14', 'research', 'spy_tech', 7, 14, 'darkmatter', 400, 'spy_tech', 7, 1, 1790173993),
(58, 'spy', 'Espia VIII', 'Tecnologia de espionaje nivel 16', 'research', 'spy_tech', 8, 16, 'darkmatter', 450, 'spy_tech', 8, 1, 1790173993),
(59, 'spy', 'Espia IX', 'Tecnologia de espionaje nivel 18', 'research', 'spy_tech', 9, 18, 'darkmatter', 500, 'spy_tech', 9, 1, 1790173993),
(60, 'spy', 'Espia X', 'Tecnologia de espionaje nivel 20', 'research', 'spy_tech', 10, 20, 'darkmatter', 550, 'spy_tech', 10, 1, 1790173993),
(61, 'defender', 'Mejorando las Defensas I', 'Tecnologia de defensa nivel 2', 'research', 'defence_tech', 1, 2, 'darkmatter', 100, 'defence_tech', 1, 1, 1790173993),
(62, 'defender', 'Mejorando las Defensas II', 'Tecnologia de defensa nivel 4', 'research', 'defence_tech', 2, 4, 'darkmatter', 150, 'defence_tech', 2, 1, 1790173993),
(63, 'defender', 'Mejorando las Defensas III', 'Tecnologia de defensa nivel 6', 'research', 'defence_tech', 3, 6, 'darkmatter', 200, 'defence_tech', 3, 1, 1790173993),
(64, 'defender', 'Mejorando las Defensas IV', 'Tecnologia de defensa nivel 8', 'research', 'defence_tech', 4, 8, 'darkmatter', 250, 'defence_tech', 4, 1, 1790173993),
(65, 'defender', 'Mejorando las Defensas V', 'Tecnologia de defensa nivel 10', 'research', 'defence_tech', 5, 10, 'darkmatter', 300, 'defence_tech', 5, 1, 1790173993),
(66, 'defender', 'Mejorando las Defensas VI', 'Tecnologia de defensa nivel 12', 'research', 'defence_tech', 6, 12, 'darkmatter', 350, 'defence_tech', 6, 1, 1790173993),
(67, 'defender', 'Mejorando las Defensas VII', 'Tecnologia de defensa nivel 14', 'research', 'defence_tech', 7, 14, 'darkmatter', 400, 'defence_tech', 7, 1, 1790173993),
(68, 'defender', 'Mejorando las Defensas VIII', 'Tecnologia de defensa nivel 16', 'research', 'defence_tech', 8, 16, 'darkmatter', 450, 'defence_tech', 8, 1, 1790173993),
(69, 'defender', 'Mejorando las Defensas IX', 'Tecnologia de defensa nivel 18', 'research', 'defence_tech', 9, 18, 'darkmatter', 500, 'defence_tech', 9, 1, 1790173993),
(70, 'defender', 'Mejorando las Defensas X', 'Tecnologia de defensa nivel 20', 'research', 'defence_tech', 10, 20, 'darkmatter', 550, 'defence_tech', 10, 1, 1790173993),
(71, 'shield_master', 'Maestro del Blindaje I', 'Tecnologia de escudo nivel 2', 'research', 'shield_tech', 1, 2, 'darkmatter', 100, 'shield_tech', 1, 1, 1790173993),
(72, 'shield_master', 'Maestro del Blindaje II', 'Tecnologia de escudo nivel 4', 'research', 'shield_tech', 2, 4, 'darkmatter', 150, 'shield_tech', 2, 1, 1790173993),
(73, 'shield_master', 'Maestro del Blindaje III', 'Tecnologia de escudo nivel 6', 'research', 'shield_tech', 3, 6, 'darkmatter', 200, 'shield_tech', 3, 1, 1790173993),
(74, 'shield_master', 'Maestro del Blindaje IV', 'Tecnologia de escudo nivel 8', 'research', 'shield_tech', 4, 8, 'darkmatter', 250, 'shield_tech', 4, 1, 1790173993),
(75, 'shield_master', 'Maestro del Blindaje V', 'Tecnologia de escudo nivel 10', 'research', 'shield_tech', 5, 10, 'darkmatter', 300, 'shield_tech', 5, 1, 1790173993),
(76, 'shield_master', 'Maestro del Blindaje VI', 'Tecnologia de escudo nivel 12', 'research', 'shield_tech', 6, 12, 'darkmatter', 350, 'shield_tech', 6, 1, 1790173993),
(77, 'shield_master', 'Maestro del Blindaje VII', 'Tecnologia de escudo nivel 14', 'research', 'shield_tech', 7, 14, 'darkmatter', 400, 'shield_tech', 7, 1, 1790173993),
(78, 'shield_master', 'Maestro del Blindaje VIII', 'Tecnologia de escudo nivel 16', 'research', 'shield_tech', 8, 16, 'darkmatter', 450, 'shield_tech', 8, 1, 1790173993),
(79, 'shield_master', 'Maestro del Blindaje IX', 'Tecnologia de escudo nivel 18', 'research', 'shield_tech', 9, 18, 'darkmatter', 500, 'shield_tech', 9, 1, 1790173993),
(80, 'shield_master', 'Maestro del Blindaje X', 'Tecnologia de escudo nivel 20', 'research', 'shield_tech', 10, 20, 'darkmatter', 550, 'shield_tech', 10, 1, 1790173993),
(81, 'explorer', 'Explorador I', 'Tecnologia de expedicion nivel 2', 'research', 'expedition_tech', 1, 2, 'darkmatter', 100, 'expedition_tech', 1, 1, 1790173993),
(82, 'explorer', 'Explorador II', 'Tecnologia de expedicion nivel 4', 'research', 'expedition_tech', 2, 4, 'darkmatter', 150, 'expedition_tech', 2, 1, 1790173993),
(83, 'explorer', 'Explorador III', 'Tecnologia de expedicion nivel 6', 'research', 'expedition_tech', 3, 6, 'darkmatter', 200, 'expedition_tech', 3, 1, 1790173993),
(84, 'explorer', 'Explorador IV', 'Tecnologia de expedicion nivel 8', 'research', 'expedition_tech', 4, 8, 'darkmatter', 250, 'expedition_tech', 4, 1, 1790173993),
(85, 'explorer', 'Explorador V', 'Tecnologia de expedicion nivel 10', 'research', 'expedition_tech', 5, 10, 'darkmatter', 300, 'expedition_tech', 5, 1, 1790173993),
(86, 'explorer', 'Explorador VI', 'Tecnologia de expedicion nivel 12', 'research', 'expedition_tech', 6, 12, 'darkmatter', 350, 'expedition_tech', 6, 1, 1790173993),
(87, 'explorer', 'Explorador VII', 'Tecnologia de expedicion nivel 14', 'research', 'expedition_tech', 7, 14, 'darkmatter', 400, 'expedition_tech', 7, 1, 1790173993),
(88, 'explorer', 'Explorador VIII', 'Tecnologia de expedicion nivel 16', 'research', 'expedition_tech', 8, 16, 'darkmatter', 450, 'expedition_tech', 8, 1, 1790173993),
(89, 'explorer', 'Explorador IX', 'Tecnologia de expedicion nivel 18', 'research', 'expedition_tech', 9, 18, 'darkmatter', 500, 'expedition_tech', 9, 1, 1790173993),
(90, 'explorer', 'Explorador X', 'Tecnologia de expedicion nivel 20', 'research', 'expedition_tech', 10, 20, 'darkmatter', 550, 'expedition_tech', 10, 1, 1790173993),
(91, 'phalanx', 'Rastreador Aereo I', 'Sensor Phalanx nivel 2', 'building', 'phalanx', 1, 2, 'darkmatter', 100, 'phalanx', 1, 1, 1790173993),
(92, 'phalanx', 'Rastreador Aereo II', 'Sensor Phalanx nivel 4', 'building', 'phalanx', 2, 4, 'darkmatter', 150, 'phalanx', 2, 1, 1790173993),
(93, 'phalanx', 'Rastreador Aereo III', 'Sensor Phalanx nivel 6', 'building', 'phalanx', 3, 6, 'darkmatter', 200, 'phalanx', 3, 1, 1790173993),
(94, 'phalanx', 'Rastreador Aereo IV', 'Sensor Phalanx nivel 8', 'building', 'phalanx', 4, 8, 'darkmatter', 250, 'phalanx', 4, 1, 1790173993),
(95, 'phalanx', 'Rastreador Aereo V', 'Sensor Phalanx nivel 10', 'building', 'phalanx', 5, 10, 'darkmatter', 300, 'phalanx', 5, 1, 1790173993),
(96, 'phalanx', 'Rastreador Aereo VI', 'Sensor Phalanx nivel 12', 'building', 'phalanx', 6, 12, 'darkmatter', 350, 'phalanx', 6, 1, 1790173993),
(97, 'phalanx', 'Rastreador Aereo VII', 'Sensor Phalanx nivel 14', 'building', 'phalanx', 7, 14, 'darkmatter', 400, 'phalanx', 7, 1, 1790173993),
(98, 'phalanx', 'Rastreador Aereo VIII', 'Sensor Phalanx nivel 16', 'building', 'phalanx', 8, 16, 'darkmatter', 450, 'phalanx', 8, 1, 1790173993),
(99, 'phalanx', 'Rastreador Aereo IX', 'Sensor Phalanx nivel 18', 'building', 'phalanx', 9, 18, 'darkmatter', 500, 'phalanx', 9, 1, 1790173993),
(100, 'phalanx', 'Rastreador Aereo X', 'Sensor Phalanx nivel 20', 'building', 'phalanx', 10, 20, 'darkmatter', 550, 'phalanx', 10, 1, 1790173993),
(101, 'computer_master', 'Maestro del Espionaje I', 'Tecnologia de computacion nivel 2', 'research', 'computer_tech', 1, 2, 'darkmatter', 100, 'computer_tech', 1, 1, 1790173993),
(102, 'computer_master', 'Maestro del Espionaje II', 'Tecnologia de computacion nivel 4', 'research', 'computer_tech', 2, 4, 'darkmatter', 150, 'computer_tech', 2, 1, 1790173993),
(103, 'computer_master', 'Maestro del Espionaje III', 'Tecnologia de computacion nivel 6', 'research', 'computer_tech', 3, 6, 'darkmatter', 200, 'computer_tech', 3, 1, 1790173993),
(104, 'computer_master', 'Maestro del Espionaje IV', 'Tecnologia de computacion nivel 8', 'research', 'computer_tech', 4, 8, 'darkmatter', 250, 'computer_tech', 4, 1, 1790173993),
(105, 'computer_master', 'Maestro del Espionaje V', 'Tecnologia de computacion nivel 10', 'research', 'computer_tech', 5, 10, 'darkmatter', 300, 'computer_tech', 5, 1, 1790173993),
(106, 'computer_master', 'Maestro del Espionaje VI', 'Tecnologia de computacion nivel 12', 'research', 'computer_tech', 6, 12, 'darkmatter', 350, 'computer_tech', 6, 1, 1790173993),
(107, 'computer_master', 'Maestro del Espionaje VII', 'Tecnologia de computacion nivel 14', 'research', 'computer_tech', 7, 14, 'darkmatter', 400, 'computer_tech', 7, 1, 1790173993),
(108, 'computer_master', 'Maestro del Espionaje VIII', 'Tecnologia de computacion nivel 16', 'research', 'computer_tech', 8, 16, 'darkmatter', 450, 'computer_tech', 8, 1, 1790173993),
(109, 'computer_master', 'Maestro del Espionaje IX', 'Tecnologia de computacion nivel 18', 'research', 'computer_tech', 9, 18, 'darkmatter', 500, 'computer_tech', 9, 1, 1790173993),
(110, 'computer_master', 'Maestro del Espionaje X', 'Tecnologia de computacion nivel 20', 'research', 'computer_tech', 10, 20, 'darkmatter', 550, 'computer_tech', 10, 1, 1790173993),
(111, 'fleet_builder', 'Ampliando tus Flotas I', 'Hangar nivel 2', 'building', 'hangar', 1, 2, 'darkmatter', 100, 'hangar', 1, 1, 1790173993),
(112, 'fleet_builder', 'Ampliando tus Flotas II', 'Hangar nivel 4', 'building', 'hangar', 2, 4, 'darkmatter', 150, 'hangar', 2, 1, 1790173993),
(113, 'fleet_builder', 'Ampliando tus Flotas III', 'Hangar nivel 6', 'building', 'hangar', 3, 6, 'darkmatter', 200, 'hangar', 3, 1, 1790173993),
(114, 'fleet_builder', 'Ampliando tus Flotas IV', 'Hangar nivel 8', 'building', 'hangar', 4, 8, 'darkmatter', 250, 'hangar', 4, 1, 1790173993),
(115, 'fleet_builder', 'Ampliando tus Flotas V', 'Hangar nivel 10', 'building', 'hangar', 5, 10, 'darkmatter', 300, 'hangar', 5, 1, 1790173993),
(116, 'fleet_builder', 'Ampliando tus Flotas VI', 'Hangar nivel 12', 'building', 'hangar', 6, 12, 'darkmatter', 350, 'hangar', 6, 1, 1790173993),
(117, 'fleet_builder', 'Ampliando tus Flotas VII', 'Hangar nivel 14', 'building', 'hangar', 7, 14, 'darkmatter', 400, 'hangar', 7, 1, 1790173993),
(118, 'fleet_builder', 'Ampliando tus Flotas VIII', 'Hangar nivel 16', 'building', 'hangar', 8, 16, 'darkmatter', 450, 'hangar', 8, 1, 1790173993),
(119, 'fleet_builder', 'Ampliando tus Flotas IX', 'Hangar nivel 18', 'building', 'hangar', 9, 18, 'darkmatter', 500, 'hangar', 9, 1, 1790173993),
(120, 'fleet_builder', 'Ampliando tus Flotas X', 'Hangar nivel 20', 'building', 'hangar', 10, 20, 'darkmatter', 550, 'hangar', 10, 1, 1790173993);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_achievements_log`
--

CREATE TABLE `uni1_achievements_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `level` tinyint(2) NOT NULL DEFAULT 1,
  `action` varchar(50) NOT NULL,
  `detalle` text DEFAULT NULL,
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_admin_bank_accounts`
--

CREATE TABLE `uni1_admin_bank_accounts` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `saldo` decimal(15,2) NOT NULL DEFAULT 0.00,
  `marca_proyecto` decimal(15,2) NOT NULL DEFAULT 0.00,
  `fecha_creacion` int(11) NOT NULL,
  `ultima_actualizacion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_admin_bank_data`
--

CREATE TABLE `uni1_admin_bank_data` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `tarjeta_magnetica` varchar(50) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  `titular` varchar(100) DEFAULT NULL,
  `banco` varchar(100) DEFAULT NULL,
  `fecha_registro` int(11) NOT NULL,
  `fecha_actualizacion` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_admin_bank_movements`
--

CREATE TABLE `uni1_admin_bank_movements` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `tipo` enum('inversion','retiro','transferencia_enviada','transferencia_recibida','retiro_proyecto','ajuste_manual','transferencia_cancelada') NOT NULL,
  `monto` decimal(15,2) NOT NULL,
  `saldo_resultante` decimal(15,2) NOT NULL,
  `admin_relacionado` int(11) DEFAULT NULL,
  `referencia_id` int(11) DEFAULT NULL,
  `detalle` varchar(255) DEFAULT NULL,
  `fecha` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_admin_bank_transfers`
--

CREATE TABLE `uni1_admin_bank_transfers` (
  `id` int(11) NOT NULL,
  `from_admin_id` int(11) NOT NULL,
  `to_admin_id` int(11) NOT NULL,
  `monto` decimal(15,2) NOT NULL,
  `estado` enum('pendiente','aceptada','rechazada','expirada','cancelada') NOT NULL DEFAULT 'pendiente',
  `fecha_creacion` int(11) NOT NULL,
  `fecha_resolucion` int(11) DEFAULT NULL,
  `fecha_expiracion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_aks`
--

CREATE TABLE `uni1_aks` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `target` int(11) UNSIGNED NOT NULL,
  `ankunft` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance`
--

CREATE TABLE `uni1_alliance` (
  `id` int(11) UNSIGNED NOT NULL,
  `ally_name` varchar(50) DEFAULT '',
  `ally_tag` varchar(20) DEFAULT '',
  `ally_owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `ally_register_time` int(11) NOT NULL DEFAULT 0,
  `ally_description` text DEFAULT NULL,
  `ally_web` varchar(255) DEFAULT '',
  `ally_text` text DEFAULT NULL,
  `ally_image` varchar(255) DEFAULT '',
  `ally_request` varchar(1000) DEFAULT NULL,
  `ally_request_notallow` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `ally_request_min_points` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `ally_owner_range` varchar(32) DEFAULT '',
  `ally_members` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ally_stats` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `ally_diplo` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `ally_universe` tinyint(3) UNSIGNED NOT NULL,
  `ally_max_members` int(5) UNSIGNED NOT NULL DEFAULT 20,
  `ally_events` varchar(55) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_bank`
--

CREATE TABLE `uni1_alliance_bank` (
  `id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL,
  `metal` bigint(20) NOT NULL DEFAULT 0,
  `crystal` bigint(20) NOT NULL DEFAULT 0,
  `deuterium` bigint(20) NOT NULL DEFAULT 0,
  `darkmatter` bigint(20) NOT NULL DEFAULT 0,
  `ntx20` bigint(20) NOT NULL DEFAULT 0,
  `level` tinyint(3) NOT NULL DEFAULT 0,
  `daily_limit` bigint(20) NOT NULL DEFAULT 0,
  `tesorero_id` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_bank_bonuses`
--

CREATE TABLE `uni1_alliance_bank_bonuses` (
  `id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL,
  `hito` tinyint(3) NOT NULL,
  `tipo` enum('production','attack','defense','speed') NOT NULL DEFAULT 'production',
  `nivel_desbloqueo` tinyint(3) NOT NULL DEFAULT 0,
  `veces_cambiado` int(11) NOT NULL DEFAULT 0,
  `fecha_asignado` int(11) NOT NULL DEFAULT 0,
  `fecha_cambio` int(11) NOT NULL DEFAULT 0,
  `changed_by` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_bank_daily`
--

CREATE TABLE `uni1_alliance_bank_daily` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `total_retirado` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_bank_log`
--

CREATE TABLE `uni1_alliance_bank_log` (
  `id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `accion` enum('deposit','withdraw','upgrade','bonus_set','bonus_change','tesorero_change','dissolve','admin') NOT NULL,
  `recurso` enum('metal','crystal','deuterium','darkmatter','ntx20','none') NOT NULL DEFAULT 'none',
  `cantidad` bigint(20) NOT NULL DEFAULT 0,
  `balance_after` bigint(20) NOT NULL DEFAULT 0,
  `motivo` varchar(255) NOT NULL DEFAULT '',
  `ip` varchar(45) NOT NULL DEFAULT '',
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_bank_tesorero_log`
--

CREATE TABLE `uni1_alliance_bank_tesorero_log` (
  `id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL,
  `old_tesorero` int(11) NOT NULL DEFAULT 0,
  `new_tesorero` int(11) NOT NULL DEFAULT 0,
  `changed_by` int(11) NOT NULL DEFAULT 0,
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_ranks`
--

CREATE TABLE `uni1_alliance_ranks` (
  `rankID` int(11) NOT NULL,
  `rankName` varchar(32) NOT NULL,
  `allianceID` int(10) UNSIGNED NOT NULL,
  `MEMBERLIST` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ONLINESTATE` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `TRANSFER` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `SEEAPPLY` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `MANAGEAPPLY` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ROUNDMAIL` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ADMIN` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `KICK` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `DIPLOMATIC` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `RANKS` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `MANAGEUSERS` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `EVENTS` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_request`
--

CREATE TABLE `uni1_alliance_request` (
  `applyID` int(10) UNSIGNED NOT NULL,
  `text` text NOT NULL,
  `userID` int(10) UNSIGNED NOT NULL,
  `allianceID` int(10) UNSIGNED NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_talent_log`
--

CREATE TABLE `uni1_alliance_talent_log` (
  `id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `action` varchar(30) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `detail` varchar(255) DEFAULT NULL,
  `log_time` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_talent_points`
--

CREATE TABLE `uni1_alliance_talent_points` (
  `alliance_id` int(11) NOT NULL,
  `total_points` bigint(20) NOT NULL DEFAULT 0,
  `spent_points` int(11) NOT NULL DEFAULT 0,
  `current_rank` tinyint(2) NOT NULL DEFAULT 0,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_alliance_talent_ranks`
--

CREATE TABLE `uni1_alliance_talent_ranks` (
  `id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL,
  `rank_num` tinyint(2) NOT NULL,
  `talent_key` varchar(40) NOT NULL,
  `chosen_at` int(11) NOT NULL DEFAULT 0,
  `chosen_by` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_asteroids`
--

CREATE TABLE `uni1_asteroids` (
  `id` int(11) NOT NULL,
  `galaxy` int(11) NOT NULL,
  `system` int(11) NOT NULL,
  `planet` int(11) NOT NULL,
  `type` enum('metal','crystal','deuterium','container') NOT NULL,
  `amount` bigint(20) NOT NULL DEFAULT 0,
  `chest_rarity` varchar(20) DEFAULT NULL,
  `spawn_time` int(11) NOT NULL,
  `recycled` tinyint(1) NOT NULL DEFAULT 0,
  `recycled_by` int(11) NOT NULL DEFAULT 0,
  `recycled_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_banned`
--

CREATE TABLE `uni1_banned` (
  `id` int(11) UNSIGNED NOT NULL,
  `who` varchar(64) NOT NULL DEFAULT '',
  `theme` varchar(500) NOT NULL,
  `time` int(11) NOT NULL DEFAULT 0,
  `longer` int(11) NOT NULL DEFAULT 0,
  `author` varchar(64) NOT NULL DEFAULT '',
  `email` varchar(64) NOT NULL DEFAULT '',
  `universe` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_boosters`
--

CREATE TABLE `uni1_boosters` (
  `booster_id` int(11) NOT NULL,
  `booster_name` varchar(80) NOT NULL,
  `booster_desc` text NOT NULL,
  `booster_icon` varchar(20) NOT NULL,
  `booster_color` varchar(10) NOT NULL DEFAULT '#00ccff',
  `booster_type` varchar(30) NOT NULL,
  `booster_value` decimal(6,2) NOT NULL DEFAULT 0.00,
  `booster_duration` int(11) NOT NULL DEFAULT 86400
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_boosters`
--

INSERT INTO `uni1_boosters` (`booster_id`, `booster_name`, `booster_desc`, `booster_icon`, `booster_color`, `booster_type`, `booster_value`, `booster_duration`) VALUES
(8, 'Pot. Hangar', 'Reduce el tiempo de construcción de naves en un 20%.', 'HNG', '#66ff99', 'ship_time', -20.00, 86400),
(7, 'Pot. Investigaciones', 'Aumenta los Slots de Investigación.', 'TEC', '#aa44ff', 'research_slots', 2.00, 86400),
(6, 'Pot. Estructuras', 'Aumenta los Droides Constructores.', 'BLD', '#00ccff', 'droids_builder', 1.00, 86400),
(9, 'Pot. Materia Oscura', 'Aumenta la MO en expediciones.', 'MO', '#ffcc00', 'exp_darkmatter', 20.00, 86400),
(10, 'Pot. Minero', 'Aumenta la Producción de Recursos.', 'PRO', '#ffaa33', 'resources', 20.00, 86400),
(11, 'Pot. Espía', 'Aumenta el Poder de Espionaje.', 'SPY', '#ff4444', 'spy_power', 20.00, 86400),
(12, 'Pot. Energía', 'Aumenta la Producción de Energía.', 'ENE', '#ffdd33', 'energy', 20.00, 86400),
(13, 'Pot. Expediciones', 'Bonus de recursos obtenidos en expediciones', 'EXP', '#00ccff', 'exp_resources', 20.00, 86400),
(14, 'Bonus VIP Semanal', 'Bonus de producción VIP Semanal (+3%)', 'VIP', '#ffd700', 'vip_production', 3.00, 86400),
(15, 'Bonus VIP Quincenal', 'Bonus de producción VIP Quincenal (+4%)', 'VIP', '#ffd700', 'vip_production', 4.00, 86400),
(16, 'Bonus VIP Mensual', 'Bonus de producción VIP Mensual (+5%)', 'VIP', '#ffd700', 'vip_production', 5.00, 86400);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_bp_config`
--

CREATE TABLE `uni1_bp_config` (
  `id` int(11) NOT NULL,
  `last_reset` int(11) NOT NULL,
  `season_name` varchar(100) NOT NULL DEFAULT 'Temporada 1',
  `bp_fallback_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `bp_fallback_mode` varchar(10) NOT NULL DEFAULT 'best',
  `bp_fallback_factor` decimal(3,2) NOT NULL DEFAULT 1.00,
  `bp_fallback_round` varchar(5) NOT NULL DEFAULT 'up',
  `bp_fallback_none` varchar(10) NOT NULL DEFAULT 'res'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_bp_config`
--

INSERT INTO `uni1_bp_config` (`id`, `last_reset`, `season_name`, `bp_fallback_enabled`, `bp_fallback_mode`, `bp_fallback_factor`, `bp_fallback_round`, `bp_fallback_none`) VALUES
(1, 1791562864, 'Temporada 2', 1, 'best', 1.00, 'up', 'res');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_bp_log`
--

CREATE TABLE `uni1_bp_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `coins` int(11) NOT NULL,
  `source` varchar(255) NOT NULL,
  `fecha` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_bp_users`
--

CREATE TABLE `uni1_bp_users` (
  `user_id` int(11) NOT NULL,
  `current_level` int(11) NOT NULL DEFAULT 0,
  `current_coins` int(11) NOT NULL DEFAULT 0,
  `total_coins` int(11) NOT NULL DEFAULT 0,
  `claimed_normal` text NOT NULL,
  `claimed_vip` text NOT NULL,
  `levels_data` text NOT NULL,
  `last_update` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_buddy`
--

CREATE TABLE `uni1_buddy` (
  `id` int(11) UNSIGNED NOT NULL,
  `sender` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `universe` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_buddy_request`
--

CREATE TABLE `uni1_buddy_request` (
  `id` int(11) UNSIGNED NOT NULL,
  `text` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_bug_categories`
--

CREATE TABLE `uni1_bug_categories` (
  `id` int(11) NOT NULL,
  `clave` varchar(50) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `icono` varchar(10) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `orden` int(11) DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_bug_categories`
--

INSERT INTO `uni1_bug_categories` (`id`, `clave`, `nombre`, `icono`, `activo`, `orden`) VALUES
(13, 'edificios', 'Edificios', 'building', 1, 1),
(14, 'investigacion', 'Investigación', 'flask', 1, 2),
(15, 'hangar', 'Hangar', 'rocket', 1, 3),
(16, 'defensas', 'Defensas', 'shield', 1, 4),
(17, 'oficiales', 'Oficiales', 'user', 1, 5),
(18, 'mercader', 'Mercader', 'money', 1, 6),
(19, 'base_flota', 'Base de Flota', 'anchor', 1, 7),
(20, 'recursos', 'Recursos', 'box', 1, 8),
(21, 'galaxia', 'Galaxia', 'globe', 1, 9),
(22, 'alianza', 'Alianza', 'castle', 1, 10),
(23, 'mop', 'MOP', 'gear', 1, 11),
(24, 'otros', 'Otros', 'note', 1, 12);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_bug_log`
--

CREATE TABLE `uni1_bug_log` (
  `id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `accion` varchar(50) NOT NULL,
  `detalle` text DEFAULT NULL,
  `ip` varchar(40) DEFAULT NULL,
  `fecha` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_bug_reports`
--

CREATE TABLE `uni1_bug_reports` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `categoria` varchar(50) NOT NULL,
  `descripcion` text NOT NULL,
  `pasos_reproducir` text DEFAULT NULL,
  `prioridad` enum('baja','media','alta','critica') DEFAULT 'media',
  `estado` enum('pendiente','aceptado','solucionado_pendiente_update','solucionado','cancelado','borrado') DEFAULT 'pendiente',
  `admin_id` int(11) DEFAULT NULL,
  `respuesta_admin` text DEFAULT NULL,
  `motivo_cancelacion` text DEFAULT NULL,
  `recompensa_dada` int(11) DEFAULT 0,
  `recompensa_tipo` varchar(20) DEFAULT NULL,
  `fecha_creacion` int(11) NOT NULL,
  `fecha_asignacion` int(11) DEFAULT NULL,
  `fecha_solucion_pendiente` int(11) DEFAULT NULL,
  `fecha_solucion` int(11) DEFAULT NULL,
  `fecha_cancelacion` int(11) DEFAULT NULL,
  `fecha_borrado` int(11) DEFAULT NULL,
  `eliminada` tinyint(1) DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_chat_bans`
--

CREATE TABLE `uni1_chat_bans` (
  `userID` int(11) NOT NULL,
  `userName` varchar(64) NOT NULL,
  `dateTime` datetime NOT NULL,
  `ip` varbinary(16) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_chat_invitations`
--

CREATE TABLE `uni1_chat_invitations` (
  `userID` int(11) NOT NULL,
  `channel` int(11) NOT NULL,
  `dateTime` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_chat_messages`
--

CREATE TABLE `uni1_chat_messages` (
  `id` int(11) NOT NULL,
  `userID` int(11) NOT NULL,
  `userName` varchar(64) NOT NULL,
  `userRole` int(1) NOT NULL,
  `channel` int(11) NOT NULL,
  `dateTime` datetime NOT NULL,
  `ip` varbinary(16) NOT NULL,
  `text` text CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_chat_online`
--

CREATE TABLE `uni1_chat_online` (
  `userID` int(11) NOT NULL,
  `userName` varchar(64) NOT NULL,
  `userRole` int(1) NOT NULL,
  `channel` int(11) NOT NULL,
  `dateTime` datetime NOT NULL,
  `ip` varbinary(16) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_config`
--

CREATE TABLE `uni1_config` (
  `uni` int(11) NOT NULL,
  `VERSION` varchar(8) NOT NULL,
  `sql_revision` int(11) NOT NULL DEFAULT 0,
  `users_amount` int(11) UNSIGNED NOT NULL DEFAULT 1,
  `game_speed` double(255,0) UNSIGNED NOT NULL DEFAULT 2500,
  `fleet_speed` double(255,0) UNSIGNED NOT NULL DEFAULT 2500,
  `resource_multiplier` double(255,0) UNSIGNED NOT NULL DEFAULT 1,
  `storage_multiplier` double(255,0) UNSIGNED NOT NULL DEFAULT 1,
  `message_delete_behavior` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `message_delete_days` tinyint(3) UNSIGNED NOT NULL DEFAULT 7,
  `halt_speed` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `Fleet_Cdr` tinyint(3) UNSIGNED NOT NULL DEFAULT 30,
  `Defs_Cdr` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `initial_fields` smallint(5) UNSIGNED NOT NULL DEFAULT 163,
  `uni_name` varchar(30) NOT NULL,
  `game_name` varchar(30) NOT NULL,
  `game_disable` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `close_reason` text NOT NULL,
  `metal_basic_income` double(255,0) NOT NULL DEFAULT 20,
  `crystal_basic_income` double(255,0) NOT NULL DEFAULT 10,
  `deuterium_basic_income` double(255,0) NOT NULL DEFAULT 0,
  `energy_basic_income` double(255,0) NOT NULL DEFAULT 0,
  `LastSettedGalaxyPos` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `LastSettedSystemPos` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `LastSettedPlanetPos` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `noobprotection` int(11) NOT NULL DEFAULT 0,
  `noobprotectiontime` int(11) NOT NULL DEFAULT 5000,
  `noobprotectionmulti` int(11) NOT NULL DEFAULT 5,
  `forum_url` varchar(128) NOT NULL DEFAULT 'http://2moons.de',
  `adm_attack` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `debug` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `lang` varchar(2) NOT NULL DEFAULT '',
  `stat` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `stat_level` tinyint(3) UNSIGNED NOT NULL DEFAULT 2,
  `stat_last_update` int(11) NOT NULL DEFAULT 0,
  `stat_settings` int(11) UNSIGNED NOT NULL DEFAULT 1000,
  `stat_update_time` tinyint(3) UNSIGNED NOT NULL DEFAULT 25,
  `stat_last_db_update` int(11) NOT NULL DEFAULT 0,
  `stats_fly_lock` int(11) NOT NULL DEFAULT 0,
  `cron_lock` int(11) NOT NULL DEFAULT 0,
  `ts_modon` tinyint(1) NOT NULL DEFAULT 0,
  `ts_server` varchar(64) NOT NULL DEFAULT '',
  `ts_tcpport` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `ts_udpport` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `ts_timeout` tinyint(1) NOT NULL DEFAULT 1,
  `ts_version` tinyint(1) NOT NULL DEFAULT 2,
  `ts_cron_last` int(11) NOT NULL DEFAULT 0,
  `ts_cron_interval` smallint(5) NOT NULL DEFAULT 5,
  `ts_login` varchar(32) NOT NULL DEFAULT '',
  `ts_password` varchar(32) NOT NULL DEFAULT '',
  `reg_closed` tinyint(1) NOT NULL DEFAULT 0,
  `OverviewNewsFrame` tinyint(1) NOT NULL DEFAULT 1,
  `OverviewNewsText` text NOT NULL,
  `capaktiv` tinyint(1) NOT NULL DEFAULT 0,
  `cappublic` varchar(42) NOT NULL DEFAULT '',
  `capprivate` varchar(42) NOT NULL DEFAULT '',
  `min_build_time` tinyint(2) NOT NULL DEFAULT 1,
  `mail_active` tinyint(1) NOT NULL DEFAULT 0,
  `mail_use` tinyint(1) NOT NULL DEFAULT 0,
  `smtp_host` varchar(64) NOT NULL DEFAULT '',
  `smtp_port` smallint(5) NOT NULL DEFAULT 0,
  `smtp_user` varchar(64) NOT NULL DEFAULT '',
  `smtp_pass` varchar(32) NOT NULL DEFAULT '',
  `smtp_ssl` enum('','ssl','tls') NOT NULL DEFAULT '',
  `smtp_sendmail` varchar(64) NOT NULL DEFAULT '',
  `smail_path` varchar(30) NOT NULL DEFAULT '/usr/sbin/sendmail',
  `user_valid` tinyint(1) NOT NULL DEFAULT 0,
  `fb_on` tinyint(1) NOT NULL DEFAULT 0,
  `fb_apikey` varchar(42) NOT NULL DEFAULT '',
  `fb_skey` varchar(42) NOT NULL DEFAULT '',
  `ga_active` varchar(42) NOT NULL DEFAULT '0',
  `ga_key` varchar(42) NOT NULL DEFAULT '',
  `moduls` varchar(255) NOT NULL DEFAULT '',
  `trade_allowed_ships` varchar(255) NOT NULL DEFAULT '202,401',
  `trade_charge` varchar(5) NOT NULL DEFAULT '30',
  `chat_closed` tinyint(1) NOT NULL DEFAULT 0,
  `chat_retention_minutes` int(10) UNSIGNED NOT NULL DEFAULT 60,
  `chat_allowchan` tinyint(1) NOT NULL DEFAULT 1,
  `chat_allowmes` tinyint(1) NOT NULL DEFAULT 1,
  `chat_allowdelmes` tinyint(1) NOT NULL DEFAULT 1,
  `chat_logmessage` tinyint(1) NOT NULL DEFAULT 1,
  `chat_nickchange` tinyint(1) NOT NULL DEFAULT 1,
  `chat_botname` varchar(15) NOT NULL DEFAULT '2Moons2.0',
  `chat_channelname` varchar(15) NOT NULL DEFAULT '2Moons2.0',
  `chat_socket_active` tinyint(1) NOT NULL DEFAULT 0,
  `chat_socket_host` varchar(64) NOT NULL DEFAULT '',
  `chat_socket_ip` varchar(40) NOT NULL DEFAULT '',
  `chat_socket_port` smallint(5) NOT NULL DEFAULT 0,
  `chat_socket_chatid` tinyint(1) NOT NULL DEFAULT 1,
  `max_galaxy` tinyint(3) UNSIGNED NOT NULL DEFAULT 9,
  `max_system` smallint(5) UNSIGNED NOT NULL DEFAULT 400,
  `max_planets` tinyint(3) UNSIGNED NOT NULL DEFAULT 15,
  `planet_factor` float(2,1) NOT NULL DEFAULT 1.0,
  `max_elements_build` tinyint(3) UNSIGNED NOT NULL DEFAULT 5,
  `max_elements_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 2,
  `max_elements_ships` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `min_player_planets` tinyint(3) UNSIGNED NOT NULL DEFAULT 9,
  `planets_tech` tinyint(4) NOT NULL DEFAULT 11,
  `planets_officier` tinyint(4) NOT NULL DEFAULT 5,
  `planets_per_tech` float(2,1) NOT NULL DEFAULT 0.5,
  `max_fleet_per_build` double(255,0) UNSIGNED NOT NULL DEFAULT 10000000000,
  `deuterium_cost_galaxy` int(11) UNSIGNED NOT NULL DEFAULT 10,
  `max_dm_missions` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `max_overflow` float(2,1) NOT NULL DEFAULT 1.0,
  `moon_factor` float(2,1) NOT NULL DEFAULT 1.0,
  `moon_chance` tinyint(3) UNSIGNED NOT NULL DEFAULT 20,
  `darkmatter_cost_trader` int(11) UNSIGNED NOT NULL DEFAULT 750,
  `factor_university` tinyint(3) UNSIGNED NOT NULL DEFAULT 8,
  `max_fleets_per_acs` tinyint(3) UNSIGNED NOT NULL DEFAULT 16,
  `debris_moon` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `vmode_min_time` int(11) NOT NULL DEFAULT 172800,
  `gate_wait_time` int(11) NOT NULL DEFAULT 3600,
  `metal_start` double(255,0) UNSIGNED NOT NULL DEFAULT 500,
  `crystal_start` double(255,0) UNSIGNED NOT NULL DEFAULT 500,
  `deuterium_start` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `darkmatter_start` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `ttf_file` varchar(128) NOT NULL DEFAULT 'styles/resource/fonts/DroidSansMono.ttf',
  `ref_active` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `ref_bonus` int(11) UNSIGNED NOT NULL DEFAULT 1000,
  `ref_minpoints` bigint(20) UNSIGNED NOT NULL DEFAULT 2000,
  `ref_max_referals` tinyint(1) UNSIGNED NOT NULL DEFAULT 5,
  `del_oldstuff` tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  `del_user_manually` tinyint(3) UNSIGNED NOT NULL DEFAULT 7,
  `del_user_automatic` tinyint(3) UNSIGNED NOT NULL DEFAULT 30,
  `del_user_sendmail` tinyint(3) UNSIGNED NOT NULL DEFAULT 21,
  `sendmail_inactive` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `silo_factor` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `timezone` varchar(32) NOT NULL DEFAULT 'Europe/London',
  `dst` enum('0','1','2') NOT NULL DEFAULT '2',
  `energySpeed` smallint(6) NOT NULL DEFAULT 1,
  `disclamerAddress` text NOT NULL,
  `disclamerPhone` text NOT NULL,
  `disclamerMail` text NOT NULL,
  `disclamerNotice` text NOT NULL,
  `alliance_create_min_points` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `expedition_limit_res_active` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `expedition_limit_res` double(255,0) UNSIGNED NOT NULL DEFAULT 1000000,
  `discord_on` tinyint(1) NOT NULL DEFAULT 0,
  `discord_apikey` varchar(64) NOT NULL DEFAULT '',
  `discord_skey` varchar(128) NOT NULL DEFAULT '',
  `ntx20_log_retention_months` int(2) NOT NULL DEFAULT 3,
  `tourneyEnd` int(11) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_config`
--

INSERT INTO `uni1_config` (`uni`, `VERSION`, `sql_revision`, `users_amount`, `game_speed`, `fleet_speed`, `resource_multiplier`, `storage_multiplier`, `message_delete_behavior`, `message_delete_days`, `halt_speed`, `Fleet_Cdr`, `Defs_Cdr`, `initial_fields`, `uni_name`, `game_name`, `game_disable`, `close_reason`, `metal_basic_income`, `crystal_basic_income`, `deuterium_basic_income`, `energy_basic_income`, `LastSettedGalaxyPos`, `LastSettedSystemPos`, `LastSettedPlanetPos`, `noobprotection`, `noobprotectiontime`, `noobprotectionmulti`, `forum_url`, `adm_attack`, `debug`, `lang`, `stat`, `stat_level`, `stat_last_update`, `stat_settings`, `stat_update_time`, `stat_last_db_update`, `stats_fly_lock`, `cron_lock`, `ts_modon`, `ts_server`, `ts_tcpport`, `ts_udpport`, `ts_timeout`, `ts_version`, `ts_cron_last`, `ts_cron_interval`, `ts_login`, `ts_password`, `reg_closed`, `OverviewNewsFrame`, `OverviewNewsText`, `capaktiv`, `cappublic`, `capprivate`, `min_build_time`, `mail_active`, `mail_use`, `smtp_host`, `smtp_port`, `smtp_user`, `smtp_pass`, `smtp_ssl`, `smtp_sendmail`, `smail_path`, `user_valid`, `fb_on`, `fb_apikey`, `fb_skey`, `ga_active`, `ga_key`, `moduls`, `trade_allowed_ships`, `trade_charge`, `chat_closed`, `chat_retention_minutes`, `chat_allowchan`, `chat_allowmes`, `chat_allowdelmes`, `chat_logmessage`, `chat_nickchange`, `chat_botname`, `chat_channelname`, `chat_socket_active`, `chat_socket_host`, `chat_socket_ip`, `chat_socket_port`, `chat_socket_chatid`, `max_galaxy`, `max_system`, `max_planets`, `planet_factor`, `max_elements_build`, `max_elements_tech`, `max_elements_ships`, `min_player_planets`, `planets_tech`, `planets_officier`, `planets_per_tech`, `max_fleet_per_build`, `deuterium_cost_galaxy`, `max_dm_missions`, `max_overflow`, `moon_factor`, `moon_chance`, `darkmatter_cost_trader`, `factor_university`, `max_fleets_per_acs`, `debris_moon`, `vmode_min_time`, `gate_wait_time`, `metal_start`, `crystal_start`, `deuterium_start`, `darkmatter_start`, `ttf_file`, `ref_active`, `ref_bonus`, `ref_minpoints`, `ref_max_referals`, `del_oldstuff`, `del_user_manually`, `del_user_automatic`, `del_user_sendmail`, `sendmail_inactive`, `silo_factor`, `timezone`, `dst`, `energySpeed`, `disclamerAddress`, `disclamerPhone`, `disclamerMail`, `disclamerNotice`, `alliance_create_min_points`, `expedition_limit_res_active`, `expedition_limit_res`, `discord_on`, `discord_apikey`, `discord_skey`, `ntx20_log_retention_months`, `tourneyEnd`) VALUES
(1, '2.0.git', 0, 1, 7500, 12500, 3, 2, 0, 7, 3, 30, 0, 250, 'Andrómeda', 'AstroIO', 0, '', 20, 10, 0, 0, 1, 35, 3, 1, 5000, 5, '', 0, 0, 'es', 0, 2, 0, 1000, 25, 1792233901, 0, 0, 0, '', 0, 0, 1, 2, 0, 5, '', '', 0, 1, 'Bienvenido a AstroIO 2.2.3, Comandante nos alegra tenerte nuevamente con nosotros. Una nueva aventura está por comenzar, con nuevas oportunidades, desafíos y conquistas por descubrir. Forma tu imperio, fortalece tu flota y prepárate para dominar la galaxia.', 0, '', '', 1, 1, 2, 'smtp.gmail.com', 587, '', '', 'tls', '', '/usr/sbin/sendmail', 1, 0, '', '', '0', '', '1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1', '202,401', '30', 0, 1440, 1, 1, 0, 1, 0, 'Ahsoka_Tano', 'AstroIO', 0, '', '', 0, 1, 5, 400, 15, 1.0, 3, 2, 10, 9, 11, 5, 0.5, 10000000000, 75, 1, 1.0, 1.0, 20, 750, 8, 16, 0, 172800, 3600, 10000, 6000, 1000, 0, 'styles/resource/fonts/DroidSansMono.ttf', 0, 1000, 2000, 5, 3, 7, 30, 21, 0, 1, 'America/Havana', '0', 3, '', '', '', '', 100, 0, 1000000, 1, '', '', 3, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_container_history`
--

CREATE TABLE `uni1_container_history` (
  `history_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `loot_id` int(11) NOT NULL,
  `loot_value` int(11) NOT NULL DEFAULT 0,
  `opened_at` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_container_loot`
--

CREATE TABLE `uni1_container_loot` (
  `loot_id` int(11) NOT NULL,
  `loot_name` varchar(50) NOT NULL,
  `loot_icon` varchar(10) NOT NULL,
  `loot_rarity` varchar(20) NOT NULL,
  `loot_chance` decimal(5,2) NOT NULL,
  `loot_type` varchar(20) NOT NULL,
  `loot_value_min` int(11) NOT NULL DEFAULT 0,
  `loot_value_max` int(11) NOT NULL DEFAULT 0,
  `loot_extra_id` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_container_loot`
--

INSERT INTO `uni1_container_loot` (`loot_id`, `loot_name`, `loot_icon`, `loot_rarity`, `loot_chance`, `loot_type`, `loot_value_min`, `loot_value_max`, `loot_extra_id`) VALUES
(1, 'Metal', 'M', 'common', 23.30, 'metal', 1000, 5000, 0),
(2, 'Cristal', 'C', 'common', 18.64, 'crystal', 500, 2500, 0),
(3, 'Deuterio', 'D', 'common', 9.32, 'deuterium', 200, 1000, 0),
(4, 'Metal', 'M', 'rare', 7.46, 'metal', 5000, 20000, 0),
(5, 'Cristal', 'C', 'rare', 6.52, 'crystal', 2500, 10000, 0),
(6, 'Deuterio', 'D', 'rare', 4.66, 'deuterium', 1000, 4000, 0),
(7, 'Cazador Ligero', 'S', 'rare', 2.80, 'ship', 1, 1, 204),
(8, 'Lanzamisiles', 'S', 'rare', 1.86, 'defense', 1, 1, 401),
(9, 'Materia Oscura', 'DM', 'epic', 4.66, 'darkmatter', 100, 500, 0),
(10, 'Crucero', 'S', 'epic', 2.80, 'ship', 1, 1, 206),
(11, 'Canon Gauss', 'S', 'epic', 1.86, 'defense', 1, 1, 404),
(12, 'Metal', 'M', 'epic', 2.80, 'metal', 20000, 100000, 0),
(13, 'Cristal', 'C', 'epic', 1.86, 'crystal', 10000, 50000, 0),
(14, 'Nave de Batalla', 'S', 'mythic', 1.40, 'ship', 1, 1, 207),
(15, 'Materia Oscura', 'DM', 'mythic', 1.40, 'darkmatter', 1000, 5000, 0),
(16, 'Metal', 'M', 'mythic', 0.93, 'metal', 100000, 500000, 0),
(17, 'Cristal', 'C', 'mythic', 0.47, 'crystal', 50000, 250000, 0),
(18, 'Deuterio', 'D', 'mythic', 0.28, 'deuterium', 20000, 100000, 0),
(40, 'Recursos de Expedición', 'EXP', 'common', 0.11, 'booster', 1, 1, 13),
(41, 'Extracción de MO', 'MO', 'common', 0.11, 'booster', 1, 1, 9),
(42, 'Producción de Recursos', 'PRO', 'common', 0.11, 'booster', 1, 1, 10),
(43, 'Poder de Espionaje', 'SPY', 'common', 0.11, 'booster', 1, 1, 11),
(44, 'Producción de Energía', 'ENE', 'common', 0.11, 'booster', 1, 1, 12),
(45, 'Recursos de Expedición', 'EXP', 'rare', 0.30, 'booster', 1, 1, 13),
(46, 'Extracción de MO', 'MO', 'rare', 0.30, 'booster', 1, 1, 9),
(47, 'Producción de Recursos', 'PRO', 'rare', 0.30, 'booster', 1, 1, 10),
(48, 'Poder de Espionaje', 'SPY', 'rare', 0.30, 'booster', 1, 1, 11),
(49, 'Producción de Energía', 'ENE', 'rare', 0.30, 'booster', 1, 1, 12),
(50, 'Recursos de Expedición', 'EXP', 'epic', 0.45, 'booster', 1, 1, 13),
(51, 'Extracción de MO', 'MO', 'epic', 0.45, 'booster', 1, 1, 9),
(52, 'Producción de Recursos', 'PRO', 'epic', 0.45, 'booster', 1, 1, 10),
(53, 'Poder de Espionaje', 'SPY', 'epic', 0.45, 'booster', 1, 1, 11),
(54, 'Producción de Energía', 'ENE', 'epic', 0.45, 'booster', 1, 1, 12),
(55, 'Recursos de Expedición', 'EXP', 'mythic', 0.50, 'booster', 1, 1, 13),
(56, 'Extracción de MO', 'MO', 'mythic', 0.50, 'booster', 1, 1, 9),
(57, 'Producción de Recursos', 'PRO', 'mythic', 0.50, 'booster', 1, 1, 10),
(58, 'Poder de Espionaje', 'SPY', 'mythic', 0.50, 'booster', 1, 1, 11),
(59, 'Producción de Energía', 'ENE', 'mythic', 0.50, 'booster', 1, 1, 12);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_cronjobs`
--

CREATE TABLE `uni1_cronjobs` (
  `cronjobID` int(11) UNSIGNED NOT NULL,
  `name` varchar(32) NOT NULL,
  `isActive` tinyint(1) NOT NULL DEFAULT 1,
  `min` varchar(32) NOT NULL,
  `hours` varchar(32) NOT NULL,
  `dom` varchar(32) NOT NULL,
  `month` varchar(32) NOT NULL,
  `dow` varchar(32) NOT NULL,
  `class` varchar(32) NOT NULL,
  `nextTime` int(11) DEFAULT NULL,
  `lock` varchar(32) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_cronjobs`
--

INSERT INTO `uni1_cronjobs` (`cronjobID`, `name`, `isActive`, `min`, `hours`, `dom`, `month`, `dow`, `class`, `nextTime`, `lock`) VALUES
(1, 'referral', 1, '0,30', '*', '*', '*', '*', 'ReferralCronjob', 1792260000, NULL),
(2, 'statistic', 1, '*/5', '*', '*', '*', '*', 'StatisticCronjob', 1792234200, '99c7124d97d412122cdea46b88fa0580'),
(3, 'daily', 1, '25', '2', '*', '*', '*', 'DailyCronjob', 1792304700, NULL),
(4, 'cleaner', 1, '45', '2', '*', '*', '6', 'CleanerCronjob', 1792219500, 'fb5064ce7efdb0b58f622cde93513fe8'),
(5, 'inactive', 1, '30', '1', '*', '*', '0,3,6', 'InactiveMailCronjob', 1792301400, NULL),
(6, 'teamspeak', 0, '*/3', '*', '*', '*', '*', 'TeamSpeakCronjob', 1792218420, NULL),
(7, 'databasedump', 1, '30', '1', '*', '*', '1', 'DumpCronjob', 1792387800, '967161ab8d45eaa0e8af490676946fcb'),
(8, 'tracking', 1, '20', '17', '*', '*', '0', 'TrackingCronjob', 1792358400, NULL),
(28, 'Tournaments', 1, '*', '*', '*', '*', '*', 'TournamentCronjob', 1792259580, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_cronjobs_log`
--

CREATE TABLE `uni1_cronjobs_log` (
  `cronjobId` int(11) UNSIGNED NOT NULL,
  `executionTime` datetime NOT NULL,
  `lockToken` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_diplo`
--

CREATE TABLE `uni1_diplo` (
  `id` int(11) UNSIGNED NOT NULL,
  `owner_1` int(11) UNSIGNED NOT NULL,
  `owner_2` int(11) UNSIGNED NOT NULL,
  `level` tinyint(1) UNSIGNED NOT NULL,
  `accept` tinyint(1) UNSIGNED NOT NULL,
  `accept_text` varchar(255) NOT NULL,
  `universe` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_discord_oauth`
--

CREATE TABLE `uni1_discord_oauth` (
  `state` varchar(64) NOT NULL,
  `data` text DEFAULT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_events`
--

CREATE TABLE `uni1_events` (
  `event_id` int(11) NOT NULL,
  `event_name` varchar(80) NOT NULL,
  `event_desc` text NOT NULL,
  `event_icon` varchar(10) NOT NULL,
  `event_color` varchar(10) NOT NULL DEFAULT '#00ccff',
  `event_type` varchar(30) NOT NULL,
  `event_target_value` int(11) NOT NULL DEFAULT 0,
  `reward_type` varchar(20) NOT NULL,
  `reward_value` int(11) NOT NULL DEFAULT 0,
  `event_class` enum('daily','weekly','elite','admin') NOT NULL DEFAULT 'admin',
  `start_date` int(11) NOT NULL DEFAULT 0,
  `end_date` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_events`
--

INSERT INTO `uni1_events` (`event_id`, `event_name`, `event_desc`, `event_icon`, `event_color`, `event_type`, `event_target_value`, `reward_type`, `reward_value`, `event_class`, `start_date`, `end_date`, `active`, `created_by`) VALUES
(1, 'Cazador', 'Destruye 100 unidades enemigas en combate.', 'ATK', '#00ccff', 'destroy_units', 100, 'metal', 500, 'daily', 0, 0, 1, 0),
(2, 'Reciclador', 'Recicla 50.000 recursos de escombros.', 'REC', '#00ccff', 'recycle_debris', 50000, 'crystal', 500, 'daily', 0, 0, 1, 0),
(3, 'Explorador', 'Completa 5 expediciones exitosas.', 'EXP', '#00ccff', 'expeditions', 5, 'deuterium', 150, 'daily', 0, 0, 1, 0),
(4, 'Magnate', 'Extrae 50.000 recursos en tus planetas.', 'RES', '#00ccff', 'get_resources', 50000, 'metal', 800, 'daily', 0, 0, 0, 0),
(5, 'Cazador Avanzado', 'Destruye 500 unidades enemigas en combate.', 'ATK', '#00ccff', 'destroy_units', 500, 'containers', 1, 'daily', 0, 0, 0, 0),
(6, 'Reciclador Pro', 'Recicla 200.000 recursos de escombros.', 'REC', '#00ccff', 'recycle_debris', 200000, 'crystal', 1000, 'daily', 0, 0, 0, 0),
(7, 'Explorador Experto', 'Completa 15 expediciones exitosas.', 'EXP', '#00ccff', 'expeditions', 15, 'containers', 1, 'daily', 0, 0, 0, 0),
(8, 'Constructor', 'Construye 100 naves en tu hangar.', 'SHIP', '#00ccff', 'build_ships', 100, 'metal', 1000, 'daily', 0, 0, 0, 0),
(9, 'Comerciante', 'Extrae 100.000 recursos en tus planetas.', 'RES', '#00ccff', 'get_resources', 100000, 'metal', 1200, 'daily', 0, 0, 1, 0),
(10, 'Pirata', 'Destruye 250 unidades enemigas en combate.', 'ATK', '#00ccff', 'destroy_units', 250, 'crystal', 800, 'daily', 0, 0, 0, 0),
(11, 'Mercader', 'Construye 50 naves en tu hangar.', 'SHIP', '#00ccff', 'build_ships', 50, 'deuterium', 200, 'daily', 0, 0, 1, 0),
(12, 'Astronomo', 'Completa 10 expediciones exitosas.', 'EXP', '#00ccff', 'expeditions', 10, 'metal', 900, 'daily', 0, 0, 0, 0),
(13, 'Chatarrero', 'Recicla 100.000 recursos de escombros.', 'REC', '#00ccff', 'recycle_debris', 100000, 'crystal', 600, 'daily', 0, 0, 0, 0),
(14, 'Ingeniero', 'Construye 200 naves en tu hangar.', 'SHIP', '#00ccff', 'build_ships', 200, 'containers', 1, 'daily', 0, 0, 1, 0),
(15, 'Corsario', 'Destruye 300 unidades enemigas en combate.', 'ATK', '#00ccff', 'destroy_units', 300, 'metal', 1000, 'daily', 0, 0, 0, 0),
(16, 'Diplomatico', 'Completa 20 expediciones exitosas.', 'EXP', '#00ccff', 'expeditions', 20, 'deuterium', 250, 'daily', 0, 0, 1, 0),
(17, 'Industrial', 'Extrae 150.000 recursos en tus planetas.', 'RES', '#00ccff', 'get_resources', 150000, 'metal', 1500, 'daily', 0, 0, 0, 0),
(18, 'Inversor', 'Extrae 200.000 recursos en tus planetas.', 'RES', '#00ccff', 'get_resources', 200000, 'containers', 1, 'daily', 0, 0, 0, 0),
(19, 'Sabio', 'Completa 3 investigaciones en tus laboratorios.', 'TEC', '#00ccff', 'research_techs', 3, 'crystal', 900, 'daily', 0, 0, 1, 0),
(20, 'Estratega', 'Completa 5 investigaciones en tus laboratorios.', 'TEC', '#00ccff', 'research_techs', 5, 'containers', 1, 'daily', 0, 0, 0, 0),
(21, 'Almirante', 'Destruye 5.000 unidades enemigas en combate.', 'ATK', '#cc88ff', 'destroy_units', 5000, 'containers', 1, 'weekly', 0, 0, 0, 0),
(22, 'Cientifico', 'Completa 5 investigaciones en tus laboratorios.', 'TEC', '#cc88ff', 'research_techs', 5, 'deuterium', 1500, 'weekly', 0, 0, 0, 0),
(23, 'Almirante Supremo', 'Destruye 20.000 unidades enemigas en combate.', 'ATK', '#cc88ff', 'destroy_units', 20000, 'containers', 1, 'weekly', 0, 0, 0, 0),
(24, 'Cientifico Experto', 'Completa 15 investigaciones en tus laboratorios.', 'TEC', '#cc88ff', 'research_techs', 15, 'containers', 2, 'weekly', 0, 0, 1, 0),
(25, 'General', 'Destruye 10.000 unidades enemigas en combate.', 'ATK', '#cc88ff', 'destroy_units', 10000, 'containers', 1, 'weekly', 0, 0, 1, 0),
(26, 'Filosofo', 'Completa 10 investigaciones en tus laboratorios.', 'TEC', '#cc88ff', 'research_techs', 10, 'deuterium', 2500, 'weekly', 0, 0, 0, 0),
(27, 'Magnate Supremo', 'Extrae 500.000 recursos en tus planetas.', 'RES', '#cc88ff', 'get_resources', 500000, 'containers', 1, 'weekly', 0, 0, 1, 0),
(28, 'Ingeniero Mayor', 'Construye 500 naves en tu hangar.', 'SHIP', '#cc88ff', 'build_ships', 500, 'containers', 1, 'weekly', 0, 0, 1, 0),
(29, 'Reciclador Maestro', 'Recicla 1.000.000 recursos de escombros.', 'REC', '#cc88ff', 'recycle_debris', 1000000, 'containers', 1, 'weekly', 0, 0, 0, 0),
(30, 'Explorador Legendario', 'Completa 50 expediciones exitosas.', 'EXP', '#cc88ff', 'expeditions', 50, 'containers', 1, 'weekly', 0, 0, 0, 0),
(31, 'Banquero', 'Extrae 1.000.000 recursos en tus planetas.', 'RES', '#cc88ff', 'get_resources', 1000000, 'containers', 2, 'weekly', 0, 0, 0, 0),
(32, 'Titan', 'Construye 1.000 naves en tu hangar.', 'SHIP', '#cc88ff', 'build_ships', 1000, 'containers', 2, 'weekly', 0, 0, 0, 0),
(33, 'Leyenda Elite', 'Destruye 100.000 unidades enemigas en combate.', 'ELT', '#ffaa33', 'destroy_units', 100000, 'containers', 2, 'elite', 0, 0, 0, 0),
(34, 'Maestro Elite', 'Construye 10.000 naves en tu hangar.', 'ELT', '#ffaa33', 'build_ships', 10000, 'containers', 3, 'elite', 0, 0, 0, 0),
(35, 'Conquistador', 'Destruye 50.000 unidades enemigas en combate.', 'ELT', '#ffaa33', 'destroy_units', 50000, 'containers', 2, 'elite', 0, 0, 0, 0),
(36, 'Cientifico Elite', 'Completa 30 investigaciones en tus laboratorios.', 'ELT', '#ffaa33', 'research_techs', 30, 'containers', 2, 'elite', 0, 0, 0, 0),
(37, 'Imperio Galactico', 'Extrae 5.000.000 recursos en tus planetas.', 'ELT', '#ffaa33', 'get_resources', 5000000, 'containers', 2, 'elite', 0, 0, 1, 0),
(38, 'Reciclador Elite', 'Recicla 5.000.000 recursos de escombros.', 'ELT', '#ffaa33', 'recycle_debris', 5000000, 'containers', 3, 'elite', 0, 0, 1, 0),
(39, 'Explorador Elite', 'Completa 100 expediciones exitosas.', 'ELT', '#ffaa33', 'expeditions', 100, 'containers', 3, 'elite', 0, 0, 0, 0),
(40, 'Creador de Flotas', 'Construye 20.000 naves en tu hangar.', 'ELT', '#ffaa33', 'build_ships', 20000, 'containers', 3, 'elite', 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_events_history`
--

CREATE TABLE `uni1_events_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `event_name` varchar(80) NOT NULL,
  `event_class` varchar(20) NOT NULL,
  `reward_type` varchar(20) NOT NULL,
  `reward_value` int(11) NOT NULL DEFAULT 0,
  `claimed_at` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_events_rotation`
--

CREATE TABLE `uni1_events_rotation` (
  `class` varchar(20) NOT NULL,
  `last_rotation` int(11) NOT NULL DEFAULT 0,
  `active_ids` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_events_rotation`
--

INSERT INTO `uni1_events_rotation` (`class`, `last_rotation`, `active_ids`) VALUES
('daily', 1792199360, '9,2,19,14,11,16,3,1'),
('elite', 1791504144, '38,37'),
('weekly', 1791936382, '24,28,27,25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_factions`
--

CREATE TABLE `uni1_factions` (
  `faction_id` int(11) NOT NULL,
  `faction_name` varchar(50) NOT NULL,
  `faction_desc` text NOT NULL,
  `faction_icon` varchar(20) NOT NULL,
  `faction_color` varchar(10) NOT NULL DEFAULT '#00ccff',
  `bonus_ship_time` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_build_time` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_defense_time` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_research_time` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_flight_time` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_fuel` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_resources` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_defense_cost` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_research_cost` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_ship_cost` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_trader_cost` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_expeditions` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_exp_resources` decimal(6,2) NOT NULL DEFAULT 0.00
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_factions`
--

INSERT INTO `uni1_factions` (`faction_id`, `faction_name`, `faction_desc`, `faction_icon`, `faction_color`, `bonus_ship_time`, `bonus_build_time`, `bonus_defense_time`, `bonus_research_time`, `bonus_flight_time`, `bonus_fuel`, `bonus_resources`, `bonus_defense_cost`, `bonus_research_cost`, `bonus_ship_cost`, `bonus_trader_cost`, `bonus_expeditions`, `bonus_exp_resources`) VALUES
(1, 'Pirata', 'Astilleros rápidos y vuelos veloces. Ataca sin perder tiempo.', 'PIRA', '#ff4488', -10.00, 0.00, 0.00, 0.00, -10.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(2, 'Mineros', 'Maestros de la construcción y la extracción de recursos.', 'MINE', '#ffaa00', 0.00, -10.00, 0.00, 0.00, 0.00, 0.00, 15.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(3, 'Defensores', 'Fortalezas vivientes. Defensas baratas y rápidas de construir.', 'DEFE', '#00ccff', 0.00, 0.00, -10.00, 0.00, 0.00, 0.00, 0.00, -5.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(4, 'Tecnócratas', 'Mentes brillantes. Investigaciones rápidas y económicas.', 'TECN', '#aa44ff', 0.00, 0.00, 0.00, -10.00, 0.00, 0.00, 0.00, 0.00, -5.00, 0.00, 0.00, 0.00, 0.00),
(5, 'Exploradores', 'Viajeros incansables. Más expediciones y mejores botines.', 'EXPL', '#66ff99', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.00, 15.00),
(6, 'Comerciantes', 'Logística perfecta. Mercantes baratos y menos combustible.', 'COME', '#ffcc00', 0.00, 0.00, 0.00, 0.00, 0.00, -15.00, 0.00, 0.00, 0.00, 0.00, -10.00, 0.00, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_fleets`
--

CREATE TABLE `uni1_fleets` (
  `fleet_id` bigint(11) UNSIGNED NOT NULL,
  `fleet_owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_mission` tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  `fleet_amount` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_array` text DEFAULT NULL,
  `fleet_universe` tinyint(3) UNSIGNED NOT NULL,
  `fleet_start_time` int(11) NOT NULL DEFAULT 0,
  `fleet_start_id` int(11) UNSIGNED NOT NULL,
  `fleet_start_galaxy` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_start_system` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_start_planet` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_start_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `fleet_end_time` int(11) NOT NULL DEFAULT 0,
  `fleet_end_stay` int(11) NOT NULL DEFAULT 0,
  `fleet_end_id` int(11) UNSIGNED NOT NULL,
  `fleet_end_galaxy` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_end_system` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_end_planet` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_end_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `fleet_target_obj` int UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_metal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_crystal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_deuterium` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_darkmatter` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_target_owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_group` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_mess` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `start_time` int(11) DEFAULT NULL,
  `fleet_busy` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `hasCanceled` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `pvp_type` enum('none','arena','tournament') NOT NULL DEFAULT 'none',
  `pvp_ref_id` int(11) NOT NULL DEFAULT 0,
  `pvp_match_id` int(11) NOT NULL DEFAULT 0,
  `fleet_asteroid_chest` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_fleettools_log`
--

CREATE TABLE `uni1_fleettools_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `detalle` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT '',
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_fleet_event`
--

CREATE TABLE `uni1_fleet_event` (
  `fleetID` int(11) NOT NULL,
  `time` int(11) NOT NULL,
  `lock` varchar(32) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_gamedu`
--

CREATE TABLE `uni1_gamedu` (
  `id` int(11) UNSIGNED NOT NULL,
  `username` varchar(32) NOT NULL DEFAULT '',
  `user_id` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `time` int(11) NOT NULL DEFAULT 0,
  `score` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `type` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `universe` tinyint(2) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_gamedu_config`
--

CREATE TABLE `uni1_gamedu_config` (
  `config_key` varchar(64) NOT NULL,
  `config_value` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_gamedu_config`
--

INSERT INTO `uni1_gamedu_config` (`config_key`, `config_value`) VALUES
('topo_chest_max', '2'),
('topo_chest_min', '1'),
('topo_cooldown_hours', '2'),
('topo_enabled', '1'),
('topo_game_duration', '30'),
('topo_mole_interval_ms', '1000'),
('topo_mole_visible_ms', '600'),
('topo_points_per_hit', '100'),
('topo_ranking_limit', '10'),
('topo_reward_1_chest_chance', '0'),
('topo_reward_1_mo', '50'),
('topo_reward_1_score', '50'),
('topo_reward_2_chest_chance', '0'),
('topo_reward_2_mo', '100'),
('topo_reward_2_score', '800'),
('topo_reward_3_chest_chance', '0'),
('topo_reward_3_mo', '150'),
('topo_reward_3_score', '1300'),
('topo_reward_4_chest_chance', '20'),
('topo_reward_4_mo', '200'),
('topo_reward_4_score', '1800'),
('topo_reward_5_chest_chance', '40'),
('topo_reward_5_mo', '250'),
('topo_reward_5_score', '2300'),
('topo_score_max', '3000'),
('topo_score_min_reward', '350');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_gamedu_tokens`
--

CREATE TABLE `uni1_gamedu_tokens` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(64) NOT NULL,
  `started_at` int(11) NOT NULL DEFAULT 0,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `used_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_improvements_catalog`
--

CREATE TABLE `uni1_improvements_catalog` (
  `id` int(11) NOT NULL,
  `chain_id` int(11) NOT NULL,
  `chain_name` varchar(100) NOT NULL,
  `category` enum('ship','defense') NOT NULL,
  `type` enum('simple','combined') NOT NULL,
  `stat1` varchar(20) NOT NULL,
  `stat2` varchar(20) DEFAULT NULL,
  `level` tinyint(2) NOT NULL,
  `tier` tinyint(1) NOT NULL,
  `price` bigint(20) NOT NULL,
  `icon` varchar(10) DEFAULT NULL,
  `season` tinyint(2) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_improvements_catalog`
--

INSERT INTO `uni1_improvements_catalog` (`id`, `chain_id`, `chain_name`, `category`, `type`, `stat1`, `stat2`, `level`, `tier`, `price`, `icon`, `season`) VALUES
(1, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(2, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(3, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(4, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(5, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(6, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(7, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(8, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(9, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(10, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(11, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(12, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(13, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(14, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(15, 1, 'Nucleo de Combate', 'ship', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(16, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(17, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(18, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(19, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(20, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(21, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(22, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(23, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(24, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(25, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(26, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(27, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(28, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(29, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(30, 2, 'Canon de Plasma', 'ship', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(31, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(32, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(33, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(34, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(35, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(36, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(37, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(38, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(39, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(40, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(41, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(42, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(43, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(44, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(45, 3, 'Misil de Antimateria', 'ship', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(46, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(47, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(48, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(49, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(50, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(51, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(52, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(53, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(54, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(55, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(56, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(57, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(58, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(59, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(60, 4, 'Laser Pesado', 'ship', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(61, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(62, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(63, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(64, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(65, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(66, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(67, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(68, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(69, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(70, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(71, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(72, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(73, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(74, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(75, 5, 'Torreta Ofensiva', 'ship', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(76, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(77, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(78, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(79, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(80, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(81, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(82, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(83, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(84, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(85, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(86, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(87, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(88, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(89, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(90, 6, 'Placas de Titanio', 'ship', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(91, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(92, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(93, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(94, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(95, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(96, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(97, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(98, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(99, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(100, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(101, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(102, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(103, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(104, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(105, 7, 'Blindaje Reforzado', 'ship', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(106, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(107, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(108, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(109, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(110, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(111, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(112, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(113, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(114, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(115, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(116, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(117, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(118, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(119, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(120, 8, 'Casco de Neutronio', 'ship', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(121, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(122, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(123, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(124, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(125, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(126, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(127, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(128, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(129, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(130, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(131, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(132, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(133, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(134, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(135, 9, 'Compuesto Ceramico', 'ship', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(136, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(137, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(138, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(139, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(140, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(141, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(142, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(143, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(144, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(145, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(146, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(147, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(148, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(149, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(150, 10, 'Estructura Celular', 'ship', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(151, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(152, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(153, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(154, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(155, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(156, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(157, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(158, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(159, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(160, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(161, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(162, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(163, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(164, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(165, 11, 'Escudo Deflector', 'ship', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(166, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(167, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(168, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(169, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(170, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(171, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(172, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(173, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(174, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(175, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(176, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(177, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(178, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(179, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(180, 12, 'Campo de Fuerza', 'ship', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(181, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(182, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(183, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(184, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(185, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(186, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(187, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(188, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(189, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(190, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(191, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(192, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(193, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(194, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(195, 13, 'Barrera de Energia', 'ship', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(196, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(197, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(198, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(199, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(200, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(201, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(202, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(203, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(204, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(205, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(206, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(207, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(208, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(209, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(210, 14, 'Matriz de Absorcion', 'ship', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(211, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(212, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(213, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(214, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(215, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(216, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(217, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(218, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(219, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(220, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(221, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(222, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(223, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(224, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(225, 15, 'Nucleo de Escudo', 'ship', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(226, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 1, 1, 1000, 'MOT', 3),
(227, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 2, 1, 3000, 'MOT', 3),
(228, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 3, 1, 10000, 'MOT', 3),
(229, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 4, 1, 30000, 'MOT', 3),
(230, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 5, 1, 100000, 'MOT', 3),
(231, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 6, 2, 300000, 'MOT', 3),
(232, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 7, 2, 600000, 'MOT', 3),
(233, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 8, 2, 1200000, 'MOT', 3),
(234, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 9, 2, 2500000, 'MOT', 3),
(235, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 10, 2, 5000000, 'MOT', 3),
(236, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 11, 3, 10000000, 'MOT', 3),
(237, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 12, 3, 20000000, 'MOT', 3),
(238, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 13, 3, 40000000, 'MOT', 3),
(239, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 14, 3, 80000000, 'MOT', 3),
(240, 16, 'Propulsor Estandar', 'ship', 'simple', 'motriz', NULL, 15, 3, 150000000, 'MOT', 3),
(241, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 1, 1, 1000, 'MOT', 3),
(242, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 2, 1, 3000, 'MOT', 3),
(243, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 3, 1, 10000, 'MOT', 3),
(244, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 4, 1, 30000, 'MOT', 3),
(245, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 5, 1, 100000, 'MOT', 3),
(246, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 6, 2, 300000, 'MOT', 3),
(247, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 7, 2, 600000, 'MOT', 3),
(248, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 8, 2, 1200000, 'MOT', 3),
(249, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 9, 2, 2500000, 'MOT', 3),
(250, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 10, 2, 5000000, 'MOT', 3),
(251, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 11, 3, 10000000, 'MOT', 3),
(252, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 12, 3, 20000000, 'MOT', 3),
(253, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 13, 3, 40000000, 'MOT', 3),
(254, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 14, 3, 80000000, 'MOT', 3),
(255, 17, 'Motor Ionico', 'ship', 'simple', 'motriz', NULL, 15, 3, 150000000, 'MOT', 3),
(256, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 1, 1, 1000, 'MOT', 3),
(257, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 2, 1, 3000, 'MOT', 3),
(258, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 3, 1, 10000, 'MOT', 3),
(259, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 4, 1, 30000, 'MOT', 3),
(260, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 5, 1, 100000, 'MOT', 3),
(261, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 6, 2, 300000, 'MOT', 3),
(262, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 7, 2, 600000, 'MOT', 3),
(263, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 8, 2, 1200000, 'MOT', 3),
(264, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 9, 2, 2500000, 'MOT', 3),
(265, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 10, 2, 5000000, 'MOT', 3),
(266, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 11, 3, 10000000, 'MOT', 3),
(267, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 12, 3, 20000000, 'MOT', 3),
(268, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 13, 3, 40000000, 'MOT', 3),
(269, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 14, 3, 80000000, 'MOT', 3),
(270, 18, 'Turbina de Plasma', 'ship', 'simple', 'motriz', NULL, 15, 3, 150000000, 'MOT', 3),
(271, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 1, 1, 1000, 'MOT', 3),
(272, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 2, 1, 3000, 'MOT', 3),
(273, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 3, 1, 10000, 'MOT', 3),
(274, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 4, 1, 30000, 'MOT', 3),
(275, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 5, 1, 100000, 'MOT', 3),
(276, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 6, 2, 300000, 'MOT', 3),
(277, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 7, 2, 600000, 'MOT', 3),
(278, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 8, 2, 1200000, 'MOT', 3),
(279, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 9, 2, 2500000, 'MOT', 3),
(280, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 10, 2, 5000000, 'MOT', 3),
(281, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 11, 3, 10000000, 'MOT', 3),
(282, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 12, 3, 20000000, 'MOT', 3),
(283, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 13, 3, 40000000, 'MOT', 3),
(284, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 14, 3, 80000000, 'MOT', 3),
(285, 19, 'Hiperpropulsor', 'ship', 'simple', 'motriz', NULL, 15, 3, 150000000, 'MOT', 3),
(286, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 1, 1, 1000, 'MOT', 3),
(287, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 2, 1, 3000, 'MOT', 3),
(288, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 3, 1, 10000, 'MOT', 3),
(289, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 4, 1, 30000, 'MOT', 3),
(290, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 5, 1, 100000, 'MOT', 3),
(291, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 6, 2, 300000, 'MOT', 3),
(292, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 7, 2, 600000, 'MOT', 3),
(293, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 8, 2, 1200000, 'MOT', 3),
(294, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 9, 2, 2500000, 'MOT', 3),
(295, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 10, 2, 5000000, 'MOT', 3),
(296, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 11, 3, 10000000, 'MOT', 3),
(297, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 12, 3, 20000000, 'MOT', 3),
(298, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 13, 3, 40000000, 'MOT', 3),
(299, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 14, 3, 80000000, 'MOT', 3),
(300, 20, 'Motor de Curvatura', 'ship', 'simple', 'motriz', NULL, 15, 3, 150000000, 'MOT', 3),
(301, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 1, 1, 1000, 'LOG', 4),
(302, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 2, 1, 3000, 'LOG', 4),
(303, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 3, 1, 10000, 'LOG', 4),
(304, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 4, 1, 30000, 'LOG', 4),
(305, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 5, 1, 100000, 'LOG', 4),
(306, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 6, 2, 300000, 'LOG', 4),
(307, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 7, 2, 600000, 'LOG', 4),
(308, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 8, 2, 1200000, 'LOG', 4),
(309, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 9, 2, 2500000, 'LOG', 4),
(310, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 10, 2, 5000000, 'LOG', 4),
(311, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 11, 3, 10000000, 'LOG', 4),
(312, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 12, 3, 20000000, 'LOG', 4),
(313, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 13, 3, 40000000, 'LOG', 4),
(314, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 14, 3, 80000000, 'LOG', 4),
(315, 21, 'Bodega Ampliada', 'ship', 'simple', 'logistica', NULL, 15, 3, 150000000, 'LOG', 4),
(316, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 1, 1, 1000, 'LOG', 4),
(317, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 2, 1, 3000, 'LOG', 4),
(318, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 3, 1, 10000, 'LOG', 4),
(319, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 4, 1, 30000, 'LOG', 4),
(320, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 5, 1, 100000, 'LOG', 4),
(321, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 6, 2, 300000, 'LOG', 4),
(322, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 7, 2, 600000, 'LOG', 4),
(323, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 8, 2, 1200000, 'LOG', 4),
(324, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 9, 2, 2500000, 'LOG', 4),
(325, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 10, 2, 5000000, 'LOG', 4),
(326, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 11, 3, 10000000, 'LOG', 4),
(327, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 12, 3, 20000000, 'LOG', 4),
(328, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 13, 3, 40000000, 'LOG', 4),
(329, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 14, 3, 80000000, 'LOG', 4),
(330, 22, 'Contenedor de Carga', 'ship', 'simple', 'logistica', NULL, 15, 3, 150000000, 'LOG', 4),
(331, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 1, 1, 1000, 'LOG', 4),
(332, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 2, 1, 3000, 'LOG', 4),
(333, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 3, 1, 10000, 'LOG', 4),
(334, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 4, 1, 30000, 'LOG', 4),
(335, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 5, 1, 100000, 'LOG', 4),
(336, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 6, 2, 300000, 'LOG', 4),
(337, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 7, 2, 600000, 'LOG', 4),
(338, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 8, 2, 1200000, 'LOG', 4),
(339, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 9, 2, 2500000, 'LOG', 4),
(340, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 10, 2, 5000000, 'LOG', 4),
(341, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 11, 3, 10000000, 'LOG', 4),
(342, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 12, 3, 20000000, 'LOG', 4),
(343, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 13, 3, 40000000, 'LOG', 4),
(344, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 14, 3, 80000000, 'LOG', 4),
(345, 23, 'Sistema de Gruas', 'ship', 'simple', 'logistica', NULL, 15, 3, 150000000, 'LOG', 4),
(346, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 1, 1, 1000, 'LOG', 4),
(347, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 2, 1, 3000, 'LOG', 4),
(348, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 3, 1, 10000, 'LOG', 4),
(349, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 4, 1, 30000, 'LOG', 4),
(350, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 5, 1, 100000, 'LOG', 4),
(351, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 6, 2, 300000, 'LOG', 4),
(352, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 7, 2, 600000, 'LOG', 4),
(353, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 8, 2, 1200000, 'LOG', 4),
(354, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 9, 2, 2500000, 'LOG', 4),
(355, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 10, 2, 5000000, 'LOG', 4),
(356, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 11, 3, 10000000, 'LOG', 4),
(357, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 12, 3, 20000000, 'LOG', 4),
(358, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 13, 3, 40000000, 'LOG', 4),
(359, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 14, 3, 80000000, 'LOG', 4),
(360, 24, 'Modulo de Expansion', 'ship', 'simple', 'logistica', NULL, 15, 3, 150000000, 'LOG', 4),
(361, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 1, 1, 1000, 'LOG', 4),
(362, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 2, 1, 3000, 'LOG', 4),
(363, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 3, 1, 10000, 'LOG', 4),
(364, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 4, 1, 30000, 'LOG', 4),
(365, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 5, 1, 100000, 'LOG', 4),
(366, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 6, 2, 300000, 'LOG', 4),
(367, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 7, 2, 600000, 'LOG', 4),
(368, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 8, 2, 1200000, 'LOG', 4),
(369, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 9, 2, 2500000, 'LOG', 4),
(370, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 10, 2, 5000000, 'LOG', 4),
(371, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 11, 3, 10000000, 'LOG', 4),
(372, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 12, 3, 20000000, 'LOG', 4),
(373, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 13, 3, 40000000, 'LOG', 4),
(374, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 14, 3, 80000000, 'LOG', 4),
(375, 25, 'Bahia de Carga', 'ship', 'simple', 'logistica', NULL, 15, 3, 150000000, 'LOG', 4),
(376, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(377, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(378, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(379, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(380, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(381, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(382, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(383, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(384, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(385, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(386, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(387, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(388, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(389, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(390, 26, 'Canon de Defensa', 'defense', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(391, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(392, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(393, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(394, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(395, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(396, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(397, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(398, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(399, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(400, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(401, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(402, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(403, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(404, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(405, 27, 'Bateria de Misiles', 'defense', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(406, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(407, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(408, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(409, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(410, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(411, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(412, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(413, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(414, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(415, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(416, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(417, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(418, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(419, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(420, 28, 'Laser de Defensa', 'defense', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(421, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(422, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(423, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(424, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(425, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(426, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(427, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(428, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(429, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(430, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(431, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(432, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(433, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(434, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(435, 29, 'Ionizador Pesado', 'defense', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(436, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 1, 1, 1000, 'ATK', 1),
(437, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 2, 1, 3000, 'ATK', 1),
(438, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 3, 1, 10000, 'ATK', 1),
(439, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 4, 1, 30000, 'ATK', 1),
(440, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 5, 1, 100000, 'ATK', 1),
(441, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 6, 2, 300000, 'ATK', 1),
(442, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 7, 2, 600000, 'ATK', 1),
(443, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 8, 2, 1200000, 'ATK', 1),
(444, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 9, 2, 2500000, 'ATK', 1),
(445, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 10, 2, 5000000, 'ATK', 1),
(446, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 11, 3, 10000000, 'ATK', 1),
(447, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 12, 3, 20000000, 'ATK', 1),
(448, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 13, 3, 40000000, 'ATK', 1),
(449, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 14, 3, 80000000, 'ATK', 1),
(450, 30, 'Plasma de Defensa', 'defense', 'simple', 'ataque', NULL, 15, 3, 150000000, 'ATK', 1),
(451, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(452, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(453, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(454, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(455, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(456, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(457, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(458, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(459, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(460, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(461, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(462, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(463, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(464, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(465, 31, 'Muro de Hormigon', 'defense', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(466, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(467, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(468, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(469, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(470, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(471, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(472, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(473, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(474, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(475, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(476, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(477, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(478, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(479, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(480, 32, 'Blindaje de Titanio', 'defense', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(481, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(482, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(483, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(484, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(485, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(486, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(487, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(488, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(489, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(490, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(491, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(492, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(493, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(494, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(495, 33, 'Cupula Reforzada', 'defense', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(496, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(497, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(498, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(499, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(500, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(501, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(502, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(503, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(504, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(505, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(506, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(507, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(508, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(509, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(510, 34, 'Muralla de Neutronio', 'defense', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(511, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 1, 1, 1000, 'DEF', 2),
(512, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 2, 1, 3000, 'DEF', 2),
(513, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 3, 1, 10000, 'DEF', 2),
(514, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 4, 1, 30000, 'DEF', 2),
(515, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 5, 1, 100000, 'DEF', 2),
(516, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 6, 2, 300000, 'DEF', 2),
(517, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 7, 2, 600000, 'DEF', 2),
(518, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 8, 2, 1200000, 'DEF', 2),
(519, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 9, 2, 2500000, 'DEF', 2),
(520, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 10, 2, 5000000, 'DEF', 2),
(521, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 11, 3, 10000000, 'DEF', 2),
(522, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 12, 3, 20000000, 'DEF', 2),
(523, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 13, 3, 40000000, 'DEF', 2),
(524, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 14, 3, 80000000, 'DEF', 2),
(525, 35, 'Bunker Subterraneo', 'defense', 'simple', 'defensa', NULL, 15, 3, 150000000, 'DEF', 2),
(526, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(527, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(528, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(529, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(530, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(531, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(532, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(533, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(534, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(535, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(536, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(537, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(538, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(539, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(540, 36, 'Escudo de Defensa', 'defense', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(541, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(542, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(543, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(544, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(545, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(546, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(547, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(548, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(549, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(550, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(551, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(552, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(553, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(554, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3);
INSERT INTO `uni1_improvements_catalog` (`id`, `chain_id`, `chain_name`, `category`, `type`, `stat1`, `stat2`, `level`, `tier`, `price`, `icon`, `season`) VALUES
(555, 37, 'Campo Deflector', 'defense', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(556, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(557, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(558, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(559, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(560, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(561, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(562, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(563, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(564, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(565, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(566, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(567, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(568, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(569, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(570, 38, 'Barrera Defensiva', 'defense', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(571, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(572, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(573, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(574, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(575, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(576, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(577, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(578, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(579, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(580, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(581, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(582, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(583, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(584, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(585, 39, 'Matriz Defensiva', 'defense', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(586, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 1, 1, 1000, 'ESC', 3),
(587, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 2, 1, 3000, 'ESC', 3),
(588, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 3, 1, 10000, 'ESC', 3),
(589, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 4, 1, 30000, 'ESC', 3),
(590, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 5, 1, 100000, 'ESC', 3),
(591, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 6, 2, 300000, 'ESC', 3),
(592, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 7, 2, 600000, 'ESC', 3),
(593, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 8, 2, 1200000, 'ESC', 3),
(594, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 9, 2, 2500000, 'ESC', 3),
(595, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 10, 2, 5000000, 'ESC', 3),
(596, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 11, 3, 10000000, 'ESC', 3),
(597, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 12, 3, 20000000, 'ESC', 3),
(598, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 13, 3, 40000000, 'ESC', 3),
(599, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 14, 3, 80000000, 'ESC', 3),
(600, 40, 'Nucleo Defensivo', 'defense', 'simple', 'escudo', NULL, 15, 3, 150000000, 'ESC', 3),
(601, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 1, 1, 1000, 'CAD', 4),
(602, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 2, 1, 3000, 'CAD', 4),
(603, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 3, 1, 10000, 'CAD', 4),
(604, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 4, 1, 30000, 'CAD', 4),
(605, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 5, 1, 100000, 'CAD', 4),
(606, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 6, 2, 300000, 'CAD', 4),
(607, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 7, 2, 600000, 'CAD', 4),
(608, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 8, 2, 1200000, 'CAD', 4),
(609, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 9, 2, 2500000, 'CAD', 4),
(610, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 10, 2, 5000000, 'CAD', 4),
(611, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 11, 3, 10000000, 'CAD', 4),
(612, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 12, 3, 20000000, 'CAD', 4),
(613, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 13, 3, 40000000, 'CAD', 4),
(614, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 14, 3, 80000000, 'CAD', 4),
(615, 41, 'Servo Mecanico', 'defense', 'simple', 'cadencia', NULL, 15, 3, 150000000, 'CAD', 4),
(616, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 1, 1, 1000, 'CAD', 4),
(617, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 2, 1, 3000, 'CAD', 4),
(618, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 3, 1, 10000, 'CAD', 4),
(619, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 4, 1, 30000, 'CAD', 4),
(620, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 5, 1, 100000, 'CAD', 4),
(621, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 6, 2, 300000, 'CAD', 4),
(622, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 7, 2, 600000, 'CAD', 4),
(623, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 8, 2, 1200000, 'CAD', 4),
(624, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 9, 2, 2500000, 'CAD', 4),
(625, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 10, 2, 5000000, 'CAD', 4),
(626, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 11, 3, 10000000, 'CAD', 4),
(627, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 12, 3, 20000000, 'CAD', 4),
(628, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 13, 3, 40000000, 'CAD', 4),
(629, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 14, 3, 80000000, 'CAD', 4),
(630, 42, 'Recarga Automatica', 'defense', 'simple', 'cadencia', NULL, 15, 3, 150000000, 'CAD', 4),
(631, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 1, 1, 1000, 'CAD', 4),
(632, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 2, 1, 3000, 'CAD', 4),
(633, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 3, 1, 10000, 'CAD', 4),
(634, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 4, 1, 30000, 'CAD', 4),
(635, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 5, 1, 100000, 'CAD', 4),
(636, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 6, 2, 300000, 'CAD', 4),
(637, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 7, 2, 600000, 'CAD', 4),
(638, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 8, 2, 1200000, 'CAD', 4),
(639, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 9, 2, 2500000, 'CAD', 4),
(640, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 10, 2, 5000000, 'CAD', 4),
(641, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 11, 3, 10000000, 'CAD', 4),
(642, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 12, 3, 20000000, 'CAD', 4),
(643, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 13, 3, 40000000, 'CAD', 4),
(644, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 14, 3, 80000000, 'CAD', 4),
(645, 43, 'Sistema Rotatorio', 'defense', 'simple', 'cadencia', NULL, 15, 3, 150000000, 'CAD', 4),
(646, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 1, 1, 1000, 'CAD', 4),
(647, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 2, 1, 3000, 'CAD', 4),
(648, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 3, 1, 10000, 'CAD', 4),
(649, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 4, 1, 30000, 'CAD', 4),
(650, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 5, 1, 100000, 'CAD', 4),
(651, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 6, 2, 300000, 'CAD', 4),
(652, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 7, 2, 600000, 'CAD', 4),
(653, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 8, 2, 1200000, 'CAD', 4),
(654, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 9, 2, 2500000, 'CAD', 4),
(655, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 10, 2, 5000000, 'CAD', 4),
(656, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 11, 3, 10000000, 'CAD', 4),
(657, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 12, 3, 20000000, 'CAD', 4),
(658, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 13, 3, 40000000, 'CAD', 4),
(659, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 14, 3, 80000000, 'CAD', 4),
(660, 44, 'Motor de Recarga', 'defense', 'simple', 'cadencia', NULL, 15, 3, 150000000, 'CAD', 4),
(661, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 1, 1, 1000, 'CAD', 4),
(662, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 2, 1, 3000, 'CAD', 4),
(663, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 3, 1, 10000, 'CAD', 4),
(664, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 4, 1, 30000, 'CAD', 4),
(665, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 5, 1, 100000, 'CAD', 4),
(666, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 6, 2, 300000, 'CAD', 4),
(667, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 7, 2, 600000, 'CAD', 4),
(668, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 8, 2, 1200000, 'CAD', 4),
(669, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 9, 2, 2500000, 'CAD', 4),
(670, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 10, 2, 5000000, 'CAD', 4),
(671, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 11, 3, 10000000, 'CAD', 4),
(672, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 12, 3, 20000000, 'CAD', 4),
(673, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 13, 3, 40000000, 'CAD', 4),
(674, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 14, 3, 80000000, 'CAD', 4),
(675, 45, 'Ciclo Acelerado', 'defense', 'simple', 'cadencia', NULL, 15, 3, 150000000, 'CAD', 4),
(676, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 1, 1, 1000, 'PRE', 4),
(677, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 2, 1, 3000, 'PRE', 4),
(678, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 3, 1, 10000, 'PRE', 4),
(679, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 4, 1, 30000, 'PRE', 4),
(680, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 5, 1, 100000, 'PRE', 4),
(681, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 6, 2, 300000, 'PRE', 4),
(682, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 7, 2, 600000, 'PRE', 4),
(683, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 8, 2, 1200000, 'PRE', 4),
(684, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 9, 2, 2500000, 'PRE', 4),
(685, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 10, 2, 5000000, 'PRE', 4),
(686, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 11, 3, 10000000, 'PRE', 4),
(687, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 12, 3, 20000000, 'PRE', 4),
(688, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 13, 3, 40000000, 'PRE', 4),
(689, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 14, 3, 80000000, 'PRE', 4),
(690, 46, 'Mira Asistida', 'defense', 'simple', 'precision', NULL, 15, 3, 150000000, 'PRE', 4),
(691, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 1, 1, 1000, 'PRE', 4),
(692, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 2, 1, 3000, 'PRE', 4),
(693, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 3, 1, 10000, 'PRE', 4),
(694, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 4, 1, 30000, 'PRE', 4),
(695, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 5, 1, 100000, 'PRE', 4),
(696, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 6, 2, 300000, 'PRE', 4),
(697, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 7, 2, 600000, 'PRE', 4),
(698, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 8, 2, 1200000, 'PRE', 4),
(699, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 9, 2, 2500000, 'PRE', 4),
(700, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 10, 2, 5000000, 'PRE', 4),
(701, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 11, 3, 10000000, 'PRE', 4),
(702, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 12, 3, 20000000, 'PRE', 4),
(703, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 13, 3, 40000000, 'PRE', 4),
(704, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 14, 3, 80000000, 'PRE', 4),
(705, 47, 'Sistema de Punteria', 'defense', 'simple', 'precision', NULL, 15, 3, 150000000, 'PRE', 4),
(706, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 1, 1, 1000, 'PRE', 4),
(707, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 2, 1, 3000, 'PRE', 4),
(708, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 3, 1, 10000, 'PRE', 4),
(709, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 4, 1, 30000, 'PRE', 4),
(710, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 5, 1, 100000, 'PRE', 4),
(711, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 6, 2, 300000, 'PRE', 4),
(712, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 7, 2, 600000, 'PRE', 4),
(713, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 8, 2, 1200000, 'PRE', 4),
(714, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 9, 2, 2500000, 'PRE', 4),
(715, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 10, 2, 5000000, 'PRE', 4),
(716, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 11, 3, 10000000, 'PRE', 4),
(717, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 12, 3, 20000000, 'PRE', 4),
(718, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 13, 3, 40000000, 'PRE', 4),
(719, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 14, 3, 80000000, 'PRE', 4),
(720, 48, 'Radar de Tiro', 'defense', 'simple', 'precision', NULL, 15, 3, 150000000, 'PRE', 4),
(721, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 1, 1, 1000, 'PRE', 4),
(722, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 2, 1, 3000, 'PRE', 4),
(723, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 3, 1, 10000, 'PRE', 4),
(724, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 4, 1, 30000, 'PRE', 4),
(725, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 5, 1, 100000, 'PRE', 4),
(726, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 6, 2, 300000, 'PRE', 4),
(727, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 7, 2, 600000, 'PRE', 4),
(728, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 8, 2, 1200000, 'PRE', 4),
(729, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 9, 2, 2500000, 'PRE', 4),
(730, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 10, 2, 5000000, 'PRE', 4),
(731, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 11, 3, 10000000, 'PRE', 4),
(732, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 12, 3, 20000000, 'PRE', 4),
(733, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 13, 3, 40000000, 'PRE', 4),
(734, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 14, 3, 80000000, 'PRE', 4),
(735, 49, 'Ordenador Balistico', 'defense', 'simple', 'precision', NULL, 15, 3, 150000000, 'PRE', 4),
(736, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 1, 1, 1000, 'PRE', 4),
(737, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 2, 1, 3000, 'PRE', 4),
(738, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 3, 1, 10000, 'PRE', 4),
(739, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 4, 1, 30000, 'PRE', 4),
(740, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 5, 1, 100000, 'PRE', 4),
(741, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 6, 2, 300000, 'PRE', 4),
(742, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 7, 2, 600000, 'PRE', 4),
(743, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 8, 2, 1200000, 'PRE', 4),
(744, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 9, 2, 2500000, 'PRE', 4),
(745, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 10, 2, 5000000, 'PRE', 4),
(746, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 11, 3, 10000000, 'PRE', 4),
(747, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 12, 3, 20000000, 'PRE', 4),
(748, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 13, 3, 40000000, 'PRE', 4),
(749, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 14, 3, 80000000, 'PRE', 4),
(750, 50, 'Guia Laser', 'defense', 'simple', 'precision', NULL, 15, 3, 150000000, 'PRE', 4),
(751, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 1, 1, 3000, 'AM', 1),
(752, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 2, 1, 9000, 'AM', 1),
(753, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 3, 1, 30000, 'AM', 1),
(754, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 4, 1, 90000, 'AM', 1),
(755, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 5, 1, 300000, 'AM', 1),
(756, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 6, 2, 900000, 'AM', 1),
(757, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 7, 2, 1800000, 'AM', 1),
(758, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 8, 2, 3600000, 'AM', 1),
(759, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 9, 2, 7500000, 'AM', 1),
(760, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 10, 2, 15000000, 'AM', 1),
(761, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 11, 3, 30000000, 'AM', 1),
(762, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 12, 3, 60000000, 'AM', 1),
(763, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 13, 3, 120000000, 'AM', 1),
(764, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 14, 3, 240000000, 'AM', 1),
(765, 51, 'Asalto Rapido', 'ship', 'combined', 'ataque', 'motriz', 15, 3, 450000000, 'AM', 1),
(766, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 1, 1, 3000, 'DM', 2),
(767, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 2, 1, 9000, 'DM', 2),
(768, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 3, 1, 30000, 'DM', 2),
(769, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 4, 1, 90000, 'DM', 2),
(770, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 5, 1, 300000, 'DM', 2),
(771, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 6, 2, 900000, 'DM', 2),
(772, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 7, 2, 1800000, 'DM', 2),
(773, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 8, 2, 3600000, 'DM', 2),
(774, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 9, 2, 7500000, 'DM', 2),
(775, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 10, 2, 15000000, 'DM', 2),
(776, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 11, 3, 30000000, 'DM', 2),
(777, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 12, 3, 60000000, 'DM', 2),
(778, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 13, 3, 120000000, 'DM', 2),
(779, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 14, 3, 240000000, 'DM', 2),
(780, 52, 'Fortaleza Movil', 'ship', 'combined', 'defensa', 'motriz', 15, 3, 450000000, 'DM', 2),
(781, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 1, 1, 3000, 'AE', 3),
(782, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 2, 1, 9000, 'AE', 3),
(783, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 3, 1, 30000, 'AE', 3),
(784, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 4, 1, 90000, 'AE', 3),
(785, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 5, 1, 300000, 'AE', 3),
(786, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 6, 2, 900000, 'AE', 3),
(787, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 7, 2, 1800000, 'AE', 3),
(788, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 8, 2, 3600000, 'AE', 3),
(789, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 9, 2, 7500000, 'AE', 3),
(790, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 10, 2, 15000000, 'AE', 3),
(791, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 11, 3, 30000000, 'AE', 3),
(792, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 12, 3, 60000000, 'AE', 3),
(793, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 13, 3, 120000000, 'AE', 3),
(794, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 14, 3, 240000000, 'AE', 3),
(795, 53, 'Escudo Ofensivo', 'ship', 'combined', 'ataque', 'escudo', 15, 3, 450000000, 'AE', 3),
(796, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 1, 1, 3000, 'LD', 4),
(797, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 2, 1, 9000, 'LD', 4),
(798, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 3, 1, 30000, 'LD', 4),
(799, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 4, 1, 90000, 'LD', 4),
(800, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 5, 1, 300000, 'LD', 4),
(801, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 6, 2, 900000, 'LD', 4),
(802, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 7, 2, 1800000, 'LD', 4),
(803, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 8, 2, 3600000, 'LD', 4),
(804, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 9, 2, 7500000, 'LD', 4),
(805, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 10, 2, 15000000, 'LD', 4),
(806, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 11, 3, 30000000, 'LD', 4),
(807, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 12, 3, 60000000, 'LD', 4),
(808, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 13, 3, 120000000, 'LD', 4),
(809, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 14, 3, 240000000, 'LD', 4),
(810, 54, 'Carga Blindada', 'ship', 'combined', 'logistica', 'defensa', 15, 3, 450000000, 'LD', 4),
(811, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 1, 1, 3000, 'ML', 4),
(812, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 2, 1, 9000, 'ML', 4),
(813, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 3, 1, 30000, 'ML', 4),
(814, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 4, 1, 90000, 'ML', 4),
(815, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 5, 1, 300000, 'ML', 4),
(816, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 6, 2, 900000, 'ML', 4),
(817, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 7, 2, 1800000, 'ML', 4),
(818, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 8, 2, 3600000, 'ML', 4),
(819, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 9, 2, 7500000, 'ML', 4),
(820, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 10, 2, 15000000, 'ML', 4),
(821, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 11, 3, 30000000, 'ML', 4),
(822, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 12, 3, 60000000, 'ML', 4),
(823, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 13, 3, 120000000, 'ML', 4),
(824, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 14, 3, 240000000, 'ML', 4),
(825, 55, 'Explorador Veloz', 'ship', 'combined', 'motriz', 'logistica', 15, 3, 450000000, 'ML', 4),
(826, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 1, 1, 3000, 'DE', 2),
(827, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 2, 1, 9000, 'DE', 2),
(828, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 3, 1, 30000, 'DE', 2),
(829, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 4, 1, 90000, 'DE', 2),
(830, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 5, 1, 300000, 'DE', 2),
(831, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 6, 2, 900000, 'DE', 2),
(832, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 7, 2, 1800000, 'DE', 2),
(833, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 8, 2, 3600000, 'DE', 2),
(834, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 9, 2, 7500000, 'DE', 2),
(835, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 10, 2, 15000000, 'DE', 2),
(836, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 11, 3, 30000000, 'DE', 2),
(837, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 12, 3, 60000000, 'DE', 2),
(838, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 13, 3, 120000000, 'DE', 2),
(839, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 14, 3, 240000000, 'DE', 2),
(840, 56, 'Tanque Defensivo', 'ship', 'combined', 'defensa', 'escudo', 15, 3, 450000000, 'DE', 2),
(841, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 1, 1, 3000, 'AD', 1),
(842, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 2, 1, 9000, 'AD', 1),
(843, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 3, 1, 30000, 'AD', 1),
(844, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 4, 1, 90000, 'AD', 1),
(845, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 5, 1, 300000, 'AD', 1),
(846, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 6, 2, 900000, 'AD', 1),
(847, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 7, 2, 1800000, 'AD', 1),
(848, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 8, 2, 3600000, 'AD', 1),
(849, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 9, 2, 7500000, 'AD', 1),
(850, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 10, 2, 15000000, 'AD', 1),
(851, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 11, 3, 30000000, 'AD', 1),
(852, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 12, 3, 60000000, 'AD', 1),
(853, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 13, 3, 120000000, 'AD', 1),
(854, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 14, 3, 240000000, 'AD', 1),
(855, 57, 'Depredador', 'ship', 'combined', 'ataque', 'defensa', 15, 3, 450000000, 'AD', 1),
(856, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 1, 1, 3000, 'ME', 3),
(857, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 2, 1, 9000, 'ME', 3),
(858, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 3, 1, 30000, 'ME', 3),
(859, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 4, 1, 90000, 'ME', 3),
(860, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 5, 1, 300000, 'ME', 3),
(861, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 6, 2, 900000, 'ME', 3),
(862, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 7, 2, 1800000, 'ME', 3),
(863, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 8, 2, 3600000, 'ME', 3),
(864, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 9, 2, 7500000, 'ME', 3),
(865, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 10, 2, 15000000, 'ME', 3),
(866, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 11, 3, 30000000, 'ME', 3),
(867, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 12, 3, 60000000, 'ME', 3),
(868, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 13, 3, 120000000, 'ME', 3),
(869, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 14, 3, 240000000, 'ME', 3),
(870, 58, 'Mensajero', 'ship', 'combined', 'motriz', 'escudo', 15, 3, 450000000, 'ME', 3),
(871, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 1, 1, 3000, 'AC', 1),
(872, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 2, 1, 9000, 'AC', 1),
(873, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 3, 1, 30000, 'AC', 1),
(874, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 4, 1, 90000, 'AC', 1),
(875, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 5, 1, 300000, 'AC', 1),
(876, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 6, 2, 900000, 'AC', 1),
(877, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 7, 2, 1800000, 'AC', 1),
(878, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 8, 2, 3600000, 'AC', 1),
(879, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 9, 2, 7500000, 'AC', 1),
(880, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 10, 2, 15000000, 'AC', 1),
(881, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 11, 3, 30000000, 'AC', 1),
(882, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 12, 3, 60000000, 'AC', 1),
(883, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 13, 3, 120000000, 'AC', 1),
(884, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 14, 3, 240000000, 'AC', 1),
(885, 59, 'Torreta Rapida', 'defense', 'combined', 'ataque', 'cadencia', 15, 3, 450000000, 'AC', 1),
(886, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 1, 1, 3000, 'AD', 1),
(887, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 2, 1, 9000, 'AD', 1),
(888, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 3, 1, 30000, 'AD', 1),
(889, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 4, 1, 90000, 'AD', 1),
(890, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 5, 1, 300000, 'AD', 1),
(891, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 6, 2, 900000, 'AD', 1),
(892, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 7, 2, 1800000, 'AD', 1),
(893, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 8, 2, 3600000, 'AD', 1),
(894, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 9, 2, 7500000, 'AD', 1),
(895, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 10, 2, 15000000, 'AD', 1),
(896, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 11, 3, 30000000, 'AD', 1),
(897, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 12, 3, 60000000, 'AD', 1),
(898, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 13, 3, 120000000, 'AD', 1),
(899, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 14, 3, 240000000, 'AD', 1),
(900, 60, 'Bunker Ofensivo', 'defense', 'combined', 'ataque', 'defensa', 15, 3, 450000000, 'AD', 1),
(901, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 1, 1, 3000, 'AE', 1),
(902, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 2, 1, 9000, 'AE', 1),
(903, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 3, 1, 30000, 'AE', 1),
(904, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 4, 1, 90000, 'AE', 1),
(905, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 5, 1, 300000, 'AE', 1),
(906, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 6, 2, 900000, 'AE', 1),
(907, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 7, 2, 1800000, 'AE', 1),
(908, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 8, 2, 3600000, 'AE', 1),
(909, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 9, 2, 7500000, 'AE', 1),
(910, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 10, 2, 15000000, 'AE', 1),
(911, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 11, 3, 30000000, 'AE', 1),
(912, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 12, 3, 60000000, 'AE', 1),
(913, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 13, 3, 120000000, 'AE', 1),
(914, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 14, 3, 240000000, 'AE', 1),
(915, 61, 'Cupula Armada', 'defense', 'combined', 'ataque', 'escudo', 15, 3, 450000000, 'AE', 1),
(916, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 1, 1, 3000, 'AP', 1),
(917, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 2, 1, 9000, 'AP', 1),
(918, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 3, 1, 30000, 'AP', 1),
(919, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 4, 1, 90000, 'AP', 1),
(920, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 5, 1, 300000, 'AP', 1),
(921, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 6, 2, 900000, 'AP', 1),
(922, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 7, 2, 1800000, 'AP', 1),
(923, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 8, 2, 3600000, 'AP', 1),
(924, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 9, 2, 7500000, 'AP', 1),
(925, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 10, 2, 15000000, 'AP', 1),
(926, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 11, 3, 30000000, 'AP', 1),
(927, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 12, 3, 60000000, 'AP', 1),
(928, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 13, 3, 120000000, 'AP', 1),
(929, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 14, 3, 240000000, 'AP', 1),
(930, 62, 'Defensa Precisa', 'defense', 'combined', 'ataque', 'precision', 15, 3, 450000000, 'AP', 1),
(931, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 1, 1, 3000, 'DE', 2),
(932, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 2, 1, 9000, 'DE', 2),
(933, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 3, 1, 30000, 'DE', 2),
(934, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 4, 1, 90000, 'DE', 2),
(935, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 5, 1, 300000, 'DE', 2),
(936, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 6, 2, 900000, 'DE', 2),
(937, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 7, 2, 1800000, 'DE', 2),
(938, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 8, 2, 3600000, 'DE', 2),
(939, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 9, 2, 7500000, 'DE', 2),
(940, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 10, 2, 15000000, 'DE', 2),
(941, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 11, 3, 30000000, 'DE', 2),
(942, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 12, 3, 60000000, 'DE', 2),
(943, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 13, 3, 120000000, 'DE', 2),
(944, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 14, 3, 240000000, 'DE', 2),
(945, 63, 'Muro Reactivo', 'defense', 'combined', 'defensa', 'escudo', 15, 3, 450000000, 'DE', 2),
(946, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 1, 1, 3000, 'DP', 2),
(947, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 2, 1, 9000, 'DP', 2),
(948, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 3, 1, 30000, 'DP', 2),
(949, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 4, 1, 90000, 'DP', 2),
(950, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 5, 1, 300000, 'DP', 2),
(951, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 6, 2, 900000, 'DP', 2),
(952, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 7, 2, 1800000, 'DP', 2),
(953, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 8, 2, 3600000, 'DP', 2),
(954, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 9, 2, 7500000, 'DP', 2),
(955, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 10, 2, 15000000, 'DP', 2),
(956, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 11, 3, 30000000, 'DP', 2),
(957, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 12, 3, 60000000, 'DP', 2),
(958, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 13, 3, 120000000, 'DP', 2),
(959, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 14, 3, 240000000, 'DP', 2),
(960, 64, 'Fortaleza Letal', 'defense', 'combined', 'defensa', 'precision', 15, 3, 450000000, 'DP', 2),
(961, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 1, 1, 3000, 'EP', 2),
(962, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 2, 1, 9000, 'EP', 2),
(963, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 3, 1, 30000, 'EP', 2),
(964, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 4, 1, 90000, 'EP', 2),
(965, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 5, 1, 300000, 'EP', 2),
(966, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 6, 2, 900000, 'EP', 2),
(967, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 7, 2, 1800000, 'EP', 2),
(968, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 8, 2, 3600000, 'EP', 2),
(969, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 9, 2, 7500000, 'EP', 2),
(970, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 10, 2, 15000000, 'EP', 2),
(971, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 11, 3, 30000000, 'EP', 2),
(972, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 12, 3, 60000000, 'EP', 2),
(973, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 13, 3, 120000000, 'EP', 2),
(974, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 14, 3, 240000000, 'EP', 2),
(975, 65, 'Escudo Certero', 'defense', 'combined', 'escudo', 'precision', 15, 3, 450000000, 'EP', 2),
(976, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 1, 1, 3000, 'CD', 4),
(977, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 2, 1, 9000, 'CD', 4),
(978, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 3, 1, 30000, 'CD', 4),
(979, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 4, 1, 90000, 'CD', 4),
(980, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 5, 1, 300000, 'CD', 4),
(981, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 6, 2, 900000, 'CD', 4),
(982, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 7, 2, 1800000, 'CD', 4),
(983, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 8, 2, 3600000, 'CD', 4),
(984, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 9, 2, 7500000, 'CD', 4),
(985, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 10, 2, 15000000, 'CD', 4),
(986, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 11, 3, 30000000, 'CD', 4),
(987, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 12, 3, 60000000, 'CD', 4),
(988, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 13, 3, 120000000, 'CD', 4),
(989, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 14, 3, 240000000, 'CD', 4),
(990, 66, 'Cadencia Blindada', 'defense', 'combined', 'cadencia', 'defensa', 15, 3, 450000000, 'CD', 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_improvements_log`
--

CREATE TABLE `uni1_improvements_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `detalle` text NOT NULL,
  `ip` varchar(45) NOT NULL,
  `fecha` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_improvements_seasons`
--

CREATE TABLE `uni1_improvements_seasons` (
  `id` int(11) NOT NULL,
  `season_number` tinyint(2) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `mode` enum('manual','auto') NOT NULL DEFAULT 'manual',
  `date_start` int(11) NOT NULL DEFAULT 0,
  `date_end` int(11) NOT NULL DEFAULT 0,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_improvements_seasons`
--

INSERT INTO `uni1_improvements_seasons` (`id`, `season_number`, `name`, `description`, `active`, `mode`, `date_start`, `date_end`, `updated_at`) VALUES
(1, 1, 'Guerra de Titanes', 'Temporada enfocada en Ataque', 0, 'manual', 0, 0, 1791506392),
(2, 2, 'Muralla de Hierro', 'Temporada enfocada en Defensa', 0, 'manual', 0, 0, 0),
(3, 3, 'Tormenta Estelar', 'Temporada enfocada en Escudo y Velocidad', 0, 'manual', 0, 0, 0),
(4, 4, 'Imperio Logistico', 'Temporada enfocada en Logistica, Cadencia y Precision', 0, 'manual', 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_log`
--

CREATE TABLE `uni1_log` (
  `id` int(11) UNSIGNED NOT NULL,
  `mode` tinyint(3) UNSIGNED NOT NULL,
  `admin` int(11) UNSIGNED NOT NULL,
  `target` int(11) NOT NULL,
  `time` int(11) UNSIGNED NOT NULL,
  `data` text NOT NULL,
  `universe` tinyint(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_log_fleets`
--

CREATE TABLE `uni1_log_fleets` (
  `fleet_id` bigint(11) UNSIGNED NOT NULL,
  `fleet_owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_mission` tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  `fleet_amount` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_array` text DEFAULT NULL,
  `fleet_universe` tinyint(3) UNSIGNED NOT NULL,
  `fleet_start_time` int(11) NOT NULL DEFAULT 0,
  `fleet_start_id` int(11) UNSIGNED NOT NULL,
  `fleet_start_galaxy` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_start_system` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_start_planet` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_start_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `fleet_end_time` int(11) NOT NULL DEFAULT 0,
  `fleet_end_stay` int(11) NOT NULL DEFAULT 0,
  `fleet_end_id` int(11) UNSIGNED NOT NULL,
  `fleet_end_galaxy` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_end_system` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_end_planet` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_end_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `fleet_target_obj` int UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_metal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_crystal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_deuterium` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_resource_darkmatter` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_target_owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_group` varchar(15) NOT NULL DEFAULT '0',
  `fleet_mess` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `start_time` int(11) DEFAULT NULL,
  `fleet_busy` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_state` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_lostpassword`
--

CREATE TABLE `uni1_lostpassword` (
  `userID` int(10) UNSIGNED NOT NULL,
  `key` varchar(32) NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `hasChanged` tinyint(1) NOT NULL DEFAULT 0,
  `fromIP` varchar(40) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_lottery_config`
--

CREATE TABLE `uni1_lottery_config` (
  `id` int(11) NOT NULL,
  `moneda` enum('ntx20') NOT NULL DEFAULT 'ntx20',
  `precio_ticket` int(11) NOT NULL DEFAULT 57,
  `descuento_vip` int(11) NOT NULL DEFAULT 50,
  `duracion_sorteo` enum('24h','7d','15d') NOT NULL DEFAULT '7d',
  `rango_max` int(11) NOT NULL DEFAULT 30,
  `numeros_a_elegir` int(11) NOT NULL DEFAULT 4,
  `fondo_admin` int(11) NOT NULL DEFAULT 1000,
  `jackpot_minimo` int(11) NOT NULL DEFAULT 1000,
  `jackpot_acumula` tinyint(1) NOT NULL DEFAULT 1,
  `premio_3_aciertos` int(11) NOT NULL DEFAULT 169,
  `premio_2_aciertos` int(11) NOT NULL DEFAULT 114,
  `max_tickets_por_jugador` int(11) NOT NULL DEFAULT 4,
  `max_tickets_totales` int(11) NOT NULL DEFAULT 1000,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_actualizacion` int(11) NOT NULL DEFAULT 0,
  `actualizado_por` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_lottery_config`
--

INSERT INTO `uni1_lottery_config` (`id`, `moneda`, `precio_ticket`, `descuento_vip`, `duracion_sorteo`, `rango_max`, `numeros_a_elegir`, `fondo_admin`, `jackpot_minimo`, `jackpot_acumula`, `premio_3_aciertos`, `premio_2_aciertos`, `max_tickets_por_jugador`, `max_tickets_totales`, `activo`, `fecha_actualizacion`, `actualizado_por`) VALUES
(1, 'ntx20', 57, 50, '7d', 30, 4, 1000, 1000, 1, 169, 114, 4, 1000, 1, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_lottery_draws`
--

CREATE TABLE `uni1_lottery_draws` (
  `id` int(11) NOT NULL,
  `numero_sorteo` int(11) NOT NULL,
  `rango_max` int(11) NOT NULL DEFAULT 30,
  `numeros_a_elegir` int(11) NOT NULL DEFAULT 4,
  `precio_ticket` int(11) NOT NULL DEFAULT 57,
  `numeros_sorteados` varchar(255) DEFAULT NULL,
  `fondo_admin` int(11) NOT NULL DEFAULT 0,
  `tickets_recaudado` int(11) NOT NULL DEFAULT 0,
  `jackpot_anterior` int(11) NOT NULL DEFAULT 0,
  `jackpot_total` int(11) NOT NULL DEFAULT 0,
  `pozo_jackpot` int(11) NOT NULL DEFAULT 0,
  `pozo_3_aciertos` int(11) NOT NULL DEFAULT 0,
  `pozo_2_aciertos` int(11) NOT NULL DEFAULT 0,
  `rollover_3` int(11) NOT NULL DEFAULT 0,
  `rollover_2` int(11) NOT NULL DEFAULT 0,
  `pct_jackpot_aplicado` int(11) NOT NULL DEFAULT 70,
  `pct_3_aplicado` int(11) NOT NULL DEFAULT 20,
  `pct_2_aplicado` int(11) NOT NULL DEFAULT 10,
  `hubo_ganador_jackpot` tinyint(1) NOT NULL DEFAULT 0,
  `jackpot_rollover` int(11) NOT NULL DEFAULT 0,
  `ganador_jackpot_id` int(11) DEFAULT NULL,
  `tickets_vendidos` int(11) NOT NULL DEFAULT 0,
  `estado` enum('abierto','sorteado','cancelado') NOT NULL DEFAULT 'abierto',
  `fecha_inicio` int(11) NOT NULL DEFAULT 0,
  `fecha_sorteo` int(11) NOT NULL DEFAULT 0,
  `fecha_ejecutado` int(11) DEFAULT NULL,
  `semilla` int(11) DEFAULT NULL,
  `hash_verificacion` varchar(64) DEFAULT NULL,
  `creado_por` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_lottery_log`
--

CREATE TABLE `uni1_lottery_log` (
  `id` int(11) NOT NULL,
  `draw_id` int(11) NOT NULL DEFAULT 0,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `accion` varchar(50) NOT NULL DEFAULT '',
  `detalle` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_lottery_percentages`
--

CREATE TABLE `uni1_lottery_percentages` (
  `id` int(11) NOT NULL,
  `jackpot_desde` int(11) NOT NULL DEFAULT 0,
  `jackpot_hasta` int(11) NOT NULL DEFAULT 0,
  `pct_jackpot` int(11) NOT NULL DEFAULT 70,
  `pct_3_aciertos` int(11) NOT NULL DEFAULT 20,
  `pct_2_aciertos` int(11) NOT NULL DEFAULT 10,
  `orden` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_lottery_percentages`
--

INSERT INTO `uni1_lottery_percentages` (`id`, `jackpot_desde`, `jackpot_hasta`, `pct_jackpot`, `pct_3_aciertos`, `pct_2_aciertos`, `orden`) VALUES
(1, 0, 1000, 70, 20, 10, 1),
(2, 1000, 5000, 60, 25, 15, 2),
(3, 5000, 20000, 50, 30, 20, 3),
(4, 20000, 100000, 40, 35, 25, 4),
(5, 100000, 0, 30, 40, 30, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_lottery_tickets`
--

CREATE TABLE `uni1_lottery_tickets` (
  `id` int(11) NOT NULL,
  `draw_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `numeros` varchar(100) NOT NULL,
  `aciertos` int(11) DEFAULT NULL,
  `tipo_premio` enum('jackpot','3_aciertos','2_aciertos','ninguno') DEFAULT NULL,
  `premio_ganado` int(11) DEFAULT NULL,
  `fecha_entrega` int(11) DEFAULT NULL,
  `precio_pagado` int(11) NOT NULL DEFAULT 0,
  `ip_compra` varchar(45) DEFAULT NULL,
  `fecha_compra` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_market_fund`
--

CREATE TABLE `uni1_market_fund` (
  `id` int(11) NOT NULL,
  `total_earned` bigint(20) NOT NULL DEFAULT 0,
  `from_seller` bigint(20) NOT NULL DEFAULT 0,
  `from_buyer` bigint(20) NOT NULL DEFAULT 0,
  `from_admin` bigint(20) NOT NULL DEFAULT 0,
  `last_update` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_market_log`
--

CREATE TABLE `uni1_market_log` (
  `log_id` int(11) NOT NULL,
  `offer_id` int(11) NOT NULL,
  `buyer_id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `offer_type` enum('sell','buy') NOT NULL DEFAULT 'sell',
  `item_type` varchar(20) NOT NULL,
  `item_id` int(11) NOT NULL DEFAULT 0,
  `item_name` varchar(64) NOT NULL DEFAULT '',
  `amount` bigint(20) NOT NULL,
  `price_ntx` bigint(20) NOT NULL,
  `fee_seller` bigint(20) NOT NULL DEFAULT 0,
  `fee_buyer` bigint(20) NOT NULL DEFAULT 0,
  `fee_seller_pct` tinyint(3) NOT NULL DEFAULT 0,
  `fee_buyer_pct` tinyint(3) NOT NULL DEFAULT 0,
  `seller_was_vip` tinyint(1) NOT NULL DEFAULT 0,
  `buyer_was_vip` tinyint(1) NOT NULL DEFAULT 0,
  `time` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_market_offers`
--

CREATE TABLE `uni1_market_offers` (
  `offer_id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `planet_id` int(11) NOT NULL DEFAULT 0,
  `offer_type` enum('sell','buy') NOT NULL DEFAULT 'sell',
  `admin_offer` tinyint(1) NOT NULL DEFAULT 0,
  `item_type` varchar(20) NOT NULL,
  `item_id` int(11) NOT NULL DEFAULT 0,
  `item_name` varchar(64) NOT NULL DEFAULT '',
  `amount` bigint(20) NOT NULL,
  `price_ntx` bigint(20) NOT NULL,
  `duration` tinyint(3) NOT NULL DEFAULT 24,
  `fee_seller_pct` tinyint(3) NOT NULL DEFAULT 3,
  `fee_buyer_pct` tinyint(3) NOT NULL DEFAULT 7,
  `fee_acceptor_pct` tinyint(3) NOT NULL DEFAULT 10,
  `seller_fee_paid` bigint(20) NOT NULL DEFAULT 0,
  `fee_buyer_paid` bigint(20) NOT NULL DEFAULT 0,
  `acceptor_fee` bigint(20) NOT NULL DEFAULT 0,
  `seller_was_vip` tinyint(1) NOT NULL DEFAULT 0,
  `created` int(11) NOT NULL,
  `expires` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','sold','expired','cancelled') NOT NULL DEFAULT 'active',
  `cancel_reason` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_market_stats`
--

CREATE TABLE `uni1_market_stats` (
  `stat_id` int(11) NOT NULL,
  `stat_date` date NOT NULL,
  `item_type` varchar(20) NOT NULL,
  `item_id` int(11) NOT NULL DEFAULT 0,
  `item_name` varchar(64) NOT NULL DEFAULT '',
  `total_sold` int(11) NOT NULL DEFAULT 0,
  `total_bought` int(11) NOT NULL DEFAULT 0,
  `avg_price` bigint(20) NOT NULL DEFAULT 0,
  `min_price` bigint(20) NOT NULL DEFAULT 0,
  `max_price` bigint(20) NOT NULL DEFAULT 0,
  `total_volume` bigint(20) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_messages`
--

CREATE TABLE `uni1_messages` (
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `message_owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `message_sender` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `message_time` int(11) NOT NULL DEFAULT 0,
  `message_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `message_from` varchar(128) DEFAULT NULL,
  `message_subject` varchar(255) DEFAULT NULL,
  `message_text` text DEFAULT NULL,
  `message_unread` tinyint(4) NOT NULL DEFAULT 1,
  `message_universe` tinyint(3) UNSIGNED NOT NULL,
  `message_deleted` int(11) UNSIGNED DEFAULT NULL,
  `messages_deleted` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_multi`
--

CREATE TABLE `uni1_multi` (
  `multiID` int(11) NOT NULL,
  `userID` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_news`
--

CREATE TABLE `uni1_news` (
  `id` int(11) UNSIGNED NOT NULL,
  `user` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` int(11) NOT NULL,
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_notes`
--

CREATE TABLE `uni1_notes` (
  `id` int(11) NOT NULL,
  `owner` int(11) UNSIGNED DEFAULT NULL,
  `time` int(11) DEFAULT NULL,
  `priority` tinyint(1) UNSIGNED DEFAULT 1,
  `title` varchar(32) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `universe` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_ntx20_log`
--

CREATE TABLE `uni1_ntx20_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `amount` int(11) NOT NULL COMMENT 'Positivo = gano, Negativo = gasto',
  `balance_after` int(11) NOT NULL DEFAULT 0 COMMENT 'Saldo despues del movimiento',
  `type` varchar(32) NOT NULL COMMENT 'vip_purchase, shop_purchase, etc.',
  `description` varchar(255) NOT NULL DEFAULT '',
  `reference_id` int(11) NOT NULL DEFAULT 0 COMMENT 'ID del item/oferta/evento',
  `ip` varbinary(16) DEFAULT NULL,
  `timestamp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_planets`
--

CREATE TABLE `uni1_planets` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(20) DEFAULT 'Hauptplanet',
  `id_owner` int(11) UNSIGNED DEFAULT NULL,
  `universe` tinyint(3) UNSIGNED NOT NULL,
  `galaxy` tinyint(3) NOT NULL DEFAULT 0,
  `system` smallint(5) NOT NULL DEFAULT 0,
  `planet` tinyint(3) NOT NULL DEFAULT 0,
  `last_update` int(11) DEFAULT NULL,
  `planet_type` enum('1','3') NOT NULL DEFAULT '1',
  `destruyed` int(11) NOT NULL DEFAULT 0,
  `b_building` int(11) NOT NULL DEFAULT 0,
  `b_building_id` text DEFAULT NULL,
  `b_hangar` int(11) NOT NULL DEFAULT 0,
  `b_hangar_id` text DEFAULT NULL,
  `b_hangar_plus` int(11) NOT NULL DEFAULT 0,
  `image` varchar(32) NOT NULL DEFAULT 'normaltempplanet01',
  `diameter` int(11) UNSIGNED NOT NULL DEFAULT 12800,
  `field_current` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `field_max` smallint(5) UNSIGNED NOT NULL DEFAULT 163,
  `temp_min` int(3) NOT NULL DEFAULT -17,
  `temp_max` int(3) NOT NULL DEFAULT 23,
  `eco_hash` varchar(32) NOT NULL DEFAULT '',
  `metal` double(255,6) UNSIGNED NOT NULL DEFAULT 0.000000,
  `metal_perhour` double(255,6) NOT NULL DEFAULT 0.000000,
  `metal_max` double(255,0) UNSIGNED DEFAULT 100000,
  `crystal` double(255,6) UNSIGNED NOT NULL DEFAULT 0.000000,
  `crystal_perhour` double(255,6) NOT NULL DEFAULT 0.000000,
  `crystal_max` double(255,0) UNSIGNED DEFAULT 100000,
  `deuterium` double(255,6) UNSIGNED NOT NULL DEFAULT 0.000000,
  `deuterium_perhour` double(255,6) NOT NULL DEFAULT 0.000000,
  `deuterium_max` double(255,0) UNSIGNED DEFAULT 100000,
  `energy_used` double(255,0) NOT NULL DEFAULT 0,
  `energy` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `metal_mine` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `crystal_mine` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `deuterium_sintetizer` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `solar_plant` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fusion_plant` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `robot_factory` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `nano_factory` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `hangar` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `metal_store` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `crystal_store` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `deuterium_store` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `laboratory` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `terraformer` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `university` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ally_deposit` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `silo` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mondbasis` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `phalanx` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `sprungtor` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `small_ship_cargo` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `big_ship_cargo` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `light_hunter` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `heavy_hunter` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `crusher` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `battle_ship` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `colonizer` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `recycler` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `spy_sonde` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `bomber_ship` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `solar_satelit` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `destructor` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `dearth_star` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `battleship` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `lune_noir` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `ev_transporter` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `star_crasher` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `giga_recykler` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `dm_ship` double(255,0) NOT NULL DEFAULT 0,
  `orbital_station` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `misil_launcher` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `small_laser` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `big_laser` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `gauss_canyon` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `ionic_canyon` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `buster_canyon` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `small_protection_shield` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `planet_protector` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `big_protection_shield` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `graviton_canyon` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `interceptor_misil` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `interplanetary_misil` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `metal_mine_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '10',
  `crystal_mine_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '10',
  `deuterium_sintetizer_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '10',
  `solar_plant_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '10',
  `fusion_plant_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '10',
  `solar_satelit_porcent` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL DEFAULT '10',
  `last_jump_time` int(11) NOT NULL DEFAULT 0,
  `der_metal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `der_crystal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `id_luna` int(11) NOT NULL DEFAULT 0,
  `star_titan` bigint(20) NOT NULL DEFAULT 0,
  `war_colossus` bigint(20) NOT NULL DEFAULT 0,
  `elite_battleship` bigint(20) NOT NULL DEFAULT 0,
  `heavy_frigate` bigint(20) NOT NULL DEFAULT 0,
  `rail_turret` bigint(20) NOT NULL DEFAULT 0,
  `antimatter_canyon` bigint(20) NOT NULL DEFAULT 0,
  `star_bastion` bigint(20) NOT NULL DEFAULT 0,
  `deflector_shield` bigint(20) NOT NULL DEFAULT 0,
  `antimatter_misil` bigint(20) NOT NULL DEFAULT 0,
  `advanced_interceptor_misil` bigint(20) NOT NULL DEFAULT 0,
  `droids_builder` tinyint(2) NOT NULL DEFAULT 0,
  `droids_engineer` tinyint(2) NOT NULL DEFAULT 0,
  `last_teleport` int(11) NOT NULL DEFAULT 0,
  `last_rename` int(11) NOT NULL DEFAULT 0,
  `b_defense` int(11) NOT NULL DEFAULT 0,
  `b_defense_id` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_achievements`
--

CREATE TABLE `uni1_pve_achievements` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `consecutive_months` int(11) NOT NULL DEFAULT 0,
  `total_months` int(11) NOT NULL DEFAULT 0,
  `last_survived_month` varchar(7) NOT NULL DEFAULT '',
  `achievement_1m` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_6m` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_12m` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_1m_at` int(11) NOT NULL DEFAULT 0,
  `achievement_6m_at` int(11) NOT NULL DEFAULT 0,
  `achievement_12m_at` int(11) NOT NULL DEFAULT 0,
  `updated_at` int(11) NOT NULL DEFAULT 0,
  `tournament_ghosts_killed` int(11) NOT NULL DEFAULT 0,
  `tournament_damage_total` double NOT NULL DEFAULT 0,
  `tournament_wins` int(11) NOT NULL DEFAULT 0,
  `achievement_hunter` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_hunter_at` int(11) NOT NULL DEFAULT 0,
  `achievement_slayer` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_slayer_at` int(11) NOT NULL DEFAULT 0,
  `achievement_contributor` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_contributor_at` int(11) NOT NULL DEFAULT 0,
  `achievement_champion` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_champion_at` int(11) NOT NULL DEFAULT 0,
  `bastion_events_played` int(11) NOT NULL DEFAULT 0,
  `bastion_pirates_killed` int(11) NOT NULL DEFAULT 0,
  `bastion_boss_pirates_killed` int(11) NOT NULL DEFAULT 0,
  `bastion_events_won` int(11) NOT NULL DEFAULT 0,
  `achievement_bastion_veteran` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_bastion_veteran_at` int(11) NOT NULL DEFAULT 0,
  `achievement_bastion_pirate_legend` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_bastion_pirate_legend_at` int(11) NOT NULL DEFAULT 0,
  `achievement_bastion_boss_hunter` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_bastion_boss_hunter_at` int(11) NOT NULL DEFAULT 0,
  `achievement_bastion_dynasty` tinyint(1) NOT NULL DEFAULT 0,
  `achievement_bastion_dynasty_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_acs_invites`
--

CREATE TABLE `uni1_pve_acs_invites` (
  `id` int(11) NOT NULL,
  `acs_id` int(11) NOT NULL,
  `invited_user_id` int(11) NOT NULL,
  `invited_by` int(11) NOT NULL,
  `invite_type` enum('user','ally') NOT NULL DEFAULT 'user' COMMENT 'user=privada, ally=por alianza',
  `status` enum('pending','accepted','rejected','expired') NOT NULL DEFAULT 'pending',
  `created_at` int(11) NOT NULL DEFAULT 0,
  `responded_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_bastion_damage`
--

CREATE TABLE `uni1_pve_bastion_damage` (
  `id` bigint(20) NOT NULL,
  `event_id` bigint(20) NOT NULL,
  `registration_id` bigint(20) NOT NULL,
  `ally_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `ships_sent` bigint(20) NOT NULL DEFAULT 0,
  `ships_lost` bigint(20) NOT NULL DEFAULT 0,
  `damage_dealt` bigint(20) NOT NULL DEFAULT 0,
  `pirates_killed` bigint(20) NOT NULL DEFAULT 0,
  `boss_pirates_killed` int(11) NOT NULL DEFAULT 0,
  `waves_participated` int(11) NOT NULL DEFAULT 0,
  `first_hit` int(11) NOT NULL,
  `last_hit` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_bastion_event`
--

CREATE TABLE `uni1_pve_bastion_event` (
  `id` bigint(20) NOT NULL,
  `bastion_name` varchar(64) NOT NULL DEFAULT 'El Bastión de la Alianza',
  `entry_mode` enum('free','paid') NOT NULL DEFAULT 'free',
  `entry_cost_ntx` int(11) NOT NULL DEFAULT 0,
  `prize_type` enum('metal','crystal','deuterium','dark_matter','ntx') NOT NULL DEFAULT 'ntx',
  `prize_metal` bigint(20) NOT NULL DEFAULT 0,
  `prize_crystal` bigint(20) NOT NULL DEFAULT 0,
  `prize_deuterium` bigint(20) NOT NULL DEFAULT 0,
  `prize_dark_matter` bigint(20) NOT NULL DEFAULT 0,
  `prize_ntx` int(11) NOT NULL DEFAULT 0,
  `prize_scales_with_allies` tinyint(1) NOT NULL DEFAULT 0,
  `project_fee_pct` tinyint(3) NOT NULL DEFAULT 5,
  `winner_distribution` enum('leader','by_contribution','equal') NOT NULL DEFAULT 'by_contribution',
  `min_alliances` tinyint(3) NOT NULL DEFAULT 2,
  `max_alliances` tinyint(3) NOT NULL DEFAULT 20,
  `bastion_hp_per_member` int(11) NOT NULL DEFAULT 500000,
  `bastion_hp_min` bigint(20) NOT NULL DEFAULT 10000000,
  `duration_hours` int(11) NOT NULL DEFAULT 48,
  `bastion_template_id` int(11) NOT NULL DEFAULT 0,
  `bastion_mode` enum('standard','hardcore') NOT NULL DEFAULT 'standard',
  `status` enum('scheduled','registration','active','finished','cancelled') NOT NULL DEFAULT 'scheduled',
  `created_by` int(11) NOT NULL,
  `created_at` int(11) NOT NULL,
  `registration_start` int(11) NOT NULL,
  `registration_end` int(11) NOT NULL,
  `start_time` int(11) NOT NULL,
  `end_time` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `cancel_reason` varchar(255) DEFAULT NULL,
  `total_pool_ntx` int(11) NOT NULL DEFAULT 0,
  `winner_registration_id` bigint(20) DEFAULT NULL,
  `winner_ally_id` int(11) DEFAULT NULL,
  `winner_score` bigint(20) DEFAULT NULL,
  `winner_pct_hp` decimal(8,2) DEFAULT NULL,
  `total_score` bigint(20) NOT NULL DEFAULT 0,
  `total_pirates_killed` bigint(20) NOT NULL DEFAULT 0,
  `total_waves_resolved` int(11) NOT NULL DEFAULT 0,
  `total_bastions_spawned` int(11) NOT NULL DEFAULT 0,
  `total_bastions_breached` int(11) NOT NULL DEFAULT 0,
  `counter_enabled` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_bastion_ghosts`
--

CREATE TABLE `uni1_pve_bastion_ghosts` (
  `id` bigint(20) NOT NULL,
  `event_id` bigint(20) NOT NULL,
  `registration_id` bigint(20) NOT NULL,
  `ally_id` int(11) NOT NULL,
  `spawn_number` int(11) NOT NULL,
  `ghost_user_id` int(11) NOT NULL,
  `ghost_planet_id` int(11) NOT NULL,
  `galaxy` tinyint(3) NOT NULL,
  `system` smallint(5) NOT NULL,
  `planet` tinyint(3) NOT NULL,
  `hp_max` bigint(20) NOT NULL,
  `hp_current` bigint(20) NOT NULL,
  `damage_received` bigint(20) NOT NULL DEFAULT 0,
  `pct_hp_lost` decimal(5,2) NOT NULL DEFAULT 0.00,
  `phase` tinyint(1) NOT NULL DEFAULT 1,
  `next_wave_at` int(11) DEFAULT NULL,
  `ships_json` text NOT NULL,
  `defenses_json` text NOT NULL,
  `status` enum('active','breached','destroyed','expired') NOT NULL DEFAULT 'active',
  `spawned_at` int(11) NOT NULL,
  `breached_at` int(11) DEFAULT NULL,
  `breached_by_wave` bigint(20) DEFAULT NULL,
  `destroyed_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_bastion_registrations`
--

CREATE TABLE `uni1_pve_bastion_registrations` (
  `id` bigint(20) NOT NULL,
  `event_id` bigint(20) NOT NULL,
  `ally_id` int(11) NOT NULL,
  `registered_by` int(11) NOT NULL,
  `registered_at` int(11) NOT NULL,
  `paid_ntx` int(11) NOT NULL DEFAULT 0,
  `paid_at` int(11) DEFAULT NULL,
  `members_at_spawn` int(11) NOT NULL DEFAULT 0,
  `bastion_ghost_user_id` int(11) NOT NULL DEFAULT 0,
  `bastion_planet_id` int(11) NOT NULL DEFAULT 0,
  `bastion_hp_max` bigint(20) NOT NULL DEFAULT 0,
  `bastion_hp_current` bigint(20) NOT NULL DEFAULT 0,
  `bastions_spawned` int(11) NOT NULL DEFAULT 0,
  `bastions_breached` int(11) NOT NULL DEFAULT 0,
  `score_total` bigint(20) NOT NULL DEFAULT 0,
  `pirates_killed` bigint(20) NOT NULL DEFAULT 0,
  `boss_pirates_killed` int(11) NOT NULL DEFAULT 0,
  `waves_survived` int(11) NOT NULL DEFAULT 0,
  `waves_total` int(11) NOT NULL DEFAULT 0,
  `pct_hp_preserved` decimal(5,2) NOT NULL DEFAULT 0.00,
  `pct_hp_total` decimal(8,2) NOT NULL DEFAULT 0.00,
  `reinforcement_attacks` int(11) NOT NULL DEFAULT 0,
  `members_reinforced` int(11) NOT NULL DEFAULT 0,
  `last_hit` int(11) DEFAULT NULL,
  `next_wave_at` int(11) DEFAULT NULL,
  `status` enum('registered','cancelled','refunded','active','winner','lost') NOT NULL DEFAULT 'registered',
  `refunded_at` int(11) DEFAULT NULL,
  `prize_given` tinyint(1) NOT NULL DEFAULT 0,
  `prize_given_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_bastion_waves`
--

CREATE TABLE `uni1_pve_bastion_waves` (
  `id` bigint(20) NOT NULL,
  `event_id` bigint(20) NOT NULL,
  `registration_id` bigint(20) NOT NULL,
  `ally_id` int(11) NOT NULL,
  `wave_number` int(11) NOT NULL,
  `phase` enum('calm','surge','siege','hell') NOT NULL DEFAULT 'calm',
  `fleet_json` text NOT NULL,
  `total_ships` int(11) NOT NULL DEFAULT 0,
  `is_boss_wave` tinyint(1) NOT NULL DEFAULT 0,
  `spawn_time` int(11) NOT NULL,
  `arrival_time` int(11) NOT NULL,
  `resolved` tinyint(1) NOT NULL DEFAULT 0,
  `result` enum('pending','defended','breached','partial') NOT NULL DEFAULT 'pending',
  `pirates_killed` bigint(20) NOT NULL DEFAULT 0,
  `pirates_survived` bigint(20) NOT NULL DEFAULT 0,
  `damage_to_bastion` bigint(20) NOT NULL DEFAULT 0,
  `reinforcement_damage` bigint(20) NOT NULL DEFAULT 0,
  `reinforcements_sent` int(11) NOT NULL DEFAULT 0,
  `reinforcements_lost` int(11) NOT NULL DEFAULT 0,
  `resolved_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_boss_damage`
--

CREATE TABLE `uni1_pve_boss_damage` (
  `id` bigint(20) NOT NULL,
  `event_id` bigint(20) NOT NULL,
  `registration_id` bigint(20) NOT NULL,
  `ally_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `damage_done` bigint(20) NOT NULL DEFAULT 0,
  `attacks_count` int(11) NOT NULL DEFAULT 0,
  `first_hit` int(11) NOT NULL,
  `last_hit` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_boss_event`
--

CREATE TABLE `uni1_pve_boss_event` (
  `id` bigint(20) NOT NULL,
  `boss_name` varchar(64) NOT NULL DEFAULT 'El Devorador Estelar',
  `entry_mode` enum('free','paid') NOT NULL DEFAULT 'free',
  `entry_cost_ntx` int(11) NOT NULL DEFAULT 0,
  `prize_type` enum('metal','crystal','deuterium','dark_matter','ntx') NOT NULL DEFAULT 'ntx',
  `prize_metal` bigint(20) NOT NULL DEFAULT 0,
  `prize_crystal` bigint(20) NOT NULL DEFAULT 0,
  `prize_deuterium` bigint(20) NOT NULL DEFAULT 0,
  `prize_dark_matter` bigint(20) NOT NULL DEFAULT 0,
  `prize_ntx` int(11) NOT NULL DEFAULT 0,
  `prize_scales_with_allies` tinyint(1) NOT NULL DEFAULT 0,
  `project_fee_pct` tinyint(3) NOT NULL DEFAULT 5,
  `winner_distribution` enum('leader','by_contribution','equal') NOT NULL DEFAULT 'by_contribution',
  `min_alliances` tinyint(3) NOT NULL DEFAULT 2,
  `max_alliances` tinyint(3) NOT NULL DEFAULT 20,
  `hp_per_member` int(11) NOT NULL DEFAULT 500000,
  `hp_min` bigint(20) NOT NULL DEFAULT 10000000,
  `duration_hours` int(11) NOT NULL DEFAULT 48,
  `status` enum('scheduled','registration','active','finished','cancelled') NOT NULL DEFAULT 'scheduled',
  `created_by` int(11) NOT NULL,
  `created_at` int(11) NOT NULL,
  `registration_start` int(11) NOT NULL,
  `registration_end` int(11) NOT NULL,
  `start_time` int(11) NOT NULL,
  `end_time` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `cancel_reason` varchar(255) DEFAULT NULL,
  `total_pool_ntx` int(11) NOT NULL DEFAULT 0,
  `winner_registration_id` bigint(20) DEFAULT NULL,
  `winner_ally_id` int(11) DEFAULT NULL,
  `winner_damage` bigint(20) DEFAULT NULL,
  `winner_pct` decimal(8,2) DEFAULT NULL,
  `total_damage` bigint(20) NOT NULL DEFAULT 0,
  `total_ghosts_spawned` int(11) NOT NULL DEFAULT 0,
  `total_ghosts_killed` int(11) NOT NULL DEFAULT 0,
  `counter_enabled` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_boss_ghosts`
--

CREATE TABLE `uni1_pve_boss_ghosts` (
  `id` bigint(20) NOT NULL,
  `event_id` bigint(20) NOT NULL,
  `registration_id` bigint(20) NOT NULL,
  `ally_id` int(11) NOT NULL,
  `spawn_number` int(11) NOT NULL,
  `ghost_user_id` int(11) NOT NULL,
  `ghost_planet_id` int(11) NOT NULL,
  `galaxy` tinyint(3) NOT NULL,
  `system` smallint(5) NOT NULL,
  `planet` tinyint(3) NOT NULL,
  `hp_max` bigint(20) NOT NULL,
  `hp_current` bigint(20) NOT NULL,
  `damage_done` bigint(20) NOT NULL DEFAULT 0,
  `pct_damage` decimal(5,2) NOT NULL DEFAULT 0.00,
  `phase` tinyint(1) NOT NULL DEFAULT 1,
  `counter_next_at` int(11) DEFAULT NULL,
  `counter_last_targets` text DEFAULT NULL,
  `ships_json` text NOT NULL,
  `defenses_json` text NOT NULL,
  `status` enum('active','killed','expired','destroyed') NOT NULL DEFAULT 'active',
  `spawned_at` int(11) NOT NULL,
  `killed_at` int(11) DEFAULT NULL,
  `killed_by` int(11) DEFAULT NULL,
  `destroyed_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_boss_registrations`
--

CREATE TABLE `uni1_pve_boss_registrations` (
  `id` bigint(20) NOT NULL,
  `event_id` bigint(20) NOT NULL,
  `ally_id` int(11) NOT NULL,
  `registered_by` int(11) NOT NULL,
  `registered_at` int(11) NOT NULL,
  `paid_ntx` int(11) NOT NULL DEFAULT 0,
  `paid_at` int(11) DEFAULT NULL,
  `members_at_spawn` int(11) NOT NULL DEFAULT 0,
  `ghosts_spawned` int(11) NOT NULL DEFAULT 0,
  `ghosts_killed` int(11) NOT NULL DEFAULT 0,
  `total_damage` bigint(20) NOT NULL DEFAULT 0,
  `pct_damage` decimal(5,2) NOT NULL DEFAULT 0.00,
  `pct_damage_total` decimal(8,2) NOT NULL DEFAULT 0.00,
  `attacks_count` int(11) NOT NULL DEFAULT 0,
  `members_attacked` int(11) NOT NULL DEFAULT 0,
  `last_hit` int(11) DEFAULT NULL,
  `next_respawn_at` int(11) DEFAULT NULL,
  `status` enum('registered','cancelled','refunded','active','winner','lost') NOT NULL DEFAULT 'registered',
  `refunded_at` int(11) DEFAULT NULL,
  `prize_given` tinyint(1) NOT NULL DEFAULT 0,
  `prize_given_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_config`
--

CREATE TABLE `uni1_pve_config` (
  `id` int(11) NOT NULL,
  `config_key` varchar(64) NOT NULL,
  `config_value` text DEFAULT NULL,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `uni1_pve_config`
--

INSERT INTO `uni1_pve_config` (`id`, `config_key`, `config_value`, `updated_at`) VALUES
(1, 'achievement_months_1', '2', 1791504043),
(2, 'achievement_months_6', '5', 1791504043),
(3, 'achievement_months_12', '10', 1791504043),
(4, 'crisis_base_mult', '30', 1791504043),
(5, 'crisis_day', '25', 1791504043),
(6, 'crisis_duration_hours', '24', 1791504043),
(7, 'crisis_faction_current', '1', 1791504043),
(8, 'crisis_flight_max', '120', 1791504043),
(9, 'crisis_flight_min', '30', 1791504043),
(10, 'crisis_hour', '10', 1791504043),
(11, 'crisis_minute', '30', 1791504043),
(12, 'crisis_mult_advanced', '6', 1791504043),
(13, 'crisis_mult_beginner', '1', 1791504043),
(14, 'crisis_mult_elite', '10', 1791504043),
(15, 'crisis_mult_intermediate', '3', 1791504043),
(16, 'crisis_mult_legendary', '20', 1791504043),
(17, 'crisis_notice_days', '3', 1791504043),
(18, 'crisis_wave_interval_minutes', '1', 1791504043),
(19, 'crisis_wave_mult', '1.5', 1791504043),
(20, 'crisis_waves', '5', 1791504043),
(21, 'crisis_reward_type', 'ntx', 1791504043),
(22, 'crisis_reward_ntx', '5', 1791504043),
(23, 'crisis_reward_metal', '0', 1791504043),
(24, 'crisis_reward_crystal', '0', 1791504043),
(25, 'crisis_reward_deuterium', '0', 1791504043),
(26, 'crisis_reward_split', 'per_player', 1791504043),
(27, 'crisis_cleanup_immediate', '1', 1791504043),
(28, 'crisis_cleanup_orphans', '1', 1791504043),
(29, 'crisis_cleanup_deep', '1', 1791504043),
(30, 'crisis_cleanup_keep_history', '0', 1791504043),
(31, 'crisis_cleanup_log_after_days', '30', 1791504043),
(32, 'crisis_cleanup_rewards_after_days', '7', 1791504043),
(33, 'empire_attacks_per_user', '5', 1791504043),
(34, 'empire_count', '1', 1791504043),
(35, 'empire_counter_naves', '20', 1791504043),
(36, 'empire_counterattack_pct', '30', 1791504043),
(37, 'empire_duration_hours', '24', 1791504043),
(38, 'empire_hp_mult', '5', 1791504043),
(39, 'empire_loot_pct', '100', 1791504043),
(40, 'empire_scheduled_time', '0', 1791504043),
(41, 'pve_enabled', '1', 1791504043),
(42, 'pve_crisis_enabled', '1', 1791504043),
(43, 'pve_empire_enabled', '1', 1791504043),
(44, 'pve_acs_enabled', '1', 1791504043),
(45, 'boss_enabled', '1', 1791504043),
(46, 'boss_default_name', 'El Devorador Estelar', 1791504043),
(47, 'boss_duration_hours', '2', 1791504043),
(48, 'boss_registration_hours', '1', 1791504043),
(49, 'boss_hp_per_member', '500000', 1791504043),
(50, 'boss_hp_min', '10000000', 1791504043),
(51, 'boss_min_alliances', '1', 1791504043),
(52, 'boss_max_alliances', '20', 1791504043),
(53, 'boss_phase2_threshold', '70', 1791504043),
(54, 'boss_phase3_threshold', '30', 1791504043),
(55, 'boss_phase2_damage_mult', '2', 1791504043),
(56, 'boss_phase3_damage_mult', '3', 1791504043),
(57, 'boss_phase3_hp_halve', '1', 1791504043),
(58, 'boss_phase3_fleet_mult', '3', 1791504043),
(59, 'boss_phase_transition_notify', '1', 1791504043),
(60, 'boss_phase2_counter_interval', '270', 1791504043),
(61, 'boss_phase3_counter_interval', '240', 1791504043),
(62, 'boss_counter_targets', '1', 1791504043),
(63, 'boss_counter_skip_offline', '1', 1791504043),
(64, 'boss_counter_avoid_repeat', '1', 1791504043),
(65, 'boss_counter_min_fleet_pct', '5', 1791504043),
(66, 'boss_counter_warn_seconds', '120', 1791504043),
(67, 'boss_respawn_enabled', '1', 1791504043),
(68, 'boss_respawn_cooldown_min', '5', 1791504043),
(69, 'boss_max_respawns_per_ally', '0', 1791504043),
(70, 'boss_respawn_block_last_hours', '1', 1791504043),
(71, 'boss_default_entry_mode', 'free', 1791504043),
(72, 'boss_default_entry_cost_ntx', '50', 1791504043),
(73, 'boss_default_prize_type', 'ntx', 1791504043),
(74, 'boss_default_prize_ntx', '500', 1791504043),
(75, 'boss_default_prize_metal', '100000000', 1791504043),
(76, 'boss_default_prize_crystal', '50000000', 1791504043),
(77, 'boss_default_prize_deuterium', '20000000', 1791504043),
(78, 'boss_default_prize_dark_matter', '50000', 1791504043),
(79, 'boss_project_fee_pct', '5', 1791504043),
(80, 'boss_winner_distribution', 'by_contribution', 1791504043),
(81, 'boss_ranking_live_interval', '10', 1791504043),
(82, 'boss_ranking_top_show', '20', 1791504043),
(83, 'boss_refund_on_cancel', '1', 1791504043),
(84, 'boss_refund_if_min_not_reached', '1', 1791504043),
(85, 'pve_boss_enabled', '1', 1791504043),
(86, 'crisis_auto_schedule_enabled', '0', 1791504043),
(87, 'crisis_auto_schedule_last_month', '0', 1791504043),
(88, 'boss_auto_schedule_enabled', '0', 1791504043),
(89, 'boss_schedule_day', '10', 1791504043),
(90, 'boss_schedule_hour', '23', 1791504043),
(91, 'boss_schedule_minute', '55', 1791504043),
(92, 'boss_schedule_last_month', '0', 1791504043),
(93, 'bastion_enabled', '1', 1791504043),
(94, 'pve_bastion_enabled', '1', 1791504043),
(95, 'bastion_default_name', 'El Bastión de la Alianza', 1791504043),
(96, 'bastion_duration_hours', '48', 1791504043),
(97, 'bastion_registration_hours', '24', 1791504043),
(98, 'bastion_min_alliances', '2', 1791504043),
(99, 'bastion_max_alliances', '20', 1791504043),
(100, 'bastion_hp_per_member', '500000', 1791504043),
(101, 'bastion_hp_min', '10000000', 1791504043),
(102, 'bastion_template_id', '0', 1791504043),
(103, 'bastion_default_entry_mode', 'free', 1791504043),
(104, 'bastion_default_entry_cost_ntx', '50', 1791504043),
(105, 'bastion_project_fee_pct', '5', 1791504043),
(106, 'bastion_default_prize_type', 'ntx', 1791504043),
(107, 'bastion_default_prize_ntx', '500', 1791504043),
(108, 'bastion_default_prize_metal', '100000000', 1791504043),
(109, 'bastion_default_prize_crystal', '50000000', 1791504043),
(110, 'bastion_default_prize_deuterium', '20000000', 1791504043),
(111, 'bastion_default_prize_dark_matter', '50000', 1791504043),
(112, 'bastion_winner_distribution', 'by_contribution', 1791504043),
(113, 'bastion_refund_on_cancel', '1', 1791504043),
(114, 'bastion_refund_if_min_not_reached', '1', 1791504043),
(115, 'bastion_ships_return_on_end', '1', 1791504043),
(116, 'bastion_phase_calm_end', '6', 1791504043),
(117, 'bastion_phase_surge_end', '24', 1791504043),
(118, 'bastion_phase_siege_end', '40', 1791504043),
(119, 'bastion_wave_interval_calm', '360', 1791504043),
(120, 'bastion_wave_interval_surge', '180', 1791504043),
(121, 'bastion_wave_interval_siege', '120', 1791504043),
(122, 'bastion_wave_interval_hell', '60', 1791504043),
(123, 'bastion_pirate_flight_min', '30', 1791504043),
(124, 'bastion_pirate_flight_max', '90', 1791504043),
(125, 'bastion_pirate_mult_calm', '1', 1791504043),
(126, 'bastion_pirate_mult_surge', '2', 1791504043),
(127, 'bastion_pirate_mult_siege', '4', 1791504043),
(128, 'bastion_pirate_mult_hell', '8', 1791504043),
(129, 'bastion_pirate_base_fleet_json', '{\"204\":100,\"205\":50,\"206\":25,\"207\":10}', 1791504043),
(130, 'bastion_boss_pirate_chance_calm', '0', 1791504043),
(131, 'bastion_boss_pirate_chance_surge', '10', 1791504043),
(132, 'bastion_boss_pirate_chance_siege', '20', 1791504043),
(133, 'bastion_boss_pirate_chance_hell', '35', 1791504043),
(134, 'bastion_boss_pirate_fleet_json', '{\"204\":500,\"205\":200,\"211\":50,\"213\":20}', 1791504043),
(135, 'bastion_score_per_pirate', '100', 1791504043),
(136, 'bastion_score_hp_pct_weight', '50', 1791504043),
(137, 'bastion_score_per_boss_pirate', '500', 1791504043),
(138, 'bastion_reinforcement_max_pct', '200', 1791504043),
(139, 'bastion_ranking_live_interval', '10', 1791504043),
(140, 'bastion_ranking_top_show', '20', 1791504043),
(141, 'bastion_auto_schedule_enabled', '0', 1791504043),
(142, 'bastion_schedule_day', '20', 1791504043),
(143, 'bastion_schedule_hour', '20', 1791504043),
(144, 'bastion_schedule_minute', '0', 1791504043),
(145, 'bastion_schedule_last_month', '0', 1791504043);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_crisis`
--

CREATE TABLE `uni1_pve_crisis` (
  `id` int(11) NOT NULL,
  `ghost_user_id` int(11) DEFAULT NULL,
  `ghost_planet_id` int(11) DEFAULT NULL,
  `faction` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1=Piratas,2=Aliens,3=Máquinas,4=Fantasmas',
  `total_waves` tinyint(2) NOT NULL DEFAULT 5,
  `current_wave` tinyint(2) NOT NULL DEFAULT 0,
  `start_time` int(11) NOT NULL DEFAULT 0,
  `end_time` int(11) NOT NULL DEFAULT 0,
  `status` enum('scheduled','active','finished') NOT NULL DEFAULT 'scheduled',
  `processing` tinyint(1) NOT NULL DEFAULT 0,
  `players_affected` int(11) NOT NULL DEFAULT 0,
  `players_survived` int(11) NOT NULL DEFAULT 0,
  `total_damage` bigint(20) NOT NULL DEFAULT 0,
  `total_resources_stolen` bigint(20) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_crisis_attacks`
--

CREATE TABLE `uni1_pve_crisis_attacks` (
  `id` bigint(20) NOT NULL,
  `crisis_id` int(11) NOT NULL,
  `wave_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `planet_id` int(11) NOT NULL,
  `difficulty_level` tinyint(1) NOT NULL DEFAULT 1,
  `ships_lost` int(11) NOT NULL DEFAULT 0,
  `defenses_lost` int(11) NOT NULL DEFAULT 0,
  `resources_stolen` bigint(20) NOT NULL DEFAULT 0,
  `damage_done` bigint(20) NOT NULL DEFAULT 0,
  `survived` tinyint(1) NOT NULL DEFAULT 0,
  `attack_time` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_crisis_waves`
--

CREATE TABLE `uni1_pve_crisis_waves` (
  `id` int(11) NOT NULL,
  `crisis_id` int(11) NOT NULL,
  `wave_number` tinyint(2) NOT NULL,
  `faction` tinyint(1) NOT NULL DEFAULT 1,
  `power_multiplier` decimal(5,2) NOT NULL DEFAULT 1.00,
  `ships_count` int(11) NOT NULL DEFAULT 0,
  `executed` tinyint(1) NOT NULL DEFAULT 0,
  `executed_at` int(11) NOT NULL DEFAULT 0,
  `total_damage_done` bigint(20) NOT NULL DEFAULT 0,
  `total_resources_stolen` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_empires`
--

CREATE TABLE `uni1_pve_empires` (
  `id` int(11) NOT NULL,
  `template_id` int(11) DEFAULT NULL,
  `ghost_user_id` int(11) DEFAULT NULL,
  `ghost_planet_id` int(11) DEFAULT NULL,
  `galaxy` int(11) NOT NULL DEFAULT 0,
  `system` int(11) NOT NULL DEFAULT 0,
  `planet` int(11) NOT NULL DEFAULT 0,
  `name` varchar(128) NOT NULL DEFAULT 'Imperio Caído',
  `faction` tinyint(1) NOT NULL DEFAULT 1,
  `total_hp` bigint(20) NOT NULL DEFAULT 0,
  `current_hp` bigint(20) NOT NULL DEFAULT 0,
  `total_ships` int(11) NOT NULL DEFAULT 0,
  `current_ships` int(11) NOT NULL DEFAULT 0,
  `status` enum('scheduled','active','destroyed','expired') NOT NULL DEFAULT 'scheduled',
  `start_time` int(11) NOT NULL DEFAULT 0,
  `end_time` int(11) NOT NULL DEFAULT 0,
  `destroyed_at` int(11) NOT NULL DEFAULT 0,
  `destroyed_by` int(11) NOT NULL DEFAULT 0,
  `total_damage_received` bigint(20) NOT NULL DEFAULT 0,
  `total_attacks` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0,
  `ships_config` text DEFAULT NULL,
  `defenses_config` text DEFAULT NULL,
  `resources_config` text DEFAULT NULL,
  `buildings_config` text DEFAULT NULL,
  `waves_config` text DEFAULT NULL,
  `generated_at` int(11) NOT NULL DEFAULT 0,
  `last_regen_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_empire_attacks`
--

CREATE TABLE `uni1_pve_empire_attacks` (
  `id` bigint(20) NOT NULL,
  `empire_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `planet_id` int(11) NOT NULL,
  `fleet_id` int(11) NOT NULL DEFAULT 0,
  `ships_sent` text DEFAULT NULL,
  `ships_lost` int(11) NOT NULL DEFAULT 0,
  `damage_done` bigint(20) NOT NULL DEFAULT 0,
  `resources_looted` bigint(20) NOT NULL DEFAULT 0,
  `counterattacked` tinyint(1) NOT NULL DEFAULT 0,
  `counterattack_ships_lost` int(11) NOT NULL DEFAULT 0,
  `counterattack_resources_lost` bigint(20) NOT NULL DEFAULT 0,
  `attack_time` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_empire_templates`
--

CREATE TABLE `uni1_pve_empire_templates` (
  `id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `slug` varchar(32) NOT NULL,
  `description` text DEFAULT NULL,
  `hp_mult` decimal(10,2) NOT NULL DEFAULT 5.00,
  `res_metal` bigint(20) NOT NULL DEFAULT 0,
  `res_crystal` bigint(20) NOT NULL DEFAULT 0,
  `res_deuterium` bigint(20) NOT NULL DEFAULT 0,
  `ships` text DEFAULT NULL,
  `defenses` text DEFAULT NULL,
  `buildings` text DEFAULT NULL,
  `travel_mode` enum('instant','scheduled','random','fixed') NOT NULL DEFAULT 'random',
  `travel_min` int(11) NOT NULL DEFAULT 30,
  `travel_max` int(11) NOT NULL DEFAULT 120,
  `travel_fixed` int(11) NOT NULL DEFAULT 60,
  `scheduled_day` tinyint(2) NOT NULL DEFAULT 0,
  `scheduled_hour` tinyint(2) NOT NULL DEFAULT 0,
  `scheduled_minute` tinyint(2) NOT NULL DEFAULT 0,
  `fleet_speed_pct` smallint(5) NOT NULL DEFAULT 100,
  `waves_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `waves_count` tinyint(2) NOT NULL DEFAULT 1,
  `waves_delay_min` int(11) NOT NULL DEFAULT 10,
  `regen_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `regen_interval_min` int(11) NOT NULL DEFAULT 15,
  `regen_pct` decimal(5,2) NOT NULL DEFAULT 10.00,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` int(11) NOT NULL DEFAULT 0,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_ghosts`
--

CREATE TABLE `uni1_pve_ghosts` (
  `id` int(11) NOT NULL,
  `event_type` enum('crisis','empire','boss','bastion') NOT NULL,
  `event_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `planet_id` int(11) NOT NULL,
  `galaxy` int(11) NOT NULL DEFAULT 0,
  `system` int(11) NOT NULL DEFAULT 0,
  `planet` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0,
  `destroyed_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_log`
--

CREATE TABLE `uni1_pve_log` (
  `id` bigint(20) NOT NULL,
  `event_type` enum('crisis','empire','system','admin','cron','boss','bastion') NOT NULL,
  `event_id` int(11) NOT NULL DEFAULT 0,
  `action` varchar(64) NOT NULL,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `planet_id` int(11) NOT NULL DEFAULT 0,
  `details` text DEFAULT NULL,
  `ip_address` varchar(45) NOT NULL DEFAULT '',
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pve_rewards`
--

CREATE TABLE `uni1_pve_rewards` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_type` enum('crisis','empire','boss','bastion') NOT NULL,
  `event_id` int(11) NOT NULL,
  `reward_type` enum('resources','ships','defenses','ntx','mo','chest','dark_matter') NOT NULL,
  `reward_data` text DEFAULT NULL,
  `claimed` tinyint(1) NOT NULL DEFAULT 0,
  `claimed_at` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_achievements`
--

CREATE TABLE `uni1_pvp_achievements` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `achievement` varchar(64) NOT NULL,
  `unlocked_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_arenas`
--

CREATE TABLE `uni1_pvp_arenas` (
  `id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `mode` enum('1v1','2v2','3v3') NOT NULL DEFAULT '1v1',
  `entry_fee` bigint(20) NOT NULL DEFAULT 0,
  `prize_pool` bigint(20) NOT NULL DEFAULT 0,
  `status` enum('waiting','active','extra_time','finished','cancelled') NOT NULL DEFAULT 'waiting',
  `current_players` tinyint(3) NOT NULL DEFAULT 0,
  `max_players` tinyint(3) NOT NULL DEFAULT 2,
  `winner_team` tinyint(3) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0,
  `starts_at` int(11) NOT NULL DEFAULT 0,
  `ends_at` int(11) NOT NULL DEFAULT 0,
  `extra_time_ends_at` int(11) NOT NULL DEFAULT 0,
  `claim_deadline` int(11) NOT NULL DEFAULT 0,
  `finished_at` int(11) NOT NULL DEFAULT 0,
  `universe` tinyint(3) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_arena_attacks`
--

CREATE TABLE `uni1_pvp_arena_attacks` (
  `id` int(11) NOT NULL,
  `arena_id` int(11) NOT NULL,
  `attacker_id` int(11) NOT NULL,
  `defender_id` int(11) NOT NULL,
  `fleet_id` int(11) NOT NULL DEFAULT 0,
  `ships_destroyed` int(11) NOT NULL DEFAULT 0,
  `defenses_destroyed` int(11) NOT NULL DEFAULT 0,
  `damage_done` bigint(20) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_arena_players`
--

CREATE TABLE `uni1_pvp_arena_players` (
  `id` int(11) NOT NULL,
  `arena_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `team` tinyint(3) NOT NULL DEFAULT 0,
  `is_leader` tinyint(1) NOT NULL DEFAULT 0,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  `joined_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_config`
--

CREATE TABLE `uni1_pvp_config` (
  `config_key` varchar(64) NOT NULL,
  `config_value` text NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_pvp_config`
--

INSERT INTO `uni1_pvp_config` (`config_key`, `config_value`, `updated_at`) VALUES
('arena_1v1_max', '10000', 1791504045),
('arena_1v1_min', '10', 1791504045),
('arena_2v2_price', '50', 1791504045),
('arena_3v3_price', '100', 1791504045),
('arena_claim_days', '4', 1791504045),
('arena_duration_hours', '48', 1791504045),
('arena_enabled', '1', 1791504045),
('arena_expire_hours', '24', 1791504045),
('arena_extra_hours', '5', 1791504045),
('tournament_commission', '5', 1791504045),
('tournament_enabled', '1', 1791504045);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_log`
--

CREATE TABLE `uni1_pvp_log` (
  `id` bigint(20) NOT NULL,
  `event_type` enum('arena','tournament','system','admin','cron') NOT NULL,
  `event_id` int(11) NOT NULL DEFAULT 0,
  `action` varchar(64) NOT NULL,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `details` text DEFAULT NULL,
  `ip_address` varchar(45) NOT NULL DEFAULT '',
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_tournaments`
--

CREATE TABLE `uni1_pvp_tournaments` (
  `id` int(11) NOT NULL,
  `type` enum('1v1','alliance') NOT NULL DEFAULT '1v1',
  `mode` enum('single','double_elimination') NOT NULL DEFAULT 'single',
  `status` enum('registration','running','finished','cancelled') NOT NULL DEFAULT 'registration',
  `entry_fee` bigint(20) NOT NULL DEFAULT 0,
  `alliance_entry_fee` bigint(20) NOT NULL DEFAULT 0,
  `prize_pool` bigint(20) NOT NULL DEFAULT 0,
  `commission_pct` tinyint(3) NOT NULL DEFAULT 5,
  `max_players` tinyint(3) NOT NULL DEFAULT 8,
  `current_players` tinyint(3) NOT NULL DEFAULT 0,
  `current_round` tinyint(3) NOT NULL DEFAULT 0,
  `round_duration` int(11) NOT NULL DEFAULT 86400,
  `registration_ends_at` int(11) NOT NULL DEFAULT 0,
  `starts_at` int(11) NOT NULL DEFAULT 0,
  `finished_at` int(11) NOT NULL DEFAULT 0,
  `winners_config` text DEFAULT NULL,
  `created_by` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0,
  `universe` tinyint(3) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_tournament_attacks`
--

CREATE TABLE `uni1_pvp_tournament_attacks` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `match_id` int(11) NOT NULL DEFAULT 0,
  `attacker_id` int(11) NOT NULL,
  `defender_id` int(11) NOT NULL,
  `fleet_id` int(11) NOT NULL DEFAULT 0,
  `ships_destroyed` int(11) NOT NULL DEFAULT 0,
  `defenses_destroyed` int(11) NOT NULL DEFAULT 0,
  `damage_done` bigint(20) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_tournament_matches`
--

CREATE TABLE `uni1_pvp_tournament_matches` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `round_id` int(11) NOT NULL,
  `match_number` int(11) NOT NULL DEFAULT 1,
  `bracket_type` enum('winners','losers','final') NOT NULL DEFAULT 'winners',
  `player1_id` int(11) NOT NULL DEFAULT 0,
  `player2_id` int(11) NOT NULL DEFAULT 0,
  `winner_id` int(11) NOT NULL DEFAULT 0,
  `status` enum('pending','active','finished') NOT NULL DEFAULT 'pending',
  `created_at` int(11) NOT NULL DEFAULT 0,
  `resolved_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_tournament_players`
--

CREATE TABLE `uni1_pvp_tournament_players` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `alliance_id` int(11) NOT NULL DEFAULT 0,
  `is_alliance` tinyint(1) NOT NULL DEFAULT 0,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  `payment_source` enum('bank','user','none') NOT NULL DEFAULT 'none',
  `eliminated` tinyint(1) NOT NULL DEFAULT 0,
  `eliminated_round` tinyint(3) NOT NULL DEFAULT 0,
  `final_position` tinyint(3) NOT NULL DEFAULT 0,
  `registered_at` int(11) NOT NULL DEFAULT 0,
  UNIQUE KEY `uniq_tournament_user` (`tournament_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_pvp_tournament_rounds`
--

CREATE TABLE `uni1_pvp_tournament_rounds` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `round_number` tinyint(3) NOT NULL DEFAULT 1,
  `starts_at` int(11) NOT NULL DEFAULT 0,
  `ends_at` int(11) NOT NULL DEFAULT 0,
  `status` enum('pending','active','finished') NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_races`
--

CREATE TABLE `uni1_races` (
  `race_id` int(11) NOT NULL,
  `race_name` varchar(50) NOT NULL,
  `race_desc` text NOT NULL,
  `race_icon` varchar(20) NOT NULL,
  `race_color` varchar(10) NOT NULL DEFAULT '#00ccff',
  `bonus_attack` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_defense` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_shield` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_resources` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_metal` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_crystal` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_deuterium` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_energy` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_storage` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_fleet_storage` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_fleet_capacity` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_fleet_slots` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_speed` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_fuel` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_expeditions` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_exp_resources` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_exp_darkmatter` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_spy` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_jumpgate` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_debris` decimal(6,2) NOT NULL DEFAULT 0.00,
  `bonus_trade_ratio` decimal(6,2) NOT NULL DEFAULT 0.00
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_races`
--

INSERT INTO `uni1_races` (`race_id`, `race_name`, `race_desc`, `race_icon`, `race_color`, `bonus_attack`, `bonus_defense`, `bonus_shield`, `bonus_resources`, `bonus_metal`, `bonus_crystal`, `bonus_deuterium`, `bonus_energy`, `bonus_storage`, `bonus_fleet_storage`, `bonus_fleet_capacity`, `bonus_fleet_slots`, `bonus_speed`, `bonus_fuel`, `bonus_expeditions`, `bonus_exp_resources`, `bonus_exp_darkmatter`, `bonus_spy`, `bonus_jumpgate`, `bonus_debris`, `bonus_trade_ratio`) VALUES
(1, 'PREDATORS', 'Cazadores natos. Especialistas en combate y espionaje rápido.', 'PRED', '#ff4488', 5.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2.00, 0.00, 0.00, 0.00, 0.00, 0.00, 10.00, -5.00, 0.00, 0.00),
(2, 'ALIENS', 'Exploradores del espacio profundo. Expertos en expediciones.', 'ALIE', '#aa44ff', 0.00, 5.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2.00, 10.00, 10.00, 0.00, 0.00, 0.00, 0.00),
(3, 'CHARTER', 'Mercenarios eficientes. Reducen costes y aprovechan escombros.', 'CHAR', '#00ccff', 0.00, 0.00, 5.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 10.00, 0.00, 0.00, -5.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2.00, 0.00),
(4, 'SARCKS', 'Imperio industrial. Producción masiva y almacenes enormes.', 'SARC', '#66ff99', 0.00, 0.00, 0.00, 5.00, 0.00, 0.00, 0.00, 5.00, 5.00, 5.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(5, 'ESPECTROS', 'Sombras veloces. Maestros del espionaje y la velocidad.', 'ESPE', '#88ddff', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.00, 15.00, 0.00, 0.00, 0.00, 0.00, 10.00, 0.00, 0.00, 0.00),
(6, 'MERCADERES', 'Reyes del comercio. Carga enorme y saqueos óptimos.', 'MERC', '#ffcc00', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 15.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_raffles`
--

CREATE TABLE `uni1_raffles` (
  `id` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL DEFAULT '',
  `descripcion` text DEFAULT NULL,
  `moneda` enum('metal','crystal','deuterium','darkmatter','ntx20') NOT NULL DEFAULT 'ntx20',
  `precio_boleto` int(11) NOT NULL DEFAULT 0,
  `max_boletos` int(11) NOT NULL DEFAULT 100,
  `boletos_vendidos` int(11) NOT NULL DEFAULT 0,
  `cantidad_lugares` int(11) NOT NULL DEFAULT 1,
  `duracion` enum('24h','7d','15d') NOT NULL DEFAULT '7d',
  `estado` enum('activo','finalizado') NOT NULL DEFAULT 'activo',
  `ganador_id` int(11) DEFAULT NULL,
  `boleto_ganador` int(11) DEFAULT NULL,
  `semilla` int(11) DEFAULT NULL,
  `hash_verificacion` varchar(64) DEFAULT NULL,
  `fecha_inicio` int(11) NOT NULL DEFAULT 0,
  `fecha_fin` int(11) NOT NULL DEFAULT 0,
  `fecha_sorteo` int(11) DEFAULT NULL,
  `creado_por` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_raffle_log`
--

CREATE TABLE `uni1_raffle_log` (
  `id` int(11) NOT NULL,
  `raffle_id` int(11) NOT NULL DEFAULT 0,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `accion` varchar(50) NOT NULL DEFAULT '',
  `detalle` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_raffle_prizes`
--

CREATE TABLE `uni1_raffle_prizes` (
  `id` int(11) NOT NULL,
  `raffle_id` int(11) NOT NULL,
  `orden` int(11) NOT NULL DEFAULT 1,
  `tipo` enum('metal','crystal','deuterium','darkmatter','ntx20','nave','defensa','vip','pase') NOT NULL DEFAULT 'ntx20',
  `subtipo` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `ganador_id` int(11) DEFAULT NULL,
  `boleto_ganador` int(11) DEFAULT NULL,
  `fecha_entrega` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_raffle_tickets`
--

CREATE TABLE `uni1_raffle_tickets` (
  `id` int(11) NOT NULL,
  `raffle_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `boleto_numero` int(11) NOT NULL,
  `precio_pagado` int(11) NOT NULL DEFAULT 0,
  `moneda_pagada` varchar(20) NOT NULL DEFAULT 'ntx20',
  `ip_compra` varchar(45) DEFAULT NULL,
  `fecha_compra` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_raports`
--

CREATE TABLE `uni1_raports` (
  `rid` varchar(32) NOT NULL,
  `raport` text NOT NULL,
  `time` int(11) NOT NULL,
  `attacker` varchar(255) NOT NULL DEFAULT '',
  `defender` varchar(255) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_records`
--

CREATE TABLE `uni1_records` (
  `userID` int(10) UNSIGNED NOT NULL,
  `elementID` smallint(5) UNSIGNED NOT NULL,
  `level` double(255,0) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_session`
--

CREATE TABLE `uni1_session` (
  `sessionID` varchar(32) NOT NULL,
  `userID` int(10) UNSIGNED NOT NULL,
  `userIP` varchar(40) NOT NULL,
  `lastonline` int(11) NOT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_shop_autosave`
--

CREATE TABLE `uni1_shop_autosave` (
  `id` int(11) NOT NULL,
  `snapshot` longtext NOT NULL,
  `accion` varchar(100) NOT NULL DEFAULT '',
  `creado_por` int(11) NOT NULL DEFAULT 0,
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_shop_items`
--

CREATE TABLE `uni1_shop_items` (
  `id` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `tipo` varchar(32) NOT NULL DEFAULT 'recurso',
  `item_id` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_ntx` int(11) NOT NULL DEFAULT 0,
  `icono` varchar(20) DEFAULT NULL,
  `popular` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `expira` tinyint(1) NOT NULL DEFAULT 0,
  `expira_en` int(11) NOT NULL DEFAULT 0,
  `duracion_dias` int(11) NOT NULL DEFAULT 0,
  `orden` int(11) NOT NULL DEFAULT 0,
  `fecha_creacion` int(11) NOT NULL DEFAULT 0,
  `fecha_actualizacion` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_shop_items`
--

INSERT INTO `uni1_shop_items` (`id`, `nombre`, `descripcion`, `tipo`, `item_id`, `cantidad`, `precio_ntx`, `icono`, `popular`, `activo`, `expira`, `expira_en`, `duracion_dias`, `orden`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(7, 'Basico', '', 'cofre_common', 0, 3, 12, '', 0, 1, 0, 0, 0, 999, 1791663966, 1791774500),
(8, 'Basico medio', '', 'cofre_common', 0, 7, 25, '', 1, 1, 0, 0, 0, 995, 1791664066, 1791774539),
(9, 'Basico mayor', '', 'cofre_common', 0, 17, 49, '', 0, 1, 0, 0, 0, 999, 1791664094, 1791774597),
(10, 'Elite basico', '', 'cofre_rare', 0, 3, 8, '', 0, 0, 0, 0, 0, 999, 1791664304, 1791761037),
(11, 'Elite medio', '', 'cofre_rare', 0, 7, 16, '', 0, 0, 0, 0, 0, 999, 1791664337, 1791761042),
(12, 'Elite mayor', '', 'cofre_rare', 0, 17, 32, '', 0, 0, 0, 0, 0, 999, 1791664380, 1791761047),
(13, 'Plus basico', '', 'cofre_legendary', 0, 3, 12, '', 0, 0, 0, 0, 0, 999, 1791664482, 1792233622),
(14, 'Plus medio', '', 'cofre_legendary', 0, 7, 24, '', 0, 0, 0, 0, 0, 999, 1791664533, 1791761057),
(15, 'Plus Premium', '', 'cofre_legendary', 0, 17, 48, '', 0, 0, 0, 0, 0, 999, 1791664636, 1791761062);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_shop_purchases`
--

CREATE TABLE `uni1_shop_purchases` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL DEFAULT 0,
  `item_nombre` varchar(150) NOT NULL DEFAULT '',
  `item_tipo` varchar(20) NOT NULL DEFAULT '',
  `item_cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_base` int(11) NOT NULL DEFAULT 0,
  `precio_final` int(11) NOT NULL DEFAULT 0,
  `vip_aplicado` tinyint(1) NOT NULL DEFAULT 0,
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_shop_templates`
--

CREATE TABLE `uni1_shop_templates` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `snapshot` longtext NOT NULL,
  `creado_por` int(11) NOT NULL DEFAULT 0,
  `fecha_creacion` int(11) NOT NULL DEFAULT 0,
  `fecha_actualizacion` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_shortcuts`
--

CREATE TABLE `uni1_shortcuts` (
  `shortcutID` int(10) UNSIGNED NOT NULL,
  `ownerID` int(10) UNSIGNED NOT NULL,
  `name` varchar(32) NOT NULL,
  `galaxy` tinyint(3) UNSIGNED NOT NULL,
  `system` smallint(5) UNSIGNED NOT NULL,
  `planet` tinyint(3) UNSIGNED NOT NULL,
  `type` tinyint(1) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_statpoints`
--

CREATE TABLE `uni1_statpoints` (
  `id_owner` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `id_ally` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `stat_type` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `universe` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `tech_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `tech_old_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `tech_points` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `tech_count` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `build_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `build_old_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `build_points` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `build_count` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `defs_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `defs_old_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `defs_points` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `defs_count` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_old_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_points` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `fleet_count` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `total_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `total_old_rank` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `total_points` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `total_count` double(255,0) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_system`
--

CREATE TABLE `uni1_system` (
  `dbVersion` int(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_system`
--

INSERT INTO `uni1_system` (`dbVersion`) VALUES
(4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_tasks_catalog`
--

CREATE TABLE `uni1_tasks_catalog` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `type` enum('daily','weekly','once') NOT NULL DEFAULT 'once',
  `action` varchar(50) NOT NULL DEFAULT '',
  `target_amount` int(11) NOT NULL DEFAULT 1,
  `reward_type` varchar(20) NOT NULL DEFAULT 'ntx20',
  `reward_amount` int(11) NOT NULL DEFAULT 0,
  `external_url` varchar(255) DEFAULT '',
  `icon` varchar(50) DEFAULT '',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_tasks_catalog`
--

INSERT INTO `uni1_tasks_catalog` (`id`, `code`, `title`, `description`, `type`, `action`, `target_amount`, `reward_type`, `reward_amount`, `external_url`, `icon`, `sort_order`, `is_active`, `created_at`) VALUES
(1, 'telegram_join', 'Unirse al Grupo de Telegram', 'Vincula tu cuenta de Telegram y únete a nuestro grupo oficial para estar al día de todo.', 'once', 'telegram_join', 1, 'darkmatter', 200, 'https://t.me/+FwdrSAJU5rA5Yzcx', 'telegram', 1, 1, 1790171124),
(2, 'whatsapp_join', 'Unirse al Grupo de WhatsApp', 'Únete a nuestro grupo oficial de WhatsApp para recibir noticias y soporte.', 'once', 'whatsapp_join', 1, 'darkmatter', 200, 'https://chat.whatsapp.com/D50zNdaNu0n2JxqxtBmKiK', 'whatsapp', 2, 1, 1790171124),
(3, 'telegram_link', 'Vincular con el Bot de Telegram', 'Vincula tu cuenta con nuestro bot oficial. Sin este paso, no podrás operar en el Banco ni en el Mercado Negro.', 'once', 'telegram_link', 1, 'darkmatter', 100, 'https://t.me/Astrals_IO_bot', 'telegram_link', 3, 1, 1790171124);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_tasks_log`
--

CREATE TABLE `uni1_tasks_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `detalle` text DEFAULT NULL,
  `fecha` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_ticket`
--

CREATE TABLE `uni1_ticket` (
  `ticketID` int(10) UNSIGNED NOT NULL,
  `universe` tinyint(3) UNSIGNED NOT NULL,
  `ownerID` int(10) UNSIGNED NOT NULL,
  `categoryID` tinyint(1) UNSIGNED NOT NULL,
  `subject` varchar(255) NOT NULL,
  `status` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `time` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_ticket_answer`
--

CREATE TABLE `uni1_ticket_answer` (
  `answerID` int(10) UNSIGNED NOT NULL,
  `ownerID` int(10) UNSIGNED NOT NULL,
  `ownerName` varchar(32) NOT NULL,
  `ticketID` int(10) UNSIGNED NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` mediumtext NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_ticket_category`
--

CREATE TABLE `uni1_ticket_category` (
  `categoryID` int(11) NOT NULL,
  `name` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_ticket_category`
--

INSERT INTO `uni1_ticket_category` (`categoryID`, `name`) VALUES
(1, 'Support');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_topkb`
--

CREATE TABLE `uni1_topkb` (
  `rid` varchar(32) NOT NULL,
  `units` double(255,0) UNSIGNED NOT NULL,
  `result` varchar(1) NOT NULL,
  `time` int(11) NOT NULL,
  `universe` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_tourney`
--

CREATE TABLE `uni1_tourney` (
  `tourneyId` int(11) UNSIGNED NOT NULL,
  `tourneyName` varchar(50) NOT NULL,
  `priceOne` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `priceTwo` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `priceThree` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `tourneyEvent` tinyint(3) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_tourney`
--

INSERT INTO `uni1_tourney` (`tourneyId`, `tourneyName`, `priceOne`, `priceTwo`, `priceThree`, `tourneyEvent`) VALUES
(1, 'Alpha', 500, 300, 200, 3),
(2, 'Beta', 500, 300, 200, 2),
(3, 'Gamma', 500, 300, 200, 5),
(4, 'Delta', 500, 300, 200, 9),
(5, 'Epsilon', 500, 300, 200, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_tourney_logs`
--

CREATE TABLE `uni1_tourney_logs` (
  `logId` int(11) UNSIGNED NOT NULL,
  `tourneyUnits` double(50,0) UNSIGNED NOT NULL DEFAULT 0,
  `playerId` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `joinTime` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `tourneyJoin` int(11) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_tourney_participante`
--

CREATE TABLE `uni1_tourney_participante` (
  `joinId` int(11) UNSIGNED NOT NULL,
  `tourneyUnits` double(50,0) UNSIGNED NOT NULL DEFAULT 0,
  `playerId` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `joinTime` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `tourneyJoin` int(11) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users`
--

CREATE TABLE `uni1_users` (
  `id` int(11) UNSIGNED NOT NULL,
  `username` varchar(32) NOT NULL DEFAULT '',
  `password` varchar(60) NOT NULL DEFAULT '',
  `email` varchar(64) NOT NULL DEFAULT '',
  `email_2` varchar(64) NOT NULL DEFAULT '',
  `lang` varchar(2) NOT NULL DEFAULT 'de',
  `authattack` tinyint(1) NOT NULL DEFAULT 0,
  `authlevel` tinyint(1) NOT NULL DEFAULT 0,
  `rights` text DEFAULT NULL,
  `id_planet` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `universe` tinyint(3) UNSIGNED NOT NULL,
  `galaxy` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `system` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `planet` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `darkmatter` double(255,0) NOT NULL DEFAULT 0,
  `user_lastip` varchar(40) NOT NULL DEFAULT '',
  `ip_at_reg` varchar(40) NOT NULL DEFAULT '',
  `register_time` int(11) NOT NULL DEFAULT 0,
  `onlinetime` int(11) NOT NULL DEFAULT 0,
  `dpath` varchar(20) NOT NULL DEFAULT 'gow',
  `timezone` varchar(32) NOT NULL DEFAULT 'Europe/London',
  `planet_sort` tinyint(1) NOT NULL DEFAULT 0,
  `planet_sort_order` tinyint(1) NOT NULL DEFAULT 0,
  `spio_anz` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `settings_fleetactions` tinyint(2) UNSIGNED NOT NULL DEFAULT 3,
  `settings_esp` tinyint(1) NOT NULL DEFAULT 1,
  `settings_wri` tinyint(1) NOT NULL DEFAULT 1,
  `settings_bud` tinyint(1) NOT NULL DEFAULT 1,
  `settings_mis` tinyint(1) NOT NULL DEFAULT 1,
  `settings_blockPM` tinyint(1) NOT NULL DEFAULT 0,
  `urlaubs_modus` tinyint(1) NOT NULL DEFAULT 0,
  `urlaubs_until` int(11) NOT NULL DEFAULT 0,
  `db_deaktjava` int(11) NOT NULL DEFAULT 0,
  `b_tech_planet` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `b_tech` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `b_tech_id` smallint(2) UNSIGNED NOT NULL DEFAULT 0,
  `b_tech_queue` text DEFAULT NULL,
  `spy_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `computer_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `military_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `defence_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `shield_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `energy_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `hyperspace_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `combustion_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `impulse_motor_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `hyperspace_motor_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `laser_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ionic_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `buster_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `intergalactic_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `expedition_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `metal_proc_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `crystal_proc_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `deuterium_proc_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `graviton_tech` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ally_id` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `ally_register_time` int(11) NOT NULL DEFAULT 0,
  `ally_rank_id` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rpg_geologue` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `rpg_amiral` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_ingenieur` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_technocrate` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_espion` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_constructeur` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_scientifique` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_commandant` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_stockeur` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_defenseur` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_destructeur` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_general` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_bunker` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_raideur` tinyint(2) NOT NULL DEFAULT 0,
  `rpg_empereur` tinyint(22) NOT NULL DEFAULT 0,
  `bana` tinyint(1) NOT NULL DEFAULT 0,
  `banaday` int(11) NOT NULL DEFAULT 0,
  `hof` tinyint(1) NOT NULL DEFAULT 1,
  `spyMessagesMode` tinyint(1) NOT NULL DEFAULT 0,
  `wons` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `loos` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `draws` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `kbmetal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `kbcrystal` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `lostunits` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `desunits` double(255,0) UNSIGNED NOT NULL DEFAULT 0,
  `uctime` int(11) NOT NULL DEFAULT 0,
  `setmail` int(11) NOT NULL DEFAULT 0,
  `dm_attack` int(11) NOT NULL DEFAULT 0,
  `dm_defensive` int(11) NOT NULL DEFAULT 0,
  `dm_buildtime` int(11) NOT NULL DEFAULT 0,
  `dm_researchtime` int(11) NOT NULL DEFAULT 0,
  `dm_resource` int(11) NOT NULL DEFAULT 0,
  `dm_energie` int(11) NOT NULL DEFAULT 0,
  `dm_fleettime` int(11) NOT NULL DEFAULT 0,
  `ref_id` int(11) NOT NULL DEFAULT 0,
  `ref_bonus` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `inactive_mail` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `ntx20` int(11) NOT NULL DEFAULT 0,
  `containers` int(11) NOT NULL DEFAULT 0,
  `containers_opened` int(11) NOT NULL DEFAULT 0,
  `improvements_compras_hoy` tinyint(2) NOT NULL DEFAULT 0,
  `improvements_ultima_compra` int(11) NOT NULL DEFAULT 0,
  `race_id` int(11) NOT NULL DEFAULT 0,
  `faction_id` int(11) NOT NULL DEFAULT 0,
  `race_chosen_at` int(11) NOT NULL DEFAULT 0,
  `is_pve` tinyint(1) NOT NULL DEFAULT 0,
  `pve_event_id` int(11) NOT NULL DEFAULT 0,
  `pve_event_type` enum('none','crisis','empire','boss','bastion') NOT NULL DEFAULT 'none',
  `pvp_points` int(11) NOT NULL DEFAULT 0,
  `ntx20_inversion` bigint(20) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_achievements`
--

CREATE TABLE `uni1_users_achievements` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `current_level` tinyint(2) NOT NULL DEFAULT 1,
  `status` enum('pending','completed','claimed') NOT NULL DEFAULT 'pending',
  `completed_at` int(11) NOT NULL DEFAULT 0,
  `claimed_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_auth`
--

CREATE TABLE `uni1_users_auth` (
  `id` int(11) NOT NULL,
  `account` varchar(255) NOT NULL,
  `mode` varchar(20) NOT NULL DEFAULT 'google',
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_boosters`
--

CREATE TABLE `uni1_users_boosters` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `booster_id` int(11) NOT NULL,
  `expires_at` int(11) NOT NULL,
  `applied_at` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_coord_favorites`
--

CREATE TABLE `uni1_users_coord_favorites` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL DEFAULT '',
  `galaxy` tinyint(3) NOT NULL,
  `system` smallint(5) NOT NULL,
  `planet` tinyint(3) NOT NULL,
  `type` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_events`
--

CREATE TABLE `uni1_users_events` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL DEFAULT 0,
  `claimed` tinyint(1) NOT NULL DEFAULT 0,
  `claimed_at` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_fleet_presets`
--

CREATE TABLE `uni1_users_fleet_presets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL DEFAULT '',
  `ships_json` text NOT NULL,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_improvements_eq`
--

CREATE TABLE `uni1_users_improvements_eq` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `slot` tinyint(1) NOT NULL,
  `item_id` int(11) NOT NULL,
  `level` tinyint(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_improvements_inv`
--

CREATE TABLE `uni1_users_improvements_inv` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` tinyint(2) NOT NULL DEFAULT 1,
  `is_penalized` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_obtencion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_market`
--

CREATE TABLE `uni1_users_market` (
  `user_id` int(11) NOT NULL,
  `balance_frozen` bigint(20) NOT NULL DEFAULT 0,
  `offers_today` int(3) NOT NULL DEFAULT 0,
  `last_offer_day` date DEFAULT NULL,
  `total_bought` int(11) NOT NULL DEFAULT 0,
  `total_sold` int(11) NOT NULL DEFAULT 0,
  `box_common` int(11) NOT NULL DEFAULT 0,
  `box_rare` int(11) NOT NULL DEFAULT 0,
  `box_legendary` int(11) NOT NULL DEFAULT 0,
  `last_reset` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_tasks`
--

CREATE TABLE `uni1_users_tasks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `progress` int(11) NOT NULL DEFAULT 0,
  `status` enum('pending','completed','claimed') NOT NULL DEFAULT 'pending',
  `completed_at` int(11) NOT NULL DEFAULT 0,
  `claimed_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_to_acs`
--

CREATE TABLE `uni1_users_to_acs` (
  `userID` int(10) UNSIGNED NOT NULL,
  `acsID` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_users_to_acs`
--

INSERT INTO `uni1_users_to_acs` (`userID`, `acsID`) VALUES
(8, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_to_extauth`
--

CREATE TABLE `uni1_users_to_extauth` (
  `id` int(11) NOT NULL,
  `account` varchar(64) NOT NULL,
  `mode` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_to_topkb`
--

CREATE TABLE `uni1_users_to_topkb` (
  `rid` varchar(32) NOT NULL,
  `uid` int(11) NOT NULL,
  `username` varchar(128) NOT NULL,
  `role` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_valid`
--

CREATE TABLE `uni1_users_valid` (
  `validationID` int(11) UNSIGNED NOT NULL,
  `userName` varchar(64) NOT NULL,
  `validationKey` varchar(32) NOT NULL,
  `password` varchar(60) NOT NULL,
  `email` varchar(64) NOT NULL,
  `date` int(11) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `language` varchar(3) NOT NULL,
  `universe` tinyint(3) UNSIGNED NOT NULL,
  `referralID` int(11) DEFAULT NULL,
  `externalAuthUID` varchar(128) DEFAULT NULL,
  `externalAuthMethod` varchar(32) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_vip`
--

CREATE TABLE `uni1_users_vip` (
  `vip_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vip_type` enum('weekly','biweekly','monthly') NOT NULL,
  `vip_start` int(11) NOT NULL,
  `vip_end` int(11) NOT NULL,
  `vip_source` enum('ntx20','admin','gift') NOT NULL DEFAULT 'ntx20',
  `vip_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_daily_reward` int(11) NOT NULL DEFAULT 0,
  `last_reward_json` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_users_wallet`
--

CREATE TABLE `uni1_users_wallet` (
  `user_id` int(11) NOT NULL,
  `cristales_kyber` bigint(20) NOT NULL DEFAULT 0,
  `total_invertido` bigint(20) NOT NULL DEFAULT 0,
  `total_retirado` bigint(20) NOT NULL DEFAULT 0,
  `fecha_registro` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_vars`
--

CREATE TABLE `uni1_vars` (
  `elementID` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(32) NOT NULL,
  `class` int(11) NOT NULL,
  `onPlanetType` set('1','3') NOT NULL,
  `onePerPlanet` tinyint(4) NOT NULL,
  `factor` float(4,2) NOT NULL,
  `maxLevel` int(11) DEFAULT NULL,
  `cost901` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `cost902` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `cost903` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `cost911` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `cost921` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `consumption1` int(11) UNSIGNED DEFAULT NULL,
  `consumption2` int(11) UNSIGNED DEFAULT NULL,
  `speedTech` int(11) UNSIGNED DEFAULT NULL,
  `speed1` int(11) UNSIGNED DEFAULT NULL,
  `speed2` int(11) UNSIGNED DEFAULT NULL,
  `speed2Tech` int(10) UNSIGNED DEFAULT NULL,
  `speed2onLevel` int(10) UNSIGNED DEFAULT NULL,
  `speed3Tech` int(10) UNSIGNED DEFAULT NULL,
  `speed3onLevel` int(10) UNSIGNED DEFAULT NULL,
  `capacity` int(11) UNSIGNED DEFAULT NULL,
  `attack` int(10) UNSIGNED DEFAULT NULL,
  `defend` int(10) UNSIGNED DEFAULT NULL,
  `timeBonus` int(11) UNSIGNED DEFAULT NULL,
  `bonusAttack` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusDefensive` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusShield` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusBuildTime` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusResearchTime` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusShipTime` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusDefensiveTime` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusResource` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusEnergy` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusResourceStorage` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusShipStorage` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusFlyTime` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusFleetSlots` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusPlanets` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusSpyPower` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusExpedition` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusGateCoolTime` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusMoreFound` float(4,2) NOT NULL DEFAULT 0.00,
  `bonusAttackUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusDefensiveUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusShieldUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusBuildTimeUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusResearchTimeUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusShipTimeUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusDefensiveTimeUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusResourceUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusEnergyUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusResourceStorageUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusShipStorageUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusFlyTimeUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusFleetSlotsUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusPlanetsUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusSpyPowerUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusExpeditionUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusGateCoolTimeUnit` smallint(1) NOT NULL DEFAULT 0,
  `bonusMoreFoundUnit` smallint(1) NOT NULL DEFAULT 0,
  `speedFleetFactor` float(4,2) DEFAULT NULL,
  `production901` varchar(255) DEFAULT NULL,
  `production902` varchar(255) DEFAULT NULL,
  `production903` varchar(255) DEFAULT NULL,
  `production911` varchar(255) DEFAULT NULL,
  `production921` varchar(255) DEFAULT NULL,
  `storage901` varchar(255) DEFAULT NULL,
  `storage902` varchar(255) DEFAULT NULL,
  `storage903` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_vars`
--

INSERT INTO `uni1_vars` (`elementID`, `name`, `class`, `onPlanetType`, `onePerPlanet`, `factor`, `maxLevel`, `cost901`, `cost902`, `cost903`, `cost911`, `cost921`, `consumption1`, `consumption2`, `speedTech`, `speed1`, `speed2`, `speed2Tech`, `speed2onLevel`, `speed3Tech`, `speed3onLevel`, `capacity`, `attack`, `defend`, `timeBonus`, `bonusAttack`, `bonusDefensive`, `bonusShield`, `bonusBuildTime`, `bonusResearchTime`, `bonusShipTime`, `bonusDefensiveTime`, `bonusResource`, `bonusEnergy`, `bonusResourceStorage`, `bonusShipStorage`, `bonusFlyTime`, `bonusFleetSlots`, `bonusPlanets`, `bonusSpyPower`, `bonusExpedition`, `bonusGateCoolTime`, `bonusMoreFound`, `bonusAttackUnit`, `bonusDefensiveUnit`, `bonusShieldUnit`, `bonusBuildTimeUnit`, `bonusResearchTimeUnit`, `bonusShipTimeUnit`, `bonusDefensiveTimeUnit`, `bonusResourceUnit`, `bonusEnergyUnit`, `bonusResourceStorageUnit`, `bonusShipStorageUnit`, `bonusFlyTimeUnit`, `bonusFleetSlotsUnit`, `bonusPlanetsUnit`, `bonusSpyPowerUnit`, `bonusExpeditionUnit`, `bonusGateCoolTimeUnit`, `bonusMoreFoundUnit`, `speedFleetFactor`, `production901`, `production902`, `production903`, `production911`, `production921`, `storage901`, `storage902`, `storage903`) VALUES
(1, 'metal_mine', 0, '1', 0, 1.50, 255, 60, 15, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, '(30 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, NULL, '-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, NULL, NULL, NULL),
(2, 'crystal_mine', 0, '1', 0, 1.50, 255, 48, 24, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, '(20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, '-(10 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor);', NULL, NULL, NULL, NULL),
(3, 'deuterium_sintetizer', 0, '1', 0, 1.50, 255, 225, 75, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, '(10 * $BuildLevel * pow((1.1), $BuildLevel) * (-0.002 * $BuildTemp + 1.28) * (0.1 * $BuildLevelFactor))', '- (30 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, NULL, NULL, NULL),
(4, 'solar_plant', 0, '1', 0, 1.50, 255, 75, 30, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, '(20 * $BuildLevel * pow((1.1), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, NULL, NULL, NULL),
(6, 'university', 0, '1', 0, 2.00, 255, 100000000, 50000000, 25000000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(12, 'fusion_plant', 0, '1', 0, 2.00, 255, 900, 360, 180, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, '- (10 * $BuildLevel * pow(1.1,$BuildLevel) * (0.1 * $BuildLevelFactor))', '(30 * $BuildLevel * pow((1.05 + $BuildEnergy * 0.01), $BuildLevel)) * (0.1 * $BuildLevelFactor)', NULL, NULL, NULL, NULL),
(14, 'robot_factory', 0, '1,3', 0, 2.00, 255, 400, 120, 200, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(15, 'nano_factory', 0, '1', 0, 2.00, 255, 1000000, 500000, 100000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(21, 'hangar', 0, '1,3', 0, 2.00, 255, 400, 200, 100, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(22, 'metal_store', 0, '1,3', 0, 2.00, 255, 2000, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'floor(2.5 * pow(1.8331954764, $BuildLevel)) * 5000', NULL, NULL),
(23, 'crystal_store', 0, '1,3', 0, 2.00, 255, 2000, 1000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'floor(2.5 * pow(1.8331954764, $BuildLevel)) * 5000', NULL),
(24, 'deuterium_store', 0, '1,3', 0, 2.00, 255, 2000, 2000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'floor(2.5 * pow(1.8331954764, $BuildLevel)) * 5000'),
(31, 'laboratory', 0, '1', 0, 2.00, 255, 200, 400, 200, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(33, 'terraformer', 0, '1', 0, 2.00, 255, 0, 50000, 100000, 1000, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(34, 'ally_deposit', 0, '1', 0, 2.00, 255, 20000, 40000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(41, 'mondbasis', 0, '3', 0, 2.00, 255, 20000, 40000, 20000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(42, 'phalanx', 0, '3', 0, 2.00, 255, 20000, 40000, 20000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(43, 'sprungtor', 0, '3', 0, 2.00, 255, 2000000, 4000000, 2000000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(44, 'silo', 0, '1', 0, 2.00, 255, 20000, 20000, 1000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(106, 'spy_tech', 100, '1,3', 0, 2.00, 255, 200, 1000, 200, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(108, 'computer_tech', 100, '1,3', 0, 2.00, 255, 0, 400, 600, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(109, 'military_tech', 100, '1,3', 0, 2.00, 255, 800, 200, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(110, 'defence_tech', 100, '1,3', 0, 2.00, 255, 200, 600, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(111, 'shield_tech', 100, '1,3', 0, 2.00, 255, 1000, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(113, 'energy_tech', 100, '1,3', 0, 2.00, 255, 0, 800, 400, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(114, 'hyperspace_tech', 100, '1,3', 0, 2.00, 255, 0, 4000, 2000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(115, 'combustion_tech', 100, '1,3', 0, 2.00, 255, 400, 0, 600, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(117, 'impulse_motor_tech', 100, '1,3', 0, 2.00, 255, 2000, 4000, 600, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(118, 'hyperspace_motor_tech', 100, '1,3', 0, 2.00, 255, 10000, 20000, 6000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(120, 'laser_tech', 100, '1,3', 0, 2.00, 255, 200, 100, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(121, 'ionic_tech', 100, '1,3', 0, 2.00, 255, 1000, 300, 100, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(122, 'buster_tech', 100, '1,3', 0, 2.00, 255, 2000, 4000, 1000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(123, 'intergalactic_tech', 100, '1,3', 0, 2.00, 255, 240000, 400000, 160000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(124, 'expedition_tech', 100, '1,3', 0, 1.75, 255, 4000, 8000, 4000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(131, 'metal_proc_tech', 100, '1,3', 0, 2.00, 255, 750, 500, 250, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(132, 'crystal_proc_tech', 100, '1,3', 0, 2.00, 255, 1000, 750, 500, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(133, 'deuterium_proc_tech', 100, '1,3', 0, 2.00, 255, 1250, 1000, 750, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(199, 'graviton_tech', 100, '1,3', 0, 3.00, 255, 0, 0, 0, 300000, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(202, 'small_ship_cargo', 200, '1,3', 0, 1.00, NULL, 2000, 2000, 0, 0, 0, 10, 20, 4, 5000, 10000, NULL, NULL, NULL, NULL, 5000, 5, 10, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(203, 'big_ship_cargo', 200, '1,3', 0, 1.00, NULL, 6000, 6000, 0, 0, 0, 50, 50, 1, 7500, 7500, NULL, NULL, NULL, NULL, 25000, 5, 25, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(204, 'light_hunter', 200, '1,3', 0, 1.00, NULL, 3000, 1000, 0, 0, 0, 20, 20, 1, 12500, 12500, NULL, NULL, NULL, NULL, 50, 50, 10, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(205, 'heavy_hunter', 200, '1,3', 0, 1.00, NULL, 6000, 4000, 0, 0, 0, 75, 75, 2, 10000, 15000, NULL, NULL, NULL, NULL, 100, 150, 25, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(206, 'crusher', 200, '1,3', 0, 1.00, NULL, 20000, 7000, 2000, 0, 0, 300, 300, 2, 15000, 15000, NULL, NULL, NULL, NULL, 800, 400, 50, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(207, 'battle_ship', 200, '1,3', 0, 1.00, NULL, 45000, 15000, 0, 0, 0, 250, 250, 3, 10000, 10000, NULL, NULL, NULL, NULL, 1500, 1000, 200, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(208, 'colonizer', 200, '1,3', 0, 1.00, NULL, 10000, 20000, 10000, 0, 0, 1000, 1000, 2, 2500, 2500, NULL, NULL, NULL, NULL, 7500, 50, 100, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(209, 'recycler', 200, '1,3', 0, 1.00, NULL, 10000, 6000, 2000, 0, 0, 300, 300, 1, 2000, 2000, NULL, NULL, NULL, NULL, 20000, 1, 10, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(210, 'spy_sonde', 200, '1,3', 0, 1.00, NULL, 0, 1000, 0, 0, 0, 1, 1, 1, 100000000, 100000000, NULL, NULL, NULL, NULL, 5, 0, 0, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(211, 'bomber_ship', 200, '1,3', 0, 1.00, NULL, 50000, 25000, 15000, 0, 0, 1000, 1000, 5, 4000, 5000, NULL, NULL, NULL, NULL, 500, 1000, 500, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(212, 'solar_satelit', 200, '1,3', 0, 1.00, NULL, 0, 2000, 500, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, '((($BuildTemp + 160) / 6) * (0.1 * $BuildLevelFactor) * $BuildLevel)', NULL, NULL, NULL, NULL),
(213, 'destructor', 200, '1,3', 0, 1.00, NULL, 60000, 50000, 15000, 0, 0, 1000, 1000, 3, 5000, 5000, NULL, NULL, NULL, NULL, 2000, 2000, 500, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(214, 'dearth_star', 200, '1,3', 0, 1.00, NULL, 5000000, 4000000, 1000000, 0, 0, 1, 1, 3, 200, 200, NULL, NULL, NULL, NULL, 1000000, 200000, 50000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(215, 'battleship', 200, '1,3', 0, 1.00, NULL, 30000, 40000, 15000, 0, 0, 250, 250, 3, 10000, 10000, NULL, NULL, NULL, NULL, 750, 700, 400, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(216, 'lune_noir', 200, '1,3', 0, 1.00, NULL, 8000000, 2000000, 1500000, 0, 0, 250, 250, 3, 900, 900, NULL, NULL, NULL, NULL, 15000000, 150000, 70000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(217, 'ev_transporter', 200, '1,3', 0, 1.00, NULL, 35000, 20000, 1500, 0, 0, 90, 90, 3, 6000, 6000, NULL, NULL, NULL, NULL, 400000000, 50, 120, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(218, 'star_crasher', 200, '1,3', 0, 1.00, NULL, 275000000, 130000000, 60000000, 0, 0, 10000, 10000, 3, 10, 10, NULL, NULL, NULL, NULL, 50000000, 35000000, 2000000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(219, 'giga_recykler', 200, '1,3', 0, 1.00, NULL, 1000000, 600000, 200000, 0, 0, 300, 300, 3, 7500, 7500, NULL, NULL, NULL, NULL, 200000000, 1, 1000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(220, 'dm_ship', 200, '1,3', 0, 1.00, NULL, 6000000, 7000000, 3000000, 0, 0, 100000, 100000, 3, 100, 100, NULL, NULL, NULL, NULL, 6000000, 5, 50000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(401, 'misil_launcher', 400, '1,3', 0, 1.00, NULL, 2000, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 80, 20, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(402, 'small_laser', 400, '1,3', 0, 1.00, NULL, 1500, 500, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 100, 25, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(403, 'big_laser', 400, '1,3', 0, 1.00, NULL, 6000, 2000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 250, 100, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(404, 'gauss_canyon', 400, '1,3', 0, 1.00, NULL, 20000, 15000, 2000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1100, 200, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(405, 'ionic_canyon', 400, '1,3', 0, 1.00, NULL, 2000, 6000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 150, 500, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(406, 'buster_canyon', 400, '1,3', 0, 1.00, NULL, 50000, 50000, 30000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 3000, 300, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(407, 'small_protection_shield', 400, '1,3', 1, 1.00, NULL, 10000, 10000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, 2000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(408, 'big_protection_shield', 400, '1,3', 1, 1.00, NULL, 50000, 50000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, 10000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(409, 'planet_protector', 400, '1,3', 1, 1.00, NULL, 10000000, 5000000, 2500000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, 1000000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(410, 'graviton_canyon', 400, '1,3', 0, 1.00, NULL, 15000000, 15000000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 500000, 80000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(411, 'orbital_station', 400, '1,3', 1, 1.00, NULL, 5000000000, 2000000000, 500000000, 1000000, 10000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 400000000, 2000000000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(502, 'interceptor_misil', 500, '1,3', 0, 1.00, NULL, 8000, 0, 2000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, 1, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(503, 'interplanetary_misil', 500, '1,3', 0, 1.00, NULL, 12500, 2500, 10000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 12000, 1, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(601, 'rpg_geologue', 600, '1,3', 0, 1.00, 20, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(602, 'rpg_amiral', 600, '1,3', 0, 1.00, 20, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.05, 0.05, 0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(603, 'rpg_ingenieur', 600, '1,3', 0, 1.00, 10, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.05, 0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(604, 'rpg_technocrate', 600, '1,3', 0, 1.00, 10, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(605, 'rpg_constructeur', 600, '1,3', 0, 1.00, 3, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(606, 'rpg_scientifique', 600, '1,3', 0, 1.00, 3, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(607, 'rpg_stockeur', 600, '1,3', 0, 1.00, 2, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.50, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(608, 'rpg_defenseur', 600, '1,3', 0, 1.00, 2, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, -0.25, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(609, 'rpg_bunker', 600, '1,3', 0, 1.00, 1, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(610, 'rpg_espion', 600, '1,3', 0, 1.00, 2, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.35, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(611, 'rpg_commandant', 600, '1,3', 0, 1.00, 3, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(612, 'rpg_destructeur', 600, '1,3', 0, 1.00, 1, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(613, 'rpg_general', 600, '1,3', 0, 1.00, 3, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(614, 'rpg_raideur', 600, '1,3', 0, 1.00, 1, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(615, 'rpg_empereur', 600, '1,3', 0, 1.00, 1, 0, 0, 0, 0, 1000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(701, 'dm_attack', 700, '1,3', 0, 1.00, NULL, 0, 0, 0, 0, 12, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86400, 0.10, 0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(702, 'dm_defensive', 700, '1,3', 0, 1.00, NULL, 0, 0, 0, 0, 10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86400, 0.00, 0.00, 0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(703, 'dm_buildtime', 700, '1,3', 0, 1.00, NULL, 0, 0, 0, 0, 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86400, 0.00, 0.00, 0.00, -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(704, 'dm_resource', 700, '1,3', 0, 1.00, NULL, 0, 0, 0, 0, 12, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86400, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(705, 'dm_energie', 700, '1,3', 0, 1.00, NULL, 0, 0, 0, 0, 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86400, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(706, 'dm_researchtime', 700, '1,3', 0, 1.00, NULL, 0, 0, 0, 0, 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86400, 0.00, 0.00, 0.00, 0.00, -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(707, 'dm_fleettime', 700, '1,3', 0, 1.00, NULL, 0, 0, 0, 0, 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86400, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(221, 'star_titan', 200, '1,3', 0, 1.00, NULL, 350000000, 170000000, 80000000, 0, 0, 12000, 12000, 3, 11, 11, NULL, NULL, NULL, NULL, 100000000, 70000000, 4000000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(222, 'war_colossus', 200, '1,3', 0, 1.00, NULL, 100000000, 50000000, 20000000, 0, 0, 2000, 2000, 3, 50, 50, NULL, NULL, NULL, NULL, 20000000, 15000000, 1200000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(223, 'elite_battleship', 200, '1,3', 0, 1.00, NULL, 60000, 40000, 15000, 0, 0, 300, 300, 3, 10000, 10000, NULL, NULL, NULL, NULL, 1000, 1000, 600, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(224, 'heavy_frigate', 200, '1,3', 0, 1.00, NULL, 80000, 60000, 25000, 0, 0, 400, 400, 3, 9000, 9000, NULL, NULL, NULL, NULL, 1200, 1100, 900, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(412, 'rail_turret', 400, '1,3', 0, 1.00, NULL, 15000, 5000, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 700, 250, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(413, 'antimatter_canyon', 400, '1,3', 0, 1.00, NULL, 200000, 150000, 50000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 15000, 1500, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(414, 'star_bastion', 400, '1,3', 0, 1.00, NULL, 60000000, 30000000, 10000000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5000000, 800000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(415, 'deflector_shield', 400, '1,3', 1, 1.00, NULL, 25000000, 20000000, 5000000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 300, 200000, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(504, 'antimatter_misil', 500, '1,3', 0, 1.00, NULL, 40000, 30000, 20000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 40000, 1, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(505, 'advanced_interceptor_misil', 500, '1,3', 0, 1.00, NULL, 20000, 10000, 8000, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 3, 3, NULL, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_vars_rapidfire`
--

CREATE TABLE `uni1_vars_rapidfire` (
  `elementID` int(11) NOT NULL,
  `rapidfireID` int(11) NOT NULL,
  `shoots` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_vars_rapidfire`
--

INSERT INTO `uni1_vars_rapidfire` (`elementID`, `rapidfireID`, `shoots`) VALUES
(202, 210, 5),
(202, 212, 5),
(203, 210, 5),
(203, 212, 5),
(204, 210, 5),
(204, 212, 5),
(205, 202, 3),
(205, 210, 5),
(205, 212, 5),
(206, 204, 6),
(206, 401, 10),
(206, 210, 5),
(206, 212, 5),
(207, 210, 5),
(207, 212, 5),
(208, 210, 5),
(208, 212, 5),
(209, 210, 5),
(209, 212, 5),
(211, 210, 5),
(211, 212, 5),
(211, 401, 20),
(211, 402, 20),
(211, 403, 10),
(211, 405, 10),
(213, 210, 5),
(213, 212, 5),
(213, 215, 2),
(213, 402, 10),
(214, 210, 1250),
(214, 212, 1250),
(214, 202, 250),
(214, 203, 250),
(214, 208, 250),
(214, 209, 250),
(214, 204, 200),
(214, 205, 100),
(214, 206, 33),
(214, 207, 30),
(214, 211, 25),
(214, 215, 15),
(214, 213, 5),
(214, 401, 200),
(214, 402, 200),
(214, 403, 100),
(214, 404, 50),
(214, 405, 100),
(215, 202, 3),
(215, 203, 3),
(215, 205, 4),
(215, 206, 4),
(215, 207, 10),
(215, 210, 5),
(215, 212, 5),
(216, 210, 1250),
(216, 212, 1250),
(216, 202, 250),
(216, 203, 250),
(216, 204, 200),
(216, 205, 100),
(216, 206, 33),
(216, 207, 30),
(216, 208, 250),
(216, 209, 250),
(216, 211, 25),
(216, 213, 5),
(216, 214, 1),
(216, 215, 15),
(216, 401, 400),
(216, 402, 200),
(216, 403, 100),
(216, 404, 50),
(216, 405, 100),
(217, 210, 5),
(217, 212, 5),
(218, 210, 1250),
(218, 212, 1250),
(218, 202, 250),
(218, 203, 250),
(218, 204, 200),
(218, 205, 100),
(218, 206, 33),
(218, 207, 30),
(218, 208, 250),
(218, 209, 250),
(218, 211, 25),
(218, 213, 5),
(218, 215, 15),
(218, 401, 400),
(218, 402, 200),
(218, 403, 100),
(218, 404, 50),
(218, 405, 100),
(219, 210, 5),
(219, 212, 5),
(220, 210, 5),
(220, 212, 5),
(221, 202, 500),
(221, 203, 500),
(221, 204, 400),
(221, 205, 200),
(221, 206, 66),
(221, 207, 60),
(221, 208, 500),
(221, 209, 500),
(221, 210, 2500),
(221, 211, 50),
(221, 212, 2500),
(221, 213, 10),
(221, 214, 2),
(221, 215, 30),
(221, 216, 2),
(221, 217, 250),
(221, 218, 2),
(221, 219, 250),
(221, 220, 1250),
(221, 401, 800),
(221, 402, 400),
(221, 403, 200),
(221, 404, 100),
(221, 405, 200),
(221, 409, 200),
(221, 410, 50),
(221, 411, 2),
(222, 202, 250),
(222, 203, 250),
(222, 204, 200),
(222, 205, 100),
(222, 206, 33),
(222, 207, 30),
(222, 208, 250),
(222, 209, 250),
(222, 210, 1250),
(222, 211, 25),
(222, 212, 1250),
(222, 213, 5),
(222, 214, 1),
(222, 215, 15),
(222, 401, 400),
(222, 402, 200),
(222, 403, 100),
(222, 404, 50),
(222, 405, 100),
(223, 202, 4),
(223, 203, 4),
(223, 205, 5),
(223, 206, 5),
(223, 207, 12),
(223, 210, 6),
(223, 212, 6),
(224, 202, 4),
(224, 203, 4),
(224, 205, 5),
(224, 206, 5),
(224, 207, 10),
(224, 210, 6),
(224, 212, 6),
(412, 202, 8),
(412, 203, 8),
(412, 204, 8),
(412, 205, 8),
(413, 207, 5),
(413, 215, 5),
(413, 223, 5),
(413, 224, 5),
(414, 214, 2),
(414, 216, 2),
(414, 218, 2),
(414, 221, 2),
(414, 222, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_vars_requriements`
--

CREATE TABLE `uni1_vars_requriements` (
  `elementID` int(11) NOT NULL,
  `requireID` int(11) NOT NULL,
  `requireLevel` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_vars_requriements`
--

INSERT INTO `uni1_vars_requriements` (`elementID`, `requireID`, `requireLevel`) VALUES
(6, 14, 20),
(6, 31, 22),
(6, 15, 4),
(6, 108, 12),
(6, 123, 3),
(12, 3, 5),
(12, 113, 3),
(15, 14, 10),
(15, 108, 10),
(21, 14, 2),
(33, 15, 1),
(33, 113, 12),
(42, 41, 1),
(43, 41, 1),
(43, 114, 7),
(44, 21, 1),
(106, 31, 3),
(108, 31, 1),
(109, 31, 4),
(110, 113, 3),
(110, 31, 6),
(111, 31, 2),
(113, 31, 1),
(114, 113, 5),
(114, 110, 5),
(114, 31, 7),
(115, 113, 1),
(115, 31, 1),
(117, 113, 1),
(117, 31, 2),
(118, 114, 3),
(118, 31, 7),
(120, 31, 1),
(120, 113, 2),
(121, 31, 4),
(121, 120, 5),
(121, 113, 4),
(122, 31, 5),
(122, 113, 8),
(122, 120, 10),
(122, 121, 5),
(123, 31, 10),
(123, 108, 8),
(123, 114, 8),
(124, 106, 3),
(124, 117, 3),
(124, 31, 3),
(131, 31, 8),
(131, 113, 5),
(132, 31, 8),
(132, 113, 5),
(133, 31, 8),
(133, 113, 5),
(199, 31, 12),
(202, 21, 2),
(202, 115, 2),
(203, 21, 4),
(203, 115, 6),
(204, 21, 1),
(204, 115, 1),
(205, 21, 3),
(205, 111, 2),
(205, 117, 2),
(206, 21, 5),
(206, 117, 4),
(206, 121, 2),
(207, 21, 7),
(207, 118, 4),
(208, 21, 4),
(208, 117, 3),
(209, 21, 4),
(209, 115, 6),
(209, 110, 2),
(210, 21, 3),
(210, 115, 3),
(210, 106, 2),
(211, 117, 6),
(211, 21, 8),
(211, 122, 5),
(212, 21, 1),
(213, 21, 9),
(213, 118, 6),
(213, 114, 5),
(214, 21, 12),
(214, 118, 7),
(214, 114, 6),
(214, 199, 1),
(215, 114, 5),
(215, 120, 12),
(215, 118, 5),
(215, 21, 8),
(216, 106, 12),
(216, 21, 15),
(216, 109, 14),
(216, 110, 14),
(216, 111, 15),
(216, 114, 10),
(216, 120, 20),
(216, 199, 3),
(217, 111, 10),
(217, 21, 14),
(217, 114, 10),
(217, 110, 14),
(217, 117, 15),
(218, 21, 18),
(218, 109, 20),
(218, 110, 20),
(218, 111, 20),
(218, 114, 15),
(218, 118, 20),
(218, 120, 25),
(218, 199, 8),
(219, 21, 15),
(219, 109, 15),
(219, 110, 15),
(219, 111, 15),
(219, 118, 8),
(220, 21, 9),
(220, 114, 5),
(220, 118, 6),
(401, 21, 1),
(402, 113, 1),
(402, 21, 2),
(402, 120, 3),
(403, 113, 3),
(403, 21, 4),
(403, 120, 6),
(404, 21, 6),
(404, 113, 6),
(404, 109, 3),
(404, 110, 1),
(405, 21, 4),
(405, 121, 4),
(406, 21, 8),
(406, 122, 7),
(407, 110, 2),
(407, 21, 1),
(408, 110, 6),
(408, 21, 6),
(409, 609, 1),
(410, 199, 7),
(410, 21, 18),
(410, 109, 20),
(411, 199, 10),
(411, 110, 22),
(411, 122, 20),
(411, 108, 15),
(411, 111, 25),
(411, 113, 20),
(411, 608, 2),
(411, 21, 20),
(502, 44, 2),
(502, 21, 1),
(503, 44, 4),
(503, 21, 1),
(503, 117, 1),
(603, 601, 5),
(604, 602, 5),
(605, 601, 10),
(605, 603, 2),
(606, 601, 10),
(606, 603, 2),
(607, 605, 1),
(608, 606, 1),
(609, 601, 20),
(609, 603, 10),
(609, 605, 3),
(609, 606, 3),
(609, 607, 2),
(609, 608, 2),
(610, 602, 10),
(610, 604, 5),
(611, 602, 10),
(611, 604, 5),
(612, 610, 1),
(613, 611, 1),
(614, 602, 20),
(614, 604, 10),
(614, 610, 2),
(614, 611, 2),
(614, 612, 1),
(614, 613, 3),
(615, 614, 1),
(615, 609, 1),
(221, 21, 23),
(221, 109, 25),
(221, 110, 25),
(221, 111, 25),
(221, 114, 20),
(221, 118, 25),
(221, 120, 30),
(221, 121, 18),
(221, 199, 13),
(222, 21, 15),
(222, 109, 17),
(222, 110, 17),
(222, 111, 17),
(222, 114, 12),
(222, 118, 12),
(222, 120, 22),
(222, 199, 5),
(223, 21, 10),
(223, 111, 8),
(223, 114, 6),
(223, 118, 7),
(223, 120, 15),
(223, 199, 2),
(224, 21, 12),
(224, 109, 5),
(224, 110, 5),
(224, 111, 10),
(224, 114, 8),
(224, 118, 9),
(224, 120, 18),
(224, 199, 3),
(412, 21, 6),
(412, 109, 5),
(412, 120, 8),
(413, 21, 10),
(413, 109, 10),
(413, 110, 8),
(413, 122, 8),
(414, 21, 18),
(414, 109, 18),
(414, 110, 18),
(414, 111, 18),
(414, 199, 6),
(415, 21, 15),
(415, 110, 15),
(415, 111, 15),
(415, 114, 10),
(504, 44, 8),
(504, 21, 6),
(504, 117, 5),
(504, 118, 3),
(504, 109, 12),
(504, 111, 10),
(505, 44, 6),
(505, 21, 5),
(505, 111, 12),
(505, 109, 10),
(505, 121, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_fund`
--

CREATE TABLE `uni1_wallet_fund` (
  `id` int(11) NOT NULL DEFAULT 1,
  `fondo_visible` bigint(20) NOT NULL DEFAULT 0,
  `fondo_proyecto` bigint(20) NOT NULL DEFAULT 0,
  `fondo_reservado_temp2` bigint(20) NOT NULL DEFAULT 0,
  `total_invertido` bigint(20) NOT NULL DEFAULT 0,
  `total_retirado` bigint(20) NOT NULL DEFAULT 0,
  `tasa_war_kyber` decimal(10,4) NOT NULL DEFAULT 0.0000,
  `retiros_habilitados` tinyint(4) NOT NULL DEFAULT 0,
  `retiros_duracion` int(11) NOT NULL DEFAULT 0,
  `fecha_apertura` int(11) DEFAULT NULL,
  `fecha_cierre` int(11) DEFAULT NULL,
  `ultima_actualizacion` int(11) NOT NULL DEFAULT 0,
  `min_retiro_nxt20` int(11) NOT NULL DEFAULT 300,
  `ntx20_inversion_total` bigint(20) NOT NULL DEFAULT 0,
  `tasa_nxt20_actual` decimal(15,6) NOT NULL DEFAULT 0.000000
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_wallet_fund`
--

INSERT INTO `uni1_wallet_fund` (`id`, `fondo_visible`, `fondo_proyecto`, `fondo_reservado_temp2`, `total_invertido`, `total_retirado`, `tasa_war_kyber`, `retiros_habilitados`, `retiros_duracion`, `fecha_apertura`, `fecha_cierre`, `ultima_actualizacion`, `min_retiro_nxt20`, `ntx20_inversion_total`, `tasa_nxt20_actual`) VALUES
(1, 3535, 1509, 3535, 5044, 0, 0.0000, 0, 0, NULL, NULL, 1792252223, 300, 0, 6.972387);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_investments`
--

CREATE TABLE `uni1_wallet_investments` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `cantidad_kyber` bigint(20) NOT NULL,
  `nxt20_entregado` bigint(20) NOT NULL,
  `referidor_id` int(11) DEFAULT NULL,
  `fondo_visible_add` bigint(20) NOT NULL,
  `fondo_proyecto_add` bigint(20) NOT NULL,
  `referidor_add` bigint(20) NOT NULL DEFAULT 0,
  `estado` enum('pendiente_sin_asignar','pendiente_asignada','datos_enviados','pendiente_verificacion','completada','rechazada','cancelada','expirada') NOT NULL DEFAULT 'pendiente_sin_asignar',
  `metodo_pago` varchar(50) DEFAULT 'CUP',
  `referencia` varchar(100) DEFAULT NULL,
  `fecha` int(11) NOT NULL,
  `fecha_procesado` int(11) DEFAULT NULL,
  `fecha_asignada` int(11) DEFAULT NULL,
  `fecha_datos_enviados` int(11) DEFAULT NULL,
  `fecha_comprobante` int(11) DEFAULT NULL,
  `motivo` text DEFAULT NULL,
  `eliminada` tinyint(1) NOT NULL DEFAULT 0,
  `eliminada_por` int(11) DEFAULT NULL,
  `fecha_eliminacion` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `admin_tarjeta_snapshot` varchar(50) DEFAULT NULL,
  `admin_telefono_snapshot` varchar(30) DEFAULT NULL,
  `nxt20_referidor_add` bigint(20) NOT NULL DEFAULT 0,
  `fecha_creacion` int(11) NOT NULL DEFAULT 0,
  `fecha_resolucion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_investment_log`
--

CREATE TABLE `uni1_wallet_investment_log` (
  `id` int(11) NOT NULL,
  `investment_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `accion` varchar(50) NOT NULL,
  `detalle` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `fecha` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_referral_fund`
--

CREATE TABLE `uni1_wallet_referral_fund` (
  `id` int(11) NOT NULL,
  `referidor_id` int(11) NOT NULL,
  `referido_id` int(11) NOT NULL,
  `cantidad` bigint(20) NOT NULL,
  `withdrawal_id` int(11) DEFAULT NULL,
  `fecha` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_stats_daily`
--

CREATE TABLE `uni1_wallet_stats_daily` (
  `fecha` date NOT NULL,
  `fondo_visible` bigint(20) NOT NULL DEFAULT 0,
  `total_invertido_dia` bigint(20) NOT NULL DEFAULT 0,
  `total_retirado_dia` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_tasa_historial`
--

CREATE TABLE `uni1_wallet_tasa_historial` (
  `id` int(11) NOT NULL,
  `fecha` int(11) NOT NULL,
  `kyber_banco` bigint(20) DEFAULT 0,
  `nxt20_en_juego` bigint(20) DEFAULT 0,
  `tasa` decimal(18,8) DEFAULT 0.00000000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_transactions`
--

CREATE TABLE `uni1_wallet_transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `tipo` enum('inversion','retiro','referido_inv','referido_ret','ajuste') NOT NULL,
  `moneda` enum('KYBER','WAR','NXT20') NOT NULL,
  `cantidad` bigint(20) NOT NULL,
  `saldo_resultante` bigint(20) NOT NULL DEFAULT 0,
  `detalle` varchar(255) DEFAULT NULL,
  `fecha` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_transfers_log`
--

CREATE TABLE `uni1_wallet_transfers_log` (
  `id` int(11) NOT NULL,
  `investment_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `referidor_id` int(11) DEFAULT NULL,
  `monto_kyber` bigint(20) NOT NULL,
  `nxt20_entregados` bigint(20) NOT NULL,
  `war_points_entregados` bigint(20) NOT NULL,
  `fondo_visible` bigint(20) NOT NULL,
  `fondo_proyecto` bigint(20) NOT NULL,
  `pago_referidor_nxt20` bigint(20) NOT NULL DEFAULT 0,
  `transferencia_id` varchar(100) DEFAULT NULL,
  `admin_tarjeta` varchar(50) DEFAULT NULL,
  `admin_telefono` varchar(30) DEFAULT NULL,
  `fecha_solicitud` int(11) NOT NULL,
  `fecha_confirmacion` int(11) NOT NULL,
  `resultado` enum('confirmada','rechazada','cancelada','expirada') NOT NULL,
  `motivo` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_wallet_withdrawals`
--

CREATE TABLE `uni1_wallet_withdrawals` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `war_points` bigint(20) NOT NULL,
  `bruto_kyber` bigint(20) NOT NULL,
  `neto_usuario` bigint(20) NOT NULL,
  `proyecto_add` bigint(20) NOT NULL,
  `fondo_virtual_add` bigint(20) NOT NULL,
  `tasa_aplicada` decimal(10,4) NOT NULL,
  `referidor_id` int(11) DEFAULT NULL,
  `estado` enum('pendiente','pagado','rechazado') NOT NULL DEFAULT 'pendiente',
  `fecha` int(11) NOT NULL,
  `fecha_procesado` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_war_battles`
--

CREATE TABLE `uni1_war_battles` (
  `id` int(11) NOT NULL,
  `atacante_id` int(11) NOT NULL,
  `atacante_nombre` varchar(80) NOT NULL,
  `defensor_id` int(11) NOT NULL,
  `defensor_nombre` varchar(80) NOT NULL,
  `inicio` int(11) NOT NULL,
  `fin` int(11) NOT NULL,
  `estado` enum('en_curso','finalizada','cancelada') NOT NULL DEFAULT 'en_curso',
  `clima_key` varchar(40) NOT NULL DEFAULT '',
  `clima_nombre` varchar(80) NOT NULL DEFAULT '',
  `resultado_final` varchar(40) NOT NULL DEFAULT '',
  `bajas_atacante_json` text DEFAULT NULL,
  `bajas_defensor_json` text DEFAULT NULL,
  `rondas_json` longtext DEFAULT NULL,
  `created_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_war_chests`
--

CREATE TABLE `uni1_war_chests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `tipo` varchar(3) NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `rarro` tinyint(1) NOT NULL DEFAULT 0,
  `battle_id` int(11) NOT NULL DEFAULT 0,
  `fecha` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_war_history`
--

CREATE TABLE `uni1_war_history` (
  `id` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `inicio` int(11) NOT NULL,
  `fin` int(11) NOT NULL,
  `estado_final` varchar(40) NOT NULL DEFAULT '',
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_war_log`
--

CREATE TABLE `uni1_war_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `battle_id` int(11) NOT NULL DEFAULT 0,
  `accion` varchar(60) NOT NULL,
  `detalle` text DEFAULT NULL,
  `ip` varchar(45) NOT NULL DEFAULT '',
  `fecha` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_war_participants`
--

CREATE TABLE `uni1_war_participants` (
  `id` int(11) NOT NULL,
  `battle_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `alliance_id` int(11) NOT NULL DEFAULT 0,
  `naves_json` longtext DEFAULT NULL,
  `defensas_json` longtext DEFAULT NULL,
  `planetas_json` longtext DEFAULT NULL,
  `fecha_envio` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_war_points`
--

CREATE TABLE `uni1_war_points` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `puntos` int(11) NOT NULL DEFAULT 0,
  `naves_enviadas` longtext DEFAULT NULL,
  `defensas_enviadas` longtext DEFAULT NULL,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_war_seasons`
--

CREATE TABLE `uni1_war_seasons` (
  `id` int(11) NOT NULL,
  `estado` enum('sin_temporada','activa') NOT NULL DEFAULT 'sin_temporada',
  `nombre_temporada` varchar(80) NOT NULL DEFAULT '',
  `duracion_horas` int(11) NOT NULL DEFAULT 7,
  `duracion_batalla_horas` int(11) NOT NULL DEFAULT 7,
  `cooldown_horas` int(11) NOT NULL DEFAULT 7,
  `pausada` tinyint(1) NOT NULL DEFAULT 0,
  `retiros_habilitados` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_inicio` int(11) DEFAULT NULL,
  `fecha_fin` int(11) DEFAULT NULL,
  `updated_at` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_war_seasons`
--

INSERT INTO `uni1_war_seasons` (`id`, `estado`, `nombre_temporada`, `duracion_horas`, `duracion_batalla_horas`, `cooldown_horas`, `pausada`, `retiros_habilitados`, `fecha_inicio`, `fecha_fin`, `updated_at`) VALUES
(1, 'sin_temporada', '', 7, 7, 7, 0, 0, NULL, NULL, 1791504044);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `uni1_weekend_boost`
--

CREATE TABLE `uni1_weekend_boost` (
  `id` int(11) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `start_day` tinyint(1) NOT NULL DEFAULT 5 COMMENT '0=Dom,1=Lun..6=Sab',
  `start_hour` tinyint(2) NOT NULL DEFAULT 0,
  `end_day` tinyint(1) NOT NULL DEFAULT 0,
  `end_hour` tinyint(2) NOT NULL DEFAULT 23,
  `normal_game_speed` decimal(6,2) NOT NULL DEFAULT 1.00,
  `normal_fleet_speed` decimal(6,2) NOT NULL DEFAULT 1.00,
  `normal_production_speed` decimal(6,2) NOT NULL DEFAULT 1.00,
  `normal_storage_speed` decimal(6,2) NOT NULL DEFAULT 1.00,
  `normal_expedition_factor` decimal(6,2) NOT NULL DEFAULT 1.00,
  `normal_energy_factor` decimal(6,2) NOT NULL DEFAULT 1.00,
  `weekend_game_speed` decimal(6,2) NOT NULL DEFAULT 2.00,
  `weekend_fleet_speed` decimal(6,2) NOT NULL DEFAULT 4.00,
  `weekend_production_speed` decimal(6,2) NOT NULL DEFAULT 2.00,
  `weekend_storage_speed` decimal(6,2) NOT NULL DEFAULT 2.00,
  `weekend_expedition_factor` decimal(6,2) NOT NULL DEFAULT 3.00,
  `weekend_energy_factor` decimal(6,2) NOT NULL DEFAULT 2.00,
  `is_weekend_active` tinyint(1) NOT NULL DEFAULT 0,
  `last_check` int(11) NOT NULL DEFAULT 0,
  `last_change` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `uni1_weekend_boost`
--

INSERT INTO `uni1_weekend_boost` (`id`, `enabled`, `start_day`, `start_hour`, `end_day`, `end_hour`, `normal_game_speed`, `normal_fleet_speed`, `normal_production_speed`, `normal_storage_speed`, `normal_expedition_factor`, `normal_energy_factor`, `weekend_game_speed`, `weekend_fleet_speed`, `weekend_production_speed`, `weekend_storage_speed`, `weekend_expedition_factor`, `weekend_energy_factor`, `is_weekend_active`, `last_check`, `last_change`) VALUES
(1, 1, 6, 0, 1, 0, 2.00, 4.00, 2.00, 1.00, 2.00, 2.00, 3.00, 5.00, 3.00, 2.00, 3.00, 3.00, 1, 1792259491, 1792246781);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `uni1_achievements_catalog`
--
ALTER TABLE `uni1_achievements_catalog`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code_level` (`code`,`level`);

--
-- Indices de la tabla `uni1_achievements_log`
--
ALTER TABLE `uni1_achievements_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `uni1_admin_bank_accounts`
--
ALTER TABLE `uni1_admin_bank_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_id` (`admin_id`);

--
-- Indices de la tabla `uni1_admin_bank_data`
--
ALTER TABLE `uni1_admin_bank_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_admin` (`admin_id`);

--
-- Indices de la tabla `uni1_admin_bank_movements`
--
ALTER TABLE `uni1_admin_bank_movements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `fecha` (`fecha`);

--
-- Indices de la tabla `uni1_admin_bank_transfers`
--
ALTER TABLE `uni1_admin_bank_transfers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `from_admin_id` (`from_admin_id`),
  ADD KEY `to_admin_id` (`to_admin_id`),
  ADD KEY `estado` (`estado`);

--
-- Indices de la tabla `uni1_aks`
--
ALTER TABLE `uni1_aks`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_alliance`
--
ALTER TABLE `uni1_alliance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ally_tag` (`ally_tag`),
  ADD KEY `ally_name` (`ally_name`),
  ADD KEY `ally_universe` (`ally_universe`);

--
-- Indices de la tabla `uni1_alliance_bank`
--
ALTER TABLE `uni1_alliance_bank`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_alliance` (`alliance_id`),
  ADD KEY `idx_tesorero` (`tesorero_id`);

--
-- Indices de la tabla `uni1_alliance_bank_bonuses`
--
ALTER TABLE `uni1_alliance_bank_bonuses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_alliance` (`alliance_id`);

--
-- Indices de la tabla `uni1_alliance_bank_daily`
--
ALTER TABLE `uni1_alliance_bank_daily`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_alliance` (`alliance_id`);

--
-- Indices de la tabla `uni1_alliance_bank_log`
--
ALTER TABLE `uni1_alliance_bank_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_alliance` (`alliance_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_accion` (`accion`),
  ADD KEY `idx_fecha` (`fecha`);

--
-- Indices de la tabla `uni1_alliance_bank_tesorero_log`
--
ALTER TABLE `uni1_alliance_bank_tesorero_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_alliance` (`alliance_id`);

--
-- Indices de la tabla `uni1_alliance_ranks`
--
ALTER TABLE `uni1_alliance_ranks`
  ADD PRIMARY KEY (`rankID`),
  ADD KEY `allianceID` (`allianceID`,`rankID`);

--
-- Indices de la tabla `uni1_alliance_request`
--
ALTER TABLE `uni1_alliance_request`
  ADD PRIMARY KEY (`applyID`),
  ADD KEY `allianceID` (`allianceID`,`userID`);

--
-- Indices de la tabla `uni1_alliance_talent_log`
--
ALTER TABLE `uni1_alliance_talent_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ally_time` (`alliance_id`,`log_time`);

--
-- Indices de la tabla `uni1_alliance_talent_points`
--
ALTER TABLE `uni1_alliance_talent_points`
  ADD PRIMARY KEY (`alliance_id`);

--
-- Indices de la tabla `uni1_alliance_talent_ranks`
--
ALTER TABLE `uni1_alliance_talent_ranks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ally_rank` (`alliance_id`,`rank_num`);

--
-- Indices de la tabla `uni1_asteroids`
--
ALTER TABLE `uni1_asteroids`
  ADD PRIMARY KEY (`id`),
  ADD KEY `coords` (`galaxy`,`system`,`planet`),
  ADD KEY `recycled` (`recycled`),
  ADD KEY `recycled_at` (`recycled_at`);

--
-- Indices de la tabla `uni1_banned`
--
ALTER TABLE `uni1_banned`
  ADD KEY `ID` (`id`),
  ADD KEY `universe` (`universe`);

--
-- Indices de la tabla `uni1_boosters`
--
ALTER TABLE `uni1_boosters`
  ADD PRIMARY KEY (`booster_id`);

--
-- Indices de la tabla `uni1_bp_config`
--
ALTER TABLE `uni1_bp_config`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_bp_log`
--
ALTER TABLE `uni1_bp_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_fecha` (`fecha`);

--
-- Indices de la tabla `uni1_bp_users`
--
ALTER TABLE `uni1_bp_users`
  ADD PRIMARY KEY (`user_id`);

--
-- Indices de la tabla `uni1_buddy`
--
ALTER TABLE `uni1_buddy`
  ADD PRIMARY KEY (`id`),
  ADD KEY `universe` (`universe`),
  ADD KEY `sender` (`sender`,`owner`);

--
-- Indices de la tabla `uni1_buddy_request`
--
ALTER TABLE `uni1_buddy_request`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_bug_categories`
--
ALTER TABLE `uni1_bug_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_clave` (`clave`);

--
-- Indices de la tabla `uni1_bug_log`
--
ALTER TABLE `uni1_bug_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_report` (`report_id`),
  ADD KEY `idx_admin` (`admin_id`),
  ADD KEY `idx_fecha` (`fecha`);

--
-- Indices de la tabla `uni1_bug_reports`
--
ALTER TABLE `uni1_bug_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_admin` (`admin_id`),
  ADD KEY `idx_fecha` (`fecha_creacion`),
  ADD KEY `idx_eliminada` (`eliminada`);

--
-- Indices de la tabla `uni1_chat_messages`
--
ALTER TABLE `uni1_chat_messages`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_chat_online`
--
ALTER TABLE `uni1_chat_online`
  ADD KEY `dateTime` (`dateTime`,`channel`);

--
-- Indices de la tabla `uni1_config`
--
ALTER TABLE `uni1_config`
  ADD PRIMARY KEY (`uni`);

--
-- Indices de la tabla `uni1_container_history`
--
ALTER TABLE `uni1_container_history`
  ADD PRIMARY KEY (`history_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `uni1_container_loot`
--
ALTER TABLE `uni1_container_loot`
  ADD PRIMARY KEY (`loot_id`);

--
-- Indices de la tabla `uni1_cronjobs`
--
ALTER TABLE `uni1_cronjobs`
  ADD UNIQUE KEY `cronjobID` (`cronjobID`),
  ADD KEY `isActive` (`isActive`,`nextTime`,`lock`,`cronjobID`);

--
-- Indices de la tabla `uni1_cronjobs_log`
--
ALTER TABLE `uni1_cronjobs_log`
  ADD KEY `cronjobId` (`cronjobId`,`executionTime`);

--
-- Indices de la tabla `uni1_diplo`
--
ALTER TABLE `uni1_diplo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `universe` (`universe`),
  ADD KEY `owner_1` (`owner_1`,`owner_2`,`accept`);

--
-- Indices de la tabla `uni1_discord_oauth`
--
ALTER TABLE `uni1_discord_oauth`
  ADD PRIMARY KEY (`state`);

--
-- Indices de la tabla `uni1_events`
--
ALTER TABLE `uni1_events`
  ADD PRIMARY KEY (`event_id`),
  ADD KEY `event_class` (`event_class`),
  ADD KEY `active` (`active`);

--
-- Indices de la tabla `uni1_events_history`
--
ALTER TABLE `uni1_events_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `uni1_events_rotation`
--
ALTER TABLE `uni1_events_rotation`
  ADD PRIMARY KEY (`class`);

--
-- Indices de la tabla `uni1_factions`
--
ALTER TABLE `uni1_factions`
  ADD PRIMARY KEY (`faction_id`);

--
-- Indices de la tabla `uni1_fleets`
--
ALTER TABLE `uni1_fleets`
  ADD PRIMARY KEY (`fleet_id`),
  ADD KEY `fleet_target_owner` (`fleet_target_owner`,`fleet_mission`),
  ADD KEY `fleet_owner` (`fleet_owner`,`fleet_mission`),
  ADD KEY `fleet_group` (`fleet_group`);

--
-- Indices de la tabla `uni1_fleettools_log`
--
ALTER TABLE `uni1_fleettools_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `uni1_fleet_event`
--
ALTER TABLE `uni1_fleet_event`
  ADD PRIMARY KEY (`fleetID`),
  ADD KEY `lock` (`lock`,`time`);

--
-- Indices de la tabla `uni1_gamedu`
--
ALTER TABLE `uni1_gamedu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_type_time` (`user_id`,`type`,`time`);

--
-- Indices de la tabla `uni1_gamedu_config`
--
ALTER TABLE `uni1_gamedu_config`
  ADD PRIMARY KEY (`config_key`);

--
-- Indices de la tabla `uni1_gamedu_tokens`
--
ALTER TABLE `uni1_gamedu_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_token` (`user_id`,`token`),
  ADD KEY `idx_started` (`started_at`),
  ADD KEY `idx_used` (`used`);

--
-- Indices de la tabla `uni1_improvements_catalog`
--
ALTER TABLE `uni1_improvements_catalog`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_chain_level` (`chain_id`,`level`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_type` (`type`);

--
-- Indices de la tabla `uni1_improvements_log`
--
ALTER TABLE `uni1_improvements_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_fecha` (`user_id`,`fecha`);

--
-- Indices de la tabla `uni1_improvements_seasons`
--
ALTER TABLE `uni1_improvements_seasons`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_season_number` (`season_number`);

--
-- Indices de la tabla `uni1_log`
--
ALTER TABLE `uni1_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `mode` (`mode`);

--
-- Indices de la tabla `uni1_log_fleets`
--
ALTER TABLE `uni1_log_fleets`
  ADD PRIMARY KEY (`fleet_id`),
  ADD KEY `BashRule` (`fleet_owner`,`fleet_end_id`,`fleet_start_time`,`fleet_mission`,`fleet_state`);

--
-- Indices de la tabla `uni1_lostpassword`
--
ALTER TABLE `uni1_lostpassword`
  ADD PRIMARY KEY (`key`),
  ADD UNIQUE KEY `userID` (`userID`,`key`,`time`,`hasChanged`),
  ADD KEY `time` (`time`);

--
-- Indices de la tabla `uni1_lottery_config`
--
ALTER TABLE `uni1_lottery_config`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_lottery_draws`
--
ALTER TABLE `uni1_lottery_draws`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_numero_sorteo` (`numero_sorteo`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_fecha` (`fecha_sorteo`);

--
-- Indices de la tabla `uni1_lottery_log`
--
ALTER TABLE `uni1_lottery_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_draw` (`draw_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_accion` (`accion`),
  ADD KEY `idx_fecha` (`fecha`);

--
-- Indices de la tabla `uni1_lottery_percentages`
--
ALTER TABLE `uni1_lottery_percentages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rango` (`jackpot_desde`,`jackpot_hasta`),
  ADD KEY `idx_orden` (`orden`);

--
-- Indices de la tabla `uni1_lottery_tickets`
--
ALTER TABLE `uni1_lottery_tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_draw` (`draw_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_user_draw` (`user_id`,`draw_id`);

--
-- Indices de la tabla `uni1_market_fund`
--
ALTER TABLE `uni1_market_fund`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_market_log`
--
ALTER TABLE `uni1_market_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `buyer` (`buyer_id`),
  ADD KEY `seller` (`seller_id`);

--
-- Indices de la tabla `uni1_market_offers`
--
ALTER TABLE `uni1_market_offers`
  ADD PRIMARY KEY (`offer_id`),
  ADD KEY `status` (`status`),
  ADD KEY `seller` (`seller_id`),
  ADD KEY `item` (`item_type`,`item_id`),
  ADD KEY `admin` (`admin_offer`);

--
-- Indices de la tabla `uni1_market_stats`
--
ALTER TABLE `uni1_market_stats`
  ADD PRIMARY KEY (`stat_id`),
  ADD UNIQUE KEY `date_item` (`stat_date`,`item_type`,`item_id`),
  ADD KEY `date` (`stat_date`),
  ADD KEY `item` (`item_type`,`item_id`);

--
-- Indices de la tabla `uni1_messages`
--
ALTER TABLE `uni1_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `message_sender` (`message_sender`),
  ADD KEY `message_deleted` (`message_deleted`),
  ADD KEY `message_owner` (`message_owner`,`message_type`,`message_unread`,`message_deleted`);

--
-- Indices de la tabla `uni1_multi`
--
ALTER TABLE `uni1_multi`
  ADD PRIMARY KEY (`multiID`),
  ADD KEY `userID` (`userID`);

--
-- Indices de la tabla `uni1_news`
--
ALTER TABLE `uni1_news`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_notes`
--
ALTER TABLE `uni1_notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `universe` (`universe`),
  ADD KEY `owner` (`owner`,`time`,`priority`);

--
-- Indices de la tabla `uni1_ntx20_log`
--
ALTER TABLE `uni1_ntx20_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_timestamp` (`timestamp`),
  ADD KEY `idx_amount` (`amount`),
  ADD KEY `idx_user_time` (`user_id`,`timestamp`);

--
-- Indices de la tabla `uni1_planets`
--
ALTER TABLE `uni1_planets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_luna` (`id_luna`),
  ADD KEY `id_owner` (`id_owner`),
  ADD KEY `destruyed` (`destruyed`),
  ADD KEY `universe` (`universe`,`galaxy`,`system`,`planet`,`planet_type`);

--
-- Indices de la tabla `uni1_pve_achievements`
--
ALTER TABLE `uni1_pve_achievements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_user` (`user_id`),
  ADD KEY `idx_consecutive` (`consecutive_months`);

--
-- Indices de la tabla `uni1_pve_acs_invites`
--
ALTER TABLE `uni1_pve_acs_invites`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_acs` (`acs_id`),
  ADD KEY `idx_invited` (`invited_user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_status_user` (`status`,`invited_user_id`);

--
-- Indices de la tabla `uni1_pve_bastion_damage`
--
ALTER TABLE `uni1_pve_bastion_damage`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_user` (`event_id`,`user_id`),
  ADD KEY `reg_rank` (`registration_id`,`damage_dealt`),
  ADD KEY `ally` (`ally_id`);

--
-- Indices de la tabla `uni1_pve_bastion_event`
--
ALTER TABLE `uni1_pve_bastion_event`
  ADD PRIMARY KEY (`id`),
  ADD KEY `status_time` (`status`,`start_time`,`end_time`);

--
-- Indices de la tabla `uni1_pve_bastion_ghosts`
--
ALTER TABLE `uni1_pve_bastion_ghosts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_ally` (`event_id`,`ally_id`),
  ADD KEY `registration` (`registration_id`),
  ADD KEY `ghost` (`ghost_user_id`),
  ADD KEY `status_time` (`status`,`spawned_at`);

--
-- Indices de la tabla `uni1_pve_bastion_registrations`
--
ALTER TABLE `uni1_pve_bastion_registrations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_ally` (`event_id`,`ally_id`),
  ADD KEY `event_rank` (`event_id`,`score_total`),
  ADD KEY `event_hp` (`event_id`,`pct_hp_preserved`),
  ADD KEY `ally` (`ally_id`),
  ADD KEY `bastion_ghost` (`bastion_ghost_user_id`);

--
-- Indices de la tabla `uni1_pve_bastion_waves`
--
ALTER TABLE `uni1_pve_bastion_waves`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_ally` (`event_id`,`ally_id`),
  ADD KEY `registration` (`registration_id`),
  ADD KEY `pending_resolve` (`resolved`,`arrival_time`),
  ADD KEY `wave_number` (`registration_id`,`wave_number`);

--
-- Indices de la tabla `uni1_pve_boss_damage`
--
ALTER TABLE `uni1_pve_boss_damage`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_user` (`event_id`,`user_id`),
  ADD KEY `reg_rank` (`registration_id`,`damage_done`),
  ADD KEY `ally` (`ally_id`);

--
-- Indices de la tabla `uni1_pve_boss_event`
--
ALTER TABLE `uni1_pve_boss_event`
  ADD PRIMARY KEY (`id`),
  ADD KEY `status_time` (`status`,`start_time`,`end_time`);

--
-- Indices de la tabla `uni1_pve_boss_ghosts`
--
ALTER TABLE `uni1_pve_boss_ghosts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_ally` (`event_id`,`ally_id`),
  ADD KEY `registration` (`registration_id`),
  ADD KEY `ghost` (`ghost_user_id`),
  ADD KEY `status_time` (`status`,`spawned_at`);

--
-- Indices de la tabla `uni1_pve_boss_registrations`
--
ALTER TABLE `uni1_pve_boss_registrations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_ally` (`event_id`,`ally_id`),
  ADD KEY `event_rank` (`event_id`,`pct_damage_total`),
  ADD KEY `event_damage` (`event_id`,`total_damage`),
  ADD KEY `ally` (`ally_id`);

--
-- Indices de la tabla `uni1_pve_config`
--
ALTER TABLE `uni1_pve_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_config_key` (`config_key`);

--
-- Indices de la tabla `uni1_pve_crisis`
--
ALTER TABLE `uni1_pve_crisis`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_start_time` (`start_time`),
  ADD KEY `idx_processing` (`processing`),
  ADD KEY `idx_ghost` (`ghost_user_id`);

--
-- Indices de la tabla `uni1_pve_crisis_attacks`
--
ALTER TABLE `uni1_pve_crisis_attacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_crisis` (`crisis_id`),
  ADD KEY `idx_wave` (`wave_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_user_crisis` (`user_id`,`crisis_id`),
  ADD KEY `idx_planet` (`planet_id`);

--
-- Indices de la tabla `uni1_pve_crisis_waves`
--
ALTER TABLE `uni1_pve_crisis_waves`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_crisis` (`crisis_id`),
  ADD KEY `idx_crisis_wave` (`crisis_id`,`wave_number`),
  ADD KEY `idx_executed` (`executed`);

--
-- Indices de la tabla `uni1_pve_empires`
--
ALTER TABLE `uni1_pve_empires`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_start_time` (`start_time`),
  ADD KEY `idx_location` (`galaxy`,`system`,`planet`),
  ADD KEY `idx_template` (`template_id`),
  ADD KEY `idx_ghost` (`ghost_user_id`);

--
-- Indices de la tabla `uni1_pve_empire_attacks`
--
ALTER TABLE `uni1_pve_empire_attacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_empire` (`empire_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_user_empire` (`user_id`,`empire_id`),
  ADD KEY `idx_attack_time` (`attack_time`);

--
-- Indices de la tabla `uni1_pve_empire_templates`
--
ALTER TABLE `uni1_pve_empire_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_slug` (`slug`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_default` (`is_default`);

--
-- Indices de la tabla `uni1_pve_ghosts`
--
ALTER TABLE `uni1_pve_ghosts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_user` (`user_id`),
  ADD KEY `idx_event` (`event_type`,`event_id`),
  ADD KEY `idx_position` (`galaxy`,`system`,`planet`),
  ADD KEY `idx_destroyed` (`destroyed_at`);

--
-- Indices de la tabla `uni1_pve_log`
--
ALTER TABLE `uni1_pve_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_event` (`event_type`,`event_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indices de la tabla `uni1_pve_rewards`
--
ALTER TABLE `uni1_pve_rewards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_user_claimed` (`user_id`,`claimed`),
  ADD KEY `idx_event` (`event_type`,`event_id`);

--
-- Indices de la tabla `uni1_pvp_achievements`
--
ALTER TABLE `uni1_pvp_achievements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_user_ach` (`user_id`,`achievement`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indices de la tabla `uni1_pvp_arenas`
--
ALTER TABLE `uni1_pvp_arenas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_creator` (`creator_id`),
  ADD KEY `idx_universe` (`universe`);

--
-- Indices de la tabla `uni1_pvp_arena_attacks`
--
ALTER TABLE `uni1_pvp_arena_attacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_arena` (`arena_id`),
  ADD KEY `idx_attacker` (`attacker_id`),
  ADD KEY `idx_defender` (`defender_id`);

--
-- Indices de la tabla `uni1_pvp_arena_players`
--
ALTER TABLE `uni1_pvp_arena_players`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_arena_user` (`arena_id`,`user_id`),
  ADD KEY `idx_arena` (`arena_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indices de la tabla `uni1_pvp_config`
--
ALTER TABLE `uni1_pvp_config`
  ADD PRIMARY KEY (`config_key`);

--
-- Indices de la tabla `uni1_pvp_log`
--
ALTER TABLE `uni1_pvp_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_event` (`event_type`,`event_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indices de la tabla `uni1_pvp_tournaments`
--
ALTER TABLE `uni1_pvp_tournaments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_universe` (`universe`);

--
-- Indices de la tabla `uni1_pvp_tournament_attacks`
--
ALTER TABLE `uni1_pvp_tournament_attacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tournament` (`tournament_id`),
  ADD KEY `idx_match` (`match_id`),
  ADD KEY `idx_attacker` (`attacker_id`),
  ADD KEY `idx_defender` (`defender_id`);

--
-- Indices de la tabla `uni1_pvp_tournament_matches`
--
ALTER TABLE `uni1_pvp_tournament_matches`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tournament` (`tournament_id`),
  ADD KEY `idx_round` (`round_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indices de la tabla `uni1_pvp_tournament_players`
--
ALTER TABLE `uni1_pvp_tournament_players`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tournament` (`tournament_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_alliance` (`alliance_id`);

--
-- Indices de la tabla `uni1_pvp_tournament_rounds`
--
ALTER TABLE `uni1_pvp_tournament_rounds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tournament` (`tournament_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indices de la tabla `uni1_races`
--
ALTER TABLE `uni1_races`
  ADD PRIMARY KEY (`race_id`);

--
-- Indices de la tabla `uni1_raffles`
--
ALTER TABLE `uni1_raffles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_moneda` (`moneda`),
  ADD KEY `idx_fecha_fin` (`fecha_fin`);

--
-- Indices de la tabla `uni1_raffle_log`
--
ALTER TABLE `uni1_raffle_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_raffle` (`raffle_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_accion` (`accion`),
  ADD KEY `idx_fecha` (`fecha`);

--
-- Indices de la tabla `uni1_raffle_prizes`
--
ALTER TABLE `uni1_raffle_prizes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_raffle` (`raffle_id`),
  ADD KEY `idx_orden` (`raffle_id`,`orden`),
  ADD KEY `idx_ganador` (`ganador_id`);

--
-- Indices de la tabla `uni1_raffle_tickets`
--
ALTER TABLE `uni1_raffle_tickets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_raffle_boleto` (`raffle_id`,`boleto_numero`),
  ADD UNIQUE KEY `uk_raffle_user` (`raffle_id`,`user_id`),
  ADD KEY `idx_raffle` (`raffle_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indices de la tabla `uni1_raports`
--
ALTER TABLE `uni1_raports`
  ADD PRIMARY KEY (`rid`),
  ADD KEY `time` (`time`);

--
-- Indices de la tabla `uni1_session`
--
ALTER TABLE `uni1_session`
  ADD PRIMARY KEY (`userID`),
  ADD KEY `sessionID` (`sessionID`);

--
-- Indices de la tabla `uni1_shop_autosave`
--
ALTER TABLE `uni1_shop_autosave`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fecha` (`fecha`);

--
-- Indices de la tabla `uni1_shop_items`
--
ALTER TABLE `uni1_shop_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tipo` (`tipo`),
  ADD KEY `activo` (`activo`),
  ADD KEY `orden` (`orden`);

--
-- Indices de la tabla `uni1_shop_purchases`
--
ALTER TABLE `uni1_shop_purchases`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `fecha` (`fecha`),
  ADD KEY `item_tipo` (`item_tipo`);

--
-- Indices de la tabla `uni1_shop_templates`
--
ALTER TABLE `uni1_shop_templates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `creado_por` (`creado_por`);

--
-- Indices de la tabla `uni1_shortcuts`
--
ALTER TABLE `uni1_shortcuts`
  ADD PRIMARY KEY (`shortcutID`),
  ADD KEY `ownerID` (`ownerID`);

--
-- Indices de la tabla `uni1_statpoints`
--
ALTER TABLE `uni1_statpoints`
  ADD KEY `id_owner` (`id_owner`),
  ADD KEY `universe` (`universe`),
  ADD KEY `stat_type` (`stat_type`);

--
-- Indices de la tabla `uni1_tasks_catalog`
--
ALTER TABLE `uni1_tasks_catalog`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indices de la tabla `uni1_tasks_log`
--
ALTER TABLE `uni1_tasks_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `uni1_ticket`
--
ALTER TABLE `uni1_ticket`
  ADD PRIMARY KEY (`ticketID`),
  ADD KEY `ownerID` (`ownerID`),
  ADD KEY `universe` (`universe`,`status`);

--
-- Indices de la tabla `uni1_ticket_answer`
--
ALTER TABLE `uni1_ticket_answer`
  ADD PRIMARY KEY (`answerID`);

--
-- Indices de la tabla `uni1_ticket_category`
--
ALTER TABLE `uni1_ticket_category`
  ADD PRIMARY KEY (`categoryID`);

--
-- Indices de la tabla `uni1_topkb`
--
ALTER TABLE `uni1_topkb`
  ADD KEY `time` (`universe`,`rid`,`time`);

--
-- Indices de la tabla `uni1_tourney`
--
ALTER TABLE `uni1_tourney`
  ADD PRIMARY KEY (`tourneyId`);

--
-- Indices de la tabla `uni1_tourney_logs`
--
ALTER TABLE `uni1_tourney_logs`
  ADD PRIMARY KEY (`logId`);

--
-- Indices de la tabla `uni1_tourney_participante`
--
ALTER TABLE `uni1_tourney_participante`
  ADD PRIMARY KEY (`joinId`),
  ADD KEY `idx_torneo_user` (`tourneyJoin`,`playerId`);

--
-- Indices de la tabla `uni1_users`
--
ALTER TABLE `uni1_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `authlevel` (`authlevel`),
  ADD KEY `ref_bonus` (`ref_bonus`),
  ADD KEY `universe` (`universe`,`username`,`password`,`onlinetime`,`authlevel`),
  ADD KEY `ally_id` (`ally_id`);

--
-- Indices de la tabla `uni1_users_achievements`
--
ALTER TABLE `uni1_users_achievements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_code` (`user_id`,`code`),
  ADD KEY `status` (`status`);

--
-- Indices de la tabla `uni1_users_auth`
--
ALTER TABLE `uni1_users_auth`
  ADD PRIMARY KEY (`id`,`mode`),
  ADD KEY `idx_account` (`account`),
  ADD KEY `idx_mode` (`mode`);

--
-- Indices de la tabla `uni1_users_boosters`
--
ALTER TABLE `uni1_users_boosters`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `expires_at` (`expires_at`);

--
-- Indices de la tabla `uni1_users_coord_favorites`
--
ALTER TABLE `uni1_users_coord_favorites`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `uni1_users_events`
--
ALTER TABLE `uni1_users_events`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_event` (`user_id`,`event_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `event_id` (`event_id`);

--
-- Indices de la tabla `uni1_users_fleet_presets`
--
ALTER TABLE `uni1_users_fleet_presets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `uni1_users_improvements_eq`
--
ALTER TABLE `uni1_users_improvements_eq`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_user_unit_slot` (`user_id`,`unit_id`,`slot`),
  ADD KEY `idx_user_unit` (`user_id`,`unit_id`);

--
-- Indices de la tabla `uni1_users_improvements_inv`
--
ALTER TABLE `uni1_users_improvements_inv`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_user_item` (`user_id`,`item_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indices de la tabla `uni1_users_market`
--
ALTER TABLE `uni1_users_market`
  ADD PRIMARY KEY (`user_id`);

--
-- Indices de la tabla `uni1_users_tasks`
--
ALTER TABLE `uni1_users_tasks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_task` (`user_id`,`task_id`),
  ADD KEY `status` (`status`);

--
-- Indices de la tabla `uni1_users_to_acs`
--
ALTER TABLE `uni1_users_to_acs`
  ADD KEY `userID` (`userID`),
  ADD KEY `acsID` (`acsID`);

--
-- Indices de la tabla `uni1_users_to_extauth`
--
ALTER TABLE `uni1_users_to_extauth`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`),
  ADD KEY `account` (`account`,`mode`);

--
-- Indices de la tabla `uni1_users_to_topkb`
--
ALTER TABLE `uni1_users_to_topkb`
  ADD KEY `rid` (`rid`,`role`);

--
-- Indices de la tabla `uni1_users_valid`
--
ALTER TABLE `uni1_users_valid`
  ADD PRIMARY KEY (`validationID`,`validationKey`);

--
-- Indices de la tabla `uni1_users_vip`
--
ALTER TABLE `uni1_users_vip`
  ADD PRIMARY KEY (`vip_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `vip_active` (`vip_active`),
  ADD KEY `vip_end` (`vip_end`);

--
-- Indices de la tabla `uni1_users_wallet`
--
ALTER TABLE `uni1_users_wallet`
  ADD PRIMARY KEY (`user_id`);

--
-- Indices de la tabla `uni1_vars`
--
ALTER TABLE `uni1_vars`
  ADD PRIMARY KEY (`elementID`),
  ADD KEY `class` (`class`);

--
-- Indices de la tabla `uni1_vars_rapidfire`
--
ALTER TABLE `uni1_vars_rapidfire`
  ADD KEY `elementID` (`elementID`),
  ADD KEY `rapidfireID` (`rapidfireID`);

--
-- Indices de la tabla `uni1_vars_requriements`
--
ALTER TABLE `uni1_vars_requriements`
  ADD KEY `elementID` (`elementID`),
  ADD KEY `requireID` (`requireID`);

--
-- Indices de la tabla `uni1_wallet_fund`
--
ALTER TABLE `uni1_wallet_fund`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_wallet_investments`
--
ALTER TABLE `uni1_wallet_investments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `estado` (`estado`),
  ADD KEY `idx_estado_eliminada` (`estado`,`eliminada`),
  ADD KEY `idx_admin_estado` (`admin_id`,`estado`),
  ADD KEY `idx_fecha_creacion` (`fecha`);

--
-- Indices de la tabla `uni1_wallet_investment_log`
--
ALTER TABLE `uni1_wallet_investment_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_investment` (`investment_id`),
  ADD KEY `idx_accion` (`accion`);

--
-- Indices de la tabla `uni1_wallet_referral_fund`
--
ALTER TABLE `uni1_wallet_referral_fund`
  ADD PRIMARY KEY (`id`),
  ADD KEY `referidor_id` (`referidor_id`);

--
-- Indices de la tabla `uni1_wallet_stats_daily`
--
ALTER TABLE `uni1_wallet_stats_daily`
  ADD PRIMARY KEY (`fecha`);

--
-- Indices de la tabla `uni1_wallet_tasa_historial`
--
ALTER TABLE `uni1_wallet_tasa_historial`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fecha` (`fecha`);

--
-- Indices de la tabla `uni1_wallet_transactions`
--
ALTER TABLE `uni1_wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `tipo` (`tipo`);

--
-- Indices de la tabla `uni1_wallet_transfers_log`
--
ALTER TABLE `uni1_wallet_transfers_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_admin` (`admin_id`),
  ADD KEY `idx_referidor` (`referidor_id`),
  ADD KEY `idx_fecha` (`fecha_confirmacion`),
  ADD KEY `idx_resultado` (`resultado`);

--
-- Indices de la tabla `uni1_wallet_withdrawals`
--
ALTER TABLE `uni1_wallet_withdrawals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `estado` (`estado`);

--
-- Indices de la tabla `uni1_war_battles`
--
ALTER TABLE `uni1_war_battles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_atacante` (`atacante_id`),
  ADD KEY `idx_defensor` (`defensor_id`),
  ADD KEY `idx_fin` (`fin`);

--
-- Indices de la tabla `uni1_war_chests`
--
ALTER TABLE `uni1_war_chests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_battle` (`battle_id`);

--
-- Indices de la tabla `uni1_war_history`
--
ALTER TABLE `uni1_war_history`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_war_log`
--
ALTER TABLE `uni1_war_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_battle` (`battle_id`);

--
-- Indices de la tabla `uni1_war_participants`
--
ALTER TABLE `uni1_war_participants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_battle_user` (`battle_id`,`user_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indices de la tabla `uni1_war_points`
--
ALTER TABLE `uni1_war_points`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_user` (`user_id`);

--
-- Indices de la tabla `uni1_war_seasons`
--
ALTER TABLE `uni1_war_seasons`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `uni1_weekend_boost`
--
ALTER TABLE `uni1_weekend_boost`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `uni1_achievements_catalog`
--
ALTER TABLE `uni1_achievements_catalog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT de la tabla `uni1_achievements_log`
--
ALTER TABLE `uni1_achievements_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_admin_bank_accounts`
--
ALTER TABLE `uni1_admin_bank_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_admin_bank_data`
--
ALTER TABLE `uni1_admin_bank_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_admin_bank_movements`
--
ALTER TABLE `uni1_admin_bank_movements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_admin_bank_transfers`
--
ALTER TABLE `uni1_admin_bank_transfers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_aks`
--
ALTER TABLE `uni1_aks`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance`
--
ALTER TABLE `uni1_alliance`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_bank`
--
ALTER TABLE `uni1_alliance_bank`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_bank_bonuses`
--
ALTER TABLE `uni1_alliance_bank_bonuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_bank_daily`
--
ALTER TABLE `uni1_alliance_bank_daily`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_bank_log`
--
ALTER TABLE `uni1_alliance_bank_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_bank_tesorero_log`
--
ALTER TABLE `uni1_alliance_bank_tesorero_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_ranks`
--
ALTER TABLE `uni1_alliance_ranks`
  MODIFY `rankID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_request`
--
ALTER TABLE `uni1_alliance_request`
  MODIFY `applyID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_talent_log`
--
ALTER TABLE `uni1_alliance_talent_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_alliance_talent_ranks`
--
ALTER TABLE `uni1_alliance_talent_ranks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_asteroids`
--
ALTER TABLE `uni1_asteroids`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_banned`
--
ALTER TABLE `uni1_banned`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_boosters`
--
ALTER TABLE `uni1_boosters`
  MODIFY `booster_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `uni1_bp_config`
--
ALTER TABLE `uni1_bp_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `uni1_bp_log`
--
ALTER TABLE `uni1_bp_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_buddy`
--
ALTER TABLE `uni1_buddy`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_bug_categories`
--
ALTER TABLE `uni1_bug_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `uni1_bug_log`
--
ALTER TABLE `uni1_bug_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_bug_reports`
--
ALTER TABLE `uni1_bug_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_chat_messages`
--
ALTER TABLE `uni1_chat_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_config`
--
ALTER TABLE `uni1_config`
  MODIFY `uni` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `uni1_container_history`
--
ALTER TABLE `uni1_container_history`
  MODIFY `history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_container_loot`
--
ALTER TABLE `uni1_container_loot`
  MODIFY `loot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT de la tabla `uni1_cronjobs`
--
ALTER TABLE `uni1_cronjobs`
  MODIFY `cronjobID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `uni1_diplo`
--
ALTER TABLE `uni1_diplo`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_events`
--
ALTER TABLE `uni1_events`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT de la tabla `uni1_events_history`
--
ALTER TABLE `uni1_events_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_factions`
--
ALTER TABLE `uni1_factions`
  MODIFY `faction_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `uni1_fleets`
--
ALTER TABLE `uni1_fleets`
  MODIFY `fleet_id` bigint(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_fleettools_log`
--
ALTER TABLE `uni1_fleettools_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_gamedu`
--
ALTER TABLE `uni1_gamedu`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_gamedu_tokens`
--
ALTER TABLE `uni1_gamedu_tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_improvements_catalog`
--
ALTER TABLE `uni1_improvements_catalog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=991;

--
-- AUTO_INCREMENT de la tabla `uni1_improvements_log`
--
ALTER TABLE `uni1_improvements_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_improvements_seasons`
--
ALTER TABLE `uni1_improvements_seasons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `uni1_log`
--
ALTER TABLE `uni1_log`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_lottery_config`
--
ALTER TABLE `uni1_lottery_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `uni1_lottery_draws`
--
ALTER TABLE `uni1_lottery_draws`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_lottery_log`
--
ALTER TABLE `uni1_lottery_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_lottery_percentages`
--
ALTER TABLE `uni1_lottery_percentages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `uni1_lottery_tickets`
--
ALTER TABLE `uni1_lottery_tickets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_market_fund`
--
ALTER TABLE `uni1_market_fund`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_market_log`
--
ALTER TABLE `uni1_market_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_market_offers`
--
ALTER TABLE `uni1_market_offers`
  MODIFY `offer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_market_stats`
--
ALTER TABLE `uni1_market_stats`
  MODIFY `stat_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_messages`
--
ALTER TABLE `uni1_messages`
  MODIFY `message_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_multi`
--
ALTER TABLE `uni1_multi`
  MODIFY `multiID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_news`
--
ALTER TABLE `uni1_news`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_notes`
--
ALTER TABLE `uni1_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_ntx20_log`
--
ALTER TABLE `uni1_ntx20_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_planets`
--
ALTER TABLE `uni1_planets`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_achievements`
--
ALTER TABLE `uni1_pve_achievements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_acs_invites`
--
ALTER TABLE `uni1_pve_acs_invites`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_bastion_damage`
--
ALTER TABLE `uni1_pve_bastion_damage`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_bastion_event`
--
ALTER TABLE `uni1_pve_bastion_event`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_bastion_ghosts`
--
ALTER TABLE `uni1_pve_bastion_ghosts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_bastion_registrations`
--
ALTER TABLE `uni1_pve_bastion_registrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_bastion_waves`
--
ALTER TABLE `uni1_pve_bastion_waves`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_boss_damage`
--
ALTER TABLE `uni1_pve_boss_damage`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_boss_event`
--
ALTER TABLE `uni1_pve_boss_event`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_boss_ghosts`
--
ALTER TABLE `uni1_pve_boss_ghosts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_boss_registrations`
--
ALTER TABLE `uni1_pve_boss_registrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_config`
--
ALTER TABLE `uni1_pve_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=146;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_crisis`
--
ALTER TABLE `uni1_pve_crisis`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_crisis_attacks`
--
ALTER TABLE `uni1_pve_crisis_attacks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_crisis_waves`
--
ALTER TABLE `uni1_pve_crisis_waves`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_empires`
--
ALTER TABLE `uni1_pve_empires`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_empire_attacks`
--
ALTER TABLE `uni1_pve_empire_attacks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_empire_templates`
--
ALTER TABLE `uni1_pve_empire_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_ghosts`
--
ALTER TABLE `uni1_pve_ghosts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_log`
--
ALTER TABLE `uni1_pve_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pve_rewards`
--
ALTER TABLE `uni1_pve_rewards`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_achievements`
--
ALTER TABLE `uni1_pvp_achievements`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_arenas`
--
ALTER TABLE `uni1_pvp_arenas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_arena_attacks`
--
ALTER TABLE `uni1_pvp_arena_attacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_arena_players`
--
ALTER TABLE `uni1_pvp_arena_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_log`
--
ALTER TABLE `uni1_pvp_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_tournaments`
--
ALTER TABLE `uni1_pvp_tournaments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_tournament_attacks`
--
ALTER TABLE `uni1_pvp_tournament_attacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_tournament_matches`
--
ALTER TABLE `uni1_pvp_tournament_matches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_tournament_players`
--
ALTER TABLE `uni1_pvp_tournament_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_pvp_tournament_rounds`
--
ALTER TABLE `uni1_pvp_tournament_rounds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_races`
--
ALTER TABLE `uni1_races`
  MODIFY `race_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `uni1_raffles`
--
ALTER TABLE `uni1_raffles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_raffle_log`
--
ALTER TABLE `uni1_raffle_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_raffle_prizes`
--
ALTER TABLE `uni1_raffle_prizes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_raffle_tickets`
--
ALTER TABLE `uni1_raffle_tickets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_shop_autosave`
--
ALTER TABLE `uni1_shop_autosave`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_shop_items`
--
ALTER TABLE `uni1_shop_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `uni1_shop_purchases`
--
ALTER TABLE `uni1_shop_purchases`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_shop_templates`
--
ALTER TABLE `uni1_shop_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_shortcuts`
--
ALTER TABLE `uni1_shortcuts`
  MODIFY `shortcutID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_tasks_catalog`
--
ALTER TABLE `uni1_tasks_catalog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `uni1_tasks_log`
--
ALTER TABLE `uni1_tasks_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_ticket`
--
ALTER TABLE `uni1_ticket`
  MODIFY `ticketID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_ticket_answer`
--
ALTER TABLE `uni1_ticket_answer`
  MODIFY `answerID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_ticket_category`
--
ALTER TABLE `uni1_ticket_category`
  MODIFY `categoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `uni1_tourney_logs`
--
ALTER TABLE `uni1_tourney_logs`
  MODIFY `logId` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_tourney_participante`
--
ALTER TABLE `uni1_tourney_participante`
  MODIFY `joinId` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users`
--
ALTER TABLE `uni1_users`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_achievements`
--
ALTER TABLE `uni1_users_achievements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_boosters`
--
ALTER TABLE `uni1_users_boosters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_coord_favorites`
--
ALTER TABLE `uni1_users_coord_favorites`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_events`
--
ALTER TABLE `uni1_users_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_fleet_presets`
--
ALTER TABLE `uni1_users_fleet_presets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_improvements_eq`
--
ALTER TABLE `uni1_users_improvements_eq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_improvements_inv`
--
ALTER TABLE `uni1_users_improvements_inv`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_tasks`
--
ALTER TABLE `uni1_users_tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_valid`
--
ALTER TABLE `uni1_users_valid`
  MODIFY `validationID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_users_vip`
--
ALTER TABLE `uni1_users_vip`
  MODIFY `vip_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_wallet_investments`
--
ALTER TABLE `uni1_wallet_investments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_wallet_investment_log`
--
ALTER TABLE `uni1_wallet_investment_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_wallet_referral_fund`
--
ALTER TABLE `uni1_wallet_referral_fund`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_wallet_tasa_historial`
--
ALTER TABLE `uni1_wallet_tasa_historial`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_wallet_transactions`
--
ALTER TABLE `uni1_wallet_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_wallet_transfers_log`
--
ALTER TABLE `uni1_wallet_transfers_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_wallet_withdrawals`
--
ALTER TABLE `uni1_wallet_withdrawals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_war_battles`
--
ALTER TABLE `uni1_war_battles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_war_chests`
--
ALTER TABLE `uni1_war_chests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_war_history`
--
ALTER TABLE `uni1_war_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_war_log`
--
ALTER TABLE `uni1_war_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_war_participants`
--
ALTER TABLE `uni1_war_participants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_war_points`
--
ALTER TABLE `uni1_war_points`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `uni1_war_seasons`
--
ALTER TABLE `uni1_war_seasons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `uni1_weekend_boost`
--
ALTER TABLE `uni1_weekend_boost`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
