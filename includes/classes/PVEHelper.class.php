<?php

/**
 * AstroIO — PVEHelper
 * Helper principal del sistema PvE (Crisis de Fin de Mes + Imperio Caído)
 *
 * v1.4 — Fix widget "Programado" fantasma:
 *   - getNextCrisisTime() respeta el toggle `crisis_auto_schedule_enabled`.
 *   - getEventState('crisis') solo aplica el fallback (día 25 calculado)
 *     si el toggle auto-schedule está a 1.
 *   - Arregla el bug por el que el widget mostraba "Programado" en el
 *     panel PvE y en Overview sin que hubiera ninguna crisis real.
 *
 * v2.0 — Doble Riel (NTX-20 / UNTX-20):
 *   - Añadidos helpers de detección de riel: getPlayerMethod, isIntl,
 *     getCurrencyLabel, getPhysicalColumn, getRielInfo.
 *   - Añadidos getPrecioParaJugador, getPremioParaJugador.
 *   - claimAllRewards() ahora acredita NTX-20 o UNTX-20 según el riel
 *     del jugador, con multiplicador ×2 para QVAPAY (premios base).
 *   - getPendingRewards() expone 'riel', 'moneda', 'multiplier' y
 *     'amount_real' para que los templates muestren el saldo correcto.
 *   - Log NTX20LogHelper SOLO si CUP (no existe UNTXLogHelper).
 *   - Refresco de $GLOBALS['USER'][col] tras acreditar NTX/UNTX.
 *   - Recursos (metal/crystal/deuterium) no dependen del riel: intactos.
 *
 * Ubicación: includes/classes/PVEHelper.class.php
 * @package AstroIO
 * @version 2.0
 */

class PVEHelper
{
	/** @var int Regla ×2 centralizada (ÚNICO lugar donde vive el 2) */
	const UNTX_MULTIPLIER = 2;

	/** @var array Rieles válidos */
	const RIELS = array('CUP', 'QVAPAY');

	/** @var array|null Caché de la configuración PvE */
	private static $configCache = null;

	/** @var int|null Caché del próximo tiempo de crisis */
	private static $crisisNextTimeCache = null;

	/** @var int|null Caché del próximo tiempo de imperio */
	private static $empireNextTimeCache = null;

	/** @var array|null Caché del estado de eventos */
	private static $eventStateCache = array();

	/** @var array Caché de método de retiro por usuario */
	private static $methodCache = array();


	/* ============================================================
	 *  CONFIGURACIÓN
	 * ============================================================ */

	/**
	 * Devuelve toda la configuración PvE como array asociativo.
	 */
	public static function getConfig()
	{
		if (self::$configCache !== null) {
			return self::$configCache;
		}

		$db		= Database::get();
		$sql	= "SELECT `config_key`, `config_value` FROM %%PVE_CONFIG%%;";
		$rows	= $db->select($sql);

		$config = array();
		if (!empty($rows)) {
			foreach ($rows as $row) {
				$config[$row['config_key']] = $row['config_value'];
			}
		}

		self::$configCache = $config;
		return $config;
	}


	/**
	 * Devuelve un valor concreto de la configuración.
	 */
	public static function get($key, $default = null)
	{
		$config = self::getConfig();
		return isset($config[$key]) ? $config[$key] : $default;
	}


	/**
	 * Fuerza la recarga de la caché de configuración.
	 */
	public static function clearConfigCache()
	{
		self::$configCache          = null;
		self::$crisisNextTimeCache  = null;
		self::$empireNextTimeCache  = null;
		self::$eventStateCache      = array();
	}


	/* ============================================================
	 *  DOBLE RIEL — DETECCIÓN
	 * ============================================================ */

	/**
	 * Detecta el riel del jugador según `metodo_retiro`.
	 * Cachea el resultado. Fail-safe: si falla → 'CUP'.
	 *
	 * @param int $userId
	 * @return string 'CUP'|'QVAPAY'
	 */
	public static function getPlayerMethod($userId)
	{
		$userId = (int) $userId;
		if ($userId <= 0) {
			return 'CUP';
		}

		if (isset(self::$methodCache[$userId])) {
			return self::$methodCache[$userId];
		}

		try {
			$db  = Database::get();
			$row = $db->selectSingle(
				"SELECT `metodo_retiro` FROM %%USERS%% WHERE `id` = :uid LIMIT 1;",
				array(':uid' => $userId)
			);
			$method = ($row && isset($row['metodo_retiro']) && $row['metodo_retiro'] === 'QVAPAY')
				? 'QVAPAY'
				: 'CUP';
		} catch (Exception $e) {
			$method = 'CUP';
		}

		self::$methodCache[$userId] = $method;
		return $method;
	}


	/**
	 * ¿El jugador pertenece al riel internacional (QVAPAY)?
	 */
	public static function isIntl($userId)
	{
		return self::getPlayerMethod($userId) === 'QVAPAY';
	}


	/**
	 * Etiqueta visible de la moneda del jugador.
	 */
	public static function getCurrencyLabel($userId)
	{
		return self::isIntl($userId) ? 'UNTX-20' : 'NTX-20';
	}


	/**
	 * Columna física de la BD donde vive el saldo del jugador.
	 */
	public static function getPhysicalColumn($userId)
	{
		return self::isIntl($userId) ? 'untx20' : 'ntx20';
	}


	/**
	 * Devuelve toda la info del riel del jugador.
	 *
	 * @param int $userId
	 * @return array
	 */
	public static function getRielInfo($userId)
	{
		$userId     = (int) $userId;
		$isIntl     = self::isIntl($userId);
		$colBalance = $isIntl ? 'untx20' : 'ntx20';
		$moneda     = $isIntl ? 'UNTX-20' : 'NTX-20';
		$monedaFiat = $isIntl ? 'USD' : 'CUP';
		$saldo      = 0;

		try {
			$db  = Database::get();
			$row = $db->selectSingle(
				"SELECT `" . $colBalance . "` AS saldo FROM %%USERS%% WHERE `id` = :uid LIMIT 1;",
				array(':uid' => $userId)
			);
			$saldo = $row ? (int) $row['saldo'] : 0;
		} catch (Exception $e) {
			// Fail-safe
		}

		return array(
			'isIntl'     => $isIntl,
			'colBalance' => $colBalance,
			'moneda'     => $moneda,
			'monedaFiat' => $monedaFiat,
			'saldo'      => $saldo,
			'multiplier' => $isIntl ? self::UNTX_MULTIPLIER : 1,
		);
	}


	/**
	 * Convierte un precio base (NTX-20) al precio real del jugador.
	 */
	public static function getPrecioParaJugador($precioBase, $userId)
	{
		return self::isIntl($userId)
			? ((int) $precioBase * self::UNTX_MULTIPLIER)
			: (int) $precioBase;
	}


	/**
	 * Convierte un premio base (NTX-20) al premio real que recibe.
	 */
	public static function getPremioParaJugador($cantidadBase, $userId)
	{
		return self::isIntl($userId)
			? ((int) $cantidadBase * self::UNTX_MULTIPLIER)
			: (int) $cantidadBase;
	}


	/**
	 * Limpia la caché de rieles.
	 */
	public static function clearMethodCache()
	{
		self::$methodCache = array();
	}


	/* ============================================================
	 *  ESTADO DE LOS EVENTOS
	 * ============================================================ */

	public static function isEnabled()
	{
		return (int) self::get('pve_enabled', 0) === 1;
	}


	public static function isCrisisEnabled()
	{
		return self::isEnabled() && (int) self::get('pve_crisis_enabled', 0) === 1;
	}


	public static function isEmpireEnabled()
	{
		return self::isEnabled() && (int) self::get('pve_empire_enabled', 0) === 1;
	}


	public static function isCrisisActive()
	{
		if (!self::isCrisisEnabled()) {
			return false;
		}

		$db		= Database::get();
		$sql	= "SELECT COUNT(*) AS total
				   FROM %%PVE_CRISIS%%
				   WHERE `status` = 'active'
				     AND `start_time` <= :now
				     AND `end_time` > :now;";

		$count = $db->selectSingle($sql, array(':now' => TIMESTAMP), 'total');
		return (int) $count > 0;
	}


	public static function isEmpireActive()
	{
		if (!self::isEmpireEnabled()) {
			return false;
		}

		$db		= Database::get();
		$sql	= "SELECT COUNT(*) AS total
				   FROM %%PVE_EMPIRES%%
				   WHERE `status` = 'active'
				     AND `start_time` <= :now
				     AND `end_time` > :now;";

		$count = $db->selectSingle($sql, array(':now' => TIMESTAMP), 'total');
		return (int) $count > 0;
	}


	/* ============================================================
	 *  CÁLCULO DEL PRÓXIMO EVENTO
	 * ============================================================ */

	public static function getNextEventTime($type)
	{
		if ($type === 'crisis') {
			return self::getNextCrisisTime();
		}
		if ($type === 'empire') {
			return self::getNextEmpireTime();
		}
		return 0;
	}


	/**
	 * Devuelve el timestamp de la próxima crisis TEÓRICA (día 25 del mes).
	 *
	 * v1.4 — Solo calcula si el toggle `crisis_auto_schedule_enabled` está a 1.
	 *        Si está a 0, devuelve 0 (sin próxima crisis programada).
	 */
	private static function getNextCrisisTime()
	{
		if (!self::isCrisisEnabled()) {
			return 0;
		}

		// v1.4 — Sin auto-schedule activado → NO hay próxima crisis teórica
		if ((int) self::get('crisis_auto_schedule_enabled', 0) !== 1) {
			return 0;
		}

		if (self::$crisisNextTimeCache !== null) {
			return self::$crisisNextTimeCache;
		}

		$day    = max(1, min(28, (int) self::get('crisis_day', 25)));
		$hour   = max(0, min(23, (int) self::get('crisis_hour', 10)));
		$minute = max(0, min(59, (int) self::get('crisis_minute', 30)));

		$now       = time();
		$year      = (int) date('Y', $now);
		$month     = (int) date('n', $now);

		$eventTime = mktime($hour, $minute, 0, $month, $day, $year);

		if ($eventTime <= $now) {
			$month++;
			if ($month > 12) {
				$month = 1;
				$year++;
			}
			$eventTime = mktime($hour, $minute, 0, $month, $day, $year);
		}

		self::$crisisNextTimeCache = $eventTime;
		return $eventTime;
	}


	private static function getNextEmpireTime()
	{
		if (!self::isEmpireEnabled()) {
			return 0;
		}

		if (self::$empireNextTimeCache !== null) {
			return self::$empireNextTimeCache;
		}

		$db   = Database::get();
		$sql  = "SELECT MIN(`start_time`) AS next_time
				   FROM %%PVE_EMPIRES%%
				   WHERE `status` = 'scheduled'
				     AND `start_time` > :now;";

		$nextTime = $db->selectSingle($sql, array(':now' => TIMESTAMP), 'next_time');

		if (!empty($nextTime)) {
			self::$empireNextTimeCache = (int) $nextTime;
			return self::$empireNextTimeCache;
		}

		$manualTime = (int) self::get('empire_scheduled_time', 0);
		self::$empireNextTimeCache = $manualTime > 0 ? $manualTime : 0;
		return self::$empireNextTimeCache;
	}


	/* ============================================================
	 *  ESTADO COMPLETO DEL EVENTO (para countdown)
	 * ============================================================ */

	/**
	 * Devuelve el estado completo del evento indicado para el countdown.
	 *
	 * @param string $type 'crisis' | 'empire'
	 * @return array
	 */
	public static function getEventState($type)
	{
		if (isset(self::$eventStateCache[$type])) {
			return self::$eventStateCache[$type];
		}

		$state = array(
			'enabled'   => 0,
			'active'    => 0,
			'next_time' => 0,
			'end_time'  => 0,
		);

		$db = Database::get();
		$now = TIMESTAMP;

		if ($type === 'crisis') {
			$state['enabled'] = self::isCrisisEnabled() ? 1 : 0;

			if (!$state['enabled']) {
				self::$eventStateCache[$type] = $state;
				return $state;
			}

			// ¿Hay crisis activa?
			$sql = "SELECT id, start_time, end_time
			        FROM %%PVE_CRISIS%%
			        WHERE `status` = 'active'
			          AND `start_time` <= :now
			          AND `end_time` > :now
			        ORDER BY end_time ASC
			        LIMIT 1;";
			$active = $db->selectSingle($sql, array(':now' => $now));

			if (!empty($active)) {
				$state['active']    = 1;
				$state['next_time'] = (int) $active['start_time'];
				$state['end_time']  = (int) $active['end_time'];
				self::$eventStateCache[$type] = $state;
				return $state;
			}

			// ¿Hay crisis programada próxima?
			$sql = "SELECT id, start_time, end_time
			        FROM %%PVE_CRISIS%%
			        WHERE `status` = 'scheduled'
			          AND `start_time` > :now
			        ORDER BY start_time ASC
			        LIMIT 1;";
			$next = $db->selectSingle($sql, array(':now' => $now));

			if (!empty($next)) {
				$state['next_time'] = (int) $next['start_time'];
			} else {
				// v1.4 — Fallback SOLO si auto-schedule está ON
				if ((int) self::get('crisis_auto_schedule_enabled', 0) === 1) {
					$state['next_time'] = self::getNextCrisisTime();
				} else {
					$state['next_time'] = 0;
				}
			}

			self::$eventStateCache[$type] = $state;
			return $state;
		}

		if ($type === 'empire') {
			$state['enabled'] = self::isEmpireEnabled() ? 1 : 0;

			if (!$state['enabled']) {
				self::$eventStateCache[$type] = $state;
				return $state;
			}

			// ¿Hay imperios activos?
			$sql = "SELECT MIN(start_time) AS first_start, MAX(end_time) AS last_end
			        FROM %%PVE_EMPIRES%%
			        WHERE `status` = 'active'
			          AND `start_time` <= :now
			          AND `end_time` > :now;";
			$active = $db->selectSingle($sql, array(':now' => $now));

			if (!empty($active) && !empty($active['last_end'])) {
				$state['active']    = 1;
				$state['next_time'] = (int) $active['first_start'];
				$state['end_time']  = (int) $active['last_end'];
				self::$eventStateCache[$type] = $state;
				return $state;
			}

			// ¿Hay imperio programado?
			$sql = "SELECT start_time, end_time
			        FROM %%PVE_EMPIRES%%
			        WHERE `status` = 'scheduled'
			          AND `start_time` > :now
			        ORDER BY start_time ASC
			        LIMIT 1;";
			$next = $db->selectSingle($sql, array(':now' => $now));

			if (!empty($next)) {
				$state['next_time'] = (int) $next['start_time'];
			} else {
				$manualTime = (int) self::get('empire_scheduled_time', 0);
				$state['next_time'] = $manualTime > 0 ? $manualTime : 0;
			}

			self::$eventStateCache[$type] = $state;
			return $state;
		}

		return $state;
	}


	/* ============================================================
	 *  DATOS PARA EL MOP / OVERVIEW
	 * ============================================================ */

	public static function getMopData()
	{
		return array(
			'crisis_enabled'    => self::isCrisisEnabled()  ? 1 : 0,
			'empire_enabled'    => self::isEmpireEnabled()  ? 1 : 0,
			'crisis_active'     => self::isCrisisActive()   ? 1 : 0,
			'empire_active'     => self::isEmpireActive()   ? 1 : 0,
			'crisis_next_time'  => self::getNextEventTime('crisis'),
			'empire_next_time'  => self::getNextEventTime('empire'),
		);
	}


	/* ============================================================
	 *  UTILIDADES
	 * ============================================================ */

	public static function log($eventType, $eventId, $action, $userId = 0, $planetId = 0, $details = null)
	{
		$db = Database::get();

		$sql = "INSERT INTO %%PVE_LOG%% SET
			`event_type`  = :eventType,
			`event_id`    = :eventId,
			`action`      = :action,
			`user_id`     = :userId,
			`planet_id`   = :planetId,
			`details`     = :details,
			`ip_address`  = :ip,
			`created_at`  = :now;";

		$db->insert($sql, array(
			':eventType' => $eventType,
			':eventId'   => (int) $eventId,
			':action'    => $action,
			':userId'    => (int) $userId,
			':planetId'  => (int) $planetId,
			':details'   => $details !== null ? json_encode($details) : null,
			':ip'        => isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : '',
			':now'       => TIMESTAMP,
		));
	}


	/* ============================================================
	 *  RECOMPENSAS — LISTAR / RECLAMAR
	 * ============================================================ */

	/**
	 * Devuelve todas las recompensas pendientes de un jugador.
	 *
	 * v1.3 — Parsea también `reward_type='resources'`.
	 * v2.0 — Añade info del riel del jugador y el monto real
	 *        (base ×2 si QVAPAY). Preserva 'amount' como BASE.
	 */
	public static function getPendingRewards($userId)
	{
		$db = Database::get();
		$userId = (int) $userId;

		$sql = "SELECT r.*, 
		               (SELECT COALESCE(SUM(damage_done), 0) 
		                FROM %%PVE_CRISIS_ATTACKS%% 
		                WHERE crisis_id = r.event_id AND user_id = r.user_id) AS damage_done,
		               (SELECT COUNT(DISTINCT wave_id) 
		                FROM %%PVE_CRISIS_ATTACKS%% 
		                WHERE crisis_id = r.event_id AND user_id = r.user_id) AS waves_survived
		        FROM %%PVE_REWARDS%% r
		        WHERE r.user_id = :uid
		          AND r.claimed = 0
		        ORDER BY r.created_at DESC;";

		$rows = $db->select($sql, array(':uid' => $userId));
		if (empty($rows)) {
			return array();
		}

		// Info del riel del jugador (una sola vez)
		$riel       = self::getPlayerMethod($userId);
		$moneda     = self::getCurrencyLabel($userId);
		$multiplier = self::isIntl($userId) ? self::UNTX_MULTIPLIER : 1;

		$rewards = array();
		foreach ($rows as $row) {
			$data = json_decode($row['reward_data'], true);
			if (!is_array($data)) {
				$data = array();
			}

			// ─── Parsear campos según tipo ───
			$amount    = isset($data['amount'])    ? (int) $data['amount']    : 0;
			$metal     = isset($data['metal'])     ? (int) $data['metal']     : 0;
			$crystal   = isset($data['crystal'])   ? (int) $data['crystal']   : 0;
			$deuterium = isset($data['deuterium']) ? (int) $data['deuterium'] : 0;

			// Monto real de NTX (solo aplica si reward_type='ntx')
			$amountReal = ($row['reward_type'] === 'ntx')
				? ((int) $amount * $multiplier)
				: 0;

			$rewards[] = array(
				'id'             => (int) $row['id'],
				'event_type'     => $row['event_type'],
				'event_id'       => (int) $row['event_id'],
				'reward_type'    => $row['reward_type'],

				// NTX (amount = BASE, amount_real = en el riel del jugador)
				'amount'         => $amount,
				'amount_real'    => $amountReal,

				// Recursos
				'metal'          => $metal,
				'crystal'        => $crystal,
				'deuterium'      => $deuterium,

				// Contexto del jugador
				'riel'           => $riel,
				'moneda'         => $moneda,
				'multiplier'     => $multiplier,

				// Contexto (solo crisis)
				'damage_done'    => (int) $row['damage_done'],
				'waves_survived' => (int) $row['waves_survived'],
				'created_at'     => (int) $row['created_at'],
			);
		}

		return $rewards;
	}


	/**
	 * Cuenta cuántas recompensas pendientes tiene un jugador.
	 */
	public static function countPendingRewards($userId)
	{
		$db = Database::get();
		$userId = (int) $userId;

		$sql = "SELECT COUNT(*) AS total
		        FROM %%PVE_REWARDS%%
		        WHERE user_id = :uid AND claimed = 0;";

		$row = $db->selectSingle($sql, array(':uid' => $userId));
		return !empty($row) ? (int) $row['total'] : 0;
	}


	/**
	 * Reclama TODAS las recompensas pendientes de un jugador.
	 *
	 * v1.3 — Soporta NTX-20 y resources.
	 * v2.0 — Doble Riel:
	 *   - reward_type='ntx' → acredita en `ntx20` o `untx20` según el
	 *     riel del jugador, con ×2 para QVAPAY.
	 *   - Refresca $GLOBALS['USER'][col].
	 *   - Log NTX20LogHelper SOLO si CUP.
	 *   - `ntx_total` devuelto es el monto REAL acreditado.
	 *
	 * @return array ['claimed', 'ntx_total', 'resources_total', 'errors']
	 */
	public static function claimAllRewards($userId)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		$pending = self::getPendingRewards($userId);

		$claimed        = 0;
		$ntxTotal       = 0;
		$resourcesTotal = array('metal' => 0, 'crystal' => 0, 'deuterium' => 0);
		$errors         = array();

		if (empty($pending)) {
			return array(
				'claimed'         => 0,
				'ntx_total'       => 0,
				'resources_total' => $resourcesTotal,
				'errors'          => array('No hay recompensas pendientes.'),
			);
		}

		// Cargar WalletHelper (solo para CUP, fallback directo si falta)
		if (!class_exists('WalletHelper')) {
			$walletFile = ROOT_PATH.'includes/classes/WalletHelper.class.php';
			if (file_exists($walletFile)) {
				require_once $walletFile;
			}
		}

		// Cargar NTX20LogHelper (solo se usa si CUP)
		if (!class_exists('NTX20LogHelper')) {
			$ntxLogFile = ROOT_PATH.'includes/classes/NTX20LogHelper.class.php';
			if (file_exists($ntxLogFile)) {
				require_once $ntxLogFile;
			}
		}

		// Info del riel del jugador (una sola vez por reclamo)
		$riel       = self::getPlayerMethod($userId);
		$isIntl     = ($riel === 'QVAPAY');
		$col        = $isIntl ? 'untx20' : 'ntx20';
		$multiplier = $isIntl ? self::UNTX_MULTIPLIER : 1;

		foreach ($pending as $reward) {
			try {
				$rewardType = $reward['reward_type'];

				// ─── NTX-20 / UNTX-20 ─────────────────────────────
				if ($rewardType === 'ntx') {
					$baseAmount = (int) $reward['amount'];
					$realAmount = $baseAmount * $multiplier;

					if ($realAmount <= 0) {
						// nada que dar, marcar y seguir
					} else {
						$okAdd = false;

						if (!$isIntl && class_exists('WalletHelper') && method_exists('WalletHelper', 'addNxt20')) {
							// CUP → WalletHelper (auditoría NTX-20)
							try {
								WalletHelper::addNxt20(
									$userId,
									$realAmount,
									'pve_' . $reward['event_type'],
									'Recompensa PvE ' . ucfirst($reward['event_type']) . ' #' . $reward['event_id']
								);
								$okAdd = true;
							} catch (Exception $e) {
								// Fallback abajo
							}
						}

						if (!$okAdd) {
							// QVAPAY o fallback directo → UPDATE en la columna correcta
							$sql = "UPDATE %%USERS%% SET `" . $col . "` = `" . $col . "` + :n WHERE id = :uid;";
							$db->update($sql, array(':n' => $realAmount, ':uid' => $userId));

							if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $userId) {
								$GLOBALS['USER'][$col] = ((int) ($GLOBALS['USER'][$col] ?? 0)) + $realAmount;
							}
						}

						// Log NTX20 SOLO si CUP (no existe UNTXLogHelper)
						if (!$isIntl && class_exists('NTX20LogHelper')) {
							try {
								NTX20LogHelper::log(
									$userId,
									$realAmount,
									'pve_' . $reward['event_type'],
									'Recompensa PvE ' . ucfirst($reward['event_type']) . ' #' . $reward['event_id'],
									(int) $reward['event_id']
								);
							} catch (Exception $e) {
								// silencioso
							}
						}

						$ntxTotal += $realAmount;
					}
				}

				// ─── Recursos (no dependen del riel) ──────────────
				elseif ($rewardType === 'resources') {
					$metal     = (int) $reward['metal'];
					$crystal   = (int) $reward['crystal'];
					$deuterium = (int) $reward['deuterium'];

					if (($metal + $crystal + $deuterium) > 0) {
						$ok = self::addResourcesToPlayer($userId, $metal, $crystal, $deuterium);
						if ($ok) {
							$resourcesTotal['metal']     += $metal;
							$resourcesTotal['crystal']   += $crystal;
							$resourcesTotal['deuterium'] += $deuterium;
						} else {
							$errors[] = 'Reward #' . $reward['id'] . ': no se pudo añadir recursos al planeta.';
							self::log($reward['event_type'], $reward['event_id'], 'claim_resources_error', $userId, 0, array(
								'reward_id' => $reward['id'],
								'metal'     => $metal,
								'crystal'   => $crystal,
								'deuterium' => $deuterium,
							));
							// NO marcar como reclamada si falla — para poder reintentar
							continue;
						}
					}
				}

				// ─── Otros tipos (ships, defenses, mo, chest) ─────
				else {
					self::log($reward['event_type'], $reward['event_id'], 'claim_unsupported_type', $userId, 0, array(
						'reward_id'   => $reward['id'],
						'reward_type' => $rewardType,
					));
				}

				// ─── Marcar como reclamada ────────────────────────
				$sql = "UPDATE %%PVE_REWARDS%% 
				        SET claimed = 1, claimed_at = :now 
				        WHERE id = :id AND user_id = :uid;";
				$db->update($sql, array(
					':now' => TIMESTAMP,
					':id'  => $reward['id'],
					':uid' => $userId,
				));

				$claimed++;

			} catch (Exception $e) {
				$errors[] = 'Reward #' . $reward['id'] . ': ' . $e->getMessage();
				self::log($reward['event_type'], $reward['event_id'], 'claim_error', $userId, 0, array(
					'error'     => $e->getMessage(),
					'reward_id' => $reward['id'],
				));
			}
		}

		self::log('rewards', 0, 'rewards_claimed', $userId, 0, array(
			'claimed'         => $claimed,
			'ntx_total'       => $ntxTotal,
			'riel'            => $riel,
			'resources_total' => $resourcesTotal,
		));

		return array(
			'claimed'         => $claimed,
			'ntx_total'       => $ntxTotal,
			'resources_total' => $resourcesTotal,
			'errors'          => $errors,
		);
	}


	/* ============================================================
	 *  HELPERS — AÑADIR RECURSOS AL JUGADOR
	 * ============================================================ */

	/**
	 * Añade recursos al planeta PRINCIPAL del jugador (planet_type = 1).
	 * Si no lo encuentra, prueba con el primer planeta del usuario.
	 *
	 * @return bool  true si se añadieron correctamente
	 */
	public static function addResourcesToPlayer($userId, $metal, $crystal, $deuterium)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		$metal     = max(0, (int) $metal);
		$crystal   = max(0, (int) $crystal);
		$deuterium = max(0, (int) $deuterium);

		if (($metal + $crystal + $deuterium) <= 0) {
			return false;
		}

		// Buscar planeta principal
		$sql = "SELECT id FROM %%PLANETS%% 
		        WHERE id_owner = :uid AND planet_type = 1 
		        ORDER BY id ASC LIMIT 1;";
		$row = $db->selectSingle($sql, array(':uid' => $userId));

		// Fallback: cualquier planeta del jugador
		if (empty($row) || empty($row['id'])) {
			$sql = "SELECT id FROM %%PLANETS%% 
			        WHERE id_owner = :uid 
			        ORDER BY id ASC LIMIT 1;";
			$row = $db->selectSingle($sql, array(':uid' => $userId));
		}

		if (empty($row) || empty($row['id'])) {
			return false;
		}

		$planetId = (int) $row['id'];

		try {
			$sql = "UPDATE %%PLANETS%% SET
			        metal     = metal     + :m,
			        crystal   = crystal   + :c,
			        deuterium = deuterium + :d
			        WHERE id = :pid;";

			$db->update($sql, array(
				':m'   => $metal,
				':c'   => $crystal,
				':d'   => $deuterium,
				':pid' => $planetId,
			));

			return true;
		} catch (Throwable $e) {
			self::log('rewards', 0, 'add_resources_error', $userId, $planetId, array(
				'error'     => $e->getMessage(),
				'metal'     => $metal,
				'crystal'   => $crystal,
				'deuterium' => $deuterium,
			));
			return false;
		}
	}
}