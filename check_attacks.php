<?php
// check_attacks.php — v3.9
// ✅ FIX FALSOS DISPAROS DE LA ALARMA:
//   Antes la sirena sonaba con: (1) flotas en VUELTA de regreso (faltaba
//   fleet_mess = 0 → una fila de retorno seguía contando horas después del
//   ataque real), (2) misiones PVE (20 Crisis, 21 Imperio, 22 Contraataque)
//   que NO son un ataque de un jugador, y (3) espionajes (misión 6).
//   Además el "blip" al hacer click venía del JS (base.js), no de aquí.
// Semántica correcta ahora:
//   hasAttack → sirena: SOLO misión PvP real (1 Ataque, 2 ACS, 9 Destrucción)
//               en IDA (fleet_mess=0), de OTRO jugador (fleet_owner <> yo),
//               aún volando (fleet_end_time > now).
//   hasPve    → aviso visual (no sirena): eventos PVE 20/21/22 hacia el jugador.
//   hasSpy    → aviso visual (no sirena): espionaje enemigo en ida.
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
    // ═══════ ATAQUES PvP REALES (1=Ataque, 2=ACS, 9=Destrucción de luna) ═══════
    // Condiciones obligatorias para que la sirena suene:
    //   fleet_mess = 0        → solo trayecto de IDA (1 = vuelta/regreso)
    //   fleet_owner <> userId → jamás flota propia (refuerzos propios, etc.)
    //   fleet_end_time > now  → aún no ha llegado
    $sql = "SELECT COUNT(*) AS attack_count
            FROM `".$prefix."fleets`
            WHERE `fleet_mission` IN (1, 2, 9)
            AND `fleet_target_owner` = :userId
            AND `fleet_owner` <> :userId
            AND `fleet_mess` = 0
            AND `fleet_end_time` > :now";

    $result = $db->selectSingle($sql, [
        ':userId' => $userId,
        ':now'    => $now,
    ]);

    $attackCount = isset($result['attack_count']) ? (int) $result['attack_count'] : 0;

    // ═══════ EVENTOS PVE (20=Crisis, 21=Imperio, 22=Contraataque) ═══════
    // Separados: aviso visual en la UI, pero la SIRENA de ataque NO debe
    // sonar por un evento NPC programado.
    $sqlPve = "SELECT COUNT(*) AS pve_count
               FROM `".$prefix."fleets`
               WHERE `fleet_mission` IN (20, 21, 22)
               AND `fleet_target_owner` = :userId
               AND `fleet_mess` = 0
               AND `fleet_end_time` > :now";

    $resultPve = $db->selectSingle($sqlPve, [
        ':userId' => $userId,
        ':now'    => $now,
    ]);

    $pveCount = isset($resultPve['pve_count']) ? (int) $resultPve['pve_count'] : 0;

    // ═══════ ESPIONAJES ENTRANTES (mission 6, solo ida, de otros) ═══════
    // Separados: aviso visual, NO sirena de ataque.
    $sqlSpy = "SELECT COUNT(*) AS spy_count
               FROM `".$prefix."fleets`"
               ." WHERE `fleet_mission` = 6"
               ." AND `fleet_target_owner` = :userId"
               ." AND `fleet_owner` <> :userId"
               ." AND `fleet_mess` = 0"
               ." AND `fleet_end_time` > :now";

    $resultSpy = $db->selectSingle($sqlSpy, [
        ':userId' => $userId,
        ':now'    => $now,
    ]);

    $spyCount = isset($resultSpy['spy_count']) ? (int) $resultSpy['spy_count'] : 0;

    echo json_encode([
        'hasAttack' => ($attackCount > 0),
        'total'     => $attackCount,
        'hasPve'    => ($pveCount > 0),
        'pveTotal'  => $pveCount,
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
