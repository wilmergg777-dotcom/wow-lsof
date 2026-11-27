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
 * ✅ AstroIO v1.7 (ENVIAR DESGLOSE A LA NUEVA PLANTILLA):
 *   - Se extrae el array de naves y los recursos en el bucle de flotas
 *   - Se envían a la plantilla (ships_array, fleet_resource_metal, etc.)
 *
 * ✅ AstroIO v1.8 (FIX ERROR AL VIRAR FLOTA):
 *   - Añadida validación previa a FleetFunctions::SendFleetBack()
 *   - Evita el error "Trying to access array offset on value of type bool"
 *     cuando la flota ya ha regresado o el cron la ha procesado antes.
 *
 * ✅ AstroIO v1.9 (VIP SLOTS FIX):
 *   - El contador de expediciones ahora usa getExpeditionLimit() 
 *   - Incluye automáticamente el bonus VIP (+1 o +2 slots)
 */

class ShowFleetTablePage extends AbstractGamePage
{
	public static $requireModule = MODULE_FLEET_TABLE;

	function __construct() 
	{
		parent::__construct();
	}
	
	public function createACS($fleetID, $fleetData) {
		global $USER;
		
		$rand 			= mt_rand(100000, 999999999);
		$acsName	 	= 'AG'.$rand;
		$acsCreator		= $USER['id'];

        $db = Database::get();
        $sql = "INSERT INTO %%AKS%% SET name = :acsName, ankunft = :time, target = :target;";
        $db->insert($sql, array(
            ':acsName'	=> $acsName,
            ':time'		=> $fleetData['fleet_start_time'],
			':target'	=> $fleetData['fleet_end_id']
        ));

        $acsID	= $db->lastInsertId();

        $sql = "INSERT INTO %%USERS_ACS%% SET acsID = :acsID, userID = :userID;";
        $db->insert($sql, array(
            ':acsID'	=> $acsID,
            ':userID'	=> $acsCreator
        ));

        $sql = "UPDATE %%FLEETS%% SET fleet_group = :acsID WHERE fleet_id = :fleetID;";
        $db->update($sql, array(
            ':acsID'	=> $acsID,
            ':fleetID'	=> $fleetID
        ));

		return array(
			'name' 			=> $acsName,
			'id' 			=> $acsID,
		);
	}
	
	public function loadACS($fleetData) {
		global $USER;
		
		$db = Database::get();
        $sql = "SELECT id, name FROM %%USERS_ACS%% INNER JOIN %%AKS%% ON acsID = id WHERE userID = :userID AND acsID = :acsID;";
        $acsResult = $db->selectSingle($sql, array(
            ':userID'   => $USER['id'],
            ':acsID'    => $fleetData['fleet_group']
        ));

		return $acsResult;
	}
	
	public function getACSPageData($fleetID)
	{
		global $USER, $LNG;
		
		$db = Database::get();

        $sql = "SELECT fleet_start_time, fleet_end_id, fleet_group, fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fleetID;";
        $fleetData = $db->selectSingle($sql, array(
            ':fleetID'  => $fleetID
        ));

        if ($db->rowCount() != 1)
			return array();

		if ($fleetData['fleet_mess'] == 1 || $fleetData['fleet_start_time'] <= TIMESTAMP)
			return array();
				
		if ($fleetData['fleet_group'] == 0)
			$acsData	= $this->createACS($fleetID, $fleetData);
		else
			$acsData	= $this->loadACS($fleetData);
	
		if (empty($acsData))
			return array();
			
		$acsName	= HTTP::_GP('acsName', '', UTF8_SUPPORT);
		if(!empty($acsName)) {
			if(!PlayerUtil::isNameValid($acsName))
			{
				$this->sendJSON($LNG['fl_acs_newname_alphanum']);
			}
			
			$sql = "UPDATE %%AKS%% SET name = acsName WHERE id = :acsID;";
            $db->update($sql, array(
                ':acsName'  => $acsName,
                ':acsID'    => $acsData['id']
            ));
            $this->sendJSON(false);
		}
		
		$invitedUsers	= array();

        $sql = "SELECT id, username FROM %%USERS_ACS%% 
                INNER JOIN %%USERS%% ON userID = id 
                WHERE acsID = :acsID 
                  AND email NOT LIKE '%@noreply.local';";
        $userResult = $db->select($sql, array(
            ':acsID'    => $acsData['id']
        ));

        foreach($userResult as $userRow)
		{
			$invitedUsers[$userRow['id']]	= $userRow['username'];
		}

		$newUser		= HTTP::_GP('username', '', UTF8_SUPPORT);
		$statusMessage	= "";
		if(!empty($newUser))
		{
			$sql = "SELECT id FROM %%USERS%% 
			        WHERE universe = :universe 
			          AND username = :username
			          AND email NOT LIKE '%@noreply.local';";
            $newUserID = $db->selectSingle($sql, array(
                ':universe' => Universe::current(),
                ':username' => $newUser
            ), 'id');

            if(empty($newUserID)) {
				$statusMessage			= $LNG['fl_player']." ".$newUser." ".$LNG['fl_dont_exist'];
			} elseif(isset($invitedUsers[$newUserID])) {
				$statusMessage			= $LNG['fl_player']." ".$newUser." ".$LNG['fl_already_invited'];
			} else {
				$statusMessage			= $LNG['fl_player']." ".$newUser." ".$LNG['fl_add_to_attack'];
				
				$sql = "INSERT INTO %%USERS_ACS%% SET acsID = :acsID, userID = :newUserID;";
                $db->insert($sql, array(
                    ':acsID'        => $acsData['id'],
                    ':newUserID'    => $newUserID
                ));

                $invitedUsers[$newUserID]	= $newUser;
				
				$inviteTitle			= $LNG['fl_acs_invitation_title'];
				$inviteMessage 			= $LNG['fl_player'] . $USER['username'] . $LNG['fl_acs_invitation_message'];
				PlayerUtil::sendMessage($newUserID, $USER['id'], $USER['username'], 1, $inviteTitle, $inviteMessage, TIMESTAMP);
			}
		}
		
		return array(
			'invitedUsers'	=> $invitedUsers,
			'acsName'		=> $acsData['name'],
			'mainFleetID'	=> $fleetID,
			'statusMessage'	=> $statusMessage,
		);
	}
	
	public function show()
	{
		global $USER, $PLANET, $reslist, $resource, $LNG;
		
		$acsData			= array();
		$FleetID			= HTTP::_GP('fleetID', 0);
		$GetAction			= HTTP::_GP('action', "");

        $db = Database::get();

		$this->tplObj->loadscript('flotten.js');
		
		if(!empty($FleetID) && !IsVacationMode($USER))
		{
			switch($GetAction){
				case "sendfleetback":
					// ✅ FIX v1.8: Validar que la flota existe y está en vuelo de ida
					$sqlCheck = "SELECT fleet_id, fleet_owner, fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fleetID;";
					$fleetCheck = $db->selectSingle($sqlCheck, array(':fleetID' => $FleetID));
					
					if (!empty($fleetCheck) && $fleetCheck['fleet_owner'] == $USER['id'] && $fleetCheck['fleet_mess'] == 0) {
						FleetFunctions::SendFleetBack($USER, $FleetID);
					}
				break;
				case "acs":
					$acsData	= $this->getACSPageData($FleetID);
				break;
			}
		}
		
		$techExpedition      = $USER[$resource[124]];

		if ($techExpedition >= 1)
		{
			$activeExpedition   = FleetFunctions::GetCurrentFleets($USER['id'], 15, true);
			// ✅ ASTROIO v1.9: Incluye el bono VIP (+1 o +2) automáticamente
			$maxExpedition 		= (int) FleetFunctions::getExpeditionLimit($USER);
		}
		else
		{
			$activeExpedition 	= 0;
			$maxExpedition 		= 0;
		}

		$maxFleetSlots	= FleetFunctions::GetMaxFleetSlots($USER);

		$pveTarget = !empty($_SESSION['pve_attack_target']) ? $_SESSION['pve_attack_target'] : null;

		$defaultGalaxy  = ($pveTarget && !empty($pveTarget['galaxy']))  ? (int) $pveTarget['galaxy']  : (int) $PLANET['galaxy'];
		$defaultSystem  = ($pveTarget && !empty($pveTarget['system']))  ? (int) $pveTarget['system']  : (int) $PLANET['system'];
		$defaultPlanet  = ($pveTarget && !empty($pveTarget['planet']))  ? (int) $pveTarget['planet']  : (int) $PLANET['planet'];
		$defaultType    = ($pveTarget && !empty($pveTarget['type']))    ? (int) $pveTarget['type']    : (int) $PLANET['planet_type'];
		$defaultMission = ($pveTarget && !empty($pveTarget['mission'])) ? (int) $pveTarget['mission'] : 0;

		$targetGalaxy	= HTTP::_GP('galaxy', $defaultGalaxy);
		$targetSystem	= HTTP::_GP('system', $defaultSystem);
		$targetPlanet	= HTTP::_GP('planet', $defaultPlanet);
		$targetType		= HTTP::_GP('planettype', $defaultType);

		$targetMission	= HTTP::_GP('target_mission', 0);
		if ($targetMission <= 0 && $defaultMission > 0) {
			$targetMission = $defaultMission;
		}

		$sqlSlots = "SELECT COUNT(*) AS c FROM %%FLEETS%% 
		             WHERE fleet_owner = :userID AND fleet_mission <> 10;";
		$activeFleetSlots = (int) $db->selectSingle($sqlSlots, array(':userID' => $USER['id']), 'c');

		$sql = "SELECT * FROM %%FLEETS%% 
		        WHERE (
		            (fleet_owner = :userID AND fleet_mission <> 10)
		            OR (fleet_target_owner = :userID AND fleet_mission IN (1, 2, 20, 21, 22, 23) AND fleet_mess = 0)
		        )
		        ORDER BY fleet_end_time ASC;";
		$fleetResult = $db->select($sql, array(
		    ':userID'   => $USER['id']
		));

		$FlyingFleetList	= array();
		
		foreach ($fleetResult as $fleetsRow)
		{
			$FleetList[$fleetsRow['fleet_id']] = FleetFunctions::unserialize($fleetsRow['fleet_array']);
			
			if($fleetsRow['fleet_mission'] == 4 && $fleetsRow['fleet_mess'] == FLEET_OUTWARD)
			{
				$returnTime	= $fleetsRow['fleet_start_time'];
			}
			else
			{
				$returnTime	= $fleetsRow['fleet_end_time'];
			}

			$isIncoming = ((int) $fleetsRow['fleet_owner'] === 0)
			           && ((int) $fleetsRow['fleet_target_owner'] === (int) $USER['id'])
			           && in_array((int) $fleetsRow['fleet_mission'], array(1, 2, 20, 21, 22, 23));

			$missionLabel = isset($LNG['type_mission_'.$fleetsRow['fleet_mission']])
				? $LNG['type_mission_'.$fleetsRow['fleet_mission']]
				: '';
			if ($missionLabel === '') {
				switch ((int) $fleetsRow['fleet_mission']) {
					case 1:  $missionLabel = 'Ataque'; break;
					case 2:  $missionLabel = 'Ataque Grupal'; break;
					case 20: $missionLabel = 'Ataque Pirata'; break;
					case 21: $missionLabel = 'Ataque a Imperio'; break;
					case 22: $missionLabel = 'Contraataque'; break;
					case 23: $missionLabel = 'Ataque al Devorador'; break;
					case 32: $missionLabel = 'Reciclaje de Asteroide'; break;
					default: $missionLabel = 'Misión #'.$fleetsRow['fleet_mission']; break;
				}
			}
			
			$FlyingFleetList[]	= array(
				'id'			=> $fleetsRow['fleet_id'],
				'mission'		=> $fleetsRow['fleet_mission'],
				'mission_label'	=> $missionLabel,
				'state'			=> $fleetsRow['fleet_mess'],
				'startGalaxy'	=> $fleetsRow['fleet_start_galaxy'],
				'startSystem'	=> $fleetsRow['fleet_start_system'],
				'startPlanet'	=> $fleetsRow['fleet_start_planet'],
				'startTime'		=> _date($LNG['php_tdformat'], $fleetsRow['fleet_start_time'], $USER['timezone']),
				'endGalaxy'		=> $fleetsRow['fleet_end_galaxy'],
				'endSystem'		=> $fleetsRow['fleet_end_system'],
				'endPlanet'		=> $fleetsRow['fleet_end_planet'],
				'endTime'		=> _date($LNG['php_tdformat'], $fleetsRow['fleet_end_time'], $USER['timezone']),
				'amount'		=> pretty_number($fleetsRow['fleet_amount']),
				'returntime'	=> $returnTime,
				'resttime'		=> $returnTime - TIMESTAMP,
				'FleetList'		=> $FleetList[$fleetsRow['fleet_id']],
				'is_incoming'	=> $isIncoming ? 1 : 0,
				
				'ships_array'               => $FleetList[$fleetsRow['fleet_id']],
				'fleet_resource_metal'      => $fleetsRow['fleet_resource_metal'],
				'fleet_resource_crystal'    => $fleetsRow['fleet_resource_crystal'],
				'fleet_resource_deuterium'  => $fleetsRow['fleet_resource_deuterium'],
				'fleet_resource_darkmatter' => $fleetsRow['fleet_resource_darkmatter']
			);
		}
		
		$FleetsOnPlanet	= array();
		
		foreach($reslist['fleet'] as $FleetID)
		{
			if ($PLANET[$resource[$FleetID]] == 0)
				continue;
				
			$FleetsOnPlanet[]	= array(
				'id'	=> $FleetID,
				'speed'	=> FleetFunctions::GetFleetMaxSpeed($FleetID, $USER),
				'count'	=> $PLANET[$resource[$FleetID]],
			);
		}
		
		$this->assign(array(
			'FleetsOnPlanet'		=> $FleetsOnPlanet,
			'FlyingFleetList'		=> $FlyingFleetList,
			'activeExpedition'		=> $activeExpedition,
			'maxExpedition'			=> $maxExpedition,
			'activeFleetSlots'		=> $activeFleetSlots,
			'maxFleetSlots'			=> $maxFleetSlots,
			'targetGalaxy'			=> $targetGalaxy,
			'targetSystem'			=> $targetSystem,
			'targetPlanet'			=> $targetPlanet,
			'targetType'			=> $targetType,
			'targetMission'			=> $targetMission,
			'acsData'				=> $acsData,
			'isVacation'			=> IsVacationMode($USER),
			'bonusAttack'			=> $USER[$resource[109]] * 10 + $USER['factor']['Attack'] * 100,
			'bonusDefensive'		=> $USER[$resource[110]] * 10 + $USER['factor']['Defensive'] * 100,
			'bonusShield'			=> $USER[$resource[111]] * 10 + $USER['factor']['Shield'] * 100,
			'bonusCombustion'		=> $USER[$resource[115]] * 10,
			'bonusImpulse'			=> $USER[$resource[117]] * 20,
			'bonusHyperspace'		=> $USER[$resource[118]] * 30,
		));
		
		$this->display('page.fleetTable.default.tpl');
	}
}