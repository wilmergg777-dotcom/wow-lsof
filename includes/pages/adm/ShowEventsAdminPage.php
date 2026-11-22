<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ============================================
 *  ASTROIO - Panel Admin de Eventos
 *  Archivo: includes/pages/adm/ShowEventsAdminPage.php
 * ============================================
 */
 
if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) throw new Exception("Permission error!");

function ShowEventsAdmin()
{
	global $LNG;
	
	$template	= new template();
	$db			= Database::get();
	$action		= HTTP::_GP('action', '');
	
	$message	= '';
	$msgType	= 'info';
	
	// ============================================
	// PREFIJO DE TABLAS
	// ============================================
	$prefix = 'uni1_';
	if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
	elseif (defined('PREFIX')) $prefix = PREFIX;
	
	// ============================================
	// ACCIONES (crear / editar / borrar / toggle)
	// ============================================
	
	// ---------- CREAR ----------
	if ($action == 'create') {
		$name        = trim(HTTP::_GP('event_name', ''));
		$desc        = trim(HTTP::_GP('event_desc', ''));
		$icon        = trim(HTTP::_GP('event_icon', 'ATK'));
		$color       = trim(HTTP::_GP('event_color', '#00ccff'));
		$type        = trim(HTTP::_GP('event_type', 'destroy_units'));
		$target      = (int) HTTP::_GP('event_target_value', 0);
		$targetRef   = (int) HTTP::_GP('event_target_ref', 0);
		$rewardType  = trim(HTTP::_GP('reward_type', 'metal'));
		$rewardValue = (int) HTTP::_GP('reward_value', 0);
		$class       = trim(HTTP::_GP('event_class', 'admin'));
		$active      = (int) HTTP::_GP('active', 0);
		
		// Validación: si el tipo no es de naves o investigaciones, forzar objetivo a Global (0)
		if (!in_array($type, array('destroy_units', 'build_ships', 'research_techs'))) {
			$targetRef = 0;
		}
		
		if ($name === '' || $desc === '' || $target <= 0 || $rewardValue <= 0) {
			$message = '❌ Rellena todos los campos correctamente (target y reward > 0).';
			$msgType = 'error';
		} else {
			$db->insert(
				"INSERT INTO `".$prefix."events` 
				 (event_name, event_desc, event_icon, event_color, event_type, 
				  event_target_value, event_target_ref, reward_type, reward_value, event_class, 
				  start_date, end_date, active, created_by)
				 VALUES 
				 (:name, :desc, :icon, :color, :type, 
				  :target, :tref, :rtype, :rvalue, :class, 
				  0, 0, :active, 0);",
				array(
					':name'   => $name,
					':desc'   => $desc,
					':icon'   => $icon,
					':color'  => $color,
					':type'   => $type,
					':target' => $target,
					':tref'   => $targetRef,
					':rtype'  => $rewardType,
					':rvalue' => $rewardValue,
					':class'  => $class,
					':active' => $active,
				)
			);
			$message = '✅ Evento <strong>'.$name.'</strong> creado correctamente.';
			$msgType = 'success';
		}
	}
	
	// ---------- EDITAR ----------
	if ($action == 'update') {
		$eventId     = (int) HTTP::_GP('event_id', 0);
		$name        = trim(HTTP::_GP('event_name', ''));
		$desc        = trim(HTTP::_GP('event_desc', ''));
		$icon        = trim(HTTP::_GP('event_icon', 'ATK'));
		$color       = trim(HTTP::_GP('event_color', '#00ccff'));
		$type        = trim(HTTP::_GP('event_type', 'destroy_units'));
		$target      = (int) HTTP::_GP('event_target_value', 0);
		$targetRef   = (int) HTTP::_GP('event_target_ref', 0);
		$rewardType  = trim(HTTP::_GP('reward_type', 'metal'));
		$rewardValue = (int) HTTP::_GP('reward_value', 0);
		$class       = trim(HTTP::_GP('event_class', 'admin'));
		$active      = (int) HTTP::_GP('active', 0);
		
		// Validación: si el tipo no es de naves o investigaciones, forzar objetivo a Global (0)
		if (!in_array($type, array('destroy_units', 'build_ships', 'research_techs'))) {
			$targetRef = 0;
		}
		
		if ($eventId <= 0 || $name === '' || $target <= 0 || $rewardValue <= 0) {
			$message = '❌ Datos inválidos para editar.';
			$msgType = 'error';
		} else {
			$db->update(
				"UPDATE `".$prefix."events` SET
				 event_name = :name,
				 event_desc = :desc,
				 event_icon = :icon,
				 event_color = :color,
				 event_type = :type,
				 event_target_value = :target,
				 event_target_ref = :tref,
				 reward_type = :rtype,
				 reward_value = :rvalue,
				 event_class = :class,
				 active = :active
				 WHERE event_id = :eid;",
				array(
					':name'   => $name,
					':desc'   => $desc,
					':icon'   => $icon,
					':color'  => $color,
					':type'   => $type,
					':target' => $target,
					':tref'   => $targetRef,
					':rtype'  => $rewardType,
					':rvalue' => $rewardValue,
					':class'  => $class,
					':active' => $active,
					':eid'    => $eventId,
				)
			);
			$message = '✅ Evento <strong>#'.$eventId.'</strong> actualizado.';
			$msgType = 'success';
		}
	}
	
	// ---------- BORRAR ----------
	if ($action == 'delete') {
		$eventId = (int) HTTP::_GP('event_id', 0);
		
		if ($eventId > 0) {
			$db->delete(
				"DELETE FROM `".$prefix."events` WHERE event_id = :eid;",
				array(':eid' => $eventId)
			);
			$db->delete(
				"DELETE FROM `".$prefix."users_events` WHERE event_id = :eid;",
				array(':eid' => $eventId)
			);
			$message = '✅ Evento <strong>#'.$eventId.'</strong> y sus progresos borrados.';
			$msgType = 'success';
		}
	}
	
	// ---------- TOGGLE (activar/desactivar) ----------
	if ($action == 'toggle') {
		$eventId = (int) HTTP::_GP('event_id', 0);
		
		if ($eventId > 0) {
			$db->update(
				"UPDATE `".$prefix."events` 
				 SET active = 1 - active 
				 WHERE event_id = :eid;",
				array(':eid' => $eventId)
			);
			$message = '✅ Estado del evento <strong>#'.$eventId.'</strong> cambiado.';
			$msgType = 'success';
		}
	}
	
	// ---------- RESET progreso de todos los jugadores ----------
	if ($action == 'reset_progress') {
		$eventId = (int) HTTP::_GP('event_id', 0);
		
		if ($eventId > 0) {
			$db->delete(
				"DELETE FROM `".$prefix."users_events` WHERE event_id = :eid;",
				array(':eid' => $eventId)
			);
			$message = '✅ Progreso de todos los jugadores reseteado para el evento <strong>#'.$eventId.'</strong>.';
			$msgType = 'success';
		}
	}
	
	// ============================================
	// CARGAR DATOS PARA LA VISTA
	// ============================================
	
	// Si hay edición, cargar el evento a editar
	$editId = (int) HTTP::_GP('edit', 0);
	$editing = null;
	if ($editId > 0) {
		$editing = $db->selectSingle(
			"SELECT * FROM `".$prefix."events` WHERE event_id = :eid;",
			array(':eid' => $editId)
		);
	}
	
	// Lista completa de eventos
	$events = $db->select(
		"SELECT * FROM `".$prefix."events` 
		 ORDER BY 
		   FIELD(event_class, 'daily', 'weekly', 'elite', 'admin'),
		   event_id ASC;"
	);
	if (!is_array($events)) $events = array();
	
	// Estadísticas de progreso (cuántos jugadores han reclamado)
	$stats = array();
	$statsRows = $db->select(
		"SELECT event_id, 
		        COUNT(*) as total_started,
		        SUM(CASE WHEN claimed = 1 THEN 1 ELSE 0 END) as total_claimed
		 FROM `".$prefix."users_events` 
		 GROUP BY event_id;"
	);
	if (is_array($statsRows)) {
		foreach ($statsRows as $s) {
			$stats[(int)$s['event_id']] = array(
				'started' => (int)$s['total_started'],
				'claimed' => (int)$s['total_claimed'],
			);
		}
	}
	
	// Iconos emoji
	$iconMap = array(
		'ATK'  => '⚔️',
		'REC'  => '♻️',
		'EXP'  => '🧭',
		'RES'  => '💰',
		'SHIP' => '🚀',
		'TEC'  => '🔬',
		'ELT'  => '👑',
	);
	
	foreach ($events as &$e) {
		$e['icon_emoji'] = isset($iconMap[$e['event_icon']]) ? $iconMap[$e['event_icon']] : '🎯';
		$e['stats']      = isset($stats[(int)$e['event_id']]) ? $stats[(int)$e['event_id']] : array('started' => 0, 'claimed' => 0);
	}
	unset($e);
	
	if ($editing) {
		$editing['icon_emoji'] = isset($iconMap[$editing['event_icon']]) ? $iconMap[$editing['event_icon']] : '🎯';
	}
	
	// Tipos de eventos disponibles
	$eventTypes = array(
		'destroy_units'    => '⚔️ Destruir unidades',
		'recycle_debris'   => '♻️ Reciclar escombros',
		'expeditions'      => '🧭 Expediciones',
		'get_resources'    => '💰 Conseguir recursos',
		'build_ships'      => '🚀 Construir naves',
		'research_techs'   => '🔬 Investigar tecnologías',
		'recycle_asteroid' => '☄️ Reciclar asteroides', // <--- LÍNEA AÑADIDA
	);
	
	// Tipos de recompensa permitidos
	$rewardTypes = array(
		'metal'      => '🪙 Metal',
		'crystal'    => '💎 Cristal',
		'deuterium'  => '🧪 Deuterio',
		'containers' => '📦 Contenedores',
	);
	
	// Clases de evento
	$eventClasses = array(
		'daily'  => '📅 Diario',
		'weekly' => '📆 Semanal',
		'elite'  => '👑 Élite',
		'admin'  => '🛠️ Admin',
	);
	
	$template->assign_vars(array(
		'events'        => $events,
		'editing'       => $editing,
		'eventTypes'    => $eventTypes,
		'rewardTypes'   => $rewardTypes,
		'eventClasses'  => $eventClasses,
		'message'       => $message,
		'msgType'       => $msgType,
	));
	
	$template->show("eventsAdminPage.tpl");
}