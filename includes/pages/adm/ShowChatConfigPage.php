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

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) throw new Exception("Permission error!");

function ShowChatConfigPage()
{
	global $LNG;

	$config = Config::get(Universe::getEmulated());

	// ═══════════════════════════════════════════════════════════
	// ACCIÓN: Vaciar chat completo (borra TODOS los mensajes)
	// Se ejecuta al pulsar el botón "wipe_chat"
	// NO espera al cron. NO filtra por tiempo. Borra TODO.
	//
	// IMPORTANTE: usamos el nombre REAL de la tabla
	// (uni1_chat_messages) porque %%CHAT_MES%% solo lo
	// reemplazan los métodos select()/insert(), NO query()
	// ni nativeQuery().
	// ═══════════════════════════════════════════════════════════
	$wipeResult = null;
	if (isset($_POST['wipe_chat']))
	{
		try {
			// ── Obtener conexión a BD (compatible con varias versiones) ──
			$db = null;
			if (class_exists('Database') && method_exists('Database', 'get')) {
				$db = Database::get();
			} elseif (isset($GLOBALS['DATABASE'])) {
				$db = $GLOBALS['DATABASE'];
			}

			if ($db === null) {
				throw new Exception('No hay conexión a la base de datos disponible.');
			}

			// ── Nombre REAL de la tabla (evita el bug del %%CHAT_MES%%) ──
			$tableName = 'uni1_chat_messages';

			// ── Contar mensajes antes de borrar ──
			$deletedCount = 0;

			// Intento 1: usar el link mysqli directo si está disponible
			if (isset($db->link) && $db->link instanceof mysqli) {
				$res = @$db->link->query("SELECT COUNT(*) AS cnt FROM `" . $tableName . "`");
				if ($res) {
					$row = $res->fetch_assoc();
					if ($row && isset($row['cnt'])) {
						$deletedCount = (int)$row['cnt'];
					}
					$res->free();
				}
			}
			// Intento 2: método selectSingle de 2Moons (SÍ reemplaza %%...%%)
			elseif (method_exists($db, 'selectSingle')) {
				$countRow = @$db->selectSingle("SELECT COUNT(*) as cnt FROM " . $tableName);
				if ($countRow && isset($countRow['cnt'])) {
					$deletedCount = (int)$countRow['cnt'];
				}
			}

			// ── Borrar TODOS los mensajes ──
			$sqlWipe = "DELETE FROM `" . $tableName . "`";
			$executed = false;

			// Intento 1: mysqli directo (lo más fiable)
			if (isset($db->link) && $db->link instanceof mysqli) {
				if ($db->link->query($sqlWipe) === true) {
					$executed = true;
				} else {
					throw new Exception('MySQLi error: ' . $db->link->error);
				}
			}
			// Intento 2: método nativeQuery
			elseif (method_exists($db, 'nativeQuery')) {
				$db->nativeQuery($sqlWipe);
				$executed = true;
			}
			// Intento 3: método query
			elseif (method_exists($db, 'query')) {
				$db->query($sqlWipe);
				$executed = true;
			}
			// Intento 4: método delete
			elseif (method_exists($db, 'delete')) {
				$db->delete($sqlWipe);
				$executed = true;
			}

			if (!$executed) {
				throw new Exception('No hay método disponible para ejecutar el DELETE.');
			}

			// ── Registrar en el log de administración (sin romper si falla) ──
			try {
				$LOG = new Log(3);
				$LOG->target = 3;
				$LOG->old = array('accion' => 'wipe_chat', 'mensajes_antes' => $deletedCount);
				$LOG->new = array('accion' => 'wipe_chat', 'mensajes_borrados' => $deletedCount);
				$LOG->save();
			} catch (Exception $e) {
				// Ignorar: el borrado ya se hizo, no rompemos por un log
			}

			$wipeResult = array(
				'success' => true,
				'count'   => $deletedCount,
			);

		} catch (Exception $e) {
			$wipeResult = array(
				'success' => false,
				'error'   => $e->getMessage(),
			);
		}
	}

	// ═══════════════════════════════════════════════════════════
	// GUARDAR CONFIGURACIÓN (comportamiento original)
	// Solo se ejecuta si NO se pulsó el botón de vaciado
	// ═══════════════════════════════════════════════════════════
	if (!empty($_POST) && !isset($_POST['wipe_chat']))
	{
		$config_before = array(	
			'chat_closed'				=> $config->chat_closed,
			'chat_retention_minutes'	=> isset($config->chat_retention_minutes) ? $config->chat_retention_minutes : 60,
			'chat_allowchan'			=> $config->chat_allowchan,
			'chat_allowmes'				=> $config->chat_allowmes,
			'chat_allowdelmes'			=> $config->chat_allowdelmes,
			'chat_logmessage'			=> $config->chat_logmessage,
			'chat_nickchange'			=> $config->chat_nickchange,
			'chat_botname'				=> $config->chat_botname,
			'chat_channelname'			=> $config->chat_channelname,
		);
		
		$chat_allowchan			= isset($_POST['chat_allowchan']) && $_POST['chat_allowchan'] == 'on' ? 1 : 0;
		$chat_allowmes			= isset($_POST['chat_allowmes']) && $_POST['chat_allowmes'] == 'on' ? 1 : 0;
		$chat_allowdelmes		= isset($_POST['chat_allowdelmes']) && $_POST['chat_allowdelmes'] == 'on' ? 1 : 0;
		$chat_logmessage		= isset($_POST['chat_logmessage']) && $_POST['chat_logmessage'] == 'on' ? 1 : 0;
		$chat_nickchange		= isset($_POST['chat_nickchange']) && $_POST['chat_nickchange'] == 'on' ? 1 : 0;
		$chat_closed			= isset($_POST['chat_closed']) && $_POST['chat_closed'] == 'on' ? 1 : 0;

		// ─── Tiempo de retención de mensajes (en minutos) ───
		$chat_retention_minutes	= (int) HTTP::_GP('chat_retention_minutes', 60);
		if ($chat_retention_minutes < 0)		$chat_retention_minutes = 0;
		if ($chat_retention_minutes > 525600)	$chat_retention_minutes = 525600; // máximo 1 año
		
		$chat_channelname		= HTTP::_GP('chat_channelname', '', true);
		$chat_botname			= HTTP::_GP('chat_botname', '', true);
		
		$config_after = array(	
			'chat_closed'				=> $chat_closed,
			'chat_retention_minutes'	=> $chat_retention_minutes,
			'chat_allowchan'			=> $chat_allowchan,
			'chat_allowmes'				=> $chat_allowmes,
			'chat_allowdelmes'			=> $chat_allowdelmes,
			'chat_logmessage'			=> $chat_logmessage,
			'chat_nickchange'			=> $chat_nickchange,
			'chat_botname'				=> $chat_botname,
			'chat_channelname'			=> $chat_channelname,
		);

		foreach($config_after as $key => $value)
		{
			$config->$key	= $value;
		}
		$config->save();
		
		$LOG = new Log(3);
		$LOG->target = 3;
		$LOG->old = $config_before;
		$LOG->new = $config_after;
		$LOG->save();
	}

	$template	= new template();

	$template->assign_vars(array(
		'chat_closed'				=> $config->chat_closed,
		'chat_retention_minutes'	=> isset($config->chat_retention_minutes) ? $config->chat_retention_minutes : 60,
		'chat_allowchan'			=> $config->chat_allowchan,
		'chat_allowmes'				=> $config->chat_allowmes,
		'chat_logmessage'			=> $config->chat_logmessage,
		'chat_nickchange'			=> $config->chat_nickchange,
		'chat_botname'				=> $config->chat_botname,
		'chat_channelname'			=> $config->chat_channelname,
		'se_server_parameters'		=> $LNG['se_server_parameters'],
		'se_save_parameters'		=> $LNG['se_save_parameters'],
		'ch_closed'					=> $LNG['ch_closed'],
		'ch_allowchan'				=> $LNG['ch_allowchan'],
		'ch_allowmes'				=> $LNG['ch_allowmes'],
		'ch_allowdelmes'			=> $LNG['ch_allowdelmes'],
		'ch_logmessage'				=> $LNG['ch_logmessage'],
		'ch_nickchange'				=> $LNG['ch_nickchange'],
		'ch_botname'				=> $LNG['ch_botname'],
		'ch_channelname'			=> $LNG['ch_channelname'],
		'ch_retention'				=> isset($LNG['ch_retention']) ? $LNG['ch_retention'] : 'Tiempo de retención de mensajes',
		'ch_retention_hint'			=> isset($LNG['ch_retention_hint']) ? $LNG['ch_retention_hint'] : 'Tiempo que un mensaje permanece visible antes de borrarse automáticamente.',
		'wipe_result'				=> $wipeResult,
	));
	
	$template->show('ChatConfigBody.tpl');
}