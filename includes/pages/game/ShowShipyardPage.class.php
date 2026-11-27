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
 */
 

class ShowShipyardPage extends AbstractGamePage
{
	public static $requireModule = 0;
	
	public static $defaultController = 'show';

	function __construct() 
	{
		parent::__construct();
	}
	
	private function CancelAuftr($mode = 'fleet') 
	{
		global $USER, $PLANET, $resource;
		
		// Seleccionamos la cola según el modo
		$queueField = ($mode == 'defense') ? 'b_defense_id' : 'b_hangar_id';
		$timeField  = ($mode == 'defense') ? 'b_defense'    : 'b_hangar';
		
		$ElementQueue = unserialize($PLANET[$queueField]);
		
		$CancelArray	= HTTP::_GP('auftr', array());
		
		if(!is_array($CancelArray))
		{
			return false;
		}	
		
		foreach ($CancelArray as $Auftr)
		{
			if(!isset($ElementQueue[$Auftr])) {
				continue;
			}
			
			if($Auftr == 0) {
				$PLANET[$timeField]	= 0;
			}
			
			$Element		= $ElementQueue[$Auftr][0];
			$Count			= $ElementQueue[$Auftr][1];
			
			$costResources	= BuildFunctions::getElementPrice($USER, $PLANET, $Element, false, $Count);
		
		if(isset($costResources[901])) { $PLANET[$resource[901]]	+= $costResources[901] * FACTOR_CANCEL_SHIPYARD; }
		if(isset($costResources[902])) { $PLANET[$resource[902]]	+= $costResources[902] * FACTOR_CANCEL_SHIPYARD; }
		if(isset($costResources[903])) { $PLANET[$resource[903]]	+= $costResources[903] * FACTOR_CANCEL_SHIPYARD; }
		if(isset($costResources[921])) { $USER[$resource[921]]		+= $costResources[921] * FACTOR_CANCEL_SHIPYARD; }
		// 🆕 v2.4.0 — Reembolso en Norium (932) y Germanium (933)
		if(isset($costResources[932])) { $PLANET['norium']			+= $costResources[932] * FACTOR_CANCEL_SHIPYARD; }
		if(isset($costResources[933])) { $PLANET['germanium']		+= $costResources[933] * FACTOR_CANCEL_SHIPYARD; }
			
			unset($ElementQueue[$Auftr]);
		}
		
		if(empty($ElementQueue)) {
			$PLANET[$queueField]	= '';
		} else {
			$PLANET[$queueField]	= serialize(array_values($ElementQueue));
		}

		return true;
	}
	
	private function BuildAuftr($fmenge, $mode = 'fleet')
	{
		global $USER, $PLANET, $reslist, $resource;
		
		$Missiles	= array(
			502	=> $PLANET[$resource[502]],
			503	=> $PLANET[$resource[503]],
		);

		foreach($fmenge as $Element => $Count)
		{
			if(empty($Count)
				|| !in_array($Element, array_merge($reslist['fleet'], $reslist['defense'], $reslist['missile']))
				|| !BuildFunctions::isTechnologieAccessible($USER, $PLANET, $Element)
			) {
				continue;
			}
			
			// Detectar si el elemento es defensa/misil o nave
			$isDefense  = in_array($Element, array_merge($reslist['defense'], $reslist['missile']));
			$queueField = $isDefense ? 'b_defense_id' : 'b_hangar_id';
			
			$MaxElements 	= BuildFunctions::getMaxConstructibleElements($USER, $PLANET, $Element);
			$Count			= is_numeric($Count) ? round($Count) : 0;
			$Count 			= max(min($Count, Config::get()->max_fleet_per_build), 0);
			$Count 			= min($Count, $MaxElements);

			// 🆕 v2.4.0 — Límite del Taladrador de Norio (234):
			// máximo 4 naves por nivel de la Mina de Norio (7), contando
			// las construidas y las ya encoladas (anti-exploit).
			if ($Element == 234 && isset($resource[7], $PLANET[$resource[7]])) {
				$mineNorio   = (int) $PLANET[$resource[7]];
				$limiteTotal = 4 * $mineNorio;
				$enCola      = 0;
				$BuildArray  = !empty($PLANET[$queueField]) ? unserialize($PLANET[$queueField]) : array();
				if (is_array($BuildArray)) {
					foreach ($BuildArray as $ElementArray) {
						if ($ElementArray[0] == 234) { $enCola += (int) $ElementArray[1]; }
					}
				}
				$disponibles = max(0, $limiteTotal - (int) $PLANET[$resource[234]] - $enCola);
				$Count       = min($Count, $disponibles);
			}
			
			$BuildArray    	= !empty($PLANET[$queueField]) ? unserialize($PLANET[$queueField]) : array();
			if (in_array($Element, $reslist['missile']))
			{
				$MaxMissiles		= BuildFunctions::getMaxConstructibleRockets($USER, $PLANET, $Missiles);
				$Count 				= min($Count, $MaxMissiles[$Element]);

				$Missiles[$Element] += $Count;
			} elseif(in_array($Element, $reslist['one'])) {
				$InBuild	= false;
				foreach($BuildArray as $ElementArray) {
					if($ElementArray[0] == $Element) {
						$InBuild	= true;
						break;
					}
				}
				
				if ($InBuild)
					continue;

				if($Count != 0 && $PLANET[$resource[$Element]] == 0 && $InBuild === false)
					$Count =  1;
			}

			if(empty($Count))
				continue;
				
			$costResources	= BuildFunctions::getElementPrice($USER, $PLANET, $Element, false, $Count);
		
			if(isset($costResources[901])) { $PLANET[$resource[901]]	-= $costResources[901]; }
			if(isset($costResources[902])) { $PLANET[$resource[902]]	-= $costResources[902]; }
			if(isset($costResources[903])) { $PLANET[$resource[903]]	-= $costResources[903]; }
			if(isset($costResources[921])) { $USER[$resource[921]]		-= $costResources[921]; }
			// 🆕 v2.4.0 — Pago en Norium (932) y Germanium (933)
			if(isset($costResources[932])) { $PLANET['norium']			-= $costResources[932]; }
			if(isset($costResources[933])) { $PLANET['germanium']		-= $costResources[933]; }
			
			$BuildArray[]			= array($Element, $Count);
			$PLANET[$queueField]	= serialize($BuildArray);
		}
	}
	
	public function show()
	{
		global $USER, $PLANET, $LNG, $resource, $reslist;
		
		if ($PLANET[$resource[21]] == 0)
		{
			$this->printMessage($LNG['bd_shipyard_required']);
		}

		// Obtenemos el modo PRIMERO para usarlo en todo el flujo
		$mode		= HTTP::_GP('mode', 'fleet');

		$buildTodo	= HTTP::_GP('fmenge', array());
		$action		= HTTP::_GP('action', '');
								
		$NotBuilding = true;
		if (!empty($PLANET['b_building_id']))
		{
			$CurrentQueue 	= unserialize($PLANET['b_building_id']);
			foreach($CurrentQueue as $ElementArray)
			{
				if($ElementArray[0] == 21 || $ElementArray[0] == 15) {
					$NotBuilding = false;
					break;
				}
			}
		}
		
		// Cola según el modo
		$queueField = ($mode == 'defense') ? 'b_defense_id' : 'b_hangar_id';
		$timeField  = ($mode == 'defense') ? 'b_defense'    : 'b_hangar';
		
		$ElementQueue 	= unserialize($PLANET[$queueField]);
		if(empty($ElementQueue))
			$Count	= 0;
		else
			$Count	= count($ElementQueue);
			
		if($USER['urlaubs_modus'] == 0 && $NotBuilding == true)
		{
			if (!empty($buildTodo))
			{
				$maxBuildQueue	= Config::get()->max_elements_ships;
				if ($maxBuildQueue != 0 && $Count >= $maxBuildQueue)
				{
					$this->printMessage(sprintf($LNG['bd_max_builds'], $maxBuildQueue));
				}

				$this->BuildAuftr($buildTodo, $mode);
			}
					
			if ($action == "delete")
			{
				$this->CancelAuftr($mode);
			}
		}
		
		$elementInQueue	= array();
		$ElementQueue 	= unserialize($PLANET[$queueField]);
		$buildList		= array();
		$elementList	= array();

		// Mostramos SOLO la cola del modo actual (naves O defensas, nunca mezcladas)
		if(!empty($ElementQueue))
		{
			$Shipyard		= array();
			$QueueTime		= 0;
			foreach($ElementQueue as $Element)
			{
				if (empty($Element))
					continue;
					
				$elementInQueue[$Element[0]]	= true;
				$ElementTime  	= BuildFunctions::getBuildingTime($USER, $PLANET, $Element[0]);
				$QueueTime   	+= $ElementTime * $Element[1];
				
				// Decodificar HTML entities para que el JS reciba texto plano
				$name = html_entity_decode($LNG['tech'][$Element[0]], ENT_QUOTES, 'UTF-8');
				
				$Shipyard[]		= array($name, $Element[1], $ElementTime, $Element[0]);		
			}

			$buildList	= array(
				'Queue' 				=> $Shipyard,
				'b_hangar_id_plus' 		=> $PLANET[$timeField],
				'pretty_time_b_hangar' 	=> pretty_time(max($QueueTime - $PLANET[$timeField],0)),
			);
		}
		
		if($mode == 'defense') {
			$elementIDs	= array_merge($reslist['defense'], $reslist['missile']);
		} else {
			$elementIDs	= $reslist['fleet'];
		}
		
		$Missiles	= array();
		
		foreach($reslist['missile'] as $elementID)
		{
			$Missiles[$elementID]	= $PLANET[$resource[$elementID]];
		}
		
		$MaxMissiles	= BuildFunctions::getMaxConstructibleRockets($USER, $PLANET, $Missiles);
		
		foreach($elementIDs as $Element)
		{
			if(!BuildFunctions::isTechnologieAccessible($USER, $PLANET, $Element))
				continue;
			
			$costResources		= BuildFunctions::getElementPrice($USER, $PLANET, $Element);
			$costOverflow		= BuildFunctions::getRestPrice($USER, $PLANET, $Element, $costResources);
			$elementTime    	= BuildFunctions::getBuildingTime($USER, $PLANET, $Element, $costResources);
			$buyable			= BuildFunctions::isElementBuyable($USER, $PLANET, $Element, $costResources);
			$maxBuildable		= BuildFunctions::getMaxConstructibleElements($USER, $PLANET, $Element, $costResources);

			if(isset($MaxMissiles[$Element])) {
				$maxBuildable	= min($maxBuildable, $MaxMissiles[$Element]);
			}
			
			$AlreadyBuild		= in_array($Element, $reslist['one']) && (isset($elementInQueue[$Element]) || $PLANET[$resource[$Element]] != 0);
			
			$elementList[$Element]	= array(
				'id'				=> $Element,
				'available'			=> $PLANET[$resource[$Element]],
				'costResources'		=> $costResources,
				'costOverflow'		=> $costOverflow,
				'elementTime'    	=> $elementTime,
				'buyable'			=> $buyable,
				'maxBuildable'		=> floatToString($maxBuildable),
				'AlreadyBuild'		=> $AlreadyBuild,
			);
		}
		
		$this->assign(array(
			'elementList'	=> $elementList,
			'NotBuilding'	=> $NotBuilding,
			'BuildList'		=> $buildList,
			'maxlength'		=> strlen(Config::get()->max_fleet_per_build),
			'mode'			=> $mode,
		));

		$this->display('page.shipyard.default.tpl');
	}
}