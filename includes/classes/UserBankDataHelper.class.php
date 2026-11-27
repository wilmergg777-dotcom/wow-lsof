<?php
/**
 * UserBankDataHelper — Datos bancarios de los usuarios
 * AstroIO v6.0 — Sistema 1:1 SIN AMM
 *
 * Cada usuario debe registrar su tarjeta magnética y teléfono
 * para poder operar con el banco (invertir / retirar).
 *
 * Sin estos datos, el user NO ve la wallet.
 * Si intenta entrar, se le redirige a ?mode=setbankdata.
 *
 * Esta clase gestiona:
 *   - Datos bancarios del user (tarjeta, teléfono, titular, banco)
 *   - Solicitudes de cambio (con aprobación del admin)
 *
 * VALIDACIONES DEL USER (más estrictas que las del admin):
 *   - Tarjeta: min 16, max 50
 *   - Teléfono: min 8, max 30
 *   - Titular: max 100 (opcional)
 *   - Banco: max 100 (opcional)
 *
 * TABLAS:
 *   - uni1_users_bank_data           → datos actuales del user
 *   - uni1_users_bank_data_requests  → solicitudes de cambio pendientes
 *
 * MÉTODOS:
 *   ── Datos actuales ──
 *   tieneDatos($userId)        — bool
 *   getDatos($userId)          — array o null
 *   saveDatos($userId, ...)    — crea/actualiza con validación
 *   deleteDatos($userId)       — borra (solo superadmin)
 *
 *   ── Solicitudes de cambio ──
 *   solicitarCambio($userId, ...)          — crea solicitud
 *   tieneSolicitudPendiente($userId)       — bool
 *   getSolicitudPendiente($userId)         — la del user
 *   getSolicitudesPendientes()             — todas (admin)
 *   getSolicitudById($requestId)           — una específica
 *   aprobarCambio($requestId, $adminId)    — actualiza datos
 *   rechazarCambio($requestId, $adminId, $motivo)
 */

if (!defined('MODE')) die('Hacking attempt');

class UserBankDataHelper
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
     * TIMESTAMP ACTUAL
     * ============================================================ */
    private static function now()
    {
        return defined('TIMESTAMP') ? TIMESTAMP : time();
    }

    /* ============================================================
     * MENSAJE INTERNO (delega al WalletHelper)
     * ============================================================ */
    private static function sendMessage($receiverId, $subject, $text)
    {
        if (!class_exists('WalletHelper')) {
            if (defined('ROOT_PATH')) {
                require_once ROOT_PATH.'includes/classes/WalletHelper.class.php';
            }
        }

        if (class_exists('WalletHelper')) {
            return WalletHelper::sendSystemMessage($receiverId, $subject, $text);
        }

        return false;
    }

    /* ════════════════════════════════════════════════════════════
     * ═══ SECCION 1 — DATOS BANCARIOS DEL USER ═════════════════
     * ════════════════════════════════════════════════════════════ */

    /**
     * ¿El user tiene datos bancarios cargados?
     * (tarjeta Y teléfono no vacíos)
     */
    public static function tieneDatos($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return false;

        $db = self::db();

        try {
            $row = $db->selectSingle(
                "SELECT tarjeta_magnetica, telefono 
                 FROM ".self::prefix()."users_bank_data 
                 WHERE user_id = :uid 
                 LIMIT 1",
                [':uid' => $userId]
            );
        } catch (Exception $e) {
            return false;
        }

        if (!$row) return false;
        if (empty($row['tarjeta_magnetica'])) return false;
        if (empty($row['telefono']))          return false;

        return true;
    }

    /**
     * Devuelve los datos bancarios del user, o null si no tiene.
     */
    public static function getDatos($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return null;

        $db = self::db();

        try {
            $row = $db->selectSingle(
                "SELECT * FROM ".self::prefix()."users_bank_data 
                 WHERE user_id = :uid 
                 LIMIT 1",
                [':uid' => $userId]
            );
        } catch (Exception $e) {
            return null;
        }

        return $row ? $row : null;
    }

    /**
     * Guarda o actualiza los datos bancarios del user.
     *
     * Valida:
     *   - tarjeta: min 16, max 50
     *   - teléfono: min 8, max 30
     *   - titular: max 100 (opcional)
     *   - banco: max 100 (opcional)
     */
    public static function saveDatos($userId, $tarjeta, $telefono, $titular = '', $banco = '')
    {
        $userId   = (int)$userId;
        $tarjeta  = trim((string)$tarjeta);
        $telefono = trim((string)$telefono);
        $titular  = trim((string)$titular);
        $banco    = trim((string)$banco);

        // ─── Validaciones ─────────────────────────────────
        if ($userId <= 0) {
            return ['error' => 'ID de usuario inválido.'];
        }

        if (strlen($tarjeta) < 16) {
            return ['error' => 'La tarjeta magnética debe tener al menos 16 caracteres.'];
        }

        if (strlen($tarjeta) > 50) {
            return ['error' => 'La tarjeta magnética es demasiado larga (máx 50).'];
        }

        if (strlen($telefono) < 8) {
            return ['error' => 'El teléfono debe tener al menos 8 caracteres.'];
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

        $db  = self::db();
        $now = self::now();

        try {
            $existe = $db->selectSingle(
                "SELECT id FROM ".self::prefix()."users_bank_data 
                 WHERE user_id = :uid 
                 LIMIT 1",
                [':uid' => $userId]
            );

            if ($existe) {
                // ─── Actualizar ────────────────────────────
                $db->update(
                    "UPDATE ".self::prefix()."users_bank_data 
                     SET tarjeta_magnetica   = :tarjeta,
                         telefono            = :tel,
                         titular             = :titular,
                         banco               = :banco,
                         fecha_actualizacion = :now
                     WHERE user_id = :uid",
                    [
                        ':tarjeta' => $tarjeta,
                        ':tel'     => $telefono,
                        ':titular' => $titular !== '' ? $titular : null,
                        ':banco'   => $banco   !== '' ? $banco   : null,
                        ':now'     => $now,
                        ':uid'     => $userId
                    ]
                );
            } else {
                // ─── Insertar ──────────────────────────────
                $db->insert(
                    "INSERT INTO ".self::prefix()."users_bank_data 
                     (user_id, tarjeta_magnetica, telefono, titular, banco,
                      fecha_creacion, fecha_actualizacion)
                     VALUES (:uid, :tarjeta, :tel, :titular, :banco, :now, :now)",
                    [
                        ':uid'     => $userId,
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

    /**
     * Elimina los datos bancarios del user (solo superadmin).
     */
    public static function deleteDatos($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return false;

        $db = self::db();

        try {
            $db->delete(
                "DELETE FROM ".self::prefix()."users_bank_data 
                 WHERE user_id = :uid",
                [':uid' => $userId]
            );
        } catch (Exception $e) {
            return false;
        }

        return true;
    }

    /* ════════════════════════════════════════════════════════════
     * ═══ SECCION 2 — SOLICITUDES DE CAMBIO ═════════════════════
     * ════════════════════════════════════════════════════════════ */

    /**
     * ¿El user tiene una solicitud de cambio pendiente?
     */
    public static function tieneSolicitudPendiente($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return false;

        $db = self::db();

        try {
            $row = $db->selectSingle(
                "SELECT id FROM ".self::prefix()."users_bank_data_requests 
                 WHERE user_id = :uid 
                   AND estado = 'pendiente'
                 LIMIT 1",
                [':uid' => $userId]
            );
        } catch (Exception $e) {
            return false;
        }

        return $row ? true : false;
    }

    /**
     * Devuelve la solicitud pendiente del user, o null.
     */
    public static function getSolicitudPendiente($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return null;

        $db = self::db();

        try {
            $row = $db->selectSingle(
                "SELECT * FROM ".self::prefix()."users_bank_data_requests 
                 WHERE user_id = :uid 
                   AND estado = 'pendiente'
                 ORDER BY fecha_creacion DESC
                 LIMIT 1",
                [':uid' => $userId]
            );
        } catch (Exception $e) {
            return null;
        }

        return $row ? $row : null;
    }

    /**
     * Crea una solicitud de cambio de datos bancarios.
     * NO actualiza los datos actuales: eso pasa cuando el admin aprueba.
     */
    public static function solicitarCambio($userId, $tarjeta, $telefono, $titular = '', $banco = '')
    {
        $userId   = (int)$userId;
        $tarjeta  = trim((string)$tarjeta);
        $telefono = trim((string)$telefono);
        $titular  = trim((string)$titular);
        $banco    = trim((string)$banco);

        // ─── Validaciones (mismas que saveDatos) ──────────
        if ($userId <= 0) {
            return ['error' => 'ID de usuario inválido.'];
        }

        if (strlen($tarjeta) < 16) {
            return ['error' => 'La tarjeta magnética debe tener al menos 16 caracteres.'];
        }

        if (strlen($tarjeta) > 50) {
            return ['error' => 'La tarjeta magnética es demasiado larga (máx 50).'];
        }

        if (strlen($telefono) < 8) {
            return ['error' => 'El teléfono debe tener al menos 8 caracteres.'];
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

        // ─── No permitir 2 solicitudes pendientes ─────────
        if (self::tieneSolicitudPendiente($userId)) {
            return ['error' => 'Ya tenes una solicitud de cambio pendiente.'];
        }

        // ─── Debe tener datos actuales para poder cambiarlos ─
        if (!self::tieneDatos($userId)) {
            return ['error' => 'Primero carga tus datos bancarios.'];
        }

        $db  = self::db();
        $now = self::now();

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."users_bank_data_requests 
                 (user_id, tarjeta_magnetica, telefono, titular, banco,
                  estado, fecha_creacion)
                 VALUES (:uid, :tarjeta, :tel, :titular, :banco,
                         'pendiente', :now)",
                [
                    ':uid'     => $userId,
                    ':tarjeta' => $tarjeta,
                    ':tel'     => $telefono,
                    ':titular' => $titular !== '' ? $titular : null,
                    ':banco'   => $banco   !== '' ? $banco   : null,
                    ':now'     => $now
                ]
            );

            $requestId = (int)$db->lastInsertId();
        } catch (Exception $e) {
            return ['error' => 'Error al crear solicitud: ' . $e->getMessage()];
        }

        // Aviso al user
        self::sendMessage(
            $userId,
            'Solicitud de cambio enviada',
            'Tu solicitud de cambio de datos bancarios fue enviada.' . "\n\n" .
            'Un administrador la revisara pronto.'
        );

        // Aviso a todos los admins
        if (class_exists('WalletHelper')) {
            WalletHelper::sendMessageToAllAdmins(
                'Cambio de datos bancarios pendiente',
                'El usuario #' . $userId . ' solicito cambiar sus datos bancarios.' . "\n\n" .
                'Entra al panel de administracion del banco para aprobar o rechazar.'
            );
        }

        return ['success' => true, 'request_id' => $requestId];
    }

    /**
     * Devuelve TODAS las solicitudes pendientes (para el admin).
     */
    public static function getSolicitudesPendientes()
    {
        $db = self::db();

        try {
            $rows = $db->select(
                "SELECT r.*, u.username 
                 FROM ".self::prefix()."users_bank_data_requests r
                 LEFT JOIN ".self::prefix()."users u ON u.id = r.user_id
                 WHERE r.estado = 'pendiente'
                 ORDER BY r.fecha_creacion ASC"
            );
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /**
     * Devuelve una solicitud por ID.
     */
    public static function getSolicitudById($requestId)
    {
        $requestId = (int)$requestId;
        if ($requestId <= 0) return null;

        $db = self::db();

        try {
            $row = $db->selectSingle(
                "SELECT r.*, u.username 
                 FROM ".self::prefix()."users_bank_data_requests r
                 LEFT JOIN ".self::prefix()."users u ON u.id = r.user_id
                 WHERE r.id = :id 
                 LIMIT 1",
                [':id' => $requestId]
            );
        } catch (Exception $e) {
            return null;
        }

        return $row ? $row : null;
    }

    /**
     * Aprueba una solicitud de cambio:
     *   - Copia los datos de la solicitud a uni1_users_bank_data
     *   - Marca la solicitud como 'aprobada'
     *   - Avisa al user
     */
    public static function aprobarCambio($requestId, $adminId)
    {
        $requestId = (int)$requestId;
        $adminId   = (int)$adminId;

        if ($requestId <= 0 || $adminId <= 0) {
            return ['error' => 'Datos invalidos.'];
        }

        $solicitud = self::getSolicitudById($requestId);
        if (!$solicitud) {
            return ['error' => 'Solicitud no encontrada.'];
        }

        if ($solicitud['estado'] !== 'pendiente') {
            return ['error' => 'Esta solicitud ya fue procesada.'];
        }

        $userId = (int)$solicitud['user_id'];

        // 1. Actualizar los datos reales
        $res = self::saveDatos(
            $userId,
            $solicitud['tarjeta_magnetica'],
            $solicitud['telefono'],
            $solicitud['titular'] ?? '',
            $solicitud['banco'] ?? ''
        );

        if (isset($res['error'])) {
            return ['error' => 'Error al actualizar datos: ' . $res['error']];
        }

        // 2. Marcar la solicitud como aprobada
        $db  = self::db();
        $now = self::now();

        try {
            $db->update(
                "UPDATE ".self::prefix()."users_bank_data_requests 
                 SET estado = 'aprobada',
                     admin_id = :aid,
                     fecha_resolucion = :now
                 WHERE id = :id AND estado = 'pendiente'",
                [
                    ':aid' => $adminId,
                    ':now' => $now,
                    ':id'  => $requestId
                ]
            );
        } catch (Exception $e) {
            return ['error' => 'Error al marcar solicitud: ' . $e->getMessage()];
        }

        // 3. Aviso al user
        self::sendMessage(
            $userId,
            'Cambio de datos aprobado',
            'Tu cambio de datos bancarios fue APROBADO.' . "\n\n" .
            'Los nuevos datos ya estan activos.'
        );

        return ['success' => true];
    }

    /**
     * Rechaza una solicitud de cambio:
     *   - NO toca los datos actuales
     *   - Marca la solicitud como 'rechazada'
     *   - Avisa al user con motivo
     */
    public static function rechazarCambio($requestId, $adminId, $motivo = '')
    {
        $requestId = (int)$requestId;
        $adminId   = (int)$adminId;
        $motivo    = trim((string)$motivo);

        if ($requestId <= 0 || $adminId <= 0) {
            return ['error' => 'Datos invalidos.'];
        }

        if (strlen($motivo) < 3) {
            return ['error' => 'El motivo es obligatorio (minimo 3 caracteres).'];
        }

        $solicitud = self::getSolicitudById($requestId);
        if (!$solicitud) {
            return ['error' => 'Solicitud no encontrada.'];
        }

        if ($solicitud['estado'] !== 'pendiente') {
            return ['error' => 'Esta solicitud ya fue procesada.'];
        }

        $userId = (int)$solicitud['user_id'];

        $db  = self::db();
        $now = self::now();

        try {
            $db->update(
                "UPDATE ".self::prefix()."users_bank_data_requests 
                 SET estado = 'rechazada',
                     admin_id = :aid,
                     motivo_rechazo = :motivo,
                     fecha_resolucion = :now
                 WHERE id = :id AND estado = 'pendiente'",
                [
                    ':aid'    => $adminId,
                    ':motivo' => $motivo,
                    ':now'    => $now,
                    ':id'     => $requestId
                ]
            );
        } catch (Exception $e) {
            return ['error' => 'Error al rechazar: ' . $e->getMessage()];
        }

        // Aviso al user
        self::sendMessage(
            $userId,
            'Cambio de datos rechazado',
            'Tu cambio de datos bancarios fue RECHAZADO.' . "\n\n" .
            'Motivo: ' . $motivo . "\n\n" .
            'Tus datos actuales siguen vigentes.'
        );

        return ['success' => true];
    }
}