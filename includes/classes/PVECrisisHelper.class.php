<?php

/**
 * AstroIO — PVECrisisHelper
 * Lógica completa de la Crisis de Fin de Mes.
 * v2.7 — RECOMPENSAS + lock robusto + logs + filtro fantasmas + guard anti-duplicado
 *        + LIMPIEZA AUTOMÁTICA en 3 capas
 *        + Limpieza extendida: empires, empire_attacks, acs_invites
 *
 * v2.8 — AUTO-PROGRAMACIÓN MENSUAL:
 *   - autoScheduleIfNeeded()      → llamada desde ShowOverviewPage cron
 *   - getScheduledTimeForCurrentMonth() → cálculo de la fecha del mes
 *   - markAsScheduledThisMonth()  → tracking YYYYMM para evitar duplicados
 *   - Respeta el toggle crisis_auto_schedule_enabled
 *   - NO interfiere con crisis manuales (skip si hay una ya scheduled/active)
 *
 * v2.9 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Este helper NO toca directamente el saldo del jugador. Las
 *     recompensas se insertan en `uni1_pve_rewards` con el monto en
 *     BASE NTX-20 y el ×2 para QVAPAY se aplica al reclamar en
 *     `PVEHelper::claimAllRewards()` (v2.0 dual-riel).
 *   · Se añaden las constantes UNTX_MULTIPLIER y RIELS por coherencia
 *     con PVPHelper/PVEHelper, aunque este archivo no las use.
 *   · Se documenta la convención base/real en `grantRewards()`.
 *
 * Ubicación: includes/classes/PVECrisisHelper.class.php
 * @package AstroIO
 * @version 2.9
 *   - scheduleCrisis(): try/catch + verificación de lastInsertId + log de errores
 *   - generateWaves(): columnas explícitas + log por wave
 *   - executeNextWave(): lock vía SELECT (no rowCount), logs en cada paso, log de excepciones
 *   - Fallback wave: mismas columnas explícitas
 *   - rotateFaction(): log de rotación
 *   - finishCrisis(): guard anti-duplicado en uni1_pve_rewards
 *   - sendWaveFleets(): excluye fantasmas (is_pve = 1) como objetivos
 *   - cleanupFinishedCrisis(): limpieza inmediata tras finalizar
 *   - cleanupOrphans(): limpieza periódica (cron cada 5 min)
 *   - cleanupDeep(): limpieza profunda (1 vez al día)
 *   - cleanupOrphans + cleanupDeep ampliados a:
 *       - uni1_pve_empires
 *       - uni1_pve_empire_attacks
 *       - uni1_pve_acs_invites
 *   - autoScheduleIfNeeded(): programación automática mensual (v2.8)
 */

// AstroIO - Cargar PveFleetHelper explícitamente
if (!class_exists('PveFleetHelper')) {
	require_once ROOT_PATH.'includes/classes/PveFleetHelper.class.php';
}

class PVECrisisHelper
{
	/* ============================================================
	 *  CONSTANTES
	 * ============================================================ */

	// Regla ×2 centralizada (por coherencia con PVPHelper/PVEHelper)
	const UNTX_MULTIPLIER = 2;

	// Rieles válidos
	const RIELS = array('CUP', 'QVAPAY');

	const FACTIONS = array(
		1 => 'Piratas',
		2 => 'Aliens',
		3 => 'Máquinas',
		4 => 'Fantasmas',
	);

	const DIFFICULTY = array(
		1 => array('name' => 'Principiante', 'min' => 0,          'max' => 10000,      'mult' => 1),
		2 => array('name' => 'Intermedio',   'min' => 10000,      'max' => 100000,     'mult' => 3),
		3 => array('name' => 'Avanzado',     'min' => 100000,     'max' => 1000000,    'mult' => 6),
		4 => array('name' => 'Élite',        'min' => 1000000,    'max' => 10000000,   'mult' => 10),
		5 => array('name' => 'Legendario',   'min' => 10000000,   'max' => PHP_INT_MAX,'mult' => 20),
	);


	/* ============================================================
	 *  CREAR UNA CRISIS PROGRAMADA
	 * ============================================================ */

	public static function scheduleCrisis($startTime = null, $wavesCount = null)
	{
		$db = Database::get();

		$startTime  = $startTime ?: PVEHelper::getNextEventTime('crisis');
		$wavesCount = $wavesCount ?: (int) PVEHelper::get('crisis_waves', 5);
		$duration   = (int) PVEHelper::get('crisis_duration_hours', 24) * 3600;
		$faction    = (int) PVEHelper::get('crisis_faction_current', 1);

		$sql = "SELECT id FROM %%PVE_CRISIS%%
				WHERE start_time = :startTime
				  AND status IN ('scheduled','active')
				LIMIT 1;";
		$rowExisting = $db->selectSingle($sql, array(':startTime' => $startTime));
		if (!empty($rowExisting['id'])) {
			return (int) $rowExisting['id'];
		}

		$sql = "INSERT INTO %%PVE_CRISIS%% SET
			faction      = :faction,
			total_waves  = :waves,
			current_wave = 0,
			start_time   = :startTime,
			end_time     = :endTime,
			status       = 'scheduled',
			created_at   = :now;";

		$db->insert($sql, array(
			':faction'   => $faction,
			':waves'     => $wavesCount,
			':startTime' => $startTime,
			':endTime'   => $startTime + $duration,
			':now'       => TIMESTAMP,
		));

		$crisisId = (int) $db->lastInsertId();

		if ($crisisId <= 0) {
			PVEHelper::log('crisis', 0, 'schedule_error', 0, 0, array(
				'reason' => 'lastInsertId_empty_after_insert',
			));
			return 0;
		}

		try {
			self::generateWaves($crisisId, $wavesCount, $faction);
			self::rotateFaction();

			PVEHelper::log('crisis', $crisisId, 'scheduled', 0, 0, array(
				'faction' => $faction,
				'waves'   => $wavesCount,
				'start'   => $startTime,
				'end'     => $startTime + $duration,
			));
			PVEHelper::clearConfigCache();
		} catch (Exception $e) {
			PVEHelper::log('crisis', $crisisId, 'schedule_partial_error', 0, 0, array(
				'error' => $e->getMessage(),
				'file'  => $e->getFile(),
				'line'  => $e->getLine(),
			));
			// No relanzamos: la crisis quedó creada, el cron podrá crear waves
			// con el fallback de executeNextWave().
		}

		return $crisisId;
	}


	private static function generateWaves($crisisId, $count, $faction)
	{
		$db = Database::get();

		for ($i = 1; $i <= $count; $i++) {
			$powerMult = 1.0 + (($i - 1) * 0.15);

			$sql = "INSERT INTO %%PVE_CRISIS_WAVES%% SET
				crisis_id              = :crisisId,
				wave_number            = :wave,
				faction                = :faction,
				power_multiplier       = :mult,
				ships_count            = 0,
				executed               = 0,
				executed_at            = 0,
				total_damage_done      = 0,
				total_resources_stolen = 0;";

			$db->insert($sql, array(
				':crisisId' => $crisisId,
				':wave'     => $i,
				':faction'  => $faction,
				':mult'     => $powerMult,
			));

			$waveId = (int) $db->lastInsertId();

			if ($waveId <= 0) {
				PVEHelper::log('crisis', $crisisId, 'wave_generation_error', 0, 0, array(
					'wave_number' => $i,
					'reason'      => 'lastInsertId_empty',
				));
			}
		}

		PVEHelper::log('crisis', $crisisId, 'waves_generated', 0, 0, array(
			'count' => $count,
		));
	}


	private static function rotateFaction()
	{
		$db     = Database::get();
		$actual = (int) PVEHelper::get('crisis_faction_current', 1);
		$next   = $actual >= 4 ? 1 : $actual + 1;

		$sql = "UPDATE %%PVE_CONFIG%%
				SET config_value = :next, updated_at = :now
				WHERE config_key = 'crisis_faction_current';";
		$db->update($sql, array(':next' => $next, ':now' => TIMESTAMP));

		PVEHelper::log('crisis', 0, 'faction_rotated', 0, 0, array(
			'from' => $actual,
			'to'   => $next,
		));
	}


	/* ============================================================
	 *  EJECUTAR UNA OLEADA (ahora crea FLOTAS REALES)
	 * ============================================================ */

	public static function executeNextWave($crisisId)
	{
		$db = Database::get();
		$crisisId = (int) $crisisId;

		if ($crisisId <= 0) {
			return 0;
		}

		$affected = 0;

		// ─── 1) Lock atómico ───────────────────────────────────
		$sql = "UPDATE %%PVE_CRISIS%%
				SET processing = 1
				WHERE id = :id AND processing = 0 AND status IN ('scheduled','active');";
		$db->update($sql, array(':id' => $crisisId));

		// ─── 2) Verificar lock vía SELECT (más fiable que rowCount) ───
		$lockRow = $db->selectSingle(
			"SELECT processing FROM %%PVE_CRISIS%% WHERE id = :id;",
			array(':id' => $crisisId)
		);
		$locked = !empty($lockRow) ? (int) $lockRow['processing'] : 0;

		if ($locked !== 1) {
			PVEHelper::log('crisis', $crisisId, 'execute_skip_locked', 0, 0, array(
				'processing' => $locked,
			));
			return 0;
		}

		try {
			$sql = "SELECT * FROM %%PVE_CRISIS%% WHERE id = :id;";
			$crisis = $db->selectSingle($sql, array(':id' => $crisisId));

			if (empty($crisis)) {
				PVEHelper::log('crisis', $crisisId, 'execute_crisis_not_found', 0, 0, null);
				return 0;
			}

			if ($crisis['status'] === 'scheduled') {
				$db->update(
					"UPDATE %%PVE_CRISIS%% SET status = 'active' WHERE id = :id;",
					array(':id' => $crisisId)
				);
				$crisis['status'] = 'active';

				PVEHelper::log('crisis', $crisisId, 'activated', 0, 0, null);
			}

			// ¿Ya se enviaron todas las oleadas? → intentar finalizar
			if ((int) $crisis['current_wave'] >= (int) $crisis['total_waves']) {
				self::tryFinishCrisis($crisisId);
				return 0;
			}

			$nextWave = (int) $crisis['current_wave'] + 1;

			$sql = "SELECT * FROM %%PVE_CRISIS_WAVES%%
					WHERE crisis_id = :crisisId AND wave_number = :wave
					LIMIT 1;";
			$wave = $db->selectSingle($sql, array(
				':crisisId' => $crisisId,
				':wave'     => $nextWave,
			));

			// ─── Fallback: crear wave al vuelo ─────────────────
			if (empty($wave)) {
				$powerMult = 1.0 + (($nextWave - 1) * 0.15);

				$sql = "INSERT INTO %%PVE_CRISIS_WAVES%% SET
					crisis_id              = :crisisId,
					wave_number            = :wave,
					faction                = :faction,
					power_multiplier       = :mult,
					ships_count            = 0,
					executed               = 0,
					executed_at            = 0,
					total_damage_done      = 0,
					total_resources_stolen = 0;";

				$db->insert($sql, array(
					':crisisId' => $crisisId,
					':wave'     => $nextWave,
					':faction'  => $crisis['faction'],
					':mult'     => $powerMult,
				));

				$waveId = (int) $db->lastInsertId();

				PVEHelper::log('crisis', $crisisId, 'wave_created_fallback', 0, 0, array(
					'wave_number' => $nextWave,
					'wave_id'     => $waveId,
				));

				$wave = array(
					'id'               => $waveId,
					'crisis_id'        => $crisisId,
					'wave_number'      => $nextWave,
					'faction'          => $crisis['faction'],
					'power_multiplier' => $powerMult,
					'executed'         => 0,
					'executed_at'      => 0,
				);
			}

			// ─── Crear FLOTAS REALES ──────────────────────────
			$affected = self::sendWaveFleets($crisis, $wave);

			PVEHelper::log('crisis', $crisisId, 'wave_fleets_sent', 0, 0, array(
				'wave_number' => $nextWave,
				'affected'    => $affected,
			));

			// ─── Marcar wave como enviada ─────────────────────
			$sql = "UPDATE %%PVE_CRISIS_WAVES%% SET
				executed    = 1,
				executed_at = :now,
				ships_count = :ships
				WHERE id = :id;";
			$db->update($sql, array(
				':id'    => $wave['id'],
				':now'   => TIMESTAMP,
				':ships' => $affected,
			));

			// ─── Avanzar oleada ───────────────────────────────
			$sql = "UPDATE %%PVE_CRISIS%%
					SET current_wave = :wave,
					    players_affected = players_affected + :affected
					WHERE id = :id;";
			$db->update($sql, array(
				':wave'     => $nextWave,
				':affected' => $affected,
				':id'       => $crisisId,
			));

			PVEHelper::log('crisis', $crisisId, 'wave_executed', 0, 0, array(
				'wave'     => $nextWave,
				'affected' => $affected,
			));

			if ($nextWave >= (int) $crisis['total_waves']) {
				PVEHelper::log('crisis', $crisisId, 'all_waves_scheduled', 0, 0, array(
					'players' => $affected,
				));
			}
		} catch (Exception $e) {
			PVEHelper::log('crisis', $crisisId, 'execute_wave_error', 0, 0, array(
				'error' => $e->getMessage(),
				'file'  => $e->getFile(),
				'line'  => $e->getLine(),
			));
			throw $e;
		} finally {
			self::unlock($crisisId);
		}

		return $affected;
	}


	/**
	 * Envía una flota pirata a cada jugador elegible.
	 *
	 * v2.7 — Excluye fantasmas (is_pve = 1) como objetivos
	 */
	private static function sendWaveFleets($crisis, $wave)
	{
		global $reslist, $resource, $pricelist;

		$db = Database::get();

		// ✅ Excluir fantasmas (is_pve = 1) de los objetivos de Crisis
		$sql = "SELECT u.id AS user_id, u.username, u.urlaubs_modus, u.bana,
		               p.id AS planet_id, p.galaxy, p.system, p.planet, p.planet_type
				FROM %%USERS%% u
				INNER JOIN %%PLANETS%% p ON p.id_owner = u.id
				WHERE p.planet_type = 1
				  AND p.destruyed = 0
				  AND u.urlaubs_modus = 0
				  AND u.bana = 0
				  AND u.authlevel < 3
				  AND (u.is_pve = 0 OR u.is_pve IS NULL);";

		$players = $db->select($sql);
		$affected = 0;

		if (empty($players)) {
			PVEHelper::log('crisis', $crisis['id'], 'wave_no_players', 0, 0, array(
				'wave' => $wave['wave_number'],
			));
			return 0;
		}

		$baseMult = (float) PVEHelper::get('crisis_base_mult', 30);
		if ($baseMult <= 0) $baseMult = 30;

		foreach ($players as $player) {
			try {
				$sql = "SELECT * FROM %%USERS%% WHERE id = :id;";
				$user = $db->selectSingle($sql, array(':id' => $player['user_id']));
				if (empty($user)) continue;

				$sqlPoints = "SELECT total_points FROM %%STATPOINTS%% 
				              WHERE id_owner = :uid AND stat_type = 1 AND universe = :uni";
				$totalPoints = $db->selectSingle($sqlPoints, array(
					':uid' => $user['id'],
					':uni' => $user['universe'],
				), 'total_points');
				$totalPoints = (int) $totalPoints;

				$sql = "SELECT * FROM %%PLANETS%% WHERE id = :id;";
				$planet = $db->selectSingle($sql, array(':id' => $player['planet_id']));
				if (empty($planet)) continue;

				$difficulty = self::getDifficultyLevel($totalPoints);
				$levelMult  = self::DIFFICULTY[$difficulty]['mult'];

				// Multiplicador final = base (30) × nivel (1-20) × wave (1-1.75)
				$totalMult = $baseMult * $levelMult * (float) $wave['power_multiplier'];

				$enemyFleet = self::buildEnemyFleetForPlayer($planet, $totalMult);

				if (empty($enemyFleet)) {
					continue;
				}

				// ✅ Enviar flota REAL
				$fleetId = PveFleetHelper::sendCrisisFleet(
					$crisis['id'],
					$wave['id'],
					$planet,
					$enemyFleet
				);

				if (!empty($fleetId)) {
					// Trackear crisis_id en la flota
					$db->update(
						"UPDATE %%FLEETS%% SET fleet_target_obj = :cid WHERE fleet_id = :fid;",
						array(':cid' => (int) $crisis['id'], ':fid' => (int) $fleetId)
					);

					$affected++;
				}
			} catch (Exception $e) {
				PVEHelper::log('crisis', $crisis['id'], 'wave_send_error', $player['user_id'], $player['planet_id'], array(
					'error' => $e->getMessage(),
					'wave'  => $wave['wave_number'],
				));
			}
		}

		return $affected;
	}


	/**
	 * Construye la flota pirata proporcional al planeta del jugador.
	 * Usa el multiplicador total calculado externamente.
	 */
	private static function buildEnemyFleetForPlayer($planet, $totalMult)
	{
		global $reslist, $resource, $pricelist;

		$defenseValue = 0;
		foreach (array_merge($reslist['fleet'], $reslist['defense']) as $elementId) {
			$colName = $resource[$elementId];
			if (!empty($planet[$colName])) {
				$cost = (isset($pricelist[$elementId]['cost'][901]) ? $pricelist[$elementId]['cost'][901] : 0)
				      + (isset($pricelist[$elementId]['cost'][902]) ? $pricelist[$elementId]['cost'][902] : 0);
				$defenseValue += $planet[$colName] * $cost;
			}
		}

		if ($defenseValue <= 0) {
			return array();
		}

		$enemyBudget = $defenseValue * $totalMult;
		$enemyFleet  = array();
		$remaining   = $enemyBudget;

		// Pool incluye destructor y battleship para alta dificultad
		$shipPool = array(204, 206, 207, 211, 215, 213);

		foreach ($shipPool as $shipId) {
			if (!isset($pricelist[$shipId])) continue;

			$cost = (isset($pricelist[$shipId]['cost'][901]) ? $pricelist[$shipId]['cost'][901] : 0)
			      + (isset($pricelist[$shipId]['cost'][902]) ? $pricelist[$shipId]['cost'][902] : 0);
			if ($cost <= 0) continue;

			$maxCount = (int) floor($remaining * 0.5 / $cost);
			if ($maxCount > 0) {
				$enemyFleet[$shipId] = $maxCount;
				$remaining -= $maxCount * $cost;
			}
		}

		return array_filter($enemyFleet);
	}


	/* ============================================================
	 *  FINALIZAR CRISIS (solo cuando todas las flotas llegaron)
	 * ============================================================ */

	/**
	 * Comprueba si la crisis se puede finalizar.
	 * Condiciones:
	 *   - Todas las oleadas ejecutadas
	 *   - NO hay flotas con misión 20 en vuelo para esta crisis
	 *
	 * @return bool  true si la crisis fue finalizada
	 */
	public static function tryFinishCrisis($crisisId)
	{
		$db = Database::get();

		$sql = "SELECT * FROM %%PVE_CRISIS%% WHERE id = :id;";
		$crisis = $db->selectSingle($sql, array(':id' => $crisisId));

		if (empty($crisis)) {
			return false;
		}

		if ($crisis['status'] === 'finished') {
			return true;
		}

		// 1) ¿Todas las oleadas enviadas?
		if ((int) $crisis['current_wave'] < (int) $crisis['total_waves']) {
			return false;
		}

		// 2) ¿Hay flotas en vuelo?
		$sql = "SELECT COUNT(*) AS total 
		        FROM %%FLEETS%% 
		        WHERE fleet_mission = :mission 
		          AND fleet_target_obj = :cid 
		          AND fleet_mess = 0;";
		$row = $db->selectSingle($sql, array(
			':mission' => MISSION_PVE_CRISIS,
			':cid'     => $crisisId,
		));

		$inFlight = !empty($row['total']) ? (int) $row['total'] : 0;

		if ($inFlight > 0) {
			return false;
		}

		// 3) Finalizar
		return self::finishCrisis($crisisId);
	}


	/**
	 * v2.7 — Fix race condition + limpieza automática:
	 *   1) UPDATE atómico condicional (status != 'finished')
	 *   2) GUARD anti-duplicado: si ya existen rewards para esta crisis, skip
	 *   3) Solo si somos los primeros → grantRewards
	 *   4) cleanupFinishedCrisis() al final
	 *
	 * @return bool  true si la crisis quedó finalizada
	 */
	private static function finishCrisis($crisisId)
	{
		$db = Database::get();
		$crisisId = (int) $crisisId;

		if ($crisisId <= 0) {
			return false;
		}

		// ─── 1) UPDATE atómico condicional ─────────────────────
		$sql = "UPDATE %%PVE_CRISIS%% SET
			status   = 'finished',
			end_time = :now
			WHERE id = :id AND status != 'finished';";
		$db->update($sql, array(':id' => $crisisId, ':now' => TIMESTAMP));

		// ─── 2) Verificar que la crisis está finished ──────────
		$check = $db->selectSingle(
			"SELECT status FROM %%PVE_CRISIS%% WHERE id = :id;",
			array(':id' => $crisisId)
		);

		if (empty($check) || $check['status'] !== 'finished') {
			PVEHelper::log('crisis', $crisisId, 'finish_failed', 0, 0, array(
				'check_status' => !empty($check['status']) ? $check['status'] : 'null',
			));
			return false;
		}

		// ─── 3) GUARD anti-duplicado: ¿ya hay rewards? ────────
		$existing = $db->selectSingle(
			"SELECT COUNT(*) AS total FROM %%PVE_REWARDS%%
			 WHERE event_type = 'crisis' AND event_id = :cid;",
			array(':cid' => $crisisId)
		);

		$rewardsAlreadyGranted = !empty($existing) ? (int) $existing['total'] : 0;

		if ($rewardsAlreadyGranted > 0) {
			// Otro proceso ya finalizó y dio rewards → no duplicar
			PVEHelper::log('crisis', $crisisId, 'finish_skip_rewards_already_granted', 0, 0, array(
				'rewards_existing' => $rewardsAlreadyGranted,
			));

			// Igual limpiamos (por si acaso)
			self::cleanupFinishedCrisis($crisisId);
			return true;
		}

		// ─── 4) Somos los primeros → dar recompensas ──────────
		self::grantRewards($crisisId);

		PVEHelper::log('crisis', $crisisId, 'finished', 0, 0, array(
			'rewards_granted_by_this_call' => 1,
		));

		// ─── 5) Limpieza inmediata ─────────────────────────
		self::cleanupFinishedCrisis($crisisId);

		return true;
	}


	/**
	 * Otorga recompensas a los supervivientes Y actualiza sus logros.
	 *
	 * v2.7 — Lee la configuración:
	 *   - crisis_reward_type      → 'ntx' | 'resources'
	 *   - crisis_reward_ntx       → int (cantidad NTX-20 BASE)
	 *   - crisis_reward_metal     → bigint
	 *   - crisis_reward_crystal   → bigint
	 *   - crisis_reward_deuterium → bigint
	 *   - crisis_reward_split     → 'per_player' | 'shared'
	 *
	 * v2.9 — ARQUITECTURA DOBLE RIEL (NTX-20 / UNTX-20):
	 *
	 *   Este método NO acredita saldo al jugador. Solo INSERTA registros
	 *   en `uni1_pve_rewards` con el monto en **BASE NTX-20**.
	 *
	 *   El ×2 para jugadores QVAPAY se aplica DESPUÉS, cuando el jugador
	 *   reclama la recompensa en `PVEHelper::claimAllRewards()` v2.0:
	 *
	 *     - reward_type = 'ntx':
	 *         base = N (guardado en reward_data JSON)
	 *         CUP    → acredita N en `uni1_users.ntx20`
	 *         QVAPAY → acredita N × 2 en `uni1_users.untx20`
	 *
	 *   Esta separación es intencional: permite que el mismo reward base
	 *   se entregue al riel correcto en función del `metodo_retiro` del
	 *   jugador en el momento del reclamo, sin tener que duplicar filas
	 *   en la BD para CUP y QVAPAY.
	 *
	 *   Regla de oro respetada: el jugador NUNCA ve la moneda del otro
	 *   riel. El template mostrará `{$reward.amount_real} {$reward.moneda}`
	 *   (ya calculados por PVEHelper::getPendingRewards()).
	 */
	private static function grantRewards($crisisId)
	{
		$db = Database::get();

		// ─── 1) Leer configuración de recompensa (en BASE NTX-20) ─
		$rewardType = strtolower(trim((string) PVEHelper::get('crisis_reward_type', 'ntx')));
		if ($rewardType !== 'resources') {
			$rewardType = 'ntx'; // fallback seguro
		}

		$rewardNtx       = (int)    PVEHelper::get('crisis_reward_ntx', 5);
		$rewardMetal     = (int)    PVEHelper::get('crisis_reward_metal', 0);
		$rewardCrystal   = (int)    PVEHelper::get('crisis_reward_crystal', 0);
		$rewardDeuterium = (int)    PVEHelper::get('crisis_reward_deuterium', 0);

		$split = strtolower(trim((string) PVEHelper::get('crisis_reward_split', 'per_player')));
		if ($split !== 'shared') {
			$split = 'per_player'; // fallback seguro
		}

		// ─── 2) Cargar supervivientes ─────────────────────────────
		$sql = "SELECT DISTINCT user_id
				FROM %%PVE_CRISIS_ATTACKS%%
				WHERE crisis_id = :crisisId AND survived = 1;";
		$survivors = $db->select($sql, array(':crisisId' => $crisisId));

		if (empty($survivors)) {
			return;
		}

		if (!class_exists('PVEAchievementHelper')) {
			$achFile = ROOT_PATH.'includes/classes/PVEAchievementHelper.class.php';
			if (file_exists($achFile)) {
				require_once $achFile;
			}
		}

		$crisisEndTime = TIMESTAMP;
		$survivorCount = count($survivors);

		// ─── 3) Calcular divisor según modo de reparto ────────────
		// per_player → cada uno recibe el total (divisor = 1)
		// shared     → se divide entre todos   (divisor = N)
		$divisor = ($split === 'shared') ? max(1, $survivorCount) : 1;

		// ─── 4) Repartir a cada superviviente ─────────────────────
		foreach ($survivors as $row) {
			$userId = (int) $row['user_id'];

			// Construir reward_data según tipo
			// ⚠️ SIEMPRE en BASE NTX-20 (sin multiplicador).
			//    El ×2 para QVAPAY se aplica al reclamar en
			//    PVEHelper::claimAllRewards().
			if ($rewardType === 'ntx') {
				$amount = (int) floor($rewardNtx / $divisor);

				if ($amount <= 0) {
					// Si el divisor deja a 0 NTX, saltar este jugador
					// (evita rewards vacíos). Se registra en log.
					PVEHelper::log('crisis', $crisisId, 'reward_skipped', $userId, 0, array(
						'reason'    => 'ntx_amount_zero_after_split',
						'base_ntx'  => $rewardNtx,
						'divisor'   => $divisor,
					));
					continue;
				}

				$insertType = 'ntx';
				$insertData = json_encode(array(
					'amount'     => $amount,       // BASE NTX-20
					'type'       => 'survival',
					'split'      => $split,
					'riel_base'  => 'NTX-20',      // doc: el base vive en NTX-20
				));

			} else { // resources
				$metal     = (int) floor($rewardMetal     / $divisor);
				$crystal   = (int) floor($rewardCrystal   / $divisor);
				$deuterium = (int) floor($rewardDeuterium / $divisor);

				if (($metal + $crystal + $deuterium) <= 0) {
					PVEHelper::log('crisis', $crisisId, 'reward_skipped', $userId, 0, array(
						'reason'   => 'resources_total_zero_after_split',
						'divisor'  => $divisor,
					));
					continue;
				}

				$insertType = 'resources';
				$insertData = json_encode(array(
					'metal'     => $metal,
					'crystal'   => $crystal,
					'deuterium' => $deuterium,
					'type'      => 'survival',
					'split'     => $split,
				));
			}

			// ─── Insertar recompensa pendiente ────────────────────
			$sql = "INSERT INTO %%PVE_REWARDS%% SET
				user_id     = :userId,
				event_type  = 'crisis',
				event_id    = :eventId,
				reward_type = :rewardType,
				reward_data = :data,
				claimed     = 0,
				created_at  = :now;";

			$db->insert($sql, array(
				':userId'     => $userId,
				':eventId'    => $crisisId,
				':rewardType' => $insertType,
				':data'       => $insertData,
				':now'        => TIMESTAMP,
			));

			// ─── Logros ───────────────────────────────────────────
			if (class_exists('PVEAchievementHelper')) {
				try {
					PVEAchievementHelper::recordSurvival($userId, $crisisEndTime);
				} catch (Exception $e) {
					PVEHelper::log('crisis', $crisisId, 'achievement_record_error', $userId, 0, array(
						'error' => $e->getMessage(),
					));
				}
			}
		}
	}


	/* ============================================================
	 *  LIMPIEZA AUTOMÁTICA — CAPA 1 (inmediata)
	 * ============================================================ */

	/**
	 * Limpieza inmediata al finalizar una crisis.
	 * Se llama desde finishCrisis().
	 *
	 * Qué borra:
	 *   - Flotas pirata huérfanas de esta crisis (mission=20, target_obj=cid)
	 *   - fleet_event huérfanos (sin flota)
	 *   - Si keep_history = 0:
	 *       - Waves de esta crisis
	 *       - Ataques de esta crisis
	 *
	 * @param int $crisisId
	 * @return array Stats de limpieza
	 */
	public static function cleanupFinishedCrisis($crisisId)
	{
		$db = Database::get();
		$crisisId = (int) $crisisId;

		$stats = array(
			'fleets_deleted' => 0,
			'events_deleted' => 0,
			'waves_deleted'  => 0,
			'attacks_deleted'=> 0,
		);

		if ($crisisId <= 0) {
			return $stats;
		}

		// ¿Está activada la limpieza inmediata?
		$enabled = (int) PVEHelper::get('crisis_cleanup_immediate', 1);
		if ($enabled !== 1) {
			return $stats;
		}

		$keepHistory = (int) PVEHelper::get('crisis_cleanup_keep_history', 0) === 1;

		try {
			// 1) Flotas pirata huérfanas de esta crisis
			$db->delete(
				"DELETE FROM %%FLEETS%% 
				 WHERE fleet_mission = :mission 
				   AND fleet_target_obj = :cid;",
				array(
					':mission' => MISSION_PVE_CRISIS,
					':cid'     => $crisisId,
				)
			);
			$stats['fleets_deleted'] = $db->rowCount();

			// 2) fleet_event huérfanos (sin flota correspondiente)
			$db->delete(
				"DELETE fe FROM %%FLEETS_EVENT%% fe
				 LEFT JOIN %%FLEETS%% f ON f.fleet_id = fe.fleetID
				 WHERE f.fleet_id IS NULL"
			);
			$stats['events_deleted'] = $db->rowCount();

			// 3) Waves y ataques — solo si NO se guarda historial
			if (!$keepHistory) {
				$db->delete(
					"DELETE FROM %%PVE_CRISIS_WAVES%% WHERE crisis_id = :cid;",
					array(':cid' => $crisisId)
				);
				$stats['waves_deleted'] = $db->rowCount();

				$db->delete(
					"DELETE FROM %%PVE_CRISIS_ATTACKS%% WHERE crisis_id = :cid;",
					array(':cid' => $crisisId)
				);
				$stats['attacks_deleted'] = $db->rowCount();
			}

			PVEHelper::log('crisis', $crisisId, 'cleanup_immediate_done', 0, 0, array_merge($stats, array(
				'keep_history' => $keepHistory ? 1 : 0,
			)));

		} catch (Exception $e) {
			PVEHelper::log('crisis', $crisisId, 'cleanup_immediate_error', 0, 0, array(
				'error' => $e->getMessage(),
				'file'  => $e->getFile(),
				'line'  => $e->getLine(),
			));
		}

		return $stats;
	}


	/* ============================================================
	 *  LIMPIEZA AUTOMÁTICA — CAPA 2 (periódica, cada 5 min)
	 * ============================================================ */

	/**
	 * Limpieza periódica de residuos huérfanos.
	 * Se llama desde ShowOverviewPage (cron cada 5 min).
	 *
	 * Qué limpia:
	 *   - Flotas pirata huérfanas (end_time < now-1h, sin llegar)
	 *   - fleet_event huérfanos (sin flota)
	 *   - Waves sin crisis válida (huérfanas)
	 *   - Crisis zombie (end_time < now, sin flotas)
	 *   - Imperios expirados sin destruir (end_time < now)
	 *   - Ataques a imperios huérfanos (empire_id no existe)
	 *   - Invitaciones ACS rechazadas/expiradas viejas
	 *
	 * @return array Stats de limpieza
	 */
	public static function cleanupOrphans()
	{
		$db = Database::get();

		$stats = array(
			'fleets_deleted'         => 0,
			'events_deleted'         => 0,
			'waves_deleted'          => 0,
			'crisis_closed'          => 0,
			'empires_expired'        => 0,
			'empire_attacks_deleted' => 0,
			'acs_invites_deleted'    => 0,
		);

		// ¿Está activada la limpieza periódica?
		$enabled = (int) PVEHelper::get('crisis_cleanup_orphans', 1);
		if ($enabled !== 1) {
			return $stats;
		}

		try {
			// ═══════════════════════════════════════════════
			// 1) FLOTAS PIRATA HUÉRFANAS (mission=20)
			// ═══════════════════════════════════════════════
			$limitTime = TIMESTAMP - 3600; // 1h de margen

			$db->delete(
				"DELETE FROM %%FLEETS%%
				 WHERE fleet_mission = :mission
				   AND fleet_end_time < :limit
				   AND fleet_mess = 0;",
				array(
					':mission' => MISSION_PVE_CRISIS,
					':limit'   => $limitTime,
				)
			);
			$stats['fleets_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 2) FLEET_EVENT HUÉRFANOS
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE fe FROM %%FLEETS_EVENT%% fe
				 LEFT JOIN %%FLEETS%% f ON f.fleet_id = fe.fleetID
				 WHERE f.fleet_id IS NULL"
			);
			$stats['events_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 3) WAVES SIN CRISIS VÁLIDA
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE w FROM %%PVE_CRISIS_WAVES%% w
				 LEFT JOIN %%PVE_CRISIS%% c ON c.id = w.crisis_id
				 WHERE c.id IS NULL"
			);
			$stats['waves_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 4) CRISIS ZOMBIE
			// ═══════════════════════════════════════════════
			$zombies = $db->select(
				"SELECT c.id FROM %%PVE_CRISIS%% c
				 WHERE c.status = 'active'
				   AND c.end_time <= :now
				   AND c.processing = 0
				   AND NOT EXISTS (
				       SELECT 1 FROM %%FLEETS%% f
				       WHERE f.fleet_mission = :mission
				         AND f.fleet_target_obj = c.id
				         AND f.fleet_mess = 0
				   )
				 LIMIT 10;",
				array(
					':now'     => TIMESTAMP,
					':mission' => MISSION_PVE_CRISIS,
				)
			);

			if (!empty($zombies)) {
				foreach ($zombies as $z) {
					$zid = (int) $z['id'];
					$db->update(
						"UPDATE %%PVE_CRISIS%% 
						 SET status = 'finished', processing = 0 
						 WHERE id = :id AND status = 'active';",
						array(':id' => $zid)
					);

					if ($db->rowCount() > 0) {
						$stats['crisis_closed']++;
						PVEHelper::log('crisis', $zid, 'cleanup_zombie_closed', 0, 0, null);

						// Limpieza inmediata de esa crisis zombie
						self::cleanupFinishedCrisis($zid);
					}
				}
			}

			// ═══════════════════════════════════════════════
			// 5) IMPERIOS EXPIRADOS SIN DESTRUIR
			// ═══════════════════════════════════════════════
			$expiredEmpires = $db->select(
				"SELECT id FROM %%PVE_EMPIRES%%
				 WHERE status = 'active'
				   AND end_time <= :now
				 LIMIT 10;",
				array(':now' => TIMESTAMP)
			);

			if (!empty($expiredEmpires)) {
				foreach ($expiredEmpires as $emp) {
					$eid = (int) $emp['id'];

					// Intentar destruir el fantasma si existe
					if (class_exists('PVEGhostHelper')) {
						try {
							PVEGhostHelper::destroyGhost($eid, 'empire');
						} catch (Throwable $e) {
							// Silencioso
						}
					}

					$db->update(
						"UPDATE %%PVE_EMPIRES%% 
						 SET status = 'expired', destroyed_at = :now 
						 WHERE id = :id AND status = 'active';",
						array(':now' => TIMESTAMP, ':id' => $eid)
					);

					if ($db->rowCount() > 0) {
						$stats['empires_expired']++;
						PVEHelper::log('empire', $eid, 'cleanup_expired', 0, 0, null);
					}
				}
			}

			// ═══════════════════════════════════════════════
			// 6) ATAQUES A IMPERIOS HUÉRFANOS
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE ea FROM %%PVE_EMPIRE_ATTACKS%% ea
				 LEFT JOIN %%PVE_EMPIRES%% e ON e.id = ea.empire_id
				 WHERE e.id IS NULL"
			);
			$stats['empire_attacks_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 7) INVITACIONES ACS RECHAZADAS/EXPIRADAS
			// ═══════════════════════════════════════════════
			$acsLimit = TIMESTAMP - (7 * 86400); // 7 días

			$db->delete(
				"DELETE FROM %%PVE_ACS_INVITES%%
				 WHERE status IN ('rejected','accepted')
				   AND created_at < :limit",
				array(':limit' => $acsLimit)
			);
			$stats['acs_invites_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// LOG (solo si hubo algo que limpiar)
			// ═══════════════════════════════════════════════
			$total = array_sum($stats);
			if ($total > 0) {
				PVEHelper::log('cron', 0, 'cleanup_orphans', 0, 0, $stats);
			}

		} catch (Exception $e) {
			PVEHelper::log('cron', 0, 'cleanup_orphans_error', 0, 0, array(
				'error' => $e->getMessage(),
				'file'  => $e->getFile(),
				'line'  => $e->getLine(),
			));
		}

		return $stats;
	}


	/* ============================================================
	 *  LIMPIEZA AUTOMÁTICA — CAPA 3 (profunda, 1 vez al día)
	 * ============================================================ */

	/**
	 * Limpieza profunda de datos viejos.
	 * Se llama desde ShowOverviewPage (1 vez al día).
	 *
	 * Qué limpia:
	 *   - Logs antiguos (>X días)
	 *   - Crisis terminadas hace mucho (>7 días)
	 *   - Recompensas no reclamadas antiguas (>X días)
	 *   - Imperios destruidos/expirados viejos (>7 días)
	 *   - Ataques a imperios viejos (>30 días)
	 *   - Invitaciones ACS viejas (>30 días)
	 *
	 * @param bool $forceRun  Si true, ignora el cache de 24h
	 * @return array Stats de limpieza
	 */
	public static function cleanupDeep($forceRun = false)
	{
		$db = Database::get();

		$stats = array(
			'logs_deleted'            => 0,
			'crisis_deleted'          => 0,
			'rewards_expired'         => 0,
			'empires_deleted'         => 0,
			'empire_attacks_deleted'  => 0,
			'acs_invites_deleted'     => 0,
		);

		// ¿Está activada la limpieza profunda?
		$enabled = (int) PVEHelper::get('crisis_cleanup_deep', 1);
		if ($enabled !== 1 && !$forceRun) {
			return $stats;
		}

		// Cache de 24h para no ejecutarla en cada request
		$cacheKey = 'pve_cleanup_deep_last';
		$lastRun  = isset($_SESSION[$cacheKey]) ? (int) $_SESSION[$cacheKey] : 0;

		if (!$forceRun && (TIMESTAMP - $lastRun) < 86400) {
			return $stats; // aún no toca
		}

		$logDays     = max(1, (int) PVEHelper::get('crisis_cleanup_log_after_days', 30));
		$rewardsDays = max(1, (int) PVEHelper::get('crisis_cleanup_rewards_after_days', 7));
		$crisisDays  = 7;   // crisis finalizadas hace más de 7 días → borrar
		$empireDays  = 7;   // imperios destruidos hace más de 7 días → borrar
		$attackDays  = 30;  // ataques viejos (>30 días) → borrar
		$acsDays     = 30;  // invitaciones viejas (>30 días) → borrar

		try {
			// ═══════════════════════════════════════════════
			// 1) LOGS ANTIGUOS
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE FROM %%PVE_LOG%% WHERE created_at < :limit;",
				array(':limit' => TIMESTAMP - ($logDays * 86400))
			);
			$stats['logs_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 2) CRISIS TERMINADAS HACE MUCHO
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE FROM %%PVE_CRISIS%% 
				 WHERE status = 'finished' 
				   AND end_time < :limit;",
				array(':limit' => TIMESTAMP - ($crisisDays * 86400))
			);
			$stats['crisis_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 3) RECOMPENSAS NO RECLAMADAS ANTIGUAS → expirar
			// ═══════════════════════════════════════════════
			$db->update(
				"UPDATE %%PVE_REWARDS%% 
				 SET claimed = 1, claimed_at = :now
				 WHERE claimed = 0 
				   AND created_at < :limit;",
				array(
					':now'   => TIMESTAMP,
					':limit' => TIMESTAMP - ($rewardsDays * 86400),
				)
			);
			$stats['rewards_expired'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 4) IMPERIOS DESTRUIDOS/EXPIRADOS VIEJOS
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE FROM %%PVE_EMPIRES%%
				 WHERE status IN ('destroyed','expired')
				   AND end_time < :limit;",
				array(':limit' => TIMESTAMP - ($empireDays * 86400))
			);
			$stats['empires_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 5) ATAQUES A IMPERIOS VIEJOS
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE FROM %%PVE_EMPIRE_ATTACKS%%
				 WHERE attack_time < :limit;",
				array(':limit' => TIMESTAMP - ($attackDays * 86400))
			);
			$stats['empire_attacks_deleted'] = $db->rowCount();

			// ═══════════════════════════════════════════════
			// 6) INVITACIONES ACS VIEJAS
			// ═══════════════════════════════════════════════
			$db->delete(
				"DELETE FROM %%PVE_ACS_INVITES%%
				 WHERE created_at < :limit;",
				array(':limit' => TIMESTAMP - ($acsDays * 86400))
			);
			$stats['acs_invites_deleted'] = $db->rowCount();

			// Guardar timestamp de última ejecución
			$_SESSION[$cacheKey] = TIMESTAMP;

			PVEHelper::log('cron', 0, 'cleanup_deep_done', 0, 0, $stats);

		} catch (Exception $e) {
			PVEHelper::log('cron', 0, 'cleanup_deep_error', 0, 0, array(
				'error' => $e->getMessage(),
				'file'  => $e->getFile(),
				'line'  => $e->getLine(),
			));
		}

		return $stats;
	}


	/* ============================================================
	 *  HELPERS
	 * ============================================================ */

	public static function getDifficultyLevel($points)
	{
		foreach (self::DIFFICULTY as $level => $data) {
			if ($points >= $data['min'] && $points < $data['max']) {
				return $level;
			}
		}
		return 5;
	}


	private static function unlock($crisisId)
	{
		$db = Database::get();
		$sql = "UPDATE %%PVE_CRISIS%% SET processing = 0 WHERE id = :id;";
		$db->update($sql, array(':id' => $crisisId));
	}


	/* ============================================================
	 *  AUTO-PROGRAMACIÓN MENSUAL (v2.8)
	 * ============================================================ */

	/**
	 * Auto-programa una crisis si corresponde.
	 * Llamado desde ShowOverviewPage (bloque PVE del cron cada 5 min).
	 *
	 * Flujo:
	 *   1) ¿Está activado el toggle crisis_auto_schedule_enabled?
	 *      → NO → return false
	 *   2) ¿Hay ya una crisis scheduled/active?
	 *      → SÍ → return false (no duplicar)
	 *   3) ¿Ya se programó este mes? (via crisis_auto_schedule_last_month)
	 *      → SÍ → return false
	 *   4) ¿Estamos en/pasado el día+hora configurados?
	 *      → NO → return false
	 *   5) Crear crisis con startTime = TIMESTAMP (arranca en este ciclo)
	 *   6) Marcar el mes como "ya programado" (YYYYMM)
	 *   7) Registrar en log
	 *
	 * @return bool  true si se programó una crisis nueva
	 */
	public static function autoScheduleIfNeeded(): bool
	{
		// ─── 1) ¿Toggle activado? ───
		if ((int) PVEHelper::get('crisis_auto_schedule_enabled', 1) !== 1) {
			return false;
		}

		// ─── 2) ¿Ya hay una scheduled o active? ───
		$db = Database::get();
		$existing = $db->selectSingle(
			"SELECT id FROM %%PVE_CRISIS%%
			 WHERE status IN ('scheduled','active')
			 LIMIT 1;"
		);
		if (!empty($existing)) {
			return false;
		}

		// ─── 3) Leer config ───
		$day    = (int) PVEHelper::get('crisis_day', 25);
		$hour   = (int) PVEHelper::get('crisis_hour', 10);
		$minute = (int) PVEHelper::get('crisis_minute', 30);
		$waves  = (int) PVEHelper::get('crisis_waves', 5);

		$day    = max(1, min(28, $day));
		$hour   = max(0, min(23, $hour));
		$minute = max(0, min(59, $minute));

		// ─── 4) ¿Ya se programó este mes? ───
		$currentYearMonth = (int) date('Ym', TIMESTAMP);   // ej: 202610
		$lastMonth        = (int) PVEHelper::get('crisis_auto_schedule_last_month', 0);

		if ($lastMonth === $currentYearMonth) {
			return false;
		}

		// ─── 5) ¿Estamos en/pasado el día+hora del mes? ───
		$scheduledTime = self::getScheduledTimeForCurrentMonth($day, $hour, $minute);
		if ($scheduledTime <= 0) {
			return false;
		}

		if (TIMESTAMP < $scheduledTime) {
			return false; // aún no toca
		}

		// ─── 6) Programar la crisis ───
		try {
			// startTime = TIMESTAMP → el cron la activará en este mismo ciclo
			$crisisId = self::scheduleCrisis(TIMESTAMP, $waves);

			if ($crisisId <= 0) {
				PVEHelper::log('cron', 0, 'crisis_auto_schedule_failed', 0, 0, array(
					'month' => $currentYearMonth,
					'day'   => $day,
					'hour'  => $hour,
					'min'   => $minute,
				));
				return false;
			}

			// ─── 7) Marcar el mes como ya programado ───
			self::markAsScheduledThisMonth($currentYearMonth);

			PVEHelper::log('cron', 0, 'crisis_auto_scheduled', $crisisId, 0, array(
				'month'     => $currentYearMonth,
				'day'       => $day,
				'hour'      => $hour,
				'minute'    => $minute,
				'waves'     => $waves,
				'scheduled' => date('Y-m-d H:i:s', $scheduledTime),
			));

			return true;
		} catch (Throwable $e) {
			PVEHelper::log('cron', 0, 'crisis_auto_schedule_error', 0, 0, array(
				'error' => $e->getMessage(),
				'file'  => $e->getFile(),
				'line'  => $e->getLine(),
			));
			return false;
		}
	}


	/**
	 * Calcula el timestamp de la fecha programada para el MES ACTUAL.
	 * (no busca el siguiente mes; si ya pasó, devuelve el del pasado)
	 *
	 * @param int $day    Día del mes (1-28)
	 * @param int $hour   Hora (0-23)
	 * @param int $minute Minuto (0-59)
	 * @return int  Timestamp o 0 si falla
	 */
	private static function getScheduledTimeForCurrentMonth(int $day, int $hour, int $minute): int
	{
		$day    = max(1, min(28, $day));
		$hour   = max(0, min(23, $hour));
		$minute = max(0, min(59, $minute));

		$year  = (int) date('Y', TIMESTAMP);
		$month = (int) date('n', TIMESTAMP);

		$ts = mktime($hour, $minute, 0, $month, $day, $year);

		return ($ts === false) ? 0 : (int) $ts;
	}


	/**
	 * Marca el mes actual como "ya programado".
	 * Guarda YYYYMM en `crisis_auto_schedule_last_month`.
	 *
	 * @param int $yearMonth  Formato YYYYMM (ej: 202610)
	 */
	private static function markAsScheduledThisMonth(int $yearMonth): void
	{
		$db = Database::get();

		$existing = $db->selectSingle(
			"SELECT id FROM %%PVE_CONFIG%%
			 WHERE config_key = 'crisis_auto_schedule_last_month'
			 LIMIT 1;"
		);

		if (!empty($existing)) {
			$db->update(
				"UPDATE %%PVE_CONFIG%%
				 SET config_value = :val, updated_at = :now
				 WHERE config_key = :key;",
				array(
					':val' => (string) $yearMonth,
					':now' => TIMESTAMP,
					':key' => 'crisis_auto_schedule_last_month',
				)
			);
		} else {
			$db->insert(
				"INSERT INTO %%PVE_CONFIG%% SET
					config_key   = :key,
					config_value = :val,
					updated_at   = :now;",
				array(
					':key' => 'crisis_auto_schedule_last_month',
					':val' => (string) $yearMonth,
					':now' => TIMESTAMP,
				)
			);
		}

		// Invalidar caché de config (para que la próxima lectura lea el valor actualizado)
		PVEHelper::clearConfigCache();
	}
}