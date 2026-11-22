<?php

/**
 * AstroIO — MissionCasePveBastion
 *
 * Procesa la llegada de una flota (o grupo ACS) de jugadores al fantasma ALIADO
 * del BASTIÓN ASEDIADO (misión 24 = MISSION_PVE_BASTION).
 *
 * Flujo:
 *   1) Jugador envía flota con mission=24 al Bastión (coords del fantasma)
 *   2) Al llegar → esta misión recoge las naves + recursos de las flotas
 *   3) Suma las naves al planeta fantasma del Bastión (refuerzo real)
 *   4) Registra la contribución en uni1_pve_bastion_damage
 *   5) ELIMINA la flota (no vuelve — las naves quedan en el Bastión)
 *   6) Notifica a cada atacante
 *
 * Al final del evento, PVEBastionHelper::returnReinforcementsToAll() devuelve
 * los sobrevivientes al planeta principal de cada jugador proporcionalmente.
 *
 * ★ v1.1 — El logro "Veterano del Bastión" se dispara automáticamente desde
 * PVEBastionHelper::registerReinforcement() (que incrementa
 * bastion_events_played la primera vez que un jugador refuerza en un evento).
 *
 * Reutiliza: PVEHelper, PVEGhostHelper, PVEBastionHelper.
 *
 * Ubicación: includes/classes/missions/MissionCasePveBastion.class.php
 * @package AstroIO
 * @subpackage PvE
 * @version 1.1
 */

if (!class_exists('PVEHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVEGhostHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';
}
if (!class_exists('PVEBastionHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEBastionHelper.class.php';
}

class MissionCasePveBastion extends MissionFunctions implements Mission
{
    function __construct($Fleet)
    {
        $this->_fleet = $Fleet;
    }

    /* ============================================================
     *  LLEGADA AL BASTIÓN (añade refuerzos)
     * ============================================================ */

    function TargetEvent()
    {
        $db = Database::get();

        $myFleetId = (int) $this->_fleet['fleet_id'];

        // ═══════════════════════════════════════════════════════════
        // 0) GUARD anti-doble-procesamiento
        // ═══════════════════════════════════════════════════════════
        $rowCheck = $db->selectSingle(
            "SELECT fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fid LIMIT 1;",
            array(':fid' => $myFleetId)
        );

        if (empty($rowCheck)) {
            PVEHelper::log('bastion', 0, 'fleet_deleted_before_processing', 0, 0, array(
                'fleet_id' => $myFleetId,
            ));
            return;
        }

        if ((int) $rowCheck['fleet_mess'] !== 0) {
            PVEHelper::log('bastion', 0, 'fleet_already_processed', 0, 0, array(
                'fleet_id'   => $myFleetId,
                'fleet_mess' => (int) $rowCheck['fleet_mess'],
            ));
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 0b) GATHER flotas del grupo ACS
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

        // Marcar TODAS como procesadas (evita doble combate)
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

        PVEHelper::log('bastion', 0, 'reinforcement_fleets_gathered', 0, $endId, array(
            'acs_id'     => $acsId,
            'trigger_id' => $myFleetId,
            'fleets'     => count($allFleets),
        ));

        // ═══════════════════════════════════════════════════════════
        // 1) Detectar el Bastión por fleet_end_id (ghost_user_id)
        // ═══════════════════════════════════════════════════════════
        $ghostUserId = $endId;

        $registration = PVEBastionHelper::getRegistrationByGhost($ghostUserId);

        // Fallback por ghost_planet_id
        if (empty($registration)) {
            try {
                $registration = $db->selectSingle(
                    "SELECT r.* 
                     FROM %%PVE_BASTION_GHOSTS%% g
                     INNER JOIN %%PVE_BASTION_REGISTRATIONS%% r ON r.id = g.registration_id
                     WHERE g.ghost_planet_id = :pid AND g.status = 'active'
                     LIMIT 1;",
                    array(':pid' => $endId)
                );
            } catch (Throwable $e) {
                $registration = null;
            }
        }

        if (empty($registration)) {
            PVEHelper::log('bastion', 0, 'registration_not_found', 0, $endId, array(
                'fleet_id' => $myFleetId,
            ));
            $this->deleteFleetsWithoutRefund($allFleets);
            return;
        }

        if ($registration['status'] !== 'active') {
            PVEHelper::log('bastion', (int) $registration['event_id'], 'registration_not_active', 0, 0, array(
                'reg_id' => (int) $registration['id'],
                'status' => $registration['status'],
            ));
            $this->deleteFleetsWithoutRefund($allFleets);
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 2) Cargar evento activo
        // ═══════════════════════════════════════════════════════════
        $event = PVEBastionHelper::getEvent((int) $registration['event_id']);
        if (empty($event) || $event['status'] !== 'active') {
            $this->deleteFleetsWithoutRefund($allFleets);
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 3) Cargar bastión activo
        // ═══════════════════════════════════════════════════════════
        $ghost = PVEBastionHelper::getActiveGhostForRegistration((int) $registration['id']);
        if (empty($ghost)) {
            PVEHelper::log('bastion', (int) $event['id'], 'bastion_not_active', 0, 0, array(
                'reg_id' => (int) $registration['id'],
            ));
            $this->deleteFleetsWithoutRefund($allFleets);
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
            PVEHelper::log('bastion', (int) $event['id'], 'no_valid_reinforcers', 0, 0, array(
                'reg_id'     => (int) $registration['id'],
                'owner_ally' => $ownerAllyId,
            ));
            $this->deleteFleetsWithoutRefund($allFleets);
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 5) Cargar planeta del bastión
        // ═══════════════════════════════════════════════════════════
        $ghostPlanetId = (int) $ghost['ghost_planet_id'];
        $ghostPlanet = $db->selectSingle(
            "SELECT * FROM %%PLANETS%% WHERE id = :pid LIMIT 1;",
            array(':pid' => $ghostPlanetId)
        );

        if (empty($ghostPlanet)) {
            PVEHelper::log('bastion', (int) $event['id'], 'bastion_planet_missing', 0, 0, array(
                'ghost_planet_id' => $ghostPlanetId,
            ));
            $this->deleteFleetsWithoutRefund($allFleets);
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 6) Añadir naves + recursos al planeta del Bastión
        //    Registrar la contribución de cada jugador
        // ═══════════════════════════════════════════════════════════
        $columnMap = PVEGhostHelper::$columnMap;
        $realCols  = $this->getRealPlanetColumns();

        $allyName = !empty($registration['ally_name']) ? $registration['ally_name'] : ('Alianza #' . $ownerAllyId);
        $allyTag  = !empty($registration['ally_tag'])  ? $registration['ally_tag']  : '?';

        $totalReinforcedAll = 0;
        $processedUsers = array();

        foreach ($validFleets as $fleetDetail) {
            $fleetId = (int) $fleetDetail['fleet_id'];
            $ownerId = (int) $fleetDetail['fleet_owner'];

            $user = $db->selectSingle(
                "SELECT * FROM %%USERS%% WHERE id = :uid LIMIT 1;",
                array(':uid' => $ownerId)
            );
            if (empty($user)) continue;

            $units = FleetFunctions::unserialize($fleetDetail['fleet_array']);
            if (empty($units) || !is_array($units)) continue;

            // Añadir naves al planeta del bastión
            $userShipsSent = 0;
            foreach ($units as $shipId => $count) {
                $shipId = (int) $shipId;
                $count  = (int) $count;
                if ($shipId <= 0 || $count <= 0) continue;

                $colName = isset($columnMap[$shipId]) ? $columnMap[$shipId] : '';
                if (empty($colName) || !in_array($colName, $realCols, true)) continue;

                try {
                    $db->update(
                        "UPDATE %%PLANETS%% SET `{$colName}` = `{$colName}` + :amt WHERE id = :pid;",
                        array(':amt' => $count, ':pid' => $ghostPlanetId)
                    );
                    $userShipsSent += $count;
                } catch (Throwable $e) {
                    // ignorar columnas problemáticas
                }
            }

            // Añadir recursos al planeta del bastión
            $metal     = (int) ($fleetDetail['fleet_resource_metal']     ?? 0);
            $crystal   = (int) ($fleetDetail['fleet_resource_crystal']   ?? 0);
            $deuterium = (int) ($fleetDetail['fleet_resource_deuterium'] ?? 0);

            if ($metal > 0 || $crystal > 0 || $deuterium > 0) {
                try {
                    $db->update(
                        "UPDATE %%PLANETS%% SET
                            metal     = metal     + :m,
                            crystal   = crystal   + :c,
                            deuterium = deuterium + :d
                         WHERE id = :pid;",
                        array(
                            ':m'   => $metal,
                            ':c'   => $crystal,
                            ':d'   => $deuterium,
                            ':pid' => $ghostPlanetId,
                        )
                    );
                } catch (Throwable $e) {}
            }

            if ($userShipsSent <= 0 && $metal <= 0 && $crystal <= 0 && $deuterium <= 0) continue;

            // Registrar la contribución (naves enviadas)
            // ★ v1.1 — Esta llamada dispara internamente
            //   PVEAchievementHelper::recordBastionPlayed() la primera vez
            //   que el jugador refuerza en este evento (logro "Veterano del Bastión").
            if ($userShipsSent > 0) {
                PVEBastionHelper::registerReinforcement(
                    (int) $event['id'],
                    (int) $registration['id'],
                    (int) $ownerAllyId,
                    $ownerId,
                    $userShipsSent
                );
            }

            $totalReinforcedAll += $userShipsSent;
            $processedUsers[$ownerId] = array(
                'user'  => $user,
                'ships' => $userShipsSent,
                'metal' => $metal,
                'crystal' => $crystal,
                'deuterium' => $deuterium,
            );

            PVEHelper::log('bastion', (int) $event['id'], 'reinforcement_arrived', $ownerId, $ghostPlanetId, array(
                'registration_id' => (int) $registration['id'],
                'fleet_id'        => $fleetId,
                'ships'           => $userShipsSent,
                'metal'           => $metal,
                'crystal'         => $crystal,
                'deuterium'       => $deuterium,
            ));
        }

        // ═══════════════════════════════════════════════════════════
        // 7) Notificar a cada atacante
        // ═══════════════════════════════════════════════════════════
        foreach ($processedUsers as $userId => $data) {
            $this->sendReinforcementMessage(
                $data['user'],
                $event,
                $ghost,
                $registration,
                $allyName,
                $allyTag,
                $data['ships'],
                $data['metal'],
                $data['crystal'],
                $data['deuterium']
            );
        }

        // ═══════════════════════════════════════════════════════════
        // 8) Recalcular scores globales del evento
        // ═══════════════════════════════════════════════════════════
        PVEBastionHelper::recomputeAllScores((int) $event['id']);

        // ═══════════════════════════════════════════════════════════
        // 9) ELIMINAR las flotas (no vuelven — las naves están ya en el bastión)
        // ═══════════════════════════════════════════════════════════
        $this->deleteFleetsWithoutRefund($validFleets);

        // Limpieza ACS si aplica
        if ($acsId > 0) {
            try {
                $db->delete("DELETE FROM %%AKS%% WHERE id = :id;", array(':id' => $acsId));
                $db->delete("DELETE FROM %%USERS_ACS%% WHERE acsID = :id;", array(':id' => $acsId));
                $db->delete("DELETE FROM %%PVE_ACS_INVITES%% WHERE acs_id = :id;", array(':id' => $acsId));
            } catch (Throwable $e) {}
        }

        // ═══════════════════════════════════════════════════════════
        // 10) Log final
        // ═══════════════════════════════════════════════════════════
        PVEHelper::log('bastion', (int) $event['id'], 'reinforcement_resolved', 0, 0, array(
            'acs_id'        => $acsId,
            'bastion_id'    => (int) $ghost['id'],
            'ships_total'   => $totalReinforcedAll,
            'users_count'   => count($processedUsers),
        ));
    }


    /* ============================================================
     *  END STAY (no aplica)
     * ============================================================ */

    function EndStayEvent()
    {
        return;
    }


    /* ============================================================
     *  RETORNO (no debería llegar — las flotas se eliminan antes)
     * ============================================================ */

    function ReturnEvent()
    {
        $fleetId = (int) $this->_fleet['fleet_id'];
        $db = Database::get();

        $row = $db->selectSingle(
            "SELECT fleet_mess FROM %%FLEETS%% WHERE fleet_id = :fid LIMIT 1;",
            array(':fid' => $fleetId)
        );

        if (empty($row)) return;

        // Si por algún motivo llegó aquí, restaurar la flota al origen
        $this->RestoreFleet();
    }


    /* ============================================================
     *  HELPERS INTERNOS
     * ============================================================ */

    /**
     * Devuelve las columnas reales de uni1_planets (para hacer UPDATE seguro).
     */
    private function getRealPlanetColumns(): array
    {
        $db = Database::get();
        $planetsTable = PVEGhostHelper::getTableName('planets');

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
        return $realCols;
    }

    /**
     * Elimina las flotas de la BD sin devolver nada al jugador.
     * Las naves ya están "estacionadas" en el planeta del bastión.
     *
     * ★ v1.1 — Fix: antes usaba un INNER JOIN entre FLEETS y FLEETS_EVENT,
     * pero si la fila en FLEETS_EVENT faltaba (flota huérfana), el JOIN
     * no borraba nada y la flota quedaba atascada. Ahora se hacen 2 DELETE
     * independientes, así la flota SIEMPRE se limpia.
     */
    private function deleteFleetsWithoutRefund(array $fleets): void
    {
        if (empty($fleets)) return;

        $db = Database::get();
        foreach ($fleets as $f) {
            $fid = (int) $f['fleet_id'];
            if ($fid <= 0) continue;

            try {
                // 1) Borrar el evento de la flota (si existe)
                try {
                    $db->delete(
                        "DELETE FROM %%FLEETS_EVENT%% WHERE fleetID = :fid;",
                        array(':fid' => $fid)
                    );
                } catch (Throwable $eEvent) {
                    // ignorar si no existe la fila
                }

                // 2) Borrar la flota en sí
                $db->delete(
                    "DELETE FROM %%FLEETS%% WHERE fleet_id = :fid;",
                    array(':fid' => $fid)
                );
            } catch (Throwable $e) {
                // Silencioso
            }
        }
    }

    /**
     * Envía mensaje al jugador confirmando que sus naves están en el bastión.
     */
    private function sendReinforcementMessage(
        array $user,
        array $event,
        array $ghost,
        array $registration,
        string $allyName,
        string $allyTag,
        int $shipsSent,
        int $metal,
        int $crystal,
        int $deuterium
    ): void {
        try {
            $coord = "{$ghost['galaxy']}:{$ghost['system']}:{$ghost['planet']}";

            $body  = "<div style='padding:12px;background:#0a1a2e;border-left:4px solid #44aaff;border-radius:6px;color:#e0e0e0;'>";
            $body .= "<h2 style='color:#99ddff;margin:0 0 10px;'>⚓ REFUERZOS ENTREGADOS</h2>";
            $body .= "<p>Tus naves han llegado al bastión de <b>[" . htmlspecialchars($allyTag) . "] " . htmlspecialchars($allyName) . "</b>.</p>";
            $body .= "<div style='background:#0a0a1a;border-left:3px solid #ffaa33;padding:10px;margin:12px 0;border-radius:4px;'>";
            $body .= "<p style='margin:0 0 6px;font-size:11px;color:#9ca3af;'>📍 BASTIÓN</p>";
            $body .= "<p style='font-size:18px;color:#ffaa33;font-weight:bold;margin:0;'>{$coord}</p>";
            $body .= "</div>";
            $body .= "<table style='width:100%;font-size:12px;color:#d1d5db;'>";
            $body .= "<tr><td>🚀 Naves enviadas:</td><td align='right'><b>" . number_format($shipsSent) . "</b></td></tr>";
            if ($metal > 0 || $crystal > 0 || $deuterium > 0) {
                $body .= "<tr><td>💰 Recursos:</td><td align='right'>";
                if ($metal > 0)     $body .= "🔩 " . number_format($metal) . " ";
                if ($crystal > 0)   $body .= "💠 " . number_format($crystal) . " ";
                if ($deuterium > 0) $body .= "⚗️ " . number_format($deuterium);
                $body .= "</td></tr>";
            }
            $body .= "<tr><td>💚 HP del Bastión:</td><td align='right'><b>" . number_format((int) $ghost['hp_current']) . " / " . number_format((int) $ghost['hp_max']) . "</b></td></tr>";
            $body .= "</table>";
            $body .= "<p style='font-size:11px;color:#9ca3af;margin-top:12px;'>🛡️ Tus naves defenderán el bastión hasta el final del torneo. Los sobrevivientes serán devueltos a tu planeta principal al terminar el evento.</p>";
            $body .= "<p style='font-size:10px;color:#6b7280;margin-top:10px;'>Panel: <a href='game.php?page=pve&mode=bastion' style='color:#99ddff;'>game.php?page=pve&mode=bastion</a></p>";
            $body .= "</div>";

            PlayerUtil::sendMessage(
                (int) $user['id'], 0, 'Bastión Asediado', 3,
                '⚓ Refuerzos entregados — [' . $coord . ']',
                $body,
                TIMESTAMP, null, 1, $user['universe'] ?? Universe::current()
            );
        } catch (Throwable $e) {
            PVEHelper::log('bastion', (int) $event['id'], 'msg_error', (int) $user['id'], 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }
}