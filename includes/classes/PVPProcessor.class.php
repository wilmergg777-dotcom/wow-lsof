<?php

/**
 * AstroIO — PVPProcessor
 * Cron del sistema PvP (Arenas + Torneos)
 *
 * Ubicación: includes/classes/PVPProcessor.class.php
 * @package AstroIO
 * @version 2.0 — Doble Riel (NTX-20 / UNTX-20)
 *
 * v1.0 — Cron base PvP (Arenas + Torneos)
 * v2.0 — Doble Riel:
 *        · Notificaciones por jugador muestran su moneda correcta
 *        · Avisos de arena usan monto real (base ×2 si QVAPAY)
 *        · Aviso de premio por expirar usa pool del riel del jugador
 *        · getStats() añade desglose pool_ntx20 / pool_untx20
 *
 * Uso:
 *   PVPProcessor::run();                    // Se llama desde ShowOverviewPage (cache 5 min)
 *   PVPProcessor::run(true);                // Bypass forzado (para testing)
 *
 * Se recomienda llamar desde ShowOverviewPage::show() al inicio.
 */

class PVPProcessor
{
    /* ============================================================
     *  CONSTANTES
     * ============================================================ */

    // Frecuencia mínima entre ejecuciones (segundos)
    const RUN_INTERVAL = 300; // 5 min

    // Ventana de aviso previo (1h antes)
    const NOTIFY_BEFORE = 3600;

    // Ventana de aviso de premio por expirar (24h antes)
    const NOTIFY_PRIZE_BEFORE = 86400;

    // Clave de sesión para cachear última ejecución
    const SESSION_KEY = 'pvp_last_run';


    /* ============================================================
     *  EJECUCIÓN PRINCIPAL
     * ============================================================ */

    /**
     * Ejecuta todas las tareas del cron.
     *
     * @param bool $force  Si true, ignora el cache de 5 min.
     * @return array       Resumen de lo ejecutado
     */
    public static function run($force = false)
    {
        $startTime = microtime(true);

        // Verificar cache de sesión (evita ejecutar en cada request)
        if (!$force && !self::shouldRun()) {
            return array(
                'skipped' => true,
                'reason'  => 'Cache de ' . self::RUN_INTERVAL . 's aún activo.',
            );
        }

        // Verificar que los helpers estén cargados
        self::ensureHelpers();

        $result = array(
            'arenas_expired'             => 0,
            'arenas_resolved'            => 0,
            'arenas_extra_time'          => 0,
            'tournaments_reg_closed'     => 0,
            'tournaments_round_resolved' => 0,
            'notifications_sent'         => 0,
            'errors'                     => array(),
        );

        // ─── 1. Expirar arenas sin llenarse ───
        try {
            $result['arenas_expired'] = self::safeCall(array('PVPArenaHelper', 'expireArenas'));
        } catch (Exception $e) {
            $result['errors'][] = 'expireArenas: ' . $e->getMessage();
            PVPHelper::log('cron', 0, 'expire_arenas_error', 0, array(
                'error' => $e->getMessage(),
            ));
        }

        // ─── 2. Resolver arenas activas (o iniciar tiempo extra) ───
        try {
            $result['arenas_resolved'] = self::safeCall(array('PVPArenaHelper', 'resolveActiveArenas'));
        } catch (Exception $e) {
            $result['errors'][] = 'resolveActiveArenas: ' . $e->getMessage();
            PVPHelper::log('cron', 0, 'resolve_arenas_error', 0, array(
                'error' => $e->getMessage(),
            ));
        }

        // ─── 3. Cerrar inscripciones de torneos que expiran ───
        try {
            $result['tournaments_reg_closed'] = self::safeCall(array('PVPTournamentHelper', 'processRegistrationTimeouts'));
        } catch (Exception $e) {
            $result['errors'][] = 'processRegistrationTimeouts: ' . $e->getMessage();
            PVPHelper::log('cron', 0, 'reg_timeouts_error', 0, array(
                'error' => $e->getMessage(),
            ));
        }

        // ─── 4. Resolver rondas de torneos que expiran ───
        try {
            $result['tournaments_round_resolved'] = self::safeCall(array('PVPTournamentHelper', 'processRoundTimeouts'));
        } catch (Exception $e) {
            $result['errors'][] = 'processRoundTimeouts: ' . $e->getMessage();
            PVPHelper::log('cron', 0, 'round_timeouts_error', 0, array(
                'error' => $e->getMessage(),
            ));
        }

        // ─── 5. Notificaciones de aviso (1h antes de arrancar) ───
        try {
            $result['notifications_sent'] += self::notifyUpcomingArenas();
            $result['notifications_sent'] += self::notifyUpcomingTournaments();
        } catch (Exception $e) {
            $result['errors'][] = 'notifications: ' . $e->getMessage();
            PVPHelper::log('cron', 0, 'notifications_error', 0, array(
                'error' => $e->getMessage(),
            ));
        }

        // ─── 6. Notificaciones de premios por expirar ───
        try {
            $result['notifications_sent'] += self::notifyExpiringPrizes();
        } catch (Exception $e) {
            $result['errors'][] = 'prize_notifications: ' . $e->getMessage();
        }

        // Guardar timestamp de última ejecución
        self::markRan();

        $duration = round(microtime(true) - $startTime, 3);

        // Log resumen
        PVPHelper::log('cron', 0, 'run_complete', 0, array(
            'duration'  => $duration,
            'result'    => $result,
        ));

        $result['duration'] = $duration;
        $result['skipped']  = false;
        return $result;
    }


    /* ============================================================
     *  CACHE DE EJECUCIÓN
     * ============================================================ */

    /**
     * ¿Debe ejecutarse el cron? (no se ejecutó en los últimos RUN_INTERVAL segundos)
     */
    public static function shouldRun()
    {
        if (!isset($_SESSION)) {
            // Sin sesión no podemos cachear → ejecutar (raro)
            return true;
        }

        $lastRun = isset($_SESSION[self::SESSION_KEY]) ? (int) $_SESSION[self::SESSION_KEY] : 0;
        return (TIMESTAMP - $lastRun) >= self::RUN_INTERVAL;
    }

    /**
     * Marca la última ejecución.
     */
    private static function markRan()
    {
        if (isset($_SESSION)) {
            $_SESSION[self::SESSION_KEY] = TIMESTAMP;
        }
    }

    /**
     * Fuerza la próxima ejecución del cron (útil para testing).
     */
    public static function resetCache()
    {
        if (isset($_SESSION)) {
            unset($_SESSION[self::SESSION_KEY]);
        }
    }


    /* ============================================================
     *  CARGA DE HELPERS
     * ============================================================ */

    /**
     * Asegura que los helpers necesarios estén cargados.
     */
    private static function ensureHelpers()
    {
        $base = defined('ROOT_PATH') ? ROOT_PATH : dirname(dirname(__FILE__)) . '/';

        $files = array(
            'PVPHelper.class.php',
            'PVPArenaHelper.class.php',
            'PVPTournamentHelper.class.php',
        );

        foreach ($files as $f) {
            $path = $base . 'includes/classes/' . $f;
            if (file_exists($path) && !class_exists(str_replace('.class.php', '', $f))) {
                require_once $path;
            }
        }
    }


    /**
     * Llama a un método estático de forma segura.
     */
    private static function safeCall($callback, $args = array())
    {
        if (!is_callable($callback)) {
            return 0;
        }

        try {
            $result = call_user_func_array($callback, $args);
            return is_int($result) ? $result : 0;
        } catch (Throwable $e) {
            return 0;
        }
    }


    /* ============================================================
     *  NOTIFICACIONES — AVISOS PREVIOS
     * ============================================================ */

    /**
     * Notifica a los jugadores de arenas que empiezan en menos de 1h
     * (aunque solo se llenan cuando se llenan, este aviso aplica si están
     * a punto de expirar sin llenarse).
     *
     * v2.0 — Cada jugador recibe el aviso con SU moneda y SU monto real.
     *
     * @return int
     */
    public static function notifyUpcomingArenas()
    {
        $db  = Database::get();
        $now = TIMESTAMP;

        // Arenas waiting que expiran en menos de 1h
        $expire = self::getArenaExpireSeconds();
        $threshold = $now + self::NOTIFY_BEFORE;
        $limitTime = $threshold - $expire;

        $rows = $db->select(
            "SELECT `id`, `created_at`, `entry_fee`, `mode` 
             FROM %%PVP_ARENAS%% 
             WHERE `status` = 'waiting' 
               AND `created_at` >= :limit 
               AND `created_at` < :limit2;",
            array(
                ':limit'  => $limitTime,
                ':limit2' => $limitTime + 60,
            )
        );

        if (empty($rows)) {
            return 0;
        }

        $sent = 0;
        foreach ($rows as $arena) {
            $arenaId  = (int) $arena['id'];
            $feeBase  = (int) $arena['entry_fee'];

            // Jugadores de esa arena
            $players = $db->select(
                "SELECT `user_id` FROM %%PVP_ARENA_PLAYERS%% WHERE `arena_id` = :aid;",
                array(':aid' => $arenaId)
            );

            foreach ($players as $p) {
                $puid   = (int) $p['user_id'];
                $moneda = PVPHelper::getCurrencyLabel($puid);
                $realFee = PVPHelper::getPrecioParaJugador($feeBase, $puid);

                PVPHelper::sendNotification(
                    $puid,
                    'Aviso: arena por expirar',
                    'La arena #' . $arenaId . ' (' . $arena['mode'] . ') expirará en 1 hora si no se llena.<br>'
                    . 'Entrada: ' . number_format($realFee) . ' ' . $moneda . '.<br>'
                    . '<a href="game.php?page=pvp&tab=arenas">Ver arena</a>'
                );
                $sent++;
            }
        }

        return $sent;
    }

    /**
     * Notifica a los jugadores de torneos que empiezan en menos de 1h
     * (aviso previo al arranque).
     */
    public static function notifyUpcomingTournaments()
    {
        $db  = Database::get();
        $now = TIMESTAMP;

        // Torneos en registration que arrancan en 1h
        $rows = $db->select(
            "SELECT `id`, `type`, `registration_ends_at` 
             FROM %%PVP_TOURNAMENTS%% 
             WHERE `status` = 'registration' 
               AND `registration_ends_at` >= :now 
               AND `registration_ends_at` <= :limit;",
            array(
                ':now'   => $now,
                ':limit' => $now + self::NOTIFY_BEFORE,
            )
        );

        if (empty($rows)) {
            return 0;
        }

        $sent = 0;
        foreach ($rows as $t) {
            $tid = (int) $t['id'];
            $regEnds = (int) $t['registration_ends_at'];

            // Jugadores inscritos
            $players = $db->select(
                "SELECT `user_id` FROM %%PVP_TOURNAMENT_PLAYERS%% 
                 WHERE `tournament_id` = :tid;",
                array(':tid' => $tid)
            );

            foreach ($players as $p) {
                PVPHelper::sendNotification(
                    (int) $p['user_id'],
                    '¡Tu torneo comienza pronto!',
                    'El torneo #' . $tid . ' (' . $t['type'] . ') arranca en menos de 1 hora.<br>'
                    . 'Cierre de inscripciones: ' . date('d/m/Y H:i', $regEnds) . '<br>'
                    . '<a href="game.php?page=pvp&tab=tournaments">Ver torneo</a>'
                );
                $sent++;
            }
        }

        return $sent;
    }

    /**
     * Notifica a los ganadores cuyo plazo para reclamar premio está por expirar.
     *
     * v2.0 — Cada ganador recibe la notificación con SU moneda y SU pool.
     */
    public static function notifyExpiringPrizes()
    {
        $db  = Database::get();
        $now = TIMESTAMP;

        // Arenas finalizadas cuyo claim_deadline está por expirar en 24h
        $rows = $db->select(
            "SELECT `id`, `winner_team`, `prize_pool`, `pool_ntx20`, `pool_untx20`, `claim_deadline` 
             FROM %%PVP_ARENAS%% 
             WHERE `status` = 'finished' 
               AND `claim_deadline` > :now 
               AND `claim_deadline` <= :limit;",
            array(
                ':now'   => $now,
                ':limit' => $now + self::NOTIFY_PRIZE_BEFORE,
            )
        );

        if (empty($rows)) {
            return 0;
        }

        $sent = 0;
        foreach ($rows as $arena) {
            $arenaId    = (int) $arena['id'];
            $winnerTeam = (int) $arena['winner_team'];
            $poolNtx    = (int) $arena['pool_ntx20'];
            $poolUntx   = (int) $arena['pool_untx20'];

            // Si ambos pools están vacíos, no notificar
            if ($poolNtx <= 0 && $poolUntx <= 0) continue;

            // Ganadores que aún no reclamaron (paid != 2)
            $players = $db->select(
                "SELECT `user_id` FROM %%PVP_ARENA_PLAYERS%% 
                 WHERE `arena_id` = :aid 
                   AND `team` = :team 
                   AND `paid` != 2;",
                array(':aid' => $arenaId, ':team' => $winnerTeam)
            );

            // Contar ganadores por riel (para estimar el premio individual)
            $countCup    = 0;
            $countQvapay = 0;
            foreach ($players as $p) {
                if (PVPHelper::getPlayerMethod((int) $p['user_id']) === 'QVAPAY') {
                    $countQvapay++;
                } else {
                    $countCup++;
                }
            }

            foreach ($players as $p) {
                $puid   = (int) $p['user_id'];
                $riel   = PVPHelper::getPlayerMethod($puid);
                $moneda = PVPHelper::getCurrencyLabel($puid);

                if ($riel === 'QVAPAY') {
                    $estimated = ($countQvapay > 0) ? (int) floor($poolUntx / $countQvapay) : 0;
                } else {
                    $estimated = ($countCup > 0) ? (int) floor($poolNtx / $countCup) : 0;
                }

                if ($estimated <= 0) continue;

                PVPHelper::sendNotification(
                    $puid,
                    'Premio por expirar',
                    'Tienes un premio pendiente de la arena #' . $arenaId . '.<br>'
                    . 'Premio estimado: <b>' . number_format($estimated) . ' ' . $moneda . '</b><br>'
                    . 'Reclámalo antes de 24h o se perderá.<br>'
                    . '<a href="game.php?page=pvp&tab=arenas">Reclamar premio</a>'
                );
                $sent++;
            }
        }

        return $sent;
    }


    /* ============================================================
     *  HELPERS INTERNOS
     * ============================================================ */

    /**
     * Devuelve el tiempo de expiración de arenas en segundos.
     */
    private static function getArenaExpireSeconds()
    {
        if (class_exists('PVPArenaHelper')) {
            return PVPArenaHelper::getExpire();
        }
        return 86400; // fallback 24h
    }


    /* ============================================================
     *  ESTADÍSTICAS (para el admin)
     * ============================================================ */

    /**
     * Devuelve estadísticas generales del sistema PvP.
     *
     * v2.0 — Añade desglose pool_ntx20 y pool_untx20. Los campos legacy
     *        `prize_pool_arenas` y `prize_pool_tournaments` se mantienen
     *        para no romper el panel admin existente.
     *
     * @return array
     */
    public static function getStats()
    {
        $db = Database::get();

        $stats = array(
            'arenas_waiting'      => 0,
            'arenas_active'       => 0,
            'arenas_finished'     => 0,
            'tournaments_active'  => 0,
            'tournaments_finished' => 0,
            'players_in_arenas'   => 0,
            'prize_pool_arenas'   => 0,
            'prize_pool_tournaments' => 0,
            // 🆕 Desglose por riel
            'prize_pool_arenas_ntx20'      => 0,
            'prize_pool_arenas_untx20'     => 0,
            'prize_pool_tournaments_ntx20' => 0,
            'prize_pool_tournaments_untx20' => 0,
        );

        try {
            $row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` = 'waiting';");
            $stats['arenas_waiting'] = empty($row) ? 0 : (int) $row['c'];

            $row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` IN ('active','extra_time');");
            $stats['arenas_active'] = empty($row) ? 0 : (int) $row['c'];

            $row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` = 'finished';");
            $stats['arenas_finished'] = empty($row) ? 0 : (int) $row['c'];

            $row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_TOURNAMENTS%% WHERE `status` IN ('registration','running');");
            $stats['tournaments_active'] = empty($row) ? 0 : (int) $row['c'];

            $row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_TOURNAMENTS%% WHERE `status` = 'finished';");
            $stats['tournaments_finished'] = empty($row) ? 0 : (int) $row['c'];

            $row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENA_PLAYERS%% ap INNER JOIN %%PVP_ARENAS%% a ON a.`id` = ap.`arena_id` WHERE a.`status` IN ('waiting','active','extra_time');");
            $stats['players_in_arenas'] = empty($row) ? 0 : (int) $row['c'];

            // Pools de arenas (legacy + desglose)
            $row = $db->selectSingle(
                "SELECT 
                    COALESCE(SUM(`prize_pool`),0) AS total,
                    COALESCE(SUM(`pool_ntx20`),0) AS total_ntx,
                    COALESCE(SUM(`pool_untx20`),0) AS total_untx
                 FROM %%PVP_ARENAS%% 
                 WHERE `status` IN ('waiting','active','extra_time');"
            );
            $stats['prize_pool_arenas']          = empty($row) ? 0 : (int) $row['total'];
            $stats['prize_pool_arenas_ntx20']    = empty($row) ? 0 : (int) $row['total_ntx'];
            $stats['prize_pool_arenas_untx20']   = empty($row) ? 0 : (int) $row['total_untx'];

            // Pools de torneos (legacy + desglose)
            $row = $db->selectSingle(
                "SELECT 
                    COALESCE(SUM(`prize_pool`),0) AS total,
                    COALESCE(SUM(`pool_ntx20`),0) AS total_ntx,
                    COALESCE(SUM(`pool_untx20`),0) AS total_untx
                 FROM %%PVP_TOURNAMENTS%% 
                 WHERE `status` IN ('registration','running');"
            );
            $stats['prize_pool_tournaments']          = empty($row) ? 0 : (int) $row['total'];
            $stats['prize_pool_tournaments_ntx20']    = empty($row) ? 0 : (int) $row['total_ntx'];
            $stats['prize_pool_tournaments_untx20']   = empty($row) ? 0 : (int) $row['total_untx'];

        } catch (Exception $e) {
            PVPHelper::log('system', 0, 'get_stats_error', 0, array(
                'error' => $e->getMessage(),
            ));
        }

        return $stats;
    }
}