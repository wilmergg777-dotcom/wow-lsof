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
 *
 * ✅ FIX AstroIO v2.4:
 *   - Línea 159: game_disable == 0 → game_disable == 1 (lógica invertida)
 *     Antes bloqueaba el juego cuando estaba ABIERTO y lo dejaba pasar cuando estaba CERRADO.
 *   - Bloque de servidor cerrado: ahora redirige al login con sesión destruida
 *     en vez de llamar a ShowErrorPage::printError() (que crasheaba con
 *     "Trying to access array offset on value of type null").
 *     El mensaje de cierre se muestra desde ShowLoginPage.
 *
 * ✅ FIX AstroIO v2.5:
 *   - Soporte para CRON externo (cron-job.org) sin sesión de usuario.
 *     Antes, cuando MODE === 'CRON' y no había cookie de sesión, se hacía
 *     HTTP::redirectTo('index.php?code=3') y el cron externo fallaba con 302.
 *     Ahora, si MODE === 'CRON' y no hay sesión, se carga el primer admin
 *     (AUTH_ADM) como usuario de sistema para poder ejecutar los cronjobs.
 *     El cron interno (cronjob.php) sigue funcionando igual porque siempre
 *     tiene sesión válida de un jugador logueado.
 *
 * ✅ FIX AstroIO v2.6:
 *   - Carga global de EventHelper al final del archivo.
 *     Antes, class.PlanetRessUpdate.php llamaba a class_exists('EventHelper')
 *     sin garantizar que la clase estuviera cargada → los hooks de
 *     get_resources, build_ships y research_techs fallaban silenciosamente.
 *     Ahora EventHelper se carga siempre en modo INGAME/ADMIN/CRON.
 *
 * ✅ FIX AstroIO v2.7 (este archivo):
 *   - Soporte CLI completo para el cron externo por crontab SSH.
 *     El problema: en CLI, cuando MODE === 'CRON' y algo falla en la
 *     comprobación de versión de BD (por ejemplo, DB_VERSION_REQUIRED
 *     no está definida), se ejecutaba HTTP::redirectTo() silenciosamente
 *     y el cron moría sin imprimir nada → cron_ssh.log vacío.
 *     Solución:
 *       1. catch (Exception) → catch (Throwable) para atrapar también
 *          los Error de PHP (Undefined constant, etc.).
 *       2. Los redirectTo() de install/index.php ahora se saltan en CLI
 *          e imprimen un mensaje de error claro por consola.
 *     Con esto, el crontab SSH ya no muere silenciosamente.
 */

if (isset($_POST['GLOBALS']) || isset($_GET['GLOBALS'])) {
	exit('You cannot set the GLOBALS-array from outside the script.');
}

$composerAutoloader = __DIR__.'/../vendor/autoload.php';

if (file_exists($composerAutoloader)) {
    require $composerAutoloader;
}

if (function_exists('mb_internal_encoding')) {
	mb_internal_encoding("UTF-8");
}

ignore_user_abort(true);
error_reporting(E_ALL & ~E_STRICT);

// If date.timezone is invalid
date_default_timezone_set(@date_default_timezone_get());

ini_set('display_errors', 1);
header('Content-Type: text/html; charset=UTF-8');
define('TIMESTAMP',	time());
	
require 'includes/constants.php';

ini_set('log_errors', 'On');
ini_set('error_log', __DIR__ . '/../cache/astroio_error.log');

require 'includes/GeneralFunctions.php';
set_exception_handler('exceptionHandler');
set_error_handler('errorHandler');

require 'includes/classes/ArrayUtil.class.php';
require 'includes/classes/Cache.class.php';
require 'includes/classes/Database.class.php';
require 'includes/classes/Config.class.php';
require 'includes/classes/class.FleetFunctions.php';
require 'includes/classes/class.BoosterHelper.php';
require 'includes/classes/class.RaceFactionHelper.php';
require 'includes/classes/HTTP.class.php';

require 'includes/classes/Language.class.php';

require 'includes/classes/PlayerUtil.class.php';
require 'includes/classes/Session.class.php';
require 'includes/classes/Universe.class.php';

require 'includes/classes/class.theme.php';
require 'includes/classes/class.template.php';

// Say Browsers to Allow ThirdParty Cookies (Thanks to morktadela)
HTTP::sendHeader('P3P', 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"');
define('AJAX_REQUEST', HTTP::_GP('ajax', 0));

$THEME		= new Theme();

if (MODE === 'INSTALL')
{
	return;
}

// ═══════════════════════════════════════════════════════════════
// ✅ FIX AstroIO v2.7: verificación de config.php con soporte CLI
// ═══════════════════════════════════════════════════════════════
// En CLI no tiene sentido hacer un redirect HTTP (no hay navegador).
// Si falta config.php, imprimimos un error claro por consola.
// ═══════════════════════════════════════════════════════════════
if(!file_exists('includes/config.php') || filesize('includes/config.php') === 0) {
	if (PHP_SAPI === 'cli') {
		exit('CRON ERROR: includes/config.php no existe o está vacío.' . PHP_EOL);
	}
	HTTP::redirectTo('install/index.php');
}

// ═══════════════════════════════════════════════════════════════
// ✅ FIX AstroIO v2.7: catch Throwable + soporte CLI en upgrade
// ═══════════════════════════════════════════════════════════════
// Antes:
//   - catch (Exception $e) → NO capturaba los "Error" de PHP 7/8
//     (como "Undefined constant DB_VERSION_REQUIRED") → el error
//     subía al exceptionHandler → exit silencioso en CLI.
//   - Si $dbNeedsUpgrade = true → HTTP::redirectTo() silencioso.
//
// Ahora:
//   - catch (Throwable $e) → captura TODO (Exception + Error).
//   - En CLI, en vez de redirect, imprimimos el error por consola.
// ═══════════════════════════════════════════════════════════════
$dbVersion = null;

try {
    $sql	= "SELECT dbVersion FROM %%SYSTEM%%;";

    $dbVersion	= Database::get()->selectSingle($sql, array(), 'dbVersion');

    $dbNeedsUpgrade = $dbVersion < DB_VERSION_REQUIRED;
} catch (Throwable $e) {
    $dbNeedsUpgrade = true;
    $dbVersionError = $e->getMessage();
}

if ($dbNeedsUpgrade) {
	if (PHP_SAPI === 'cli') {
		exit(
			'CRON ERROR: dbNeedsUpgrade=true' . PHP_EOL .
			'  dbVersion=' . var_export($dbVersion, true) . PHP_EOL .
			'  DB_VERSION_REQUIRED=' . (defined('DB_VERSION_REQUIRED') ? DB_VERSION_REQUIRED : 'NO DEFINIDA') . PHP_EOL .
			'  Error: ' . (isset($dbVersionError) ? $dbVersionError : 'sin mensaje') . PHP_EOL
		);
	}
    HTTP::redirectTo('install/index.php?mode=upgrade');
}

if(defined('DATABASE_VERSION') && DATABASE_VERSION === 'OLD')
{
	/* For our old Admin panel */
	require 'includes/classes/Database_BC.class.php';
	$DATABASE	= new Database_BC();
	
	$dbTableNames	= Database::get()->getDbTableNames();
	$dbTableNames	= array_combine($dbTableNames['keys'], $dbTableNames['names']);
	
	foreach($dbTableNames as $dbAlias => $dbName)
	{
		define(substr($dbAlias, 2, -2), $dbName);
	}	
}

$config = Config::get();
date_default_timezone_set($config->timezone);

if (MODE === 'INGAME' || MODE === 'ADMIN' || MODE === 'CRON')
{
	$session	= Session::load();

	// ═══════════════════════════════════════════════════════════
	// ✅ FIX AstroIO v2.5: soporte para CRON externo (cron-job.org)
	// Cuando MODE === 'CRON' y NO hay sesión (porque cron-job.org
	// no envía cookies), cargamos el primer administrador como
	// usuario de sistema para que los cronjobs puedan ejecutarse.
	// El cron interno (cronjob.php) siempre tendrá sesión válida,
	// así que este bloque no le afecta en absoluto.
	// ═══════════════════════════════════════════════════════════
	$cronSystemUserId = null;

	if(!$session->isValidSession())
	{
		if (MODE === 'CRON')
		{
			$dbTmp = Database::get();
			$cronAdmin = $dbTmp->selectSingle(
				"SELECT id FROM %%USERS%% WHERE authlevel = :auth ORDER BY id ASC LIMIT 1;",
				array(':auth' => AUTH_ADM)
			);

			if (empty($cronAdmin))
			{
				exit('CRON ERROR: no admin user found for system cron.');
			}

			$cronSystemUserId = (int) $cronAdmin['id'];
		}
		else
		{
			$session->delete();
			HTTP::redirectTo('index.php?code=3');
		}
	}

	require 'includes/vars.php';
	require 'includes/classes/class.BuildFunctions.php';
	require 'includes/classes/class.PlanetRessUpdate.php';
	
	if(!AJAX_REQUEST && MODE === 'INGAME' && isModuleAvailable(MODULE_FLEET_EVENTS)) {
		require('includes/FleetHandler.php');
	}
	
	$db		= Database::get();

	// Si estamos en cron externo sin sesión, usamos el ID del admin de sistema
	$effectiveUserId = $cronSystemUserId ? $cronSystemUserId : $session->userId;

	$sql	= "SELECT 
	user.*,
	COUNT(message.message_id) as messages
	FROM %%USERS%% as user
	LEFT JOIN %%MESSAGES%% as message ON message.message_owner = user.id AND message.message_unread = :unread
	WHERE user.id = :userId
	GROUP BY message.message_owner;";
	
	$USER	= $db->selectSingle($sql, array(
		':unread'	=> 1,
		':userId'	=> $effectiveUserId
	));
	
	if(empty($USER))
	{
		if (MODE === 'CRON')
		{
			exit('CRON ERROR: admin user not found in USERS table.');
		}
		HTTP::redirectTo('index.php?code=3');
	}
	
	$LNG	= new Language('es');   // ← CAMBIO: Forzado a español
	$LNG->includeData(array('L18N', 'INGAME', 'TECH', 'CUSTOM'));
	$THEME->setUserTheme($USER['dpath']);
	
	// ✅ FIX v2.4: Si el servidor está cerrado y el usuario es jugador normal,
	// destruimos su sesión y lo mandamos al login.
	// El mensaje de cierre se muestra desde ShowLoginPage, donde el motivo
	// (close_reason) se ve limpio, sin errores de PHP.
	// ⚠️ NO se usa ShowErrorPage::printError() aquí porque crashea con
	// "Trying to access array offset on value of type null" al no estar
	// $PLANET ni $USER['PLANETS'] cargados todavía.
	// ⚠️ En modo CRON (sistema) NO aplicamos esta restricción, porque si no
	// el cron externo se bloquearía cuando el juego esté cerrado por mantenimiento.
	if($config->game_disable == 1 && $USER['authlevel'] == AUTH_USR && MODE !== 'CRON') {
		$session->delete();
		HTTP::redirectTo('index.php');
	}

	if($USER['bana'] == 1 && MODE !== 'CRON') {
		ShowErrorPage::printError("<font size=\"6px\">".$LNG['css_account_banned_message']."</font><br><br>".sprintf($LNG['css_account_banned_expire'], _date($LNG['php_tdformat'], $USER['banaday'], $USER['timezone']))."<br><br>".$LNG['css_goto_homeside'], false);
	}
	
	if (MODE === 'INGAME')
	{
		$universeAmount	= count(Universe::availableUniverses());
		if(Universe::current() != $USER['universe'] && $universeAmount > 1)
		{
			HTTP::redirectToUniverse($USER['universe']);
		}

		$session->selectActivePlanet();

		$sql	= "SELECT * FROM %%PLANETS%% WHERE id = :planetId;";
		$PLANET	= $db->selectSingle($sql, array(
			':planetId'	=> $session->planetId,
		));

		if(empty($PLANET))
		{
			$sql	= "SELECT * FROM %%PLANETS%% WHERE id = :planetId;";
			$PLANET	= $db->selectSingle($sql, array(
				':planetId'	=> $USER['id_planet'],
			));
			
			if(empty($PLANET))
			{
				throw new Exception("Main Planet does not exist!");
			}
			else
			{
				$session->planetId = $USER['id_planet'];
			}
		}
		
		$USER['factor']		= getFactors($USER);
		$USER['PLANETS']	= getPlanets($USER);
	}
	elseif (MODE === 'ADMIN')
	{
		error_reporting(E_ERROR | E_WARNING | E_PARSE);
		
		$USER['rights']		= unserialize($USER['rights']);
		$LNG->includeData(array('ADMIN', 'CUSTOM'));
	}
}
elseif(MODE === 'LOGIN')
{
	$LNG	= new Language('es');   // ← CAMBIO: Forzado a español
	$LNG->getUserAgentLanguage();
	$LNG->includeData(array('L18N', 'INGAME', 'PUBLIC', 'CUSTOM'));
}
elseif(MODE === 'CHAT')
{
	$session	= Session::load();

	if(!$session->isValidSession())
	{
		HTTP::redirectTo('index.php?code=3');
	}
}

// ============================================
// ✅ FIX AstroIO v2.6
// ASTROIO - Cargar EventHelper globalmente
// ------------------------------------------------------------
// Garantiza que class_exists('EventHelper') funcione en
// TODOS los hooks (get_resources, build_ships, research_techs,
// destroy_units, recycle_debris, expeditions) sin necesidad
// de require_once en cada archivo que lo usa.
//
// Antes:
//   - class.PlanetRessUpdate.php usaba class_exists('EventHelper')
//     sin garantizar que la clase estuviera cargada → los hooks
//     de recursos/naves/investigación fallaban silenciosamente.
//
// Ahora:
//   - EventHelper se carga SIEMPRE que el juego esté en modo
//     INGAME, ADMIN o CRON.
//   - Si la clase ya está cargada, no se vuelve a cargar.
//   - Si el archivo no existe, no rompe nada (falla silenciosa).
// ============================================
if (MODE === 'INGAME' || MODE === 'ADMIN' || MODE === 'CRON')
{
	if (!class_exists('EventHelper'))
	{
		if (defined('ROOT_PATH'))
		{
			$__astroEvFile = ROOT_PATH . 'includes/classes/EventHelper.class.php';
		}
		else
		{
			$__astroEvFile = dirname(__FILE__) . '/classes/EventHelper.class.php';
		}

		if (file_exists($__astroEvFile))
		{
			require_once $__astroEvFile;
		}
	}
}
// ============================================
// FIN FIX AstroIO v2.6
// ============================================