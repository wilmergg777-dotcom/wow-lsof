<?php
// check_attacks.php
error_reporting(E_ALL);
ini_set('display_errors', 0);

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)).'/');
set_include_path(ROOT_PATH);

require 'includes/pages/game/AbstractGamePage.class.php';
require 'includes/pages/game/ShowErrorPage.class.php';
require 'includes/common.php';

header('Content-Type: application/json; charset=utf-8');

if (empty($GLOBALS['USER']['id'])) {
    echo json_encode(['hasAttack' => false, 'total' => 0, 'reason' => 'no_session']);
    exit;
}

$userId = (int) $GLOBALS['USER']['id'];
$db     = Database::get();
$prefix = DB_PREFIX;
$now    = TIMESTAMP;

try {
    // ═══════ ATAQUES ENTRANTES (mission 1=PvP, 20=Crisis, 21=Imperio, 22=Contraataque, 23=Devorador, 24=Refuerzo, 25=Pirata) ═══════
    // ✅ FIX: añadidas misiones PvE (20, 21, 22) para que la alarma suene con piratas
    // 🆕 v6.0: añadidas 23 (Devorador), 24 (Refuerzo Bastión), 25 (Pirata Bastión)
    //          — las misiones 24 y 25 tienen fleet_target_owner = ghost (> 900M),
    //            así que NO dispararán la alarma al jugador (es correcto), pero
    //            las dejamos en el IN para futura consistencia.
    $sql = "SELECT COUNT(*) AS attack_count
            FROM `".$prefix."fleets`
            WHERE `fleet_mission` IN (1, 20, 21, 22, 23, 24, 25)
            AND `fleet_target_owner` = :userId
            AND `fleet_end_time` > :now";

    $result = $db->selectSingle($sql, [
        ':userId' => $userId,
        ':now'    => $now,
    ]);

    $attackCount = isset($result['attack_count']) ? (int) $result['attack_count'] : 0;

    // ═══════ ESPIONAJES ENTRANTES (mission 6) ═══════
    $sqlSpy = "SELECT COUNT(*) AS spy_count
               FROM `".$prefix."fleets`"
               ." WHERE `fleet_mission` = 6"
               ." AND `fleet_target_owner` = :userId"
               ." AND `fleet_end_time` > :now";

    $resultSpy = $db->selectSingle($sqlSpy, [
        ':userId' => $userId,
        ':now'    => $now,
    ]);

    $spyCount = isset($resultSpy['spy_count']) ? (int) $resultSpy['spy_count'] : 0;

    echo json_encode([
        'hasAttack' => ($attackCount > 0),
        'total'     => $attackCount,
        'hasSpy'    => ($spyCount > 0),
        'spyTotal'  => $spyCount,
    ]);

} catch (Exception $e) {
    echo json_encode([
        'hasAttack' => false,
        'total'     => 0,
        'error'     => $e->getMessage(),
    ]);
}