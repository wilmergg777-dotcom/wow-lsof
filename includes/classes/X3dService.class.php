<?php

/**
 * XNOVA3D (rama xnova3d) — Servicio de datos del ESCRITORIO 3D.
 *
 * Una única fuente de datos para:
 *   - game.php?page=x3d&modo=fetch&modo=base|hangar|lab|imperio|flotas (visor 3D)
 *   - api/index.php?r=x3d&modo=...                                    (APKs)
 *
 * TODO sale del MISMO juego: tablas reales, costos/tiempos con BuildFunctions
 * (los mismos cálculos que las páginas clásicas de Edificios / Investigación /
 * Naves / Defensas) e imágenes REALES del tema (styles/theme/gow/gebaeude y
 * planeten). El 3D nunca calcula reglas: solo muestra y envía acciones.
 */

require_once('includes/classes/class.BuildFunctions.php');
require_once('includes/classes/class.FleetFunctions.php');

class X3dService
{
	/** dpath real del tema (imágenes del juego) */
	public static function dpath()
	{
		global $THEME;
		return ($THEME && method_exists($THEME, 'getTheme')) ? $THEME->getTheme() : './styles/theme/gow/';
	}

	/** imagen real de un elemento (edificio / investigación / nave / defensa) */
	private static function imgElemento($id)
	{
		return self::dpath() . 'gebaeude/' . (int)$id . '.gif';
	}

	/** mapa de costos reducido a lo que el HUD muestra */
	private static function costos($precio)
	{
		global $resource;
		$out = array('metal' => 0, 'cristal' => 0, 'deuterio' => 0);
		if (isset($precio[$resource[901]])) $out['metal']    = (int)$precio[$resource[901]];
		if (isset($precio[$resource[902]])) $out['cristal']  = (int)$precio[$resource[902]];
		if (isset($precio[$resource[903]])) $out['deuterio'] = (int)$precio[$resource[903]];
		return $out;
	}

	/** cabecera común: planeta actual + recursos + usuario (los "recursos del HUD") */
	public static function esquinas()
	{
		global $PLANET, $USER, $resource, $LNG;

		return array(
			'dpath' => self::dpath(),
			'usuario' => array(
				'nombre' => (string)$USER['username'],
				'dm'     => (int)$USER['darkmatter'],
			),
			'planeta' => array(
				'id'     => (int)$PLANET['id'],
				'nombre' => (string)$PLANET['name'],
				'tipo'   => (int)$PLANET['planet_type'],
				'coords' => (int)$PLANET['galaxy'] . ':' . (int)$PLANET['system'] . ':' . (int)$PLANET['planet'],
				'img'    => (string)$PLANET['image'],
				'imgUrl' => self::dpath() . 'planeten/' . $PLANET['image'] . '.jpg',
				'campos' => array('usados' => (int)$PLANET['field_current'], 'max' => (int)CalculateMaxPlanetFields($PLANET)),
			),
			'recursos' => array(
				'metal'    => array('val' => floor($PLANET['metal']),    'max' => (int)$PLANET['metal_max']),
				'cristal'  => array('val' => floor($PLANET['crystal']),  'max' => (int)$PLANET['crystal_max']),
				'deuterio' => array('val' => floor($PLANET['deuterium']), 'max' => (int)$PLANET['deuterium_max']),
			),
			'energia' => array(
				'usado' => (int)$PLANET['energy'],
				'max'   => (int)$PLANET['energy_max'],
			),
		);
	}

	/** BASE 3D: edificios del planeta actual (imagen real + costo + tiempo + cola) */
	public static function base()
	{
		global $LNG, $resource, $reslist, $PLANET, $USER;

		$edificios = array();
		$permitidos = isset($reslist['allow'][$PLANET['planet_type']]) ? $reslist['allow'][$PLANET['planet_type']] : array();
		foreach ($permitidos as $id) {
			if (!in_array($id, $reslist['build'])) continue;
			if (!BuildFunctions::isTechnologieAccessible($USER, $PLANET, $id)) continue;

			$nivel   = (int)$PLANET[$resource[$id]];
			$costo   = BuildFunctions::getElementPrice($USER, $PLANET, $id, false, $nivel + 1);
			$seg     = BuildFunctions::getBuildingTime($USER, $PLANET, $id, $costo);
			$costoDe = BuildFunctions::getElementPrice($USER, $PLANET, $id, true);

			$edificios[] = array(
				'id'        => (int)$id,
				'nombre'    => (string)$LNG['tech'][$id],
				'img'       => self::imgElemento($id),
				'nivel'     => $nivel,
				'costo'     => self::costos($costo),
				'segundos'  => (int)$seg,
				'comprable' => (bool)BuildFunctions::isElementBuyable($USER, $PLANET, $id, $costo, false, $nivel + 1),
				'destruirCosto' => self::costos($costoDe),
				'destruible'    => $nivel > 0 && (bool)BuildFunctions::isElementBuyable($USER, $PLANET, $id, $costoDe, true),
			);
		}

		// cola de construcción (mismo formato que ShowBuildingsPage::getQueueData)
		$cola = array();
		if ($PLANET['b_building'] != 0 && $PLANET['b_building_id'] != '') {
			$buildQueue = unserialize($PLANET['b_building_id']);
			if (is_array($buildQueue)) {
				foreach ($buildQueue as $b) {
					if (empty($b[0]) || $b[3] < TIMESTAMP) continue;
					$cola[] = array(
						'id'       => (int)$b[0],
						'nombre'   => (string)$LNG['tech'][$b[0]],
						'img'      => self::imgElemento($b[0]),
						'nivel'    => (int)$b[1],
						'restante' => max(0, (int)($b[3] - TIMESTAMP)),
						'destruir' => ($b[4] == 'destroy'),
					);
				}
			}
		}

		$esq = self::esquinas();
		return array(
			'esquinas'  => $esq,
			'edificios' => $edificios,
			'cola'      => $cola,
			'limiteCola' => (int)Config::get()->max_elements_build + (int)$PLANET['droids_builder'],
		);
	}

	/** HANGAR 3D: naves y defensas del planeta actual (imagen real + conteo + cola) */
	public static function hangar()
	{
		global $LNG, $resource, $reslist, $PLANET, $USER;

		$lista = function ($grupo, $esMissil) use ($LNG, $resource, $reslist, $PLANET, $USER) {
			$out = array();
			$permitidos = isset($reslist['allow'][$PLANET['planet_type']]) ? $reslist['allow'][$PLANET['planet_type']] : array();
			foreach ($reslist[$grupo] as $id) {
				if (!in_array($id, $permitidos)) continue;
				if (!BuildFunctions::isTechnologieAccessible($USER, $PLANET, $id)) continue;

				$max = ($esMissil && in_array($id, $reslist['missile']))
					? (int)BuildFunctions::getMaxConstructibleRockets($USER, $PLANET)
					: (int)BuildFunctions::getMaxConstructibleElements($USER, $PLANET, $id);

				$out[] = array(
					'id'        => (int)$id,
					'nombre'    => (string)$LNG['tech'][$id],
					'img'       => self::imgElemento($id),
					'tengo'     => (int)$PLANET[$resource[$id]],
					'costo'     => self::costos(BuildFunctions::getElementPrice($USER, $PLANET, $id)),
					'segundos'  => (int)BuildFunctions::getBuildingTime($USER, $PLANET, $id),
					'maxConstruible' => $max,
				);
			}
			return $out;
		};

		// colas de naves y defensas (mismo formato que ShowShipyardPage)
		$cola = function ($queueField, $timeField) use ($LNG, $PLANET, $USER) {
			$out = array('items' => array(), 'restante' => 0);
			$ElementQueue = $PLANET[$queueField] != '' ? unserialize($PLANET[$queueField]) : array();
			if (is_array($ElementQueue)) {
				$total = 0;
				$idx = 0;
				foreach ($ElementQueue as $e) {
					if (empty($e)) { $idx++; continue; }
					$segU = (int)BuildFunctions::getBuildingTime($USER, $PLANET, $e[0]);
					$tiempoCola = $segU * (int)$e[1];
					$total += $tiempoCola;
					$out['items'][] = array(
						'idx'      => $idx,
						'id'       => (int)$e[0],
						'nombre'   => (string)$LNG['tech'][$e[0]],
						'img'      => self::imgElemento($e[0]),
						'cantidad' => (int)$e[1],
						'segUnidad' => $segU,
					);
					$idx++;
				}
				$out['restante'] = max(0, $total - (int)$PLANET[$timeField]);
			}
			return $out;
		};

		return array(
			'esquinas' => self::esquinas(),
			'naves'    => $lista('fleet', false),
			'defensas' => array_merge($lista('defense', true), $lista('missile', true)),
			'colaNaves'    => $cola('b_hangar_id', 'b_hangar'),
			'colaDefensas' => $cola('b_defense_id', 'b_defense'),
		);
	}

	/** LABORATORIO 3D: investigaciones (imagen real + costo + tiempo + cola) */
	public static function lab()
	{
		global $LNG, $resource, $reslist, $PLANET, $USER;

		$techs = array();
		foreach ($reslist['tech'] as $id) {
			if (!BuildFunctions::isTechnologieAccessible($USER, $PLANET, $id)) continue;

			$costo = BuildFunctions::getElementPrice($USER, $PLANET, $id);
			$techs[] = array(
				'id'        => (int)$id,
				'nombre'    => (string)$LNG['tech'][$id],
				'img'       => self::imgElemento($id),
				'nivel'     => (int)$USER[$resource[$id]],
				'costo'     => self::costos($costo),
				'segundos'  => (int)BuildFunctions::getBuildingTime($USER, $PLANET, $id, $costo),
				'comprable' => (bool)BuildFunctions::isElementBuyable($USER, $PLANET, $id, $costo),
			);
		}

		// cola de investigación (mismo formato que ShowResearchPage)
		$cola = array();
		if ($USER['b_tech_queue'] != '') {
			$CurrentQueue = unserialize($USER['b_tech_queue']);
			if (is_array($CurrentQueue)) {
				foreach ($CurrentQueue as $q) {
					if (empty($q[0]) || $q[3] < TIMESTAMP) continue;
					$cola[] = array(
						'id'       => (int)$q[0],
						'nombre'   => (string)$LNG['tech'][$q[0]],
						'img'      => self::imgElemento($q[0]),
						'nivel'    => (int)$q[1],
						'restante' => max(0, (int)($q[3] - TIMESTAMP)),
					);
				}
			}
		}

		$otroPlaneta = 0;
		if (!empty($USER['b_tech_planet']) && (int)$USER['b_tech_planet'] !== (int)$PLANET['id']) {
			$otroPlaneta = (int)$USER['b_tech_planet'];
		}

		return array(
			'esquinas'  => self::esquinas(),
			'techs'     => $techs,
			'cola'      => $cola,
			'enOtroPlaneta' => $otroPlaneta,
		);
	}

	/** IMPERIO 3D: todos los planetas y lunas del jugador (texturas reales) */
	public static function imperio()
	{
		global $LNG, $resource, $USER;

		$rows = Database::get()->select(
			'SELECT id, name, planet_type, galaxy, system, planet, image, diameter, field_current,
			 metal, crystal, deuterium, `' . $resource[1] . '`, `' . $resource[2] . '`, `' . $resource[3] . '`, `' . $resource[21] . '`, `' . $resource[31] . '`
			 FROM %%PLANETS%% WHERE id_owner = :uid AND destruyed = 0
			 ORDER BY galaxy, system, planet, planet_type',
			array(':uid' => (int)$USER['id'])
		);

		$planetas = array();
		foreach ($rows as $row) {
			$planetas[] = array(
				'id'       => (int)$row['id'],
				'nombre'   => (string)$row['name'],
				'tipo'     => (int)$row['planet_type'],
				'coords'   => (int)$row['galaxy'] . ':' . (int)$row['system'] . ':' . (int)$row['planet'],
				'img'      => (string)$row['image'],
				'imgUrl'   => self::dpath() . 'planeten/' . $row['image'] . '.jpg',
				'diametro' => (int)$row['diameter'],
				'campos'   => array('usados' => (int)$row['field_current'], 'max' => (int)CalculateMaxPlanetFields($row)),
				'recursos' => array(
					'metal'    => (int)$row['metal'],
					'cristal'  => (int)$row['crystal'],
					'deuterio' => (int)$row['deuterium'],
				),
				'minas' => array(
					'metal'    => (int)$row[$resource[1]],
					'cristal'  => (int)$row[$resource[2]],
					'deuterio' => (int)$row[$resource[3]],
					'hangar'   => (int)$row[$resource[21]],
					'laboratorio' => (int)$row[$resource[31]],
				),
			);
		}

		return array('esquinas' => self::esquinas(), 'planetas' => $planetas);
	}

	/** FLOTAS 3D: flotas en vuelo del jugador (datos reales de uni1_fleets) */
	public static function flotas()
	{
		global $LNG, $USER;

		$rows = Database::get()->select(
			'SELECT fleet_mission, fleet_mess, fleet_array, fleet_start_galaxy, fleet_start_system,
			 fleet_start_planet, fleet_start_type, fleet_end_galaxy, fleet_end_system, fleet_end_planet,
			 fleet_end_type, fleet_start_time, fleet_end_time
			 FROM %%FLEETS%% WHERE fleet_owner = :uid ORDER BY fleet_end_time',
			array(':uid' => (int)$USER['id'])
		);

		$flotas = array();
		foreach ($rows as $row) {
			$naves = array();
			$totalNaves = 0;
			$arr = unserialize($row['fleet_array']);
			if (is_array($arr)) {
				foreach ($arr as $shipId => $cnt) {
					$shipId = (int)$shipId;
					if ($shipId <= 0 || (int)$cnt <= 0) continue;
					$naves[] = array(
						'id'       => $shipId,
						'nombre'   => (string)$LNG['tech'][$shipId],
						'img'      => self::imgElemento($shipId),
						'cantidad' => (int)$cnt,
					);
					$totalNaves += (int)$cnt;
				}
			}

			$flotas[] = array(
				'mision'  => (int)$row['fleet_mission'],
				'misionNombre' => isset($LNG['type_mission_' . $row['fleet_mission']]) ? (string)$LNG['type_mission_' . $row['fleet_mission']] : '#' . (int)$row['fleet_mission'],
				'volviendo' => ((int)$row['fleet_mess'] == 1),
				'origen'  => (int)$row['fleet_start_galaxy'] . ':' . (int)$row['fleet_start_system'] . ':' . (int)$row['fleet_start_planet'] . ' #' . (int)$row['fleet_start_type'],
				'destino' => (int)$row['fleet_end_galaxy'] . ':' . (int)$row['fleet_end_system'] . ':' . (int)$row['fleet_end_planet'] . ' #' . (int)$row['fleet_end_type'],
				'llegada' => max(0, (int)($row['fleet_end_time'] - TIMESTAMP)),
				'regreso' => max(0, (int)($row['fleet_start_time'] - TIMESTAMP)),
				'naves'   => $naves,
				'totalNaves' => $totalNaves,
			);
		}

		return array(
			'esquinas' => self::esquinas(),
			'flotas'   => $flotas,
			'slots'    => array('usados' => count($flotas), 'max' => (int)FleetFunctions::GetMaxFleetSlots($USER)),
		);
	}

	/** router del fetch / API */
	public static function todo($modo)
	{
		switch ($modo) {
			case 'hangar':  return self::hangar();
			case 'lab':     return self::lab();
			case 'imperio': return self::imperio();
			case 'flotas':  return self::flotas();
			default:        return self::base();
		}
	}
}
