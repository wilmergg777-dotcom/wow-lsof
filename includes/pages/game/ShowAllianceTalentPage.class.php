<?php
/**
 * ShowAllianceTalentPage - Arbol de Talentos de Alianza (jugador)
 * AstroIO v2.0 (2026-10-30) - DUAL RIEL
 *
 * v2.0:
 *  - Detecta el riel del jugador (CUP / QVAPAY).
 *  - Pasa al template: $moneda, $moneda_fiat, $es_internacional,
 *    $saldo_actual, $reset_cost_user, $can_afford_reset, $has_talents.
 *  - doReset() recarga el saldo del jugador antes de llamar al Helper.
 *  - El resto del sistema (puntos, rangos, bonus, historial) NO toca
 *    moneda y queda igual.
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

require_once 'includes/classes/AllianceTalentHelper.class.php';

class ShowAllianceTalentPage extends AbstractGamePage
{
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER;

        $allianceId = isset($USER['ally_id']) ? (int)$USER['ally_id'] : 0;
        if ($allianceId <= 0) {
            HTTP::redirectTo('game.php?page=alliance');
            exit;
        }

        $mode = HTTP::_GP('mode', 'main');

        switch ($mode) {
            case 'doSetTalent': $this->doSetTalent($allianceId); return;
            case 'doReset':     $this->doReset($allianceId);     return;
        }

        $this->renderMain($allianceId);
    }

    /* ============================================================
     * VISTA PRINCIPAL
     * ============================================================ */

    private function renderMain($allianceId)
    {
        global $USER;

        $userId = (int)$USER['id'];

        // ============================================
        // 🆕 v2.0 — DETECCIÓN DE RIEL DEL JUGADOR
        // ============================================
        $isIntl      = AllianceTalentHelper::isIntl($userId);
        $moneda      = $isIntl ? 'UNTX-20' : 'NTX-20';
        $monedaFiat  = $isIntl ? 'USD'     : 'CUP';
        $colBalance  = $isIntl ? 'untx20'  : 'ntx20';
        $saldoActual = $isIntl ? (int)($USER['untx20'] ?? 0) : (int)($USER['ntx20'] ?? 0);

        // ============================================
        // Datos base (SIN CAMBIOS)
        // ============================================
        $data          = AllianceTalentHelper::getPoints($allianceId);
        $ranks         = AllianceTalentHelper::getRanks($allianceId);
        $info          = AllianceTalentHelper::getAllianceInfo($allianceId);
        $isLeader      = AllianceTalentHelper::isLeader($userId, $allianceId);
        $activeBonuses = AllianceTalentHelper::getActiveBonuses($allianceId);

        $available = (int)$data['total_points'] - (int)$data['spent_points'];

        $allianceName = !empty($info) ? $info['ally_name'] : '';
        $allianceTag  = !empty($info) ? $info['ally_tag']  : '';

        // ============================================
        // Preparar los 7 rangos con sus opciones
        // ============================================
        $rankData = array();

        foreach (AllianceTalentHelper::TALENTS as $rn => $talents) {
            $cost   = AllianceTalentHelper::RANK_COSTS[$rn];
            $nivel  = AllianceTalentHelper::RANK_LEVELS[$rn];
            $chosen = isset($ranks[$rn]) ? $ranks[$rn]['talent_key'] : null;

            $options = array();
            foreach ($talents as $key => $t) {
                $options[] = array(
                    'key'      => $key,
                    'name'     => $t['name'],
                    'icon'     => $t['icon'],
                    'type'     => $t['type'],
                    'value'    => $t['value'],
                    'selected' => ($chosen === $key),
                );
            }

            $prevChosen = ($rn == 1) ? true : isset($ranks[$rn - 1]);
            $canChoose  = $isLeader && !$chosen && $prevChosen && ($available >= $cost);

            $rankData[] = array(
                'num'         => $rn,
                'level'       => $nivel,
                'cost'        => $cost,
                'cost_fmt'    => number_format($cost),
                'chosen'      => $chosen,
                'options'     => $options,
                'can_choose'  => $canChoose,
                'prev_chosen' => $prevChosen,
            );
        }

        // ============================================
        // 🆕 v2.0 — CÁLCULO DEL RESET (dual riel)
        // ============================================
        // Coste base (NTX-20) y coste final para el jugador (×2 si QVAPAY)
        $resetCostBase = AllianceTalentHelper::RESET_COST;
        $resetCostUser = $isIntl ? ($resetCostBase * AllianceTalentHelper::UNTX_MULTIPLIER) : $resetCostBase;
        $canAffordReset = ($saldoActual >= $resetCostUser);

        // ¿Hay talentos elegidos? (para saber si mostrar el botón de reset)
        $hasTalents = !empty($ranks);

        // Historial
        $history = AllianceTalentHelper::getHistory($allianceId, 50);

        // Mensajes flash
        $msg     = HTTP::_GP('msg', '');
        $msgType = HTTP::_GP('msg_type', 'info');

        $this->tplObj->assign_vars(array(
            // Info general
            'alliance_id'      => $allianceId,
            'alliance_name'    => $allianceName,
            'alliance_tag'     => $allianceTag,
            'is_leader'        => $isLeader,

            // 🆕 v2.0 — DUAL RIEL (variables canónicas)
            'moneda'           => $moneda,           // 'NTX-20' | 'UNTX-20'
            'moneda_fiat'      => $monedaFiat,       // 'CUP' | 'USD'
            'es_internacional' => $isIntl,
            'saldo_actual'     => $saldoActual,
            'col_balance'      => $colBalance,

            // Puntos
            'total_points'     => (int)$data['total_points'],
            'total_points_fmt' => number_format((int)$data['total_points']),
            'spent_points'     => (int)$data['spent_points'],
            'spent_points_fmt' => number_format((int)$data['spent_points']),
            'available_points' => $available,
            'available_fmt'    => number_format($available),
            'current_rank'     => (int)$data['current_rank'],

            // Arbol
            'rank_data'        => $rankData,

            // Bonuses activos
            'active_bonuses'   => $activeBonuses,

            // 🆕 v2.0 — RESET (dual riel)
            'reset_cost'       => $resetCostBase,             // Base NTX-20 (compat)
            'reset_cost_user'  => $resetCostUser,             // ⚠️ Coste final para el jugador
            'reset_cost_user_fmt' => number_format($resetCostUser),
            'can_afford_reset' => $canAffordReset,
            'has_talents'      => $hasTalents,

            // Limite diario
            'max_daily'        => AllianceTalentHelper::MAX_DAILY_POINTS,
            'daily_used'       => AllianceTalentHelper::getDailyUsed($userId),

            // Historial
            'history'          => $history,

            // Mensajes
            'msg'              => $msg,
            'msg_type'         => $msgType,
        ));

        $this->display('page.alliancetalent.default.tpl');
    }

    /* ============================================================
     * ACCIONES
     * ============================================================ */

    private function doSetTalent($allianceId)
    {
        global $USER;

        if (!AllianceTalentHelper::isLeader((int)$USER['id'], $allianceId)) {
            $this->redirectWithMsg(array('ok' => false, 'msg' => 'Solo el lider puede asignar talentos.'));
            return;
        }

        $rank = (int)HTTP::_GP('rank', 0);
        $key  = HTTP::_GP('talent', '');

        $res = AllianceTalentHelper::setTalent($allianceId, $rank, $key, (int)$USER['id']);

        $this->redirectWithMsg($res);
    }

    private function doReset($allianceId)
    {
        global $USER;

        if (!AllianceTalentHelper::isLeader((int)$USER['id'], $allianceId)) {
            $this->redirectWithMsg(array('ok' => false, 'msg' => 'Solo el lider puede resetear.'));
            return;
        }

        // 🆕 v2.0 — Recargar saldo fresco desde BD antes de llamar al Helper
        // (evita usar una caché de sesión desactualizada)
        $db     = Database::get();
        $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
        try {
            $row = $db->selectSingle(
                "SELECT `ntx20`, `untx20`, `metodo_retiro` FROM `".$prefix."users` WHERE `id` = '".(int)$USER['id']."' LIMIT 1;"
            );
            if (!empty($row)) {
                $USER['ntx20']  = (int)($row['ntx20']  ?? 0);
                $USER['untx20'] = (int)($row['untx20'] ?? 0);
                if (isset($row['metodo_retiro'])) {
                    $USER['metodo_retiro'] = $row['metodo_retiro'];
                }
            }
        } catch (Exception $e) {
            // silencioso: si falla, el Helper igual re-lee la BD
        }

        $res = AllianceTalentHelper::resetTalents($allianceId, (int)$USER['id'], $USER);

        $this->redirectWithMsg($res);
    }

    /* ============================================================
     * HELPERS
     * ============================================================ */

    private function redirectWithMsg($res)
    {
        $msg  = urlencode($res['msg']);
        $type = !empty($res['ok']) ? 'ok' : 'error';
        HTTP::redirectTo('game.php?page=allianceTalent&msg='.$msg.'&msg_type='.$type);
    }
}