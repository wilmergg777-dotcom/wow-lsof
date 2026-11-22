<?php
/**
 * AstroIO — ColoniesHelper v1.0
 * Mercado Negro de Colonias — compra/venta entre jugadores por NTX-20
 * Archivo: includes/classes/ColoniesHelper.class.php
 *
 * Reglas:
 *  - Solo se venden COLONIAS (id_owner del user, no el principal).
 *  - Se vende TODO: edificios, defensas, naves y recursos (misma fila de planets).
 *  - Pago en NTX-20 (usa MarketHelper::subtractBalance / addBalance).
 *  - Comisión: MarketHelper::getSellerFeePct($sellerId, 24) → 5% / 3% VIP.
 *  - Sin caducidad (30 días como red de seguridad).
 *  - Bloquea si hay flotas en vuelo o estacionadas.
 *  - Sin transacciones (patrón del Market): lock optimista vía status.
 */

if (!defined('MODE')) die('Hacking attempt');

class ColoniesHelper
{
    /** Precio mínimo en NTX-20 */
    const MIN_PRICE = 50;
    /** Precio máximo en NTX-20 */
    const MAX_PRICE = 50000;
    /** Días que un listado puede estar en venta (red de seguridad) */
    const LISTING_TTL_DAYS = 30;
    /** Máximo de planetas por usuario (config del fork) */
    const MAX_PLANETS_PER_USER = 10;
    /** Duración para el cálculo del fee (24 = 5% normal / 3% VIP) */
    const FEE_DURATION = 24;

    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /* ============================================================
     * PLANETA PRINCIPAL (id_owner, no user_id)
     * ============================================================ */
    public static function isMainPlanet($userId, $planetId)
    {
        $prefix = self::prefix();
        $row = Database::get()->selectSingle(
            "SELECT MIN(id) AS mid FROM `".$prefix."planets`
             WHERE id_owner = :u AND planet_type = 1",
            [':u' => (int)$userId]);
        return $row && (int)$row['mid'] === (int)$planetId;
    }

    /* ============================================================
     * FLOTAS EN VUELO / ESTACIONADAS
     * Bloquea si fleet_mess<2 (en vuelo) O fleet_end_stay>0 (estacionada).
     * ============================================================ */
    public static function hasFleetsInFlight($planetId)
    {
        $prefix = self::prefix();
        $row = Database::get()->selectSingle(
            "SELECT COUNT(*) AS c FROM `".$prefix."fleets`
             WHERE (fleet_start_id = :pid OR fleet_end_id = :pid)
               AND (fleet_mess < 2 OR fleet_end_stay > 0)",
            [':pid' => (int)$planetId]);
        return $row && (int)$row['c'] > 0;
    }

    /* ============================================================
     * CANTIDAD DE PLANETAS DEL USUARIO
     * ============================================================ */
    public static function countPlanets($userId)
    {
        $prefix = self::prefix();
        $row = Database::get()->selectSingle(
            "SELECT COUNT(*) AS c FROM `".$prefix."planets`
             WHERE id_owner = :u AND planet_type = 1",
            [':u' => (int)$userId]);
        return $row ? (int)$row['c'] : 0;
    }

    /* ============================================================
     * VALIDACIÓN COMPLETA PARA PUBLICAR
     * ============================================================ */
    public static function canSellPlanet($userId, $planetId)
    {
        $prefix = self::prefix();
        $userId   = (int)$userId;
        $planetId = (int)$planetId;

        if ($userId <= 0) return ['ok'=>false, 'error'=>'Sesión inválida.'];

        // ¿Existe y es del user?
        $planet = Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."planets`
             WHERE id = :pid AND id_owner = :uid",
            [':pid'=>$planetId, ':uid'=>$userId]);
        if (!$planet) return ['ok'=>false, 'error'=>'Esa colonia no existe o no es tuya.'];

        // ¿Es el principal?
        if (self::isMainPlanet($userId, $planetId)) {
            return ['ok'=>false, 'error'=>'El planeta principal NO se puede vender. Solo colonias.'];
        }

        // ¿Es un planeta (type=1)?
        if ((int)$planet['planet_type'] !== 1) {
            return ['ok'=>false, 'error'=>'Solo se pueden vender planetas/colonias.'];
        }

        // ¿Ya está en venta?
        $already = Database::get()->selectSingle(
            "SELECT id FROM `".$prefix."blackmarket_listings`
             WHERE planet_id = :pid AND status = 'active'",
            [':pid'=>$planetId]);
        if ($already) return ['ok'=>false, 'error'=>'Esa colonia ya está publicada en venta.'];

        // ¿Vacaciones?
        $u = Database::get()->selectSingle(
            "SELECT vacation FROM `".$prefix."users` WHERE id = :uid",
            [':uid'=>$userId]);
        if ($u && !empty($u['vacation'])) {
            return ['ok'=>false, 'error'=>'No puedes vender en modo vacaciones.'];
        }

        // ¿Flotas en vuelo / estacionadas?
        if (self::hasFleetsInFlight($planetId)) {
            return ['ok'=>false, 'error'=>'Tienes flotas en vuelo o estacionadas en esa colonia. Recógelas primero.'];
        }

        return ['ok'=>true, 'error'=>''];
    }

    /* ============================================================
     * PUBLICAR COLONIA
     * ============================================================ */
    public static function listColony($userId, $planetId, $price)
    {
        $prefix = self::prefix();
        $userId   = (int)$userId;
        $planetId = (int)$planetId;
        $price    = (int)$price;

        if ($price < self::MIN_PRICE) {
            return ['error'=>'El precio mínimo es '.self::MIN_PRICE.' NTX-20.'];
        }
        if ($price > self::MAX_PRICE) {
            return ['error'=>'El precio máximo es '.number_format(self::MAX_PRICE,0,',','.').' NTX-20.'];
        }

        $check = self::canSellPlanet($userId, $planetId);
        if (!$check['ok']) return ['error'=>$check['error']];

        // Límite diario del Market (2/6)
        $limit = MarketHelper::canPublish($userId);
        if (!$limit['ok']) return ['error'=>$limit['msg']];

        $planet = Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."planets`
             WHERE id = :pid AND id_owner = :uid",
            [':pid'=>$planetId, ':uid'=>$userId]);
        if (!$planet) return ['error'=>'Colonia no encontrada.'];

        $feePct = MarketHelper::getSellerFeePct($userId, self::FEE_DURATION);
        $isVip  = MarketHelper::isVip($userId) ? 1 : 0;

        Database::get()->insert(
            "INSERT INTO `".$prefix."blackmarket_listings`
             (seller_id, planet_id, planet_name, galaxy, system, planet,
              price_ntx, fee_pct, seller_vip, status, created)
             VALUES (:s, :pid, :n, :g, :sy, :p, :pr, :fp, :vip, 'active', :now)",
            [
                ':s'   => $userId,
                ':pid' => $planetId,
                ':n'   => $planet['name'],
                ':g'   => (int)$planet['galaxy'],
                ':sy'  => (int)$planet['system'],
                ':p'   => (int)$planet['planet'],
                ':pr'  => $price,
                ':fp'  => $feePct,
                ':vip' => $isVip,
                ':now' => TIMESTAMP,
            ]);

        MarketHelper::incrementOffersToday($userId);

        return ['success'=>true, 'price'=>$price, 'fee_pct'=>$feePct];
    }

    /* ============================================================
     * CANCELAR LISTADO
     * ============================================================ */
    public static function cancelListing($userId, $listingId)
    {
        $prefix = self::prefix();
        $userId    = (int)$userId;
        $listingId = (int)$listingId;

        $row = Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."blackmarket_listings`
             WHERE id = :id AND seller_id = :uid AND status = 'active'",
            [':id'=>$listingId, ':uid'=>$userId]);
        if (!$row) return ['error'=>'Ese listado no existe o ya no está activo.'];

        Database::get()->update(
            "UPDATE `".$prefix."blackmarket_listings`
             SET status = 'cancelled', cancel_reason = 'seller_cancelled'
             WHERE id = :id",
            [':id'=>$listingId]);

        return ['success'=>true];
    }

    /* ============================================================
     * COMPRAR COLONIA
     * Sin transacciones: lock optimista vía UPDATE ... status='active'.
     * ============================================================ */
    public static function buyColony($buyerId, $listingId)
    {
        $prefix = self::prefix();
        $buyerId   = (int)$buyerId;
        $listingId = (int)$listingId;

        if ($buyerId <= 0) return ['error'=>'Sesión inválida.'];

        // 1) Leer listado
        $l = Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."blackmarket_listings`
             WHERE id = :id AND status = 'active'",
            [':id'=>$listingId]);
        if (!$l) return ['error'=>'Este listado ya no está disponible.'];

        $sellerId = (int)$l['seller_id'];
        $planetId = (int)$l['planet_id'];
        $price    = (int)$l['price_ntx'];

        if ($sellerId === $buyerId) return ['error'=>'No puedes comprar tu propia colonia.'];

        // 2) Verificar colonia aún es del vendedor
        $planet = Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."planets`
             WHERE id = :pid AND id_owner = :uid",
            [':pid'=>$planetId, ':uid'=>$sellerId]);
        if (!$planet) {
            Database::get()->update(
                "UPDATE `".$prefix."blackmarket_listings`
                 SET status='cancelled', cancel_reason='seller_no_planet'
                 WHERE id = :id",
                [':id'=>$listingId]);
            return ['error'=>'La colonia ya no pertenece al vendedor. Se canceló el listado.'];
        }

        // 3) Comprador: vacaciones / saldo / planetas
        $buyer = Database::get()->selectSingle(
            "SELECT id, username, ntx20, vacation FROM `".$prefix."users` WHERE id = :uid",
            [':uid'=>$buyerId]);
        if (!$buyer) return ['error'=>'Usuario comprador no encontrado.'];
        if (!empty($buyer['vacation'])) return ['error'=>'No puedes comprar en modo vacaciones.'];

        $available = MarketHelper::getAvailableBalance($buyerId);
        if ($available < $price) {
            return ['error'=>'No tienes suficiente NTX-20. Necesitas '
                .number_format($price,0,',','.').' y tienes '
                .number_format($available,0,',','.').'.'];
        }

        if (self::countPlanets($buyerId) >= self::MAX_PLANETS_PER_USER) {
            return ['error'=>'Ya tienes el máximo de planetas permitido ('.self::MAX_PLANETS_PER_USER.').'];
        }

        // 4) LOCK optimista: marcar como 'sold' SOLO si sigue 'active'
        $rows = Database::get()->update(
            "UPDATE `".$prefix."blackmarket_listings`
             SET status = 'sold', sold_at = :now, buyer_id = :b
             WHERE id = :id AND status = 'active'",
            [':now'=>TIMESTAMP, ':b'=>$buyerId, ':id'=>$listingId]);

        // Si 0 filas → otro comprador se adelantó
        if (!$rows || (int)$rows < 1) {
            return ['error'=>'Este listado ya fue comprado por otro jugador.'];
        }

        // 5) Cobrar y pagar (con fee)
        $feePct = MarketHelper::getSellerFeePct($sellerId, self::FEE_DURATION);
        $fee    = (int)ceil($price * $feePct / 100);
        $net    = $price - $fee;

        MarketHelper::subtractBalance($buyerId, $price);
        MarketHelper::addBalance($sellerId, $net);
        if ($fee > 0) MarketHelper::addToFund('seller', $fee);

        // 6) Transferir colonia (edificios/defensas/naves/recursos viajan solos)
        $moved = Database::get()->update(
            "UPDATE `".$prefix."planets` SET id_owner = :b
             WHERE id = :pid AND id_owner = :s",
            [':b'=>$buyerId, ':pid'=>$planetId, ':s'=>$sellerId]);

        // 7) Si el UPDATE planets falló (raro pero posible): revertir TODO
        if (!$moved || (int)$moved < 1) {
            MarketHelper::addBalance($buyerId, $price);
            MarketHelper::subtractBalance($sellerId, $net);
            if ($fee > 0) MarketHelper::addToFund('seller', -$fee);
            Database::get()->update(
                "UPDATE `".$prefix."blackmarket_listings`
                 SET status='active', sold_at=NULL, buyer_id=NULL
                 WHERE id = :id",
                [':id'=>$listingId]);
            return ['error'=>'Error al transferir la colonia. Se te devolvió el NTX.'];
        }

        // 8) Auditoría
        MarketHelper::logNtx20(
            $buyerId, -$price, 'market_buy',
            'Colonia: '.$l['planet_name'].' ['.$l['galaxy'].':'.$l['system'].':'.$l['planet'].']',
            $listingId);
        MarketHelper::logNtx20(
            $sellerId, +$net, 'market_sell',
            'Colonia: '.$l['planet_name'].' - fee '.$feePct.'%',
            $listingId);
        if ($fee > 0) {
            MarketHelper::logNtx20(
                $sellerId, -$fee, 'market_fee',
                'Comisión colonia: '.$l['planet_name'].' ('.$feePct.'%)',
                $listingId);
        }

        // 9) Log mercado
        Database::get()->insert(
            "INSERT INTO `".$prefix."market_log` SET
                offer_id=:o, buyer_id=:b, seller_id=:s, offer_type='sell',
                item_type='colony', item_id=:pid, item_name=:n,
                amount=1, price_ntx=:p,
                fee_seller=:fs, fee_buyer=0,
                fee_seller_pct=:fsp, fee_buyer_pct=0,
                seller_was_vip=:sv, buyer_was_vip=:bv,
                time=:ti",
            [
                ':o'  => $listingId,
                ':b'  => $buyerId,
                ':s'  => $sellerId,
                ':pid'=> $planetId,
                ':n'  => $l['planet_name'].' ['.$l['galaxy'].':'.$l['system'].':'.$l['planet'].']',
                ':p'  => $price,
                ':fs' => $fee,
                ':fsp'=> $feePct,
                ':sv' => (int)$l['seller_vip'],
                ':bv' => MarketHelper::isVip($buyerId) ? 1 : 0,
                ':ti' => TIMESTAMP,
            ]);

        // 10) Actualizar contadores
        Database::get()->update(
            "UPDATE `".$prefix."users_market` SET total_bought = total_bought + 1 WHERE user_id = :u",
            [':u'=>$buyerId]);
        Database::get()->update(
            "UPDATE `".$prefix."users_market` SET total_sold = total_sold + 1 WHERE user_id = :u",
            [':u'=>$sellerId]);

        // 11) Actualizar sesión global
        if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $buyerId) {
            $GLOBALS['USER']['ntx20'] = max(0, (int)$GLOBALS['USER']['ntx20'] - $price);
        }

        return [
            'success'   => true,
            'planet_name' => $l['planet_name'],
            'coords'    => '['.$l['galaxy'].':'.$l['system'].':'.$l['planet'].']',
            'paid'      => $price,
            'fee'       => $fee,
            'fee_pct'   => $feePct,
            'net'       => $net,
        ];
    }

    /* ============================================================
     * CONSULTAS
     * ============================================================ */
    public static function getActiveListings($excludeSellerId = 0)
    {
        $prefix  = self::prefix();
        $since   = TIMESTAMP - (self::LISTING_TTL_DAYS * 86400);
        $sql = "SELECT l.*, u.username AS seller_name
                FROM `".$prefix."blackmarket_listings` l
                LEFT JOIN `".$prefix."users` u ON u.id = l.seller_id
                WHERE l.status = 'active' AND l.created >= :since";
        $params = [':since'=>$since];

        if ((int)$excludeSellerId > 0) {
            $sql .= " AND l.seller_id <> :ex";
            $params[':ex'] = (int)$excludeSellerId;
        }
        $sql .= " ORDER BY l.created DESC LIMIT 100";

        $rows = Database::get()->select($sql, $params);
        return is_array($rows) ? $rows : [];
    }

    public static function getMyListings($userId)
    {
        $prefix = self::prefix();
        $rows = Database::get()->select(
            "SELECT * FROM `".$prefix."blackmarket_listings`
             WHERE seller_id = :uid AND status = 'active'
             ORDER BY created DESC",
            [':uid'=>(int)$userId]);
        return is_array($rows) ? $rows : [];
    }

    public static function getSellablePlanets($userId)
    {
        $prefix = self::prefix();
        $rows = Database::get()->select(
            "SELECT id, name, galaxy, system, planet, planet_type
             FROM `".$prefix."planets`
             WHERE id_owner = :uid AND planet_type = 1
             ORDER BY id ASC",
            [':uid'=>(int)$userId]);
        if (!is_array($rows)) return [];

        $mainId = !empty($rows) ? (int)$rows[0]['id'] : 0;
        $out = [];
        foreach ($rows as $r) {
            if ((int)$r['id'] === $mainId) continue;
            $r['coords'] = '['.$r['galaxy'].':'.$r['system'].':'.$r['planet'].']';
            $out[] = $r;
        }
        return $out;
    }

    /**
     * Preview del contenido de una colonia (para el comprador).
     * Devuelve datos básicos: recursos, naves y defensas totales.
     */
    public static function getPlanetPreview($planetId)
    {
        global $resource, $reslist;
        $prefix = self::prefix();

        $p = Database::get()->selectSingle(
            "SELECT * FROM `".$prefix."planets` WHERE id = :pid",
            [':pid'=>(int)$planetId]);
        if (!$p) return null;

        $shipsCount = 0;
        $defsCount  = 0;
        $shipList   = [];
        $defList    = [];

        if (isset($reslist['fleet']) && is_array($reslist['fleet'])) {
            foreach ($reslist['fleet'] as $id) {
                $col = isset($resource[$id]) ? $resource[$id] : null;
                if ($col && isset($p[$col]) && (int)$p[$col] > 0) {
                    $shipsCount += (int)$p[$col];
                    $shipList[] = ['id'=>$id, 'qty'=>(int)$p[$col]];
                }
            }
        }
        if (isset($reslist['defense']) && is_array($reslist['defense'])) {
            foreach ($reslist['defense'] as $id) {
                $col = isset($resource[$id]) ? $resource[$id] : null;
                if ($col && isset($p[$col]) && (int)$p[$col] > 0) {
                    $defsCount += (int)$p[$col];
                    $defList[] = ['id'=>$id, 'qty'=>(int)$p[$col]];
                }
            }
        }

        return [
            'metal'       => (float)$p['metal'],
            'crystal'     => (float)$p['crystal'],
            'deuterium'   => (float)$p['deuterium'],
            'ships_count' => $shipsCount,
            'defs_count'  => $defsCount,
            'ships'       => $shipList,
            'defenses'    => $defList,
            'fields'      => (int)$p['field_current'] ?? 0,
            'fields_max'  => (int)$p['field_max'] ?? 0,
        ];
    }
}