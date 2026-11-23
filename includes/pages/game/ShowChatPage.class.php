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

		/* ASTROIO: mensajes del canal en JSON para el chat flotante nativo
		   (mockup8_3/8_4) — evita el iframe del chat viejo */
		if($action == 'messages') {
			$this->messagesJSON();
		}

		/* ASTROIO: enviar un mensaje desde el chat flotante nativo */
		if($action == 'send') {
			$this->sendMessage();
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

	/* ASTROIO: canal numérico (General = 0, Alianza = ally_id + 100).
	   $allyTag se rellena con el tag de la alianza; devuelve -1 si el canal
	   no está disponible (sin alianza). */
	private function channelID($channel, &$allyTag)
	{
		global $USER;

		$allyTag = '';

		if($channel === 'ally') {
			$allyId	= (int) $USER['ally_id'];
			if($allyId <= 0) {
				return -1;
			}
			$allyTag = (string) Database::get()->selectSingle('SELECT ally_tag FROM %%ALLIANCE%% WHERE id = :id', array(':id' => $allyId), 'ally_tag');
			return $allyId + 100;
		}

		return 0;
	}

	/* ASTROIO: JSON {ok, messages:[{id,uid,name,staff,own,time,text}], latest, allyTag}.
	   GET game.php?page=chat&action=messages&channel=gen|ally&after=<id> */
	private function messagesJSON()
	{
		global $USER;

		$channel	= HTTP::_GP('channel', 'gen');
		$after		= (int) HTTP::_GP('after', 0);
		$allyTag	= '';
		$channelId	= $this->channelID($channel, $allyTag);

		$out = array('ok' => true, 'messages' => array(), 'latest' => $after, 'allyTag' => $allyTag);

		if($channelId >= 0) {
			$rows = Database::get()->select('SELECT id, userID, userName, userRole, dateTime, text
					FROM %%CHAT_MES%% WHERE channel = :channel AND id > :after
					ORDER BY id DESC LIMIT 50', array(':channel' => $channelId, ':after' => $after));

			foreach(array_reverse($rows) as $row) {
				$out['messages'][] = array(
					'id'	=> (int) $row['id'],
					'uid'	=> (int) $row['userID'],
					'name'	=> (string) $row['userName'],
					'staff'	=> ((int) $row['userRole'] >= 2),
					'own'	=> ((int) $row['userID'] == (int) $USER['id']),
					'time'	=> date('H:i', strtotime($row['dateTime'])),
					'text'	=> (string) $row['text'],
				);
				$out['latest'] = (int) $row['id'];
			}
		}

		echo json_encode($out);
		exit;
	}

	/* ASTROIO: inserta un mensaje (POST text, channel=gen|ally) y responde JSON {ok} */
	private function sendMessage()
	{
		global $USER;

		$channel	= HTTP::_GP('channel', 'gen');
		$text		= trim(strip_tags(HTTP::_GP('text', '')));
		$out		= array('ok' => false);

		if($text !== '' && mb_strlen($text) <= 300) {
			$allyTag	= '';
			$channelId	= $this->channelID($channel, $allyTag);

			if($channelId >= 0) {
				$auth	= (int) $USER['authlevel'];
				$role	= ($auth >= 3) ? 3 : (($auth >= 1) ? 2 : 1); /* roles AJAXChat: 3 admin, 2 mod, 1 usuario */

				try {
					Database::get()->insert('INSERT INTO %%CHAT_MES%% (userID, userName, userRole, channel, dateTime, ip, text)
							VALUES (:uid, :uname, :role, :channel, NOW(), :ip, :text)', array(
						':uid'		=> (int) $USER['id'],
						':uname'	=> (string) $USER['username'],
						':role'		=> $role,
						':channel'	=> $channelId,
						':ip'		=> @inet_pton($_SERVER['REMOTE_ADDR']),
						':text'		=> $text,
					));
					$out['ok'] = true;
				} catch (Exception $e) {
					$out['ok'] = false;
				}
			}
		}

		echo json_encode($out);
		exit;
	}
}
