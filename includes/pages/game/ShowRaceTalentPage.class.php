<?php
/**
 * ShowRaceTalentPage - Arbol de Talentos de RAZA (jugador)
 * AstroIO v2.6 — integrado al repositorio testeo en v2.4.10 (2026-11-27)
 *
 * URL: game.php?page=raceTalent
 *
 * Sistema tipo WoW:
 *  - Cada raza tiene 6 talentos en 3 filas (3 / 2 / 1).
 *  - El jugador reparte 11 puntos (TOTAL_POINTS).
 *  - Fila 2 se desbloquea con 2 puntos en la Fila 1;
 *    Fila 3 con 2 puntos en la Fila 2 (RaceTalentHelper::ROW_GATE).
 *  - Al cambiar de raza (ShowRacePage) se borra TODO (wipe):
 *    el arbol empieza DESDE 0 en la nueva raza (v2.4.10).
 *  - Los bonus se suman en RaceFactionHelper y se aplican en todo el juego.
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

require_once 'includes/classes/RaceTalentHelper.class.php';

class ShowRaceTalentPage extends AbstractGamePage
{
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER;

        $userId   = (int)$USER['id'];
        $raceId   = isset($USER['race_id']) ? (int)$USER['race_id'] : RaceTalentHelper::getRaceId($userId);

        // Sin raza elegida: mandar a la pagina de razas
        if ($raceId <= 0) {
            HTTP::redirectTo('game.php?page=race');
            exit;
        }

        $mode = HTTP::_GP('mode', 'main');

        switch ($mode) {
            case 'doAdd':    $this->doSet($userId, 'add');    return;
            case 'doRemove': $this->doSet($userId, 'remove'); return;
        }

        $this->renderMain($userId, $raceId);
    }

    /* ============================================================
     * VISTA PRINCIPAL
     * ============================================================ */

    private function renderMain($userId, $raceId)
    {
        global $LNG;

        $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
        $race   = Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."races` WHERE `race_id` = '".(int)$raceId."' LIMIT 1;"
        );

        if (empty($race)) {
            HTTP::redirectTo('game.php?page=race');
            exit;
        }

        // Arbol con estados
        $structure = RaceTalentHelper::getStructure($userId);

        // Bonus actual SOLO por talentos (lo que agrega el arbol)
        $talentBonus = RaceTalentHelper::getBonusesForUser($userId, $raceId);
        $bonusList = array();
        foreach ($talentBonus as $col => $val) {
            $bonusList[] = array(
                'label' => RaceTalentHelper::bonusLabel($col),
                'val'   => (float)$val,
            );
        }

        // Bonus base de la raza (los que venia teniendo)
        $raceBonus = array();
        foreach ($race as $key => $val) {
            if (strpos($key, 'bonus_') === 0 && is_numeric($val) && (float)$val != 0) {
                $raceBonus[] = array(
                    'label' => RaceTalentHelper::bonusLabel($key),
                    'val'   => (float)$val,
                );
            }
        }

        $msg     = HTTP::_GP('msg', '');
        $msgType = HTTP::_GP('msg_type', 'info');

        $this->assign(array(
            'race'            => $race,
            'race_color'      => !empty($race['race_color']) ? $race['race_color'] : '#00ccff',
            'race_icon'       => $race['race_icon'],
            'race_name'       => $race['race_name'],
            'race_desc'       => $race['race_desc'],

            // Arbol
            'rows'            => $structure['rows'],
            'spent'           => $structure['spent'],
            'available'       => $structure['available'],
            'total_points'    => $structure['total'],
            'max_per'         => $structure['max_per'],
            'gate_2'          => $structure['gate_2'],
            'gate_3'          => $structure['gate_3'],

            // Bonus
            'talent_bonus'    => $bonusList,
            'race_bonus'      => $raceBonus,

            // Mensajes
            'message'         => $msg,
            'msgType'         => $msgType,
            'pageTitle'       => 'Talentos de Raza',
        ));

        $this->display('page.racetalent.default.tpl');
    }

    /* ============================================================
     * ACCIONES
     * ============================================================ */

    private function doSet($userId, $action)
    {
        $key = HTTP::_GP('talent', '');

        $res = RaceTalentHelper::setPoint($userId, $key, $action);

        $msg  = urlencode($res['msg']);
        $type = !empty($res['ok']) ? 'ok' : 'error';
        HTTP::redirectTo('game.php?page=raceTalent&msg='.$msg.'&msg_type='.$type);
    }
}
