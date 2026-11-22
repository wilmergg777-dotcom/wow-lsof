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

require_once 'includes/classes/cronjob/CronjobTask.interface.php';

class StatisticCronjob implements CronjobTask
{
	function run()
	{
		require 'includes/classes/class.statbuilder.php';
		$stat	= new Statbuilder();
		$statData = $stat->MakeStats();

		// ============================================
		// ACTUALIZAR TIMESTAMP DE STATS EN CONFIG
		// ============================================
		$db = Database::get();

		$db->update(
			"UPDATE %%CONFIG%% SET 
				stat_last_update = :time,
				stat_last_db_update = :time",
			array(':time' => TIMESTAMP)
		);
	}
}