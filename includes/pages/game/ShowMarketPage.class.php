<?php
/**
 * ============================================================
 * ShowMarketPage — Página del Mercado AstroIO v2.9
 * ============================================================
 * Router nativo de 2Moons:
 *   ?page=market                       → show()
 *   ?page=market&mode=buy&id=X         → buy()
 *   ?page=market&mode=fulfill&id=X     → fulfill()
 *   ?page=market&mode=cancel&id=X      → cancel()
 *   ?page=market&mode=publishSell      → publishSell()
 *   ?page=market&mode=publishBuy       → publishBuy()
 *   ?page=market&mode=suggest          → suggest() (AJAX)
 *   ?page=market&mode=chart            → chart()   (AJAX)
 *   ?page=market&mode=improvements     → improvements() (AJAX)
 *   ?page=market&mode=publishColony    → publishColony()
 *   ?page=market&mode=buyColony&id=X   → buyColony()
 *   ?page=market&mode=cancelColony&id=X→ cancelColony()
 *
 * v2.7 — NUEVO (Cofre Genérico):
 *  - Soporte para vender el COFRE GENÉRICO (uni1_users.containers)
 *    en el Mercado.
 *
 * v2.8 — NUEVO (Cofres Climáticos):
 *  - `prepareBoxes()` ahora muestra los 3 cofres climáticos.
 *
 * v2.9 — NUEVO (Mercado Negro de Colonias):
 *  - Añadida pestaña 'colonies' con prepareColonies().
 *  - Añadidos métodos publishColony(), buyColony(), cancelColony().
 *  - Añadidos feedbacks colony_published/bought/cancelled.
 *  - Requiere ColoniesHelper.class.php.
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

class ShowMarketPage extends AbstractGamePage
{
    public $defaultController = 'show';

    /** Factor de multiplicación para recursos (1 = 1000 unidades) */
    const RESOURCE_MULTIPLIER = 1000;

    private $userId;

    public function __construct()
    {
        global $USER;

        parent::__construct();

        // Cargar helpers
        require_once ROOT_PATH.'includes/classes/MarketHelper.class.php';
        require_once ROOT_PATH.'includes/classes/MarketTrendsHelper.class.php';
        require_once ROOT_PATH.'includes/classes/ColoniesHelper.class.php';

        $this->userId = (int)$USER['id'];

        // Asegurar fila en uni1_users_market
        MarketHelper::ensureUser($this->userId);
    }

    /* ============================================================
     * UTILIDAD — PREFIJO DE TABLAS
     * ============================================================ */
    private function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /* ============================================================
     * UTILIDAD — ¿Es un recurso?
     * ============================================================ */
    private function isResource($itemType)
    {
        return in_array($itemType, ['metal', 'crystal', 'deuterium', 'dark_matter'], true);
    }

    /* ============================================================
     * UTILIDAD — CLAVE DE MATERIA OSCURA EN $USER
     * ============================================================ */
    private function getDarkMatterKey()
    {
        global $resource;
        if (isset($resource[921]) && is_string($resource[921])) {
            return $resource[921];
        }
        return 'dark_matter';
    }

    private function getDarkMatterAmount()
    {
        global $USER, $resource;

        $keys = [];
        if (isset($resource[921])) $keys[] = $resource[921];
        $keys[] = 'dark_matter';
        $keys[] = 'dm';
        $keys[] = 'darkmatter';
        $keys[] = 'matter';

        foreach ($keys as $k) {
            if ($k && isset($USER[$k])) {
                return (int)$USER[$k];
            }
        }
        return 0;
    }

    /* ============================================================
     * PUNTO DE ENTRADA — Vista principal con pestañas
     * ============================================================ */
    public function show()
    {
        // Hook de expiración (aprovecha la visita al mercado)
        MarketHelper::expireOffers();

        // Feedback desde URL (?ok=...&error=...)
        $this->handleFeedback();

        $tab = isset($_GET['tab']) ? $_GET['tab'] : 'explore';

        // Preparar datos según pestaña
        switch ($tab) {
            case 'sell':     $this->prepareSell();     break;
            case 'buy':      $this->prepareBuyForm();  break;
            case 'boxes':    $this->prepareBoxes();    break;
            case 'trends':   $this->prepareTrends();   break;
            case 'mine':     $this->prepareMine();     break;
            case 'history':  $this->prepareHistory();  break;
            case 'colonies': $this->prepareColonies(); break;
            case 'explore':
            default:         $this->prepareExplore();  break;
        }

        // Datos globales
        $this->prepareGlobal($tab);

        $this->display('page.market.default.tpl');
    }

    /* ============================================================
     * v2.6.1 — FEEDBACK — ok / error desde URL
     * ------------------------------------------------------------
     * Detecta auto-cancelaciones (por ataque al vendedor o por
     * falta de NTX del comprador) para mostrar un aviso visual
     * diferenciado al usuario.
     *
     * v2.9 — Añadidos feedbacks de colonias.
     * ============================================================ */
    private function handleFeedback()
    {
        $ok    = isset($_GET['ok'])    ? $_GET['ok']    : '';
        $error = isset($_GET['error']) ? $_GET['error'] : '';

        $msg_ok  = '';
        $msg_err = '';
        $error_type = '';

        switch ($ok) {
            case 'bought':
                $msg_ok = '¡Compra realizada con éxito! Los ítems han sido '
                        . 'añadidos a tu planeta.';
                break;

            case 'fulfilled':
                $msg_ok = '¡Ítem entregado! Has recibido NTX-20 en tu cuenta.';
                break;

            case 'cancelled':
                $msg_ok = 'Oferta cancelada. Tus naves y recursos siguen en tu '
                        . 'planeta (nunca se quitaron).';
                break;

            case 'published':
                $msg_ok = '¡Oferta publicada! Recuerda: tus naves/recursos '
                        . 'SIGUEN en tu planeta y son vulnerables a ataques. '
                        . 'Si te atacan y los destruyen, la oferta se cancelará '
                        . 'automáticamente cuando alguien intente comprarla.';
                break;

            case 'buy_published':
                $msg_ok = '¡Orden de compra publicada! Recuerda: el NTX-20 '
                        . 'SIGUE en tu cuenta y es visible/usable. Si lo gastas '
                        . 'antes de que alguien venda, la orden se cancelará '
                        . 'automáticamente.';
                break;

            case 'colony_published':
                $msg_ok = '¡Colonia publicada en venta! Se venderá junto con todo lo '
                        . 'que hay dentro (edificios, defensas, naves y recursos).';
                break;

            case 'colony_bought':
                $msg_ok = '¡Has comprado la colonia! Ya aparece en tu lista de planetas.';
                break;

            case 'colony_cancelled':
                $msg_ok = 'Listado de colonia cancelado. Tu colonia sigue siendo tuya.';
                break;
        }

        if ($error !== '') {
            $msg_err = urldecode($error);

            // v2.6.1 — Detectar auto-cancelaciones por palabras clave
            if (stripos($msg_err, 'cancelada automaticamente') !== false
                || stripos($msg_err, 'cancelada automáticamente') !== false
                || stripos($msg_err, 'cancelada automatico') !== false
                || stripos($msg_err, 'cancelada automático') !== false) {
                $error_type = 'autocancelled';
            } else {
                $error_type = 'error';
            }
        }

        $this->assign([
            'feedback_ok'         => $msg_ok,
            'feedback_error'      => $msg_err,
            'feedback_error_type' => $error_type,
        ]);
    }

    /* ============================================================
     * PREPARAR DATOS GLOBALES
     * ------------------------------------------------------------
     * v2.7 — Añadido `container_balance` para el template.
     * ============================================================ */
    private function prepareGlobal($tab)
    {
        global $USER;

        $balance   = MarketHelper::getBalance($this->userId);
        $frozen    = MarketHelper::getFrozenBalance($this->userId);
        $available = MarketHelper::getAvailableBalance($this->userId);
        $isVip     = MarketHelper::isVip($this->userId);
        $limit     = MarketHelper::getDailyLimit($this->userId);
        $today     = MarketHelper::getOffersToday($this->userId);

        // v2.7 — Cofres genéricos disponibles (uni1_users.containers)
        $containerBalance = isset($USER['containers']) ? (int)$USER['containers'] : 0;

        $this->assign([
            'balance_ntx'       => number_format($balance, 0, ',', '.'),
            'balance_raw'       => $balance,
            'balance_frozen'    => number_format($frozen, 0, ',', '.'),
            'balance_available' => number_format($available, 0, ',', '.'),
            'is_vip'            => $isVip,
            'daily_limit'       => $limit,
            'daily_limit_txt'   => $limit,
            'offers_today'      => $today,
            'offers_remaining'  => max(0, $limit - $today),
            'tab_active'        => $tab,
            'action_url'        => 'game.php?page=market',
            // Factor para JS (para mostrar el hint en el form)
            'resource_multiplier' => self::RESOURCE_MULTIPLIER,
            // v2.7 — Cofre genérico disponible
            'container_balance' => $containerBalance,
            // Valores por defecto para el gráfico
            'chart_labels_json' => '[]',
            'chart_prices_json' => '[]',
            'chart_mins_json'   => '[]',
            'chart_maxs_json'   => '[]',
            // Valores por defecto para el resto de pestañas
            'widget'            => ['top_sold'=>null, 'top_demanded'=>null],
            'top_sold'          => [],
            'top_demanded'      => [],
            'trendable_items'   => [],
            'chart_item'        => null,
            'chart_trend'       => ['dir'=>'=', 'pct'=>0, 'icon'=>'=', 'class'=>'flat'],
        ]);
    }

    /* ============================================================
     * PESTAÑA EXPLORAR
     * ============================================================ */
    private function prepareExplore()
    {
        $filters = [
            'cat'      => isset($_GET['cat'])      ? $_GET['cat']      : 'all',
            'type'     => isset($_GET['type'])     ? $_GET['type']     : 'all',
            'sort'     => isset($_GET['sort'])     ? $_GET['sort']     : 'recent',
            'q'        => isset($_GET['q'])        ? trim($_GET['q'])  : '',
            'duration' => isset($_GET['duration']) ? $_GET['duration'] : '',
        ];
        $page = isset($_GET['p']) ? max(1, (int)$_GET['p']) : 1;

        $offers = MarketHelper::getOffers($filters, $page);
        $total  = MarketHelper::countOffers($filters);
        $pages  = max(1, ceil($total / MarketHelper::PAGE_SIZE));

        foreach ($offers as &$o) {
            $o = $this->enrichOffer($o);
        }
        unset($o);

        $pagination = [];
        $start = max(1, $page - 2);
        $end   = min($pages, $page + 2);
        for ($i = $start; $i <= $end; $i++) {
            $pagination[] = $i;
        }

        $this->assign([
            'offers'      => $offers,
            'total'       => $total,
            'shown'       => count($offers),
            'page'        => $page,
            'pages'       => $pages,
            'pagination'  => $pagination,
            'filters'     => $filters,
            'has_filters' => ($filters['cat'] !== 'all'
                           || $filters['type'] !== 'all'
                           || $filters['q'] !== ''),
        ]);
    }

    /* ============================================================
     * ENRIQUECER OFERTA — v2.6.1
     * ============================================================ */
    private function enrichOffer($o)
    {
        $o['category']   = MarketHelper::getCategoryLabel($o['item_type']);
        $o['amount_fmt'] = MarketHelper::formatAmount((int)$o['amount']);
        $o['price_fmt']  = number_format((int)$o['price_ntx'], 0, ',', '.');
        $o['image']      = MarketHelper::itemImage($o['item_type'], (int)$o['item_id']);
        $o['is_admin']   = ((int)$o['admin_offer'] === 1);
        $o['is_buy']     = ($o['offer_type'] === 'buy');
        $o['is_mine']    = ((int)$o['seller_id'] === $this->userId);
        $o['is_improvement'] = ($o['item_type'] === 'improvement');
        $o['is_resource']    = $this->isResource($o['item_type']);

        // v2.6.1 — Motivo de cancelación (si aplica)
        $o['cancel_reason']       = isset($o['cancel_reason']) ? $o['cancel_reason'] : '';
        $o['cancel_reason_label'] = $this->getCancelReasonLabel($o['cancel_reason']);

        // Para mejoras: añadir info extendida
        if ($o['is_improvement']) {
            $info = MarketHelper::getItemInfo('improvement', (int)$o['item_id']);
            if ($info) {
                $o['chain_name']  = $info['chain_name'];
                $o['level']       = $info['level'];
                $o['stat1']       = $info['stat1'];
                $o['stat2']       = $info['stat2'];
                $o['item_cat']    = $info['category'];
                $o['stat_text']   = $this->buildStatText($info);
            }
        }

        // v2.6 — Cálculo de precios y fees con PRIVACIDAD
        $price = (int)$o['price_ntx'];

        $o['fee_pct']       = 0;
        $o['fee_amt']       = 0;
        $o['fee_label']     = '';
        $o['buyer_pays']    = $price;
        $o['net_receive']   = $price;
        $o['show_fee_info'] = false;

        if ($o['is_admin']) {
            $o['fee_label']     = 'Sin comisión';
            $o['show_fee_info'] = false;

        } elseif ($o['is_buy']) {
            $duration = (int)$o['duration'];

            if ($o['is_mine']) {
                $o['fee_label']     = '';
                $o['show_fee_info'] = false;

            } else {
                $acceptorPct = MarketHelper::getAcceptorFeePct($this->userId, $duration);
                $o['fee_pct']       = $acceptorPct;
                $o['fee_amt']       = (int)ceil($price * $acceptorPct / 100);
                $o['fee_label']     = 'Comisión aceptador';
                $o['net_receive']   = $price - $o['fee_amt'];
                $o['show_fee_info'] = true;
            }

        } else {
            $duration = (int)$o['duration'];

            if ($o['is_mine']) {
                $sellerPct = MarketHelper::getSellerFeePct($this->userId, $duration);
                $o['fee_pct']       = $sellerPct;
                $o['fee_amt']       = (int)ceil($price * $sellerPct / 100);
                $o['fee_label']     = 'Comisión vendedor';
                $o['net_receive']   = $price - $o['fee_amt'];
                $o['show_fee_info'] = true;

            } else {
                $o['fee_label']     = '';
                $o['show_fee_info'] = false;
            }
        }

        $o['buyer_pays_fmt']   = number_format($o['buyer_pays'], 0, ',', '.');
        $o['net_receive_fmt']  = number_format($o['net_receive'], 0, ',', '.');
        $o['fee_amt_fmt']      = number_format($o['fee_amt'], 0, ',', '.');

        if ($o['is_admin']) {
            $o['timer_text'] = 'Sin expiración';
            $o['timer_cls']  = 'infinite';
            $o['remaining']  = 0;
        } else {
            $o['remaining']  = max(0, (int)$o['expires'] - TIMESTAMP);
            $o['timer_text'] = $this->formatCountdown($o['remaining']);
            $o['timer_cls']  = $this->calcUrgency($o['remaining']);
        }

        return $o;
    }

    /* ============================================================
     * v2.6.1 — TEXTO LEGIBLE DEL MOTIVO DE CANCELACIÓN
     * ============================================================ */
    private function getCancelReasonLabel($reason)
    {
        $map = [
            'seller_cancelled'    => 'Cancelada por el vendedor',
            'seller_no_resources' => 'Auto-cancelada: el vendedor ya no tenía los recursos (posible ataque)',
            'buyer_no_ntx'        => 'Auto-cancelada: el comprador ya no tenía el NTX-20',
            'expired'             => 'Expirada sin completarse',
        ];

        if (empty($reason)) return '';
        return isset($map[$reason]) ? $map[$reason] : ucfirst(str_replace('_', ' ', $reason));
    }

    /* ============================================================
     * UTILIDAD — TEXTO DE STATS DE UNA MEJORA
     * ============================================================ */
    private function buildStatText($info)
    {
        $percentages = [
            1=>3, 2=>6, 3=>10, 4=>15, 5=>20, 6=>25, 7=>30, 8=>35,
            9=>40, 10=>45, 11=>50, 12=>55, 13=>60, 14=>65, 15=>70
        ];
        $pct = isset($percentages[(int)$info['level']])
            ? $percentages[(int)$info['level']]
            : 0;

        $names = [
            'ataque'=>'Ataque', 'defensa'=>'Defensa', 'escudo'=>'Escudo',
            'motriz'=>'Motriz', 'logistica'=>'Logistica',
            'cadencia'=>'Cadencia', 'precision'=>'Precision'
        ];

        $parts = [];
        if (!empty($info['stat1']) && isset($names[$info['stat1']])) {
            $parts[] = '+'.$pct.'% '.$names[$info['stat1']];
        }
        if (!empty($info['stat2']) && isset($names[$info['stat2']])) {
            $parts[] = '+'.$pct.'% '.$names[$info['stat2']];
        }
        return implode(' / ', $parts);
    }

    /* ============================================================
     * PESTAÑA VENDER
     * ============================================================ */
    private function prepareSell()
    {
        global $PLANET, $USER, $resource;

        $items = MarketHelper::getSellableItems();

        // v2.8 — Inyectar los 3 cofres climáticos si no existen en la lista
        $climateBoxes = [
            ['type' => 'box_climate', 'id' => 1, 'name' => 'Cofre Climático Menor'],
            ['type' => 'box_climate', 'id' => 2, 'name' => 'Cofre Climático Mayor'],
            ['type' => 'box_climate', 'id' => 3, 'name' => 'Cofre Climático Dominio'],
        ];
        foreach ($climateBoxes as $cb) {
            $exists = false;
            foreach ($items as $i) {
                if ($i['type'] === $cb['type'] && $i['id'] === $cb['id']) {
                    $exists = true; break;
                }
            }
            if (!$exists) {
                $items[] = $cb;
            }
        }

        $shipMap  = MarketHelper::getShipMap($PLANET);
        $dmAmount = $this->getDarkMatterAmount();

        $u = MarketHelper::ensureUser($this->userId);

        foreach ($items as &$item) {
            switch ($item['type']) {
                case 'metal':       $avail = (int)$PLANET['metal'];     break;
                case 'crystal':     $avail = (int)$PLANET['crystal'];   break;
                case 'deuterium':   $avail = (int)$PLANET['deuterium']; break;
                case 'dark_matter': $avail = $dmAmount;                 break;
                case 'ship':
                case 'defense':
                    $avail = isset($shipMap[$item['id']]) ? $shipMap[$item['id']] : 0;
                    break;
                case 'box':
                    $key   = MarketHelper::$BOXES[$item['id']];
                    $avail = (int)$u[$key];
                    break;
                case 'box_climate':
                    $keyMap = [
                        1 => 'box_climate_minor',
                        2 => 'box_climate_major',
                        3 => 'box_climate_dominion',
                    ];
                    $key = $keyMap[$item['id']];
                    $avail = (int)$u[$key];
                    break;
                case 'container':
                    $avail = isset($USER['containers']) ? (int)$USER['containers'] : 0;
                    break;
                default: $avail = 0;
            }
            $item['available']   = $avail;
            $item['image']       = MarketHelper::itemImage($item['type'], $item['id']);
            $item['is_resource'] = $this->isResource($item['type']);
        }
        unset($item);

        // IMPROVEMENTS
        $improvements = MarketHelper::getSellableImprovements($this->userId);
        $improvementList = [];
        foreach ($improvements as $imp) {
            $imp['stat_text'] = $this->buildStatText([
                'level' => $imp['level'],
                'stat1' => $imp['stat1'],
                'stat2' => $imp['stat2'],
            ]);
            $improvementList[] = $imp;
        }

        $warning_text = 'IMPORTANTE: al publicar una oferta, tus naves/recursos '
                      . 'NO se guardan en el mercado. Siguen en tu planeta y son '
                      . 'vulnerables a ataques. Si te atacan y los destruyen, la '
                      . 'oferta se cancelara automaticamente cuando alguien intente '
                      . 'comprarla. Publica solo lo que estes dispuesto a perder.';

        $this->assign([
            'sell_items'         => $items,
            'improvement_items'  => $improvementList,
            'has_improvements'   => count($improvementList) > 0,
            'planet_id'          => $PLANET['id'],
            'fee_24'             => MarketHelper::getSellerFeePct($this->userId, 24),
            'fee_48'             => MarketHelper::getSellerFeePct($this->userId, 48),
            'warning_no_storage' => true,
            'warning_text'       => $warning_text,
            'container_balance'  => isset($USER['containers']) ? (int)$USER['containers'] : 0,
        ]);
    }

    /* ============================================================
     * PESTAÑA COMPRAR (buy order)
     * ============================================================ */
    private function prepareBuyForm()
    {
        $items = MarketHelper::getSellableItems();

        // v2.8 — Inyectar los 3 cofres climáticos si no existen en la lista
        $climateBoxes = [
            ['type' => 'box_climate', 'id' => 1, 'name' => 'Cofre Climático Menor'],
            ['type' => 'box_climate', 'id' => 2, 'name' => 'Cofre Climático Mayor'],
            ['type' => 'box_climate', 'id' => 3, 'name' => 'Cofre Climático Dominio'],
        ];
        foreach ($climateBoxes as $cb) {
            $exists = false;
            foreach ($items as $i) {
                if ($i['type'] === $cb['type'] && $i['id'] === $cb['id']) {
                    $exists = true; break;
                }
            }
            if (!$exists) {
                $items[] = $cb;
            }
        }

        foreach ($items as &$item) {
            $item['image']       = MarketHelper::itemImage($item['type'], $item['id']);
            $item['is_resource'] = $this->isResource($item['type']);
        }
        unset($item);

        // IMPROVEMENTS — catálogo activo
        $prefix = $this->prefix();
        $db = Database::get();
        $activeSeasons = [];
        $rows = $db->select("SELECT season_number FROM `".$prefix."improvements_seasons` WHERE active = 1");
        foreach ($rows as $r) { $activeSeasons[] = (int)$r['season_number']; }

        $improvementCatalog = [];
        if (!empty($activeSeasons)) {
            $in = implode(',', $activeSeasons);
            $catalog = $db->select(
                "SELECT * FROM `".$prefix."improvements_catalog`
                 WHERE season IN ($in)
                 ORDER BY category ASC, chain_id ASC, level ASC"
            );
            foreach ($catalog as $c) {
                $improvementCatalog[] = [
                    'id'       => (int)$c['id'],
                    'name'     => $c['chain_name'].' Nv '.$c['level'],
                    'category' => $c['category'],
                    'level'    => (int)$c['level'],
                    'stat_text'=> $this->buildStatText([
                        'level' => $c['level'],
                        'stat1' => $c['stat1'],
                        'stat2' => $c['stat2'],
                    ]),
                ];
            }
        }

        $warning_text = 'IMPORTANTE: al publicar una orden de compra, tu NTX-20 '
                      . 'NO se guarda en el mercado. Sigue en tu cuenta y es '
                      . 'visible/usable. Si lo gastas antes de que alguien venda, '
                      . 'la orden se cancelara automaticamente cuando alguien intente '
                      . 'venderte. Publica solo lo que estes dispuesto a mantener.';

        $this->assign([
            'buy_items'           => $items,
            'improvement_catalog' => $improvementCatalog,
            'has_improvement_catalog' => count($improvementCatalog) > 0,
            'fee_24'              => MarketHelper::getAcceptorFeePct($this->userId, 24),
            'fee_48'              => MarketHelper::getAcceptorFeePct($this->userId, 48),
            'warning_no_storage'  => true,
            'warning_text'        => $warning_text,
        ]);
    }

    /* ============================================================
     * PESTAÑA CAJAS
     * ============================================================ */
    private function prepareBoxes()
    {
        $u = MarketHelper::ensureUser($this->userId);

        $boxes = [
            [
                'id'    => 1, 'name' => 'Cofre Común',
                'count' => (int)$u['box_common'],
                'image' => 'styles/theme/gow/gebaeude/100.gif',
                'desc'  => 'Recursos · Boosters · MO', 'color' => 'common',
            ],
            [
                'id'    => 2, 'name' => 'Cofre Raro',
                'count' => (int)$u['box_rare'],
                'image' => 'styles/theme/gow/gebaeude/200.gif',
                'desc'  => 'Naves · Recursos x2 · Boosters', 'color' => 'rare',
            ],
            [
                'id'    => 3, 'name' => 'Cofre Legendario',
                'count' => (int)$u['box_legendary'],
                'image' => 'styles/theme/gow/gebaeude/300.gif',
                'desc'  => 'Recompensas exclusivas VIP', 'color' => 'legendary',
            ],
            [
                'id'    => 4, 'name' => 'Cofre Climático Menor',
                'count' => (int)$u['box_climate_minor'],
                'image' => 'styles/theme/gow/gebaeude/100.gif',
                'desc'  => 'Reduce a la mitad los factores negativos del clima', 'color' => 'climate-minor',
            ],
            [
                'id'    => 5, 'name' => 'Cofre Climático Mayor',
                'count' => (int)$u['box_climate_major'],
                'image' => 'styles/theme/gow/gebaeude/200.gif',
                'desc'  => 'Neutraliza todos los factores negativos del clima', 'color' => 'climate-major',
            ],
            [
                'id'    => 6, 'name' => 'Cofre Climático Dominio',
                'count' => (int)$u['box_climate_dominion'],
                'image' => 'styles/theme/gow/gebaeude/300.gif',
                'desc'  => 'Convierte los negativos en positivos', 'color' => 'climate-dominion',
            ],
        ];

        $this->assign(['boxes' => $boxes]);
    }

    /* ============================================================
     * PESTAÑA TENDENCIAS
     * ============================================================ */
    private function prepareTrends()
    {
        $topSold     = MarketTrendsHelper::getTopSold(7, 5);
        $topDemanded = MarketTrendsHelper::getTopDemanded(7, 5);
        $widget      = MarketTrendsHelper::getWidgetSummary();
        $trendable   = MarketTrendsHelper::getTrendableItems(30);

        $maxSold = 0;
        foreach ($topSold as $t) {
            if ((int)$t['total'] > $maxSold) $maxSold = (int)$t['total'];
        }
        foreach ($topSold as &$t) {
            $t['pct']   = $maxSold > 0 ? round(($t['total'] / $maxSold) * 100) : 0;
            $t['image'] = MarketHelper::itemImage($t['item_type'], (int)$t['item_id']);
        }
        unset($t);

        $maxDem = 0;
        foreach ($topDemanded as $t) {
            if ((int)$t['demand'] > $maxDem) $maxDem = (int)$t['demand'];
        }
        foreach ($topDemanded as &$t) {
            $t['pct']   = $maxDem > 0 ? round(($t['demand'] / $maxDem) * 100) : 0;
            $t['image'] = MarketHelper::itemImage($t['item_type'], (int)$t['item_id']);
        }
        unset($t);

        $selType = isset($_GET['ct']) ? $_GET['ct']       : null;
        $selId   = isset($_GET['ci']) ? (int)$_GET['ci']  : null;

        if (!$selType && !empty($trendable)) {
            $selType = $trendable[0]['item_type'];
            $selId   = (int)$trendable[0]['item_id'];
        }

        $chartData = ['labels'=>[], 'prices'=>[], 'mins'=>[], 'maxs'=>[]];
        $chartItem = null;
        if ($selType !== null) {
            $chartData = MarketTrendsHelper::getChartData($selType, $selId, 7);
            $chartItem = ['type'=>$selType, 'id'=>$selId];
            $info = MarketHelper::getItemInfo($selType, $selId);
            $chartItem['name'] = $info ? $info['name'] : '';
        }

        $trend = ($selType !== null)
            ? MarketTrendsHelper::getTrend($selType, $selId, 7)
            : ['dir'=>'=', 'pct'=>0, 'icon'=>'=', 'class'=>'flat'];

        $this->assign([
            'top_sold'          => $topSold,
            'top_demanded'      => $topDemanded,
            'widget'            => $widget,
            'trendable_items'   => $trendable,
            'chart_item'        => $chartItem,
            'chart_labels'      => $chartData['labels'],
            'chart_prices'      => $chartData['prices'],
            'chart_mins'        => $chartData['mins'],
            'chart_maxs'        => $chartData['maxs'],
            'chart_trend'       => $trend,
            'chart_labels_json' => json_encode($chartData['labels']),
            'chart_prices_json' => json_encode($chartData['prices']),
            'chart_mins_json'   => json_encode($chartData['mins']),
            'chart_maxs_json'   => json_encode($chartData['maxs']),
        ]);
    }

    /* ============================================================
     * PESTAÑA MIS LISTADOS
     * ============================================================ */
    private function prepareMine()
    {
        $myOffers = MarketHelper::getMyOffers($this->userId);

        foreach ($myOffers as &$o) {
            $o['category']   = MarketHelper::getCategoryLabel($o['item_type']);
            $o['amount_fmt'] = MarketHelper::formatAmount((int)$o['amount']);
            $o['price_fmt']  = number_format((int)$o['price_ntx'], 0, ',', '.');
            $o['image']      = MarketHelper::itemImage($o['item_type'], (int)$o['item_id']);
            $o['is_admin']   = ((int)$o['admin_offer'] === 1);
            $o['is_buy']     = ($o['offer_type'] === 'buy');
            $o['is_improvement'] = ($o['item_type'] === 'improvement');
            $o['is_resource']    = $this->isResource($o['item_type']);

            $o['cancel_reason']       = isset($o['cancel_reason']) ? $o['cancel_reason'] : '';
            $o['cancel_reason_label'] = $this->getCancelReasonLabel($o['cancel_reason']);
            $o['is_autocancelled']    = in_array($o['cancel_reason'],
                ['seller_no_resources', 'buyer_no_ntx'], true);

            if ($o['is_admin']) {
                $o['fee_pct']        = 0;
                $o['fee_amt']        = 0;
                $o['fee_label']      = 'Sin comisión';
                $o['net_receive']    = (int)$o['price_ntx'];
                $o['show_fee_info']  = false;

            } elseif ($o['is_buy']) {
                $o['fee_pct']        = 0;
                $o['fee_amt']        = 0;
                $o['fee_label']      = 'Sin comisión para ti';
                $o['net_receive']    = (int)$o['price_ntx'];
                $o['show_fee_info']  = false;

            } else {
                $duration    = (int)$o['duration'];
                $sellerPct   = MarketHelper::getSellerFeePct($this->userId, $duration);
                $o['fee_pct']        = $sellerPct;
                $o['fee_amt']        = (int)ceil($o['price_ntx'] * $sellerPct / 100);
                $o['fee_label']      = 'Comisión al vender';
                $o['net_receive']    = (int)$o['price_ntx'] - $o['fee_amt'];
                $o['show_fee_info']  = true;
            }

            $o['fee_amt_fmt']     = number_format($o['fee_amt'], 0, ',', '.');
            $o['net_receive_fmt'] = number_format($o['net_receive'], 0, ',', '.');

            $o['timer_text'] = $o['is_admin']
                ? 'Sin expiración'
                : $this->formatCountdown((int)$o['remaining']);
            $o['timer_cls']  = $o['is_admin']
                ? 'infinite'
                : $this->calcUrgency((int)$o['remaining']);

            $statusMap = [
                'active'    => 'Activa',
                'sold'      => 'Vendida',
                'expired'   => 'Expirada',
                'cancelled' => 'Cancelada',
            ];
            $o['status_label'] = isset($statusMap[$o['status']])
                ? $statusMap[$o['status']]
                : $o['status'];
        }
        unset($o);

        $this->assign(['my_offers' => $myOffers]);
    }

    /* ============================================================
     * PESTAÑA HISTORIAL — v2.6.2 (FIX is_buy)
     * ============================================================ */
    private function prepareHistory()
    {
        $log = MarketHelper::getLog($this->userId, 30);

        foreach ($log as &$l) {
            $l['is_buyer']   = ((int)$l['buyer_id'] === $this->userId);
            $l['is_buy']     = $l['is_buyer'];
            $l['amount_fmt'] = MarketHelper::formatAmount((int)$l['amount']);
            $l['price_fmt']  = number_format((int)$l['price_ntx'], 0, ',', '.');
            $l['image']      = MarketHelper::itemImage($l['item_type'], (int)$l['item_id']);
            $l['date']       = date('d/m H:i', (int)$l['time']);
            $l['role']       = $l['is_buyer'] ? 'Compra' : 'Venta';
            $l['role_class'] = $l['is_buyer'] ? 'buyer' : 'seller';
        }
        unset($l);

        $this->assign(['history' => $log]);
    }

    /* ============================================================
     * v2.9 — PESTAÑA COLONIAS (Mercado Negro)
     * ============================================================ */
    private function prepareColonies()
    {
        $listings   = ColoniesHelper::getActiveListings($this->userId);
        $myListings = ColoniesHelper::getMyListings($this->userId);
        $sellable   = ColoniesHelper::getSellablePlanets($this->userId);

        // Preview de cada listado (recursos, naves, defensas)
        foreach ($listings as &$l) {
            $l['preview']   = ColoniesHelper::getPlanetPreview((int)$l['planet_id']);
            $l['price_fmt'] = number_format((int)$l['price_ntx'], 0, ',', '.');
            $l['coords']    = '['.(int)$l['galaxy'].':'.(int)$l['system'].':'.(int)$l['planet'].']';
        }
        unset($l);

        foreach ($myListings as &$l) {
            $l['price_fmt'] = number_format((int)$l['price_ntx'], 0, ',', '.');
            $l['coords']    = '['.(int)$l['galaxy'].':'.(int)$l['system'].':'.(int)$l['planet'].']';
            $l['fee_amt']   = (int)ceil($l['price_ntx'] * $l['fee_pct'] / 100);
            $l['net']       = (int)$l['price_ntx'] - $l['fee_amt'];
        }
        unset($l);

        $this->assign([
            'col_listings'    => $listings,
            'col_my_listings' => $myListings,
            'col_sellable'    => $sellable,
            'col_min_price'   => ColoniesHelper::MIN_PRICE,
            'col_max_price'   => ColoniesHelper::MAX_PRICE,
            'col_max_planets' => ColoniesHelper::MAX_PLANETS_PER_USER,
            'col_fee_pct'     => MarketHelper::getSellerFeePct($this->userId, ColoniesHelper::FEE_DURATION),
            'col_my_planets'  => ColoniesHelper::countPlanets($this->userId),
        ]);
    }

    /* ============================================================
     * v2.9 — ACCIÓN: PUBLICAR COLONIA
     * ============================================================ */
    public function publishColony()
    {
        $planetId = isset($_POST['planet_id']) ? (int)$_POST['planet_id'] : 0;
        $price    = isset($_POST['price'])     ? (int)$_POST['price']     : 0;

        $res = ColoniesHelper::listColony($this->userId, $planetId, $price);

        if (isset($res['error'])) {
            $this->redirect('game.php?page=market&tab=colonies&error='.urlencode($res['error']));
        }
        $this->redirect('game.php?page=market&tab=colonies&ok=colony_published');
    }

    /* ============================================================
     * v2.9 — ACCIÓN: COMPRAR COLONIA
     * ============================================================ */
    public function buyColony()
    {
        $listingId = isset($_GET['id']) ? (int)$_GET['id'] : 0;

        $res = ColoniesHelper::buyColony($this->userId, $listingId);

        if (isset($res['error'])) {
            $this->redirect('game.php?page=market&tab=colonies&error='.urlencode($res['error']));
        }
        $this->redirect('game.php?page=market&tab=colonies&ok=colony_bought');
    }

    /* ============================================================
     * v2.9 — ACCIÓN: CANCELAR LISTADO DE COLONIA
     * ============================================================ */
    public function cancelColony()
    {
        $listingId = isset($_GET['id']) ? (int)$_GET['id'] : 0;

        $res = ColoniesHelper::cancelListing($this->userId, $listingId);

        if (isset($res['error'])) {
            $this->redirect('game.php?page=market&tab=colonies&error='.urlencode($res['error']));
        }
        $this->redirect('game.php?page=market&tab=colonies&ok=colony_cancelled');
    }

    /* ============================================================
     * ACCIÓN — COMPRAR (sell order)
     * ============================================================ */
    public function buy()
    {
        $offerId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        $result  = MarketHelper::buyOffer($this->userId, $offerId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=market&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=market&ok=bought');
    }

    /* ============================================================
     * ACCIÓN — ACEPTAR BUY ORDER (entregar ítem)
     * ============================================================ */
    public function fulfill()
    {
        $offerId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        $result  = MarketHelper::fulfillBuyOrder($this->userId, $offerId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=market&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=market&ok=fulfilled');
    }

    /* ============================================================
     * ACCIÓN — CANCELAR OFERTA
     * ============================================================ */
    public function cancel()
    {
        $offerId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        $result  = MarketHelper::cancelOffer($this->userId, $offerId);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=market&tab=mine&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=market&tab=mine&ok=cancelled');
    }

    /* ============================================================
     * ACCIÓN — PUBLICAR VENTA
     * ============================================================ */
    public function publishSell()
    {
        $data = [
            'item_type' => isset($_POST['item_type']) ? $_POST['item_type'] : '',
            'item_id'   => isset($_POST['item_id'])   ? (int)$_POST['item_id'] : 0,
            'amount'    => isset($_POST['amount'])    ? (int)$_POST['amount'] : 0,
            'price_ntx' => isset($_POST['price_ntx']) ? (int)$_POST['price_ntx'] : 0,
            'duration'  => isset($_POST['duration'])  ? (int)$_POST['duration'] : 24,
            'is_penalized' => isset($_POST['is_penalized']) ? (int)$_POST['is_penalized'] : 0,
        ];

        if (in_array($data['item_type'], ['metal', 'crystal', 'deuterium'], true)) {
            $data['amount'] *= self::RESOURCE_MULTIPLIER;
        }

        $info = MarketHelper::getItemInfo($data['item_type'], $data['item_id']);
        $data['item_name'] = $info ? $info['name'] : 'Desconocido';

        if ($data['item_type'] === 'improvement' && $data['is_penalized']) {
            $data['item_name'] .= ' (P)';
        }

        $result = MarketHelper::createOffer($this->userId, $data);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=market&tab=sell&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=market&tab=mine&ok=published');
    }

    /* ============================================================
     * ACCIÓN — PUBLICAR BUY ORDER
     * ============================================================ */
    public function publishBuy()
    {
        $data = [
            'item_type' => isset($_POST['item_type']) ? $_POST['item_type'] : '',
            'item_id'   => isset($_POST['item_id'])   ? (int)$_POST['item_id'] : 0,
            'amount'    => isset($_POST['amount'])    ? (int)$_POST['amount'] : 0,
            'price_ntx' => isset($_POST['price_ntx']) ? (int)$_POST['price_ntx'] : 0,
            'duration'  => isset($_POST['duration'])  ? (int)$_POST['duration'] : 24,
        ];

        if (in_array($data['item_type'], ['metal', 'crystal', 'deuterium'], true)) {
            $data['amount'] *= self::RESOURCE_MULTIPLIER;
        }

        $info = MarketHelper::getItemInfo($data['item_type'], $data['item_id']);
        $data['item_name'] = $info ? $info['name'] : 'Desconocido';

        $result = MarketHelper::createBuyOrder($this->userId, $data);

        if (isset($result['error'])) {
            $this->redirect('game.php?page=market&tab=buy&error='.urlencode($result['error']));
        }
        $this->redirect('game.php?page=market&tab=mine&ok=buy_published');
    }

    /* ============================================================
     * AJAX — SUGERIR PRECIO
     * ============================================================ */
    public function suggest()
    {
        header('Content-Type: application/json');

        $type = isset($_GET['item_type']) ? $_GET['item_type'] : '';
        $id   = isset($_GET['item_id'])   ? (int)$_GET['item_id'] : 0;

        $suggest = MarketHelper::suggestPrice($type, $id);
        echo json_encode($suggest ?: ['avg'=>0, 'min'=>0, 'max'=>0]);
        exit;
    }

    /* ============================================================
     * AJAX — DATOS DEL GRÁFICO
     * ============================================================ */
    public function chart()
    {
        header('Content-Type: application/json');

        $type = isset($_GET['item_type']) ? $_GET['item_type'] : '';
        $id   = isset($_GET['item_id'])   ? (int)$_GET['item_id'] : 0;
        $days = isset($_GET['days'])      ? (int)$_GET['days'] : 7;

        echo json_encode(MarketTrendsHelper::getChartData($type, $id, $days));
        exit;
    }

    /* ============================================================
     * AJAX — INFO DE UNA MEJORA ESPECÍFICA
     * ============================================================ */
    public function improvements()
    {
        header('Content-Type: application/json');

        $itemId = isset($_GET['item_id']) ? (int)$_GET['item_id'] : 0;

        $info = MarketHelper::getItemInfo('improvement', $itemId);
        if (!$info) {
            echo json_encode(['error' => 'Item no encontrado']);
            exit;
        }

        $info['stat_text'] = $this->buildStatText($info);
        $info['image']     = MarketHelper::itemImage('improvement', $itemId);

        echo json_encode($info);
        exit;
    }

    /* ============================================================
     * UTILIDADES
     * ============================================================ */
    private function formatCountdown($seconds)
    {
        $seconds = max(0, (int)$seconds);
        if ($seconds <= 0) return 'Expirada';

        $h = floor($seconds / 3600);
        $m = floor(($seconds % 3600) / 60);
        $s = $seconds % 60;

        return sprintf('%02dh %02dm %02ds', $h, $m, $s);
    }

    private function calcUrgency($seconds)
    {
        $seconds = (int)$seconds;
        if ($seconds <= 0)     return 'expired';
        if ($seconds < 3600)   return 'critical';
        if ($seconds < 10800)  return 'warning';
        if ($seconds < 21600)  return 'attention';
        return 'ok';
    }

    private function redirect($url)
    {
        header('Location: '.$url);
        exit;
    }
}