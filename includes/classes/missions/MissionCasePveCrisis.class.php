<?php

/**
 * AstroIO — MissionCasePveCrisis
 * Procesa la llegada de una flota de piratas (misión 20) al planeta del jugador.
 * Reutiliza el motor de combate nativo xnova (calculateAttack).
 *
 * Ubicación: includes/classes/missions/MissionCasePveCrisis.class.php
 * @package AstroIO
 * @version 1.3
 *   - GUARD anti-doble-procesamiento (verifica fleet_mess=0)
 *   - Logs en planet/user no encontrado
 *   - damage_done = costo(naves atacante perdidas) × 0.5
 *   - defenses_lost calculado aparte de ships_lost
 *   - Log de excepción en tryFinishCrisis
 *   - Guard contra $crisis null/empty
 *   - INFORME DE BATALLA: genera reporte en %%RW%% y lo enlaza al mensaje
 */

// ============================================
// ASTROIO — Dependencias PvE (evita "Class not found")
// ============================================
if (!class_exists('PveFleetHelper')) {
    require_once ROOT_PATH . 'includes/classes/PveFleetHelper.class.php';
}
if (!class_exists('PVEHelper')) {
    require_once ROOT_PATH . 'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVECrisisHelper')) {
    require_once ROOT_PATH . 'includes/classes/PVECrisisHelper.class.php';
}
if (!class_exists('PVEEmpireHelper')) {
    require_once ROOT_PATH . 'includes/classes/PVEEmpireHelper.class.php';
}
if (!class_exists('PVEGhostHelper')) {
    require_once ROOT_PATH . 'includes/classes/PVEGhostHelper.class.php';
}
if (!class_exists('PveBattleReportHelper')) {
    require_once ROOT_PATH . 'includes/classes/PveBattleReportHelper.class.php';
}
// ============================================

class MissionCasePveCrisis extends MissionFunctions implements Mission
{
	function __construct($Fleet)
	{
		$this->_fleet = $Fleet;
	}


	/* ============================================================
	 *  LLEGADA AL PLANETA (combate)
	 * ============================================================ */

	function TargetEvent()
	{
		global $reslist, $resource, $pricelist;

		$db     = Database::get();
		$config = Config::get($this->_fleet['fleet_universe']);

		$fleetId = (int) $this->_fleet['fleet_id'];

		// ─── 0) GUARD anti-doble-procesamiento ────────────────────
		// Releer fleet_mess desde BD para confirmar que esta flota
		// sigue en estado Target (0). Si ya está en RETURN (1) o
		// eliminada, salir sin hacer nada.
		$freshFleet = $db->selectSingle(
			"SELECT fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fid LIMIT 1;",
			array(':fid' => $fleetId)
		);

		if (empty($freshFleet)) {
			PVEHelper::log('crisis', 0, 'fleet_already_deleted', 0, 0, array(
				'fleet_id' => $fleetId,
			));
			return;
		}

		if ((int) $freshFleet['fleet_mess'] !== 0) {
			PVEHelper::log('crisis', 0, 'fleet_already_processed', 0, 0, array(
				'fleet_id'   => $fleetId,
				'fleet_mess' => (int) $freshFleet['fleet_mess'],
			));
			return;
		}

		// ─── 1) Cargar datos del planeta destino y su dueño ───
		$sql = "SELECT * FROM %%PLANETS%% WHERE id = :planetId LIMIT 1;";
		$targetPlanet = $db->selectSingle($sql, array(
			':planetId' => $this->_fleet['fleet_end_id'],
		));

		if (empty($targetPlanet)) {
			PVEHelper::log('crisis', 0, 'target_planet_not_found', 0, (int) $this->_fleet['fleet_end_id'], array(
				'fleet_id' => $fleetId,
			));
			$this->KillFleet();
			return;
		}

		$sql = "SELECT * FROM %%USERS%% WHERE id = :userId LIMIT 1;";
		$targetUser = $db->selectSingle($sql, array(
			':userId' => $targetPlanet['id_owner'],
		));

		if (empty($targetUser)) {
			PVEHelper::log('crisis', 0, 'target_user_not_found', 0, (int) $targetPlanet['id'], array(
				'fleet_id'   => $fleetId,
				'id_owner'   => (int) $targetPlanet['id_owner'],
			));
			$this->KillFleet();
			return;
		}

		$targetUser['factor'] = getFactors($targetUser, 'basic', $this->_fleet['fleet_start_time']);

		// Actualizar recursos del planeta al momento del impacto
		$planetUpdater = new ResourceUpdate();
		list($targetUser, $targetPlanet) = $planetUpdater->CalcResource(
			$targetUser,
			$targetPlanet,
			true,
			$this->_fleet['fleet_start_time']
		);

		// ─── 2) Cargar crisis asociada (desde fleet_target_obj) ───
		$crisisId = (int) $this->_fleet['fleet_target_obj'];

		$crisis = null;
		if ($crisisId > 0) {
			$sql = "SELECT * FROM %%PVE_CRISIS%% WHERE id = :id LIMIT 1;";
			$crisis = $db->selectSingle($sql, array(':id' => $crisisId));
		}

		// Obtener facción y número de oleada desde la wave asociada
		$faction     = 1;
		$waveNumber  = 1;
		$waveId      = 0;

		if (!empty($crisis) && is_array($crisis)) {
			$faction = (int) $crisis['faction'];

			// Buscar la wave más reciente ejecutada para esta crisis
			$sql = "SELECT id, wave_number FROM %%PVE_CRISIS_WAVES%%
			        WHERE crisis_id = :cid AND executed = 1
			        ORDER BY executed_at DESC LIMIT 1;";
			$wave = $db->selectSingle($sql, array(':cid' => $crisisId));
			if (!empty($wave)) {
				$waveNumber = (int) $wave['wave_number'];
				$waveId     = (int) $wave['id'];
			}
		}

		// ─── 3) Construir atacante (piratas) ───
		$attackerUnits = FleetFunctions::unserialize($this->_fleet['fleet_array']);

		if (empty($attackerUnits)) {
			PVEHelper::log('crisis', $crisisId, 'attacker_units_empty', 0, 0, array(
				'fleet_id' => $fleetId,
			));
			$this->KillFleet();
			return;
		}

		// ✅ Snapshot ANTES del combate (para calcular pérdidas reales)
		$attackerUnitsBefore = $attackerUnits;

		$attackerFleetId = (int) $this->_fleet['fleet_id'];

		$fleetAttack = array(
			$attackerFleetId => array(
				'player' => array(
					'id'            => 0,
					'username'      => PveFleetHelper::getFactionName($faction) . ' (Oleada ' . $waveNumber . ')',
					'military_tech' => 0,
					'defence_tech'  => 0,
					'shield_tech'   => 0,
					'factor'        => array(
						'Attack'      => 0,
						'Defensive'   => 0,
						'Shield'      => 0,
						'ShipStorage' => 0,
					),
				),
				'fleetDetail' => array(
					'fleet_id'                 => $attackerFleetId,
					'fleet_owner'              => 0,
					'fleet_start_galaxy'       => (int) $this->_fleet['fleet_start_galaxy'],
					'fleet_start_system'       => (int) $this->_fleet['fleet_start_system'],
					'fleet_start_planet'       => (int) $this->_fleet['fleet_start_planet'],
					'fleet_start_type'         => 1,
					'fleet_resource_metal'     => 0,
					'fleet_resource_crystal'   => 0,
					'fleet_resource_deuterium' => 0,
				),
				'unit' => $attackerUnits,
			),
		);

		// ─── 4) Construir defensor (jugador + flotas estacionadas) ───
		$fleetDefend = array();

		// 4a) Flotas estacionadas del jugador (mission=5)
		$sql = "SELECT * FROM %%FLEETS%%
		        WHERE fleet_mission = 5
		          AND fleet_end_id = :planetId
		          AND fleet_start_time <= :timeStamp
		          AND fleet_end_stay >= :timeStamp;";
		$targetFleetsResult = $db->select($sql, array(
			':planetId'  => $this->_fleet['fleet_end_id'],
			':timeStamp' => TIMESTAMP,
		));

		foreach ($targetFleetsResult as $fleetDetail) {
			$stationedFleetId = (int) $fleetDetail['fleet_id'];

			$sql = "SELECT * FROM %%USERS%% WHERE id = :userId LIMIT 1;";
			$stationedPlayer = $db->selectSingle($sql, array(
				':userId' => $fleetDetail['fleet_owner'],
			));

			if (empty($stationedPlayer)) {
				continue;
			}

			$fleetDefend[$stationedFleetId] = array(
				'player' => array(
					'id'            => $stationedPlayer['id'],
					'username'      => $stationedPlayer['username'],
					'military_tech' => (int) $stationedPlayer['military_tech'],
					'defence_tech'  => (int) $stationedPlayer['defence_tech'],
					'shield_tech'   => (int) $stationedPlayer['shield_tech'],
					'factor'        => getFactors($stationedPlayer, 'attack', $this->_fleet['fleet_start_time']),
				),
				'fleetDetail' => array(
					'fleet_id'                 => $stationedFleetId,
					'fleet_owner'              => (int) $fleetDetail['fleet_owner'],
					'fleet_start_galaxy'       => (int) $fleetDetail['fleet_start_galaxy'],
					'fleet_start_system'       => (int) $fleetDetail['fleet_start_system'],
					'fleet_start_planet'       => (int) $fleetDetail['fleet_start_planet'],
					'fleet_start_type'         => (int) $fleetDetail['fleet_start_type'],
					'fleet_resource_metal'     => 0,
					'fleet_resource_crystal'   => 0,
					'fleet_resource_deuterium' => 0,
				),
				'unit' => FleetFunctions::unserialize($fleetDetail['fleet_array']),
			);
		}

		// 4b) Defensas y naves del planeta (jugador con ID 0 = planeta)
		$defenderUnits = array();
		foreach (array_merge($reslist['fleet'], $reslist['defense']) as $elementId) {
			$colName = $resource[$elementId];
			if (!empty($targetPlanet[$colName])) {
				$defenderUnits[$elementId] = (int) $targetPlanet[$colName];
			}
		}

		// ✅ Snapshot ANTES del combate para calcular pérdidas reales
		$defenderUnitsBefore = $defenderUnits;

		$fleetDefend[0] = array(
			'player' => array(
				'id'            => $targetUser['id'],
				'username'      => $targetUser['username'],
				'military_tech' => (int) $targetUser['military_tech'],
				'defence_tech'  => (int) $targetUser['defence_tech'],
				'shield_tech'   => (int) $targetUser['shield_tech'],
				'factor'        => getFactors($targetUser, 'attack', $this->_fleet['fleet_start_time']),
			),
			'fleetDetail' => array(
				'fleet_id'                 => 0,
				'fleet_owner'              => (int) $targetUser['id'],
				'fleet_start_galaxy'       => (int) $targetPlanet['galaxy'],
				'fleet_start_system'       => (int) $targetPlanet['system'],
				'fleet_start_planet'       => (int) $targetPlanet['planet'],
				'fleet_start_type'         => (int) $targetPlanet['planet_type'],
				'fleet_resource_metal'     => 0,
				'fleet_resource_crystal'   => 0,
				'fleet_resource_deuterium' => 0,
			),
			'unit' => $defenderUnits,
		);

		// ─── 5) Ejecutar combate ───
		require_once ROOT_PATH.'includes/classes/missions/functions/calculateAttack.php';

		$combatResult = calculateAttack(
			$fleetAttack,
			$fleetDefend,
			$config->Fleet_Cdr,
			$config->Defs_Cdr
		);

		// ─── 6) Aplicar pérdidas al planeta (naves + defensas) ───
		$planetUnitsAfter = isset($fleetDefend[0]['unit']) ? $fleetDefend[0]['unit'] : array();

		$updateFields = array();
		$updateParams = array(':id' => $targetPlanet['id']);

		foreach ($planetUnitsAfter as $elementId => $amount) {
			$colName = isset($resource[$elementId]) ? $resource[$elementId] : '';
			if ($colName === '') continue;

			$updateFields[] = "`$colName` = :col_$elementId";
			$updateParams[":col_$elementId"] = max(0, (int) $amount);
		}

		if (!empty($updateFields)) {
			$sql = "UPDATE %%PLANETS%% SET " . implode(', ', $updateFields) . " WHERE id = :id;";
			$db->update($sql, $updateParams);
		}

		// ─── 7) Robar recursos si los piratas ganan ───
		$stolen = array(901 => 0, 902 => 0, 903 => 0);

		if ($combatResult['won'] === 'a') {
			require_once ROOT_PATH.'includes/classes/missions/functions/calculateSteal.php';

			$stolen = calculateSteal($fleetAttack, $targetPlanet, true);

			if (!empty($stolen) && ($stolen[901] + $stolen[902] + $stolen[903]) > 0) {
				$sql = "UPDATE %%PLANETS%% SET
					metal     = GREATEST(0, metal - :metal),
					crystal   = GREATEST(0, crystal - :crystal),
					deuterium = GREATEST(0, deuterium - :deuterium)
					WHERE id = :id;";
				$db->update($sql, array(
					':metal'     => $stolen[901],
					':crystal'   => $stolen[902],
					':deuterium' => $stolen[903],
					':id'        => $targetPlanet['id'],
				));
			}
		}

		// ─── 8) Calcular métricas (pérdidas reales + daño real) ───

		// 8a) Pérdidas del defensor (planeta) — separadas en ships / defenses
		$shipsLostDefender    = 0;
		$defensesLostDefender = 0;

		foreach ($defenderUnitsBefore as $elementId => $before) {
			$after = isset($planetUnitsAfter[$elementId]) ? (int) $planetUnitsAfter[$elementId] : 0;
			$lost  = max(0, (int) $before - $after);

			if ($lost <= 0) {
				continue;
			}

			if (in_array($elementId, $reslist['defense'])) {
				$defensesLostDefender += $lost;
			} else {
				$shipsLostDefender += $lost;
			}
		}

		// 8b) Daño real hecho por el defensor = costo(naves atacante perdidas) × 0.5
		$attackerUnitsAfter = isset($fleetAttack[$attackerFleetId]['unit'])
			? $fleetAttack[$attackerFleetId]['unit']
			: array();

		$damageDone = 0;

		foreach ($attackerUnitsBefore as $elementId => $before) {
			$after = isset($attackerUnitsAfter[$elementId]) ? (int) $attackerUnitsAfter[$elementId] : 0;
			$lost  = max(0, (int) $before - $after);

			if ($lost <= 0 || !isset($pricelist[$elementId]['cost'])) {
				continue;
			}

			$unitCost = (isset($pricelist[$elementId]['cost'][901]) ? (int) $pricelist[$elementId]['cost'][901] : 0)
			          + (isset($pricelist[$elementId]['cost'][902]) ? (int) $pricelist[$elementId]['cost'][902] : 0);

			$damageDone += $lost * $unitCost * 0.5;
		}

		$damageDone = (int) floor($damageDone);

		$shipsLostAttacker = (int) $combatResult['unitLost']['attacker'];
		$totalStolen       = (int) ($stolen[901] + $stolen[902] + $stolen[903]);

		$defenderUnitsLeft = 0;
		foreach ($planetUnitsAfter as $amount) {
			$defenderUnitsLeft += (int) $amount;
		}
		$survived = ($defenderUnitsLeft > 0) ? 1 : 0;

		// ─── 9) Dificultad (para el registro) ───
		$sqlPoints = "SELECT total_points FROM %%STATPOINTS%% 
		              WHERE id_owner = :uid AND stat_type = 1 AND universe = :uni";
		$totalPoints = $db->selectSingle($sqlPoints, array(
			':uid' => $targetUser['id'],
			':uni' => $targetUser['universe'],
		), 'total_points');
		$difficulty = PVECrisisHelper::getDifficultyLevel((int) $totalPoints);

		// ─── 10) Registrar ataque en pve_crisis_attacks ───
		if ($crisisId > 0 && !empty($crisis)) {
			$sql = "INSERT INTO %%PVE_CRISIS_ATTACKS%% SET
				crisis_id         = :crisisId,
				wave_id           = :waveId,
				user_id           = :userId,
				planet_id         = :planetId,
				difficulty_level  = :difficulty,
				ships_lost        = :shipsLost,
				defenses_lost     = :defensesLost,
				resources_stolen  = :stolen,
				damage_done       = :damage,
				survived          = :survived,
				attack_time       = :now;";

			$db->insert($sql, array(
				':crisisId'     => $crisisId,
				':waveId'       => $waveId,
				':userId'       => $targetUser['id'],
				':planetId'     => $targetPlanet['id'],
				':difficulty'   => $difficulty,
				':shipsLost'    => $shipsLostDefender,
				':defensesLost' => $defensesLostDefender,
				':stolen'       => $totalStolen,
				':damage'       => $damageDone,
				':survived'     => $survived,
				':now'          => TIMESTAMP,
			));
		}

		// ─── 10.5) INFORME DE BATALLA PvE ───
		// v1.3 — Genera el reporte en %%RW%% para que el mensaje incluya
		//        el enlace "Ver informe de batalla".
		$reportID = null;

		if (class_exists('PveBattleReportHelper')) {
			$reportID = PveBattleReportHelper::save(
				$combatResult,
				$this->_fleet,
				$stolen,                                    // recursos robados por los piratas
				array(),                                    // atacantes: piratas (id 0 → se filtra a "-1")
				array((int) $targetUser['id'])              // defensores: jugador atacado
			);

			if (empty($reportID)) {
				PVEHelper::log('crisis', $crisisId, 'report_generation_failed', 0, 0, array(
					'fleet_id' => $fleetId,
				));
			}
		}

		// ─── 11) Mensaje al jugador ───
		$this->sendPlayerMessage(
			$targetUser,
			$targetPlanet,
			$faction,
			$waveNumber,
			$combatResult,
			$stolen,
			$survived,
			$reportID
		);

		// ─── 12) Log ───
		PVEHelper::log('crisis', $crisisId, 'fleet_resolved', $targetUser['id'], $targetPlanet['id'], array(
			'fleet_id'       => $fleetId,
			'wave'           => $waveNumber,
			'won'            => $combatResult['won'],
			'stolen'         => $totalStolen,
			'ships_lost'     => $shipsLostDefender,
			'defenses_lost'  => $defensesLostDefender,
			'damage_done'    => $damageDone,
			'survived'       => $survived,
			'report_id'      => $reportID,
		));

		// ─── 13) Intentar finalizar la crisis ───
		if ($crisisId > 0 && class_exists('PVECrisisHelper')) {
			try {
				PVECrisisHelper::tryFinishCrisis($crisisId);
			} catch (Exception $e) {
				PVEHelper::log('crisis', $crisisId, 'try_finish_error', 0, 0, array(
					'error' => $e->getMessage(),
					'file'  => $e->getFile(),
					'line'  => $e->getLine(),
				));
			}
		}

		// ─── 14) Cambiar a RETURN (los piratas vuelven con el botín) ───
		$this->setState(FLEET_RETURN);
		$this->SaveFleet();
	}


	/* ============================================================
	 *  END STAY (no aplica para crisis)
	 * ============================================================ */

	function EndStayEvent()
	{
		PVEHelper::log('crisis', 0, 'end_stay_unexpected', 0, 0, array(
			'fleet_id' => (int) $this->_fleet['fleet_id'],
		));
		return;
	}


	/* ============================================================
	 *  RETORNO DE LA FLOTA PIRATA (se elimina)
	 * ============================================================ */

	function ReturnEvent()
	{
		PVEHelper::log('crisis', 0, 'fleet_returned_and_killed', 0, 0, array(
			'fleet_id' => (int) $this->_fleet['fleet_id'],
		));

		// Los piratas simplemente se van con el botín
		$this->KillFleet();
	}


	/* ============================================================
	 *  MENSAJE AL JUGADOR
	 * ============================================================ */

	private function sendPlayerMessage($user, $planet, $faction, $waveNumber, $combatResult, $stolen, $survived, $reportID = null)
	{
		try {
			$factionName = PveFleetHelper::getFactionName($faction);

			$title = "[PvE] Crisis de Fin de Mes - Oleada " . (int) $waveNumber . " (" . $factionName . ")";

			$resultText = 'Empate';
			if ($combatResult['won'] === 'a') {
				$resultText = 'Derrota';
			} elseif ($combatResult['won'] === 'r') {
				$resultText = 'Victoria';
			}

			$body  = "Tu planeta [" . (int) $planet['galaxy'] . ":" . (int) $planet['system'] . ":" . (int) $planet['planet'] . "] fue atacado por <b>" . $factionName . "</b>.<br><br>";
			$body .= "<b>Resultado:</b> " . $resultText . "<br>";
			$body .= "<b>Naves perdidas:</b> " . number_format((int) $combatResult['unitLost']['defender']) . "<br>";
			$body .= "<b>Naves enemigas destruidas:</b> " . number_format((int) $combatResult['unitLost']['attacker']) . "<br>";
			$body .= "<b>Recursos robados:</b><br>";
			$body .= "&nbsp;&nbsp;- Metal: " . number_format((int) $stolen[901]) . "<br>";
			$body .= "&nbsp;&nbsp;- Cristal: " . number_format((int) $stolen[902]) . "<br>";
			$body .= "&nbsp;&nbsp;- Deuterio: " . number_format((int) $stolen[903]) . "<br>";

			if ($survived) {
				$body .= "<br><b>&iexcl;Sobreviviste a la oleada!</b>";
			} else {
				$body .= "<br><b style='color: #ff8888;'>Fuiste destruido en esta oleada.</b>";
			}

			// ─── Enlace al informe de batalla (si se generó correctamente) ───
			if (!empty($reportID)) {
				$body .= '<br><br><a href="game.php?page=raport&raport=' . $reportID . '" target="_blank" style="display:inline-block;padding:6px 14px;background:#1e3a5a;border:1px solid #4a9eff;border-radius:4px;color:#4a9eff;font-weight:bold;text-decoration:none;">&raquo; Ver informe de batalla completo</a>';
			}

			PlayerUtil::sendMessage(
				$user['id'], 0, 'Comando Central PvE', 3, $title, $body,
				TIMESTAMP, null, 1, $user['universe']
			);
		} catch (Exception $e) {
			PVEHelper::log('crisis', 0, 'msg_error', $user['id'], $planet['id'], array(
				'error' => $e->getMessage(),
			));
		}
	}
}