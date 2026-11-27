<?php

/**
 * XNOVA3D — MÓDULO BASE (edificios del planeta actual).
 *
 * Mismos cálculos que ShowBuildingsPage (BuildFunctions): costos, tiempos,
 * comprable, demoler. Cola real de uni1_planets (b_building_id).
 * Para corregir la BASE toca SOLO este archivo.
 */

class X3dBase
{
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
				'img'       => X3dCore::imgElemento($id),
				'nivel'     => $nivel,
				'costo'     => X3dCore::costos($costo),
				'segundos'  => (int)$seg,
				'comprable' => (bool)BuildFunctions::isElementBuyable($USER, $PLANET, $id, $costo, false, $nivel + 1),
				'destruirCosto' => X3dCore::costos($costoDe),
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
						'img'      => X3dCore::imgElemento($b[0]),
						'nivel'    => (int)$b[1],
						'restante' => max(0, (int)($b[3] - TIMESTAMP)),
						'destruir' => ($b[4] == 'destroy'),
					);
				}
			}
		}

		return array(
			'esquinas'  => X3dCore::esquinas(),
			'edificios' => $edificios,
			'cola'      => $cola,
			'limiteCola' => (int)Config::get()->max_elements_build + (int)$PLANET['droids_builder'],
		);
	}
}
