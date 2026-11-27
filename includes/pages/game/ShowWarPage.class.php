<?php
/**
 * ShowWarPage - Pagina del jugador del sistema de Guerra WAR
 * AstroIO v1.0
 *
 * v1h: anadido carga de cofres (tab "Cofres").
 */

if (!defined('MODE')) { die('Hacking attempt'); }

require_once 'includes/classes/WarHelper.class.php';
require_once 'includes/classes/WarClimatesHelper.class.php';

class ShowWarPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Punto de entrada. Decide que tab mostrar.
     */
    public function show()
    {
        global $USER, $LNG;

        $userId = (int)$USER['id'];
        $allyId = isset($USER['ally_id']) ? (int)$USER['ally_id'] : 0;

        // Tab activa (default: temporada)
        $tab = HTTP::_GP('tab', 'temporada');

        // Datos comunes
        $season   = WarHelper::getSeason();
        $activa   = WarHelper::seasonActive();
        $restante = WarHelper::seasonTimeLeft();

        // Feedback flash (comun)
        $ok  = HTTP::_GP('ok', '');
        $err = HTTP::_GP('err', '');
        $feedbackOk  = '';
        $feedbackErr = '';
        switch ($ok) {
            case 'declared': $feedbackOk = 'Guerra declarada correctamente.'; break;
            case 'sent':     $feedbackOk = 'Flotas enviadas a la guerra.'; break;
        }
        switch ($err) {
            case 'no_admin':    $feedbackErr = 'No eres administrador de tu alianza.'; break;
            case 'no_declare':  $feedbackErr = 'Tu alianza no puede declarar guerra ahora mismo.'; break;
            case 'invalid':     $feedbackErr = 'Datos invalidos.'; break;
            case 'create_fail': $feedbackErr = 'No se pudo crear la batalla.'; break;
            case 'empty':       $feedbackErr = 'No seleccionaste ninguna nave ni defensa.'; break;
            case 'no_battle':   $feedbackErr = 'Tu alianza no tiene una guerra activa.'; break;
        }

        // Sin alianza: mostrar mensaje
        if ($allyId <= 0) {
            $this->tplObj->assign_vars(array(
                'war_tab'         => $tab,
                'war_season'      => $season,
                'war_activa'      => $activa,
                'war_restante'    => $restante,
                'war_no_ally'     => true,
                'war_user_id'     => $userId,
                'war_ally_id'     => 0,
                'war_ally_name'   => '',
                'war_battle'      => null,
                'war_clima'       => null,
                'war_my_pts'      => 0,
                'war_ally_pts'    => 0,
                'war_cooldown'    => 0,
                'war_can_declare' => array('ok' => false, 'motivo' => 'Sin alianza'),
                'war_is_admin'    => false,
                'war_ranking'     => array(),
                'war_rivals'      => array(),
                'war_planetas'    => array(),
                'war_pesos_naves' => WarHelper::$PESOS_NAVES,
                'war_pesos_def'   => WarHelper::$PESOS_DEFENSAS,
                'war_history'     => array(),
                'war_full_ranking'=> array(),
                'war_rank_filter' => 'global',
                'war_rank_page'   => 1,
                'war_rank_pages'  => 1,
                'war_rank_total'  => 0,
                'war_rank_shown'  => 0,
                'war_rank_pagination' => array(),
                'war_chests'      => array(),
                'war_chests_total'=> 0,
                'war_feedback'    => array('ok' => $feedbackOk, 'err' => $feedbackErr),
            ));
            $this->display('page.war.default.tpl');
            return;
        }

        // Batalla activa de la alianza
        $battle = WarHelper::getActiveBattleForAlly($allyId);

        // Info del clima (si hay batalla)
        $clima = null;
        if (!empty($battle) && !empty($battle['clima_key'])) {
            $clima = WarClimatesHelper::get($battle['clima_key']);
        }

        // Puntos personales
        $myPoints = WarHelper::getUserPoints($userId);
        $myPts    = (int)(isset($myPoints['puntos']) ? $myPoints['puntos'] : 0);

        // Puntos de la alianza
        $allyPts  = WarHelper::getAllyDamage($allyId);

        // Nombre de la alianza
        $allyName = WarHelper::getAllyName($allyId);

        // Cooldown restante de la alianza
        $cooldownLeft = WarHelper::getAllyCooldownLeft($allyId);

        // Puede declarar guerra?
        $canDeclare = WarHelper::canAllyDeclare($allyId);

        // Es admin de la alianza?
        $isAllyAdmin = WarHelper::isAllyAdmin($userId, $allyId);

        // Ranking (top 10) — mini
        $ranking = WarHelper::getRanking(10);
        if (!$ranking) $ranking = array();

        // Rivales (solo si puede declarar)
        $rivals = array();
        if ($isAllyAdmin && !empty($canDeclare['ok'])) {
            $rivals = WarHelper::getRivals($allyId);
            if (!$rivals) $rivals = array();
        }

        // Planetas con naves (para el tab enviar)
        $planetas = array();
        if (!empty($battle)) {
            $planetas = WarHelper::getPlayerPlanetsWithShips($userId);
            if (!$planetas) $planetas = array();
        }

        // Historial de batallas de la alianza (solo si tab historial)
        $history = array();
        if ($tab === 'historial') {
            $history = self::getAllyHistory($allyId, 30);
        }

        // Ranking completo con paginacion (solo si tab ranking)
        $fullRanking    = array();
        $rankFilter     = 'global';
        $rankPage       = 1;
        $rankPages      = 1;
        $rankTotal      = 0;
        $rankShown      = 0;
        $rankPagination = array();

        if ($tab === 'ranking') {
            $rankFilter = HTTP::_GP('filter', 'global');
            if ($rankFilter !== 'ally') $rankFilter = 'global';

            $rankPage = (int)HTTP::_GP('p', 1);
            if ($rankPage < 1) $rankPage = 1;

            $perPage = 50;

            $rankData       = self::getFullRanking($allyId, $rankFilter, $rankPage, $perPage);
            $fullRanking    = $rankData['rows'];
            $rankTotal      = $rankData['total'];
            $rankShown      = count($fullRanking);
            $rankPages      = max(1, (int)ceil($rankTotal / $perPage));
            $rankPagination = $rankData['pagination'];
        }

        // Cofres del jugador (solo si tab cofres)
        $chests      = array();
        $chestsTotal = 0;
        if ($tab === 'cofres') {
            $chests      = self::getUserChests($userId);
            foreach ($chests as $c) {
                $chestsTotal += (int)$c['total'];
            }
        }

        // Asignar variables al template
        $this->tplObj->assign_vars(array(
            'war_tab'         => $tab,
            'war_season'      => $season,
            'war_activa'      => $activa,
            'war_restante'    => $restante,
            'war_no_ally'     => false,
            'war_user_id'     => $userId,
            'war_ally_id'     => $allyId,
            'war_ally_name'   => $allyName,
            'war_battle'      => $battle,
            'war_clima'       => $clima,
            'war_my_pts'      => $myPts,
            'war_ally_pts'    => $allyPts,
            'war_cooldown'    => $cooldownLeft,
            'war_can_declare' => $canDeclare,
            'war_is_admin'    => $isAllyAdmin,
            'war_ranking'     => $ranking,
            'war_rivals'      => $rivals,
            'war_planetas'    => $planetas,
            'war_pesos_naves' => WarHelper::$PESOS_NAVES,
            'war_pesos_def'   => WarHelper::$PESOS_DEFENSAS,
            'war_history'     => $history,
            'war_full_ranking'=> $fullRanking,
            'war_rank_filter' => $rankFilter,
            'war_rank_page'   => $rankPage,
            'war_rank_pages'  => $rankPages,
            'war_rank_total'  => $rankTotal,
            'war_rank_shown'  => $rankShown,
            'war_rank_pagination' => $rankPagination,
            'war_chests'      => $chests,
            'war_chests_total'=> $chestsTotal,
            'war_feedback'    => array(
                'ok'  => $feedbackOk,
                'err' => $feedbackErr,
            ),
        ));

        // display() carga el layout.full.tpl
        $this->display('page.war.default.tpl');
    }

    /**
     * POST: crear batalla.
     */
    public function doDeclare()
    {
        global $USER, $LNG;

        $userId   = (int)$USER['id'];
        $allyId   = isset($USER['ally_id']) ? (int)$USER['ally_id'] : 0;
        $targetId = (int)HTTP::_GP('target_id', 0);

        if ($allyId <= 0) {
            HTTP::redirectTo('game.php?page=war&err=invalid');
            return;
        }
        if (!WarHelper::isAllyAdmin($userId, $allyId)) {
            HTTP::redirectTo('game.php?page=war&err=no_admin');
            return;
        }
        if ($targetId <= 0 || $targetId === $allyId) {
            HTTP::redirectTo('game.php?page=war&err=invalid');
            return;
        }

        $canDeclare = WarHelper::canAllyDeclare($allyId);
        if (empty($canDeclare['ok'])) {
            HTTP::redirectTo('game.php?page=war&err=no_declare');
            return;
        }

        // Validar que el rival este en la lista sugerida
        $rivals = WarHelper::getRivals($allyId);
        if (!is_array($rivals) || !isset($rivals[$targetId])) {
            HTTP::redirectTo('game.php?page=war&err=invalid');
            return;
        }

        // Crear la batalla
        $battleId = WarHelper::createBattle($allyId, $targetId);
        if (!$battleId) {
            HTTP::redirectTo('game.php?page=war&err=create_fail');
            return;
        }

        // Notificar a ambas alianzas
        $myName     = WarHelper::getAllyName($allyId);
        $targetName = WarHelper::getAllyName($targetId);
        $asunto     = 'GUERRA DECLARADA';
        $mensaje    = "La alianza [b]{$myName}[/b] ha declarado la guerra a [b]{$targetName}[/b].\n\n"
                    . "Entra en la seccion GUERRA WAR para enviar tus flotas y defensas.";

        try {
            WarHelper::notifyAlly($allyId,   $asunto, $mensaje);
            WarHelper::notifyAlly($targetId, $asunto, $mensaje);
        } catch (Exception $e) {
            // Silencioso
        }

        // Log del usuario que declaro
        WarHelper::log($userId, 'battle_declared',
            "Usuario {$userId} de alianza {$allyId} declaro guerra a alianza {$targetId} (batalla #{$battleId})",
            $battleId);

        HTTP::redirectTo('game.php?page=war&ok=declared');
    }

    /**
     * POST: enviar flotas a la guerra.
     */
    public function sendFleet()
    {
        global $USER;

        $userId = (int)$USER['id'];
        $allyId = isset($USER['ally_id']) ? (int)$USER['ally_id'] : 0;

        if ($allyId <= 0) {
            HTTP::redirectTo('game.php?page=war&err=invalid');
            return;
        }

        $battle = WarHelper::getActiveBattleForAlly($allyId);
        if (empty($battle)) {
            HTTP::redirectTo('game.php?page=war&err=no_battle');
            return;
        }

        $planetas = WarHelper::getPlayerPlanetsWithShips($userId);
        if (empty($planetas)) {
            HTTP::redirectTo('game.php?page=war&tab=enviar&err=invalid');
            return;
        }

        $p  = DB_PREFIX;
        $db = Database::get();

        $navesTotales    = array();
        $defensasTotales = array();
        $porPlaneta      = array('ship' => array(), 'def' => array());
        $updatesPlanetas = array();

        foreach ($planetas as $pl) {
            $pid = (int)$pl['id'];

            $navesUpd = array();
            $defUpd   = array();

            // Naves
            foreach (WarHelper::$PESOS_NAVES as $col => $peso) {
                $val = (int)HTTP::_GP('ship_' . $col . '_p' . $pid, 0);
                if ($val <= 0) continue;

                $max = isset($pl[$col]) ? (int)$pl[$col] : 0;
                if ($val > $max) $val = $max;
                if ($val <= 0) continue;

                $navesTotales[$col] = (isset($navesTotales[$col]) ? $navesTotales[$col] : 0) + $val;
                $navesUpd[$col] = $val;
                $porPlaneta['ship'][$pid][$col] = $val;
            }

            // Defensas
            foreach (WarHelper::$PESOS_DEFENSAS as $col => $peso) {
                $val = (int)HTTP::_GP('def_' . $col . '_p' . $pid, 0);
                if ($val <= 0) continue;

                $max = isset($pl[$col]) ? (int)$pl[$col] : 0;
                if ($val > $max) $val = $max;
                if ($val <= 0) continue;

                $defensasTotales[$col] = (isset($defensasTotales[$col]) ? $defensasTotales[$col] : 0) + $val;
                $defUpd[$col] = $val;
                $porPlaneta['def'][$pid][$col] = $val;
            }

            if (!empty($navesUpd) || !empty($defUpd)) {
                $updatesPlanetas[$pid] = array_merge($navesUpd, $defUpd);
            }
        }

        if (empty($navesTotales) && empty($defensasTotales)) {
            HTTP::redirectTo('game.php?page=war&tab=enviar&err=empty');
            return;
        }

        // Descontar de cada planeta
        foreach ($updatesPlanetas as $pid => $upds) {
            $sets = array();
            foreach ($upds as $col => $cant) {
                $sets[] = "`" . $col . "` = `" . $col . "` - " . (int)$cant;
            }
            if (!empty($sets)) {
                $db->query(
                    "UPDATE `" . $p . "planets` SET " . implode(', ', $sets) . " WHERE `id` = " . (int)$pid
                );
            }
        }

        // Registrar participante
        WarHelper::registerParticipant(
            (int)$battle['id'],
            $userId,
            $allyId,
            $navesTotales,
            $defensasTotales,
            $porPlaneta
        );

        // Log
        WarHelper::log($userId, 'fleet_sent',
            "Envio a batalla #" . (int)$battle['id'],
            (int)$battle['id']);

        HTTP::redirectTo('game.php?page=war&tab=temporada&ok=sent');
    }

    /**
     * Muestra el reporte detallado de una batalla pasada.
     * URL: game.php?page=war&mode=report&id=X
     */
    public function report()
    {
        global $USER;

        $userId = (int)$USER['id'];
        $allyId = isset($USER['ally_id']) ? (int)$USER['ally_id'] : 0;

        if ($allyId <= 0) {
            HTTP::redirectTo('game.php?page=war&err=invalid');
            return;
        }

        $battleId = (int)HTTP::_GP('id', 0);
        if ($battleId <= 0) {
            HTTP::redirectTo('game.php?page=war&tab=historial');
            return;
        }

        $p  = DB_PREFIX;
        $db = Database::get();

        // Cargar batalla (debe ser de tu alianza)
        $battle = $db->selectSingle(
            "SELECT * FROM `" . $p . "war_battles`
             WHERE `id` = " . $battleId . "
               AND (`atacante_id` = " . $allyId . " OR `defensor_id` = " . $allyId . ")
             LIMIT 1"
        );
        if (empty($battle)) {
            HTTP::redirectTo('game.php?page=war&tab=historial');
            return;
        }

        // Datos basicos
        $season   = WarHelper::getSeason();
        $activa   = WarHelper::seasonActive();
        $restante = WarHelper::seasonTimeLeft();
        $allyName = WarHelper::getAllyName($allyId);
        $isAllyAdmin = WarHelper::isAllyAdmin($userId, $allyId);

        // Clima
        $clima = null;
        if (!empty($battle['clima_key'])) {
            $clima = WarClimatesHelper::get($battle['clima_key']);
        }

        // Rondas (JSON)
        $rondas = array();
        if (!empty($battle['rondas_json'])) {
            $decoded = json_decode($battle['rondas_json'], true);
            if (is_array($decoded)) $rondas = $decoded;
        }

        // Bajas
        $bajasA = array();
        $bajasD = array();
        if (!empty($battle['bajas_atacante_json'])) {
            $dec = json_decode($battle['bajas_atacante_json'], true);
            if (is_array($dec)) $bajasA = $dec;
        }
        if (!empty($battle['bajas_defensor_json'])) {
            $dec = json_decode($battle['bajas_defensor_json'], true);
            if (is_array($dec)) $bajasD = $dec;
        }

        // Bonus aplicados (extraer del json de la batalla si existe)
        // Por ahora los leemos del helper del banco
        $bonusA = array('attack' => 0, 'defense' => 0);
        $bonusD = array('attack' => 0, 'defense' => 0);
        if (class_exists('AllianceBankHelper')) {
            try {
                $ba = AllianceBankHelper::getActiveBonuses((int)$battle['atacante_id']);
                $bd = AllianceBankHelper::getActiveBonuses((int)$battle['defensor_id']);
                if (is_array($ba)) {
                    $bonusA['attack']  = isset($ba['attack'])  ? (int)$ba['attack']  : 0;
                    $bonusA['defense'] = isset($ba['defense']) ? (int)$ba['defense'] : 0;
                }
                if (is_array($bd)) {
                    $bonusD['attack']  = isset($bd['attack'])  ? (int)$bd['attack']  : 0;
                    $bonusD['defense'] = isset($bd['defense']) ? (int)$bd['defense'] : 0;
                }
            } catch (Exception $e) {
                // Silencioso
            }
        }

        // Datos del jugador
        $myPoints = WarHelper::getUserPoints($userId);
        $myPts    = (int)(isset($myPoints['puntos']) ? $myPoints['puntos'] : 0);
        $allyPts  = WarHelper::getAllyDamage($allyId);

        // Asignar
        $this->tplObj->assign_vars(array(
            'war_tab'         => 'historial',
            'war_season'      => $season,
            'war_activa'      => $activa,
            'war_restante'    => $restante,
            'war_no_ally'     => false,
            'war_user_id'     => $userId,
            'war_ally_id'     => $allyId,
            'war_ally_name'   => $allyName,
            'war_battle'      => $battle,
            'war_clima'       => $clima,
            'war_my_pts'      => $myPts,
            'war_ally_pts'    => $allyPts,
            'war_cooldown'    => 0,
            'war_can_declare' => array('ok' => false, 'motivo' => ''),
            'war_is_admin'    => $isAllyAdmin,
            'war_ranking'     => array(),
            'war_rivals'      => array(),
            'war_planetas'    => array(),
            'war_pesos_naves' => WarHelper::$PESOS_NAVES,
            'war_pesos_def'   => WarHelper::$PESOS_DEFENSAS,
            'war_history'     => array(),
            'war_full_ranking'=> array(),
            'war_rank_filter' => 'global',
            'war_rank_page'   => 1,
            'war_rank_pages'  => 1,
            'war_rank_total'  => 0,
            'war_rank_shown'  => 0,
            'war_rank_pagination' => array(),
            'war_chests'      => array(),
            'war_chests_total'=> 0,
            'war_report'      => array(
                'rondas'      => $rondas,
                'bajasA'      => $bajasA,
                'bajasD'      => $bajasD,
                'bonusA'      => $bonusA,
                'bonusD'      => $bonusD,
            ),
            'war_feedback'    => array('ok' => '', 'err' => ''),
        ));

        $this->display('page.war.report.tpl');
    }

    /**
     * Devuelve el historial de batallas de una alianza (finalizadas o canceladas).
     */
    private static function getAllyHistory($allyId, $limit = 30)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) return array();

        $p     = DB_PREFIX;
        $limit = max(1, min(100, (int)$limit));

        $rows = Database::get()->select(
            "SELECT `id`, `atacante_id`, `atacante_nombre`, `defensor_id`, `defensor_nombre`,
                    `inicio`, `fin`, `estado`, `resultado_final`, `clima_key`, `clima_nombre`
             FROM `" . $p . "war_battles`
             WHERE (`atacante_id` = " . $allyId . " OR `defensor_id` = " . $allyId . ")
               AND `estado` IN ('finalizada', 'cancelada')
             ORDER BY `fin` DESC
             LIMIT " . $limit
        );

        if (!$rows) return array();

        // Añadir campos calculados para el template
        foreach ($rows as &$r) {
            $r['es_atacante'] = ((int)$r['atacante_id'] === $allyId);
            $r['mi_nombre']   = $r['es_atacante'] ? $r['atacante_nombre'] : $r['defensor_nombre'];
            $r['rival_nombre']= $r['es_atacante'] ? $r['defensor_nombre'] : $r['atacante_nombre'];

            // Resultado desde la perspectiva de "mi alianza"
            $res = isset($r['resultado_final']) ? $r['resultado_final'] : '';
            if ($res === 'empate') {
                $r['mi_resultado'] = 'empate';
            } elseif ($res === 'victoria_atacante') {
                $r['mi_resultado'] = $r['es_atacante'] ? 'victoria' : 'derrota';
            } elseif ($res === 'victoria_defensor') {
                $r['mi_resultado'] = $r['es_atacante'] ? 'derrota' : 'victoria';
            } else {
                $r['mi_resultado'] = 'cancelada';
            }
        }
        unset($r);

        return $rows;
    }

    /**
     * Devuelve el ranking completo con paginacion.
     */
    private static function getFullRanking($myAllyId, $filter = 'global', $page = 1, $perPage = 50)
    {
        $myAllyId = (int)$myAllyId;
        $filter   = ($filter === 'ally') ? 'ally' : 'global';
        $page     = max(1, (int)$page);
        $perPage  = max(5, min(200, (int)$perPage));

        $p  = DB_PREFIX;
        $db = Database::get();

        // WHERE segun filtro
        $where = "wp.`puntos` > 0";
        if ($filter === 'ally' && $myAllyId > 0) {
            $where .= " AND u.`ally_id` = " . $myAllyId;
        }

        // Total
        $row = $db->selectSingle(
            "SELECT COUNT(*) AS total
             FROM `" . $p . "war_points` wp
             INNER JOIN `" . $p . "users` u ON u.`id` = wp.`user_id`
             WHERE " . $where
        );
        $total = !empty($row) && isset($row['total']) ? (int)$row['total'] : 0;

        // Datos de la pagina
        $offset = ($page - 1) * $perPage;

        $rows = $db->select(
            "SELECT wp.`user_id`, wp.`puntos`, u.`username`, u.`ally_id`, a.`ally_name`, a.`ally_tag`
             FROM `" . $p . "war_points` wp
             LEFT JOIN `" . $p . "users`    u ON u.`id` = wp.`user_id`
             LEFT JOIN `" . $p . "alliance` a ON a.`id` = u.`ally_id`
             WHERE " . $where . "
             ORDER BY wp.`puntos` DESC, wp.`user_id` ASC
             LIMIT " . $offset . ", " . $perPage
        );
        if (!$rows) $rows = array();

        // Marcar cada fila: es mi alianza? posicion?
        $rankPos = $offset + 1;
        foreach ($rows as &$r) {
            $r['alliance_name'] = !empty($r['ally_name']) ? $r['ally_name'] : '';
            $r['es_mi_alianza'] = ((int)$r['ally_id'] === $myAllyId);
            $r['pos']           = $rankPos;
            $rankPos++;
        }
        unset($r);

        // Paginacion
        $pages = max(1, (int)ceil($total / $perPage));
        $pagination = self::buildPagination($page, $pages);

        return array(
            'rows'       => $rows,
            'total'      => $total,
            'page'       => $page,
            'pages'      => $pages,
            'pagination' => $pagination,
        );
    }

    /**
     * Genera el array de paginacion (con '...' cuando hace falta).
     */
    private static function buildPagination($current, $pages)
    {
        $out = array();
        if ($pages <= 1) return $out;

        // Mostrar hasta 7 numeros + '...'
        $out[] = 1;
        if ($current > 3) $out[] = '...';
        for ($i = max(2, $current - 1); $i <= min($pages - 1, $current + 1); $i++) {
            $out[] = $i;
        }
        if ($current < $pages - 2) $out[] = '...';
        if ($pages > 1) $out[] = $pages;

        // Eliminar duplicados si quedaron
        $out = array_values(array_unique($out));
        return $out;
    }

    /**
     * Devuelve los cofres del jugador agrupados por tipo (I-VII).
     * Devuelve siempre los 7 tipos, con 0 si no tiene.
     */
    private static function getUserChests($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return array();

        $p = DB_PREFIX;

        $rows = Database::get()->select(
            "SELECT `tipo`, SUM(`cantidad`) AS total, MAX(`rarro`) AS tiene_rarro
             FROM `" . $p . "war_chests`
             WHERE `user_id` = " . $userId . "
             GROUP BY `tipo`"
        );
        if (!$rows) $rows = array();

        // Indexar por tipo
        $map = array();
        foreach ($rows as $r) {
            $t = isset($r['tipo']) ? (string)$r['tipo'] : '';
            if ($t === '') continue;
            $map[$t] = array(
                'tipo'   => $t,
                'total'  => isset($r['total']) ? (int)$r['total'] : 0,
                'rarro'  => !empty($r['tiene_rarro']),
            );
        }

        // Devolver siempre en orden I..VII
        $order = array('I', 'II', 'III', 'IV', 'V', 'VI', 'VII');
        $out = array();
        foreach ($order as $t) {
            if (isset($map[$t])) {
                $out[] = $map[$t];
            } else {
                $out[] = array('tipo' => $t, 'total' => 0, 'rarro' => false);
            }
        }

        return $out;
    }
}