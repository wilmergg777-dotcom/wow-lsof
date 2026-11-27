<?php

/**
 * AstroIO — PVPArenaHelper
 * Lógica completa del sistema de Arenas PvP (1v1, 2v2, 3v3)
 *
 * Ubicación: includes/classes/PVPArenaHelper.class.php
 * @package AstroIO
 * @version 2.0 — Doble Riel (NTX-20 / UNTX-20)
 *
 * v1.4 — fixes: getUserArenas filtra status, finishArena suma pvp_points,
 *        claimPrize reparte entre ganadores reales, sin código muerto
 * v2.0 — Doble Riel:
 *        · A1: pools separados `pool_ntx20` + `pool_untx20` por arena
 *        · D1: el creador define precio BASE; QVAPAY paga ×2 UNTX-20
 *        · Entrada / reembolso / premio siempre en el riel del jugador
 *        · Reparto de premio por riel (sin acuñar)
 *        · Log NTX20LogHelper SOLO si CUP
 */

class PVPArenaHelper
{
    /* ============================================================ 
     *  CONSTANTES
     * ============================================================ */

    // Tiempos por defecto (si no hay config)
    const DEFAULT_DURATION    = 172800; // 48h
    const DEFAULT_EXTRA_TIME  = 18000;  // 5h
    const DEFAULT_EXPIRE      = 86400;  // 24h
    const DEFAULT_CLAIM_DAYS  = 4;

    // Premio: 100% del bote al ganador
    const PRIZE_COMMISSION    = 0;


    /* ============================================================ 
     *  HELPERS INTERNOS
     * ============================================================ */

    private static function db()
    {
        return Database::get();
    }

    private static function prefix()
    {
        return DB_PREFIX;
    }

    /**
     * Carga el helper de auditoría NTX-20 (si existe)
     */
    private static function loadNtxLogHelper()
    {
        if (class_exists('NTX20LogHelper')) return true;

        if (defined('ROOT_PATH')) {
            $file = ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php';
        } else {
            $file = dirname(__FILE__) . '/NTX20LogHelper.class.php';
        }

        if (file_exists($file)) {
            require_once $file;
        }
        return class_exists('NTX20LogHelper');
    }

    /**
     * Wrapper seguro para el log NTX-20 (no rompe si falla).
     * SOLO debe llamarse para jugadores CUP.
     */
    private static function logNtx20($userId, $amount, $type, $description = '', $refId = 0)
    {
        try {
            if (!self::loadNtxLogHelper()) return;
            NTX20LogHelper::log($userId, $amount, $type, $description, $refId);
        } catch (Exception $e) {
            // silencioso
        }
    }

    /**
     * Devuelve el monto REAL que pagó un jugador por una arena.
     * Como `entry_fee` se guarda en BASE NTX-20, el real depende del riel.
     */
    private static function getRealPaidByPlayer($baseFee, $userId)
    {
        return PVPHelper::getPrecioParaJugador((int) $baseFee, (int) $userId);
    }


    /* ============================================================ 
     *  CONFIGURACIÓN
     * ============================================================ */

    public static function getEntryFee($mode)
    {
        if ($mode === '1v1') {
            return null; // lo define el creador
        }
        if ($mode === '2v2') {
            return (int) PVPHelper::get('arena_2v2_price', 50);
        }
        if ($mode === '3v3') {
            return (int) PVPHelper::get('arena_3v3_price', 100);
        }
        return 0;
    }

    public static function getDuration()
    {
        return (int) PVPHelper::get('arena_duration_hours', 48) * 3600;
    }

    public static function getExtraTime()
    {
        return (int) PVPHelper::get('arena_extra_hours', 5) * 3600;
    }

    public static function getExpire()
    {
        return (int) PVPHelper::get('arena_expire_hours', 24) * 3600;
    }

    public static function getClaimDeadlineDays()
    {
        return (int) PVPHelper::get('arena_claim_days', 4);
    }

    public static function getMinFee1v1()
    {
        return (int) PVPHelper::get('arena_1v1_min', 10);
    }

    public static function getMaxFee1v1()
    {
        return (int) PVPHelper::get('arena_1v1_max', 10000);
    }


    /* ============================================================ 
     *  CREAR ARENA
     * ============================================================ */

    /**
     * Crea una nueva arena.
     *
     * El creador define `$entryFee` en BASE NTX-20 para 1v1.
     * Para 2v2/3v3 se lee el precio global (también base).
     * El creador paga en SU riel: base (CUP) o base×2 (QVAPAY).
     *
     * @param int    $userId
     * @param string $mode    '1v1' | '2v2' | '3v3'
     * @param int    $entryFee Solo para 1v1 (en base NTX-20)
     * @return array ['ok' => bool, 'msg' => string, 'arena_id' => int]
     */
    public static function createArena($userId, $mode, $entryFee = 0)
    {
        $userId = (int) $userId;

        if (!PVPHelper::isArenaEnabled()) {
            return array('ok' => false, 'msg' => 'El sistema de arenas está desactivado.');
        }

        if (!PVPHelper::isValidMode($mode)) {
            return array('ok' => false, 'msg' => 'Modalidad inválida.');
        }

        // Riel del creador (una sola llamada, se cachea en PVPHelper)
        $riel       = PVPHelper::getPlayerMethod($userId);
        $moneda     = PVPHelper::getCurrencyLabel($userId);
        $isIntl     = ($riel === 'QVAPAY');

        // Precio (BASE NTX-20)
        if ($mode === '1v1') {
            $entryFee = (int) $entryFee;
            $min = self::getMinFee1v1();
            $max = self::getMaxFee1v1();

            if ($entryFee < $min || $entryFee > $max) {
                $minReal = PVPHelper::getPrecioParaJugador($min, $userId);
                $maxReal = PVPHelper::getPrecioParaJugador($max, $userId);
                return array('ok' => false, 'msg' => 'La entrada debe estar entre ' . number_format($minReal) . ' y ' . number_format($maxReal) . ' ' . $moneda . '.');
            }
        } else {
            $entryFee = self::getEntryFee($mode);
            if ($entryFee <= 0) {
                return array('ok' => false, 'msg' => 'La modalidad ' . $mode . ' no tiene precio configurado.');
            }
        }

        // Verificar que el jugador no tenga ya 1 arena creada
        $existente = self::db()->selectSingle(
            "SELECT `id` FROM %%PVP_ARENAS%% 
             WHERE `creator_id` = :uid 
               AND `status` IN ('waiting','active','extra_time') 
             LIMIT 1;",
            array(':uid' => $userId)
        );

        if (!empty($existente)) {
            return array('ok' => false, 'msg' => 'Ya tienes una arena activa. Debes terminarla o cancelarla primero.');
        }

        // Verificar que el jugador no esté en otra arena
        $enOtra = self::db()->selectSingle(
            "SELECT ap.`id` 
             FROM %%PVP_ARENA_PLAYERS%% ap
             INNER JOIN %%PVP_ARENAS%% a ON a.`id` = ap.`arena_id`
             WHERE ap.`user_id` = :uid 
               AND a.`status` IN ('waiting','active','extra_time')
             LIMIT 1;",
            array(':uid' => $userId)
        );

        if (!empty($enOtra)) {
            return array('ok' => false, 'msg' => 'Ya estás inscrito en otra arena.');
        }

        // Monto REAL que pagará el creador en su riel
        $realPaid = self::getRealPaidByPlayer($entryFee, $userId);

        // Verificar saldo en su riel
        if (!PVPHelper::hasBalance($userId, $entryFee)) {
            return array('ok' => false, 'msg' => 'No tienes suficientes ' . $moneda . '. Necesitas ' . number_format($realPaid) . '.');
        }

        // Descontar del riel correcto (removeBalance ya registra log NTX20 solo si CUP)
        if (!PVPHelper::removeBalance($userId, $entryFee, 'pvp_arena_create', 'Entrada arena ' . $mode)) {
            return array('ok' => false, 'msg' => 'No se pudo descontar la entrada. Inténtalo de nuevo.');
        }

        $maxPlayers = PVPHelper::getModeMaxPlayers($mode);
        $now        = TIMESTAMP;

        // Pools separados: solo el riel del creador recibe este pago
        $poolNtx    = $isIntl ? 0 : $realPaid;
        $poolUntx   = $isIntl ? $realPaid : 0;

        // Insertar arena
        try {
            self::db()->insert(
                "INSERT INTO %%PVP_ARENAS%% SET
                    `creator_id`      = :creator,
                    `mode`            = :mode,
                    `entry_fee`       = :fee,
                    `prize_pool`      = :pool,
                    `pool_ntx20`      = :pool_ntx,
                    `pool_untx20`     = :pool_untx,
                    `status`          = 'waiting',
                    `current_players` = 1,
                    `max_players`     = :maxp,
                    `winner_team`     = 0,
                    `created_at`      = :now,
                    `starts_at`       = 0,
                    `ends_at`         = 0,
                    `extra_time_ends_at` = 0,
                    `claim_deadline`  = 0,
                    `finished_at`     = 0,
                    `universe`        = :universe;",
                array(
                    ':creator'   => $userId,
                    ':mode'      => $mode,
                    ':fee'       => $entryFee,
                    ':pool'      => $realPaid,
                    ':pool_ntx'  => $poolNtx,
                    ':pool_untx' => $poolUntx,
                    ':maxp'      => $maxPlayers,
                    ':now'       => $now,
                    ':universe'  => class_exists('Universe') ? Universe::current() : 1,
                )
            );
        } catch (Exception $e) {
            // Devolver al creador en su riel
            PVPHelper::addRealAmount($userId, $realPaid, $riel, 'pvp_arena_refund', 'Error al crear arena');
            if (!$isIntl) {
                self::logNtx20($userId, +$realPaid, 'earn_pvp_arena', 'Reembolso arena (error de creación)', 0);
            }
            return array('ok' => false, 'msg' => 'Error al crear la arena. Se te devolvió el ' . $moneda . '.');
        }

        $arenaId = self::db()->lastInsertId();

        // Inscribir al creador
        self::db()->insert(
            "INSERT INTO %%PVP_ARENA_PLAYERS%% SET
                `arena_id`  = :aid,
                `user_id`   = :uid,
                `team`      = 0,
                `is_leader` = 1,
                `paid`      = 1,
                `joined_at` = :now;",
            array(':aid' => $arenaId, ':uid' => $userId, ':now' => $now)
        );

        PVPHelper::log('arena', $arenaId, 'created', $userId, array(
            'mode'      => $mode,
            'fee_base'  => $entryFee,
            'real_paid' => $realPaid,
            'riel'      => $riel,
        ));

        // (removeBalance ya registró el log NTX20 si CUP)

        return array(
            'ok'       => true,
            'msg'      => 'Arena ' . $mode . ' creada. Entrada: ' . number_format($realPaid) . ' ' . $moneda . '.',
            'arena_id' => (int) $arenaId,
        );
    }


    /* ============================================================ 
     *  UNIRSE A ARENA
     * ============================================================ */

    /**
     * Inscribe a un jugador en una arena existente.
     * Cada jugador paga en SU riel: base (CUP) o base×2 (QVAPAY).
     */
    public static function joinArena($arenaId, $userId)
    {
        $arenaId = (int) $arenaId;
        $userId  = (int) $userId;

        $db = self::db();

        // Cargar arena
        $arena = self::getArena($arenaId);
        if (empty($arena)) {
            return array('ok' => false, 'msg' => 'Arena no encontrada.');
        }

        if ($arena['status'] !== 'waiting') {
            return array('ok' => false, 'msg' => 'Esta arena ya no acepta jugadores.');
        }

        if ($arena['current_players'] >= $arena['max_players']) {
            return array('ok' => false, 'msg' => 'La arena está llena.');
        }

        // Ya inscrito?
        $ya = $db->selectSingle(
            "SELECT `id` FROM %%PVP_ARENA_PLAYERS%% WHERE `arena_id` = :aid AND `user_id` = :uid LIMIT 1;",
            array(':aid' => $arenaId, ':uid' => $userId)
        );
        if (!empty($ya)) {
            return array('ok' => false, 'msg' => 'Ya estás inscrito en esta arena.');
        }

        // Ya en otra arena?
        $enOtra = $db->selectSingle(
            "SELECT ap.`id` 
             FROM %%PVP_ARENA_PLAYERS%% ap
             INNER JOIN %%PVP_ARENAS%% a ON a.`id` = ap.`arena_id`
             WHERE ap.`user_id` = :uid 
               AND a.`status` IN ('waiting','active','extra_time')
             LIMIT 1;",
            array(':uid' => $userId)
        );
        if (!empty($enOtra)) {
            return array('ok' => false, 'msg' => 'Ya estás en otra arena activa.');
        }

        // Riel del jugador
        $riel    = PVPHelper::getPlayerMethod($userId);
        $moneda  = PVPHelper::getCurrencyLabel($userId);
        $isIntl  = ($riel === 'QVAPAY');

        // ✅ v3.8 — GATE atómico de cupo ANTES de cobrar: el check previo era
        // lectura obsoleta — dos joins concurrentes superaban `max_players` y
        // ambos calculaban el mismo equipo (3 en un equipo de 2v2). El UPDATE
        // condicional reclama el cupo (rowCount) y falla si está lleno.
        $db->update(
            "UPDATE %%PVP_ARENAS%% SET `current_players` = `current_players` + 1
             WHERE `id` = :aid AND `status` = 'waiting' AND `current_players` < `max_players`;",
            array(':aid' => $arenaId)
        );
        if ($db->rowCount() !== 1) {
            return array('ok' => false, 'msg' => 'La arena está llena o ya no acepta jugadores.');
        }

        $releaseSlot = function () use ($db, $arenaId) {
            // ✅ v3.8 — Devolver el cupo reclamado si algo falla después
            try {
                $db->update(
                    "UPDATE %%PVP_ARENAS%% SET `current_players` = `current_players` - 1
                     WHERE `id` = :aid AND `current_players` > 0;",
                    array(':aid' => $arenaId)
                );
            } catch (Throwable $e) {}
        };

        // Fee en BASE NTX-20 (guardado en la arena)
        $feeBase  = (int) $arena['entry_fee'];
        $realPaid = self::getRealPaidByPlayer($feeBase, $userId);

        // Verificar saldo en su riel
        if (!PVPHelper::hasBalance($userId, $feeBase)) {
            $releaseSlot();
            return array('ok' => false, 'msg' => 'No tienes suficientes ' . $moneda . '. Necesitas ' . number_format($realPaid) . '.');
        }

        // Descontar del riel correcto (removeBalance loguea NTX20 solo si CUP)
        if (!PVPHelper::removeBalance($userId, $feeBase, 'pvp_arena_join', 'Entrada arena #' . $arenaId)) {
            $releaseSlot();
            return array('ok' => false, 'msg' => 'No se pudo descontar la entrada.');
        }

        $now      = TIMESTAMP;
        $teamSize = PVPHelper::getModeTeamSize($arena['mode']);

        // ✅ v3.8 — Equipo calculado por COUNT real (no por el contador
        // obsoleto): primeros teamSize jugadores → equipo 0, resto → 1.
        $playersSoFar = (int) $db->selectSingle(
            "SELECT COUNT(*) AS c FROM %%PVP_ARENA_PLAYERS%% WHERE `arena_id` = :aid;",
            array(':aid' => $arenaId),
            'c'
        );
        $team = ($playersSoFar < $teamSize) ? 0 : 1;

        // Insertar
        try {
            $db->insert(
                "INSERT INTO %%PVP_ARENA_PLAYERS%% SET
                    `arena_id`  = :aid,
                    `user_id`   = :uid,
                    `team`      = :team,
                    `is_leader` = 0,
                    `paid`      = 1,
                    `joined_at` = :now;",
                array(
                    ':aid'  => $arenaId,
                    ':uid'  => $userId,
                    ':team' => $team,
                    ':now'  => $now,
                )
            );

            // Actualizar pools separados (el cupo YA se reclamó en el gate)
            if ($isIntl) {
                $db->update(
                    "UPDATE %%PVP_ARENAS%%
                     SET `pool_untx20`     = `pool_untx20` + :real,
                         `prize_pool`      = `prize_pool` + :real2
                     WHERE `id` = :aid;",
                    array(':real' => $realPaid, ':real2' => $realPaid, ':aid' => $arenaId)
                );
            } else {
                $db->update(
                    "UPDATE %%PVP_ARENAS%%
                     SET `pool_ntx20`      = `pool_ntx20` + :real,
                         `prize_pool`      = `prize_pool` + :real2
                     WHERE `id` = :aid;",
                    array(':real' => $realPaid, ':real2' => $realPaid, ':aid' => $arenaId)
                );
            }

            PVPHelper::log('arena', $arenaId, 'joined', $userId, array(
                'team'      => $team,
                'fee_base'  => $feeBase,
                'real_paid' => $realPaid,
                'riel'      => $riel,
            ));

            // ¿Se llenó? → arrancar
            $updated = self::getArena($arenaId);
            if ((int) $updated['current_players'] >= (int) $updated['max_players']) {
                self::startArena($arenaId);
            }

            return array('ok' => true, 'msg' => 'Te uniste a la arena #' . $arenaId . '.');
        } catch (Exception $e) {
            // ✅ v3.8 — Devolver en su riel + devolver el cupo reclamado
            $releaseSlot();
            PVPHelper::addRealAmount($userId, $realPaid, $riel, 'pvp_arena_refund', 'Error al unirse');
            if (!$isIntl) {
                self::logNtx20($userId, +$realPaid, 'earn_pvp_arena', 'Reembolso arena #' . $arenaId . ' (error al unirse)', (int) $arenaId);
            }
            return array('ok' => false, 'msg' => 'Error al unirse. Se te devolvió el ' . $moneda . '.');
        }
    }


    /* ============================================================ 
     *  CANCELAR ARENA (solo antes de arrancar)
     * ============================================================ */

    /**
     * Cancela una arena. Solo el creador puede hacerlo antes de arrancar.
     * Devuelve a cada jugador lo que pagó, EN SU RIEL.
     */
    public static function cancelArena($arenaId, $userId)
    {
        $arenaId = (int) $arenaId;
        $userId  = (int) $userId;

        $db = self::db();

        $arena = self::getArena($arenaId);
        if (empty($arena)) {
            return array('ok' => false, 'msg' => 'Arena no encontrada.');
        }

        if ((int) $arena['creator_id'] !== $userId) {
            return array('ok' => false, 'msg' => 'Solo el creador puede cancelar la arena.');
        }

        if ($arena['status'] !== 'waiting') {
            return array('ok' => false, 'msg' => 'Solo puedes cancelar antes de que arranque.');
        }

        // ✅ v3.8 — Lock atómico ANTES de reembolsar: solo el primer proceso
        // cancela (rowCount). Antes un doble click (o cron + usuario) pasaban
        // ambos el check de estado y reembolsaban DOS veces.
        $db->update(
            "UPDATE %%PVP_ARENAS%% SET `status` = 'cancelled', `finished_at` = :now
             WHERE `id` = :aid AND `status` = 'waiting';",
            array(':now' => TIMESTAMP, ':aid' => $arenaId)
        );
        if ($db->rowCount() !== 1) {
            return array('ok' => false, 'msg' => 'La arena ya no puede cancelarse.');
        }

        // Devolver a cada jugador en su riel
        $players  = self::getArenaPlayers($arenaId);
        $feeBase  = (int) $arena['entry_fee'];
        $refunded = 0;

        foreach ($players as $p) {
            $puid = (int) $p['user_id'];
            if ((int) $p['paid'] === 1 && $feeBase > 0) {
                $rielP     = PVPHelper::getPlayerMethod($puid);
                $realPaid  = self::getRealPaidByPlayer($feeBase, $puid);

                // ✅ v3.8 — Contar solo reembolsos reales (si addRealAmount
                // falla, el jugador no cobró pero antes contaba igual)
                if (PVPHelper::addRealAmount($puid, $realPaid, $rielP, 'pvp_arena_refund', 'Arena #' . $arenaId . ' cancelada')) {
                    $refunded++;
                    if ($rielP === 'CUP') {
                        self::logNtx20($puid, +$realPaid, 'earn_pvp_arena', 'Reembolso arena #' . $arenaId . ' cancelada', (int) $arenaId);
                    }
                }
            }
        }

        PVPHelper::log('arena', $arenaId, 'cancelled', $userId, array(
            'refunded_players' => $refunded,
            'fee_base'         => $feeBase,
        ));

        return array('ok' => true, 'msg' => 'Arena cancelada. Se devolvió la entrada a ' . $refunded . ' jugador(es).');
    }


    /* ============================================================ 
     *  ARRANCAR ARENA
     * ============================================================ */

    /**
     * Arranca una arena. Se llama automáticamente cuando se llena.
     */
    public static function startArena($arenaId)
    {
        $arenaId = (int) $arenaId;

        $arena = self::getArena($arenaId);
        if (empty($arena)) {
            return false;
        }

        if ($arena['status'] !== 'waiting') {
            return false;
        }

        if ((int) $arena['current_players'] < (int) $arena['max_players']) {
            return false;
        }

        $now      = TIMESTAMP;
        $duration = self::getDuration();
        $endsAt   = $now + $duration;

        self::db()->update(
            "UPDATE %%PVP_ARENAS%% 
             SET `status`    = 'active',
                 `starts_at` = :now,
                 `ends_at`   = :ends
             WHERE `id` = :aid;",
            array(':now' => $now, ':ends' => $endsAt, ':aid' => $arenaId)
        );

        PVPHelper::log('arena', $arenaId, 'started', 0, array(
            'ends_at' => $endsAt,
        ));

        // Notificar a todos los inscritos (pool del riel de cada uno)
        $players = self::getArenaPlayers($arenaId);
        foreach ($players as $p) {
            $puid    = (int) $p['user_id'];
            $rielP   = PVPHelper::getPlayerMethod($puid);
            $monedaP = PVPHelper::getCurrencyLabel($puid);
            $poolP   = ($rielP === 'QVAPAY')
                ? (int) $arena['pool_untx20']
                : (int) $arena['pool_ntx20'];

            PVPHelper::sendNotification(
                $puid,
                '¡Tu arena ha comenzado!',
                'La arena #' . $arenaId . ' (' . $arena['mode'] . ') ha comenzado.<br>'
                . 'Duración: ' . round($duration / 3600) . ' horas.<br>'
                . 'Bote de tu riel: ' . number_format($poolP) . ' ' . $monedaP . '.<br>'
                . '<a href="game.php?page=pvp&mode=arenas">Ir a la arena</a>'
            );
        }

        return true;
    }


    /* ============================================================ 
     *  EXPIRAR ARENAS (cron)
     * ============================================================ */

    /**
     * Expira arenas sin llenarse. Devuelve a cada jugador en su riel.
     *
     * @return int  Número de arenas expiradas
     */
    public static function expireArenas()
    {
        $db     = self::db();
        $now    = TIMESTAMP;
        $expire = self::getExpire();

        // Arenas waiting creadas hace más de expire
        $sql = "SELECT `id`, `entry_fee`, `created_at` 
                FROM %%PVP_ARENAS%% 
                WHERE `status` = 'waiting' 
                  AND `created_at` + :expire <= :now;";
        $rows = $db->select($sql, array(':expire' => $expire, ':now' => $now));

        if (empty($rows)) {
            return 0;
        }

        $count = 0;
        foreach ($rows as $row) {
            $arenaId = (int) $row['id'];
            $feeBase = (int) $row['entry_fee'];

            // ✅ v3.8 — Claim atómico ANTES de reembolsar: solo el primer
            // proceso expira esta arena (rowCount). Antes dos runs del cron
            // solapados leían las mismas arenas 'waiting' y reembolsaban DOS
            // veces a todos sus jugadores.
            $db->update(
                "UPDATE %%PVP_ARENAS%% SET `status` = 'cancelled', `finished_at` = :now
                 WHERE `id` = :aid AND `status` = 'waiting';",
                array(':now' => $now, ':aid' => $arenaId)
            );
            if ($db->rowCount() !== 1) {
                continue; // otro proceso se la llevó
            }

            // Devolver a cada uno en su riel
            $players = self::getArenaPlayers($arenaId);
            foreach ($players as $p) {
                $puid = (int) $p['user_id'];
                if ((int) $p['paid'] === 1 && $feeBase > 0) {
                    $rielP    = PVPHelper::getPlayerMethod($puid);
                    $monedaP  = PVPHelper::getCurrencyLabel($puid);
                    $realPaid = self::getRealPaidByPlayer($feeBase, $puid);

                    PVPHelper::addRealAmount($puid, $realPaid, $rielP, 'pvp_arena_refund', 'Arena #' . $arenaId . ' expirada');

                    if ($rielP === 'CUP') {
                        self::logNtx20($puid, +$realPaid, 'earn_pvp_arena', 'Reembolso arena #' . $arenaId . ' expirada', (int) $arenaId);
                    }

                    // Notificar
                    PVPHelper::sendNotification(
                        $puid,
                        'Arena expirada',
                        'La arena #' . $arenaId . ' no se llenó a tiempo. Se te devolvieron ' . number_format($realPaid) . ' ' . $monedaP . '.'
                    );
                } else {
                    PVPHelper::sendNotification(
                        $puid,
                        'Arena expirada',
                        'La arena #' . $arenaId . ' no se llenó a tiempo.'
                    );
                }
            }

            $db->update(
                "UPDATE %%PVP_ARENAS%% SET `status` = 'cancelled', `finished_at` = :now WHERE `id` = :aid;",
                array(':now' => $now, ':aid' => $arenaId)
            );

            PVPHelper::log('arena', $arenaId, 'expired', 0, array(
                'refunded_players' => count($players),
                'fee_base'         => $feeBase,
            ));

            $count++;
        }

        return $count;
    }

    /* ============================================================
     *  RESOLVER ARENAS ACTIVAS (cron)
     * ============================================================ */

    /**
     * Resuelve arenas activas cuyo tiempo terminó.
     *
     * - Si ambos equipos tienen daño distinto → gana el mayor
     * - Si están exactamente empatados → +5h extra (una sola vez)
     * - Si el tiempo extra terminó → gana el primero en inscribirse (desempate técnico)
     *
     * @return int  Número de arenas resueltas
     */
    public static function resolveActiveArenas()
    {
        $db  = self::db();
        $now = TIMESTAMP;

        // Activas cuyo ends_at ya pasó
        $sql = "SELECT `id`, `mode`, `ends_at`, `extra_time_ends_at`, `status`
                FROM %%PVP_ARENAS%% 
                WHERE `status` IN ('active','extra_time') 
                  AND `ends_at` <= :now;";
        $rows = $db->select($sql, array(':now' => $now));

        if (empty($rows)) {
            return 0;
        }

        $count = 0;
        foreach ($rows as $row) {
            $arenaId = (int) $row['id'];

            // Si está en extra_time y ya pasó el extra_time_ends_at → forzar fin
            if ($row['status'] === 'extra_time' && (int) $row['extra_time_ends_at'] <= $now) {
                self::finishArenaByTiebreaker($arenaId);
                $count++;
                continue;
            }

            // Si está en active y ya pasó ends_at → calcular ganador o prórroga
            if ($row['status'] === 'active') {
                $result = self::determineWinner($arenaId);
                if ($result === 'tie') {
                    // Prórroga
                    $extraEnd = (int) $row['ends_at'] + self::getExtraTime();
                    $db->update(
                        "UPDATE %%PVP_ARENAS%% 
                         SET `status` = 'extra_time', `extra_time_ends_at` = :extra
                         WHERE `id` = :aid;",
                        array(':extra' => $extraEnd, ':aid' => $arenaId)
                    );

                    PVPHelper::log('arena', $arenaId, 'extra_time_started', 0, array(
                        'extra_ends_at' => $extraEnd,
                    ));

                    // Notificar
                    $players = self::getArenaPlayers($arenaId);
                    foreach ($players as $p) {
                        PVPHelper::sendNotification(
                            (int) $p['user_id'],
                            'Empate en tu arena',
                            'La arena #' . $arenaId . ' está exactamente empatada. '
                            . 'Se añaden ' . round(self::getExtraTime() / 3600) . ' horas extra.'
                        );
                    }
                } else {
                    // Hay ganador
                    self::finishArena($arenaId, (int) $result);
                    $count++;
                }
            }
        }

        return $count;
    }


    /**
     * Determina el equipo ganador por daño total.
     *
     * @return int|string  ID del equipo (0|1) o 'tie' si están exactamente empatados
     */
    public static function determineWinner($arenaId)
    {
        $arenaId = (int) $arenaId;
        $db      = self::db();

        // Obtener daño por atacante
        $sql = "SELECT `attacker_id`, SUM(`damage_done`) AS total_damage
                FROM %%PVP_ARENA_ATTACKS%% 
                WHERE `arena_id` = :aid 
                GROUP BY `attacker_id`;";
        $rows = $db->select($sql, array(':aid' => $arenaId));

        // Mapear atacante → equipo
        $players = self::getArenaPlayers($arenaId);
        $userTeam = array();
        foreach ($players as $p) {
            $userTeam[(int) $p['user_id']] = (int) $p['team'];
        }

        $teamDamage = array(0 => 0, 1 => 0);
        if (!empty($rows)) {
            foreach ($rows as $r) {
                $uid = (int) $r['attacker_id'];
                if (isset($userTeam[$uid])) {
                    $teamDamage[$userTeam[$uid]] += (int) $r['total_damage'];
                }
            }
        }

        if ($teamDamage[0] === $teamDamage[1]) {
            return 'tie';
        }

        return $teamDamage[0] > $teamDamage[1] ? 0 : 1;
    }


    /**
     * Desempate técnico: gana el equipo del jugador que se inscribió primero.
     */
    public static function finishArenaByTiebreaker($arenaId)
    {
        $arenaId = (int) $arenaId;

        $first = self::db()->selectSingle(
            "SELECT `team` FROM %%PVP_ARENA_PLAYERS%% 
             WHERE `arena_id` = :aid 
             ORDER BY `joined_at` ASC, `id` ASC 
             LIMIT 1;",
            array(':aid' => $arenaId)
        );

        $winnerTeam = !empty($first) ? (int) $first['team'] : 0;
        self::finishArena($arenaId, $winnerTeam);
    }


    /**
     * Finaliza una arena y prepara el premio.
     * Suma +1 pvp_points a TODOS los ganadores (independientemente de si reclaman).
     */
    public static function finishArena($arenaId, $winnerTeam)
    {
        $arenaId    = (int) $arenaId;
        $winnerTeam = (int) $winnerTeam;

        $arena = self::getArena($arenaId);
        if (empty($arena)) {
            return false;
        }

        if (in_array($arena['status'], array('finished', 'cancelled'), true)) {
            return false;
        }

        $now      = TIMESTAMP;
        $days     = self::getClaimDeadlineDays();
        $deadline = $now + ($days * 86400);

        // ✅ v3.8 — UPDATE condicional + rowCount: solo el primer proceso
        // finaliza la arena. Antes dos runs concurrentes aplicaban +1
        // pvp_points a los ganadores y enviaban notificaciones DOS veces.
        self::db()->update(
            "UPDATE %%PVP_ARENAS%%
             SET `status`         = 'finished',
                 `winner_team`    = :wt,
                 `finished_at`    = :now,
                 `claim_deadline` = :deadline
             WHERE `id` = :aid AND `status` NOT IN ('finished','cancelled');",
            array(':wt' => $winnerTeam, ':now' => $now, ':deadline' => $deadline, ':aid' => $arenaId)
        );

        if (self::db()->rowCount() !== 1) {
            return false;
        }

        PVPHelper::log('arena', $arenaId, 'finished', 0, array(
            'winner_team' => $winnerTeam,
            'pool_ntx20'  => (int) $arena['pool_ntx20'],
            'pool_untx20' => (int) $arena['pool_untx20'],
        ));

        // ─── Ranking: +1 punto a TODOS los ganadores (una sola vez) ───
        $winnerPlayers = self::db()->select(
            "SELECT `user_id` FROM %%PVP_ARENA_PLAYERS%%
             WHERE `arena_id` = :aid AND `team` = :team;",
            array(':aid' => $arenaId, ':team' => $winnerTeam)
        );

        foreach ($winnerPlayers as $wp) {
            $uid = (int) $wp['user_id'];
            self::addRankingPoint($uid, 1);
            PVPHelper::log('arena', $arenaId, 'points_awarded', $uid, array(
                'amount' => 1,
            ));
        }

        // Notificar a todos
        $players = self::getArenaPlayers($arenaId);
        foreach ($players as $p) {
            $puid     = (int) $p['user_id'];
            $isWinner = ((int) $p['team'] === $winnerTeam);
            $msg      = $isWinner
                ? '¡Has GANADO la arena #' . $arenaId . '! Reclama tu premio antes de ' . $days . ' días.'
                : 'Has perdido la arena #' . $arenaId . '. Mejor suerte la próxima.';

            PVPHelper::sendNotification(
                $puid,
                $isWinner ? '¡Victoria en arena!' : 'Derrota en arena',
                $msg . '<br><a href="game.php?page=pvp&mode=arenas">Ver arena</a>'
            );
        }

        return true;
    }


    /* ============================================================ 
     *  RECLAMAR PREMIO
     * ============================================================ */

    /**
     * Reclama el premio de una arena ganada.
     *
     * v2.0 (A1): con pools separados, el jugador cobra del pool de SU riel,
     *            dividido entre los ganadores de SU riel. No se acuña.
     */
    public static function claimPrize($arenaId, $userId)
    {
        $arenaId = (int) $arenaId;
        $userId  = (int) $userId;

        $arena = self::getArena($arenaId);
        if (empty($arena)) {
            return array('ok' => false, 'msg' => 'Arena no encontrada.');
        }

        if ($arena['status'] !== 'finished') {
            return array('ok' => false, 'msg' => 'Esta arena aún no ha terminado.');
        }

        if ((int) $arena['claim_deadline'] > 0 && (int) $arena['claim_deadline'] < TIMESTAMP) {
            return array('ok' => false, 'msg' => 'El plazo para reclamar el premio ha expirado.');
        }

        // Verificar que el jugador sea del equipo ganador
        $player = self::db()->selectSingle(
            "SELECT * FROM %%PVP_ARENA_PLAYERS%% 
             WHERE `arena_id` = :aid AND `user_id` = :uid 
             LIMIT 1;",
            array(':aid' => $arenaId, ':uid' => $userId)
        );

        if (empty($player)) {
            return array('ok' => false, 'msg' => 'No participaste en esta arena.');
        }

        if ((int) $player['team'] !== (int) $arena['winner_team']) {
            return array('ok' => false, 'msg' => 'No perteneces al equipo ganador.');
        }

        // Verificar si ya lo reclamó (paid=2 flag)
        if ((int) $player['paid'] === 2) {
            return array('ok' => false, 'msg' => 'Ya has reclamado tu premio.');
        }

        // ─── Reparto equitativo POR RIEL ───
        $winnerTeam = (int) $arena['winner_team'];
        $poolNtx    = (int) $arena['pool_ntx20'];
        $poolUntx   = (int) $arena['pool_untx20'];

        // Contar ganadores CUP y QVAPAY del equipo ganador
        $winnersInTeam = self::db()->select(
            "SELECT `user_id` FROM %%PVP_ARENA_PLAYERS%%
             WHERE `arena_id` = :aid AND `team` = :team;",
            array(':aid' => $arenaId, ':team' => $winnerTeam)
        );

        $countCup    = 0;
        $countQvapay = 0;
        foreach ($winnersInTeam as $w) {
            $wuid = (int) $w['user_id'];
            if (PVPHelper::getPlayerMethod($wuid) === 'QVAPAY') {
                $countQvapay++;
            } else {
                $countCup++;
            }
        }

        $riel       = PVPHelper::getPlayerMethod($userId);
        $moneda     = PVPHelper::getCurrencyLabel($userId);

        if ($riel === 'QVAPAY') {
            if ($countQvapay <= 0 || $poolUntx <= 0) {
                return array('ok' => false, 'msg' => 'El bote de tu riel está vacío.');
            }
            $individual = (int) floor($poolUntx / $countQvapay);
        } else {
            if ($countCup <= 0 || $poolNtx <= 0) {
                return array('ok' => false, 'msg' => 'El bote de tu riel está vacío.');
            }
            $individual = (int) floor($poolNtx / $countCup);
        }

        if ($individual <= 0) {
            return array('ok' => false, 'msg' => 'El bote está vacío.');
        }

        // ✅ v3.8 — CLAIM del flag ANTES de pagar (UPDATE condicional +
        // rowCount): antes era check-then-act — dos requests concurrentes
        // leían paid=1, ambos pasaban y cobraban el premio DOS veces. Si el
        // pago falla después, se revierte el flag para poder reintentar.
        self::db()->update(
            "UPDATE %%PVP_ARENA_PLAYERS%% SET `paid` = 2
             WHERE `arena_id` = :aid AND `user_id` = :uid AND `paid` <> 2;",
            array(':aid' => $arenaId, ':uid' => $userId)
        );

        if (self::db()->rowCount() !== 1) {
            return array('ok' => false, 'msg' => 'Ya has reclamado tu premio.');
        }

        // Entregar en el riel correcto
        if (!PVPHelper::addRealAmount($userId, $individual, $riel, 'pvp_arena_prize', 'Premio arena #' . $arenaId)) {
            // Revertir el claim para permitir reintento
            self::db()->update(
                "UPDATE %%PVP_ARENA_PLAYERS%% SET `paid` = 1
                 WHERE `arena_id` = :aid AND `user_id` = :uid AND `paid` = 2;",
                array(':aid' => $arenaId, ':uid' => $userId)
            );
            return array('ok' => false, 'msg' => 'Error al entregar el premio.');
        }

        PVPHelper::log('arena', $arenaId, 'prize_claimed', $userId, array(
            'amount' => $individual,
            'riel'   => $riel,
        ));

        // Log NTX20 SOLO si CUP
        if ($riel === 'CUP') {
            self::logNtx20($userId, +$individual, 'earn_pvp_arena', 'Premio arena #' . $arenaId . ' ganada', (int) $arenaId);
        }

        return array('ok' => true, 'msg' => '¡Has reclamado ' . number_format($individual) . ' ' . $moneda . '!');
    }


    /* ============================================================ 
     *  RANKING
     * ============================================================ */

    /**
     * Suma puntos de ranking al jugador.
     */
    public static function addRankingPoint($userId, $points = 1)
    {
        try {
            $db    = self::db();
            $p     = self::prefix();
            $check = $db->selectSingle(
                "SELECT COUNT(*) AS c FROM information_schema.COLUMNS 
                 WHERE TABLE_SCHEMA = DATABASE() 
                   AND TABLE_NAME = '" . $p . "users' 
                   AND COLUMN_NAME = 'pvp_points';"
            );

            if (!empty($check) && (int) $check['c'] > 0) {
                $db->update(
                    "UPDATE `" . $p . "users` SET `pvp_points` = `pvp_points` + :pts WHERE `id` = :uid;",
                    array(':pts' => (int) $points, ':uid' => (int) $userId)
                );
            }
        } catch (Exception $e) {
            // Silencioso
        }
    }


    /* ============================================================ 
     *  CONSULTAS
     * ============================================================ */

    public static function getArena($arenaId)
    {
        $arenaId = (int) $arenaId;
        if ($arenaId <= 0) {
            return null;
        }
        return self::db()->selectSingle(
            "SELECT * FROM %%PVP_ARENAS%% WHERE `id` = :aid LIMIT 1;",
            array(':aid' => $arenaId)
        );
    }

    public static function getArenaPlayers($arenaId)
    {
        $arenaId = (int) $arenaId;
        if ($arenaId <= 0) {
            return array();
        }
        return self::db()->select(
            "SELECT * FROM %%PVP_ARENA_PLAYERS%% WHERE `arena_id` = :aid ORDER BY `id` ASC;",
            array(':aid' => $arenaId)
        );
    }

    /**
     * Devuelve todos los jugadores inscritos con datos de su planeta.
     * Incluye AMBOS saldos (ntx20 + untx20) para que el controlador
     * muestre el del riel correcto.
     */
    public static function getArenaPlayersWithPlanets($arenaId)
    {
        $arenaId = (int) $arenaId;
        if ($arenaId <= 0) {
            return array();
        }

        return self::db()->select(
            "SELECT 
                ap.`user_id`,
                ap.`team`,
                ap.`is_leader`,
                ap.`paid`,
                ap.`joined_at`,
                u.`username`,
                u.`ntx20`,
                u.`untx20`,
                u.`metodo_retiro`,
                u.`pvp_points`,
                u.`id_planet` AS `main_planet_id`,
                p.`name`       AS `planet_name`,
                p.`galaxy`,
                p.`system`,
                p.`planet`,
                p.`planet_type`
             FROM %%PVP_ARENA_PLAYERS%% ap
             INNER JOIN %%USERS%% u ON u.`id` = ap.`user_id`
             LEFT JOIN %%PLANETS%% p ON p.`id` = u.`id_planet`
             WHERE ap.`arena_id` = :aid
             ORDER BY ap.`team` ASC, ap.`joined_at` ASC;",
            array(':aid' => $arenaId)
        );
    }

    /**
     * Devuelve el planeta principal de un jugador con sus coordenadas.
     */
    public static function getPlayerMainPlanet($userId)
    {
        $userId = (int) $userId;
        if ($userId <= 0) {
            return null;
        }

        $row = self::db()->selectSingle(
            "SELECT p.`id`, p.`name`, p.`galaxy`, p.`system`, p.`planet`, p.`planet_type`
             FROM %%USERS%% u
             INNER JOIN %%PLANETS%% p ON p.`id` = u.`id_planet`
             WHERE u.`id` = :uid
             LIMIT 1;",
            array(':uid' => $userId)
        );

        return empty($row) ? null : $row;
    }

    public static function getAvailableArenas($limit = 20)
    {
        $limit = max(1, min(100, (int) $limit));
        return self::db()->select(
            "SELECT a.*, u.`username` AS creator_name
             FROM %%PVP_ARENAS%% a
             LEFT JOIN %%USERS%% u ON u.`id` = a.`creator_id`
             WHERE a.`status` = 'waiting'
             ORDER BY a.`created_at` DESC
             LIMIT " . $limit . ";"
        );
    }

    /**
     * Devuelve las arenas relevantes para un jugador.
     */
    public static function getUserArenas($userId)
    {
        $userId = (int) $userId;
        $now    = TIMESTAMP;

        return self::db()->select(
            "SELECT a.*, 
                    (SELECT COUNT(*) FROM %%PVP_ARENA_PLAYERS%% ap 
                        WHERE ap.`arena_id` = a.`id`) AS player_count,
                    ap2.`team`      AS my_team,
                    ap2.`paid`      AS my_paid,
                    ap2.`is_leader` AS my_is_leader
             FROM %%PVP_ARENAS%% a
             LEFT JOIN %%PVP_ARENA_PLAYERS%% ap2
                    ON ap2.`arena_id` = a.`id` AND ap2.`user_id` = :uid
             WHERE (a.`creator_id` = :uid2 OR ap2.`id` IS NOT NULL)
               AND (
                    a.`status` IN ('waiting','active','extra_time')
                    OR (
                        a.`status` = 'finished'
                        AND a.`winner_team` = ap2.`team`
                        AND ap2.`paid` != 2
                        AND a.`claim_deadline` > :now
                    )
               )
             ORDER BY a.`created_at` DESC
             LIMIT 20;",
            array(':uid' => $userId, ':uid2' => $userId, ':now' => $now)
        );
    }

    public static function getHistory($limit = 5)
    {
        $limit = max(1, min(50, (int) $limit));
        return self::db()->select(
            "SELECT a.*, u.`username` AS creator_name
             FROM %%PVP_ARENAS%% a
             LEFT JOIN %%USERS%% u ON u.`id` = a.`creator_id`
             WHERE a.`status` IN ('finished','cancelled')
             ORDER BY a.`finished_at` DESC
             LIMIT " . $limit . ";"
        );
    }

    public static function countUserActiveArenas($userId)
    {
        $userId = (int) $userId;
        $row = self::db()->selectSingle(
            "SELECT COUNT(*) AS c 
             FROM %%PVP_ARENAS%% 
             WHERE `creator_id` = :uid 
               AND `status` IN ('waiting','active','extra_time');",
            array(':uid' => $userId)
        );
        return empty($row) ? 0 : (int) $row['c'];
    }

    public static function countUserActiveParticipations($userId)
    {
        $userId = (int) $userId;
        $row = self::db()->selectSingle(
            "SELECT COUNT(*) AS c 
             FROM %%PVP_ARENA_PLAYERS%% ap
             INNER JOIN %%PVP_ARENAS%% a ON a.`id` = ap.`arena_id`
             WHERE ap.`user_id` = :uid 
               AND a.`status` IN ('waiting','active','extra_time');",
            array(':uid' => $userId)
        );
        return empty($row) ? 0 : (int) $row['c'];
    }


    /* ============================================================ 
     *  REGISTRAR ATAQUE (llamado desde el combate)
     * ============================================================ */

    /**
     * Registra un ataque dentro de una arena (daño causado).
     */
    public static function registerAttack($arenaId, $attackerId, $defenderId, $fleetId, $shipsDestroyed, $defensesDestroyed, $damageDone)
    {
        $arenaId = (int) $arenaId;
        if ($arenaId <= 0) {
            return false;
        }

        try {
            self::db()->insert(
                "INSERT INTO %%PVP_ARENA_ATTACKS%% SET
                    `arena_id`           = :aid,
                    `attacker_id`        = :att,
                    `defender_id`        = :def,
                    `fleet_id`           = :fid,
                    `ships_destroyed`    = :sd,
                    `defenses_destroyed` = :dd,
                    `damage_done`        = :dmg,
                    `created_at`         = :now;",
                array(
                    ':aid' => $arenaId,
                    ':att' => (int) $attackerId,
                    ':def' => (int) $defenderId,
                    ':fid' => (int) $fleetId,
                    ':sd'  => (int) $shipsDestroyed,
                    ':dd'  => (int) $defensesDestroyed,
                    ':dmg' => (int) $damageDone,
                    ':now' => TIMESTAMP,
                )
            );
            return true;
        } catch (Exception $e) {
            PVPHelper::log('arena', $arenaId, 'register_attack_error', $attackerId, array(
                'error' => $e->getMessage(),
            ));
            return false;
        }
    }


    /**
     * Devuelve el ID de la arena activa en la que está el jugador (si la hay).
     */
    public static function getActiveArenaForUser($userId)
    {
        $userId = (int) $userId;
        $row = self::db()->selectSingle(
            "SELECT a.`id`
             FROM %%PVP_ARENAS%% a
             INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
             WHERE ap.`user_id` = :uid 
               AND a.`status` IN ('active','extra_time')
             LIMIT 1;",
            array(':uid' => $userId)
        );
        return empty($row) ? 0 : (int) $row['id'];
    }


    /**
     * Comprueba si ambos jugadores están en la misma arena activa.
     *
     * @return int  ID de la arena o 0
     */
    public static function areInSameArena($userId1, $userId2)
    {
        $userId1 = (int) $userId1;
        $userId2 = (int) $userId2;

        if ($userId1 <= 0 || $userId2 <= 0) {
            return 0;
        }

        $row = self::db()->selectSingle(
            "SELECT a.`id`
             FROM %%PVP_ARENAS%% a
             INNER JOIN %%PVP_ARENA_PLAYERS%% ap1 ON ap1.`arena_id` = a.`id`
             INNER JOIN %%PVP_ARENA_PLAYERS%% ap2 ON ap2.`arena_id` = a.`id`
             WHERE ap1.`user_id` = :u1 
               AND ap2.`user_id` = :u2
               AND a.`status` IN ('active','extra_time')
             LIMIT 1;",
            array(':u1' => $userId1, ':u2' => $userId2)
        );

        return empty($row) ? 0 : (int) $row['id'];
    }
}