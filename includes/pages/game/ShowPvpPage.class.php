<?php

/**
 * AstroIO — ShowPvpPage
 * Página principal del sistema PvP (Arenas + Torneos + Ranking + Logros)
 *
 * Ubicación: includes/pages/game/ShowPvpPage.class.php
 * @package AstroIO
 * @version 2.0 — Doble Riel (NTX-20 / UNTX-20)
 *
 * v1.4 — Premio individual + coordenadas + flash URL
 * v2.0 — Doble Riel:
 *        · getRielVars($userId) centraliza la inyección de moneda/saldo
 *        · arenes()/tournaments()/createArena()/viewArena()/profile()
 *          muestran precios, saldos y pools en el riel del jugador
 *        · enrichArena() usa el pool del riel del jugador y cuenta
 *          ganadores del mismo riel
 *        · getUserStats() calcula ntx_won/ntx_lost por riel
 *        · Ranking muestra el saldo del riel de cada fila
 */

class ShowPvpPage extends AbstractGamePage
{
    public $requireModule     = MODULE_PVP;
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();

        require_once ROOT_PATH.'includes/classes/PVPHelper.class.php';
        require_once ROOT_PATH.'includes/classes/PVPArenaHelper.class.php';
        require_once ROOT_PATH.'includes/classes/PVPTournamentHelper.class.php';
        require_once ROOT_PATH.'includes/classes/PVPAchievementHelper.class.php';
        require_once ROOT_PATH.'includes/classes/PVPProcessor.class.php';
    }


    /* ============================================================
     *  DOBLE RIEL — VARIABLES PARA EL TEMPLATE
     * ============================================================ */

    /**
     * Devuelve las variables estándar del riel del jugador para inyectar
     * en cualquier template PvP.
     *
     * @param int $userId
     * @return array
     */
    private static function getRielVars($userId)
    {
        $riel = PVPHelper::getRielInfo($userId);
        return array(
            'moneda'           => $riel['moneda'],
            'moneda_fiat'      => $riel['monedaFiat'],
            'es_internacional' => $riel['isIntl'],
            'saldo_actual'     => $riel['saldo'],
            'multiplier'       => $riel['multiplier'],
        );
    }


    /* ============================================================
     *  CRON
     * ============================================================ */

    private function runCron()
    {
        try {
            PVPProcessor::run();
        } catch (Exception $e) {
            PVPHelper::log('system', 0, 'cron_from_page_error', 0, array(
                'error' => $e->getMessage(),
            ));
        }
    }


    /* ============================================================
     *  HELPER — redirigir con mensaje por URL
     * ============================================================ */

    private function redirectWithFlash($url, $msg, $ok = true)
    {
        $type  = $ok ? 'ok' : 'err';
        $sep   = (strpos($url, '?') === false) ? '?' : '&';
        $final = $url . $sep . 'fmsg=' . rawurlencode((string) $msg) . '&ftype=' . $type;
        $this->redirectTo($final);
    }


    /* ============================================================
     *  HELPER — leer flash (URL primero, sesión después)
     * ============================================================ */

    private function readFlash()
    {
        $fmsg  = (string) HTTP::_GP('fmsg', '');
        $ftype = (string) HTTP::_GP('ftype', '');

        if ($fmsg !== '') {
            return array(
                'type' => ($ftype === 'ok') ? 'success' : 'error',
                'msg'  => $fmsg,
            );
        }

        if (isset($_SESSION['pvp_flash'])) {
            $flash = $_SESSION['pvp_flash'];
            unset($_SESSION['pvp_flash']);
            return $flash;
        }

        return null;
    }


    /* ============================================================
     *  VISTA PRINCIPAL — PANEL
     * ============================================================ */

    public function show()
    {
        global $USER;

        $this->runCron();

        if (!PVPHelper::isArenaEnabled() && !PVPHelper::isTournamentEnabled()) {
            $this->printMessage('El sistema PvP está desactivado actualmente.');
            return;
        }

        $userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

        $arenasActive  = 0;
        $arenasWaiting = 0;
        $myArena       = null;

        if ($userId > 0) {
            try {
                $myArena = self::getUserActiveArena($userId);
            } catch (Exception $e) {}
        }

        try {
            $arenasWaiting = count(PVPArenaHelper::getAvailableArenas(50));
            $stats = PVPProcessor::getStats();
            $arenasActive = isset($stats['arenas_active']) ? $stats['arenas_active'] : 0;
        } catch (Exception $e) {}

        $activeTournament = null;
        try {
            $activeTournament = PVPTournamentHelper::getActiveTournament();
        } catch (Exception $e) {}

        $myStats = self::getUserStats($userId);

        $achData = array('unlocked' => 0, 'total' => 8);
        try {
            $achData = PVPAchievementHelper::getUserAchievements($userId);
        } catch (Exception $e) {}

        $assign = array(
            'pvp' => array(
                'arena_enabled'      => PVPHelper::isArenaEnabled() ? 1 : 0,
                'tournament_enabled' => PVPHelper::isTournamentEnabled() ? 1 : 0,
                'arenas_waiting'     => $arenasWaiting,
                'arenas_active'      => $arenasActive,
            ),
            'my_arena'           => $myArena,
            'active_tournament'  => $activeTournament,
            'my_stats'           => $myStats,
            'ach_unlocked'       => isset($achData['unlocked']) ? $achData['unlocked'] : 0,
            'ach_total'          => isset($achData['total']) ? $achData['total'] : 8,
        );

        // Doble riel
        $assign = array_merge($assign, self::getRielVars($userId));

        $this->assign($assign);

        $this->display('page.pvp.default.tpl');
    }


    /* ============================================================
     *  SUB-PESTAÑA: ARENAS
     * ============================================================ */

    public function arenas()
    {
        global $USER;

        $this->runCron();

        if (!PVPHelper::isArenaEnabled()) {
            $this->printMessage('El sistema de arenas está desactivado.');
            return;
        }

        $userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

        $available = array();
        try {
            $available = PVPArenaHelper::getAvailableArenas(30);
        } catch (Exception $e) {}

        $myArenas = array();
        try {
            $myArenas = PVPArenaHelper::getUserArenas($userId);
        } catch (Exception $e) {}

        $enriched = array();
        foreach ($available as $a) {
            $enriched[] = self::enrichArena($a, $userId);
        }

        $myEnriched = array();
        foreach ($myArenas as $a) {
            $myEnriched[] = self::enrichArena($a, $userId);
        }

        $flash = $this->readFlash();

        // Precios BASE
        $pricesBase = array(
            '1v1_min' => PVPArenaHelper::getMinFee1v1(),
            '1v1_max' => PVPArenaHelper::getMaxFee1v1(),
            '2v2'     => PVPArenaHelper::getEntryFee('2v2'),
            '3v3'     => PVPArenaHelper::getEntryFee('3v3'),
        );

        // Precios REALES (×2 si QVAPAY)
        $isIntl = PVPHelper::isIntl($userId);
        $mult   = $isIntl ? PVPHelper::UNTX_MULTIPLIER : 1;

        $pricesReal = array(
            '1v1_min' => (int) $pricesBase['1v1_min'] * $mult,
            '1v1_max' => (int) $pricesBase['1v1_max'] * $mult,
            '2v2'     => (int) $pricesBase['2v2']     * $mult,
            '3v3'     => (int) $pricesBase['3v3']     * $mult,
        );

        $assign = array(
            'available_arenas' => $enriched,
            'my_arenas'        => $myEnriched,
            'can_create'       => (PVPArenaHelper::countUserActiveArenas($userId) === 0
                                    && PVPArenaHelper::countUserActiveParticipations($userId) === 0),
            'flash'            => $flash,
            'prices'           => $pricesReal,
            'prices_base'      => $pricesBase,
        );

        $assign = array_merge($assign, self::getRielVars($userId));

        $this->assign($assign);

        $this->display('page.pvp.arenas.tpl');
    }


    /* ============================================================
     *  SUB-PESTAÑA: TORNEOS
     * ============================================================ */

    public function tournaments()
    {
        global $USER;

        $this->runCron();

        if (!PVPHelper::isTournamentEnabled()) {
            $this->printMessage('El sistema de torneos está desactivado.');
            return;
        }

        $userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

        $active = null;
        try {
            $active = PVPTournamentHelper::getActiveTournament();
        } catch (Exception $e) {}

        $registeredPlayers = array();
        $rounds            = array();
        $matchesByRound    = array();
        $myRegistration    = null;
        $myAllianceId      = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
        $myAllianceReg     = null;

        if (!empty($active)) {
            try {
                $registeredPlayers = PVPTournamentHelper::getRegisteredPlayers((int) $active['id']);
                $rounds            = PVPTournamentHelper::getRounds((int) $active['id']);
                $allMatches        = PVPTournamentHelper::getMatches((int) $active['id']);

                foreach ($allMatches as $m) {
                    $matchesByRound[(int) $m['round_id']][] = $m;
                }

                if ($userId > 0) {
                    foreach ($registeredPlayers as $rp) {
                        if ((int) $rp['user_id'] === $userId && (int) $rp['is_alliance'] === 0) {
                            $myRegistration = $rp;
                            break;
                        }
                    }
                }

                if ($myAllianceId > 0) {
                    foreach ($registeredPlayers as $rp) {
                        if ((int) $rp['is_alliance'] === 1 && (int) $rp['alliance_id'] === $myAllianceId) {
                            $myAllianceReg = $rp;
                            break;
                        }
                    }
                }
            } catch (Exception $e) {}
        }

        // 🆕 Saldo del banco de alianza en el riel del jugador (líder paga)
        $allianceBankBalance = 0;
        $allianceBankMoneda  = PVPHelper::getCurrencyLabel($userId);
        $bankCol             = PVPHelper::getPhysicalColumn($userId);
        if ($myAllianceId > 0) {
            try {
                $db  = Database::get();
                $row = $db->selectSingle(
                    "SELECT `".$bankCol."` AS `balance` FROM `".DB_PREFIX."alliance_bank` WHERE `alliance_id` = :aid LIMIT 1;",
                    array(':aid' => $myAllianceId)
                );
                $allianceBankBalance = empty($row) ? 0 : (int) $row['balance'];
            } catch (Exception $e) {}
        }

        // 🆕 Precios de entrada en el riel del jugador
        $entryFeeBase        = $active ? (int) $active['entry_fee'] : 0;
        $allianceEntryFeeBase = $active ? (int) $active['alliance_entry_fee'] : 0;

        $entryFeeReal         = PVPHelper::getPrecioParaJugador($entryFeeBase, $userId);
        $allianceEntryFeeReal = PVPHelper::getPrecioParaJugador($allianceEntryFeeBase, $userId);

        $flash = $this->readFlash();

        $assign = array(
            'active_tournament'      => $active,
            'registered_players'     => $registeredPlayers,
            'rounds'                 => $rounds,
            'matches_by_round'       => $matchesByRound,
            'my_registration'        => $myRegistration,
            'my_alliance_id'         => $myAllianceId,
            'my_alliance_reg'        => $myAllianceReg,
            'alliance_bank_ntx'      => $allianceBankBalance,
            'alliance_bank_moneda'   => $allianceBankMoneda,
            'entry_fee_real'         => $entryFeeReal,
            'alliance_entry_fee_real'=> $allianceEntryFeeReal,
            'entry_fee_base'         => $entryFeeBase,
            'alliance_entry_fee_base'=> $allianceEntryFeeBase,
            'can_register_1v1'       => ($active
                                        && $active['type'] === '1v1'
                                        && $active['status'] === 'registration'
                                        && empty($myRegistration)
                                        && (int) $active['current_players'] < (int) $active['max_players']),
            'can_register_ally'      => ($active
                                        && $active['type'] === 'alliance'
                                        && $active['status'] === 'registration'
                                        && $myAllianceId > 0
                                        && empty($myAllianceReg)
                                        && (int) $active['current_players'] < (int) $active['max_players']),
            'flash'                  => $flash,
        );

        $assign = array_merge($assign, self::getRielVars($userId));

        $this->assign($assign);

        $this->display('page.pvp.tournaments.tpl');
    }


    /* ============================================================
     *  SUB-PESTAÑA: HISTORIAL
     * ============================================================ */

    public function history()
    {
        global $USER;

        $this->runCron();

        $userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

        $arenaHistory   = array();
        $tourneyHistory = array();

        try {
            $arenaHistory = PVPArenaHelper::getHistory(5);
        } catch (Exception $e) {}

        try {
            $tourneyHistory = PVPTournamentHelper::getHistory(5);
        } catch (Exception $e) {}

        $assign = array(
            'arena_history'   => $arenaHistory,
            'tourney_history' => $tourneyHistory,
        );

        $assign = array_merge($assign, self::getRielVars($userId));

        $this->assign($assign);

        $this->display('page.pvp.history.tpl');
    }


    /* ============================================================
     *  SUB-PESTAÑA: LOGROS
     * ============================================================ */

    public function achievements()
    {
        global $USER;

        $userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

        $data = array(
            'achievements' => array(),
            'unlocked'     => 0,
            'total'        => 8,
        );

        try {
            $data = PVPAchievementHelper::getUserAchievements($userId);
        } catch (Exception $e) {}

        $assign = array(
            'ach_data' => $data,
        );

        $assign = array_merge($assign, self::getRielVars($userId));

        $this->assign($assign);

        $this->display('page.pvp.achievements.tpl');
    }


    /* ============================================================
     *  SUB-PESTAÑA: PERFIL + RANKING
     * ============================================================ */

    public function profile()
    {
        global $USER;

        $this->runCron();

        $userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

        $myStats = self::getUserStats($userId);

        $ranking = array();
        try {
            $db   = Database::get();
            $rows = $db->select(
                "SELECT u.`id`, u.`username`, u.`pvp_points`, u.`ntx20`, u.`untx20`, u.`metodo_retiro`
                 FROM %%USERS%% u
                 WHERE u.`pvp_points` > 0
                 ORDER BY u.`pvp_points` DESC, u.`id` ASC
                 LIMIT 25;"
            );

            $pos = 1;
            if (is_array($rows)) {
                foreach ($rows as $r) {
                    $r['position'] = $pos++;

                    // 🆕 Saldo del riel de cada jugador del ranking
                    $isIntlRow  = (isset($r['metodo_retiro']) && $r['metodo_retiro'] === 'QVAPAY');
                    $r['moneda']       = $isIntlRow ? 'UNTX-20' : 'NTX-20';
                    $r['saldo_riel']   = $isIntlRow ? (int) $r['untx20'] : (int) $r['ntx20'];

                    $ranking[] = $r;
                }
            }
        } catch (Exception $e) {}

        $assign = array(
            'my_stats' => $myStats,
            'ranking'  => $ranking,
        );

        $assign = array_merge($assign, self::getRielVars($userId));

        $this->assign($assign);

        $this->display('page.pvp.profile.tpl');
    }


    /* ============================================================
     *  ACCIÓN: CREAR ARENA
     * ============================================================ */

    public function createArena()
    {
        global $USER;

        if (!PVPHelper::isArenaEnabled()) {
            $this->redirectTo('game.php?page=pvp&mode=arenas');
            return;
        }

        $userId = !empty($USER['id']) ? (int) $USER['id'] : 0;

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $mode     = HTTP::_GP('arena_mode', '1v1');
            $entryFee = (int) HTTP::_GP('fee', 0);

            if (!PVPHelper::isValidMode($mode)) {
                $mode = '1v1';
            }

            // Precios BASE y REALES
            $pricesBase = array(
                '1v1_min' => PVPArenaHelper::getMinFee1v1(),
                '1v1_max' => PVPArenaHelper::getMaxFee1v1(),
                '2v2'     => PVPArenaHelper::getEntryFee('2v2'),
                '3v3'     => PVPArenaHelper::getEntryFee('3v3'),
            );

            $isIntl = PVPHelper::isIntl($userId);
            $mult   = $isIntl ? PVPHelper::UNTX_MULTIPLIER : 1;

            $pricesReal = array(
                '1v1_min' => (int) $pricesBase['1v1_min'] * $mult,
                '1v1_max' => (int) $pricesBase['1v1_max'] * $mult,
                '2v2'     => (int) $pricesBase['2v2']     * $mult,
                '3v3'     => (int) $pricesBase['3v3']     * $mult,
            );

            $assign = array(
                'selected_mode' => $mode,
                'entry_fee'     => $entryFee,
                'prices'        => $pricesReal,
                'prices_base'   => $pricesBase,
                'my_ntx'        => PVPHelper::getBalance($userId),
            );

            $assign = array_merge($assign, self::getRielVars($userId));

            $this->assign($assign);

            $this->display('page.pvp.arenas.create.tpl');
            return;
        }

        $mode     = HTTP::_GP('arena_mode', '1v1');
        $entryFee = (int) HTTP::_GP('fee', 0);

        $res = PVPArenaHelper::createArena($userId, $mode, $entryFee);

        $this->redirectWithFlash(
            'game.php?page=pvp&mode=arenas',
            isset($res['msg']) ? $res['msg'] : 'Resultado desconocido.',
            !empty($res['ok'])
        );
    }


    /* ============================================================
     *  ACCIÓN: UNIRSE A ARENA
     * ============================================================ */

    public function joinArena()
    {
        global $USER;

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirectTo('game.php?page=pvp&mode=arenas');
            return;
        }

        $userId  = !empty($USER['id']) ? (int) $USER['id'] : 0;
        $arenaId = (int) HTTP::_GP('arena_id', 0);

        $res = PVPArenaHelper::joinArena($arenaId, $userId);

        $this->redirectWithFlash(
            'game.php?page=pvp&mode=arenas',
            isset($res['msg']) ? $res['msg'] : 'Resultado desconocido.',
            !empty($res['ok'])
        );
    }


    /* ============================================================
     *  ACCIÓN: CANCELAR ARENA
     * ============================================================ */

    public function cancelArena()
    {
        global $USER;

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirectTo('game.php?page=pvp&mode=arenas');
            return;
        }

        $userId  = !empty($USER['id']) ? (int) $USER['id'] : 0;
        $arenaId = (int) HTTP::_GP('arena_id', 0);

        $res = PVPArenaHelper::cancelArena($arenaId, $userId);

        $this->redirectWithFlash(
            'game.php?page=pvp&mode=arenas',
            isset($res['msg']) ? $res['msg'] : 'Resultado desconocido.',
            !empty($res['ok'])
        );
    }


    /* ============================================================
     *  ACCIÓN: RECLAMAR PREMIO DE ARENA
     * ============================================================ */

    public function claimPrize()
    {
        global $USER;

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirectTo('game.php?page=pvp&mode=arenas');
            return;
        }

        $userId  = !empty($USER['id']) ? (int) $USER['id'] : 0;
        $arenaId = (int) HTTP::_GP('arena_id', 0);

        $res = PVPArenaHelper::claimPrize($arenaId, $userId);

        if (!empty($res['ok'])) {
            try {
                PVPAchievementHelper::checkAchievements($userId);
            } catch (Exception $e) {}
        }

        $this->redirectWithFlash(
            'game.php?page=pvp&mode=arenas',
            isset($res['msg']) ? $res['msg'] : 'Resultado desconocido.',
            !empty($res['ok'])
        );
    }


    /* ============================================================
     *  ACCIÓN: VER DETALLE DE ARENA
     * ============================================================ */

    public function viewArena()
    {
        global $USER;

        $arenaId = (int) HTTP::_GP('arena_id', 0);
        $userId  = !empty($USER['id']) ? (int) $USER['id'] : 0;

        $arena = PVPArenaHelper::getArena($arenaId);
        if (empty($arena)) {
            $this->printMessage('Arena no encontrada.');
            return;
        }

        // Jugadores + planeta principal (username + coords) en 1 sola query
        $players = PVPArenaHelper::getArenaPlayersWithPlanets($arenaId);

        // Mapa user_id => team (para calcular daño por equipo)
        $userTeam = array();
        foreach ($players as $p) {
            $userTeam[(int) $p['user_id']] = (int) $p['team'];
        }

        // Daño acumulado por equipo
        $teamDamage = array(0 => 0, 1 => 0);
        try {
            $db   = Database::get();
            $rows = $db->select(
                "SELECT `attacker_id`, SUM(`damage_done`) AS total 
                 FROM %%PVP_ARENA_ATTACKS%% 
                 WHERE `arena_id` = :aid 
                 GROUP BY `attacker_id`;",
                array(':aid' => $arenaId)
            );
            foreach ($rows as $r) {
                $uid = (int) $r['attacker_id'];
                if (isset($userTeam[$uid])) {
                    $teamDamage[$userTeam[$uid]] += (int) $r['total'];
                }
            }
        } catch (Exception $e) {}

        $arenaEnriched = self::enrichArena($arena, $userId);

        $assign = array(
            'arena'       => $arenaEnriched,
            'players'     => $players,
            'team_damage' => $teamDamage,
            'my_user_id'  => $userId,
        );

        $assign = array_merge($assign, self::getRielVars($userId));

        $this->assign($assign);

        $this->display('page.pvp.arena.view.tpl');
    }


    /* ============================================================
     *  ACCIÓN: INSCRIBIRSE EN TORNEO 1v1
     * ============================================================ */

    public function registerTournament()
    {
        global $USER;

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirectTo('game.php?page=pvp&mode=tournaments');
            return;
        }

        $userId       = !empty($USER['id']) ? (int) $USER['id'] : 0;
        $tournamentId = (int) HTTP::_GP('tournament_id', 0);

        $res = PVPTournamentHelper::registerPlayer($tournamentId, $userId);

        $this->redirectWithFlash(
            'game.php?page=pvp&mode=tournaments',
            isset($res['msg']) ? $res['msg'] : 'Resultado desconocido.',
            !empty($res['ok'])
        );
    }


    /* ============================================================
     *  ACCIÓN: INSCRIBIR ALIANZA
     * ============================================================ */

    public function registerAlliance()
    {
        global $USER;

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirectTo('game.php?page=pvp&mode=tournaments');
            return;
        }

        $userId       = !empty($USER['id']) ? (int) $USER['id'] : 0;
        $allianceId   = !empty($USER['ally_id']) ? (int) $USER['ally_id'] : 0;
        $tournamentId = (int) HTTP::_GP('tournament_id', 0);
        $source       = HTTP::_GP('source', 'bank');

        if ($allianceId <= 0) {
            $this->redirectWithFlash(
                'game.php?page=pvp&mode=tournaments',
                'No perteneces a ninguna alianza.',
                false
            );
            return;
        }

        $res = PVPTournamentHelper::registerAlliance($tournamentId, $allianceId, $userId, $source);

        $this->redirectWithFlash(
            'game.php?page=pvp&mode=tournaments',
            isset($res['msg']) ? $res['msg'] : 'Resultado desconocido.',
            !empty($res['ok'])
        );
    }


    /* ============================================================
     *  HELPERS
     * ============================================================ */

    private function pvpRedirect($url)
    {
        HTTP::redirectTo($url);
        exit;
    }


    private static function getUserActiveArena($userId)
    {
        $userId = (int) $userId;
        if ($userId <= 0) return null;

        $db  = Database::get();
        $row = $db->selectSingle(
            "SELECT a.* 
             FROM %%PVP_ARENAS%% a
             INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
             WHERE ap.`user_id` = :uid 
               AND a.`status` IN ('waiting','active','extra_time')
             LIMIT 1;",
            array(':uid' => $userId)
        );

        if (empty($row)) return null;

        return self::enrichArena($row, $userId);
    }


    /**
     * Enriquece una arena con datos calculados para el template.
     * v2.0: precios, pools y premio individual en el riel del jugador.
     */
    private static function enrichArena($arena, $userId)
    {
        if (empty($arena)) return $arena;

        $now = TIMESTAMP;

        $timeLeft = 0;
        if ($arena['status'] === 'waiting') {
            $expire   = PVPArenaHelper::getExpire();
            $timeLeft = max(0, ((int) $arena['created_at'] + $expire) - $now);
        } elseif ($arena['status'] === 'active') {
            $timeLeft = max(0, (int) $arena['ends_at'] - $now);
        } elseif ($arena['status'] === 'extra_time') {
            $timeLeft = max(0, (int) $arena['extra_time_ends_at'] - $now);
        }

        $arena['time_left']       = $timeLeft;
        $arena['time_left_fmt']   = PVPHelper::formatCountdown($timeLeft);
        $arena['countdown_color'] = PVPHelper::getCountdownColor(
            $timeLeft,
            in_array($arena['status'], array('active','extra_time'), true)
        );

        $arena['mode_label'] = strtoupper($arena['mode']);
        $arena['team_size']  = PVPHelper::getModeTeamSize($arena['mode']);

        // 🆕 Fee en el riel del jugador
        $feeBase        = (int) $arena['entry_fee'];
        $feeReal        = PVPHelper::getPrecioParaJugador($feeBase, $userId);
        $arena['fee_base'] = $feeBase;
        $arena['fee_real'] = $feeReal;
        $arena['fee_fmt']  = number_format($feeReal);

        // 🆕 Pool en el riel del jugador
        $isIntl     = PVPHelper::isIntl($userId);
        $myPoolReal = $isIntl
            ? (int) (isset($arena['pool_untx20']) ? $arena['pool_untx20'] : 0)
            : (int) (isset($arena['pool_ntx20'])  ? $arena['pool_ntx20']  : 0);

        $arena['my_pool']     = $myPoolReal;
        $arena['pool_fmt']    = number_format($myPoolReal);
        $arena['pool_fmt_global'] = number_format((int) $arena['prize_pool']);

        $arena['i_am_in']      = false;
        $arena['i_am_creator'] = ((int) $arena['creator_id'] === $userId);
        $arena['i_am_winner']  = false;
        $arena['i_can_claim']  = false;
        $arena['my_team']      = 0;
        $arena['my_paid']      = 0;

        $winnerCountReal = 0;

        try {
            $db  = Database::get();
            $row = $db->selectSingle(
                "SELECT * FROM %%PVP_ARENA_PLAYERS%% 
                 WHERE `arena_id` = :aid AND `user_id` = :uid LIMIT 1;",
                array(':aid' => (int) $arena['id'], ':uid' => $userId)
            );
            if (!empty($row)) {
                $arena['i_am_in'] = true;
                $arena['my_team'] = (int) $row['team'];
                $arena['my_paid'] = (int) $row['paid'];

                if ($arena['status'] === 'finished'
                    && (int) $row['team'] === (int) $arena['winner_team']
                    && (int) $row['paid'] !== 2
                    && ((int) $arena['claim_deadline'] === 0 || (int) $arena['claim_deadline'] > $now)
                ) {
                    $arena['i_am_winner'] = true;
                    $arena['i_can_claim'] = true;
                }
            }

            // 🆕 Contar solo ganadores del MISMO riel (para reparto justo)
            if ($arena['status'] === 'finished') {
                $winnersAll = $db->select(
                    "SELECT `user_id` FROM %%PVP_ARENA_PLAYERS%%
                     WHERE `arena_id` = :aid AND `team` = :team;",
                    array(':aid' => (int) $arena['id'], ':team' => (int) $arena['winner_team'])
                );
                foreach ($winnersAll as $w) {
                    $wuId = (int) $w['user_id'];
                    $wIntl = PVPHelper::isIntl($wuId);
                    if ($wIntl === $isIntl) {
                        $winnerCountReal++;
                    }
                }
            }
        } catch (Exception $e) {}

        // Fallback al teamSize si aún no hay ganadores reales (arena no finalizada)
        if ($winnerCountReal <= 0) {
            $winnerCountReal = max(1, (int) $arena['team_size']);
        }

        $arena['winner_count']         = $winnerCountReal;
        $arena['prize_individual']     = (int) floor($myPoolReal / $winnerCountReal);
        $arena['prize_individual_fmt'] = number_format($arena['prize_individual']);

        $arena['can_cancel'] = ($arena['i_am_creator'] && $arena['status'] === 'waiting');

        return $arena;
    }


    /**
     * Estadísticas del jugador para su perfil PvP.
     * v2.0: ntx_won / ntx_lost se calculan en el riel del jugador.
     */
    private static function getUserStats($userId)
    {
        $userId = (int) $userId;

        $stats = array(
            'wins'            => 0,
            'losses'          => 0,
            'ntx_won'         => 0,
            'ntx_lost'        => 0,
            'arena_wins_1v1'  => 0,
            'arena_wins_2v2'  => 0,
            'arena_wins_3v3'  => 0,
            'tournaments_won' => 0,
            'best_streak'     => 0,
            'points'          => 0,
        );

        if ($userId <= 0) return $stats;

        $isIntl = PVPHelper::isIntl($userId);
        $mult   = $isIntl ? PVPHelper::UNTX_MULTIPLIER : 1;

        try {
            $db = Database::get();

            $row = $db->selectSingle(
                "SELECT `pvp_points` FROM %%USERS%% WHERE `id` = :uid LIMIT 1;",
                array(':uid' => $userId)
            );
            $stats['points'] = empty($row) ? 0 : (int) $row['pvp_points'];

            // 🆕 Victorias + NTX ganados por riel
            $rows = $db->select(
                "SELECT a.`mode`, a.`prize_pool`, a.`pool_ntx20`, a.`pool_untx20`
                 FROM %%PVP_ARENAS%% a
                 INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
                 WHERE ap.`user_id` = :uid 
                   AND a.`status` = 'finished'
                   AND ap.`team` = a.`winner_team';",
                array(':uid' => $userId)
            );

            foreach ($rows as $r) {
                $stats['wins']++;
                $mode = $r['mode'];
                if ($mode === '1v1') $stats['arena_wins_1v1']++;
                if ($mode === '2v2') $stats['arena_wins_2v2']++;
                if ($mode === '3v3') $stats['arena_wins_3v3']++;

                // 🆕 Pool del riel del jugador
                $poolRiel = $isIntl
                    ? (int) $r['pool_untx20']
                    : (int) $r['pool_ntx20'];

                // Contar ganadores del mismo riel para dividir
                $teamSize   = PVPHelper::getModeTeamSize($mode);
                $winnerDiv  = max(1, $teamSize);

                $stats['ntx_won'] += (int) floor($poolRiel / $winnerDiv);
            }

            $row = $db->selectSingle(
                "SELECT COUNT(*) AS c 
                 FROM %%PVP_ARENAS%% a
                 INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
                 WHERE ap.`user_id` = :uid 
                   AND a.`status` = 'finished'
                   AND ap.`team` != a.`winner_team';",
                array(':uid' => $userId)
            );
            $stats['losses'] = empty($row) ? 0 : (int) $row['c'];

            $row = $db->selectSingle(
                "SELECT COUNT(*) AS c 
                 FROM %%PVP_TOURNAMENT_PLAYERS%% tp
                 INNER JOIN %%PVP_TOURNAMENTS%% t ON t.`id` = tp.`tournament_id`
                 WHERE tp.`user_id` = :uid 
                   AND tp.`final_position` = 1 
                   AND t.`status` = 'finished';",
                array(':uid' => $userId)
            );
            $stats['tournaments_won'] = empty($row) ? 0 : (int) $row['c'];

            $rows = $db->select(
                "SELECT a.`id`, a.`finished_at`, 
                        (ap.`team` = a.`winner_team`) AS won
                 FROM %%PVP_ARENAS%% a
                 INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
                 WHERE ap.`user_id` = :uid 
                   AND a.`status` = 'finished'
                 ORDER BY a.`finished_at` ASC;",
                array(':uid' => $userId)
            );

            $streak = 0;
            $best   = 0;
            foreach ($rows as $r) {
                if ((int) $r['won'] === 1) {
                    $streak++;
                    if ($streak > $best) $best = $streak;
                } else {
                    $streak = 0;
                }
            }
            $stats['best_streak'] = $best;

            // 🆕 Entrada pagada en el riel del jugador (×2 si QVAPAY)
            $row = $db->selectSingle(
                "SELECT COALESCE(SUM(`entry_fee`),0) AS total 
                 FROM %%PVP_ARENA_PLAYERS%% ap
                 INNER JOIN %%PVP_ARENAS%% a ON a.`id` = ap.`arena_id`
                 WHERE ap.`user_id` = :uid AND a.`status` = 'finished' AND ap.`paid` > 0;",
                array(':uid' => $userId)
            );
            $stats['ntx_lost'] = empty($row) ? 0 : ((int) $row['total'] * $mult);

        } catch (Exception $e) {}

        return $stats;
    }
}