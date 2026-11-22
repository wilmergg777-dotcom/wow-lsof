<?php
/**
 * ============================================================
 * MarketTrendsHelper — Tendencias del Mercado AstroIO v2.1
 * ============================================================
 * Se encarga de:
 *   - Registrar ventas en las estadísticas diarias
 *   - Calcular top vendidos / top demandados
 *   - Devolver evolución de precios para el gráfico
 *   - Calcular tendencia (↑ ↓ =)
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

class MarketTrendsHelper
{
    const DAYS_DEFAULT = 7;
    const TOP_LIMIT    = 5;

    /* ============================================================
     * PREFIJO DE TABLAS
     * ============================================================ */
    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /* ============================================================
     * REGISTRAR UNA VENTA
     * Se llama desde MarketHelper::buyOffer() y fulfillBuyOrder().
     * ============================================================ */
    public static function recordSale($itemType, $itemId, $itemName,
                                       $amount, $price)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $today  = date('Y-m-d');
        $itemId = (int)$itemId;
        $amount = (int)$amount;
        $price  = (int)$price;

        if ($amount <= 0 || $price <= 0) return;

        // ¿Existe fila para hoy + ítem?
        $row = $db->selectSingle(
            "SELECT * FROM `".$prefix."market_stats`
             WHERE stat_date = :d
               AND item_type = :t
               AND item_id   = :i",
            [':d'=>$today, ':t'=>$itemType, ':i'=>$itemId]);

        if ($row) {
            // Calcular nuevo promedio ponderado
            $newSold   = (int)$row['total_sold'] + $amount;
            $newVolume = (int)$row['total_volume'] + ($price * $amount);
            $newAvg    = $newSold > 0 ? (int)($newVolume / $newSold) : 0;

            $db->update(
                "UPDATE `".$prefix."market_stats` SET
                    total_sold   = total_sold + :a,
                    total_volume = total_volume + :v,
                    avg_price    = :avg,
                    min_price    = LEAST(min_price, :p),
                    max_price    = GREATEST(max_price, :p)
                 WHERE stat_id = :id",
                [':a'=>$amount, ':v'=>$price*$amount,
                 ':avg'=>$newAvg, ':p'=>$price, ':id'=>$row['stat_id']]);
        } else {
            // Insertar primera fila del día
            // ✅ v3.9 — UPSERT atómico: la tabla tiene UNIQUE
            // (stat_date,item_type,item_id); antes check-then-insert y dos
            // compras concurrentes del mismo item el mismo día lanzaban
            // duplicate-key DESPUÉS de que el dinero ya se movió (la compra
            // se completaba pero el jugador veía pantalla de error).
            $db->insert(
                "INSERT INTO `".$prefix."market_stats` SET
                    stat_date    = :d,
                    item_type    = :t,
                    item_id      = :i,
                    item_name    = :n,
                    total_sold   = :a,
                    total_bought = 0,
                    avg_price    = :p,
                    min_price    = :p,
                    max_price    = :p,
                    total_volume = :v
                ON DUPLICATE KEY UPDATE
                    total_sold   = total_sold + :a,
                    total_volume = total_volume + :v,
                    avg_price    = FLOOR((avg_price * total_sold + :p2 * :a) / (total_sold + :a)),
                    min_price    = LEAST(min_price, :p),
                    max_price    = GREATEST(max_price, :p)",
                [':d'=>$today, ':t'=>$itemType, ':i'=>$itemId, ':n'=>$itemName,
                 ':a'=>$amount, ':p'=>$price, ':p2'=>$price, ':v'=>$price*$amount]);
        }
    }

    /* ============================================================
     * REGISTRAR UNA DEMANDA (buy order creada)
     * Opcional — se puede llamar desde createBuyOrder().
     * ============================================================ */
    public static function recordDemand($itemType, $itemId, $itemName, $amount)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $today  = date('Y-m-d');
        $itemId = (int)$itemId;
        $amount = (int)$amount;
        if ($amount <= 0) return;

        $row = $db->selectSingle(
            "SELECT * FROM `".$prefix."market_stats`
             WHERE stat_date = :d AND item_type = :t AND item_id = :i",
            [':d'=>$today, ':t'=>$itemType, ':i'=>$itemId]);

        if ($row) {
            $db->update(
                "UPDATE `".$prefix."market_stats`
                 SET total_bought = total_bought + :a
                 WHERE stat_id = :id",
                [':a'=>$amount, ':id'=>$row['stat_id']]);
        } else {
            $db->insert(
                "INSERT INTO `".$prefix."market_stats` SET
                    stat_date    = :d,
                    item_type    = :t,
                    item_id      = :i,
                    item_name    = :n,
                    total_sold   = 0,
                    total_bought = :a,
                    avg_price    = 0,
                    min_price    = 0,
                    max_price    = 0,
                    total_volume = 0",
                [':d'=>$today, ':t'=>$itemType, ':i'=>$itemId,
                 ':n'=>$itemName, ':a'=>$amount]);
        }
    }

    /* ============================================================
     * TOP MÁS VENDIDOS (últimos N días)
     * Devuelve array de items ordenados por unidades vendidas.
     * ============================================================ */
    public static function getTopSold($days = self::DAYS_DEFAULT,
                                       $limit = self::TOP_LIMIT)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $from   = date('Y-m-d', strtotime("-$days days"));
        $limit  = (int)$limit;

        $rows = $db->select(
            "SELECT item_type, item_id, item_name,
                    SUM(total_sold) AS total,
                    AVG(avg_price)  AS avg_p
             FROM `".$prefix."market_stats`
             WHERE stat_date >= :f
               AND total_sold > 0
             GROUP BY item_type, item_id, item_name
             ORDER BY total DESC
             LIMIT $limit",
            [':f' => $from]);

        return is_array($rows) ? $rows : [];
    }

    /* ============================================================
     * TOP MÁS DEMANDADOS (últimos N días)
     * Combina ventas + buy orders activas.
     * ============================================================ */
    public static function getTopDemanded($days = self::DAYS_DEFAULT,
                                           $limit = self::TOP_LIMIT)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $from   = date('Y-m-d', strtotime("-$days days"));
        $limit  = (int)$limit;

        // 1) Demanda histórica (ventas + buy orders creadas)
        $historic = $db->select(
            "SELECT item_type, item_id, item_name,
                    SUM(total_sold + total_bought) AS demand
             FROM `".$prefix."market_stats`
             WHERE stat_date >= :f
             GROUP BY item_type, item_id, item_name",
            [':f' => $from]);

        // 2) Buy orders activas (demanda actual)
        $active = $db->select(
            "SELECT item_type, item_id, item_name,
                    SUM(amount) AS demand
             FROM `".$prefix."market_offers`
             WHERE status = 'active'
               AND offer_type = 'buy'
               AND admin_offer = 0
               AND expires > :now
             GROUP BY item_type, item_id, item_name",
            [':now' => TIMESTAMP]);

        // 3) Combinar
        $map = [];
        if (is_array($historic)) {
            foreach ($historic as $h) {
                $key = $h['item_type'].'_'.(int)$h['item_id'];
                $map[$key] = [
                    'item_type' => $h['item_type'],
                    'item_id'   => (int)$h['item_id'],
                    'item_name' => $h['item_name'],
                    'demand'    => (int)$h['demand'],
                ];
            }
        }
        if (is_array($active)) {
            foreach ($active as $a) {
                $key = $a['item_type'].'_'.(int)$a['item_id'];
                if (isset($map[$key])) {
                    $map[$key]['demand'] += (int)$a['demand'];
                } else {
                    $map[$key] = [
                        'item_type' => $a['item_type'],
                        'item_id'   => (int)$a['item_id'],
                        'item_name' => $a['item_name'],
                        'demand'    => (int)$a['demand'],
                    ];
                }
            }
        }

        // 4) Ordenar por demanda desc y limitar
        if (empty($map)) return [];

        usort($map, function($x, $y) {
            return (int)$y['demand'] - (int)$x['demand'];
        });

        return array_slice(array_values($map), 0, $limit);
    }

    /* ============================================================
     * HISTORIAL DE PRECIOS DE UN ÍTEM (para el gráfico)
     * ============================================================ */
    public static function getPriceHistory($itemType, $itemId,
                                            $days = self::DAYS_DEFAULT)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $from   = date('Y-m-d', strtotime("-$days days"));

        $rows = $db->select(
            "SELECT stat_date, avg_price, min_price, max_price,
                    total_sold, total_volume
             FROM `".$prefix."market_stats`
             WHERE stat_date >= :f
               AND item_type = :t
               AND item_id   = :i
             ORDER BY stat_date ASC",
            [':f'=>$from, ':t'=>$itemType, ':i'=>(int)$itemId]);

        // Rellenar días sin datos con 0
        $byDate = [];
        if (is_array($rows)) {
            foreach ($rows as $r) {
                $byDate[$r['stat_date']] = $r;
            }
        }

        $out = [];
        for ($i = $days - 1; $i >= 0; $i--) {
            $d = date('Y-m-d', strtotime("-$i days"));
            $out[] = [
                'date'         => $d,
                'label'        => date('d/m', strtotime($d)),
                'avg_price'    => isset($byDate[$d]) ? (int)$byDate[$d]['avg_price']    : 0,
                'min_price'    => isset($byDate[$d]) ? (int)$byDate[$d]['min_price']    : 0,
                'max_price'    => isset($byDate[$d]) ? (int)$byDate[$d]['max_price']    : 0,
                'total_sold'   => isset($byDate[$d]) ? (int)$byDate[$d]['total_sold']   : 0,
                'total_volume' => isset($byDate[$d]) ? (int)$byDate[$d]['total_volume'] : 0,
            ];
        }
        return $out;
    }

    /* ============================================================
     * TENDENCIA (sube / baja / igual)
     * Compara el primero y el último valor con precio > 0.
     * ============================================================ */
    public static function getTrend($itemType, $itemId,
                                     $days = self::DAYS_DEFAULT)
    {
        $h = self::getPriceHistory($itemType, $itemId, $days);

        // Filtrar días con precio > 0
        $valid = array_values(array_filter($h, function($x) {
            return (int)$x['avg_price'] > 0;
        }));

        if (count($valid) < 2) {
            return [
                'dir'   => '=',
                'pct'   => 0.0,
                'icon'  => '=',
                'class' => 'flat',
            ];
        }

        $first = (int)$valid[0]['avg_price'];
        $last  = (int)$valid[count($valid) - 1]['avg_price'];

        if ($first <= 0) {
            return ['dir'=>'=','pct'=>0.0,'icon'=>'=','class'=>'flat'];
        }

        $pct = round((($last - $first) / $first) * 100, 1);

        if ($pct > 2) {
            return ['dir'=>'up',   'pct'=>$pct, 'icon'=>'↑', 'class'=>'up'];
        }
        if ($pct < -2) {
            return ['dir'=>'down', 'pct'=>$pct, 'icon'=>'↓', 'class'=>'down'];
        }
        return     ['dir'=>'=',    'pct'=>$pct, 'icon'=>'=', 'class'=>'flat'];
    }

    /* ============================================================
     * RESUMEN COMPACTO PARA EL WIDGET
     * ============================================================ */
    public static function getWidgetSummary()
    {
        $sold     = self::getTopSold(7, 1);
        $demanded = self::getTopDemanded(7, 1);

        $topSold     = (!empty($sold[0]))     ? $sold[0]     : null;
        $topDemanded = (!empty($demanded[0])) ? $demanded[0] : null;

        $out = [
            'top_sold'     => null,
            'top_demanded' => null,
        ];

        if ($topSold) {
            $trend = self::getTrend($topSold['item_type'],
                                    (int)$topSold['item_id'], 7);
            $out['top_sold'] = [
                'name'  => $topSold['item_name'],
                'total' => (int)$topSold['total'],
                'avg'   => (int)$topSold['avg_p'],
                'trend' => $trend,
            ];
        }

        if ($topDemanded) {
            $trend = self::getTrend($topDemanded['item_type'],
                                    (int)$topDemanded['item_id'], 7);
            $out['top_demanded'] = [
                'name'  => $topDemanded['item_name'],
                'total' => (int)$topDemanded['demand'],
                'trend' => $trend,
            ];
        }

        return $out;
    }

    /* ============================================================
     * LISTA DE ÍTEMS CON HISTORIAL (para el selector del gráfico)
     * ============================================================ */
    public static function getTrendableItems($days = 30)
    {
        $db     = Database::get();
        $prefix = self::prefix();
        $from   = date('Y-m-d', strtotime("-$days days"));

        $rows = $db->select(
            "SELECT DISTINCT item_type, item_id, item_name
             FROM `".$prefix."market_stats`
             WHERE stat_date >= :f
               AND total_sold > 0
             ORDER BY item_name ASC",
            [':f' => $from]);

        return is_array($rows) ? $rows : [];
    }

    /* ============================================================
     * DATOS PARA CHART.JS
     * ============================================================ */
    public static function getChartData($itemType, $itemId,
                                         $days = self::DAYS_DEFAULT)
    {
        $history = self::getPriceHistory($itemType, $itemId, $days);

        $labels = [];
        $prices = [];
        $mins   = [];
        $maxs   = [];

        foreach ($history as $h) {
            $labels[] = $h['label'];
            $prices[] = (int)$h['avg_price'];
            $mins[]   = (int)$h['min_price'];
            $maxs[]   = (int)$h['max_price'];
        }

        return [
            'labels' => $labels,
            'prices' => $prices,
            'mins'   => $mins,
            'maxs'   => $maxs,
        ];
    }

    /* ============================================================
     * CONSOLIDACIÓN DIARIA (opcional, para cron)
     * Reservado para futuras consolidaciones.
     * ============================================================ */
    public static function consolidateDay($date = null)
    {
        if (!$date) $date = date('Y-m-d', strtotime('-1 day'));
        return true;
    }
}