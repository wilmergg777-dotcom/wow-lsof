<?php
/**
 * ReferralHelper — Lógica del sistema de referidos
 * AstroIO v5.0 (unificado, SOLO CÓDIGO, sin links)
 *
 * ✅ Sistema único: solo código de referido (8 hex)
 * ✅ Eliminado: getReferralLink(), getReferralLinkByCode()
 * ✅ Eliminado: dependencias de config nativa (ref_bonus, ref_active)
 * ✅ Nuevo: getUserIdByCode() optimizado + validateCode() + resolveReferrerId()
 *
 * v5.0 (2026-10-07):
 *  - Ya no se usan links de referido. Solo código.
 *  - El usuario ingresa el código en el formulario de registro.
 *  - Código inválido = bloquea registro. Código vacío = registra sin referidor.
 */

if (!defined('MODE')) die('Hacking attempt');

class ReferralHelper
{
    /* ============================================================
     * PREFIJO DE TABLAS
     * ============================================================ */
    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /* ============================================================
     * OBTENER DATOS DE REFERIDOS DEL USUARIO
     * ============================================================ */
    public static function getReferrals($userId)
    {
        $db = Database::get();
        $userId = (int)$userId;

        $sql = "SELECT u.id, u.username,
                       s.total_points, s.total_rank
                FROM ".self::prefix()."users u
                LEFT JOIN ".self::prefix()."statpoints s 
                    ON s.id_owner = u.id AND s.stat_type = 1
                WHERE u.ref_id = :uid
                ORDER BY u.id DESC";

        $rows = $db->select($sql, [':uid' => $userId]);
        return $rows ? $rows : [];
    }

    /* ============================================================
     * CONTAR REFERIDOS TOTALES
     * ============================================================ */
    public static function countReferrals($userId)
    {
        $db = Database::get();
        $userId = (int)$userId;

        $sql = "SELECT COUNT(*) as total 
                FROM ".self::prefix()."users 
                WHERE ref_id = :uid";

        $row = $db->selectSingle($sql, [':uid' => $userId]);
        return (int)($row['total'] ?? 0);
    }

    /* ============================================================
     * CONTAR REFERIDOS QUE YA PAGARON
     * ------------------------------------------------------------
     * v5.0: cuenta referidos que generaron al menos una comisión
     * en el sistema Wallet (wallet_referral_fund).
     * ============================================================ */
    public static function countPaidReferrals($userId)
    {
        $db = Database::get();
        $userId = (int)$userId;

        try {
            $sql = "SELECT COUNT(DISTINCT referred_id) as total
                    FROM ".self::prefix()."wallet_referral_fund
                    WHERE user_id = :uid AND amount > 0";

            $row = $db->selectSingle($sql, [':uid' => $userId]);
            return (int)($row['total'] ?? 0);
        } catch (Exception $e) {
            // Fallback: contar por ref_bonus (compatibilidad)
            try {
                $row = $db->selectSingle(
                    "SELECT COUNT(*) as total 
                     FROM ".self::prefix()."users 
                     WHERE ref_id = :uid AND ref_bonus = 0",
                    [':uid' => $userId]
                );
                return (int)($row['total'] ?? 0);
            } catch (Exception $e2) {
                return 0;
            }
        }
    }

    /* ============================================================
     * CALCULAR TOTAL GANADO (en NXT-20 / Kyber según sistema Wallet)
     * ------------------------------------------------------------
     * v5.0: suma las comisiones reales del nuevo sistema.
     * ============================================================ */
    public static function getTotalEarned($userId)
    {
        $db = Database::get();
        $userId = (int)$userId;

        try {
            $sql = "SELECT COALESCE(SUM(amount), 0) as total
                    FROM ".self::prefix()."wallet_referral_fund
                    WHERE user_id = :uid";

            $row = $db->selectSingle($sql, [':uid' => $userId]);
            return (float)($row['total'] ?? 0);
        } catch (Exception $e) {
            return 0;
        }
    }

    /* ============================================================
     * OBTENER EL REFERIDOR DE UN USUARIO
     * ============================================================ */
    public static function getMyReferrer($userId)
    {
        $db = Database::get();
        $userId = (int)$userId;

        $sql = "SELECT u.id, u.username 
                FROM ".self::prefix()."users u
                INNER JOIN ".self::prefix()."users me 
                    ON me.ref_id = u.id
                WHERE me.id = :uid
                LIMIT 1";

        $row = $db->selectSingle($sql, [':uid' => $userId]);
        return $row ? $row : null;
    }

    /* ============================================================
     * GENERAR CÓDIGO DE REFERIDO (a partir del user_id)
     * ------------------------------------------------------------
     * Fórmula: strtoupper(substr(md5('astroio_ref_' . userId), 0, 8))
     * Ej: user_id=2 → 4AF1013C
     * ============================================================ */
    public static function getReferralCode($userId)
    {
        $userId = (int)$userId;
        return strtoupper(substr(md5('astroio_ref_' . $userId), 0, 8));
    }

    /* ============================================================
     * CONVERTIR CÓDIGO DE REFERIDO A USER_ID
     * ------------------------------------------------------------
     * Estrategia optimizada:
     *   1) Si la tabla users tiene columna 'referral_code', la usamos
     *      (lookup directo, O(1)).
     *   2) Si no existe la columna, iteramos (fallback, O(n)).
     *   3) Cachea resultados en memoria para evitar repetir búsquedas.
     * ============================================================ */
    public static function getUserIdByCode($code)
    {
        static $cache = [];

        if (empty($code)) return 0;

        $code = strtoupper(trim($code));

        // Caché en memoria
        if (isset($cache[$code])) return $cache[$code];

        // Si es numérico, es un user_id directo (compatibilidad legacy)
        if (is_numeric($code)) {
            $uid = (int)$code;
            $db = Database::get();
            try {
                $row = $db->selectSingle(
                    "SELECT id FROM ".self::prefix()."users WHERE id = :id LIMIT 1",
                    [':id' => $uid]
                );
                if ($row && self::getReferralCode($uid) === $code) {
                    $cache[$code] = $uid;
                    return $uid;
                }
            } catch (Exception $e) {
                // sigue abajo
            }
        }

        $db = Database::get();

        // Intento 1: columna referral_code (si existe)
        try {
            $row = $db->selectSingle(
                "SELECT id FROM ".self::prefix()."users 
                 WHERE referral_code = :code LIMIT 1",
                [':code' => $code]
            );
            if ($row) {
                $uid = (int)$row['id'];
                $cache[$code] = $uid;
                return $uid;
            }
        } catch (Exception $e) {
            // La columna no existe → seguimos con fallback
        }

        // Intento 2: iterar (fallback)
        try {
            $rows = $db->select("SELECT id FROM ".self::prefix()."users");
            if (!$rows) {
                $cache[$code] = 0;
                return 0;
            }

            foreach ($rows as $row) {
                $uid = (int)$row['id'];
                if (self::getReferralCode($uid) === $code) {
                    $cache[$code] = $uid;
                    return $uid;
                }
            }
        } catch (Exception $e) {
            // nada
        }

        $cache[$code] = 0;
        return 0;
    }

    /* ============================================================
     * ALIAS LEGACY (por si algo llama codeToUserId)
     * ============================================================ */
    public static function codeToUserId($code)
    {
        return self::getUserIdByCode($code);
    }

    /* ============================================================
     * VALIDAR CÓDIGO DE REFERIDO
     * ------------------------------------------------------------
     * Devuelve true si el código existe en la BD.
     * Usado por ShowRegisterPage antes de permitir el registro.
     * ============================================================ */
    public static function validateCode($code)
    {
        if (empty($code)) return false;
        return self::getUserIdByCode($code) > 0;
    }

    /* ============================================================
     * RESOLVER REFERIDOR EN EL REGISTRO
     * ------------------------------------------------------------
     * Llamado por ShowRegisterPage cuando el nuevo usuario
     * ingresa un código VÁLIDO. Devuelve el user_id del referidor
     * o 0 si algo falla.
     *
     * v5.0: valida formato 8 hex + busca en BD.
     * ============================================================ */
    public static function resolveReferrerId($code)
    {
        if (empty($code)) return 0;

        $code = strtoupper(trim($code));

        // Validación de formato: 8 hex chars
        if (!preg_match('/^[A-F0-9]{8}$/', $code)) {
            return 0;
        }

        return self::getUserIdByCode($code);
    }

    /* ============================================================
     * OBTENER ESTADÍSTICAS DEL PROGRAMA
     * ------------------------------------------------------------
     * v5.0: solo estadísticas del nuevo sistema (sin config nativa).
     * Las ganancias reales vienen del sistema Wallet (3% NXT-20 + 3%).
     * ============================================================ */
    public static function getStats($userId)
    {
        $userId = (int)$userId;

        return [
            'total_referrals' => self::countReferrals($userId),
            'paid_referrals'  => self::countPaidReferrals($userId),
            'total_earned'    => self::getTotalEarned($userId),
            'referral_code'   => self::getReferralCode($userId),
        ];
    }
}