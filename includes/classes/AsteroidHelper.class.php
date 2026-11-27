<?php
/**
 * AstroIO — AsteroidHelper
 * Sistema de asteroides aleatorios para el universo.
 *
 * Reglas:
 *  - Max 5 asteroides activos en todo el universo
 *  - 1 solo tipo de contenido por asteroide (metal, cristal, deuterio o contenedor)
 *  - Regen individual 24h tras reciclarse
 *  - 15% prob. contenedor, con rareza 55/25/15/5
 *  - Mision de reciclaje (32) nativa
 */

class AsteroidHelper
{
    const MAX_ASTEROIDS  = 5;
    const REGEN_TIME     = 86400;      // 24h
    const CHEST_CHANCE   = 15;         // 15%
    const MAX_METAL      = 5000000;
    const MAX_CRYSTAL    = 4000000;
    const MAX_DEUTERIUM  = 2000000;

    private static function db()     { return Database::get(); }
    private static function prefix() { return defined('DB_PREFIX') ? DB_PREFIX : 'uni1_'; }

    /* ============================================================
     *  CRON — Regenera asteroides reciclados y crea los que falten
     * ============================================================ */
    public static function processCron()
    {
        $db     = self::db();
        $prefix = self::prefix();

        // 1) Borrar asteroides reciclados hace mas de 24h
        $db->delete(
            "DELETE FROM `".$prefix."asteroids`
             WHERE `recycled` = 1
               AND `recycled_at` > 0
               AND `recycled_at` + :regen <= :now;",
            array(':regen' => self::REGEN_TIME, ':now' => TIMESTAMP)
        );

        // 2) Contar activos
        $row = $db->selectSingle(
            "SELECT COUNT(*) AS c FROM `".$prefix."asteroids` WHERE `recycled` = 0;"
        );
        $activeCount = empty($row) ? 0 : (int) $row['c'];

        // 3) Generar los que falten
        $toSpawn = self::MAX_ASTEROIDS - $activeCount;
        $spawned = 0;

        for ($i = 0; $i < $toSpawn; $i++) {
            if (self::spawnOne()) {
                $spawned++;
            }
        }

        return $spawned;
    }

    /* ============================================================
     *  SPAWN — Crea un asteroide aleatorio
     * ============================================================ */
    public static function spawnOne()
    {
        $db     = self::db();
        $prefix = self::prefix();
        $config = Config::get();

        $maxG = max(1, (int) $config->max_galaxy);
        $maxS = max(1, (int) $config->max_system);
        $maxP = max(4, (int) $config->max_planets - 3);

        $galaxy = $system = $planet = 0;
        $found  = false;

        for ($i = 0; $i < 30; $i++) {
            $g = mt_rand(1, $maxG);
            $s = mt_rand(1, $maxS);
            $p = mt_rand(4, $maxP);

            // Hay planeta?
            $planetExists = $db->selectSingle(
                "SELECT `id` FROM %%PLANETS%%
                 WHERE `galaxy` = :g AND `system` = :s AND `planet` = :p
                   AND `planet_type` = 1 LIMIT 1;",
                array(':g' => $g, ':s' => $s, ':p' => $p)
            );
            if (!empty($planetExists)) continue;

            // Hay asteroide activo en esa posicion?
            $astExists = $db->selectSingle(
                "SELECT `id` FROM `".$prefix."asteroids`
                 WHERE `galaxy` = :g AND `system` = :s AND `planet` = :p
                   AND `recycled` = 0 LIMIT 1;",
                array(':g' => $g, ':s' => $s, ':p' => $p)
            );
            if (!empty($astExists)) continue;

            $galaxy = $g;
            $system = $s;
            $planet = $p;
            $found  = true;
            break;
        }

        if (!$found) return false;

        // Decidir tipo segun probabilidades (45/25/15/15)
        $roll = mt_rand(1, 100);

        if ($roll <= 15) {
            // 15% contenedor
            $type        = 'container';
            $amount      = 1;
            $chestRarity = self::rollChestRarity();
        } elseif ($roll <= 30) {
            // 15% deuterio (50000 - 2M)
            $type        = 'deuterium';
            $amount      = mt_rand(50000, self::MAX_DEUTERIUM);
            $chestRarity = null;
        } elseif ($roll <= 55) {
            // 25% cristal (200000 - 4M)
            $type        = 'crystal';
            $amount      = mt_rand(200000, self::MAX_CRYSTAL);
            $chestRarity = null;
        } else {
            // 45% metal (300000 - 5M)
            $type        = 'metal';
            $amount      = mt_rand(300000, self::MAX_METAL);
            $chestRarity = null;
        }

        $db->insert(
            "INSERT INTO `".$prefix."asteroids`
             (`galaxy`, `system`, `planet`, `type`, `amount`, `chest_rarity`, `spawn_time`, `recycled`)
             VALUES (:g, :s, :p, :t, :a, :cr, :st, 0);",
            array(
                ':g'  => $galaxy,
                ':s'  => $system,
                ':p'  => $planet,
                ':t'  => $type,
                ':a'  => $amount,
                ':cr' => $chestRarity,
                ':st' => TIMESTAMP
            )
        );

        return true;
    }

    /* ============================================================
     *  RAREZA DEL COFRE (55/25/15/5)
     * ============================================================ */
    public static function rollChestRarity()
    {
        $roll = mt_rand(1, 100);
        if ($roll <= 55) return 'common';
        if ($roll <= 80) return 'rare';
        if ($roll <= 95) return 'epic';
        return 'mythic';
    }

    /* ============================================================
     *  CONSULTAS
     * ============================================================ */
    public static function getAsteroidsInSystem($galaxy, $system)
    {
        $db     = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT * FROM `".$prefix."asteroids`
             WHERE `galaxy` = :g AND `system` = :s AND `recycled` = 0;",
            array(':g' => (int) $galaxy, ':s' => (int) $system)
        );

        $result = array();
        if (is_array($rows)) {
            foreach ($rows as $row) {
                $result[(int) $row['planet']] = $row;
            }
        }
        return $result;
    }

    public static function getAsteroidAt($galaxy, $system, $planet)
    {
        $db     = self::db();
        $prefix = self::prefix();

        return $db->selectSingle(
            "SELECT * FROM `".$prefix."asteroids`
             WHERE `galaxy` = :g AND `system` = :s AND `planet` = :p
               AND `recycled` = 0 LIMIT 1;",
            array(':g' => (int) $galaxy, ':s' => (int) $system, ':p' => (int) $planet)
        );
    }

    /* ============================================================
     *  RECICLAJE — Marca el asteroide como reciclado y devuelve
     *             que se recogio + si lleva contenedor
     * ============================================================ */
    public static function recycleAsteroid($fleet, $asteroid, $fleetData, $shipStorageFactor)
    {
        global $pricelist;

        $db     = self::db();
        $prefix = self::prefix();

        // Calcular bodega disponible (misma logica que MissionCaseRecycling)
        $recyclerStorage   = 0;
        $otherFleetStorage = 0;

        foreach ($fleetData as $shipId => $shipAmount) {
            if ($shipId == 209 || $shipId == 219) {
                $recyclerStorage += $pricelist[$shipId]['capacity'] * $shipAmount;
            } else {
                $otherFleetStorage += $pricelist[$shipId]['capacity'] * $shipAmount;
            }
        }

        $recyclerStorage   *= $shipStorageFactor;
        $otherFleetStorage *= $shipStorageFactor;

        $incomingGoods = (int) $fleet['fleet_resource_metal']
                       + (int) $fleet['fleet_resource_crystal']
                       + (int) $fleet['fleet_resource_deuterium'];

        $totalStorage = $recyclerStorage + min(0, $otherFleetStorage - $incomingGoods);
        if ($totalStorage < 0) $totalStorage = 0;

        $collected   = array(901 => 0, 902 => 0, 903 => 0);
        $hasChest    = false;
        $chestRarity = null;

        if ($asteroid['type'] === 'container') {
            $hasChest    = true;
            $chestRarity = !empty($asteroid['chest_rarity']) ? $asteroid['chest_rarity'] : 'common';
        } else {
            $amt = min((int) $asteroid['amount'], (int) $totalStorage);
            if ($asteroid['type'] === 'metal')     $collected[901] = $amt;
            if ($asteroid['type'] === 'crystal')   $collected[902] = $amt;
            if ($asteroid['type'] === 'deuterium') $collected[903] = $amt;
        }

        // Marcar asteroide como reciclado
        $db->update(
            "UPDATE `".$prefix."asteroids`
             SET `recycled` = 1, `recycled_by` = :uid, `recycled_at` = :now
             WHERE `id` = :id;",
            array(
                ':uid' => (int) $fleet['fleet_owner'],
                ':now' => TIMESTAMP,
                ':id'  => (int) $asteroid['id']
            )
        );

        return array(
            'collected'    => $collected,
            'chest'        => $hasChest,
            'chest_rarity' => $chestRarity,
            'type'         => $asteroid['type']
        );
    }

    /* ============================================================
     *  ENTREGA DEL CONTENEDOR al volver la flota
     * ============================================================ */
    public static function deliverChest($userId)
    {
        $db     = self::db();
        $prefix = self::prefix();

        $db->update(
            "UPDATE `".$prefix."users` SET `containers` = `containers` + 1 WHERE `id` = :uid;",
            array(':uid' => (int) $userId)
        );

        return true;
    }
}