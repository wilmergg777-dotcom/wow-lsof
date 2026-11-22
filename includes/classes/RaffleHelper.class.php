<?php
/**
 * RaffleHelper.class.php
 * Sistema de Rifas - AstroIO v3.0 (DUAL RIEL)
 *
 * v3.0 (2026-10-30) - DUAL RIEL:
 *  - Detecta el riel del jugador (CUP / QVAPAY).
 *  - Si moneda === 'ntx20' y el jugador es QVAPAY:
 *      · Paga precio × 2 desde untx20
 *      · Recibe premio × 2 en untx20 (si gana)
 *  - Log NTX20LogHelper SOLO para CUP (no hay UNTXLogHelper).
 *  - getSaldoJugador() lee de la columna del riel.
 *  - getMonedaInfo() / getPremioTexto() aceptan $userId opcional
 *    para mostrar 'UNTX-20' cuando corresponde.
 *  - El resto de monedas (metal/crystal/deuterium/darkmatter)
 *    NO se ven afectadas: van al planeta o a users como siempre.
 *
 * ⚠️ IMPORTANTE PARA EL ADMIN:
 *  - Las rifas se configuran SIEMPRE en "valor base" (NTX-20 equivalente).
 *  - Si un QVAPAY gana, recibe premio × 2 en UNTX-20.
 *    Ej: premio "1000 NTX-20" → QVAPAY recibe 2000 UNTX-20.
 *  - Configurá los premios pensando en esta escala.
 */

if (!defined('MODE')) {
    exit;
}

class RaffleHelper
{
    // ═══════════════════════════════════════════════════════════
    // DUAL RIEL - Regla ×2 (único lugar)
    // ═══════════════════════════════════════════════════════════
    const UNTX_MULTIPLIER = 2;

    private static $methodCache = [];

    private static function prefix()
    {
        return 'uni1_';
    }

    private static function db()
    {
        return Database::get();
    }

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

    private static function logNtx20($userId, $amount, $type, $description = '', $refId = 0)
    {
        try {
            if (!self::loadNtxLogHelper()) return;
            NTX20LogHelper::log($userId, $amount, $type, $description, $refId);
        } catch (Exception $e) {
            // silencioso
        }
    }

    // ============================================================
    // DUAL RIEL — Métodos públicos
    // ============================================================

    /**
     * Devuelve 'QVAPAY' o 'CUP' según metodo_retiro del jugador.
     */
    public static function getPlayerMethod($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return 'CUP';

        if (isset(self::$methodCache[$userId])) {
            return self::$methodCache[$userId];
        }

        $prefix = self::prefix();
        try {
            $row = self::db()->selectSingle(
                "SELECT metodo_retiro FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
                [':uid' => $userId]
            );
            $method = ($row && isset($row['metodo_retiro']) && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
        } catch (Exception $e) {
            $method = 'CUP';
        }

        self::$methodCache[$userId] = $method;
        return $method;
    }

    public static function isIntl($userId)
    {
        return self::getPlayerMethod($userId) === 'QVAPAY';
    }

    public static function getCurrencyLabel($userId)
    {
        return self::isIntl($userId) ? 'UNTX-20' : 'NTX-20';
    }

    public static function getPhysicalColumn($userId)
    {
        return self::isIntl($userId) ? 'untx20' : 'ntx20';
    }

    /**
     * Devuelve array completo del riel del jugador.
     * Usado por el controlador para preparar variables del template.
     */
    public static function getRielInfo($userId)
    {
        $userId      = (int)$userId;
        $isIntl      = self::isIntl($userId);
        $colBalance  = $isIntl ? 'untx20' : 'ntx20';
        $moneda      = $isIntl ? 'UNTX-20' : 'NTX-20';
        $monedaFiat  = $isIntl ? 'USD' : 'CUP';
        $saldo       = 0;

        $prefix = self::prefix();
        try {
            $row = self::db()->selectSingle(
                "SELECT `".$colBalance."` AS saldo FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
                [':uid' => $userId]
            );
            $saldo = $row ? (int)$row['saldo'] : 0;
        } catch (Exception $e) {
            $saldo = 0;
        }

        return [
            'isIntl'     => $isIntl,
            'colBalance' => $colBalance,
            'moneda'     => $moneda,
            'monedaFiat' => $monedaFiat,
            'saldo'      => $saldo,
            'multiplier' => $isIntl ? self::UNTX_MULTIPLIER : 1,
        ];
    }

    /**
     * Convierte un precio base (NTX-20) al precio real del jugador.
     * Si el jugador es QVAPAY, aplica × UNTX_MULTIPLIER.
     */
    public static function getPrecioParaJugador($precioBase, $userId)
    {
        return self::isIntl($userId) ? ((int)$precioBase * self::UNTX_MULTIPLIER) : (int)$precioBase;
    }

    /**
     * Convierte una cantidad de premio base (NTX-20) a la cantidad real que recibe el jugador.
     * Si el jugador es QVAPAY, aplica × UNTX_MULTIPLIER.
     */
    public static function getPremioParaJugador($cantidadBase, $userId)
    {
        return self::isIntl($userId) ? ((int)$cantidadBase * self::UNTX_MULTIPLIER) : (int)$cantidadBase;
    }

    public static function clearMethodCache()
    {
        self::$methodCache = [];
    }

    // ============================================================
    // INFO DE MONEDA
    // ============================================================

    /**
     * Devuelve info de la moneda.
     * Para 'ntx20' acepta $userId opcional: si el jugador es QVAPAY,
     * devuelve nombre/icon de 'UNTX-20'.
     */
    public static function getMonedaInfo($moneda, $userId = null)
    {
        $map = [
            'metal'      => ['nombre' => 'Metal',          'icon' => 'M',  'color' => '#c8d6e5'],
            'crystal'    => ['nombre' => 'Cristal',        'icon' => 'C',  'color' => '#00ccff'],
            'deuterium'  => ['nombre' => 'Deuterio',       'icon' => 'D',  'color' => '#66ff99'],
            'darkmatter' => ['nombre' => 'Materia Oscura', 'icon' => 'MO', 'color' => '#aa44ff'],
            'ntx20'      => ['nombre' => 'NTX-20',         'icon' => 'N',  'color' => '#ffaa33'],
        ];

        if (!isset($map[$moneda])) {
            $moneda = 'ntx20';
        }

        // Override para QVAPAY
        if ($moneda === 'ntx20' && $userId !== null && self::isIntl($userId)) {
            $map['ntx20']['nombre'] = 'UNTX-20';
        }

        return $map[$moneda];
    }

    // ============================================================
    // UTILIDADES
    // ============================================================

    public static function formatTiempo($segundos)
    {
        if ($segundos <= 0) return 'SORTEANDO...';
        $d = floor($segundos / 86400);
        $h = floor(($segundos % 86400) / 3600);
        $m = floor(($segundos % 3600) / 60);
        $s = $segundos % 60;
        if ($d > 0) return $d . 'd ' . $h . 'h ' . $m . 'm';
        if ($h > 0) return $h . 'h ' . $m . 'm ' . $s . 's';
        if ($m > 0) return $m . 'm ' . $s . 's';
        return $s . 's';
    }

    public static function duracionASegundos($duracion)
    {
        switch ($duracion) {
            case '24h': return 24 * 3600;
            case '7d':  return 7 * 24 * 3600;
            case '15d': return 15 * 24 * 3600;
            default:    return 7 * 24 * 3600;
        }
    }

    public static function log($raffleId, $userId, $accion, $detalle = '', $ip = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $ip = $ip ? $ip : (isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null);

        $db->insert(
            "INSERT INTO `" . $prefix . "raffle_log` 
             (raffle_id, user_id, accion, detalle, ip, fecha) 
             VALUES (:rid, :uid, :accion, :detalle, :ip, :fecha)",
            [
                ':rid'     => (int)$raffleId,
                ':uid'     => (int)$userId,
                ':accion'  => $accion,
                ':detalle' => $detalle,
                ':ip'      => $ip,
                ':fecha'   => time(),
            ]
        );
    }

    public static function countActive()
    {
        $db = self::db();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT COUNT(*) as total FROM `" . $prefix . "raffles` WHERE estado = 'activo'"
        );
        return isset($row['total']) ? (int)$row['total'] : 0;
    }

    public static function getActive($limit = 50, $offset = 0, $userId = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $limit = (int)$limit;
        $offset = (int)$offset;

        $rows = $db->select(
            "SELECT * FROM `" . $prefix . "raffles` 
             WHERE estado = 'activo' 
             ORDER BY fecha_fin ASC 
             LIMIT " . $offset . ", " . $limit
        );

        return self::hydrateRaffles($rows, $userId);
    }

    public static function getFinished($limit = 20, $offset = 0, $userId = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $limit = (int)$limit;
        $offset = (int)$offset;

        $rows = $db->select(
            "SELECT * FROM `" . $prefix . "raffles` 
             WHERE estado = 'finalizado' 
             ORDER BY fecha_sorteo DESC 
             LIMIT " . $offset . ", " . $limit
        );

        return self::hydrateRaffles($rows, $userId);
    }

    public static function getById($id, $userId = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT * FROM `" . $prefix . "raffles` WHERE id = :id",
            [':id' => (int)$id]
        );
        if (!$row) return null;
        $raffles = self::hydrateRaffles([$row], $userId);
        return $raffles[0];
    }

    /**
     * Enriquece las filas con datos calculados.
     * Acepta $userId para ajustar precio_moneda según el riel.
     */
    private static function hydrateRaffles($rows, $userId = null)
    {
        if (!is_array($rows)) return [];
        $result = [];
        foreach ($rows as $r) {
            $moneda = self::getMonedaInfo($r['moneda'], $userId);
            $prizes = self::getPrizesByRaffle($r['id'], $userId);

            $pct = 0;
            if ($r['max_boletos'] > 0) {
                $pct = round(($r['boletos_vendidos'] / $r['max_boletos']) * 100);
            }

            // Precio ajustado al riel del jugador
            $precioReal = (int)$r['precio_boleto'];
            if ($r['moneda'] === 'ntx20' && $userId !== null) {
                $precioReal = self::getPrecioParaJugador((int)$r['precio_boleto'], $userId);
            }

            $result[] = array_merge($r, [
                'moneda_nombre'      => $moneda['nombre'],
                'moneda_icon'        => $moneda['icon'],
                'moneda_color'       => $moneda['color'],
                'precio_boleto_base' => (int)$r['precio_boleto'],   // base NTX-20
                'precio_boleto_real' => $precioReal,                // el que paga el jugador
                'premios'            => $prizes,
                'premio_principal'   => isset($prizes[0]) ? $prizes[0]['texto'] : 'Sin premio',
                'pct'                => $pct,
                'tiempo_restante'    => self::formatTiempo($r['fecha_fin'] - time()),
                'boletos_restantes'  => max(0, $r['max_boletos'] - $r['boletos_vendidos']),
            ]);
        }
        return $result;
    }

    public static function getPrizesByRaffle($raffleId, $userId = null)
    {
        $db = self::db();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT rp.*, u.username AS ganador_username
             FROM `" . $prefix . "raffle_prizes` rp
             LEFT JOIN `" . $prefix . "users` u ON u.id = rp.ganador_id
             WHERE rp.raffle_id = :rid 
             ORDER BY rp.orden ASC",
            [':rid' => (int)$raffleId]
        );
        if (!is_array($rows)) return [];
        $result = [];
        foreach ($rows as $p) {
            $p['texto'] = self::getPremioTexto($p, $userId);
            $result[] = $p;
        }
        return $result;
    }

    /**
     * Devuelve el texto del premio.
     * Acepta $userId: si es QVAPAY y el tipo es 'ntx20', muestra 'UNTX-20' y cantidad ×2.
     */
    public static function getPremioTexto($prize, $userId = null)
    {
        $tipo = $prize['tipo'];
        $cant = (int)$prize['cantidad'];

        // Override para QVAPAY
        if ($tipo === 'ntx20' && $userId !== null && self::isIntl($userId)) {
            $cant = $cant * self::UNTX_MULTIPLIER;
        }

        $cantFmt = number_format($cant);

        $nombresRecursos = [
            'metal'      => 'Metal',
            'crystal'    => 'Cristal',
            'deuterium'  => 'Deuterio',
            'darkmatter' => 'Materia Oscura',
            'ntx20'      => 'NTX-20',
            'vip'        => 'dias VIP',
            'pase'       => 'niveles de Pase',
        ];

        // Override del nombre para QVAPAY
        if ($tipo === 'ntx20' && $userId !== null && self::isIntl($userId)) {
            $nombresRecursos['ntx20'] = 'UNTX-20';
        }

        if (isset($nombresRecursos[$tipo])) {
            return $cantFmt . ' ' . $nombresRecursos[$tipo];
        }
        if ($tipo === 'nave') {
            return $cantFmt . ' Nave (ID ' . $prize['subtipo'] . ')';
        }
        if ($tipo === 'defensa') {
            return $cantFmt . ' Defensa (ID ' . $prize['subtipo'] . ')';
        }
        return $cantFmt . ' ' . $tipo;
    }

    public static function getTicketsByUser($userId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT t.*, r.titulo, r.estado, r.fecha_fin, r.ganador_id, 
                    r.boleto_ganador, r.moneda 
             FROM `" . $prefix . "raffle_tickets` t 
             INNER JOIN `" . $prefix . "raffles` r ON r.id = t.raffle_id 
             WHERE t.user_id = :uid 
             ORDER BY t.fecha_compra DESC",
            [':uid' => (int)$userId]
        );
        return is_array($rows) ? $rows : [];
    }

    public static function getTicketsByRaffle($raffleId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $rows = $db->select(
            "SELECT t.*, u.username 
             FROM `" . $prefix . "raffle_tickets` t 
             LEFT JOIN `" . $prefix . "users` u ON u.id = t.user_id 
             WHERE t.raffle_id = :rid 
             ORDER BY t.boleto_numero ASC",
            [':rid' => (int)$raffleId]
        );
        return is_array($rows) ? $rows : [];
    }

    public static function countTicketsByUser($raffleId, $userId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $row = $db->selectSingle(
            "SELECT COUNT(*) as total FROM `" . $prefix . "raffle_tickets` 
             WHERE raffle_id = :rid AND user_id = :uid",
            [':rid' => (int)$raffleId, ':uid' => (int)$userId]
        );
        return isset($row['total']) ? (int)$row['total'] : 0;
    }

    public static function hasTicket($raffleId, $userId)
    {
        return self::countTicketsByUser($raffleId, $userId) > 0;
    }

    /**
     * Saldo del jugador en una moneda.
     * - metal, crystal, deuterium -> planeta principal
     * - darkmatter                 -> uni1_users.darkmatter
     * - ntx20                      -> uni1_users.{ntx20|untx20} según riel
     */
    public static function getSaldoJugador($userId, $moneda)
    {
        $db = self::db();
        $prefix = self::prefix();

        if ($moneda === 'darkmatter') {
            $row = $db->selectSingle(
                "SELECT darkmatter FROM `" . $prefix . "users` WHERE id = :uid",
                [':uid' => (int)$userId]
            );
            return isset($row['darkmatter']) ? (int)$row['darkmatter'] : 0;
        }

        if ($moneda === 'ntx20') {
            // 🆕 v3.0 — Leer de la columna del riel del jugador
            $col = self::getPhysicalColumn($userId);
            $row = $db->selectSingle(
                "SELECT `".$col."` AS saldo FROM `" . $prefix . "users` WHERE id = :uid",
                [':uid' => (int)$userId]
            );
            return isset($row['saldo']) ? (int)$row['saldo'] : 0;
        }

        $cols = ['metal', 'crystal', 'deuterium'];
        if (!in_array($moneda, $cols)) {
            $moneda = 'metal';
        }

        $row = $db->selectSingle(
            "SELECT `" . $moneda . "` FROM `" . $prefix . "planets` 
             WHERE id_owner = :uid AND planet_type = 1 
             ORDER BY id ASC LIMIT 1",
            [':uid' => (int)$userId]
        );
        return ($row && isset($row[$moneda])) ? (int)$row[$moneda] : 0;
    }

    public static function create($adminId, $data)
    {
        $db = self::db();
        $prefix = self::prefix();

        if (empty($data['titulo'])) {
            return ['ok' => false, 'msg' => 'El titulo es obligatorio'];
        }
        if ($data['precio_boleto'] < 1) {
            return ['ok' => false, 'msg' => 'El precio debe ser al menos 1'];
        }
        if ($data['max_boletos'] < 1) {
            return ['ok' => false, 'msg' => 'Debe vender al menos 1 boleto'];
        }
        if ($data['cantidad_lugares'] < 1 || $data['cantidad_lugares'] > 20) {
            return ['ok' => false, 'msg' => 'Los lugares deben estar entre 1 y 20'];
        }
        if (self::countActive() >= 5) {
            return ['ok' => false, 'msg' => 'Ya hay 5 rifas activas (maximo)'];
        }

        $monedasValidas = ['metal', 'crystal', 'deuterium', 'darkmatter', 'ntx20'];
        if (!in_array($data['moneda'], $monedasValidas)) {
            return ['ok' => false, 'msg' => 'Moneda invalida'];
        }

        $duraciones = ['24h', '7d', '15d'];
        if (!in_array($data['duracion'], $duraciones)) {
            return ['ok' => false, 'msg' => 'Duracion invalida'];
        }

        $fechaInicio = time();
        $fechaFin = $fechaInicio + self::duracionASegundos($data['duracion']);

        $db->insert(
            "INSERT INTO `" . $prefix . "raffles` 
             (titulo, descripcion, moneda, precio_boleto, max_boletos, 
              cantidad_lugares, duracion, estado, fecha_inicio, fecha_fin, creado_por) 
             VALUES (:titulo, :descripcion, :moneda, :precio, :maxbol, 
                     :lugares, :duracion, 'activo', :finicio, :ffin, :admin)",
            [
                ':titulo'      => $data['titulo'],
                ':descripcion' => isset($data['descripcion']) ? $data['descripcion'] : '',
                ':moneda'      => $data['moneda'],
                ':precio'      => (int)$data['precio_boleto'],
                ':maxbol'      => (int)$data['max_boletos'],
                ':lugares'     => (int)$data['cantidad_lugares'],
                ':duracion'    => $data['duracion'],
                ':finicio'     => $fechaInicio,
                ':ffin'        => $fechaFin,
                ':admin'       => (int)$adminId,
            ]
        );

        $raffleId = $db->lastInsertId();

        if (!empty($data['premios']) && is_array($data['premios'])) {
            $orden = 1;
            foreach ($data['premios'] as $p) {
                // ✅ v4.0 — Lugar explícito por premio: VARIOS premios pueden
                // compartir el MISMO lugar (todos se los lleva el mismo
                // boleto ganador). 0 = auto → sigue la secuencia 1,2,3...
                $lugar = isset($p['lugar']) ? (int)$p['lugar'] : 0;
                if ($lugar < 0 || $lugar > 20) {
                    $lugar = 0;
                }
                if ($lugar === 0) {
                    $lugar = $orden;
                }

                $db->insert(
                    "INSERT INTO `" . $prefix . "raffle_prizes`
                     (raffle_id, orden, lugar, tipo, subtipo, cantidad)
                     VALUES (:rid, :orden, :lugar, :tipo, :subtipo, :cantidad)",
                    [
                        ':rid'      => $raffleId,
                        ':orden'    => $orden,
                        ':lugar'    => $lugar,
                        ':tipo'     => $p['tipo'],
                        ':subtipo'  => isset($p['subtipo']) ? (int)$p['subtipo'] : 0,
                        ':cantidad' => (int)$p['cantidad'],
                    ]
                );
                $orden++;
            }

            // ✅ v4.0 — Sincronizar cantidad_lugares con los lugares REALES
            // (si el admin puso 3 lugares pero definió premios en 1,1,1,2 la
            // rifa tiene 2 lugares ganadores, no 3).
            $rowLugares = $db->selectSingle(
                "SELECT COUNT(DISTINCT lugar) AS l FROM `"
                . $prefix . "raffle_prizes` WHERE raffle_id = :rid",
                [':rid' => $raffleId]
            );
            $lugaresReales = ($rowLugares && !empty($rowLugares['l']))
                ? max(1, (int)$rowLugares['l']) : 1;
            if ($lugaresReales !== (int)$data['cantidad_lugares']) {
                $db->update(
                    "UPDATE `" . $prefix . "raffles` SET cantidad_lugares = :l WHERE id = :rid",
                    [':l' => $lugaresReales, ':rid' => $raffleId]
                );
            }
        }

        self::log($raffleId, $adminId, 'creado', 'Rifa creada: ' . $data['titulo']);

        return ['ok' => true, 'raffle_id' => $raffleId];
    }

    /**
     * Compra un boleto.
     * Si la rifa es en ntx20:
     *  - CUP:    cobra precio × 1 de ntx20
     *  - QVAPAY: cobra precio × 2 de untx20
     */
    public static function buyTicket($raffleId, $userId, $ip = null)
    {
        $db = self::db();
        $prefix = self::prefix();

        if (isset($_SESSION['last_raffle_buy']) && (time() - $_SESSION['last_raffle_buy']) < 2) {
            return ['ok' => false, 'msg' => 'Espera 2 segundos entre compras'];
        }
        $_SESSION['last_raffle_buy'] = time();

        $pdo = $db->getHandle();

        try {
            $pdo->beginTransaction();

            $raffle = $db->selectSingle(
                "SELECT * FROM `" . $prefix . "raffles` 
                 WHERE id = :id AND estado = 'activo' FOR UPDATE",
                [':id' => (int)$raffleId]
            );

            if (!$raffle) throw new Exception('Rifa no disponible');
            if ($raffle['fecha_fin'] < time()) throw new Exception('La rifa ya vencio');
            if ($raffle['boletos_vendidos'] >= $raffle['max_boletos']) {
                throw new Exception('No quedan boletos disponibles');
            }

            $tieneBoleto = self::countTicketsByUser($raffleId, $userId);
            if ($tieneBoleto > 0) {
                throw new Exception('Ya tenes un boleto en esta rifa (maximo 1 por jugador)');
            }

            $moneda = $raffle['moneda'];
            $precioBase = (int)$raffle['precio_boleto'];

            // 🆕 v3.0 — Detectar riel del jugador (solo importa si moneda === 'ntx20')
            $isIntl     = ($moneda === 'ntx20') ? self::isIntl($userId) : false;
            $colBalance = $isIntl ? 'untx20' : 'ntx20';
            $monedaLbl  = $isIntl ? 'UNTX-20' : 'NTX-20';
            $precioReal = ($moneda === 'ntx20')
                ? self::getPrecioParaJugador($precioBase, $userId)
                : $precioBase;

            // ============ MONEDAS EN uni1_users ============
            if ($moneda === 'darkmatter') {
                $row = $db->selectSingle(
                    "SELECT darkmatter FROM `" . $prefix . "users` 
                     WHERE id = :uid FOR UPDATE",
                    [':uid' => (int)$userId]
                );
                if (!$row || $row['darkmatter'] < $precioReal) {
                    throw new Exception('No tenes suficiente Materia Oscura');
                }
                $nuevoSaldo = $row['darkmatter'] - $precioReal;
                $db->update(
                    "UPDATE `" . $prefix . "users` SET darkmatter = :saldo WHERE id = :uid",
                    [':saldo' => $nuevoSaldo, ':uid' => (int)$userId]
                );
                if (isset($GLOBALS['USER']) && $GLOBALS['USER']['id'] == $userId) {
                    $GLOBALS['USER']['darkmatter'] = $nuevoSaldo;
                }
            } elseif ($moneda === 'ntx20') {
                // 🆕 v3.0 — Cobra de la columna del riel
                $row = $db->selectSingle(
                    "SELECT `".$colBalance."` AS saldo FROM `" . $prefix . "users` 
                     WHERE id = :uid FOR UPDATE",
                    [':uid' => (int)$userId]
                );
                if (!$row || (int)$row['saldo'] < $precioReal) {
                    throw new Exception('No tenes suficiente ' . $monedaLbl);
                }
                $nuevoSaldo = (int)$row['saldo'] - $precioReal;
                $db->update(
                    "UPDATE `" . $prefix . "users` SET `".$colBalance."` = :saldo WHERE id = :uid",
                    [':saldo' => $nuevoSaldo, ':uid' => (int)$userId]
                );
                if (isset($GLOBALS['USER']) && $GLOBALS['USER']['id'] == $userId) {
                    $GLOBALS['USER'][$colBalance] = $nuevoSaldo;
                }

                // Log NTX20 solo para CUP (no hay UNTXLogHelper)
                if (!$isIntl) {
                    self::logNtx20(
                        $userId,
                        -$precioReal,
                        'raffle_ticket',
                        'Boleto de rifa: ' . $raffle['titulo'],
                        (int)$raffleId
                    );
                }
            } else {
                // ============ MONEDAS EN uni1_planets (planeta principal) ============
                $cols = ['metal', 'crystal', 'deuterium'];
                if (!in_array($moneda, $cols)) throw new Exception('Moneda invalida');

                $planeta = $db->selectSingle(
                    "SELECT id FROM `" . $prefix . "planets` 
                     WHERE id_owner = :uid AND planet_type = 1 
                     ORDER BY id ASC LIMIT 1 FOR UPDATE",
                    [':uid' => (int)$userId]
                );

                if (!$planeta || !isset($planeta['id'])) {
                    throw new Exception('No tenes planeta principal');
                }

                $row = $db->selectSingle(
                    "SELECT `" . $moneda . "` FROM `" . $prefix . "planets` 
                     WHERE id = :pid FOR UPDATE",
                    [':pid' => (int)$planeta['id']]
                );

                if (!$row || $row[$moneda] < $precioReal) {
                    throw new Exception('No tenes suficiente ' . self::getMonedaInfo($moneda)['nombre']);
                }

                $nuevoSaldo = $row[$moneda] - $precioReal;
                $db->update(
                    "UPDATE `" . $prefix . "planets` SET `" . $moneda . "` = :saldo 
                     WHERE id = :pid",
                    [':saldo' => $nuevoSaldo, ':pid' => (int)$planeta['id']]
                );
                if (isset($GLOBALS['PLANET']) && (int)$GLOBALS['PLANET']['id'] === (int)$planeta['id']) {
                    $GLOBALS['PLANET'][$moneda] = $nuevoSaldo;
                }
            }

            $numBoleto = (int)$raffle['boletos_vendidos'] + 1;

            // 🆕 v3.0 — Guardar la moneda REAL usada (untx20 si es QVAPAY)
            $monedaPagada = ($moneda === 'ntx20' && $isIntl) ? 'untx20' : $moneda;

            $db->insert(
                "INSERT INTO `" . $prefix . "raffle_tickets` 
                 (raffle_id, user_id, boleto_numero, precio_pagado, moneda_pagada, ip_compra, fecha_compra) 
                 VALUES (:rid, :uid, :num, :precio, :moneda, :ip, :fecha)",
                [
                    ':rid'    => (int)$raffleId,
                    ':uid'    => (int)$userId,
                    ':num'    => $numBoleto,
                    ':precio' => $precioReal,
                    ':moneda' => $monedaPagada,
                    ':ip'     => $ip ? $ip : (isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null),
                    ':fecha'  => time(),
                ]
            );

            $db->update(
                "UPDATE `" . $prefix . "raffles` 
                 SET boletos_vendidos = boletos_vendidos + 1 
                 WHERE id = :rid",
                [':rid' => (int)$raffleId]
            );

            self::log($raffleId, $userId, 'boleto_comprado', 
                      'Boleto #' . $numBoleto . ' pagado con ' . $precioReal . ' ' . $monedaLbl);

            $pdo->commit();

            return [
                'ok'      => true,
                'boleto'  => $numBoleto,
                'precio'  => $precioReal,
                'moneda'  => $monedaLbl,
            ];

        } catch (Exception $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            return ['ok' => false, 'msg' => $e->getMessage()];
        }
    }

    public static function drawWinner($raffleId)
    {
        $db = self::db();
        $prefix = self::prefix();

        $pdo = $db->getHandle();

        try {
            $pdo->beginTransaction();

            $raffle = $db->selectSingle(
                "SELECT * FROM `" . $prefix . "raffles` 
                 WHERE id = :id AND estado = 'activo' FOR UPDATE",
                [':id' => (int)$raffleId]
            );

            if (!$raffle) throw new Exception('Rifa no activa');

            $tickets = $db->select(
                "SELECT * FROM `" . $prefix . "raffle_tickets` 
                 WHERE raffle_id = :rid 
                 ORDER BY boleto_numero ASC",
                [':rid' => (int)$raffleId]
            );

            if (!is_array($tickets) || count($tickets) === 0) {
                $db->update(
                    "UPDATE `" . $prefix . "raffles` SET 
                     estado = 'finalizado', fecha_sorteo = :fecha 
                     WHERE id = :rid",
                    [':fecha' => time(), ':rid' => (int)$raffleId]
                );
                self::log($raffleId, 0, 'finalizado', 'Sin boletos vendidos');
                $pdo->commit();
                return ['ok' => true, 'msg' => 'Sin boletos'];
            }

            // ✅ v4.0 — Agrupar premios por LUGAR: todos los premios del
            // mismo lugar se los lleva el MISMO boleto ganador (antes 1 fila
            // = 1 lugar, así que dar varios premios al 1er lugar era
            // imposible). Premios legacy con lugar=0 caen a su orden.
            $prizes = $db->select(
                "SELECT * FROM `" . $prefix . "raffle_prizes`
                 WHERE raffle_id = :rid
                 ORDER BY lugar ASC, orden ASC, id ASC",
                [':rid' => (int)$raffleId]
            );

            $porLugar = [];
            foreach ($prizes as $p) {
                $lugar = ((int)$p['lugar'] > 0) ? (int)$p['lugar'] : (int)$p['orden'];
                $porLugar[$lugar][] = $p;
            }
            $lugaresOrdenados = array_keys($porLugar);
            sort($lugaresOrdenados);

            $semilla = random_int(1, 999999999);
            mt_srand($semilla);

            $indices = range(0, count($tickets) - 1);
            shuffle($indices);

            $ganadores = [];
            $cantidadLugares = min(count($lugaresOrdenados), count($tickets));

            for ($i = 0; $i < $cantidadLugares; $i++) {
                $ticket = $tickets[$indices[$i]];
                $premiosLugar = $porLugar[$lugaresOrdenados[$i]];

                foreach ($premiosLugar as $prize) {
                    $db->update(
                        "UPDATE `" . $prefix . "raffle_prizes` SET
                         ganador_id = :gid, boleto_ganador = :bnum, fecha_entrega = :fecha
                         WHERE id = :pid",
                        [
                            ':gid'   => (int)$ticket['user_id'],
                            ':bnum'  => (int)$ticket['boleto_numero'],
                            ':fecha' => time(),
                            ':pid'   => (int)$prize['id'],
                        ]
                    );
                }

                $ganadores[] = [
                    'user_id' => (int)$ticket['user_id'],
                    'boleto'  => (int)$ticket['boleto_numero'],
                    'lugar'   => $lugaresOrdenados[$i],
                    'premio'  => $premiosLugar[0],
                    'premios' => $premiosLugar,
                ];
            }

            $hash = hash('sha256', $raffleId . '|' . $semilla . '|' . json_encode($ganadores));

            $primerGanador = $ganadores[0];
            $db->update(
                "UPDATE `" . $prefix . "raffles` SET 
                 estado = 'finalizado',
                 ganador_id = :gid,
                 boleto_ganador = :bnum,
                 semilla = :semilla,
                 hash_verificacion = :hash,
                 fecha_sorteo = :fecha 
                 WHERE id = :rid",
                [
                    ':gid'     => $primerGanador['user_id'],
                    ':bnum'    => $primerGanador['boleto'],
                    ':semilla' => $semilla,
                    ':hash'    => $hash,
                    ':fecha'   => time(),
                    ':rid'     => (int)$raffleId,
                ]
            );

            // ==========================================================
            //  ENTREGA DE PREMIOS DENTRO DE LA TRANSACCION
            //  ✅ v4.0 — todos los premios del lugar de cada ganador
            // ==========================================================
            foreach ($ganadores as $g) {
                foreach ($g['premios'] as $prize) {
                    $ok = self::deliverPrize($g['user_id'], $prize, $raffleId, $g['boleto']);
                    if (!$ok) {
                        throw new Exception(
                            'Fallo al entregar premio tipo ' . $prize['tipo'] .
                            ' a user_id ' . $g['user_id']
                        );
                    }
                }
            }

            self::log($raffleId, 0, 'finalizado',
                      'Sorteados ' . count($lugaresOrdenados) . ' lugares / '
                      . count($prizes) . ' premios. Semilla: ' . $semilla);

            $pdo->commit();

            foreach ($ganadores as $g) {
                // ✅ v4.0 — un SOLO mensaje por ganador, con TODOS los
                // premios de su lugar listados
                self::notifyWinner(
                    $g['user_id'], $raffle, $g['premio'], $g['boleto'],
                    array_slice($g['premios'], 1)
                );
            }

            return ['ok' => true, 'ganadores' => $ganadores];

        } catch (Exception $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            self::log($raffleId, 0, 'error_sorteo', $e->getMessage());
            return ['ok' => false, 'msg' => $e->getMessage()];
        }
    }

    /**
     * Entrega el premio al ganador.
     * - Si tipo = 'ntx20':
     *    · CUP:    suma cantidad × 1 en ntx20
     *    · QVAPAY: suma cantidad × 2 en untx20
     * - Resto igual que antes.
     */
    public static function deliverPrize($userId, $prize, $raffleId, $boleto)
    {
        $db = self::db();
        $prefix = self::prefix();

        $tipo     = $prize['tipo'];
        $cantidadBase = (int)$prize['cantidad'];
        $subtipo  = isset($prize['subtipo']) ? (int)$prize['subtipo'] : 0;

        // ==========================================================
        // 1) NTX-20 (dual riel)
        // ==========================================================
        if ($tipo === 'ntx20') {
            $isIntl     = self::isIntl($userId);
            $colBalance = $isIntl ? 'untx20' : 'ntx20';
            $monedaLbl  = $isIntl ? 'UNTX-20' : 'NTX-20';

            // 🆕 v3.0 — Cantidad ×2 si QVAPAY
            $cantidadReal = $isIntl ? ($cantidadBase * self::UNTX_MULTIPLIER) : $cantidadBase;

            $db->update(
                "UPDATE `" . $prefix . "users` SET `".$colBalance."` = `".$colBalance."` + :cant WHERE id = :uid",
                [':cant' => $cantidadReal, ':uid' => (int)$userId]
            );
            if (isset($GLOBALS['USER']) && (int)$GLOBALS['USER']['id'] === (int)$userId) {
                $GLOBALS['USER'][$colBalance] = (int)$GLOBALS['USER'][$colBalance] + $cantidadReal;
            }

            // Log solo para CUP
            if (!$isIntl) {
                self::logNtx20(
                    $userId,
                    +$cantidadReal,
                    'earn_raffle',
                    'Premio de rifa ganado (boleto #' . $boleto . ')',
                    (int)$raffleId
                );
            }

            self::log($raffleId, $userId, 'premio_entregado', 
                      $cantidadReal . ' ' . $monedaLbl . ' (boleto #' . $boleto . ')');
            return true;
        }

        // ==========================================================
        // 2) MATERIA OSCURA (global, sin dual riel)
        // ==========================================================
        if ($tipo === 'darkmatter') {
            $db->update(
                "UPDATE `" . $prefix . "users` SET darkmatter = darkmatter + :cant WHERE id = :uid",
                [':cant' => $cantidadBase, ':uid' => (int)$userId]
            );
            if (isset($GLOBALS['USER']) && (int)$GLOBALS['USER']['id'] === (int)$userId) {
                $GLOBALS['USER']['darkmatter'] = (int)$GLOBALS['USER']['darkmatter'] + $cantidadBase;
            }
            self::log($raffleId, $userId, 'premio_entregado', 
                      $cantidadBase . ' MO (boleto #' . $boleto . ')');
            return true;
        }

        // ==========================================================
        // BUSCAR PLANETA PRINCIPAL (menor id con planet_type = 1)
        // ==========================================================
        $planeta = $db->selectSingle(
            "SELECT id FROM `" . $prefix . "planets` 
             WHERE id_owner = :uid AND planet_type = 1 
             ORDER BY id ASC LIMIT 1",
            [':uid' => (int)$userId]
        );

        if (!$planeta || !isset($planeta['id'])) {
            self::log($raffleId, $userId, 'premio_FALLIDO',
                      'No se encontro planeta principal del usuario');
            return false;
        }
        $planetId = (int)$planeta['id'];

        // 3) METAL / CRISTAL / DEUTERIO -> planeta principal
        if (in_array($tipo, ['metal', 'crystal', 'deuterium'])) {
            $col = $tipo;
            $db->update(
                "UPDATE `" . $prefix . "planets` 
                 SET `" . $col . "` = `" . $col . "` + :cant 
                 WHERE id = :pid",
                [':cant' => $cantidadBase, ':pid' => $planetId]
            );
            if (isset($GLOBALS['PLANET']) && (int)$GLOBALS['PLANET']['id'] === $planetId) {
                $GLOBALS['PLANET'][$col] = (int)$GLOBALS['PLANET'][$col] + $cantidadBase;
            }
            self::log($raffleId, $userId, 'premio_entregado', 
                      $cantidadBase . ' ' . $col . ' al planeta ' . $planetId .
                      ' (boleto #' . $boleto . ')');
            return true;
        }

        // 4) NAVES -> planeta principal
        $mapaNaves = [
            202 => 'small_ship_cargo', 203 => 'big_ship_cargo',
            204 => 'light_hunter',     205 => 'heavy_hunter',
            206 => 'crusher',          207 => 'battle_ship',
            208 => 'colonizer',        209 => 'recycler',
            210 => 'spy_sonde',        211 => 'bomber_ship',
            212 => 'solar_satelit',    213 => 'destructor',
            214 => 'dearth_star',      215 => 'battleship',
            216 => 'lune_noir',        217 => 'ev_transporter',
            218 => 'star_crasher',     219 => 'giga_recykler',
            220 => 'dm_ship',
        ];

        if ($tipo === 'nave' && isset($mapaNaves[$subtipo])) {
            $col = $mapaNaves[$subtipo];
            $db->update(
                "UPDATE `" . $prefix . "planets` 
                 SET `" . $col . "` = `" . $col . "` + :cant 
                 WHERE id = :pid",
                [':cant' => $cantidadBase, ':pid' => $planetId]
            );
            self::log($raffleId, $userId, 'premio_entregado', 
                      $cantidadBase . ' nave ' . $col . ' (ID ' . $subtipo . 
                      ') (boleto #' . $boleto . ')');
            return true;
        }

        // 5) DEFENSAS -> planeta principal
        $mapaDefensas = [
            401 => 'misil_launcher',   402 => 'small_laser',
            403 => 'big_laser',        404 => 'gauss_canyon',
            405 => 'ionic_canyon',     406 => 'buster_canyon',
            407 => 'small_protection_shield', 408 => 'big_protection_shield',
            502 => 'interceptor_misil',      503 => 'interplanetary_misil',
        ];

        if ($tipo === 'defensa' && isset($mapaDefensas[$subtipo])) {
            $col = $mapaDefensas[$subtipo];
            $db->update(
                "UPDATE `" . $prefix . "planets` 
                 SET `" . $col . "` = `" . $col . "` + :cant 
                 WHERE id = :pid",
                [':cant' => $cantidadBase, ':pid' => $planetId]
            );
            self::log($raffleId, $userId, 'premio_entregado', 
                      $cantidadBase . ' defensa ' . $col . ' (ID ' . $subtipo . 
                      ') (boleto #' . $boleto . ')');
            return true;
        }

        self::log($raffleId, $userId, 'premio_FALLIDO',
                  'Tipo ' . $tipo . ' subtipo ' . $subtipo . ' no reconocido');
        return false;
    }

    public static function notifyWinner($userId, $raffle, $prize, $boleto, $premiosExtra = [])
    {
        $db = self::db();
        $prefix = self::prefix();

        // 🆕 v3.0 — Texto del premio con moneda del riel
        $premioTexto = self::getPremioTexto($prize, $userId);

        // ✅ v4.0 — si el lugar tenía VARIOS premios, se listan todos
        if (!empty($premiosExtra) && is_array($premiosExtra)) {
            $lineas = ['  · ' . $premioTexto];
            foreach ($premiosExtra as $p2) {
                $lineas[] = '  · ' . self::getPremioTexto($p2, $userId);
            }
            $premioTexto = "Varios premios por tu lugar:\n" . implode("\n", $lineas);
        }

        $asunto = 'Ganaste en la rifa: ' . $raffle['titulo'];
        $mensaje = "Felicitaciones!\n\n"
                 . "Rifa: " . $raffle['titulo'] . "\n"
                 . "Premio: " . $premioTexto . "\n"
                 . "Tu boleto ganador: #" . $boleto . "\n\n"
                 . "El premio ya fue acreditado en tu cuenta.\n\n"
                 . "AVISO: Si tu almacen esta lleno, los recursos pueden "
                 . "capearse al maximo. Amplia tu almacen cuanto antes.\n\n"
                 . "- El equipo de AstroIO";

        $db->insert(
            "INSERT INTO `" . $prefix . "messages` 
             (message_sender_id, message_owner_id, message_subject, 
              message_text, message_time, message_type, message_unread) 
             VALUES (0, :uid, :asunto, :texto, :fecha, 1, 1)",
            [
                ':uid'    => (int)$userId,
                ':asunto' => $asunto,
                ':texto'  => $mensaje,
                ':fecha'  => time(),
            ]
        );
    }

    public static function processExpired()
    {
        $db = self::db();
        $prefix = self::prefix();

        $rows = $db->select(
            "SELECT id FROM `" . $prefix . "raffles` 
             WHERE estado = 'activo' AND fecha_fin < :ahora 
             LIMIT 5",
            [':ahora' => time()]
        );

        if (!is_array($rows)) return 0;

        $count = 0;
        foreach ($rows as $r) {
            $result = self::drawWinner($r['id']);
            if ($result['ok']) $count++;
        }
        return $count;
    }

    public static function getWidgetData($limit = 3, $userId = null)
    {
        $raffles = self::getActive($limit, 0, $userId);
        $result = [];
        foreach ($raffles as $r) {
            $result[] = [
                'id'               => $r['id'],
                'titulo'           => $r['titulo'],
                'boletos_vendidos' => $r['boletos_vendidos'],
                'max_boletos'      => $r['max_boletos'],
                'pct'              => $r['pct'],
                'premio_texto'     => $r['premio_principal'],
                'precio_boleto'    => $r['precio_boleto_real'],  // 🆕 v3.0 — ya ajustado
                'moneda_nombre'    => $r['moneda_nombre'],
                'moneda_icon'      => $r['moneda_icon'],
                'moneda_color'     => $r['moneda_color'],
                'fecha_fin'        => $r['fecha_fin'],
                'tiempo_restante'  => $r['tiempo_restante'],
            ];
        }
        return $result;
    }
}