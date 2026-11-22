<?php

/**
 * AstroIO — PVEAchievementHelper
 * Logros de supervivencia consecutiva + Logros del Torneo del Devorador + Logros del Bastión Asediado.
 *
 * v2.1 — Logros supervivencia + torneo + bastión (recompensas DM)
 *
 * v2.2 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Este helper entrega **Materia Oscura (DM)**, NO NTX-20/UNTX-20.
 *   · `grantAchievement()` hace `UPDATE uni1_users SET darkmatter = darkmatter + X`.
 *   · No hay `hasNtx20`, `removeNtx20`, `addNxt20`, `WalletHelper` ni `NTX20LogHelper`.
 *   · Por eso NO aplica la regla ×2 ni la detección de riel (CUP/QVAPAY).
 *   · La Materia Oscura es un recurso universal independiente del `metodo_retiro`.
 *   · Se añaden las constantes UNTX_MULTIPLIER y RIELS por coherencia con
 *     PVPHelper / PVEHelper / PVECrisisHelper / PVEEmpireHelper, aunque
 *     este archivo no las use funcionalmente.
 *   · Se documenta explícitamente en `grantAchievement()` por qué NO se toca
 *     NTX-20/UNTX-20 aquí (para evitar "arreglos" futuros innecesarios).
 *
 * Ubicación: includes/classes/PVEAchievementHelper.class.php
 * @package AstroIO
 * @version 2.2
 */

class PVEAchievementHelper
{
	/* ============================================================
	 *  CONSTANTES
	 * ============================================================ */

	// Regla ×2 centralizada (por coherencia con el resto de helpers)
	const UNTX_MULTIPLIER = 2;

	// Rieles válidos
	const RIELS = array('CUP', 'QVAPAY');

	const ACHIEVEMENTS = array(

		/* ===== SUPERVIVENCIA ===== */
		1 => array(
			'type'       => 'survival',
			'months'     => 1,
			'field_flag' => 'achievement_1m',
			'field_date' => 'achievement_1m_at',
			'label'      => 'Superviviente',
			'icon'       => '🥉',
			'color'      => '#cd7f32',
			'reward_dm'  => 100,
		),
		6 => array(
			'type'       => 'survival',
			'months'     => 6,
			'field_flag' => 'achievement_6m',
			'field_date' => 'achievement_6m_at',
			'label'      => 'Veterano',
			'icon'       => '🥈',
			'color'      => '#c0c0c0',
			'reward_dm'  => 800,
		),
		12 => array(
			'type'       => 'survival',
			'months'     => 12,
			'field_flag' => 'achievement_12m',
			'field_date' => 'achievement_12m_at',
			'label'      => 'Leyenda',
			'icon'       => '🥇',
			'color'      => '#ffd700',
			'reward_dm'  => 2500,
		),

		/* ===== TORNEO DEL DEVORADOR ===== */
		101 => array(
			'type'       => 'tournament',
			'counter'    => 'tournament_ghosts_killed',
			'target'     => 1,
			'field_flag' => 'achievement_hunter',
			'field_date' => 'achievement_hunter_at',
			'label'      => 'Cazador del Devorador',
			'icon'       => '👻',
			'color'      => '#9b59b6',
			'reward_dm'  => 200,
		),
		102 => array(
			'type'       => 'tournament',
			'counter'    => 'tournament_ghosts_killed',
			'target'     => 10,
			'field_flag' => 'achievement_slayer',
			'field_date' => 'achievement_slayer_at',
			'label'      => 'Verdugo Estelar',
			'icon'       => '💀',
			'color'      => '#7f8c8d',
			'reward_dm'  => 600,
		),
		103 => array(
			'type'       => 'tournament',
			'counter'    => 'tournament_damage_total',
			'target'     => 10000000,
			'field_flag' => 'achievement_contributor',
			'field_date' => 'achievement_contributor_at',
			'label'      => 'Contribuyente Épico',
			'icon'       => '⚔️',
			'color'      => '#e67e22',
			'reward_dm'  => 1000,
		),
		104 => array(
			'type'       => 'tournament',
			'counter'    => 'tournament_wins',
			'target'     => 1,
			'field_flag' => 'achievement_champion',
			'field_date' => 'achievement_champion_at',
			'label'      => 'Campeón del Torneo',
			'icon'       => '🏆',
			'color'      => '#f1c40f',
			'reward_dm'  => 4000,
		),

		/* ===== BASTIÓN ASEDIADO ===== */
		201 => array(
			'type'       => 'bastion',
			'counter'    => 'bastion_events_played',
			'target'     => 5,
			'field_flag' => 'achievement_bastion_veteran',
			'field_date' => 'achievement_bastion_veteran_at',
			'label'      => 'Veterano del Bastión',
			'icon'       => '🛡️',
			'color'      => '#3498db',
			'reward_dm'  => 300,
		),
		202 => array(
			'type'       => 'bastion',
			'counter'    => 'bastion_pirates_killed',
			'target'     => 5000,
			'field_flag' => 'achievement_bastion_pirate_legend',
			'field_date' => 'achievement_bastion_pirate_legend_at',
			'label'      => 'Leyenda Pirata',
			'icon'       => '☠️',
			'color'      => '#2ecc71',
			'reward_dm'  => 1000,
		),
		203 => array(
			'type'       => 'bastion',
			'counter'    => 'bastion_boss_pirates_killed',
			'target'     => 10,
			'field_flag' => 'achievement_bastion_boss_hunter',
			'field_date' => 'achievement_bastion_boss_hunter_at',
			'label'      => 'Cazador de Capitanes',
			'icon'       => '💀',
			'color'      => '#e74c3c',
			'reward_dm'  => 1500,
		),
		204 => array(
			'type'       => 'bastion',
			'counter'    => 'bastion_events_won',
			'target'     => 5,
			'field_flag' => 'achievement_bastion_dynasty',
			'field_date' => 'achievement_bastion_dynasty_at',
			'label'      => 'Dinastía del Bastión',
			'icon'       => '👑',
			'color'      => '#f1c40f',
			'reward_dm'  => 3000,
		),
	);


	/* ============================================================
	 *  REGISTRAR SUPERVIVENCIA
	 * ============================================================ */

	public static function recordSurvival($userId, $crisisEndTime)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		if ($userId <= 0) {
			return array('consecutive' => 0, 'total' => 0, 'newly_unlocked' => array());
		}

		$currentMonth  = date('Y-m', (int) $crisisEndTime);
		$previousMonth = date('Y-m', strtotime($currentMonth . ' -1 month'));

		$row = $db->selectSingle(
			"SELECT * FROM %%PVE_ACHIEVEMENTS%% WHERE user_id = :uid LIMIT 1;",
			array(':uid' => $userId)
		);

		$consecutive = 0;
		$total       = 0;
		$lastMonth   = '';

		if (!empty($row)) {
			$consecutive = (int) $row['consecutive_months'];
			$total       = (int) $row['total_months'];
			$lastMonth   = (string) $row['last_survived_month'];
		}

		if ($lastMonth === $currentMonth) {
			return array(
				'consecutive'    => $consecutive,
				'total'          => $total,
				'newly_unlocked' => array(),
			);
		}

		if ($lastMonth === $previousMonth) {
			$consecutive++;
		} else {
			$consecutive = 1;
		}

		$total++;
		$now = TIMESTAMP;

		if (empty($row)) {
			try {
				$db->insert(
					"INSERT INTO %%PVE_ACHIEVEMENTS%% SET
						user_id              = :uid,
						consecutive_months   = :consec,
						total_months         = :total,
						last_survived_month  = :month,
						updated_at           = :now;",
					array(
						':uid'    => $userId,
						':consec' => $consecutive,
						':total'  => $total,
						':month'  => $currentMonth,
						':now'    => $now,
					)
				);
			} catch (Throwable $eDup) {
				// ✅ v3.8 — Carrera: otro proceso ya creó la fila → caer a la
				// vía UPDATE condicional de abajo (en vez de reventar).
			}
		}

		if (!empty($row) || !empty($eDup ?? null)) {
			// ✅ v3.8 — Guard anti-doble: `last_survived_month <> :mes` hace
			// que solo el PRIMER proceso del mes cuente. Antes dos cierres de
			// crisis concurrentes para el mismo usuario incrementaban
			// consecutive_months/total_months dos veces.
			$db->update(
				"UPDATE %%PVE_ACHIEVEMENTS%% SET
					consecutive_months   = :consec,
					total_months         = :total,
					last_survived_month  = :month,
					updated_at           = :now
				WHERE user_id = :uid AND last_survived_month <> :month2;",
				array(
					':uid'    => $userId,
					':consec' => $consecutive,
					':total'  => $total,
					':month'  => $currentMonth,
					':month2' => $currentMonth,
					':now'    => $now,
				)
			);

			if ($db->rowCount() !== 1) {
				// Otro proceso ya registró este mes → devolver el estado real
				$row2 = $db->selectSingle(
					"SELECT consecutive_months, total_months FROM %%PVE_ACHIEVEMENTS%% WHERE user_id = :uid LIMIT 1;",
					array(':uid' => $userId)
				);
				$c = !empty($row2) ? (int) $row2['consecutive_months'] : $consecutive;
				$t = !empty($row2) ? (int) $row2['total_months'] : $total;
				return array(
					'consecutive'    => $c,
					'total'          => $t,
					'newly_unlocked' => array(),
				);
			}
		}

		$newlyUnlocked = self::checkSurvivalAchievements($userId, $consecutive);

		return array(
			'consecutive'    => $consecutive,
			'total'          => $total,
			'newly_unlocked' => $newlyUnlocked,
		);
	}


	/* ============================================================
	 *  REGISTRAR EVENTOS DEL TORNEO DEL DEVORADOR
	 * ============================================================ */

	public static function recordBossKill($userId, $kills = 1)
	{
		$kills = max(1, (int) $kills);
		return self::incrementCounter($userId, 'tournament_ghosts_killed', $kills, 'tournament');
	}

	public static function recordBossDamage($userId, $damage)
	{
		$damage = (float) $damage;
		if ($damage <= 0) {
			return array();
		}
		return self::incrementCounter($userId, 'tournament_damage_total', $damage, 'tournament');
	}

	public static function recordTournamentWin($userId, $tournamentId = 0)
	{
		return self::incrementCounter($userId, 'tournament_wins', 1, 'tournament');
	}


	/* ============================================================
	 *  REGISTRAR EVENTOS DEL BASTIÓN ASEDIADO
	 * ============================================================ */

	/**
	 * Registra que un jugador ha participado en un evento del Bastión.
	 * Se llama UNA vez por evento (idealmente en MissionCasePveBastion::TargetEvent()
	 * la primera vez que el jugador envía refuerzos en ese evento).
	 */
	public static function recordBastionPlayed($userId, $eventId = 0)
	{
		return self::incrementCounter($userId, 'bastion_events_played', 1, 'bastion');
	}

	/**
	 * Suma piratas eliminados por el jugador (acumulativo global).
	 */
	public static function recordBastionPirateKills($userId, $kills)
	{
		$kills = (int) $kills;
		if ($kills <= 0) {
			return array();
		}
		return self::incrementCounter($userId, 'bastion_pirates_killed', $kills, 'bastion');
	}

	/**
	 * Suma capitanes piratas (boss) eliminados por el jugador (acumulativo global).
	 */
	public static function recordBastionBossKills($userId, $kills)
	{
		$kills = (int) $kills;
		if ($kills <= 0) {
			return array();
		}
		return self::incrementCounter($userId, 'bastion_boss_pirates_killed', $kills, 'bastion');
	}

	/**
	 * Registra que el jugador ha ganado un evento del Bastión (su alianza quedó 1ª).
	 */
	public static function recordBastionWin($userId, $eventId = 0)
	{
		return self::incrementCounter($userId, 'bastion_events_won', 1, 'bastion');
	}


	/* ============================================================
	 *  INCREMENTADOR GENÉRICO DE CONTADORES
	 *  (refactor de incrementTournamentCounter — soporta tournament + bastion)
	 * ============================================================ */

	private static function incrementCounter($userId, $column, $amount, $type)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		$allowed = array(
			'tournament' => array(
				'tournament_ghosts_killed',
				'tournament_damage_total',
				'tournament_wins',
			),
			'bastion' => array(
				'bastion_events_played',
				'bastion_pirates_killed',
				'bastion_boss_pirates_killed',
				'bastion_events_won',
			),
		);

		if ($userId <= 0
			|| !isset($allowed[$type])
			|| !in_array($column, $allowed[$type], true)) {
			return array();
		}

		$now = TIMESTAMP;

		// ✅ v3.8 — UPSERT atómico en una sola sentencia: antes era
		// check-then-act y dos procesos que inicializaban al mismo usuario
		// lanzaban duplicate-key SIN capturar (abortaba a mitad de resolución
		// en recordBossKill/recordBossDamage del torneo). La tabla tiene
		// UNIQUE uk_user(user_id) → ON DUPLICATE KEY UPDATE es seguro.
		$db->insert(
			"INSERT INTO %%PVE_ACHIEVEMENTS%% SET
				user_id      = :uid,
				`$column`    = :val,
				updated_at   = :now
			ON DUPLICATE KEY UPDATE
				`$column`    = `$column` + :val,
				updated_at   = :now;",
			array(
				':uid' => $userId,
				':val' => $amount,
				':now' => $now,
			)
		);

		if ($type === 'tournament') {
			return self::checkTournamentAchievements($userId);
		}

		return self::checkBastionAchievements($userId);
	}


	/* ============================================================
	 *  COMPROBACIÓN DE LOGROS
	 * ============================================================ */

	public static function checkAchievements($userId, $consecutiveMonths = null)
	{
		return self::checkSurvivalAchievements($userId, $consecutiveMonths);
	}

	public static function checkSurvivalAchievements($userId, $consecutiveMonths = null)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		$row = $db->selectSingle(
			"SELECT * FROM %%PVE_ACHIEVEMENTS%% WHERE user_id = :uid LIMIT 1;",
			array(':uid' => $userId)
		);

		if (empty($row)) {
			return array();
		}

		if ($consecutiveMonths === null) {
			$consecutiveMonths = (int) $row['consecutive_months'];
		}

		$newlyUnlocked = array();

		foreach (self::ACHIEVEMENTS as $id => $ach) {
			if ($ach['type'] !== 'survival') {
				continue;
			}
			if (!empty($row[$ach['field_flag']])) {
				continue;
			}
			if ($consecutiveMonths < $ach['months']) {
				continue;
			}

			$ok = self::grantAchievement($userId, $id, $ach, array(
				'months' => $ach['months'],
			));

			if ($ok) {
				$newlyUnlocked[$id] = array(
					'months' => $ach['months'],
					'label'  => $ach['label'],
					'icon'   => $ach['icon'],
					'reward' => $ach['reward_dm'],
				);
			}
		}

		return $newlyUnlocked;
	}

	public static function checkTournamentAchievements($userId)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		$row = $db->selectSingle(
			"SELECT * FROM %%PVE_ACHIEVEMENTS%% WHERE user_id = :uid LIMIT 1;",
			array(':uid' => $userId)
		);

		if (empty($row)) {
			return array();
		}

		$newlyUnlocked = array();

		foreach (self::ACHIEVEMENTS as $id => $ach) {
			if ($ach['type'] !== 'tournament') {
				continue;
			}
			if (!empty($row[$ach['field_flag']])) {
				continue;
			}

			$counterValue = isset($row[$ach['counter']]) ? (float) $row[$ach['counter']] : 0;
			if ($counterValue < $ach['target']) {
				continue;
			}

			$ok = self::grantAchievement($userId, $id, $ach, array(
				'counter' => $ach['counter'],
				'value'   => $counterValue,
				'target'  => $ach['target'],
			));

			if ($ok) {
				$newlyUnlocked[$id] = array(
					'label'  => $ach['label'],
					'icon'   => $ach['icon'],
					'reward' => $ach['reward_dm'],
				);
			}
		}

		return $newlyUnlocked;
	}

	public static function checkBastionAchievements($userId)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		$row = $db->selectSingle(
			"SELECT * FROM %%PVE_ACHIEVEMENTS%% WHERE user_id = :uid LIMIT 1;",
			array(':uid' => $userId)
		);

		if (empty($row)) {
			return array();
		}

		$newlyUnlocked = array();

		foreach (self::ACHIEVEMENTS as $id => $ach) {
			if ($ach['type'] !== 'bastion') {
				continue;
			}
			if (!empty($row[$ach['field_flag']])) {
				continue;
			}

			$counterValue = isset($row[$ach['counter']]) ? (float) $row[$ach['counter']] : 0;
			if ($counterValue < $ach['target']) {
				continue;
			}

			$ok = self::grantAchievement($userId, $id, $ach, array(
				'counter' => $ach['counter'],
				'value'   => $counterValue,
				'target'  => $ach['target'],
			));

			if ($ok) {
				$newlyUnlocked[$id] = array(
					'label'  => $ach['label'],
					'icon'   => $ach['icon'],
					'reward' => $ach['reward_dm'],
				);
			}
		}

		return $newlyUnlocked;
	}


	/* ============================================================
	 *  OTORGAR LOGRO + ENTREGAR DM
	 * ============================================================ */

	/**
	 * Otorga un logro al jugador y le acredita la Materia Oscura.
	 *
	 * v2.2 — DOBLE RIEL: NO APLICA.
	 *
	 *   Este método entrega **Materia Oscura (DM)**, no NTX-20 ni UNTX-20.
	 *   La Materia Oscura es un recurso universal del juego (columna
	 *   `uni1_users.darkmatter`) que NO depende del `metodo_retiro` del
	 *   jugador. Por eso NO hay:
	 *
	 *     - detección de riel (getPlayerMethod / isIntl)
	 *     - regla ×2 (UNTX_MULTIPLIER)
	 *     - llamadas a WalletHelper::addNxt20()
	 *     - llamadas a PVPHelper::getPremioParaJugador()
	 *
	 *   Tanto un jugador CUP como uno QVAPAY reciben la misma cantidad
	 *   de DM (`reward_dm`). Aplicar ×2 aquí sería un bug.
	 *
	 *   Si en el futuro los logros PvE empiezan a dar NTX-20, entonces
	 *   sí habría que:
	 *     1. Añadir `reward_ntx` al array ACHIEVEMENTS
	 *     2. Calcular `$realNtx = PVEHelper::getPremioParaJugador($reward_ntx, $userId)`
	 *     3. Acreditar en la columna correcta (ntx20 | untx20)
	 *     4. Loguear en NTX20LogHelper SOLO si CUP
	 *
	 *   Pero eso NO es lo que hace el código actual.
	 *
	 * @param int   $userId
	 * @param int   $id
	 * @param array $ach
	 * @param array $meta
	 * @return bool
	 */
	private static function grantAchievement($userId, $id, array $ach, array $meta = array())
	{
		$db     = Database::get();
		$userId = (int) $userId;
		$now    = TIMESTAMP;
		$dm     = (int) $ach['reward_dm'];

		// Mapear tipo de logro al ENUM de uni1_pve_log
		// - survival   -> 'crisis'   (ENUM válido)
		// - tournament -> 'boss'     (ENUM válido — antes usaba 'tournament' que NO está en el ENUM)
		// - bastion    -> 'bastion'  (ENUM válido)
		$logType = 'crisis';
		if ($ach['type'] === 'tournament') {
			$logType = 'boss';
		} elseif ($ach['type'] === 'bastion') {
			$logType = 'bastion';
		}

		try {
			// ✅ v3.8 — Flag condicional + rowCount: solo el primer proceso
			// que desbloquea el logro acredita la DM. Antes el UPDATE era
			// incondicional: dos procesos concurrentes pasaban ambos el
			// check de la bandera y daban la DM DOS veces.
			$db->update(
				"UPDATE %%PVE_ACHIEVEMENTS%% SET
					`" . $ach['field_flag'] . "` = 1,
					`" . $ach['field_date'] . "` = :now,
					updated_at = :now
				WHERE user_id = :uid
				  AND (`" . $ach['field_flag'] . "` IS NULL OR `" . $ach['field_flag'] . "` = 0);",
				array(':now' => $now, ':uid' => $userId)
			);

			if ($db->rowCount() !== 1) {
				// Ya estaba concedido (por este u otro proceso)
				return false;
			}

			// ═════════════════════════════════════════════════════════
			// MATERIA OSCURA — recurso universal, NO depende del riel
			// (regla ×2 de UNTX-20 NO aplica aquí)
			// ═════════════════════════════════════════════════════════
			if ($dm > 0) {
				$db->update(
					"UPDATE %%USERS%% SET
						darkmatter = darkmatter + :dm
					WHERE id = :uid;",
					array(':dm' => $dm, ':uid' => $userId)
				);

				// Refrescar la sesión global para que el Topnav muestre el cambio
				if (isset($GLOBALS['USER']['id']) && (int) $GLOBALS['USER']['id'] === $userId) {
					$GLOBALS['USER']['darkmatter'] = ((int) ($GLOBALS['USER']['darkmatter'] ?? 0)) + $dm;
				}
			}

			self::sendAchievementMessage($userId, $ach, $dm, $meta);

			PVEHelper::log(
				$logType,
				0,
				'achievement_unlocked',
				$userId,
				0,
				array(
					'id'        => $id,
					'label'     => $ach['label'],
					'reward'    => $dm,
					'type'      => $ach['type'],
					'meta'      => $meta,
					'riel_note' => 'darkmatter_es_universal_no_aplica_dual_riel',
				)
			);

			return true;

		} catch (Exception $e) {
			PVEHelper::log(
				$logType,
				0,
				'achievement_error',
				$userId,
				0,
				array(
					'id'    => $id,
					'label' => $ach['label'],
					'error' => $e->getMessage(),
				)
			);
			return false;
		}
	}


	/* ============================================================
	 *  MENSAJE INTERNO AL JUGADOR
	 * ============================================================ */

	private static function sendAchievementMessage($userId, $ach, $rewardDm, array $meta = array())
	{
		try {
			$title = "[PvE] Logro desbloqueado: " . $ach['label'];

			$body  = "&iexcl;Has desbloqueado un nuevo logro en el sistema PvE!<br><br>";
			$body .= "<b>Logro:</b> " . $ach['label'] . "<br>";

			if ($ach['type'] === 'survival' && isset($meta['months'])) {
				$body .= "<b>Meses consecutivos sobrevividos:</b> " . (int) $meta['months'] . "<br>";
			}

			if (($ach['type'] === 'tournament' || $ach['type'] === 'bastion')
				&& isset($meta['value']) && isset($meta['target'])) {
				$body .= "<b>Progreso:</b> " . number_format((float) $meta['value'])
					. " / " . number_format((float) $meta['target']) . "<br>";
			}

			if ($rewardDm > 0) {
				$body .= "<b>Recompensa:</b> +" . number_format($rewardDm) . " Materia Oscura<br><br>";
				$body .= "La recompensa ya ha sido a&ntilde;adida a tu cuenta.";
			}

			PlayerUtil::sendMessage(
				$userId, 0, 'Comando Central PvE', 3, $title, $body,
				TIMESTAMP, null, 1, PVEHelper::getUniverseForUser($userId)
			);
		} catch (Exception $e) {
			// Silencioso
		}
	}


	/* ============================================================
	 *  CONSULTAS PARA LA VISTA
	 * ============================================================ */

	public static function getUserAchievements($userId)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		$row = $db->selectSingle(
			"SELECT * FROM %%PVE_ACHIEVEMENTS%% WHERE user_id = :uid LIMIT 1;",
			array(':uid' => $userId)
		);

		$consecutive = !empty($row) ? (int) $row['consecutive_months'] : 0;
		$total       = !empty($row) ? (int) $row['total_months']       : 0;
		$lastMonth   = !empty($row) ? (string) $row['last_survived_month'] : '';

		$achievements = array();

		foreach (self::ACHIEVEMENTS as $id => $ach) {
			$unlocked   = !empty($row) && !empty($row[$ach['field_flag']]);
			$unlockedAt = (!empty($row) && !empty($row[$ach['field_date']]))
				? (int) $row[$ach['field_date']]
				: 0;

			if ($ach['type'] === 'survival') {
				$current  = $consecutive;
				$target   = $ach['months'];
				$progress = min(100, round(($consecutive / max(1, $ach['months'])) * 100));
			} else {
				$current  = isset($row[$ach['counter']]) ? (float) $row[$ach['counter']] : 0;
				$target   = $ach['target'];
				$progress = $target > 0 ? min(100, round(($current / $target) * 100)) : 0;
			}

			$achievements[] = array(
				'id'              => $id,
				'type'            => $ach['type'],
				'label'           => $ach['label'],
				'icon'            => $ach['icon'],
				'color'           => $ach['color'],
				'reward_dm'       => (int) $ach['reward_dm'],
				'current'         => $current,
				'target'          => $target,
				'months_required' => isset($ach['months']) ? $ach['months'] : null,
				'unlocked'        => $unlocked,
				'unlocked_at'     => $unlockedAt,
				'unlocked_fmt'    => $unlockedAt > 0 ? date('d/m/Y H:i', $unlockedAt) : '',
				'progress'        => $progress,
			);
		}

		return array(
			'consecutive'  => $consecutive,
			'total'        => $total,
			'last_month'   => $lastMonth,
			'achievements' => $achievements,
		);
	}
}