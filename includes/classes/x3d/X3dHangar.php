<?php

/**
 * XNOVA3D — MÓDULO HANGAR (naves y defensas del planeta actual).
 *
 * Mismos cálculos que ShowShipyardPage: costos/tiempos con BuildFunctions,
 * máximo construible (recursos y misiles), colas reales b_hangar_id y
 * b_defense_id. Para corregir el HANGAR toca SOLO este archivo.
 */

class X3dHangar
{
	private static function lista($grupo, $esMissil)
	{
		global $LNG, $resource, $reslist, $PLANET, $USER;

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
				'img'       => X3dCore::imgElemento($id),
				'tengo'     => (int)$PLANET[$resource[$id]],
				'costo'     => X3dCore::costos(BuildFunctions::getElementPrice($USER, $PLANET, $id)),
				'segundos'  => (int)BuildFunctions::getBuildingTime($USER, $PLANET, $id),
				'maxConstruible' => $max,
			);
		}
		return $out;
	}

	/** cola del hangar (naves) o de defensas — formato real de ShowShipyardPage */
	private static function cola($queueField, $timeField)
	{
		global $LNG, $PLANET, $USER;

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
					'img'      => X3dCore::imgElemento($e[0]),
					'cantidad' => (int)$e[1],
					'segUnidad' => $segU,
				);
				$idx++;
			}
			$out['restante'] = max(0, $total - (int)$PLANET[$timeField]);
		}
		return $out;
	}

	public static function hangar()
	{
		return array(
			'esquinas'     => X3dCore::esquinas(),
			'naves'        => self::lista('fleet', false),
			'defensas'     => array_merge(self::lista('defense', true), self::lista('missile', true)),
			'colaNaves'    => self::cola('b_hangar_id', 'b_hangar'),
			'colaDefensas' => self::cola('b_defense_id', 'b_defense'),
		);
	}
}
