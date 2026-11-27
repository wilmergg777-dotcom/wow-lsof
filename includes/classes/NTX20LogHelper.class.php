<?php

/**
 * NTX20LogHelper — Auditoria de movimientos NTX-20
 * AstroIO 2026
 *
 * v1.0 — Versión inicial (log, consultas, labels, iconos)
 * v1.1 — Agregados métodos de retención y mantenimiento:
 *          · getRetentionMonths()
 *          · setRetentionMonths()
 *          · cleanupOldLogs()
 *          · clearAllLogs()
 *          · getLogStats()
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

class NTX20LogHelper
{
    // ═══ TIPOS DE MOVIMIENTO — GASTOS ═══
    const T_VIP_PURCHASE      = 'vip_purchase';
    const T_SHOP_PURCHASE     = 'shop_purchase';
    const T_MARKET_BUY        = 'market_buy';
    const T_MARKET_FEE        = 'market_fee';
    const T_PVP_ARENA         = 'pvp_arena';
    const T_PVP_TOURNAMENT    = 'pvp_tournament';
    const T_PLANET_DROID      = 'planet_droid';
    const T_PLANET_MOON       = 'planet_moon';
    const T_PLANET_FIELDS     = 'planet_fields';
    const T_PLANET_DIAMETER   = 'planet_diameter';
    const T_PLANET_TELEPORT   = 'planet_teleport';
    const T_RAFFLE_TICKET     = 'raffle_ticket';
    const T_LOTTERY_TICKET    = 'lottery_ticket';
    const T_IMPROVEMENT_BUY   = 'improvement_buy';
    const T_WALLET_WITHDRAW   = 'wallet_withdraw';
    const T_BATTLEPASS_BUY    = 'battlepass_buy';
    const T_ADMIN_REMOVE      = 'admin_remove';

    // ═══ TIPOS DE MOVIMIENTO — INGRESOS ═══
    const T_EARN_EVENT        = 'earn_event';
    const T_EARN_TASK         = 'earn_task';
    const T_EARN_ACHIEVEMENT  = 'earn_achievement';
    const T_EARN_RAFFLE       = 'earn_raffle';
    const T_EARN_LOTTERY      = 'earn_lottery';
    const T_EARN_ADMIN        = 'earn_admin';
    const T_EARN_WALLET_INV   = 'earn_wallet_inv';
    const T_EARN_REFERRAL     = 'earn_referral';
    const T_EARN_OTHER        = 'earn_other';

    /**
     * Registra un movimiento NTX-20
     *
     * @param int    $userId      ID del jugador
     * @param int    $amount      Monto (+ gano / - gasto)
     * @param string $type        Categoria (una de las constantes T_*)
     * @param string $description Descripcion legible
     * @param int    $refId       ID del objeto relacionado (item, pack, evento)
     * @return bool
     */
    public static function log($userId, $amount, $type, $description = '', $refId = 0)
    {
        try {
            $userId = (int) $userId;
            $amount = (int) $amount;

            if ($userId <= 0 || $amount === 0) {
                return false;
            }

            $db     = Database::get();
            $prefix = DB_PREFIX;

            // Obtener username + saldo actual (post-movimiento)
            $userData = $db->selectSingle(
                "SELECT username, ntx20 FROM `" . $prefix . "users` WHERE id = :uid LIMIT 1",
                [':uid' => $userId]
            );

            if (!$userData) {
                return false;
            }

            $username     = (string) $userData['username'];
            $balanceAfter = (int) $userData['ntx20'];

            // IP binaria — formato: 0xHEX o NULL
            $ipSQL = 'NULL';
            if (!empty($_SERVER['REMOTE_ADDR'])) {
                $ipBin = @inet_pton($_SERVER['REMOTE_ADDR']);
                if ($ipBin !== false) {
                    $ipSQL = "0x" . bin2hex($ipBin);
                }
            }

            // SQL con inyeccion directa (el fork NO acepta :params en insert/query)
            $sql = "INSERT INTO `" . $prefix . "ntx20_log`
                        (user_id, username, amount, balance_after, type, description, reference_id, ip, timestamp)
                     VALUES
                        (" . $userId . ",
                         '" . addslashes($username) . "',
                         " . $amount . ",
                         " . $balanceAfter . ",
                         '" . addslashes((string) $type) . "',
                         '" . addslashes((string) $description) . "',
                         " . (int) $refId . ",
                         " . $ipSQL . ",
                         " . TIMESTAMP . ")";

            $db->query($sql);

            return true;
        } catch (Exception $e) {
            error_log('[NTX20Log] ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Lista completa de usuarios para el dropdown
     */
    public static function getUserList()
    {
        $db     = Database::get();
        $prefix = DB_PREFIX;

        return $db->select(
            "SELECT id, username FROM `" . $prefix . "users`
             ORDER BY username ASC"
        );
    }

    /**
     * Datos de un usuario (username + saldo actual)
     */
    public static function getUserData($userId)
    {
        $db     = Database::get();
        $prefix = DB_PREFIX;

        $userId = (int) $userId;

        return $db->selectSingle(
            "SELECT id, username, ntx20 FROM `" . $prefix . "users`
             WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );
    }

    /**
     * Estadisticas de un jugador (gastos + ingresos)
     */
    public static function getUserStats($userId, $fromTs = 0, $toTs = 0)
    {
        $db     = Database::get();
        $prefix = DB_PREFIX;

        $userId = (int) $userId;

        $where = "user_id = " . $userId;
        if ($fromTs > 0) $where .= " AND timestamp >= " . (int) $fromTs;
        if ($toTs   > 0) $where .= " AND timestamp <= " . (int) $toTs;

        $row = $db->selectSingle(
            "SELECT
                SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END) AS total_spent,
                SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS total_earned,
                COUNT(*) AS total_movements
             FROM `" . $prefix . "ntx20_log`
             WHERE " . $where
        );

        $spent  = abs((int) ($row['total_spent']  ?? 0));
        $earned = (int) ($row['total_earned'] ?? 0);

        return [
            'total_spent'     => $spent,
            'total_earned'    => $earned,
            'balance'         => $earned - $spent,
            'total_movements' => (int) ($row['total_movements'] ?? 0),
        ];
    }

    /**
     * Historial de un jugador con filtros + paginacion
     */
    public static function getUserHistory($userId, $filters = [], $limit = 50, $offset = 0)
    {
        $db     = Database::get();
        $prefix = DB_PREFIX;

        $userId = (int) $userId;
        $limit  = (int) $limit;
        $offset = (int) $offset;

        $where = ["user_id = " . $userId];

        if (!empty($filters['type'])) {
            $where[] = "type = '" . addslashes($filters['type']) . "'";
        }
        if (!empty($filters['direction'])) {
            if ($filters['direction'] === 'spend') $where[] = "amount < 0";
            if ($filters['direction'] === 'earn')  $where[] = "amount > 0";
        }
        if (!empty($filters['from_ts'])) {
            $where[] = "timestamp >= " . (int) $filters['from_ts'];
        }
        if (!empty($filters['to_ts'])) {
            $where[] = "timestamp <= " . (int) $filters['to_ts'];
        }

        $whereStr = implode(' AND ', $where);

        return $db->select(
            "SELECT * FROM `" . $prefix . "ntx20_log`
             WHERE " . $whereStr . "
             ORDER BY id DESC
             LIMIT " . $offset . ", " . $limit
        );
    }

    /**
     * Total de registros de un jugador (con filtros) para paginacion
     */
    public static function getUserHistoryCount($userId, $filters = [])
    {
        $db     = Database::get();
        $prefix = DB_PREFIX;

        $userId = (int) $userId;

        $where = ["user_id = " . $userId];

        if (!empty($filters['type'])) {
            $where[] = "type = '" . addslashes($filters['type']) . "'";
        }
        if (!empty($filters['direction'])) {
            if ($filters['direction'] === 'spend') $where[] = "amount < 0";
            if ($filters['direction'] === 'earn')  $where[] = "amount > 0";
        }
        if (!empty($filters['from_ts'])) {
            $where[] = "timestamp >= " . (int) $filters['from_ts'];
        }
        if (!empty($filters['to_ts'])) {
            $where[] = "timestamp <= " . (int) $filters['to_ts'];
        }

        $whereStr = implode(' AND ', $where);

        $row = $db->selectSingle(
            "SELECT COUNT(*) AS total FROM `" . $prefix . "ntx20_log` WHERE " . $whereStr
        );

        return (int) ($row['total'] ?? 0);
    }

    /**
     * Etiquetas legibles por tipo
     */
    public static function getTypeLabel($type)
    {
        $labels = [
            self::T_VIP_PURCHASE     => 'VIP',
            self::T_SHOP_PURCHASE    => 'Shop',
            self::T_MARKET_BUY       => 'Mercado (compra)',
            self::T_MARKET_FEE       => 'Mercado (comision)',
            self::T_PVP_ARENA        => 'Arena PvP',
            self::T_PVP_TOURNAMENT   => 'Torneo PvP',
            self::T_PLANET_DROID     => 'Planetario (Droide)',
            self::T_PLANET_MOON      => 'Planetario (Luna)',
            self::T_PLANET_FIELDS    => 'Planetario (Campos)',
            self::T_PLANET_DIAMETER  => 'Planetario (Diametro)',
            self::T_PLANET_TELEPORT  => 'Planetario (Teletransporte)',
            self::T_RAFFLE_TICKET    => 'Rifa (boleto)',
            self::T_LOTTERY_TICKET   => 'Loteria (ticket)',
            self::T_IMPROVEMENT_BUY  => 'Mejoras',
            self::T_WALLET_WITHDRAW  => 'Wallet (retiro)',
            self::T_BATTLEPASS_BUY   => 'Pase de Batalla',
            self::T_ADMIN_REMOVE     => 'Ajuste Admin (gasto)',

            self::T_EARN_EVENT       => 'Evento completado',
            self::T_EARN_TASK        => 'Tarea completada',
            self::T_EARN_ACHIEVEMENT => 'Logro reclamado',
            self::T_EARN_RAFFLE      => 'Rifa ganada',
            self::T_EARN_LOTTERY     => 'Loteria ganada',
            self::T_EARN_ADMIN       => 'Ajuste Admin (ingreso)',
            self::T_EARN_WALLET_INV  => 'Wallet (inversion)',
            self::T_EARN_REFERRAL    => 'Comision de referido',
            self::T_EARN_OTHER       => 'Otro ingreso',
        ];

        return $labels[$type] ?? $type;
    }

    /**
     * Iconos por tipo
     */
    public static function getTypeIcon($type)
    {
        $icons = [
            self::T_VIP_PURCHASE     => '💎',
            self::T_SHOP_PURCHASE    => '🛒',
            self::T_MARKET_BUY       => '🏛️',
            self::T_MARKET_FEE       => '📊',
            self::T_PVP_ARENA        => '⚔️',
            self::T_PVP_TOURNAMENT   => '🏆',
            self::T_PLANET_DROID     => '🤖',
            self::T_PLANET_MOON      => '🌕',
            self::T_PLANET_FIELDS    => '📐',
            self::T_PLANET_DIAMETER  => '📏',
            self::T_PLANET_TELEPORT  => '🚀',
            self::T_RAFFLE_TICKET    => '🎰',
            self::T_LOTTERY_TICKET   => '🎫',
            self::T_IMPROVEMENT_BUY  => '🔧',
            self::T_WALLET_WITHDRAW  => '🏦',
            self::T_BATTLEPASS_BUY   => '⚔️',
            self::T_ADMIN_REMOVE     => '👑',

            self::T_EARN_EVENT       => '🎉',
            self::T_EARN_TASK        => '🎯',
            self::T_EARN_ACHIEVEMENT => '🏅',
            self::T_EARN_RAFFLE      => '🎰',
            self::T_EARN_LOTTERY     => '🎫',
            self::T_EARN_ADMIN       => '👑',
            self::T_EARN_WALLET_INV  => '💵',
            self::T_EARN_REFERRAL    => '🔗',
            self::T_EARN_OTHER       => '💰',
        ];

        return $icons[$type] ?? '❓';
    }

    /**
     * Lista de tipos para el <select> de filtros
     */
    public static function getAllTypes()
    {
        return [
            // Gastos
            self::T_VIP_PURCHASE,
            self::T_SHOP_PURCHASE,
            self::T_MARKET_BUY,
            self::T_MARKET_FEE,
            self::T_PVP_ARENA,
            self::T_PVP_TOURNAMENT,
            self::T_PLANET_DROID,
            self::T_PLANET_MOON,
            self::T_PLANET_FIELDS,
            self::T_PLANET_DIAMETER,
            self::T_PLANET_TELEPORT,
            self::T_RAFFLE_TICKET,
            self::T_LOTTERY_TICKET,
            self::T_IMPROVEMENT_BUY,
            self::T_WALLET_WITHDRAW,
            self::T_BATTLEPASS_BUY,
            self::T_ADMIN_REMOVE,
            // Ingresos
            self::T_EARN_EVENT,
            self::T_EARN_TASK,
            self::T_EARN_ACHIEVEMENT,
            self::T_EARN_RAFFLE,
            self::T_EARN_LOTTERY,
            self::T_EARN_ADMIN,
            self::T_EARN_WALLET_INV,
            self::T_EARN_REFERRAL,
            self::T_EARN_OTHER,
        ];
    }

    // ============================================================
    // 🆕 v1.1 — CONFIGURACIÓN DE RETENCIÓN Y MANTENIMIENTO
    // ============================================================

    /**
     * Devuelve el número de meses de retención (0 = ilimitado)
     */
    public static function getRetentionMonths()
    {
        try {
            $db     = Database::get();
            $prefix = DB_PREFIX;

            $row = $db->selectSingle(
                "SELECT `ntx20_log_retention_months` AS `months`
                 FROM `" . $prefix . "config` LIMIT 1"
            );

            if (!$row || !isset($row['months'])) {
                return 3;
            }

            return max(0, (int) $row['months']);
        } catch (Exception $e) {
            return 3;
        }
    }

    /**
     * Guarda el número de meses de retención
     */
    public static function setRetentionMonths($months)
    {
        try {
            $db     = Database::get();
            $prefix = DB_PREFIX;

            $months = max(0, (int) $months);

            $db->update(
                "UPDATE `" . $prefix . "config`
                 SET `ntx20_log_retention_months` = :m
                 LIMIT 1",
                [':m' => $months]
            );

            return true;
        } catch (Exception $e) {
            return false;
        }
    }

    /**
     * Limpieza automática de logs viejos (se llama desde el cron)
     * Devuelve el número de filas borradas
     */
    public static function cleanupOldLogs()
    {
        try {
            $months = self::getRetentionMonths();

            // 0 = ilimitado → no borrar nada
            if ($months <= 0) {
                return 0;
            }

            $db     = Database::get();
            $prefix = DB_PREFIX;

            // Calcular timestamp límite (hace X meses)
            $limitTs = strtotime('-' . $months . ' months');

            // Contar antes de borrar
            $countRow = $db->selectSingle(
                "SELECT COUNT(*) AS total
                 FROM `" . $prefix . "ntx20_log`
                 WHERE `timestamp` < :limit",
                [':limit' => $limitTs]
            );

            $total = $countRow ? (int) $countRow['total'] : 0;

            if ($total > 0) {
                $db->query(
                    "DELETE FROM `" . $prefix . "ntx20_log`
                     WHERE `timestamp` < " . (int) $limitTs . ";"
                );
            }

            return $total;
        } catch (Exception $e) {
            error_log('[NTX20Log] cleanup error: ' . $e->getMessage());
            return 0;
        }
    }

    /**
     * Borrar TODOS los logs (botón del admin)
     * Devuelve el número de filas borradas
     */
    public static function clearAllLogs()
    {
        try {
            $db     = Database::get();
            $prefix = DB_PREFIX;

            // Contar antes de borrar
            $countRow = $db->selectSingle(
                "SELECT COUNT(*) AS total FROM `" . $prefix . "ntx20_log`"
            );

            $total = $countRow ? (int) $countRow['total'] : 0;

            if ($total > 0) {
                $db->query("TRUNCATE TABLE `" . $prefix . "ntx20_log`;");
            }

            return $total;
        } catch (Exception $e) {
            error_log('[NTX20Log] clearAll error: ' . $e->getMessage());
            return 0;
        }
    }

    /**
     * Estadísticas del log (para mostrar en admin)
     */
    public static function getLogStats()
    {
        try {
            $db     = Database::get();
            $prefix = DB_PREFIX;

            $row = $db->selectSingle(
                "SELECT
                    COUNT(*) AS total,
                    MIN(`timestamp`) AS oldest_ts,
                    MAX(`timestamp`) AS newest_ts
                 FROM `" . $prefix . "ntx20_log`"
            );

            if (!$row) {
                return [
                    'total'      => 0,
                    'oldest_ts'  => 0,
                    'newest_ts'  => 0,
                    'oldest_fmt' => '—',
                    'newest_fmt' => '—',
                    'size_mb'    => 0,
                ];
            }

            $total    = (int) ($row['total']     ?? 0);
            $oldestTs = (int) ($row['oldest_ts'] ?? 0);
            $newestTs = (int) ($row['newest_ts'] ?? 0);

            // Tamaño aproximado: ~200 bytes por fila
            $sizeMb = round(($total * 200) / (1024 * 1024), 2);

            return [
                'total'      => $total,
                'oldest_ts'  => $oldestTs,
                'newest_ts'  => $newestTs,
                'oldest_fmt' => $oldestTs > 0 ? date('d/m/Y H:i', $oldestTs) : '—',
                'newest_fmt' => $newestTs > 0 ? date('d/m/Y H:i', $newestTs) : '—',
                'size_mb'    => $sizeMb,
            ];
        } catch (Exception $e) {
            return [
                'total'      => 0,
                'oldest_ts'  => 0,
                'newest_ts'  => 0,
                'oldest_fmt' => '—',
                'newest_fmt' => '—',
                'size_mb'    => 0,
            ];
        }
    }
}