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
 * ============================================
 * ASTROIO - Modificado para dar NTX-20 y Contenedores
 * Fecha: 2026-09-16
 * ============================================
 */
 
 if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) throw new Exception("Permission error!");
function ShowGiveaway()
{
	global $LNG, $resource, $reslist;
	$template	= new template();	
	$action	= HTTP::_GP('action', '');
	if ($action == 'send') {
		$planet			= HTTP::_GP('planet', 0);
		$moon			= HTTP::_GP('moon', 0);
		$mainplanet		= HTTP::_GP('mainplanet', 0);
		$no_inactive	= HTTP::_GP('no_inactive', 0);
		
		if (!$planet && !$moon) {
			$template->message($LNG['ga_selectplanettype']);
			exit;
		}
		
		$planetIN	= array();
		
		if ($planet) {
			$planetIN[]	= "'1'";
		} 
		
		if ($moon) {
			$planetIN[]	= "'3'";
		} 
		
		$data		= array();
		$dataUser	= array(); // 🆕 Array para elementos de la tabla USERS (Tecnologías, Oficiales, Materia Oscura)
		
		$DataIDs	= array_merge($reslist['resstype'][1], $reslist['resstype'][3], $reslist['build'], $reslist['tech'], $reslist['fleet'], $reslist['defense'], $reslist['officier']);
		
		$logOld		= array();
		$logNew		= array();
		
		foreach($DataIDs as $ID)
		{
			$amount	= max(0, round(HTTP::_GP('element_'.$ID, 0.0)));
			
			// 🆕 FIX: Separar elementos que pertenecen a la tabla USERS
			// - Materia Oscura (ID 921)
			// - Investigaciones ($reslist['tech'])
			// - Oficiales ($reslist['officier'])
			if ($ID == 921 || in_array($ID, $reslist['tech']) || in_array($ID, $reslist['officier'])) {
				$dataUser[] = "u.".$resource[$ID]." = u.".$resource[$ID]." + ".$amount;
			} else {
				// Metal, Cristal, Deuterio, Edificios, Naves, Defensas → tabla PLANETS
				$data[] = "p.".$resource[$ID]." = p.".$resource[$ID]." + ".$amount;
			}
			
			$logOld[$ID]	= 0;
			$logNew[$ID]	= $amount;
		}
		
		// 1️⃣ Actualizar recursos de PLANETAS (si hay alguno)
		if (!empty($data)) {
			$SQL		= "UPDATE ".PLANETS." p INNER JOIN ".USERS." u ON p.id_owner = u.id";
			
			if ($mainplanet == true) {
				$SQL	.= " AND p.id = u.id_planet";
			}
			
			if ($no_inactive == true) {
				$SQL	.= " AND u.onlinetime > ".(TIMESTAMP - INACTIVE);
			}
			
			$SQL	.= " SET ".implode(', ', $data)." WHERE p.universe = ".Universe::getEmulated()." AND p.planet_type IN (".implode(',', $planetIN).")";
			
			$GLOBALS['DATABASE']->query($SQL);
		}
		
		// 2️⃣ Actualizar elementos de USERS (Tecnologías, Oficiales, Materia Oscura)
		if (!empty($dataUser)) {
			$SQLu = "UPDATE ".USERS." u SET ".implode(', ', $dataUser)." WHERE u.universe = ".Universe::getEmulated();
			
			if ($no_inactive == true) {
				$SQLu .= " AND u.onlinetime > ".(TIMESTAMP - INACTIVE);
			}
			
			// Filtro: el usuario debe tener al menos un planeta del tipo seleccionado
			$SQLu .= " AND EXISTS (
				SELECT 1 FROM ".PLANETS." p2 
				WHERE p2.id_owner = u.id 
				AND p2.universe = u.universe 
				AND p2.planet_type IN (".implode(',', $planetIN).")
			)";
			
			$GLOBALS['DATABASE']->query($SQLu);
		}
		
		// ============================================
		// ASTROIO - NTX-20 y Contenedores (al USUARIO)
		// ============================================
		$ntx20Amount      = max(0, round(HTTP::_GP('element_930', 0.0)));
		$containersAmount = max(0, round(HTTP::_GP('element_931', 0.0)));
		
		if ($ntx20Amount > 0 || $containersAmount > 0) {
			
			// Construir los SET para la tabla USERS
			$setUser = array();
			if ($ntx20Amount > 0) {
				$setUser[] = "u.ntx20 = u.ntx20 + ".(int)$ntx20Amount;
			}
			if ($containersAmount > 0) {
				$setUser[] = "u.containers = u.containers + ".(int)$containersAmount;
			}
			
			// Construir los filtros
			$filterUser = array();
			$filterUser[] = "u.universe = ".Universe::getEmulated();
			
			if ($no_inactive == true) {
				$filterUser[] = "u.onlinetime > ".(TIMESTAMP - INACTIVE);
			}
			
			// Filtro: el usuario debe tener al menos un planeta del tipo seleccionado
			$filterUser[] = "EXISTS (
				SELECT 1 FROM ".PLANETS." p2 
				WHERE p2.id_owner = u.id 
				AND p2.universe = u.universe 
				AND p2.planet_type IN (".implode(',', $planetIN).")
			)";
			
			$SQLu = "UPDATE ".USERS." u SET ".implode(', ', $setUser)." WHERE ".implode(' AND ', $filterUser);
			
			$GLOBALS['DATABASE']->query($SQLu);
		}
		// ============================================
		// FIN ASTROIO
		// ============================================
		
		$LOG = new Log(4);
		$LOG->target = 0;
		$LOG->old = $logOld;
		$LOG->new = $logNew;
		$LOG->save();
		
		$template->message($LNG['ga_success']);
		exit;
	}	
	
	$template->assign_vars(array(	
		'reslist'		=> $reslist
	));
	$template->show("giveaway.tpl");
}