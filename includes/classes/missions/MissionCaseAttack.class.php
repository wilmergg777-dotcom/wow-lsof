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
 *
 * ✅ AstroIO v1.2 (FIX CRÍTICO - Saqueo al volver)
 * ✅ AstroIO v1.3 (Mini Torneos)
 * ✅ AstroIO v1.4 (FIX ALIANZA — Red de seguridad al llegar)
 * ✅ AstroIO v1.5 (BLINDAJE TOTAL — Anti-flotas huérfanas)
 * ✅ AstroIO v1.6 (REPRESALIA NOVATOS)
 * ✅ AstroIO v1.7 (SISTEMA DE CLIMA):
 *   - Se integra ClimaEngine para aplicar factores de ataque, defensa, bajas y botín.
 *   - Se guarda clima_id en el reporte de batalla (%%RW%%).
 * ✅ AstroIO v1.8 (BUFF CLIMÁTICO):
 *   - Se lee fleets.buff_id (fijado al lanzar) y se aplica con ClimaEngine::applyBuff().
 *   - Solo modifica factores negativos (los positivos se quedan igual).
 *   - Se guarda buff_id en el reporte de batalla (%%RW%%) para auditoría.
 * ✅ AstroIO v1.9 (OFICIAL ASTRÓNOMO):
 *   - Se lee rpg_astronomo del atacante.
 *   - Reduce las penalizaciones climáticas según el nivel del Astrónomo.
 * ✅ AstroIO v1.10 (ASTRÓNOMO — FIX FACTOR BAJAS):
 *   - La mitigación del Astrónomo ahora cubre correctamente factor_bajas:
 *     en el motor de combate, factor_bajas > 1.00 es la PENALIZACIÓN (más bajas),
 *     por eso la reducción se aplica al exceso por encima de 1.00.
 *   - factor_bajas < 1.00 es un bonus y NO se toca.
 *   - Tope de seguridad del nivel a 5.
 */

// ============================================
// ASTROIO - Cargar EventHelper explícitamente
// ============================================
if (!class_exists('EventHelper')) {
    $__evFile = (defined('ROOT_PATH') ? ROOT_PATH : '') . 'includes/classes/EventHelper.class.php';
    if (file_exists($__evFile)) {
        require_once $__evFile;
    }
}
// ============================================

// ============================================
// ASTROIO - Cargar ClimaEngine
// ============================================
if (!class_exists('ClimaEngine')) {
    $__climaFile = (defined('ROOT_PATH') ? ROOT_PATH : '') . 'includes/classes/ClimaEngine.class.php';
    if (file_exists($__climaFile)) {
        require_once $__climaFile;
    }
}
// ============================================

class MissionCaseAttack extends MissionFunctions implements Mission
{
    function __construct($Fleet)
    {
        $this->_fleet	= $Fleet;
    }

    private function safeTournement($playerId, $tourneyEvent, $addUnits)
    {
        try {
            if (!function_exists('tournement')) {
                return false;
            }
            return tournement($playerId, $tourneyEvent, $addUnits);
        } catch (Throwable $e) {
            $logDir = (defined('ROOT_PATH') ? ROOT_PATH : '') . 'cache/';
            if (!is_dir($logDir)) {
                @mkdir($logDir, 0755, true);
            }
            @file_put_contents(
                $logDir . 'tournement_error.log',
                '[' . date('Y-m-d H:i:s') . '] [MissionCaseAttack] Torneo=' . $tourneyEvent
                . ' Player=' . $playerId
                . ' AddUnits=' . $addUnits
                . ' ERROR: ' . $e->getMessage()
                . ' en ' . $e->getFile() . ':' . $e->getLine()
                . PHP_EOL,
                FILE_APPEND
            );
            return false;
        }
    }

    private function safeUpdateEventProgress($userId, $eventKey, $amount)
    {
        try {
            if (!class_exists('EventHelper')) {
                return false;
            }
            if (!method_exists('EventHelper', 'updateProgress')) {
                return false;
            }
            return EventHelper::updateProgress($userId, $eventKey, $amount);
        } catch (Throwable $e) {
            $logDir = (defined('ROOT_PATH') ? ROOT_PATH : '') . 'cache/';
            if (!is_dir($logDir)) {
                @mkdir($logDir, 0755, true);
            }
            @file_put_contents(
                $logDir . 'eventhelper_error.log',
                '[' . date('Y-m-d H:i:s') . '] [MissionCaseAttack] EventKey=' . $eventKey
                . ' User=' . $userId
                . ' Amount=' . $amount
                . ' ERROR: ' . $e->getMessage()
                . ' en ' . $e->getFile() . ':' . $e->getLine()
                . PHP_EOL,
                FILE_APPEND
            );
            return false;
        }
    }

    function TargetEvent()
    {	
        global $resource, $reslist;

        $db				= Database::get();
        $config			= Config::get($this->_fleet['fleet_universe']);

        $fleetAttack	= array();
        $fleetDefend	= array();
        
        $userAttack		= array();
        $userDefend		= array();

        $incomingFleets	= array();

        $stealResource	= array(
            901	=> 0,
            902	=> 0,
            903	=> 0,
        );
        
        $debris			= array();
        $planetDebris	= array();
        
        $debrisResource	= array(901, 902);
        
        $messageHTML	= <<<HTML
<div class="raportMessage">
    <table>
        <tr>
            <td colspan="2"><a href="game.php?page=raport&raport=%s" target="_blank"><span class="%s">%s %s (%s)</span></a></td>
        </tr>
        <tr>
            <td>%s</td><td><span class="%s">%s: %s</span>&nbsp;<span class="%s">%s: %s</span></td>
        </tr>
        <tr>
            <td>%s</td><td><span>%s:&nbsp;<span class="reportSteal element901">%s</span>&nbsp;</span><span>%s:&nbsp;<span class="reportSteal element902">%s</span>&nbsp;</span><span>%s:&nbsp;<span class="reportSteal element903">%s</span></span></td>
        </tr>
        <tr>
            <td>%s</td><td><span>%s:&nbsp;<span class="reportDebris element901">%s</span>&nbsp;</span><span>%s:&nbsp;<span class="reportDebris element902">%s</span></span></td>
        </tr>
    </table>
</div>
HTML;
        //Minize HTML
        $messageHTML	= str_replace(array("\n", "\t", "\r"), "", $messageHTML);

        $sql			= "SELECT * FROM %%PLANETS%% WHERE id = :planetId;";
        $targetPlanet 	= $db->selectSingle($sql, array(
            ':planetId'	=> $this->_fleet['fleet_end_id']
        ));

        $sql			= "SELECT * FROM %%USERS%% WHERE id = :userId;";
        $targetUser		= $db->selectSingle($sql, array(
            ':userId'	=> $targetPlanet['id_owner']
        ));
        $targetUser['factor']	= getFactors($targetUser, 'basic', $this->_fleet['fleet_start_time']);

        // ============================================
        // ASTROIO v1.4 — FIX ALIANZA (Red de seguridad)
        // ============================================
        if (
            !empty($targetUser)
            && !empty($targetUser['id'])
            && (int) $targetUser['id'] < 900000000
            && !empty($targetUser['ally_id'])
            && (int) $targetUser['ally_id'] > 0
            && (int) $targetUser['id'] !== (int) $this->_fleet['fleet_owner']
        ) {
            $sql = "SELECT ally_id FROM %%USERS%% WHERE id = :userId LIMIT 1;";
            $attackerAllyId = $db->selectSingle($sql, array(
                ':userId' => (int) $this->_fleet['fleet_owner']
            ), 'ally_id');

            if (
                !empty($attackerAllyId)
                && (int) $attackerAllyId > 0
                && (int) $attackerAllyId === (int) $targetUser['ally_id']
            ) {
                $this->setState(FLEET_RETURN);
                $this->SaveFleet();
                return;
            }
        }
        // ============================================

        // ============================================
        // ASTROIO v1.7 — Cargar Clima
        // ============================================
        $climaInfo = null;
        if (class_exists('ClimaEngine')) {
            if (!empty($this->_fleet['clima_id'])) {
                // Usar el clima fijado al lanzar la flota
                $climaInfo = ClimaEngine::getFactoresPorClimaId($this->_fleet['clima_id']);
            } else {
                // Fallback: usar el clima actual del planeta
                $climaInfo = ClimaEngine::getFactoresPlaneta($this->_fleet['fleet_end_id']);
            }
        }

        // Valores por defecto si no hay clima
        $factorAtaque = isset($climaInfo['factor_ataque']) ? $climaInfo['factor_ataque'] : 1.0;
        $factorDefensa = isset($climaInfo['factor_defensa']) ? $climaInfo['factor_defensa'] : 1.0;
        $factorBajas = isset($climaInfo['factor_bajas']) ? $climaInfo['factor_bajas'] : 1.0;
        $factorBotin = isset($climaInfo['factor_botin']) ? $climaInfo['factor_botin'] : 1.0;
        $climaId = !empty($this->_fleet['clima_id']) ? (int)$this->_fleet['clima_id'] : (isset($climaInfo['clima_id']) ? (int)$climaInfo['clima_id'] : null);
        // ============================================

        // ============================================
        // ASTROIO v1.8 — Cargar y aplicar BUFF CLIMÁTICO
        // El buff se fijó al lanzar (fleets.buff_id). Si expiró en vuelo,
        // se sigue aplicando porque lo tenía el jugador en el momento del envío.
        // Solo modifica factores negativos (los positivos se quedan igual).
        // ============================================
        $buffId = !empty($this->_fleet['buff_id']) ? (int)$this->_fleet['buff_id'] : null;
        if ($buffId > 0 && class_exists('ClimaEngine') && is_array($climaInfo)) {
            $climaInfo = ClimaEngine::applyBuff($climaInfo, $buffId);

            // Recalcular factores tras aplicar buff
            $factorAtaque  = isset($climaInfo['factor_ataque'])  ? $climaInfo['factor_ataque']  : 1.0;
            $factorDefensa = isset($climaInfo['factor_defensa']) ? $climaInfo['factor_defensa'] : 1.0;
            $factorBajas   = isset($climaInfo['factor_bajas'])   ? $climaInfo['factor_bajas']   : 1.0;
            $factorBotin   = isset($climaInfo['factor_botin'])   ? $climaInfo['factor_botin']   : 1.0;
        }
        // ============================================

        // ============================================
        // ASTROIO v1.10 — OFICIAL ASTRÓNOMO (Mitigación Climática — FIX BAJAS)
        // ============================================
        // Consultamos el nivel del Astrónomo del jugador que ataca
        // (tope de seguridad en nivel 5, aunque la BD ya limita a 5)
        $sqlAstro = "SELECT rpg_astronomo FROM %%USERS%% WHERE id = :userId LIMIT 1;";
        $astronomoLvl = min(5, max(0, (int)$db->selectSingle($sqlAstro, array(':userId' => $this->_fleet['fleet_owner']), 'rpg_astronomo')));
        
        if ($astronomoLvl > 0) {
            // Reducción del 5% por nivel de la penalización (máximo nivel 5 = -25% de la penalización)
            $reduccion = 1 - ($astronomoLvl * 0.05);
            
            // Ataque / Defensa / Botín: factor < 1.00 es penalización -> la reducimos hacia 1.00
            if ($factorAtaque < 1.00)  { $factorAtaque  = 1 - ((1 - $factorAtaque)  * $reduccion); }
            if ($factorDefensa < 1.00) { $factorDefensa = 1 - ((1 - $factorDefensa) * $reduccion); }
            if ($factorBotin < 1.00)   { $factorBotin   = 1 - ((1 - $factorBotin)   * $reduccion); }
            
            // Bajas: aquí la lógica se INVIERTA. En el motor, los supervivientes se dividen
            // por factor_bajas: factor_bajas > 1.00 = MÁS bajas (penalización),
            // factor_bajas < 1.00 = MENOS bajas (bonus, no se toca).
            if ($factorBajas > 1.00)   { $factorBajas   = 1 + (($factorBajas - 1) * $reduccion); }
        }
        // ============================================

        $planetUpdater	= new ResourceUpdate();
        
        list($targetUser, $targetPlanet)	= $planetUpdater->CalcResource($targetUser, $targetPlanet, true, $this->_fleet['fleet_start_time']);
        
        if($this->_fleet['fleet_group'] != 0)
        {
            $sql	= "DELETE FROM %%AKS%% WHERE id = :acsId;";
            $db->delete($sql, array(
                ':acsId'	=> $this->_fleet['fleet_group'],
            ));

            $sql	= "SELECT * FROM %%FLEETS%% WHERE fleet_group = :acsId;";

            $incomingFleetsResult = $db->select($sql, array(
                ':acsId'	=> $this->_fleet['fleet_group'],
            ));
        
            foreach($incomingFleetsResult as $incomingFleetRow)
            {
                $incomingFleets[$incomingFleetRow['fleet_id']] = $incomingFleetRow;
            }
            
            unset($incomingFleetsResult);
        }
        else
        {
            $incomingFleets = array($this->_fleet['fleet_id'] => $this->_fleet);
        }
        
        foreach($incomingFleets as $fleetID => $fleetDetail)
        {
            $sql	= "SELECT * FROM %%USERS%% WHERE id = :userId;";
            $fleetAttack[$fleetID]['player']	= $db->selectSingle($sql, array(
                ':userId'	=> $fleetDetail['fleet_owner']
            ));

            $fleetAttack[$fleetID]['player']['factor']	= getFactors($fleetAttack[$fleetID]['player'], 'attack', $this->_fleet['fleet_start_time']);
            
            // ASTROIO v1.7 — Aplicar clima al atacante
            $fleetAttack[$fleetID]['player']['factor']['Attack'] *= $factorAtaque;
            $fleetAttack[$fleetID]['player']['factor']['Defensive'] *= $factorDefensa;

            $fleetAttack[$fleetID]['fleetDetail']		= $fleetDetail;
            $fleetAttack[$fleetID]['unit']				= FleetFunctions::unserialize($fleetDetail['fleet_array']);
            
            $userAttack[$fleetAttack[$fleetID]['player']['id']]	= $fleetAttack[$fleetID]['player']['username'];

            // ============================================================
            // ASTROIO v1.6 — LÓGICA DE REPRESALIA (El Débil ataca al Fuerte)
            // ============================================================
            // Calculamos la diferencia de puntos
            $attackerPoints = (int)$fleetAttack[$fleetID]['player']['total_points'];
            $defenderPoints = (int)$targetUser['total_points'];
            
            $noobPoints = (int)$config->noobprotection;
            $noobLimit  = (int)$config->noobprotectiontime;
            $maxDiff    = $noobPoints * $noobLimit;

            // Si el defensor es más fuerte (o sea, el atacante es el Débil)
            if (($defenderPoints - $attackerPoints) > $maxDiff && $attackerPoints > 0) {
                // Le ponemos un castigo de 24 horas (86400 segundos)
                $retaliationUntil = TIMESTAMP + 86400;
                
                // ✅ v3.8 — FIX REPRESALIA: también se escribe retaliation_target
                // (id del defensor fuerte al que atacó el débil). Sin ese campo,
                // la excepción de represalia en FleetFunctions
                // (retaliation_target == mi id) nunca se activaba y el fuerte
                // NO podía contraatacar. La ventana sigue siendo 24 h.
                $sql = "UPDATE %%USERS%% SET retaliation_time = :retaliationTime, retaliation_target = :retaliationTarget WHERE id = :userId;";
                $db->update($sql, array(
                    ':retaliationTime'   => $retaliationUntil,
                    ':retaliationTarget' => (int) $targetUser['id'],
                    ':userId'            => $fleetAttack[$fleetID]['player']['id']
                ));
            }
            // ============================================================
        }

        $sql	= "SELECT * FROM %%FLEETS%%
        WHERE fleet_mission		= :mission
        AND fleet_end_id		= :fleetEndId
        AND fleet_start_time 	<= :timeStamp
        AND fleet_end_stay 		>= :timeStamp;";

        $targetFleetsResult = $db->select($sql, array(
            ':mission'		=> 5,
            ':fleetEndId'	=> $this->_fleet['fleet_end_id'],
            ':timeStamp'	=> TIMESTAMP
        ));

        foreach($targetFleetsResult as $fleetDetail)
        {
            $fleetID	= $fleetDetail['fleet_id'];

            $sql	= "SELECT * FROM %%USERS%% WHERE id = :userId;";
            $fleetDefend[$fleetID]['player']			= $db->selectSingle($sql, array(
                ':userId'	=> $fleetDetail['fleet_owner']
            ));

            $fleetDefend[$fleetID]['player']['factor']	= getFactors($fleetDefend[$fleetID]['player'], 'attack', $this->_fleet['fleet_start_time']);
            
            // ASTROIO v1.7 — Aplicar clima al defensor (flotas estacionadas)
            $fleetDefend[$fleetID]['player']['factor']['Attack'] *= $factorAtaque;
            $fleetDefend[$fleetID]['player']['factor']['Defensive'] *= $factorDefensa;

            $fleetDefend[$fleetID]['fleetDetail']		= $fleetDetail;
            $fleetDefend[$fleetID]['unit']				= FleetFunctions::unserialize($fleetDetail['fleet_array']);
            
            $userDefend[$fleetDefend[$fleetID]['player']['id']]	= $fleetDefend[$fleetID]['player']['username'];
        }
            
        unset($targetFleetsResult);
        
        $fleetDefend[0]['player']			= $targetUser;
        $fleetDefend[0]['player']['factor']	= getFactors($fleetDefend[0]['player'], 'attack', $this->_fleet['fleet_start_time']);
        
        // ASTROIO v1.7 — Aplicar clima al defensor (planeta)
        $fleetDefend[0]['player']['factor']['Attack'] *= $factorAtaque;
        $fleetDefend[0]['player']['factor']['Defensive'] *= $factorDefensa;

        $fleetDefend[0]['fleetDetail']		= array(
            'fleet_start_galaxy'	=> $targetPlanet['galaxy'], 
            'fleet_start_system'	=> $targetPlanet['system'], 
            'fleet_start_planet'	=> $targetPlanet['planet'], 
            'fleet_start_type'		=> $targetPlanet['planet_type'], 
        );
        
        $fleetDefend[0]['unit']				= array();
        
        foreach(array_merge($reslist['fleet'], $reslist['defense']) as $elementID)
        {
            if (empty($targetPlanet[$resource[$elementID]])) continue;

            $fleetDefend[0]['unit'][$elementID] = $targetPlanet[$resource[$elementID]];
        }
            
        $userDefend[$fleetDefend[0]['player']['id']]	= $fleetDefend[0]['player']['username'];
        
        // ✅ v3.8 — Snapshot de unidades ANTES del combate. Si algún clima
        // tiene factor_bajas < 1.00 (bonus), la división de supervivientes
        // podría devolver MÁS naves de las que existían ("crear" naves de la
        // nada). El clamp posterior usa este snapshot para impedirlo.
        $initialUnits = array('attack' => array(), 'defend' => array());
        foreach ($fleetAttack as $fleetID => $fleetDetail) {
            $initialUnits['attack'][$fleetID] = $fleetDetail['unit'];
        }
        foreach ($fleetDefend as $fleetID => $fleetDetail) {
            $initialUnits['defend'][$fleetID] = $fleetDetail['unit'];
        }

        require_once 'includes/classes/missions/functions/calculateAttack.php';

        $fleetIntoDebris	= $config->Fleet_Cdr;
        $defIntoDebris		= $config->Defs_Cdr;
        
        $combatResult 		= calculateAttack($fleetAttack, $fleetDefend, $fleetIntoDebris, $defIntoDebris);

        // ============================================
        // ASTROIO v1.7 — Aplicar factor de Bajas
        // ============================================
        if ($factorBajas != 1.00) {
            // Aplicar a naves atacantes
            foreach ($fleetAttack as $fleetID => &$fleetDetail) {
                if (empty($fleetDetail['unit'])) continue;
                foreach ($fleetDetail['unit'] as $elementID => &$amount) {
                    if ($amount > 0) {
                        $amount = (int)floor($amount / $factorBajas);
                        // ✅ v3.8 — clamp: nunca más naves que las originales
                        if (isset($initialUnits['attack'][$fleetID][$elementID])) {
                            $amount = min($amount, (int)$initialUnits['attack'][$fleetID][$elementID]);
                        }
                    }
                }
            }
            unset($fleetDetail);

            // Aplicar a naves y defensas defensoras
            foreach ($fleetDefend as $fleetID => &$fleetDetail) {
                if (empty($fleetDetail['unit'])) continue;
                foreach ($fleetDetail['unit'] as $elementID => &$amount) {
                    if ($amount > 0) {
                        $amount = (int)floor($amount / $factorBajas);
                        // ✅ v3.8 — clamp: nunca más unidades que las originales
                        if (isset($initialUnits['defend'][$fleetID][$elementID])) {
                            $amount = min($amount, (int)$initialUnits['defend'][$fleetID][$elementID]);
                        }
                    }
                }
            }
            unset($fleetDetail);
        }
        // ============================================

        foreach ($fleetAttack as $fleetID => $fleetDetail)
        {
            $fleetArray = '';
            $totalCount = 0;
            
            $fleetDetail['unit']	= array_filter($fleetDetail['unit']);
            foreach ($fleetDetail['unit'] as $elementID => $amount)
            {				
                $fleetArray .= $elementID.','.floatToString($amount).';';
                $totalCount += $amount;
            }
            
            if($totalCount == 0)
            {
                if($this->_fleet['fleet_id'] == $fleetID)
                {
                    $this->KillFleet();
                }
                else
                {
                    $sql	= 'DELETE %%FLEETS%%, %%FLEETS_EVENT%%
                    FROM %%FLEETS%%
                    INNER JOIN %%FLEETS_EVENT%% ON fleetID = fleet_id
                    WHERE fleet_id = :fleetId;';

                    $db->delete($sql, array(
                        ':fleetId'	=> $fleetID
                    ));
                }
                
                $sql	= 'UPDATE %%LOG_FLEETS%% SET fleet_state = :fleetState WHERE fleet_id = :fleetId;';
                $db->update($sql, array(
                    ':fleetId'		=> $fleetID,
                    ':fleetState'	=> FLEET_HOLD,
                ));

                unset($fleetAttack[$fleetID]);
            }
            elseif($totalCount > 0)
            {
                $sql = "UPDATE %%FLEETS%% fleet, %%LOG_FLEETS%% log SET
                fleet.fleet_array	= :fleetData,
                fleet.fleet_amount	= :fleetCount,
                log.fleet_array		= :fleetData,
                log.fleet_amount	= :fleetCount
                WHERE fleet.fleet_id = :fleetId AND log.fleet_id = :fleetId;";

                $db->update($sql, array(
                    ':fleetData'	=> substr($fleetArray, 0, -1),
                    ':fleetCount'	=> $totalCount,
                    ':fleetId'		=> $fleetID
              	));
            }
            else
            {
                throw new OutOfRangeException("Negative Fleet amount ....");
            }
        }
        
        foreach ($fleetDefend as $fleetID => $fleetDetail)
        {
            if($fleetID != 0)
            {
                $fleetArray = '';
                $totalCount = 0;
                
                $fleetDetail['unit']	= array_filter($fleetDetail['unit']);
                
                foreach ($fleetDetail['unit'] as $elementID => $amount)
                {				
                    $fleetArray .= $elementID.','.floatToString($amount).';';
                    $totalCount += $amount;
                }
                
                if($totalCount == 0)
                {
                    $sql	= 'DELETE %%FLEETS%%, %%FLEETS_EVENT%%
                    FROM %%FLEETS%%
                    INNER JOIN %%FLEETS_EVENT%% ON fleetID = fleet_id
                    WHERE fleet_id = :fleetId;';

                    $db->delete($sql, array(
                        ':fleetId'	=> $fleetID
                    ));

                    $sql	= 'UPDATE %%LOG_FLEETS%% SET fleet_state = :fleetState WHERE fleet_id = :fleetId;';
                    $db->update($sql, array(
                        ':fleetId'		=> $fleetID,
                        ':fleetState'	=> FLEET_HOLD,
                    ));

                    unset($fleetAttack[$fleetID]);
                }
                elseif($totalCount > 0)
                {
                    $sql = "UPDATE %%FLEETS%% fleet, %%LOG_FLEETS%% log SET
                    fleet.fleet_array	= :fleetData,
                    fleet.fleet_amount	= :fleetCount,
                    log.fleet_array		= :fleetData,
                    log.fleet_amount	= :fleetCount
                    WHERE fleet.fleet_id = :fleetId AND log.fleet_id = :fleetId;";

                    $db->update($sql, array(
       					':fleetData'	=> substr($fleetArray, 0, -1),
                        ':fleetCount'	=> $totalCount,
                        ':fleetId'		=> $fleetID
                    ));
                }
                else
                {
                    throw new OutOfRangeException("Negative Fleet amount ....");
                }
            }
            else
            {
                $params	= array(':planetId' => $this->_fleet['fleet_end_id']);

                $fleetArray = array();
                foreach ($fleetDetail['unit'] as $elementID => $amount)
                {				
                    $fleetArray[] = '`'.$resource[$elementID].'` = :'.$resource[$elementID];
                    $params[':'.$resource[$elementID]]	= $amount;
                }
                
                if(!empty($fleetArray))
                {
                    $sql = 'UPDATE %%PLANETS%% SET '.implode(', ', $fleetArray).' WHERE id = :planetId;';
                    $db->update($sql, $params);
                }
            }
        }
        
        if ($combatResult['won'] == "a")
        {
            require_once 'includes/classes/missions/functions/calculateSteal.php';
            $stealResource = calculateSteal($fleetAttack, $targetPlanet);
            
            // ASTROIO v1.7 — Aplicar factor de Botín
            if ($factorBotin != 1.00) {
                $stealResource[901] = (int)floor($stealResource[901] * $factorBotin);
                $stealResource[902] = (int)floor($stealResource[902] * $factorBotin);
                $stealResource[903] = (int)floor($stealResource[903] * $factorBotin);
            }
        }

        $this->_fleet['fleet_resource_metal']     = $stealResource[901];
        $this->_fleet['fleet_resource_crystal']   = $stealResource[902];
        $this->_fleet['fleet_resource_deuterium'] = $stealResource[903];

        if($this->_fleet['fleet_end_type'] == 3)
        {
            $sql							= "SELECT der_metal, der_crystal FROM %%PLANETS%% WHERE id_luna = :moonId;";
            $targetDebris					= $db->selectSingle($sql, array(
                ':moonId'	=> $this->_fleet['fleet_end_id']
            ));
            $targetPlanet['der_metal']		= $targetDebris['der_metal'];
            $targetPlanet['der_crystal']	= $targetDebris['der_crystal'];
        }
        
        foreach($debrisResource as $elementID)
        {
            $debris[$elementID]			= $combatResult['debris']['attacker'][$elementID] + $combatResult['debris']['defender'][$elementID];
            $planetDebris[$elementID]	= $targetPlanet['der_'.$resource[$elementID]] + $debris[$elementID];
        }
        
        $debrisTotal		= array_sum($debris);
        
        $moonFactor			= $config->moon_factor;
        $maxMoonChance		= $config->moon_chance;
        
        if($targetPlanet['id_luna'] == 0 && $targetPlanet['planet_type'] == 1)
        {
            $chanceCreateMoon	= round($debrisTotal / 100000 * $moonFactor);
            $chanceCreateMoon	= min($chanceCreateMoon, $maxMoonChance);
        }
        else
        {
            $chanceCreateMoon	= 0;
        }

        $reportInfo	= array(
            'thisFleet'				=> $this->_fleet,
            'debris'				=> $debris,
            'stealResource'			=> $stealResource,
            'moonChance'			=> $chanceCreateMoon,
            'moonDestroy'			=> false,
            'moonName'				=> NULL,
            'moonDestroyChance'		=> NULL,
            'moonDestroySuccess'	=> NULL,
            'fleetDestroyChance'	=> NULL,
            'fleetDestroySuccess'	=> NULL,
        );
        
        $randChance	= mt_rand(1, 100);
        if ($randChance <= $chanceCreateMoon)
        {
            $LNG					= $this->getLanguage($targetUser['lang']);
            $reportInfo['moonName']	= $LNG['type_planet_3'];
            
            PlayerUtil::createMoon(
                $this->_fleet['fleet_universe'],
                $this->_fleet['fleet_end_galaxy'],
                $this->_fleet['fleet_end_system'],
                $this->_fleet['fleet_end_planet'],
                $targetUser['id'],
                $chanceCreateMoon
            );

            if (isset($targetUser['onlinetime']) && $targetUser['onlinetime'] > TIMESTAMP - 24 * 3600 * 7) {
                $this->safeTournement($this->_fleet['fleet_owner'], 10, 1);
            }
            
            if(Config::get($this->_fleet['fleet_universe'])->debris_moon == 1)
            {
                foreach($debrisResource as $elementID)
                {
                    $planetDebris[$elementID]	= 0;
                }
            }
        }
        
        require_once 'includes/classes/missions/functions/GenerateReport.php';
        $reportData	= GenerateReport($combatResult, $reportInfo);
        
        switch($combatResult['won'])
        {
            case "a":
                $attackStatus	= 'wons';
                $defendStatus	= 'loos';
                $class			= array('raportWin', 'raportLose');
                break;
            case "r":
                $attackStatus	= 'loos';
                $defendStatus	= 'wons';
                $class			= array('raportLose', 'raportWin');
                break;
            case "w":
            default:
                $attackStatus	= 'draws';
                $defendStatus	= 'draws';
                $class			= array('raportDraw', 'raportDraw');
                break;
        }

        if (isset($combatResult['won'])) {
            if ($combatResult['won'] == 'a') {
                foreach (array_keys($userAttack) as $attackerId) {
                    $this->safeTournement($attackerId, 4, 1);
                }
            } elseif ($combatResult['won'] == 'r') {
                foreach (array_keys($userDefend) as $defenderId) {
                    $this->safeTournement($defenderId, 4, 1);
                }
            }
        }
        
        $reportID	= md5(uniqid('', true).TIMESTAMP);
        
        // ASTROIO v1.8 — Se añade clima_id y buff_id al reporte
        $sql	= 'INSERT INTO %%RW%% SET
        rid 		= :reportId,
        raport 		= :reportData,
        time 		= :time,
        attacker	= :attackers,
        defender	= :defenders,
        clima_id	= :climaId,
        buff_id		= :buffId;';

        $db->insert($sql, array(
            ':reportId'		=> $reportID,
            ':reportData'	=> serialize($reportData),
            ':time'			=> $this->_fleet['fleet_start_time'],
            ':attackers'	=> implode(',', array_keys($userAttack)),
            ':defenders'	=> implode(',', array_keys($userDefend)),
            ':climaId'		=> $climaId,
            ':buffId'		=> $buffId
        ));

        $i = 0;

        foreach(array($userAttack, $userDefend) as $data)
        {
            foreach($data as $userID => $userName)
            {
                $LNG		= $this->getLanguage(NULL, $userID);
                
                $message	= sprintf($messageHTML,
                    $reportID,
                    $class[$i],
                    $LNG['sys_mess_attack_report'],
                    sprintf(
                        $LNG['sys_adress_planet'],
                        $this->_fleet['fleet_end_galaxy'],
                        $this->_fleet['fleet_end_system'],
                        $this->_fleet['fleet_end_planet']
                    ),
                    $LNG['type_planet_short_'.$this->_fleet['fleet_end_type']],
                    $LNG['sys_lost'],
                    $class[0],
                    $LNG['sys_attack_attacker_pos'],
                    pretty_number($combatResult['unitLost']['attacker']),
                    $class[1],
                    $LNG['sys_attack_defender_pos'],
                    pretty_number($combatResult['unitLost']['defender']),
                    $LNG['sys_gain'],
                    $LNG['tech'][901],
                    pretty_number($stealResource[901]),
                    $LNG['tech'][902],
                    pretty_number($stealResource[902]),
                    $LNG['tech'][903],
                    pretty_number($stealResource[903]),
                    $LNG['sys_debris'],
                    $LNG['tech'][901],
                    pretty_number($debris[901]), 
                    $LNG['tech'][902],
                    pretty_number($debris[902])
                );

                PlayerUtil::sendMessage($userID, 0, $LNG['sys_mess_tower'], 3, $LNG['sys_mess_attack_report'],
                    $message, $this->_fleet['fleet_start_time'], NULL, 1, $this->_fleet['fleet_universe']);

                $sql	= "INSERT INTO %%TOPKB_USERS%% SET
                rid			= :reportId,
                role		= :userRole,
                username	= :username,
                uid			= :userId;";

                $db->insert($sql, array(
                    ':reportId'	=> $reportID,
                    ':userRole'	=> $i + 1,
                    ':username'	=> $userName,
                    ':userId'	=> $userID
                ));

                if ($i == 0) {
                    $totalAttackers = count($userAttack);
                    if ($totalAttackers > 0) {
                        $puntosDestruccion = round($combatResult['unitLost']['defender'] / $totalAttackers);
                        if ($puntosDestruccion > 0) {
                            $this->safeTournement($userID, 3, $puntosDestruccion);
                        }
                    }
                } elseif ($i == 1) {
                    $totalDefenders = count($userDefend);
                    if ($totalDefenders > 0) {
                        $puntosDestruccion = round($combatResult['unitLost']['attacker'] / $totalDefenders);
                        if ($puntosDestruccion > 0) {
                            $this->safeTournement($userID, 3, $puntosDestruccion);
                        }
                    }
                }
            }

            $i++;
        }
        
        if($this->_fleet['fleet_end_type'] == 3)
        {
            $debrisType	= 'id_luna';
        }
        else
        {
            $debrisType	= 'id';
        }
        
        $sql = 'UPDATE %%PLANETS%% SET
        der_metal	= :metal,
        der_crystal	= :crystal
        WHERE '.$debrisType.' = :planetId;';

        $db->update($sql, array(
            ':metal'	=> $planetDebris[901],
            ':crystal'	=> $planetDebris[902],
            ':planetId'	=> $this->_fleet['fleet_end_id']
        ));

        $sql = 'UPDATE %%PLANETS%% SET
        metal		= metal - :metal,
        crystal		= crystal - :crystal,
        deuterium	= deuterium - :deuterium
        WHERE id = :planetId;';

        $db->update($sql, array(
            ':metal'		=> $stealResource[901],
            ':crystal'		=> $stealResource[902],
            ':deuterium'	=> $stealResource[903],
            ':planetId'		=> $this->_fleet['fleet_end_id']
        ));

        $sql = 'INSERT INTO %%TOPKB%% SET
        units 		= :units,
        rid			= :reportId,
        time		= :time,
        universe	= :universe,
        result		= :result;';

        $db->insert($sql, array(
            ':units'	=> $combatResult['unitLost']['attacker'] + $combatResult['unitLost']['defender'],
            ':reportId'	=> $reportID,
            ':time'		=> $this->_fleet['fleet_start_time'],
            ':universe'	=> $this->_fleet['fleet_universe'],
            ':result'	=> $combatResult['won']
        ));

        $sql = 'UPDATE %%USERS%% SET
        `'.$attackStatus.'` = `'.$attackStatus.'` + 1,
        kbmetal		= kbmetal + :debrisMetal,
        kbcrystal	= kbcrystal + :debrisCrystal,
        lostunits	= lostunits + :lostUnits,
        desunits	= desunits + :destroyedUnits
        WHERE id IN ('.implode(',', array_keys($userAttack)).');';

        $db->update($sql, array(
            ':debrisMetal'		=> $debris[901],
            ':debrisCrystal'	=> $debris[902],
            ':lostUnits'		=> $combatResult['unitLost']['attacker'],
            ':destroyedUnits'	=> $combatResult['unitLost']['defender']
      	));

        $sql = 'UPDATE %%USERS%% SET
        `'.$defendStatus.'` = `'.$defendStatus.'` + 1,
        kbmetal		= kbmetal + :debrisMetal,
        kbcrystal	= kbcrystal + :debrisCrystal,
        lostunits	= lostunits + :lostUnits,
        desunits	= desunits + :destroyedUnits
        WHERE id IN ('.implode(',', array_keys($userDefend)).');';

        $db->update($sql, array(
            ':debrisMetal'		=> $debris[901],
            ':debrisCrystal'	=> $debris[902],
            ':lostUnits'		=> $combatResult['unitLost']['defender'],
            ':destroyedUnits'	=> $combatResult['unitLost']['attacker']
        ));

        $destroyedUnits	= (int)$combatResult['unitLost']['defender'];

        if ($destroyedUnits > 0) {
            foreach (array_keys($userAttack) as $attackerId) {
                $this->safeUpdateEventProgress($attackerId, 'destroy_units', $destroyedUnits);
            }
        }

        $this->setState(FLEET_RETURN);
        $this->SaveFleet();
    }
    
    function EndStayEvent()
    {
        return;
    }
    
    function ReturnEvent()
    {
        $LNG		= $this->getLanguage(NULL, $this->_fleet['fleet_owner']);

        $sql		= 'SELECT name FROM %%PLANETS%% WHERE id = :planetId;';
        $planetName	= Database::get()->selectSingle($sql, array(
            ':planetId'	=> $this->_fleet['fleet_start_id'],
        ), 'name');

        $Message	= sprintf(
            $LNG['sys_fleet_won'],
            $planetName,
            GetTargetAddressLink($this->_fleet, ''),
            pretty_number($this->_fleet['fleet_resource_metal']),
            $LNG['tech'][901],
            pretty_number($this->_fleet['fleet_resource_crystal']),
            $LNG['tech'][902],
            pretty_number($this->_fleet['fleet_resource_deuterium']),
            $LNG['tech'][903]
        );

        PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 4, $LNG['sys_mess_fleetback'],
            $Message, $this->_fleet['fleet_end_time'], NULL, 1, $this->_fleet['fleet_universe']);

        $this->RestoreFleet();
    }
}