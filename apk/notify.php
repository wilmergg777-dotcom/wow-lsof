<?php
// ══════════════════════════════════════════════════════════════════
// AstroIO — Notificaciones para la APK (v1)
// ------------------------------------------------------------------
// Endpoint: https://TU-DOMINIO/AstroIO3.4/apk/notify.php
//
// La APK lo consulta con la MISMA sesión del juego (cookie PHPSESSID):
//   - Mensajes nuevos DEL JUEGO (correo interno, informes, admin…).
//     El CHAT FLOTANTE nunca se devuelve: vive en otra tabla
//     (PREFIX_chat_messages) y aquí solo se lee PREFIX_messages.
//   - Ataques PvP reales entrantes (misión 1/2/9, ida, de otro jugador)
//     con hora exacta de llegada → la APK programa la sirena.
//   - Contadores de eventos PVE (20/21/22) y espionajes (misión 6),
//     que se avisan sin sirena.
// ══════════════════════════════════════════════════════════════════
error_reporting(E_ALL);
ini_set('display_errors', 0);

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__) ) . '/../');
set_include_path(ROOT_PATH);

require 'includes/pages/game/AbstractGamePage.class.php';
require 'includes/pages/game/ShowErrorPage.class.php';
require 'includes/common.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate');

if (empty($GLOBALS['USER']['id'])) {
    echo json_encode(array('auth' => false));
    exit;
}

$userId = (int) $GLOBALS['USER']['id'];
$db     = Database::get();
$prefix = DB_PREFIX;
$now    = TIMESTAMP;

try {
    // ── Mensajes nuevos del juego (sin chat flotante) ─────────────
    $messages = array();
    $sqlMsg = "SELECT message_id, message_from, message_subject, message_time, message_type
               FROM `".$prefix."messages`
               WHERE `message_owner` = :userId
               AND `message_unread` = 1
               AND (`message_deleted` IS NULL OR `message_deleted` = 0)
               ORDER BY `message_id` DESC
               LIMIT 20";
    $rowsMsg = $db->select($sqlMsg, array(':userId' => $userId));
    foreach ((array) $rowsMsg as $m) {
        $messages[] = array(
            'id'      => (int) $m['message_id'],
            'from'    => (string) $m['message_from'],
            'subject' => (string) $m['message_subject'],
            'time'    => (int) $m['message_time'],
            'type'    => (int) $m['message_type'],
        );
    }

    // ── Ataques PvP reales (1=Ataque, 2=ACS, 9=Destrucción) en ida ─
    $attacks = array();
    $sqlAtt = "SELECT fleet_id, fleet_mission, fleet_end_time,
                      fleet_start_galaxy, fleet_start_system, fleet_start_planet
               FROM `".$prefix."fleets`
               WHERE `fleet_mission` IN (1, 2, 9)
               AND `fleet_target_owner` = :userId
               AND `fleet_owner` <> :userId
               AND `fleet_mess` = 0
               AND `hasCanceled` = 0
               AND `fleet_end_time` > :now
               ORDER BY `fleet_end_time` ASC
               LIMIT 30";
    $rowsAtt = $db->select($sqlAtt, array(':userId' => $userId, ':now' => $now));
    foreach ((array) $rowsAtt as $a) {
        $attacks[] = array(
            'id'      => (int) $a['fleet_id'],
            'mission' => (int) $a['fleet_mission'],
            'endTime' => (int) $a['fleet_end_time'],
            'galaxy'  => (int) $a['fleet_start_galaxy'],
            'system'  => (int) $a['fleet_start_system'],
            'planet'  => (int) $a['fleet_start_planet'],
        );
    }

    // ── PVE (20=Crisis, 21=Imperio, 22=Contraataque): solo contador ─
    $pveCount = 0;
    $sqlPve = "SELECT COUNT(*) AS c
               FROM `".$prefix."fleets`
               WHERE `fleet_mission` IN (20, 21, 22)
               AND `fleet_target_owner` = :userId
               AND `fleet_mess` = 0
               AND `fleet_end_time` > :now";
    $r = $db->selectSingle($sqlPve, array(':userId' => $userId, ':now' => $now));
    if (is_array($r)) { $pveCount = (int) $r['c']; }

    // ── Espionajes entrantes (misión 6, ida, de otro jugador) ──────
    $spyCount = 0;
    $sqlSpy = "SELECT COUNT(*) AS c
               FROM `".$prefix."fleets`
               WHERE `fleet_mission` = 6
               AND `fleet_target_owner` = :userId
               AND `fleet_owner` <> :userId
               AND `fleet_mess` = 0
               AND `fleet_end_time` > :now";
    $r = $db->selectSingle($sqlSpy, array(':userId' => $userId, ':now' => $now));
    if (is_array($r)) { $spyCount = (int) $r['c']; }

    echo json_encode(array(
        'auth'        => true,
        'serverTime'  => $now,
        'unreadCount' => count($messages),
        'messages'    => $messages,
        'attacks'     => $attacks,
        'pveCount'    => $pveCount,
        'spyCount'    => $spyCount,
    ), JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    echo json_encode(array('auth' => true, 'serverTime' => $now, 'error' => 'db'));
}
