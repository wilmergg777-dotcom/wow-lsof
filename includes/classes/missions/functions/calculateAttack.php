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
 * AstroIO v3.5 (FASE 9 PvP):
 *  - Al final del combate, si la flota atacante tiene pvp_type != 'none'
 *    en uni1_fleets, se registra el daño en pvp_arena_attacks o
 *    pvp_tournament_attacks.
 *  - Se registran 2 FILAS por combate:
 *      A) atacante -> defensor  (fleet_id = flota real)
 *      B) defensor -> atacante  (fleet_id = 0, el defensor no tiene flota)
 *    Esto permite que el daño del defensor tambien cuente en el ranking
 *    de la arena (antes solo contaba el daño del atacante y el defensor
 *    aparecia siempre con 0).
 *  - Metrica: CANTIDAD DE UNIDADES destruidas (no recursos).
 *      ships_destroyed    = naves destruidas
 *      defenses_destroyed = defensas destruidas
 *      damage_done        = ships_destroyed + defenses_destroyed
 *  - Guard anti-duplicado por (arena_id, attacker_id, defender_id, fleet_id).
 *  - Solo la PRIMERA flota con pvp_type != 'none' registra (evita duplicar
 *    el dano si hay varias flotas atacantes en el mismo combate).
 *  - Bloque en try/catch para no romper el combate por un error de PvP.
 *
 * AstroIO v3.6 (VIP Bonus):
 *  - Se anaden los bonus VIP (ataque/defensa/escudo) al combate.
 *  - Se cargan desde VIPHelper::getBonus($userId, $type)
 *  - Atacante: bonus VIP de ataque, defensa y escudo.
 *  - Defensor: bonus VIP de ataque, defensa y escudo.
 *  - Se suman al mismo nivel que los bonus de razas y del arbol de talentos.
 *
 * AstroIO v3.7 (POT. ESPÍA):
 *  - El Pot. Espía NO aplica en este archivo.
 *  - El bonus de espionaje se aplica en MissionCaseSpy.class.php
 *  - Aquí solo se conserva la lógica de combate intacta.
 *
 * AstroIO v4.0 (MEJORAS DE COMBATE):
 *  - Se integra ImprovementHelper para aplicar Ataque, Defensa (Blindaje),
 *    Escudo, Cadencia (Disparo doble) y Precisión (Daño extra).
 *  - Se añade cache estática para evitar múltiples consultas SQL.
 *
 * AstroIO v4.1 (MÍSTICOS):
 *  - Se integra MisticHelper para aplicar los bonus de los Elementos Místicos.
 *  - Ataque, Defensa y Escudo de los Místicos se suman a las tecnologías base.
 */

// ============================================
// ASTROIO - Cargar AllianceTalentHelper explicitamente
// ============================================
if (!class_exists('AllianceTalentHelper')) {
    require_once ROOT_PATH . 'includes/classes/AllianceTalentHelper.class.php';
}
// ============================================

// ============================================
// ASTROIO - Cargar VIPHelper explicitamente
// ============================================
if (!class_exists('VIPHelper')) {
    $__vipFile = ROOT_PATH . 'includes/classes/VIPHelper.class.php';
    if (file_exists($__vipFile)) {
        require_once $__vipFile;
    }
}
// ============================================

// ============================================
// ASTROIO - Cargar ImprovementHelper explicitamente
// ============================================
if (!class_exists('ImprovementHelper')) {
    $__impFile = ROOT_PATH . 'includes/classes/ImprovementHelper.class.php';
    if (file_exists($__impFile)) {
        require_once $__impFile;
    }
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


function calculateAttack(&$attackers, &$defenders, $FleetTF, $DefTF)
{
	global $pricelist, $CombatCaps, $resource;

	$TRES 	= array('attacker' => 0, 'defender' => 0);
	$ARES 	= $DRES = array('metal' => 0, 'crystal' => 0);
	$ROUND	= array();
	$RF		= array();

	$attackAmount = array();
	$defenseAmount = array();
	$STARTDEF = array();
	
	// Caché para no saturar la BD con consultas de mejoras
	static $impBonusesCache = array();
	// Caché para no saturar la BD con consultas de místicos
	static $misticBonusesCache = array();

	foreach ($attackers as $fleetID => $attacker) 
	{
		foreach ($attacker['unit'] as $element => $amount) 
		{
			$ARES['metal'] 		+= $pricelist[$element]['cost'][901] * $amount;
			$ARES['crystal'] 	+= $pricelist[$element]['cost'][902] * $amount;
		}
	}

	foreach($CombatCaps as $e => $arr) {
		if(!isset($arr['sd'])) continue;
		
		foreach($arr['sd'] as $t => $sd) {
			if($sd == 0) continue;
			$RF[$t][$e] = $sd;
		}
	}
	
	$TRES['attacker']	= $ARES['metal'] + $ARES['crystal'];

	foreach ($defenders as $fleetID => $defender) 
	{
		foreach ($defender['unit'] as $element => $amount)
		{
			if ($element < 300) {
				$DRES['metal'] 		+= $pricelist[$element]['cost'][901] * $amount;
				$DRES['crystal'] 	+= $pricelist[$element]['cost'][902] * $amount ;

				$TRES['defender'] 	+= $pricelist[$element]['cost'][901] * $amount;
				$TRES['defender'] 	+= $pricelist[$element]['cost'][902] * $amount;
			} else {
				if (!isset($STARTDEF[$element])) 
					$STARTDEF[$element] = 0;
				
				$STARTDEF[$element] += $amount;

				$TRES['defender']	+= $pricelist[$element]['cost'][901] * $amount;
				$TRES['defender']	+= $pricelist[$element]['cost'][902] * $amount;
			}
		}
	}
	
	for ($ROUNDC = 0; $ROUNDC <= MAX_ATTACK_ROUNDS; $ROUNDC++) 
	{
		$attackDamage  = array('total' => 0);
		$attackShield  = array('total' => 0);
		$attackAmount  = array('total' => 0);
		$defenseDamage = array('total' => 0);
		$defenseShield = array('total' => 0);
		$defenseAmount = array('total' => 0);
		$attArray = array();
		$defArray = array();

		foreach ($attackers as $fleetID => $attacker) {
			$attackDamage[$fleetID] = 0;
			$attackShield[$fleetID] = 0;
			$attackAmount[$fleetID] = 0;

			// ============================================
			// ASTROIO - Bonos de razas/facciones del atacante
			// ============================================
			$raceAttack  = 0;
			$raceDefense = 0;
			$raceShield  = 0;
			
			if (isset($attacker['player']['id']) && class_exists('RaceFactionHelper')) {
				$raceAttack  = RaceFactionHelper::getBonus($attacker['player']['id'], 'bonus_attack') / 100;
				$raceDefense = RaceFactionHelper::getBonus($attacker['player']['id'], 'bonus_defense') / 100;
				$raceShield  = RaceFactionHelper::getBonus($attacker['player']['id'], 'bonus_shield') / 100;
			}
			// ============================================

			// ============================================
			// ASTROIO - Bonos del Arbol de Talentos del atacante
			// ============================================
			$bankAttack  = 0;
			$bankDefense = 0;

			if (isset($attacker['player']['id']) && class_exists('AllianceTalentHelper')) {
				$allyBonuses	= AllianceTalentHelper::getBonusesForUserCached($attacker['player']['id']);
				$bankAttack		= (float)$allyBonuses['attack'];
				$bankDefense	= (float)$allyBonuses['defense'];
			}
			// ============================================

			// ============================================
			// ASTROIO - Bonos VIP del atacante
			// ============================================
			$vipAttack  = 0;
			$vipDefense = 0;
			$vipShield  = 0;

			if (isset($attacker['player']['id']) && class_exists('VIPHelper')) {
				$vipAttack  = (float) VIPHelper::getBonus($attacker['player']['id'], 'attack');
				$vipDefense = (float) VIPHelper::getBonus($attacker['player']['id'], 'defense');
				$vipShield  = (float) VIPHelper::getBonus($attacker['player']['id'], 'shield');
			}
			// ============================================

			// ============================================
			// ASTROIO - Bonos Místicos del atacante
			// ============================================
			$misticAttack  = 0;
			$misticDefense = 0;
			$misticShield  = 0;

			if (isset($attacker['player']['id']) && class_exists('MisticHelper')) {
				$cacheKeyM = 'mistic_' . $attacker['player']['id'];
				if (!isset($misticBonusesCache[$cacheKeyM])) {
					$misticBonusesCache[$cacheKeyM] = MisticHelper::getBonuses($attacker['player']['id']);
				}
				$misticBonus = $misticBonusesCache[$cacheKeyM];
				
				$misticAttack  = isset($misticBonus['ataque']) ? ($misticBonus['ataque'] / 100) : 0;
				$misticDefense = isset($misticBonus['defensa']) ? ($misticBonus['defensa'] / 100) : 0;
				$misticShield  = isset($misticBonus['escudo']) ? ($misticBonus['escudo'] / 100) : 0;
			}
			// ============================================

			$attTech	= (1 + (0.1 * $attacker['player']['military_tech']) + $attacker['player']['factor']['Attack'] + $raceAttack + $bankAttack + $vipAttack + $misticAttack); //attaque
			$defTech	= (1 + (0.1 * $attacker['player']['defence_tech']) + $attacker['player']['factor']['Defensive'] + $raceDefense + $bankDefense + $vipDefense + $misticDefense); //bouclier
			$shieldTech = (1 + (0.1 * $attacker['player']['shield_tech']) + $attacker['player']['factor']['Shield'] + $raceShield + $vipShield + $misticShield); //coque
			$attackers[$fleetID]['techs'] = array($attTech, $defTech, $shieldTech);
				
			foreach ($attacker['unit'] as $element => $amount) {
				$thisAtt	= $amount * ($CombatCaps[$element]['attack']) * $attTech * (rand(80, 120) / 100); //attaque
				$thisDef	= $amount * ($CombatCaps[$element]['shield']) * $defTech ; //bouclier
				$thisShield	= $amount * ($pricelist[$element]['cost'][901] + $pricelist[$element]['cost'][902]) / 10 * $shieldTech; //coque

				// ============================================
				// ASTROIO - Aplicar Bonos de Mejoras (Atacante)
				// ============================================
				if (isset($attacker['player']['id']) && class_exists('ImprovementHelper')) {
					$cacheKey = 'a_' . $attacker['player']['id'] . '_' . $element;
					if (!isset($impBonusesCache[$cacheKey])) {
						$impBonusesCache[$cacheKey] = ImprovementHelper::getBonuses($attacker['player']['id'], $element);
					}
					$imp = $impBonusesCache[$cacheKey];

					// Ataque, Escudo, Defensa (Blindaje)
					$thisAtt    *= $imp['ataque'];
					$thisDef    *= $imp['escudo'];
					$thisShield *= $imp['defensa'];

					// Precisión: Aumenta el daño final
					if (isset($imp['precision']) && $imp['precision'] > 1.0) {
						$thisAtt *= $imp['precision'];
					}

					// Cadencia: Probabilidad de disparo doble
					if (isset($imp['cadencia']) && $imp['cadencia'] > 1.0) {
						$cadenciaChance = ($imp['cadencia'] - 1.0) * 100;
						if (rand(1, 100) <= $cadenciaChance) {
							$thisAtt *= 2; // Disparo doble
						}
					}
				}
				// ============================================

				$attArray[$fleetID][$element] = array('def' => $thisDef, 'shield' => $thisShield, 'att' => $thisAtt);

				$attackDamage[$fleetID] += $thisAtt;
				$attackDamage['total'] += $thisAtt;
				$attackShield[$fleetID] += $thisDef;
				$attackShield['total'] += $thisDef;
				$attackAmount[$fleetID] += $amount;
				$attackAmount['total'] += $amount;
			}
		}

		foreach ($defenders as $fleetID => $defender) {
			$defenseDamage[$fleetID] = 0;
			$defenseShield[$fleetID] = 0;
			$defenseAmount[$fleetID] = 0;

			// ============================================
			// ASTROIO - Bonos de razas/facciones del defensor
			// ============================================
			$raceAttack  = 0;
			$raceDefense = 0;
			$raceShield  = 0;
			
			if (isset($defender['player']['id']) && class_exists('RaceFactionHelper')) {
				$raceAttack  = RaceFactionHelper::getBonus($defender['player']['id'], 'bonus_attack') / 100;
				$raceDefense = RaceFactionHelper::getBonus($defender['player']['id'], 'bonus_defense') / 100;
				$raceShield  = RaceFactionHelper::getBonus($defender['player']['id'], 'bonus_shield') / 100;
			}
			// ============================================

			// ============================================
			// ASTROIO - Bonos del Arbol de Talentos del defensor
			// ============================================
			$bankAttack  = 0;
			$bankDefense = 0;

			if (isset($defender['player']['id']) && class_exists('AllianceTalentHelper')) {
				$allyBonuses	= AllianceTalentHelper::getBonusesForUserCached($defender['player']['id']);
				$bankAttack		= (float)$allyBonuses['attack'];
				$bankDefense	= (float)$allyBonuses['defense'];
			}
			// ============================================

			// ============================================
			// ASTROIO - Bonos VIP del defensor
			// ============================================
			$vipAttack  = 0;
			$vipDefense = 0;
			$vipShield  = 0;

			if (isset($defender['player']['id']) && class_exists('VIPHelper')) {
				$vipAttack  = (float) VIPHelper::getBonus($defender['player']['id'], 'attack');
				$vipDefense = (float) VIPHelper::getBonus($defender['player']['id'], 'defense');
				$vipShield  = (float) VIPHelper::getBonus($defender['player']['id'], 'shield');
			}
			// ============================================

			// ============================================
			// ASTROIO - Bonos Místicos del defensor
			// ============================================
			$misticAttack  = 0;
			$misticDefense = 0;
			$misticShield  = 0;

			if (isset($defender['player']['id']) && class_exists('MisticHelper')) {
				$cacheKeyM = 'mistic_' . $defender['player']['id'];
				if (!isset($misticBonusesCache[$cacheKeyM])) {
					$misticBonusesCache[$cacheKeyM] = MisticHelper::getBonuses($defender['player']['id']);
				}
				$misticBonus = $misticBonusesCache[$cacheKeyM];
				
				$misticAttack  = isset($misticBonus['ataque']) ? ($misticBonus['ataque'] / 100) : 0;
				$misticDefense = isset($misticBonus['defensa']) ? ($misticBonus['defensa'] / 100) : 0;
				$misticShield  = isset($misticBonus['escudo']) ? ($misticBonus['escudo'] / 100) : 0;
			}
			// ============================================

			$attTech	= (1 + (0.1 * $defender['player']['military_tech']) + $defender['player']['factor']['Attack'] + $raceAttack + $bankAttack + $vipAttack + $misticAttack); //attaquue
			$defTech	= (1 + (0.1 * $defender['player']['defence_tech']) + $defender['player']['factor']['Defensive'] + $raceDefense + $bankDefense + $vipDefense + $misticDefense); //bouclier
			$shieldTech = (1 + (0.1 * $defender['player']['shield_tech']) + $defender['player']['factor']['Shield'] + $raceShield + $vipShield + $misticShield); //coque
			$defenders[$fleetID]['techs'] = array($attTech, $defTech, $shieldTech);

			foreach ($defender['unit'] as $element => $amount) {
				$thisAtt	= $amount * ($CombatCaps[$element]['attack']) * $attTech * (rand(80, 120) / 100); //attaque
				$thisDef	= $amount * ($CombatCaps[$element]['shield']) * $defTech ; //bouclier
				$thisShield	= $amount * ($pricelist[$element]['cost'][901] + $pricelist[$element]['cost'][902]) / 10 * $shieldTech; //coque

				if ($element == 407 || $element == 408 || $element == 409) $thisAtt = 0;

				// ============================================
				// ASTROIO - Aplicar Bonos de Mejoras (Defensor)
				// ============================================
				if (isset($defender['player']['id']) && class_exists('ImprovementHelper')) {
					$cacheKey = 'd_' . $defender['player']['id'] . '_' . $element;
					if (!isset($impBonusesCache[$cacheKey])) {
						$impBonusesCache[$cacheKey] = ImprovementHelper::getBonuses($defender['player']['id'], $element);
					}
					$imp = $impBonusesCache[$cacheKey];

					// Ataque, Escudo, Defensa (Blindaje)
					$thisAtt    *= $imp['ataque'];
					$thisDef    *= $imp['escudo'];
					$thisShield *= $imp['defensa'];

					// Precisión: Aumenta el daño final
					if (isset($imp['precision']) && $imp['precision'] > 1.0) {
						$thisAtt *= $imp['precision'];
					}

					// Cadencia: Probabilidad de disparo doble
					if (isset($imp['cadencia']) && $imp['cadencia'] > 1.0) {
						$cadenciaChance = ($imp['cadencia'] - 1.0) * 100;
						if (rand(1, 100) <= $cadenciaChance) {
							$thisAtt *= 2; // Disparo doble
						}
					}
				}
				// ============================================

				$defArray[$fleetID][$element] = array('def' => $thisDef, 'shield' => $thisShield, 'att' => $thisAtt);

				$defenseDamage[$fleetID] += $thisAtt;
				$defenseDamage['total'] += $thisAtt;
				$defenseShield[$fleetID] += $thisDef;
				$defenseShield['total'] += $thisDef;
				$defenseAmount[$fleetID] += $amount;
				$defenseAmount['total'] += $amount;
			}
		}

		$ROUND[$ROUNDC] = array('attackers' => $attackers, 'defenders' => $defenders, 'attackA' => $attackAmount, 'defenseA' => $defenseAmount, 'infoA' => $attArray, 'infoD' => $defArray);

		if ($ROUNDC >= MAX_ATTACK_ROUNDS || $defenseAmount['total'] <= 0 || $attackAmount['total'] <= 0) {
			break;
		}

		// Calculate hit percentages (ACS only but ok)
		$attackPct = array();
		foreach ($attackAmount as $fleetID => $amount) {
			if (!is_numeric($fleetID)) continue;
				$attackPct[$fleetID] = $amount / $attackAmount['total'];
		}

		$defensePct = array();
		foreach ($defenseAmount as $fleetID => $amount) {
			if (!is_numeric($fleetID)) continue;
				$defensePct[$fleetID] = $amount / $defenseAmount['total'];
		}

		// CALCUL DES PERTES !!!
		$attacker_n = array();
		$attacker_shield = 0;
		$defenderAttack	= 0;
		foreach ($attackers as $fleetID => $attacker) {
			$attacker_n[$fleetID] = array();

			foreach($attacker['unit'] as $element => $amount) {
				if ($amount <= 0) {
					$attacker_n[$fleetID][$element] = 0;
					continue;
				}

				$defender_moc = $amount * ($defenseDamage['total'] * $attackPct[$fleetID]) / $attackAmount[$fleetID];
			
				if(isset($RF[$element])) {
					foreach($RF[$element] as $shooter => $shots) {
						foreach($defArray as $fID => $rfdef) {
							if(empty($rfdef[$shooter]['att']) || $attackAmount[$fleetID] <= 0) continue;

							$defender_moc += $rfdef[$shooter]['att'] * $shots / ($amount / $attackAmount[$fleetID] * $attackPct[$fleetID]);
							$defenseAmount['total'] += $defenders[$fID]['unit'][$shooter] * $shots;
						}
					}
				}
				
				$defenderAttack	+= $defender_moc;
				
				if (($attArray[$fleetID][$element]['def'] / $amount) >= $defender_moc) {
					$attacker_n[$fleetID][$element] = round($amount);
					$attacker_shield += $defender_moc;
					continue;
				}

				$max_removePoints = floor($amount * $defenseAmount['total'] / $attackAmount[$fleetID] * $attackPct[$fleetID]);

				$attacker_shield += min($attArray[$fleetID][$element]['def'], $defender_moc);
				$defender_moc 	 -= min($attArray[$fleetID][$element]['def'], $defender_moc);

				$ile_removePoints = max(min($max_removePoints, $amount * min($defender_moc / $attArray[$fleetID][$element]['shield'] * (rand(0, 200) / 100), 1)), 0);

				$attacker_n[$fleetID][$element] = max(ceil($amount - $ile_removePoints), 0);
			}
		}

		$defender_n = array();
		$defender_shield = 0;
		$attackerAttack	= 0;
		foreach ($defenders as $fleetID => $defender) {
			$defender_n[$fleetID] = array();

			foreach($defender['unit'] as $element => $amount) {
				if ($amount <= 0) {
					$defender_n[$fleetID][$element] = 0;
					continue;
				}

				$attacker_moc = $amount * ($attackDamage['total'] * $defensePct[$fleetID]) / $defenseAmount[$fleetID];
				if (isset($RF[$element])) {
					foreach($RF[$element] as $shooter => $shots) {
						foreach($attArray as $fID => $rfatt) {
							if (empty($rfatt[$shooter]['att']) || $defenseAmount[$fleetID] <= 0 ) continue;

							$attacker_moc += $rfatt[$shooter]['att'] * $shots / ($amount / $defenseAmount[$fleetID] * $defensePct[$fleetID]);
							$attackAmount['total'] += $attackers[$fID]['unit'][$shooter] * $shots;
						}
					}
				}
				
				$attackerAttack	+= $attacker_moc;
				
				if (($defArray[$fleetID][$element]['def'] / $amount) >= $attacker_moc) {
					$defender_n[$fleetID][$element] = round($amount);
					$defender_shield += $attacker_moc;
					continue;
				}
	
				$max_removePoints = floor($amount * $attackAmount['total'] / $defenseAmount[$fleetID] * $defensePct[$fleetID]);
				$defender_shield += min($defArray[$fleetID][$element]['def'], $attacker_moc);
				$attacker_moc 	 -= min($defArray[$fleetID][$element]['def'], $attacker_moc);
				
				$ile_removePoints = max(min($max_removePoints, $amount * min($attacker_moc / $defArray[$fleetID][$element]['shield'] * (rand(0, 200) / 100), 1)), 0);

				$defender_n[$fleetID][$element] = max(ceil($amount - $ile_removePoints), 0);
			}
		}
		
		$ROUND[$ROUNDC]['attack'] 		= $attackerAttack;
		$ROUND[$ROUNDC]['defense'] 		= $defenderAttack;
		$ROUND[$ROUNDC]['attackShield'] = $attacker_shield;
		$ROUND[$ROUNDC]['defShield'] 	= $defender_shield;
		foreach ($attackers as $fleetID => $attacker) {
			$attackers[$fleetID]['unit'] = array_map('round', $attacker_n[$fleetID]);
		}

		foreach ($defenders as $fleetID => $defender) {
			$defenders[$fleetID]['unit'] = array_map('round', $defender_n[$fleetID]);
		}
	}
	
	if ($attackAmount['total'] <= 0 && $defenseAmount['total'] > 0) {
		$won = "r"; // defender
	} elseif ($attackAmount['total'] > 0 && $defenseAmount['total'] <= 0) {
		$won = "a"; // attacker
	} else {
		$won = "w"; // draw
	}

	// ============================================
	// ASTROIO — FASE 9 PvP v3.5: Registrar daño en arena/torneo
	// ============================================
	try {
		if (!empty($ROUND[0])) {
			$pvpDb = Database::get();

			if (!class_exists('PVPArenaHelper')) {
				$__pvpFile = ROOT_PATH . 'includes/classes/PVPArenaHelper.class.php';
				if (file_exists($__pvpFile)) {
					require_once $__pvpFile;
				}
			}
			if (!class_exists('PVPTournamentHelper')) {
				$__pvpFile = ROOT_PATH . 'includes/classes/PVPTournamentHelper.class.php';
				if (file_exists($__pvpFile)) {
					require_once $__pvpFile;
				}
			}

			$pvpDefShipsDestroyed    = 0;
			$pvpDefDefensesDestroyed = 0;

			$__initialDefenders = isset($ROUND[0]['defenders']) ? $ROUND[0]['defenders'] : array();
			foreach ($__initialDefenders as $__defFleetId => $__defData) {
				if (!is_numeric($__defFleetId)) continue;

				$__initialUnits = isset($__defData['unit']) ? $__defData['unit'] : array();
				$__finalUnits   = isset($defenders[$__defFleetId]['unit']) ? $defenders[$__defFleetId]['unit'] : array();

				foreach ($__initialUnits as $__element => $__initialAmt) {
					$__initialAmt = (int) $__initialAmt;
					$__finalAmt   = isset($__finalUnits[$__element]) ? (int) $__finalUnits[$__element] : 0;
					$__lost       = max(0, $__initialAmt - $__finalAmt);
					if ($__lost <= 0) continue;

					if ($__element < 300) {
						$pvpDefShipsDestroyed += $__lost;
					} else {
						$pvpDefDefensesDestroyed += $__lost;
					}
				}
			}

			$pvpAttShipsDestroyed = 0;

			$__initialAttackers = isset($ROUND[0]['attackers']) ? $ROUND[0]['attackers'] : array();
			foreach ($__initialAttackers as $__attFleetId => $__attData) {
				if (!is_numeric($__attFleetId)) continue;

				$__initialUnits = isset($__attData['unit']) ? $__attData['unit'] : array();
				$__finalUnits   = isset($attackers[$__attFleetId]['unit']) ? $attackers[$__attFleetId]['unit'] : array();

				foreach ($__initialUnits as $__element => $__initialAmt) {
					$__initialAmt = (int) $__initialAmt;
					$__finalAmt   = isset($__finalUnits[$__element]) ? (int) $__finalUnits[$__element] : 0;
					$__lost       = max(0, $__initialAmt - $__finalAmt);
					if ($__lost <= 0) continue;

					$pvpAttShipsDestroyed += $__lost;
				}
			}

			if ($pvpDefShipsDestroyed > 0 || $pvpDefDefensesDestroyed > 0 || $pvpAttShipsDestroyed > 0) {

				$__registered = false;

				foreach ($attackers as $__attFleetId => $__attackerData) {
					if ($__registered) break;
					if (!is_numeric($__attFleetId)) continue;

					$__pvpRow = $pvpDb->selectSingle(
						"SELECT `pvp_type`, `pvp_ref_id`, `pvp_match_id`, `fleet_owner`, `fleet_target_owner`
						 FROM %%FLEETS%% WHERE `fleet_id` = :fid LIMIT 1;",
						array(':fid' => (int) $__attFleetId)
					);

					if (empty($__pvpRow) || $__pvpRow['pvp_type'] === 'none') {
						continue;
					}

					$__attackerId = (int) $__pvpRow['fleet_owner'];
					$__defenderId = (int) $__pvpRow['fleet_target_owner'];
					$__refId      = (int) $__pvpRow['pvp_ref_id'];

					if ($__pvpRow['pvp_type'] === 'arena' && class_exists('PVPArenaHelper')) {

						$__checkArena = PVPArenaHelper::areInSameArena($__attackerId, $__defenderId);
						if ((int) $__checkArena <= 0 || (int) $__checkArena !== $__refId) {
							continue;
						}

						$__dupA = $pvpDb->selectSingle(
							"SELECT `id` FROM %%PVP_ARENA_ATTACKS%% 
							 WHERE `arena_id` = :aid 
							   AND `attacker_id` = :att 
							   AND `defender_id` = :def 
							   AND `fleet_id` = :fid 
							 LIMIT 1;",
							array(
								':aid' => $__refId,
								':att' => $__attackerId,
								':def' => $__defenderId,
								':fid' => (int) $__attFleetId,
							)
						);
						if (empty($__dupA)) {
							PVPArenaHelper::registerAttack(
								$__refId,
								$__attackerId,
								$__defenderId,
								(int) $__attFleetId,
								$pvpDefShipsDestroyed,
								$pvpDefDefensesDestroyed,
								$pvpDefShipsDestroyed + $pvpDefDefensesDestroyed
							);
						}

						$__dupB = $pvpDb->selectSingle(
							"SELECT `id` FROM %%PVP_ARENA_ATTACKS%% 
							 WHERE `arena_id` = :aid 
							   AND `attacker_id` = :att 
							   AND `defender_id` = :def 
							   AND `fleet_id` = 0 
							 LIMIT 1;",
							array(
								':aid' => $__refId,
								':att' => $__defenderId,
								':def' => $__attackerId,
							)
						);
						if (empty($__dupB)) {
							PVPArenaHelper::registerAttack(
								$__refId,
								$__defenderId,
								$__attackerId,
								0,
								$pvpAttShipsDestroyed,
								0,
								$pvpAttShipsDestroyed
							);
						}

						$__registered = true;

					} elseif ($__pvpRow['pvp_type'] === 'tournament' && class_exists('PVPTournamentHelper')) {

						$__dupA = $pvpDb->selectSingle(
							"SELECT `id` FROM %%PVP_TOURNAMENT_ATTACKS%% 
							 WHERE `tournament_id` = :tid 
							   AND `attacker_id` = :att 
							   AND `defender_id` = :def 
							   AND `fleet_id` = :fid 
							 LIMIT 1;",
							array(
								':tid' => $__refId,
								':att' => $__attackerId,
								':def' => $__defenderId,
								':fid' => (int) $__attFleetId,
							)
						);
						if (empty($__dupA)) {
							PVPTournamentHelper::registerAttack(
								$__refId,
								(int) $__pvpRow['pvp_match_id'],
								$__attackerId,
								$__defenderId,
								(int) $__attFleetId,
								$pvpDefShipsDestroyed,
								$pvpDefDefensesDestroyed,
								$pvpDefShipsDestroyed + $pvpDefDefensesDestroyed
							);
						}

						$__dupB = $pvpDb->selectSingle(
							"SELECT `id` FROM %%PVP_TOURNAMENT_ATTACKS%% 
							 WHERE `tournament_id` = :tid 
							   AND `attacker_id` = :att 
							   AND `defender_id` = :def 
							   AND `fleet_id` = 0 
							 LIMIT 1;",
							array(
								':tid' => $__refId,
								':att' => $__defenderId,
								':def' => $__attackerId,
							)
						);
						if (empty($__dupB)) {
							PVPTournamentHelper::registerAttack(
								$__refId,
								(int) $__pvpRow['pvp_match_id'],
								$__defenderId,
								$__attackerId,
								0,
								$pvpAttShipsDestroyed,
								0,
								$pvpAttShipsDestroyed
							);
						}

						$__registered = true;
					}
				}
			}
		}
	} catch (Exception $e) {
		// Silencioso — un error PvP nunca debe romper el combate
	}
	// ============================================

	// CDR
	foreach ($attackers as $fleetID => $attacker) {					   // flotte attaquant en CDR
		foreach ($attacker['unit'] as $element => $amount) {
			$TRES['attacker'] -= $pricelist[$element]['cost'][901] * $amount ;
			$TRES['attacker'] -= $pricelist[$element]['cost'][902] * $amount ;

			$ARES['metal'] -= $pricelist[$element]['cost'][901] * $amount ;
			$ARES['crystal'] -= $pricelist[$element]['cost'][902] * $amount ;
		}
	}

	$DRESDefs = array('metal' => 0, 'crystal' => 0);

	foreach ($defenders as $fleetID => $defender) {
		foreach ($defender['unit'] as $element => $amount) {
			if ($element < 300) {							// flotte defenseur en CDR
				$DRES['metal'] 	 -= $pricelist[$element]['cost'][901] * $amount ;
				$DRES['crystal'] -= $pricelist[$element]['cost'][902] * $amount ;

				$TRES['defender'] -= $pricelist[$element]['cost'][901] * $amount ;
				$TRES['defender'] -= $pricelist[$element]['cost'][902] * $amount ;
			} else {									// defs defenseur en CDR + reconstruction
				$TRES['defender'] -= $pricelist[$element]['cost'][901] * $amount ;
				$TRES['defender'] -= $pricelist[$element]['cost'][902] * $amount ;

				$lost = $STARTDEF[$element] - $amount;
				$giveback = round($lost * (rand(56, 84) / 100));
				$defenders[$fleetID]['unit'][$element] += $giveback;
				$DRESDefs['metal'] 	 += $pricelist[$element]['cost'][901] * ($lost - $giveback) ;
				$DRESDefs['crystal'] += $pricelist[$element]['cost'][902] * ($lost - $giveback) ;
			}
		}
	}
	
	$ARES['metal']		= max($ARES['metal'], 0);
	$ARES['crystal']	= max($ARES['crystal'], 0);
	$DRES['metal']		= max($DRES['metal'], 0);
	$DRES['crystal']	= max($DRES['crystal'], 0);
	$TRES['attacker']	= max($TRES['attacker'], 0);
	$TRES['defender']	= max($TRES['defender'], 0);
	
	$totalLost = array('attacker' => $TRES['attacker'], 'defender' => $TRES['defender']);
	$debAttMet = ($ARES['metal'] * ($FleetTF / 100));
	$debAttCry = ($ARES['crystal'] * ($FleetTF / 100));
	$debDefMet = ($DRES['metal'] * ($FleetTF / 100)) + ($DRESDefs['metal'] * ($DefTF / 100));
	$debDefCry = ($DRES['crystal'] * ($FleetTF / 100)) + ($DRESDefs['crystal'] * ($DefTF / 100));

	return array('won' => $won, 'debris' => array('attacker' => array(901 => $debAttMet, 902 => $debAttCry), 'defender' => array(901 => $debDefMet, 902 => $debDefCry)), 'rw' => $ROUND, 'unitLost' => $totalLost);
}
?>