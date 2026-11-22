<?php

/**
 * AstroIO - Cron externo 24/7 (Versión con DOBLE CANDADO ANTI-SPAM + CLI + AUTO-CURACIÓN)
 * -------------------------------------------------------------------
 * v4.3 — Soporte COMPLETO para ejecución HTTP y CLI:
 *          - HTTP  → cron-job.org / navegador (lee $_GET['key'])
 *          - CLI   → crontab SSH (lee $argv[1])
 *
 * SISTEMA DE DOBLE CANDADO:
 *   1. flock() atómico  → solo un proceso puede ejecutar a la vez
 *   2. timestamp 55s    → mínimo 55s entre ejecuciones reales
 *
 * NOTA SOBRE CLI:
 *   Cuando se ejecuta desde el crontab SSH, PHP no tiene las variables
 *   $_SERVER normales de HTTP (REQUEST_URI, HTTP_HOST, etc.). Se definen
 *   manualmente al inicio para que common.php y el exceptionHandler no
 *   fallen con "Undefined array key".
 *
 * ✅ FIX AstroIO v4.3:
 *   - Se añade un bloque de AUTO-CURACIÓN antes de ejecutar las flotas.
 *   - Detecta si una flota de ataque/espionaje se quedó en estado 2 (Estacionada)
 *     por un bug del juego, y la pasa a estado 1 (Regresando) automáticamente.
 *   - Evita que las naves se queden huérfanas para siempre.
 * 
 * ✅ FIX AstroIO v4.4 (NUEVO):
 *   - Se añade la ejecución del Cron de Recompensas por Referidos.
 *
 * ✅ FIX AstroIO v4.5 (CLIMA):
 *   - Se añade la ejecución del Sistema de Clima (Rotación 03:00 UTC, Predicción 21:00 UTC).
 */

// ═══════════════════════════════════════════════════════════════
// DETECCIÓN CLI vs HTTP (debe ser lo PRIMERO)
// ═══════════════════════════════════════════════════════════════
$isCli = (php_sapi_name() === 'cli' || php_sapi_name() === 'php-cli');

define('MODE', 'CRON');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)).'/');

// ═══════════════════════════════════════════════════════════════
// ✅ FIX AstroIO v2.7: fallback DB_VERSION_REQUIRED para CLI
// ═══════════════════════════════════════════════════════════════
if (!defined('DB_VERSION_REQUIRED')) {
    define('DB_VERSION_REQUIRED', 4);
}

// ═══════════════════════════════════════════════════════════════
// FIX CLI: Preparar entorno antes de cargar common.php
// ═══════════════════════════════════════════════════════════════
if ($isCli) {

    // 1) Cambiar al directorio del juego (para require relativos)
    @chdir(ROOT_PATH);

    // 2) Definir variables $_SERVER que faltan en CLI
    if (!isset($_SERVER['REQUEST_URI']))     $_SERVER['REQUEST_URI']     = '/cron.php';
    if (!isset($_SERVER['SCRIPT_NAME']))     $_SERVER['SCRIPT_NAME']     = '/cron.php';
    if (!isset($_SERVER['SCRIPT_FILENAME'])) $_SERVER['SCRIPT_FILENAME'] = __FILE__;
    if (!isset($_SERVER['PHP_SELF']))        $_SERVER['PHP_SELF']        = '/cron.php';
    if (!isset($_SERVER['HTTP_HOST']))       $_SERVER['HTTP_HOST']       = 'localhost';
    if (!isset($_SERVER['SERVER_NAME']))     $_SERVER['SERVER_NAME']     = 'localhost';
    if (!isset($_SERVER['SERVER_PORT']))     $_SERVER['SERVER_PORT']     = 80;
    if (!isset($_SERVER['REMOTE_ADDR']))     $_SERVER['REMOTE_ADDR']     = '127.0.0.1';
    if (!isset($_SERVER['REQUEST_METHOD']))  $_SERVER['REQUEST_METHOD']  = 'GET';
    if (!isset($_SERVER['QUERY_STRING']))    $_SERVER['QUERY_STRING']    = '';
    if (!isset($_SERVER['HTTP_USER_AGENT'])) $_SERVER['HTTP_USER_AGENT'] = 'AstroIO-CLI';
    if (!isset($_SERVER['HTTPS']))           $_SERVER['HTTPS']           = '';

    // 3) Convertir los argumentos CLI a $_GET
    if (!empty($argv[1])) {
        parse_str($argv[1], $cliParams);
        if (is_array($cliParams)) {
            foreach ($cliParams as $k => $v) {
                $_GET[$k] = $v;
            }
        }
    }
}

set_include_path(ROOT_PATH);

// ═══════════════════════════════════════════════════════════════
// CONFIGURACIÓN DE LOGS DE ERRORES PHP
// ═══════════════════════════════════════════════════════════════
ini_set('log_errors', 1);
ini_set('error_log', ROOT_PATH . 'cache/astroio_error.log');
ini_set('display_errors', 0);
error_reporting(E_ALL);

// ═══════════════════════════════════════════════════════════════
// CLAVES PARA EVITAR TIMEOUTS DE CRON-JOB.ORG
// ═══════════════════════════════════════════════════════════════
ignore_user_abort(true);
set_time_limit(0);
ini_set('max_execution_time', 0);

require 'includes/common.php';

// ═══════════════════════════════════════════════════════════════
// VALIDACIÓN DE CLAVES
// ═══════════════════════════════════════════════════════════════
$SECRET_KEY   = 'AstroIO_2026_k9Xm_7pQw_Z3nB_vL5t';
$INTERNAL_KEY = 'internal';

$givenKey = isset($_GET['key']) ? $_GET['key'] : '';

if ($givenKey !== $SECRET_KEY && $givenKey !== $INTERNAL_KEY) {
    HTTP::sendHeader('Content-Type', 'text/plain; charset=utf-8');
    echo 'Forbidden';
    exit;
}

// ═══════════════════════════════════════════════════════════════
// DOBLE CANDADO ANTI-SPAM (flock + timestamp)
// ═══════════════════════════════════════════════════════════════
$cronLockFile = ROOT_PATH . 'cache/.cron_run_lock';   // Candado atómico
$cronTimeFile = ROOT_PATH . 'cache/.cron_last_run';   // Timestamp última ejecución
$cronInterval = 55;                                    // Segundos mínimos entre ejecuciones

// Asegurar que la carpeta cache existe
if (!is_dir(ROOT_PATH . 'cache')) {
    @mkdir(ROOT_PATH . 'cache', 0755, true);
}

// ═══ CANDADO 1: flock() atómico ═══
$lockHandle = @fopen($cronLockFile, 'c');
if (!$lockHandle) {
    HTTP::sendHeader('Content-Type', 'text/plain; charset=utf-8');
    echo 'OK (skipped: no se pudo abrir el lock)';
    exit;
}

if (!@flock($lockHandle, LOCK_EX | LOCK_NB)) {
    @fclose($lockHandle);
    HTTP::sendHeader('Content-Type', 'text/plain; charset=utf-8');
    echo 'OK (skipped: otro proceso está ejecutando el cron)';
    exit;
}

// ═══ CANDADO 2: timestamp temporal ═══
if (file_exists($cronTimeFile)) {
    $lastRun = (int) @file_get_contents($cronTimeFile);
    if (TIMESTAMP - $lastRun < $cronInterval) {
        @flock($lockHandle, LOCK_UN);
        @fclose($lockHandle);
        HTTP::sendHeader('Content-Type', 'text/plain; charset=utf-8');
        echo 'OK (skipped: ejecutado hace ' . (TIMESTAMP - $lastRun) . 's)';
        exit;
    }
}

// ═══ MARCAR COMO "EN EJECUCIÓN" ANTES DE HACER NADA ═══
@file_put_contents($cronTimeFile, TIMESTAMP);

// ═══════════════════════════════════════════════════════════════
// PREPARAR EJECUCIÓN (SIN VALIDAR SESIÓN)
// ═══════════════════════════════════════════════════════════════
require 'includes/classes/Cronjob.class.php';

HTTP::sendHeader('Cache-Control', 'no-cache');
HTTP::sendHeader('Content-Type', 'text/plain; charset=utf-8');
HTTP::sendHeader('Connection', 'close');

echo 'OK - ' . date('Y-m-d H:i:s') . PHP_EOL;

if (!$isCli) {
    if (function_exists('fastcgi_finish_request')) {
        fastcgi_finish_request();
    } else {
        while (ob_get_level() > 0) {
            ob_end_flush();
        }
        flush();
    }
}

// ═══════════════════════════════════════════════════════════════
// ✅ FIX DEFINITIVO ASTROIO: FORZAR PROCESAMIENTO DE FLOTAS + AUTO-CURACIÓN
// ═══════════════════════════════════════════════════════════════
$db = Database::get();
$token = uniqid('cron_');

try {
    if (file_exists('includes/classes/class.FlyingFleetHandler.php')) {
        require_once 'includes/classes/class.FlyingFleetHandler.php';
        
        // ═══ AUTO-CURACIÓN DE FLOTAS CORRUPTAS (Evita que se queden huérfanas) ═══
        // Si una flota debía llegar, está en estado 2 (Estacionada) pero es un ataque (1) o espionaje (6),
        // el juego no sabe devolverla. La pasamos a estado 1 (Regresando) automáticamente.
        $db->update("UPDATE %%FLEETS%% SET fleet_mess = 1 WHERE fleet_mess = 2 AND fleet_mission IN (1, 2, 6, 10) AND fleet_end_time <= :time", array(
            ':time' => TIMESTAMP
        ));

        // 1. Bloquear las flotas en la tabla de EVENTOS
        $db->update("UPDATE %%FLEETS_EVENT%% e INNER JOIN %%FLEETS%% f ON e.fleetID = f.fleet_id SET e.`lock` = :token WHERE f.fleet_end_time <= :time", array(
            ':token' => $token,
            ':time'  => TIMESTAMP
        ));
        
        // 2. Ejecutar el motor de flotas
        $fleetHandler = new FlyingFleetHandler();
        $fleetHandler->setToken($token);
        $fleetHandler->run();
        
        // 3. Limpiar los candados sobrantes
        $db->update("UPDATE %%FLEETS_EVENT%% SET `lock` = NULL WHERE `lock` = :token", array(
            ':token' => $token
        ));
    }
} catch (Throwable $e) {
    @file_put_contents(
        ROOT_PATH . 'cache/astroio_error.log',
        '['.date('Y-m-d H:i:s').'] ERROR FLOTAS FORZADAS: '.$e->getMessage()
        . ' en ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL,
        FILE_APPEND
    );
}

// ═══════════════════════════════════════════════════════════════
// EJECUCIÓN REAL (el cliente ya no espera en HTTP; en CLI es secuencial)
// ═══════════════════════════════════════════════════════════════
$logFile  = ROOT_PATH . 'cron_exec.log';
$executed = array();
$failed   = array();

try {
    $todo = Cronjob::getNeedTodoExecutedJobs();
} catch (Throwable $e) {
    @file_put_contents(
        $logFile,
        '['.date('Y-m-d H:i:s').'] ERROR obteniendo cronjobs: '.$e->getMessage().PHP_EOL,
        FILE_APPEND
    );

    @file_put_contents(
        ROOT_PATH . 'cache/astroio_error.log',
        '['.date('Y-m-d H:i:s').'] CRON ERROR obteniendo jobs: '.$e->getMessage()
        . ' en ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL,
        FILE_APPEND
    );

    if (isset($lockHandle) && is_resource($lockHandle)) {
        @flock($lockHandle, LOCK_UN);
        @fclose($lockHandle);
    }
    exit;
}

if (!empty($todo)) {
    foreach ($todo as $cronjobID) {
        try {
            Cronjob::execute($cronjobID);
            $executed[] = $cronjobID;
        } catch (Throwable $e) {
            $failed[] = $cronjobID . ' (' . $e->getMessage() . ')';

            @file_put_contents(
                ROOT_PATH . 'cache/astroio_error.log',
                '['.date('Y-m-d H:i:s').'] CRONJOB '.$cronjobID.' ERROR: '.$e->getMessage()
                . ' en ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL,
                FILE_APPEND
            );
        }
    }
}

@file_put_contents(
    $logFile,
    '['.date('Y-m-d H:i:s').'] Ejecutados: '.(count($executed) ? implode(', ', $executed) : 'ninguno')
    . (!empty($failed) ? ' | Fallidos: '.implode(' | ', $failed) : '')
    . PHP_EOL,
    FILE_APPEND
);

// ═══════════════════════════════════════════════════════════════
// 🆕 LIMPIEZA DE DEPÓSITOS QVAPAY PENDIENTES
// ═══════════════════════════════════════════════════════════════
try {
    // Borra las facturas pendientes de QvaPay que tengan más de 2 horas
    $db->query("DELETE FROM uni1_qvapay_deposits 
                WHERE status = 'pending' 
                AND created_at < DATE_SUB(NOW(), INTERVAL 2 HOUR)");
} catch (Throwable $e) {
    @file_put_contents(
        ROOT_PATH . 'cache/astroio_error.log',
        '['.date('Y-m-d H:i:s').'] ERROR LIMPIEZA QVAPAY: '.$e->getMessage() . PHP_EOL,
        FILE_APPEND
    );
}

// ═══════════════════════════════════════════════════════════════
// 🆕 ASTROIO - CRON DE RECOMPENSAS POR REFERIDOS
// ═══════════════════════════════════════════════════════════════
try {
    if (file_exists('includes/classes/cronjob/ReferralRewardsCronjob.class.php')) {
        require_once 'includes/classes/cronjob/ReferralRewardsCronjob.class.php';
        ReferralRewardsCronjob::run();
    }
} catch (Throwable $e) {
    @file_put_contents(
        ROOT_PATH . 'cache/astroio_error.log',
        '['.date('Y-m-d H:i:s').'] ERROR RECOMPENSAS REFERIDOS: '.$e->getMessage() . PHP_EOL,
        FILE_APPEND
    );
}

// ═══════════════════════════════════════════════════════════════
// 🌦️ NUEVO: SISTEMA DE CLIMA (ROTACIÓN Y PREDICCIÓN)
// ═══════════════════════════════════════════════════════════════
try {
    if (file_exists('includes/classes/ClimaEngine.class.php') && file_exists('includes/classes/ClimaCron.class.php')) {
        require_once 'includes/classes/ClimaEngine.class.php';
        require_once 'includes/classes/ClimaCron.class.php';
        
        $horaActual = date('H');
        
        // Rotación diaria (03:00 UTC)
        if ($horaActual == '03') {
            // Candado para evitar doble rotación en la misma hora
            $lockRotacion = ROOT_PATH . 'cache/.clima_rotated_' . date('Y-m-d');
            if (!file_exists($lockRotacion)) {
                ClimaCron::rotarTodos();
                @file_put_contents($lockRotacion, time());
            }
        }
        
        // Predicción diaria (21:00 UTC)
        if ($horaActual == '21') {
            // Candado para evitar doble predicción en la misma hora
            $lockPrediccion = ROOT_PATH . 'cache/.clima_predicted_' . date('Y-m-d');
            if (!file_exists($lockPrediccion)) {
                ClimaCron::predecirTodos();
                @file_put_contents($lockPrediccion, time());
            }
        }
    }
} catch (Throwable $e) {
    @file_put_contents(
        ROOT_PATH . 'cache/astroio_error.log',
        '['.date('Y-m-d H:i:s').'] ERROR SISTEMA CLIMA: '.$e->getMessage() . PHP_EOL,
        FILE_APPEND
    );
}

// ═══════════════════════════════════════════════════════════════
// LIBERAR EL CANDADO AL TERMINAR (crítico)
// ═══════════════════════════════════════════════════════════════
if (isset($lockHandle) && is_resource($lockHandle)) {
    @flock($lockHandle, LOCK_UN);
    @fclose($lockHandle);
}