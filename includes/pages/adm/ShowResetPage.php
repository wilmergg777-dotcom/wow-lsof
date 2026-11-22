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
 * AstroIO v3.1 — Reset con Boss + Bastión + AdminBank + PvP + Asteroids + Planetario + Talent
 *
 * ✅ AstroIO v5.5 (REFERIDOS UNIFICADOS — SOLO CÓDIGO):
 *   - Reset de referidos: se elimina `ref_bonus = 0` (bandera del sistema viejo).
 *   - Se mantiene `ref_id = 0` (borra vinculaciones al resetear).
 *   - El sistema nuevo solo usa `ref_id` y `wallet_referral_fund`.
 *
 * ✅ AstroIO v5.6 (POTENCIADORES — RESET UNIVERSAL):
 *   - Mejorado `astroio_boosters`:
 *       * TRUNCATE users_boosters (borra potenciadores activos de TODOS)
 *       * Mensaje de log con contador
 *   - NUEVO `astroio_boosters_catalog`:
 *       * TRUNCATE uni1_boosters
 *       * Re-inserta los 7 POTENCIADORES BASE (IDs 6-12)
 *       * Útil cuando alguien modifica valores por error
 *
 * ✅ AstroIO v3.3 (BOOST FIN DE SEMANA):
 *   - NUEVO `astroio_weekend_boost`:
 *       * TRUNCATE uni1_weekend_boost
 *       * Re-inserta la fila id=1 con los valores por defecto
 *       * Deja enabled = 0 (el admin debe reactivarlo tras el reset)
 *
 * ✅ AstroIO v3.4 (MINI TORNEOS):
 *   - NUEVO `astroio_tourney`:
 *       * TRUNCATE uni1_tourney
 *       * TRUNCATE uni1_tourney_participante
 *       * TRUNCATE uni1_tourney_logs
 *       * UPDATE uni1_config SET tourneyEnd = 0
 *   - El cronjob 28 (Tournaments) se mantiene activo.
 */

if ($USER['id'] != ROOT_USER || $_GET['sid'] != session_id()) exit;

function ShowResetPage()
{
	global $LNG, $reslist, $resource;
	$template	= new template();
	$config	= Config::get(ROOT_UNI);
	
	if ($_POST)
	{		
		foreach($reslist['build'] as $ID)
		{
			$dbcol['build'][$ID]	= "`".$resource[$ID]."` = '0'";
		}
		
		foreach($reslist['tech'] as $ID)
		{
			$dbcol['tech'][$ID]		= "`".$resource[$ID]."` = '0'";
		}
		
		foreach($reslist['fleet'] as $ID)
		{
			$dbcol['fleet'][$ID]	= "`".$resource[$ID]."` = '0'";
		}
		
		foreach($reslist['defense'] as $ID)
		{
			$dbcol['defense'][$ID]	= "`".$resource[$ID]."` = '0'";
		}
		
		foreach($reslist['officier'] as $ID)
		{
			$dbcol['officier'][$ID]	= "`".$resource[$ID]."` = '0'";
		}
		
		foreach($reslist['resstype'][1] as $ID)
		{
			if(isset($config->{$resource[$ID].'_start'}))
			{
				$dbcol['resource_planet_start'][$ID]	= "`".$resource[$ID]."` = ".$config->{$resource[$ID].'_start'};
			}
		}
		
		foreach($reslist['resstype'][3] as $ID)
		{
			if(isset($config->{$resource[$ID].'_start'}))
			{
				$dbcol['resource_user_start'][$ID]	= "`".$resource[$ID]."` = ".$config->{$resource[$ID].'_start'};
			}
		}
		
		// Players and Planets
		
		if (isset($_POST['players']) && $_POST['players'] == 'on'){
			// Preservar SIEMPRE al admin (ROOT_USER)
			$GLOBALS['DATABASE']->multi_query("DELETE FROM ".USERS." WHERE `universe` = ".Universe::getEmulated()." AND `id` != '".ROOT_USER."';DELETE FROM ".PLANETS." WHERE `universe` = ".Universe::getEmulated()." AND `id_owner` != '".ROOT_USER."';");
		}
		
		if (isset($_POST['planets']) && $_POST['planets'] == 'on')
			$GLOBALS['DATABASE']->multi_query("DELETE FROM ".PLANETS." WHERE `universe` = ".Universe::getEmulated()." AND `id_owner` != '".ROOT_USER."' AND `id` NOT IN (SELECT id_planet FROM ".USERS." WHERE `universe` = ".Universe::getEmulated().");UPDATE ".PLANETS." SET `id_luna` = '0' WHERE `universe` = ".Universe::getEmulated()." AND `id_owner` != '".ROOT_USER."';");
			
		if (isset($_POST['moons']) && $_POST['moons'] == 'on'){
			$GLOBALS['DATABASE']->multi_query("DELETE FROM ".PLANETS." WHERE `planet_type` = '3' AND `universe` = ".Universe::getEmulated()." AND `id_owner` != '".ROOT_USER."';UPDATE ".PLANETS." SET `id_luna` = '0' WHERE `universe` = ".Universe::getEmulated()." AND `id_owner` != '".ROOT_USER."';");}

		// HANGARES Y DEFENSAS
		if (isset($_POST['defenses']) && $_POST['defenses'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".PLANETS." SET ".implode(", ",$dbcol['defense'])." WHERE `universe` = ".Universe::getEmulated().";");
	
		if (isset($_POST['ships']) && $_POST['ships'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".PLANETS." SET ".implode(", ",$dbcol['fleet'])." WHERE `universe` = ".Universe::getEmulated().";");
	
		if (isset($_POST['h_d']) && $_POST['h_d'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".PLANETS." SET `b_hangar` = '0', `b_hangar_id` = '' WHERE `universe` = ".Universe::getEmulated().";");
	

		// EDIFICIOS
		if (isset($_POST['edif_p']) && $_POST['edif_p'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".PLANETS." SET ".implode(", ",$dbcol['build']).", `field_current` = '0' WHERE `planet_type` = '1' AND `universe` = ".Universe::getEmulated().";");
	
		if (isset($_POST['edif_l']) && $_POST['edif_l'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".PLANETS." SET ".implode(", ",$dbcol['build']).", `field_current` = '0' WHERE `planet_type` = '3' AND `universe` = ".Universe::getEmulated().";");
	
		if (isset($_POST['edif']) && $_POST['edif'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".PLANETS." SET `b_building` = '0', `b_building_id` = '' WHERE `universe` = ".Universe::getEmulated().";");
	

		// INVESTIGACIONES Y OFICIALES
		if (isset($_POST['inves']) && $_POST['inves'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".USERS." SET ".implode(", ",$dbcol['tech'])." WHERE `universe` = ".Universe::getEmulated().";");
	
		if (isset($_POST['ofis']) && $_POST['ofis'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".USERS." SET ".implode(", ",$dbcol['officier'])." WHERE `universe` = ".Universe::getEmulated().";");
	
		if (isset($_POST['inves_c']) && $_POST['inves_c'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".USERS." SET `b_tech_planet` = '0', `b_tech` = '0', `b_tech_id` = '0', `b_tech_queue` = '' WHERE `universe` = ".Universe::getEmulated().";");
	
	
		// RECURSOS
		if (isset($_POST['dark']) && $_POST['dark'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".USERS." SET ".implode(", ",$dbcol['resource_user_start'])." WHERE `universe` = ".Universe::getEmulated().";");
	
		if (isset($_POST['resources']) && $_POST['resources'] == 'on')
			$GLOBALS['DATABASE']->query("UPDATE ".PLANETS." SET ".implode(", ",$dbcol['resource_planet_start'])." WHERE `universe` = ".Universe::getEmulated().";");
	
		// GENERAL
		if (isset($_POST['notes']) && $_POST['notes'] == 'on')
			$GLOBALS['DATABASE']->query("DELETE FROM ".NOTES." WHERE `universe` = ".Universe::getEmulated().";");

		if (isset($_POST['rw']) && $_POST['rw'] == 'on')
			$GLOBALS['DATABASE']->query("DELETE FROM ".TOPKB." WHERE `universe` = ".Universe::getEmulated().";");

		if (isset($_POST['friends']) && $_POST['friends'] == 'on')
			$GLOBALS['DATABASE']->query("DELETE FROM ".BUDDY." WHERE `universe` = ".Universe::getEmulated().";");

		if (isset($_POST['alliances']) && $_POST['alliances'] == 'on')
			$GLOBALS['DATABASE']->multi_query("DELETE FROM ".ALLIANCE." WHERE `ally_universe` = '".Universe::getEmulated()."';UPDATE ".USERS." SET `ally_id` = '0', `ally_register_time` = '0', `ally_rank_id` = '0' WHERE `universe` = ".Universe::getEmulated().";");

		if (isset($_POST['fleets']) && $_POST['fleets'] == 'on')
			$GLOBALS['DATABASE']->query("DELETE FROM ".FLEETS." WHERE `fleet_universe` = '".Universe::getEmulated()."';");

		if (isset($_POST['banneds']) && $_POST['banneds'] == 'on')
			$GLOBALS['DATABASE']->multi_query("DELETE FROM ".BANNED." WHERE `universe` = ".Universe::getEmulated().";UPDATE ".USERS." SET `bana` = '0', `banaday` = '0' WHERE `universe` = ".Universe::getEmulated().";");

		if (isset($_POST['messages']) && $_POST['messages'] == 'on')
			$GLOBALS['DATABASE']->multi_query("DELETE FROM ".MESSAGES." WHERE `message_universe` = '".Universe::getEmulated()."';");

		if (isset($_POST['statpoints']) && $_POST['statpoints'] == 'on')
			$GLOBALS['DATABASE']->query("DELETE FROM ".STATPOINTS." WHERE `universe` = ".Universe::getEmulated().";");

		// ASTROIO - Reset de modulos nuevos
		// La funcion internamente revisa cada checkbox (astroio_vip, astroio_wallet, etc.)
		ResetAstroIOModules();

		$template->message($LNG['re_reset_excess'], '?page=reset&sid='.session_id(), 3);
		exit;
	}

	$template->assign_vars(array(	
		'button_submit'						=> $LNG['button_submit'],
		're_reset_universe_confirmation'	=> $LNG['re_reset_universe_confirmation'],
		're_reset_all'						=> $LNG['re_reset_all'],
		're_defenses_and_ships'				=> $LNG['re_defenses_and_ships'],
		're_reset_buldings'					=> $LNG['re_reset_buldings'],
		're_buildings_lu'					=> $LNG['re_buildings_lu'],
		're_buildings_pl'					=> $LNG['re_buildings_pl'],
		're_buldings'						=> $LNG['re_buldings'],
		're_reset_hangar'					=> $LNG['re_reset_hangar'],
		're_ships'							=> $LNG['re_ships'],
		're_defenses'						=> $LNG['re_defenses'],
		're_resources_met_cry'				=> $LNG['re_resources_met_cry'],
		're_resources_dark'					=> $LNG['re_resources_dark'],
		're_resources'						=> $LNG['re_resources'],
		're_reset_invest'					=> $LNG['re_reset_invest'],
		're_investigations'					=> $LNG['re_investigations'],
		're_ofici'							=> $LNG['re_ofici'],
		're_inve_ofis'						=> $LNG['re_inve_ofis'],
		're_reset_statpoints'				=> $LNG['re_reset_statpoints'],
		're_reset_messages'					=> $LNG['re_reset_messages'],
		're_reset_banned'					=> $LNG['re_reset_banned'],
		're_reset_errors'					=> $LNG['re_reset_errors'],
		're_reset_fleets'					=> $LNG['re_reset_fleets'],
		're_reset_allys'					=> $LNG['re_reset_allys'],
		're_reset_buddies'					=> $LNG['re_reset_buddies'],
		're_reset_rw'						=> $LNG['re_reset_rw'],
		're_reset_notes'					=> $LNG['re_reset_notes'],
		're_reset_moons'					=> $LNG['re_reset_moons'],
		're_reset_planets'					=> $LNG['re_reset_planets'],
		're_reset_player'					=> $LNG['re_reset_player'],
		're_player_and_planets'				=> $LNG['re_player_and_planets'],
		're_general'						=> $LNG['re_general'],
	));
	
	$template->show('ResetPage.tpl');
}

/**
 * ASTROIO - Reset de los modulos nuevos.
 * Se llama siempre al ejecutar el reset. Internamente revisa
 * cada checkbox (astroio_vip, astroio_events, etc.) y solo
 * ejecuta el bloque correspondiente si esta marcada.
 */
function ResetAstroIOModules()
{
	$prefix = 'uni1_';

	// ─────────────────────────────────────────────────────────
	// VIP
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_vip']) && $_POST['astroio_vip'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_vip`");
	}

	// ─────────────────────────────────────────────────────────
	// EVENTOS (datos + reinstalar los 14 auto)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_events']) && $_POST['astroio_events'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_events`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."events_history`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."events`");

		if (class_exists('EventHelper'))
		{
			if (method_exists('EventHelper', 'initEvents'))
				EventHelper::initEvents();
			elseif (method_exists('EventHelper', 'installDefaultEvents'))
				EventHelper::installDefaultEvents();
			elseif (method_exists('EventHelper', 'createDefaultEvents'))
				EventHelper::createDefaultEvents();
			elseif (method_exists('EventHelper', 'seedEvents'))
				EventHelper::seedEvents();
		}
	}

	// ─────────────────────────────────────────────────────────
	// WALLET (usuarios + inversiones + log + historial de tasa)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_wallet']) && $_POST['astroio_wallet'] == 'on')
	{
		$tablas = array(
			'users_wallet',
			'wallet_investments',
			'wallet_withdrawals',
			'wallet_transactions',
			'wallet_referral_fund',
			'wallet_stats_daily',
			'wallet_investment_log',
			'wallet_transfers_log',
			'wallet_tasa_historial',   // ← v3.0: historial de tasa AMM
		);
		foreach ($tablas as $t)
		{
			$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix.$t."`");
		}
		// Resetear ntx20_inversion en users
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."users` SET `ntx20_inversion` = 0");
	}

	// ─────────────────────────────────────────────────────────
	// MERCADO
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_market']) && $_POST['astroio_market'] == 'on')
	{
		$tablas = array(
			'users_market',
			'market_offers',
			'market_log',
			'market_stats',
		);
		foreach ($tablas as $t)
		{
			$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix.$t."`");
		}
	}

	// ─────────────────────────────────────────────────────────
	// PASE DE BATALLA
	// bp_config tiene last_reset NOT NULL sin default:
	// hay que darle valor explicito en el INSERT
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_bp']) && $_POST['astroio_bp'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."bp_users`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."bp_log`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."bp_config`");
		$GLOBALS['DATABASE']->query("INSERT INTO `".$prefix."bp_config` (`id`, `last_reset`, `season_name`) VALUES (1, 0, 'Temporada 1')");
	}

	// ─────────────────────────────────────────────────────────
	// BUGS
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_bugs']) && $_POST['astroio_bugs'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."bug_reports`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."bug_log`");
	}

	// ─────────────────────────────────────────────────────────
	// RIFAS
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_raffles']) && $_POST['astroio_raffles'] == 'on')
	{
		$tablas = array(
			'raffles',
			'raffle_prizes',
			'raffle_tickets',
			'raffle_log',
		);
		foreach ($tablas as $t)
		{
			$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix.$t."`");
		}
	}

	// ─────────────────────────────────────────────────────────
	// LOTERIA
	// lottery_config: todos los campos tienen default excepto id
	// asi que INSERT (id) VALUES (1) es suficiente
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_lottery']) && $_POST['astroio_lottery'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."lottery_draws`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."lottery_tickets`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."lottery_log`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."lottery_config`");
		$GLOBALS['DATABASE']->query("INSERT INTO `".$prefix."lottery_config` (`id`) VALUES (1)");
	}

	// ─────────────────────────────────────────────────────────
	// MEJORAS
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_improvements']) && $_POST['astroio_improvements'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_improvements_inv`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_improvements_eq`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."improvements_log`");
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."users` SET `improvements_compras_hoy` = 0, `improvements_ultima_compra` = 0");
	}

	// ─────────────────────────────────────────────────────────
	// NTX-20
	// Solo se resetea uni1_users.ntx20 (columna real)
	// La columna uni1_planets.nxt20 ya no existe en la BD
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_ntx20']) && $_POST['astroio_ntx20'] == 'on')
	{
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."users` SET `ntx20` = 0");
	}

	// ─────────────────────────────────────────────────────────
	// FONDOS GLOBALES (wallet_fund + market_fund)
	// v3.0: + 3 columnas nuevas de wallet_fund
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_funds']) && $_POST['astroio_funds'] == 'on')
	{
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."wallet_fund` SET
			`fondo_visible` = 0,
			`fondo_proyecto` = 0,
			`fondo_reservado_temp2` = 0,
			`total_invertido` = 0,
			`total_retirado` = 0,
			`tasa_war_kyber` = 0,
			`retiros_habilitados` = 0,
			`fecha_apertura` = NULL,
			`fecha_cierre` = NULL,
			`ultima_actualizacion` = UNIX_TIMESTAMP(),
			`min_retiro_nxt20` = 300,
			`ntx20_inversion_total` = 0,
			`tasa_nxt20_actual` = 0.000000
		WHERE `id` = 1");

		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."market_fund` SET
			`total_earned` = 0,
			`from_seller` = 0,
			`from_buyer` = 0,
			`from_admin` = 0,
			`last_update` = UNIX_TIMESTAMP()
		WHERE `id` = 1");
	}

	// ─────────────────────────────────────────────────────────
	// REFERIDOS
	// ✅ v5.5: solo se resetea `ref_id`. La bandera `ref_bonus` ya no se usa.
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_refs']) && $_POST['astroio_refs'] == 'on')
	{
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."users` SET `ref_id` = 0");
	}

	// ═════════════════════════════════════════════════════════
	// v2.7 - NUEVOS MODULOS
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// WAR - Guerra entre alianzas
	// 6 TRUNCATE + 1 UPDATE (temporada se desactiva)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_war']) && $_POST['astroio_war'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."war_battles`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."war_participants`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."war_points`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."war_chests`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."war_history`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."war_log`");
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."war_seasons` SET `estado` = 'sin_temporada', `pausada` = 0, `fecha_inicio` = NULL, `fecha_fin` = NULL");
	}

	// ─────────────────────────────────────────────────────────
	// ALLIANCE BANK - Banco de alianza
	// 4 TRUNCATE + 1 UPDATE (saldo y nivel a 0)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_allybank']) && $_POST['astroio_allybank'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."alliance_bank_log`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."alliance_bank_daily`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."alliance_bank_bonuses`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."alliance_bank_tesorero_log`");
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."alliance_bank` SET `metal` = 0, `crystal` = 0, `deuterium` = 0, `darkmatter` = 0, `ntx20` = 0, `level` = 0, `tesorero_id` = 0, `daily_limit` = 0");
	}

	// ─────────────────────────────────────────────────────────
	// FLEETTOOLS - Herramientas de flota
	// 3 TRUNCATE (favoritos + presets + logs)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_fleettools']) && $_POST['astroio_fleettools'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_coord_favorites`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_fleet_presets`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."fleettools_log`");
	}

	// ─────────────────────────────────────────────────────────
	// TASKS - Tareas sociales
	// 2 TRUNCATE (users_tasks + tasks_log)
	// tasks_catalog NO se toca (3 tareas base)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_tasks']) && $_POST['astroio_tasks'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_tasks`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."tasks_log`");
	}

	// ─────────────────────────────────────────────────────────
	// ACHIEVEMENTS - Logros progresivos
	// 2 TRUNCATE (users_achievements + achievements_log)
	// achievements_catalog NO se toca (120 logros)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_achievements']) && $_POST['astroio_achievements'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_achievements`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."achievements_log`");
	}

	// ─────────────────────────────────────────────────────────
	// DISCORD - OAuth + vinculaciones con proveedores externos
	// 2 TRUNCATE
	// ATENCION: users_to_extauth borra las vinculaciones con
	// Discord. Los jugadores tendran que re-vincular su cuenta.
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_discord']) && $_POST['astroio_discord'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."discord_oauth`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_to_extauth`");
	}

	// ═════════════════════════════════════════════════════════
	// v5.6 - POTENCIADORES (RESET UNIVERSAL)
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// BOOSTERS - Potenciadores ACTIVOS de TODOS los jugadores
	//
	// Acciones:
	//   1. Cuenta cuántos registros hay antes de borrar
	//   2. TRUNCATE de uni1_users_boosters (borra TODOS los activos)
	//   3. Registra la acción en el log de errores
	//
	// PRESERVA:
	//   - uni1_boosters (catálogo de potenciadores disponibles)
	//
	// NOTA: Si quieres restaurar el CATÁLOGO, usa el checkbox
	//       "astroio_boosters_catalog" (ver abajo).
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_boosters']) && $_POST['astroio_boosters'] == 'on')
	{
		// 1) Contar cuántos potenciadores activos hay antes de borrar
		$countBefore = (int) $GLOBALS['DATABASE']->selectSingle(
			"SELECT COUNT(*) AS cnt FROM `".$prefix."users_boosters`"
		)['cnt'];

		// 2) Borrar TODOS los potenciadores activos
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_boosters`");

		// 3) Log de auditoría
		$logMsg = date('Y-m-d H:i:s') . " [Reset Universo] Potenciadores eliminados: " . $countBefore . " registros (todos los jugadores)" . PHP_EOL;
		@file_put_contents(ROOT_PATH . 'includes/error.log', $logMsg, FILE_APPEND);
	}

	// ─────────────────────────────────────────────────────────
	// BOOSTERS CATALOG - Restaurar los 7 POTENCIADORES BASE
	//
	// Acciones:
	//   1. TRUNCATE de uni1_boosters (borra el catálogo actual)
	//   2. Re-inserta los 7 potenciadores con sus valores originales
	//   3. Log de auditoría
	//
	// Útil cuando:
	//   - Alguien modificó los valores por error
	//   - Alguien borró un potenciador sin querer
	//   - Quieres volver al estado "de fábrica"
	//
	// PRESERVA:
	//   - uni1_users_boosters (NO se toca esta tabla)
	//
	// ⚠️ ATENCIÓN: Si un potenciador cambió de ID o tipo, los
	//    jugadores que lo tenían activo podrían tener referencias
	//    rotas. Se recomienda resetear también `astroio_boosters`
	//    (checkbox de arriba) para evitar inconsistencias.
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_boosters_catalog']) && $_POST['astroio_boosters_catalog'] == 'on')
	{
		// 1) Borrar el catálogo actual
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."boosters`");

		// 2) Re-insertar los 7 POTENCIADORES BASE (IDs 6-12)
		$GLOBALS['DATABASE']->query(
			"INSERT INTO `".$prefix."boosters`
				(`booster_id`, `booster_name`, `booster_desc`, `booster_icon`, `booster_color`, `booster_type`, `booster_value`, `booster_duration`)
			 VALUES
				(6,  'Pot. Estructuras',     'Aumenta los Droides Constructores.',                  'BLD', '#00ccff', 'droids_builder',    1.00, 86400),
				(7,  'Pot. Investigaciones', 'Aumenta los Slots de Investigación.',                 'TEC', '#aa44ff', 'research_slots',    2.00, 86400),
				(8,  'Pot. Hangar',          'Reduce el tiempo de construcción de naves en un 20%.', 'HNG', '#66ff99', 'ship_time',       -20.00, 86400),
				(9,  'Pot. Materia Oscura',  'Aumenta la MO obtenida en expediciones.',             'MO',  '#ffcc00', 'exp_darkmatter',   20.00, 86400),
				(10, 'Pot. Minero',          'Aumenta la producción de recursos.',                  'PRO', '#ffaa33', 'resources',        20.00, 86400),
				(11, 'Pot. Espía',           'Aumenta el poder de espionaje.',                      'SPY', '#ff4444', 'spy_power',        20.00, 86400),
				(12, 'Pot. Energía',         'Aumenta la producción de energía.',                   'ENE', '#ffdd33', 'energy',           20.00, 86400)"
		);

		// 3) Log de auditoría
		$logMsg = date('Y-m-d H:i:s') . " [Reset Universo] Catálogo de boosters restaurado a los 7 base (IDs 6-12)" . PHP_EOL;
		@file_put_contents(ROOT_PATH . 'includes/error.log', $logMsg, FILE_APPEND);
	}

	// ─────────────────────────────────────────────────────────
	// CONTAINERS - Historial de contenedores
	// 1 TRUNCATE
	// container_loot (catalogo) NO se toca (39 items)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_containers']) && $_POST['astroio_containers'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."container_history`");
	}

	// ─────────────────────────────────────────────────────────
	// RACES / FACTIONS - Resetear eleccion de raza/faccion
	// 1 UPDATE (columnas en users)
	// races y factions (catalogos) NO se tocan
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_races']) && $_POST['astroio_races'] == 'on')
	{
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."users` SET `race_id` = 0, `faction_id` = 0, `race_chosen_at` = 0");
	}

	// ═════════════════════════════════════════════════════════
	// v3.5 - SISTEMA PvE
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// PvE - Crisis + Imperio Caído + Fantasmas + Flotas
	//
	// Acciones:
	//   1. Borra flotas mission 20 (crisis), 21 (imperio), 22 (contraataque)
	//   2. Borra fleet_events huérfanos
	//   3. Borra fantasmas (users + planets + statpoints con id >= 900M)
	//   4. TRUNCATE de las 10 tablas PvE
	//   5. v3.0: resetea users.is_pve, pve_event_id, pve_event_type
	//
	// PRESERVA:
	//   - uni1_pve_config              (145 configs)
	//   - uni1_pve_empire_templates    (plantillas)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_pve']) && $_POST['astroio_pve'] == 'on')
	{
		// 1) Borrar flotas PvE (misiones 20, 21, 22)
		$GLOBALS['DATABASE']->query(
			"DELETE FROM ".FLEETS." WHERE `fleet_mission` IN (20, 21, 22)"
		);

		// 2) Borrar fleet_events huérfanos (sin flota)
		$GLOBALS['DATABASE']->query(
			"DELETE fe FROM ".FLEETS_EVENT." fe
			 LEFT JOIN ".FLEETS." f ON f.fleet_id = fe.fleetID
			 WHERE f.fleet_id IS NULL"
		);

		// 3) Borrar fantasmas (users + planets + statpoints con id >= 900M)
		$GLOBALS['DATABASE']->query("DELETE FROM ".PLANETS."    WHERE `id_owner` >= 900000000");
		$GLOBALS['DATABASE']->query("DELETE FROM ".STATPOINTS." WHERE `id_owner` >= 900000000");
		$GLOBALS['DATABASE']->query("DELETE FROM ".USERS."      WHERE `id`       >= 900000000");

		// 4) TRUNCATE de las 10 tablas PvE
		//    Preserva: pve_config, pve_empire_templates
		$pveTablas = array(
			'pve_crisis',
			'pve_crisis_waves',
			'pve_crisis_attacks',
			'pve_empires',
			'pve_empire_attacks',
			'pve_rewards',
			'pve_achievements',
			'pve_log',
			'pve_acs_invites',
			'pve_ghosts',
		);

		foreach ($pveTablas as $t)
		{
			$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix.$t."`");
		}

		// 5) v3.0: resetear columnas PvE en users
		$GLOBALS['DATABASE']->query(
			"UPDATE `".$prefix."users` SET
				`is_pve` = 0,
				`pve_event_id` = 0,
				`pve_event_type` = 'none'
			WHERE `is_pve` = 1 OR `pve_event_id` > 0"
		);
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - BOSS SYSTEM (El Devorador Estelar)
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// BOSS - 4 tablas + fantasmas de boss
	//      + resetear pve_boss_enabled en config
	// Preserva: uni1_pve_config (contiene las 48 configs del boss)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_boss']) && $_POST['astroio_boss'] == 'on')
	{
		// 1) Borrar flotas del boss (mission 23 = boss)
		$GLOBALS['DATABASE']->query("DELETE FROM ".FLEETS." WHERE `fleet_mission` = 23");

		// 2) Borrar fantasmas de boss (id >= 900M con event_type = 'boss')
		$GLOBALS['DATABASE']->query(
			"DELETE p FROM ".PLANETS." p
			 INNER JOIN ".USERS." u ON u.id_planet = p.id
			 WHERE u.id >= 900000000"
		);

		// 3) TRUNCATE de las 4 tablas del boss
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_boss_damage`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_boss_ghosts`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_boss_registrations`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_boss_event`");

		// 4) Resetear la config del boss a defaults
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."pve_config` SET
			`config_value` = '1', `updated_at` = UNIX_TIMESTAMP()
			WHERE `config_key` = 'pve_boss_enabled'");

		// 5) Resetear flag en users
		$GLOBALS['DATABASE']->query(
			"UPDATE `".$prefix."users` SET `pve_event_type` = 'none'
			 WHERE `pve_event_type` = 'boss'"
		);
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - BASTION DE LA ALIANZA
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// BASTION - 5 tablas + fantasmas + waves
	//         + resetear pve_bastion_enabled en config
	// Preserva: uni1_pve_config (contiene las 53 configs del bastión)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_bastion']) && $_POST['astroio_bastion'] == 'on')
	{
		// 1) Borrar flotas del bastión (mission 24 = bastion)
		$GLOBALS['DATABASE']->query("DELETE FROM ".FLEETS." WHERE `fleet_mission` = 24");

		// 2) TRUNCATE de las 5 tablas del bastión
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_bastion_waves`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_bastion_damage`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_bastion_ghosts`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_bastion_registrations`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."pve_bastion_event`");

		// 3) Resetear la config del bastión a defaults
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."pve_config` SET
			`config_value` = '1', `updated_at` = UNIX_TIMESTAMP()
			WHERE `config_key` = 'pve_bastion_enabled'");

		// 4) Resetear flag en users
		$GLOBALS['DATABASE']->query(
			"UPDATE `".$prefix."users` SET `pve_event_type` = 'none'
			 WHERE `pve_event_type` = 'bastion'"
		);
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - BANCO ADMIN
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// ADMIN BANK - Cuentas + movimientos + transferencias
	//
	// NO se toca admin_bank_data (tarjeta/teléfono de admins).
	// Solo se resetean saldos, movimientos y transferencias.
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_admin_bank']) && $_POST['astroio_admin_bank'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."admin_bank_movements`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."admin_bank_transfers`");

		// Resetear saldos a 0 pero preservar la cuenta de cada admin
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."admin_bank_accounts` SET
			`saldo` = 0,
			`marca_proyecto` = 0,
			`ultima_actualizacion` = UNIX_TIMESTAMP()");

		// NOTA: admin_bank_data (tarjeta, teléfono, titular, banco)
		// NO se toca para no perder los datos bancarios de los admins
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - PVP (Arenas + Torneos)
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// PVP - 11 tablas + pvp_points en users
	// Preserva: uni1_pvp_config (config del admin)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_pvp']) && $_POST['astroio_pvp'] == 'on')
	{
		$pvpTablas = array(
			'pvp_arena_attacks',
			'pvp_arena_players',
			'pvp_arenas',
			'pvp_tournament_attacks',
			'pvp_tournament_matches',
			'pvp_tournament_rounds',
			'pvp_tournament_players',
			'pvp_tournaments',
			'pvp_log',
			'pvp_achievements',
		);

		foreach ($pvpTablas as $t)
		{
			$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix.$t."`");
		}

		// Resetear puntos PvP de los usuarios
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."users` SET `pvp_points` = 0");

		// Resetear config PvP (11 configs)
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."pvp_config` SET
			`config_value` = `config_value`,
			`updated_at` = UNIX_TIMESTAMP()
			WHERE `config_key` = 'arena_enabled'");
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - ASTEROIDES
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// ASTEROIDS - 1 tabla (asteroides actuales)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_asteroids']) && $_POST['astroio_asteroids'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."asteroids`");
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - TIENDA NTX-20 (Shop)
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// SHOP - Tienda NTX-20
	//
	// Acciones:
	//   1. Borra el historial de compras (shop_purchases)
	//   2. Borra los auto-snapshots de rollback (shop_autosave)
	//
	// PRESERVA:
	//   - uni1_shop_items       (ofertas configuradas por el admin)
	//   - uni1_shop_templates   (plantillas guardadas por el admin)
	//
	// Motivo: si se resetea el universo, las ofertas y plantillas
	// siguen siendo válidas (no dependen de usuarios específicos).
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_shop']) && $_POST['astroio_shop'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."shop_purchases`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."shop_autosave`");
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - TALENTOS DE ALIANZA
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// TALENT - Puntos + rangos elegidos + log de alianza
	// 3 TRUNCATE
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_talent']) && $_POST['astroio_talent'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."alliance_talent_log`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."alliance_talent_ranks`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."alliance_talent_points`");
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - WALLET AMM (historial de tasa) - complemento
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// WALLET AMM - Reset del historial de tasa + inversion total
	// Se complementa con astroio_wallet y astroio_funds
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_wallet_amm']) && $_POST['astroio_wallet_amm'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."wallet_tasa_historial`");
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."wallet_fund` SET
			`ntx20_inversion_total` = 0,
			`tasa_nxt20_actual` = 0.000000
			WHERE `id` = 1");
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."users` SET `ntx20_inversion` = 0");
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - AUTH EXTERNA
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// USERS_AUTH - Vinculaciones con Google/Discord (tabla nueva)
	// 1 TRUNCATE
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_users_auth']) && $_POST['astroio_users_auth'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."users_auth`");
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - MISILES NUEVOS
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// MISILES - Reset de los 2 misiles nuevos en planets
	// 2 columnas: antimatter_misil, advanced_interceptor_misil
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_misiles']) && $_POST['astroio_misiles'] == 'on')
	{
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."planets` SET
			`antimatter_misil` = 0,
			`advanced_interceptor_misil` = 0");
	}

	// ═════════════════════════════════════════════════════════
	// v3.0 - PLANETARIO (Droides)
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// PLANETARIO - Reset de droides en planets
	// 4 columnas: droids_builder, droids_engineer, last_teleport, last_rename
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_planetario']) && $_POST['astroio_planetario'] == 'on')
	{
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."planets` SET
			`droids_builder` = 0,
			`droids_engineer` = 0,
			`last_teleport` = 0,
			`last_rename` = 0");
	}

	// ═════════════════════════════════════════════════════════
	// v3.3 - BOOST FIN DE SEMANA
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// WEEKEND BOOST - Reset de la configuración completa
	//
	// Acciones:
	//   1. TRUNCATE uni1_weekend_boost (borra toda la config)
	//   2. INSERT de la fila id=1 con defaults:
	//      - enabled = 0 (el admin debe reactivarlo)
	//      - Ventana: Viernes 00:00 → Domingo 23:59
	//      - Normal: 1,1,1,1,1,1
	//      - Weekend: 2,4,2,2,3,2
	//
	// DESPUÉS DEL RESET:
	//   - Los valores de uni1_config NO se tocan (quedan como están)
	//   - El admin debe reactivar el sistema desde admin.php?page=weekendboost
	//   - Al activarlo, el cron aplicará el estado según la hora actual
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_weekend_boost']) && $_POST['astroio_weekend_boost'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."weekend_boost`");
		$GLOBALS['DATABASE']->query(
			"INSERT INTO `".$prefix."weekend_boost` (`id`) VALUES (1)"
		);
	}

	// ═════════════════════════════════════════════════════════
	// v3.4 - MINI TORNEOS
	// ═════════════════════════════════════════════════════════

	// ─────────────────────────────────────────────────────────
	// TOURNEY - Mini Torneos (rotativos de 24h)
	//
	// Acciones:
	//   1. TRUNCATE uni1_tourney               (torneos activos)
	//   2. TRUNCATE uni1_tourney_participante  (inscripciones + puntos)
	//   3. TRUNCATE uni1_tourney_logs          (historial de ganadores)
	//   4. UPDATE uni1_config SET tourneyEnd = 0
	//
	// DESPUÉS DEL RESET:
	//   - El cronjob 28 (Tournaments) sigue activo
	//   - En la próxima ejecución del cron (cada hora), sorteará
	//     5 torneos nuevos y arrancará un nuevo ciclo de 24h
	//
	// PRESERVA:
	//   - El cronjob 28 (no se toca)
	// ─────────────────────────────────────────────────────────
	if (isset($_POST['astroio_tourney']) && $_POST['astroio_tourney'] == 'on')
	{
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."tourney`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."tourney_participante`");
		$GLOBALS['DATABASE']->query("TRUNCATE TABLE `".$prefix."tourney_logs`");
		$GLOBALS['DATABASE']->query("UPDATE `".$prefix."config` SET `tourneyEnd` = 0");
	}

	// ─────────────────────────────────────────────────────────
	// NO se tocan (catalogos estaticos / datos de admins):
	//   improvements_catalog    (990 items)
	//   improvements_seasons    (4 temporadas)
	//   bug_categories          (12 categorias)
	//   admin_bank_data         (datos bancarios de admins)
	//   tasks_catalog           (3 tareas base)
	//   achievements_catalog    (120 logros)
	//   container_loot          (39 items)
	//   races                   (6 razas)
	//   factions                (6 facciones)
	//   vars / vars_requriements / vars_rapidfire (catalogos de naves)
	//   pve_config              (145 configs PvE - Boss + Bastión)
	//   pve_empire_templates    (plantillas de imperio)
	//   shop_items              (ofertas de la tienda - config del admin)
	//   shop_templates          (plantillas de tienda - config del admin)
	//   pvp_config              (11 configs del admin)
	//   boosters                (7 potenciadores - solo si NO se marca
	//                            astroio_boosters_catalog)
	// ─────────────────────────────────────────────────────────
}