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
 *   - isset → !isset en $USER['PLANETS'] (evita warning "Undefined array key PLANETS")
 *   - Blindaje is_array en $USER['PLANETS']
 *   - Corregida lógica invertida en 'closed'
 *   - Early return en getNavigationData() cuando no hay $USER o $PLANET cargados
 *   - Blindaje de getPageData() y display() contra $USER nulo
 *
 * ✅ FIX AstroIO v2.5 (Sistema PvE):
 *   - Inyección de $pve (PVEHelper::getMopData()) para el botón PvE + countdown
 *
 * ✅ FIX AstroIO v2.6 (Sistema PvP):
 *   - Inyección de $pvp (arenas + torneos) para el botón PvP + countdown
 *
 * ✅ FIX AstroIO v2.8.2:
 *   - Contador "Últimas 24h" ahora incluye a TODOS (admins + superadmins)
 *     Se quitó el filtro "authlevel < 3" de onlineCount y totalCount
 *
 * ✅ FIX AstroIO v1.0 (Sistema de Asteroides):
 *   - Cron GLOBAL de asteroides: se ejecuta en CUALQUIER página del juego
 *     (no depende de que el usuario entre a Overview)
 *     - Cada 5 minutos
 *     - Bypass manual via ?force_ast_cron=1
 *
 * ✅ FIX AstroIO v1.2 (Alertas globales de flotas):
 *   - Detección global de flotas entrantes (Ataque/Espionaje/Transporte)
 *     disponible en TODAS las páginas del juego
 *   - Variable $globalAlerts pasada al template
 *   - Se usa en main.navigation.tpl (sidebar izquierdo)
 *
 * ✅ FIX AstroIO v1.3 (Torneo del Devorador en el MOP):
 *   - Detección del Torneo del Devorador en el botón "Eventos PvE"
 *   - Nuevos campos en $pve:
 *       boss_active, boss_status, boss_next_time, boss_end_time
 *   - Nuevo campo combinado 'any_active' (Crisis OR Imperio OR Torneo)
 *   - Nuevo campo 'next_time' (mínimo no-cero entre crisis/empire/boss)
 *   - Helper privado astroio_getBossMopData() para consultar el torneo
 *   - Helper privado astroio_mergePveData() para fusionar y combinar
 *   - Se aplica también en el early-return (evita warnings)
 *
 * ✅ FIX AstroIO v1.4 (Contador 24h sin fantasmas PvE/PvP):
 *   - El contador "Últimas 24h: X/Y" ya NO cuenta a los fantasmas.
 *   - Los fantasmas tienen email terminado en "@noreply.local".
 *   - Filtro aplicado: email NOT LIKE '%@noreply.local'
 *   - Ahora muestra solo jugadores reales, sin importar su ID.
 *
 * ✅ FIX AstroIO v1.5 (Boost de Fin de Semana):
 *   - Cron GLOBAL del Boost de Fin de Semana.
 *   - Se ejecuta en CUALQUIER página del juego (no depende de Overview).
 *   - Cada 5 minutos, con bypass manual via ?force_wb_cron=1
 *   - Llama a WeekendBoostHelper::checkAndApply()
 *   - Activa/desactiva automáticamente las velocidades según
 *     el día/hora configurados en admin.php?page=weekendboost
 *
 * ✅ FIX AstroIO v1.6 (Contador de Contenedores completo):
 *   - El contador 🎁 del header ahora muestra la SUMA de las 4 cajas:
 *       - uni1_users.containers        (Contenedor Genérico)
 *       - uni1_users_market.box_common (Cofre Común)
 *       - uni1_users_market.box_rare   (Cofre Raro)
 *       - uni1_users_market.box_legendary (Cofre Legendario)
 *   - Se hace 1 consulta extra a uni1_users_market para obtener los 3
 *     cofres del mercado y sumarlos al contador genérico.
 *   - La variable 'containers' que se pasa al template ahora es la SUMA.
 *   - Método privado astroio_getTotalContainers() hace la consulta.
 *
 * ✅ FIX AstroIO v1.7 (Mini Torneos):
 *   - Se inyecta 'tourneyEnd' (segundos restantes del ciclo de torneos)
 *     en TODAS las plantillas para que main.navigation_header.tpl u
 *     otros templates puedan mostrar el contador sin depender de
 *     ShowTourneyPage.
 *   - Valor calculado: Config::get()->tourneyEnd - TIMESTAMP
 *   - Si tourneyEnd = 0 o vencido, se envía 0.
 *
 * ✅ FIX AstroIO (Doble Riel NTX/UNTX):
 *   - El UNTX-20 ahora es global y se lee directamente de $USER, 
 *     igual que el NTX-20. Se suman 'untx20' y 'untx20_retirable'.
 *
 * ✅ FIX AstroIO (Bloqueo Global de MOPs Desactivados):
 *   - REGLA GLOBAL: Si un módulo está desactivado en el panel de admin,
 *     cualquier intento de acceso por URL (game.php?page=xxx) será bloqueado
 *     con un popup de advertencia. Aplica para TODOS los módulos (excepto admins).
 *   - FIX v2.0: Se ha añadido el parámetro `false` al final de printMessage
 *     para que el mensaje salga como una ventana (popup) compacta en el centro
 *     de la pantalla, en lugar de ocupar toda la página.
 */

abstract class AbstractGamePage
{
	/**
	 * reference of the template object
	 * @var template
	 */
	protected $tplObj;

	/**
	 * reference of the template object
	 * @var ResourceUpdate
	 */
	protected $ecoObj;
	protected $window;
	protected $disableEcoSystem = false;

	/* ═══ AstroIO: avatar por defecto (globo SVG, como en la foto del menú de usuario) ═══ */
	const ASTROIO_DEFAULT_AVATAR = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0' y1='0' x2='1' y2='1'%3E%3Cstop offset='0' stop-color='%230066cc'/%3E%3Cstop offset='1' stop-color='%2300e0ff'/%3E%3C/linearGradient%3E%3C/defs%3E%3Ccircle cx='32' cy='32' r='30' fill='url(%23g)'/%3E%3Cpath d='M2 32h60M32 2v60' stroke='rgba(255,255,255,.5)' stroke-width='2' fill='none'/%3E%3Ccircle cx='32' cy='32' r='14' fill='none' stroke='rgba(255,255,255,.35)' stroke-width='2'/%3E%3C/svg%3E";

	/* ═══ AstroIO: garantiza la columna avatar en %%USERS%% (migración automática, una vez por request) ═══ */
	public static function astroio_ensureAvatarColumn()
	{
		static $checked = false;
		if ($checked) return;
		$checked = true;
		try {
			$db    = Database::get();
			$names = $db->getDbTableNames();
			$idx   = array_search('%%USERS%%', $names['keys']);
			if ($idx === false) return;
			$usersTable = $names['names'][$idx];
			$res = $db->getHandle()->query("SHOW COLUMNS FROM `".$usersTable."` LIKE 'avatar'");
			if ($res && $res->fetch() === false) {
				$db->getHandle()->exec("ALTER TABLE `".$usersTable."` ADD COLUMN `avatar` VARCHAR(255) NOT NULL DEFAULT '' AFTER `email`");
			}
		} catch (Exception $e) { /* silencioso */ }
	}

	/* ═══ AstroIO: rango militar según puntos (cosmético para el submenú del avatar) ═══ */
	public static function astroio_rankName($points)
	{
		if ($points < 1000)    return 'Cadete';
		if ($points < 10000)   return 'Teniente';
		if ($points < 50000)   return 'Capitán';
		if ($points < 250000)  return 'Comandante';
		if ($points < 1000000) return 'Coronel';
		return 'Almirante';
	}

	/* ═══ AstroIO: ruta del avatar (vacío o inexistente = avatar por defecto) ═══ */
	public static function astroio_avatarPath($avatar)
	{
		return (!empty($avatar) && is_file($avatar)) ? $avatar : self::ASTROIO_DEFAULT_AVATAR;
	}

	protected function __construct() {

		if(!AJAX_REQUEST)
		{
			$this->setWindow('full');
			if(!$this->disableEcoSystem)
			{
				$this->ecoObj	= new ResourceUpdate();
				$this->ecoObj->CalcResource();
			}
			$this->initTemplate();

			// ═══════════════════════════════════════════════════════════
			// 🆕 REGLA GLOBAL: BLOQUEO DE MOPs DESACTIVADOS POR URL
			// ═══════════════════════════════════════════════════════════
			global $USER;
			
			// Verificamos si la clase tiene definida la constante $requireModule
			// y si esa constante no es 0 (0 significa que no requiere módulo)
			if (isset(static::$requireModule) && static::$requireModule != 0) {
				
				// Si el módulo NO está disponible y el usuario NO es admin (authlevel 0)
				if (!isModuleAvailable(static::$requireModule) && (!isset($USER['authlevel']) || $USER['authlevel'] == 0)) {
					
					// Mostramos el popup de advertencia.
					// El último parámetro `false` fuerza a que sea un popup (ventana centrada).
					$this->printMessage(
						"El MOP está desactivado temporalmente.<br>Consulte con la administración para cualquier duda.",
						array(array(
							'label' => 'Volver',
							'url'   => 'game.php?page=overview'
						)),
						NULL,
						false
					);
				}
			}
			// ═══════════════════════════════════════════════════════════

		} else {
			$this->setWindow('ajax');
		}
	}

	protected function initTemplate() {
		if(isset($this->tplObj))
			return true;

		$this->tplObj	= new template;
		list($tplDir)	= $this->tplObj->getTemplateDir();
		$this->tplObj->setTemplateDir($tplDir.'game/');
		return true;
	}

	protected function setWindow($window) {
		$this->window	= $window;
	}

	protected function getWindow() {
		return $this->window;
	}

	protected function getQueryString() {
		$queryString	= array();
		$page			= HTTP::_GP('page', '');

		if(!empty($page)) {
			$queryString['page']	= $page;
		}

		$mode			= HTTP::_GP('mode', '');
		if(!empty($mode)) {
			$queryString['mode']	= $mode;
		}

		return http_build_query($queryString);
	}

	protected function getCronjobsTodo()
	{
		require_once 'includes/classes/Cronjob.class.php';

		$this->assign(array(
			'cronjobs'		=> Cronjob::getNeedTodoExecutedJobs()
		));
	}

	/**
	 * AstroIO v1.3 — Datos del Torneo del Devorador para el MOP.
	 * Devuelve array con los campos boss_* listos para $pve.
	 *
	 * Se llama desde astroio_mergePveData() y es silencioso ante fallos.
	 *
	 * @return array {
	 *   boss_active, boss_status, boss_next_time, boss_end_time
	 * }
	 */
	private function astroio_getBossMopData()
	{
		$result = array(
			'boss_active'    => 0,
			'boss_status'    => 'idle',
			'boss_next_time' => 0,
			'boss_end_time'  => 0,
		);

		try {
			if (
				defined('MODULE_PVE')
				&& function_exists('isModuleAvailable')
				&& isModuleAvailable(MODULE_PVE)
			) {
				if (!class_exists('PVEBossTournamentHelper')) {
					$__bossFile = ROOT_PATH.'includes/classes/PVEBossTournamentHelper.class.php';
					if (file_exists($__bossFile)) {
						require_once $__bossFile;
					}
				}

				if (class_exists('PVEBossTournamentHelper')
					&& method_exists('PVEBossTournamentHelper', 'getEventState')) {
					$state = PVEBossTournamentHelper::getEventState();

					$result['boss_active']    = !empty($state['active'])     ? 1 : 0;
					$result['boss_status']    = !empty($state['status'])     ? (string) $state['status'] : 'idle';
					$result['boss_next_time'] = !empty($state['next_time'])  ? (int) $state['next_time']  : 0;
					$result['boss_end_time']  = !empty($state['end_time'])   ? (int) $state['end_time']   : 0;
				}
			}
		} catch (Throwable $e) {
			// Silencioso — nunca romper el MOP por el torneo
		}

		return $result;
	}

	/**
	 * AstroIO v1.3 — Fusiona los datos base del PvE con los del torneo
	 * y calcula los campos combinados any_active / next_time.
	 *
	 * @param array $pveData Array base devuelto por PVEHelper::getMopData()
	 * @return array Array fusionado con:
	 *   - boss_active, boss_status, boss_next_time, boss_end_time
	 *   - any_active (Crisis OR Imperio OR Torneo)
	 *   - next_time  (mínimo de los próximos tiempos no-cero)
	 */
	private function astroio_mergePveData(array $pveData)
	{
		// Fusionar datos del torneo
		$bossData = $this->astroio_getBossMopData();
		$pveData  = array_merge($pveData, $bossData);

		// any_active = Crisis OR Imperio OR Torneo
		$pveData['any_active'] = (
			!empty($pveData['crisis_active']) ||
			!empty($pveData['empire_active']) ||
			!empty($pveData['boss_active'])
		) ? 1 : 0;

		// next_time = mínimo de los próximos tiempos no-cero
		$candidates = array();
		if (!empty($pveData['crisis_next_time'])) $candidates[] = (int) $pveData['crisis_next_time'];
		if (!empty($pveData['empire_next_time'])) $candidates[] = (int) $pveData['empire_next_time'];
		if (!empty($pveData['boss_next_time']))   $candidates[] = (int) $pveData['boss_next_time'];

		$pveData['next_time'] = !empty($candidates) ? min($candidates) : 0;

		return $pveData;
	}

	/**
	 * 🆕 AstroIO v1.6 — Cuenta el TOTAL de contenedores del jugador.
	 *
	 * Suma las 4 cajas que tiene el jugador:
	 *   1. Contenedor Genérico  → uni1_users.containers
	 *   2. Cofre Común           → uni1_users_market.box_common
	 *   3. Cofre Raro            → uni1_users_market.box_rare
	 *   4. Cofre Legendario      → uni1_users_market.box_legendary
	 *
	 * @param Database $db
	 * @param int      $userId
	 * @param int      $genericCount  Valor actual de $USER['containers']
	 * @return int  Total de cajas (genérico + común + raro + legendario)
	 */
	private function astroio_getTotalContainers($db, $userId, $genericCount = 0)
	{
		$total = (int) $genericCount;

		try {
			$prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';

			$marketRow = $db->selectSingle(
				"SELECT box_common, box_rare, box_legendary
				 FROM `".$prefix."users_market`
				 WHERE user_id = :uid;",
				array(':uid' => (int) $userId)
			);

			if (is_array($marketRow)) {
				$total += (int) $marketRow['box_common'];
				$total += (int) $marketRow['box_rare'];
				$total += (int) $marketRow['box_legendary'];
			}
		} catch (Exception $e) {
			// Silencioso — si falla, mostramos al menos el genérico
			error_log('[ASTROIO CONTAINERS COUNT] ' . $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
		}

		return $total;
	}

	/**
	 * 🆕 AstroIO v1.7 — Segundos restantes del ciclo actual de Mini Torneos.
	 *
	 * Lee Config::get()->tourneyEnd y lo compara con TIMESTAMP.
	 * Si tourneyEnd es 0 o ya venció, devuelve 0.
	 *
	 * @return int  Segundos restantes (0 si no hay ciclo activo)
	 */
	private function astroio_getTourneyEnd()
	{
		try {
			$config = Config::get();
			if (empty($config->tourneyEnd)) {
				return 0;
			}
			$diff = (int) $config->tourneyEnd - TIMESTAMP;
			return $diff > 0 ? $diff : 0;
		} catch (Exception $e) {
			return 0;
		}
	}

	protected function getNavigationData()
	{
		global $PLANET, $LNG, $USER, $THEME, $resource, $reslist;

		// ============================================
		// ASTROIO - CRON GLOBAL DE ASTEROIDES
		// Se ejecuta en cualquier pagina del juego (overview, galaxy, fleetTable, etc.)
		// Cada 5 minutos, con bypass manual via ?force_ast_cron=1
		// ============================================
		if (!empty($USER) && is_array($USER) && !empty($USER['id'])) {
			$__astCacheKey = 'ast_last_run';
			$__astNow      = defined('TIMESTAMP') ? TIMESTAMP : time();
			$__astLast     = isset($_SESSION[$__astCacheKey]) ? (int)$_SESSION[$__astCacheKey] : 0;

			$__astForce = isset($_GET['force_ast_cron']) && (int) $_GET['force_ast_cron'] === 1;

			if ($__astForce || ($__astNow - $__astLast) > 300) {
				try {
					if (!class_exists('AsteroidHelper')) {
						$__astFile = ROOT_PATH . 'includes/classes/AsteroidHelper.class.php';
						if (file_exists($__astFile)) {
							require_once $__astFile;
						}
					}

					if (class_exists('AsteroidHelper')) {
						AsteroidHelper::processCron();
						$_SESSION[$__astCacheKey] = $__astNow;
					}
				} catch (Exception $e) {
					error_log('[ASTEROID CRON GLOBAL] ' . $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
				}
			}
		}
		// ============================================
		// FIN ASTROIO CRON GLOBAL
		// ============================================

		// ============================================
		// 🆕 ASTROIO v1.5 - CRON GLOBAL DE BOOST FIN DE SEMANA
		// ============================================
		// Se ejecuta en cualquier página del juego (overview, galaxy,
		// fleetTable, etc.). Cada 5 minutos. Comprueba si debe activar
		// o desactivar el boost según el día/hora actual.
		//
		// Bypass manual: añadir ?force_wb_cron=1 a cualquier URL
		// ============================================
		if (!empty($USER) && is_array($USER) && !empty($USER['id'])) {
			$__wbCacheKey = 'wb_last_run';
			$__wbNow      = defined('TIMESTAMP') ? TIMESTAMP : time();
			$__wbLast     = isset($_SESSION[$__wbCacheKey]) ? (int)$_SESSION[$__wbCacheKey] : 0;

			$__wbForce = isset($_GET['force_wb_cron']) && (int) $_GET['force_wb_cron'] === 1;

			if ($__wbForce || ($__wbNow - $__wbLast) > 300) {
				try {
					if (!class_exists('WeekendBoostHelper')) {
						$__wbFile = ROOT_PATH . 'includes/classes/WeekendBoostHelper.class.php';
						if (file_exists($__wbFile)) {
							require_once $__wbFile;
						}
					}

					if (class_exists('WeekendBoostHelper')) {
						WeekendBoostHelper::checkAndApply();
						$_SESSION[$__wbCacheKey] = $__wbNow;
					}
				} catch (Exception $e) {
					error_log('[WEEKEND BOOST CRON GLOBAL] ' . $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
				}
			}
		}
		// ============================================
		// FIN ASTROIO WEEKEND BOOST
		// ============================================

		// ✅ FIX v2.4: Detectar estado de error (juego cerrado, baneo, sesión inválida, etc.)
		if(
			empty($PLANET) || !is_array($PLANET) || !isset($PLANET['id'])
			|| empty($USER) || !is_array($USER) || !isset($USER['id'])
		) {
			$config = Config::get();

			// ✅ AstroIO v2.5 — $pve seguro también en early-return
			$pveData = array(
				'crisis_enabled'    => 0,
				'empire_enabled'    => 0,
				'crisis_active'     => 0,
				'empire_active'     => 0,
				'crisis_next_time'  => 0,
				'empire_next_time'  => 0,
			);
			try {
				if (
					defined('MODULE_PVE')
					&& function_exists('isModuleAvailable')
					&& isModuleAvailable(MODULE_PVE)
				) {
					if (!class_exists('PVEHelper')) {
						require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
					}
					$pveData = PVEHelper::getMopData();
				}
			} catch (Exception $e) {
				// Silencioso
			}

			// ✅ AstroIO v1.3 — Fusionar datos del Torneo + combinados
			$pveData = $this->astroio_mergePveData($pveData);

			// ✅ AstroIO v2.6 — $pvp seguro también en early-return
			$pvpData = array(
				'arena_enabled'      => 0,
				'tournament_enabled' => 0,
				'arenas_waiting'     => 0,
				'arenas_active'      => 0,
				'tournament_active'  => 0,
				'tournament_status'  => '',
				'tournament_time'    => 0,
			);
			try {
				if (
					defined('MODULE_PVP')
					&& function_exists('isModuleAvailable')
					&& isModuleAvailable(MODULE_PVP)
				) {
					if (!class_exists('PVPHelper')) {
						require_once ROOT_PATH.'includes/classes/PVPHelper.class.php';
					}
					if (!class_exists('PVPArenaHelper')) {
						require_once ROOT_PATH.'includes/classes/PVPArenaHelper.class.php';
					}
					if (!class_exists('PVPTournamentHelper')) {
						require_once ROOT_PATH.'includes/classes/PVPTournamentHelper.class.php';
					}

					$pvpData['arena_enabled']      = PVPHelper::isArenaEnabled()      ? 1 : 0;
					$pvpData['tournament_enabled'] = PVPHelper::isTournamentEnabled() ? 1 : 0;

					try {
						$arenaRows = PVPArenaHelper::getAvailableArenas(50);
						$pvpData['arenas_waiting'] = is_array($arenaRows) ? count($arenaRows) : 0;
					} catch (Exception $e) {}

					try {
						$rowA = Database::get()->selectSingle(
							"SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` IN ('active','extra_time');"
						);
						$pvpData['arenas_active'] = empty($rowA) ? 0 : (int) $rowA['c'];
					} catch (Exception $e) {}

					try {
						$t = PVPTournamentHelper::getActiveTournament();
						if (!empty($t)) {
							$pvpData['tournament_active'] = 1;
							$pvpData['tournament_status'] = isset($t['status']) ? $t['status'] : '';
							if ($pvpData['tournament_status'] === 'registration' && !empty($t['registration_ends_at'])) {
								$pvpData['tournament_time'] = (int) $t['registration_ends_at'];
							} elseif ($pvpData['tournament_status'] === 'running' && !empty($t['starts_at'])) {
								$pvpData['tournament_time'] = (int) $t['starts_at'];
							}
						}
					} catch (Exception $e) {}
				}
			} catch (Exception $e) {
				// Silencioso
			}

			$this->assign(array(
				'PlanetSelect'		=> array(),
				'new_message'		=> 0,
				'vacation'			=> false,
				'delete'			=> false,
				'darkmatter'		=> 0,
				'current_pid'		=> 0,
				'image'				=> '',
				'resourceTable'		=> array(),
				'shortlyNumber'		=> false,
				'closed'			=> (bool)$config->game_disable,
				'hasBoard'			=> false,
				'hasAdminAccess'	=> false,
				'hasGate'			=> false,
				'username'			=> '',
				// ═══ AstroIO: defaults del submenú de usuario (early-return) ═══
				'AIO_AVATAR_DEF'	=> self::ASTROIO_DEFAULT_AVATAR,
				'userAvatar'		=> self::ASTROIO_DEFAULT_AVATAR,
				'userEmail'			=> '',
				'userPoints'		=> 0,
				'userRankName'		=> 'Cadete',
				'userLangs'			=> array(),
				'userLang'			=> '',
				'previousPlanet'	=> 0,
				'nextPlanet'		=> 0,
				'allyName'			=> '',
				'allyTag'			=> '',
				'allyMembers'		=> 0,
				'allyMembersList'	=> array(),
				'onlineCount'		=> 0,
				'totalCount'		=> 0,
				'ntx20'				=> 0,
				'containers'		=> 0,
				'metodo_retiro'     => 'CUP',
				'untx20'            => 0,
				'pve'				=> $pveData,
				'pvp'				=> $pvpData,
				// ✅ AstroIO v1.2 — Alertas vacías en early-return
				'globalAlerts'		=> array('attack' => array(), 'spy' => array(), 'transport' => array()),
				// ✅ AstroIO v1.7 — Mini Torneos (contador global)
				'tourneyEnd'		=> $this->astroio_getTourneyEnd(),
			));
			return;
		}

		$config			= Config::get();
		$db 			= Database::get();

		// ═══ AstroIO: asegura la columna avatar antes de usarla en cualquier página ═══
		self::astroio_ensureAvatarColumn();

		$PlanetSelect	= array();

		if(!isset($USER['PLANETS']) || !is_array($USER['PLANETS'])) {
			$USER['PLANETS']	= getPlanets($USER);
		}

		if(!is_array($USER['PLANETS'])) {
			$USER['PLANETS']	= array();
		}

		foreach($USER['PLANETS'] as $PlanetQuery)
		{
			if(!is_array($PlanetQuery) || !isset($PlanetQuery['id'])) {
				continue;
			}
			$PlanetSelect[$PlanetQuery['id']]	= $PlanetQuery['name'].(($PlanetQuery['planet_type'] == 3) ? " (" . $LNG['fcm_moon'] . ")":"")." [".$PlanetQuery['galaxy'].":".$PlanetQuery['system'].":".$PlanetQuery['planet']."]";
		}

		$resourceTable	= array();
		$resourceSpeed	= $config->resource_multiplier;
		foreach($reslist['resstype'][1] as $resourceID)
		{
			$resourceTable[$resourceID]['name']			= $resource[$resourceID];
			$resourceTable[$resourceID]['current']		= $PLANET[$resource[$resourceID]];
			$resourceTable[$resourceID]['max']			= $PLANET[$resource[$resourceID].'_max'];
			if($USER['urlaubs_modus'] == 1 || $PLANET['planet_type'] != 1)
			{
				$resourceTable[$resourceID]['production']	= $PLANET[$resource[$resourceID].'_perhour'];
			}
			else
			{
				$resourceTable[$resourceID]['production']	= $PLANET[$resource[$resourceID].'_perhour'] + $config->{$resource[$resourceID].'_basic_income'} * $resourceSpeed;
			}
		}

		foreach($reslist['resstype'][2] as $resourceID)
		{
			$resourceTable[$resourceID]['name']			= $resource[$resourceID];
			$resourceTable[$resourceID]['used']			= $PLANET[$resource[$resourceID].'_used'];
			$resourceTable[$resourceID]['max']			= $PLANET[$resource[$resourceID]];
		}

		foreach($reslist['resstype'][3] as $resourceID)
		{
			$resourceTable[$resourceID]['name']			= $resource[$resourceID];
			$resourceTable[$resourceID]['current']		= $USER[$resource[$resourceID]];
		}

		/**
		 * Addition for moving planet with arrows
		**/
		$previousPlanet = $db->selectSingle("SELECT id FROM %%PLANETS%% WHERE id < :planetID AND id_owner = :userID AND destruyed = '0' ORDER BY id DESC LIMIT 1 ;", array(':planetID' => $PLANET['id'], ':userID' => $USER['id']));
		$nextPlanet = $db->selectSingle("SELECT id FROM %%PLANETS%% WHERE id > :planetID AND id_owner = :userID AND destruyed = '0' ORDER BY id ASC LIMIT 1 ;", array(':planetID' => $PLANET['id'], ':userID' => $USER['id']));

		// ===== ASTROIO - Panel de información =====
		$allyName    = '';
		$allyTag     = '';
		$allyMembers = 0;
		$allyMembersList = array();
		
		if (!empty($USER['ally_id'])) {
			$sql = "SELECT ally_name, ally_tag, ally_members 
					FROM %%ALLIANCE%% 
					WHERE id = :allyId AND ally_universe = :universe;";
			$allyData = $db->selectSingle($sql, [
				':allyId'    => $USER['ally_id'],
				':universe'  => Universe::current()
			]);
			if ($allyData) {
				$allyName    = $allyData['ally_name'];
				$allyTag     = $allyData['ally_tag'];
				$allyMembers = $allyData['ally_members'];
				
				$sql = "SELECT id, username, onlinetime, authlevel 
						FROM %%USERS%% 
						WHERE ally_id = :allyId 
						AND universe = :universe
						ORDER BY onlinetime DESC
						LIMIT 30;";
				$members = $db->select($sql, [
					':allyId'    => $USER['ally_id'],
					':universe'  => Universe::current()
				]);
				
				foreach ($members as $member) {
					$isOnline = ($member['onlinetime'] > (TIMESTAMP - 900));
					$allyMembersList[] = array(
						'id'       => $member['id'],
						'username' => $member['username'],
						'online'   => $isOnline,
						'time'     => $member['onlinetime']
					);
				}
			}
		}

		// =========================================================
		// ✅ FIX AstroIO v1.4: contador de usuarios online 24h y total
		// Ahora incluye a TODOS (usuarios + admins).
		// Se EXCLUYEN los fantasmas PvE/PvP filtrando por email.
		// Los fantasmas tienen email terminado en "@noreply.local".
		// =========================================================
		$sql = "SELECT COUNT(*) as onlineCount 
				FROM %%USERS%% 
				WHERE onlinetime > :timeLimit 
				AND universe = :universe
				AND email NOT LIKE '%@noreply.local';";
		$onlineCount = $db->selectSingle($sql, [
			':timeLimit' => TIMESTAMP - 86400,
			':universe'  => Universe::current()
		], 'onlineCount');

		$sql = "SELECT COUNT(*) as totalCount 
				FROM %%USERS%% 
				WHERE universe = :universe
				AND email NOT LIKE '%@noreply.local';";
		$totalCount = $db->selectSingle($sql, [
			':universe'  => Universe::current()
		], 'totalCount');
		// ===== FIN ASTROIO =====

		// =========================================================
		// 🆕 AstroIO v1.6 — TOTAL de contenedores del jugador
		// Suma: genérico + común + raro + legendario
		// =========================================================
		$totalContainers = $this->astroio_getTotalContainers(
			$db,
			(int) $USER['id'],
			isset($USER['containers']) ? (int) $USER['containers'] : 0
		);
		// ===== FIN ASTROIO CONTENEDORES =====

		// =========================================================
		// 🆕 AstroIO — Sistema de Doble Riel (Nacional / Internacional)
		// Ahora UNTX-20 es global y se lee directo de $USER
		// =========================================================
		$metodo_retiro = isset($USER['metodo_retiro']) ? $USER['metodo_retiro'] : 'CUP';
		
		// Sumamos el saldo jugable + el retirable directo de la tabla global
		$untx20 = (isset($USER['untx20']) ? (int)$USER['untx20'] : 0) + 
		          (isset($USER['untx20_retirable']) ? (int)$USER['untx20_retirable'] : 0);
		          
		// ===== FIN ASTROIO DOBLE RIEL =====

		// ===== ASTROIO v2.5 — Sistema PvE =====
		$pveData = array(
			'crisis_enabled'    => 0,
			'empire_enabled'    => 0,
			'crisis_active'     => 0,
			'empire_active'     => 0,
			'crisis_next_time'  => 0,
			'empire_next_time'  => 0,
		);
		try {
			if (
				defined('MODULE_PVE')
				&& function_exists('isModuleAvailable')
				&& isModuleAvailable(MODULE_PVE)
			) {
				if (!class_exists('PVEHelper')) {
					require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
				}
				$pveData = PVEHelper::getMopData();
			}
		} catch (Exception $e) {
			// Silencioso
		}
		// ✅ AstroIO v1.3 — Fusionar datos del Torneo + combinados
		$pveData = $this->astroio_mergePveData($pveData);
		// ===== FIN ASTROIO PvE =====

		// ===== ASTROIO v2.6 — Sistema PvP =====
		$pvpData = array(
			'arena_enabled'      => 0,
			'tournament_enabled' => 0,
			'arenas_waiting'     => 0,
			'arenas_active'      => 0,
			'tournament_active'  => 0,
			'tournament_status'  => '',
			'tournament_time'    => 0,
		);
		try {
			if (
				defined('MODULE_PVP')
				&& function_exists('isModuleAvailable')
				&& isModuleAvailable(MODULE_PVP)
			) {
				if (!class_exists('PVPHelper')) {
					require_once ROOT_PATH.'includes/classes/PVPHelper.class.php';
				}
				if (!class_exists('PVPArenaHelper')) {
					require_once ROOT_PATH.'includes/classes/PVPArenaHelper.class.php';
				}
				if (!class_exists('PVPTournamentHelper')) {
					require_once ROOT_PATH.'includes/classes/PVPTournamentHelper.class.php';
				}

				$pvpData['arena_enabled']      = PVPHelper::isArenaEnabled()      ? 1 : 0;
				$pvpData['tournament_enabled'] = PVPHelper::isTournamentEnabled() ? 1 : 0;

				try {
					$arenaRows = PVPArenaHelper::getAvailableArenas(50);
					$pvpData['arenas_waiting'] = is_array($arenaRows) ? count($arenaRows) : 0;
				} catch (Exception $e) {}

				try {
					$rowA = $db->selectSingle(
						"SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` IN ('active','extra_time');"
					);
					$pvpData['arenas_active'] = empty($rowA) ? 0 : (int) $rowA['c'];
				} catch (Exception $e) {}

				try {
					$t = PVPTournamentHelper::getActiveTournament();
					if (!empty($t)) {
						$pvpData['tournament_active'] = 1;
						$pvpData['tournament_status'] = isset($t['status']) ? $t['status'] : '';
						if ($pvpData['tournament_status'] === 'registration' && !empty($t['registration_ends_at'])) {
							$pvpData['tournament_time'] = (int) $t['registration_ends_at'];
						} elseif ($pvpData['tournament_status'] === 'running' && !empty($t['starts_at'])) {
							$pvpData['tournament_time'] = (int) $t['starts_at'];
						}
					}
				} catch (Exception $e) {}
			}
		} catch (Exception $e) {
			// Silencioso — nunca romper el MOP por el módulo PvP
		}
		// ===== FIN ASTROIO PvP =====

		// =========================================================
		// ✅ AstroIO v1.2 — Detección global de flotas entrantes
		// Se ejecuta en TODAS las páginas del juego (no solo galaxia)
		// Alimenta el bloque de alertas de la sidebar izquierda.
		// Misiones:
		//   1 = Atacar      → attack (rojo)
		//   2 = ACS         → attack (rojo)
		//   10 = Misiles    → attack (rojo)
		//   6 = Espionaje   → spy    (amarillo)
		//   3 = Transportar → transport (azul)
		//   4 = Desplegar   → transport (azul)
		// =========================================================
		$globalAlerts = array(
			'attack'    => array(),
			'spy'       => array(),
			'transport' => array(),
		);
		try {
			$alertSql = 'SELECT fleet_end_galaxy, fleet_end_system, fleet_end_planet,
								fleet_end_type, fleet_mission
						 FROM %%FLEETS%%
						 WHERE fleet_target_owner = :userId
						 AND fleet_mission IN (1, 2, 3, 4, 6, 10)
						 AND fleet_end_time > :now';
			$alertRows = $db->select($alertSql, array(
				':userId' => $USER['id'],
				':now'    => TIMESTAMP
			));

			foreach ($alertRows as $alert) {
				$ck = (int)$alert['fleet_end_galaxy'] . ':'
					. (int)$alert['fleet_end_system'] . ':'
					. (int)$alert['fleet_end_planet'] . ':'
					. (int)$alert['fleet_end_type'];

				$entry = array(
					'galaxy' => (int)$alert['fleet_end_galaxy'],
					'system' => (int)$alert['fleet_end_system'],
					'planet' => (int)$alert['fleet_end_planet'],
					'type'   => (int)$alert['fleet_end_type'],
					'coords' => (int)$alert['fleet_end_galaxy'] . ':'
							  . (int)$alert['fleet_end_system'] . ':'
							  . (int)$alert['fleet_end_planet'],
				);

				$mission = (int)$alert['fleet_mission'];

				if ($mission === 1 || $mission === 2 || $mission === 10) {
					$globalAlerts['attack'][$ck] = $entry;
				} elseif ($mission === 6) {
					$globalAlerts['spy'][$ck] = $entry;
				} elseif ($mission === 3 || $mission === 4) {
					$globalAlerts['transport'][$ck] = $entry;
				}
			}
		} catch (Exception $e) {
			error_log('[ASTROIO GLOBAL ALERTS] ' . $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
		}
		// ===== FIN ASTROIO ALERTAS =====

		$themeSettings	= $THEME->getStyleSettings();

		// ═══ AstroIO: datos del submenú del avatar (foto 1: datos, puntos, billetera, idioma) ═══
		self::astroio_ensureAvatarColumn();
		$UserPoints = 0;
		try {
			$UserPoints = (int) $db->selectSingle('SELECT total_points FROM %%STATPOINTS%% WHERE id_owner = :uid AND stat_type = 1', array(':uid' => $USER['id']), 'total_points');
		} catch (Exception $e) {}

		$this->assign(array(
			'AIO_AVATAR_DEF'	=> self::ASTROIO_DEFAULT_AVATAR,
			'userAvatar'		=> self::astroio_avatarPath(isset($USER['avatar']) ? $USER['avatar'] : ''),
			'userEmail'			=> $USER['email'],
			'userPoints'		=> $UserPoints,
			'userRankName'		=> self::astroio_rankName($UserPoints),
			'userLangs'			=> $LNG->getAllowedLangs(false),
			'userLang'			=> isset($USER['lang']) ? $USER['lang'] : $LNG->getLanguage(),
			'PlanetSelect'		=> $PlanetSelect,
			'new_message' 		=> $USER['messages'],
			'vacation'			=> $USER['urlaubs_modus'] ? _date($LNG['php_tdformat'], $USER['urlaubs_until'], $USER['timezone']) : false,
			'delete'			=> $USER['db_deaktjava'] ? sprintf($LNG['tn_delete_mode'], _date($LNG['php_tdformat'], $USER['db_deaktjava'] + ($config->del_user_manually * 86400)), $USER['timezone']) : false,
			'darkmatter'		=> $USER['darkmatter'],
			'current_pid'		=> $PLANET['id'],
			'image'				=> $PLANET['image'],
			'resourceTable'		=> $resourceTable,
			'shortlyNumber'		=> $themeSettings['TOPNAV_SHORTLY_NUMBER'],
			'closed'			=> (bool)$config->game_disable,
			'hasBoard'			=> filter_var($config->forum_url, FILTER_VALIDATE_URL),
			'hasAdminAccess'	=> !empty(Session::load()->adminAccess),
			'hasGate'			=> $PLANET[$resource[43]] > 0,
			'username'			=> $USER['username'],
			'previousPlanet'	=> (!empty($previousPlanet))?$previousPlanet['id']:$PLANET['id'],
			'nextPlanet'		=> (!empty($nextPlanet))?$nextPlanet['id']:$PLANET['id'],
			'allyName'			=> $allyName,
			'allyTag'			=> $allyTag,
			'allyMembers'		=> $allyMembers,
			'allyMembersList'	=> $allyMembersList,
			'onlineCount'		=> $onlineCount,
			'totalCount'		=> $totalCount,
			'ntx20'				=> isset($USER['ntx20']) ? (int)$USER['ntx20'] : 0,
			// ✅ AstroIO v1.6 — Total de contenedores (genérico + común + raro + legendario)
			'containers'		=> $totalContainers,
			// 🆕 AstroIO — Doble Riel (Nacional / Internacional)
			'metodo_retiro'     => $metodo_retiro,
			'untx20'            => $untx20,
			'pve'				=> $pveData,
			'pvp'				=> $pvpData,
			// ✅ AstroIO v1.2 — Alertas globales de flotas entrantes
			'globalAlerts'		=> $globalAlerts,
			// ✅ AstroIO v1.7 — Mini Torneos (contador global)
			'tourneyEnd'		=> $this->astroio_getTourneyEnd(),
		));
	}

	protected function getPageData()
	{
		global $USER, $THEME;

		if($this->getWindow() === 'full') {
			$this->getNavigationData();
			$this->getCronjobsTodo();
		}

		$dateTimeServer		= new DateTime("now");

		if(!empty($USER) && is_array($USER) && isset($USER['timezone'])) {
			try {
				$dateTimeUser	= new DateTime("now", new DateTimeZone($USER['timezone']));
			} catch (Exception $e) {
				$dateTimeUser	= $dateTimeServer;
			}
		} else {
			$dateTimeUser	= $dateTimeServer;
		}

		$config	= Config::get();

		$this->assign(array(
			'vmode'				=> isset($USER['urlaubs_modus']) ? $USER['urlaubs_modus'] : 0,
			'authlevel'			=> isset($USER['authlevel']) ? $USER['authlevel'] : 0,
			'userID'			=> isset($USER['id']) ? $USER['id'] : 0,
			'bodyclass'			=> $this->getWindow(),
			'game_name'			=> $config->game_name,
			'uni_name'			=> $config->uni_name,
			'ga_active'			=> $config->ga_active,
			'ga_key'			=> $config->ga_key,
			'debug'				=> $config->debug,
			'VERSION'			=> $config->VERSION,
			'date'				=> explode("|", date('Y\|n\|j\|G\|i\|s\|Z', TIMESTAMP)),
			'isPlayerCardActive' => isModuleAvailable(MODULE_PLAYERCARD),
			'REV'				=> substr($config->VERSION, -4),
			'Offset'			=> $dateTimeUser->getOffset() - $dateTimeServer->getOffset(),
			'queryString'		=> $this->getQueryString(),
			'themeSettings'		=> $THEME->getStyleSettings(),
		));
	}

	protected function printMessage($message, $redirectButtons = NULL, $redirect = NULL, $fullSide = true)
	{
		$this->assign(array(
			'message'			=> $message,
			'redirectButtons'	=> $redirectButtons,
		));

		if(isset($redirect)) {
			$this->tplObj->gotoside($redirect[0], $redirect[1]);
		}

		if(!$fullSide) {
			$this->setWindow('popup');
		}

		$this->display('error.default.tpl');
	}

	protected function save() {
		if(isset($this->ecoObj)) {
			$this->ecoObj->SavePlanetToDB();
		}
	}

	protected function assign($array, $nocache = true) {
		$this->tplObj->assign_vars($array, $nocache);
	}

	protected function display($file) {
		global $THEME, $LNG, $USER;

		$this->save();

		if($this->getWindow() !== 'ajax') {
			$this->getPageData();
		}

		$this->assign(array(
			'lang'    		=> $LNG->getLanguage(),
			'dpath'			=> $THEME->getTheme(),
			'scripts'		=> $this->tplObj->jsscript,
			'execscript'	=> implode("\n", $this->tplObj->script),
			'basepath'		=> PROTOCOL.HTTP_HOST.HTTP_BASE,
			'servertime'	=> _date("M D d H:i:s", TIMESTAMP, (!empty($USER) && is_array($USER) && isset($USER['timezone'])) ? $USER['timezone'] : 'UTC'),
		));

		$this->assign(array(
			'LNG'			=> $LNG,
		), false);

		$this->tplObj->display('extends:layout.'.$this->getWindow().'.tpl|'.$file);
		exit;
	}

	protected function sendJSON($data) {
		$this->save();
		echo json_encode($data);
		exit;
	}

	protected function redirectTo($url) {
		$this->save();
		HTTP::redirectTo($url);
		exit;
	}
}