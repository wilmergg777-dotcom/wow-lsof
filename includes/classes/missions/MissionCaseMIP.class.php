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
 * AstroIO v1.2 (MISILES 504 y 505 — MECÁNICA ×3):
 *  - Misil 504 (Antimateria): ahora destruye 3 defensas por unidad (×3).
 *  - Misil 505 (Interceptor Avanzado): ahora intercepta 3 misiles por
 *    unidad (×3) al defender.
 *  - Misil 503 (Interplanetario): sigue destruyendo 1 defensa por unidad.
 *  - Misil 502 (Intercepción): sigue interceptando 1 misil por unidad.
 *  - El tipo de misil entrante se detecta automáticamente desde
 *    fleet_array (compatible con formato serializado y "id,count;").
 *  - La intercepción del 505 se suma a la del 502:
 *      poder de intercepción = 502×1 + 505×3
 *  - Se consume 502 primero, luego 505, para no desperdiciar 505
 *    cuando el 502 alcanza.
 *  - El 505 ya NO cuenta como "defensa destructible" (se quita de
 *    targetDefensive); solo actúa como interceptor.
 *  - El 504 SI sigue siendo "destructible" como inventario (igual que
 *    el 503 original).
 *  - Preserva el 100% de la lógica original para 502 y 503.
 */

class MissionCaseMIP extends MissionFunctions implements Mission
{
	function __construct($Fleet)
	{
		$this->_fleet	= $Fleet;
	}
	
	function TargetEvent()
	{
		global $resource, $reslist;

		$db	= Database::get();

		$sqlFields	= array();
		$elementIDs	= array_merge($reslist['defense'], $reslist['missile']);

		foreach($elementIDs as $elementID)
		{
			$sqlFields[]	= '%%PLANETS%%.`'.$resource[$elementID].'`';
		}
			
		$sql = 'SELECT lang, shield_tech,
		%%PLANETS%%.id, name, id_owner, '.implode(', ', $sqlFields).'
		FROM %%PLANETS%%
		INNER JOIN %%USERS%% ON id_owner = %%USERS%%.id
		WHERE %%PLANETS%%.id = :planetId;';

		$targetData	= $db->selectSingle($sql, array(
			':planetId'	=> $this->_fleet['fleet_end_id']
		));

		// ASTROIO v1.2: si el objetivo es una luna, leer también el 505
		// del planeta padre (igual que ya hace el 502 original).
		if($this->_fleet['fleet_end_type'] == 3)
		{
			$sql	= 'SELECT '.$resource[502].', '.$resource[505].' FROM %%PLANETS%% WHERE id_luna = :moonId;';
			$moonParent = $db->selectSingle($sql, array(
				':moonId'	=> $this->_fleet['fleet_end_id']
			));
			$targetData[$resource[502]]	= $moonParent[$resource[502]] ?? 0;
			$targetData[$resource[505]]	= $moonParent[$resource[505]] ?? 0;
		}

		// ASTROIO v1.2: asegurar índices (compatibilidad hacia atrás)
		if (!isset($targetData[$resource[502]])) {
			$targetData[$resource[502]] = 0;
		}
		if (!isset($targetData[$resource[505]])) {
			$targetData[$resource[505]] = 0;
		}
		if (!isset($targetData[$resource[504]])) {
			$targetData[$resource[504]] = 0;
		}

		$sql		= 'SELECT lang, military_tech FROM %%USERS%% WHERE id = :userId;';
		$senderData	= $db->selectSingle($sql, array(
			':userId'	=> $this->_fleet['fleet_owner']
		));

		if(!in_array($this->_fleet['fleet_target_obj'], array_merge($reslist['defense'], $reslist['missile']))
			|| $this->_fleet['fleet_target_obj'] == 502
			|| $this->_fleet['fleet_target_obj'] == 0)
		{
			$primaryTarget	= 401;
		}
		else
		{
			$primaryTarget	= $this->_fleet['fleet_target_obj'];
		}

        $targetDefensive    = array();

		foreach($elementIDs as $elementID)	
		{
			$targetDefensive[$elementID]	= $targetData[$resource[$elementID]];
		}
		
		// ASTROIO v1.2: 502 y 505 son interceptores, no "defensas destructibles"
		unset($targetDefensive[502], $targetDefensive[505]);

		$LNG	= $this->getLanguage(Config::get($this->_fleet['fleet_universe'])->lang, array('L18N', 'FLEET', 'TECH'));

		// ============================================
		// ASTROIO v1.2 — Detección del tipo de misil entrante
		// ============================================
		$missileType = $this->detectIncomingMissileType($reslist);
		$destructionMultiplier = ($missileType == 504) ? 3 : 1;

		$fleetAmount = (int) $this->_fleet['fleet_amount'];
		$defender502 = (int) $targetData[$resource[502]];
		$defender505 = (int) $targetData[$resource[505]];

		// Poder total de intercepción: 502×1 + 505×3
		$totalInterceptPower = $defender502 + ($defender505 * 3);
		// ============================================
		// FIN ASTROIO v1.2 — Detección
		// ============================================
				
		if ($totalInterceptPower >= $fleetAmount && $fleetAmount > 0)
		{
			// ============================================
			// ASTROIO v1.2: TODO interceptado (502 + 505)
			// ============================================
			$message 	= $LNG['sys_irak_no_att'];
			$where 		= $this->_fleet['fleet_end_type'] == 3 ? 'id_luna' : 'id';
			
			// Consumir 502 primero, luego 505 (ceil para no dejar
			// misiles "a medias" absorbidos)
			$consumed502 = min($defender502, $fleetAmount);
			$need505     = $fleetAmount - $consumed502;
			$consumed505 = ($need505 > 0) ? min($defender505, (int) ceil($need505 / 3)) : 0;

			if ($consumed502 > 0 || $consumed505 > 0)
			{
				$sql		= 'UPDATE %%PLANETS%% SET '
							. $resource[502].' = '.$resource[502].' - :amount502, '
							. $resource[505].' = '.$resource[505].' - :amount505 '
							. 'WHERE '.$where.' = :planetId;';

				$db->update($sql, array(
					':amount502'	=> $consumed502,
					':amount505'	=> $consumed505,
					':planetId'		=> $targetData['id']
				));
			}
		}
		else
		{
			// ============================================
			// ASTROIO v1.2: Intercepción parcial (502 + 505)
			// ============================================
			if ($defender502 > 0 || $defender505 > 0)
			{
				$where 	= $this->_fleet['fleet_end_type'] == 3 ? 'id_luna' : 'id';
				$sql	= 'UPDATE %%PLANETS%% SET '
						. $resource[502].' = 0, '
						. $resource[505].' = 0 '
						. 'WHERE '.$where.' = :planetId;';

				$db->update($sql, array(
					':planetId'	=> $targetData['id']
				));
			}
			
			$targetDefensive = array_filter($targetDefensive);
			
			if(!empty($targetDefensive))
			{
				// Misiles que pasaron la intercepción
				$remainingMissiles = max(0, $fleetAmount - $totalInterceptPower);

				// ASTROIO v1.2: multiplicador de destrucción según tipo
				// 503 → 1× (comportamiento original)
				// 504 → 3× (destruye 3 defensas por unidad)
				$effectiveAmount = $remainingMissiles * $destructionMultiplier;

				require_once 'includes/classes/missions/functions/calculateMIPAttack.php';
				$result   	= calculateMIPAttack($targetData["shield_tech"], $senderData["military_tech"],
					$effectiveAmount, $targetDefensive, $primaryTarget, 0);

				$result		= array_filter($result);
				
				// Mensaje: cuántos misiles fueron interceptados en total
				$totalIntercepted = $fleetAmount - $remainingMissiles;
				$message	= sprintf($LNG['sys_irak_def'], $totalIntercepted).'<br><br>';
				
				ksort($result, SORT_NUMERIC);
				
				foreach ($result as $Element => $destroy)
				{
					$message .= sprintf('%s (- %d)<br>', $LNG['tech'][$Element], $destroy);

					$sql	= 'UPDATE %%PLANETS%% SET '.$resource[$Element].' = '.$resource[$Element].' - :amount WHERE id = :planetId;';
					$db->update($sql, array(
						':planetId' => $targetData['id'],
						':amount'	=> $destroy
					));
				}
			}
			else
			{
				$message = $LNG['sys_irak_no_def'];
			}
		}

		$sql		= 'SELECT name FROM %%PLANETS%% WHERE id = :planetId;';
		$planetName	= Database::get()->selectSingle($sql, array(
			':planetId'	=> $this->_fleet['fleet_start_id'],
		), 'name');

		$ownerLink			= $planetName." ".GetStartAddressLink($this->_fleet);
		$targetLink 		= $targetData['name']." ".GetTargetAddressLink($this->_fleet);
		$message			= sprintf($LNG['sys_irak_mess'], $this->_fleet['fleet_amount'], $ownerLink, $targetLink).$message;

		PlayerUtil::sendMessage($this->_fleet['fleet_owner'], 0, $LNG['sys_mess_tower'], 3,
			$LNG['sys_irak_subject'], $message, $this->_fleet['fleet_start_time'], NULL, 1, $this->_fleet['fleet_universe']);

		PlayerUtil::sendMessage($this->_fleet['fleet_target_owner'], 0, $LNG['sys_mess_tower'], 3,
			$LNG['sys_irak_subject'], $message, $this->_fleet['fleet_start_time'], NULL, 1, $this->_fleet['fleet_universe']);

		$this->KillFleet();
	}
	
	/**
	 * ASTROIO v1.2 — Detecta el tipo de misil entrante desde fleet_array.
	 * Soporta:
	 *   1) Serializado PHP:    'a:1:{i:504;i:3;}'
	 *   2) Formato string:     '504,3'  o  '504,3;503,1'
	 * Si no puede detectar, devuelve 503 (compatibilidad hacia atrás).
	 *
	 * @param  array $reslist Lista global de reslist['missile']
	 * @return int   elementID del misil entrante
	 */
	private function detectIncomingMissileType($reslist)
	{
		$default = 503;
		$raw = isset($this->_fleet['fleet_array']) ? $this->_fleet['fleet_array'] : '';

		if (empty($raw)) {
			return $default;
		}

		// Formato 1: serializado (array de PHP)
		$parsed = @unserialize($raw);
		if (is_array($parsed) && !empty($parsed)) {
			foreach ($parsed as $elemID => $count) {
				if (in_array((int) $elemID, $reslist['missile'], true)) {
					return (int) $elemID;
				}
			}
			return $default;
		}

		// Formato 2: "id,count;id,count"
		$parts = explode(';', $raw);
		foreach ($parts as $part) {
			$sub = explode(',', $part);
			if (count($sub) >= 2) {
				$elemID = (int) $sub[0];
				if (in_array($elemID, $reslist['missile'], true)) {
					return $elemID;
				}
			}
		}

		return $default;
	}
	
	function EndStayEvent()
	{
		return;
	}
	
	function ReturnEvent()
	{
		return;
	}
}