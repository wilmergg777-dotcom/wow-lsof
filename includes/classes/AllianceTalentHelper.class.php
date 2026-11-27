<?php
/**
 * AllianceTalentHelper - Arbol de Talentos de Alianza
 * AstroIO v2.0 (2026-10-30) - DUAL RIEL
 *
 * Sistema de 7 rangos x 3 opciones, elegidas por el lider.
 * Los rangos se desbloquean con puntos ganados por misiones.
 *
 * v2.0 — DUAL RIEL:
 *  - resetTalents() detecta el riel del jugador (CUP / QVAPAY).
 *  - Coste de reset: 100 NTX-20 (CUP) o 200 UNTX-20 (QVAPAY, ×2).
 *  - Se descuenta de la columna correcta (ntx20 / untx20).
 *  - Mensaje dinamico: "Se descontaron 200 UNTX-20" o "100 NTX-20".
 *  - Todo lo demas (puntos, rangos, bonus) NO toca moneda y queda igual.
 *
 * v2.1 (2026-11-27) — RESET REAL DESDE CERO:
 *  - resetTalents() tambien pone total_points = 0. Antes solo borraba los
 *    rangos y ponia spent_points a 0, asi que la alianza conservaba TODOS
 *    los puntos acumulados y podia re-comprar los 7 rangos al instante.
 *  - Tras un reset: total_points = 0, spent_points = 0, current_rank = 0.
 *    La alianza empieza de nuevo desde cero (v2.4.10).
 */

class AllianceTalentHelper
{
    // ============================================================
    // DUAL RIEL - Regla ×2 para QVAPAY (unico lugar)
    // ============================================================
    const UNTX_MULTIPLIER = 2;

    // ============================================================
    // COSTOS POR RANGO (Opcion A - para que R7 tarde 6-7 meses)
    // ============================================================
    const RANK_COSTS = array(
        1 => 1000,
        2 => 5000,
        3 => 15000,
        4 => 40000,
        5 => 90000,
        6 => 200000,
        7 => 450000,
    );

    // ============================================================
    // NIVEL MINIMO DEL BANCO para desbloquear cada rango
    // ============================================================
    const RANK_LEVELS = array(
        1 => 4,
        2 => 7,
        3 => 10,
        4 => 13,
        5 => 16,
        6 => 19,
        7 => 22,
    );

    // ============================================================
    // DEFINICION DE LOS 7 RANGOS x 3 OPCIONES
    // ============================================================
    const TALENTS = array(
        1 => array(
            'production_5' => array('name' => 'Produccion I',  'icon' => 'PROD1', 'type' => 'production', 'value' => 0.05),
            'attack_5'     => array('name' => 'Ataque I',      'icon' => 'ATK1',  'type' => 'attack',     'value' => 0.05),
            'defense_5'    => array('name' => 'Blindaje I',    'icon' => 'DEF1',  'type' => 'defense',    'value' => 0.05),
        ),
        2 => array(
            'speed_5'      => array('name' => 'Vuelo I',       'icon' => 'SPD1',  'type' => 'speed',      'value' => 0.05),
            'expedition_5' => array('name' => 'Expedicion I',  'icon' => 'EXP1',  'type' => 'expedition', 'value' => 0.05),
            'defense_8'    => array('name' => 'Blindaje II',   'icon' => 'DEF2',  'type' => 'defense',    'value' => 0.08),
        ),
        3 => array(
            'research_10'   => array('name' => 'Investigacion I', 'icon' => 'INV1',  'type' => 'research',   'value' => 0.10),
            'build_10'      => array('name' => 'Construccion I',  'icon' => 'CON1',  'type' => 'build',      'value' => 0.10),
            'production_10' => array('name' => 'Produccion II',   'icon' => 'PROD2', 'type' => 'production', 'value' => 0.10),
        ),
        4 => array(
            'attack_10'  => array('name' => 'Ataque II',   'icon' => 'ATK2', 'type' => 'attack',  'value' => 0.10),
            'defense_10' => array('name' => 'Defensa II',  'icon' => 'DEF3', 'type' => 'defense', 'value' => 0.10),
            'speed_10'   => array('name' => 'Vuelo II',    'icon' => 'SPD2', 'type' => 'speed',   'value' => 0.10),
        ),
        5 => array(
            'expedition_5b' => array('name' => 'Expedicion II',   'icon' => 'EXP2', 'type' => 'expedition', 'value' => 0.05),
            'research_15'   => array('name' => 'Investigacion II', 'icon' => 'INV2', 'type' => 'research',   'value' => 0.15),
            'build_15'      => array('name' => 'Construccion II',  'icon' => 'CON2', 'type' => 'build',      'value' => 0.15),
        ),
        6 => array(
            'production_15' => array('name' => 'Produccion III', 'icon' => 'PROD3', 'type' => 'production', 'value' => 0.15),
            'attack_15'     => array('name' => 'Ataque III',     'icon' => 'ATK3',  'type' => 'attack',     'value' => 0.15),
            'defense_15'    => array('name' => 'Blindaje III',   'icon' => 'DEF4',  'type' => 'defense',    'value' => 0.15),
        ),
        7 => array(
            'economy_total'     => array('name' => 'ECONOMIA TOTAL',    'icon' => 'ECO',  'type' => 'economy',     'value' => 0),
            'war_total'         => array('name' => 'GUERRA TOTAL',      'icon' => 'WAR',  'type' => 'war',         'value' => 0),
            'exploration_total' => array('name' => 'EXPLORACION TOTAL', 'icon' => 'EXPL', 'type' => 'exploration', 'value' => 0),
        ),
    );

    const RESET_COST       = 100; // NTX-20 base (×2 si QVAPAY)
    const MAX_DAILY_POINTS = 500; // Limite diario por miembro

    private static $cache = array();
    private static $methodCache = array();

    // ============================================================
    // HELPERS BASICOS
    // ============================================================

    private static function db()
    {
        return Database::get();
    }

    private static function prefix()
    {
        return DB_PREFIX;
    }

    // ============================================================
    // DUAL RIEL - Metodos publicos de deteccion
    // ============================================================

    /**
     * Devuelve 'QVAPAY' o 'CUP' segun el metodo_retiro del jugador.
     */
    public static function getPlayerMethod($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 'CUP';

        if (isset(self::$methodCache[$userId])) {
            return self::$methodCache[$userId];
        }

        $p = self::prefix();
        try {
            $row = self::db()->selectSingle(
                "SELECT `metodo_retiro` FROM `".$p."users` WHERE `id` = '".$userId."' LIMIT 1;"
            );
            $method = ($row && isset($row['metodo_retiro']) && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
        } catch (Exception $e) {
            $method = 'CUP';
        }

        self::$methodCache[$userId] = $method;
        return $method;
    }

    /**
     * ¿El jugador es internacional (paga con UNTX-20)?
     */
    public static function isIntl($userId)
    {
        return self::getPlayerMethod($userId) === 'QVAPAY';
    }

    /**
     * Etiqueta visible de la moneda: 'NTX-20' o 'UNTX-20'.
     */
    public static function getCurrencyLabel($userId)
    {
        return self::isIntl($userId) ? 'UNTX-20' : 'NTX-20';
    }

    /**
     * Columna FISICA del saldo segun el riel del jugador.
     */
    public static function getPhysicalColumn($userId)
    {
        return self::isIntl($userId) ? 'untx20' : 'ntx20';
    }

    // ============================================================
    // PUNTOS
    // ============================================================

    /**
     * Obtiene (o crea) la fila de puntos de la alianza.
     */
    public static function getPoints($allianceId)
    {
        $allianceId = (int)$allianceId;
        $p = self::prefix();

        $row = self::db()->selectSingle(
            "SELECT * FROM `".$p."alliance_talent_points` WHERE `alliance_id` = '".$allianceId."' LIMIT 1;"
        );

        if (empty($row)) {
            self::db()->query(
                "INSERT INTO `".$p."alliance_talent_points`
                 SET `alliance_id` = '".$allianceId."',
                     `total_points` = 0,
                     `spent_points` = 0,
                     `current_rank` = 0,
                     `updated_at` = '".TIMESTAMP."';"
            );
            $row = self::db()->selectSingle(
                "SELECT * FROM `".$p."alliance_talent_points` WHERE `alliance_id` = '".$allianceId."' LIMIT 1;"
            );
        }

        return $row;
    }

    /**
     * Suma puntos a la alianza (con limite diario por miembro).
     */
    public static function addPoints($allianceId, $userId, $points, $reason = '')
    {
        $points = (int)$points;
        if ($points <= 0) {
            return array('ok' => false, 'msg' => 'Puntos invalidos.');
        }

        $usedToday = self::getDailyUsed($userId);
        if ($usedToday + $points > self::MAX_DAILY_POINTS) {
            $left = max(0, self::MAX_DAILY_POINTS - $usedToday);
            return array('ok' => false, 'msg' => 'Limite diario alcanzado. Solo puedes sumar '.$left.' pts mas hoy.');
        }

        $allianceId = (int)$allianceId;
        $p = self::prefix();

        self::getPoints($allianceId);

        self::db()->query(
            "UPDATE `".$p."alliance_talent_points`
             SET `total_points` = `total_points` + ".$points.",
                 `updated_at` = '".TIMESTAMP."'
             WHERE `alliance_id` = '".$allianceId."';"
        );

        self::log($allianceId, $userId, 'points_added', $points, $reason);
        self::$cache = array();

        return array('ok' => true, 'msg' => 'Sumados '.$points.' puntos.');
    }

    /**
     * Cuantos puntos lleva un miembro hoy.
     */
    public static function getDailyUsed($userId)
    {
        $p = self::prefix();
        $startOfDay = strtotime('today 00:00:00');

        $row = self::db()->selectSingle(
            "SELECT COALESCE(SUM(`points`),0) AS total
             FROM `".$p."alliance_talent_log`
             WHERE `user_id` = '".(int)$userId."'
               AND `action` = 'points_added'
               AND `log_time` >= '".$startOfDay."';"
        );

        return (is_array($row) && isset($row['total'])) ? (int)$row['total'] : 0;
    }

    // ============================================================
    // RANGOS / TALENTOS
    // ============================================================

    /**
     * Devuelve los talentos ya elegidos, indexados por numero de rango.
     */
    public static function getRanks($allianceId)
    {
        $allianceId = (int)$allianceId;
        $p = self::prefix();

        $rows = self::db()->select(
            "SELECT `rank_num`, `talent_key`, `chosen_at`, `chosen_by`
             FROM `".$p."alliance_talent_ranks`
             WHERE `alliance_id` = '".$allianceId."'
             ORDER BY `rank_num` ASC;"
        );

        $out = array();
        foreach ($rows as $r) {
            $out[(int)$r['rank_num']] = $r;
        }
        return $out;
    }

    /**
     * Asigna un talento a un rango. Solo si hay puntos y se respeta el orden.
     */
    public static function setTalent($allianceId, $rankNum, $talentKey, $byUserId)
    {
        $rankNum    = (int)$rankNum;
        $allianceId = (int)$allianceId;

        if (!isset(self::TALENTS[$rankNum])) {
            return array('ok' => false, 'msg' => 'Rango invalido.');
        }
        if (!isset(self::TALENTS[$rankNum][$talentKey])) {
            return array('ok' => false, 'msg' => 'Talento invalido.');
        }

        $existing = self::getRanks($allianceId);
        if (isset($existing[$rankNum])) {
            return array('ok' => false, 'msg' => 'Este rango ya tiene un talento elegido.');
        }
        if ($rankNum > 1 && !isset($existing[$rankNum - 1])) {
            return array('ok' => false, 'msg' => 'Debes elegir el rango anterior primero.');
        }

        $cost = self::RANK_COSTS[$rankNum];
        $data = self::getPoints($allianceId);
        $available = (int)$data['total_points'] - (int)$data['spent_points'];

        if ($available < $cost) {
            return array('ok' => false, 'msg' => 'Faltan puntos. Tienes '.$available.', necesitas '.$cost.'.');
        }

        $p = self::prefix();

        self::db()->query(
            "INSERT INTO `".$p."alliance_talent_ranks`
             SET `alliance_id` = '".$allianceId."',
                 `rank_num` = '".$rankNum."',
                 `talent_key` = '".addslashes($talentKey)."',
                 `chosen_at` = '".TIMESTAMP."',
                 `chosen_by` = '".(int)$byUserId."';"
        );

        self::db()->query(
            "UPDATE `".$p."alliance_talent_points`
             SET `spent_points` = `spent_points` + ".$cost.",
                 `current_rank` = GREATEST(`current_rank`, ".$rankNum."),
                 `updated_at` = '".TIMESTAMP."'
             WHERE `alliance_id` = '".$allianceId."';"
        );

        self::log($allianceId, $byUserId, 'talent_set', $cost, "R".$rankNum.": ".$talentKey);
        self::$cache = array();

        return array('ok' => true, 'msg' => 'Talento del rango '.$rankNum.' asignado.');
    }

    /**
     * Resetea TODOS los talentos.
     *
     * Coste: RESET_COST NTX-20 base.
     *   - Si el jugador es CUP     -> 100 NTX-20
     *   - Si el jugador es QVAPAY  -> 200 UNTX-20 (×2)
     *
     * v2.1: el reset tambien pone total_points a 0 — los puntos ganados
     * NO se conservan; el arbol vuelve a empezar desde cero.
     *
     * @param int   $allianceId
     * @param int   $byUserId
     * @param array $user       Debe contener 'id' (y opcionalmente ntx20/untx20)
     */
    public static function resetTalents($allianceId, $byUserId, $user)
    {
        $byUserId   = (int)$byUserId;
        $allianceId = (int)$allianceId;

        // Detectar riel y calcular coste final
        $isIntl     = self::isIntl($byUserId);
        $colBalance = $isIntl ? 'untx20' : 'ntx20';
        $monedaLbl  = $isIntl ? 'UNTX-20' : 'NTX-20';
        $costFinal  = $isIntl ? (self::RESET_COST * self::UNTX_MULTIPLIER) : self::RESET_COST;

        // Leer saldo real desde BD (evita cache de sesion desactualizada)
        $p = self::prefix();
        $row = self::db()->selectSingle(
            "SELECT `".$colBalance."` AS `saldo` FROM `".$p."users` WHERE `id` = '".$byUserId."' LIMIT 1;"
        );
        $saldoActual = (empty($row) || !isset($row['saldo'])) ? 0 : (int)$row['saldo'];

        if ($saldoActual < $costFinal) {
            return array(
                'ok'  => false,
                'msg' => 'No tienes '.number_format($costFinal).' '.$monedaLbl.' para resetear.'
            );
        }

        // Descontar
        $nuevoSaldo = $saldoActual - $costFinal;
        self::db()->query(
            "UPDATE `".$p."users`
             SET `".$colBalance."` = '".$nuevoSaldo."'
             WHERE `id` = '".$byUserId."';"
        );

        // Sincronizar globals
        if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $byUserId) {
            $GLOBALS['USER'][$colBalance] = $nuevoSaldo;
        }
        if (is_array($user) && isset($user['id']) && (int)$user['id'] === $byUserId) {
            $user[$colBalance] = $nuevoSaldo;
        }

        // Borrar talentos y resetear puntos
        self::db()->query(
            "DELETE FROM `".$p."alliance_talent_ranks` WHERE `alliance_id` = '".$allianceId."';"
        );

        // v2.1 (v2.4.10): los puntos ACUMULADOS tambien vuelven a 0.
        // Antes solo se ponian a cero spent_points y current_rank, de modo
        // que la alianza conservaba todo lo ganado y podia re-comprar los
        // rangos de inmediato. Ahora el arbol empieza desde cero.
        self::db()->query(
            "UPDATE `".$p."alliance_talent_points`
             SET `total_points` = 0,
                 `spent_points` = 0,
                 `current_rank` = 0,
                 `updated_at` = '".TIMESTAMP."'
             WHERE `alliance_id` = '".$allianceId."';"
        );

        self::log($allianceId, $byUserId, 'talents_reset', $costFinal, 'Reset completo desde 0 ('.$monedaLbl.')');
        self::$cache = array();

        return array(
            'ok'  => true,
            'msg' => 'Talentos reseteados: los puntos vuelven a 0. Se descontaron '.number_format($costFinal).' '.$monedaLbl.'.'
        );
    }

    // ============================================================
    // BONUSES ACTIVOS (para aplicar al juego)
    // ============================================================

    /**
     * Suma todos los talentos elegidos y devuelve los % finales.
     */
    public static function getActiveBonuses($allianceId)
    {
        $allianceId = (int)$allianceId;
        $key = 'b_'.$allianceId;

        if (isset(self::$cache[$key])) {
            return self::$cache[$key];
        }

        $ranks = self::getRanks($allianceId);
        $totals = array(
            'production'         => 0,
            'attack'             => 0,
            'defense'            => 0,
            'speed'              => 0,
            'expedition'         => 0,
            'research'           => 0,
            'build'              => 0,
            'expedition_rewards' => 0,
        );

        foreach ($ranks as $rn => $row) {
            $tk = $row['talent_key'];
            if (!isset(self::TALENTS[$rn][$tk])) {
                continue;
            }
            $t = self::TALENTS[$rn][$tk];
            $type = $t['type'];
            $val  = $t['value'];

            if ($type === 'economy') {
                $totals['production'] += 0.25;
                $totals['research']   += 0.20;
                $totals['build']      += 0.20;
            } elseif ($type === 'war') {
                $totals['attack']  += 0.25;
                $totals['defense'] += 0.25;
            } elseif ($type === 'exploration') {
                $totals['expedition']         += 0.05;
                $totals['speed']              += 0.10;
                $totals['expedition_rewards'] += 0.10;
            } else {
                if (isset($totals[$type])) {
                    $totals[$type] += $val;
                }
            }
        }

        self::$cache[$key] = $totals;
        return $totals;
    }

    /**
     * Bonuses del usuario (segun su alianza).
     */
    public static function getBonusesForUser($userId)
    {
        $p = self::prefix();
        $row = self::db()->selectSingle(
            "SELECT `ally_id` FROM `".$p."users` WHERE `id` = '".(int)$userId."' LIMIT 1;"
        );

        $allianceId = (is_array($row) && isset($row['ally_id'])) ? (int)$row['ally_id'] : 0;

        if ($allianceId <= 0) {
            return array(
                'production' => 0, 'attack' => 0, 'defense' => 0, 'speed' => 0,
                'expedition' => 0, 'research' => 0, 'build' => 0, 'expedition_rewards' => 0,
            );
        }

        return self::getActiveBonuses($allianceId);
    }

    /**
     * Version cacheada (evita 2 queries por request).
     */
    public static function getBonusesForUserCached($userId)
    {
        return self::getBonusesForUser($userId);
    }

    // ============================================================
    // HELPERS DE LIDER / ALIANZA
    // ============================================================

    public static function isLeader($userId, $allianceId)
    {
        $p = self::prefix();
        $row = self::db()->selectSingle(
            "SELECT `ally_owner` FROM `".$p."alliance` WHERE `id` = '".(int)$allianceId."' LIMIT 1;"
        );
        return !empty($row) && (int)$row['ally_owner'] === (int)$userId;
    }

    public static function getAllianceInfo($allianceId)
    {
        $p = self::prefix();
        return self::db()->selectSingle(
            "SELECT `id`, `ally_name`, `ally_tag`, `ally_owner`, `ally_members`, `ally_max_members`
             FROM `".$p."alliance` WHERE `id` = '".(int)$allianceId."' LIMIT 1;"
        );
    }

    // ============================================================
    // LOG / HISTORIAL
    // ============================================================

    private static function log($allianceId, $userId, $action, $points, $detail)
    {
        $p = self::prefix();
        self::db()->query(
            "INSERT INTO `".$p."alliance_talent_log`
             SET `alliance_id` = '".(int)$allianceId."',
                 `user_id` = '".(int)$userId."',
                 `action` = '".addslashes($action)."',
                 `points` = '".(int)$points."',
                 `detail` = '".addslashes($detail)."',
                 `log_time` = '".TIMESTAMP."';"
        );
    }

    public static function getHistory($allianceId, $limit = 100)
    {
        $p = self::prefix();
        $limit = (int)$limit;

        return self::db()->select(
            "SELECT l.*, u.username
             FROM `".$p."alliance_talent_log` l
             LEFT JOIN `".$p."users` u ON u.id = l.user_id
             WHERE l.alliance_id = '".(int)$allianceId."'
             ORDER BY l.id DESC
             LIMIT ".$limit.";"
        );
    }
}