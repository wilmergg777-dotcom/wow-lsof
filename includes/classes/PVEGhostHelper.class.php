<?php

/**
 * PVEGhostHelper — AstroIO v2.4
 *
 * Gestiona cuentas fantasma para imperios/crisis PvE y torneos Boss.
 * Mapa ID → columna HARDCODEADO + UPDATE por columna (más robusto).
 *
 * CAMBIOS v2.3:
 *  - Añadido createGhostForBoss() → soporta N fantasmas por evento (torneo Boss)
 *  - Refactorizado createGhost() → delega en createGhostWithCustomId() privado
 *  - Añadido createGhostWithCustomId() privado con toda la lógica real
 *  - Añadido destroyGhostByUserId() → elimina por user_id (para multi-fantasma)
 *  - Compatibilidad total con Empire y Crisis (sin cambios en API externa)
 *
 * CAMBIO v2.2:
 *  - getTableName() ahora es PUBLIC
 *  - $columnMap ahora es PUBLIC
 *  (para que MissionCasePveEmpire pueda usarlos al leer/escribir naves del fantasma)
 *
 * v2.4 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Este helper NO toca NTX-20 ni UNTX-20 en ningún punto.
 *   · Los fantasmas son cuentas `is_pve = 1` creadas por el sistema para
 *     representar imperios/jefes del Torneo. NO son jugadores reales:
 *       - No tienen `metodo_retiro` (o lo tienen NULL/vacío → getPlayerMethod()
 *         devuelve 'CUP' por fail-safe, pero nunca se llama para fantasmas)
 *       - No compran nada (no pagan entradas, no gastan NTX)
 *       - No reclaman recompensas (las recompensas van a los jugadores reales
 *         que los atacan, no al fantasma)
 *   · `userData` no inicializa `ntx20` ni `untx20` → se quedan en el default
 *     de BD (0). Es lo correcto: los fantasmas no necesitan saldo.
 *   · `destroyGhost*()` hace DELETE de fleets/statpoints/planets/users y NO
 *     toca `ntx20`/`untx20` de nadie (solo borra la fila del fantasma).
 *   · Se añaden las constantes UNTX_MULTIPLIER y RIELS por coherencia con el
 *     resto de helpers PvE/PvP, aunque este archivo no las use funcionalmente.
 *
 * @package AstroIO
 * @subpackage PvE
 * @version 2.4
 */

class PVEGhostHelper
{
    /* ============================================================
     *  CONSTANTES
     * ============================================================ */

    // Regla ×2 centralizada (por coherencia con el resto de helpers PvE/PvP)
    const UNTX_MULTIPLIER = 2;

    // Rieles válidos
    const RIELS = array('CUP', 'QVAPAY');

    const ID_BASE = 900000000;

    private static $columnsCache = array();

    /**
     * Mapa ID → nombre de columna real en uni1_planets.
     * PÚBLICO para que otras clases (MissionCasePveEmpire) puedan usarlo.
     */
    public static $columnMap = array(
        // ─── NAVES ───
        202 => 'small_ship_cargo',
        203 => 'big_ship_cargo',
        204 => 'light_hunter',
        205 => 'heavy_hunter',
        206 => 'crusher',
        207 => 'battle_ship',
        208 => 'colonizer',
        209 => 'recycler',
        210 => 'spy_sonde',
        211 => 'bomber_ship',
        212 => 'solar_satelit',
        213 => 'destructor',
        214 => 'dearth_star',
        215 => 'battleship',
        216 => 'lune_noir',
        217 => 'ev_transporter',
        218 => 'star_crasher',
        219 => 'giga_recykler',
        220 => 'dm_ship',
        221 => 'orbital_station',
        222 => 'star_titan',
        223 => 'war_colossus',
        224 => 'elite_battleship',
        225 => 'heavy_frigate',

        // ─── DEFENSAS ───
        401 => 'misil_launcher',
        402 => 'small_laser',
        403 => 'big_laser',
        404 => 'gauss_canyon',
        405 => 'ionic_canyon',
        406 => 'buster_canyon',
        407 => 'small_protection_shield',
        408 => 'planet_protector',
        409 => 'big_protection_shield',
        410 => 'graviton_canyon',
        411 => 'interceptor_misil',
        412 => 'interplanetary_misil',
        413 => 'antimatter_misil',
        414 => 'advanced_interceptor_misil',
        415 => 'rail_turret',
        416 => 'antimatter_canyon',
        417 => 'star_bastion',
        418 => 'deflector_shield',

        // ─── EDIFICIOS ───
        1  => 'metal_mine',
        2  => 'crystal_mine',
        3  => 'deuterium_sintetizer',
        4  => 'solar_plant',
        5  => 'fusion_plant',
        6  => 'robot_factory',
        7  => 'nano_factory',
        8  => 'hangar',
        9  => 'metal_store',
        10 => 'crystal_store',
        11 => 'deuterium_store',
        12 => 'laboratory',
        13 => 'terraformer',
        14 => 'ally_deposit',
        15 => 'silo',
        16 => 'mondbasis',
        17 => 'phalanx',
        18 => 'sprungtor',
        19 => 'university',
    );

    // ═══════════════════════════════════════════════════════════════
    //  UTILIDADES
    // ═══════════════════════════════════════════════════════════════

    /**
     * Devuelve el nombre real de una tabla (con prefijo).
     * PÚBLICO para que MissionCasePveEmpire pueda usarlo.
     */
    public static function getTableName(string $suffix): string
    {
        $prefix = 'uni1_';
        if (defined('DB_PREFIX') && DB_PREFIX !== '') {
            $prefix = DB_PREFIX;
        } elseif (defined('PREFIX') && PREFIX !== '') {
            $prefix = PREFIX;
        }
        return $prefix . $suffix;
    }

    private static function getTableColumns(string $tableName): array
    {
        if (isset(self::$columnsCache[$tableName])) {
            return self::$columnsCache[$tableName];
        }

        $db = Database::get();
        $cols = array();

        try {
            $dbName = defined('DB_NAME') ? DB_NAME : 'prueba';

            $rows = $db->select(
                "SELECT COLUMN_NAME AS col
                 FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = :db
                   AND TABLE_NAME   = :tbl;",
                array(':db' => $dbName, ':tbl' => $tableName)
            );

            if (is_array($rows)) {
                foreach ($rows as $r) {
                    if (!empty($r['col'])) {
                        $cols[] = $r['col'];
                    }
                }
            }
        } catch (Throwable $e) {}

        if (empty($cols)) {
            try {
                $rows = $db->select("SELECT * FROM `" . $tableName . "` LIMIT 1;");
                if (is_array($rows) && count($rows) > 0 && is_array($rows[0])) {
                    $cols = array_keys($rows[0]);
                }
            } catch (Throwable $e) {}
        }

        self::$columnsCache[$tableName] = $cols;
        return $cols;
    }

    private static function insertFiltered(string $tableName, array $data): int
    {
        $db = Database::get();
        $existing = self::getTableColumns($tableName);

        if (empty($existing)) {
            throw new Exception("Tabla `{$tableName}` no existe o sin columnas detectables.");
        }

        $cols = array();
        $vals = array();
        $params = array();

        foreach ($data as $col => $val) {
            if (!in_array($col, $existing, true)) continue;

            $param = ':c_' . $col;
            $cols[] = '`' . $col . '`';
            $vals[] = $param;
            $params[$param] = $val;
        }

        if (empty($cols)) {
            throw new Exception("Ninguna columna válida para insertar en `{$tableName}`.");
        }

        $sql = "INSERT INTO `{$tableName}` (" . implode(', ', $cols) . ") VALUES (" . implode(', ', $vals) . ");";
        $db->insert($sql, $params);

        return (int) $db->lastInsertId();
    }

    // ═══════════════════════════════════════════════════════════════
    //  CREACIÓN
    // ═══════════════════════════════════════════════════════════════

    public static function createGhostForEmpire(int $empireId, array $data): array
    {
        return self::createGhost('empire', $empireId, $data);
    }

    public static function createGhostForCrisis(int $crisisId, array $data): array
    {
        return self::createGhost('crisis', $crisisId, $data);
    }

    /**
     * Crea un fantasma del TORNEO DEL DEVORADOR.
     *
     * Diferencia clave vs createGhostForEmpire():
     *   - Empire/Crisis: usan ID_BASE + eventId (1 fantasma por evento).
     *   - Boss Tournament: usa ID_BASE + (eventId * 1000) + registrationId
     *     para permitir hasta 1000 fantasmas distintos por evento
     *     (uno por cada alianza inscrita).
     *
     * @param int   $eventId        ID del evento en uni1_pve_boss_event
     * @param int   $registrationId ID de la registration en uni1_pve_boss_registrations
     * @param array $data           Mismos campos que createGhostForEmpire()
     *                              (name, galaxy, system, planet, hp, metal,
     *                               crystal, deuterium, ships, defenses, buildings)
     * @param int   $idBase         ✅ v3.8 Base de IDs del sistema llamante.
     *                              Por defecto ID_BASE (900000000, Torneo del
     *                              Devorador). PVEBastionHelper pasa su
     *                              ID_BASE_BASTION (950000000) para que un
     *                              Bastión y un Boss con el mismo (eventId,
     *                              registrationId) NO colisionen en
     *                              uni*_users.id / uni*_planets.id (antes el
     *                              segundo INSERT fallaba y la alianza se
     *                              quedaba sin evento, silenciosamente).
     * @return array ['user_id'=>int, 'planet_id'=>int]
     */
    public static function createGhostForBoss(int $eventId, int $registrationId, array $data, ?int $idBase = null): array
    {
        $base     = ($idBase !== null && $idBase > 0) ? $idBase : self::ID_BASE;
        $uniqueId = $base + ($eventId * 1000) + $registrationId;

        return self::createGhostWithCustomId('boss', $eventId, $uniqueId, $data);
    }

    /**
     * Wrapper de compatibilidad para Empire/Crisis.
     * Calcula el ID como ID_BASE + eventId y delega en createGhostWithCustomId().
     */
    private static function createGhost(string $eventType, int $eventId, array $data): array
    {
        $uniqueId = self::ID_BASE + $eventId;

        return self::createGhostWithCustomId($eventType, $eventId, $uniqueId, $data);
    }

    /**
     * Lógica real de creación de un fantasma con ID personalizado.
     * Usado por createGhost() (Empire/Crisis) y createGhostForBoss() (Torneo).
     *
     * v2.4 — DOBLE RIEL: NO APLICA.
     *
     *   Los fantasmas NO son jugadores reales:
     *     - `is_pve = 1` → filtrados en todas las queries de ataques
     *     - No tienen `metodo_retiro` → nunca pasan por getPlayerMethod()
     *     - No compran entradas ni reclaman recompensas
     *     - No tienen `ntx20` ni `untx20` inicializados (default 0 en BD)
     *
     *   Por eso aquí NO hay:
     *     - getPlayerMethod() / isIntl() / getCurrencyLabel()
     *     - getPrecioParaJugador() / getPremioParaJugador()
     *     - addBalance() / removeBalance()
     *     - WalletHelper::addNxt20() / NTX20LogHelper::log()
     *
     *   `userData` deja `ntx20` y `untx20` en los defaults de la BD (0).
     *   Si en algún momento se quisiera dar saldo inicial al fantasma
     *   (por ejemplo para simular una economía interna), habría que:
     *     1. Añadir 'ntx20' => 0 explícito en $userData (documental)
     *     2. Decidir si es CUP o QVAPAY (aunque no tiene sentido — no
     *        interactúa con el sistema de pagos)
     *   Pero eso NO es lo que hace el código actual ni lo que necesita.
     *
     * @param string $eventType Tipo de evento: 'empire' | 'crisis' | 'boss'
     * @param int    $eventId   ID REAL del evento (se guarda en pve_ghosts.event_id)
     * @param int    $uniqueId  ID único calculado para user_id y planet_id
     * @param array  $data      Datos del fantasma
     * @return array ['user_id'=>int, 'planet_id'=>int]
     */
    private static function createGhostWithCustomId(
        string $eventType, int $eventId, int $uniqueId, array $data
    ): array {
        $db       = Database::get();
        $userId   = $uniqueId;
        $planetId = $uniqueId;
        $now      = TIMESTAMP;
        $universe = Universe::current();

        $name      = $data['name']      ?? ('[PvE] Event ' . $eventId);
        $galaxy    = (int) ($data['galaxy']    ?? 1);
        $system    = (int) ($data['system']    ?? 1);
        $planetPos = (int) ($data['planet']    ?? 1);
        $hp        = (int) ($data['hp']        ?? 1000000);
        $metal     = (float) ($data['metal']     ?? 0);
        $crystal   = (float) ($data['crystal']   ?? 0);
        $deuterium = (float) ($data['deuterium'] ?? 0);
        $ships     = is_array($data['ships']     ?? null) ? $data['ships']     : array();
        $defenses  = is_array($data['defenses']  ?? null) ? $data['defenses']  : array();
        $buildings = is_array($data['buildings'] ?? null) ? $data['buildings'] : array();

        // Email único por fantasma (usa $uniqueId para evitar colisión con multi-fantasma)
        $email  = 'pve.' . $eventType . '.' . $uniqueId . '@noreply.local';
        $fakeIp = '127.0.0.1';

        // ─── 1) USUARIO FANTASMA ───
        // ⚠️ Sin ntx20/untx20 explícitos → quedan en default de BD (0).
        //    Los fantasmas no participan del sistema dual-riel.
        $usersTable = self::getTableName('users');

        $userData = array(
            'id'              => $userId,
            'username'        => mb_substr($name, 0, 30),
            'password'        => bin2hex(random_bytes(30)),
            'email'           => $email,
            'email_2'         => $email,
            'lang'            => 'es',
            'authattack'      => 0,
            'authlevel'       => 0,
            'is_pve'          => 1,
            'pve_event_type'  => $eventType,
            'pve_event_id'    => $eventId,
            'id_planet'       => 0,
            'universe'        => $universe,
            'galaxy'          => $galaxy,
            'system'          => $system,
            'planet'          => $planetPos,
            'darkmatter'      => 0,
            'user_lastip'     => $fakeIp,
            'ip_at_reg'       => $fakeIp,
            'register_time'   => $now,
            'onlinetime'      => 0,
            'dpath'           => 'gow',
            'timezone'        => 'Europe/London',
            'urlaubs_modus'   => 0,
            'bana'            => 0,
        );

        self::insertFiltered($usersTable, $userData);

        // ─── 2) PLANETA FANTASMA ───
        $planetsTable = self::getTableName('planets');

        $planetData = array(
            'id'             => $planetId,
            'id_owner'       => $userId,
            'name'           => mb_substr($name, 0, 20),
            'universe'       => $universe,
            'galaxy'         => $galaxy,
            'system'         => $system,
            'planet'         => $planetPos,
            'planet_type'    => 1,
            'is_pve'         => 1,
            'pve_event_type' => $eventType,
            'pve_event_id'   => $eventId,
            'last_update'    => $now,
            'destruyed'      => 0,
            'metal'          => $metal,
            'crystal'        => $crystal,
            'deuterium'      => $deuterium,
            'metal_max'      => max(100000, (int) $metal),
            'crystal_max'    => max(100000, (int) $crystal),
            'deuterium_max'  => max(100000, (int) $deuterium),
            'energy'         => 0,
            'energy_used'    => 0,
            'field_current'  => 0,
            'field_max'      => 9999,
            'temp_min'       => 0,
            'temp_max'       => 0,
            'diameter'       => 10000,
            'eco_hash'       => md5((string) $planetId . '_' . $now),
            'image'          => 'trockenplanet06',
            'id_luna'        => 0,
            'b_building'     => 0,
            'b_hangar'       => 0,
        );

        self::insertFiltered($planetsTable, $planetData);

        // ─────────────────────────────────────────────────────────
        // 3) NAVES + DEFENSAS + EDIFICIOS
        // Un UPDATE INDIVIDUAL por cada columna (robusto)
        // ─────────────────────────────────────────────────────────

        $allUnits = array();

        // Naves
        foreach ($ships as $unitId => $count) {
            $unitId = (int) $unitId;
            $count  = (int) $count;
            if ($unitId > 0 && $count > 0 && isset(self::$columnMap[$unitId])) {
                $allUnits[self::$columnMap[$unitId]] = $count;
            }
        }

        // Defensas
        foreach ($defenses as $unitId => $count) {
            $unitId = (int) $unitId;
            $count  = (int) $count;
            if ($unitId > 0 && $count > 0 && isset(self::$columnMap[$unitId])) {
                $allUnits[self::$columnMap[$unitId]] = $count;
            }
        }

        // Edificios
        foreach ($buildings as $buildId => $level) {
            $buildId = (int) $buildId;
            $level   = (int) $level;
            if ($buildId > 0 && $level > 0 && isset(self::$columnMap[$buildId])) {
                $allUnits[self::$columnMap[$buildId]] = $level;
            }
        }

        // Aplicar UN UPDATE por columna
        foreach ($allUnits as $colName => $value) {
            if (!preg_match('/^[a-z_][a-z0-9_]*$/i', $colName)) continue;

            try {
                $db->update(
                    "UPDATE `{$planetsTable}` SET `{$colName}` = :val WHERE id = :pid;",
                    array(':val' => $value, ':pid' => $planetId)
                );
            } catch (Throwable $e) {
                // Columna no existe → ignorar
            }
        }

        // ─── 4) STATPOINTS ───
        $statpointsTable = self::getTableName('statpoints');

        $statData = array(
            'id_owner'     => $userId,
            'stat_type'    => 1,
            'total_points' => $hp,
            'total_rank'   => 99999,
        );

        try {
            self::insertFiltered($statpointsTable, $statData);
        } catch (Throwable $e) {}

        // ─── 5) REGISTRO MAESTRO ───
        $ghostsTable = self::getTableName('pve_ghosts');

        $ghostData = array(
            'event_type'   => $eventType,
            'event_id'     => $eventId,
            'user_id'      => $userId,
            'planet_id'    => $planetId,
            'galaxy'       => $galaxy,
            'system'       => $system,
            'planet'       => $planetPos,
            'created_at'   => $now,
            'destroyed_at' => 0,
        );

        self::insertFiltered($ghostsTable, $ghostData);

        return array(
            'user_id'   => $userId,
            'planet_id' => $planetId,
        );
    }

    // ═══════════════════════════════════════════════════════════════
    //  DESTRUCCIÓN
    // ═══════════════════════════════════════════════════════════════

    /**
     * Destruye un fantasma por su event_id (Empire/Crisis).
     *
     * v2.4 — DOBLE RIEL: NO APLICA.
     *   Solo borra filas de fleets/statpoints/planets/users del fantasma.
     *   NO toca ntx20/untx20 de nadie. NO toca saldo de jugadores reales.
     */
    public static function destroyGhost(int $eventId, string $eventType = 'empire'): bool
    {
        $db       = Database::get();
        $userId   = self::ID_BASE + $eventId;
        $planetId = self::ID_BASE + $eventId;

        $fleetsTable     = self::getTableName('fleets');
        $statpointsTable = self::getTableName('statpoints');
        $planetsTable    = self::getTableName('planets');
        $usersTable      = self::getTableName('users');
        $ghostsTable     = self::getTableName('pve_ghosts');

        try { $db->delete("DELETE FROM `{$fleetsTable}` WHERE fleet_owner = :uid;", array(':uid' => $userId)); } catch (Throwable $e) {}
        try { $db->delete("DELETE FROM `{$statpointsTable}` WHERE id_owner = :uid;", array(':uid' => $userId)); } catch (Throwable $e) {}
        try { $db->delete("DELETE FROM `{$planetsTable}` WHERE id = :pid;", array(':pid' => $planetId)); } catch (Throwable $e) {}
        try { $db->delete("DELETE FROM `{$usersTable}` WHERE id = :uid;", array(':uid' => $userId)); } catch (Throwable $e) {}

        try {
            $db->update(
                "UPDATE `{$ghostsTable}` SET destroyed_at = :now WHERE user_id = :uid AND destroyed_at = 0;",
                array(':now' => TIMESTAMP, ':uid' => $userId)
            );
        } catch (Throwable $e) {}

        return true;
    }

    /**
     * Destruye un fantasma por su user_id exacto.
     *
     * Necesario para el TORNEO porque el user_id NO se calcula como
     * ID_BASE + eventId, sino como ID_BASE + (eventId * 1000) + registrationId.
     *
     * v2.4 — DOBLE RIEL: NO APLICA (mismo motivo que destroyGhost).
     *
     * @param int $userId  user_id del fantasma (>= 900M)
     * @return bool
     */
    public static function destroyGhostByUserId(int $userId): bool
    {
        if (!self::isGhostId($userId)) return false;

        $db = Database::get();

        $fleetsTable     = self::getTableName('fleets');
        $statpointsTable = self::getTableName('statpoints');
        $planetsTable    = self::getTableName('planets');
        $usersTable      = self::getTableName('users');
        $ghostsTable     = self::getTableName('pve_ghosts');

        try { $db->delete("DELETE FROM `{$fleetsTable}` WHERE fleet_owner = :uid;", array(':uid' => $userId)); } catch (Throwable $e) {}
        try { $db->delete("DELETE FROM `{$statpointsTable}` WHERE id_owner = :uid;", array(':uid' => $userId)); } catch (Throwable $e) {}
        try { $db->delete("DELETE FROM `{$planetsTable}` WHERE id_owner = :uid;", array(':uid' => $userId)); } catch (Throwable $e) {}
        try { $db->delete("DELETE FROM `{$usersTable}` WHERE id = :uid;", array(':uid' => $userId)); } catch (Throwable $e) {}

        try {
            $db->update(
                "UPDATE `{$ghostsTable}` SET destroyed_at = :now
                 WHERE user_id = :uid AND destroyed_at = 0;",
                array(':now' => TIMESTAMP, ':uid' => $userId)
            );
        } catch (Throwable $e) {}

        return true;
    }

    public static function destroyGhostsForEvent(string $eventType, int $eventId): int
    {
        $db = Database::get();
        $ghostsTable = self::getTableName('pve_ghosts');

        $ghosts = $db->select(
            "SELECT user_id, planet_id FROM `{$ghostsTable}`
             WHERE event_type = :type AND event_id = :eid
               AND destroyed_at = 0;",
            array(':type' => $eventType, ':eid' => $eventId)
        );

        if (!is_array($ghosts) || count($ghosts) === 0) {
            return 0;
        }

        $fleetsTable     = self::getTableName('fleets');
        $statpointsTable = self::getTableName('statpoints');
        $planetsTable    = self::getTableName('planets');
        $usersTable      = self::getTableName('users');

        $count = 0;
        foreach ($ghosts as $g) {
            $uid = (int) $g['user_id'];
            $pid = (int) $g['planet_id'];

            try { $db->delete("DELETE FROM `{$fleetsTable}` WHERE fleet_owner = :uid;", array(':uid' => $uid)); } catch (Throwable $e) {}
            try { $db->delete("DELETE FROM `{$statpointsTable}` WHERE id_owner = :uid;", array(':uid' => $uid)); } catch (Throwable $e) {}
            try { $db->delete("DELETE FROM `{$planetsTable}` WHERE id = :pid;", array(':pid' => $pid)); } catch (Throwable $e) {}
            try { $db->delete("DELETE FROM `{$usersTable}` WHERE id = :uid;", array(':uid' => $uid)); } catch (Throwable $e) {}

            $count++;
        }

        try {
            $db->update(
                "UPDATE `{$ghostsTable}` SET destroyed_at = :now
                 WHERE event_type = :type AND event_id = :eid AND destroyed_at = 0;",
                array(':now' => TIMESTAMP, ':type' => $eventType, ':eid' => $eventId)
            );
        } catch (Throwable $e) {}

        return $count;
    }

    // ═══════════════════════════════════════════════════════════════
    //  CONSULTAS
    // ═══════════════════════════════════════════════════════════════

    public static function getGhostIdsForEvent(string $eventType, int $eventId): array
    {
        $db = Database::get();
        $ghostsTable = self::getTableName('pve_ghosts');

        $rows = $db->select(
            "SELECT user_id, planet_id, galaxy, system, planet
             FROM `{$ghostsTable}`
             WHERE event_type = :type AND event_id = :eid AND destroyed_at = 0;",
            array(':type' => $eventType, ':eid' => $eventId)
        );
        return is_array($rows) ? $rows : array();
    }

    public static function getGhostByUserId(int $userId): ?array
    {
        if (!self::isGhostId($userId)) return null;

        $db = Database::get();
        $ghostsTable = self::getTableName('pve_ghosts');

        $row = $db->selectSingle(
            "SELECT * FROM `{$ghostsTable}` WHERE user_id = :uid AND destroyed_at = 0;",
            array(':uid' => $userId)
        );
        return !empty($row) ? $row : null;
    }

    public static function getGhostByEventId(string $eventType, int $eventId): ?array
    {
        $db = Database::get();
        $ghostsTable = self::getTableName('pve_ghosts');

        $row = $db->selectSingle(
            "SELECT * FROM `{$ghostsTable}`
             WHERE event_type = :type AND event_id = :eid AND destroyed_at = 0
             ORDER BY id ASC LIMIT 1;",
            array(':type' => $eventType, ':eid' => $eventId)
        );
        return !empty($row) ? $row : null;
    }

    public static function isGhostId(int $userId): bool
    {
        return $userId >= self::ID_BASE;
    }

    // ═══════════════════════════════════════════════════════════════
    //  LIMPIEZA
    // ═══════════════════════════════════════════════════════════════

    public static function cleanupOrphanGhosts(): int
    {
        $db = Database::get();
        $ghostsTable  = self::getTableName('pve_ghosts');
        $empiresTable = self::getTableName('pve_empires');
        $crisisTable  = self::getTableName('pve_crisis');

        $count = 0;

        try {
            $orphansEmpire = $db->select(
                "SELECT g.user_id, g.event_id
                 FROM `{$ghostsTable}` g
                 LEFT JOIN `{$empiresTable}` e ON e.id = g.event_id
                 WHERE g.event_type = 'empire'
                   AND g.destroyed_at = 0
                   AND (e.id IS NULL OR e.status IN ('destroyed','expired'));"
            );
            if (is_array($orphansEmpire)) {
                foreach ($orphansEmpire as $o) {
                    self::destroyGhost((int) $o['event_id'], 'empire');
                    $count++;
                }
            }
        } catch (Throwable $e) {}

        try {
            $orphansCrisis = $db->select(
                "SELECT g.user_id, g.event_id
                 FROM `{$ghostsTable}` g
                 LEFT JOIN `{$crisisTable}` c ON c.id = g.event_id
                 WHERE g.event_type = 'crisis'
                   AND g.destroyed_at = 0
                   AND (c.id IS NULL OR c.status = 'finished');"
            );
            if (is_array($orphansCrisis)) {
                foreach ($orphansCrisis as $o) {
                    self::destroyGhost((int) $o['event_id'], 'crisis');
                    $count++;
                }
            }
        } catch (Throwable $e) {}

        return $count;
    }
}