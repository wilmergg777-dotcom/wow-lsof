<?php
/**
 *  AstroIO - RaceFactionHelper
 *  Archivo: includes/classes/class.RaceFactionHelper.php
 *  
 *  Gestiona los bonos de Razas y Facciones del jugador.
 *  
 *  Uso:
 *    RaceFactionHelper::getBonus($userId, 'attack');
 *    RaceFactionHelper::apply($valor, $userId, 'resources');
 */

class RaceFactionHelper
{
    private static $cache = array();

    /**
     * Devuelve el % de bono activo del tipo indicado para el usuario
     * (suma raza + facción).
     */
    public static function getBonus($userId, $bonusType)
    {
        $userId = (int)$userId;

        if (!isset(self::$cache[$userId])) {
            self::loadUserBonuses($userId);
        }

        return isset(self::$cache[$userId][$bonusType])
            ? (float)self::$cache[$userId][$bonusType]
            : 0;
    }

    /**
     * Aplica el bono a un valor.
     * Ejemplo: 100 con bono +20% → 120
     */
    public static function apply($value, $userId, $bonusType)
    {
        $bonus = self::getBonus($userId, $bonusType);
        if ($bonus == 0) {
            return $value;
        }
        return $value * (1 + ($bonus / 100));
    }

    /**
     * Aplica el bono de forma INVERSA (para tiempos y costes).
     * Ejemplo: 100 de tiempo con bono -10% → 90
     */
    public static function applyInverse($value, $userId, $bonusType)
    {
        $bonus = self::getBonus($userId, $bonusType);
        if ($bonus == 0) {
            return $value;
        }
        return $value * (1 + ($bonus / 100));
    }

    /**
     * Devuelve el bono de un tipo, priorizando la suma raza+facción
     */
    private static function loadUserBonuses($userId)
    {
        global $db;

        if (!isset($db)) {
            $db = Database::get();
        }

        $prefix = 'uni1_';
        if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
        elseif (defined('PREFIX')) $prefix = PREFIX;

        self::$cache[$userId] = array();

        // Cargar datos del usuario (race_id, faction_id)
        $user = $db->selectSingle(
            "SELECT race_id, faction_id FROM `".$prefix."users` WHERE id = :uid;",
            array(':uid' => $userId)
        );

        if (!$user) return;

        $raceId    = (int)$user['race_id'];
        $factionId = (int)$user['faction_id'];

        // Cargar bonos de la raza
        if ($raceId > 0) {
            $race = $db->selectSingle(
                "SELECT * FROM `".$prefix."races` WHERE race_id = :rid;",
                array(':rid' => $raceId)
            );

            if ($race) {
                foreach ($race as $key => $val) {
                    if (strpos($key, 'bonus_') === 0 && is_numeric($val)) {
                        self::$cache[$userId][$key] = (float)$val;
                    }
                }
            }
        }

        // Cargar bonos de la facción (se SUMAN a los de la raza)
        if ($factionId > 0) {
            $faction = $db->selectSingle(
                "SELECT * FROM `".$prefix."factions` WHERE faction_id = :fid;",
                array(':fid' => $factionId)
            );

            if ($faction) {
                foreach ($faction as $key => $val) {
                    if (strpos($key, 'bonus_') === 0 && is_numeric($val)) {
                        if (!isset(self::$cache[$userId][$key])) {
                            self::$cache[$userId][$key] = 0;
                        }
                        self::$cache[$userId][$key] += (float)$val;
                    }
                }
            }
        }

        // ========================================================
        // ASTROIO v2.4.10 (base v2.6) — TALENTOS DE RAZA
        // Cada punto invertido en el arbol de talentos de la raza
        // agrega su valor al bonus correspondiente. Si el jugador
        // cambia de raza, los puntos se borran (RaceTalentHelper::wipe)
        // y el arbol vuelve a empezar desde 0.
        // ========================================================
        if (class_exists('RaceTalentHelper')) {
            $talentBonus = RaceTalentHelper::getBonusesForUser($userId, $raceId);
            foreach ($talentBonus as $key => $val) {
                if (!isset(self::$cache[$userId][$key])) {
                    self::$cache[$userId][$key] = 0;
                }
                self::$cache[$userId][$key] += (float)$val;
            }
        }
    }

    public static function clearCache($userId = null)
    {
        if ($userId === null) {
            self::$cache = array();
        } else {
            unset(self::$cache[(int)$userId]);
        }
    }

    // ============================================================
    // ASTROIO v2.4.10 — FOTOS OFICIALES (fallback)
    // Las 12 fotos viven en styles/theme/gow/razas/ y /facciones/.
    // Si la BD tiene la columna race_img/faction_img vacia (pasa en
    // el servidor real), se busca la foto por NOMBRE y, si no cuadra,
    // por ID (1-6). Asi cada raza y faccion muestra SIEMPRE su foto.
    // ============================================================

    /**
     * Foto oficial de una raza. Devuelve la ruta relativa al tema
     * (ej. 'razas/raza_predators.jpg') o '' si no hay coincidencia.
     */
    public static function imgForRace($raceRow)
    {
        if (!is_array($raceRow)) return '';

        // 1) Por nombre (coincidencia parcial, sin acentos ni mayusculas)
        $name = strtolower((string)(isset($raceRow['race_name']) ? $raceRow['race_name'] : ''));
        $mapByName = array(
            'predator' => 'razas/raza_predators.jpg',
            'alien'    => 'razas/raza_aliens.jpg',
            'charter'  => 'razas/raza_charter.jpg',
            'sarck'    => 'razas/raza_sarcks.jpg',
            'espectr'  => 'razas/raza_espectros.jpg',
            'mercader' => 'razas/raza_mercaderes.jpg',
        );
        foreach ($mapByName as $needle => $img) {
            if ($name !== '' && strpos($name, $needle) !== false) {
                return $img;
            }
        }

        // 2) Por icono de texto (ej. 'PRED', 'ALIE', 'CHAR', 'SARC')
        $icon = strtoupper((string)(isset($raceRow['race_icon']) ? $raceRow['race_icon'] : ''));
        $mapByIcon = array(
            'PRED' => 'razas/raza_predators.jpg',
            'ALIE' => 'razas/raza_aliens.jpg',
            'CHAR' => 'razas/raza_charter.jpg',
            'SARC' => 'razas/raza_sarcks.jpg',
            'ESPE' => 'razas/raza_espectros.jpg',
            'MERC' => 'razas/raza_mercaderes.jpg',
        );
        if ($icon !== '' && isset($mapByIcon[$icon])) {
            return $mapByIcon[$icon];
        }

        // 3) Por ID (1-6, orden de instalacion)
        $mapById = array(
            1 => 'razas/raza_predators.jpg',
            2 => 'razas/raza_aliens.jpg',
            3 => 'razas/raza_charter.jpg',
            4 => 'razas/raza_sarcks.jpg',
            5 => 'razas/raza_espectros.jpg',
            6 => 'razas/raza_mercaderes.jpg',
        );
        $id = (int)(isset($raceRow['race_id']) ? $raceRow['race_id'] : 0);
        if ($id > 0 && isset($mapById[$id])) {
            return $mapById[$id];
        }

        return '';
    }

    /**
     * Foto oficial de una faccion. Devuelve la ruta relativa al tema
     * (ej. 'facciones/fac_pirata.jpg') o '' si no hay coincidencia.
     */
    public static function imgForFaction($factionRow)
    {
        if (!is_array($factionRow)) return '';

        // 1) Por nombre (coincidencia parcial)
        $name = strtolower((string)(isset($factionRow['faction_name']) ? $factionRow['faction_name'] : ''));
        $mapByName = array(
            'pirat'   => 'facciones/fac_pirata.jpg',
            'minero'  => 'facciones/fac_mineros.jpg',
            'miner'   => 'facciones/fac_mineros.jpg',
            'defens'  => 'facciones/fac_defensores.jpg',
            'tecnocr' => 'facciones/fac_tecnocratas.jpg',
            'explor'  => 'facciones/fac_exploradores.jpg',
            'comerc'  => 'facciones/fac_comerciantes.jpg',
        );
        foreach ($mapByName as $needle => $img) {
            if ($name !== '' && strpos($name, $needle) !== false) {
                return $img;
            }
        }

        // 2) Por icono de texto
        $icon = strtoupper((string)(isset($factionRow['faction_icon']) ? $factionRow['faction_icon'] : ''));
        $mapByIcon = array(
            'PIRA' => 'facciones/fac_pirata.jpg',
            'MINE' => 'facciones/fac_mineros.jpg',
            'DEFE' => 'facciones/fac_defensores.jpg',
            'TECN' => 'facciones/fac_tecnocratas.jpg',
            'EXPL' => 'facciones/fac_exploradores.jpg',
            'COME' => 'facciones/fac_comerciantes.jpg',
        );
        if ($icon !== '' && isset($mapByIcon[$icon])) {
            return $mapByIcon[$icon];
        }

        // 3) Por ID (1-6)
        $mapById = array(
            1 => 'facciones/fac_pirata.jpg',
            2 => 'facciones/fac_mineros.jpg',
            3 => 'facciones/fac_defensores.jpg',
            4 => 'facciones/fac_tecnocratas.jpg',
            5 => 'facciones/fac_exploradores.jpg',
            6 => 'facciones/fac_comerciantes.jpg',
        );
        $id = (int)(isset($factionRow['faction_id']) ? $factionRow['faction_id'] : 0);
        if ($id > 0 && isset($mapById[$id])) {
            return $mapById[$id];
        }

        return '';
    }
}