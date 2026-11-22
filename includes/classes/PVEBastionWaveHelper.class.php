<?php

/**
 * AstroIO — PVEBastionWaveHelper
 *
 * Motor de oleadas piratas del BASTIÓN ASEDIADO.
 *
 * Responsabilidades:
 *   - Generar oleadas piratas (según fase por tiempo transcurrido)
 *   - Construir la composición de cada oleada (con multiplicador por fase)
 *   - Enviar la flota pirata real (misión 25) al Bastión
 *   - Resolver la batalla cuando la flota pirata llega
 *   - Aplicar daño al HP del Bastión (via PVEBastionHelper)
 *   - Atribuir bajas / kills a cada jugador que reforzó
 *   - Disparar acumuladores globales y logros vía PVEAchievementHelper
 *
 * Reutiliza: PVEBastionHelper, PVEGhostHelper, PVEHelper, PVEAchievementHelper.
 *
 * Ubicación: includes/classes/PVEBastionWaveHelper.class.php
 * @package AstroIO
 * @subpackage PvE
 * @version 1.1
 */

if (!defined('ROOT_PATH')) {
    exit('Access denied');
}

if (!class_exists('PVEHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVEBastionHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEBastionHelper.class.php';
}
if (!class_exists('PVEGhostHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';
}
if (!class_exists('PVEAchievementHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEAchievementHelper.class.php';
}

class PVEBastionWaveHelper
{
    const LOG_TYPE = 'bastion';

    /** ID de misión de los piratas (debe coincidir con MISSION_PIRATE_ATTACK) */
    const PIRATE_MISSION = 25;

    /** Coordenadas de origen de los piratas */
    const PIRATE_ORIGIN_GALAXY = 99;
    const PIRATE_ORIGIN_SYSTEM = 99;
    const PIRATE_ORIGIN_PLANET = 99;

    /* ============================================================
     *  1. GENERACIÓN DE OLEADAS (llamado desde cron)
     * ============================================================ */

    /**
     * Procesa las oleadas programadas para todas las registraciones activas.
     * Se llama desde PVEBastionHelper::cron() cada 5 min.
     *
     * @return array  Estadísticas: waves_created, waves_skipped, errors
     */
    public static function processScheduledWaves(int $eventId): array
    {
        $db = Database::get();
        $stats = array('waves_created' => 0, 'waves_skipped' => 0, 'errors' => 0);

        $event = PVEBastionHelper::getEvent($eventId);
        if (empty($event) || $event['status'] !== 'active') {
            return $stats;
        }

        $now = TIMESTAMP;

        // Cargar bastiones activos con next_wave_at vencido
        $ghosts = $db->select(
            "SELECT g.*, r.ally_id, r.id AS reg_id, r.status AS reg_status
             FROM %%PVE_BASTION_GHOSTS%% g
             INNER JOIN %%PVE_BASTION_REGISTRATIONS%% r ON r.id = g.registration_id
             WHERE g.event_id = :eid
               AND g.status = 'active'
               AND r.status = 'active'
               AND g.next_wave_at IS NOT NULL
               AND g.next_wave_at <= :now
             ORDER BY g.next_wave_at ASC
             LIMIT 20;",
            array(':eid' => $eventId, ':now' => $now)
        );

        if (!is_array($ghosts) || count($ghosts) === 0) {
            return $stats;
        }

        foreach ($ghosts as $ghost) {
            try {
                // Fase por tiempo transcurrido desde el inicio del evento
                $phase = self::determinePhase($event, $now);

                // Siguiente número de oleada para este bastión
                $lastWave = $db->selectSingle(
                    "SELECT MAX(wave_number) AS last FROM %%PVE_BASTION_WAVES%%
                     WHERE registration_id = :rid;",
                    array(':rid' => (int) $ghost['registration_id']),
                    'last'
                );
                $nextWaveNum = ((int) $lastWave) + 1;

                // ¿Oleada boss?
                $isBoss = self::rollBossWave($phase);

                // Composición pirata
                $fleet = self::buildPirateFleet($event, $phase, $isBoss);
                $totalShips = is_array($fleet) ? array_sum($fleet) : 0;

                if ($totalShips <= 0) {
                    // Reintentar en 5 min (no hay composición válida)
                    $db->update(
                        "UPDATE %%PVE_BASTION_GHOSTS%% SET next_wave_at = :next WHERE id = :id;",
                        array(':next' => $now + 300, ':id' => (int) $ghost['id'])
                    );
                    $stats['waves_skipped']++;
                    continue;
                }

                // Tiempo de vuelo aleatorio
                $flightMin = random_int(
                    max(1, (int) PVEHelper::get('bastion_pirate_flight_min', 30)),
                    max(1, (int) PVEHelper::get('bastion_pirate_flight_max', 90))
                );
                $arrivalTime = $now + ($flightMin * 60);

                // Crear row de wave (pending)
                $db->insert(
                    "INSERT INTO %%PVE_BASTION_WAVES%% SET
                        event_id        = :eid,
                        registration_id = :rid,
                        ally_id         = :aid,
                        wave_number     = :wn,
                        phase           = :phase,
                        fleet_json      = :fleet,
                        total_ships     = :ts,
                        is_boss_wave    = :boss,
                        spawn_time      = :now,
                        arrival_time    = :arr,
                        resolved        = 0,
                        result          = 'pending',
                        created_at      = :now;",
                    array(
                        ':eid'   => $eventId,
                        ':rid'   => (int) $ghost['registration_id'],
                        ':aid'   => (int) $ghost['ally_id'],
                        ':wn'    => $nextWaveNum,
                        ':phase' => $phase,
                        ':fleet' => json_encode($fleet),
                        ':ts'    => $totalShips,
                        ':boss'  => $isBoss ? 1 : 0,
                        ':now'   => $now,
                        ':arr'   => $arrivalTime,
                    )
                );

                $waveId = (int) $db->lastInsertId();

                if ($waveId <= 0) {
                    $stats['errors']++;
                    continue;
                }

                // Enviar la flota pirata real (misión 25)
                $fleetId = self::sendPirateFleet($event, $ghost, $waveId, $fleet, $arrivalTime);

                if ($fleetId > 0) {
                    $stats['waves_created']++;

                    // Programar la SIGUIENTE oleada
                    $intervalMin = self::getPhaseIntervalMin($phase);
                    $db->update(
                        "UPDATE %%PVE_BASTION_GHOSTS%% SET
                            next_wave_at = :next,
                            phase        = :phaseNew
                         WHERE id = :id;",
                        array(
                            ':next'     => $now + ($intervalMin * 60),
                            ':phaseNew' => self::phaseToNumber($phase),
                            ':id'       => (int) $ghost['id'],
                        )
                    );

                    // Contador global del evento
                    // ★ v1.1 — Fix: antes era un no-op (SET x = x). Ahora incrementa correctamente.
                    $db->update(
                        "UPDATE %%PVE_BASTION_EVENT%% SET
                            total_waves_resolved = total_waves_resolved + 1
                         WHERE id = :id;",
                        array(':id' => $eventId)
                    );

                    PVEHelper::log(self::LOG_TYPE, $eventId, 'wave_spawned', 0, 0, array(
                        'wave_id'     => $waveId,
                        'wave_number' => $nextWaveNum,
                        'phase'       => $phase,
                        'is_boss'     => $isBoss ? 1 : 0,
                        'ships'       => $totalShips,
                        'fleet_id'    => $fleetId,
                        'arrival'     => $arrivalTime,
                    ));
                } else {
                    // No se pudo enviar la flota — marcar como fallida
                    $db->update(
                        "UPDATE %%PVE_BASTION_WAVES%% SET
                            resolved    = 1,
                            result      = 'pending',
                            resolved_at = :now
                         WHERE id = :id;",
                        array(':now' => $now, ':id' => $waveId)
                    );
                    $stats['errors']++;

                    PVEHelper::log(self::LOG_TYPE, $eventId, 'wave_send_failed', 0, 0, array(
                        'wave_id' => $waveId,
                    ));
                }

            } catch (Throwable $e) {
                PVEHelper::log(self::LOG_TYPE, $eventId, 'wave_process_error', 0, 0, array(
                    'ghost_id' => (int) $ghost['id'],
                    'error'    => $e->getMessage(),
                ));
                $stats['errors']++;
            }
        }

        return $stats;
    }

    /* ============================================================
     *  2. RESOLUCIÓN DE OLEADAS (llamado al llegar la flota pirata)
     * ============================================================ */

    /**
     * Resuelve la llegada de una oleada pirata al Bastión.
     * Llamado desde MissionCasePirateAttack::TargetEvent().
     *
     * @param int   $waveId    ID de la wave en uni1_pve_bastion_waves
     * @param array $pirateFleet  Flota pirata completa (fleet_array deserializado)
     * @return array  Resultado: ok, result ('defended'|'breached'|'partial'),
     *                pirates_killed, pirates_survived, damage_to_bastion
     */
    public static function resolveWaveArrival(int $waveId, array $pirateFleet): array
    {
        $result = array(
            'ok'                => false,
            'result'            => 'pending',
            'pirates_killed'    => 0,
            'pirates_survived'  => 0,
            'damage_to_bastion' => 0,
            'breached'          => false,
        );

        if ($waveId <= 0) return $result;

        $db = Database::get();

        // Cargar wave
        $wave = $db->selectSingle(
            "SELECT * FROM %%PVE_BASTION_WAVES%% WHERE id = :id LIMIT 1;",
            array(':id' => $waveId)
        );

        if (empty($wave)) return $result;
        if ((int) $wave['resolved'] === 1) {
            // Ya resuelta (idempotencia)
            $result['ok'] = true;
            $result['result'] = $wave['result'];
            return $result;
        }

        $event = PVEBastionHelper::getEvent((int) $wave['event_id']);
        if (empty($event)) return $result;

        // Cargar bastión
        $ghost = $db->selectSingle(
            "SELECT * FROM %%PVE_BASTION_GHOSTS%%
             WHERE event_id = :eid AND registration_id = :rid
             ORDER BY id DESC LIMIT 1;",
            array(':eid' => (int) $wave['event_id'], ':rid' => (int) $wave['registration_id'])
        );

        if (empty($ghost)) {
            // El bastión ya no existe — marcar wave como cancelada
            $db->update(
                "UPDATE %%PVE_BASTION_WAVES%% SET
                    resolved    = 1,
                    result      = 'partial',
                    resolved_at = :now
                 WHERE id = :id;",
                array(':now' => TIMESTAMP, ':id' => $waveId)
            );
            $result['ok'] = true;
            return $result;
        }

        if ($ghost['status'] === 'breached' || $ghost['status'] === 'destroyed') {
            // El bastión ya cayó — la oleada es irrelevante
            $db->update(
                "UPDATE %%PVE_BASTION_WAVES%% SET
                    resolved    = 1,
                    result      = 'breached',
                    resolved_at = :now
                 WHERE id = :id;",
                array(':now' => TIMESTAMP, ':id' => $waveId)
            );
            $result['ok'] = true;
            $result['result'] = 'breached';
            return $result;
        }

        // Cargar el planeta del bastión (defensas + guarnición + refuerzos)
        $planetId = (int) $ghost['ghost_planet_id'];
        $planet = $db->selectSingle(
            "SELECT * FROM %%PLANETS%% WHERE id = :pid LIMIT 1;",
            array(':pid' => $planetId)
        );

        if (empty($planet)) {
            $db->update(
                "UPDATE %%PVE_BASTION_WAVES%% SET
                    resolved    = 1,
                    result      = 'partial',
                    resolved_at = :now
                 WHERE id = :id;",
                array(':now' => TIMESTAMP, ':id' => $waveId)
            );
            $result['ok'] = true;
            return $result;
        }

        // ═══════════════════════════════════════════════════════════
        // RESOLVER COMBATE
        // ═══════════════════════════════════════════════════════════
        $combat = self::runCombat($pirateFleet, $planet);

        $piratesKilled    = (int) $combat['attacker_lost'];
        $piratesSurvived  = (int) $combat['attacker_survived'];
        $defendersLost    = (int) $combat['defender_lost'];

        // Daño al HP del Bastión = coste de piratas supervivientes × 0.5
        $damageToBastion = self::calculateDamageToBastion($pirateFleet, $combat['attacker_survivor_units']);

        // Aplicar daño al HP del bastión
        $applyResult = PVEBastionHelper::applyPirateDamageToBastion((int) $ghost['id'], $damageToBastion);

        $result['ok']                = true;
        $result['pirates_killed']    = $piratesKilled;
        $result['pirates_survived']  = $piratesSurvived;
        $result['damage_to_bastion'] = $damageToBastion;
        $result['breached']          = !empty($applyResult['breached']);

        // Determinar resultado
        if (!empty($applyResult['breached'])) {
            $result['result'] = 'breached';
        } elseif ($piratesSurvived <= 0 && $piratesKilled > 0) {
            $result['result'] = 'defended';
        } elseif ($piratesKilled > 0) {
            $result['result'] = 'partial';
        } else {
            $result['result'] = 'breached';
        }

        // ═══════════════════════════════════════════════════════════
        // ATRIBUIR KILLS Y PÉRDIDAS A CADA JUGADOR REFORZADO
        // ═══════════════════════════════════════════════════════════
        self::distributeWaveOutcome(
            (int) $wave['event_id'],
            (int) $wave['registration_id'],
            $piratesKilled,
            $piratesSurvived,
            $defendersLost,
            (int) $wave['is_boss_wave'] === 1
        );

        // ═══════════════════════════════════════════════════════════
        // ACTUALIZAR WAVE
        // ═══════════════════════════════════════════════════════════
        $db->update(
            "UPDATE %%PVE_BASTION_WAVES%% SET
                resolved             = 1,
                result               = :res,
                pirates_killed       = :pk,
                pirates_survived     = :ps,
                damage_to_bastion    = :dmg,
                resolved_at          = :now
             WHERE id = :id;",
            array(
                ':res' => $result['result'],
                ':pk'  => $piratesKilled,
                ':ps'  => $piratesSurvived,
                ':dmg' => $damageToBastion,
                ':now' => TIMESTAMP,
                ':id'  => $waveId,
            )
        );

        // Recalcular scores de todo el evento
        PVEBastionHelper::recomputeAllScores((int) $wave['event_id']);

        // Notificar a la alianza
        self::notifyWaveResolved($event, $wave, $ghost, $result);

        PVEHelper::log(self::LOG_TYPE, (int) $wave['event_id'], 'wave_resolved', 0, 0, array(
            'wave_id'        => $waveId,
            'result'         => $result['result'],
            'phase'          => $wave['phase'],
            'is_boss'        => (int) $wave['is_boss_wave'],
            'pirates_killed' => $piratesKilled,
            'pirates_alive'  => $piratesSurvived,
            'defenders_lost' => $defendersLost,
            'damage'         => $damageToBastion,
            'breached'       => $result['breached'] ? 1 : 0,
        ));

        return $result;
    }

    /* ============================================================
     *  3. COMBATE (motor nativo xnova)
     * ============================================================ */

    private static function runCombat(array $pirateFleet, array $bastionPlanet): array
    {
        global $reslist, $resource, $pricelist;
        $config = Config::get();

        // Construir atacantes (piratas)
        $attackerUnits = array();
        foreach ($pirateFleet as $shipId => $count) {
            $shipId = (int) $shipId;
            $count  = (int) $count;
            if ($shipId > 0 && $count > 0) {
                $attackerUnits[$shipId] = $count;
            }
        }

        // Construir defensor (bastión: defensas + naves)
        $defenderUnits = array();
        foreach (array_merge($reslist['fleet'], $reslist['defense']) as $elementId) {
            $colName = isset($resource[$elementId]) ? $resource[$elementId] : '';
            if ($colName === '') continue;
            $amount = isset($bastionPlanet[$colName]) ? (int) $bastionPlanet[$colName] : 0;
            if ($amount > 0) $defenderUnits[$elementId] = $amount;
        }

        $initialAttacker = $attackerUnits;
        $initialDefender = $defenderUnits;

        if (empty($attackerUnits) || empty($defenderUnits)) {
            // Sin combate real
            return array(
                'attacker_lost'           => 0,
                'attacker_survived'       => array_sum($attackerUnits),
                'attacker_survivor_units' => $attackerUnits,
                'defender_lost'           => 0,
                'defender_survived'       => array_sum($defenderUnits),
                'defender_survivor_units' => $defenderUnits,
                'won'                     => empty($defenderUnits) ? 'a' : 'r',
            );
        }

        $fleetAttack = array(
            'pirate' => array(
                'player' => array(
                    'id'            => 0,
                    'username'      => 'Piratas',
                    'military_tech' => 0,
                    'defence_tech'  => 0,
                    'shield_tech'   => 0,
                    'factor'        => array('Attack' => 1, 'Defensive' => 1, 'Shield' => 1, 'ShipStorage' => 0),
                ),
                'fleetDetail' => array(
                    'fleet_id'                 => 0,
                    'fleet_owner'              => 0,
                    'fleet_start_galaxy'       => self::PIRATE_ORIGIN_GALAXY,
                    'fleet_start_system'       => self::PIRATE_ORIGIN_SYSTEM,
                    'fleet_start_planet'       => self::PIRATE_ORIGIN_PLANET,
                    'fleet_start_type'         => 1,
                    'fleet_resource_metal'     => 0,
                    'fleet_resource_crystal'   => 0,
                    'fleet_resource_deuterium' => 0,
                ),
                'unit' => $attackerUnits,
            ),
        );

        $fleetDefend = array(
            'bastion' => array(
                'player' => array(
                    'id'            => 0,
                    'username'      => 'Bastión',
                    'military_tech' => 0,
                    'defence_tech'  => 0,
                    'shield_tech'   => 0,
                    'factor'        => array('Attack' => 0, 'Defensive' => 0, 'Shield' => 0, 'ShipStorage' => 0),
                ),
                'fleetDetail' => array(
                    'fleet_id'                 => 0,
                    'fleet_owner'              => 0,
                    'fleet_start_galaxy'       => (int) $bastionPlanet['galaxy'],
                    'fleet_start_system'       => (int) $bastionPlanet['system'],
                    'fleet_start_planet'       => (int) $bastionPlanet['planet'],
                    'fleet_start_type'         => 1,
                    'fleet_resource_metal'     => 0,
                    'fleet_resource_crystal'   => 0,
                    'fleet_resource_deuterium' => 0,
                ),
                'unit' => $defenderUnits,
            ),
        );

        require_once ROOT_PATH.'includes/classes/missions/functions/calculateAttack.php';

        $combatResult = calculateAttack(
            $fleetAttack,
            $fleetDefend,
            $config->Fleet_Cdr,
            $config->Defs_Cdr
        );

        $attackerSurvivors = isset($fleetAttack['pirate']['unit']) ? $fleetAttack['pirate']['unit'] : array();
        $defenderSurvivors = isset($fleetDefend['bastion']['unit']) ? $fleetDefend['bastion']['unit'] : array();

        $attackerLost      = array_sum($initialAttacker) - array_sum($attackerSurvivors);
        $attackerSurvived  = array_sum($attackerSurvivors);
        $defenderLost      = array_sum($initialDefender) - array_sum($defenderSurvivors);
        $defenderSurvived  = array_sum($defenderSurvivors);

        // Persistir las unidades supervivientes del bastión
        self::updateBastionPlanetUnits((int) $bastionPlanet['id'], $defenderSurvivors);

        return array(
            'attacker_lost'           => $attackerLost,
            'attacker_survived'       => $attackerSurvived,
            'attacker_survivor_units' => $attackerSurvivors,
            'defender_lost'           => $defenderLost,
            'defender_survived'       => $defenderSurvived,
            'defender_survivor_units' => $defenderSurvivors,
            'won'                     => $combatResult['won'] ?? 'r',
            'combat_result'           => $combatResult,
        );
    }

    private static function calculateDamageToBastion(array $initialPirateFleet, array $survivorUnits): int
    {
        global $pricelist;

        $totalCost = 0;
        foreach ($survivorUnits as $shipId => $count) {
            $shipId = (int) $shipId;
            $count  = (int) $count;
            if ($shipId <= 0 || $count <= 0) continue;

            $cost = 0;
            if (isset($pricelist[$shipId]['cost']) && is_array($pricelist[$shipId]['cost'])) {
                $cost = (int) ($pricelist[$shipId]['cost'][901] ?? 0)
                      + (int) ($pricelist[$shipId]['cost'][902] ?? 0)
                      + (int) ($pricelist[$shipId]['cost'][903] ?? 0);
            }
            if ($cost <= 0) $cost = 1000;

            $totalCost += $count * $cost;
        }

        // 50% del coste de los piratas supervivientes → daño al HP del bastión
        return (int) floor($totalCost * 0.5);
    }

    private static function updateBastionPlanetUnits(int $planetId, array $survivingUnits): void
    {
        $db = Database::get();
        $planetsTable = PVEGhostHelper::getTableName('planets');

        // Columnas reales
        $realCols = array();
        try {
            $dbName = defined('DB_NAME') ? DB_NAME : 'prueba_test';
            $rows = $db->select(
                "SELECT COLUMN_NAME AS col
                 FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = :db AND TABLE_NAME = :tbl;",
                array(':db' => $dbName, ':tbl' => $planetsTable)
            );
            if (is_array($rows)) {
                foreach ($rows as $r) $realCols[] = $r['col'];
            }
        } catch (Throwable $e) {}

        $columnMap = PVEGhostHelper::$columnMap;

        foreach ($columnMap as $unitId => $colName) {
            if (!in_array($colName, $realCols, true)) continue;

            $value = isset($survivingUnits[$unitId]) ? (int) $survivingUnits[$unitId] : 0;
            if ($value < 0) $value = 0;

            try {
                $db->update(
                    "UPDATE `{$planetsTable}` SET `{$colName}` = :v WHERE id = :pid;",
                    array(':v' => $value, ':pid' => $planetId)
                );
            } catch (Throwable $e) {}
        }
    }

    /* ============================================================
     *  4. ATRIBUCIÓN DE RESULTADOS A JUGADORES
     * ============================================================ */

    /**
     * Reparte los pirate kills y las pérdidas de defensores entre los jugadores
     * que enviaron refuerzos, proporcional a su contribución actual.
     *
     * ★ v1.1 — Añadido:
     *   - Parámetro $piratesSurvived para saber si la oleada boss murió entera.
     *   - Llamada a PVEBastionHelper::recordPiratesKilled() por cada contribuyente,
     *     que a su vez actualiza los acumuladores globales en uni1_pve_achievements
     *     y dispara los chequeos de logros:
     *       - Leyenda Pirata       (bastion_pirates_killed)
     *       - Cazador de Capitanes (bastion_boss_pirates_killed)
     *   - Boss kills solo se otorgan si la oleada boss murió ENTERA
     *     ($piratesSurvived <= 0) y al jugador de mayor contribución.
     */
    private static function distributeWaveOutcome(
        int $eventId,
        int $registrationId,
        int $piratesKilled,
        int $piratesSurvived,
        int $defendersLost,
        bool $isBoss
    ): void {
        if ($piratesKilled <= 0 && $defendersLost <= 0) return;

        $db = Database::get();

        try {
            // Contribución actual de cada jugador
            $contribs = $db->select(
                "SELECT id, user_id, ships_sent, ships_lost
                 FROM %%PVE_BASTION_DAMAGE%%
                 WHERE registration_id = :rid;",
                array(':rid' => $registrationId)
            );

            if (!is_array($contribs) || count($contribs) === 0) return;

            // Calcular peso total (naves vivas de cada uno)
            $weights = array();
            $totalWeight = 0;
            $maxWeight   = -1;
            $maxWeightId = 0;

            foreach ($contribs as $c) {
                $alive = max(0, (int) $c['ships_sent'] - (int) $c['ships_lost']);
                $weights[(int) $c['id']] = array(
                    'user_id' => (int) $c['user_id'],
                    'weight'  => $alive,
                );
                $totalWeight += $alive;

                if ($alive > $maxWeight) {
                    $maxWeight   = $alive;
                    $maxWeightId = (int) $c['id'];
                }
            }

            if ($totalWeight <= 0) return;

            // ★ v1.1 — Decidir quién recibe el boss kill:
            // Solo si fue oleada boss Y la oleada murió entera (no quedaron piratas vivos).
            $bossKillForId = 0;
            if ($isBoss && $piratesSurvived <= 0 && $piratesKilled > 0 && $maxWeightId > 0) {
                $bossKillForId = $maxWeightId;
            }

            // Repartir proporcionalmente
            foreach ($weights as $id => $info) {
                $share = $info['weight'] / $totalWeight;

                $userPiratesKilled = (int) round($piratesKilled * $share);
                $userDefendersLost = (int) round($defendersLost * $share);
                $userBossKills     = ($id === $bossKillForId) ? 1 : 0;

                // Daño proporcional estimado (100 por pirata muerto — configurable)
                $scorePerPirate = (int) PVEHelper::get('bastion_score_per_pirate', 100);
                $damageDealt = $userPiratesKilled * $scorePerPirate;

                // 1ª pasada: ships_lost (el resto lo hace recordPiratesKilled)
                $db->update(
                    "UPDATE %%PVE_BASTION_DAMAGE%% SET
                        ships_lost = ships_lost + :lost
                     WHERE id = :id;",
                    array(
                        ':lost' => $userDefendersLost,
                        ':id'   => $id,
                    )
                );

                // ★ v1.1 — 2ª pasada vía PVEBastionHelper::recordPiratesKilled():
                //   - Actualiza damage_dealt, pirates_killed, boss_pirates_killed
                //   - Suma acumuladores globales en uni1_pve_achievements
                //   - Dispara PVEAchievementHelper::recordBastionPirateKills()
                //   - Dispara PVEAchievementHelper::recordBastionBossKills()
                if (class_exists('PVEBastionHelper') && method_exists('PVEBastionHelper', 'recordPiratesKilled')) {
                    try {
                        PVEBastionHelper::recordPiratesKilled(
                            $registrationId,
                            (int) $info['user_id'],
                            $damageDealt,
                            $userPiratesKilled,
                            $userBossKills
                        );
                    } catch (Throwable $ePk) {
                        // Silencioso
                    }
                } else {
                    // Fallback — por si la versión del helper no tuviera el método
                    $db->update(
                        "UPDATE %%PVE_BASTION_DAMAGE%% SET
                            damage_dealt        = damage_dealt + :dmg,
                            pirates_killed      = pirates_killed + :pk,
                            boss_pirates_killed = boss_pirates_killed + :bpk,
                            last_hit            = :now
                         WHERE id = :id;",
                        array(
                            ':dmg' => $damageDealt,
                            ':pk'  => $userPiratesKilled,
                            ':bpk' => $userBossKills,
                            ':now' => TIMESTAMP,
                            ':id'  => $id,
                        )
                    );
                }
            }

            // Actualizar contadores de la registración
            $db->update(
                "UPDATE %%PVE_BASTION_REGISTRATIONS%% SET
                    pirates_killed      = pirates_killed + :pk,
                    boss_pirates_killed = boss_pirates_killed + :bpk,
                    waves_survived      = waves_survived + 1,
                    waves_total         = waves_total + 1,
                    last_hit            = :now
                 WHERE id = :rid;",
                array(
                    ':pk'  => $piratesKilled,
                    ':bpk' => ($bossKillForId > 0) ? 1 : 0,
                    ':now' => TIMESTAMP,
                    ':rid' => $registrationId,
                )
            );

        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, $eventId, 'distribute_wave_error', 0, 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }

    /* ============================================================
     *  5. HELPERS DE FASE
     * ============================================================ */

    private static function determinePhase(array $event, int $now): string
    {
        $elapsed = max(0, $now - (int) $event['start_time']);

        $calmEnd  = (int) PVEHelper::get('bastion_phase_calm_end', 6)  * 3600;
        $surgeEnd = (int) PVEHelper::get('bastion_phase_surge_end', 24) * 3600;
        $siegeEnd = (int) PVEHelper::get('bastion_phase_siege_end', 40) * 3600;

        if ($elapsed < $calmEnd)  return 'calm';
        if ($elapsed < $surgeEnd) return 'surge';
        if ($elapsed < $siegeEnd) return 'siege';
        return 'hell';
    }

    private static function phaseToNumber(string $phase): int
    {
        switch ($phase) {
            case 'calm':  return 1;
            case 'surge': return 2;
            case 'siege': return 3;
            case 'hell':  return 4;
        }
        return 1;
    }

    private static function getPhaseIntervalMin(string $phase): int
    {
        switch ($phase) {
            case 'calm':  return max(1, (int) PVEHelper::get('bastion_wave_interval_calm', 360));
            case 'surge': return max(1, (int) PVEHelper::get('bastion_wave_interval_surge', 180));
            case 'siege': return max(1, (int) PVEHelper::get('bastion_wave_interval_siege', 120));
            case 'hell':  return max(1, (int) PVEHelper::get('bastion_wave_interval_hell', 60));
        }
        return 360;
    }

    private static function getPhaseMultiplier(string $phase): int
    {
        switch ($phase) {
            case 'calm':  return max(1, (int) PVEHelper::get('bastion_pirate_mult_calm', 1));
            case 'surge': return max(1, (int) PVEHelper::get('bastion_pirate_mult_surge', 2));
            case 'siege': return max(1, (int) PVEHelper::get('bastion_pirate_mult_siege', 4));
            case 'hell':  return max(1, (int) PVEHelper::get('bastion_pirate_mult_hell', 8));
        }
        return 1;
    }

    private static function getPhaseBossChance(string $phase): int
    {
        switch ($phase) {
            case 'calm':  return (int) PVEHelper::get('bastion_boss_pirate_chance_calm', 0);
            case 'surge': return (int) PVEHelper::get('bastion_boss_pirate_chance_surge', 10);
            case 'siege': return (int) PVEHelper::get('bastion_boss_pirate_chance_siege', 20);
            case 'hell':  return (int) PVEHelper::get('bastion_boss_pirate_chance_hell', 35);
        }
        return 0;
    }

    private static function rollBossWave(string $phase): bool
    {
        $chance = self::getPhaseBossChance($phase);
        if ($chance <= 0) return false;
        if ($chance >= 100) return true;
        return random_int(1, 100) <= $chance;
    }

    /* ============================================================
     *  6. CONSTRUCCIÓN DE FLOTA PIRATA
     * ============================================================ */

    private static function buildPirateFleet(array $event, string $phase, bool $isBoss): array
    {
        $mult = self::getPhaseMultiplier($phase);

        if ($isBoss) {
            $baseJson = (string) PVEHelper::get(
                'bastion_boss_pirate_fleet_json',
                '{"204":500,"205":200,"211":50,"213":20}'
            );
        } else {
            $baseJson = (string) PVEHelper::get(
                'bastion_pirate_base_fleet_json',
                '{"204":100,"205":50,"206":25,"207":10}'
            );
        }

        $base = json_decode($baseJson, true);
        if (!is_array($base)) return array();

        $fleet = array();
        foreach ($base as $shipId => $count) {
            $shipId = (int) $shipId;
            $count  = (int) $count;
            if ($shipId <= 0 || $count <= 0) continue;

            $final = $count * $mult;
            // Variación aleatoria ±20%
            $variation = random_int(80, 120) / 100;
            $final = (int) floor($final * $variation);

            if ($final > 0) $fleet[$shipId] = $final;
        }

        return $fleet;
    }

    /* ============================================================
     *  7. ENVÍO DE FLOTA PIRATA (misión 25)
     * ============================================================ */

    /**
     * Inserta la flota pirata real en uni1_fleets con misión 25.
     * El destino es el planeta del bastión. Al llegar, FlyingFleetHandler
     * la enrutará a MissionCasePirateAttack::TargetEvent().
     *
     * @return int  fleet_id (o 0 si falla)
     */
    private static function sendPirateFleet(
        array $event, array $ghost, int $waveId, array $fleet, int $arrivalTime
    ): int {
        if (empty($fleet)) return 0;

        $db = Database::get();

        $targetPlanetId = (int) $ghost['ghost_planet_id'];
        $targetUserId   = (int) $ghost['ghost_user_id'];
        $targetGalaxy   = (int) $ghost['galaxy'];
        $targetSystem   = (int) $ghost['system'];
        $targetPlanet   = (int) $ghost['planet'];

        if ($targetPlanetId <= 0) return 0;

        // Serializar fleet_array: "204,100;205,50;"
        $fleetArray = '';
        $totalCount = 0;
        foreach ($fleet as $shipId => $count) {
            $shipId = (int) $shipId;
            $count  = (int) $count;
            if ($shipId <= 0 || $count <= 0) continue;

            $fleetArray .= $shipId . ',' . floatToString($count) . ';';
            $totalCount += $count;
        }
        if ($totalCount <= 0) return 0;

        $fleetArray = substr($fleetArray, 0, -1);

        $now        = TIMESTAMP;
        $startTime  = $now;
        $endTime    = $arrivalTime;
        // ✅ v3.4 — Multiverso: el universo lo dicta el dueño del fantasma
        // (esto corre desde cron para cualquier universo).
        $universe   = PVEHelper::getUniverseForUser($ghost['ghost_user_id']);

        try {
            // Insertar la flota
            $db->insert(
                "INSERT INTO %%FLEETS%% SET
                    fleet_owner              = 0,
                    fleet_universe           = :uni,
                    fleet_start_time         = :st,
                    fleet_end_time           = :et,
                    fleet_start_galaxy       = :sgal,
                    fleet_start_system       = :ssys,
                    fleet_start_planet       = :spl,
                    fleet_start_type         = 1,
                    fleet_end_galaxy         = :egal,
                    fleet_end_system         = :esys,
                    fleet_end_planet         = :epl,
                    fleet_end_type           = 1,
                    fleet_end_id             = :eid,
                    fleet_target_owner       = :towner,
                    fleet_target_obj         = :tobj,
                    fleet_mission            = :mission,
                    fleet_array              = :farray,
                    fleet_amount             = :famount,
                    fleet_resource_metal     = 0,
                    fleet_resource_crystal   = 0,
                    fleet_resource_deuterium = 0,
                    fleet_group              = 0,
                    fleet_mess               = 0,
                    fleet_creation           = :now,
                    fleet_ship_storage       = 0;",
                array(
                    ':uni'    => $universe,
                    ':st'     => $startTime,
                    ':et'     => $endTime,
                    ':sgal'   => self::PIRATE_ORIGIN_GALAXY,
                    ':ssys'   => self::PIRATE_ORIGIN_SYSTEM,
                    ':spl'    => self::PIRATE_ORIGIN_PLANET,
                    ':egal'   => $targetGalaxy,
                    ':esys'   => $targetSystem,
                    ':epl'    => $targetPlanet,
                    ':eid'    => $targetUserId,
                    ':towner' => $targetUserId,
                    ':tobj'   => $waveId,
                    ':mission'=> self::PIRATE_MISSION,
                    ':farray' => $fleetArray,
                    ':famount'=> $totalCount,
                    ':now'    => $now,
                )
            );

            $fleetId = (int) $db->lastInsertId();
            if ($fleetId <= 0) return 0;

            // Programar el evento de la flota
            $db->insert(
                "INSERT INTO %%FLEETS_EVENT%% SET
                    fleetID = :fid,
                    `lock`  = 0,
                    time    = :et;",
                array(
                    ':fid' => $fleetId,
                    ':et'  => $endTime,
                )
            );

            return $fleetId;
        } catch (Throwable $e) {
            PVEHelper::log(self::LOG_TYPE, (int) $event['id'], 'pirate_fleet_insert_error', 0, 0, array(
                'wave_id' => $waveId,
                'error'   => $e->getMessage(),
            ));
            return 0;
        }
    }

    /* ============================================================
     *  8. NOTIFICACIONES
     * ============================================================ */

    private static function notifyWaveResolved(
        array $event, array $wave, array $ghost, array $result
    ): void {
        $phaseNames = array(
            'calm'  => 'I — CALMA',
            'surge' => 'II — OLEADA',
            'siege' => 'III — ASEDIO',
            'hell'  => 'IV — INFIERNO',
        );
        $phaseLabel = $phaseNames[$wave['phase']] ?? $wave['phase'];

        $title = '';
        $color = '';
        $icon  = '';

        if ($result['result'] === 'defended') {
            $title = '🛡️ ¡OLEADA REPELIDA!';
            $color = '#00cc66';
            $icon  = '✅';
        } elseif ($result['result'] === 'breached') {
            $title = '💥 ¡BASTIÓN SUPERADO!';
            $color = '#cc2200';
            $icon  = '💀';
        } else {
            $title = '⚔️ Oleada resuelta (parcial)';
            $color = '#ffaa33';
            $icon  = '⚠️';
        }

        $body  = "<div style='padding:12px;background:#0a1a2e;border-left:4px solid {$color};border-radius:6px;color:#e0e0e0;'>";
        $body .= "<h2 style='color:{$color};margin:0 0 10px;'>{$title}</h2>";
        $body .= "<p>Oleada <b>#{$wave['wave_number']}</b> — Fase <b>{$phaseLabel}</b>";
        if ((int) $wave['is_boss_wave'] === 1) $body .= " — <span style='color:#ff4444;'>⚠️ OLEADA JEFE</span>";
        $body .= "</p>";
        $body .= "<table style='width:100%;font-size:12px;color:#d1d5db;margin-top:8px;'>";
        $body .= "<tr><td>☠️ Piratas destruidos:</td><td align='right'><b>" . number_format($result['pirates_killed']) . "</b></td></tr>";
        $body .= "<tr><td>🏴‍☠️ Piratas supervivientes:</td><td align='right'><b>" . number_format($result['pirates_survived']) . "</b></td></tr>";
        $body .= "<tr><td>💥 Daño al Bastión:</td><td align='right'><b>" . number_format($result['damage_to_bastion']) . "</b></td></tr>";
        $body .= "<tr><td>💚 HP Bastión:</td><td align='right'><b>" . number_format((int) $result['damage_to_bastion'] > 0 ? max(0, (int) $ghost['hp_current'] - $result['damage_to_bastion']) : (int) $ghost['hp_current']) . "</b></td></tr>";
        $body .= "</table>";
        $body .= "<p style='font-size:10px;color:#6b7280;margin-top:12px;'>Panel: <a href='game.php?page=pve&mode=bastion' style='color:#99ddff;'>game.php?page=pve&mode=bastion</a></p>";
        $body .= "</div>";

        $allyId = (int) $wave['ally_id'];
        self::sendMessageToAlly($allyId, $icon . ' ' . $title, $body);
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
            try {
                PlayerUtil::sendMessage(
                    (int) $m['id'], 0, 'Bastión Asediado', 3, $title, $body,
                    TIMESTAMP, null, 1, PVEHelper::getUniverseForUser((int) $m['id'])
                );
                $count++;
            } catch (Throwable $e) {}
        }
        return $count;
    }

    /* ============================================================
     *  9. UTILIDADES PÚBLICAS
     * ============================================================ */

    /**
     * Devuelve las oleadas pendientes de un evento (para panel admin / debug).
     */
    public static function getPendingWaves(int $eventId, int $limit = 50): array
    {
        $db = Database::get();
        $rows = $db->select(
            "SELECT w.*, a.ally_name
             FROM %%PVE_BASTION_WAVES%% w
             LEFT JOIN %%ALLIANCE%% a ON a.id = w.ally_id
             WHERE w.event_id = :eid AND w.resolved = 0
             ORDER BY w.arrival_time ASC
             LIMIT " . (int) $limit . ";",
            array(':eid' => $eventId)
        );
        return is_array($rows) ? $rows : array();
    }

    /**
     * Devuelve las últimas oleadas resueltas de un evento.
     */
    public static function getRecentWaves(int $eventId, int $limit = 30): array
    {
        $db = Database::get();
        $rows = $db->select(
            "SELECT w.*, a.ally_name
             FROM %%PVE_BASTION_WAVES%% w
             LEFT JOIN %%ALLIANCE%% a ON a.id = w.ally_id
             WHERE w.event_id = :eid AND w.resolved = 1
             ORDER BY w.resolved_at DESC
             LIMIT " . (int) $limit . ";",
            array(':eid' => $eventId)
        );
        return is_array($rows) ? $rows : array();
    }
}