<?php
/**
 * ============================================================
 * CrossMarketHelper — Mercado Cruzado AstroIO v1.4
 * ============================================================
 * v1.4 — CAMBIOS:
 *  - SOPORTE COFRES CLIMÁTICOS: Añadido item_type 'box_climate'
 *  - Nuevo array $CLIMATE_BOXES para mapear IDs a columnas.
 *  - Actualizados checkUserItem, removeUserItem y addUserItem.
 * ============================================================
 * v1.3 — CAMBIOS:
 *  - FIX CRÍTICO: createBuyOrder() ahora guarda `untx_amount`.
 *  - FIX CRÍTICO: executeBuyFromInternational() ahora lee `untx_amount`
 *    en lugar de `amount` (que es la cantidad de ítems).
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

class CrossMarketHelper
{
    const CURRENCY_NAC = 'NTX20_NAC';
    const CURRENCY_INT = 'UNTX20_INT';

    const SIDE_BUY  = 'buy';
    const SIDE_SELL = 'sell';

    const STATUS_OPEN      = 'open';
    const STATUS_LOCKED    = 'locked';
    const STATUS_FILLED    = 'filled';
    const STATUS_CANCELLED = 'cancelled';
    const STATUS_EXPIRED   = 'expired';

    const TRADE_PENDING   = 'pending';
    const TRADE_COMPLETED = 'completed';
    const TRADE_FAILED    = 'failed';
    const TRADE_REVERSED  = 'reversed';

    const UNIT_USD_DEFAULT   = 0.1;
    const SPREAD_PCT_DEFAULT = 5.0;
    const TASA_DEFAULT       = 820.0;

    public static $BOXES = [
        1 => 'box_common',
        2 => 'box_rare',
        3 => 'box_legendary',
    ];

    public static $CLIMATE_BOXES = [
        1 => 'box_climate_minor',
        2 => 'box_climate_major',
        3 => 'box_climate_dominion',
    ];

    /* ============================================================
     * UTILIDADES
     * ============================================================ */

    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    private static function db()
    {
        return Database::get();
    }

    private static function now()
    {
        return defined('TIMESTAMP') ? (int)TIMESTAMP : time();
    }

    private static function getConfig($key, $default = null)
    {
        $prefix = self::prefix();
        $row = self::db()->selectSingle(
            "SELECT * FROM `".$prefix."config` WHERE uni = 1"
        );
        if (!$row) return $default;

        if (isset($row[$key]) && $row[$key] !== null && $row[$key] !== '') {
            return $row[$key];
        }
        return $default;
    }

    /* ============================================================
     * TASA Y SPREAD
     * ============================================================ */

    public static function getTasaQvapay()
    {
        $tasa = 0.0;

        if (class_exists('QvaPay')) {
            try {
                if (method_exists('QvaPay', 'getP2PAverages')) {
                    $avg = QvaPay::getP2PAverages();
                    if (isset($avg['CUP']['average'])) {
                        $tasa = (float)$avg['CUP']['average'];
                    }
                }
            } catch (Exception $e) {
                $tasa = 0.0;
            }
        }

        if ($tasa <= 1) {
            $tasa = (float)self::getConfig('qvapay_tasa_cup_por_kyber', self::TASA_DEFAULT);
        }

        if ($tasa <= 1) {
            $tasa = self::TASA_DEFAULT;
        }

        return $tasa;
    }

    public static function getSpreadPct()
    {
        $pct = (float)self::getConfig('cross_spread_pct', self::SPREAD_PCT_DEFAULT);
        if ($pct < 0) $pct = 0;
        if ($pct > 50) $pct = 50;
        return $pct;
    }

    public static function getUnitUsd()
    {
        $u = (float)self::getConfig('cross_unit_usd', self::UNIT_USD_DEFAULT);
        if ($u <= 0) $u = self::UNIT_USD_DEFAULT;
        return $u;
    }

    /* ============================================================
     * CALCULOS DEL CRUCE
     * ============================================================ */

    public static function calculateSellToInternational($cupAmount)
    {
        $cupAmount = (int)$cupAmount;
        if ($cupAmount <= 0) {
            return ['error' => 'Cantidad CUP invalida'];
        }

        $tasa     = self::getTasaQvapay();
        $spread   = self::getSpreadPct();
        $unitUsd  = self::getUnitUsd();

        $valorUsd = $cupAmount / $tasa;
        $usdCobrar = $valorUsd * (1 + ($spread / 100));
        $untxCobrar = (int)ceil($usdCobrar / $unitUsd);

        if ($untxCobrar <= 0) {
            $untxCobrar = 1;
        }

        $untxValorReal = (int)ceil($valorUsd / $unitUsd);
        $spreadUntx = $untxCobrar - $untxValorReal;

        return [
            'ok'             => true,
            'tasa'           => $tasa,
            'spread_pct'     => $spread,
            'unit_usd'       => $unitUsd,
            'cup_amount'     => $cupAmount,
            'valor_usd'      => round($valorUsd, 6),
            'usd_cobrar'     => round($usdCobrar, 6),
            'untx_cobrar'    => $untxCobrar,
            'untx_valor_real'=> $untxValorReal,
            'spread_untx'    => $spreadUntx,
        ];
    }

    public static function calculateBuyFromInternational($untxAmount)
    {
        $untxAmount = (int)$untxAmount;
        if ($untxAmount <= 0) {
            return ['error' => 'Cantidad UNTX invalida'];
        }

        $tasa    = self::getTasaQvapay();
        $spread  = self::getSpreadPct();
        $unitUsd = self::getUnitUsd();

        $valorCup = $untxAmount * $unitUsd * $tasa;
        $cupCobrar = $valorCup * (1 + ($spread / 100));

        return [
            'ok'          => true,
            'tasa'        => $tasa,
            'spread_pct'  => $spread,
            'unit_usd'    => $unitUsd,
            'untx_amount' => $untxAmount,
            'valor_cup'   => round($valorCup, 6),
            'cup_cobrar'  => (int)ceil($cupCobrar),
            'spread_cup'  => (int)ceil($cupCobrar) - (int)ceil($valorCup),
        ];
    }

    /* ============================================================
     * WALLETS Y LEDGER
     * ============================================================ */

    public static function getWallet($userId, $currencyCode)
    {
        $prefix = self::prefix();
        return self::db()->selectSingle(
            "SELECT * FROM `".$prefix."wallets`
             WHERE user_id = :u AND currency_code = :c",
            [':u' => (int)$userId, ':c' => $currencyCode]
        );
    }

    public static function ensureWallet($userId, $currencyCode)
    {
        $wallet = self::getWallet($userId, $currencyCode);
        if ($wallet) return $wallet;

        $prefix = self::prefix();
        self::db()->insert(
            "INSERT INTO `".$prefix."wallets`
                (user_id, currency_code, balance_juego, balance_retirable)
             VALUES (:u, :c, 0, 0)",
            [':u' => (int)$userId, ':c' => $currencyCode]
        );

        return self::getWallet($userId, $currencyCode);
    }

    public static function getBalance($userId, $currencyCode)
    {
        $wallet = self::ensureWallet($userId, $currencyCode);
        if (!$wallet) return 0;
        return (int)$wallet['balance_juego'] + (int)$wallet['balance_retirable'];
    }

    public static function addBalance($userId, $currencyCode, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return;

        self::ensureWallet($userId, $currencyCode);
        $prefix = self::prefix();

        self::db()->update(
            "UPDATE `".$prefix."wallets`
             SET balance_juego = balance_juego + :a
             WHERE user_id = :u AND currency_code = :c",
            [':a' => $amount, ':u' => (int)$userId, ':c' => $currencyCode]
        );
    }

    public static function subtractBalance($userId, $currencyCode, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return;

        self::ensureWallet($userId, $currencyCode);
        $prefix = self::prefix();

        self::db()->update(
            "UPDATE `".$prefix."wallets`
             SET balance_juego = GREATEST(0, balance_juego - :a)
             WHERE user_id = :u AND currency_code = :c",
            [':a' => $amount, ':u' => (int)$userId, ':c' => $currencyCode]
        );
    }

    public static function addLedger($userId, $currencyCode, $amount, $tipo, $referenceId = null, $metadata = null)
    {
        $wallet = self::ensureWallet($userId, $currencyCode);
        if (!$wallet) return false;

        $prefix = self::prefix();
        self::db()->insert(
            "INSERT INTO `".$prefix."ledger_entries`
                (wallet_id, user_id, currency_code, amount, tipo, reference_id, metadata, created_at)
             VALUES
                (:w, :u, :c, :a, :t, :r, :m, :cr)",
            [
                ':w'  => (int)$wallet['id'],
                ':u'  => (int)$userId,
                ':c'  => $currencyCode,
                ':a'  => (int)$amount,
                ':t'  => $tipo,
                ':r'  => $referenceId,
                ':m'  => $metadata ? json_encode($metadata) : null,
                ':cr' => date('Y-m-d H:i:s', self::now()),
            ]
        );
        return true;
    }

    /* ============================================================
     * RESERVAS
     * ============================================================ */

    public static function addReserve($currencyCode, $amount)
    {
        $amount = (int)$amount;
        if ($amount == 0) return;

        $prefix = self::prefix();
        self::db()->update(
            "UPDATE `".$prefix."reserves`
             SET balance = GREATEST(0, balance + :a)
             WHERE currency_code = :c",
            [':a' => $amount, ':c' => $currencyCode]
        );
    }

    public static function subtractReserve($currencyCode, $amount)
    {
        $amount = (int)$amount;
        if ($amount <= 0) return;

        $prefix = self::prefix();
        self::db()->update(
            "UPDATE `".$prefix."reserves`
             SET balance = GREATEST(0, balance - :a)
             WHERE currency_code = :c",
            [':a' => $amount, ':c' => $currencyCode]
        );
    }

    /* ============================================================
     * INVENTARIO — PLANETAS E ÍTEMS
     * ============================================================ */

    public static function getMainPlanetId($userId)
    {
        $prefix = self::prefix();
        $row = self::db()->selectSingle(
            "SELECT id FROM `".$prefix."planets`
             WHERE id_owner = :u AND planet_type = 1
             ORDER BY id ASC LIMIT 1",
            [':u' => (int)$userId]
        );
        return ($row && isset($row['id'])) ? (int)$row['id'] : 0;
    }

    public static function resolvePlanetId($userId, $preferredPlanetId = 0)
    {
        if ((int)$preferredPlanetId > 0) return (int)$preferredPlanetId;
        return self::getMainPlanetId($userId);
    }

    public static function checkUserItem($userId, $planetId, $type, $itemId, $amount)
    {
        global $resource;
        $amount = (int)$amount;
        if ($amount <= 0) return false;

        $db     = self::db();
        $prefix = self::prefix();

        switch ($type) {
            case 'metal':
            case 'crystal':
            case 'deuterium':
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

    public static function removeUserItem($userId, $planetId, $type, $itemId, $amount)
    {
        global $resource;
        $amount = (int)$amount;
        if ($amount <= 0) return;

        $db     = self::db();
        $prefix = self::prefix();

        switch ($type) {
            case 'metal':
            case 'crystal':
            case 'deuterium':
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

    public static function addUserItem($userId, $planetId, $type, $itemId, $amount)
    {
        global $resource;
        $amount = (int)$amount;
        if ($amount <= 0) return;

        $db     = self::db();
        $prefix = self::prefix();

        switch ($type) {
            case 'metal':
            case 'crystal':
            case 'deuterium':
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
                $exists = $db->selectSingle(
                    "SELECT user_id FROM `".$prefix."users_market` WHERE user_id = :u",
                    [':u' => (int)$userId]);
                if (!$exists) {
                    $db->insert(
                        "INSERT INTO `".$prefix."users_market`
                            (user_id, balance_frozen, offers_today, total_bought, total_sold,
                             box_common, box_rare, box_legendary, box_climate_minor, box_climate_major, box_climate_dominion, last_reset)
                         VALUES (:u, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)",
                        [':u' => (int)$userId]);
                }
                $db->update(
                    "UPDATE `".$prefix."users_market`
                     SET `".$key."` = `".$key."` + :a
                     WHERE user_id = :u",
                    [':a' => $amount, ':u' => (int)$userId]);
                break;

            case 'box_climate':
                $key = isset(self::$CLIMATE_BOXES[$itemId]) ? self::$CLIMATE_BOXES[$itemId] : null;
                if (!$key) return;
                $exists = $db->selectSingle(
                    "SELECT user_id FROM `".$prefix."users_market` WHERE user_id = :u",
                    [':u' => (int)$userId]);
                if (!$exists) {
                    $db->insert(
                        "INSERT INTO `".$prefix."users_market`
                            (user_id, balance_frozen, offers_today, total_bought, total_sold,
                             box_common, box_rare, box_legendary, box_climate_minor, box_climate_major, box_climate_dominion, last_reset)
                         VALUES (:u, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)",
                        [':u' => (int)$userId]);
                }
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
                            ':t' => self::now(),
                        ]);
                }
                break;
        }
    }

    /* ============================================================
     * ORDENES
     * ============================================================ */

    public static function getOrder($orderId)
    {
        $prefix = self::prefix();
        return self::db()->selectSingle(
            "SELECT * FROM `".$prefix."cross_orders` WHERE id = :id",
            [':id' => (int)$orderId]
        );
    }

    public static function createSellOrder($userId, $data)
    {
        $amountCup = isset($data['amount_cup']) ? (int)$data['amount_cup'] : 0;
        $itemType  = isset($data['item_type']) ? $data['item_type'] : 'resource';
        $itemId    = isset($data['item_id']) ? (int)$data['item_id'] : 0;
        $itemName  = isset($data['item_name']) ? $data['item_name'] : 'Recurso';
        $itemAmount= isset($data['item_amount']) ? (int)$data['item_amount'] : 0;
        $idem      = isset($data['idempotency_key']) ? $data['idempotency_key'] : null;

        if ($amountCup <= 0) {
            return ['error' => 'Precio CUP invalido'];
        }
        if ($itemAmount <= 0) {
            return ['error' => 'Cantidad de item invalida'];
        }

        if ($idem) {
            $prefix = self::prefix();
            $exists = self::db()->selectSingle(
                "SELECT id FROM `".$prefix."cross_orders` WHERE idempotency_key = :k",
                [':k' => $idem]
            );
            if ($exists) {
                return ['ok' => true, 'order_id' => (int)$exists['id'], 'duplicated' => true];
            }
        }

        $planetId = 0;
        if (isset($GLOBALS['PLANET']['id'])) {
            $planetId = (int)$GLOBALS['PLANET']['id'];
        }
        if ($planetId <= 0) {
            $planetId = self::getMainPlanetId($userId);
        }

        if (!self::checkUserItem($userId, $planetId, $itemType, $itemId, $itemAmount)) {
            return ['error' => 'No tienes suficientes items en este planeta'];
        }

        $calc = self::calculateSellToInternational($amountCup);
        if (isset($calc['error'])) {
            return ['error' => $calc['error']];
        }

        $prefix = self::prefix();
        self::db()->insert(
            "INSERT INTO `".$prefix."cross_orders`
                (user_id, planet_id, side, item_type, item_id, item_name, amount,
                 price_amount, currency_code, status, idempotency_key, created_at, expires_at)
             VALUES
                (:u, :pid, 'sell', :it, :ii, :in, :a,
                 :p, :c, 'open', :k, :cr, :ex)",
            [
                ':u'  => (int)$userId,
                ':pid'=> (int)$planetId,
                ':it' => $itemType,
                ':ii' => $itemId,
                ':in' => $itemName,
                ':a'  => $itemAmount,
                ':p'  => $amountCup,
                ':c'  => self::CURRENCY_NAC,
                ':k'  => $idem,
                ':cr' => self::now(),
                ':ex' => self::now() + 86400,
            ]
        );

        return [
            'ok'       => true,
            'order_id' => (int)self::db()->lastInsertId(),
            'calc'     => $calc,
        ];
    }

    public static function createBuyOrder($userId, $data)
    {
        $untxAmount = isset($data['untx_amount']) ? (int)$data['untx_amount'] : 0;
        $itemType   = isset($data['item_type']) ? $data['item_type'] : 'resource';
        $itemId     = isset($data['item_id']) ? (int)$data['item_id'] : 0;
        $itemName   = isset($data['item_name']) ? $data['item_name'] : 'Recurso';
        $itemAmount = isset($data['item_amount']) ? (int)$data['item_amount'] : 0;
        $idem       = isset($data['idempotency_key']) ? $data['idempotency_key'] : null;

        if ($untxAmount <= 0) {
            return ['error' => 'Cantidad UNTX invalida'];
        }
        if ($itemAmount <= 0) {
            return ['error' => 'Cantidad de item invalida'];
        }

        if ($idem) {
            $prefix = self::prefix();
            $exists = self::db()->selectSingle(
                "SELECT id FROM `".$prefix."cross_orders` WHERE idempotency_key = :k",
                [':k' => $idem]
            );
            if ($exists) {
                return ['ok' => true, 'order_id' => (int)$exists['id'], 'duplicated' => true];
            }
        }

        $planetId = 0;
        if (isset($GLOBALS['PLANET']['id'])) {
            $planetId = (int)$GLOBALS['PLANET']['id'];
        }
        if ($planetId <= 0) {
            $planetId = self::getMainPlanetId($userId);
        }

        $calc = self::calculateBuyFromInternational($untxAmount);
        if (isset($calc['error'])) {
            return ['error' => $calc['error']];
        }

        $prefix = self::prefix();
        self::db()->insert(
            "INSERT INTO `".$prefix."cross_orders`
                (user_id, planet_id, side, item_type, item_id, item_name, amount,
                 untx_amount, price_amount, currency_code, status, idempotency_key, created_at, expires_at)
             VALUES
                (:u, :pid, 'buy', :it, :ii, :in, :a,
                 :ua, :p, :c, 'open', :k, :cr, :ex)",
            [
                ':u'  => (int)$userId,
                ':pid'=> (int)$planetId,
                ':it' => $itemType,
                ':ii' => $itemId,
                ':in' => $itemName,
                ':a'  => $itemAmount,
                ':ua' => $untxAmount,
                ':p'  => (int)$calc['cup_cobrar'],
                ':c'  => self::CURRENCY_INT,
                ':k'  => $idem,
                ':cr' => self::now(),
                ':ex' => self::now() + 86400,
            ]
        );

        return [
            'ok'       => true,
            'order_id' => (int)self::db()->lastInsertId(),
            'calc'     => $calc,
        ];
    }

    public static function cancelOrder($userId, $orderId)
    {
        $order = self::getOrder($orderId);
        if (!$order) return ['error' => 'Orden no encontrada'];
        if ((int)$order['user_id'] !== (int)$userId) return ['error' => 'No autorizado'];
        if ($order['status'] !== self::STATUS_OPEN) return ['error' => 'Orden no abierta'];

        $prefix = self::prefix();
        self::db()->update(
            "UPDATE `".$prefix."cross_orders`
             SET status = 'cancelled'
             WHERE id = :id",
            [':id' => (int)$orderId]
        );

        return ['ok' => true];
    }

    public static function expireOrders()
    {
        $prefix = self::prefix();
        $now = self::now();

        self::db()->update(
            "UPDATE `".$prefix."cross_orders`
             SET status = 'expired'
             WHERE status = 'open' AND expires_at > 0 AND expires_at < :n",
            [':n' => $now]
        );
    }

    /* ============================================================
     * EJECUTAR CRUCE — NACIONAL VENDE, INTERNACIONAL COMPRA
     * ============================================================ */

    public static function executeSellToInternational($buyerId, $sellOrderId, $buyerPlanetId = 0, $idempotencyKey = null)
    {
        if ($idempotencyKey) {
            $prefix = self::prefix();
            $exists = self::db()->selectSingle(
                "SELECT id FROM `".$prefix."cross_trades` WHERE idempotency_key = :k",
                [':k' => $idempotencyKey]
            );
            if ($exists) {
                return ['ok' => true, 'trade_id' => (int)$exists['id'], 'duplicated' => true];
            }
        }

        $order = self::getOrder($sellOrderId);
        if (!$order) return ['error' => 'Orden no encontrada'];
        if ($order['status'] !== self::STATUS_OPEN) return ['error' => 'Orden no disponible'];
        if ($order['side'] !== self::SIDE_SELL) return ['error' => 'No es una orden de venta'];
        if ((int)$order['user_id'] === (int)$buyerId) return ['error' => 'No puedes comprar tu propia orden'];

        $sellerId   = (int)$order['user_id'];
        $cupAmount  = (int)$order['price_amount'];
        $itemAmount = (int)$order['amount'];
        $itemType   = $order['item_type'];
        $itemId     = (int)$order['item_id'];

        $sellerPlanet = self::resolvePlanetId($sellerId, (int)$order['planet_id']);

        if (!self::checkUserItem($sellerId, $sellerPlanet, $itemType, $itemId, $itemAmount)) {
            $prefix = self::prefix();
            self::db()->update(
                "UPDATE `".$prefix."cross_orders`
                 SET status = 'cancelled'
                 WHERE id = :id",
                [':id' => (int)$sellOrderId]
            );
            return ['error' => 'La oferta fue cancelada automaticamente: el vendedor ya no tiene los items'];
        }

        $calc = self::calculateSellToInternational($cupAmount);
        if (isset($calc['error'])) return ['error' => $calc['error']];

        $untxToPay = (int)$calc['untx_cobrar'];
        if (self::getBalance($buyerId, self::CURRENCY_INT) < $untxToPay) {
            return ['error' => 'El comprador no tiene suficiente UNTX'];
        }

        $realBuyerPlanet = self::resolvePlanetId($buyerId, $buyerPlanetId);
        if ($realBuyerPlanet <= 0) {
            return ['error' => 'El comprador no tiene planeta principal'];
        }

        $prefix = self::prefix();
        $now = self::now();

        self::db()->update(
            "UPDATE `".$prefix."cross_orders`
             SET status = 'locked'
             WHERE id = :id AND status = 'open'",
            [':id' => (int)$sellOrderId]
        );

        // ✅ v3.9 — Solo el proceso que GANA el lock ejecuta el cruce (rowCount):
        // antes el resultado del UPDATE no se comprobaba y dos compradores
        // concurrentes ejecutaban el cruce COMPLETO dos veces (doble pago,
        // doble entrega de items).
        if (self::db()->rowCount() !== 1) {
            return ['error' => 'La orden acaba de ser ejecutada por otro jugador'];
        }

        // ✅ v3.9 — Tracking de pasos para compensación en cascada
        $done = array();

        try {
            self::subtractBalance($buyerId, self::CURRENCY_INT, $untxToPay);
            $done[] = 'buyer_paid';
            self::addBalance($sellerId, self::CURRENCY_NAC, $cupAmount);
            $done[] = 'seller_paid';

            self::addReserve(self::CURRENCY_INT, $untxToPay);
            $done[] = 'res_int';
            self::subtractReserve(self::CURRENCY_NAC, $cupAmount);
            $done[] = 'res_nac';

            self::addLedger(
                $buyerId,
                self::CURRENCY_INT,
                -$untxToPay,
                'market_buy',
                'cross_sell_'.$sellOrderId,
                ['order_id' => $sellOrderId, 'tasa' => $calc['tasa'], 'spread_pct' => $calc['spread_pct']]
            );
            $done[] = 'led_b';

            self::addLedger(
                $sellerId,
                self::CURRENCY_NAC,
                $cupAmount,
                'market_sell',
                'cross_sell_'.$sellOrderId,
                ['order_id' => $sellOrderId, 'buyer_id' => $buyerId]
            );
            $done[] = 'led_s';

            self::removeUserItem($sellerId, $sellerPlanet, $itemType, $itemId, $itemAmount);
            $done[] = 'item_s';
            self::addUserItem($buyerId, $realBuyerPlanet, $itemType, $itemId, $itemAmount);
            $done[] = 'item_b';

            self::db()->insert(
                "INSERT INTO `".$prefix."cross_trades`
                    (buy_order_id, sell_order_id, buyer_id, seller_id,
                     item_type, item_id, item_name, amount,
                     currency_buyer, currency_seller, amount_buyer, amount_seller,
                     tasa_qvapay, spread_pct, spread_amount, spread_currency,
                     status, idempotency_key, created_at)
                 VALUES
                    (0, :so, :b, :s,
                     :it, :ii, :in, :a,
                     :cb, :cs, :ab, :as,
                     :tasa, :sp, :sa, :sc,
                     'completed', :k, :cr)",
                [
                    ':so'   => (int)$sellOrderId,
                    ':b'    => (int)$buyerId,
                    ':s'    => (int)$sellerId,
                    ':it'   => $itemType,
                    ':ii'   => $itemId,
                    ':in'   => $order['item_name'],
                    ':a'    => $itemAmount,
                    ':cb'   => self::CURRENCY_INT,
                    ':cs'   => self::CURRENCY_NAC,
                    ':ab'   => $untxToPay,
                    ':as'   => $cupAmount,
                    ':tasa' => $calc['tasa'],
                    ':sp'   => $calc['spread_pct'],
                    ':sa'   => (int)$calc['spread_untx'],
                    ':sc'   => self::CURRENCY_INT,
                    ':k'    => $idempotencyKey,
                    ':cr'   => $now,
                ]
            );

            $tradeId = (int)self::db()->lastInsertId();

            self::db()->update(
                "UPDATE `".$prefix."cross_orders`
                 SET status = 'filled'
                 WHERE id = :id",
                [':id' => (int)$sellOrderId]
            );

            return ['ok' => true, 'trade_id' => $tradeId, 'calc' => $calc];

        } catch (Exception $e) {
            // ✅ v3.9 — Compensación en cascada SOLO de lo que llegó a moverse
            // (antes el catch solo re-abría la orden: dinero/items descontados
            // sin entrega ni devolución). Los asientos de ledger se dejan como
            // rastro de auditoría (no se revierten).
            try {
                if (in_array('item_b', $done, true)) {
                    self::removeUserItem($buyerId, $realBuyerPlanet, $itemType, $itemId, $itemAmount);
                }
                if (in_array('item_s', $done, true)) {
                    self::addUserItem($sellerId, $sellerPlanet, $itemType, $itemId, $itemAmount);
                }
                if (in_array('res_nac', $done, true)) {
                    self::addReserve(self::CURRENCY_NAC, $cupAmount);
                }
                if (in_array('res_int', $done, true)) {
                    self::subtractReserve(self::CURRENCY_INT, $untxToPay);
                }
                if (in_array('seller_paid', $done, true)) {
                    self::subtractBalance($sellerId, self::CURRENCY_NAC, $cupAmount);
                }
                if (in_array('buyer_paid', $done, true)) {
                    self::addBalance($buyerId, self::CURRENCY_INT, $untxToPay);
                }
            } catch (Exception $e2) { /* best-effort */ }

            self::db()->update(
                "UPDATE `".$prefix."cross_orders`
                 SET status = 'open'
                 WHERE id = :id AND status = 'locked'",
                [':id' => (int)$sellOrderId]
            );
            return ['error' => 'Error al ejecutar cruce (movimientos revertidos): '.$e->getMessage()];
        }
    }

    /* ============================================================
     * EJECUTAR CRUCE — INTERNACIONAL VENDE, NACIONAL COMPRA
     * ============================================================ */

    public static function executeBuyFromInternational($acceptorId, $buyOrderId, $acceptorPlanetId = 0, $idempotencyKey = null)
    {
        if ($idempotencyKey) {
            $prefix = self::prefix();
            $exists = self::db()->selectSingle(
                "SELECT id FROM `".$prefix."cross_trades` WHERE idempotency_key = :k",
                [':k' => $idempotencyKey]
            );
            if ($exists) {
                return ['ok' => true, 'trade_id' => (int)$exists['id'], 'duplicated' => true];
            }
        }

        $order = self::getOrder($buyOrderId);
        if (!$order) return ['error' => 'Orden no encontrada'];
        if ($order['status'] !== self::STATUS_OPEN) return ['error' => 'Orden no disponible'];
        if ($order['side'] !== self::SIDE_BUY) return ['error' => 'No es una orden de compra'];
        if ((int)$order['user_id'] === (int)$acceptorId) return ['error' => 'No puedes aceptar tu propia orden'];

        $buyerId    = (int)$order['user_id'];   // internacional
        // 🆕 CORRECCIÓN: Leer untx_amount en lugar de amount
        $untxAmount = (int)$order['untx_amount'];
        $itemAmount = (int)$order['amount'];
        $itemType   = $order['item_type'];
        $itemId     = (int)$order['item_id'];

        // Calcular CUP a cobrar al nacional
        $calc = self::calculateBuyFromInternational($untxAmount);
        if (isset($calc['error'])) return ['error' => $calc['error']];

        $cupToPay = (int)$calc['cup_cobrar'];

        // Verificar que el internacional (buyer) tenga UNTX
        if (self::getBalance($buyerId, self::CURRENCY_INT) < $untxAmount) {
            $prefix = self::prefix();
            self::db()->update(
                "UPDATE `".$prefix."cross_orders`
                 SET status = 'cancelled'
                 WHERE id = :id",
                [':id' => (int)$buyOrderId]
            );
            return ['error' => 'La orden fue cancelada automaticamente: el comprador ya no tiene suficiente UNTX'];
        }

        // Verificar que el aceptador (nacional) tenga el ítem
        $acceptorPlanet = self::resolvePlanetId($acceptorId, $acceptorPlanetId);
        if ($acceptorPlanet <= 0) {
            return ['error' => 'El aceptador no tiene planeta principal'];
        }

        if (!self::checkUserItem($acceptorId, $acceptorPlanet, $itemType, $itemId, $itemAmount)) {
            return ['error' => 'No tienes suficientes items en este planeta para aceptar la orden'];
        }

        // Verificar que el comprador (internacional) tenga planeta destino
        $buyerPlanet = self::resolvePlanetId($buyerId, (int)$order['planet_id']);
        if ($buyerPlanet <= 0) {
            return ['error' => 'El comprador internacional no tiene planeta principal'];
        }

        $prefix = self::prefix();
        $now = self::now();

        // Bloquear orden
        self::db()->update(
            "UPDATE `".$prefix."cross_orders`
             SET status = 'locked'
             WHERE id = :id AND status = 'open'",
            [':id' => (int)$buyOrderId]
        );

        // ✅ v3.9 — Solo el proceso que GANA el lock ejecuta el cruce (rowCount)
        if (self::db()->rowCount() !== 1) {
            return ['error' => 'La orden acaba de ser ejecutada por otro jugador'];
        }

        // ✅ v3.9 — Tracking de pasos para compensación en cascada
        $done = array();

        try {
            // Mover monedas
            self::subtractBalance($buyerId, self::CURRENCY_INT, $untxAmount);
            $done[] = 'buyer_paid';
            self::addBalance($acceptorId, self::CURRENCY_NAC, $cupToPay);
            $done[] = 'acceptor_paid';

            // Reservas: entra UNTX, sale NTX
            self::addReserve(self::CURRENCY_INT, $untxAmount);
            $done[] = 'res_int';
            self::subtractReserve(self::CURRENCY_NAC, $cupToPay);
            $done[] = 'res_nac';

            // Ledger del comprador internacional
            self::addLedger(
                $buyerId,
                self::CURRENCY_INT,
                -$untxAmount,
                'market_buy',
                'cross_buy_'.$buyOrderId,
                ['order_id' => $buyOrderId, 'tasa' => $calc['tasa'], 'spread_pct' => $calc['spread_pct']]
            );
            $done[] = 'led_b';

            // Ledger del aceptador nacional
            self::addLedger(
                $acceptorId,
                self::CURRENCY_NAC,
                $cupToPay,
                'market_sell',
                'cross_buy_'.$buyOrderId,
                ['order_id' => $buyOrderId, 'buyer_id' => $buyerId]
            );
            $done[] = 'led_s';

            // Mover ítem real
            self::removeUserItem($acceptorId, $acceptorPlanet, $itemType, $itemId, $itemAmount);
            $done[] = 'item_s';
            self::addUserItem($buyerId, $buyerPlanet, $itemType, $itemId, $itemAmount);
            $done[] = 'item_b';

            // Registrar cruce
            self::db()->insert(
                "INSERT INTO `".$prefix."cross_trades`
                    (buy_order_id, sell_order_id, buyer_id, seller_id,
                     item_type, item_id, item_name, amount,
                     currency_buyer, currency_seller, amount_buyer, amount_seller,
                     tasa_qvapay, spread_pct, spread_amount, spread_currency,
                     status, idempotency_key, created_at)
                 VALUES
                    (:bo, 0, :b, :s,
                     :it, :ii, :in, :a,
                     :cb, :cs, :ab, :as,
                     :tasa, :sp, :sa, :sc,
                     'completed', :k, :cr)",
                [
                    ':bo'   => (int)$buyOrderId,
                    ':b'    => (int)$buyerId,
                    ':s'    => (int)$acceptorId,
                    ':it'   => $itemType,
                    ':ii'   => $itemId,
                    ':in'   => $order['item_name'],
                    ':a'    => $itemAmount,
                    ':cb'   => self::CURRENCY_INT,
                    ':cs'   => self::CURRENCY_NAC,
                    ':ab'   => $untxAmount,
                    ':as'   => $cupToPay,
                    ':tasa' => $calc['tasa'],
                    ':sp'   => $calc['spread_pct'],
                    ':sa'   => (int)$calc['spread_cup'],
                    ':sc'   => self::CURRENCY_NAC,
                    ':k'    => $idempotencyKey,
                    ':cr'   => $now,
                ]
            );

            $tradeId = (int)self::db()->lastInsertId();

            // Marcar orden
            self::db()->update(
                "UPDATE `".$prefix."cross_orders`
                 SET status = 'filled'
                 WHERE id = :id",
                [':id' => (int)$buyOrderId]
            );

            return ['ok' => true, 'trade_id' => $tradeId, 'calc' => $calc];

        } catch (Exception $e) {
            // ✅ v3.9 — Compensación en cascada SOLO de lo que llegó a moverse
            try {
                if (in_array('item_b', $done, true)) {
                    self::removeUserItem($buyerId, $buyerPlanet, $itemType, $itemId, $itemAmount);
                }
                if (in_array('item_s', $done, true)) {
                    self::addUserItem($acceptorId, $acceptorPlanet, $itemType, $itemId, $itemAmount);
                }
                if (in_array('res_nac', $done, true)) {
                    self::addReserve(self::CURRENCY_NAC, $cupToPay);
                }
                if (in_array('res_int', $done, true)) {
                    self::subtractReserve(self::CURRENCY_INT, $untxAmount);
                }
                if (in_array('acceptor_paid', $done, true)) {
                    self::subtractBalance($acceptorId, self::CURRENCY_NAC, $cupToPay);
                }
                if (in_array('buyer_paid', $done, true)) {
                    self::addBalance($buyerId, self::CURRENCY_INT, $untxAmount);
                }
            } catch (Exception $e2) { /* best-effort */ }

            // Revertir bloqueo (solo si sigue locked)
            self::db()->update(
                "UPDATE `".$prefix."cross_orders`
                 SET status = 'open'
                 WHERE id = :id AND status = 'locked'",
                [':id' => (int)$buyOrderId]
            );
            return ['error' => 'Error al ejecutar cruce (movimientos revertidos): '.$e->getMessage()];
        }
    }
}