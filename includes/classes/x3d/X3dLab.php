<?php

/**
 * XNOVA3D — MÓDULO INVESTIGACIÓN (laboratorio).
 *
 * Mismos cálculos que ShowResearchPage: costos/tiempos con BuildFunctions,
 * niveles de uni1_users, cola real b_tech_queue y laboratorio ocupado
 * en otro planeta. Para corregir la INVESTIGACIÓN toca SOLO este archivo.
 */

class X3dLab
{
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
				'img'       => X3dCore::imgElemento($id),
				'nivel'     => (int)$USER[$resource[$id]],
				'costo'     => X3dCore::costos($costo),
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
						'img'      => X3dCore::imgElemento($q[0]),
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
			'esquinas'      => X3dCore::esquinas(),
			'techs'         => $techs,
			'cola'          => $cola,
			'enOtroPlaneta' => $otroPlaneta,
		);
	}
}
