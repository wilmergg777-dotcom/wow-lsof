<?php
/**
 * ============================================================
 * ShowCrossmarketAdminPage — Admin del Mercado Cruzado v1.2
 * ============================================================
 * Panel para el administrador con 3 pestañas:
 * 1. Dashboard (Reservas y Spread)
 * 2. Conciliación QvaPay (Movimientos manuales)
 * 3. Historial y Órdenes (Control del mercado)
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

function ShowCrossMarketAdmin()
{
    global $USER;

    if ($USER['authlevel'] < AUTH_ADM) {
        exit('Acceso denegado');
    }

    $template = new Template();
    $db       = Database::get();
    $prefix   = 'uni1_';
    $feedbackOk = '';

    // ── 1. PROCESAR ACCIONES ──
    
    // Cancelar Orden
    if (isset($_GET['mode']) && $_GET['mode'] === 'cancelOrder' && isset($_GET['id'])) {
        $orderId = (int)$_GET['id'];
        $db->update(
            "UPDATE `".$prefix."cross_orders`
             SET status = 'cancelled'
             WHERE id = :id AND status = 'open'",
            [':id' => $orderId]
        );
        $feedbackOk = 'Orden #'.$orderId.' cancelada manualmente.';
    }

    // Registrar Rebalanceo (Conciliación QvaPay)
    if (isset($_POST['action']) && $_POST['action'] === 'rebalance') {
        $from = $_POST['from_currency'] ?? '';
        $to = $_POST['to_currency'] ?? '';
        $amountFrom = (int)($_POST['amount_from'] ?? 0);
        $amountTo = (int)($_POST['amount_to'] ?? 0);
        $note = trim($_POST['note'] ?? '');
        
        if ($from && $to && $amountFrom > 0) {
            // Insertar evento de rebalanceo
            $db->insert(
                "INSERT INTO `".$prefix."rebalance_events` 
                    (admin_id, from_currency, to_currency, amount_from, amount_to, note, created_at) 
                 VALUES (:aid, :fc, :tc, :af, :at, :n, :cr)", 
                [
                    ':aid' => $USER['id'], ':fc' => $from, ':tc' => $to, 
                    ':af' => $amountFrom, ':at' => $amountTo, 
                    ':n' => $note, ':cr' => time()
                ]
            );
            
            // Actualizar reservas en el juego
            $db->update(
                "UPDATE `".$prefix."reserves` 
                 SET balance = GREATEST(0, balance - :a) 
                 WHERE currency_code = :c", 
                [':a' => $amountFrom, ':c' => $from]
            );
            $db->update(
                "UPDATE `".$prefix."reserves` 
                 SET balance = balance + :a 
                 WHERE currency_code = :c", 
                [':a' => $amountTo, ':c' => $to]
            );
            
            $feedbackOk = 'Movimiento registrado. Las reservas han sido actualizadas correctamente.';
        } else {
            $feedbackOk = 'Error: Faltan datos para registrar el movimiento.';
        }
    }

    // ── 2. OBTENER TASA QVAPAY ACTUAL ──
    $tasaQvapay = 0;
    try {
        require_once ROOT_PATH . 'includes/qvapay.class.php';
        $cfg = $db->selectSingle("SELECT qvapay_app_id, qvapay_app_secret FROM `".$prefix."config` LIMIT 1");
        if ($cfg && !empty($cfg['qvapay_app_id'])) {
            $qp = new QvaPay($cfg['qvapay_app_id'], $cfg['qvapay_app_secret']);
            $avg = $qp->getP2PAverages();
            if (isset($avg['CUP']['average'])) {
                $tasaQvapay = (float)$avg['CUP']['average'];
            }
        }
    } catch (Exception $e) {
        // Silencioso, se usa el fallback
    }
    if ($tasaQvapay <= 1) {
        $tasaQvapay = 820.00; // Fallback por defecto si QvaPay falla
    }

    // ── 3. LEER DATOS PARA EL DASHBOARD ──
    // Reservas
    $reservesNac = $db->selectSingle("SELECT balance FROM `".$prefix."reserves` WHERE currency_code = 'NTX20_NAC'");
    $reservesInt = $db->selectSingle("SELECT balance FROM `".$prefix."reserves` WHERE currency_code = 'UNTX20_INT'");
    
    $balanceNac = $reservesNac ? (int)$reservesNac['balance'] : 0;
    $balanceInt = $reservesInt ? (int)$reservesInt['balance'] : 0;

    // Spread acumulado
    $spreadNac = $db->selectSingle("SELECT SUM(spread_amount) AS total FROM `".$prefix."cross_trades` WHERE spread_currency = 'NTX20_NAC'");
    $spreadInt = $db->selectSingle("SELECT SUM(spread_amount) AS total FROM `".$prefix."cross_trades` WHERE spread_currency = 'UNTX20_INT'");
    
    $totalSpreadNac = $spreadNac ? (int)$spreadNac['total'] : 0;
    $totalSpreadInt = $spreadInt ? (int)$spreadInt['total'] : 0;

    // ── 4. ÓRDENES ABIERTAS ──
    $openOrders = $db->select(
        "SELECT o.*, u.username 
         FROM `".$prefix."cross_orders` o
         LEFT JOIN `".$prefix."users` u ON u.id = o.user_id
         WHERE o.status = 'open'
         ORDER BY o.created_at DESC"
    );
    if (!is_array($openOrders)) $openOrders = [];

    foreach ($openOrders as &$o) {
        $o['is_sell'] = ($o['side'] === 'sell');
        $o['side_label'] = $o['is_sell'] ? 'Venta' : 'Compra';
        $o['amount_fmt'] = number_format((int)$o['amount'], 0, ',', '.');
        $o['price_fmt']  = number_format((int)$o['price_amount'], 0, ',', '.');
        $o['date'] = date('d/m H:i', (int)$o['created_at']);
    }
    unset($o);

    // ── 5. HISTORIAL DE CRUCES ──
    $trades = $db->select(
        "SELECT t.*, ub.username AS buyer_name, us.username AS seller_name
         FROM `".$prefix."cross_trades` t
         LEFT JOIN `".$prefix."users` ub ON ub.id = t.buyer_id
         LEFT JOIN `".$prefix."users` us ON us.id = t.seller_id
         ORDER BY t.created_at DESC
         LIMIT 50"
    );
    if (!is_array($trades)) $trades = [];

    foreach ($trades as &$t) {
        $t['amount_fmt'] = number_format((int)$t['amount'], 0, ',', '.');
        $t['price_fmt']  = number_format((int)$t['amount_buyer'], 0, ',', '.');
        $t['date'] = date('d/m H:i', (int)$t['created_at']);
        $t['spread_fmt'] = number_format((int)$t['spread_amount'], 0, ',', '.');
        $t['spread_curr'] = ($t['spread_currency'] === 'NTX20_NAC') ? 'CUP' : 'UNTX';
    }
    unset($t);

    // ── 6. HISTORIAL DE REBALANCEOS (CONCILIACIÓN) ──
    $rebalanceEvents = $db->select(
        "SELECT r.*, u.username AS admin_name 
         FROM `".$prefix."rebalance_events` r 
         LEFT JOIN `".$prefix."users` u ON u.id = r.admin_id 
         ORDER BY r.created_at DESC LIMIT 20"
    );
    if (!is_array($rebalanceEvents)) $rebalanceEvents = [];

    foreach ($rebalanceEvents as &$re) {
        $re['date'] = date('d/m H:i', (int)$re['created_at']);
    }
    unset($re);

    // ── 7. ASIGNAR VARIABLES A LA VISTA ──
    $template->assign_vars([
        'balance_nac'      => number_format($balanceNac, 0, ',', '.'),
        'balance_int'      => number_format($balanceInt, 0, ',', '.'),
        'spread_nac'       => number_format($totalSpreadNac, 0, ',', '.'),
        'spread_int'       => number_format($totalSpreadInt, 0, ',', '.'),
        'tasa_qvapay'      => number_format($tasaQvapay, 2, '.', ','),
        'open_orders'      => $openOrders,
        'trades'           => $trades,
        'rebalance_events' => $rebalanceEvents,
        'FEEDBACK_OK'      => $feedbackOk,
    ]);

    $template->show('crossmarketAdminPage.tpl');
}