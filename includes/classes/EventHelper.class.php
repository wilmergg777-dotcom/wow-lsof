<?php
/**
 *  AstroIO - EventHelper
 *  Archivo: includes/classes/EventHelper.class.php
 *  
 *  Gestiona los Eventos en Curso del servidor:
 *   - Auto-seeder: crea los 40 eventos si la tabla esta vacia
 *   - Rotacion automatica cada 24h / 5d / 17d
 *   - Resetear eventos caducados de cada jugador
 *   - Actualizar el progreso de los jugadores
 *   - Dar recompensas al reclamar
 *   - Dar monedas del Pase de Batalla al reclamar
 *   - Dar puntos al Arbol de Talentos de Alianza al reclamar
 *  
 *  Uso:
 *    EventHelper::ensureEventsExist();
 *    EventHelper::rotateEvents();
 *    EventHelper::updateProgress($userId, 'destroy_units', 50);
 *    EventHelper::updateProgress($userId, 'destroy_units', 20, 209);
 *    EventHelper::getUserEvents($userId);
 *    EventHelper::claimReward($userId, $eventId);
 *
 *  ═══════════════════════════════════════════════════════════════
 *  ✅ ASTROIO FIX v1.0 — BLINDAJE DE updateProgress()
 *  ═══════════════════════════════════════════════════════════════
 *  updateProgress() envuelto en try/catch(Throwable) para no matar
 *  misiones si falla el SQL. Log en cache/eventhelper_error.log.
 *  ═══════════════════════════════════════════════════════════════
 *
 *  ═══════════════════════════════════════════════════════════════
 *  🔴 ASTROIO FIX v1.1 — RESET DE PROGRESO AL ROTAR
 *  ═══════════════════════════════════════════════════════════════
 *  rotateEvents() resetea el progreso de los eventos que salen del
 *  ciclo. resetUserEvents() limpia fantasmas en cada visita.
 *  ═══════════════════════════════════════════════════════════════
 *
 *  ═══════════════════════════════════════════════════════════════
 *  🟢 ASTROIO FIX v1.2 — EVENTOS ESPECIFICOS
 *  ═══════════════════════════════════════════════════════════════
 *  updateProgress() acepta un 4º parametro opcional $refId:
 *    - $refId = 0 → solo eventos GLOBALES (ref=0)
 *    - $refId > 0 → solo eventos ESPECIFICOS (ref=$refId)
 *  ═══════════════════════════════════════════════════════════════
 *
 *  ═══════════════════════════════════════════════════════════════
 *  🟡 ASTROIO FIX v1.3 — getPlanetaActivo() añadido (lee id_planet)
 *  ═══════════════════════════════════════════════════════════════
 *
 *  ═══════════════════════════════════════════════════════════════
 *  🟢 ASTROIO FIX v1.4 — ENTREGA EN EL PLANETA ACTIVO (REAL)
 *  ═══════════════════════════════════════════════════════════════
 *  BUG v1.3: getPlanetaActivo() leia uni1_users.id_planet, que es
 *  el planeta HOME (fijo, nunca cambia al cambiar de planeta).
 *  Por eso los recursos seguian cayendo en el home.
 *
 *  FIX v1.4: usar $GLOBALS['PLANET']['id'] (planeta activo real,
 *  cargado por common.php desde la sesión en cada peticion INGAME).
 *  Fallback: id_planet de la BD (cron, admin, planeta destruido).
 *  Mismo patrón que BattlePassHelper v1.9.1.
 *  ═══════════════════════════════════════════════════════════════
 */

if (!class_exists('BattlePassHelper')) {
    if (defined('ROOT_PATH')) {
        $bpPath = ROOT_PATH . 'includes/classes/BattlePassHelper.class.php';
        if (file_exists($bpPath)) {
            require_once $bpPath;
        }
    }
}

class EventHelper
{
    // Tiempos de reset en segundos
    const RESET_DAILY   = 86400;    // 24 horas
    const RESET_WEEKLY  = 432000;   // 5 dias
    const RESET_ELITE   = 1468800;  // 17 dias

    // ============================================
    // Configuracion de rotacion
    // ============================================
    const ROTATE_DAILY_ACTIVE  = 8;
    const ROTATE_WEEKLY_ACTIVE = 4;
    const ROTATE_ELITE_ACTIVE  = 2;
    // ============================================

    // ============================================
    // Puntos al Arbol de Talentos por clase de evento
    // ============================================
    const TALENT_POINTS_DAILY  = 25;
    const TALENT_POINTS_WEEKLY = 150;
    const TALENT_POINTS_ELITE  = 300;
    const TALENT_POINTS_ADMIN  = 500;
    // ============================================

    private static $prefix = null;
    private static $rotationDone = false;

    /**
     * Obtener el prefijo de tablas
     */
    private static function getPrefix()
    {
        if (self::$prefix !== null) {
            return self::$prefix;
        }
        if (defined('DB_PREFIX')) self::$prefix = DB_PREFIX;
        elseif (defined('PREFIX')) self::$prefix = PREFIX;
        else self::$prefix = 'uni1_';
        return self::$prefix;
    }

    // ============================================================
    // v1.4 — OBTENER PLANETA ACTIVO DEL JUGADOR (FIX REAL)
    //
    // Prioridad:
    //   1. $GLOBALS['PLANET']['id']  → planeta activo real (sesión)
    //      (solo si pertenece al mismo jugador y está vivo)
    //   2. Fallback: id_planet de la BD (home)
    //   3. Fallback final: getPlanetaPrincipal() (home)
    //
    // Si el planeta activo es una LUNA (planet_type=3):
    //   → se busca el planeta padre por coordenadas.
    // ============================================================
    public static function getPlanetaActivo($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 0;

        $db     = Database::get();
        $prefix = self::getPrefix();

        // ── 1. PRIORIDAD: planeta activo del contexto de juego ──
        //    Solo si pertenece al mismo jugador (evita usar el
        //    planeta del admin cuando consulta a otro jugador).
        if (isset($GLOBALS['PLANET']['id'])
            && isset($GLOBALS['PLANET']['id_owner'])
            && (int)$GLOBALS['PLANET']['id_owner'] === $userId
            && (int)$GLOBALS['PLANET']['id'] > 0
            && isset($GLOBALS['PLANET']['destruyed'])
            && (int)$GLOBALS['PLANET']['destruyed'] === 0
        ) {
            // Planeta normal → usarlo directamente
            if ((int)$GLOBALS['PLANET']['planet_type'] === 1) {
                return (int)$GLOBALS['PLANET']['id'];
            }

            // Luna → buscar planeta padre por coordenadas
            if ((int)$GLOBALS['PLANET']['planet_type'] === 3) {
                $parent = $db->selectSingle(
                    "SELECT id FROM `".$prefix."planets`
                     WHERE id_owner = :uid
                       AND galaxy  = :g
                       AND system  = :s
                       AND planet  = :p
                       AND planet_type = 1
                       AND destruyed = 0
                     LIMIT 1;",
                    array(
                        ':uid' => $userId,
                        ':g'   => (int)$GLOBALS['PLANET']['galaxy'],
                        ':s'   => (int)$GLOBALS['PLANET']['system'],
                        ':p'   => (int)$GLOBALS['PLANET']['planet']
                    )
                );
                if (!empty($parent)) {
                    return (int)$parent['id'];
                }
                // Si no encuentra padre, cae al fallback de abajo
            }
        }

        // ── 2. Fallback: leer id_planet de la BD (home) ──
        $userRow = $db->selectSingle(
            "SELECT id_planet FROM `".$prefix."users` WHERE id = :uid LIMIT 1;",
            array(':uid' => $userId)
        );

        $idPlanet = (is_array($userRow) && isset($userRow['id_planet']))
                  ? (int)$userRow['id_planet'] : 0;

        if ($idPlanet > 0) {
            $planet = $db->selectSingle(
                "SELECT id, planet_type, galaxy, system, planet, destruyed
                 FROM `".$prefix."planets`
                 WHERE id = :pid AND id_owner = :uid LIMIT 1;",
                array(':pid' => $idPlanet, ':uid' => $userId)
            );

            if (!empty($planet) && (int)$planet['destruyed'] === 0) {

                if ((int)$planet['planet_type'] === 1) {
                    return (int)$planet['id'];
                }

                if ((int)$planet['planet_type'] === 3) {
                    $parent = $db->selectSingle(
                        "SELECT id FROM `".$prefix."planets`
                         WHERE id_owner = :uid
                           AND galaxy  = :g
                           AND system  = :s
                           AND planet  = :p
                           AND planet_type = 1
                           AND destruyed = 0
                         LIMIT 1;",
                        array(
                            ':uid' => $userId,
                            ':g'   => (int)$planet['galaxy'],
                            ':s'   => (int)$planet['system'],
                            ':p'   => (int)$planet['planet']
                        )
                    );
                    if (!empty($parent)) {
                        return (int)$parent['id'];
                    }
                }
            }
        }

        // ── 3. Ultimo recurso: planeta principal ──
        return self::getPlanetaPrincipal($userId);
    }

    // ============================================================
    // OBTENER PLANETA PRINCIPAL (fallback seguro)
    // ============================================================
    public static function getPlanetaPrincipal($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 0;

        $db     = Database::get();
        $prefix = self::getPrefix();

        $row = $db->selectSingle(
            "SELECT id FROM `".$prefix."planets`
             WHERE id_owner = :uid
               AND planet_type = 1
               AND destruyed = 0
             ORDER BY id ASC
             LIMIT 1;",
            array(':uid' => $userId)
        );

        return (is_array($row) && isset($row['id'])) ? (int)$row['id'] : 0;
    }

    // ============================================================
    // AUTO-SEEDER: crea los 40 eventos si la tabla esta vacia
    // ============================================================
    public static function ensureEventsExist()
    {
        $db     = Database::get();
        $prefix = self::getPrefix();

        $row = $db->selectSingle(
            "SELECT COUNT(*) as total FROM `".$prefix."events`;"
        );

        $total = (!empty($row) && isset($row['total'])) ? (int)$row['total'] : 0;

        if ($total >= 40) {
            return false;
        }

        if ($total > 0) {
            return false;
        }

        $eventos = array(
            // ============ DAILY (20) ============
            array('Cazador',              'Destruye 100 unidades enemigas en combate.',      'ATK',  '#00ccff', 'destroy_units',  100,     'metal',      5000,  'daily'),
            array('Reciclador',           'Recicla 50.000 recursos de escombros.',           'REC',  '#00ccff', 'recycle_debris', 50000,   'crystal',    5000,  'daily'),
            array('Explorador',           'Completa 5 expediciones exitosas.',               'EXP',  '#00ccff', 'expeditions',    5,       'deuterium',  3000,  'daily'),
            array('Magnate',              'Extrae 50.000 recursos en tus planetas.',         'RES',  '#00ccff', 'get_resources',  50000,   'metal',      8000,  'daily'),
            array('Cazador Avanzado',     'Destruye 500 unidades enemigas en combate.',      'ATK',  '#00ccff', 'destroy_units',  500,     'containers', 1,     'daily'),
            array('Reciclador Pro',       'Recicla 200.000 recursos de escombros.',          'REC',  '#00ccff', 'recycle_debris', 200000,  'crystal',    10000, 'daily'),
            array('Explorador Experto',   'Completa 15 expediciones exitosas.',              'EXP',  '#00ccff', 'expeditions',    15,      'containers', 2,     'daily'),
            array('Constructor',          'Construye 100 naves en tu hangar.',                'SHIP', '#00ccff', 'build_ships',    100,     'metal',      10000, 'daily'),
            array('Comerciante',          'Extrae 100.000 recursos en tus planetas.',         'RES',  '#00ccff', 'get_resources',  100000,  'metal',      12000, 'daily'),
            array('Pirata',               'Destruye 250 unidades enemigas en combate.',      'ATK',  '#00ccff', 'destroy_units',  250,     'crystal',    8000,  'daily'),
            array('Mercader',             'Construye 50 naves en tu hangar.',                 'SHIP', '#00ccff', 'build_ships',    50,      'deuterium',  5000,  'daily'),
            array('Astronomo',            'Completa 10 expediciones exitosas.',               'EXP',  '#00ccff', 'expeditions',    10,      'metal',      9000,  'daily'),
            array('Chatarrero',           'Recicla 100.000 recursos de escombros.',           'REC',  '#00ccff', 'recycle_debris', 100000,  'crystal',    7000,  'daily'),
            array('Ingeniero',            'Construye 200 naves en tu hangar.',                'SHIP', '#00ccff', 'build_ships',    200,     'containers', 2,     'daily'),
            array('Corsario',             'Destruye 300 unidades enemigas en combate.',      'ATK',  '#00ccff', 'destroy_units',  300,     'metal',      10000, 'daily'),
            array('Diplomatico',          'Completa 20 expediciones exitosas.',               'EXP',  '#00ccff', 'expeditions',    20,      'deuterium',  8000,  'daily'),
            array('Industrial',           'Extrae 150.000 recursos en tus planetas.',         'RES',  '#00ccff', 'get_resources',  150000,  'metal',      15000, 'daily'),
            array('Inversor',             'Extrae 200.000 recursos en tus planetas.',         'RES',  '#00ccff', 'get_resources',  200000,  'containers', 3,     'daily'),
            array('Sabio',                'Completa 3 investigaciones en tus laboratorios.',  'TEC',  '#00ccff', 'research_techs', 3,       'crystal',    9000,  'daily'),
            array('Estratega',            'Completa 5 investigaciones en tus laboratorios.',  'TEC',  '#00ccff', 'research_techs', 5,       'containers', 3,     'daily'),
            // ============ WEEKLY (12) ============
            array('Almirante',            'Destruye 5.000 unidades enemigas en combate.',    'ATK',  '#cc88ff', 'destroy_units',  5000,    'containers', 5,     'weekly'),
            array('Cientifico',           'Completa 5 investigaciones en tus laboratorios.',  'TEC',  '#cc88ff', 'research_techs', 5,       'deuterium',  50000, 'weekly'),
            array('Almirante Supremo',    'Destruye 20.000 unidades enemigas en combate.',   'ATK',  '#cc88ff', 'destroy_units',  20000,   'containers', 10,    'weekly'),
            array('Cientifico Experto',   'Completa 15 investigaciones en tus laboratorios.', 'TEC',  '#cc88ff', 'research_techs', 15,      'containers', 15,    'weekly'),
            array('General',              'Destruye 10.000 unidades enemigas en combate.',   'ATK',  '#cc88ff', 'destroy_units',  10000,   'containers', 7,     'weekly'),
            array('Filosofo',             'Completa 10 investigaciones en tus laboratorios.', 'TEC',  '#cc88ff', 'research_techs', 10,      'deuterium',  80000, 'weekly'),
            array('Magnate Supremo',      'Extrae 500.000 recursos en tus planetas.',         'RES',  '#cc88ff', 'get_resources',  500000,  'containers', 8,     'weekly'),
            array('Ingeniero Mayor',      'Construye 500 naves en tu hangar.',                'SHIP', '#cc88ff', 'build_ships',    500,     'containers', 8,     'weekly'),
            array('Reciclador Maestro',   'Recicla 1.000.000 recursos de escombros.',         'REC',  '#cc88ff', 'recycle_debris', 1000000, 'containers', 10,    'weekly'),
            array('Explorador Legendario','Completa 50 expediciones exitosas.',               'EXP',  '#cc88ff', 'expeditions',    50,      'containers', 10,    'weekly'),
            array('Banquero',             'Extrae 1.000.000 recursos en tus planetas.',       'RES',  '#cc88ff', 'get_resources',  1000000, 'containers', 12,    'weekly'),
            array('Titan',                'Construye 1.000 naves en tu hangar.',              'SHIP', '#cc88ff', 'build_ships',    1000,    'containers', 12,    'weekly'),
            // ============ ELITE (8) ============
            array('Leyenda Elite',        'Destruye 100.000 unidades enemigas en combate.',  'ELT',  '#ffaa33', 'destroy_units',  100000,  'containers', 30,    'elite'),
            array('Maestro Elite',        'Construye 10.000 naves en tu hangar.',             'ELT',  '#ffaa33', 'build_ships',    10000,   'containers', 50,    'elite'),
            array('Conquistador',         'Destruye 50.000 unidades enemigas en combate.',   'ELT',  '#ffaa33', 'destroy_units',  50000,   'containers', 20,    'elite'),
            array('Cientifico Elite',     'Completa 30 investigaciones en tus laboratorios.', 'ELT',  '#ffaa33', 'research_techs', 30,      'containers', 25,    'elite'),
            array('Imperio Galactico',    'Extrae 5.000.000 recursos en tus planetas.',       'ELT',  '#ffaa33', 'get_resources',  5000000, 'containers', 30,    'elite'),
            array('Reciclador Elite',     'Recicla 5.000.000 recursos de escombros.',         'ELT',  '#ffaa33', 'recycle_debris', 5000000, 'containers', 35,    'elite'),
            array('Explorador Elite',     'Completa 100 expediciones exitosas.',              'ELT',  '#ffaa33', 'expeditions',    100,     'containers', 40,    'elite'),
            array('Creador de Flotas',    'Construye 20.000 naves en tu hangar.',             'ELT',  '#ffaa33', 'build_ships',    20000,   'containers', 50,    'elite'),
        );

        foreach ($eventos as $e) {
            $db->insert(
                "INSERT INTO `".$prefix."events` 
                 (`event_name`, `event_desc`, `event_icon`, `event_color`, `event_type`, `event_target_value`, `reward_type`, `reward_value`, `event_class`, `active`, `start_date`, `end_date`, `created_by`)
                 VALUES (:name, :desc, :icon, :color, :type, :target, :rtype, :rvalue, :class, 0, 0, 0, 0);",
                array(
                    ':name'   => $e[0],
                    ':desc'   => $e[1],
                    ':icon'   => $e[2],
                    ':color'  => $e[3],
                    ':type'   => $e[4],
                    ':target' => $e[5],
                    ':rtype'  => $e[6],
                    ':rvalue' => $e[7],
                    ':class'  => $e[8],
                )
            );
        }

        self::rotateEvents(true);

        return true;
    }

    // ============================================================
    // ROTACION: elige eventos al azar para cada ciclo
    // ============================================================
    public static function rotateEvents($force = false)
    {
        $db     = Database::get();
        $prefix = self::getPrefix();

        $config = array(
            'daily'  => array('active' => self::ROTATE_DAILY_ACTIVE,  'time' => self::RESET_DAILY),
            'weekly' => array('active' => self::ROTATE_WEEKLY_ACTIVE, 'time' => self::RESET_WEEKLY),
            'elite'  => array('active' => self::ROTATE_ELITE_ACTIVE,  'time' => self::RESET_ELITE),
        );

        foreach ($config as $class => $cfg) {

            $state = $db->selectSingle(
                "SELECT last_rotation, active_ids FROM `".$prefix."events_rotation` WHERE `class` = :c LIMIT 1;",
                array(':c' => $class)
            );

            $lastRotation = $state ? (int)$state['last_rotation'] : 0;
            $age          = TIMESTAMP - $lastRotation;

            if (!$force && $lastRotation > 0 && $age < $cfg['time']) {
                continue;
            }

            // FIX v1.1 — Reset de progreso al rotar
            if ($state && !empty($state['active_ids'])) {
                $safeIds = implode(',', array_map('intval', explode(',', $state['active_ids'])));
                if ($safeIds !== '') {
                    $db->update(
                        "UPDATE `".$prefix."users_events` 
                         SET progress = 0, claimed = 0, claimed_at = 0 
                         WHERE event_id IN (".$safeIds.");"
                    );
                }
            }

            $pool = $db->select(
                "SELECT event_id FROM `".$prefix."events` WHERE event_class = :c;",
                array(':c' => $class)
            );

            if (!is_array($pool) || count($pool) < $cfg['active']) {
                continue;
            }

            $ids = array();
            foreach ($pool as $p) {
                $ids[] = (int)$p['event_id'];
            }
            shuffle($ids);

            $chosen    = array_slice($ids, 0, $cfg['active']);
            $chosenStr = implode(',', $chosen);

            $db->update(
                "UPDATE `".$prefix."events` SET active = 0 WHERE event_class = :c;",
                array(':c' => $class)
            );

            $db->update(
                "UPDATE `".$prefix."events` SET active = 1 WHERE event_id IN (".$chosenStr.");"
            );

            if ($state) {
                $db->update(
                    "UPDATE `".$prefix."events_rotation` SET last_rotation = :t, active_ids = :ids WHERE `class` = :c;",
                    array(':t' => TIMESTAMP, ':ids' => $chosenStr, ':c' => $class)
                );
            } else {
                $db->insert(
                    "INSERT INTO `".$prefix."events_rotation` (`class`, last_rotation, active_ids) VALUES (:c, :t, :ids);",
                    array(':c' => $class, ':t' => TIMESTAMP, ':ids' => $chosenStr)
                );
            }
        }

        self::$rotationDone = true;
        return true;
    }

    /**
     * Actualiza el progreso de un tipo de evento para un usuario.
     *
     * @param int    $userId    ID del jugador
     * @param string $eventType Tipo de evento (destroy_units, recycle_debris, etc.)
     * @param int    $amount    Cantidad a sumar
     * @param int    $refId     0 = global, >0 = ID específico
     * @return bool
     */
    public static function updateProgress($userId, $eventType, $amount = 1, $refId = 0)
    {
        try {
            $userId = (int)$userId;
            $amount = (int)$amount;
            $refId  = (int)$refId;
            
            if ($userId <= 0 || $amount <= 0) return false;

            $db     = Database::get();
            $prefix = self::getPrefix();

            $events = $db->select(
                "SELECT event_id, event_target_value 
                 FROM `".$prefix."events` 
                 WHERE event_type = :type AND active = 1 AND event_target_ref = :ref;",
                array(':type' => $eventType, ':ref' => $refId)
            );

            if (!is_array($events) || empty($events)) return false;

            self::resetUserEvents($userId, $eventType);

            foreach ($events as $event) {
                $eventId = (int)$event['event_id'];

                $existing = $db->selectSingle(
                    "SELECT id, progress, claimed 
                     FROM `".$prefix."users_events` 
                     WHERE user_id = :uid AND event_id = :eid;",
                    array(':uid' => $userId, ':eid' => $eventId)
                );

                if ($existing) {
                    if ($existing['claimed'] == 1) continue;

                    $db->update(
                        "UPDATE `".$prefix."users_events` 
                         SET progress = progress + :amount 
                         WHERE id = :id;",
                        array(':amount' => $amount, ':id' => $existing['id'])
                    );
                } else {
                    $db->insert(
                        "INSERT INTO `".$prefix."users_events` 
                         (user_id, event_id, progress, claimed, claimed_at, created_at)
                         VALUES (:uid, :eid, :amount, 0, 0, :time);",
                        array(
                            ':uid'    => $userId,
                            ':eid'    => $eventId,
                            ':amount' => $amount,
                            ':time'   => TIMESTAMP
                        )
                    );
                }
            }

            return true;

        } catch (Throwable $e) {
            $logDir = (defined('ROOT_PATH') ? ROOT_PATH : dirname(__FILE__) . '/../../') . 'cache/';
            if (!is_dir($logDir)) {
                @mkdir($logDir, 0755, true);
            }
            @file_put_contents(
                $logDir . 'eventhelper_error.log',
                '[' . date('Y-m-d H:i:s') . '] updateProgress User=' . $userId
                . ' Type=' . $eventType
                . ' Amount=' . $amount
                . ' Ref=' . $refId
                . ' ERROR: ' . $e->getMessage()
                . ' en ' . $e->getFile() . ':' . $e->getLine()
                . PHP_EOL,
                FILE_APPEND
            );
            return false;
        }
    }

    /**
     * Obtiene los eventos del usuario (con progreso).
     *
     * @param int    $userId  ID del usuario
     * @param string $filter  'all' | 'daily' | 'weekly' | 'elite'
     * @return array
     */
    public static function getUserEvents($userId, $filter = 'all')
    {
        $userId = (int)$userId;
        $db     = Database::get();
        $prefix = self::getPrefix();

        if (!self::$rotationDone) {
            self::rotateEvents();
        }

        self::resetUserEvents($userId);

        $where = "WHERE e.active = 1";
        if ($filter !== 'all') {
            $where .= " AND e.event_class = :class";
        }

        $sql = "SELECT e.*, 
                       COALESCE(ue.progress, 0) as progress,
                       COALESCE(ue.claimed, 0) as claimed,
                       ue.claimed_at,
                       ue.created_at
                FROM `".$prefix."events` e
                LEFT JOIN `".$prefix."users_events` ue 
                       ON ue.event_id = e.event_id AND ue.user_id = :uid
                ".$where."
                ORDER BY 
                    FIELD(e.event_class, 'daily', 'weekly', 'elite', 'admin'),
                    e.event_id ASC;";

        $params = array(':uid' => $userId);
        if ($filter !== 'all') {
            $params[':class'] = $filter;
        }

        $events = $db->select($sql, $params);
        return is_array($events) ? $events : array();
    }

    /**
     * Reclama la recompensa de un evento.
     *
     * Recompensas permitidas:
     *   - metal      → al PLANETA ACTIVO del jugador (v1.4)
     *   - crystal    → al PLANETA ACTIVO del jugador (v1.4)
     *   - deuterium  → al PLANETA ACTIVO del jugador (v1.4)
     *   - containers → al usuario
     *
     * @param int $userId
     * @param int $eventId
     * @return array  ['success' => bool, 'message' => string, 'reward' => array]
     */
    public static function claimReward($userId, $eventId)
    {
        $userId  = (int)$userId;
        $eventId = (int)$eventId;
        $db      = Database::get();
        $prefix  = self::getPrefix();

        $event = $db->selectSingle(
            "SELECT * FROM `".$prefix."events` 
             WHERE event_id = :eid AND active = 1;",
            array(':eid' => $eventId)
        );

        if (!$event) {
            return array('success' => false, 'message' => '❌ El evento no existe.');
        }

        $progress = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_events` 
             WHERE user_id = :uid AND event_id = :eid;",
            array(':uid' => $userId, ':eid' => $eventId)
        );

        if (!$progress) {
            return array('success' => false, 'message' => '❌ No tienes progreso en este evento.');
        }

        if ($progress['claimed'] == 1) {
            return array('success' => false, 'message' => '❌ Ya has reclamado este evento.');
        }

        if ($progress['progress'] < $event['event_target_value']) {
            return array('success' => false, 'message' => '❌ Aún no has completado el evento.');
        }

        // ============================================
        // DAR RECOMPENSA
        // ============================================
        $rewardType  = $event['reward_type'];
        $rewardValue = (int)$event['reward_value'];
        $rewardMsg   = '';

        if (in_array($rewardType, array('metal', 'crystal', 'deuterium'))) {

            // v1.4 — ENTREGAR EN EL PLANETA ACTIVO DEL JUGADOR
            // (usa $GLOBALS['PLANET']['id'] si pertenece al jugador;
            //  fallback al home si no hay contexto)
            $planetId = self::getPlanetaActivo($userId);

            if ($planetId <= 0) {
                return array('success' => false, 'message' => '❌ No tienes planeta activo.');
            }

            $affected = $db->update(
                "UPDATE `".$prefix."planets`
                 SET ".$rewardType." = ".$rewardType." + :val
                 WHERE id = :pid;",
                array(':val' => $rewardValue, ':pid' => $planetId)
            );

            if ($affected === false) {
                return array('success' => false, 'message' => '❌ No se pudo entregar la recompensa.');
            }

            $icons = array(
                'metal'     => '🪙',
                'crystal'   => '💎',
                'deuterium' => '🧪',
            );
            $rewardMsg = $icons[$rewardType].' +'.number_format($rewardValue).' '.ucfirst($rewardType);
        }
        elseif ($rewardType === 'containers') {
            $db->update(
                "UPDATE `".$prefix."users` SET containers = containers + :val WHERE id = :uid;",
                array(':val' => $rewardValue, ':uid' => $userId)
            );
            $rewardMsg = '📦 +'.$rewardValue.' Contenedores';
        }
        else {
            return array(
                'success' => false,
                'message' => '❌ Tipo de recompensa no permitido: '.$rewardType,
            );
        }
        // ============================================

        // Marcar como reclamado
        $db->update(
            "UPDATE `".$prefix."users_events` 
             SET claimed = 1, claimed_at = :time 
             WHERE id = :id;",
            array(':time' => TIMESTAMP, ':id' => $progress['id'])
        );

        // Guardar en historial
        $db->insert(
            "INSERT INTO `".$prefix."events_history` 
             (user_id, event_id, event_name, event_class, reward_type, reward_value, claimed_at)
             VALUES (:uid, :eid, :name, :class, :rtype, :rval, :time);",
            array(
                ':uid'   => $userId,
                ':eid'   => $eventId,
                ':name'  => $event['event_name'],
                ':class' => $event['event_class'],
                ':rtype' => $rewardType,
                ':rval'  => $rewardValue,
                ':time'  => TIMESTAMP
            )
        );

        // ═══════════════════════════════════════════════════════════
        // DAR MONEDAS DEL PASE DE BATALLA SEGÚN TIPO DE EVENTO
        // ═══════════════════════════════════════════════════════════
        $monedasPase = 0;
        $eventClass = isset($event['event_class']) ? $event['event_class'] : '';

        if (in_array($eventClass, array('daily', 'weekly', 'elite'))) {
            if (class_exists('BattlePassHelper')) {
                $monedasPase = BattlePassHelper::darMonedasPorEvento($userId, $eventClass);
            }
        }

        // ═══════════════════════════════════════════════════════════
        // DAR PUNTOS AL ARBOL DE TALENTOS DE ALIANZA
        // ═══════════════════════════════════════════════════════════
        $talentPoints = 0;
        $talentMsg    = '';

        if (defined('ROOT_PATH')) {
            $talentFile = ROOT_PATH . 'includes/classes/AllianceTalentHelper.class.php';
            if (file_exists($talentFile) && !class_exists('AllianceTalentHelper')) {
                require_once $talentFile;
            }
        }

        if (class_exists('AllianceTalentHelper')) {
            $userRow = $db->selectSingle(
                "SELECT `ally_id` FROM `".$prefix."users` WHERE `id` = :uid LIMIT 1;",
                array(':uid' => $userId)
            );

            $allyId = (is_array($userRow) && isset($userRow['ally_id'])) ? (int)$userRow['ally_id'] : 0;

            if ($allyId > 0) {
                if ($eventClass === 'daily')  $talentPoints = self::TALENT_POINTS_DAILY;
                if ($eventClass === 'weekly') $talentPoints = self::TALENT_POINTS_WEEKLY;
                if ($eventClass === 'elite')  $talentPoints = self::TALENT_POINTS_ELITE;
                if ($eventClass === 'admin')  $talentPoints = self::TALENT_POINTS_ADMIN;

                if ($talentPoints > 0) {
                    $res = AllianceTalentHelper::addPoints(
                        $allyId,
                        $userId,
                        $talentPoints,
                        'Evento: '.$event['event_name']
                    );

                    if (!empty($res['ok'])) {
                        $talentMsg = ' | 🌳 +'.$talentPoints.' pts al Arbol';
                    } else {
                        $talentMsg = ' | ⚠️ '.$res['msg'];
                    }
                }
            }
        }
        // ═══════════════════════════════════════════════════════════

        $mensajeFinal = '✅ ¡Recompensa reclamada! '.$rewardMsg;
        if ($monedasPase > 0) {
            $mensajeFinal .= ' | 🎟️ +'.$monedasPase.' monedas del Pase';
        }
        if (!empty($talentMsg)) {
            $mensajeFinal .= $talentMsg;
        }

        return array(
            'success'      => true,
            'message'      => $mensajeFinal,
            'reward'       => array('type' => $rewardType, 'value' => $rewardValue),
            'bp_coins'     => $monedasPase,
            'talent_pts'   => $talentPoints
        );
    }

    /**
     * Resetea los eventos caducados de un usuario.
     *
     * @param int    $userId
     * @param string $onlyType  Opcional: solo resetear eventos de este tipo
     */
    public static function resetUserEvents($userId, $onlyType = null)
    {
        $userId = (int)$userId;
        $db     = Database::get();
        $prefix = self::getPrefix();

        // FIX v1.1 — Limpieza de fantasmas
        if ($onlyType === null) {
            $inactive = $db->select(
                "SELECT event_id FROM `".$prefix."events` WHERE active = 0;"
            );

            if (is_array($inactive) && !empty($inactive)) {
                $inactiveIds = array();
                foreach ($inactive as $ie) {
                    $inactiveIds[] = (int)$ie['event_id'];
                }

                if (!empty($inactiveIds)) {
                    $idList = implode(',', $inactiveIds);
                    $db->update(
                        "UPDATE `".$prefix."users_events` 
                         SET progress = 0, claimed = 0, claimed_at = 0 
                         WHERE user_id = ".$userId." 
                           AND event_id IN (".$idList.");"
                    );
                }
            }
        }

        $where = "WHERE active = 1";
        $params = array();

        if ($onlyType !== null) {
            $where .= " AND event_type = :type";
            $params[':type'] = $onlyType;
        }

        $events = $db->select(
            "SELECT event_id, event_class FROM `".$prefix."events` ".$where.";",
            $params
        );

        if (!is_array($events)) return;

        foreach ($events as $event) {
            $eventId    = (int)$event['event_id'];
            $eventClass = $event['event_class'];

            $resetTime = 0;
            if ($eventClass === 'daily')  $resetTime = self::RESET_DAILY;
            if ($eventClass === 'weekly') $resetTime = self::RESET_WEEKLY;
            if ($eventClass === 'elite')  $resetTime = self::RESET_ELITE;

            if ($resetTime === 0) continue;

            $progress = $db->selectSingle(
                "SELECT id, created_at FROM `".$prefix."users_events` 
                 WHERE user_id = :uid AND event_id = :eid;",
                array(':uid' => $userId, ':eid' => $eventId)
            );

            if (!$progress) continue;

            $age = TIMESTAMP - (int)$progress['created_at'];

            if ($age >= $resetTime) {
                $db->delete(
                    "DELETE FROM `".$prefix."users_events` WHERE id = :id;",
                    array(':id' => $progress['id'])
                );
            }
        }
    }

    /**
     * Devuelve 1 evento de cada tipo (el mejor) para mostrar en el overview.
     *
     * @param int $userId
     * @return array ['daily' => event, 'weekly' => event, 'elite' => event]
     */
    public static function getOverviewEvents($userId)
    {
        $userId = (int)$userId;
        $db     = Database::get();
        $prefix = self::getPrefix();

        $result = array(
            'daily'  => null,
            'weekly' => null,
            'elite'  => null,
        );

        if (!self::$rotationDone) {
            self::rotateEvents();
        }

        self::resetUserEvents($userId);

        foreach (array('daily', 'weekly', 'elite') as $class) {
            $sql = "SELECT e.*, 
                           COALESCE(ue.progress, 0) as progress,
                           COALESCE(ue.claimed, 0) as claimed,
                           ue.claimed_at,
                           ue.created_at
                    FROM `".$prefix."events` e
                    LEFT JOIN `".$prefix."users_events` ue 
                           ON ue.event_id = e.event_id AND ue.user_id = :uid
                    WHERE e.active = 1 AND e.event_class = :class
                    ORDER BY e.event_id ASC
                    LIMIT 1;";

            $event = $db->selectSingle($sql, array(
                ':uid'   => $userId,
                ':class' => $class
            ));

            if (!empty($event)) {
                $result[$class] = $event;
            }
        }

        return $result;
    }
}