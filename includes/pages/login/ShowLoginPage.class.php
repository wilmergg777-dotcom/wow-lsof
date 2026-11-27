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
 * ✅ FIX AstroIO v2.5:
 *   - El bloqueo por servidor cerrado AHORA respeta a los administradores.
 *   - Primero valida credenciales, luego comprueba authlevel.
 *   - Si el servidor está cerrado:
 *       * AUTH_USR (jugador normal, authlevel = 0) → bloquea con mensaje del admin
 *       * authlevel > 0 (admin/mod/operador) → permite el login
 *         para que puedan entrar al panel admin y desactivar el cierre.
 */

class ShowLoginPage extends AbstractLoginPage
{
	public static $requireModule = 0;

	function __construct() 
	{
		parent::__construct();
	}
	
	function show() 
	{
		if (empty($_POST)) {
			HTTP::redirectTo('index.php');	
		}

		global $LNG;

		$db = Database::get();

		$username = HTTP::_GP('username', '', UTF8_SUPPORT);
		$password = HTTP::_GP('password', '', true);

		// ✅ FIX v2.5: Buscamos también el authlevel para saber si es admin
		$sql = "SELECT id, password, authlevel FROM %%USERS%% WHERE universe = :universe AND username = :username;";
		$loginData = $db->selectSingle($sql, array(
			':universe'	=> Universe::current(),
			':username'	=> $username
		));

		if (empty($loginData))
		{
			HTTP::redirectTo('index.php?code=1');
		}

		// ✅ Validar contraseña
		$hashedPassword = PlayerUtil::cryptPassword($password);
		if($loginData['password'] != $hashedPassword)
		{
			// Fallback pre 1.7
			if($loginData['password'] == md5($password)) {
				$sql = "UPDATE %%USERS%% SET password = :hashedPassword WHERE id = :loginID;";
				$db->update($sql, array(
					':hashedPassword'	=> $hashedPassword,
					':loginID'			=> $loginData['id']
				));
			} else {
				HTTP::redirectTo('index.php?code=1');	
			}
		}

		// ✅ FIX v2.5: Si el servidor está cerrado y el usuario NO es admin → bloquear.
		// Los admins (authlevel > 0) pueden entrar para desactivar el cierre.
		$config = Config::get();
		if($config->game_disable == 1 && $loginData['authlevel'] == AUTH_USR) {
			$message = $LNG['sys_closed_game'];
			if(!empty($config->close_reason)) {
				$message .= '<br><br>' . $config->close_reason;
			}
			$this->printMessage($message, array(array(
				'label' => $LNG['registerBack'],
				'url'   => 'index.php',
			)));
			return;
		}

		// ✅ Crear sesión y redirigir
		$session	= Session::create();
		$session->userId		= (int) $loginData['id'];
		$session->adminAccess	= 0;
		$session->save();

		HTTP::redirectTo('game.php');	
	}
}