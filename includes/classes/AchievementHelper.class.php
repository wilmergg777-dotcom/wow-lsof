<?php
/**
 * AchievementHelper.class.php
 * Sistema de Logros AstroIO v1.3 — Expansión de Oficiales + Consejo Imperial + Minas Norio/Germanio
 * 
 * Logica:
 * - 19 cadenas, 10 niveles cada una (190 logros)
 *   * 12 originales (building + research)
 *   * 4 de oficiales individuales (officier)
 *   * 1 de conjunto (officier_all): Consejo Imperial
 *   * 2 nuevas v1.3 (v2.4.9): minas de Norio y Germanio (expansión migration_10)
 * - Solo se muestra el nivel actual de cada cadena
 * - Al reclamar un nivel, se desbloquea el siguiente
 * - Recompensa en Materia Oscura (MO)
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

class AchievementHelper
{
    private static function prefix()
    {
        return 'uni1_';
    }

    /**
     * Mapeo de nombres legibles para los requisitos
     * v1.1: añadidos los 4 oficiales con progresión
     * v1.2: añadido el conjunto 'all' (Consejo Imperial) con detalle dinámico
     */
    private static function getRequirementName($key, $achievementLevel = 0)
    {
        // 🟢 Caso especial para el Consejo Imperial (officier_all)
        if ($key === 'all') {
            if ($achievementLevel == 10) {
                return "Geo 20 + Alm 20 + Ing 10 + Tec 10";
            }
            $req = $achievementLevel * 2;
            return "Geo {$req} + Alm {$req}";
        }

        $nameMap = [
            // === Edificios ===
            'metal_mine'           => 'Mina de metal',
            'crystal_mine'         => 'Mina de cristal',
            'deuterium_sintetizer' => 'Sintetizador de deuterio',
            'norium_mine'          => 'Mina de norio',
            'germanium_mine'       => 'Mina de germanio',
            'solar_plant'          => 'Planta de energia solar',
            'laboratory'           => 'Laboratorio de investigacion',
            'phalanx'              => 'Sensor Phalanx',
            'hangar'               => 'Hangar',

            // === Investigaciones ===
            'spy_tech'             => 'Tecnologia de espionaje',
            'computer_tech'        => 'Tecnologia de computacion',
            'defence_tech'         => 'Tecnologia de defensa',
            'shield_tech'          => 'Tecnologia de escudo',
            'expedition_tech'      => 'Tecnologia de expedicion',

            // === Oficiales individuales (v1.1) ===
            'rpg_geologue'         => 'Geologo',
            'rpg_amiral'           => 'Almirante',
            'rpg_ingenieur'        => 'Ingeniero',
            'rpg_technocrate'      => 'Tecnocrata',
        ];

        return isset($nameMap[$key]) ? $nameMap[$key] : $key;
    }

    /**
     * Obtiene los logros del jugador: solo el nivel actual de cada cadena
     * 
     * @param int $userId
     * @return array Lista de logros activos (17 maximo, uno por cadena)
     */
    public static function getUserAchievements($userId)
    {
        $prefix = self::prefix();
        $db = Database::get();

        // 1. Obtener todas las cadenas unicas (code)
        $codes = $db->select("SELECT DISTINCT `code` FROM `" . $prefix . "achievements_catalog` WHERE `is_active` = 1 ORDER BY `sort_order` ASC");

        // 2. Obtener el progreso del jugador
        $progressRows = $db->select("SELECT * FROM `" . $prefix . "users_achievements` WHERE `user_id` = :uid", [':uid' => $userId]);

        $progressMap = [];
        foreach ($progressRows as $row) {
            $progressMap[$row['code']] = $row;
        }

        // 3. Obtener el usuario y los niveles MAXIMOS de edificios entre TODOS los planetas
        $user = $db->selectSingle("SELECT * FROM `" . $prefix . "users` WHERE `id` = :uid LIMIT 1", [':uid' => $userId]);

        if (empty($user)) {
            return [];
        }

        // CORRECCION BUG 2: Usar MAX() para buscar el nivel mas alto en todos los planetas
        $maxBuildings = $db->selectSingle("SELECT 
            MAX(metal_mine) as metal_mine, 
            MAX(crystal_mine) as crystal_mine, 
            MAX(deuterium_sintetizer) as deuterium_sintetizer, 
            MAX(norium_mine) as norium_mine, 
            MAX(germanium_mine) as germanium_mine, 
            MAX(solar_plant) as solar_plant, 
            MAX(laboratory) as laboratory,
            MAX(phalanx) as phalanx,
            MAX(hangar) as hangar
            FROM `" . $prefix . "planets` WHERE `id_owner` = :uid", [':uid' => $userId]);

        $result = [];

        foreach ($codes as $row) {
            $code = $row['code'];

            // Determinar el nivel actual del jugador en esta cadena
            $currentLevel = isset($progressMap[$code]) ? (int)$progressMap[$code]['current_level'] : 1;
            $status = isset($progressMap[$code]) ? $progressMap[$code]['status'] : 'pending';

            // CORRECCION BUG 1 y 3: Si el nivel es mayor a 10, significa que ya reclamo el nivel 10 y la cadena termino.
            // Forzamos is_completed a false para que el Template NO muestre el boton de reclamar.
            if ($currentLevel > 10) {
                $result[] = [
                    'code'              => $code,
                    'title'             => 'Cadena completada',
                    'description'       => 'Has completado todos los niveles de esta cadena.',
                    'level'             => 10,
                    'current_value'     => 1,
                    'requirement_value' => 1,
                    'requirement_key'   => '',
                    'requirement_name'  => 'Completada',
                    'reward_text'       => 'Completada',
                    'status'            => 'claimed',
                    'is_completed'      => false, // FALSE: No muestra boton
                    'is_claimed'        => true,  // TRUE: Muestra etiqueta verde de reclamado
                ];
                continue;
            }

            // Obtener el logro actual (el nivel actual de esta cadena)
            $achievement = $db->selectSingle("SELECT * FROM `" . $prefix . "achievements_catalog` WHERE `code` = :code AND `level` = :lvl AND `is_active` = 1 LIMIT 1", [
                ':code' => $code,
                ':lvl'  => $currentLevel
            ]);

            // Si no existe el logro en el catalogo (error de datos), evitamos el 0/0
            if (empty($achievement)) {
                $result[] = [
                    'code'              => $code,
                    'title'             => 'Error de Catalogo',
                    'description'       => 'Nivel no encontrado en la base de datos.',
                    'level'             => $currentLevel,
                    'current_value'     => 0,
                    'requirement_value' => 1,
                    'requirement_key'   => '',
                    'requirement_name'  => 'No disponible',
                    'reward_text'       => '0 MO',
                    'status'            => 'pending',
                    'is_completed'      => false,
                    'is_claimed'        => false,
                ];
                continue;
            }

            // Obtener el valor actual del requisito
            $requirementType = $achievement['requirement_type'];
            $requirementKey = $achievement['requirement_key'];
            $requirementValue = (int)$achievement['requirement_value'];

            $currentValue = 0;

            if ($requirementType === 'building') {
                // Edificios: se busca el nivel MAXIMO entre todos los planetas del jugador
                $currentValue = isset($maxBuildings[$requirementKey]) ? (int)$maxBuildings[$requirementKey] : 0;

            } elseif ($requirementType === 'officier') {
                // v1.1: Oficiales: se lee la columna del oficial en la tabla users
                // Ej: $user['rpg_geologue'], $user['rpg_amiral'], etc.
                $currentValue = isset($user[$requirementKey]) ? (int)$user[$requirementKey] : 0;

            } elseif ($requirementType === 'officier_all') {
                // v1.2: Consejo Imperial: nivel equivalente segun los 4 oficiales
                // Niveles I-IX  -> Geologo >= 2*N  y  Almirante >= 2*N
                // Nivel X       -> Geologo 20 + Almirante 20 + Ingeniero 10 + Tecnocrata 10
                $geo = isset($user['rpg_geologue'])    ? (int)$user['rpg_geologue']    : 0;
                $ama = isset($user['rpg_amiral'])      ? (int)$user['rpg_amiral']      : 0;
                $ing = isset($user['rpg_ingenieur'])   ? (int)$user['rpg_ingenieur']   : 0;
                $tec = isset($user['rpg_technocrate']) ? (int)$user['rpg_technocrate'] : 0;

                $consejoLevel = 0;
                for ($n = 1; $n <= 9; $n++) {
                    if ($geo >= $n * 2 && $ama >= $n * 2) {
                        $consejoLevel = $n;
                    } else {
                        break;
                    }
                }
                // Nivel X: exige los 4 al maximo
                if ($consejoLevel === 9 && $geo >= 20 && $ama >= 20 && $ing >= 10 && $tec >= 10) {
                    $consejoLevel = 10;
                }

                $currentValue = $consejoLevel;

            } else {
                // research (y cualquier otro tipo futuro): se lee la columna en la tabla users
                $currentValue = isset($user[$requirementKey]) ? (int)$user[$requirementKey] : 0;
            }

            // Verificar si cumple el requisito
            $isCompleted = ($currentValue >= $requirementValue);

            // Si cumple y estaba pendiente, marcarlo como completado en BD
            if ($isCompleted && $status === 'pending') {
                self::markCompleted($userId, $code, $currentLevel);
                $status = 'completed';
            }

            // Nombre legible del requisito (Pasamos el nivel para el Consejo Imperial)
            $requirementName = self::getRequirementName($requirementKey, (int)$achievement['level']);

            $result[] = [
                'code'              => $code,
                'title'             => $achievement['title'],
                'description'       => $achievement['description'],
                'level'             => $currentLevel,
                'current_value'     => $currentValue,
                'requirement_value' => $requirementValue,
                'requirement_key'   => $requirementKey,
                'requirement_name'  => $requirementName,
                'reward_type'       => $achievement['reward_type'],
                'reward_amount'     => $achievement['reward_amount'],
                'reward_text'       => $achievement['reward_amount'] . ' MO',
                'icon'              => $achievement['icon'],
                'status'            => $status,
                'is_completed'      => ($status === 'completed'),
                'is_claimed'        => ($status === 'claimed'),
            ];
        }

        return $result;
    }

    /**
     * Marca un logro como completado en la BD
     */
    private static function markCompleted($userId, $code, $level)
    {
        $prefix = self::prefix();
        $db = Database::get();

        $existing = $db->selectSingle("SELECT * FROM `" . $prefix . "users_achievements` WHERE `user_id` = :uid AND `code` = :code", [
            ':uid'  => $userId,
            ':code' => $code
        ]);

        if (empty($existing)) {
            $db->insert("INSERT INTO `" . $prefix . "users_achievements` (`user_id`, `code`, `current_level`, `status`, `completed_at`) VALUES (:uid, :code, :lvl, 'completed', :time)", [
                ':uid'  => $userId,
                ':code' => $code,
                ':lvl'  => $level,
                ':time' => time()
            ]);
            self::log($userId, $code, $level, 'completado', 'Logro verificado automaticamente');
        } else {
            // Solo actualizamos a completado si esta pendiente y en el nivel correcto
            if ($existing['status'] === 'pending' && (int)$existing['current_level'] === (int)$level) {
                $db->update("UPDATE `" . $prefix . "users_achievements` SET `status` = 'completed', `completed_at` = :time WHERE `id` = :id", [
                    ':time' => time(),
                    ':id'   => $existing['id']
                ]);
                self::log($userId, $code, $level, 'completado', 'Logro verificado automaticamente');
            }
        }
    }

    /**
     * Reclama la recompensa del logro actual de una cadena
     * 
     * @param int $userId
     * @param string $code
     * @return array ['success' => bool, 'message' => string]
     */
    public static function claimAchievement($userId, $code)
    {
        $prefix = self::prefix();
        $db = Database::get();

        // 1. Obtener el progreso del jugador
        $progress = $db->selectSingle("SELECT * FROM `" . $prefix . "users_achievements` WHERE `user_id` = :uid AND `code` = :code", [
            ':uid'  => $userId,
            ':code' => $code
        ]);

        if (empty($progress)) {
            return ['success' => false, 'message' => 'No has empezado esta cadena.'];
        }

        if ($progress['status'] !== 'completed') {
            return ['success' => false, 'message' => 'Debes completar el logro primero.'];
        }

        $currentLevel = (int)$progress['current_level'];

        // 2. Obtener el logro actual
        $achievement = $db->selectSingle("SELECT * FROM `" . $prefix . "achievements_catalog` WHERE `code` = :code AND `level` = :lvl LIMIT 1", [
            ':code' => $code,
            ':lvl'  => $currentLevel
        ]);

        if (empty($achievement)) {
            return ['success' => false, 'message' => 'Logro no encontrado.'];
        }

        // 3. Otorgar recompensa
        $rewardAmount = (int)$achievement['reward_amount'];
        $rewardType = $achievement['reward_type'];

        if ($rewardType === 'darkmatter') {
            $db->update("UPDATE `" . $prefix . "users` SET `darkmatter` = `darkmatter` + :amt WHERE `id` = :uid", [
                ':amt' => $rewardAmount,
                ':uid' => $userId
            ]);
            if (isset($GLOBALS['USER']['darkmatter'])) {
                $GLOBALS['USER']['darkmatter'] += $rewardAmount;
            }
        }

        // 4. Actualizar al siguiente nivel
        $nextLevel = $currentLevel + 1;

        // Verificar si existe el siguiente nivel
        $nextAchievement = $db->selectSingle("SELECT * FROM `" . $prefix . "achievements_catalog` WHERE `code` = :code AND `level` = :lvl LIMIT 1", [
            ':code' => $code,
            ':lvl'  => $nextLevel
        ]);

        if (!empty($nextAchievement)) {
            // Pasar al siguiente nivel (pending)
            $db->update("UPDATE `" . $prefix . "users_achievements` SET `current_level` = :lvl, `status` = 'pending', `completed_at` = 0, `claimed_at` = :time WHERE `id` = :id", [
                ':lvl'  => $nextLevel,
                ':time' => time(),
                ':id'   => $progress['id']
            ]);
        } else {
            // CORRECCION CLAVE: Si era el nivel 10, guardamos el nivel 11 y lo marcamos como claimed.
            // Esto rompe el bucle del boton de reclamar.
            $db->update("UPDATE `" . $prefix . "users_achievements` SET `current_level` = :lvl, `status` = 'claimed', `claimed_at` = :time WHERE `id` = :id", [
                ':lvl'  => 11, 
                ':time' => time(),
                ':id'   => $progress['id']
            ]);
        }

        // 5. Log
        self::log($userId, $code, $currentLevel, 'reclamado', 'Recompensa otorgada: ' . $rewardAmount . ' MO');

        return [
            'success' => true,
            'message' => 'Logro reclamado. Recibiste ' . $rewardAmount . ' MO.'
        ];
    }

    /**
     * Cuenta cuantos logros tiene el jugador pendientes de reclamar
     */
    public static function countPendingClaims($userId)
    {
        $prefix = self::prefix();
        $db = Database::get();

        $row = $db->selectSingle("SELECT COUNT(*) AS total FROM `" . $prefix . "users_achievements` WHERE `user_id` = :uid AND `status` = 'completed'", [
            ':uid' => $userId
        ]);

        return !empty($row) ? (int)$row['total'] : 0;
    }

    /**
     * Log de auditoria
     */
    private static function log($userId, $code, $level, $action, $detalle = '')
    {
        $prefix = self::prefix();
        $db = Database::get();

        $db->insert("INSERT INTO `" . $prefix . "achievements_log` (`user_id`, `code`, `level`, `action`, `detalle`, `fecha`) VALUES (:uid, :code, :lvl, :action, :detalle, :time)", [
            ':uid'     => $userId,
            ':code'    => $code,
            ':lvl'     => $level,
            ':action'  => $action,
            ':detalle' => $detalle,
            ':time'    => time()
        ]);
    }
}