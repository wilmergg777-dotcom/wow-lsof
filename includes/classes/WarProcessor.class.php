<?php
/**
 * WarProcessor - Cron del sistema de Guerra WAR
 * AstroIO v1.0
 *
 * Procesa batallas terminadas y expiradas.
 * Llamado desde ShowOverviewPage cada 5 minutos.
 */

if (!defined('MODE')) { die('Hacking attempt'); }

require_once 'includes/classes/WarHelper.class.php';
require_once 'includes/classes/WarCombatHelper.class.php';
require_once 'includes/classes/WarClimatesHelper.class.php';

class WarProcessor
{
    private static function prefix() { return DB_PREFIX; }
    private static function db()     { return Database::get(); }

    /**
     * Punto de entrada — se llama desde ShowOverviewPage.
     */
    public static function process()
    {
        self::processFinished();
        self::processExpired();
    }

    // ============================================================
    // FINALIZAR BATALLAS QUE YA CUMPLIERON SU TIEMPO
    // ============================================================

    public static function processFinished()
    {
        $p   = self::prefix();
        $now = (int)TIMESTAMP;

        $rows = self::db()->select(
            "SELECT * FROM `{$p}war_battles`
             WHERE `estado` = 'en_curso' AND `fin` <= {$now}"
        );
        if (!$rows) return 0;

        $total = 0;
        foreach ($rows as $battle) {
            if (self::finalizeBattle($battle)) $total++;
        }
        return $total;
    }

    // ============================================================
    // FINALIZAR UNA BATALLA
    // ============================================================

    private static function finalizeBattle($battle)
    {
        $p      = self::prefix();
        $db     = self::db();
        $warId  = (int)$battle['id'];

        // 1) Cargar participantes
        $parts = $db->select(
            "SELECT * FROM `{$p}war_participants` WHERE `battle_id` = {$warId}"
        );
        if (!$parts) $parts = array();

        $atkId = (int)$battle['atacante_id'];
        $defId = (int)$battle['defensor_id'];

        $navesA = array(); $defA = array();
        $navesD = array(); $defD = array();

        $participantes = array();

        foreach ($parts as $p) {
            $uid      = (int)$p['user_id'];
            $pAlly    = (int)$p['alliance_id'];
            $naves    = json_decode($p['naves_json'],    true);
            $defs     = json_decode($p['defensas_json'], true);
            if (!is_array($naves)) $naves = array();
            if (!is_array($defs))  $defs  = array();

            $participantes[$uid] = array(
                'user_id'   => $uid,
                'alliance'  => $pAlly,
                'naves'     => $naves,
                'defensas'  => $defs,
            );

            if ($pAlly === $atkId) {
                foreach ($naves as $k => $c) $navesA[$k] = (isset($navesA[$k]) ? $navesA[$k] : 0) + (int)$c;
                foreach ($defs  as $k => $c) $defA[$k]   = (isset($defA[$k])   ? $defA[$k]   : 0) + (int)$c;
            } elseif ($pAlly === $defId) {
                foreach ($naves as $k => $c) $navesD[$k] = (isset($navesD[$k]) ? $navesD[$k] : 0) + (int)$c;
                foreach ($defs  as $k => $c) $defD[$k]   = (isset($defD[$k])   ? $defD[$k]   : 0) + (int)$c;
            }
        }

        // 2) Simular
        $result = WarCombatHelper::simulate(
            $navesA, $defA,
            $navesD, $defD,
            $battle['clima_key'],
            $atkId, $defId
        );

        // 3) Guardar resultado
        $rondasJson  = json_encode($result['rondas']);
        $bajasAJson  = json_encode($result['bajas_totales_atacante']);
        $bajasDJson  = json_encode($result['bajas_totales_defensor']);
        $resFinal    = $result['resultado'];

        $db->query(
            "UPDATE `{$p}war_battles`
             SET `estado` = 'finalizada',
                 `resultado_final` = '".addslashes($resFinal)."',
                 `rondas_json` = '".addslashes($rondasJson)."',
                 `bajas_atacante_json` = '".addslashes($bajasAJson)."',
                 `bajas_defensor_json` = '".addslashes($bajasDJson)."'
             WHERE `id` = {$warId}"
        );

        // 4) Repartir puntos a los participantes
        self::repartirPuntos($result, $participantes, $atkId, $defId, $warId);

        // 5) Devolver supervivientes a cada jugador
        self::devolverSupervivientes($result, $participantes, $atkId, $defId);

        // 6) Log
        WarHelper::log(0, 'battle_finished',
            "Batalla #{$warId} finalizada: {$resFinal}", $warId);

        return true;
    }

    // ============================================================
    // REPARTIR PUNTOS (max 20 por jugador, top 2 por bando)
    // ============================================================

    private static function repartirPuntos($result, $participantes, $atkId, $defId, $warId)
    {
        $res = $result['resultado'];

        // Calcular puntos por bajas infligidas al enemigo
        $bajasA = $result['bajas_totales_atacante']; // Bajas QUE SUFRIO el atacante
        $bajasD = $result['bajas_totales_defensor'];

        // Puntos del atacante = daño causado al defensor
        $ptsAtacante = self::calcularPuntosBajas($bajasD);
        $ptsDefensor = self::calcularPuntosBajas($bajasA);

        // Si victoria atacante, +5 al atacante
        if ($res === 'victoria_atacante') {
            $ptsAtacante += 5;
        } elseif ($res === 'victoria_defensor') {
            $ptsDefensor += 5;
        }

        // Cap a 20
        $ptsAtacante = min(20, $ptsAtacante);
        $ptsDefensor = min(20, $ptsDefensor);

        // Separar participantes por bando y ordenar por naves enviadas
        $bandA = array();
        $bandD = array();
        foreach ($participantes as $uid => $data) {
            $totalNaves = array_sum($data['naves']) + array_sum($data['defensas']);
            if ($data['alliance'] === $atkId) {
                $bandA[] = array('uid' => $uid, 'naves' => $totalNaves);
            } elseif ($data['alliance'] === $defId) {
                $bandD[] = array('uid' => $uid, 'naves' => $totalNaves);
            }
        }

        // Ordenar descendente por naves
        usort($bandA, function($a, $b) { return $b['naves'] - $a['naves']; });
        usort($bandD, function($a, $b) { return $b['naves'] - $a['naves']; });

        // Ganador: TODOS cobran
        // Perdedor: solo top 2 cobran
        // Empate: solo top 2 de cada bando

        if ($res === 'victoria_atacante') {
            // Atacante: todos
            self::asignarPuntosEquipo($bandA, $ptsAtacante, $warId, 999);
            // Defensor: top 2
            self::asignarPuntosEquipo($bandD, $ptsDefensor, $warId, 2);
        } elseif ($res === 'victoria_defensor') {
            self::asignarPuntosEquipo($bandD, $ptsDefensor, $warId, 999);
            self::asignarPuntosEquipo($bandA, $ptsAtacante, $warId, 2);
        } else {
            // Empate: top 2 de cada bando
            self::asignarPuntosEquipo($bandA, $ptsAtacante, $warId, 2);
            self::asignarPuntosEquipo($bandD, $ptsDefensor, $warId, 2);
        }
    }

    private static function asignarPuntosEquipo($band, $ptsTotal, $warId, $maxCobran)
    {
        if (empty($band) || $ptsTotal <= 0) return;

        $cantidad = min($maxCobran, count($band));
        if ($cantidad <= 0) return;

        $ptsCadaUno = (int)floor($ptsTotal / $cantidad);
        if ($ptsCadaUno <= 0) $ptsCadaUno = 1;

        for ($i = 0; $i < $cantidad; $i++) {
            $uid = (int)$band[$i]['uid'];
            WarHelper::addPoints($uid, $ptsCadaUno);
            WarHelper::log($uid, 'war_points_earned',
                "Gano {$ptsCadaUno} pts en batalla #{$warId}", $warId);
        }
    }

    private static function calcularPuntosBajas($bajas)
    {
        $pts = 0;
        if (!is_array($bajas)) return 0;
        foreach ($bajas as $unidad => $cantidad) {
            $cantidad = (int)$cantidad;
            if ($cantidad <= 0) continue;
            if (isset(WarHelper::$PESOS_NAVES[$unidad])) {
                $pts += WarHelper::$PESOS_NAVES[$unidad] * $cantidad;
            } elseif (isset(WarHelper::$PESOS_DEFENSAS[$unidad])) {
                $pts += WarHelper::$PESOS_DEFENSAS[$unidad] * $cantidad;
            }
        }
        // Reducir escala (1000 -> 1 punto)
        return (int)floor($pts / 1000);
    }

    // ============================================================
    // DEVOLVER SUPERVIVIENTES A LOS JUGADORES
    // ============================================================

    private static function devolverSupervivientes($result, $participantes, $atkId, $defId)
    {
        $p  = self::prefix();
        $db = self::db();

        $supA = $result['supervivientesA'];
        $supD = $result['supervivientesD'];

        foreach ($participantes as $uid => $data) {
            $uid   = (int)$uid;
            $pAlly = (int)$data['alliance'];

            $navesEnviadas    = $data['naves'];
            $defensasEnviadas = $data['defensas'];

            // Factor de supervivencia por bando
            $totalEnviado = array_sum($navesEnviadas) + array_sum($defensasEnviadas);
            if ($totalEnviado <= 0) continue;

            $sups = ($pAlly === $atkId) ? $supA : $supD;
            $totalSup = array_sum($sups);

            $factor = $totalSup > 0 ? ($totalSup / max(1, array_sum($supA) + array_sum($supD))) : 0;
            // Mejor: aplicar proporcion directa por unidades enviadas
            $factor = 1.0;
            if ($totalSup <= 0) $factor = 0;

            // Devolver proporcionalmente segun lo enviado
            $row = $db->selectSingle(
                "SELECT `id_planet` FROM `{$p}users` WHERE `id` = {$uid} LIMIT 1"
            );
            $planetId = !empty($row['id_planet']) ? (int)$row['id_planet'] : 0;
            if ($planetId <= 0) continue;

            $planet = $db->selectSingle(
                "SELECT * FROM `{$p}planets` WHERE `id` = {$planetId} LIMIT 1"
            );
            if (!$planet) continue;

            // Calcular devolucion proporcional: aplicamos el ratio de supervivencia global
            $ratio = $totalSup / max(1, array_sum($supA) + array_sum($supD));

            $updates = array();
            foreach ($navesEnviadas as $col => $cant) {
                $dev = (int)floor((int)$cant * $ratio);
                if ($dev > 0) {
                    $updates[] = "`{$col}` = `{$col}` + {$dev}";
                }
            }
            foreach ($defensasEnviadas as $col => $cant) {
                $dev = (int)floor((int)$cant * $ratio);
                if ($dev > 0) {
                    $updates[] = "`{$col}` = `{$col}` + {$dev}";
                }
            }

            if (!empty($updates)) {
                $sql = "UPDATE `{$p}planets` SET " . implode(', ', $updates) . " WHERE `id` = {$planetId}";
                $db->query($sql);
            }
        }
    }

    // ============================================================
    // EXPIRAR BATALLAS PENDIENTES (>48h sin empezar)
    // ============================================================

    public static function processExpired()
    {
        $p   = self::prefix();
        $now = (int)TIMESTAMP;

        // Batallas en_curso viejas sin participantes durante 48h -> cancelar
        $rows = self::db()->select(
            "SELECT * FROM `{$p}war_battles`
             WHERE `estado` = 'en_curso'
               AND `created_at` > 0
               AND `created_at` < " . ($now - 172800)
        );
        if (!$rows) return 0;

        $total = 0;
        foreach ($rows as $b) {
            $battleId = (int)$b['id'];
            // Si tiene participantes, ya no es "abandonada"
            $cnt = self::db()->selectSingle(
                "SELECT COUNT(*) AS c FROM `{$p}war_participants`
                 WHERE `battle_id` = {$battleId}"
            );
            if (!empty($cnt) && (int)$cnt['c'] > 0) continue;

            self::db()->query(
                "UPDATE `{$p}war_battles`
                 SET `estado` = 'cancelada',
                     `resultado_final` = 'cancelada'
                 WHERE `id` = {$battleId}"
            );
            WarHelper::log(0, 'battle_cancelled',
                "Batalla #{$battleId} cancelada por inactividad", $battleId);
            $total++;
        }
        return $total;
    }
}