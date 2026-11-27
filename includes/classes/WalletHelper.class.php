<?php
/**
 * WalletHelper — Logica del sistema de Wallet/Banco
 * AstroIO v7.4 — Sistema 1:1 SIN AMM con Bancos Separados (CUP y QvaPay)
 */

if (!defined('MODE')) die('Hacking attempt');

class WalletHelper
{
    /* ═══════════════════════════════════════════════════════════
     * CONSTANTES — INVERSION
     * ═══════════════════════════════════════════════════════════ */
    const PCT_PROYECTO              = 27;
    const PCT_REFERIDOR             = 3;
    const PCT_PROYECTO_SIN_REF      = 30;
    const MIN_INVERSION_KYBER       = 100;
    const TIMEOUT_HORAS_INV         = 48;

    /* ═══════════════════════════════════════════════════════════
     * CONSTANTES — RETIRO
     * ═══════════════════════════════════════════════════════════ */
    const PCT_RET_COMISION          = 10;
    const PCT_RET_PROYECTO          = 7;
    const PCT_RET_REFERIDOR         = 3;
    const TIMEOUT_HORAS_RET         = 72;

    /* ═══════════════════════════════════════════════════════════
     * CONSTANTES — LIMITES
     * ═══════════════════════════════════════════════════════════ */
    const MAX_SOLICITUDES_ACTIVAS   = 2;
    const MAX_RETIROS_PENDIENTES    = 1;

    /* ═══════════════════════════════════════════════════════════
     * CONSTANTES — MENSAJES
     * ═══════════════════════════════════════════════════════════ */
    const MSG_TYPE_SYSTEM           = 4;
    const MSG_SENDER_NAME           = 'Banco AstroIO';
    const MSG_SENDER_ID             = 0;

    /* ════════════════════════════════════════════════════════════
     * HELPERS INTERNOS
     * ════════════════════════════════════════════════════════════ */

    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    private static function db()
    {
        return Database::get();
    }

    private static function now()
    {
        return defined('TIMESTAMP') ? TIMESTAMP : time();
    }

    private static function getUsername($userId)
    {
        $db = self::db();
        $userId = (int)$userId;
        try {
            $row = $db->selectSingle(
                "SELECT username FROM ".self::prefix()."users WHERE id = :uid",
                [':uid' => $userId]
            );
            return $row ? $row['username'] : ('ID ' . $userId);
        } catch (Exception $e) {
            return 'ID ' . $userId;
        }
    }

    // 🆕 Obtiene el método de retiro del usuario
    private static function getMetodoRetiro($userId)
    {
        $db = self::db();
        try {
            $row = $db->selectSingle(
                "SELECT metodo_retiro FROM ".self::prefix()."users WHERE id = :uid LIMIT 1",
                [':uid' => (int)$userId]
            );
            return $row ? $row['metodo_retiro'] : 'CUP';
        } catch (Exception $e) {
            return 'CUP';
        }
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 0 — MENSAJES INTERNOS (SISTEMA)
     * ════════════════════════════════════════════════════════════ */

    private static function getUniverseForUser($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        try {
            $row = $db->selectSingle(
                "SELECT universe FROM ".self::prefix()."users 
                 WHERE id = :uid LIMIT 1",
                [':uid' => $userId]
            );
            if ($row && isset($row['universe'])) {
                return (int)$row['universe'];
            }
        } catch (Exception $e) {}

        if (defined('UNIVERSE')) return (int)UNIVERSE;
        if (isset($GLOBALS['USER']['universe'])) return (int)$GLOBALS['USER']['universe'];
        return 1;
    }

    public static function sendSystemMessage($receiverId, $subject, $text)
    {
        $receiverId = (int)$receiverId;
        if ($receiverId <= 0) return false;

        if (function_exists('makebr')) {
            $text = makebr($text);
        }

        $db       = self::db();
        $universe = self::getUniverseForUser($receiverId);
        $now      = self::now();

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."messages 
                 (message_owner, message_sender, message_time, message_type,
                  message_from, message_subject, message_text,
                  message_unread, message_universe)
                 VALUES (:owner, :sender, :time, :type,
                         :from, :subject, :text,
                         1, :universe)",
                [
                    ':owner'    => $receiverId,
                    ':sender'   => self::MSG_SENDER_ID,
                    ':time'     => $now,
                    ':type'     => self::MSG_TYPE_SYSTEM,
                    ':from'     => self::MSG_SENDER_NAME,
                    ':subject'  => $subject,
                    ':text'     => $text,
                    ':universe' => $universe
                ]
            );

            if (defined('DEBUG') && DEBUG) {
                error_log('WalletHelper::sendSystemMessage OK | to='.$receiverId);
            }

            return true;
        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('WalletHelper::sendSystemMessage ERROR: '.$e->getMessage());
            }
        }

        try {
            if (class_exists('PlayerUtil')) {
                PlayerUtil::sendMessage(
                    $receiverId,
                    self::MSG_SENDER_ID,
                    self::MSG_SENDER_NAME,
                    self::MSG_TYPE_SYSTEM,
                    $subject,
                    $text,
                    $now
                );
                return true;
            }
        } catch (Exception $e2) {}

        return false;
    }

    public static function sendMessageToAllAdmins($subject, $text, $excludeAdminId = 0)
    {
        $db = self::db();
        $excludeAdminId = (int)$excludeAdminId;

        try {
            $sql = "SELECT id FROM ".self::prefix()."users WHERE authlevel >= 2";
            $params = [];
            if ($excludeAdminId > 0) {
                $sql .= " AND id != :ex";
                $params[':ex'] = $excludeAdminId;
            }

            $rows = $db->select($sql, $params);
            if (!$rows) return 0;

            $count = 0;
            foreach ($rows as $row) {
                if (self::sendSystemMessage((int)$row['id'], $subject, $text)) {
                    $count++;
                }
            }
            return $count;
        } catch (Exception $e) {
            return 0;
        }
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 1 — WALLET DEL USUARIO
     * ════════════════════════════════════════════════════════════ */

    public static function ensureWallet($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT user_id FROM ".self::prefix()."users_wallet 
             WHERE user_id = :uid",
            [':uid' => $userId]
        );

        if (!$row) {
            $db->insert(
                "INSERT INTO ".self::prefix()."users_wallet 
                 (user_id, fecha_registro) 
                 VALUES (:uid, :now)",
                [':uid' => $userId, ':now' => self::now()]
            );
        }
    }

    public static function getWallet($userId)
    {
        $db = self::db();
        $userId = (int)$userId;
        self::ensureWallet($userId);

        $row = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."users_wallet 
             WHERE user_id = :uid",
            [':uid' => $userId]
        );

        if (!$row) {
            $row = [
                'user_id'          => $userId,
                'cristales_kyber'  => 0,
                'total_invertido'  => 0,
                'total_retirado'   => 0,
                'fecha_registro'   => 0
            ];
        }

        return $row;
    }

    public static function addKyber($userId, $cantidad, $tipo = 'ajuste', $detalle = '')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        self::ensureWallet($userId);

        $db->update(
            "UPDATE ".self::prefix()."users_wallet 
             SET cristales_kyber = cristales_kyber + :c 
             WHERE user_id = :uid",
            [':c' => $cantidad, ':uid' => $userId]
        );

        self::logTransaction($userId, $tipo, 'KYBER', $cantidad, $detalle);
        return self::getWallet($userId);
    }

    public static function addNxt20($userId, $cantidad, $tipo = 'ajuste', $detalle = '')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        $db->update(
            "UPDATE ".self::prefix()."users 
             SET ntx20 = ntx20 + :c 
             WHERE id = :uid",
            [':c' => $cantidad, ':uid' => $userId]
        );

        if (isset($GLOBALS['USER']['id'])
            && (int)$GLOBALS['USER']['id'] === $userId) {
            $GLOBALS['USER']['ntx20'] = (int)$GLOBALS['USER']['ntx20'] + $cantidad;
        }

        self::logTransaction($userId, $tipo, 'NXT20', $cantidad, $detalle);
        return true;
    }

    public static function addNxt20Retirable($userId, $cantidad, $tipo = 'ajuste', $detalle = '')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        $db->update(
            "UPDATE ".self::prefix()."users 
             SET ntx20 = ntx20 + :c,
                 ntx20_retirable = ntx20_retirable + :c2
             WHERE id = :uid",
            [':c' => $cantidad, ':c2' => $cantidad, ':uid' => $userId]
        );

        if (isset($GLOBALS['USER']['id'])
            && (int)$GLOBALS['USER']['id'] === $userId) {
            $GLOBALS['USER']['ntx20'] = (int)$GLOBALS['USER']['ntx20'] + $cantidad;
            if (isset($GLOBALS['USER']['ntx20_retirable'])) {
                $GLOBALS['USER']['ntx20_retirable'] += $cantidad;
            }
        }

        self::logTransaction($userId, $tipo, 'NXT20', $cantidad, $detalle);
        return true;
    }

    public static function bloquearNxt20($userId, $cantidad, $detalle = '')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        $db->update(
            "UPDATE ".self::prefix()."users 
             SET ntx20 = ntx20 - :c1,
                 ntx20_retirable = ntx20_retirable - :c2,
                 ntx20_bloqueado = ntx20_bloqueado + :c3
             WHERE id = :uid",
            [':c1' => $cantidad, ':c2' => $cantidad, ':c3' => $cantidad, ':uid' => $userId]
        );

        if (isset($GLOBALS['USER']['id'])
            && (int)$GLOBALS['USER']['id'] === $userId) {
            $GLOBALS['USER']['ntx20'] = (int)$GLOBALS['USER']['ntx20'] - $cantidad;
            if (isset($GLOBALS['USER']['ntx20_retirable'])) {
                $GLOBALS['USER']['ntx20_retirable'] -= $cantidad;
            }
            if (isset($GLOBALS['USER']['ntx20_bloqueado'])) {
                $GLOBALS['USER']['ntx20_bloqueado'] += $cantidad;
            }
        }

        self::logTransaction($userId, 'retiro', 'NXT20', -$cantidad, $detalle . ' (bloqueado)');
        return true;
    }

    public static function quemarNxt20Bloqueado($userId, $cantidad, $detalle = '')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        $db->update(
            "UPDATE ".self::prefix()."users 
             SET ntx20_bloqueado = ntx20_bloqueado - :c
             WHERE id = :uid",
            [':c' => $cantidad, ':uid' => $userId]
        );

        if (isset($GLOBALS['USER']['id'])
            && (int)$GLOBALS['USER']['id'] === $userId) {
            if (isset($GLOBALS['USER']['ntx20_bloqueado'])) {
                $GLOBALS['USER']['ntx20_bloqueado'] -= $cantidad;
            }
        }

        self::logTransaction($userId, 'retiro', 'NXT20', 0, $detalle . ' (quemado)');
        return true;
    }

    public static function devolverNxt20Bloqueado($userId, $cantidad, $detalle = '')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        $db->update(
            "UPDATE ".self::prefix()."users 
             SET ntx20 = ntx20 + :c1,
                 ntx20_retirable = ntx20_retirable + :c2,
                 ntx20_bloqueado = ntx20_bloqueado - :c3
             WHERE id = :uid",
            [':c1' => $cantidad, ':c2' => $cantidad, ':c3' => $cantidad, ':uid' => $userId]
        );

        if (isset($GLOBALS['USER']['id'])
            && (int)$GLOBALS['USER']['id'] === $userId) {
            $GLOBALS['USER']['ntx20'] = (int)$GLOBALS['USER']['ntx20'] + $cantidad;
            if (isset($GLOBALS['USER']['ntx20_retirable'])) {
                $GLOBALS['USER']['ntx20_retirable'] += $cantidad;
            }
            if (isset($GLOBALS['USER']['ntx20_bloqueado'])) {
                $GLOBALS['USER']['ntx20_bloqueado'] -= $cantidad;
            }
        }

        self::logTransaction($userId, 'retiro', 'NXT20', $cantidad, $detalle . ' (devuelto)');
        return true;
    }

    public static function logTransaction($userId, $tipo, $moneda, $cantidad, $detalle = '')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."wallet_transactions 
                 (user_id, tipo, moneda, cantidad, detalle, fecha)
                 VALUES (:uid, :t, :m, :c, :d, :now)",
                [
                    ':uid' => $userId,
                    ':t'   => $tipo,
                    ':m'   => $moneda,
                    ':c'   => $cantidad,
                    ':d'   => $detalle,
                    ':now' => self::now()
                ]
            );
        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('WalletHelper::logTransaction ERROR: '.$e->getMessage());
            }
        }
    }

    public static function getTransactions($userId, $limit = 30)
    {
        $db = self::db();
        $userId = (int)$userId;
        $limit = (int)$limit;

        $rows = $db->select(
            "SELECT * FROM ".self::prefix()."wallet_transactions 
             WHERE user_id = :uid
             ORDER BY fecha DESC
             LIMIT ".$limit,
            [':uid' => $userId]
        );

        return $rows ? $rows : [];
    }

    public static function getReferrerId($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        try {
            $row = $db->selectSingle(
                "SELECT ref_id FROM ".self::prefix()."users 
                 WHERE id = :uid LIMIT 1",
                [':uid' => $userId]
            );
            if ($row && !empty($row['ref_id']) && (int)$row['ref_id'] > 0) {
                return (int)$row['ref_id'];
            }
        } catch (Exception $e) {
            return null;
        }

        return null;
    }

    public static function getNxt20($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT ntx20 FROM ".self::prefix()."users WHERE id = :uid",
            [':uid' => $userId]
        );

        return (int)($row['ntx20'] ?? 0);
    }

    public static function getNxt20Retirable($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT ntx20_retirable FROM ".self::prefix()."users WHERE id = :uid",
            [':uid' => $userId]
        );

        return (int)($row['ntx20_retirable'] ?? 0);
    }

    public static function getNxt20Bloqueado($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT ntx20_bloqueado FROM ".self::prefix()."users WHERE id = :uid",
            [':uid' => $userId]
        );

        return (int)($row['ntx20_bloqueado'] ?? 0);
    }

    public static function getNxt20EnJuego()
    {
        $db = self::db();
        $row = $db->selectSingle(
            "SELECT SUM(ntx20) AS total FROM ".self::prefix()."users"
        );
        return (int)($row['total'] ?? 0);
    }

    public static function formatNumber($n)
    {
        return number_format((int)$n, 0, ',', '.');
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 2 — BANCO (ex-AMM)
     * ════════════════════════════════════════════════════════════ */

    public static function getKyberBanco()
    {
        if (!class_exists('WalletFundHelper')) return 0;
        $fund = WalletFundHelper::getFund();
        return (int)($fund['kyber_banco'] ?? 0);
    }

    // 🆕 Obtiene el Kyber del sistema CUP
    public static function getKyberBancoCup()
    {
        if (!class_exists('WalletFundHelper')) return 0;
        $fund = WalletFundHelper::getFund();
        return (int)($fund['kyber_banco_cup'] ?? 0);
    }

    // 🆕 Obtiene el Kyber del sistema QvaPay
    public static function getKyberBancoQvapay()
    {
        if (!class_exists('WalletFundHelper')) return 0;
        $fund = WalletFundHelper::getFund();
        return (int)($fund['kyber_banco_qvapay'] ?? 0);
    }

    public static function getTotalInvertidoHistorico()
    {
        if (!class_exists('WalletFundHelper')) return 0;
        $fund = WalletFundHelper::getFund();
        return (int)($fund['total_invertido_historico'] ?? 0);
    }

    public static function getTotalRetiradoHistorico()
    {
        if (!class_exists('WalletFundHelper')) return 0;
        $fund = WalletFundHelper::getFund();
        return (int)($fund['total_retirado_historico'] ?? 0);
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 3 — CONFIG RETIRO
     * ════════════════════════════════════════════════════════════ */

    public static function getMinRetiroNxt20()
    {
        if (!class_exists('WalletFundHelper')) return 300;
        return WalletFundHelper::getMinRetiroNxt20();
    }

    public static function setMinRetiros($minNxt20)
    {
        if (!class_exists('WalletFundHelper')) return false;
        return WalletFundHelper::setMinRetiros((int)$minNxt20);
    }

    public static function retirosHabilitados()
    {
        if (!class_exists('WalletFundHelper')) return false;
        $fund = WalletFundHelper::getFund();
        return (int)($fund['retiros_habilitados'] ?? 0) === 1;
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 4 — FONDO PROYECTO
     * ════════════════════════════════════════════════════════════ */

    public static function getFondoProyecto()
    {
        if (!class_exists('WalletFundHelper')) return 0;
        $fund = WalletFundHelper::getFund();
        return (int)($fund['fondo_proyecto'] ?? 0);
    }

    public static function addToFondoProyecto($cantidad)
    {
        if (!class_exists('WalletFundHelper')) return false;
        $cantidad = (int)$cantidad;
        if ($cantidad <= 0) return true;
        WalletFundHelper::addToProyecto($cantidad);
        return true;
    }

    public static function retirarFondoProyecto($superadminId, $targetAdminId, $cantidad)
    {
        $superadminId   = (int)$superadminId;
        $targetAdminId  = (int)$targetAdminId;
        $cantidad       = (int)$cantidad;

        if ($cantidad <= 0) {
            return ['error' => 'La cantidad debe ser mayor a 0.'];
        }

        if ($targetAdminId <= 0) {
            return ['error' => 'Debes elegir un admin del cual retirar.'];
        }

        if (!class_exists('AdminBankHelper')) {
            require_once ROOT_PATH.'includes/classes/AdminBankHelper.class.php';
        }

        $db = self::db();
        $prefix = self::prefix();

        $cuenta = AdminBankHelper::getAccount($targetAdminId);
        $marcaActual = (int)round((float)($cuenta['marca_proyecto'] ?? 0));

        // ⚡ FIX: Validar SOLO contra la marca del admin, ignorando el contador global desincronizado
        if ($marcaActual < $cantidad) {
            return [
                'error' => 'Ese admin solo tiene ' . $marcaActual . 
                           ' CUP marcados como Fondo Proyecto.'
            ];
        }

        // ⚡ QUEMA DE SALDO: Descontar del admin target (saldo y marca)
        $db->update(
            "UPDATE ".$prefix."admin_bank_accounts 
             SET saldo = saldo - :c1,
                 marca_proyecto = marca_proyecto - :c2
             WHERE admin_id = :tid",
            [
                ':c1' => $cantidad, 
                ':c2' => $cantidad, 
                ':tid' => $targetAdminId
            ]
        );

        // Obtener saldo para log
        $accTarget = AdminBankHelper::getAccount($targetAdminId);
        $saldoTarget = (float)($accTarget['saldo'] ?? 0);

        // Registrar movimiento en Target (Descuento) -- ¡AQUÍ SE GUARDA QUIÉN LO HIZO!
        if (method_exists('AdminBankHelper', 'logMovimiento')) {
            AdminBankHelper::logMovimiento(
                $targetAdminId,
                'ajuste_manual',
                -$cantidad,
                $saldoTarget,
                $superadminId, // <--- ID del SuperAdmin que realizó la acción
                null,
                'Liquidación de Fondo Proyecto (Quema de saldo)'
            );
        } else {
            $db->insert(
                "INSERT INTO ".$prefix."admin_bank_movements 
                 (admin_id, tipo, monto, saldo_resultante, admin_relacionado, detalle, fecha) 
                 VALUES (:aid, 'ajuste_manual', :monto, :saldo, :rel, :detalle, :now)",
                [
                    ':aid' => $targetAdminId,
                    ':monto' => -$cantidad,
                    ':saldo' => $saldoTarget,
                    ':rel' => $superadminId,
                    ':detalle' => 'Liquidación de Fondo Proyecto (Quema de saldo)',
                    ':now' => self::now()
                ]
            );
        }

        // Obtener saldo SuperAdmin para log
        $accSuper = AdminBankHelper::getAccount($superadminId);
        $saldoSuper = (float)($accSuper['saldo'] ?? 0);

        // Registrar movimiento en SuperAdmin (Auditoría, SIN sumar saldo)
        if (method_exists('AdminBankHelper', 'logMovimiento')) {
            AdminBankHelper::logMovimiento(
                $superadminId,
                'ajuste_manual',
                0,
                $saldoSuper,
                $targetAdminId,
                null,
                'Liquidación ejecutada sobre admin #'.$targetAdminId.' (Quema de saldo)'
            );
        } else {
            $db->insert(
                "INSERT INTO ".$prefix."admin_bank_movements 
                 (admin_id, tipo, monto, saldo_resultante, admin_relacionado, detalle, fecha) 
                 VALUES (:aid, 'ajuste_manual', 0, :saldo, :rel, :detalle, :now)",
                [
                    ':aid' => $superadminId,
                    ':saldo' => $saldoSuper,
                    ':rel' => $targetAdminId,
                    ':detalle' => 'Liquidación de Fondo Proyecto ejecutada sobre admin ID '.$targetAdminId.' (Quema de saldo)',
                    ':now' => self::now()
                ]
            );
        }

        // Bajar el fondo global y el total invertido
        if (class_exists('WalletFundHelper')) {
            WalletFundHelper::removeFromProyecto($cantidad);
            WalletFundHelper::removeFromInvertidoHistorico($cantidad);
        }

        self::sendSystemMessage(
            $superadminId,
            'Fondo Proyecto liquidado',
            'Liquidaste ' . self::formatNumber($cantidad) . ' CUP del fondo del proyecto del admin ID ' . $targetAdminId . '. El saldo fue quemado.'
        );

        self::sendSystemMessage(
            $targetAdminId,
            'Ajuste en tu cuenta CUP',
            'El superadmin liquido ' . self::formatNumber($cantidad) . 
            ' CUP marcados como Fondo Proyecto de tu cuenta. Este saldo fue removido del sistema.'
        );

        return ['success' => true, 'cantidad' => $cantidad];
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 5 — SOLICITUDES DE INVERSION
     * ════════════════════════════════════════════════════════════ */

    public static function contarActivasByUser($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT COUNT(*) AS total 
             FROM ".self::prefix()."wallet_investments 
             WHERE user_id = :uid 
               AND eliminada = 0
               AND estado IN (
                   'pendiente_sin_asignar','pendiente_asignada',
                   'datos_enviados','pendiente_verificacion'
               )",
            [':uid' => $userId]
        );

        return (int)($row['total'] ?? 0);
    }

    public static function createInvestment($userId, $cantidadKyber, $referidorId = null)
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidadKyber = (int)$cantidadKyber;

        if ($cantidadKyber < self::MIN_INVERSION_KYBER) {
            return ['error' => 'El minimo es ' . self::MIN_INVERSION_KYBER . ' Kyber.'];
        }

        $activas = self::contarActivasByUser($userId);
        if ($activas >= self::MAX_SOLICITUDES_ACTIVAS) {
            return [
                'error' => 'Ya tenes ' . self::MAX_SOLICITUDES_ACTIVAS . 
                           ' solicitudes activas. Cancela una para crear otra.'
            ];
        }

        $nxt20Usuario = $cantidadKyber;
        $nxt20Referidor = $referidorId ? (int)floor($nxt20Usuario * self::PCT_REFERIDOR / 100) : 0;

        $now = self::now();

        $db->insert(
            "INSERT INTO ".self::prefix()."wallet_investments 
             (user_id, cantidad_kyber, nxt20_entregado, referidor_id,
              fondo_visible_add, fondo_proyecto_add, referidor_add,
              nxt20_referidor_add,
              estado, metodo_pago, fecha, fecha_creacion)
             VALUES (:uid, :ck, :nxt, :rid, 0, 0, 0, :nxtref,
                     'pendiente_sin_asignar', 'CUP', :now, :now)",
            [
                ':uid'    => $userId,
                ':ck'     => $cantidadKyber,
                ':nxt'    => $nxt20Usuario,
                ':rid'    => $referidorId ? (int)$referidorId : null,
                ':nxtref' => $nxt20Referidor,
                ':now'    => $now
            ]
        );

        $investmentId = (int)$db->lastInsertId();

        self::logAccion($investmentId, null, $userId, 'creada', 
            'Solicitud creada por ' . $cantidadKyber . ' Kyber');

        $userName = self::getUsername($userId);

        self::sendSystemMessage(
            $userId,
            'Solicitud de inversion creada',
            'Tu solicitud #' . $investmentId . ' por ' . self::formatNumber($cantidadKyber) . 
            ' Kyber fue creada correctamente.' . "\n\n" .
            'Un administrador la tomara pronto y te enviara los datos bancarios ' .
            'para que hagas la transferencia.' . "\n\n" .
            'Podes ver el estado en cualquier momento desde tu Wallet.'
        );

        self::sendMessageToAllAdmins(
            'Nueva solicitud de inversion #' . $investmentId,
            'El usuario ' . $userName . ' (ID ' . $userId . ') creo una nueva ' .
            'solicitud de inversion por ' . self::formatNumber($cantidadKyber) . ' Kyber.' . "\n\n" .
            'Solicitud #' . $investmentId . "\n" .
            'Estado: Pendiente sin asignar' . "\n\n" .
            'Entra al panel de administracion del banco para tomarla.'
        );

        return [
            'success'         => true,
            'investment_id'   => $investmentId,
            'nxt20_usuario'   => $nxt20Usuario,
            'nxt20_referidor' => $nxt20Referidor
        ];
    }

    public static function getInvestmentById($investmentId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;

        $row = $db->selectSingle(
            "SELECT i.*, u.username, a.username AS admin_username
             FROM ".self::prefix()."wallet_investments i
             LEFT JOIN ".self::prefix()."users u ON u.id = i.user_id
             LEFT JOIN ".self::prefix()."users a ON a.id = i.admin_id
             WHERE i.id = :id LIMIT 1",
            [':id' => $investmentId]
        );

        return $row ? $row : null;
    }

    public static function getSolicitudesSinAsignar()
    {
        $db = self::db();

        $rows = $db->select(
            "SELECT i.*, u.username 
             FROM ".self::prefix()."wallet_investments i
             LEFT JOIN ".self::prefix()."users u ON u.id = i.user_id
             WHERE i.estado = 'pendiente_sin_asignar' 
               AND i.eliminada = 0
             ORDER BY i.fecha ASC"
        );

        return $rows ? $rows : [];
    }

    public static function getSolicitudesByAdmin($adminId)
    {
        $db = self::db();
        $adminId = (int)$adminId;

        $rows = $db->select(
            "SELECT i.*, u.username 
             FROM ".self::prefix()."wallet_investments i
             LEFT JOIN ".self::prefix()."users u ON u.id = i.user_id
             WHERE i.admin_id = :aid 
               AND i.eliminada = 0
               AND i.estado IN ('pendiente_asignada', 'datos_enviados')
             ORDER BY i.fecha_asignada ASC",
            [':aid' => $adminId]
        );

        return $rows ? $rows : [];
    }

    public static function getSolicitudesVerificacionByAdmin($adminId)
    {
        $db = self::db();
        $adminId = (int)$adminId;

        $rows = $db->select(
            "SELECT i.*, u.username 
             FROM ".self::prefix()."wallet_investments i
             LEFT JOIN ".self::prefix()."users u ON u.id = i.user_id
             WHERE i.admin_id = :aid 
               AND i.eliminada = 0
               AND i.estado = 'pendiente_verificacion'
             ORDER BY i.fecha_comprobante ASC",
            [':aid' => $adminId]
        );

        return $rows ? $rows : [];
    }

    public static function getHistorial($adminId = null, $limit = 100)
    {
        $db = self::db();
        $limit = (int)$limit;
        $params = [];

        $sql = "SELECT i.*, u.username 
                FROM ".self::prefix()."wallet_investments i
                LEFT JOIN ".self::prefix()."users u ON u.id = i.user_id
                WHERE i.eliminada = 0
                  AND i.estado IN ('completada','rechazada','cancelada','expirada')";

        if ($adminId !== null) {
            $sql .= " AND i.admin_id = :aid";
            $params[':aid'] = (int)$adminId;
        }

        $sql .= " ORDER BY i.fecha_resolucion DESC LIMIT ".$limit;

        $rows = $db->select($sql, $params);
        return $rows ? $rows : [];
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 6 — ACCIONES DEL FLUJO (INVERSION)
     * ════════════════════════════════════════════════════════════ */

    public static function tomarSolicitud($investmentId, $adminId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $adminId = (int)$adminId;

        if (!class_exists('AdminBankDataHelper')) {
            require_once ROOT_PATH.'includes/classes/AdminBankDataHelper.class.php';
        }

        if (!AdminBankDataHelper::hasBankData($adminId)) {
            return ['error' => 'Primero debes cargar tu tarjeta y telefono.'];
        }

        $bank = AdminBankDataHelper::getBankData($adminId);
        if (!$bank) {
            return ['error' => 'No se pudieron leer tus datos bancarios.'];
        }

        $now = self::now();

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET admin_id = :aid,
                 estado = 'datos_enviados',
                 fecha_asignada = :now,
                 fecha_datos_enviados = :now,
                 admin_tarjeta_snapshot = :tarjeta,
                 admin_telefono_snapshot = :tel
             WHERE id = :id 
               AND estado = 'pendiente_sin_asignar'
               AND admin_id IS NULL",
            [
                ':aid'     => $adminId,
                ':now'     => $now,
                ':tarjeta' => $bank['tarjeta_magnetica'],
                ':tel'     => $bank['telefono'],
                ':id'      => $investmentId
            ]
        );

        $inv = self::getInvestmentById($investmentId);
        if (!$inv || (int)$inv['admin_id'] !== $adminId) {
            return ['error' => 'Otro admin ya tomo esta solicitud.'];
        }

        self::logAccion($investmentId, $adminId, (int)$inv['user_id'], 'tomada', 
            'Admin tomo la solicitud. Datos bancarios enviados automaticamente.');

        $titular = !empty($bank['titular']) ? $bank['titular'] : '—';
        $banco   = !empty($bank['banco'])   ? $bank['banco']   : '—';

        $textoDatos = 
            "Un administrador tomo tu solicitud #" . $investmentId . " y ya te envio los datos bancarios.\n\n" .
            "=== DATOS BANCARIOS ===\n" .
            "Tarjeta magnetica: " . $bank['tarjeta_magnetica'] . "\n" .
            "Telefono: "          . $bank['telefono']          . "\n" .
            "Titular: "           . $titular                   . "\n" .
            "Banco: "             . $banco                     . "\n" .
            "=======================\n\n" .
            "Monto a transferir: " . self::formatNumber((int)$inv['cantidad_kyber']) . " CUP\n" .
            "NXT-20 que recibiras: " . self::formatNumber((int)$inv['nxt20_entregado']) . " NXT-20\n\n" .
            "INSTRUCCIONES:\n" .
            "1. Hace la transferencia a esos datos.\n" .
            "2. Anda a tu Wallet, abri el detalle de la solicitud #" . $investmentId . ".\n" .
            "3. Subi el ID de transferencia.\n\n" .
            "Cuando el admin verifique el pago, confirmara tu inversion.";

        self::sendSystemMessage(
            (int)$inv['user_id'],
            'Datos bancarios disponibles - Solicitud #' . $investmentId,
            $textoDatos
        );

        return ['success' => true];
    }

    public static function enviarDatos($investmentId, $adminId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $adminId = (int)$adminId;

        $inv = self::getInvestmentById($investmentId);
        if (!$inv) return ['error' => 'Solicitud no encontrada.'];
        if ((int)$inv['admin_id'] !== $adminId) {
            return ['error' => 'No sos el admin asignado.'];
        }
        if ($inv['estado'] !== 'datos_enviados') {
            return ['error' => 'La solicitud no esta en el estado correcto para reenviar.'];
        }

        if (!class_exists('AdminBankDataHelper')) {
            require_once ROOT_PATH.'includes/classes/AdminBankDataHelper.class.php';
        }

        $bank = AdminBankDataHelper::getBankData($adminId);
        if (!$bank) {
            return ['error' => 'No se pudieron leer tus datos bancarios.'];
        }

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET fecha_datos_enviados = :now
             WHERE id = :id",
            [':now' => self::now(), ':id' => $investmentId]
        );

        self::logAccion($investmentId, $adminId, (int)$inv['user_id'], 'datos_reenviados', 
            'Datos bancarios REENVIADOS al usuario');

        $titular = !empty($bank['titular']) ? $bank['titular'] : '—';
        $banco   = !empty($bank['banco'])   ? $bank['banco']   : '—';

        $textoDatos = 
            "REENVIO de los datos bancarios para tu solicitud #" . $investmentId . ".\n\n" .
            "=== DATOS BANCARIOS ===\n" .
            "Tarjeta magnetica: " . $bank['tarjeta_magnetica'] . "\n" .
            "Telefono: "          . $bank['telefono']          . "\n" .
            "Titular: "           . $titular                   . "\n" .
            "Banco: "             . $banco                     . "\n" .
            "=======================\n\n" .
            "Monto a transferir: " . self::formatNumber((int)$inv['cantidad_kyber']) . " CUP\n" .
            "NXT-20 que recibiras: " . self::formatNumber((int)$inv['nxt20_entregado']) . " NXT-20\n\n" .
            "Cuando termines, subi el ID de transferencia desde el detalle de la solicitud.";

        self::sendSystemMessage(
            (int)$inv['user_id'],
            'RE-envio de datos bancarios - Solicitud #' . $investmentId,
            $textoDatos
        );

        return ['success' => true];
    }

    public static function subirComprobante($investmentId, $userId, $transferenciaId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $userId = (int)$userId;
        $transferenciaId = trim((string)$transferenciaId);

        if (strlen($transferenciaId) < 3) {
            return ['error' => 'El ID de transferencia es demasiado corto.'];
        }
        if (strlen($transferenciaId) > 100) {
            return ['error' => 'El ID de transferencia es demasiado largo.'];
        }

        $inv = self::getInvestmentById($investmentId);
        if (!$inv) return ['error' => 'Solicitud no encontrada.'];
        if ((int)$inv['user_id'] !== $userId) {
            return ['error' => 'Esta solicitud no te pertenece.'];
        }
        if ($inv['estado'] !== 'datos_enviados') {
            return ['error' => 'La solicitud no esta esperando comprobante.'];
        }

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET estado = 'pendiente_verificacion',
                 referencia = :ref,
                 fecha_comprobante = :now
             WHERE id = :id",
            [
                ':ref' => $transferenciaId,
                ':now' => self::now(),
                ':id'  => $investmentId
            ]
        );

        self::logAccion($investmentId, null, $userId, 'comprobante_enviado', 
            'ID transferencia: ' . $transferenciaId);

        if (!empty($inv['admin_id'])) {
            self::sendSystemMessage(
                (int)$inv['admin_id'],
                'Comprobante recibido - Solicitud #' . $investmentId,
                'El usuario ' . ($inv['username'] ?? '#' . $userId) . 
                ' subio el comprobante de la solicitud #' . $investmentId . '.' . "\n\n" .
                'Monto invertido: ' . self::formatNumber((int)$inv['cantidad_kyber']) . 
                ' Kyber' . "\n" .
                'NXT-20 a entregar: ' . self::formatNumber((int)$inv['nxt20_entregado']) . 
                ' NXT-20' . "\n" .
                'ID de transferencia: ' . $transferenciaId . "\n\n" .
                'Entra al panel de verificacion para confirmar o rechazar.'
            );
        }

        self::sendSystemMessage(
            $userId,
            'Comprobante enviado',
            'Tu comprobante para la solicitud #' . $investmentId . ' fue registrado.' . "\n\n" .
            'Un administrador lo verificara y confirmara la inversion.'
        );

        return ['success' => true];
    }

    public static function liberarLock($investmentId, $adminId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $adminId = (int)$adminId;

        $inv = self::getInvestmentById($investmentId);
        if (!$inv) return ['error' => 'Solicitud no encontrada.'];
        if ((int)$inv['admin_id'] !== $adminId) {
            return ['error' => 'No sos el admin asignado.'];
        }

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET admin_id = NULL,
                 estado = 'pendiente_sin_asignar',
                 fecha_asignada = NULL,
                 fecha_datos_enviados = NULL,
                 admin_tarjeta_snapshot = NULL,
                 admin_telefono_snapshot = NULL
             WHERE id = :id",
            [':id' => $investmentId]
        );

        self::logAccion($investmentId, $adminId, (int)$inv['user_id'], 'lock_liberado', 
            'Admin libero la solicitud');

        return ['success' => true];
    }

    public static function forzarLiberacion($investmentId, $superAdminId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $superAdminId = (int)$superAdminId;

        $inv = self::getInvestmentById($investmentId);
        if (!$inv) return ['error' => 'Solicitud no encontrada.'];

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET admin_id = NULL,
                 estado = 'pendiente_sin_asignar',
                 fecha_asignada = NULL,
                 fecha_datos_enviados = NULL,
                 admin_tarjeta_snapshot = NULL,
                 admin_telefono_snapshot = NULL
             WHERE id = :id",
            [':id' => $investmentId]
        );

        self::logAccion($investmentId, $superAdminId, (int)$inv['user_id'], 'lock_forzado', 
            'Superadmin forzo la liberacion');

        return ['success' => true];
    }

    public static function cancelarSolicitud($investmentId, $userId, $motivo = '')
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $userId = (int)$userId;

        $inv = self::getInvestmentById($investmentId);
        if (!$inv) return ['error' => 'Solicitud no encontrada.'];
        if ((int)$inv['user_id'] !== $userId) {
            return ['error' => 'Esta solicitud no te pertenece.'];
        }

        $estadosPermitidos = ['pendiente_sin_asignar', 'pendiente_asignada', 'datos_enviados'];
        if (!in_array($inv['estado'], $estadosPermitidos)) {
            return ['error' => 'No podes cancelar en este estado.'];
        }

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET estado = 'cancelada',
                 motivo = :motivo,
                 fecha_resolucion = :now
             WHERE id = :id",
            [
                ':motivo' => $motivo !== '' ? $motivo : 'Cancelada por el usuario',
                ':now'    => self::now(),
                ':id'     => $investmentId
            ]
        );

        self::logAccion($investmentId, null, $userId, 'cancelada_usuario', 
            $motivo !== '' ? $motivo : 'Sin motivo');

        self::crearTransfersLog($inv, 'cancelada', 
            $motivo !== '' ? $motivo : 'Cancelada por el usuario');

        if (!empty($inv['admin_id'])) {
            self::sendSystemMessage(
                (int)$inv['admin_id'],
                'Solicitud cancelada por el usuario',
                'El usuario cancelo la solicitud #' . $investmentId . ' que tenias asignada.'
            );
        }

        return ['success' => true];
    }

    public static function cancelarSolicitudAdmin($investmentId, $adminId, $motivo = '')
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $adminId = (int)$adminId;

        $inv = self::getInvestmentById($investmentId);
        if (!$inv) return ['error' => 'Solicitud no encontrada.'];
        if ((int)$inv['admin_id'] !== $adminId) {
            return ['error' => 'No sos el admin asignado.'];
        }

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET estado = 'cancelada',
                 motivo = :motivo,
                 fecha_resolucion = :now
             WHERE id = :id",
            [
                ':motivo' => $motivo !== '' ? $motivo : 'Cancelada por el admin',
                ':now'    => self::now(),
                ':id'     => $investmentId
            ]
        );

        self::logAccion($investmentId, $adminId, (int)$inv['user_id'], 'cancelada_admin', 
            $motivo !== '' ? $motivo : 'Sin motivo');

        self::crearTransfersLog($inv, 'cancelada', 
            $motivo !== '' ? $motivo : 'Cancelada por el admin');

        self::sendSystemMessage(
            (int)$inv['user_id'],
            'Solicitud cancelada',
            'Tu solicitud #' . $investmentId . ' fue cancelada por el admin.' . "\n\n" .
            'Motivo: ' . ($motivo !== '' ? $motivo : 'Sin motivo')
        );

        return ['success' => true];
    }

    public static function eliminarSolicitud($investmentId, $adminId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $adminId = (int)$adminId;

        $inv = self::getInvestmentById($investmentId);
        if (!$inv) return ['error' => 'Solicitud no encontrada.'];

        $estadosFinales = ['rechazada', 'cancelada', 'expirada'];
        if (!in_array($inv['estado'], $estadosFinales)) {
            return ['error' => 'Solo se pueden eliminar solicitudes resueltas.'];
        }

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET eliminada = 1,
                 eliminada_por = :aid,
                 fecha_eliminacion = :now
             WHERE id = :id",
            [
                ':aid' => $adminId,
                ':now' => self::now(),
                ':id'  => $investmentId
            ]
        );

        self::logAccion($investmentId, $adminId, (int)$inv['user_id'], 'eliminada', 
            'Solicitud eliminada del sistema');

        return ['success' => true];
    }

    public static function restaurarSolicitud($investmentId, $superAdminId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $superAdminId = (int)$superAdminId;

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET eliminada = 0,
                 eliminada_por = NULL,
                 fecha_eliminacion = NULL
             WHERE id = :id",
            [':id' => $investmentId]
        );

        self::logAccion($investmentId, $superAdminId, null, 'restaurada', 
            'Solicitud restaurada por superadmin');

        return ['success' => true];
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 7 — CONFIRMACION Y RECHAZO (INVERSION)
     * ════════════════════════════════════════════════════════════ */

    public static function confirmInvestment($investmentId, $adminId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $adminId = (int)$adminId;

        $inv = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."wallet_investments 
             WHERE id = :id 
               AND estado = 'pendiente_verificacion'
               AND admin_id = :aid
               AND eliminada = 0
             LIMIT 1",
            [':id' => $investmentId, ':aid' => $adminId]
        );

        if (!$inv) {
            return ['error' => 'Solicitud no encontrada, ya procesada, o no sos el admin asignado.'];
        }

        $userId        = (int)$inv['user_id'];
        $cantidadKyber = (int)$inv['cantidad_kyber'];
        $nxt20Entrega  = (int)$inv['nxt20_entregado'];

        // 🆕 CORRECCIÓN: Solo el 70% entra al banco como respaldo real
        $montoAlBanco = (int)floor($cantidadKyber * 0.70);
        
        $prefix = self::prefix();
        $db->update(
            "UPDATE ".$prefix."wallet_fund 
             SET kyber_banco = kyber_banco + :c1,
                 kyber_banco_cup = kyber_banco_cup + :c2,
                 total_invertido_historico = total_invertido_historico + :c3
             WHERE id = 1",
            [':c1' => $montoAlBanco, ':c2' => $montoAlBanco, ':c3' => $cantidadKyber]
        );

        $db->update(
            "UPDATE ".self::prefix()."users_wallet 
             SET total_invertido = total_invertido + :c
             WHERE user_id = :uid",
            [':c' => $cantidadKyber, ':uid' => $userId]
        );

        self::addNxt20Retirable($userId, $nxt20Entrega, 'inversion', 
            'Inversion #' . $investmentId);

        $pctProyecto = self::PCT_PROYECTO;
        if (!empty($inv['referidor_id']) && (int)$inv['nxt20_referidor_add'] > 0) {
            $referidorId = (int)$inv['referidor_id'];
            $nxt20Ref    = (int)$inv['nxt20_referidor_add'];

            self::addNxt20Retirable($referidorId, $nxt20Ref, 'referido_inv', 
                'Referido #' . $userId . ' invirtio');

            self::sendSystemMessage(
                $referidorId,
                'Tu referido invirtio',
                'Tu referido ' . ($inv['username'] ?? '#' . $userId) . 
                ' hizo una inversion. Recibiste ' . self::formatNumber($nxt20Ref) . 
                ' NXT-20.'
            );
        } else {
            $pctProyecto = self::PCT_PROYECTO_SIN_REF;
        }

        $marcaProyecto = (int)floor($cantidadKyber * $pctProyecto / 100);

        if (class_exists('AdminBankHelper')) {
            if (method_exists('AdminBankHelper', 'sumarInversion')) {
                AdminBankHelper::sumarInversion(
                    $adminId,
                    $cantidadKyber,
                    $marcaProyecto,
                    $investmentId
                );
            }
        }

        $now = self::now();
        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET estado = 'completada',
                 fecha_procesado = :now,
                 fecha_resolucion = :now
             WHERE id = :id",
            [':now' => $now, ':id' => $investmentId]
        );

        self::logAccion($investmentId, $adminId, $userId, 'confirmada', 
            'Inversion confirmada. NXT-20 retirables entregados.');

        $inv['admin_id'] = $adminId;
        self::crearTransfersLog($inv, 'confirmada', null);

        self::guardarSnapshotBanco();

        self::sendSystemMessage(
            $userId,
            'Inversion confirmada',
            'Tu inversion #' . $investmentId . ' fue confirmada.' . "\n\n" .
            'Recibiste ' . self::formatNumber($nxt20Entrega) . ' NXT-20 retirables.'
        );

        return ['success' => true];
    }

    public static function rejectInvestment($investmentId, $adminId, $motivo = '')
    {
        $db = self::db();
        $investmentId = (int)$investmentId;
        $adminId = (int)$adminId;

        $inv = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."wallet_investments 
             WHERE id = :id 
               AND estado = 'pendiente_verificacion'
               AND admin_id = :aid
               AND eliminada = 0
             LIMIT 1",
            [':id' => $investmentId, ':aid' => $adminId]
        );

        if (!$inv) {
            return ['error' => 'Solicitud no encontrada o no podes rechazarla.'];
        }

        $now = self::now();

        $db->update(
            "UPDATE ".self::prefix()."wallet_investments 
             SET estado = 'rechazada',
                 motivo = :motivo,
                 fecha_procesado = :now,
                 fecha_resolucion = :now
             WHERE id = :id",
            [
                ':motivo' => $motivo !== '' ? $motivo : 'Rechazada por el admin',
                ':now'    => $now,
                ':id'     => $investmentId
            ]
        );

        self::logAccion($investmentId, $adminId, (int)$inv['user_id'], 'rechazada', 
            $motivo !== '' ? $motivo : 'Sin motivo');

        $inv['admin_id'] = $adminId;
        self::crearTransfersLog($inv, 'rechazada', 
            $motivo !== '' ? $motivo : 'Rechazada por el admin');

        self::sendSystemMessage(
            (int)$inv['user_id'],
            'Inversion rechazada',
            'Tu inversion #' . $investmentId . ' fue rechazada.' . "\n\n" .
            'Motivo: ' . ($motivo !== '' ? $motivo : 'Sin motivo')
        );

        return ['success' => true];
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 8 — LOG Y AUDITORIA
     * ════════════════════════════════════════════════════════════ */

    public static function logAccion($investmentId, $adminId, $userId, $accion, $detalle = '')
    {
        $db = self::db();

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."wallet_investment_log 
                 (investment_id, admin_id, user_id, accion, detalle, ip, fecha)
                 VALUES (:iid, :aid, :uid, :acc, :det, :ip, :now)",
                [
                    ':iid' => (int)$investmentId,
                    ':aid' => $adminId ? (int)$adminId : null,
                    ':uid' => $userId ? (int)$userId : null,
                    ':acc' => $accion,
                    ':det' => $detalle,
                    ':ip'  => $_SERVER['REMOTE_ADDR'] ?? null,
                    ':now' => self::now()
                ]
            );
        } catch (Exception $e) {}

        return true;
    }

    public static function crearTransfersLog($inv, $resultado, $motivo = null)
    {
        $db = self::db();

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."wallet_transfers_log 
                 (investment_id, user_id, admin_id, referidor_id,
                  monto_kyber, nxt20_entregados,
                  fondo_visible, fondo_proyecto, pago_referidor_nxt20,
                  transferencia_id, admin_tarjeta, admin_telefono,
                  fecha_solicitud, fecha_confirmacion, resultado, motivo)
                 VALUES (:iid, :uid, :aid, :rid,
                         :mk, :nxt,
                         0, 0, :pr,
                         :tid, :tar, :tel,
                         :fs, :fc, :res, :mot)",
                [
                    ':iid' => (int)$inv['id'],
                    ':uid' => (int)$inv['user_id'],
                    ':aid' => (int)$inv['admin_id'],
                    ':rid' => !empty($inv['referidor_id']) ? (int)$inv['referidor_id'] : null,
                    ':mk'  => (int)$inv['cantidad_kyber'],
                    ':nxt' => (int)$inv['nxt20_entregado'],
                    ':pr'  => (int)($inv['nxt20_referidor_add'] ?? 0),
                    ':tid' => $inv['referencia'] ?? null,
                    ':tar' => $inv['admin_tarjeta_snapshot'] ?? null,
                    ':tel' => $inv['admin_telefono_snapshot'] ?? null,
                    ':fs'  => (int)$inv['fecha'],
                    ':fc'  => self::now(),
                    ':res' => $resultado,
                    ':mot' => $motivo
                ]
            );
        } catch (Exception $e) {}

        return true;
    }

    public static function getLogByInvestment($investmentId)
    {
        $db = self::db();
        $investmentId = (int)$investmentId;

        $rows = $db->select(
            "SELECT l.*, u.username AS admin_name, us.username AS user_name
             FROM ".self::prefix()."wallet_investment_log l
             LEFT JOIN ".self::prefix()."users u ON u.id = l.admin_id
             LEFT JOIN ".self::prefix()."users us ON us.id = l.user_id
             WHERE l.investment_id = :iid
             ORDER BY l.fecha ASC",
            [':iid' => $investmentId]
        );

        return $rows ? $rows : [];
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 9 — RETIROS (v6.0 NUEVO FLUJO)
     * ════════════════════════════════════════════════════════════ */

    public static function contarRetirosPendientesByUser($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT COUNT(*) AS total 
             FROM ".self::prefix()."wallet_withdrawals 
             WHERE user_id = :uid 
               AND estado IN ('pendiente', 'aceptada')",
            [':uid' => $userId]
        );

        return (int)($row['total'] ?? 0);
    }

    public static function tieneDatosBancarios($userId)
    {
        $userId = (int)$userId;

        if (!class_exists('UserBankDataHelper')) {
            $file = ROOT_PATH.'includes/classes/UserBankDataHelper.class.php';
            if (file_exists($file)) {
                require_once $file;
            } else {
                return false;
            }
        }

        if (method_exists('UserBankDataHelper', 'tieneDatos')) {
            return (bool)UserBankDataHelper::tieneDatos($userId);
        }

        return false;
    }

    /**
     * SOLICITAR RETIRO (v7.4):
     *   - Valida VIP
     *   - Valida retiros habilitados
     *   - Valida minimo
     *   - Valida saldo retirable
     *   - Valida maximo 1 pendiente
     *   - ⚡ Valida que el banco específico (CUP o QvaPay) tenga suficiente Kyber
     *   - BLOQUEA NXT-20 inmediatamente
     *   - Crea withdrawal con estado 'pendiente' y metodo_pago
     */
    public static function solicitarRetiro($userId, $nxt20)
    {
        $db = self::db();
        $userId = (int)$userId;
        $nxt20  = (int)$nxt20;

        if ($nxt20 <= 0) {
            return ['error' => 'La cantidad de NXT-20 debe ser mayor a 0.'];
        }

        // VIP
        if (class_exists('VIPHelper')) {
            if (!VIPHelper::isVIP($userId)) {
                return ['error' => 'Necesitas ser VIP para retirar. Compra un pase VIP.'];
            }
        }

        // Retiros habilitados
        if (!self::retirosHabilitados()) {
            return ['error' => 'Los retiros estan cerrados temporalmente.'];
        }

        // Minimo
        $minNxt20 = self::getMinRetiroNxt20();
        if ($nxt20 < $minNxt20) {
            return [
                'error' => 'Minimo de retiro: ' . $minNxt20 . ' NXT-20. ' .
                           'Estas intentando retirar ' . $nxt20 . '.'
            ];
        }

        // Max 1 pendiente
        $pendientes = self::contarRetirosPendientesByUser($userId);
        if ($pendientes >= self::MAX_RETIROS_PENDIENTES) {
            return ['error' => 'Ya tenes un retiro pendiente. Espera a que se procese.'];
        }

        // Saldo retirable del user
        $retirable = self::getNxt20Retirable($userId);
        if ($retirable < $nxt20) {
            return [
                'error' => 'No tenes suficiente NXT-20 retirable. Tenes ' . 
                           self::formatNumber($retirable) . '.'
            ];
        }

        $metodoRetiro = self::getMetodoRetiro($userId);

        // Calculo 1:1 con 10% comision
        $bruto           = $nxt20;
        $comision        = (int)floor($bruto * self::PCT_RET_COMISION / 100);
        $comisionProy    = (int)floor($bruto * self::PCT_RET_PROYECTO / 100);
        $comisionRef     = $comision - $comisionProy;
        $neto            = $bruto - $comision;
        $totalNecesario  = $neto + $comisionProy;

        // ═══════════════════════════════════════════════════════════
        //  ⚡ VALIDAR QUE EL BANCO ESPECÍFICO TENGA KYBER (97%)
        // ═══════════════════════════════════════════════════════════
        if ($metodoRetiro === 'CUP') {
            $kyberBanco = self::getKyberBancoCup();
            $nombreBanco = 'CUP';
        } else {
            $kyberBanco = self::getKyberBancoQvapay();
            $nombreBanco = 'QvaPay';
        }

        // 🆕 CORRECCIÓN: Validar el Neto + lo que se lleva el Proyecto (97% del bruto)
        if ($kyberBanco < $totalNecesario) {
            return [
                'error' => 'El banco de ' . $nombreBanco . ' no tiene suficiente liquidez para cubrir este retiro. ' .
                           'Disponible: ' . self::formatNumber($kyberBanco) . ' CUP. ' .
                           'Necesitas: ' . self::formatNumber($totalNecesario) . ' CUP. ' .
                           'Los retiros se podran hacer cuando el banco tenga suficiente liquidez.'
            ];
        }

        $referidorId = self::getReferrerId($userId);

        if (!$referidorId) {
            $comisionProy += $comisionRef;
            $comisionRef  = 0;
        }

        $now  = self::now();
        $exp  = $now + (self::TIMEOUT_HORAS_RET * 3600);

        // INSERT
        $db->insert(
            "INSERT INTO ".self::prefix()."wallet_withdrawals 
             (user_id, nxt20_retirados, bruto, neto, 
              comision_proyecto, comision_referidor, tipo_cambio,
              referidor_id, estado, metodo_pago, fecha, fecha_expiracion)
             VALUES (:uid, :nx, :bk, :nu, :cp, :cr, 1.0000,
                     :rid, 'pendiente', :mp, :now, :exp)",
            [
                ':uid' => $userId,
                ':nx'  => $nxt20,
                ':bk'  => $bruto,
                ':nu'  => $neto,
                ':cp'  => $comisionProy,
                ':cr'  => $comisionRef,
                ':rid' => $referidorId ? (int)$referidorId : null,
                ':mp'  => $metodoRetiro,
                ':now' => $now,
                ':exp' => $exp
            ]
        );

        $withdrawalId = (int)$db->lastInsertId();

        // BLOQUEAR NXT-20 inmediatamente
        self::bloquearNxt20($userId, $nxt20, 'Retiro #' . $withdrawalId);

        // Mensajes
        self::sendSystemMessage(
            $userId,
            'Solicitud de retiro creada',
            'Tu retiro #' . $withdrawalId . ' por ' . self::formatNumber($nxt20) . 
            ' NXT-20 fue creado.' . "\n\n" .
            'Los NXT-20 quedaron BLOQUEADOS hasta que el admin procese el retiro.' . "\n" .
            'Recibiras ' . self::formatNumber($neto) . ' CUP reales (menos 10% de comision).'
        );

        self::sendMessageToAllAdmins(
            'Nuevo retiro pendiente #' . $withdrawalId,
            'El usuario ' . self::getUsername($userId) . ' (ID ' . $userId . ') ' .
            'solicito un retiro de ' . self::formatNumber($nxt20) . ' NXT-20.' . "\n\n" .
            'Neto a transferir: ' . self::formatNumber($neto) . ' CUP' . "\n" .
            'Método de pago: ' . $metodoRetiro . "\n\n" .
            'Entra al panel de retiros para aceptarlo.'
        );

        return [
            'success'       => true,
            'withdrawal_id' => $withdrawalId,
            'bruto'         => $bruto,
            'neto'          => $neto,
            'comision'      => $comision,
            'comision_proyecto'  => $comisionProy,
            'comision_referidor' => $comisionRef
        ];
    }

    public static function aceptarRetiro($withdrawalId, $adminId)
    {
        $db = self::db();
        $withdrawalId = (int)$withdrawalId;
        $adminId      = (int)$adminId;

        $wd = $db->selectSingle(
            "SELECT w.*, u.username 
             FROM ".self::prefix()."wallet_withdrawals w
             LEFT JOIN ".self::prefix()."users u ON u.id = w.user_id
             WHERE w.id = :id AND w.estado = 'pendiente' LIMIT 1",
            [':id' => $withdrawalId]
        );

        if (!$wd) return ['error' => 'Retiro no encontrado o ya procesado.'];

        $now = self::now();

        $db->update(
            "UPDATE ".self::prefix()."wallet_withdrawals 
             SET estado = 'aceptada',
                 admin_id = :aid,
                 fecha_aceptacion = :now
             WHERE id = :id AND estado = 'pendiente'",
            [':aid' => $adminId, ':now' => $now, ':id' => $withdrawalId]
        );

        $datosUser = '';
        if (class_exists('UserBankDataHelper')) {
            if (method_exists('UserBankDataHelper', 'getDatos')) {
                $bankUser = UserBankDataHelper::getDatos((int)$wd['user_id']);
                if ($bankUser) {
                    $datosUser = "\n\n--- DATOS BANCARIOS DEL USER ---\n" .
                                 'Tarjeta: ' . ($bankUser['tarjeta_magnetica'] ?? '-') . "\n" .
                                 'Telefono: ' . ($bankUser['telefono'] ?? '-') . "\n" .
                                 'Titular: ' . ($bankUser['titular'] ?? '-') . "\n" .
                                 'Banco: ' . ($bankUser['banco'] ?? '-');
                }
            }
        }

        self::sendSystemMessage(
            (int)$wd['user_id'],
            'Retiro aceptado',
            'Tu solicitud de retiro #' . $withdrawalId . ' fue ACEPTADA.' . "\n\n" .
            'El admin procesara la transferencia a tu tarjeta.' . "\n" .
            'Recibiras ' . self::formatNumber((int)$wd['neto']) . ' CUP.'
        );

        self::sendSystemMessage(
            $adminId,
            'Retiro aceptado - #' . $withdrawalId,
            'Aceptaste el retiro #' . $withdrawalId . ' del usuario ' . 
            ($wd['username'] ?? '#' . $wd['user_id']) . '.' . "\n\n" .
            'Monto NETO a transferir: ' . self::formatNumber((int)$wd['neto']) . ' CUP' . "\n" .
            'NXT-20 a quemar: ' . self::formatNumber((int)$wd['nxt20_retirados']) . 
            $datosUser . "\n\n" .
            'Cuando termines la transferencia, confirma el retiro desde el panel.'
        );

        return ['success' => true];
    }

    public static function confirmarRetiro($withdrawalId, $adminId)
    {
        $db = self::db();
        $withdrawalId = (int)$withdrawalId;
        $adminId      = (int)$adminId;

        if ($withdrawalId <= 0 || $adminId <= 0) {
            return ['error' => 'Datos invalidos.'];
        }

        // ⚡ FIX 1: forzar carga de AdminBankHelper
        if (!class_exists('AdminBankHelper')) {
            $f = ROOT_PATH.'includes/classes/AdminBankHelper.class.php';
            if (file_exists($f)) {
                require_once $f;
            }
        }
        if (!class_exists('AdminBankHelper')) {
            return ['error' => 'No se pudo cargar AdminBankHelper. Avisa al superadmin.'];
        }

        $wd = $db->selectSingle(
            "SELECT w.*, u.username 
             FROM ".self::prefix()."wallet_withdrawals w
             LEFT JOIN ".self::prefix()."users u ON u.id = w.user_id
             WHERE w.id = :id AND w.estado = 'aceptada' LIMIT 1",
            [':id' => $withdrawalId]
        );

        if (!$wd) {
            return ['error' => 'Retiro no encontrado o no esta en estado aceptada.'];
        }

        $userId       = (int)$wd['user_id'];
        $nxt20Retirar = (int)$wd['nxt20_retirados'];
        $bruto        = (int)$wd['bruto'];
        $neto         = (int)$wd['neto'];
        $comProy      = (int)$wd['comision_proyecto'];
        $comRef       = (int)$wd['comision_referidor'];
        $metodoPago   = $wd['metodo_pago'] ?? 'CUP';

        // ⚡ FIX 2: usar el admin que ACEPTO (no el que confirma)
        $adminPagoId = !empty($wd['admin_id']) ? (int)$wd['admin_id'] : $adminId;

        // ─── VALIDACIONES PREVIAS ───

        if ($metodoPago === 'CUP') {
            $kyberBanco = self::getKyberBancoCup();
            $nombreBanco = 'CUP';
        } else {
            $kyberBanco = self::getKyberBancoQvapay();
            $nombreBanco = 'QvaPay';
        }

        // 🆕 CORRECCIÓN: Validar el Neto + lo que se lleva el Proyecto (97% del bruto)
        $totalNecesario = $neto + $comProy;

        if ($kyberBanco < $totalNecesario) {
            return ['error' => 'El banco de ' . $nombreBanco . ' no tiene suficiente liquidez en este momento. Disponible: ' . self::formatNumber($kyberBanco) . ' CUP. Necesitas: ' . self::formatNumber($totalNecesario) . ' CUP. Espera a que entren nuevas inversiones.'];
        }

        // ⚡ FIX 3: validar CUP del admin que acepto ANTES de nada
        $accAdmin = AdminBankHelper::getAccount($adminPagoId);
        $saldoCup = (float)($accAdmin['saldo'] ?? 0);
        if ($saldoCup < $neto) {
            return [
                'error' => 'El admin que acepto el retiro (#'.$adminPagoId.') no tiene '.
                           'suficiente CUP. Saldo: '.number_format($saldoCup, 2).
                           ' CUP / Necesita: '.number_format($neto, 2).' CUP.'
            ];
        }

        // ═══════════════════════════════════════════════════════════════
        //  EJECUTAR
        // ═══════════════════════════════════════════════════════════════

        // 1. Quemar NXT-20 bloqueados del user
        self::quemarNxt20Bloqueado($userId, $nxt20Retirar, 'Retiro #' . $withdrawalId);

        // 2. Bajar Kyber del banco (Neto + Proyecto = 97%) - ⚡ RESTAMOS DEL CAJÓN ESPECÍFICO Y DEL GLOBAL
        $prefix = self::prefix();
        if ($metodoPago === 'CUP') {
            $db->update(
                "UPDATE ".$prefix."wallet_fund 
                 SET kyber_banco = GREATEST(0, kyber_banco - :c1),
                     kyber_banco_cup = GREATEST(0, kyber_banco_cup - :c2),
                     total_retirado_historico = total_retirado_historico + :c3
                 WHERE id = 1",
                [':c1' => $totalNecesario, ':c2' => $totalNecesario, ':c3' => $bruto]
            );
        } else {
            $db->update(
                "UPDATE ".$prefix."wallet_fund 
                 SET kyber_banco = GREATEST(0, kyber_banco - :c1),
                     kyber_banco_qvapay = GREATEST(0, kyber_banco_qvapay - :c2),
                     total_retirado_historico = total_retirado_historico + :c3
                 WHERE id = 1",
                [':c1' => $totalNecesario, ':c2' => $totalNecesario, ':c3' => $bruto]
            );
        }

        // 4. Sumar al fondo proyecto (7% o 7%+3%)
        if ($comProy > 0) {
            self::addToFondoProyecto($comProy);
        }

        // 5. Referidor (3% minted) si hay
        if (!empty($wd['referidor_id']) && $comRef > 0) {
            $referidorId = (int)$wd['referidor_id'];

            self::addNxt20Retirable($referidorId, $comRef, 'referido_ret', 
                'Referido #' . $userId . ' retiro');

            self::sendSystemMessage(
                $referidorId,
                'Tu referido retiro',
                'Tu referido ' . ($wd['username'] ?? '#' . $userId) . 
                ' hizo un retiro. Recibiste ' . self::formatNumber($comRef) . ' NXT-20.'
            );
        } else if ($comRef > 0) {
            self::addToFondoProyecto($comRef);
        }

        // 6. Marcar total retirado del user
        $db->update(
            "UPDATE ".self::prefix()."users_wallet 
             SET total_retirado = total_retirado + :bk 
             WHERE user_id = :uid",
            [':bk' => $bruto, ':uid' => $userId]
        );

        // 7a. DESCONTAR NETO DEL CUP
        $resDesc = AdminBankHelper::descontarRetiro($adminPagoId, $neto, $withdrawalId);
        if (isset($resDesc['error'])) {
            self::devolverNxt20Bloqueado($userId, $nxt20Retirar, 
                'Rollback retiro #'.$withdrawalId.' (fallo CUP)');
            return ['error' => 'No se pudo descontar el CUP: ' . $resDesc['error']];
        }

        // 7b. MARCAR PROYECTO EN EL CUP DEL ADMIN
        if ($comProy > 0) {
            $resProy = AdminBankHelper::sumarAlProyecto($adminPagoId, $comProy, $withdrawalId);
            if (isset($resProy['error'])) {
                if (defined('DEBUG') && DEBUG) {
                    error_log('confirmarRetiro: sumarAlProyecto fallo: '.$resProy['error']);
                }
            }
        }

        // 8. Estado completada
        $now = self::now();
        $db->update(
            "UPDATE ".self::prefix()."wallet_withdrawals 
             SET estado = 'completada',
                 fecha_procesado = :now
             WHERE id = :id AND estado = 'aceptada'",
            [':now' => $now, ':id' => $withdrawalId]
        );

        // 9. Snapshot
        self::guardarSnapshotBanco();

        // 10. Aviso al user
        self::sendSystemMessage(
            $userId,
            'Retiro completado',
            'Tu retiro #' . $withdrawalId . ' fue COMPLETADO.' . "\n\n" .
            'Transferencia realizada con exito.' . "\n" .
            'Recibiste ' . self::formatNumber($neto) . ' CUP en tu tarjeta.' . "\n" .
            'Los NXT-20 fueron quemados.'
        );

        return ['success' => true];
    }

    public static function cancelarRetiro($withdrawalId, $userId, $motivo = '')
    {
        $db = self::db();
        $withdrawalId = (int)$withdrawalId;
        $userId       = (int)$userId;

        $wd = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."wallet_withdrawals 
             WHERE id = :id AND user_id = :uid AND estado = 'pendiente' LIMIT 1",
            [':id' => $withdrawalId, ':uid' => $userId]
        );

        if (!$wd) return ['error' => 'Retiro no encontrado o ya no se puede cancelar.'];

        $nxt20 = (int)$wd['nxt20_retirados'];

        self::devolverNxt20Bloqueado($userId, $nxt20, 'Retiro #' . $withdrawalId . ' cancelado por user');

        $db->update(
            "UPDATE ".self::prefix()."wallet_withdrawals 
             SET estado = 'cancelada_user',
                 motivo = :motivo,
                 fecha_procesado = :now
             WHERE id = :id AND estado = 'pendiente'",
            [
                ':motivo' => $motivo !== '' ? $motivo : 'Cancelado por el usuario',
                ':now'    => self::now(),
                ':id'     => $withdrawalId
            ]
        );

        self::sendSystemMessage(
            $userId,
            'Retiro cancelado',
            'Tu retiro #' . $withdrawalId . ' fue cancelado.' . "\n\n" .
            'Se te devolvieron ' . self::formatNumber($nxt20) . ' NXT-20.'
        );

        return ['success' => true];
    }

    public static function cancelarRetiroAdmin($withdrawalId, $adminId, $motivo = '')
    {
        $db = self::db();
        $withdrawalId = (int)$withdrawalId;
        $adminId      = (int)$adminId;

        $wd = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."wallet_withdrawals 
             WHERE id = :id AND estado IN ('pendiente', 'aceptada') LIMIT 1",
            [':id' => $withdrawalId]
        );

        if (!$wd) return ['error' => 'Retiro no encontrado o ya procesado.'];

        $nxt20 = (int)$wd['nxt20_retirados'];

        self::devolverNxt20Bloqueado((int)$wd['user_id'], $nxt20, 
            'Retiro #' . $withdrawalId . ' cancelado por admin');

        $db->update(
            "UPDATE ".self::prefix()."wallet_withdrawals 
             SET estado = 'cancelada_admin',
                 admin_id = :aid,
                 motivo = :motivo,
                 fecha_procesado = :now
             WHERE id = :id",
            [
                ':aid'    => $adminId,
                ':motivo' => $motivo !== '' ? $motivo : 'Cancelado por el admin',
                ':now'    => self::now(),
                ':id'     => $withdrawalId
            ]
        );

        self::sendSystemMessage(
            (int)$wd['user_id'],
            'Retiro cancelado',
            'Tu retiro #' . $withdrawalId . ' fue cancelado por el admin.' . "\n\n" .
            'Motivo: ' . ($motivo !== '' ? $motivo : 'Sin motivo') . "\n" .
            'Se te devolvieron ' . self::formatNumber($nxt20) . ' NXT-20.'
        );

        return ['success' => true];
    }

    public static function rechazarRetiro($withdrawalId, $adminId, $motivo = '')
    {
        $db = self::db();
        $withdrawalId = (int)$withdrawalId;
        $adminId      = (int)$adminId;

        $wd = $db->selectSingle(
            "SELECT * FROM ".self::prefix()."wallet_withdrawals 
             WHERE id = :id AND estado IN ('pendiente', 'aceptada') LIMIT 1",
            [':id' => $withdrawalId]
        );

        if (!$wd) return ['error' => 'Retiro no encontrado o ya procesado.'];

        $nxt20 = (int)$wd['nxt20_retirados'];

        self::devolverNxt20Bloqueado((int)$wd['user_id'], $nxt20, 
            'Retiro #' . $withdrawalId . ' rechazado por admin');

        $db->update(
            "UPDATE ".self::prefix()."wallet_withdrawals 
             SET estado = 'rechazada',
                 admin_id = :aid,
                 motivo = :motivo,
                 fecha_procesado = :now
             WHERE id = :id",
            [
                ':aid'    => $adminId,
                ':motivo' => $motivo !== '' ? $motivo : 'Rechazado por el admin',
                ':now'    => self::now(),
                ':id'     => $withdrawalId
            ]
        );

        self::sendSystemMessage(
            (int)$wd['user_id'],
            'Retiro rechazado',
            'Tu retiro #' . $withdrawalId . ' fue rechazado.' . "\n\n" .
            'Motivo: ' . ($motivo !== '' ? $motivo : 'Sin motivo') . "\n" .
            'Se te devolvieron ' . self::formatNumber($nxt20) . ' NXT-20.'
        );

        return ['success' => true];
    }

    public static function getWithdrawals($estado = 'pendiente', $limit = 50)
    {
        $db = self::db();
        $limit = (int)$limit;

        $rows = $db->select(
            "SELECT w.*, u.username 
             FROM ".self::prefix()."wallet_withdrawals w
             LEFT JOIN ".self::prefix()."users u ON u.id = w.user_id
             WHERE w.estado = :est
             ORDER BY w.fecha DESC
             LIMIT ".$limit,
            [':est' => $estado]
        );

        return $rows ? $rows : [];
    }

    public static function getWithdrawalById($withdrawalId)
    {
        $db = self::db();
        $withdrawalId = (int)$withdrawalId;

        $row = $db->selectSingle(
            "SELECT w.*, u.username 
             FROM ".self::prefix()."wallet_withdrawals w
             LEFT JOIN ".self::prefix()."users u ON u.id = w.user_id
             WHERE w.id = :id LIMIT 1",
            [':id' => $withdrawalId]
        );

        return $row ? $row : null;
    }

    public static function getRetirosByUser($userId, $limit = 50)
    {
        $db = self::db();
        $userId = (int)$userId;
        $limit = (int)$limit;

        $rows = $db->select(
            "SELECT * FROM ".self::prefix()."wallet_withdrawals 
             WHERE user_id = :uid
             ORDER BY fecha DESC
             LIMIT ".$limit,
            [':uid' => $userId]
        );

        return $rows ? $rows : [];
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 10 — VALIDACIONES
     * ════════════════════════════════════════════════════════════ */

    public static function puedeCancelar($inv)
    {
        if (!$inv) return false;
        $estados = ['pendiente_sin_asignar', 'pendiente_asignada', 'datos_enviados'];
        return in_array($inv['estado'], $estados);
    }

    public static function puedeEliminar($inv, $adminId, $authlevel = 0)
    {
        if (!$inv) return false;
        if ((int)$authlevel >= 4) return true;
        if ((int)$inv['admin_id'] === (int)$adminId) return true;
        return false;
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 11 — CONSULTAS POR USUARIO
     * ════════════════════════════════════════════════════════════ */

    public static function getSolicitudesByUser($userId, $onlyActive = true)
    {
        $db = self::db();
        $userId = (int)$userId;

        $sql = "SELECT * FROM ".self::prefix()."wallet_investments 
                WHERE user_id = :uid 
                  AND eliminada = 0";

        if ($onlyActive) {
            $sql .= " AND estado IN (
                        'pendiente_sin_asignar','pendiente_asignada',
                        'datos_enviados','pendiente_verificacion'
                      )";
        }

        $sql .= " ORDER BY fecha DESC";

        $rows = $db->select($sql, [':uid' => $userId]);
        return $rows ? $rows : [];
    }

    public static function getHistorialByUser($userId, $limit = 100)
    {
        $db = self::db();
        $userId = (int)$userId;
        $limit = (int)$limit;

        $rows = $db->select(
            "SELECT * FROM ".self::prefix()."wallet_investments 
             WHERE user_id = :uid 
               AND eliminada = 0
               AND estado IN ('completada','rechazada','cancelada','expirada')
             ORDER BY fecha_resolucion DESC
             LIMIT ".$limit,
            [':uid' => $userId]
        );

        return $rows ? $rows : [];
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 12 — CRON DE TIMEOUTS
     * ════════════════════════════════════════════════════════════ */

    public static function processTimeouts()
    {
        $inv = self::processTimeoutsInversiones();
        $ret = self::procesarTimeoutsRetiros();

        return [
            'inversiones' => $inv,
            'retiros'     => $ret
        ];
    }

    public static function processTimeoutsInversiones()
    {
        $db     = self::db();
        $now    = self::now();
        $limite = $now - (self::TIMEOUT_HORAS_INV * 3600);

        $resultados = [
            'expiradas' => 0,
            'liberadas' => 0,
            'escaladas' => 0
        ];

        // TIMEOUT 1: pendiente_sin_asignar > 48h → expirada
        $rows = $db->select(
            "SELECT id, user_id 
             FROM ".self::prefix()."wallet_investments 
             WHERE estado = 'pendiente_sin_asignar' 
               AND fecha_creacion < :limite
               AND eliminada = 0",
            [':limite' => $limite]
        );

        if ($rows) {
            foreach ($rows as $row) {
                $db->update(
                    "UPDATE ".self::prefix()."wallet_investments 
                     SET estado = 'expirada',
                         motivo = 'Expirada: ningun admin tomo la solicitud en ".self::TIMEOUT_HORAS_INV."h',
                         fecha_resolucion = :now
                     WHERE id = :id",
                    [':now' => $now, ':id' => $row['id']]
                );

                self::logAccion($row['id'], null, $row['user_id'], 'expirada', 
                    'Timeout: nadie tomo la solicitud');

                self::sendSystemMessage(
                    (int)$row['user_id'],
                    'Solicitud expirada',
                    'Tu solicitud #' . $row['id'] . ' expiro porque ningun admin la tomo en ' . 
                    self::TIMEOUT_HORAS_INV . 'h.'
                );

                $resultados['expiradas']++;
            }
        }

        // TIMEOUT 2: pendiente_asignada > 48h → liberar lock
        $rows = $db->select(
            "SELECT id, user_id, admin_id 
             FROM ".self::prefix()."wallet_investments 
             WHERE estado = 'pendiente_asignada' 
               AND fecha_asignada < :limite
               AND eliminada = 0",
            [':limite' => $limite]
        );

        if ($rows) {
            foreach ($rows as $row) {
                $db->update(
                    "UPDATE ".self::prefix()."wallet_investments 
                     SET admin_id = NULL,
                         estado = 'pendiente_sin_asignar',
                         fecha_asignada = NULL,
                         fecha_datos_enviados = NULL,
                         admin_tarjeta_snapshot = NULL,
                         admin_telefono_snapshot = NULL
                     WHERE id = :id",
                    [':id' => $row['id']]
                );

                self::logAccion($row['id'], $row['admin_id'], $row['user_id'], 'lock_forzado', 
                    'Timeout: el admin no actuo en '.self::TIMEOUT_HORAS_INV.'h');

                $resultados['liberadas']++;
            }
        }

        // TIMEOUT 3: datos_enviados > 48h → expirada
        $rows = $db->select(
            "SELECT id, user_id 
             FROM ".self::prefix()."wallet_investments 
             WHERE estado = 'datos_enviados' 
               AND fecha_datos_enviados < :limite
               AND eliminada = 0",
            [':limite' => $limite]
        );

        if ($rows) {
            foreach ($rows as $row) {
                $db->update(
                    "UPDATE ".self::prefix()."wallet_investments 
                     SET estado = 'expirada',
                         motivo = 'Expirada: el usuario no completo la transferencia en ".self::TIMEOUT_HORAS_INV."h',
                         fecha_resolucion = :now
                     WHERE id = :id",
                    [':now' => $now, ':id' => $row['id']]
                );

                self::logAccion($row['id'], null, $row['user_id'], 'expirada', 
                    'Timeout: usuario no completo la transferencia');

                self::sendSystemMessage(
                    (int)$row['user_id'],
                    'Solicitud expirada',
                    'Tu solicitud #' . $row['id'] . ' expiro porque no completaste la transferencia en ' . 
                    self::TIMEOUT_HORAS_INV . 'h.'
                );

                $resultados['expiradas']++;
            }
        }

        // TIMEOUT 4: pendiente_verificacion > 48h → escalar
        $row = $db->selectSingle(
            "SELECT COUNT(*) AS total 
             FROM ".self::prefix()."wallet_investments 
             WHERE estado = 'pendiente_verificacion' 
               AND fecha_comprobante < :limite
               AND eliminada = 0",
            [':limite' => $limite]
        );

        $resultados['escaladas'] = (int)($row['total'] ?? 0);

        return $resultados;
    }

    public static function procesarTimeoutsRetiros()
    {
        $db     = self::db();
        $now    = self::now();
        $limite = $now - (self::TIMEOUT_HORAS_RET * 3600);

        $resultados = [
            'expiradas_pendiente' => 0,
            'expiradas_aceptada'  => 0,
            'nxt20_devuelto'      => 0
        ];

        // TIMEOUT: pendiente > 72h (usa fecha como referencia)
        $rows = $db->select(
            "SELECT id, user_id, nxt20_retirados 
             FROM ".self::prefix()."wallet_withdrawals 
             WHERE estado = 'pendiente' 
               AND fecha < :limite",
            [':limite' => $limite]
        );

        if ($rows) {
            foreach ($rows as $row) {
                $nxt20 = (int)$row['nxt20_retirados'];

                self::devolverNxt20Bloqueado((int)$row['user_id'], $nxt20, 
                    'Retiro #' . $row['id'] . ' expirado');

                $db->update(
                    "UPDATE ".self::prefix()."wallet_withdrawals 
                     SET estado = 'expirada',
                         motivo = 'Expirado: el admin no respondio en ".self::TIMEOUT_HORAS_RET."h',
                         fecha_procesado = :now
                     WHERE id = :id AND estado = 'pendiente'",
                    [':now' => $now, ':id' => $row['id']]
                );

                self::sendSystemMessage(
                    (int)$row['user_id'],
                    'Retiro expirado',
                    'Tu retiro #' . $row['id'] . ' expiro. Se te devolvieron ' . 
                    self::formatNumber($nxt20) . ' NXT-20.'
                );

                $resultados['expiradas_pendiente']++;
                $resultados['nxt20_devuelto'] += $nxt20;
            }
        }

        // TIMEOUT: aceptada > 72h (usa fecha_aceptacion)
        $rows = $db->select(
            "SELECT id, user_id, nxt20_retirados 
             FROM ".self::prefix()."wallet_withdrawals 
             WHERE estado = 'aceptada' 
               AND fecha_aceptacion < :limite",
            [':limite' => $limite]
        );

        if ($rows) {
            foreach ($rows as $row) {
                $nxt20 = (int)$row['nxt20_retirados'];

                self::devolverNxt20Bloqueado((int)$row['user_id'], $nxt20, 
                    'Retiro #' . $row['id'] . ' expirado (aceptado sin confirmar)');

                $db->update(
                    "UPDATE ".self::prefix()."wallet_withdrawals 
                     SET estado = 'expirada',
                         motivo = 'Expirado: el admin acepto pero no confirmo en ".self::TIMEOUT_HORAS_RET."h',
                         fecha_procesado = :now
                     WHERE id = :id AND estado = 'aceptada'",
                    [':now' => $now, ':id' => $row['id']]
                );

                self::sendSystemMessage(
                    (int)$row['user_id'],
                    'Retiro expirado',
                    'Tu retiro #' . $row['id'] . ' expiro (el admin no confirmo a tiempo).' . "\n" .
                    'Se te devolvieron ' . self::formatNumber($nxt20) . ' NXT-20.'
                );

                $resultados['expiradas_aceptada']++;
                $resultados['nxt20_devuelto'] += $nxt20;
            }
        }

        return $resultados;
    }

    /* ════════════════════════════════════════════════════════════
     * SECCION 13 — GRAFICO (SNAPSHOT DEL BANCO)
     * ════════════════════════════════════════════════════════════ */

    public static function guardarSnapshotBanco()
    {
        $db = self::db();

        $kyberBanco       = self::getKyberBanco();
        $totalInvertido   = self::getTotalInvertidoHistorico();
        $totalRetirado    = self::getTotalRetiradoHistorico();

        try {
            $db->insert(
                "INSERT INTO ".self::prefix()."wallet_banco_historial 
                 (fecha, kyber_banco, total_invertido, total_retirado)
                 VALUES (:f, :k, :ti, :tr)",
                [
                    ':f'  => self::now(),
                    ':k'  => $kyberBanco,
                    ':ti' => $totalInvertido,
                    ':tr' => $totalRetirado
                ]
            );
        } catch (Exception $e) {
            if (defined('DEBUG') && DEBUG) {
                error_log('WalletHelper::guardarSnapshotBanco ERROR: '.$e->getMessage());
            }
        }

        return true;
    }

    public static function getGraficoFlujo($horas = 360)
    {
        $db = self::db();
        $horas = (int)$horas;

        $params = [];
        $sql = "SELECT fecha, kyber_banco, total_invertido, total_retirado 
                FROM ".self::prefix()."wallet_banco_historial";

        if ($horas > 0) {
            $desde = self::now() - ($horas * 3600);
            $sql .= " WHERE fecha >= :d";
            $params[':d'] = $desde;
        }

        $sql .= " ORDER BY fecha ASC";

        $rows = $db->select($sql, $params);

        if (!$rows) return [];

        $out = [];
        foreach ($rows as $r) {
            $out[] = [
                'fecha'           => (int)$r['fecha'],
                'kyber_banco'     => (int)$r['kyber_banco'],
                'total_invertido' => (int)$r['total_invertido'],
                'total_retirado'  => (int)$r['total_retirado']
            ];
        }

        return $out;
    }
}