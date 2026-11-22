<?php
/**
 *  AstroIO - Página de Razas
 *  Archivo: includes/pages/game/ShowRacePage.class.php
 *  URL:     game.php?page=race
 *  Compatible con 2Moons 2.0.git (PDO)
 *
 *  Reglas:
 *   - 1ª elección: GRATIS
 *   - Cambios posteriores: 5.000 DM
 *   - Se cobra al pulsar "Confirmar"
 */

class ShowRacePage extends AbstractGamePage
{
    /**
     * Coste en Materia Oscura para cambiar de raza
     */
    const CHANGE_COST_DM = 5000;

    function __construct()
    {
        parent::__construct();
    }

    /**
     * Prefijo de las tablas
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

        $action  = HTTP::_GP('action', '');
        $raceId  = (int) HTTP::_GP('race_id', 0);
        $message = '';
        $msgType = 'info';

        // ¿Ya tiene raza elegida?
        $alreadyChosen = (isset($USER['race_id']) && $USER['race_id'] != 0);

        // ============================================
        // PROCESAR SELECCIÓN / CAMBIO
        // ============================================
        if ($action === 'select' && $raceId > 0) {

            // Validar que la raza existe
            $raceExists = $db->selectSingle(
                "SELECT COUNT(*) as cnt FROM `".$prefix."races` WHERE race_id = :rid;",
                array(':rid' => $raceId),
                'cnt'
            );

            if (!$raceExists) {
                $message = '❌ Raza inválida.';
                $msgType = 'error';
            }
            else {
                // ---------- PRIMERA VEZ: GRATIS ----------
                if (!$alreadyChosen) {
                    $db->update(
                        "UPDATE `".$prefix."users` SET
                            race_id        = :rid,
                            race_chosen_at = :time
                         WHERE id = :uid;",
                        array(
                            ':rid'  => $raceId,
                            ':time' => TIMESTAMP,
                            ':uid'  => $USER['id']
                        )
                    );

                    $USER['race_id'] = $raceId;

                    $message = '✅ ¡Raza elegida! Esta decisión es permanente, salvo pago de Materia Oscura.';
                    $msgType = 'success';
                }
                // ---------- CAMBIO: PAGA 5.000 DM ----------
                else {
                    // Comprobar saldo de DM (recurso 921)
                    $currentDM = isset($USER['darkmatter']) ? (int)$USER['darkmatter'] : 0;

                    if ($currentDM < self::CHANGE_COST_DM) {
                        $message = '❌ Necesitas '.number_format(self::CHANGE_COST_DM, 0, ',', '.').' de Materia Oscura para cambiar de raza. Tienes: '.number_format($currentDM, 0, ',', '.').'.';
                        $msgType = 'error';
                    }
                    else {
                        // Restar DM y actualizar raza
                        $db->update(
                            "UPDATE `".$prefix."users` SET
                                race_id        = :rid,
                                race_chosen_at = :time,
                                darkmatter     = darkmatter - :cost
                             WHERE id = :uid;",
                            array(
                                ':rid'  => $raceId,
                                ':time' => TIMESTAMP,
                                ':cost' => self::CHANGE_COST_DM,
                                ':uid'  => $USER['id']
                            )
                        );

                        $USER['race_id']    = $raceId;
                        $USER['darkmatter'] = $currentDM - self::CHANGE_COST_DM;

                        $message = '✅ ¡Raza cambiada! Se han descontado '.number_format(self::CHANGE_COST_DM, 0, ',', '.').' de Materia Oscura.';
                        $msgType = 'success';
                    }
                }

                // Recargar estado
                $alreadyChosen = true;
            }
        }

        // ============================================
        // CARGAR RAZAS
        // ============================================
        $races = $db->select("SELECT * FROM `".$prefix."races` ORDER BY race_id ASC;");
        if (!is_array($races)) $races = array();

        // ============================================
        // DATOS DEL JUGADOR
        // ============================================
        $myRace       = null;
        $currentDM    = isset($USER['darkmatter']) ? (int)$USER['darkmatter'] : 0;

        if ($alreadyChosen) {
            foreach ($races as $r) {
                if ($r['race_id'] == $USER['race_id']) $myRace = $r;
            }
        }

        $canChange = ($alreadyChosen && $currentDM >= self::CHANGE_COST_DM);

        // ============================================
        // ASIGNAR AL TEMPLATE
        // ============================================
        $this->assign(array(
            'races'         => $races,
            'hasChosen'     => $alreadyChosen,
            'myRace'        => $myRace,
            'message'       => $message,
            'msgType'       => $msgType,
            'changeCost'    => self::CHANGE_COST_DM,
            'currentDM'     => $currentDM,
            'canChange'     => $canChange,
            'pageTitle'     => 'Elegir Raza',
        ));

        $this->display('page.race.default.tpl');
    }
}