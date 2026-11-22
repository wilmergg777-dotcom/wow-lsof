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
 * MODIFICADO PARA ASTROIO - Login con Discord
 * 
 * ✅ FIX: isValidSession() ahora usa $this->data['sessionId'] si existe
 *         (para login externo con Discord), en lugar de session_id() de PHP.
 *
 * ✅ FIX v2.6: getClientIp() ahora usa SIEMPRE REMOTE_ADDR (IP real),
 *              ignorando X-Forwarded-For y headers de proxy que pueden
 *              cambiar entre peticiones (causa de "Sesión expirada" con
 *              ETECSA/IPv4-IPv6 alternante). También convierte IPv6
 *              mapeada (::ffff:x.x.x.x) a IPv4 limpia.
 */

class Session
{
	static private $obj = NULL;
	static private $iniSet	= false;
	private $data = NULL;

	static public function init()
	{
		if(self::$iniSet === true) {
			return false;
		}
		self::$iniSet = true;

		ini_set('session.use_cookies', '1');
		ini_set('session.use_only_cookies', '1');
		ini_set('session.use_trans_sid', 0);
		ini_set('session.auto_start', '0');
		ini_set('session.serialize_handler', 'php');
		ini_set('session.gc_maxlifetime', SESSION_LIFETIME);
		ini_set('session.gc_probability', '1');
		ini_set('session.gc_divisor', '1000');
		ini_set('session.bug_compat_warn', '0');
		ini_set('session.bug_compat_42', '0');
		ini_set('session.cookie_httponly', true);
		ini_set('session.save_path', CACHE_PATH.'sessions');
		ini_set('upload_tmp_dir', CACHE_PATH.'sessions');

		$HTTP_ROOT = MODE === 'INSTALL' ? dirname(HTTP_ROOT) : HTTP_ROOT;

		session_set_cookie_params(SESSION_LIFETIME, $HTTP_ROOT, NULL, HTTPS, true);
		session_cache_limiter('nocache');
		session_name('2Moons');

		return true;
	}

	static private function getTempPath()
	{
		require_once 'includes/libs/wcf/BasicFileUtil.class.php';
		return BasicFileUtil::getTempFolder();
	}

	static public function getClientIp()
	{
		// ✅ FIX AstroIO: usar SIEMPRE REMOTE_ADDR (la IP real de la conexión)
		// Evita que X-Forwarded-For cambie entre peticiones (proxies, CDN, etc.)
		$ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'UNKNOWN';

		// Si viene como IPv6 mapeada (::ffff:190.15.20.30), convertir a IPv4
		if (strpos($ipAddress, '::ffff:') === 0) {
			$ipAddress = substr($ipAddress, 7);
		}

		return $ipAddress;
	}

	static public function create()
	{
		if(!self::existsActiveSession()) {
			self::$obj	= new self;
			register_shutdown_function(array(self::$obj, 'save'));
			@session_start();
		}
		return self::$obj;
	}

	static public function load()
	{
		if(!self::existsActiveSession())
		{
			// ═══════════════════════════════════════════════════════
			// LOGIN EXTERNO (Discord, etc.)
			// Lee la sesión DIRECTAMENTE de la BD usando 'astroio_login'
			// ═══════════════════════════════════════════════════════
			$token = !empty($_COOKIE['astroio_login']) ? $_COOKIE['astroio_login'] : null;

			if (!empty($token)) {
				$db = Database::get();
				$row = $db->selectSingle(
					"SELECT userID, userIP FROM uni1_session WHERE sessionID = :t LIMIT 1;",
					array(':t' => $token)
				);

				if (!empty($row) && !empty($row['userID'])) {
					self::init();

					self::$obj = new self;
					self::$obj->userId        = (int) $row['userID'];
					self::$obj->adminAccess   = 0;
					self::$obj->universe      = Universe::current();
					self::$obj->lastActivity  = TIMESTAMP;
					self::$obj->userIpAddress = $row['userIP'];
					self::$obj->sessionId     = $token;

					register_shutdown_function(array(self::$obj, 'refreshOnline'));

					return self::$obj;
				}
			}

			// ═══════════════════════════════════════════════════════
			// LOGIN CLÁSICO (usuario/contraseña)
			// ═══════════════════════════════════════════════════════
			self::init();
			@session_start();

			if(isset($_SESSION['obj'])) {
				self::$obj	= unserialize($_SESSION['obj']);
				register_shutdown_function(array(self::$obj, 'save'));
			} else {
				self::create();
			}
		}

		return self::$obj;
	}

	static public function existsActiveSession()
	{
		return isset(self::$obj);
	}

	public function __construct()
	{
		self::init();
	}

	public function __sleep()
	{
		return array('data');
	}

	public function __wakeup()
	{
	}

	public function __set($name, $value)
	{
		if(!is_array($this->data)) {
			$this->data = array();
		}
		$this->data[$name]	= $value;
	}

	public function __get($name)
	{
		if(isset($this->data[$name])) {
			return $this->data[$name];
		}
		return NULL;
	}

	public function __isset($name)
	{
		return isset($this->data[$name]);
	}

	public function save()
	{
		$sessionId = session_id();
		if(empty($sessionId)) {
			return;
		}

		if(empty($this->data) || empty($this->data['userId'])) {
			$this->delete();
			return;
		}

		$userIpAddress = self::getClientIp();

		$sql	= 'REPLACE INTO %%SESSION%% SET
		sessionID	= :sessionId,
		userID		= :userId,
		lastonline	= :lastActivity,
		userIP		= :userAddress;';

		$db		= Database::get();

		$db->replace($sql, array(
			':sessionId'	=> session_id(),
			':userId'		=> $this->data['userId'],
			':lastActivity'	=> TIMESTAMP,
			':userAddress'	=> $userIpAddress,
		));

		$sql = 'UPDATE %%USERS%% SET
		onlinetime	= :lastActivity,
		user_lastip = :userAddress
		WHERE id = :userId;';

		$db->update($sql, array(
		   ':userAddress'	=> $userIpAddress,
		   ':lastActivity'	=> TIMESTAMP,
		   ':userId'		=> $this->data['userId'],
		));

		$this->data['lastActivity']  = TIMESTAMP;
		$this->data['sessionId']	 = session_id();
		$this->data['userIpAddress'] = $userIpAddress;
		$this->data['requestPath']	 = $this->getRequestPath();

		$_SESSION['obj']	= serialize($this);

		@session_write_close();
	}

	/**
	 * Refrescar online sin tocar archivos de sesión (para login externo)
	 */
	public function refreshOnline()
	{
		if(empty($this->data['userId'])) {
			return;
		}

		$sessionId = isset($this->data['sessionId']) ? $this->data['sessionId'] : null;
		if(empty($sessionId)) {
			return;
		}

		$userIpAddress = self::getClientIp();

		$db = Database::get();

		$db->replace('REPLACE INTO %%SESSION%% SET
			sessionID	= :sessionId,
			userID		= :userId,
			lastonline	= :lastActivity,
			userIP		= :userAddress;',
			array(
				':sessionId'	=> $sessionId,
				':userId'		=> $this->data['userId'],
				':lastActivity'	=> TIMESTAMP,
				':userAddress'	=> $userIpAddress,
			)
		);

		$db->update('UPDATE %%USERS%% SET
			onlinetime	= :lastActivity,
			user_lastip = :userAddress
			WHERE id = :userId;',
			array(
				':userAddress'	=> $userIpAddress,
				':lastActivity'	=> TIMESTAMP,
				':userId'		=> $this->data['userId'],
			)
		);
	}

	public function delete()
	{
		// No borrar la fila si el usuario entró con Discord
		if (!empty($_COOKIE['astroio_login'])) {
			@session_destroy();
			return;
		}

		$sql	= 'DELETE FROM %%SESSION%% WHERE sessionID = :sessionId;';
		$db		= Database::get();

		$db->delete($sql, array(
			':sessionId'	=> session_id(),
		));

		@session_destroy();
	}

	public function isValidSession()
	{
		// PHP 8.2: proteger acceso a $this->data si es null
		if(empty($this->data)) {
			return false;
		}

		if(!isset($this->data['userIpAddress']) || !isset($this->data['lastActivity'])) {
			return false;
		}

		// Validación de IP (RE-ACTIVADA, optimización InfinityFree eliminada)
		if($this->compareIpAddress($this->data['userIpAddress'], self::getClientIp(), COMPARE_IP_BLOCKS) === false)
		{
			return false;
		}

		// Validación por tiempo de inactividad
		if($this->data['lastActivity'] < TIMESTAMP - SESSION_LIFETIME)
		{
			return false;
		}

		// ═══════════════════════════════════════════════════════
		// ✅ FIX AstroIO: usar $this->data['sessionId'] si existe
		// (para login externo con Discord). Si no, usar session_id().
		// ═══════════════════════════════════════════════════════
		$sessionId = !empty($this->data['sessionId']) 
			? $this->data['sessionId'] 
			: session_id();

		// Validación por existencia en BD
		$sql = 'SELECT COUNT(*) as record FROM %%SESSION%% WHERE sessionID = :sessionId;';
		$db		= Database::get();

		$sessionCount = $db->selectSingle($sql, array(
			':sessionId'	=> $sessionId,
		), 'record');

		if($sessionCount == 0)
		{
			return false;
		}

		return true;
	}

	public function selectActivePlanet()
	{
		$httpData	= HTTP::_GP('cp', 0);

		if(!empty($httpData))
		{
			$sql	= 'SELECT id FROM %%PLANETS%% WHERE id = :planetId AND id_owner = :userId;';

			$db	= Database::get();
			$planetId	= $db->selectSingle($sql, array(
				':userId'	=> $this->data['userId'],
				':planetId'	=> $httpData,
			), 'id');

			if(!empty($planetId))
			{
				$this->data['planetId']	= $planetId;
			}
		}
	}

	private function getRequestPath()
	{
		return HTTP_ROOT.(!empty($_SERVER['QUERY_STRING']) ? '?'.$_SERVER['QUERY_STRING'] : '');
	}

	private function compareIpAddress($ip1, $ip2, $blockCount)
	{
		if (strpos($ip2, ':') !== false && strpos($ip1, ':') !== false) {
			$s_ip = $this->short_ipv6($ip1, $blockCount);
			$u_ip = $this->short_ipv6($ip2, $blockCount);
		} else {
			$s_ip = implode('.', array_slice(explode('.', $ip1), 0, $blockCount));
			$u_ip = implode('.', array_slice(explode('.', $ip2), 0, $blockCount));
		}
		return ($s_ip == $u_ip);
	}

	private function short_ipv6($ip, $length)
	{
		if ($length < 1) {
			return '';
		}

		$blocks = substr_count($ip, ':') + 1;
		if ($blocks < 9) {
			$ip = str_replace('::', ':' . str_repeat('0000:', 9 - $blocks), $ip);
		}
		if ($ip[0] == ':') {
			$ip = '0000' . $ip;
		}
		if ($length < 4) {
			$ip = implode(':', array_slice(explode(':', $ip), 0, 1 + $length));
		}

		return $ip;
	}
}