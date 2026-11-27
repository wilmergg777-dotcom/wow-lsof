<?php
/**
 * WarHelper - Sistema de Guerra WAR
 * AstroIO v1.0
 *
 * v6: anadido getPlayerPlanetsWithShips() y registerParticipant()
 *     para el tab "Enviar Flotas".
 *
 * Notas del fork:
 *  - query() no acepta :params -> inyeccion directa
 *  - escape() no existe -> addslashes() nativo
 *  - columna de alianza es 'ally_name' (no 'alliance_name')
 *  - campo de rango es 'ally_rank_id' en uni1_users
 */

if (!defined('MODE')) { die('Hacking attempt'); }

class WarHelper
{
    // ============ CONFIGURACION ============
    const MIN_MIEMBROS_ALIANZA = 3;
    const MAX_PUNTOS_GUERRA    = 20;
    const DURACION_DEFAULT     = 7;
    const MAX_RONDAS           = 10;
    const MAX_RIVALES_MOSTRAR  = 4;

    public static $PESOS_NAVES = array(
        'small_ship_cargo' => 18,
        'big_ship_cargo'   => 36,
        'light_hunter'     => 30,
        'heavy_hunter'     => 60,
        'crusher'          => 120,
        'battle_ship'      => 240,
        'bomber_ship'      => 360,
        'destructor'       => 480,
        'death_star'       => 12000,
        'recycler'         => 48,
        'spy_sonde'        => 6,
        'solar_satelit'    => 12,
    );

    public static $PESOS_DEFENSAS = array(
        'misil_launcher'          => 80,
        'small_laser'             => 100,
        'big_laser'               => 250,
        'ionic_canyon'            => 150,
        'gauss_canyon'            => 1100,
        'buster_canyon'           => 3000,
        'small_protection_shield' => 1,
        'big_protection_shield'   => 1,
    );

    // ============ PREFIJO / DB ============
    private static function prefix()
    {
        return defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
    }

    private static function db()
    {
        return Database::get();
    }

    // Escapa un string para uso directo en SQL (fallback nativo)
    private static function esc($s)
    {
        return addslashes((string)$s);
    }

    // ============================================================
    // TEMPORADA
    // ============================================================

    public static function getSeason()
    {
        $p = self::prefix();
        $row = self::db()->selectSingle(
            "SELECT * FROM `" . $p . "war_seasons` WHERE `id` = 1 LIMIT 1"
        );
        if (empty($row)) {
            $now = (int)TIMESTAMP;
            self::db()->query(
                "INSERT INTO `" . $p . "war_seasons` (`id`, `duracion_horas`, `duracion_batalla_horas`, `cooldown_horas`, `updated_at`) VALUES (1, 7, 7, 7, " . $now . ")"
            );
            $row = self::db()->selectSingle(
                "SELECT * FROM `" . $p . "war_seasons` WHERE `id` = 1 LIMIT 1"
            );
        }
        return $row ? $row : array();
    }

    public static function seasonActive()
    {
        $s = self::getSeason();
        if (empty($s))                         return false;
        if (($s['estado'] !== 'activa'))       return false;
        if (!empty($s['pausada']))             return false;
        if (empty($s['fecha_fin']))            return false;
        return TIMESTAMP < (int)$s['fecha_fin'];
    }

    public static function seasonTimeLeft()
    {
        $s = self::getSeason();
        if (empty($s['fecha_fin'])) return 0;
        return max(0, (int)$s['fecha_fin'] - (int)TIMESTAMP);
    }

    /**
     * Activa la temporada con las 3 duraciones configurables.
     *
     * @param string $nombre       Nombre de la temporada
     * @param int    $horas        Duracion de la temporada en horas (1 a 840 = 35 dias)
     * @param int    $durBatalla   Duracion de cada batalla en horas (default 7)
     * @param int    $cooldown     Cooldown entre guerras por alianza (default 7)
     */
    public static function activateSeason($nombre, $horas, $durBatalla = 7, $cooldown = 7)
    {
        $p          = self::prefix();
        $now        = (int)TIMESTAMP;
        $h          = max(1, min(840, (int)$horas));           // max 35 dias = 840h
        $durBatalla = max(1, min(168, (int)$durBatalla));      // max 7 dias
        $cooldown   = max(0, min(168, (int)$cooldown));        // max 7 dias
        $fin        = $now + ($h * 3600);
        $nombre     = self::esc($nombre);

        return (bool)self::db()->query(
            "UPDATE `" . $p . "war_seasons` SET `estado` = 'activa', `pausada` = 0, `nombre_temporada` = '" . $nombre . "', `duracion_horas` = " . $h . ", `duracion_batalla_horas` = " . $durBatalla . ", `cooldown_horas` = " . $cooldown . ", `fecha_inicio` = " . $now . ", `fecha_fin` = " . $fin . ", `retiros_habilitados` = 0, `updated_at` = " . $now . " WHERE `id` = 1"
        );
    }

    public static function closeSeason()
    {
        $p   = self::prefix();
        $s   = self::getSeason();
        $now = (int)TIMESTAMP;

        $nombre = self::esc(isset($s['nombre_temporada']) ? $s['nombre_temporada'] : '');
        $inicio = (int)(isset($s['fecha_inicio']) ? $s['fecha_inicio'] : $now);

        self::db()->query(
            "INSERT INTO `" . $p . "war_history` (`nombre`, `inicio`, `fin`, `estado_final`, `created_at`) VALUES ('" . $nombre . "', " . $inicio . ", " . $now . ", 'cerrada_por_admin', " . $now . ")"
        );

        return (bool)self::db()->query(
            "UPDATE `" . $p . "war_seasons` SET `estado` = 'sin_temporada', `pausada` = 0, `retiros_habilitados` = 1, `fecha_fin` = NULL, `updated_at` = " . $now . " WHERE `id` = 1"
        );
    }

    public static function pauseSeason()
    {
        $p   = self::prefix();
        $now = (int)TIMESTAMP;
        return (bool)self::db()->query(
            "UPDATE `" . $p . "war_seasons` SET `pausada` = 1, `updated_at` = " . $now . " WHERE `id` = 1"
        );
    }

    public static function resumeSeason()
    {
        $p   = self::prefix();
        $now = (int)TIMESTAMP;
        return (bool)self::db()->query(
            "UPDATE `" . $p . "war_seasons` SET `pausada` = 0, `updated_at` = " . $now . " WHERE `id` = 1"
        );
    }

    public static function resetAll()
    {
        $p   = self::prefix();
        $now = (int)TIMESTAMP;

        self::db()->query("DELETE FROM `" . $p . "war_points`");
        self::db()->query("DELETE FROM `" . $p . "war_chests`");
        self::db()->query("DELETE FROM `" . $p . "war_participants`");
        self::db()->query("DELETE FROM `" . $p . "war_battles`");
        self::db()->query("DELETE FROM `" . $p . "war_history`");

        return (bool)self::db()->query(
            "UPDATE `" . $p . "war_seasons` SET `estado` = 'sin_temporada', `pausada` = 0, `retiros_habilitados` = 0, `fecha_inicio` = NULL, `fecha_fin` = NULL, `nombre_temporada` = '', `updated_at` = " . $now . " WHERE `id` = 1"
        );
    }

    // ============================================================
    // PUNTOS WAR
    // ============================================================

    public static function getUserPoints($userId)
    {
        $p      = self::prefix();
        $userId = (int)$userId;

        $row = self::db()->selectSingle(
            "SELECT * FROM `" . $p . "war_points` WHERE `user_id` = " . $userId . " LIMIT 1"
        );
        if (empty($row)) {
            $now = (int)TIMESTAMP;
            self::db()->query(
                "INSERT INTO `" . $p . "war_points` (`user_id`, `puntos`, `naves_enviadas`, `defensas_enviadas`, `updated_at`) VALUES (" . $userId . ", 0, '{}', '{}', " . $now . ")"
            );
            return array(
                'user_id'           => $userId,
                'puntos'            => 0,
                'naves_enviadas'    => '{}',
                'defensas_enviadas' => '{}',
            );
        }
        return $row;
    }

    public static function addPoints($userId, $puntos)
    {
        $puntos = (int)$puntos;
        if ($puntos <= 0) return false;
        $p      = self::prefix();
        $userId = (int)$userId;
        $now    = (int)TIMESTAMP;

        self::getUserPoints($userId);

        return (bool)self::db()->query(
            "UPDATE `" . $p . "war_points` SET `puntos` = `puntos` + " . $puntos . ", `updated_at` = " . $now . " WHERE `user_id` = " . $userId
        );
    }

    public static function getRanking($limit = 50)
    {
        $p     = self::prefix();
        $limit = (int)$limit;

        $rows = self::db()->select(
            "SELECT wp.`user_id`, wp.`puntos`, u.`username`, u.`ally_id`, a.`ally_name`
             FROM `" . $p . "war_points` wp
             LEFT JOIN `" . $p . "users`    u ON u.`id` = wp.`user_id`
             LEFT JOIN `" . $p . "alliance` a ON a.`id` = u.`ally_id`
             WHERE wp.`puntos` > 0
             ORDER BY wp.`puntos` DESC
             LIMIT " . $limit
        );
        if (!$rows) return array();

        foreach ($rows as &$r) {
            $r['alliance_name'] = !empty($r['ally_name']) ? $r['ally_name'] : '';
        }
        return $rows;
    }

    public static function getRankingByAlly($allyId, $limit = 50)
    {
        $p      = self::prefix();
        $allyId = (int)$allyId;
        $limit  = (int)$limit;

        return self::db()->select(
            "SELECT wp.`user_id`, wp.`puntos`, u.`username`
             FROM `" . $p . "war_points` wp
             INNER JOIN `" . $p . "users` u ON u.`id` = wp.`user_id`
             WHERE wp.`puntos` > 0 AND u.`ally_id` = " . $allyId . "
             ORDER BY wp.`puntos` DESC
             LIMIT " . $limit
        );
    }

    // ============================================================
    // BATALLAS Y COOLDOWN
    // ============================================================

    /**
     * Devuelve la batalla activa de una alianza (o null).
     */
    public static function getActiveBattleForAlly($allyId)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) return null;
        $p = self::prefix();

        $row = self::db()->selectSingle(
            "SELECT * FROM `" . $p . "war_battles`
             WHERE `estado` = 'en_curso'
               AND (`atacante_id` = " . $allyId . " OR `defensor_id` = " . $allyId . ")
             ORDER BY `id` DESC LIMIT 1"
        );
        return $row ? $row : null;
    }

    /**
     * Devuelve los segundos que le quedan de cooldown a una alianza.
     * El cooldown empieza cuando DECLARA (inicio de la batalla).
     */
    public static function getAllyCooldownLeft($allyId)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) return 0;
        $p   = self::prefix();
        $now = (int)TIMESTAMP;

        // Buscar la ultima batalla (en curso o finalizada) donde participo
        $row = self::db()->selectSingle(
            "SELECT `inicio`, `fin` FROM `" . $p . "war_battles`
             WHERE `atacante_id` = " . $allyId . " OR `defensor_id` = " . $allyId . "
             ORDER BY `id` DESC LIMIT 1"
        );
        if (empty($row)) return 0;

        // El cooldown empieza cuando declara (inicio de la batalla)
        $season      = self::getSeason();
        $cooldownH   = isset($season['cooldown_horas']) ? (int)$season['cooldown_horas'] : 7;
        $finCooldown = (int)$row['inicio'] + ($cooldownH * 3600);

        return max(0, $finCooldown - $now);
    }

    /**
     * Verifica si una alianza puede declarar guerra.
     * Devuelve array('ok' => true) o array('ok' => false, 'motivo' => '...').
     */
    public static function canAllyDeclare($allyId)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) {
            return array('ok' => false, 'motivo' => 'Alianza invalida.');
        }

        // 1. Temporada activa?
        if (!self::seasonActive()) {
            return array('ok' => false, 'motivo' => 'No hay temporada activa.');
        }

        // 2. Ya tiene una batalla activa?
        $battle = self::getActiveBattleForAlly($allyId);
        if (!empty($battle)) {
            return array('ok' => false, 'motivo' => 'Tu alianza ya tiene una guerra activa.');
        }

        // 3. Esta en cooldown?
        $cooldownLeft = self::getAllyCooldownLeft($allyId);
        if ($cooldownLeft > 0) {
            return array('ok' => false, 'motivo' => 'Tu alianza esta en cooldown.', 'restante' => $cooldownLeft);
        }

        return array('ok' => true);
    }

    // ============================================================
    // EMPAREJAMIENTO ADAPTATIVO (getRivals)
    // ============================================================

    /**
     * Devuelve hasta MAX_RIVALES_MOSTRAR alianzas rivales sugeridas.
     * Emparejamiento adaptativo: empieza en +-5% y sube hasta +-100%.
     */
    public static function getRivals($myAllyId)
    {
        $myAllyId = (int)$myAllyId;
        if ($myAllyId <= 0) return array();

        $p  = self::prefix();
        $db = self::db();

        $myDamage = self::getAllyDamage($myAllyId);
        $rivals   = array();

        // Busqueda adaptativa por rango de dano
        for ($factor = 0.05; $factor <= 1.00; $factor += 0.05) {

            // Traer alianzas validas
            $rows = $db->select(
                "SELECT a.`id`, a.`ally_name`, a.`ally_tag`, a.`ally_members`, a.`ally_owner`
                 FROM `" . $p . "alliance` a
                 WHERE a.`id` != " . $myAllyId . "
                   AND a.`ally_members` >= " . self::MIN_MIEMBROS_ALIANZA . "
                 LIMIT 30"
            );
            if (!$rows) $rows = array();

            foreach ($rows as $r) {
                $rid = (int)$r['id'];
                if (isset($rivals[$rid])) continue;

                $dmg = self::getAllyDamage($rid);
                $min = (int)floor($myDamage * (1 - $factor));
                $max = (int)ceil($myDamage * (1 + $factor));
                if ($min < 0) $min = 0;

                if ($dmg < $min || $dmg > $max) continue;

                // El rival tambien debe poder ser atacado
                $canDecl = self::canAllyDeclare($rid);
                if (empty($canDecl['ok'])) continue;

                $r['damage']   = $dmg;
                $r['diff']     = abs($dmg - $myDamage);
                $r['diff_pct'] = ($myDamage > 0)
                    ? (int)round((abs($dmg - $myDamage) / $myDamage) * 100)
                    : 0;
                $rivals[$rid]  = $r;
            }

            if (count($rivals) >= self::MAX_RIVALES_MOSTRAR) break;
        }

        // Fallback: si no encontro nada, ampliar a cualquier alianza valida
        if (empty($rivals)) {
            $rows = $db->select(
                "SELECT a.`id`, a.`ally_name`, a.`ally_tag`, a.`ally_members`
                 FROM `" . $p . "alliance` a
                 WHERE a.`id` != " . $myAllyId . "
                   AND a.`ally_members` >= " . self::MIN_MIEMBROS_ALIANZA . "
                 LIMIT 30"
            );
            if (!$rows) $rows = array();

            foreach ($rows as $r) {
                $rid = (int)$r['id'];
                if (isset($rivals[$rid])) continue;

                $canDecl = self::canAllyDeclare($rid);
                if (empty($canDecl['ok'])) continue;

                $dmg = self::getAllyDamage($rid);
                $r['damage']   = $dmg;
                $r['diff']     = abs($dmg - $myDamage);
                $r['diff_pct'] = ($myDamage > 0)
                    ? (int)round((abs($dmg - $myDamage) / $myDamage) * 100)
                    : 0;
                $rivals[$rid]  = $r;
            }
        }

        // Ordenar por cercania de dano y cortar a MAX
        if (!empty($rivals)) {
            uasort($rivals, function($a, $b) {
                if ($a['diff'] == $b['diff']) return 0;
                return ($a['diff'] < $b['diff']) ? -1 : 1;
            });
            $rivals = array_slice($rivals, 0, self::MAX_RIVALES_MOSTRAR, true);
        }

        return $rivals;
    }

    // ============================================================
    // CREAR BATALLA
    // ============================================================

    /**
     * Crea una batalla entre dos alianzas.
     * Devuelve el ID de la batalla (o false si falla).
     */
    public static function createBattle($atkId, $defId)
    {
        $atkId = (int)$atkId;
        $defId = (int)$defId;
        if ($atkId <= 0 || $defId <= 0 || $atkId === $defId) return false;

        $p = self::prefix();

        // Validar atacante
        $atk = self::canAllyDeclare($atkId);
        if (empty($atk['ok'])) return false;

        // Validar defensor
        $def = self::canAllyDeclare($defId);
        if (empty($def['ok'])) return false;

        // Duracion de batalla (config temporada)
        $season      = self::getSeason();
        $durBatallaH = isset($season['duracion_batalla_horas']) ? (int)$season['duracion_batalla_horas'] : 7;
        if ($durBatallaH < 1)   $durBatallaH = 7;
        if ($durBatallaH > 168) $durBatallaH = 168;

        // No puede durar mas que la temporada restante
        $tiempoTemporada = self::seasonTimeLeft();
        $maxBatalla      = $durBatallaH * 3600;
        if ($tiempoTemporada > 0 && $tiempoTemporada < $maxBatalla) {
            $duracionSeg = $tiempoTemporada;
        } else {
            $duracionSeg = $maxBatalla;
        }

        $now = (int)TIMESTAMP;
        $fin = $now + $duracionSeg;

        // Nombres
        $atkName = self::esc(self::getAllyName($atkId));
        $defName = self::esc(self::getAllyName($defId));

        // Clima aleatorio
        $climaKey    = '';
        $climaNombre = '';
        if (class_exists('WarClimatesHelper')) {
            $climaKey    = WarClimatesHelper::random();
            $climaNombre = WarClimatesHelper::getName($climaKey);
        }
        $climaKey    = self::esc($climaKey);
        $climaNombre = self::esc($climaNombre);

        // Insertar batalla
        $ok = self::db()->query(
            "INSERT INTO `" . $p . "war_battles`
                (`atacante_id`, `atacante_nombre`, `defensor_id`, `defensor_nombre`,
                 `inicio`, `fin`, `estado`, `clima_key`, `clima_nombre`, `created_at`)
             VALUES
                (" . $atkId . ", '" . $atkName . "', " . $defId . ", '" . $defName . "',
                 " . $now . ", " . $fin . ", 'en_curso', '" . $climaKey . "', '" . $climaNombre . "', " . $now . ")"
        );

        if (!$ok) return false;

        $battleId = (int)self::db()->lastInsertId();
        if ($battleId <= 0) return false;

        self::log(0, 'battle_created',
            "Batalla #{$battleId}: {$atkName} (ID {$atkId}) vs {$defName} (ID {$defId}) | clima: {$climaKey}",
            $battleId);

        return $battleId;
    }

    // ============================================================
    // NOTIFICAR ALIANZA
    // ============================================================

    /**
     * Envia mensaje interno a todos los miembros de una alianza.
     * Usa PlayerUtil::sendMessage si esta disponible.
     */
    public static function notifyAlly($allyId, $asunto, $mensaje)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) return;
        if (!class_exists('PlayerUtil')) return;

        $p = self::prefix();
        $rows = self::db()->select(
            "SELECT `id` FROM `" . $p . "users` WHERE `ally_id` = " . $allyId
        );
        if (!$rows) return;

        foreach ($rows as $r) {
            $uid = (int)$r['id'];
            if ($uid <= 0) continue;
            try {
                PlayerUtil::sendMessage(
                    $uid,
                    0,              // sender = sistema
                    'Sistema WAR',  // sender_name
                    4,              // message_type (4 = sistema)
                    $asunto,
                    $mensaje,
                    TIMESTAMP
                );
            } catch (Exception $e) {
                // Silencioso — no romper el flujo
            }
        }
    }

    // ============================================================
    // ENVIO DE FLOTAS (para el tab "Enviar")
    // ============================================================

    /**
     * Devuelve los planetas del jugador con TODAS sus naves y defensas.
     * Solo planetas tipo 1 (planetas, no lunas).
     */
    public static function getPlayerPlanetsWithShips($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return array();

        $p = self::prefix();

        $shipCols = array_keys(self::$PESOS_NAVES);
        $defCols  = array_keys(self::$PESOS_DEFENSAS);
        $allCols  = array_merge($shipCols, $defCols);

        $colsList = array();
        foreach ($allCols as $c) {
            $colsList[] = "`" . $c . "`";
        }
        $colsStr = "`id`, `name`, `galaxy`, `system`, `planet`, `planet_type`, " . implode(', ', $colsList);

        $rows = self::db()->select(
            "SELECT " . $colsStr . " FROM `" . $p . "planets`
             WHERE `id_owner` = " . $userId . " AND `planet_type` = 1
             ORDER BY `id` ASC"
        );

        return $rows ? $rows : array();
    }

    /**
     * Registra un participante en la batalla (guarda naves/defensas).
     */
    public static function registerParticipant($battleId, $userId, $allyId, $naves, $defensas, $planetas)
    {
        $battleId = (int)$battleId;
        $userId   = (int)$userId;
        $allyId   = (int)$allyId;
        if ($battleId <= 0 || $userId <= 0) return false;

        $p = self::prefix();

        $navesJson    = self::esc(json_encode($naves));
        $defensasJson = self::esc(json_encode($defensas));
        $planetasJson = self::esc(json_encode($planetas));
        $now          = (int)TIMESTAMP;

        return (bool)self::db()->query(
            "INSERT INTO `" . $p . "war_participants`
                (`battle_id`, `user_id`, `alliance_id`, `naves_json`, `defensas_json`, `planetas_json`, `fecha_envio`)
             VALUES
                (" . $battleId . ", " . $userId . ", " . $allyId . ", '" . $navesJson . "', '" . $defensasJson . "', '" . $planetasJson . "', " . $now . ")"
        );
    }

    // ============================================================
    // UTILIDADES
    // ============================================================

    public static function log($userId, $accion, $detalle, $battleId = 0)
    {
        $p   = self::prefix();
        $ip  = isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : '';
        $now = (int)TIMESTAMP;

        self::db()->query(
            "INSERT INTO `" . $p . "war_log` (`user_id`, `battle_id`, `accion`, `detalle`, `ip`, `fecha`) VALUES (" . (int)$userId . ", " . (int)$battleId . ", '" . self::esc($accion) . "', '" . self::esc($detalle) . "', '" . self::esc($ip) . "', " . $now . ")"
        );
    }

    public static function getAllyName($allyId)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) return 'Sin alianza';
        $p = self::prefix();

        $row = self::db()->selectSingle(
            "SELECT `ally_name` FROM `" . $p . "alliance` WHERE `id` = " . $allyId . " LIMIT 1"
        );
        if (!empty($row['ally_name'])) {
            return $row['ally_name'];
        }
        return 'Alianza #' . $allyId;
    }

    public static function getAllyDamage($allyId)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) return 0;
        $p = self::prefix();

        $row = self::db()->selectSingle(
            "SELECT COALESCE(SUM(wp.`puntos`), 0) AS total
             FROM `" . $p . "war_points` wp
             INNER JOIN `" . $p . "users` u ON u.`id` = wp.`user_id`
             WHERE u.`ally_id` = " . $allyId
        );
        return (int)(isset($row['total']) ? $row['total'] : 0);
    }

    public static function isAllyAdmin($userId, $allyId)
    {
        $userId = (int)$userId;
        $allyId = (int)$allyId;
        if ($userId <= 0 || $allyId <= 0) return false;
        $p = self::prefix();

        // Fundador
        $ally = self::db()->selectSingle(
            "SELECT `ally_owner` FROM `" . $p . "alliance` WHERE `id` = " . $allyId . " LIMIT 1"
        );
        if (!empty($ally['ally_owner']) && (int)$ally['ally_owner'] === $userId) {
            return true;
        }

        // Rango admin en la alianza
        $row = self::db()->selectSingle(
            "SELECT `ally_rank_id` FROM `" . $p . "users` WHERE `id` = " . $userId . " AND `ally_id` = " . $allyId . " LIMIT 1"
        );
        if (!empty($row['ally_rank_id']) && (int)$row['ally_rank_id'] >= 2) {
            return true;
        }

        return false;
    }
}