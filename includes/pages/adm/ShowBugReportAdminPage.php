<?php
/**
 * ShowBugReportAdminPage — Panel de gestión de reportes de bugs (ADMIN)
 * AstroIO v1.0
 *
 * URL: admin.php?page=bugreportadmin
 *
 * Modos:
 *   - show()         → Dashboard con stats
 *   - pendientes()   → Reportes sin revisar
 *   - aceptados()    → Reportes en proceso
 *   - solucionados() → Reportes esperando update
 *   - historial()    → Cancelados + Borrados
 *   - ver()          → Ver detalle de un reporte
 *   - aceptar()      → POST: aceptar reporte
 *   - cancelar()     → POST: cancelar reporte
 *   - solucionar()   → POST: marcar como solucionado
 *   - borrar()       → POST: borrar definitivamente
 */

if (!defined('MODE')) die('Hacking attempt');

require_once ROOT_PATH . 'includes/classes/BugReportHelper.class.php';

function ShowBugReportAdmin()
{
    global $USER, $LNG;

    // Crear instancia de la clase Template
    $template = new Template();

    $action  = isset($_GET['mode']) ? $_GET['mode'] : 'show';
    $adminId = (int)$USER['id'];

    // Inicializar variables por defecto (para el template)
    $msgSuccess = '';
    $msgError   = '';
    $stats      = BugReportHelper::getStats();
    $reportes   = [];
    $reporte    = null;
    $log        = [];

    // Detectar mensajes en la URL
    if (isset($_GET['msg'])) {
        switch ($_GET['msg']) {
            case 'aceptado':
                $msgSuccess = '✅ Reporte aceptado correctamente.';
                break;
            case 'cancelado':
                $msgSuccess = '✅ Reporte cancelado y eliminado.';
                break;
            case 'solucionado':
                $msgSuccess = '✅ Reporte marcado como solucionado.';
                break;
            case 'borrado':
                $msgSuccess = '✅ Reporte borrado del sistema.';
                break;
            case 'error_estado':
                $msgError = '❌ El reporte no está en el estado correcto.';
                break;
            case 'error_motivo':
                $msgError = '❌ El motivo es obligatorio (mínimo 5 caracteres).';
                break;
            case 'error_no_encontrado':
                $msgError = '❌ Reporte no encontrado.';
                break;
            case 'error_general':
                $msgError = '❌ No se pudo completar la acción.';
                break;
        }
    }

    // Procesar acciones POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
        $reportId = isset($_POST['report_id']) ? (int)$_POST['report_id'] : 0;

        switch ($_POST['action']) {
            case 'aceptar':
                $result = BugReportHelper::aceptar($reportId, $adminId);
                if ($result['success']) {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=aceptado');
                } else {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=error_general');
                }
                exit;

            case 'cancelar':
                $motivo = isset($_POST['motivo']) ? trim($_POST['motivo']) : '';
                if (strlen($motivo) < 5) {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=error_motivo');
                    exit;
                }
                $result = BugReportHelper::cancelar($reportId, $adminId, $motivo);
                if ($result['success']) {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=cancelado');
                } else {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=error_general');
                }
                exit;

            case 'solucionar':
                $result = BugReportHelper::marcarSolucionado($reportId, $adminId);
                if ($result['success']) {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=solucionado');
                } else {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=error_general');
                }
                exit;

            case 'borrar':
                $result = BugReportHelper::borrar($reportId, $adminId);
                if ($result['success']) {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=borrado');
                } else {
                    HTTP::redirectTo('admin.php?page=bugreportadmin&msg=error_general');
                }
                exit;
        }
    }

    // Cargar datos según el modo
    switch ($action) {
        case 'pendientes':
            $reportes = BugReportHelper::getPendientes();
            break;

        case 'aceptados':
            $reportes = BugReportHelper::getAceptados();
            break;

        case 'solucionados':
            $reportes = BugReportHelper::getSolucionados();
            break;

        case 'historial':
            $reportes = BugReportHelper::getHistorial();
            break;

        case 'ver':
            $reportId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
            if ($reportId > 0) {
                $reporte = BugReportHelper::getReporteById($reportId);
                $log     = BugReportHelper::getLogByReport($reportId);
            }
            if (!$reporte) {
                HTTP::redirectTo('admin.php?page=bugreportadmin&msg=error_no_encontrado');
                exit;
            }
            break;

        case 'show':
        default:
            // Dashboard — no carga lista, solo stats
            break;
    }

    // Asignar variables al template
    $template->assign_vars([
        'astrobuga_current_mode' => $action,
        'astrobuga_stats'        => $stats,
        'astrobuga_reportes'     => $reportes,
        'astrobuga_reporte'      => $reporte,
        'astrobuga_log'          => $log,
        'astrobuga_msg_success'  => $msgSuccess,
        'astrobuga_msg_error'    => $msgError,
    ]);

    $template->show('bugreportAdminPage.tpl');
}