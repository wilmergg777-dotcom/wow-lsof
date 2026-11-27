<?php

/**
 * XNOVA3D — API v1 (rama xnova3d)
 * -----------------------------------------------------------------------
 * Misma instalación, mismo servidor, MISMA base de datos que el juego
 * clásico (game.php). No reemplaza el proyecto: es una capa aparte para
 * que los clientes consuman el juego sin tocar el código clásico.
 *
 * Clientes:
 *   - Web clásica (game.php)     -> usa su sesión de siempre (cookie '2Moons')
 *   - Visor 3D web (game.php...) -> idem + AJAX mode=fetch
 *   - APK CLÁSICA / APK 3D       -> esta API con sesión PHP o token Bearer
 *
 * Autenticación (la MISMA sesión del juego, no un sistema aparte):
 *   - Cookie de sesión '2Moons' (web / WebView)
 *   - Authorization: Bearer <session_id>   (APK nativa)
 *   - ?token=<session_id>                  (APK nativa, alternativa)
 * El token lo devuelve r=login y es el session_id real del juego
 * (tabla uni1_session): lo que la APK haga con el token se ve en la
 * web clásica y viceversa porque es LA MISMA sesión y LA MISMA BD.
 *
 * Endpoints (todos devuelven JSON):
 *   GET  ?r=ping                                   estado de la API y sesión
 *   POST ?r=login    username, password            inicia sesión -> {token}
 *   POST ?r=logout                                 cierra sesión
 *   GET  ?r=galaxy    &galaxy=G&system=S           paquete completo del sistema
 *                (cobra deuterio igual que la vista clásica)
 *   GET  ?r=top                                    TOP 10 del universo + TÚ
 *   GET  ?r=me                                     perfil, planeta y naves
 *   GET  ?r=missions  &galaxy&system&planet        misiones permitidas en una posición
 *   GET  ?r=action    &mission=6&planetID=123      pasarela a fleetAjax (real)
 *                &mission=32&galaxy&system&planet (asteroide)
 */

define('ROOT_PATH', str_replace('\\', '/', dirname(__DIR__)) . '/');
set_include_path(ROOT_PATH);

// ============================================================
// Respuesta JSON central
// ============================================================
function api_res($arr, $code = null)
{
	if ($code !== null) {
		http_response_code($code);
	}
	header('Content-Type: application/json; charset=UTF-8');
	echo json_encode($arr);
	exit;
}

// ============================================================
// CORS (para clientes web externos; las APKs nativas no lo necesitan)
// ============================================================
$apiOrigin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '*';
header('Access-Control-Allow-Origin: ' . $apiOrigin);
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
	exit;
}

// ============================================================
// Token de la APK (Bearer / ?token=) o cookie de sesión del juego
// ============================================================
$apiToken = '';
if (!empty($_SERVER['HTTP_AUTHORIZATION']) && preg_match('/Bearer\s+(\S+)/i', $_SERVER['HTTP_AUTHORIZATION'], $apiM)) {
	$apiToken = $apiM[1];
}
if (empty($apiToken) && isset($_GET['token'])) {
	$apiToken = trim($_GET['token']);
}
if (empty($apiToken) && !empty($_COOKIE['2Moons'])) {
	$apiToken = $_COOKIE['2Moons'];
}

// endpoint pedido
$apiR = isset($_REQUEST['r']) ? preg_replace('/[^a-z_]/', '', strtolower($_REQUEST['r'])) : 'ping';

// ============================================================
// Pre-chequeo de sesión: lectura directa de uni1_session con PDO
// (sin cargar las clases del juego aún, para no chocar con los
// require de common.php). La validación completa (IP, inactividad)
// la hace Session::load() al arrancar el juego.
// ============================================================
$apiAuth = false;
if ($apiToken !== '') {
	try {
		$database = array();
		include ROOT_PATH . 'includes/config.php';
		$apiPdo = new PDO(
			"mysql:host=" . $database['host'] . ";port=" . $database['port'] . ";dbname=" . $database['databasename'] . ";charset=utf8mb4",
			$database['user'],
			$database['userpw'],
			array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
		);
		$apiSt = $apiPdo->prepare('SELECT userID FROM uni1_session WHERE sessionID = :t LIMIT 1');
		$apiSt->execute(array(':t' => $apiToken));
		$apiRow = $apiSt->fetch(PDO::FETCH_ASSOC);
		$apiPdo = null;
		if (!empty($apiRow) && !empty($apiRow['userID'])) {
			$apiAuth = true;
		}
	} catch (Exception $apiE) {
		// si la BD aún no responde, seguimos y common.php decidirá
	}
}

// el token manda sobre la cookie: lo mapeamos a la sesión de PHP
if ($apiAuth && !empty($apiToken)) {
	$_COOKIE['2Moons'] = $apiToken;
}

// ============================================================
// Modo de arranque: LOGIN para ping/login, INGAME para el resto
// ============================================================
if ($apiR === 'ping' || $apiR === 'login') {
	define('MODE', 'LOGIN');
} else {
	define('MODE', 'INGAME');
	if (!$apiAuth) {
		api_res(array(
			'ok'   => false,
			'err'  => 'no_auth',
			'mess' => 'Sesion no iniciada. Usa r=login para obtener el token.',
		), 401);
	}
}

// ============================================================
// Bootstrap del juego (idéntico a game.php)
// ============================================================
require ROOT_PATH . 'includes/pages/game/AbstractGamePage.class.php';
require ROOT_PATH . 'includes/pages/game/ShowErrorPage.class.php';
require ROOT_PATH . 'includes/common.php';
require ROOT_PATH . 'includes/classes/Galaxy3dService.class.php';

// ============================================================
// Endpoints
// ============================================================
try {

	switch ($apiR) {

		case 'ping': {
			$apiPingUser = 0;
			if ($apiAuth) {
				try {
					$database = array();
					include ROOT_PATH . 'includes/config.php';
					$apiPdo = new PDO(
						"mysql:host=" . $database['host'] . ";port=" . $database['port'] . ";dbname=" . $database['databasename'] . ";charset=utf8mb4",
						$database['user'],
						$database['userpw'],
						array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
					);
					$apiSt = $apiPdo->prepare('SELECT userID FROM uni1_session WHERE sessionID = :t LIMIT 1');
					$apiSt->execute(array(':t' => $apiToken));
					$apiRow = $apiSt->fetch(PDO::FETCH_ASSOC);
					$apiPdo = null;
					if (!empty($apiRow)) {
						$apiPingUser = (int)$apiRow['userID'];
					}
				} catch (Exception $apiE) {
				}
			}
			api_res(array(
				'ok'      => true,
				'api'     => 'XNOVA3D',
				'version' => 1,
				'auth'    => $apiAuth,
				'userId'  => $apiPingUser,
				'time'    => TIMESTAMP,
			));
		}

		case 'login': {
			// Validación idéntica a ShowLoginPage (mismo hash, mismo fallback)
			$username = HTTP::_GP('username', '', UTF8_SUPPORT);
			$password = HTTP::_GP('password', '', true);

			$sql = "SELECT id, password, authlevel FROM %%USERS%% WHERE universe = :universe AND username = :username;";
			$loginData = Database::get()->selectSingle($sql, array(
				':universe' => Universe::current(),
				':username' => $username
			));

			if (empty($loginData)) {
				api_res(array('ok' => false, 'err' => 'login', 'mess' => 'Usuario o clave incorrectos.'), 401);
			}

			$hashedPassword = PlayerUtil::cryptPassword($password);
			if ($loginData['password'] != $hashedPassword) {
				// Fallback pre 1.7 (igual que el juego): md5 -> actualiza el hash
				if ($loginData['password'] == md5($password)) {
					Database::get()->update("UPDATE %%USERS%% SET password = :hashedPassword WHERE id = :loginID;", array(
						':hashedPassword' => $hashedPassword,
						':loginID'        => $loginData['id']
					));
				} else {
					api_res(array('ok' => false, 'err' => 'login', 'mess' => 'Usuario o clave incorrectos.'), 401);
				}
			}

			$configLogin = Config::get();
			if ($configLogin->game_disable == 1 && $loginData['authlevel'] == AUTH_USR) {
				api_res(array('ok' => false, 'err' => 'closed', 'mess' => $configLogin->close_reason), 403);
			}

			// Crear la sesión REAL del juego (misma tabla, mismas reglas)
			$sessionLogin = Session::create();
			$sessionLogin->userId      = (int)$loginData['id'];
			$sessionLogin->adminAccess = 0;
			$sessionLogin->save();

			api_res(array(
				'ok'     => true,
				'token'  => session_id(),
				'user'   => array(
					'id'       => (int)$loginData['id'],
					'username' => $username,
					'universe' => Universe::current(),
				),
				'mess'   => 'Sesion iniciada. Envía Authorization: Bearer <token> en cada petición.',
			));
		}

		case 'logout':
			Session::load()->delete();
			api_res(array('ok' => true, 'mess' => 'Sesion cerrada.'));

		case 'galaxy': {
			$configApi = Config::get();

			$galaxy = min(max(HTTP::_GP('galaxy', (int)$PLANET['galaxy']), 1), $configApi->max_galaxy);
			$system = min(max(HTTP::_GP('system', (int)$PLANET['system']), 1), $configApi->max_system);

			// Regla idéntica a ShowGalaxyPage::show()/fetch(): mirar otro
			// sistema cuesta deuterio y se descuenta en la MISMA BD.
			if ($galaxy != $PLANET['galaxy'] || $system != $PLANET['system']) {
				if ($PLANET['deuterium'] < $configApi->deuterium_cost_galaxy) {
					api_res(array(
						'ok'  => false,
						'err' => 'no_deuterium',
						'mess' => $LNG['gl_no_deuterium_to_view_galaxy'],
					), 402);
				}
				$PLANET['deuterium'] -= $configApi->deuterium_cost_galaxy;
				// la API no tiene ecoObj: persistimos el descuento explícitamente
				Database::get()->update('UPDATE %%PLANETS%% SET deuterium = deuterium - :cost WHERE id = :pid;', array(
					':cost' => $configApi->deuterium_cost_galaxy,
					':pid'  => $PLANET['id'],
				));
			}

			api_res(Galaxy3dService::datosCompletos($galaxy, $system));
		}

		case 'top':
			api_res(array_merge(
				array('ok' => true, 'galaxy' => (int)$PLANET['galaxy'], 'system' => (int)$PLANET['system']),
				Galaxy3dService::getTop()
			));

		case 'me': {
			global $resource;
			$outMe = array_merge(array('ok' => true), Galaxy3dService::getMe());
			$outMe['username'] = (string)$USER['username'];
			$outMe['planet']   = array(
				'id'   => (int)$PLANET['id'],
				'name' => (string)$PLANET['name'],
				'g'    => (int)$PLANET['galaxy'],
				's'    => (int)$PLANET['system'],
				'p'    => (int)$PLANET['planet'],
				'type' => (int)$PLANET['planet_type'],
			);
			$outMe['fleets']  = (int)FleetFunctions::GetCurrentFleets($USER['id']);
			$outMe['fleetmax'] = (int)FleetFunctions::GetMaxFleetSlots($USER);
			$outMe['ships']   = array(
				'spyprobes'  => (int)$PLANET[$resource[210]],
				'recyclers'  => (int)$PLANET[$resource[209]],
				'grecyclers' => (int)$PLANET[$resource[219]],
				'mip'        => (int)$PLANET[$resource[503]],
			);
			api_res($outMe);
		}

		case 'missions': {
			$configMis = Config::get();
			$galaxy = min(max(HTTP::_GP('galaxy', (int)$PLANET['galaxy']), 1), $configMis->max_galaxy);
			$system = min(max(HTTP::_GP('system', (int)$PLANET['system']), 1), $configMis->max_system);
			$planet = min(max(HTTP::_GP('planet', 1), 1), $configMis->max_planets + 1);
			api_res(Galaxy3dService::getAccion($galaxy, $system, $planet));
		}

		case 'action': {
			// Pasarela REAL al fleetAjax del juego (espionaje 6, escombros 8,
			// asteroide 32, etc.). Mismo handler que usan la tabla clásica y
			// el visor 3D: el resultado se ve en todos los clientes.
			if (empty($_GET['ajax'])) {
				$_GET['ajax'] = 1;
			}
			require_once ROOT_PATH . 'includes/pages/game/ShowFleetAjaxPage.class.php';
			$fleetAjaxPage = new ShowFleetAjaxPage();
			$fleetAjaxPage->show(); // responde JSON y termina (sendJSON)
			exit;
		}

		default:
			api_res(array('ok' => false, 'err' => 'bad_request', 'mess' => 'Endpoint desconocido: r=' . $apiR), 400);
	}

} catch (Exception $apiEx) {
	api_res(array('ok' => false, 'err' => 'exception', 'mess' => $apiEx->getMessage()), 500);
}
