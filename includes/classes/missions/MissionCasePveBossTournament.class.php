<?php

/**
 * AstroIO — MissionCasePveBossTournament
 * Procesa la llegada de una flota (o grupo ACS) de jugadores al fantasma
 * del Torneo del Devorador (misión 23, o misión 1/2 redirigida por
 * FlyingFleetHandler al detectar un ghost con event_type='boss').
 *
 * Reutiliza el motor de combate nativo xnova (calculateAttack).
 *
 * Ubicación: includes/classes/missions/MissionCasePveBossTournament.class.php
 * @package AstroIO
 * @version 1.1
 *   - GATHER/MARK del grupo ACS antes de combatir (previene doble combate)
 *   - Valida que TODOS los atacantes pertenezcan a la alianza dueña del fantasma
 *   - Calcula daño = (precio × naves destruidas) × 0.5
 *   - Reparte daño por jugador proporcional al aporte de naves
 *   - Registra daño en el ranking del torneo (PVEBossTournamentHelper::registerDamage)
 *   - Aplica daño al HP del fantasma (PVEBossTournamentHelper::applyDamage)
 *   - 🆕 v1.1 — Pasa $topContributorId a applyDamage() para que disparen
 *     los logros "Cazador del Devorador" (1 kill) y "Verdugo Estelar" (10 kills).
 *   - Detecta fase 3 → triplica las naves supervivientes del fantasma
 *   - Genera informe de batalla nativo (PveBattleReportHelper)
 *   - Envía mensaje a cada atacante con resultado + fase + enlace al informe
 */

// ═══════════════════════════════════════════════════════════════════
// DEPENDENCIAS
// ═══════════════════════════════════════════════════════════════════
if (!class_exists('PVEHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVEGhostHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';
}
if (!class_exists('PveFleetHelper')) {
    require_once ROOT_PATH.'includes/classes/PveFleetHelper.class.php';
}
if (!class_exists('PVEBossTournamentHelper')) {
    $__bossFile = ROOT_PATH.'includes/classes/PVEBossTournamentHelper.class.php';
    if (file_exists($__bossFile)) {
        require_once $__bossFile;
    }
}
if (!class_exists('PveBattleReportHelper')) {
    require_once ROOT_PATH.'includes/classes/PveBattleReportHelper.class.php';
}

class MissionCasePveBossTournament extends MissionFunctions implements Mission
{
    function __construct($Fleet)
    {
        $this->_fleet = $Fleet;
    }

    /* ============================================================
     *  LLEGADA AL FANTASMA DEL TORNEO (combate + ranking)
     * ============================================================ */

    function TargetEvent()
    {
        global $reslist, $resource, $pricelist;

        $db     = Database::get();
        $config = Config::get($this->_fleet['fleet_universe']);

        $myFleetId = (int) $this->_fleet['fleet_id'];

        // ═══════════════════════════════════════════════════════════
        // 0) GUARD — evitar doble procesamiento
        // ═══════════════════════════════════════════════════════════
        $rowCheck = $db->selectSingle(
            "SELECT fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fid LIMIT 1;",
            array(':fid' => $myFleetId)
        );

        if (empty($rowCheck)) {
            PVEHelper::log('boss', 0, 'fleet_deleted_before_processing', 0, 0, array(
                'fleet_id' => $myFleetId,
            ));
            return;
        }

        if ((int) $rowCheck['fleet_mess'] !== 0) {
            PVEHelper::log('boss', 0, 'fleet_already_processed', 0, 0, array(
                'fleet_id'   => $myFleetId,
                'fleet_mess' => (int) $rowCheck['fleet_mess'],
            ));
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 0b) GATHER — recolectar TODAS las flotas del grupo ACS
        // ═══════════════════════════════════════════════════════════
        $acsId = (int) $this->_fleet['fleet_group'];
        $endId = (int) $this->_fleet['fleet_end_id'];

        $allFleets = array();

        if ($acsId > 0) {
            $allFleets = $db->select(
                "SELECT * FROM %%FLEETS%% 
                 WHERE fleet_group = :acsId 
                   AND fleet_end_id = :endId
                   AND fleet_mess = 0;",
                array(':acsId' => $acsId, ':endId' => $endId)
            );
        } else {
            $allFleets = array($this->_fleet);
        }

        if (empty($allFleets) || !is_array($allFleets)) {
            $allFleets = array($this->_fleet);
        }

        // ═══════════════════════════════════════════════════════════
        // 0c) MARK ALL — marcar TODAS como RETURN para que los eventos
        //     de las otras flotas del grupo no vuelvan a combatir.
        // ═══════════════════════════════════════════════════════════
        if ($acsId > 0) {
            $db->update(
                "UPDATE %%FLEETS%% SET fleet_mess = 1 
                 WHERE fleet_group = :acsId 
                   AND fleet_end_id = :endId
                   AND fleet_mess = 0;",
                array(':acsId' => $acsId, ':endId' => $endId)
            );
        } else {
            $db->update(
                "UPDATE %%FLEETS%% SET fleet_mess = 1 WHERE fleet_id = :fid;",
                array(':fid' => $myFleetId)
            );
        }

        PVEHelper::log('boss', 0, 'acs_fleets_gathered', 0, $endId, array(
            'acs_id'     => $acsId,
            'trigger_id' => $myFleetId,
            'fleets'     => count($allFleets),
        ));

        // ═══════════════════════════════════════════════════════════
        // 1) Buscar el fantasma del torneo por fleet_end_id
        //    (en PVEGhostHelper los ghost_user_id y ghost_planet_id
        //    son el mismo valor, así que da igual cuál sea)
        // ═══════════════════════════════════════════════════════════
        $ghostUserId = $endId;

        $registration = null;
        if (class_exists('PVEBossTournamentHelper')) {
            $registration = PVEBossTournamentHelper::getRegistrationByGhost($ghostUserId);
        }

        // Fallback: buscar por ghost_planet_id
        if (empty($registration)) {
            try {
                $registration = $db->selectSingle(
                    "SELECT r.* 
                     FROM %%PVE_BOSS_GHOSTS%% g
                     INNER JOIN %%PVE_BOSS_REGISTRATIONS%% r ON r.id = g.registration_id
                     WHERE g.ghost_planet_id = :pid AND g.status = 'active'
                     LIMIT 1;",
                    array(':pid' => $endId)
                );
            } catch (Throwable $e) {
                $registration = null;
            }
        }

        if (empty($registration)) {
            PVEHelper::log('boss', 0, 'registration_not_found', 0, $endId, array(
                'fleet_id' => $myFleetId,
            ));
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        if ($registration['status'] !== 'active') {
            PVEHelper::log('boss', (int) $registration['event_id'], 'registration_not_active', 0, 0, array(
                'reg_id' => (int) $registration['id'],
                'status' => $registration['status'],
            ));
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 2) Cargar evento activo
        // ═══════════════════════════════════════════════════════════
        $event = PVEBossTournamentHelper::getEvent((int) $registration['event_id']);
        if (empty($event) || $event['status'] !== 'active') {
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 3) Cargar fantasma activo
        // ═══════════════════════════════════════════════════════════
        $ghost = PVEBossTournamentHelper::getActiveGhostForRegistration((int) $registration['id']);
        if (empty($ghost)) {
            PVEHelper::log('boss', (int) $event['id'], 'ghost_not_active', 0, 0, array(
                'reg_id' => (int) $registration['id'],
            ));
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 4) Validar que TODOS los atacantes son de la alianza dueña
        // ═══════════════════════════════════════════════════════════
        $ownerAllyId = (int) $registration['ally_id'];

        $validFleets = array();
        foreach ($allFleets as $f) {
            $ownerId = (int) $f['fleet_owner'];
            $userAlly = (int) $db->selectSingle(
                "SELECT ally_id FROM %%USERS%% WHERE id = :uid LIMIT 1;",
                array(':uid' => $ownerId),
                'ally_id'
            );
            if ($userAlly === $ownerAllyId) {
                $validFleets[] = $f;
            }
        }

        if (empty($validFleets)) {
            PVEHelper::log('boss', (int) $event['id'], 'no_valid_attackers', 0, 0, array(
                'reg_id'     => (int) $registration['id'],
                'owner_ally' => $ownerAllyId,
            ));
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 5) Cargar planeta fantasma (para leer naves/defensas)
        // ═══════════════════════════════════════════════════════════
        $ghostPlanetId = (int) $ghost['ghost_planet_id'];
        $ghostPlanet = $db->selectSingle(
            "SELECT * FROM %%PLANETS%% WHERE id = :pid LIMIT 1;",
            array(':pid' => $ghostPlanetId)
        );

        if (empty($ghostPlanet)) {
            PVEHelper::log('boss', (int) $event['id'], 'ghost_planet_missing', 0, 0, array(
                'ghost_planet_id' => $ghostPlanetId,
            ));
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 6) Construir atacantes
        // ═══════════════════════════════════════════════════════════
        $fleetAttack = array();

        foreach ($validFleets as $fleetDetail) {
            $fleetId = (int) $fleetDetail['fleet_id'];
            $ownerId = (int) $fleetDetail['fleet_owner'];

            $user = $db->selectSingle(
                "SELECT * FROM %%USERS%% WHERE id = :uid LIMIT 1;",
                array(':uid' => $ownerId)
            );

            if (empty($user)) continue;

            $attackerUnits = FleetFunctions::unserialize($fleetDetail['fleet_array']);
            if (empty($attackerUnits)) continue;

            $fleetAttack[$fleetId] = array(
                'player' => array(
                    'id'            => $user['id'],
                    'username'      => $user['username'],
                    'military_tech' => (int) $user['military_tech'],
                    'defence_tech'  => (int) $user['defence_tech'],
                    'shield_tech'   => (int) $user['shield_tech'],
                    'factor'        => getFactors($user, 'attack', $fleetDetail['fleet_start_time']),
                ),
                'fleetDetail' => array(
                    'fleet_id'                 => $fleetId,
                    'fleet_owner'              => $ownerId,
                    'fleet_start_galaxy'       => (int) $fleetDetail['fleet_start_galaxy'],
                    'fleet_start_system'       => (int) $fleetDetail['fleet_start_system'],
                    'fleet_start_planet'       => (int) $fleetDetail['fleet_start_planet'],
                    'fleet_start_type'         => (int) $fleetDetail['fleet_start_type'],
                    'fleet_resource_metal'     => 0,
                    'fleet_resource_crystal'   => 0,
                    'fleet_resource_deuterium' => 0,
                ),
                'unit' => $attackerUnits,
            );
        }

        if (empty($fleetAttack)) {
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 7) Construir defensor (naves + defensas del fantasma)
        // ═══════════════════════════════════════════════════════════
        $ghostUnits = array();
        foreach (array_merge($reslist['fleet'], $reslist['defense']) as $elementId) {
            $colName = isset($resource[$elementId]) ? $resource[$elementId] : '';
            if ($colName === '') continue;

            $amount = isset($ghostPlanet[$colName]) ? (int) $ghostPlanet[$colName] : 0;
            if ($amount > 0) {
                $ghostUnits[$elementId] = $amount;
            }
        }

        $initialGhostUnits = $ghostUnits;

        if (empty($ghostUnits)) {
            // Nada que defender → victoria automática, no hay daño
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        $fleetDefend = array(
            $ghostUserId => array(
                'player' => array(
                    'id'            => 0,
                    'username'      => (string) $event['boss_name'],
                    'military_tech' => 0,
                    'defence_tech'  => 0,
                    'shield_tech'   => 0,
                    'factor'        => array(
                        'Attack'      => 0,
                        'Defensive'   => 0,
                        'Shield'      => 0,
                        'ShipStorage' => 0,
                    ),
                ),
                'fleetDetail' => array(
                    'fleet_id'                 => 0,
                    'fleet_owner'              => 0,
                    'fleet_start_galaxy'       => (int) $ghost['galaxy'],
                    'fleet_start_system'       => (int) $ghost['system'],
                    'fleet_start_planet'       => (int) $ghost['planet'],
                    'fleet_start_type'         => 1,
                    'fleet_resource_metal'     => 0,
                    'fleet_resource_crystal'   => 0,
                    'fleet_resource_deuterium' => 0,
                ),
                'unit' => $ghostUnits,
            ),
        );

        // ═══════════════════════════════════════════════════════════
        // 8) Combate
        // ═══════════════════════════════════════════════════════════
        require_once ROOT_PATH.'includes/classes/missions/functions/calculateAttack.php';

        $combatResult = calculateAttack(
            $fleetAttack,
            $fleetDefend,
            $config->Fleet_Cdr,
            $config->Defs_Cdr
        );

        // ═══════════════════════════════════════════════════════════
        // 9) Supervivientes del fantasma
        // ═══════════════════════════════════════════════════════════
        $survivingGhostUnits = isset($fleetDefend[$ghostUserId]['unit'])
            ? $fleetDefend[$ghostUserId]['unit']
            : array();

        // ═══════════════════════════════════════════════════════════
        // 10) Calcular daño al fantasma
        //     daño = (precio × naves destruidas) × 0.5
        // ═══════════════════════════════════════════════════════════
        $damageToBoss = 0;

        foreach ($initialGhostUnits as $unitId => $initialCount) {
            $unitId = (int) $unitId;
            $initialCount = (int) $initialCount;
            if ($initialCount <= 0) continue;

            $left = isset($survivingGhostUnits[$unitId]) ? (int) $survivingGhostUnits[$unitId] : 0;
            $lost = max(0, $initialCount - $left);
            if ($lost <= 0) continue;

            $cost = 0;
            if (isset($pricelist[$unitId]['cost']) && is_array($pricelist[$unitId]['cost'])) {
                $cost = (int) ($pricelist[$unitId]['cost'][901] ?? 0)
                      + (int) ($pricelist[$unitId]['cost'][902] ?? 0)
                      + (int) ($pricelist[$unitId]['cost'][903] ?? 0);
            }
            if ($cost <= 0) $cost = 1000;

            $damageToBoss += $lost * $cost;
        }

        $damageToBoss = (int) floor($damageToBoss * 0.5);

        // ═══════════════════════════════════════════════════════════
        // 11) Registrar daño POR JUGADOR (proporcional al aporte)
        //
        // 🆕 v1.1 — Mientras repartimos el daño, también detectamos
        //           quién ha aportado MÁS naves en este ataque. Ese
        //           jugador (topContributorId) recibirá el logro de
        //           "fantasma matado" si el boss muere en este combate.
        //           Así en un ACS no se inflan los logros: solo uno
        //           se lleva el kill.
        // ═══════════════════════════════════════════════════════════
        $totalFleetShips = 0;
        foreach ($validFleets as $f) {
            $u = FleetFunctions::unserialize($f['fleet_array']);
            if (is_array($u)) {
                $totalFleetShips += array_sum($u);
            }
        }
        if ($totalFleetShips <= 0) $totalFleetShips = 1;

        $topContributorId = 0;
        $topContributorShips = 0;

        foreach ($validFleets as $fleetDetail) {
            $fleetId = (int) $fleetDetail['fleet_id'];
            $ownerId = (int) $fleetDetail['fleet_owner'];

            $userUnits = FleetFunctions::unserialize($fleetDetail['fleet_array']);
            $userShips = is_array($userUnits) ? array_sum($userUnits) : 0;
            if ($userShips <= 0) continue;

            // 🆕 v1.1 — Seguimiento del mayor contribuyente
            if ($userShips > $topContributorShips) {
                $topContributorShips = $userShips;
                $topContributorId    = $ownerId;
            }

            $userDamage = (int) round($damageToBoss * ($userShips / $totalFleetShips));
            if ($userDamage <= 0) continue;

            PVEBossTournamentHelper::registerDamage(
                (int) $event['id'],
                (int) $registration['id'],
                (int) $registration['ally_id'],
                $ownerId,
                $userDamage
            );
        }

        // Fallback: si por lo que sea no se detectó contribuyente,
        // usar el primer atacante válido para que el kill no se pierda.
        if ($topContributorId <= 0 && !empty($validFleets)) {
            $topContributorId = (int) $validFleets[0]['fleet_owner'];
        }

        // ═══════════════════════════════════════════════════════════
        // 12) Aplicar daño al fantasma (HP + fase + posible kill)
        //
        // 🆕 v1.1 — Se pasa $topContributorId para que, si el boss
        //           muere en este ataque, PVEAchievementHelper reciba
        //           el kill y desbloquee "Cazador del Devorador" /
        //           "Verdugo Estelar".
        // ═══════════════════════════════════════════════════════════
        $applyResult = PVEBossTournamentHelper::applyDamage(
            (int) $ghost['id'],
            $damageToBoss,
            $topContributorId
        );

        $killed        = !empty($applyResult['killed']);
        $phaseChanged  = !empty($applyResult['phase_changed']);
        $newPhase      = isset($applyResult['new_phase']) ? (int) $applyResult['new_phase'] : 0;

        // ═══════════════════════════════════════════════════════════
        // 13) Si el fantasma NO murió → actualizar unidades supervivientes
        //     - Si entró en fase 3 → triplicar supervivientes
        // ═══════════════════════════════════════════════════════════
        if (!$killed) {
            // Fase 3 → triplicar la flota superviviente
            if ($phaseChanged && $newPhase === 3) {
                $mult = max(2, (int) PVEHelper::get('boss_phase3_fleet_mult', 3));
                if ($mult > 1) {
                    foreach ($survivingGhostUnits as $unitId => $count) {
                        $survivingGhostUnits[$unitId] = (int) $count * $mult;
                    }
                }
            }

            $this->updateGhostPlanetUnits($ghostPlanetId, $survivingGhostUnits);
        }

        // ═══════════════════════════════════════════════════════════
        // 14) Aplicar pérdidas a las flotas atacantes
        // ═══════════════════════════════════════════════════════════
        foreach ($validFleets as $fleetDetail) {
            $fleetId = (int) $fleetDetail['fleet_id'];

            $updatedUnits = isset($fleetAttack[$fleetId]['unit'])
                ? array_filter($fleetAttack[$fleetId]['unit'])
                : array();

            $totalCount = 0;
            $fleetArray = '';

            foreach ($updatedUnits as $elementId => $amount) {
                $amount = (int) $amount;
                if ($amount <= 0) continue;
                $fleetArray .= $elementId . ',' . floatToString($amount) . ';';
                $totalCount += $amount;
            }

            if ($totalCount <= 0) {
                $sql = 'DELETE %%FLEETS%%, %%FLEETS_EVENT%%
                        FROM %%FLEETS%%
                        INNER JOIN %%FLEETS_EVENT%% ON fleetID = fleet_id
                        WHERE fleet_id = :fleetId;';
                $db->delete($sql, array(':fleetId' => $fleetId));

                $db->update(
                    'UPDATE %%LOG_FLEETS%% SET fleet_state = :state WHERE fleet_id = :fleetId;',
                    array(':state' => FLEET_HOLD, ':fleetId' => $fleetId)
                );
            } else {
                $fleetArray = substr($fleetArray, 0, -1);

                $db->update(
                    "UPDATE %%FLEETS%% SET
                        fleet_array  = :fleetData,
                        fleet_amount = :fleetCount,
                        fleet_mess   = 1
                        WHERE fleet_id = :fleetId;",
                    array(
                        ':fleetData'  => $fleetArray,
                        ':fleetCount' => $totalCount,
                        ':fleetId'    => $fleetId,
                    )
                );

                $db->update(
                    "UPDATE %%LOG_FLEETS%% SET
                        fleet_array  = :fleetData,
                        fleet_amount = :fleetCount
                        WHERE fleet_id = :fleetId;",
                    array(
                        ':fleetData'  => $fleetArray,
                        ':fleetCount' => $totalCount,
                        ':fleetId'    => $fleetId,
                    )
                );
            }
        }

        // ═══════════════════════════════════════════════════════════
        // 15) Informe de batalla
        // ═══════════════════════════════════════════════════════════
        $reportID = null;

        if (class_exists('PveBattleReportHelper')) {
            $attackerIds = array();
            foreach ($validFleets as $f) {
                $attackerIds[] = (int) $f['fleet_owner'];
            }

            $reportID = PveBattleReportHelper::save(
                $combatResult,
                $this->_fleet,
                array(),                 // sin robo de recursos
                $attackerIds,            // atacantes (jugadores reales)
                array($ghostUserId)      // defensor: el fantasma (user_id 900M+)
            );

            if (empty($reportID)) {
                PVEHelper::log('boss', (int) $event['id'], 'report_generation_failed', 0, 0, array(
                    'ghost_id' => (int) $ghost['id'],
                ));
            }
        }

        // ═══════════════════════════════════════════════════════════
        // 16) Mensaje a cada atacante
        // ═══════════════════════════════════════════════════════════
        $newHpForMsg = max(0, (int) $ghost['hp_current'] - $damageToBoss);
        $hpMax       = max(1, (int) $ghost['hp_max']);
        $hpPctAfter  = round($newHpForMsg / $hpMax * 100, 1);

        // Cargar ally_name y ally_tag (no vienen en getRegistrationByGhost)
        $allyInfo = $db->selectSingle(
            "SELECT ally_name, ally_tag FROM %%ALLIANCE%% WHERE id = :aid LIMIT 1;",
            array(':aid' => (int) $registration['ally_id'])
        );
        $allyName = !empty($allyInfo['ally_name']) ? $allyInfo['ally_name'] : ('Alianza #' . $registration['ally_id']);
        $allyTag  = !empty($allyInfo['ally_tag'])  ? $allyInfo['ally_tag']  : '?';

        foreach ($validFleets as $fleetDetail) {
            $ownerId = (int) $fleetDetail['fleet_owner'];
            $fleetId = (int) $fleetDetail['fleet_id'];

            $user = $db->selectSingle(
                "SELECT * FROM %%USERS%% WHERE id = :uid LIMIT 1;",
                array(':uid' => $ownerId)
            );
            if (empty($user)) continue;

            $survivingUnits = isset($fleetAttack[$fleetId]['unit'])
                ? (int) array_sum($fleetAttack[$fleetId]['unit'])
                : 0;

            $this->sendPlayerMessage(
                $user,
                $event,
                $ghost,
                $registration,
                $allyName,
                $allyTag,
                $combatResult,
                $damageToBoss,
                $hpPctAfter,
                $killed,
                $phaseChanged,
                $newPhase,
                (int) $survivingUnits,
                $reportID
            );
        }

        // ═══════════════════════════════════════════════════════════
        // 17) Limpiar AKS + invitaciones si es ACS
        // ═══════════════════════════════════════════════════════════
        if ($acsId > 0) {
            try {
                $db->delete("DELETE FROM %%AKS%% WHERE id = :id;", array(':id' => $acsId));
                $db->delete("DELETE FROM %%USERS_ACS%% WHERE acsID = :id;", array(':id' => $acsId));
                $db->delete("DELETE FROM %%PVE_ACS_INVITES%% WHERE acs_id = :id;", array(':id' => $acsId));
            } catch (Throwable $e) {
                // Silencioso
            }
        }

        // ═══════════════════════════════════════════════════════════
        // 18) Log final
        // ═══════════════════════════════════════════════════════════
        PVEHelper::log('boss', (int) $event['id'], 'combat_resolved', 0, 0, array(
            'acs_id'        => $acsId,
            'ghost_id'      => (int) $ghost['id'],
            'won'           => $combatResult['won'],
            'damage'        => $damageToBoss,
            'hp_after'      => $newHpForMsg,
            'killed'        => $killed ? 1 : 0,
            'phase_changed' => $phaseChanged ? 1 : 0,
            'new_phase'     => $newPhase,
            'report_id'     => $reportID,
            'top_attacker'  => $topContributorId,
        ));
    }


    /* ============================================================
     *  ACTUALIZAR PLANETA FANTASMA (naves supervivientes)
     * ============================================================ */

    /**
     * Escribe en el planeta fantasma SOLO las naves/defensas que sobrevivieron.
     * Las demás se ponen a 0.
     */
    private function updateGhostPlanetUnits($planetId, array $survivingUnits)
    {
        $db = Database::get();
        $planetsTable = PVEGhostHelper::getTableName('planets');

        // Obtener columnas reales del planeta
        $realCols = array();
        try {
            $dbName = defined('DB_NAME') ? DB_NAME : 'prueba';
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

        // Mapa ID → columna (usamos el mapa público de PVEGhostHelper)
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
            } catch (Throwable $e) {
                // Silencioso
            }
        }
    }


    /* ============================================================
     *  END STAY (no aplica)
     * ============================================================ */

    function EndStayEvent()
    {
        return;
    }


    /* ============================================================
     *  RETORNO DE LA FLOTA
     * ============================================================ */

    function ReturnEvent()
    {
        $fleetId = (int) $this->_fleet['fleet_id'];

        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fid LIMIT 1;",
            array(':fid' => $fleetId)
        );

        if (empty($row)) {
            return;
        }

        $this->RestoreFleet();
    }


    /* ============================================================
     *  MENSAJE AL JUGADOR
     * ============================================================ */

    private function sendPlayerMessage(
        $user, $event, $ghost, $registration,
        $allyName, $allyTag,
        $combatResult, $damage, $hpPctAfter,
        $killed, $phaseChanged, $newPhase,
        $survivingUnits, $reportID = null
    ) {
        try {
            $resultText = 'Empate';
            if ($combatResult['won'] === 'a') {
                $resultText = 'Victoria';
            } elseif ($combatResult['won'] === 'r') {
                $resultText = 'Derrota';
            }

            $title = '🌌 Torneo del Devorador — ' . $event['boss_name'];

            $body  = "<div style='padding:12px;background:#1a0a2e;border-left:4px solid #aa44ff;border-radius:6px;color:#e0e0e0;'>";
            $body .= "<h2 style='color:#dd99ff;margin:0 0 10px;'>🌌 Combate contra el Devorador</h2>";
            $body .= "<p>Alianza: <b>[" . htmlspecialchars($allyTag) . "] " . htmlspecialchars($allyName) . "</b></p>";
            $body .= "<p><b>Resultado:</b> " . $resultText . "</p>";
            $body .= "<p><b>Daño causado:</b> " . number_format((int) $damage) . "</p>";

            if ($killed) {
                $body .= "<p style='color:#88ffbb;font-size:14px;'><b>🏆 ¡HABÉIS DERROTADO AL DEVORADOR!</b></p>";
                $cooldown = (int) PVEHelper::get('boss_respawn_cooldown_min', 5);
                $body .= "<p style='color:#ffee88;'>Un nuevo Devorador aparecerá en ~" . $cooldown . " minutos.</p>";
            } else {
                $body .= "<p><b>HP del Devorador:</b> " . $hpPctAfter . "% (" . number_format((int) $ghost['hp_current'] - (int) $damage) . " / " . number_format((int) $ghost['hp_max']) . ")</p>";

                if ($phaseChanged && $newPhase > 0) {
                    $phaseNames = array(
                        2 => 'II — Enfurecido',
                        3 => 'III — Último Aliento',
                    );
                    $phaseLabel = isset($phaseNames[$newPhase]) ? $phaseNames[$newPhase] : ('Fase ' . $newPhase);
                    $body .= "<p style='color:#ff8888;'><b>⚠️ ¡El Devorador ha entrado en FASE {$phaseLabel}!</b></p>";
                }
            }

            $body .= "<p><b>Tus naves supervivientes:</b> " . number_format((int) $survivingUnits) . "</p>";

            if (!empty($reportID)) {
                $body .= '<p><a href="game.php?page=raport&raport=' . $reportID . '" target="_blank" style="display:inline-block;padding:6px 14px;background:#1e3a5a;border:1px solid #4a9eff;border-radius:4px;color:#4a9eff;font-weight:bold;text-decoration:none;">&raquo; Ver informe de batalla completo</a></p>';
            }

            $body .= "<p style='font-size:11px;color:#9ca3af;margin-top:12px;'><a href='game.php?page=pve&mode=boss' style='color:#dd99ff;'>→ Ir al panel del torneo</a></p>";
            $body .= "</div>";

            PlayerUtil::sendMessage(
                $user['id'], 0, 'Torneo del Devorador', 3, $title, $body,
                TIMESTAMP, null, 1, $user['universe']
            );
        } catch (Exception $e) {
            PVEHelper::log('boss', (int) $event['id'], 'msg_error', (int) $user['id'], 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }
}