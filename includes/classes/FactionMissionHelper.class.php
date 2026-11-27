<?php
/**
 * FactionMissionHelper — Sistema de Misiones de Facción AstroIO v1.1
 * 
 * Personales (diarias, compartidas por facción, rotación aleatoria)
 * Globales (por facción, rotación secuencial, buff 5 días al completar)
 * 
 * v1.1:
 * - Integrada la validación de requisitos del BattlePass.
 * - Si el jugador no tiene el Hangar/Lab necesario, se le entregan recursos equivalentes.
 */
if (!defined('MODE')) { die('Hacking attempt'); }

class FactionMissionHelper
{
    private static $bonusCache = [];
    private static $rotationDone = false;

    /* ============================================================
     * MAPEO DE NAVES Y DEFENSAS (Para requisitos)
     * ============================================================ */
    private static $NAVES = [
        202 => 'small_ship_cargo', 203 => 'big_ship_cargo', 204 => 'light_hunter',
        205 => 'heavy_hunter', 206 => 'crusher', 207 => 'battle_ship',
        208 => 'colonizer', 209 => 'recycler', 210 => 'spy_sonde',
        211 => 'bomber_ship', 212 => 'solar_satelit', 213 => 'destructor',
        214 => 'dearth_star', 215 => 'battleship', 216 => 'lune_noir',
        217 => 'ev_transporter', 218 => 'star_crasher', 219 => 'giga_recykler',
        220 => 'dm_ship'
    ];

    private static $DEFENSAS = [
        401 => 'misil_launcher', 402 => 'small_laser', 403 => 'big_laser',
        404 => 'gauss_canyon', 405 => 'ionic_canyon', 406 => 'buster_canyon',
        407 => 'small_protection_shield', 408 => 'big_protection_shield',
        409 => 'planet_protector', 410 => 'graviton_canyon', 411 => 'orbital_station'
    ];

    private static function db()     { return Database::get(); }
    private static function prefix() { return defined('DB_PREFIX') ? DB_PREFIX : 'uni1_'; }

    private static function todayUtc()
    {
        return gmdate('Y-m-d');
    }

    /* ============================================================
     * ROTACIÓN DIARIA — PERSONALES
     * ============================================================ */
    public static function rotatePersonalMissions()
    {
        if (self::$rotationDone) return;
        self::$rotationDone = true;

        $today = self::todayUtc();

        $factions = self::db()->select(
            "SELECT DISTINCT faction_id FROM %%FACTION_MISSIONS%% WHERE mission_type = 'personal' AND active = 1"
        );

        foreach ($factions as $f) {
            $fid = (int) $f['faction_id'];
            if ($fid <= 0) continue;

            $exists = self::db()->selectSingle(
                "SELECT id FROM %%FACTION_DAILY_ROTATION%% WHERE faction_id = :fid AND rotation_date = :d",
                [':fid' => $fid, ':d' => $today]
            );
            if ($exists) continue;

            $mission = self::db()->selectSingle(
                "SELECT id FROM %%FACTION_MISSIONS%%
                 WHERE faction_id = :fid AND mission_type = 'personal' AND active = 1
                 ORDER BY RAND() LIMIT 1",
                [':fid' => $fid]
            );
            if (!$mission) continue;

            self::db()->insert(
                "INSERT INTO %%FACTION_DAILY_ROTATION%% (faction_id, mission_id, rotation_date)
                 VALUES (:fid, :mid, :d)",
                [':fid' => $fid, ':mid' => (int) $mission['id'], ':d' => $today]
            );

            self::log(0, $fid, (int) $mission['id'], 'rotate_daily', 0, 'Rotación personal ' . $today);
        }
    }

    public static function getTodayPersonalMission($factionId)
    {
        if ((int) $factionId <= 0) return null;

        self::rotatePersonalMissions();
        $today = self::todayUtc();

        $row = self::db()->selectSingle(
            "SELECT m.* FROM %%FACTION_DAILY_ROTATION%% r
             INNER JOIN %%FACTION_MISSIONS%% m ON m.id = r.mission_id
             WHERE r.faction_id = :fid AND r.rotation_date = :d AND m.active = 1",
            [':fid' => (int) $factionId, ':d' => $today]
        );
        return $row ?: null;
    }

    public static function getPersonalProgress($userId, $missionId)
    {
        if ($userId <= 0 || $missionId <= 0) return null;

        return self::db()->selectSingle(
            "SELECT * FROM %%USERS_FACTION_MISSIONS%%
             WHERE user_id = :uid AND mission_id = :mid AND rotation_date = :d",
            [':uid' => (int) $userId, ':mid' => (int) $missionId, ':d' => self::todayUtc()]
        ) ?: null;
    }

    public static function addPersonalProgress($userId, $actionType, $targetType, $targetId, $amount)
    {
        if ($amount <= 0 || $userId <= 0) return;

        $user = self::db()->selectSingle(
            "SELECT faction_id FROM %%USERS%% WHERE id = :uid",
            [':uid' => (int) $userId]
        );
        if (empty($user) || (int) $user['faction_id'] <= 0) return;

        $factionId = (int) $user['faction_id'];
        $mission   = self::getTodayPersonalMission($factionId);
        if (!$mission) return;

        if ($mission['action_type'] !== $actionType) return;
        if ($mission['target_type'] !== 'any' && $mission['target_type'] !== $targetType) return;
        if ((int) $mission['target_id'] > 0 && (int) $mission['target_id'] !== (int) $targetId) return;

        $today    = self::todayUtc();
        $progress = self::getPersonalProgress($userId, (int) $mission['id']);

        if ($progress && (int) $progress['claimed'] === 1) return;

        $newProgress = ($progress ? (int) $progress['progress'] : 0) + (int) $amount;
        $cap         = (int) $mission['target_amount'];
        if ($newProgress > $cap) $newProgress = $cap;

        if ($progress) {
            self::db()->update(
                "UPDATE %%USERS_FACTION_MISSIONS%%
                 SET progress = :p
                 WHERE user_id = :uid AND mission_id = :mid AND rotation_date = :d",
                [':p' => $newProgress, ':uid' => (int) $userId, ':mid' => (int) $mission['id'], ':d' => $today]
            );
        } else {
            self::db()->insert(
                "INSERT INTO %%USERS_FACTION_MISSIONS%%
                    (user_id, faction_id, mission_id, progress, claimed, claimed_at, rotation_date)
                 VALUES (:uid, :fid, :mid, :p, 0, 0, :d)",
                [
                    ':uid' => (int) $userId,
                    ':fid' => $factionId,
                    ':mid' => (int) $mission['id'],
                    ':p'   => $newProgress,
                    ':d'   => $today,
                ]
            );
        }
    }

    /* ============================================================
     * GLOBALES
     * ============================================================ */
    public static function getGlobalMission($factionId)
    {
        if ((int) $factionId <= 0) return null;
        $config = Config::get();

        $row = self::db()->selectSingle(
            "SELECT g.*, m.name, m.description, m.icon, m.action_type, m.target_type, m.target_id,
                    m.reward_type, m.reward_json
             FROM %%FACTION_GLOBAL_MISSIONS%% g
             INNER JOIN %%FACTION_MISSIONS%% m ON m.id = g.mission_id
             WHERE g.faction_id = :fid AND g.status IN ('active','completed','bonus_active')
             ORDER BY g.id DESC LIMIT 1",
            [':fid' => (int) $factionId]
        );

        if (!$row) {
            $row = self::createNextGlobalMission($factionId);
        }
        return $row;
    }

    private static function createNextGlobalMission($factionId)
    {
        $last = self::db()->selectSingle(
            "SELECT mission_id FROM %%FACTION_GLOBAL_MISSIONS%%
             WHERE faction_id = :fid ORDER BY id DESC LIMIT 1",
            [':fid' => (int) $factionId]
        );

        if ($last) {
            $next = self::db()->selectSingle(
                "SELECT * FROM %%FACTION_MISSIONS%%
                 WHERE faction_id = :fid AND mission_type = 'global' AND active = 1
                   AND sort_order > (SELECT sort_order FROM %%FACTION_MISSIONS%% WHERE id = :last)
                 ORDER BY sort_order ASC LIMIT 1",
                [':fid' => (int) $factionId, ':last' => (int) $last['mission_id']]
            );
        } else {
            $next = null;
        }

        if (!$next) {
            $next = self::db()->selectSingle(
                "SELECT * FROM %%FACTION_MISSIONS%%
                 WHERE faction_id = :fid AND mission_type = 'global' AND active = 1
                 ORDER BY sort_order ASC LIMIT 1",
                [':fid' => (int) $factionId]
            );
        }
        if (!$next) return null;

        $config    = Config::get();
        $divisor   = max(1, (int) $config->faction_global_base_divisor);
        $members   = self::db()->selectSingle(
            "SELECT COUNT(*) AS c FROM %%USERS%% WHERE faction_id = :fid AND is_pve = 0",
            [':fid' => (int) $factionId]
        );
        $count     = max(1, (int) ($members['c'] ?? 1));
        $mult      = max(1, $count / $divisor);
        $target    = (int) round((int) $next['target_amount'] * $mult);

        self::db()->insert(
            "INSERT INTO %%FACTION_GLOBAL_MISSIONS%%
                (faction_id, mission_id, progress, target, status, bonus_end, bonus_type, bonus_value, cycle_start)
             VALUES (:fid, :mid, 0, :tgt, 'active', 0, NULL, 0, :cs)",
            [
                ':fid' => (int) $factionId,
                ':mid' => (int) $next['id'],
                ':tgt' => $target,
                ':cs'  => (int) TIMESTAMP,
            ]
        );

        return self::getGlobalMission($factionId);
    }

    public static function addGlobalProgress($userId, $actionType, $targetType, $targetId, $amount)
    {
        if ($amount <= 0 || $userId <= 0) return;

        $user = self::db()->selectSingle(
            "SELECT faction_id FROM %%USERS%% WHERE id = :uid",
            [':uid' => (int) $userId]
        );
        if (empty($user) || (int) $user['faction_id'] <= 0) return;

        $factionId = (int) $user['faction_id'];
        $global    = self::getGlobalMission($factionId);
        if (!$global || $global['status'] !== 'active') return;

        if ($global['action_type'] !== $actionType) return;
        if ($global['target_type'] !== 'any' && $global['target_type'] !== $targetType) return;
        if ((int) $global['target_id'] > 0 && (int) $global['target_id'] !== (int) $targetId) return;

        self::db()->insert(
            "INSERT INTO %%FACTION_GLOBAL_CONTRIB%%
                (global_mission_id, user_id, amount, created_at)
             VALUES (:gid, :uid, :amt, :now)",
            [':gid' => (int) $global['id'], ':uid' => (int) $userId, ':amt' => (int) $amount, ':now' => (int) TIMESTAMP]
        );

        $newProgress = (int) $global['progress'] + (int) $amount;
        $target      = (int) $global['target'];

        if ($newProgress >= $target) {
            self::completeGlobalMission($factionId, (int) $global['id']);
        } else {
            self::db()->update(
                "UPDATE %%FACTION_GLOBAL_MISSIONS%%
                 SET progress = :p
                 WHERE id = :id AND status = 'active'",
                [':p' => $newProgress, ':id' => (int) $global['id']]
            );
        }
    }

    private static function completeGlobalMission($factionId, $globalId)
    {
        $config    = Config::get();
        $bonusDays = max(1, (int) $config->faction_global_bonus_days);
        $bonusEnd  = TIMESTAMP + 86400 * $bonusDays;

        $buff = self::rollFactionBuff($factionId);
        if (!$buff) {
            self::db()->update(
                "UPDATE %%FACTION_GLOBAL_MISSIONS%% SET status = 'completed' WHERE id = :id",
                [':id' => (int) $globalId]
            );
            return;
        }

        self::db()->update(
            "UPDATE %%FACTION_GLOBAL_MISSIONS%%
             SET progress = target, status = 'bonus_active', bonus_end = :be,
                 bonus_type = :bt, bonus_value = :bv
             WHERE id = :id",
            [
                ':be' => (int) $bonusEnd,
                ':bt' => (string) $buff['buff_type'],
                ':bv' => (float) $buff['buff_value'],
                ':id' => (int) $globalId,
            ]
        );

        self::db()->insert(
            "INSERT INTO %%FACTION_BONUSES%%
                (faction_id, bonus_type, bonus_value, source_mission_id, expires_at, created_at)
             VALUES (:fid, :bt, :bv, :sid, :exp, :now)",
            [
                ':fid' => (int) $factionId,
                ':bt'  => (string) $buff['buff_type'],
                ':bv'  => (float) $buff['buff_value'],
                ':sid' => 0,
                ':exp' => (int) $bonusEnd,
                ':now' => (int) TIMESTAMP,
            ]
        );

        self::$bonusCache = [];

        self::log(0, $factionId, $globalId, 'global_complete', 0,
            'Buff sorteado: ' . $buff['buff_name'] . ' (' . $buff['buff_value'] . ') por ' . $bonusDays . ' días'
        );
    }

    private static function rollFactionBuff($factionId)
    {
        $buffs = self::db()->select(
            "SELECT * FROM %%FACTION_BUFF_POOL%%
             WHERE faction_id = :fid AND active = 1",
            [':fid' => (int) $factionId]
        );
        if (empty($buffs)) return null;

        $totalWeight = 0;
        foreach ($buffs as $b) $totalWeight += max(1, (int) $b['weight']);

        $roll = mt_rand(1, $totalWeight);
        $acc  = 0;
        foreach ($buffs as $b) {
            $acc += max(1, (int) $b['weight']);
            if ($roll <= $acc) return $b;
        }
        return $buffs[0];
    }

    /* ============================================================
     * RECLAMAR RECOMPENSA PERSONAL
     * ============================================================ */
    public static function claimPersonalReward($userId, $missionId)
    {
        if ($userId <= 0 || $missionId <= 0) return ['ok' => false, 'msg' => 'Datos inválidos'];

        $user = self::db()->selectSingle(
            "SELECT faction_id FROM %%USERS%% WHERE id = :uid",
            [':uid' => (int) $userId]
        );
        if (empty($user) || (int) $user['faction_id'] <= 0) return ['ok' => false, 'msg' => 'No estás en una facción'];

        $factionId = (int) $user['faction_id'];
        $mission   = self::db()->selectSingle(
            "SELECT * FROM %%FACTION_MISSIONS%%
             WHERE id = :mid AND faction_id = :fid AND mission_type = 'personal' AND active = 1",
            [':mid' => (int) $missionId, ':fid' => $factionId]
        );
        if (!$mission) return ['ok' => false, 'msg' => 'Misión no encontrada o no es de tu facción'];

        $today    = self::todayUtc();
        $progress = self::getPersonalProgress($userId, $missionId);
        if (!$progress) return ['ok' => false, 'msg' => 'No tenés progreso en esta misión'];
        if ((int) $progress['claimed'] === 1) return ['ok' => false, 'msg' => 'Ya reclamaste esta misión'];
        if ((int) $progress['progress'] < (int) $mission['target_amount'])
            return ['ok' => false, 'msg' => 'Aún no completaste la misión'];

        self::db()->update(
            "UPDATE %%USERS_FACTION_MISSIONS%%
             SET claimed = 1, claimed_at = :now
             WHERE user_id = :uid AND mission_id = :mid AND rotation_date = :d AND claimed = 0",
            [':now' => (int) TIMESTAMP, ':uid' => (int) $userId, ':mid' => (int) $missionId, ':d' => $today]
        );

        $reward = json_decode($mission['reward_json'] ?: '{}', true);
        $ok     = self::grantReward($userId, $mission['reward_type'], $reward);

        if (!$ok) {
            self::db()->update(
                "UPDATE %%USERS_FACTION_MISSIONS%%
                 SET claimed = 0, claimed_at = 0
                 WHERE user_id = :uid AND mission_id = :mid AND rotation_date = :d",
                [':uid' => (int) $userId, ':mid' => (int) $missionId, ':d' => $today]
            );
            return ['ok' => false, 'msg' => 'No se pudo entregar la recompensa'];
        }

        self::log((int) $userId, $factionId, (int) $missionId, 'claim_personal', 0, 'Recompensa reclamada');
        return ['ok' => true, 'msg' => 'Recompensa reclamada: ' . $mission['name']];
    }

    public static function getAllBonusesForUser($userId)
    {
        $user = self::db()->selectSingle(
            "SELECT faction_id FROM %%USERS%% WHERE id = :uid",
            [':uid' => (int) $userId]
        );
        if (empty($user) || (int) $user['faction_id'] <= 0) return [];

        return self::getAllBonusesByFaction((int) $user['faction_id']);
    }

    public static function getAllBonusesByFaction($factionId)
    {
        if ((int) $factionId <= 0) return [];

        $key = 'all_' . $factionId;
        if (isset(self::$bonusCache[$key])) return self::$bonusCache[$key];

        $rows = self::db()->select(
            "SELECT bonus_type, SUM(bonus_value) AS total
             FROM %%FACTION_BONUSES%%
             WHERE faction_id = :fid AND expires_at > :now
             GROUP BY bonus_type",
            [':fid' => (int) $factionId, ':now' => (int) TIMESTAMP]
        );
        $out = [];
        foreach ($rows as $r) $out[$r['bonus_type']] = (float) $r['total'];

        self::$bonusCache[$key] = $out;
        return $out;
    }

    public static function getBonusForUser($userId, $bonusType)
    {
        $bonuses = self::getAllBonusesForUser($userId);
        return isset($bonuses[$bonusType]) ? (float) $bonuses[$bonusType] : 0.0;
    }

    /* ============================================================
     * ENTREGAR RECOMPENSA (CON VALIDACIÓN DE REQUISITOS)
     * ============================================================ */
    private static function grantReward($userId, $rewardType, $rewardJson)
    {
        $user   = $GLOBALS['USER'] ?? null;
        $planet = $GLOBALS['PLANET'] ?? null;
        global $resource; // Para saber el nombre de la columna

        switch ($rewardType) {
            case 'ntx20':
                $amount = (int) ($rewardJson['amount'] ?? 0);
                if ($amount <= 0) return false;
                self::db()->update(
                    "UPDATE %%USERS%% SET ntx20 = ntx20 + :a WHERE id = :uid",
                    [':a' => $amount, ':uid' => (int) $userId]
                );
                if ($user && (int) $user['id'] === (int) $userId)
                    $GLOBALS['USER']['ntx20'] += $amount;
                return true;

            case 'darkmatter':
                $amount = (int) ($rewardJson['amount'] ?? 0);
                if ($amount <= 0) return false;
                self::db()->update(
                    "UPDATE %%USERS%% SET darkmatter = darkmatter + :a WHERE id = :uid",
                    [':a' => $amount, ':uid' => (int) $userId]
                );
                if ($user && (int) $user['id'] === (int) $userId)
                    $GLOBALS['USER']['darkmatter'] += $amount;
                return true;

            case 'container':
                $amount = (int) ($rewardJson['amount'] ?? 1);
                if ($amount <= 0) return false;
                self::db()->update(
                    "UPDATE %%USERS%% SET containers = containers + :a WHERE id = :uid",
                    [':a' => $amount, ':uid' => (int) $userId]
                );
                if ($user && (int) $user['id'] === (int) $userId)
                    $GLOBALS['USER']['containers'] += $amount;
                return true;

            case 'resource':
                $planetId = (int) ($planet['id'] ?? 0);
                if ($planetId <= 0) return false;
                $m = (int) ($rewardJson['metal'] ?? 0);
                $c = (int) ($rewardJson['crystal'] ?? 0);
                $d = (int) ($rewardJson['deuterium'] ?? 0);
                self::db()->update(
                    "UPDATE %%PLANETS%%
                     SET metal = metal + :m, crystal = crystal + :c, deuterium = deuterium + :d
                     WHERE id = :pid",
                    [':m' => $m, ':c' => $c, ':d' => $d, ':pid' => $planetId]
                );
                if ($planet && (int) $planet['id'] === $planetId) {
                    $GLOBALS['PLANET']['metal']     += $m;
                    $GLOBALS['PLANET']['crystal']   += $c;
                    $GLOBALS['PLANET']['deuterium'] += $d;
                }
                return true;

            case 'ship':
            case 'defense':
                $amount = (int) ($rewardJson['amount'] ?? 0);
                $itemId = (int) ($rewardJson['item_id'] ?? 0);
                if ($amount <= 0 || $itemId <= 0) return false;

                $planetId = (int) ($planet['id'] ?? 0);
                if ($planetId <= 0) return false;

                // 🛡️ LÓGICA DE VALIDACIÓN (Copiada del BattlePass)
                if (self::cumpleRequisitos($userId, $planetId, $itemId)) {
                    // El jugador cumple los requisitos → Le damos la nave/defensa
                    $column = $resource[$itemId] ?? null;
                    if (!$column) return false;

                    self::db()->update(
                        "UPDATE %%PLANETS%% SET `$column` = `$column` + :a WHERE id = :pid",
                        [':a' => $amount, ':pid' => $planetId]
                    );
                    if ($planet && (int) $planet['id'] === $planetId) {
                        if (!isset($GLOBALS['PLANET'][$column])) $GLOBALS['PLANET'][$column] = 0;
                        $GLOBALS['PLANET'][$column] += $amount;
                    }
                    return true;
                } else {
                    // ❌ NO cumple los requisitos → Le damos RECURSOS EQUIVALENTES
                    $p = $GLOBALS['pricelist'][$itemId] ?? null;
                    if (!$p) return false;

                    $m = (int)($p['metal'] ?? 0) * $amount;
                    $c = (int)($p['crystal'] ?? 0) * $amount;
                    $d = (int)($p['deuterium'] ?? 0) * $amount;

                    self::db()->update(
                        "UPDATE %%PLANETS%%
                         SET metal = metal + :m, crystal = crystal + :c, deuterium = deuterium + :d
                         WHERE id = :pid",
                        [':m' => $m, ':c' => $c, ':d' => $d, ':pid' => $planetId]
                    );
                    if ($planet && (int) $planet['id'] === $planetId) {
                        $GLOBALS['PLANET']['metal']     += $m;
                        $GLOBALS['PLANET']['crystal']   += $c;
                        $GLOBALS['PLANET']['deuterium'] += $d;
                    }
                    return true;
                }

            case 'faction_buff':
                return true;
        }
        return false;
    }

    /* ============================================================
     * VALIDACIÓN DE REQUISITOS (Copiada del BattlePass)
     * ============================================================ */
    private static function cumpleRequisitos($userId, $planetaId, $elementId)
    {
        $requisitos = self::db()->select(
            "SELECT requireID, requireLevel 
             FROM %%VARS_REQUIRE%% 
             WHERE elementID = :eid",
            [':eid' => (int)$elementId]
        );

        if (!$requisitos || !is_array($requisitos)) return true;

        foreach ($requisitos as $req) {
            $requireId = (int)$req['requireID'];
            $nivelReq  = (int)$req['requireLevel'];

            $columna = self::getIdToColumna($requireId);
            if (!$columna) continue;

            if (self::esColumnaDePlaneta($columna)) {
                $row = self::db()->selectSingle(
                    "SELECT ".$columna." AS nivel FROM %%PLANETS%% WHERE id = :pid",
                    [':pid' => $planetaId]
                );
                if ($row && (int)$row['nivel'] >= $nivelReq) continue;
                return false;
            }

            if (self::esColumnaDeUsuario($columna)) {
                $row = self::db()->selectSingle(
                    "SELECT ".$columna." AS nivel FROM %%USERS%% WHERE id = :uid",
                    [':uid' => $userId]
                );
                if ($row && (int)$row['nivel'] >= $nivelReq) continue;
                return false;
            }
        }
        return true;
    }

    private static function getIdToColumna($id)
    {
        $edificios = [
            1 => 'metal_mine', 2 => 'crystal_mine', 3 => 'deuterium_sintetizer',
            4 => 'solar_plant', 12 => 'fusion_plant', 14 => 'robot_factory',
            15 => 'nano_factory', 21 => 'hangar', 22 => 'metal_store',
            23 => 'crystal_store', 24 => 'deuterium_store', 31 => 'laboratory',
            33 => 'terraformer', 34 => 'ally_deposit', 41 => 'mondbasis',
            42 => 'phalanx', 43 => 'sprungtor', 44 => 'silo'
        ];
        $investigaciones = [
            106 => 'spy_tech', 108 => 'computer_tech', 109 => 'military_tech',
            110 => 'defence_tech', 111 => 'shield_tech', 113 => 'energy_tech',
            114 => 'hyperspace_tech', 115 => 'combustion_tech',
            117 => 'impulse_motor_tech', 118 => 'hyperspace_motor_tech',
            120 => 'laser_tech', 121 => 'ionic_tech', 122 => 'buster_tech',
            123 => 'intergalactic_tech', 124 => 'expedition_tech',
            131 => 'metal_proc_tech', 132 => 'crystal_proc_tech',
            133 => 'deuterium_proc_tech', 199 => 'graviton_tech'
        ];

        if (isset($edificios[$id])) return $edificios[$id];
        if (isset($investigaciones[$id])) return $investigaciones[$id];
        return null;
    }

    private static function esColumnaDePlaneta($columna)
    {
        $cols = [
            'metal_mine', 'crystal_mine', 'deuterium_sintetizer', 'solar_plant',
            'fusion_plant', 'robot_factory', 'nano_factory', 'hangar',
            'metal_store', 'crystal_store', 'deuterium_store', 'laboratory',
            'terraformer', 'ally_deposit', 'mondbasis', 'phalanx',
            'sprungtor', 'silo'
        ];
        return in_array($columna, $cols);
    }

    private static function esColumnaDeUsuario($columna)
    {
        $cols = [
            'spy_tech', 'computer_tech', 'military_tech', 'defence_tech',
            'shield_tech', 'energy_tech', 'hyperspace_tech', 'combustion_tech',
            'impulse_motor_tech', 'hyperspace_motor_tech', 'laser_tech',
            'ionic_tech', 'buster_tech', 'intergalactic_tech', 'expedition_tech',
            'metal_proc_tech', 'crystal_proc_tech', 'deuterium_proc_tech',
            'graviton_tech'
        ];
        return in_array($columna, $cols);
    }

    /* ============================================================
     * CRON
     * ============================================================ */
    public static function cron()
    {
        try {
            self::$rotationDone = false;
            self::rotatePersonalMissions();

            self::db()->query(
                "DELETE FROM %%FACTION_BONUSES%% WHERE expires_at < :now",
                [':now' => (int) TIMESTAMP]
            );

            $expired = self::db()->select(
                "SELECT * FROM %%FACTION_GLOBAL_MISSIONS%%
                 WHERE status = 'bonus_active' AND bonus_end < :now",
                [':now' => (int) TIMESTAMP]
            );
            foreach ($expired as $e) {
                self::db()->update(
                    "UPDATE %%FACTION_GLOBAL_MISSIONS%% SET status = 'completed' WHERE id = :id",
                    [':id' => (int) $e['id']]
                );
                self::createNextGlobalMission((int) $e['faction_id']);
            }

            self::$bonusCache = [];
        } catch (Exception $ex) {
            @file_put_contents(ROOT_PATH . 'cache/astroio_error.log',
                '[' . date('Y-m-d H:i:s') . '] FACTION MISSION CRON: ' . $ex->getMessage() . PHP_EOL,
                FILE_APPEND);
        }
    }

    private static function log($userId, $factionId, $missionId, $action, $amount = 0, $note = null)
    {
        try {
            self::db()->insert(
                "INSERT INTO %%FACTION_MISSIONS_LOG%%
                    (user_id, faction_id, mission_id, action, amount, note, created_at)
                 VALUES (:uid, :fid, :mid, :act, :amt, :note, :now)",
                [
                    ':uid'  => (int) $userId,
                    ':fid'  => (int) $factionId,
                    ':mid'  => (int) $missionId,
                    ':act'  => (string) $action,
                    ':amt'  => (int) $amount,
                    ':note' => $note,
                    ':now'  => (int) TIMESTAMP,
                ]
            );
        } catch (Exception $e) { /* silencioso */ }
    }
}