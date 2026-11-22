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
    }

    public static function clearCache($userId = null)
    {
        if ($userId === null) {
            self::$cache = array();
        } else {
            unset(self::$cache[(int)$userId]);
        }
    }
}