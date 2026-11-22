<?php

/**
 *  2Moons
 *  Copyright (C) 2011 Jan Kröpke
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @package 2Moons
 * @author Jan Kröpke <info@2moons.cc>
 * @copyright 2009 Lucky
 * @copyright 2011 Jan Kröpke <info@2moons.cc>
 * @license http://www.gnu.org/licenses/gpl.html GNU GPLv3 License
 * @version 1.7.0 (2011-12-10)
 * @info $Id$
 * @link http://code.google.com/p/2moons/
 */

require_once 'includes/classes/cronjob/CronjobTask.interface.php';

class TournamentCronJob implements CronjobTask
{
	// ✅ CAMBIO 1: Ahora dura 7 días (604800 segundos en vez de 86400)
	const CYCLE_SECONDS	= 604800; // 7 días
	const PRIZE_ONE		= 500;   // 1er lugar
	const PRIZE_TWO		= 300;   // 2do lugar
	const PRIZE_THREE	= 200;   // 3er lugar

	function run()
	{
		$config = Config::get();

		// Solo actúa si el ciclo actual ya venció
		if ($config->tourneyEnd >= TIMESTAMP) {
			return;
		}

		$db = Database::get();

		// -----------------------------------------------------------------
		// 1. Entregar premios del ciclo que acaba de terminar
		// -----------------------------------------------------------------
		$tourneyIds = array(1, 2, 3, 4, 5);

		// Limpiamos el historial ANTES de repartir (una sola vez, no por torneo)
		// ✅ Esto mantiene solo los ganadores del último torneo
		$db->delete('DELETE FROM %%TOURNEYLOGS%%;', array());

		foreach ($tourneyIds as $Ids) {

			// Top 3 de ese torneo (solo con puntos > 0)
			$sql = "SELECT * FROM %%TOURNEYPARTICI%%
					WHERE tourneyJoin = :tourneyJoin
					  AND tourneyUnits > 0
					ORDER BY tourneyUnits DESC
					LIMIT 3;";
			$totalPlayers = $db->select($sql, array(
				':tourneyJoin' => $Ids,
			));

			// Info del torneo (para saber su nombre y evento)
			$sql = "SELECT * FROM %%TOURNEY%% WHERE tourneyId = :tourneyId;";
			$tourneyDetail = $db->selectSingle($sql, array(
				':tourneyId' => $Ids,
			));

			if (empty($tourneyDetail)) {
				continue;
			}

			$priceArray = array(
				0 => self::PRIZE_ONE,
				1 => self::PRIZE_TWO,
				2 => self::PRIZE_THREE,
			);

			$countPrice = 0;

			foreach ($totalPlayers as $Winner) {

				// Sumar antimateria al ganador
				$sql = "UPDATE %%USERS%% SET antimatter = antimatter + :antimatter WHERE id = :userId;";
				$db->update($sql, array(
					':antimatter' => $priceArray[$countPrice],
					':userId'     => $Winner['playerId'],
				));

				// Guardar en historial de ganadores
				$sql = "INSERT INTO %%TOURNEYLOGS%%
						SET tourneyUnits = :tourneyUnits,
						    playerId     = :playerId,
						    joinTime     = :joinTime,
						    tourneyJoin  = :tourneyJoin;";
				$db->insert($sql, array(
					':tourneyUnits' => $Winner['tourneyUnits'],
					':playerId'     => $Winner['playerId'],
					':joinTime'     => $Winner['joinTime'],
					':tourneyJoin'  => $Winner['tourneyJoin'],
				));

				// Mensaje privado al ganador (tipo 4 = Sistema)
				$subject = '¡Ganaste un Mini Torneo!';
				$message = "¡Felicitaciones! Ganaste el torneo <b>".$tourneyDetail['tourneyName']."</b> "
				         . "obteniendo el puesto <b>#".($countPrice + 1)."</b>.<br><br>"
				         . "Has recibido <b>".pretty_number($priceArray[$countPrice])."</b> de Antimateria.<br><br>"
				         . "¡Seguí participando en los próximos torneos!";

				PlayerUtil::sendMessage(
					$Winner['playerId'],   // receptor
					0,                     // emisor (0 = sistema)
					'Sistema de Torneos',  // nombre emisor
					4,                     // tipo = Sistema
					$subject,
					$message,
					TIMESTAMP
				);

				$countPrice++;
			}
		}

		// -----------------------------------------------------------------
		// 2. Limpiar inscripciones y torneos del ciclo viejo
		// -----------------------------------------------------------------
		$db->delete('DELETE FROM %%TOURNEYPARTICI%%;', array());
		$db->delete('DELETE FROM %%TOURNEY%%;', array());

		// -----------------------------------------------------------------
		// 3. Sortear 5 torneos nuevos (sin repetir evento)
		// -----------------------------------------------------------------
		$AlowedEvents = array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
		$totalTourney = array(1, 2, 3, 4, 5);
		$tourneyNames = array('Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon');

		$countArray = 0;

		foreach ($totalTourney as $Tourney) {

			// array_rand devuelve una CLAVE, no el valor
			$randKey     = array_rand($AlowedEvents);
			$randEvent   = $AlowedEvents[$randKey];

			// Sacarlo para que no se repita
			unset($AlowedEvents[$randKey]);
			// Reindexar para que array_rand siga funcionando
			$AlowedEvents = array_values($AlowedEvents);

			$sql = "INSERT INTO %%TOURNEY%%
					SET tourneyId    = :tourneyId,
					    tourneyName  = :tourneyName,
					    priceOne     = :priceOne,
					    priceTwo     = :priceTwo,
					    priceThree   = :priceThree,
					    tourneyEvent = :tourneyEvent;";
			$db->insert($sql, array(
				':tourneyId'    => $Tourney,
				':tourneyName'  => $tourneyNames[$countArray],
				':priceOne'     => self::PRIZE_ONE,
				':priceTwo'     => self::PRIZE_TWO,
				':priceThree'   => self::PRIZE_THREE,
				':tourneyEvent' => $randEvent,
			));

			$countArray++;
		}

		// -----------------------------------------------------------------
		// 4. Notificar a los usuarios activos del nuevo ciclo
		// -----------------------------------------------------------------
		$timeToUpdate = TIMESTAMP;
		$sql = "SELECT DISTINCT id, lang FROM %%USERS%% WHERE onlinetime > :onlinetime;";
		$totalUsers = $db->select($sql, array(
			':onlinetime' => $timeToUpdate - (7 * 24 * 3600),
		));

		$langObjects = array();

		foreach ($totalUsers as $userInfo) {

			if (!isset($langObjects[$userInfo['lang']])) {
				$langObjects[$userInfo['lang']] = new Language($userInfo['lang']);
				$langObjects[$userInfo['lang']]->includeData(array('L18N', 'INGAME', 'TECH', 'CUSTOM'));
			}

			$LNG = $langObjects[$userInfo['lang']];

			$subject = '¡Nuevos Mini Torneos disponibles!';
			// ✅ CAMBIO 2: El mensaje ahora avisa que duran 7 días
			$message = "Se inició una nueva tanda de Mini Torneos.<br><br>"
			         . "Entrá a <b>Mini Torneos</b> desde el menú y participá.<br>"
			         . "Tenés <b>7 días</b> para inscribirte y sumar puntos.<br><br>"
			         . "¡Los 3 primeros de cada torneo ganan Antimateria!";

			PlayerUtil::sendMessage(
				$userInfo['id'],
				0,
				'Sistema de Torneos',
				4,
				$subject,
				$message,
				$timeToUpdate
			);
		}

		// -----------------------------------------------------------------
		// 5. Resetear el timer del ciclo (para TODOS los universos)
		// -----------------------------------------------------------------
		// Suma los 7 días (604800 segundos) al momento actual
		$nuevoEnd = TIMESTAMP + self::CYCLE_SECONDS;

		$sql = 'UPDATE %%CONFIG%% SET `tourneyEnd` = :tourneyEnd;';
		$db->update($sql, array(
			':tourneyEnd' => $nuevoEnd,
		));

		// Actualizar en memoria también para que el reloj cambie al instante
		$config->tourneyEnd = $nuevoEnd;
		$config->save();
	}
}