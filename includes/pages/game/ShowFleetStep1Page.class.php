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
 * AstroIO: 
 *   - soporte para acs_id (integración ACS PvE con flujo nativo)
 *   - v1.1: acepta 'planettype' además de 'type' (fix PvE)
 *   - v1.2: lee $_SESSION['pve_attack_target'] para preservar
 *           las coordenadas del imperio a través del flujo nativo
 *           (fleetTable → fleetStep1 → 2 → 3)
 *   - v1.3: soporte para misión 23 (Torneo del Devorador).
 *           El flujo es genérico: target_mission se lee desde GET o
 *           desde la sesión PvE, y no se valida contra una lista blanca,
 *           así que 23 pasa sin problema. La sesión 'pve_attack_target'
 *           se reutiliza para las coordenadas del fantasma del boss.
 *
 * ⚠️ AstroIO FIX ALIANZA — NOTA IMPORTANTE (v1.4):
 *   Este archivo NO se modifica para el bloqueo de aliados.
 *
 *   Motivo técnico:
 *     El método checkTarget() se invoca por AJAX cuando el jugador hace
 *     clic en un planeta desde la galaxia. En ese momento el sistema
 *     NO sabe qué misión va a elegir el jugador (atacar, transportar,
 *     desplegar, espiar, reciclar, deposit...).
 *
 *     Si bloqueáramos aquí a los aliados, romperíamos las misiones
 *     PACÍFICAS que los aliados SÍ necesitan:
 *       - Misión 3: Transportar recursos a un aliado
 *       - Misión 4: Desplegar flota a un aliado
 *       - Misión 5: Depositar en el banco de la alianza
 *       - Misión 6: Espiar a un aliado (permitido)
 *       - Misión 8: Reciclar escombros de un aliado
 *
 *   El bloqueo real de "no atacar a tu propia alianza" YA ESTÁ
 *   aplicado en 3 capas, todas ellas específicas de misiones agresivas:
 *
 *     CAPA 1 → class.FleetFunctions.php
 *              Oculta las misiones 1 (Ataque), 2 (ACS) y 9 (Destruir Luna)
 *              en el selector del fleetStep2 cuando el target es aliado.
 *
 *     CAPA 2 → ShowFleetStep3Page.class.php
 *              Bloquea el envío al confirmar si el target es aliado.
 *
 *     CAPA 3 → MissionCaseAttack.class.php
 *              Devuelve la flota sin combatir si llega al destino.
 *
 *   Con esas 3 capas el bug queda resuelto sin tocar este archivo.
 */

class ShowFleetStep1Page extends AbstractGamePage
{
	public static $requireModule = MODULE_FLEET_TABLE;

	function __construct() 
	{
		parent::__construct();
	}
	
	public function show()
	{
		global $USER, $PLANET, $pricelist, $reslist, $LNG;

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v1.2 — Recuperar target PvE desde sesión
		//
		// Prioridad de coordenadas:
		//   1) GET params (URL explícita)
		//   2) $_SESSION['pve_attack_target'] (flujo PvE desde el Imperio Caído
		//      o Torneo del Devorador)
		//   3) Defaults de $PLANET (flujo nativo PvP)
		//
		// La sesión NO se borra aquí: sobrevive a fleetStep2 y fleetStep3.
		// Se sobreescribe en el próximo attackPrepare() o se limpia en el
		// envío exitoso de la flota.
		// ═══════════════════════════════════════════════════════════
		$pveTarget = !empty($_SESSION['pve_attack_target']) ? $_SESSION['pve_attack_target'] : null;

		// Defaults (fallback al planeta actual si no hay sesión)
		$defaultGalaxy  = $pveTarget ? (int) $pveTarget['galaxy']  : (int) $PLANET['galaxy'];
		$defaultSystem  = $pveTarget ? (int) $pveTarget['system']  : (int) $PLANET['system'];
		$defaultPlanet  = $pveTarget ? (int) $pveTarget['planet']  : (int) $PLANET['planet'];
		$defaultType    = $pveTarget ? (int) $pveTarget['type']    : (int) $PLANET['planet_type'];
		$defaultMission = $pveTarget ? (int) $pveTarget['mission'] : 0;

		// GET manda (URL explícita), si no hay GET → usar defaults
		$targetGalaxy  = HTTP::_GP('galaxy',  $defaultGalaxy);
		$targetSystem  = HTTP::_GP('system',  $defaultSystem);
		$targetPlanet  = HTTP::_GP('planet',  $defaultPlanet);

		// Aceptar 'planettype' (URL PvE) y 'type' (URL nativa)
		$targetType = (int) HTTP::_GP('planettype', 0);
		if ($targetType <= 0) {
			$targetType = (int) HTTP::_GP('type', 0);
		}
		if ($targetType <= 0) {
			$targetType = $defaultType;
		}

		// Misión: GET primero, después sesión PvE, después 0
		// Acepta cualquier valor (1, 2, 3, 4, 5, ..., 20, 21, 22, 23)
		$mission = (int) HTTP::_GP('target_mission', 0);
		if ($mission <= 0 && $defaultMission > 0) {
			$mission = $defaultMission;
		}

		// ═══════════════════════════════════════════════════════════
		// ASTROIO — acs_id desde URL o sesión
		// ═══════════════════════════════════════════════════════════
		$prefilledAcsId = (int) HTTP::_GP('acs_id', 0);

		if ($prefilledAcsId <= 0 && $pveTarget && !empty($pveTarget['acs_id'])) {
			$prefilledAcsId = (int) $pveTarget['acs_id'];
		}
		if ($prefilledAcsId <= 0 && !empty($_SESSION['pve_acs_id'])) {
			$prefilledAcsId = (int) $_SESSION['pve_acs_id'];
		}
		// ═══════════════════════════════════════════════════════════
		
		$Fleet		= array();
		$FleetRoom	= 0;
		foreach ($reslist['fleet'] as $id => $ShipID)
		{
			$amount		 				= max(0, round(HTTP::_GP('ship'.$ShipID, 0.0, 0.0)));
			
			if ($amount < 1 || $ShipID == 212) continue;

			$Fleet[$ShipID]				= $amount;
			$FleetRoom			   	   += $pricelist[$ShipID]['capacity'] * $amount;
		}
		
		$FleetRoom	*= 1 + $USER['factor']['ShipStorage'];
		
		if (empty($Fleet))
			FleetFunctions::GotoFleetPage();
	
		$FleetData	= array(
			'fleetroom'			=> floatToString($FleetRoom),
			'gamespeed'			=> FleetFunctions::GetGameSpeedFactor(),
			'fleetspeedfactor'	=> max(0, 1 + $USER['factor']['FlyTime']),
			'planet'			=> array('galaxy' => $PLANET['galaxy'], 'system' => $PLANET['system'], 'planet' => $PLANET['planet'], 'planet_type' => $PLANET['planet_type']),
			'maxspeed'			=> FleetFunctions::GetFleetMaxSpeed($Fleet, $USER),
			'ships'				=> FleetFunctions::GetFleetShipInfo($Fleet, $USER),
			'fleetMinDuration'	=> MIN_FLEET_TIME,
		);
		
		$token		= getRandomString();
		
		$_SESSION['fleet'][$token]	= array(
			'time'			=> TIMESTAMP,
			'fleet'			=> $Fleet,
			'fleetRoom'		=> $FleetRoom,
			'fleetGroup'	=> $prefilledAcsId, // ASTROIO: propagar acs_id al Step2 y Step3
		);

		$shortcutList	= $this->GetUserShotcut();
		$colonyList 	= $this->GetColonyList();
		$ACSList 		= $this->GetAvalibleACS();
		
		if(!empty($shortcutList)) {
			$shortcutAmount	= max(array_keys($shortcutList));
		} else {
			$shortcutAmount	= 0;
		}
		
		$this->tplObj->loadscript('flotten.js');
		$this->tplObj->execscript('updateVars();FleetTime();window.setInterval("FleetTime()", 1000);');
		$this->assign(array(
			'token'				=> $token,
			'mission'			=> $mission,
			'shortcutList'		=> $shortcutList,
			'shortcutMax'		=> $shortcutAmount,
			'colonyList' 		=> $colonyList,
			'ACSList' 			=> $ACSList,
			'galaxy' 			=> $targetGalaxy,
			'system' 			=> $targetSystem,
			'planet' 			=> $targetPlanet,
			'type'				=> $targetType,
			'speedSelect'		=> FleetFunctions::$allowedSpeed,
			'typeSelect'   		=> array(1 => $LNG['type_planet_1'], 2 => $LNG['type_planet_2'], 3 => $LNG['type_planet_3']),
			'fleetdata'			=> $FleetData,
			'prefilledAcsId'	=> $prefilledAcsId, // ASTROIO: para el template
		));
		
		$this->display('page.fleetStep1.default.tpl');
	}
	
	public function saveShortcuts()
	{
		global $USER, $LNG;
		
		if(!isset($_REQUEST['shortcut'])) {
			$this->sendJSON($LNG['fl_shortcut_saved']);
		}

        $db = Database::get();

		$ShortcutData	= $_REQUEST['shortcut'];
		$ShortcutUser	= $this->GetUserShotcut();
		foreach($ShortcutData as $ID => $planetData) {
			if(!isset($ShortcutUser[$ID])) {
				if(empty($planetData['name']) || empty($planetData['galaxy']) || empty($planetData['system']) || empty($planetData['planet'])) {
					continue;
				}

                $sql = "INSERT INTO %%SHORTCUTS%% SET ownerID = :userID, name = :name, galaxy = :galaxy, system = :system, planet = :planet, type = :type;";
                $db->insert($sql, array(
                    ':userID'   => $USER['id'],
                    ':name'     => $planetData['name'],
                    ':galaxy'   => $planetData['galaxy'],
                    ':system'   => $planetData['system'],
                    ':planet'   => $planetData['planet'],
                    ':type'     => $planetData['type']
                ));
			} elseif(empty($planetData['name'])) {
				$sql = "DELETE FROM %%SHORTCUTS%% WHERE shortcutID = :shortcutID AND ownerID = :userID;";
                $db->delete($sql, array(
                    ':shortcutID'   => $ID,
                    ':userID'       => $USER['id']
                ));
            } else {
				$planetData['ownerID']		= $USER['id'];
				$planetData['shortcutID']		= $ID;
				if($planetData != $ShortcutUser[$ID]) {
                    $sql = "UPDATE %%SHORTCUTS%% SET name = :name, galaxy = :galaxy, system = :system, planet = :planet, type = :type WHERE shortcutID = :shortcutID AND ownerID = :userID;";
                    $db->update($sql, array(
                        ':userID'   => $USER['id'],
                        ':name'     => $planetData['name'],
                        ':galaxy'   => $planetData['galaxy'],
                        ':system'   => $planetData['system'],
                        ':planet'   => $planetData['planet'],
                        ':type'     => $planetData['type'],
                        ':shortcutID'   => $ID
                    ));
                }
			}
		}
		
		$this->sendJSON($LNG['fl_shortcut_saved']);
	}
	
	private function GetColonyList()
	{
		global $PLANET, $USER;
		
		$ColonyList	= array();
		
		foreach($USER['PLANETS'] as $CurPlanetID => $CurPlanet)
		{
			if ($PLANET['id'] == $CurPlanet['id'])
				continue;
			
			$ColonyList[] = array(
				'name'		=> $CurPlanet['name'],
				'galaxy'	=> $CurPlanet['galaxy'],
				'system'	=> $CurPlanet['system'],
				'planet'	=> $CurPlanet['planet'],
				'type'		=> $CurPlanet['planet_type'],
			);	
		}
			
		return $ColonyList;
	}
	
	private function GetUserShotcut()
	{
		global $USER;
		
		if (!isModuleAvailable(MODULE_SHORTCUTS))
			return array();

        $db = Database::get();

        $sql = "SELECT * FROM %%SHORTCUTS%% WHERE ownerID = :userID;";
        $ShortcutResult = $db->select($sql, array(
            ':userID'   => $USER['id']
        ));

        $ShortcutList	= array();

		foreach($ShortcutResult as $ShortcutRow) {
			$ShortcutList[$ShortcutRow['shortcutID']] = $ShortcutRow;
		}
		
		return $ShortcutList;
	}
	
	private function GetAvalibleACS()
	{
		global $USER;
		
		$db = Database::get();

        $sql = "SELECT acs.id, acs.name, planet.galaxy, planet.system, planet.planet, planet.planet_type
		FROM %%USERS_ACS%%
		INNER JOIN %%AKS%% acs ON acsID = acs.id
		INNER JOIN %%PLANETS%% planet ON planet.id = acs.target
		WHERE userID = :userID AND :maxFleets > (SELECT COUNT(*) FROM %%FLEETS%% WHERE fleet_group = acsID);";
        $ACSResult = $db->select($sql, array(
            ':userID'       => $USER['id'],
            ':maxFleets'    => Config::get()->max_fleets_per_acs,
        ));

        $ACSList	= array();
		
		foreach ($ACSResult as $ACSRow) {
			$ACSList[]	= $ACSRow;
		}
		
		return $ACSList;
	}
	
	function checkTarget()
	{
		global $PLANET, $LNG, $USER, $resource;

		$targetGalaxy 		= HTTP::_GP('galaxy', 0);
		$targetSystem 		= HTTP::_GP('system', 0);
		$targetPlanet		= HTTP::_GP('planet', 0);
		$targetPlanetType	= HTTP::_GP('planet_type', 1);
	
		if($targetGalaxy == $PLANET['galaxy'] && $targetSystem == $PLANET['system'] && $targetPlanet == $PLANET['planet'] && $targetPlanetType == $PLANET['planet_type'])
		{
			$this->sendJSON($LNG['fl_error_same_planet']);
		}

		// If target is expedition
		if ($targetPlanet != Config::get()->max_planets + 1)
		{
			$db = Database::get();
            $sql = "SELECT u.id, u.urlaubs_modus, u.user_lastip, u.authattack,
            	p.destruyed, p.der_metal, p.der_crystal, p.destruyed
                FROM %%USERS%% as u, %%PLANETS%% as p WHERE
                p.universe = :universe AND
                p.galaxy = :targetGalaxy AND
                p.system = :targetSystem AND
                p.planet = :targetPlanet  AND
                p.planet_type = :targetType AND
                u.id = p.id_owner;";

			$planetData = $db->selectSingle($sql, array(
                ':universe'     => Universe::current(),
                ':targetGalaxy' => $targetGalaxy,
                ':targetSystem' => $targetSystem,
                ':targetPlanet' => $targetPlanet,
                ':targetType' => (($targetPlanetType == 2) ? 1 : $targetPlanetType),
            ));

            if ($targetPlanetType == 3 && empty($planetData))
			{
				$this->sendJSON($LNG['fl_error_no_moon']);
			}

            if ($targetPlanetType == 1 && empty($planetData))
			{
				$this->sendJSON($LNG['OK']);
			}

			if ($targetPlanetType != 2 && !empty($planetData) && $planetData['urlaubs_modus'])
			{
				$this->sendJSON($LNG['fl_in_vacation_player']);
			}

			if ($planetData['id'] != $USER['id'] && Config::get()->adm_attack == 1 && !empty($planetData) && $planetData['authattack'] > $USER['authlevel'])
			{
				$this->sendJSON($LNG['fl_admin_attack']);
			}

			if (!empty($planetData) && $planetData['destruyed'] != 0)
			{
				$this->sendJSON($LNG['fl_error_not_avalible']);
			}

			if($targetPlanetType == 2 && !empty($planetData) && $planetData['der_metal'] == 0 && $planetData['der_crystal'] == 0)
			{
				$this->sendJSON($LNG['fl_error_empty_derbis']);
			}

			$sql	= 'SELECT (
				(SELECT COUNT(*) FROM %%MULTI%% WHERE userID = :userID) +
				(SELECT COUNT(*) FROM %%MULTI%% WHERE userID = :dataID)
			) as count;';

			$multiCount	= $db->selectSingle($sql ,array(
				':userID' => $USER['id'],
				':dataID' => $planetData['id']
			), 'count');

			if(ENABLE_MULTIALERT && $USER['id'] != $planetData['id'] && $USER['authlevel'] != AUTH_ADM && $USER['user_lastip'] == $planetData['user_lastip'] && $multiCount != 2)
			{
				$this->sendJSON($LNG['fl_multi_alarm']);
			}
		}
		else
		{
			if ($USER[$resource[124]] == 0)
			{
				$this->sendJSON($LNG['fl_target_not_exists']);
			}
			
			$activeExpedition	= FleetFunctions::GetCurrentFleets($USER['id'], 15, true);

			if ($activeExpedition >= FleetFunctions::getExpeditionLimit($USER))
			{
				$this->sendJSON($LNG['fl_no_expedition_slot']);
			}
		}

		$this->sendJSON('OK');	
	}
}