<?php

/**
 * AstroIO — PVEBossTournamentHelper
 *
 * Sistema completo del TORNEO DEL DEVORADOR (World Boss por alianza):
 *   - 1 fantasma por alianza inscrita
 *   - 3 fases (Acecho / Enfurecido / Último Aliento)
 *   - Contraataques espaciados (cada ~4-5h)
 *   - Respawn con cooldown (5 min por defecto)
 *   - Modo free (premio fijo) o paid (pool acumulado - fee %)
 *   - Ranking en vivo por % de HP bajado acumulado
 *   - Notificaciones con coordenadas a toda la alianza
 *
 * v1.1 — AUTO-PROGRAMACIÓN MENSUAL
 * v1.2 — CHECKBOX REACTIVO (forceAutoScheduleNow / cancelScheduledEvents)
 * v1.3 — FIX LÍDER REAL (ally_owner en canRegister)
 * v1.4 — FIX "Undefined array key ally_tag" al spawnear fantasmas
 * v1.5 — LIMPIEZA AUTOMÁTICA (3 capas, igual que Crisis)
 * v1.6 — INTEGRACIÓN CON LOGROS
 * v1.7 — SOPORTE PARA PREMIOS MIXTOS (Múltiples recursos a la vez)
 *
 * v1.8 — DOBLE RIEL (NTX-20 / UNTX-20) — Modelo A1 (pools separados)
 *   · Pools separados: `pool_ntx20` (CUP) + `pool_untx20` (QVAPAY).
 *     Requiere ALTER TABLE en `uni1_pve_boss_event`:
 *       ALTER TABLE uni1_pve_boss_event
 *         ADD COLUMN pool_ntx20  BIGINT(20) NOT NULL DEFAULT 0,
 *         ADD COLUMN pool_untx20 BIGINT(20) NOT NULL DEFAULT 0;
 *       UPDATE uni1_pve_boss_event SET pool_ntx20 = total_pool_ntx
 *         WHERE pool_ntx20 = 0 AND total_pool_ntx > 0;
 *   · `registerAlliance()`: cobra en el riel del líder. CUP ? ntx20,
 *     QVAPAY ? untx20 ×2. Suma al pool del riel correspondiente.
 *   · `cancelEvent()`: refund por riel del líder.
 *   · `calculatePrize()` (paid): devuelve pools separados con fee por riel.
 *   · `distributePrize()`: reparte CADA pool entre los contribuyentes del
 *     mismo riel (regla de oro). Sin acuñar.
 *   · `grantPrizeToUser()`: sigue insertando en `pve_rewards.reward_type='ntx'`
 *     con el monto en BASE. El ×2 para QVAPAY se aplica al reclamar en
 *     `PVEHelper::claimAllRewards()` v2.0.
 *   · Log NTX20LogHelper NO se usa aquí (no hay hook directo); la
 *     auditoría la hace `PVEHelper::log()` con `event_type='boss'`.
 *   · `describePrize()` / `formatPrize()`: muestran pools duales.
 *   · `$event['entry_cost_ntx']` y `$event['prize_ntx']` siguen siendo
 *     BASE NTX-20 (compatibilidad). El ×2 se aplica al cobrar/entregar.
 *   · `total_pool_ntx` se mantiene actualizado como "suma de base
 *     equivalente" (para display legacy del admin). Los pools reales
 *     son `pool_ntx20` y `pool_untx20`.
 *   · ?? Edge case (migración en caliente): si un evento tiene
 *     registros previos pagados en NTX y el líder es QVAPAY, el refund
 *     aplicará ×2 sobre `paid_ntx`. Recomendado cancelar eventos
 *     abiertos antes de aplicar el ALTER.
 *
 * Reutiliza: PVEGhostHelper, PveFleetHelper, PVEHelper, PVEAchievementHelper.
 *
 * Ubicación: includes/classes/PVEBossTournamentHelper.class.php
 * @package AstroIO
 * @subpackage PvE
 * @version 1.8
 */

if (!defined('ROOT_PATH')) {
    exit('Access denied');
}

// -------------------------------------------------------------------
// DEPENDENCIAS (evita Class not found)
// -------------------------------------------------------------------
if (!class_exists('PVEHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVEGhostHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';
}
if (!class_exists('PveFleetHelper')) {
    require_once ROOT_PATH.'includes/classes/PveFleetHelper.class.php';
}
if (!class_exists('PVEAchievementHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEAchievementHelper.class.php';
}

class PVEBossTournamentHelper
{
    /** Offset para fleet_start_id de las flotas del boss */
    const BOSS_ID_OFFSET = 2000000000;

    /** Tipos de evento permitidos en uni1_pve_log */
    const LOG_TYPE = 'boss';

    /** Regla ×2 centralizada */
    const UNTX_MULTIPLIER = 2;


    /* ============================================================
     *  ?? v1.8 — HELPERS DE DOBLE RIEL
     * ============================================================ */

    /**
     * Devuelve el riel del jugador ('CUP' | 'QVAPAY').
     * Fail-safe a 'CUP' si PVEHelper no existe o falla.
     */
    private static function getRiel(int $userId): string
    {
        if ($userId <= 0) return 'CUP';
        if (class_exists('PVEHelper') && method_exists('PVEHelper', 'getPlayerMethod')) {
            try {
                return PVEHelper::getPlayerMethod($userId);
            } catch (Throwable $e) {}
        }
        return 'CUP';
    }

    /**
     * Etiqueta visible de la moneda del jugador.
     */
    private static function getMoneda(int $userId): string
    {
        return self::getRiel($userId) === 'QVAPAY' ? 'UNTX-20' : 'NTX-20';
    }

    /**
     * Columna física donde vive el saldo del jugador.
     */
    private static function getPhysicalColumn(int $userId): string
    {
        return self::getRiel($userId) === 'QVAPAY' ? 'untx20' : 'ntx20';
    }

    /**
     * Resta un monto BASE del saldo del jugador en su riel.
     * CUP ? -base de `ntx20`. QVAPAY ? -(base×2) de `untx20`.
     * Refresca $GLOBALS['USER'][col] si aplica.
     */
    private static function subtractBalance(int $userId, int $baseAmount, string $source, string $reason): bool
    {
        if ($userId <= 0 || $baseAmount <= 0) return false;

        $riel = self::getRiel($userId);
        $col  = ($riel === 'QVAPAY') ? 'untx20' : 'ntx20';
        $realAmount = ($riel === 'QVAPAY') ? ($baseAmount * self::UNTX_MULTIPLIER) : $baseAmount;

        $db = Database::get();

        try {
            $current = (int) $db->selectSingle(
                "SELECT `{$col}` AS balance FROM %%USERS%% WHERE id = :uid LIMIT 1;",
                array(':uid' => $userId),
                'balance'
            );

            if ($current < $realAmount) return false;

            $db->update(
                "UPDATE %%USERS%% SET `{$col}` = `{$col}` - :amt WHERE id = :uid AND `{$col}` >= :amt2;",
                array(':amt' => $realAmount, ':uid' => $userId, ':amt2' => $realAmount)
            );

            // [v3.8] rowCount: el guard SQL (`>= :amt2`) puede dejar el UPDATE
            // en 0 filas si otro request concurrente ya gasto el saldo. Antes
            // se devolvia true igualmente -> inscripcion sin pago efectivo.
            if ($db->rowCount() !== 1) return false;

            if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER'][$col] = max(0, (int)($GLOBALS['USER'][$col] ?? 0) - $realAmount);
            }

            return true;
        } catch (Throwable $e) {
            return false;
        }
    }

    /**
     * Suma un monto REAL al saldo del jugador en el riel indicado.
     */
    private static function addRealAmount(int $userId, int $realAmount, string $riel, string $source, string $reason): bool
    {
        if ($userId <= 0 || $realAmount <= 0) return false;

        $col = ($riel === 'QVAPAY') ? 'untx20' : 'ntx20';

        $db = Database::get();

        try {
            $db->update(
                "UPDATE %%USERS%% SET `{$col}` = `{$col}` + :amt WHERE id = :uid;",
                array(':amt' => $realAmount, ':uid' => $userId)
            );

            if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER'][$col] = (int)($GLOBALS['USER'][$col] ?? 0) + $realAmount;
            }

            return true;
        } catch (Throwable $e) {
            return false;
        }
    }


    /* ============================================================
     *  v1.6 — LOGROS: helpers internos seguros
     * ============================================================ */

    private static function safeRecordBossKill(int $userId, int $kills = 1): void
    {
        if ($userId <= 0 || !class_exists('PVEAchievementHelper')) return;
        try {
            PVEAchievementHelper::recordBossKill($userId, $kills);
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'achievement_kill_error', $userId, 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }

    private static function safeRecordBossDamage(int $userId, $damage): void
    {
        if ($userId <= 0 || $damage <= 0 || !class_exists('PVEAchievementHelper')) return;
        try {
            PVEAchievementHelper::recordBossDamage($userId, $damage);
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'achievement_damage_error', $userId, 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }

    private static function safeRecordTournamentWin(int $userId): void
    {
        if ($userId <= 0 || !class_exists('PVEAchievementHelper')) return;
        try {
            PVEAchievementHelper::recordTournamentWin($userId);
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'achievement_win_error', $userId, 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }

    // ---------------------------------------------------------------
    //  1. CONFIGURACIÓN / ESTADO
    // ---------------------------------------------------------------

    public static function isEnabled(): bool
    {
        return (int) PVEHelper::get('pve_boss_enabled', 0) === 1;
    }

    public static function getEventState(): array
    {
        $state = array(
            'enabled'          => self::isEnabled() ? 1 : 0,
            'active'           => 0,
            'status'           => 'idle',
            'event_id'         => 0,
            'next_time'        => 0,
            'end_time'         => 0,
            'registration_end' => 0,
            'has_event'        => 0,
        );

        if (!$state['enabled']) {
            return $state;
        }

        $event = self::getActiveEvent();
        if (empty($event)) return $state;

        $state['has_event']        = 1;
        $state['event_id']         = (int) $event['id'];
        $state['status']           = (string) $event['status'];
        $state['registration_end'] = (int) $event['registration_end'];

        if ($event['status'] === 'active') {
            $state['active']    = 1;
            $state['next_time'] = (int) $event['start_time'];
            $state['end_time']  = (int) $event['end_time'];
        } elseif ($event['status'] === 'registration') {
            $state['next_time'] = (int) $event['registration_start'];
            $state['end_time']  = (int) $event['registration_end'];
        } elseif ($event['status'] === 'scheduled') {
            $state['next_time'] = (int) $event['registration_start'];
        }

        return $state;
    }

    public static function getActiveEvent(): ?array
    {
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT * FROM %%PVE_BOSS_EVENT%%
             WHERE status IN ('scheduled','registration','active')
             ORDER BY id DESC LIMIT 1;"
        );
        return !empty($row) ? $row : null;
    }

    public static function getEvent(int $eventId): ?array
    {
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT * FROM %%PVE_BOSS_EVENT%% WHERE id = :id LIMIT 1;",
            array(':id' => $eventId)
        );
        return !empty($row) ? $row : null;
    }

    public static function getEventStats(int $eventId): array
    {
        $db = Database::get();
        $stats = array('ghosts_alive' => 0, 'ghosts_total' => 0, 'ghosts_killed' => 0, 'allies_active' => 0);

        try {
            $row = $db->selectSingle(
                "SELECT 
                    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS alive,
                    COUNT(*) AS total,
                    SUM(CASE WHEN status = 'killed' THEN 1 ELSE 0 END) AS killed
                 FROM %%PVE_BOSS_GHOSTS%% WHERE event_id = :eid;",
                array(':eid' => $eventId)
            );
            if (!empty($row)) {
                $stats['ghosts_alive']  = (int) $row['alive'];
                $stats['ghosts_total']  = (int) $row['total'];
                $stats['ghosts_killed'] = (int) $row['killed'];
            }
            $row2 = $db->selectSingle(
                "SELECT COUNT(*) AS c FROM %%PVE_BOSS_REGISTRATIONS%%
                 WHERE event_id = :eid AND status IN ('active','registered');",
                array(':eid' => $eventId)
            );
            if (!empty($row2)) $stats['allies_active'] = (int) $row2['c'];
        } catch (Throwable $e) {}

        return $stats;
    }

    // ---------------------------------------------------------------
    //  2. CICLO DE VIDA DEL EVENTO
    // ---------------------------------------------------------------

    /**
     * Crea un nuevo evento del torneo (status = scheduled).
     *
     * v1.8 — Añade `pool_ntx20 = 0` y `pool_untx20 = 0`.
     */
    public static function createEvent(array $params): array
    {
        $db = Database::get();

        $existing = self::getActiveEvent();
        if (!empty($existing)) {
            return array('ok' => false, 'error' => 'Ya hay un torneo activo (ID #' . $existing['id'] . ').');
        }

        $bossName         = !empty($params['boss_name']) ? substr((string) $params['boss_name'], 0, 64) : 'El Devorador Estelar';
        $entryMode        = ($params['entry_mode'] ?? 'free') === 'paid' ? 'paid' : 'free';
        $entryCostNtx     = max(0, (int) ($params['entry_cost_ntx'] ?? 50));
        $prizeType        = in_array($params['prize_type'] ?? 'ntx', array('metal','crystal','deuterium','dark_matter','ntx','mixed'), true)
                            ? $params['prize_type'] : 'ntx';
        $prizeMetal       = max(0, (int) ($params['prize_metal'] ?? 0));
        $prizeCrystal     = max(0, (int) ($params['prize_crystal'] ?? 0));
        $prizeDeuterium   = max(0, (int) ($params['prize_deuterium'] ?? 0));
        $prizeDarkMatter  = max(0, (int) ($params['prize_dark_matter'] ?? 0));
        $prizeNtx         = max(0, (int) ($params['prize_ntx'] ?? 500));
        $prizeScales      = !empty($params['prize_scales_with_allies']) ? 1 : 0;
        $feePct           = max(0, min(100, (int) ($params['project_fee_pct'] ?? 5)));
        $distribution     = in_array($params['winner_distribution'] ?? 'by_contribution',
                            array('leader','by_contribution','equal'), true)
                            ? $params['winner_distribution'] : 'by_contribution';
        $minAlliances     = max(1, min(50, (int) ($params['min_alliances'] ?? 2)));
        $maxAlliances     = max($minAlliances, min(100, (int) ($params['max_alliances'] ?? 20)));
        $hpPerMember      = max(1000, (int) ($params['hp_per_member'] ?? 500000));
        $hpMin            = max(100000, (int) ($params['hp_min'] ?? 10000000));
        $durationHours    = max(1, min(168, (int) ($params['duration_hours'] ?? 48)));
        $registrationHrs  = max(1, min(168, (int) ($params['registration_hours'] ?? 24)));
        $scheduleStart    = max(0, (int) ($params['schedule_start_time'] ?? 0));

        if ($scheduleStart > 0) {
            $startTime         = $scheduleStart;
            $registrationEnd   = $scheduleStart;
            $registrationStart = max(0, $scheduleStart - ($registrationHrs * 3600));
            $endTime           = $startTime + ($durationHours * 3600);
        } else {
            $now               = TIMESTAMP;
            $registrationStart = $now;
            $registrationEnd   = $now + ($registrationHrs * 3600);
            $startTime         = $registrationEnd;
            $endTime           = $startTime + ($durationHours * 3600);
        }

        $now = TIMESTAMP;

        try {
            $db->insert(
                "INSERT INTO %%PVE_BOSS_EVENT%% SET
                    boss_name              = :bossName,
                    entry_mode             = :entryMode,
                    entry_cost_ntx         = :entryCostNtx,
                    prize_type             = :prizeType,
                    prize_metal            = :prizeMetal,
                    prize_crystal          = :prizeCrystal,
                    prize_deuterium        = :prizeDeuterium,
                    prize_dark_matter      = :prizeDarkMatter,
                    prize_ntx              = :prizeNtx,
                    prize_scales_with_allies = :prizeScales,
                    project_fee_pct        = :feePct,
                    winner_distribution    = :distribution,
                    min_alliances          = :minAlliances,
                    max_alliances          = :maxAlliances,
                    hp_per_member          = :hpPerMember,
                    hp_min                 = :hpMin,
                    duration_hours         = :durationHours,
                    total_pool_ntx         = 0,
                    pool_ntx20             = 0,
                    pool_untx20            = 0,
                    status                 = 'scheduled',
                    created_by             = :createdBy,
                    created_at             = :now,
                    registration_start     = :regStart,
                    registration_end       = :regEnd,
                    start_time             = :startTime,
                    end_time               = :endTime,
                    counter_enabled        = 1;",
                array(
                    ':bossName'      => $bossName,
                    ':entryMode'     => $entryMode,
                    ':entryCostNtx'  => $entryCostNtx,
                    ':prizeType'     => $prizeType,
                    ':prizeMetal'    => $prizeMetal,
                    ':prizeCrystal'  => $prizeCrystal,
                    ':prizeDeuterium'=> $prizeDeuterium,
                    ':prizeDarkMatter'=> $prizeDarkMatter,
                    ':prizeNtx'      => $prizeNtx,
                    ':prizeScales'   => $prizeScales,
                    ':feePct'        => $feePct,
                    ':distribution'  => $distribution,
                    ':minAlliances'  => $minAlliances,
                    ':maxAlliances'  => $maxAlliances,
                    ':hpPerMember'   => $hpPerMember,
                    ':hpMin'         => $hpMin,
                    ':durationHours' => $durationHours,
                    ':createdBy'     => 0,
                    ':now'           => $now,
                    ':regStart'      => $registrationStart,
                    ':regEnd'        => $registrationEnd,
                    ':startTime'     => $startTime,
                    ':endTime'       => $endTime,
                )
            );

            $eventId = (int) $db->lastInsertId();

            PVEHelper::log(self::LOG_TYPE, $eventId, 'event_created', 0, 0, array(
                'entry_mode'    => $entryMode,
                'cost_base_ntx' => $entryCostNtx,
                'prize_type'    => $prizeType,
                'scheduled'     => $scheduleStart > 0 ? 1 : 0,
                'start_time'    => $startTime,
                'reg_start'     => $registrationStart,
                'reg_end'       => $registrationEnd,
                'end_time'      => $endTime,
            ));

            return array('ok' => true, 'event_id' => $eventId);
        } catch (Throwable $e) {
            return array('ok' => false, 'error' => $e->getMessage());
        }
    }

    public static function openRegistration(int $eventId): bool
    {
        $db = Database::get();
        $event = self::getEvent($eventId);
        if (empty($event) || $event['status'] !== 'scheduled') return false;

        $db->update(
            "UPDATE %%PVE_BOSS_EVENT%% SET status = 'registration' WHERE id = :id;",
            array(':id' => $eventId)
        );

        PVEHelper::log(self::LOG_TYPE, $eventId, 'registration_opened', 0, 0, null);
        self::notifyAllianceLeaders($eventId, $event);

        return true;
    }

    public static function startEvent(int $eventId): array
    {
        $db = Database::get();
        $event = self::getEvent($eventId);
        if (empty($event) || $event['status'] !== 'registration') {
            return array('ok' => false, 'error' => 'El evento no está en fase de registro.');
        }

        $regs = $db->select(
            "SELECT r.*, a.ally_name, a.ally_tag
             FROM %%PVE_BOSS_REGISTRATIONS%% r
             LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
             WHERE r.event_id = :eid AND r.status = 'registered'
             ORDER BY r.id ASC;",
            array(':eid' => $eventId)
        );

        if (!is_array($regs) || count($regs) === 0) {
            self::cancelEvent($eventId, 'no_alliances', true);
            return array('ok' => false, 'error' => 'No hay alianzas inscritas. Evento cancelado.');
        }

        $minAlliances = (int) $event['min_alliances'];
        if (count($regs) < $minAlliances) {
            self::cancelEvent($eventId, 'min_alliances_not_reached', true);
            return array('ok' => false, 'error' => 'No se alcanzó el mínimo de ' . $minAlliances . ' alianzas. Evento cancelado.');
        }

        $now     = TIMESTAMP;
        $endTime = $now + ((int) $event['duration_hours'] * 3600);

        $db->update(
            "UPDATE %%PVE_BOSS_EVENT%% SET
                status     = 'active',
                start_time = :now,
                end_time   = :endTime
             WHERE id = :id;",
            array(':now' => $now, ':endTime' => $endTime, ':id' => $eventId)
        );

        $spawned = 0;
        foreach ($regs as $reg) {
            $result = self::spawnGhostForRegistration($event, $reg, 1);
            if (!empty($result)) $spawned++;
        }

        $db->update(
            "UPDATE %%PVE_BOSS_EVENT%% SET total_ghosts_spawned = :c WHERE id = :id;",
            array(':c' => $spawned, ':id' => $eventId)
        );

        PVEHelper::log(self::LOG_TYPE, $eventId, 'event_started', 0, 0, array(
            'spawned' => $spawned,
            'allies'  => count($regs),
        ));

        self::announceGlobalSpawn($eventId, $spawned);

        return array('ok' => true, 'spawned' => $spawned);
    }

    /**
     * Finaliza el evento (por tiempo o por admin) y reparte premios.
     *
     * v1.8 — El reparto delega en `calculatePrize()` y `distributePrize()`
     * que manejan pools duales (ntx20/untx20).
     */
    public static function finishEvent(int $eventId, string $reason = 'time'): array
    {
        $db = Database::get();
        $event = self::getEvent($eventId);
        if (empty($event) || $event['status'] !== 'active') {
            return array('ok' => false, 'error' => 'El evento no está activo.');
        }

        $now = TIMESTAMP;

        $winner = $db->selectSingle(
            "SELECT * FROM %%PVE_BOSS_REGISTRATIONS%%
             WHERE event_id = :eid AND status IN ('registered','active')
             ORDER BY pct_damage_total DESC, total_damage DESC
             LIMIT 1;",
            array(':eid' => $eventId)
        );

        if (empty($winner)) {
            self::cancelEvent($eventId, 'no_participants', true);
            return array('ok' => false, 'error' => 'Nadie participó.');
        }

        $activeGhost = $db->selectSingle(
            "SELECT * FROM %%PVE_BOSS_GHOSTS%%
             WHERE registration_id = :rid AND status = 'active' LIMIT 1;",
            array(':rid' => (int) $winner['id'])
        );

        $extraPct = 0;
        if (!empty($activeGhost) && (int) $activeGhost['hp_max'] > 0) {
            $extraPct = round((1 - ($activeGhost['hp_current'] / $activeGhost['hp_max'])) * 100, 2);
        }

        $winnerPctTotal = (float) $winner['pct_damage_total'] + $extraPct;

        // [v3.8] UPDATE condicional + rowCount: solo el proceso que realmente
        // cambia el estado reparte el premio. Antes dos llamadas concurrentes
        // (cron + admin) pasaban ambas el check de estado y ejecutaban
        // distributePrize() dos veces -> premios duplicados.
        $db->update(
            "UPDATE %%PVE_BOSS_EVENT%% SET
                status                  = 'finished',
                finished_at             = :now,
                winner_registration_id  = :wrid,
                winner_ally_id          = :waid,
                winner_damage           = :wdmg,
                winner_pct              = :wpct
             WHERE id = :id AND status = 'active';",
            array(
                ':now'  => $now,
                ':wrid' => (int) $winner['id'],
                ':waid' => (int) $winner['ally_id'],
                ':wdmg' => (int) $winner['total_damage'],
                ':wpct' => $winnerPctTotal,
                ':id'   => $eventId,
            )
        );

        if ($db->rowCount() !== 1) {
            return array('ok' => false, 'error' => 'El evento ya fue finalizado por otro proceso.');
        }

        $db->update(
            "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET pct_damage_total = :pct WHERE id = :id;",
            array(':pct' => $winnerPctTotal, ':id' => (int) $winner['id'])
        );

        $db->update(
            "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET status = 'lost'
             WHERE event_id = :eid AND id != :wid AND status IN ('registered','active');",
            array(':eid' => $eventId, ':wid' => (int) $winner['id'])
        );

        $db->update(
            "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET status = 'winner' WHERE id = :id;",
            array(':id' => (int) $winner['id'])
        );

        $prize = self::calculatePrize($event, $winner);
        self::distributePrize($eventId, $winner, $prize);
        self::destroyAllGhosts($eventId);
        self::notifyEventFinished($eventId, $event, $winner, $prize);

        try {
            $winnerMembers = $db->select(
                "SELECT id FROM %%USERS%%
                 WHERE ally_id = :aid AND bana = 0 AND universe = :uni;",
                array(':aid' => (int) $winner['ally_id'], ':uni' => PVEHelper::getUniverseForAlly((int) $winner['ally_id']))
            );
            if (is_array($winnerMembers)) {
                foreach ($winnerMembers as $m) {
                    self::safeRecordTournamentWin((int) $m['id']);
                }
            }
        } catch (Throwable $e) {}

        PVEHelper::log(self::LOG_TYPE, $eventId, 'event_finished', 0, 0, array(
            'reason'      => $reason,
            'winner_ally' => (int) $winner['ally_id'],
            'winner_pct'  => $winnerPctTotal,
            'prize_type'  => $prize['type'],
            'prize_net'   => $prize['net'],
            'prize_fee'   => $prize['fee'],
        ));

        self::cleanup($eventId);

        return array(
            'ok'             => true,
            'winner_ally_id' => (int) $winner['ally_id'],
            'winner_pct'     => $winnerPctTotal,
            'prize'          => $prize,
        );
    }

    /**
     * Cancela el evento y (opcionalmente) devuelve el saldo a cada líder
     * en SU RIEL.
     */
    public static function cancelEvent(int $eventId, string $reason = '', bool $refund = true): array
    {
        $db = Database::get();
        $event = self::getEvent($eventId);
        if (empty($event)) {
            return array('ok' => false, 'error' => 'Evento no encontrado.');
        }
        if ($event['status'] === 'finished' || $event['status'] === 'cancelled') {
            return array('ok' => false, 'error' => 'El evento ya está cerrado.');
        }

        $now = TIMESTAMP;

        $db->update(
            "UPDATE %%PVE_BOSS_EVENT%% SET
                status        = 'cancelled',
                cancelled_at  = :now,
                cancel_reason = :reason
             WHERE id = :id;",
            array(':now' => $now, ':reason' => substr($reason, 0, 255), ':id' => $eventId)
        );

        $refundedCount = 0;
        if ($refund && $event['entry_mode'] === 'paid' && (int) $event['entry_cost_ntx'] > 0) {
            // [v3.8] Incluir 'active': startEvent() marca las registraciones
            // como 'active' al spawnear; antes un evento pagado cancelado tras
            // arrancar excluya a esas alianzas del reembolso (dinero perdido).
            $regs = $db->select(
                "SELECT * FROM %%PVE_BOSS_REGISTRATIONS%%
                 WHERE event_id = :eid AND status IN ('registered','active') AND paid_ntx > 0;",
                array(':eid' => $eventId)
            );

            $refundedIds = array();
            if (is_array($regs)) {
                foreach ($regs as $reg) {
                    $uid        = (int) $reg['registered_by'];
                    $baseAmount = (int) $reg['paid_ntx'];
                    if ($uid <= 0 || $baseAmount <= 0) continue;

                    $riel       = self::getRiel($uid);
                    $realAmount = ($riel === 'QVAPAY') ? ($baseAmount * self::UNTX_MULTIPLIER) : $baseAmount;

                    if (self::addRealAmount($uid, $realAmount, $riel, 'pve_boss_refund',
                        'Reembolso Torneo Devorador #' . $eventId)) {
                        $refundedCount++;
                        $refundedIds[] = (int) $reg['id'];
                    }
                }
            }

            // [v3.8] Solo marcar 'refunded' las que SE reembolsaron de verdad.
            // Antes el UPDATE era incondicional: si addRealAmount fallaba, el
            // lider no cobraba pero su registro quedaba 'refunded' -> imposible
            // reintentar.
            if (!empty($refundedIds)) {
                $db->update(
                    "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET
                        status       = 'refunded',
                        refunded_at  = :now
                     WHERE id IN (" . implode(',', $refundedIds) . ");",
                    array(':now' => $now)
                );
            }
        }

        self::destroyAllGhosts($eventId);
        self::notifyEventCancelled($eventId, $event, $reason, $refundedCount);

        PVEHelper::log(self::LOG_TYPE, $eventId, 'event_cancelled', 0, 0, array(
            'reason'   => $reason,
            'refunded' => $refundedCount,
        ));

        return array('ok' => true, 'refunded' => $refundedCount);
    }

    // ---------------------------------------------------------------
    //  3. INSCRIPCIÓN DE ALIANZAS
    // ---------------------------------------------------------------

    public static function canRegister(int $allyId, int $allyRank, int $userId = 0): bool
    {
        if ($allyId <= 0) return false;

        if ($userId > 0) {
            $db = Database::get();
            $leader = $db->selectSingle(
                "SELECT ally_owner FROM %%ALLIANCE%% WHERE id = :aid LIMIT 1;",
                array(':aid' => $allyId)
            );
            $leaderId = !empty($leader) ? (int) $leader['ally_owner'] : 0;
            if ($leaderId !== $userId) return false;
        } else {
            if ($allyRank < 0) return false;
        }

        $event = self::getActiveEvent();
        if (empty($event) || $event['status'] !== 'registration') return false;

        $existing = self::getRegistration((int) $event['id'], $allyId);
        if (!empty($existing)) return false;

        $db = Database::get();
        $count = (int) $db->selectSingle(
            "SELECT COUNT(*) AS c FROM %%PVE_BOSS_REGISTRATIONS%%
             WHERE event_id = :eid AND status = 'registered';",
            array(':eid' => (int) $event['id']), 'c'
        );

        $max = (int) $event['max_alliances'];
        if ($count >= $max) return false;

        return true;
    }

    /**
     * Inscribe una alianza (paga en el RIEL del líder si entry_mode=paid).
     *
     * v1.8 — Doble riel:
     *   - CUP    ? cobra `entry_cost_ntx` de `ntx20`, suma a `pool_ntx20`
     *   - QVAPAY ? cobra `entry_cost_ntx × 2` de `untx20`, suma a `pool_untx20`
     *   - `paid_ntx` guarda el monto BASE (para compatibilidad con refund)
     */
    public static function registerAlliance(int $allyId, int $userId, int $allyRank): array
    {
        if (!self::canRegister($allyId, $allyRank, $userId)) {
            return array('ok' => false, 'error' => 'No puedes inscribir tu alianza ahora mismo.');
        }

        $db    = Database::get();
        $event = self::getActiveEvent();

        $leader = $db->selectSingle(
            "SELECT ally_owner FROM %%ALLIANCE%% WHERE id = :aid LIMIT 1;",
            array(':aid' => $allyId)
        );

        $leaderId = !empty($leader) ? (int) $leader['ally_owner'] : 0;
        if ($leaderId !== $userId) {
            return array(
                'ok'    => false,
                'error' => 'Solo el líder de la alianza puede inscribirla en el torneo.',
            );
        }

        $now      = TIMESTAMP;
        $paidNtx  = 0;
        $paidAt   = null;
        $realPaid = 0;
        $riel     = 'CUP';
        $moneda   = 'NTX-20';

        if ($event['entry_mode'] === 'paid' && (int) $event['entry_cost_ntx'] > 0) {
            $costBase = (int) $event['entry_cost_ntx'];
            $riel     = self::getRiel($userId);
            $moneda   = self::getMoneda($userId);
            $realPaid = ($riel === 'QVAPAY') ? ($costBase * self::UNTX_MULTIPLIER) : $costBase;

            $ok = self::subtractBalance($userId, $costBase, 'pve_boss_entry',
                'Inscripción Torneo Devorador #' . $event['id']);

            if (!$ok) {
                return array('ok' => false, 'error' => 'No tienes suficientes ' . $moneda . ' (' . $realPaid . ' necesarios).');
            }

            // Guardamos BASE en `paid_ntx` (refund posterior convierte si es QVAPAY)
            $paidNtx = $costBase;
            $paidAt  = $now;

            // Actualizamos el pool del riel + total_pool_ntx legacy (suma base)
            $col = ($riel === 'QVAPAY') ? 'pool_untx20' : 'pool_ntx20';
            $db->update(
                "UPDATE %%PVE_BOSS_EVENT%% SET
                    `{$col}`       = `{$col}` + :real,
                    total_pool_ntx = total_pool_ntx + :base
                 WHERE id = :id;",
                array(
                    ':real' => $realPaid,
                    ':base' => $costBase,
                    ':id'   => (int) $event['id'],
                )
            );
        }

        $membersActive = self::countActiveMembers($allyId, 24);

        try {
            $db->insert(
                "INSERT INTO %%PVE_BOSS_REGISTRATIONS%% SET
                    event_id         = :eid,
                    ally_id          = :allyId,
                    registered_by    = :userId,
                    registered_at    = :now,
                    paid_ntx         = :paidNtx,
                    paid_at          = :paidAt,
                    members_at_spawn = :members,
                    status           = 'registered';",
                array(
                    ':eid'      => (int) $event['id'],
                    ':allyId'   => $allyId,
                    ':userId'   => $userId,
                    ':now'      => $now,
                    ':paidNtx'  => $paidNtx,
                    ':paidAt'   => $paidAt,
                    ':members'  => $membersActive,
                )
            );

            $regId = (int) $db->lastInsertId();

            PVEHelper::log(self::LOG_TYPE, (int) $event['id'], 'ally_registered', $userId, 0, array(
                'ally_id'   => $allyId,
                'reg_id'    => $regId,
                'paid_base' => $paidNtx,
                'paid_real' => $realPaid,
                'riel'      => $riel,
                'moneda'    => $moneda,
            ));

            return array(
                'ok'      => true,
                'message' => 'Alianza inscrita en el torneo.'
                    . ($realPaid > 0 ? ' Se han descontado ' . $realPaid . ' ' . $moneda . '.' : ''),
            );
        } catch (Throwable $e) {
            return array('ok' => false, 'error' => $e->getMessage());
        }
    }

    public static function getRegistration(int $eventId, int $allyId): ?array
    {
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT r.*, a.ally_name, a.ally_tag
             FROM %%PVE_BOSS_REGISTRATIONS%% r
             LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
             WHERE r.event_id = :eid AND r.ally_id = :aid LIMIT 1;",
            array(':eid' => $eventId, ':aid' => $allyId)
        );
        return !empty($row) ? $row : null;
    }

    public static function getRegistrationById(int $registrationId): ?array
    {
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT r.*, a.ally_name, a.ally_tag
             FROM %%PVE_BOSS_REGISTRATIONS%% r
             LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
             WHERE r.id = :id LIMIT 1;",
            array(':id' => $registrationId)
        );
        return !empty($row) ? $row : null;
    }

    public static function getRegistrationByGhost(int $ghostUserId): ?array
    {
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT r.*, g.id AS ghost_id, g.event_id AS ghost_event_id, g.status AS ghost_status
             FROM %%PVE_BOSS_GHOSTS%% g
             INNER JOIN %%PVE_BOSS_REGISTRATIONS%% r ON r.id = g.registration_id
             WHERE g.ghost_user_id = :uid AND g.status = 'active'
             LIMIT 1;",
            array(':uid' => $ghostUserId)
        );
        return !empty($row) ? $row : null;
    }


    /* --------------------------------------------------------------
     *  FIN DE LA PARTE 1 — continúa en la PARTE 2 con las secciones:
     *    4. Fantasmas
     *    5. Combate (daño y fases)
     *    6. Contraataques
     *    7. Ranking / Consultas
     *    8. Premios y reparto (dual-riel A1)
     *    9. Notificaciones
     *    10. Cron
     *    11. Utilidades
     *    12. Limpieza automática
     *    13. Auto-programación mensual
     *    } ? cierre de clase
     * -------------------------------------------------------------- */
	 
	     // ---------------------------------------------------------------
    //  4. FANTASMAS
    // ---------------------------------------------------------------

    public static function getActiveGhostForRegistration(int $registrationId): ?array
    {
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT * FROM %%PVE_BOSS_GHOSTS%%
             WHERE registration_id = :rid AND status = 'active'
             ORDER BY id DESC LIMIT 1;",
            array(':rid' => $registrationId)
        );
        return !empty($row) ? $row : null;
    }

    private static function spawnGhostForRegistration(array $event, array $registration, int $spawnNumber): ?array
    {
        $db = Database::get();

        $eventId        = (int) $event['id'];
        $registrationId = (int) $registration['id'];
        $allyId         = (int) $registration['ally_id'];

        $allyTag  = !empty($registration['ally_tag'])  ? (string) $registration['ally_tag']  : ('A' . $allyId);
        $allyName = !empty($registration['ally_name']) ? (string) $registration['ally_name'] : ('Alliance #' . $allyId);

        $membersActive = self::countActiveMembers($allyId, 24);
        $hpMax = max((int) $event['hp_min'], $membersActive * (int) $event['hp_per_member']);

        $coords = self::findEmptyCoordinatesForEvent($eventId);
        if (empty($coords)) {
            PVEHelper::log(self::LOG_TYPE, $eventId, 'spawn_failed_no_coords', 0, 0, array(
                'registration_id' => $registrationId,
            ));
            return null;
        }

        $shipsJson    = self::getDefaultShipsJson();
        $defensesJson = self::getDefaultDefensesJson();

        try {
            $ghost = PVEGhostHelper::createGhostForBoss($eventId, $registrationId, array(
                'name'      => $event['boss_name'] . ' [' . $allyTag . ']',
                'galaxy'    => $coords['galaxy'],
                'system'    => $coords['system'],
                'planet'    => $coords['planet'],
                'hp'        => $hpMax,
                'metal'     => 0,
                'crystal'   => 0,
                'deuterium' => 0,
                'ships'     => json_decode($shipsJson, true) ?: array(),
                'defenses'  => json_decode($defensesJson, true) ?: array(),
                'buildings' => array(),
            ));
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, $eventId, 'spawn_ghost_error', 0, 0, array(
                'registration_id' => $registrationId,
                'error'           => $e->getMessage(),
            ));
            return null;
        }

        if (empty($ghost['user_id'])) return null;

        try {
            $db->insert(
                "INSERT INTO %%PVE_BOSS_GHOSTS%% SET
                    event_id        = :eid,
                    registration_id = :rid,
                    ally_id         = :aid,
                    spawn_number    = :spawnNum,
                    ghost_user_id   = :guid,
                    ghost_planet_id = :gpid,
                    galaxy          = :g,
                    system          = :s,
                    planet          = :p,
                    hp_max          = :hpMax,
                    hp_current      = :hpMax,
                    damage_done     = 0,
                    pct_damage      = 0,
                    phase           = 1,
                    counter_next_at = :counterAt,
                    ships_json      = :ships,
                    defenses_json   = :defs,
                    status          = 'active',
                    spawned_at      = :now;",
                array(
                    ':eid'       => $eventId,
                    ':rid'       => $registrationId,
                    ':aid'       => $allyId,
                    ':spawnNum'  => $spawnNumber,
                    ':guid'      => (int) $ghost['user_id'],
                    ':gpid'      => (int) $ghost['planet_id'],
                    ':g'         => (int) $coords['galaxy'],
                    ':s'         => (int) $coords['system'],
                    ':p'         => (int) $coords['planet'],
                    ':hpMax'     => $hpMax,
                    ':counterAt' => TIMESTAMP + ((int) PVEHelper::get('boss_phase2_counter_interval', 270) * 60),
                    ':ships'     => $shipsJson,
                    ':defs'      => $defensesJson,
                    ':now'       => TIMESTAMP,
                )
            );

            $ghostId = (int) $db->lastInsertId();

            $db->update(
                "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET
                    ghosts_spawned   = ghosts_spawned + 1,
                    status           = 'active',
                    members_at_spawn = :members
                 WHERE id = :id;",
                array(':members' => $membersActive, ':id' => $registrationId)
            );

            $db->update(
                "UPDATE %%PVE_BOSS_EVENT%% SET total_ghosts_spawned = total_ghosts_spawned + 1 WHERE id = :id;",
                array(':id' => $eventId)
            );

            self::notifyAllianceCoords($event, $ghostId, $coords, $allyId, $hpMax, $spawnNumber);

            PVEHelper::log(self::LOG_TYPE, $eventId, 'ghost_spawned', 0, 0, array(
                'registration_id' => $registrationId,
                'ally_id'         => $allyId,
                'spawn_number'    => $spawnNumber,
                'coord'           => "{$coords['galaxy']}:{$coords['system']}:{$coords['planet']}",
                'hp'              => $hpMax,
            ));

            return array(
                'ghost_id' => $ghostId,
                'galaxy'   => $coords['galaxy'],
                'system'   => $coords['system'],
                'planet'   => $coords['planet'],
            );
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, $eventId, 'spawn_insert_error', 0, 0, array(
                'error' => $e->getMessage(),
            ));

            // [v3.8] El fantasma (users+planets+statpoints+pve_ghosts) ya
            // existe aunque el INSERT en pve_boss_ghosts haya fallado:
            // destruirlo para no dejar un planeta fantasma huerfano e
            // invisible para destroyAllGhosts/cleanupOrphans.
            try {
                if (!empty($ghost['user_id'])) {
                    PVEGhostHelper::destroyGhostByUserId((int) $ghost['user_id']);
                }
            } catch (Throwable $e2) {}

            return null;
        }
    }

    private static function findEmptyCoordinatesForEvent(int $eventId): array
    {
        $db     = Database::get();
        $config = Config::get();

        $maxGalaxy  = max(1, (int) ($config->max_galaxy  ?? 5));
        $maxSystem  = max(1, (int) ($config->max_system  ?? 400));
        $maxPlanets = max(1, (int) ($config->max_planets ?? 12));

        $minPlanet = 4;
        $maxPlanet = max($minPlanet, $maxPlanets - 3);

        $taken = self::getTakenCoordsForEvent($eventId);

        for ($i = 0; $i < 50; $i++) {
            $g = random_int(1, $maxGalaxy);
            $s = random_int(1, $maxSystem);
            $p = random_int($minPlanet, $maxPlanet);

            $key = "{$g}:{$s}:{$p}";
            if (in_array($key, $taken, true)) continue;

            // [v3.8] Filtro por universo: los fantasmas se crean con
            // universe = Universe::current() (PVEGhostHelper), pero este
            // SELECT miraba TODOS los universos -> coordenadas libres aqui
            // se rechazaban por estar ocupadas en otro universo.
            $exists = $db->selectSingle(
                "SELECT id FROM %%PLANETS%%
                 WHERE galaxy = :g AND system = :s AND planet = :p AND planet_type = 1
                   AND universe = :uni
                 LIMIT 1;",
                array(':g' => $g, ':s' => $s, ':p' => $p, ':uni' => Universe::current())
            );
            if (!empty($exists)) continue;

            return array('galaxy' => $g, 'system' => $s, 'planet' => $p);
        }

        // [v3.8] El fallback ANTES devolvia coordenadas sin validar (si
        // estaban ocupadas, se creaban dos planetas en la misma posicion).
        // Ahora intenta validarlas antes de rendirse.
        for ($i = 0; $i < 30; $i++) {
            $g = 1;
            $s = random_int(1, $maxSystem);
            $p = random_int($minPlanet, $maxPlanet);

            $key = "{$g}:{$s}:{$p}";
            if (in_array($key, $taken, true)) continue;

            $exists = $db->selectSingle(
                "SELECT id FROM %%PLANETS%%
                 WHERE galaxy = :g AND system = :s AND planet = :p AND planet_type = 1
                   AND universe = :uni
                 LIMIT 1;",
                array(':g' => $g, ':s' => $s, ':p' => $p, ':uni' => Universe::current())
            );
            if (!empty($exists)) continue;

            return array('galaxy' => $g, 'system' => $s, 'planet' => $p);
        }

        return array(
            'galaxy' => 1,
            'system' => random_int(1, $maxSystem),
            'planet' => random_int($minPlanet, $maxPlanet),
        );
    }

    private static function getTakenCoordsForEvent(int $eventId): array
    {
        $db = Database::get();
        $rows = $db->select(
            "SELECT galaxy, system, planet FROM %%PVE_BOSS_GHOSTS%%
             WHERE event_id = :eid AND status IN ('active','killed');",
            array(':eid' => $eventId)
        );
        $taken = array();
        if (is_array($rows)) {
            foreach ($rows as $r) {
                $taken[] = (int) $r['galaxy'] . ':' . (int) $r['system'] . ':' . (int) $r['planet'];
            }
        }
        return $taken;
    }

    public static function respawnGhosts(): void
    {
        if ((int) PVEHelper::get('boss_respawn_enabled', 1) !== 1) return;

        $db = Database::get();
        $event = self::getActiveEvent();
        if (empty($event) || $event['status'] !== 'active') return;

        $now = TIMESTAMP;
        $blockLastHours = (int) PVEHelper::get('boss_respawn_block_last_hours', 1);
        $blockBefore    = $now + ($blockLastHours * 3600);
        if ((int) $event['end_time'] <= $blockBefore) return;

        $pending = $db->select(
            "SELECT r.*, a.ally_name, a.ally_tag
             FROM %%PVE_BOSS_REGISTRATIONS%% r
             LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
             WHERE r.event_id = :eid
               AND r.status = 'active'
               AND r.next_respawn_at IS NOT NULL
               AND r.next_respawn_at <= :now
             ORDER BY r.next_respawn_at ASC LIMIT 10;",
            array(':eid' => (int) $event['id'], ':now' => $now)
        );

        if (!is_array($pending) || count($pending) === 0) return;

        foreach ($pending as $reg) {
            $maxRespawns = (int) PVEHelper::get('boss_max_respawns_per_ally', 0);
            if ($maxRespawns > 0 && (int) $reg['ghosts_spawned'] >= $maxRespawns) continue;

            $spawnNumber = (int) $reg['ghosts_spawned'] + 1;
            $result = self::spawnGhostForRegistration($event, $reg, $spawnNumber);

            if (!empty($result)) {
                $db->update(
                    "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET next_respawn_at = NULL WHERE id = :id;",
                    array(':id' => (int) $reg['id'])
                );
            }
        }
    }

    public static function forceRespawnGhost(int $registrationId): array
    {
        $db = Database::get();
        $reg = self::getRegistrationById($registrationId);
        if (empty($reg)) {
            return array('ok' => false, 'error' => 'Registration no encontrada.');
        }

        $event = self::getEvent((int) $reg['event_id']);
        if (empty($event)) {
            return array('ok' => false, 'error' => 'Evento no encontrado.');
        }

        $spawnNumber = (int) $reg['ghosts_spawned'] + 1;
        $result = self::spawnGhostForRegistration($event, $reg, $spawnNumber);
        if (empty($result)) {
            return array('ok' => false, 'error' => 'No se pudo crear el fantasma.');
        }

        return array(
            'ok'     => true,
            'galaxy' => $result['galaxy'],
            'system' => $result['system'],
            'planet' => $result['planet'],
        );
    }

    private static function destroyAllGhosts(int $eventId): void
    {
        $db = Database::get();
        $ghosts = $db->select(
            "SELECT id, ghost_user_id FROM %%PVE_BOSS_GHOSTS%%
             WHERE event_id = :eid AND status = 'active';",
            array(':eid' => $eventId)
        );
        if (!is_array($ghosts)) return;

        foreach ($ghosts as $g) {
            try {
                PVEGhostHelper::destroyGhostByUserId((int) $g['ghost_user_id']);
            } catch (Throwable $e) {}

            $db->update(
                "UPDATE %%PVE_BOSS_GHOSTS%% SET
                    status       = 'destroyed',
                    destroyed_at = :now
                 WHERE id = :id;",
                array(':now' => TIMESTAMP, ':id' => (int) $g['id'])
            );
        }
    }

    private static function getDefaultShipsJson(): string
    {
        return json_encode(array(
            204 => 500, 205 => 300, 206 => 150, 207 => 80,
            211 => 40, 213 => 20, 215 => 10,
        ));
    }

    private static function getDefaultDefensesJson(): string
    {
        return json_encode(array(
            401 => 2000, 402 => 1000, 403 => 500, 404 => 200,
            405 => 100, 406 => 50, 407 => 1, 408 => 1,
        ));
    }

    // ---------------------------------------------------------------
    //  5. COMBATE — DAÑO Y FASES
    // ---------------------------------------------------------------

    public static function registerDamage(
        int $eventId, int $registrationId, int $allyId, int $userId, int $damage
    ): void {
        if ($damage <= 0) return;

        $db  = Database::get();
        $now = TIMESTAMP;

        try {
            $existing = $db->selectSingle(
                "SELECT id FROM %%PVE_BOSS_DAMAGE%%
                 WHERE event_id = :eid AND user_id = :uid LIMIT 1;",
                array(':eid' => $eventId, ':uid' => $userId)
            );

            if (!empty($existing)) {
                $db->update(
                    "UPDATE %%PVE_BOSS_DAMAGE%% SET
                        damage_done   = damage_done + :dmg,
                        attacks_count = attacks_count + 1,
                        last_hit      = :now
                     WHERE id = :id;",
                    array(':dmg' => $damage, ':now' => $now, ':id' => (int) $existing['id'])
                );
            } else {
                $db->insert(
                    "INSERT INTO %%PVE_BOSS_DAMAGE%% SET
                        event_id        = :eid,
                        registration_id = :rid,
                        ally_id         = :aid,
                        user_id         = :uid,
                        damage_done     = :dmg,
                        attacks_count   = 1,
                        first_hit       = :now,
                        last_hit        = :now;",
                    array(
                        ':eid' => $eventId, ':rid' => $registrationId, ':aid' => $allyId,
                        ':uid' => $userId, ':dmg' => $damage, ':now' => $now,
                    )
                );
            }

            $db->update(
                "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET
                    total_damage     = total_damage + :dmg,
                    attacks_count    = attacks_count + 1,
                    members_attacked = (
                        SELECT COUNT(DISTINCT user_id) FROM %%PVE_BOSS_DAMAGE%%
                        WHERE registration_id = :rid2
                    ),
                    last_hit         = :now
                 WHERE id = :id;",
                array(':dmg' => $damage, ':rid2' => $registrationId, ':now' => $now, ':id' => $registrationId)
            );

            $db->update(
                "UPDATE %%PVE_BOSS_EVENT%% SET total_damage = total_damage + :dmg WHERE id = :id;",
                array(':dmg' => $damage, ':id' => $eventId)
            );

            self::safeRecordBossDamage($userId, $damage);
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, $eventId, 'register_damage_error', $userId, 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }

    public static function applyDamage(int $ghostId, int $damage, int $userId = 0): array
    {
        $result = array(
            'phase_changed' => false, 'old_phase' => 0, 'new_phase' => 0,
            'killed' => false, 'will_respawn' => false, 'all_killed' => false,
        );
        if ($damage <= 0) return $result;

        $db = Database::get();
        $ghost = $db->selectSingle(
            "SELECT * FROM %%PVE_BOSS_GHOSTS%% WHERE id = :id LIMIT 1;",
            array(':id' => $ghostId)
        );
        if (empty($ghost) || $ghost['status'] !== 'active') return $result;

        $oldPhase = (int) $ghost['phase'];
        $result['old_phase'] = $oldPhase;

        // [v3.8] Decremento atomico en SQL (GREATEST + guard de estado): antes
        // el HP se leia en PHP y se escribia el resultado, asi que dos ataques
        // concurrentes perdian uno de los dos danios (lost update). Ademas
        // pct_damage sumaba :dmg2 sobre damage_done YA incrementado (MySQL
        // evalua los SET de izquierda a derecha con el valor nuevo), con lo
        // que el porcentaje quedaba inflado.
        $db->update(
            "UPDATE %%PVE_BOSS_GHOSTS%% SET
                hp_current  = GREATEST(0, hp_current - :dmg),
                damage_done = damage_done + :dmg,
                pct_damage  = ROUND(damage_done / GREATEST(hp_max, 1) * 100, 2)
             WHERE id = :id AND status = 'active';",
            array(':dmg' => $damage, ':id' => $ghostId)
        );

        if ($db->rowCount() !== 1) {
            return $result; // el ghost ya no esta activo (otro proceso lo mato)
        }

        // Releer el HP real tras el decremento atomico
        $rowHp = $db->selectSingle(
            "SELECT hp_current FROM %%PVE_BOSS_GHOSTS%% WHERE id = :id LIMIT 1;",
            array(':id' => $ghostId)
        );
        $newHp = !empty($rowHp) ? (int) $rowHp['hp_current'] : 0;

        if ($newHp <= 0) {
            return self::killGhost($ghost, $result, $userId);
        }

        $hpPct = ((int) $ghost['hp_max'] > 0) ? ($newHp / (int) $ghost['hp_max'] * 100) : 0;
        $phase2 = (int) PVEHelper::get('boss_phase2_threshold', 70);
        $phase3 = (int) PVEHelper::get('boss_phase3_threshold', 30);

        if ($oldPhase === 1 && $hpPct <= $phase2) {
            self::setPhase($ghostId, 2);
            $result['phase_changed'] = true;
            $result['new_phase']     = 2;
        } elseif ($oldPhase === 2 && $hpPct <= $phase3) {
            self::setPhase($ghostId, 3);
            $result['phase_changed'] = true;
            $result['new_phase']     = 3;
        }

        return $result;
    }

    private static function setPhase(int $ghostId, int $newPhase): void
    {
        $db = Database::get();
        $ghost = $db->selectSingle(
            "SELECT * FROM %%PVE_BOSS_GHOSTS%% WHERE id = :id LIMIT 1;",
            array(':id' => $ghostId)
        );
        if (empty($ghost)) return;

        $updates = "phase = :phase";
        $params  = array(':phase' => $newPhase, ':id' => $ghostId);

        if ($newPhase === 3 && (int) PVEHelper::get('boss_phase3_hp_halve', 1) === 1) {
            $newHp = max(1, (int) floor($ghost['hp_current'] / 2));
            $updates .= ", hp_current = :newHp";
            $params[':newHp'] = $newHp;
        }

        $intervalMin = ($newPhase === 3)
            ? (int) PVEHelper::get('boss_phase3_counter_interval', 240)
            : (int) PVEHelper::get('boss_phase2_counter_interval', 270);
        $updates .= ", counter_next_at = :counterAt";
        $params[':counterAt'] = TIMESTAMP + ($intervalMin * 60);

        $db->update(
            "UPDATE %%PVE_BOSS_GHOSTS%% SET {$updates} WHERE id = :id;",
            $params
        );

        self::notifyPhaseChange((int) $ghost['event_id'], (int) $ghost['ally_id'], $newPhase, $ghost);
    }

    private static function killGhost(array $ghost, array &$result, int $userId = 0): array
    {
        $db = Database::get();
        $now = TIMESTAMP;

        // [v3.8] Guard anti-carrera: solo el primer proceso que mata al ghost
        // acredita el kill (WHERE status='active' + rowCount). Antes dos
        // ataques concurrentes ejecutaban killGhost dos veces:
        // ghosts_killed +2, pct_damage_total +200 y respawn duplicado.
        $db->update(
            "UPDATE %%PVE_BOSS_GHOSTS%% SET
                hp_current = 0, status = 'killed', killed_at = :now
             WHERE id = :id AND status = 'active';",
            array(':now' => $now, ':id' => (int) $ghost['id'])
        );

        if ($db->rowCount() !== 1) {
            return $result; // otro proceso ya lo mato
        }

        $result['killed'] = true;

        $cooldownMin = (int) PVEHelper::get('boss_respawn_cooldown_min', 5);
        $nextRespawn = $now + ($cooldownMin * 60);

        $db->update(
            "UPDATE %%PVE_BOSS_REGISTRATIONS%% SET
                ghosts_killed    = ghosts_killed + 1,
                pct_damage_total = pct_damage_total + 100,
                next_respawn_at  = :next
             WHERE id = :id;",
            array(':next' => $nextRespawn, ':id' => (int) $ghost['registration_id'])
        );

        $db->update(
            "UPDATE %%PVE_BOSS_EVENT%% SET total_ghosts_killed = total_ghosts_killed + 1 WHERE id = :id;",
            array(':id' => (int) $ghost['event_id'])
        );

        try { PVEGhostHelper::destroyGhostByUserId((int) $ghost['ghost_user_id']); } catch (Throwable $e) {}

        $result['will_respawn'] = true;

        if ($userId > 0) {
            self::safeRecordBossKill($userId, 1);
        }

        self::notifyGhostKilled((int) $ghost['event_id'], (int) $ghost['ally_id'], $ghost, $cooldownMin);

        $allDone = $db->selectSingle(
            "SELECT COUNT(*) AS c FROM %%PVE_BOSS_GHOSTS%%
             WHERE event_id = :eid AND status = 'active';",
            array(':eid' => (int) $ghost['event_id']), 'c'
        );
        $result['all_killed'] = ((int) $allDone === 0);

        return $result;
    }

    // ---------------------------------------------------------------
    //  6. CONTRAATAQUES
    // ---------------------------------------------------------------

    public static function processCounterAttacks(): void
    {
        $event = self::getActiveEvent();
        if (empty($event) || $event['status'] !== 'active') return;

        $db = Database::get();
        $ghosts = $db->select(
            "SELECT * FROM %%PVE_BOSS_GHOSTS%%
             WHERE event_id = :eid AND status = 'active' AND phase >= 2
               AND counter_next_at IS NOT NULL AND counter_next_at <= :now
             LIMIT 20;",
            array(':eid' => (int) $event['id'], ':now' => TIMESTAMP)
        );

        if (!is_array($ghosts) || count($ghosts) === 0) return;

        foreach ($ghosts as $ghost) {
            self::tickCounterAttackForGhost($event, $ghost);
        }
    }

    private static function tickCounterAttackForGhost(array $event, array $ghost): void
    {
        $db  = Database::get();
        $now = TIMESTAMP;

        $phase       = (int) $ghost['phase'];
        $intervalMin = ($phase >= 3)
            ? (int) PVEHelper::get('boss_phase3_counter_interval', 240)
            : (int) PVEHelper::get('boss_phase2_counter_interval', 270);

        $hpPct = ((int) $ghost['hp_max'] > 0) ? ($ghost['hp_current'] / $ghost['hp_max'] * 100) : 0;
        $minPct = (int) PVEHelper::get('boss_counter_min_fleet_pct', 5);
        if ($hpPct < $minPct) return;

        $target = self::pickCounterTarget($ghost);
        if (empty($target)) {
            $db->update(
                "UPDATE %%PVE_BOSS_GHOSTS%% SET counter_next_at = :next WHERE id = :id;",
                array(':next' => $now + 600, ':id' => (int) $ghost['id'])
            );
            return;
        }

        $sent = self::launchCounterAttack($ghost, $target, $phase);

        // [v3.8] Acumular los ultimos objetivos en vez de sobrescribir con 1:
        // pickCounterTarget() usa counter_last_targets como lista de
        // repeticiones a evitar; antes solo se evitaba al ultimo atacado.
        $lastTargets = array();
        if (!empty($ghost['counter_last_targets'])) {
            $decoded = json_decode((string) $ghost['counter_last_targets'], true);
            if (is_array($decoded)) $lastTargets = array_map('intval', $decoded);
        }
        $lastTargets[] = (int) $target['id'];
        $lastTargets   = array_values(array_unique(array_slice($lastTargets, -5)));

        $db->update(
            "UPDATE %%PVE_BOSS_GHOSTS%% SET
                counter_next_at      = :next,
                counter_last_targets = :targets
             WHERE id = :id;",
            array(
                ':next'    => $now + ($intervalMin * 60),
                ':targets' => json_encode($lastTargets),
                ':id'      => (int) $ghost['id'],
            )
        );

        if ($sent) {
            PVEHelper::log(self::LOG_TYPE, (int) $event['id'], 'counter_sent', (int) $target['id'], 0, array(
                'ghost_id' => (int) $ghost['id'], 'phase' => $phase,
            ));
        }
    }

    private static function pickCounterTarget(array $ghost): ?array
    {
        $db  = Database::get();
        $now = TIMESTAMP;

        $skipOffline = (int) PVEHelper::get('boss_counter_skip_offline', 1);
        $avoidRepeat = (int) PVEHelper::get('boss_counter_avoid_repeat', 1);
        $lastTargets = json_decode($ghost['counter_last_targets'] ?: '[]', true);
        if (!is_array($lastTargets)) $lastTargets = array();

        $sql    = "SELECT u.id, u.username, u.onlinetime FROM %%USERS%% u
                   WHERE u.ally_id = :aid AND u.bana = 0";
        $params = array(':aid' => (int) $ghost['ally_id']);

        if ($skipOffline) {
            $sql .= " AND u.onlinetime >= :onlineMin";
            $params[':onlineMin'] = $now - 7200;
        }

        if ($avoidRepeat && !empty($lastTargets)) {
            $placeholders = array();
            foreach ($lastTargets as $i => $tid) {
                $key = ":t{$i}";
                $placeholders[] = $key;
                $params[$key] = (int) $tid;
            }
            $sql .= " AND u.id NOT IN (" . implode(',', $placeholders) . ")";
        }

        $sql .= " ORDER BY RAND() LIMIT 5;";
        $members = $db->select($sql, $params);

        if (empty($members) && $avoidRepeat && !empty($lastTargets)) {
            return self::pickCounterTargetFallback((int) $ghost['ally_id'], $skipOffline);
        }
        if (empty($members)) return null;
        return $members[0];
    }

    private static function pickCounterTargetFallback(int $allyId, int $skipOffline): ?array
    {
        $db  = Database::get();
        $now = TIMESTAMP;

        $sql    = "SELECT u.id, u.username FROM %%USERS%% u WHERE u.ally_id = :aid AND u.bana = 0";
        $params = array(':aid' => $allyId);

        if ($skipOffline) {
            $sql .= " AND u.onlinetime >= :onlineMin";
            $params[':onlineMin'] = $now - 7200;
        }

        $sql .= " ORDER BY RAND() LIMIT 1;";
        $row = $db->selectSingle($sql, $params);
        return !empty($row) ? $row : null;
    }

    private static function launchCounterAttack(array $ghost, array $target, int $phase): bool
    {
        $ghostPlanetId = (int) $ghost['ghost_planet_id'];
        if ($ghostPlanetId <= 0) return false;

        $db = Database::get();
        $planet = $db->selectSingle(
            "SELECT * FROM %%PLANETS%% WHERE id = :id LIMIT 1;",
            array(':id' => $ghostPlanetId)
        );
        if (empty($planet)) return false;

        global $resource;
        $counterFleet = array();
        $shipsJson = json_decode($ghost['ships_json'] ?: '{}', true);
        if (!is_array($shipsJson)) $shipsJson = array();

        foreach ($shipsJson as $shipId => $baseCount) {
            $shipId = (int) $shipId;
            if ($shipId <= 0) continue;
            $colName = isset($resource[$shipId]) ? $resource[$shipId] : '';
            if (empty($colName) || empty($planet[$colName])) continue;
            $send = (int) floor((int) $planet[$colName] * 0.3);
            if ($send > 0) $counterFleet[$shipId] = $send;
        }

        if (empty($counterFleet)) return false;

        $targetPlanet = $db->selectSingle(
            "SELECT * FROM %%PLANETS%%
             WHERE id_owner = :uid AND planet_type = 1 ORDER BY id ASC LIMIT 1;",
            array(':uid' => (int) $target['id'])
        );
        if (empty($targetPlanet)) return false;

        $empireLike = array(
            'id'     => (int) $ghost['ghost_user_id'],
            'galaxy' => (int) $ghost['galaxy'],
            'system' => (int) $ghost['system'],
            'planet' => (int) $ghost['planet'],
        );

        try {
            $fleetId = PveFleetHelper::sendCounterAttackFleet(
                $empireLike, (int) $target['id'], (int) $targetPlanet['id'], $counterFleet
            );
            return !empty($fleetId);
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, (int) $ghost['event_id'], 'counter_launch_error', 0, 0, array(
                'error' => $e->getMessage(),
            ));
            return false;
        }
    }

    // ---------------------------------------------------------------
    //  7. RANKING / CONSULTAS
    // ---------------------------------------------------------------

    public static function getLiveRanking(int $eventId, int $limit = 20): array
    {
        $db = Database::get();
        $rows = $db->select(
            "SELECT 
                r.id AS registration_id, r.ally_id, r.total_damage, r.pct_damage_total,
                r.ghosts_spawned, r.ghosts_killed, r.members_at_spawn,
                r.attacks_count, r.members_attacked, r.status,
                a.ally_name, a.ally_tag,
                (SELECT phase FROM %%PVE_BOSS_GHOSTS%% g
                 WHERE g.registration_id = r.id AND g.status = 'active'
                 ORDER BY id DESC LIMIT 1) AS current_phase
             FROM %%PVE_BOSS_REGISTRATIONS%% r
             LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
             WHERE r.event_id = :eid AND r.status IN ('registered','active','killed','winner','lost')
             ORDER BY r.pct_damage_total DESC, r.total_damage DESC
             LIMIT " . (int) $limit . ";",
            array(':eid' => $eventId)
        );
        return is_array($rows) ? $rows : array();
    }

    public static function getAllyDetail(int $eventId, int $registrationId): array
    {
        $db = Database::get();
        $rows = $db->select(
            "SELECT d.user_id, d.damage_done, d.attacks_count, d.first_hit, d.last_hit, u.username
             FROM %%PVE_BOSS_DAMAGE%% d
             LEFT JOIN %%USERS%% u ON u.id = d.user_id
             WHERE d.event_id = :eid AND d.registration_id = :rid
             ORDER BY d.damage_done DESC LIMIT 50;",
            array(':eid' => $eventId, ':rid' => $registrationId)
        );
        return is_array($rows) ? $rows : array();
    }

    // ---------------------------------------------------------------
    //  8. PREMIOS Y REPARTO (DUAL-RIEL A1)
    // ---------------------------------------------------------------

    /**
     * Calcula el premio total a repartir.
     *
     * v1.8 — DUAL-RIEL:
     *   · Paid:  devuelve `net` como array ['ntx20' => real, 'untx20' => real]
     *            con fee aplicada por riel.
     *   · Free:  devuelve `net` como array con base NTX y recursos.
     *            El ×2 de QVAPAY se aplica al reclamar (pve_rewards ? claim).
     */
    private static function calculatePrize(array $event, array $winner): array
    {
        $prize = array('type' => 'ntx', 'total' => 0, 'fee' => 0, 'net' => 0, 'pool' => 0);

        if ($event['entry_mode'] === 'paid') {
            $poolNtx  = (int) ($event['pool_ntx20']  ?? 0);
            $poolUntx = (int) ($event['pool_untx20'] ?? 0);
            $feePct   = (int) $event['project_fee_pct'];

            $feeNtx  = (int) floor($poolNtx  * $feePct / 100);
            $feeUntx = (int) floor($poolUntx * $feePct / 100);

            $netNtx  = max(0, $poolNtx  - $feeNtx);
            $netUntx = max(0, $poolUntx - $feeUntx);

            $prize['type']  = 'ntx_dual';
            $prize['pool']  = array('ntx20' => $poolNtx,  'untx20' => $poolUntx);
            $prize['fee']   = array('ntx20' => $feeNtx,   'untx20' => $feeUntx);
            $prize['total'] = array('ntx20' => $poolNtx,  'untx20' => $poolUntx);
            $prize['net']   = array('ntx20' => $netNtx,   'untx20' => $netUntx);
        } else {
            $prize['type'] = 'mixed';

            $multiplier = 1;
            if (!empty($event['prize_scales_with_allies'])) {
                $db = Database::get();
                $count = (int) $db->selectSingle(
                    "SELECT COUNT(*) AS c FROM %%PVE_BOSS_REGISTRATIONS%%
                     WHERE event_id = :eid AND status IN ('registered','active','winner','lost');",
                    array(':eid' => (int) $event['id']), 'c'
                );
                $multiplier = max(1, $count);
            }

            // ?? NTX en BASE (claim aplica ×2 para QVAPAY)
            $prize['net'] = array(
                'ntx'         => (int) $event['prize_ntx'] * $multiplier,
                'metal'       => (int) $event['prize_metal'] * $multiplier,
                'crystal'     => (int) $event['prize_crystal'] * $multiplier,
                'deuterium'   => (int) $event['prize_deuterium'] * $multiplier,
                'dark_matter' => (int) $event['prize_dark_matter'] * $multiplier,
            );

            $prize['total'] = $prize['net'];
        }

        return $prize;
    }

    /**
     * Reparte el premio a la alianza ganadora.
     *
     * v1.8 — DUAL-RIEL:
     *   · Paid: cada contribuyente cobra del pool de SU riel, sin acuñar.
     *           Los montos en UNTX se convierten a base (÷2) para pve_rewards,
     *           así al reclamar PVEHelper los multiplica ×2 y devuelve el real.
     *   · Free: NTX en base (claim aplica ×2 para QVAPAY). Recursos universales.
     */
    private static function distributePrize(int $eventId, array $winner, array $prize): void
    {
        $db = Database::get();
        $allyId = (int) $winner['ally_id'];
        $event = self::getEvent($eventId);
        $distribution = (string) $event['winner_distribution'];

        $contribs = $db->select(
            "SELECT user_id, damage_done FROM %%PVE_BOSS_DAMAGE%%
             WHERE event_id = :eid AND registration_id = :rid;",
            array(':eid' => $eventId, ':rid' => (int) $winner['id'])
        );
        if (!is_array($contribs) || count($contribs) === 0) return;

        // Obtener líder
        $leader = $db->selectSingle(
            "SELECT ally_owner FROM %%ALLIANCE%% WHERE id = :id LIMIT 1;",
            array(':id' => $allyId)
        );
        $leaderId = !empty($leader['ally_owner']) ? (int) $leader['ally_owner'] : 0;

        // -- PAID MODE (dual pools) --
        if ($prize['type'] === 'ntx_dual') {
            $netNtx  = (int) ($prize['net']['ntx20']  ?? 0);
            $netUntx = (int) ($prize['net']['untx20'] ?? 0);

            if ($distribution === 'leader' && $leaderId > 0) {
                $leaderRiel = self::getRiel($leaderId);
                if ($leaderRiel === 'QVAPAY' && $netUntx > 0) {
                    // Convertir real UNTX ? base para pve_rewards (claim ×2)
                    $baseAmount = (int) floor($netUntx / self::UNTX_MULTIPLIER);
                    if ($baseAmount > 0) {
                        self::grantPrizeToUser($leaderId, 'ntx', $baseAmount, $eventId);
                    }
                    if ($netNtx > 0) {
                        PVEHelper::log(self::LOG_TYPE, $eventId, 'prize_orphan_pool', 0, 0, array(
                            'riel' => 'QVAPAY', 'orphan_ntx20' => $netNtx,
                            'reason' => 'distribution_leader_and_leader_is_qvapay',
                        ));
                    }
                } elseif ($leaderRiel !== 'QVAPAY' && $netNtx > 0) {
                    self::grantPrizeToUser($leaderId, 'ntx', $netNtx, $eventId);
                    if ($netUntx > 0) {
                        PVEHelper::log(self::LOG_TYPE, $eventId, 'prize_orphan_pool', 0, 0, array(
                            'riel' => 'CUP', 'orphan_untx20' => $netUntx,
                            'reason' => 'distribution_leader_and_leader_is_cup',
                        ));
                    }
                }
                return;
            }

            // Separar contribuyentes por riel
            $cupUsers = array(); $qvapayUsers = array();
            $totalDamageCup = 0; $totalDamageQvapay = 0;

            foreach ($contribs as $c) {
                $uid = (int) $c['user_id'];
                $dmg = (int) $c['damage_done'];
                $riel = self::getRiel($uid);
                if ($riel === 'QVAPAY') {
                    $qvapayUsers[] = array('user_id' => $uid, 'damage_done' => $dmg);
                    $totalDamageQvapay += $dmg;
                } else {
                    $cupUsers[] = array('user_id' => $uid, 'damage_done' => $dmg);
                    $totalDamageCup += $dmg;
                }
            }

            if ($distribution === 'equal') {
                if (count($cupUsers) > 0 && $netNtx > 0) {
                    $per = (int) floor($netNtx / count($cupUsers));
                    if ($per > 0) {
                        foreach ($cupUsers as $u) {
                            self::grantPrizeToUser($u['user_id'], 'ntx', $per, $eventId);
                        }
                    }
                }
                if (count($qvapayUsers) > 0 && $netUntx > 0) {
                    $perBase = (int) floor(($netUntx / self::UNTX_MULTIPLIER) / count($qvapayUsers));
                    if ($perBase > 0) {
                        foreach ($qvapayUsers as $u) {
                            self::grantPrizeToUser($u['user_id'], 'ntx', $perBase, $eventId);
                        }
                    }
                }
                return;
            }

            // by_contribution (por defecto)
            if ($totalDamageCup > 0 && $netNtx > 0) {
                foreach ($cupUsers as $u) {
                    $share = $u['damage_done'] / $totalDamageCup;
                    $amt = (int) floor($netNtx * $share);
                    if ($amt > 0) self::grantPrizeToUser($u['user_id'], 'ntx', $amt, $eventId);
                }
            }
            if ($totalDamageQvapay > 0 && $netUntx > 0) {
                $netUntxBase = (int) floor($netUntx / self::UNTX_MULTIPLIER);
                foreach ($qvapayUsers as $u) {
                    $share = $u['damage_done'] / $totalDamageQvapay;
                    $amt = (int) floor($netUntxBase * $share);
                    if ($amt > 0) self::grantPrizeToUser($u['user_id'], 'ntx', $amt, $eventId);
                }
            }
            return;
        }

        // -- FREE MODE (mixed) --
        $totalDamage = 0;
        foreach ($contribs as $c) $totalDamage += (int) $c['damage_done'];
        $netPrize = $prize['net'];

        if ($distribution === 'leader' && $leaderId > 0) {
            self::grantPrizeToUser($leaderId, $prize['type'], $netPrize, $eventId);
            return;
        }

        if ($distribution === 'equal') {
            $count = count($contribs);
            $perUser = array();
            foreach ($netPrize as $k => $v) {
                $perUser[$k] = (int) floor($v / max(1, $count));
            }
            foreach ($contribs as $c) {
                self::grantPrizeToUser((int) $c['user_id'], $prize['type'], $perUser, $eventId);
            }
            return;
        }

        if ($totalDamage <= 0) return;

        foreach ($contribs as $c) {
            $share = (int) $c['damage_done'] / $totalDamage;
            $amount = array();
            foreach ($netPrize as $k => $v) {
                $amount[$k] = (int) floor($v * $share);
            }
            self::grantPrizeToUser((int) $c['user_id'], $prize['type'], $amount, $eventId);
        }
    }

    /**
     * Otorga el premio a un usuario según tipo.
     *
     * v1.8 — `pve_rewards.reward_type='ntx'` guarda SIEMPRE el monto en
     * BASE NTX-20. `PVEHelper::claimAllRewards()` aplica ×2 para QVAPAY.
     * Por eso, al pagar con pool_untx20 real, se divide entre 2 antes de
     * llamar a `grantPrizeToUser()`.
     */
    private static function grantPrizeToUser(int $userId, string $type, $amount, int $eventId): void
    {
        if ($userId <= 0) return;
        $db = Database::get();

        // --- PREMIO MIXTO (Array) ---
        if (is_array($amount)) {
            $res = array(
                'metal'     => (int) ($amount['metal'] ?? 0),
                'crystal'   => (int) ($amount['crystal'] ?? 0),
                'deuterium' => (int) ($amount['deuterium'] ?? 0),
            );
            if ($res['metal'] > 0 || $res['crystal'] > 0 || $res['deuterium'] > 0) {
                $db->insert(
                    "INSERT INTO %%PVE_REWARDS%% SET
                        user_id     = :uid,
                        event_type  = 'boss',
                        event_id    = :eid,
                        reward_type = 'resources',
                        reward_data = :data,
                        claimed     = 0,
                        created_at  = :now;",
                    array(
                        ':uid'  => $userId, ':eid' => $eventId,
                        ':data' => json_encode($res), ':now' => TIMESTAMP,
                    )
                );
            }

            if (!empty($amount['ntx']) && $amount['ntx'] > 0) {
                $db->insert(
                    "INSERT INTO %%PVE_REWARDS%% SET
                        user_id     = :uid,
                        event_type  = 'boss',
                        event_id    = :eid,
                        reward_type = 'ntx',
                        reward_data = :data,
                        claimed     = 0,
                        created_at  = :now;",
                    array(
                        ':uid'  => $userId, ':eid' => $eventId,
                        ':data' => json_encode(array('amount' => (int) $amount['ntx'])),
                        ':now'  => TIMESTAMP,
                    )
                );
            }

            if (!empty($amount['dark_matter']) && $amount['dark_matter'] > 0) {
                $db->update(
                    "UPDATE %%USERS%% SET darkmatter = darkmatter + :amt WHERE id = :uid;",
                    array(':amt' => (int) $amount['dark_matter'], ':uid' => $userId)
                );
            }
            return;
        }

        // --- PREMIO ÚNICO ---
        if ($amount <= 0) return;

        switch ($type) {
            case 'ntx':
                $db->insert(
                    "INSERT INTO %%PVE_REWARDS%% SET
                        user_id     = :uid,
                        event_type  = 'boss',
                        event_id    = :eid,
                        reward_type = 'ntx',
                        reward_data = :data,
                        claimed     = 0,
                        created_at  = :now;",
                    array(
                        ':uid'  => $userId, ':eid' => $eventId,
                        ':data' => json_encode(array('amount' => $amount)), ':now' => TIMESTAMP,
                    )
                );
                break;

            case 'metal':
            case 'crystal':
            case 'deuterium':
                $data = array('metal' => 0, 'crystal' => 0, 'deuterium' => 0);
                $data[$type] = $amount;
                $db->insert(
                    "INSERT INTO %%PVE_REWARDS%% SET
                        user_id     = :uid,
                        event_type  = 'boss',
                        event_id    = :eid,
                        reward_type = 'resources',
                        reward_data = :data,
                        claimed     = 0,
                        created_at  = :now;",
                    array(
                        ':uid'  => $userId, ':eid' => $eventId,
                        ':data' => json_encode($data), ':now' => TIMESTAMP,
                    )
                );
                break;

            case 'dark_matter':
                $db->update(
                    "UPDATE %%USERS%% SET darkmatter = darkmatter + :amt WHERE id = :uid;",
                    array(':amt' => $amount, ':uid' => $userId)
                );
                break;
        }
    }

    // ---------------------------------------------------------------
    //  9. NOTIFICACIONES
    // ---------------------------------------------------------------

    private static function notifyAllianceLeaders(int $eventId, array $event): void
    {
        $db = Database::get();
        $allies = $db->select(
            "SELECT id, ally_name, ally_owner FROM %%ALLIANCE%%
             WHERE ally_members > 0;"
        );
        if (!is_array($allies)) return;

        foreach ($allies as $ally) {
            $leaderId = (int) $ally['ally_owner'];
            if ($leaderId <= 0) continue;

            $riel     = self::getRiel($leaderId);
            $moneda   = self::getMoneda($leaderId);
            $costBase = (int) $event['entry_cost_ntx'];
            $costReal = ($riel === 'QVAPAY') ? ($costBase * self::UNTX_MULTIPLIER) : $costBase;

            $body  = "<b>?? ¡Torneo del Devorador disponible!</b><br><br>";
            $body .= "Tu alianza <b>" . $ally['ally_name'] . "</b> puede inscribirse.<br><br>";
            $body .= "<b>Modo de entrada:</b> " . ($event['entry_mode'] === 'paid' ? 'Pago (' . $costReal . ' ' . $moneda . ')' : 'Gratis') . "<br>";
            $body .= "<b>Registro cierra:</b> " . date('d/m/Y H:i', (int) $event['registration_end']) . "<br>";
            $body .= "<b>Premio:</b> " . self::describePrize($event) . "<br><br>";
            $body .= "<a href=\"game.php?page=pve&mode=boss\">? Ir al panel del torneo</a>";

            self::sendMessageToUser($leaderId, '?? Torneo del Devorador — Inscripción abierta', $body);
        }
    }

    private static function notifyAllianceCoords(
        array $event, int $ghostId, array $coords, int $allyId, int $hpMax, int $spawnNumber
    ): void {
        $coord = "{$coords['galaxy']}:{$coords['system']}:{$coords['planet']}";
        $attackUrl = "game.php?page=fleetTable"
                   . "&galaxy={$coords['galaxy']}"
                   . "&system={$coords['system']}"
                   . "&planet={$coords['planet']}"
                   . "&planettype=1"
                   . "&target_mission=23";

        $body  = "<div style='padding:12px;background:#1a0a2e;border-left:4px solid #aa44ff;border-radius:6px;color:#e0e0e0;'>";
        $body .= "<h2 style='color:#dd99ff;margin:0 0 10px;'>?? TORNEO DEL DEVORADOR — FANTASMA #{$spawnNumber}</h2>";
        $body .= "<p>Ha aparecido un nuevo Devorador para tu alianza.</p>";
        $body .= "<div style='background:#0a0a1a;border-left:3px solid #ffaa33;padding:10px;margin:12px 0;border-radius:4px;'>";
        $body .= "<p style='margin:0 0 6px;font-size:11px;color:#9ca3af;'>?? COORDENADAS</p>";
        $body .= "<p style='font-size:22px;color:#ffaa33;font-weight:bold;margin:0;'>{$coord}</p>";
        $body .= "</div>";
        $body .= "<table style='width:100%;font-size:12px;color:#d1d5db;'>";
        $body .= "<tr><td>?? HP total:</td><td align='right'><b>" . number_format($hpMax) . "</b></td></tr>";
        $body .= "<tr><td>?? Fase:</td><td align='right'><b>I — Acecho</b></td></tr>";
        $body .= "</table>";
        $body .= "<div style='margin-top:16px;text-align:center;'>";
        $body .= "<a href='{$attackUrl}' style='display:inline-block;background:linear-gradient(135deg,#6a1b9a,#ab47bc);color:#fff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:bold;'>?? ATACAR AHORA</a>";
        $body .= "</div>";
        $body .= "<p style='font-size:10px;color:#6b7280;margin-top:14px;'>Ranking en vivo: <a href='game.php?page=pve&mode=boss' style='color:#dd99ff;'>panel PvE</a></p>";
        $body .= "</div>";

        self::sendMessageToAlly($allyId,
            '?? Torneo del Devorador — Nuevo fantasma [' . $coord . ']',
            $body);
    }

    private static function notifyPhaseChange(int $eventId, int $allyId, int $newPhase, array $ghost): void
    {
        $phaseNames = array(
            2 => '? II — ENFURECIDO',
            3 => '?? III — ÚLTIMO ALIENTO',
        );

        $phaseName = isset($phaseNames[$newPhase]) ? $phaseNames[$newPhase] : 'Fase ' . $newPhase;

        $body  = "<div style='padding:12px;background:#1a0a2e;border-left:4px solid #ff4444;border-radius:6px;'>";
        $body .= "<h2 style='color:#ff88ff;margin:0 0 10px;'>?? CAMBIO DE FASE</h2>";
        $body .= "<p>El Devorador de tu alianza ha entrado en <b style='color:#ff4444;'>{$phaseName}</b>.</p>";

        if ($newPhase === 2) {
            $body .= "<p style='font-size:12px;'>A partir de ahora lanzará contraataques aleatorios cada pocas horas.</p>";
        } elseif ($newPhase === 3) {
            $body .= "<p style='font-size:12px;'>Su HP se ha reducido a la mitad, pero su flota es ahora el triple de peligrosa. ¡Cuidado!</p>";
        }

        $body .= "<p style='font-size:11px;color:#9ca3af;margin-top:10px;'>HP actual: " . number_format((int) $ghost['hp_current']) . " / " . number_format((int) $ghost['hp_max']) . "</p>";
        $body .= "</div>";

        self::sendMessageToAlly($allyId,
            '?? Devorador — ' . $phaseName,
            $body);
    }

    private static function notifyGhostKilled(int $eventId, int $allyId, array $ghost, int $cooldownMin): void
    {
        $body  = "<div style='padding:12px;background:#0a2e1a;border-left:4px solid #00cc66;border-radius:6px;'>";
        $body .= "<h2 style='color:#88ffbb;margin:0 0 10px;'>?? ¡DEVORADOR ELIMINADO!</h2>";
        $body .= "<p>Tu alianza ha destruido el Devorador #" . (int) $ghost['spawn_number'] . ".</p>";
        $body .= "<p style='color:#ffee88;font-size:13px;'>?? Un nuevo Devorador aparecerá en " . (int) $cooldownMin . " minutos.</p>";
        $body .= "<p style='font-size:11px;color:#9ca3af;'>Permaneced atentos a las nuevas coordenadas.</p>";
        $body .= "</div>";

        self::sendMessageToAlly($allyId,
            '?? Devorador eliminado — Respawn en ' . (int) $cooldownMin . ' min',
            $body);
    }

    private static function announceGlobalSpawn(int $eventId, int $count): void
    {
        $db = Database::get();
        // [v3.8] Antes se enviaba SOLO al staff (authlevel >= 1): el aviso
        // "¡EL TORNEO HA COMENZADO!" nunca llegaba a los jugadores. Ahora va
        // a todos los usuarios reales activos; el universo correcto de cada
        // destinatario lo resuelve sendMessageToUser() (getUniverseForUser).
        $users = $db->select(
            "SELECT id FROM %%USERS%%
             WHERE bana = 0 AND urlaubs_modus = 0
             LIMIT 2000;"
        );
        if (!is_array($users)) return;

        $body  = "<div style='padding:14px;background:linear-gradient(135deg,#1a0a2e,#2d1b4e);border-radius:8px;text-align:center;color:#e0e0e0;'>";
        $body .= "<h2 style='color:#ffaa33;margin:0 0 10px;'>?? ¡EL TORNEO HA COMENZADO!</h2>";
        $body .= "<p style='font-size:14px;'>{$count} Devoradores han aparecido en coordenadas aleatorias.</p>";
        $body .= "<p style='font-size:12px;color:#9ca3af;'>Las alianzas inscritas ya conocen sus coordenadas.</p>";
        $body .= "<div style='margin-top:12px;'>";
        $body .= "<a href='game.php?page=pve&mode=boss' style='display:inline-block;background:#aa44ff;color:#fff;padding:10px 20px;border-radius:6px;text-decoration:none;font-weight:bold;'>?? Ver ranking en vivo</a>";
        $body .= "</div>";
        $body .= "</div>";

        foreach ($users as $u) {
            self::sendMessageToUser((int) $u['id'], '?? Torneo del Devorador — ¡Comenzó!', $body);
        }
    }

    private static function notifyEventFinished(int $eventId, array $event, array $winner, array $prize): void
    {
        $db = Database::get();
        $regs = $db->select(
            "SELECT r.*, a.ally_name
             FROM %%PVE_BOSS_REGISTRATIONS%% r
             LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
             WHERE r.event_id = :eid;",
            array(':eid' => $eventId)
        );
        if (!is_array($regs)) return;

        foreach ($regs as $reg) {
            $isWinner = ((int) $reg['ally_id'] === (int) $winner['ally_id']);

            $body  = "<div style='padding:12px;border-radius:6px;background:" . ($isWinner ? '#0a2e1a;border-left:4px solid #00cc66' : '#2e0a0a;border-left:4px solid #cc2200') . ";'>";
            $body .= "<h2 style='margin:0 0 10px;color:" . ($isWinner ? '#88ffbb' : '#ff8888') . ";'>";
            $body .= $isWinner ? '?? ¡GANADORES!' : '?? No ganasteis';
            $body .= "</h2>";
            $body .= "<p>Alianza <b>" . $reg['ally_name'] . "</b></p>";

            if ($isWinner) {
                $body .= "<p style='color:#ffee88;font-size:14px;'>Premio: <b>" . self::formatPrize($prize) . "</b></p>";
                $body .= "<p style='font-size:11px;'>Distribución: " . self::describeDistribution($event['winner_distribution']) . "</p>";
                $body .= "<p style='font-size:11px;color:#9ca3af;'>Reclama tu premio en el panel PvE.</p>";
            } else {
                $body .= "<p style='font-size:12px;'>Puntuación final: <b>" . number_format((float) $reg['pct_damage_total'], 2) . "%</b> del HP total</p>";
            }

            $body .= "</div>";

            self::sendMessageToAlly((int) $reg['ally_id'],
                $isWinner ? '?? Torneo finalizado — ¡Habéis ganado!' : '?? Torneo finalizado',
                $body);
        }
    }

    private static function notifyEventCancelled(int $eventId, array $event, string $reason, int $refundedCount): void
    {
        $db = Database::get();
        $regs = $db->select(
            "SELECT DISTINCT ally_id FROM %%PVE_BOSS_REGISTRATIONS%% WHERE event_id = :eid;",
            array(':eid' => $eventId)
        );
        if (!is_array($regs)) return;

        $body  = "<div style='padding:12px;background:#2e1a00;border-left:4px solid #ffaa33;border-radius:6px;'>";
        $body .= "<h2 style='color:#ffaa33;margin:0 0 10px;'>?? Torneo cancelado</h2>";
        $body .= "<p>Motivo: <b>" . htmlspecialchars($reason, ENT_QUOTES, 'UTF-8') . "</b></p>";
        if ($refundedCount > 0) {
            $body .= "<p style='color:#88ffbb;font-size:12px;'>Se han reembolsado a " . $refundedCount . " líderes en su riel.</p>";
        }
        $body .= "</div>";

        foreach ($regs as $r) {
            self::sendMessageToAlly((int) $r['ally_id'], '?? Torneo del Devorador cancelado', $body);
        }
    }

    // ---------------------------------------------------------------
    //  10. CRON
    // ---------------------------------------------------------------

    public static function cron(): void
    {
        if (!self::isEnabled()) return;

        try {
            // --- Auto-programación mensual ---
            try {
                self::autoScheduleIfNeeded();
            } catch (Throwable $eAuto) {
                PVEHelper::log(self::LOG_TYPE, 0, 'cron_auto_schedule_error', 0, 0, array(
                    'error' => $eAuto->getMessage(),
                    'file'  => $eAuto->getFile(),
                    'line'  => $eAuto->getLine(),
                ));
            }

            // --- Procesar evento activo ---
            $event = self::getActiveEvent();

            if (!empty($event)) {
                $now = TIMESTAMP;

                // 1. Scheduled ? registration
                if ($event['status'] === 'scheduled' && $now >= (int) $event['registration_start']) {
                    self::openRegistration((int) $event['id']);
                    $event = self::getEvent((int) $event['id']);
                }

                // 2. Registration ? active
                if (!empty($event) && $event['status'] === 'registration' && $now >= (int) $event['registration_end']) {
                    self::startEvent((int) $event['id']);
                    $event = self::getEvent((int) $event['id']);
                }

                // 3. Active ? procesar contraataques y respawn
                if (!empty($event) && $event['status'] === 'active') {
                    self::processCounterAttacks();
                    self::respawnGhosts();

                    if ($now >= (int) $event['end_time']) {
                        self::finishEvent((int) $event['id'], 'time');
                    }
                }
            }

            // -------------------------------------------------------
            // LIMPIEZA AUTOMÁTICA DEL TORNEO (2 capas)
            // -------------------------------------------------------
            try {
                self::cleanupOrphansBoss();
                self::cleanupDeepBoss(false);
            } catch (Throwable $eClean) {
                PVEHelper::log(self::LOG_TYPE, 0, 'cron_cleanup_boss_error', 0, 0, array(
                    'error' => $eClean->getMessage(),
                    'file'  => $eClean->getFile(),
                    'line'  => $eClean->getLine(),
                ));
            }

        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'cron_error', 0, 0, array(
                'error' => $e->getMessage(),
                'file'  => $e->getFile(),
                'line'  => $e->getLine(),
            ));
        }
    }

    // ---------------------------------------------------------------
    //  11. UTILIDADES
    // ---------------------------------------------------------------

    private static function countActiveMembers(int $allyId, int $hours = 24): int
    {
        $db = Database::get();
        $threshold = TIMESTAMP - ($hours * 3600);

        $count = (int) $db->selectSingle(
            "SELECT COUNT(*) AS c FROM %%USERS%%
             WHERE ally_id = :aid AND onlinetime >= :thr AND bana = 0;",
            array(':aid' => $allyId, ':thr' => $threshold),
            'c'
        );

        return max(1, $count);
    }

    private static function sendMessageToUser(int $userId, string $title, string $body): bool
    {
        try {
            PlayerUtil::sendMessage(
                $userId, 0, 'Torneo del Devorador', 3, $title, $body,
                TIMESTAMP, null, 1, PVEHelper::getUniverseForUser($userId)
            );
            return true;
        } catch (Throwable $e) {
            return false;
        }
    }

    private static function sendMessageToAlly(int $allyId, string $title, string $body): int
    {
        if ($allyId <= 0) return 0;

        $db = Database::get();
        $members = $db->select(
            "SELECT id FROM %%USERS%%
             WHERE ally_id = :aid AND bana = 0 AND universe = :uni;",
            array(':aid' => $allyId, ':uni' => PVEHelper::getUniverseForAlly($allyId))
        );
        if (!is_array($members)) return 0;

        $count = 0;
        foreach ($members as $m) {
            if (self::sendMessageToUser((int) $m['id'], $title, $body)) {
                $count++;
            }
        }
        return $count;
    }

    private static function describePrize(array $event): string
    {
        if ($event['entry_mode'] === 'paid') {
            $poolNtx  = (int) ($event['pool_ntx20']  ?? 0);
            $poolUntx = (int) ($event['pool_untx20'] ?? 0);
            return '?? Pool dual (' . $poolNtx . ' NTX + ' . $poolUntx . ' UNTX) - ' . (int) $event['project_fee_pct'] . '% fee';
        }

        $rewards = array();
        if ($event['prize_ntx'] > 0)         $rewards[] = number_format($event['prize_ntx']) . ' base NTX-20';
        if ($event['prize_metal'] > 0)       $rewards[] = number_format($event['prize_metal']) . ' Metal';
        if ($event['prize_crystal'] > 0)     $rewards[] = number_format($event['prize_crystal']) . ' Cristal';
        if ($event['prize_deuterium'] > 0)   $rewards[] = number_format($event['prize_deuterium']) . ' Deuterio';
        if ($event['prize_dark_matter'] > 0) $rewards[] = number_format($event['prize_dark_matter']) . ' Materia Oscura';

        if (empty($rewards)) {
            return 'Sin premio configurado';
        }

        return '?? ' . implode(' + ', $rewards);
    }

    private static function formatPrize(array $prize): string
    {
        if ($prize['type'] === 'ntx_dual') {
            $netNtx  = (int) ($prize['net']['ntx20']  ?? 0);
            $netUntx = (int) ($prize['net']['untx20'] ?? 0);
            return number_format($netNtx) . ' NTX-20 + ' . number_format($netUntx) . ' UNTX-20';
        }

        if ($prize['type'] === 'ntx' && !is_array($prize['net'])) {
            return number_format((int) $prize['net']) . ' NTX-20 (base)';
        }

        if (is_array($prize['net'])) {
            $parts = array();
            if (!empty($prize['net']['ntx']))         $parts[] = number_format((int)$prize['net']['ntx']) . ' base NTX-20';
            if (!empty($prize['net']['metal']))       $parts[] = number_format((int)$prize['net']['metal']) . ' Metal';
            if (!empty($prize['net']['crystal']))     $parts[] = number_format((int)$prize['net']['crystal']) . ' Cristal';
            if (!empty($prize['net']['deuterium']))   $parts[] = number_format((int)$prize['net']['deuterium']) . ' Deuterio';
            if (!empty($prize['net']['dark_matter'])) $parts[] = number_format((int)$prize['net']['dark_matter']) . ' Materia Oscura';
            return implode(' + ', $parts);
        }

        return 'Premio configurado';
    }

    private static function describeDistribution(string $mode): string
    {
        switch ($mode) {
            case 'leader':          return 'Todo al líder';
            case 'equal':           return 'Equitativo entre atacantes';
            case 'by_contribution':
            default:                return 'Proporcional al daño hecho';
        }
    }

    public static function cleanup(int $eventId): void
    {
        $db = Database::get();
        try {
            $db->delete(
                "DELETE fe FROM %%FLEETS_EVENT%% fe
                 LEFT JOIN %%FLEETS%% f ON f.fleet_id = fe.fleetID
                 WHERE f.fleet_id IS NULL;"
            );
        } catch (Throwable $e) {}
    }

    // ---------------------------------------------------------------
    //  12. LIMPIEZA AUTOMÁTICA (2 CAPAS)
    // ---------------------------------------------------------------

    public static function cleanupOrphansBoss(): array
    {
        $db = Database::get();

        $stats = array(
            'ghosts_destroyed'      => 0,
            'registrations_deleted' => 0,
            'damage_deleted'        => 0,
            'events_finished'       => 0,
            'fleets_deleted'        => 0,
        );

        try {
            // 1) Fantasmas de eventos cerrados
            $ghostsToKill = $db->select(
                "SELECT g.id, g.ghost_user_id
                 FROM %%PVE_BOSS_GHOSTS%% g
                 INNER JOIN %%PVE_BOSS_EVENT%% e ON e.id = g.event_id
                 WHERE g.status = 'active'
                   AND e.status IN ('cancelled','finished')
                 LIMIT 50;"
            );

            if (is_array($ghostsToKill)) {
                foreach ($ghostsToKill as $g) {
                    try {
                        PVEGhostHelper::destroyGhostByUserId((int) $g['ghost_user_id']);
                    } catch (Throwable $e) {}

                    $db->update(
                        "UPDATE %%PVE_BOSS_GHOSTS%% SET
                            status       = 'destroyed',
                            destroyed_at = :now
                         WHERE id = :id;",
                        array(':now' => TIMESTAMP, ':id' => (int) $g['id'])
                    );
                    $stats['ghosts_destroyed']++;
                }
            }

            // 2) Registrations sin evento padre
            $db->delete(
                "DELETE r FROM %%PVE_BOSS_REGISTRATIONS%% r
                 LEFT JOIN %%PVE_BOSS_EVENT%% e ON e.id = r.event_id
                 WHERE e.id IS NULL"
            );
            $stats['registrations_deleted'] = $db->rowCount();

            // 3) Damage sin evento padre
            $db->delete(
                "DELETE d FROM %%PVE_BOSS_DAMAGE%% d
                 LEFT JOIN %%PVE_BOSS_EVENT%% e ON e.id = d.event_id
                 WHERE e.id IS NULL"
            );
            $stats['damage_deleted'] = $db->rowCount();

            // 4) Eventos zombie
            $zombies = $db->select(
                "SELECT e.id FROM %%PVE_BOSS_EVENT%% e
                 WHERE e.status = 'active'
                   AND e.end_time <= :now
                   AND NOT EXISTS (
                       SELECT 1 FROM %%PVE_BOSS_GHOSTS%% g
                       WHERE g.event_id = e.id AND g.status = 'active'
                   )
                 LIMIT 10;",
                array(':now' => TIMESTAMP)
            );

            if (is_array($zombies)) {
                foreach ($zombies as $z) {
                    $zid = (int) $z['id'];
                    $db->update(
                        "UPDATE %%PVE_BOSS_EVENT%% SET
                            status      = 'finished',
                            finished_at = :now
                         WHERE id = :id AND status = 'active';",
                        array(':now' => TIMESTAMP, ':id' => $zid)
                    );
                    if ($db->rowCount() > 0) {
                        $stats['events_finished']++;
                    }
                }
            }

            // 5) Flotas del boss atascadas (mission=23, >1h sin llegar)
            // [v3.8] Si la flota es de un jugador real (no del fantasma),
            // devolver sus naves y carga al planeta de origen antes de
            // borrar: un DELETE directo DESTRUIA las naves para siempre.
            $limitTime = TIMESTAMP - 3600;
            $stuckFleets = $db->select(
                "SELECT * FROM %%FLEETS%%
                 WHERE fleet_mission = :mission
                   AND fleet_end_time < :limit
                   AND fleet_mess = 0;",
                array(':mission' => 23, ':limit' => $limitTime)
            );
            if (is_array($stuckFleets)) {
                global $resource;
                foreach ($stuckFleets as $f) {
                    if ((int) $f['fleet_owner'] >= 900000000) continue; // fantasma: nada que devolver
                    try {
                        $units = FleetFunctions::unserialize($f['fleet_array']);
                        $params = array(':pid' => (int) $f['fleet_start_id']);
                        $sets   = array();
                        if (is_array($units)) {
                            foreach ($units as $elementId => $amount) {
                                $amount = (int) $amount;
                                if ($amount <= 0 || !isset($resource[$elementId])) continue;
                                $col = $resource[$elementId];
                                $sets[] = "`{$col}` = `{$col}` + :n_{$elementId}";
                                $params[":n_{$elementId}"] = $amount;
                            }
                        }
                        foreach (array('fleet_resource_metal' => 901, 'fleet_resource_crystal' => 902, 'fleet_resource_deuterium' => 903) as $fCol => $resId) {
                            $cargo = (float) $f[$fCol];
                            if ($cargo > 0) {
                                $col = $resource[$resId];
                                $sets[] = "`{$col}` = `{$col}` + :r_{$resId}";
                                $params[":r_{$resId}"] = $cargo;
                            }
                        }
                        if (!empty($sets)) {
                            $db->update(
                                "UPDATE %%PLANETS%% SET " . implode(', ', $sets) . " WHERE id = :pid;",
                                $params
                            );
                        }
                    } catch (Throwable $eRescue) {
                        PVEHelper::log(self::LOG_TYPE, 0, 'cleanup_fleet_rescue_error', (int) $f['fleet_owner'], 0, array(
                            'fleet_id' => (int) $f['fleet_id'],
                            'error'    => $eRescue->getMessage(),
                        ));
                    }
                }
            }

            $db->delete(
                "DELETE FROM %%FLEETS%%
                 WHERE fleet_mission = :mission
                   AND fleet_end_time < :limit
                   AND fleet_mess = 0;",
                array(':mission' => 23, ':limit' => $limitTime)
            );
            $stats['fleets_deleted'] = $db->rowCount();

            $total = array_sum($stats);
            if ($total > 0) {
                PVEHelper::log(self::LOG_TYPE, 0, 'cleanup_orphans_boss', 0, 0, $stats);
            }
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'cleanup_orphans_boss_error', 0, 0, array(
                'error' => $e->getMessage(),
                'file'  => $e->getFile(),
                'line'  => $e->getLine(),
            ));
        }

        return $stats;
    }

    public static function cleanupDeepBoss($forceRun = false): array
    {
        $db = Database::get();

        $stats = array(
            'ghosts_deleted'        => 0,
            'damage_deleted'        => 0,
            'registrations_deleted' => 0,
            'events_deleted'        => 0,
        );

        // [v3.8] Persistido en pve_config: antes $_SESSION (no existe en el
        // cron CLI) -> la limpieza profunda corria en cada tick.
        $cacheKey = 'pve_boss_cleanup_deep_last';
        $lastRun  = (int) PVEHelper::get($cacheKey, 0);

        if (!$forceRun && (TIMESTAMP - $lastRun) < 86400) {
            return $stats;
        }

        $daysOld = 30;

        try {
            $db->delete(
                "DELETE FROM %%PVE_BOSS_GHOSTS%%
                 WHERE status IN ('killed','destroyed')
                   AND spawned_at < :limit;",
                array(':limit' => TIMESTAMP - ($daysOld * 86400))
            );
            $stats['ghosts_deleted'] = $db->rowCount();

            $db->delete(
                "DELETE FROM %%PVE_BOSS_DAMAGE%%
                 WHERE first_hit < :limit;",
                array(':limit' => TIMESTAMP - ($daysOld * 86400))
            );
            $stats['damage_deleted'] = $db->rowCount();

            $db->delete(
                "DELETE FROM %%PVE_BOSS_REGISTRATIONS%%
                 WHERE registered_at < :limit;",
                array(':limit' => TIMESTAMP - ($daysOld * 86400))
            );
            $stats['registrations_deleted'] = $db->rowCount();

            $db->delete(
                "DELETE FROM %%PVE_BOSS_EVENT%%
                 WHERE status IN ('finished','cancelled')
                   AND end_time < :limit;",
                array(':limit' => TIMESTAMP - ($daysOld * 86400))
            );
            $stats['events_deleted'] = $db->rowCount();

            // [v3.8] Guardar en pve_config (mismo patron que markAsScheduledThisMonth)
            $cfgRow = $db->selectSingle(
                "SELECT id FROM %%PVE_CONFIG%% WHERE config_key = :key LIMIT 1;",
                array(':key' => $cacheKey)
            );
            if (!empty($cfgRow)) {
                $db->update(
                    "UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = :key;",
                    array(':val' => (string) TIMESTAMP, ':now' => TIMESTAMP, ':key' => $cacheKey)
                );
            } else {
                $db->insert(
                    "INSERT INTO %%PVE_CONFIG%% SET config_key = :key, config_value = :val, updated_at = :now;",
                    array(':key' => $cacheKey, ':val' => (string) TIMESTAMP, ':now' => TIMESTAMP)
                );
            }
            PVEHelper::clearConfigCache();

            PVEHelper::log(self::LOG_TYPE, 0, 'cleanup_deep_boss_done', 0, 0, $stats);
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'cleanup_deep_boss_error', 0, 0, array(
                'error' => $e->getMessage(),
                'file'  => $e->getFile(),
                'line'  => $e->getLine(),
            ));
        }

        return $stats;
    }

    // ---------------------------------------------------------------
    //  13. AUTO-PROGRAMACIÓN MENSUAL
    // ---------------------------------------------------------------

    public static function isAutoScheduleEnabled(): bool
    {
        return (int) PVEHelper::get('boss_auto_schedule_enabled', 0) === 1;
    }

    public static function getScheduleConfig(): array
    {
        $day    = max(1, min(28, (int) PVEHelper::get('boss_schedule_day', 15)));
        $hour   = max(0, min(23, (int) PVEHelper::get('boss_schedule_hour', 20)));
        $minute = max(0, min(59, (int) PVEHelper::get('boss_schedule_minute', 0)));

        return array(
            'enabled'        => self::isAutoScheduleEnabled() ? 1 : 0,
            'day'            => $day,
            'hour'           => $hour,
            'minute'         => $minute,
            'last_month'     => (int) PVEHelper::get('boss_schedule_last_month', 0),
            'next_scheduled' => self::getScheduledTimeForCurrentMonth($day, $hour, $minute),
        );
    }

    public static function autoScheduleIfNeeded(): bool
    {
        if (!self::isAutoScheduleEnabled()) {
            return false;
        }

        $existing = self::getActiveEvent();
        if (!empty($existing)) {
            return false;
        }

        $day    = max(1, min(28, (int) PVEHelper::get('boss_schedule_day', 15)));
        $hour   = max(0, min(23, (int) PVEHelper::get('boss_schedule_hour', 20)));
        $minute = max(0, min(59, (int) PVEHelper::get('boss_schedule_minute', 0)));

        $currentYearMonth = (int) date('Ym', TIMESTAMP);
        $lastMonth        = (int) PVEHelper::get('boss_schedule_last_month', 0);

        if ($lastMonth === $currentYearMonth) {
            return false;
        }

        $scheduledTime = self::getScheduledTimeForCurrentMonth($day, $hour, $minute);
        if ($scheduledTime <= 0) {
            return false;
        }

        if (TIMESTAMP < $scheduledTime) {
            return false;
        }

        $params = array(
            'boss_name'              => (string) PVEHelper::get('boss_default_name', 'El Devorador Estelar'),
            'entry_mode'             => (string) PVEHelper::get('boss_default_entry_mode', 'free'),
            'entry_cost_ntx'         => (int) PVEHelper::get('boss_default_entry_cost_ntx', 50),
            'prize_type'             => (string) PVEHelper::get('boss_default_prize_type', 'ntx'),
            'prize_ntx'              => (int) PVEHelper::get('boss_default_prize_ntx', 500),
            'prize_metal'            => (int) PVEHelper::get('boss_default_prize_metal', 100000000),
            'prize_crystal'          => (int) PVEHelper::get('boss_default_prize_crystal', 50000000),
            'prize_deuterium'        => (int) PVEHelper::get('boss_default_prize_deuterium', 20000000),
            'prize_dark_matter'      => (int) PVEHelper::get('boss_default_prize_dark_matter', 50000),
            'prize_scales_with_allies' => 0,
            'project_fee_pct'        => (int) PVEHelper::get('boss_project_fee_pct', 5),
            'winner_distribution'    => (string) PVEHelper::get('boss_winner_distribution', 'by_contribution'),
            'min_alliances'          => (int) PVEHelper::get('boss_min_alliances', 2),
            'max_alliances'          => (int) PVEHelper::get('boss_max_alliances', 20),
            'hp_per_member'          => (int) PVEHelper::get('boss_hp_per_member', 500000),
            'hp_min'                 => (int) PVEHelper::get('boss_hp_min', 10000000),
            'duration_hours'         => (int) PVEHelper::get('boss_duration_hours', 48),
            'registration_hours'     => (int) PVEHelper::get('boss_registration_hours', 24),
            'schedule_start_time'    => $scheduledTime,
        );

        try {
            $result = self::createEvent($params);

            if (empty($result['ok'])) {
                PVEHelper::log(self::LOG_TYPE, 0, 'auto_schedule_create_failed', 0, 0, array(
                    'error'     => $result['error'] ?? 'unknown',
                    'scheduled' => $scheduledTime,
                    'month'     => $currentYearMonth,
                ));
                return false;
            }

            $eventId = (int) $result['event_id'];

            self::markAsScheduledThisMonth($currentYearMonth);

            PVEHelper::log(self::LOG_TYPE, $eventId, 'auto_scheduled', 0, 0, array(
                'month'      => $currentYearMonth,
                'day'        => $day,
                'hour'       => $hour,
                'minute'     => $minute,
                'start_time' => $scheduledTime,
                'reg_start'  => $scheduledTime - ($params['registration_hours'] * 3600),
                'reg_end'    => $scheduledTime,
                'end_time'   => $scheduledTime + ($params['duration_hours'] * 3600),
            ));

            return true;
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'auto_schedule_exception', 0, 0, array(
                'error' => $e->getMessage(),
                'file'  => $e->getFile(),
                'line'  => $e->getLine(),
            ));
            return false;
        }
    }

    private static function getScheduledTimeForCurrentMonth(int $day, int $hour, int $minute): int
    {
        $day    = max(1, min(28, $day));
        $hour   = max(0, min(23, $hour));
        $minute = max(0, min(59, $minute));

        $year  = (int) date('Y', TIMESTAMP);
        $month = (int) date('n', TIMESTAMP);

        $ts = mktime($hour, $minute, 0, $month, $day, $year);

        return ($ts === false) ? 0 : (int) $ts;
    }

    private static function markAsScheduledThisMonth(int $yearMonth): void
    {
        $db = Database::get();

        $existing = $db->selectSingle(
            "SELECT id FROM %%PVE_CONFIG%%
             WHERE config_key = 'boss_schedule_last_month'
             LIMIT 1;"
        );

        if (!empty($existing)) {
            $db->update(
                "UPDATE %%PVE_CONFIG%%
                 SET config_value = :val, updated_at = :now
                 WHERE config_key = :key;",
                array(
                    ':val' => (string) $yearMonth,
                    ':now' => TIMESTAMP,
                    ':key' => 'boss_schedule_last_month',
                )
            );
        } else {
            $db->insert(
                "INSERT INTO %%PVE_CONFIG%% SET
                    config_key   = :key,
                    config_value = :val,
                    updated_at   = :now;",
                array(
                    ':key' => 'boss_schedule_last_month',
                    ':val' => (string) $yearMonth,
                    ':now' => TIMESTAMP,
                )
            );
        }

        PVEHelper::clearConfigCache();
    }

    /* ============================================================
     *  CHECKBOX REACTIVO
     * ============================================================ */

    public static function getNextScheduledTime(int $day, int $hour, int $minute): int
    {
        $day    = max(1, min(28, $day));
        $hour   = max(0, min(23, $hour));
        $minute = max(0, min(59, $minute));

        $year  = (int) date('Y', TIMESTAMP);
        $month = (int) date('n', TIMESTAMP);

        $ts = mktime($hour, $minute, 0, $month, $day, $year);

        if ($ts !== false && $ts > TIMESTAMP) {
            return (int) $ts;
        }

        $nextMonth = $month + 1;
        $nextYear  = $year;
        if ($nextMonth > 12) {
            $nextMonth = 1;
            $nextYear++;
        }

        $ts = mktime($hour, $minute, 0, $nextMonth, $day, $nextYear);
        return ($ts === false) ? 0 : (int) $ts;
    }

    public static function forceAutoScheduleNow(): array
    {
        $existing = self::getActiveEvent();
        if (!empty($existing)) {
            return array(
                'ok'    => false,
                'error' => 'Ya hay un torneo programado o activo (#' . $existing['id'] . ').',
            );
        }

        $day    = max(1, min(28, (int) PVEHelper::get('boss_schedule_day', 15)));
        $hour   = max(0, min(23, (int) PVEHelper::get('boss_schedule_hour', 20)));
        $minute = max(0, min(59, (int) PVEHelper::get('boss_schedule_minute', 0)));

        $scheduledTime = self::getNextScheduledTime($day, $hour, $minute);
        if ($scheduledTime <= 0) {
            return array('ok' => false, 'error' => 'No se pudo calcular la próxima fecha programada.');
        }

        $params = array(
            'boss_name'                => (string) PVEHelper::get('boss_default_name', 'El Devorador Estelar'),
            'entry_mode'               => (string) PVEHelper::get('boss_default_entry_mode', 'free'),
            'entry_cost_ntx'           => (int) PVEHelper::get('boss_default_entry_cost_ntx', 50),
            'prize_type'               => (string) PVEHelper::get('boss_default_prize_type', 'ntx'),
            'prize_ntx'                => (int) PVEHelper::get('boss_default_prize_ntx', 500),
            'prize_metal'              => (int) PVEHelper::get('boss_default_prize_metal', 100000000),
            'prize_crystal'            => (int) PVEHelper::get('boss_default_prize_crystal', 50000000),
            'prize_deuterium'          => (int) PVEHelper::get('boss_default_prize_deuterium', 20000000),
            'prize_dark_matter'        => (int) PVEHelper::get('boss_default_prize_dark_matter', 50000),
            'prize_scales_with_allies' => 0,
            'project_fee_pct'          => (int) PVEHelper::get('boss_project_fee_pct', 5),
            'winner_distribution'      => (string) PVEHelper::get('boss_winner_distribution', 'by_contribution'),
            'min_alliances'            => (int) PVEHelper::get('boss_min_alliances', 2),
            'max_alliances'            => (int) PVEHelper::get('boss_max_alliances', 20),
            'hp_per_member'            => (int) PVEHelper::get('boss_hp_per_member', 500000),
            'hp_min'                   => (int) PVEHelper::get('boss_hp_min', 10000000),
            'duration_hours'           => (int) PVEHelper::get('boss_duration_hours', 48),
            'registration_hours'       => (int) PVEHelper::get('boss_registration_hours', 24),
            'schedule_start_time'      => $scheduledTime,
        );

        try {
            $result = self::createEvent($params);

            if (empty($result['ok'])) {
                return array(
                    'ok'    => false,
                    'error' => !empty($result['error']) ? $result['error'] : 'No se pudo crear el evento.',
                );
            }

            $eventId = (int) $result['event_id'];

            $scheduledYM = (int) date('Ym', $scheduledTime);
            self::markAsScheduledThisMonth($scheduledYM);

            PVEHelper::log(self::LOG_TYPE, $eventId, 'force_scheduled_by_admin', 0, 0, array(
                'scheduled' => $scheduledTime,
                'month'     => $scheduledYM,
                'day'       => $day,
                'hour'      => $hour,
                'minute'    => $minute,
            ));

            return array(
                'ok'         => true,
                'event_id'   => $eventId,
                'start_time' => $scheduledTime,
            );
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'force_schedule_exception', 0, 0, array(
                'error' => $e->getMessage(),
                'file'  => $e->getFile(),
                'line'  => $e->getLine(),
            ));
            return array('ok' => false, 'error' => $e->getMessage());
        }
    }

    public static function cancelScheduledEvents(): array
    {
        $db = Database::get();

        try {
            $scheduled = $db->select(
                "SELECT id FROM %%PVE_BOSS_EVENT%% WHERE status = 'scheduled';"
            );

            if (!is_array($scheduled) || count($scheduled) === 0) {
                self::resetLastScheduledMonth();
                return array('ok' => true, 'cancelled' => 0);
            }

            $now   = TIMESTAMP;
            $count = 0;

            foreach ($scheduled as $row) {
                $db->update(
                    "UPDATE %%PVE_BOSS_EVENT%% SET
                        status        = 'cancelled',
                        cancelled_at  = :now,
                        cancel_reason = 'auto_schedule_disabled'
                     WHERE id = :id AND status = 'scheduled';",
                    array(':now' => $now, ':id' => (int) $row['id'])
                );
                $count++;
            }

            self::resetLastScheduledMonth();

            PVEHelper::log(self::LOG_TYPE, 0, 'scheduled_cancelled_by_admin', 0, 0, array(
                'cancelled' => $count,
            ));

            return array('ok' => true, 'cancelled' => $count);
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, 0, 'cancel_scheduled_exception', 0, 0, array(
                'error' => $e->getMessage(),
                'file'  => $e->getFile(),
                'line'  => $e->getLine(),
            ));
            return array('ok' => false, 'error' => $e->getMessage(), 'cancelled' => 0);
        }
    }

    private static function resetLastScheduledMonth(): void
    {
        $db = Database::get();

        $existing = $db->selectSingle(
            "SELECT id FROM %%PVE_CONFIG%%
             WHERE config_key = 'boss_schedule_last_month' LIMIT 1;"
        );

        if (!empty($existing)) {
            $db->update(
                "UPDATE %%PVE_CONFIG%%
                 SET config_value = '0', updated_at = :now
                 WHERE config_key = 'boss_schedule_last_month';",
                array(':now' => TIMESTAMP)
            );
        }

        PVEHelper::clearConfigCache();
    }
}