<?php
// includes/pages/game/ShowFactionPage.class.php

class ShowFactionPage extends AbstractGamePage
{
    const CHANGE_COST_DM = 5000;

    function __construct()
    {
        parent::__construct();
    }

    private function getPrefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    public function show()
    {
        global $USER, $db;

        $helperPath = ROOT_PATH . 'includes/classes/FactionMissionHelper.class.php';
        if (file_exists($helperPath)) {
            require_once $helperPath;
        }

        $prefix = $this->getPrefix();
        $tab       = HTTP::_GP('tab', 'default');
        $action    = HTTP::_GP('action', '');
        $factionId = (int) HTTP::_GP('faction_id', 0);
        
        $message   = '';
        $msgType   = 'info';
        $alreadyChosen = (isset($USER['faction_id']) && $USER['faction_id'] != 0);

        // ==========================================
        // 1. PROCESAR ENTREGA DE RECURSOS (MISIONES)
        // ==========================================
        if ($tab === 'missions' && ($action === 'deliver' || $action === 'deliver_all')) {
            $amount = (int) HTTP::_GP('amount', 0);
            $resType = HTTP::_GP('res_type', 'metal');
            
            // Si es deliver_all, obtenemos la cantidad requerida de la misión (100.000)
            if ($action === 'deliver_all') {
                $m = FactionMissionHelper::getTodayPersonalMission($USER['faction_id']);
                $amount = ($m && isset($m['target_amount'])) ? (int)$m['target_amount'] : 100000;
                $resType = 'all';
            }

            if ($amount > 0 && $alreadyChosen && class_exists('FactionMissionHelper')) {
                
                $hasResources = false;
                $updateSql = "";
                $params = array(':pid' => $GLOBALS['PLANET']['id']);
                $progressAction = '';
                $progressTarget = '';

                // Verificamos si tiene los recursos necesarios
                if ($resType === 'all') {
                    $hasResources = (isset($GLOBALS['PLANET']['metal']) && $GLOBALS['PLANET']['metal'] >= $amount) &&
                                    (isset($GLOBALS['PLANET']['crystal']) && $GLOBALS['PLANET']['crystal'] >= $amount) &&
                                    (isset($GLOBALS['PLANET']['deuterium']) && $GLOBALS['PLANET']['deuterium'] >= $amount);
                    
                    if ($hasResources) {
                        $updateSql = "UPDATE `".$prefix."planets` SET metal = metal - :amt, crystal = crystal - :amt, deuterium = deuterium - :amt WHERE id = :pid";
                        $params[':amt'] = $amount;
                        $GLOBALS['PLANET']['metal'] -= $amount;
                        $GLOBALS['PLANET']['crystal'] -= $amount;
                        $GLOBALS['PLANET']['deuterium'] -= $amount;
                        $progressAction = 'deliver_all';
                        $progressTarget = 'any';
                    }
                } elseif (in_array($resType, ['metal', 'crystal', 'deuterium'])) {
                    $hasResources = (isset($GLOBALS['PLANET'][$resType]) && $GLOBALS['PLANET'][$resType] >= $amount);
                    if ($hasResources) {
                        $updateSql = "UPDATE `".$prefix."planets` SET `$resType` = `$resType` - :amt WHERE id = :pid";
                        $params[':amt'] = $amount;
                        $GLOBALS['PLANET'][$resType] -= $amount;
                        $progressAction = 'deliver_' . $resType;
                        $progressTarget = $resType;
                    }
                }

                // Ejecutamos la entrega
                if ($hasResources && !empty($updateSql)) {
                    $db->update($updateSql, $params);
                    
                    // 1. Sumamos el progreso a la misión Personal
                    FactionMissionHelper::addPersonalProgress($USER['id'], $progressAction, $progressTarget, 0, $amount);
                    
                    // 2. Sumamos el progreso a la misión Global (Fiebre de Oro pide metal)
                    if ($resType === 'metal' || $resType === 'all') {
                        FactionMissionHelper::addGlobalProgress($USER['id'], 'deliver_metal', 'metal', 0, $amount);
                    } else {
                        FactionMissionHelper::addGlobalProgress($USER['id'], 'deliver_' . $resType, $resType, 0, $amount);
                    }

                    $nombreRes = ($resType === 'all') ? 'todos los recursos' : $resType;
                    $message = "✅ Has entregado " . number_format($amount, 0, ',', '.') . " de " . $nombreRes . " a tu facción.";
                    $msgType = 'success';
                } else {
                    $nombreRes = ($resType === 'all') ? 'todos los recursos (metal, cristal y deuterio)' : $resType;
                    $message = "❌ No tienes suficiente " . $nombreRes . " en este planeta.";
                    $msgType = 'error';
                }
            }
        }

        // ==========================================
        // 2. PROCESAR RECLAMAR RECOMPENSA
        // ==========================================
        if ($tab === 'missions' && $action === 'claimPersonal') {
            $missionId = (int) HTTP::_GP('mission_id', 0);
            if ($missionId > 0 && class_exists('FactionMissionHelper')) {
                $result = FactionMissionHelper::claimPersonalReward($USER['id'], $missionId);
                $message = $result['msg'];
                $msgType = $result['ok'] ? 'success' : 'error';
            }
        }

        // ==========================================
        // 3. PROCESAR SELECCIÓN / CAMBIO DE FACCIÓN
        // ==========================================
        if ($tab === 'default' && $action === 'select' && $factionId > 0) {
            $factionExists = $db->selectSingle("SELECT COUNT(*) as cnt FROM `".$prefix."factions` WHERE faction_id = :fid;", array(':fid' => $factionId), 'cnt');
            if (!$factionExists) {
                $message = '❌ Facción inválida.';
                $msgType = 'error';
            } else {
                if (!$alreadyChosen) {
                    $db->update("UPDATE `".$prefix."users` SET faction_id = :fid WHERE id = :uid;", array(':fid' => $factionId, ':uid' => $USER['id']));
                    $USER['faction_id'] = $factionId;
                    $message = '✅ ¡Facción elegida!';
                    $msgType = 'success';
                } else {
                    $currentDM = isset($USER['darkmatter']) ? (int)$USER['darkmatter'] : 0;
                    if ($currentDM < self::CHANGE_COST_DM) {
                        $message = '❌ Necesitas '.number_format(self::CHANGE_COST_DM, 0, ',', '.').' de MO.';
                        $msgType = 'error';
                    } else {
                        $db->update("UPDATE `".$prefix."users` SET faction_id = :fid, darkmatter = darkmatter - :cost WHERE id = :uid;", array(':fid' => $factionId, ':cost' => self::CHANGE_COST_DM, ':uid' => $USER['id']));
                        $USER['faction_id'] = $factionId;
                        $USER['darkmatter'] = $currentDM - self::CHANGE_COST_DM;
                        $message = '✅ ¡Facción cambiada!';
                        $msgType = 'success';
                    }
                }
                $alreadyChosen = true;
            }
        }

        // ==========================================
        // CARGAR DATOS DE FACCIONES
        // ==========================================
        $factions = $db->select("SELECT * FROM `".$prefix."factions` ORDER BY faction_id ASC;");
        if (!is_array($factions)) $factions = array();

        $myFaction = null;
        $currentDM = isset($USER['darkmatter']) ? (int)$USER['darkmatter'] : 0;

        if ($alreadyChosen) {
            foreach ($factions as $f) {
                if ($f['faction_id'] == $USER['faction_id']) $myFaction = $f;
            }
        }

        // ==========================================
        // PREPARAR VARIABLES DE MISIONES
        // ==========================================
        $personalMission = array(
            'id' => 0, 'icon' => '🎯', 'name' => 'Misión no asignada', 
            'description' => 'No hay misión disponible hoy.', 'target_amount' => 1, 'reward_type' => '', 'action_type' => ''
        );
        $personalProgress = array('progress' => 0, 'claimed' => 0);
        
        // 🆕 Variables para la recompensa exacta
        $personalRewardAmount = 0; 
        $personalRewardData   = array(); 
        
        $globalMission = array(
            'status' => 'none', 'icon' => '🌍', 'name' => 'Misión Global', 
            'description' => 'No hay misión global activa.', 'progress' => 0, 'target' => 1, 
            'bonus_type' => '', 'bonus_value' => 0, 'bonus_end' => 0, 'action_type' => ''
        );
        $activeBuffs = array();
        $globalBuffPool = "";

        // ==========================================
        // CARGAR DATOS DE MISIONES DESDE EL HELPER
        // ==========================================
        if ($tab === 'missions' && $alreadyChosen && class_exists('FactionMissionHelper')) {
            
            // PERSONAL
            $m = FactionMissionHelper::getTodayPersonalMission($USER['faction_id']);
            if (is_array($m) && !empty($m)) {
                $personalMission = array_merge($personalMission, $m); 
                
                // 🆕 Extraemos todos los datos del JSON (para recursos, naves, defensas, etc.)
                if (!empty($personalMission['reward_json'])) {
                    $personalRewardData = json_decode($personalMission['reward_json'], true);
                    if (isset($personalRewardData['amount'])) {
                        $personalRewardAmount = (int)$personalRewardData['amount'];
                    }
                }
                
                $p = FactionMissionHelper::getPersonalProgress($USER['id'], $personalMission['id']);
                if (is_array($p) && !empty($p)) {
                    $personalProgress = array_merge($personalProgress, $p);
                }
            }

            // GLOBAL
            $g = FactionMissionHelper::getGlobalMission($USER['faction_id']);
            if (is_array($g) && !empty($g)) {
                $globalMission = array_merge($globalMission, $g);
                
                // 🆕 Buscamos los nombres de los 5 buffs posibles de esta facción
                $buffQuery = $db->select("SELECT buff_name FROM `".$prefix."faction_buff_pool` WHERE faction_id = :fid AND active = 1", array(':fid' => $USER['faction_id']));
                if (is_array($buffQuery) && count($buffQuery) > 0) {
                    $names = array();
                    foreach ($buffQuery as $b) {
                        $names[] = $b['buff_name'];
                    }
                    $globalBuffPool = implode(', ', $names);
                }
            }

            // BUFFS ACTIVOS
            $b = FactionMissionHelper::getAllBonusesByFaction($USER['faction_id']);
            if (is_array($b)) {
                $activeBuffs = $b;
            }
        }

        // ==========================================
        // ASIGNAR AL TEMPLATE
        // ==========================================
        $this->assign(array(
            'factions'             => $factions,
            'hasChosen'            => $alreadyChosen,
            'myFaction'            => $myFaction,
            'message'              => $message,
            'msgType'              => $msgType,
            'changeCost'           => self::CHANGE_COST_DM,
            'currentDM'            => $currentDM,
            'canChange'            => ($alreadyChosen && $currentDM >= self::CHANGE_COST_DM),
            'pageTitle'            => 'Facciones',
            'tab_active'           => $tab,
            'personalMission'      => $personalMission,
            'personalProgress'     => $personalProgress,
            'personalRewardAmount' => $personalRewardAmount,
            'personalRewardData'   => $personalRewardData, // 🆕 Enviamos todo el array decodificado
            'globalMission'        => $globalMission,
            'globalBuffPool'       => $globalBuffPool,
            'activeBuffs'          => $activeBuffs,
        ));

        $this->display('page.faction.default.tpl');
    }
}