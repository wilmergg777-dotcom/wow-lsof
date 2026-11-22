<?php
/**
 * ShowGamesAdminPage.php
 * Panel admin UNIFICADO - Rifas + Loteria
 * AstroIO v2.5
 * FORMATO FUNCION (NO clase)
 *
 * NOTA: Este archivo es compatible con RaffleHelper v2.5.
 * Los premios ya incluyen 'ganador_username' desde getPrizesByRaffle().
 * El template gamesAdminPage.tpl debe mostrar {$premio.ganador_username}.
 */

if (!defined('MODE')) {
    exit;
}

require_once 'includes/classes/RaffleHelper.class.php';
require_once 'includes/classes/LotteryHelper.class.php';

/**
 * Punto de entrada del panel admin unificado
 */
function ShowGamesAdmin()
{
    global $USER, $template;

    $template = new Template();

    $tab  = isset($_GET['tab'])  ? $_GET['tab']  : 'dashboard';
    $mode = isset($_GET['mode']) ? $_GET['mode'] : 'default';

    switch ($tab) {
        case 'rifas':    gamesAdminRifas($mode);    break;
        case 'loteria':  gamesAdminLoteria($mode);  break;
        case 'log':      gamesAdminLog();           break;
        default:         gamesAdminDashboard();     break;
    }
}

/* ============================================================
 *  DASHBOARD GENERAL
 * ============================================================ */
function gamesAdminDashboard()
{
    global $template, $db;
    $prefix = 'uni1_';

    $raActivas = RaffleHelper::countActive();
    $row = $db->selectSingle("SELECT COUNT(*) as t FROM `".$prefix."raffles` WHERE estado = 'finalizado'");
    $raFinalizadas = isset($row['t']) ? (int)$row['t'] : 0;
    $row = $db->selectSingle("SELECT COUNT(*) as t FROM `".$prefix."raffle_tickets`");
    $raBoletos = isset($row['t']) ? (int)$row['t'] : 0;

    $listaActivas = RaffleHelper::getActive(10, 0);

    $lotDraw    = LotteryHelper::getCurrentDraw();
    $lotActivo  = $lotDraw ? 1 : 0;
    $lotJackpot = $lotDraw ? $lotDraw['jackpot_total'] : 0;

    $row = $db->selectSingle("SELECT COUNT(*) as t FROM `".$prefix."lottery_draws` WHERE estado = 'sorteado'");
    $lotSorteosTerminados = isset($row['t']) ? (int)$row['t'] : 0;

    $row = $db->selectSingle("SELECT COUNT(*) as t FROM `".$prefix."lottery_tickets`");
    $lotTickets = isset($row['t']) ? (int)$row['t'] : 0;

    $template->assign_vars([
        'ga_tab_activa'             => 'dashboard',
        'ga_ra_activas'             => $raActivas,
        'ga_ra_max_activas'         => 5,
        'ga_ra_finalizadas'         => $raFinalizadas,
        'ga_ra_boletos'             => $raBoletos,
        'ga_lista_activas'          => $listaActivas,
        'ga_hay_activas'            => count($listaActivas) > 0,
        'ga_lot_activo'             => $lotActivo,
        'ga_lot_jackpot'            => $lotJackpot,
        'ga_lot_sorteos_terminados' => $lotSorteosTerminados,
        'ga_lot_tickets'            => $lotTickets,
        'ga_lot_draw'               => $lotDraw,
        'ga_lot_hay_draw'           => ($lotDraw !== null),
        'ga_msg'                    => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'               => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

/* ============================================================
 *  RIFAS
 * ============================================================ */
function gamesAdminRifas($mode)
{
    switch ($mode) {
        case 'crear':       gamesAdminRifasCrear();       return;
        case 'doCrear':     gamesAdminRifasDoCrear();     return;
        case 'finalizadas': gamesAdminRifasFinalizadas(); return;
        case 'ver':         gamesAdminRifasVer();         return;
        case 'forzar':      gamesAdminRifasForzar();      return;
        default:            gamesAdminRifasActivas();     return;
    }
}

function gamesAdminRifasActivas()
{
    global $template;

    $activas = RaffleHelper::getActive(50, 0);

    $template->assign_vars([
        'ga_tab_activa'   => 'rifas',
        'ga_sub_activa'   => 'activas',
        'ga_activas'      => $activas,
        'ga_hay_activas'  => count($activas) > 0,
        'ga_msg'          => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'     => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminRifasFinalizadas()
{
    global $template;

    $finalizadas = RaffleHelper::getFinished(50, 0);

    $template->assign_vars([
        'ga_tab_activa'      => 'rifas',
        'ga_sub_activa'      => 'finalizadas',
        'ga_finalizadas'     => $finalizadas,
        'ga_hay_finalizadas' => count($finalizadas) > 0,
        'ga_msg'             => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'        => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminRifasCrear()
{
    global $template;

    $activas = RaffleHelper::countActive();
    if ($activas >= 5) {
        $_SESSION['ga_msg'] = 'Ya hay 5 rifas activas. Espera a que termine alguna.';
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=rifas&mode=activas');
        exit;
    }

    $monedas = [
        ['id' => 'metal',      'nombre' => 'Metal'],
        ['id' => 'crystal',    'nombre' => 'Cristal'],
        ['id' => 'deuterium',  'nombre' => 'Deuterio'],
        ['id' => 'darkmatter', 'nombre' => 'Materia Oscura'],
        ['id' => 'ntx20',      'nombre' => 'NTX-20'],
    ];

    $duraciones = [
        ['id' => '24h', 'nombre' => '24 horas'],
        ['id' => '7d',  'nombre' => '7 dias'],
        ['id' => '15d', 'nombre' => '15 dias'],
    ];

    $tiposPremio = [
        ['id' => 'metal',      'nombre' => 'Metal'],
        ['id' => 'crystal',    'nombre' => 'Cristal'],
        ['id' => 'deuterium',  'nombre' => 'Deuterio'],
        ['id' => 'darkmatter', 'nombre' => 'Materia Oscura'],
        ['id' => 'ntx20',      'nombre' => 'NTX-20'],
    ];

    $template->assign_vars([
        'ga_tab_activa'   => 'rifas',
        'ga_sub_activa'   => 'crear',
        'ga_monedas'      => $monedas,
        'ga_duraciones'   => $duraciones,
        'ga_tipos_premio' => $tiposPremio,
        'ga_msg'          => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'     => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminRifasDoCrear()
{
    global $USER;

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Location: admin.php?page=gamesadmin&tab=rifas');
        exit;
    }

    $data = [
        'titulo'           => isset($_POST['titulo']) ? trim($_POST['titulo']) : '',
        'descripcion'      => isset($_POST['descripcion']) ? trim($_POST['descripcion']) : '',
        'moneda'           => isset($_POST['moneda']) ? $_POST['moneda'] : 'ntx20',
        'precio_boleto'    => isset($_POST['precio_boleto']) ? (int)$_POST['precio_boleto'] : 0,
        'max_boletos'      => isset($_POST['max_boletos']) ? (int)$_POST['max_boletos'] : 100,
        'cantidad_lugares' => isset($_POST['cantidad_lugares']) ? (int)$_POST['cantidad_lugares'] : 1,
        'duracion'         => isset($_POST['duracion']) ? $_POST['duracion'] : '7d',
        'premios'          => [],
    ];

    if (isset($_POST['premio_tipo']) && is_array($_POST['premio_tipo'])) {
        foreach ($_POST['premio_tipo'] as $i => $tipo) {
            // ✅ v4.0 — cada premio trae su LUGAR: varios premios con el
            // mismo lugar se los lleva el mismo ganador (0 = auto/secuencial)
            $data['premios'][] = [
                'tipo'     => $tipo,
                'subtipo'  => null,
                'cantidad' => isset($_POST['premio_cantidad'][$i]) ? (int)$_POST['premio_cantidad'][$i] : 1,
                'lugar'    => isset($_POST['premio_lugar'][$i]) ? (int)$_POST['premio_lugar'][$i] : 0,
            ];
        }
    }

    $adminId = 0;
    if (isset($USER['id'])) {
        $adminId = (int)$USER['id'];
    } elseif (isset($GLOBALS['USER']['id'])) {
        $adminId = (int)$GLOBALS['USER']['id'];
    }

    $result = RaffleHelper::create($adminId, $data);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Rifa creada correctamente';
        $_SESSION['ga_msg_type'] = 'success';
        header('Location: admin.php?page=gamesadmin&tab=rifas&mode=activas');
    } else {
        $_SESSION['ga_msg'] = $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=rifas&mode=crear');
    }
    exit;
}

function gamesAdminRifasVer()
{
    global $template;

    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        header('Location: admin.php?page=gamesadmin&tab=rifas');
        exit;
    }

    $raffle = RaffleHelper::getById($id);
    if (!$raffle) {
        $_SESSION['ga_msg'] = 'La rifa no existe';
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=rifas');
        exit;
    }

    $tickets = RaffleHelper::getTicketsByRaffle($id);

    // Los premios ya incluyen 'ganador_username' desde RaffleHelper::getPrizesByRaffle()
    $template->assign_vars([
        'ga_tab_activa'   => 'rifas',
        'ga_sub_activa'   => 'ver',
        'ga_raffle'       => $raffle,
        'ga_premios'      => $raffle['premios'],
        'ga_tickets'      => $tickets,
        'ga_hay_tickets'  => count($tickets) > 0,
        'ga_msg'          => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'     => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminRifasForzar()
{
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        header('Location: admin.php?page=gamesadmin&tab=rifas');
        exit;
    }

    $result = RaffleHelper::drawWinner($id);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Sorteo ejecutado correctamente';
        $_SESSION['ga_msg_type'] = 'success';
    } else {
        $_SESSION['ga_msg'] = 'Error: ' . $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
    }

    header('Location: admin.php?page=gamesadmin&tab=rifas&mode=ver&id=' . $id);
    exit;
}

/* ============================================================
 *  LOTERIA
 * ============================================================ */
function gamesAdminLoteria($mode)
{
    switch ($mode) {
        case 'config':          gamesAdminLoteriaConfig();          return;
        case 'doConfig':        gamesAdminLoteriaDoConfig();        return;
        case 'crear':           gamesAdminLoteriaCrear();           return;
        case 'doCrear':         gamesAdminLoteriaDoCrear();         return;
        case 'ver':             gamesAdminLoteriaVer();             return;
        case 'forzar':          gamesAdminLoteriaForzar();          return;
        case 'tickets':         gamesAdminLoteriaTickets();         return;
        case 'tramos':          gamesAdminLoteriaTramos();          return;
        case 'tramoEditar':     gamesAdminLoteriaTramoEditar();     return;
        case 'tramoDoEdit':     gamesAdminLoteriaTramoDoEdit();     return;
        case 'tramoNew':        gamesAdminLoteriaTramoNew();        return;
        case 'tramoDoNew':      gamesAdminLoteriaTramoDoNew();      return;
        case 'tramoDelete':     gamesAdminLoteriaTramoDelete();     return;
        default:                gamesAdminLoteriaSorteos();         return;
    }
}

function gamesAdminLoteriaSorteos()
{
    global $template;

    $sorteos    = LotteryHelper::getDraws(50, 0);
    $drawActual = LotteryHelper::getCurrentDraw();
    $config     = LotteryHelper::getConfig();

    $template->assign_vars([
        'ga_tab_activa'       => 'loteria',
        'ga_sub_activa'       => 'sorteos',
        'ga_lot_sorteos'      => $sorteos,
        'ga_lot_hay_sorteos'  => count($sorteos) > 0,
        'ga_lot_draw'         => $drawActual,
        'ga_lot_hay_draw'     => ($drawActual !== null),
        'ga_lot_config'       => $config,
        'ga_msg'              => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'         => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminLoteriaConfig()
{
    global $template;

    $config = LotteryHelper::getConfig();

    $duraciones = [
        ['id' => '24h', 'nombre' => '24 horas'],
        ['id' => '7d',  'nombre' => '7 dias'],
        ['id' => '15d', 'nombre' => '15 dias'],
    ];

    $template->assign_vars([
        'ga_tab_activa'     => 'loteria',
        'ga_sub_activa'     => 'config',
        'ga_lot_config'     => $config,
        'ga_lot_duraciones' => $duraciones,
        'ga_msg'            => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'       => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminLoteriaDoConfig()
{
    global $USER;

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=config');
        exit;
    }

    $data = [
        'moneda'                  => 'ntx20',
        'precio_ticket'           => isset($_POST['precio_ticket']) ? (int)$_POST['precio_ticket'] : 57,
        'descuento_vip'           => isset($_POST['descuento_vip']) ? (int)$_POST['descuento_vip'] : 0,
        'duracion_sorteo'         => isset($_POST['duracion_sorteo']) ? $_POST['duracion_sorteo'] : '7d',
        'rango_max'               => isset($_POST['rango_max']) ? (int)$_POST['rango_max'] : 30,
        'numeros_a_elegir'        => isset($_POST['numeros_a_elegir']) ? (int)$_POST['numeros_a_elegir'] : 4,
        'fondo_admin'             => isset($_POST['fondo_admin']) ? (int)$_POST['fondo_admin'] : 1000,
        'jackpot_minimo'          => isset($_POST['jackpot_minimo']) ? (int)$_POST['jackpot_minimo'] : 1000,
        'jackpot_acumula'         => isset($_POST['jackpot_acumula']) ? 1 : 0,
        'premio_3_aciertos'       => isset($_POST['premio_3_aciertos']) ? (int)$_POST['premio_3_aciertos'] : 169,
        'premio_2_aciertos'       => isset($_POST['premio_2_aciertos']) ? (int)$_POST['premio_2_aciertos'] : 114,
        'max_tickets_por_jugador' => isset($_POST['max_tickets_por_jugador']) ? (int)$_POST['max_tickets_por_jugador'] : 4,
        'max_tickets_totales'     => isset($_POST['max_tickets_totales']) ? (int)$_POST['max_tickets_totales'] : 1000,
        'activo'                  => isset($_POST['activo']) ? 1 : 0,
    ];

    $adminId = isset($USER['id']) ? (int)$USER['id'] : 0;
    $result = LotteryHelper::saveConfig($data, $adminId);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Configuracion guardada correctamente';
        $_SESSION['ga_msg_type'] = 'success';
    } else {
        $_SESSION['ga_msg'] = 'Error: ' . $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
    }

    header('Location: admin.php?page=gamesadmin&tab=loteria&mode=config');
    exit;
}

function gamesAdminLoteriaCrear()
{
    global $template, $db;
    $prefix = 'uni1_';

    $config = LotteryHelper::getConfig();

    $drawActual = LotteryHelper::getCurrentDraw();
    if ($drawActual) {
        $_SESSION['ga_msg'] = 'Ya hay un sorteo abierto. Espera a que termine para crear otro.';
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=sorteos');
        exit;
    }

    $rollover = 0;
    $hayRollover = false;

    $ultimo = $db->selectSingle(
        "SELECT jackpot_rollover, hubo_ganador_jackpot 
         FROM `".$prefix."lottery_draws` 
         WHERE estado = 'sorteado' 
         ORDER BY id DESC LIMIT 1"
    );

    if ($ultimo && !$ultimo['hubo_ganador_jackpot'] && $ultimo['jackpot_rollover'] > 0) {
        $rollover = (int)$ultimo['jackpot_rollover'];
        $hayRollover = true;
    }

    $template->assign_vars([
        'ga_tab_activa'       => 'loteria',
        'ga_sub_activa'       => 'crear',
        'ga_lot_config'       => $config,
        'ga_lot_rollover'     => $rollover,
        'ga_lot_hay_rollover' => $hayRollover,
        'ga_msg'              => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'         => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminLoteriaDoCrear()
{
    global $USER;

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Location: admin.php?page=gamesadmin&tab=loteria');
        exit;
    }

    $fondoAdmin = isset($_POST['fondo_admin']) ? (int)$_POST['fondo_admin'] : 0;
    $adminId = isset($USER['id']) ? (int)$USER['id'] : 0;

    $result = LotteryHelper::createDraw($adminId, $fondoAdmin);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Sorteo #' . $result['numero'] . ' creado. Jackpot: ' . number_format($result['jackpot']) . ' NTX-20';
        $_SESSION['ga_msg_type'] = 'success';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=sorteos');
    } else {
        $_SESSION['ga_msg'] = $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=crear');
    }
    exit;
}

function gamesAdminLoteriaVer()
{
    global $template;

    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        header('Location: admin.php?page=gamesadmin&tab=loteria');
        exit;
    }

    $draw = LotteryHelper::getDrawById($id);
    if (!$draw) {
        $_SESSION['ga_msg'] = 'El sorteo no existe';
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=loteria');
        exit;
    }

    $tickets = LotteryHelper::getTicketsByDraw($id);

    $template->assign_vars([
        'ga_tab_activa'       => 'loteria',
        'ga_sub_activa'       => 'ver',
        'ga_lot_draw'         => $draw,
        'ga_lot_tickets'      => $tickets,
        'ga_lot_hay_tickets'  => count($tickets) > 0,
        'ga_msg'              => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'         => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

function gamesAdminLoteriaForzar()
{
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        header('Location: admin.php?page=gamesadmin&tab=loteria');
        exit;
    }

    $result = LotteryHelper::drawWinner($id);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Sorteo ejecutado! Numeros: ' . implode(', ', $result['numeros']);
        $_SESSION['ga_msg_type'] = 'success';
    } else {
        $_SESSION['ga_msg'] = 'Error: ' . $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
    }

    header('Location: admin.php?page=gamesadmin&tab=loteria&mode=ver&id=' . $id);
    exit;
}

function gamesAdminLoteriaTickets()
{
    global $template;

    $drawId = isset($_GET['draw_id']) ? (int)$_GET['draw_id'] : 0;
    if ($drawId <= 0) {
        header('Location: admin.php?page=gamesadmin&tab=loteria');
        exit;
    }

    $draw = LotteryHelper::getDrawById($drawId);
    if (!$draw) {
        header('Location: admin.php?page=gamesadmin&tab=loteria');
        exit;
    }

    $tickets = LotteryHelper::getTicketsByDraw($drawId);

    $template->assign_vars([
        'ga_tab_activa'       => 'loteria',
        'ga_sub_activa'       => 'tickets',
        'ga_lot_draw'         => $draw,
        'ga_lot_tickets'      => $tickets,
        'ga_lot_hay_tickets'  => count($tickets) > 0,
        'ga_msg'              => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'         => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

/* ============================================================
 *  LOTERIA - TRAMOS DE PORCENTAJES
 * ============================================================ */

/**
 * Lista todos los tramos de porcentajes
 */
function gamesAdminLoteriaTramos()
{
    global $template;

    $tramos = LotteryHelper::getAllTramos();

    $template->assign_vars([
        'ga_tab_activa'      => 'loteria',
        'ga_sub_activa'      => 'tramos',
        'ga_lot_tramos'      => $tramos,
        'ga_lot_hay_tramos'  => count($tramos) > 0,
        'ga_msg'             => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'        => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

/**
 * Formulario para editar un tramo existente
 */
function gamesAdminLoteriaTramoEditar()
{
    global $template;

    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
        exit;
    }

    $tramo = LotteryHelper::getTramoById($id);
    if (!$tramo) {
        $_SESSION['ga_msg'] = 'El tramo no existe';
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
        exit;
    }

    $template->assign_vars([
        'ga_tab_activa'   => 'loteria',
        'ga_sub_activa'   => 'tramos',
        'ga_tramo'        => $tramo,
        'ga_tramo_edit'   => true,
        'ga_msg'          => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'     => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

/**
 * Guardar edicion de tramo (POST)
 */
function gamesAdminLoteriaTramoDoEdit()
{
    global $USER;

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
        exit;
    }

    $data = [
        'id'              => isset($_POST['id']) ? (int)$_POST['id'] : 0,
        'jackpot_desde'   => isset($_POST['jackpot_desde']) ? (int)$_POST['jackpot_desde'] : 0,
        'jackpot_hasta'   => isset($_POST['jackpot_hasta']) ? (int)$_POST['jackpot_hasta'] : 0,
        'pct_jackpot'     => isset($_POST['pct_jackpot']) ? (int)$_POST['pct_jackpot'] : 70,
        'pct_3_aciertos'  => isset($_POST['pct_3_aciertos']) ? (int)$_POST['pct_3_aciertos'] : 20,
        'pct_2_aciertos'  => isset($_POST['pct_2_aciertos']) ? (int)$_POST['pct_2_aciertos'] : 10,
        'orden'           => isset($_POST['orden']) ? (int)$_POST['orden'] : 0,
    ];

    $adminId = isset($USER['id']) ? (int)$USER['id'] : 0;
    $result = LotteryHelper::saveTramo($data, $adminId);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Tramo actualizado correctamente';
        $_SESSION['ga_msg_type'] = 'success';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
    } else {
        $_SESSION['ga_msg'] = 'Error: ' . $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramoEditar&id=' . $data['id']);
    }
    exit;
}

/**
 * Formulario para crear un tramo nuevo
 */
function gamesAdminLoteriaTramoNew()
{
    global $template;

    $template->assign_vars([
        'ga_tab_activa'   => 'loteria',
        'ga_sub_activa'   => 'tramos',
        'ga_tramo'        => null,
        'ga_tramo_edit'   => false,
        'ga_msg'          => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'     => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}

/**
 * Guardar tramo nuevo (POST)
 */
function gamesAdminLoteriaTramoDoNew()
{
    global $USER;

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
        exit;
    }

    $data = [
        'id'              => 0,
        'jackpot_desde'   => isset($_POST['jackpot_desde']) ? (int)$_POST['jackpot_desde'] : 0,
        'jackpot_hasta'   => isset($_POST['jackpot_hasta']) ? (int)$_POST['jackpot_hasta'] : 0,
        'pct_jackpot'     => isset($_POST['pct_jackpot']) ? (int)$_POST['pct_jackpot'] : 70,
        'pct_3_aciertos'  => isset($_POST['pct_3_aciertos']) ? (int)$_POST['pct_3_aciertos'] : 20,
        'pct_2_aciertos'  => isset($_POST['pct_2_aciertos']) ? (int)$_POST['pct_2_aciertos'] : 10,
        'orden'           => isset($_POST['orden']) ? (int)$_POST['orden'] : 0,
    ];

    $adminId = isset($USER['id']) ? (int)$USER['id'] : 0;
    $result = LotteryHelper::saveTramo($data, $adminId);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Tramo creado correctamente';
        $_SESSION['ga_msg_type'] = 'success';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
    } else {
        $_SESSION['ga_msg'] = 'Error: ' . $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramoNew');
    }
    exit;
}

/**
 * Eliminar un tramo
 */
function gamesAdminLoteriaTramoDelete()
{
    global $USER;

    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
        exit;
    }

    $adminId = isset($USER['id']) ? (int)$USER['id'] : 0;
    $result = LotteryHelper::deleteTramo($id, $adminId);

    if ($result['ok']) {
        $_SESSION['ga_msg'] = 'Tramo eliminado correctamente';
        $_SESSION['ga_msg_type'] = 'success';
    } else {
        $_SESSION['ga_msg'] = 'Error: ' . $result['msg'];
        $_SESSION['ga_msg_type'] = 'error';
    }

    header('Location: admin.php?page=gamesadmin&tab=loteria&mode=tramos');
    exit;
}

/* ============================================================
 *  LOG
 * ============================================================ */
function gamesAdminLog()
{
    global $template, $db;
    $prefix = 'uni1_';

    $rowsRaffles = $db->select(
        "SELECT 'rifas' as tipo, id, raffle_id as ref_id, user_id, accion, detalle, fecha 
         FROM `".$prefix."raffle_log` 
         ORDER BY fecha DESC LIMIT 50"
    );

    $rowsLottery = $db->select(
        "SELECT 'loteria' as tipo, id, draw_id as ref_id, user_id, accion, detalle, fecha 
         FROM `".$prefix."lottery_log` 
         ORDER BY fecha DESC LIMIT 50"
    );

    $rows = array();
    if (is_array($rowsRaffles)) $rows = array_merge($rows, $rowsRaffles);
    if (is_array($rowsLottery)) $rows = array_merge($rows, $rowsLottery);

    usort($rows, function ($a, $b) {
        return (int)$b['fecha'] - (int)$a['fecha'];
    });

    $rows = array_slice($rows, 0, 100);

    $template->assign_vars([
        'ga_tab_activa' => 'log',
        'ga_log_rows'   => $rows,
        'ga_msg'        => isset($_SESSION['ga_msg']) ? $_SESSION['ga_msg'] : '',
        'ga_msg_type'   => isset($_SESSION['ga_msg_type']) ? $_SESSION['ga_msg_type'] : 'info',
    ]);

    unset($_SESSION['ga_msg']);
    unset($_SESSION['ga_msg_type']);

    $template->show('gamesAdminPage.tpl');
}