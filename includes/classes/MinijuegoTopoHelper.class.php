<?php

/**
 * AstroIO - Minijuego Topo (Golpea al Topo)
 * Helper principal
 *
 * @package AstroIO
 * @author  AstroIO Team
 * @version 1.3
 */

class MinijuegoTopoHelper
{
    /* ============================================================
     * CONSTANTES / DEFAULTS
     * ============================================================ */

    // Tipo de juego en la tabla uni1_gamedu
    // 0 = Minijuego Topo (mantenemos compatibilidad con el mod original)
    const GAME_TYPE = 0;

    // Tiempo mínimo real que debe durar la partida (anti-cheat)
    // 30s de juego + 5s de margen
    const MIN_GAME_DURATION = 25;

    // Duración máxima que consideramos válida (por si el usuario
    // deja el navegador abierto y luego manda el POST)
    const MAX_GAME_DURATION = 300;

    // Días a mantener los tokens huérfanos antes de limpiarlos
    const TOKEN_CLEANUP_DAYS = 1;


    /* ============================================================
     * UTILIDADES PRIVADAS
     * ============================================================ */

    private static function db()
    {
        return Database::get();
    }

    private static function prefix()
    {
        return DB_PREFIX;
    }


    /* ============================================================
     * CONFIGURACIÓN
     * Lee/escribe desde uni1_gamedu_config
     * ============================================================ */

    /**
     * Devuelve toda la configuración como array asociativo
     */
    public static function getAllConfig()
    {
        $db = self::db();
        $p  = self::prefix();

        $rows = $db->select("SELECT config_key, config_value FROM `".$p."gamedu_config`");

        $config = array();
        if (is_array($rows)) {
            foreach ($rows as $row) {
                $config[$row['config_key']] = $row['config_value'];
            }
        }

        return $config;
    }

    /**
     * Devuelve un valor de config (o null si no existe)
     */
    public static function getConfig($key, $default = null)
    {
        $db = self::db();
        $p  = self::prefix();

        $keyEsc = addslashes((string) $key);

        $row = $db->selectSingle(
            "SELECT config_value FROM `".$p."gamedu_config` WHERE config_key = '".$keyEsc."'"
        );

        if ($row && isset($row['config_value'])) {
            return $row['config_value'];
        }

        return $default;
    }

    /**
     * Guarda un valor de config
     */
    public static function setConfig($key, $value)
    {
        $db = self::db();
        $p  = self::prefix();

        // Escapar manualmente (no hay input de user directo)
        $keyEsc   = addslashes((string) $key);
        $valueEsc = addslashes((string) $value);

        $db->query(
            "INSERT INTO `".$p."gamedu_config` (config_key, config_value)
             VALUES ('".$keyEsc."', '".$valueEsc."')
             ON DUPLICATE KEY UPDATE config_value = '".$valueEsc."'"
        );

        return true;
    }


    /* ============================================================
     * COOLDOWN
     * ============================================================ */

    /**
     * Devuelve el timestamp de la última partida del usuario
     * (o 0 si nunca jugó)
     */
    public static function getLastPlay($userId)
    {
        $db = self::db();
        $p  = self::prefix();

        $uid  = (int) $userId;
        $type = (int) self::GAME_TYPE;

        $row = $db->selectSingle(
            "SELECT MAX(`time`) AS last_time
             FROM `".$p."gamedu`
             WHERE user_id = ".$uid." AND type = ".$type
        );

        if ($row && !empty($row['last_time'])) {
            return (int) $row['last_time'];
        }

        return 0;
    }

    /**
     * Segundos restantes de cooldown (0 si puede jugar)
     */
    public static function getCooldownLeft($userId)
    {
        $lastPlay = self::getLastPlay($userId);

        if ($lastPlay <= 0) {
            return 0;
        }

        $cooldownHours = (int) self::getConfig('topo_cooldown_hours', 2);
        $cooldownSecs  = $cooldownHours * 3600;

        $elapsed   = TIMESTAMP - $lastPlay;
        $remaining = $cooldownSecs - $elapsed;

        if ($remaining < 0) {
            $remaining = 0;
        }

        return $remaining;
    }

    /**
     * ¿Puede jugar ahora?
     */
    public static function canPlay($userId)
    {
        if (!self::isEnabled()) {
            return false;
        }

        return self::getCooldownLeft($userId) <= 0;
    }

    /**
     * ¿Está habilitado el juego?
     */
    public static function isEnabled()
    {
        return (int) self::getConfig('topo_enabled', 1) === 1;
    }

    /**
     * Formatea segundos a "Xh Ym" o "Ym Zs" o "Zs"
     */
    public static function formatTimeLeft($seconds)
    {
        $seconds = (int) $seconds;

        if ($seconds <= 0) {
            return '0s';
        }

        $h = floor($seconds / 3600);
        $m = floor(($seconds % 3600) / 60);
        $s = $seconds % 60;

        if ($h > 0) {
            return $h.'h '.$m.'m';
        }
        if ($m > 0) {
            return $m.'m '.$s.'s';
        }
        return $s.'s';
    }


    /* ============================================================
     * TOKEN (ANTI-CHEAT)
     * ============================================================ */

    /**
     * Genera un token único para la partida
     */
    public static function generateToken()
    {
        return strtoupper(bin2hex(random_bytes(16)));
    }

    /**
     * Crea un registro de token al iniciar partida
     * Devuelve el token generado
     */
    public static function createToken($userId)
    {
        $db = self::db();
        $p  = self::prefix();

        $token = self::generateToken();

        // Casteos + escape manual
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

    /**
     * Valida un token
     * Devuelve array:
     *   - success: bool
     *   - error:   string (si success=false)
     *   - row:     array con los datos del token (si success=true)
     */
    public static function validateToken($userId, $token)
    {
        $db = self::db();
        $p  = self::prefix();

        if (empty($token) || !is_string($token)) {
            return array('success' => false, 'error' => 'invalid_token');
        }

        $uid    = (int) $userId;
        $tokEsc = addslashes($token);

        $row = $db->selectSingle(
            "SELECT * FROM `".$p."gamedu_tokens`
             WHERE user_id = ".$uid." AND token = '".$tokEsc."'
             ORDER BY id DESC LIMIT 1"
        );

        if (!$row) {
            return array('success' => false, 'error' => 'token_not_found');
        }

        if ((int) $row['used'] === 1) {
            return array('success' => false, 'error' => 'token_already_used');
        }

        // Verificar duración mínima
        $elapsed = TIMESTAMP - (int) $row['started_at'];

        if ($elapsed < self::MIN_GAME_DURATION) {
            return array('success' => false, 'error' => 'too_fast');
        }

        if ($elapsed > self::MAX_GAME_DURATION) {
            return array('success' => false, 'error' => 'too_slow');
        }

        return array('success' => true, 'row' => $row);
    }

    /**
     * Marca un token como usado
     */
    public static function markTokenUsed($tokenId)
    {
        $db = self::db();
        $p  = self::prefix();

        $id  = (int) $tokenId;
        $now = (int) TIMESTAMP;

        $db->query(
            "UPDATE `".$p."gamedu_tokens`
             SET used = 1, used_at = ".$now."
             WHERE id = ".$id
        );
    }

    /**
     * Limpia tokens huérfanos (más viejos que X días y no usados)
     */
    public static function cleanupOldTokens()
    {
        $db = self::db();
        $p  = self::prefix();

        // Casteo a int para seguridad (viene de constante, no de input del user)
        $limit = (int) (TIMESTAMP - (self::TOKEN_CLEANUP_DAYS * 86400));

        $db->query(
            "DELETE FROM `".$p."gamedu_tokens`
             WHERE started_at < ".$limit." AND used = 0"
        );
    }


    /* ============================================================
     * STATS DEL JUGADOR
     * ============================================================ */

    /**
     * Devuelve estadísticas del jugador para mostrar en la página
     */
    public static function getPlayerStats($userId)
    {
        $db = self::db();
        $p  = self::prefix();

        $uid  = (int) $userId;
        $type = (int) self::GAME_TYPE;

        // Última partida
        $lastPlay = self::getLastPlay($userId);

        // Cooldown restante
        $cooldownLeft = self::getCooldownLeft($userId);

        // Récord personal
        $bestRow = $db->selectSingle(
            "SELECT MAX(score) AS best
             FROM `".$p."gamedu`
             WHERE user_id = ".$uid." AND type = ".$type
        );

        $bestScore = ($bestRow && !empty($bestRow['best'])) ? (int) $bestRow['best'] : 0;

        // Partidas totales
        $totalRow = $db->selectSingle(
            "SELECT COUNT(*) AS total
             FROM `".$p."gamedu`
             WHERE user_id = ".$uid." AND type = ".$type
        );

        $totalPlays = ($totalRow && !empty($totalRow['total'])) ? (int) $totalRow['total'] : 0;

        // Partidas últimas 24h
        $today    = (int) (TIMESTAMP - 86400);
        $todayRow = $db->selectSingle(
            "SELECT COUNT(*) AS today_plays
             FROM `".$p."gamedu`
             WHERE user_id = ".$uid." AND type = ".$type." AND `time` >= ".$today
        );

        $playsToday = ($todayRow && !empty($todayRow['today_plays'])) ? (int) $todayRow['today_plays'] : 0;

        return array(
            'last_play'      => $lastPlay,
            'cooldown_left'  => $cooldownLeft,
            'cooldown_text'  => self::formatTimeLeft($cooldownLeft),
            'can_play'       => $cooldownLeft <= 0,
            'best_score'     => $bestScore,
            'total_plays'    => $totalPlays,
            'plays_today'    => $playsToday,
        );
    }


    /* ============================================================
     * PARTIDAS
     * ============================================================ */

    /**
     * Inicia una partida:
     *  1) Verifica cooldown
     *  2) Crea token
     *  3) Inserta row con score=0 (para que cuente el cooldown)
     *
     * Devuelve:
     *   - success: bool
     *   - token:   string (si success=true)
     *   - error:   string (si success=false)
     */
    public static function startGame($userId, $username)
    {
        $db = self::db();
        $p  = self::prefix();

        // 1) Verificar cooldown
        if (!self::canPlay($userId)) {
            return array('success' => false, 'error' => 'cooldown');
        }

        // 2) Crear token
        $token = self::createToken($userId);

        // 3) Insertar row en uni1_gamedu con score=0
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

        return array(
            'success' => true,
            'token'   => $token
        );
    }

    /**
     * Finaliza una partida:
     *  1) Valida token
     *  2) Valida score (entre 0 y max)
     *  3) Actualiza el score de la row
     *  4) Calcula premio
     *  5) Da premio (MO + cofres)
     *  6) Marca token como usado
     *
     * Devuelve:
     *   - success: bool
     *   - error:   string (si success=false)
     *   - score:   int
     *   - reward:  array con mo + chests
     */
    public static function finishGame($userId, $token, $score)
    {
        $db = self::db();
        $p  = self::prefix();

        // 1) Validar score básico
        $score = (int) $score;

        if ($score < 0) {
            return array('success' => false, 'error' => 'negative_score');
        }

        $maxScore = (int) self::getConfig('topo_score_max', 3000);
        if ($score > $maxScore) {
            return array('success' => false, 'error' => 'score_too_high');
        }

        // 2) Validar token
        $validation = self::validateToken($userId, $token);

        if (!$validation['success']) {
            return array('success' => false, 'error' => $validation['error']);
        }

        $tokenRow = $validation['row'];

        // 3) Actualizar la row con el score real
        $scoreInt = (int) $score;
        $uidInt   = (int) $userId;
        $typeInt  = (int) self::GAME_TYPE;
        $timeInt  = (int) $tokenRow['started_at'];

        $db->query(
            "UPDATE `".$p."gamedu`
             SET score = ".$scoreInt."
             WHERE user_id = ".$uidInt."
               AND type = ".$typeInt."
               AND `time` = ".$timeInt."
             LIMIT 1"
        );

        // 4) Calcular premio
        $reward = self::calculateReward($score);

        // 5) Dar premio (si corresponde)
        $given = array('mo' => 0, 'chests' => 0);

        // 🔥 MODIFICADO: Ahora también verifica chest_fixed
        if ($reward['mo'] > 0 || $reward['chest_roll'] > 0 || $reward['chest_fixed'] > 0) {
            $given = self::giveReward($userId, $reward);
        }

        // 6) Marcar token como usado
        self::markTokenUsed($tokenRow['id']);

        return array(
            'success' => true,
            'score'   => $score,
            'reward'  => array(
                'mo'      => $given['mo'],
                'chests'  => $given['chests'],
                'tier'    => $reward['tier']
            )
        );
    }


    /* ============================================================
     * REWARDS
     * ============================================================ */

    /**
     * Calcula el premio según el score (escalonado)
     */
    private static function calculateReward($score)
    {
        $result = array(
            'mo'          => 0,
            'chest_fixed' => 0, // 🔥 NUEVO: Cofres fijos asegurados
            'chest_min'   => 0,
            'chest_max'   => 0,
            'chest_roll'  => 0, // porcentaje de chance de cofre extra
            'tier'        => 0
        );

        // Leer escalones desde config
        for ($i = 5; $i >= 1; $i--) {
            $tierScore      = (int) self::getConfig('topo_reward_'.$i.'_score', 0);
            $tierMo         = (int) self::getConfig('topo_reward_'.$i.'_mo', 0);
            $tierChest      = (int) self::getConfig('topo_reward_'.$i.'_chest_chance', 0);
            $tierChestFixed = (int) self::getConfig('topo_reward_'.$i.'_chest_fixed', 0); // 🔥 NUEVO

            if ($score >= $tierScore && $tierScore > 0) {
                $result['mo']          = $tierMo;
                $result['chest_roll']  = $tierChest;
                $result['chest_fixed'] = $tierChestFixed; // 🔥 NUEVO
                $result['tier']        = $i;
                break;
            }
        }

        // Si el tier tiene chance de cofre > 0 → definir rango para los extras
        if ($result['chest_roll'] > 0) {
            $result['chest_min'] = (int) self::getConfig('topo_chest_min', 1);
            $result['chest_max'] = (int) self::getConfig('topo_chest_max', 2);
        }

        return $result;
    }

    /**
     * Aplica el premio a la BD
     */
    private static function giveReward($userId, $reward)
    {
        $db = self::db();
        $p  = self::prefix();

        $moGiven     = 0;
        // 🔥 MODIFICADO: Empezamos con los cofres fijos
        $chestsGiven = (int) $reward['chest_fixed']; 

        $uid = (int) $userId;

        // MO
        if ($reward['mo'] > 0) {
            $moGiven = (int) $reward['mo'];

            $db->query(
                "UPDATE `".$p."users`
                 SET darkmatter = darkmatter + ".$moGiven."
                 WHERE id = ".$uid
            );

            // Actualizar $GLOBALS para que se vea en la misma request
            if (isset($GLOBALS['USER']) && $GLOBALS['USER']['id'] == $uid) {
                $GLOBALS['USER']['darkmatter'] += $moGiven;
            }
        }

        // Cofres (Fijos + Tirada Única de Extras)
        if ($reward['chest_roll'] > 0 && $reward['chest_max'] > 0) {
            $roll = mt_rand(1, 100);

            if ($roll <= $reward['chest_roll']) {
                // Si gana la tirada, se suman de 1 a 2 cofres extra
                $chestsGiven += mt_rand($reward['chest_min'], $reward['chest_max']);
            }
        }

        // Aplicar a la base de datos si el total de cofres es mayor a 0
        if ($chestsGiven > 0) {
            $chestsInt = (int) $chestsGiven;

            $db->query(
                "UPDATE `".$p."users`
                 SET containers = containers + ".$chestsInt."
                 WHERE id = ".$uid
            );

            if (isset($GLOBALS['USER']) && $GLOBALS['USER']['id'] == $uid) {
                $GLOBALS['USER']['containers'] += $chestsInt;
            }
        }

        return array(
            'mo'     => $moGiven,
            'chests' => $chestsGiven
        );
    }


    /* ============================================================
     * RANKING
     * ============================================================ */

    /**
     * Devuelve el top N histórico
     * Estructura: [{username, score, time}, ...]
     */
    public static function getRanking($limit = 10)
    {
        $db = self::db();
        $p  = self::prefix();

        $limit = (int) $limit;
        if ($limit <= 0 || $limit > 100) {
            $limit = 10;
        }

        $typeInt     = (int) self::GAME_TYPE;
        $universeInt = (int) Universe::current();

        // 🔥 MODIFICADO: Suma de puntos históricos agrupado por jugador
        $rows = $db->select(
            "SELECT username, SUM(score) AS score, MAX(`time`) AS time
             FROM `".$p."gamedu`
             WHERE type = ".$typeInt." AND universe = ".$universeInt."
             GROUP BY user_id, username
             ORDER BY score DESC
             LIMIT ".$limit
        );

        if (!is_array($rows)) {
            return array();
        }

        return $rows;
    }


    /* ============================================================
     * LOG (opcional, para debug)
     * ============================================================ */

    /**
     * Log interno (a error_log de PHP)
     * No hace INSERT en BD para no cargar la tabla
     */
    public static function log($userId, $action, $details = '')
    {
        $line = '[MINIJUEGO_TOPO] user='.$userId.' action='.$action.' details='.$details;
        error_log($line);
    }
}