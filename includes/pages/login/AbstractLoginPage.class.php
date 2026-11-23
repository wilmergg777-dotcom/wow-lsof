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
 * ✅ AstroIO v2.9 — printMessage() blindado
 *    - Detecta si $redirectButtons es booleano (llamada con orden equivocado)
 *    - Fuerza $redirectButtons a null si no es array
 *
 * ✅ AstroIO v5.5 (REFERIDOS UNIFICADOS — SOLO CÓDIGO):
 *    - ELIMINADO assign 'referralEnable' => $config->ref_active
 *    - El sistema nativo de referidos ya no existe.
 *    - La vinculación ocurre SOLO en el registro por código (ReferralHelper v5.0).
 *
 * ✅ AstroIO v5.6 (FIX PHP 8.2 — Undefined array key "page"):
 *    - Añadido assign 'page' en getPageData() para evitar el warning
 *      "Undefined array key 'page'" que en PHP 8.2 rompe la home.
 */

abstract class AbstractLoginPage
{

	/**
	 * reference of the template object
	 * @var template
	 */
	protected $tplObj = null;
	protected $window;
	public $defaultWindow = 'normal';
	
	protected function __construct() {
		
		if(!AJAX_REQUEST)
		{
			$this->setWindow($this->defaultWindow);
			$this->initTemplate();
		} else {
			$this->setWindow('ajax');
		}
	}

	protected function getUniverseSelector()
	{
		$universeSelect	= array();
		foreach(Universe::availableUniverses() as $uniId)
		{
			$universeSelect[$uniId]	= Config::get($uniId)->uni_name;
		}

		return $universeSelect;
	}

	protected function initTemplate()
	{
		if(isset($this->tplObj))
			return true;
			
		$this->tplObj	= new template;
		list($tplDir)	= $this->tplObj->getTemplateDir();
		$this->tplObj->setTemplateDir($tplDir.'login/');
		return true;
	}
	
	protected function setWindow($window) {
		$this->window	= $window;
	}
		
	protected function getWindow() {
		return $this->window;
	}
	
	protected function getQueryString() {
		$queryString	= array();
		$page			= HTTP::_GP('page', '');
		
		if(!empty($page)) {
			$queryString['page']	= $page;
		}
		
		$mode			= HTTP::_GP('mode', '');
		if(!empty($mode)) {
			$queryString['mode']	= $mode;
		}
		
		return http_build_query($queryString);
	}
	
	protected function getPageData() 
    {		
		global $LNG;

		$config	= Config::get();

		// ✅ FIX v5.6 — PHP 8.2: definir 'page' siempre, con fallback a 'index'
		$page = HTTP::_GP('page', '');
		if ($page === '') {
			$page = 'index';
		}

        $this->tplObj->assign_vars(array(
			// ✅ FIX v5.6 — variable que faltaba y rompía el template en PHP 8.2
			'page'					=> $page,
			'recaptchaEnable'		=> $config->capaktiv,
			'recaptchaPublicKey'	=> $config->cappublic,
			'gameName' 				=> $config->game_name,
			'facebookEnable'		=> $config->fb_on,
			'fb_key' 				=> $config->fb_apikey,
			'discordEnable'			=> $config->discord_on,
			'discord_apikey'		=> $config->discord_apikey,
			'mailEnable'			=> $config->mail_active,
			'reg_close'				=> $config->reg_closed,
			// ✅ v5.5: ELIMINADO 'referralEnable' => $config->ref_active
			'analyticsEnable'		=> $config->ga_active,
			'analyticsUID'			=> $config->ga_key,
			'lang'					=> $LNG->getLanguage(),
			'UNI'					=> Universe::current(),
			'VERSION'				=> $config->VERSION,
			'REV'					=> substr($config->VERSION, -4),
			'languages'				=> Language::getAllowedLangs(false),
		));
	}
	
	protected function printMessage($message, $redirectButtons = null, $redirect = null, $fullSide = true)
	{
		// ✅ FIX v2.9 — Blindaje contra argumentos en orden equivocado
		// Si el segundo argumento es un booleano, significa que se llamó
		// con el orden viejo: printMessage($msg, $fullSide, $redirect)
		if (is_bool($redirectButtons)) {
			$fullSide        = $redirectButtons;
			$redirectButtons = null;
		}

		// Si no es un array válido, forzamos null para que el template no falle
		if (!is_array($redirectButtons)) {
			$redirectButtons = null;
		}

		$this->assign(array(
			'message'			=> $message,
			'redirectButtons'	=> $redirectButtons,
		));
		
		if(isset($redirect)) {
			$this->tplObj->gotoside($redirect[0], $redirect[1]);
		}
		
		if(!$fullSide) {
			$this->setWindow('popup');
		}
		
		$this->display('error.default.tpl');
	}
	
	protected function save() {
		
	}

	protected function assign($array, $nocache = true) {
		$this->tplObj->assign_vars($array, $nocache);
	}
	
	protected function display($file) {
		global $LNG;
		
		$this->save();
		
		if($this->getWindow() !== 'ajax') {
			$this->getPageData();
		}

		if (UNIS_WILDCAST) {
			$hostParts = explode('.', HTTP_HOST);
			if (preg_match('/uni[0-9]+/', $hostParts[0])) {
				array_shift($hostParts);
			}
			$host = implode('.', $hostParts);
			$basePath = PROTOCOL.$host.HTTP_BASE;
		} else {
			$basePath = PROTOCOL.HTTP_HOST.HTTP_BASE;
		}
		
		$this->assign(array(
            'lang'    			=> $LNG->getLanguage(),
			'bodyclass'			=> $this->getWindow(),
			'basepath'			=> $basePath,
			'isMultiUniverse'	=> count(Universe::availableUniverses()) > 1,
			'unisWildcast'		=> UNIS_WILDCAST,
		));

		$this->assign(array(
			'LNG'			=> $LNG,
		), false);
		
		$this->tplObj->display('extends:layout.'.$this->getWindow().'.tpl|'.$file);
		exit;
	}
	
	protected function sendJSON($data) {
		$this->save();
		echo json_encode($data);
		exit;
	}
	
	protected function redirectTo($url) {
		$this->save();
		HTTP::redirectTo($url);
		exit;
	}
	
	protected function redirectPost($url, $postFields) {
		$this->save();
		$this->tplObj->assign_vars(array(
            'url'    		=> $url,
			'postFields'	=> $postFields,
		));
		
		$this->display('info.redirectPost.tpl');
	}
}