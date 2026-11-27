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
 * AstroIO: soporte para acs_id (integración ACS PvE con flujo nativo)
 * AstroIO v1.1 (SISTEMA DE CLIMA):
 *   - Se carga ClimaEngine para mostrar el clima del objetivo antes de atacar.
 *   - Se obtiene el clima actual y la predicción del planeta/luna objetivo.
 *   - Se pasa al template para que el jugador decida si atacar o no.
 * AstroIO v1.2 (BUFF CLIMÁTICO):
 *   - Se obtiene el buff activo del atacante y se pasa al template.
 *   - El jugador sabe que su buff se aplicará al combate antes de lanzar.
 */

// ============================================
// ASTROIO - Cargar ClimaEngine explicitamente
// ============================================
if (!class_exists('ClimaEngine')) {
    $__climaFile = (defined('ROOT_PATH') ? ROOT_PATH : '') . 'includes/classes/ClimaEngine.class.php';
    if (file_exists($__climaFile)) {
        require_once $__climaFile;
    }
}
// ============================================

class ShowFleetStep2Page extends AbstractGamePage
{
	public static $requireModule = MODULE_FLEET_TABLE;

	function __construct() 
	{
		parent::__construct();
	}
	
	public function show()
	{
		global $USER, $PLANET, $LNG;
	
		$this->tplObj->loadscript('flotten.js');
		
		$targetGalaxy  				= HTTP::_GP('galaxy', 0);
		$targetSystem   			= HTTP::_GP('system', 0);
		$targetPlanet   			= HTTP::_GP('planet', 0);
		$targetType 				= HTTP::_GP('type', 0);
		$targetMission 				= HTTP::_GP('target_mission', 0);
		$fleetSpeed  				= HTTP::_GP('speed', 0);		
		$fleetGroup 				= HTTP::_GP('fleet_group', 0);
		$token						= HTTP::_GP('token', '');

		if (!isset($_SESSION['fleet'][$token]))
		{
			FleetFunctions::GotoFleetPage();
		}

		// ═══════════════════════════════════════════════════════════
		// ASTROIO — Recuperar acs_id pre-rellenado desde Step1
		// ═══════════════════════════════════════════════════════════
		// Si Step1 guardó un acs_id (porque el jugador vino desde createAcsPve
		// o acceptInvite), y ahora el POST no trae fleet_group, usar ese valor.
		// ═══════════════════════════════════════════════════════════
		$prefilledAcsId = 0;
		if (isset($_SESSION['fleet'][$token]['fleetGroup'])) {
			$prefilledAcsId = (int) $_SESSION['fleet'][$token]['fleetGroup'];
		}

		// Si el POST no trae fleet_group pero sí tenemos prefilled, usarlo
		if ($fleetGroup <= 0 && $prefilledAcsId > 0) {
			$fleetGroup = $prefilledAcsId;
		}
		// ═══════════════════════════════════════════════════════════

		$fleetArray    				= $_SESSION['fleet'][$token]['fleet'];

        $db = Database::get();
        $sql = "SELECT id, id_owner, der_metal, der_crystal FROM %%PLANETS%% WHERE universe = :universe AND galaxy = :targetGalaxy AND system = :targetSystem AND planet = :targetPlanet AND planet_type = '1';";
        $targetPlanetData = $db->selectSingle($sql, array(
            ':universe' => Universe::current(),
            ':targetGalaxy' => $targetGalaxy,
            ':targetSystem' => $targetSystem,
            ':targetPlanet' => $targetPlanet
        ));

        if($targetType == 2 && $targetPlanetData['der_metal'] == 0 && $targetPlanetData['der_crystal'] == 0)
		{
			$this->printMessage($LNG['fl_error_empty_derbis'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleetTable'
			)));
		}
			
		$MisInfo		     		= array();		
		$MisInfo['galaxy']     		= $targetGalaxy;		
		$MisInfo['system'] 	  		= $targetSystem;	
		$MisInfo['planet'] 	  		= $targetPlanet;		
		$MisInfo['planettype'] 		= $targetType;	
		$MisInfo['IsAKS']			= $fleetGroup;
		$MisInfo['Ship'] 			= $fleetArray;		
		
		$MissionOutput	 			= FleetFunctions::GetFleetMissions($USER, $MisInfo, $targetPlanetData);
		
		if(empty($MissionOutput['MissionSelector']))
		{
			$this->printMessage($LNG['fl_empty_target'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleetTable'
			)));
		}
		
		$GameSpeedFactor   		 	= FleetFunctions::GetGameSpeedFactor();		
		$MaxFleetSpeed 				= FleetFunctions::GetFleetMaxSpeed($fleetArray, $USER);
		$distance      				= FleetFunctions::GetTargetDistance(array($PLANET['galaxy'], $PLANET['system'], $PLANET['planet']), array($targetGalaxy, $targetSystem, $targetPlanet));
		$duration      				= FleetFunctions::GetMissionDuration($fleetSpeed, $MaxFleetSpeed, $distance, $GameSpeedFactor, $USER);
		$consumption				= FleetFunctions::GetFleetConsumption($fleetArray, $duration, $distance, $USER, $GameSpeedFactor);
		
		if($consumption > $PLANET['deuterium'])
		{
			$this->printMessage($LNG['fl_not_enough_deuterium'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleetTable'
			)));
		}
		
		if(!FleetFunctions::CheckUserSpeed($fleetSpeed))
		{
			FleetFunctions::GotoFleetPage(0);
		}
		
		$_SESSION['fleet'][$token]['speed']			= $MaxFleetSpeed;
		$_SESSION['fleet'][$token]['distance']		= $distance;
		$_SESSION['fleet'][$token]['targetGalaxy']	= $targetGalaxy;
		$_SESSION['fleet'][$token]['targetSystem']	= $targetSystem;
		$_SESSION['fleet'][$token]['targetPlanet']	= $targetPlanet;
		$_SESSION['fleet'][$token]['targetType']	= $targetType;
		$_SESSION['fleet'][$token]['fleetGroup']	= $fleetGroup;
		$_SESSION['fleet'][$token]['fleetSpeed']	= $fleetSpeed;
		
		if(!empty($fleet_group))
			$targetMission	= 2;

		$fleetData	= array(
			'fleetroom'			=> floatToString($_SESSION['fleet'][$token]['fleetRoom']),
			'consumption'		=> floatToString($consumption),
		);

		// ============================================
		// ASTROIO v1.1 (SISTEMA DE CLIMA) - Obtener clima del objetivo
		// ============================================
		$climaObjetivo = null;
		$climaPrevisto = null;

		if (class_exists('ClimaEngine') && !empty($targetPlanetData['id'])) {
			// Determinar el ID del cuerpo celeste objetivo (planeta o luna)
			$targetBodyId = (int)$targetPlanetData['id'];

			// Si el objetivo es una luna (type 3), buscar el ID de la luna
			if ((int)$targetType === 3) {
				$moonData = $db->selectSingle(
					"SELECT id FROM %%PLANETS%% WHERE id_luna = :planetId AND planet_type = 3 LIMIT 1",
					array(':planetId' => $targetPlanetData['id'])
				);
				if (!empty($moonData)) {
					$targetBodyId = (int)$moonData['id'];
				}
			}

			try {
				$climaObjetivo = ClimaEngine::getClimaPlaneta($targetBodyId);
				$climaPrevisto = ClimaEngine::getPrediccionPlaneta($targetBodyId);
			} catch (Exception $e) {
				// Silencioso: si falla, no se muestra el clima
			}
		}
		// ============================================

		// ============================================
		// ASTROIO v1.2 (BUFF CLIMÁTICO) - Obtener buff activo del atacante
		// ============================================
		$buffActivo = null;
		if (class_exists('ClimaEngine') && !empty($USER['id'])) {
			try {
				$buffActivo = ClimaEngine::getActiveBuff((int)$USER['id']);
			} catch (Exception $e) {
				// Silencioso: si falla el buff, la página sigue funcionando
			}
		}
		// ============================================
			
		$this->tplObj->execscript('calculateTransportCapacity();');
		$this->assign(array(
			'fleetdata'						=> $fleetData,
			'consumption'					=> floatToString($consumption),
			'mission'						=> $targetMission,
			'galaxy'			 			=> $PLANET['galaxy'],
			'system'			 			=> $PLANET['system'],
			'planet'			 			=> $PLANET['planet'],
			'type'			 				=> $PLANET['planet_type'],
			'MissionSelector' 				=> $MissionOutput['MissionSelector'],
			'StaySelector' 					=> $MissionOutput['StayBlock'],
			'fl_dm_alert_message'			=> sprintf($LNG['fl_dm_alert_message'], $LNG['type_mission_11'], $LNG['tech'][921]),
			'fl_continue'					=> $LNG['fl_continue'],
			'token' 						=> $token,
			'prefilledAcsId'				=> $prefilledAcsId, // ASTROIO: para el template
			'clima_objetivo'				=> $climaObjetivo, // ASTROIO v1.1
			'clima_previsto'				=> $climaPrevisto, // ASTROIO v1.1
			'buff_activo'					=> $buffActivo,    // ASTROIO v1.2
		));
		
		$this->display('page.fleetStep2.default.tpl');
	}
}
?>