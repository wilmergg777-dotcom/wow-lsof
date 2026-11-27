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
 *   - Los fantasmas tienen email terminado en "@noreply.local".
 *   - Se valida el email ANTES de la query: si es fantasma, se muestra
 *     un mensaje "Perfil no disponible" y se sale.
 *   - También se añade el filtro "u.email NOT LIKE '%@noreply.local'"
 *     como respaldo en la query principal.
 *   - Se evita el "Trying to access array offset on false" cuando el
 *     ID no existe o es inválido.
 */

class ShowPlayerCardPage extends AbstractGamePage
{
    public static $requireModule = MODULE_PLAYERCARD;
	
	protected $disableEcoSystem = true;

	function __construct() 
	{
		parent::__construct();
	}
	
	function show()
	{
		global $USER, $LNG;
		
		$this->setWindow('popup');
		$this->initTemplate();

		$db = Database::get();

		$PlayerID 	= (int) HTTP::_GP('id', 0);

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v1.1 — Validación temprana de fantasmas
		// ═══════════════════════════════════════════════════════════
		// Los fantasmas tienen email terminado en "@noreply.local".
		// Si el ID corresponde a un fantasma, mostramos un mensaje
		// y salimos sin cargar el perfil.
		// ═══════════════════════════════════════════════════════════
		if ($PlayerID <= 0) {
			$this->printMessage(
				'Perfil no disponible.',
				array(array(
					'label' => 'Volver',
					'url'   => 'game.php?page=overview'
				))
			);
			return;
		}

		$checkGhost = $db->selectSingle(
			"SELECT id FROM %%USERS%% 
			 WHERE id = :id 
			   AND email LIKE '%@noreply.local' 
			 LIMIT 1;",
			array(':id' => $PlayerID)
		);

		if (!empty($checkGhost)) {
			$this->printMessage(
				'Perfil no disponible.',
				array(array(
					'label' => 'Volver',
					'url'   => 'game.php?page=overview'
				))
			);
			return;
		}
		// ═══════════════════════════════════════════════════════════

		$sql = "SELECT 
				u.username, u.avatar, u.galaxy, u.system, u.planet, u.wons, u.loos, u.draws, u.kbmetal, u.kbcrystal, u.lostunits, u.desunits, u.ally_id,
				p.name,
				s.tech_rank, s.tech_points, s.build_rank, s.build_points, s.defs_rank, s.defs_points, s.fleet_rank, s.fleet_points, s.total_rank, s.total_points,
				a.ally_name
				FROM %%USERS%% u
				INNER JOIN %%PLANETS%% p ON p.id = u.id_planet
				LEFT JOIN %%STATPOINTS%% s ON s.id_owner = u.id AND s.stat_type = 1
				LEFT JOIN %%ALLIANCE%% a ON a.id = u.ally_id
				WHERE u.id = :playerID 
				  AND u.universe = :universe
				  AND u.email NOT LIKE '%@noreply.local';";
		$query = $db->selectSingle($sql, array(
			':universe'	=> Universe::current(),
			':playerID'	=> $PlayerID
		));

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v1.1 — Validación por si la query devuelve false
		// (jugador inexistente o cualquier caso raro)
		// ═══════════════════════════════════════════════════════════
		if (empty($query) || !is_array($query)) {
			$this->printMessage(
				'Jugador no encontrado.',
				array(array(
					'label' => 'Volver',
					'url'   => 'game.php?page=overview'
				))
			);
			return;
		}
		// ═══════════════════════════════════════════════════════════

		$totalfights = $query['wons'] + $query['loos'] + $query['draws'];
		
		if ($totalfights == 0) {
			$siegprozent                = 0;
			$loosprozent                = 0;
			$drawsprozent               = 0;
		} else {
			$siegprozent                = 100 / $totalfights * $query['wons'];
			$loosprozent                = 100 / $totalfights * $query['loos'];
			$drawsprozent               = 100 / $totalfights * $query['draws'];
		}

		$this->assign(array(
			'id'			=> $PlayerID,
			'yourid'		=> $USER['id'],
			'name'			=> $query['username'],
			// ═══ AstroIO: foto del avatar del jugador (o avatar por defecto) ═══
			'avatar'		=> self::astroio_avatarPath(isset($query['avatar']) ? $query['avatar'] : ''),
			'homeplanet'	=> $query['name'],
			'galaxy'		=> $query['galaxy'],
			'system'		=> $query['system'],
			'planet'		=> $query['planet'],
			'allyid'		=> $query['ally_id'],
			'tech_rank'     => pretty_number($query['tech_rank']),
			'tech_points'   => pretty_number($query['tech_points']),
			'build_rank'    => pretty_number($query['build_rank']),
			'build_points'  => pretty_number($query['build_points']),
			'defs_rank'     => pretty_number($query['defs_rank']),
			'defs_points'   => pretty_number($query['defs_points']),
			'fleet_rank'    => pretty_number($query['fleet_rank']),
			'fleet_points'  => pretty_number($query['fleet_points']),
			'total_rank'    => pretty_number($query['total_rank']),
			'total_points'  => pretty_number($query['total_points']),
			'allyname'		=> $query['ally_name'],
			'playerdestory' => sprintf($LNG['pl_destroy'], $query['username']),
			'wons'          => pretty_number($query['wons']),
			'loos'          => pretty_number($query['loos']),
			'draws'         => pretty_number($query['draws']),
			'kbmetal'       => pretty_number($query['kbmetal']),
			'kbcrystal'     => pretty_number($query['kbcrystal']),
			'lostunits'     => pretty_number($query['lostunits']),
			'desunits'      => pretty_number($query['desunits']),
			'totalfights'   => pretty_number($totalfights),
			'siegprozent'   => round($siegprozent, 2),
			'loosprozent'   => round($loosprozent, 2),
			'drawsprozent'  => round($drawsprozent, 2),
		));
		
		$this->display('page.playerCard.default.tpl');
	}
}