<?php
/**
 * LotteryHelper.class.php
 * Sistema de Loteria - AstroIO v3.0 (DUAL RIEL)
 *
 * v3.0 (2026-10-30) - DUAL RIEL:
 *  - Detecta el riel del jugador (CUP / QVAPAY).
 *  - Si el jugador es QVAPAY:
 *      · Paga precio × 2 desde untx20 (el descuento VIP se aplica sobre base)
 *      · Recibe premios × 2 en untx20 (jackpot, 3 aciertos, 2 aciertos)
 *  - El pozo (jackpot_total, pozo_3, pozo_2) SIEMPRE se guarda en
 *    base NTX-20. Aporte del QVAPAY al pozo es precio_base (÷2).
 *  - Log NTX20LogHelper SOLO para CUP (no hay UNTXLogHelper).
 *  - hydrateDraw() añade jackpot_display y precio_display para UI.
 *  - getCurrentDraw/getDraws/getDrawById/getWidgetData aceptan $userId
 *    opcional para devolver los campos display ajustados al riel.
 *  - Resto intacto (config admin, tramos, createDraw, drawWinner, etc).
 *
 * ⚠️ INFLACIÓN: El pozo se guarda en base NTX-20. Si un QVAPAY gana,
 *    recibe (pozo × 2) UNTX-20. El "× 1 extra" se acuña. Asegurate de
 *    que el fondo admin + reserva UNTX cubra el acuñado potencial.
 */

if (!defined('MODE')) {
    exit;
}

class LotteryHelper
{
    // ═══════════════════════════════════════════════════════════
    // DUAL RIEL - Regla ×2 (único lugar)
    // ═══════════════════════════════════════════════════════════
    const UNTX_MULTIPLIER = 2;

    private static $methodCache = [];

    private static function prefix()
    {
        return 'uni1_';
    }

    private static function db()
    {
        return Database::get();
    }

    // ============================================================
    // DUAL RIEL — Métodos públicos
    // ============================================================

    public static function getPlayerMethod($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 'CUP';

        if (isset(self::$methodCache[$userId])) {
            return self::$methodCache[$userId];
        }

        $prefix = self::prefix();
        try {
            $row = self::db()->selectSingle(
                "SELECT metodo_retiro FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
                [':uid' => $userId]
            );
            $method = ($row && isset($row['metodo_retiro']) && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
        } catch (Exception $e) {
            $method = 'CUP';
        }

        self::$methodCache[$userId] = $method;
        return $method;
    }

    public static function isIntl($userId)
    {
        return self::getPlayerMethod($userId) === 'QVAPAY';
    }

    public static function getCurrencyLabel($userId)
    {
        return self::isIntl($userId) ? 'UNTX-20' : 'NTX-20';
    }

    public static function getPhysicalColumn($userId)
    {
        return self::isIntl($userId) ? 'untx20' : 'ntx20';
    }

    public static function getRielInfo($userId)
    {
        $userId     = (int)$userId;
        $isIntl     = self::isIntl($userId);
        $colBalance = $isIntl ? 'untx20' : 'ntx20';
        $moneda     = $isIntl ? 'UNTX-20' : 'NTX-20';
        $monedaFiat = $isIntl ? 'USD' : 'CUP';
        $saldo      = 0;

        $prefix = self::prefix();
        try {
            $row = self::db()->selectSingle(
                "SELECT `".$colBalance."` AS saldo FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
                [':uid' => $userId]
            );
            $saldo = $row ? (int)$row['saldo'] : 0;
        } catch (Exception $e) {
            $saldo = 0;
        }

        return [
            'isIntl'     => $isIntl,
            'colBalance' => $colBalance,
            'moneda'     => $moneda,
            'monedaFiat' => $monedaFiat,
            'saldo'      => $saldo,
            'multiplier' => $isIntl ? self::UNTX_MULTIPLIER : 1,
        ];
    }

    public static function getPrecioParaJugador($precioBase, $userId)
    {
        return self::isIntl($userId) ? ((int)$precioBase * self::UNTX_MULTIPLIER) : (int)$precioBase;
    }

    public static function getPremioParaJugador($cantidadBase, $userId)
    {
        return self::isIntl($userId) ? ((int)$cantidadBase * self::UNTX_MULTIPLIER) : (int)$cantidadBase;
    }

    public static function clearMethodCache()
    {
        self::$methodCache = [];
    }

    /**
     * Carga el helper de auditoría NTX-20 (si existe)
     */
    private static function loadNtxLogHelper()
    {
        if (class_exists('NTX20LogHelper')) return true;

        if (defined('ROOT_PATH')) {
            $file = ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php';
        } else {
            $file = dirname(__FILE__) . '/NTX20LogHelper.class.php';
        }

        if (file_exists($file)) {
            require_once $file;
        }
        return class_exists('NTX20LogHelper');
    }

    private static function logNtx20($userId, $amount, $type, $description = '', $refId = 0)
    {
        try {
            if (!self::loadNtxLogHelper()) return;
            NTX20LogHelper::log($userId, $amount, $type, $description, $refId);
        } catch (Exception $e) {
            // silencioso
        }
    }

    /* ============================================================
     *  CONFIGURACION
     * ============================================================ */

    public static function getConfig()
    {
        $db = self::db();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT * FROM `" . $prefix . "lottery_config` WHERE id = 1"
        );
        return $row ? $row : null;
    }

    public static function saveConfig($data, $adminId)
    {
        $db = self::db();
        $prefix = self::prefix();

        if ($data['precio_ticket'] < 1) return ['ok' => false, 'msg' => 'Precio minimo 1'];
        if ($data['rango_max'] < 10 || $data['rango_max'] > 100) return ['ok' => false, 'msg' => 'Rango entre 10 y 100'];
        if ($data['numeros_a_elegir'] < 2 || $data['numeros_a_elegir'] > 10) return ['ok' => false, 'msg' => 'Numeros a elegir entre 2 y 10'];
        if ($data['numeros_a_elegir'] > $data['rango_max']) return ['ok' => false, 'msg' => 'No podes elegir mas numeros que el rango'];
        if ($data['descuento_vip'] < 0 || $data['descuento_vip'] > 100) return ['ok' => false, 'msg' => 'Descuento VIP entre 0 y 100'];

        $duraciones = ['24h', '7d', '15d'];
        if (!in_array($data['duracion_sorteo'], $duraciones)) {
            $data['duracion_sorteo'] = '7d';
        }

        $db->update(
            "UPDATE `" . $prefix . "lottery_config` SET 
             moneda = :moneda,
             precio_ticket = :precio,
             descuento_vip = :descvip,
             duracion_sorteo = :duracion,
             rango_max = :rango,
             numeros_a_elegir = :numeros,
             fondo_admin = :fondo,
             jackpot_minimo = :jackpotmin,
             jackpot_acumula = :acumula,
             premio_3_aciertos = :p3,
             premio_2_aciertos = :p2,
             max_tickets_por_jugador = :maxtickets,
             max_tickets_totales = :maxtotal,
             activo = :activo,
             fecha_actualizacion = :fecha,
             actualizado_por = :admin
             WHERE id = 1",
            [
                ':moneda'     => 'ntx20',
                ':precio'     => (int)$data['precio_ticket'],
                ':descvip'    => (int)$data['descuento_vip'],
                ':duracion'   => $data['duracion_sorteo'],
                ':rango'      => (int)$data['rango_max'],
                ':numeros'    => (int)$data['numeros_a_elegir'],
                ':fondo'      => (int)$data['fondo_admin'],
                ':jackpotmin' => (int)$data['jackpot_minimo'],
                ':acumula'    => (int)$data['jackpot_acumula'],
                ':p3'         => (int)$data['premio_3_aciertos'],
                ':p2'         => (int)$data['premio_2_aciertos'],
                ':maxtickets' => (int)$data['max_tickets_por_jugador'],
                ':maxtotal'   => (int)$data['max_tickets_totales'],
                ':activo'     => (int)$data['activo'],
                ':fecha'      => time(),
                ':admin'      => (int)$adminId,
            ]
        );

        self::log(0, $adminId, 'config_actualizada', 'Precio: ' . $data['precio_ticket']);
        return ['ok' => true];
    }

    /* ============================================================
     *  PORCENTAJES ESCALONADOS (TRAMOS)
     * ============================================================ */

    public static function getPorcentajes($jackpotActual)
    {
        $db = self::db();
        $prefix = self::prefix();
        $jp = (int)$jackpotActual;

        $row = $db->selectSingle(
            "SELECT * FROM `" . $prefix . "lottery_percentages` 
             WHERE jackpot_desde <= :jp1
             AND (jackpot_hasta = 0 OR jackpot_hasta >= :jp2)
             ORDER BY orden ASC LIMIT 1",
            [':jp1' => $jp, ':jp2' => $jp]
        );

        if (!$row) {
            return ['jackpot' => 70, 'a3' => 20, 'a2' => 10];
        }

        return [
            'jackpot' => (int)$row['pct_jackpot'],
            'a3'      => (int)$row['pct_3_aciertos'],
            'a2'      => (int)$row['pct_2_aciertos'],
        ];
    }

    public static function getAllTramos()
    {
        $db = self::db();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT * FROM `" . $prefix . "lottery_percentages` 
             ORDER BY orden ASC, jackpot_desde ASC"
        );
        return is_array($rows) ? $rows : [];
    }

    public static function getTramoById($id)
    {
        $db = self::db();
        $prefix = self::prefix();
        return $db->selectSingle(
            "SELECT * FROM `" . $prefix . "lottery_percentages` WHERE id = :id",
            [':id' => (int)$id]
        );
    }

    public static function saveTramo($data, $adminId)
    {
        $db = self::db();
        $prefix = self::prefix();

        $desde  = max(0, (int)$data['jackpot_desde']);
        $hasta  = max(0, (int)$data['jackpot_hasta']);
        $pctJp  = (int)$data['pct_jackpot'];
        $pct3   = (int)$data['pct_3_aciertos'];
        $pct2   = (int)$data['pct_2_aciertos'];

        if ($pctJp < 0 || $pctJp > 100) return ['ok' => false, 'msg' => 'Porcentaje de jackpot invalido'];
        if ($pct3  < 0 || $pct3  > 100) return ['ok' => false, 'msg' => 'Porcentaje de 3 aciertos invalido'];
        if ($pct2  < 0 || $pct2  > 100) return ['ok' => false, 'msg' => 'Porcentaje de 2 aciertos invalido'];

        if (($pctJp + $pct3 + $pct2) !== 100) {
            return ['ok' => false, 'msg' => 'Los porcentajes deben sumar 100% (actual: ' . ($pctJp + $pct3 + $pct2) . '%)'];
        }

        if ($hasta > 0 && $hasta <= $desde) {
            return ['ok' => false, 'msg' => 'Jackpot hasta debe ser mayor que desde'];
        }

        $id = isset($data['id']) ? (int)$data['id'] : 0;

        if ($id > 0) {
            $db->update(
                "UPDATE `" . $prefix . "lottery_percentages` SET 
                 jackpot_desde = :desde,
                 jackpot_hasta = :hasta,
                 pct_jackpot = :pjp,
                 pct_3_aciertos = :p3,
                 pct_2_aciertos = :p2,
                 orden = :orden
                 WHERE id = :id",
                [
                    ':desde'  => $desde,
                    ':hasta'  => $hasta,
                    ':pjp'    => $pctJp,
                    ':p3'     => $pct3,
                    ':p2'     => $pct2,
                    ':orden'  => isset($data['orden']) ? (int)$data['orden'] : 0,
                    ':id'     => $id,
                ]
            );
            self::log(0, $adminId, 'tramo_editado', 'ID: ' . $id);
        } else {
            $db->insert(
                "INSERT INTO `" . $prefix . "lottery_percentages` 
                 (jackpot_desde, jackpot_hasta, pct_jackpot, pct_3_aciertos, pct_2_aciertos, orden) 
                 VALUES (:desde, :hasta, :pjp, :p3, :p2, :orden)",
                [
                    ':desde'  => $desde,
                    ':hasta'  => $hasta,
                    ':pjp'    => $pctJp,
                    ':p3'     => $pct3,
                    ':p2'     => $pct2,
                    ':orden'  => isset($data['orden']) ? (int)$data['orden'] : 0,
                ]
            );
            self::log(0, $adminId, 'tramo_creado', 'Desde: ' . $desde);
        }

        return ['ok' => true];
    }

    public static function deleteTramo($id, $adminId)
    {
        $db = self::db();
        $prefix = self::prefix();

        $id = (int)$id;
        if ($id <= 0) return ['ok' => false, 'msg' => 'ID invalido'];

        $total = $db->selectSingle(
            "SELECT COUNT(*) as t FROM `" . $prefix . "lottery_percentages`"
        );
        if (isset($total['t']) && (int)$total['t'] <= 1) {
            return ['ok' => false, 'msg' => 'Debe haber al menos 1 tramo'];
        }

        $db->delete(
            "DELETE FROM `" . $prefix . "lottery_percentages` WHERE id = :id",
            [':id' => $id]
        );

        self::log(0, $adminId, 'tramo_eliminado', 'ID: ' . $id);
        return ['ok' => true];
    }

    /* ============================================================
     *  SORTEOS (READ)
     * ============================================================ */

    /**
     * @param int|null $userId  Si se pasa, se añaden campos display (jackpot_display, precio_display)
     */
    public static function getCurrentDraw($userId = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT * FROM `" . $prefix . "lottery_draws` 
             WHERE estado = 'abierto' 
             ORDER BY id ASC LIMIT 1"
        );
        if (!$row) return null;
        return self::hydrateDraw($row, $userId);
    }

    public static function getDraws($limit = 20, $offset = 0, $userId = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $limit = (int)$limit;
        $offset = (int)$offset;

        $rows = $db->select(
            "SELECT * FROM `" . $prefix . "lottery_draws` 
             ORDER BY id DESC 
             LIMIT " . $offset . ", " . $limit
        );
        if (!is_array($rows)) return [];

        $result = [];
        foreach ($rows as $row) {
            $result[] = self::hydrateDraw($row, $userId);
        }
        return $result;
    }

    public static function getDrawById($id, $userId = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT * FROM `" . $prefix . "lottery_draws` WHERE id = :id",
            [':id' => (int)$id]
        );
        if (!$row) return null;
        return self::hydrateDraw($row, $userId);
    }

    private static function hydrateDraw($row, $userId = null)
    {
        $row['tiempo_restante'] = self::formatTiempo($row['fecha_sorteo'] - time());

        $row['numeros_sorteados_arr'] = [];
        if (!empty($row['numeros_sorteados'])) {
            $row['numeros_sorteados_arr'] = explode(',', $row['numeros_sorteados']);
        }

        // Base (compat)
        $row['jackpot_fmt'] = number_format($row['jackpot_total']);

        // 🆕 v3.0 — Display según riel
        $isIntl = ($userId !== null) ? self::isIntl($userId) : false;
        $mult   = $isIntl ? self::UNTX_MULTIPLIER : 1;

        $row['jackpot_display']     = (int)$row['jackpot_total'] * $mult;
        $row['jackpot_display_fmt'] = number_format($row['jackpot_display']);
        $row['pozo3_display']       = (int)$row['pozo_3_aciertos'] * $mult;
        $row['pozo2_display']       = (int)$row['pozo_2_aciertos'] * $mult;
        $row['precio_display']      = (int)$row['precio_ticket'] * $mult;
        $row['moneda_label']        = $isIntl ? 'UNTX-20' : 'NTX-20';

        return $row;
    }

    public static function formatTiempo($segundos)
    {
        if ($segundos <= 0) return 'SORTEANDO...';
        $d = floor($segundos / 86400);
        $h = floor(($segundos % 86400) / 3600);
        $m = floor(($segundos % 3600) / 60);
        $s = $segundos % 60;
        if ($d > 0) return $d . 'd ' . $h . 'h ' . $m . 'm';
        if ($h > 0) return $h . 'h ' . $m . 'm ' . $s . 's';
        if ($m > 0) return $m . 'm ' . $s . 's';
        return $s . 's';
    }

    public static function duracionASegundos($duracion)
    {
        switch ($duracion) {
            case '24h': return 24 * 3600;
            case '7d':  return 7 * 24 * 3600;
            case '15d': return 15 * 24 * 3600;
            default:    return 7 * 24 * 3600;
        }
    }

    private static function esVIP($userId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT COUNT(*) as t FROM `" . $prefix . "users_vip` 
             WHERE user_id = :uid AND vip_active = 1 AND vip_end > :ahora",
            [':uid' => (int)$userId, ':ahora' => time()]
        );
        return isset($row['t']) && (int)$row['t'] > 0;
    }

    /* ============================================================
     *  CREAR SORTEO
     * ============================================================ */

    public static function createDraw($adminId, $fondoAdmin = 0)
    {
        $db = self::db();
        $prefix = self::prefix();
        $config = self::getConfig();

        if (!$config) return ['ok' => false, 'msg' => 'Configuracion no encontrada'];

        $ultimo = $db->selectSingle(
            "SELECT jackpot_rollover, hubo_ganador_jackpot, rollover_3, rollover_2 
             FROM `" . $prefix . "lottery_draws` 
             WHERE estado = 'sorteado' 
             ORDER BY id DESC LIMIT 1"
        );

        $hayRollover = ($ultimo && !$ultimo['hubo_ganador_jackpot'] && $ultimo['jackpot_rollover'] > 0);
        $jackpotAnterior = $hayRollover ? (int)$ultimo['jackpot_rollover'] : 0;

        $rollover3Anterior = ($ultimo && isset($ultimo['rollover_3'])) ? (int)$ultimo['rollover_3'] : 0;
        $rollover2Anterior = ($ultimo && isset($ultimo['rollover_2'])) ? (int)$ultimo['rollover_2'] : 0;

        if (!$hayRollover && $fondoAdmin < 1) {
            return ['ok' => false, 'msg' => 'Debes poner un fondo inicial (no hay rollover)'];
        }

        $fondoAdmin = max(0, (int)$fondoAdmin);
        $jackpotTotal = $fondoAdmin + $jackpotAnterior;
        $pozo3Inicial = $rollover3Anterior;
        $pozo2Inicial = $rollover2Anterior;

        $last = $db->selectSingle(
            "SELECT MAX(numero_sorteo) as maxnum FROM `" . $prefix . "lottery_draws`"
        );
        $numeroSorteo = ($last && $last['maxnum'] ? (int)$last['maxnum'] : 0) + 1;

        $fechaInicio = time();
        $fechaSorteo = $fechaInicio + self::duracionASegundos($config['duracion_sorteo']);

        $pct = self::getPorcentajes($jackpotTotal);

        $db->insert(
            "INSERT INTO `" . $prefix . "lottery_draws` 
             (numero_sorteo, rango_max, numeros_a_elegir, precio_ticket,
              fondo_admin, jackpot_anterior, jackpot_total,
              pozo_jackpot, pozo_3_aciertos, pozo_2_aciertos,
              rollover_3, rollover_2,
              pct_jackpot_aplicado, pct_3_aplicado, pct_2_aplicado,
              estado, fecha_inicio, fecha_sorteo, creado_por)
             VALUES (:num, :rango, :numeros, :precio,
                     :fondo, :anterior, :total,
                     :pozo_jp, :pozo_3, :pozo_2,
                     :roll3, :roll2,
                     :pct_jp, :pct_3, :pct_2,
                     'abierto', :finicio, :fsorteo, :admin)",
            [
                ':num'      => $numeroSorteo,
                ':rango'    => (int)$config['rango_max'],
                ':numeros'  => (int)$config['numeros_a_elegir'],
                ':precio'   => (int)$config['precio_ticket'],
                ':fondo'    => $fondoAdmin,
                ':anterior' => $jackpotAnterior,
                ':total'    => $jackpotTotal,
                ':pozo_jp'  => 0,
                ':pozo_3'   => $pozo3Inicial,
                ':pozo_2'   => $pozo2Inicial,
                ':roll3'    => $rollover3Anterior,
                ':roll2'    => $rollover2Anterior,
                ':pct_jp'   => $pct['jackpot'],
                ':pct_3'    => $pct['a3'],
                ':pct_2'    => $pct['a2'],
                ':finicio'  => $fechaInicio,
                ':fsorteo'  => $fechaSorteo,
                ':admin'    => (int)$adminId,
            ]
        );

        $drawId = $db->lastInsertId();

        self::log($drawId, $adminId, 'sorteo_creado',
                  "Sorteo #$numeroSorteo - Jackpot: $jackpotTotal NTX-20 (Fondo: $fondoAdmin, Rollover: $jackpotAnterior, Roll3: $rollover3Anterior, Roll2: $rollover2Anterior)");

        return [
            'ok'      => true,
            'draw_id' => $drawId,
            'numero'  => $numeroSorteo,
            'jackpot' => $jackpotTotal,
        ];
    }

    /* ============================================================
     *  COMPRAR TICKET (DUAL RIEL)
     * ============================================================ */

    public static function buyTicket($drawId, $userId, $numeros, $ip = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $config = self::getConfig();

        if (!$config || !$config['activo']) return ['ok' => false, 'msg' => 'La loteria esta desactivada'];

        $numeros = array_map('intval', $numeros);
        $numeros = array_unique($numeros);
        sort($numeros);

        if (count($numeros) !== (int)$config['numeros_a_elegir']) {
            return ['ok' => false, 'msg' => 'Debes elegir ' . $config['numeros_a_elegir'] . ' numeros'];
        }

        foreach ($numeros as $n) {
            if ($n < 1 || $n > (int)$config['rango_max']) {
                return ['ok' => false, 'msg' => 'Numero fuera de rango: ' . $n];
            }
        }

        $numerosStr = implode(',', array_map(function ($n) {
            return str_pad($n, 2, '0', STR_PAD_LEFT);
        }, $numeros));

        // 🆕 v3.0 — Detectar riel
        $isIntl     = self::isIntl($userId);
        $colBalance = $isIntl ? 'untx20' : 'ntx20';
        $monedaLbl  = $isIntl ? 'UNTX-20' : 'NTX-20';

        $pdo = $db->getHandle();

        try {
            $pdo->beginTransaction();

            $draw = $db->selectSingle(
                "SELECT * FROM `" . $prefix . "lottery_draws` 
                 WHERE id = :id AND estado = 'abierto' FOR UPDATE",
                [':id' => (int)$drawId]
            );

            if (!$draw) throw new Exception('Sorteo no disponible');
            if ($draw['fecha_sorteo'] < time()) throw new Exception('El sorteo ya cerro');
            if ($draw['tickets_vendidos'] >= (int)$config['max_tickets_totales']) {
                throw new Exception('No quedan tickets disponibles');
            }

            $misTickets = $db->selectSingle(
                "SELECT COUNT(*) as t FROM `" . $prefix . "lottery_tickets` 
                 WHERE draw_id = :did AND user_id = :uid",
                [':did' => (int)$drawId, ':uid' => (int)$userId]
            );
            $cantidad = isset($misTickets['t']) ? (int)$misTickets['t'] : 0;

            if ($cantidad >= (int)$config['max_tickets_por_jugador']) {
                throw new Exception('Limite de tickets alcanzado (max: ' . $config['max_tickets_por_jugador'] . ')');
            }

            $ticketsPrevios = $db->select(
                "SELECT numeros FROM `" . $prefix . "lottery_tickets` 
                 WHERE draw_id = :did AND user_id = :uid",
                [':did' => (int)$drawId, ':uid' => (int)$userId]
            );

            if (is_array($ticketsPrevios)) {
                foreach ($ticketsPrevios as $tp) {
                    if ($tp['numeros'] === $numerosStr) {
                        throw new Exception('Ya tenes un ticket con esos numeros');
                    }
                }
            }

            // 🆕 v3.0 — Precio base (VIP aplicado sobre base)
            $precioBase = (int)$config['precio_ticket'];
            $esVip = self::esVIP($userId);
            if ($esVip && $config['descuento_vip'] > 0) {
                $precioBase = (int)round($precioBase * (1 - $config['descuento_vip'] / 100));
            }

            // 🆕 v3.0 — Precio real (×2 si QVAPAY)
            $precioReal = self::getPrecioParaJugador($precioBase, $userId);

            // Aporte al pozo (SIEMPRE BASE, no ×2)
            $pct = self::getPorcentajes((int)$draw['jackpot_total']);
            $aporteJackpot = (int)round($precioBase * $pct['jackpot'] / 100);
            $aporte3       = (int)round($precioBase * $pct['a3'] / 100);
            $aporte2       = $precioBase - $aporteJackpot - $aporte3;

            // Verificar saldo en la columna del riel
            $userRow = $db->selectSingle(
                "SELECT `".$colBalance."` AS saldo FROM `" . $prefix . "users` 
                 WHERE id = :uid FOR UPDATE",
                [':uid' => (int)$userId]
            );

            if (!$userRow || (int)$userRow['saldo'] < $precioReal) {
                throw new Exception($monedaLbl . ' insuficientes. Necesitas ' . $precioReal . ' y tienes ' . ((int)($userRow['saldo'] ?? 0)) . '.');
            }

            $nuevoSaldo = (int)$userRow['saldo'] - $precioReal;
            $db->update(
                "UPDATE `" . $prefix . "users` SET `".$colBalance."` = :saldo WHERE id = :uid",
                [':saldo' => $nuevoSaldo, ':uid' => (int)$userId]
            );

            if (isset($GLOBALS['USER']) && $GLOBALS['USER']['id'] == $userId) {
                $GLOBALS['USER'][$colBalance] = $nuevoSaldo;
            }

            // Log solo para CUP (no hay UNTXLogHelper)
            if (!$isIntl) {
                $descLog = 'Ticket de loteria #' . $draw['numero_sorteo'] . ' (numeros: ' . $numerosStr . ')';
                if ($esVip && $config['descuento_vip'] > 0) {
                    $descLog .= ' [VIP -' . (int)$config['descuento_vip'] . '%]';
                }
                self::logNtx20(
                    $userId,
                    -$precioReal,
                    'lottery_ticket',
                    $descLog,
                    (int)$drawId
                );
            }

            // Insertar ticket — guardar el precio REAL pagado (para auditoría)
            $db->insert(
                "INSERT INTO `" . $prefix . "lottery_tickets` 
                 (draw_id, user_id, numeros, precio_pagado, ip_compra, fecha_compra)
                 VALUES (:did, :uid, :num, :precio, :ip, :fecha)",
                [
                    ':did'    => (int)$drawId,
                    ':uid'    => (int)$userId,
                    ':num'    => $numerosStr,
                    ':precio' => $precioReal,
                    ':ip'     => $ip ? $ip : (isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null),
                    ':fecha'  => time(),
                ]
            );

            // Actualizar pozos con BASE (no ×2)
            $db->update(
                "UPDATE `" . $prefix . "lottery_draws` SET 
                 tickets_vendidos = tickets_vendidos + 1,
                 tickets_recaudado = tickets_recaudado + :precio,
                 jackpot_total = jackpot_total + :ap_jp,
                 pozo_jackpot = pozo_jackpot + :ap_jp2,
                 pozo_3_aciertos = pozo_3_aciertos + :ap_3,
                 pozo_2_aciertos = pozo_2_aciertos + :ap_2,
                 pct_jackpot_aplicado = :pct_jp,
                 pct_3_aplicado = :pct_3,
                 pct_2_aplicado = :pct_2
                 WHERE id = :did",
                [
                    ':precio' => $precioBase,   // ⚠️ BASE
                    ':ap_jp'  => $aporteJackpot,
                    ':ap_jp2' => $aporteJackpot,
                    ':ap_3'   => $aporte3,
                    ':ap_2'   => $aporte2,
                    ':pct_jp' => $pct['jackpot'],
                    ':pct_3'  => $pct['a3'],
                    ':pct_2'  => $pct['a2'],
                    ':did'    => (int)$drawId,
                ]
            );

            self::log($drawId, $userId, 'ticket_comprado',
                      "Numeros: $numerosStr - Pagado: $precioReal $monedaLbl (base: $precioBase) - JP: $aporteJackpot, 3A: $aporte3, 2A: $aporte2");

            $pdo->commit();

            return [
                'ok'      => true,
                'precio'  => $precioReal,
                'moneda'  => $monedaLbl,
                'numeros' => $numerosStr,
            ];

        } catch (Exception $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            return ['ok' => false, 'msg' => $e->getMessage()];
        }
    }

    /* ============================================================
     *  MIS TICKETS
     * ============================================================ */

    public static function getMyTickets($userId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT t.*, d.numero_sorteo, d.estado, d.fecha_sorteo, d.numeros_sorteados 
             FROM `" . $prefix . "lottery_tickets` t 
             LEFT JOIN `" . $prefix . "lottery_draws` d ON d.id = t.draw_id 
             WHERE t.user_id = :uid 
             ORDER BY t.fecha_compra DESC",
            [':uid' => (int)$userId]
        );
        return is_array($rows) ? $rows : [];
    }

    public static function getTicketsByDraw($drawId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT t.*, u.username 
             FROM `" . $prefix . "lottery_tickets` t 
             LEFT JOIN `" . $prefix . "users` u ON u.id = t.user_id 
             WHERE t.draw_id = :did 
             ORDER BY t.id ASC",
            [':did' => (int)$drawId]
        );
        return is_array($rows) ? $rows : [];
    }

    /* ============================================================
     *  SORTEO 100% ALEATORIO
     * ============================================================ */

    public static function drawWinner($drawId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $config = self::getConfig();

        $pdo = $db->getHandle();

        try {
            $pdo->beginTransaction();

            $draw = $db->selectSingle(
                "SELECT * FROM `" . $prefix . "lottery_draws` 
                 WHERE id = :id AND estado = 'abierto' FOR UPDATE",
                [':id' => (int)$drawId]
            );

            if (!$draw) throw new Exception('Sorteo no disponible');

            $semilla = random_int(1, 999999999);
            mt_srand($semilla);

            $rango = (int)$draw['rango_max'];
            $cantidad = (int)$draw['numeros_a_elegir'];

            $numeros = [];
            while (count($numeros) < $cantidad) {
                $n = mt_rand(1, $rango);
                if (!in_array($n, $numeros)) $numeros[] = $n;
            }
            sort($numeros);
            $numerosStr = implode(',', array_map(function ($n) {
                return str_pad($n, 2, '0', STR_PAD_LEFT);
            }, $numeros));

            $tickets = $db->select(
                "SELECT * FROM `" . $prefix . "lottery_tickets` 
                 WHERE draw_id = :did 
                 ORDER BY id ASC",
                [':did' => (int)$drawId]
            );

            if (!is_array($tickets)) $tickets = [];

            $jackpotTotal = (int)$draw['jackpot_total'];
            $pozo3Total   = (int)$draw['pozo_3_aciertos'];
            $pozo2Total   = (int)$draw['pozo_2_aciertos'];

            $ganadores4 = [];
            $ganadores3 = [];
            $ganadores2 = [];

            foreach ($tickets as $ticket) {
                $numerosTicket = array_map('intval', explode(',', $ticket['numeros']));
                $aciertos = count(array_intersect($numeros, $numerosTicket));

                if ($aciertos == $cantidad) {
                    $ganadores4[] = $ticket;
                } elseif ($aciertos == ($cantidad - 1)) {
                    $ganadores3[] = $ticket;
                } elseif ($aciertos == ($cantidad - 2)) {
                    $ganadores2[] = $ticket;
                }
            }

            $ganadorJackpot = null;
            if (count($ganadores4) > 0) {
                $ganadorJackpot = $ganadores4[0];
            }

            $premio_3 = (count($ganadores3) > 0) ? (int)floor($pozo3Total / count($ganadores3)) : 0;
            $premio_2 = (count($ganadores2) > 0) ? (int)floor($pozo2Total / count($ganadores2)) : 0;

            $rollover_3 = (count($ganadores3) > 0) ? ($pozo3Total - ($premio_3 * count($ganadores3))) : $pozo3Total;
            $rollover_2 = (count($ganadores2) > 0) ? ($pozo2Total - ($premio_2 * count($ganadores2))) : $pozo2Total;

            foreach ($tickets as $ticket) {
                $numerosTicket = array_map('intval', explode(',', $ticket['numeros']));
                $aciertos = count(array_intersect($numeros, $numerosTicket));

                $tipoPremio = 'ninguno';
                $premioGanado = 0;

                if ($aciertos == $cantidad) {
                    if ($ganadorJackpot && $ganadorJackpot['id'] == $ticket['id']) {
                        $tipoPremio = 'jackpot';
                        $premioGanado = $jackpotTotal;
                    }
                } elseif ($aciertos == ($cantidad - 1)) {
                    $tipoPremio = '3_aciertos';
                    $premioGanado = $premio_3;
                } elseif ($aciertos == ($cantidad - 2)) {
                    $tipoPremio = '2_aciertos';
                    $premioGanado = $premio_2;
                }

                $db->update(
                    "UPDATE `" . $prefix . "lottery_tickets` SET 
                     aciertos = :aciertos, 
                     tipo_premio = :tipo, 
                     premio_ganado = :premio,
                     fecha_entrega = :fentrega
                     WHERE id = :tid",
                    [
                        ':aciertos' => $aciertos,
                        ':tipo'     => $tipoPremio,
                        ':premio'   => $premioGanado,
                        ':fentrega' => $premioGanado > 0 ? time() : 0,
                        ':tid'      => (int)$ticket['id'],
                    ]
                );

                if ($premioGanado > 0) {
                    $ok = self::entregarPremio($ticket['user_id'], $premioGanado, $drawId, $tipoPremio);
                    if (!$ok) {
                        throw new Exception(
                            'Fallo al entregar premio de loteria a user_id ' . $ticket['user_id']
                        );
                    }
                }
            }

            $hash = hash('sha256', $drawId . '|' . $semilla . '|' . $numerosStr);

            $huboGanador = ($ganadorJackpot !== null) ? 1 : 0;
            $jackpotRollover = $huboGanador ? 0 : $jackpotTotal;
            $ganadorId = $ganadorJackpot ? (int)$ganadorJackpot['user_id'] : 0;

            $db->update(
                "UPDATE `" . $prefix . "lottery_draws` SET 
                 numeros_sorteados = :nums,
                 hubo_ganador_jackpot = :hubo,
                 jackpot_rollover = :rollover,
                 ganador_jackpot_id = :ganador,
                 rollover_3 = :roll3,
                 rollover_2 = :roll2,
                 estado = 'sorteado',
                 fecha_ejecutado = :fecha,
                 semilla = :semilla,
                 hash_verificacion = :hash
                 WHERE id = :did",
                [
                    ':nums'     => $numerosStr,
                    ':hubo'     => $huboGanador,
                    ':rollover' => $jackpotRollover,
                    ':ganador'  => $ganadorId,
                    ':roll3'    => $rollover_3,
                    ':roll2'    => $rollover_2,
                    ':fecha'    => time(),
                    ':semilla'  => $semilla,
                    ':hash'     => $hash,
                    ':did'      => (int)$drawId,
                ]
            );

            self::log($drawId, 0, 'sorteado',
                      "Numeros: $numerosStr - Jackpot: $jackpotTotal (base) - " .
                      "Ganadores JP: " . count($ganadores4) . " - " .
                      "Ganadores 3A: " . count($ganadores3) . " ($premio_3 c/u) - " .
                      "Ganadores 2A: " . count($ganadores2) . " ($premio_2 c/u) - " .
                      "Semilla: $semilla");

            $pdo->commit();

            // Notificar ganadores (fuera de transaccion)
            foreach ($tickets as $ticket) {
                $numerosTicket = array_map('intval', explode(',', $ticket['numeros']));
                $aciertosT = count(array_intersect($numeros, $numerosTicket));

                $ticketAux = [
                    'numeros'       => $ticket['numeros'],
                    'aciertos'      => $aciertosT,
                    'tipo_premio'   => 'ninguno',
                    'premio_ganado' => 0,
                ];

                if ($ganadorJackpot && $ganadorJackpot['id'] == $ticket['id']) {
                    $ticketAux['tipo_premio'] = 'jackpot';
                    $ticketAux['premio_ganado'] = $jackpotTotal;
                } elseif ($aciertosT == ($cantidad - 1) && $premio_3 > 0) {
                    $ticketAux['tipo_premio'] = '3_aciertos';
                    $ticketAux['premio_ganado'] = $premio_3;
                } elseif ($aciertosT == ($cantidad - 2) && $premio_2 > 0) {
                    $ticketAux['tipo_premio'] = '2_aciertos';
                    $ticketAux['premio_ganado'] = $premio_2;
                }

                if ($ticketAux['premio_ganado'] > 0) {
                    self::notificarGanador($ticket['user_id'], $draw, $ticketAux, $numerosStr);
                }
            }

            return [
                'ok'              => true,
                'numeros'         => $numeros,
                'ganador_jackpot' => $ganadorId,
            ];

        } catch (Exception $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            self::log($drawId, 0, 'error_sorteo', $e->getMessage());
            return ['ok' => false, 'msg' => $e->getMessage()];
        }
    }

    /* ============================================================
     *  ENTREGAR PREMIO (DUAL RIEL)
     * ============================================================ */

    /**
     * @param int    $userId        Jugador
     * @param int    $cantidadBase  Cantidad en BASE (NTX-20)
     * @param int    $drawId
     * @param string $tipoPremio    'jackpot' | '3_aciertos' | '2_aciertos'
     */
    public static function entregarPremio($userId, $cantidadBase, $drawId = 0, $tipoPremio = '')
    {
        $db = self::db();
        $prefix = self::prefix();

        $cantidadBase = (int)$cantidadBase;
        if ($cantidadBase <= 0) return false;

        $existe = $db->selectSingle(
            "SELECT id FROM `" . $prefix . "users` WHERE id = :uid",
            [':uid' => (int)$userId]
        );

        if (!$existe || !isset($existe['id'])) {
            return false;
        }

        // 🆕 v3.0 — Detectar riel
        $isIntl     = self::isIntl($userId);
        $colBalance = $isIntl ? 'untx20' : 'ntx20';
        $monedaLbl  = $isIntl ? 'UNTX-20' : 'NTX-20';

        // 🆕 v3.0 — Cantidad real (×2 si QVAPAY)
        $cantidadReal = self::getPremioParaJugador($cantidadBase, $userId);

        $db->update(
            "UPDATE `" . $prefix . "users` SET `".$colBalance."` = `".$colBalance."` + :cant 
             WHERE id = :uid",
            [':cant' => $cantidadReal, ':uid' => (int)$userId]
        );

        if (isset($GLOBALS['USER']) && (int)$GLOBALS['USER']['id'] === (int)$userId) {
            $GLOBALS['USER'][$colBalance] = (int)$GLOBALS['USER'][$colBalance] + $cantidadReal;
        }

        // Log solo para CUP
        if (!$isIntl) {
            $desc = 'Premio de loteria';
            if (!empty($tipoPremio)) {
                $tipos = [
                    'jackpot'    => 'JACKPOT',
                    '3_aciertos' => '3 aciertos',
                    '2_aciertos' => '2 aciertos',
                ];
                $desc .= ' (' . (isset($tipos[$tipoPremio]) ? $tipos[$tipoPremio] : $tipoPremio) . ')';
            }
            self::logNtx20(
                $userId,
                +$cantidadReal,
                'earn_lottery',
                $desc,
                (int)$drawId
            );
        }

        return true;
    }

    /* ============================================================
     *  NOTIFICAR GANADOR
     * ============================================================ */

    public static function notificarGanador($userId, $draw, $ticket, $numerosSorteados = '')
    {
        $db = self::db();
        $prefix = self::prefix();

        $tipoTexto = '';
        switch ($ticket['tipo_premio']) {
            case 'jackpot':    $tipoTexto = 'JACKPOT';    break;
            case '3_aciertos': $tipoTexto = '3 Aciertos'; break;
            case '2_aciertos': $tipoTexto = '2 Aciertos'; break;
            default: return false;
        }

        if (empty($numerosSorteados)) {
            $numerosSorteados = $draw['numeros_sorteados'];
        }

        // 🆕 v3.0 — Mostrar monto en la moneda del riel
        $cantidadBase = (int)$ticket['premio_ganado'];
        $cantidadReal = self::getPremioParaJugador($cantidadBase, $userId);
        $monedaLbl    = self::getCurrencyLabel($userId);

        $asunto = 'Ganaste en la Loteria #' . $draw['numero_sorteo'];
        $mensaje = "Felicitaciones!\n\n"
                 . "Sorteo: #" . $draw['numero_sorteo'] . "\n"
                 . "Tipo: " . $tipoTexto . "\n"
                 . "Numeros sorteados: " . $numerosSorteados . "\n"
                 . "Tus numeros: " . $ticket['numeros'] . "\n"
                 . "Aciertos: " . $ticket['aciertos'] . "\n"
                 . "Premio: " . number_format($cantidadReal) . " " . $monedaLbl . "\n\n"
                 . "El premio ya fue acreditado en tu cuenta.\n\n"
                 . "- El equipo de AstroIO";

        $db->insert(
            "INSERT INTO `" . $prefix . "messages` 
             (message_sender_id, message_owner_id, message_subject, 
              message_text, message_time, message_type, message_unread) 
             VALUES (0, :uid, :asunto, :texto, :fecha, 1, 1)",
            [
                ':uid'    => (int)$userId,
                ':asunto' => $asunto,
                ':texto'  => $mensaje,
                ':fecha'  => time(),
            ]
        );
        return true;
    }

    /* ============================================================
     *  CRON - PROCESAR SORTEOS VENCIDOS
     * ============================================================ */

    public static function processExpired()
    {
        $db = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT id FROM `" . $prefix . "lottery_draws` 
             WHERE estado = 'abierto' AND fecha_sorteo < :ahora 
             LIMIT 3",
            [':ahora' => time()]
        );

        if (!is_array($rows)) return 0;

        $count = 0;
        foreach ($rows as $r) {
            $result = self::drawWinner($r['id']);
            if ($result['ok']) $count++;
        }
        return $count;
    }

    /* ============================================================
     *  LOG
     * ============================================================ */

    public static function log($drawId, $userId, $accion, $detalle = '', $ip = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $ip = $ip ? $ip : (isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null);

        $db->insert(
            "INSERT INTO `" . $prefix . "lottery_log` 
             (draw_id, user_id, accion, detalle, ip, fecha) 
             VALUES (:did, :uid, :accion, :detalle, :ip, :fecha)",
            [
                ':did'     => (int)$drawId,
                ':uid'     => (int)$userId,
                ':accion'  => $accion,
                ':detalle' => $detalle,
                ':ip'      => $ip,
                ':fecha'   => time(),
            ]
        );
    }

    /* ============================================================
     *  WIDGET PARA OVERVIEW
     * ============================================================ */

    public static function getWidgetData($userId = null)
    {
        $draw = self::getCurrentDraw($userId);
        if (!$draw) return null;

        $config = self::getConfig();

        return [
            'id'               => $draw['id'],
            'numero_sorteo'    => $draw['numero_sorteo'],
            'jackpot'          => $draw['jackpot_display'],       // display (× mult)
            'jackpot_fmt'      => $draw['jackpot_display_fmt'],   // display (formateado)
            'tickets_vendidos' => $draw['tickets_vendidos'],
            'max_tickets'      => (int)$config['max_tickets_totales'],
            'precio_ticket'    => $draw['precio_display'],        // display (× mult)
            'fecha_sorteo'     => $draw['fecha_sorteo'],
            'tiempo_restante'  => $draw['tiempo_restante'],
            'numeros_a_elegir' => (int)$config['numeros_a_elegir'],
            'rango_max'        => (int)$config['rango_max'],
            'moneda_label'     => $draw['moneda_label'],
        ];
    }

    /* ============================================================
     *  HELPERS ADICIONALES
     * ============================================================ */

    public static function getSaldoJugador($userId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $col = self::getPhysicalColumn($userId);
        $row = $db->selectSingle(
            "SELECT `".$col."` AS saldo FROM `" . $prefix . "users` WHERE id = :uid",
            [':uid' => (int)$userId]
        );
        return ($row && isset($row['saldo'])) ? (int)$row['saldo'] : 0;
    }

    public static function getTicketsByUserAndDraw($userId, $drawId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT * FROM `" . $prefix . "lottery_tickets` 
             WHERE user_id = :uid AND draw_id = :did 
             ORDER BY id ASC",
            [':uid' => (int)$userId, ':did' => (int)$drawId]
        );
        return is_array($rows) ? $rows : [];
    }
}