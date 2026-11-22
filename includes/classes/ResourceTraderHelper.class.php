<?php
/**
 * ResourceTraderHelper
 * Logica del Comerciante de Recursos (AstroIO) con Doble Riel
 *
 * Reglas:
 *  - Recursos intercambiables: metal/crystal/deuterium del PLANETA actual
 *  - Coste: 50 MO base, con descuento VIP (via VIPHelper del sistema)
 *  - Fallback: si no alcanza MO, paga 2 NTX-20 (CUP) o 4 UNTX-20 (QvaPay)
 *  - Sin limite, sin historial, sin mensaje interno
 *
 * Ratios actuales (v2):
 *  - metal     = 1
 *  - crystal   = 2
 *  - deuterium = 4
 *
 * v2.4 — DOBLE RIEL: Si el jugador es QVAPAY, el coste fallback se duplica
 *         (4 UNTX-20) y se descuenta de la columna `untx20`. El mensaje
 *         muestra la moneda correcta.
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

class ResourceTraderHelper
{
    /** Coste base en MO */
    const COSTE_MO_BASE = 50;

    /** Coste alternativo en NTX-20 (fijo, sin descuento VIP) */
    const COSTE_NTX20 = 2;

    /** Multiplicador para UNTX-20 (el doble) */
    const UNTX_MULTIPLIER = 2;

    /**
     * Tasas: [dar][recibir] = tasa
     *
     * Ratio base: metal=1, crystal=2, deuterium=4
     *
     * Formula: tasa = valor(dar) / valor(recibir)
     *  - metal -> crystal   : 1/2 = 0.5
     *  - metal -> deuterium : 1/4 = 0.25
     *  - crystal -> metal   : 2/1 = 2.0
     *  - crystal -> deuterium: 2/4 = 0.5
     *  - deuterium -> metal : 4/1 = 4.0
     *  - deuterium -> crystal: 4/2 = 2.0
     */
    private static $TASAS = [
        'metal'     => ['crystal'   => 0.5,   'deuterium' => 0.25],
        'crystal'   => ['metal'     => 2.0,   'deuterium' => 0.5],
        'deuterium' => ['metal'     => 4.0,   'crystal'   => 2.0],
    ];

    private static $NOMBRES = [
        'metal'     => 'Metal',
        'crystal'   => 'Cristal',
        'deuterium' => 'Deuterio',
    ];

    private static $COLUMNAS = [
        'metal'     => 'metal',
        'crystal'   => 'crystal',
        'deuterium' => 'deuterium',
    ];

    /**
     * Prefijo de tablas (mismo patron que VIPHelper)
     */
    private static function prefix(): string
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    // =====================================================
    //  GETTERS BASICOS
    // =====================================================

    public static function getTasa(string $dar, string $recibir): float
    {
        return self::$TASAS[$dar][$recibir] ?? 0.0;
    }

    public static function calcularRecibir(int $cantidadDar, float $tasa): int
    {
        return (int) floor($cantidadDar * $tasa);
    }

    public static function getNombre(string $recurso): string
    {
        return self::$NOMBRES[$recurso] ?? $recurso;
    }

    public static function esRecursoValido(string $recurso): bool
    {
        return isset(self::$NOMBRES[$recurso]);
    }

    public static function esOperacionValida(string $dar, string $recibir): bool
    {
        return $dar !== $recibir
            && self::esRecursoValido($dar)
            && self::esRecursoValido($recibir)
            && self::getTasa($dar, $recibir) > 0;
    }

    public static function getRecursosDar(): array
    {
        return array_keys(self::$TASAS);
    }

    public static function getRecursosRecibir(string $dar): array
    {
        return array_keys(self::$TASAS[$dar] ?? []);
    }

    public static function getTodasLasTasas(): array
    {
        return self::$TASAS;
    }

    public static function getNombres(): array
    {
        return self::$NOMBRES;
    }

    // =====================================================
    //  VIP (integrado con VIPHelper del sistema)
    // =====================================================

    /**
     * Devuelve el descuento VIP en % (0 si no es VIP).
     * Usa VIPHelper como fuente unica de verdad.
     */
    public static function getVipDiscount(int $userId): int
    {
        if ($userId <= 0) {
            return 0;
        }
        if (!class_exists('VIPHelper')) {
            return 0;
        }

        if (!VIPHelper::isVIP($userId)) {
            return 0;
        }

        $data = VIPHelper::getVIPData($userId);
        if (empty($data) || empty($data['vip_type'])) {
            return 0;
        }

        $mapa = [
            'weekly'     => 10,
            'biweekly'   => 12,
            'monthly'    => 15,
            'semiannual' => 25,
            'annual'     => 40,
        ];

        return $mapa[$data['vip_type']] ?? 0;
    }

    /**
     * Coste final en MO aplicando descuento VIP.
     */
    public static function getCosteMO(int $userId): int
    {
        $desc  = self::getVipDiscount($userId);
        $coste = (int) round(self::COSTE_MO_BASE * (100 - $desc) / 100);
        return max(1, $coste);
    }

    // =====================================================
    //  🆕 v2.5 — OFICIAL COMERCIANTE (ID 617)
    // =====================================================

    /**
     * 🆕 v2.5 — Nivel del Oficial Comerciante del jugador.
     * Columna rpg_comerciante (tope 5, igual que uni1_vars.maxLevel).
     */
    public static function getComercianteNivel(int $userId): int
    {
        if ($userId <= 0) {
            return 0;
        }

        global $db;
        $prefix = self::prefix();

        try {
            $row = $db->selectSingle(
                "SELECT `rpg_comerciante` AS lvl FROM `".$prefix."users` WHERE `id` = :uid LIMIT 1",
                [':uid' => $userId]
            );
            return ($row && isset($row['lvl'])) ? min(5, max(0, (int) $row['lvl'])) : 0;
        } catch (Exception $e) {
            return 0;
        }
    }

    /**
     * 🆕 v2.5 — Multiplicador de lo RECIBIDO por el Oficial Comerciante.
     * +2% por nivel (nivel 5 = +10% de recursos extra en cada cambio).
     * La vista previa de la página del trader aplica el mismo
     * multiplicador: lo que ves es lo que recibes.
     */
    public static function getComercianteMulti(int $userId): float
    {
        return 1.0 + (self::getComercianteNivel($userId) * 0.02);
    }

    // =====================================================
    //  DOBLE RIEL — MÉTODOS AUXILIARES
    // =====================================================

    /**
     * 🆕 v2.4 — Detecta el método de pago del jugador.
     */
    private static function getPlayerMethod(int $userId): string
    {
        global $db;
        $prefix = self::prefix();

        $row = $db->selectSingle(
            "SELECT `metodo_retiro` FROM `".$prefix."users` WHERE `id` = :uid LIMIT 1",
            [':uid' => $userId]
        );

        return ($row && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
    }

    /**
     * 🆕 v2.4 — Obtiene el saldo correcto (ntx20 o untx20) según el método.
     */
    private static function getPlayerBalance(int $userId, string $method): int
    {
        global $db;
        $prefix = self::prefix();
        $col = ($method === 'QVAPAY') ? 'untx20' : 'ntx20';

        $row = $db->selectSingle(
            "SELECT `".$col."` AS saldo FROM `".$prefix."users` WHERE `id` = :uid LIMIT 1",
            [':uid' => $userId]
        );

        return $row ? (int)$row['saldo'] : 0;
    }

    // =====================================================
    //  RECURSOS
    // =====================================================

    /**
     * Recursos del planeta actual + MO + NTX-20 del usuario.
     */
    public static function getRecursosActuales(int $userId, int $planetId): array
    {
        global $db;
        $prefix = self::prefix();

        $planeta = $db->selectSingle(
            "SELECT `metal`, `crystal`, `deuterium`
             FROM `" . $prefix . "planets`
             WHERE `id` = :pid AND `id_owner` = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );

        $user = $db->selectSingle(
            "SELECT `darkmatter`, `ntx20`
             FROM `" . $prefix . "users`
             WHERE `id` = :uid",
            [':uid' => $userId]
        );

        return [
            'metal'      => (int) ($planeta['metal']     ?? 0),
            'crystal'    => (int) ($planeta['crystal']   ?? 0),
            'deuterium'  => (int) ($planeta['deuterium'] ?? 0),
            'darkmatter' => (int) ($user['darkmatter']   ?? 0),
            'ntx20'      => (int) ($user['ntx20']        ?? 0),
        ];
    }

    // =====================================================
    //  EJECUTAR INTERCAMBIO (v2.4 — doble riel)
    // =====================================================

    /**
     * @return array{ok:bool, msg:string, cantidad_dar:int, cantidad_recibir:int, metodo:string}
     */
    public static function ejecutarIntercambio(
        int $userId,
        int $planetId,
        string $dar,
        string $recibir,
        int $cantidadDar
    ): array {
        global $db;
        $prefix = self::prefix();

        $fail = function (string $m): array {
            return [
                'ok' => false,
                'msg' => $m,
                'cantidad_dar' => 0,
                'cantidad_recibir' => 0,
                'metodo' => '',
            ];
        };

        // 1) Validaciones basicas
        if (!self::esOperacionValida($dar, $recibir)) {
            return $fail('Operacion no valida.');
        }
        if ($cantidadDar <= 0) {
            return $fail('La cantidad debe ser mayor a 0.');
        }

        $tasa            = self::getTasa($dar, $recibir);
        $cantidadRecibir = self::calcularRecibir($cantidadDar, $tasa);

        // 🆕 v2.5 — Oficial Comerciante (ID 617): +2% por nivel al recibir
        // (nivel máx. 5 = +10%). La vista previa del trader usa el mismo
        // multiplicador, así que la ganancia mostrada coincide con esta.
        $multiComerciante = self::getComercianteMulti($userId);
        $cantidadRecibir  = (int) floor($cantidadRecibir * $multiComerciante);

        if ($cantidadRecibir <= 0) {
            $minimo = (int) ceil(1 / $tasa);
            return $fail('La cantidad a recibir seria 0. Necesitas al menos ' . $minimo . ' unidades.');
        }

        // 2) Leer estado fresco
        $planeta = $db->selectSingle(
            "SELECT `metal`, `crystal`, `deuterium`
             FROM `" . $prefix . "planets`
             WHERE `id` = :pid AND `id_owner` = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );
        if (empty($planeta)) {
            return $fail('Planeta no encontrado.');
        }

        $user = $db->selectSingle(
            "SELECT `darkmatter`, `ntx20`, `untx20`, `metodo_retiro`
             FROM `" . $prefix . "users`
             WHERE `id` = :uid",
            [':uid' => $userId]
        );
        if (empty($user)) {
            return $fail('Usuario no encontrado.');
        }

        // 🆕 v2.4 — Detectar método y saldo correcto
        $metodo      = ($user['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
        $colBalance  = ($metodo === 'QVAPAY') ? 'untx20' : 'ntx20';
        $saldoActual = (int) ($user[$colBalance] ?? 0);
        $moneda      = ($metodo === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';

        // 3) Validar stock del recurso a dar
        if ((int) $planeta[$dar] < $cantidadDar) {
            return $fail('No tienes suficientes recursos para entregar.');
        }

        // 4) Determinar metodo de pago (MO primero, luego la moneda correcta)
        $costeMO   = self::getCosteMO($userId);
        $moActual  = (int) $user['darkmatter'];

        // 🆕 v2.4 — Coste fallback ajustado al doble riel
        $costeFallback = self::COSTE_NTX20;
        if ($metodo === 'QVAPAY') {
            $costeFallback = self::COSTE_NTX20 * self::UNTX_MULTIPLIER; // 4 UNTX-20
        }

        if ($moActual >= $costeMO) {
            $metodoPago = 'mo';
        } elseif ($saldoActual >= $costeFallback) {
            $metodoPago = 'ntx20'; // puede ser ntx20 o untx20
        } else {
            return $fail(
                'No tienes suficiente MO ni ' . $moneda . '. '
                . 'Necesitas ' . $costeMO . ' MO o ' . $costeFallback . ' ' . $moneda . '.'
            );
        }

        // 5) UPDATE planeta (con guard atomico)
        $colDar     = self::$COLUMNAS[$dar];
        $colRecibir = self::$COLUMNAS[$recibir];

        $db->update(
            "UPDATE `" . $prefix . "planets`
             SET `{$colDar}`     = `{$colDar}`     - :cantDar,
                 `{$colRecibir}` = `{$colRecibir}` + :cantRec
             WHERE `id` = :pid
               AND `id_owner` = :uid
               AND `{$colDar}` >= :cantDar2",
            [
                ':cantDar'  => $cantidadDar,
                ':cantRec'  => $cantidadRecibir,
                ':pid'      => $planetId,
                ':uid'      => $userId,
                ':cantDar2' => $cantidadDar,
            ]
        );

        // 6) UPDATE usuario (MO o la moneda correcta)
        if ($metodoPago === 'mo') {
            $db->update(
                "UPDATE `" . $prefix . "users`
                 SET `darkmatter` = `darkmatter` - :coste
                 WHERE `id` = :uid
                   AND `darkmatter` >= :coste2",
                [':coste' => $costeMO, ':uid' => $userId, ':coste2' => $costeMO]
            );
        } else {
            // 🆕 v2.4 — Descontar de la columna correcta
            $db->update(
                "UPDATE `" . $prefix . "users`
                 SET `".$colBalance."` = `".$colBalance."` - :coste
                 WHERE `id` = :uid
                   AND `".$colBalance."` >= :coste2",
                [':coste' => $costeFallback, ':uid' => $userId, ':coste2' => $costeFallback]
            );
        }

        // 7) Refrescar $GLOBALS (regla de oro #19)
        $planetaNuevo = $db->selectSingle(
            "SELECT `metal`, `crystal`, `deuterium`
             FROM `" . $prefix . "planets`
             WHERE `id` = :pid AND `id_owner` = :uid",
            [':pid' => $planetId, ':uid' => $userId]
        );
        $userNuevo = $db->selectSingle(
            "SELECT `darkmatter`, `ntx20`, `untx20`
             FROM `" . $prefix . "users`
             WHERE `id` = :uid",
            [':uid' => $userId]
        );

        if (isset($GLOBALS['PLANET']) && is_array($GLOBALS['PLANET'])) {
            $GLOBALS['PLANET']['metal']     = (int) $planetaNuevo['metal'];
            $GLOBALS['PLANET']['crystal']   = (int) $planetaNuevo['crystal'];
            $GLOBALS['PLANET']['deuterium'] = (int) $planetaNuevo['deuterium'];
        }
        if (isset($GLOBALS['USER']) && is_array($GLOBALS['USER'])) {
            $GLOBALS['USER']['darkmatter'] = (int) $userNuevo['darkmatter'];
            $GLOBALS['USER']['ntx20']      = (int) $userNuevo['ntx20'];
            $GLOBALS['USER']['untx20']     = (int) $userNuevo['untx20'];
        }

        // 🆕 v2.4 — Mensaje con la moneda correcta
        if ($metodoPago === 'mo') {
            $msgPago = 'Pagado: ' . $costeMO . ' MO';
        } else {
            $msgPago = 'Pagado: ' . $costeFallback . ' ' . $moneda . ' (fallback)';
        }

        return [
            'ok'               => true,
            'msg'              => 'Intercambio realizado. ' . $msgPago,
            'cantidad_dar'     => $cantidadDar,
            'cantidad_recibir' => $cantidadRecibir,
            'metodo'           => $metodoPago,
            'moneda'           => $moneda,
        ];
    }
}