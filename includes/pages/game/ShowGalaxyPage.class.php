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
 * ASTROIO v1.0 - Asteroides
 * ASTROIO v1.1 - Alertas de Flotas
 * ASTROIO v1.2 (SISTEMA DE CLIMA)
 * ASTROIO v1.3 (FIX LAZY):
 *   - Se corrige el ID del planeta en el bloque "lazy".
 *     Ahora usa $row['planet']['id'] (estructura real de GalaxyRows)
 *     en lugar de $row['id'].
 * ASTROIO v1.4 (FIX SQL CLIMA):
 *   - Se reemplazan los marcadores %%CLIMA_PLANETA%% y %%CLIMAS%%
 *     por los nombres reales de las tablas (uni1_clima_planeta y uni1_climas)
 *     para evitar el error SQL 1064.
 */

require_once('includes/classes/class.GalaxyRows.php');

// ============================================
// ASTROIO - Cargar AsteroidHelper
// ============================================
if (!class_exists('AsteroidHelper')) {
    require_once ROOT_PATH.'includes/classes/AsteroidHelper.class.php';
}
// ============================================

// ============================================
// ASTROIO - Cargar ClimaEngine
// ============================================
if (!class_exists('ClimaEngine')) {
    require_once ROOT_PATH.'includes/classes/ClimaEngine.class.php';
}
// ============================================

class ShowGalaxyPage extends AbstractGamePage
{
    public static $requireModule = MODULE_RESEARCH;

	function __construct() 
	{
		parent::__construct();
	}
	
	public function show()
	{
		global $USER, $PLANET, $resource, $LNG, $reslist;

		$config			= Config::get();

		$action 		= HTTP::_GP('action', '');
		$galaxyLeft		= HTTP::_GP('galaxyLeft', '');
		$galaxyRight	= HTTP::_GP('galaxyRight', '');
		$systemLeft		= HTTP::_GP('systemLeft', '');
		$systemRight	= HTTP::_GP('systemRight', '');
		$galaxy			= min(max(HTTP::_GP('galaxy', (int) $PLANET['galaxy']), 1), $config->max_galaxy);
		$system			= min(max(HTTP::_GP('system', (int) $PLANET['system']), 1), $config->max_system);
		$planet			= min(max(HTTP::_GP('planet', (int) $PLANET['planet']), 1), $config->max_planets);
		$type			= HTTP::_GP('type', 1);
		$current		= HTTP::_GP('current', 0);
		
        if (!empty($galaxyLeft))
            $galaxy	= max($galaxy - 1, 1);
        elseif (!empty($galaxyRight))
            $galaxy	= min($galaxy + 1, $config->max_galaxy);

        if (!empty($systemLeft))
            $system	= max($system - 1, 1);
        elseif (!empty($systemRight))
            $system	= min($system + 1, $config->max_system);

		if ($galaxy != $PLANET['galaxy'] || $system != $PLANET['system'])
		{
			if($PLANET['deuterium'] < $config->deuterium_cost_galaxy)
			{	
				$this->printMessage($LNG['gl_no_deuterium_to_view_galaxy'], array(array(
					'label'	=> $LNG['sys_back'],
					'url'	=> 'game.php?page=galaxy'
				)));
			} else {
				$PLANET['deuterium']	-= $config->deuterium_cost_galaxy;
            }
		}

        $targetDefensive    = $reslist['defense'];
        $targetDefensive[]	= 502;
		$missileSelector[0]	= $LNG['gl_all_defenses'];
		
		foreach($targetDefensive as $Element)
		{	
			$missileSelector[$Element] = $LNG['tech'][$Element];
		}
		$sql	= 'SELECT total_points
		FROM %%STATPOINTS%%
		WHERE id_owner = :userId AND stat_type = :statType';

		// ✅ FIX: selectSingle() puede devolver false si no hay fila en statpoints
		$statPoints = Database::get()->selectSingle($sql, array(
			':userId'	=> $USER['id'],
			':statType'	=> 1
		));

		if (is_array($statPoints)) {
			$USER += $statPoints;
		} else {
			$USER['total_points'] = 0;
		}

		$galaxyRows	= new GalaxyRows;
		$galaxyRows->setGalaxy($galaxy);
		$galaxyRows->setSystem($system);
		$Result	= $galaxyRows->getGalaxyData();
		// ✅ FIX: getGalaxyData() puede devolver null -> normalizar a array
		if (!is_array($Result)) {
			$Result = array();
		}

		// ============================================
		// ASTROIO - Cargar asteroides del sistema actual
		// ============================================
		$asteroids = array();
		if (class_exists('AsteroidHelper')) {
			$asteroids = AsteroidHelper::getAsteroidsInSystem($galaxy, $system);
			if (!is_array($asteroids)) $asteroids = array();
		}
		// ============================================

		// ============================================
		// ASTROIO v1.1 - Detección de flotas entrantes
		// ============================================
		$incomingFleets = array(
			'attack'    => array(), // Misiones 1, 2, 10
			'spy'       => array(), // Misión 6
			'transport' => array(), // Misiones 3, 4
		);

		$fleetSql = 'SELECT fleet_end_galaxy, fleet_end_system, fleet_end_planet, 
							fleet_end_type, fleet_mission
					 FROM %%FLEETS%%
					 WHERE fleet_target_owner = :userId
					 AND fleet_mission IN (1, 2, 3, 4, 6, 10)
					 AND fleet_end_time > :now';

		$fleetRows = Database::get()->select($fleetSql, array(
			':userId' => $USER['id'],
			':now'    => TIMESTAMP
		));
		if (!is_array($fleetRows)) $fleetRows = array();

		foreach ($fleetRows as $fleet) {
			$key = $fleet['fleet_end_galaxy'].':'.$fleet['fleet_end_system'].':'.$fleet['fleet_end_planet'].':'.$fleet['fleet_end_type'];
			
			// Misión 1: Atacar, Misión 2: ACS, Misión 10: Misiles
			if (in_array($fleet['fleet_mission'], array(1, 2, 10))) {
				$incomingFleets['attack'][$key] = true;
			}
			// Misión 6: Espionaje
			elseif ($fleet['fleet_mission'] == 6) {
				$incomingFleets['spy'][$key] = true;
			}
			// Misión 3: Transportar, Misión 4: Desplegar
			elseif (in_array($fleet['fleet_mission'], array(3, 4))) {
				$incomingFleets['transport'][$key] = true;
			}
		}
		// ============================================

		// ============================================
		// ASTROIO v1.2 (SISTEMA DE CLIMA) - Cargar climas del sistema
		// ============================================
		$climasGalaxy = array();
		if (class_exists('ClimaEngine')) {
			$db = Database::get();

			// 1. Bulk query: una sola consulta para todos los planetas/lunas del sistema
            // ✅ FIX v1.4: Se usan los nombres reales de las tablas en lugar de marcadores
			$sqlClimas = "SELECT cp.planeta_id, c.clave, c.nombre, c.descripcion,
								c.factor_ataque, c.factor_defensa, c.factor_bajas, c.factor_botin
						  FROM uni1_clima_planeta cp
						  INNER JOIN uni1_climas c ON c.id = cp.clima_id
						  INNER JOIN %%PLANETS%% p ON p.id = cp.planeta_id
						  WHERE p.galaxy = :galaxy AND p.system = :system AND p.destruyed = 0
							AND cp.fecha_expiracion > NOW()
							AND c.activo = 1";
			$climasRows = $db->select($sqlClimas, array(
				':galaxy' => (int)$galaxy,
				':system' => (int)$system
			));
			if (is_array($climasRows)) {
				foreach ($climasRows as $row) {
					$climasGalaxy[(int)$row['planeta_id']] = $row;
				}
			}

			// 2. Lazy: para planetas sin clima, se lo asignamos al vuelo
			//    ASTROIO v1.3 — FIX: el ID del planeta está en $row['planet']['id']
			if (!empty($Result)) {
				foreach ($Result as $row) {
					$pid = isset($row['planet']['id']) ? (int)$row['planet']['id'] : 0;
					if ($pid > 0 && !isset($climasGalaxy[$pid])) {
						$nuevoClima = ClimaEngine::asignarClimaPlaneta($pid);
						if ($nuevoClima) {
							$climasGalaxy[$pid] = $nuevoClima;
						}
					}
				}
			}
		}
		// ============================================

        $this->tplObj->loadscript('galaxy.js');
        $this->assign(array(
			'GalaxyRows'				=> $Result,
			'asteroids'					=> $asteroids,
			'incomingFleets'			=> $incomingFleets,
			'climasGalaxy'				=> $climasGalaxy, // ASTROIO v1.2
			'planetcount'				=> sprintf($LNG['gl_populed_planets'], Database::get()->rowCount()),
			'action'					=> $action,
			'galaxy'					=> $galaxy,
			'system'					=> $system,
			'planet'					=> $planet,
			'type'						=> $type,
			'current'					=> $current,
			'maxfleetcount'				=> FleetFunctions::GetCurrentFleets($USER['id']),
			'fleetmax'					=> FleetFunctions::GetMaxFleetSlots($USER),
			'currentmip'				=> $PLANET[$resource[503]],
			'grecyclers'   				=> $PLANET[$resource[219]],
			'recyclers'   				=> $PLANET[$resource[209]],
			'spyprobes'   				=> $PLANET[$resource[210]],
			'missile_count'				=> sprintf($LNG['gl_missil_to_launch'], $PLANET[$resource[503]]),
			'spyShips'					=> array(210 => $USER['spio_anz']),
			'settings_fleetactions'		=> $USER['settings_fleetactions'],
			'current_galaxy'			=> $PLANET['galaxy'],
			'current_system'			=> $PLANET['system'],
			'current_planet'			=> $PLANET['planet'],
			'planet_type' 				=> $PLANET['planet_type'],
            'max_planets'               => $config->max_planets,
			'missileSelector'			=> $missileSelector,
			'ShortStatus'				=> array(
				'vacation'					=> $LNG['gl_short_vacation'],
				'banned'					=> $LNG['gl_short_ban'],
				'inactive'					=> $LNG['gl_short_inactive'],
				'longinactive'				=> $LNG['gl_short_long_inactive'],
				'noob'						=> $LNG['gl_short_newbie'],
				'strong'					=> $LNG['gl_short_strong'],
				'enemy'						=> $LNG['gl_short_enemy'],
				'friend'					=> $LNG['gl_short_friend'],
				'member'					=> $LNG['gl_short_member'],
			),
		));
		
		$this->display('page.galaxy.default.tpl');
	}
}
?>