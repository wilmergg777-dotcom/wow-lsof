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

//SET TIMEZONE (if Server Timezone are not correct)
//date_default_timezone_set('America/Chicago');

//TEMPLATES DEFAULT SETTINGS
define('DEFAULT_THEME'	 		    , 'gow');
define('HTTPS'						, isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"]  == 'on');
define('PROTOCOL'					, HTTPS ? 'https://' : 'http://');
if(PHP_SAPI === 'cli')
{
	$requestUrl	= str_replace(array(dirname(dirname(__FILE__)), '\\'), array('', '/'), $_SERVER["PHP_SELF"]);

	//debug mode
	define('HTTP_BASE'					, str_replace(array('\\', '//'), '/', dirname($_SERVER['SCRIPT_NAME']).'/'));
	define('HTTP_ROOT'					, str_replace(basename($_SERVER['SCRIPT_FILENAME']), '', parse_url($requestUrl, PHP_URL_PATH)));

	define('HTTP_FILE'					, basename($_SERVER['SCRIPT_NAME']));
	define('HTTP_HOST'					, '127.0.0.1');
	define('HTTP_PATH'					, PROTOCOL.HTTP_HOST.HTTP_ROOT);
}
else
{
	define('HTTP_BASE'					, str_replace(array('\\', '//'), '/', dirname($_SERVER['SCRIPT_NAME']).'/'));
	define('HTTP_ROOT'					, str_replace(basename($_SERVER['SCRIPT_FILENAME']), '', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)));

	define('HTTP_FILE'					, basename($_SERVER['SCRIPT_NAME']));
	define('HTTP_HOST'					, $_SERVER['HTTP_HOST']);
	define('HTTP_PATH'					, PROTOCOL.HTTP_HOST.HTTP_ROOT);
}

if(!defined('AJAX_CHAT_PATH')) {
	define('AJAX_CHAT_PATH', ROOT_PATH.'chat/');
}

if(!defined('CACHE_PATH')) {
	define('CACHE_PATH', ROOT_PATH.'cache/');
}

define('COMBAT_ENGINE'				, 'xnova');

// For Fatal Errors!
define('DEFAULT_LANG'				, 'de');

// SUPPORT WILDCAST DOMAINS
define('UNIS_WILDCAST'				, false);

// FIELDS FOR EACH LEVEL OF THE LUNAR BASE
define('FIELDS_BY_MOONBASIS_LEVEL'	, 3);

// FIELDS FOR EACH LEVEL OF THE TERRAFORMER
define('FIELDS_BY_TERRAFORMER'		, 5);

// TIME IN SECONDS, TO (i) APPEAR ON GALAXY
define('INACTIVE'					, 604800);

// TIME IN SECONDS, TO (i I) APPEAR ON GALAXY
define('INACTIVE_LONG'				, 2419200);

// FEE FOR CANCEL QUEUE IN SHIPYARD
define('FACTOR_CANCEL_SHIPYARD'		, 0.6);

// MINIMUM FLEET TIME
define('MIN_FLEET_TIME'				, 5);	

// 🆕 ASTROIO - LÍMITE MÁXIMO DE MIEMBROS POR ALIANZA
define('MAX_ALLIANCE_MEMBERS'       , 7);

// PHALANX COST'S
define('PHALANX_DEUTERIUM'			, 5000);	

// Time of changable nick after changing nick.
define('USERNAME_CHANGETIME'		, 604800);

// Max Results in Searchpage (-1 = disable)
define('SEARCH_LIMIT'				, 25);

// Messages per page at message list
define('MESSAGES_PER_PAGE'			, 10);

// banned users per page at ban list
define('BANNED_USERS_PER_PAGE'		, 25);

// How much IP Block ll be checked
// 1 = (AAA); 2 = (AAA.BBB); 3 = (AAA.BBB.CCC)
define('COMPARE_IP_BLOCKS'			, 1);

// Max Round on Combats
define('MAX_ATTACK_ROUNDS'			, 6);

// Enable the one-Click SImulation on Spy-Raports
define('ENABLE_SIMULATOR_LINK'		, true);

// Max. User Session in Seconds
define('SESSION_LIFETIME'			, 43200);

// ENABLE Mutlialert on sending fleets
define('ENABLE_MULTIALERT'			, true);

// UTF-8 support for names (required for non-english chars!)
define('UTF8_SUPPORT'				, true);

// Define, how its more hard to spy all inforation
/*
	if [Spy tech level of sender] > [Spy tech level of target]
		min amount of spies = -1 * (abs([Spy tech level of sender] - [Spy tech level of target]) * SPY_DIFFENCE_FACTOR) ^ 2;
	else
		min amount of spies = -1 * (abs([Spy tech level of sender] - [Spy tech level of target]) * SPY_DIFFENCE_FACTOR) ^ 2;
	
*/
define('SPY_DIFFENCE_FACTOR'		, 1);

// Define, how its more hard to spy all inforation
/*
	min amount of spies = see MissionCaseSpy.php#78

	To see Fleet		= {min amount of spies}
	To see Defense		= {min amount of spies} + 1 * SPY_VIEW_FACTOR
	To see Buildings	= {min amount of spies} + 3 * SPY_VIEW_FACTOR
	To see Technology	= {min amount of spies} + 5 * SPY_VIEW_FACTOR
*/
define('SPY_VIEW_FACTOR'			, 1);

// Bash Settings
define('BASH_ON'					, false);	
define('BASH_COUNT'					, 6);	
define('BASH_TIME'					, 86400);	

// Bash rule on wars:
// 0 = NORMAL
// 1 = ON WAR, BASH RULE IS DEACTIVE
define('BASH_WAR'					, 0);

// MINIMUM FLEET TIME MUST HIGHER THEN BASH_TIME
define('FLEETLOG_AGE'				, 86400);	

// Root IDs
define('ROOT_UNI'					, 1);	
define('ROOT_USER'					, 1);	

// AUTHLEVEL
define('AUTH_ADM'					, 3);
define('AUTH_OPS'					, 2);
define('AUTH_MOD'					, 1);
define('AUTH_USR'					, 0);

// Modules
define('MODULE_AMOUNT'				, 73);
define('MODULE_ALLIANCE'			, 0);
define('MODULE_BANLIST'				, 21);
define('MODULE_BANNER'				, 37);
define('MODULE_BATTLEHALL'			, 12);
define('MODULE_BUDDYLIST'			, 6);
define('MODULE_BUILDING'			, 2);
define('MODULE_CHAT'				, 7);
define('MODULE_DMEXTRAS'			, 8);
define('MODULE_FLEET_EVENTS'		, 10);
define('MODULE_FLEET_TABLE'			, 9);
define('MODULE_FLEET_TRADER'		, 38);
define('MODULE_GALAXY'				, 11);
define('MODULE_IMPERIUM'			, 15);
define('MODULE_INFORMATION'			, 14);
define('MODULE_MESSAGES'			, 16);
define('MODULE_MISSILEATTACK'		, 40);
define('MODULE_MISSION_ATTACK'		, 1);
define('MODULE_MISSION_ACS'			, 42);
define('MODULE_MISSION_COLONY'		, 35);
define('MODULE_MISSION_DARKMATTER'	, 31);
define('MODULE_MISSION_DESTROY'		, 29);
define('MODULE_MISSION_EXPEDITION'	, 30);
define('MODULE_MISSION_HOLD'		, 33);
define('MODULE_MISSION_RECYCLE'		, 32);
define('MODULE_MISSION_SPY'			, 24);
define('MODULE_MISSION_STATION'		, 36);
define('MODULE_MISSION_TRANSPORT'	, 34);
define('MODULE_NOTICE'				, 17);
define('MODULE_OFFICIER'			, 18);
define('MODULE_PHALANX'				, 19);
define('MODULE_PLAYERCARD'			, 20);
define('MODULE_RECORDS'				, 22);
define('MODULE_RESEARCH'			, 3);
define('MODULE_RESSOURCE_LIST'		, 23);
define('MODULE_SEARCH'				, 26);
define('MODULE_SHIPYARD_FLEET'		, 4);
define('MODULE_SHIPYARD_DEFENSIVE'	, 5);
define('MODULE_SHORTCUTS'			, 41);
define('MODULE_SIMULATOR'			, 39);
define('MODULE_STATISTICS'			, 25);
define('MODULE_SUPPORT'				, 27);
define('MODULE_TECHTREE'			, 28);
define('MODULE_TRADER'				, 13);

// AstroIO - Modulos nuevos
define('MODULE_VIP'                 , 43);
define('MODULE_EVENTS'              , 44);
define('MODULE_MARKET'              , 45);
define('MODULE_WALLET'              , 46);
define('MODULE_REFERRAL'            , 47);
define('MODULE_BATTLEPASS'          , 48);
define('MODULE_BUGREPORT'           , 49);
define('MODULE_RAFFLES'             , 50);
define('MODULE_LOTTERY'             , 51);
define('MODULE_IMPROVEMENTS'        , 52);
define('MODULE_IMPROVEMENTS_SEASONS', 53);
define('MODULE_GIVEAWAY'            , 54);
define('MODULE_RACES'               , 55);
define('MODULE_FACTIONS'            , 56);
define('MODULE_CONTAINERS'          , 57);
define('MODULE_TASKS'               , 58);
define('MODULE_WAR'                 , 59);
define('MODULE_ALLIANCEBANK'        , 60);
define('MODULE_FLEETTOOLS'          , 61);
define('MODULE_RESOURCE_TRADER'     , 62);

// AstroIO - Sistema PvE (Crisis de Fin de Mes + Imperio Caído)
define('MODULE_PVE'                 , 63);

// AstroIO - Sistema de Asteroides (5 asteroides con recursos + cofres)
define('MODULE_ASTEROIDS'           , 64);

// AstroIO - Sistema PvP (Arenas 1v1/2v2/3v3 + Torneos 1v1/Alianza)
define('MODULE_PVP'                 , 65);

// AstroIO - Sistema Planetario (Droides + Lunas + Mejoras de Planeta)
define('MODULE_PLANET'              , 66);

// AstroIO - Sistema de Tienda NTX-20 (Ofertas fijas + Plantillas + Descuento VIP)
define('MODULE_SHOP'                , 67);

// AstroIO - Sistema de Boost de Fin de Semana (velocidades x2 los fines de semana)
define('MODULE_WEEKEND_BOOST'       , 68);

// AstroIO - Minijuego Topo (Golpea al Topo)
define('MODULE_MINIJUEGOTOPO'       , 69);

// AstroIO - Sistema de Mini Torneos (rotativos de 24h con premios automáticos)
define('MODULE_TOURNEY'             , 70);

// AstroIO - La Cueva Pirata (Minijuegos de casino - Hundir la Flota)
define('MODULE_CUEVA'               , 71);

// AstroIO - Minijuego Navidad (Memoria Navideña)
define('MODULE_MINIJUEGONAVIDAD'    , 72);

// AstroIO - Misiones PvE (flotas reales con tiempo de vuelo)
define('MISSION_PVE_CRISIS'           , 20);
define('MISSION_PVE_EMPIRE'           , 21);
define('MISSION_PVE_COUNTER'          , 22);
define('MISSION_PVE_BOSS_TOURNAMENT'  , 23);
define('MISSION_PVE_BASTION'          , 24);
define('MISSION_PIRATE_ATTACK'        , 25);

// FLEET STATE
define('FLEET_OUTWARD'				, 0);
define('FLEET_RETURN'				, 1);
define('FLEET_HOLD'					, 2);

// ELEMENT FLAGS
define('ELEMENT_BUILD'				, 1); # ID 0 - 99
define('ELEMENT_TECH'				, 2); # ID 101 - 199
define('ELEMENT_FLEET'				, 4); # ID 201 - 399
define('ELEMENT_DEFENSIVE'			, 8); # ID 401 - 599
define('ELEMENT_OFFICIER'			, 16); # ID 601 - 699
define('ELEMENT_BONUS'				, 32); # ID 701 - 799
define('ELEMENT_RACE'				, 64); # ID 801 - 899
define('ELEMENT_PLANET_RESOURCE'   , 128); # ID 901 - 949
define('ELEMENT_USER_RESOURCE'     , 256); # ID 951 - 999

// .. 512, 1024, 2048, 4096, 8192, 16384, 32768

define('ELEMENT_PRODUCTION'			, 65536);
define('ELEMENT_STORAGE'			, 131072);
define('ELEMENT_ONEPERPLANET'		, 262144);
define('ELEMENT_BOUNS'				, 524288);
define('ELEMENT_BUILD_ON_PLANET'	, 1048576);
define('ELEMENT_BUILD_ON_MOONS'		, 2097152);
define('ELEMENT_RESOURCE_ON_TF'		, 4194304);
define('ELEMENT_RESOURCE_ON_FLEET'	, 8388608);
define('ELEMENT_RESOURCE_ON_STEAL'	, 16777216);

// 🆕 ============================================================
// 🆕 NAVES NUEVAS v1.0 — IDs 225, 226, 227
// 🆕 Desbloqueo por Oficial Supervisor (niveles 1, 3, 5 — Opción B)
// 🆕 ============================================================

// IDs de las 3 naves nuevas
define('SHIP_ASSAULT_CORVETTE', 225);
define('SHIP_SIEGE_BATTLESHIP', 226);
define('SHIP_SUPER_CARGO',      227);

// Mapeo ID → columna SQL (para INSERT/SELECT dinámicos)
$GLOBALS['SHIP_COLUMN_MAP'] = array(
	SHIP_ASSAULT_CORVETTE => 'assault_corvette',
	SHIP_SIEGE_BATTLESHIP => 'siege_battleship',
	SHIP_SUPER_CARGO      => 'super_cargo',
);

// Requisito de Oficial Supervisor por nave (Opción B — Niveles 1, 3, 5)
// ✅ v3.3: el requisito se valida DESDE LA BD (uni1_vars_require:
//   227 → Supervisor nivel 1 (Súper Carguero)
//   225 → Supervisor nivel 3 (Corbeta de Asalto)
//   226 → Supervisor nivel 5 (Acorazado de Asedio)
// ) vía BuildFunctions::isTechnologieAccessible(), tanto al mostrar el
// astillero como al encolar. El array $GLOBALS['SHIP_SUPERVISOR_REQ']
// anterior era código muerto (nadie lo leía) y se eliminó.

// 🆕 ============================================================
// 🆕 FIN — Naves nuevas v1.0
// 🆕 ============================================================