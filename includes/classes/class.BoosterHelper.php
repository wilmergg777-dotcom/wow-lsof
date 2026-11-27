<?php
/**
 *  AstroIO - BoosterHelper
 *  Archivo: includes/classes/class.BoosterHelper.php
 *  
 *  Gestiona los potenciadores activos del jugador.
 *  
 *  Uso:
 *    BoosterHelper::getBonus($userId, 'resources');   // → 20 (o 0)
 *    BoosterHelper::getBonus($userId, 'energy');      // → 20 (o 0)
 *    BoosterHelper::getBonus($userId, 'exp_resources');
 *    BoosterHelper::getBonus($userId, 'exp_darkmatter');
 *    BoosterHelper::getBonus($userId, 'spy_power');
 */

class BoosterHelper
{
    /**
     * Cache de bonos por usuario para no consultar la BD múltiples veces en la misma petición
     */
    private static $cache = array();

    /**
     * Devuelve el % de bono activo del tipo indicado para el usuario.
     * 
     * @param int    $userId   ID del usuario
     * @param string $bonusType  Tipo de bono:
     *                           'resources'       → Producción de recursos
     *                           'energy'          → Producción de energía
     *                           'exp_resources'   → Recursos de expedición
     *                           'exp_darkmatter'  → MO de expedición
     *                           'spy_power'       → Poder de espionaje
     * @return float  El bono en % (ej: 20.0) o 0 si no tiene
     */
    public static function getBonus($userId, $bonusType)
    {
        $userId = (int)$userId;

        // Cargar todos los bonos del usuario (con caché)
        if (!isset(self::$cache[$userId])) {
            self::loadUserBoosters($userId);
        }

        return isset(self::$cache[$userId][$bonusType])
            ? (float)self::$cache[$userId][$bonusType]
            : 0;
    }

    /**
     * Devuelve TODOS los bonos activos del usuario (array por tipo)
     */
    public static function getAllBonuses($userId)
    {
        $userId = (int)$userId;
        if (!isset(self::$cache[$userId])) {
            self::loadUserBoosters($userId);
        }
        return self::$cache[$userId];
    }

    /**
     * Multiplica un valor por el bono correspondiente.
     * Ejemplo: 100 unidades de metal + bono 20% → 120
     * 
     * @param float  $value      Valor original
     * @param int    $userId     ID del usuario
     * @param string $bonusType  Tipo de bono
     * @return float  El valor con el bono aplicado
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
     * Carga desde la BD los boosters activos del usuario
     */
    private static function loadUserBoosters($userId)
    {
        global $db;

        if (!isset($db)) {
            $db = Database::get();
        }

        $prefix = 'uni1_';
        if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
        elseif (defined('PREFIX')) $prefix = PREFIX;

        self::$cache[$userId] = array();

        $rows = $db->select(
            "SELECT b.booster_type, b.booster_value
             FROM `".$prefix."users_boosters` ub
             INNER JOIN `".$prefix."boosters` b ON b.booster_id = ub.booster_id
             WHERE ub.user_id = :uid AND ub.expires_at > :now;",
            array(':uid' => $userId, ':now' => TIMESTAMP)
        );

        if (!is_array($rows)) {
            return;
        }

        foreach ($rows as $row) {
            $type = $row['booster_type'];
            $val  = (float)$row['booster_value'];

            // Si hay varios del mismo tipo, se acumulan
            if (!isset(self::$cache[$userId][$type])) {
                self::$cache[$userId][$type] = 0;
            }
            self::$cache[$userId][$type] += $val;
        }
    }

    /**
     * Limpia la caché (útil si cambian los boosters en la misma petición)
     */
    public static function clearCache($userId = null)
    {
        if ($userId === null) {
            self::$cache = array();
        } else {
            unset(self::$cache[(int)$userId]);
        }
    }
}