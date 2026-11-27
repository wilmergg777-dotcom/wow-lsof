<?php
/**
 * ShowBugreportPage — Página del sistema de reportes (JUGADOR)
 * AstroIO v1.1 — Todos los jugadores ven TODOS los reportes
 *
 * URL: game.php?page=bugreport
 *
 * Modos:
 *   - show()             → Lista PÚBLICA de reportes (todos los jugadores)
 *   - new()              → Formulario paso 1: elegir categoría
 *   - newForm()          → Formulario paso 2: título + descripción
 *   - doNew()            → POST: crear reporte
 *   - ver()              → Ver detalle de un reporte (público)
 *   - cancelar()         → POST: cancelar un reporte propio
 *
 * Cambios v1.1:
 *   - show() ahora muestra TODOS los reportes (aceptados + solucionados)
 *   - Cada reporte indica quién lo creó
 *   - ver() ahora permite ver cualquier reporte (no solo los propios)
 */

if (!defined('MODE')) die('Hacking attempt');

require_once ROOT_PATH . 'includes/classes/BugReportHelper.class.php';

class ShowBugreportPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    /* ============================================================
     * LISTA PÚBLICA DE REPORTES
     * Muestra TODOS los reportes (aceptados + solucionados) de TODOS los jugadores
     * ============================================================ */
    public function show()
    {
        global $USER;

        $userId = (int)$USER['id'];

        // ✅ CAMBIO: usar getReportesPublicos() en vez de getMisReportes()
        //    Esto trae TODOS los reportes de TODOS los jugadores
        $reportes = BugReportHelper::getReportesPublicos(100);

        // Añadir el nombre del jugador que reportó cada uno
        $db     = Database::get();
        $prefix = defined('DB_PREFIX') ? DB_PREFIX : (defined('PREFIX') ? PREFIX : 'uni1_');

        foreach ($reportes as &$rep) {
            $row = $db->selectSingle(
                "SELECT username FROM ".$prefix."users WHERE id = :uid LIMIT 1",
                [':uid' => (int)$rep['user_id']]
            );
            $rep['jugador']   = $row ? $row['username'] : 'Desconocido';
            $rep['es_mio']    = ((int)$rep['user_id'] === $userId) ? 1 : 0;
        }
        unset($rep);

        $this->assign([
            'reportes'      => $reportes,
            'msgSuccess'    => $this->getMsg('success'),
            'msgError'      => $this->getMsg('error'),
            'totalAbiertos' => count($reportes),
        ]);

        $this->display('page.bugreport.default.tpl');
    }

    /* ============================================================
     * PASO 1 — ELEGIR CATEGORÍA
     * ============================================================ */
    public function new()
    {
        global $USER;

        $categorias = BugReportHelper::getCategorias();

        $this->assign([
            'categorias' => $categorias,
            'msgError'   => $this->getMsg('error'),
        ]);

        $this->display('page.bugreport.new.tpl');
    }

    /* ============================================================
     * PASO 2 — FORMULARIO CON CATEGORÍA YA ELEGIDA
     * ============================================================ */
    public function newForm()
    {
        global $USER;

        $categoriaClave = isset($_GET['cat']) ? trim($_GET['cat']) : '';
        $categoria = BugReportHelper::getCategoria($categoriaClave);

        if (!$categoria) {
            $this->bpRedirect('game.php?page=bugreport&mode=new&msg=error_cat');
            return;
        }

        // Mostrar error real de sesión si existe
        $msgError = '';
        if (isset($_SESSION['bugreport_error'])) {
            $msgError = $_SESSION['bugreport_error'];
            unset($_SESSION['bugreport_error']);
        } else {
            $msgError = $this->getMsg('error');
        }

        $this->assign([
            'categoria' => $categoria,
            'msgError'  => $msgError,
        ]);

        $this->display('page.bugreport.newform.tpl');
    }

    /* ============================================================
     * POST — CREAR REPORTE
     * ============================================================ */
    public function doNew()
    {
        global $USER;

        $userId = (int)$USER['id'];
        $categoria  = isset($_POST['categoria']) ? trim($_POST['categoria']) : '';
        $titulo     = isset($_POST['titulo']) ? trim($_POST['titulo']) : '';
        $descripcion= isset($_POST['descripcion']) ? trim($_POST['descripcion']) : '';

        if ($categoria === '' || $titulo === '' || $descripcion === '') {
            $_SESSION['bugreport_error'] = '❌ Completá todos los campos obligatorios.';
            $this->bpRedirect('game.php?page=bugreport&mode=newForm&cat='.urlencode($categoria));
            return;
        }

        $result = BugReportHelper::crearReporte($userId, $categoria, $titulo, $descripcion);

        if ($result['success']) {
            $this->bpRedirect('game.php?page=bugreport&msg=enviado');
        } else {
            $_SESSION['bugreport_error'] = $result['message'];
            $this->bpRedirect('game.php?page=bugreport&mode=newForm&cat='.urlencode($categoria));
        }
    }

    /* ============================================================
     * VER DETALLE DE UN REPORTE
     * v1.1 — Ahora CUALQUIERA puede ver cualquier reporte
     *        (mientras no esté pendiente, cancelado o borrado)
     * ============================================================ */
    public function ver()
    {
        global $USER;

        $userId   = (int)$USER['id'];
        $reportId = isset($_GET['id']) ? (int)$_GET['id'] : 0;

        if ($reportId <= 0) {
            $this->bpRedirect('game.php?page=bugreport');
            return;
        }

        $reporte = BugReportHelper::getReporteById($reportId);

        if (!$reporte) {
            $this->bpRedirect('game.php?page=bugreport&msg=error_permiso');
            return;
        }

        // Si está pendiente, nadie lo puede ver (excepto el admin en su panel)
        if ($reporte['estado'] === 'pendiente') {
            $this->bpRedirect('game.php?page=bugreport&msg=error_pendiente');
            return;
        }

        // Si está cancelado o borrado, nadie lo puede ver
        if (in_array($reporte['estado'], ['cancelado', 'borrado'])) {
            $this->bpRedirect('game.php?page=bugreport&msg=error_cancelado');
            return;
        }

        // ✅ CAMBIO: ya no verificamos que sea del usuario actual
        //    Todos pueden ver los reportes en estado aceptado/solucionado

        // Log del historial
        $log = BugReportHelper::getLogByReport($reportId);

        // Saber si es mío (para mostrar el botón de cancelar solo si es mío)
        $esMio = ((int)$reporte['user_id'] === $userId) ? 1 : 0;

        $this->assign([
            'reporte' => $reporte,
            'log'     => $log,
            'esMio'   => $esMio,
        ]);

        $this->display('page.bugreport.ver.tpl');
    }

    /* ============================================================
     * MENSAJES
     * ============================================================ */
    private function getMsg($type)
    {
        if (!isset($_GET['msg'])) return '';

        $msg = $_GET['msg'];

        $success = [
            'enviado' => '✅ Reporte enviado. Será revisado por un admin.'
        ];

        $error = [
            'error_vacio'      => '❌ Completá todos los campos obligatorios.',
            'error_crear'      => '❌ No se pudo crear el reporte. Revisá los datos.',
            'error_cat'        => '❌ Categoría no válida.',
            'error_permiso'    => '❌ No tenés permiso para ver este reporte.',
            'error_pendiente'  => '❌ Este reporte aún está siendo revisado.',
            'error_cancelado'  => '❌ Este reporte fue cancelado.',
            'error_limite'     => '❌ Alcanzaste el límite de reportes activos.',
        ];

        if ($type === 'success' && isset($success[$msg])) return $success[$msg];
        if ($type === 'error'   && isset($error[$msg]))   return $error[$msg];

        return '';
    }

    /* ============================================================
     * REDIRECCIÓN (renombrado para no chocar con AbstractGamePage)
     * ============================================================ */
    private function bpRedirect($url)
    {
        header('Location: ' . $url);
        exit;
    }
}