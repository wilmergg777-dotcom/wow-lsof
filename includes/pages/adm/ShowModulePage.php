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

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) throw new Exception("Permission error!");

function ShowModulePage()
{
	global $LNG;

	$config	= Config::get(Universe::getEmulated());
	$module	= explode(';', $config->moduls);

	// Normalizar: asegurar que existan todas las posiciones 0..MODULE_AMOUNT-1
	for ($i = 0; $i < MODULE_AMOUNT; $i++) {
		if (!isset($module[$i])) {
			$module[$i] = 1;
		}
	}

	if(isset($_GET['mode'])) {
		$id = HTTP::_GP('id', 0);
		if ($id >= 0 && $id < MODULE_AMOUNT) {
			$module[$id] = ($_GET['mode'] == 'aktiv') ? 1 : 0;
			$config->moduls = implode(";", $module);
			$config->save();
			ClearCache();
		}
	}

	// Nombres de respaldo para los modulos AstroIO
	// (por si aun no estan en el archivo de idioma)
	// IDs 43-72 (30 modulos AstroIO)
	$astroioNames = array(
		43 => 'VIP Prime',
		44 => 'Eventos',
		45 => 'Mercado',
		46 => 'Wallet',
		47 => 'Referidos',
		48 => 'Pase de Batalla',
		49 => 'Reporte de Bugs',
		50 => 'Rifas',
		51 => 'Loteria',
		52 => 'Mejoras',
		53 => 'Temporadas de Mejoras',
		54 => 'Giveaway',
		55 => 'Razas',
		56 => 'Facciones',
		57 => 'Contenedores',
		58 => 'Tareas y Logros',
		59 => 'Guerra WAR',
		60 => 'Banco de Alianza',
		61 => 'FleetTools',
		62 => 'Comerciante',
		63 => 'Sistema PvE (Crisis + Boss + Bastion)',
		64 => 'Asteroides',
		65 => 'Sistema PvP (Arenas + Torneos)',
		66 => 'Planetario (Droides)',
		67 => 'Shop NTX-20',
		68 => 'Boost Fin de Semana',
		69 => 'Minijuego Topo',
		70 => 'Mini Torneos',
		71 => 'La Cueva Pirata',
		72 => 'Minijuego Navidad', // ← NUEVO
	);

	$IDs	= range(0, MODULE_AMOUNT - 1);
	foreach($IDs as $ID) {
		$langKey = 'modul_'.$ID;
		$name    = null;

		if (isset($LNG[$langKey]) && !empty($LNG[$langKey])) {
			$name = $LNG[$langKey];
		} elseif (isset($astroioNames[$ID])) {
			$name = $astroioNames[$ID];
		} else {
			$name = 'Modulo '.$ID;
		}

		$Modules[$ID]	= array(
			'name'	=> $name,
			'state'	=> isset($module[$ID]) ? $module[$ID] : 1,
		);
	}

	asort($Modules);
	$template	= new template();

	$template->assign_vars(array(
		'Modules'				=> $Modules,
		'mod_module'			=> $LNG['mod_module'],
		'mod_info'				=> $LNG['mod_info'],
		'mod_active'			=> $LNG['mod_active'],
		'mod_deactive'			=> $LNG['mod_deactive'],
		'mod_change_active'		=> $LNG['mod_change_active'],
		'mod_change_deactive'	=> $LNG['mod_change_deactive'],
	));
	
	$template->show('ModulePage.tpl');
}