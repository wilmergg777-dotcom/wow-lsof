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
 * AstroIO v1.0 (Bonos de Espionaje)
 * AstroIO v1.1 (FALLBACK DIRECTO Pot. Espía)
 * AstroIO v1.2 (MISTICOS)
 * AstroIO v1.3 (SISTEMA DE CLIMA):
 *   - Se integra ClimaEngine para mostrar el clima actual y la predicción en el reporte.
 */

// ============================================
// ASTROIO - Cargar MisticHelper explicitamente
// ============================================
if (!class_exists('MisticHelper')) {
    $__misticFile = ROOT_PATH . 'includes/classes/MisticHelper.class.php';
    if (file_exists($__misticFile)) {
        require_once $__misticFile;
    }
}
// ============================================

// ============================================
// ASTROIO - Cargar ClimaEngine explicitamente
// ============================================
if (!class_exists('ClimaEngine')) {
    $__climaFile = ROOT_PATH . 'includes/classes/ClimaEngine.class.php';
    if (file_exists($__climaFile)) {
        require_once $__climaFile;
    }
}
// ============================================

class MissionCaseSpy extends MissionFunctions implements Mission
{
		
	function __construct($Fleet)
	{
		$this->_fleet	= $Fleet;
	}

	/**
	 * 🆕 AstroIO v1.1 - Fallback directo si BoosterHelper no existe
	 * ------------------------------------------------------------
	 * Lee el valor total de un potenciador activo del jugador,
	 * filtrando por su `booster_type`, DIRECTAMENTE de la BD.
	 *
	 * @param int    $userId  ID del jugador
	 * @param string $type    Tipo de booster ('spy_power')
	 * @return int            Valor total del bonus (sin dividir por 100)
	 */
	private function getDirectBoosterBonus($userId, $type)
	{
		try {
			$db = Database::get();
			$prefix = 'uni1_';
			if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
			elseif (defined('PREFIX')) $prefix = PREFIX;

			$row = $db->selectSingle(
				"SELECT SUM(b.booster_value) AS total_bonus
				 FROM `".$prefix."users_boosters` ub
				 INNER JOIN `".$prefix."boosters` b ON b.booster_id = ub.booster_id
				 WHERE ub.user_id = :uid 
				   AND ub.expires_at > :now
				   AND b.booster_type = :type;",
				array(
					':uid'  => (int) $userId,
					':now'  => TIMESTAMP,
					':type' => $type,
				)
			);
			return !empty($row['total_bonus']) ? (int) $row['total_bonus'] : 0;
		} catch (Exception $e) {
			return 0;
		}
	}
	
	function TargetEvent()
	{
		global $pricelist, $reslist, $resource;

		$db				= Database::get();

		$sql			= 'SELECT * FROM %%USERS%% WHERE id = :userId;';
		$senderUser		= $db->selectSingle($sql, array(
			':userId'	=> $this->_fleet['fleet_owner']
		));

		$targetUser		= $db->selectSingle($sql, array(
			':userId'	=> $this->_fleet['fleet_target_owner']
		));

		$sql			= 'SELECT * FROM %%PLANETS%% WHERE id = :planetId;';
		$targetPlanet	= $db->selectSingle($sql, array(
			':planetId'	=> $this->_fleet['fleet_end_id']
		));

		$sql				= 'SELECT name FROM %%PLANETS%% WHERE id = :planetId;';
		$senderPlanetName	= $db->selectSingle($sql, array(
			':planetId'	=> $this->_fleet['fleet_start_id']
		), 'name');

		$LNG			= $this->getLanguage($senderUser['lang']);

		$senderUser['factor']	= getFactors($senderUser, 'basic', $this->_fleet['fleet_start_time']);
		$targetUser['factor']	= getFactors($targetUser, 'basic', $this->_fleet['fleet_start_time']);

		$planetUpdater 						= new ResourceUpdate();
		list($targetUser, $targetPlanet)	= $planetUpdater->CalcResource($targetUser, $targetPlanet, true, $this->_fleet['fleet_start_time']);

		$sql	= 'SELECT * FROM %%FLEETS%% WHERE fleet_end_id = :planetId AND fleet_mission = 5 AND fleet_end_stay > :time;';

		$targetStayFleets	= $db->select($sql, array(
			':planetId'	=> $this->_fleet['fleet_end_id'],
			':time'		=> $this->_fleet['fleet_start_time'],
		));

		foreach($targetStayFleets as $fleetRow)
		{
			$fleetData	= FleetFunctions::unserialize($fleetRow['fleet_array']);
			foreach($fleetData as $shipId => $shipAmount)
			{
				$targetPlanet[$resource[$shipId]]	+= $shipAmount;
			}
		}
		
		// ============================================
		// ASTROIO v1.1 - Cargar bonos de Poder de Espionaje
		// (Potenciadores + Razas/Facciones) con FALLBACK DIRECTO
		// ============================================
		$boosterSpyPower	= 0;
		$raceSpyPower		= 0;
		
		// Pot. Espía
		if (class_exists('BoosterHelper')) {
			$boosterSpyPower	= BoosterHelper::getBonus($this->_fleet['fleet_owner'], 'spy_power') / 100;
		} else {
			// Fallback directo si BoosterHelper no existe
			$boosterSpyPower	= $this->getDirectBoosterBonus($this->_fleet['fleet_owner'], 'spy_power') / 100;
		}
		
		// Razas y Facciones
		if (class_exists('RaceFactionHelper')) {
			$raceSpyPower		= RaceFactionHelper::getBonus($this->_fleet['fleet_owner'], 'bonus_spy') / 100;
		}

		// ============================================
		// ASTROIO v1.2 - Bonos Místicos de Espionaje (WATER)
		// ============================================
		$misticSpyPower		= 0;
		
		if (class_exists('MisticHelper')) {
			$misticBonuses	= MisticHelper::getBonuses($this->_fleet['fleet_owner']);
			$misticSpyPower	= isset($misticBonuses['espionaje']) ? ($misticBonuses['espionaje'] / 100) : 0;
		}
		// ============================================
		
		// Suma total
		$totalSpyPower		= $boosterSpyPower + $raceSpyPower + $misticSpyPower;
		// ============================================
		
		// ============================================
		// ASTROIO v1.1 - Aplicar bono de Poder de Espionaje
		// (Pot. Espía + Razas/Facciones + Místicos) con fallback
		// ============================================
		$fleetAmount	= $this->_fleet['fleet_amount'] * (1 + $senderUser['factor']['SpyPower'] + $totalSpyPower);
		// ============================================

		$senderSpyTech	= max($senderUser['spy_tech'], 1);
		$targetSpyTech	= max($targetUser['spy_tech'], 1);

		$techDifference	= abs($senderSpyTech - $targetSpyTech);
		$MinAmount		= ($senderSpyTech > $targetSpyTech ? -1 : 1) * pow($techDifference * SPY_DIFFENCE_FACTOR, 2);
		$SpyFleet		= $fleetAmount >= $MinAmount;
		$SpyDef			= $fleetAmount >= $MinAmount + 1 * SPY_VIEW_FACTOR;
		$SpyBuild		= $fleetAmount >= $MinAmount + 3 * SPY_VIEW_FACTOR;
		$SpyTechno		= $fleetAmount >= $MinAmount + 5 * SPY_VIEW_FACTOR;
			

		$classIDs[900]	= array_merge($reslist['resstype'][1], $reslist['resstype'][2]);
				
		if($SpyFleet) 
		{
			$classIDs[200]	= $reslist['fleet'];
		}
		
		if($SpyDef) 
		{
			$classIDs[400]	= array_merge($reslist['defense'], $reslist['missile']);
		}
		
		if($SpyBuild) 
		{
			$classIDs[0]	= $reslist['build'];
		}
		
		if($SpyTechno) 
		{
			$classIDs[100]	= $reslist['tech'];
		}
		
		$targetChance 	= mt_rand(0, min(($fleetAmount/4) * floor($targetSpyTech / $senderSpyTech), 100));
		$spyChance  	= mt_rand(0, 100);
		$spyData		= array();

		foreach($classIDs as $classID => $elementIDs)
		{
			foreach($elementIDs as $elementID)
			{
				if(isset($targetUser[$resource[$elementID]]))
				{
					$spyData[$classID][$elementID]	= $targetUser[$resource[$elementID]];
				}
				else 
				{
					$spyData[$classID][$elementID]	= $targetPlanet[$resource[$elementID]];
				}
			}
		
			if($senderUser['spyMessagesMode'] == 1)
			{
				$spyData[$classID]	= array_filter($spyData[$classID]);
			}
		}
		
		// I'm use template class here, because, i want to exclude HTML in PHP.
		
		require_once 'includes/classes/class.template.php';
		
		$template	= new template;
		
		$template->caching		= true;
		$template->compile_id	= $senderUser['lang'];
		$template->loadFilter('output', 'trimwhitespace');
		list($tplDir)	= $template->getTemplateDir();
		$template->setTemplateDir($tplDir.'game/');

		// ============================================
		// ASTROIO v1.3 (SISTEMA DE CLIMA) — Obtener clima actual y predicción
		// ============================================
		$climaActual = null;
		$climaPrevisto = null;

		if (class_exists('ClimaEngine')) {
			$climaActual = ClimaEngine::getClimaPlaneta($this->_fleet['fleet_end_id']);
			$climaPrevisto = ClimaEngine::getPrediccionPlaneta($this->_fleet['fleet_end_id']);
		}
		// ============================================

		$template->assign_vars(array(
			'spyData'		=> $spyData,
			'targetPlanet'	=> $targetPlanet,
			'targetChance'	=> $targetChance,
			'spyChance'		=> $spyChance,
			'isBattleSim'	=> ENABLE_SIMULATOR_LINK == true && isModuleAvailable(MODULE_SIMULATOR),
			'title'			=> sprintf($LNG['sys_mess_head'], $targetPlanet['name'], $targetPlanet['galaxy'], $targetPlanet['system'], $targetPlanet['planet'], _date($LNG['php_tdformat'], $this->_fleet['fleet_end_time'], $targetUser['timezone'], $LNG)),
			
			// ASTROIO v1.3 — Variables de Clima para el template
			'climaActual'	=> $climaActual,
			'climaPrevisto'	=> $climaPrevisto,
		));
		
		$template->assign_vars(array(
			'LNG'			=> $LNG
		), false);
				
		$spyReport	= $template->fetch('shared.mission.spyReport.tpl');

		PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_qg'], 0, $LNG['sys_mess_spy_report'],
			$spyReport, $this->_fleet['fleet_start_time'], NULL, 1, $this->_fleet['fleet_universe']);
		
		$LNG			= $this->getLanguage($targetUser['lang']);
		$targetMessage  = $LNG['sys_mess_spy_ennemyfleet'] ." ". $senderPlanetName;

		if($this->_fleet['fleet_start_type'] == 3)
		{
			$targetMessage .= $LNG['sys_mess_spy_report_moon'].' ';
		}

		$text	= '<a href="game.php?page=galaxy&amp;galaxy=%1$s&amp;system=%2$s">[%1$s:%2$s:%3$s]</a> %7$s
		%8$s <a href="game.php?page=galaxy&amp;galaxy=%4$s&amp;system=%5$s">[%4$s:%5$s:%6$s]</a> %9$s';

		$targetMessage .= sprintf($text,
			$this->_fleet['fleet_start_galaxy'],
			$this->_fleet['fleet_start_system'],
			$this->_fleet['fleet_start_planet'],
			$this->_fleet['fleet_end_galaxy'],
			$this->_fleet['fleet_end_system'],
			$this->_fleet['fleet_end_planet'],
			$LNG['sys_mess_spy_seen_at'],
			$targetPlanet['name'],
			$LNG['sys_mess_spy_seen_at2']
		);


		PlayerUtil::sendMessage($this->_fleet['fleet_target_owner'], 0, $LNG['sys_mess_spy_control'], 0,
			$LNG['sys_mess_spy_activity'], $targetMessage, $this->_fleet['fleet_start_time'], NULL, 1, $this->_fleet['fleet_universe']);

		if ($targetChance >= $spyChance)
		{
			$config		= Config::get($this->_fleet['fleet_universe']);
			$whereCol	= $this->_fleet['fleet_end_type'] == 3 ? "id_luna" : "id";

			$sql		= 'UPDATE %%PLANETS%% SET
			der_metal	= der_metal + :metal,
			der_crystal = der_crystal + :metal
			WHERE '.$whereCol.' = :planetId;';

			$db->update($sql, array(
				':metal'	=> $fleetAmount * $pricelist[210]['cost'][901] * $config->Fleet_Cdr / 100,
				':crystal'	=> $fleetAmount * $pricelist[210]['cost'][902] * $config->Fleet_Cdr / 100,
				':planetId'	=> $this->_fleet['fleet_end_id']
			));

			$this->KillFleet();
		}
		else
		{
			$this->setState(FLEET_RETURN);
			$this->SaveFleet();
		}
	}
	
	function EndStayEvent()
	{
		return;
	}
	
	function ReturnEvent()
	{	
		$this->RestoreFleet();
	}
}
?>