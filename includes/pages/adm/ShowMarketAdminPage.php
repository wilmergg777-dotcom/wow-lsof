<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ============================================
 *  ASTROIO - Panel Admin del Mercado
 *  Archivo: includes/pages/adm/ShowMarketAdminPage.php
 * ============================================
 *
 *  ✅ v2.1 (MERCADO v2.6 — Anti-exploit "almacén seguro"):
 *     - Nuevo helper getAdminCancelReasonLabel() que traduce
 *       cancel_reason a texto legible para el admin.
 *     - Estadísticas nuevas: ofertas auto-canceladas por motivo
 *       (seller_no_resources / buyer_no_ntx).
 *     - Query nueva: últimas 50 ofertas auto-canceladas, con datos
 *       completos (seller_id, planet_id, item, cancel_reason).
 *     - Todas las ofertas de admin ahora llevan cancel_reason_label
 *       para que el template lo pueda mostrar.
 *     - Nueva acción mode=cleanup_autocancelled que borra del
 *       histórico las ofertas auto-canceladas (opcional, el admin
 *       decide cuándo limpiar).
 *     - Todo lo anterior (crear/borrar/vaciar fondo) sigue igual.
 */

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) throw new Exception("Permission error!");

/**
 * ✅ v2.1 — Helper: traduce cancel_reason a texto legible
 */
function getAdminCancelReasonLabel($reason)
{
    $map = array(
        'seller_cancelled'    => 'Cancelada por el vendedor',
        'seller_no_resources' => 'Auto-cancelada: el vendedor ya no tenía los recursos (posible ataque)',
        'buyer_no_ntx'        => 'Auto-cancelada: el comprador ya no tenía el NTX-20',
        'expired'             => 'Expirada sin completarse',
    );

    if (empty($reason)) return '';
    return isset($map[$reason]) ? $map[$reason] : ucfirst(str_replace('_', ' ', $reason));
}

function ShowMarketAdmin()
{
    global $LNG;

    $template = new template();
    $db       = Database::get();
    $action   = HTTP::_GP('mode', '');

    $message = '';
    $msgType = 'info';

    // ============================================
    // PREFIJO DE TABLAS
    // ============================================
    $prefix = 'uni1_';
    if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
    elseif (defined('PREFIX')) $prefix = PREFIX;

    // Cargar helpers
    require_once ROOT_PATH.'includes/classes/MarketHelper.class.php';

    // ============================================
    // PROCESAR ACCIONES
    // ============================================

    // --- CREAR OFERTA DE ADMIN ---
    if ($action == 'create') {
        $itemTypeRaw = HTTP::_GP('item_type', '');
        $itemId      = (int) HTTP::_GP('item_id', 0);
        $amount      = (int) HTTP::_GP('amount', 0);
        $price       = (int) HTTP::_GP('price_ntx', 0);

        if ($itemTypeRaw === '' || $amount <= 0) {
            $message = 'Datos incompletos.';
            $msgType = 'error';
        } else {
            $info     = MarketHelper::getItemInfo($itemTypeRaw, $itemId);
            $itemName = $info ? $info['name'] : 'Desconocido';

            $result = MarketHelper::createAdminOffer(0, array(
                'item_type' => $itemTypeRaw,
                'item_id'   => $itemId,
                'item_name' => $itemName,
                'amount'    => $amount,
                'price_ntx' => $price,
            ));

            if (isset($result['error'])) {
                $message = $result['error'];
                $msgType = 'error';
            } else {
                $message = 'Oferta de admin creada: '.$itemName.' x'.$amount.' por '.$price.' NTX-20';
                $msgType = 'success';
            }
        }
    }

    // --- BORRAR OFERTA ADMIN ---
    if ($action == 'delete') {
        $offerId = (int) HTTP::_GP('id', 0);
        if ($offerId > 0) {
            $db->update(
                "UPDATE `".$prefix."market_offers` SET status='cancelled'
                 WHERE offer_id = :id AND admin_offer = 1",
                array(':id' => $offerId)
            );
            $message = 'Oferta eliminada.';
            $msgType = 'success';
        }
    }

    // --- VACIAR FONDO ---
    if ($action == 'clear') {
        $db->update(
            "UPDATE `".$prefix."market_fund` SET
                total_earned = 0,
                from_seller  = 0,
                from_buyer   = 0,
                from_admin   = 0,
                last_update  = :t
             WHERE id = 1",
            array(':t' => TIMESTAMP)
        );
        $message = 'Fondo reseteado.';
        $msgType = 'success';
    }

    // ============================================
    // 🆕 v2.1 — LIMPIAR OFERTAS AUTO-CANCELADAS DEL HISTÓRICO
    // ------------------------------------------------------------
    // Borra las ofertas que quedaron en status='cancelled' con
    // cancel_reason = 'seller_no_resources' o 'buyer_no_ntx'.
    // Útil cuando el admin quiere limpiar la base de ofertas
    // que ya no sirven y ocupan espacio en el listado.
    // ============================================
    if ($action == 'cleanup_autocancelled') {
        try {
            $db->delete(
                "DELETE FROM `".$prefix."market_offers`
                 WHERE status = 'cancelled'
                   AND cancel_reason IN ('seller_no_resources', 'buyer_no_ntx')"
            );
            $message = 'Ofertas auto-canceladas eliminadas del histórico.';
            $msgType = 'success';
        } catch (Exception $e) {
            $message = 'Error al limpiar: '.$e->getMessage();
            $msgType = 'error';
        }
    }

    // ============================================
    // CARGAR DATOS PARA LA VISTA
    // ============================================

    // --- Fondo del proyecto ---
    $fund = $db->selectSingle(
        "SELECT * FROM `".$prefix."market_fund` WHERE id = 1"
    );
    if (!$fund) {
        $fund = array(
            'total_earned' => 0,
            'from_seller'  => 0,
            'from_buyer'   => 0,
            'from_admin'   => 0,
        );
    }

    // --- Estadísticas generales ---
    $stats = $db->selectSingle(
        "SELECT
            (SELECT COUNT(*) FROM `".$prefix."market_offers` WHERE status='active') AS active_offers,
            (SELECT COUNT(*) FROM `".$prefix."market_offers` WHERE status='sold')   AS sold_offers,
            (SELECT COUNT(*) FROM `".$prefix."market_offers` WHERE admin_offer=1 AND status='active') AS admin_offers,
            (SELECT COUNT(*) FROM `".$prefix."market_log`) AS total_logs,
            (SELECT COALESCE(SUM(price_ntx), 0) FROM `".$prefix."market_log`) AS total_volume,
            (SELECT COUNT(*) FROM `".$prefix."market_offers`
                WHERE status='cancelled' AND cancel_reason='seller_no_resources') AS autocancelled_seller,
            (SELECT COUNT(*) FROM `".$prefix."market_offers`
                WHERE status='cancelled' AND cancel_reason='buyer_no_ntx') AS autocancelled_buyer
        "
    );

    if (!$stats) {
        $stats = array(
            'active_offers'         => 0,
            'sold_offers'           => 0,
            'admin_offers'          => 0,
            'total_logs'            => 0,
            'total_volume'          => 0,
            'autocancelled_seller'  => 0,
            'autocancelled_buyer'   => 0,
        );
    }

    // --- Ofertas admin ---
    $adminOffers = $db->select(
        "SELECT * FROM `".$prefix."market_offers`
         WHERE admin_offer = 1
         ORDER BY status ASC, created DESC
         LIMIT 50"
    );

    if (!is_array($adminOffers)) $adminOffers = array();

    foreach ($adminOffers as &$o) {
        $o['amount_fmt'] = MarketHelper::formatAmount((int) $o['amount']);
        $o['price_fmt']  = number_format((int) $o['price_ntx'], 0, ',', '.');
        $o['image']      = MarketHelper::itemImage($o['item_type'], (int) $o['item_id']);
        $o['category']   = MarketHelper::getCategoryLabel($o['item_type']);
        $o['date']       = date('d/m/Y H:i', (int) $o['created']);

        // 🆕 v2.1 — Motivo de cancelación legible
        $o['cancel_reason']       = isset($o['cancel_reason']) ? $o['cancel_reason'] : '';
        $o['cancel_reason_label'] = getAdminCancelReasonLabel($o['cancel_reason']);
    }
    unset($o);

    // ============================================
    // 🆕 v2.1 — OFERTAS AUTO-CANCELADAS (últimas 50)
    // ------------------------------------------------------------
    // Muestra las ofertas que el cron canceló automáticamente
    // porque:
    //   · El vendedor ya no tenía los items en su planeta
    //     (probablemente lo atacaron)
    //   · El comprador ya no tenía el NTX-20
    //     (probablemente lo gastó en otra cosa)
    // ============================================
    $autoCancelledOffers = $db->select(
        "SELECT o.*, u.username AS seller_name
         FROM `".$prefix."market_offers` o
         LEFT JOIN `".$prefix."users` u ON u.id = o.seller_id
         WHERE o.status = 'cancelled'
           AND o.cancel_reason IN ('seller_no_resources', 'buyer_no_ntx')
         ORDER BY o.offer_id DESC
         LIMIT 50"
    );

    if (!is_array($autoCancelledOffers)) $autoCancelledOffers = array();

    foreach ($autoCancelledOffers as &$ac) {
        $ac['amount_fmt']         = MarketHelper::formatAmount((int) $ac['amount']);
        $ac['price_fmt']          = number_format((int) $ac['price_ntx'], 0, ',', '.');
        $ac['image']              = MarketHelper::itemImage($ac['item_type'], (int) $ac['item_id']);
        $ac['category']           = MarketHelper::getCategoryLabel($ac['item_type']);
        $ac['date']               = date('d/m/Y H:i', (int) $ac['created']);
        $ac['cancel_reason_label']= getAdminCancelReasonLabel($ac['cancel_reason']);
        $ac['is_seller_attack']   = ($ac['cancel_reason'] === 'seller_no_resources');
    }
    unset($ac);

    // --- Ítems para crear ofertas ---
    $items = MarketHelper::getSellableItems();
    if (!is_array($items)) $items = array();

    foreach ($items as &$item) {
        $item['image'] = MarketHelper::itemImage($item['type'], $item['id']);
    }
    unset($item);

    // ============================================
    // ASIGNAR VARIABLES Y MOSTRAR
    // ============================================
    $template->assign_vars(array(
        'fund'         => $fund,
        'fund_total'   => number_format((int) $fund['total_earned'], 0, ',', '.'),
        'fund_seller'  => number_format((int) $fund['from_seller'],  0, ',', '.'),
        'fund_buyer'   => number_format((int) $fund['from_buyer'],   0, ',', '.'),
        'stats'        => $stats,
        'admin_offers' => $adminOffers,
        'items'        => $items,
        'message'      => $message,
        'msgType'      => $msgType,
        // 🆕 v2.1 — Auto-cancelaciones
        'auto_cancelled_offers' => $autoCancelledOffers,
        'has_auto_cancelled'    => count($autoCancelledOffers) > 0,
        'autocancel_stats'      => array(
            'seller_no_resources' => (int) $stats['autocancelled_seller'],
            'buyer_no_ntx'        => (int) $stats['autocancelled_buyer'],
            'total'               => (int) $stats['autocancelled_seller'] + (int) $stats['autocancelled_buyer'],
        ),
    ));

    $template->show("marketAdminPage.tpl");
}