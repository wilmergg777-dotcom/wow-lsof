<?php
/**
 * AstroIO - ImprovementHelper v1.7
 * Sistema de Mejoras para Naves y Defensas
 * Archivo: includes/classes/ImprovementHelper.class.php
 */

class ImprovementHelper
{
    private static function prefix(): string
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    // ============================================
    // UTILIDADES DE ICONOS Y ESPECIFICACIONES
    // ============================================

    public static function getStatIcon($stat): string
    {
        $icons = [
            'ataque'    => '⚔️',
            'defensa'   => '🛡️',
            'escudo'    => '🔵',
            'motriz'    => '💨',
            'logistica' => '📦',
            'cadencia'  => '🔄',
            'precision' => '🎯'
        ];
        return isset($icons[$stat]) ? $icons[$stat] : '📦';
    }

    public static function getStatName($stat): string
    {
        $names = [
            'ataque'    => 'Ataque',
            'defensa'   => 'Defensa',
            'escudo'    => 'Escudo',
            'motriz'    => 'Motriz',
            'logistica' => 'Logistica',
            'cadencia'  => 'Cadencia',
            'precision' => 'Precision'
        ];
        return isset($names[$stat]) ? $names[$stat] : $stat;
    }

    private static function getBonusPercentage($level): int
    {
        $tiers = [
            1 => 3, 2 => 6, 3 => 10, 4 => 15, 5 => 20,
            6 => 25, 7 => 30, 8 => 35, 9 => 40, 10 => 45,
            11 => 50, 12 => 55, 13 => 60, 14 => 65, 15 => 70
        ];
        return $tiers[(int)$level] ?? 0;
    }

    /**
     * Calcula el precio dinámico según el nivel (1-15).
     * Máximo absoluto: 30,000 MO.
     */
    private static function getCalculatedPrice($level, $type = 'simple'): int
    {
        $prices = [
            1 => 1000,   2 => 1250,   3 => 1600,   4 => 2050,   5 => 2650,
            6 => 3350,   7 => 4300,   8 => 5450,   9 => 7000,   10 => 8900,
            11 => 11300, 12 => 14400, 13 => 18400, 14 => 23400, 15 => 30000
        ];
        return isset($prices[(int)$level]) ? $prices[(int)$level] : 0;
    }

    /**
     * Genera el texto de especificaciones de un item
     */
    public static function getSpec($item): string
    {
        if (!$item) return '';
        $pct = self::getBonusPercentage((int)$item['level']);
        $stat1 = isset($item['stat1']) ? $item['stat1'] : '';
        $stat2 = isset($item['stat2']) ? $item['stat2'] : '';

        $out = '';
        if (!empty($stat1)) {
            $out .= self::getStatIcon($stat1) . ' +' . $pct . '% ' . self::getStatName($stat1);
        }
        if (!empty($stat2)) {
            if (!empty($out)) $out .= ' / ';
            $out .= self::getStatIcon($stat2) . ' +' . $pct . '% ' . self::getStatName($stat2);
        }
        return $out;
    }

    /**
     * Añade icon y spec a cada fila del resultado
     */
    private static function enrich(array $rows): array
    {
        foreach ($rows as &$row) {
            if (isset($row['stat1']) && !empty($row['stat1'])) {
                $row['icon_display'] = self::getStatIcon($row['stat1']);
            } else {
                $row['icon_display'] = '📦';
            }
            $row['spec'] = self::getSpec($row);

            // Sobrescribimos el precio con el valor calculado
            if (isset($row['level'])) {
                $type = isset($row['type']) ? $row['type'] : 'simple';
                $row['price'] = self::getCalculatedPrice((int)$row['level'], $type);
            }
        }
        return $rows;
    }

    // ============================================
    // TEMPORADAS
    // ============================================

    public static function getActiveSeasons(): array
    {
        global $db;
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT `season_number` FROM `".$prefix."improvements_seasons`
             WHERE `active` = 1 ORDER BY `season_number` ASC"
        );
        $seasons = [];
        foreach ($rows as $row) {
            $seasons[] = (int)$row['season_number'];
        }
        return $seasons;
    }

    public static function isSeasonActive($season): bool
    {
        $active = self::getActiveSeasons();
        return in_array((int)$season, $active);
    }

    public static function getAllSeasons(): array
    {
        global $db;
        $prefix = self::prefix();
        return $db->select(
            "SELECT * FROM `".$prefix."improvements_seasons`
             ORDER BY `season_number` ASC"
        );
    }

    public static function getSeasonInfo($season): ?array
    {
        global $db;
        $prefix = self::prefix();
        return $db->selectSingle(
            "SELECT * FROM `".$prefix."improvements_seasons`
             WHERE `season_number` = :num",
            [':num' => (int)$season]
        );
    }

    public static function setSeasonActive($season, $active, $mode = 'manual', $dateStart = 0, $dateEnd = 0): bool
    {
        global $db;
        $prefix = self::prefix();

        $exists = self::getSeasonInfo($season);
        if (!$exists) return false;

        $db->update(
            "UPDATE `".$prefix."improvements_seasons`
             SET `active` = :act, `mode` = :mode,
                 `date_start` = :ds, `date_end` = :de,
                 `updated_at` = :now
             WHERE `season_number` = :num",
            [
                ':act'  => (int)$active ? 1 : 0,
                ':mode' => $mode,
                ':ds'   => (int)$dateStart,
                ':de'   => (int)$dateEnd,
                ':now'  => time(),
                ':num'  => (int)$season
            ]
        );
        return true;
    }

    public static function processAutoSeasons(): void
    {
        global $db;
        $prefix = self::prefix();
        $now = time();

        $rows = $db->select(
            "SELECT * FROM `".$prefix."improvements_seasons`
             WHERE `mode` = 'auto'"
        );

        foreach ($rows as $row) {
            $season = (int)$row['season_number'];
            $start  = (int)$row['date_start'];
            $end    = (int)$row['date_end'];

            $shouldBeActive = 0;
            if ($start > 0 && $end > 0 && $now >= $start && $now <= $end) {
                $shouldBeActive = 1;
            }

            if ((int)$row['active'] !== $shouldBeActive) {
                $db->update(
                    "UPDATE `".$prefix."improvements_seasons`
                     SET `active` = :act, `updated_at` = :now
                     WHERE `season_number` = :num",
                    [
                        ':act' => $shouldBeActive,
                        ':now' => $now,
                        ':num' => $season
                    ]
                );
            }
        }
    }

    // ============================================
    // CATALOGO
    // ============================================

    public static function getCatalog($category = 'todas', $type = 'todas'): array
    {
        global $db;
        $prefix = self::prefix();

        $activeSeasons = self::getActiveSeasons();
        if (empty($activeSeasons)) {
            return [];
        }

        $placeholders = [];
        $params = [];
        foreach ($activeSeasons as $i => $s) {
            $key = ':s' . $i;
            $placeholders[] = $key;
            $params[$key] = $s;
        }

        $extra = '';
        if ($type !== 'todas') {
            $extra .= " AND `type` = :type";
            $params[':type'] = $type;
        }

        $catQuery = "";
        if ($category !== 'todas') {
            $catQuery = " AND `category` = :cat";
            $params[':cat'] = $category;
        }

        $rows = $db->select(
            "SELECT * FROM `".$prefix."improvements_catalog`
             WHERE `season` IN (".implode(',', $placeholders).")".$catQuery.$extra."
             ORDER BY `season`, `category`, `chain_id`, `level`",
            $params
        );

        $rows = self::enrich($rows);

        $catalog = [];
        foreach ($rows as $row) {
            $catalog[$row['id']] = $row;
        }
        return $catalog;
    }

    public static function getItem($itemId): ?array
    {
        global $db;
        $prefix = self::prefix();
        $item = $db->selectSingle(
            "SELECT * FROM `".$prefix."improvements_catalog` WHERE `id` = :id",
            [':id' => (int)$itemId]
        );

        // Sobrescribimos el precio con el valor calculado
        if ($item) {
            $item['price'] = self::getCalculatedPrice((int)$item['level'], $item['type']);
        }

        return $item;
    }

    // ============================================
    // INVENTARIO
    // ============================================

    public static function getInventory($userId): array
    {
        global $db;
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT i.*, c.chain_name, c.icon, c.level, c.category, c.type, c.price, c.stat1, c.stat2
             FROM `".$prefix."users_improvements_inv` i
             JOIN `".$prefix."improvements_catalog` c ON i.item_id = c.id
             WHERE i.user_id = :uid
             ORDER BY c.chain_id, c.level",
            [':uid' => (int)$userId]
        );
        return self::enrich($rows);
    }

    public static function countInventorySlots($userId): int
    {
        global $db;
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT COUNT(*) as total FROM `".$prefix."users_improvements_inv` WHERE `user_id` = :uid",
            [':uid' => (int)$userId]
        );
        return $row ? (int)$row['total'] : 0;
    }

    // ============================================
    // EQUIPADAS
    // ============================================

    public static function getEquipped($userId, $unitId): array
    {
        global $db;
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT e.*, c.chain_name, c.icon, c.stat1, c.stat2, c.type
             FROM `".$prefix."users_improvements_eq` e
             JOIN `".$prefix."improvements_catalog` c ON e.item_id = c.id
             WHERE e.user_id = :uid AND e.unit_id = :unit
             ORDER BY e.slot ASC",
            [':uid' => (int)$userId, ':unit' => (int)$unitId]
        );
        $rows = self::enrich($rows);

        $eq = [1 => null, 2 => null, 3 => null, 4 => null];
        foreach ($rows as $row) {
            $eq[(int)$row['slot']] = $row;
        }
        return $eq;
    }

    public static function canEquip($userId, $unitId, $newItemId, $slot): bool
    {
        $newItem = self::getItem($newItemId);
        if (!$newItem) return false;

        $newLevel = (int)$newItem['level'];
        $equipped = self::getEquipped($userId, $unitId);
        $currentInSlot = $equipped[$slot];

        if ($newLevel > 1) {
            // Regla estricta: Debe actualizar el item existente en ESTA misma ranura
            if (!$currentInSlot || (int)$currentInSlot['level'] !== $newLevel - 1) {
                return false;
            }
        } else {
            // Si es nivel 1, la ranura debe estar vacía
            if ($currentInSlot) {
                return false;
            }
        }

        // Verificar regla de progresión escalonada (máx 1 nivel de diferencia entre ranuras)
        $levels = [];
        foreach ($equipped as $s => $item) {
            if ($item && $s != $slot) { // Excluir el item de esta ranura porque lo vamos a reemplazar
                $levels[] = (int)$item['level'];
            }
        }
        $levels[] = $newLevel;

        if (!empty($levels)) {
            $min = min($levels);
            $max = max($levels);
            if (($max - $min) > 1) return false;
        }

        return true;
    }

    public static function equip($userId, $unitId, $slot, $itemId): bool
    {
        global $db;
        $prefix = self::prefix();

        if (!self::canEquip($userId, $unitId, $itemId, $slot)) return false;

        $item = self::getItem($itemId);
        if (!$item) return false;
        $level = (int)$item['level'];

        // 1. Eliminar el item actual en esta ranura (destruye el nivel inferior)
        $db->delete(
            "DELETE FROM `".$prefix."users_improvements_eq`
             WHERE `user_id` = :uid AND `unit_id` = :unit AND `slot` = :slot",
            [':uid' => (int)$userId, ':unit' => (int)$unitId, ':slot' => (int)$slot]
        );

        // 2. Insertar el nuevo item equipado
        $db->insert(
            "INSERT INTO `".$prefix."users_improvements_eq`
             (`user_id`, `unit_id`, `slot`, `item_id`, `level`)
             VALUES (:uid, :unit, :slot, :item, :lvl)",
            [
                ':uid'   => (int)$userId,
                ':unit'  => (int)$unitId,
                ':slot'  => (int)$slot,
                ':item'  => (int)$itemId,
                ':lvl'   => $level
            ]
        );

        // 3. Descontar del inventario
        $db->update(
            "UPDATE `".$prefix."users_improvements_inv` SET `quantity` = `quantity` - 1
             WHERE `user_id` = :uid AND `item_id` = :item",
            [':uid' => (int)$userId, ':item' => (int)$itemId]
        );

        $db->delete(
            "DELETE FROM `".$prefix."users_improvements_inv`
             WHERE `user_id` = :uid AND `item_id` = :item AND `quantity` <= 0",
            [':uid' => (int)$userId, ':item' => (int)$itemId]
        );

        self::log($userId, 'equipar', "Equipo item $itemId en unidad $unitId slot $slot");
        return true;
    }

    public static function unequip($userId, $unitId, $slot): bool
    {
        global $db;
        $prefix = self::prefix();

        $equipped = self::getEquipped($userId, $unitId);
        if (!$equipped[$slot]) return false;

        $itemId = (int)$equipped[$slot]['item_id'];

        // VALIDACION: Maximo 5 unidades en inventario
        $checkInv = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_improvements_inv`
             WHERE `user_id` = :uid AND `item_id` = :item",
            [':uid' => (int)$userId, ':item' => $itemId]
        );

        if ($checkInv && (int)$checkInv['quantity'] >= 5) {
            return false;
        }

        // Eliminar de equipadas
        $db->delete(
            "DELETE FROM `".$prefix."users_improvements_eq`
             WHERE `user_id` = :uid AND `unit_id` = :unit AND `slot` = :slot",
            [':uid' => (int)$userId, ':unit' => (int)$unitId, ':slot' => (int)$slot]
        );

        // Añadir al inventario (marcada como penalizada)
        if ($checkInv) {
            $db->update(
                "UPDATE `".$prefix."users_improvements_inv`
                 SET `quantity` = `quantity` + 1, `is_penalized` = 1
                 WHERE `id` = :id",
                [':id' => (int)$checkInv['id']]
            );
        } else {
            $db->insert(
                "INSERT INTO `".$prefix."users_improvements_inv`
                 (`user_id`, `item_id`, `quantity`, `is_penalized`, `fecha_obtencion`)
                 VALUES (:uid, :item, 1, 1, :time)",
                [
                    ':uid'  => (int)$userId,
                    ':item' => $itemId,
                    ':time' => time()
                ]
            );
        }

        self::log($userId, 'desequipar', "Desequipo item $itemId de unidad $unitId slot $slot");
        return true;
    }

    // ============================================
    // BONOS
    // ============================================

    public static function getBonuses($userId, $unitId): array
    {
        $equipped = self::getEquipped($userId, $unitId);
        $bonuses = [
            'ataque'    => 1.0,
            'defensa'   => 1.0,
            'escudo'    => 1.0,
            'motriz'    => 1.0,
            'logistica' => 1.0,
            'cadencia'  => 1.0,
            'precision' => 1.0
        ];

        foreach ($equipped as $item) {
            if (!$item) continue;
            $mult = 1 + (self::getBonusPercentage((int)$item['level']) / 100);

            if (!empty($item['stat1']) && isset($bonuses[$item['stat1']])) {
                $bonuses[$item['stat1']] *= $mult;
            }
            if (!empty($item['stat2']) && isset($bonuses[$item['stat2']])) {
                $bonuses[$item['stat2']] *= $mult;
            }
        }
        return $bonuses;
    }

    // ============================================
    // COMPRAR
    // ============================================

    public static function buy($userId, $itemId): array
    {
        global $db;
        $prefix = self::prefix();

        $user = $db->selectSingle(
            "SELECT `improvements_compras_hoy`, `improvements_ultima_compra`, `darkmatter`
             FROM `".$prefix."users` WHERE `id` = :uid",
            [':uid' => (int)$userId]
        );

        if (!$user) return ['error' => 'Usuario no encontrado'];

        $hoy = date('Y-m-d');
        $ultima = ($user['improvements_ultima_compra'] > 0) ? date('Y-m-d', $user['improvements_ultima_compra']) : '';

        if ($hoy != $ultima) {
            $db->update(
                "UPDATE `".$prefix."users` SET `improvements_compras_hoy` = 0, `improvements_ultima_compra` = :time
                 WHERE `id` = :uid",
                [':time' => time(), ':uid' => (int)$userId]
            );
            $user['improvements_compras_hoy'] = 0;
        }

        if ((int)$user['improvements_compras_hoy'] >= 7) {
            return ['error' => 'Limite diario alcanzado (7 compras)'];
        }

        $item = self::getItem($itemId);
        if (!$item) return ['error' => 'Item no existe'];

        // VALIDAR TEMPORADA ACTIVA
        if (!self::isSeasonActive($item['season'])) {
            return ['error' => 'Esta mejora no esta disponible en este momento (temporada inactiva)'];
        }

        if ((int)$user['darkmatter'] < (int)$item['price']) {
            return ['error' => 'Materia Oscura insuficiente'];
        }

        $slots = self::countInventorySlots($userId);
        $yaTiene = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_improvements_inv`
             WHERE `user_id` = :uid AND `item_id` = :item",
            [':uid' => (int)$userId, ':item' => (int)$itemId]
        );

        if (!$yaTiene && $slots >= 30) {
            return ['error' => 'Inventario lleno (30 espacios)'];
        }

        // VALIDACION: Verificar maximo 5 unidades ANTES de descontar MO
        if ($yaTiene && (int)$yaTiene['quantity'] >= 5) {
            return ['error' => 'Ya tienes 5 unidades de este item'];
        }

        // 🆕 Descontar MO en base de datos con verificación estricta
        $afectadas = $db->update(
            "UPDATE `".$prefix."users` SET `darkmatter` = `darkmatter` - :price WHERE `id` = :uid AND `darkmatter` >= :price",
            [':price' => (int)$item['price'], ':uid' => (int)$userId]
        );

        if ($afectadas === 0) {
            return ['error' => 'Error crítico: No se pudo descontar la Materia Oscura (posible saldo insuficiente o error de base de datos).'];
        }

        if (isset($GLOBALS['USER']['darkmatter'])) {
            $GLOBALS['USER']['darkmatter'] -= (int)$item['price'];
            if ($GLOBALS['USER']['darkmatter'] < 0) $GLOBALS['USER']['darkmatter'] = 0;
        }

        if ($yaTiene) {
            $db->update(
                "UPDATE `".$prefix."users_improvements_inv` SET `quantity` = `quantity` + 1
                 WHERE `id` = :id",
                [':id' => (int)$yaTiene['id']]
            );
        } else {
            $db->insert(
                "INSERT INTO `".$prefix."users_improvements_inv`
                 (`user_id`, `item_id`, `quantity`, `is_penalized`, `fecha_obtencion`)
                 VALUES (:uid, :item, 1, 0, :time)",
                [
                    ':uid'  => (int)$userId,
                    ':item' => (int)$itemId,
                    ':time' => time()
                ]
            );
        }

        $db->update(
            "UPDATE `".$prefix."users` SET `improvements_compras_hoy` = `improvements_compras_hoy` + 1
             WHERE `id` = :uid",
            [':uid' => (int)$userId]
        );

        self::log($userId, 'comprar', "Compro item $itemId por ".$item['price']." MO");
        return ['success' => true];
    }

    // ============================================
    // VENDER
    // ============================================

    public static function sell($userId, $itemId, $quantity = 1): array
    {
        global $db;
        $prefix = self::prefix();
        $quantity = max(1, (int)$quantity);

        $item = self::getItem($itemId);
        if (!$item) return ['error' => 'Item no existe'];

        $inv = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_improvements_inv`
             WHERE `user_id` = :uid AND `item_id` = :item",
            [':uid' => (int)$userId, ':item' => (int)$itemId]
        );

        if (!$inv || (int)$inv['quantity'] < $quantity) {
            return ['error' => 'No tienes suficientes unidades'];
        }

        $porcentaje = $inv['is_penalized'] ? 0.20 : 0.40;
        $precioVenta = floor($item['price'] * $porcentaje) * $quantity;

        $db->update(
            "UPDATE `".$prefix."users_improvements_inv` SET `quantity` = `quantity` - :qty
             WHERE `id` = :id",
            [':qty' => $quantity, ':id' => (int)$inv['id']]
        );

        $db->delete(
            "DELETE FROM `".$prefix."users_improvements_inv`
             WHERE `id` = :id AND `quantity` <= 0",
            [':id' => (int)$inv['id']]
        );

        // 🆕 Sumar MO en base de datos y actualizar variable global
        $db->update(
            "UPDATE `".$prefix."users` SET `darkmatter` = `darkmatter` + :gan WHERE `id` = :uid",
            [':gan' => $precioVenta, ':uid' => (int)$userId]
        );

        if (isset($GLOBALS['USER']['darkmatter'])) {
            $GLOBALS['USER']['darkmatter'] += $precioVenta;
        }

        self::log($userId, 'vender', "Vendio $quantity x item $itemId por $precioVenta MO");
        return ['success' => true, 'ganancia' => $precioVenta];
    }

    // ============================================
    // FUSIONAR
    // ============================================

    public static function fuse($userId, $itemId): array
    {
        global $db;
        $prefix = self::prefix();

        $item = self::getItem($itemId);
        if (!$item) return ['error' => 'Item no existe'];
        if ((int)$item['level'] >= 7) return ['error' => 'Nivel maximo de fusion alcanzado (7)'];

        $inv = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_improvements_inv`
             WHERE `user_id` = :uid AND `item_id` = :item",
            [':uid' => (int)$userId, ':item' => (int)$itemId]
        );

        if (!$inv || (int)$inv['quantity'] < 3) {
            return ['error' => 'Necesitas 3 unidades para fusionar'];
        }

        $nextItem = $db->selectSingle(
            "SELECT * FROM `".$prefix."improvements_catalog`
             WHERE `chain_id` = :chain AND `level` = :lvl",
            [':chain' => (int)$item['chain_id'], ':lvl' => (int)$item['level'] + 1]
        );

        if (!$nextItem) return ['error' => 'No existe item superior'];

        $nextInv = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_improvements_inv`
             WHERE `user_id` = :uid AND `item_id` = :item",
            [':uid' => (int)$userId, ':item' => (int)$nextItem['id']]
        );

        // Validar limite antes de tocar el inventario
        if ($nextInv && (int)$nextInv['quantity'] >= 5) {
            return ['error' => 'Ya tienes 5 unidades del item superior'];
        }

        $db->update(
            "UPDATE `".$prefix."users_improvements_inv` SET `quantity` = `quantity` - 3
             WHERE `id` = :id",
            [':id' => (int)$inv['id']]
        );

        $db->delete(
            "DELETE FROM `".$prefix."users_improvements_inv`
             WHERE `id` = :id AND `quantity` <= 0",
            [':id' => (int)$inv['id']]
        );

        if ($nextInv) {
            $db->update(
                "UPDATE `".$prefix."users_improvements_inv` SET `quantity` = `quantity` + 1
                 WHERE `id` = :id",
                [':id' => (int)$nextInv['id']]
            );
        } else {
            $db->insert(
                "INSERT INTO `".$prefix."users_improvements_inv`
                 (`user_id`, `item_id`, `quantity`, `is_penalized`, `fecha_obtencion`)
                 VALUES (:uid, :item, 1, 0, :time)",
                [
                    ':uid'  => (int)$userId,
                    ':item' => (int)$nextItem['id'],
                    ':time' => time()
                ]
            );
        }

        self::log($userId, 'fusionar', "Fusiono 3 x item $itemId en item ".$nextItem['id']);
        return ['success' => true];
    }

    // ============================================
    // LOG
    // ============================================

    private static function log($userId, $accion, $detalle): void
    {
        global $db;
        $prefix = self::prefix();
        $ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
        $db->insert(
            "INSERT INTO `".$prefix."improvements_log`
             (`user_id`, `accion`, `detalle`, `ip`, `fecha`)
             VALUES (:uid, :acc, :det, :ip, :time)",
            [
                ':uid'  => (int)$userId,
                ':acc'  => $accion,
                ':det'  => $detalle,
                ':ip'   => $ip,
                ':time' => time()
            ]
        );
    }
}
?>