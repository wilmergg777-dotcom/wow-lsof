<?php
/**
 * ShowWarAdminPage - Panel de admin del sistema de Guerra WAR
 * AstroIO v1.0
 *
 * IMPORTANTE: es una FUNCION, no una clase.
 * Se llama desde admin.php?page=war
 *
 * v3: anadida gestion de batallas:
 *      - Cancelar batalla
 *      - Forzar finalizacion
 *      - Ver participantes
 */

if (!defined('MODE')) { die('Hacking attempt'); }

require_once 'includes/classes/WarHelper.class.php';
require_once 'includes/classes/WarClimatesHelper.class.php';

function ShowWarAdmin()
{
    global $USER, $LNG;

    // Verificar permisos
    if ((int)$USER['authlevel'] < 1) {
        message('Sin permisos', 'No eres administrador.', 'admin.php', false);
        return;
    }

    $p  = DB_PREFIX;
    $db = Database::get();

    $mode = HTTP::_GP('mode', '');

    // ============================================================
    // ACCIONES (POST / GET)
    // ============================================================
    if ($mode !== '') {
        switch ($mode) {

            case 'activate':
                $nombre     = HTTP::_GP('nombre', 'Guerra Galactica');
                $durBatalla = (int)HTTP::_GP('dur_batalla', 7);
                $cooldown   = (int)HTTP::_GP('cooldown', 7);

                // === Duracion temporada (dropdown + custom) ===
                $horasRaw    = HTTP::_GP('horas', '7');
                $horasCustom = (int)HTTP::_GP('horas_custom', 0);

                if ($horasRaw === 'custom' || !is_numeric($horasRaw)) {
                    // Eligio "Personalizado" en el dropdown
                    $horas = $horasCustom > 0 ? $horasCustom : 7;
                } else {
                    $horas = (int)$horasRaw;
                }

                // Validaciones
                if ($horas < 1)        $horas = 7;
                if ($horas > 840)      $horas = 840;        // max 35 dias
                if ($durBatalla < 1)   $durBatalla = 7;
                if ($durBatalla > 168) $durBatalla = 168;   // max 7 dias
                if ($cooldown < 0)     $cooldown = 0;
                if ($cooldown > 168)   $cooldown = 168;     // max 7 dias

                WarHelper::activateSeason($nombre, $horas, $durBatalla, $cooldown);
                WarHelper::log((int)$USER['id'], 'season_activated', "Nombre: {$nombre}, Horas: {$horas}, Batalla: {$durBatalla}h, Cooldown: {$cooldown}h");

                HTTP::redirectTo('admin.php?page=war&ok=activated');
                break;

            case 'pause':
                WarHelper::pauseSeason();
                WarHelper::log((int)$USER['id'], 'season_paused', '');
                HTTP::redirectTo('admin.php?page=war&ok=paused');
                break;

            case 'resume':
                WarHelper::resumeSeason();
                WarHelper::log((int)$USER['id'], 'season_resumed', '');
                HTTP::redirectTo('admin.php?page=war&ok=resumed');
                break;

            case 'close':
                WarHelper::closeSeason();
                WarHelper::log((int)$USER['id'], 'season_closed', 'Temporada cerrada');
                HTTP::redirectTo('admin.php?page=war&ok=closed');
                break;

            case 'reset':
                WarHelper::resetAll();
                WarHelper::log((int)$USER['id'], 'season_reset', 'Todo reseteado');
                HTTP::redirectTo('admin.php?page=war&ok=reset');
                break;

            case 'cancel_battle':
                $battleId = (int)HTTP::_GP('id', 0);
                if ($battleId > 0) {
                    $db->query(
                        "UPDATE `{$p}war_battles`
                         SET `estado` = 'cancelada', `resultado_final` = 'cancelada'
                         WHERE `id` = {$battleId} AND `estado` = 'en_curso'"
                    );
                    WarHelper::log((int)$USER['id'], 'battle_cancelled_admin',
                        "Batalla #{$battleId} cancelada por admin", $battleId);
                }
                HTTP::redirectTo('admin.php?page=war&ok=cancelled');
                break;

            case 'finish_battle':
                $battleId = (int)HTTP::_GP('id', 0);
                if ($battleId > 0) {
                    // Forzar fin = ahora (para que el processor la tome)
                    $now = (int)TIMESTAMP;
                    $db->query(
                        "UPDATE `{$p}war_battles`
                         SET `fin` = {$now}
                         WHERE `id` = {$battleId} AND `estado` = 'en_curso'"
                    );

                    // Ejecutar el WarProcessor
                    $procFile = ROOT_PATH . 'includes/classes/WarProcessor.class.php';
                    if (file_exists($procFile)) {
                        require_once $procFile;
                        if (class_exists('WarProcessor')) {
                            try {
                                WarProcessor::processFinished();
                            } catch (Exception $e) {
                                // Silencioso
                            }
                        }
                    }

                    WarHelper::log((int)$USER['id'], 'battle_forced_finish',
                        "Batalla #{$battleId} finalizada manualmente por admin", $battleId);
                }
                HTTP::redirectTo('admin.php?page=war&ok=finished');
                break;

            default:
                // Modo desconocido, volver al panel
                HTTP::redirectTo('admin.php?page=war');
                break;
        }
        return;
    }

    // ============================================================
    // DATOS PARA EL TEMPLATE
    // ============================================================
    $season   = WarHelper::getSeason();
    $restante = WarHelper::seasonTimeLeft();

    // --- Batallas en curso ---
    $battles = $db->select(
        "SELECT * FROM `{$p}war_battles`
         WHERE `estado` = 'en_curso'
         ORDER BY `id` DESC LIMIT 20"
    );
    if (!$battles) $battles = array();

    // Contar participantes por batalla
    foreach ($battles as &$b) {
        $row = $db->selectSingle(
            "SELECT COUNT(*) AS c FROM `{$p}war_participants`
             WHERE `battle_id` = " . (int)$b['id']
        );
        $b['participants_count'] = !empty($row) ? (int)$row['c'] : 0;
    }
    unset($b);

    // --- Batallas finalizadas recientes ---
    $battlesFinished = $db->select(
        "SELECT * FROM `{$p}war_battles`
         WHERE `estado` IN ('finalizada', 'cancelada')
         ORDER BY `id` DESC LIMIT 10"
    );
    if (!$battlesFinished) $battlesFinished = array();

    // Contar participantes por batalla finalizada
    foreach ($battlesFinished as &$b) {
        $row = $db->selectSingle(
            "SELECT COUNT(*) AS c FROM `{$p}war_participants`
             WHERE `battle_id` = " . (int)$b['id']
        );
        $b['participants_count'] = !empty($row) ? (int)$row['c'] : 0;
    }
    unset($b);

    // --- Historial de temporadas ---
    $historial = $db->select(
        "SELECT * FROM `{$p}war_history`
         ORDER BY `id` DESC LIMIT 10"
    );
    if (!$historial) $historial = array();

    // --- Top 10 ranking ---
    $ranking = WarHelper::getRanking(10);
    if (!$ranking) $ranking = array();

    // --- Ver participantes de una batalla concreta ---
    $viewBattleId     = (int)HTTP::_GP('view', 0);
    $viewBattle       = null;
    $viewParticipants = array();

    if ($viewBattleId > 0) {
        $viewBattle = $db->selectSingle(
            "SELECT * FROM `{$p}war_battles` WHERE `id` = {$viewBattleId} LIMIT 1"
        );

        if (!empty($viewBattle)) {
            $viewParticipants = $db->select(
                "SELECT p.*, u.`username`
                 FROM `{$p}war_participants` p
                 LEFT JOIN `{$p}users` u ON u.`id` = p.`user_id`
                 WHERE p.`battle_id` = {$viewBattleId}
                 ORDER BY p.`id` ASC"
            );
            if (!$viewParticipants) $viewParticipants = array();

            // Decodificar JSON de cada participante para mostrarlo en el template
            foreach ($viewParticipants as &$vp) {
                $naves = json_decode($vp['naves_json'], true);
                $defs  = json_decode($vp['defensas_json'], true);

                $vp['naves_arr']     = is_array($naves) ? $naves : array();
                $vp['defensas_arr']  = is_array($defs)  ? $defs  : array();
                $vp['total_naves']   = array_sum($vp['naves_arr']);
                $vp['total_defensas']= array_sum($vp['defensas_arr']);

                // Bando: 0 = atacante, 1 = defensor
                $vp['es_atacante'] = ((int)$vp['alliance_id'] === (int)$viewBattle['atacante_id']);
            }
            unset($vp);
        }
    }

    // --- Mensaje de estado (si viene por URL) ---
    $ok  = HTTP::_GP('ok', '');
    $msg = '';
    switch ($ok) {
        case 'activated': $msg = 'Temporada activada correctamente.'; break;
        case 'paused':    $msg = 'Temporada pausada.'; break;
        case 'resumed':   $msg = 'Temporada reanudada.'; break;
        case 'closed':    $msg = 'Temporada cerrada. Retiros habilitados.'; break;
        case 'reset':     $msg = 'Estadisticas reseteadas.'; break;
        case 'cancelled': $msg = 'Batalla cancelada correctamente.'; break;
        case 'finished':  $msg = 'Batalla finalizada. Los puntos fueron repartidos.'; break;
    }

    // ============================================================
    // ASIGNAR AL TEMPLATE
    // ============================================================
    $template = new Template();
    $template->assign_vars(array(
        'war_season'            => $season,
        'war_restante'          => $restante,
        'war_battles'           => $battles,
        'war_battles_fin'       => $battlesFinished,
        'war_historial'         => $historial,
        'war_ranking'           => $ranking,
        'war_msg'               => $msg,
        'war_all_climates'      => WarClimatesHelper::all(),
        'war_view_battle'       => $viewBattle,
        'war_view_participants' => $viewParticipants,
        'war_view_id'           => $viewBattleId,
    ));
    $template->show('warAdminPage.tpl');
}