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

class ShowResourcesPage extends AbstractGamePage
{
	public static $requireModule = MODULE_RESSOURCE_LIST;

	function __construct() 
	{
		parent::__construct();
	}
	
	function send()
	{
		global $resource, $USER, $PLANET;
		if ($USER['urlaubs_modus'] == 0)
		{
			$updateSQL	= array();
			if(!isset($_POST['prod']))
				$_POST['prod'] = array();


			$param	= array(':planetId' => $PLANET['id']);
			
			foreach($_POST['prod'] as $resourceId => $Value)
			{
				$FieldName = $resource[$resourceId].'_porcent';
				if (!isset($PLANET[$FieldName]) || !in_array($Value, range(0, 10)))
					continue;
				
				$updateSQL[]	= $FieldName." = :".$FieldName;
				$param[':'.$FieldName]		= (int) $Value;
				$PLANET[$FieldName]			= $Value;
			}

			if(!empty($updateSQL))
			{
				$sql	= 'UPDATE %%PLANETS%% SET '.implode(', ', $updateSQL).' WHERE id = :planetId;';

				Database::get()->update($sql, $param);

				$this->ecoObj->setData($USER, $PLANET);
				$this->ecoObj->ReBuildCache();
				list($USER, $PLANET)	= $this->ecoObj->getData();
				$PLANET['eco_hash'] = $this->ecoObj->CreateHash();
			}
		}

		$this->save();
		$this->redirectTo('game.php?page=resources');
	}
	function show()
	{
		global $LNG, $ProdGrid, $resource, $reslist, $USER, $PLANET;

		$config	= Config::get();

		if($USER['urlaubs_modus'] == 1 || $PLANET['planet_type'] != 1)
		{
			$basicIncome[901]	= 0;
			$basicIncome[902]	= 0;
			$basicIncome[903]	= 0;
			$basicIncome[911]	= 0;
		}
		else
		{		
			$basicIncome[901]	= isset($resource[901]) ? $config->{$resource[901].'_basic_income'} : 0;
			$basicIncome[902]	= isset($resource[902]) ? $config->{$resource[902].'_basic_income'} : 0;
			$basicIncome[903]	= isset($resource[903]) ? $config->{$resource[903].'_basic_income'} : 0;
			$basicIncome[911]	= isset($resource[911]) ? $config->{$resource[911].'_basic_income'} : 0;
		}
		
		$temp	= array(
			901	=> array(
				'plus'	=> 0,
				'minus'	=> 0,
			),
			902	=> array(
				'plus'	=> 0,
				'minus'	=> 0,
			),
			903	=> array(
				'plus'	=> 0,
				'minus'	=> 0,
			),
			911	=> array(
				'plus'	=> 0,
				'minus'	=> 0,
			)
		);
		
		$ressIDs		= array_merge(array(), $reslist['resstype'][1], $reslist['resstype'][2]);

		$productionList	= array();

		if($PLANET['energy_used'] != 0) {
			$prodLevel	= min(1, $PLANET['energy'] / abs($PLANET['energy_used']));
		} else {
			$prodLevel	= 0;
		}

		/* Data for eval */
		$BuildEnergy		= isset($resource[113]) && isset($USER[$resource[113]]) ? $USER[$resource[113]] : 0;
		$BuildTemp          = isset($PLANET['temp_max']) ? $PLANET['temp_max'] : 0;

		foreach($reslist['prod'] as $ProdID)
		{
			if(isset($PLANET[$resource[$ProdID]]) && $PLANET[$resource[$ProdID]] == 0)
				continue;

			if(isset($USER[$resource[$ProdID]]) && $USER[$resource[$ProdID]] == 0)
				continue;

			$elementLevel = isset($resource[$ProdID]) && isset($PLANET[$resource[$ProdID]]) ? $PLANET[$resource[$ProdID]] : 0;
			$prodLevelPercent = isset($resource[$ProdID]) && isset($PLANET[$resource[$ProdID].'_porcent']) ? $PLANET[$resource[$ProdID].'_porcent'] : 0;

			$productionList[$ProdID]	= array(
				'production'	=> array(901 => 0, 902 => 0, 903 => 0, 911 => 0),
				'elementLevel'	=> $elementLevel,
				'prodLevel'		=> $prodLevelPercent,
			);

			/* Data for eval */
			$BuildLevel			= $elementLevel;
			$BuildLevelFactor	= $prodLevelPercent;

			foreach($ressIDs as $ID)
			{
				if(!isset($ProdGrid[$ProdID]['production'][$ID]))
					continue;

				$Production	= eval(ResourceUpdate::getProd($ProdGrid[$ProdID]['production'][$ID]));

				if(in_array($ID, $reslist['resstype'][2]))
				{
					$Production	*= $config->energySpeed;
				}
				else
				{
					$Production	*= $prodLevel * $config->resource_multiplier;
				}
				
				$productionList[$ProdID]['production'][$ID]	= $Production;
				
				if(!isset($temp[$ID])) {
					$temp[$ID] = array('plus' => 0, 'minus' => 0);
				}

				if($Production > 0) {
					if(!isset($resource[$ID]) || !isset($PLANET[$resource[$ID]]) || $PLANET[$resource[$ID]] == 0) continue;
					
					$temp[$ID]['plus']	+= $Production;
				} else {
					$temp[$ID]['minus']	+= $Production;
				}
			}
		}
				
		$resource901 = isset($resource[901]) ? $resource[901] : '';
		$resource902 = isset($resource[902]) ? $resource[902] : '';
		$resource903 = isset($resource[903]) ? $resource[903] : '';
		$resource911 = isset($resource[911]) ? $resource[911] : '';

		$storage	= array(
			901 => isset($PLANET[$resource901.'_max']) ? shortly_number($PLANET[$resource901.'_max']) : '0',
			902 => isset($PLANET[$resource902.'_max']) ? shortly_number($PLANET[$resource902.'_max']) : '0',
			903 => isset($PLANET[$resource903.'_max']) ? shortly_number($PLANET[$resource903.'_max']) : '0',
		);
		
		$basicProduction	= array(
			901 => $basicIncome[901] * $config->resource_multiplier,
			902 => $basicIncome[902] * $config->resource_multiplier,
			903	=> $basicIncome[903] * $config->resource_multiplier,
			911	=> $basicIncome[911] * $config->energySpeed,
		);
		
		$totalProduction	= array(
			901 => (isset($PLANET[$resource901.'_perhour']) ? $PLANET[$resource901.'_perhour'] : 0) + $basicProduction[901],
			902 => (isset($PLANET[$resource902.'_perhour']) ? $PLANET[$resource902.'_perhour'] : 0) + $basicProduction[902],
			903	=> (isset($PLANET[$resource903.'_perhour']) ? $PLANET[$resource903.'_perhour'] : 0) + $basicProduction[903],
			911	=> (isset($PLANET[$resource911]) ? $PLANET[$resource911] : 0) + $basicProduction[911] + (isset($PLANET[$resource911.'_used']) ? $PLANET[$resource911.'_used'] : 0),
		);
		
		$factorResource = isset($USER['factor']['Resource']) ? $USER['factor']['Resource'] : 0;
		$factorEnergy = isset($USER['factor']['Energy']) ? $USER['factor']['Energy'] : 0;

		$resource131 = isset($resource[131]) && isset($USER[$resource[131]]) ? $USER[$resource[131]] : 0;
		$resource132 = isset($resource[132]) && isset($USER[$resource[132]]) ? $USER[$resource[132]] : 0;
		$resource133 = isset($resource[133]) && isset($USER[$resource[133]]) ? $USER[$resource[133]] : 0;

		$bonusProduction	= array(
			901 => (isset($temp[901]['plus']) ? $temp[901]['plus'] : 0) * ($factorResource + 0.02 * $resource131),
			902 => (isset($temp[902]['plus']) ? $temp[902]['plus'] : 0) * ($factorResource + 0.02 * $resource132),
			903	=> (isset($temp[903]['plus']) ? $temp[903]['plus'] : 0) * ($factorResource + 0.02 * $resource133),
			911	=> (isset($temp[911]['plus']) ? $temp[911]['plus'] : 0) * $factorEnergy,
		);
		
		$dailyProduction	= array(
			901 => $totalProduction[901] * 24,
			902 => $totalProduction[902] * 24,
			903	=> $totalProduction[903] * 24,
			911	=> $totalProduction[911],
		);
		
		$weeklyProduction	= array(
			901 => $totalProduction[901] * 168,
			902 => $totalProduction[902] * 168,
			903	=> $totalProduction[903] * 168,
			911	=> $totalProduction[911],
		);
			
		$prodSelector	= array();
		
		foreach(range(10, 0) as $percent) {
			$prodSelector[$percent]	= ($percent * 10).'%';
		}
		
		$this->assign(array(
			'header'			=> sprintf($LNG['rs_production_on_planet'], $PLANET['name']),
			'prodSelector'		=> $prodSelector,
			'productionList'	=> $productionList,
			'basicProduction'	=> $basicProduction,
			'totalProduction'	=> $totalProduction,
			'bonusProduction'	=> $bonusProduction,
			'dailyProduction'	=> $dailyProduction,
			'weeklyProduction'	=> $weeklyProduction,
			'storage'			=> $storage,
		));
		
		$this->display('page.resources.default.tpl');
	}
}