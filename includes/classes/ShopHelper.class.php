<?php
/**
 * AstroIO — ShopHelper v1.9
 * Gestor del Sistema de Tienda con Doble Riel (CUP / QvaPay)
 * Archivo: includes/classes/ShopHelper.class.php
 *
 * Características:
 *  - Ofertas fijas (no expiran, sin stock)
 *  - Descuento VIP del 25% aplicado al precio base
 *  - 11 tipos de producto: recurso, nave, defensa, misil, cofre_common,
 *    cofre_rare, cofre_legendary, cofre_climate_minor, cofre_climate_major,
 *    cofre_climate_dominion, booster
 *  - Plantillas guardables (snapshot completo)
 *  - Auto-snapshot para rollback del último cambio
 *  - El admin crea/edita/borra ofertas desde el panel
 *  - Ofertas temporales con auto-eliminación al expirar
 *
 * v1.1 (fix):
 *  - Corregidos los DELETE que usaban update() (prohibido en el fork)
 *  - Ahora usan query() con inyección directa para WHERE id = X
 *
 * v1.2 (fix):
 *  - Los catálogos (naves/defensas/misiles) ahora usan $LNG['tech'][$id]
 *    para mostrar nombres traducidos al español.
 *
 * v1.3 (nuevo):
 *  - Soporte de ofertas temporales (7, 15, 29 días)
 *  - Auto-limpieza al instante de ofertas expiradas (Opción C)
 *
 * v1.4 (texto):
 *  - Cambiado "Booster" por "Potenciador" en getTypeLabel()
 *
 * v1.5 (ASTROIO-FIX):
 *  - $GLOBALS['USER']['ntx20'] ahora usa max(0, ...) para nunca quedar negativo
 *
 * v1.6 (nuevo — 3 cofres del Mercado):
 *  - Soporte para 3 tipos de cofre: cofre_common, cofre_rare, cofre_legendary
 *  - giveChest() ahora escribe en uni1_users_market
 *
 * v1.7 (ASTROIO-FIX):
 *  - Nuevo hook NTX20LogHelper::log() al comprar cualquier oferta.
 *
 * v1.8 (NUEVO — DOBLE RIEL):
 *  - getPlayerMethod() detecta si es CUP o QVAPAY
 *  - getCurrencyLabel() devuelve 'NTX-20' o 'UNTX-20'
 *  - getBalance() lee de la columna correcta según el método
 *  - getFinalPrice() aplica x2 al precio si es internacional (UNTX-20)
 *  - buy() descuenta de la columna correcta (ntx20 o untx20)
 *  - Los mensajes de error muestran la moneda correcta
 *
 * v1.9 (BUFF CLIMÁTICO - TIENDA):
 *  - Añadidos 3 tipos de cofre: cofre_climate_minor, cofre_climate_major,
 *    cofre_climate_dominion.
 *  - giveChest() mapea a las columnas box_climate_minor/major/dominion.
 *  - getTypeLabel(), getTypeIcon() y getItemName() actualizados.
 */

class ShopHelper
{
    // ============================================================
    // CONSTANTES
    // ============================================================
    const VIP_DISCOUNT = 0.25; // 25% descuento para VIP
    const UNTX_MULTIPLIER = 2; // 🆕 UNTX-20 cuesta el doble que NTX-20

    /**
     * Duraciones disponibles (días) para ofertas temporales
     * 0 = permanente (sin expiración)
     */
    public static function getDuraciones(): array
    {
        return array(
            0  => 'Sin tiempo límite',
            7  => '7 días',
            15 => '15 días',
            29 => '29 días',
        );
    }

    // ============================================================
    // PREFIJO DE TABLAS
    // ============================================================
    private static function prefix(): string
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    // ============================================================
    // 🆕 DOBLE RIEL — MÉTODOS AUXILIARES
    // ============================================================

    /**
     * Devuelve el método de pago del jugador ('CUP' o 'QVAPAY')
     */
    public static function getPlayerMethod($userId): string
    {
        global $db;
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT metodo_retiro FROM `".$prefix."users` WHERE id = :uid LIMIT 1;",
            [':uid' => (int)$userId]
        );
        return ($row && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
    }

    /**
     * Devuelve el label de la moneda según el método
     */
    public static function getCurrencyLabel($method): string
    {
        return ($method === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';
    }

    /**
     * Devuelve la columna de la BD según el método
     */
    public static function getCurrencyColumn($method): string
    {
        return ($method === 'QVAPAY') ? 'untx20' : 'ntx20';
    }

    // ============================================================
    // MAPA DE NAVES (class 200)
    // ============================================================
    public static function getShipColumnMap(): array
    {
        return array(
            202 => 'small_ship_cargo',
            203 => 'big_ship_cargo',
            204 => 'light_hunter',
            205 => 'heavy_hunter',
            206 => 'crusher',
            207 => 'battle_ship',
            208 => 'colonizer',
            209 => 'recycler',
            210 => 'spy_sonde',
            211 => 'bomber_ship',
            212 => 'solar_satelit',
            213 => 'destructor',
            214 => 'dearth_star',
            215 => 'battleship',
            216 => 'lune_noir',
            217 => 'ev_transporter',
            218 => 'star_crasher',
            219 => 'giga_recykler',
            220 => 'dm_ship',
            221 => 'star_titan',
            222 => 'war_colossus',
            223 => 'elite_battleship',
            224 => 'heavy_frigate',
        );
    }

    // ============================================================
    // MAPA DE DEFENSAS (class 400)
    // ============================================================
    public static function getDefenseColumnMap(): array
    {
        return array(
            401 => 'misil_launcher',
            402 => 'small_laser',
            403 => 'big_laser',
            404 => 'gauss_canyon',
            405 => 'ionic_canyon',
            406 => 'buster_canyon',
            407 => 'small_protection_shield',
            408 => 'big_protection_shield',
            409 => 'planet_protector',
            410 => 'graviton_canyon',
            411 => 'orbital_station',
            412 => 'rail_turret',
            413 => 'antimatter_canyon',
            414 => 'star_bastion',
            415 => 'deflector_shield',
        );
    }

    // ============================================================
    // MAPA DE MISILES (class 500)
    // ============================================================
    public static function getMissileColumnMap(): array
    {
        return array(
            502 => 'interceptor_misil',
            503 => 'interplanetary_misil',
            504 => 'antimatter_misil',
            505 => 'advanced_interceptor_misil',
        );
    }

    // ============================================================
    // HELPER INTERNO: Traduce un catálogo con $LNG['tech']
    // ============================================================
    private static function translateCatalog(array $rows): array
    {
        global $LNG;

        if (!is_array($rows)) return array();

        foreach ($rows as &$row)
        {
            $id = (int)$row['id'];

            if (isset($LNG['tech'][$id]) && !empty($LNG['tech'][$id])) {
                $row['name_original'] = $row['name'];
                $row['name']          = $LNG['tech'][$id];
            } else {
                $row['name_original'] = $row['name'];
            }
        }
        unset($row);

        return $rows;
    }

    // ============================================================
    // AUTO-LIMPIEZA DE OFERTAS EXPIRADAS (Opción C: borrado al instante)
    // ============================================================
    public static function deleteExpiredOffers(): int
    {
        global $db;
        $prefix = self::prefix();

        $countRow = $db->selectSingle(
            "SELECT COUNT(*) AS total FROM `".$prefix."shop_items`
             WHERE expira = 1 AND expira_en > 0 AND expira_en <= :now;",
            [':now' => TIMESTAMP]
        );

        $total = $countRow ? (int)$countRow['total'] : 0;

        if ($total > 0) {
            $db->query(
                "DELETE FROM `".$prefix."shop_items`
                 WHERE expira = 1 AND expira_en > 0 AND expira_en <= ".TIMESTAMP.";"
            );
        }

        return $total;
    }

    // ============================================================
    // LISTAS DINÁMICAS PARA EL DESPLEGABLE DEL ADMIN
    // ============================================================

    public static function getShipsCatalog(): array
    {
        global $db;
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT elementID AS id, name, cost901 AS metal, cost902 AS crystal, cost903 AS deuterium
             FROM `".$prefix."vars` WHERE class = 200 ORDER BY elementID ASC;"
        );
        return self::translateCatalog($rows);
    }

    public static function getDefensesCatalog(): array
    {
        global $db;
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT elementID AS id, name, cost901 AS metal, cost902 AS crystal, cost903 AS deuterium
             FROM `".$prefix."vars` WHERE class = 400 ORDER BY elementID ASC;"
        );
        return self::translateCatalog($rows);
    }

    public static function getMissilesCatalog(): array
    {
        global $db;
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT elementID AS id, name, cost901 AS metal, cost902 AS crystal, cost903 AS deuterium
             FROM `".$prefix."vars` WHERE class = 500 ORDER BY elementID ASC;"
        );
        return self::translateCatalog($rows);
    }

    public static function getBoostersCatalog(): array
    {
        global $db;
        $prefix = self::prefix();
        return $db->select(
            "SELECT booster_id AS id, booster_name AS name, booster_desc AS description,
                    booster_icon AS icon, booster_value AS value, booster_duration AS duration
             FROM `".$prefix."boosters` ORDER BY booster_id ASC;"
        );
    }

    // ============================================================
    // OFERTAS (CRUD)
    // ============================================================

    public static function getOffers(): array
    {
        global $db;
        $prefix = self::prefix();

        self::deleteExpiredOffers();

        $rows = $db->select(
            "SELECT * FROM `".$prefix."shop_items`
             WHERE activo = 1
               AND (expira = 0 OR expira_en = 0 OR expira_en > :now)
             ORDER BY popular DESC, orden ASC, id ASC;",
            [':now' => TIMESTAMP]
        );
        return is_array($rows) ? $rows : array();
    }

    public static function getAllOffers(): array
    {
        global $db;
        $prefix = self::prefix();

        self::deleteExpiredOffers();

        $rows = $db->select(
            "SELECT * FROM `".$prefix."shop_items`
             ORDER BY activo DESC, popular DESC, orden ASC, id ASC;"
        );
        return is_array($rows) ? $rows : array();
    }

    public static function hasOffers(): bool
    {
        return count(self::getOffers()) > 0;
    }

    public static function getOffer($id): ?array
    {
        global $db;
        $prefix = self::prefix();
        $id = (int)$id;

        $row = $db->selectSingle(
            "SELECT * FROM `".$prefix."shop_items` WHERE id = :id;",
            [':id' => $id]
        );

        if (!$row) return null;

        if ((int)$row['expira'] === 1
            && (int)$row['expira_en'] > 0
            && (int)$row['expira_en'] <= TIMESTAMP) {
            $db->query("DELETE FROM `".$prefix."shop_items` WHERE id = ".$id.";");
            return null;
        }

        return $row;
    }

    public static function createOffer(array $data): bool
    {
        global $db;
        $prefix = self::prefix();

        $duracion = (int)($data['duracion'] ?? 0);
        if (!in_array($duracion, [0, 7, 15, 29], true)) {
            $duracion = 0;
        }

        $expira        = ($duracion > 0) ? 1 : 0;
        $expiraEn      = ($duracion > 0) ? (TIMESTAMP + ($duracion * 86400)) : 0;
        $duracionDias  = $duracion;

        $db->insert(
            "INSERT INTO `".$prefix."shop_items`
             (nombre, descripcion, tipo, item_id, cantidad, precio_ntx, icono,
              popular, activo, expira, expira_en, duracion_dias, orden,
              fecha_creacion, fecha_actualizacion)
             VALUES (:nombre, :desc, :tipo, :iid, :cant, :precio, :icono,
                     :pop, :act, :exp, :exp_en, :dur, :orden,
                     :fc, :fa);",
            array(
                ':nombre'  => (string)$data['nombre'],
                ':desc'    => (string)($data['descripcion'] ?? ''),
                ':tipo'    => (string)$data['tipo'],
                ':iid'     => (int)($data['item_id'] ?? 0),
                ':cant'    => (int)($data['cantidad'] ?? 1),
                ':precio'  => (int)($data['precio_ntx'] ?? 0),
                ':icono'   => (string)($data['icono'] ?? ''),
                ':pop'     => (int)($data['popular'] ?? 0),
                ':act'     => (int)($data['activo'] ?? 1),
                ':exp'     => $expira,
                ':exp_en'  => $expiraEn,
                ':dur'     => $duracionDias,
                ':orden'   => (int)($data['orden'] ?? 0),
                ':fc'      => TIMESTAMP,
                ':fa'      => TIMESTAMP,
            )
        );
        return true;
    }

    public static function updateOffer($id, array $data): bool
    {
        global $db;
        $prefix = self::prefix();

        $id = (int)$id;

        $actual = $db->selectSingle(
            "SELECT duracion_dias, expira_en FROM `".$prefix."shop_items` WHERE id = :id;",
            [':id' => $id]
        );

        $duracionNueva = (int)($data['duracion'] ?? 0);
        if (!in_array($duracionNueva, [0, 7, 15, 29], true)) {
            $duracionNueva = 0;
        }

        $duracionVieja = $actual ? (int)$actual['duracion_dias'] : 0;
        $expiraEnViejo = $actual ? (int)$actual['expira_en']      : 0;

        if ($duracionNueva === 0) {
            $expira       = 0;
            $expiraEn     = 0;
            $duracionDias = 0;
        } elseif ($duracionNueva !== $duracionVieja || $expiraEnViejo === 0) {
            $expira       = 1;
            $expiraEn     = TIMESTAMP + ($duracionNueva * 86400);
            $duracionDias = $duracionNueva;
        } else {
            $expira       = 1;
            $expiraEn     = $expiraEnViejo;
            $duracionDias = $duracionNueva;
        }

        $db->update(
            "UPDATE `".$prefix."shop_items` SET
                nombre = :nombre,
                descripcion = :desc,
                tipo = :tipo,
                item_id = :iid,
                cantidad = :cant,
                precio_ntx = :precio,
                icono = :icono,
                popular = :pop,
                activo = :act,
                expira = :exp,
                expira_en = :exp_en,
                duracion_dias = :dur,
                orden = :orden,
                fecha_actualizacion = :fa
             WHERE id = :id;",
            array(
                ':nombre'  => (string)$data['nombre'],
                ':desc'    => (string)($data['descripcion'] ?? ''),
                ':tipo'    => (string)$data['tipo'],
                ':iid'     => (int)($data['item_id'] ?? 0),
                ':cant'    => (int)($data['cantidad'] ?? 1),
                ':precio'  => (int)($data['precio_ntx'] ?? 0),
                ':icono'   => (string)($data['icono'] ?? ''),
                ':pop'     => (int)($data['popular'] ?? 0),
                ':act'     => (int)($data['activo'] ?? 1),
                ':exp'     => $expira,
                ':exp_en'  => $expiraEn,
                ':dur'     => $duracionDias,
                ':orden'   => (int)($data['orden'] ?? 0),
                ':fa'      => TIMESTAMP,
                ':id'      => $id,
            )
        );
        return true;
    }

    public static function deleteOffer($id): bool
    {
        global $db;
        $prefix = self::prefix();
        $id = (int)$id;
        $db->query("DELETE FROM `".$prefix."shop_items` WHERE id = ".$id.";");
        return true;
    }

    public static function toggleOffer($id): bool
    {
        global $db;
        $prefix = self::prefix();
        $db->update(
            "UPDATE `".$prefix."shop_items` SET activo = 1 - activo, fecha_actualizacion = :fa WHERE id = :id;",
            [':fa' => TIMESTAMP, ':id' => (int)$id]
        );
        return true;
    }

    // ============================================================
    // VIP
    // ============================================================

    public static function isVip($userId): bool
    {
        if (!class_exists('VIPHelper')) {
            $file = ROOT_PATH . 'includes/classes/VIPHelper.class.php';
            if (file_exists($file)) require_once $file;
        }
        if (class_exists('VIPHelper')) {
            return VIPHelper::isVIP((int)$userId);
        }
        return false;
    }

    /**
     * 🆕 v1.8 — Calcula el precio final con doble riel.
     *
     * Regla:
     *   1. Aplica descuento VIP (25%) al precio base.
     *   2. Si es QVAPAY, multiplica por 2 (UNTX-20 cuesta el doble).
     */
    public static function getFinalPrice($precioBase, $isVip, $method = 'CUP'): int
    {
        $precioBase = (int)$precioBase;
        $precio = $precioBase;

        // 1. Aplicar descuento VIP
        if ($isVip) {
            $precio = (int) round($precio * (1 - self::VIP_DISCOUNT));
        }

        // 2. Si es internacional, el doble
        if ($method === 'QVAPAY') {
            $precio = $precio * self::UNTX_MULTIPLIER;
        }

        return $precio;
    }

    // ============================================================
    // SALDO DEL JUGADOR (doble riel)
    // ============================================================

    /**
     * 🆕 v1.8 — Devuelve el saldo del jugador según su método de pago.
     * Lee de la columna correcta (`ntx20` o `untx20`).
     */
    public static function getBalance($userId): int
    {
        global $db;
        $prefix = self::prefix();

        $row = $db->selectSingle(
            "SELECT metodo_retiro, ntx20, untx20 FROM `".$prefix."users` WHERE id = :id;",
            [':id' => (int)$userId]
        );

        if (!$row) return 0;

        if ($row['metodo_retiro'] === 'QVAPAY') {
            return isset($row['untx20']) ? (int)$row['untx20'] : 0;
        }

        return (int)$row['ntx20'];
    }

    // ============================================================
    // COMPRAR
    // ============================================================

    public static function buy($userId, $itemId): array
    {
        global $db, $PLANET, $USER;
        $prefix = self::prefix();
        $userId = (int)$userId;
        $itemId = (int)$itemId;

        // 1) Verificar la oferta
        $item = self::getOffer($itemId);
        if (!$item || (int)$item['activo'] !== 1) {
            return array('ok' => false, 'msg' => 'La oferta no existe, expiró o fue desactivada.');
        }

        // 2) Doble check de expiración
        if ((int)$item['expira'] === 1
            && (int)$item['expira_en'] > 0
            && (int)$item['expira_en'] <= TIMESTAMP) {
            $db->query("DELETE FROM `".$prefix."shop_items` WHERE id = ".$itemId.";");
            return array('ok' => false, 'msg' => 'Esta oferta temporal ya expiró.');
        }

        // 3) 🆕 Detectar método de pago
        $method  = self::getPlayerMethod($userId);
        $moneda  = self::getCurrencyLabel($method);
        $columna = self::getCurrencyColumn($method);

        // 4) Calcular precio final (con VIP y multiplicador x2 si es internacional)
        $isVip      = self::isVip($userId);
        $precioBase = (int)$item['precio_ntx'];
        $precioFin  = self::getFinalPrice($precioBase, $isVip, $method);

        // 5) Verificar saldo (lectura de la columna correcta)
        $saldo = self::getBalance($userId);
        if ($saldo < $precioFin) {
            return array(
                'ok'  => false,
                'msg' => 'No tienes suficiente ' . $moneda . '. Necesitas ' . $precioFin . ' y tienes ' . $saldo . '.'
            );
        }

        // 6) Descontar de la columna correcta
        $db->update(
            "UPDATE `".$prefix."users` SET `".$columna."` = `".$columna."` - :p
             WHERE id = :id AND `".$columna."` >= :p;",
            [':p' => $precioFin, ':id' => $userId]
        );

        // 7) Actualizar $GLOBALS['USER'] para reflejar el cambio
        if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $userId) {
            if ($columna === 'untx20') {
                $GLOBALS['USER']['untx20'] = max(0, (int)($GLOBALS['USER']['untx20'] ?? 0) - $precioFin);
            } else {
                $GLOBALS['USER']['ntx20'] = max(0, (int)($GLOBALS['USER']['ntx20'] ?? 0) - $precioFin);
            }
        }

        // 8) Registrar en auditoría (solo si es NTX-20, para no romper el Helper)
        if ($columna === 'ntx20') {
            if (!class_exists('NTX20LogHelper')) {
                $ntxLogFile = ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php';
                if (file_exists($ntxLogFile)) {
                    require_once $ntxLogFile;
                }
            }
            if (class_exists('NTX20LogHelper')) {
                try {
                    $cantidad = max(1, (int)$item['cantidad']);
                    $descLog  = (string)$item['nombre'];
                    if ($cantidad > 1) {
                        $descLog .= ' (x' . $cantidad . ')';
                    }
                    if ($isVip) {
                        $descLog .= ' [VIP -25%]';
                    }
                    NTX20LogHelper::log(
                        $userId,
                        -$precioFin,
                        'shop_purchase',
                        $descLog,
                        $itemId
                    );
                } catch (Exception $e) {
                    // silencioso
                }
            }
        }

        // 9) Dar recompensa según tipo
        $cantidad = max(1, (int)$item['cantidad']);
        $tipo     = (string)$item['tipo'];

        switch ($tipo) {
            case 'recurso':
                self::giveResources($userId, (int)$item['item_id'], $cantidad);
                break;
            case 'nave':
                self::giveShip($userId, (int)$item['item_id'], $cantidad);
                break;
            case 'defensa':
                self::giveDefense($userId, (int)$item['item_id'], $cantidad);
                break;
            case 'misil':
                self::giveMissile($userId, (int)$item['item_id'], $cantidad);
                break;

            case 'cofre_common':
                self::giveChest($userId, $cantidad, 'cofre_common');
                break;
            case 'cofre_rare':
                self::giveChest($userId, $cantidad, 'cofre_rare');
                break;
            case 'cofre_legendary':
                self::giveChest($userId, $cantidad, 'cofre_legendary');
                break;

            // 🆕 v1.9 — Cofres Climáticos
            case 'cofre_climate_minor':
                self::giveChest($userId, $cantidad, 'cofre_climate_minor');
                break;
            case 'cofre_climate_major':
                self::giveChest($userId, $cantidad, 'cofre_climate_major');
                break;
            case 'cofre_climate_dominion':
                self::giveChest($userId, $cantidad, 'cofre_climate_dominion');
                break;

            case 'cofre':
                self::giveChest($userId, $cantidad, 'cofre_common');
                break;

            case 'booster':
                self::giveBooster($userId, (int)$item['item_id']);
                break;
        }

        // 10) Registrar en historial
        $db->insert(
            "INSERT INTO `".$prefix."shop_purchases`
             (user_id, item_id, item_nombre, item_tipo, item_cantidad, precio_base, precio_final, vip_aplicado, fecha)
             VALUES (:uid, :iid, :inom, :itip, :icant, :pb, :pf, :vip, :f);",
            array(
                ':uid'   => $userId,
                ':iid'   => $itemId,
                ':inom'  => (string)$item['nombre'],
                ':itip'  => $tipo,
                ':icant' => $cantidad,
                ':pb'    => $precioBase,
                ':pf'    => $precioFin,
                ':vip'   => $isVip ? 1 : 0,
                ':f'     => TIMESTAMP,
            )
        );

        return array(
            'ok'      => true,
            'msg'     => '¡Compra realizada correctamente! Pagaste ' . $precioFin . ' ' . $moneda . '.',
            'moneda'  => $moneda,
            'pagado'  => $precioFin
        );
    }

    // ============================================================
    // ENTREGA DE RECOMPENSAS
    // ============================================================

    private static function giveResources($userId, $recursoId, $cantidad)
    {
        global $db, $PLANET;
        $prefix = self::prefix();

        $planetId = self::getPlayerPlanetId($userId);
        if (!$planetId) return;

        $col = '';
        if ($recursoId === 1) $col = 'metal';
        elseif ($recursoId === 2) $col = 'crystal';
        elseif ($recursoId === 3) $col = 'deuterium';

        if ($col === '') {
            $part = (int)floor($cantidad / 3);
            $db->update(
                "UPDATE `".$prefix."planets`
                 SET metal = metal + :m, crystal = crystal + :c, deuterium = deuterium + :d
                 WHERE id = :pid;",
                [':m' => $part, ':c' => $part, ':d' => $part, ':pid' => $planetId]
            );
            return;
        }

        $db->update(
            "UPDATE `".$prefix."planets` SET `".$col."` = `".$col."` + :val WHERE id = :pid;",
            [':val' => $cantidad, ':pid' => $planetId]
        );
    }

    private static function giveShip($userId, $shipId, $cantidad)
    {
        $map = self::getShipColumnMap();
        if (!isset($map[$shipId])) return;
        self::addToPlanet($userId, $map[$shipId], $cantidad);
    }

    private static function giveDefense($userId, $defId, $cantidad)
    {
        $map = self::getDefenseColumnMap();
        if (!isset($map[$defId])) return;
        self::addToPlanet($userId, $map[$defId], $cantidad);
    }

    private static function giveMissile($userId, $misId, $cantidad)
    {
        $map = self::getMissileColumnMap();
        if (!isset($map[$misId])) return;
        self::addToPlanet($userId, $map[$misId], $cantidad);
    }

    private static function addToPlanet($userId, $column, $cantidad)
    {
        global $db, $PLANET;
        $prefix = self::prefix();

        $planetId = self::getPlayerPlanetId($userId);
        if (!$planetId) return;

        $db->update(
            "UPDATE `".$prefix."planets` SET `".$column."` = `".$column."` + :val WHERE id = :pid;",
            [':val' => (int)$cantidad, ':pid' => $planetId]
        );
    }

    private static function giveChest($userId, $cantidad, $tipo = 'cofre_common')
    {
        global $db;
        $prefix  = self::prefix();
        $userId  = (int)$userId;
        $cantidad = max(1, (int)$cantidad);

        $columnMap = array(
            'cofre_common'             => 'box_common',
            'cofre_rare'               => 'box_rare',
            'cofre_legendary'          => 'box_legendary',
            // 🆕 v1.9 — Cofres Climáticos
            'cofre_climate_minor'      => 'box_climate_minor',
            'cofre_climate_major'      => 'box_climate_major',
            'cofre_climate_dominion'   => 'box_climate_dominion',
        );

        if (isset($columnMap[$tipo])) {
            $col = $columnMap[$tipo];

            $row = $db->selectSingle(
                "SELECT user_id FROM `".$prefix."users_market` WHERE user_id = :u;",
                [':u' => $userId]
            );
            if (!$row) {
                $db->insert(
                    "INSERT INTO `".$prefix."users_market`
                     SET user_id = :u, balance_frozen = 0,
                         offers_today = 0, last_reset = :t;",
                    [':u' => $userId, ':t' => TIMESTAMP]
                );
            }

            $db->update(
                "UPDATE `".$prefix."users_market`
                 SET `".$col."` = `".$col."` + :c
                 WHERE user_id = :uid;",
                [':c' => $cantidad, ':uid' => $userId]
            );

            return;
        }

        $db->update(
            "UPDATE `".$prefix."users` SET containers = containers + :c WHERE id = :uid;",
            [':c' => $cantidad, ':uid' => $userId]
        );

        if (isset($GLOBALS['USER']['containers'])) {
            $GLOBALS['USER']['containers'] += $cantidad;
        }
    }

    private static function giveBooster($userId, $boosterId)
    {
        global $db;
        $prefix = self::prefix();
        $userId = (int)$userId;
        $boosterId = (int)$boosterId;

        if ($boosterId <= 0) return;

        $booster = $db->selectSingle(
            "SELECT * FROM `".$prefix."boosters` WHERE booster_id = :bid;",
            [':bid' => $boosterId]
        );
        if (!$booster) return;

        $duration  = (int)$booster['booster_duration'];
        $expiresAt = TIMESTAMP + $duration;

        $existing = $db->selectSingle(
            "SELECT id FROM `".$prefix."users_boosters`
             WHERE user_id = :uid AND booster_id = :bid;",
            [':uid' => $userId, ':bid' => $boosterId]
        );

        if ($existing) {
            $db->update(
                "UPDATE `".$prefix."users_boosters`
                 SET expires_at = :exp, applied_at = :app
                 WHERE id = :id;",
                [':exp' => $expiresAt, ':app' => TIMESTAMP, ':id' => (int)$existing['id']]
            );
        } else {
            $db->insert(
                "INSERT INTO `".$prefix."users_boosters`
                 (user_id, booster_id, expires_at, applied_at)
                 VALUES (:uid, :bid, :exp, :app);",
                [':uid' => $userId, ':bid' => $boosterId,
                 ':exp' => $expiresAt, ':app' => TIMESTAMP]
            );
        }
    }

    private static function getPlayerPlanetId($userId)
    {
        global $db;
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT id_planet FROM `".$prefix."users` WHERE id = :uid;",
            [':uid' => (int)$userId]
        );
        return $row && !empty($row['id_planet']) ? (int)$row['id_planet'] : 0;
    }

    // ============================================================
    // HISTORIAL DE COMPRAS
    // ============================================================

    public static function getHistoryByUser($userId, $limit = 20): array
    {
        global $db;
        $prefix = self::prefix();
        $limit  = max(1, (int)$limit);
        $rows = $db->select(
            "SELECT * FROM `".$prefix."shop_purchases`
             WHERE user_id = :uid
             ORDER BY fecha DESC
             LIMIT ".$limit.";",
            [':uid' => (int)$userId]
        );
        return is_array($rows) ? $rows : array();
    }

    public static function getAllHistory($limit = 100): array
    {
        global $db;
        $prefix = self::prefix();
        $limit  = max(1, (int)$limit);
        $rows = $db->select(
            "SELECT p.*, u.username
             FROM `".$prefix."shop_purchases` p
             LEFT JOIN `".$prefix."users` u ON u.id = p.user_id
             ORDER BY p.fecha DESC
             LIMIT ".$limit.";"
        );
        return is_array($rows) ? $rows : array();
    }

    // ============================================================
    // PLANTILLAS
    // ============================================================

    public static function saveTemplate($nombre, $descripcion, $userId): bool
    {
        global $db;
        $prefix = self::prefix();

        $offers = self::getAllOffers();
        $snapshot = json_encode($offers, JSON_UNESCAPED_UNICODE);

        $db->insert(
            "INSERT INTO `".$prefix."shop_templates`
             (nombre, descripcion, snapshot, creado_por, fecha_creacion, fecha_actualizacion)
             VALUES (:nom, :desc, :snap, :uid, :fc, :fa);",
            array(
                ':nom'  => (string)$nombre,
                ':desc' => (string)$descripcion,
                ':snap' => $snapshot,
                ':uid'  => (int)$userId,
                ':fc'   => TIMESTAMP,
                ':fa'   => TIMESTAMP,
            )
        );
        return true;
    }

    public static function getTemplates(): array
    {
        global $db;
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT id, nombre, descripcion, creado_por, fecha_creacion, fecha_actualizacion,
                    LENGTH(snapshot) AS snapshot_size
             FROM `".$prefix."shop_templates`
             ORDER BY fecha_creacion DESC;"
        );
        return is_array($rows) ? $rows : array();
    }

    public static function getTemplate($id): ?array
    {
        global $db;
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT * FROM `".$prefix."shop_templates` WHERE id = :id;",
            [':id' => (int)$id]
        );
        return $row ?: null;
    }

    public static function loadTemplate($id): bool
    {
        global $db;
        $prefix = self::prefix();

        $tpl = self::getTemplate($id);
        if (!$tpl) return false;

        $offers = json_decode($tpl['snapshot'], true);
        if (!is_array($offers)) return false;

        self::createAutosave('Antes de cargar plantilla: '.$tpl['nombre'], 0);

        $db->query("DELETE FROM `".$prefix."shop_items`;");

        foreach ($offers as $o) {
            self::createOffer(array(
                'nombre'      => $o['nombre'],
                'descripcion' => $o['descripcion'],
                'tipo'        => $o['tipo'],
                'item_id'     => $o['item_id'],
                'cantidad'    => $o['cantidad'],
                'precio_ntx'  => $o['precio_ntx'],
                'icono'       => $o['icono'],
                'popular'     => $o['popular'],
                'activo'      => $o['activo'],
                'orden'       => $o['orden'],
                'duracion'    => isset($o['duracion_dias']) ? (int)$o['duracion_dias'] : 0,
            ));
        }

        $db->update(
            "UPDATE `".$prefix."shop_templates` SET fecha_actualizacion = :fa WHERE id = :id;",
            [':fa' => TIMESTAMP, ':id' => (int)$id]
        );

        return true;
    }

    public static function renameTemplate($id, $nombre, $descripcion): bool
    {
        global $db;
        $prefix = self::prefix();
        $db->update(
            "UPDATE `".$prefix."shop_templates`
             SET nombre = :nom, descripcion = :desc, fecha_actualizacion = :fa
             WHERE id = :id;",
            [':nom' => (string)$nombre, ':desc' => (string)$descripcion,
             ':fa' => TIMESTAMP, ':id' => (int)$id]
        );
        return true;
    }

    public static function deleteTemplate($id): bool
    {
        global $db;
        $prefix = self::prefix();
        $id = (int)$id;
        $db->query("DELETE FROM `".$prefix."shop_templates` WHERE id = ".$id.";");
        return true;
    }

    // ============================================================
    // AUTO-SNAPSHOT (ROLLBACK)
    // ============================================================

    public static function createAutosave($accion, $userId): bool
    {
        global $db;
        $prefix = self::prefix();

        $offers = self::getAllOffers();
        $snapshot = json_encode($offers, JSON_UNESCAPED_UNICODE);

        $db->insert(
            "INSERT INTO `".$prefix."shop_autosave`
             (snapshot, accion, creado_por, fecha)
             VALUES (:snap, :acc, :uid, :f);",
            array(
                ':snap' => $snapshot,
                ':acc'  => (string)$accion,
                ':uid'  => (int)$userId,
                ':f'    => TIMESTAMP,
            )
        );

        $db->query(
            "DELETE FROM `".$prefix."shop_autosave`
             WHERE id NOT IN (
                SELECT id FROM (
                    SELECT id FROM `".$prefix."shop_autosave` ORDER BY fecha DESC LIMIT 10
                ) AS t
             );"
        );

        return true;
    }

    public static function getLastAutosave(): ?array
    {
        global $db;
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT * FROM `".$prefix."shop_autosave` ORDER BY fecha DESC LIMIT 1;"
        );
        return $row ?: null;
    }

    public static function restoreLastAutosave(): bool
    {
        global $db;
        $prefix = self::prefix();

        $auto = self::getLastAutosave();
        if (!$auto) return false;

        $offers = json_decode($auto['snapshot'], true);
        if (!is_array($offers)) return false;

        $db->query("DELETE FROM `".$prefix."shop_items`;");

        foreach ($offers as $o) {
            self::createOffer(array(
                'nombre'      => $o['nombre'],
                'descripcion' => $o['descripcion'],
                'tipo'        => $o['tipo'],
                'item_id'     => $o['item_id'],
                'cantidad'    => $o['cantidad'],
                'precio_ntx'  => $o['precio_ntx'],
                'icono'       => $o['icono'],
                'popular'     => $o['popular'],
                'activo'      => $o['activo'],
                'orden'       => $o['orden'],
                'duracion'    => isset($o['duracion_dias']) ? (int)$o['duracion_dias'] : 0,
            ));
        }

        $autoId = (int)$auto['id'];
        $db->query("DELETE FROM `".$prefix."shop_autosave` WHERE id = ".$autoId.";");

        return true;
    }

    // ============================================================
    // HELPERS DE PRESENTACIÓN
    // ============================================================

    public static function getTypeLabel($tipo): string
    {
        $map = array(
            'recurso'                  => 'Recursos',
            'nave'                     => 'Nave',
            'defensa'                  => 'Defensa',
            'misil'                    => 'Misil',
            'cofre_common'             => 'Cofre Común',
            'cofre_rare'               => 'Cofre Raro',
            'cofre_legendary'          => 'Cofre Legendario',
            // 🆕 v1.9 — Cofres Climáticos
            'cofre_climate_minor'      => 'Cofre Climático Menor',
            'cofre_climate_major'      => 'Cofre Climático Mayor',
            'cofre_climate_dominion'   => 'Cofre Climático Legendario',
            'cofre'                    => 'Cofre',
            'booster'                  => 'Potenciador',
        );
        return isset($map[$tipo]) ? $map[$tipo] : 'Item';
    }

    public static function getTypeIcon($tipo): string
    {
        $map = array(
            'recurso'                  => '💰',
            'nave'                     => '🚀',
            'defensa'                  => '🛡️',
            'misil'                    => '🎯',
            'cofre_common'             => '📦',
            'cofre_rare'               => '💎',
            'cofre_legendary'          => '👑',
            // 🆕 v1.9 — Cofres Climáticos
            'cofre_climate_minor'      => '🌤️',
            'cofre_climate_major'      => '🌈',
            'cofre_climate_dominion'   => '⚡',
            'cofre'                    => '📦',
            'booster'                  => '⚡',
        );
        return isset($map[$tipo]) ? $map[$tipo] : '📦';
    }

    public static function getItemName($tipo, $itemId, $fallback = '')
    {
        global $db, $LNG;
        $prefix = self::prefix();

        if ($tipo === 'recurso') {
            $map = array(1 => 'Metal', 2 => 'Cristal', 3 => 'Deuterio', 0 => 'Metal + Cristal + Deuterio');
            return $map[(int)$itemId] ?? 'Recursos';
        }

        if ($tipo === 'cofre_common' || $tipo === 'cofre_rare' || $tipo === 'cofre_legendary') {
            $map = array(
                'cofre_common'    => 'Cofre Común',
                'cofre_rare'      => 'Cofre Raro',
                'cofre_legendary' => 'Cofre Legendario',
            );
            return $map[$tipo];
        }

        // 🆕 v1.9 — Cofres Climáticos
        if ($tipo === 'cofre_climate_minor' || $tipo === 'cofre_climate_major' || $tipo === 'cofre_climate_dominion') {
            $map = array(
                'cofre_climate_minor'    => 'Cofre Climático Menor',
                'cofre_climate_major'    => 'Cofre Climático Mayor',
                'cofre_climate_dominion' => 'Cofre Climático Legendario',
            );
            return $map[$tipo];
        }

        if ($tipo === 'cofre') {
            return 'Cofre';
        }

        if ($tipo === 'booster') {
            $row = $db->selectSingle(
                "SELECT booster_name FROM `".$prefix."boosters` WHERE booster_id = :id;",
                [':id' => (int)$itemId]
            );
            return $row ? $row['booster_name'] : $fallback;
        }

        $itemIdInt = (int)$itemId;
        if (isset($LNG['tech'][$itemIdInt]) && !empty($LNG['tech'][$itemIdInt])) {
            return $LNG['tech'][$itemIdInt];
        }

        $row = $db->selectSingle(
            "SELECT name FROM `".$prefix."vars` WHERE elementID = :id;",
            [':id' => $itemIdInt]
        );
        return $row ? $row['name'] : $fallback;
    }
}