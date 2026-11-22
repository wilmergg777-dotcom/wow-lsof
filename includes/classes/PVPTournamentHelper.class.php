<?php

/**
 * AstroIO — PVPTournamentHelper
 * Lógica completa del sistema de Torneos PvP (1v1 + Alianza)
 *
 * Ubicación: includes/classes/PVPTournamentHelper.class.php
 * @package AstroIO
 * @version 2.0 — Doble Riel (NTX-20 / UNTX-20)
 *
 * v1.1 — Hooks NTX20LogHelper, fixes menores
 * v2.0 — Doble Riel:
 *        · A1: pools separados `pool_ntx20` + `pool_untx20` por torneo
 *        · D1: precios base; QVAPAY paga ×2 UNTX-20
 *        · Pago dual alianza (bank | user) en el riel del líder
 *        · Comisión 5% destruida por riel
 *        · Reparto de premios por riel (sin acuñar)
 *        · Refunds por riel
 *        · Log NTX20LogHelper SOLO si CUP
 */

class PVPTournamentHelper
{
    /* ============================================================
     *  CONSTANTES
     * ============================================================ */

    // Mínimos
    const MIN_PLAYERS_1V1      = 7;
    const MIN_ALLIANCES        = 5;

    // Máximos (potencias de 2 con byes)
    const MAX_PLAYERS_1V1      = 32;
    const MAX_ALLIANCES        = 32;

    // Duración de ronda (segundos)
    const MIN_ROUND_DURATION   = 86400;   // 24h
    const MAX_ROUND_DURATION   = 172800;  // 48h
    const DEFAULT_ROUND_DURATION = 86400;

    // Extra si no se llena
    const EXTRA_WAIT_TIME      = 36000;   // +10h

    // Comisión por defecto
    const DEFAULT_COMMISSION   = 5;       // 5% se destruye

    // Ataques por día en torneo
    const MAX_ATTACKS_PER_DAY  = 5;


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
     * Devuelve el monto REAL que pagó un jugador por una base dada.
     * Como los precios se guardan en BASE NTX-20, el real depende del riel.
     */
    private static function getRealPaidByPlayer($baseFee, $userId)
    {
        return PVPHelper::getPrecioParaJugador((int) $baseFee, (int) $userId);
    }

    /**
     * Riel del líder (para pagos de alianza)
     */
    private static function getLeaderRail($leaderId)
    {
        return PVPHelper::getPlayerMethod((int) $leaderId);
    }


    /* ============================================================
     *  CREAR TORNEO (admin)
     * ============================================================ */

    /**
     * Crea un torneo.
     *
     * @param array $data {
     *   type                => '1v1' | 'alliance'
     *   mode                => 'single' | 'double_elimination'
     *   entry_fee           => int (base NTX-20, para 1v1)
     *   alliance_entry_fee  => int (base NTX-20, para alianza)
     *   max_players         => int (potencia de 2: 8, 16, 32)
     *   round_duration      => int (segundos, 24-48h)
     *   commission_pct      => int (0-100, default 5)
     *   winners_config      => array [1 => pct, 2 => pct, 3 => pct...] o null
     *   registration_ends_at => timestamp
     *   created_by          => user_id del admin
     * }
     * @return array ['ok' => bool, 'msg' => string, 'tournament_id' => int]
     */
    public static function createTournament($data)
    {
        if (!PVPHelper::isTournamentEnabled()) {
            return array('ok' => false, 'msg' => 'Los torneos están desactivados.');
        }

        // Solo 1 torneo activo al mismo tiempo
        $existing = self::db()->selectSingle(
            "SELECT `id` FROM %%PVP_TOURNAMENTS%% 
             WHERE `status` IN ('registration','running') 
             LIMIT 1;"
        );
        if (!empty($existing)) {
            return array('ok' => false, 'msg' => 'Ya hay un torneo activo. Debes esperar a que termine.');
        }

        // Validar type
        if (!PVPHelper::isValidTournamentType($data['type'] ?? '')) {
            return array('ok' => false, 'msg' => 'Tipo de torneo inválido.');
        }

        // Validar mode
        if (!PVPHelper::isValidTournamentMode($data['mode'] ?? '')) {
            return array('ok' => false, 'msg' => 'Modo de torneo inválido.');
        }

        // Validar max_players (potencia de 2 entre 8 y 32)
        $maxPlayers = (int) ($data['max_players'] ?? 8);
        if (!in_array($maxPlayers, array(8, 16, 32), true)) {
            return array('ok' => false, 'msg' => 'El máximo debe ser 8, 16 o 32.');
        }

        // Validar duración de ronda
        $roundDuration = (int) ($data['round_duration'] ?? self::DEFAULT_ROUND_DURATION);
        if ($roundDuration < self::MIN_ROUND_DURATION || $roundDuration > self::MAX_ROUND_DURATION) {
            $roundDuration = self::DEFAULT_ROUND_DURATION;
        }

        // Comisión
        $commission = isset($data['commission_pct'])
            ? max(0, min(100, (int) $data['commission_pct']))
            : (int) PVPHelper::get('tournament_commission', self::DEFAULT_COMMISSION);

        // Precios BASE
        $entryFee         = (int) ($data['entry_fee'] ?? 0);
        $allianceEntryFee = (int) ($data['alliance_entry_fee'] ?? 0);

        if ($data['type'] === '1v1' && $entryFee <= 0) {
            return array('ok' => false, 'msg' => 'El precio de entrada debe ser mayor que 0.');
        }
        if ($data['type'] === 'alliance' && $allianceEntryFee <= 0) {
            return array('ok' => false, 'msg' => 'El precio de entrada para alianzas debe ser mayor que 0.');
        }

        $now      = TIMESTAMP;
        $regEnds  = (int) ($data['registration_ends_at'] ?? ($now + 86400));

        $winnersConfig = !empty($data['winners_config']) && is_array($data['winners_config'])
            ? json_encode($data['winners_config'])
            : null;

        try {
            self::db()->insert(
                "INSERT INTO %%PVP_TOURNAMENTS%% SET
                    `type`                  = :type,
                    `mode`                  = :mode,
                    `status`                = 'registration',
                    `entry_fee`             = :fee,
                    `alliance_entry_fee`    = :afee,
                    `prize_pool`            = 0,
                    `pool_ntx20`            = 0,
                    `pool_untx20`           = 0,
                    `commission_pct`        = :comm,
                    `max_players`           = :maxp,
                    `current_players`       = 0,
                    `current_round`         = 0,
                    `round_duration`        = :rdur,
                    `registration_ends_at`  = :regend,
                    `starts_at`             = 0,
                    `finished_at`           = 0,
                    `winners_config`        = :wcfg,
                    `created_by`            = :creator,
                    `created_at`            = :now,
                    `universe`              = :universe;",
                array(
                    ':type'      => $data['type'],
                    ':mode'      => $data['mode'],
                    ':fee'       => $entryFee,
                    ':afee'      => $allianceEntryFee,
                    ':comm'      => $commission,
                    ':maxp'      => $maxPlayers,
                    ':rdur'      => $roundDuration,
                    ':regend'    => $regEnds,
                    ':wcfg'      => $winnersConfig,
                    ':creator'   => (int) ($data['created_by'] ?? 0),
                    ':now'       => $now,
                    ':universe'  => class_exists('Universe') ? Universe::current() : 1,
                )
            );
        } catch (Exception $e) {
            return array('ok' => false, 'msg' => 'Error al crear el torneo: ' . $e->getMessage());
        }

        $tournamentId = (int) self::db()->lastInsertId();

        PVPHelper::log('tournament', $tournamentId, 'created', (int) ($data['created_by'] ?? 0), array(
            'type' => $data['type'],
            'mode' => $data['mode'],
            'fee'  => $entryFee,
            'afee' => $allianceEntryFee,
        ));

        // Notificación global
        PVPHelper::sendGlobalNotification(
            '¡Nuevo torneo PvP programado!',
            'Se ha programado un torneo <b>' . $data['type'] . '</b> (' . $data['mode'] . ').<br>'
            . 'Inscripciones abiertas hasta: ' . date('d/m/Y H:i', $regEnds) . '<br>'
            . '<a href="game.php?page=pvp&tab=tournaments">Ver torneo</a>'
        );

        return array(
            'ok'            => true,
            'msg'           => 'Torneo creado correctamente.',
            'tournament_id' => $tournamentId,
        );
    }


    /* ============================================================
     *  INSCRIBIR JUGADOR 1v1
     * ============================================================ */

    public static function registerPlayer($tournamentId, $userId)
    {
        $tournamentId = (int) $tournamentId;
        $userId       = (int) $userId;

        $t = self::getTournament($tournamentId);
        if (empty($t)) {
            return array('ok' => false, 'msg' => 'Torneo no encontrado.');
        }

        if ($t['type'] !== '1v1') {
            return array('ok' => false, 'msg' => 'Este torneo es solo para alianzas.');
        }

        if ($t['status'] !== 'registration') {
            return array('ok' => false, 'msg' => 'Las inscripciones están cerradas.');
        }

        if ((int) $t['current_players'] >= (int) $t['max_players']) {
            return array('ok' => false, 'msg' => 'El torneo está lleno.');
        }

        // Ya inscrito?
        $ya = self::db()->selectSingle(
            "SELECT `id` FROM %%PVP_TOURNAMENT_PLAYERS%% 
             WHERE `tournament_id` = :tid AND `user_id` = :uid LIMIT 1;",
            array(':tid' => $tournamentId, ':uid' => $userId)
        );
        if (!empty($ya)) {
            return array('ok' => false, 'msg' => 'Ya estás inscrito en este torneo.');
        }

        // Ya en otro torneo activo?
        $enOtro = self::db()->selectSingle(
            "SELECT tp.`id`
             FROM %%PVP_TOURNAMENT_PLAYERS%% tp
             INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
             WHERE tp.`user_id` = :uid 
               AND t.`status` IN ('registration','running')
             LIMIT 1;",
            array(':uid' => $userId)
        );
        if (!empty($enOtro)) {
            return array('ok' => false, 'msg' => 'Ya estás en otro torneo activo.');
        }

        // Riel del jugador
        $riel    = PVPHelper::getPlayerMethod($userId);
        $moneda  = PVPHelper::getCurrencyLabel($userId);
        $isIntl  = ($riel === 'QVAPAY');

        // Fee BASE NTX-20
        $feeBase  = (int) $t['entry_fee'];
        $realPaid = self::getRealPaidByPlayer($feeBase, $userId);

        // Verificar saldo en su riel
        if (!PVPHelper::hasBalance($userId, $feeBase)) {
            return array('ok' => false, 'msg' => 'No tienes suficientes ' . $moneda . '. Necesitas ' . number_format($realPaid) . '.');
        }

        // Descontar del riel correcto (removeBalance loguea NTX20 solo si CUP)
        if (!PVPHelper::removeBalance($userId, $feeBase, 'pvp_tournament_reg', 'Inscripción torneo #' . $tournamentId)) {
            return array('ok' => false, 'msg' => 'No se pudo descontar la entrada.');
        }

        try {
            self::db()->insert(
                "INSERT INTO %%PVP_TOURNAMENT_PLAYERS%% SET
                    `tournament_id`   = :tid,
                    `user_id`         = :uid,
                    `alliance_id`     = 0,
                    `is_alliance`     = 0,
                    `paid`            = 1,
                    `payment_source`  = 'user',
                    `eliminated`      = 0,
                    `eliminated_round` = 0,
                    `final_position`  = 0,
                    `registered_at`   = :now;",
                array(':tid' => $tournamentId, ':uid' => $userId, ':now' => TIMESTAMP)
            );

            // Actualizar pool del riel + total legacy
            if ($isIntl) {
                self::db()->update(
                    "UPDATE %%PVP_TOURNAMENTS%% 
                     SET `pool_untx20` = `pool_untx20` + :real,
                         `prize_pool`   = `prize_pool` + :real2,
                         `current_players` = `current_players` + 1
                     WHERE `id` = :tid;",
                    array(':real' => $realPaid, ':real2' => $realPaid, ':tid' => $tournamentId)
                );
            } else {
                self::db()->update(
                    "UPDATE %%PVP_TOURNAMENTS%% 
                     SET `pool_ntx20` = `pool_ntx20` + :real,
                         `prize_pool` = `prize_pool` + :real2,
                         `current_players` = `current_players` + 1
                     WHERE `id` = :tid;",
                    array(':real' => $realPaid, ':real2' => $realPaid, ':tid' => $tournamentId)
                );
            }
        } catch (Exception $e) {
            PVPHelper::addRealAmount($userId, $realPaid, $riel, 'pvp_tournament_refund', 'Error al inscribir');
            if (!$isIntl) {
                self::logNtx20($userId, +$realPaid, 'earn_pvp_tournament', 'Reembolso torneo #' . $tournamentId . ' (error)', $tournamentId);
            }
            return array('ok' => false, 'msg' => 'Error al inscribir.');
        }

        PVPHelper::log('tournament', $tournamentId, 'player_registered', $userId, array(
            'fee_base'  => $feeBase,
            'real_paid' => $realPaid,
            'riel'      => $riel,
        ));

        return array('ok' => true, 'msg' => 'Inscrito en el torneo. Pago: ' . number_format($realPaid) . ' ' . $moneda . '.');
    }


    /* ============================================================
     *  INSCRIBIR ALIANZA (pago dual: bank | user)
     * ============================================================ */

    public static function registerAlliance($tournamentId, $allianceId, $leaderId, $source = 'bank')
    {
        $tournamentId = (int) $tournamentId;
        $allianceId   = (int) $allianceId;
        $leaderId     = (int) $leaderId;
        $source       = ($source === 'user') ? 'user' : 'bank';

        $t = self::getTournament($tournamentId);
        if (empty($t)) {
            return array('ok' => false, 'msg' => 'Torneo no encontrado.');
        }

        if ($t['type'] !== 'alliance') {
            return array('ok' => false, 'msg' => 'Este torneo es solo para jugadores individuales.');
        }

        if ($t['status'] !== 'registration') {
            return array('ok' => false, 'msg' => 'Las inscripciones están cerradas.');
        }

        if ((int) $t['current_players'] >= (int) $t['max_players']) {
            return array('ok' => false, 'msg' => 'El torneo está lleno.');
        }

        // Solo el líder puede inscribir
        if (class_exists('AllianceBankHelper') && method_exists('AllianceBankHelper', 'isLeader')) {
            if (!AllianceBankHelper::isLeader($leaderId, $allianceId)) {
                return array('ok' => false, 'msg' => 'Solo el líder puede inscribir la alianza.');
            }
        }

        // Ya inscrita?
        $ya = self::db()->selectSingle(
            "SELECT `id` FROM %%PVP_TOURNAMENT_PLAYERS%% 
             WHERE `tournament_id` = :tid AND `alliance_id` = :aid LIMIT 1;",
            array(':tid' => $tournamentId, ':aid' => $allianceId)
        );
        if (!empty($ya)) {
            return array('ok' => false, 'msg' => 'Tu alianza ya está inscrita.');
        }

        // Ya en otro torneo activo?
        $enOtro = self::db()->selectSingle(
            "SELECT tp.`id`
             FROM %%PVP_TOURNAMENT_PLAYERS%% tp
             INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
             WHERE tp.`alliance_id` = :aid 
               AND t.`status` IN ('registration','running')
             LIMIT 1;",
            array(':aid' => $allianceId)
        );
        if (!empty($enOtro)) {
            return array('ok' => false, 'msg' => 'Tu alianza está en otro torneo activo.');
        }

        // Riel del líder (define el riel del pago de alianza)
        $leaderRail = self::getLeaderRail($leaderId);
        $moneda     = ($leaderRail === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';
        $isIntl     = ($leaderRail === 'QVAPAY');

        $feeBase  = (int) $t['alliance_entry_fee'];
        $realPaid = self::getRealPaidByPlayer($feeBase, $leaderId);

        // PAGO
        if ($source === 'user') {
            // Paga el líder desde su cuenta (riel del líder)
            if (!PVPHelper::hasBalance($leaderId, $feeBase)) {
                return array('ok' => false, 'msg' => 'No tienes suficientes ' . $moneda . ' en tu cuenta. Necesitas ' . number_format($realPaid) . '.');
            }
            if (!PVPHelper::removeBalance($leaderId, $feeBase, 'pvp_tournament_reg_leader', 'Inscripción alianza #' . $allianceId)) {
                return array('ok' => false, 'msg' => 'Error al descontar de tu cuenta.');
            }
        } else {
            // Pago del banco (riel del líder)
            $bankCol = $isIntl ? 'untx20' : 'ntx20';
            $p       = self::prefix();
            $bank    = self::db()->selectSingle(
                "SELECT `" . $bankCol . "` AS `balance`
                   FROM `" . $p . "alliance_bank`
                  WHERE `alliance_id` = :aid
                  LIMIT 1;",
                array(':aid' => $allianceId)
            );
            $bankBalance = empty($bank) ? 0 : (int) $bank['balance'];

            if ($bankBalance < $realPaid) {
                return array('ok' => false, 'msg' => 'El banco de tu alianza no tiene suficientes ' . $moneda . '. Necesita ' . number_format($realPaid) . '.');
            }

            self::db()->update(
                "UPDATE `" . $p . "alliance_bank`
                    SET `" . $bankCol . "` = `" . $bankCol . "` - :n,
                        `updated_at` = :now
                  WHERE `alliance_id` = :aid
                  LIMIT 1;",
                array(':n' => $realPaid, ':now' => time(), ':aid' => $allianceId)
            );

            if (class_exists('AllianceBankHelper') && method_exists('AllianceBankHelper', 'log')) {
                try {
                    AllianceBankHelper::log($allianceId, $leaderId, 'withdraw', $bankCol, $realPaid, $bankBalance - $realPaid, 'Inscripción torneo #' . $tournamentId);
                } catch (Exception $e) { /* silencioso */ }
            }
        }

        try {
            self::db()->insert(
                "INSERT INTO %%PVP_TOURNAMENT_PLAYERS%% SET
                    `tournament_id`   = :tid,
                    `user_id`         = :uid,
                    `alliance_id`     = :aid,
                    `is_alliance`     = 1,
                    `paid`            = 1,
                    `payment_source`  = :src,
                    `eliminated`      = 0,
                    `eliminated_round` = 0,
                    `final_position`  = 0,
                    `registered_at`   = :now;",
                array(
                    ':tid' => $tournamentId,
                    ':uid' => $leaderId,
                    ':aid' => $allianceId,
                    ':src' => $source,
                    ':now' => TIMESTAMP,
                )
            );

            // Actualizar pool del riel + total legacy
            if ($isIntl) {
                self::db()->update(
                    "UPDATE %%PVP_TOURNAMENTS%% 
                     SET `pool_untx20` = `pool_untx20` + :real,
                         `prize_pool`   = `prize_pool` + :real2,
                         `current_players` = `current_players` + 1
                     WHERE `id` = :tid;",
                    array(':real' => $realPaid, ':real2' => $realPaid, ':tid' => $tournamentId)
                );
            } else {
                self::db()->update(
                    "UPDATE %%PVP_TOURNAMENTS%% 
                     SET `pool_ntx20` = `pool_ntx20` + :real,
                         `prize_pool` = `prize_pool` + :real2,
                         `current_players` = `current_players` + 1
                     WHERE `id` = :tid;",
                    array(':real' => $realPaid, ':real2' => $realPaid, ':tid' => $tournamentId)
                );
            }
        } catch (Exception $e) {
            // Devolver según source
            if ($source === 'user') {
                PVPHelper::addRealAmount($leaderId, $realPaid, $leaderRail, 'pvp_tournament_refund', 'Error al inscribir alianza');
                if (!$isIntl) {
                    self::logNtx20($leaderId, +$realPaid, 'earn_pvp_tournament', 'Reembolso torneo #' . $tournamentId . ' (error)', $tournamentId);
                }
            } else {
                PVPHelper::addBalanceToAllianceBank($allianceId, $realPaid, $leaderRail, 'pvp_tournament_refund', 'Error al inscribir alianza');
            }
            return array('ok' => false, 'msg' => 'Error al inscribir la alianza.');
        }

        PVPHelper::log('tournament', $tournamentId, 'alliance_registered', $leaderId, array(
            'alliance_id' => $allianceId,
            'fee_base'    => $feeBase,
            'real_paid'   => $realPaid,
            'source'      => $source,
            'riel'        => $leaderRail,
        ));

        return array('ok' => true, 'msg' => 'Alianza inscrita. Pago (' . $source . '): ' . number_format($realPaid) . ' ' . $moneda . '.');
    }


    /* ============================================================
     *  CERRAR INSCRIPCIONES / INICIAR TORNEO
     * ============================================================ */

    /**
     * Cierra inscripciones y genera el bracket.
     * Se llama cuando se alcanza el mínimo o cuando expira el plazo.
     */
    public static function closeRegistration($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        $t = self::getTournament($tournamentId);
        if (empty($t)) {
            return array('ok' => false, 'msg' => 'Torneo no encontrado.');
        }

        if ($t['status'] !== 'registration') {
            return array('ok' => false, 'msg' => 'El torneo ya no está en inscripciones.');
        }

        $min = ($t['type'] === 'alliance') ? self::MIN_ALLIANCES : self::MIN_PLAYERS_1V1;
        $current = (int) $t['current_players'];

        if ($current < $min) {
            return array('ok' => false, 'msg' => 'Faltan jugadores: ' . $current . '/' . $min . '.');
        }

        // Generar bracket
        self::generateBracket($tournamentId);

        // Arrancar la primera ronda
        self::startNextRound($tournamentId);

        // Cambiar status a running
        self::db()->update(
            "UPDATE %%PVP_TOURNAMENTS%% SET `status` = 'running', `starts_at` = :now WHERE `id` = :tid;",
            array(':now' => TIMESTAMP, ':tid' => $tournamentId)
        );

        PVPHelper::log('tournament', $tournamentId, 'registration_closed', 0, array(
            'players' => $current,
        ));

        // Notificar a todos
        $players = self::getRegisteredPlayers($tournamentId);
        foreach ($players as $p) {
            $puid   = (int) $p['user_id'];
            $riel   = PVPHelper::getPlayerMethod($puid);
            $moneda = PVPHelper::getCurrencyLabel($puid);
            $pool   = ($riel === 'QVAPAY') ? (int) $t['pool_untx20'] : (int) $t['pool_ntx20'];

            PVPHelper::sendNotification(
                $puid,
                '¡Torneo comenzado!',
                'El torneo #' . $tournamentId . ' ha comenzado. Ronda 1 en curso.<br>'
                . 'Premio acumulado de tu riel: ' . number_format($pool) . ' ' . $moneda . '.<br>'
                . '<a href="game.php?page=pvp&tab=tournaments">Ver bracket</a>'
            );
        }

        return array('ok' => true, 'msg' => 'Inscripciones cerradas. Torneo comenzado.');
    }


    /**
     * Cancela un torneo por falta de jugadores. Devuelve a cada uno en su riel.
     */
    public static function cancelTournament($tournamentId, $reason = '')
    {
        $tournamentId = (int) $tournamentId;
        $t = self::getTournament($tournamentId);
        if (empty($t)) {
            return array('ok' => false, 'msg' => 'Torneo no encontrado.');
        }

        if (in_array($t['status'], array('finished', 'cancelled'), true)) {
            return array('ok' => false, 'msg' => 'El torneo ya está cerrado.');
        }

        // Devolver a cada jugador en su riel
        $players = self::getRegisteredPlayers($tournamentId);
        foreach ($players as $p) {
            $baseFee = ((int) $p['is_alliance'] === 1)
                ? (int) $t['alliance_entry_fee']
                : (int) $t['entry_fee'];

            if ((int) $p['paid'] === 1 && $baseFee > 0) {
                if ((int) $p['is_alliance'] === 1 && $p['payment_source'] === 'bank') {
                    $leaderId   = (int) $p['user_id'];
                    $leaderRail = self::getLeaderRail($leaderId);
                    $realPaid   = self::getRealPaidByPlayer($baseFee, $leaderId);
                    $moneda     = ($leaderRail === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';

                    PVPHelper::addBalanceToAllianceBank(
                        (int) $p['alliance_id'],
                        $realPaid,
                        $leaderRail,
                        'pvp_tournament_refund',
                        'Torneo #' . $tournamentId . ' cancelado'
                    );

                    PVPHelper::sendNotification(
                        $leaderId,
                        'Torneo cancelado',
                        'El torneo #' . $tournamentId . ' fue cancelado. Se devolvieron ' . number_format($realPaid) . ' ' . $moneda . ' al banco de tu alianza.<br>Motivo: ' . $reason
                    );
                } else {
                    $userId   = (int) $p['user_id'];
                    $riel     = PVPHelper::getPlayerMethod($userId);
                    $moneda   = PVPHelper::getCurrencyLabel($userId);
                    $realPaid = self::getRealPaidByPlayer($baseFee, $userId);

                    PVPHelper::addRealAmount($userId, $realPaid, $riel, 'pvp_tournament_refund', 'Torneo #' . $tournamentId . ' cancelado');

                    if ($riel === 'CUP') {
                        self::logNtx20($userId, +$realPaid, 'earn_pvp_tournament', 'Reembolso torneo #' . $tournamentId . ' cancelado', $tournamentId);
                    }

                    PVPHelper::sendNotification(
                        $userId,
                        'Torneo cancelado',
                        'El torneo #' . $tournamentId . ' fue cancelado. Se te devolvieron ' . number_format($realPaid) . ' ' . $moneda . '.<br>Motivo: ' . $reason
                    );
                }
            }
        }

        self::db()->update(
            "UPDATE %%PVP_TOURNAMENTS%% SET `status` = 'cancelled', `finished_at` = :now WHERE `id` = :tid;",
            array(':now' => TIMESTAMP, ':tid' => $tournamentId)
        );

        PVPHelper::log('tournament', $tournamentId, 'cancelled', 0, array(
            'reason'   => $reason,
            'refunded' => count($players),
        ));

        return array('ok' => true, 'msg' => 'Torneo cancelado. Se devolvió la entrada a ' . count($players) . ' participantes.');
    }


    /* ============================================================
     *  GENERAR BRACKET (aleatorio, potencias de 2 con byes)
     * ============================================================ */

    /**
     * Genera el bracket aleatorio para el torneo.
     * Crea la ronda 1 con los enfrentamientos.
     */
    public static function generateBracket($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        $db = self::db();

        // Cargar participantes
        $players = self::getRegisteredPlayers($tournamentId);
        if (empty($players)) {
            return false;
        }

        // Barajar aleatoriamente
        $ids = array();
        foreach ($players as $p) {
            $ids[] = (int) $p['id'];
        }
        shuffle($ids);

        // Calcular tamaño del bracket (potencia de 2 más cercana por encima)
        $count = count($ids);
        $bracketSize = 8;
        while ($bracketSize < $count) {
            $bracketSize *= 2;
        }
        if ($bracketSize > 32) $bracketSize = 32;

        // Rellenar con byes (0 = bye)
        $byes = $bracketSize - $count;
        for ($i = 0; $i < $byes; $i++) {
            $ids[] = 0;
        }
        shuffle($ids);

        // Crear ronda 1
        $now = TIMESTAMP;
        $roundDuration = (int) self::getTournament($tournamentId)['round_duration'];
        $endsAt = $now + $roundDuration;

        $db->insert(
            "INSERT INTO %%PVP_TOURNAMENT_ROUNDS%% SET
                `tournament_id` = :tid,
                `round_number`  = 1,
                `starts_at`     = :now,
                `ends_at`       = :ends,
                `status`        = 'active';",
            array(':tid' => $tournamentId, ':now' => $now, ':ends' => $endsAt)
        );

        $roundId = (int) $db->lastInsertId();

        // Crear matches de la ronda 1
        $matchNumber = 1;
        for ($i = 0; $i < $bracketSize; $i += 2) {
            $p1 = $ids[$i];
            $p2 = $ids[$i + 1];

            // Si uno es bye, el otro pasa automáticamente
            $winner = 0;
            $status = 'pending';
            if ($p1 === 0 && $p2 > 0) {
                $winner = $p2;
                $status = 'finished';
            } elseif ($p1 > 0 && $p2 === 0) {
                $winner = $p1;
                $status = 'finished';
            }

            $db->insert(
                "INSERT INTO %%PVP_TOURNAMENT_MATCHES%% SET
                    `tournament_id` = :tid,
                    `round_id`      = :rid,
                    `match_number`  = :num,
                    `bracket_type`  = 'winners',
                    `player1_id`    = :p1,
                    `player2_id`    = :p2,
                    `winner_id`     = :win,
                    `status`        = :st,
                    `created_at`    = :now,
                    `resolved_at`   = :rat;",
                array(
                    ':tid' => $tournamentId,
                    ':rid' => $roundId,
                    ':num' => $matchNumber,
                    ':p1'  => $p1,
                    ':p2'  => $p2,
                    ':win' => $winner,
                    ':st'  => $status,
                    ':now' => $now,
                    ':rat' => $status === 'finished' ? $now : 0,
                )
            );

            $matchNumber++;
        }

        PVPHelper::log('tournament', $tournamentId, 'bracket_generated', 0, array(
            'players'      => $count,
            'bracket_size' => $bracketSize,
            'byes'         => $byes,
        ));

        return true;
    }


    /* ============================================================
     *  INICIAR SIGUIENTE RONDA
     * ============================================================ */

    /**
     * Inicia la siguiente ronda del torneo.
     * Llamado por el cron cuando una ronda termina y hay ganadores.
     */
    public static function startNextRound($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        $db = self::db();

        // Última ronda
        $lastRound = $db->selectSingle(
            "SELECT `id`, `round_number` 
             FROM %%PVP_TOURNAMENT_ROUNDS%% 
             WHERE `tournament_id` = :tid 
             ORDER BY `round_number` DESC LIMIT 1;",
            array(':tid' => $tournamentId)
        );

        if (empty($lastRound)) {
            return false;
        }

        $nextNumber = (int) $lastRound['round_number'] + 1;

        // Ganadores de la última ronda (en winners)
        $winners = $db->select(
            "SELECT `winner_id` 
             FROM %%PVP_TOURNAMENT_MATCHES%% 
             WHERE `tournament_id` = :tid 
               AND `round_id` = :rid 
               AND `bracket_type` = 'winners'
               AND `winner_id` > 0;",
            array(':tid' => $tournamentId, ':rid' => (int) $lastRound['id'])
        );

        if (count($winners) < 2) {
            // Solo 1 ganador → fin del torneo
            self::finishTournament($tournamentId);
            return false;
        }

        // Crear nueva ronda
        $now = TIMESTAMP;
        $rd  = (int) self::getTournament($tournamentId)['round_duration'];
        $endsAt = $now + $rd;

        $db->insert(
            "INSERT INTO %%PVP_TOURNAMENT_ROUNDS%% SET
                `tournament_id` = :tid,
                `round_number`  = :num,
                `starts_at`     = :now,
                `ends_at`       = :ends,
                `status`        = 'active';",
            array(':tid' => $tournamentId, ':num' => $nextNumber, ':now' => $now, ':ends' => $endsAt)
        );

        $newRoundId = (int) $db->lastInsertId();

        // Emparejar aleatoriamente
        $winnerIds = array();
        foreach ($winners as $w) {
            if ((int) $w['winner_id'] > 0) {
                $winnerIds[] = (int) $w['winner_id'];
            }
        }
        shuffle($winnerIds);

        $matchNumber = 1;
        for ($i = 0; $i < count($winnerIds); $i += 2) {
            $p1 = $winnerIds[$i] ?? 0;
            $p2 = $winnerIds[$i + 1] ?? 0;

            $winner = 0;
            $status = 'pending';
            if ($p1 > 0 && $p2 === 0) {
                $winner = $p1;
                $status = 'finished';
            }

            $db->insert(
                "INSERT INTO %%PVP_TOURNAMENT_MATCHES%% SET
                    `tournament_id` = :tid,
                    `round_id`      = :rid,
                    `match_number`  = :num,
                    `bracket_type`  = 'winners',
                    `player1_id`    = :p1,
                    `player2_id`    = :p2,
                    `winner_id`     = :win,
                    `status`        = :st,
                    `created_at`    = :now,
                    `resolved_at`   = :rat;",
                array(
                    ':tid' => $tournamentId,
                    ':rid' => $newRoundId,
                    ':num' => $matchNumber,
                    ':p1'  => $p1,
                    ':p2'  => $p2,
                    ':win' => $winner,
                    ':st'  => $status,
                    ':now' => $now,
                    ':rat' => $status === 'finished' ? $now : 0,
                )
            );
            $matchNumber++;
        }

        $db->update(
            "UPDATE %%PVP_TOURNAMENTS%% SET `current_round` = :r WHERE `id` = :tid;",
            array(':r' => $nextNumber, ':tid' => $tournamentId)
        );

        PVPHelper::log('tournament', $tournamentId, 'new_round_started', 0, array(
            'round' => $nextNumber,
            'matches' => $matchNumber - 1,
        ));

        // Notificar
        $players = self::getRegisteredPlayers($tournamentId);
        foreach ($players as $p) {
            if ((int) $p['eliminated'] === 0) {
                PVPHelper::sendNotification(
                    (int) $p['user_id'],
                    'Nueva ronda del torneo',
                    'La ronda ' . $nextNumber . ' del torneo #' . $tournamentId . ' ha comenzado.<br>'
                    . '<a href="game.php?page=pvp&tab=tournaments">Ver bracket</a>'
                );
            }
        }

        return true;
    }


    /* ============================================================
     *  RESOLVER RONDA / FINALIZAR TORNEO
     * ============================================================ */

    /**
     * Resuelve los matches de la ronda activa (por daño).
     * Llamado por el cron cuando termina el tiempo de la ronda.
     */
    public static function resolveRound($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        $db = self::db();

        $round = $db->selectSingle(
            "SELECT `id`, `round_number` 
             FROM %%PVP_TOURNAMENT_ROUNDS%% 
             WHERE `tournament_id` = :tid AND `status` = 'active' 
             ORDER BY `round_number` DESC LIMIT 1;",
            array(':tid' => $tournamentId)
        );

        if (empty($round)) {
            return false;
        }

        $matches = $db->select(
            "SELECT * FROM %%PVP_TOURNAMENT_MATCHES%% 
             WHERE `round_id` = :rid AND `status` = 'pending';",
            array(':rid' => (int) $round['id'])
        );

        foreach ($matches as $m) {
            $winner = self::determineMatchWinner((int) $m['id']);

            if ($winner === 'tie') {
                // Empate → pasan los dos (no se elimina a nadie)
                $db->update(
                    "UPDATE %%PVP_TOURNAMENT_MATCHES%% SET `status` = 'finished', `resolved_at` = :now 
                     WHERE `id` = :id;",
                    array(':now' => TIMESTAMP, ':id' => (int) $m['id'])
                );
                continue;
            }

            if ($winner === 0) {
                // No hubo actividad → ambos eliminados
                $db->update(
                    "UPDATE %%PVP_TOURNAMENT_MATCHES%% SET `status` = 'finished', `resolved_at` = :now 
                     WHERE `id` = :id;",
                    array(':now' => TIMESTAMP, ':id' => (int) $m['id'])
                );
                continue;
            }

            // Hay ganador
            self::setMatchWinner((int) $m['id'], (int) $winner);
        }

        // Marcar ronda como terminada
        $db->update(
            "UPDATE %%PVP_TOURNAMENT_ROUNDS%% SET `status` = 'finished' WHERE `id` = :rid;",
            array(':rid' => (int) $round['id'])
        );

        // Avanzar a la siguiente ronda
        self::startNextRound($tournamentId);

        return true;
    }


    /**
     * Determina el ganador de un match por daño total.
     *
     * @return int|string   user_id/alliance_id del ganador, 0 si no hubo actividad, 'tie' si empate
     */
    public static function determineMatchWinner($matchId)
    {
        $matchId = (int) $matchId;
        $db = self::db();

        $match = $db->selectSingle(
            "SELECT * FROM %%PVP_TOURNAMENT_MATCHES%% WHERE `id` = :id LIMIT 1;",
            array(':id' => $matchId)
        );
        if (empty($match)) return 0;

        $p1 = (int) $match['player1_id'];
        $p2 = (int) $match['player2_id'];

        if ($p1 === 0 || $p2 === 0) {
            return $p1 > 0 ? $p1 : $p2;
        }

        // Cargar ataques del match
        $rows = $db->select(
            "SELECT `attacker_id`, SUM(`damage_done`) AS total 
             FROM %%PVP_TOURNAMENT_ATTACKS%% 
             WHERE `match_id` = :mid 
             GROUP BY `attacker_id`;",
            array(':mid' => $matchId)
        );

        $dmg = array($p1 => 0, $p2 => 0);
        foreach ($rows as $r) {
            $uid = (int) $r['attacker_id'];
            if (isset($dmg[$uid])) {
                $dmg[$uid] = (int) $r['total'];
            }
        }

        // Los IDs aquí son de tournament_players.id, no user_id
        // Obtener los user_ids reales
        $playerRows = $db->select(
            "SELECT `id`, `user_id`, `alliance_id` FROM %%PVP_TOURNAMENT_PLAYERS%% 
             WHERE `id` IN (:p1, :p2) LIMIT 2;",
            array(':p1' => $p1, ':p2' => $p2)
        );

        $userMap = array();
        foreach ($playerRows as $pr) {
            $userMap[(int) $pr['id']] = ((int) $pr['is_alliance'] === 1)
                ? (int) $pr['alliance_id']
                : (int) $pr['user_id'];
        }

        // Reducir daño a por usuario real
        $dmgReal = array();
        foreach ($rows as $r) {
            $uid = (int) $r['attacker_id'];
            $pid = self::findPlayerIdByUser($match['tournament_id'], $uid);
            if ($pid > 0) {
                if (!isset($dmgReal[$pid])) $dmgReal[$pid] = 0;
                $dmgReal[$pid] += (int) $r['total'];
            }
        }

        $d1 = $dmgReal[$p1] ?? 0;
        $d2 = $dmgReal[$p2] ?? 0;

        if ($d1 === 0 && $d2 === 0) {
            return 0; // Nadie atacó → eliminar ambos
        }
        if ($d1 === $d2) {
            return 'tie';
        }

        return $d1 > $d2 ? $p1 : $p2;
    }


    /**
     * Marca el ganador de un match y elimina al perdedor.
     */
    public static function setMatchWinner($matchId, $winnerPlayerId)
    {
        $db = self::db();

        $match = $db->selectSingle(
            "SELECT * FROM %%PVP_TOURNAMENT_MATCHES%% WHERE `id` = :id LIMIT 1;",
            array(':id' => (int) $matchId)
        );
        if (empty($match)) return false;

        $p1 = (int) $match['player1_id'];
        $p2 = (int) $match['player2_id'];

        $loser = ($winnerPlayerId === $p1) ? $p2 : $p1;

        // Actualizar match
        $db->update(
            "UPDATE %%PVP_TOURNAMENT_MATCHES%% 
             SET `winner_id` = :win, `status` = 'finished', `resolved_at` = :now 
             WHERE `id` = :id;",
            array(':win' => $winnerPlayerId, ':now' => TIMESTAMP, ':id' => (int) $matchId)
        );

        // Eliminar al perdedor
        if ($loser > 0) {
            $db->update(
                "UPDATE %%PVP_TOURNAMENT_PLAYERS%% 
                 SET `eliminated` = 1, `eliminated_round` = :r 
                 WHERE `id` = :pid;",
                array(':r' => (int) $match['round_id'], ':pid' => $loser)
            );
        }

        // Sumar +1 punto de ranking al ganador
        $winner = $db->selectSingle(
            "SELECT `user_id` FROM %%PVP_TOURNAMENT_PLAYERS%% WHERE `id` = :id LIMIT 1;",
            array(':id' => $winnerPlayerId)
        );
        if (!empty($winner)) {
            PVPArenaHelper::addRankingPoint((int) $winner['user_id'], 1);
        }

        PVPHelper::log('tournament', (int) $match['tournament_id'], 'match_resolved', 0, array(
            'match_id' => (int) $matchId,
            'winner'   => $winnerPlayerId,
            'loser'    => $loser,
        ));

        return true;
    }


    /* ============================================================
     *  FINALIZAR TORNEO Y PAGAR PREMIOS
     * ============================================================ */

    /**
     * Finaliza el torneo. Aplica comisión 5% destruida por riel y reparte premios.
     */
    public static function finishTournament($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        $db = self::db();

        $t = self::getTournament($tournamentId);
        if (empty($t)) return false;
        if (in_array($t['status'], array('finished', 'cancelled'), true)) return false;

        // Ganador = último match final resuelto
        $lastMatch = $db->selectSingle(
            "SELECT `winner_id` FROM %%PVP_TOURNAMENT_MATCHES%% 
             WHERE `tournament_id` = :tid AND `bracket_type` = 'winners' AND `winner_id` > 0
             ORDER BY `id` DESC LIMIT 1;",
            array(':tid' => $tournamentId)
        );

        $winnerPlayerId = !empty($lastMatch) ? (int) $lastMatch['winner_id'] : 0;

        // Pools por riel
        $poolNtx  = (int) $t['pool_ntx20'];
        $poolUntx = (int) $t['pool_untx20'];

        // Comisión por riel (se destruye)
        $commPct = (int) $t['commission_pct'];
        $commNtx  = (int) floor($poolNtx  * $commPct / 100);
        $commUntx = (int) floor($poolUntx * $commPct / 100);
        $netNtx   = $poolNtx  - $commNtx;
        $netUntx  = $poolUntx - $commUntx;

        // Distribuir premios según winners_config
        $winners = json_decode((string) $t['winners_config'], true);
        if (!is_array($winners) || empty($winners)) {
            // Default: 100% al 1º
            $winners = array(1 => 100);
        }

        // Ganadores finales (no eliminados)
        $remaining = $db->select(
            "SELECT * FROM %%PVP_TOURNAMENT_PLAYERS%% 
             WHERE `tournament_id` = :tid AND `eliminated` = 0 
             ORDER BY `id` ASC;",
            array(':tid' => $tournamentId)
        );

        // Ordenar por posición (el último ganador = 1º)
        $positions = array();
        $pos = 1;

        foreach ($remaining as $r) {
            if ((int) $r['id'] === $winnerPlayerId) {
                $positions[1] = $r;
            } else {
                $pos++;
                if (!isset($positions[$pos])) {
                    $positions[$pos] = $r;
                }
            }
        }

        // Entregar premios
        foreach ($winners as $position => $pct) {
            $position = (int) $position;
            $pct      = (int) $pct;
            if (!isset($positions[$position])) continue;

            $player = $positions[$position];

            // Actualizar final_position
            $db->update(
                "UPDATE %%PVP_TOURNAMENT_PLAYERS%% SET `final_position` = :pos WHERE `id` = :pid;",
                array(':pos' => $position, ':pid' => (int) $player['id'])
            );

            if ((int) $player['is_alliance'] === 1) {
                // Premio al banco de la alianza (riel del líder)
                $leaderId   = (int) $player['user_id'];
                $leaderRail = self::getLeaderRail($leaderId);
                $isIntl     = ($leaderRail === 'QVAPAY');
                $netPool    = $isIntl ? $netUntx : $netNtx;
                $prize      = (int) floor($netPool * $pct / 100);
                if ($prize <= 0) continue;

                $moneda = $isIntl ? 'UNTX-20' : 'NTX-20';

                PVPHelper::addBalanceToAllianceBank(
                    (int) $player['alliance_id'],
                    $prize,
                    $leaderRail,
                    'pvp_tournament_prize',
                    'Premio torneo #' . $tournamentId . ' - Posición ' . $position
                );

                PVPHelper::sendNotification(
                    $leaderId,
                    '¡Premio de torneo!',
                    'Tu alianza ganó el puesto #' . $position . ' en el torneo #' . $tournamentId . '.<br>'
                    . 'Premio: ' . number_format($prize) . ' ' . $moneda . ' al banco.<br>'
                    . '<a href="game.php?page=alliancebank">Ver banco</a>'
                );
            } else {
                // Premio al usuario (su riel)
                $userId   = (int) $player['user_id'];
                $riel     = PVPHelper::getPlayerMethod($userId);
                $isIntl   = ($riel === 'QVAPAY');
                $netPool  = $isIntl ? $netUntx : $netNtx;
                $prize    = (int) floor($netPool * $pct / 100);
                if ($prize <= 0) continue;

                $moneda = $isIntl ? 'UNTX-20' : 'NTX-20';

                PVPHelper::addRealAmount($userId, $prize, $riel, 'pvp_tournament_prize', 'Premio torneo #' . $tournamentId . ' - Posición ' . $position);

                if (!$isIntl) {
                    self::logNtx20($userId, +$prize, 'earn_pvp_tournament', 'Premio torneo #' . $tournamentId . ' (posición ' . $position . ')', $tournamentId);
                }

                PVPHelper::sendNotification(
                    $userId,
                    '¡Premio de torneo!',
                    'Has ganado el puesto #' . $position . ' en el torneo #' . $tournamentId . '.<br>'
                    . 'Premio: ' . number_format($prize) . ' ' . $moneda . '.<br>'
                    . '<a href="game.php?page=pvp&tab=tournaments">Ver torneo</a>'
                );
            }

            // Ranking +5 por ganar torneo
            if ($position === 1) {
                PVPArenaHelper::addRankingPoint((int) $player['user_id'], 5);
            }
        }

        // Cerrar torneo
        $db->update(
            "UPDATE %%PVP_TOURNAMENTS%% SET `status` = 'finished', `finished_at` = :now WHERE `id` = :tid;",
            array(':now' => TIMESTAMP, ':tid' => $tournamentId)
        );

        PVPHelper::log('tournament', $tournamentId, 'finished', 0, array(
            'pool_ntx20'  => $poolNtx,
            'pool_untx20' => $poolUntx,
            'comm_ntx20'  => $commNtx,
            'comm_untx20' => $commUntx,
            'net_ntx20'   => $netNtx,
            'net_untx20'  => $netUntx,
            'winner_id'   => $winnerPlayerId,
            'distributed' => array_keys($positions),
        ));

        return true;
    }


    /* ============================================================
     *  DESCALIFICAR (admin)
     * ============================================================ */

    public static function disqualifyPlayer($tournamentId, $playerId, $reason = '')
    {
        $tournamentId = (int) $tournamentId;
        $playerId     = (int) $playerId;

        $db = self::db();

        $player = $db->selectSingle(
            "SELECT * FROM %%PVP_TOURNAMENT_PLAYERS%% 
             WHERE `id` = :pid AND `tournament_id` = :tid LIMIT 1;",
            array(':pid' => $playerId, ':tid' => $tournamentId)
        );
        if (empty($player)) {
            return array('ok' => false, 'msg' => 'Jugador no encontrado.');
        }

        // Marcar como eliminado (sin devolver entrada)
        $db->update(
            "UPDATE %%PVP_TOURNAMENT_PLAYERS%% 
             SET `eliminated` = 1, `paid` = 3 
             WHERE `id` = :pid;",
            array(':pid' => $playerId)
        );

        PVPHelper::log('tournament', $tournamentId, 'disqualified', (int) $player['user_id'], array(
            'player_id' => $playerId,
            'reason'    => $reason,
        ));

        PVPHelper::sendNotification(
            (int) $player['user_id'],
            'Descalificado del torneo',
            'Has sido descalificado del torneo #' . $tournamentId . '.<br>Motivo: ' . $reason . '<br>'
            . 'La entrada no será devuelta.'
        );

        return array('ok' => true, 'msg' => 'Jugador descalificado.');
    }


    /* ============================================================
     *  CRON — CIERRE AUTOMÁTICO
     * ============================================================ */

    /**
     * Cierra torneos cuya inscripción expiró.
     * Si no se llenó mínimo → cancelar y devolver.
     * Si se llenó → generar bracket.
     *
     * @return int
     */
    public static function processRegistrationTimeouts()
    {
        $db  = self::db();
        $now = TIMESTAMP;

        $rows = $db->select(
            "SELECT * FROM %%PVP_TOURNAMENTS%% 
             WHERE `status` = 'registration' 
               AND `registration_ends_at` <= :now;",
            array(':now' => $now)
        );

        $count = 0;
        foreach ($rows as $t) {
            $tournamentId = (int) $t['id'];
            $current = (int) $t['current_players'];
            $min = ($t['type'] === 'alliance') ? self::MIN_ALLIANCES : self::MIN_PLAYERS_1V1;

            if ($current >= $min) {
                self::closeRegistration($tournamentId);
            } else {
                // Extender 10h si aún no llegó al mínimo y no se ha extendido
                $regEnds = (int) $t['registration_ends_at'];
                if ($regEnds + self::EXTRA_WAIT_TIME > $now) {
                    // Ya está en la ventana de extensión, no hacer nada
                    continue;
                }
                // Ya pasó la extensión → cancelar
                self::cancelTournament($tournamentId, 'No se alcanzó el mínimo de jugadores.');
            }
            $count++;
        }

        return $count;
    }

    /**
     * Resuelve rondas cuyo tiempo terminó.
     */
    public static function processRoundTimeouts()
    {
        $db  = self::db();
        $now = TIMESTAMP;

        // Torneos running
        $tournaments = $db->select(
            "SELECT `id` FROM %%PVP_TOURNAMENTS%% WHERE `status` = 'running';"
        );

        $count = 0;
        foreach ($tournaments as $t) {
            $tid = (int) $t['id'];

            // ¿Hay ronda activa con tiempo expirado?
            $round = $db->selectSingle(
                "SELECT `id` FROM %%PVP_TOURNAMENT_ROUNDS%% 
                 WHERE `tournament_id` = :tid AND `status` = 'active' 
                   AND `ends_at` <= :now 
                 LIMIT 1;",
                array(':tid' => $tid, ':now' => $now)
            );

            if (!empty($round)) {
                self::resolveRound($tid);
                $count++;
            }
        }

        return $count;
    }


    /* ============================================================
     *  CONSULTAS
     * ============================================================ */

    public static function getTournament($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        if ($tournamentId <= 0) return null;
        return self::db()->selectSingle(
            "SELECT * FROM %%PVP_TOURNAMENTS%% WHERE `id` = :tid LIMIT 1;",
            array(':tid' => $tournamentId)
        );
    }

    public static function getActiveTournament()
    {
        return self::db()->selectSingle(
            "SELECT * FROM %%PVP_TOURNAMENTS%% 
             WHERE `status` IN ('registration','running') 
             ORDER BY `id` DESC LIMIT 1;"
        );
    }

    public static function getRegisteredPlayers($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        return self::db()->select(
            "SELECT tp.*, u.`username`, u.`metodo_retiro`, a.`ally_name`, a.`ally_tag`
             FROM %%PVP_TOURNAMENT_PLAYERS%% tp
             LEFT JOIN %%USERS%% u ON u.`id` = tp.`user_id`
             LEFT JOIN %%ALLIANCE%% a ON a.`id` = tp.`alliance_id`
             WHERE tp.`tournament_id` = :tid
             ORDER BY tp.`id` ASC;",
            array(':tid' => $tournamentId)
        );
    }

    public static function getRounds($tournamentId)
    {
        $tournamentId = (int) $tournamentId;
        return self::db()->select(
            "SELECT * FROM %%PVP_TOURNAMENT_ROUNDS%% 
             WHERE `tournament_id` = :tid 
             ORDER BY `round_number` ASC;",
            array(':tid' => $tournamentId)
        );
    }

    public static function getMatches($tournamentId, $roundId = 0)
    {
        $tournamentId = (int) $tournamentId;
        $roundId      = (int) $roundId;

        if ($roundId > 0) {
            return self::db()->select(
                "SELECT * FROM %%PVP_TOURNAMENT_MATCHES%% 
                 WHERE `tournament_id` = :tid AND `round_id` = :rid 
                 ORDER BY `match_number` ASC;",
                array(':tid' => $tournamentId, ':rid' => $roundId)
            );
        }

        return self::db()->select(
            "SELECT * FROM %%PVP_TOURNAMENT_MATCHES%% 
             WHERE `tournament_id` = :tid 
             ORDER BY `round_id` ASC, `match_number` ASC;",
            array(':tid' => $tournamentId)
        );
    }

    public static function getHistory($limit = 5)
    {
        $limit = max(1, min(50, (int) $limit));
        return self::db()->select(
            "SELECT * FROM %%PVP_TOURNAMENTS%% 
             WHERE `status` IN ('finished','cancelled') 
             ORDER BY `finished_at` DESC 
             LIMIT " . $limit . ";"
        );
    }

    public static function getMatch($matchId)
    {
        $matchId = (int) $matchId;
        return self::db()->selectSingle(
            "SELECT * FROM %%PVP_TOURNAMENT_MATCHES%% WHERE `id` = :id LIMIT 1;",
            array(':id' => $matchId)
        );
    }

    /**
     * Devuelve el ID del torneo activo del jugador (o 0).
     */
    public static function getActiveTournamentForUser($userId)
    {
        $userId = (int) $userId;
        $row = self::db()->selectSingle(
            "SELECT tp.`tournament_id`
             FROM %%PVP_TOURNAMENT_PLAYERS%% tp
             INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
             WHERE tp.`user_id` = :uid 
               AND tp.`eliminated` = 0
               AND t.`status` IN ('registration','running')
             LIMIT 1;",
            array(':uid' => $userId)
        );
        return empty($row) ? 0 : (int) $row['tournament_id'];
    }

    /**
     * Devuelve el ID del torneo activo de la alianza (o 0).
     */
    public static function getActiveTournamentForAlliance($allianceId)
    {
        $allianceId = (int) $allianceId;
        $row = self::db()->selectSingle(
            "SELECT tp.`tournament_id`
             FROM %%PVP_TOURNAMENT_PLAYERS%% tp
             INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
             WHERE tp.`alliance_id` = :aid 
               AND t.`status` IN ('registration','running')
             LIMIT 1;",
            array(':aid' => $allianceId)
        );
        return empty($row) ? 0 : (int) $row['tournament_id'];
    }


    /* ============================================================
     *  ATAQUES EN TORNEO
     * ============================================================ */

    /**
     * Registra un ataque dentro de un match de torneo.
     */
    public static function registerAttack($tournamentId, $matchId, $attackerId, $defenderId, $fleetId, $ships, $defenses, $damage)
    {
        $tournamentId = (int) $tournamentId;
        if ($tournamentId <= 0) return false;

        try {
            self::db()->insert(
                "INSERT INTO %%PVP_TOURNAMENT_ATTACKS%% SET
                    `tournament_id`       = :tid,
                    `match_id`            = :mid,
                    `attacker_id`         = :att,
                    `defender_id`         = :def,
                    `fleet_id`            = :fid,
                    `ships_destroyed`     = :sd,
                    `defenses_destroyed`  = :dd,
                    `damage_done`         = :dmg,
                    `created_at`          = :now;",
                array(
                    ':tid' => $tournamentId,
                    ':mid' => (int) $matchId,
                    ':att' => (int) $attackerId,
                    ':def' => (int) $defenderId,
                    ':fid' => (int) $fleetId,
                    ':sd'  => (int) $ships,
                    ':dd'  => (int) $defenses,
                    ':dmg' => (int) $damage,
                    ':now' => TIMESTAMP,
                )
            );
            return true;
        } catch (Exception $e) {
            PVPHelper::log('tournament', $tournamentId, 'register_attack_error', $attackerId, array(
                'error' => $e->getMessage(),
            ));
            return false;
        }
    }

    /**
     * ¿Puede atacar A a B? Verifica que estén emparejados en un match activo.
     */
    public static function canAttack($tournamentId, $attackerId, $defenderId)
    {
        $tournamentId = (int) $tournamentId;
        $attackerId   = (int) $attackerId;
        $defenderId   = (int) $defenderId;

        $db = self::db();

        // Player IDs
        $attPlayer = $db->selectSingle(
            "SELECT `id` FROM %%PVP_TOURNAMENT_PLAYERS%% WHERE `tournament_id` = :tid AND `user_id` = :uid LIMIT 1;",
            array(':tid' => $tournamentId, ':uid' => $attackerId)
        );
        $defPlayer = $db->selectSingle(
            "SELECT `id` FROM %%PVP_TOURNAMENT_PLAYERS%% WHERE `tournament_id` = :tid AND `user_id` = :uid LIMIT 1;",
            array(':tid' => $tournamentId, ':uid' => $defenderId)
        );

        if (empty($attPlayer) || empty($defPlayer)) return false;

        $apId = (int) $attPlayer['id'];
        $dpId = (int) $defPlayer['id'];

        // Buscar match activo entre ambos
        $match = $db->selectSingle(
            "SELECT `id` FROM %%PVP_TOURNAMENT_MATCHES%% 
             WHERE `tournament_id` = :tid 
               AND `status` IN ('pending','active') 
               AND ((`player1_id` = :p1 AND `player2_id` = :p2) OR (`player1_id` = :p2 AND `player2_id` = :p1))
             LIMIT 1;",
            array(':tid' => $tournamentId, ':p1' => $apId, ':p2' => $dpId)
        );

        return !empty($match) ? (int) $match['id'] : false;
    }


    /* ============================================================
     *  HELPERS INTERNOS
     * ============================================================ */

    private static function findPlayerIdByUser($tournamentId, $userId)
    {
        $row = self::db()->selectSingle(
            "SELECT `id` FROM %%PVP_TOURNAMENT_PLAYERS%% 
             WHERE `tournament_id` = :tid AND `user_id` = :uid LIMIT 1;",
            array(':tid' => (int) $tournamentId, ':uid' => (int) $userId)
        );
        return empty($row) ? 0 : (int) $row['id'];
    }
}