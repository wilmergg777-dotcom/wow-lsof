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
 *
 * ✅ AstroIO v5.5 (REFERIDOS UNIFICADOS — SOLO CÓDIGO):
 *    - Al verificar la cuenta, se guarda `ref_id` (referidor) desde
 *      `%%USERS_VALID%%.referralID` (llenado en el registro por código).
 *    - ELIMINADO `ref_bonus = 1` (bandera del sistema viejo).
 *    - El pago del 3% NXT-20 al referidor lo maneja el sistema Wallet
 *      (WalletHelper) al confirmar la inversión del referido.
 * ✅ AstroIO v5.8 (FIX sesión no se guarda cuando hay referido):
 *    - El UPDATE de ref_id ahora usa casts a int.
 *    - try/catch + error_log para diagnosticar fallos.
 *    - Verificación post-update: si el ref_id no quedó guardado, se loguea.
 *    - Si algo falla, NO se interrumpe el flujo (el registro sigue).
 */

class ShowVertifyPage extends AbstractLoginPage
{
	public static $requireModule = 0;

	function __construct()
	{
		parent::__construct();
	}

	private function _activeUser()
	{
		global $LNG;

		$validationID	= HTTP::_GP('i', 0);
		$validationKey	= HTTP::_GP('k', '');

		$db = Database::get();

		$sql = "SELECT * FROM %%USERS_VALID%%
		WHERE validationID	= :validationID
		AND validationKey	= :validationKey
		AND universe		= :universe;";

		$userData = $db->selectSingle($sql, array(
			':validationKey'	=> $validationKey,
			':validationID'		=> $validationID,
			':universe'			=> Universe::current()
		));

		if(empty($userData))
		{
			$this->printMessage($LNG['vertifyNoUserFound']);
		}

		$config	= Config::get();

		$sql = "DELETE FROM %%USERS_VALID%% WHERE validationID = :validationID;";
		$db->delete($sql, array(
			':validationID'	=> $validationID
		));

		list($userID, $planetID) = PlayerUtil::createPlayer($userData['universe'], $userData['userName'], $userData['password'], $userData['email'], $userData['language']);

		if($config->mail_active == 1)
		{
			require('includes/classes/Mail.class.php');
			$MailSubject	= sprintf($LNG['registerMailCompleteTitle'], $config->game_name, Universe::current());
			$MailRAW		= $LNG->getTemplate('email_reg_done');
			$MailContent	= str_replace(array(
				'{USERNAME}',
				'{GAMENAME}',
				'{GAMEMAIL}',
			), array(
				$userData['userName'],
				$config->game_name.' - '.$config->uni_name,
				$config->smtp_sendmail,
			), $MailRAW);

			try {
				Mail::send($userData['email'], $userData['userName'], $MailSubject, $MailContent);
			}
			catch (Exception $e)
			{
				// This mail is wayne.
			}
		}

		// ═══════════════════════════════════════════════════════════
		// ✅ v5.8 — REFERIDOS: SOLO GUARDAMOS `ref_id` (BLINDADO)
		// ------------------------------------------------------------
		// El `referralID` fue llenado en `%%USERS_VALID%%` durante el
		// registro, cuando el usuario ingresó un código de referido VÁLIDO.
		//
		// Este bloque ahora:
		//   1. Castea ambos valores a int (evita fallos con MySQL strict)
		//   2. Está envuelto en try/catch (no rompe el flujo si falla)
		//   3. Loguea errores a un archivo para diagnóstico
		//   4. Verifica que el UPDATE realmente persistió
		// ═══════════════════════════════════════════════════════════
		if(!empty($userData['referralID']))
		{
			$referralId = (int) $userData['referralID'];
			$uid        = (int) $userID;

			if ($referralId > 0 && $uid > 0)
			{
				try {
					$sql = "UPDATE %%USERS%% SET
						`ref_id`	= :referralId
					WHERE
						`id`		= :userID;";

					$db->update($sql, array(
						':referralId'	=> $referralId,
						':userID'		=> $uid
					));

					// Verificación: leer de vuelta y comprobar
					$check = $db->selectSingle(
						"SELECT ref_id FROM %%USERS%% WHERE id = :uid LIMIT 1;",
						array(':uid' => $uid)
					);

					if (empty($check) || (int) $check['ref_id'] !== $referralId) {
						@file_put_contents(
							ROOT_PATH.'cache/ref_debug.log',
							date('[Y-m-d H:i:s] ') . 
							"UPDATE falló. user=$uid expected=$referralId got=" . 
							(isset($check['ref_id']) ? $check['ref_id'] : 'NULL') . "\n",
							FILE_APPEND
						);
					}
				} catch (Exception $e) {
					// Loguear el error pero NO romper el flujo del registro
					@file_put_contents(
						ROOT_PATH.'cache/ref_debug.log',
						date('[Y-m-d H:i:s] ') . 
						"EXCEPTION: " . $e->getMessage() . " | user=$uid ref=$referralId\n",
						FILE_APPEND
					);
				}
			}
		}

		if(!empty($userData['externalAuthUID']))
		{
			$sql ="INSERT INTO uni1_users_to_extauth SET
			`id`		= :userID,
			`account`	= :externalAuthUID,
			`mode`		= :externalAuthMethod;";
			$db->insert($sql, array(
				':userID'				=> $userID,
				':externalAuthUID'		=> $userData['externalAuthUID'],
				':externalAuthMethod'	=> $userData['externalAuthMethod']
			));
		}

		$senderName = $LNG['registerWelcomePMSenderName'];
		$subject 	= $LNG['registerWelcomePMSubject'];
		$message 	= sprintf($LNG['registerWelcomePMText'], $config->game_name, $userData['universe']);

		PlayerUtil::sendMessage($userID, 1, $senderName, 1, $subject, $message, TIMESTAMP);
		
		return array(
			'userID'	=> $userID,
			'userName'	=> $userData['userName'],
			'planetID'	=> $planetID
		);
	}

	function show()
	{
		$userData	= $this->_activeUser();

		$session	= Session::create();
		$session->userId		= (int) $userData['userID'];
		$session->adminAccess	= 0;
		$session->save();

		HTTP::redirectTo('game.php');
	}

	function json()
	{
		global $LNG;
		$userData	= $this->_activeUser();
		$this->sendJSON(sprintf($LNG['vertifyAdminMessage'], $userData['userName']));
	}
}