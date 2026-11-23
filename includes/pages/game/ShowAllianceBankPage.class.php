<?php
/**
 * ShowAllianceBankPage - Pagina del Banco de Alianza (jugador)
 * AstroIO v2.0 (2026-10-30) - DUAL RIEL
 *
 * Cambios v2.0:
 *  - Detecta el riel del jugador (CUP o QVAPAY) usando AllianceBankHelper.
 *  - Pasa al template: $moneda, $moneda_fiat, $es_internacional, $saldo_actual.
 *  - Pasa el bolsillo VISIBLE (solo del riel del jugador): $bank_visible.
 *  - Pasa AMBOS bolsillos para el líder: $bank_ntx, $bank_untx.
 *  - Costos de upgrade pre-calculados: $upgrade_cost_base (NTX-20) y
 *    $upgrade_cost_user (× 2 si QVAPAY).
 *  - Historial procesado con recurso_label dinámico (NTX-20 / UNTX-20).
 *  - Mensajes de éxito/error con la moneda correcta.
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

require_once 'includes/classes/AllianceBankHelper.class.php';

class ShowAllianceBankPage extends AbstractGamePage
{
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER, $PLANET, $LNG;

        $allianceId = isset($USER['ally_id']) ? (int)$USER['ally_id'] : 0;
        if ($allianceId <= 0) {
            $this->printMessage('No perteneces a ninguna alianza.', true, 'game.php?page=overview');
            return;
        }

        $mode = HTTP::_GP('mode', 'main');

        switch ($mode) {
            case 'doDeposit':        $this->doDeposit($allianceId);        return;
            case 'doWithdraw':       $this->doWithdraw($allianceId);       return;
            case 'setTesorero':      $this->doSetTesorero($allianceId);    return;
            case 'removeTesorero':   $this->doRemoveTesorero($allianceId); return;
            case 'setDailyLimit':    $this->doSetDailyLimit($allianceId);  return;
            case 'upgrade':          $this->doUpgrade($allianceId);        return;
        }

        $this->renderMain($allianceId);
    }

    /* ============================================================
     * VISTA PRINCIPAL
     * ============================================================ */

    private function renderMain($allianceId)
    {
        global $USER, $PLANET;

        $bank   = AllianceBankHelper::getBank($allianceId);
        $userId = (int)$USER['id'];

        // ============================================
        // 🆕 v2.0 — DETECCIÓN DE RIEL DEL JUGADOR
        // ============================================
        $isIntl      = AllianceBankHelper::isIntl($userId);
        $moneda      = $isIntl ? 'UNTX-20' : 'NTX-20';
        $monedaFiat  = $isIntl ? 'USD'     : 'CUP';
        $colBalance  = $isIntl ? 'untx20'  : 'ntx20';
        $saldoActual = $isIntl ? (int)($USER['untx20'] ?? 0) : (int)($USER['ntx20'] ?? 0);

        // ============================================
        // Líder y permisos
        // ============================================
        $isLeader = AllianceBankHelper::isLeader($userId, $allianceId);
        $canWithdraw = AllianceBankHelper::canWithdraw($userId, $bank);

        // ============================================
        // Info de la alianza
        // ============================================
        $allianceInfo = AllianceBankHelper::getAllianceInfo($allianceId);
        $allianceName = !empty($allianceInfo) ? $allianceInfo['ally_name'] : '';
        $allianceTag  = !empty($allianceInfo) ? $allianceInfo['ally_tag']  : '';

        // ============================================
        // Capacidad y límites
        // ============================================
        $capacity    = AllianceBankHelper::getCapacity($bank['level']);
        $dailyLimit  = (int)$bank['daily_limit'];
        $dailyUsed   = AllianceBankHelper::getDailyUsed($userId);
        $dailyLeft   = $dailyLimit > 0 ? max(0, $dailyLimit - $dailyUsed) : 0;

        // ============================================
        // 🆕 v2.0 — BOLSILLOS DEL BANCO
        // ============================================
        // Bolsillo del riel del jugador (el que puede tocar)
        $bankVisible = $isIntl ? (int)$bank['untx20'] : (int)$bank['ntx20'];

        // Ambos bolsillos (para el líder que puede ver ambos)
        $bankNtx  = (int)$bank['ntx20'];
        $bankUntx = (int)$bank['untx20'];

        // ============================================
        // 🆕 v2.0 — COSTOS DE UPGRADE (dual riel)
        // ============================================
        $upgradeCostBase = AllianceBankHelper::getUpgradeCost($bank['level']);
        $isMaxLevel      = ((int)$bank['level'] >= 25);

        // Costo si el LÍDER paga desde su cuenta (×2 si es QVAPAY)
        $upgradeCostUser = $isIntl ? ($upgradeCostBase * AllianceBankHelper::UNTX_MULTIPLIER) : $upgradeCostBase;

        // ¿Puede permitirse?
        $canAffordUser = ($saldoActual >= $upgradeCostUser);

        // ¿Puede pagar el banco? (prueba ambos bolsillos, mismo criterio que el Helper)
        $canAffordBank = ($bankNtx >= $upgradeCostBase) || ($bankUntx >= ($upgradeCostBase * AllianceBankHelper::UNTX_MULTIPLIER));

        // ============================================
        // Listas
        // ============================================
        $members = $this->getAllianceMembers($allianceId);
        $history = AllianceBankHelper::getHistory($allianceId, 100);
        $planets = $this->getUserPlanets($userId);

        // ============================================
        // 🆕 v2.0 — HISTORIAL PROCESADO (recurso_label dinámico)
        // ============================================
        if (!empty($history)) {
            foreach ($history as &$h) {
                $rec = isset($h['recurso']) ? $h['recurso'] : '';
                if ($rec === 'ntx20' || $rec === 'untx20') {
                    // Mostrar según el riel del VISOR (aproximación práctica)
                    $h['recurso_label'] = $moneda;
                } elseif ($rec === 'darkmatter') {
                    $h['recurso_label'] = 'Materia Oscura';
                } elseif ($rec === 'metal') {
                    $h['recurso_label'] = 'Metal';
                } elseif ($rec === 'crystal') {
                    $h['recurso_label'] = 'Cristal';
                } elseif ($rec === 'deuterium') {
                    $h['recurso_label'] = 'Deuterio';
                } elseif ($rec === 'norium') {          // 🆕 v2.6
                    $h['recurso_label'] = 'Norium';
                } elseif ($rec === 'germanium') {       // 🆕 v2.6
                    $h['recurso_label'] = 'Germanio';
                } else {
                    $h['recurso_label'] = $rec;
                }
                // Campo amigable para la cantidad
                $h['cantidad_fmt'] = isset($h['cantidad']) ? number_format((int)$h['cantidad']) : '0';
            }
            unset($h);
        }

        // Mensajes flash
        $msg     = HTTP::_GP('msg', '');
        $msgType = HTTP::_GP('msg_type', 'info');

        $this->tplObj->assign_vars([
            // Info general
            'alliance_id'         => $allianceId,
            'alliance_name'       => $allianceName,
            'alliance_tag'        => $allianceTag,
            'is_leader'           => $isLeader,
            'can_withdraw'        => $canWithdraw,
            'tesorero_id'         => (int)$bank['tesorero_id'],

            // 🆕 v2.0 — DUAL RIEL (variables canónicas)
            'moneda'              => $moneda,             // 'NTX-20' | 'UNTX-20'
            'moneda_fiat'         => $monedaFiat,         // 'CUP' | 'USD'
            'es_internacional'    => $isIntl,
            'saldo_actual'        => $saldoActual,
            'col_balance'         => $colBalance,

            // Bóveda (completa + bolsillo visible)
            'bank'                => $bank,
            'bank_visible'        => $bankVisible,        // ⚠️ Solo el bolsillo del riel del jugador
            'bank_visible_fmt'    => number_format($bankVisible),
            'bank_ntx'            => $bankNtx,            // ⚠️ Para el líder
            'bank_untx'           => $bankUntx,           // ⚠️ Para el líder
            'bank_ntx_fmt'        => number_format($bankNtx),
            'bank_untx_fmt'       => number_format($bankUntx),

            'capacity'            => $capacity,
            'capacity_fmt'        => number_format($capacity),
            'max_level'           => 25,
            'is_max_level'        => $isMaxLevel,

            // 🆕 v2.0 — Upgrade con doble riel
            'upgrade_cost'        => $upgradeCostBase,             // NTX-20 (base)
            'upgrade_cost_fmt'    => number_format($upgradeCostBase),
            'upgrade_cost_user'   => $upgradeCostUser,             // Costo para el jugador (×2 si QVAPAY)
            'upgrade_cost_user_fmt' => number_format($upgradeCostUser),
            'can_afford_user'     => $canAffordUser,
            'can_afford_bank'     => $canAffordBank,

            // Límites diarios
            'daily_limit'         => $dailyLimit,
            'daily_limit_fmt'     => number_format($dailyLimit),
            'daily_used'          => $dailyUsed,
            'daily_used_fmt'      => number_format($dailyUsed),
            'daily_left'          => $dailyLeft,
            'daily_left_fmt'      => number_format($dailyLeft),
            'has_daily_limit'     => ($dailyLimit > 0),

            // Listas
            'members'             => $members,
            'history'             => $history,
            'planets'             => $planets,

            // Planeta actual
            'current_planet'      => [
                'id'        => $PLANET['id'],
                'name'      => $PLANET['name'],
                'galaxy'    => $PLANET['galaxy'],
                'system'    => $PLANET['system'],
                'planet'    => $PLANET['planet'],
                'metal'     => $PLANET['metal'],
                'crystal'   => $PLANET['crystal'],
                'deuterium' => $PLANET['deuterium'],
                // 🆕 v2.6 — Recursos nuevos del planeta actual
                'norium'    => isset($PLANET['norium']) ? $PLANET['norium'] : 0,
                'germanium' => isset($PLANET['germanium']) ? $PLANET['germanium'] : 0,
            ],

            // Compatibilidad con template viejo
            'user_ntx20'          => (int)($USER['ntx20']      ?? 0),
            'user_untx20'         => (int)($USER['untx20']     ?? 0),
            'user_darkmatter'     => (int)($USER['darkmatter'] ?? 0),

            // Mensajes
            'msg'                 => $msg,
            'msg_type'            => $msgType,
        ]);

        $this->display('page.alliancebank.default.tpl');
    }

    /* ============================================================
     * ACCIONES
     * ============================================================ */

    private function doDeposit($allianceId)
    {
        global $USER, $PLANET;

        $recurso  = HTTP::_GP('recurso', 'metal');
        $cantidad = (int)HTTP::_GP('cantidad', 0);

        $res = AllianceBankHelper::deposit((int)$USER['id'], $allianceId, $recurso, $cantidad, $PLANET);

        $this->redirectWithMsg($res);
    }

    private function doWithdraw($allianceId)
    {
        global $USER;

        $recurso  = HTTP::_GP('recurso', 'metal');
        $cantidad = (int)HTTP::_GP('cantidad', 0);
        $planetId = (int)HTTP::_GP('planet_id', 0);

        $res = AllianceBankHelper::withdraw((int)$USER['id'], $allianceId, $recurso, $cantidad, $planetId);

        $this->redirectWithMsg($res);
    }

    private function doSetTesorero($allianceId)
    {
        global $USER;

        if (!AllianceBankHelper::isLeader((int)$USER['id'], $allianceId)) {
            $this->redirectWithMsg(['ok' => false, 'msg' => 'Solo el lider puede asignar tesorero.']);
            return;
        }

        $newId = (int)HTTP::_GP('tesorero_id', 0);
        $res   = AllianceBankHelper::setTesorero($allianceId, $newId, (int)$USER['id']);

        $this->redirectWithMsg($res);
    }

    private function doRemoveTesorero($allianceId)
    {
        global $USER;

        if (!AllianceBankHelper::isLeader((int)$USER['id'], $allianceId)) {
            $this->redirectWithMsg(['ok' => false, 'msg' => 'Solo el lider puede quitar el tesorero.']);
            return;
        }

        $res = AllianceBankHelper::removeTesorero($allianceId, (int)$USER['id']);

        $this->redirectWithMsg($res);
    }

    private function doSetDailyLimit($allianceId)
    {
        global $USER;

        if (!AllianceBankHelper::isLeader((int)$USER['id'], $allianceId)) {
            $this->redirectWithMsg(['ok' => false, 'msg' => 'Solo el lider puede cambiar el limite diario.']);
            return;
        }

        $limit = (int)HTTP::_GP('daily_limit', 0);
        $res   = AllianceBankHelper::setDailyLimit($allianceId, $limit, (int)$USER['id']);

        $this->redirectWithMsg($res);
    }

    private function doUpgrade($allianceId)
    {
        global $USER;

        if (!AllianceBankHelper::isLeader((int)$USER['id'], $allianceId)) {
            $this->redirectWithMsg(['ok' => false, 'msg' => 'Solo el lider puede ampliar el banco.']);
            return;
        }

        // 'bank' = intenta bolsillo ntx20, si no alcanza prueba untx20 (×2)
        // 'user' = usa el riel del lider (coste ×2 si QVAPAY)
        $source = HTTP::_GP('source', 'bank');

        $res = AllianceBankHelper::upgrade($allianceId, (int)$USER['id'], $source);

        $this->redirectWithMsg($res);
    }

    /* ============================================================
     * HELPERS INTERNOS
     * ============================================================ */

    private function redirectWithMsg($res)
    {
        $msg  = urlencode($res['msg']);
        $type = !empty($res['ok']) ? 'ok' : 'error';
        HTTP::redirectTo('game.php?page=allianceBank&msg='.$msg.'&msg_type='.$type);
    }

    private function getAllianceMembers($allianceId)
    {
        $p = DB_PREFIX;
        return Database::get()->select("SELECT `id`, `username`, `ally_rank_id` FROM `".$p."users` WHERE `ally_id` = '".(int)$allianceId."' ORDER BY `ally_rank_id` ASC, `username` ASC;");
    }

    private function getUserPlanets($userId)
    {
        $p = DB_PREFIX;
        return Database::get()->select("SELECT `id`, `name`, `galaxy`, `system`, `planet`, `metal`, `crystal`, `deuterium`, `norium`, `germanium` FROM `".$p."planets` WHERE `id_owner` = '".(int)$userId."' AND `planet_type` = '1' ORDER BY `id` ASC;");
    }
}