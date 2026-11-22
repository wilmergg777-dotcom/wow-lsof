<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ============================================
 *  ASTROIO - Panel Admin del Sistema PvE
 *  Archivo: includes/pages/adm/ShowPveAdminPage.php
 *  Versión: 4.3 — Doble Riel (NTX-20 / UNTX-20) en stats + refunds
 * ============================================
 *
 * v4.1:
 *  - FIX BUG: eliminados los fallbacks que cargaban el "último evento"
 *    (incluyendo cancelados/finalizados) cuando getActiveEvent() devolvía null.
 *    Ahora $bossEvent / $bastionEvent quedan a null si no hay evento activo,
 *    y el template cae en {else} mostrando "📭 No hay ningún torneo actualmente".
 *
 * v4.2:
 *  - FIX CONTADORES: "Fantasmas Totales", "Eliminados", "Bastiones Totales" y "Caídos"
 *    ahora SOLO cuentan fantasmas/bastiones pertenecientes a eventos VIVOS
 *    (status IN 'scheduled','registration','active'). Cuando un evento se cancela
 *    o finaliza, sus fantasmas dejan de contarse → contador = 0 si no hay evento vivo.
 *
 * v4.3 — DOBLE RIEL (NTX-20 / UNTX-20):
 *  - $bossStats añade 'total_pool_ntx20' y 'total_pool_untx20'
 *    (suma de columnas reales, no la legacy total_pool_ntx).
 *  - $bastionStats añade 'total_pool_ntx20' y 'total_pool_untx20'.
 *  - Se mantiene 'total_pool_ntx' como "suma base equivalente" para
 *    retrocompatibilidad con templates viejos (aggregaciones legacy).
 *  - Mensajes de cancelBossEvent / cancelBastionEvent ahora dicen
 *    "reembolsados a X líderes en su riel" (riel-neutro) en lugar de
 *    "X NTX" (confuso porque el contador es de líderes, no de NTX).
 *  - Los $bossEvent / $bastionEvent ya traen pool_ntx20 y pool_untx20
 *    porque getActiveEvent() hace SELECT * (no hay cambio de query).
 *  - Los configs default_*_ntx siguen siendo BASE NTX-20 (el template
 *    se encarga de mostrar el equivalente ×2 UNTX para QVAPAY).
 *  - 100% retrocompatible: agrega claves sin romper las existentes.
 */

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) {
	throw new Exception("Permission error!");
}

function ShowPveAdmin()
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
	require_once ROOT_PATH.'includes/classes/PVEHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVECrisisHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVEEmpireHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVEGhostHelper.class.php';
	require_once ROOT_PATH.'includes/classes/PVEEmpireTemplateHelper.class.php';

	// v3.4 — Torneo del Devorador (carga defensiva: puede no existir aún)
	$bossHelperFile = ROOT_PATH.'includes/classes/PVEBossTournamentHelper.class.php';
	if (file_exists($bossHelperFile)) {
		require_once $bossHelperFile;
	}

	// v4.0 — Bastión Asediado (carga defensiva)
	$bastionHelperFile = ROOT_PATH.'includes/classes/PVEBastionHelper.class.php';
	if (file_exists($bastionHelperFile)) {
		require_once $bastionHelperFile;
	}

	$bastionWaveFile = ROOT_PATH.'includes/classes/PVEBastionWaveHelper.class.php';
	if (file_exists($bastionWaveFile)) {
		require_once $bastionWaveFile;
	}

	// ============================================
	// PROCESAR ACCIONES
	// ============================================

	// ─── ACTIVAR CRISIS AHORA (manual) ───
	if ($action === 'activateCrisis') {
		try {
			$waves = (int) HTTP::_GP('waves', 5);
			$waves = max(1, min(10, $waves));

			$crisisId = PVECrisisHelper::scheduleCrisis(TIMESTAMP, $waves);

			$message = '✅ Crisis #' . $crisisId . ' creada con ' . $waves . ' oleadas. Se activará en el próximo ciclo del cron (máx 5 min).';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'crisis';
	}

	// ─── PROGRAMAR CRISIS (fecha futura) ───
	if ($action === 'scheduleCrisis') {
		try {
			$day    = (int) HTTP::_GP('day', 25);
			$hour   = (int) HTTP::_GP('hour', 10);
			$minute = (int) HTTP::_GP('minute', 30);
			$waves  = (int) HTTP::_GP('waves', 5);

			$day    = max(1, min(28, $day));
			$hour   = max(0, min(23, $hour));
			$minute = max(0, min(59, $minute));
			$waves  = max(1, min(10, $waves));

			$startTime = mktime($hour, $minute, 0, (int)date('n'), $day, (int)date('Y'));
			if ($startTime <= TIMESTAMP) {
				$startTime = mktime($hour, $minute, 0, (int)date('n') + 1, $day, (int)date('Y'));
			}

			$crisisId = PVECrisisHelper::scheduleCrisis($startTime, $waves);

			$message = '📅 Crisis #' . $crisisId . ' programada para ' . date('d/m/Y H:i', $startTime) . ' (' . $waves . ' oleadas).';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'crisis';
	}

	// ─── CANCELAR CRISIS PROGRAMADA ───
	if ($action === 'cancelCrisis') {
		$crisisId = (int) HTTP::_GP('id', 0);
		if ($crisisId > 0) {
			$db->update(
				"UPDATE %%PVE_CRISIS%% SET status = 'finished' WHERE id = :id AND status IN ('scheduled','active');",
				array(':id' => $crisisId)
			);
			$message = '🛑 Crisis #' . $crisisId . ' cancelada.';
			$msgType = 'success';
		}
		$tab = 'crisis';
	}

	// ─── CREAR IMPERIOS (con plantilla) ───
	if ($action === 'spawnEmpires') {
		try {
			$count      = (int) HTTP::_GP('count', 1);
			$duration   = (int) HTTP::_GP('duration', 24);
			$templateId = (int) HTTP::_GP('template_id', 0);

			$count    = max(1, min(10, $count));
			$duration = max(1, min(168, $duration));

			$created = PVEEmpireHelper::spawnEmpires($count, $duration, $templateId);

			if ($created > 0) {
				$templateName = 'default';
				if ($templateId > 0) {
					$tpl = PVEEmpireTemplateHelper::getTemplate($templateId);
					if ($tpl) $templateName = $tpl['name'];
				}
				$message = '🏛️ ' . $created . ' imperio(s) creado(s) con plantilla "' . $templateName . '" y duración de ' . $duration . 'h.';
				$msgType = 'success';
			} else {
				$message = '⚠️ No se pudo crear ningún imperio (no hay coordenadas libres).';
				$msgType = 'error';
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'empires';
	}

	// ─── MARCAR IMPERIO COMO DESTRUIDO ───
	if ($action === 'destroyEmpire') {
		$empireId = (int) HTTP::_GP('id', 0);
		if ($empireId > 0) {
			// Destruir fantasma también
			try {
				PVEGhostHelper::destroyGhost($empireId, 'empire');
			} catch (Throwable $e) {}

			$db->update(
				"UPDATE %%PVE_EMPIRES%% SET status = 'destroyed', destroyed_at = :now, current_hp = 0 WHERE id = :id;",
				array(':now' => TIMESTAMP, ':id' => $empireId)
			);
			$message = '💥 Imperio #' . $empireId . ' marcado como destruido y fantasma eliminado.';
			$msgType = 'success';
		}
		$tab = 'empires';
	}

	// ─── LIMPIAR AHORA (limpieza forzada — Crisis/Imperio) ───
	if ($action === 'runCleanup') {
		try {
			$cleanupResults = array(
				'orphans' => array(),
				'deep'    => array(),
			);

			// Capa 2 — Limpieza de huérfanos
			if (method_exists('PVECrisisHelper', 'cleanupOrphans')) {
				$cleanupResults['orphans'] = PVECrisisHelper::cleanupOrphans();
			}

			// Capa 3 — Limpieza profunda (forzada)
			if (method_exists('PVECrisisHelper', 'cleanupDeep')) {
				$cleanupResults['deep'] = PVECrisisHelper::cleanupDeep(true);
			}

			// Calcular totales
			$totalOrphans = array_sum($cleanupResults['orphans']);
			$totalDeep    = array_sum($cleanupResults['deep']);
			$totalAll     = $totalOrphans + $totalDeep;

			// Construir mensaje detallado
			if ($totalAll > 0) {
				$detalles = array();

				// Orphans
				if (!empty($cleanupResults['orphans']['fleets_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['fleets_deleted'] . ' flotas huérfanas';
				}
				if (!empty($cleanupResults['orphans']['events_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['events_deleted'] . ' fleet_events';
				}
				if (!empty($cleanupResults['orphans']['waves_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['waves_deleted'] . ' waves huérfanas';
				}
				if (!empty($cleanupResults['orphans']['crisis_closed'])) {
					$detalles[] = $cleanupResults['orphans']['crisis_closed'] . ' crisis zombie';
				}
				if (!empty($cleanupResults['orphans']['empires_expired'])) {
					$detalles[] = $cleanupResults['orphans']['empires_expired'] . ' imperios expirados';
				}
				if (!empty($cleanupResults['orphans']['empire_attacks_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['empire_attacks_deleted'] . ' ataques huérfanos';
				}
				if (!empty($cleanupResults['orphans']['acs_invites_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['acs_invites_deleted'] . ' invitaciones ACS';
				}

				// Deep
				if (!empty($cleanupResults['deep']['logs_deleted'])) {
					$detalles[] = $cleanupResults['deep']['logs_deleted'] . ' logs viejos';
				}
				if (!empty($cleanupResults['deep']['crisis_deleted'])) {
					$detalles[] = $cleanupResults['deep']['crisis_deleted'] . ' crisis viejas';
				}
				if (!empty($cleanupResults['deep']['rewards_expired'])) {
					$detalles[] = $cleanupResults['deep']['rewards_expired'] . ' rewards expiradas';
				}
				if (!empty($cleanupResults['deep']['empires_deleted'])) {
					$detalles[] = $cleanupResults['deep']['empires_deleted'] . ' imperios viejos';
				}
				if (!empty($cleanupResults['deep']['empire_attacks_deleted'])) {
					$detalles[] = $cleanupResults['deep']['empire_attacks_deleted'] . ' ataques viejos';
				}
				if (!empty($cleanupResults['deep']['acs_invites_deleted'])) {
					$detalles[] = $cleanupResults['deep']['acs_invites_deleted'] . ' invitaciones viejas';
				}

				$message = '🧹 Limpieza completada: <strong>' . $totalAll . '</strong> registro(s) borrado(s)<br>';
				if (!empty($detalles)) {
					$message .= '<small>' . implode(' · ', $detalles) . '</small>';
				}
			} else {
				$message = '🧹 Limpieza ejecutada. No había nada que borrar (todo limpio).';
			}

			$msgType = 'success';

		} catch (Exception $e) {
			$message = '❌ Error en la limpieza: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'dashboard';
	}

	// ═══════════════════════════════════════════
	// 🆕 v3.7 — LIMPIAR TORNEO DEL DEVORADOR
	// ═══════════════════════════════════════════
	if ($action === 'runBossCleanup') {
		try {
			$cleanupResults = array(
				'orphans' => array(),
				'deep'    => array(),
			);

			// Capa 2 — Limpieza de huérfanos del Torneo
			if (class_exists('PVEBossTournamentHelper')
				&& method_exists('PVEBossTournamentHelper', 'cleanupOrphansBoss')) {
				$cleanupResults['orphans'] = PVEBossTournamentHelper::cleanupOrphansBoss();
			}

			// Capa 3 — Limpieza profunda (forzada)
			if (class_exists('PVEBossTournamentHelper')
				&& method_exists('PVEBossTournamentHelper', 'cleanupDeepBoss')) {
				$cleanupResults['deep'] = PVEBossTournamentHelper::cleanupDeepBoss(true);
			}

			// Calcular totales
			$totalOrphans = array_sum($cleanupResults['orphans']);
			$totalDeep    = array_sum($cleanupResults['deep']);
			$totalAll     = $totalOrphans + $totalDeep;

			// Construir mensaje detallado
			if ($totalAll > 0) {
				$detalles = array();

				// Orphans (Capa 2)
				if (!empty($cleanupResults['orphans']['ghosts_destroyed'])) {
					$detalles[] = $cleanupResults['orphans']['ghosts_destroyed'] . ' fantasmas destruidos';
				}
				if (!empty($cleanupResults['orphans']['registrations_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['registrations_deleted'] . ' registros huérfanos';
				}
				if (!empty($cleanupResults['orphans']['damage_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['damage_deleted'] . ' daños huérfanos';
				}
				if (!empty($cleanupResults['orphans']['events_finished'])) {
					$detalles[] = $cleanupResults['orphans']['events_finished'] . ' eventos zombie';
				}
				if (!empty($cleanupResults['orphans']['fleets_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['fleets_deleted'] . ' flotas atascadas';
				}

				// Deep (Capa 3)
				if (!empty($cleanupResults['deep']['ghosts_deleted'])) {
					$detalles[] = $cleanupResults['deep']['ghosts_deleted'] . ' fantasmas viejos';
				}
				if (!empty($cleanupResults['deep']['damage_deleted'])) {
					$detalles[] = $cleanupResults['deep']['damage_deleted'] . ' daños viejos';
				}
				if (!empty($cleanupResults['deep']['registrations_deleted'])) {
					$detalles[] = $cleanupResults['deep']['registrations_deleted'] . ' registros viejos';
				}
				if (!empty($cleanupResults['deep']['events_deleted'])) {
					$detalles[] = $cleanupResults['deep']['events_deleted'] . ' eventos viejos';
				}

				$message = '🧹 Limpieza del Torneo completada: <strong>' . $totalAll . '</strong> registro(s) borrado(s)<br>';
				if (!empty($detalles)) {
					$message .= '<small>' . implode(' · ', $detalles) . '</small>';
				}
			} else {
				$message = '🧹 Limpieza del Torneo ejecutada. No había nada que borrar (todo limpio).';
			}

			$msgType = 'success';

		} catch (Exception $e) {
			$message = '❌ Error en la limpieza del Torneo: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ═══════════════════════════════════════════
	// 🆕 v4.0 — LIMPIAR BASTIÓN ASEDIADO
	// ═══════════════════════════════════════════
	if ($action === 'runBastionCleanup') {
		try {
			$cleanupResults = array(
				'orphans' => array(),
				'deep'    => array(),
			);

			// Capa 2 — Limpieza de huérfanos del Bastión
			if (class_exists('PVEBastionHelper')
				&& method_exists('PVEBastionHelper', 'cleanupOrphansBastion')) {
				$cleanupResults['orphans'] = PVEBastionHelper::cleanupOrphansBastion();
			}

			// Capa 3 — Limpieza profunda (forzada)
			if (class_exists('PVEBastionHelper')
				&& method_exists('PVEBastionHelper', 'cleanupDeepBastion')) {
				$cleanupResults['deep'] = PVEBastionHelper::cleanupDeepBastion(true);
			}

			// Calcular totales
			$totalOrphans = array_sum($cleanupResults['orphans']);
			$totalDeep    = array_sum($cleanupResults['deep']);
			$totalAll     = $totalOrphans + $totalDeep;

			// Construir mensaje detallado
			if ($totalAll > 0) {
				$detalles = array();

				// Orphans (Capa 2)
				if (!empty($cleanupResults['orphans']['ghosts_destroyed'])) {
					$detalles[] = $cleanupResults['orphans']['ghosts_destroyed'] . ' bastiones destruidos';
				}
				if (!empty($cleanupResults['orphans']['registrations_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['registrations_deleted'] . ' registros huérfanos';
				}
				if (!empty($cleanupResults['orphans']['damage_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['damage_deleted'] . ' contribuciones huérfanas';
				}
				if (!empty($cleanupResults['orphans']['waves_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['waves_deleted'] . ' waves huérfanas';
				}
				if (!empty($cleanupResults['orphans']['events_finished'])) {
					$detalles[] = $cleanupResults['orphans']['events_finished'] . ' eventos zombie';
				}
				if (!empty($cleanupResults['orphans']['fleets_deleted'])) {
					$detalles[] = $cleanupResults['orphans']['fleets_deleted'] . ' flotas atascadas';
				}

				// Deep (Capa 3)
				if (!empty($cleanupResults['deep']['ghosts_deleted'])) {
					$detalles[] = $cleanupResults['deep']['ghosts_deleted'] . ' bastiones viejos';
				}
				if (!empty($cleanupResults['deep']['damage_deleted'])) {
					$detalles[] = $cleanupResults['deep']['damage_deleted'] . ' contribuciones viejas';
				}
				if (!empty($cleanupResults['deep']['waves_deleted'])) {
					$detalles[] = $cleanupResults['deep']['waves_deleted'] . ' waves viejas';
				}
				if (!empty($cleanupResults['deep']['registrations_deleted'])) {
					$detalles[] = $cleanupResults['deep']['registrations_deleted'] . ' registros viejos';
				}
				if (!empty($cleanupResults['deep']['events_deleted'])) {
					$detalles[] = $cleanupResults['deep']['events_deleted'] . ' eventos viejos';
				}

				$message = '🧹 Limpieza del Bastión completada: <strong>' . $totalAll . '</strong> registro(s) borrado(s)<br>';
				if (!empty($detalles)) {
					$message .= '<small>' . implode(' · ', $detalles) . '</small>';
				}
			} else {
				$message = '🧹 Limpieza del Bastión ejecutada. No había nada que borrar (todo limpio).';
			}

			$msgType = 'success';

		} catch (Exception $e) {
			$message = '❌ Error en la limpieza del Bastión: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'bastion';
	}

	// ─── GUARDAR CONFIGURACIÓN GLOBAL (Dashboard) ───
	// ⚠️ v3.2 — NO toca crisis_reward_ntx ni empire_reward_ntx
	// (esas se gestionan SOLO desde la pestaña Recompensas)
	if ($action === 'saveConfig') {
		try {
			$configs = array(
				'pve_enabled'                  => (int) HTTP::_GP('pve_enabled', 0),
				'pve_crisis_enabled'           => (int) HTTP::_GP('pve_crisis_enabled', 0),
				'pve_empire_enabled'           => (int) HTTP::_GP('pve_empire_enabled', 0),
				'crisis_day'                   => (int) HTTP::_GP('crisis_day', 25),
				'crisis_hour'                  => (int) HTTP::_GP('crisis_hour', 10),
				'crisis_minute'                => (int) HTTP::_GP('crisis_minute', 30),
				'crisis_duration_hours'        => (int) HTTP::_GP('crisis_duration_hours', 24),
				'crisis_waves'                 => (int) HTTP::_GP('crisis_waves', 5),
				'crisis_wave_interval_minutes' => (int) HTTP::_GP('crisis_wave_interval_minutes', 60),
				'empire_duration_hours'        => (int) HTTP::_GP('empire_duration_hours', 24),
				'empire_count'                 => (int) HTTP::_GP('empire_count', 1),
				'empire_attacks_per_user'      => (int) HTTP::_GP('empire_attacks_per_user', 5),
				'empire_counterattack_pct'     => (int) HTTP::_GP('empire_counterattack_pct', 30),
			);

			foreach ($configs as $key => $value) {
				$existing = $db->selectSingle(
					"SELECT id FROM %%PVE_CONFIG%% WHERE config_key = :key LIMIT 1;",
					array(':key' => $key)
				);

				if (!empty($existing)) {
					$db->update(
						"UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = :key;",
						array(':val' => (string)$value, ':now' => TIMESTAMP, ':key' => $key)
					);
				} else {
					$db->insert(
						"INSERT INTO %%PVE_CONFIG%% (config_key, config_value, updated_at) VALUES (:key, :val, :now);",
						array(':key' => $key, ':val' => (string)$value, ':now' => TIMESTAMP)
					);
				}
			}

			PVEHelper::clearConfigCache();
			$message = '💾 Configuración guardada correctamente.';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'dashboard';
	}

	// ─── GUARDAR CONFIGURACIÓN DE RECOMPENSAS ───
	if ($action === 'saveRewards') {
		try {
			// ─── Crisis: tipo de recompensa ───
			$crisisType = strtolower(trim((string) HTTP::_GP('crisis_reward_type', 'ntx')));
			if ($crisisType !== 'resources') {
				$crisisType = 'ntx';
			}

			$crisisSplit = strtolower(trim((string) HTTP::_GP('crisis_reward_split', 'per_player')));
			if ($crisisSplit !== 'shared') {
				$crisisSplit = 'per_player';
			}

			// ─── Recursos de crisis (solo se aplican si type=resources) ───
			$crisisMetal     = max(0, (int) HTTP::_GP('crisis_reward_metal', 0));
			$crisisCrystal   = max(0, (int) HTTP::_GP('crisis_reward_crystal', 0));
			$crisisDeuterium = max(0, (int) HTTP::_GP('crisis_reward_deuterium', 0));

			// ─── NTX de crisis ───
			$crisisNtx = max(0, (int) HTTP::_GP('crisis_reward_ntx', 5));

			// ─── Imperio: % de botín ───
			$empireLootPct = (int) HTTP::_GP('empire_loot_pct', 100);
			if ($empireLootPct < 0)   $empireLootPct = 0;
			if ($empireLootPct > 100) $empireLootPct = 100;

			$configs = array(
				'crisis_reward_type'      => $crisisType,
				'crisis_reward_ntx'       => (int) $crisisNtx,
				'crisis_reward_metal'     => (int) $crisisMetal,
				'crisis_reward_crystal'   => (int) $crisisCrystal,
				'crisis_reward_deuterium' => (int) $crisisDeuterium,
				'crisis_reward_split'     => $crisisSplit,
				'empire_loot_pct'         => (int) $empireLootPct,
			);

			foreach ($configs as $key => $value) {
				$existing = $db->selectSingle(
					"SELECT id FROM %%PVE_CONFIG%% WHERE config_key = :key LIMIT 1;",
					array(':key' => $key)
				);

				if (!empty($existing)) {
					$db->update(
						"UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = :key;",
						array(':val' => (string)$value, ':now' => TIMESTAMP, ':key' => $key)
					);
				} else {
					$db->insert(
						"INSERT INTO %%PVE_CONFIG%% (config_key, config_value, updated_at) VALUES (:key, :val, :now);",
						array(':key' => $key, ':val' => (string)$value, ':now' => TIMESTAMP)
					);
				}
			}

			PVEHelper::clearConfigCache();
			$message = '🎁 Recompensas guardadas correctamente.';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar recompensas: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'rewards';
	}

	// ═══════════════════════════════════════════
	// ACCIONES DE PLANTILLAS (v3.0)
	// ═══════════════════════════════════════════

	// ─── GUARDAR PLANTILLA (crear o editar) ───
	if ($action === 'saveTemplate') {
		try {
			$templateId = (int) HTTP::_GP('template_id', 0);

			// 🔧 FIX: HTTP::_GP no maneja arrays → usar $_POST directo
			$shipIds     = isset($_POST['ship_id'])     && is_array($_POST['ship_id'])     ? $_POST['ship_id']     : array();
			$shipCounts  = isset($_POST['ship_count'])  && is_array($_POST['ship_count'])  ? $_POST['ship_count']  : array();
			$defIds      = isset($_POST['def_id'])      && is_array($_POST['def_id'])      ? $_POST['def_id']      : array();
			$defCounts   = isset($_POST['def_count'])   && is_array($_POST['def_count'])   ? $_POST['def_count']   : array();
			$buildIds    = isset($_POST['build_id'])    && is_array($_POST['build_id'])    ? $_POST['build_id']    : array();
			$buildLevels = isset($_POST['build_level']) && is_array($_POST['build_level']) ? $_POST['build_level'] : array();

			// Recolectar naves (solamente las que tienen cantidad > 0)
			$ships = array();
			foreach ($shipIds as $i => $shipId) {
				$shipId = (int) $shipId;
				$count  = (int) ($shipCounts[$i] ?? 0);
				if ($shipId > 0 && $count > 0) {
					$ships[$shipId] = $count;
				}
			}

			// Recolectar defensas
			$defenses = array();
			foreach ($defIds as $i => $defId) {
				$defId = (int) $defId;
				$count = (int) ($defCounts[$i] ?? 0);
				if ($defId > 0 && $count > 0) {
					$defenses[$defId] = $count;
				}
			}

			// Recolectar edificios
			$buildings = array();
			foreach ($buildIds as $i => $buildId) {
				$buildId = (int) $buildId;
				$level   = (int) ($buildLevels[$i] ?? 0);
				if ($buildId > 0 && $level > 0) {
					$buildings[$buildId] = $level;
				}
			}

			$data = array(
				'name'              => HTTP::_GP('name', ''),
				'slug'              => HTTP::_GP('slug', ''),
				'description'       => HTTP::_GP('description', '', true),
				'hp_mult'           => (float) HTTP::_GP('hp_mult', 5.0),
				'res_metal'         => (int) HTTP::_GP('res_metal', 0),
				'res_crystal'       => (int) HTTP::_GP('res_crystal', 0),
				'res_deuterium'     => (int) HTTP::_GP('res_deuterium', 0),
				'ships'             => $ships,
				'defenses'          => $defenses,
				'buildings'         => $buildings,
				'travel_mode'       => HTTP::_GP('travel_mode', 'random'),
				'travel_min'        => (int) HTTP::_GP('travel_min', 30),
				'travel_max'        => (int) HTTP::_GP('travel_max', 120),
				'travel_fixed'      => (int) HTTP::_GP('travel_fixed', 60),
				'scheduled_day'     => (int) HTTP::_GP('scheduled_day', 0),
				'scheduled_hour'    => (int) HTTP::_GP('scheduled_hour', 0),
				'scheduled_minute'  => (int) HTTP::_GP('scheduled_minute', 0),
				'fleet_speed_pct'   => (int) HTTP::_GP('fleet_speed_pct', 100),
				'waves_enabled'     => (int) HTTP::_GP('waves_enabled', 0),
				'waves_count'       => (int) HTTP::_GP('waves_count', 1),
				'waves_delay_min'   => (int) HTTP::_GP('waves_delay_min', 10),
				'regen_enabled'     => (int) HTTP::_GP('regen_enabled', 0),
				'regen_interval_min'=> (int) HTTP::_GP('regen_interval_min', 15),
				'regen_pct'         => (float) HTTP::_GP('regen_pct', 10.0),
				'is_default'        => (int) HTTP::_GP('is_default', 0),
				'is_active'         => (int) HTTP::_GP('is_active', 1),
			);

			if ($templateId > 0) {
				// Actualizar
				$ok = PVEEmpireTemplateHelper::updateTemplate($templateId, $data);
				if ($ok) {
					$message = '💾 Plantilla #' . $templateId . ' actualizada.';
					$msgType = 'success';
				} else {
					$message = '❌ Error al actualizar la plantilla.';
					$msgType = 'error';
				}
			} else {
				// Crear
				$newId = PVEEmpireTemplateHelper::createTemplate($data);
				if ($newId > 0) {
					$message = '✅ Plantilla #' . $newId . ' creada.';
					$msgType = 'success';
				} else {
					$message = '❌ Error al crear la plantilla.';
					$msgType = 'error';
				}
			}
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'templates';
	}

	// ─── ELIMINAR PLANTILLA ───
	if ($action === 'deleteTemplate') {
		$templateId = (int) HTTP::_GP('id', 0);
		if ($templateId > 0) {
			$ok = PVEEmpireTemplateHelper::deleteTemplate($templateId);
			if ($ok) {
				$message = '🗑️ Plantilla #' . $templateId . ' eliminada.';
				$msgType = 'success';
			} else {
				$message = '⚠️ No se puede eliminar la plantilla default. Marca otra como default primero.';
				$msgType = 'error';
			}
		}
		$tab = 'templates';
	}

	// ─── DUPLICAR PLANTILLA ───
	if ($action === 'duplicateTemplate') {
		$templateId = (int) HTTP::_GP('id', 0);
		if ($templateId > 0) {
			$newId = PVEEmpireTemplateHelper::duplicateTemplate($templateId);
			if ($newId > 0) {
				$message = '📋 Plantilla duplicada como #' . $newId . '.';
				$msgType = 'success';
			} else {
				$message = '❌ Error al duplicar.';
				$msgType = 'error';
			}
		}
		$tab = 'templates';
	}

	// ─── MARCAR COMO DEFAULT ───
	if ($action === 'setDefaultTemplate') {
		$templateId = (int) HTTP::_GP('id', 0);
		if ($templateId > 0) {
			$ok = PVEEmpireTemplateHelper::setDefaultTemplate($templateId);
			if ($ok) {
				$message = '⭐ Plantilla #' . $templateId . ' marcada como default.';
				$msgType = 'success';
			} else {
				$message = '❌ Error al marcar como default.';
				$msgType = 'error';
			}
		}
		$tab = 'templates';
	}

	// ─── TOGGLE ACTIVA/INACTIVA ───
	if ($action === 'toggleTemplate') {
		$templateId = (int) HTTP::_GP('id', 0);
		$active     = (int) HTTP::_GP('active', 0);
		if ($templateId > 0) {
			PVEEmpireTemplateHelper::toggleActive($templateId, $active === 1);
			$message = ($active === 1) ? '✅ Plantilla activada.' : '⏸️ Plantilla desactivada.';
			$msgType = 'success';
		}
		$tab = 'templates';
	}

	// ═══════════════════════════════════════════
	// v3.4 — ACCIONES DEL TORNEO DEL DEVORADOR
	// ═══════════════════════════════════════════

	// ─── CREAR TORNEO ───
	if ($action === 'createBossEvent') {
		if (!class_exists('PVEBossTournamentHelper')) {
			$message = '❌ El módulo del Torneo no está instalado.';
			$msgType = 'error';
			$tab = 'boss';
		} else {
			try {
				$params = array(
					'boss_name'              => HTTP::_GP('boss_name', 'El Devorador Estelar'),
					'entry_mode'             => HTTP::_GP('entry_mode', 'free'),
					'entry_cost_ntx'         => (int) HTTP::_GP('entry_cost_ntx', 50),
					'prize_type'             => HTTP::_GP('prize_type', 'ntx'),
					'prize_metal'            => (int) HTTP::_GP('prize_metal', 0),
					'prize_crystal'          => (int) HTTP::_GP('prize_crystal', 0),
					'prize_deuterium'        => (int) HTTP::_GP('prize_deuterium', 0),
					'prize_dark_matter'      => (int) HTTP::_GP('prize_dark_matter', 0),
					'prize_ntx'              => (int) HTTP::_GP('prize_ntx', 500),
					'prize_scales_with_allies' => (int) HTTP::_GP('prize_scales_with_allies', 0),
					'project_fee_pct'        => (int) HTTP::_GP('project_fee_pct', 5),
					'winner_distribution'    => HTTP::_GP('winner_distribution', 'by_contribution'),
					'min_alliances'          => (int) HTTP::_GP('min_alliances', 2),
					'max_alliances'          => (int) HTTP::_GP('max_alliances', 20),
					'hp_per_member'          => (int) HTTP::_GP('hp_per_member', 500000),
					'hp_min'                 => (int) HTTP::_GP('hp_min', 10000000),
					'duration_hours'         => (int) HTTP::_GP('duration_hours', 48),
					'registration_hours'     => (int) HTTP::_GP('registration_hours', 24),
				);

				$result = PVEBossTournamentHelper::createEvent($params);

				if (!empty($result['ok'])) {
					$message = '🌌 Torneo del Devorador #' . (int) $result['event_id'] . ' creado (status: scheduled). Abre el registro cuando estés listo.';
					$msgType = 'success';
				} else {
					$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo crear el torneo.');
					$msgType = 'error';
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
			$tab = 'boss';
		}
	}

	// ─── ABRIR REGISTRO ───
	if ($action === 'openBossRegistration') {
		if (class_exists('PVEBossTournamentHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$ok = PVEBossTournamentHelper::openRegistration($eventId);
					if ($ok) {
						$message = '📝 Registro abierto para el torneo #' . $eventId . '. Notificando a los líderes de alianza...';
						$msgType = 'success';
					} else {
						$message = '⚠️ No se pudo abrir el registro (el evento no está en scheduled).';
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Torneo no instalado.';
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ─── INICIAR EVENTO (SPAWN MASIVO DE FANTASMAS) ───
	if ($action === 'startBossEvent') {
		if (class_exists('PVEBossTournamentHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$result = PVEBossTournamentHelper::startEvent($eventId);
					if (!empty($result['ok'])) {
						$spawned = isset($result['spawned']) ? (int) $result['spawned'] : 0;
						$message = '🚀 Torneo #' . $eventId . ' iniciado. Se han creado <strong>' . $spawned . '</strong> fantasmas. Todos los miembros de las alianzas inscritas han recibido sus coordenadas.';
						$msgType = 'success';
					} else {
						$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo iniciar el torneo.');
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Torneo no instalado.';
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ─── FINALIZAR EVENTO ───
	if ($action === 'finishBossEvent') {
		if (class_exists('PVEBossTournamentHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$result = PVEBossTournamentHelper::finishEvent($eventId, 'admin_forced');
					if (!empty($result['ok'])) {
						$message = '🏆 Torneo #' . $eventId . ' finalizado.';
						if (!empty($result['winner_ally_id'])) {
							$message .= ' Ganador: alianza #' . (int) $result['winner_ally_id'] . ' (' . number_format((int) $result['winner_pct'], 2) . '% del HP total).';
						}
						$msgType = 'success';
					} else {
						$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo finalizar.');
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Torneo no instalado.';
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ─── CANCELAR EVENTO + REFUND ───
	if ($action === 'cancelBossEvent') {
		if (class_exists('PVEBossTournamentHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				$refund  = (int) HTTP::_GP('refund', 1);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$result = PVEBossTournamentHelper::cancelEvent($eventId, 'admin_cancelled', $refund === 1);
					if (!empty($result['ok'])) {
						$message = '🛑 Torneo #' . $eventId . ' cancelado.';
						if ($refund === 1 && !empty($result['refunded'])) {
							// v4.3 — Mensaje riel-neutro
							$message .= ' Reembolsados a ' . (int) $result['refunded'] . ' líderes en su riel.';
						}
						$msgType = 'success';
					} else {
						$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo cancelar.');
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Torneo no instalado.';
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ─── FORZAR RESPAWN DE UN FANTASMA ───
	if ($action === 'forceBossRespawn') {
		if (class_exists('PVEBossTournamentHelper')) {
			try {
				$registrationId = (int) HTTP::_GP('registration_id', 0);
				if ($registrationId <= 0) {
					$message = '❌ Registration inválida.';
					$msgType = 'error';
				} else {
					$result = PVEBossTournamentHelper::forceRespawnGhost($registrationId);
					if (!empty($result['ok'])) {
						$message = '♻️ Respawn forzado para registration #' . $registrationId . '. Nuevo fantasma: [' . (int) $result['galaxy'] . ':' . (int) $result['system'] . ':' . (int) $result['planet'] . ']';
						$msgType = 'success';
					} else {
						$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo forzar el respawn.');
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Torneo no instalado.';
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ─── MATAR FANTASMA (DEBUG) ───
	if ($action === 'killBossGhostDebug') {
		if (class_exists('PVEBossTournamentHelper')) {
			try {
				$ghostId = (int) HTTP::_GP('ghost_id', 0);
				if ($ghostId <= 0) {
					$message = '❌ Ghost ID inválido.';
					$msgType = 'error';
				} else {
					$result = PVEBossTournamentHelper::applyDamage($ghostId, PHP_INT_MAX);
					if (!empty($result['killed'])) {
						$message = '💀 Fantasma #' . $ghostId . ' eliminado (debug).';
						$msgType = 'success';
					} else {
						$message = '⚠️ El fantasma sigue vivo tras aplicar daño masivo.';
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Torneo no instalado.';
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ─── GUARDAR CONFIGS DEFAULT DEL TORNEO ───
	if ($action === 'saveBossConfig') {
		try {
			$configs = array(
				'pve_boss_enabled'                => (int) HTTP::_GP('pve_boss_enabled', 0),
				'boss_enabled'                    => (int) HTTP::_GP('pve_boss_enabled', 0),
				'boss_default_name'               => HTTP::_GP('boss_default_name', 'El Devorador Estelar'),
				'boss_duration_hours'             => (int) HTTP::_GP('boss_duration_hours', 48),
				'boss_registration_hours'         => (int) HTTP::_GP('boss_registration_hours', 24),
				'boss_hp_per_member'              => (int) HTTP::_GP('boss_hp_per_member', 500000),
				'boss_hp_min'                     => (int) HTTP::_GP('boss_hp_min', 10000000),
				'boss_min_alliances'              => (int) HTTP::_GP('boss_min_alliances', 2),
				'boss_max_alliances'              => (int) HTTP::_GP('boss_max_alliances', 20),
				'boss_default_entry_mode'         => HTTP::_GP('boss_default_entry_mode', 'free'),
				'boss_default_entry_cost_ntx'     => (int) HTTP::_GP('boss_default_entry_cost_ntx', 50),
				'boss_default_prize_type'         => HTTP::_GP('boss_default_prize_type', 'ntx'),
				'boss_default_prize_ntx'          => (int) HTTP::_GP('boss_default_prize_ntx', 500),
				'boss_default_prize_metal'        => (int) HTTP::_GP('boss_default_prize_metal', 100000000),
				'boss_default_prize_crystal'      => (int) HTTP::_GP('boss_default_prize_crystal', 50000000),
				'boss_default_prize_deuterium'    => (int) HTTP::_GP('boss_default_prize_deuterium', 20000000),
				'boss_default_prize_dark_matter'  => (int) HTTP::_GP('boss_default_prize_dark_matter', 50000),
				'boss_project_fee_pct'            => (int) HTTP::_GP('boss_project_fee_pct', 5),
				'boss_winner_distribution'        => HTTP::_GP('boss_winner_distribution', 'by_contribution'),
				'boss_phase2_threshold'           => (int) HTTP::_GP('boss_phase2_threshold', 70),
				'boss_phase3_threshold'           => (int) HTTP::_GP('boss_phase3_threshold', 30),
				'boss_phase2_counter_interval'    => (int) HTTP::_GP('boss_phase2_counter_interval', 270),
				'boss_phase3_counter_interval'    => (int) HTTP::_GP('boss_phase3_counter_interval', 240),
				'boss_counter_targets'            => (int) HTTP::_GP('boss_counter_targets', 1),
				'boss_counter_skip_offline'       => (int) HTTP::_GP('boss_counter_skip_offline', 1),
				'boss_counter_avoid_repeat'       => (int) HTTP::_GP('boss_counter_avoid_repeat', 1),
				'boss_counter_min_fleet_pct'      => (int) HTTP::_GP('boss_counter_min_fleet_pct', 5),
				'boss_respawn_enabled'            => (int) HTTP::_GP('boss_respawn_enabled', 1),
				'boss_respawn_cooldown_min'       => (int) HTTP::_GP('boss_respawn_cooldown_min', 5),
				'boss_max_respawns_per_ally'      => (int) HTTP::_GP('boss_max_respawns_per_ally', 0),
				'boss_respawn_block_last_hours'   => (int) HTTP::_GP('boss_respawn_block_last_hours', 1),
				'boss_ranking_live_interval'      => (int) HTTP::_GP('boss_ranking_live_interval', 10),
				'boss_refund_on_cancel'           => (int) HTTP::_GP('boss_refund_on_cancel', 1),
				'boss_refund_if_min_not_reached'  => (int) HTTP::_GP('boss_refund_if_min_not_reached', 1),
			);

			foreach ($configs as $key => $value) {
				$existing = $db->selectSingle(
					"SELECT id FROM %%PVE_CONFIG%% WHERE config_key = :key LIMIT 1;",
					array(':key' => $key)
				);

				if (!empty($existing)) {
					$db->update(
						"UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = :key;",
						array(':val' => (string) $value, ':now' => TIMESTAMP, ':key' => $key)
					);
				} else {
					$db->insert(
						"INSERT INTO %%PVE_CONFIG%% (config_key, config_value, updated_at) VALUES (:key, :val, :now);",
						array(':key' => $key, ':val' => (string) $value, ':now' => TIMESTAMP)
					);
				}
			}

			PVEHelper::clearConfigCache();
			$message = '💾 Configuración del Torneo guardada.';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ═══════════════════════════════════════════
	// 🆕 v3.5/v3.6 — ACCIONES DE AUTO-PROGRAMACIÓN
	// ═══════════════════════════════════════════

	// ─── GUARDAR PROGRAMACIÓN AUTOMÁTICA DEL TORNEO ───
	if ($action === 'saveBossSchedule') {
		try {
			$enabled = (int) HTTP::_GP('boss_auto_schedule_enabled', 0);
			$day     = (int) HTTP::_GP('boss_schedule_day', 15);
			$hour    = (int) HTTP::_GP('boss_schedule_hour', 20);
			$minute  = (int) HTTP::_GP('boss_schedule_minute', 0);

			$day    = max(1, min(28, $day));
			$hour   = max(0, min(23, $hour));
			$minute = max(0, min(59, $minute));

			$configs = array(
				'boss_auto_schedule_enabled' => $enabled,
				'boss_schedule_day'          => $day,
				'boss_schedule_hour'         => $hour,
				'boss_schedule_minute'       => $minute,
			);

			foreach ($configs as $key => $value) {
				$existing = $db->selectSingle(
					"SELECT id FROM %%PVE_CONFIG%% WHERE config_key = :key LIMIT 1;",
					array(':key' => $key)
				);

				if (!empty($existing)) {
					$db->update(
						"UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = :key;",
						array(':val' => (string) $value, ':now' => TIMESTAMP, ':key' => $key)
					);
				} else {
					$db->insert(
						"INSERT INTO %%PVE_CONFIG%% (config_key, config_value, updated_at) VALUES (:key, :val, :now);",
						array(':key' => $key, ':val' => (string) $value, ':now' => TIMESTAMP)
					);
				}
			}

			PVEHelper::clearConfigCache();

			// ═══════════════════════════════════════════════════════════
			// 🆕 v3.6 — CHECKBOX REACTIVO
			// Si MARCA → forzar creación del evento scheduled AHORA
			// Si DESMARCA → cancelar los eventos scheduled pendientes
			// ═══════════════════════════════════════════════════════════
			$schedulerMsg = '';

			if ($enabled === 1 && class_exists('PVEBossTournamentHelper')
				&& method_exists('PVEBossTournamentHelper', 'forceAutoScheduleNow')) {
				try {
					$schedResult = PVEBossTournamentHelper::forceAutoScheduleNow();

					if (!empty($schedResult['ok'])) {
						$startTime = !empty($schedResult['start_time'])
							? date('d/m/Y H:i', (int) $schedResult['start_time'])
							: '—';
						$schedulerMsg = '<br>✅ Evento programado creado al instante: <strong>#' . (int) $schedResult['event_id'] . '</strong> — inicio <strong>' . $startTime . '</strong>.';
					} else {
						$err = !empty($schedResult['error']) ? $schedResult['error'] : 'Error desconocido';
						$schedulerMsg = '<br>⚠️ No se pudo crear el evento programado ahora: ' . $err;
					}
				} catch (Throwable $e) {
					$schedulerMsg = '<br>⚠️ Excepción al crear el evento: ' . $e->getMessage();
				}
			}
			elseif ($enabled === 0 && class_exists('PVEBossTournamentHelper')
				&& method_exists('PVEBossTournamentHelper', 'cancelScheduledEvents')) {
				try {
					$cancelResult = PVEBossTournamentHelper::cancelScheduledEvents();
					$cancelled = !empty($cancelResult['cancelled']) ? (int) $cancelResult['cancelled'] : 0;

					if ($cancelled > 0) {
						$schedulerMsg = '<br>🛑 Se cancelaron <strong>' . $cancelled . '</strong> evento(s) programado(s) pendiente(s).';
					} else {
						$schedulerMsg = '<br>ℹ️ No había eventos programados pendientes que cancelar.';
					}
				} catch (Throwable $e) {
					$schedulerMsg = '<br>⚠️ Excepción al cancelar eventos programados: ' . $e->getMessage();
				}
			}

			if ($enabled === 1) {
				$message = '📅 Auto-programación del Torneo <strong>ACTIVADA</strong>. El torneo se iniciará el día <strong>' 
					. str_pad($day, 2, '0', STR_PAD_LEFT) . '</strong> de cada mes a las <strong>' 
					. str_pad($hour, 2, '0', STR_PAD_LEFT) . ':' . str_pad($minute, 2, '0', STR_PAD_LEFT) . '</strong>.'
					. $schedulerMsg;
			} else {
				$message = '⏸️ Auto-programación del Torneo <strong>DESACTIVADA</strong>. El torneo no se iniciará automáticamente.'
					. $schedulerMsg;
			}

			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar la programación: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'boss';
	}

	// ─── GUARDAR AUTO-PROGRAMACIÓN DE CRISIS ───
	if ($action === 'saveCrisisAutoSchedule') {
		try {
			$enabled = (int) HTTP::_GP('crisis_auto_schedule_enabled', 0);

			$existing = $db->selectSingle(
				"SELECT id FROM %%PVE_CONFIG%% WHERE config_key = 'crisis_auto_schedule_enabled' LIMIT 1;"
			);

			if (!empty($existing)) {
				$db->update(
					"UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = 'crisis_auto_schedule_enabled';",
					array(':val' => (string) $enabled, ':now' => TIMESTAMP)
				);
			} else {
				$db->insert(
					"INSERT INTO %%PVE_CONFIG%% (config_key, config_value, updated_at) VALUES ('crisis_auto_schedule_enabled', :val, :now);",
					array(':val' => (string) $enabled, ':now' => TIMESTAMP)
				);
			}

			PVEHelper::clearConfigCache();

			if ($enabled === 1) {
				$message = '📅 Auto-programación de Crisis <strong>ACTIVADA</strong>. La crisis se auto-programará cada mes según la fecha configurada.';
			} else {
				$message = '⏸️ Auto-programación de Crisis <strong>DESACTIVADA</strong>. La crisis NO se auto-programará (solo funcionará el modo manual/programado por admin).';
			}

			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'crisis';
	}

	/* --------------------------------------------------------------
	 *  FIN DE LA PARTE 1 — continúa en la PARTE 2 con:
	 *    - Acciones del Bastión Asediado (create/open/start/finish/cancel/saveConfig/saveSchedule)
	 *    - Carga de datos: config, schedules, listas, stats
	 *    - Stats dual-riel: total_pool_ntx20 + total_pool_untx20 (Boss + Bastión)
	 *    - Catálogo de naves y defensas
	 *    - assign_vars + template->show
	 *    - Cierre de función
	 * -------------------------------------------------------------- */
	 
	 	// ═══════════════════════════════════════════
	// 🆕 v4.0 — ACCIONES DEL BASTIÓN ASEDIADO
	// ═══════════════════════════════════════════

	// ─── CREAR EVENTO DEL BASTIÓN ───
	if ($action === 'createBastionEvent') {
		if (!class_exists('PVEBastionHelper')) {
			$message = '❌ El módulo del Bastión no está instalado.';
			$msgType = 'error';
			$tab = 'bastion';
		} else {
			try {
				$params = array(
					'bastion_name'              => HTTP::_GP('bastion_name', 'El Bastión de la Alianza'),
					'entry_mode'                => HTTP::_GP('entry_mode', 'free'),
					'entry_cost_ntx'            => (int) HTTP::_GP('entry_cost_ntx', 50),
					'prize_type'                => HTTP::_GP('prize_type', 'ntx'),
					'prize_metal'               => (int) HTTP::_GP('prize_metal', 0),
					'prize_crystal'             => (int) HTTP::_GP('prize_crystal', 0),
					'prize_deuterium'           => (int) HTTP::_GP('prize_deuterium', 0),
					'prize_dark_matter'         => (int) HTTP::_GP('prize_dark_matter', 0),
					'prize_ntx'                 => (int) HTTP::_GP('prize_ntx', 500),
					'prize_scales_with_allies'  => (int) HTTP::_GP('prize_scales_with_allies', 0),
					'project_fee_pct'           => (int) HTTP::_GP('project_fee_pct', 5),
					'winner_distribution'       => HTTP::_GP('winner_distribution', 'by_contribution'),
					'min_alliances'             => (int) HTTP::_GP('min_alliances', 2),
					'max_alliances'             => (int) HTTP::_GP('max_alliances', 20),
					'bastion_hp_per_member'     => (int) HTTP::_GP('bastion_hp_per_member', 500000),
					'bastion_hp_min'            => (int) HTTP::_GP('bastion_hp_min', 10000000),
					'duration_hours'            => (int) HTTP::_GP('duration_hours', 48),
					'registration_hours'        => (int) HTTP::_GP('registration_hours', 24),
					'bastion_template_id'       => (int) HTTP::_GP('bastion_template_id', 0),
					'bastion_mode'              => HTTP::_GP('bastion_mode', 'standard'),
				);

				$result = PVEBastionHelper::createEvent($params);

				if (!empty($result['ok'])) {
					$message = '⚓ Bastión Asediado #' . (int) $result['event_id'] . ' creado (status: scheduled). Abre el registro cuando estés listo.';
					$msgType = 'success';
				} else {
					$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo crear el evento.');
					$msgType = 'error';
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
			$tab = 'bastion';
		}
	}

	// ─── ABRIR REGISTRO DEL BASTIÓN ───
	if ($action === 'openBastionRegistration') {
		if (class_exists('PVEBastionHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$ok = PVEBastionHelper::openRegistration($eventId);
					if ($ok) {
						$message = '📝 Registro abierto para el Bastión #' . $eventId . '. Notificando a los líderes de alianza...';
						$msgType = 'success';
					} else {
						$message = '⚠️ No se pudo abrir el registro (el evento no está en scheduled).';
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Bastión no instalado.';
			$msgType = 'error';
		}
		$tab = 'bastion';
	}

	// ─── INICIAR EVENTO DEL BASTIÓN ───
	if ($action === 'startBastionEvent') {
		if (class_exists('PVEBastionHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$result = PVEBastionHelper::startEvent($eventId);
					if (!empty($result['ok'])) {
						$spawned = isset($result['spawned']) ? (int) $result['spawned'] : 0;
						$message = '🚀 Bastión #' . $eventId . ' iniciado. Se han creado <strong>' . $spawned . '</strong> bastiones. Todos los miembros de las alianzas inscritas han recibido sus coordenadas.';
						$msgType = 'success';
					} else {
						$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo iniciar el evento.');
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Bastión no instalado.';
			$msgType = 'error';
		}
		$tab = 'bastion';
	}

	// ─── FINALIZAR EVENTO DEL BASTIÓN ───
	if ($action === 'finishBastionEvent') {
		if (class_exists('PVEBastionHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$result = PVEBastionHelper::finishEvent($eventId, 'admin_forced');
					if (!empty($result['ok'])) {
						$message = '🏆 Bastión #' . $eventId . ' finalizado.';
						if (!empty($result['winner_ally_id'])) {
							$message .= ' Ganador: alianza #' . (int) $result['winner_ally_id'] . ' (score ' . number_format((int) ($result['winner_score'] ?? 0)) . ').';
						}
						$msgType = 'success';
					} else {
						$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo finalizar.');
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Bastión no instalado.';
			$msgType = 'error';
		}
		$tab = 'bastion';
	}

	// ─── CANCELAR EVENTO DEL BASTIÓN + REFUND ───
	if ($action === 'cancelBastionEvent') {
		if (class_exists('PVEBastionHelper')) {
			try {
				$eventId = (int) HTTP::_GP('event_id', 0);
				$refund  = (int) HTTP::_GP('refund', 1);
				if ($eventId <= 0) {
					$message = '❌ Evento inválido.';
					$msgType = 'error';
				} else {
					$result = PVEBastionHelper::cancelEvent($eventId, 'admin_cancelled', $refund === 1);
					if (!empty($result['ok'])) {
						$message = '🛑 Bastión #' . $eventId . ' cancelado.';
						if ($refund === 1 && !empty($result['refunded'])) {
							// v4.3 — Mensaje riel-neutro
							$message .= ' Reembolsados a ' . (int) $result['refunded'] . ' líderes en su riel.';
						}
						$msgType = 'success';
					} else {
						$message = '❌ ' . (!empty($result['error']) ? $result['error'] : 'No se pudo cancelar.');
						$msgType = 'error';
					}
				}
			} catch (Throwable $e) {
				$message = '❌ Error: ' . $e->getMessage();
				$msgType = 'error';
			}
		} else {
			$message = '❌ Módulo del Bastión no instalado.';
			$msgType = 'error';
		}
		$tab = 'bastion';
	}

	// ─── GUARDAR CONFIGS DEFAULT DEL BASTIÓN ───
	if ($action === 'saveBastionConfig') {
		try {
			$configs = array(
				'pve_bastion_enabled'                => (int) HTTP::_GP('pve_bastion_enabled', 0),
				'bastion_enabled'                    => (int) HTTP::_GP('pve_bastion_enabled', 0),
				'bastion_default_name'               => HTTP::_GP('bastion_default_name', 'El Bastión de la Alianza'),
				'bastion_duration_hours'             => (int) HTTP::_GP('bastion_duration_hours', 48),
				'bastion_registration_hours'         => (int) HTTP::_GP('bastion_registration_hours', 24),
				'bastion_hp_per_member'              => (int) HTTP::_GP('bastion_hp_per_member', 500000),
				'bastion_hp_min'                     => (int) HTTP::_GP('bastion_hp_min', 10000000),
				'bastion_min_alliances'              => (int) HTTP::_GP('bastion_min_alliances', 2),
				'bastion_max_alliances'              => (int) HTTP::_GP('bastion_max_alliances', 20),
				'bastion_default_entry_mode'         => HTTP::_GP('bastion_default_entry_mode', 'free'),
				'bastion_default_entry_cost_ntx'     => (int) HTTP::_GP('bastion_default_entry_cost_ntx', 50),
				'bastion_default_prize_type'         => HTTP::_GP('bastion_default_prize_type', 'ntx'),
				'bastion_default_prize_ntx'          => (int) HTTP::_GP('bastion_default_prize_ntx', 500),
				'bastion_default_prize_metal'        => (int) HTTP::_GP('bastion_default_prize_metal', 100000000),
				'bastion_default_prize_crystal'      => (int) HTTP::_GP('bastion_default_prize_crystal', 50000000),
				'bastion_default_prize_deuterium'    => (int) HTTP::_GP('bastion_default_prize_deuterium', 20000000),
				'bastion_default_prize_dark_matter'  => (int) HTTP::_GP('bastion_default_prize_dark_matter', 50000),
				'bastion_project_fee_pct'            => (int) HTTP::_GP('bastion_project_fee_pct', 5),
				'bastion_winner_distribution'        => HTTP::_GP('bastion_winner_distribution', 'by_contribution'),
				'bastion_score_per_pirate'           => (int) HTTP::_GP('bastion_score_per_pirate', 100),
				'bastion_score_hp_pct_weight'        => (int) HTTP::_GP('bastion_score_hp_pct_weight', 50),
				'bastion_score_per_boss_pirate'      => (int) HTTP::_GP('bastion_score_per_boss_pirate', 500),
				'bastion_refund_on_cancel'           => (int) HTTP::_GP('bastion_refund_on_cancel', 1),
				'bastion_refund_if_min_not_reached'  => (int) HTTP::_GP('bastion_refund_if_min_not_reached', 1),
				'bastion_ships_return_on_end'        => (int) HTTP::_GP('bastion_ships_return_on_end', 1),
				'bastion_phase_calm_end'             => (int) HTTP::_GP('bastion_phase_calm_end', 6),
				'bastion_phase_surge_end'            => (int) HTTP::_GP('bastion_phase_surge_end', 24),
				'bastion_phase_siege_end'            => (int) HTTP::_GP('bastion_phase_siege_end', 40),
				'bastion_wave_interval_calm'         => (int) HTTP::_GP('bastion_wave_interval_calm', 360),
				'bastion_wave_interval_surge'        => (int) HTTP::_GP('bastion_wave_interval_surge', 180),
				'bastion_wave_interval_siege'        => (int) HTTP::_GP('bastion_wave_interval_siege', 120),
				'bastion_wave_interval_hell'         => (int) HTTP::_GP('bastion_wave_interval_hell', 60),
				'bastion_pirate_flight_min'          => (int) HTTP::_GP('bastion_pirate_flight_min', 30),
				'bastion_pirate_flight_max'          => (int) HTTP::_GP('bastion_pirate_flight_max', 90),
				'bastion_pirate_mult_calm'           => (int) HTTP::_GP('bastion_pirate_mult_calm', 1),
				'bastion_pirate_mult_surge'          => (int) HTTP::_GP('bastion_pirate_mult_surge', 2),
				'bastion_pirate_mult_siege'          => (int) HTTP::_GP('bastion_pirate_mult_siege', 4),
				'bastion_pirate_mult_hell'           => (int) HTTP::_GP('bastion_pirate_mult_hell', 8),
				'bastion_pirate_base_fleet_json'     => HTTP::_GP('bastion_pirate_base_fleet_json', '{"204":100,"205":50,"206":25,"207":10}'),
				'bastion_boss_pirate_chance_calm'    => (int) HTTP::_GP('bastion_boss_pirate_chance_calm', 0),
				'bastion_boss_pirate_chance_surge'   => (int) HTTP::_GP('bastion_boss_pirate_chance_surge', 10),
				'bastion_boss_pirate_chance_siege'   => (int) HTTP::_GP('bastion_boss_pirate_chance_siege', 20),
				'bastion_boss_pirate_chance_hell'    => (int) HTTP::_GP('bastion_boss_pirate_chance_hell', 35),
				'bastion_boss_pirate_fleet_json'     => HTTP::_GP('bastion_boss_pirate_fleet_json', '{"204":500,"205":200,"211":50,"213":20}'),
				'bastion_ranking_live_interval'      => (int) HTTP::_GP('bastion_ranking_live_interval', 10),
			);

			foreach ($configs as $key => $value) {
				$existing = $db->selectSingle(
					"SELECT id FROM %%PVE_CONFIG%% WHERE config_key = :key LIMIT 1;",
					array(':key' => $key)
				);

				if (!empty($existing)) {
					$db->update(
						"UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = :key;",
						array(':val' => (string) $value, ':now' => TIMESTAMP, ':key' => $key)
					);
				} else {
					$db->insert(
						"INSERT INTO %%PVE_CONFIG%% (config_key, config_value, updated_at) VALUES (:key, :val, :now);",
						array(':key' => $key, ':val' => (string) $value, ':now' => TIMESTAMP)
					);
				}
			}

			PVEHelper::clearConfigCache();
			$message = '💾 Configuración del Bastión guardada.';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'bastion';
	}

	// ─── GUARDAR AUTO-PROGRAMACIÓN DEL BASTIÓN ───
	if ($action === 'saveBastionSchedule') {
		try {
			$enabled = (int) HTTP::_GP('bastion_auto_schedule_enabled', 0);
			$day     = (int) HTTP::_GP('bastion_schedule_day', 20);
			$hour    = (int) HTTP::_GP('bastion_schedule_hour', 20);
			$minute  = (int) HTTP::_GP('bastion_schedule_minute', 0);

			$day    = max(1, min(28, $day));
			$hour   = max(0, min(23, $hour));
			$minute = max(0, min(59, $minute));

			$configs = array(
				'bastion_auto_schedule_enabled' => $enabled,
				'bastion_schedule_day'          => $day,
				'bastion_schedule_hour'         => $hour,
				'bastion_schedule_minute'       => $minute,
			);

			foreach ($configs as $key => $value) {
				$existing = $db->selectSingle(
					"SELECT id FROM %%PVE_CONFIG%% WHERE config_key = :key LIMIT 1;",
					array(':key' => $key)
				);

				if (!empty($existing)) {
					$db->update(
						"UPDATE %%PVE_CONFIG%% SET config_value = :val, updated_at = :now WHERE config_key = :key;",
						array(':val' => (string) $value, ':now' => TIMESTAMP, ':key' => $key)
					);
				} else {
					$db->insert(
						"INSERT INTO %%PVE_CONFIG%% (config_key, config_value, updated_at) VALUES (:key, :val, :now);",
						array(':key' => $key, ':val' => (string) $value, ':now' => TIMESTAMP)
					);
				}
			}

			PVEHelper::clearConfigCache();

			// Checkbox reactivo (forzar / cancelar)
			$schedulerMsg = '';

			if ($enabled === 1 && class_exists('PVEBastionHelper')
				&& method_exists('PVEBastionHelper', 'forceAutoScheduleNow')) {
				try {
					$schedResult = PVEBastionHelper::forceAutoScheduleNow();

					if (!empty($schedResult['ok'])) {
						$startTime = !empty($schedResult['start_time'])
							? date('d/m/Y H:i', (int) $schedResult['start_time'])
							: '—';
						$schedulerMsg = '<br>✅ Evento del Bastión programado al instante: <strong>#' . (int) $schedResult['event_id'] . '</strong> — inicio <strong>' . $startTime . '</strong>.';
					} else {
						$err = !empty($schedResult['error']) ? $schedResult['error'] : 'Error desconocido';
						$schedulerMsg = '<br>⚠️ No se pudo crear el evento del Bastión ahora: ' . $err;
					}
				} catch (Throwable $e) {
					$schedulerMsg = '<br>⚠️ Excepción al crear el evento: ' . $e->getMessage();
				}
			}
			elseif ($enabled === 0 && class_exists('PVEBastionHelper')
				&& method_exists('PVEBastionHelper', 'cancelScheduledEvents')) {
				try {
					$cancelResult = PVEBastionHelper::cancelScheduledEvents();
					$cancelled = !empty($cancelResult['cancelled']) ? (int) $cancelResult['cancelled'] : 0;

					if ($cancelled > 0) {
						$schedulerMsg = '<br>🛑 Se cancelaron <strong>' . $cancelled . '</strong> evento(s) programado(s) pendiente(s).';
					} else {
						$schedulerMsg = '<br>ℹ️ No había eventos programados pendientes que cancelar.';
					}
				} catch (Throwable $e) {
					$schedulerMsg = '<br>⚠️ Excepción al cancelar eventos programados: ' . $e->getMessage();
				}
			}

			if ($enabled === 1) {
				$message = '📅 Auto-programación del Bastión <strong>ACTIVADA</strong>. El evento se iniciará el día <strong>'
					. str_pad($day, 2, '0', STR_PAD_LEFT) . '</strong> de cada mes a las <strong>'
					. str_pad($hour, 2, '0', STR_PAD_LEFT) . ':' . str_pad($minute, 2, '0', STR_PAD_LEFT) . '</strong>.'
					. $schedulerMsg;
			} else {
				$message = '⏸️ Auto-programación del Bastión <strong>DESACTIVADA</strong>. El evento no se iniciará automáticamente.'
					. $schedulerMsg;
			}

			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al guardar la programación: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'bastion';
	}

	// ============================================
	// CARGAR DATOS PARA LA VISTA
	// ============================================

	$config = PVEHelper::getConfig();

	// --- Config específica de RECOMPENSAS (para la pestaña rewards) ---
	$rewardsConfig = array(
		'crisis_reward_type'      => isset($config['crisis_reward_type'])      ? $config['crisis_reward_type']      : 'ntx',
		'crisis_reward_ntx'       => isset($config['crisis_reward_ntx'])       ? (int) $config['crisis_reward_ntx'] : 5,
		'crisis_reward_metal'     => isset($config['crisis_reward_metal'])     ? (int) $config['crisis_reward_metal'] : 0,
		'crisis_reward_crystal'   => isset($config['crisis_reward_crystal'])   ? (int) $config['crisis_reward_crystal'] : 0,
		'crisis_reward_deuterium' => isset($config['crisis_reward_deuterium']) ? (int) $config['crisis_reward_deuterium'] : 0,
		'crisis_reward_split'     => isset($config['crisis_reward_split'])     ? $config['crisis_reward_split'] : 'per_player',
		'empire_loot_pct'         => isset($config['empire_loot_pct'])         ? (int) $config['empire_loot_pct'] : 100,
	);

	// ============================================
	// 🆕 v3.5 — CONFIG DE AUTO-PROGRAMACIÓN
	// ============================================

	// ─── Config de auto-programación de la Crisis ───
	$crisisAutoSchedule = array(
		'enabled'    => isset($config['crisis_auto_schedule_enabled'])    ? (int) $config['crisis_auto_schedule_enabled']    : 1,
		'last_month' => isset($config['crisis_auto_schedule_last_month']) ? (int) $config['crisis_auto_schedule_last_month'] : 0,
	);

	// ─── Config de auto-programación del Torneo ───
	$bossSchedule = array(
		'enabled'    => isset($config['boss_auto_schedule_enabled']) ? (int) $config['boss_auto_schedule_enabled'] : 0,
		'day'        => isset($config['boss_schedule_day'])          ? (int) $config['boss_schedule_day']          : 15,
		'hour'       => isset($config['boss_schedule_hour'])         ? (int) $config['boss_schedule_hour']         : 20,
		'minute'     => isset($config['boss_schedule_minute'])       ? (int) $config['boss_schedule_minute']       : 0,
		'last_month' => isset($config['boss_schedule_last_month'])   ? (int) $config['boss_schedule_last_month']   : 0,
		'next_scheduled'     => 0,
		'next_scheduled_fmt' => '—',
	);

	// Sanitizar
	$bossSchedule['day']    = max(1, min(28, $bossSchedule['day']));
	$bossSchedule['hour']   = max(0, min(23, $bossSchedule['hour']));
	$bossSchedule['minute'] = max(0, min(59, $bossSchedule['minute']));

	// Calcular la próxima ejecución del torneo (solo si está activado)
	if ($bossSchedule['enabled'] === 1) {
		try {
			$year  = (int) date('Y', TIMESTAMP);
			$month = (int) date('n', TIMESTAMP);

			$ts = mktime(
				$bossSchedule['hour'],
				$bossSchedule['minute'],
				0,
				$month,
				$bossSchedule['day'],
				$year
			);

			if ($ts !== false) {
				// Si ya pasó, mostrar el del próximo mes
				if ($ts <= TIMESTAMP) {
					$nextMonth = $month + 1;
					$nextYear  = $year;
					if ($nextMonth > 12) {
						$nextMonth = 1;
						$nextYear++;
					}
					$ts = mktime(
						$bossSchedule['hour'],
						$bossSchedule['minute'],
						0,
						$nextMonth,
						$bossSchedule['day'],
						$nextYear
					);
				}

				$bossSchedule['next_scheduled']     = (int) $ts;
				$bossSchedule['next_scheduled_fmt'] = date('d/m/Y H:i', (int) $ts);
			}
		} catch (Throwable $e) {
			$bossSchedule['next_scheduled_fmt'] = '⚠️ Error al calcular';
		}
	} else {
		$bossSchedule['next_scheduled_fmt'] = '— (desactivado)';
	}

	// ============================================
	// 🆕 v4.0 — CONFIG DE AUTO-PROGRAMACIÓN DEL BASTIÓN
	// ============================================
	$bastionSchedule = array(
		'enabled'    => isset($config['bastion_auto_schedule_enabled']) ? (int) $config['bastion_auto_schedule_enabled'] : 0,
		'day'        => isset($config['bastion_schedule_day'])          ? (int) $config['bastion_schedule_day']          : 20,
		'hour'       => isset($config['bastion_schedule_hour'])         ? (int) $config['bastion_schedule_hour']         : 20,
		'minute'     => isset($config['bastion_schedule_minute'])       ? (int) $config['bastion_schedule_minute']       : 0,
		'last_month' => isset($config['bastion_schedule_last_month'])   ? (int) $config['bastion_schedule_last_month']   : 0,
		'next_scheduled'     => 0,
		'next_scheduled_fmt' => '—',
	);

	$bastionSchedule['day']    = max(1, min(28, $bastionSchedule['day']));
	$bastionSchedule['hour']   = max(0, min(23, $bastionSchedule['hour']));
	$bastionSchedule['minute'] = max(0, min(59, $bastionSchedule['minute']));

	if ($bastionSchedule['enabled'] === 1) {
		try {
			$year  = (int) date('Y', TIMESTAMP);
			$month = (int) date('n', TIMESTAMP);

			$ts = mktime(
				$bastionSchedule['hour'],
				$bastionSchedule['minute'],
				0,
				$month,
				$bastionSchedule['day'],
				$year
			);

			if ($ts !== false) {
				if ($ts <= TIMESTAMP) {
					$nextMonth = $month + 1;
					$nextYear  = $year;
					if ($nextMonth > 12) {
						$nextMonth = 1;
						$nextYear++;
					}
					$ts = mktime(
						$bastionSchedule['hour'],
						$bastionSchedule['minute'],
						0,
						$nextMonth,
						$bastionSchedule['day'],
						$nextYear
					);
				}
				$bastionSchedule['next_scheduled']     = (int) $ts;
				$bastionSchedule['next_scheduled_fmt'] = date('d/m/Y H:i', (int) $ts);
			}
		} catch (Throwable $e) {
			$bastionSchedule['next_scheduled_fmt'] = '⚠️ Error al calcular';
		}
	} else {
		$bastionSchedule['next_scheduled_fmt'] = '— (desactivado)';
	}

	// --- Crisis activas y programadas ---
	$crisisList = $db->select(
		"SELECT * FROM %%PVE_CRISIS%% 
		 WHERE status IN ('scheduled','active') 
		 ORDER BY start_time ASC 
		 LIMIT 20;"
	);
	if (!is_array($crisisList)) $crisisList = array();

	foreach ($crisisList as &$c) {
		$c['faction_name'] = isset(PVECrisisHelper::FACTIONS[$c['faction']]) ? PVECrisisHelper::FACTIONS[$c['faction']] : 'Desconocida';
		$c['start_fmt']    = date('d/m/Y H:i', (int)$c['start_time']);
		$c['end_fmt']      = date('d/m/Y H:i', (int)$c['end_time']);
		$c['wave_str']     = $c['current_wave'] . ' / ' . $c['total_waves'];
		$c['status_label'] = $c['status'] === 'scheduled' ? '⏰ Programada' : '🔴 Activa';
	}
	unset($c);

	// --- Imperios activos ---
	$empires = $db->select(
		"SELECT * FROM %%PVE_EMPIRES%% 
		 WHERE status = 'active' 
		 ORDER BY current_hp DESC 
		 LIMIT 30;"
	);
	if (!is_array($empires)) $empires = array();

	foreach ($empires as &$e) {
		$e['hp_percent'] = ($e['total_hp'] > 0) ? round(($e['current_hp'] / $e['total_hp']) * 100, 1) : 0;
		$e['hp_fmt']     = number_format((int)$e['current_hp']);
		$e['hp_max_fmt'] = number_format((int)$e['total_hp']);
		$e['end_fmt']    = date('d/m/Y H:i', (int)$e['end_time']);
		$e['faction_name'] = isset(PVECrisisHelper::FACTIONS[$e['faction']]) ? PVECrisisHelper::FACTIONS[$e['faction']] : 'Desconocida';
		$e['has_ghost']  = !empty($e['ghost_user_id']) && (int) $e['ghost_user_id'] > 0;
		$e['ghost_label'] = $e['has_ghost'] ? ('#' . $e['ghost_user_id']) : '—';
	}
	unset($e);

	// --- Historial: últimas crisis finalizadas ---
	$history = $db->select(
		"SELECT * FROM %%PVE_CRISIS%% 
		 WHERE status = 'finished' 
		 ORDER BY end_time DESC 
		 LIMIT 5;"
	);
	if (!is_array($history)) $history = array();

	foreach ($history as &$h) {
		$h['faction_name'] = isset(PVECrisisHelper::FACTIONS[$h['faction']]) ? PVECrisisHelper::FACTIONS[$h['faction']] : 'Desconocida';
		$h['end_fmt']      = date('d/m/Y H:i', (int)$h['end_time']);
	}
	unset($h);

	// --- Estadísticas globales ---
	$stats = array(
		'total_crisis'    => 0,
		'total_empires'   => 0,
		'total_rewards'   => 0,
		'total_attacks'   => 0,
		'rewards_claimed' => 0,
	);

	$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_CRISIS%%;");
	$stats['total_crisis'] = !empty($row) ? (int)$row['c'] : 0;

	$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_EMPIRES%%;");
	$stats['total_empires'] = !empty($row) ? (int)$row['c'] : 0;

	$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_REWARDS%%;");
	$stats['total_rewards'] = !empty($row) ? (int)$row['c'] : 0;

	$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_CRISIS_ATTACKS%%;");
	$stats['total_attacks'] = !empty($row) ? (int)$row['c'] : 0;

	$row = $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_REWARDS%% WHERE claimed = 1;");
	$stats['rewards_claimed'] = !empty($row) ? (int)$row['c'] : 0;

	// --- PLANTILLAS ---
	$templatesList = PVEEmpireTemplateHelper::getAllTemplates();
	if (!is_array($templatesList)) $templatesList = array();

	foreach ($templatesList as &$t) {
		$t['ships_parsed']    = PVEEmpireTemplateHelper::parseShips($t);
		$t['defenses_parsed'] = PVEEmpireTemplateHelper::parseDefenses($t);
		$t['buildings_parsed']= PVEEmpireTemplateHelper::parseBuildings($t);
		$t['ships_count']     = count($t['ships_parsed']);
		$t['defenses_count']  = count($t['defenses_parsed']);
		$t['buildings_count'] = count($t['buildings_parsed']);
	}
	unset($t);

	// --- ¿Editar plantilla? ---
	$editTemplate = null;
	$editMode = ($action === 'editTemplate' || HTTP::_GP('edit_id', 0) > 0 || HTTP::_GP('new', 0) == 1);
	if ($editMode) {
		$editId = (int) HTTP::_GP('edit_id', HTTP::_GP('id', 0));
		if ($editId > 0) {
			$editTemplate = PVEEmpireTemplateHelper::getTemplate($editId);
			if ($editTemplate !== null) {
				$editTemplate['ships_parsed']    = PVEEmpireTemplateHelper::parseShips($editTemplate);
				$editTemplate['defenses_parsed'] = PVEEmpireTemplateHelper::parseDefenses($editTemplate);
				$editTemplate['buildings_parsed']= PVEEmpireTemplateHelper::parseBuildings($editTemplate);
			}
		}
		if ($editTemplate === null && HTTP::_GP('new', 0) == 1) {
			// Plantilla en blanco para crear nueva
			$editTemplate = array(
				'id'                  => 0,
				'name'                => '',
				'slug'                => '',
				'description'         => '',
				'hp_mult'             => 5.00,
				'res_metal'           => 10000000,
				'res_crystal'         => 5000000,
				'res_deuterium'       => 2000000,
				'ships_parsed'        => array(202 => 500, 203 => 200, 205 => 50),
				'defenses_parsed'     => array(401 => 1000, 402 => 500),
				'buildings_parsed'    => array(1 => 20, 2 => 15),
				'travel_mode'         => 'random',
				'travel_min'          => 30,
				'travel_max'          => 120,
				'travel_fixed'        => 60,
				'scheduled_day'       => 0,
				'scheduled_hour'      => 0,
				'scheduled_minute'    => 0,
				'fleet_speed_pct'     => 100,
				'waves_enabled'       => 0,
				'waves_count'         => 1,
				'waves_delay_min'     => 10,
				'regen_enabled'       => 0,
				'regen_interval_min'  => 15,
				'regen_pct'           => 10.00,
				'is_default'          => 0,
				'is_active'           => 1,
			);
		}
		if ($editTemplate !== null) {
			$tab = 'templates';
		}
	}

	// ============================================
	// v3.4 — DATOS DEL TORNEO DEL DEVORADOR
	// ============================================
	// ★ v4.1 FIX — Se eliminó el fallback que cargaba el último evento
	// (incluyendo cancelados/finalizados) cuando no había evento activo.
	// ★ v4.2 FIX — Contadores de fantasmas solo de eventos VIVOS.
	// ★ v4.3 — Stats dual-riel: total_pool_ntx20 + total_pool_untx20.
	// ============================================

	$bossEvent         = null;
	$bossRegistrations = array();
	$bossGhosts        = array();
	$bossRanking       = array();
	$bossStats         = array(
		'total_events'        => 0,
		'total_events_active' => 0,
		'total_ghosts'        => 0,
		'total_ghosts_killed' => 0,
		'total_pool_ntx'      => 0,   // legacy (suma base equivalente)
		'total_pool_ntx20'    => 0,   // v4.3 — pool CUP real
		'total_pool_untx20'   => 0,   // v4.3 — pool QVAPAY real
	);
	$bossConfig = array(
		'pve_boss_enabled'              => isset($config['pve_boss_enabled'])              ? (int) $config['pve_boss_enabled']              : 0,
		'boss_enabled'                  => isset($config['boss_enabled'])                  ? (int) $config['boss_enabled']                  : 0,
		'boss_default_name'             => isset($config['boss_default_name'])             ? $config['boss_default_name']                   : 'El Devorador Estelar',
		'boss_duration_hours'           => isset($config['boss_duration_hours'])           ? (int) $config['boss_duration_hours']           : 48,
		'boss_registration_hours'       => isset($config['boss_registration_hours'])       ? (int) $config['boss_registration_hours']       : 24,
		'boss_hp_per_member'            => isset($config['boss_hp_per_member'])            ? (int) $config['boss_hp_per_member']            : 500000,
		'boss_hp_min'                   => isset($config['boss_hp_min'])                   ? (int) $config['boss_hp_min']                   : 10000000,
		'boss_min_alliances'            => isset($config['boss_min_alliances'])            ? (int) $config['boss_min_alliances']            : 2,
		'boss_max_alliances'            => isset($config['boss_max_alliances'])            ? (int) $config['boss_max_alliances']            : 20,
		'boss_default_entry_mode'       => isset($config['boss_default_entry_mode'])       ? $config['boss_default_entry_mode']             : 'free',
		'boss_default_entry_cost_ntx'   => isset($config['boss_default_entry_cost_ntx'])   ? (int) $config['boss_default_entry_cost_ntx']   : 50,
		'boss_default_prize_type'       => isset($config['boss_default_prize_type'])       ? $config['boss_default_prize_type']             : 'ntx',
		'boss_default_prize_ntx'        => isset($config['boss_default_prize_ntx'])        ? (int) $config['boss_default_prize_ntx']        : 500,
		'boss_default_prize_metal'      => isset($config['boss_default_prize_metal'])      ? (int) $config['boss_default_prize_metal']      : 100000000,
		'boss_default_prize_crystal'    => isset($config['boss_default_prize_crystal'])    ? (int) $config['boss_default_prize_crystal']    : 50000000,
		'boss_default_prize_deuterium'  => isset($config['boss_default_prize_deuterium'])  ? (int) $config['boss_default_prize_deuterium']  : 20000000,
		'boss_default_prize_dark_matter'=> isset($config['boss_default_prize_dark_matter'])? (int) $config['boss_default_prize_dark_matter']: 50000,
		'boss_project_fee_pct'          => isset($config['boss_project_fee_pct'])          ? (int) $config['boss_project_fee_pct']          : 5,
		'boss_winner_distribution'      => isset($config['boss_winner_distribution'])      ? $config['boss_winner_distribution']            : 'by_contribution',
		'boss_phase2_threshold'         => isset($config['boss_phase2_threshold'])         ? (int) $config['boss_phase2_threshold']         : 70,
		'boss_phase3_threshold'         => isset($config['boss_phase3_threshold'])         ? (int) $config['boss_phase3_threshold']         : 30,
		'boss_phase2_counter_interval'  => isset($config['boss_phase2_counter_interval'])  ? (int) $config['boss_phase2_counter_interval']  : 270,
		'boss_phase3_counter_interval'  => isset($config['boss_phase3_counter_interval'])  ? (int) $config['boss_phase3_counter_interval']  : 240,
		'boss_counter_targets'          => isset($config['boss_counter_targets'])          ? (int) $config['boss_counter_targets']          : 1,
		'boss_counter_skip_offline'     => isset($config['boss_counter_skip_offline'])     ? (int) $config['boss_counter_skip_offline']     : 1,
		'boss_counter_avoid_repeat'     => isset($config['boss_counter_avoid_repeat'])     ? (int) $config['boss_counter_avoid_repeat']     : 1,
		'boss_counter_min_fleet_pct'    => isset($config['boss_counter_min_fleet_pct'])    ? (int) $config['boss_counter_min_fleet_pct']    : 5,
		'boss_respawn_enabled'          => isset($config['boss_respawn_enabled'])          ? (int) $config['boss_respawn_enabled']          : 1,
		'boss_respawn_cooldown_min'     => isset($config['boss_respawn_cooldown_min'])     ? (int) $config['boss_respawn_cooldown_min']     : 5,
		'boss_max_respawns_per_ally'    => isset($config['boss_max_respawns_per_ally'])    ? (int) $config['boss_max_respawns_per_ally']    : 0,
		'boss_respawn_block_last_hours' => isset($config['boss_respawn_block_last_hours']) ? (int) $config['boss_respawn_block_last_hours'] : 1,
		'boss_ranking_live_interval'    => isset($config['boss_ranking_live_interval'])    ? (int) $config['boss_ranking_live_interval']    : 10,
		'boss_refund_on_cancel'         => isset($config['boss_refund_on_cancel'])         ? (int) $config['boss_refund_on_cancel']         : 1,
		'boss_refund_if_min_not_reached'=> isset($config['boss_refund_if_min_not_reached'])? (int) $config['boss_refund_if_min_not_reached']: 1,
	);

	if (class_exists('PVEBossTournamentHelper')) {
		try {
			// ★ v4.1 FIX — Solo evento ACTIVO (scheduled/registration/active).
			$bossEvent = PVEBossTournamentHelper::getActiveEvent();

			// Registrations
			if (!empty($bossEvent['id'])) {
				$bossRegistrations = $db->select(
					"SELECT r.*, a.ally_name, a.ally_tag
					 FROM %%PVE_BOSS_REGISTRATIONS%% r
					 LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
					 WHERE r.event_id = :eid
					 ORDER BY r.pct_damage_total DESC, r.total_damage DESC
					 LIMIT 30;",
					array(':eid' => (int) $bossEvent['id'])
				);
				if (!is_array($bossRegistrations)) $bossRegistrations = array();

				// Fantasmas del evento
				$bossGhosts = $db->select(
					"SELECT g.*, a.ally_name AS ally_name
					 FROM %%PVE_BOSS_GHOSTS%% g
					 LEFT JOIN %%ALLIANCE%% a ON a.id = g.ally_id
					 WHERE g.event_id = :eid
					 ORDER BY g.spawned_at DESC
					 LIMIT 50;",
					array(':eid' => (int) $bossEvent['id'])
				);
				if (!is_array($bossGhosts)) $bossGhosts = array();

				// Ranking
				$bossRanking = PVEBossTournamentHelper::getLiveRanking((int) $bossEvent['id']);
				if (!is_array($bossRanking)) $bossRanking = array();
			}

			// Stats globales (siempre)
			$bossStats['total_events']        = (int) $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_BOSS_EVENT%%;", array(), 'c');
			$bossStats['total_events_active'] = (int) $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_BOSS_EVENT%% WHERE status = 'active';", array(), 'c');

			// ★ v4.2 FIX — Solo fantasmas de eventos VIVOS (scheduled/registration/active)
			$bossStats['total_ghosts'] = (int) $db->selectSingle(
				"SELECT COUNT(*) AS c
				 FROM %%PVE_BOSS_GHOSTS%% g
				 INNER JOIN %%PVE_BOSS_EVENT%% e ON e.id = g.event_id
				 WHERE e.status IN ('scheduled','registration','active')
				   AND g.status = 'active';",
				array(), 'c'
			);

			// ★ v4.2 FIX — Solo eliminados en eventos VIVOS
			$bossStats['total_ghosts_killed'] = (int) $db->selectSingle(
				"SELECT COUNT(*) AS c
				 FROM %%PVE_BOSS_GHOSTS%% g
				 INNER JOIN %%PVE_BOSS_EVENT%% e ON e.id = g.event_id
				 WHERE e.status IN ('scheduled','registration','active')
				   AND g.status = 'killed';",
				array(), 'c'
			);

			// v4.3 — Pools duales reales
			$bossStats['total_pool_ntx']    = (int) $db->selectSingle("SELECT COALESCE(SUM(total_pool_ntx), 0) AS c FROM %%PVE_BOSS_EVENT%%;", array(), 'c');
			$bossStats['total_pool_ntx20']  = (int) $db->selectSingle("SELECT COALESCE(SUM(pool_ntx20), 0)  AS c FROM %%PVE_BOSS_EVENT%%;", array(), 'c');
			$bossStats['total_pool_untx20'] = (int) $db->selectSingle("SELECT COALESCE(SUM(pool_untx20), 0) AS c FROM %%PVE_BOSS_EVENT%%;", array(), 'c');
		} catch (Throwable $e) {
			// Silencioso — probablemente tablas no creadas
		}
	}

	// ============================================
	// 🆕 v4.0 — DATOS DEL BASTIÓN ASEDIADO
	// ============================================
	// ★ v4.1 FIX — Se eliminó el fallback que cargaba el último evento
	// (incluyendo cancelados/finalizados) cuando no había evento activo.
	// ★ v4.2 FIX — Contadores de bastiones solo de eventos VIVOS.
	// ★ v4.3 — Stats dual-riel: total_pool_ntx20 + total_pool_untx20.
	// ============================================

	$bastionEvent         = null;
	$bastionRegistrations = array();
	$bastionGhosts        = array();
	$bastionWaves         = array();
	$bastionRanking       = array();
	$bastionStats         = array(
		'total_events'            => 0,
		'total_events_active'     => 0,
		'total_bastions'          => 0,
		'total_bastions_breached' => 0,
		'total_pool_ntx'          => 0,   // legacy (suma base equivalente)
		'total_pool_ntx20'        => 0,   // v4.3 — pool CUP real
		'total_pool_untx20'       => 0,   // v4.3 — pool QVAPAY real
		'total_pirates_killed'    => 0,
	);
	$bastionConfig = array(
		'pve_bastion_enabled'                => isset($config['pve_bastion_enabled'])                ? (int) $config['pve_bastion_enabled']                : 0,
		'bastion_enabled'                    => isset($config['bastion_enabled'])                    ? (int) $config['bastion_enabled']                    : 0,
		'bastion_default_name'               => isset($config['bastion_default_name'])               ? $config['bastion_default_name']                     : 'El Bastión de la Alianza',
		'bastion_duration_hours'             => isset($config['bastion_duration_hours'])             ? (int) $config['bastion_duration_hours']             : 48,
		'bastion_registration_hours'         => isset($config['bastion_registration_hours'])         ? (int) $config['bastion_registration_hours']         : 24,
		'bastion_hp_per_member'              => isset($config['bastion_hp_per_member'])              ? (int) $config['bastion_hp_per_member']              : 500000,
		'bastion_hp_min'                     => isset($config['bastion_hp_min'])                     ? (int) $config['bastion_hp_min']                     : 10000000,
		'bastion_min_alliances'              => isset($config['bastion_min_alliances'])              ? (int) $config['bastion_min_alliances']              : 2,
		'bastion_max_alliances'              => isset($config['bastion_max_alliances'])              ? (int) $config['bastion_max_alliances']              : 20,
		'bastion_default_entry_mode'         => isset($config['bastion_default_entry_mode'])         ? $config['bastion_default_entry_mode']               : 'free',
		'bastion_default_entry_cost_ntx'     => isset($config['bastion_default_entry_cost_ntx'])     ? (int) $config['bastion_default_entry_cost_ntx']     : 50,
		'bastion_default_prize_type'         => isset($config['bastion_default_prize_type'])         ? $config['bastion_default_prize_type']               : 'ntx',
		'bastion_default_prize_ntx'          => isset($config['bastion_default_prize_ntx'])          ? (int) $config['bastion_default_prize_ntx']          : 500,
		'bastion_default_prize_metal'        => isset($config['bastion_default_prize_metal'])        ? (int) $config['bastion_default_prize_metal']        : 100000000,
		'bastion_default_prize_crystal'      => isset($config['bastion_default_prize_crystal'])      ? (int) $config['bastion_default_prize_crystal']      : 50000000,
		'bastion_default_prize_deuterium'    => isset($config['bastion_default_prize_deuterium'])    ? (int) $config['bastion_default_prize_deuterium']    : 20000000,
		'bastion_default_prize_dark_matter'  => isset($config['bastion_default_prize_dark_matter'])  ? (int) $config['bastion_default_prize_dark_matter']  : 50000,
		'bastion_project_fee_pct'            => isset($config['bastion_project_fee_pct'])            ? (int) $config['bastion_project_fee_pct']            : 5,
		'bastion_winner_distribution'        => isset($config['bastion_winner_distribution'])        ? $config['bastion_winner_distribution']              : 'by_contribution',
		'bastion_score_per_pirate'           => isset($config['bastion_score_per_pirate'])           ? (int) $config['bastion_score_per_pirate']           : 100,
		'bastion_score_hp_pct_weight'        => isset($config['bastion_score_hp_pct_weight'])        ? (int) $config['bastion_score_hp_pct_weight']        : 50,
		'bastion_score_per_boss_pirate'      => isset($config['bastion_score_per_boss_pirate'])      ? (int) $config['bastion_score_per_boss_pirate']      : 500,
		'bastion_refund_on_cancel'           => isset($config['bastion_refund_on_cancel'])           ? (int) $config['bastion_refund_on_cancel']           : 1,
		'bastion_refund_if_min_not_reached'  => isset($config['bastion_refund_if_min_not_reached'])  ? (int) $config['bastion_refund_if_min_not_reached']  : 1,
		'bastion_ships_return_on_end'        => isset($config['bastion_ships_return_on_end'])        ? (int) $config['bastion_ships_return_on_end']        : 1,
		'bastion_phase_calm_end'             => isset($config['bastion_phase_calm_end'])             ? (int) $config['bastion_phase_calm_end']             : 6,
		'bastion_phase_surge_end'            => isset($config['bastion_phase_surge_end'])            ? (int) $config['bastion_phase_surge_end']            : 24,
		'bastion_phase_siege_end'            => isset($config['bastion_phase_siege_end'])            ? (int) $config['bastion_phase_siege_end']            : 40,
		'bastion_wave_interval_calm'         => isset($config['bastion_wave_interval_calm'])         ? (int) $config['bastion_wave_interval_calm']         : 360,
		'bastion_wave_interval_surge'        => isset($config['bastion_wave_interval_surge'])        ? (int) $config['bastion_wave_interval_surge']        : 180,
		'bastion_wave_interval_siege'        => isset($config['bastion_wave_interval_siege'])        ? (int) $config['bastion_wave_interval_siege']        : 120,
		'bastion_wave_interval_hell'         => isset($config['bastion_wave_interval_hell'])         ? (int) $config['bastion_wave_interval_hell']         : 60,
		'bastion_pirate_flight_min'          => isset($config['bastion_pirate_flight_min'])          ? (int) $config['bastion_pirate_flight_min']          : 30,
		'bastion_pirate_flight_max'          => isset($config['bastion_pirate_flight_max'])          ? (int) $config['bastion_pirate_flight_max']          : 90,
		'bastion_pirate_mult_calm'           => isset($config['bastion_pirate_mult_calm'])           ? (int) $config['bastion_pirate_mult_calm']           : 1,
		'bastion_pirate_mult_surge'          => isset($config['bastion_pirate_mult_surge'])          ? (int) $config['bastion_pirate_mult_surge']          : 2,
		'bastion_pirate_mult_siege'          => isset($config['bastion_pirate_mult_siege'])          ? (int) $config['bastion_pirate_mult_siege']          : 4,
		'bastion_pirate_mult_hell'           => isset($config['bastion_pirate_mult_hell'])           ? (int) $config['bastion_pirate_mult_hell']           : 8,
		'bastion_pirate_base_fleet_json'     => isset($config['bastion_pirate_base_fleet_json'])     ? $config['bastion_pirate_base_fleet_json']           : '{"204":100,"205":50,"206":25,"207":10}',
		'bastion_boss_pirate_chance_calm'    => isset($config['bastion_boss_pirate_chance_calm'])    ? (int) $config['bastion_boss_pirate_chance_calm']    : 0,
		'bastion_boss_pirate_chance_surge'   => isset($config['bastion_boss_pirate_chance_surge'])   ? (int) $config['bastion_boss_pirate_chance_surge']   : 10,
		'bastion_boss_pirate_chance_siege'   => isset($config['bastion_boss_pirate_chance_siege'])   ? (int) $config['bastion_boss_pirate_chance_siege']   : 20,
		'bastion_boss_pirate_chance_hell'    => isset($config['bastion_boss_pirate_chance_hell'])    ? (int) $config['bastion_boss_pirate_chance_hell']    : 35,
		'bastion_boss_pirate_fleet_json'     => isset($config['bastion_boss_pirate_fleet_json'])     ? $config['bastion_boss_pirate_fleet_json']           : '{"204":500,"205":200,"211":50,"213":20}',
		'bastion_ranking_live_interval'      => isset($config['bastion_ranking_live_interval'])      ? (int) $config['bastion_ranking_live_interval']      : 10,
		'bastion_ranking_top_show'           => isset($config['bastion_ranking_top_show'])           ? (int) $config['bastion_ranking_top_show']           : 20,
	);

	if (class_exists('PVEBastionHelper')) {
		try {
			// ★ v4.1 FIX — Solo evento ACTIVO. Sin fallback.
			$bastionEvent = PVEBastionHelper::getActiveEvent();

			if (!empty($bastionEvent['id'])) {
				// Registrations
				$bastionRegistrations = $db->select(
					"SELECT r.*, a.ally_name, a.ally_tag
					 FROM %%PVE_BASTION_REGISTRATIONS%% r
					 LEFT JOIN %%ALLIANCE%% a ON a.id = r.ally_id
					 WHERE r.event_id = :eid
					 ORDER BY r.score_total DESC, r.pct_hp_preserved DESC
					 LIMIT 30;",
					array(':eid' => (int) $bastionEvent['id'])
				);
				if (!is_array($bastionRegistrations)) $bastionRegistrations = array();

				// Bastiones (fantasmas aliados)
				$bastionGhosts = $db->select(
					"SELECT g.*, a.ally_name AS ally_name
					 FROM %%PVE_BASTION_GHOSTS%% g
					 LEFT JOIN %%ALLIANCE%% a ON a.id = g.ally_id
					 WHERE g.event_id = :eid
					 ORDER BY g.spawned_at DESC
					 LIMIT 50;",
					array(':eid' => (int) $bastionEvent['id'])
				);
				if (!is_array($bastionGhosts)) $bastionGhosts = array();

				// Oleadas (últimas 40)
				$bastionWaves = $db->select(
					"SELECT w.*, a.ally_name AS ally_name
					 FROM %%PVE_BASTION_WAVES%% w
					 LEFT JOIN %%ALLIANCE%% a ON a.id = w.ally_id
					 WHERE w.event_id = :eid
					 ORDER BY w.spawn_time DESC
					 LIMIT 40;",
					array(':eid' => (int) $bastionEvent['id'])
				);
				if (!is_array($bastionWaves)) $bastionWaves = array();

				// Ranking
				$bastionRanking = PVEBastionHelper::getLiveRanking((int) $bastionEvent['id']);
				if (!is_array($bastionRanking)) $bastionRanking = array();
			}

			// Stats globales (siempre)
			$bastionStats['total_events']        = (int) $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_BASTION_EVENT%%;", array(), 'c');
			$bastionStats['total_events_active'] = (int) $db->selectSingle("SELECT COUNT(*) AS c FROM %%PVE_BASTION_EVENT%% WHERE status = 'active';", array(), 'c');

			// ★ v4.2 FIX — Solo bastiones de eventos VIVOS (scheduled/registration/active)
			$bastionStats['total_bastions'] = (int) $db->selectSingle(
				"SELECT COUNT(*) AS c
				 FROM %%PVE_BASTION_GHOSTS%% g
				 INNER JOIN %%PVE_BASTION_EVENT%% e ON e.id = g.event_id
				 WHERE e.status IN ('scheduled','registration','active')
				   AND g.status = 'active';",
				array(), 'c'
			);

			// ★ v4.2 FIX — Solo caídos en eventos VIVOS
			$bastionStats['total_bastions_breached'] = (int) $db->selectSingle(
				"SELECT COUNT(*) AS c
				 FROM %%PVE_BASTION_GHOSTS%% g
				 INNER JOIN %%PVE_BASTION_EVENT%% e ON e.id = g.event_id
				 WHERE e.status IN ('scheduled','registration','active')
				   AND g.status = 'breached';",
				array(), 'c'
			);

			// v4.3 — Pools duales reales
			$bastionStats['total_pool_ntx']        = (int) $db->selectSingle("SELECT COALESCE(SUM(total_pool_ntx), 0) AS c FROM %%PVE_BASTION_EVENT%%;", array(), 'c');
			$bastionStats['total_pool_ntx20']      = (int) $db->selectSingle("SELECT COALESCE(SUM(pool_ntx20), 0)  AS c FROM %%PVE_BASTION_EVENT%%;", array(), 'c');
			$bastionStats['total_pool_untx20']     = (int) $db->selectSingle("SELECT COALESCE(SUM(pool_untx20), 0) AS c FROM %%PVE_BASTION_EVENT%%;", array(), 'c');
			$bastionStats['total_pirates_killed']  = (int) $db->selectSingle("SELECT COALESCE(SUM(total_pirates_killed), 0) AS c FROM %%PVE_BASTION_EVENT%%;", array(), 'c');
		} catch (Throwable $e) {
			// Silencioso — probablemente tablas no creadas
		}
	}

	// ============================================
	// CATÁLOGO DE NAVES Y DEFENSAS (con nombres reales)
	// ============================================
	// 🔧 v3.2 — Usar $LNG['tech'][$id] en lugar de $pricelist[$id]['name']
	//          (ese último NO existe en 2Moons y caía al fallback "Nave #207")
	global $resource, $pricelist;
	$shipsCatalog    = array();
	$defensesCatalog = array();

	if (is_array($resource) && is_array($pricelist)) {
		foreach ($resource as $id => $colName) {
			$id = (int) $id;

			// Nombre real: prioridad $LNG['tech'] > $pricelist['name'] > fallback
			$techName = '';
			if (isset($LNG['tech'][$id]) && trim((string) $LNG['tech'][$id]) !== '') {
				$techName = $LNG['tech'][$id];
			} elseif (isset($pricelist[$id]['name']) && trim((string) $pricelist[$id]['name']) !== '') {
				$techName = $pricelist[$id]['name'];
			}

			if ($id >= 200 && $id <= 399) {
				$shipsCatalog[$id] = array(
					'id'   => $id,
					'name' => $techName !== '' ? $techName : ('Nave #' . $id),
					'col'  => $colName,
				);
			}
			if ($id >= 400 && $id <= 499) {
				$defensesCatalog[$id] = array(
					'id'   => $id,
					'name' => $techName !== '' ? $techName : ('Defensa #' . $id),
					'col'  => $colName,
				);
			}
		}
	}

	// ============================================
	// ASIGNAR VARIABLES Y MOSTRAR
	// ============================================
	$template->assign_vars(array(
		'config'          => $config,
		'rewards_config'  => $rewardsConfig,
		'crisis_list'     => $crisisList,
		'empires'         => $empires,
		'history'         => $history,
		'stats'           => $stats,
		'message'         => $message,
		'msgType'         => $msgType,
		'factions'        => PVECrisisHelper::FACTIONS,
		'templates_list'  => $templatesList,
		'edit_template'   => $editTemplate,
		'edit_mode'       => $editMode,
		'ships_catalog'   => $shipsCatalog,
		'defenses_catalog'=> $defensesCatalog,
		'active_tab'      => $tab,

		// v3.4 — Torneo del Devorador
		'boss_event'         => $bossEvent,
		'boss_registrations' => $bossRegistrations,
		'boss_ghosts'        => $bossGhosts,
		'boss_ranking'       => $bossRanking,
		'boss_stats'         => $bossStats,
		'boss_config'        => $bossConfig,
		'boss_helper_ok'     => class_exists('PVEBossTournamentHelper') ? 1 : 0,

		// 🆕 v3.5 — Auto-programación
		'boss_schedule'        => $bossSchedule,
		'crisis_auto_schedule' => $crisisAutoSchedule,

		// 🆕 v4.0 — Bastión Asediado
		'bastion_event'          => $bastionEvent,
		'bastion_registrations'  => $bastionRegistrations,
		'bastion_ghosts'         => $bastionGhosts,
		'bastion_waves'          => $bastionWaves,
		'bastion_ranking'        => $bastionRanking,
		'bastion_stats'          => $bastionStats,
		'bastion_config'         => $bastionConfig,
		'bastion_schedule'       => $bastionSchedule,
		'bastion_helper_ok'      => class_exists('PVEBastionHelper') ? 1 : 0,
	));

	$template->show("pveAdminPage.tpl");
}