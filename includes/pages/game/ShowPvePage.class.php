<?php

/**
 * AstroIO — ShowPvePage
 * Página principal del sistema PvE (Crisis + Imperio + Logros)
 *
 * v3.3 — Fix del flujo de ataque al Imperio Caído:
 *  - Nuevo handler attackPrepare() que guarda el target en sesión
 *  - Los botones del template ya apuntan a mode=attackPrepare
 *  - Sobrevive al redirect de fleetStep1 → fleetTable
 *
 * v3.4 — SOPORTE TORNEO DEL DEVORADOR:
 *  - Añadido require_once de PVEBossTournamentHelper
 *  - Nuevos métodos:
 *      - boss()                 → panel del torneo (registro + activo + ranking)
 *      - registerAlliance()     → inscripción de la alianza (líder)
 *      - summonBoss()           → invocación manual (admin)
 *      - bossRankingJson()      → endpoint AJAX para ranking en vivo
 *      - attackBossPrepare()    → prepara ataque al boss del torneo
 *  - Sin cambios en métodos existentes (100% retrocompatible)
 *
 * v5.3 — CARD DEL TORNEO EN EL PANEL PRINCIPAL:
 *  - show() calcula $bossState (enabled, active, status, next_time, end_time)
 *    y lo asigna como 'boss_state' al template.
 *  - El template pinta la 3ª card con countdown regresivo.
 *  - Bloque defensivo: si el helper no existe o falla, cae a enabled=0.
 *
 * v6.0 — SOPORTE BASTIÓN ASEDIADO:
 *  - Añadido require_once de PVEBastionHelper (carga defensiva)
 *  - Nuevos métodos:
 *      - bastion()               → panel del bastión (registro + activo + ranking)
 *      - registerBastion()       → inscripción de la alianza (líder)
 *      - bastionRankingJson()    → endpoint AJAX para ranking en vivo
 *      - reinforcePrepare()      → prepara envío de refuerzos al bastión
 *  - show() calcula $bastionState y lo asigna como 'bastion_state'
 *  - Sin cambios en métodos existentes (100% retrocompatible)
 *
 * v6.1 — FIX: isEmpireEnabled() pertenece a PVEHelper, no a PVEEmpireHelper.
 *  - Corregidas 4 llamadas erróneas PVEEmpireHelper::isEmpireEnabled() → PVEHelper::isEmpireEnabled()
 *    en empire(), attackPrepare(), acsSetup() y createAcsPve().
 *
 * v6.2 — DOBLE RIEL (NTX-20 / UNTX-20):
 *  - Helper interno getRielVarsForUser() + buildRielAssignVars() (fail-safe a CUP).
 *  - show(): inyecta 'riel', 'moneda', 'saldo_actual', 'es_internacional'.
 *    · pendingTotals['ntx'] ahora es el monto REAL del jugador (base ×2 si QVAPAY).
 *    · pendingTotals['ntx_base'] es la suma BASE legacy (para referencia).
 *    · pendingTotals['moneda'] etiqueta visible ('NTX-20' | 'UNTX-20').
 *    · claim_info añade 'moneda' y 'multiplier'.
 *  - empire(): inyecta riel vars + 'loot_pct_dual' con vista por riel.
 *  - boss() / bastion(): pool_preview ahora incluye pools duales reales
 *    (pool_ntx20, pool_untx20, fee_ntx20/untx20, prize_ntx20/untx20) +
 *    entry_cost_base/real/moneda + my_pool/my_fee/my_prize/my_currency
 *    para el riel del jugador actual. Mantiene campos legacy
 *    (total/fee/prize) para retrocompatibilidad con templates viejos.
 *  - achievements(): inyecta riel vars.
 *  - acsSetup(): inyecta riel vars.
 *  - bossRankingJson() / bastionRankingJson(): exponen pools duales
 *    (pool_ntx20, pool_untx20, prize_ntx20, prize_untx20, fee_ntx20, fee_untx20) +
 *    vista del jugador (my_pool, my_fee, my_prize, my_currency, my_is_intl) +
 *    entry_cost_base/real/moneda. Sin queries extra por request
 *    (usa getPlayerMethod que está cacheado en PVEHelper).
 *  - claimRewards(): sin cambios lógicos (ya devuelve montos REALES en
 *    $result['ntx_total'] vía PVEHelper::claimAllRewards() v2.0). Sólo se
 *    documenta en el docblock que ntx es REAL.
 *  - 100% retrocompatible: agrega campos a los templates sin romper los existentes.
 *
 * Ubicación: includes/pages/game/ShowPvePage.class.php
 * @package AstroIO
 * @version 6.2
 */

class ShowPvePage extends AbstractGamePage
{
	public $requireModule     = MODULE_PVE;
	public $defaultController = 'show';

	public function __construct()
	{
		parent::__construct();

		require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
		require_once ROOT_PATH.'includes/classes/PVECrisisHelper.class.php';
		require_once ROOT_PATH.'includes/classes/PVEEmpireHelper.class.php';
		require_once ROOT_PATH.'includes/classes/PVEAchievementHelper.class.php';
		require_once ROOT_PATH.'includes/classes/PveFleetHelper.class.php';
		require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';

		// v3.4 — Torneo del Devorador (carga defensiva: puede no existir aún)
		$bossHelperFile = ROOT_PATH.'includes/classes/PVEBossTournamentHelper.class.php';
		if (file_exists($bossHelperFile)) {
			require_once $bossHelperFile;
		}

		// v6.0 — Bastión Asediado (carga defensiva: puede no existir aún)
		$bastionHelperFile = ROOT_PATH.'includes/classes/PVEBastionHelper.class.php';
		if (file_exists($bastionHelperFile)) {
			require_once $bastionHelperFile;
		}

		// v6.0 — WaveHelper del Bastión (carga defensiva)
		$bastionWaveFile = ROOT_PATH.'includes/classes/PVEBastionWaveHelper.class.php';
		if (file_exists($bastionWaveFile)) {
			require_once $bastionWaveFile;
		}
	}


	/* ============================================================
	 *  v6.2 — HELPERS INTERNOS DE DOBLE RIEL
	 * ============================================================ */

	/**
	 * Obtiene info completa del riel del jugador.
	 * Fail-safe a CUP si PVEHelper no está disponible o falla.
	 *
	 * @param int $userId
	 * @return array{
	 *   isIntl: bool, colBalance: string, moneda: string,
	 *   monedaFiat: string, saldo: int, multiplier: int
	 * }
	 */
	private function getRielVarsForUser(int $userId): array
	{
		if ($userId > 0 && class_exists('PVEHelper') && method_exists('PVEHelper', 'getRielInfo')) {
			try {
				return PVEHelper::getRielInfo($userId);
			} catch (Throwable $e) {
				// fallback abajo
			}
		}

		return array(
			'isIntl'     => false,
			'colBalance' => 'ntx20',
			'moneda'     => 'NTX-20',
			'monedaFiat' => 'CUP',
			'saldo'      => 0,
			'multiplier' => 1,
		);
	}


	/**
	 * Empaqueta las vars de riel para pasar a $this->assign().
	 *
	 * @param array $rielInfo
	 * @return array
	 */
	private function buildRielAssignVars(array $rielInfo): array
	{
		return array(
			'riel'             => $rielInfo,
			'moneda'           => $rielInfo['moneda'],
			'saldo_actual'     => (int) $rielInfo['saldo'],
			'es_internacional' => !empty($rielInfo['isIntl']) ? 1 : 0,
		);
	}


	/* ============================================================
	 *  VISTA PRINCIPAL
	 * ============================================================ */

	public function show()
	{
		global $USER;

		if (!PVEHelper::isEnabled()) {
			$this->printMessage('El sistema PvE está desactivado actualmente.');
			return;
		}

		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

		// v6.2 — Info de riel del jugador
		$rielInfo = $this->getRielVarsForUser($userId);

		$data = array(
			'crisis_enabled'    => PVEHelper::isCrisisEnabled() ? 1 : 0,
			'empire_enabled'    => PVEHelper::isEmpireEnabled() ? 1 : 0,
			'crisis_active'     => PVEHelper::isCrisisActive()  ? 1 : 0,
			'empire_active'     => PVEHelper::isEmpireActive()  ? 1 : 0,
			'crisis_next_time'  => PVEHelper::getNextEventTime('crisis'),
			'empire_next_time'  => PVEHelper::getNextEventTime('empire'),
		);

		$crisisState = array(
			'enabled'   => 0,
			'active'    => 0,
			'next_time' => 0,
			'end_time'  => 0,
		);
		$empireState = array(
			'enabled'   => 0,
			'active'    => 0,
			'next_time' => 0,
			'end_time'  => 0,
		);

		try {
			$crisisState = PVEHelper::getEventState('crisis');
		} catch (Exception $e) {}

		try {
			$empireState = PVEHelper::getEventState('empire');
		} catch (Exception $e) {}

		// ─── v5.3: Estado del Torneo del Devorador (para la card del panel) ───
		$bossState = array(
			'enabled'   => 0,
			'active'    => 0,
			'status'    => 'idle',
			'next_time' => 0,
			'end_time'  => 0,
		);

		if (class_exists('PVEBossTournamentHelper')) {
			try {
				$rawBoss = PVEBossTournamentHelper::getEventState();

				if (!empty($rawBoss['enabled'])) {
					$bossState['enabled'] = 1;

					if (!empty($rawBoss['has_event'])) {
						$status = (string) ($rawBoss['status'] ?? 'idle');
						$bossState['status'] = $status;

						if ($status === 'active') {
							$bossState['active']    = 1;
							$bossState['next_time'] = (int) ($rawBoss['next_time'] ?? 0);
							$bossState['end_time']  = (int) ($rawBoss['end_time']  ?? 0);
						} elseif ($status === 'registration') {
							// Cuenta atrás hasta el inicio real del torneo (= fin de inscripción)
							$bossState['next_time'] = (int) ($rawBoss['registration_end'] ?? 0);
						} elseif ($status === 'scheduled') {
							// Cuenta atrás hasta la apertura de inscripciones
							$bossState['next_time'] = (int) ($rawBoss['next_time'] ?? 0);
						}
					}
				}
			} catch (Throwable $e) {
				// mantener defaults
			}
		}

		// ─── v6.0: Estado del Bastión Asediado (para la card del panel) ───
		$bastionState = array(
			'enabled'   => 0,
			'active'    => 0,
			'status'    => 'idle',
			'next_time' => 0,
			'end_time'  => 0,
		);

		if (class_exists('PVEBastionHelper')) {
			try {
				$rawBastion = PVEBastionHelper::getEventState();

				if (!empty($rawBastion['enabled'])) {
					$bastionState['enabled'] = 1;

					if (!empty($rawBastion['has_event'])) {
						$status = (string) ($rawBastion['status'] ?? 'idle');
						$bastionState['status'] = $status;

						if ($status === 'active') {
							$bastionState['active']    = 1;
							$bastionState['next_time'] = (int) ($rawBastion['next_time'] ?? 0);
							$bastionState['end_time']  = (int) ($rawBastion['end_time']  ?? 0);
						} elseif ($status === 'registration') {
							$bastionState['next_time'] = (int) ($rawBastion['registration_end'] ?? 0);
						} elseif ($status === 'scheduled') {
							$bastionState['next_time'] = (int) ($rawBastion['next_time'] ?? 0);
						}
					}
				}
			} catch (Throwable $e) {
				// mantener defaults
			}
		}

		$rewards       = array();
		$pendingCount  = 0;
		$activeEmpires = array();

		if ($userId > 0) {
			try {
				$rewards      = PVEHelper::getPendingRewards($userId);
				$pendingCount = PVEHelper::countPendingRewards($userId);
			} catch (Exception $e) {
				$rewards      = array();
				$pendingCount = 0;
			}
		}

		try {
			$activeEmpires = PVEEmpireHelper::getActiveEmpires();
		} catch (Exception $e) {
			$activeEmpires = array();
		}

		// ─── Totales de recompensas pendientes (para mostrar en cabecera) ───
		// v6.2 — El monto NTX que se muestra al jugador es el REAL de su riel.
		//         `ntx` = real (base ×2 si QVAPAY). `ntx_base` = suma base (referencia).
		$pendingTotals = array(
			'ntx'       => 0, // REAL (para el jugador)
			'ntx_base'  => 0, // BASE (referencia legacy)
			'metal'     => 0,
			'crystal'   => 0,
			'deuterium' => 0,
			'count'     => 0,
			'moneda'    => $rielInfo['moneda'],
			'multiplier'=> (int) $rielInfo['multiplier'],
			'is_intl'   => !empty($rielInfo['isIntl']) ? 1 : 0,
		);
		foreach ($rewards as $r) {
			$pendingTotals['count']++;
			if (isset($r['reward_type']) && $r['reward_type'] === 'ntx') {
				$baseAmt = isset($r['amount'])      ? (int) $r['amount']      : 0;
				$realAmt = isset($r['amount_real']) ? (int) $r['amount_real'] : ($baseAmt * (int) $rielInfo['multiplier']);

				$pendingTotals['ntx']      += $realAmt;
				$pendingTotals['ntx_base'] += $baseAmt;
			}
			if (isset($r['reward_type']) && $r['reward_type'] === 'resources') {
				$pendingTotals['metal']     += isset($r['metal'])     ? (int) $r['metal']     : 0;
				$pendingTotals['crystal']   += isset($r['crystal'])   ? (int) $r['crystal']   : 0;
				$pendingTotals['deuterium'] += isset($r['deuterium']) ? (int) $r['deuterium'] : 0;
			}
		}

		// ─── Flash tras reclamar recompensas ───
		$claimInfo = null;
		$claimFlag = HTTP::_GP('claim', '');

		if ($claimFlag === 'success') {
			$claimInfo = array(
				'type'       => 'success',
				'ntx'        => (int) HTTP::_GP('ntx', 0), // v6.2: REAL (ya lo devuelve claimRewards)
				'metal'      => (int) HTTP::_GP('metal', 0),
				'crystal'    => (int) HTTP::_GP('crystal', 0),
				'deuterium'  => (int) HTTP::_GP('deuterium', 0),
				'count'      => (int) HTTP::_GP('n', 0),
				'moneda'     => $rielInfo['moneda'],
				'multiplier' => (int) $rielInfo['multiplier'],
			);
		} elseif ($claimFlag === 'none') {
			$claimInfo = array(
				'type'  => 'none',
				'count' => 0,
				'moneda'=> $rielInfo['moneda'],
			);
		}

		$this->assign(array_merge(
			array(
				'pve'           => $data,
				'crisis_state'  => $crisisState,
				'empire_state'  => $empireState,
				'boss_state'    => $bossState,
				'bastion_state' => $bastionState,
				'rewards'       => $rewards,
				'pendingCount'  => $pendingCount,
				'pendingTotals' => $pendingTotals,
				'activeEmpires' => $activeEmpires,
				'empiresCount'  => count($activeEmpires),
				'claim_info'    => $claimInfo,
			),
			$this->buildRielAssignVars($rielInfo)
		));

		$this->display('page.pve.default.tpl');
	}


	/* ============================================================
	 *  VISTA IMPERIO CAÍDO
	 * ============================================================ */

	public function empire()
	{
		global $USER, $PLANET, $resource, $reslist;

		if (!PVEHelper::isEnabled() || !PVEHelper::isEmpireEnabled()) {
			$this->printMessage('El evento Imperio Caído está desactivado actualmente.');
			return;
		}

		$db     = Database::get();
		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

		// v6.2 — Info de riel del jugador
		$rielInfo = $this->getRielVarsForUser($userId);

		// ─── % de botín configurado (para el preview del template) ───
		$lootPct = (int) PVEHelper::get('empire_loot_pct', 100);
		if ($lootPct < 0)   $lootPct = 0;
		if ($lootPct > 100) $lootPct = 100;
		$lootFactor = $lootPct / 100;

		$empires = array();
		$openAcsByEmpire = array();

		try {
			$rawEmpires = PVEEmpireHelper::getActiveEmpires();
			$maxAttacks = (int) PVEHelper::get('empire_attacks_per_user', 5);

			foreach ($rawEmpires as $e) {
				$myAttacks = 0;
				if ($userId > 0) {
					$myAttacks = PVEEmpireHelper::getAttacksByUser($userId, (int) $e['id']);
				}

				$e['my_attacks']  = $myAttacks;
				$e['max_attacks'] = $maxAttacks;
				$e['can_attack']  = ($myAttacks < $maxAttacks);
				$e['hp_percent']  = ($e['total_hp'] > 0)
					? round(($e['current_hp'] / $e['total_hp']) * 100, 1)
					: 0;
				$e['hp_fmt']      = number_format((int) $e['current_hp']);
				$e['hp_max_fmt']  = number_format((int) $e['total_hp']);
				$e['dmg_fmt']     = number_format((int) $e['total_damage_received']);
				$e['time_left']   = max(0, (int) $e['end_time'] - TIMESTAMP);
				$e['time_left_fmt'] = pretty_time($e['time_left']);
				$e['faction_name']  = PveFleetHelper::getFactionName((int) $e['faction']);

				// 🔧 v3.0: asegurar ghost_planet_id numérico para el botón "Atacar"
				$e['ghost_planet_id'] = !empty($e['ghost_planet_id']) ? (int) $e['ghost_planet_id'] : 0;

				// ─── Preview del botín (v3.2) ───
				// Parsear resources_config (JSON) y aplicar el % de empire_loot_pct
				$e['loot_preview'] = array('metal' => 0, 'crystal' => 0, 'deuterium' => 0);
				$e['loot_pct']     = $lootPct;

				if (!empty($e['resources_config'])) {
					$parsed = json_decode($e['resources_config'], true);
					if (is_array($parsed)) {
						$baseMetal     = isset($parsed['metal'])     ? (int) $parsed['metal']     : 0;
						$baseCrystal   = isset($parsed['crystal'])   ? (int) $parsed['crystal']   : 0;
						$baseDeuterium = isset($parsed['deuterium']) ? (int) $parsed['deuterium'] : 0;

						$e['loot_preview'] = array(
							'metal'     => (int) floor($baseMetal     * $lootFactor),
							'crystal'   => (int) floor($baseCrystal   * $lootFactor),
							'deuterium' => (int) floor($baseDeuterium * $lootFactor),
						);
					}
				}

				try {
					$openAcsByEmpire[(int) $e['id']] = PveFleetHelper::getOpenAcsForEmpire((int) $e['id'], $userId);
				} catch (Exception $e2) {
					$openAcsByEmpire[(int) $e['id']] = array();
				}

				$empires[] = $e;
			}
		} catch (Exception $e) {
			$empires = array();
		}

		// ─── Naves del planeta ACTUAL (referencia informativa) ───
		$planetShips = array();
		if (!empty($PLANET) && !empty($PLANET['id'])) {
			foreach ($reslist['fleet'] as $elementId) {
				$colName = $resource[$elementId];
				$amount  = isset($PLANET[$colName]) ? (int) $PLANET[$colName] : 0;
				if ($amount > 0) {
					$planetShips[] = array(
						'id'     => $elementId,
						'name'   => $GLOBALS['LNG']['tech'][$elementId],
						'amount' => $amount,
					);
				}
			}
		}

		// ─── Planetas alternativos ───
		$otherPlanets = array();
		if (!empty($USER['PLANETS']) && is_array($USER['PLANETS'])) {
			foreach ($USER['PLANETS'] as $pl) {
				if (!is_array($pl) || !isset($pl['id'])) continue;
				if ((int) $pl['id'] === (int) $PLANET['id']) continue;
				if ((int) $pl['planet_type'] !== 1) continue;

				$otherPlanets[] = array(
					'id'     => (int) $pl['id'],
					'name'   => $pl['name'],
					'coords' => '[' . (int) $pl['galaxy'] . ':' . (int) $pl['system'] . ':' . (int) $pl['planet'] . ']',
				);
			}
		}

		// ─── Invitaciones pendientes ───
		$pendingInvites = array();
		if ($userId > 0) {
			try {
				$pendingInvites = PveFleetHelper::getPendingInvitesForUser($userId);
			} catch (Exception $e) {
				$pendingInvites = array();
			}
		}

		// ─── Mi alianza ───
		$myAllyId   = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$myAllyTag  = '';
		$myAllyName = '';

		if ($myAllyId > 0) {
			$sql = "SELECT ally_name, ally_tag FROM %%ALLIANCE%% WHERE id = :id LIMIT 1;";
			$allyData = $db->selectSingle($sql, array(':id' => $myAllyId));
			if (!empty($allyData)) {
				$myAllyTag  = $allyData['ally_tag'];
				$myAllyName = $allyData['ally_name'];
			}
		}

		// ─── Lista de usuarios ───
		$allUsers = array();
		try {
			$sql = "SELECT u.id, u.username, u.ally_id,
			               COALESCE(s.total_points, 0) AS total_points
			        FROM %%USERS%% u
			        LEFT JOIN %%STATPOINTS%% s ON s.id_owner = u.id AND s.stat_type = 1
			        WHERE u.id != :me
			          AND u.authlevel < 3
			          AND u.universe = :uni
			          AND u.bana = 0
			          AND u.urlaubs_modus = 0
			        ORDER BY s.total_points DESC
			        LIMIT 100;";
			$users = $db->select($sql, array(
				':me'  => $userId,
				':uni' => Universe::current(),
			));
			if (!empty($users)) {
				foreach ($users as $u) {
					$allUsers[] = array(
						'id'     => (int) $u['id'],
						'name'   => $u['username'],
						'points' => (int) $u['total_points'],
						'ally_id' => (int) $u['ally_id'],
					);
				}
			}
		} catch (Exception $e) {
			$allUsers = array();
		}

		// ─── Lista de alianzas ───
		$allAlliances = array();
		try {
			$sql = "SELECT id, ally_name, ally_tag, ally_members
			        FROM %%ALLIANCE%%
			        WHERE ally_universe = :uni
			        ORDER BY ally_members DESC
			        LIMIT 100;";
			$alliances = $db->select($sql, array(':uni' => Universe::current()));
			if (!empty($alliances)) {
				foreach ($alliances as $a) {
					$allAlliances[] = array(
						'id'      => (int) $a['id'],
						'name'    => $a['ally_name'],
						'tag'     => $a['ally_tag'],
						'members' => (int) $a['ally_members'],
					);
				}
			}
		} catch (Exception $e) {
			$allAlliances = array();
		}

		// ─── Flash messages ───
		$attackResult = null;
		$attackError  = null;

		if (isset($_SESSION['pve_empire_result'])) {
			$attackResult = $_SESSION['pve_empire_result'];
			unset($_SESSION['pve_empire_result']);
		}
		if (isset($_SESSION['pve_empire_error'])) {
			$attackError = $_SESSION['pve_empire_error'];
			unset($_SESSION['pve_empire_error']);
		}

		$this->assign(array_merge(
			array(
				'empires'         => $empires,
				'empiresCount'    => count($empires),
				'openAcsByEmpire' => $openAcsByEmpire,
				'pendingInvites'  => $pendingInvites,
				'pendingInvitesCount' => count($pendingInvites),
				'lootPct'         => $lootPct,
				'currentPlanet'   => array(
					'id'        => !empty($PLANET['id'])        ? (int) $PLANET['id']        : 0,
					'name'      => !empty($PLANET['name'])      ? $PLANET['name']            : '',
					'galaxy'    => !empty($PLANET['galaxy'])    ? (int) $PLANET['galaxy']    : 0,
					'system'    => !empty($PLANET['system'])    ? (int) $PLANET['system']    : 0,
					'planet'    => !empty($PLANET['planet'])    ? (int) $PLANET['planet']    : 0,
					'deuterium' => !empty($PLANET['deuterium']) ? (int) $PLANET['deuterium'] : 0,
				),
				'planetShips'     => $planetShips,
				'otherPlanets'    => $otherPlanets,
				'allUsers'        => $allUsers,
				'allAlliances'    => $allAlliances,
				'myAllyId'        => $myAllyId,
				'myAllyTag'       => $myAllyTag,
				'myAllyName'      => $myAllyName,
				'attackResult'    => $attackResult,
				'attackError'     => $attackError,
			),
			$this->buildRielAssignVars($rielInfo)
		));

		$this->display('page.pve.empire.tpl');
	}


	/* ============================================================
	 *  🆕 ACCIÓN: PREPARAR ATAQUE (v3.3)
	 *
	 *  Guarda el target del imperio en sesión y redirige a fleetTable.
	 *  Esto permite que el flujo nativo (fleetTable → fleetStep1 → 2 → 3)
	 *  conserve las coordenadas del imperio, sobreviviendo al redirect
	 *  interno de GotoFleetPage().
	 *
	 *  URL: game.php?page=pve&mode=attackPrepare&empire_id=X[&acs_id=Y]
	 * ============================================================ */

	public function attackPrepare()
	{
		global $USER;

		if (!PVEHelper::isEnabled() || !PVEHelper::isEmpireEnabled()) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		$userId   = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$empireId = (int) HTTP::_GP('empire_id', 0);
		$acsId    = (int) HTTP::_GP('acs_id', 0);

		if ($userId <= 0 || $empireId <= 0) {
			$_SESSION['pve_empire_error'] = 'Datos inválidos.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		$empire = PVEEmpireHelper::getEmpire($empireId);
		if (empty($empire) || $empire['status'] !== 'active') {
			$_SESSION['pve_empire_error'] = 'El imperio no está activo.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		if (!PVEEmpireHelper::canAttack($userId, $empireId)) {
			$max = (int) PVEHelper::get('empire_attacks_per_user', 5);
			$_SESSION['pve_empire_error'] = 'Ya alcanzaste el máximo de ' . $max . ' ataques a este imperio.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		// ═══════════════════════════════════════════════════════════
		// GUARDAR TARGET EN SESIÓN
		// Sobrevive al redirect interno de fleetStep1 → fleetTable
		// y a todo el flujo fleetTable → fleetStep1 → fleetStep2 → fleetStep3
		// ═══════════════════════════════════════════════════════════
		$_SESSION['pve_attack_target'] = array(
			'empire_id' => (int) $empireId,
			'galaxy'    => (int) $empire['galaxy'],
			'system'    => (int) $empire['system'],
			'planet'    => (int) $empire['planet'],
			'type'      => 1, // planet_type del imperio fantasma (siempre 1 = planeta)
			'mission'   => 1, // ATTACK
			'acs_id'    => $acsId > 0 ? $acsId : 0,
			'created_at'=> TIMESTAMP,
		);

		// Si viene con acs_id (Unirse a ACS existente), también guardarlo
		if ($acsId > 0) {
			$_SESSION['pve_acs_id']        = $acsId;
			$_SESSION['pve_acs_empire_id'] = $empireId;
		}

		// ═══════════════════════════════════════════════════════════
		// REDIRIGIR A fleetTable (selección de naves)
		// El target se recuperará en fleetStep1 desde la sesión
		// ═══════════════════════════════════════════════════════════
		HTTP::redirectTo('game.php?page=fleetTable');
		exit;
	}


	/* ============================================================
	 *  VISTA CONFIGURACIÓN ACS
	 * ============================================================ */

	/**
	 * Página intermedia para configurar un ACS antes de ir a fleetStep1.
	 * URL: game.php?page=pve&mode=acsSetup&empire_id=X
	 */
	public function acsSetup()
	{
		global $USER, $PLANET;

		if (!PVEHelper::isEnabled() || !PVEHelper::isEmpireEnabled()) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		$db       = Database::get();
		$userId   = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$empireId = (int) HTTP::_GP('empire_id', 0);

		// v6.2 — Info de riel del jugador
		$rielInfo = $this->getRielVarsForUser($userId);

		if ($userId <= 0 || $empireId <= 0) {
			$_SESSION['pve_empire_error'] = 'Datos inválidos.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		$empire = PVEEmpireHelper::getEmpire($empireId);
		if (empty($empire) || $empire['status'] !== 'active') {
			$_SESSION['pve_empire_error'] = 'El imperio no está activo.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		if (!PVEEmpireHelper::canAttack($userId, $empireId)) {
			$max = (int) PVEHelper::get('empire_attacks_per_user', 5);
			$_SESSION['pve_empire_error'] = 'Ya alcanzaste el máximo de ' . $max . ' ataques a este imperio.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		// ─── Datos del imperio ───
		$empireData = array(
			'id'             => (int) $empire['id'],
			'name'           => $empire['name'],
			'galaxy'         => (int) $empire['galaxy'],
			'system'         => (int) $empire['system'],
			'planet'         => (int) $empire['planet'],
			'faction_name'   => PveFleetHelper::getFactionName((int) $empire['faction']),
			'ghost_planet_id'=> !empty($empire['ghost_planet_id']) ? (int) $empire['ghost_planet_id'] : 0,
		);

		// ─── Mi alianza ───
		$myAllyId   = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$myAllyTag  = '';
		$myAllyName = '';

		if ($myAllyId > 0) {
			$sql = "SELECT ally_name, ally_tag FROM %%ALLIANCE%% WHERE id = :id LIMIT 1;";
			$allyData = $db->selectSingle($sql, array(':id' => $myAllyId));
			if (!empty($allyData)) {
				$myAllyTag  = $allyData['ally_tag'];
				$myAllyName = $allyData['ally_name'];
			}
		}

		// ─── Lista de usuarios ───
		$allUsers = array();
		try {
			$sql = "SELECT u.id, u.username,
			               COALESCE(s.total_points, 0) AS total_points
			        FROM %%USERS%% u
			        LEFT JOIN %%STATPOINTS%% s ON s.id_owner = u.id AND s.stat_type = 1
			        WHERE u.id != :me
			          AND u.authlevel < 3
			          AND u.universe = :uni
			          AND u.bana = 0
			          AND u.urlaubs_modus = 0
			        ORDER BY s.total_points DESC
			        LIMIT 100;";
			$users = $db->select($sql, array(
				':me'  => $userId,
				':uni' => Universe::current(),
			));
			if (!empty($users)) {
				foreach ($users as $u) {
					$allUsers[] = array(
						'id'     => (int) $u['id'],
						'name'   => $u['username'],
						'points' => (int) $u['total_points'],
					);
				}
			}
		} catch (Exception $e) {
			$allUsers = array();
		}

		// ─── Lista de alianzas ───
		$allAlliances = array();
		try {
			$sql = "SELECT id, ally_name, ally_tag, ally_members
			        FROM %%ALLIANCE%%
			        WHERE ally_universe = :uni
			        ORDER BY ally_members DESC
			        LIMIT 100;";
			$alliances = $db->select($sql, array(':uni' => Universe::current()));
			if (!empty($alliances)) {
				foreach ($alliances as $a) {
					$allAlliances[] = array(
						'id'      => (int) $a['id'],
						'name'    => $a['ally_name'],
						'tag'     => $a['ally_tag'],
						'members' => (int) $a['ally_members'],
					);
				}
			}
		} catch (Exception $e) {
			$allAlliances = array();
		}

		// ─── Mi planeta actual ───
		$currentPlanet = array(
			'id'     => !empty($PLANET['id'])     ? (int) $PLANET['id']     : 0,
			'name'   => !empty($PLANET['name'])   ? $PLANET['name']         : '',
			'galaxy' => !empty($PLANET['galaxy']) ? (int) $PLANET['galaxy'] : 0,
			'system' => !empty($PLANET['system']) ? (int) $PLANET['system'] : 0,
			'planet' => !empty($PLANET['planet']) ? (int) $PLANET['planet'] : 0,
		);

		$this->assign(array_merge(
			array(
				'empire'         => $empireData,
				'myAllyId'       => $myAllyId,
				'myAllyTag'      => $myAllyTag,
				'myAllyName'     => $myAllyName,
				'allUsers'       => $allUsers,
				'allAlliances'   => $allAlliances,
				'currentPlanet'  => $currentPlanet,
			),
			$this->buildRielAssignVars($rielInfo)
		));

		$this->display('page.pve.acsSetup.tpl');
	}


	/* ============================================================
	 *  ACCIÓN: CREAR ACS PvE (POST)
	 * ============================================================ */

	/**
	 * Crea el ACS + invitaciones y redirige a fleetStep1 (UI nativa)
	 * URL: POST game.php?page=pve&mode=createAcsPve
	 */
	public function createAcsPve()
	{
		global $USER;

		if (!PVEHelper::isEnabled() || !PVEHelper::isEmpireEnabled()) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		$db       = Database::get();
		$userId   = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$empireId = (int) HTTP::_GP('empire_id', 0);

		if ($userId <= 0 || $empireId <= 0) {
			$_SESSION['pve_empire_error'] = 'Datos inválidos.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		$empire = PVEEmpireHelper::getEmpire($empireId);
		if (empty($empire) || $empire['status'] !== 'active') {
			$_SESSION['pve_empire_error'] = 'El imperio no está activo.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		if (!PVEEmpireHelper::canAttack($userId, $empireId)) {
			$max = (int) PVEHelper::get('empire_attacks_per_user', 5);
			$_SESSION['pve_empire_error'] = 'Ya alcanzaste el máximo de ' . $max . ' ataques a este imperio.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		// ─── Recoger opciones ───
		$visibility = HTTP::_GP('acs_visibility', 'public');
		if (!in_array($visibility, array('public', 'ally', 'invite'))) {
			$visibility = 'public';
		}

		$allyId      = (int) HTTP::_GP('acs_ally_id', 0);
		$deadlineMin = (int) HTTP::_GP('acs_deadline_minutes', 60);

		if ($deadlineMin < 5)   $deadlineMin = 5;
		if ($deadlineMin > 720) $deadlineMin = 720;

		$invitedUsers = array();
		if (isset($_POST['acs_users']) && is_array($_POST['acs_users'])) {
			foreach ($_POST['acs_users'] as $uid) {
				$uid = (int) $uid;
				if ($uid > 0 && $uid !== $userId) {
					$invitedUsers[] = $uid;
				}
			}
		}

		// ─── Crear el ACS ───
		$estimatedArrival = TIMESTAMP + ($deadlineMin * 60);

		try {
			$acsId = PveFleetHelper::createAcsGroup(
				$userId,
				$empireId,
				$estimatedArrival,
				$visibility,
				$allyId,
				TIMESTAMP + ($deadlineMin * 60)
			);
		} catch (Throwable $e) {
			$_SESSION['pve_empire_error'] = 'Error al crear el ACS: ' . $e->getMessage();
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		if ($acsId <= 0) {
			$_SESSION['pve_empire_error'] = 'No se pudo crear el ACS.';
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		// ─── Crear invitaciones ───
		$invitesCreated = 0;
		try {
			if ($visibility === 'invite' && !empty($invitedUsers)) {
				$invitesCreated = PveFleetHelper::createAcsInvites($acsId, $userId, 'user', $invitedUsers);
			} elseif ($visibility === 'ally' && $allyId > 0) {
				$invitesCreated = PveFleetHelper::createAcsInvites($acsId, $userId, 'ally', array(), $allyId);
			}
		} catch (Throwable $e) {
			// Silencioso
		}

		// ─── Guardar el ACS en sesión para que fleetStep1 lo recoja ───
		$_SESSION['pve_acs_id']          = $acsId;
		$_SESSION['pve_acs_empire_id']   = $empireId;
		$_SESSION['pve_acs_visibility']  = $visibility;

		// 🆕 v3.3: También guardar el target para que fleetStep1 lo use
		$_SESSION['pve_attack_target'] = array(
			'empire_id' => (int) $empireId,
			'galaxy'    => (int) $empire['galaxy'],
			'system'    => (int) $empire['system'],
			'planet'    => (int) $empire['planet'],
			'type'      => 1,
			'mission'   => 1,
			'acs_id'    => $acsId,
			'created_at'=> TIMESTAMP,
		);

		// ─── Mensaje flash ───
		$msgText = '✅ ACS #' . $acsId . ' creado. ';
		if ($invitesCreated > 0) {
			$msgText .= 'Se enviaron ' . $invitesCreated . ' invitaciones. ';
		}
		$msgText .= 'Ahora selecciona tus naves para atacar el imperio.';

		$_SESSION['pve_empire_result'] = array(
			'message' => $msgText,
			'details' => array(
				'acs_id'    => $acsId,
				'empire_id' => $empireId,
			),
		);

		// ─── Redirigir a fleetTable (selección de naves) ───
		// El target se recuperará en fleetStep1 desde la sesión
		HTTP::redirectTo('game.php?page=fleetTable');
		exit;
	}

	/* --------------------------------------------------------------
	 *  FIN DE LA PARTE 1 — continúa en la PARTE 2 con:
	 *    - achievements()
	 *    - doAttackEmpire() (deprecado)
	 *    - acceptInvite() / rejectInvite()
	 *    - claimRewards()
	 *    - boss() + registerAlliance() + summonBoss() + bossRankingJson() + attackBossPrepare()
	 *    - bastion() + registerBastion() + bastionRankingJson() + reinforcePrepare()
	 *    - Cierre de clase
	 * -------------------------------------------------------------- */
	 
	 	/* ============================================================
	 *  VISTA LOGROS
	 * ============================================================ */

	public function achievements()
	{
		global $USER;

		if (!PVEHelper::isEnabled() || !PVEHelper::isCrisisEnabled()) {
			$this->printMessage('El sistema de logros está desactivado actualmente.');
			return;
		}

		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

		if ($userId <= 0) {
			$this->printMessage('Debes iniciar sesión para ver tus logros.');
			return;
		}

		// v6.2 — Info de riel del jugador
		$rielInfo = $this->getRielVarsForUser($userId);

		$data = array(
			'consecutive'  => 0,
			'total'        => 0,
			'last_month'   => '',
			'achievements' => array(),
		);

		try {
			$data = PVEAchievementHelper::getUserAchievements($userId);
		} catch (Exception $e) {}

		$this->assign(array_merge(
			array(
				'achievements_data' => $data,
			),
			$this->buildRielAssignVars($rielInfo)
		));

		$this->display('page.pve.achievements.tpl');
	}


	/* ============================================================
	 *  ACCIÓN DEPRECADA: ATACAR IMPERIO
	 * ============================================================ */

	/**
	 * @deprecated v3.0 — Reemplazado por el flujo nativo de fleetStep1.
	 */
	public function doAttackEmpire()
	{
		$_SESSION['pve_empire_error'] = 'Este método ya no se usa. Usa los botones de ataque.';
		HTTP::redirectTo('game.php?page=pve&mode=empire');
		exit;
	}


	/* ============================================================
	 *  ACCIÓN: ACEPTAR INVITACIÓN ACS
	 * ============================================================ */

	public function acceptInvite()
	{
		global $USER;

		$userId   = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$inviteId = (int) HTTP::_GP('invite_id', 0);

		if ($userId <= 0 || $inviteId <= 0) {
			HTTP::redirectTo('game.php?page=pve&mode=empire');
			return;
		}

		try {
			$resultAcsId = PveFleetHelper::acceptInvite($inviteId, $userId);

			if (!empty($resultAcsId)) {
				// Obtener datos del imperio del ACS para redirigir a fleetStep1
				$db = Database::get();
				$sql = "SELECT target FROM %%AKS%% WHERE id = :id LIMIT 1;";
				$targetEmpireId = (int) $db->selectSingle($sql, array(':id' => $resultAcsId), 'target');

				$empire = PVEEmpireHelper::getEmpire($targetEmpireId);

				$_SESSION['pve_empire_result'] = array(
					'message' => '✅ Has aceptado la invitación al ACS #' . $resultAcsId . '. Ahora selecciona tus naves y únete.',
					'details' => array(
						'acs_id'    => $resultAcsId,
						'empire_id' => $targetEmpireId,
					),
				);

				// Guardar en sesión para que fleetStep1 lo recoja
				$_SESSION['pve_acs_id']        = $resultAcsId;
				$_SESSION['pve_acs_empire_id'] = $targetEmpireId;

				// 🆕 v3.3: Guardar target para que fleetStep1 lo use
				if (!empty($empire)) {
					$_SESSION['pve_attack_target'] = array(
						'empire_id' => (int) $targetEmpireId,
						'galaxy'    => (int) $empire['galaxy'],
						'system'    => (int) $empire['system'],
						'planet'    => (int) $empire['planet'],
						'type'      => 1,
						'mission'   => 1,
						'acs_id'    => (int) $resultAcsId,
						'created_at'=> TIMESTAMP,
					);
				}

				// 🆕 v3.3: redirigir a fleetTable (selección de naves)
				HTTP::redirectTo('game.php?page=fleetTable');
				exit;
			} else {
				$_SESSION['pve_empire_error'] = '❌ Invitación no encontrada o ya procesada.';
			}
		} catch (Exception $e) {
			$_SESSION['pve_empire_error'] = '❌ Error: ' . $e->getMessage();
		}

		HTTP::redirectTo('game.php?page=pve&mode=empire');
		exit;
	}


	/* ============================================================
	 *  ACCIÓN: RECHAZAR INVITACIÓN ACS
	 * ============================================================ */

	public function rejectInvite()
	{
		global $USER;

		$userId   = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$inviteId = (int) HTTP::_GP('invite_id', 0);

		if ($userId > 0 && $inviteId > 0) {
			try {
				PveFleetHelper::rejectInvite($inviteId, $userId);
				$_SESSION['pve_empire_result'] = array(
					'message' => 'ℹ️ Invitación rechazada.',
					'details' => array(),
				);
			} catch (Exception $e) {}
		}

		HTTP::redirectTo('game.php?page=pve&mode=empire');
		exit;
	}


	/* ============================================================
	 *  ACCIÓN: RECLAMAR RECOMPENSAS
	 * ============================================================ */

	/**
	 * v3.1 — Ahora maneja NTX-20 Y recursos.
	 *
	 * v6.2 — El `ntx_total` devuelto por PVEHelper::claimAllRewards() v2.0
	 *        YA ES EL MONTO REAL del jugador (base ×2 si QVAPAY). No hay
	 *        conversión adicional aquí: se pasa tal cual al redirect para
	 *        que el template lo muestre con la moneda correcta.
	 *
	 * Redirige con:
	 *   - &ntx=X       (REAL, moneda del jugador)
	 *   - &metal=X
	 *   - &crystal=X
	 *   - &deuterium=X
	 *   - &n=X         (cantidad total de recompensas reclamadas)
	 */
	public function claimRewards()
	{
		global $USER;

		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

		if ($userId <= 0) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		$result = array(
			'claimed'         => 0,
			'ntx_total'       => 0,
			'resources_total' => array('metal' => 0, 'crystal' => 0, 'deuterium' => 0),
			'errors'          => array(),
		);

		try {
			$result = PVEHelper::claimAllRewards($userId);
		} catch (Exception $e) {
			$result['errors'][] = $e->getMessage();
		}

		// ─── Si no se reclamó nada → redirect de "nada pendiente" ───
		if (empty($result['claimed']) || $result['claimed'] <= 0) {
			HTTP::redirectTo('game.php?page=pve&claim=none');
			exit;
		}

		// ─── Extraer totales (con fallback seguro) ───
		// v6.2: ntx_total YA ES REAL (PVEHelper v2.0 aplica ×2 internamente).
		$ntxTotal = isset($result['ntx_total']) ? (int) $result['ntx_total'] : 0;

		$metalTotal     = 0;
		$crystalTotal   = 0;
		$deuteriumTotal = 0;

		if (!empty($result['resources_total']) && is_array($result['resources_total'])) {
			$metalTotal     = isset($result['resources_total']['metal'])     ? (int) $result['resources_total']['metal']     : 0;
			$crystalTotal   = isset($result['resources_total']['crystal'])   ? (int) $result['resources_total']['crystal']   : 0;
			$deuteriumTotal = isset($result['resources_total']['deuterium']) ? (int) $result['resources_total']['deuterium'] : 0;
		}

		// ─── Log de errores (por si algo falló) ───
		if (!empty($result['errors'])) {
			foreach ($result['errors'] as $err) {
				PVEHelper::log('rewards', 0, 'claim_partial_error', $userId, 0, array(
					'error' => $err,
				));
			}
		}

		// ─── Redirect con info detallada ───
		$url = 'game.php?page=pve'
		     . '&claim=success'
		     . '&n='         . (int) $result['claimed']
		     . '&ntx='       . $ntxTotal
		     . '&metal='     . $metalTotal
		     . '&crystal='   . $crystalTotal
		     . '&deuterium=' . $deuteriumTotal;

		HTTP::redirectTo($url);
		exit;
	}


	/* ============================================================
	 *  🆕 v3.4 — TORNEO DEL DEVORADOR: PANEL PRINCIPAL
	 * ============================================================ */

	/**
	 * Página principal del Torneo del Devorador.
	 *
	 * URL: game.php?page=pve&mode=boss
	 *
	 * v6.2 — DUAL-RIEL:
	 *   · pool_preview ahora incluye pools separados (pool_ntx20 / pool_untx20)
	 *     y vista por riel del jugador (my_pool, my_fee, my_prize, my_currency).
	 *   · Mantiene campos legacy (total, fee, prize) calculados sobre
	 *     total_pool_ntx (suma base) para retrocompatibilidad con templates viejos.
	 *
	 * Muestra:
	 *   - Estado del evento (scheduled / registration / active / finished)
	 *   - Fantasma activo de tu alianza (HP, fase, coords, countdown)
	 *   - Ranking en vivo de alianzas
	 *   - Contribución interna de tu alianza
	 *   - Botón de inscripción (solo líder/sub-líder)
	 *   - Botón de ataque (si tu alianza está inscrita)
	 */
	public function boss()
	{
		global $USER;

		if (!PVEHelper::isEnabled()) {
			$this->printMessage('El sistema PvE está desactivado actualmente.');
			return;
		}

		if (!class_exists('PVEBossTournamentHelper')) {
			$this->printMessage('El módulo del Torneo del Devorador no está instalado.');
			return;
		}

		if (!PVEBossTournamentHelper::isEnabled()) {
			$this->printMessage('El Torneo del Devorador está desactivado actualmente.');
			return;
		}

		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;
		if ($userId <= 0) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		// v6.2 — Info de riel del jugador
		$rielInfo = $this->getRielVarsForUser($userId);

		// ─── Mi alianza + rango ───
		$myAllyId    = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$myAllyRank  = !empty($USER['ally_rank_id']) ? (int) $USER['ally_rank_id'] : 0;
		$myAllyName  = '';
		$myAllyTag   = '';

		if ($myAllyId > 0) {
			$db = Database::get();
			$sql = "SELECT ally_name, ally_tag FROM %%ALLIANCE%% WHERE id = :id LIMIT 1;";
			$allyData = $db->selectSingle($sql, array(':id' => $myAllyId));
			if (!empty($allyData)) {
				$myAllyName = $allyData['ally_name'];
				$myAllyTag  = $allyData['ally_tag'];
			}
		}

		// ─── Flash messages ───
		$bossResult = null;
		$bossError  = null;

		if (isset($_SESSION['pve_boss_result'])) {
			$bossResult = $_SESSION['pve_boss_result'];
			unset($_SESSION['pve_boss_result']);
		}
		if (isset($_SESSION['pve_boss_error'])) {
			$bossError = $_SESSION['pve_boss_error'];
			unset($_SESSION['pve_boss_error']);
		}

		// ─── Estado del evento ───
		$eventState = PVEBossTournamentHelper::getEventState();
		$event      = PVEBossTournamentHelper::getActiveEvent();

		// ─── Mi registration (si mi alianza está inscrita) ───
		$myRegistration = null;
		if ($event && $myAllyId > 0) {
			$myRegistration = PVEBossTournamentHelper::getRegistration($event['id'], $myAllyId);
		}

		// ─── Fantasma activo de mi alianza ───
		$myActiveGhost = null;
		if ($myRegistration) {
			$myActiveGhost = PVEBossTournamentHelper::getActiveGhostForRegistration((int) $myRegistration['id']);
		}

		// ─── Ranking en vivo ───
		$ranking = array();
		if ($event) {
			try {
				$ranking = PVEBossTournamentHelper::getLiveRanking((int) $event['id']);
			} catch (Exception $e) {
				$ranking = array();
			}
		}

		// ─── Contribución interna de mi alianza ───
		$myAllyContrib = array();
		if ($event && $myRegistration) {
			try {
				$myAllyContrib = PVEBossTournamentHelper::getAllyDetail((int) $event['id'], (int) $myRegistration['id']);
			} catch (Exception $e) {
				$myAllyContrib = array();
			}
		}

		// ─── ¿Puede inscribir? (líder o sub-líder) ───
		$canRegister = false;
		if ($event && $event['status'] === 'registration' && $myAllyId > 0 && !$myRegistration) {
			$canRegister = PVEBossTournamentHelper::canRegister($myAllyId, $myAllyRank);
		}

		// ─── ¿Puede atacar? (inscrita + fantasma activo) ───
		$canAttack = false;
		if ($event && $event['status'] === 'active' && $myRegistration && $myActiveGhost) {
			$canAttack = true;
		}

		// ─── Preview del pool de premios (DUAL-RIEL) ───
		// v6.2 — Se exponen pools separados (ntx20/untx20) + vista por riel.
		//         Los campos legacy (total/fee/prize) se mantienen calculados
		//         sobre `total_pool_ntx` para retrocompatibilidad.
		$poolPreview = array(
			// Campos legacy (retrocompat)
			'total'      => 0,
			'fee'        => 0,
			'prize'      => 0,
			'type'       => 'ntx',
			'entry_mode' => 'free',

			// v6.2 — Pools duales reales
			'pool_ntx20'  => 0,
			'pool_untx20' => 0,
			'fee_ntx20'   => 0,
			'fee_untx20'  => 0,
			'prize_ntx20' => 0,
			'prize_untx20'=> 0,
			'fee_pct'     => 0,

			// v6.2 — Vista del jugador actual (su riel)
			'my_pool'     => 0,
			'my_fee'      => 0,
			'my_prize'    => 0,
			'my_currency' => $rielInfo['moneda'],
			'my_is_intl'  => !empty($rielInfo['isIntl']) ? 1 : 0,
			'my_multiplier' => (int) $rielInfo['multiplier'],

			// v6.2 — Coste de entrada (base y real)
			'entry_cost_base' => 0,
			'entry_cost_real' => 0,
			'entry_cost_currency' => $rielInfo['moneda'],
		);

		if ($event) {
			$poolPreview['entry_mode'] = $event['entry_mode'];
			$poolPreview['type']       = $event['prize_type'];

			$feePct = max(0, min(100, (int) $event['project_fee_pct']));
			$poolPreview['fee_pct'] = $feePct;

			$entryCostBase = (int) $event['entry_cost_ntx'];
			$poolPreview['entry_cost_base'] = $entryCostBase;
			$poolPreview['entry_cost_real'] = ($rielInfo['isIntl'])
				? ($entryCostBase * (int) $rielInfo['multiplier'])
				: $entryCostBase;

			if ($event['entry_mode'] === 'paid') {
				// Pools reales
				$poolNtx  = (int) ($event['pool_ntx20']  ?? 0);
				$poolUntx = (int) ($event['pool_untx20'] ?? 0);

				$feeNtx  = (int) floor($poolNtx  * $feePct / 100);
				$feeUntx = (int) floor($poolUntx * $feePct / 100);

				$prizeNtx  = max(0, $poolNtx  - $feeNtx);
				$prizeUntx = max(0, $poolUntx - $feeUntx);

				$poolPreview['pool_ntx20']   = $poolNtx;
				$poolPreview['pool_untx20']  = $poolUntx;
				$poolPreview['fee_ntx20']    = $feeNtx;
				$poolPreview['fee_untx20']   = $feeUntx;
				$poolPreview['prize_ntx20']  = $prizeNtx;
				$poolPreview['prize_untx20'] = $prizeUntx;

				// Vista legacy (total_pool_ntx = suma base)
				$poolPreview['total'] = (int) $event['total_pool_ntx'];
				$poolPreview['fee']   = (int) floor($poolPreview['total'] * $feePct / 100);
				$poolPreview['prize'] = $poolPreview['total'] - $poolPreview['fee'];

				// Vista del jugador
				if ($rielInfo['isIntl']) {
					$poolPreview['my_pool']  = $poolUntx;
					$poolPreview['my_fee']   = $feeUntx;
					$poolPreview['my_prize'] = $prizeUntx;
				} else {
					$poolPreview['my_pool']  = $poolNtx;
					$poolPreview['my_fee']   = $feeNtx;
					$poolPreview['my_prize'] = $prizeNtx;
				}
			} else {
				// Modo gratis → premio configurado (BASE NTX-20)
				$basePrizeNtx = (int) $event['prize_ntx'];

				$poolPreview['prize'] = ($event['prize_type'] === 'ntx') ? $basePrizeNtx : 0;

				if ($event['prize_type'] === 'ntx') {
					$poolPreview['prize_ntx20']  = $basePrizeNtx;
					$poolPreview['prize_untx20'] = 0;

					// Vista del jugador (×2 si QVAPAY)
					$poolPreview['my_prize'] = ($rielInfo['isIntl'])
						? ($basePrizeNtx * (int) $rielInfo['multiplier'])
						: $basePrizeNtx;
					$poolPreview['my_pool'] = 0;
					$poolPreview['my_fee']  = 0;
				}
			}
		}

		$this->assign(array_merge(
			array(
				'pve_boss'          => array(
					'event'         => $event,
					'event_state'   => $eventState,
					'my_ally_id'    => $myAllyId,
					'my_ally_rank'  => $myAllyRank,
					'my_ally_name'  => $myAllyName,
					'my_ally_tag'   => $myAllyTag,
					'my_registration' => $myRegistration,
					'my_active_ghost' => $myActiveGhost,
					'can_register'  => $canRegister,
					'can_attack'    => $canAttack,
					'ranking'       => $ranking,
					'my_ally_contrib' => $myAllyContrib,
					'pool_preview'  => $poolPreview,
				),
				'bossResult'        => $bossResult,
				'bossError'         => $bossError,
			),
			$this->buildRielAssignVars($rielInfo)
		));

		$this->display('page.pve.boss.tpl');
	}


	/* ============================================================
	 *  🆕 v3.4 — TORNEO DEL DEVORADOR: INSCRIBIR ALIANZA
	 * ============================================================ */

	/**
	 * Inscribe la alianza del jugador en el torneo.
	 * Solo el líder (o sub-líder) puede hacerlo.
	 *
	 * URL: POST game.php?page=pve&mode=registerAlliance
	 */
	public function registerAlliance()
	{
		global $USER;

		if (!PVEHelper::isEnabled()) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		if (!class_exists('PVEBossTournamentHelper')) {
			$_SESSION['pve_boss_error'] = 'El módulo del Torneo no está instalado.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		$userId   = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$allyId   = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$allyRank = !empty($USER['ally_rank_id']) ? (int) $USER['ally_rank_id'] : 0;

		if ($userId <= 0 || $allyId <= 0) {
			$_SESSION['pve_boss_error'] = 'Debes pertenecer a una alianza para inscribirla.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		try {
			$result = PVEBossTournamentHelper::registerAlliance($allyId, $userId, $allyRank);

			if (!empty($result['ok'])) {
				$_SESSION['pve_boss_result'] = array(
					'message' => !empty($result['message']) ? $result['message'] : 'Alianza inscrita en el torneo.',
				);
			} else {
				$_SESSION['pve_boss_error'] = !empty($result['error']) ? $result['error'] : 'No se pudo inscribir la alianza.';
			}
		} catch (Throwable $e) {
			$_SESSION['pve_boss_error'] = 'Error: ' . $e->getMessage();
		}

		HTTP::redirectTo('game.php?page=pve&mode=boss');
		exit;
	}


	/* ============================================================
	 *  🆕 v3.4 — TORNEO DEL DEVORADOR: INVOCAR (ADMIN)
	 * ============================================================ */

	/**
	 * Fuerza la invocación del torneo (solo admin, uso de emergencia).
	 * El flujo normal es por el panel admin.
	 *
	 * URL: POST game.php?page=pve&mode=summonBoss
	 */
	public function summonBoss()
	{
		global $USER;

		$userId    = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$authLevel = !empty($USER['authlevel']) ? (int) $USER['authlevel'] : 0;

		if ($userId <= 0 || $authLevel < AUTH_ADM) {
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		if (!class_exists('PVEBossTournamentHelper')) {
			$_SESSION['pve_boss_error'] = 'El módulo del Torneo no está instalado.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		try {
			$result = PVEBossTournamentHelper::summonBoss();

			if (!empty($result['ok'])) {
				$_SESSION['pve_boss_result'] = array(
					'message' => 'Torneo invocado. ID del evento: ' . (int) $result['event_id'],
				);
			} else {
				$_SESSION['pve_boss_error'] = !empty($result['error']) ? $result['error'] : 'No se pudo invocar el torneo.';
			}
		} catch (Throwable $e) {
			$_SESSION['pve_boss_error'] = 'Error: ' . $e->getMessage();
		}

		HTTP::redirectTo('game.php?page=pve&mode=boss');
		exit;
	}


	/* ============================================================
	 *  🆕 v3.4 — TORNEO DEL DEVORADOR: RANKING EN VIVO (AJAX)
	 * ============================================================ */

	/**
	 * Endpoint AJAX que devuelve el ranking en vivo del torneo en JSON.
	 *
	 * URL: GET game.php?page=pve&mode=bossRankingJson&event_id=X
	 *
	 * v6.2 — DUAL-RIEL:
	 *   · Añade pool_ntx20 / pool_untx20 / prize_ntx20 / prize_untx20 /
	 *     fee_ntx20 / fee_untx20 (pools reales).
	 *   · Añade vista del jugador: my_pool, my_fee, my_prize, my_currency, my_is_intl.
	 *   · Añade entry_cost_base / entry_cost_real / entry_cost_currency.
	 *   · Mantiene campos legacy pool_ntx / prize_ntx (sobre total_pool_ntx)
	 *     para retrocompatibilidad con JS viejos.
	 *   · Sin queries extra: usa PVEHelper::getPlayerMethod() (cacheado).
	 *
	 * Devuelve:
	 *   {
	 *     ok, event_id, status, phase, hp_current, hp_max,
	 *     end_time, ghosts_alive, ghosts_total,
	 *     pool_ntx, prize_ntx,                                       ← legacy
	 *     pool_ntx20, pool_untx20,                                    ← v6.2
	 *     fee_ntx20, fee_untx20,                                      ← v6.2
	 *     prize_ntx20, prize_untx20,                                  ← v6.2
	 *     my_pool, my_fee, my_prize, my_currency, my_is_intl,         ← v6.2
	 *     entry_cost_base, entry_cost_real, entry_cost_currency,      ← v6.2
	 *     ranking: [{pos, ally_id, ally_name, pct, damage, hp_current, hp_max, members, phase}],
	 *     user_ally_id, user_ally_pos,
	 *     user_registration: {hp_current, hp_max, phase, galaxy, system, planet}
	 *   }
	 */
	public function bossRankingJson()
	{
		global $USER;

		header('Content-Type: application/json; charset=utf-8');

		if (!PVEHelper::isEnabled() || !class_exists('PVEBossTournamentHelper')) {
			echo json_encode(array('ok' => false, 'error' => 'Módulo no disponible.'));
			exit;
		}

		$userId  = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$allyId  = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$eventId = (int) HTTP::_GP('event_id', 0);

		// v6.2 — Info de riel del jugador (una sola vez por request)
		$rielInfo = $this->getRielVarsForUser($userId);

		if ($eventId <= 0) {
			echo json_encode(array('ok' => false, 'error' => 'event_id requerido.'));
			exit;
		}

		$event = PVEBossTournamentHelper::getEvent($eventId);
		if (empty($event)) {
			echo json_encode(array('ok' => false, 'error' => 'Evento no encontrado.'));
			exit;
		}

		// ─── Ranking ───
		$ranking = array();
		try {
			$ranking = PVEBossTournamentHelper::getLiveRanking($eventId);
		} catch (Throwable $e) {
			$ranking = array();
		}

		// ─── Mi registration ───
		$myReg = null;
		$myGhost = null;
		$userAllyPos = 0;

		if ($allyId > 0) {
			$myReg = PVEBossTournamentHelper::getRegistration($eventId, $allyId);
			if ($myReg) {
				$myGhost = PVEBossTournamentHelper::getActiveGhostForRegistration((int) $myReg['id']);
			}
		}

		// Calcular posición de mi alianza en el ranking
		foreach ($ranking as $i => $r) {
			if ((int) $r['ally_id'] === $allyId) {
				$userAllyPos = $i + 1;
				break;
			}
		}

		// ─── Contadores ───
		$ghostsAlive = 0;
		$ghostsTotal = 0;

		try {
			$stats = PVEBossTournamentHelper::getEventStats($eventId);
			$ghostsAlive = isset($stats['ghosts_alive']) ? (int) $stats['ghosts_alive'] : 0;
			$ghostsTotal = isset($stats['ghosts_total']) ? (int) $stats['ghosts_total'] : 0;
		} catch (Throwable $e) {
			// ignorar
		}

		// ─── Pool / premio (v6.2: dual-riel) ───
		$feePct    = max(0, min(100, (int) $event['project_fee_pct']));
		$poolLegacy = (int) $event['total_pool_ntx'];

		$poolNtx20  = (int) ($event['pool_ntx20']  ?? 0);
		$poolUntx20 = (int) ($event['pool_untx20'] ?? 0);

		$feeNtx20   = (int) floor($poolNtx20  * $feePct / 100);
		$feeUntx20  = (int) floor($poolUntx20 * $feePct / 100);

		$prizeNtx20  = max(0, $poolNtx20  - $feeNtx20);
		$prizeUntx20 = max(0, $poolUntx20 - $feeUntx20);

		// Legacy (retrocompat)
		$prizeLegacy = ($event['entry_mode'] === 'paid')
			? (int) floor($poolLegacy * (100 - $feePct) / 100)
			: (int) $event['prize_ntx'];

		// Vista del jugador
		$myPool  = $rielInfo['isIntl'] ? $poolUntx20  : $poolNtx20;
		$myFee   = $rielInfo['isIntl'] ? $feeUntx20   : $feeNtx20;
		$myPrize = $rielInfo['isIntl'] ? $prizeUntx20 : $prizeNtx20;

		if ($event['entry_mode'] !== 'paid' && $event['prize_type'] === 'ntx') {
			// Modo gratis: premio base × mult del jugador
			$basePrize = (int) $event['prize_ntx'];
			$myPrize = $rielInfo['isIntl']
				? ($basePrize * (int) $rielInfo['multiplier'])
				: $basePrize;
			$myPool = 0;
			$myFee  = 0;
		}

		// Coste de entrada (base y real)
		$entryCostBase = (int) $event['entry_cost_ntx'];
		$entryCostReal = $rielInfo['isIntl']
			? ($entryCostBase * (int) $rielInfo['multiplier'])
			: $entryCostBase;

		// ─── Preparar ranking limpio ───
		$cleanRanking = array();
		foreach ($ranking as $i => $r) {
			$cleanRanking[] = array(
				'pos'         => $i + 1,
				'ally_id'     => (int) $r['ally_id'],
				'ally_name'   => isset($r['ally_name']) ? $r['ally_name'] : ('Alianza #' . $r['ally_id']),
				'ally_tag'    => isset($r['ally_tag']) ? $r['ally_tag'] : '',
				'pct'         => isset($r['pct_damage_total']) ? (float) $r['pct_damage_total'] : 0,
				'damage'      => isset($r['total_damage']) ? (int) $r['total_damage'] : 0,
				'members'     => isset($r['members_at_spawn']) ? (int) $r['members_at_spawn'] : 0,
				'ghosts_killed' => isset($r['ghosts_killed']) ? (int) $r['ghosts_killed'] : 0,
				'ghosts_spawned' => isset($r['ghosts_spawned']) ? (int) $r['ghosts_spawned'] : 0,
				'phase'       => isset($r['current_phase']) ? (int) $r['current_phase'] : 0,
				'is_me'       => ((int) $r['ally_id'] === $allyId) ? 1 : 0,
			);
		}

		// ─── Mi fantasma ───
		$myGhostData = null;
		if ($myGhost) {
			$hpCurrent = (int) $myGhost['hp_current'];
			$hpMax     = max(1, (int) $myGhost['hp_max']);
			$myGhostData = array(
				'hp_current' => $hpCurrent,
				'hp_max'     => $hpMax,
				'hp_pct'     => round($hpCurrent / $hpMax * 100, 2),
				'phase'      => (int) $myGhost['phase'],
				'galaxy'     => (int) $myGhost['galaxy'],
				'system'     => (int) $myGhost['system'],
				'planet'     => (int) $myGhost['planet'],
				'spawn_number' => (int) $myGhost['spawn_number'],
			);
		}

		echo json_encode(array(
			'ok'            => true,
			'event_id'      => $eventId,
			'status'        => $event['status'],
			'entry_mode'    => $event['entry_mode'],
			'phase'         => 0,
			'ghosts_alive'  => $ghostsAlive,
			'ghosts_total'  => $ghostsTotal,

			// v6.2 — Pools duales reales
			'pool_ntx20'    => $poolNtx20,
			'pool_untx20'   => $poolUntx20,
			'fee_ntx20'     => $feeNtx20,
			'fee_untx20'    => $feeUntx20,
			'prize_ntx20'   => $prizeNtx20,
			'prize_untx20'  => $prizeUntx20,

			// v6.2 — Vista del jugador
			'my_pool'       => $myPool,
			'my_fee'        => $myFee,
			'my_prize'      => $myPrize,
			'my_currency'   => $rielInfo['moneda'],
			'my_is_intl'    => !empty($rielInfo['isIntl']) ? 1 : 0,

			// v6.2 — Coste de entrada
			'entry_cost_base'     => $entryCostBase,
			'entry_cost_real'     => $entryCostReal,
			'entry_cost_currency' => $rielInfo['moneda'],

			// Legacy (retrocompat)
			'pool_ntx'      => $poolLegacy,
			'prize_ntx'     => $prizeLegacy,

			'ranking'       => $cleanRanking,
			'user_ally_id'  => $allyId,
			'user_ally_pos' => $userAllyPos,
			'user_registration' => $myGhostData,
			'server_time'   => TIMESTAMP,
		));
		exit;
	}


	/* ============================================================
	 *  🆕 v3.4 — TORNEO DEL DEVORADOR: PREPARAR ATAQUE
	 * ============================================================ */

	/**
	 * Guarda el target del boss en sesión y redirige a fleetTable.
	 * Funciona igual que attackPrepare() pero con mission=23 y
	 * las coordenadas del fantasma activo de la alianza del jugador.
	 *
	 * URL: game.php?page=pve&mode=attackBossPrepare[&acs_id=Y]
	 */
	public function attackBossPrepare()
	{
		global $USER;

		if (!PVEHelper::isEnabled()) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		if (!class_exists('PVEBossTournamentHelper')) {
			$_SESSION['pve_boss_error'] = 'El módulo del Torneo no está instalado.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$allyId = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$acsId  = (int) HTTP::_GP('acs_id', 0);

		if ($userId <= 0 || $allyId <= 0) {
			$_SESSION['pve_boss_error'] = 'Debes pertenecer a una alianza.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		$event = PVEBossTournamentHelper::getActiveEvent();
		if (empty($event) || $event['status'] !== 'active') {
			$_SESSION['pve_boss_error'] = 'El torneo no está activo.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		$myReg = PVEBossTournamentHelper::getRegistration((int) $event['id'], $allyId);
		if (empty($myReg)) {
			$_SESSION['pve_boss_error'] = 'Tu alianza no está inscrita en el torneo.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		$ghost = PVEBossTournamentHelper::getActiveGhostForRegistration((int) $myReg['id']);
		if (empty($ghost)) {
			$_SESSION['pve_boss_error'] = 'No hay un Devorador activo para tu alianza. Espera al respawn.';
			HTTP::redirectTo('game.php?page=pve&mode=boss');
			return;
		}

		// ═══════════════════════════════════════════════════════════
		// Guardar target en sesión (mismo formato que attackPrepare)
		// ═══════════════════════════════════════════════════════════
		$_SESSION['pve_attack_target'] = array(
			'boss_event_id'    => (int) $event['id'],
			'boss_ghost_id'    => (int) $ghost['id'],
			'boss_ally_id'     => (int) $allyId,
			'galaxy'           => (int) $ghost['galaxy'],
			'system'           => (int) $ghost['system'],
			'planet'           => (int) $ghost['planet'],
			'type'             => 1,
			'mission'          => 23, // MISSION_PVE_BOSS_TOURNAMENT
			'acs_id'           => $acsId > 0 ? $acsId : 0,
			'created_at'       => TIMESTAMP,
		);

		if ($acsId > 0) {
			$_SESSION['pve_acs_id']        = $acsId;
			$_SESSION['pve_acs_boss_id']   = (int) $event['id'];
			$_SESSION['pve_acs_ghost_id']  = (int) $ghost['id'];
		}

		// Redirigir a fleetTable (selección de naves)
		HTTP::redirectTo('game.php?page=fleetTable');
		exit;
	}


	/* ============================================================
	 *  🆕 v6.0 — BASTIÓN ASEDIADO: PANEL PRINCIPAL
	 * ============================================================ */

	/**
	 * Página principal del Bastión Asediado.
	 *
	 * URL: game.php?page=pve&mode=bastion
	 *
	 * v6.2 — DUAL-RIEL:
	 *   · pool_preview ahora incluye pools separados (pool_ntx20 / pool_untx20)
	 *     y vista por riel del jugador (my_pool, my_fee, my_prize, my_currency).
	 *   · Mantiene campos legacy (total, fee, prize) calculados sobre
	 *     total_pool_ntx para retrocompatibilidad con templates viejos.
	 *
	 * Muestra:
	 *   - Estado del evento (scheduled / registration / active / finished)
	 *   - Bastión activo de tu alianza (HP, fase, coords, countdown)
	 *   - Oleadas piratas pendientes
	 *   - Ranking en vivo de alianzas (por score)
	 *   - Contribución interna de tu alianza
	 *   - Botón de inscripción (solo líder/sub-líder)
	 *   - Botón de envío de refuerzos (si tu alianza está inscrita)
	 */
	public function bastion()
	{
		global $USER;

		if (!PVEHelper::isEnabled()) {
			$this->printMessage('El sistema PvE está desactivado actualmente.');
			return;
		}

		if (!class_exists('PVEBastionHelper')) {
			$this->printMessage('El módulo del Bastión Asediado no está instalado.');
			return;
		}

		if (!PVEBastionHelper::isEnabled()) {
			$this->printMessage('El Bastión Asediado está desactivado actualmente.');
			return;
		}

		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;
		if ($userId <= 0) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		// v6.2 — Info de riel del jugador
		$rielInfo = $this->getRielVarsForUser($userId);

		// ─── Mi alianza + rango ───
		$myAllyId    = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$myAllyRank  = !empty($USER['ally_rank_id']) ? (int) $USER['ally_rank_id'] : 0;
		$myAllyName  = '';
		$myAllyTag   = '';

		if ($myAllyId > 0) {
			$db = Database::get();
			$sql = "SELECT ally_name, ally_tag FROM %%ALLIANCE%% WHERE id = :id LIMIT 1;";
			$allyData = $db->selectSingle($sql, array(':id' => $myAllyId));
			if (!empty($allyData)) {
				$myAllyName = $allyData['ally_name'];
				$myAllyTag  = $allyData['ally_tag'];
			}
		}

		// ─── Flash messages ───
		$bastionResult = null;
		$bastionError  = null;

		if (isset($_SESSION['pve_bastion_result'])) {
			$bastionResult = $_SESSION['pve_bastion_result'];
			unset($_SESSION['pve_bastion_result']);
		}
		if (isset($_SESSION['pve_bastion_error'])) {
			$bastionError = $_SESSION['pve_bastion_error'];
			unset($_SESSION['pve_bastion_error']);
		}

		// ─── Estado del evento ───
		$eventState = PVEBastionHelper::getEventState();
		$event      = PVEBastionHelper::getActiveEvent();

		// ─── Mi registration (si mi alianza está inscrita) ───
		$myRegistration = null;
		if ($event && $myAllyId > 0) {
			$myRegistration = PVEBastionHelper::getRegistration($event['id'], $myAllyId);
		}

		// ─── Bastión activo de mi alianza ───
		$myActiveGhost = null;
		if ($myRegistration) {
			$myActiveGhost = PVEBastionHelper::getActiveGhostForRegistration((int) $myRegistration['id']);
		}

		// ─── Ranking en vivo ───
		$ranking = array();
		if ($event) {
			try {
				$ranking = PVEBastionHelper::getLiveRanking((int) $event['id']);
			} catch (Exception $e) {
				$ranking = array();
			}
		}

		// ─── Contribución interna de mi alianza ───
		$myAllyContrib = array();
		if ($event && $myRegistration) {
			try {
				$myAllyContrib = PVEBastionHelper::getAllyDetail((int) $event['id'], (int) $myRegistration['id']);
			} catch (Exception $e) {
				$myAllyContrib = array();
			}
		}

		// ─── Oleadas pendientes (solo si hay bastión activo) ───
		$pendingWaves = array();
		if ($event && $myRegistration) {
			try {
				if (class_exists('PVEBastionWaveHelper')) {
					$allPending = PVEBastionWaveHelper::getPendingWaves((int) $event['id'], 20);
					foreach ($allPending as $w) {
						if ((int) $w['registration_id'] === (int) $myRegistration['id']) {
							$pendingWaves[] = $w;
						}
					}
				}
			} catch (Exception $e) {
				$pendingWaves = array();
			}
		}

		// ─── ¿Puede inscribir? (líder o sub-líder) ───
		$canRegister = false;
		if ($event && $event['status'] === 'registration' && $myAllyId > 0 && !$myRegistration) {
			$canRegister = PVEBastionHelper::canRegister($myAllyId, $myAllyRank);
		}

		// ─── ¿Puede reforzar? (inscrita + bastión activo + evento activo) ───
		$canReinforce = false;
		if ($event && $event['status'] === 'active' && $myRegistration && $myActiveGhost) {
			$canReinforce = true;
		}

		// ─── Preview del pool de premios (DUAL-RIEL) ───
		// v6.2 — Se exponen pools separados (ntx20/untx20) + vista por riel.
		//         Los campos legacy (total/fee/prize) se mantienen calculados
		//         sobre `total_pool_ntx` para retrocompatibilidad.
		$poolPreview = array(
			// Campos legacy (retrocompat)
			'total'      => 0,
			'fee'        => 0,
			'prize'      => 0,
			'type'       => 'ntx',
			'entry_mode' => 'free',

			// v6.2 — Pools duales reales
			'pool_ntx20'   => 0,
			'pool_untx20'  => 0,
			'fee_ntx20'    => 0,
			'fee_untx20'   => 0,
			'prize_ntx20'  => 0,
			'prize_untx20' => 0,
			'fee_pct'      => 0,

			// v6.2 — Vista del jugador actual (su riel)
			'my_pool'       => 0,
			'my_fee'        => 0,
			'my_prize'      => 0,
			'my_currency'   => $rielInfo['moneda'],
			'my_is_intl'    => !empty($rielInfo['isIntl']) ? 1 : 0,
			'my_multiplier' => (int) $rielInfo['multiplier'],

			// v6.2 — Coste de entrada (base y real)
			'entry_cost_base'     => 0,
			'entry_cost_real'     => 0,
			'entry_cost_currency' => $rielInfo['moneda'],
		);

		if ($event) {
			$poolPreview['entry_mode'] = $event['entry_mode'];
			$poolPreview['type']       = $event['prize_type'];

			$feePct = max(0, min(100, (int) $event['project_fee_pct']));
			$poolPreview['fee_pct'] = $feePct;

			$entryCostBase = (int) $event['entry_cost_ntx'];
			$poolPreview['entry_cost_base'] = $entryCostBase;
			$poolPreview['entry_cost_real'] = ($rielInfo['isIntl'])
				? ($entryCostBase * (int) $rielInfo['multiplier'])
				: $entryCostBase;

			if ($event['entry_mode'] === 'paid') {
				$poolNtx  = (int) ($event['pool_ntx20']  ?? 0);
				$poolUntx = (int) ($event['pool_untx20'] ?? 0);

				$feeNtx  = (int) floor($poolNtx  * $feePct / 100);
				$feeUntx = (int) floor($poolUntx * $feePct / 100);

				$prizeNtx  = max(0, $poolNtx  - $feeNtx);
				$prizeUntx = max(0, $poolUntx - $feeUntx);

				$poolPreview['pool_ntx20']   = $poolNtx;
				$poolPreview['pool_untx20']  = $poolUntx;
				$poolPreview['fee_ntx20']    = $feeNtx;
				$poolPreview['fee_untx20']   = $feeUntx;
				$poolPreview['prize_ntx20']  = $prizeNtx;
				$poolPreview['prize_untx20'] = $prizeUntx;

				// Legacy (total_pool_ntx = suma base)
				$poolPreview['total'] = (int) $event['total_pool_ntx'];
				$poolPreview['fee']   = (int) floor($poolPreview['total'] * $feePct / 100);
				$poolPreview['prize'] = $poolPreview['total'] - $poolPreview['fee'];

				// Vista del jugador
				if ($rielInfo['isIntl']) {
					$poolPreview['my_pool']  = $poolUntx;
					$poolPreview['my_fee']   = $feeUntx;
					$poolPreview['my_prize'] = $prizeUntx;
				} else {
					$poolPreview['my_pool']  = $poolNtx;
					$poolPreview['my_fee']   = $feeNtx;
					$poolPreview['my_prize'] = $prizeNtx;
				}
			} else {
				$basePrizeNtx = (int) $event['prize_ntx'];

				$poolPreview['prize'] = ($event['prize_type'] === 'ntx') ? $basePrizeNtx : 0;

				if ($event['prize_type'] === 'ntx') {
					$poolPreview['prize_ntx20']  = $basePrizeNtx;
					$poolPreview['prize_untx20'] = 0;

					$poolPreview['my_prize'] = ($rielInfo['isIntl'])
						? ($basePrizeNtx * (int) $rielInfo['multiplier'])
						: $basePrizeNtx;
					$poolPreview['my_pool'] = 0;
					$poolPreview['my_fee']  = 0;
				}
			}
		}

		$this->assign(array_merge(
			array(
				'pve_bastion'       => array(
					'event'             => $event,
					'event_state'       => $eventState,
					'my_ally_id'        => $myAllyId,
					'my_ally_rank'      => $myAllyRank,
					'my_ally_name'      => $myAllyName,
					'my_ally_tag'       => $myAllyTag,
					'my_registration'   => $myRegistration,
					'my_active_ghost'   => $myActiveGhost,
					'can_register'      => $canRegister,
					'can_reinforce'     => $canReinforce,
					'ranking'           => $ranking,
					'my_ally_contrib'   => $myAllyContrib,
					'pending_waves'     => $pendingWaves,
					'pool_preview'      => $poolPreview,
				),
				'bastionResult'     => $bastionResult,
				'bastionError'      => $bastionError,
			),
			$this->buildRielAssignVars($rielInfo)
		));

		$this->display('page.pve.bastion.tpl');
	}


	/* ============================================================
	 *  🆕 v6.0 — BASTIÓN ASEDIADO: INSCRIBIR ALIANZA
	 * ============================================================ */

	/**
	 * Inscribe la alianza del jugador en el Bastión Asediado.
	 * Solo el líder (o sub-líder) puede hacerlo.
	 *
	 * URL: POST game.php?page=pve&mode=registerBastion
	 */
	public function registerBastion()
	{
		global $USER;

		if (!PVEHelper::isEnabled()) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		if (!class_exists('PVEBastionHelper')) {
			$_SESSION['pve_bastion_error'] = 'El módulo del Bastión no está instalado.';
			HTTP::redirectTo('game.php?page=pve&mode=bastion');
			return;
		}

		$userId   = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$allyId   = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$allyRank = !empty($USER['ally_rank_id']) ? (int) $USER['ally_rank_id'] : 0;

		if ($userId <= 0 || $allyId <= 0) {
			$_SESSION['pve_bastion_error'] = 'Debes pertenecer a una alianza para inscribirla.';
			HTTP::redirectTo('game.php?page=pve&mode=bastion');
			return;
		}

		try {
			$result = PVEBastionHelper::registerAlliance($allyId, $userId, $allyRank);

			if (!empty($result['ok'])) {
				$_SESSION['pve_bastion_result'] = array(
					'message' => !empty($result['message']) ? $result['message'] : 'Alianza inscrita en el Bastión Asediado.',
				);
			} else {
				$_SESSION['pve_bastion_error'] = !empty($result['error']) ? $result['error'] : 'No se pudo inscribir la alianza.';
			}
		} catch (Throwable $e) {
			$_SESSION['pve_bastion_error'] = 'Error: ' . $e->getMessage();
		}

		HTTP::redirectTo('game.php?page=pve&mode=bastion');
		exit;
	}


	/* ============================================================
	 *  🆕 v6.0 — BASTIÓN ASEDIADO: RANKING EN VIVO (AJAX)
	 * ============================================================ */

	/**
	 * Endpoint AJAX que devuelve el ranking en vivo del Bastión en JSON.
	 *
	 * URL: GET game.php?page=pve&mode=bastionRankingJson&event_id=X
	 *
	 * v6.2 — DUAL-RIEL:
	 *   · Añade pool_ntx20 / pool_untx20 / prize_ntx20 / prize_untx20 /
	 *     fee_ntx20 / fee_untx20 (pools reales).
	 *   · Añade vista del jugador: my_pool, my_fee, my_prize, my_currency, my_is_intl.
	 *   · Añade entry_cost_base / entry_cost_real / entry_cost_currency.
	 *   · Mantiene campos legacy pool_ntx / prize_ntx (sobre total_pool_ntx)
	 *     para retrocompatibilidad con JS viejos.
	 *   · Sin queries extra: usa PVEHelper::getPlayerMethod() (cacheado).
	 *
	 * Devuelve:
	 *   {
	 *     ok, event_id, status, entry_mode,
	 *     bastions_alive, bastions_total, bastions_breached,
	 *     pool_ntx, prize_ntx,                                       ← legacy
	 *     pool_ntx20, pool_untx20,                                    ← v6.2
	 *     fee_ntx20, fee_untx20,                                      ← v6.2
	 *     prize_ntx20, prize_untx20,                                  ← v6.2
	 *     my_pool, my_fee, my_prize, my_currency, my_is_intl,         ← v6.2
	 *     entry_cost_base, entry_cost_real, entry_cost_currency,      ← v6.2
	 *     ranking: [{pos, ally_id, ally_name, score, pirates_killed, boss_pirates_killed, pct_hp, members, phase, status}],
	 *     user_ally_id, user_ally_pos,
	 *     user_registration: {hp_current, hp_max, hp_pct, phase, galaxy, system, planet}
	 *   }
	 */
	public function bastionRankingJson()
	{
		global $USER;

		header('Content-Type: application/json; charset=utf-8');

		if (!PVEHelper::isEnabled() || !class_exists('PVEBastionHelper')) {
			echo json_encode(array('ok' => false, 'error' => 'Módulo no disponible.'));
			exit;
		}

		$userId  = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$allyId  = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$eventId = (int) HTTP::_GP('event_id', 0);

		// v6.2 — Info de riel del jugador (una sola vez por request)
		$rielInfo = $this->getRielVarsForUser($userId);

		if ($eventId <= 0) {
			echo json_encode(array('ok' => false, 'error' => 'event_id requerido.'));
			exit;
		}

		$event = PVEBastionHelper::getEvent($eventId);
		if (empty($event)) {
			echo json_encode(array('ok' => false, 'error' => 'Evento no encontrado.'));
			exit;
		}

		// ─── Ranking ───
		$ranking = array();
		try {
			$ranking = PVEBastionHelper::getLiveRanking($eventId);
		} catch (Throwable $e) {
			$ranking = array();
		}

		// ─── Mi registration ───
		$myReg = null;
		$myGhost = null;
		$userAllyPos = 0;

		if ($allyId > 0) {
			$myReg = PVEBastionHelper::getRegistration($eventId, $allyId);
			if ($myReg) {
				$myGhost = PVEBastionHelper::getActiveGhostForRegistration((int) $myReg['id']);
			}
		}

		// Calcular posición de mi alianza en el ranking
		foreach ($ranking as $i => $r) {
			if ((int) $r['ally_id'] === $allyId) {
				$userAllyPos = $i + 1;
				break;
			}
		}

		// ─── Contadores ───
		$bastionsAlive    = 0;
		$bastionsTotal    = 0;
		$bastionsBreached = 0;

		try {
			$stats = PVEBastionHelper::getEventStats($eventId);
			$bastionsAlive    = isset($stats['bastions_alive'])    ? (int) $stats['bastions_alive']    : 0;
			$bastionsTotal    = isset($stats['bastions_total'])    ? (int) $stats['bastions_total']    : 0;
			$bastionsBreached = isset($stats['bastions_breached']) ? (int) $stats['bastions_breached'] : 0;
		} catch (Throwable $e) {
			// ignorar
		}

		// ─── Pool / premio (v6.2: dual-riel) ───
		$feePct     = max(0, min(100, (int) $event['project_fee_pct']));
		$poolLegacy = (int) $event['total_pool_ntx'];

		$poolNtx20  = (int) ($event['pool_ntx20']  ?? 0);
		$poolUntx20 = (int) ($event['pool_untx20'] ?? 0);

		$feeNtx20   = (int) floor($poolNtx20  * $feePct / 100);
		$feeUntx20  = (int) floor($poolUntx20 * $feePct / 100);

		$prizeNtx20  = max(0, $poolNtx20  - $feeNtx20);
		$prizeUntx20 = max(0, $poolUntx20 - $feeUntx20);

		// Legacy (retrocompat)
		$prizeLegacy = ($event['entry_mode'] === 'paid')
			? (int) floor($poolLegacy * (100 - $feePct) / 100)
			: (int) $event['prize_ntx'];

		// Vista del jugador
		$myPool  = $rielInfo['isIntl'] ? $poolUntx20  : $poolNtx20;
		$myFee   = $rielInfo['isIntl'] ? $feeUntx20   : $feeNtx20;
		$myPrize = $rielInfo['isIntl'] ? $prizeUntx20 : $prizeNtx20;

		if ($event['entry_mode'] !== 'paid' && $event['prize_type'] === 'ntx') {
			$basePrize = (int) $event['prize_ntx'];
			$myPrize = $rielInfo['isIntl']
				? ($basePrize * (int) $rielInfo['multiplier'])
				: $basePrize;
			$myPool = 0;
			$myFee  = 0;
		}

		// Coste de entrada (base y real)
		$entryCostBase = (int) $event['entry_cost_ntx'];
		$entryCostReal = $rielInfo['isIntl']
			? ($entryCostBase * (int) $rielInfo['multiplier'])
			: $entryCostBase;

		// ─── Preparar ranking limpio ───
		$cleanRanking = array();
		foreach ($ranking as $i => $r) {
			$cleanRanking[] = array(
				'pos'                 => $i + 1,
				'ally_id'             => (int) $r['ally_id'],
				'ally_name'           => isset($r['ally_name']) ? $r['ally_name'] : ('Alianza #' . $r['ally_id']),
				'ally_tag'            => isset($r['ally_tag']) ? $r['ally_tag'] : '',
				'score'               => isset($r['score_total']) ? (int) $r['score_total'] : 0,
				'pirates_killed'      => isset($r['pirates_killed']) ? (int) $r['pirates_killed'] : 0,
				'boss_pirates_killed' => isset($r['boss_pirates_killed']) ? (int) $r['boss_pirates_killed'] : 0,
				'pct_hp'              => isset($r['pct_hp_preserved']) ? (float) $r['pct_hp_preserved'] : 0,
				'members'             => isset($r['members_at_spawn']) ? (int) $r['members_at_spawn'] : 0,
				'phase'               => isset($r['current_phase']) ? (int) $r['current_phase'] : 0,
				'status'              => isset($r['status']) ? (string) $r['status'] : 'unknown',
				'is_me'               => ((int) $r['ally_id'] === $allyId) ? 1 : 0,
			);
		}

		// ─── Mi bastión ───
		$myGhostData = null;
		if ($myGhost) {
			$hpCurrent = (int) $myGhost['hp_current'];
			$hpMax     = max(1, (int) $myGhost['hp_max']);
			$myGhostData = array(
				'hp_current'   => $hpCurrent,
				'hp_max'       => $hpMax,
				'hp_pct'       => round($hpCurrent / $hpMax * 100, 2),
				'phase'        => (int) $myGhost['phase'],
				'galaxy'       => (int) $myGhost['galaxy'],
				'system'       => (int) $myGhost['system'],
				'planet'       => (int) $myGhost['planet'],
				'spawn_number' => (int) $myGhost['spawn_number'],
			);
		}

		echo json_encode(array(
			'ok'                 => true,
			'event_id'           => $eventId,
			'status'             => $event['status'],
			'entry_mode'         => $event['entry_mode'],
			'bastions_alive'     => $bastionsAlive,
			'bastions_total'     => $bastionsTotal,
			'bastions_breached'  => $bastionsBreached,

			// v6.2 — Pools duales reales
			'pool_ntx20'         => $poolNtx20,
			'pool_untx20'        => $poolUntx20,
			'fee_ntx20'          => $feeNtx20,
			'fee_untx20'         => $feeUntx20,
			'prize_ntx20'        => $prizeNtx20,
			'prize_untx20'       => $prizeUntx20,

			// v6.2 — Vista del jugador
			'my_pool'            => $myPool,
			'my_fee'             => $myFee,
			'my_prize'           => $myPrize,
			'my_currency'        => $rielInfo['moneda'],
			'my_is_intl'         => !empty($rielInfo['isIntl']) ? 1 : 0,

			// v6.2 — Coste de entrada
			'entry_cost_base'     => $entryCostBase,
			'entry_cost_real'     => $entryCostReal,
			'entry_cost_currency' => $rielInfo['moneda'],

			// Legacy (retrocompat)
			'pool_ntx'           => $poolLegacy,
			'prize_ntx'          => $prizeLegacy,

			'ranking'            => $cleanRanking,
			'user_ally_id'       => $allyId,
			'user_ally_pos'      => $userAllyPos,
			'user_registration'  => $myGhostData,
			'server_time'        => TIMESTAMP,
		));
		exit;
	}


	/* ============================================================
	 *  🆕 v6.0 — BASTIÓN ASEDIADO: PREPARAR REFUERZOS
	 * ============================================================ */

	/**
	 * Guarda el target del bastión en sesión y redirige a fleetTable.
	 * Funciona igual que attackPrepare() pero con mission=24 y
	 * las coordenadas del bastión activo de la alianza del jugador.
	 *
	 * URL: game.php?page=pve&mode=reinforcePrepare[&acs_id=Y]
	 */
	public function reinforcePrepare()
	{
		global $USER;

		if (!PVEHelper::isEnabled()) {
			HTTP::redirectTo('game.php?page=pve');
			return;
		}

		if (!class_exists('PVEBastionHelper')) {
			$_SESSION['pve_bastion_error'] = 'El módulo del Bastión no está instalado.';
			HTTP::redirectTo('game.php?page=pve&mode=bastion');
			return;
		}

		$userId = !empty($USER['id']) ? (int) $USER['id'] : 0;
		$allyId = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
		$acsId  = (int) HTTP::_GP('acs_id', 0);

		if ($userId <= 0 || $allyId <= 0) {
			$_SESSION['pve_bastion_error'] = 'Debes pertenecer a una alianza.';
			HTTP::redirectTo('game.php?page=pve&mode=bastion');
			return;
		}

		$event = PVEBastionHelper::getActiveEvent();
		if (empty($event) || $event['status'] !== 'active') {
			$_SESSION['pve_bastion_error'] = 'El evento del Bastión no está activo.';
			HTTP::redirectTo('game.php?page=pve&mode=bastion');
			return;
		}

		$myReg = PVEBastionHelper::getRegistration((int) $event['id'], $allyId);
		if (empty($myReg)) {
			$_SESSION['pve_bastion_error'] = 'Tu alianza no está inscrita en el Bastión.';
			HTTP::redirectTo('game.php?page=pve&mode=bastion');
			return;
		}

		$ghost = PVEBastionHelper::getActiveGhostForRegistration((int) $myReg['id']);
		if (empty($ghost)) {
			$_SESSION['pve_bastion_error'] = 'No hay un Bastión activo para tu alianza.';
			HTTP::redirectTo('game.php?page=pve&mode=bastion');
			return;
		}

		// ═══════════════════════════════════════════════════════════
		// Guardar target en sesión (mismo formato que attackPrepare)
		// ═══════════════════════════════════════════════════════════
		$_SESSION['pve_attack_target'] = array(
			'bastion_event_id'    => (int) $event['id'],
			'bastion_ghost_id'    => (int) $ghost['id'],
			'bastion_ally_id'     => (int) $allyId,
			'galaxy'              => (int) $ghost['galaxy'],
			'system'              => (int) $ghost['system'],
			'planet'              => (int) $ghost['planet'],
			'type'                => 1,
			'mission'             => 24, // MISSION_PVE_BASTION
			'acs_id'              => $acsId > 0 ? $acsId : 0,
			'created_at'          => TIMESTAMP,
		);

		if ($acsId > 0) {
			$_SESSION['pve_acs_id']          = $acsId;
			$_SESSION['pve_acs_bastion_id']  = (int) $event['id'];
			$_SESSION['pve_acs_ghost_id']    = (int) $ghost['id'];
		}

		// Redirigir a fleetTable (selección de naves)
		HTTP::redirectTo('game.php?page=fleetTable');
		exit;
	}
}