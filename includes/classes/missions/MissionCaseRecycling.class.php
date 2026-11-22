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
 * ASTROIO v1.4 - Asteroides (TIEMPO DE VUELTA CORREGIDO)
 */

// ============================================
// ASTROIO - Cargar EventHelper explícitamente
// ============================================
if (!class_exists('EventHelper')) {
    require_once ROOT_PATH.'includes/classes/EventHelper.class.php';
}
// ============================================
// ASTROIO - Cargar AsteroidHelper (asteroides)
// ============================================
if (!class_exists('AsteroidHelper')) {
    require_once ROOT_PATH.'includes/classes/AsteroidHelper.class.php';
}
// ============================================

class MissionCaseRecycling extends MissionFunctions implements Mission
{
	function __construct($Fleet)
	{
		$this->_fleet	= $Fleet;
	}
	
	function TargetEvent()
	{	
		global $pricelist, $resource;

		try {
			// ============================================
			// ASTROIO - Deteccion de asteroide
			// ============================================
			if (class_exists('AsteroidHelper')) {
				$asteroid = AsteroidHelper::getAsteroidAt(
					$this->_fleet['fleet_end_galaxy'],
					$this->_fleet['fleet_end_system'],
					$this->_fleet['fleet_end_planet']
				);

				if (!empty($asteroid)) {
					$this->recycleAsteroid($asteroid);
					return; // Salimos, la flota ya está configurada para volver
				}
			}
			
			// ============================================
			// RECICLAJE DE ESCOMBROS NORMAL
			// ============================================
			$resourceIDs	= array(901, 902, 903, 921);
			$debrisIDs		= array(901, 902);
			$resQuery		= array();
			$collectQuery	= array();
			
			$collectedGoods = array();
			foreach($debrisIDs as $debrisID)
			{
				$collectedGoods[$debrisID] = 0;
				$resQuery[]	= 'der_'.$resource[$debrisID];
			}

			$sql	= 'SELECT '.implode(',', $resQuery).', ('.implode(' + ', $resQuery).') as total
			FROM %%PLANETS%% WHERE id = :planetId';

			$targetData	= Database::get()->selectSingle($sql, array(
				':planetId'	=> $this->_fleet['fleet_end_id']
			));

			if(!empty($targetData['total']))
			{
				$sql				= 'SELECT * FROM %%USERS%% WHERE id = :userId;';
				$targetUser			= Database::get()->selectSingle($sql, array(
					':userId'	=> $this->_fleet['fleet_owner']
				));

				$targetUserFactors	= getFactors($targetUser);
				$shipStorageFactor	= 1 + $targetUserFactors['ShipStorage'];
			
				$fleetData			= FleetFunctions::unserialize($this->_fleet['fleet_array']);

				$recyclerStorage	= 0;
				$otherFleetStorage	= 0;

				foreach ($fleetData as $shipId => $shipAmount)
				{
					if ($shipId == 209 ||  $shipId == 219)
					{
						$recyclerStorage   += $pricelist[$shipId]['capacity'] * $shipAmount;
					}
					else
					{
						$otherFleetStorage += $pricelist[$shipId]['capacity'] * $shipAmount;
					}
				}
				
				$recyclerStorage	*= $shipStorageFactor;
				$otherFleetStorage	*= $shipStorageFactor;

				$incomingGoods		= 0;
				foreach($resourceIDs as $resourceID)
				{
					$incomingGoods	+= $this->_fleet['fleet_resource_'.$resource[$resourceID]];
				}

				$totalStorage = $recyclerStorage + min(0, $otherFleetStorage - $incomingGoods);

				$param	= array(
					':planetId'	=> $this->_fleet['fleet_end_id']
				);

				$collectFactor	= min(1, $totalStorage / $targetData['total']);
				foreach($debrisIDs as $debrisID)
				{
					$fleetColName	= 'fleet_resource_'.$resource[$debrisID];
					$debrisColName	= 'der_'.$resource[$debrisID];

					$collectedGoods[$debrisID]			= ceil($targetData[$debrisColName] * $collectFactor);
					$collectQuery[]						= $debrisColName.' = GREATEST(0, '.$debrisColName.' - :'.$resource[$debrisID].')';
					$param[':'.$resource[$debrisID]]	= $collectedGoods[$debrisID];

					$this->UpdateFleet($fleetColName, $this->_fleet[$fleetColName] + $collectedGoods[$debrisID]);
				}

				$sql	= 'UPDATE %%PLANETS%% SET '.implode(',', $collectQuery).' WHERE id = :planetId;';

				Database::get()->update($sql, $param);
			}
			
			$totalRecycled	= (int)$collectedGoods[901] + (int)$collectedGoods[902];

			if ($totalRecycled > 0 && class_exists('EventHelper')) {
				EventHelper::updateProgress($this->_fleet['fleet_owner'], 'recycle_debris', $totalRecycled);
			}
			
			$LNG		= $this->getLanguage(NULL, $this->_fleet['fleet_owner']);
			
			$Message 	= sprintf($LNG['sys_recy_gotten'], 
				pretty_number($collectedGoods[901]), $LNG['tech'][901],
				pretty_number($collectedGoods[902]), $LNG['tech'][902]
			);

			PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 5,
				$LNG['sys_recy_report'], $Message, $this->_fleet['fleet_start_time'], NULL, 1, $this->_fleet['fleet_universe']);

			// ============================================
			// ASTROIO - CALCULAR TIEMPO DE VUELTA (ESCOMBROS)
			// ============================================
			$Duration = max(1, $this->_fleet['fleet_end_time'] - $this->_fleet['fleet_start_time']);
			$this->UpdateFleet('fleet_start_time', TIMESTAMP);
			$this->UpdateFleet('fleet_end_time', TIMESTAMP + $Duration);
			// ============================================

			$this->setState(FLEET_RETURN);
			$this->SaveFleet();

		} catch (Throwable $e) {
			// Si algo falla en la llegada (escombros), devolvemos la flota a casa a la fuerza
			$logDir = defined('ROOT_PATH') ? ROOT_PATH : dirname(__FILE__) . '/../../../';
			@file_put_contents(
				$logDir . 'cache/asteroid_error.log',
				'[' . date('Y-m-d H:i:s') . '] ERROR EN LLEGADA: ' . $e->getMessage() . ' en ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL,
				FILE_APPEND
			);
			
			// ============================================
			// ASTROIO - CALCULAR TIEMPO DE VUELTA (ERROR)
			// ============================================
			$Duration = max(1, $this->_fleet['fleet_end_time'] - $this->_fleet['fleet_start_time']);
			$this->UpdateFleet('fleet_start_time', TIMESTAMP);
			$this->UpdateFleet('fleet_end_time', TIMESTAMP + $Duration);
			// ============================================

			$this->setState(FLEET_RETURN);
			$this->SaveFleet();
		}
	}
	
	// ============================================
	// ASTROIO - Reciclaje de un asteroide
	// ============================================
	private function recycleAsteroid($asteroid)
	{
		try {
			$db = Database::get();
			$prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';

			$sql = 'SELECT * FROM %%USERS%% WHERE id = :userId;';
			$targetUser = $db->selectSingle($sql, array(
				':userId' => $this->_fleet['fleet_owner']
			));

			$targetUserFactors  = getFactors($targetUser);
			$shipStorageFactor  = 1 + $targetUserFactors['ShipStorage'];
			$fleetData = FleetFunctions::unserialize($this->_fleet['fleet_array']);

			// Procesar reciclaje
			$result = AsteroidHelper::recycleAsteroid(
				$this->_fleet,
				$asteroid,
				$fleetData,
				$shipStorageFactor
			);

			$collected = $result['collected'];

			// Actualizar flota
			$this->UpdateFleet('fleet_resource_metal',     $this->_fleet['fleet_resource_metal']     + $collected[901]);
			$this->UpdateFleet('fleet_resource_crystal',   $this->_fleet['fleet_resource_crystal']   + $collected[902]);
			$this->UpdateFleet('fleet_resource_deuterium', $this->_fleet['fleet_resource_deuterium'] + $collected[903]);

			if ($result['chest']) {
				$this->UpdateFleet('fleet_asteroid_chest', 1);
			}

			// Eventos
			$totalRecycled = $collected[901] + $collected[902] + $collected[903];
			if ($totalRecycled > 0 && class_exists('EventHelper')) {
				EventHelper::updateProgress($this->_fleet['fleet_owner'], 'recycle_debris', $totalRecycled);
			}

			if (class_exists('EventHelper')) {
				$ownerId = (int)$this->_fleet['fleet_owner'];
				EventHelper::updateProgress($ownerId, 'recycle_asteroid', 1, 0);
				$typeMap = array('metal' => 1, 'crystal' => 2, 'deuterium' => 3, 'container' => 4);
				if (isset($typeMap[$asteroid['type']])) {
					EventHelper::updateProgress($ownerId, 'recycle_asteroid', 1, $typeMap[$asteroid['type']]);
				}
			}

			// Mensaje
			$LNG = $this->getLanguage(NULL, $this->_fleet['fleet_owner']);
			$message  = "Has reciclado un asteroide:<br><br>";
			if ($collected[901] > 0) $message .= "- Metal: " . pretty_number($collected[901]) . "<br>";
			if ($collected[902] > 0) $message .= "- Cristal: " . pretty_number($collected[902]) . "<br>";
			if ($collected[903] > 0) $message .= "- Deuterio: " . pretty_number($collected[903]) . "<br>";
			
			if ($result['chest']) {
				$rarityTxt = array('common'=>'Comun','rare'=>'Raro','epic'=>'Epico','mythic'=>'Mitico');
				$r = isset($rarityTxt[$result['chest_rarity']]) ? $rarityTxt[$result['chest_rarity']] : 'Comun';
				$message .= "<br>Has encontrado un CONTENEDOR " . $r . ".<br>Llegara a tu planeta cuando la flota regrese.";
			}

			PlayerUtil::sendMessage(
				$this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 5,
				'Reciclaje de asteroide', $message,
				$this->_fleet['fleet_start_time'], NULL, 1, $this->_fleet['fleet_universe']
			);

		} catch (Throwable $e) {
			// Si algo falla, guardar log
			$logDir = defined('ROOT_PATH') ? ROOT_PATH : dirname(__FILE__) . '/../../../';
			@file_put_contents(
				$logDir . 'cache/asteroid_error.log',
				'[' . date('Y-m-d H:i:s') . '] ERROR EN ASTEROIDE: ' . $e->getMessage() . ' en ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL,
				FILE_APPEND
			);
		}

		// ============================================
		// ASTROIO - CALCULAR TIEMPO DE VUELTA (ASTEROIDE)
		// ============================================
		$Duration = max(1, $this->_fleet['fleet_end_time'] - $this->_fleet['fleet_start_time']);
		$this->UpdateFleet('fleet_start_time', TIMESTAMP);
		$this->UpdateFleet('fleet_end_time', TIMESTAMP + $Duration);
		// ============================================

		// PASE LO QUE PASE, LA FLOTA VUELVE A CASA
		$this->setState(FLEET_RETURN);
		$this->SaveFleet();
	}
	// ============================================
	
	function EndStayEvent()
	{
		return;
	}
	
	function ReturnEvent()
	{
		try {
			$LNG		= $this->getLanguage(NULL, $this->_fleet['fleet_owner']);

			// ============================================
			// ASTROIO - Entrega del contenedor
			// ============================================
			if (!empty($this->_fleet['fleet_asteroid_chest'])) {
				if (class_exists('AsteroidHelper')) {
					AsteroidHelper::deliverChest($this->_fleet['fleet_owner']);
				}

				PlayerUtil::sendMessage(
					$this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 5,
					'Contenedor recibido',
					'Tu flota ha regresado con un contenedor.<br>Abrelo en:<br><a href="game.php?page=containers">Contenedores</a>',
					$this->_fleet['fleet_end_time'], NULL, 1, $this->_fleet['fleet_universe']
				);
			}
			// ============================================

			$sql		= 'SELECT name FROM %%PLANETS%% WHERE id = :planetId;';
			$planetName	= Database::get()->selectSingle($sql, array(
				':planetId'	=> $this->_fleet['fleet_start_id'],
			), 'name');
		
			$Message	= sprintf($LNG['sys_tran_mess_owner'],
				$planetName, GetStartAddressLink($this->_fleet, ''),
				pretty_number($this->_fleet['fleet_resource_metal']), $LNG['tech'][901],
				pretty_number($this->_fleet['fleet_resource_crystal']), $LNG['tech'][902],
				pretty_number($this->_fleet['fleet_resource_deuterium']), $LNG['tech'][903]
			);

			PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 4, $LNG['sys_mess_fleetback'],
				$Message, $this->_fleet['fleet_end_time'], NULL, 1, $this->_fleet['fleet_universe']);

		} catch (Throwable $e) {
			// Si falla la entrega del mensaje, guardar log
			$logDir = defined('ROOT_PATH') ? ROOT_PATH : dirname(__FILE__) . '/../../../';
			@file_put_contents(
				$logDir . 'cache/asteroid_error.log',
				'[' . date('Y-m-d H:i:s') . '] ERROR EN RETORNO: ' . $e->getMessage() . ' en ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL,
				FILE_APPEND
			);
		}

		// PASE LO QUE PASE, LOS RECURSOS SE ACREDITAN AL PLANETA
		$this->RestoreFleet();
	}
}