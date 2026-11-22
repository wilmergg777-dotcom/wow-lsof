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
 * AstroIO v1.1 (SISTEMA DE CLIMA):
 *   - Se integra ClimaEngine para aplicar los factores en la simulación.
 *   - Se añade selector de clima en la UI.
 *   - Se guarda clima_id en el reporte.
 */

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

class ShowBattleSimulatorPage extends AbstractGamePage
{
	public static $requireModule = MODULE_SIMULATOR;

	function __construct() 
	{
		parent::__construct();
	}

	function send()
	{
		global $reslist, $pricelist, $LNG;
		
		if(!isset($_REQUEST['battleinput'])) {
			$this->sendJSON(0);
		}
		
		$BattleArray	= $_REQUEST['battleinput'];
		$elements	= array(0, 0);
		
		// ============================================
		// ASTROIO v1.1 — Obtener clima seleccionado
		// ============================================
		$climaId = HTTP::_GP('clima_id', 0);
		$factorAtaque = 1.0;
		$factorDefensa = 1.0;
		$factorBajas = 1.0;
		$factorBotin = 1.0;

		if ($climaId > 0 && class_exists('ClimaEngine')) {
			$climaInfo = ClimaEngine::getFactoresPorClimaId($climaId);
			if ($climaInfo) {
				$factorAtaque = $climaInfo['factor_ataque'];
				$factorDefensa = $climaInfo['factor_defensa'];
				$factorBajas = $climaInfo['factor_bajas'];
				$factorBotin = $climaInfo['factor_botin'];
			}
		}
		// ============================================

		foreach($BattleArray as $BattleSlotID => $BattleSlot)
		{
			if(isset($BattleSlot[0]) && (array_sum($BattleSlot[0]) > 0 || $BattleSlotID == 0))
			{
				$attacker	= array();
				$attacker['fleetDetail'] 		= array(
					'fleet_start_galaxy' => 1,
					'fleet_start_system' => 33,
					'fleet_start_planet' => 7, 
					'fleet_start_type' => 1, 
					'fleet_end_galaxy' => 1, 
					'fleet_end_system' => 33, 
					'fleet_end_planet' => 7, 
					'fleet_end_type' => 1, 
					'fleet_resource_metal' => 0,
					'fleet_resource_crystal' => 0,
					'fleet_resource_deuterium' => 0
				);
				
				$attacker['player']				= array(
					'id' => (1000 + $BattleSlotID + 1),
					'username'	=> $LNG['bs_atter'].' Nr.'.($BattleSlotID + 1),
					'military_tech' => $BattleSlot[0][109],
					'defence_tech' => $BattleSlot[0][110],
					'shield_tech' => $BattleSlot[0][111],
					'dm_defensive' => 0,
					'dm_attack' => 0
				); 
				
				$attacker['player']['factor']	= getFactors($attacker['player'], 'attack');
				
				// ASTROIO v1.1 — Aplicar clima
				$attacker['player']['factor']['Attack'] *= $factorAtaque;
				$attacker['player']['factor']['Defensive'] *= $factorDefensa;

				foreach($BattleSlot[0] as $ID => $Count)
				{
					if(!in_array($ID, $reslist['fleet']) || $BattleSlot[0][$ID] <= 0)
					{
						unset($BattleSlot[0][$ID]);
					}
				}
				
				$attacker['unit'] 	= $BattleSlot[0];
				
				$attackers[]	= $attacker;
			}
				
			if(isset($BattleSlot[1]) && (array_sum($BattleSlot[1]) > 0 || $BattleSlotID == 0))
			{
				$defender	= array();
				$defender['fleetDetail'] 		= array(
					'fleet_start_galaxy' => 1,
					'fleet_start_system' => 33,
					'fleet_start_planet' => 7, 
					'fleet_start_type' => 1, 
					'fleet_end_galaxy' => 1, 
					'fleet_end_system' => 33, 
					'fleet_end_planet' => 7, 
					'fleet_end_type' => 1, 
					'fleet_resource_metal' => 0,
					'fleet_resource_crystal' => 0,
					'fleet_resource_deuterium' => 0
				);
				
				$defender['player']				= array(
					'id' => (2000 + $BattleSlotID + 1),
					'username'	=> $LNG['bs_deffer'].' Nr.'.($BattleSlotID + 1),
					'military_tech' => $BattleSlot[1][109],
					'defence_tech' => $BattleSlot[1][110],
					'shield_tech' => $BattleSlot[1][111],
					'dm_attack' => 0,
					'dm_defensive' => 0,
				); 
				
				$defender['player']['factor']	= getFactors($defender['player'], 'attack');
				
				// ASTROIO v1.1 — Aplicar clima
				$defender['player']['factor']['Attack'] *= $factorAtaque;
				$defender['player']['factor']['Defensive'] *= $factorDefensa;

				foreach($BattleSlot[1] as $ID => $Count)
				{
					if((!in_array($ID, $reslist['fleet']) && !in_array($ID, $reslist['defense'])) || $BattleSlot[1][$ID] <= 0)
					{
						unset($BattleSlot[1][$ID]);
					}
				}
				
				$defender['unit'] 	= $BattleSlot[1];
				$defenders[]	= $defender;
			}
		}
		
		$LNG->includeData(array('FLEET'));
		
		require_once 'includes/classes/missions/functions/calculateAttack.php';
		require_once 'includes/classes/missions/functions/calculateSteal.php';
		require_once 'includes/classes/missions/functions/GenerateReport.php';
		
		$combatResult	= calculateAttack($attackers, $defenders, Config::get()->Fleet_Cdr, Config::get()->Defs_Cdr);
		
		// ============================================
		// ASTROIO v1.1 — Aplicar factor de Bajas
		// ============================================
		if ($factorBajas != 1.00) {
			foreach ($attackers as &$attacker) {
				if (empty($attacker['unit'])) continue;
				foreach ($attacker['unit'] as $elementID => &$amount) {
					if ($amount > 0) {
						$amount = (int)floor($amount / $factorBajas);
					}
				}
			}
			unset($attacker);

			foreach ($defenders as &$defender) {
				if (empty($defender['unit'])) continue;
				foreach ($defender['unit'] as $elementID => &$amount) {
					if ($amount > 0) {
						$amount = (int)floor($amount / $factorBajas);
					}
				}
			}
			unset($defender);
		}
		// ============================================

		if($combatResult['won'] == "a")
		{
			$stealResource = calculateSteal($attackers, array(
			'metal' => $BattleArray[0][1][901],
			'crystal' => $BattleArray[0][1][902],
			'deuterium' => $BattleArray[0][1][903]
			), true);
			
			// ASTROIO v1.1 — Aplicar factor de Botín
			if ($factorBotin != 1.00) {
				$stealResource[901] = (int)floor($stealResource[901] * $factorBotin);
				$stealResource[902] = (int)floor($stealResource[902] * $factorBotin);
				$stealResource[903] = (int)floor($stealResource[903] * $factorBotin);
			}
		}
		else
		{
			$stealResource = array(
				901 => 0,
				902 => 0,
				903 => 0
			);
		}
		
		$debris	= array();
		
		foreach(array(901, 902) as $elementID)
		{
			$debris[$elementID]			= $combatResult['debris']['attacker'][$elementID] + $combatResult['debris']['defender'][$elementID];
		}
		
		$debrisTotal		= array_sum($debris);
		
		$moonFactor			= Config::get()->moon_factor;
		$maxMoonChance		= Config::get()->moon_chance;
		
		$chanceCreateMoon	= round($debrisTotal / 100000 * $moonFactor);
		$chanceCreateMoon	= min($chanceCreateMoon, $maxMoonChance);
		
		$sumSteal	= array_sum($stealResource);
		
		$stealResourceInformation	= sprintf($LNG['bs_derbis_raport'], 
			pretty_number(ceil($debrisTotal / $pricelist[219]['capacity'])), $LNG['tech'][219],
			pretty_number(ceil($debrisTotal / $pricelist[209]['capacity'])), $LNG['tech'][209]
		);
		
		$stealResourceInformation	.= '<br>';
		
		$stealResourceInformation	.= sprintf($LNG['bs_steal_raport'], 
			pretty_number(ceil($sumSteal / $pricelist[202]['capacity'])), $LNG['tech'][202], 
			pretty_number(ceil($sumSteal / $pricelist[203]['capacity'])), $LNG['tech'][203], 
			pretty_number(ceil($sumSteal / $pricelist[217]['capacity'])), $LNG['tech'][217]
		);

		$reportInfo	= array(
			'thisFleet'				=> array(
				'fleet_start_galaxy'	=> 1,
				'fleet_start_system'	=> 33,
				'fleet_start_planet'	=> 7,
				'fleet_start_type'		=> 1,
				'fleet_end_galaxy'		=> 1,
				'fleet_end_system'		=> 33,
				'fleet_end_planet'		=> 7,
				'fleet_end_type'		=> 1,
				'fleet_start_time'		=> TIMESTAMP,
			),
			'debris'				=> $debris,
			'stealResource'			=> $stealResource,
			'moonChance'			=> $chanceCreateMoon,
			'moonDestroy'			=> false,
			'moonName'				=> NULL,
			'moonDestroyChance'		=> NULL,
			'moonDestroySuccess'	=> NULL,
			'fleetDestroyChance'	=> NULL,
			'fleetDestroySuccess'	=> NULL,
			'additionalInfo'		=> $stealResourceInformation,
		);
		
		$reportData	= GenerateReport($combatResult, $reportInfo);
		$reportID	= md5(uniqid('', true).TIMESTAMP);

        $db = Database::get();

        // ASTROIO v1.1 — Incluir clima_id en el reporte
        $sql = "INSERT INTO %%RW%% SET rid = :reportID, raport = :reportData, time = :time, clima_id = :climaId;";
        $db->insert($sql,array(
            ':reportID'     => $reportID,
            ':reportData'   => serialize($reportData),
            ':time'         => TIMESTAMP,
            ':climaId'      => ($climaId > 0 ? $climaId : null)
        ));

        $this->sendJSON($reportID);
	}
	
	function show()
	{
		global $USER, $PLANET, $reslist, $resource;

		$Slots			= HTTP::_GP('slots', 1);


		$BattleArray[0][0][109]	= $USER[$resource[109]];
		$BattleArray[0][0][110]	= $USER[$resource[110]];
		$BattleArray[0][0][111]	= $USER[$resource[111]];
		
		if(empty($_REQUEST['battleinput']))
		{
			foreach($reslist['fleet'] as $ID)
			{
				if(FleetFunctions::GetFleetMaxSpeed($ID, $USER) > 0)
				{
					// Add just flyable elements
					$BattleArray[0][0][$ID]	= $PLANET[$resource[$ID]];
				}
			}
		}
		else
		{
			$BattleArray	= HTTP::_GP('battleinput', array());
		}
		
		if(isset($_REQUEST['im']))
		{
			foreach($_REQUEST['im'] as $ID => $Count)
			{
				$BattleArray[0][1][$ID]	= floatToString($Count);
			}
		}
		
		// ============================================
		// ASTROIO v1.1 — Cargar lista de climas y selección actual
		// ============================================
		$climasList = array();
		if (class_exists('ClimaEngine')) {
			$climasList = ClimaEngine::getCatalogoCompleto();
		}
		$climaId = HTTP::_GP('clima_id', 0);
		// ============================================

		$this->tplObj->loadscript('battlesim.js');
		
		$this->assign(array(
			'Slots'			=> $Slots,
			'battleinput'	=> $BattleArray,
			'fleetList'		=> $reslist['fleet'],
			'defensiveList'	=> $reslist['defense'],
			'climasList'	=> $climasList,
			'climaId'		=> $climaId,
		));
		
		$this->display('page.battleSimulator.default.tpl');   
	}
}
?>