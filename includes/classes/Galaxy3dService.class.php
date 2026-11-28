<?php

/**
 * Galaxy3dService — servicio compartido de datos de la galaxia (rama xnova3d)
 * -----------------------------------------------------------------------
 * UNA SOLA fuente de verdad para los datos de la galaxia, usada por:
 *   - ShowGalaxyPage (vista 3D en el navegador y modo fetch AJAX)
 *   - api/index.php  (API v1 para las APKs: clásica y 3D)
 * Todos los clientes leen la MISMA base de datos del juego clásico:
 * lo que se hace en un cliente se ve en los demás.
 *
 * Métodos:
 *   cargarGalaxia(g, s)        filas + asteroides + flotas entrantes + climas
 *   getMe()                    puntuación propia + etiquetas + planeta actual
 *   getTop()                   TOP 10 del universo (%%STATPOINTS%%) + getMe()
 *   buildAstro3d(g, s, datos)  paquete JSON completo del visor 3D
 *   datosCompletos(g, s)       atajo: cargarGalaxia + buildAstro3d
 *   getAccion(g, s, p)         misiones disponibles de una posición (r=missions)
 */

if (!class_exists('AsteroidHelper')) {
    require_once ROOT_PATH.'includes/classes/AsteroidHelper.class.php';
}
if (!class_exists('ClimaEngine')) {
    require_once ROOT_PATH.'includes/classes/ClimaEngine.class.php';
}

class Galaxy3dService
{
	// ============================================================
	// Carga de un sistema completo (compartido por la página y la API)
	// ============================================================
	public static function cargarGalaxia($galaxy, $system)
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
	// Puntuación propia (fila TÚ) + etiquetas + planeta actual
	// ============================================================
	public static function getMe()
	{
		global $USER, $PLANET;

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
			'me'      => array('pts' => $scoreMe['pts'], 'rank' => $scoreMe['rank']),
			'scoreMe' => $scoreMe,
			'meName'  => $meName,
			'meAlly'  => $meAlly,
			'home'    => array(
				'g' => (int)$PLANET['galaxy'],
				's' => (int)$PLANET['system'],
				'p' => (int)$PLANET['planet'],
			),
		);
	}

	// ============================================================
	// TOP 10 DEL UNIVERSO (misma tabla %%STATPOINTS%% que las
	// estadísticas clásicas) con las coordenadas del planeta
	// principal de cada jugador, para viajar a su sistema.
	// ============================================================
	public static function getTop()
	{
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

		$score3d = array();
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

		return array_merge(self::getMe(), array('score' => $score3d));
	}

	// ============================================================
	// Paquete JSON completo del visor 3D (página y API fetch)
	// ============================================================
	public static function buildAstro3d($galaxy, $system, $datos)
	{
		global $USER, $PLANET, $THEME, $LNG;

		// ✅ FIX port: $config no es global en este juego; se obtiene del singleton
		$config = Config::get();

		$Result         = $datos['result'];
		$asteroids      = $datos['asteroids'];
		$incomingFleets = $datos['incoming'];
		$climasGalaxy   = $datos['climas'];

		$maxPlanets3d = (int)$config->max_planets;
		$shortStatus3d = array(
			'vacation'      => $LNG['gl_short_vacation'],
			'banned'        => $LNG['gl_short_ban'],
			'inactive'      => $LNG['gl_short_inactive'],
			'longinactive'  => $LNG['gl_short_long_inactive'],
			'noob'          => $LNG['gl_short_newbie'],
			'strong'        => $LNG['gl_short_strong'],
			'enemy'         => $LNG['gl_short_enemy'],
			'friend'        => $LNG['gl_short_friend'],
			'member'        => $LNG['gl_short_member'],
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

		// TOP 10 + puntuación propia (misma fuente que la API r=top)
		$top3d = self::getTop();

		return array(
			'ok'         => true,
			'galaxy'     => (int)$galaxy,
			'system'     => (int)$system,
			'maxPlanets' => $maxPlanets3d,
			'maxGalaxy'  => (int)$config->max_galaxy,
			'maxSystem'  => (int)$config->max_system,
			'dpath'      => ($THEME && method_exists($THEME, 'getTheme')) ? $THEME->getTheme() : 'styles/theme/'.DEFAULT_THEME.'/',
			'curGalaxy'  => (int)$PLANET['galaxy'],
			'curSystem'  => (int)$PLANET['system'],
			'curPlanet'  => (int)$PLANET['planet'],
			'meName'     => $top3d['meName'],
			'meAlly'     => $top3d['meAlly'],
			'me'         => $top3d['me'],
			'scoreMe'    => $top3d['scoreMe'],
			'score'      => $top3d['score'],
			'short'      => $shortStatus3d,
			'rows'       => $astro3dRows,
		);
	}

	// ============================================================
	// Atajo para la página y la API: todo el paquete del sistema
	// ============================================================
	public static function datosCompletos($galaxy, $system)
	{
		return self::buildAstro3d($galaxy, $system, self::cargarGalaxia($galaxy, $system));
	}

	// ============================================================
	// Misiones disponibles en una posición (API r=missions).
	// Sirve para que las APKs pinten sus botones con las mismas
	// reglas que el visor 3D y la tabla clásica.
	// ============================================================
	public static function getAccion($galaxy, $system, $planet)
	{
		$datos  = self::cargarGalaxia($galaxy, $system);
		$Result = $datos['result'];
		$ast    = isset($datos['asteroids'][(int)$planet]) ? 1 : 0;
		$p      = (int)$planet;

		if (isset($Result[$p]) && is_array($Result[$p])) {
			$g3 = $Result[$p];
			$ms3 = array();
			if (!empty($g3['missions']) && is_array($g3['missions'])) {
				foreach ($g3['missions'] as $mid3 => $mok3) {
					if ($mok3) { $ms3[] = (int)$mid3; }
				}
			}
			return array(
				'ok'    => true,
				't'     => 'p',
				'pos'   => $p,
				'own'   => !empty($g3['ownPlanet']) ? 1 : 0,
				'pid'   => (int)$g3['planet']['id'],
				'name'  => (string)$g3['planet']['name'],
				'uname' => (string)$g3['user']['username'],
				'ms'    => $ms3,
				'actBtns' => array(
					'esp' => !empty($g3['action']['esp']) ? 1 : 0,
					'msg' => !empty($g3['action']['message']) ? 1 : 0,
					'bud' => !empty($g3['action']['buddy']) ? 1 : 0,
					'mis' => !empty($g3['action']['missle']) ? 1 : 0,
				),
				'deb'   => !empty($g3['debris']) ? array('m' => (int)$g3['debris']['metal'], 'c' => (int)$g3['debris']['crystal']) : 0,
				'ast'   => $ast,
				'moon'  => !empty($g3['moon']) ? array('id' => (int)$g3['moon']['id'], 'dia' => (int)$g3['moon']['diameter']) : 0,
				'phx'   => !empty($g3['planet']['phalanx']) ? 1 : 0,
				'depo'  => !empty($g3['planet']['ally_deposit']) ? 1 : 0,
			);
		} elseif (isset($Result[$p])) {
			return array('ok' => true, 't' => 'r', 'pos' => $p, 'ast' => $ast);
		}
		return array('ok' => true, 't' => 'e', 'pos' => $p, 'ast' => $ast, 'colonizable' => $ast ? 0 : 1);
	}
}
?>
