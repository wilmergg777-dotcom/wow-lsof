<?php

/**
 * AstroIO — PVEEmpireHelper
 * Lógica completa del Imperio Caído (evento PvE grupal cooperativo).
 * v3.2 — Spawn adaptativo: lee max_galaxy / max_system / max_planets de la config
 *
 * v3.3 — Fix: buildEmpireFleet() lee naves desde uni1_planets (no existe uni1_ships)
 *
 * v3.4 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Este helper NO toca NTX-20/UNTX-20 en ningún punto.
 *   · Las recompensas del Imperio Caído son RECURSOS (metal/crystal/
 *     deuterium), que son universales y NO dependen del riel del jugador.
 *   · `grantEmpireRewards()` desde v3.1 ya no da NTX — solo reparte el
 *     botín del planeta fantasma proporcional al daño.
 *   · Se añaden las constantes UNTX_MULTIPLIER y RIELS por coherencia
 *     con PVPHelper/PVEHelper/PVECrisisHelper, aunque este archivo no
 *     las use funcionalmente.
 *   · Se documenta explícitamente en `grantEmpireRewards()` por qué NO
 *     aplica dual-riel (para evitar "arreglos" futuros innecesarios).
 *
 * Ubicación: includes/classes/PVEEmpireHelper.class.php
 * @package AstroIO
 * @version 3.4
 */

// ═══════════════════════════════════════════════════════════════════
// ASTROIO — Dependencias PvE (evita "Class not found")
// ═══════════════════════════════════════════════════════════════════
if (!class_exists('PveFleetHelper')) {
	require_once ROOT_PATH.'includes/classes/PveFleetHelper.class.php';
}
if (!class_exists('PVEHelper')) {
	require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
}
if (!class_exists('PVEGhostHelper')) {
	require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';
}
if (!class_exists('PVEEmpireTemplateHelper')) {
	require_once ROOT_PATH.'includes/classes/PVEEmpireTemplateHelper.class.php';
}

class PVEEmpireHelper
{
	/* ============================================================
	 *  CONSTANTES
	 * ============================================================ */

	// Regla ×2 centralizada (por coherencia con PVPHelper/PVEHelper)
	const UNTX_MULTIPLIER = 2;

	// Rieles válidos
	const RIELS = array('CUP', 'QVAPAY');

	/** Nombres temáticos para los imperios */
	const EMPIRE_NAMES = array(
		1 => array('Fortaleza Pirata', 'Astillero Pirata', 'Base Corsaria'),
		2 => array('Nido Alienígena', 'Colmena Xeno', 'Enjambre Estelar'),
		3 => array('Factoría Máquina', 'Núcleo Sintético', 'Forja Automática'),
		4 => array('Necrópolis Espectral', 'Tumba Errante', 'Santuario Fantasmal'),
	);


	/* ============================================================
	 *  CREAR IMPERIOS (v3.0 — con fantasmas + plantillas)
	 * ============================================================ */

	/**
	 * Crea N imperios usando una plantilla.
	 *
	 * @param int|null   $count          Cantidad de imperios (default: config)
	 * @param int|null   $durationHours  Duración en horas (default: config)
	 * @param int|null   $templateId     ID de la plantilla (default: la que esté marcada)
	 * @param array      $overrides      Overrides opcionales:
	 *                                    - hp_mult
	 *                                    - res_metal, res_crystal, res_deuterium
	 *                                    - ships_mult, defenses_mult
	 * @return int  Cantidad de imperios creados
	 */
	public static function spawnEmpires($count = null, $durationHours = null, $templateId = null, $overrides = array())
	{
		$db = Database::get();

		$count         = $count ?: (int) PVEHelper::get('empire_count', 1);
		$durationHours = $durationHours ?: (int) PVEHelper::get('empire_duration_hours', 24);
		$count         = max(1, min(10, $count));
		$duration      = max(1, $durationHours) * 3600;

		// ─── Plantilla base ───
		$template = null;
		if ($templateId !== null && (int) $templateId > 0) {
			$template = PVEEmpireTemplateHelper::getTemplate((int) $templateId);
		}
		if ($template === null) {
			$template = PVEEmpireTemplateHelper::getDefaultTemplate();
		}
		if ($template === null) {
			// Fallback extremo: sin plantilla → usar valores por defecto básicos
			$template = array(
				'id'                  => 0,
				'name'                => 'Fallback',
				'hp_mult'             => 5.00,
				'res_metal'           => 10000000,
				'res_crystal'         => 5000000,
				'res_deuterium'       => 2000000,
				'ships'               => '{"202":500,"203":200}',
				'defenses'            => '{"401":1000,"402":500}',
				'buildings'           => '{}',
				'travel_mode'         => 'random',
				'travel_min'          => 30,
				'travel_max'          => 120,
				'travel_fixed'        => 60,
				'fleet_speed_pct'     => 100,
				'waves_enabled'       => 0,
				'waves_count'         => 1,
				'waves_delay_min'     => 10,
				'regen_enabled'       => 0,
				'regen_interval_min'  => 15,
				'regen_pct'           => 10.00,
			);
		}

		// ─── Overrides opcionales ───
		$hpMult      = isset($overrides['hp_mult'])      ? (float) $overrides['hp_mult']      : (float) $template['hp_mult'];
		$resMetal    = isset($overrides['res_metal'])    ? (int)   $overrides['res_metal']    : (int)   $template['res_metal'];
		$resCrystal  = isset($overrides['res_crystal'])  ? (int)   $overrides['res_crystal']  : (int)   $template['res_crystal'];
		$resDeut     = isset($overrides['res_deuterium'])? (int)   $overrides['res_deuterium']: (int)   $template['res_deuterium'];
		$shipsMult   = isset($overrides['ships_mult'])   ? (float) $overrides['ships_mult']   : 1.0;
		$defsMult    = isset($overrides['defenses_mult']) ? (float) $overrides['defenses_mult'] : 1.0;

		if ($hpMult <= 0) $hpMult = 5.0;

		// ─── Parsear naves/defensas/edificios de la plantilla ───
		$templateShips     = PVEEmpireTemplateHelper::parseShips($template);
		$templateDefenses  = PVEEmpireTemplateHelper::parseDefenses($template);
		$templateBuildings = PVEEmpireTemplateHelper::parseBuildings($template);

		// Aplicar multiplicadores a naves/defensas
		if ($shipsMult != 1.0) {
			foreach ($templateShips as $id => $cnt) {
				$templateShips[$id] = max(1, (int) round($cnt * $shipsMult));
			}
		}
		if ($defsMult != 1.0) {
			foreach ($templateDefenses as $id => $cnt) {
				$templateDefenses[$id] = max(1, (int) round($cnt * $defsMult));
			}
		}

		// ─── Facción ───
		$faction = (int) PVEHelper::get('crisis_faction_current', 1);
		if (!isset(self::EMPIRE_NAMES[$faction])) {
			$faction = 1;
		}

		$avgPoints = self::getAveragePoints();

		$created = 0;

		for ($i = 0; $i < $count; $i++) {
			$pos = self::findEmptyCoordinates();
			if ($pos === false) {
				break;
			}

			// HP total = promedio × multiplicador
			$totalHp = max(5000000, (int) ($avgPoints * $hpMult));

			$nameList = self::EMPIRE_NAMES[$faction];
			$name     = $nameList[array_rand($nameList)] . ' #' . ($i + 1);

			$totalShips = max(1000, (int) ($avgPoints / 100));

			// ─── 1) Insertar imperio ───
			$sql = "INSERT INTO %%PVE_EMPIRES%% SET
				galaxy            = :galaxy,
				system            = :system,
				planet            = :planet,
				name              = :name,
				faction           = :faction,
				total_hp          = :totalHp,
				current_hp        = :totalHp,
				total_ships       = :totalShips,
				current_ships     = :totalShips,
				status            = 'active',
				start_time        = :startTime,
				end_time          = :endTime,
				created_at        = :now;";

			$db->insert($sql, array(
				':galaxy'     => $pos['galaxy'],
				':system'     => $pos['system'],
				':planet'     => $pos['planet'],
				':name'       => $name,
				':faction'    => $faction,
				':totalHp'    => $totalHp,
				':totalShips' => $totalShips,
				':startTime'  => TIMESTAMP,
				':endTime'    => TIMESTAMP + $duration,
				':now'        => TIMESTAMP,
			));

			$empireId = (int) $db->lastInsertId();

			// ─── 2) Crear FANTASMA (usuario + planeta + naves + defensas + recursos) ───
			$ghost = null;
			try {
				$ghost = PVEGhostHelper::createGhostForEmpire($empireId, array(
					'name'      => $name,
					'galaxy'    => $pos['galaxy'],
					'system'    => $pos['system'],
					'planet'    => $pos['planet'],
					'hp'        => $totalHp,
					'metal'     => $resMetal,
					'crystal'   => $resCrystal,
					'deuterium' => $resDeut,
					'ships'     => $templateShips,
					'defenses'  => $templateDefenses,
					'buildings' => $templateBuildings,
				));
			} catch (Throwable $e) {
				PVEHelper::log('empire', $empireId, 'ghost_error', 0, 0, array(
					'error' => $e->getMessage(),
				));
				$ghost = null;
			}

			// ─── 3) Guardar template_id + ghost IDs + configs JSON ───
			if ($ghost !== null) {
				try {
					$db->update(
						"UPDATE %%PVE_EMPIRES%% SET
							template_id      = :tid,
							ghost_user_id    = :guid,
							ghost_planet_id  = :gpid,
							ships_config     = :shipsJson,
							defenses_config  = :defsJson,
							resources_config = :resJson,
							buildings_config = :buildJson,
							generated_at     = :now,
							last_regen_at    = :now
						 WHERE id = :id;",
						array(
							':tid'      => (int) $template['id'],
							':guid'     => (int) $ghost['user_id'],
							':gpid'     => (int) $ghost['planet_id'],
							':shipsJson'=> json_encode($templateShips),
							':defsJson' => json_encode($templateDefenses),
							':resJson'  => json_encode(array(
								'metal'     => $resMetal,
								'crystal'   => $resCrystal,
								'deuterium' => $resDeut,
							)),
							':buildJson'=> json_encode($templateBuildings),
							':now'      => TIMESTAMP,
							':id'       => $empireId,
						)
					);
				} catch (Throwable $e) {
					// Silencioso
				}
			}

			$created++;

			PVEHelper::log('empire', $empireId, 'spawned', 0, 0, array(
				'name'         => $name,
				'faction'      => $faction,
				'hp'           => $totalHp,
				'template_id'  => (int) $template['id'],
				'template_name'=> $template['name'],
				'ghost_user'   => $ghost ? $ghost['user_id'] : null,
			));
		}

		return $created;
	}


	/**
	 * Alias por comodidad: crear imperio desde plantilla con overrides.
	 * Igual que spawnEmpires() pero pensado para llamadas externas.
	 */
	public static function spawnEmpireFromTemplate($templateId, $overrides = array(), $count = 1, $durationHours = null)
	{
		return self::spawnEmpires($count, $durationHours, $templateId, $overrides);
	}


	/**
	 * Busca coordenadas vacías dentro del rango VÁLIDO del juego.
	 *
	 * v3.2 — Lee max_galaxy / max_system / max_planets desde Config::get()
	 *        para adaptarse automáticamente si el admin amplía el universo.
	 *
	 * @return array|false  ['galaxy','system','planet'] o false si no encuentra
	 */
	private static function findEmptyCoordinates()
	{
		$db     = Database::get();
		$config = Config::get();

		// ─── Límites REALES del juego ───
		$maxGalaxy  = max(1, (int) $config->max_galaxy);   // ej: 9
		$maxSystem  = max(1, (int) $config->max_system);   // ej: 400
		$maxPlanets = max(1, (int) $config->max_planets);  // ej: 15

		// Rango de planetas: del 4 hasta (max - 3) para dejar hueco inicial
		$minPlanet = 4;
		$maxPlanet = max($minPlanet, $maxPlanets - 3);

		// Si por alguna razón la config está mal, fallback seguro
		if ($maxGalaxy <= 0) $maxGalaxy = 5;
		if ($maxSystem <= 0) $maxSystem = 400;
		if ($maxPlanet < $minPlanet) $maxPlanet = 12;

		for ($i = 0; $i < 30; $i++) {
			$g = mt_rand(1, $maxGalaxy);
			$s = mt_rand(1, $maxSystem);
			$p = mt_rand($minPlanet, $maxPlanet);

			// ¿Planeta ocupado por un jugador real?
			$sql = "SELECT id FROM %%PLANETS%% 
			        WHERE galaxy = :g AND system = :s AND planet = :p 
			        LIMIT 1;";
			$occupied = $db->selectSingle($sql, array(':g' => $g, ':s' => $s, ':p' => $p));
			if (!empty($occupied)) continue;

			// ¿Ya hay un imperio activo en esa posición?
			$sql = "SELECT id FROM %%PVE_EMPIRES%% 
			        WHERE galaxy = :g AND system = :s AND planet = :p 
			          AND status = 'active'
			        LIMIT 1;";
			$occupiedEmpire = $db->selectSingle($sql, array(':g' => $g, ':s' => $s, ':p' => $p));
			if (!empty($occupiedEmpire)) continue;

			return array('galaxy' => $g, 'system' => $s, 'planet' => $p);
		}

		return false;
	}


	private static function getAveragePoints()
	{
		$db = Database::get();

		$sql = "SELECT AVG(total_points) AS avg_points 
		        FROM %%STATPOINTS%% 
		        WHERE stat_type = 1 AND universe = :uni;";
		$row = $db->selectSingle($sql, array(':uni' => Universe::current()));

		$avg = !empty($row['avg_points']) ? (int) $row['avg_points'] : 10000;
		return max(10000, $avg);
	}


	/* ============================================================
	 *  ESTADO / CONSULTAS
	 * ============================================================ */

	public static function getActiveEmpires()
	{
		$db = Database::get();

		$sql = "SELECT * FROM %%PVE_EMPIRES%% 
		        WHERE status = 'active' 
		          AND end_time > :now
		        ORDER BY current_hp DESC;";

		return $db->select($sql, array(':now' => TIMESTAMP));
	}


	public static function getEmpire($empireId)
	{
		$db = Database::get();
		$empireId = (int) $empireId;

		$sql = "SELECT * FROM %%PVE_EMPIRES%% WHERE id = :id LIMIT 1;";
		return $db->selectSingle($sql, array(':id' => $empireId));
	}


	public static function getAttacksByUser($userId, $empireId)
	{
		$db = Database::get();

		$sql = "SELECT COUNT(*) AS total 
		        FROM %%PVE_EMPIRE_ATTACKS%% 
		        WHERE user_id = :uid AND empire_id = :eid;";
		$row = $db->selectSingle($sql, array(':uid' => (int) $userId, ':eid' => (int) $empireId));

		return !empty($row) ? (int) $row['total'] : 0;
	}


	public static function canAttack($userId, $empireId)
	{
		$max = (int) PVEHelper::get('empire_attacks_per_user', 5);
		$current = self::getAttacksByUser($userId, $empireId);

		return $current < $max;
	}


	/**
	 * Comprueba si un usuario ya tiene una flota en vuelo hacia este imperio.
	 */
	public static function hasFleetInFlight($userId, $empireId)
	{
		$db = Database::get();

		$endId = PveFleetHelper::EMPIRE_ID_OFFSET + (int) $empireId;

		$sql = "SELECT COUNT(*) AS total 
		        FROM %%FLEETS%% 
		        WHERE fleet_owner = :uid 
		          AND fleet_mission = :mission 
		          AND fleet_end_id = :eid 
		          AND fleet_mess = 0;";
		$row = $db->selectSingle($sql, array(
			':uid'     => (int) $userId,
			':mission' => MISSION_PVE_EMPIRE,
			':eid'     => $endId,
		));

		return !empty($row) && (int) $row['total'] > 0;
	}


	/* ============================================================
	 *  ACS — CONSULTAS
	 * ============================================================ */

	public static function getOpenAcsForEmpire($empireId)
	{
		return PveFleetHelper::getOpenAcsForEmpire($empireId);
	}


	public static function getAcsParticipants($acsId)
	{
		return PveFleetHelper::getAcsParticipants($acsId);
	}


	/* ============================================================
	 *  ATAQUE DEL JUGADOR (FLOTA REAL)
	 * ============================================================ */

	public static function sendAttackFleet($userId, $empireId, $planetId, $fleetArray, $acsId = 0, $flightSpeed = 10)
	{
		$db = Database::get();

		$userId   = (int) $userId;
		$empireId = (int) $empireId;
		$planetId = (int) $planetId;

		// 1) Validaciones
		$empire = self::getEmpire($empireId);
		if (empty($empire)) {
			return array('success' => false, 'message' => 'Imperio no encontrado.');
		}
		if ($empire['status'] !== 'active') {
			return array('success' => false, 'message' => 'El imperio ya no está activo.');
		}
		if ((int) $empire['end_time'] <= TIMESTAMP) {
			return array('success' => false, 'message' => 'El imperio ya expiró.');
		}
		if (!self::canAttack($userId, $empireId)) {
			$max = (int) PVEHelper::get('empire_attacks_per_user', 5);
			return array('success' => false, 'message' => 'Ya alcanzaste el máximo de ' . $max . ' ataques a este imperio.');
		}

		if (empty($fleetArray)) {
			return array('success' => false, 'message' => 'No has seleccionado naves.');
		}

		// 2) Verificar planeta
		$sql = "SELECT * FROM %%PLANETS%% WHERE id = :id AND id_owner = :uid LIMIT 1;";
		$planet = $db->selectSingle($sql, array(':id' => $planetId, ':uid' => $userId));

		if (empty($planet)) {
			return array('success' => false, 'message' => 'Planeta no válido.');
		}

		// 3) Enviar flota real vía PveFleetHelper
		$result = PveFleetHelper::sendEmpireAttackFleet(
			$userId,
			$empireId,
			$planetId,
			$fleetArray,
			$acsId,
			$flightSpeed
		);

		if (!$result['success']) {
			return array('success' => false, 'message' => $result['error']);
		}

		return array(
			'success'      => true,
			'message'      => 'Flota enviada. Llegará en ' . pretty_time($result['duration']) . '.',
			'fleet_id'     => $result['fleet_id'],
			'acs_id'       => $result['acs_id'],
			'is_new_acs'   => !empty($result['is_new_acs']),
			'duration'     => $result['duration'],
			'consumption'  => $result['consumption'],
			'start_time'   => $result['start_time'],
			'end_time'     => $result['end_time'],
		);
	}


	/* ============================================================
	 *  CONSTRUIR FLOTA DEL IMPERIO (usado por MissionCasePveEmpire)
	 * ============================================================ */

	/**
	 * Genera la flota defensora del imperio basada en su HP actual.
	 * Si el imperio tiene un fantasma con naves reales, esas mandan.
	 * Si no, se usa el método legacy (basado en HP).
	 *
	 * ✅ FIX v3.3: Las naves se leen desde %%PLANETS%% (columnas directas)
	 *              ya que NO existe una tabla uni1_ships en este fork.
	 */
	public static function buildEmpireFleet($empire)
	{
		global $pricelist;

		// ─── Si hay fantasma, leer naves reales desde uni1_planets ───
		if (!empty($empire['ghost_user_id'])) {
			$db = Database::get();
			
			// ✅ Las naves están como COLUMNAS en la tabla %%PLANETS%%
			$row = $db->selectSingle(
				"SELECT * FROM %%PLANETS%% 
				 WHERE id_owner = :uid AND planet_type = 1 
				 LIMIT 1;",
				array(':uid' => (int) $empire['ghost_user_id'])
			);

			if (!empty($row)) {
				// ✅ Mapeo de columna → ID de nave (2Moons estándar)
				$shipColumns = array(
					202 => 'small_ship_cargo',
					203 => 'big_ship_cargo',
					204 => 'light_hunter',
					205 => 'heavy_hunter',
					206 => 'crusher',
					207 => 'battle_ship',
					208 => 'colonizer',
					209 => 'recycler',
					210 => 'spy_sonde',
					211 => 'bomber_ship',
					// 212 = solar_satelit (no vuela, excluido)
					213 => 'destructor',
					214 => 'dearth_star',
					215 => 'battleship',
					217 => 'ev_transporter',
					219 => 'giga_recykler',
					220 => 'dm_ship',
				);

				$fleet = array();
				foreach ($shipColumns as $shipId => $colName) {
					if (isset($row[$colName]) && (int) $row[$colName] > 0) {
						$fleet[$shipId] = (int) $row[$colName];
					}
				}
				
				if (!empty($fleet)) {
					return $fleet;
				}
			}
		}

		// ─── Fallback legacy: generar por HP ───
		$currentHp = max(0, (int) $empire['current_hp']);
		$totalHp   = max(1, (int) $empire['total_hp']);
		$ratio     = $currentHp / $totalHp;

		$budget = (int) ($totalHp * $ratio * 0.5);

		if ($budget <= 0) {
			return array();
		}

		$fleet = array();
		$remaining = $budget;

		$shipPool = array(204, 205, 206, 207, 211, 213, 215);

		foreach ($shipPool as $shipId) {
			if (!isset($pricelist[$shipId])) continue;

			$cost = (isset($pricelist[$shipId]['cost'][901]) ? $pricelist[$shipId]['cost'][901] : 0)
			      + (isset($pricelist[$shipId]['cost'][902]) ? $pricelist[$shipId]['cost'][902] : 0);
			if ($cost <= 0) continue;

			$maxCount = (int) floor($remaining * 0.5 / $cost);
			if ($maxCount <= 0) continue;

			$fleet[$shipId] = $maxCount;
			$remaining -= $maxCount * $cost;
		}

		return array_filter($fleet);
	}


	/**
	 * Aplica daño al imperio y devuelve si fue destruido.
	 * v3.0 → si destruido, elimina el fantasma.
	 *
	 * @return array ['new_hp' => int, 'destroyed' => bool]
	 */
	public static function applyDamage($empireId, $damage)
	{
		$db = Database::get();

		$empire = self::getEmpire($empireId);
		if (empty($empire)) {
			return array('new_hp' => 0, 'destroyed' => false);
		}

		// ✅ v3.8 — UPDATE atómico:
		//  - GREATEST(0, current_hp - :dmg) hace el decremento en SQL: antes
		//    el HP se leía en PHP y se escribía el resultado (read-modify-
		//    write), así que dos ataques concurrentes perdían uno de los dos
		//    daños (lost update).
		//  - AND status = 'active' impide "dañar" un imperio ya
		//    destruido/expirado y re-activar la destrucción.
		$sql = "UPDATE %%PVE_EMPIRES%% SET
			current_hp             = GREATEST(0, current_hp - :dmg),
			total_damage_received  = total_damage_received + :dmg,
			total_attacks          = total_attacks + 1
			WHERE id = :id AND status = 'active';";
		$db->update($sql, array(
			':dmg'   => (int) $damage,
			':id'    => $empireId,
		));

		if ($db->rowCount() !== 1) {
			// No estaba activo (ya destruido/expirado) o no existe
			$row = $db->selectSingle(
				"SELECT current_hp FROM %%PVE_EMPIRES%% WHERE id = :id;",
				array(':id' => $empireId)
			);
			return array(
				'new_hp'    => !empty($row) ? (int) $row['current_hp'] : 0,
				'destroyed' => false,
			);
		}

		// Releer el HP real tras el decremento atómico
		$row = $db->selectSingle(
			"SELECT current_hp FROM %%PVE_EMPIRES%% WHERE id = :id;",
			array(':id' => $empireId)
		);
		$newHp = !empty($row) ? (int) $row['current_hp'] : 0;

		$destroyed = ($newHp <= 0);

		if ($destroyed) {
			// ✅ v3.8 — Destrucción condicional: solo el primer proceso la
			// aplica (rowCount=1); el segundo ya no vuelve a llamar
			// destroyGhost() (antes un imperio podía "destruirse" dos veces).
			$sql = "UPDATE %%PVE_EMPIRES%% SET
				status         = 'destroyed',
				destroyed_at   = :now,
				current_hp     = 0
				WHERE id = :id AND status = 'active';";
			$db->update($sql, array(
				':now' => TIMESTAMP,
				':id'  => $empireId,
			));

			if ($db->rowCount() === 1) {
				// 🔥 Eliminar el fantasma (borrado limpio en cascada)
				try {
					if (class_exists('PVEGhostHelper')) {
						PVEGhostHelper::destroyGhost((int) $empireId, 'empire');
					}
				} catch (Throwable $e) {
					PVEHelper::log('empire', $empireId, 'ghost_destroy_error', 0, 0, array(
						'error' => $e->getMessage(),
					));
				}

				PVEHelper::log('empire', $empireId, 'destroyed', 0, 0, array(
					'final_hp' => $newHp,
				));
			}
		}

		return array('new_hp' => $newHp, 'destroyed' => $destroyed);
	}


	/**
	 * Registra un ataque al imperio en la tabla PVE.
	 */
	public static function registerAttack($empireId, $userId, $planetId, $fleetId, $shipsSent, $shipsLost, $damage)
	{
		$db = Database::get();

		$shipsSentJson = is_array($shipsSent) ? json_encode($shipsSent) : $shipsSent;

		$sql = "INSERT INTO %%PVE_EMPIRE_ATTACKS%% SET
			empire_id      = :empireId,
			user_id        = :userId,
			planet_id      = :planetId,
			fleet_id       = :fleetId,
			ships_sent     = :shipsSent,
			ships_lost     = :shipsLost,
			damage_done    = :damage,
			resources_looted = 0,
			counterattacked = 0,
			attack_time    = :now;";

		$db->insert($sql, array(
			':empireId' => (int) $empireId,
			':userId'   => (int) $userId,
			':planetId' => (int) $planetId,
			':fleetId'  => (int) $fleetId,
			':shipsSent' => $shipsSentJson,
			':shipsLost' => (int) $shipsLost,
			':damage'    => (int) $damage,
			':now'       => TIMESTAMP,
		));

		return $db->lastInsertId();
	}


	/**
	 * Marca un ataque como contraatacado.
	 */
	public static function markCounterattacked($attackId, $shipsLost, $resLost)
	{
		$db = Database::get();

		$sql = "UPDATE %%PVE_EMPIRE_ATTACKS%% SET
			counterattacked = 1,
			counterattack_ships_lost = :sl,
			counterattack_resources_lost = :rl
			WHERE id = :id;";
		$db->update($sql, array(
			':sl' => (int) $shipsLost,
			':rl' => (int) $resLost,
			':id' => (int) $attackId,
		));
	}


	/* ============================================================
	 *  RECOMPENSAS
	 * ============================================================ */

	/**
	 * Reparte recompensas tras destruir el imperio.
	 *
	 * v3.1 — YA NO DA NTX. Reparte los RECURSOS del fantasma:
	 *   - Lee el % configurado en `empire_loot_pct` (0-100, default 100)
	 *   - Aplica ese % sobre los recursos del planeta fantasma
	 *   - Reparte proporcionalmente al daño hecho por cada contribuyente
	 *   - Inserta UN reward `resources` por jugador
	 *   - Vacía el planeta fantasma al terminar
	 *
	 * v3.4 — DOBLE RIEL: NO APLICA.
	 *
	 *   Este método NO acredita NTX-20 ni UNTX-20 al jugador. Solo
	 *   inserta registros con `reward_type = 'resources'` en
	 *   `uni1_pve_rewards`. Los recursos (metal / crystal / deuterium)
	 *   son universales y NO dependen del riel del jugador.
	 *
	 *   Cuando el jugador reclama en `PVEHelper::claimAllRewards()`,
	 *   esos recursos se añaden a su planeta principal sin ninguna
	 *   conversión (sin ×2, sin detección de riel).
	 *
	 *   Por eso este método se queda SIN cambios funcionales respecto
	 *   a v3.1. Solo se documenta para evitar "arreglos" futuros
	 *   innecesarios (aplicar ×2 aquí sería un bug).
	 *
	 * @param int $empireId
	 * @return void
	 */
	public static function grantEmpireRewards($empireId)
	{
		$db = Database::get();
		$empireId = (int) $empireId;

		// ─── 1) Cargar imperio ────────────────────────────────────
		$empire = self::getEmpire($empireId);
		if (empty($empire)) {
			return;
		}

		// ✅ v3.8 — GUARD anti-duplicado: dos ataques concurrentes que
		// derrumban el HP a cero a la vez ejecutan grantEmpireRewards()
		// dos veces (MissionCasePveEmpire lo llama ANTES de applyDamage
		// para repartir con el fantasma vivo). Sin este guard, cada
		// contribuyente cobraría el botín por duplicado.
		$existing = $db->selectSingle(
			"SELECT COUNT(*) AS total FROM %%PVE_REWARDS%%
			 WHERE event_type = 'empire' AND event_id = :eid;",
			array(':eid' => $empireId)
		);
		if (!empty($existing) && (int) $existing['total'] > 0) {
			PVEHelper::log('empire', $empireId, 'rewards_skip_already_granted', 0, 0, array(
				'rewards_existing' => (int) $existing['total'],
			));
			return;
		}

		// ─── 2) Cargar recursos del planeta fantasma ──────────────
		$ghostPlanetId = (int) $empire['ghost_planet_id'];
		if ($ghostPlanetId <= 0) {
			PVEHelper::log('empire', $empireId, 'rewards_no_ghost', 0, 0, null);
			return;
		}

		$planet = $db->selectSingle(
			"SELECT metal, crystal, deuterium FROM %%PLANETS%% WHERE id = :id LIMIT 1;",
			array(':id' => $ghostPlanetId)
		);
		if (empty($planet)) {
			PVEHelper::log('empire', $empireId, 'rewards_no_planet', 0, 0, array(
				'ghost_planet_id' => $ghostPlanetId,
			));
			return;
		}

		// ─── 3) Aplicar % de botín configurable ───────────────────
		$lootPct = (int) PVEHelper::get('empire_loot_pct', 100);
		if ($lootPct < 0)   $lootPct = 0;
		if ($lootPct > 100) $lootPct = 100;
		$factor = $lootPct / 100;

		$baseMetal     = max(0, (int) $planet['metal']);
		$baseCrystal   = max(0, (int) $planet['crystal']);
		$baseDeuterium = max(0, (int) $planet['deuterium']);

		$lootMetal     = (int) floor($baseMetal     * $factor);
		$lootCrystal   = (int) floor($baseCrystal   * $factor);
		$lootDeuterium = (int) floor($baseDeuterium * $factor);

		if (($lootMetal + $lootCrystal + $lootDeuterium) <= 0) {
			PVEHelper::log('empire', $empireId, 'rewards_empty_loot', 0, 0, array(
				'loot_pct' => $lootPct,
				'metal'    => $baseMetal,
				'crystal'  => $baseCrystal,
				'deut'     => $baseDeuterium,
			));
			return;
		}

		// ─── 4) Cargar contribuyentes (daño agregado por usuario) ─
		$contributors = $db->select(
			"SELECT user_id, SUM(damage_done) AS total_damage
			 FROM %%PVE_EMPIRE_ATTACKS%%
			 WHERE empire_id = :eid
			 GROUP BY user_id
			 HAVING total_damage > 0;",
			array(':eid' => $empireId)
		);

		if (empty($contributors)) {
			PVEHelper::log('empire', $empireId, 'rewards_no_contributors', 0, 0, null);
			return;
		}

		$totalDamage = 0;
		foreach ($contributors as $c) {
			$totalDamage += (int) $c['total_damage'];
		}
		if ($totalDamage <= 0) {
			return;
		}

		// ─── 5) Repartir proporcionalmente al daño ────────────────
		$totalRewarded = array(
			'metal'     => 0,
			'crystal'   => 0,
			'deuterium' => 0,
		);
		$playersRewarded = 0;

		foreach ($contributors as $c) {
			$userId     = (int) $c['user_id'];
			$userDamage = (int) $c['total_damage'];
			$pct        = $userDamage / $totalDamage;

			$userMetal     = (int) floor($lootMetal     * $pct);
			$userCrystal   = (int) floor($lootCrystal   * $pct);
			$userDeuterium = (int) floor($lootDeuterium * $pct);

			if (($userMetal + $userCrystal + $userDeuterium) <= 0) {
				continue;
			}

			$sql = "INSERT INTO %%PVE_REWARDS%% SET
				user_id     = :userId,
				event_type  = 'empire',
				event_id    = :eventId,
				reward_type = 'resources',
				reward_data = :data,
				claimed     = 0,
				created_at  = :now;";

			$db->insert($sql, array(
				':userId'  => $userId,
				':eventId' => $empireId,
				':data'    => json_encode(array(
					'metal'     => $userMetal,
					'crystal'   => $userCrystal,
					'deuterium' => $userDeuterium,
					'damage'    => $userDamage,
					'total_dmg' => $totalDamage,
					'percent'   => round($pct * 100, 2),
					'loot_pct'  => $lootPct,
				)),
				':now'     => TIMESTAMP,
			));

			$totalRewarded['metal']     += $userMetal;
			$totalRewarded['crystal']   += $userCrystal;
			$totalRewarded['deuterium'] += $userDeuterium;
			$playersRewarded++;
		}

		// ─── 6) Vaciar el planeta fantasma (los recursos ya se repartieron) ───
		try {
			$db->update(
				"UPDATE %%PLANETS%% SET
					metal     = 0,
					crystal   = 0,
					deuterium = 0
				 WHERE id = :id;",
				array(':id' => $ghostPlanetId)
			);
		} catch (Throwable $e) {
			PVEHelper::log('empire', $empireId, 'ghost_planet_clear_error', 0, 0, array(
				'error' => $e->getMessage(),
			));
		}

		// ─── 7) Log final ────────────────────────────────────────
		PVEHelper::log('empire', $empireId, 'rewards_granted', 0, 0, array(
			'loot_pct'      => $lootPct,
			'distributed'   => $totalRewarded,
			'contributors'  => $playersRewarded,
			'total_damage'  => $totalDamage,
			'riel_note'     => 'resources_son_universales_no_aplica_dual_riel',
		));
	}


	/* ============================================================
	 *  CRON — EXPIRAR IMPERIOS SIN DESTRUIR
	 * ============================================================ */

	/**
	 * Marca como 'expired' los imperios que han pasado su end_time
	 * y ELIMINA sus fantasmas asociados.
	 */
	public static function processExpiredEmpires()
	{
		$db = Database::get();

		// ─── 1) Buscar los que van a expirar ───
		$expired = $db->select(
			"SELECT id FROM %%PVE_EMPIRES%%
			 WHERE status = 'active' AND end_time <= :now;",
			array(':now' => TIMESTAMP)
		);

		if (!is_array($expired) || count($expired) === 0) {
			return 0;
		}

		// ─── 2) Marcar como expirados ───
		$db->update(
			"UPDATE %%PVE_EMPIRES%% 
			 SET status = 'expired' 
			 WHERE status = 'active' AND end_time <= :now;",
			array(':now' => TIMESTAMP)
		);

		// ─── 3) Eliminar fantasmas de cada imperio expirado ───
		foreach ($expired as $row) {
			$eid = (int) $row['id'];
			try {
				if (class_exists('PVEGhostHelper')) {
					PVEGhostHelper::destroyGhost($eid, 'empire');
				}
			} catch (Throwable $e) {
				PVEHelper::log('empire', $eid, 'ghost_expire_error', 0, 0, array(
					'error' => $e->getMessage(),
				));
			}
		}

		return count($expired);
	}


	/* ============================================================
	 *  UTILIDADES PARA VISTA
	 * ============================================================ */

	/**
	 * Datos enriquecidos para la vista del jugador.
	 */
	public static function getEmpireForView($empire, $userId)
	{
		$empire['my_attacks']  = self::getAttacksByUser($userId, (int) $empire['id']);
		$maxAttacks            = (int) PVEHelper::get('empire_attacks_per_user', 5);
		$empire['max_attacks'] = $maxAttacks;
		$empire['can_attack']  = ($empire['my_attacks'] < $maxAttacks);
		$empire['hp_percent']  = ($empire['total_hp'] > 0)
			? round(($empire['current_hp'] / $empire['total_hp']) * 100, 1)
			: 0;
		$empire['hp_fmt']      = number_format((int) $empire['current_hp']);
		$empire['hp_max_fmt']  = number_format((int) $empire['total_hp']);
		$empire['dmg_fmt']     = number_format((int) $empire['total_damage_received']);
		$empire['time_left']   = max(0, (int) $empire['end_time'] - TIMESTAMP);

		// ACS abiertos
		$empire['open_acs']    = self::getOpenAcsForEmpire((int) $empire['id']);

		// Datos de la plantilla si existe
		$empire['template']    = null;
		if (!empty($empire['template_id'])) {
			try {
				$empire['template'] = PVEEmpireTemplateHelper::getTemplate((int) $empire['template_id']);
			} catch (Throwable $e) {
				// Silencioso
			}
		}

		return $empire;
	}
}