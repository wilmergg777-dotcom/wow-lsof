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
 * GALAXIA 3D (rama xnova3d) v1.0:
 *   - El cliente 3D consume los MISMOS datos del juego clásico (misma BD).
 *   - cargarGalaxia(): filas + asteroides + flotas entrantes + climas
 *     (refactor compartido por show() y fetch()).
 *   - buildAstro3d(): filas JSON para el motor 3D (scripts/game/galaxy3d.js)
 *     + TOP 10 de puntuación del universo (%%STATPOINTS%%, misma tabla que
 *     las estadísticas clásicas) con las coordenadas de su planeta principal.
 *   - fetch(): NUEVA ACCIÓN API — devuelve el sistema en JSON para que el
 *     visor 3D cambie de sistema sin recargar la página (cobra deuterio
 *     igual que la vista clásica).
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

	// ============================================================
	// GALAXIA 3D — carga de un sistema completo (compartido por
	// show() y fetch()): filas de GalaxyRows + asteroides +
	// flotas entrantes + climas del sistema.
	// ============================================================
	private function cargarGalaxia($galaxy, $system)
	{
		global $USER;

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

		return array(
			'result'    => $Result,
			'asteroids' => $asteroids,
			'incoming'  => $incomingFleets,
			'climas'    => $climasGalaxy,
		);
	}

	// ============================================================
	// GALAXIA 3D — filas JSON para el motor 3D + TOP de puntuación
	// del universo (misma tabla %%STATPOINTS%% que las estadísticas
	// clásicas: lo que se ve en un cliente se ve en el otro).
	// ============================================================
	private function buildAstro3d($galaxy, $system, $datos)
	{
		global $USER, $PLANET, $THEME;

		$config = Config::get();

		$Result         = $datos['result'];
		$asteroids      = $datos['asteroids'];
		$incomingFleets = $datos['incoming'];
		$climasGalaxy   = $datos['climas'];

		$maxPlanets3d = (int)$config->max_planets;
		$shortStatus3d = array(
			'vacation'      => 'V',
			'banned'        => 'B',
			'inactive'      => 'i',
			'longinactive'  => 'I',
			'noob'          => 'D',
			'strong'        => 'F',
			'enemy'         => 'E',
			'friend'        => 'A',
			'member'        => 'M',
		);

		$astro3dRows = array();
		for ($p3 = 1; $p3 <= $maxPlanets3d; $p3++) {
			$ckp3 = $galaxy . ':' . $system . ':' . $p3 . ':1';
			$ckm3 = $galaxy . ':' . $system . ':' . $p3 . ':3';
			if (isset($Result[$p3]) && is_array($Result[$p3])) {
				$g3 = $Result[$p3];
				$inc3 = '-';
				if (isset($incomingFleets['attack'][$ckp3]) || isset($incomingFleets['attack'][$ckm3])) { $inc3 = 'a'; }
				elseif (isset($incomingFleets['spy'][$ckp3]) || isset($incomingFleets['spy'][$ckm3])) { $inc3 = 's'; }
				elseif (isset($incomingFleets['transport'][$ckp3]) || isset($incomingFleets['transport'][$ckm3])) { $inc3 = 't'; }
				$clima3 = 0;
				if (isset($climasGalaxy[$g3['planet']['id']])) {
					$clima3 = array(
						'n' => $climasGalaxy[$g3['planet']['id']]['nombre'],
						'c' => $climasGalaxy[$g3['planet']['id']]['clave'],
						'd' => $climasGalaxy[$g3['planet']['id']]['descripcion'],
					);
				}
				$climaL3 = 0;
				if (!empty($g3['moon']) && isset($climasGalaxy[$g3['moon']['id']])) {
					$climaL3 = array(
						'n' => $climasGalaxy[$g3['moon']['id']]['nombre'],
						'c' => $climasGalaxy[$g3['moon']['id']]['clave'],
						'd' => $climasGalaxy[$g3['moon']['id']]['descripcion'],
					);
				}
				// SOLO las misiones permitidas (el cliente 3D usa esta lista
				// para mostrar u ocultar los botones de acción).
				$ms3 = array();
				if (!empty($g3['missions']) && is_array($g3['missions'])) {
					foreach ($g3['missions'] as $mid3 => $mok3) {
						if ($mok3) { $ms3[] = (int)$mid3; }
					}
				}
				$ucl3 = array();
				if (!empty($g3['user']['class']) && is_array($g3['user']['class'])) {
					$ucl3 = array_values($g3['user']['class']);
				}
				// puntos crudos (user['points'] viene formateado con puntos de millar)
				$pts3 = 0;
				if (isset($g3['user']['points'])) {
					$pts3 = (int)str_replace(array('.', ' ', ','), '', $g3['user']['points']);
				}
				$astro3dRows[] = array(
					't'     => 'p',
					'pos'   => $p3,
					'own'   => !empty($g3['ownPlanet']) ? 1 : 0,
					'pid'   => (int)$g3['planet']['id'],
					'name'  => (string)$g3['planet']['name'],
					'img'   => (string)$g3['planet']['image'],
					'phx'   => !empty($g3['planet']['phalanx']) ? 1 : 0,
					'depo'  => !empty($g3['planet']['ally_deposit']) ? 1 : 0,
					'moon'  => !empty($g3['moon']) ? array('id' => (int)$g3['moon']['id'], 'name' => (string)$g3['moon']['name'], 'dia' => (int)$g3['moon']['diameter']) : 0,
					'deb'   => !empty($g3['debris']) ? array('m' => (int)$g3['debris']['metal'], 'c' => (int)$g3['debris']['crystal']) : 0,
					'uid'   => (int)$g3['user']['id'],
					'uname' => (string)$g3['user']['username'],
					'rank'  => isset($g3['user']['rank']) ? (int)$g3['user']['rank'] : 1,
					'pts'   => $pts3,
					'act'   => isset($g3['lastActivity']) ? (string)$g3['lastActivity'] : '',
					'ucl'   => $ucl3,
					'ally'  => !empty($g3['alliance']) ? array('tag' => (string)$g3['alliance']['tag'], 'id' => (int)$g3['alliance']['id']) : 0,
					'actBtns' => array(
						'esp' => !empty($g3['action']['esp']) ? 1 : 0,
						'msg' => !empty($g3['action']['message']) ? 1 : 0,
						'bud' => !empty($g3['action']['buddy']) ? 1 : 0,
						'mis' => !empty($g3['action']['missle']) ? 1 : 0,
					),
					'ms'    => $ms3,
					'clima' => $clima3,
					'climaL'=> $climaL3,
					'ast'   => isset($asteroids[$p3]) ? 1 : 0,
					'inc'   => $inc3,
				);
			} elseif (isset($Result[$p3])) {
				// Ruinas (planeta destruido)
				$astro3dRows[] = array('t' => 'r', 'pos' => $p3, 'ast' => isset($asteroids[$p3]) ? 1 : 0);
			} else {
				// Posición vacía (colonizable, misión 7 desde el visor 3D)
				$astro3dRows[] = array('t' => 'e', 'pos' => $p3, 'ast' => isset($asteroids[$p3]) ? 1 : 0);
			}
		}
		// Espacio profundo (posición max_planets + 1: expediciones, misión 15)
		$astro3dRows[] = array('t' => 'd', 'pos' => $maxPlanets3d + 1);

		// ============================================================
		// TOP 10 DEL UNIVERSO (tabla de puntuación del juego).
		// Se une con el planeta principal (id_planet) para que el
		// visor 3D pueda viajar al sistema de cada jugador del TOP.
		// ============================================================
		$score3d = array();
		$sqlTop = 'SELECT s.total_rank, s.total_points, u.username, a.ally_tag, u.id_planet,
					p.galaxy, p.system, p.planet
				FROM %%STATPOINTS%% s
				INNER JOIN %%USERS%% u ON u.id = s.id_owner
				LEFT JOIN %%ALLIANCE%% a ON a.id = u.ally_id
				LEFT JOIN %%PLANETS%% p ON p.id = u.id_planet
				WHERE s.stat_type = :statType
				ORDER BY s.total_points DESC
				LIMIT 10';
		$topRows = Database::get()->select($sqlTop, array(':statType' => 1));
		if (is_array($topRows)) {
			foreach ($topRows as $tr) {
				$score3d[] = array(
					'rank'  => (int)$tr['total_rank'],
					'uname' => (string)$tr['username'],
					'ally'  => (string)$tr['ally_tag'],
					'pts'   => (int)$tr['total_points'],
					'g'     => (int)$tr['galaxy'],
					's'     => (int)$tr['system'],
					'p'     => (int)$tr['planet'],
				);
			}
		}

		// puntuación propia (fila TÚ de la tabla de puntuación)
		$scoreMe = array('rank' => 0, 'pts' => 0);
		$sqlMe = 'SELECT total_rank, total_points
				FROM %%STATPOINTS%%
				WHERE id_owner = :userId AND stat_type = :statType';
		$meRow = Database::get()->selectSingle($sqlMe, array(
			':userId'   => $USER['id'],
			':statType' => 1
		));
		if (is_array($meRow)) {
			$scoreMe = array('rank' => (int)$meRow['total_rank'], 'pts' => (int)$meRow['total_points']);
		}

		// etiqueta propia para la fila TÚ
		$meName = isset($USER['username']) ? (string)$USER['username'] : '';
		$meAlly = '';
		if (!empty($USER['ally_id'])) {
			$allyRow = Database::get()->selectSingle('SELECT ally_tag FROM %%ALLIANCE%% WHERE id = :aid', array(
				':aid' => (int)$USER['ally_id']
			));
			if (is_array($allyRow) && !empty($allyRow['ally_tag'])) {
				$meAlly = (string)$allyRow['ally_tag'];
			}
		}

		return array(
			'ok'         => true,
			'galaxy'     => (int)$galaxy,
			'system'     => (int)$system,
			'maxPlanets' => $maxPlanets3d,
			'maxGalaxy'  => (int)$config->max_galaxy,
			'maxSystem'  => (int)$config->max_system,
			'dpath'      => ($THEME && method_exists($THEME, 'getTheme')) ? $THEME->getTheme() : 'styles/themes/gow/',
			'curGalaxy'  => (int)$PLANET['galaxy'],
			'curSystem'  => (int)$PLANET['system'],
			'curPlanet'  => (int)$PLANET['planet'],
			'meName'     => $meName,
			'meAlly'     => $meAlly,
			'me'         => array('pts' => $scoreMe['pts'], 'rank' => $scoreMe['rank']),
			'scoreMe'    => $scoreMe,
			'score'      => $score3d,
			'short'      => $shortStatus3d,
			'rows'       => $astro3dRows,
		);
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

		// ============================================
		// GALAXIA 3D — datos del sistema para el visor 3D
		// ============================================
		$datos = $this->cargarGalaxia($galaxy, $system);
		$astro3d = $this->buildAstro3d($galaxy, $system, $datos);
		// ============================================

		$this->tplObj->loadscript('three.min.js');
		$this->tplObj->loadscript('OrbitControls.js');
		$this->tplObj->loadscript('galaxy.js');
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
	// GALAXIA 3D — API JSON del visor 3D.
	// game.php?page=galaxy&mode=fetch&galaxy=G&system=S
	// Devuelve el mismo paquete de datos que show() inyecta en la
	// plantilla, para que el visor cambie de sistema SIN recargar.
	// Cobra deuterio exactamente igual que la vista clásica:
	// el 3D es otro cliente del MISMO juego (misma base de datos),
	// no un juego aparte.
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

		$datos = $this->cargarGalaxia($galaxy, $system);
		$astro3d = $this->buildAstro3d($galaxy, $system, $datos);
		$this->sendJSON($astro3d);
	}
}
?>
