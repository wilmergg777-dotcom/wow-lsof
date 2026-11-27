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
 * AstroIO v2.1:
 *  - Asegura que el usuario esté en USERS_ACS (para ACS creados por PvE)
 *  - Skip noob protection + bash para targets fantasmas (id_owner >= 900M)
 *  - v2.1: limpia $_SESSION['pve_attack_target'] y demás tras enviar la flota
 *
 * AstroIO v2.2:
 *  - Soporte para misión 23 (Torneo del Devorador):
 *    - Detecta si el target es un boss ghost (event_type='boss')
 *    - Permite target_mission=23 aunque no esté en GetFleetMissions()
 *    - Skip noob/bash para boss ghosts (id_owner >= 900M)
 *
 * AstroIO v2.3 (FIX ASTEROIDES):
 *  - Soporte para misión 32 (reciclaje de asteroide):
 *    - $targetPlanetData se inicializa como array vacío si selectSingle devuelve false
 *    - Se detecta si el target es un asteroide activo ($isAsteroidTarget)
 *    - La misión 32 no requiere planeta, ni targetPlayerData, ni noob/bash
 *    - Se evita "Trying to access array offset on false" en $targetPlanetData["destruyed"]
 *
 * AstroIO v2.4 (FIX ALIANZA):
 *  - Bloqueo: no se puede atacar a miembros de tu propia alianza (misiones 1, 2, 9)
 *  - Excepciones respetadas:
 *      - Misión 23 (Boss Tournament -> target es fantasma)
 *      - Misión 32 (Asteroide -> no es jugador)
 *      - Cualquier target PvE ghost (id_owner >= 900M)
 *      - Tu propio planeta
 *      - Misiones pacíficas (3, 4, 5, 6, 7, 8, 10, 11, 15, etc.)
 */

class ShowFleetStep3Page extends AbstractGamePage
{
	public static $requireModule = MODULE_FLEET_TABLE;

	function __construct() 
	{
		parent::__construct();
	}
	
	public function show()
	{
		global $USER, $PLANET, $resource, $LNG;
			
		if (IsVacationMode($USER)) {
			FleetFunctions::GotoFleetPage(0);
		}
		
		$targetMission 			= HTTP::_GP('mission', 3);
		$TransportMetal			= max(0, round(HTTP::_GP('metal', 0.0)));
		$TransportCrystal		= max(0, round(HTTP::_GP('crystal', 0.0)));
		$TransportDeuterium		= max(0, round(HTTP::_GP('deuterium', 0.0)));
		$stayTime 				= HTTP::_GP('staytime', 0);
		$token					= HTTP::_GP('token', '');

		$config					= Config::get();

		if (!isset($_SESSION['fleet'][$token])) {
			FleetFunctions::GotoFleetPage(1);
		}
			
		if ($_SESSION['fleet'][$token]['time'] < TIMESTAMP - 600) {
			unset($_SESSION['fleet'][$token]);
			FleetFunctions::GotoFleetPage(0);
		}

		$formData		= $_SESSION['fleet'][$token];
        unset($_SESSION['fleet'][$token]);

		$distance		= $formData['distance'];
		$targetGalaxy	= $formData['targetGalaxy'];
		$targetSystem	= $formData['targetSystem'];
		$targetPlanet	= $formData['targetPlanet'];
		$targetType		= $formData['targetType'];
		$fleetGroup		= $formData['fleetGroup'];
		$fleetArray  	= $formData['fleet'];
		$fleetStorage	= $formData['fleetRoom'];
		$fleetSpeed		= $formData['fleetSpeed'];
		
		if($targetMission != 2)
		{
			$fleetGroup	= 0;
		}
			
		if ($PLANET['galaxy'] == $targetGalaxy && $PLANET['system'] == $targetSystem && $PLANET['planet'] == $targetPlanet && $PLANET['planet_type'] == $targetType)
		{
			$this->printMessage($LNG['fl_error_same_planet'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleet1'
			)));
		}

		if ($targetGalaxy < 1 || $targetGalaxy > $config->max_galaxy || 
			$targetSystem < 1 || $targetSystem > $config->max_system || 
			$targetPlanet < 1 || $targetPlanet > ($config->max_planets + 1) ||
			($targetType !== 1 && $targetType !== 2 && $targetType !== 3)) {
			$this->printMessage($LNG['fl_invalid_target'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleet1'
			)));
		}

		if ($targetMission == 3 && $TransportMetal + $TransportCrystal + $TransportDeuterium < 1)
		{
			$this->printMessage($LNG['fl_no_noresource'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleet2'
			)));
		}
		
		$ActualFleets		= FleetFunctions::GetCurrentFleets($USER['id']);
		
		if (FleetFunctions::GetMaxFleetSlots($USER) <= $ActualFleets)
		{
			$this->printMessage($LNG['fl_no_slots'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleetTable'
			)));
		}
		
		$ACSTime = 0;

        $db = Database::get();

		// ═══════════════════════════════════════════════════════════
		// ASTROIO — Asegurar USERS_ACS
		// ═══════════════════════════════════════════════════════════
		// Los ACS creados por PveFleetHelper::createAcsGroup() NO añaden
		// al creador a USERS_ACS. El flujo nativo SÍ lo espera. Sin este
		// fix, el ACS se resetea a mission=1 y se pierde la agrupación.
		// ═══════════════════════════════════════════════════════════
		if (!empty($fleetGroup)) {
			$sql = "SELECT COUNT(*) AS cnt FROM %%USERS_ACS%% WHERE userID = :uid AND acsID = :acsID;";
			$userInAcs = (int) $db->selectSingle($sql, array(
				':uid'   => $USER['id'],
				':acsID' => $fleetGroup,
			), 'cnt');

			if ($userInAcs === 0) {
				$sql = "SELECT id FROM %%AKS%% WHERE id = :acsID LIMIT 1;";
				$acsExists = $db->selectSingle($sql, array(':acsID' => $fleetGroup));

				if (!empty($acsExists)) {
					$sql = "INSERT INTO %%USERS_ACS%% SET userID = :uid, acsID = :acsID;";
					$db->insert($sql, array(
						':uid'   => $USER['id'],
						':acsID' => $fleetGroup,
					));
				}
			}
		}
		// ═══════════════════════════════════════════════════════════

        if(!empty($fleetGroup))
		{
            $sql = "SELECT ankunft FROM %%USERS_ACS%% INNER JOIN %%AKS%% ON id = acsID
			WHERE acsID = :acsID AND :maxFleets > (SELECT COUNT(*) FROM %%FLEETS%% WHERE fleet_group = :acsID);";
            $ACSTime = $db->selectSingle($sql, array(
                ':acsID'        => $fleetGroup,
                ':maxFleets'    => $config->max_fleets_per_acs,
            ), 'ankunft');

            if (empty($ACSTime)) {
				$fleetGroup	= 0;
				$targetMission	= 1;
			}
		}

        $sql = "SELECT id, id_owner, der_metal, der_crystal, destruyed, ally_deposit FROM %%PLANETS%% WHERE universe = :universe AND galaxy = :targetGalaxy AND system = :targetSystem AND planet = :targetPlanet AND planet_type = :targetType;";
        $targetPlanetData = $db->selectSingle($sql, array(
            ':universe'     => Universe::current(),
            ':targetGalaxy' => $targetGalaxy,
            ':targetSystem' => $targetSystem,
            ':targetPlanet' => $targetPlanet,
            ':targetType' => ($targetType == 2 ? 1 : $targetType),
        ));

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v2.3 — FIX: $targetPlanetData puede ser false
		// ═══════════════════════════════════════════════════════════
		// selectSingle() devuelve false cuando no encuentra fila (ej:
		// un asteroide en una posición vacía). Sin este fix, el acceso
		// a $targetPlanetData["destruyed"] lanza:
		//   "Trying to access array offset on false"
		// ═══════════════════════════════════════════════════════════
		if (!is_array($targetPlanetData)) {
			$targetPlanetData = array();
		}
		// ═══════════════════════════════════════════════════════════

		// ═══════════════════════════════════════════════════════════
		// ASTROIO — Detección de fantasma PvE (para skip noob/bashing)
		// ═══════════════════════════════════════════════════════════
		$isPveGhost = !empty($targetPlanetData['id_owner'])
		           && (int) $targetPlanetData['id_owner'] >= 900000000;
		// ═══════════════════════════════════════════════════════════

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v2.2 — Detección de BOSS GHOST (Torneo del Devorador)
		// ═══════════════════════════════════════════════════════════
		// Si el target es un fantasma con event_type='boss', permitimos
		// la misión 23 aunque GetFleetMissions() no la devuelva.
		// ═══════════════════════════════════════════════════════════
		$isBossGhost = false;

		if ($isPveGhost) {
			$ghostUserId = (int) $targetPlanetData['id_owner'];

			if (!class_exists('PVEGhostHelper')) {
				$ghostHelperPath = ROOT_PATH . 'includes/classes/PVEGhostHelper.class.php';
				if (file_exists($ghostHelperPath)) {
					require_once $ghostHelperPath;
				}
			}

			if (class_exists('PVEGhostHelper')) {
				$ghostRow = PVEGhostHelper::getGhostByUserId($ghostUserId);
				if (!empty($ghostRow) && isset($ghostRow['event_type'])
					&& $ghostRow['event_type'] === 'boss') {
					$isBossGhost = true;
				}
			}
		}
		// ═══════════════════════════════════════════════════════════
		// FIN DETECCIÓN BOSS GHOST
		// ═══════════════════════════════════════════════════════════

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v2.3 — Detección de ASTEROIDE (misión 32)
		// ═══════════════════════════════════════════════════════════
		// Si la misión es 32, verificamos que exista un asteroide activo
		// en las coordenadas destino. Si existe, marcamos $isAsteroidTarget
		// para permitir la misión aunque GetFleetMissions() no la incluya.
		// ═══════════════════════════════════════════════════════════
		$isAsteroidTarget = false;

		if ($targetMission == 32) {
			if (!class_exists('AsteroidHelper')) {
				$astFile = ROOT_PATH . 'includes/classes/AsteroidHelper.class.php';
				if (file_exists($astFile)) {
					require_once $astFile;
				}
			}

			if (class_exists('AsteroidHelper')) {
				$asteroid = AsteroidHelper::getAsteroidAt($targetGalaxy, $targetSystem, $targetPlanet);
				if (!empty($asteroid)) {
					$isAsteroidTarget = true;
				}
			}

			if (!$isAsteroidTarget) {
				$this->printMessage($LNG['fl_no_target'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleet1'
				)));
			}
		}
		// ═══════════════════════════════════════════════════════════
		// FIN DETECCIÓN ASTEROIDE
		// ═══════════════════════════════════════════════════════════

		if ($targetMission == 7)
		{
			if (!empty($targetPlanetData)) {
				$this->printMessage($LNG['fl_target_exists'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleet1'
				)));
			}
			
			if ($targetType != 1) {
				$this->printMessage($LNG['fl_only_planets_colonizable'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleet1'
				)));
			}
		}
		
		if ($targetMission == 7 || $targetMission == 15)
		{
			$targetPlanetData	= array('id' => 0, 'id_owner' => 0, 'planettype' => 1);
		}
		elseif ($targetMission == 32)
		{
			// ASTROIO v2.3: asteroide — no requiere planeta.
			// Inicializamos un array con las claves que usa el flujo nativo
			// para evitar "array offset on false".
			$targetPlanetData	= array(
				'id'            => 0,
				'id_owner'      => 0,
				'planettype'    => 1,
				'destruyed'     => 0,
				'ally_deposit'  => 0,
				'der_metal'     => 0,
				'der_crystal'   => 0,
			);
		}
		else
		{
			if (!empty($targetPlanetData["destruyed"])) {
				$this->printMessage($LNG['fl_no_target'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleet1'
				)));
			}
				
			if (empty($targetPlanetData)) {
				$this->printMessage($LNG['fl_no_target'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleet1'
				)));
			}
		}
		
		foreach ($fleetArray as $Ship => $Count)
		{
			if ($Count > $PLANET[$resource[$Ship]]) {
				$this->printMessage($LNG['fl_not_all_ship_avalible'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				)));
			}
		}
		
		if ($targetMission == 11)
		{
			$activeExpedition	= FleetFunctions::GetCurrentFleets($USER['id'], 11, true);
			$maxExpedition		= FleetFunctions::getDMMissionLimit($USER);

			if ($activeExpedition >= $maxExpedition) {
				$this->printMessage($LNG['fl_no_expedition_slot'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				)));
			}
		}
		elseif ($targetMission == 15)
		{		
			$activeExpedition	= FleetFunctions::GetCurrentFleets($USER['id'], 15, true);
			$maxExpedition		= FleetFunctions::getExpeditionLimit($USER);
			
			if ($activeExpedition >= $maxExpedition) {
				$this->printMessage($LNG['fl_no_expedition_slot'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				)));
			}
		}

		$usedPlanet	= isset($targetPlanetData['id_owner']);
		$myPlanet	= $usedPlanet && $targetPlanetData['id_owner'] == $USER['id'];
		$targetPlayerData	= array();

		if($targetMission == 7 || $targetMission == 15 || $targetMission == 32) {
			// ASTROIO v2.3: misión 32 (asteroide) tampoco requiere targetPlayerData
			$targetPlayerData	= array(
				'id'				=> 0,
				'onlinetime'		=> TIMESTAMP,
				'ally_id'			=> 0,
				'urlaubs_modus'		=> 0,
				'authattack'		=> 0,
				'total_points'		=> 0,
			);
		} elseif($myPlanet) {
			$targetPlayerData	= $USER;
		} elseif(!empty($targetPlanetData['id_owner'])) {
            $sql = "SELECT user.id, user.onlinetime, user.ally_id, user.urlaubs_modus, user.banaday, user.authattack,
                stat.total_points
                FROM %%USERS%% as user
                LEFT JOIN %%STATPOINTS%% as stat ON stat.id_owner = user.id AND stat.stat_type = '1'
                WHERE user.id = :ownerID;";

			$targetPlayerData = $db->selectSingle($sql, array(
                ':ownerID'  => $targetPlanetData['id_owner']
            ));
		}

		if(empty($targetPlayerData))
		{
			$this->printMessage($LNG['fl_empty_target'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleet1'
			)));
		}

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v2.4 — FIX ALIANZA
		// ═══════════════════════════════════════════════════════════
		// Bloqueo: no se puede atacar a miembros de tu propia alianza.
		//
		// Aplica a misiones de ataque/agresión:
		//   - 1 = ATAQUE
		//   - 2 = ACS (ataque grupal)
		//   - 9 = DESTRUIR LUNA
		//
		// NO aplica a:
		//   - 23 (Boss Tournament -> target es fantasma)
		//   - 32 (Asteroide -> no es jugador)
		//   - Cualquier target PvE ghost (id_owner >= 900M)
		//   - Tu propio planeta
		//   - Misiones pacíficas (3, 4, 5, 6, 7, 8, 10, 11, 15, etc.)
		// ═══════════════════════════════════════════════════════════
		$isAggressiveMission = in_array($targetMission, array(1, 2, 9), true);

		if (
			$isAggressiveMission
			&& !$isPveGhost
			&& !$isAsteroidTarget
			&& !$myPlanet
			&& !empty($USER['ally_id'])
			&& (int) $USER['ally_id'] > 0
			&& !empty($targetPlayerData['ally_id'])
			&& (int) $targetPlayerData['ally_id'] === (int) $USER['ally_id']
			&& (int) $targetPlayerData['id'] !== (int) $USER['id']
		) {
			$this->printMessage(
				isset($LNG['fl_own_ally']) ? $LNG['fl_own_ally'] : 'No puedes atacar a miembros de tu propia alianza.',
				array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				))
			);
		}
		// ═══════════════════════════════════════════════════════════
		// FIN FIX ALIANZA
		// ═══════════════════════════════════════════════════════════
		
		$MisInfo		     	= array();		
		$MisInfo['galaxy']     	= $targetGalaxy;		
		$MisInfo['system'] 	  	= $targetSystem;	
		$MisInfo['planet'] 	  	= $targetPlanet;		
		$MisInfo['planettype'] 	= $targetType;	
		$MisInfo['IsAKS']		= $fleetGroup;
		$MisInfo['Ship'] 		= $fleetArray;		
		
		$availableMissions		= FleetFunctions::GetFleetMissions($USER, $MisInfo, $targetPlanetData);
		
		// ═══════════════════════════════════════════════════════════
		// ASTROIO v2.3 — Permitir misión 23 (boss) y 32 (asteroide)
		// ═══════════════════════════════════════════════════════════
		// GetFleetMissions() es código nativo. La misión 23 la permitimos
		// si es boss ghost. La misión 32 la permitimos si $isAsteroidTarget.
		// ═══════════════════════════════════════════════════════════
		$missionIsAllowed = in_array($targetMission, $availableMissions['MissionSelector']);

		if (!$missionIsAllowed
		    && !($isBossGhost && $targetMission == 23)
		    && !($isAsteroidTarget && $targetMission == 32)
		) {
			$this->printMessage($LNG['fl_invalid_mission'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleet2'
			)));
		}
		// ═══════════════════════════════════════════════════════════
		
		if ($targetMission != 8 && IsVacationMode($targetPlayerData)) {
			$this->printMessage($LNG['fl_target_exists'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleet1'
			)));
		}
		
		// ASTROIO v2.2: incluir misión 23 en el check de bash (aunque
		// $isPveGhost la saltará de todos modos, es más explícito).
		if($targetMission == 1 || $targetMission == 2 || $targetMission == 9 || $targetMission == 23) {
			// ASTROIO: skip bash para PvE ghosts
			if (!$isPveGhost && FleetFunctions::CheckBash($targetPlanetData['id']))
			{
				$this->printMessage($LNG['fl_bash_protection'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				)));
			}
		}
		
		// ASTROIO v2.2: incluir misión 23 en el check de noob/adm.
		if($targetMission == 1 || $targetMission == 2 || $targetMission == 5 || $targetMission == 6 || $targetMission == 9 || $targetMission == 23)
		{
			if(Config::get()->adm_attack == 1 && $targetPlayerData['authattack'] > $USER['authlevel'])
			{
				$this->printMessage($LNG['fl_admin_attack'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				)));
			}

			// ASTROIO: skip noob protection para PvE ghosts (incluye boss)
			if (!$isPveGhost) {
				$sql	= 'SELECT total_points
				FROM %%STATPOINTS%%
				WHERE id_owner = :userId AND stat_type = :statType';

				$USER	+= Database::get()->selectSingle($sql, array(
					':userId'	=> $USER['id'],
					':statType'	=> 1
				));
			
				$IsNoobProtec	= CheckNoobProtec($USER, $targetPlayerData, $targetPlayerData);
				
				if ($IsNoobProtec['NoobPlayer'])
				{
					$this->printMessage($LNG['fl_player_is_noob'], array(array(
						'label'	=> $LNG['sys_back'],
						'url'	=> 'game.php?page=fleetTable'
					)));
				}
				
				if ($IsNoobProtec['StrongPlayer']) {
					$this->printMessage($LNG['fl_player_is_strong'], array(array(
						'label'	=> $LNG['sys_back'],
						'url'	=> 'game.php?page=fleetTable'
					)));
				}
			}
		}

		if ($targetMission == 5)
		{	
			if($targetPlanetData['ally_deposit'] == 0) {
				$this->printMessage($LNG['fl_not_ally_deposit'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				)));	
			}

			if($targetPlayerData['ally_id'] != $USER['ally_id'] || $targetPlayerData['ally_id'] == 0) {
				$sql = "SELECT COUNT(*) as state FROM %%BUDDY%%
				WHERE id NOT IN (SELECT id FROM %%BUDDY_REQUEST%% WHERE %%BUDDY_REQUEST%%.id = %%BUDDY%%.id) AND
				(owner = :ownerID AND sender = :userID) OR (owner = :userID AND sender = :ownerID);";
                $buddy = $db->selectSingle($sql, array(
                    ':ownerID'  => $targetPlayerData['id'],
                    ':userID'   => $USER['id']
                ), 'state');
				
               if($buddy == 0) {
					$this->printMessage($LNG['fl_no_same_alliance'], array(array(
						'label'	=> $LNG['sys_back'],
						'url'	=> 'game.php?page=fleetTable'
					)));
				}
			}
		}

		$fleetMaxSpeed 	= FleetFunctions::GetFleetMaxSpeed($fleetArray, $USER);
		$SpeedFactor    = FleetFunctions::GetGameSpeedFactor();
		$duration      	= FleetFunctions::GetMissionDuration($fleetSpeed, $fleetMaxSpeed, $distance, $SpeedFactor, $USER);
		$consumption   	= FleetFunctions::GetFleetConsumption($fleetArray, $duration, $distance, $USER, $SpeedFactor);
	
		if ($PLANET[$resource[903]] < $consumption) {
			$this->printMessage($LNG['fl_not_enough_deuterium'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleetTable'
			)));
		}
		
		$StayDuration    = 0;
		
		if($targetMission == 5 || $targetMission == 11 || $targetMission == 15)
		{
			if(!isset($availableMissions['StayBlock'][$stayTime]))
			{
				$this->printMessage($LNG['fl_hold_time_not_exists'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=fleetTable'
				)));
			}
			
			$StayDuration    = round($availableMissions['StayBlock'][$stayTime] * 3600, 0);
		}
		
		$fleetStorage		-= $consumption;
		
		$fleetResource	= array(
			901	=> min($TransportMetal, floor($PLANET[$resource[901]])),
			902	=> min($TransportCrystal, floor($PLANET[$resource[902]])),
			903	=> min($TransportDeuterium, floor($PLANET[$resource[903]] - $consumption)),
		);
		
		$StorageNeeded		= array_sum($fleetResource);
		
		if ($StorageNeeded > $fleetStorage)
		{
			$this->printMessage($LNG['fl_not_enough_space'], array(array(
				'label'	=> $LNG['sys_back'],
				'url'	=> 'game.php?page=fleetTable'
			)));
		}
		
		$PLANET[$resource[901]]	-= $fleetResource[901];
		$PLANET[$resource[902]]	-= $fleetResource[902];
		$PLANET[$resource[903]]	-= $fleetResource[903] + $consumption;

		$fleetStartTime		= $duration + TIMESTAMP;
		$timeDifference		= round(max(0, $fleetStartTime - $ACSTime));
		
		if($fleetGroup != 0)
		{
			if($timeDifference != 0)
			{
				FleetFunctions::setACSTime($timeDifference, $fleetGroup);
			}
			else
			{
				$fleetStartTime		= $ACSTime;
			}
		}
		
		$fleetStayTime		= $fleetStartTime + $StayDuration;
		$fleetEndTime		= $fleetStayTime + $duration;
		
		FleetFunctions::sendFleet($fleetArray, $targetMission, $USER['id'], $PLANET['id'], $PLANET['galaxy'],
			$PLANET['system'], $PLANET['planet'], $PLANET['planet_type'], $targetPlanetData['id_owner'],
			$targetPlanetData['id'], $targetGalaxy, $targetSystem, $targetPlanet, $targetType, $fleetResource,
			$fleetStartTime, $fleetStayTime, $fleetEndTime, $fleetGroup);

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v2.1 — Limpiar target PvE tras enviar la flota
		//
		// Una vez que la flota se ha creado correctamente, ya no
		// necesitamos el target guardado en sesión. Lo limpiamos
		// para que:
		//   1) No contamine futuras acciones (PvP normal, ACS, etc.)
		//   2) No sature la sesión del jugador
		//   3) Fuerce un nuevo attackPrepare() para el próximo ataque
		// ═══════════════════════════════════════════════════════════
		unset($_SESSION['pve_attack_target']);
		unset($_SESSION['pve_acs_id']);
		unset($_SESSION['pve_acs_empire_id']);
		unset($_SESSION['pve_acs_visibility']);
		// ═══════════════════════════════════════════════════════════
		
		foreach ($fleetArray as $Ship => $Count)
		{
			$fleetList[$LNG['tech'][$Ship]]	= $Count;
		}

		$this->tplObj->gotoside('game.php?page=fleetTable');
		$this->assign(array(
			'targetMission'		=> $targetMission,
			'distance'			=> $distance,
			'consumption'		=> $consumption,
			'from'				=> $PLANET['galaxy'] .":". $PLANET['system']. ":". $PLANET['planet'],
			'destination'		=> $targetGalaxy .":". $targetSystem .":". $targetPlanet,
			'fleetStartTime'	=> _date($LNG['php_tdformat'], $fleetStartTime, $USER['timezone']),
			'fleetEndTime'		=> _date($LNG['php_tdformat'], $fleetEndTime, $USER['timezone']),
			'MaxFleetSpeed'		=> $fleetMaxSpeed,
			'FleetList'			=> $fleetArray,
		));
		
		$this->display('page.fleetStep3.default.tpl');
	}
}