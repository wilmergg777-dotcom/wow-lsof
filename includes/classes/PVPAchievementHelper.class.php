<?php

/**
 * AstroIO — PVPAchievementHelper
 * Logros del sistema PvP (Arenas + Torneos)
 *
 * v1.1 — RECOMPENSAS EN MATERIA OSCURA:
 *   - Sustituye NTX-20 por DM (entrega directa a uni1_users.darkmatter)
 *   - Ya no usa PVPHelper::addNxt20() para logros
 *   - Notificación con icono 🌌 y texto "Materia Oscura"
 *   - Log registra 'reward_dm' en vez de 'reward'
 *
 * v2.0 — Sin cambios dual-riel:
 *   · Este helper entrega Materia Oscura (DM), NO NTX-20/UNTX-20.
 *   · No aplica la regla ×2 ni la detección de riel.
 *   · Si en el futuro los logros vuelven a dar NTX-20, habría que
 *     aplicar `PVPHelper::getPremioParaJugador()` para QVAPAY.
 *
 * Ubicación: includes/classes/PVPAchievementHelper.class.php
 * @package AstroIO
 * @version 2.0
 */

class PVPAchievementHelper
{
    /* ============================================================
     *  DEFINICIÓN DE LOGROS
     * ============================================================ */

    const ACHIEVEMENTS = array(
        // ─── Torneos ───
        1 => array(
            'key'         => 'first_tournament',
            'label'       => 'Primer torneo ganado',
            'icon'        => '🥇',
            'color'       => '#ffd700',
            'description' => 'Gana tu primer torneo.',
            'type'        => 'tournaments_won',
            'target'      => 1,
            'reward_dm'   => 200,
        ),
        2 => array(
            'key'         => 'winner_5',
            'label'       => 'Ganador',
            'icon'        => '🏆',
            'color'       => '#ffaa33',
            'description' => 'Gana 5 torneos.',
            'type'        => 'tournaments_won',
            'target'      => 5,
            'reward_dm'   => 800,
        ),
        3 => array(
            'key'         => 'legend_10',
            'label'       => 'Leyenda',
            'icon'        => '👑',
            'color'       => '#dd99ff',
            'description' => 'Gana 10 torneos.',
            'type'        => 'tournaments_won',
            'target'      => 10,
            'reward_dm'   => 2000,
        ),
        4 => array(
            'key'         => 'alliance_champ',
            'label'       => 'Alianza campeona',
            'icon'        => '🛡️',
            'color'       => '#88ddff',
            'description' => 'Gana 1 torneo de alianza.',
            'type'        => 'alliance_tournaments_won',
            'target'      => 1,
            'reward_dm'   => 500,
        ),
        5 => array(
            'key'         => 'alliance_legend',
            'label'       => 'Alianza legendaria',
            'icon'        => '⚔️',
            'color'       => '#ff6666',
            'description' => 'Gana 5 torneos de alianza consecutivos.',
            'type'        => 'alliance_streak',
            'target'      => 5,
            'reward_dm'   => 2500,
        ),

        // ─── Arenas (victorias por modalidad) ───
        6 => array(
            'key'         => 'gladiator_1v1',
            'label'       => 'Gladiador 1v1',
            'icon'        => '⚔️',
            'color'       => '#ff8888',
            'description' => 'Gana 10 arenas 1v1.',
            'type'        => 'arena_wins_1v1',
            'target'      => 10,
            'reward_dm'   => 500,
        ),
        7 => array(
            'key'         => 'gladiator_2v2',
            'label'       => 'Gladiador 2v2',
            'icon'        => '⚔️',
            'color'       => '#ffaa88',
            'description' => 'Gana 10 arenas 2v2.',
            'type'        => 'arena_wins_2v2',
            'target'      => 10,
            'reward_dm'   => 800,
        ),
        8 => array(
            'key'         => 'gladiator_3v3',
            'label'       => 'Gladiador 3v3',
            'icon'        => '⚔️',
            'color'       => '#ffcc88',
            'description' => 'Gana 10 arenas 3v3.',
            'type'        => 'arena_wins_3v3',
            'target'      => 10,
            'reward_dm'   => 1200,
        ),
    );


    /* ============================================================
     *  HELPERS INTERNOS
     * ============================================================ */

    private static function db()
    {
        return Database::get();
    }

    private static function prefix()
    {
        return DB_PREFIX;
    }


    /* ============================================================
     *  OBTENER DATOS DE LOGROS DEL JUGADOR
     * ============================================================ */

    /**
     * Devuelve el array completo de logros del jugador listos para renderizar.
     */
    public static function getUserAchievements($userId)
    {
        $userId = (int) $userId;
        if ($userId <= 0) {
            return array(
                'stats'        => array(),
                'achievements' => array(),
                'unlocked'     => 0,
                'total'        => count(self::ACHIEVEMENTS),
            );
        }

        $stats = self::computeStats($userId);
        $unlockedRows = self::getUnlockedRows($userId);

        $achievements = array();
        $unlockedCount = 0;

        foreach (self::ACHIEVEMENTS as $id => $a) {
            $isUnlocked = isset($unlockedRows[$a['key']]);
            $unlockedAt = $isUnlocked ? (int) $unlockedRows[$a['key']] : 0;

            $progress = isset($stats[$a['type']]) ? (int) $stats[$a['type']] : 0;
            $pct = min(100, round(($progress / max(1, $a['target'])) * 100));

            if ($isUnlocked) {
                $unlockedCount++;
            }

            $achievements[] = array(
                'id'           => $id,
                'key'          => $a['key'],
                'label'        => $a['label'],
                'icon'         => $a['icon'],
                'color'        => $a['color'],
                'description'  => $a['description'],
                'target'       => (int) $a['target'],
                'reward_dm'    => (int) $a['reward_dm'],
                'progress'     => $progress,
                'progress_pct' => $pct,
                'unlocked'     => $isUnlocked ? 1 : 0,
                'unlocked_at'  => $unlockedAt,
                'unlocked_fmt' => $unlockedAt > 0 ? date('d/m/Y H:i', $unlockedAt) : '',
            );
        }

        return array(
            'stats'        => $stats,
            'achievements' => $achievements,
            'unlocked'     => $unlockedCount,
            'total'        => count(self::ACHIEVEMENTS),
        );
    }


    /**
     * Calcula las estadísticas del jugador que alimentan los logros.
     */
    public static function computeStats($userId)
    {
        $userId = (int) $userId;
        $p = self::prefix();
        $db = self::db();

        $stats = array(
            'tournaments_won'         => 0,
            'alliance_tournaments_won'=> 0,
            'alliance_streak'         => 0,
            'arena_wins_1v1'          => 0,
            'arena_wins_2v2'          => 0,
            'arena_wins_3v3'          => 0,
        );

        // Torneos 1v1 ganados (posición 1, tipo 1v1)
        try {
            $row = $db->selectSingle(
                "SELECT COUNT(*) AS c 
                 FROM %%PVP_TOURNAMENT_PLAYERS%% tp
                 INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
                 WHERE tp.`user_id` = :uid 
                   AND tp.`final_position` = 1 
                   AND t.`type` = '1v1'
                   AND t.`status` = 'finished';",
                array(':uid' => $userId)
            );
            $stats['tournaments_won'] = empty($row) ? 0 : (int) $row['c'];
        } catch (Exception $e) {}

        // Torneos de alianza ganados (posición 1, tipo alliance)
        try {
            $row = $db->selectSingle(
                "SELECT COUNT(*) AS c 
                 FROM %%PVP_TOURNAMENT_PLAYERS%% tp
                 INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
                 WHERE tp.`user_id` = :uid 
                   AND tp.`final_position` = 1 
                   AND t.`type` = 'alliance'
                   AND t.`status` = 'finished';",
                array(':uid' => $userId)
            );
            $stats['alliance_tournaments_won'] = empty($row) ? 0 : (int) $row['c'];
        } catch (Exception $e) {}

        // Racha de torneos de alianza consecutivos
        try {
            $rows = $db->select(
                "SELECT tp.`final_position`
                 FROM %%PVP_TOURNAMENT_PLAYERS%% tp
                 INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
                 WHERE tp.`user_id` = :uid 
                   AND t.`type` = 'alliance'
                   AND t.`status` = 'finished'
                 ORDER BY t.`finished_at` DESC
                 LIMIT 20;",
                array(':uid' => $userId)
            );
            $streak = 0;
            if (is_array($rows)) {
                foreach ($rows as $r) {
                    if ((int) $r['final_position'] === 1) {
                        $streak++;
                    } else {
                        break;
                    }
                }
            }
            $stats['alliance_streak'] = $streak;
        } catch (Exception $e) {}

        // Victorias en arenas por modalidad
        try {
            $rows = $db->select(
                "SELECT a.`mode`, COUNT(*) AS c
                 FROM %%PVP_ARENAS%% a
                 INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
                 WHERE ap.`user_id` = :uid 
                   AND a.`status` = 'finished'
                   AND ap.`team` = a.`winner_team`
                 GROUP BY a.`mode`;",
                array(':uid' => $userId)
            );
            if (is_array($rows)) {
                foreach ($rows as $r) {
                    $mode = $r['mode'];
                    $count = (int) $r['c'];
                    if ($mode === '1v1') $stats['arena_wins_1v1'] = $count;
                    if ($mode === '2v2') $stats['arena_wins_2v2'] = $count;
                    if ($mode === '3v3') $stats['arena_wins_3v3'] = $count;
                }
            }
        } catch (Exception $e) {}

        return $stats;
    }


    /**
     * Comprueba y desbloquea logros nuevos. Llamado desde claimPrize/finishTournament.
     *
     * @return array  Lista de logros desbloqueados
     */
    public static function checkAchievements($userId)
    {
        $userId = (int) $userId;
        if ($userId <= 0) return array();

        $stats = self::computeStats($userId);
        $unlockedRows = self::getUnlockedRows($userId);

        $newlyUnlocked = array();
        $now = TIMESTAMP;

        foreach (self::ACHIEVEMENTS as $id => $a) {
            if (isset($unlockedRows[$a['key']])) {
                continue; // ya desbloqueado
            }

            $progress = isset($stats[$a['type']]) ? (int) $stats[$a['type']] : 0;
            if ($progress < (int) $a['target']) {
                continue;
            }

            // Desbloquear
            try {
                self::db()->insert(
                    "INSERT INTO %%PVP_ACHIEVEMENTS%% SET
                        `user_id`      = :uid,
                        `achievement`  = :key,
                        `unlocked_at`  = :now;",
                    array(
                        ':uid' => $userId,
                        ':key' => $a['key'],
                        ':now' => $now,
                    )
                );

                // Entregar Materia Oscura directamente
                $rewardDm = (int) $a['reward_dm'];
                if ($rewardDm > 0) {
                    self::grantDarkMatter($userId, $rewardDm);
                }

                // Notificar
                self::sendAchievementNotification($userId, $a, $rewardDm);

                PVPHelper::log('system', 0, 'achievement_unlocked', $userId, array(
                    'key'       => $a['key'],
                    'label'     => $a['label'],
                    'reward_dm' => $rewardDm,
                ));

                $newlyUnlocked[] = $a;
            } catch (Exception $e) {
                // Silencioso
            }
        }

        return $newlyUnlocked;
    }


    /* ============================================================
     *  ENTREGA DE MATERIA OSCURA
     * ============================================================ */

    /**
     * Suma Materia Oscura al jugador directamente a uni1_users.darkmatter.
     * No usa PVPHelper::addNxt20() ni WalletHelper.
     *
     * @param int $userId
     * @param int $amount
     * @return bool
     */
    private static function grantDarkMatter($userId, $amount)
    {
        $userId = (int) $userId;
        $amount = (int) $amount;

        if ($userId <= 0 || $amount <= 0) return false;

        try {
            self::db()->update(
                "UPDATE %%USERS%% SET
                    darkmatter = darkmatter + :amt
                 WHERE id = :uid;",
                array(':amt' => $amount, ':uid' => $userId)
            );
            return true;
        } catch (Exception $e) {
            PVPHelper::log('system', 0, 'achievement_dm_error', $userId, array(
                'amount' => $amount,
                'error'  => $e->getMessage(),
            ));
            return false;
        }
    }


    /* ============================================================
     *  NOTIFICACIÓN AL JUGADOR
     * ============================================================ */

    /**
     * Envía la notificación interna del logro desbloqueado.
     * Muestra Materia Oscura con el icono 🌌.
     */
    private static function sendAchievementNotification($userId, array $a, $rewardDm)
    {
        try {
            $title = '¡Logro PvP desbloqueado! ' . $a['icon'] . ' ' . $a['label'];

            $body  = 'Has desbloqueado el logro <b>' . $a['label'] . '</b>.<br>';
            $body .= $a['description'] . '<br>';

            if ($rewardDm > 0) {
                $body .= 'Recompensa: <b>🌌 ' . number_format($rewardDm) . ' Materia Oscura</b><br>';
                $body .= 'La recompensa ya ha sido añadida a tu cuenta.<br>';
            }

            $body .= '<a href="game.php?page=pvp&mode=achievements">Ver logros</a>';

            PVPHelper::sendNotification($userId, $title, $body);

        } catch (Exception $e) {
            // Silencioso
        }
    }


    /* ============================================================
     *  CONSULTA DE LOGROS YA DESBLOQUEADOS
     * ============================================================ */

    /**
     * Devuelve las filas de logros ya desbloqueados.
     */
    private static function getUnlockedRows($userId)
    {
        $rows = self::db()->select(
            "SELECT `achievement`, `unlocked_at` 
             FROM %%PVP_ACHIEVEMENTS%% 
             WHERE `user_id` = :uid;",
            array(':uid' => (int) $userId)
        );

        $out = array();
        if (is_array($rows)) {
            foreach ($rows as $r) {
                $out[$r['achievement']] = (int) $r['unlocked_at'];
            }
        }
        return $out;
    }
}