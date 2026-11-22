<?php

/**
 * AstroIO — Router de vinculación Discord para el juego
 * 
 * Extiende AbstractGamePage para tener acceso a $USER (sesión cargada).
 * Se accede vía: game.php?page=ExternalAuth&method=discord&link=1
 *                game.php?page=ExternalAuth&method=discord&unlink=1
 * 
 * NO reemplaza al ShowExternalAuthPage de login (pages/login/).
 */

class ShowExternalAuthPage extends AbstractGamePage
{
	public static $requireModule = 0;

	function __construct() 
	{
		parent::__construct();
	}

	public function show()
	{
		global $USER;

		$method = HTTP::_GP('method', '');
		$method = strtolower(str_replace(array('_', '\\', '/', '.', "\0"), '', $method));

		if (empty($method)) {
			HTTP::redirectTo('game.php?page=settings');
			exit;
		}

		$path = 'includes/classes/extauth/' . $method . '.class.php';

		if (!file_exists($path)) {
			HTTP::redirectTo('game.php?page=settings');
			exit;
		}

		require 'includes/classes/extauth/externalAuth.interface.php';
		require $path;

		$methodClass = ucwords($method) . 'Auth';

		if (!class_exists($methodClass)) {
			HTTP::redirectTo('game.php?page=settings');
			exit;
		}

		$authObj = new $methodClass;

		if (!$authObj->isActiveMode()) {
			HTTP::redirectTo('game.php?page=settings');
			exit;
		}

		if (!$authObj->isValid()) {
			HTTP::redirectTo('game.php?page=settings');
			exit;
		}

		$linkMode   = (int) HTTP::_GP('link', 0);
		$unlinkMode = (int) HTTP::_GP('unlink', 0);

		// ═══════════════════════════════════════════════════════
		// MODO DESVINCULAR
		// ═══════════════════════════════════════════════════════
		if ($unlinkMode === 1)
		{
			$db = Database::get();
			$db->query(
				"DELETE FROM uni1_users_to_extauth 
				 WHERE id = " . (int) $USER['id'] . " 
				 AND mode = '" . addslashes($method) . "'"
			);

			HTTP::redirectTo('game.php?page=settings');
			exit;
		}

		// ═══════════════════════════════════════════════════════
		// MODO VINCULAR
		// ═══════════════════════════════════════════════════════
		if ($linkMode === 1)
		{
			if (method_exists($authObj, 'linkAccount')) {
				$authObj->linkAccount((int) $USER['id']);
				// linkAccount hace redirect y exit
			} else {
				HTTP::redirectTo('game.php?page=settings');
				exit;
			}
		}

		// ═══════════════════════════════════════════════════════
		// SIN MODO → redirigir a settings
		// ═══════════════════════════════════════════════════════
		HTTP::redirectTo('game.php?page=settings');
		exit;
	}
}