<?php

/**
 * XNOVA3D — MÓDULO IMPERIO (todos los planetas y lunas del jugador).
 *
 * Datos reales de uni1_planets con texturas reales (planeten/{img}.jpg).
 * Para corregir el IMPERIO toca SOLO este archivo.
 */

class X3dImperio
{
	public static function imperio()
	{
		global $resource, $USER;

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
				'imgUrl'   => X3dCore::dpath() . 'planeten/' . $row['image'] . '.jpg',
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

		return array('esquinas' => X3dCore::esquinas(), 'planetas' => $planetas);
	}
}
