<?php
/**
 * RaceTalentHelper - Arbol de Talentos de RAZA
 * AstroIO v2.8 — Sistema de puntos progresivos con Fragmentos
 * 
 * El jugador acumula "fragmentos" al completar misiones.
 * Cada 50 fragmentos = 1 Punto de Talento real.
 * 
 * SQL OBLIGATORIO (migration_16.sql):
 *   CREATE TABLE IF NOT EXISTS `%PREFIX%user_race_talents` (...);
 *   CREATE TABLE IF NOT EXISTS `%PREFIX%user_race_talent_points` (
 *      `user_id` int(11) NOT NULL,
 *      `available_points` int(11) NOT NULL DEFAULT 0,
 *      `progress` int(11) NOT NULL DEFAULT 0,
 *      `total_earned` int(11) NOT NULL DEFAULT 0,
 *      `updated_at` int(11) NOT NULL,
 *      PRIMARY KEY (`user_id`)
 *   );
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

class RaceTalentHelper
{
    // ============================================================
    // CONSTANTES DEL SISTEMA
    // ============================================================

    // Puntos TOTALES que el jugador puede llegar a ganar y repartir
    const TOTAL_POINTS = 11;

    // Maximo de puntos por talento (rango 1-3)
    const MAX_PER_TALENT = 3;

    // Cuántos "fragmentos" de misión se necesitan para obtener 1 Punto de Talento
    const FRAGMENTS_PER_POINT = 50;

    // Puntos necesarios en la fila ANTERIOR para desbloquear la fila
    const ROW_GATE = array(
        2 => 2,   // Fila 2 se desbloquea con 2 puntos invertidos en la Fila 1
        3 => 2,   // Fila 3 se desbloquea con 2 puntos invertidos en la Fila 2
    );

    // ============================================================
    // DEFINICION DE TALENTOS POR RAZA (3 filas: 3 / 2 / 1 talentos)
    // ============================================================

    const RACE_TALENTS = array(
        // ---------------------------------------------
        // RAZA 1 — PREDATORS (combate y espionaje)
        // ---------------------------------------------
        1 => array(
            'rows' => array(
                1 => array(
                    'pred_garras'    => array('name' => 'Garras Afiladas',    'icon' => 'fa-crosshairs',       'bonus' => array('bonus_attack' => 2),        'desc' => 'Mas dano de ataque en combate.'),
                    'pred_ojos'      => array('name' => 'Ojos Rojos',          'icon' => 'fa-eye',              'bonus' => array('bonus_spy' => 3),           'desc' => 'Espionaje mas potente.'),
                    'pred_caza'      => array('name' => 'Caza Veloz',          'icon' => 'fa-tachometer-alt',   'bonus' => array('bonus_speed' => 1),         'desc' => 'Flotas un poco mas rapidas.'),
                ),
                2 => array(
                    'pred_instinto'  => array('name' => 'Instinto Salvaje',   'icon' => 'fa-fighter-jet',      'bonus' => array('bonus_attack' => 3),        'desc' => 'Ataque aun mas fuerte.'),
                    'pred_corazon'   => array('name' => 'Corazon Feroz',       'icon' => 'fa-heart',            'bonus' => array('bonus_shield' => 2),        'desc' => 'Mas escudo en combate.'),
                ),
                3 => array(
                    'pred_furia'     => array('name' => 'FURIA DEPREDADORA',   'icon' => 'fa-fire',             'bonus' => array('bonus_attack' => 4, 'bonus_defense' => 2), 'desc' => 'Ataque masivo + blindaje extra.'),
                ),
            ),
        ),

        // ---------------------------------------------
        // RAZA 2 — ALIENS (expediciones y defensa)
        // ---------------------------------------------
        2 => array(
            'rows' => array(
                1 => array(
                    'alie_membranas' => array('name' => 'Membranas Densas',   'icon' => 'fa-shield-alt',       'bonus' => array('bonus_defense' => 2),       'desc' => 'Mas blindaje en combate.'),
                    'alie_radar'     => array('name' => 'Radar Cuantico',      'icon' => 'fa-signal',           'bonus' => array('bonus_exp_resources' => 3), 'desc' => 'Mas recursos en expediciones.'),
                    'alie_metab'     => array('name' => 'Metabolismo Alien',   'icon' => 'fa-flask',            'bonus' => array('bonus_exp_darkmatter' => 3),'desc' => 'Mas Materia Oscura en expediciones.'),
                ),
                2 => array(
                    'alie_colonias'  => array('name' => 'Colonias Resistentes','icon' => 'fa-cubes',           'bonus' => array('bonus_defense' => 3),       'desc' => 'Blindaje reforzado.'),
                    'alie_sonda'     => array('name' => 'Sonda Simbionte',     'icon' => 'fa-eye',              'bonus' => array('bonus_spy' => 3),           'desc' => 'Espionaje mejorado.'),
                ),
                3 => array(
                    'alie_nucleo'    => array('name' => 'NUCLEO ALIENIGENA',   'icon' => 'fa-gem',              'bonus' => array('bonus_defense' => 4, 'bonus_exp_darkmatter' => 3), 'desc' => 'Blindaje masivo + mas MO en expediciones.'),
                ),
            ),
        ),

        // ---------------------------------------------
        // RAZA 3 — CHARTER (costes y escudos)
        // ---------------------------------------------
        3 => array(
            'rows' => array(
                1 => array(
                    'char_herreria'  => array('name' => 'Herreria Eficiente',  'icon' => 'fa-wrench',           'bonus' => array('bonus_defense_cost' => -2), 'desc' => 'Defensas mas baratas.'),
                    'char_ojo'       => array('name' => 'Ojo del Mercenario',  'icon' => 'fa-eye',              'bonus' => array('bonus_spy' => 2),           'desc' => 'Espionaje mejorado.'),
                    'char_escudos'   => array('name' => 'Escudos Charter',     'icon' => 'fa-shield-alt',       'bonus' => array('bonus_shield' => 2),        'desc' => 'Mas escudo en combate.'),
                ),
                2 => array(
                    'char_cadena'    => array('name' => 'Cadena de Montaje',   'icon' => 'fa-cogs',             'bonus' => array('bonus_ship_cost' => -2),    'desc' => 'Naves mas baratas.'),
                    'char_contratos' => array('name' => 'Contratos Inteligentes','icon' => 'fa-dollar-sign',    'bonus' => array('bonus_research_cost' => -3),'desc' => 'Investigaciones mas baratas.'),
                ),
                3 => array(
                    'char_maestria'  => array('name' => 'MAESTRIA MERCENARIA', 'icon' => 'fa-trophy',           'bonus' => array('bonus_ship_cost' => -3, 'bonus_defense_cost' => -2), 'desc' => 'Naves y defensas mucho mas baratas.'),
                ),
            ),
        ),

        // ---------------------------------------------
        // RAZA 4 — SARCKS (produccion y almacenes)
        // ---------------------------------------------
        4 => array(
            'rows' => array(
                1 => array(
                    'sarc_minas'     => array('name' => 'Minas Pesadas',       'icon' => 'fa-cube',             'bonus' => array('bonus_resources' => 2),     'desc' => 'Mas produccion de recursos.'),
                    'sarc_turbinas'  => array('name' => 'Turbinas Extra',      'icon' => 'fa-bolt',             'bonus' => array('bonus_energy' => 2),        'desc' => 'Mas produccion de energia.'),
                    'sarc_bodegas'   => array('name' => 'Bodegas Reforzadas',  'icon' => 'fa-archive',          'bonus' => array('bonus_storage' => 3),       'desc' => 'Almacenes mas grandes.'),
                ),
                2 => array(
                    'sarc_industria' => array('name' => 'Industria Pesada',    'icon' => 'fa-industry',         'bonus' => array('bonus_resources' => 3),     'desc' => 'Produccion reforzada.'),
                    'sarc_refin'     => array('name' => 'Refinerias Profundas','icon' => 'fa-tint',             'bonus' => array('bonus_energy' => 3),        'desc' => 'Energia reforzada.'),
                ),
                3 => array(
                    'sarc_corazon'   => array('name' => 'CORAZON INDUSTRIAL',  'icon' => 'fa-fire',             'bonus' => array('bonus_resources' => 4, 'bonus_storage' => 3), 'desc' => 'Produccion masiva + almacenes enormes.'),
                ),
            ),
        ),

        // ---------------------------------------------
        // RAZA 5 — ESPECTROS (velocidad y espionaje)
        // ---------------------------------------------
        5 => array(
            'rows' => array(
                1 => array(
                    'espe_prop'      => array('name' => 'Propulsion Fantasmal','icon' => 'fa-tachometer-alt',   'bonus' => array('bonus_speed' => 2),         'desc' => 'Flotas mas rapidas.'),
                    'espe_ocult'     => array('name' => 'Ocultacion',          'icon' => 'fa-eye-slash',        'bonus' => array('bonus_spy' => 3),           'desc' => 'Espionaje mas potente.'),
                    'espe_rutas'     => array('name' => 'Rutas de Sombra',     'icon' => 'fa-map-marker-alt',   'bonus' => array('bonus_flight_time' => -2),  'desc' => 'Vuelos mas cortos.'),
                ),
                2 => array(
                    'espe_motores'   => array('name' => 'Motores Espectro',    'icon' => 'fa-rocket',           'bonus' => array('bonus_speed' => 3),         'desc' => 'Velocidad reforzada.'),
                    'espe_combus'    => array('name' => 'Combustible Etereo',  'icon' => 'fa-tint',             'bonus' => array('bonus_fuel' => -2),         'desc' => 'Menos consumo de combustible.'),
                ),
                3 => array(
                    'espe_espectral' => array('name' => 'VELOCIDAD ESPECTRAL', 'icon' => 'fa-bolt',             'bonus' => array('bonus_speed' => 5, 'bonus_flight_time' => -2), 'desc' => 'Velocidad extrema + vuelos cortos.'),
                ),
            ),
        ),

        // ---------------------------------------------
        // RAZA 6 — MERCADERES (almacenes, costes y combustible)
        // ---------------------------------------------
        6 => array(
            'rows' => array(
                1 => array(
                    'merc_bodegas'   => array('name' => 'Bodegas Ampliadas',   'icon' => 'fa-archive',          'bonus' => array('bonus_storage' => 3),       'desc' => 'Almacenes mas grandes.'),
                    'merc_regateo'   => array('name' => 'Regateo',             'icon' => 'fa-exchange-alt',     'bonus' => array('bonus_ship_cost' => -2),    'desc' => 'Naves mas baratas.'),
                    'merc_rutas'     => array('name' => 'Rutas Comerciales',   'icon' => 'fa-map-marker-alt',   'bonus' => array('bonus_flight_time' => -2),  'desc' => 'Vuelos mas cortos.'),
                ),
                2 => array(
                    'merc_carga'     => array('name' => 'Carga Masiva',        'icon' => 'fa-truck',            'bonus' => array('bonus_resources' => 3),     'desc' => 'Mas produccion de recursos.'),
                    'merc_convenio'  => array('name' => 'Convenio Estelar',    'icon' => 'fa-handshake',        'bonus' => array('bonus_fuel' => -3),         'desc' => 'Mucho menos combustible.'),
                ),
                3 => array(
                    'merc_imperio'   => array('name' => 'IMPERIO COMERCIAL',   'icon' => 'fa-trophy',           'bonus' => array('bonus_ship_cost' => -3, 'bonus_fuel' => -2), 'desc' => 'Naves baratas + poco combustible.'),
                ),
            ),
        ),
    );

    // ============================================================
    // HELPERS BASICOS
    // ============================================================

    private static function db()
    {
        return Database::get();
    }

    private static function prefix()
    {
        return DB_PREFIX;
    }

    /**
     * Raza actual del usuario (0 si no eligio).
     */
    public static function getRaceId($userId)
    {
        $row = self::db()->selectSingle(
            "SELECT `race_id` FROM `".self::prefix()."users` WHERE `id` = '".(int)$userId."' LIMIT 1;"
        );
        return (is_array($row) && isset($row['race_id'])) ? (int)$row['race_id'] : 0;
    }

    // ============================================================
    // GESTIÓN DE PUNTOS Y FRAGMENTOS
    // ============================================================

    /**
     * Obtiene el saldo de puntos disponibles para gastar.
     */
    public static function getAvailablePoints($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 0;

        $row = self::db()->selectSingle(
            "SELECT `available_points` FROM `".self::prefix()."user_race_talent_points`
             WHERE `user_id` = '".$userId."' LIMIT 1;"
        );

        if (empty($row)) {
            self::db()->query(
                "INSERT INTO `".self::prefix()."user_race_talent_points`
                 (`user_id`, `available_points`, `progress`, `total_earned`, `updated_at`)
                 VALUES ('".$userId."', 0, 0, 0, '".TIMESTAMP."');"
            );
            return 0;
        }

        return (int)$row['available_points'];
    }

    /**
     * Obtiene los fragmentos acumulados actuales.
     */
    public static function getProgress($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 0;

        $row = self::db()->selectSingle(
            "SELECT `progress` FROM `".self::prefix()."user_race_talent_points`
             WHERE `user_id` = '".$userId."' LIMIT 1;"
        );

        return (is_array($row) && isset($row['progress'])) ? (int)$row['progress'] : 0;
    }

    /**
     * Otorga FRAGMENTOS al jugador (se llama desde misiones/eventos).
     * Cada FRAGMENTS_PER_POINT (50) fragmentos se convierten en 1 Punto.
     * 
     * @param int    $userId ID del jugador
     * @param int    $amount Cantidad de FRAGMENTOS a otorgar
     * @param string $reason Motivo
     * @return bool
     */
    public static function addPoints($userId, $amount, $reason = '')
    {
        $userId = (int)$userId;
        $amount = (int)$amount;
        if ($userId <= 0 || $amount <= 0) return false;

        $p = self::prefix();
        $raceId = self::getRaceId($userId);
        
        if ($raceId <= 0) return false;

        // Asegurar que existe la fila
        self::getAvailablePoints($userId);

        // Obtener datos actuales
        $currentData = self::db()->selectSingle(
            "SELECT `available_points`, `progress`, `total_earned` FROM `".$p."user_race_talent_points` WHERE `user_id` = '".$userId."' LIMIT 1;"
        );
        
        $available = (int)$currentData['available_points'];
        $progress  = (int)$currentData['progress'];
        $earned    = (int)$currentData['total_earned'];

        // Si ya llegó al tope máximo de puntos totales, no hace nada
        if ($earned >= self::TOTAL_POINTS) {
            return false; 
        }

        // Sumar los nuevos fragmentos
        $newProgress = $progress + $amount;
        
        // Calcular cuántos Puntos reales se generan
        $pointsGained = floor($newProgress / self::FRAGMENTS_PER_POINT);
        $remainingFragments = $newProgress % self::FRAGMENTS_PER_POINT;

        // Si al ganar puntos supera el máximo total, ajustamos
        if ($earned + $pointsGained > self::TOTAL_POINTS) {
            $pointsGained = self::TOTAL_POINTS - $earned;
            $remainingFragments = 0; // Si ya está al máximo, los fragmentos sobran
        }

        $newAvailable = $available + $pointsGained;
        $newEarned = $earned + $pointsGained;

        // Actualizar la base de datos
        self::db()->query(
            "UPDATE `".$p."user_race_talent_points`
             SET `available_points` = ".$newAvailable.",
                 `progress` = ".$remainingFragments.",
                 `total_earned` = ".$newEarned.",
                 `updated_at` = '".TIMESTAMP."'
             WHERE `user_id` = '".$userId."';"
        );

        // Log opcional
        $logDir = (defined('ROOT_PATH') ? ROOT_PATH : dirname(__FILE__) . '/../../') . 'cache/';
        if (!is_dir($logDir)) @mkdir($logDir, 0755, true);
        @file_put_contents($logDir . 'race_talent_points.log',
            '['.date('Y-m-d H:i:s').'] User='.$userId.' +'.$amount.' fragmentos. (Puntos ganados: '.$pointsGained.'). Razón: '.$reason.PHP_EOL,
            FILE_APPEND);

        return true;
    }

    // ============================================================
    // ELECCIONES DEL JUGADOR
    // ============================================================

    public static function getChoices($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) {
            return array();
        }

        $rows = self::db()->select(
            "SELECT `talent_key`, `points` FROM `".self::prefix()."user_race_talents`
             WHERE `user_id` = '".$userId."' AND `points` > 0;"
        );

        $out = array();
        if (!empty($rows)) {
            foreach ($rows as $r) {
                $out[$r['talent_key']] = (int)$r['points'];
            }
        }
        return $out;
    }

    public static function getSpentInRow($raceId, $rowNum, $choices)
    {
        if (!isset(self::RACE_TALENTS[$raceId]['rows'][$rowNum])) {
            return 0;
        }
        $spent = 0;
        foreach (self::RACE_TALENTS[$raceId]['rows'][$rowNum] as $key => $def) {
            if (isset($choices[$key])) {
                $spent += (int)$choices[$key];
            }
        }
        return $spent;
    }

    public static function isRowUnlocked($raceId, $rowNum, $choices)
    {
        if ($rowNum <= 1) {
            return true;
        }
        $gate = isset(self::ROW_GATE[$rowNum]) ? self::ROW_GATE[$rowNum] : 0;
        return self::getSpentInRow($raceId, $rowNum - 1, $choices) >= $gate;
    }

    public static function getTotalSpent($choices)
    {
        $spent = 0;
        foreach ($choices as $pts) {
            $spent += (int)$pts;
        }
        return $spent;
    }

    // ============================================================
    // ESTRUCTURA PARA LA PLANTILLA
    // ============================================================

    public static function getStructure($userId)
    {
        $raceId = self::getRaceId($userId);
        if ($raceId <= 0 || !isset(self::RACE_TALENTS[$raceId])) {
            return null;
        }

        $choices = self::getChoices($userId);
        $spent   = self::getTotalSpent($choices);
        
        // Puntos reales disponibles y fragmentos actuales
        $available = self::getAvailablePoints($userId); 
        $currentFragments = self::getProgress($userId);

        $rows = array();
        foreach (self::RACE_TALENTS[$raceId]['rows'] as $rowNum => $talents) {
            $unlocked = self::isRowUnlocked($raceId, $rowNum, $choices);
            $gate     = $rowNum > 1 ? self::ROW_GATE[$rowNum] : 0;
            $spentPrev = $rowNum > 1 ? self::getSpentInRow($raceId, $rowNum - 1, $choices) : 0;

            $talentsOut = array();
            foreach ($talents as $key => $def) {
                $pts = isset($choices[$key]) ? (int)$choices[$key] : 0;

                $canAdd = $unlocked && ($available > 0) && ($pts < self::MAX_PER_TALENT);
                $canRemove = $pts > 0;

                $bonusTxt = array();
                foreach ($def['bonus'] as $col => $val) {
                    $label = self::bonusLabel($col);
                    $sign = $val > 0 ? '+' : '';
                    $bonusTxt[] = $label.' '.$sign.($val * self::MAX_PER_TALENT).'%';
                }

                $talentsOut[] = array(
                    'key'        => $key,
                    'name'       => $def['name'],
                    'desc'       => $def['desc'],
                    'icon'       => $def['icon'],
                    'points'     => $pts,
                    'max'        => self::MAX_PER_TALENT,
                    'can_add'    => $canAdd,
                    'can_remove' => $canRemove,
                    'bonus_txt'  => implode(' | ', $bonusTxt),
                    'bonus_map'  => $def['bonus'],
                );
            }

            $rows[] = array(
                'num'         => $rowNum,
                'unlocked'    => $unlocked,
                'gate'        => $gate,
                'spent'       => self::getSpentInRow($raceId, $rowNum, $choices),
                'spent_prev'  => $spentPrev,
                'talents'     => $talentsOut,
            );
        }

        return array(
            'race_id'   => $raceId,
            'rows'      => $rows,
            'spent'     => $spent,
            'available' => $available,       // Puntos para gastar
            'fragments' => $currentFragments, // Fragmentos actuales (ej. 15)
            'fragments_max' => self::FRAGMENTS_PER_POINT, // (ej. 50)
            'total'     => self::TOTAL_POINTS,
            'max_per'   => self::MAX_PER_TALENT,
            'gate_2'    => self::ROW_GATE[2],
            'gate_3'    => self::ROW_GATE[3],
        );
    }

    public static function bonusLabel($col)
    {
        $map = array(
            'bonus_attack'        => 'Ataque',
            'bonus_defense'       => 'Blindaje',
            'bonus_shield'        => 'Escudo',
            'bonus_resources'     => 'Produccion',
            'bonus_energy'        => 'Energia',
            'bonus_storage'       => 'Almacen',
            'bonus_speed'         => 'Velocidad',
            'bonus_fuel'          => 'Combustible',
            'bonus_flight_time'   => 'Tiempo de vuelo',
            'bonus_ship_cost'     => 'Coste de naves',
            'bonus_defense_cost'  => 'Coste de defensas',
            'bonus_research_cost' => 'Coste de investigacion',
            'bonus_ship_time'     => 'Tiempo de naves',
            'bonus_defense_time'  => 'Tiempo de defensas',
            'bonus_build_time'    => 'Tiempo de edificios',
            'bonus_research_time' => 'Tiempo de investigacion',
            'bonus_spy'           => 'Espionaje',
            'bonus_exp_resources' => 'Recursos de expedicion',
            'bonus_exp_darkmatter'=> 'MO de expedicion',
            'bonus_fleet_slots'   => 'Slots de flota',
        );
        return isset($map[$col]) ? $map[$col] : $col;
    }

    // ============================================================
    // ACCIONES: PONER / QUITAR PUNTOS
    // ============================================================

    public static function setPoint($userId, $talentKey, $action)
    {
        $userId    = (int)$userId;
        $talentKey = (string)$talentKey;
        $action    = ($action === 'remove') ? 'remove' : 'add';

        $raceId = self::getRaceId($userId);
        if ($raceId <= 0) {
            return array('ok' => false, 'msg' => 'No tienes raza elegida.');
        }

        $found = null;
        $foundRow = 0;
        foreach (self::RACE_TALENTS[$raceId]['rows'] as $rowNum => $talents) {
            if (isset($talents[$talentKey])) {
                $found = $talents[$talentKey];
                $foundRow = $rowNum;
                break;
            }
        }
        if (empty($found)) {
            return array('ok' => false, 'msg' => 'Ese talento no pertenece a tu raza.');
        }

        $choices = self::getChoices($userId);
        $pts     = isset($choices[$talentKey]) ? (int)$choices[$talentKey] : 0;
        $availablePoints = self::getAvailablePoints($userId);

        $p = self::prefix();

        if ($action === 'add') {
            if ($availablePoints <= 0) {
                return array('ok' => false, 'msg' => 'No tienes puntos de talento disponibles. Completa misiones para conseguir fragmentos.');
            }
            if ($pts >= self::MAX_PER_TALENT) {
                return array('ok' => false, 'msg' => $found['name'].' ya esta al maximo ('.self::MAX_PER_TALENT.' puntos).');
            }
            if (!self::isRowUnlocked($raceId, $foundRow, $choices)) {
                $gate = self::ROW_GATE[$foundRow];
                $prevSpent = self::getSpentInRow($raceId, $foundRow - 1, $choices);
                return array('ok' => false, 'msg' => 'Fila '.$foundRow.' bloqueada: necesita '.$gate.' puntos en la fila anterior (tienes '.$prevSpent.').');
            }

            if ($pts === 0) {
                self::db()->query(
                    "INSERT INTO `".$p."user_race_talents` (`user_id`, `race_id`, `talent_key`, `points`, `updated_at`)
                     VALUES ('".$userId."', '".$raceId."', '".addslashes($talentKey)."', 1, '".TIMESTAMP."')
                     ON DUPLICATE KEY UPDATE `points` = `points` + 1, `updated_at` = '".TIMESTAMP."';"
                );
            } else {
                self::db()->query(
                    "UPDATE `".$p."user_race_talents`
                     SET `points` = `points` + 1, `updated_at` = '".TIMESTAMP."'
                     WHERE `user_id` = '".$userId."' AND `talent_key` = '".addslashes($talentKey)."' LIMIT 1;"
                );
            }

            self::db()->query(
                "UPDATE `".$p."user_race_talent_points`
                 SET `available_points` = `available_points` - 1, `updated_at` = '".TIMESTAMP."'
                 WHERE `user_id` = '".$userId."';"
            );

            if (class_exists('RaceFactionHelper')) {
                RaceFactionHelper::clearCache($userId);
            }

            return array('ok' => true, 'msg' => $found['name'].': '.($pts + 1).'/'.self::MAX_PER_TALENT.' puntos.');
        }

        // remove
        if ($pts <= 0) {
            return array('ok' => false, 'msg' => 'Ese talento no tiene puntos que quitar.');
        }

        self::db()->query(
            "UPDATE `".$p."user_race_talents`
             SET `points` = GREATEST(`points` - 1, 0), `updated_at` = '".TIMESTAMP."'
             WHERE `user_id` = '".$userId."' AND `talent_key` = '".addslashes($talentKey)."' LIMIT 1;"
        );

        self::db()->query(
            "UPDATE `".$p."user_race_talent_points`
             SET `available_points` = `available_points` + 1, `updated_at` = '".TIMESTAMP."'
             WHERE `user_id` = '".$userId."';"
        );

        if (class_exists('RaceFactionHelper')) {
            RaceFactionHelper::clearCache($userId);
        }

        return array('ok' => true, 'msg' => $found['name'].': '.($pts - 1).'/'.self::MAX_PER_TALENT.' puntos.');
    }

    /**
     * BORRA todos los talentos, fragmentos y puntos (se llama al cambiar de raza).
     */
    public static function wipe($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) {
            return;
        }
        
        self::db()->query(
            "DELETE FROM `".self::prefix()."user_race_talents` WHERE `user_id` = '".$userId."';"
        );

        self::db()->query(
            "DELETE FROM `".self::prefix()."user_race_talent_points` WHERE `user_id` = '".$userId."';"
        );

        if (class_exists('RaceFactionHelper')) {
            RaceFactionHelper::clearCache($userId);
        }
    }

    // ============================================================
    // BONUS ACTIVOS
    // ============================================================

    public static function getBonusesForUser($userId, $raceId = null)
    {
        $userId = (int)$userId;
        if ($userId <= 0) {
            return array();
        }

        if ($raceId === null) {
            $raceId = self::getRaceId($userId);
        }
        $raceId = (int)$raceId;
        if ($raceId <= 0 || !isset(self::RACE_TALENTS[$raceId])) {
            return array();
        }

        $choices = self::getChoices($userId);
        if (empty($choices)) {
            return array();
        }

        $bonus = array();
        foreach (self::RACE_TALENTS[$raceId]['rows'] as $talents) {
            foreach ($talents as $key => $def) {
                if (!isset($choices[$key]) || (int)$choices[$key] <= 0) {
                    continue;
                }
                $pts = (int)$choices[$key];
                foreach ($def['bonus'] as $col => $val) {
                    if (!isset($bonus[$col])) {
                        $bonus[$col] = 0.0;
                    }
                    $bonus[$col] += (float)$val * $pts;
                }
            }
        }
        return $bonus;
    }

    // ============================================================
    // INTEGRACIÓN CON EVENTOS Y MISIONES
    // ============================================================

    /**
     * Método puente entre EventHelper y el sistema de talentos.
     * Recibe una cantidad de FRAGMENTOS y llama a addPoints para procesarlos.
     */
    public static function addProgressFromMission($userId, $missionType, $amount)
    {
        $userId = (int)$userId;
        $amount = (int)$amount;
        
        if ($userId <= 0 || $amount <= 0) {
            return false;
        }

        $raceId = self::getRaceId($userId);
        if ($raceId <= 0) {
            return false;
        }

        try {
            return self::addPoints($userId, $amount, 'Mision: ' . $missionType);
        } catch (Throwable $e) {
            return false;
        }
    }
}