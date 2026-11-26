<?php
// api_estado.php — v1.0
// Endpoint de ESTADO para la APP MÓVIL (AstroIO APK v2.4.4+).
// El servicio en segundo plano de la APK consulta aquí (con la misma
// sesión del juego, PHPSESSID) cada ~60 s para decidir si debe mostrar
// notificaciones y hacer sonar la alarma, aun con la APK minimizada.
//
// Devuelve en JSON:
//   mensajes  → número de mensajes SIN LEER del jugador (badge/chat flotante)
//   hasAttack → TRUE solo si hay un ATAQUE PvP REAL en ida hacia el jugador
//               (misión 1/2/9, de otro jugador, aún volando) → LA APK HACE
//               SONAR LA SIRENA. Misma semántica que check_attacks.php v3.9:
//               flotas en vuelta, PVE (20/21/22) y espionajes NO disparan la
//               alarma (hasPve/hasSpy van aparte como aviso visual).
//   ts        → hora del servidor (epoch) por si la APK la necesita.
//
// Nota: el conteo de ataques es idéntico al de check_attacks.php para que
// la app y la web no difieran nunca.
error_reporting(E_ALL);
ini_set('display_errors', 0);

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)).'/');
set_include_path(ROOT_PATH);

require 'includes/pages/game/AbstractGamePage.class.php';
require 'includes/pages/game/ShowErrorPage.class.php';
require 'includes/common.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

// Sin sesión válida → respuesta vacía inofensiva (la APK no notifica nada).
if (empty($GLOBALS['USER']['id'])) {
    echo json_encode(['mensajes' => 0, 'hasAttack' => false, 'total' => 0,
                      'hasPve' => false, 'hasSpy' => false, 'reason' => 'no_session']);
    exit;
}

$userId = (int) $GLOBALS['USER']['id'];
$db     = Database::get();
$prefix = DB_PREFIX;
$now    = TIMESTAMP;

try {
    // ═══ ATAQUES PvP REALES (1=Ataque, 2=ACS, 9=Destrucción de luna) ═══
    // fleet_mess = 0 → solo trayecto de IDA · fleet_owner <> yo → jamás flota
    // propia · fleet_end_time > now → aún no ha llegado.
    $r = $db->selectSingle(
        "SELECT COUNT(*) AS n FROM `".$prefix."fleets`
         WHERE `fleet_mission` IN (1, 2, 9)
         AND `fleet_target_owner` = :userId
         AND `fleet_owner` <> :userId
         AND `fleet_mess` = 0
         AND `fleet_end_time` > :now",
        [':userId' => $userId, ':now' => $now]);
    $attackCount = isset($r['n']) ? (int) $r['n'] : 0;

    // ═══ MENSAJES SIN LEER (para la notificación de mensaje nuevo) ═══
    // Mismo criterio que ShowMessagesPage: message_unread = 1 y sin borrar.
    $r = $db->selectSingle(
        "SELECT COUNT(*) AS n FROM `".$prefix."messages`
         WHERE `message_owner` = :userId
         AND `message_unread` = 1
         AND `message_deleted` IS NULL",
        [':userId' => $userId]);
    $unread = isset($r['n']) ? (int) $r['n'] : 0;

    // ═══ PVE y ESPIONAJE (solo aviso visual, NUNCA sirena) ═══
    $r = $db->selectSingle(
        "SELECT COUNT(*) AS n FROM `".$prefix."fleets`
         WHERE `fleet_mission` IN (20, 21, 22)
         AND `fleet_target_owner` = :userId
         AND `fleet_mess` = 0
         AND `fleet_end_time` > :now",
        [':userId' => $userId, ':now' => $now]);
    $pveCount = isset($r['n']) ? (int) $r['n'] : 0;

    $r = $db->selectSingle(
        "SELECT COUNT(*) AS n FROM `".$prefix."fleets`
         WHERE `fleet_mission` = 6
         AND `fleet_target_owner` = :userId
         AND `fleet_owner` <> :userId
         AND `fleet_mess` = 0
         AND `fleet_end_time` > :now",
        [':userId' => $userId, ':now' => $now]);
    $spyCount = isset($r['n']) ? (int) $r['n'] : 0;

    echo json_encode([
        'mensajes'  => $unread,
        'hasAttack' => ($attackCount > 0),
        'total'     => $attackCount,
        'hasPve'    => ($pveCount > 0),
        'hasSpy'    => ($spyCount > 0),
        'ts'        => $now,
    ]);

} catch (Exception $e) {
    echo json_encode(['mensajes' => 0, 'hasAttack' => false, 'total' => 0,
                      'error' => $e->getMessage()]);
}
