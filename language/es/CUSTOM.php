<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */
 
// If you have custom lang vars, you can include them here. The file ll be not overwrite by updatemanager
// Also you can overwrite exists var, too. You use the same key.

/**
 * main.navigation.tpl
**/
$LNG['mn_username']			= "Apodo";

/**
 * page.overview.default.tpl
**/
$LNG['ov_online_user']			= "Jugadores en línea";
$LNG['ov_ticket']				= "Boleto";
$LNG['ov_create_moon']			= "Crea una luna";
$LNG['ov_list_title_build']		= "Edificio";
$LNG['ov_list_title_tech']		= "Búsqueda";
$LNG['ov_list_title_fleet']		= "Flota/Defensa";

// ============================================
// ASTROIO - OVERRIDES DE BONUS (respaldo)
// Se cargan DESPUÉS de INGAME.php.
// Si INGAME.php se sobreescribe en una actualización,
// estas traducciones se mantienen.
// ============================================
$LNG['bonus']['Attack']              = 'Ataque';
$LNG['bonus']['Defensive']           = 'Defensa';
$LNG['bonus']['Shield']              = 'Escudo';
$LNG['bonus']['BuildTime']           = 'Tiempo de construcción';
$LNG['bonus']['ResearchTime']        = 'Tiempo de investigación';
$LNG['bonus']['ShipTime']            = 'Tiempo de construcción de naves';
$LNG['bonus']['DefensiveTime']       = 'Tiempo de construcción de defensas';
$LNG['bonus']['Resource']            = 'Producción de recursos';
$LNG['bonus']['Energy']              = 'Producción de energía';
$LNG['bonus']['ResourceStorage']     = 'Capacidad de almacenamiento';
$LNG['bonus']['ShipStorage']         = 'Capacidad de carga de naves';
$LNG['bonus']['FlyTime']             = 'Tiempo de vuelo';
$LNG['bonus']['FleetSlots']          = 'Espacios de flota';
$LNG['bonus']['Planets']             = 'Planetas';
$LNG['bonus']['SpyPower']            = 'Poder de espionaje';
$LNG['bonus']['Expedition']          = 'Expedición';
$LNG['bonus']['GateCoolTime']        = 'Tiempo de recarga del salto';
$LNG['bonus']['MoreFound']           = 'Más hallazgos';

// ============================================
// ASTROIO - OVERRIDE DE "Duración del efecto"
// (Por si INGAME.php se sobreescribe)
// ============================================
$LNG['in_dest_durati']               = 'Duración del efecto';

// ============================================
// ASTROIO — MINI TORNEOS
// ============================================

// --- Título del módulo (para el header y el título de la página) ---
$LNG['lm_tourney']          = 'Mini Torneos';

// --- Interfaz de la página ---
$LNG['tourney_pos']         = 'Posición';
$LNG['tourney_name']        = 'Nombre';
$LNG['tourney_pts']         = 'Puntos';
$LNG['tourney_btn']         = 'Participar';
$LNG['tourney_time']        = 'Tiempo restante';
$LNG['tourney_end']         = 'Los torneos terminaron. Espere al próximo comienzo.';
$LNG['tourney_noplayers']   = 'No hay jugadores participando en este torneo.';
$LNG['tourney_history']     = 'Historial';
$LNG['tourney_already']     = 'Ya estás participando en este torneo';

// --- Descripciones de cada tipo de torneo (evento 1 al 10) ---
$LNG['tourney_1']  = 'Participe en este torneo. Los ganadores son los jugadores que encuentren más Materia Oscura en las expediciones.';
$LNG['tourney_2']  = 'Participe en este torneo. Los ganadores son los jugadores que pierdan más flota en un agujero negro.';
$LNG['tourney_3']  = 'Participe en este torneo. Los ganadores son los jugadores que causen más destrucción de unidades en batallas.';
$LNG['tourney_4']  = 'Participe en este torneo. Los ganadores son los jugadores que ganen más batallas.';
$LNG['tourney_5']  = 'Participe en este torneo. Los ganadores son los jugadores que logren más expediciones exitosas.';
$LNG['tourney_6']  = 'Participe en este torneo. Los ganadores son los jugadores que encuentren más naves en las expediciones.';
$LNG['tourney_7']  = 'Participe en este torneo. Los ganadores son los jugadores que encuentren más de 700 de Materia Oscura en las expediciones.';
$LNG['tourney_8']  = 'Participe en este torneo. Los ganadores son los jugadores que ganen más batallas contra Aliens y Piratas.';
$LNG['tourney_9']  = 'Participe en este torneo. Los ganadores son los jugadores que destruyan más lunas a jugadores activos.';
$LNG['tourney_10'] = 'Participe en este torneo. Los ganadores son los jugadores que creen más lunas a jugadores activos.';

// (Por si en algún momento se activa el evento 11)
$LNG['tourney_11'] = 'Participe en este torneo. Los ganadores son los jugadores que reciban más experiencia de combate.';