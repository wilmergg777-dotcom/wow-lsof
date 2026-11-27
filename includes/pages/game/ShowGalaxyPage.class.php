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
 * GALAXIA 3D (rama xnova3d) v2.0:
 *   - La lógica de datos vive en Galaxy3dService (compartida con la API).
 *   - SELECTOR DE VISTA: el jugador elige entorno 3D o clásico con
 *     ?page=galaxy&vista=3d|clasico (se recuerda en la sesión). Es la MISMA
 *     instalación y la MISMA base de datos: solo cambia la forma de jugar.
 *   - show(): renderiza page.galaxy.default.tpl (3D) o page.galaxy.clasico.tpl.
 *   - fetch(): API JSON AJAX del visor 3D (cobra deuterio igual que la clásica).
 */

require_once('includes/classes/class.GalaxyRows.php');
require_once('includes/classes/Galaxy3dService.class.php');

class ShowGalaxyPage extends AbstractGamePage
{
    public static $requireModule = MODULE_RESEARCH;

	function __construct()
	{
		parent::__construct();
	}

	// ============================================================
	// SELECTOR DE VISTA (xnova3d v2.0)
	// El usuario escoge si juega en el entorno 3D o en el clásico:
	//   ?page=galaxy&vista=3d      -> visor 3D
	//   ?page=galaxy&vista=clasico -> tabla clásica
	// La elección se recuerda en la sesión del usuario mientras dure
	// su conexión. Por defecto: 3D (esta rama).
	// ============================================================
	private function elegirVista()
	{
		global $session;

		$vista = HTTP::_GP('vista', '');
		if ($vista === 'clasico' || $vista === '3d') {
			$session->ag3d_vista = $vista;
			return $vista;
		}
		$guardada = $session->ag3d_vista;
		return ($guardada === 'clasico') ? 'clasico' : '3d';
	}

	public function show()
	{
		global $USER, $PLANET, $resource, $LNG, $reslist;

		$config			= Config::get();

		$vista			= $this->elegirVista();
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

		// ============================================
		// GALAXIA 3D v2.0 — datos del sistema vía Galaxy3dService
		// (misma fuente de datos que la API api/index.php)
		// ============================================
		$datos = Galaxy3dService::cargarGalaxia($galaxy, $system);
		// ============================================

		$this->tplObj->loadscript('galaxy.js');

		// ============================================================
		// VISTA CLÁSICA (tabla original del juego, restaurada)
		// ============================================================
		if ($vista === 'clasico')
		{
	        $this->assign(array(
				'GalaxyRows'				=> $datos['result'],
				'asteroids'					=> $datos['asteroids'],
				'incomingFleets'			=> $datos['incoming'],
				'climasGalaxy'				=> $datos['climas'], // ASTROIO v1.2
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

			$this->display('page.galaxy.clasico.tpl');
		}

		// ============================================================
		// VISTA 3D (visor a pantalla completa + HUD con 2 tablas)
		// ============================================================
		$astro3d = Galaxy3dService::buildAstro3d($galaxy, $system, $datos);

		$this->tplObj->loadscript('three.min.js');
		$this->tplObj->loadscript('OrbitControls.js');
		$this->tplObj->loadscript('galaxy3d.js');
        $this->assign(array(
			'GalaxyRows'				=> $datos['result'],
			'asteroids'					=> $datos['asteroids'],
			'incomingFleets'			=> $datos['incoming'],
			'climasGalaxy'				=> $datos['climas'], // ASTROIO v1.2
			'astro3d'					=> $astro3d, // GALAXIA 3D
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
		));

		$this->display('page.galaxy.default.tpl');
	}

	// ============================================================
	// GALAXIA 3D — API JSON AJAX del visor 3D.
	// game.php?page=galaxy&mode=fetch&galaxy=G&system=S
	// Devuelve el mismo paquete de datos que la plantilla recibe,
	// para que el visor cambie de sistema SIN recargar. Cobra
	// deuterio exactamente igual que la vista clásica: el 3D es
	// otro cliente del MISMO juego (misma base de datos).
	// ============================================================
	public function fetch()
	{
		global $USER, $PLANET, $LNG;

		$config = Config::get();

		$galaxy	= min(max(HTTP::_GP('galaxy', (int) $PLANET['galaxy']), 1), $config->max_galaxy);
		$system	= min(max(HTTP::_GP('system', (int) $PLANET['system']), 1), $config->max_system);

		if ($galaxy != $PLANET['galaxy'] || $system != $PLANET['system'])
		{
			if($PLANET['deuterium'] < $config->deuterium_cost_galaxy)
			{
				$this->sendJSON(array(
					'ok'  => false,
					'err' => $LNG['gl_no_deuterium_to_view_galaxy'],
				));
			}
			$PLANET['deuterium'] -= $config->deuterium_cost_galaxy;
		}

		$this->sendJSON(Galaxy3dService::datosCompletos($galaxy, $system));
	}
}
?>
