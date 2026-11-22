<?php

/**
 * AstroIO - Sistema Planetario
 * PlanetHelper.class.php
 *
 * Gestiona la logica del modulo Planetario:
 * - Droides (Constructor / Ingeniero)
 * - Crear Luna
 * - Aumentar Campos
 * - Aumentar Diametro
 * - Teletransportar
 * - Renombrar
 * - Abandonar
 *
 * AstroIO-FIX v3.7 (2026-10-13):
 *  - FIX CRITICO en createMoon() y abandon():
 *      - planet_type = '3' CON COMILLAS en TODAS las consultas SQL
 *
 * AstroIO v4.0 (2026-10-30) - DUAL RIEL:
 *  - Droides (Constructor / Ingeniero) y Crear Luna detectan si el
 *    jugador es CUP (NTX-20) o QVAPAY (UNTX-20).
 *  - Si es QVAPAY: precio × 2 y descuenta de `untx20`.
 *  - Si es CUP: precio base y descuenta de `ntx20`.
 *  - Los mensajes de error muestran la moneda correcta (NTX-20 / UNTX-20).
 *  - El log NTX20 se registra solo para CUP (no hay UNTXLogHelper).
 *  - Aumentar Campos / Diametro / Teletransportar / Renombrar siguen
 *    usando Materia Oscura (NO cambian).
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

class PlanetHelper
{
    const UNTX_MULTIPLIER = 2; // ← ÚNICO lugar de la regla × 2 para QVAPAY

    const BUILDER_PRICES = [
        1 => 6,
        2 => 7,
        3 => 8,
        4 => 9,
        5 => 10,
    ];
    const BUILDER_MAX = 5;

    const ENGINEER_PRICES = [
        1 => 6,
        2 => 8,
        3 => 10,
    ];
    const ENGINEER_MAX = 3;

    const MOON_PRICE_NTX       = 250;
    const FIELD_PRICE_MO       = 200;
    const DIAMETER_PRICE_MO    = 400;
    const TELEPORT_PRICE_MO    = 20000;
    const FIELD_MAX            = 500;
    const DIAMETER_MAX         = 21447;
    const TELEPORT_COOLDOWN    = 86400;
    const RENAME_COOLDOWN      = 60;
    const RENAME_MAX_CHARS     = 20;

    private static function db()
    {
        return Database::get();
    }

    private static function prefix()
    {
        return DB_PREFIX;
    }

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

    // ==========================================
    // DUAL RIEL — Métodos públicos y privados
    // ==========================================

    /**
     * Devuelve 'QVAPAY' o 'CUP' según el metodo_retiro del jugador.
     * Fail-safe a 'CUP' si hay error de BD.
     */
    public static function getPlayerMethod($userId)
    {
        $db     = self::db();
        $prefix = self::prefix();
        try {
            $row = $db->selectSingle(
                "SELECT metodo_retiro FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
                [':uid' => (int) $userId]
            );
            return ($row && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
        } catch (Exception $e) {
            return 'CUP';
        }
    }

    /**
     * ¿El jugador es internacional (paga con UNTX-20)?
     */
    public static function isIntl($userId)
    {
        return self::getPlayerMethod($userId) === 'QVAPAY';
    }

    /**
     * Etiqueta de la moneda según el riel del jugador.
     */
    public static function getCurrencyLabel($userId)
    {
        return self::isIntl($userId) ? 'UNTX-20' : 'NTX-20';
    }

    /**
     * Columna de saldo del jugador ('untx20' o 'ntx20').
     */
    public static function getBalanceColumn($userId)
    {
        return self::isIntl($userId) ? 'untx20' : 'ntx20';
    }

    /**
     * Aplica el multiplicador ×2 si es internacional.
     */
    private static function applyMultiplier($basePrice, $isIntl)
    {
        return $isIntl ? ((int) $basePrice * self::UNTX_MULTIPLIER) : (int) $basePrice;
    }

    /**
     * Extrae los datos de dual-riel desde una fila de usuario ya cargada.
     * Devuelve array con isIntl, colBalance, moneda, balance.
     */
    private static function extractDualRail($row)
    {
        $isIntl     = isset($row['metodo_retiro']) && $row['metodo_retiro'] === 'QVAPAY';
        $colBalance = $isIntl ? 'untx20' : 'ntx20';
        $moneda     = $isIntl ? 'UNTX-20' : 'NTX-20';
        $balance    = (int) ($row[$colBalance] ?? 0);

        return [
            'isIntl'     => $isIntl,
            'colBalance' => $colBalance,
            'moneda'     => $moneda,
            'balance'    => $balance,
        ];
    }

    // ==========================================
    // GETTERS GENERALES
    // ==========================================

    public static function getPlanet($planetId)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $planetId = (int) $planetId;

        return $db->selectSingle(
            "SELECT * FROM `".$prefix."planets` WHERE id = :pid",
            [':pid' => $planetId]
        );
    }

    public static function getConfig()
    {
        $db = self::db();

        return $db->selectSingle(
            "SELECT max_elements_build, max_elements_tech 
             FROM `".self::prefix()."config` LIMIT 1"
        );
    }

    public static function getBuildQueues($planet)
    {
        $config = self::getConfig();
        $base   = (int) $config['max_elements_build'];

        return $base + (int) $planet['droids_builder'];
    }

    public static function getTechQueues($planet)
    {
        $config = self::getConfig();
        $base   = (int) $config['max_elements_tech'];

        return $base + (int) $planet['droids_engineer'];
    }

    // ==========================================
    // COMPRAR DROIDE CONSTRUCTOR (dual riel)
    // ==========================================
    public static function buyBuilder($userId, $planetId)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;

        // Query ampliada con las columnas de dual-riel
        $planet = $db->selectSingle(
            "SELECT p.*, u.ntx20, u.untx20, u.metodo_retiro
             FROM `".$prefix."planets` p
             INNER JOIN `".$prefix."users` u ON u.id = p.id_owner
             WHERE p.id = :pid AND p.id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($planet)) {
            throw new Exception('Planeta no encontrado.');
        }

        $nextLevel = (int) $planet['droids_builder'] + 1;

        if ($nextLevel > self::BUILDER_MAX) {
            throw new Exception('Ya tienes el maximo de Droides Constructores ('.self::BUILDER_MAX.').');
        }

        // Dual riel
        $dr         = self::extractDualRail($planet);
        $isIntl     = $dr['isIntl'];
        $colBalance = $dr['colBalance'];
        $moneda     = $dr['moneda'];
        $balance    = $dr['balance'];

        $priceBase  = (int) self::BUILDER_PRICES[$nextLevel];
        $priceFinal = self::applyMultiplier($priceBase, $isIntl);

        if ($balance < $priceFinal) {
            throw new Exception($moneda.' insuficiente. Necesitas '.number_format($priceFinal).' '.$moneda.'.');
        }

        $db->query(
            "UPDATE `".$prefix."users` 
             SET `".$colBalance."` = GREATEST(0, `".$colBalance."` - ".$priceFinal.") 
             WHERE id = ".$userId
        );
        $db->query(
            "UPDATE `".$prefix."planets` 
             SET droids_builder = droids_builder + 1 
             WHERE id = ".$planetId
        );

        // Log solo para CUP (no hay UNTXLogHelper)
        if (!$isIntl) {
            self::logNtx20(
                $userId,
                -$priceFinal,
                'planet_droid',
                'Droide Constructor nivel '.$nextLevel,
                $planetId
            );
        }

        if (isset($GLOBALS['USER'])) {
            $GLOBALS['USER'][$colBalance] = max(0, (int) $GLOBALS['USER'][$colBalance] - $priceFinal);
        }
        if (isset($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['droids_builder'] = $nextLevel;
        }

        return $priceFinal;
    }

    // ==========================================
    // COMPRAR DROIDE INGENIERO (dual riel)
    // ==========================================
    public static function buyEngineer($userId, $planetId)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;

        $planet = $db->selectSingle(
            "SELECT p.*, u.ntx20, u.untx20, u.metodo_retiro
             FROM `".$prefix."planets` p
             INNER JOIN `".$prefix."users` u ON u.id = p.id_owner
             WHERE p.id = :pid AND p.id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($planet)) {
            throw new Exception('Planeta no encontrado.');
        }

        $nextLevel = (int) $planet['droids_engineer'] + 1;

        if ($nextLevel > self::ENGINEER_MAX) {
            throw new Exception('Ya tienes el maximo de Droides Ingenieros ('.self::ENGINEER_MAX.').');
        }

        // Dual riel
        $dr         = self::extractDualRail($planet);
        $isIntl     = $dr['isIntl'];
        $colBalance = $dr['colBalance'];
        $moneda     = $dr['moneda'];
        $balance    = $dr['balance'];

        $priceBase  = (int) self::ENGINEER_PRICES[$nextLevel];
        $priceFinal = self::applyMultiplier($priceBase, $isIntl);

        if ($balance < $priceFinal) {
            throw new Exception($moneda.' insuficiente. Necesitas '.number_format($priceFinal).' '.$moneda.'.');
        }

        $db->query(
            "UPDATE `".$prefix."users` 
             SET `".$colBalance."` = GREATEST(0, `".$colBalance."` - ".$priceFinal.") 
             WHERE id = ".$userId
        );
        $db->query(
            "UPDATE `".$prefix."planets` 
             SET droids_engineer = droids_engineer + 1 
             WHERE id = ".$planetId
        );

        if (!$isIntl) {
            self::logNtx20(
                $userId,
                -$priceFinal,
                'planet_droid',
                'Droide Ingeniero nivel '.$nextLevel,
                $planetId
            );
        }

        if (isset($GLOBALS['USER'])) {
            $GLOBALS['USER'][$colBalance] = max(0, (int) $GLOBALS['USER'][$colBalance] - $priceFinal);
        }
        if (isset($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['droids_engineer'] = $nextLevel;
        }

        return $priceFinal;
    }

    // ==========================================
    // CREAR LUNA (dual riel)
    // ==========================================
    public static function createMoon($userId, $planetId)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;

        // 1) VALIDACIONES — query ampliada con dual-riel
        $planet = $db->selectSingle(
            "SELECT p.*, u.ntx20, u.untx20, u.metodo_retiro
             FROM `".$prefix."planets` p
             INNER JOIN `".$prefix."users` u ON u.id = p.id_owner
             WHERE p.id = :pid AND p.id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($planet)) {
            throw new Exception('Planeta no encontrado.');
        }

        if ((int) $planet['planet_type'] === 3) {
            throw new Exception('No puedes crear una luna en una luna.');
        }

        // CAMBIO: planet_type = '3' CON COMILLAS
        $exists = $db->selectSingle(
            "SELECT id FROM `".$prefix."planets` 
             WHERE galaxy = :g AND system = :s AND planet = :p 
               AND planet_type = '3'",
            [':g' => $planet['galaxy'], ':s' => $planet['system'], ':p' => $planet['planet']]
        );

        if (!empty($exists)) {
            throw new Exception('Este planeta ya tiene una luna.');
        }

        // Dual riel
        $dr         = self::extractDualRail($planet);
        $isIntl     = $dr['isIntl'];
        $colBalance = $dr['colBalance'];
        $moneda     = $dr['moneda'];
        $balance    = $dr['balance'];

        $priceFinal = self::applyMultiplier(self::MOON_PRICE_NTX, $isIntl);

        if ($balance < $priceFinal) {
            throw new Exception($moneda.' insuficiente. Necesitas '.number_format($priceFinal).' '.$moneda.'.');
        }

        // 2) PREPARAR DATOS
        $diameter = rand(1000, 15000);

        $rawName  = 'Luna de '.$planet['name'];
        $moonName = mb_substr($rawName, 0, 20, 'UTF-8');
        $moonNameSql = addslashes($moonName);

        $universe = isset($planet['universe']) && $planet['universe'] !== null
            ? (int) $planet['universe']
            : 1;

        $g = (int) $planet['galaxy'];
        $s = (int) $planet['system'];
        $p = (int) $planet['planet'];

        $moonImage = 'mond';

        // 3) INSERT DE LA LUNA
        $db->query(
            "INSERT INTO `".$prefix."planets` 
             (`id_owner`, `name`, `universe`, `galaxy`, `system`, `planet`,
              `planet_type`, `destruyed`, `image`,
              `diameter`, `field_max`, `field_current`,
              `temp_min`, `temp_max`,
              `metal`, `crystal`, `deuterium`,
              `metal_perhour`, `crystal_perhour`, `deuterium_perhour`,
              `energy_used`, `energy`,
              `eco_hash`,
              `id_luna`, `last_update`,
              `droids_builder`, `droids_engineer`,
              `last_teleport`, `last_rename`)
             VALUES 
             (".$userId.", '".$moonNameSql."', ".$universe.", ".$g.", ".$s.", ".$p.",
              '3', 0, '".$moonImage."',
              ".$diameter.", 1, 0,
              -20, 0,
              0, 0, 0,
              0, 0, 0,
              0, 0,
              '',
              0, ".TIMESTAMP.",
              0, 0,
              0, 0)"
        );

        // 4) OBTENER EL ID DE LA LUNA
        $moonRow = $db->selectSingle(
            "SELECT id FROM `".$prefix."planets` 
             WHERE id_owner = :uid 
               AND galaxy   = :g 
               AND system   = :s 
               AND planet   = :p 
               AND planet_type = '3'",
            [
                ':uid' => $userId,
                ':g'   => $g,
                ':s'   => $s,
                ':p'   => $p
            ]
        );

        if (empty($moonRow) || empty($moonRow['id'])) {
            throw new Exception('La luna no se pudo localizar tras el INSERT.');
        }

        $moonId = (int) $moonRow['id'];

        // 5) ENLAZAR planeta <-> luna
        $db->query(
            "UPDATE `".$prefix."planets` SET id_luna = ".$moonId." WHERE id = ".$planetId
        );
        $db->query(
            "UPDATE `".$prefix."planets` SET id_luna = ".$planetId." WHERE id = ".$moonId
        );

        // 6) DESCONTAR (columna correcta)
        $db->query(
            "UPDATE `".$prefix."users` 
             SET `".$colBalance."` = GREATEST(0, `".$colBalance."` - ".$priceFinal.") 
             WHERE id = ".$userId
        );

        // 7) LOG + GLOBALS
        if (!$isIntl) {
            self::logNtx20(
                $userId,
                -$priceFinal,
                'planet_moon',
                'Creacion de Luna (diametro '.number_format($diameter).')',
                $planetId
            );
        }

        if (isset($GLOBALS['USER'])) {
            $GLOBALS['USER'][$colBalance] = max(0, (int) $GLOBALS['USER'][$colBalance] - $priceFinal);
        }
        if (isset($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['id_luna'] = $moonId;
        }

        return $diameter;
    }

    // ==========================================
    // AUMENTAR CAMPOS (MO — sin cambios)
    // ==========================================
    public static function increaseFields($userId, $planetId, $amount)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;
        $amount   = (int) $amount;

        if ($amount <= 0) {
            throw new Exception('Cantidad invalida.');
        }

        $planet = $db->selectSingle(
            "SELECT p.*, u.darkmatter 
             FROM `".$prefix."planets` p
             INNER JOIN `".$prefix."users` u ON u.id = p.id_owner
             WHERE p.id = :pid AND p.id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($planet)) {
            throw new Exception('Planeta no encontrado.');
        }

        $newTotal = (int) $planet['field_max'] + $amount;
        if ($newTotal > self::FIELD_MAX) {
            throw new Exception('Limite maximo de campos alcanzado ('.self::FIELD_MAX.').');
        }

        $cost = (int) ($amount * self::FIELD_PRICE_MO);

        if ((int) $planet['darkmatter'] < $cost) {
            throw new Exception('Materia Oscura insuficiente. Necesitas '.number_format($cost).' MO.');
        }

        $db->query("UPDATE `".$prefix."users` SET darkmatter = GREATEST(0, darkmatter - ".$cost.") WHERE id = ".$userId);
        $db->query("UPDATE `".$prefix."planets` SET field_max = field_max + ".$amount." WHERE id = ".$planetId);

        if (isset($GLOBALS['USER'])) {
            $GLOBALS['USER']['darkmatter'] = max(0, $GLOBALS['USER']['darkmatter'] - $cost);
        }
        if (isset($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['field_max'] = $newTotal;
        }

        return $cost;
    }

    // ==========================================
    // AUMENTAR DIAMETRO (MO — sin cambios)
    // ==========================================
    public static function increaseDiameter($userId, $planetId, $amount)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;
        $amount   = (int) $amount;

        if ($amount <= 0) {
            throw new Exception('Cantidad invalida.');
        }

        $planet = $db->selectSingle(
            "SELECT p.*, u.darkmatter 
             FROM `".$prefix."planets` p
             INNER JOIN `".$prefix."users` u ON u.id = p.id_owner
             WHERE p.id = :pid AND p.id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($planet)) {
            throw new Exception('Planeta no encontrado.');
        }

        $newTotal = (int) $planet['diameter'] + $amount;
        if ($newTotal > self::DIAMETER_MAX) {
            throw new Exception('Limite maximo de diametro alcanzado ('.number_format(self::DIAMETER_MAX).').');
        }

        $cost = (int) ($amount * self::DIAMETER_PRICE_MO);

        if ((int) $planet['darkmatter'] < $cost) {
            throw new Exception('Materia Oscura insuficiente. Necesitas '.number_format($cost).' MO.');
        }

        $db->query("UPDATE `".$prefix."users` SET darkmatter = GREATEST(0, darkmatter - ".$cost.") WHERE id = ".$userId);
        $db->query("UPDATE `".$prefix."planets` SET diameter = diameter + ".$amount." WHERE id = ".$planetId);

        if (isset($GLOBALS['USER'])) {
            $GLOBALS['USER']['darkmatter'] = max(0, $GLOBALS['USER']['darkmatter'] - $cost);
        }
        if (isset($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['diameter'] = $newTotal;
        }

        return $cost;
    }

    // ==========================================
    // TELETRANSPORTAR (MO — sin cambios)
    // ==========================================
    public static function teleport($userId, $planetId, $galaxy, $system, $planet)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;
        $galaxy   = (int) $galaxy;
        $system   = (int) $system;
        $planet   = (int) $planet;

        if ($galaxy < 1 || $system < 1 || $planet < 1) {
            throw new Exception('Coordenadas invalidas.');
        }

        $p = $db->selectSingle(
            "SELECT p.*, u.darkmatter 
             FROM `".$prefix."planets` p
             INNER JOIN `".$prefix."users` u ON u.id = p.id_owner
             WHERE p.id = :pid AND p.id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($p)) {
            throw new Exception('Planeta no encontrado.');
        }

        if ((TIMESTAMP - (int) $p['last_teleport']) < self::TELEPORT_COOLDOWN) {
            $remaining = self::TELEPORT_COOLDOWN - (TIMESTAMP - (int) $p['last_teleport']);
            throw new Exception('Debes esperar '.floor($remaining / 60).' minutos antes de teletransportar de nuevo.');
        }

        $planetType = (int) $p['planet_type'];

        $exists = $db->selectSingle(
            "SELECT id FROM `".$prefix."planets` 
             WHERE galaxy = :g AND system = :s AND planet = :p 
               AND planet_type = :pt",
            [':g' => $galaxy, ':s' => $system, ':p' => $planet, ':pt' => $planetType]
        );

        if (!empty($exists)) {
            throw new Exception('La posicion destino ya esta ocupada.');
        }

        if ((int) $p['darkmatter'] < self::TELEPORT_PRICE_MO) {
            throw new Exception('Materia Oscura insuficiente. Necesitas '.number_format(self::TELEPORT_PRICE_MO).' MO.');
        }

        $db->query("UPDATE `".$prefix."users` SET darkmatter = GREATEST(0, darkmatter - ".self::TELEPORT_PRICE_MO.") WHERE id = ".$userId);

        $db->query(
            "UPDATE `".$prefix."planets` 
             SET galaxy = ".$galaxy.", system = ".$system.", planet = ".$planet.", 
                 last_teleport = ".TIMESTAMP." 
             WHERE id = ".$planetId
        );

        $oldGal = (int) $p['galaxy'];
        $oldSys = (int) $p['system'];
        $oldPl  = (int) $p['planet'];

        $db->query(
            "UPDATE `".$prefix."fleets` 
             SET fleet_end_galaxy = ".$galaxy.", 
                 fleet_end_system = ".$system.", 
                 fleet_end_planet = ".$planet." 
             WHERE fleet_end_galaxy = ".$oldGal." 
               AND fleet_end_system = ".$oldSys." 
               AND fleet_end_planet = ".$oldPl." 
               AND fleet_end_id = ".$planetId
        );

        if (isset($GLOBALS['USER'])) {
            $GLOBALS['USER']['darkmatter'] = max(0, $GLOBALS['USER']['darkmatter'] - self::TELEPORT_PRICE_MO);
        }
        if (isset($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['galaxy'] = $galaxy;
            $GLOBALS['PLANET']['system'] = $system;
            $GLOBALS['PLANET']['planet'] = $planet;
            $GLOBALS['PLANET']['last_teleport'] = TIMESTAMP;
        }

        return true;
    }

    // ==========================================
    // RENOMBRAR (gratis — sin cambios)
    // ==========================================
    public static function rename($userId, $planetId, $newName)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;

        $newName = trim($newName);

        if (empty($newName)) {
            throw new Exception('El nombre no puede estar vacio.');
        }

        if (mb_strlen($newName) > self::RENAME_MAX_CHARS) {
            throw new Exception('El nombre no puede superar los '.self::RENAME_MAX_CHARS.' caracteres.');
        }

        $p = $db->selectSingle(
            "SELECT * FROM `".$prefix."planets` WHERE id = :pid AND id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($p)) {
            throw new Exception('Planeta no encontrado.');
        }

        if ((TIMESTAMP - (int) $p['last_rename']) < self::RENAME_COOLDOWN) {
            $remaining = self::RENAME_COOLDOWN - (TIMESTAMP - (int) $p['last_rename']);
            throw new Exception('Debes esperar '.$remaining.' segundos antes de renombrar de nuevo.');
        }

        $newNameSql = addslashes($newName);

        $db->query(
            "UPDATE `".$prefix."planets` 
             SET name = '".$newNameSql."', last_rename = ".TIMESTAMP." 
             WHERE id = ".$planetId
        );

        if (isset($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['name'] = $newName;
            $GLOBALS['PLANET']['last_rename'] = TIMESTAMP;
        }

        return $newName;
    }

    public static function generateName()
    {
        $prefixes = ['Nova', 'Astra', 'Orion', 'Vega', 'Lyra', 'Titan', 'Atlas', 'Kronos', 'Phoenix', 'Zenith'];
        $suffixes = ['Prime', 'Alpha', 'Beta', 'Gamma', 'Delta', 'Omega', 'Ultra', 'Nexus', 'Core', 'Star'];

        return $prefixes[array_rand($prefixes)].' '.$suffixes[array_rand($suffixes)];
    }

    // ==========================================
    // ABANDONAR (gratis — sin cambios)
    // ==========================================
    public static function abandon($userId, $planetId)
    {
        $db     = self::db();
        $prefix = self::prefix();
        $userId   = (int) $userId;
        $planetId = (int) $planetId;

        $count = $db->selectSingle(
            "SELECT COUNT(*) AS total FROM `".$prefix."planets` 
             WHERE id_owner = :uid AND planet_type = '1'",
            [':uid' => $userId]
        );

        if ((int) $count['total'] <= 1) {
            throw new Exception('No puedes abandonar tu ultimo planeta.');
        }

        $p = $db->selectSingle(
            "SELECT * FROM `".$prefix."planets` WHERE id = :pid AND id_owner = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        if (empty($p)) {
            throw new Exception('Planeta no encontrado.');
        }

        $otherPlanet = $db->selectSingle(
            "SELECT id, galaxy, system, planet FROM `".$prefix."planets` 
             WHERE id_owner = :uid AND id != :pid AND planet_type = '1' LIMIT 1",
            [':uid' => $userId, ':pid' => $planetId]
        );

        if (!empty($otherPlanet)) {
            $oid = (int) $otherPlanet['id'];
            $og  = (int) $otherPlanet['galaxy'];
            $os  = (int) $otherPlanet['system'];
            $op  = (int) $otherPlanet['planet'];

            $db->query(
                "UPDATE `".$prefix."fleets` 
                 SET fleet_end_galaxy = ".$og.", 
                     fleet_end_system = ".$os.", 
                     fleet_end_planet = ".$op.", 
                     fleet_end_id = ".$oid." 
                 WHERE fleet_end_id = ".$planetId." AND fleet_mess = 0"
            );
        }

        $g = (int) $p['galaxy'];
        $s = (int) $p['system'];
        $pl = (int) $p['planet'];

        // planet_type = '3' CON COMILLAS
        $db->query(
            "DELETE FROM `".$prefix."planets` 
             WHERE (id = ".$planetId." 
                    OR (galaxy = ".$g." AND system = ".$s." AND planet = ".$pl." AND planet_type = '3'))
               AND id_owner = ".$userId
        );

        return true;
    }
}