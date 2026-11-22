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
 * ✅ AstroIO v2.2 (RADAR OVERVIEW):
 *   - Se añade 'state' (0=ida, 1=vuelta, 2=holding) al return.
 *   - Se añade 'is_incoming' (true si la flota NO es del usuario).
 *   - Con esto el radar del Overview y la Base de Flotas pueden animar
 *     correctamente la nave (ida vs vuelta) y colorear la tarjeta.
 *   - Se eliminó el hack de $Rest = 1, el JS ahora controla la recarga.
 */

class FlyingFleetsTable
{
	protected $Mode = null;
	protected $userId	= null;
	protected $planetId = null;
	protected $IsPhalanx = false;
	protected $missions = false;

	public function __construct() {
		
	}

	public function setUser($userId) {
		$this->userId = $userId;
	}

	public function setPlanet($planetId) {
		$this->planetId = $planetId;
	}

	public function setPhalanxMode() {
		$this->IsPhalanx = true;
	}

	public function setMissions($missions) {
		$this->missions = implode(',', array_filter(explode(',', $missions), 'is_numeric'));
	}
	
	private function getFleets($acsID = false) {
		if($this->IsPhalanx) {
			$where = '(fleet_start_id = :planetId AND fleet_start_type = 1 AND fleet_mission != 4) OR
					  (fleet_end_id = :planetId AND fleet_end_type = 1 AND fleet_mess IN (0, 2))';

			$param = array(
				':planetId'	  => $this->planetId
			);
		} elseif(!empty($acsID)) {
			$where	= 'fleet_group = :acsId';
			$param = array(
				':acsId'	=> $acsID
			);
		} elseif($this->missions) {
			$where = '(fleet_owner = :userId OR fleet_target_owner = :userId) AND fleet_mission IN ('.$this->missions.')';
			$param = array(
				':userId'	=> $this->userId
			);
		} else {
			$where  = 'fleet_owner = :userId OR (fleet_target_owner = :userId AND fleet_mission != 8)';
			$param = array(
				':userId'	=> $this->userId,
			);
		}

		$sql = 'SELECT DISTINCT fleet.*, ownuser.username as own_username, targetuser.username as target_username,
		ownplanet.name as own_planetname, targetplanet.name as target_planetname
		FROM %%FLEETS%% fleet
		LEFT JOIN %%USERS%% ownuser ON (ownuser.id = fleet.fleet_owner)
		LEFT JOIN %%USERS%% targetuser ON (targetuser.id = fleet.fleet_target_owner)
		LEFT JOIN %%PLANETS%% ownplanet ON (ownplanet.id = fleet.fleet_start_id)
		LEFT JOIN %%PLANETS%% targetplanet ON (targetplanet.id = fleet.fleet_end_id)
		WHERE '.$where.';';

		return Database::get()->select($sql, $param);
	}

	public function renderTable()
	{
		$fleetResult	= $this->getFleets();
		$ACSDone		= array();
		$FleetData		= array();
		
		foreach($fleetResult as $fleetRow)
		{
			// 1. FASE DE IDA (Outward)
			if ($fleetRow['fleet_mess'] == 0 && $fleetRow['fleet_end_time'] > TIMESTAMP && ($fleetRow['fleet_group'] == 0 || !isset($ACSDone[$fleetRow['fleet_group']])))
			{
				$ACSDone[$fleetRow['fleet_group']]		= true;
				$FleetData[$fleetRow['fleet_start_time'].$fleetRow['fleet_id']] = $this->BuildFleetEventTable($fleetRow, 0);
			}
				
			// Ignorar misiles y despliegues internos
			if ($fleetRow['fleet_mission'] == 10 || ($fleetRow['fleet_mission'] == 4 && $fleetRow['fleet_mess'] == 0))
				continue;
				
			// 2. FASE DE ESTANCIA (Holding)
			if ($fleetRow['fleet_end_stay'] != $fleetRow['fleet_start_time'] && $fleetRow['fleet_end_stay'] > TIMESTAMP && ($this->IsPhalanx && $fleetRow['fleet_end_id'] == $this->planetId))
				$FleetData[$fleetRow['fleet_end_stay'].$fleetRow['fleet_id']] = $this->BuildFleetEventTable($fleetRow, 2);
			
			$MissionsOK = 5;
			if ($fleetRow['fleet_end_stay'] > TIMESTAMP && $fleetRow['fleet_mission'] == $MissionsOK )
			$FleetData[$fleetRow['fleet_end_stay'].$fleetRow['fleet_id']] = $this->BuildFleetEventTable($fleetRow, 2);
				
			if ($fleetRow['fleet_owner'] != $this->userId)
				continue;
		
			// 3. FASE DE VUELTA (Return) - Solo si fleet_mess == 1
			if ($fleetRow['fleet_mess'] == 1 && $fleetRow['fleet_end_time'] > TIMESTAMP)
				$FleetData[$fleetRow['fleet_end_time'].$fleetRow['fleet_id']] = $this->BuildFleetEventTable($fleetRow, 1);
		}
		
		ksort($FleetData);
		return $FleetData;
	}

	private function BuildFleetEventTable($fleetRow, $FleetState)
	{
		global $LNG;
		
		$Time	= 0;
		$Rest	= 0;

		if ($FleetState == 0 && !$this->IsPhalanx && $fleetRow['fleet_group'] != 0)
		{
			$acsResult		= $this->getFleets($fleetRow['fleet_group']);
			$EventString	= '';

			foreach($acsResult as $acsRow)
			{
				$Return			= $this->getEventData($acsRow, $FleetState);
					
				$Rest			= $Return[0];
				$EventString    .= $Return[1].'<br><br>';
				$Time			= $Return[2];
			}

			$EventString	= substr($EventString, 0, -8);
		}
		else
		{
			list($Rest, $EventString, $Time) = $this->getEventData($fleetRow, $FleetState);
		}
		
		// ✅ ASTROIO - EXTRAER DATOS
		$shipsArray = array();
		if (!empty($fleetRow['fleet_array'])) {
			$FleetRec = explode(';', $fleetRow['fleet_array']);
			foreach($FleetRec as $Group) {
				if(empty($Group)) continue;
				$Ship = explode(',', $Group);
				if(isset($Ship[0]) && isset($Ship[1])) {
					$shipsArray[$Ship[0]] = $Ship[1];
				}
			}
		}

		$MissionType = $fleetRow['fleet_mission'];
		$pveMissionLabels = array(
			20 => 'Ataque Pirata', 21 => 'Ataque a Imperio', 22 => 'Contraataque', 23 => 'Ataque al Devorador',
		);
		$MissionLabel = isset($LNG['type_mission_'.$MissionType])
			? $LNG['type_mission_'.$MissionType]
			: (isset($pveMissionLabels[$MissionType]) ? $pveMissionLabels[$MissionType] : 'PvE');
		
		return array(
			'text'			=> $EventString,
			'resttime'		=> $Rest,
			'returntime'	=> $Time,
			'mission_label' => $MissionLabel,

			// ✅ ASTROIO v2.2 — Para el radar del Overview y la Base de Flotas
			'state'         => (int) $FleetState,
			'is_incoming'   => ($fleetRow['fleet_owner'] != $this->userId),

			'ships_array'   => $shipsArray,
			'amount'        => $fleetRow['fleet_amount'],
			'fleet_mission' => $fleetRow['fleet_mission'],
			'fleet_owner'   => $fleetRow['fleet_owner'],
			'fleet_resource_metal'      => $fleetRow['fleet_resource_metal'],
			'fleet_resource_crystal'    => $fleetRow['fleet_resource_crystal'],
			'fleet_resource_deuterium'  => $fleetRow['fleet_resource_deuterium'],
			'fleet_resource_darkmatter' => $fleetRow['fleet_resource_darkmatter'],
			
			'startGalaxy' => $fleetRow['fleet_start_galaxy'],
			'startSystem' => $fleetRow['fleet_start_system'],
			'startPlanet' => $fleetRow['fleet_start_planet'],
			'start_type'  => $fleetRow['fleet_start_type'],
			'endGalaxy'   => $fleetRow['fleet_end_galaxy'],
			'endSystem'   => $fleetRow['fleet_end_system'],
			'endPlanet'   => $fleetRow['fleet_end_planet'],
			'end_type'    => $fleetRow['fleet_end_type']
		);
	}
	
	public function getEventData($fleetRow, $Status)
	{
		global $LNG;
		$Owner			= $fleetRow['fleet_owner'] == $this->userId;

		$FleetStyle  = array (
			1 => 'attack', 2 => 'federation', 3 => 'transport', 4 => 'deploy',
			5 => 'hold', 6 => 'espionage', 7 => 'colony', 8 => 'harvest', 9 => 'destroy',
			10 => 'missile', 11 => 'transport', 15 => 'transport',
			20 => 'attack', 21 => 'attack', 22 => 'attack', 23 => 'attack',
		);
		
	    $GoodMissions	= array(3, 5);
		$MissionType    = $fleetRow['fleet_mission'];

		$pveMissionLabels = array(
			20 => 'Ataque Pirata', 21 => 'Ataque a Imperio', 22 => 'Contraataque', 23 => 'Ataque al Devorador',
		);
		$MissionLabel = isset($LNG['type_mission_'.$MissionType])
			? $LNG['type_mission_'.$MissionType]
			: (isset($pveMissionLabels[$MissionType]) ? $pveMissionLabels[$MissionType] : 'PvE');

		$FleetPrefix    = ($Owner == true) ? 'own' : '';
		$FleetType		= isset($FleetStyle[$MissionType]) ? $FleetPrefix.$FleetStyle[$MissionType] : $FleetPrefix.'attack';
		$FleetName		= (!$Owner && ($MissionType == 1 || $MissionType == 2) && $Status == FLEET_OUTWARD && $fleetRow['fleet_target_owner'] != $this->userId) ? $LNG['cff_acs_fleet'] : $LNG['ov_fleet'];
		$FleetContent   = $this->CreateFleetPopupedFleetLink($fleetRow, $FleetName, $FleetType);
		$FleetCapacity  = $this->CreateFleetPopupedMissionLink($fleetRow, $MissionLabel, $FleetType);
		$FleetStatus    = array(0 => 'flight', 1 => 'return' , 2 => 'holding');
		$StartType		= $LNG['type_planet_'.$fleetRow['fleet_start_type']];
		$TargetType		= $LNG['type_planet_'.$fleetRow['fleet_end_type']];
	
		if ($MissionType == 8) {
			if ($Status == FLEET_OUTWARD)
				$EventString = sprintf($LNG['cff_mission_own_recy_0'], $FleetContent, $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), GetTargetAddressLink($fleetRow, $FleetType), $FleetCapacity);
			else
				$EventString = sprintf($LNG['cff_mission_own_recy_1'], $FleetContent, GetTargetAddressLink($fleetRow, $FleetType), $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $FleetCapacity);
		} elseif ($MissionType == 10) {
			if ($Owner)
				$EventString = sprintf($LNG['cff_mission_own_mip'], $fleetRow['fleet_amount'], $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $TargetType, $fleetRow['target_planetname'], GetTargetAddressLink($fleetRow, $FleetType));
			else
				$EventString = sprintf($LNG['cff_mission_target_mip'], $fleetRow['fleet_amount'], $this->BuildHostileFleetPlayerLink($fleetRow), $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $TargetType, $fleetRow['target_planetname'], GetTargetAddressLink($fleetRow, $FleetType));
		} elseif ($MissionType == 11 || $MissionType == 15) {		
			if ($Status == FLEET_OUTWARD)
				$EventString = sprintf($LNG['cff_mission_own_expo_0'], $FleetContent, $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), GetTargetAddressLink($fleetRow, $FleetType), $FleetCapacity);
			elseif ($Status == FLEET_HOLD)
				$EventString = sprintf($LNG['cff_mission_own_expo_2'], $FleetContent, $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), GetTargetAddressLink($fleetRow, $FleetType), $FleetCapacity);
			else
				$EventString = sprintf($LNG['cff_mission_own_expo_1'], $FleetContent, GetTargetAddressLink($fleetRow, $FleetType), $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $FleetCapacity);
		} else {
			if ($Owner == true) {
				if ($Status == FLEET_OUTWARD) {
					if (!$Owner && ($MissionType == 1 || $MissionType == 2))
						$Message  = $LNG['cff_mission_acs']	;
					else
						$Message  = $LNG['cff_mission_own_0'];
						
					$EventString  = sprintf($Message, $FleetContent, $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $TargetType, $fleetRow['target_planetname'], GetTargetAddressLink($fleetRow, $FleetType), $FleetCapacity);
				} elseif($Status == FLEET_RETURN)
					$EventString  = sprintf($LNG['cff_mission_own_1'], $FleetContent, $TargetType, $fleetRow['target_planetname'], GetTargetAddressLink($fleetRow, $FleetType), $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $FleetCapacity);
				else
					$EventString  = sprintf($LNG['cff_mission_own_2'], $FleetContent, $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $TargetType, $fleetRow['target_planetname'], GetTargetAddressLink($fleetRow, $FleetType), $FleetCapacity);
			} else {
				$isPveIncoming = in_array((int) $MissionType, array(20, 21, 22, 23))
				              && (int) $fleetRow['fleet_owner'] === 0;

				if ($isPveIncoming) {
					$attackerLabel = $this->BuildHostileFleetPlayerLink($fleetRow);
					$EventString = sprintf('%s atacan tu %s %s %s — Misión: %s', $attackerLabel, $TargetType, $fleetRow['target_planetname'], GetTargetAddressLink($fleetRow, $FleetType), $FleetCapacity);
				} else {
					if ($Status == FLEET_HOLD)
						$Message	= $LNG['cff_mission_target_stay'];
					elseif(in_array($MissionType, $GoodMissions))
						$Message	= $LNG['cff_mission_target_good'];
					else
						$Message	= $LNG['cff_mission_target_bad'];

					$EventString	= sprintf($Message, $FleetContent, $this->BuildHostileFleetPlayerLink($fleetRow), $StartType, $fleetRow['own_planetname'], GetStartAddressLink($fleetRow, $FleetType), $TargetType, $fleetRow['target_planetname'], GetTargetAddressLink($fleetRow, $FleetType), $FleetCapacity, $fleetRow['fleet_amount']);
				}
			}		       
		}

		$customColor = '';
		$isAttackMission = in_array((int) $MissionType, array(1, 2, 20, 21, 22, 23));

		if (!$Owner && $isAttackMission) {
			$customColor = 'color: #ff4444 !important; font-weight: bold; text-shadow: 0 0 5px rgba(255,68,68,0.5);';
		} elseif ($MissionType == 6) {
			$customColor = 'color: #ffcc00 !important; font-weight: bold; text-shadow: 0 0 5px rgba(255,204,0,0.5);';
		} elseif ($MissionType == 4) {
			$customColor = 'color: #00ccff !important; font-weight: bold; text-shadow: 0 0 5px rgba(0,204,255,0.5);';
		} elseif ($MissionType == 3) {
			$customColor = 'color: #66ff66 !important; font-weight: bold; text-shadow: 0 0 5px rgba(102,255,102,0.5);';
		} elseif ($Owner && $isAttackMission) {
			$customColor = 'color: #66ff66 !important; font-weight: bold; text-shadow: 0 0 5px rgba(102,255,102,0.5);';
		}

		$styleAttr = $customColor ? ' style="' . $customColor . '"' : '';

		$EventString = '<span class="'.$FleetStatus[$Status].' '.$FleetType.'"'.$styleAttr.'>'.$EventString.'</span>';

		if ($Status == FLEET_OUTWARD)
			$Time = $fleetRow['fleet_start_time'];
		elseif ($Status == FLEET_RETURN)
			$Time = $fleetRow['fleet_end_time'];
		elseif ($Status == FLEET_HOLD)
			$Time = $fleetRow['fleet_end_stay'];
		else
			$Time = TIMESTAMP;

		$Rest	= $Time - TIMESTAMP;
		return array($Rest, $EventString, $Time);
	}

	private function BuildHostileFleetPlayerLink($fleetRow)
    {
		global $LNG;

		if (in_array((int) $fleetRow['fleet_mission'], array(20, 21, 22, 23))
		    && empty($fleetRow['own_username'])
		    && (int) $fleetRow['fleet_owner'] === 0) {

			if ((int) $fleetRow['fleet_mission'] === 23) return '<b>El Devorador</b>';
			if ((int) $fleetRow['fleet_mission'] === 22) return '<b>Imperio Caído</b>';
			if ((int) $fleetRow['fleet_mission'] === 21) return '<b>Imperio Caído</b>';
			return '<b>Piratas</b>';
		}

		return $fleetRow['own_username'].' <a href="#" onclick="return Dialog.PM('.$fleetRow['fleet_owner'].')">'.$LNG['PM'].'</a>';
    }

	private function CreateFleetPopupedMissionLink($fleetRow, $Texte, $FleetType)
	{
		global $LNG;
		$FleetTotalC  = $fleetRow['fleet_resource_metal'] + $fleetRow['fleet_resource_crystal'] + $fleetRow['fleet_resource_deuterium'] + $fleetRow['fleet_resource_darkmatter'];
		if ($FleetTotalC != 0)
		{
			$textForBlind = $LNG['tech'][900].': ';
			$textForBlind .= floatToString($fleetRow['fleet_resource_metal']).' '.$LNG['tech'][901];
			$textForBlind .= '; '.floatToString($fleetRow['fleet_resource_crystal']).' '.$LNG['tech'][902];
			$textForBlind .= '; '.floatToString($fleetRow['fleet_resource_deuterium']).' '.$LNG['tech'][903];
			if($fleetRow['fleet_resource_darkmatter'] > 0)
				$textForBlind .= '; '.floatToString($fleetRow['fleet_resource_darkmatter']).' '.$LNG['tech'][921];
			
			$FRessource   = '<table style=\'width:200px\'>';
			$FRessource  .= '<tr><td style=\'width:50%;color:white\'>'.$LNG['tech'][901].'</td><td style=\'width:50%;color:white\'>'. pretty_number($fleetRow['fleet_resource_metal']).'</td></tr>';
			$FRessource  .= '<tr><td style=\'width:50%;color:white\'>'.$LNG['tech'][902].'</td><td style=\'width:50%;color:white\'>'. pretty_number($fleetRow['fleet_resource_crystal']).'</td></tr>';
			$FRessource  .= '<tr><td style=\'width:50%;color:white\'>'.$LNG['tech'][903].'</td><td style=\'width:50%;color:white\'>'. pretty_number($fleetRow['fleet_resource_deuterium']).'</td></tr>';
			if($fleetRow['fleet_resource_darkmatter'] > 0)
				$FRessource  .= '<tr><td style=\'width:50%;color:white\'>'.$LNG['tech'][921].'</td><td style=\'width:50%;color:white\'>'. pretty_number($fleetRow['fleet_resource_darkmatter']).'</td></tr>';
			$FRessource  .= '</table>';
			
			$MissionPopup  = '<a data-tooltip-content="'.$FRessource.'" class="tooltip '.$FleetType.'">'.$Texte.'</a><span class="textForBlind"> ('.$textForBlind.')</span>';
		}
		else
			$MissionPopup  = $Texte;

		return $MissionPopup;
	}

	private function CreateFleetPopupedFleetLink($fleetRow, $Text, $FleetType)
	{
		global $LNG, $USER, $resource;
		$SpyTech		= $USER[$resource[106]];
		$Owner			= $fleetRow['fleet_owner'] == $this->userId;
		$FleetRec		= explode(';', $fleetRow['fleet_array']);
		$FleetPopup		= '<a href="#" data-tooltip-content="<table style=\'width:200px\'>';
		$textForBlind	= '';

		$shipsData	= array();
		foreach($FleetRec as $Item => $Group)
		{
			if (empty($Group)) continue;
			$Ship    = explode(',', $Group);
			$FleetPopup 	.= '<tr><td style=\'width:50%;color:white\'>'.$LNG['tech'][$Ship[0]].':</td><td style=\'width:50%;color:white\'>'.pretty_number($Ship[1]).'</td></tr>';
			$shipsData[]	= floatToString($Ship[1]).' '.$LNG['tech'][$Ship[0]];
		}
		$textForBlind	.= implode('; ', $shipsData);

		if (empty($shipsData)) {
			$FleetPopup 	.= '<tr><td style=\'width:100%;color:white\'>'.$LNG['cff_no_loot'].'</span></td></tr>';
			$textForBlind	= $LNG['cff_no_loot'];
		}
		
		$FleetPopup  .= '</table>" class="tooltip '. $FleetType .'">'. $Text .'</a><span class="textForBlind"> ('.$textForBlind.')</span>';

		return $FleetPopup;
	}	
}