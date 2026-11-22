<?php
/**
 * ShowResourceTraderPage
 * URL: game.php?page=resourceTrader
 *
 * Controller del Comerciante de Recursos (AstroIO)
 * Conectado a ResourceTraderHelper + VIPHelper
 *
 * v2.3 — Añadido cálculo de equivalencia entera (Opción C)
 *         para mostrar "X Metal = Y Cristal" en el selector.
 *
 * v2.4 — DOBLE RIEL: Si el jugador es QVAPAY, el costo del comerciante
 *         se duplica (x2) y se descuenta de UNTX-20. El icono sigue 💲.
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

require_once 'includes/classes/VIPHelper.class.php';
require_once 'includes/classes/ResourceTraderHelper.class.php';

class ShowResourceTraderPage extends AbstractGamePage
{
    // ============================================
    // FIX CRITICO: El router de game.php lee "mode"
    // del POST (doTrade). Como no existe el metodo
    // doTrade() en esta clase, el router necesita
    // defaultController para saber a donde ir.
    // ============================================
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    /**
     * 🆕 v2.4 — Detecta el método de pago del jugador ('CUP' o 'QVAPAY').
     */
    private function getPlayerMethod($userId): string
    {
        $db = Database::get();
        $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';

        try {
            $row = $db->selectSingle(
                "SELECT metodo_retiro FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
                [':uid' => (int)$userId]
            );
            return ($row && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
        } catch (Exception $e) {
            return 'CUP';
        }
    }

    /**
     * 🆕 v2.4 — Lee el saldo correcto (ntx20 o untx20) según el método.
     */
    private function getBalanceByMethod($userId, $method): int
    {
        $db = Database::get();
        $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
        $col = ($method === 'QVAPAY') ? 'untx20' : 'ntx20';

        try {
            $row = $db->selectSingle(
                "SELECT `".$col."` AS saldo FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
                [':uid' => (int)$userId]
            );
            return $row ? (int)$row['saldo'] : 0;
        } catch (Exception $e) {
            return 0;
        }
    }

    public function show(): void
    {
        global $USER, $PLANET;

        $mensaje = '';
        $tipo    = '';

        $preseleccionDar = HTTP::_GP('dar', '');
        $recursosValidos = ['metal', 'crystal', 'deuterium'];
        if (!in_array($preseleccionDar, $recursosValidos, true)) {
            $preseleccionDar = '';
        }

        // 🆕 v2.4 — Detectar método y moneda
        $method = $this->getPlayerMethod((int) $USER['id']);
        $moneda = ($method === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';
        $isInternational = ($method === 'QVAPAY');

        if (isset($_POST['mode']) && $_POST['mode'] === 'doTrade') {
            $resultado = ResourceTraderHelper::ejecutarIntercambio(
                (int) $USER['id'],
                (int) $PLANET['id'],
                isset($_POST['dar'])      ? (string) $_POST['dar']      : '',
                isset($_POST['recibir'])  ? (string) $_POST['recibir']  : '',
                isset($_POST['cantidad']) ? (int)    $_POST['cantidad'] : 0
            );

            $mensaje = $resultado['msg'];
            $tipo    = $resultado['ok'] ? 'success' : 'error';

            $darPost = isset($_POST['dar']) ? (string) $_POST['dar'] : '';
            if (in_array($darPost, $recursosValidos, true)) {
                $preseleccionDar = $darPost;
            }
        }

        $recursos = ResourceTraderHelper::getRecursosActuales(
            (int) $USER['id'],
            (int) $PLANET['id']
        );

        $costeMO = ResourceTraderHelper::getCosteMO((int) $USER['id']);
        $descVip = ResourceTraderHelper::getVipDiscount((int) $USER['id']);

        // 🆕 v2.4 — Costo base y costo final ajustado al doble riel
        $costeBase   = (int) ResourceTraderHelper::COSTE_NTX20;
        $costeFinal  = $isInternational ? ($costeBase * 2) : $costeBase;
        $saldoActual = $this->getBalanceByMethod((int) $USER['id'], $method);

        // ============================================
        // RECURSOS A ENTREGAR (Dar)
        // ============================================
        $recursosDar = [];
        foreach (ResourceTraderHelper::getRecursosDar() as $r) {
            $recursosDar[] = [
                'id'       => $r,
                'nombre'   => ResourceTraderHelper::getNombre($r),
                'cantidad' => $recursos[$r] ?? 0,
            ];
        }

        // ============================================
        // RECURSOS A RECIBIR (Recibir)
        // v2.3: Añadido cálculo de equivalencia entera
        //       para mostrar "X Metal = Y Cristal"
        // ============================================
        $recursosRecibir = [];
        foreach (ResourceTraderHelper::getRecursosDar() as $dar) {
            foreach (ResourceTraderHelper::getRecursosRecibir($dar) as $rec) {

                $tasa = ResourceTraderHelper::getTasa($dar, $rec);

                // Calcular "X de [dar] = Y de [rec]" con enteros
                // Ejemplo tasa 0.25 → 4 de dar = 1 de recibir
                // Ejemplo tasa 4.0  → 1 de dar = 4 de recibir
                if ($tasa >= 1) {
                    $cuentaDar     = 1;
                    $cuentaRecibir = (int) round($tasa);
                } else {
                    $cuentaDar     = (int) round(1 / $tasa);
                    $cuentaRecibir = 1;
                }

                $recursosRecibir[] = [
                    'id'             => $rec,
                    'nombre'         => ResourceTraderHelper::getNombre($rec),
                    'dar'            => $dar,
                    'dar_nombre'     => ResourceTraderHelper::getNombre($dar),
                    'tasa'           => $tasa,
                    'cuenta_dar'     => $cuentaDar,
                    'cuenta_recibir' => $cuentaRecibir,
                ];
            }
        }

        $this->assign([
            'planet_name'      => isset($PLANET['name']) ? $PLANET['name'] : 'Actual',
            'coste_mo'         => $costeMO,
            'coste_mo_base'    => ResourceTraderHelper::COSTE_MO_BASE,

            // 🆕 v2.4 — Costo ajustado y moneda dinámica
            'coste_ntx20'      => $costeFinal,
            'coste_base'       => $costeBase,

            'descuento_vip'    => $descVip,
            'recursos'         => $recursos,
            'mo_actual'        => $recursos['darkmatter'],

            // 🆕 v2.4 — Saldo correcto según método
            'ntx_actual'       => $saldoActual,

            // 🆕 v2.4 — Etiqueta de moneda y método
            'moneda'           => $moneda,
            'metodo_retiro'    => $method,
            'es_internacional' => $isInternational,

            'recursos_dar'     => $recursosDar,
            'recursos_recibir' => $recursosRecibir,
            'mensaje'          => $mensaje,
            'mensaje_tipo'     => $tipo,
            'preseleccion_dar' => $preseleccionDar,
            'tasas_json'       => json_encode(ResourceTraderHelper::getTodasLasTasas()),
            'recursos_json'    => json_encode([
                'metal'     => $recursos['metal'],
                'crystal'   => $recursos['crystal'],
                'deuterium' => $recursos['deuterium'],
            ]),
            'nombres_json'     => json_encode(ResourceTraderHelper::getNombres()),
        ]);

        $this->display('page.resourcetrader.default.tpl');
    }
}