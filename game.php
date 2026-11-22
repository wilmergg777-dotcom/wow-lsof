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

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/',dirname(__FILE__)).'/');
set_include_path(ROOT_PATH);

require 'includes/pages/game/AbstractGamePage.class.php';
require 'includes/pages/game/ShowErrorPage.class.php';
require 'includes/common.php';
/** @var $LNG Language */

$page 		= HTTP::_GP('page', 'overview');
$mode 		= HTTP::_GP('mode', 'show');

// ═══════════════════════════════════════════════════════════════════════
// 🆕 ASTROIO: MAPEO DE PÁGINAS CON NOMBRE PERSONALIZADO
// Las páginas que NO siguen el patrón convencional Show{Page}Page.class.php
// se mapean aquí explícitamente. El resto sigue el flujo dinámico normal.
// ═══════════════════════════════════════════════════════════════════════
$customPages = array(
	'unified_base' => array(
		'class' => 'UnifiedBase',
		'file'  => 'includes/pages/game/UnifiedBase.class.php',
	),
);

if (isset($customPages[$page])) {
	$pageClass = $customPages[$page]['class'];
	$path      = $customPages[$page]['file'];
} else {
	$page		= str_replace(array('_', '\\', '/', '.', "\0"), '', $page);
	$pageClass	= 'Show'.ucwords($page).'Page';
	$path		= 'includes/pages/game/'.$pageClass.'.class.php';
}

if(!file_exists($path)) {
	ShowErrorPage::printError($LNG['page_doesnt_exist']);
}

// Added Autoload in feature Versions
require $path;

// ═══════════════════════════════════════════════════════════════════════
// 🆕 ASTROIO: PORTERO GLOBAL Y ESTRICTO DE MÓDULOS DESACTIVADOS
// - Se ejecuta ANTES de instanciar la página.
// - Si el módulo está apagado, detiene la ejecución y muestra el popup.
// - Bloquea a TODOS por igual (sin excepción para admins).
// - Si el archivo no tiene $requireModule, deduce el módulo por la URL.
// ═══════════════════════════════════════════════════════════════════════
$pageProps = get_class_vars($pageClass);
$reqModule = 0;

// 1. Intentar leer la etiqueta estática del archivo
if (isset($pageProps['requireModule']) && $pageProps['requireModule'] !== 0) {
    $reqModule = $pageProps['requireModule'];
} else {
    // 2. Si el archivo no tiene etiqueta, DEDUCIR el módulo por la URL
    // Ejemplo: ?page=battlepass -> MODULE_BATTLEPASS
    $constName = 'MODULE_' . strtoupper($page);
    if (defined($constName)) {
        $reqModule = constant($constName);
    }
}

// 3. Si se identificó un módulo y está desactivado en el panel admin -> BLOQUEAR
if ($reqModule > 0 && !isModuleAvailable($reqModule)) {
    
    // Definimos una clase rápida para mostrar el error con el mismo diseño
    if (!class_exists('AstroIOModuleDisabledPage')) {
        class AstroIOModuleDisabledPage extends AbstractGamePage {
            public function __construct() {
                parent::__construct();
            }
            public function showError() {
                $this->printMessage(
                    "El MOP está desactivado temporalmente.<br>Consulte con la administración para cualquier duda.",
                    array(array(
                        'label' => 'Volver',
                        'url'   => 'game.php?page=overview'
                    )),
                    NULL,
                    false
                );
            }
        }
    }
    
    // Mostrar el error y detener la ejecución
    $errorPage = new AstroIOModuleDisabledPage();
    $errorPage->showError();
    exit;
}
// ═══════════════════════════════════════════════════════════════════════

$pageObj	= new $pageClass;

if(!is_callable(array($pageObj, $mode))) {	
	if(!isset($pageProps['defaultController']) || !is_callable(array($pageObj, $pageProps['defaultController']))) {
		ShowErrorPage::printError($LNG['page_doesnt_exist']);
	}
	$mode	= $pageProps['defaultController'];
}

$pageObj->{$mode}();

// ============================================
// AstroIO — Disparador automático de cronjobs
// ============================================
// Ejecuta los cronjobs pendientes cada 5 minutos.
// El cronjob 'statistic' respeta su propio horario
// (cada 1 hora en punto). NO se ejecuta más seguido
// porque internamente valida nextTime < ahora.
//
// Se ejecuta DESPUÉS del render para no demorar la
// carga de la página al usuario.
// ============================================

try {
	$cronCacheDir  = ROOT_PATH.'cache/';
	$cronCacheFile = $cronCacheDir.'astroio_cron_last_check.txt';
	$cronInterval  = 300; // 5 minutos

	// Verificar si el directorio cache existe y es escribible
	if (is_dir($cronCacheDir) && is_writable($cronCacheDir)) {

		$lastCheck = 0;
		if (file_exists($cronCacheFile)) {
			$lastCheck = (int) @file_get_contents($cronCacheFile);
		}

		if (TIMESTAMP - $lastCheck >= $cronInterval) {
			// Marcar el chequeo ANTES de ejecutar (evita concurrencia)
			@file_put_contents($cronCacheFile, TIMESTAMP, LOCK_EX);

			require_once 'includes/classes/Cronjob.class.php';

			$cronjobsTodo = Cronjob::getNeedTodoExecutedJobs();

			foreach ($cronjobsTodo as $cronjobID) {
				try {
					Cronjob::execute($cronjobID);
				} catch (Exception $e) {
					// Ignorar errores individuales para no romper el juego
				}
			}
		}
	}
} catch (Exception $e) {
	// Ignorar cualquier error del cronjob para no afectar al usuario
}