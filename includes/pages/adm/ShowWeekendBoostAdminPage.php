<?php
/**
 * ShowWeekendBoostAdminPage.php
 * -------------------------------------------------------------------
 * AstroIO 2026 - Panel admin del Boost de Fin de Semana
 * -------------------------------------------------------------------
 * v3 CORREGIDO — Añade has_missing calculado en PHP
 *
 * v4 CORREGIDO (FIX DESACTIVACIÓN AUTOMÁTICA):
 *   - Al guardar la config, se aplica el estado AL INSTANTE
 *     llamando a WeekendBoostHelper::checkAndApply(true)
 *   - Antes: al desactivar desde el panel, las velocidades seguían
 *     boosteadas hasta que el cron corriera (5 min) y encima se
 *     quedaba atascado
 *   - Ahora: al guardar, se aplica el cambio inmediatamente
 * -------------------------------------------------------------------
 */

if (!defined('INSIDE') && !defined('MODE')) {
    die('Hacking attempt');
}

function ShowWeekendBoostAdmin()
{
    global $LNG, $USER;

    require_once ROOT_PATH . 'includes/classes/WeekendBoostHelper.class.php';

    $db      = Database::get();
    $message = '';
    $error   = '';

    // ═══════════════════════════════════════════════════════════════
    // PROCESAR ACCIONES POST
    // ═══════════════════════════════════════════════════════════════
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {

        $action = (string) $_POST['action'];

        // ── Guardar configuración ──
        if ($action === 'save') {
            try {
                WeekendBoostHelper::saveConfig([
                    'enabled'                   => isset($_POST['enabled']) ? 1 : 0,
                    'start_day'                 => (int)   ($_POST['start_day']                 ?? 5),
                    'start_hour'                => (int)   ($_POST['start_hour']                ?? 0),
                    'end_day'                   => (int)   ($_POST['end_day']                   ?? 0),
                    'end_hour'                  => (int)   ($_POST['end_hour']                  ?? 23),
                    'normal_game_speed'         => (float) ($_POST['normal_game_speed']         ?? 1),
                    'normal_fleet_speed'        => (float) ($_POST['normal_fleet_speed']        ?? 1),
                    'normal_production_speed'   => (float) ($_POST['normal_production_speed']   ?? 1),
                    'normal_storage_speed'      => (float) ($_POST['normal_storage_speed']      ?? 1),
                    'normal_expedition_factor'  => (float) ($_POST['normal_expedition_factor']  ?? 1),
                    'normal_energy_factor'      => (float) ($_POST['normal_energy_factor']      ?? 1),
                    'weekend_game_speed'        => (float) ($_POST['weekend_game_speed']        ?? 2),
                    'weekend_fleet_speed'       => (float) ($_POST['weekend_fleet_speed']       ?? 2),
                    'weekend_production_speed'  => (float) ($_POST['weekend_production_speed']  ?? 2),
                    'weekend_storage_speed'     => (float) ($_POST['weekend_storage_speed']     ?? 2),
                    'weekend_expedition_factor' => (float) ($_POST['weekend_expedition_factor'] ?? 3),
                    'weekend_energy_factor'     => (float) ($_POST['weekend_energy_factor']     ?? 2),
                ]);

                // ✅ FIX v4: aplicar el estado AL INSTANTE tras guardar
                // Esto hace que si desactivas el sistema desde el panel,
                // las velocidades vuelvan a NORMAL inmediatamente
                // (sin esperar los 5 min del cron)
                WeekendBoostHelper::checkAndApply(true);

                $message = '✅ Configuración guardada y aplicada correctamente.';
            } catch (Exception $e) {
                $error = '❌ Error al guardar: ' . $e->getMessage();
            }
        }

        // ── Aplicar estado calculado ──
        elseif ($action === 'apply') {
            try {
                $changed = WeekendBoostHelper::checkAndApply(true);
                if ($changed) {
                    $message = '✅ Estado aplicado correctamente.';
                } else {
                    $message = 'ℹ️ No hubo cambios (ya estaba en el estado correcto).';
                }
            } catch (Exception $e) {
                $error = '❌ Error al aplicar: ' . $e->getMessage();
            }
        }

        // ── Forzar BOOST ──
        elseif ($action === 'force_weekend') {
            try {
                $ok = WeekendBoostHelper::forceState(1);
                if ($ok) {
                    $message = '🎉 Boost de fin de semana aplicado AHORA.';
                } else {
                    $error = '❌ No se pudo aplicar el boost.';
                }
            } catch (Exception $e) {
                $error = '❌ Error: ' . $e->getMessage();
            }
        }

        // ── Forzar NORMAL ──
        elseif ($action === 'force_normal') {
            try {
                $ok = WeekendBoostHelper::forceState(0);
                if ($ok) {
                    $message = '⚪ Modo NORMAL aplicado AHORA.';
                } else {
                    $error = '❌ No se pudo aplicar el modo normal.';
                }
            } catch (Exception $e) {
                $error = '❌ Error: ' . $e->getMessage();
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // CARGAR DATOS PARA LA VISTA
    // ═══════════════════════════════════════════════════════════════
    $config   = WeekendBoostHelper::getConfig(true);
    $diag     = WeekendBoostHelper::diagnose();
    $isWeek   = WeekendBoostHelper::isWeekendNow($config);
    $nextTs   = WeekendBoostHelper::getNextChangeTime($config);
    $nextAct  = WeekendBoostHelper::getNextChangeAction($config);

    $nextStr = $nextTs ? date('D d/m/Y H:i', $nextTs) : '—';
    $nextWhat = $nextAct === 'deactivate' ? 'Volver a NORMAL' : 'Activar BOOST';

    // Valores actuales en uni1_config
    $actuales = WeekendBoostHelper::getCurrentConfigValues();

    // Mapa y labels
    $columnsMap   = WeekendBoostHelper::CFG_COLUMNS;
    $labels       = WeekendBoostHelper::LABELS;
    $realColumns  = WeekendBoostHelper::getRealColumns();

    // Preparar filas de la tabla de valores
    $rowsValues = [];
    $hasMissing = false;   // ✅ CALCULADO EN PHP
    foreach ($columnsMap as $logical => $info) {
        $realCol = $info['col'];
        $factor  = $info['factor'];
        $exists  = in_array($realCol, $realColumns, true);

        if (!$exists) $hasMissing = true;   // ✅ marcar si falta

        $rowsValues[] = [
            'logical' => $logical,
            'real'    => $realCol,
            'label'   => isset($labels[$logical]) ? $labels[$logical] : $logical,
            'normal'  => isset($config['normal_' . $logical])  ? $config['normal_' . $logical]  : 1,
            'weekend' => isset($config['weekend_' . $logical]) ? $config['weekend_' . $logical] : 2,
            'current' => isset($actuales[$realCol]) ? $actuales[$realCol] : '—',
            'exists'  => $exists,
            'factor'  => $factor,
        ];
    }

    // Días
    $days = [
        0 => 'Domingo',
        1 => 'Lunes',
        2 => 'Martes',
        3 => 'Miércoles',
        4 => 'Jueves',
        5 => 'Viernes',
        6 => 'Sábado',
    ];

    // Horas
    $hours = [];
    for ($h = 0; $h <= 23; $h++) {
        $hours[$h] = sprintf('%02d:00', $h);
    }

    // ═══════════════════════════════════════════════════════════════
    // RENDER
    // ═══════════════════════════════════════════════════════════════
    $template = new Template();
    $template->assign_vars([
        'message'          => $message,
        'error'            => $error,
        'cfg'              => $config,
        'rows_values'      => $rowsValues,
        'has_missing'      => $hasMissing,   // ✅ NUEVO
        'is_weekend'       => $isWeek,
        'next_change_time' => $nextStr,
        'next_change_what' => $nextWhat,
        'next_change_raw'  => $nextTs,
        'diag'             => $diag,
        'days'             => $days,
        'hours'            => $hours,
        'start_day_name'   => isset($days[(int) $config['start_day']])
                                ? $days[(int) $config['start_day']] : '?',
        'end_day_name'     => isset($days[(int) $config['end_day']])
                                ? $days[(int) $config['end_day']] : '?',
    ]);

    $template->show('weekendBoostAdminPage.tpl');
}