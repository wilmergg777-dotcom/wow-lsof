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
 * AstroIO v1.1 — FIX FANTASMAS PvE/PvP:
 *   - Las batallas donde participó un fantasma (email @noreply.local)
 *     NO aparecen en el Salón de la Fama.
 *   - Se usa un NOT IN con subconsulta que une TOPKB_USERS con USERS
 *     para poder filtrar por email del atacante o defensor.
 *   - Esto evita que la comunidad vea entradas del Top KB con fantasmas.
 */

class ShowBattleHallPage extends AbstractGamePage
{
	public static $requireModule = MODULE_BATTLEHALL;

	function __construct()
    {
		parent::__construct();
	}

	function show()
	{
		global $USER, $LNG;
		$order  = HTTP::_GP('order', 'units');
		$sort   = HTTP::_GP('sort', 'desc');
		$sort   = strtoupper($sort) === "DESC" ? "DESC" : "ASC";


		switch($order)
		{
			case 'date':
				$key = '%%TOPKB%%.time '.$sort;
				break;
			case 'units':
			default:
				$key = '%%TOPKB%%.units '.$sort;
				break;
		}

		$db = Database::get();

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v1.1 — Filtro de fantasmas por email
		// ═══════════════════════════════════════════════════════════
		// Excluimos cualquier batalla donde el atacante o el defensor
		// tenga email terminado en "@noreply.local" (fantasmas PvE/PvP).
		// El filtro se hace con un NOT IN sobre TOPKB_USERS unido a
		// USERS para poder consultar el email.
		// ═══════════════════════════════════════════════════════════
		$sql = "SELECT *, (
			SELECT DISTINCT
			IF(%%TOPKB_USERS%%.username = '', GROUP_CONCAT(%%USERS%%.username SEPARATOR ' & '), GROUP_CONCAT(%%TOPKB_USERS%%.username SEPARATOR ' & '))
			FROM %%TOPKB_USERS%%
			LEFT JOIN %%USERS%% ON uid = %%USERS%%.id
			WHERE %%TOPKB_USERS%%.rid = %%TOPKB%%.rid AND role = 1
		) as attacker,
		(
			SELECT DISTINCT
			IF(%%TOPKB_USERS%%.username = '', GROUP_CONCAT(%%USERS%%.username SEPARATOR ' & '), GROUP_CONCAT(%%TOPKB_USERS%%.username SEPARATOR ' & '))
			FROM %%TOPKB_USERS%% INNER JOIN %%USERS%% ON uid = id
			WHERE %%TOPKB_USERS%%.rid = %%TOPKB%%.`rid` AND `role` = 2
		) as defender
		FROM %%TOPKB%% 
		WHERE universe = :universe 
		  AND rid NOT IN (
			SELECT tbu.rid 
			FROM %%TOPKB_USERS%% tbu
			INNER JOIN %%USERS%% u ON u.id = tbu.uid
			WHERE u.email LIKE '%@noreply.local'
		  )
		ORDER BY ".$key." LIMIT 100;";

		$top = $db->select($sql, array(
			':universe' => Universe::current()
		));

		$TopKBList	= array();
		foreach($top as $data)
		{
			$TopKBList[]	= array(
				'result'	=> $data['result'],
				'date'		=> _date($LNG['php_tdformat'], $data['time'], $USER['timezone']),
				'time'		=> TIMESTAMP - $data['time'],
				'units'		=> $data['units'],
				'rid'		=> $data['rid'],
				'attacker'	=> $data['attacker'],
				'defender'	=> $data['defender'],
			);
		}

		$this->assign(array(
			'TopKBList'		=> $TopKBList,
			'sort'			=> $sort,
			'order'			=> $order,
		));

		$this->display('page.battleHall.default.tpl');
	}
}