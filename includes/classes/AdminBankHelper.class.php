<?php
/**
 * AdminBankHelper — Cuenta CUP de los administradores
 * AstroIO v6.2 — Sistema 1:1 SIN AMM
 *
 * CAMBIOS v6.2 (respecto a v6.0):
 *   - FIX descontarRetiro():
 *       · Relee saldo despues del UPDATE y compara
 *       · Devuelve array con saldo_antes / saldo_despues
 *       · Ya no falla silenciosamente
 *   - FIX sumarAlProyecto():
 *       · Tipo de movimiento ahora es 'retiro' (antes decia 'inversion')
 *       · Devuelve array con marca_proyecto actualizada
 *
 * Gestiona la cuenta de auditoria de plata real (CUP) de cada admin.
 * Es un libro contable interno: registra quien tiene fisicamente
 * la plata que entro al servidor por las inversiones.
 *
 * CONCEPTO:
 *   - Cuando un usuario invierte, el admin que confirma recibe la
 *     plata fisicamente. Su cuenta CUP suma el monto total.
 *   - El 27% (o 30% sin referidor) de la inversion se "marca" como
 *     proyecto (marca_proyecto). Ese monto NO es del admin, es del proyecto.
 *   - El admin puede usar para retiros: saldo - marca_proyecto.
 *   - Al confirmar un retiro, el admin paga solo el NETO al usuario
 *     (bruto - 10% de comision). El 7% del retiro se suma a su
 *     marca_proyecto (mas el 3% si no hay referidor).
 *
 * DIFERENCIAS v6.0 vs v5.0:
 *   - Header actualizado (sin AMM)
 *   - Comentarios de porcentajes: 27%/30% (antes 17%/20%)
 *   - Comentarios de retiro: 10% comision (antes se hablaba de 90% neto)
 *   - La logica NO cambio (el helper es agnostico a los porcentajes)
 *
 * TRANSFERENCIAS ENTRE ADMINS:
 *   - Admin A -> Admin B (monto CUP)
 *   - B debe ACEPTAR para que se mueva el dinero
 *   - Si B rechaza o no responde en 24h: vuelve automaticamente a A
 *   - Solo se pueden transferir saldos disponibles (no marca_proyecto)
 *
 * AJUSTE MANUAL (solo superadmin):
 *   - Puede sumar/restar saldo a cualquier admin
 *   - Queda registrado en movimientos con motivo
 *   - PUEDE dejar saldo negativo si el superadmin lo fuerza
 *
 * FONDO PROYECTO (retiro global):
 *   - Superadmin elige un admin especifico y el monto a retirar
 *   - El admin elegido debe tener suficiente marca_proyecto
 *   - Se descuenta del admin (QUEMA DE SALDO)
 *   - El dinero NO se transfiere al superadmin, simplemente se elimina del sistema
 *
 * METODOS:
 *   ── Cuenta ──
 *   getAccount($adminId)
 *   getAllAccounts()
 *   getAvailableBalance($adminId)   — saldo - marca_proyecto
 *   ensureAccount($adminId)
 *
 *   ── Movimientos ──
 *   getMovimientos($adminId, $filtros)
 *   getMovimientosGlobales($filtros)
 *   logMovimiento($adminId, $tipo, $monto, $saldoRes, $ref, $detalle)
 *
 *   ── Flujo banco ──
 *   sumarInversion($adminId, $monto, $marcaProyecto, $refId)
 *   descontarRetiro($adminId, $monto, $refId)
 *   sumarAlProyecto($adminId, $monto, $refId)
 *   restarProyectoGlobal($targetAdminId, $superadminId, $monto)
 *   ajusteManual($adminId, $monto, $motivo, $superadminId)
 *
 *   ── Transferencias ──
 *   crearTransferencia($fromId, $toId, $monto)
 *   aceptarTransferencia($transferId, $adminId)
 *   rechazarTransferencia($transferId, $adminId)
 *   cancelarTransferencia($transferId, $adminId)
 *   getTransferenciasPendientes($adminId)
 *   getTransferenciasEnviadas($adminId)
 *
 *   ── Cron ──
 *   processTimeouts()   — expira transferencias a las 24h
 */

if (!defined('MODE')) die('Hacking attempt');

class AdminBankHelper
{
    /* ============================================================
     * CONSTANTES
     * ============================================================ */
    const TIMEOUT_TRANSFER_HORAS = 24;

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
     * ═══ SECCION 1 — CUENTA CUP ════════════════════════════════
     * ════════════════════════════════════════════════════════════ */

    /**
     * Asegura que exista la cuenta del admin.
     * Si no existe, la crea con saldo 0.
     */
    public static function ensureAccount($adminId)
    {
        $db = self::db();
        $adminId = (int)$adminId;
        if ($adminId <= 0) return false;

        try {
            $row = $db->selectSingle(
                "SELECT id FROM ".self::prefix()."admin_bank_accounts 
                 WHERE admin_id = :aid LIMIT 1",
                [':aid' => $adminId]
            );

            if (!$row) {
                $now = self::now();
                $db->insert(
                    "INSERT INTO ".self::prefix()."admin_bank_accounts 
                     (admin_id, saldo, marca_proyecto, fecha_creacion, ultima_actualizacion)
                     VALUES (:aid, 0, 0, :now, :now)",
                    [':aid' => $adminId, ':now' => $now]
                );
            }
        } catch (Exception $e) {
            return false;
        }

        return true;
    }

    /**
     * Devuelve la cuenta del admin (saldo + marca_proyecto).
     * Si no existe, la crea y la devuelve.
     */
    public static function getAccount($adminId)
    {
        $db = self::db();
        $adminId = (int)$adminId;
        if ($adminId <= 0) {
            return [
                'admin_id'       => 0,
                'saldo'          => 0,
                'marca_proyecto' => 0
            ];
        }

        self::ensureAccount($adminId);

        try {
            $row = $db->selectSingle(
                "SELECT * FROM ".self::prefix()."admin_bank_accounts 
                 WHERE admin_id = :aid LIMIT 1",
                [':aid' => $adminId]
            );
        } catch (Exception $e) {
            $row = null;
        }

        if (!$row) {
            return [
                'admin_id'       => $adminId,
                'saldo'          => 0,
                'marca_proyecto' => 0
            ];
        }

        return $row;
    }

    /**
     * Saldo disponible = saldo - marca_proyecto
     * Es lo que el admin puede usar para transferir o pagar retiros.
     */
    public static function getAvailableBalance($adminId)
    {
        $acc = self::getAccount($adminId);
        $saldo = (float)$acc['saldo'];
        $marca = (float)$acc['marca_proyecto'];
        $disp  = $saldo - $marca;
        return $disp > 0 ? $disp : 0;
    }

    /**
     * Lista TODAS las cuentas con username + authlevel (todos se ven entre si)
     */
    public static function getAllAccounts()
    {
        $db = self::db();

        try {
            $rows = $db->select(
                "SELECT a.*, u.username, u.authlevel 
                 FROM ".self::prefix()."admin_bank_accounts a
                 LEFT JOIN ".self::prefix()."users u ON u.id = a.admin_id
                 ORDER BY a.saldo DESC"
            );
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /* ════════════════════════════════════════════════════════════
     * ═══ SECCION 2 — MOVIMIENTOS ════════════════════════════════
     * ════════════════════════════════════════════════════════════ */

    /**
     * Registra un movimiento en el historial.
     * tipo: inversion, retiro, transferencia_enviada, transferencia_recibida,
     *       retiro_proyecto, ajuste_manual, transferencia_cancelada
     */
    public static function logMovimiento($adminId, $tipo, $monto, $saldoResultante, $adminRelacionado = null, $referenciaId = null, $detalle = null)
    {
        $db = self::db();

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."admin_bank_movements 
                 (admin_id, tipo, monto, saldo_resultante, admin_relacionado,
                  referencia_id, detalle, fecha)
                 VALUES (:aid, :tipo, :monto, :saldo, :rel, :ref, :det, :now)",
                [
                    ':aid'   => (int)$adminId,
                    ':tipo'  => $tipo,
                    ':monto' => $monto,
                    ':saldo' => $saldoResultante,
                    ':rel'   => $adminRelacionado ? (int)$adminRelacionado : null,
                    ':ref'   => $referenciaId ? (int)$referenciaId : null,
                    ':det'   => $detalle,
                    ':now'   => self::now()
                ]
            );
        } catch (Exception $e) {
            return false;
        }

        return true;
    }

    /**
     * Devuelve movimientos de un admin con filtros opcionales.
     * Si $adminId es 0 o menor, devuelve TODOS los movimientos del servidor.
     * $filtros = ['tipo' => '...', 'desde' => ts, 'hasta' => ts, 'admin_rel' => id]
     */
    public static function getMovimientos($adminId, $filtros = [], $limit = 100)
    {
        $db = self::db();
        $adminId = (int)$adminId;
        $limit = (int)$limit;
        if ($limit <= 0 || $limit > 500) $limit = 100;

        // 🔥 FIX CLAVE: Si el ID es 0, significa que piden "Todos los admins".
        // Llamamos a la función global y evitamos que la consulta busque el ID 0.
        if ($adminId <= 0) {
            return self::getMovimientosGlobales($filtros, $limit);
        }

        $sql = "SELECT m.*, u.username AS admin_name, ur.username AS admin_rel_name
                FROM ".self::prefix()."admin_bank_movements m
                LEFT JOIN ".self::prefix()."users u  ON u.id  = m.admin_id
                LEFT JOIN ".self::prefix()."users ur ON ur.id = m.admin_relacionado
                WHERE m.admin_id = :aid";
        $params = [':aid' => $adminId];

        if (!empty($filtros['tipo'])) {
            $sql .= " AND m.tipo = :tipo";
            $params[':tipo'] = $filtros['tipo'];
        }

        if (!empty($filtros['desde'])) {
            $sql .= " AND m.fecha >= :desde";
            $params[':desde'] = (int)$filtros['desde'];
        }

        if (!empty($filtros['hasta'])) {
            $sql .= " AND m.fecha <= :hasta";
            $params[':hasta'] = (int)$filtros['hasta'];
        }

        if (!empty($filtros['admin_rel'])) {
            $sql .= " AND m.admin_relacionado = :arel";
            $params[':arel'] = (int)$filtros['admin_rel'];
        }

        $sql .= " ORDER BY m.fecha DESC LIMIT ".$limit;

        try {
            $rows = $db->select($sql, $params);
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /**
     * Movimientos de TODOS los admins (vista superadmin)
     */
    public static function getMovimientosGlobales($filtros = [], $limit = 200)
    {
        $db = self::db();
        $limit = (int)$limit;
        if ($limit <= 0 || $limit > 500) $limit = 200;

        $sql = "SELECT m.*, u.username AS admin_name, ur.username AS admin_rel_name
                FROM ".self::prefix()."admin_bank_movements m
                LEFT JOIN ".self::prefix()."users u  ON u.id  = m.admin_id
                LEFT JOIN ".self::prefix()."users ur ON ur.id = m.admin_relacionado
                WHERE 1=1";
        $params = [];

        if (!empty($filtros['tipo'])) {
            $sql .= " AND m.tipo = :tipo";
            $params[':tipo'] = $filtros['tipo'];
        }

        if (!empty($filtros['admin_id'])) {
            $sql .= " AND m.admin_id = :aid";
            $params[':aid'] = (int)$filtros['admin_id'];
        }

        if (!empty($filtros['desde'])) {
            $sql .= " AND m.fecha >= :desde";
            $params[':desde'] = (int)$filtros['desde'];
        }

        if (!empty($filtros['hasta'])) {
            $sql .= " AND m.fecha <= :hasta";
            $params[':hasta'] = (int)$filtros['hasta'];
        }

        $sql .= " ORDER BY m.fecha DESC LIMIT ".$limit;

        try {
            $rows = $db->select($sql, $params);
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /* ════════════════════════════════════════════════════════════
     * ═══ SECCION 3 — FLUJO DEL BANCO ═══════════════════════════
     * ════════════════════════════════════════════════════════════ */

    /**
     * Al confirmar una inversion (v6.0):
     *   - Suma el monto total invertido al saldo CUP del admin
     *   - Marca el % de proyecto (27% o 30%) como marca_proyecto
     *   - Registra movimiento
     *
     * Ejemplo: usuario invierte 100 Kyber
     *   Admin CUP +$100, marca_proyecto += $27 (o $30 sin referidor)
     *
     * Nota: el "monto" es el Kyber invertido (que en CUP es 1:1).
     *       el "marcaProyecto" ya viene calculado desde WalletHelper.
     */
    public static function sumarInversion($adminId, $monto, $marcaProyecto, $refId = null)
    {
        $db = self::db();
        $adminId = (int)$adminId;
        $monto   = (float)$monto;
        $marca   = (float)$marcaProyecto;

        if ($adminId <= 0 || $monto <= 0) {
            return ['error' => 'Datos invalidos.'];
        }

        self::ensureAccount($adminId);

        try {
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_accounts 
                 SET saldo = saldo + :monto,
                     marca_proyecto = marca_proyecto + :marca,
                     ultima_actualizacion = :now
                 WHERE admin_id = :aid",
                [
                    ':monto' => $monto,
                    ':marca' => $marca,
                    ':now'   => self::now(),
                    ':aid'   => $adminId
                ]
            );

            $acc = self::getAccount($adminId);

            self::logMovimiento(
                $adminId,
                'inversion',
                $monto,
                (float)$acc['saldo'],
                $adminId, // <-- FIX: Pasa el ID del admin que realizó la operación
                $refId,
                'Inversion confirmada (+' . number_format($monto, 2) . ' CUP, ' .
                number_format($marca, 2) . ' marcado proyecto)'
            );
        } catch (Exception $e) {
            return ['error' => 'Error al sumar inversion: ' . $e->getMessage()];
        }

        return ['success' => true];
    }

    /**
     * Al confirmar un retiro (v6.2 FIX):
     *   - Descuenta el NETO pagado al usuario (bruto - 10% comision)
     *   - Relee saldo y valida que el UPDATE se aplico
     *   - Registra movimiento
     *
     * Solo se descuenta lo que SALE del servidor (dinero real al usuario).
     * El 7% (o 10% sin referidor) del proyecto se suma por separado con
     * sumarAlProyecto().
     *
     * ⚡ NUEVO: devuelve array con saldo_antes / saldo_despues para debug
     * ⚡ NUEVO: si el UPDATE no aplica, devuelve error claro
     */
    public static function descontarRetiro($adminId, $monto, $refId = null)
    {
        $db = self::db();
        $adminId = (int)$adminId;
        $monto   = (float)$monto;

        if ($adminId <= 0 || $monto <= 0) {
            return ['error' => 'Datos invalidos (adminId='.$adminId.', monto='.$monto.')'];
        }

        self::ensureAccount($adminId);

        // ⚡ NUEVO: leer saldo ANTES
        $accAntes = self::getAccount($adminId);
        $saldoAntes = (float)$accAntes['saldo'];

        if ($saldoAntes < $monto) {
            return [
                'error' => 'Saldo CUP insuficiente. Tenes ' . number_format($saldoAntes, 2) .
                           ' CUP y necesitas ' . number_format($monto, 2) . ' CUP.'
            ];
        }

        try {
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_accounts 
                 SET saldo = saldo - :monto,
                     ultima_actualizacion = :now
                 WHERE admin_id = :aid",
                [
                    ':monto' => $monto,
                    ':now'   => self::now(),
                    ':aid'   => $adminId
                ]
            );

            // ⚡ NUEVO: releer saldo DESPUES y comparar
            $accDespues = self::getAccount($adminId);
            $saldoDespues = (float)$accDespues['saldo'];

            $esperado = $saldoAntes - $monto;
            if (abs($esperado - $saldoDespues) > 0.01) {
                if (defined('DEBUG') && DEBUG) {
                    error_log('descontarRetiro: UPDATE no aplico bien. antes=' . $saldoAntes .
                              ' monto=' . $monto . ' esperado=' . $esperado .
                              ' despues=' . $saldoDespues);
                }
                return [
                    'error' => 'El descuento no se aplico correctamente. ' .
                               'Antes=' . number_format($saldoAntes, 2) .
                               ' / Despues=' . number_format($saldoDespues, 2) . '.'
                ];
            }

            self::logMovimiento(
                $adminId,
                'retiro',
                -$monto,
                $saldoDespues,
                $adminId, // <-- FIX: Pasa el ID del admin que realizó la operación
                $refId,
                'Retiro pagado al user (-' . number_format($monto, 2) . ' CUP)'
            );

            return [
                'success'       => true,
                'saldo_antes'   => $saldoAntes,
                'saldo_despues' => $saldoDespues,
                'monto'         => $monto
            ];

        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('descontarRetiro ERROR: ' . $e->getMessage());
            }
            return ['error' => 'Error al descontar retiro: ' . $e->getMessage()];
        }
    }

    /**
     * Al confirmar un retiro (v6.2 FIX):
     *   Marca el 7% (o 10% sin referidor) del bruto como proyecto.
     *   El CUP del proyecto se queda en el admin (no sale), solo se marca.
     *
     * ⚡ NUEVO: el tipo de movimiento ahora es 'retiro' (antes decia 'inversion')
     * ⚡ NUEVO: devuelve array con la marca_proyecto actualizada
     */
    public static function sumarAlProyecto($adminId, $monto, $refId = null)
    {
        $db = self::db();
        $adminId = (int)$adminId;
        $monto   = (float)$monto;

        if ($adminId <= 0 || $monto <= 0) {
            return ['success' => true, 'marca_proyecto' => 0];
        }

        self::ensureAccount($adminId);

        try {
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_accounts 
                 SET marca_proyecto = marca_proyecto + :monto,
                     ultima_actualizacion = :now
                 WHERE admin_id = :aid",
                [
                    ':monto' => $monto,
                    ':now'   => self::now(),
                    ':aid'   => $adminId
                ]
            );

            $acc = self::getAccount($adminId);
            $marca = (float)$acc['marca_proyecto'];

            // ⚡ FIX: tipo 'retiro' (antes decia 'inversion')
            self::logMovimiento(
                $adminId,
                'retiro',
                0,
                (float)$acc['saldo'],
                $adminId, // <-- FIX: Pasa el ID del admin que realizó la operación
                $refId,
                'Proyecto +' . number_format($monto, 2) . ' CUP marcado (comision retiro)'
            );

            return [
                'success'        => true,
                'marca_proyecto' => $marca,
                'monto'          => $monto
            ];

        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('sumarAlProyecto ERROR: ' . $e->getMessage());
            }
            return ['error' => 'Error al marcar proyecto: ' . $e->getMessage()];
        }
    }

    /**
     * Superadmin retira el fondo proyecto (v6.4 - QUEMA DE SALDO):
     *   - Descuenta del admin elegido (saldo y marca_proyecto)
     *   - NO se suma al superadmin (el dinero se QUEMA, sale del sistema)
     *   - Registra movimientos en ambos (auditoria)
     */
    public static function restarProyectoGlobal($targetAdminId, $superadminId, $monto)
    {
        $db = self::db();
        $targetAdminId = (int)$targetAdminId;
        $superadminId  = (int)$superadminId;
        $monto         = (float)$monto;

        if ($targetAdminId <= 0 || $superadminId <= 0 || $monto <= 0) {
            return ['error' => 'Datos invalidos.'];
        }

        $accTarget = self::getAccount($targetAdminId);
        if ((float)$accTarget['marca_proyecto'] < $monto) {
            return ['error' => 'Ese admin solo tiene ' . 
                number_format((float)$accTarget['marca_proyecto'], 2) . 
                ' CUP marcados como Proyecto.'];
        }

        self::ensureAccount($superadminId);

        try {
            // 1. Descontar del admin elegido (saldo + marca) -> LA PLATA SE QUEMA
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_accounts 
                 SET saldo = saldo - :monto,
                     marca_proyecto = marca_proyecto - :monto,
                     ultima_actualizacion = :now
                 WHERE admin_id = :aid",
                [
                    ':monto' => $monto,
                    ':now'   => self::now(),
                    ':aid'   => $targetAdminId
                ]
            );

            // 2. NO se suma al superadmin. Solo registramos auditoría.

            // 3. Log en el admin afectado (descuento real)
            $accT = self::getAccount($targetAdminId);
            self::logMovimiento(
                $targetAdminId,
                'ajuste_manual',
                -$monto,
                (float)$accT['saldo'],
                $superadminId,
                null,
                'Liquidación de Fondo Proyecto (Quema de saldo)'
            );

            // 4. Log en el superadmin (Auditoría, sin sumar saldo)
            $accS = self::getAccount($superadminId);
            self::logMovimiento(
                $superadminId,
                'ajuste_manual',
                0,
                (float)$accS['saldo'],
                $targetAdminId,
                null,
                'Liquidación ejecutada sobre admin #' . $targetAdminId . 
                ' (-' . number_format($monto, 2) . ' CUP quemados)'
            );
        } catch (Exception $e) {
            return ['error' => 'Error al retirar fondo proyecto: ' . $e->getMessage()];
        }

        return ['success' => true, 'monto' => $monto];
    }

    /**
     * Ajuste manual (solo superadmin):
     *   - Suma o resta saldo a un admin
     *   - Puede dejar saldo negativo si el superadmin lo fuerza
     *   - Queda registrado con motivo
     */
    public static function ajusteManual($adminId, $monto, $motivo, $superadminId)
    {
        $db = self::db();
        $adminId      = (int)$adminId;
        $superadminId = (int)$superadminId;
        $monto        = (float)$monto;
        $motivo       = trim((string)$motivo);

        if ($adminId <= 0 || $superadminId <= 0) {
            return ['error' => 'Datos invalidos.'];
        }

        if ($monto == 0) {
            return ['error' => 'El monto no puede ser 0.'];
        }

        if (strlen($motivo) < 3) {
            return ['error' => 'El motivo es obligatorio (minimo 3 caracteres).'];
        }

        self::ensureAccount($adminId);

        try {
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_accounts 
                 SET saldo = saldo + :monto,
                     ultima_actualizacion = :now
                 WHERE admin_id = :aid",
                [
                    ':monto' => $monto,
                    ':now'   => self::now(),
                    ':aid'   => $adminId
                ]
            );

            $acc = self::getAccount($adminId);

            self::logMovimiento(
                $adminId,
                'ajuste_manual',
                $monto,
                (float)$acc['saldo'],
                $superadminId,
                null,
                'Ajuste manual: ' . $motivo
            );

            self::sendMessage(
                $adminId,
                'Ajuste en tu cuenta CUP',
                'El superadmin hizo un ajuste de ' . 
                ($monto > 0 ? '+' : '') . number_format($monto, 2) . 
                ' CUP. Motivo: ' . $motivo
            );
        } catch (Exception $e) {
            return ['error' => 'Error al ajustar: ' . $e->getMessage()];
        }

        return ['success' => true, 'monto' => $monto];
    }

    /* ════════════════════════════════════════════════════════════
     * ═══ SECCION 4 — TRANSFERENCIAS ENTRE ADMINS ═══════════════
     * ════════════════════════════════════════════════════════════ */

    /**
     * Admin A crea una transferencia hacia Admin B.
     * Solo puede transferir saldo DISPONIBLE (saldo - marca_proyecto).
     * La transferencia queda PENDIENTE hasta que B acepte.
     */
    public static function crearTransferencia($fromAdminId, $toAdminId, $monto)
    {
        $db = self::db();
        $fromAdminId = (int)$fromAdminId;
        $toAdminId   = (int)$toAdminId;
        $monto       = (float)$monto;

        if ($fromAdminId <= 0 || $toAdminId <= 0) {
            return ['error' => 'Datos invalidos.'];
        }

        if ($fromAdminId === $toAdminId) {
            return ['error' => 'No podes transferirte a vos mismo.'];
        }

        if ($monto <= 0) {
            return ['error' => 'El monto debe ser mayor a 0.'];
        }

        $disponible = self::getAvailableBalance($fromAdminId);
        if ($disponible < $monto) {
            return ['error' => 'No tenes suficiente saldo disponible. ' .
                'Disponible: ' . number_format($disponible, 2) . ' CUP.'];
        }

        self::ensureAccount($fromAdminId);
        self::ensureAccount($toAdminId);

        $now = self::now();
        $expira = $now + (self::TIMEOUT_TRANSFER_HORAS * 3600);

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."admin_bank_transfers 
                 (from_admin_id, to_admin_id, monto, estado,
                  fecha_creacion, fecha_expiracion)
                 VALUES (:fid, :tid, :monto, 'pendiente', :now, :exp)",
                [
                    ':fid'   => $fromAdminId,
                    ':tid'   => $toAdminId,
                    ':monto' => $monto,
                    ':now'   => $now,
                    ':exp'   => $expira
                ]
            );

            $transferId = (int)$db->lastInsertId();
        } catch (Exception $e) {
            return ['error' => 'Error al crear transferencia: ' . $e->getMessage()];
        }

        // Mensaje al receptor
        self::sendMessage(
            $toAdminId,
            'Nueva transferencia CUP pendiente',
            'Un admin te quiere transferir ' . number_format($monto, 2) . 
            ' CUP. Entra a tu Saldo CUP para aceptar o rechazar. ' .
            'Expira en ' . self::TIMEOUT_TRANSFER_HORAS . ' horas.'
        );

        return ['success' => true, 'transfer_id' => $transferId];
    }

    /**
     * Admin B acepta la transferencia:
     *   - Se descuenta al A
     *   - Se suma al B
     *   - Se registran ambos movimientos
     */
    public static function aceptarTransferencia($transferId, $adminId)
    {
        $db = self::db();
        $transferId = (int)$transferId;
        $adminId    = (int)$adminId;

        $t = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."admin_bank_transfers 
             WHERE id = :id AND estado = 'pendiente' LIMIT 1",
            [':id' => $transferId]
        );

        if (!$t) {
            return ['error' => 'Transferencia no encontrada o ya procesada.'];
        }

        if ((int)$t['to_admin_id'] !== $adminId) {
            return ['error' => 'Esta transferencia no es para vos.'];
        }

        $fromId = (int)$t['from_admin_id'];
        $monto  = (float)$t['monto'];

        // Verificar que A todavia tenga saldo disponible
        $disponible = self::getAvailableBalance($fromId);
        if ($disponible < $monto) {
            // Cancelar automaticamente: A ya no tiene saldo
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_transfers 
                 SET estado = 'cancelada', fecha_resolucion = :now
                 WHERE id = :id",
                [':now' => self::now(), ':id' => $transferId]
            );

            return ['error' => 'El admin de origen ya no tiene saldo disponible. Transferencia cancelada.'];
        }

        try {
            // 1. Descontar al emisor
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_accounts 
                 SET saldo = saldo - :monto,
                     ultima_actualizacion = :now
                 WHERE admin_id = :aid",
                [
                    ':monto' => $monto,
                    ':now'   => self::now(),
                    ':aid'   => $fromId
                ]
            );

            // 2. Sumar al receptor
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_accounts 
                 SET saldo = saldo + :monto,
                     ultima_actualizacion = :now
                 WHERE admin_id = :aid",
                [
                    ':monto' => $monto,
                    ':now'   => self::now(),
                    ':aid'   => $adminId
                ]
            );

            // 3. Marcar la transferencia como aceptada
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_transfers 
                 SET estado = 'aceptada', fecha_resolucion = :now
                 WHERE id = :id",
                [':now' => self::now(), ':id' => $transferId]
            );

            // 4. Logs
            $accF = self::getAccount($fromId);
            self::logMovimiento(
                $fromId,
                'transferencia_enviada',
                -$monto,
                (float)$accF['saldo'],
                $adminId,
                $transferId,
                'Transferencia enviada a admin #' . $adminId
            );

            $accT = self::getAccount($adminId);
            self::logMovimiento(
                $adminId,
                'transferencia_recibida',
                $monto,
                (float)$accT['saldo'],
                $fromId,
                $transferId,
                'Transferencia recibida de admin #' . $fromId
            );
        } catch (Exception $e) {
            return ['error' => 'Error al aceptar: ' . $e->getMessage()];
        }

        // Mensaje al emisor
        self::sendMessage(
            $fromId,
            'Transferencia aceptada',
            'El admin #' . $adminId . ' acepto tu transferencia de ' . 
            number_format($monto, 2) . ' CUP.'
        );

        return ['success' => true, 'monto' => $monto];
    }

    /**
     * Admin B rechaza la transferencia.
     * No se mueve nada: vuelve automaticamente a A.
     */
    public static function rechazarTransferencia($transferId, $adminId)
    {
        $db = self::db();
        $transferId = (int)$transferId;
        $adminId    = (int)$adminId;

        $t = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."admin_bank_transfers 
             WHERE id = :id AND estado = 'pendiente' LIMIT 1",
            [':id' => $transferId]
        );

        if (!$t) {
            return ['error' => 'Transferencia no encontrada o ya procesada.'];
        }

        if ((int)$t['to_admin_id'] !== $adminId) {
            return ['error' => 'Esta transferencia no es para vos.'];
        }

        $fromId = (int)$t['from_admin_id'];
        $monto  = (float)$t['monto'];

        try {
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_transfers 
                 SET estado = 'rechazada', fecha_resolucion = :now
                 WHERE id = :id",
                [':now' => self::now(), ':id' => $transferId]
            );

            $accF = self::getAccount($fromId);
            self::logMovimiento(
                $fromId,
                'transferencia_cancelada',
                0,
                (float)$accF['saldo'],
                $adminId,
                $transferId,
                'Transferencia rechazada por admin #' . $adminId
            );
        } catch (Exception $e) {
            return ['error' => 'Error al rechazar: ' . $e->getMessage()];
        }

        // Mensaje al emisor
        self::sendMessage(
            $fromId,
            'Transferencia rechazada',
            'El admin #' . $adminId . ' rechazo tu transferencia de ' . 
            number_format($monto, 2) . ' CUP. El saldo sigue en tu cuenta.'
        );

        return ['success' => true];
    }

    /**
     * Admin A cancela su propia transferencia (mientras este pendiente).
     */
    public static function cancelarTransferencia($transferId, $adminId)
    {
        $db = self::db();
        $transferId = (int)$transferId;
        $adminId    = (int)$adminId;

        $t = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."admin_bank_transfers 
             WHERE id = :id AND estado = 'pendiente' LIMIT 1",
            [':id' => $transferId]
        );

        if (!$t) {
            return ['error' => 'Transferencia no encontrada o ya procesada.'];
        }

        if ((int)$t['from_admin_id'] !== $adminId) {
            return ['error' => 'Solo el emisor puede cancelarla.'];
        }

        try {
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_transfers 
                 SET estado = 'cancelada', fecha_resolucion = :now
                 WHERE id = :id",
                [':now' => self::now(), ':id' => $transferId]
            );

            $acc = self::getAccount($adminId);
            self::logMovimiento(
                $adminId,
                'transferencia_cancelada',
                0,
                (float)$acc['saldo'],
                (int)$t['to_admin_id'],
                $transferId,
                'Transferencia cancelada por el emisor'
            );
        } catch (Exception $e) {
            return ['error' => 'Error al cancelar: ' . $e->getMessage()];
        }

        // Mensaje al receptor
        self::sendMessage(
            (int)$t['to_admin_id'],
            'Transferencia cancelada',
            'El admin #' . $adminId . ' cancelo la transferencia de ' . 
            number_format((float)$t['monto'], 2) . ' CUP.'
        );

        return ['success' => true];
    }

    /**
     * Transferencias pendientes que RECIBIO el admin (para aceptar/rechazar).
     */
    public static function getTransferenciasPendientes($adminId)
    {
        $db = self::db();
        $adminId = (int)$adminId;

        try {
            $rows = $db->select(
                "SELECT t.*, u.username AS from_username
                 FROM ".self::prefix()."admin_bank_transfers t
                 LEFT JOIN ".self::prefix()."users u ON u.id = t.from_admin_id
                 WHERE t.to_admin_id = :aid 
                   AND t.estado = 'pendiente'
                 ORDER BY t.fecha_creacion DESC",
                [':aid' => $adminId]
            );
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /**
     * Transferencias que ENVIO el admin (para poder cancelarlas).
     */
    public static function getTransferenciasEnviadas($adminId)
    {
        $db = self::db();
        $adminId = (int)$adminId;

        try {
            $rows = $db->select(
                "SELECT t.*, u.username AS to_username
                 FROM ".self::prefix()."admin_bank_transfers t
                 LEFT JOIN ".self::prefix()."users u ON u.id = t.to_admin_id
                 WHERE t.from_admin_id = :aid 
                   AND t.estado = 'pendiente'
                 ORDER BY t.fecha_creacion DESC",
                [':aid' => $adminId]
            );
        } catch (Exception $e) {
            return [];
        }

        return $rows ? $rows : [];
    }

    /* ════════════════════════════════════════════════════════════
     * ═══ SECCION 5 — CRON DE TIMEOUTS (24h) ════════════════════
     * ════════════════════════════════════════════════════════════ */

    /**
     * Expira transferencias pendientes que superaron las 24h.
     * Vuelven automaticamente al emisor (no se mueve nada).
     */
    public static function processTimeouts()
    {
        $db  = self::db();
        $now = self::now();

        try {
            $rows = $db->select(
                "SELECT id, from_admin_id, to_admin_id, monto 
                 FROM ".self::prefix()."admin_bank_transfers 
                 WHERE estado = 'pendiente' 
                   AND fecha_expiracion < :now",
                [':now' => $now]
            );
        } catch (Exception $e) {
            return ['expiradas' => 0];
        }

        if (!$rows) return ['expiradas' => 0];

        $count = 0;

        foreach ($rows as $t) {
            $db->update(
                "UPDATE ".self::prefix()."admin_bank_transfers 
                 SET estado = 'expirada', fecha_resolucion = :now
                 WHERE id = :id AND estado = 'pendiente'",
                [':now' => $now, ':id' => $t['id']]
            );

            $acc = self::getAccount((int)$t['from_admin_id']);
            self::logMovimiento(
                (int)$t['from_admin_id'],
                'transferencia_cancelada',
                0,
                (float)$acc['saldo'],
                (int)$t['to_admin_id'],
                (int)$t['id'],
                'Transferencia expirada (' . self::TIMEOUT_TRANSFER_HORAS . 'h)'
            );

            self::sendMessage(
                (int)$t['from_admin_id'],
                'Transferencia expirada',
                'Tu transferencia de ' . number_format((float)$t['monto'], 2) . 
                ' CUP expiro a las ' . self::TIMEOUT_TRANSFER_HORAS . 
                ' horas sin respuesta. El saldo sigue en tu cuenta.'
            );

            self::sendMessage(
                (int)$t['to_admin_id'],
                'Transferencia expirada',
                'La transferencia pendiente de ' . number_format((float)$t['monto'], 2) . 
                ' CUP expiro automaticamente.'
            );

            $count++;
        }

        return ['expiradas' => $count];
    }
}