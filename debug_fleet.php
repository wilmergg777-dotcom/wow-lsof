<?php
define('MODE', 'CRON');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)).'/');
@chdir(ROOT_PATH);
set_include_path(ROOT_PATH);

if (!isset($_SERVER['REQUEST_URI']))     $_SERVER['REQUEST_URI']     = '/cron.php';
if (!isset($_SERVER['SCRIPT_NAME']))     $_SERVER['SCRIPT_NAME']     = '/cron.php';
if (!isset($_SERVER['SCRIPT_FILENAME'])) $_SERVER['SCRIPT_FILENAME'] = __FILE__;
if (!isset($_SERVER['PHP_SELF']))        $_SERVER['PHP_SELF']        = '/cron.php';
if (!isset($_SERVER['HTTP_HOST']))       $_SERVER['HTTP_HOST']       = 'localhost';
if (!isset($_SERVER['SERVER_NAME']))     $_SERVER['SERVER_NAME']     = 'localhost';
if (!isset($_SERVER['SERVER_PORT']))     $_SERVER['SERVER_PORT']     = 80;
if (!isset($_SERVER['REMOTE_ADDR']))     $_SERVER['REMOTE_ADDR']     = '127.0.0.1';
if (!isset($_SERVER['REQUEST_METHOD']))  $_SERVER['REQUEST_METHOD']  = 'GET';

if (!defined('DB_VERSION_REQUIRED')) define('DB_VERSION_REQUIRED', 4);
ini_set('display_errors', 1);
ini_set('error_reporting', E_ALL);

require 'includes/common.php';
require_once 'includes/classes/class.FlyingFleetHandler.php';

echo "1. Base cargada.\n";

$db = Database::get();
$token = uniqid('cron_');

// 1. Bloquear las flotas en la tabla de EVENTOS (que es donde está el lock)
$db->update("UPDATE %%FLEETS_EVENT%% e INNER JOIN %%FLEETS%% f ON e.fleetID = f.fleet_id SET e.`lock` = :token WHERE f.fleet_end_time <= :time", array(
    ':token' => $token,
    ':time'  => TIMESTAMP
));
echo "2. Flotas bloqueadas en EVENTOS con token: $token\n";

// 2. Ejecutar el motor de flotas
$fleetHandler = new FlyingFleetHandler();
$fleetHandler->setToken($token);
$fleetHandler->run();
echo "3. run() ejecutado.\n";

// 3. Quitar el candado a las que no se procesaron o limpiar
$db->update("UPDATE %%FLEETS_EVENT%% SET `lock` = NULL WHERE `lock` = :token", array(
    ':token' => $token
));
echo "4. Candados liberados. ¡Proceso terminado!\n";
