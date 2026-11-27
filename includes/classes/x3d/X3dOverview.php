<?php

/**
 * XNOVA3D — MÓDULO RESUMEN (la vista principal del juego en 3D).
 *
 * Es lo primero que ve el jugador al entrar al escritorio 3D: su planeta
 * con la IMAGEN REAL del juego, la producción por hora, las colas reales
 * (edificios / investigación / naves), las flotas en vuelo y su luna.
 * Mismos cálculos y campos que ShowOverviewPage (BuildFunctions, colas
 * serializadas b_building_id / b_tech_queue / b_hangar_id).
 * Para corregir el RESUMEN toca SOLO este archivo.
 */

class X3dOverview
{
	public static function overview()
	{
		global $LNG, $PLANET, $USER;

		/* ---------- planeta actual (igual que ShowOverviewPage) ---------- */
		$esTipoLuna = ((int)$PLANET['planet_type'] == 3);
		$planeta = array(
			'nombre'    => (string)$PLANET['name'],
			'coords'    => (int)$PLANET['galaxy'] . ':' . (int)$PLANET['system'] . ':' . (int)$PLANET['planet'],
			'imgUrl'    => X3dCore::dpath() . 'planeten/' . $PLANET['image'] . '.jpg',
			'tipo'      => (int)$PLANET['planet_type'],
			'tipoNombre' => $esTipoLuna ? 'Luna' : 'Planeta',
			'diametro'  => (int)$PLANET['diameter'],
			'tempMin'   => (int)$PLANET['temp_min'],
			'tempMax'   => (int)$PLANET['temp_max'],
			'campos'    => array('usados' => (int)$PLANET['field_current'], 'max' => (int)CalculateMaxPlanetFields($PLANET)),
		);

		/* ---------- luna del planeta (id_luna, como el overview clásico) ---------- */
		$luna = null;
		if ((int)$PLANET['id_luna'] != 0) {
			$rowLuna = Database::get()->selectSingle(
				'SELECT name, image, diameter FROM %%PLANETS%% WHERE id = :lunaID;',
				array(':lunaID' => (int)$PLANET['id_luna'])
			);
			if (!empty($rowLuna)) {
				$luna = array(
					'nombre'   => (string)$rowLuna['name'],
					'imgUrl'   => X3dCore::dpath() . 'planeten/' . $rowLuna['image'] . '.jpg',
					'diametro' => (int)$rowLuna['diameter'],
				);
			}
		}

		/* ---------- producción por hora (columnas reales de uni1_planets) ---------- */
		$produccion = array(
			'metal'    => (int)$PLANET['metal_perhour'],
			'cristal'  => (int)$PLANET['crystal_perhour'],
			'deuterio' => (int)$PLANET['deuterium_perhour'],
		);

		/* ---------- cola de EDIFICIOS (misma lectura que X3dBase) ---------- */
		$colaEdificios = array();
		if ($PLANET['b_building'] != 0 && $PLANET['b_building_id'] != '') {
			$buildQueue = unserialize($PLANET['b_building_id']);
			if (is_array($buildQueue)) {
				foreach ($buildQueue as $b) {
					if (empty($b[0]) || $b[3] < TIMESTAMP) continue;
					$colaEdificios[] = array(
						'id'       => (int)$b[0],
						'nombre'   => (string)$LNG['tech'][$b[0]],
						'img'      => X3dCore::imgElemento($b[0]),
						'nivel'    => (int)$b[1],
						'restante' => max(0, (int)($b[3] - TIMESTAMP)),
						'destruir' => ($b[4] == 'destroy'),
					);
				}
			}
		}

		/* ---------- cola de INVESTIGACIÓN (b_tech_queue, como el clásico) ---------- */
		$colaInvestigacion = array();
		if ($USER['b_tech'] - TIMESTAMP > 0) {
			$techQueue = unserialize($USER['b_tech_queue']);
			if (is_array($techQueue) && !empty($techQueue[0][0])) {
				$colaInvestigacion[] = array(
					'id'       => (int)$techQueue[0][0],
					'nombre'   => (string)$LNG['tech'][$techQueue[0][0]],
					'img'      => X3dCore::imgElemento($techQueue[0][0]),
					'nivel'    => (int)$techQueue[0][1],
					'restante' => max(0, (int)($USER['b_tech'] - TIMESTAMP)),
				);
			}
		}

		/* ---------- cola de NAVES (b_hangar_id, como el clásico) ---------- */
		$colaNaves = array();
		if (!empty($PLANET['b_hangar_id'])) {
			$hangarQueue = unserialize($PLANET['b_hangar_id']);
			if (is_array($hangarQueue) && !empty($hangarQueue[0][0])) {
				$seg = BuildFunctions::getBuildingTime($USER, $PLANET, $hangarQueue[0][0]) * $hangarQueue[0][1];
				$colaNaves[] = array(
					'id'       => (int)$hangarQueue[0][0],
					'nombre'   => (string)$LNG['tech'][$hangarQueue[0][0]],
					'img'      => X3dCore::imgElemento($hangarQueue[0][0]),
					'cantidad' => (int)$hangarQueue[0][1],
					'restante' => max(0, (int)($seg - $PLANET['b_hangar'])),
				);
			}
		}

		/* ---------- flotas en vuelo (reutiliza el módulo FLOTAS) ---------- */
		$datosFlotas = X3dFlotas::flotas();

		/* ---------- accesos rápidos a los módulos del escritorio 3D ---------- */
		$enlaces = array(
			array('escena' => 'base',    'nombre' => 'Construir'),
			array('escena' => 'hangar',  'nombre' => 'Naves'),
			array('escena' => 'lab',     'nombre' => 'Investigar'),
			array('escena' => 'flotas',  'nombre' => 'Flotas'),
			array('escena' => 'imperio', 'nombre' => 'Imperio'),
		);

		return array(
			'esquinas'   => X3dCore::esquinas(),
			'planeta'    => $planeta,
			'luna'       => $luna,
			'produccion' => $produccion,
			'colas'      => array(
				'construccion'  => $colaEdificios,
				'investigacion' => $colaInvestigacion,
				'naves'         => $colaNaves,
			),
			'flotas'     => $datosFlotas['flotas'],
			'slots'      => $datosFlotas['slots'],
			'enlaces'    => $enlaces,
		);
	}
}
