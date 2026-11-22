<?php
/**
 *  AstroIO - MOP Raza y Facción
 *  Archivo: includes/pages/game/ShowRacefactionPage.class.php
 *  URL:     game.php?page=racefaction
 *  Compatible con 2Moons 2.0.git (PDO)
 */

class ShowRacefactionPage extends AbstractGamePage
{
    function __construct()
    {
        parent::__construct();
    }

    /**
     * Obtiene el prefijo de las tablas.
     */
    private function getPrefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    public function show()
    {
        global $USER, $LNG, $db;

        $prefix = $this->getPrefix();

        $action    = HTTP::_GP('action', '');
        $raceId    = (int) HTTP::_GP('race_id', 0);
        $factionId = (int) HTTP::_GP('faction_id', 0);
        $message   = '';
        $msgType   = 'info';

        // ============================================
        // PROCESAR SELECCIÓN
        // ============================================
        if ($action === 'select') {

            if ($USER['race_id'] != 0 || $USER['faction_id'] != 0) {
                $message = isset($LNG['ra_already_chosen']) ? $LNG['ra_already_chosen'] : 'Ya has elegido tu raza y facción.';
                $msgType = 'error';
            }
            elseif ($raceId <= 0 || $factionId <= 0) {
                $message = isset($LNG['ra_select_both']) ? $LNG['ra_select_both'] : 'Debes seleccionar una raza y una facción.';
                $msgType = 'error';
            }
            else {
                // Validar que la raza existe
                $raceOk = $db->selectSingle(
                    "SELECT COUNT(*) as cnt FROM `".$prefix."races` WHERE race_id = :rid;",
                    array(':rid' => $raceId),
                    'cnt'
                );

                // Validar que la facción existe
                $factionOk = $db->selectSingle(
                    "SELECT COUNT(*) as cnt FROM `".$prefix."factions` WHERE faction_id = :fid;",
                    array(':fid' => $factionId),
                    'cnt'
                );

                if ($raceOk && $factionOk) {
                    $db->update(
                        "UPDATE `".$prefix."users` SET
                            race_id        = :rid,
                            faction_id     = :fid,
                            race_chosen_at = :time
                         WHERE id = :uid;",
                        array(
                            ':rid'  => $raceId,
                            ':fid'  => $factionId,
                            ':time' => TIMESTAMP,
                            ':uid'  => $USER['id']
                        )
                    );

                    $USER['race_id']    = $raceId;
                    $USER['faction_id'] = $factionId;

                    // ✅ v4.0 — Onboarding completo: tras elegir raza+facción
                    // el jugador va DIRECTO a la vista principal (overview).
                    HTTP::redirectTo('game.php?page=overview');

                    $message = isset($LNG['ra_success']) ? $LNG['ra_success'] : 'Elección confirmada.';
                    $msgType = 'success';
                } else {
                    $message = isset($LNG['ra_invalid']) ? $LNG['ra_invalid'] : 'Selección inválida.';
                    $msgType = 'error';
                }
            }
        }

        // ============================================
        // CARGAR RAZAS Y FACCIONES
        // ============================================
        $races    = $db->select("SELECT * FROM `".$prefix."races` ORDER BY race_id ASC;");
        $factions = $db->select("SELECT * FROM `".$prefix."factions` ORDER BY faction_id ASC;");

        if (!is_array($races))    $races = array();
        if (!is_array($factions)) $factions = array();

        // ============================================
        // ESTADO DEL JUGADOR
        // ============================================
        $hasChosen = (isset($USER['race_id']) && $USER['race_id'] != 0)
                  || (isset($USER['faction_id']) && $USER['faction_id'] != 0);

        $myRace    = null;
        $myFaction = null;

        if ($hasChosen) {
            foreach ($races as $r) {
                if ($r['race_id'] == $USER['race_id']) $myRace = $r;
            }
            foreach ($factions as $f) {
                if ($f['faction_id'] == $USER['faction_id']) $myFaction = $f;
            }
        }

        // ============================================
        // ASIGNAR VARIABLES A LA PLANTILLA
        // ============================================
        $this->assign(array(
            'races'        => $races,
            'factions'     => $factions,
            'hasChosen'    => $hasChosen,
            'myRace'       => $myRace,
            'myFaction'    => $myFaction,
            'message'      => $message,
            'msgType'      => $msgType,
            'ra_pageTitle' => isset($LNG['ra_page_title']) ? $LNG['ra_page_title'] : 'Raza y Facción',
        ));

        $this->display('page.racefaction.default.tpl');
    }
}