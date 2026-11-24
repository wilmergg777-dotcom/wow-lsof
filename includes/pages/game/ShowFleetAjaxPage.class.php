<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */


class ShowFleetAjaxPage extends AbstractGamePage
{
        public $returnData      = array();

        public static $requireModule = 0;

        function __construct()
        {
                parent::__construct();
                $this->setWindow('ajax');
        }

        private function sendData($Code, $Message)
        {
                $this->returnData['code']       = $Code;
                $this->returnData['mess']       = $Message;
                $this->sendJSON($this->returnData);
        }

        public function show()
        {
                global $USER, $PLANET, $resource, $LNG, $pricelist;

                $UserDeuterium  = $PLANET['deuterium'];

                $planetID               = HTTP::_GP('planetID', 0);
                $targetMission  = HTTP::_GP('mission', 0);

                $activeSlots    = FleetFunctions::GetCurrentFleets($USER['id']);
                $maxSlots               = FleetFunctions::GetMaxFleetSlots($USER);

                $this->returnData['slots']              = $activeSlots;

                if (IsVacationMode($USER)) {
                        $this->sendData(620, $LNG['fa_vacation_mode_current']);
                }

                if (empty($planetID)) {
                        $this->sendData(601, $LNG['fa_planet_not_exist']);
                }

                if ($maxSlots <= $activeSlots) {
                        $this->sendData(612, $LNG['fa_no_more_slots']);
                }

                $fleetArray = array();

                $db = Database::get();

                switch($targetMission)
                {
                        case 6:
                                if(!isModuleAvailable(MODULE_MISSION_SPY)) {
                                        $this->sendData(699, $LNG['sys_module_inactive']);
                                }

                                $ships  = min($USER['spio_anz'], $PLANET[$resource[210]]);

                                if(empty($ships)) {
                                        $this->sendData(611, $LNG['fa_no_spios']);
                                }

                                $fleetArray = array(210 => $ships);
                                $this->returnData['ships'][210] = $PLANET[$resource[210]] - $ships;
                                break;
                        // ══════════════════════════════════════════════
                        // ASTROIO v3.2 — RECICLAJE AUTOMÁTICO
                        // Misión 8  = Campo de escombros (planeta real)
                        // Misión 32 = Asteroide (posición vacía)
                        // Ambas envían los recicladores al instante,
                        // sin pasar por la página de flotas.
                        // ══════════════════════════════════════════════
                        case 8:
                                if(!isModuleAvailable(MODULE_MISSION_RECYCLE)) {
                                        $this->sendData(699, $LNG['sys_module_inactive']);
                                }

                                $sql = "SELECT (der_metal + der_crystal) as sum FROM %%PLANETS%% WHERE id = :planetID;";
                                $totalDebris = $db->selectSingle($sql, array(
                                        ':planetID' => $planetID
                                ), 'sum');

                                if(empty($totalDebris) || $totalDebris <= 0) {
                                        $this->sendData(614, isset($LNG['fa_no_debris']) ? $LNG['fa_no_debris'] : $LNG['fa_no_recyclers']);
                                }

                                $fleetArray = $this->buildRecyclerFleet((float)$totalDebris);

                                if($fleetArray === false) {
                                        $this->sendData(611, $LNG['fa_no_recyclers']);
                                }
                                break;
                        case 32:
                                if(!isModuleAvailable(MODULE_MISSION_RECYCLE)) {
                                        $this->sendData(699, $LNG['sys_module_inactive']);
                                }

                                if (!class_exists('AsteroidHelper')) {
                                        require_once ROOT_PATH.'includes/classes/AsteroidHelper.class.php';
                                }

                                $astGalaxy  = min(max(HTTP::_GP('galaxy', 0), 1), Config::get()->max_galaxy);
                                $astSystem  = min(max(HTTP::_GP('system', 0), 1), Config::get()->max_system);
                                $astPlanet  = min(max(HTTP::_GP('planet', 0), 1), Config::get()->max_planets);

                                if(empty($astGalaxy) || empty($astSystem) || empty($astPlanet)) {
                                        $this->sendData(601, $LNG['fa_planet_not_exist']);
                                }

                                $asteroid = AsteroidHelper::getAsteroidAt($astGalaxy, $astSystem, $astPlanet);

                                if(empty($asteroid) || !empty($asteroid['recycled'])) {
                                        $this->sendData(640, isset($LNG['fa_no_asteroid']) ? $LNG['fa_no_asteroid'] : $LNG['fa_planet_not_exist']);
                                }

                                // Contenedor ocupa 1 unidad de carga; recursos ocupan su cantidad.
                                $astLoad    = ($asteroid['type'] === 'container') ? 1 : (float)$asteroid['amount'];
                                $fleetArray = $this->buildRecyclerFleet($astLoad);

                                if($fleetArray === false) {
                                        $this->sendData(611, $LNG['fa_no_recyclers']);
                                }

                                // Destino: posición vacía, sin registro de planeta.
                                $targetData = array(
                                        'id_owner'   => 0,
                                        'galaxy'     => $astGalaxy,
                                        'system'     => $astSystem,
                                        'planet'     => $astPlanet,
                                        'planet_type'=> 1,
                                );
                                $planetID   = 0;
                                break;
                        default:
                                $this->sendData(610, $LNG['fa_not_enough_probes']);
                                break;
                }

                $fleetArray                                             = array_filter($fleetArray);

                if(empty($fleetArray)) {
                        $this->sendData(611, $LNG['fa_no_recyclers']);
                }

                if ($targetMission == 32)
                {
                        // ASTROIO v3.2: el asteroide no tiene registro de planeta.
                        // $targetData ya está preparado en el case 32.
                }
                else
                {
                $sql = "SELECT planet.id_owner as id_owner,
                planet.galaxy as galaxy,
                planet.system as system,
                planet.planet as planet,
                planet.planet_type as planet_type,
                total_points, onlinetime, urlaubs_modus, banaday, authattack
                FROM %%PLANETS%% planet
                INNER JOIN %%USERS%% user ON planet.id_owner = user.id
                LEFT JOIN %%STATPOINTS%% as stat ON stat.id_owner = user.id AND stat.stat_type = '1'
                WHERE planet.id = :planetID;";

                $targetData = $db->selectSingle($sql, array(
                        ':planetID' => $planetID
                ));

                if (empty($targetData)) {
                        $this->sendData(601, $LNG['fa_planet_not_exist']);
                }
                }

                if($targetMission == 6)
                {
                        if(Config::get()->adm_attack == 1 && $targetData['authattack'] > $USER['authlevel']) {
                                $this->sendData(619, $LNG['fa_action_not_allowed']);
                        }

                        if (IsVacationMode($targetData)) {
                                $this->sendData(605, $LNG['fa_vacation_mode']);
                        }
                        $sql    = 'SELECT total_points
                        FROM %%STATPOINTS%%
                        WHERE id_owner = :userId AND stat_type = :statType';

                        $USER   += Database::get()->selectSingle($sql, array(
                                ':userId'       => $USER['id'],
                                ':statType'     => 1
                        ));

                        $IsNoobProtec   = CheckNoobProtec($USER, $targetData, $targetData);

                        if ($IsNoobProtec['NoobPlayer']) {
                                $this->sendData(603, $LNG['fa_week_player']);
                        }

                        if ($IsNoobProtec['StrongPlayer']) {
                                $this->sendData(604, $LNG['fa_strong_player']);
                        }

                        if ($USER['id'] == $targetData['id_owner']) {
                                $this->sendData(618, $LNG['fa_not_spy_yourself']);
                        }
                }

                $SpeedFactor            = FleetFunctions::GetGameSpeedFactor();
                $Distance               = FleetFunctions::GetTargetDistance(array($PLANET['galaxy'], $PLANET['system'], $PLANET['planet']), array($targetData['galaxy'], $targetData['system'], $targetData['planet']));
                $SpeedAllMin            = FleetFunctions::GetFleetMaxSpeed($fleetArray, $USER);
                $Duration                       = FleetFunctions::GetMissionDuration(10, $SpeedAllMin, $Distance, $SpeedFactor, $USER);
                $consumption            = FleetFunctions::GetFleetConsumption($fleetArray, $Duration, $Distance, $USER, $SpeedFactor);

                $UserDeuterium          -= $consumption;

                if($UserDeuterium < 0) {
                        $this->sendData(613, $LNG['fa_not_enough_fuel']);
                }

                if($consumption > FleetFunctions::GetFleetRoom($fleetArray)) {
                        $this->sendData(613, $LNG['fa_no_fleetroom']);
                }

                if(connection_aborted())
                        exit;

                $this->returnData['slots']++;

                $fleetResource  = array(
                        901     => 0,
                        902     => 0,
                        903     => 0,
                );

                $fleetStartTime         = $Duration + TIMESTAMP;
                $fleetStayTime          = $fleetStartTime;
                $fleetEndTime           = $fleetStayTime + $Duration;

                $shipID                         = array_keys($fleetArray);

                FleetFunctions::sendFleet($fleetArray, $targetMission, $USER['id'], $PLANET['id'], $PLANET['galaxy'],
                        $PLANET['system'], $PLANET['planet'], $PLANET['planet_type'], $targetData['id_owner'], $planetID,
                        $targetData['galaxy'], $targetData['system'], $targetData['planet'], $targetData['planet_type'],
                        $fleetResource, $fleetStartTime, $fleetStayTime, $fleetEndTime);

                $this->sendData(600, $LNG['fa_sending']." ".array_sum($fleetArray)." ". $LNG['tech'][$shipID[0]] ." ".$LNG['gl_to']." ".$targetData['galaxy'].":".$targetData['system'].":".$targetData['planet']." ...");
        }

        // ════════════════════════════════════════════════════════════
        // ASTROIO v3.2 — Construye la flota de recicladores necesaria
        // para cargar $totalLoad de recursos. Prioriza Mega-Reciclador
        // (219) y después Reciclador (209). Devuelve false si el jugador
        // no tiene recicladores en el planeta actual.
        // ════════════════════════════════════════════════════════════
        private function buildRecyclerFleet($totalLoad)
        {
                global $PLANET, $resource, $pricelist;

                $recElementIDs  = array(219, 209);
                $fleetArray     = array();

                foreach($recElementIDs as $elementID)
                {
                        $capacity       = !empty($pricelist[$elementID]['capacity']) ? $pricelist[$elementID]['capacity'] : 1;
                        $shipsNeed      = min((int)ceil($totalLoad / $capacity), (int)$PLANET[$resource[$elementID]]);

                        if($shipsNeed <= 0) {
                                continue;
                        }

                        $fleetArray[$elementID] = $shipsNeed;
                        $this->returnData['ships'][$elementID]  = $PLANET[$resource[$elementID]] - $shipsNeed;

                        $totalLoad      -= ($shipsNeed * $capacity);

                        if($totalLoad <= 0)
                        {
                                break;
                        }
                }

                if(empty($fleetArray))
                {
                        return false;
                }

                return $fleetArray;
        }
}