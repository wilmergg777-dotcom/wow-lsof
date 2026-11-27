<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ============================================
 *  ASTROIO - Panel Admin de Mini Torneos
 *  Archivo: includes/pages/adm/ShowTourneyAdminPage.php
 *  Versión: 1.1 (Fixes de lógica de botones)
 * ============================================
 */

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) {
	throw new Exception("Permission error!");
}

function ShowTourneyAdmin()
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
	// PROCESAR ACCIONES
	// ============================================

	// ─── GUARDAR CONFIG (TOGGLE DEL MÓDULO) ───
	if ($action === 'saveConfig') {
		try {
			$enabled = (int) HTTP::_GP('tourney_enabled', 0);

			$config = Config::get();
			$moduls = explode(';', $config->moduls);

			$targetIndex = defined('MODULE_TOURNEY') ? MODULE_TOURNEY : 70;
			while (count($moduls) <= $targetIndex) {
				$moduls[] = 1;
			}
			$moduls[$targetIndex] = $enabled;

			$newModuls = implode(';', $moduls);
			$db->update(
				"UPDATE %%CONFIG%% SET `moduls` = :moduls WHERE `uni` = :uni;",
				array(':moduls' => $newModuls, ':uni' => Universe::getEmulated())
			);

			if (method_exists('Config', 'reloadConfig')) {
				Config::reloadConfig();
			}

			$message = $enabled
				? '✅ Mini Torneos <strong>ACTIVADOS</strong>.'
				: '⏸️ Mini Torneos <strong>DESACTIVADOS</strong>.';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'dashboard';
	}

	// ─── FORZAR ROTACIÓN ───
	if ($action === 'forceRotation') {
		try {
			require_once ROOT_PATH . 'includes/classes/cronjob/TournamentCronjob.class.php';

			if (class_exists('TournamentCronjob')) {
				$cronjob = new TournamentCronjob();
				// Llamamos a run() directamente. Como el tourneyEnd ya venció o lo forzamos, va a rotar.
				$cronjob->run();
				$message = '🔄 Rotación de Mini Torneos ejecutada manualmente. Revisá los torneos activos.';
				$msgType = 'success';
			} else {
				$message = '⚠️ TournamentCronjob no está instalado.';
				$msgType = 'error';
			}
		} catch (Throwable $e) {
			$message = '❌ Error al forzar rotación: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'actions';
	}

	// ─── LIMPIAR HISTORIAL ───
	if ($action === 'cleanHistory') {
		try {
			$days = (int) HTTP::_GP('days', 30);
			$days = max(1, min(365, $days));

			$db->delete(
				"DELETE FROM `" . $prefix . "tourney_logs` WHERE `joinTime` < :cutoff;",
				array(':cutoff' => TIMESTAMP - ($days * 86400))
			);

			$message = '🧹 Historial limpiado (registros con más de ' . $days . ' días).';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al limpiar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'actions';
	}

	// ─── RESETEAR CICLO ACTUAL ───
	if ($action === 'resetCycle') {
		try {
			// 1. Limpiamos las tablas
			$db->delete("DELETE FROM `" . $prefix . "tourney_participante`;");
			$db->delete("DELETE FROM `" . $prefix . "tourney`;");

			// 2. Forzamos el tourneyEnd a 0
			$db->update(
				"UPDATE %%CONFIG%% SET `tourneyEnd` = 0 WHERE `uni` = :uni;",
				array(':uni' => Universe::getEmulated())
			);

			// 3. Recargamos la config para que el cronjob se de cuenta
			if (method_exists('Config', 'reloadConfig')) {
				Config::reloadConfig();
			}

			// 4. Ejecutamos el Cronjob inmediatamente para que sortee los nuevos
			require_once ROOT_PATH . 'includes/classes/cronjob/TournamentCronjob.class.php';
			if (class_exists('TournamentCronjob')) {
				$cronjob = new TournamentCronjob();
				$cronjob->run();
			}

			$message = '🔄 Ciclo reseteado y Torneos sorteados con éxito.';
			$msgType = 'success';
		} catch (Throwable $e) {
			$message = '❌ Error al resetear: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'actions';
	}

	// ============================================
	// CARGAR DATOS PARA LA VISTA
	// ============================================

	$config = Config::get();
	$tourneyEnd = isset($config->tourneyEnd) ? (int) $config->tourneyEnd : 0;
	$now = TIMESTAMP;
	$remaining = max(0, $tourneyEnd - $now);

	$moduleEnabled = 0;
	if (function_exists('isModuleAvailable') && defined('MODULE_TOURNEY')) {
		$moduleEnabled = isModuleAvailable(MODULE_TOURNEY) ? 1 : 0;
	}

	$cycleInfo = array(
		'tourney_end'         => $tourneyEnd,
		'tourney_end_fmt'     => $tourneyEnd > 0 ? date('d/m/Y H:i', $tourneyEnd) : '—',
		'remaining_seconds'   => $remaining,
		'remaining_fmt'       => $remaining > 0 ? pretty_time($remaining) : '—',
		'is_active'           => $tourneyEnd > $now ? 1 : 0,
		'module_enabled'      => $moduleEnabled,
	);

	$tourneys = array();
	try {
		$tourneys = $db->select(
			"SELECT * FROM `" . $prefix . "tourney` ORDER BY `tourneyId` ASC;"
		);
		if (!is_array($tourneys)) $tourneys = array();

		$eventNames = array(
			1  => '💎 Más Materia Oscura',
			2  => '🕳️ Agujero Negro',
			3  => '💥 Destrucción de Unidades',
			4  => '⚔️ Batallas Ganadas',
			5  => '🚀 Expediciones Exitosas',
			6  => '🛸 Naves Encontradas',
			7  => '🌌 DM > 700',
			8  => '👽 Aliens / Piratas',
			9  => '🌑 Destrucción de Lunas',
			10 => '🌕 Creación de Lunas',
		);

		foreach ($tourneys as &$t) {
			$t['event_label'] = isset($eventNames[(int)$t['tourneyEvent']])
				? $eventNames[(int)$t['tourneyEvent']]
				: 'Torneo #' . (int)$t['tourneyEvent'];

			$t['top3'] = $db->select(
				"SELECT p.*, u.username
				 FROM `" . $prefix . "tourney_participante` p
				 LEFT JOIN `" . $prefix . "users` u ON u.id = p.playerId
				 WHERE p.tourneyJoin = :tid
				 ORDER BY p.tourneyUnits DESC
				 LIMIT 3;",
				array(':tid' => (int)$t['tourneyId'])
			);
			if (!is_array($t['top3'])) $t['top3'] = array();

			foreach ($t['top3'] as &$p) {
				$p['units_fmt'] = number_format((float)$p['tourneyUnits']);
				if (empty($p['username'])) $p['username'] = 'ID #' . (int)$p['playerId'];
			}
			unset($p);

			$t['priceOne_fmt']   = number_format((int)$t['priceOne']);
			$t['priceTwo_fmt']   = number_format((int)$t['priceTwo']);
			$t['priceThree_fmt'] = number_format((int)$t['priceThree']);
		}
		unset($t);
	} catch (Throwable $e) {
		$tourneys = array();
	}

	$history = array();
	try {
		$history = $db->select(
			"SELECT l.*, u.username, t.tourneyName, t.tourneyEvent
			 FROM `" . $prefix . "tourney_logs` l
			 LEFT JOIN `" . $prefix . "users` u ON u.id = l.playerId
			 LEFT JOIN `" . $prefix . "tourney` t ON t.tourneyId = l.tourneyJoin
			 ORDER BY l.logId DESC
			 LIMIT 30;"
		);
		if (!is_array($history)) $history = array();

		foreach ($history as &$h) {
			$h['units_fmt'] = number_format((float)$h['tourneyUnits']);
			$h['join_fmt']  = date('d/m/Y H:i', (int)$h['joinTime']);
			if (empty($h['username'])) $h['username'] = 'ID #' . (int)$h['playerId'];
			if (empty($h['tourneyName'])) $h['tourneyName'] = 'Torneo #' . (int)$h['tourneyJoin'];
		}
		unset($h);
	} catch (Throwable $e) {
		$history = array();
	}

	$stats = array(
		'total_tourneys'  => 0,
		'total_players'   => 0,
		'total_history'   => 0,
	);

	try {
		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM `" . $prefix . "tourney`;");
		$stats['total_tourneys'] = !empty($row) ? (int)$row['c'] : 0;

		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM `" . $prefix . "tourney_participante`;");
		$stats['total_players'] = !empty($row) ? (int)$row['c'] : 0;

		$row = $db->selectSingle("SELECT COUNT(*) AS c FROM `" . $prefix . "tourney_logs`;");
		$stats['total_history'] = !empty($row) ? (int)$row['c'] : 0;
	} catch (Throwable $e) {}

	// ============================================
	// ASIGNAR VARIABLES Y MOSTRAR
	// ============================================
	$template->assign_vars(array(
		'cycle_info'      => $cycleInfo,
		'tourneys'        => $tourneys,
		'history'         => $history,
		'stats'           => $stats,
		'message'         => $message,
		'msgType'         => $msgType,
		'active_tab'      => $tab,
	));

	$template->show("tourneyAdminPage.tpl");
}