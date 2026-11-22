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
 * ✅ AstroIO v1.1 (Mini Torneos):
 *   - Enganche a tournement() al destruir una luna:
 *       Torneo 9 (destrucción de lunas a jugadores activos)
 *   - Solo cuenta si el dueño de la luna estuvo activo en los últimos 7 días.
 *   - La creación de lunas (Torneo 10) se dispara desde MissionCaseAttack.
 *
 * ✅ AstroIO v1.2 (SISTEMA DE CLIMA):
 *   - Se carga ClimaEngine.
 *   - Se lee el clima_id guardado en la flota al lanzar (o se consulta el clima actual si es una flota antigua).
 *   - Se aplican los 4 factores (ataque, defensa, bajas, botín) al combate.
 *   - Se guarda clima_id en el reporte de batalla (%%RW%%).
 *
 * ✅ AstroIO v1.3 (BUFF CLIMÁTICO):
 *   - Se lee fleets.buff_id (fijado al lanzar) y se aplica con ClimaEngine::applyBuff().
 *   - Solo modifica factores negativos (los positivos se quedan igual).
 *   - Se guarda buff_id en el reporte de batalla (%%RW%%) para auditoría.
 *
 * ✅ AstroIO v1.4 (OFICIAL ASTRÓNOMO):
 *   - Se lee rpg_astronomo del atacante.
 *   - Reduce las penalizaciones climáticas según el nivel del Astrónomo.
 *
 * ✅ AstroIO v1.5 (ASTRÓNOMO — FIX FACTOR BAJAS):
 *   - La mitigación del Astrónomo ahora cubre correctamente factor_bajas:
 *     en el motor de combate, factor_bajas > 1.00 es la PENALIZACIÓN (más bajas),
 *     por eso la reducción se aplica al exceso por encima de 1.00.
 *   - factor_bajas < 1.00 es un bonus y NO se toca.
 *   - Tope de seguridad del nivel a 5.
 */

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

class MissionCaseDestruction extends MissionFunctions implements Mission
{
    function __construct($Fleet)
    {
        $this->_fleet	= $Fleet;
    }

    function TargetEvent()
    {
        global $resource, $reslist;

        $db				= Database::get();

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
        // ASTROIO v1.2 (SISTEMA DE CLIMA) - Obtener clima del objetivo
        // ============================================
        $climaInfo = null;
        if (class_exists('ClimaEngine')) {
            if (!empty($this->_fleet['clima_id'])) {
                // Usar el clima fijado al lanzar la flota
                $climaInfo = ClimaEngine::getFactoresPorClimaId($this->_fleet['clima_id']);
            } else {
                // Fallback: usar el clima actual del planeta/luna objetivo
                $climaInfo = ClimaEngine::getFactoresPlaneta($this->_fleet['fleet_end_id']);
            }
        }

        // Valores por defecto si no hay clima
        $factorAtaque  = isset($climaInfo['factor_ataque'])  ? $climaInfo['factor_ataque']  : 1.0;
        $factorDefensa = isset($climaInfo['factor_defensa']) ? $climaInfo['factor_defensa'] : 1.0;
        $factorBajas   = isset($climaInfo['factor_bajas'])   ? $climaInfo['factor_bajas']   : 1.0;
        $factorBotin   = isset($climaInfo['factor_botin'])   ? $climaInfo['factor_botin']   : 1.0;
        $climaId       = !empty($this->_fleet['clima_id']) ? (int)$this->_fleet['clima_id'] : (isset($climaInfo['clima_id']) ? (int)$climaInfo['clima_id'] : null);
        // ============================================

        // ============================================
        // ASTROIO v1.3 — Cargar y aplicar BUFF CLIMÁTICO
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
        // ASTROIO v1.5 — OFICIAL ASTRÓNOMO (Mitigación Climática — FIX BAJAS)
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

            // ASTROIO v1.2 — Aplicar clima al atacante
            $fleetAttack[$fleetID]['player']['factor']['Attack']    *= $factorAtaque;
            $fleetAttack[$fleetID]['player']['factor']['Defensive'] *= $factorDefensa;

            $fleetAttack[$fleetID]['fleetDetail']		= $fleetDetail;
            $fleetAttack[$fleetID]['unit']				= FleetFunctions::unserialize($fleetDetail['fleet_array']);

            $userAttack[$fleetAttack[$fleetID]['player']['id']]	= $fleetAttack[$fleetID]['player']['username'];
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

            // ASTROIO v1.2 — Aplicar clima al defensor (flotas estacionadas)
            $fleetDefend[$fleetID]['player']['factor']['Attack']    *= $factorAtaque;
            $fleetDefend[$fleetID]['player']['factor']['Defensive'] *= $factorDefensa;

            $fleetDefend[$fleetID]['fleetDetail']		= $fleetDetail;
            $fleetDefend[$fleetID]['unit']				= FleetFunctions::unserialize($fleetDetail['fleet_array']);

            $userDefend[$fleetDefend[$fleetID]['player']['id']]	= $fleetDefend[$fleetID]['player']['username'];
        }

        unset($targetFleetsResult);

        $fleetDefend[0]['player']			= $targetUser;
        $fleetDefend[0]['player']['factor']	= getFactors($fleetDefend[0]['player'], 'attack', $this->_fleet['fleet_start_time']);

        // ASTROIO v1.2 — Aplicar clima al defensor (planeta/luna)
        $fleetDefend[0]['player']['factor']['Attack']    *= $factorAtaque;
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

        require_once 'includes/classes/missions/functions/calculateAttack.php';

        $fleetIntoDebris	= Config::get($this->_fleet['fleet_universe'])->Fleet_Cdr;
        $defIntoDebris		= Config::get($this->_fleet['fleet_universe'])->Defs_Cdr;

        $combatResult 		= calculateAttack($fleetAttack, $fleetDefend, $fleetIntoDebris, $defIntoDebris);

        // ============================================
        // ASTROIO v1.2 — Aplicar factor de Bajas
        // ============================================
        if ($factorBajas != 1.00) {
            // Aplicar a naves atacantes
            foreach ($fleetAttack as $fleetID => &$fleetDetail) {
                if (empty($fleetDetail['unit'])) continue;
                foreach ($fleetDetail['unit'] as $elementID => &$amount) {
                    if ($amount > 0) {
                        $amount = (int)floor($amount / $factorBajas);
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
                // Stay fleet
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

                // Planet fleet
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

            // ASTROIO v1.2 — Aplicar factor de Botín
            if ($factorBotin != 1.00) {
                $stealResource[901] = (int)floor($stealResource[901] * $factorBotin);
                $stealResource[902] = (int)floor($stealResource[902] * $factorBotin);
                $stealResource[903] = (int)floor($stealResource[903] * $factorBotin);
            }
        }

        if($this->_fleet['fleet_end_type'] == 3)
        {
            // Use planet debris, if attack on moons
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

        $reportInfo	= array(
            'thisFleet'				=> $this->_fleet,
            'debris'				=> $debris,
            'stealResource'			=> $stealResource,
            'moonChance'			=> NULL,
            'moonDestroy'			=> true,
            'moonName'				=> NULL,
            'moonDestroyChance'		=> NULL,
            'moonDestroySuccess'	=> NULL,
            'fleetDestroyChance'	=> NULL,
            'fleetDestroySuccess'	=> false,
        );

        $moonDestroyStatus				= false;

        switch($combatResult['won'])
        {
            // Win
            case "a":
                $moonDestroyChance	= round((100 - sqrt($targetPlanet['diameter'])) * sqrt($fleetAttack[$this->_fleet['fleet_id']]['unit'][214]), 1);

                // Max 100% | Min 0%
                $moonDestroyChance	= min($moonDestroyChance, 100);
                $moonDestroyChance	= max($moonDestroyChance, 0);

                $randChance	= mt_rand(1, 100);

                if ($randChance <= $moonDestroyChance)
                {
                    $sql		= 'SELECT id FROM %%PLANETS%% WHERE id_luna = :moonId;';
                    $planetID	= $db->selectSingle($sql, array(
                        ':moonId'	=> $targetPlanet['id']
                    ), 'id');


                    $sql		= 'UPDATE %%FLEETS%% SET
                    fleet_start_type		= 1,
                    fleet_start_id			= :planetId
                    WHERE fleet_start_id	= :moonId;';

                    $db->update($sql, array(
                        ':planetId'	=> $planetID,
                        ':moonId'	=> $targetPlanet['id']
                    ));

                    $sql		= 'UPDATE %%FLEETS%% SET
                    fleet_end_type	= 1,
                    fleet_end_id	= :moonId,
                    fleet_mission	= IF(fleet_mission = 9, 1, fleet_mission)
                    WHERE fleet_end_id = :planetId
                    AND fleet_id != :fleetId;';

                    $db->update($sql, array(
                        ':planetId'	=> $planetID,
                        ':moonId'	=> $targetPlanet['id'],
                        ':fleetId'	=> $this->_fleet['fleet_id']
                    ));

                    $sql = "UPDATE %%AKS%% SET target = :planetId WHERE target = :moonId;";
                    $db->update($sql, array(
                        ':planetId'	=> $planetID,
                        ':moonId'	=> $targetPlanet['id']
                    ));

                    PlayerUtil::deletePlanet($targetPlanet['id']);
                    $moonDestroyStatus	= $planetID;

                    $reportInfo['moonDestroySuccess'] = 1;

                    // ============================================
                    // ASTROIO v1.1 - Mini Torneos: destrucción de luna
                    // Torneo 9 (destrucción de lunas a jugadores activos)
                    // Solo cuenta si el dueño de la luna estuvo activo en los últimos 7 días.
                    // ============================================
                    if (isset($targetUser['onlinetime']) && $targetUser['onlinetime'] > TIMESTAMP - 24 * 3600 * 7) {
                        foreach (array_keys($userAttack) as $attackerId) {
                            tournement($attackerId, 9, 1);
                        }
                    }
                    // ============================================

                } else {
                    $reportInfo['moonDestroySuccess'] = 0;
                }

                $fleetDestroyChance	= round(sqrt($targetPlanet['diameter']) / 2);

                $randChance	= mt_rand(1, 100);
                if ($randChance <= $fleetDestroyChance)
                {
                    $this->KillFleet();
                    $reportInfo['fleetDestroySuccess'] = true;
                }
                else
                {
                    $reportInfo['fleetDestroySuccess'] = false;
                }


                $reportInfo['moonDestroyChance']	= $moonDestroyChance;
                $reportInfo['fleetDestroyChance']	= $fleetDestroyChance;

                $attackStatus	= 'wons';
                $defendStatus	= 'loos';
                $class			= array('raportWin', 'raportLose');
                break;
            case "r":
                // Lose
                $attackStatus	= 'loos';
                $defendStatus	= 'wons';
                $class			= array('raportLose', 'raportWin');
                $reportInfo['moonDestroySuccess'] = -1;
                break;
            default:
                // Draw
                $attackStatus	= 'draws';
                $defendStatus	= 'draws';
                $class			= array('raportDraw', 'raportDraw');
                $reportInfo['moonDestroySuccess'] = -1;
                break;
        }

        require_once 'includes/classes/missions/functions/GenerateReport.php';
        $reportData	= GenerateReport($combatResult, $reportInfo);

        $reportID	= md5(uniqid('', true).TIMESTAMP);

        // ASTROIO v1.3 — Se añade clima_id y buff_id al reporte
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
                    ':userRole'	=> 1,
                    ':username'	=> $userName,
                    ':userId'	=> $userID
                ));
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

        if ($moonDestroyStatus)
        {
            $sql = 'UPDATE %%PLANETS%% SET
            der_metal	= :metal,
            der_crystal	= :crystal
            WHERE id = :planetId;';

            $db->update($sql, array(
                ':metal'	=> $planetDebris[901],
                ':crystal'	=> $planetDebris[902],
                ':planetId'	=> $moonDestroyStatus
            ));
        }
        else
        {
            $sql = 'UPDATE %%PLANETS%% SET
            der_metal	= :metal,
            der_crystal	= :crystal
            WHERE '.$debrisType.' = :planetId;';

            $db->update($sql, array(
                ':metal'	=> $planetDebris[901],
                ':crystal'	=> $planetDebris[902],
                ':planetId'	=> $this->_fleet['fleet_end_id']
            ));
        }

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
            pretty_number($this->_fleet['fleet_resource_metal']), $LNG['tech'][901],
            pretty_number($this->_fleet['fleet_resource_crystal']), $LNG['tech'][902],
            pretty_number($this->_fleet['fleet_resource_deuterium']), $LNG['tech'][903]
        );

        PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 4, $LNG['sys_mess_fleetback'],
            $Message, $this->_fleet['fleet_end_time'], NULL, 1, $this->_fleet['fleet_universe']);

        $this->RestoreFleet();
    }
}
?>