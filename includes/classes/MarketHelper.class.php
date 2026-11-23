<?php
/**
 * ============================================================
 * MarketHelper — Mercado AstroIO v2.8
 * ============================================================
 * Moneda:       NTX-20  (GLOBAL — vive en uni1_users.ntx20)
 * Fees v2.6:    SIN fee al crear · Fee AL VENDER
 *               · SELL 24h → 5% normal / 3% VIP
 *               · SELL 48h → 10% normal / 7% VIP
 *               · BUY  aceptar → mismo esquema que SELL
 *               · Comprador paga SIEMPRE precio limpio
 * Comisión:     Al fondo del proyecto (from_seller)
 * Límite:       2 sin VIP / 6 con VIP (cualquier tipo)
 * Precio mín.:  60% del más bajo (ratio 0.60)
 *
 * ═══════════════════════════════════════════════════════════
 * ASTROIO v2.8 — SOPORTE COFRES CLIMÁTICOS
 * ───────────────────────────────────────────────────────────
 * Añadido el item_type 'box_climate' para poder vender los
 * 3 cofres climáticos en el Mercado.
 *
 * NO confundir:
 *   · item_type = 'container'   → uni1_users.containers      (genérico, x1)
 *   · item_type = 'box'         → uni1_users_market.box_*    (común/raro/legendario)
 *   · item_type = 'box_climate' → uni1_users_market.box_climate_* (menor/mayor/dominio)
 * ============================================================
 *
 * ASTROIO v2.7 — SOPORTE COFRE GENÉRICO
 * ───────────────────────────────────────────────────────────
 * Añadido el item_type 'container' para poder vender el
 * COFRE GENÉRICO (uni1_users.containers) en el Mercado.
 * ============================================================
 *
 * ASTROIO-FIX v2.6 (CRÍTICO — ANTI-EXPLOIT "ALMACÉN SEGURO"):
 * ───────────────────────────────────────────────────────────
 * PROBLEMA ARREGLADO:
 *   Antes, al crear una oferta de venta, los items se quitaban
 *   del planeta del vendedor y se "guardaban" en la tabla
 *   market_offers. Eso convertía al mercado en un ALMACÉN
 *   SEGURO Y GRATIS: la gente metía todas sus naves/recursos
 *   antes de dormir, era inatacable, y cancelaba en la mañana
 *   recuperando todo.
 *
 * SOLUCIÓN (4 capas):
 *   1) NO se quitan items al crear oferta de venta
 *   2) NO se congelan NTX al crear buy order
 *   3) Al COMPRAR se verifica que el vendedor TENGA los items
 *   4) Al VENDER se verifica que el comprador TENGA el NTX
 *
 * CANCELAR / EXPIRAR:
 *   → Para ofertas nuevas: no se devuelve nada
 *   → Para ofertas legacy (planet_id=0): se devuelve al planeta
 *
 * NUEVAS COLUMNAS REQUERIDAS (ejecutar ANTES):
 *   ALTER TABLE uni1_market_offers
 *     ADD COLUMN planet_id INT(11) NOT NULL DEFAULT 0 AFTER seller_id,
 *     ADD COLUMN cancel_reason VARCHAR(50) DEFAULT NULL AFTER status;
 * ═══════════════════════════════════════════════════════════
 *
 * ASTROIO-FIX v2.2:
 *  - subtractBalance: GREATEST(0, ...) + max(0, ...) → nunca negativo
 *  - addBalance: max(0, ...) en el $GLOBALS para consistencia
 *  - removeItem: max(0, ...) en recursos (metal, crystal, deuterium, dark_matter)
 *
 * ASTROIO-FIX v2.3 (CRÍTICO):
 *  - FIX: buyOffer()       → (int)$o['offer_type'] !== 'sell' daba siempre TRUE
 *  - FIX: fulfillBuyOrder() → mismo bug con 'buy'
 *  - FIX: giveItem()       → ahora escribe en BD
 *  - FIX: removeItem()     → ahora escribe en BD
 *
 * ASTROIO-FIX v2.4:
 *  - Nuevos hooks NTX20LogHelper::log()
 *
 * ASTROIO v2.5 (CAMBIOS CLAVE):
 *  - Fee al crear oferta = 0% (NO se cobra nada al publicar)
 *  - Fee al vender (SELL) = 5%/10% normal · 3%/7% VIP
 *  - Fee al aceptar (BUY) = 5%/10% normal · 3%/7% VIP
 *  - Comprador / buyer paga SIEMPRE el precio limpio (sin fee)
 *  - Límite simplificado: 2 sin VIP / 6 con VIP (cualquier tipo)
 *  - El fee lo paga SIEMPRE el que recibe los NTX-20
 *  - El fee va a from_seller (incluso el del buy order)
 *  - NO se loggea el fee al crear (porque es 0)
 *
 * ASTROIO v2.6.4 (FIX DARK MATTER):
 *  - Añadidas funciones getGlobalDarkMatter / setGlobalDarkMatter
 *    para evitar errores de "Undefined array key" en PHP 8.2.
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

class MarketHelper
{
    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /**
     * ASTROIO v2.4 — Carga el helper de auditoría NTX-20 (si existe)
     */
    private static function loadNtxLogHelper()
    {
        if (class_exists('NTX20LogHelper')) return true;

        if (defined('ROOT_PATH')) {
            $file = ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php';
        } else {
            $file = dirname(__FILE__) . '/NTX20LogHelper.class.php';
        }

        if (file_exists($file)) {
            require_once $file;
        }
        return class_exists('NTX20LogHelper');
    }

    /**
     * ASTROIO v2.4 — Wrapper seguro para el log (no rompe si falla)
     */
    private static function logNtx20($userId, $amount, $type, $description = '', $refId = 0)
    {
        try {
            if (!self::loadNtxLogHelper()) return;
            NTX20LogHelper::log($userId, $amount, $type, $description, $refId);
        } catch (Exception $e) {
            // silencioso
        }
    }

    /* ============================================================
     * FIX DARK MATTER — COMPATIBILIDAD MULTI-FORK
     * ============================================================ */
    
    private static function getGlobalDarkMatter()
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

    private static function setGlobalDarkMatter($amount)
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
                $USER[$k] = max(0, (int)$amount);
                return;
            }
        }
    }

    /* ============================================================
     * CONSTANTES — FEES (v2.5)
     * ------------------------------------------------------------
     * FEE_CREATE_* = 0 → Ya NO se cobra al crear oferta
     * FEE_BUY_*    = 0 → El comprador paga precio limpio (sin fee)
     * FEE_SELL_*   = 5/10 normal · 3/7 VIP → Se cobra AL VENDER
     * ============================================================ */
    const FEE_CREATE_24_NORMAL  = 0;
    const FEE_CREATE_48_NORMAL  = 0;
    const FEE_BUY_NORMAL        = 0;
    const FEE_ACCEPT_BUY_NORMAL = 0;

    const FEE_CREATE_24_VIP     = 0;
    const FEE_CREATE_48_VIP     = 0;
    const FEE_BUY_VIP           = 0;
    const FEE_ACCEPT_BUY_VIP    = 0;

    // NUEVAS v2.5 — Fee al vender/entregar
    const FEE_SELL_24_NORMAL    = 5;
    const FEE_SELL_48_NORMAL    = 10;
    const FEE_SELL_24_VIP       = 3;
    const FEE_SELL_48_VIP       = 7;

    /* ============================================================
     * CONSTANTES — LÍMITES DIARIOS
     * ============================================================ */
    const LIMIT_NORMAL       = 2;
    const LIMIT_VIP_BASIC    = 6;

    /* ============================================================
     * CONSTANTES — TIPOS VIP
     * ============================================================ */
    const VIP_TYPE_WEEKLY     = 'weekly';
    const VIP_TYPE_MONTHLY    = 'monthly';
    const VIP_TYPE_SEMIANNUAL = 'semiannual';
    const VIP_TYPE_ANNUAL     = 'annual';

    /* ============================================================
     * CONSTANTES — DURACIÓN
     * ============================================================ */
    const DURATION_24H = 24;
    const DURATION_48H = 48;

    /* ============================================================
     * CONSTANTES — REGLAS DE MERCADO
     * ============================================================ */
    const MIN_PRICE_RATIO = 0.60;
    const OFFER_TTL_24H   = 86400;
    const OFFER_TTL_48H   = 172800;
    const PENDING_TIME    = 180;
    const PAGE_SIZE       = 24;
    const MIN_PRICE       = 1;

    /* ============================================================
     * CATÁLOGO DE ÍTEMS VENDIBLES
     * ============================================================ */
    public static $SHIPS = [
        202=>'small_ship_cargo',   203=>'big_ship_cargo',
        204=>'light_hunter',       205=>'heavy_hunter',
        206=>'crusher',            207=>'battle_ship',
        208=>'colonizer',          209=>'recycler',
        210=>'spy_sonde',          211=>'bomber_ship',
        212=>'solar_satelit',      213=>'destructor',
        214=>'dearth_star',        215=>'battleship',
        216=>'lune_noir',          217=>'ev_transporter',
        218=>'star_crasher',       219=>'giga_recykler',
        220=>'dm_ship',            221=>'orbital_station',
    ];

    public static $DEFENSES = [
        401=>'misil_launcher',     402=>'small_laser',
        403=>'big_laser',          404=>'gauss_canyon',
        405=>'ionic_canyon',       406=>'buster_canyon',
        407=>'small_protection_shield',
        408=>'planet_protector',   409=>'big_protection_shield',
        410=>'graviton_canyon',
        502=>'interceptor_misil',  503=>'interplanetary_misil',
    ];

    public static $BOXES = [
        1 => 'box_common',
        2 => 'box_rare',
        3 => 'box_legendary',
    ];

    // v2.8 — Cofres Climáticos
    public static $CLIMATE_BOXES = [
        1 => 'box_climate_minor',
        2 => 'box_climate_major',
        3 => 'box_climate_dominion',
    ];

    /* ============================================================
     * SALDO NTX-20  (GLOBAL — uni1_users.ntx20)
     * ============================================================ */

    public static function ensureUser($userId)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_market` WHERE user_id = :u",
            [':u' => (int)$userId]);

        if (!$row) {
            // NOTA: balance_ntx ya no existe en la tabla.
            // El saldo NTX-20 vive en uni1_users.ntx20.
            $db->insert(
                "INSERT INTO `".$prefix."users_market` SET
                    user_id = :u, balance_frozen = 0,
                    offers_today = 0, last_offer_day = NULL,
                    last_reset = :t",
                [':u' => (int)$userId, ':t' => TIMESTAMP]);

            $row = $db->selectSingle(
                "SELECT * FROM `".$prefix."users_market` WHERE user_id = :u",
                [':u' => (int)$userId]);
        }
        return $row;
    }

    public static function getBalance($userId)
    {
        $prefix = self::prefix();
        $row = Database::get()->selectSingle(
            "SELECT ntx20 FROM `".$prefix."users` WHERE id = :u",
            [':u' => (int)$userId]);
        return ($row && isset($row['ntx20'])) ? (int)$row['ntx20'] : 0;
    }

    public static function getAvailableBalance($userId)
    {
        $u = self::ensureUser($userId);
        return self::getBalance($userId) - (int)$u['balance_frozen'];
    }

    public static function getFrozenBalance($userId)
    {
        return (int) self::ensureUser($userId)['balance_frozen'];
    }

    public static function addBalance($userId, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return;
        $prefix = self::prefix();
        Database::get()->update(
            "UPDATE `".$prefix."users`
             SET ntx20 = ntx20 + :a
             WHERE id = :u",
            [':a' => $amount, ':u' => (int)$userId]);

        if (isset($GLOBALS['USER']['id'])
            && (int)$GLOBALS['USER']['id'] === (int)$userId) {
            $GLOBALS['USER']['ntx20'] = max(0, (int)$GLOBALS['USER']['ntx20'] + $amount);
        }
    }

    public static function subtractBalance($userId, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return true;
        $prefix = self::prefix();

        $db = Database::get();
        // ✅ v3.9 — Guard condicional + rowCount: antes era
        // GREATEST(0, ntx20 - :a) SIN guard → en carrera el pago salía 0 y el
        // vendedor recibía NTX de la nada. Ahora si el saldo no alcanza
        // devuelve false y el llamador aborta (nada se mueve).
        $db->update(
            "UPDATE `".$prefix."users`
             SET ntx20 = ntx20 - :a
             WHERE id = :u AND ntx20 >= :a",
            [':a' => $amount, ':u' => (int)$userId]);

        if ($db->rowCount() !== 1) {
            return false;
        }

        if (isset($GLOBALS['USER']['id'])
            && (int)$GLOBALS['USER']['id'] === (int)$userId) {
            $GLOBALS['USER']['ntx20'] = max(0, (int)$GLOBALS['USER']['ntx20'] - $amount);
        }

        return true;
    }

    /**
     * ✅ v3.9 — Revertir el claim de una oferta (status='sold' → 'active')
     * cuando el flujo de compra/aceptación aborta ANTES de mover dinero.
     */
    private static function revertOfferClaim($offerId)
    {
        $prefix = self::prefix();
        try {
            Database::get()->update(
                "UPDATE `".$prefix."market_offers`
                 SET status = 'active'
                 WHERE offer_id = :id AND status = 'sold'",
                [':id' => $offerId]);
        } catch (Throwable $e) {}
    }

    public static function freezeBalance($userId, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return;
        self::ensureUser($userId);
        $prefix = self::prefix();
        Database::get()->update(
            "UPDATE `".$prefix."users_market`
             SET balance_frozen = balance_frozen + :a
             WHERE user_id = :u",
            [':a' => $amount, ':u' => (int)$userId]);
    }

    public static function unfreezeBalance($userId, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return;
        self::ensureUser($userId);
        $prefix = self::prefix();
        Database::get()->update(
            "UPDATE `".$prefix."users_market`
             SET balance_frozen = GREATEST(0, balance_frozen - :a)
             WHERE user_id = :u",
            [':a' => $amount, ':u' => (int)$userId]);
    }

    /* ============================================================
     * VIP / FEES
     * ============================================================ */

    public static function getVipInfo($userId)
    {
        if (!class_exists('VIPHelper')) return false;
        if (!method_exists('VIPHelper', 'isVIP')) return false;

        if (!VIPHelper::isVIP($userId)) return false;

        if (!method_exists('VIPHelper', 'getVIPData')) {
            return ['active'=>true, 'vip_type'=>self::VIP_TYPE_MONTHLY];
        }

        $data = VIPHelper::getVIPData($userId);
        if (empty($data) || empty($data['vip_type'])) {
            return ['active'=>true, 'vip_type'=>self::VIP_TYPE_MONTHLY];
        }

        return [
            'active'   => true,
            'vip_type' => $data['vip_type'],
        ];
    }

    public static function isVip($userId)
    {
        $v = self::getVipInfo($userId);
        return !empty($v['active']);
    }

    /**
     * v2.5 — Se mantiene por compatibilidad con otros módulos,
     * pero ya no se usa para lógica de límites ni fees.
     */
    public static function isVipPremium($userId)
    {
        return self::isVip($userId);
    }

    /**
     * v2.5 — Fee que se cobra AL VENDER (SELL)
     *  · 24h → 5% normal / 3% VIP
     *  · 48h → 10% normal / 7% VIP
     * El % depende del VIP del VENDEDOR (el que recibe el NTX-20).
     */
    public static function getSellerFeePct($sellerId, $duration)
    {
        $isVip = self::isVip($sellerId);

        if ((int)$duration === self::DURATION_48H) {
            return $isVip ? self::FEE_SELL_48_VIP : self::FEE_SELL_48_NORMAL;
        }
        return $isVip ? self::FEE_SELL_24_VIP : self::FEE_SELL_24_NORMAL;
    }

    /**
     * v2.5 — El COMPRADOR ya NO paga fee extra.
     * Paga siempre el precio limpio.
     */
    public static function getBuyerFeePct($buyerId)
    {
        return 0;
    }

    /**
     * v2.5 — Fee que se cobra AL ACEPTAR una BUY ORDER
     *  · 24h → 5% normal / 3% VIP
     *  · 48h → 10% normal / 7% VIP
     * El % depende del VIP del ACEPTADOR (el que recibe el NTX-20).
     */
    public static function getAcceptorFeePct($acceptorId, $duration = 24)
    {
        $isVip = self::isVip($acceptorId);

        if ((int)$duration === self::DURATION_48H) {
            return $isVip ? self::FEE_SELL_48_VIP : self::FEE_SELL_48_NORMAL;
        }
        return $isVip ? self::FEE_SELL_24_VIP : self::FEE_SELL_24_NORMAL;
    }

    /* ============================================================
     * LÍMITE DIARIO
     * ============================================================ */

    /**
     * v2.5 — Simplificado: 2 sin VIP / 6 con VIP (cualquier tipo).
     */
    public static function getDailyLimit($userId)
    {
        return self::isVip($userId)
            ? self::LIMIT_VIP_BASIC
            : self::LIMIT_NORMAL;
    }

    public static function getOffersToday($userId)
    {
        $u      = self::ensureUser($userId);
        $today  = date('Y-m-d');
        $prefix = self::prefix();

        if ($u['last_offer_day'] !== $today) {
            Database::get()->update(
                "UPDATE `".$prefix."users_market`
                 SET offers_today = 0, last_offer_day = :d
                 WHERE user_id = :u",
                [':d' => $today, ':u' => (int)$userId]);
            return 0;
        }
        return (int)$u['offers_today'];
    }

    public static function canPublish($userId)
    {
        $limit = self::getDailyLimit($userId);
        $today = self::getOffersToday($userId);

        if ($today >= $limit) {
            return [
                'ok'  => false,
                'msg' => "Has alcanzado el límite de $limit ofertas diarias. ".
                         "Hazte VIP para más.",
            ];
        }
        return ['ok' => true, 'remaining' => $limit - $today];
    }

    public static function incrementOffersToday($userId)
    {
        $today  = date('Y-m-d');
        $prefix = self::prefix();
        Database::get()->update(
            "UPDATE `".$prefix."users_market`
             SET offers_today = offers_today + 1, last_offer_day = :d
             WHERE user_id = :u",
            [':d' => $today, ':u' => (int)$userId]);
    }

    /* ============================================================
     * PRECIO MÍNIMO
     * ============================================================ */

    public static function getMinPrice($itemType, $itemId)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT MIN(price_ntx) AS min_price
             FROM `".$prefix."market_offers`
             WHERE status = 'active'
               AND admin_offer = 0
               AND (expires = 0 OR expires > :now)
               AND item_type = :t
               AND item_id   = :i",
            [':now' => TIMESTAMP, ':t' => $itemType, ':i' => (int)$itemId]);

        if (!$row || $row['min_price'] === null) return null;

        return (int)floor((int)$row['min_price'] * self::MIN_PRICE_RATIO);
    }

    public static function validatePrice($itemType, $itemId, $price)
    {
        $min = self::getMinPrice($itemType, $itemId);
        if ($min !== null && (int)$price < $min) {
            return [
                'ok'  => false,
                'msg' => "El precio mínimo permitido es $min NTX-20 ".
                         "(40% por debajo del más bajo del mercado)",
            ];
        }
        return ['ok' => true];
    }

    /* ============================================================
     * CATÁLOGO / UTILIDADES
     * ============================================================ */

    public static function getSellableItems()
    {
        global $LNG, $reslist;
        $items = [
            ['type'=>'metal',      'id'=>0, 'name'=>'Metal',          'cat'=>'resource'],
            ['type'=>'crystal',    'id'=>0, 'name'=>'Cristal',        'cat'=>'resource'],
            ['type'=>'deuterium',  'id'=>0, 'name'=>'Deuterio',       'cat'=>'resource'],
            // 🆕 v2.6 — Recursos nuevos en el mercado jugador a jugador
            ['type'=>'norium',     'id'=>0, 'name'=>'Norium',         'cat'=>'resource'],
            ['type'=>'germanium',  'id'=>0, 'name'=>'Germanio',       'cat'=>'resource'],
            ['type'=>'dark_matter','id'=>0, 'name'=>'Materia Oscura', 'cat'=>'resource'],
        ];

        $fleetIds = (isset($reslist['fleet']) && is_array($reslist['fleet']))
            ? $reslist['fleet']
            : array_keys(self::$SHIPS);

        foreach ($fleetIds as $id) {
            $name = (isset($LNG['tech'][$id]) ? $LNG['tech'][$id]
                    : (isset(self::$SHIPS[$id]) ? self::$SHIPS[$id] : 'Nave '.$id));
            $items[] = ['type'=>'ship','id'=>$id,'name'=>$name,'cat'=>'ship'];
        }

        $defIds = (isset($reslist['defense']) && is_array($reslist['defense']))
            ? $reslist['defense']
            : array_keys(self::$DEFENSES);

        foreach ($defIds as $id) {
            $name = (isset($LNG['tech'][$id]) ? $LNG['tech'][$id]
                    : (isset(self::$DEFENSES[$id]) ? self::$DEFENSES[$id] : 'Defensa '.$id));
            $items[] = ['type'=>'defense','id'=>$id,'name'=>$name,'cat'=>'defense'];
        }

        $items[] = ['type'=>'box','id'=>1,'name'=>'Cofre Común',      'cat'=>'box'];
        $items[] = ['type'=>'box','id'=>2,'name'=>'Cofre Raro',       'cat'=>'box'];
        $items[] = ['type'=>'box','id'=>3,'name'=>'Cofre Legendario', 'cat'=>'box'];

        // v2.8 — Cofres Climáticos
        $items[] = ['type'=>'box_climate','id'=>1,'name'=>'Cofre Climático Menor',   'cat'=>'box'];
        $items[] = ['type'=>'box_climate','id'=>2,'name'=>'Cofre Climático Mayor',   'cat'=>'box'];
        $items[] = ['type'=>'box_climate','id'=>3,'name'=>'Cofre Climático Dominio', 'cat'=>'box'];

        // v2.7 — Cofre Genérico (uni1_users.containers)
        $items[] = ['type'=>'container','id'=>0,'name'=>'Cofre Genérico','cat'=>'box'];

        return $items;
    }

    // >>> IMPROVEMENTS — Mejoras vendibles del usuario
    public static function getSellableImprovements($userId)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT
                i.item_id,
                i.quantity,
                i.is_penalized,
                c.chain_name,
                c.level,
                c.category,
                c.stat1,
                c.stat2,
                c.type AS kind
             FROM `".$prefix."users_improvements_inv` i
             JOIN `".$prefix."improvements_catalog` c ON i.item_id = c.id
             WHERE i.user_id = :u
               AND i.quantity > 0
             ORDER BY c.category ASC, c.chain_id ASC, c.level ASC, i.is_penalized ASC",
            [':u' => (int)$userId]);

        if (!is_array($rows)) return [];

        $list = [];
        foreach ($rows as $r) {
            $list[] = [
                'type'         => 'improvement',
                'id'           => (int)$r['item_id'],
                'name'         => $r['chain_name'].' Nv '.$r['level']
                                  .($r['is_penalized'] ? ' (P)' : ''),
                'chain_name'   => $r['chain_name'],
                'level'        => (int)$r['level'],
                'category'     => $r['category'],
                'kind'         => $r['kind'],
                'stat1'        => $r['stat1'],
                'stat2'        => $r['stat2'],
                'quantity'     => (int)$r['quantity'],
                'is_penalized' => (int)$r['is_penalized'],
                'available'    => (int)$r['quantity'],
                'image'        => self::itemImage('improvement', (int)$r['item_id']),
            ];
        }
        return $list;
    }

    public static function getCategoryLabel($itemType)
    {
        switch ($itemType) {
            case 'metal':
            case 'crystal':
            case 'deuterium':
            case 'norium':      // 🆕 v2.6
            case 'germanium':   // 🆕 v2.6
                                return 'Recurso';
            case 'dark_matter': return 'MO';
            case 'ship':        return 'Nave';
            case 'defense':     return 'Defensa';
            case 'box':         return 'Cofre';
            case 'box_climate': return 'Cofre';
            case 'container':   return 'Cofre';
            case 'improvement': return 'Mejora';
        }
        return 'Otro';
    }

    public static function itemImage($itemType, $itemId)
    {
        switch ($itemType) {
            case 'metal':       return 'styles/theme/gow/mercado/metal.gif';
            case 'crystal':     return 'styles/theme/gow/mercado/cristal.gif';
            case 'deuterium':   return 'styles/theme/gow/mercado/dulterio.gif';
            case 'norium':      return 'styles/theme/gow/mercado/norium.gif';    // 🆕 v2.6
            case 'germanium':   return 'styles/theme/gow/mercado/germanio.gif';  // 🆕 v2.6
            case 'dark_matter': return 'styles/theme/gow/mercado/materia oscura.gif';
            case 'ship':
            case 'defense':
                return 'styles/theme/gow/gebaeude/'.(int)$itemId.'.gif';
            case 'box':
            case 'box_climate':
                return 'styles/theme/gow/gebaeude/'.(int)$itemId.'00.gif';
            case 'container':
                return 'styles/theme/gow/gebaeude/generico.gif';
            case 'improvement':
                return 'styles/theme/gow/gebaeude/'.(int)$itemId.'.gif';
        }
        return 'styles/theme/gow/gebaeude/0.gif';
    }

    public static function getItemInfo($itemType, $itemId)
    {
        if ($itemType === 'improvement') {
            $db     = Database::get();
            $prefix = self::prefix();
            $row = $db->selectSingle(
                "SELECT * FROM `".$prefix."improvements_catalog` WHERE id = :i",
                [':i' => (int)$itemId]);
            if (!$row) return null;
            return [
                'type'      => 'improvement',
                'id'        => (int)$row['id'],
                'name'      => $row['chain_name'].' Nv '.$row['level'],
                'chain_name'=> $row['chain_name'],
                'level'     => (int)$row['level'],
                'category'  => $row['category'],
                'stat1'     => $row['stat1'],
                'stat2'     => $row['stat2'],
                'cat'       => 'improvement',
            ];
        }

        foreach (self::getSellableItems() as $item) {
            if ($item['type'] === $itemType
                && (int)$item['id'] === (int)$itemId) {
                return $item;
            }
        }
        return null;
    }

    /* ============================================================
     * MAPA DE NAVES / DEFENSAS DESDE $PLANET
     * ============================================================ */
    public static function getShipMap($planet)
    {
        global $resource, $reslist;
        $map = [];

        if (!is_array($planet) || !is_array($resource)) {
            return $map;
        }

        $ids = [];
        if (isset($reslist['fleet']) && is_array($reslist['fleet'])) {
            $ids = array_merge($ids, $reslist['fleet']);
        } else {
            $ids = array_merge($ids, array_keys(self::$SHIPS));
        }
        if (isset($reslist['defense']) && is_array($reslist['defense'])) {
            $ids = array_merge($ids, $reslist['defense']);
        } else {
            $ids = array_merge($ids, array_keys(self::$DEFENSES));
        }

        foreach ($ids as $id) {
            if (isset($resource[$id]) && isset($planet[$resource[$id]])) {
                $map[(int)$id] = (int)$planet[$resource[$id]];
            }
        }
        return $map;
    }

    /* ============================================================
     * v2.6 — HELPERS DE PLANETA ESPECÍFICO
     * ------------------------------------------------------------
     * Los usamos para verificar/quitar/agregar items a un planeta
     * CONCRETO (no el del usuario actual). Necesario porque al
     * comprar, el vendedor es OTRO usuario y sus items están en
     * SU planeta, no en el del comprador.
     * ============================================================ */

    /**
     * v2.6 — Resuelve el planet_id a usar.
     * Si nos pasan uno válido, se usa. Si no, buscamos el principal.
     */
    private static function resolvePlanetId($userId, $preferredPlanetId = 0)
    {
        if ((int)$preferredPlanetId > 0) return (int)$preferredPlanetId;
        return self::getMainPlanetId($userId);
    }

    /**
     * v2.6 — Obtiene el planet_id del planeta principal del usuario.
     */
    private static function getMainPlanetId($userId)
    {
        $prefix = self::prefix();
        $row = Database::get()->selectSingle(
            "SELECT id FROM `".$prefix."planets`
             WHERE id_owner = :u AND planet_type = 1
             ORDER BY id ASC LIMIT 1",
            [':u' => (int)$userId]);
        return ($row && isset($row['id'])) ? (int)$row['id'] : 0;
    }

    /**
     * v2.6 — Verifica si un usuario tiene X cantidad de un item en
     * un planeta CONCRETO.
     *  - Recursos / naves / defensas → se miran en el planeta
     *  - MO / cofres / mejoras → son globales (van al user)
     */
    private static function checkUserItem($userId, $planetId, $type, $itemId, $amount)
    {
        global $resource;
        $amount = (int)$amount;
        if ($amount <= 0) return false;

        $db     = Database::get();
        $prefix = self::prefix();

        switch ($type) {
            case 'metal':
            case 'crystal':
            case 'deuterium':
            case 'norium':      // 🆕 v2.6
            case 'germanium':   // 🆕 v2.6
                if ((int)$planetId <= 0) return false;
                $row = $db->selectSingle(
                    "SELECT `".$type."` AS qty FROM `".$prefix."planets`
                     WHERE id = :p AND id_owner = :u",
                    [':p' => (int)$planetId, ':u' => (int)$userId]);
                return $row && (float)$row['qty'] >= $amount;

            case 'dark_matter':
                $row = $db->selectSingle(
                    "SELECT darkmatter AS qty FROM `".$prefix."users` WHERE id = :u",
                    [':u' => (int)$userId]);
                return $row && (float)$row['qty'] >= $amount;

            // v2.7 — Cofre genérico (uni1_users.containers)
            case 'container':
                $row = $db->selectSingle(
                    "SELECT containers AS qty FROM `".$prefix."users` WHERE id = :u",
                    [':u' => (int)$userId]);
                return $row && (int)$row['qty'] >= $amount;

            case 'ship':
            case 'defense':
                if ((int)$planetId <= 0) return false;
                $col = isset($resource[(int)$itemId]) ? $resource[(int)$itemId] : null;
                if (!$col) return false;
                $row = $db->selectSingle(
                    "SELECT `".$col."` AS qty FROM `".$prefix."planets`
                     WHERE id = :p AND id_owner = :u",
                    [':p' => (int)$planetId, ':u' => (int)$userId]);
                return $row && (int)$row['qty'] >= $amount;

            case 'box':
                $key = isset(self::$BOXES[$itemId]) ? self::$BOXES[$itemId] : null;
                if (!$key) return false;
                $row = $db->selectSingle(
                    "SELECT `".$key."` AS qty FROM `".$prefix."users_market`
                     WHERE user_id = :u",
                    [':u' => (int)$userId]);
                return $row && (int)$row['qty'] >= $amount;

            case 'box_climate':
                $key = isset(self::$CLIMATE_BOXES[$itemId]) ? self::$CLIMATE_BOXES[$itemId] : null;
                if (!$key) return false;
                $row = $db->selectSingle(
                    "SELECT `".$key."` AS qty FROM `".$prefix."users_market`
                     WHERE user_id = :u",
                    [':u' => (int)$userId]);
                return $row && (int)$row['qty'] >= $amount;

            case 'improvement':
                $row = $db->selectSingle(
                    "SELECT quantity AS qty FROM `".$prefix."users_improvements_inv`
                     WHERE user_id = :u AND item_id = :i",
                    [':u' => (int)$userId, ':i' => (int)$itemId]);
                return $row && (int)$row['qty'] >= $amount;
        }
        return false;
    }

    /**
     * v2.6 — Quita X cantidad de un item de un planeta CONCRETO.
     *  - Recursos / naves / defensas → se quitan del planeta
     *  - MO → se quita del user
     *  - Cofres → se quitan del users_market del user
     *  - Mejoras → se quitan del inventario del user
     */
    private static function removeUserItem($userId, $planetId, $type, $itemId, $amount)
    {
        global $resource;
        $amount = (int)$amount;
        if ($amount <= 0) return;

        $db     = Database::get();
        $prefix = self::prefix();

        switch ($type) {
            case 'metal':
            case 'crystal':
            case 'deuterium':
            case 'norium':      // 🆕 v2.6
            case 'germanium':   // 🆕 v2.6
                if ((int)$planetId <= 0) return;
                $db->update(
                    "UPDATE `".$prefix."planets`
                     SET `".$type."` = GREATEST(0, `".$type."` - :a)
                     WHERE id = :p AND id_owner = :u",
                    [':a' => $amount, ':p' => (int)$planetId, ':u' => (int)$userId]);
                break;

            case 'dark_matter':
                $db->update(
                    "UPDATE `".$prefix."users`
                     SET darkmatter = GREATEST(0, darkmatter - :a)
                     WHERE id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            // v2.7 — Cofre genérico
            case 'container':
                $db->update(
                    "UPDATE `".$prefix."users`
                     SET containers = GREATEST(0, containers - :a)
                     WHERE id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            case 'ship':
            case 'defense':
                if ((int)$planetId <= 0) return;
                $col = isset($resource[(int)$itemId]) ? $resource[(int)$itemId] : null;
                if (!$col) return;
                $db->update(
                    "UPDATE `".$prefix."planets`
                     SET `".$col."` = GREATEST(0, `".$col."` - :a)
                     WHERE id = :p AND id_owner = :u",
                    [':a' => $amount, ':p' => (int)$planetId, ':u' => (int)$userId]);
                break;

            case 'box':
                $key = isset(self::$BOXES[$itemId]) ? self::$BOXES[$itemId] : null;
                if (!$key) return;
                $db->update(
                    "UPDATE `".$prefix."users_market`
                     SET `".$key."` = GREATEST(0, `".$key."` - :a)
                     WHERE user_id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            case 'box_climate':
                $key = isset(self::$CLIMATE_BOXES[$itemId]) ? self::$CLIMATE_BOXES[$itemId] : null;
                if (!$key) return;
                $db->update(
                    "UPDATE `".$prefix."users_market`
                     SET `".$key."` = GREATEST(0, `".$key."` - :a)
                     WHERE user_id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            case 'improvement':
                $db->update(
                    "UPDATE `".$prefix."users_improvements_inv`
                     SET quantity = quantity - :a
                     WHERE user_id = :u AND item_id = :i",
                    [':a' => $amount, ':u' => (int)$userId, ':i' => (int)$itemId]);
                $db->delete(
                    "DELETE FROM `".$prefix."users_improvements_inv`
                     WHERE user_id = :u AND item_id = :i AND quantity <= 0",
                    [':u' => (int)$userId, ':i' => (int)$itemId]);
                break;
        }
    }

    /**
     * v2.6 — Agrega X cantidad de un item a un planeta CONCRETO.
     *  - Recursos / naves / defensas → se agregan al planeta
     *  - MO → se agrega al user
     *  - Cofres → se agregan al users_market del user
     *  - Mejoras → se agregan al inventario del user
     */
    private static function addUserItem($userId, $planetId, $type, $itemId, $amount)
    {
        global $resource;
        $amount = (int)$amount;
        if ($amount <= 0) return;

        $db     = Database::get();
        $prefix = self::prefix();

        switch ($type) {
            case 'metal':
            case 'crystal':
            case 'deuterium':
            case 'norium':      // 🆕 v2.6
            case 'germanium':   // 🆕 v2.6
                if ((int)$planetId <= 0) return;
                $db->update(
                    "UPDATE `".$prefix."planets`
                     SET `".$type."` = `".$type."` + :a
                     WHERE id = :p AND id_owner = :u",
                    [':a' => $amount, ':p' => (int)$planetId, ':u' => (int)$userId]);
                break;

            case 'dark_matter':
                $db->update(
                    "UPDATE `".$prefix."users`
                     SET darkmatter = darkmatter + :a
                     WHERE id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            // v2.7 — Cofre genérico
            case 'container':
                $db->update(
                    "UPDATE `".$prefix."users`
                     SET containers = containers + :a
                     WHERE id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            case 'ship':
            case 'defense':
                if ((int)$planetId <= 0) return;
                $col = isset($resource[(int)$itemId]) ? $resource[(int)$itemId] : null;
                if (!$col) return;
                $db->update(
                    "UPDATE `".$prefix."planets`
                     SET `".$col."` = `".$col."` + :a
                     WHERE id = :p AND id_owner = :u",
                    [':a' => $amount, ':p' => (int)$planetId, ':u' => (int)$userId]);
                break;

            case 'box':
                $key = isset(self::$BOXES[$itemId]) ? self::$BOXES[$itemId] : null;
                if (!$key) return;
                self::ensureUser($userId);
                $db->update(
                    "UPDATE `".$prefix."users_market`
                     SET `".$key."` = `".$key."` + :a
                     WHERE user_id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            case 'box_climate':
                $key = isset(self::$CLIMATE_BOXES[$itemId]) ? self::$CLIMATE_BOXES[$itemId] : null;
                if (!$key) return;
                self::ensureUser($userId);
                $db->update(
                    "UPDATE `".$prefix."users_market`
                     SET `".$key."` = `".$key."` + :a
                     WHERE user_id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            case 'improvement':
                $row = $db->selectSingle(
                    "SELECT id FROM `".$prefix."users_improvements_inv`
                     WHERE user_id = :u AND item_id = :i",
                    [':u' => (int)$userId, ':i' => (int)$itemId]);
                if ($row) {
                    $db->update(
                        "UPDATE `".$prefix."users_improvements_inv`
                         SET quantity = quantity + :a, is_penalized = 0
                         WHERE id = :id",
                        [':a' => $amount, ':id' => (int)$row['id']]);
                } else {
                    $db->insert(
                        "INSERT INTO `".$prefix."users_improvements_inv`
                         (`user_id`, `item_id`, `quantity`, `is_penalized`, `fecha_obtencion`)
                         VALUES (:u, :i, :a, 0, :t)",
                        [
                            ':u' => (int)$userId,
                            ':i' => (int)$itemId,
                            ':a' => $amount,
                            ':t' => TIMESTAMP,
                        ]);
                }
                break;
        }
    }

    /* ============================================================
     * INVENTARIO (current user — $GLOBALS)
     * ------------------------------------------------------------
     * hasItem / removeItem / giveItem usan $GLOBALS['PLANET'] y
     * $GLOBALS['USER'] del usuario actual. Sirven cuando el usuario
     * actual es el dueño del ítem. Para tocar items de OTRO usuario,
     * usar checkUserItem / removeUserItem / addUserItem (arriba).
     * ============================================================ */

    public static function hasItem($userId, $type, $itemId, $amount)
    {
        global $USER, $PLANET, $resource;
        $amount = (int)$amount;
        if ($amount <= 0) return ['ok'=>false,'msg'=>'Cantidad inválida'];

        switch ($type) {
            case 'metal':
                return $PLANET['metal'] >= $amount
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>'Metal insuficiente'];
            case 'crystal':
                return $PLANET['crystal'] >= $amount
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>'Cristal insuficiente'];
            case 'deuterium':
                return $PLANET['deuterium'] >= $amount
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>'Deuterio insuficiente'];
            case 'norium':      // 🆕 v2.6
            case 'germanium':   // 🆕 v2.6
                return isset($PLANET[$type]) && $PLANET[$type] >= $amount
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>($type === 'norium' ? 'Norium' : 'Germanio').' insuficiente'];
            case 'dark_matter':
                // FIX v2.6.4 — Usar la función segura
                return self::getGlobalDarkMatter() >= $amount
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>'Materia Oscura insuficiente'];

            // v2.7 — Cofre genérico
            case 'container':
                $current = isset($USER['containers']) ? (int)$USER['containers'] : 0;
                return ($current >= $amount)
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>'Cofres insuficientes'];

            case 'ship':
            case 'defense':
                $colName = isset($resource[(int)$itemId]) ? $resource[(int)$itemId] : null;
                if (!$colName || !isset($PLANET[$colName])) {
                    return ['ok'=>false, 'msg'=>'Ítem inválido'];
                }
                $current = (int)$PLANET[$colName];
                return ($current >= $amount)
                    ? ['ok'=>true] : ['ok'=>false, 'msg'=>'Unidades insuficientes'];

            case 'box':
                $u = self::ensureUser($userId);
                $key = isset(self::$BOXES[$itemId]) ? self::$BOXES[$itemId] : null;
                if (!$key) return ['ok'=>false,'msg'=>'Cofre inválido'];
                return ((int)$u[$key] >= $amount)
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>'Cofres insuficientes'];

            case 'box_climate':
                $u = self::ensureUser($userId);
                $key = isset(self::$CLIMATE_BOXES[$itemId]) ? self::$CLIMATE_BOXES[$itemId] : null;
                if (!$key) return ['ok'=>false,'msg'=>'Cofre climático inválido'];
                return ((int)$u[$key] >= $amount)
                    ? ['ok'=>true] : ['ok'=>false,'msg'=>'Cofres insuficientes'];

            case 'improvement':
                $db     = Database::get();
                $prefix = self::prefix();
                $row = $db->selectSingle(
                    "SELECT quantity FROM `".$prefix."users_improvements_inv`
                     WHERE user_id = :u AND item_id = :i",
                    [':u' => (int)$userId, ':i' => (int)$itemId]);
                if (!$row) return ['ok'=>false, 'msg'=>'No tienes esta mejora'];
                return ((int)$row['quantity'] >= $amount)
                    ? ['ok'=>true] : ['ok'=>false, 'msg'=>'Unidades insuficientes'];
        }
        return ['ok'=>false,'msg'=>'Tipo inválido'];
    }

    public static function removeItem($userId, $type, $itemId, $amount)
    {
        global $USER, $PLANET, $resource;
        $amount = (int)$amount;
        $db     = Database::get();
        $prefix = self::prefix();
        $planetId = isset($PLANET['id']) ? (int)$PLANET['id'] : 0;

        switch ($type) {
            case 'metal':
                $PLANET['metal'] = max(0, (int)$PLANET['metal'] - $amount);
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET metal = GREATEST(0, metal - :a) WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'crystal':
                $PLANET['crystal'] = max(0, (int)$PLANET['crystal'] - $amount);
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET crystal = GREATEST(0, crystal - :a) WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'deuterium':
                $PLANET['deuterium'] = max(0, (int)$PLANET['deuterium'] - $amount);
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET deuterium = GREATEST(0, deuterium - :a) WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'norium':      // 🆕 v2.6
            case 'germanium':   // 🆕 v2.6
                $PLANET[$type] = max(0, (int)$PLANET[$type] - $amount);
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET `".$type."` = GREATEST(0, `".$type."` - :a) WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'dark_matter':
                // FIX v2.6.4 — Usar la función segura
                $current = self::getGlobalDarkMatter();
                self::setGlobalDarkMatter($current - $amount);
                $db->update(
                    "UPDATE `".$prefix."users` SET darkmatter = GREATEST(0, darkmatter - :a) WHERE id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            // v2.7 — Cofre genérico
            case 'container':
                $current = isset($USER['containers']) ? (int)$USER['containers'] : 0;
                $USER['containers'] = max(0, $current - $amount);
                $db->update(
                    "UPDATE `".$prefix."users` SET containers = GREATEST(0, containers - :a) WHERE id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            case 'ship':
            case 'defense':
                $colName = isset($resource[(int)$itemId]) ? $resource[(int)$itemId] : null;
                if ($colName && isset($PLANET[$colName])) {
                    $PLANET[$colName] = max(0, (int)$PLANET[$colName] - $amount);
                    if ($planetId > 0) {
                        $db->update(
                            "UPDATE `".$prefix."planets` SET `".$colName."` = GREATEST(0, `".$colName."` - :a) WHERE id = :pid",
                            [':a'=>$amount, ':pid'=>$planetId]);
                    }
                }
                break;

            case 'box':
                $key = self::$BOXES[$itemId];
                self::ensureUser($userId);
                $db->update(
                    "UPDATE `".$prefix."users_market` SET $key = GREATEST(0, $key - :a)
                     WHERE user_id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            case 'box_climate':
                $key = self::$CLIMATE_BOXES[$itemId];
                self::ensureUser($userId);
                $db->update(
                    "UPDATE `".$prefix."users_market` SET $key = GREATEST(0, $key - :a)
                     WHERE user_id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            case 'improvement':
                $db->update(
                    "UPDATE `".$prefix."users_improvements_inv`
                     SET quantity = quantity - :a
                     WHERE user_id = :u AND item_id = :i",
                    [':a'=>$amount, ':u'=>(int)$userId, ':i'=>(int)$itemId]);
                $db->delete(
                    "DELETE FROM `".$prefix."users_improvements_inv`
                     WHERE user_id = :u AND item_id = :i AND quantity <= 0",
                    [':u'=>(int)$userId, ':i'=>(int)$itemId]);
                break;
        }
    }

    public static function giveItem($userId, $type, $itemId, $amount, $itemName = '')
    {
        global $USER, $PLANET, $resource;
        $amount = (int)$amount;
        $db     = Database::get();
        $prefix = self::prefix();
        $planetId = isset($PLANET['id']) ? (int)$PLANET['id'] : 0;

        switch ($type) {
            case 'metal':
                $PLANET['metal'] += $amount;
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET metal = metal + :a WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'crystal':
                $PLANET['crystal'] += $amount;
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET crystal = crystal + :a WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'deuterium':
                $PLANET['deuterium'] += $amount;
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET deuterium = deuterium + :a WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'norium':      // 🆕 v2.6
            case 'germanium':   // 🆕 v2.6
                $PLANET[$type] += $amount;
                if ($planetId > 0) {
                    $db->update(
                        "UPDATE `".$prefix."planets` SET `".$type."` = `".$type."` + :a WHERE id = :pid",
                        [':a'=>$amount, ':pid'=>$planetId]);
                }
                break;
            case 'dark_matter':
                // FIX v2.6.4 — Usar la función segura
                $current = self::getGlobalDarkMatter();
                self::setGlobalDarkMatter($current + $amount);
                $db->update(
                    "UPDATE `".$prefix."users` SET darkmatter = darkmatter + :a WHERE id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            // v2.7 — Cofre genérico
            case 'container':
                $current = isset($USER['containers']) ? (int)$USER['containers'] : 0;
                $USER['containers'] = $current + $amount;
                $db->update(
                    "UPDATE `".$prefix."users` SET containers = containers + :a WHERE id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            case 'ship':
            case 'defense':
                $colName = isset($resource[(int)$itemId]) ? $resource[(int)$itemId] : null;
                if ($colName && isset($PLANET[$colName])) {
                    $PLANET[$colName] = (int)$PLANET[$colName] + $amount;
                    if ($planetId > 0) {
                        $db->update(
                            "UPDATE `".$prefix."planets` SET `".$colName."` = `".$colName."` + :a WHERE id = :pid",
                            [':a'=>$amount, ':pid'=>$planetId]);
                    }
                }
                break;

            case 'box':
                $key = self::$BOXES[$itemId];
                self::ensureUser($userId);
                $db->update(
                    "UPDATE `".$prefix."users_market` SET $key = $key + :a
                     WHERE user_id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            case 'box_climate':
                $key = self::$CLIMATE_BOXES[$itemId];
                self::ensureUser($userId);
                $db->update(
                    "UPDATE `".$prefix."users_market` SET $key = $key + :a
                     WHERE user_id = :u",
                    [':a'=>$amount, ':u'=>(int)$userId]);
                break;

            case 'improvement':
                $row = $db->selectSingle(
                    "SELECT id, quantity, is_penalized FROM `".$prefix."users_improvements_inv`
                     WHERE user_id = :u AND item_id = :i",
                    [':u'=>(int)$userId, ':i'=>(int)$itemId]);

                if ($row) {
                    $db->update(
                        "UPDATE `".$prefix."users_improvements_inv`
                         SET quantity = quantity + :a, is_penalized = 0
                         WHERE id = :id",
                        [':a'=>$amount, ':id'=>(int)$row['id']]);
                } else {
                    $db->insert(
                        "INSERT INTO `".$prefix."users_improvements_inv`
                         (`user_id`, `item_id`, `quantity`, `is_penalized`, `fecha_obtencion`)
                         VALUES (:u, :i, :a, 0, :t)",
                        [
                            ':u'=>(int)$userId,
                            ':i'=>(int)$itemId,
                            ':a'=>$amount,
                            ':t'=>TIMESTAMP,
                        ]);
                }
                break;
        }
    }

    /* ============================================================
     * CONSULTAS DE OFERTAS
     * ============================================================ */

    public static function getOffer($offerId)
    {
        $prefix = self::prefix();
        return Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."market_offers` WHERE offer_id = :id",
            [':id' => (int)$offerId]);
    }

    public static function getOffers($filters, $page = 1)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $sql = "SELECT o.*, u.username AS seller_name
                FROM `".$prefix."market_offers` o
                LEFT JOIN `".$prefix."users` u ON u.id = o.seller_id
                WHERE o.status = 'active'
                  AND (o.expires > :now OR o.admin_offer = 1)";
        $par = [':now' => TIMESTAMP];

        if (!empty($filters['cat']) && $filters['cat'] !== 'all') {
            $map = [
                'resource'    => ['metal','crystal','deuterium','dark_matter'],
                'ship'        => ['ship'],
                'defense'     => ['defense'],
                'box'         => ['box','box_climate','container'],
                'improvement' => ['improvement'],
            ];
            if (isset($map[$filters['cat']])) {
                $in = "'".implode("','", $map[$filters['cat']])."'";
                $sql .= " AND o.item_type IN ($in)";
            }
        }
        if (!empty($filters['type']) && $filters['type'] !== 'all') {
            $sql .= " AND o.offer_type = :ot";
            $par[':ot'] = $filters['type'];
        }
        if (!empty($filters['q'])) {
            $sql .= " AND (o.item_name LIKE :q OR u.username LIKE :q)";
            $par[':q'] = '%'.$filters['q'].'%';
        }

        $sortMap = [
            'price_asc'  => 'o.admin_offer DESC, o.price_ntx ASC',
            'price_desc' => 'o.admin_offer DESC, o.price_ntx DESC',
            'expires'    => 'o.admin_offer DESC, o.expires ASC',
            'recent'     => 'o.admin_offer DESC, o.created DESC',
        ];
        $sort = $sortMap[$filters['sort'] ?? 'recent'] ?? $sortMap['recent'];

        $offset = (($page - 1) * self::PAGE_SIZE);
        $sql .= " ORDER BY $sort LIMIT $offset,".self::PAGE_SIZE;

        return $db->select($sql, $par);
    }

    public static function countOffers($filters)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $sql = "SELECT COUNT(*) AS c
                FROM `".$prefix."market_offers` o
                LEFT JOIN `".$prefix."users` u ON u.id = o.seller_id
                WHERE o.status = 'active'
                  AND (o.expires > :now OR o.admin_offer = 1)";
        $par = [':now' => TIMESTAMP];

        if (!empty($filters['cat']) && $filters['cat'] !== 'all') {
            $map = [
                'resource'    => ['metal','crystal','deuterium','dark_matter'],
                'ship'        => ['ship'],
                'defense'     => ['defense'],
                'box'         => ['box','box_climate','container'],
                'improvement' => ['improvement'],
            ];
            if (isset($map[$filters['cat']])) {
                $in = "'".implode("','", $map[$filters['cat']])."'";
                $sql .= " AND o.item_type IN ($in)";
            }
        }
        if (!empty($filters['type']) && $filters['type'] !== 'all') {
            $sql .= " AND o.offer_type = :ot";
            $par[':ot'] = $filters['type'];
        }
        if (!empty($filters['q'])) {
            $sql .= " AND (o.item_name LIKE :q OR u.username LIKE :q)";
            $par[':q'] = '%'.$filters['q'].'%';
        }

        return (int)$db->selectSingle($sql, $par)['c'];
    }

    public static function getMyOffers($userId)
    {
        $prefix = self::prefix();
        $offers = Database::get()->select(
            "SELECT * FROM `".$prefix."market_offers`
             WHERE seller_id = :u
             ORDER BY status ASC, admin_offer DESC, expires ASC",
            [':u' => (int)$userId]);

        if (!is_array($offers)) return [];

        foreach ($offers as &$o) {
            $o['remaining'] = max(0, (int)$o['expires'] - TIMESTAMP);
            $o['total']     = (int)$o['duration'] * 3600;
            $o['progress']  = $o['total'] > 0
                ? round(($o['remaining'] / $o['total']) * 100) : 0;
            $o['urgency']   = self::calcUrgency($o);
        }
        unset($o);
        return $offers;
    }

    public static function calcUrgency($offer)
    {
        if ($offer['status'] !== 'active') return 'inactive';
        if ((int)$offer['admin_offer'] === 1) return 'ok';
        $r = (int)$offer['remaining'];
        if ($r <= 0)      return 'expired';
        if ($r < 3600)    return 'critical';
        if ($r < 10800)   return 'warning';
        if ($r < 21600)   return 'attention';
        return 'ok';
    }

    /* ============================================================
     * v2.6 — CREAR OFERTA (SELL)
     * ------------------------------------------------------------
     * ⚠️ CAMBIO v2.6: YA NO se quitan los items del planeta.
     * Los items quedan en el planeta del vendedor.
     * Solo guardamos planet_id + verificamos que el vendedor los
     * tenga para "comprometer" la venta.
     * ============================================================ */

    public static function createOffer($sellerId, $data)
    {
        $db     = Database::get();
        $prefix = self::prefix();

        $duration = (int)($data['duration'] ?? self::DURATION_24H);
        if (!in_array($duration, [self::DURATION_24H, self::DURATION_48H])) {
            return ['error' => 'Duración inválida'];
        }

        $limit = self::canPublish($sellerId);
        if (!$limit['ok']) return ['error' => $limit['msg']];

        $amount = (int)$data['amount'];
        $price  = max(self::MIN_PRICE, (int)$data['price_ntx']);
        if ($amount <= 0) return ['error' => 'Cantidad inválida'];

        $priceCheck = self::validatePrice(
            $data['item_type'], (int)$data['item_id'], $price);
        if (!$priceCheck['ok']) return ['error' => $priceCheck['msg']];

        // v2.5 — El fee se calcula para guardarlo, pero NO se cobra ahora
        $feePct = self::getSellerFeePct($sellerId, $duration);

        // v2.6 — Solo verificamos que el usuario tenga el item
        // (los items NO salen del planeta)
        $check = self::hasItem($sellerId, $data['item_type'],
                               (int)$data['item_id'], $amount);
        if (!$check['ok']) return ['error' => $check['msg']];

        // v2.6 — Guardamos el planet_id del planeta actual
        $planetId = isset($GLOBALS['PLANET']['id'])
            ? (int)$GLOBALS['PLANET']['id'] : 0;

        // ✅ v3.9 — Rechazar planet_id=0: sin planeta la oferta caería en la
        // rama LEGACY al cancelar/expirar (devolvía items con addUserItem que
        // el vendedor NUNCA perdió en v2.6) y al vender entregaba al comprador
        // sin quitar nada al vendedor → items acuñados. Mejor no publicar.
        if ($planetId <= 0) {
            return ['error' => 'No se pudo resolver tu planeta. No se publicó la oferta.'];
        }

        $ttl = $duration === self::DURATION_48H
            ? self::OFFER_TTL_48H : self::OFFER_TTL_24H;

        $db->insert(
            "INSERT INTO `".$prefix."market_offers` SET
                seller_id = :s, planet_id = :pid, offer_type = 'sell',
                admin_offer = 0,
                item_type = :t, item_id = :i, item_name = :n,
                amount = :a, price_ntx = :p,
                duration = :d, fee_seller_pct = :fs, fee_buyer_pct = 0,
                fee_acceptor_pct = 0,
                seller_fee_paid = 0, seller_was_vip = :vip,
                created = :cr, expires = :ex, status = 'active'",
            [':s'=>$sellerId, ':pid'=>$planetId,
             ':t'=>$data['item_type'],
             ':i'=>(int)$data['item_id'], ':n'=>$data['item_name'],
             ':a'=>$amount, ':p'=>$price, ':d'=>$duration,
             ':fs'=>$feePct,
             ':vip'=>(self::isVip($sellerId) ? 1 : 0),
             ':cr'=>TIMESTAMP, ':ex'=>TIMESTAMP + $ttl]);

        self::incrementOffersToday($sellerId);

        return ['ok' => true, 'offer_id' => $db->lastInsertId()];
    }

    /* ============================================================
     * v2.6 — CREAR BUY ORDER
     * ------------------------------------------------------------
     * ⚠️ CAMBIO v2.6: YA NO se congela el NTX del comprador.
     * El NTX queda disponible (pero se verifica al ejecutar).
     * ============================================================ */

    public static function createBuyOrder($buyerId, $data)
    {
        $db     = Database::get();
        $prefix = self::prefix();

        $duration = (int)($data['duration'] ?? self::DURATION_24H);
        if (!in_array($duration, [self::DURATION_24H, self::DURATION_48H])) {
            return ['error' => 'Duración inválida'];
        }

        $limit = self::canPublish($buyerId);
        if (!$limit['ok']) return ['error' => $limit['msg']];

        $amount = (int)$data['amount'];
        $price  = max(self::MIN_PRICE, (int)$data['price_ntx']);
        if ($amount <= 0) return ['error' => 'Cantidad inválida'];

        $priceCheck = self::validatePrice(
            $data['item_type'], (int)$data['item_id'], $price);
        if (!$priceCheck['ok']) return ['error' => $priceCheck['msg']];

        // v2.6 — Verificamos que el buyer tenga el NTX ahora.
        // (No lo congelamos, pero sí verificamos que lo tenga).
        if (self::getBalance($buyerId) < $price) {
            return ['error' => "Necesitas $price NTX-20"];
        }

        // v2.6 — NO se congela el NTX.
        // self::freezeBalance($buyerId, $price);   // ← ELIMINADO

        $planetId = isset($GLOBALS['PLANET']['id'])
            ? (int)$GLOBALS['PLANET']['id'] : 0;

        $ttl = $duration === self::DURATION_48H
            ? self::OFFER_TTL_48H : self::OFFER_TTL_24H;

        $db->insert(
            "INSERT INTO `".$prefix."market_offers` SET
                seller_id = :s, planet_id = :pid, offer_type = 'buy',
                admin_offer = 0,
                item_type = :t, item_id = :i, item_name = :n,
                amount = :a, price_ntx = :p,
                duration = :d, fee_seller_pct = 0, fee_buyer_pct = 0,
                fee_acceptor_pct = 0,
                seller_fee_paid = 0, seller_was_vip = :vip,
                created = :cr, expires = :ex, status = 'active'",
            [':s'=>$buyerId, ':pid'=>$planetId,
             ':t'=>$data['item_type'],
             ':i'=>(int)$data['item_id'], ':n'=>$data['item_name'],
             ':a'=>$amount, ':p'=>$price, ':d'=>$duration,
             ':vip'=>(self::isVip($buyerId) ? 1 : 0),
             ':cr'=>TIMESTAMP, ':ex'=>TIMESTAMP + $ttl]);

        self::incrementOffersToday($buyerId);

        return ['ok' => true, 'offer_id' => $db->lastInsertId()];
    }

    /* ============================================================
     * v2.6 — CANCELAR OFERTA
     * ------------------------------------------------------------
     * ⚠️ CAMBIO v2.6:
     *  - Ofertas NUEVAS (planet_id > 0): NO se devuelve nada
     *    (nunca salió nada del planeta)
     *  - Ofertas LEGACY (planet_id = 0): se devuelve al planeta
     *    principal del dueño (por compatibilidad)
     * ============================================================ */

    public static function cancelOffer($userId, $offerId)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $o      = self::getOffer($offerId);

        if (!$o) return ['error' => 'Oferta no encontrada'];
        if ((int)$o['seller_id'] !== (int)$userId)
            return ['error' => 'No autorizado'];
        if ($o['status'] !== 'active')
            return ['error' => 'Oferta no activa'];
        if ((int)$o['admin_offer'] === 1)
            return ['error' => 'No puedes cancelar ofertas de admin'];

        $planetId = isset($o['planet_id']) ? (int)$o['planet_id'] : 0;

        // v2.6 — Solo devolvemos para ofertas LEGACY (planet_id = 0)
        if ($planetId === 0) {
            $mainPlanet = self::getMainPlanetId($userId);

            if ($o['offer_type'] === 'sell') {
                self::addUserItem($userId, $mainPlanet,
                    $o['item_type'], (int)$o['item_id'], (int)$o['amount']);
            }
            if ($o['offer_type'] === 'buy') {
                // unfreeze es safe para legacy (balance_frozen > 0)
                self::unfreezeBalance($userId, (int)$o['price_ntx']);
            }
        }
        // Ofertas NUEVAS: no hay nada que devolver (nunca salió nada)

        $db->update(
            "UPDATE `".$prefix."market_offers`
             SET status = 'cancelled', cancel_reason = 'seller_cancelled'
             WHERE offer_id = :id",
            [':id' => $offerId]);

        return ['ok' => true];
    }

    /* ============================================================
     * v2.6 — COMPRAR (aceptar SELL ORDER)
     * ------------------------------------------------------------
     * ⚠️ CAMBIO v2.6:
     *  - Antes de comprar, verificamos que el vendedor TENGA los
     *    items en su planeta (planet_id).
     *  - Si NO los tiene → auto-cancelar con reason
     *    'seller_no_resources' y devolver error al comprador.
     *  - Si SÍ los tiene → quitar del planeta del vendedor y dar
     *    al planeta del comprador.
     * ============================================================ */

    public static function buyOffer($buyerId, $offerId)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $o      = self::getOffer($offerId);

        if (!$o || $o['status'] !== 'active')
            return ['error' => 'Oferta no disponible'];

        if ($o['offer_type'] !== 'sell')
            return ['error' => 'No es una oferta de venta'];

        if ((int)$o['seller_id'] === (int)$buyerId)
            return ['error' => 'No puedes comprar tu propia oferta'];

        $isAdmin = ((int)$o['admin_offer'] === 1);
        if (!$isAdmin && (int)$o['expires'] < TIMESTAMP)
            return ['error' => 'Oferta expirada'];

        $price  = (int)$o['price_ntx'];
        $seller = (int)$o['seller_id'];

        // v2.5 — El comprador paga SIEMPRE el precio limpio
        $total = $price;
        if (self::getAvailableBalance($buyerId) < $total)
            return ['error' => "Necesitas $total NTX-20"];

        // ✅ v3.9 — CLAIM atómico ANTES de mover dinero (UPDATE condicional +
        // rowCount): solo el primer request compra. Antes el UPDATE final era
        // incondicional y dos compras concurrentes cobraban al comprador,
        // acreditaban al vendedor y entregaban items DOS veces (items
        // acuñados de la nada).
        $db->update(
            "UPDATE `".$prefix."market_offers` SET status = 'sold'
             WHERE offer_id = :id AND status = 'active'",
            [':id' => $offerId]);
        if ($db->rowCount() !== 1) {
            return ['error' => 'Oferta no disponible (otro jugador acaba de comprarla)'];
        }

        // v2.6 — VERIFICAR que el vendedor TENGA los items (solo para
        // ofertas nuevas — legacy ya los tenían removidos al crear)
        $planetId   = isset($o['planet_id']) ? (int)$o['planet_id'] : 0;
        $sellerPlanet = self::resolvePlanetId($seller, $planetId);

        if ($planetId > 0) {
            // Oferta NUEVA — el vendedor debe tener los items AHORA
            $hasItems = self::checkUserItem(
                $seller, $sellerPlanet,
                $o['item_type'], (int)$o['item_id'], (int)$o['amount']);

            if (!$hasItems) {
                // AUTO-CANCELAR la oferta
                $db->update(
                    "UPDATE `".$prefix."market_offers`
                     SET status = 'cancelled',
                         cancel_reason = 'seller_no_resources'
                     WHERE offer_id = :id",
                    [':id' => $offerId]);

                return ['error' =>
                    'La oferta fue cancelada automaticamente: el vendedor '.
                    'ya no tiene suficientes recursos (posible ataque). '.
                    'No se te ha cobrado nada.'];
            }
        }

        // ✅ v3.9 — Resolver el planeta del comprador ANTES de cobrar:
        // si no se puede resolver, aborta SIN cobrar ni tocar la oferta
        // (antes el pago ya salía y el item nunca se entregaba).
        $buyerPlanet = isset($GLOBALS['PLANET']['id'])
            ? (int)$GLOBALS['PLANET']['id'] : 0;
        if ($planetId > 0 && $buyerPlanet <= 0) {
            self::revertOfferClaim($offerId);
            return ['error' => 'No se pudo resolver tu planeta. Intenta de nuevo.'];
        }

        // v2.5 — Calcular fee que se descuenta al vendedor
        if ($isAdmin) {
            $sellerFeePct = 0;
            $sellerFee    = 0;
            $sellerNet    = $price;
        } else {
            $duration     = (int)$o['duration'];
            $sellerFeePct = self::getSellerFeePct($seller, $duration);
            $sellerFee    = (int)ceil($price * $sellerFeePct / 100);
            // ✅ v3.9 — PISO del neto del vendedor: la comisión NUNCA se come
            // la venta entera (antes vender por 1 NTX con fee 5% →
            // ceil(0.05)=1 → el vendedor recibía 0). El fee se limita a
            // price - 1: el vendedor siempre gana al menos 1 NTX-20.
            $sellerFee    = min($sellerFee, max(0, $price - 1));
            $sellerNet    = $price - $sellerFee;
        }

        // Movimientos de saldo
        // ✅ v3.9 — Con guard: si el saldo del comprador ya no alcanza
        // (carrera con otro gasto), NADA se mueve y la oferta vuelve a active.
        if (!self::subtractBalance($buyerId, $total)) {
            self::revertOfferClaim($offerId);
            return ['error' => 'Saldo insuficiente. No se te ha cobrado nada.'];
        }
        self::addBalance($seller, $sellerNet);

        // Log del comprador (gasto)
        self::logNtx20(
            $buyerId,
            -$total,
            'market_buy',
            'Compra en mercado: '.$o['item_name'].' (x'.(int)$o['amount'].')'.($isAdmin ? ' [ADMIN]' : ''),
            $offerId
        );

        // Log del vendedor (ingreso neto)
        if (!$isAdmin) {
            self::logNtx20(
                $seller,
                +$sellerNet,
                'market_sell',
                'Venta en mercado: '.$o['item_name'].' (x'.(int)$o['amount'].') - fee '.$sellerFeePct.'%',
                $offerId
            );

            if ($sellerFee > 0) {
                self::addToFund('seller', $sellerFee);
                self::logNtx20(
                    $seller,
                    -$sellerFee,
                    'market_fee',
                    'Comisión de venta: '.$o['item_name'].' ('.$sellerFeePct.'%)',
                    $offerId
                );
            }
        }

        // v2.6 — MOVER LOS ITEMS
        // Para ofertas nuevas: quitar del planeta del vendedor + dar
        // al planeta del comprador (usando helpers planet-specific).
        // Para ofertas legacy: los items estaban en "limbo", solo se
        // dan al comprador con el flujo actual.
        if ($planetId > 0) {
            // 1) Quitar del planeta del vendedor
            self::removeUserItem(
                $seller, $sellerPlanet,
                $o['item_type'], (int)$o['item_id'], (int)$o['amount']);

            // 2) Dar al comprador (planeta YA resuelto antes de cobrar ✅ v3.9)
            if ($buyerPlanet > 0) {
                self::addUserItem(
                    $buyerId, $buyerPlanet,
                    $o['item_type'], (int)$o['item_id'], (int)$o['amount']);
                // Refrescar $GLOBALS['PLANET'] del comprador
                $col = ($o['item_type'] === 'metal')     ? 'metal'
                     : (($o['item_type'] === 'crystal')  ? 'crystal'
                     : (($o['item_type'] === 'deuterium') ? 'deuterium' : null));
                if ($col) {
                    $GLOBALS['PLANET'][$col] =
                        (float)$GLOBALS['PLANET'][$col] + (int)$o['amount'];
                } elseif ($o['item_type'] === 'ship' || $o['item_type'] === 'defense') {
                    global $resource;
                    $colName = $resource[(int)$o['item_id']] ?? null;
                    if ($colName && isset($GLOBALS['PLANET'][$colName])) {
                        $GLOBALS['PLANET'][$colName] =
                            (int)$GLOBALS['PLANET'][$colName] + (int)$o['amount'];
                    }
                } elseif ($o['item_type'] === 'dark_matter') {
                    // FIX v2.6.4
                    $current = self::getGlobalDarkMatter();
                    self::setGlobalDarkMatter($current + (int)$o['amount']);
                } elseif ($o['item_type'] === 'container') {
                    // v2.7 — Cofre genérico: actualizar $GLOBALS['USER']
                    $current = isset($GLOBALS['USER']['containers'])
                        ? (int)$GLOBALS['USER']['containers'] : 0;
                    $GLOBALS['USER']['containers'] = $current + (int)$o['amount'];
                }
            }
        } else {
            // LEGACY: los items estaban en limbo, se dan al comprador
            self::giveItem($buyerId, $o['item_type'],
                           (int)$o['item_id'], (int)$o['amount'],
                           $o['item_name']);
        }

        // ✅ v3.9 — La oferta ya está 'sold' (claim atómico de arriba):
        // aquí solo se registran las comisiones efectivamente pagadas.
        $db->update(
            "UPDATE `".$prefix."market_offers` SET
                seller_fee_paid = :sfp,
                fee_seller_pct = :fsp
             WHERE offer_id = :id",
            [':sfp'=>$sellerFee, ':fsp'=>$sellerFeePct, ':id'=>$offerId]);

        // Log del mercado
        $db->insert(
            "INSERT INTO `".$prefix."market_log` SET
                offer_id=:o, buyer_id=:b, seller_id=:s, offer_type='sell',
                item_type=:t, item_id=:i, item_name=:n,
                amount=:a, price_ntx=:p,
                fee_seller=:fs, fee_buyer=0,
                fee_seller_pct=:fsp, fee_buyer_pct=0,
                seller_was_vip=:sv, buyer_was_vip=:bv,
                time=:ti",
            [':o'=>$offerId, ':b'=>$buyerId, ':s'=>$seller,
             ':t'=>$o['item_type'], ':i'=>(int)$o['item_id'], ':n'=>$o['item_name'],
             ':a'=>(int)$o['amount'], ':p'=>$price,
             ':fs'=>$sellerFee, ':fsp'=>$sellerFeePct,
             ':sv'=>(int)$o['seller_was_vip'],
             ':bv'=>(self::isVip($buyerId) ? 1 : 0),
             ':ti'=>TIMESTAMP]);

        $db->update(
            "UPDATE `".$prefix."users_market` SET total_bought = total_bought + 1
             WHERE user_id = :u",
            [':u' => $buyerId]);
        $db->update(
            "UPDATE `".$prefix."users_market` SET total_sold = total_sold + 1
             WHERE user_id = :u",
            [':u' => $seller]);

        if (class_exists('MarketTrendsHelper')) {
            MarketTrendsHelper::recordSale(
                $o['item_type'], (int)$o['item_id'],
                $o['item_name'], (int)$o['amount'], $price);
        }

        return ['ok' => true];
    }

    /* ============================================================
     * v2.6 — ACEPTAR BUY ORDER
     * ------------------------------------------------------------
     * ⚠️ CAMBIO v2.6:
     *  - Antes de aceptar, verificamos que el BUYER TENGA el NTX.
     *  - Si NO lo tiene → auto-cancelar con reason 'buyer_no_ntx'
     *    y devolver error al aceptador.
     *  - Si SÍ lo tiene → proceder (quitar items al aceptador,
     *    dar al buyer, transferir NTX).
     * ============================================================ */

    public static function fulfillBuyOrder($acceptorId, $offerId)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $o      = self::getOffer($offerId);

        if (!$o || $o['status'] !== 'active')
            return ['error' => 'Orden no disponible'];

        if ($o['offer_type'] !== 'buy')
            return ['error' => 'No es una orden de compra'];

        if ((int)$o['seller_id'] === (int)$acceptorId)
            return ['error' => 'No puedes aceptar tu propia orden'];

        $isAdmin = ((int)$o['admin_offer'] === 1);
        if (!$isAdmin && (int)$o['expires'] < TIMESTAMP)
            return ['error' => 'Orden expirada'];

        $price  = (int)$o['price_ntx'];
        $buyer  = (int)$o['seller_id'];   // quien creó la orden (buyer)

        // v2.6 — VERIFICAR que el BUYER TENGA el NTX
        $planetId = isset($o['planet_id']) ? (int)$o['planet_id'] : 0;

        if (!$isAdmin && self::getAvailableBalance($buyer) < $price) {
            // ✅ v3.9 — Saldo DISPONIBLE (antes getBalance sin descontar el
            // congelado): un buyer con NTX congelado pasaba el check y luego
            // el subtractBalance pagaba 0 → NTX acuñados hacia el aceptador.
            // AUTO-CANCELAR la orden
            $db->update(
                "UPDATE `".$prefix."market_offers`
                 SET status = 'cancelled',
                     cancel_reason = 'buyer_no_ntx'
                 WHERE offer_id = :id",
                [':id' => $offerId]);

            return ['error' =>
                'La orden fue cancelada automaticamente: el comprador '.
                'ya no tiene suficiente NTX-20. No se te ha quitado nada.'];
        }

        // Verificar que el aceptador tenga el ítem
        $check = self::hasItem($acceptorId, $o['item_type'],
                               (int)$o['item_id'], (int)$o['amount']);
        if (!$check['ok']) return ['error' => $check['msg']];

        // ✅ v3.9 — CLAIM atómico ANTES de quitar items ni cobrar (rowCount):
        // dos aceptadores concurrentes ya no pueden ejecutar la orden dos
        // veces (doble cobro al buyer, items acuñados).
        $db->update(
            "UPDATE `".$prefix."market_offers` SET status = 'sold'
             WHERE offer_id = :id AND status = 'active'",
            [':id' => $offerId]);
        if ($db->rowCount() !== 1) {
            return ['error' => 'Orden no disponible (otro jugador acaba de aceptarla)'];
        }

        // v2.5 — Calcular fee del aceptador según duración + VIP
        if ($isAdmin) {
            $acceptorFeePct = 0;
            $acceptorFee    = 0;
            $acceptorNet    = $price;
        } else {
            $duration       = (int)$o['duration'];
            $acceptorFeePct = self::getAcceptorFeePct($acceptorId, $duration);
            $acceptorFee    = (int)ceil($price * $acceptorFeePct / 100);
            // ✅ v3.9 — PISO del neto (idéntico a buyOffer): la comisión nunca
            // deja al aceptador en 0.
            $acceptorFee    = min($acceptorFee, max(0, $price - 1));
            $acceptorNet    = $price - $acceptorFee;
        }

        // ✅ v3.9 — Resolver el destino del buyer ANTES de quitar items ni
        // cobrar: si no hay planeta, aborta limpio (revertir claim).
        $buyerPlanet = self::resolvePlanetId($buyer, $planetId);
        if ($buyerPlanet <= 0) {
            self::revertOfferClaim($offerId);
            return ['error' => 'El comprador no tiene planeta disponible. Intenta de nuevo.'];
        }

        // ✅ v3.9 — Cobrar al buyer PRIMERO y con guard (primer movimiento de
        // dinero): si falla, aborta SIN haber quitado items a nadie.
        if ($planetId === 0) {
            self::unfreezeBalance($buyer, $price);
        }
        if (!self::subtractBalance($buyer, $price)) {
            self::revertOfferClaim($offerId);
            return ['error' => 'El comprador ya no tiene saldo. Nada se ha perdido.'];
        }

        // v2.6 — Quitar el ítem del aceptador (usuario actual)
        self::removeItem($acceptorId, $o['item_type'],
                         (int)$o['item_id'], (int)$o['amount']);

        // v2.6 — Dar el ítem al buyer (planeta ya resuelto ✅ v3.9)
        self::addUserItem(
            $buyer, $buyerPlanet,
            $o['item_type'], (int)$o['item_id'], (int)$o['amount']);

        // Acreditar al aceptador el neto
        self::addBalance($acceptorId, $acceptorNet);

        // Log del buyer (gasto)
        if (!$isAdmin) {
            self::logNtx20(
                $buyer,
                -$price,
                'market_buy',
                'Orden de compra ejecutada: '.$o['item_name'].' (x'.(int)$o['amount'].')',
                $offerId
            );
        }

        // Log del aceptador (ingreso neto)
        self::logNtx20(
            $acceptorId,
            +$acceptorNet,
            'market_sell',
            'Venta en mercado (buy order): '.$o['item_name'].' (x'.(int)$o['amount'].')'
                .($isAdmin ? ' [ADMIN]' : ' - fee '.$acceptorFeePct.'%'),
            $offerId
        );

        // Fee al fondo
        if (!$isAdmin && $acceptorFee > 0) {
            self::addToFund('seller', $acceptorFee);
            self::logNtx20(
                $acceptorId,
                -$acceptorFee,
                'market_fee',
                'Comisión de venta (buy order): '.$o['item_name'].' ('.$acceptorFeePct.'%)',
                $offerId
            );
        }

        // ✅ v3.9 — La orden ya está 'sold' (claim atómico): solo se
        // registran las comisiones efectivamente pagadas.
        $db->update(
            "UPDATE `".$prefix."market_offers` SET
                acceptor_fee = :af,
                fee_acceptor_pct = :afp
             WHERE offer_id = :id",
            [':af'=>$acceptorFee, ':afp'=>$acceptorFeePct, ':id'=>$offerId]);

        // Log del mercado
        $db->insert(
            "INSERT INTO `".$prefix."market_log` SET
                offer_id=:o, buyer_id=:b, seller_id=:s, offer_type='buy',
                item_type=:t, item_id=:i, item_name=:n,
                amount=:a, price_ntx=:p,
                fee_seller=:fs, fee_buyer=0,
                fee_seller_pct=:fsp, fee_buyer_pct=0,
                seller_was_vip=:sv, buyer_was_vip=:bv,
                time=:ti",
            [':o'=>$offerId, ':b'=>$buyer, ':s'=>$acceptorId,
             ':t'=>$o['item_type'], ':i'=>(int)$o['item_id'], ':n'=>$o['item_name'],
             ':a'=>(int)$o['amount'], ':p'=>$price,
             ':fs'=>$acceptorFee, ':fsp'=>$acceptorFeePct,
             ':sv'=>(int)$o['seller_was_vip'],
             ':bv'=>(self::isVip($acceptorId) ? 1 : 0),
             ':ti'=>TIMESTAMP]);

        $db->update(
            "UPDATE `".$prefix."users_market` SET total_sold = total_sold + 1
             WHERE user_id = :u",
            [':u' => $acceptorId]);

        if (class_exists('MarketTrendsHelper')) {
            MarketTrendsHelper::recordSale(
                $o['item_type'], (int)$o['item_id'],
                $o['item_name'], (int)$o['amount'], $price);
        }

        return ['ok' => true];
    }

    /* ============================================================
     * CREAR OFERTA DE ADMIN
     * ============================================================ */

    public static function createAdminOffer($adminId, $data)
    {
        $db     = Database::get();
        $prefix = self::prefix();

        $amount = (int)$data['amount'];
        $price  = max(1, (int)$data['price_ntx']);
        if ($amount <= 0) return ['error' => 'Cantidad inválida'];

        $db->insert(
            "INSERT INTO `".$prefix."market_offers` SET
                seller_id = :s, planet_id = 0, offer_type = 'sell',
                admin_offer = 1,
                item_type = :t, item_id = :i, item_name = :n,
                amount = :a, price_ntx = :p,
                duration = 0,
                fee_seller_pct = 0, fee_buyer_pct = 0,
                fee_acceptor_pct = 0,
                seller_fee_paid = 0, fee_buyer_paid = 0,
                seller_was_vip = 0,
                created = :cr, expires = 0, status = 'active'",
            [':s'=>$adminId, ':t'=>$data['item_type'],
             ':i'=>(int)$data['item_id'], ':n'=>$data['item_name'],
             ':a'=>$amount, ':p'=>$price, ':cr'=>TIMESTAMP]);

        return ['ok' => true, 'offer_id' => $db->lastInsertId()];
    }

    /* ============================================================
     * v2.6 — EXPIRACIÓN
     * ------------------------------------------------------------
     * ⚠️ CAMBIO v2.6:
     *  - Ofertas NUEVAS (planet_id > 0): NO se devuelve nada
     *    (los items nunca salieron del planeta).
     *  - Ofertas LEGACY (planet_id = 0): se devuelve al planeta
     *    principal del dueño.
     * ============================================================ */

    public static function expireOffers()
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $expired = $db->select(
            "SELECT * FROM `".$prefix."market_offers`
             WHERE status = 'active'
               AND admin_offer = 0
               AND expires > 0
               AND expires < :n",
            [':n' => TIMESTAMP]);

        if (!is_array($expired)) return;

        foreach ($expired as $o) {
            $planetId = isset($o['planet_id']) ? (int)$o['planet_id'] : 0;

            // Solo devolvemos para LEGACY (planet_id = 0)
            if ($planetId === 0) {
                $sellerId   = (int)$o['seller_id'];
                $mainPlanet = self::getMainPlanetId($sellerId);

                if ($o['offer_type'] === 'sell') {
                    self::addUserItem(
                        $sellerId, $mainPlanet,
                        $o['item_type'], (int)$o['item_id'], (int)$o['amount']);
                } else {
                    // unfreeze es safe para legacy (balance_frozen > 0)
                    self::unfreezeBalance($sellerId, (int)$o['price_ntx']);
                }
            }
            // Ofertas NUEVAS: nada que devolver

            $db->update(
                "UPDATE `".$prefix."market_offers`
                 SET status = 'expired', cancel_reason = 'expired'
                 WHERE offer_id = :id",
                [':id' => $o['offer_id']]);
        }
    }

    /* ============================================================
     * FONDO DEL PROYECTO
     * ============================================================ */

    public static function addToFund($source, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return;

        $prefix = self::prefix();
        $col = ($source === 'seller') ? 'from_seller'
             : (($source === 'buyer') ? 'from_buyer' : 'from_admin');

        Database::get()->update(
            "UPDATE `".$prefix."market_fund` SET
                total_earned = total_earned + :a,
                $col = $col + :a,
                last_update = :t
             WHERE id = 1",
            [':a' => $amount, ':t' => TIMESTAMP]);
    }

    public static function getFund()
    {
        $prefix = self::prefix();
        return Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."market_fund` WHERE id = 1");
    }

    /* ============================================================
     * LOG / HISTORIAL
     * ============================================================ */

    public static function getLog($userId, $limit = 20)
    {
        $limit  = (int)$limit;
        $prefix = self::prefix();
        return Database::get()->select(
            "SELECT l.*, u.username AS buyer_name, s.username AS seller_name
             FROM `".$prefix."market_log` l
             LEFT JOIN `".$prefix."users` u ON u.id = l.buyer_id
             LEFT JOIN `".$prefix."users` s ON s.id = l.seller_id
             WHERE l.buyer_id = :u OR l.seller_id = :u
             ORDER BY l.time DESC
             LIMIT $limit",
            [':u' => (int)$userId]);
    }

    /* ============================================================
     * SUGERIR PRECIO
     * ============================================================ */

    public static function suggestPrice($itemType, $itemId)
    {
        $prefix = self::prefix();
        $db = Database::get();
        $row = $db->selectSingle(
            "SELECT AVG(price_ntx) AS avg_p, MIN(price_ntx) AS min_p,
                    MAX(price_ntx) AS max_p
             FROM `".$prefix."market_offers`
             WHERE status = 'active'
               AND expires > :now
               AND item_type = :t
               AND item_id = :i",
            [':now' => TIMESTAMP, ':t' => $itemType, ':i' => (int)$itemId]);

        if (!$row || $row['avg_p'] === null) return null;

        return [
            'avg' => (int)round($row['avg_p']),
            'min' => (int)$row['min_p'],
            'max' => (int)$row['max_p'],
        ];
    }

    /* ============================================================
     * FORMATO ABREVIADO
     * ============================================================ */

    public static function formatAmount($n)
    {
        $n = (int)$n;
        if ($n >= 1000000) return number_format($n / 1000000, 2).'M';
        if ($n >= 1000)    return number_format($n / 1000, 2).'K';
        return (string)$n;
    }
}