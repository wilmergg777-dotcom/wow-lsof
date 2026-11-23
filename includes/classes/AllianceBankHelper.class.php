<?php
/**
 * AllianceBankHelper - Banco compartido por alianza
 * AstroIO v2.0
 *
 * Reglas del fork:
 * - Database::get() en vez de $GLOBALS['DATABASE']
 * - DB_PREFIX para el prefijo de tablas
 * - Queries en UNA SOLA LINEA
 * - Sin emojis, sin INSIDE (usar MODE)
 * - FOR UPDATE en transacciones criticas
 * - Actualizar $GLOBALS['PLANET'] y $GLOBALS['USER'] al modificar recursos
 *
 * AstroIO v2.0 (2026-10-30) - DUAL RIEL:
 *  - El banco guarda DOS bolsillos independientes:
 *      `ntx20`  -> depósitos de jugadores CUP (nacional)
 *      `untx20` -> depósitos de jugadores QVAPAY (internacional)
 *  - El Helper traduce el recurso lógico `ntx20` a la columna física
 *    correcta según el riel del jugador.
 *  - `upgrade('user')` usa el riel del líder (coste ×2 si QVAPAY).
 *  - `upgrade('bank')` y `changeBonus()` prueban primero `ntx20` y si
 *    no alcanza, prueban `untx20` (con coste ×2).
 *  - Mensajes dinámicos: NTX-20 o UNTX-20 según el riel.
 *
 * SQL OBLIGATORIO:
 *   ALTER TABLE `uni1_alliance_bank`
 *     ADD COLUMN `untx20` BIGINT NOT NULL DEFAULT 0 AFTER `ntx20`;
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

class AllianceBankHelper
{
    /* ============================================================
     * CONSTANTES DEL SISTEMA
     * ============================================================ */

    // Regla ×2 para QVAPAY (único lugar)
    const UNTX_MULTIPLIER = 2;

    // Capacidad por nivel (indice = nivel 0 a 25)
    const CAPACITIES = [
        0  => 100000,
        1  => 150000,
        2  => 200000,
        3  => 275000,
        4  => 375000,
        5  => 500000,
        6  => 675000,
        7  => 900000,
        8  => 1200000,
        9  => 1600000,
        10 => 2100000,
        11 => 2800000,
        12 => 3700000,
        13 => 4900000,
        14 => 6500000,
        15 => 8600000,
        16 => 11400000,
        17 => 15000000,
        18 => 19800000,
        19 => 26000000,
        20 => 34000000,
        21 => 44000000,
        22 => 56000000,
        23 => 70000000,
        24 => 85000000,
        25 => 100000000,
    ];

    // Costo en NTX-20 para subir al nivel (indice = nivel destino)
    const UPGRADE_COSTS = [
        1  => 5,
        2  => 6,
        3  => 8,
        4  => 9,
        5  => 10,
        6  => 11,
        7  => 13,
        8  => 14,
        9  => 15,
        10 => 16,
        11 => 18,
        12 => 19,
        13 => 20,
        14 => 21,
        15 => 23,
        16 => 24,
        17 => 25,
        18 => 26,
        19 => 28,
        20 => 29,
        21 => 30,
        22 => 31,
        23 => 32,
        24 => 33,
        25 => 34,
    ];

    // Hitos de bonus: hito => nivel que lo desbloquea
    const BONUS_HITOS = [
        1  => 2,
        2  => 4,
        3  => 6,
        4  => 8,
        5  => 10,
        6  => 12,
        7  => 14,
        8  => 16,
        9  => 18,
        10 => 20,
        11 => 22,
        12 => 24,
        13 => 25,
    ];

    // Valores por hito segun el tipo
    const BONUS_VALUES = [
        'production' => 0.02,
        'attack'     => 0.01,
        'defense'    => 0.01,
        'speed'      => 0.01,
    ];

    // Costo de cambiar un bonus ya elegido (base NTX-20)
    const BONUS_CHANGE_COST = 50;

    // Recursos validos (nombre LOGICO — 'ntx20' se traduce segun riel)
    const RESOURCES = ['metal', 'crystal', 'deuterium', 'darkmatter', 'ntx20', 'norium', 'germanium']; // 🆕 v2.6

    // Tipos de bonus validos
    const BONUS_TYPES = ['production', 'attack', 'defense', 'speed'];

    /* ============================================================
     * CACHE ESTATICO (para PlanetRessUpdate y combate)
     * ============================================================ */

    private static $bonusCache = [];
    private static $methodCache = [];

    /* ============================================================
     * HELPERS INTERNOS
     * ============================================================ */

    private static function prefix()
    {
        return DB_PREFIX;
    }

    private static function db()
    {
        return Database::get();
    }

    private static function ip()
    {
        return isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : '0.0.0.0';
    }

    /* ============================================================
     * DUAL RIEL — Métodos públicos de detección
     * ============================================================ */

    /**
     * Devuelve 'QVAPAY' o 'CUP' según el metodo_retiro del jugador.
     * Fail-safe a 'CUP' si hay error de BD.
     */
    public static function getPlayerMethod($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 'CUP';

        if (isset(self::$methodCache[$userId])) {
            return self::$methodCache[$userId];
        }

        $p  = self::prefix();
        $db = self::db();
        try {
            $row = $db->selectSingle("SELECT `metodo_retiro` FROM `".$p."users` WHERE `id` = '".$userId."' LIMIT 1;");
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
     * Columna FISICA del bolsillo según el riel del jugador.
     */
    public static function getPhysicalColumn($userId)
    {
        return self::isIntl($userId) ? 'untx20' : 'ntx20';
    }

    /**
     * Limpia la caché de métodos (útil si el jugador cambia de riel en el mismo request).
     */
    public static function clearMethodCache()
    {
        self::$methodCache = [];
    }

    /* ============================================================
     * GESTION DE LA BOVEDA
     * ============================================================ */

    /**
     * Devuelve la boveda de la alianza. Si no existe, la crea.
     * Devuelve array o null si la alianza no es valida.
     */
    public static function getBank($allianceId)
    {
        $allianceId = (int)$allianceId;
        if ($allianceId <= 0) {
            return null;
        }

        $p  = self::prefix();
        $db = self::db();

        $row = $db->selectSingle("SELECT * FROM `".$p."alliance_bank` WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

        if (empty($row)) {
            $now = time();
            $db->query("INSERT INTO `".$p."alliance_bank` (`alliance_id`, `metal`, `crystal`, `deuterium`, `darkmatter`, `ntx20`, `untx20`, `level`, `daily_limit`, `tesorero_id`, `created_at`, `updated_at`) VALUES ('".$allianceId."', 0, 0, 0, 0, 0, 0, 0, 0, 0, '".$now."', '".$now."');");
            $row = $db->selectSingle("SELECT * FROM `".$p."alliance_bank` WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");
        }

        return $row;
    }

    /**
     * Capacidad actual del banco segun su nivel.
     */
    public static function getCapacity($level)
    {
        $level = (int)$level;
        return isset(self::CAPACITIES[$level]) ? self::CAPACITIES[$level] : self::CAPACITIES[0];
    }

    /**
     * Costo en NTX-20 para subir al siguiente nivel. 0 si ya esta al maximo.
     */
    public static function getUpgradeCost($currentLevel)
    {
        $next = (int)$currentLevel + 1;
        if ($next > 25) return 0;
        return isset(self::UPGRADE_COSTS[$next]) ? self::UPGRADE_COSTS[$next] : 0;
    }

    /* ============================================================
     * DEPOSITO (dual riel)
     * ============================================================ */

    /**
     * Deposita recursos desde el planeta actual (o wallet para NTX-20/MO).
     * - `recurso='ntx20'` se traduce automáticamente a `ntx20` o `untx20`
     *   según el riel del jugador.
     * - `recurso='darkmatter'` usa una sola columna (MO es universal).
     * - Recursos del planeta (metal/crystal/deuterium) sin cambios.
     */
    public static function deposit($userId, $allianceId, $recurso, $cantidad, $planet)
    {
        $userId     = (int)$userId;
        $allianceId = (int)$allianceId;
        $recurso    = self::validateResource($recurso);
        $cantidad   = (int)$cantidad;

        if (!$recurso || $cantidad <= 0) {
            return ['ok' => false, 'msg' => 'Cantidad o recurso invalido.'];
        }

        $p  = self::prefix();
        $db = self::db();

        $bank = self::getBank($allianceId);
        if (empty($bank)) {
            return ['ok' => false, 'msg' => 'No perteneces a ninguna alianza.'];
        }

        // Traducir recurso logico -> columna fisica
        // (ntx20 se convierte en ntx20 o untx20 segun el riel del jugador)
        $physCol   = ($recurso === 'ntx20') ? self::getPhysicalColumn($userId) : $recurso;
        $monedaLbl = ($recurso === 'ntx20') ? self::getCurrencyLabel($userId) : self::nameOf($recurso, $userId);

        // Verificar capacidad en el bolsillo correcto
        $capacidad  = self::getCapacity($bank['level']);
        $bankSaldo  = isset($bank[$physCol]) ? (int)$bank[$physCol] : 0;
        $nuevoSaldo = $bankSaldo + $cantidad;
        if ($nuevoSaldo > $capacidad) {
            $restante = $capacidad - $bankSaldo;
            return ['ok' => false, 'msg' => 'Capacidad excedida. Puedes depositar maximo '.number_format(max(0, $restante)).' de '.$monedaLbl.'.'];
        }

        // NTX-20 (o su variante UNTX-20) y MO se leen desde users
        if ($recurso === 'ntx20' || $recurso === 'darkmatter') {
            $userRow = $db->selectSingle("SELECT `".$physCol."` AS `total` FROM `".$p."users` WHERE `id` = '".$userId."' LIMIT 1;");
            $disponible = empty($userRow) ? 0 : (int)$userRow['total'];

            if ($disponible < $cantidad) {
                return ['ok' => false, 'msg' => 'No tienes suficiente '.$monedaLbl.'.'];
            }

            $db->query("UPDATE `".$p."users` SET `".$physCol."` = `".$physCol."` - '".$cantidad."' WHERE `id` = '".$userId."' LIMIT 1;");

            // Sincronizar globals
            if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER'][$physCol] = $disponible - $cantidad;
            }
        } else {
            // Recursos del planeta (metal, crystal, deuterium) — sin dual riel
            $planetId   = isset($planet['id']) ? (int)$planet['id'] : 0;
            $disponible = isset($planet[$recurso]) ? (int)$planet[$recurso] : 0;

            if ($planetId <= 0 || $disponible < $cantidad) {
                return ['ok' => false, 'msg' => 'No tienes suficiente '.$monedaLbl.' en el planeta.'];
            }

            $db->query("UPDATE `".$p."planets` SET `".$recurso."` = `".$recurso."` - '".$cantidad."' WHERE `id` = '".$planetId."' AND `id_owner` = '".$userId."' LIMIT 1;");

            if (isset($GLOBALS['PLANET']['id']) && (int)$GLOBALS['PLANET']['id'] === $planetId) {
                $GLOBALS['PLANET'][$recurso] = $disponible - $cantidad;
            }
        }

        // Actualizar boveda en la columna fisica
        $db->query("UPDATE `".$p."alliance_bank` SET `".$physCol."` = `".$physCol."` + '".$cantidad."', `updated_at` = '".time()."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

        // Log
        self::log($allianceId, $userId, 'deposit', $recurso, $cantidad, $nuevoSaldo);

        return ['ok' => true, 'msg' => 'Depositaste '.number_format($cantidad).' de '.$monedaLbl.'.'];
    }

    /* ============================================================
     * RETIRO (dual riel)
     * ============================================================ */

    /**
     * Retira recursos de la boveda al planeta indicado.
     * - `recurso='ntx20'` se traduce a la columna del riel del jugador.
     * - Solo se puede retirar del bolsillo del propio riel.
     */
    public static function withdraw($userId, $allianceId, $recurso, $cantidad, $planetId)
    {
        $userId     = (int)$userId;
        $allianceId = (int)$allianceId;
        $recurso    = self::validateResource($recurso);
        $cantidad   = (int)$cantidad;
        $planetId   = (int)$planetId;

        if (!$recurso || $cantidad <= 0) {
            return ['ok' => false, 'msg' => 'Cantidad o recurso invalido.'];
        }

        $p  = self::prefix();
        $db = self::db();

        $bank = self::getBank($allianceId);
        if (empty($bank)) {
            return ['ok' => false, 'msg' => 'No hay boveda para esta alianza.'];
        }

        // Permiso
        if (!self::canWithdraw($userId, $bank)) {
            return ['ok' => false, 'msg' => 'No tienes permiso para retirar.'];
        }

        // Traducir recurso logico -> columna fisica
        $physCol   = ($recurso === 'ntx20') ? self::getPhysicalColumn($userId) : $recurso;
        $monedaLbl = ($recurso === 'ntx20') ? self::getCurrencyLabel($userId) : self::nameOf($recurso, $userId);

        // Saldo suficiente en el bolsillo correcto
        $bankSaldo = isset($bank[$physCol]) ? (int)$bank[$physCol] : 0;
        if ($bankSaldo < $cantidad) {
            return ['ok' => false, 'msg' => 'La boveda no tiene suficientes '.$monedaLbl.' en tu moneda.'];
        }

        // Limite diario (global, no por moneda)
        if ((int)$bank['daily_limit'] > 0) {
            $usadoHoy = self::getDailyUsed($userId);
            if (($usadoHoy + $cantidad) > (int)$bank['daily_limit']) {
                $restante = (int)$bank['daily_limit'] - $usadoHoy;
                return ['ok' => false, 'msg' => 'Limite diario excedido. Te quedan '.number_format(max(0, $restante)).' por retirar hoy.'];
            }
        }

        // Descontar de la boveda
        $db->query("UPDATE `".$p."alliance_bank` SET `".$physCol."` = `".$physCol."` - '".$cantidad."', `updated_at` = '".time()."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

        // Acreditar al destino
        if ($recurso === 'ntx20' || $recurso === 'darkmatter') {
            // Users (columna fisica del riel)
            $db->query("UPDATE `".$p."users` SET `".$physCol."` = `".$physCol."` + '".$cantidad."' WHERE `id` = '".$userId."' LIMIT 1;");
            if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $userId) {
                $GLOBALS['USER'][$physCol] = (int)$GLOBALS['USER'][$physCol] + $cantidad;
            }
        } else {
            // Recursos del planeta
            if ($planetId <= 0) {
                return ['ok' => false, 'msg' => 'Debes elegir un planeta destino.'];
            }
            $db->query("UPDATE `".$p."planets` SET `".$recurso."` = `".$recurso."` + '".$cantidad."' WHERE `id` = '".$planetId."' AND `id_owner` = '".$userId."' LIMIT 1;");
            if (isset($GLOBALS['PLANET']['id']) && (int)$GLOBALS['PLANET']['id'] === $planetId) {
                $GLOBALS['PLANET'][$recurso] = (int)$GLOBALS['PLANET'][$recurso] + $cantidad;
            }
        }

        // Actualizar control diario
        self::addDailyUsed($userId, $allianceId, $cantidad);

        // Log
        $nuevoSaldo = $bankSaldo - $cantidad;
        self::log($allianceId, $userId, 'withdraw', $recurso, $cantidad, $nuevoSaldo);

        return ['ok' => true, 'msg' => 'Retiraste '.number_format($cantidad).' de '.$monedaLbl.'.'];
    }

    /* ============================================================
     * PERMISOS
     * ============================================================ */

    /**
     * Puede retirar el usuario? (lider o tesorero)
     */
    public static function canWithdraw($userId, $bank)
    {
        $userId = (int)$userId;
        if ($userId <= 0 || empty($bank)) {
            return false;
        }

        if ((int)$bank['tesorero_id'] === $userId) {
            return true;
        }

        if (self::isLeader($userId, (int)$bank['alliance_id'])) {
            return true;
        }

        return false;
    }

    /**
     * Devuelve el ID del tesorero actual (0 si no hay).
     */
    public static function getTesorero($bank)
    {
        return empty($bank) ? 0 : (int)$bank['tesorero_id'];
    }

    /**
     * Devuelve TRUE si el usuario es el lider (owner) de la alianza.
     * En 2Moons el lider se identifica por ally_owner, NO por ally_rank_id.
     */
    public static function isLeader($userId, $allianceId)
    {
        $userId     = (int)$userId;
        $allianceId = (int)$allianceId;
        if ($userId <= 0 || $allianceId <= 0) {
            return false;
        }

        $p  = self::prefix();
        $db = self::db();

        $row = $db->selectSingle("SELECT `ally_owner` FROM `".$p."alliance` WHERE `id` = '".$allianceId."' LIMIT 1;");
        if (empty($row)) {
            return false;
        }

        return (int)$row['ally_owner'] === $userId;
    }

    /**
     * Devuelve los datos basicos de la alianza (nombre, tag, owner, miembros).
     */
    public static function getAllianceInfo($allianceId)
    {
        $allianceId = (int)$allianceId;
        if ($allianceId <= 0) {
            return null;
        }

        $p = self::prefix();
        return self::db()->selectSingle("SELECT `id`, `ally_name`, `ally_tag`, `ally_owner`, `ally_members`, `ally_max_members` FROM `".$p."alliance` WHERE `id` = '".$allianceId."' LIMIT 1;");
    }

    /**
     * Asigna un nuevo tesorero. Solo el lider deberia llamar esto.
     */
    public static function setTesorero($allianceId, $newTesoreroId, $byUserId)
    {
        $allianceId     = (int)$allianceId;
        $newTesoreroId  = (int)$newTesoreroId;
        $byUserId       = (int)$byUserId;

        $p  = self::prefix();
        $db = self::db();

        $bank = self::getBank($allianceId);
        if (empty($bank)) {
            return ['ok' => false, 'msg' => 'No hay boveda.'];
        }

        if ($newTesoreroId > 0) {
            $miembro = $db->selectSingle("SELECT `id` FROM `".$p."users` WHERE `id` = '".$newTesoreroId."' AND `ally_id` = '".$allianceId."' LIMIT 1;");
            if (empty($miembro)) {
                return ['ok' => false, 'msg' => 'El usuario no pertenece a esta alianza.'];
            }
        }

        $oldTesorero = (int)$bank['tesorero_id'];

        $db->query("UPDATE `".$p."alliance_bank` SET `tesorero_id` = '".$newTesoreroId."', `updated_at` = '".time()."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

        $db->query("INSERT INTO `".$p."alliance_bank_tesorero_log` (`alliance_id`, `old_tesorero`, `new_tesorero`, `changed_by`, `fecha`) VALUES ('".$allianceId."', '".$oldTesorero."', '".$newTesoreroId."', '".$byUserId."', '".time()."');");

        self::log($allianceId, $byUserId, 'tesorero_change', 'none', $newTesoreroId, 0, 'Tesorero cambiado');

        return ['ok' => true, 'msg' => 'Tesorero actualizado.'];
    }

    /**
     * Quita el permiso de tesorero a quien lo tenga asignado.
     */
    public static function removeTesorero($allianceId, $byUserId)
    {
        $allianceId = (int)$allianceId;
        $byUserId   = (int)$byUserId;

        $p  = self::prefix();
        $db = self::db();

        $bank = self::getBank($allianceId);
        if (empty($bank)) {
            return ['ok' => false, 'msg' => 'No hay boveda.'];
        }

        $oldTesorero = (int)$bank['tesorero_id'];

        if ($oldTesorero === 0) {
            return ['ok' => false, 'msg' => 'No hay ningun tesorero asignado.'];
        }

        $db->query("UPDATE `".$p."alliance_bank` SET `tesorero_id` = '0', `updated_at` = '".time()."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

        $db->query("INSERT INTO `".$p."alliance_bank_tesorero_log` (`alliance_id`, `old_tesorero`, `new_tesorero`, `changed_by`, `fecha`) VALUES ('".$allianceId."', '".$oldTesorero."', '0', '".$byUserId."', '".time()."');");

        self::log($allianceId, $byUserId, 'tesorero_change', 'none', 0, 0, 'Tesorero removido (ID: '.$oldTesorero.')');

        return ['ok' => true, 'msg' => 'Permiso de tesorero removido correctamente.'];
    }

    /**
     * Fija el limite diario global de retiro (0 = sin limite).
     */
    public static function setDailyLimit($allianceId, $limit, $byUserId)
    {
        $allianceId = (int)$allianceId;
        $limit      = (int)$limit;
        $byUserId   = (int)$byUserId;

        if ($limit < 0) $limit = 0;

        $p  = self::prefix();
        $db = self::db();

        $db->query("UPDATE `".$p."alliance_bank` SET `daily_limit` = '".$limit."', `updated_at` = '".time()."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

        self::log($allianceId, $byUserId, 'admin', 'none', $limit, 0, 'Limite diario actualizado');

        return ['ok' => true, 'msg' => 'Limite diario actualizado.'];
    }

    /* ============================================================
     * AMPLIACION DE CAPACIDAD (dual riel)
     * ============================================================ */

    /**
     * Sube el banco un nivel.
     *
     * @param int    $allianceId ID de la alianza
     * @param int    $byUserId   ID del lider que ejecuta
     * @param string $source     'bank' = paga con el bolsillo del lider en el banco
     *                           'user' = paga con la wallet del lider
     *
     * Reglas:
     *  - `source='user'`: usa el riel del lider. Coste ×1 (CUP) o ×2 (QVAPAY).
     *  - `source='bank'`: intenta primero `ntx20` (coste ×1). Si no alcanza,
     *    intenta `untx20` (coste ×2). El mensaje indica cual se uso.
     */
    public static function upgrade($allianceId, $byUserId, $source = 'bank')
    {
        $allianceId = (int)$allianceId;
        $byUserId   = (int)$byUserId;
        $source     = ($source === 'user') ? 'user' : 'bank';

        $p  = self::prefix();
        $db = self::db();

        $bank = self::getBank($allianceId);
        if (empty($bank)) {
            return ['ok' => false, 'msg' => 'No hay boveda.'];
        }

        $nivelActual = (int)$bank['level'];
        if ($nivelActual >= 25) {
            return ['ok' => false, 'msg' => 'El banco esta al nivel maximo.'];
        }

        $costoBase = self::getUpgradeCost($nivelActual);
        if ($costoBase <= 0) {
            return ['ok' => false, 'msg' => 'Costo invalido.'];
        }

        $nuevoNivel = $nivelActual + 1;

        // ============================================
        // FUENTE: USER (paga el lider con su moneda)
        // ============================================
        if ($source === 'user') {
            $isIntl     = self::isIntl($byUserId);
            $colUser    = $isIntl ? 'untx20' : 'ntx20';
            $monedaLbl  = $isIntl ? 'UNTX-20' : 'NTX-20';
            $costoFinal = $isIntl ? ($costoBase * self::UNTX_MULTIPLIER) : $costoBase;

            $userRow = $db->selectSingle("SELECT `".$colUser."` AS `saldo` FROM `".$p."users` WHERE `id` = '".$byUserId."' LIMIT 1;");
            $userSaldo = empty($userRow) ? 0 : (int)$userRow['saldo'];

            if ($userSaldo < $costoFinal) {
                return ['ok' => false, 'msg' => 'No tienes suficientes '.$monedaLbl.'. Necesitas '.number_format($costoFinal).' y tienes '.number_format($userSaldo).'.'];
            }

            $nuevoUserSaldo = $userSaldo - $costoFinal;

            $db->query("UPDATE `".$p."users` SET `".$colUser."` = '".$nuevoUserSaldo."' WHERE `id` = '".$byUserId."' LIMIT 1;");

            if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $byUserId) {
                $GLOBALS['USER'][$colUser] = $nuevoUserSaldo;
            }

            $db->query("UPDATE `".$p."alliance_bank` SET `level` = '".$nuevoNivel."', `updated_at` = '".time()."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

            self::log($allianceId, $byUserId, 'upgrade', 'ntx20', $costoFinal, (int)$bank['ntx20'], 'Banco subido a nivel '.$nuevoNivel.' (pagado por el usuario '.$byUserId.' con '.$monedaLbl.')');

            return [
                'ok'  => true,
                'msg' => 'Banco ampliado al nivel '.$nuevoNivel.'. Pagaste '.number_format($costoFinal).' '.$monedaLbl.' de tu cuenta. Capacidad nueva: '.number_format(self::getCapacity($nuevoNivel)).' por recurso.'
            ];
        }

        // ============================================
        // FUENTE: BANK (intenta ntx20 primero, luego untx20)
        // ============================================

        $bankNtx    = (int)$bank['ntx20'];
        $bankUntx   = (int)$bank['untx20'];

        $usadoCol   = null;
        $usadoMon   = null;
        $usadoCosto = 0;

        // Intento 1: bolsillo NTX-20 (coste base)
        if ($bankNtx >= $costoBase) {
            $usadoCol   = 'ntx20';
            $usadoMon   = 'NTX-20';
            $usadoCosto = $costoBase;
        }
        // Intento 2: bolsillo UNTX-20 (coste ×2)
        else {
            $costoUntx = $costoBase * self::UNTX_MULTIPLIER;
            if ($bankUntx >= $costoUntx) {
                $usadoCol   = 'untx20';
                $usadoMon   = 'UNTX-20';
                $usadoCosto = $costoUntx;
            }
        }

        if ($usadoCol === null) {
            return [
                'ok'  => false,
                'msg' => 'El banco no tiene suficiente dinero para la ampliacion. Necesita '.number_format($costoBase).' NTX-20 o '.number_format($costoBase * self::UNTX_MULTIPLIER).' UNTX-20.'
            ];
        }

        $nuevoSaldoBolsillo = (int)$bank[$usadoCol] - $usadoCosto;

        $db->query("UPDATE `".$p."alliance_bank` SET `".$usadoCol."` = '".$nuevoSaldoBolsillo."', `level` = '".$nuevoNivel."', `updated_at` = '".time()."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");

        self::log($allianceId, $byUserId, 'upgrade', $usadoCol, $usadoCosto, $nuevoSaldoBolsillo, 'Banco subido a nivel '.$nuevoNivel.' (pagado del bolsillo '.$usadoMon.')');

        return [
            'ok'  => true,
            'msg' => 'Banco ampliado al nivel '.$nuevoNivel.'. Pagaste '.number_format($usadoCosto).' '.$usadoMon.' del banco. Capacidad nueva: '.number_format(self::getCapacity($nuevoNivel)).' por recurso.'
        ];
    }

    /* ============================================================
     * BONUSES
     * ============================================================ */

    public static function getBonuses($allianceId)
    {
        $allianceId = (int)$allianceId;
        $p  = self::prefix();
        $db = self::db();

        $rows = $db->select("SELECT * FROM `".$p."alliance_bank_bonuses` WHERE `alliance_id` = '".$allianceId."' ORDER BY `hito` ASC;");

        $bonuses = [];
        if (!empty($rows)) {
            foreach ($rows as $r) {
                $bonuses[(int)$r['hito']] = $r;
            }
        }
        return $bonuses;
    }

    public static function setBonus($allianceId, $hito, $tipo, $byUserId)
    {
        $allianceId = (int)$allianceId;
        $hito       = (int)$hito;
        $byUserId   = (int)$byUserId;
        $tipo       = self::validateBonusType($tipo);

        if (!$tipo) {
            return ['ok' => false, 'msg' => 'Tipo de bonus invalido.'];
        }

        if (!isset(self::BONUS_HITOS[$hito])) {
            return ['ok' => false, 'msg' => 'Hito invalido.'];
        }

        $nivelRequerido = self::BONUS_HITOS[$hito];

        $p  = self::prefix();
        $db = self::db();

        $bank = self::getBank($allianceId);
        if (empty($bank)) {
            return ['ok' => false, 'msg' => 'No hay boveda.'];
        }

        if ((int)$bank['level'] < $nivelRequerido) {
            return ['ok' => false, 'msg' => 'Necesitas nivel '.$nivelRequerido.' para este hito.'];
        }

        $existe = $db->selectSingle("SELECT `id` FROM `".$p."alliance_bank_bonuses` WHERE `alliance_id` = '".$allianceId."' AND `hito` = '".$hito."' LIMIT 1;");
        if (!empty($existe)) {
            return ['ok' => false, 'msg' => 'Este hito ya tiene un bonus asignado. Usa cambiar.'];
        }

        $now = time();
        $db->query("INSERT INTO `".$p."alliance_bank_bonuses` (`alliance_id`, `hito`, `tipo`, `nivel_desbloqueo`, `veces_cambiado`, `fecha_asignado`, `fecha_cambio`, `changed_by`) VALUES ('".$allianceId."', '".$hito."', '".$tipo."', '".$nivelRequerido."', 0, '".$now."', 0, '".$byUserId."');");

        self::log($allianceId, $byUserId, 'bonus_set', 'none', $hito, 0, 'Hito '.$hito.' asignado a '.$tipo);

        return ['ok' => true, 'msg' => 'Bonus del hito '.$hito.' asignado a '.self::nameOfBonus($tipo).'.'];
    }

    /**
     * Cambia el bonus de un hito ya asignado.
     * Coste: 50 NTX-20 base, ×2 si el banco paga desde su bolsillo UNTX-20.
     * Intenta primero `ntx20` (coste 50). Si no alcanza, intenta `untx20` (coste 100).
     */
    public static function changeBonus($allianceId, $hito, $newTipo, $byUserId)
    {
        $allianceId = (int)$allianceId;
        $hito       = (int)$hito;
        $byUserId   = (int)$byUserId;
        $newTipo    = self::validateBonusType($newTipo);

        if (!$newTipo) {
            return ['ok' => false, 'msg' => 'Tipo de bonus invalido.'];
        }

        $p  = self::prefix();
        $db = self::db();

        $bank = self::getBank($allianceId);
        if (empty($bank)) {
            return ['ok' => false, 'msg' => 'No hay boveda.'];
        }

        $row = $db->selectSingle("SELECT * FROM `".$p."alliance_bank_bonuses` WHERE `alliance_id` = '".$allianceId."' AND `hito` = '".$hito."' LIMIT 1;");
        if (empty($row)) {
            return ['ok' => false, 'msg' => 'Este hito no tiene bonus asignado todavia.'];
        }

        if ($row['tipo'] === $newTipo) {
            return ['ok' => false, 'msg' => 'El hito ya tiene ese tipo de bonus.'];
        }

        $costoBase = self::BONUS_CHANGE_COST;
        $bankNtx   = (int)$bank['ntx20'];
        $bankUntx  = (int)$bank['untx20'];

        $usadoCol   = null;
        $usadoMon   = null;
        $usadoCosto = 0;

        if ($bankNtx >= $costoBase) {
            $usadoCol   = 'ntx20';
            $usadoMon   = 'NTX-20';
            $usadoCosto = $costoBase;
        } else {
            $costoUntx = $costoBase * self::UNTX_MULTIPLIER;
            if ($bankUntx >= $costoUntx) {
                $usadoCol   = 'untx20';
                $usadoMon   = 'UNTX-20';
                $usadoCosto = $costoUntx;
            }
        }

        if ($usadoCol === null) {
            return [
                'ok'  => false,
                'msg' => 'El banco necesita '.number_format($costoBase).' NTX-20 o '.number_format($costoBase * self::UNTX_MULTIPLIER).' UNTX-20 para cambiar.'
            ];
        }

        $nuevoSaldoBolsillo = (int)$bank[$usadoCol] - $usadoCosto;
        $now = time();

        $db->query("UPDATE `".$p."alliance_bank` SET `".$usadoCol."` = '".$nuevoSaldoBolsillo."', `updated_at` = '".$now."' WHERE `alliance_id` = '".$allianceId."' LIMIT 1;");
        $db->query("UPDATE `".$p."alliance_bank_bonuses` SET `tipo` = '".$newTipo."', `veces_cambiado` = `veces_cambiado` + 1, `fecha_cambio` = '".$now."', `changed_by` = '".$byUserId."' WHERE `alliance_id` = '".$allianceId."' AND `hito` = '".$hito."' LIMIT 1;");

        self::log($allianceId, $byUserId, 'bonus_change', $usadoCol, $usadoCosto, $nuevoSaldoBolsillo, 'Hito '.$hito.' cambiado a '.$newTipo.' (pagado '.$usadoMon.')');

        return ['ok' => true, 'msg' => 'Hito '.$hito.' cambiado a '.self::nameOfBonus($newTipo).'. Costo: '.number_format($usadoCosto).' '.$usadoMon.'.'];
    }

    /**
     * Calcula los bonuses activos totales de la alianza.
     */
    public static function getActiveBonuses($allianceId)
    {
        $bonuses = self::getBonuses($allianceId);
        $total = [
            'production' => 0.0,
            'attack'     => 0.0,
            'defense'    => 0.0,
            'speed'      => 0.0,
        ];

        foreach ($bonuses as $b) {
            $tipo = $b['tipo'];
            if (isset(self::BONUS_VALUES[$tipo])) {
                $total[$tipo] += self::BONUS_VALUES[$tipo];
            }
        }
        return $total;
    }

    public static function getBonusesForUser($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) {
            return ['production' => 0, 'attack' => 0, 'defense' => 0, 'speed' => 0];
        }

        $p  = self::prefix();
        $db = self::db();

        $user = $db->selectSingle("SELECT `ally_id` FROM `".$p."users` WHERE `id` = '".$userId."' LIMIT 1;");
        if (empty($user) || (int)$user['ally_id'] <= 0) {
            return ['production' => 0, 'attack' => 0, 'defense' => 0, 'speed' => 0];
        }

        return self::getActiveBonuses((int)$user['ally_id']);
    }

    public static function getBonusesForUserCached($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) {
            return ['production' => 0, 'attack' => 0, 'defense' => 0, 'speed' => 0];
        }
        if (isset(self::$bonusCache[$userId])) {
            return self::$bonusCache[$userId];
        }
        $bonuses = self::getBonusesForUser($userId);
        self::$bonusCache[$userId] = $bonuses;
        return $bonuses;
    }

    public static function clearBonusCache()
    {
        self::$bonusCache = [];
    }

    /* ============================================================
     * LIMITES DIARIOS
     * ============================================================ */

    public static function getDailyUsed($userId)
    {
        $userId = (int)$userId;
        $p = self::prefix();
        $hoy = date('Y-m-d');
        $row = self::db()->selectSingle("SELECT `total_retirado` FROM `".$p."alliance_bank_daily` WHERE `user_id` = '".$userId."' AND `fecha` = '".$hoy."' LIMIT 1;");
        return empty($row) ? 0 : (int)$row['total_retirado'];
    }

    public static function addDailyUsed($userId, $allianceId, $cantidad)
    {
        $userId     = (int)$userId;
        $allianceId = (int)$allianceId;
        $cantidad   = (int)$cantidad;
        $p  = self::prefix();
        $hoy = date('Y-m-d');

        self::db()->query("INSERT INTO `".$p."alliance_bank_daily` (`user_id`, `alliance_id`, `fecha`, `total_retirado`) VALUES ('".$userId."', '".$allianceId."', '".$hoy."', '".$cantidad."') ON DUPLICATE KEY UPDATE `total_retirado` = `total_retirado` + VALUES(`total_retirado`);");
    }

    /* ============================================================
     * HISTORIAL
     * ============================================================ */

    public static function getHistory($allianceId, $limit = 100)
    {
        $allianceId = (int)$allianceId;
        $limit      = (int)$limit;
        if ($limit <= 0) $limit = 100;
        if ($limit > 500) $limit = 500;

        $p = self::prefix();
        return self::db()->select("SELECT l.*, u.`username` FROM `".$p."alliance_bank_log` AS l LEFT JOIN `".$p."users` AS u ON u.`id` = l.`user_id` WHERE l.`alliance_id` = '".$allianceId."' ORDER BY l.`id` DESC LIMIT ".$limit.";");
    }

    /* ============================================================
     * LOG
     * ============================================================ */

    public static function log($allianceId, $userId, $accion, $recurso, $cantidad, $balanceAfter, $motivo = '')
    {
        $p = self::prefix();
        self::db()->query("INSERT INTO `".$p."alliance_bank_log` (`alliance_id`, `user_id`, `accion`, `recurso`, `cantidad`, `balance_after`, `motivo`, `ip`, `fecha`) VALUES ('".(int)$allianceId."', '".(int)$userId."', '".addslashes($accion)."', '".addslashes($recurso)."', '".(int)$cantidad."', '".(int)$balanceAfter."', '".addslashes($motivo)."', '".addslashes(self::ip())."', '".time()."');");
    }

    /* ============================================================
     * VALIDACIONES / HELPERS
     * ============================================================ */

    public static function validateResource($r)
    {
        return in_array($r, self::RESOURCES, true) ? $r : null;
    }

    public static function validateBonusType($t)
    {
        return in_array($t, self::BONUS_TYPES, true) ? $t : null;
    }

    /**
     * Nombre visible del recurso.
     * Para 'ntx20' devuelve 'NTX-20' o 'UNTX-20' segun el riel del jugador
     * (si se pasa $userId). Sin $userId devuelve 'NTX-20' (por defecto).
     */
    public static function nameOf($recurso, $userId = null)
    {
        if ($recurso === 'ntx20') {
            if ($userId !== null) {
                return self::getCurrencyLabel($userId);
            }
            return 'NTX-20';
        }

        $map = [
            'metal'      => 'Metal',
            'crystal'    => 'Cristal',
            'deuterium'  => 'Deuterio',
            'darkmatter' => 'Materia Oscura',
            'untx20'     => 'UNTX-20',
            'norium'     => 'Norium',    // 🆕 v2.6
            'germanium'  => 'Germanio',  // 🆕 v2.6
        ];
        return isset($map[$recurso]) ? $map[$recurso] : $recurso;
    }

    public static function nameOfBonus($tipo)
    {
        $map = [
            'production' => 'Produccion',
            'attack'     => 'Ataque',
            'defense'    => 'Defensa',
            'speed'      => 'Velocidad',
        ];
        return isset($map[$tipo]) ? $map[$tipo] : $tipo;
    }
}