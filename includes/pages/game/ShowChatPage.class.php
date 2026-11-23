<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */

class ShowChatPage extends AbstractGamePage
{
	public static $requireModule = MODULE_CHAT;

	function __construct() 
	{
		parent::__construct();
	}
	
	function show()
	{
		$action	= HTTP::_GP('action', '');

		/* ASTROIO: contador de mensajes no leídos para el chat flotante
		   (JSON: General = canal 0, Alianza = canal ally_id + 100, ver CustomAJAXChat) */
		if($action == 'unread') {
			$this->unreadCount();
		}

		if($action == 'alliance') {
			$this->setWindow('popup');
			$this->initTemplate();
		}

		$this->display('page.chat.default.tpl');
	}

	/* ASTROIO: devuelve {gen, ally, latestGen, latestAlly, hasAlly} en JSON.
	   Los conteos se calculan contra el último mensaje leído (genLast/allyLast),
	   que el chat flotante guarda en localStorage del navegador. */
	private function unreadCount()
	{
		global $USER;

		$genLast	= (int) HTTP::_GP('genLast', 0);
		$allyLast	= (int) HTTP::_GP('allyLast', 0);
		$allyId		= (int) $USER['ally_id'];
		$db			= Database::get();

		$out = array(
			'gen' => 0, 'ally' => 0,
			'latestGen' => 0, 'latestAlly' => 0,
			'hasAlly' => false,
		);

		$sql = 'SELECT COALESCE(MAX(id), 0) AS latest, SUM(id > :last) AS unread
				FROM %%CHAT_MES%% WHERE channel = :channel';

		$row = $db->selectSingle($sql, array(':last' => $genLast, ':channel' => 0));
		$out['latestGen']	= (int) $row['latest'];
		$out['gen']			= (int) $row['unread'];

		if($allyId > 0) {
			$row = $db->selectSingle($sql, array(':last' => $allyLast, ':channel' => $allyId + 100));
			$out['latestAlly']	= (int) $row['latest'];
			$out['ally']		= (int) $row['unread'];
			$out['hasAlly']		= true;
		}

		echo json_encode($out);
		exit;
	}
}
