<?php

/**
 * AstroIO — MissionCasePirateAttack
 *
 * Procesa la LLEGADA de una oleada pirata al BASTIÓN ASEDIADO (misión 25).
 *
 * Flujo:
 *   1) PVEBastionWaveHelper::sendPirateFleet() inserta una flota pirata
 *      con fleet_mission=25, fleet_owner=0, fleet_target_obj=wave_id
 *   2) Al llegar → FlyingFleetHandler la enruta aquí
 *   3) Esta clase:
 *       - Carga la flota pirata (fleet_array)
 *       - Llama a PVEBastionWaveHelper::resolveWaveArrival($waveId, $pirataFleet)
 *       - El helper hace el combate, aplica daño al HP, atribuye kills
 *       - La flota pirata se ELIMINA (no vuelve — son desechables)
 *
 * NO envía mensaje al "jugador pirata" (es NPC).
 * El mensaje de resultado lo manda PVEBastionWaveHelper a la alianza.
 *
 * Reutiliza: PVEHelper, PVEBastionWaveHelper, PVEBastionHelper.
 *
 * Ubicación: includes/classes/missions/MissionCasePirateAttack.class.php
 * @package AstroIO
 * @subpackage PvE
 * @version 1.0
 */

if (!class_exists('PVEHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVEBastionHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEBastionHelper.class.php';
}
if (!class_exists('PVEBastionWaveHelper')) {
    require_once ROOT_PATH.'includes/classes/PVEBastionWaveHelper.class.php';
}

class MissionCasePirateAttack extends MissionFunctions implements Mission
{
    function __construct($Fleet)
    {
        $this->_fleet = $Fleet;
    }

    /* ============================================================
     *  LLEGADA DE LA OLEADA PIRATA AL BASTIÓN
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
            PVEHelper::log('bastion', 0, 'pirate_fleet_deleted_before_processing', 0, 0, array(
                'fleet_id' => $myFleetId,
            ));
            return;
        }

        if ((int) $rowCheck['fleet_mess'] !== 0) {
            PVEHelper::log('bastion', 0, 'pirate_fleet_already_processed', 0, 0, array(
                'fleet_id'   => $myFleetId,
                'fleet_mess' => (int) $rowCheck['fleet_mess'],
            ));
            return;
        }

        // Marcar como procesada inmediatamente (evita doble ejecución)
        $db->update(
            "UPDATE %%FLEETS%% SET fleet_mess = 1 WHERE fleet_id = :fid;",
            array(':fid' => $myFleetId)
        );

        // ═══════════════════════════════════════════════════════════
        // 1) Recuperar datos de la flota pirata
        // ═══════════════════════════════════════════════════════════
        $waveId = (int) $this->_fleet['fleet_target_obj'];
        $endId  = (int) $this->_fleet['fleet_end_id'];

        if ($waveId <= 0) {
            PVEHelper::log('bastion', 0, 'pirate_wave_id_missing', 0, 0, array(
                'fleet_id' => $myFleetId,
            ));
            $this->deletePirateFleet($myFleetId);
            return;
        }

        // Deserializar la flota pirata
        $pirateFleet = FleetFunctions::unserialize($this->_fleet['fleet_array']);

        if (empty($pirateFleet) || !is_array($pirateFleet)) {
            PVEHelper::log('bastion', 0, 'pirate_fleet_empty', 0, 0, array(
                'fleet_id' => $myFleetId,
                'wave_id'  => $waveId,
            ));
            // Marcar wave como cancelada
            $this->markWaveAsCancelled($waveId);
            $this->deletePirateFleet($myFleetId);
            return;
        }

        // ═══════════════════════════════════════════════════════════
        // 2) Delegar la resolución al WaveHelper
        // ═══════════════════════════════════════════════════════════
        try {
            $result = PVEBastionWaveHelper::resolveWaveArrival($waveId, $pirateFleet);

            PVEHelper::log('bastion', 0, 'pirate_attack_resolved', 0, 0, array(
                'fleet_id'          => $myFleetId,
                'wave_id'           => $waveId,
                'end_id'            => $endId,
                'pirates_total'     => array_sum($pirateFleet),
                'pirates_killed'    => $result['pirates_killed']    ?? 0,
                'pirates_survived'  => $result['pirates_survived']  ?? 0,
                'damage_to_bastion' => $result['damage_to_bastion'] ?? 0,
                'result'            => $result['result']            ?? 'unknown',
                'breached'          => !empty($result['breached']) ? 1 : 0,
            ));

        } catch (Throwable $e) {
            PVEHelper::log('bastion', 0, 'pirate_resolve_exception', 0, 0, array(
                'fleet_id' => $myFleetId,
                'wave_id'  => $waveId,
                'error'    => $e->getMessage(),
                'file'     => $e->getFile(),
                'line'     => $e->getLine(),
            ));
        }

        // ═══════════════════════════════════════════════════════════
        // 3) Eliminar la flota pirata (es desechable)
        // ═══════════════════════════════════════════════════════════
        $this->deletePirateFleet($myFleetId);
    }


    /* ============================================================
     *  END STAY (no aplica)
     * ============================================================ */

    function EndStayEvent()
    {
        return;
    }


    /* ============================================================
     *  RETORNO (no debería llegar — la flota pirata se elimina)
     * ============================================================ */

    function ReturnEvent()
    {
        // Los piratas no vuelven a casa. Si por algún motivo llega aquí,
        // eliminar la flota directamente.
        $fleetId = (int) $this->_fleet['fleet_id'];
        if ($fleetId > 0) {
            $this->deletePirateFleet($fleetId);
        }
    }


    /* ============================================================
     *  HELPERS INTERNOS
     * ============================================================ */

    /**
     * Elimina la flota pirata (FLEETS + FLEETS_EVENT + LOG_FLEETS).
     * No devuelve nada al "jugador pirata" (es NPC sin recursos).
     */
    private function deletePirateFleet(int $fleetId): void
    {
        if ($fleetId <= 0) return;

        $db = Database::get();

        try {
            // Eliminar FLEETS + FLEETS_EVENT
            $db->delete(
                "DELETE %%FLEETS%%, %%FLEETS_EVENT%%
                 FROM %%FLEETS%%
                 INNER JOIN %%FLEETS_EVENT%% ON fleetID = fleet_id
                 WHERE fleet_id = :fid;",
                array(':fid' => $fleetId)
            );
        } catch (Throwable $e) {
            // Fallback: intentar eliminar solo FLEETS si el JOIN falla
            try {
                $db->delete(
                    "DELETE FROM %%FLEETS%% WHERE fleet_id = :fid;",
                    array(':fid' => $fleetId)
                );
                $db->delete(
                    "DELETE FROM %%FLEETS_EVENT%% WHERE fleetID = :fid;",
                    array(':fid' => $fleetId)
                );
            } catch (Throwable $e2) {}
        }
    }

    /**
     * Marca la wave como cancelada (fleet_array vacío, coords inválidas, etc.).
     */
    private function markWaveAsCancelled(int $waveId): void
    {
        if ($waveId <= 0) return;

        $db = Database::get();

        try {
            $db->update(
                "UPDATE %%PVE_BASTION_WAVES%% SET
                    resolved    = 1,
                    result      = 'partial',
                    resolved_at = :now
                 WHERE id = :id AND resolved = 0;",
                array(':now' => TIMESTAMP, ':id' => $waveId)
            );
        } catch (Throwable $e) {}
    }
}