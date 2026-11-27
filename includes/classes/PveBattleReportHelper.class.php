<?php

/**
 * AstroIO — PveBattleReportHelper
 *
 * Genera el informe de batalla (uni1_raports / %%RW%%) para las misiones PvE
 * y devuelve el hash (reportID) para enlazarlo desde el mensaje del jugador.
 *
 * Se apoya en GenerateReport.php (el mismo que usa el PvP nativo).
 *
 * v1.1 — Documentada compatibilidad con Torneo del Devorador.
 *        No requiere cambios funcionales: acepta cualquier combinación
 *        de attackerIds/defenderIds, así que sirve para:
 *          - Empire:   attacker=[players], defender=[]
 *          - Crisis:   attacker=[players], defender=[]
 *          - Counter:  attacker=[],          defender=[player]
 *          - Boss:     attacker=[players],   defender=[]  (o [boss_ghost_uid])
 *        La firma pública de save() es estable desde v1.0.
 *
 * v1.2 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Este helper NO toca NTX-20 ni UNTX-20 en ningún punto.
 *   · Solo genera el informe de batalla visual (naves destruidas,
 *     recursos robados, escombros) y lo guarda en `uni1_raports` (%%RW%%).
 *   · Las recompensas NTX/UNTX NO se mencionan dentro del informe:
 *     se entregan por separado en `uni1_pve_rewards` (PVEHelper /
 *     PVECrisisHelper / PVEEmpireHelper) y se reclaman en el panel PvE.
 *   · El `stealResource` del array `$reportInfo` es SIEMPRE de recursos
 *     universales (metal/crystal/deuterium) → sin ×2.
 *   · No hay detección de riel, ni getPlayerMethod(), ni isIntl(),
 *     ni getPremioParaJugador(), ni WalletHelper, ni NTX20LogHelper.
 *   · Se añaden las constantes UNTX_MULTIPLIER y RIELS por coherencia
 *     con el resto de helpers PvE/PvP, aunque este archivo no las use
 *     funcionalmente.
 *   · Se documenta explícitamente en el header para evitar "arreglos"
 *     futuros innecesarios (mencionar moneda del otro riel dentro del
 *     informe sería una violación de la regla de oro).
 *
 * Ubicación: includes/classes/PveBattleReportHelper.class.php
 * @package AstroIO
 * @version 1.2
 */

if (!defined('ROOT_PATH')) {
    exit('Access denied');
}

class PveBattleReportHelper
{
    /* ============================================================
     *  CONSTANTES
     * ============================================================ */

    // Regla ×2 centralizada (por coherencia con el resto de helpers PvE/PvP)
    const UNTX_MULTIPLIER = 2;

    // Rieles válidos
    const RIELS = array('CUP', 'QVAPAY');


    /**
     * Genera el informe de batalla y lo guarda en %%RW%%.
     *
     * v1.2 — DOBLE RIEL: NO APLICA.
     *
     *   El informe de batalla muestra:
     *     - Naves y defensas destruidas (universales)
     *     - Recursos robados (metal/crystal/deuterium — universales)
     *     - Escombros generados (metal/crystal — universales)
     *     - Lunares y destrucciones (universal)
     *
     *   El informe NO muestra NTX-20 ni UNTX-20 porque:
     *     1. Las recompensas NTX/UNTX se entregan por separado en
     *        `uni1_pve_rewards` (NO en el informe de batalla).
     *     2. El botín del Imperio Caído desde v3.1 es solo recursos.
     *     3. La Crisis da recompensas configuradas (NTX o recursos)
     *        que se reclaman en el panel PvE, no en el informe.
     *     4. Los premios del Torneo/Bastión se entregan al final del
     *        evento, tampoco en el informe de batalla.
     *
     *   Regla de oro respetada: el informe NO menciona moneda alguna.
     *   Ni CUP ve "UNTX-20" ni QVAPAY ve "NTX-20" porque NINGUNA
     *   moneda aparece en el texto del informe.
     *
     * @param array $combatResult  Resultado de calculateAttack()
     * @param array $fleet         $this->_fleet de la misión
     * @param array $stealResource array(901=>,902=>,903=>) — recursos robados
     * @param array $attackerIds   IDs de usuarios atacantes
     * @param array $defenderIds   IDs de usuarios defensores
     *
     * @return string|null         El reportID (md5 de 32 chars) o null si falla
     */
    public static function save(array $combatResult, array $fleet, array $stealResource = array(), array $attackerIds = array(), array $defenderIds = array())
    {
        if (empty($combatResult) || empty($fleet)) {
            return null;
        }

        // ─── 1) Cargar GenerateReport.php ───
        $reportFile = ROOT_PATH . 'includes/classes/missions/functions/GenerateReport.php';

        if (!file_exists($reportFile)) {
            if (class_exists('PVEHelper')) {
                PVEHelper::log('system', 0, 'report_generate_missing', 0, 0, array(
                    'file' => $reportFile,
                ));
            }
            return null;
        }

        require_once $reportFile;

        if (!function_exists('GenerateReport')) {
            if (class_exists('PVEHelper')) {
                PVEHelper::log('system', 0, 'report_generate_not_callable', 0, 0, array());
            }
            return null;
        }

        // ─── 2) Normalizar stealResource ───
        // ⚠️ Estos son SIEMPRE recursos universales (metal/crystal/deuterium).
        //    No hay NTX-20 ni UNTX-20 aquí. Sin ×2, sin detección de riel.
        $steal = array(
            901 => isset($stealResource[901]) ? (int) $stealResource[901] : 0,
            902 => isset($stealResource[902]) ? (int) $stealResource[902] : 0,
            903 => isset($stealResource[903]) ? (int) $stealResource[903] : 0,
        );

        // ─── 3) Construir $reportInfo (estructura que espera GenerateReport) ───
        $reportInfo = array(
            'thisFleet'           => $fleet,
            'debris'              => array(901 => 0, 902 => 0),
            'stealResource'       => $steal,
            'moonChance'          => 0,
            'moonDestroy'         => false,
            'moonName'            => null,
            'moonDestroyChance'   => null,
            'moonDestroySuccess'  => null,
            'fleetDestroyChance'  => null,
            'fleetDestroySuccess' => null,
        );

        // ─── 4) Generar el reporte ───
        try {
            $reportData = GenerateReport($combatResult, $reportInfo);
        } catch (Throwable $e) {
            if (class_exists('PVEHelper')) {
                PVEHelper::log('system', 0, 'report_generate_failed', 0, 0, array(
                    'error' => $e->getMessage(),
                    'file'  => $e->getFile(),
                    'line'  => $e->getLine(),
                ));
            }
            return null;
        }

        if (empty($reportData) || !is_array($reportData)) {
            if (class_exists('PVEHelper')) {
                PVEHelper::log('system', 0, 'report_data_empty', 0, 0, array());
            }
            return null;
        }

        // ─── 5) Generar hash único (formato idéntico al PvP nativo) ───
        $reportID = md5(uniqid('', true) . TIMESTAMP);

        // ─── 6) Construir cadenas de attacker/defender ───
        // IMPORTANTE: nunca dejar vacío, si no, ShowRaportPage permite
        // a cualquier usuario con el hash ver el reporte.
        $attackerStr = self::buildIdsString($attackerIds);
        $defenderStr = self::buildIdsString($defenderIds);

        // ─── 7) INSERT en %%RW%% ───
        try {
            $db = Database::get();
            $db->insert(
                'INSERT INTO %%RW%% SET
                    rid      = :rid,
                    raport   = :raport,
                    time     = :time,
                    attacker = :attacker,
                    defender = :defender;',
                array(
                    ':rid'      => $reportID,
                    ':raport'   => serialize($reportData),
                    ':time'     => (int) ($fleet['fleet_start_time'] ?? TIMESTAMP),
                    ':attacker' => $attackerStr,
                    ':defender' => $defenderStr,
                )
            );
        } catch (Throwable $e) {
            if (class_exists('PVEHelper')) {
                PVEHelper::log('system', 0, 'report_insert_failed', 0, 0, array(
                    'error' => $e->getMessage(),
                    'file'  => $e->getFile(),
                    'line'  => $e->getLine(),
                ));
            }
            return null;
        }

        return $reportID;
    }


    /**
     * Convierte un array de IDs en un string "1,2,3".
     * Si está vacío o todos son 0/negativos, devuelve "-1"
     * (nunca string vacío — evita agujero de seguridad en ShowRaportPage).
     */
    private static function buildIdsString(array $ids)
    {
        if (empty($ids)) {
            return '-1';
        }

        $clean = array();
        foreach ($ids as $id) {
            $id = (int) $id;
            if ($id > 0) {
                $clean[] = $id;
            }
        }

        if (empty($clean)) {
            return '-1';
        }

        return implode(',', array_unique($clean));
    }
}