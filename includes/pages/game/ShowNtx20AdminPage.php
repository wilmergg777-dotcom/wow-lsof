<?php

/**
 * ShowNtx20Admin — Auditoria de NTX-20 (panel admin)
 * AstroIO 2026
 *
 * v1.0 — Dashboard + por jugador + por tipo + historial
 * v1.1 — Agregadas acciones POST:
 *          · saveRetention → guarda meses de retención
 *          · clearAll      → borra TODOS los logs (con confirmación)
 *          · cleanupNow    → ejecuta limpieza manual
 *        + variables al template (retentionMonths, logStats, flashMessage, flashType)
 *
 * v1.2 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Carga PVEHelper para detectar el riel del jugador seleccionado.
 *   · Inyecta 'userMethod' (CUP/QVAPAY) y 'userMoneda' (NTX-20/UNTX-20) al template.
 *   · Inyecta 'isQvapay' (bool) para que el template pueda mostrar una alerta
 *     indicando que el historial de NTX-20 no aplica a jugadores QVAPAY.
 *   · No se cambia la lógica de logs (NTX20LogHelper solo loguea CUP).
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

function ShowNtx20Admin()
{
    global $USER;

    $db     = Database::get();
    $prefix = DB_PREFIX;

    // Cargar Helpers
    require_once ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php';
    
    // ✅ v1.2 — Cargar PVEHelper para detectar el riel
    if (!class_exists('PVEHelper')) {
        require_once ROOT_PATH . 'includes/classes/PVEHelper.class.php';
    }

    // ═══════════════════════════════════════════════
    // 🆕 ACCIONES DE MANTENIMIENTO (POST)
    // ═══════════════════════════════════════════════

    $flashMessage = '';
    $flashType    = 'info';

    // ── Guardar meses de retención ──
    if (isset($_POST['action']) && $_POST['action'] === 'saveRetention') {
        $months = isset($_POST['retention_months']) ? (int) $_POST['retention_months'] : 3;

        // Validar que sea uno de los permitidos
        $allowed = [0, 1, 2, 3, 6, 12, 24];
        if (!in_array($months, $allowed, true)) {
            $months = 3;
        }

        if (NTX20LogHelper::setRetentionMonths($months)) {
            $flashMessage = '✅ Configuración guardada. Los logs se limpiarán automáticamente.';
            $flashType    = 'success';
        } else {
            $flashMessage = '❌ Error al guardar la configuración.';
            $flashType    = 'error';
        }
    }

    // ── Limpiar TODOS los logs ──
    if (isset($_POST['action']) && $_POST['action'] === 'clearAll') {
        // Confirmación obligatoria
        $confirm = isset($_POST['confirm_text']) ? trim($_POST['confirm_text']) : '';

        if ($confirm !== 'BORRAR TODO') {
            $flashMessage = '❌ Debes escribir exactamente "BORRAR TODO" para confirmar.';
            $flashType    = 'error';
        } else {
            $deleted = NTX20LogHelper::clearAllLogs();

            if ($deleted >= 0) {
                $flashMessage = '🗑️ Se borraron ' . number_format($deleted) . ' registros del log.';
                $flashType    = 'success';
            } else {
                $flashMessage = '❌ Error al borrar los logs.';
                $flashType    = 'error';
            }
        }
    }

    // ── Limpieza manual de logs viejos ──
    if (isset($_POST['action']) && $_POST['action'] === 'cleanupNow') {
        $deleted = NTX20LogHelper::cleanupOldLogs();

        $flashMessage = '🔄 Limpieza ejecutada: se borraron ' . number_format($deleted) . ' registros viejos.';
        $flashType    = 'success';
    }

    // ═══════════════════════════════════════════════
    // PARÁMETROS DE FILTRADO
    // ═══════════════════════════════════════════════

    $selectedUser = isset($_GET['user_id'])  ? (int)    $_GET['user_id']  : 0;
    $filterType   = isset($_GET['type'])     ? (string) $_GET['type']     : '';
    $filterDir    = isset($_GET['direction'])? (string) $_GET['direction']: '';
    $filterDays   = isset($_GET['days'])     ? (int)    $_GET['days']     : 0;
    $page         = isset($_GET['page_num']) ? max(1, (int) $_GET['page_num']) : 1;

    // Si no hay usuario seleccionado, tomar el primero de la lista
    $userList = NTX20LogHelper::getUserList();
    if ($selectedUser <= 0 && !empty($userList)) {
        $selectedUser = (int) $userList[0]['id'];
    }

    // ═══ DATOS DEL JUGADOR ═══
    $userData = null;
    if ($selectedUser > 0) {
        $userData = NTX20LogHelper::getUserData($selectedUser);
    }

    // ✅ v1.2 — Detectar el riel del jugador seleccionado
    $userMethod = 'CUP';
    $userMoneda = 'NTX-20';
    $isQvapay   = 0;

    if ($selectedUser > 0 && class_exists('PVEHelper')) {
        try {
            $userMethod = PVEHelper::getPlayerMethod($selectedUser);
            $userMoneda = PVEHelper::getCurrencyLabel($selectedUser);
            $isQvapay   = ($userMethod === 'QVAPAY') ? 1 : 0;
        } catch (Throwable $e) {
            // Fail-safe a CUP
        }
    }

    // Rango de fechas
    $fromTs = 0;
    $toTs   = 0;
    if ($filterDays > 0) {
        $fromTs = TIMESTAMP - ($filterDays * 86400);
    }

    $filters = [
        'type'      => $filterType,
        'direction' => $filterDir,
        'from_ts'   => $fromTs,
        'to_ts'     => $toTs,
    ];

    // ═══ STATS + HISTORIAL ═══
    $stats      = ['total_spent'=>0, 'total_earned'=>0, 'balance'=>0, 'total_movements'=>0];
    $history    = [];
    $totalRows  = 0;
    $totalPages = 1;

    if ($userData) {
        $stats = NTX20LogHelper::getUserStats($selectedUser, $fromTs, $toTs);

        $perPage    = 50;
        $offset     = ($page - 1) * $perPage;
        $history    = NTX20LogHelper::getUserHistory($selectedUser, $filters, $perPage, $offset);
        $totalRows  = NTX20LogHelper::getUserHistoryCount($selectedUser, $filters);
        $totalPages = max(1, ceil($totalRows / $perPage));
    }

    // ═══ ENRIQUECER DATOS ═══
    foreach ($history as &$row) {
        $row['label']       = NTX20LogHelper::getTypeLabel($row['type']);
        $row['icon']        = NTX20LogHelper::getTypeIcon($row['type']);
        $row['date']        = date('d/m/Y H:i', (int) $row['timestamp']);
        $row['amount_abs']  = abs((int) $row['amount']);
        $row['amount_fmt']  = number_format(abs((int) $row['amount']), 0, ',', '.');
        $row['balance_fmt'] = number_format((int) $row['balance_after'], 0, ',', '.');
        $row['is_spend']    = ((int) $row['amount'] < 0) ? 1 : 0;
        $row['sign']        = ((int) $row['amount'] < 0) ? '-' : '+';

        // IP legible
        $row['ip_legible'] = '';
        if (!empty($row['ip'])) {
            $ipRead = @inet_ntop($row['ip']);
            if ($ipRead !== false) {
                $row['ip_legible'] = $ipRead;
            }
        }
    }
    unset($row);

    // Formatear stats
    $stats['total_spent_fmt']  = number_format($stats['total_spent'],  0, ',', '.');
    $stats['total_earned_fmt'] = number_format($stats['total_earned'], 0, ',', '.');
    $stats['balance_fmt']      = number_format($stats['balance'], 0, ',', '.');

    // ═══ LISTA DE TIPOS PARA EL SELECT ═══
    $typesRaw = NTX20LogHelper::getAllTypes();
    $typesList = [];
    foreach ($typesRaw as $t) {
        $typesList[] = [
            'value' => $t,
            'label' => NTX20LogHelper::getTypeLabel($t),
            'icon'  => NTX20LogHelper::getTypeIcon($t),
        ];
    }

    // ═══════════════════════════════════════════════
    // 🆕 DATOS DE RETENCIÓN Y STATS DEL LOG
    // ═══════════════════════════════════════════════

    $retentionMonths = NTX20LogHelper::getRetentionMonths();
    $logStats        = NTX20LogHelper::getLogStats();

    // Formatear el tamaño del log
    $logStats['size_mb'] = (string) $logStats['size_mb'];

    // ═══ RENDER ═══
    $template = new Template();
    $template->assign_vars([
        'userList'     => $userList,
        'selectedUser' => $selectedUser,
        'userData'     => $userData,
        'stats'        => $stats,
        'history'      => $history,
        'typesList'    => $typesList,
        'filterType'   => $filterType,
        'filterDir'    => $filterDir,
        'filterDays'   => $filterDays,
        'page'         => $page,
        'totalPages'   => $totalPages,
        'totalRows'    => $totalRows,

        // 🆕 v1.1 — Config de retención + stats + mensajes flash
        'retentionMonths' => $retentionMonths,
        'logStats'        => $logStats,
        'flashMessage'    => $flashMessage,
        'flashType'       => $flashType,

        // ✅ v1.2 — Datos del Riel del jugador
        'userMethod'   => $userMethod,
        'userMoneda'   => $userMoneda,
        'isQvapay'     => $isQvapay,
    ]);

    $template->show('ntx20AdminPage.tpl');
}