<?php

/**
 *  2Moons
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ✅ AstroIO v1.4 (PHP 8.2 — Fix Timer & Username):
 *   - Fix getUsername() inexistente reemplazado por helper interno.
 *   - Fix $timeLeft: aseguramos que el tiempo enviado al TPL no sea negativo.
 */

class ShowTourneyPage extends AbstractGamePage
{
	public static $requireModule = MODULE_TOURNEY;

	function __construct()
	{
		parent::__construct();
	}

	private function getUsernameById(int $userId): string
	{
		$db = Database::get();
		$username = $db->selectSingle(
			"SELECT `username` FROM %%USERS%% WHERE `id` = :userID;",
			array(':userID' => $userId),
			'username'
		);
		return (is_string($username) && $username !== '') ? $username : 'Desconocido';
	}

	function show()
	{
		global $USER, $LNG;

		$touneyGroup   = HTTP::_GP('group', 1);
		$touneyGroupOK = array(1, 2, 3, 4, 5);

		if (!in_array($touneyGroup, $touneyGroupOK)) {
			$touneyGroup = 1;
		}

		$db = Database::get();

		$sql = "SELECT * FROM %%TOURNEY%% WHERE tourneyId = :tourneyId;";
		$tourneyDetail = $db->selectSingle($sql, array(
			':tourneyId' => $touneyGroup,
		));

		if (!is_array($tourneyDetail) || empty($tourneyDetail)) {
			$this->printMessage(
				'Los Mini Torneos se están generando. Volvé en unos minutos cuando el sistema haya sorteado la primera tanda.',
				NULL,
				array('game.php?page=overview', 3)
			);
			return;
		}

		if ($_SERVER['REQUEST_METHOD'] === 'POST') {
			if (Config::get()->tourneyEnd < TIMESTAMP) {
				$this->printMessage(
					$LNG['tourney_end'],
					NULL,
					array('game.php?page=tourney', 3)
				);
			}

			$sql = "SELECT * FROM %%TOURNEYPARTICI%%
					WHERE tourneyJoin = :tourneyJoin
					  AND playerId    = :playerId
					LIMIT 1;";
			$tourneyCheck = $db->selectSingle($sql, array(
				':tourneyJoin' => $touneyGroup,
				':playerId'    => $USER['id'],
			));

			if (is_array($tourneyCheck) && !empty($tourneyCheck)) {
				$this->printMessage(
					'Ya estás inscripto en este torneo.',
					NULL,
					array('game.php?page=tourney&group='.$touneyGroup, 3)
				);
			}

			$sql = "INSERT INTO %%TOURNEYPARTICI%%
					SET playerId     = :playerId,
					    joinTime     = :joinTime,
					    tourneyJoin  = :tourneyJoin,
					    tourneyUnits = 0;";
			$db->insert($sql, array(
				':playerId'    => $USER['id'],
				':joinTime'    => TIMESTAMP,
				':tourneyJoin' => $touneyGroup,
			));

			$this->printMessage(
				'¡Te inscribiste correctamente en el torneo!',
				NULL,
				array('game.php?page=tourney&group='.$touneyGroup, 3)
			);
		}

		$sql = "SELECT * FROM %%TOURNEYPARTICI%%
				WHERE tourneyJoin = :tourneyJoin
				  AND playerId    = :playerId
				LIMIT 1;";
		$tourneyCheck = $db->selectSingle($sql, array(
			':tourneyJoin' => $touneyGroup,
			':playerId'    => $USER['id'],
		));

		$sql = "SELECT * FROM %%TOURNEYPARTICI%%
				WHERE tourneyJoin = :tourneyJoin
				ORDER BY tourneyUnits DESC
				LIMIT 50;";
		$tourneyPlayers = $db->select($sql, array(
			':tourneyJoin' => $touneyGroup,
		));

		$playerList = array();

		if (is_array($tourneyPlayers)) {
			foreach ($tourneyPlayers as $Player) {
				$playerList[$Player['playerId']] = array(
					'tourneyUnits' => pretty_number($Player['tourneyUnits']),
					'playerName'   => $this->getUsernameById((int)$Player['playerId']),
				);
			}
		}

		$descripcionKey = 'tourney_'.$tourneyDetail['tourneyEvent'];
		$descripcion = isset($LNG[$descripcionKey]) ? $LNG[$descripcionKey] : 'Descripción no disponible.';

		$timeLeft = Config::get()->tourneyEnd - TIMESTAMP;
		if ($timeLeft < 0) {
			$timeLeft = 0;
		}

		$this->assign(array(
			'tourneyCheck'    => (empty($tourneyCheck) && Config::get()->tourneyEnd > TIMESTAMP) ? 0 : 1,
			'playerList'      => $playerList,
			'touneyGroup'     => $touneyGroup,
			'tourneyEnd'      => $timeLeft,
			'tourneyDetail'   => $tourneyDetail,
			'tourneyDescrip'  => $descripcion,
			'isHistory'       => false,
		));

		$this->display('page.tourney.default.tpl');
	}

	function history()
	{
		global $USER, $LNG;
		$db = Database::get();

		$sql = "SELECT * FROM %%TOURNEYLOGS%% ORDER BY logId DESC LIMIT 100;";
		$logs = $db->select($sql, array());

		$winnerList = array();
		if (is_array($logs)) {
			foreach ($logs as $log) {
				$winnerList[] = array(
					'playerName'   => $this->getUsernameById((int)$log['playerId']),
					'tourneyUnits' => pretty_number($log['tourneyUnits']),
					'tourneyJoin'  => $log['tourneyJoin'],
				);
			}
		}

		$this->assign(array(
			'winnerList' => $winnerList,
		));

		$this->display('page.tourney.history.tpl');
	}
}