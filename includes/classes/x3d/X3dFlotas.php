<?php

/**
 * XNOVA3D — MÓDULO FLOTAS (flotas en vuelo del jugador).
 *
 * Datos reales de uni1_fleets con las naves reales (gebaeude/{id}.gif)
 * y slots con FleetFunctions::GetMaxFleetSlots (igual que fleetTable).
 * Para corregir las FLOTAS toca SOLO este archivo.
 */

class X3dFlotas
{
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
						'img'      => X3dCore::imgElemento($shipId),
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
			'esquinas' => X3dCore::esquinas(),
			'flotas'   => $flotas,
			'slots'    => array('usados' => count($flotas), 'max' => (int)FleetFunctions::GetMaxFleetSlots($USER)),
		);
	}
}
