<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ============================================
 *  ASTROIO - Panel Admin del Sistema de Clima
 *  Archivo: includes/pages/adm/ShowClimasAdminPage.php
 *  Versión: 1.1
 *
 *  Funciones:
 *   - Ver catálogo de los 14 climas (editable inline)
 *   - Activar/Desactivar climas (excepto "despejado")
 *   - Forzar clima a un planeta/luna específico
 *   - Forzar clima a una galaxia entera
 *   - Rotar ahora (ejecuta cron manualmente)
 *   - Predecir ahora (ejecuta predicción manualmente)
 *   - Limpiar huérfanos
 *   - Ver log de rotaciones recientes
 *   - Ver distribución global de climas
 *
 *  v1.1 — FIX: columna correcta es `destruyed` (con "y"), no `destruido`.
 *         Afecta a 4 queries: forzarGalaxia, planetasRecientes, stats.
 * ============================================
 */

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) {
	throw new Exception("Permission error!");
}

function ShowClimasAdmin()
{
	global $LNG;

	$template = new template();
	$db       = Database::get();
	$action   = HTTP::_GP('mode', '');
	$tab      = HTTP::_GP('tab', 'catalogo');

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
	require_once ROOT_PATH . 'includes/classes/ClimaEngine.class.php';
	require_once ROOT_PATH . 'includes/classes/ClimaCron.class.php';

	// ============================================
	// PROCESAR ACCIONES
	// ============================================

	// ─── GUARDAR CLIMA (editar uno del catálogo) ───
	if ($action === 'guardarClima') {
		try {
			$climaId       = (int) HTTP::_GP('clima_id', 0);
			$nombre        = trim((string) HTTP::_GP('nombre', ''));
			$descripcion   = trim((string) HTTP::_GP('descripcion', ''));
			$factorAtaque  = (float) HTTP::_GP('factor_ataque', 1.00);
			$factorDefensa = (float) HTTP::_GP('factor_defensa', 1.00);
			$factorBajas   = (float) HTTP::_GP('factor_bajas', 1.00);
			$factorBotin   = (float) HTTP::_GP('factor_botin', 1.00);
			$peso          = (int) HTTP::_GP('peso', 10);
			$categoria     = (string) HTTP::_GP('categoria', 'medio');
			$activo        = (int) HTTP::_GP('activo', 1);

			// Validaciones
			if ($climaId <= 0) {
				throw new Exception('ID de clima inválido.');
			}
			if ($nombre === '') {
				throw new Exception('El nombre no puede estar vacío.');
			}
			if (!in_array($categoria, array('suave', 'medio', 'raro'), true)) {
				$categoria = 'medio';
			}

			// Validar factores según reglas de oro
			$factores = array(
				'factor_ataque'  => $factorAtaque,
				'factor_defensa' => $factorDefensa,
				'factor_bajas'   => $factorBajas,
				'factor_botin'   => $factorBotin,
			);

			if (!ClimaEngine::validarFactores($factores)) {
				throw new Exception('Factores inválidos. Deben estar entre 0.00 y 3.00, y factor_bajas máximo 1.25.');
			}

			$peso = max(0, min(255, $peso));

			// Si se intenta desactivar "despejado", forzar activo = 1
			$climaActual = ClimaEngine::getClimaInfo($climaId);
			if ($climaActual && $climaActual['clave'] === 'despejado') {
				$activo = 1;
			}

			$db->update(
				"UPDATE `" . $prefix . "climas` SET
					nombre         = :nombre,
					descripcion    = :descripcion,
					factor_ataque  = :factor_ataque,
					factor_defensa = :factor_defensa,
					factor_bajas   = :factor_bajas,
					factor_botin   = :factor_botin,
					peso           = :peso,
					categoria      = :categoria,
					activo         = :activo
				 WHERE id = :id",
				array(
					':nombre'         => $nombre,
					':descripcion'    => $descripcion,
					':factor_ataque'  => $factorAtaque,
					':factor_defensa' => $factorDefensa,
					':factor_bajas'   => $factorBajas,
					':factor_botin'   => $factorBotin,
					':peso'           => $peso,
					':categoria'      => $categoria,
					':activo'         => $activo,
					':id'             => $climaId,
				)
			);

			ClimaEngine::resetCache();

			$message = '✅ Clima #' . $climaId . ' actualizado correctamente.';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'catalogo';
	}

	// ─── TOGGLE ACTIVO/INACTIVO ───
	if ($action === 'toggleClima') {
		try {
			$climaId = (int) HTTP::_GP('clima_id', 0);
			$activo  = (int) HTTP::_GP('activo', 0);

			if ($climaId <= 0) {
				throw new Exception('ID de clima inválido.');
			}

			$clima = ClimaEngine::getClimaInfo($climaId);
			if (!$clima) {
				throw new Exception('Clima no encontrado.');
			}
			if ($clima['clave'] === 'despejado') {
				throw new Exception('No se puede desactivar "Cielo Despejado" (es el neutro de seguridad).');
			}

			$db->update(
				"UPDATE `" . $prefix . "climas` SET activo = :activo WHERE id = :id",
				array(':activo' => $activo, ':id' => $climaId)
			);

			ClimaEngine::resetCache();

			$message = ($activo === 1)
				? '✅ Clima "' . $clima['nombre'] . '" activado.'
				: '⏸️ Clima "' . $clima['nombre'] . '" desactivado. No se volverá a sortear (los asignados actualmente se mantienen hasta la próxima rotación).';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'catalogo';
	}

	// ─── FORZAR CLIMA A UN PLANETA/LUNA ───
	if ($action === 'forzarPlaneta') {
		try {
			$planetaId = (int) HTTP::_GP('planeta_id', 0);
			$climaId   = (int) HTTP::_GP('clima_id', 0);

			if ($planetaId <= 0) {
				throw new Exception('ID de planeta inválido.');
			}
			if ($climaId <= 0) {
				throw new Exception('Debes seleccionar un clima.');
			}

			// Verificar que el planeta existe
			$planeta = $db->selectSingle(
				"SELECT id, name, galaxy, system, planet, planet_type FROM `" . $prefix . "planets` WHERE id = :id LIMIT 1",
				array(':id' => $planetaId)
			);
			if (empty($planeta)) {
				throw new Exception('El planeta/luna #' . $planetaId . ' no existe.');
			}

			$clima = ClimaEngine::getClimaInfo($climaId);
			if (!$clima || (int)$clima['activo'] !== 1) {
				throw new Exception('El clima seleccionado no existe o está desactivado.');
			}

			$adminId = (int) $GLOBALS['USER']['id'];
			$result  = ClimaEngine::forzarClima($planetaId, $climaId, $adminId);

			if (!$result) {
				throw new Exception('No se pudo asignar el clima.');
			}

			$tipoLabel = ((int)$planeta['planet_type'] === 3) ? 'Luna' : 'Planeta';
			$message = '✅ ' . $tipoLabel . ' [' . $planeta['galaxy'] . ':' . $planeta['system'] . ':' . $planeta['planet'] . '] (' . $planeta['name'] . ') forzado al clima "' . $clima['nombre'] . '".';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'forzar';
	}

	// ─── FORZAR CLIMA A UNA GALAXIA ENTERA ───
	if ($action === 'forzarGalaxia') {
		try {
			$galaxia = (int) HTTP::_GP('galaxia', 0);
			$climaId = (int) HTTP::_GP('clima_id', 0);

			if ($galaxia < 1) {
				throw new Exception('Galaxia inválida.');
			}
			if ($climaId <= 0) {
				throw new Exception('Debes seleccionar un clima.');
			}

			$clima = ClimaEngine::getClimaInfo($climaId);
			if (!$clima || (int)$clima['activo'] !== 1) {
				throw new Exception('El clima seleccionado no existe o está desactivado.');
			}

			// Obtener todos los planetas/lunas de esa galaxia
			// ✅ FIX v1.1: destruyed (con "y"), no destruido
			$planetas = $db->select(
				"SELECT id FROM `" . $prefix . "planets` WHERE galaxy = :galaxy AND destruyed = 0",
				array(':galaxy' => $galaxia)
			);
			if (!is_array($planetas)) $planetas = array();

			$afectados = 0;
			$adminId   = (int) $GLOBALS['USER']['id'];

			foreach ($planetas as $p) {
				$pid = (int) $p['id'];
				if ($pid <= 0) continue;

				// Asignación directa (sin log individual para no spamear)
				$db->insert(
					"INSERT INTO `" . $prefix . "clima_planeta`
						(planeta_id, clima_id, fecha_asignacion, fecha_expiracion)
					 VALUES (:pid, :cid, NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR))
					 ON DUPLICATE KEY UPDATE
						clima_id         = VALUES(clima_id),
						fecha_asignacion = VALUES(fecha_asignacion),
						fecha_expiracion = VALUES(fecha_expiracion),
						clima_previsto_id = NULL,
						fecha_prediccion  = NULL",
					array(':pid' => $pid, ':cid' => $climaId)
				);
				$afectados++;
			}

			// Log global
			ClimaEngine::registrarLog('forzado_admin', $afectados, 0, $adminId,
				'Galaxia ' . $galaxia . ' forzada al clima "' . $clima['nombre'] . '" (' . $afectados . ' cuerpos celestes)');

			ClimaEngine::resetCache();

			$message = '✅ Galaxia ' . $galaxia . ' forzada al clima "' . $clima['nombre'] . '". Afectados: ' . $afectados . ' planetas/lunas.';
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'forzar';
	}

	// ─── ROTAR AHORA (ejecuta cron manual) ───
	if ($action === 'rotarAhora') {
		try {
			$result = ClimaCron::rotarTodos();

			$message = '🔄 Rotación ejecutada: <strong>' . (int)$result['afectados'] . '</strong> planetas/lunas afectados en <strong>' . $result['duracion'] . 's</strong>.';
			if (!empty($result['errores'])) {
				$message .= ' Errores: ' . (int)$result['errores'];
			}
			if (!empty($result['error'])) {
				$message .= '<br><small>' . htmlspecialchars($result['error']) . '</small>';
			}
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al rotar: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'acciones';
	}

	// ─── PREDECIR AHORA (ejecuta predicción manual) ───
	if ($action === 'predecirAhora') {
		try {
			$result = ClimaCron::predecirTodos();

			$message = '🔮 Predicción ejecutada: <strong>' . (int)$result['afectados'] . '</strong> planetas/lunas con predicción asignada en <strong>' . $result['duracion'] . 's</strong>.';
			if (!empty($result['errores'])) {
				$message .= ' Errores: ' . (int)$result['errores'];
			}
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error al predecir: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'acciones';
	}

	// ─── LIMPIAR HUÉRFANOS ───
	if ($action === 'limpiarHuerfanos') {
		try {
			$deleted = ClimaEngine::limpiarHuerfanos();

			if ($deleted > 0) {
				$message = '🧹 Limpieza completada: <strong>' . (int)$deleted . '</strong> registros huérfanos borrados.';
			} else {
				$message = '🧹 Limpieza ejecutada. No había huérfanos (todo limpio).';
			}
			$msgType = 'success';
		} catch (Exception $e) {
			$message = '❌ Error: ' . $e->getMessage();
			$msgType = 'error';
		}
		$tab = 'acciones';
	}

	// ============================================
	// CARGAR DATOS PARA LA VISTA
	// ============================================

	// --- Catálogo completo de climas ---
	$catalogoClimas = ClimaEngine::getCatalogoCompleto();
	if (!is_array($catalogoClimas)) $catalogoClimas = array();

	// Enriquecer con emojis (mapeados por clave, NO en BD)
	$emojiMap = array(
		'despejado'      => '☀️',
		'brisa_solar'    => '🌤️',
		'viento_estelar' => '🍃',
		'cristalino'     => '✨',
		'niebla'         => '🌫️',
		'tormenta_solar' => '⚡',
		'meteoros'       => '☄️',
		'nebulosa'       => '💰',
		'plasma'         => '🌌',
		'eclipse'        => '🌓',
		'campo_mag'      => '🌀',
		'aurora'         => '🌈',
		'agujero'        => '🕳️',
		'singularidad'   => '⚫',
	);

	foreach ($catalogoClimas as &$c) {
		$c['emoji']       = isset($emojiMap[$c['clave']]) ? $emojiMap[$c['clave']] : '❓';
		$c['pct_ataque']  = round(($c['factor_ataque']  - 1) * 100);
		$c['pct_defensa'] = round(($c['factor_defensa'] - 1) * 100);
		$c['pct_bajas']   = round(($c['factor_bajas']   - 1) * 100);
		$c['pct_botin']   = round(($c['factor_botin']   - 1) * 100);
	}
	unset($c);

	// --- Distribución global (cuántos planetas tienen cada clima) ---
	$distribucion = ClimaEngine::getEstadisticasGlobales();
	if (!is_array($distribucion)) $distribucion = array();

	$totalClimasActivos = 0;
	foreach ($distribucion as $count) {
		$totalClimasActivos += (int)$count;
	}

	$distribucionEnriquecida = array();
	foreach ($catalogoClimas as $c) {
		$clave = $c['clave'];
		$count = isset($distribucion[$clave]) ? (int)$distribucion[$clave] : 0;
		$pct   = ($totalClimasActivos > 0) ? round(($count / $totalClimasActivos) * 100, 2) : 0;

		$distribucionEnriquecida[] = array(
			'clave'      => $clave,
			'nombre'     => $c['nombre'],
			'emoji'      => $c['emoji'],
			'categoria'  => $c['categoria'],
			'activo'     => $c['activo'],
			'count'      => $count,
			'count_fmt'  => number_format($count),
			'pct'        => $pct,
		);
	}

	// Ordenar por count descendente
	usort($distribucionEnriquecida, function($a, $b) {
		return $b['count'] - $a['count'];
	});

	// --- Log de rotaciones recientes ---
	$logReciente = $db->select(
		"SELECT * FROM `" . $prefix . "clima_log`
		 ORDER BY created_at DESC
		 LIMIT 30"
	);
	if (!is_array($logReciente)) $logReciente = array();

	foreach ($logReciente as &$l) {
		$l['tipo_label'] = array(
			'rotacion'       => '🔄 Rotación',
			'prediccion'     => '🔮 Predicción',
			'forzado_admin'  => '⚡ Forzado Admin',
			'limpieza'       => '🧹 Limpieza',
		)[$l['tipo']] ?? $l['tipo'];
		$l['created_fmt'] = date('d/m/Y H:i:s', strtotime($l['created_at']));
		$l['duracion_fmt'] = number_format((float)$l['duracion_segundos'], 2) . 's';
	}
	unset($l);

	// --- Planetas recientes para el selector (últimos 100 activos) ---
	// ✅ FIX v1.1: destruyed (con "y"), no destruido
	$planetasRecientes = $db->select(
		"SELECT p.id, p.name, p.galaxy, p.system, p.planet, p.planet_type
		 FROM `" . $prefix . "planets` p
		 WHERE p.destruyed = 0
		 ORDER BY p.id DESC
		 LIMIT 100"
	);
	if (!is_array($planetasRecientes)) $planetasRecientes = array();

	foreach ($planetasRecientes as &$p) {
		$tipoLabel = ((int)$p['planet_type'] === 3) ? '🌑 Luna' : '🪐 Planeta';
		$p['label'] = $tipoLabel . ' [' . $p['galaxy'] . ':' . $p['system'] . ':' . $p['planet'] . '] ' . $p['name'] . ' (#' . $p['id'] . ')';
	}
	unset($p);

	// --- Estadísticas rápidas ---
	$stats = array(
		'total_climas'       => count($catalogoClimas),
		'climas_activos'     => 0,
		'total_planetas'     => 0,
		'planetas_sin_clima' => 0,
		'ultima_rotacion'    => null,
	);

	foreach ($catalogoClimas as $c) {
		if ((int)$c['activo'] === 1) $stats['climas_activos']++;
	}

	// ✅ FIX v1.1: destruyed (con "y"), no destruido
	$row = $db->selectSingle(
		"SELECT COUNT(*) AS c FROM `" . $prefix . "planets` WHERE destruyed = 0"
	);
	$stats['total_planetas'] = !empty($row) ? (int)$row['c'] : 0;

	// ✅ FIX v1.1: destruyed (con "y"), no destruido
	$row = $db->selectSingle(
		"SELECT COUNT(*) AS c FROM `" . $prefix . "planets` p
		 LEFT JOIN `" . $prefix . "clima_planeta` cp ON cp.planeta_id = p.id
		 WHERE p.destruyed = 0 AND cp.planeta_id IS NULL"
	);
	$stats['planetas_sin_clima'] = !empty($row) ? (int)$row['c'] : 0;

	$row = $db->selectSingle(
		"SELECT created_at FROM `" . $prefix . "clima_log`
		 WHERE tipo = 'rotacion'
		 ORDER BY created_at DESC LIMIT 1"
	);
	$stats['ultima_rotacion'] = !empty($row) ? date('d/m/Y H:i', strtotime($row['created_at'])) : '—';

	// ============================================
	// ASIGNAR VARIABLES Y MOSTRAR
	// ============================================
	$template->assign_vars(array(
		'catalogo_climas'      => $catalogoClimas,
		'distribucion'         => $distribucionEnriquecida,
		'total_climas_activos' => $totalClimasActivos,
		'log_reciente'         => $logReciente,
		'planetas_recientes'   => $planetasRecientes,
		'stats'                => $stats,
		'message'              => $message,
		'msgType'              => $msgType,
		'active_tab'           => $tab,
	));

	$template->show('climasAdminPage.tpl');
}