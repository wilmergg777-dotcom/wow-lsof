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
 * AstroIO v1.1 (SISTEMA DE CLIMA):
 *   - Se integra ClimaEngine para mostrar el clima en el reporte.
 *
 * AstroIO v1.2 (BUFF CLIMÁTICO):
 *   - Se lee buff_id de uni1_raports.
 *   - Se pasa $buffInfo al template para mostrar el buff aplicado.
 */

// ============================================
// ASTROIO - Cargar ClimaEngine explicitamente
// ============================================
if (!class_exists('ClimaEngine')) {
    $__climaFile = (defined('ROOT_PATH') ? ROOT_PATH : '') . 'includes/classes/ClimaEngine.class.php';
    if (file_exists($__climaFile)) {
        require_once $__climaFile;
    }
}
// ============================================

class ShowRaportPage extends AbstractGamePage
{
	public static $requireModule = 0;
	
	protected $disableEcoSystem = true;

	function __construct() 
	{
		parent::__construct();
	}
	
	private function BCWrapperPreRev2321($combatReport)
	{
		if(isset($combatReport['moon']['desfail']))
		{
			$combatReport['moon']	= array(
				'moonName'				=> $combatReport['moon']['name'],
				'moonChance'			=> $combatReport['moon']['chance'],
				'moonDestroySuccess'	=> !$combatReport['moon']['desfail'],
				'fleetDestroyChance'	=> $combatReport['moon']['chance2'],
				'fleetDestroySuccess'	=> !$combatReport['moon']['fleetfail']
			);			
		}
		elseif(isset($combatReport['moon'][0]))
		{
			$combatReport['moon']	= array(
				'moonName'				=> $combatReport['moon'][1],
				'moonChance'			=> $combatReport['moon'][0],
				'moonDestroySuccess'	=> !$combatReport['moon'][2],
				'fleetDestroyChance'	=> $combatReport['moon'][3],
				'fleetDestroySuccess'	=> !$combatReport['moon'][4]
			);			
		}
		
		if(isset($combatReport['simu']))
		{
			$combatReport['additionalInfo'] = $combatReport['simu'];
		}
		
		if(isset($combatReport['debris'][0]))
		{
            $combatReport['debris'] = array(
                901	=> $combatReport['debris'][0],
                902	=> $combatReport['debris'][1]
            );
		}
		
		if (!empty($combatReport['steal']['metal']))
		{
			$combatReport['steal'] = array(
				901	=> $combatReport['steal']['metal'],
				902	=> $combatReport['steal']['crystal'],
				903	=> $combatReport['steal']['deuterium']
			);
		}
		
		return $combatReport;
	}
	
	function battlehall() 
	{
		global $LNG, $USER;
		
		$LNG->includeData(array('FLEET'));
		$this->setWindow('popup');

		$db = Database::get();

		$RID		= HTTP::_GP('raport', '');

		// ASTROIO v1.2 — Añadido buff_id al SELECT
		$sql = "SELECT 
			raport, time, clima_id, buff_id,
			(
				SELECT
				GROUP_CONCAT(username SEPARATOR ' & ') as attacker
				FROM %%USERS%%
				WHERE id IN (SELECT uid FROM %%TOPKB_USERS%% WHERE %%TOPKB_USERS%%.rid = %%RW%%.rid AND role = 1)
			) as attacker,
			(
				SELECT
				GROUP_CONCAT(username SEPARATOR ' & ') as defender
				FROM %%USERS%%
				WHERE id IN (SELECT uid FROM %%TOPKB_USERS%% WHERE %%TOPKB_USERS%%.rid = %%RW%%.rid AND role = 2)
			) as defender
			FROM %%RW%%
			WHERE rid = :reportID;";
		$reportData = $db->selectSingle($sql, array(
			':reportID'	=> $RID
		));

		$Info		= array($reportData["attacker"], $reportData["defender"]);
		
		if(!isset($reportData)) {
			$this->printMessage($LNG['sys_raport_not_found']);
		}
		
		$combatReport			= unserialize($reportData['raport']);
		$combatReport['time']	= _date($LNG['php_tdformat'], $combatReport['time'], $USER['timezone']);
		$combatReport			= $this->BCWrapperPreRev2321($combatReport);

		// ASTROIO v1.2 — Cargar datos del clima y buff
		$climaInfo = null;
		if (!empty($reportData['clima_id']) && class_exists('ClimaEngine')) {
			$climaInfo = ClimaEngine::getFactoresPorClimaId((int)$reportData['clima_id']);
		}

		$buffInfo = null;
		$buffId = !empty($reportData['buff_id']) ? (int)$reportData['buff_id'] : 0;
		if ($buffId > 0 && class_exists('ClimaEngine')) {
			$buffInfo = ClimaEngine::getBuffInfo($buffId);
		}
		
		$this->assign(array(
			'Raport'	=> $combatReport,
			'Info'		=> $Info,
			'climaInfo'	=> $climaInfo, // ASTROIO
			'buffInfo'	=> $buffInfo,  // ASTROIO
			'pageTitle'	=> $LNG['lm_topkb']
		));
		
		$this->display('shared.mission.raport.tpl');
	}
	
	function show() 
	{
		global $LNG, $USER;
		
		$LNG->includeData(array('FLEET'));		
		$this->setWindow('popup');

		$db = Database::get();

		$RID		= HTTP::_GP('raport', '');

		// ASTROIO v1.2 — Añadido buff_id al SELECT
		$sql = "SELECT raport, attacker, defender, clima_id, buff_id FROM %%RW%% WHERE rid = :reportID;";
		$reportData = $db->selectSingle($sql, array(
			':reportID'	=> $RID
		));

		if(empty($reportData)) {
			$this->printMessage($LNG['sys_raport_not_found']);
		}
		
		// empty is BC for pre r2484
		$isAttacker = empty($reportData['attacker']) || in_array($USER['id'], explode(",", $reportData['attacker']));
		$isDefender = empty($reportData['defender']) || in_array($USER['id'], explode(",", $reportData['defender']));
		
		if(empty($reportData) || (!$isAttacker && !$isDefender)) {
			$this->printMessage($LNG['sys_raport_not_found']);
		}

		$combatReport			= unserialize($reportData['raport']);
		if($isAttacker && !$isDefender && $combatReport['result'] == 'r' && count($combatReport['rounds']) <= 2) {
			$this->printMessage($LNG['sys_raport_lost_contact']);
		}
		
		$combatReport['time']	= _date($LNG['php_tdformat'], $combatReport['time'], $USER['timezone']);
		$combatReport			= $this->BCWrapperPreRev2321($combatReport);

		// ASTROIO v1.2 — Cargar datos del clima y buff
		$climaInfo = null;
		if (!empty($reportData['clima_id']) && class_exists('ClimaEngine')) {
			$climaInfo = ClimaEngine::getFactoresPorClimaId((int)$reportData['clima_id']);
		}

		$buffInfo = null;
		$buffId = !empty($reportData['buff_id']) ? (int)$reportData['buff_id'] : 0;
		if ($buffId > 0 && class_exists('ClimaEngine')) {
			$buffInfo = ClimaEngine::getBuffInfo($buffId);
		}
		
		$this->assign(array(
			'Raporter'	=> $combatReport, // typo heredado
			'Raport'	=> $combatReport,
			'climaInfo'	=> $climaInfo, // ASTROIO
			'buffInfo'	=> $buffInfo,  // ASTROIO
			'pageTitle'	=> $LNG['sys_mess_attack_report']
		));
		
		$this->display('shared.mission.raport.tpl');
	}
}
?>