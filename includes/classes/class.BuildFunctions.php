<?php

/**
 *  2Moons
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 *
 * AstroIO v3.6 (VIP Bonus):
 *  - Se anaden los bonus VIP de tiempo de construccion e investigacion.
 *  - Se cargan desde VIPHelper::getBonus($userId, 'build_time'|'research_time')
 *  - Se aplican en getBuildingTime() para:
 *      - Edificios (reslist['build'])
 *      - Investigaciones (reslist['tech'])
 *  - El bono es negativo (ej: -0.10 = -10% tiempo)
 *
 * ✅ AstroIO v3.7 (POTENCIADOR "Pot. Hangar"):
 *  - Nuevo método estático getDirectBoosterBonus() que lee DIRECTAMENTE
 *    de `uni1_users_boosters` + `uni1_boosters` (sin depender de BoosterHelper)
 *  - Si BoosterHelper existe → se usa (comportamiento original)
 *  - Si NO existe → se usa el fallback directo
 *  - Aplica SOLO a naves (reslist['fleet']):
 *      🔧 Pot. Hangar  → booster_type = 'ship_time'  (-20% tiempo de naves)
 *  - Se suma al bonus de razas/facciones y VIP.
 *
 * ✅ AstroIO v3.8 (MÍSTICOS):
 *  - Se integra MisticHelper para aplicar descuentos de tiempo y costos.
 *  - Tiempos: MECRIC (construccion), CHAOS (investigacion), MAGIC (naves), ELEMENTAL (defensas).
 *  - Costos: DESTRICT (estructuras), MIND/MECRIC (naves), ENERGY (investigacion), MAGIC (misiles).
 */

// ============================================
// ASTROIO - Cargar VIPHelper explicitamente
// ============================================
if (!class_exists('VIPHelper')) {
    $__vipFile = ROOT_PATH . 'includes/classes/VIPHelper.class.php';
    if (file_exists($__vipFile)) {
        require_once $__vipFile;
    }
}
// ============================================

// ============================================
// ASTROIO - Cargar MisticHelper explicitamente
// ============================================
if (!class_exists('MisticHelper')) {
    $__misticFile = ROOT_PATH . 'includes/classes/MisticHelper.class.php';
    if (file_exists($__misticFile)) {
        require_once $__misticFile;
    }
}
// ============================================


class BuildFunctions
{

    static $bonusList	= array(
        'Attack',
        'Defensive',
        'Shield',
        'BuildTime',
        'ResearchTime',
        'ShipTime',
        'DefensiveTime',
        'Resource',
        'Energy',
        'ResourceStorage',
        'ShipStorage',
        'FlyTime',
        'FleetSlots',
        'Planets',
        'SpyPower',
        'Expedition',
        'GateCoolTime',
        'MoreFound',
    );

    // Caché para no saturar la base de datos al calcular bonos de místicos
    private static $misticBonusesCache = array();

    public static function getBonusList()
    {
        return self::$bonusList;
    }

    private static function getMisticBonuses($userId) {
        if (!class_exists('MisticHelper') || empty($userId)) return array();
        if (!isset(self::$misticBonusesCache[$userId])) {
            self::$misticBonusesCache[$userId] = MisticHelper::getBonuses($userId);
        }
        return self::$misticBonusesCache[$userId];
    }

    /**
     * 🆕 AstroIO v3.7 - Fallback directo si BoosterHelper no existe
     * ------------------------------------------------------------
     * Lee el valor total de un potenciador activo del jugador,
     * filtrando por su `booster_type`, DIRECTAMENTE de la BD.
     *
     * @param int    $userId  ID del jugador
     * @param string $type    Tipo de booster ('ship_time', 'research_slots', etc.)
     * @return int            Valor total del bonus (sin dividir por 100)
     */
    public static function getDirectBoosterBonus($userId, $type)
    {
        try {
            $db = Database::get();
            $prefix = 'uni1_';
            if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
            elseif (defined('PREFIX')) $prefix = PREFIX;

            $row = $db->selectSingle(
                "SELECT SUM(b.booster_value) AS total_bonus
                 FROM `".$prefix."users_boosters` ub
                 INNER JOIN `".$prefix."boosters` b ON b.booster_id = ub.booster_id
                 WHERE ub.user_id = :uid 
                   AND ub.expires_at > :now
                   AND b.booster_type = :type;",
                array(
                    ':uid'  => (int) $userId,
                    ':now'  => TIMESTAMP,
                    ':type' => $type,
                )
            );
            return !empty($row['total_bonus']) ? (int) $row['total_bonus'] : 0;
        } catch (Exception $e) {
            return 0;
        }
    }

    public static function getRestPrice($USER, $PLANET, $Element, $elementPrice = NULL)
    {
        global $resource;

        if(!isset($elementPrice)) {
            $elementPrice	= self::getElementPrice($USER, $PLANET, $Element);
        }

        $overflow	= array();

        foreach ($elementPrice as $resType => $resPrice) {
            $available			= isset($PLANET[$resource[$resType]]) ? $PLANET[$resource[$resType]] : $USER[$resource[$resType]];
            $overflow[$resType] = max($resPrice - floor($available), 0);
        }

        return $overflow;
    }

    public static function getElementPrice($USER, $PLANET, $Element, $forDestroy = false, $forLevel = NULL) {
        global $pricelist, $resource, $reslist;

        if (in_array($Element, $reslist['fleet']) || in_array($Element, $reslist['defense']) || in_array($Element, $reslist['missile'])) {
            $elementLevel = $forLevel;
        } elseif (isset($forLevel)) {
            $elementLevel = $forLevel;
        } elseif (isset($PLANET[$resource[$Element]])) {
            $elementLevel = $PLANET[$resource[$Element]];
        } elseif (isset($USER[$resource[$Element]])) {
            $elementLevel = $USER[$resource[$Element]];
        } else {
            return array();
        }

        // ============================================
        // ASTROIO - Determinar bono de coste según tipo de elemento
        // ============================================
        $costBonus = 0;

        if (class_exists('RaceFactionHelper') && isset($USER['id'])) {
            if (in_array($Element, $reslist['fleet'])) {
                // Naves
                $costBonus = RaceFactionHelper::getBonus($USER['id'], 'bonus_ship_cost') / 100;
            } elseif (in_array($Element, $reslist['defense']) || in_array($Element, $reslist['missile'])) {
                // Defensas y misiles
                $costBonus = RaceFactionHelper::getBonus($USER['id'], 'bonus_defense_cost') / 100;
            } elseif (in_array($Element, $reslist['tech'])) {
                // Investigaciones
                $costBonus = RaceFactionHelper::getBonus($USER['id'], 'bonus_research_cost') / 100;
            }
        }
        // ============================================

        // ============================================
        // ASTROIO v1.5 - Determinar bono de coste (Místicos)
        // ============================================
        $misticCostBonus = 0;

        if (isset($USER['id']) && class_exists('MisticHelper')) {
            $mBonuses = self::getMisticBonuses($USER['id']);

            if (in_array($Element, $reslist['build'])) {
                // DESTRICT: -2% Costo de estructuras
                $misticCostBonus += isset($mBonuses['costo_estructuras']) ? ($mBonuses['costo_estructuras'] / 100) : 0;
            } elseif (in_array($Element, $reslist['fleet'])) {
                // MAGIC: -2% Costo de flotas
                $misticCostBonus += isset($mBonuses['costo_flotas']) ? ($mBonuses['costo_flotas'] / 100) : 0;
            } elseif (in_array($Element, $reslist['defense']) || in_array($Element, $reslist['missile'])) {
                // MIND: -2% Costo de defensas
                $misticCostBonus += isset($mBonuses['costo_defensas']) ? ($mBonuses['costo_defensas'] / 100) : 0;
            } elseif (in_array($Element, $reslist['tech'])) {
                // ENERGY: -2% Costo de Investigaciones
                $misticCostBonus += isset($mBonuses['costo_investigacion']) ? ($mBonuses['costo_investigacion'] / 100) : 0;
            }
        }
        
        $totalCostBonus = $costBonus + $misticCostBonus;
        // ============================================

        // ============================================
        // ASTROIO - Factor de coste de OFICIALES
        // Los oficiales (600-699) usan factor 1.05 = +5% por nivel
        // Esto sobreescribe cualquier factor de la BD
        // ============================================
        // $customFactor = NULL;
        // if ($Element >= 600 && $Element < 700) {
        //    $customFactor = 1.05;
        // }
        // ============================================

        $price	= array();
        foreach ($reslist['ressources'] as $resType)
        {
            if (!isset($pricelist[$Element]['cost'][$resType])) {
                continue;
            }
            $ressourceAmount	= $pricelist[$Element]['cost'][$resType];

            if ($ressourceAmount == 0) {
                continue;
            }

            $price[$resType]	= $ressourceAmount;

            // ============================================
            // ASTROIO - Aplicar factor (oficiales o BD)
            // ============================================
            if(isset($pricelist[$Element]['factor']) && $pricelist[$Element]['factor'] != 0 && $pricelist[$Element]['factor'] != 1) {
                $price[$resType]	*= pow($pricelist[$Element]['factor'], $elementLevel);
            }
            // ============================================

            if($forLevel && (in_array($Element, $reslist['fleet']) || in_array($Element, $reslist['defense']) || in_array($Element, $reslist['missile']))) {
                $price[$resType]	*= $elementLevel;
            }

            if($forDestroy === true) {
                $price[$resType]	/= 2;
            }

            // ============================================
            // ASTROIO - Aplicar bono de coste (razas/facciones + místicos)
            // ============================================
            if ($totalCostBonus != 0) {
                $price[$resType]	= $price[$resType] * (1 + $totalCostBonus);
                $price[$resType]	= max(0, round($price[$resType]));
            }
            // ============================================
        }

        return $price;
    }

    public static function isTechnologieAccessible($USER, $PLANET, $Element)
    {
        global $requeriments, $resource;

        if(!isset($requeriments[$Element]))
            return true;

        foreach($requeriments[$Element] as $ReqElement => $EleLevel)
        {
            if (
                (isset($USER[$resource[$ReqElement]]) && $USER[$resource[$ReqElement]] < $EleLevel) ||
                (isset($PLANET[$resource[$ReqElement]]) && $PLANET[$resource[$ReqElement]] < $EleLevel)
            ) {
                return false;
            }
        }
        return true;
    }

    public static function getBuildingTime($USER, $PLANET, $Element, $elementPrice = NULL, $forDestroy = false, $forLevel = NULL)
    {
        global $resource, $reslist, $requeriments;

        $config	= Config::get($USER['universe']);

        $time   = 0;

        if(!isset($elementPrice)) {
            $elementPrice	= self::getElementPrice($USER, $PLANET, $Element, $forDestroy, $forLevel);
        }

        $elementCost	= 0;

        if(isset($elementPrice[901])) {
            $elementCost	+= $elementPrice[901];
        }

        if(isset($elementPrice[902])) {
            $elementCost	+= $elementPrice[902];
        }

        // 🆕 v2.4.0 — el tiempo de construcción pondera también Norium (932)
        // y Germanium (933) con el factor equivalente ×2.5 (mismo criterio atk/k).
        if(isset($elementPrice[932])) {
            $elementCost	+= $elementPrice[932] * 2.5;
        }
        if(isset($elementPrice[933])) {
            $elementCost	+= $elementPrice[933] * 2.5;
        }

        // ============================================
        // ASTROIO - Determinar bono de tiempo según tipo (razas/facciones)
        // ============================================
        $timeBonus = 0;

        if (class_exists('RaceFactionHelper') && isset($USER['id'])) {
            if (in_array($Element, $reslist['build'])) {
                // Edificios
                $timeBonus = RaceFactionHelper::getBonus($USER['id'], 'bonus_build_time') / 100;
            } elseif (in_array($Element, $reslist['fleet'])) {
                // Naves
                $timeBonus = RaceFactionHelper::getBonus($USER['id'], 'bonus_ship_time') / 100;
            } elseif (in_array($Element, $reslist['defense'])) {
                // Defensas
                $timeBonus = RaceFactionHelper::getBonus($USER['id'], 'bonus_defense_time') / 100;
            } elseif (in_array($Element, $reslist['tech'])) {
                // Investigaciones
                $timeBonus = RaceFactionHelper::getBonus($USER['id'], 'bonus_research_time') / 100;
            }
        }
        // ============================================

        // ============================================
        // ASTROIO - Bonus VIP de tiempo (v3.6)
        // Se suma al bonus de razas/facciones.
        // Aplica SOLO a edificios e investigaciones.
        // ============================================
        $vipTimeBonus = 0;

        if (class_exists('VIPHelper') && isset($USER['id'])) {
            if (in_array($Element, $reslist['build'])) {
                // Edificios → build_time
                $vipTimeBonus = (float) VIPHelper::getBonus($USER['id'], 'build_time');
            } elseif (in_array($Element, $reslist['tech'])) {
                // Investigaciones → research_time
                $vipTimeBonus = (float) VIPHelper::getBonus($USER['id'], 'research_time');
            }
        }
        // ============================================

        // ============================================
        // 🆕 ASTROIO v3.7 - Bonus Potenciador "Pot. Hangar"
        // ------------------------------------------------------------
        // Reduce el tiempo de construcción de NAVES (-20% con valor -20).
        // Se lee de `uni1_users_boosters` filtrando booster_type='ship_time'.
        // Si BoosterHelper existe, se usa primero; si no, fallback directo.
        // Aplica SOLO a naves (reslist['fleet']).
        // ============================================
        $hangarTimeBonus = 0;

        if (isset($USER['id']) && in_array($Element, $reslist['fleet'])) {
            if (class_exists('BoosterHelper')) {
                $hangarTimeBonus = (float) BoosterHelper::getBonus($USER['id'], 'ship_time') / 100;
            } else {
                // Fallback directo desde BD
                $hangarTimeBonus = (float) self::getDirectBoosterBonus($USER['id'], 'ship_time') / 100;
            }
        }
        // ============================================

        // ============================================
        // ASTROIO v1.5 - Determinar bono de tiempo (Místicos)
        // ============================================
        $misticTimeBonus = 0;

        if (isset($USER['id']) && class_exists('MisticHelper')) {
            $mBonuses = self::getMisticBonuses($USER['id']);

            if (in_array($Element, $reslist['build'])) {
                // MECRIC: -2% Tiempo de construcción
                $misticTimeBonus += isset($mBonuses['tiempo_construccion']) ? ($mBonuses['tiempo_construccion'] / 100) : 0;
            } elseif (in_array($Element, $reslist['fleet'])) {
                // MAGIC: -2% Tiempo de construcción naves
                $misticTimeBonus += isset($mBonuses['tiempo_naves']) ? ($mBonuses['tiempo_naves'] / 100) : 0;
            } elseif (in_array($Element, $reslist['defense'])) {
                // ELEMENTAL: -2% Tiempo de construcción defensas
                $misticTimeBonus += isset($mBonuses['tiempo_defensas']) ? ($mBonuses['tiempo_defensas'] / 100) : 0;
            } elseif (in_array($Element, $reslist['tech'])) {
                // CHAOS: -2% Tiempo de Investigación
                $misticTimeBonus += isset($mBonuses['tiempo_investigacion']) ? ($mBonuses['tiempo_investigacion'] / 100) : 0;
            }
        }
        // ============================================
		
        if	   (in_array($Element, $reslist['build'])) {
            $time	= $elementCost / ($config->game_speed * (1 + $PLANET[$resource[14]])) * pow(0.5, $PLANET[$resource[15]]) * (1 + $USER['factor']['BuildTime']);
        } elseif (in_array($Element, $reslist['fleet'])) {
            $time	= $elementCost / ($config->game_speed * (1 + $PLANET[$resource[21]])) * pow(0.5, $PLANET[$resource[15]]) * (1 + $USER['factor']['ShipTime']);
        } elseif (in_array($Element, $reslist['defense'])) {
            $time	= $elementCost / ($config->game_speed * (1 + $PLANET[$resource[21]])) * pow(0.5, $PLANET[$resource[15]]) * (1 + $USER['factor']['DefensiveTime']);
        } elseif (in_array($Element, $reslist['tech'])) {
            if(is_numeric($PLANET[$resource[31].'_inter']))
            {
                $Level	= $PLANET[$resource[31]];
            } else {
                $Level = 0;
                foreach($PLANET[$resource[31].'_inter'] as $Levels)
                {
                    if(!isset($requeriments[$Element][31]) || $Levels >= $requeriments[$Element][31])
                        $Level += $Levels;
                }
            }

            $time	= $elementCost / (1000 * (1 + $Level)) / ($config->game_speed / 2500) * pow(1 - $config->factor_university / 100, $PLANET[$resource[6]]) * (1 + $USER['factor']['ResearchTime']);
        }

        // ============================================
        // ASTROIO - Aplicar bono de tiempo (razas/facciones)
        // Si el bono es -10%, multiplicamos por 0.9
        // ============================================
        if ($timeBonus != 0 && $time > 0) {
            $time	= $time * (1 + $timeBonus);
        }
        // ============================================

        // ============================================
        // ASTROIO - Aplicar bono VIP de tiempo (v3.6)
        // Si el bono es -10%, multiplicamos por 0.9
        // Se aplica SOLO a edificios e investigaciones.
        // ============================================
        if ($vipTimeBonus != 0 && $time > 0) {
            $time	= $time * (1 + $vipTimeBonus);
        }
        // ============================================

        // ============================================
        // 🆕 ASTROIO v3.7 - Aplicar bono Pot. Hangar
        // Si el bono es -20%, multiplicamos por 0.8
        // Se aplica SOLO a naves (reslist['fleet']).
        // ============================================
        if ($hangarTimeBonus != 0 && $time > 0) {
            $time	= $time * (1 + $hangarTimeBonus);
        }
        // ============================================

        // ============================================
        // ASTROIO v3.8 - Aplicar bono de tiempo (Místicos)
        // ============================================
        if ($misticTimeBonus != 0 && $time > 0) {
            $time	= $time * (1 + $misticTimeBonus);
            //$time   = max(1, $time); // Asegurar que no quede en 0 o negativo
        }
        // ============================================

        // ============================================
        // 🆕 ASTROIO v3.3 - Oficial SUPERVISOR (ID 619)
        // Naves de élite (225 Corbeta de Asalto, 226 Acorazado de Asedio,
        // 227 Súper Carguero): -4% por nivel al tiempo de astillero
        // (nivel máx. 5 = -20%). El desbloqueo por niveles 1/3/5 lo
        // valida la BD (uni1_vars_require) vía isTechnologieAccessible().
        // No aplica al demoler (forDestroy).
        // ============================================
        if (!$forDestroy && $time > 0
            && in_array($Element, array(SHIP_ASSAULT_CORVETTE, SHIP_SIEGE_BATTLESHIP, SHIP_SUPER_CARGO))) {
            $supNivel	= isset($USER['rpg_supervisor']) ? min(5, max(0, (int) $USER['rpg_supervisor'])) : 0;
            if ($supNivel > 0) {
                $time	= $time * (1 - ($supNivel * 0.04));
            }
        }
        // ============================================

        if($forDestroy) {
            $time	= floor($time * 1300);
        } else {
            $time	= floor($time * 3600);
        }

        return max($time, $config->min_build_time);
    }

    public static function isElementBuyable($USER, $PLANET, $Element, $elementPrice = NULL, $forDestroy = false, $forLevel = NULL)
    {
        $rest	= self::getRestPrice($USER, $PLANET, $Element, $elementPrice);
        return count(array_filter($rest)) === 0;
    }

    public static function getMaxConstructibleElements($USER, $PLANET, $Element, $elementPrice = NULL)
    {
        global $resource, $reslist;

        if(!isset($elementPrice)) {
            $elementPrice	= self::getElementPrice($USER, $PLANET, $Element);
        }

        $maxElement	= array();

        foreach($elementPrice as $resourceID => $price)
        {
            if(isset($PLANET[$resource[$resourceID]]))
            {
                $maxElement[]	= floor($PLANET[$resource[$resourceID]] / $price);
            }
            elseif(isset($USER[$resource[$resourceID]]))
            {
                $maxElement[]	= floor($USER[$resource[$resourceID]] / $price);
            }
            else
            {
                throw new Exception("Unknown Ressource ".$resourceID." at element ".$Element.".");
            }
        }

        if(in_array($Element, $reslist['one'])) {
            $maxElement[]	= 1;
        }

        return min($maxElement);
    }

    public static function getMaxConstructibleRockets($USER, $PLANET, $Missiles = NULL)
    {
        global $resource, $reslist;

        if(!isset($Missiles))
        {
            $Missiles	= array();

            foreach($reslist['missile'] as $elementID)
            {
                $Missiles[$elementID]	= $PLANET[$resource[$elementID]];
            }
        }

        $BuildArray  	  	= !empty($PLANET['b_hangar_id']) ? unserialize($PLANET['b_hangar_id']) : array();
        $MaxMissiles   		= $PLANET[$resource[44]] * 10 * max(Config::get()->silo_factor, 1);

        foreach($BuildArray as $ElementArray) {
            if(isset($Missiles[$ElementArray[0]]))
                $Missiles[$ElementArray[0]] += $ElementArray[1];
        }

        $ActuMissiles  = $Missiles[502] + (2 * $Missiles[503]);
        $MissilesSpace = max(0, $MaxMissiles - $ActuMissiles);

        return array(
            502	=> $MissilesSpace,
            503	=> floor($MissilesSpace / 2),
        );
    }

    public static function getAvalibleBonus($Element)
    {
        global $pricelist;

        $elementBonus	= array();

        foreach(self::$bonusList as $bonus)
        {
            $temp	= (float) $pricelist[$Element]['bonus'][$bonus][0];
            if(empty($temp))
            {
                continue;
            }

            $elementBonus[$bonus]	= $pricelist[$Element]['bonus'][$bonus];
        }

        return $elementBonus;
    }
}
?>