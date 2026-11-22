<?php

class ShowExternalAuthPage extends AbstractLoginPage
{
	public static $requireModule = 0;

	function __construct() 
	{
		parent::__construct();
	}
	
	function show() 
	{
		$method = HTTP::_GP('method', '');
		$method = strtolower(str_replace(array('_', '\\', '/', '.', "\0"), '', $method));
		$path   = 'includes/classes/extauth/'.$method.'.class.php';
		
		if(!file_exists($path)) {
			HTTP::redirectTo('index.php');			
		}

		require 'includes/classes/extauth/externalAuth.interface.php';
		require $path;
		
		$methodClass = ucwords($method).'Auth';
		$authObj     = new $methodClass;
		
		if(!$authObj->isActiveMode()) {
			HTTP::redirectTo('index.php?code=5');
		}
		
		if(!$authObj->isValid()) {
			HTTP::redirectTo('index.php?code=4');
		}
		
		$loginData = $authObj->getLoginData();
		
		if(empty($loginData)) {
			HTTP::redirectTo('index.php?page=register&externalAuth[account]='.$authObj->getAccount().'&externalAuth[method]='.$method);
		}

		$userId = (int) $loginData['id'];
		$userIp = Session::getClientIp();

		// Token único - NO usa el session_id() de PHP
		$token = md5(uniqid('astroio_', true) . $userId . microtime());

		$db = Database::get();
		$db->query("REPLACE INTO uni1_session SET
			sessionID   = '" . addslashes($token) . "',
			userID      = " . (int) $userId . ",
			lastonline  = " . (int) TIMESTAMP . ",
			userIP      = '" . addslashes($userIp) . "'");

		$db->query("UPDATE uni1_users SET
			onlinetime  = " . (int) TIMESTAMP . ",
			user_lastip = '" . addslashes($userIp) . "'
			WHERE id = " . (int) $userId);

		$cookiePath = defined('HTTP_ROOT') ? HTTP_ROOT : '/';

		// Cookie propia - NUNCA se borra
		@setcookie('astroio_login', $token, time() + SESSION_LIFETIME, $cookiePath, '', false, true);

		// BORRAR la cookie 2Moons para que PHP genere uno nuevo random
		@setcookie('2Moons', '', time() - 3600, $cookiePath, '', false, true);

		HTTP::redirectTo("game.php");
		exit;
	}
}