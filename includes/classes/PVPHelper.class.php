<?php

/**
 * AstroIO — PVPHelper
 * Helper base del sistema PvP (Arenas + Torneos)
 *
 * Ubicación: includes/classes/PVPHelper.class.php
 * @package AstroIO
 * @version 2.0 — Doble Riel (NTX-20 / UNTX-20)
 *
 * v1.0 — Helper base PvP (Arenas + Torneos)
 * v2.0 — Doble Riel: NTX-20 (CUP) y UNTX-20 (QVAPAY ×2)
 *        · Detección de riel por `metodo_retiro`
 *        · Regla ×2 centralizada en const UNTX_MULTIPLIER
 *        · Métodos riel-aware: getBalance/addBalance/removeBalance/addRealAmount
 *        · Banco de alianza dual (ntx20 + untx20)
 *        · Compatibilidad total con los métodos originales (CUP-only)
 */

class PVPHelper
{
    /* ============================================================
     *  CONSTANTES
     * ============================================================ */

    // 🔥 Regla ×2 centralizada (ÚNICO lugar donde vive el 2)
    const UNTX_MULTIPLIER = 2;

    // Rieles válidos
    const RIELS = array('CUP', 'QVAPAY');

    // Modos de arena válidos
    const MODES = array('1v1', '2v2', '3v3');

    // Tamaño de equipo por modo
    const TEAM_SIZE = array(
        '1v1' => 1,
        '2v2' => 2,
        '3v3' => 3,
    );

    // Máximo de jugadores por modo (equipos x 2)
    const MAX_PLAYERS = array(
        '1v1' => 2,
        '2v2' => 4,
        '3v3' => 6,
    );

    // Estados de arena
    const ARENA_STATUS = array(
        'waiting'    => 'Esperando jugadores',
        'active'     => 'En curso',
        'extra_time' => 'Tiempo extra',
        'finished'   => 'Finalizada',
        'cancelled'  => 'Cancelada',
    );

    // Estados de torneo
    const TOURNAMENT_STATUS = array(
        'registration' => 'Inscripciones abiertas',
        'running'      => 'En curso',
        'finished'     => 'Finalizado',
        'cancelled'    => 'Cancelado',
    );

    // Tipos de torneo
    const TOURNAMENT_TYPES = array('1v1', 'alliance');

    // Modos de torneo
    const TOURNAMENT_MODES = array('single', 'double_elimination');

    // Colores de countdown (segundos)
    const COLOR_GREEN_MAX = 86400; // >24h


    /* ============================================================
     *  CACHÉS ESTÁTICAS
     * ============================================================ */

    private static $configCache     = null;
    private static $eventStateCache = array();
    private static $methodCache     = array();


    /* ============================================================
     *  DOBLE RIEL — DETECCIÓN
     * ============================================================ */

    /**
     * Detecta el riel del jugador según `metodo_retiro`.
     * Cachea el resultado para no repetir queries.
     * Fail-safe: si falla la consulta → 'CUP'.
     *
     * @param int $userId
     * @return string 'CUP'|'QVAPAY'
     */
    public static function getPlayerMethod($userId)
    {
        $userId = (int) $userId;
        if ($userId <= 0) {
            return 'CUP';
        }

        if (isset(self::$methodCache[$userId])) {
            return self::$methodCache[$userId];
        }

        try {
            $db  = Database::get();
            $row = $db->selectSingle(
                "SELECT `metodo_retiro` FROM %%USERS%% WHERE `id` = :uid LIMIT 1;",
                array(':uid' => $userId)
            );
            $method = ($row && isset($row['metodo_retiro']) && $row['metodo_retiro'] === 'QVAPAY')
                ? 'QVAPAY'
                : 'CUP';
        } catch (Exception $e) {
            $method = 'CUP';
        }

        self::$methodCache[$userId] = $method;
        return $method;
    }

    /**
     * ¿El jugador pertenece al riel internacional (QVAPAY)?
     */
    public static function isIntl($userId)
    {
        return self::getPlayerMethod($userId) === 'QVAPAY';
    }

    /**
     * Etiqueta visible de la moneda del jugador.
     * Jugador NUNCA ve la moneda del otro riel.
     */
    public static function getCurrencyLabel($userId)
    {
        return self::isIntl($userId) ? 'UNTX-20' : 'NTX-20';
    }

    /**
     * Columna física de la BD donde vive el saldo del jugador.
     */
    public static function getPhysicalColumn($userId)
    {
        return self::isIntl($userId) ? 'untx20' : 'ntx20';
    }

    /**
     * Devuelve toda la info del riel del jugador (para controladores/templates).
     *
     * @param int $userId
     * @return array
     */
    public static function getRielInfo($userId)
    {
        $userId     = (int) $userId;
        $isIntl     = self::isIntl($userId);
        $colBalance = $isIntl ? 'untx20' : 'ntx20';
        $moneda     = $isIntl ? 'UNTX-20' : 'NTX-20';
        $monedaFiat = $isIntl ? 'USD' : 'CUP';
        $saldo      = 0;

        try {
            $db  = Database::get();
            $row = $db->selectSingle(
                "SELECT `" . $colBalance . "` AS saldo FROM %%USERS%% WHERE `id` = :uid LIMIT 1;",
                array(':uid' => $userId)
            );
            $saldo = $row ? (int) $row['saldo'] : 0;
        } catch (Exception $e) {
            // Fail-safe: saldo 0
        }

        return array(
            'isIntl'     => $isIntl,
            'colBalance' => $colBalance,
            'moneda'     => $moneda,
            'monedaFiat' => $monedaFiat,
            'saldo'      => $saldo,
            'multiplier' => $isIntl ? self::UNTX_MULTIPLIER : 1,
        );
    }

    /**
     * Convierte un precio base (NTX-20) al precio real del jugador.
     * Si es QVAPAY → base × 2.
     *
     * @param int $precioBase
     * @param int $userId
     * @return int
     */
    public static function getPrecioParaJugador($precioBase, $userId)
    {
        return self::isIntl($userId)
            ? ((int) $precioBase * self::UNTX_MULTIPLIER)
            : (int) $precioBase;
    }

    /**
     * Convierte un premio base (NTX-20) al premio real que recibe el jugador.
     * Si es QVAPAY → base × 2.
     *
     * @param int $cantidadBase
     * @param int $userId
     * @return int
     */
    public static function getPremioParaJugador($cantidadBase, $userId)
    {
        return self::isIntl($userId)
            ? ((int) $cantidadBase * self::UNTX_MULTIPLIER)
            : (int) $cantidadBase;
    }

    /**
     * Limpia la caché de rieles (útil en tests o cambios de metodo_retiro).
     */
    public static function clearMethodCache()
    {
        self::$methodCache = array();
    }


    /* ============================================================
     *  CONFIGURACIÓN
     * ============================================================ */

    public static function getConfig()
    {
        if (self::$configCache !== null) {
            return self::$configCache;
        }

        $db   = Database::get();
        $sql  = "SELECT `config_key`, `config_value` FROM %%PVP_CONFIG%%;";
        $rows = $db->select($sql);

        $config = array();
        if (!empty($rows)) {
            foreach ($rows as $row) {
                $config[$row['config_key']] = $row['config_value'];
            }
        }

        self::$configCache = $config;
        return $config;
    }

    public static function get($key, $default = null)
    {
        $config = self::getConfig();
        return isset($config[$key]) ? $config[$key] : $default;
    }

    public static function set($key, $value)
    {
        $db = Database::get();
        $sql = "INSERT INTO %%PVP_CONFIG%% (`config_key`, `config_value`, `updated_at`)
                VALUES (:key, :value, :now)
                ON DUPLICATE KEY UPDATE
                    `config_value` = VALUES(`config_value`),
                    `updated_at`   = VALUES(`updated_at`);";

        $db->update($sql, array(
            ':key'   => $key,
            ':value' => (string) $value,
            ':now'   => TIMESTAMP,
        ));

        self::clearConfigCache();
    }

    public static function clearConfigCache()
    {
        self::$configCache     = null;
        self::$eventStateCache = array();
    }


    /* ============================================================
     *  ESTADO GLOBAL
     * ============================================================ */

    public static function isArenaEnabled()
    {
        return (int) self::get('arena_enabled', 1) === 1;
    }

    public static function isTournamentEnabled()
    {
        return (int) self::get('tournament_enabled', 1) === 1;
    }


    /* ============================================================
     *  LOG / AUDITORÍA
     * ============================================================ */

    public static function log($eventType, $eventId, $action, $userId = 0, $details = null)
    {
        try {
            $db = Database::get();
            $sql = "INSERT INTO %%PVP_LOG%% SET
                `event_type`  = :eventType,
                `event_id`    = :eventId,
                `action`      = :action,
                `user_id`     = :userId,
                `details`     = :details,
                `ip_address`  = :ip,
                `created_at`  = :now;";

            $db->insert($sql, array(
                ':eventType' => $eventType,
                ':eventId'   => (int) $eventId,
                ':action'    => $action,
                ':userId'    => (int) $userId,
                ':details'   => $details !== null ? json_encode($details) : null,
                ':ip'        => isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : '',
                ':now'       => TIMESTAMP,
            ));
        } catch (Exception $e) {
            if (function_exists('error_log')) {
                error_log('[PVP] log error: ' . $e->getMessage());
            }
        }
    }


    /* ============================================================
     *  NTX-20 — GESTIÓN (LEGACY, CUP-ONLY)
     *  ------------------------------------------------------------
     *  Estos métodos operan SOLO sobre la columna `ntx20`.
     *  Se conservan por compatibilidad con código existente.
     *  Para flujos dual-riel, usar los métodos de la sección
     *  "DOBLE RIEL — GESTIÓN DE SALDO" más abajo.
     * ============================================================ */

    public static function getNtx20($userId)
    {
        $db  = Database::get();
        $sql = "SELECT `ntx20` FROM %%USERS%% WHERE `id` = :uid LIMIT 1;";
        $row = $db->selectSingle($sql, array(':uid' => (int) $userId));
        return empty($row) ? 0 : (int) $row['ntx20'];
    }

    public static function hasNtx20($userId, $amount)
    {
        return self::getNtx20($userId) >= (int) $amount;
    }

    /**
     * Suma NTX-20 al jugador (CUP-only).
     * Usa WalletHelper::addNxt20() si existe; si no, UPDATE directo a `ntx20`.
     *
     * @return bool
     */
    public static function addNtx20($userId, $amount, $source = 'pvp', $description = '')
    {
        $userId = (int) $userId;
        $amount = (int) $amount;
        if ($userId <= 0 || $amount <= 0) {
            return false;
        }

        // Intentar con WalletHelper si existe
        if (!class_exists('WalletHelper')) {
            $walletFile = ROOT_PATH . 'includes/classes/WalletHelper.class.php';
            if (file_exists($walletFile)) {
                require_once $walletFile;
            }
        }

        if (class_exists('WalletHelper') && method_exists('WalletHelper', 'addNxt20')) {
            try {
                WalletHelper::addNxt20($userId, $amount, $source, $description);
                return true;
            } catch (Exception $e) {
                // Fallback abajo
            }
        }

        // Fallback directo a la tabla users
        try {
            $db  = Database::get();
            $sql = "UPDATE %%USERS%% SET `ntx20` = `ntx20` + :n WHERE `id` = :uid;";
            $db->update($sql, array(':n' => $amount, ':uid' => $userId));

            if (isset($GLOBALS['USER']['id']) && (int) $GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER']['ntx20'] = (int) $GLOBALS['USER']['ntx20'] + $amount;
            }
            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'add_ntx20_error', $userId, array(
                'error'  => $e->getMessage(),
                'amount' => $amount,
            ));
            return false;
        }
    }

    /**
     * Resta NTX-20 al jugador (CUP-only, con verificación de saldo).
     *
     * @return bool  true si se descontó correctamente
     */
    public static function removeNtx20($userId, $amount, $source = 'pvp', $description = '')
    {
        $userId = (int) $userId;
        $amount = (int) $amount;
        if ($userId <= 0 || $amount <= 0) {
            return false;
        }

        // Verificar saldo primero
        if (!self::hasNtx20($userId, $amount)) {
            return false;
        }

        try {
            $db  = Database::get();
            $sql = "UPDATE %%USERS%% SET `ntx20` = `ntx20` - :n
                    WHERE `id` = :uid AND `ntx20` >= :n;";
            $db->update($sql, array(':n' => $amount, ':uid' => $userId));

            if (isset($GLOBALS['USER']['id']) && (int) $GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER']['ntx20'] = max(0, (int) $GLOBALS['USER']['ntx20'] - $amount);
            }
            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'remove_ntx20_error', $userId, array(
                'error'  => $e->getMessage(),
                'amount' => $amount,
            ));
            return false;
        }
    }

    /**
     * Suma NTX-20 al banco de una alianza (CUP-only, legacy).
     *
     * @return bool
     */
    public static function addNtx20ToAllianceBank($allianceId, $amount, $source = 'pvp_tournament', $motivo = '')
    {
        $allianceId = (int) $allianceId;
        $amount     = (int) $amount;
        if ($allianceId <= 0 || $amount <= 0) {
            return false;
        }

        try {
            $db = Database::get();
            $p  = DB_PREFIX;

            // Verificar si existe la fila del banco
            $bank = $db->selectSingle("SELECT `id` FROM `" . $p . "alliance_bank` WHERE `alliance_id` = '" . $allianceId . "' LIMIT 1;");
            if (empty($bank)) {
                $now = time();
                $db->query("INSERT INTO `" . $p . "alliance_bank` (`alliance_id`, `metal`, `crystal`, `deuterium`, `darkmatter`, `ntx20`, `level`, `daily_limit`, `tesorero_id`, `created_at`, `updated_at`) VALUES ('" . $allianceId . "', 0, 0, 0, 0, 0, 0, 0, 0, '" . $now . "', '" . $now . "');");
            }

            // Sumar NTX-20 al banco
            $db->query("UPDATE `" . $p . "alliance_bank` SET `ntx20` = `ntx20` + '" . $amount . "', `updated_at` = '" . time() . "' WHERE `alliance_id` = '" . $allianceId . "' LIMIT 1;");

            // Log del banco si el helper está cargado (evita require directo por el MODE check)
            if (class_exists('AllianceBankHelper') && method_exists('AllianceBankHelper', 'log')) {
                try {
                    AllianceBankHelper::log($allianceId, 0, 'admin', 'ntx20', $amount, 0, 'Premio PvP: ' . $motivo);
                } catch (Exception $e) {
                    // Ignorar
                }
            }

            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'add_ntx20_bank_error', 0, array(
                'alliance_id' => $allianceId,
                'amount'      => $amount,
                'error'       => $e->getMessage(),
            ));
            return false;
        }
    }


    /* ============================================================
     *  DOBLE RIEL — GESTIÓN DE SALDO
     *  ------------------------------------------------------------
     *  Todos los métodos de esta sección detectan el riel del
     *  jugador y operan sobre la columna correcta (`ntx20` o
     *  `untx20`). El jugador NUNCA ve la moneda del otro riel.
     *
     *  Convención de "base" vs "real":
     *   · input "base"  → se multiplica ×2 si QVAPAY
     *   · input "real"  → se usa tal cual (para pools ya en riel)
     * ============================================================ */

    /**
     * Devuelve el saldo REAL del jugador en su propio riel.
     * - CUP    → `ntx20`
     * - QVAPAY → `untx20`
     */
    public static function getBalance($userId)
    {
        $col = self::getPhysicalColumn($userId);

        try {
            $db  = Database::get();
            $sql = "SELECT `" . $col . "` AS `balance` FROM %%USERS%% WHERE `id` = :uid LIMIT 1;";
            $row = $db->selectSingle($sql, array(':uid' => (int) $userId));
            return empty($row) ? 0 : (int) $row['balance'];
        } catch (Exception $e) {
            return 0;
        }
    }

    /**
     * ¿El jugador tiene saldo suficiente para pagar un monto BASE?
     * Internamente convierte a real (×2 si QVAPAY) y compara.
     */
    public static function hasBalance($userId, $baseAmount)
    {
        $realAmount = self::getPrecioParaJugador((int) $baseAmount, $userId);
        return self::getBalance($userId) >= $realAmount;
    }

    /**
     * Suma un monto BASE al jugador en su riel.
     * CUP → +base en `ntx20` · QVAPAY → +(base×2) en `untx20`.
     *
     * @return bool
     */
    public static function addBalance($userId, $baseAmount, $source = 'pvp', $description = '')
    {
        $userId     = (int) $userId;
        $baseAmount = (int) $baseAmount;
        if ($userId <= 0 || $baseAmount <= 0) {
            return false;
        }

        $isIntl     = self::isIntl($userId);
        $col        = $isIntl ? 'untx20' : 'ntx20';
        $realAmount = self::getPremioParaJugador($baseAmount, $userId);

        try {
            $db  = Database::get();
            $sql = "UPDATE %%USERS%% SET `" . $col . "` = `" . $col . "` + :n WHERE `id` = :uid;";
            $db->update($sql, array(':n' => $realAmount, ':uid' => $userId));

            // Refrescar sesión global (Topnav al instante)
            if (isset($GLOBALS['USER']['id']) && (int) $GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER'][$col] = ((int) ($GLOBALS['USER'][$col] ?? 0)) + $realAmount;
            }

            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'add_balance_error', $userId, array(
                'riel'      => $isIntl ? 'QVAPAY' : 'CUP',
                'base'      => $baseAmount,
                'real'      => $realAmount,
                'error'     => $e->getMessage(),
            ));
            return false;
        }
    }

    /**
     * Resta un monto BASE al jugador de su riel (con verificación).
     * CUP → -base en `ntx20` · QVAPAY → -(base×2) en `untx20`.
     *
     * @return bool  true si se descontó correctamente
     */
    public static function removeBalance($userId, $baseAmount, $source = 'pvp', $description = '')
    {
        $userId     = (int) $userId;
        $baseAmount = (int) $baseAmount;
        if ($userId <= 0 || $baseAmount <= 0) {
            return false;
        }

        $isIntl     = self::isIntl($userId);
        $col        = $isIntl ? 'untx20' : 'ntx20';
        $realAmount = self::getPrecioParaJugador($baseAmount, $userId);

        // Verificar saldo
        if (self::getBalance($userId) < $realAmount) {
            return false;
        }

        try {
            $db  = Database::get();
            $sql = "UPDATE %%USERS%% SET `" . $col . "` = `" . $col . "` - :n
                    WHERE `id` = :uid AND `" . $col . "` >= :n;";
            $db->update($sql, array(':n' => $realAmount, ':uid' => $userId));

            // Refrescar sesión global
            if (isset($GLOBALS['USER']['id']) && (int) $GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER'][$col] = max(0, ((int) ($GLOBALS['USER'][$col] ?? 0)) - $realAmount);
            }

            // Log NTX20 SOLO si CUP (no existe UNTXLogHelper)
            if (!$isIntl && class_exists('NTX20LogHelper')) {
                try {
                    NTX20LogHelper::log($userId, -$realAmount, $source, $description, 0);
                } catch (Exception $e) {
                    // silencioso
                }
            }

            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'remove_balance_error', $userId, array(
                'riel'  => $isIntl ? 'QVAPAY' : 'CUP',
                'base'  => $baseAmount,
                'real'  => $realAmount,
                'error' => $e->getMessage(),
            ));
            return false;
        }
    }

    /**
     * Suma un monto REAL a un riel específico.
     * Sin multiplicador. Usado para repartir pools que ya están
     * en el riel correcto (A1 — pools separados por riel).
     *
     * @param int         $userId
     * @param int         $realAmount
     * @param string|null $riel       'CUP'|'QVAPAY'|null (null → detecta del jugador)
     * @param string      $source
     * @param string      $description
     * @return bool
     */
    public static function addRealAmount($userId, $realAmount, $riel = null, $source = 'pvp', $description = '')
    {
        $userId     = (int) $userId;
        $realAmount = (int) $realAmount;
        if ($userId <= 0 || $realAmount <= 0) {
            return false;
        }

        if ($riel === null) {
            $riel = self::getPlayerMethod($userId);
        }
        if (!in_array($riel, self::RIELS, true)) {
            $riel = 'CUP';
        }

        $col = ($riel === 'QVAPAY') ? 'untx20' : 'ntx20';

        try {
            $db  = Database::get();
            $sql = "UPDATE %%USERS%% SET `" . $col . "` = `" . $col . "` + :n WHERE `id` = :uid;";
            $db->update($sql, array(':n' => $realAmount, ':uid' => $userId));

            if (isset($GLOBALS['USER']['id']) && (int) $GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER'][$col] = ((int) ($GLOBALS['USER'][$col] ?? 0)) + $realAmount;
            }

            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'add_real_amount_error', $userId, array(
                'riel'  => $riel,
                'real'  => $realAmount,
                'error' => $e->getMessage(),
            ));
            return false;
        }
    }


    /* ============================================================
     *  DOBLE RIEL — BANCO DE ALIANZA
     *  ------------------------------------------------------------
     *  La tabla `uni1_alliance_bank` tiene AMBAS columnas:
     *   · `ntx20`  (existente)
     *   · `untx20` (confirmada — ya existe en la BD)
     * ============================================================ */

    /**
     * Suma un monto REAL al banco de la alianza en un riel específico.
     * Si el banco no existe, lo crea con ambas columnas.
     *
     * @param int    $allianceId
     * @param int    $realAmount
     * @param string $riel       'CUP'|'QVAPAY'
     * @param string $source
     * @param string $motivo
     * @return bool
     */
    public static function addBalanceToAllianceBank($allianceId, $realAmount, $riel = 'CUP', $source = 'pvp_tournament', $motivo = '')
    {
        $allianceId = (int) $allianceId;
        $realAmount = (int) $realAmount;
        if ($allianceId <= 0 || $realAmount <= 0) {
            return false;
        }

        if (!in_array($riel, self::RIELS, true)) {
            $riel = 'CUP';
        }

        $col = ($riel === 'QVAPAY') ? 'untx20' : 'ntx20';

        try {
            $db = Database::get();
            $p  = DB_PREFIX;

            // Verificar si existe la fila del banco
            $bank = $db->selectSingle(
                "SELECT `id` FROM `" . $p . "alliance_bank` WHERE `alliance_id` = :aid LIMIT 1;",
                array(':aid' => $allianceId)
            );

            if (empty($bank)) {
                $now = time();
                $db->update(
                    "INSERT INTO `" . $p . "alliance_bank`
                        (`alliance_id`, `metal`, `crystal`, `deuterium`, `darkmatter`,
                         `ntx20`, `untx20`, `level`, `daily_limit`, `tesorero_id`,
                         `created_at`, `updated_at`)
                     VALUES
                        (:aid, 0, 0, 0, 0, 0, 0, 0, 0, 0, :now, :now);",
                    array(':aid' => $allianceId, ':now' => $now)
                );
            }

            // Sumar al riel correspondiente
            $db->update(
                "UPDATE `" . $p . "alliance_bank`
                    SET `" . $col . "` = `" . $col . "` + :n,
                        `updated_at`   = :now
                  WHERE `alliance_id` = :aid
                  LIMIT 1;",
                array(':n' => $realAmount, ':now' => time(), ':aid' => $allianceId)
            );

            // Log del banco si el helper está cargado
            if (class_exists('AllianceBankHelper') && method_exists('AllianceBankHelper', 'log')) {
                try {
                    $colLabel = ($riel === 'QVAPAY') ? 'untx20' : 'ntx20';
                    AllianceBankHelper::log($allianceId, 0, 'admin', $colLabel, $realAmount, 0, 'Premio PvP: ' . $motivo);
                } catch (Exception $e) {
                    // Ignorar
                }
            }

            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'add_balance_bank_error', 0, array(
                'alliance_id' => $allianceId,
                'riel'        => $riel,
                'real'        => $realAmount,
                'error'       => $e->getMessage(),
            ));
            return false;
        }
    }

    /**
     * Devuelve el saldo del banco de la alianza en un riel específico.
     *
     * @param int    $allianceId
     * @param string $riel       'CUP'|'QVAPAY'|null (null → 'CUP')
     * @return int
     */
    public static function getBalanceFromAllianceBank($allianceId, $riel = null)
    {
        $allianceId = (int) $allianceId;
        if ($allianceId <= 0) {
            return 0;
        }

        if ($riel === null) {
            $riel = 'CUP';
        }
        if (!in_array($riel, self::RIELS, true)) {
            $riel = 'CUP';
        }

        $col = ($riel === 'QVAPAY') ? 'untx20' : 'ntx20';

        try {
            $db  = Database::get();
            $p   = DB_PREFIX;
            $row = $db->selectSingle(
                "SELECT `" . $col . "` AS `balance`
                   FROM `" . $p . "alliance_bank`
                  WHERE `alliance_id` = :aid
                  LIMIT 1;",
                array(':aid' => $allianceId)
            );
            return empty($row) ? 0 : (int) $row['balance'];
        } catch (Exception $e) {
            return 0;
        }
    }


    /* ============================================================
     *  NOTIFICACIONES (sistema nativo de mensajes)
     * ============================================================ */

    public static function sendNotification($userId, $subject, $body)
    {
        try {
            if (!class_exists('PlayerUtil')) {
                return false;
            }

            $universe = class_exists('Universe') ? Universe::current() : 1;

            PlayerUtil::sendMessage(
                (int) $userId,
                0,
                'Sistema PvP',
                3,
                $subject,
                $body,
                TIMESTAMP,
                null,
                1,
                $universe
            );

            return true;
        } catch (Exception $e) {
            self::log('system', 0, 'send_notification_error', (int) $userId, array(
                'error'   => $e->getMessage(),
                'subject' => $subject,
            ));
            return false;
        }
    }

    /**
     * Notificación global a todos los jugadores.
     *
     * @return int  Número de mensajes enviados
     */
    public static function sendGlobalNotification($subject, $body)
    {
        try {
            $db   = Database::get();
            $sql  = "SELECT `id` FROM %%USERS%% WHERE `authlevel` >= 0;";
            $rows = $db->select($sql);

            if (empty($rows)) {
                return 0;
            }

            $count = 0;
            foreach ($rows as $row) {
                if (self::sendNotification((int) $row['id'], $subject, $body)) {
                    $count++;
                }
            }
            return $count;
        } catch (Exception $e) {
            self::log('system', 0, 'global_notification_error', 0, array(
                'error' => $e->getMessage(),
            ));
            return 0;
        }
    }


    /* ============================================================
     *  ESTADO DE ARENAS / TORNEOS (para countdown)
     * ============================================================ */

    /**
     * Devuelve el estado completo de una arena.
     * Cachea el resultado para no repetir queries.
     *
     * @return array
     *   - enabled   : 1|0
     *   - waiting   : 1|0 (esperando jugadores)
     *   - active    : 1|0 (en curso o tiempo extra)
     *   - next_time : timestamp (próximo inicio) o 0
     *   - end_time  : timestamp (fin) o 0
     *   - status    : string
     */
    public static function getArenaState($arenaId)
    {
        $arenaId  = (int) $arenaId;
        $cacheKey = 'arena_' . $arenaId;

        if (isset(self::$eventStateCache[$cacheKey])) {
            return self::$eventStateCache[$cacheKey];
        }

        $state = array(
            'enabled'   => 0,
            'waiting'   => 0,
            'active'    => 0,
            'next_time' => 0,
            'end_time'  => 0,
            'status'    => '',
        );

        $db  = Database::get();
        $sql = "SELECT `id`, `status`, `starts_at`, `ends_at`, `extra_time_ends_at`
                FROM %%PVP_ARENAS%%
                WHERE `id` = :id LIMIT 1;";
        $row = $db->selectSingle($sql, array(':id' => $arenaId));

        if (empty($row)) {
            self::$eventStateCache[$cacheKey] = $state;
            return $state;
        }

        $state['enabled'] = 1;
        $state['status']  = $row['status'];

        if ($row['status'] === 'waiting') {
            $state['waiting']   = 1;
            $state['next_time'] = (int) $row['starts_at'];
        } elseif ($row['status'] === 'active') {
            $state['active']   = 1;
            $state['end_time'] = (int) $row['ends_at'];
        } elseif ($row['status'] === 'extra_time') {
            $state['active']   = 1;
            $state['end_time'] = (int) $row['extra_time_ends_at'];
        }

        self::$eventStateCache[$cacheKey] = $state;
        return $state;
    }

    /**
     * Devuelve el estado completo de un torneo.
     */
    public static function getTournamentState($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        $cacheKey     = 'tournament_' . $tournamentId;

        if (isset(self::$eventStateCache[$cacheKey])) {
            return self::$eventStateCache[$cacheKey];
        }

        $state = array(
            'enabled'      => 0,
            'registration' => 0,
            'active'       => 0,
            'next_time'    => 0,
            'end_time'     => 0,
            'status'       => '',
        );

        $db  = Database::get();
        $sql = "SELECT `id`, `status`, `registration_ends_at`, `starts_at`, `current_round`
                FROM %%PVP_TOURNAMENTS%%
                WHERE `id` = :id LIMIT 1;";
        $row = $db->selectSingle($sql, array(':id' => $tournamentId));

        if (empty($row)) {
            self::$eventStateCache[$cacheKey] = $state;
            return $state;
        }

        $state['enabled'] = 1;
        $state['status']  = $row['status'];

        if ($row['status'] === 'registration') {
            $state['registration'] = 1;
            $state['next_time']    = (int) $row['registration_ends_at'];
        } elseif ($row['status'] === 'running') {
            $state['active']    = 1;
            $state['next_time'] = (int) $row['starts_at'];
        }

        self::$eventStateCache[$cacheKey] = $state;
        return $state;
    }


    /* ============================================================
     *  UTILIDADES
     * ============================================================ */

    public static function getModeTeamSize($mode)
    {
        return isset(self::TEAM_SIZE[$mode]) ? self::TEAM_SIZE[$mode] : 1;
    }

    public static function getModeMaxPlayers($mode)
    {
        return isset(self::MAX_PLAYERS[$mode]) ? self::MAX_PLAYERS[$mode] : 2;
    }

    public static function isValidMode($mode)
    {
        return in_array($mode, self::MODES, true);
    }

    public static function isValidTournamentType($type)
    {
        return in_array($type, self::TOURNAMENT_TYPES, true);
    }

    public static function isValidTournamentMode($mode)
    {
        return in_array($mode, self::TOURNAMENT_MODES, true);
    }

    /**
     * Formatea segundos a "23d 14h 22m"
     */
    public static function formatCountdown($seconds)
    {
        $seconds = max(0, (int) $seconds);

        if ($seconds <= 0) {
            return '0m';
        }

        $days    = (int) floor($seconds / 86400);
        $hours   = (int) floor(($seconds % 86400) / 3600);
        $minutes = (int) floor(($seconds % 3600) / 60);

        $parts = array();
        if ($days > 0)    $parts[] = $days . 'd';
        if ($hours > 0)   $parts[] = $hours . 'h';
        if ($minutes > 0) $parts[] = $minutes . 'm';

        if (empty($parts)) {
            $parts[] = '<1m';
        }

        return implode(' ', $parts);
    }

    /**
     * Devuelve el color del countdown:
     * - red    : activo (en curso)
     * - green  : >24h restantes
     * - yellow : <24h restantes
     * - gray   : sin programar
     */
    public static function getCountdownColor($seconds, $isActive = false)
    {
        if ($isActive) {
            return 'red';
        }

        $seconds = (int) $seconds;

        if ($seconds <= 0) {
            return 'gray';
        }

        if ($seconds > self::COLOR_GREEN_MAX) {
            return 'green';
        }

        return 'yellow';
    }

    /**
     * Timestamp actual del servidor.
     */
    public static function now()
    {
        return TIMESTAMP;
    }
}