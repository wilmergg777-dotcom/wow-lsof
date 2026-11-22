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
 * AstroIO v3.2:
 *  - Misiones PvE nativas (20, 21, 22) en el pattern
 *  - Detección automática de fantasmas: si mission=1 (ATTACK solo)
 *    o mission=2 (ACS ATTACK) y el destino es un fantasma (ID >= 900M),
 *    se redirige a MissionCasePveEmpire SIN tocar el flujo PvP.
 *  - 🆕 v3.2: null-check defensivo en $fleetResult
 *  - 🆕 v3.3 (FASE 9): detección de ataques PvP en arena/torneo
 *    y marcado de flota con pvp_type/pvp_ref_id/pvp_match_id
 *
 * AstroIO v3.3:
 *  - 🆕 Añadida misión 23 (MISSION_PVE_BOSS) → MissionCasePveBossTournament
 *  - 🆕 Detección de fantasmas mejorada: ahora lee el event_type del ghost
 *    ('empire' → MissionCasePveEmpire, 'boss' → MissionCasePveBossTournament)
 *    para que los ataques con UI nativa a fantasmas del torneo se enruten bien.
 *
 * AstroIO v3.4 (Bastión Asediado):
 *  - 🆕 Añadidas misiones 24 (MISSION_PVE_BASTION) y 25 (MISSION_PIRATE_ATTACK)
 *  - 🆕 Detección de fantasmas amplía a 'bastion' → MissionCasePveBastion
 *  - 🆕 Los piratas del bastión (mission=25) se enrutan a MissionCasePirateAttack
 *
 * AstroIO v3.5 (ASTEROIDES - FIX):
 *  - 🆕 Añadida misión 32 (RECICLAJE DE ASTEROIDE) → MissionCaseRecycling
 *    Sin esta entrada, las flotas con misión 32 eran BORRADAS silenciosamente
 *    por el bloque "misión desconocida" (DELETE FROM %%FLEETS%%).
 *    Ahora se enrutan correctamente a MissionCaseRecycling, que detecta
 *    el asteroide por coordenadas y lo recicla.
 *  - 🆕 Añadido log defensivo en cache/asteroid_error.log para trazar
 *    qué misión llega y si está o no en el pattern.
 *
 * NOTA PvE (crisis):
 *  Las flotas de crisis usan fleet_mission=20, fleet_owner=0 y coords
 *  de origen 99:99:99. Este handler NO las filtra por owner, así que
 *  se procesan correctamente vía MissionCasePveCrisis::TargetEvent()
 *  siempre que exista entrada en uni1_fleet_event (la inserta
 *  PveFleetHelper::sendCrisisFleet()).
 *
 * NOTA FASE 9 (PvP):
 *  Solo se marca la flota (no se bloquea el ataque). El registro
 *  de daño se hace en calculateAttack.php leyendo la columna
 *  pvp_type de la flota. Los ataques fuera de arena/torneo pasan
 *  como PvP normal de 2Moons sin tocar nada.
 *
 * NOTA TORNEO DEVORADOR:
 *  - Las flotas del torneo usan fleet_mission=23 (MISSION_PVE_BOSS).
 *  - Se registran en $missionObjPattern y se enrutan directamente a
 *    MissionCasePveBossTournament::TargetEvent().
 *  - El fantasma del torneo se identifica por event_type='boss' en
 *    uni1_pve_ghosts y se distingue de los fantasmas de Imperio ('empire').
 *
 * NOTA BASTIÓN ASEDIADO:
 *  - Refuerzos del jugador → mission=24 → MissionCasePveBastion
 *  - Ataques piratas autogenerados → mission=25 → MissionCasePirateAttack
 *  - El fantasma del bastión se identifica por event_type='bastion' en
 *    uni1_pve_ghosts y se distingue de 'empire' y 'boss'.
 */

class FlyingFleetHandler
{	
	protected $token;
	
	public static $missionObjPattern	= array(
		1	=> 'MissionCaseAttack',
		2	=> 'MissionCaseACS',
		3	=> 'MissionCaseTransport',
		4	=> 'MissionCaseStay',
		5	=> 'MissionCaseStayAlly',
		6	=> 'MissionCaseSpy',
		7	=> 'MissionCaseColonisation',
		8	=> 'MissionCaseRecycling',
		9	=> 'MissionCaseDestruction',
		10	=> 'MissionCaseMIP',
		11	=> 'MissionCaseFoundDM',
		15	=> 'MissionCaseExpedition',
		// AstroIO - Misiones PvE
		20	=> 'MissionCasePveCrisis',
		21	=> 'MissionCasePveEmpire',
		22	=> 'MissionCasePveCounter',
		// AstroIO - Torneo del Devorador
		23	=> 'MissionCasePveBossTournament',
		// AstroIO - Bastión Asediado
		24	=> 'MissionCasePveBastion',
		25	=> 'MissionCasePirateAttack',
		// AstroIO v3.5 - Reciclaje de Asteroide
		32	=> 'MissionCaseRecycling',
	);
		
	function setToken($token)
	{
		$this->token	= $token;
	}
	
	function run()
	{
		require_once 'includes/classes/class.MissionFunctions.php';
		require_once 'includes/classes/missions/Mission.interface.php';

		$db	= Database::get();

		// ============================================
		// ASTROIO v3.5 - Log defensivo
		// ============================================
		$logDir = defined('ROOT_PATH') ? ROOT_PATH : dirname(__FILE__) . '/../../';
		// ============================================

		$sql = 'SELECT %%FLEETS%%.*
		FROM %%FLEETS_EVENT%%
		INNER JOIN %%FLEETS%% ON fleetID = fleet_id
		WHERE `lock` = :token;';

		$fleetResult = $db->select($sql, array(
			':token'	=> $this->token
		));

		// ✅ NUEVO v3.2: si no hay flotas listas, salir limpiamente
		if (empty($fleetResult)) {
			return;
		}

		foreach($fleetResult as $fleetRow)
		{
			// ============================================
			// ASTROIO v3.5 - Log defensivo de entrada
			// ============================================
			@file_put_contents(
				$logDir . 'cache/asteroid_error.log',
				'[' . date('Y-m-d H:i:s') . '] FFH procesando: fleet_id=' . $fleetRow['fleet_id']
				. ' mission=' . $fleetRow['fleet_mission']
				. ' mess=' . $fleetRow['fleet_mess']
				. ' end_id=' . $fleetRow['fleet_end_id']
				. ' coords=' . $fleetRow['fleet_end_galaxy'] . ':' . $fleetRow['fleet_end_system'] . ':' . $fleetRow['fleet_end_planet']
				. ' enPattern=' . (isset(self::$missionObjPattern[$fleetRow['fleet_mission']]) ? 'SI' : 'NO')
				. PHP_EOL,
				FILE_APPEND
			);
			// ============================================

			// ═══════════════════════════════════════════════════════════
			// ASTROIO — Detección de fantasmas PvE
			// ═══════════════════════════════════════════════════════════
			// Missions nativas que pueden apuntar a un fantasma:
			//   - mission=1 (ATTACK solo)  → UI fleetStep1 sin ACS
			//   - mission=2 (ACS ATTACK)   → UI fleetStep1 con ACS
			//
			// Si el target es un fantasma (fleet_end_id >= 900M),
			// redirigimos a la misión PvE correspondiente según el
			// event_type del fantasma:
			//   - 'empire'  → MissionCasePveEmpire      (Imperio Caído)
			//   - 'boss'    → MissionCasePveBossTournament (Torneo del Devorador)
			//   - 'bastion' → MissionCasePveBastion     (Bastión Asediado)
			//
			// Esto NO rompe el PvP:
			//   - Los ataques PvP reales usan IDs < 900M → flujo normal
			//   - Solo si fleet_end_id >= 900M y el fantasma existe → PvE
			//   - Missions 3, 4, 5... siguen igual
			//
			// NOTA: Las misiones 20/21/22/23/24/25 NO pasan por este bloque,
			//       van directas al pattern match de abajo.
			// ═══════════════════════════════════════════════════════════
			$fleetMission = (int) $fleetRow['fleet_mission'];
			$fleetEndId   = (int) $fleetRow['fleet_end_id'];

			if (($fleetMission === 1 || $fleetMission === 2) && $fleetEndId >= 900000000) {
				// Solo procesar en TargetEvent (fleet_mess=0), no en Return ni EndStay
				if ((int) $fleetRow['fleet_mess'] === 0) {
					// Verificar que realmente existe un fantasma activo
					if (!class_exists('PVEGhostHelper')) {
						$ghostHelperPath = ROOT_PATH . 'includes/classes/PVEGhostHelper.class.php';
						if (file_exists($ghostHelperPath)) {
							require_once $ghostHelperPath;
						}
					}

					if (class_exists('PVEGhostHelper')) {
						$ghost = PVEGhostHelper::getGhostByUserId($fleetEndId);
						if (!empty($ghost)) {
							// ✅ Determinar qué tipo de fantasma es
							$ghostType = isset($ghost['event_type']) ? (string) $ghost['event_type'] : 'empire';

							// Enrutar según tipo de fantasma
							// - 'boss'    → Torneo del Devorador (ataque)
							// - 'bastion' → Bastión Asediado (refuerzo)
							// - resto     → MissionCasePveEmpire (Imperio/Crisis)
							if ($ghostType === 'boss') {
								$missionName = 'MissionCasePveBossTournament';
							} elseif ($ghostType === 'bastion') {
								$missionName = 'MissionCasePveBastion';
							} else {
								$missionName = 'MissionCasePveEmpire';
							}

							$path = 'includes/classes/missions/' . $missionName . '.class.php';
							if (file_exists(ROOT_PATH . $path)) {
								require_once $path;

								/** @var Mission $missionObj */
								$missionObj = new $missionName($fleetRow);
								$missionObj->TargetEvent();

								continue;
							}
						}
					}
				}
			}
			// ═══════════════════════════════════════════════════════════
			// FIN DETECCIÓN FANTASMA
			// ═══════════════════════════════════════════════════════════

			// ═══════════════════════════════════════════════════════════
			// ASTROIO — FASE 9 PvP: Detección de ataques en arena/torneo
			// ═══════════════════════════════════════════════════════════
			// Solo actúa cuando:
			//   - fleet_mission = 1 (ATTACK solo, sin ACS)
			//   - fleet_mess    = 0 (llega al destino, TargetEvent)
			//
			// Qué hace:
			//   1) ¿Atacante y defensor están en la MISMA arena activa?
			//      → marca la flota: pvp_type='arena', pvp_ref_id=<arena_id>
			//   2) Si no, ¿están emparejados en un torneo activo?
			//      → marca la flota: pvp_type='tournament',
			//        pvp_ref_id=<tournament_id>, pvp_match_id=<match_id>
			//   3) Si no aplica nada → deja la flota como PvP normal
			//      (no se registra daño en arena/torneo)
			//
			// El daño se registrará luego en calculateAttack.php,
			// leyendo la columna pvp_type de la flota.
			//
			// NOTA 1: El bloqueo de ataques a jugadores fuera de la
			//         arena/torneo NO está activado en esta versión.
			//         Los ataques ajenos pasan como PvP normal.
			// NOTA 2: Torneos de alianza NO soportados aún en esta
			//         detección (los miembros no líderes no se
			//         detectan porque la inscripción usa user_id=líder).
			// ═══════════════════════════════════════════════════════════
			if ($fleetMission === 1 && (int) $fleetRow['fleet_mess'] === 0) {

				// Cargar helpers PvP (lazy)
				if (!class_exists('PVPArenaHelper')) {
					$arenaHelperFile = ROOT_PATH . 'includes/classes/PVPArenaHelper.class.php';
					if (file_exists($arenaHelperFile)) {
						require_once $arenaHelperFile;
					}
				}
				if (!class_exists('PVPTournamentHelper')) {
					$tourneyHelperFile = ROOT_PATH . 'includes/classes/PVPTournamentHelper.class.php';
					if (file_exists($tourneyHelperFile)) {
						require_once $tourneyHelperFile;
					}
				}

				$pvpAttackerId = (int) $fleetRow['fleet_owner'];
				$pvpDefenderId = (int) $fleetRow['fleet_target_owner'];
				$pvpFleetId    = (int) $fleetRow['fleet_id'];
				$pvpMarked     = false;

				if ($pvpAttackerId > 0 && $pvpDefenderId > 0) {

					// ─── CASO 1: Arena ───
					if (class_exists('PVPArenaHelper')) {
						$pvpArenaId = PVPArenaHelper::areInSameArena($pvpAttackerId, $pvpDefenderId);
						if ($pvpArenaId > 0) {
							$db->update(
								"UPDATE %%FLEETS%% 
								 SET `pvp_type` = :pt, `pvp_ref_id` = :rid, `pvp_match_id` = 0 
								 WHERE `fleet_id` = :fid;",
								array(
									':pt'  => 'arena',
									':rid' => (int) $pvpArenaId,
									':fid' => $pvpFleetId,
								)
							);
							$pvpMarked = true;
						}
					}

					// ─── CASO 2: Torneo (solo si no se marcó como arena) ───
					if (!$pvpMarked && class_exists('PVPTournamentHelper')) {
						$pvpTourneyId = PVPTournamentHelper::getActiveTournamentForUser($pvpAttackerId);
						if ($pvpTourneyId > 0) {
							$pvpMatchId = PVPTournamentHelper::canAttack($pvpTourneyId, $pvpAttackerId, $pvpDefenderId);
							if ($pvpMatchId !== false && (int) $pvpMatchId > 0) {
								$db->update(
									"UPDATE %%FLEETS%% 
									 SET `pvp_type` = :pt, `pvp_ref_id` = :tid, `pvp_match_id` = :mid 
									 WHERE `fleet_id` = :fid;",
									array(
										':pt'  => 'tournament',
										':tid' => (int) $pvpTourneyId,
										':mid' => (int) $pvpMatchId,
										':fid' => $pvpFleetId,
									)
								);
								$pvpMarked = true;
							}
						}
					}
				}
			}
			// ═══════════════════════════════════════════════════════════
			// FIN FASE 9 PvP
			// ═══════════════════════════════════════════════════════════

			if(!isset(self::$missionObjPattern[$fleetRow['fleet_mission']])) {
				// ============================================
				// ASTROIO v3.5 - Log defensivo del asesino
				// ============================================
				@file_put_contents(
					$logDir . 'cache/asteroid_error.log',
					'[' . date('Y-m-d H:i:s') . '] ⚠️ MISIÓN DESCONOCIDA, BORRANDO FLOTA: fleet_id='
					. $fleetRow['fleet_id'] . ' mission=' . $fleetRow['fleet_mission'] . PHP_EOL,
					FILE_APPEND
				);
				// ============================================

				$sql = 'DELETE FROM %%FLEETS%% WHERE fleet_id = :fleetId;';

				$db->delete($sql, array(
					':fleetId'	=> $fleetRow['fleet_id']
			  	));

				continue;
			}
			
			$missionName	= self::$missionObjPattern[$fleetRow['fleet_mission']];

			$path	= 'includes/classes/missions/'.$missionName.'.class.php';
			require_once $path;
			/** @var $missionObj Mission */
			$missionObj	= new $missionName($fleetRow);
			
			switch($fleetRow['fleet_mess'])
			{
				case 0:
					$missionObj->TargetEvent();
				break;
				case 1:
					$missionObj->ReturnEvent();
				break;
				case 2:
					$missionObj->EndStayEvent();
				break;
			}
		}
	}
}