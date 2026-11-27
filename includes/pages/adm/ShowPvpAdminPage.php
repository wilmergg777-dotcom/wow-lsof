<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ============================================
 *  ASTROIO - Panel Admin del Sistema PvP
 *  Archivo: includes/pages/adm/ShowPvpAdminPage.php
 *  Versión: 2.0 — Doble Riel (NTX-20 / UNTX-20)
 *
 *  v1.0 — Panel admin base PvP
 *  v2.0 — Doble Riel:
 *        · saveConfig: precios BASE (el panel configura base NTX-20)
 *        · createTournament: precios BASE
 *        · refundUser: usa addRealAmount (auto-detecta riel del user)
 *        · cancelArena: mensaje sin "NTX-20" hardcodeado
 *        · stats: desglose pool_ntx20 / pool_untx20
 *        · arenas/torneos: campos pool_ntx20_fmt / pool_untx20_fmt
 * ============================================
 */

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) {
	throw new Exception("Permission error!");
}

function ShowPvpAdmin()
{
	global $LNG;

	$template = new template();
	$db       = Database::get();
	$action   = HTTP::_GP('mode', '');
	$tab      = HTTP::_GP('tab', 'dashboard');

	$message = '';
	$msgType = 'info';

	// ============================================
	// PREFIJO DE TABLAS
	// ============================================
	$prefix = 'uni1_';
	if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
	elseif (defined('PREFIX')) $prefix = PREFIX;

	// ============================================
	// CARGAR HELPERS
	// ============================================
	require_once ROOT_PATH.'includes/classes/PVPHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVPArenaHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVPTournamentHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVPAchievementHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVPProcessor.class.php';

	// ============================================
	// PROCESAR ACCIONES
	// ============================================

	// ─── GUARDAR CONFIG GLOBAL (Dashboard) ───
	// ⚠️ TODOS los precios se guardan en BASE NTX-20.
	//    El Helper multiplica ×2 al cobrar a jugadores QVAPAY.
	if ($action === 'saveConfig') {
		try {
			$configs = array(
				// Activar/desactivar
				'arena_enabled'          => (int) HTTP::_GP('arena_enabled', 0),
				'tournament_enabled'     => (int) HTTP::_GP('tournament_enabled', 0),

				// Precios de arenas (BASE NTX-20)
				'arena_1v1_min'          => max(0, (int) HTTP::_GP('arena_1v1_min', 10)),
				'arena_1v1_max'          => max(0, (int) HTTP::_GP('arena_1v1_max', 10000)),
				'arena_2v2_price'        => max(0, (int) HTTP::_GP('arena_2v2_price', 50)),
				'arena_3v3_price'        => max(0, (int) HTTP::_GP('arena_3v3_price', 100)),

				// Tiempos de arenas
				'arena_expire_hours'     => max(1, (int) HTTP::_GP('arena_expire_hours', 24)),
				'arena_duration_hours'   => max(1, (int) HTTP::_GP('arena_duration_hours', 48)),
				'arena_extra_hours'      => max(1, (int) HTTP::_GP('arena_extra_hours', 5)),
				'arena_claim_days'       => max(1, (int) HTTP::_GP('arena_claim_days', 4)),

				// Comisión de torneos
				'tournament_commission'  => max(0, min(100, (int) HTTP::_GP('tournament_commission', 5))),
			);

			// Validar que min <= max en 1v1
			if ($configs['arena_1v1_min'] > $configs['arena_1v1_max']) {
				$temp = $configs['arena_1v1_min'];
				$configs['arena_1v1_min'] = $configs['arena_1v1_max'];
				$configs['arena_1v1_max'] = $temp;
			}

			foreach ($configs as $key => $value) {
				$existing = $db->selectSingle(
					"SELECT `config_key` FROM %%PVP_CONFIG%% WHERE `config_key` = :key LIMIT 1;",
					array(':key' => $key)
				);

				if (!empty($existing)) {
					$db->update(
						"UPDATE %%PVP_CONFIG%% SET `config_value` = :val, `updated_at` = :now WHERE `config_key` = :key;",
						array(':val' => (string)$value, ':now' => TIMESTAMP, ':key' => $key)
					);
				} else {
					$db->insert(
						"INSERT INTO %%PVP_CONFIG%% (`config_key`, `config_value`, `updated_at`) VALUES (:key, :val, :now);",
						array(':key' => $key, ':val' => (string)$value, ':now' => TIMESTAMP)
					);
				}
			}

			PVPHelper::clearConfigCache();
			$message = '💾 Configuración PvP guardada correctamente. Los precios están en base NTX-20 (QVAPAY paga ×2 en UNTX-20).';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'dashboard';
	}

	// ─── CREAR TORNEO (admin) ───
	// ⚠️ entry_fee y alliance_entry_fee son BASE NTX-20.
	if ($action === 'createTournament') {
		try {
			$type       = HTTP::_GP('type', '1v1');
			$mode       = HTTP::_GP('tmode', 'single');
			$entryFee   = (int) HTTP::_GP('entry_fee', 0);
			$allyFee    = (int) HTTP::_GP('alliance_entry_fee', 0);
			$maxPlayers = (int) HTTP::_GP('max_players', 8);
			$roundHours = (int) HTTP::_GP('round_hours', 24);
			$commission = (int) HTTP::_GP('commission', 5);
			$regHours   = (int) HTTP::_GP('registration_hours', 24);

			// Winner configs
			$w1 = (int) HTTP::_GP('w1', 70);
			$w2 = (int) HTTP::_GP('w2', 20);
			$w3 = (int) HTTP::_GP('w3', 10);

			$winners = array();
			if ($w1 > 0) $winners[1] = $w1;
			if ($w2 > 0) $winners[2] = $w2;
			if ($w3 > 0) $winners[3] = $w3;

			$data = array(
				'type'                 => $type,
				'mode'                 => $mode,
				'entry_fee'            => $entryFee,
				'alliance_entry_fee'   => $allyFee,
				'max_players'          => $maxPlayers,
				'round_duration'       => $roundHours * 3600,
				'commission_pct'       => $commission,
				'winners_config'       => $winners,
				'registration_ends_at' => TIMESTAMP + ($regHours * 3600),
				'created_by'           => $GLOBALS['USER']['id'],
			);

			$res = PVPTournamentHelper::createTournament($data);

			if ($res['ok']) {
				$message = '🏆 Torneo #' . $res['tournament_id'] . ' creado correctamente.';
				$msgType = 'success';
			} else {
				$message = '❌ ' . $res['msg'];
				$msgType = 'error';
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'tournaments';
	}

	// ─── FORZAR CIERRE DE INSCRIPCIONES ───
	if ($action === 'forceCloseRegistration') {
		try {
			$tournamentId = (int) HTTP::_GP('id', 0);
			if ($tournamentId > 0) {
				$res = PVPTournamentHelper::closeRegistration($tournamentId);
				if ($res['ok']) {
					$message = '✅ ' . $res['msg'];
					$msgType = 'success';
				} else {
					$message = '❌ ' . $res['msg'];
					$msgType = 'error';
				}
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'tournaments';
	}

	// ─── CANCELAR TORNEO (con devolución) ───
	// El helper ya maneja dual-riel internamente (refund por riel).
	if ($action === 'cancelTournament') {
		try {
			$tournamentId = (int) HTTP::_GP('id', 0);
			$reason       = HTTP::_GP('reason', 'Cancelado por el admin');
			if ($tournamentId > 0) {
				$res = PVPTournamentHelper::cancelTournament($tournamentId, $reason);
				if ($res['ok']) {
					$message = '🛑 ' . $res['msg'];
					$msgType = 'success';
				} else {
					$message = '❌ ' . $res['msg'];
					$msgType = 'error';
				}
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'tournaments';
	}

	// ─── DESCALIFICAR JUGADOR ───
	if ($action === 'disqualifyPlayer') {
		try {
			$tournamentId = (int) HTTP::_GP('tournament_id', 0);
			$playerId     = (int) HTTP::_GP('player_id', 0);
			$reason       = HTTP::_GP('reason', 'Sin motivo especificado');

			if ($tournamentId > 0 && $playerId > 0) {
				$res = PVPTournamentHelper::disqualifyPlayer($tournamentId, $playerId, $reason);
				if ($res['ok']) {
					$message = '🚫 ' . $res['msg'];
					$msgType = 'success';
				} else {
					$message = '❌ ' . $res['msg'];
					$msgType = 'error';
				}
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'tournaments';
	}

	// ─── CANCELAR ARENA (con devolución) ───
	// El helper ya maneja dual-riel internamente (refund por riel).
	if ($action === 'cancelArena') {
		try {
			$arenaId = (int) HTTP::_GP('id', 0);
			if ($arenaId > 0) {
				$arena = PVPArenaHelper::getArena($arenaId);
				if (!empty($arena)) {
					$res = PVPArenaHelper::cancelArena($arenaId, (int) $arena['creator_id']);
					if ($res['ok']) {
						$message = '🛑 Arena #' . $arenaId . ' cancelada. Se devolvió la entrada a todos los jugadores en su riel.';
						$msgType = 'success';
					} else {
						$message = '❌ ' . $res['msg'];
						$msgType = 'error';
					}
				} else {
					$message = '❌ Arena no encontrada.';
					$msgType = 'error';
				}
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'arenas';
	}

	// ─── DEVOLVER SALDO MANUALMENTE A UN JUGADOR ───
	// El admin ingresa el monto REAL en la moneda del jugador.
	// Se detecta automáticamente el riel del user y se acredita
	// en la columna correcta (ntx20 o untx20).
	if ($action === 'refundUser') {
		try {
			$userId = (int) HTTP::_GP('user_id', 0);
			$amount = (int) HTTP::_GP('amount', 0);
			$reason = HTTP::_GP('reason', 'Devolución manual');

			if ($userId > 0 && $amount > 0) {
				$riel   = PVPHelper::getPlayerMethod($userId);
				$moneda = PVPHelper::getCurrencyLabel($userId);

				$ok = PVPHelper::addRealAmount($userId, $amount, $riel, 'pvp_admin_refund', $reason);
				if ($ok) {
					$message = '💎 Se devolvieron ' . number_format($amount) . ' ' . $moneda . ' al usuario #' . $userId . ' (riel: ' . $riel . ').';
					$msgType = 'success';
					PVPHelper::log('admin', 0, 'manual_refund', $userId, array(
						'amount' => $amount,
						'reason' => $reason,
						'riel'   => $riel,
						'admin'  => $GLOBALS['USER']['id'],
					));
				} else {
					$message = '❌ No se pudo devolver el ' . $moneda . '.';
					$msgType = 'error';
				}
			} else {
				$message = '❌ Usuario o cantidad inválidos.';
				$msgType = 'error';
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'actions';
	}

	// ─── FORZAR CRON PVP ───
	if ($action === 'forceCron') {
		try {
			$result = PVPProcessor::run(true);

			$detalles = array();
			if (!empty($result['arenas_expired']))             $detalles[] = $result['arenas_expired'] . ' arenas expiradas';
			if (!empty($result['arenas_resolved']))            $detalles[] = $result['arenas_resolved'] . ' arenas resueltas';
			if (!empty($result['tournaments_reg_closed']))     $detalles[] = $result['tournaments_reg_closed'] . ' inscripciones cerradas';
			if (!empty($result['tournaments_round_resolved'])) $detalles[] = $result['tournaments_round_resolved'] . ' rondas resueltas';
			if (!empty($result['notifications_sent']))         $detalles[] = $result['notifications_sent'] . ' notificaciones';

			if (!empty($detalles)) {
				$message = '⚙️ Cron PvP ejecutado: ' . implode(' · ', $detalles);
			} else {
				$message = '⚙️ Cron PvP ejecutado. No había nada que procesar.';
			}
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error en el cron: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'actions';
	}

	// ============================================
	// CARGAR DATOS PARA LA VISTA
	// ============================================

	$config = PVPHelper::getConfig();

	// --- Estadísticas globales (con desglose por riel) ---
	$stats = array(
		'arenas_waiting'           => 0,
		'arenas_active'            => 0,
		'arenas_finished'          => 0,
		'arenas_cancelled'         => 0,
		'tournaments_active'       => 0,
		'tournaments_finished'     => 0,
		'players_in_arenas'        => 0,
		'prize_pool_arenas'        => 0,
		'prize_pool_tourneys'      => 0,
		// 🆕 Doble riel
		'prize_pool_arenas_ntx20'      => 0,
		'prize_pool_arenas_untx20'     => 0,
		'prize_pool_tourneys_ntx20'    => 0,
		'prize_pool_tourneys_untx20'   => 0,
	);

	try {
		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` = 'waiting';");
		$stats['arenas_waiting'] = empty($row) ? 0 : (int) $row['c'];

		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` IN ('active','extra_time');");
		$stats['arenas_active'] = empty($row) ? 0 : (int) $row['c'];

		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` = 'finished';");
		$stats['arenas_finished'] = empty($row) ? 0 : (int) $row['c'];

		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` = 'cancelled';");
		$stats['arenas_cancelled'] = empty($row) ? 0 : (int) $row['c'];

		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_TOURNAMENTS%% WHERE `status` IN ('registration','running');");
		$stats['tournaments_active'] = empty($row) ? 0 : (int) $row['c'];

		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVP_TOURNAMENTS%% WHERE `status` = 'finished';");
		$stats['tournaments_finished'] = empty($row) ? 0 : (int) $row['c'];

		$row = $db->selectSingle(
			"SELECT COUNT(*) AS c FROM %%PVP_ARENA_PLAYERS%% ap
			 INNER JOIN %%PVP_ARENAS%% a ON a.`id` = ap.`arena_id`
			 WHERE a.`status` IN ('waiting','active','extra_time');"
		);
		$stats['players_in_arenas'] = empty($row) ? 0 : (int) $row['c'];

		// 🆕 Pools de arenas (legacy + desglose)
		$row = $db->selectSingle(
			"SELECT 
				COALESCE(SUM(`prize_pool`),0) AS t,
				COALESCE(SUM(`pool_ntx20`),0) AS t_ntx,
				COALESCE(SUM(`pool_untx20`),0) AS t_untx
			 FROM %%PVP_ARENAS%% 
			 WHERE `status` IN ('waiting','active','extra_time');"
		);
		$stats['prize_pool_arenas']        = empty($row) ? 0 : (int) $row['t'];
		$stats['prize_pool_arenas_ntx20']  = empty($row) ? 0 : (int) $row['t_ntx'];
		$stats['prize_pool_arenas_untx20'] = empty($row) ? 0 : (int) $row['t_untx'];

		// 🆕 Pools de torneos (legacy + desglose)
		$row = $db->selectSingle(
			"SELECT 
				COALESCE(SUM(`prize_pool`),0) AS t,
				COALESCE(SUM(`pool_ntx20`),0) AS t_ntx,
				COALESCE(SUM(`pool_untx20`),0) AS t_untx
			 FROM %%PVP_TOURNAMENTS%% 
			 WHERE `status` IN ('registration','running');"
		);
		$stats['prize_pool_tourneys']        = empty($row) ? 0 : (int) $row['t'];
		$stats['prize_pool_tourneys_ntx20']  = empty($row) ? 0 : (int) $row['t_ntx'];
		$stats['prize_pool_tourneys_untx20'] = empty($row) ? 0 : (int) $row['t_untx'];
	} catch (Exception $e) {}

	// --- Arenas activas / en espera ---
	$arenas = array();
	try {
		$arenas = $db->select(
			"SELECT a.*, u.`username` AS creator_name,
			        (SELECT COUNT(*) FROM %%PVP_ARENA_PLAYERS%% ap WHERE ap.`arena_id` = a.`id`) AS player_count
			 FROM %%PVP_ARENAS%% a
			 LEFT JOIN %%USERS%% u ON u.`id` = a.`creator_id`
			 WHERE a.`status` IN ('waiting','active','extra_time')
			 ORDER BY a.`created_at` DESC
			 LIMIT 50;"
		);
		if (!is_array($arenas)) $arenas = array();

		foreach ($arenas as &$a) {
			$a['mode_label']     = strtoupper($a['mode']);
			$a['pool_fmt']       = number_format((int) $a['prize_pool']);
			$a['pool_ntx20_fmt'] = number_format((int) (isset($a['pool_ntx20'])  ? $a['pool_ntx20']  : 0));
			$a['pool_untx20_fmt']= number_format((int) (isset($a['pool_untx20']) ? $a['pool_untx20'] : 0));
			$a['fee_fmt']        = number_format((int) $a['entry_fee']);
			$a['created_fmt']    = date('d/m/Y H:i', (int) $a['created_at']);
			$a['status_label']   = array(
				'waiting'    => '⏳ Esperando',
				'active'     => '🔴 Activa',
				'extra_time' => '⚡ Extra',
			)[$a['status']] ?? $a['status'];
		}
		unset($a);
	} catch (Exception $e) {}

	// --- Torneo activo + torneos recientes ---
	$activeTournament = null;
	$recentTournaments = array();
	try {
		$activeTournament = PVPTournamentHelper::getActiveTournament();

		if (!empty($activeTournament)) {
			$activeTournament['pool_fmt']        = number_format((int) $activeTournament['prize_pool']);
			$activeTournament['pool_ntx20_fmt']  = number_format((int) (isset($activeTournament['pool_ntx20'])  ? $activeTournament['pool_ntx20']  : 0));
			$activeTournament['pool_untx20_fmt'] = number_format((int) (isset($activeTournament['pool_untx20']) ? $activeTournament['pool_untx20'] : 0));
			$activeTournament['entry_fee_fmt']   = number_format((int) $activeTournament['entry_fee']);
			$activeTournament['afee_fmt']        = number_format((int) $activeTournament['alliance_entry_fee']);
			$activeTournament['reg_ends_fmt']    = date('d/m/Y H:i', (int) $activeTournament['registration_ends_at']);

			// Jugadores inscritos del torneo activo
			$activeTournamentPlayers = PVPTournamentHelper::getRegisteredPlayers((int) $activeTournament['id']);
		} else {
			$activeTournamentPlayers = array();
		}

		$recentTournaments = $db->select(
			"SELECT * FROM %%PVP_TOURNAMENTS%% 
			 WHERE `status` IN ('finished','cancelled') 
			 ORDER BY `finished_at` DESC 
			 LIMIT 10;"
		);
		if (!is_array($recentTournaments)) $recentTournaments = array();

		foreach ($recentTournaments as &$t) {
			$t['pool_fmt']        = number_format((int) $t['prize_pool']);
			$t['pool_ntx20_fmt']  = number_format((int) (isset($t['pool_ntx20'])  ? $t['pool_ntx20']  : 0));
			$t['pool_untx20_fmt'] = number_format((int) (isset($t['pool_untx20']) ? $t['pool_untx20'] : 0));
			$t['entry_fee_fmt']   = number_format((int) $t['entry_fee']);
			$t['afee_fmt']        = number_format((int) $t['alliance_entry_fee']);
			$t['finished_fmt']    = !empty($t['finished_at']) ? date('d/m/Y H:i', (int) $t['finished_at']) : '—';
			$t['status_label']    = array(
				'finished'  => '✅ Finalizado',
				'cancelled' => '🛑 Cancelado',
			)[$t['status']] ?? $t['status'];
		}
		unset($t);
	} catch (Exception $e) {
		$activeTournamentPlayers = array();
	}

	// --- Historial de arenas finalizadas ---
	$historyArenas = array();
	try {
		$historyArenas = $db->select(
			"SELECT a.*, u.`username` AS creator_name
			 FROM %%PVP_ARENAS%% a
			 LEFT JOIN %%USERS%% u ON u.`id` = a.`creator_id`
			 WHERE a.`status` IN ('finished','cancelled')
			 ORDER BY a.`finished_at` DESC
			 LIMIT 15;"
		);
		if (!is_array($historyArenas)) $historyArenas = array();

		foreach ($historyArenas as &$a) {
			$a['mode_label']      = strtoupper($a['mode']);
			$a['pool_fmt']        = number_format((int) $a['prize_pool']);
			$a['pool_ntx20_fmt']  = number_format((int) (isset($a['pool_ntx20'])  ? $a['pool_ntx20']  : 0));
			$a['pool_untx20_fmt'] = number_format((int) (isset($a['pool_untx20']) ? $a['pool_untx20'] : 0));
			$a['fee_fmt']         = number_format((int) $a['entry_fee']);
			$a['finished_fmt']    = !empty($a['finished_at']) ? date('d/m/Y H:i', (int) $a['finished_at']) : '—';
			$a['status_label']    = array(
				'finished'  => '✅ Finalizada',
				'cancelled' => '🛑 Cancelada',
			)[$a['status']] ?? $a['status'];
		}
		unset($a);
	} catch (Exception $e) {}

	// ============================================
	// ASIGNAR VARIABLES Y MOSTRAR
	// ============================================
	$template->assign_vars(array(
		'config'                    => $config,
		'stats'                     => $stats,
		'arenas'                    => $arenas,
		'active_tournament'         => $activeTournament,
		'active_tournament_players' => isset($activeTournamentPlayers) ? $activeTournamentPlayers : array(),
		'recent_tournaments'        => $recentTournaments,
		'history_arenas'            => $historyArenas,
		'message'                   => $message,
		'msgType'                   => $msgType,
		'active_tab'                => $tab,
	));

	$template->show("pvpAdminPage.tpl");
}