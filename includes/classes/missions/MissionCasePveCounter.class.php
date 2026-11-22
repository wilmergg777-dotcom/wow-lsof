<?php

/**
 * AstroIO — MissionCasePveCounter
 * Procesa la llegada de una flota de contraataque del imperio/boss (misión 22)
 * al planeta del jugador.
 * Reutiliza el motor de combate nativo xnova (calculateAttack).
 *
 * Ubicación: includes/classes/missions/MissionCasePveCounter.class.php
 * @package AstroIO
 * @version 1.2
 *   - v1.1: FIX: añadidos require_once de PveFleetHelper y PVEHelper
 *           INFORME DE BATALLA: genera reporte en %%RW%% y lo enlaza al mensaje
 *   - v1.2: SOPORTE TORNEO DEL DEVORADOR:
 *           Detecta si el contraataque viene de un Imperio o de un Boss
 *           Tournament (mirando si el fleet_start_id apunta a un ghost
 *           empire o a un boss ghost). Carga el nombre correcto y loguea
 *           con event_type='empire' o 'boss' según corresponda.
 *           Sin cambios de comportamiento para Empire/Crisis.
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

class MissionCasePveCounter extends MissionFunctions implements Mission
{
	function __construct($Fleet)
	{
		$this->_fleet = $Fleet;
	}


	/* ============================================================
	 *  LLEGADA AL PLANETA (combate + robo)
	 * ============================================================ */

	function TargetEvent()
	{
		global $reslist, $resource, $pricelist;

		$db     = Database::get();
		$config = Config::get($this->_fleet['fleet_universe']);

		// ─── 1) Cargar planeta destino y su dueño ───
		$sql = "SELECT * FROM %%PLANETS%% WHERE id = :planetId LIMIT 1;";
		$targetPlanet = $db->selectSingle($sql, array(
			':planetId' => $this->_fleet['fleet_end_id'],
		));

		if (empty($targetPlanet)) {
			$this->KillFleet();
			return;
		}

		$sql = "SELECT * FROM %%USERS%% WHERE id = :userId LIMIT 1;";
		$targetUser = $db->selectSingle($sql, array(
			':userId' => $targetPlanet['id_owner'],
		));

		if (empty($targetUser)) {
			$this->KillFleet();
			return;
		}

		$targetUser['factor'] = getFactors($targetUser, 'basic', $this->_fleet['fleet_start_time']);

		// Actualizar recursos al momento del impacto
		$planetUpdater = new ResourceUpdate();
		list($targetUser, $targetPlanet) = $planetUpdater->CalcResource(
			$targetUser,
			$targetPlanet,
			true,
			$this->_fleet['fleet_start_time']
		);

		// ═══════════════════════════════════════════════════════════
		// 2) Identificar el ORIGEN del contraataque
		//    - Empire / Crisis  → %%PVE_EMPIRES%% (id < 900M)
		//    - Boss Tournament  → %%PVE_BOSS_GHOSTS%% (id >= 900M, event_type='boss')
		//
		// El fleet_start_id del contraataque se construyó en
		// PveFleetHelper::sendCounterAttackFleet() como:
		//     EMPIRE_ID_OFFSET + $empire['id']
		// donde $empire['id'] es:
		//   - Empire: id del imperio en %%PVE_EMPIRES%%
		//   - Boss:   ghost_user_id del boss (>= 900M)
		// ═══════════════════════════════════════════════════════════
		$rawOriginId = (int) $this->_fleet['fleet_start_id'] - PveFleetHelper::EMPIRE_ID_OFFSET;

		$empire       = array();
		$empireName   = 'Imperio Caído';
		$logEventType = 'empire';
		$logEventId   = $rawOriginId;
		$isBossGhost  = false;

		if ($rawOriginId >= 900000000) {
			// ─── Es un fantasma (Boss Tournament o similar) ───
			if (class_exists('PVEGhostHelper')) {
				$ghostRow = PVEGhostHelper::getGhostByUserId($rawOriginId);
				if (!empty($ghostRow) && isset($ghostRow['event_type'])
					&& $ghostRow['event_type'] === 'boss') {

					$isBossGhost  = true;
					$logEventType = 'boss';

					// Cargar datos del boss ghost (por user_id) para el nombre
					$sql = "SELECT bg.*, be.boss_name AS event_boss_name, be.id AS event_id_real
					        FROM %%PVE_BOSS_GHOSTS%% bg
					        LEFT JOIN %%PVE_BOSS_EVENT%% be ON be.id = bg.event_id
					        WHERE bg.ghost_user_id = :uid
					        ORDER BY bg.id DESC
					        LIMIT 1;";
					$bossGhost = $db->selectSingle($sql, array(':uid' => $rawOriginId));

					if (!empty($bossGhost)) {
						$logEventId = (int) $bossGhost['event_id'];
						if (!empty($bossGhost['event_boss_name'])) {
							$empireName = (string) $bossGhost['event_boss_name'];
						} else {
							$empireName = 'El Devorador Estelar';
						}
					} else {
						$empireName = 'El Devorador Estelar';
					}
				}
			}

			// Si no era boss pero sí un fantasma, mantenemos los fallbacks
			// (empire id fuera de rango → probablemente fantasma huérfano).
		} else {
			// ─── Es un imperio/crisis normal ───
			$empireId = $rawOriginId;

			if ($empireId > 0) {
				$sql = "SELECT * FROM %%PVE_EMPIRES%% WHERE id = :id LIMIT 1;";
				$empire = $db->selectSingle($sql, array(':id' => $empireId));

				if (!empty($empire['name'])) {
					$empireName = $empire['name'];
				}
			}
		}
		// ═══════════════════════════════════════════════════════════
		// FIN IDENTIFICACIÓN DE ORIGEN
		// ═══════════════════════════════════════════════════════════

		// ─── 3) Construir atacante (imperio o boss) ───
		$attackerUnits = FleetFunctions::unserialize($this->_fleet['fleet_array']);

		if (empty($attackerUnits)) {
			$this->KillFleet();
			return;
		}

		$attackerFleetId = (int) $this->_fleet['fleet_id'];

		$fleetAttack = array(
			$attackerFleetId => array(
				'player' => array(
					'id'            => 0,
					'username'      => $empireName,
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

		// ─── 4) Construir defensor (planeta + flotas estacionadas) ───
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

		// 4b) Defensas y naves del planeta
		$defenderUnits = array();
		foreach (array_merge($reslist['fleet'], $reslist['defense']) as $elementId) {
			$colName = $resource[$elementId];
			if (!empty($targetPlanet[$colName])) {
				$defenderUnits[$elementId] = (int) $targetPlanet[$colName];
			}
		}

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

		// ─── 6) Aplicar pérdidas al planeta del jugador ───
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

		// ✅ v3.8 — Aplicar también las pérdidas de las flotas ESTACIONADAS
		// (misión 5). Antes solo se actualizaba el planeta: las flotas
		// estacionadas luchaban, perdían naves… y esas naves "resucitaban"
		// porque su fleet_array nunca se escribía de vuelta (quedaban al
		// 100% para el siguiente combate).
		foreach ($fleetDefend as $defFleetId => $defFleet) {
			if (!is_numeric($defFleetId) || (int) $defFleetId === 0) continue;
			if (empty($defFleet['unit']) || !is_array($defFleet['unit'])) continue;

			$fleetArray = '';
			$totalCount = 0;
			foreach ($defFleet['unit'] as $elementId => $amount) {
				$amount = max(0, (int) $amount);
				if ($amount <= 0) continue;
				$fleetArray .= $elementId . ',' . $amount . ';';
				$totalCount += $amount;
			}

			if ($totalCount > 0) {
				$sql = "UPDATE %%FLEETS%% SET
					fleet_array  = :fleetData,
					fleet_amount = :fleetCount
				 WHERE fleet_id = :fleetId;";
				$db->update($sql, array(
					':fleetData'  => rtrim($fleetArray, ';'),
					':fleetCount' => $totalCount,
					':fleetId'    => (int) $defFleetId,
				));
			} else {
				// Flota estacionada destruida por completo → eliminarla
				$sql = 'DELETE %%FLEETS%%, %%FLEETS_EVENT%%
					FROM %%FLEETS%%
					INNER JOIN %%FLEETS_EVENT%% ON fleetID = fleet_id
					WHERE fleet_id = :fleetId;';
				$db->delete($sql, array(':fleetId' => (int) $defFleetId));

				$sql = 'UPDATE %%LOG_FLEETS%% SET fleet_state = :fleetState WHERE fleet_id = :fleetId;';
				$db->update($sql, array(
					':fleetId'    => (int) $defFleetId,
					':fleetState' => FLEET_HOLD,
				));
			}
		}

		// ─── 7) Robar recursos si el imperio/boss gana ───
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

		// ─── 8) Métricas ───
		$shipsLostDefender = (int) $combatResult['unitLost']['defender'];
		$shipsLostAttacker = (int) $combatResult['unitLost']['attacker'];
		$totalStolen       = (int) ($stolen[901] + $stolen[902] + $stolen[903]);

		$defenderUnitsLeft = 0;
		foreach ($planetUnitsAfter as $amount) {
			$defenderUnitsLeft += (int) $amount;
		}
		$survived = ($defenderUnitsLeft > 0) ? 1 : 0;

		// ─── 8.5) INFORME DE BATALLA PvE ───
		// v1.1 — Genera el reporte en %%RW%% para que el mensaje incluya
		//        el enlace "Ver informe de batalla".
		// v1.2 — Soporta también contraataques del boss tournament.
		$reportID = null;

		if (class_exists('PveBattleReportHelper')) {
			$reportID = PveBattleReportHelper::save(
				$combatResult,
				$this->_fleet,
				$stolen,                                    // recursos robados por el atacante
				array(),                                    // atacantes: imperio/boss (id 0 → se filtra a "-1")
				array((int) $targetUser['id'])              // defensores: jugador atacado
			);

			if (empty($reportID)) {
				PVEHelper::log($logEventType, $logEventId, 'report_generation_failed', 0, 0, array(
					'fleet_id' => $attackerFleetId,
					'origin_id'=> $rawOriginId,
					'is_boss'  => $isBossGhost ? 1 : 0,
				));
			}
		}

		// ─── 9) Mensaje al jugador ───
		$this->sendPlayerMessage(
			$targetUser,
			$targetPlanet,
			$empireName,
			$combatResult,
			$stolen,
			$survived,
			$reportID,
			$isBossGhost
		);

		// ─── 10) Log ───
		PVEHelper::log($logEventType, $logEventId, 'counterattack_resolved', $targetUser['id'], $targetPlanet['id'], array(
			'won'        => $combatResult['won'],
			'stolen'     => $totalStolen,
			'survived'   => $survived,
			'fleet_id'   => $attackerFleetId,
			'report_id'  => $reportID,
			'origin_id'  => $rawOriginId,
			'is_boss'    => $isBossGhost ? 1 : 0,
		));

		// ─── 11) La flota del imperio/boss se retira con el botín ───
		$this->setState(FLEET_RETURN);
		$this->SaveFleet();
	}


	/* ============================================================
	 *  END STAY (no aplica)
	 * ============================================================ */

	function EndStayEvent()
	{
		return;
	}


	/* ============================================================
	 *  RETORNO (la flota del imperio/boss se elimina)
	 * ============================================================ */

	function ReturnEvent()
	{
		// El contraataque "vuelve" al origen pero no hay planeta real → se destruye
		$this->KillFleet();
	}


	/* ============================================================
	 *  MENSAJE AL JUGADOR
	 * ============================================================ */

	private function sendPlayerMessage($user, $planet, $empireName, $combatResult, $stolen, $survived, $reportID = null, $isBossGhost = false)
	{
		try {
			// v1.2 — Título diferenciado para boss vs imperio
			$title = $isBossGhost
				? "[PvE] Contraataque del Devorador " . $empireName
				: "[PvE] Contraataque del " . $empireName;

			$resultText = 'Empate';
			if ($combatResult['won'] === 'a') {
				$resultText = 'Derrota';
			} elseif ($combatResult['won'] === 'r') {
				$resultText = 'Victoria';
			}

			// v1.2 — Texto diferenciado para boss vs imperio
			if ($isBossGhost) {
				$body  = "El <b>" . $empireName . "</b> (Torneo del Devorador) lanzó un contraataque contra tu planeta [" . (int) $planet['galaxy'] . ":" . (int) $planet['system'] . ":" . (int) $planet['planet'] . "].<br><br>";
			} else {
				$body  = "El <b>" . $empireName . "</b> lanzó un contraataque contra tu planeta [" . (int) $planet['galaxy'] . ":" . (int) $planet['system'] . ":" . (int) $planet['planet'] . "].<br><br>";
			}

			$body .= "<b>Resultado:</b> " . $resultText . "<br>";
			$body .= "<b>Naves perdidas:</b> " . number_format((int) $combatResult['unitLost']['defender']) . "<br>";
			$body .= "<b>Naves enemigas destruidas:</b> " . number_format((int) $combatResult['unitLost']['attacker']) . "<br>";
			$body .= "<b>Recursos robados:</b><br>";
			$body .= "&nbsp;&nbsp;- Metal: " . number_format((int) $stolen[901]) . "<br>";
			$body .= "&nbsp;&nbsp;- Cristal: " . number_format((int) $stolen[902]) . "<br>";
			$body .= "&nbsp;&nbsp;- Deuterio: " . number_format((int) $stolen[903]) . "<br>";

			if ($survived) {
				$body .= "<br><b>Resististe el contraataque.</b>";
			} else {
				$body .= "<br><b style='color: #ff8888;'>Tu planeta quedó sin defensas.</b>";
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
			PVEHelper::log('empire', 0, 'msg_error', $user['id'], $planet['id'], array(
				'error' => $e->getMessage(),
			));
		}
	}
}