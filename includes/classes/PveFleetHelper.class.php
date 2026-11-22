<?php

/**
 * AstroIO — PveFleetHelper
 * Helper para crear/gestionar flotas reales de las misiones PvE.
 * Reutiliza el sistema nativo de flotas de xnova (uni1_fleets + fleet_event).
 *
 * v2.2 — FIX: fleet_target_owner = dueño real del planeta (para que aparezca en fleetTable como PvP)
 *
 * v2.3 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Este helper NO toca NTX-20 ni UNTX-20 en ningún punto.
 *   · Solo crea/gestiona flotas reales (naves + deuterio + fleet_event + log).
 *   · Los campos `fleet_resource_metal/crystal/deuterium` que inserta son
 *     SIEMPRE 0 (la flota no transporta recursos del jugador).
 *   · No hay detección de riel, ni getPlayerMethod(), ni isIntl(),
 *     ni addBalance(), ni removeBalance(), ni WalletHelper, ni
 *     NTX20LogHelper.
 *   · Se añaden las constantes UNTX_MULTIPLIER y RIELS por coherencia
 *     con PVPHelper / PVEHelper / PVECrisisHelper / PVEEmpireHelper /
 *     PVEAchievementHelper, aunque este archivo no las use funcionalmente.
 *   · Se documenta explícitamente en el header por qué NO aplica dual-riel
 *     (para evitar "arreglos" futuros innecesarios).
 *
 * Ubicación: includes/classes/PveFleetHelper.class.php
 * @package AstroIO
 * @version 2.3
 */

class PveFleetHelper
{
	/* ============================================================
	 *  CONSTANTES
	 * ============================================================ */

	// Regla ×2 centralizada (por coherencia con el resto de helpers PvE/PvP)
	const UNTX_MULTIPLIER = 2;

	// Rieles válidos
	const RIELS = array('CUP', 'QVAPAY');

	/** Coordenadas ficticias de origen de los piratas (galaxia 99, sistema 99, planeta 99) */
	const PIRATE_GALAXY = 99;
	const PIRATE_SYSTEM = 99;
	const PIRATE_PLANET = 99;

	/** Offset de IDs para imperios en el campo fleet_end_id (para no chocar con planetas reales) */
	const EMPIRE_ID_OFFSET = 1000000000;


	/* ============================================================
	 *  CRISIS — FLOTA DE PIRATAS (mission=20)
	 * ============================================================ */

	public static function sendCrisisFleet($crisisId, $waveId, $targetPlanet, $enemyFleet)
	{
		$db = Database::get();

		if (empty($enemyFleet) || empty($targetPlanet['id'])) {
			return null;
		}

		$flightMin = (int) PVEHelper::get('crisis_flight_min', 30);
		$flightMax = (int) PVEHelper::get('crisis_flight_max', 120);

		if ($flightMax < $flightMin) {
			$flightMax = $flightMin;
		}

		$flightSeconds = mt_rand($flightMin, $flightMax) * 60;

		$fleetStartTime = TIMESTAMP + $flightSeconds;
		$fleetStayTime  = $fleetStartTime;
		$fleetEndTime   = $fleetStartTime + $flightSeconds;

		$fleetData     = array();
		$fleetAmount   = 0;
		foreach ($enemyFleet as $shipId => $count) {
			$count = (int) $count;
			if ($count <= 0) continue;
			$fleetData[] = $shipId . ',' . floatToString($count);
			$fleetAmount += $count;
		}

		if ($fleetAmount <= 0) {
			return null;
		}

		$fleetArrayStr = implode(';', $fleetData);

		// ✅ FIX: el dueño real del planeta atacado → para que aparezca en su fleetTable
		$targetOwnerId = (int) $targetPlanet['id_owner'];

		$sql = 'INSERT INTO %%FLEETS%% SET
			fleet_owner                 = 0,
			fleet_target_owner          = :targetOwner,
			fleet_mission               = :mission,
			fleet_amount                = :fleetAmount,
			fleet_array                 = :fleetArray,
			fleet_universe              = :universe,
			fleet_start_time            = :fleetStartTime,
			fleet_end_stay              = :fleetStayTime,
			fleet_end_time              = :fleetEndTime,
			fleet_start_id              = 0,
			fleet_start_galaxy          = :startGalaxy,
			fleet_start_system          = :startSystem,
			fleet_start_planet          = :startPlanet,
			fleet_start_type            = 1,
			fleet_end_id                = :targetPlanetId,
			fleet_end_galaxy            = :targetGalaxy,
			fleet_end_system            = :targetSystem,
			fleet_end_planet            = :targetPlanet,
			fleet_end_type              = :targetType,
			fleet_resource_metal        = 0,
			fleet_resource_crystal      = 0,
			fleet_resource_deuterium    = 0,
			fleet_resource_darkmatter   = 0,
			fleet_group                 = 0,
			fleet_target_obj            = 0,
			fleet_mess                  = 0,
			start_time                  = :timestamp;';

		$db->insert($sql, array(
			':targetOwner'      => $targetOwnerId,
			':mission'          => MISSION_PVE_CRISIS,
			':fleetAmount'      => $fleetAmount,
			':fleetArray'       => $fleetArrayStr,
			':universe'         => (int) $targetPlanet['universe'],
			':fleetStartTime'   => $fleetStartTime,
			':fleetStayTime'    => $fleetStayTime,
			':fleetEndTime'     => $fleetEndTime,
			':startGalaxy'      => self::PIRATE_GALAXY,
			':startSystem'      => self::PIRATE_SYSTEM,
			':startPlanet'      => self::PIRATE_PLANET,
			':targetPlanetId'   => (int) $targetPlanet['id'],
			':targetGalaxy'     => (int) $targetPlanet['galaxy'],
			':targetSystem'     => (int) $targetPlanet['system'],
			':targetPlanet'     => (int) $targetPlanet['planet'],
			':targetType'       => (int) $targetPlanet['planet_type'],
			':timestamp'        => TIMESTAMP,
		));

		$fleetId = $db->lastInsertId();

		if (empty($fleetId)) {
			return null;
		}

		try {
			$sql = 'INSERT INTO %%FLEETS_EVENT%% SET fleetID = :fleetId, `time` = :endTime, `lock` = NULL;';
			$db->insert($sql, array(
				':fleetId' => $fleetId,
				':endTime' => $fleetStartTime,
			));
		} catch (Throwable $e) {
			// ✅ v3.8 — Compensación: sin evento, FlyingFleetHandler nunca
			// procesaría la oleada pirata (quedaría congelada para siempre y
			// el planeta objetivo esperaría una crisis que nunca llega).
			try {
				$db->delete("DELETE FROM %%FLEETS%% WHERE fleet_id = :fid;", array(':fid' => (int) $fleetId));
			} catch (Throwable $e2) {}
			return null;
		}

		$sql = 'INSERT INTO %%LOG_FLEETS%% SET
			fleet_id                    = :fleetId,
			fleet_owner                 = 0,
			fleet_target_owner          = :targetOwner,
			fleet_mission               = :mission,
			fleet_amount                = :fleetAmount,
			fleet_array                 = :fleetArray,
			fleet_universe              = :universe,
			fleet_start_time            = :fleetStartTime,
			fleet_end_stay              = :fleetStayTime,
			fleet_end_time              = :fleetEndTime,
			fleet_start_id              = 0,
			fleet_start_galaxy          = :startGalaxy,
			fleet_start_system          = :startSystem,
			fleet_start_planet          = :startPlanet,
			fleet_start_type            = 1,
			fleet_end_id                = :targetPlanetId,
			fleet_end_galaxy            = :targetGalaxy,
			fleet_end_system            = :targetSystem,
			fleet_end_planet            = :targetPlanet,
			fleet_end_type              = :targetType,
			fleet_resource_metal        = 0,
			fleet_resource_crystal      = 0,
			fleet_resource_deuterium    = 0,
			fleet_group                 = 0,
			fleet_target_obj            = 0,
			start_time                  = :timestamp;';

		$db->insert($sql, array(
			':fleetId'          => $fleetId,
			':targetOwner'      => $targetOwnerId,
			':mission'          => MISSION_PVE_CRISIS,
			':fleetAmount'      => $fleetAmount,
			':fleetArray'       => $fleetArrayStr,
			':universe'         => (int) $targetPlanet['universe'],
			':fleetStartTime'   => $fleetStartTime,
			':fleetStayTime'    => $fleetStayTime,
			':fleetEndTime'     => $fleetEndTime,
			':startGalaxy'      => self::PIRATE_GALAXY,
			':startSystem'      => self::PIRATE_SYSTEM,
			':startPlanet'      => self::PIRATE_PLANET,
			':targetPlanetId'   => (int) $targetPlanet['id'],
			':targetGalaxy'     => (int) $targetPlanet['galaxy'],
			':targetSystem'     => (int) $targetPlanet['system'],
			':targetPlanet'     => (int) $targetPlanet['planet'],
			':targetType'       => (int) $targetPlanet['planet_type'],
			':timestamp'        => TIMESTAMP,
		));

		return (int) $fleetId;
	}


	/* ============================================================
	 *  IMPERIO — ATAQUE DEL JUGADOR (mission=21) + ACS
	 * ============================================================ */

	public static function sendEmpireAttackFleet($userId, $empireId, $planetId, $fleetArray, $acsId = 0, $flightSpeed = 10, $acsOptions = array())
	{
		global $USER;

		$db = Database::get();

		$userId   = (int) $userId;
		$empireId = (int) $empireId;
		$planetId = (int) $planetId;
		$acsId    = (int) $acsId;

		if ($userId <= 0 || $empireId <= 0 || $planetId <= 0 || empty($fleetArray)) {
			return array('success' => false, 'error' => 'Datos inválidos.');
		}

		$sql = "SELECT * FROM %%PVE_EMPIRES%% WHERE id = :id AND status = 'active' LIMIT 1;";
		$empire = $db->selectSingle($sql, array(':id' => $empireId));

		if (empty($empire)) {
			return array('success' => false, 'error' => 'Imperio no encontrado o inactivo.');
		}

		if ((int) $empire['end_time'] <= TIMESTAMP) {
			return array('success' => false, 'error' => 'El imperio ya expiró.');
		}

		$sql = "SELECT * FROM %%PLANETS%% WHERE id = :id AND id_owner = :uid AND planet_type = 1 LIMIT 1;";
		$planet = $db->selectSingle($sql, array(':id' => $planetId, ':uid' => $userId));

		if (empty($planet)) {
			return array('success' => false, 'error' => 'Planeta no encontrado.');
		}

		$sql = "SELECT * FROM %%USERS%% WHERE id = :id LIMIT 1;";
		$user = $db->selectSingle($sql, array(':id' => $userId));

		if (empty($user)) {
			return array('success' => false, 'error' => 'Usuario no encontrado.');
		}

		global $resource;

		$shipsToSend = array();
		foreach ($fleetArray as $shipId => $count) {
			$shipId = (int) $shipId;
			$count  = (int) $count;
			if ($shipId <= 0 || $count <= 0) continue;

			$colName = $resource[$shipId];
			$available = !empty($planet[$colName]) ? (int) $planet[$colName] : 0;

			if ($available < $count) {
				return array('success' => false, 'error' => 'No tienes suficientes naves (' . $colName . ').');
			}

			$shipsToSend[$shipId] = $count;
		}

		if (empty($shipsToSend)) {
			return array('success' => false, 'error' => 'No hay naves seleccionadas.');
		}

		$distance    = FleetFunctions::GetTargetDistance(
			array($planet['galaxy'], $planet['system'], $planet['planet']),
			array($empire['galaxy'], $empire['system'], $empire['planet'])
		);

		$maxSpeed    = FleetFunctions::GetFleetMaxSpeed($shipsToSend, $user);
		$gameSpeed   = FleetFunctions::GetGameSpeedFactor();

		if ($maxSpeed <= 0) {
			return array('success' => false, 'error' => 'Velocidad de flota inválida.');
		}

		if ($flightSpeed < 1 || $flightSpeed > 10) {
			$flightSpeed = 10;
		}

		$duration    = FleetFunctions::GetMissionDuration($flightSpeed, $maxSpeed, $distance, $gameSpeed, $user);
		$duracion    = (int) ceil($duration);
		if ($duracion < 1) $duracion = 1;

		$consumption = 0;
		$checkDiv    = ($duracion * $gameSpeed) - 10;
		if ($checkDiv > 0) {
			$consumption = (int) FleetFunctions::GetFleetConsumption($shipsToSend, $duracion, $distance, $user, $gameSpeed);
		}

		$deuterioDisponible = (int) $planet['deuterium'];
		if ($deuterioDisponible < $consumption) {
			return array('success' => false, 'error' => 'No tienes suficiente deuterio (necesitas ' . $consumption . ').');
		}

		// ACS: unirse a uno existente o crear nuevo
		$isNewAcs      = false;
		$acsLeaderId   = 0;
		$invitesCount  = 0;

		if ($acsId > 0) {
			// ─── Unirse a ACS existente ───
			$sql = "SELECT * FROM %%AKS%% WHERE id = :id LIMIT 1;";
			$acs = $db->selectSingle($sql, array(':id' => $acsId));

			if (empty($acs)) {
				return array('success' => false, 'error' => 'El ACS no existe.');
			}

			$sql = "SELECT * FROM %%USERS_ACS%% WHERE userID = :uid AND acsID = :aid LIMIT 1;";
			$alreadyIn = $db->selectSingle($sql, array(':uid' => $userId, ':aid' => $acsId));

			if (!empty($alreadyIn)) {
				return array('success' => false, 'error' => 'Ya estás en este ACS.');
			}

			if (!self::canUserJoinAcs($userId, $acsId)) {
				return array('success' => false, 'error' => 'No tienes permiso para unirte a este ACS.');
			}

			$acsLeaderId = isset($acs['created_by']) ? (int) $acs['created_by'] : 0;

		} else {
			// ─── Crear ACS nuevo con visibilidad ───
			$visibility     = isset($acsOptions['visibility']) ? $acsOptions['visibility'] : 'public';
			if (!in_array($visibility, array('public', 'ally', 'invite'))) {
				$visibility = 'public';
			}

			$allyId         = isset($acsOptions['ally_id']) ? (int) $acsOptions['ally_id'] : 0;
			$deadline       = isset($acsOptions['deadline']) ? (int) $acsOptions['deadline'] : 0;
			$invitedUsers   = isset($acsOptions['invited_users']) && is_array($acsOptions['invited_users'])
				? $acsOptions['invited_users']
				: array();

			$acsId = self::createAcsGroup($userId, $empireId, TIMESTAMP + $duracion, $visibility, $allyId, $deadline);

			if ($acsId <= 0) {
				return array('success' => false, 'error' => 'No se pudo crear el ACS.');
			}

			$isNewAcs    = true;
			$acsLeaderId = $userId;

			// ─── Crear invitaciones si aplica ───
			try {
				if ($visibility === 'invite' && !empty($invitedUsers)) {
					$invitesCount = self::createAcsInvites($acsId, $userId, 'user', $invitedUsers);
				} elseif ($visibility === 'ally' && $allyId > 0) {
					$invitesCount = self::createAcsInvites($acsId, $userId, 'ally', array(), $allyId);
				}

				// ─── ✅ MENSAJE 3: Confirmar al líder que creó el ACS ───
				if (!empty($invitesCount) && $invitesCount > 0) {
					$body  = "Has creado un <b>ACS PvE</b> contra <b>" . $empire['name'] . "</b> [" . (int) $empire['galaxy'] . ":" . (int) $empire['system'] . ":" . (int) $empire['planet'] . "].<br><br>";
					$body .= "<b>Visibilidad:</b> ";
					if ($visibility === 'public')   $body .= "🌍 Público";
					if ($visibility === 'ally')     $body .= "🏰 Solo alianza";
					if ($visibility === 'invite')   $body .= "👥 Solo invitados";
					$body .= "<br>";

					if ($visibility === 'ally') {
						$body .= "<b>Invitaciones enviadas:</b> " . (int) $invitesCount . " miembros de la alianza<br>";
					} elseif ($visibility === 'invite') {
						$body .= "<b>Invitaciones enviadas:</b> " . (int) $invitesCount . " jugadores<br>";
					}

					$body .= "<b>Tiempo de vuelo:</b> " . pretty_time($duracion) . "<br>";
					$body .= "<br>Los invitados recibirán un mensaje con el enlace para unirse.<br>";
					$body .= "<a href=\"game.php?page=pve&mode=empire\">Ver el panel de Imperio</a>";

					self::sendMessage($userId, "[PvE] ACS creado — " . $empire['name'], $body);
				}
			} catch (Exception $e) {
				// Silencioso — el ACS ya está creado
			}
		}

		// Calcular tiempos finales
		$fleetStartTime = TIMESTAMP + $duracion;
		$fleetStayTime  = $fleetStartTime;
		$fleetEndTime   = $fleetStartTime + $duracion;

		// Sincronizar con el ACS si ya existe
		if ($acsId > 0) {
			$sql = "SELECT ankunft FROM %%AKS%% WHERE id = :id LIMIT 1;";
			$acsAnkunft = $db->selectSingle($sql, array(':id' => $acsId), 'ankunft');

			if (!empty($acsAnkunft)) {
				$targetTime = (int) $acsAnkunft;

				if ($targetTime > TIMESTAMP) {
					$fleetStartTime = $targetTime;
					$fleetStayTime  = $targetTime;
					$fleetEndTime   = $targetTime + $duracion;
				}
			}
		}

		// Añadir usuario al ACS
		// ✅ v3.8 — try/catch: dos joins concurrentes pasaban ambos el check
		// y el INSERT duplicado (PK userID+acsID) reventaba sin control.
		try {
			$sql = "INSERT INTO %%USERS_ACS%% SET userID = :uid, acsID = :aid;";
			$db->insert($sql, array(':uid' => $userId, ':aid' => $acsId));
		} catch (Throwable $e) {
			return array('success' => false, 'error' => 'Ya estás en este ACS.');
		}

		// ─── ✅ MENSAJE 2: Avisar al líder cuando alguien se une (solo si NO es el creador) ───
		if (!$isNewAcs && $acsLeaderId > 0 && $acsLeaderId !== $userId) {
			try {
				$membersCount = (int) $db->selectSingle(
					"SELECT COUNT(*) AS c FROM %%USERS_ACS%% WHERE acsID = :aid;",
					array(':aid' => $acsId),
					'c'
				);

				$totalShips = (int) $db->selectSingle(
					"SELECT COALESCE(SUM(fleet_amount), 0) AS s FROM %%FLEETS%% WHERE fleet_group = :aid;",
					array(':aid' => $acsId),
					's'
				);

				$body  = "El jugador <b>" . $user['username'] . "</b> se ha unido a tu ACS contra <b>" . $empire['name'] . "</b>.<br><br>";
				$body .= "<b>Miembros actuales:</b> " . $membersCount . "<br>";
				$body .= "<b>Naves totales en el ACS:</b> " . number_format($totalShips) . "<br>";
				$body .= "<br>El ataque se ejecutará cuando llegue la última flota.<br>";
				$body .= "<a href=\"game.php?page=pve&mode=empire\">Ver el panel de Imperio</a>";

				self::sendMessage($acsLeaderId, "[PvE] Nuevo miembro en tu ACS", $body);
			} catch (Exception $e) {
				// Silencioso
			}
		}

		// Restar naves del planeta
		// ✅ v3.8 — Descuento condicional en SQL (guard `col >= :n` + rowCount):
		// antes la validación era check-then-act contra un snapshot sin lock y
		// dos requests concurrentes restaban DOS veces (naves fantasma) o
		// reventaban en STRICT con columnas unsigned.
		$updateFields = array();
		$guardFields  = array();
		$params = array(':id' => $planetId);

		foreach ($shipsToSend as $shipId => $count) {
			$colName = $resource[$shipId];
			$updateFields[] = "`$colName` = `$colName` - :col_$shipId";
			$guardFields[]  = "`$colName` >= :g_$shipId";
			$params[":col_$shipId"] = $count;
			$params[":g_$shipId"]   = $count;
		}

		$updateFields[] = "`deuterium` = `deuterium` - :consumption";
		$guardFields[]  = "`deuterium` >= :consumption";
		$params[':consumption'] = $consumption;

		$sql = "UPDATE %%PLANETS%% SET " . implode(', ', $updateFields) . "
			WHERE id = :id AND " . implode(' AND ', $guardFields) . ";";
		$db->update($sql, $params);

		if ($db->rowCount() !== 1) {
			return array('success' => false, 'error' => 'Ya no tienes esas naves o deuterio (otra flota salió antes).');
		}

		// ✅ v3.8 — A partir de aquí, cualquier fallo DEVUELVE naves+deuterio
		// y limpia el ACS (antes el INSERT fallido dejaba todo perdido).

		// Serializar naves
		$fleetData = array();
		$fleetAmount = 0;
		foreach ($shipsToSend as $shipId => $count) {
			$fleetData[] = $shipId . ',' . floatToString($count);
			$fleetAmount += $count;
		}
		$fleetArrayStr = implode(';', $fleetData);

		$endId = self::EMPIRE_ID_OFFSET + $empireId;

		$sql = 'INSERT INTO %%FLEETS%% SET
			fleet_owner                 = :owner,
			fleet_target_owner          = 0,
			fleet_mission               = :mission,
			fleet_amount                = :fleetAmount,
			fleet_array                 = :fleetArray,
			fleet_universe              = :universe,
			fleet_start_time            = :fleetStartTime,
			fleet_end_stay              = :fleetStayTime,
			fleet_end_time              = :fleetEndTime,
			fleet_start_id              = :planetId,
			fleet_start_galaxy          = :startGalaxy,
			fleet_start_system          = :startSystem,
			fleet_start_planet          = :startPlanet,
			fleet_start_type            = 1,
			fleet_end_id                = :empireEndId,
			fleet_end_galaxy            = :targetGalaxy,
			fleet_end_system            = :targetSystem,
			fleet_end_planet            = :targetPlanet,
			fleet_end_type              = 1,
			fleet_resource_metal        = 0,
			fleet_resource_crystal      = 0,
			fleet_resource_deuterium    = 0,
			fleet_resource_darkmatter   = 0,
			fleet_group                 = :acsId,
			fleet_target_obj            = 0,
			fleet_mess                  = 0,
			start_time                  = :timestamp;';

		try {
			$db->insert($sql, array(
				':owner'            => $userId,
				':mission'          => MISSION_PVE_EMPIRE,
				':fleetAmount'      => $fleetAmount,
				':fleetArray'       => $fleetArrayStr,
				':universe'         => (int) $planet['universe'],
				':fleetStartTime'   => $fleetStartTime,
				':fleetStayTime'    => $fleetStayTime,
				':fleetEndTime'     => $fleetEndTime,
				':planetId'         => $planetId,
				':startGalaxy'      => (int) $planet['galaxy'],
				':startSystem'      => (int) $planet['system'],
				':startPlanet'      => (int) $planet['planet'],
				':empireEndId'      => $endId,
				':targetGalaxy'     => (int) $empire['galaxy'],
				':targetSystem'     => (int) $empire['system'],
				':targetPlanet'     => (int) $empire['planet'],
				':acsId'            => $acsId,
				':timestamp'        => TIMESTAMP,
			));
		} catch (Throwable $e) {
			// ✅ v3.8 — Compensación: devolver naves+deuterio y limpiar ACS
			self::refundAttackFleet($planetId, $shipsToSend, $consumption, $userId, $acsId, $isNewAcs);
			PVEHelper::log('empire', $empireId, 'attack_fleet_insert_error', $userId, $planetId, array(
				'error' => $e->getMessage(),
			));
			return array('success' => false, 'error' => 'Error al crear la flota (las naves fueron devueltas).');
		}

		$fleetId = $db->lastInsertId();

		if (empty($fleetId)) {
			self::refundAttackFleet($planetId, $shipsToSend, $consumption, $userId, $acsId, $isNewAcs);
			return array('success' => false, 'error' => 'Error al crear la flota (las naves fueron devueltas).');
		}

		try {
			$sql = 'INSERT INTO %%FLEETS_EVENT%% SET fleetID = :fleetId, `time` = :endTime, `lock` = NULL;';
			$db->insert($sql, array(
				':fleetId' => $fleetId,
				':endTime' => $fleetStartTime,
			));
		} catch (Throwable $e) {
			// ✅ v3.8 — Sin evento, FlyingFleetHandler nunca procesaría la
			// flota (quedaría congelada para siempre): compensar borrándola
			// y devolviendo las naves.
			try {
				$db->delete("DELETE FROM %%FLEETS%% WHERE fleet_id = :fid;", array(':fid' => (int) $fleetId));
			} catch (Throwable $e2) {}
			self::refundAttackFleet($planetId, $shipsToSend, $consumption, $userId, $acsId, $isNewAcs);
			PVEHelper::log('empire', $empireId, 'attack_event_insert_error', $userId, $planetId, array(
				'error' => $e->getMessage(),
			));
			return array('success' => false, 'error' => 'Error al programar la flota (las naves fueron devueltas).');
		}

		$sql = 'INSERT INTO %%LOG_FLEETS%% SET
			fleet_id                    = :fleetId,
			fleet_owner                 = :owner,
			fleet_target_owner          = 0,
			fleet_mission               = :mission,
			fleet_amount                = :fleetAmount,
			fleet_array                 = :fleetArray,
			fleet_universe              = :universe,
			fleet_start_time            = :fleetStartTime,
			fleet_end_stay              = :fleetStayTime,
			fleet_end_time              = :fleetEndTime,
			fleet_start_id              = :planetId,
			fleet_start_galaxy          = :startGalaxy,
			fleet_start_system          = :startSystem,
			fleet_start_planet          = :startPlanet,
			fleet_start_type            = 1,
			fleet_end_id                = :empireEndId,
			fleet_end_galaxy            = :targetGalaxy,
			fleet_end_system            = :targetSystem,
			fleet_end_planet            = :targetPlanet,
			fleet_end_type              = 1,
			fleet_resource_metal        = 0,
			fleet_resource_crystal      = 0,
			fleet_resource_deuterium    = 0,
			fleet_group                 = :acsId,
			fleet_target_obj            = 0,
			start_time                  = :timestamp;';

		$db->insert($sql, array(
			':fleetId'          => $fleetId,
			':owner'            => $userId,
			':mission'          => MISSION_PVE_EMPIRE,
			':fleetAmount'      => $fleetAmount,
			':fleetArray'       => $fleetArrayStr,
			':universe'         => (int) $planet['universe'],
			':fleetStartTime'   => $fleetStartTime,
			':fleetStayTime'    => $fleetStayTime,
			':fleetEndTime'     => $fleetEndTime,
			':planetId'         => $planetId,
			':startGalaxy'      => (int) $planet['galaxy'],
			':startSystem'      => (int) $planet['system'],
			':startPlanet'      => (int) $planet['planet'],
			':empireEndId'      => $endId,
			':targetGalaxy'     => (int) $empire['galaxy'],
			':targetSystem'     => (int) $empire['system'],
			':targetPlanet'     => (int) $empire['planet'],
			':acsId'            => $acsId,
			':timestamp'        => TIMESTAMP,
		));

		PVEHelper::log('empire', $empireId, 'attack_sent', $userId, $planetId, array(
			'fleet_id'  => $fleetId,
			'acs_id'    => $acsId,
			'ships'     => $fleetAmount,
			'duration'  => $duracion,
			'consumo'   => $consumption,
		));

		return array(
			'success'   => true,
			'fleet_id'  => (int) $fleetId,
			'acs_id'    => (int) $acsId,
			'is_new_acs' => $isNewAcs,
			'duration'  => $duracion,
			'consumption' => $consumption,
			'start_time' => $fleetStartTime,
			'end_time'  => $fleetEndTime,
		);
	}


	/* ============================================================
	 *  ACS — CREAR
	 * ============================================================ */

	public static function createAcsGroup($userId, $empireId, $ankunftTime, $visibility = 'public', $invitedAllyId = 0, $inviteDeadline = 0)
	{
		$db = Database::get();

		$visibility     = in_array($visibility, array('public', 'ally', 'invite')) ? $visibility : 'public';
		$invitedAllyId  = (int) $invitedAllyId;
		$inviteDeadline = (int) $inviteDeadline;

		$visibilityLabel = '🌍 Público';
		if ($visibility === 'ally')   $visibilityLabel = '🏰 Alianza';
		if ($visibility === 'invite') $visibilityLabel = '👥 Invitación';

		$name = 'PvE Empire #' . $empireId . ' (' . $visibilityLabel . ')';

		$sql = "INSERT INTO %%AKS%% SET
			name              = :name,
			target            = :target,
			visibility        = :visibility,
			invite_deadline   = :deadline,
			invited_ally_id   = :allyId,
			created_by        = :creator,
			ankunft           = :ankunft;";

		$db->insert($sql, array(
			':name'       => $name,
			':target'     => (int) $empireId,
			':visibility' => $visibility,
			':deadline'   => $inviteDeadline,
			':allyId'     => $invitedAllyId,
			':creator'    => (int) $userId,
			':ankunft'    => (int) $ankunftTime,
		));

		$acsId = $db->lastInsertId();
		return (int) $acsId;
	}


	public static function getOpenAcsForEmpire($empireId, $userId = 0)
	{
		$db = Database::get();
		$empireId = (int) $empireId;
		$userId   = (int) $userId;

		$sql = "SELECT a.id, a.name, a.ankunft, a.visibility, a.invite_deadline,
		               a.invited_ally_id, a.created_by,
		               u.username AS creator_name,
		               (SELECT COUNT(*) FROM %%USERS_ACS%% ua WHERE ua.acsID = a.id) AS participants,
		               (SELECT SUM(f.fleet_amount) FROM %%FLEETS%% f WHERE f.fleet_group = a.id) AS total_ships
		        FROM %%AKS%% a
		        LEFT JOIN %%USERS%% u ON u.id = a.created_by
		        WHERE a.target = :eid
		          AND a.ankunft > :now
		        ORDER BY a.ankunft ASC
		        LIMIT 20;";

		$rows = $db->select($sql, array(
			':eid' => $empireId,
			':now' => TIMESTAMP,
		));

		if (empty($rows)) {
			return array();
		}

		if ($userId > 0) {
			$filtered = array();
			foreach ($rows as $acs) {
				if (self::canUserJoinAcs($userId, (int) $acs['id'])) {
					$filtered[] = $acs;
				}
			}
			return $filtered;
		}

		return $rows;
	}


	public static function getAcsParticipants($acsId)
	{
		$db = Database::get();

		$sql = "SELECT f.fleet_id, f.fleet_owner, f.fleet_amount, f.fleet_array, 
		               f.fleet_start_time, f.fleet_end_time,
		               u.username
		        FROM %%FLEETS%% f
		        INNER JOIN %%USERS%% u ON u.id = f.fleet_owner
		        WHERE f.fleet_group = :aid;";

		$rows = $db->select($sql, array(':aid' => (int) $acsId));
		return !empty($rows) ? $rows : array();
	}


	/* ============================================================
	 *  ACS — INVITACIONES
	 * ============================================================ */

	/**
	 * Crea invitaciones al ACS Y envía mensaje interno a cada invitado.
	 */
	public static function createAcsInvites($acsId, $invitedBy, $type, $userIds = array(), $allyId = 0)
	{
		$db       = Database::get();
		$acsId    = (int) $acsId;
		$invitedBy = (int) $invitedBy;

		if ($acsId <= 0 || $invitedBy <= 0) {
			return 0;
		}

		// Cargar datos del ACS + imperio + invitador para el mensaje
		$sql = "SELECT a.name AS acs_name, a.ankunft, a.target,
		               u.username AS inviter_name,
		               e.name AS empire_name, e.galaxy AS empire_galaxy,
		               e.system AS empire_system, e.planet AS empire_planet,
		               e.current_hp, e.total_hp
		        FROM %%AKS%% a
		        LEFT JOIN %%USERS%% u ON u.id = :by
		        LEFT JOIN %%PVE_EMPIRES%% e ON e.id = a.target
		        WHERE a.id = :acsId LIMIT 1;";

		$acsData = $db->selectSingle($sql, array(':acsId' => $acsId, ':by' => $invitedBy));

		$acsName     = !empty($acsData['acs_name'])     ? $acsData['acs_name']     : ('ACS #' . $acsId);
		$inviterName = !empty($acsData['inviter_name']) ? $acsData['inviter_name'] : 'Un jugador';
		$empireName  = !empty($acsData['empire_name'])  ? $acsData['empire_name']  : 'Imperio Caído';
		$ankunft     = !empty($acsData['ankunft'])      ? (int) $acsData['ankunft'] : 0;
		$empireCoord = '[' . (int) $acsData['empire_galaxy'] . ':' . (int) $acsData['empire_system'] . ':' . (int) $acsData['empire_planet'] . ']';
		$hpPct       = ($acsData['total_hp'] > 0)
			? round(($acsData['current_hp'] / $acsData['total_hp']) * 100, 1)
			: 0;

		$created   = 0;
		$invitedIds = array();

		// ─── Caso 1: Invitar a usuarios específicos ───
		if ($type === 'user' && !empty($userIds)) {
			foreach ($userIds as $userId) {
				$userId = (int) $userId;
				if ($userId <= 0 || $userId === $invitedBy) continue;

				// ✅ v3.8 — Validar que el invitado EXISTE y es del mismo
				// universo (el caso 'ally' ya lo filtraba): antes IDs
				// arbitrarios creaban invitaciones fantasma y mensajes a
				// usuarios inexistentes.
				$validUser = $db->selectSingle(
					"SELECT id FROM %%USERS%% WHERE id = :uid AND universe = :uni LIMIT 1;",
					array(':uid' => $userId, ':uni' => Universe::current())
				);
				if (empty($validUser)) continue;

				$sql = "SELECT id FROM %%PVE_ACS_INVITES%% 
				        WHERE acs_id = :acsId AND invited_user_id = :uid 
				        LIMIT 1;";
				$exists = $db->selectSingle($sql, array(':acsId' => $acsId, ':uid' => $userId));
				if (!empty($exists)) continue;

				$sql = "INSERT INTO %%PVE_ACS_INVITES%% SET
					acs_id           = :acsId,
					invited_user_id  = :uid,
					invited_by       = :by,
					invite_type      = 'user',
					status           = 'pending',
					created_at       = :now;";

				$db->insert($sql, array(
					':acsId' => $acsId,
					':uid'   => $userId,
					':by'    => $invitedBy,
					':now'   => TIMESTAMP,
				));

				$invitedIds[] = $userId;
				$created++;
			}
		}

		// ─── Caso 2: Invitar a toda una alianza ───
		if ($type === 'ally' && $allyId > 0) {
			$allyId = (int) $allyId;

			$sql = "SELECT id FROM %%USERS%% 
			        WHERE ally_id = :allyId 
			          AND id != :by
			          AND universe = :uni;";
			$members = $db->select($sql, array(
				':allyId'  => $allyId,
				':by'      => $invitedBy,
				':uni'     => Universe::current(),
			));

			if (!empty($members)) {
				foreach ($members as $m) {
					$userId = (int) $m['id'];
					if ($userId <= 0) continue;

					$sql = "SELECT id FROM %%PVE_ACS_INVITES%% 
					        WHERE acs_id = :acsId AND invited_user_id = :uid 
					        LIMIT 1;";
					$exists = $db->selectSingle($sql, array(':acsId' => $acsId, ':uid' => $userId));
					if (!empty($exists)) continue;

					$sql = "INSERT INTO %%PVE_ACS_INVITES%% SET
						acs_id           = :acsId,
						invited_user_id  = :uid,
						invited_by       = :by,
						invite_type      = 'ally',
						status           = 'pending',
						created_at       = :now;";

					$db->insert($sql, array(
						':acsId' => $acsId,
						':uid'   => $userId,
						':by'    => $invitedBy,
						':now'   => TIMESTAMP,
					));

					$invitedIds[] = $userId;
					$created++;
				}
			}
		}

		// ─── ✅ MENSAJE 1: Enviar mensaje interno a cada invitado ───
		if (!empty($invitedIds)) {
			$deadlineStr = ($ankunft > 0)
				? date('d/m/Y H:i', $ankunft)
				: 'No especificado';

			foreach ($invitedIds as $invUserId) {
				try {
					$body  = "El jugador <b>" . $inviterName . "</b> te invita a unirte a un ataque <b>ACS PvE</b> contra:<br><br>";
					$body .= "🏛️ <b>" . $empireName . "</b> " . $empireCoord . "<br>";
					$body .= "❤️ HP: " . number_format((int) $acsData['current_hp']) . " / " . number_format((int) $acsData['total_hp']) . " (" . $hpPct . "%)<br>";
					$body .= "⏱️ Unirse antes de: <b>" . $deadlineStr . "</b><br>";
					$body .= "<br>Se necesitan muchos jugadores coordinados para destruir el imperio.<br>";
					$body .= "<a href=\"game.php?page=pve&mode=empire\"><b>→ Ver el panel y aceptar/rechazar</b></a>";

					self::sendMessage($invUserId, "[PvE] Invitación a ACS — " . $empireName, $body);
				} catch (Exception $e) {
					// Silencioso
				}
			}
		}

		return $created;
	}


	public static function getPendingInvitesForUser($userId)
	{
		$db     = Database::get();
		$userId = (int) $userId;

		if ($userId <= 0) {
			return array();
		}

		$sql = "SELECT i.*, a.name AS acs_name, a.target AS empire_id, 
		               a.ankunft, u.username AS inviter_name,
		               e.name AS empire_name, e.galaxy AS empire_galaxy, 
		               e.system AS empire_system, e.planet AS empire_planet,
		               e.current_hp, e.total_hp
		        FROM %%PVE_ACS_INVITES%% i
		        INNER JOIN %%AKS%% a ON a.id = i.acs_id
		        LEFT JOIN %%USERS%% u ON u.id = i.invited_by
		        LEFT JOIN %%PVE_EMPIRES%% e ON e.id = a.target
		        WHERE i.invited_user_id = :uid 
		          AND i.status = 'pending'
		          AND a.ankunft > :now
		        ORDER BY i.created_at DESC
		        LIMIT 20;";

		$rows = $db->select($sql, array(
			':uid' => $userId,
			':now' => TIMESTAMP,
		));

		return !empty($rows) ? $rows : array();
	}


	public static function acceptInvite($inviteId, $userId)
	{
		$db       = Database::get();
		$inviteId = (int) $inviteId;
		$userId   = (int) $userId;

		$sql = "SELECT * FROM %%PVE_ACS_INVITES%% 
		        WHERE id = :id AND invited_user_id = :uid AND status = 'pending'
		        LIMIT 1;";
		$invite = $db->selectSingle($sql, array(':id' => $inviteId, ':uid' => $userId));

		if (empty($invite)) {
			return null;
		}

		$db->update(
			"UPDATE %%PVE_ACS_INVITES%% SET status = 'accepted', responded_at = :now
			 WHERE id = :id AND invited_user_id = :uid AND status = 'pending';",
			array(':now' => TIMESTAMP, ':id' => $inviteId, ':uid' => $userId)
		);

		// ✅ v3.8 — rowCount: solo el proceso que REALMENTE cambió el estado
		// obtiene el ACS. Antes dos peticiones simultáneas aceptaban la misma
		// invitación, y una rechazada entre el SELECT y el UPDATE igual se
		// aceptaba (el UPDATE no exigía status='pending').
		if ($db->rowCount() !== 1) {
			return null;
		}

		return (int) $invite['acs_id'];
	}


	public static function rejectInvite($inviteId, $userId)
	{
		$db       = Database::get();
		$inviteId = (int) $inviteId;
		$userId   = (int) $userId;

		$db->update(
			"UPDATE %%PVE_ACS_INVITES%% SET status = 'rejected', responded_at = :now 
			 WHERE id = :id AND invited_user_id = :uid AND status = 'pending';",
			array(':now' => TIMESTAMP, ':id' => $inviteId, ':uid' => $userId)
		);

		return true;
	}


	public static function canUserJoinAcs($userId, $acsId)
	{
		$db     = Database::get();
		$userId = (int) $userId;
		$acsId  = (int) $acsId;

		$sql = "SELECT * FROM %%AKS%% WHERE id = :id LIMIT 1;";
		$acs = $db->selectSingle($sql, array(':id' => $acsId));

		if (empty($acs)) {
			return false;
		}

		$visibility = isset($acs['visibility']) ? $acs['visibility'] : 'public';

		if ($visibility === 'public') {
			return true;
		}

		if ($visibility === 'ally') {
			$allyId = isset($acs['invited_ally_id']) ? (int) $acs['invited_ally_id'] : 0;
			if ($allyId <= 0) {
				return false;
			}

			$sql = "SELECT ally_id FROM %%USERS%% WHERE id = :uid LIMIT 1;";
			$userAlly = $db->selectSingle($sql, array(':uid' => $userId), 'ally_id');

			return ((int) $userAlly === $allyId);
		}

		if ($visibility === 'invite') {
			$sql = "SELECT id FROM %%PVE_ACS_INVITES%% 
			        WHERE acs_id = :acsId AND invited_user_id = :uid 
			          AND status IN ('pending','accepted')
			        LIMIT 1;";
			$invite = $db->selectSingle($sql, array(':acsId' => $acsId, ':uid' => $userId));

			return !empty($invite);
		}

		return false;
	}


	/* ============================================================
	 *  CONTRATAQUE DEL IMPERIO (mission=22)
	 * ============================================================ */

	public static function sendCounterAttackFleet($empire, $targetUserId, $targetPlanetId, $counterFleet)
	{
		$db = Database::get();

		if (empty($empire) || empty($counterFleet) || $targetPlanetId <= 0) {
			return null;
		}

		$sql = "SELECT * FROM %%PLANETS%% WHERE id = :id LIMIT 1;";
		$targetPlanet = $db->selectSingle($sql, array(':id' => (int) $targetPlanetId));

		if (empty($targetPlanet)) {
			return null;
		}

		$fleetData   = array();
		$fleetAmount = 0;
		foreach ($counterFleet as $shipId => $count) {
			$count = (int) $count;
			if ($count <= 0) continue;
			$fleetData[] = $shipId . ',' . floatToString($count);
			$fleetAmount += $count;
		}

		if ($fleetAmount <= 0) {
			return null;
		}

		$fleetArrayStr = implode(';', $fleetData);

		$distance   = FleetFunctions::GetTargetDistance(
			array($empire['galaxy'], $empire['system'], $empire['planet']),
			array($targetPlanet['galaxy'], $targetPlanet['system'], $targetPlanet['planet'])
		);

		$gameSpeed    = FleetFunctions::GetGameSpeedFactor();
		$flightSpeed  = 8;
		$maxSpeed     = 5000000;

		$duration     = FleetFunctions::GetMissionDuration($flightSpeed, $maxSpeed, $distance, $gameSpeed, null);
		$duracion     = (int) ceil($duration);
		if ($duracion < 1) $duracion = 1;

		$fleetStartTime = TIMESTAMP + $duracion;
		$fleetStayTime  = $fleetStartTime;
		$fleetEndTime   = $fleetStartTime + $duracion;

		$endId = self::EMPIRE_ID_OFFSET + (int) $empire['id'];

		$sql = 'INSERT INTO %%FLEETS%% SET
			fleet_owner                 = 0,
			fleet_target_owner          = :targetOwner,
			fleet_mission               = :mission,
			fleet_amount                = :fleetAmount,
			fleet_array                 = :fleetArray,
			fleet_universe              = :universe,
			fleet_start_time            = :fleetStartTime,
			fleet_end_stay              = :fleetStayTime,
			fleet_end_time              = :fleetEndTime,
			fleet_start_id              = :empireStartId,
			fleet_start_galaxy          = :startGalaxy,
			fleet_start_system          = :startSystem,
			fleet_start_planet          = :startPlanet,
			fleet_start_type            = 1,
			fleet_end_id                = :targetPlanetId,
			fleet_end_galaxy            = :targetGalaxy,
			fleet_end_system            = :targetSystem,
			fleet_end_planet            = :targetPlanet,
			fleet_end_type              = :endType,
			fleet_resource_metal        = 0,
			fleet_resource_crystal      = 0,
			fleet_resource_deuterium    = 0,
			fleet_resource_darkmatter   = 0,
			fleet_group                 = 0,
			fleet_target_obj            = 0,
			fleet_mess                  = 0,
			start_time                  = :timestamp;';

		// ✅ v3.8 — fleet_end_type del PLANETA real (1=planeta, 3=luna): antes
		// se hardcodeaba a 1 y un contrataque a una luna aterrizaba mal
		// (misión 22 con tipo equivocado).
		$db->insert($sql, array(
			':targetOwner'      => (int) $targetUserId,
			':mission'          => MISSION_PVE_COUNTER,
			':fleetAmount'      => $fleetAmount,
			':fleetArray'       => $fleetArrayStr,
			':universe'         => (int) $targetPlanet['universe'],
			':fleetStartTime'   => $fleetStartTime,
			':fleetStayTime'    => $fleetStayTime,
			':fleetEndTime'     => $fleetEndTime,
			':empireStartId'    => $endId,
			':startGalaxy'      => (int) $empire['galaxy'],
			':startSystem'      => (int) $empire['system'],
			':startPlanet'      => (int) $empire['planet'],
			':targetPlanetId'   => (int) $targetPlanetId,
			':targetGalaxy'     => (int) $targetPlanet['galaxy'],
			':targetSystem'     => (int) $targetPlanet['system'],
			':targetPlanet'     => (int) $targetPlanet['planet'],
			':endType'          => (int) $targetPlanet['planet_type'],
			':timestamp'        => TIMESTAMP,
		));

		$fleetId = $db->lastInsertId();

		if (empty($fleetId)) {
			return null;
		}

		try {
			$sql = 'INSERT INTO %%FLEETS_EVENT%% SET fleetID = :fleetId, `time` = :endTime, `lock` = NULL;';
			$db->insert($sql, array(
				':fleetId' => $fleetId,
				':endTime' => $fleetStartTime,
			));
		} catch (Throwable $e) {
			// ✅ v3.8 — Compensación: borrar la flota sin evento (quedaría
			// congelada para siempre en la cola de flotas).
			try {
				$db->delete("DELETE FROM %%FLEETS%% WHERE fleet_id = :fid;", array(':fid' => (int) $fleetId));
			} catch (Throwable $e2) {}
			return null;
		}

		$sql = 'INSERT INTO %%LOG_FLEETS%% SET
			fleet_id                    = :fleetId,
			fleet_owner                 = 0,
			fleet_target_owner          = :targetOwner,
			fleet_mission               = :mission,
			fleet_amount                = :fleetAmount,
			fleet_array                 = :fleetArray,
			fleet_universe              = :universe,
			fleet_start_time            = :fleetStartTime,
			fleet_end_stay              = :fleetStayTime,
			fleet_end_time              = :fleetEndTime,
			fleet_start_id              = :empireStartId,
			fleet_start_galaxy          = :startGalaxy,
			fleet_start_system          = :startSystem,
			fleet_start_planet          = :startPlanet,
			fleet_start_type            = 1,
			fleet_end_id                = :targetPlanetId,
			fleet_end_galaxy            = :targetGalaxy,
			fleet_end_system            = :targetSystem,
			fleet_end_planet            = :targetPlanet,
			fleet_end_type              = 1,
			fleet_resource_metal        = 0,
			fleet_resource_crystal      = 0,
			fleet_resource_deuterium    = 0,
			fleet_group                 = 0,
			fleet_target_obj            = 0,
			start_time                  = :timestamp;';

		$db->insert($sql, array(
			':fleetId'          => $fleetId,
			':targetOwner'      => (int) $targetUserId,
			':mission'          => MISSION_PVE_COUNTER,
			':fleetAmount'      => $fleetAmount,
			':fleetArray'       => $fleetArrayStr,
			':universe'         => (int) $targetPlanet['universe'],
			':fleetStartTime'   => $fleetStartTime,
			':fleetStayTime'    => $fleetStayTime,
			':fleetEndTime'     => $fleetEndTime,
			':empireStartId'    => $endId,
			':startGalaxy'      => (int) $empire['galaxy'],
			':startSystem'      => (int) $empire['system'],
			':startPlanet'      => (int) $empire['planet'],
			':targetPlanetId'   => (int) $targetPlanetId,
			':targetGalaxy'     => (int) $targetPlanet['galaxy'],
			':targetSystem'     => (int) $targetPlanet['system'],
			':targetPlanet'     => (int) $targetPlanet['planet'],
			':timestamp'        => TIMESTAMP,
		));

		return (int) $fleetId;
	}


	/* ============================================================
	 *  UTILIDADES
	 * ============================================================ */

	/**
	 * ✅ v3.8 — Compensación de sendEmpireAttackFleet: devuelve las naves y
	 * el deuterio al planeta de origen y limpia la membresía del ACS (y el
	 * propio ACS si era nuevo). Best-effort: nunca lanza.
	 */
	private static function refundAttackFleet(int $planetId, array $shipsToSend, int $consumption, int $userId, int $acsId, bool $isNewAcs): void
	{
		global $resource;
		$db = Database::get();

		try {
			$updateFields = array();
			$params = array(':id' => $planetId);
			foreach ($shipsToSend as $shipId => $count) {
				$colName = isset($resource[$shipId]) ? $resource[$shipId] : '';
				if ($colName === '' || $count <= 0) continue;
				$updateFields[] = "`$colName` = `$colName` + :col_$shipId";
				$params[":col_$shipId"] = (int) $count;
			}
			if ($consumption > 0) {
				$updateFields[] = "`deuterium` = `deuterium` + :consumption";
				$params[':consumption'] = (int) $consumption;
			}
			if (!empty($updateFields)) {
				$db->update(
					"UPDATE %%PLANETS%% SET " . implode(', ', $updateFields) . " WHERE id = :id;",
					$params
				);
			}
		} catch (Throwable $e) {}

		try {
			if ($acsId > 0) {
				$db->delete(
					"DELETE FROM %%USERS_ACS%% WHERE userID = :uid AND acsID = :aid;",
					array(':uid' => $userId, ':aid' => $acsId)
				);
			}
			if ($isNewAcs && $acsId > 0) {
				$db->delete(
					"DELETE FROM %%AKS%% WHERE id = :aid;",
					array(':aid' => $acsId)
				);
			}
		} catch (Throwable $e) {}
	}

	/**
	 * Helper para enviar mensajes internos SIN emojis 4-byte
	 */
	private static function sendMessage($userId, $title, $body)
	{
		try {
			// ✅ v3.4 — Multiverso: el mensaje usa el universo del DESTINATARIO,
			// no el de la sesión (esto corre en cron y puede notificar a
			// jugadores de cualquier universo).
			$db = Database::get();
			$userUni = $db->selectSingle(
				"SELECT universe FROM %%USERS%% WHERE id = :id LIMIT 1;",
				array(':id' => (int) $userId),
				'universe'
			);
			$userUni = (int) ($userUni ?: 1);

			PlayerUtil::sendMessage(
				(int) $userId, 0, 'Comando Central PvE', 3, $title, $body,
				TIMESTAMP, null, 1, $userUni
			);
			return true;
		} catch (Exception $e) {
			PVEHelper::log('empire', 0, 'msg_error', (int) $userId, 0, array(
				'error' => $e->getMessage(),
				'title' => $title,
			));
			return false;
		}
	}


	public static function cleanOrphanEvents()
	{
		$db = Database::get();

		$sql = "DELETE fe FROM %%FLEETS_EVENT%% fe
		        LEFT JOIN %%FLEETS%% f ON f.fleet_id = fe.fleetID
		        WHERE f.fleet_id IS NULL;";

		$db->delete($sql);
	}


	public static function getEmpireDistance($empire, $planet)
	{
		return FleetFunctions::GetTargetDistance(
			array($empire['galaxy'], $empire['system'], $empire['planet']),
			array($planet['galaxy'], $planet['system'], $planet['planet'])
		);
	}


	public static function getFactionName($factionId)
	{
		$factions = array(
			1 => 'Piratas',
			2 => 'Aliens',
			3 => 'Máquinas',
			4 => 'Fantasmas',
		);

		$factionId = (int) $factionId;
		return isset($factions[$factionId]) ? $factions[$factionId] : 'Piratas';
	}
}