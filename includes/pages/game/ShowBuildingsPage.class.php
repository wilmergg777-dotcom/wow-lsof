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
 * ✅ AstroIO v1.0 (Planetario - Droides Constructores):
 *   - Suma los Droides Constructores (droids_builder) al límite base
 *     de colas de edificios (max_elements_build)
 *   - Se aplica en DOS lugares:
 *       1) AddBuildingToQueue()  → validación al encolar
 *       2) show()                → cálculo de $CanBuildElement
 *
 * ✅ AstroIO v1.1 (Potenciador "Pot. Estructuras"):
 *   - Suma el bonus del potenciador activo tipo 'droids_builder'
 *     (Pot. Estructuras) al límite de colas de edificios
 *   - Se aplica en los MISMOS DOS lugares que los droides
 *   - Se lee desde `uni1_users_boosters` + `uni1_boosters`
 *   - Si el potenciador no existe o está inactivo, no afecta nada
 *   - Se ejecuta SIEMPRE (con o sin droides), ya que el potenciador
 *     es temporal e independiente del Planetario
 *
 * 🆕 AstroIO v1.2 (Orden de Minas):
 *   - Fuerza a que las minas principales (Metal, Cristal, Deuterio, 
 *     Planta Solar y Reactor de Fusión) salgan siempre al principio.
 */

class ShowBuildingsPage extends AbstractGamePage
{	
	public static $requireModule = MODULE_BUILDING;

	function __construct() 
	{
		parent::__construct();
	}
	
	/**
	 * 🆕 AstroIO v1.1 - Obtener bonus de un potenciador por tipo
	 * ------------------------------------------------------------
	 * Lee el valor total de un potenciador activo del jugador,
	 * filtrado por su `booster_type`. Devuelve 0 si no tiene ninguno.
	 *
	 * @param int    $userId  ID del jugador
	 * @param string $type    Tipo de booster (ej: 'droids_builder')
	 * @return int            Valor total del bonus (suma de todos los activos del tipo)
	 */
	private function getBoosterBonus($userId, $type)
	{
		$db = Database::get();
		$prefix = 'uni1_';
		if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
		elseif (defined('PREFIX')) $prefix = PREFIX;

		try {
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

	private function CancelBuildingFromQueue()
	{
		global $PLANET, $USER, $resource;
		$CurrentQueue  = unserialize($PLANET['b_building_id']);
		if (empty($CurrentQueue))
		{
			$PLANET['b_building_id']	= '';
			$PLANET['b_building']		= 0;
			return false;
		}
	
		$Element             	= $CurrentQueue[0][0];
        $BuildLevel          	= $CurrentQueue[0][1];
		$BuildMode          	= $CurrentQueue[0][4];
		
		$costResources			= BuildFunctions::getElementPrice($USER, $PLANET, $Element, $BuildMode == 'destroy', $BuildLevel);
		
		if(isset($costResources[901])) { $PLANET[$resource[901]]	+= $costResources[901]; }
		if(isset($costResources[902])) { $PLANET[$resource[902]]	+= $costResources[902]; }
		if(isset($costResources[903])) { $PLANET[$resource[903]]	+= $costResources[903]; }
		if(isset($costResources[921])) { $USER[$resource[921]]		+= $costResources[921]; }
		array_shift($CurrentQueue);
		if (count($CurrentQueue) == 0) {
			$PLANET['b_building']    	= 0;
			$PLANET['b_building_id'] 	= '';
		} else {
			$BuildEndTime	= TIMESTAMP;
			$NewQueueArray	= array();
			foreach($CurrentQueue as $ListIDArray) {
				if($Element == $ListIDArray[0])
					continue;
					
				$BuildEndTime       += BuildFunctions::getBuildingTime($USER, $PLANET, $ListIDArray[0], $costResources, $ListIDArray[4] == 'destroy');
				$ListIDArray[3]		= $BuildEndTime;
				$NewQueueArray[]	= $ListIDArray;					
			}
			
			if(!empty($NewQueueArray)) {
				$PLANET['b_building']    	= TIMESTAMP;
				$PLANET['b_building_id'] 	= serialize($NewQueueArray);
				$this->ecoObj->setData($USER, $PLANET);
				$this->ecoObj->SetNextQueueElementOnTop();
				list($USER, $PLANET)		= $this->ecoObj->getData();
			} else {
				$PLANET['b_building']    	= 0;
				$PLANET['b_building_id'] 	= '';
			}
		}
		return true;
	}

	private function RemoveBuildingFromQueue($QueueID)
	{
		global $USER, $PLANET;
		if ($QueueID <= 1 || empty($PLANET['b_building_id'])) {
            return false;
        }

		$CurrentQueue  = unserialize($PLANET['b_building_id']);
		$ActualCount   = count($CurrentQueue);
		if($ActualCount <= 1) {
			return $this->CancelBuildingFromQueue();
        }

        if ($QueueID - $ActualCount >= 2) {
            // Avoid race conditions
            return;
        }

		$Element		= $CurrentQueue[$QueueID - 2][0];
		$BuildEndTime	= $CurrentQueue[$QueueID - 2][3];
		unset($CurrentQueue[$QueueID - 1]);
		$NewQueueArray	= array();
		foreach($CurrentQueue as $ID => $ListIDArray)
		{				
			if ($ID < $QueueID - 1) {
				$NewQueueArray[]	= $ListIDArray;
			} else {
				if($Element == $ListIDArray[0] || empty($ListIDArray[0]))
					continue;

				$BuildEndTime       += BuildFunctions::getBuildingTime($USER, $PLANET, $ListIDArray[0], NULL, $ListIDArray[4] == 'destroy', $ListIDArray[2]);
				$ListIDArray[3]		= $BuildEndTime;
				$NewQueueArray[]	= $ListIDArray;				
			}
		}

		if(!empty($NewQueueArray))
			$PLANET['b_building_id'] = serialize($NewQueueArray);
		else
			$PLANET['b_building_id'] = "";

        return true;
	}

	private function AddBuildingToQueue($Element, $AddMode = true)
	{
		global $PLANET, $USER, $resource, $reslist, $pricelist;
		
		if(!in_array($Element, $reslist['allow'][$PLANET['planet_type']])
			|| !BuildFunctions::isTechnologieAccessible($USER, $PLANET, $Element) 
			|| ($Element == 31 && $USER["b_tech_planet"] != 0) 
			|| (($Element == 15 || $Element == 21) && !empty($PLANET['b_hangar_id']))
			|| (!$AddMode && $PLANET[$resource[$Element]] == 0)
		)
			return;
		
		$CurrentQueue  		= (!empty($PLANET['b_building_id']))?unserialize($PLANET['b_building_id']):[];

				
		if (!empty($CurrentQueue)) {
			$ActualCount	= count($CurrentQueue);
		} else {
			$CurrentQueue	= array();
			$ActualCount	= 0;
		}
		
		$CurrentMaxFields  	= CalculateMaxPlanetFields($PLANET);

		$config	= Config::get();

		// ═══════════════════════════════════════════════════════════
		// AstroIO - Límite de colas de edificios:
		//   1) Base (max_elements_build)
		//   2) + Droides Constructores (Planetario)
		//   3) + Potenciador "Pot. Estructuras" (v1.1)
		// ═══════════════════════════════════════════════════════════
		$maxBuildQueues = $config->max_elements_build;
		if ($maxBuildQueues != 0) {
			// Planetario: sumar Droides Constructores
			$maxBuildQueues += (int) $PLANET['droids_builder'];

			// 🆕 AstroIO v1.1: sumar Potenciador "Pot. Estructuras"
			$boosterSlots = $this->getBoosterBonus($USER['id'], 'droids_builder');
			if ($boosterSlots > 0) {
				$maxBuildQueues += $boosterSlots;
			}
		}

		if (($maxBuildQueues != 0 && $ActualCount == $maxBuildQueues)
			|| ($AddMode && $PLANET["field_current"] >= ($CurrentMaxFields - $ActualCount)))
		{
			return;
		}
	
		$BuildMode 			= $AddMode ? 'build' : 'destroy';
		$BuildLevel			= $PLANET[$resource[$Element]] + (int) $AddMode;
		
		if($ActualCount == 0)
		{
			if($pricelist[$Element]['max'] < $BuildLevel)
				return;

			$costResources		= BuildFunctions::getElementPrice($USER, $PLANET, $Element, !$AddMode, $BuildLevel);
			
			if(!BuildFunctions::isElementBuyable($USER, $PLANET, $Element, $costResources))
				return;
			
			if(isset($costResources[901])) { $PLANET[$resource[901]]	-= $costResources[901]; }
			if(isset($costResources[902])) { $PLANET[$resource[902]]	-= $costResources[902]; }
			if(isset($costResources[903])) { $PLANET[$resource[903]]	-= $costResources[903]; }
			if(isset($costResources[921])) { $USER[$resource[921]]		-= $costResources[921]; }
			
			$elementTime    			= BuildFunctions::getBuildingTime($USER, $PLANET, $Element, $costResources);
			$BuildEndTime				= TIMESTAMP + $elementTime;
			
			$PLANET['b_building_id']	= serialize(array(array($Element, $BuildLevel, $elementTime, $BuildEndTime, $BuildMode)));
			$PLANET['b_building']		= $BuildEndTime;
			
		} else {
			$addLevel = 0;
			foreach($CurrentQueue as $QueueSubArray)
			{
				if($QueueSubArray[0] != $Element)
					continue;
					
				if($QueueSubArray[4] == 'build')
					$addLevel++;
				else
					$addLevel--;
			}
			
			$BuildLevel					+= $addLevel;
			
			if(!$AddMode && $BuildLevel == 0)
				return;
				
			if($pricelist[$Element]['max'] < $BuildLevel)
				return;
				
			$elementTime    			= BuildFunctions::getBuildingTime($USER, $PLANET, $Element, NULL, !$AddMode, $BuildLevel);
			$BuildEndTime				= $CurrentQueue[$ActualCount - 1][3] + $elementTime;
			$CurrentQueue[]				= array($Element, $BuildLevel, $elementTime, $BuildEndTime, $BuildMode);
			$PLANET['b_building_id']	= serialize($CurrentQueue);		
		}

	}

	private function getQueueData()
	{
		global $LNG, $PLANET, $USER;
		
		$scriptData		= array();
		$quickinfo		= array();
		
		if ($PLANET['b_building'] == 0 || $PLANET['b_building_id'] == "")
			return array('queue' => $scriptData, 'quickinfo' => $quickinfo);
		
		$buildQueue		= unserialize($PLANET['b_building_id']);
		
		foreach($buildQueue as $BuildArray) {
			if ($BuildArray[3] < TIMESTAMP)
				continue;
			
			$quickinfo[$BuildArray[0]]	= $BuildArray[1];
			
			$scriptData[] = array(
				'element'	=> $BuildArray[0], 
				'level' 	=> $BuildArray[1], 
				'time' 		=> $BuildArray[2], 
				'resttime' 	=> ($BuildArray[3] - TIMESTAMP), 
				'destroy' 	=> ($BuildArray[4] == 'destroy'), 
				'endtime' 	=> _date('U', $BuildArray[3], $USER['timezone']),
				'display' 	=> _date($LNG['php_tdformat'], $BuildArray[3], $USER['timezone']),
			);
		}
		
		return array('queue' => $scriptData, 'quickinfo' => $quickinfo);
	}

	public function show()
	{
		global $ProdGrid, $LNG, $resource, $reslist, $PLANET, $USER, $pricelist;
		
		$TheCommand		= HTTP::_GP('cmd', '');

		// wellformed buildURLs
		if(!empty($TheCommand) && $_SERVER['REQUEST_METHOD'] === 'POST' && $USER['urlaubs_modus'] == 0)
		{
			$Element     	= HTTP::_GP('building', 0);
			$ListID      	= HTTP::_GP('listid', 0);
			switch($TheCommand)
			{
				case 'cancel':
					$this->CancelBuildingFromQueue();
				break;
				case 'remove':
					$this->RemoveBuildingFromQueue($ListID);
				break;
				case 'insert':
					$this->AddBuildingToQueue($Element, true);
				break;
				case 'destroy':
					$this->AddBuildingToQueue($Element, false);
				break;
			}
			
			$this->redirectTo('game.php?page=buildings');
		}

		$config				= Config::get();

		$queueData	 		= $this->getQueueData();
		$Queue	 			= $queueData['queue'];
		$QueueCount			= count($Queue);

		// ═══════════════════════════════════════════════════════════
		// AstroIO - Límite de colas de edificios (visual):
		//   1) Base (max_elements_build)
		//   2) + Droides Constructores (Planetario)
		//   3) + Potenciador "Pot. Estructuras" (v1.1)
		// ═══════════════════════════════════════════════════════════
		$maxBuildQueues		= $config->max_elements_build;
		if ($maxBuildQueues != 0) {
			// Planetario: sumar Droides Constructores
			$maxBuildQueues	+= (int) $PLANET['droids_builder'];

			// 🆕 AstroIO v1.1: sumar Potenciador "Pot. Estructuras"
			$boosterSlots = $this->getBoosterBonus($USER['id'], 'droids_builder');
			if ($boosterSlots > 0) {
				$maxBuildQueues += $boosterSlots;
			}
		}

		$CanBuildElement 	= isVacationMode($USER) || $maxBuildQueues == 0 || $QueueCount < $maxBuildQueues;
		$CurrentMaxFields   = CalculateMaxPlanetFields($PLANET);
		
		$RoomIsOk 			= $PLANET['field_current'] < ($CurrentMaxFields - $QueueCount);
				
		$BuildEnergy		= $USER[$resource[113]];
		$BuildLevelFactor   = 10;
		$BuildTemp          = $PLANET['temp_max'];

        $BuildInfoList      = array();

		$Elements			= $reslist['allow'][$PLANET['planet_type']];
		
		// ═══════════════════════════════════════════════════════════
		// 🆕 AstroIO v1.2 - Forzar orden de Minas al principio
		// IDs: 1=Mina Metal, 2=Mina Cristal, 3=Sintetizador Deuterio,
		//      4=Planta Solar, 12=Reactor Fusión
		// ═══════════════════════════════════════════════════════════
		$priorityElements = array(1, 2, 3, 4, 12);
		$firstElements    = array();
		$otherElements    = array();
		
		foreach($Elements as $Element) {
			if (in_array($Element, $priorityElements)) {
				$firstElements[] = $Element;
			} else {
				$otherElements[] = $Element;
			}
		}
		
		// Reordenamos el array final para que las minas salgan primero
		sort($firstElements);
		$Elements = array_merge($firstElements, $otherElements);
		// ═══════════════════════════════════════════════════════════
		
		foreach($Elements as $Element)
		{
			if (!BuildFunctions::isTechnologieAccessible($USER, $PLANET, $Element))
				continue;

			$infoEnergy	= "";
			
			if(isset($queueData['quickinfo'][$Element]))
			{
				$levelToBuild	= $queueData['quickinfo'][$Element];
			}
			else
			{
				$levelToBuild	= $PLANET[$resource[$Element]];
			}
			
			if(in_array($Element, $reslist['prod']))
			{
				$BuildLevel	= $PLANET[$resource[$Element]];
				$Need		= eval(ResourceUpdate::getProd($ProdGrid[$Element]['production'][911]));
									
				$BuildLevel	= $levelToBuild + 1;
				$Prod		= eval(ResourceUpdate::getProd($ProdGrid[$Element]['production'][911]));
					
				$requireEnergy	= $Prod - $Need;
				$requireEnergy	= round($requireEnergy * $config->energySpeed);

				if($requireEnergy < 0) {
					$infoEnergy	= sprintf($LNG['bd_need_engine'], pretty_number(abs($requireEnergy)), $LNG['tech'][911]);
				} else {
					$infoEnergy	= sprintf($LNG['bd_more_engine'], pretty_number(abs($requireEnergy)), $LNG['tech'][911]);
				}
			}
			
			$costResources		= BuildFunctions::getElementPrice($USER, $PLANET, $Element, false, $levelToBuild+1);
			$costOverflow		= BuildFunctions::getRestPrice($USER, $PLANET, $Element, $costResources);
			$elementTime    	= BuildFunctions::getBuildingTime($USER, $PLANET, $Element, $costResources);
			$destroyResources	= BuildFunctions::getElementPrice($USER, $PLANET, $Element, true);
			$destroyTime		= BuildFunctions::getBuildingTime($USER, $PLANET, $Element, $destroyResources);
			$destroyOverflow	= BuildFunctions::getRestPrice($USER, $PLANET, $Element, $destroyResources);
			$buyable			= $QueueCount != 0 || BuildFunctions::isElementBuyable($USER, $PLANET, $Element, $costResources);

			$BuildInfoList[$Element]	= array(
				'level'				=> $PLANET[$resource[$Element]],
				'maxLevel'			=> $pricelist[$Element]['max'],
				'infoEnergy'		=> $infoEnergy,
				'costResources'		=> $costResources,
				'costOverflow'		=> $costOverflow,
				'elementTime'    	=> $elementTime,
				'destroyResources'	=> $destroyResources,
				'destroyTime'		=> $destroyTime,
				'destroyOverflow'	=> $destroyOverflow,
				'buyable'			=> $buyable,
				'levelToBuild'		=> $levelToBuild,
			);
		}

		
		if ($QueueCount != 0) {
			$this->tplObj->loadscript('buildlist.js');
		}
		
		$this->assign(array(
			'BuildInfoList'		=> $BuildInfoList,
			'CanBuildElement'	=> $CanBuildElement,
			'RoomIsOk'			=> $RoomIsOk,
			'Queue'				=> $Queue,
			'isBusy'			=> array('shipyard' => !empty($PLANET['b_hangar_id']), 'research' => $USER['b_tech_planet'] != 0),
			'HaveMissiles'		=> (bool) $PLANET[$resource[503]] + $PLANET[$resource[502]],
		));
			
		$this->display('page.buildings.default.tpl');
	}
}