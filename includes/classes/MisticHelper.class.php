<?php

/**
 * MisticHelper.class.php
 * Sistema de Elementos Místicos - AstroIO v1.0
 * 
 * Este Helper se encarga de leer la BD y calcular los bonus/nerfs
 * reales que tiene el jugador según el nivel de sus Místicos.
 */

class MisticHelper
{
    /**
     * Devuelve un array con todos los bonus/nerfs acumulados del jugador.
     * Ejemplo de retorno: ['ataque' => 5, 'tiempo_vuelo' => -7.5, 'defensa' => 10]
     */
    public static function getBonuses($userId)
    {
        $db = Database::get();
        
        $query = "SELECT u.level, i.bonus_json 
                  FROM %%USERS_MISTIC%% u 
                  INNER JOIN %%MISTIC_ITEMS%% i ON u.mistic_id = i.id 
                  WHERE u.user_id = :uid AND u.level > 0";
                  
        $result = $db->select($query, array(':uid' => $userId));
        
        $totalBonuses = array();
        
        if (!empty($result)) {
            foreach ($result as $row) {
                $level = (int)$row['level'];
                $bonusData = json_decode($row['bonus_json'], true);
                
                if (is_array($bonusData)) {
                    foreach ($bonusData as $statName => $maxStatValue) {
                        // 🆕 Nueva regla: El valor del JSON se multiplica por el nivel actual
                        $realValue = $maxStatValue * $level;
                        
                        if (!isset($totalBonuses[$statName])) {
                            $totalBonuses[$statName] = 0;
                        }
                        $totalBonuses[$statName] += $realValue;
                    }
                }
            }
        }
        
        return $totalBonuses;
    }

    /**
     * Función auxiliar para pedir un stat específico de forma más limpia.
     * Ejemplo: MisticHelper::getStat($userId, 'ataque');
     */
    public static function getStat($userId, $statName)
    {
        $bonuses = self::getBonuses($userId);
        return isset($bonuses[$statName]) ? $bonuses[$statName] : 0;
    }
}