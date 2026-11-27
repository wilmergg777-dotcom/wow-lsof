<?php

/**
 * AstroIO — MissionCasePveEmpire
 * Procesa la llegada de una flota (o grupo ACS) de jugadores al imperio.
 *
 * v3.1 — FIX CRÍTICO ACS:
 *        El guard original marcaba las flotas del grupo como RETURN ANTES
 *        de recolectarlas, por lo que solo combatía la flota disparadora.
 *        Ahora:
 *          1) GUARD — verificamos que NUESTRA flota siga en Target.
 *          2) GATHER — recolectamos TODAS las flotas del grupo en Target.
 *          3) MARK — marcamos TODAS como RETURN (previene doble combate).
 *          4) Combatimos con TODAS las flotas combinadas.
 *
 *        Además: logs defensivos, ReturnEvent guard, damage solo con recursos.
 *
 * v3.2 — INFORME DE BATALLA:
 *        - Genera informe en %%RW%% usando PveBattleReportHelper
 *        - Añade enlace "Ver informe de batalla" al mensaje del jugador
 *
 *  - mission 21 (custom PvE): fleet_end_id = 1000000000 + empireId
 *  - mission 1  (ATTACK):     fleet_end_id = 900000000 + empireId (ghost user)
 *  - mission 3  (AKS_ATTACK): fleet_end_id = 900000000 + empireId (ghost user)
 *
 * Ubicación: includes/classes/missions/MissionCasePveEmpire.class.php
 * @package AstroIO
 * @version 3.2
 */

// ═══════════════════════════════════════════════════════════════════
// ASTROIO — Dependencias PvE
// ═══════════════════════════════════════════════════════════════════
if (!class_exists('PveFleetHelper')) {
    require_once ROOT_PATH.'includes/classes/PveFleetHelper.class.php';
}
if (!class_exists('PVEHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVEEmpireHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEEmpireHelper.class.php';
}
if (!class_exists('PVEGhostHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';
}
if (!class_exists('PveBattleReportHelper')) {
    require_once ROOT_PATH.'includes/classes/PveBattleReportHelper.class.php';
}

class MissionCasePveEmpire extends MissionFunctions implements Mission
{
    function __construct($Fleet)
    {
        $this->_fleet = $Fleet;
    }


    /* ============================================================
     *  LLEGADA AL IMPERIO (combate + ACS)
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
            PVEHelper::log('empire', 0, 'fleet_deleted_before_processing', 0, 0, array(
                'fleet_id' => $myFleetId,
            ));
            return;
        }

        if ((int) $rowCheck['fleet_mess'] !== 0) {
            PVEHelper::log('empire', 0, 'fleet_already_processed', 0, 0, array(
                'fleet_id'   => $myFleetId,
                'fleet_mess' => (int) $rowCheck['fleet_mess'],
            ));
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 0b) GATHER — recolectar TODAS las flotas del grupo ACS
        //     en Target ANTES de marcarlas como RETURN.
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

        PVEHelper::log('empire', 0, 'acs_fleets_gathered', 0, $endId, array(
            'acs_id'     => $acsId,
            'trigger_id' => $myFleetId,
            'fleets'     => count($allFleets),
        ));
        // ═══════════════════════════════════════════════════════════
        // FIN GUARD / GATHER / MARK
        // ═══════════════════════════════════════════════════════════

        // ─── 1) Obtener empire_id ───
        $fleetMission = (int) $this->_fleet['fleet_mission'];
        $fleetEndId   = $endId;
        $empireId     = 0;

        if ($fleetMission == MISSION_PVE_EMPIRE) {
            // Flujo CUSTOM (mission=21):
            // fleet_end_id = EMPIRE_ID_OFFSET (1000000000) + empireId
            $empireId = $fleetEndId - PveFleetHelper::EMPIRE_ID_OFFSET;
        } else {
            // Flujo NATIVO (mission=1 o 3):
            // fleet_end_id = ghost_user_id (900000000 + empireId)
            // → usar el registro del fantasma para obtener el empire_id real
            $ghost = PVEGhostHelper::getGhostByUserId($fleetEndId);
            if (!empty($ghost) && (int) $ghost['event_id'] > 0) {
                $empireId = (int) $ghost['event_id'];
            } else {
                // Fallback (nunca debería pasar)
                $empireId = $fleetEndId - PVEGhostHelper::ID_BASE;
            }
        }

        if ($empireId <= 0) {
            PVEHelper::log('empire', 0, 'empire_id_invalid', 0, $fleetEndId, array(
                'fleet_id'     => $myFleetId,
                'fleet_mission'=> $fleetMission,
                'fleet_end_id' => $fleetEndId,
            ));
            $this->KillFleet();
            return;
        }

        $sql = "SELECT * FROM %%PVE_EMPIRES%% WHERE id = :id LIMIT 1;";
        $empire = $db->selectSingle($sql, array(':id' => $empireId));

        if (empty($empire) || $empire['status'] !== 'active') {
            PVEHelper::log('empire', $empireId, 'empire_not_active', 0, 0, array(
                'fleet_id' => $myFleetId,
            ));
            $this->setState(FLEET_RETURN);
            $this->SaveFleet();
            return;
        }

        // NOTA: $allFleets ya está cargado arriba (sección 0b). No recargar.

        // ─── 3) Construir atacantes ───
        $fleetAttack = array();

        foreach ($allFleets as $fleetDetail) {
            $fleetId = (int) $fleetDetail['fleet_id'];
            $ownerId = (int) $fleetDetail['fleet_owner'];

            $sql = "SELECT * FROM %%USERS%% WHERE id = :uid LIMIT 1;";
            $user = $db->selectSingle($sql, array(':uid' => $ownerId));

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
                $db->update(
                    "UPDATE %%FLEETS%% SET fleet_mess = 1 WHERE fleet_id = :id;",
                    array(':id' => (int) $f['fleet_id'])
                );
            }
            return;
        }

        // ─── 4) Construir defensor (el FANTASMA con sus naves y defensas reales) ───
        $empireUnits = PVEEmpireHelper::buildEmpireFleet($empire);

        if (empty($empireUnits)) {
            // Imperio sin naves → victoria automática
            foreach ($allFleets as $f) {
                $this->_fleet = $f;
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
            }
            return;
        }

        // Guardar copia inicial para saber qué se destruyó
        $initialEmpireUnits = $empireUnits;

        // Leer datos del planeta fantasma (solo para actualizar naves/defensas tras el combate)
        $ghostPlanetId = (int) ($empire['ghost_planet_id'] ?? 0);
        $ghostPlanet = null;
        if ($ghostPlanetId > 0) {
            $sql = "SELECT * FROM %%PLANETS%% WHERE id = :pid LIMIT 1;";
            $ghostPlanet = $db->selectSingle($sql, array(':pid' => $ghostPlanetId));
        }

        $fleetDefend = array(
            $empireId => array(
                'player' => array(
                    'id'            => 0,
                    'username'      => $empire['name'],
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
                    'fleet_start_galaxy'       => (int) $empire['galaxy'],
                    'fleet_start_system'       => (int) $empire['system'],
                    'fleet_start_planet'       => (int) $empire['planet'],
                    'fleet_start_type'         => 1,
                    'fleet_resource_metal'     => 0,
                    'fleet_resource_crystal'   => 0,
                    'fleet_resource_deuterium' => 0,
                ),
                'unit' => $empireUnits,
            ),
        );

        // ─── 5) Ejecutar combate ───
        require_once ROOT_PATH.'includes/classes/missions/functions/calculateAttack.php';

        $combatResult = calculateAttack(
            $fleetAttack,
            $fleetDefend,
            $config->Fleet_Cdr,
            $config->Defs_Cdr
        );

        // ─── 6) Naves supervivientes del DEFENSOR (el fantasma) ───
        $survivingEmpireUnits = isset($fleetDefend[$empireId]['unit'])
            ? $fleetDefend[$empireId]['unit']
            : array();

        // ─── 7) Actualizar planeta fantasma con las naves/defensas supervivientes ───
        if ($ghostPlanetId > 0 && is_array($ghostPlanet)) {
            $this->updateGhostPlanetUnits($ghostPlanetId, $survivingEmpireUnits);
        }

        // ─── 8) Calcular daño al imperio (por valor de unidades destruidas) ───
        $damageToEmpire = $this->calculateDamageFromLosses($initialEmpireUnits, $survivingEmpireUnits);

        // v3.0 — Anticipar si va a ser destruido ANTES de aplicar el daño,
        //         para poder repartir recursos con el fantasma aún vivo.
        $previousHp      = (int) $empire['current_hp'];
        $willBeDestroyed = ($previousHp - $damageToEmpire) <= 0;

        // ─── 9) Aplicar pérdidas a cada atacante ───
        foreach ($allFleets as $fleetDetail) {
            $fleetId = (int) $fleetDetail['fleet_id'];
            $ownerId = (int) $fleetDetail['fleet_owner'];

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

                $sql = 'UPDATE %%LOG_FLEETS%% SET fleet_state = :state WHERE fleet_id = :fleetId;';
                $db->update($sql, array(':state' => FLEET_HOLD, ':fleetId' => $fleetId));
            } else {
                $fleetArray = substr($fleetArray, 0, -1);

                $sql = "UPDATE %%FLEETS%% SET
                    fleet_array  = :fleetData,
                    fleet_amount = :fleetCount,
                    fleet_mess   = 1
                    WHERE fleet_id = :fleetId;";
                $db->update($sql, array(
                    ':fleetData'  => $fleetArray,
                    ':fleetCount' => $totalCount,
                    ':fleetId'    => $fleetId,
                ));

                $sql = "UPDATE %%LOG_FLEETS%% SET
                    fleet_array  = :fleetData,
                    fleet_amount = :fleetCount
                    WHERE fleet_id = :fleetId;";
                $db->update($sql, array(
                    ':fleetData'  => $fleetArray,
                    ':fleetCount' => $totalCount,
                    ':fleetId'    => $fleetId,
                ));
            }
        }

        // ─── 10) Registrar ataque de cada contribuyente ───
        // v3.0 — MOVIDO ANTES de grantEmpireRewards y ANTES de applyDamage.
        foreach ($allFleets as $fleetDetail) {
            $fleetId = (int) $fleetDetail['fleet_id'];
            $ownerId = (int) $fleetDetail['fleet_owner'];

            $shipsSent = FleetFunctions::unserialize($fleetDetail['fleet_array']);
            $shipsLost = self::countInitialUnits($fleetDetail['fleet_array'])
                       - self::countCurrentUnits($fleetAttack[$fleetId]['unit'] ?? array());

            // Daño proporcional al aporte de naves
            $userDamage = 0;
            if (!empty($shipsSent)) {
                $userShips = array_sum($shipsSent);
                $totalShips = 0;
                foreach ($allFleets as $f) {
                    $totalShips += array_sum(FleetFunctions::unserialize($f['fleet_array']));
                }
                if ($totalShips > 0) {
                    $userDamage = (int) round($damageToEmpire * ($userShips / $totalShips));
                }
            }

            PVEEmpireHelper::registerAttack(
                $empireId,
                $ownerId,
                (int) $fleetDetail['fleet_start_id'],
                $fleetId,
                $shipsSent,
                $shipsLost,
                $userDamage
            );
        }

        // ─── 11) Repartir recompensas si VA A SER destruido ───
        // v3.0 — CRÍTICO: se llama ANTES de applyDamage() para que el planeta
        //         fantasma aún exista y se puedan leer sus recursos reales.
        if ($willBeDestroyed) {
            PVEEmpireHelper::grantEmpireRewards($empireId);
        }

        // ─── 12) Aplicar daño al imperio (esto destruye el fantasma si HP ≤ 0) ───
        $damageResult = PVEEmpireHelper::applyDamage($empireId, $damageToEmpire);
        $newHp        = (int) $damageResult['new_hp'];
        $destroyed    = (bool) $damageResult['destroyed'];

        if ($destroyed) {
            PVEHelper::log('empire', $empireId, 'destroyed_by_acs', 0, 0, array(
                'acs_id'       => $acsId,
                'participants' => count($allFleets),
                'damage'       => $damageToEmpire,
            ));
        }

        // ─── 13) Contraataque del imperio (si NO está destruido) ───
        if (!$destroyed) {
            $this->maybeCounterattack($empire, $allFleets, $damageToEmpire, $survivingEmpireUnits);
        }

        // ─── 13.5) INFORME DE BATALLA PvE (una vez, compartido por todos) ───
        // v3.2 — Genera el reporte en %%RW%% para que el mensaje incluya
        //        el enlace "Ver informe de batalla".
        $reportID = null;

        if (class_exists('PveBattleReportHelper')) {
            $attackerUserIds = array();
            foreach ($allFleets as $f) {
                $attackerUserIds[] = (int) $f['fleet_owner'];
            }

            $reportID = PveBattleReportHelper::save(
                $combatResult,
                $this->_fleet,
                array(),            // Empire no roba recursos → sin steal
                $attackerUserIds,   // atacantes: jugadores reales
                array()             // defensor: imperio (id 0 → se filtra a "-1")
            );

            if (empty($reportID)) {
                PVEHelper::log('empire', $empireId, 'report_generation_failed', 0, 0, array(
                    'fleet_id' => $myFleetId,
                ));
            }
        }

        // ─── 14) Mensaje a cada participante ───
        foreach ($allFleets as $fleetDetail) {
            $ownerId = (int) $fleetDetail['fleet_owner'];
            $fleetId = (int) $fleetDetail['fleet_id'];

            $sql = "SELECT * FROM %%USERS%% WHERE id = :uid LIMIT 1;";
            $user = $db->selectSingle($sql, array(':uid' => $ownerId));

            if (empty($user)) continue;

            $survivingUnits = isset($fleetAttack[$fleetId]['unit'])
                ? array_sum($fleetAttack[$fleetId]['unit'])
                : 0;

            $this->sendPlayerMessage(
                $user,
                $empire,
                $combatResult,
                $damageToEmpire,
                $newHp,
                $destroyed,
                (int) $survivingUnits,
                $reportID
            );
        }

        // ─── 15) Limpiar AKS + invitaciones si es ACS ───
        if ($acsId > 0) {
            $sql = "DELETE FROM %%AKS%% WHERE id = :id;";
            $db->delete($sql, array(':id' => $acsId));

            $sql = "DELETE FROM %%USERS_ACS%% WHERE acsID = :id;";
            $db->delete($sql, array(':id' => $acsId));

            // Limpiar invitaciones PvE huérfanas
            try {
                $sql = "DELETE FROM %%PVE_ACS_INVITES%% WHERE acs_id = :id;";
                $db->delete($sql, array(':id' => $acsId));
            } catch (Throwable $e) {
                // Silencioso — por si la tabla no existe todavía
            }
        }

        // ─── 16) Log final ───
        PVEHelper::log('empire', $empireId, 'combat_resolved', 0, 0, array(
            'acs_id'    => $acsId,
            'won'       => $combatResult['won'],
            'damage'    => $damageToEmpire,
            'new_hp'    => $newHp,
            'destroyed' => $destroyed,
            'report_id' => $reportID,
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

        // Obtener mapa ID → columna
        $columnMap = $this->getColumnMap();

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

        // Recorrer todas las unidades del mapa y poner 0 o el valor superviviente
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
     *  CÁLCULO DE DAÑO (por valor de unidades destruidas)
     * ============================================================ */

    private function calculateDamageFromLosses($initialUnits, $survivingUnits)
    {
        global $pricelist;

        $damage = 0;

        // Solo contar recursos reales (metal 901, cristal 902, deuterio 903)
        $resourceKeys = array(901, 902, 903);

        foreach ($initialUnits as $unitId => $count) {
            $unitId = (int) $unitId;
            $count  = (int) $count;
            if ($count <= 0) continue;

            $left = isset($survivingUnits[$unitId]) ? (int) $survivingUnits[$unitId] : 0;
            $lost = max(0, $count - $left);

            if ($lost <= 0) continue;

            // Valor en recursos de una unidad destruida (metal + crystal + deuterium)
            $cost = 0;
            if (isset($pricelist[$unitId]['cost']) && is_array($pricelist[$unitId]['cost'])) {
                foreach ($resourceKeys as $resId) {
                    if (isset($pricelist[$unitId]['cost'][$resId])) {
                        $cost += (int) $pricelist[$unitId]['cost'][$resId];
                    }
                }
            }

            // Si no hay precio, usar 1000 como fallback
            if ($cost <= 0) $cost = 1000;

            $damage += $lost * $cost;
        }

        // Reducir a la mitad (para no romper el balance)
        return (int) floor($damage * 0.5);
    }


    /* ============================================================
     *  MAPA DE COLUMNAS (ID → nombre)
     * ============================================================ */

    /**
     * Mapa de unidades PvE (naves + defensas) → columna en uni1_planets.
     * Se obtiene desde PVEGhostHelper (que lo tiene hardcodeado).
     */
    private function getColumnMap()
    {
        // Reflejar el mapa de PVEGhostHelper
        $reflection = new ReflectionClass('PVEGhostHelper');
        $prop = $reflection->getProperty('columnMap');
        $prop->setAccessible(true);
        return $prop->getValue();
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

        // Verificar que la flota siga existiendo y en estado RETURN
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fid LIMIT 1;",
            array(':fid' => $fleetId)
        );

        if (empty($row)) {
            // Flota ya eliminada (perdió todas las naves) → nada que restaurar
            return;
        }

        // Restaurar naves/recursos de vuelta al planeta de origen
        $this->RestoreFleet();
    }


    /* ============================================================
     *  CONTRATAQUE DEL IMPERIO
     * ============================================================ */

    private function maybeCounterattack($empire, $allFleets, $damageToEmpire, $survivingUnits)
    {
        $counterPct = (int) PVEHelper::get('empire_counterattack_pct', 30);
        if ($counterPct <= 0) return;

        if (mt_rand(1, 100) > $counterPct) return;

        if (empty($allFleets)) return;

        // Elige un atacante al azar
        $randomFleet = $allFleets[array_rand($allFleets)];
        $targetUserId   = (int) $randomFleet['fleet_owner'];
        $targetPlanetId = (int) $randomFleet['fleet_start_id'];

        if ($targetUserId <= 0 || $targetPlanetId <= 0) return;

        // Cantidad de naves del contraataque: % de las naves SUPERVIVIENTES del imperio
        $counterShipPct = (int) PVEHelper::get('empire_counter_naves', 20);
        if ($counterShipPct <= 0) $counterShipPct = 20;

        if (empty($survivingUnits)) return;

        $counterFleet = array();
        foreach ($survivingUnits as $shipId => $count) {
            $shipId = (int) $shipId;
            $count  = (int) $count;
            if ($shipId <= 0 || $count <= 0) continue;

            $sendCount = (int) floor($count * $counterShipPct / 100);
            if ($sendCount > 0) {
                $counterFleet[$shipId] = $sendCount;
            }
        }

        if (empty($counterFleet)) return;

        $counterFleetId = PveFleetHelper::sendCounterAttackFleet(
            $empire,
            $targetUserId,
            $targetPlanetId,
            $counterFleet
        );

        if (!empty($counterFleetId)) {
            PVEHelper::log('empire', (int) $empire['id'], 'counterattack_sent', $targetUserId, $targetPlanetId, array(
                'counter_fleet_id' => $counterFleetId,
                'ships'            => array_sum($counterFleet),
                'prob_pct'         => $counterPct,
            ));
        }
    }


    /* ============================================================
     *  MENSAJE AL JUGADOR
     * ============================================================ */

    private function sendPlayerMessage($user, $empire, $combatResult, $damage, $newHp, $destroyed, $survivingUnits, $reportID = null)
    {
        try {
            $title = "[PvE] Ataque a " . $empire['name'];

            $resultText = 'Empate';
            if ($combatResult['won'] === 'a') {
                $resultText = 'Victoria';
            } elseif ($combatResult['won'] === 'r') {
                $resultText = 'Derrota';
            }

            $body  = "Atacaste <b>" . $empire['name'] . "</b> en [" . (int) $empire['galaxy'] . ":" . (int) $empire['system'] . ":" . (int) $empire['planet'] . "].<br><br>";
            $body .= "<b>Resultado:</b> " . $resultText . "<br>";
            $body .= "<b>Daño causado (colectivo):</b> " . number_format((int) $damage) . "<br>";
            $body .= "<b>HP imperio ahora:</b> " . number_format($newHp) . " / " . number_format((int) $empire['total_hp']) . "<br>";
            $body .= "<b>Naves perdidas:</b> " . number_format((int) $combatResult['unitLost']['attacker']) . "<br>";
            $body .= "<b>Tus naves supervivientes:</b> " . number_format($survivingUnits) . "<br>";

            if ($destroyed) {
                $body .= "<br><b style='color: #ffdd88;'>&iexcl;IMPERIO DESTRUIDO!</b><br>";
                $body .= "El bot&iacute;n de recursos se ha repartido entre todos los atacantes seg&uacute;n el da&ntilde;o causado.<br>";
                $body .= "Reclama tu recompensa en la p&aacute;gina PvE (<i>game.php?page=pve</i>).";
            }

            // ─── Enlace al informe de batalla (si se generó correctamente) ───
            if (!empty($reportID)) {
                $body .= '<br><br><a href="game.php?page=raport&raport=' . $reportID . '" target="_blank" style="display:inline-block;padding:6px 14px;background:#1e3a5a;border:1px solid #4a9eff;border-radius:4px;color:#4a9eff;font-weight:bold;text-decoration:none;">&raquo; Ver informe de batalla completo</a>';
            }

            PlayerUtil::sendMessage(
                $user['id'], 0, 'Comando Central PvE', 3, $title, $body,
                TIMESTAMP, null, 1, $user['universe']
            );
        } catch (Exception $e) {
            PVEHelper::log('empire', (int) $empire['id'], 'msg_error', $user['id'], 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }


    /* ============================================================
     *  UTILIDADES
     * ============================================================ */

    private static function countInitialUnits($fleetArrayStr)
    {
        $units = FleetFunctions::unserialize($fleetArrayStr);
        if (empty($units)) return 0;
        return array_sum($units);
    }


    private static function countCurrentUnits($units)
    {
        if (empty($units) || !is_array($units)) return 0;
        $total = 0;
        foreach ($units as $amount) {
            $total += (int) $amount;
        }
        return $total;
    }
}