<?php
/**
 * ShowImprovementsAdminPage — Panel de gestión de temporadas de mejoras (ADMIN)
 * AstroIO v1.0
 *
 * URL: admin.php?page=improvementsadmin
 *
 * Modos:
 *   - show()       → Dashboard con las 4 temporadas
 *   - activar()    → POST: activar una temporada
 *   - desactivar() → POST: desactivar una temporada
 *   - modo()       → POST: cambiar entre manual/auto
 *   - fechas()     → POST: guardar fechas de una temporada
 */

if (!defined('MODE')) die('Hacking attempt');

require_once ROOT_PATH . 'includes/classes/ImprovementHelper.class.php';

function ShowImprovementsAdmin()
{
    global $USER, $LNG;

    $template = new Template();

    $action = isset($_GET['mode']) ? $_GET['mode'] : 'show';

    // Inicializar variables
    $msgSuccess = '';
    $msgError   = '';
    $seasons    = ImprovementHelper::getAllSeasons();

    // Detectar mensajes en la URL
    if (isset($_GET['msg'])) {
        switch ($_GET['msg']) {
            case 'activada':
                $msgSuccess = '✅ Temporada activada correctamente.';
                break;
            case 'desactivada':
                $msgSuccess = '✅ Temporada desactivada correctamente.';
                break;
            case 'modo_ok':
                $msgSuccess = '✅ Modo de temporada actualizado.';
                break;
            case 'fechas_ok':
                $msgSuccess = '✅ Fechas guardadas correctamente.';
                break;
            case 'error':
                $msgError = '❌ No se pudo completar la acción.';
                break;
            case 'error_fechas':
                $msgError = '❌ Las fechas son incorrectas (fin debe ser mayor que inicio).';
                break;
        }
    }

    // Procesar acciones POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
        $seasonNum = isset($_POST['season_number']) ? (int)$_POST['season_number'] : 0;

        switch ($_POST['action']) {

            case 'activar':
                if ($seasonNum > 0) {
                    ImprovementHelper::setSeasonActive($seasonNum, 1);
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=activada');
                } else {
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=error');
                }
                exit;

            case 'desactivar':
                if ($seasonNum > 0) {
                    ImprovementHelper::setSeasonActive($seasonNum, 0);
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=desactivada');
                } else {
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=error');
                }
                exit;

            case 'modo':
                $mode = isset($_POST['mode']) && $_POST['mode'] === 'auto' ? 'auto' : 'manual';
                if ($seasonNum > 0) {
                    // Conservar fechas si las hay
                    $info = ImprovementHelper::getSeasonInfo($seasonNum);
                    $ds = $info ? (int)$info['date_start'] : 0;
                    $de = $info ? (int)$info['date_end']   : 0;
                    ImprovementHelper::setSeasonActive($seasonNum, (int)$info['active'], $mode, $ds, $de);
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=modo_ok');
                } else {
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=error');
                }
                exit;

            case 'fechas':
                $dateStart = isset($_POST['date_start']) ? (int)strtotime($_POST['date_start']) : 0;
                $dateEnd   = isset($_POST['date_end'])   ? (int)strtotime($_POST['date_end'])   : 0;
                if ($dateStart > 0 && $dateEnd > 0 && $dateEnd > $dateStart) {
                    $info = ImprovementHelper::getSeasonInfo($seasonNum);
                    ImprovementHelper::setSeasonActive(
                        $seasonNum,
                        (int)$info['active'],
                        $info['mode'],
                        $dateStart,
                        $dateEnd
                    );
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=fechas_ok');
                } else {
                    HTTP::redirectTo('admin.php?page=improvementsadmin&msg=error_fechas');
                }
                exit;
        }
    }

    // Procesar temporadas automáticas (por si hay alguna en modo auto)
    ImprovementHelper::processAutoSeasons();

    // Recargar las temporadas después de procesar
    $seasons = ImprovementHelper::getAllSeasons();

    // Calcular stats generales
    $stats = [
        'total_seasons'  => count($seasons),
        'active_seasons' => count(ImprovementHelper::getActiveSeasons()),
    ];

    // Asignar variables al template
    $template->assign_vars([
        'astroimpa_seasons'      => $seasons,
        'astroimpa_stats'        => $stats,
        'astroimpa_msg_success'  => $msgSuccess,
        'astroimpa_msg_error'    => $msgError,
    ]);

    $template->show('improvementsAdminPage.tpl');
}