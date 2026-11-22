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
 * ✅ AstroIO v1.0 (Bonos de Expedición):
 *   - Potenciadores: exp_resources + exp_darkmatter
 *   - Razas/Facciones: bonus_exp_resources + bonus_exp_darkmatter
 *   - Se aplican al resultado de las expediciones exitosas (case 1 y 2)
 *
 * ✅ AstroIO v1.1 (FALLBACK DIRECTO Pot. Materia Oscura):
 *   - Nuevo método privado getDirectBoosterBonus() que lee DIRECTAMENTE
 *     de `uni1_users_boosters` + `uni1_boosters` (sin depender de BoosterHelper)
 *   - Si BoosterHelper existe → se usa (comportamiento original)
 *   - Si NO existe → se usa el fallback directo
 *   - Aplica para:
 *       💎 Pot. Materia Oscura → booster_type = 'exp_darkmatter' (+20% MO)
 *       🧭 Pot. Recursos Exp  → booster_type = 'exp_resources'  (+20% recursos)
 *
 * ✅ AstroIO v1.2 (Mini Torneos):
 *   - Enganches a tournement() en eventos de expedición:
 *       case 2 → Torneos 1, 5, 7
 *       case 3 → Torneos 5, 6
 *       case 4 → Torneos 5, 8
 *       case 5 → Torneo 2
 *
 * ✅ AstroIO v1.3 (MÍSTICOS):
 *   - Se integra MisticHelper para aplicar el bonus de MO extraída
 *     en expediciones (NATURE: +5% MO).
 *
 * ✅ AstroIO v1.4 (FIX CRÍTICO - Idempotencia y Contenedores):
 *   - Guard de idempotencia al inicio de EndStayEvent():
 *       UPDATE %%FLEETS%%  SET fleet_mess = FLEET_RETURN
 *        WHERE fleet_id = :fid AND fleet_mess = FLEET_HOLD
 *     Si affected = 0 → otra instancia ya procesó la flota → return.
 *     Si affected = 1 → también se actualiza %%FLEETS_EVENT%% time a
 *     fleet_end_time para que el cron no la recoja antes de tiempo.
 *     Esto elimina el bug de "contenedores al bulto" por doble ejecución.
 *   - Bloque de contenedores: usa %%USERS%% (prefijo correcto vía wrapper)
 *     en lugar de $prefix hardcodeado 'uni1_', y try/catch para no romper
 *     la expedición si el UPDATE falla.
 *   - case 3: fleet_amount ahora suma $Found (naves encontradas) al total
 *     original, evitando la desincronización entre fleet_array y fleet_amount.
 *   - Se MANTIENE setState(FLEET_RETURN) + SaveFleet() al final: el
 *     setState fija eventTime = fleet_end_time (necesario para que
 *     SaveFleet actualice correctamente %%FLEETS_EVENT%%) y el doble
 *     UPDATE de fleet_mess (guard + SaveFleet) es idempotente (1 → 1).
 *
 *   NOTA: en esta instalación la columna de estado de flota es `fleet_mess`
 *   (confirmado con SHOW COLUMNS FROM uni1_fleets). NO existe `fleet_state`.
 *
 * ✅ AstroIO v1.5 (BUFF CLIMÁTICO - DROP DE COFRES):
 *   - Nuevo drop al volver de expedición:
 *       0.5% → cofre climático mayor  (box_climate_major)
 *       1.5% → cofre climático menor  (box_climate_minor)
 *       Total 2.0% de drop, con 0.5% para el mayor.
 *   - Roll único jerárquico de 0.01 a 100.00:
 *       roll ≤ 0.5     → mayor
 *       0.5 < roll ≤ 2 → menor
 *       roll > 2       → nada
 *   - Se inserta en `uni1_users_market` con ON DUPLICATE KEY UPDATE
 *     (crea la fila si el jugador no la tenía).
 *   - El cofre de DOMINIO NO cae en expedición (solo tienda/MN).
 *   - try/catch para no romper la expedición si el UPDATE falla.
 *   - Se ejecuta SIEMPRE, sin importar el resultado (cases 1-9).
 */

// ============================================
// ASTROIO - Cargar EventHelper explícitamente
// ============================================
if (!class_exists('EventHelper')) {
    require_once ROOT_PATH.'includes/classes/EventHelper.class.php';
}
// ============================================

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

class MissionCaseExpedition extends MissionFunctions implements Mission
{
	function __construct($fleet)
	{
		$this->_fleet	= $fleet;
	}

	/**
	 * 🆕 AstroIO v1.1 - Fallback directo si BoosterHelper no existe
	 * ------------------------------------------------------------
	 * Lee el valor total de un potenciador activo del jugador,
	 * filtrando por su `booster_type`, DIRECTAMENTE de la BD.
	 *
	 * @param int    $userId  ID del jugador
	 * @param string $type    Tipo de booster ('exp_darkmatter', 'exp_resources')
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
		$this->setState(FLEET_HOLD);
		$this->SaveFleet();
	}
	
	function EndStayEvent()
	{
		// ============================================
		// ASTROIO v1.4 - GUARD DE IDEMPOTENCIA (FIX CRÍTICO)
		// ------------------------------------------------------------
		// La columna de estado de flota en esta instalación es
		// `fleet_mess` (confirmado con SHOW COLUMNS FROM uni1_fleets).
		//
		// 1) UPDATE atómico HOLD → RETURN. Si affected = 0, otra
		//    instancia ya procesó esta flota (o ya no está en HOLD)
		//    → salimos SIN regalar contenedores, recursos, MO, naves,
		//    ni reenviar mensajes. Esto elimina el "al bulto".
		// 2) Si affected = 1, adelantamos también el `time` de
		//    %%FLEETS_EVENT%% a `fleet_end_time` para que el cron no
		//    recoja la flota antes de que terminemos de procesarla.
		// ============================================
		if (empty($this->_fleet['fleet_id'])) {
			return;
		}

		$db = Database::get();

		$acquired = $db->update(
			"UPDATE %%FLEETS%% SET fleet_mess = :return
			 WHERE fleet_id = :fid AND fleet_mess = :hold",
			array(
				':return' => FLEET_RETURN,
				':fid'    => (int) $this->_fleet['fleet_id'],
				':hold'   => FLEET_HOLD,
			)
		);

		if ($acquired == 0) {
			// Ya procesada por otra instancia → no hacer nada
			return;
		}

		// Adelantar el evento de retorno para que el cron no la recoja
		// mientras terminamos de procesar la expedición.
		$db->update(
			"UPDATE %%FLEETS_EVENT%% SET time = :time WHERE fleetID = :fid",
			array(
				':time' => (int) $this->_fleet['fleet_end_time'],
				':fid'  => (int) $this->_fleet['fleet_id'],
			)
		);

		// Mantener coherencia en memoria con lo que acabamos de escribir
		$this->_fleet['fleet_mess'] = FLEET_RETURN;
		// ============================================

		global $pricelist, $reslist, $resource;
		$LNG	= $this->getLanguage(NULL, $this->_fleet['fleet_owner']);

		$config	= Config::get($this->_fleet['fleet_universe']);

		// ============================================
		// ASTROIO v1.1 - Cargar bonos de expedición del jugador
		// (Potenciadores + Razas/Facciones) con FALLBACK DIRECTO
		// ============================================
		$boosterExpResources	= 0;
		$boosterExpDarkmatter	= 0;
		$raceExpResources		= 0;
		$raceExpDarkmatter		= 0;
		
		// 💎 Pot. Materia Oscura + 🧭 Pot. Recursos Exp
		if (class_exists('BoosterHelper')) {
			$boosterExpResources	= BoosterHelper::getBonus($this->_fleet['fleet_owner'], 'exp_resources') / 100;
			$boosterExpDarkmatter	= BoosterHelper::getBonus($this->_fleet['fleet_owner'], 'exp_darkmatter') / 100;
		} else {
			// Fallback directo si BoosterHelper no existe
			$boosterExpResources	= $this->getDirectBoosterBonus($this->_fleet['fleet_owner'], 'exp_resources') / 100;
			$boosterExpDarkmatter	= $this->getDirectBoosterBonus($this->_fleet['fleet_owner'], 'exp_darkmatter') / 100;
		}
		
		// Razas y Facciones
		if (class_exists('RaceFactionHelper')) {
			$raceExpResources		= RaceFactionHelper::getBonus($this->_fleet['fleet_owner'], 'bonus_exp_resources') / 100;
			$raceExpDarkmatter		= RaceFactionHelper::getBonus($this->_fleet['fleet_owner'], 'bonus_exp_darkmatter') / 100;
		}

		// ============================================
		// ASTROIO v1.3 - Bonos Místicos de Expedición (NATURE)
		// ============================================
		$misticExpDarkmatter	= 0;
		
		if (class_exists('MisticHelper')) {
			$misticBonuses		= MisticHelper::getBonuses($this->_fleet['fleet_owner']);
			$misticExpDarkmatter	= isset($misticBonuses['mo_expediciones']) ? ($misticBonuses['mo_expediciones'] / 100) : 0;
		}
		// ============================================
		
		// Suma total
		$totalExpResources		= $boosterExpResources + $raceExpResources;
		$totalExpDarkmatter		= $boosterExpDarkmatter + $raceExpDarkmatter + $misticExpDarkmatter;
		// ============================================

        $expeditionPoints       = array();

		foreach($reslist['fleet'] as $shipId)
		{
			$expeditionPoints[$shipId]	= ($pricelist[$shipId]['cost'][901] + $pricelist[$shipId]['cost'][902]) * 5 / 1000;
		}
			
		$fleetArray		= FleetFunctions::unserialize($this->_fleet['fleet_array']);
		$fleetPoints 	= 0;
		$fleetCapacity	= 0;

		foreach ($fleetArray as $shipId => $shipAmount)
		{
			$fleetCapacity 			   += $shipAmount * $pricelist[$shipId]['capacity'];
			$fleetPoints   			   += $shipAmount * $expeditionPoints[$shipId];
		}

		$fleetCapacity  -= $this->_fleet['fleet_resource_metal'] + $this->_fleet['fleet_resource_crystal']
			+ $this->_fleet['fleet_resource_deuterium'] + $this->_fleet['fleet_resource_darkmatter'];

		$GetEvent       = mt_rand(1, 9);

        $Message        = $LNG['sys_expe_nothing_'.mt_rand(1,8)];

		switch($GetEvent)
		{
			case 1:
				$eventSize		= mt_rand(0, 100);
                $factor			= 0;

				if(10 < $eventSize)
				{
					$Message	= $LNG['sys_expe_found_ress_1_'.mt_rand(1,4)];
					$factor		= mt_rand(10, 50);
				}
				elseif(0 < $eventSize && 10 >= $eventSize)
				{
					$Message	= $LNG['sys_expe_found_ress_2_'.mt_rand(1,3)];
					$factor		= mt_rand(50, 100);
				}
				elseif(0 == $eventSize)
				{
					$Message	= $LNG['sys_expe_found_ress_3_'.mt_rand(1,2)];
					$factor		= mt_rand(100, 200);
				}

				$chanceToFound	= mt_rand(1, 6);
				if($chanceToFound > 3)
				{
					$resourceId	= 901;
				}
				elseif($chanceToFound > 1)
				{
					$resourceId	= 902;
					$factor		= $factor / 2;
				}
				else
				{
					$resourceId	= 903;
					$factor		= $factor / 3;
				}

				$sql		= "SELECT MAX(total_points) as total FROM %%STATPOINTS%%
				WHERE `stat_type` = :type AND `universe` = :universe;";

				$topPoints	= Database::get()->selectSingle($sql, array(
					':type'		=> 1,
					':universe'	=> $this->_fleet['fleet_universe']
				), 'total');

				if($topPoints > 5000000)
				{
					$maxFactor		= 12000;
				}
				elseif($topPoints > 1000000)
				{
					$maxFactor		= 9000;
				}
				elseif($topPoints > 100000)
				{
					$maxFactor		= 6000;
				}
				else
				{
					$maxFactor		= 2400;
				}

                if ($config->expedition_limit_res_active == 1) {
                    $founded		= round(min($config->expedition_limit_res, $fleetCapacity));
                } else {
                    $founded		= round(min($fleetCapacity,min($maxFactor, max(200, $factor)) * $fleetPoints));
                }

				// ============================================
				// ASTROIO v1.1 - Aplicar bonos de recursos de expedición
				// (Potenciador 🧭 + Razas/Facciones) con fallback
				// ============================================
				if ($totalExpResources > 0) {
					$founded		= round($founded * (1 + $totalExpResources));
				}
				// ============================================

				$fleetColName	= 'fleet_resource_'.$resource[$resourceId];
				$this->UpdateFleet($fleetColName, $this->_fleet[$fleetColName] + $founded);
			break;
			case 2:
				$eventSize   = mt_rand(0, 100);
                $Size       = 0;

				if(10 < $eventSize) {
					$Size		= mt_rand(100, 300);
					$Message	= $LNG['sys_expe_found_dm_1_'.mt_rand(1,5)];
				} elseif(0 < $eventSize && 10 >= $eventSize) {
					$Size		= mt_rand(301, 600);
					$Message	= $LNG['sys_expe_found_dm_2_'.mt_rand(1,3)];
				} elseif(0 == $eventSize) {
					$Size	 	= mt_rand(601, 3000);
					$Message	= $LNG['sys_expe_found_dm_3_'.mt_rand(1,2)];
				}

				// ============================================
				// ASTROIO v1.1 - Aplicar bonos de MO de expedición
				// (💎 Pot. Materia Oscura + Razas/Facciones + Místicos) con fallback
				// ============================================
				if ($totalExpDarkmatter > 0) {
					$Size		= round($Size * (1 + $totalExpDarkmatter));
				}
				// ============================================

				$this->UpdateFleet('fleet_resource_darkmatter', $this->_fleet['fleet_resource_darkmatter'] + $Size);

				// ============================================
				// ASTROIO v1.2 - Mini Torneos: Materia Oscura encontrada
				// Torneos: 1 (más MO), 5 (expe exitosa), 7 (MO > 700)
				// ============================================
				if ($Size > 0) {
					tournement($this->_fleet['fleet_owner'], 1, $Size); // Torneo 1: más MO
					tournement($this->_fleet['fleet_owner'], 5, 1);     // Torneo 5: expe exitosa
				}
				if ($Size > 700) {
					tournement($this->_fleet['fleet_owner'], 7, $Size); // Torneo 7: DM > 700
				}
				// ============================================
			break;
			case 3:
				$eventSize	= mt_rand(0, 100);
                $Size       = 0;
                $Message    = "";

				if(10 < $eventSize) {
					$Size		= mt_rand(10, 50);
					$Message	= $LNG['sys_expe_found_ships_1_'.mt_rand(1,4)];
				} elseif(0 < $eventSize && 10 >= $eventSize) {
					$Size		= mt_rand(52, 100);
					$Message	= $LNG['sys_expe_found_ships_2_'.mt_rand(1,2)];
				} elseif(0 == $eventSize) {
					$Size	 	= mt_rand(102, 200);
					$Message	= $LNG['sys_expe_found_ships_3_'.mt_rand(1,2)];
				}

				$sql		= "SELECT MAX(total_points) as total FROM %%STATPOINTS%%
				WHERE `stat_type` = :type AND `universe` = :universe;";

				$topPoints	= Database::get()->selectSingle($sql, array(
					':type'		=> 1,
					':universe'	=> $this->_fleet['fleet_universe']
				), 'total');

				$MaxPoints 		= ($topPoints < 5000000) ? 4500 : 6000;

				$FoundShips		= max(round($Size * min($fleetPoints, $MaxPoints)), 10000);
				
				$FoundShipMess	= "";	
				$NewFleetArray 	= "";
				
				$Found			= array();
				foreach($reslist['fleet'] as $ID) 
				{
					if(!isset($fleetArray[$ID]) || $ID == 208 || $ID == 209 || $ID == 214)
						continue;
					
					$MaxFound			= floor($FoundShips / ($pricelist[$ID]['cost'][901] + $pricelist[$ID]['cost'][902]));
					if($MaxFound <= 0) 
						continue;
						
					$Count				= mt_rand(0, $MaxFound);
					if($Count <= 0) 
						continue;
						
					$Found[$ID]			= $Count;
					$FoundShips	 		-= $Count * ($pricelist[$ID]['cost'][901] + $pricelist[$ID]['cost'][902]);
					$FoundShipMess   	.= '<br>'.$LNG['tech'][$ID].': '.pretty_number($Count);
					if($FoundShips <= 0)
						break;
				}
				
				if (empty($Found)) {
					$FoundShipMess .= '<br><br>'.$LNG['sys_expe_found_ships_nothing'];
				}

				foreach($fleetArray as $ID => $Count)
				{
					if(!empty($Found[$ID]))
					{
						$Count	+= $Found[$ID];
					}
					
					$NewFleetArray  	.= $ID.",".floatToString($Count).';';
				}	
				
				$Message	.= $FoundShipMess;

				// ============================================
				// ASTROIO v1.2 - Mini Torneos: naves encontradas
				// Torneos: 5 (expe exitosa), 6 (naves)
				// ============================================
				if (!empty($Found)) {
					tournement($this->_fleet['fleet_owner'], 6, 1); // Torneo 6: naves
					tournement($this->_fleet['fleet_owner'], 5, 1); // Torneo 5: expe exitosa
				}
				// ============================================
							
				$this->UpdateFleet('fleet_array', $NewFleetArray);
				// ============================================
				// ASTROIO v1.4 - FIX: fleet_amount debe sumar las naves
				// encontradas ($Found) al total original. Antes se dejaba
				// el array original, causando desincronización entre
				// fleet_array (con naves nuevas) y fleet_amount (sin ellas).
				// ============================================
				$this->UpdateFleet('fleet_amount', array_sum($fleetArray) + array_sum($Found));
			break;
			case 4:
			
				$messageHTML	= <<<HTML
<div class="raportMessage">
<table>
<tr>
<td colspan="2"><a href="CombatReport.php?raport=%s" target="_blank"><span class="%s">%s %s (%s)</span></a></td>
</tr>
<tr>
<td>%s</td><td><span class="%s">%s: %s</span>&nbsp;<span class="%s">%s: %s</span></td>
</tr>
<tr>
<td>%s</td><td><span>%s:&nbsp;<span class="raportSteal element901">%s</span>&nbsp;</span><span>%s:&nbsp;<span class="raportSteal element902">%s</span>&nbsp;</span><span>%s:&nbsp;<span class="raportSteal element903">%s</span></span></td>
</tr>
<tr>
<td>%s</td><td><span>%s:&nbsp;<span class="raportDebris element901">%s</span>&nbsp;</span><span>%s:&nbsp;<span class="raportDebris element902">%s</span></span></td>
</tr>
</table>
</div>
HTML;
				//Minize HTML
				$messageHTML	= str_replace(array("\n", "\t", "\r"), "", $messageHTML);

				// pirate or alien
				$attackType	= mt_rand(1,2);
				$eventSize	= mt_rand(0, 100);

				$targetFleetData	= array();

				if($attackType == 1)
				{
					$techBonus		= -3;
					$targetName		= $LNG['sys_expe_attackname_1'];
					$roundFunction	= 'floor';

					if(10 < $eventSize)
					{
						$Message    			= $LNG['sys_expe_attack_1_1_5'];
						$attackFactor			= (30 + mt_rand(-3, 3)) / 100;
						$targetFleetData[204]	= 5;
					}
					elseif(0 < $eventSize && 10 >= $eventSize)
					{
						$Message    			= $LNG['sys_expe_attack_1_2_3'];
						$attackFactor			= (50 + mt_rand(-5, 5)) / 100;
						$targetFleetData[206]	= 3;
					}
					else
					{
						$Message   				= $LNG['sys_expe_attack_1_3_2'];
						$attackFactor			= (80 + mt_rand(-8, 8)) / 100;
						$targetFleetData[207]	= 2;
					}
				}
				else
				{
					$techBonus		= 3;
					$targetName		= $LNG['sys_expe_attackname_2'];
					$roundFunction	= 'ceil';

					if(10 < $eventSize)
					{
						$Message    			= $LNG['sys_expe_attack_1_1_5'];
						$attackFactor			= (40 + mt_rand(-4, 4)) / 100;
						$targetFleetData[204]	= 5;
					}
					elseif(0 < $eventSize && 10 >= $eventSize)
					{
						$Message    			= $LNG['sys_expe_attack_1_3_3'];
						$attackFactor			= (60 + mt_rand(-6, 6)) / 100;
						$targetFleetData[215]	= 3;
					}
					else
					{
						$Message    			= $LNG['sys_expe_attack_1_3_2'];
						$attackFactor			= (90 + mt_rand(-9, 9)) / 100;
						$targetFleetData[213]	= 2;
					}
				}
					
				foreach($fleetArray as $shipId => $shipAmount)
				{
					if(isset($targetFleetData[$shipId]))
					{
						$targetFleetData[$shipId]	= 0;
					}

					$targetFleetData[$shipId]	= $roundFunction($shipAmount * $attackFactor);
				}

				$targetFleetData	= array_filter($targetFleetData);

				$sql = 'SELECT * FROM %%USERS%% WHERE id = :userId;';

				$senderData	= Database::get()->selectSingle($sql, array(
					':userId'	=> $this->_fleet['fleet_owner']
				));

				$targetData	= array(
					'id'			=> 0,
					'username'		=> $targetName,
					'military_tech'	=> min($senderData['military_tech'] + $techBonus, 0),
					'defence_tech'	=> min($senderData['defence_tech'] + $techBonus, 0),
					'shield_tech'	=> min($senderData['shield_tech'] + $techBonus, 0),
					'rpg_amiral'	=> 0,
					'dm_defensive'	=> 0,
					'dm_attack' 	=> 0
				);
				
				$fleetID	= $this->_fleet['fleet_id'];
				
				$fleetAttack[$fleetID]['fleetDetail']		= $this->_fleet;
				$fleetAttack[$fleetID]['player']			= $senderData;
				$fleetAttack[$fleetID]['player']['factor']	= getFactors($fleetAttack[$this->_fleet['fleet_id']]['player'], 'attack', $this->_fleet['fleet_start_time']);
				$fleetAttack[$fleetID]['unit']				= $fleetArray;
				
				$fleetDefend = array();

				$fleetDefend[0]['fleetDetail'] = array(
					'fleet_start_galaxy'		=> $this->_fleet['fleet_end_galaxy'],
					'fleet_start_system'		=> $this->_fleet['fleet_end_system'],
					'fleet_start_planet'		=> $this->_fleet['fleet_end_planet'],
					'fleet_start_type'			=> 1,
					'fleet_end_galaxy'			=> $this->_fleet['fleet_end_galaxy'],
					'fleet_end_system'			=> $this->_fleet['fleet_end_system'],
					'fleet_end_planet'			=> $this->_fleet['fleet_end_planet'],
					'fleet_end_type'			=> 1,
					'fleet_resource_metal'		=> 0,
					'fleet_resource_crystal'	=> 0,
					'fleet_resource_deuterium'	=> 0
				);

				$bonusList	= BuildFunctions::getBonusList();

				$fleetDefend[0]['player']	= $targetData;
				$fleetDefend[0]['player']['factor']	= ArrayUtil::combineArrayWithSingleElement($bonusList, 0);
				$fleetDefend[0]['unit']		= $targetFleetData;

				require_once 'includes/classes/missions/functions/calculateAttack.php';
				$combatResult	= calculateAttack($fleetAttack, $fleetDefend, $config->Fleet_Cdr, $config->Defs_Cdr);

				$fleetArray = '';
				$totalCount = 0;
				
				$fleetAttack[$fleetID]['unit']	= array_filter($fleetAttack[$fleetID]['unit']);
				foreach ($fleetAttack[$fleetID]['unit'] as $element => $amount)
				{
					$fleetArray .= $element.','.$amount.';';
					$totalCount += $amount;
				}

				if ($totalCount <= 0)
				{
					$this->KillFleet();
				}
				else
				{
					$this->UpdateFleet('fleet_array', substr($fleetArray, 0, -1));
					$this->UpdateFleet('fleet_amount', $totalCount);
				}

				require_once('includes/classes/missions/functions/GenerateReport.php');
			
			
				$debrisResource	= array(901, 902);
				$debris			= array();

				foreach($debrisResource as $elementID)
				{
					$debris[$elementID]			= 0;
				}
				
				$stealResource	= array(901 => 0, 902 => 0, 903 => 0);
			
				$reportInfo	= array(
					'thisFleet'				=> $this->_fleet,
					'debris'				=> $debris,
					'stealResource'			=> $stealResource,
					'moonChance'			=> 0,
					'moonDestroy'			=> false,
					'moonName'				=> NULL,
					'moonDestroyChance'		=> NULL,
					'moonDestroySuccess'	=> NULL,
					'fleetDestroyChance'	=> NULL,
					'fleetDestroySuccess'	=> NULL,
				);
				
				$reportData	= GenerateReport($combatResult, $reportInfo);
			
				$reportID	= md5(uniqid('', true).TIMESTAMP);

				$sql		= "INSERT INTO %%RW%% SET
				rid			= :reportId,
				raport		= :reportData,
				time		= :time,
				attacker	= :attacker;";

				Database::get()->insert($sql, array(
					':reportId'		=> $reportID,
					':reportData'	=> serialize($reportData),
					':time'			=> $this->_fleet['fleet_start_time'],
					':attacker'		=> $this->_fleet['fleet_owner'],
				));
			
				switch($combatResult['won'])
				{
					case "a":
						$attackClass	= 'raportWin';
						$defendClass	= 'raportLose';
					break;
					case "r":
						$attackClass	= 'raportLose';
						$defendClass	= 'raportWin';
					break;
					default:
						$attackClass	= 'raportDraw';
						$defendClass	= 'raportDraw';
					break;
				}

				$message	= sprintf($messageHTML,
					$reportID,
					$attackClass,
					$LNG['sys_mess_attack_report'],
					sprintf(
						$LNG['sys_adress_planet'],
						$this->_fleet['fleet_end_galaxy'],
						$this->_fleet['fleet_end_system'],
						$this->_fleet['fleet_end_planet']
					),
					$LNG['type_planet_short_'.$this->_fleet['fleet_end_type']],
					$LNG['sys_lost'],
					$attackClass,
					$LNG['sys_attack_attacker_pos'], pretty_number($combatResult['unitLost']['attacker']),
					$defendClass,
					$LNG['sys_attack_defender_pos'], pretty_number($combatResult['unitLost']['defender']),
					$LNG['sys_gain'],
					$LNG['tech'][901], pretty_number($stealResource[901]),
					$LNG['tech'][902], pretty_number($stealResource[902]),
					$LNG['tech'][903], pretty_number($stealResource[903]),
					$LNG['sys_debris'],
					$LNG['tech'][901], pretty_number($debris[901]),
					$LNG['tech'][902], pretty_number($debris[902])
				);

				// ============================================
				// ASTROIO v1.2 - Mini Torneos: victoria vs Aliens/Piratas
				// Torneos: 5 (expe exitosa), 8 (Aliens/Piratas)
				// ============================================
				if (isset($combatResult['won']) && $combatResult['won'] == 'a') {
					tournement($this->_fleet['fleet_owner'], 5, 1); // Torneo 5: expe exitosa
					tournement($this->_fleet['fleet_owner'], 8, 1); // Torneo 8: Aliens/Piratas
				}
				// ============================================
				
				PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 3,
					$LNG['sys_mess_attack_report'], $message, $this->_fleet['fleet_end_stay']);

			break;
			case 5:
				// ============================================
				// ASTROIO v1.2 - Mini Torneos: flota perdida en agujero negro
				// Torneo: 2
				// ============================================
				tournement($this->_fleet['fleet_owner'], 2, 1);
				// ============================================

				$this->KillFleet();
				$Message	= $LNG['sys_expe_lost_fleet_'.mt_rand(1,4)];
			break;
			case 6:
				# http://owiki.de/Expedition#Ver.C3.A4nderte_Flugzeit
				$chance	= mt_rand(0, 100);

				$Wrapper	= array();
				$Wrapper[]	= 2;
				$Wrapper[]	= 2;
				$Wrapper[]	= 2;
				$Wrapper[]	= 2;
				$Wrapper[]	= 2;
				$Wrapper[]	= 2;
				$Wrapper[]	= 2;
				$Wrapper[]	= 3;
				$Wrapper[]	= 3;
				$Wrapper[]	= 5;
			
				if($chance < 75)
				{
					// More return time

					$normalBackTime	= $this->_fleet['fleet_end_time'] - $this->_fleet['fleet_end_stay'];
					$stayTime		= $this->_fleet['fleet_end_stay'] - $this->_fleet['fleet_start_time'];
					$factor			= $Wrapper[mt_rand(0, 9)];

					$endTime		= $this->_fleet['fleet_end_stay'] + $normalBackTime + $stayTime + $factor;
					$this->UpdateFleet('fleet_end_time', $endTime);
					$Message = $LNG['sys_expe_time_slow_'.mt_rand(1,6)];
				}
				else
				{
					$normalBackTime	= $this->_fleet['fleet_end_time'] - $this->_fleet['fleet_end_stay'];
					$stayTime		= $this->_fleet['fleet_end_stay'] - $this->_fleet['fleet_start_time'];
					$factor			= $Wrapper[mt_rand(0, 9)];

					$endTime		= max(1, $normalBackTime - $stayTime / 3 * $factor);
					$this->UpdateFleet('fleet_end_time', $endTime);
					$Message = $LNG['sys_expe_time_fast_'.mt_rand(1,3)];
				}
			break;
		}

		// ============================================
		// ASTROIO - Drop de Contenedores al volver de expedición
		// 25% de probabilidad · 1-5 contenedores · Al jugador
		// Se ejecuta SIEMPRE, sin importar el resultado (cases 1-9).
		// ------------------------------------------------------------
		// ASTROIO v1.4 - FIX: usa %%USERS%% (prefijo correcto vía wrapper)
		// en lugar de $prefix hardcodeado 'uni1_', y try/catch para no
		// romper la expedición si el UPDATE falla (tabla inexistente,
		// deadlock, etc.). El guard de idempotencia de arriba ya impide
		// que este bloque se ejecute dos veces por la misma flota.
		// ============================================
		$containerDrop	= 0;
		$dropChance		= mt_rand(1, 100);

		if ($dropChance <= 25) {
			$containerDrop	= mt_rand(1, 5);

			try {
				$db = Database::get();
				$db->update(
					"UPDATE %%USERS%% SET `containers` = `containers` + :add WHERE `id` = :uid;",
					array(
						':add' => (int) $containerDrop,
						':uid' => (int) $this->_fleet['fleet_owner'],
					)
				);

				$Message	.= '<br><br>🎁 <strong>¡Has encontrado '.$containerDrop.' contenedor'.($containerDrop > 1 ? 'es' : '').'!</strong>';
			} catch (Exception $e) {
				// No romper la expedición por un fallo del UPDATE
				$containerDrop = 0;
			}
		}
		// ============================================

		// ============================================
		// ASTROIO v1.5 - Drop de Cofres Climáticos al volver de expedición
		// ------------------------------------------------------------
		// Roll único jerárquico de 0.01 a 100.00:
		//   roll ≤ 0.5      → cofre climático MAYOR   (0.5%)
		//   0.5 < roll ≤ 2  → cofre climático MENOR   (1.5%)
		//   roll > 2        → nada                    (98%)
		// Total: 2.0% de drop, con 0.5% para el mayor.
		// El cofre de DOMINIO NO cae en expedición (solo tienda/MN).
		//
		// Se ejecuta SIEMPRE, sin importar el resultado (cases 1-9).
		// Usa prefix manual (no %%USERS_MARKET%%) para no depender de
		// un wrapper que podría no existir en este fork.
		// try/catch para no romper la expedición si el INSERT falla.
		// ============================================
		$climateDrop = null;
		$climateRoll = mt_rand(1, 10000) / 100; // 0.01 a 100.00

		if ($climateRoll <= 2.0) {
			if ($climateRoll <= 0.5) {
				$climateDrop = 'major';
				$climateCol  = 'box_climate_major';
				$climateName = 'Cofre Climático Mayor';
			} else {
				$climateDrop = 'minor';
				$climateCol  = 'box_climate_minor';
				$climateName = 'Cofre Climático Menor';
			}

			try {
				$db = Database::get();
				$prefix = 'uni1_';
				if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
				elseif (defined('PREFIX')) $prefix = PREFIX;

				$db->insert(
					"INSERT INTO `".$prefix."users_market` (user_id, `".$climateCol."`)
					 VALUES (:uid, 1)
					 ON DUPLICATE KEY UPDATE `".$climateCol."` = `".$climateCol."` + 1",
					array(
						':uid' => (int) $this->_fleet['fleet_owner'],
					)
				);

				$Message	.= '<br><br>🌦️ <strong>¡Has encontrado un '.$climateName.'!</strong>';
			} catch (Exception $e) {
				// No romper la expedición por un fallo del INSERT
				$climateDrop = null;
			}
		}
		// ============================================

		// ============================================
		// ASTROIO - Actualizar progreso del evento "Expediciones"
		// ============================================
		if (class_exists('EventHelper')) {
			EventHelper::updateProgress($this->_fleet['fleet_owner'], 'expeditions', 1);
		}
		// ============================================

		PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 15,
			$LNG['sys_expe_report'], $Message, $this->_fleet['fleet_end_stay'], NULL, 1, $this->_fleet['fleet_universe']);

		// ============================================
		// ASTROIO v1.4 - Se mantienen setState + SaveFleet:
		//  - setState(FLEET_RETURN) fija eventTime = fleet_end_time
		//    (necesario para que SaveFleet actualice %%FLEETS_EVENT%%,
		//    sobre todo si case 6 modificó fleet_end_time).
		//  - SaveFleet() escribe todos los _upd (recursos, MO, naves,
		//    fleet_end_time) y vuelve a escribir fleet_mess = RETURN.
		//    El doble UPDATE de fleet_mess (guard + SaveFleet) es
		//    idempotente (1 → 1) y no causa ningún problema.
		// ============================================
		$this->setState(FLEET_RETURN);
		$this->SaveFleet();
	}
	
	function ReturnEvent()
	{
		$LNG		= $this->getLanguage(NULL, $this->_fleet['fleet_owner']);
		$Message 	= sprintf(
			$LNG['sys_expe_back_home'],
			$LNG['tech'][901], pretty_number($this->_fleet['fleet_resource_metal']),
			$LNG['tech'][902], pretty_number($this->_fleet['fleet_resource_crystal']),
			$LNG['tech'][903], pretty_number($this->_fleet['fleet_resource_deuterium']),
			$LNG['tech'][921], pretty_number($this->_fleet['fleet_resource_darkmatter'])
		);

		PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 4, $LNG['sys_mess_fleetback'],
			$Message, $this->_fleet['fleet_end_time'], NULL, 1, $this->_fleet['fleet_universe']);

		$this->RestoreFleet();
	}
}
?>