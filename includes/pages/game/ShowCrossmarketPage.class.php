<?php
/**
 * ============================================================
 * ShowCrossMarketPage — Mercado Cruzado AstroIO v1.2
 * ============================================================
 * Página del jugador para el mercado cruzado.
 *
 * v1.2 — CAMBIOS:
 *  - Ahora usa MarketHelper::getSellableItems() en prepareGlobal()
 *    para extraer la lista dinámica de Naves, Defensas y Cofres
 *    (incluyendo los climáticos) y pasarla al template como JSON.
 *  - De esta forma, el Mercado Internacional tendrá exactamente
 *    las mismas opciones que el Mercado Nacional.
 *
 * Rutas:
 *   ?page=crossmarket                        → show()
 *   ?page=crossmarket&tab=explore            → show() (pestaña explorar)
 *   ?page=crossmarket&tab=sell               → show() (pestaña vender)
 *   ?page=crossmarket&tab=buy                → show() (pestaña comprar)
 *   ?page=crossmarket&tab=mine               → show() (mis órdenes)
 *   ?page=crossmarket&tab=history            → show() (historial)
 *   ?page=crossmarket&mode=publishSell       → publishSell() (POST)
 *   ?page=crossmarket&mode=publishBuy        → publishBuy() (POST)
 *   ?page=crossmarket&mode=buy&id=X          → buy() (GET)
 *   ?page=crossmarket&mode=fulfill&id=X      → fulfill() (GET)
 *   ?page=crossmarket&mode=cancel&id=X       → cancel() (GET)
 *
 * Requiere:
 *   - CrossMarketHelper.class.php
 *   - MarketHelper.class.php
 *   - uni1_cross_orders
 *   - uni1_cross_trades
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

class ShowCrossmarketPage extends AbstractGamePage
{
    public $defaultController = 'show';

    private $userId;

    public function __construct()
    {
        global $USER;

        parent::__construct();

        require_once ROOT_PATH.'includes/classes/CrossMarketHelper.class.php';
        // 🆕 v1.2: Cargar MarketHelper para obtener la lista de ítems
        require_once ROOT_PATH.'includes/classes/MarketHelper.class.php';

        $this->userId = (int)$USER['id'];
    }

    /* ============================================================
     * PUNTO DE ENTRADA
     * ============================================================ */
    public function show()
    {
        // Expirar órdenes vencidas al entrar
        CrossMarketHelper::expireOrders();

        // Feedback desde URL
        $this->handleFeedback();

        $tab = isset($_GET['tab']) ? $_GET['tab'] : 'explore';

        switch ($tab) {
            case 'sell':    $this->prepareSell();    break;
            case 'buy':     $this->prepareBuy();     break;
            case 'mine':    $this->prepareMine();    break;
            case 'history': $this->prepareHistory(); break;
            case 'explore':
            default:        $this->prepareExplore(); break;
        }

        $this->prepareGlobal($tab);

        $this->display('page.crossmarket.default.tpl');
    }

    /* ============================================================
     * FEEDBACK
     * ============================================================ */
    private function handleFeedback()
    {
        $ok    = isset($_GET['ok'])    ? $_GET['ok']    : '';
        $error = isset($_GET['error']) ? $_GET['error'] : '';

        $msgOk  = '';
        $msgErr = '';
        $errorType = '';

        switch ($ok) {
            case 'published_sell':
                $msgOk = 'Orden de venta publicada. Tus items siguen en tu planeta hasta que alguien compre.';
                break;
            case 'published_buy':
                $msgOk = 'Orden de compra publicada. Tu UNTX sigue en tu cuenta hasta que alguien acepte.';
                break;
            case 'bought':
                $msgOk = 'Compra realizada. Los items fueron entregados a tu planeta.';
                break;
            case 'fulfilled':
                $msgOk = 'Orden aceptada. Los items fueron entregados y recibiste CUP.';
                break;
            case 'cancelled':
                $msgOk = 'Orden cancelada.';
                break;
        }

        if ($error !== '') {
            $msgErr = urldecode($error);
            $errorType = 'error';

            if (stripos($msgErr, 'cancelada automaticamente') !== false
                || stripos($msgErr, 'cancelada automáticamente') !== false) {
                $errorType = 'autocancelled';
            }
        }

        $this->assign([
            'feedback_ok'         => $msgOk,
            'feedback_error'      => $msgErr,
            'feedback_error_type' => $errorType,
        ]);
    }

    /* ============================================================
     * DATOS GLOBALES
     * ============================================================ */
    private function prepareGlobal($tab)
    {
        $balanceNac = CrossMarketHelper::getBalance($this->userId, CrossMarketHelper::CURRENCY_NAC);
        $balanceInt = CrossMarketHelper::getBalance($this->userId, CrossMarketHelper::CURRENCY_INT);

        // 🆕 v1.2: Obtener ítems dinámicos y agruparlos para JS
        $sellableItems = MarketHelper::getSellableItems();
        $groupedItems = [];
        
        foreach ($sellableItems as $item) {
            // Ignoramos recursos para el JS, ya que están fijos en el HTML
            if (in_array($item['type'], ['metal', 'crystal', 'deuterium', 'dark_matter'])) {
                continue;
            }
            $groupedItems[$item['type']][] = [
                'id' => $item['id'],
                'name' => $item['name']
            ];
        }

        $this->assign([
            'tab_active'        => $tab,
            'balance_nac'       => number_format($balanceNac, 0, ',', '.'),
            'balance_int'       => number_format($balanceInt, 0, ',', '.'),
            'balance_nac_raw'   => $balanceNac,
            'balance_int_raw'   => $balanceInt,
            'action_url'        => 'game.php?page=crossmarket',
            'tasa_qvapay'       => CrossMarketHelper::getTasaQvapay(),
            'spread_pct'        => CrossMarketHelper::getSpreadPct(),
            'unit_usd'          => CrossMarketHelper::getUnitUsd(),
            'cross_items_json'  => json_encode($groupedItems), // 🆕 v1.2
        ]);
    }

    /* ============================================================
     * PESTAÑA EXPLORAR
     * ============================================================ */
    private function prepareExplore()
    {
        $prefix = $this->prefix();
        $db = Database::get();

        $orders = $db->select(
            "SELECT o.*, u.username AS owner_name
             FROM `".$prefix."cross_orders` o
             LEFT JOIN `".$prefix."users` u ON u.id = o.user_id
             WHERE o.status = 'open'
               AND o.expires_at > :now
             ORDER BY o.created_at DESC
             LIMIT 100",
            [':now' => defined('TIMESTAMP') ? TIMESTAMP : time()]
        );

        if (!is_array($orders)) $orders = [];

        foreach ($orders as &$o) {
            $o['is_mine'] = ((int)$o['user_id'] === $this->userId);
            $o['side_label'] = ($o['side'] === 'sell') ? 'Venta' : 'Compra';
            $o['amount_fmt'] = number_format((int)$o['amount'], 0, ',', '.');
            $o['price_fmt']  = number_format((int)$o['price_amount'], 0, ',', '.');
        }
        unset($o);

        $this->assign(['orders' => $orders]);
    }

    /* ============================================================
     * PESTAÑA VENDER (nacional)
     * ============================================================ */
    private function prepareSell()
    {
        global $PLANET, $USER;
        $prefix = $this->prefix();
        $db = Database::get();

        // Cargar contadores de cofres desde users_market
        $marketRow = $db->selectSingle(
            "SELECT box_common, box_rare, box_legendary,
                    box_climate_minor, box_climate_major, box_climate_dominion
             FROM `".$prefix."users_market`
             WHERE user_id = :u",
            [':u' => $this->userId]
        );

        $boxCommon    = $marketRow ? (int)$marketRow['box_common'] : 0;
        $boxRare      = $marketRow ? (int)$marketRow['box_rare'] : 0;
        $boxLegendary = $marketRow ? (int)$marketRow['box_legendary'] : 0;
        $boxClimateMinor    = $marketRow ? (int)$marketRow['box_climate_minor'] : 0;
        $boxClimateMajor    = $marketRow ? (int)$marketRow['box_climate_major'] : 0;
        $boxClimateDominion = $marketRow ? (int)$marketRow['box_climate_dominion'] : 0;

        $this->assign([
            'planet_id'          => isset($PLANET['id']) ? (int)$PLANET['id'] : 0,
            'metal'              => isset($PLANET['metal']) ? (float)$PLANET['metal'] : 0,
            'crystal'            => isset($PLANET['crystal']) ? (float)$PLANET['crystal'] : 0,
            'deuterium'          => isset($PLANET['deuterium']) ? (float)$PLANET['deuterium'] : 0,
            'containers'         => isset($USER['containers']) ? (int)$USER['containers'] : 0,
            
            // Contadores de cofres
            'box_common'         => $boxCommon,
            'box_rare'           => $boxRare,
            'box_legendary'      => $boxLegendary,
            'box_climate_minor'    => $boxClimateMinor,
            'box_climate_major'    => $boxClimateMajor,
            'box_climate_dominion' => $boxClimateDominion,
        ]);
    }

    /* ============================================================
     * PESTAÑA COMPRAR (internacional)
     * ============================================================ */
    private function prepareBuy()
    {
        $this->assign([]);
    }

    /* ============================================================
     * PESTAÑA MIS ÓRDENES
     * ============================================================ */
    private function prepareMine()
    {
        $prefix = $this->prefix();
        $db = Database::get();

        $myOrders = $db->select(
            "SELECT * FROM `".$prefix."cross_orders`
             WHERE user_id = :u
             ORDER BY created_at DESC
             LIMIT 100",
            [':u' => $this->userId]
        );

        if (!is_array($myOrders)) $myOrders = [];

        foreach ($myOrders as &$o) {
            $o['is_sell'] = ($o['side'] === 'sell');
            $o['side_label'] = $o['is_sell'] ? 'Venta' : 'Compra';
            $o['amount_fmt'] = number_format((int)$o['amount'], 0, ',', '.');
            $o['price_fmt']  = number_format((int)$o['price_amount'], 0, ',', '.');
            $o['status_label'] = $this->statusLabel($o['status']);
        }
        unset($o);

        $this->assign(['my_orders' => $myOrders]);
    }

    /* ============================================================
     * PESTAÑA HISTORIAL
     * ============================================================ */
    private function prepareHistory()
    {
        $prefix = $this->prefix();
        $db = Database::get();

        $trades = $db->select(
            "SELECT t.*,
                    ub.username AS buyer_name,
                    us.username AS seller_name
             FROM `".$prefix."cross_trades` t
             LEFT JOIN `".$prefix."users` ub ON ub.id = t.buyer_id
             LEFT JOIN `".$prefix."users` us ON us.id = t.seller_id
             WHERE t.buyer_id = :u OR t.seller_id = :u
             ORDER BY t.created_at DESC
             LIMIT 100",
            [':u' => $this->userId]
        );

        if (!is_array($trades)) $trades = [];

        foreach ($trades as &$t) {
            $t['is_buyer']   = ((int)$t['buyer_id'] === $this->userId);
            $t['role_label'] = $t['is_buyer'] ? 'Compra' : 'Venta';
            $t['amount_fmt'] = number_format((int)$t['amount'], 0, ',', '.');
            $t['date']       = date('d/m H:i', (int)$t['created_at']);
        }
        unset($t);

        $this->assign(['trades' => $trades]);
    }

    /* ============================================================
     * ACCIÓN — PUBLICAR VENTA (nacional)
     * ============================================================ */
    public function publishSell()
    {
        $data = [
            'item_type'   => isset($_POST['item_type'])   ? $_POST['item_type'] : '',
            'item_id'     => isset($_POST['item_id'])     ? (int)$_POST['item_id'] : 0,
            'item_name'   => $this->getItemName(
                isset($_POST['item_type']) ? $_POST['item_type'] : '',
                isset($_POST['item_id'])   ? (int)$_POST['item_id'] : 0
            ),
            'item_amount' => isset($_POST['item_amount']) ? (int)$_POST['item_amount'] : 0,
            'amount_cup'  => isset($_POST['amount_cup'])  ? (int)$_POST['amount_cup'] : 0,
        ];

        $result = CrossMarketHelper::createSellOrder($this->userId, $data);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=crossmarket&tab=sell&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=crossmarket&tab=mine&ok=published_sell');
    }

    /* ============================================================
     * ACCIÓN — PUBLICAR COMPRA (internacional)
     * ============================================================ */
    public function publishBuy()
    {
        $data = [
            'item_type'   => isset($_POST['item_type'])   ? $_POST['item_type'] : '',
            'item_id'     => isset($_POST['item_id'])     ? (int)$_POST['item_id'] : 0,
            'item_name'   => $this->getItemName(
                isset($_POST['item_type']) ? $_POST['item_type'] : '',
                isset($_POST['item_id'])   ? (int)$_POST['item_id'] : 0
            ),
            'item_amount' => isset($_POST['item_amount']) ? (int)$_POST['item_amount'] : 0,
            'untx_amount' => isset($_POST['untx_amount']) ? (int)$_POST['untx_amount'] : 0,
        ];

        $result = CrossMarketHelper::createBuyOrder($this->userId, $data);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=crossmarket&tab=buy&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=crossmarket&tab=mine&ok=published_buy');
    }

    /* ============================================================
     * ACCIÓN — COMPRAR ORDEN DE VENTA (internacional)
     * ============================================================ */
    public function buy()
    {
        $orderId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        $planetId = isset($GLOBALS['PLANET']['id']) ? (int)$GLOBALS['PLANET']['id'] : 0;

        $result = CrossMarketHelper::executeSellToInternational($this->userId, $orderId, $planetId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=crossmarket&tab=explore&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=crossmarket&tab=history&ok=bought');
    }

    /* ============================================================
     * ACCIÓN — ACEPTAR ORDEN DE COMPRA (nacional)
     * ============================================================ */
    public function fulfill()
    {
        $orderId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        $planetId = isset($GLOBALS['PLANET']['id']) ? (int)$GLOBALS['PLANET']['id'] : 0;

        $result = CrossMarketHelper::executeBuyFromInternational($this->userId, $orderId, $planetId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=crossmarket&tab=explore&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=crossmarket&tab=history&ok=fulfilled');
    }

    /* ============================================================
     * ACCIÓN — CANCELAR ORDEN
     * ============================================================ */
    public function cancel()
    {
        $orderId = isset($_GET['id']) ? (int)$_GET['id'] : 0;

        $result = CrossMarketHelper::cancelOrder($this->userId, $orderId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=crossmarket&tab=mine&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=crossmarket&tab=mine&ok=cancelled');
    }

    /* ============================================================
     * UTILIDADES
     * ============================================================ */
    private function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    private function statusLabel($status)
    {
        $map = [
            'open'      => 'Abierta',
            'locked'    => 'Bloqueada',
            'filled'    => 'Completada',
            'cancelled' => 'Cancelada',
            'expired'   => 'Expirada',
        ];
        return isset($map[$status]) ? $map[$status] : $status;
    }

    private function redirect($url)
    {
        header('Location: '.$url);
        exit;
    }

    /**
     * Genera un nombre legible para el ítem a partir de su
     * tipo e id, para que las órdenes no se guarden con nombre vacío.
     */
    private function getItemName($type, $id)
    {
        global $LNG;

        switch ($type) {
            case 'metal':       return 'Metal';
            case 'crystal':     return 'Cristal';
            case 'deuterium':   return 'Deuterio';
            case 'dark_matter': return 'Materia Oscura';
            case 'container':   return 'Cofre Genérico';

            case 'box':
                $map = [1 => 'Cofre Común', 2 => 'Cofre Raro', 3 => 'Cofre Legendario'];
                return isset($map[$id]) ? $map[$id] : 'Cofre del Mercado';

            case 'box_climate':
                $map = [
                    1 => 'Cofre Climático Menor',
                    2 => 'Cofre Climático Mayor',
                    3 => 'Cofre Climático Dominio'
                ];
                return isset($map[$id]) ? $map[$id] : 'Cofre Climático';

            case 'ship':
            case 'defense':
                // Usar el nombre traducido del juego si existe
                if (isset($LNG['tech'][$id]) && !empty($LNG['tech'][$id])) {
                    return $LNG['tech'][$id];
                }
                return ($type === 'ship') ? 'Nave #'.$id : 'Defensa #'.$id;
        }

        return 'Ítem';
    }
}