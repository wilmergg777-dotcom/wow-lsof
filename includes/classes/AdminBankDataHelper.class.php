<?php
/**
 * AdminBankDataHelper — Datos bancarios de los administradores
 * AstroIO v6.0 — Sistema 1:1 SIN AMM
 *
 * Cada admin debe registrar su tarjeta magnética y teléfono.
 * Sin estos datos, no puede operar el banco.
 *
 * Esta clase SOLO gestiona tarjeta + teléfono + titular + banco.
 * NO toca:
 *   - Cuenta CUP (eso lo hace AdminBankHelper)
 *   - Banco / pool / fondo proyecto (eso lo hace WalletFundHelper)
 *   - NXT-20 / Kyber (eso lo hace WalletHelper)
 *
 * VALIDACIONES DEL ADMIN (distintas a las del USER):
 *   - Tarjeta: min 10 caracteres (el user pide min 16)
 *   - Teléfono: min 6 caracteres (el user pide min 8)
 *   - Titular / banco: opcionales
 *
 * NOTA v6.0:
 *   El user tendrá su propio helper (UserBankDataHelper) con la MISMA
 *   estructura pero validaciones más estrictas. Este archivo queda
 *   exclusivamente para admins.
 *
 * Métodos:
 *   hasBankData()           — ¿tiene tarjeta + teléfono?
 *   getBankData()           — devuelve todos los datos
 *   saveBankData()          — crea o actualiza con validación
 *   getAllAdminsWithData()  — lista todos (superadmin)
 *   getAdminsSinDatos()     — alerta de admins sin datos
 *   deleteBankData()        — solo superadmin
 */

if (!defined('MODE')) die('Hacking attempt');

class AdminBankDataHelper
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
     * INSTANCIA DE LA BD
     * ============================================================ */
    private static function db()
    {
        return Database::get();
    }

    /* ============================================================
     * ¿TIENE DATOS BANCARIOS CARGADOS?
     * Devuelve true si tiene tarjeta Y teléfono
     * ============================================================ */
    public static function hasBankData($adminId)
    {
        $adminId = (int)$adminId;
        if ($adminId <= 0) return false;

        $db = self::db();

        try {
            $row = $db->selectSingle(
                "SELECT tarjeta_magnetica, telefono 
                 FROM ".self::prefix()."admin_bank_data 
                 WHERE admin_id = :aid 
                 LIMIT 1",
                [':aid' => $adminId]
            );
        } catch (Exception $e) {
            return false;
        }

        if (!$row) return false;
        if (empty($row['tarjeta_magnetica'])) return false;
        if (empty($row['telefono']))          return false;

        return true;
    }

    /* ============================================================
     * OBTENER DATOS BANCARIOS COMPLETOS
     * Devuelve array con todos los campos, o null si no tiene
     * ============================================================ */
    public static function getBankData($adminId)
    {
        $adminId = (int)$adminId;
        if ($adminId <= 0) return null;

        $db = self::db();

        try {
            $row = $db->selectSingle(
                "SELECT * FROM ".self::prefix()."admin_bank_data 
                 WHERE admin_id = :aid 
                 LIMIT 1",
                [':aid' => $adminId]
            );
        } catch (Exception $e) {
            return null;
        }

        return $row ? $row : null;
    }

    /* ============================================================
     * GUARDAR / ACTUALIZAR DATOS BANCARIOS
     * Devuelve true si se guardó, o array con 'error'
     * ============================================================ */
    public static function saveBankData($adminId, $tarjeta, $telefono, $titular = '', $banco = '')
    {
        $adminId  = (int)$adminId;
        $tarjeta  = trim((string)$tarjeta);
        $telefono = trim((string)$telefono);
        $titular  = trim((string)$titular);
        $banco    = trim((string)$banco);

        // ─── Validaciones ─────────────────────────────────
        if ($adminId <= 0) {
            return ['error' => 'ID de admin inválido.'];
        }

        if (strlen($tarjeta) < 10) {
            return ['error' => 'La tarjeta magnética debe tener al menos 10 caracteres.'];
        }

        if (strlen($tarjeta) > 50) {
            return ['error' => 'La tarjeta magnética es demasiado larga (máx 50).'];
        }

        if (strlen($telefono) < 6) {
            return ['error' => 'El teléfono debe tener al menos 6 caracteres.'];
        }

        if (strlen($telefono) > 30) {
            return ['error' => 'El teléfono es demasiado largo (máx 30).'];
        }

        if (strlen($titular) > 100) {
            return ['error' => 'El titular es demasiado largo (máx 100).'];
        }

        if (strlen($banco) > 100) {
            return ['error' => 'El banco es demasiado largo (máx 100).'];
        }

        $db = self::db();
        $now = defined('TIMESTAMP') ? TIMESTAMP : time();

        try {
            $existe = $db->selectSingle(
                "SELECT id FROM ".self::prefix()."admin_bank_data 
                 WHERE admin_id = :aid 
                 LIMIT 1",
                [':aid' => $adminId]
            );

            if ($existe) {
                // ─── Actualizar ────────────────────────────
                $db->update(
                    "UPDATE ".self::prefix()."admin_bank_data 
                     SET tarjeta_magnetica   = :tarjeta,
                         telefono            = :tel,
                         titular             = :titular,
                         banco               = :banco,
                         fecha_actualizacion = :now
                     WHERE admin_id = :aid",
                    [
                        ':tarjeta' => $tarjeta,
                        ':tel'     => $telefono,
                        ':titular' => $titular !== '' ? $titular : null,
                        ':banco'   => $banco   !== '' ? $banco   : null,
                        ':now'     => $now,
                        ':aid'     => $adminId
                    ]
                );
            } else {
                // ─── Insertar ──────────────────────────────
                $db->insert(
                    "INSERT INTO ".self::prefix()."admin_bank_data 
                     (admin_id, tarjeta_magnetica, telefono, titular, banco, 
                      fecha_registro, fecha_actualizacion)
                     VALUES (:aid, :tarjeta, :tel, :titular, :banco, :now, :now)",
                    [
                        ':aid'     => $adminId,
                        ':tarjeta' => $tarjeta,
                        ':tel'     => $telefono,
                        ':titular' => $titular !== '' ? $titular : null,
                        ':banco'   => $banco   !== '' ? $banco   : null,
                        ':now'     => $now
                    ]
                );
            }
        } catch (Exception $e) {
            return ['error' => 'Error al guardar: ' . $e->getMessage()];
        }

        return ['success' => true];
    }

    /* ============================================================
     * LISTAR TODOS LOS ADMINS CON DATOS BANCARIOS
     * Para panel superadmin
     * ============================================================ */
    public static function getAllAdminsWithData()
    {
        $db = self::db();

        try {
            $rows = $db->select(
                "SELECT b.*, u.username, u.authlevel 
                 FROM ".self::prefix()."admin_bank_data b
                 LEFT JOIN ".self::prefix()."users u ON u.id = b.admin_id
                 ORDER BY b.fecha_actualizacion DESC, b.fecha_registro DESC"
            );
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /* ============================================================
     * LISTAR ADMINS QUE NO TIENEN DATOS
     * Para alertar al superadmin
     * ============================================================ */
    public static function getAdminsSinDatos()
    {
        $db = self::db();

        try {
            $rows = $db->select(
                "SELECT u.id, u.username, u.authlevel 
                 FROM ".self::prefix()."users u
                 LEFT JOIN ".self::prefix()."admin_bank_data b ON b.admin_id = u.id
                 WHERE u.authlevel >= 2 
                   AND b.id IS NULL
                 ORDER BY u.authlevel DESC, u.username ASC"
            );
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /* ============================================================
     * ELIMINAR DATOS BANCARIOS (solo superadmin)
     * ============================================================ */
    public static function deleteBankData($adminId)
    {
        $adminId = (int)$adminId;
        if ($adminId <= 0) return false;

        $db = self::db();

        try {
            $db->delete(
                "DELETE FROM ".self::prefix()."admin_bank_data 
                 WHERE admin_id = :aid",
                [':aid' => $adminId]
            );
        } catch (Exception $e) {
            return false;
        }

        return true;
    }
}