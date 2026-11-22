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
 * ✅ FIX AstroIO v2.7:
 *   Las 3 primeras constantes ahora usan if(!defined()) para evitar
 *   el warning "Constant already defined" cuando el cron CLI las
 *   define antes (por ejemplo, desde cron.php). Sin este fix, el
 *   errorHandler de 2Moons convertía el warning en ErrorException,
 *   y la query de dbVersion fallaba silenciosamente → el cron CLI
 *   moría sin imprimir nada.
 *
 * ✅ AstroIO v2.8 (MÍSTICOS):
 *   - Se añaden las tablas USERS_MISTIC y MISTIC_ITEMS.
 *
 * ✅ AstroIO v3.4 (MISIONES DE FACCIÓN):
 *   - Se añaden las 7 tablas del sistema de misiones de facción.
 */

if (!defined('DB_VERSION_REQUIRED')) define('DB_VERSION_REQUIRED', 4);
if (!defined('DB_NAME'))             define('DB_NAME'  , $database['databasename']);
if (!defined('DB_PREFIX'))           define('DB_PREFIX', $database['tableprefix']);

// Data Tabells
$dbTableNames	= array(
	'AKS'				=> DB_PREFIX.'aks',
	'ALLIANCE'			=> DB_PREFIX.'alliance',
	'ALLIANCE_RANK'		=> DB_PREFIX.'alliance_ranks',
	'ALLIANCE_REQUEST'	=> DB_PREFIX.'alliance_request',
	'BANNED'			=> DB_PREFIX.'banned',
	'BUDDY'				=> DB_PREFIX.'buddy',
	'BUDDY_REQUEST'		=> DB_PREFIX.'buddy_request',
	'CHAT_BAN'			=> DB_PREFIX.'chat_bans',
	'CHAT_INV'			=> DB_PREFIX.'chat_invitations',
	'CHAT_MES'			=> DB_PREFIX.'chat_messages',
	'CHAT_ON'			=> DB_PREFIX.'chat_online',
	'CONFIG'			=> DB_PREFIX.'config',
	'CRONJOBS'			=> DB_PREFIX.'cronjobs',
	'CRONJOBS_LOG'		=> DB_PREFIX.'cronjobs_log',
	'DIPLO'				=> DB_PREFIX.'diplo',
	'FLEETS'			=> DB_PREFIX.'fleets',
	'FLEETS_EVENT'		=> DB_PREFIX.'fleet_event',
	'LOG'				=> DB_PREFIX.'log',
	'LOG_FLEETS'		=> DB_PREFIX.'log_fleets',
	'LOSTPASSWORD'		=> DB_PREFIX.'lostpassword',
	'NEWS'				=> DB_PREFIX.'news',
	'NOTES'				=> DB_PREFIX.'notes',
	'MESSAGES'			=> DB_PREFIX.'messages',
	'MULTI'				=> DB_PREFIX.'multi',
	'PLANETS'			=> DB_PREFIX.'planets',
	'RW'				=> DB_PREFIX.'raports',
	'RECORDS'			=> DB_PREFIX.'records',
	'SESSION'			=> DB_PREFIX.'session',
	'SHORTCUTS'			=> DB_PREFIX.'shortcuts',
	'STATPOINTS'		=> DB_PREFIX.'statpoints',
	'SYSTEM'		    => DB_PREFIX.'system',
	'TICKETS'			=> DB_PREFIX.'ticket',
	'TICKETS_ANSWER'	=> DB_PREFIX.'ticket_answer',
	'TICKETS_CATEGORY'	=> DB_PREFIX.'ticket_category',
	'TOPKB'				=> DB_PREFIX.'topkb',
	'TOPKB_USERS'		=> DB_PREFIX.'users_to_topkb',
	'USERS'				=> DB_PREFIX.'users',
	'USERS_ACS'			=> DB_PREFIX.'users_to_acs',
	'USERS_AUTH'		=> DB_PREFIX.'users_to_extauth',
	'USERS_VALID'	 	=> DB_PREFIX.'users_valid',
	'VARS'	 			=> DB_PREFIX.'vars',
	'VARS_RAPIDFIRE'	=> DB_PREFIX.'vars_rapidfire',
	'VARS_REQUIRE'	 	=> DB_PREFIX.'vars_requriements',

	// ============================================
	// AstroIO - Sistema PvE (Crisis + Imperio)
	// ============================================
	'PVE_CONFIG'			=> DB_PREFIX.'pve_config',
	'PVE_CRISIS'			=> DB_PREFIX.'pve_crisis',
	'PVE_CRISIS_WAVES'		=> DB_PREFIX.'pve_crisis_waves',
	'PVE_CRISIS_ATTACKS'	=> DB_PREFIX.'pve_crisis_attacks',
	'PVE_EMPIRES'			=> DB_PREFIX.'pve_empires',
	'PVE_EMPIRE_ATTACKS'	=> DB_PREFIX.'pve_empire_attacks',
	'PVE_REWARDS'			=> DB_PREFIX.'pve_rewards',
	'PVE_ACHIEVEMENTS'		=> DB_PREFIX.'pve_achievements',
	'PVE_LOG'				=> DB_PREFIX.'pve_log',

	// 🆕 AÑADIDOS EN v3.0
	'PVE_GHOSTS'			=> DB_PREFIX.'pve_ghosts',
	'PVE_EMPIRE_TEMPLATES'	=> DB_PREFIX.'pve_empire_templates',

	// 🆕 AÑADIDO EN v3.5 (fix cleanup ACS invites)
	'PVE_ACS_INVITES'		=> DB_PREFIX.'pve_acs_invites',

	// 🆕 AÑADIDOS EN v3.6 (Torneo del Devorador)
	'PVE_BOSS_EVENT'			=> DB_PREFIX.'pve_boss_event',
	'PVE_BOSS_REGISTRATIONS'	=> DB_PREFIX.'pve_boss_registrations',
	'PVE_BOSS_GHOSTS'			=> DB_PREFIX.'pve_boss_ghosts',
	'PVE_BOSS_DAMAGE'			=> DB_PREFIX.'pve_boss_damage',

	// 🆕 AÑADIDOS EN v4.2 (Bastión Asediado — torneo defensivo)
	'PVE_BASTION_EVENT'			=> DB_PREFIX.'pve_bastion_event',
	'PVE_BASTION_REGISTRATIONS'	=> DB_PREFIX.'pve_bastion_registrations',
	'PVE_BASTION_GHOSTS'		=> DB_PREFIX.'pve_bastion_ghosts',
	'PVE_BASTION_WAVES'			=> DB_PREFIX.'pve_bastion_waves',
	'PVE_BASTION_DAMAGE'		=> DB_PREFIX.'pve_bastion_damage',

	// ============================================
	// AstroIO - Sistema PvP (Arenas + Torneos)
	// ============================================
	'PVP_CONFIG'				=> DB_PREFIX.'pvp_config',
	'PVP_ARENAS'				=> DB_PREFIX.'pvp_arenas',
	'PVP_ARENA_PLAYERS'			=> DB_PREFIX.'pvp_arena_players',
	'PVP_ARENA_ATTACKS'			=> DB_PREFIX.'pvp_arena_attacks',
	'PVP_TOURNAMENTS'			=> DB_PREFIX.'pvp_tournaments',
	'PVP_TOURNAMENT_PLAYERS'	=> DB_PREFIX.'pvp_tournament_players',
	'PVP_TOURNAMENT_ROUNDS'		=> DB_PREFIX.'pvp_tournament_rounds',
	'PVP_TOURNAMENT_MATCHES'	=> DB_PREFIX.'pvp_tournament_matches',
	'PVP_TOURNAMENT_ATTACKS'	=> DB_PREFIX.'pvp_tournament_attacks',
	'PVP_LOG'					=> DB_PREFIX.'pvp_log',
	'PVP_ACHIEVEMENTS'			=> DB_PREFIX.'pvp_achievements',

	// ============================================
	// AstroIO - Sistema de Asteroides
	// ============================================
	'ASTEROIDS'					=> DB_PREFIX.'asteroids',

	// ============================================
	// AstroIO - Sistema de Tienda NTX-20
	// ============================================
	'SHOP_ITEMS'				=> DB_PREFIX.'shop_items',
	'SHOP_TEMPLATES'			=> DB_PREFIX.'shop_templates',
	'SHOP_AUTOSAVE'				=> DB_PREFIX.'shop_autosave',
	'SHOP_PURCHASES'			=> DB_PREFIX.'shop_purchases',

	// ============================================
	// AstroIO - Boost de Fin de Semana
	// ============================================
	'WEEKEND_BOOST'				=> DB_PREFIX.'weekend_boost',

	// ============================================
	// AstroIO - Minijuego Topo (Golpea al Topo)
	// ============================================
	'GAMEDU'					=> DB_PREFIX.'gamedu',
	'GAMEDU_CONFIG'				=> DB_PREFIX.'gamedu_config',
	'GAMEDU_TOKENS'				=> DB_PREFIX.'gamedu_tokens',

	// ============================================
	// AstroIO - Mini Torneos (rotativos 24h)
	// ============================================
	'TOURNEY'					=> DB_PREFIX.'tourney',
	'TOURNEYPARTICI'			=> DB_PREFIX.'tourney_participante',
	'TOURNEYLOGS'				=> DB_PREFIX.'tourney_logs',

	// ============================================
	// AstroIO - Sistema de Místicos (Oficiales)
	// ============================================
	'MISTIC_ITEMS'				=> DB_PREFIX.'mistic_items',
	'USERS_MISTIC'				=> DB_PREFIX.'users_mistic',

	// ============================================
	// AstroIO - Sistema de Misiones de Facción
	// ============================================
	'FACTION_MISSIONS'			=> DB_PREFIX.'faction_missions',
	'USERS_FACTION_MISSIONS'	=> DB_PREFIX.'users_faction_missions',
	'FACTION_DAILY_ROTATION'	=> DB_PREFIX.'faction_daily_rotation',
	'FACTION_GLOBAL_MISSIONS'	=> DB_PREFIX.'faction_global_missions',
	'FACTION_GLOBAL_CONTRIB'	=> DB_PREFIX.'faction_global_contributions',
	'FACTION_BONUSES'			=> DB_PREFIX.'faction_bonuses',
	'FACTION_MISSIONS_LOG'		=> DB_PREFIX.'faction_missions_log',
);
// MOD-TABLES