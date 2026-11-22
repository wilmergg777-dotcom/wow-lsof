<?php

/**
 * AstroIO - Minijuego Navidad (Memoria Navideña)
 * Helper principal
 *
 * @package AstroIO
 * @version 1.1
 */

class MinijuegoNavidadHelper
{
    const GAME_TYPE = 2; // 2 = Navidad
    const MIN_GAME_DURATION = 25;
    const MAX_GAME_DURATION = 300;
    const TOKEN_CLEANUP_DAYS = 1;

    // IDs de naves/defensas
    const NAVE_ID = 204;    // Cazador Ligero
    const DEFENSA_ID = 404; // Cañón Gauss

    // Parejas (1 a 8)
    const PAREJAS = [
        1 => 'metal',
        2 => 'crystal',
        3 => 'deuterium',
        4 => 'nave',
        5 => 'defensa',
        6 => 'mo',
        7 => 'cofres',
        8 => 'especial'
    ];

    private static function db() { return Database::get(); }
    private static function prefix() { return DB_PREFIX; }

    /* ============================================================
     * CONFIGURACIÓN
     * ============================================================ */

    public static function getConfig($key, $default = null)
    {
        $db = self::db();
        $p  = self::prefix();
        $keyEsc = addslashes((string) $key);
        $row = $db->selectSingle(
            "SELECT config_value FROM `".$p."gamedu_config` WHERE config_key = '".$keyEsc."'"
        );
        return ($row && isset($row['config_value'])) ? $row['config_value'] : $default;
    }

    public static function isEnabled()
    {
        return (int) self::getConfig('navidad_enabled', 1) === 1;
    }

    /* ============================================================
     * COOLDOWN (5 HORAS)
     * ============================================================ */

    public static function getLastPlay($userId)
    {
        $db = self::db();
        $p  = self::prefix();
        $uid  = (int) $userId;
        $type = (int) self::GAME_TYPE;
        $row = $db->selectSingle(
            "SELECT MAX(`time`) AS last_time FROM `".$p."gamedu`
             WHERE user_id = ".$uid." AND type = ".$type
        );
        return ($row && !empty($row['last_time'])) ? (int) $row['last_time'] : 0;
    }

    public static function getCooldownLeft($userId)
    {
        $lastPlay = self::getLastPlay($userId);
        if ($lastPlay <= 0) return 0;

        $cooldownHours = (int) self::getConfig('navidad_cooldown_hours', 5);
        $cooldownSecs  = $cooldownHours * 3600;
        $elapsed       = TIMESTAMP - $lastPlay;
        $remaining     = $cooldownSecs - $elapsed;

        return max(0, $remaining);
    }

    public static function canPlay($userId)
    {
        if (!self::isEnabled()) return false;
        return self::getCooldownLeft($userId) <= 0;
    }

    public static function formatTimeLeft($seconds)
    {
        $seconds = (int) $seconds;
        if ($seconds <= 0) return '0s';
        $h = floor($seconds / 3600);
        $m = floor(($seconds % 3600) / 60);
        $s = $seconds % 60;
        if ($h > 0) return $h.'h '.$m.'m';
        if ($m > 0) return $m.'m '.$s.'s';
        return $s.'s';
    }

    /* ============================================================
     * TOKEN ANTI-CHEAT
     * ============================================================ */

    public static function generateToken()
    {
        return strtoupper(bin2hex(random_bytes(16)));
    }

    public static function createToken($userId)
    {
        $db = self::db();
        $p  = self::prefix();
        $token = self::generateToken();
        $uid     = (int) $userId;
        $tokEsc  = addslashes($token);
        $started = (int) TIMESTAMP;

        $db->query(
            "INSERT INTO `".$p."gamedu_tokens`
                (user_id, token, started_at, used, used_at)
             VALUES (".$uid.", '".$tokEsc."', ".$started.", 0, 0)"
        );

        return $token;
    }

    public static function validateToken($userId, $token)
    {
        $db = self::db();
        $p  = self::prefix();

        if (empty($token) || !is_string($token)) {
            return ['success' => false, 'error' => 'invalid_token'];
        }

        $uid    = (int) $userId;
        $tokEsc = addslashes($token);

        $row = $db->selectSingle(
            "SELECT * FROM `".$p."gamedu_tokens`
             WHERE user_id = ".$uid." AND token = '".$tokEsc."'
             ORDER BY id DESC LIMIT 1"
        );

        if (!$row) return ['success' => false, 'error' => 'token_not_found'];
        if ((int) $row['used'] === 1) return ['success' => false, 'error' => 'token_already_used'];

        $elapsed = TIMESTAMP - (int) $row['started_at'];
        if ($elapsed < self::MIN_GAME_DURATION) return ['success' => false, 'error' => 'too_fast'];
        if ($elapsed > self::MAX_GAME_DURATION) return ['success' => false, 'error' => 'too_slow'];

        return ['success' => true, 'row' => $row];
    }

    public static function markTokenUsed($tokenId)
    {
        $db = self::db();
        $p  = self::prefix();
        $id  = (int) $tokenId;
        $now = (int) TIMESTAMP;

        $db->query(
            "UPDATE `".$p."gamedu_tokens` SET used = 1, used_at = ".$now." WHERE id = ".$id
        );
    }

    public static function cleanupOldTokens()
    {
        $db = self::db();
        $p  = self::prefix();
        $limit = (int) (TIMESTAMP - (self::TOKEN_CLEANUP_DAYS * 86400));
        $db->query(
            "DELETE FROM `".$p."gamedu_tokens` WHERE started_at < ".$limit." AND used = 0"
        );
    }

    /* ============================================================
     * STATS DEL JUGADOR (SIN RÉCORD)
     * ============================================================ */

    public static function getPlayerStats($userId)
    {
        $db = self::db();
        $p  = self::prefix();
        $uid  = (int) $userId;
        $type = (int) self::GAME_TYPE;

        $lastPlay = self::getLastPlay($userId);
        $cooldownLeft = self::getCooldownLeft($userId);

        $totalRow = $db->selectSingle(
            "SELECT COUNT(*) AS total FROM `".$p."gamedu`
             WHERE user_id = ".$uid." AND type = ".$type
        );
        $totalPlays = ($totalRow && !empty($totalRow['total'])) ? (int) $totalRow['total'] : 0;

        $today = (int) (TIMESTAMP - 86400);
        $todayRow = $db->selectSingle(
            "SELECT COUNT(*) AS today_plays FROM `".$p."gamedu`
             WHERE user_id = ".$uid." AND type = ".$type." AND `time` >= ".$today
        );
        $playsToday = ($todayRow && !empty($todayRow['today_plays'])) ? (int) $todayRow['today_plays'] : 0;

        return [
            'last_play'      => $lastPlay,
            'cooldown_left'  => $cooldownLeft,
            'cooldown_text'  => self::formatTimeLeft($cooldownLeft),
            'can_play'       => $cooldownLeft <= 0,
            'total_plays'    => $totalPlays,
            'plays_today'    => $playsToday,
        ];
    }

    /* ============================================================
     * PARTIDAS
     * ============================================================ */

    public static function startGame($userId, $username)
    {
        $db = self::db();
        $p  = self::prefix();

        if (!self::canPlay($userId)) return ['success' => false, 'error' => 'cooldown'];

        $token = self::createToken($userId);

        $unameEsc = addslashes((string) $username);
        $uid      = (int) $userId;
        $now      = (int) TIMESTAMP;
        $type     = (int) self::GAME_TYPE;
        $universe = (int) Universe::current();

        $db->query(
            "INSERT INTO `".$p."gamedu`
                (username, user_id, `time`, score, type, universe)
             VALUES ('".$unameEsc."', ".$uid.", ".$now.", 0, ".$type.", ".$universe.")"
        );

        return ['success' => true, 'token' => $token];
    }

    public static function finishGame($userId, $token, $parejasEncontradas)
    {
        global $USER, $PLANET;

        $db = self::db();
        $p  = self::prefix();

        $validation = self::validateToken($userId, $token);
        if (!$validation['success']) return ['success' => false, 'error' => $validation['error']];

        $tokenRow = $validation['row'];

        if (!is_array($parejasEncontradas)) $parejasEncontradas = [];
        $parejasEncontradas = array_unique(array_map('intval', $parejasEncontradas));
        $parejasEncontradas = array_filter($parejasEncontradas, function($id) { return $id >= 1 && $id <= 8; });

        $puntosPorPareja = (int) self::getConfig('navidad_points_per_pair', 100);
        $score = count($parejasEncontradas) * $puntosPorPareja;

        $scoreInt = (int) $score;
        $uidInt   = (int) $userId;
        $typeInt  = (int) self::GAME_TYPE;
        $timeInt  = (int) $tokenRow['started_at'];

        $db->query(
            "UPDATE `".$p."gamedu` SET score = ".$scoreInt."
             WHERE user_id = ".$uidInt." AND type = ".$typeInt." AND `time` = ".$timeInt." LIMIT 1"
        );

        $recompensas = [];
        foreach ($parejasEncontradas as $parejaId) {
            $recompensa = self::entregarRecompensa($parejaId, $userId, $USER, $PLANET);
            if ($recompensa) $recompensas[] = $recompensa;
        }

        self::markTokenUsed($tokenRow['id']);

        return ['success' => true, 'score' => $score, 'parejas' => count($parejasEncontradas), 'recompensas' => $recompensas];
    }

    /* ============================================================
     * ENTREGA DE RECOMPENSAS (SI ES LUNA, USA PLANETA PRINCIPAL)
     * ============================================================ */

    private static function entregarRecompensa($parejaId, $userId, $USER, $PLANET)
    {
        $db = self::db();
        $p  = self::prefix();
        $uid = (int) $userId;

        // Determinar planeta para recursos
        $targetPlanet = $PLANET;
        if ((int)$PLANET['planet_type'] === 3) {
            // Es luna -> buscar planeta principal (menor ID)
            $mainPlanet = $db->selectSingle(
                "SELECT * FROM `".$p."planets` WHERE id_owner = ".$uid." AND planet_type = 1 ORDER BY id ASC LIMIT 1"
            );
            if ($mainPlanet) $targetPlanet = $mainPlanet;
        }

        switch ($parejaId) {
            case 1: // Metal
                $cantidad = max(100, (int)($targetPlanet['metal_perhour'] ?? 1000));
                $db->query("UPDATE `".$p."planets` SET metal = metal + ".$cantidad." WHERE id = ".(int)$targetPlanet['id']);
                if (isset($GLOBALS['PLANET']) && $GLOBALS['PLANET']['id'] == $targetPlanet['id']) $GLOBALS['PLANET']['metal'] += $cantidad;
                return ['tipo' => 'metal', 'cantidad' => $cantidad, 'texto' => number_format($cantidad).' Metal'];

            case 2: // Cristal
                $cantidad = max(100, (int)($targetPlanet['crystal_perhour'] ?? 500));
                $db->query("UPDATE `".$p."planets` SET crystal = crystal + ".$cantidad." WHERE id = ".(int)$targetPlanet['id']);
                if (isset($GLOBALS['PLANET']) && $GLOBALS['PLANET']['id'] == $targetPlanet['id']) $GLOBALS['PLANET']['crystal'] += $cantidad;
                return ['tipo' => 'crystal', 'cantidad' => $cantidad, 'texto' => number_format($cantidad).' Cristal'];

            case 3: // Deuterio
                $cantidad = max(50, (int)($targetPlanet['deuterium_perhour'] ?? 100));
                $db->query("UPDATE `".$p."planets` SET deuterium = deuterium + ".$cantidad." WHERE id = ".(int)$targetPlanet['id']);
                if (isset($GLOBALS['PLANET']) && $GLOBALS['PLANET']['id'] == $targetPlanet['id']) $GLOBALS['PLANET']['deuterium'] += $cantidad;
                return ['tipo' => 'deuterium', 'cantidad' => $cantidad, 'texto' => number_format($cantidad).' Deuterio'];

            case 4: // Nave (Cazador Ligero)
                if (function_exists('isTechnologieAccessible') && !isTechnologieAccessible($USER, $targetPlanet, self::NAVE_ID)) {
                    $db->query("UPDATE `".$p."planets` SET metal = metal + 10000 WHERE id = ".(int)$targetPlanet['id']);
                    return ['tipo' => 'metal', 'cantidad' => 10000, 'texto' => '10.000 Metal (Nave no desbloqueada)'];
                }
                $db->query("UPDATE `".$p."planets` SET light_hunter = light_hunter + 1 WHERE id = ".(int)$targetPlanet['id']);
                return ['tipo' => 'nave', 'cantidad' => 1, 'texto' => '1 Cazador Ligero'];

            case 5: // Defensa (Cañón Gauss)
                if (function_exists('isTechnologieAccessible') && !isTechnologieAccessible($USER, $targetPlanet, self::DEFENSA_ID)) {
                    $db->query("UPDATE `".$p."planets` SET crystal = crystal + 10000 WHERE id = ".(int)$targetPlanet['id']);
                    return ['tipo' => 'crystal', 'cantidad' => 10000, 'texto' => '10.000 Cristal (Defensa no desbloqueada)'];
                }
                $db->query("UPDATE `".$p."planets` SET gauss_canyon = gauss_canyon + 1 WHERE id = ".(int)$targetPlanet['id']);
                return ['tipo' => 'defensa', 'cantidad' => 1, 'texto' => '1 Cañón Gauss'];

            case 6: // MO
                $cantidad = mt_rand(250, 700);
                $db->query("UPDATE `".$p."users` SET darkmatter = darkmatter + ".$cantidad." WHERE id = ".$uid);
                if (isset($GLOBALS['USER'])) $GLOBALS['USER']['darkmatter'] += $cantidad;
                return ['tipo' => 'mo', 'cantidad' => $cantidad, 'texto' => number_format($cantidad).' MO'];

            case 7: // Cofres
                $cantidad = mt_rand(5, 15);
                $db->query("UPDATE `".$p."users` SET containers = containers + ".$cantidad." WHERE id = ".$uid);
                if (isset($GLOBALS['USER'])) $GLOBALS['USER']['containers'] += $cantidad;
                return ['tipo' => 'cofres', 'cantidad' => $cantidad, 'texto' => $cantidad.' Cofres Genéricos'];

            case 8: // Regalo Especial
                $db->query("UPDATE `".$p."planets` SET metal = metal + 1000, crystal = crystal + 1000, deuterium = deuterium + 1000 WHERE id = ".(int)$targetPlanet['id']);
                if (isset($GLOBALS['PLANET']) && $GLOBALS['PLANET']['id'] == $targetPlanet['id']) {
                    $GLOBALS['PLANET']['metal'] += 1000;
                    $GLOBALS['PLANET']['crystal'] += 1000;
                    $GLOBALS['PLANET']['deuterium'] += 1000;
                }
                return ['tipo' => 'especial', 'cantidad' => 1000, 'texto' => '1.000 Metal + 1.000 Cristal + 1.000 Deuterio'];

            default: return null;
        }
    }
}