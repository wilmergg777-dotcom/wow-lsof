<?php
/**
 * ShowLotteryPage.class.php
 * Pagina del jugador - Sistema de Loteria
 * AstroIO v3.0 (DUAL RIEL)
 *
 * v3.0 (2026-10-30) - DUAL RIEL:
 *  - Detecta el riel del jugador (CUP / QVAPAY) en todas las vistas.
 *  - Pasa al template: $moneda, $moneda_fiat, $es_internacional, $saldo_actual, $multiplier.
 *  - Pasa $userId a getCurrentDraw/getDraws para que devuelvan
 *    jackpot_display y precio_display ya ajustados al riel.
 *  - index(): calcula $precio_real (base + VIP + ×2 si QVAPAY) para
 *    que la vista muestre el precio exacto que pagará el jugador.
 *  - $puedeComprar compara contra $precio_real (no contra config base).
 *  - comprarTicket(): mensaje de éxito con $result['moneda'].
 *  - misTickets(): añade moneda_pagada_label y precio_pagado_display
 *    a cada ticket (moneda_pagada = riel del jugador; precio ×2 si QVAPAY).
 *  - historial(): pasa $userId a getDraws.
 *  - El Helper ya devuelve los valores en la moneda correcta.
 */

if (!defined('MODE')) {
    exit;
}

require_once 'includes/classes/LotteryHelper.class.php';

class ShowLotteryPage extends AbstractGamePage
{
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        $modo = isset($_GET['mode']) ? $_GET['mode'] : 'lista';

        switch ($modo) {
            case 'buy':        $this->comprarTicket();  break;
            case 'myTickets':  $this->misTickets();     break;
            case 'history':    $this->historial();      break;
            default:           $this->index();          break;
        }
    }

    /**
     * 🆕 v3.0 — Añade variables canónicas del riel.
     */
    private function addRielVars($userId)
    {
        $riel = LotteryHelper::getRielInfo($userId);
        return [
            'moneda'           => $riel['moneda'],
            'moneda_fiat'      => $riel['monedaFiat'],
            'es_internacional' => $riel['isIntl'],
            'saldo_actual'     => $riel['saldo'],
            'multiplier'       => $riel['multiplier'],
        ];
    }

    /**
     * Vista principal: sorteo actual + historial breve
     */
    private function index()
    {
        $userId = (int)$GLOBALS['USER']['id'];

        $config = LotteryHelper::getConfig();

        // 🆕 v3.0 — Pasar $userId para que hydrateDraw() devuelva display
        $draw = LotteryHelper::getCurrentDraw($userId);

        $miSaldo      = 0;
        $misTickets   = [];
        $puedeComprar = false;
        $precioReal   = 0;
        $precioBase   = 0;

        if ($config) {
            // 🆕 v3.0 — Saldo del riel
            $miSaldo = LotteryHelper::getSaldoJugador($userId);

            // 🆕 v3.0 — Calcular precio real (con VIP + ×2 si QVAPAY)
            $precioBase = (int)$config['precio_ticket'];

            // Aplicar descuento VIP si aplica
            $isVip = false;
            try {
                $db     = Database::get();
                $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
                $vipRow = $db->selectSingle(
                    "SELECT COUNT(*) as t FROM `".$prefix."users_vip` 
                     WHERE user_id = :uid AND vip_active = 1 AND vip_end > :ahora",
                    [':uid' => $userId, ':ahora' => time()]
                );
                $isVip = isset($vipRow['t']) && (int)$vipRow['t'] > 0;
            } catch (Exception $e) {
                $isVip = false;
            }

            if ($isVip && (int)$config['descuento_vip'] > 0) {
                $precioBase = (int)round($precioBase * (1 - (int)$config['descuento_vip'] / 100));
            }

            // 🆕 v3.0 — ×2 si QVAPAY
            $precioReal = LotteryHelper::getPrecioParaJugador($precioBase, $userId);
        }

        if ($draw && $config) {
            $misTickets = LotteryHelper::getTicketsByUserAndDraw($userId, $draw['id']);

            // 🆕 v3.0 — Comparar contra $precioReal
            $puedeComprar = (count($misTickets) < (int)$config['max_tickets_por_jugador'])
                         && ($draw['tickets_vendidos'] < (int)$config['max_tickets_totales'])
                         && ($miSaldo >= $precioReal)
                         && ($draw['fecha_sorteo'] > time());
        }

        // 🆕 v3.0 — Pasar $userId a getDraws
        $ultimosSorteos = LotteryHelper::getDraws(5, 0, $userId);

        $sorteoAnterior = null;
        foreach ($ultimosSorteos as $s) {
            if ($s['estado'] === 'sorteado' && !empty($s['numeros_sorteados'])) {
                $sorteoAnterior = $s;
                break;
            }
        }

        $fechaSorteoFmt = '';
        if ($draw) {
            $fechaSorteoFmt = date('d/m/Y H:i', $draw['fecha_sorteo']);
        }

        $assign = array_merge([
            'config'            => $config,
            'draw'              => $draw,
            'hay_sorteo'        => ($draw !== null),
            'mi_saldo'          => $miSaldo,
            'mis_tickets'       => $misTickets,
            'mis_tickets_count' => count($misTickets),
            'puede_comprar'     => $puedeComprar,

            // 🆕 v3.0 — Precios ajustados al riel
            'precio_base'       => $precioBase,
            'precio_real'       => $precioReal,

            'ultimos_sorteos'   => $ultimosSorteos,
            'hay_historial'     => count($ultimosSorteos) > 0,
            'sorteo_anterior'   => $sorteoAnterior,
            'hay_anterior'      => ($sorteoAnterior !== null),
            'fecha_sorteo_fmt'  => $fechaSorteoFmt,
            'msg'               => isset($_SESSION['lot_msg']) ? $_SESSION['lot_msg'] : '',
            'msg_type'          => isset($_SESSION['lot_msg_type']) ? $_SESSION['lot_msg_type'] : 'info',
            'token'             => $this->generateToken(),
            'time_now'          => time(),
        ], $this->addRielVars($userId));

        $this->assign($assign);

        unset($_SESSION['lot_msg']);
        unset($_SESSION['lot_msg_type']);

        $this->display('page.lottery.default.tpl');
    }

    /**
     * Comprar ticket (POST)
     */
    private function comprarTicket()
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirectTo('game.php?page=lottery');
            return;
        }

        if (!$this->validateToken(isset($_POST['token']) ? $_POST['token'] : '')) {
            $_SESSION['lot_msg'] = 'Token invalido, intenta de nuevo';
            $_SESSION['lot_msg_type'] = 'error';
            $this->redirectTo('game.php?page=lottery');
            return;
        }

        $userId = (int)$GLOBALS['USER']['id'];
        $ip     = isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null;

        // 🆕 v3.0 — Pasar $userId
        $draw = LotteryHelper::getCurrentDraw($userId);
        if (!$draw) {
            $_SESSION['lot_msg'] = 'No hay sorteo activo';
            $_SESSION['lot_msg_type'] = 'error';
            $this->redirectTo('game.php?page=lottery');
            return;
        }

        $numeros = [];
        if (isset($_POST['numeros']) && is_array($_POST['numeros'])) {
            foreach ($_POST['numeros'] as $n) {
                $numeros[] = (int)$n;
            }
        }

        $config = LotteryHelper::getConfig();
        $cantidadEsperada = (int)$config['numeros_a_elegir'];

        if (count($numeros) !== $cantidadEsperada) {
            $_SESSION['lot_msg'] = 'Debes elegir exactamente ' . $cantidadEsperada . ' numeros';
            $_SESSION['lot_msg_type'] = 'error';
            $this->redirectTo('game.php?page=lottery');
            return;
        }

        $result = LotteryHelper::buyTicket($draw['id'], $userId, $numeros, $ip);

        if ($result['ok']) {
            // 🆕 v3.0 — Mensaje con moneda dinámica
            $moneda = isset($result['moneda']) ? $result['moneda'] : 'NTX-20';
            $_SESSION['lot_msg'] = 'Ticket comprado! Numeros: ' . $result['numeros']
                                 . ' - Pagaste: ' . number_format((int)$result['precio']) . ' ' . $moneda;
            $_SESSION['lot_msg_type'] = 'success';
        } else {
            $_SESSION['lot_msg'] = $result['msg'];
            $_SESSION['lot_msg_type'] = 'error';
        }

        $this->redirectTo('game.php?page=lottery');
    }

    /**
     * Mis tickets
     */
    private function misTickets()
    {
        $userId  = (int)$GLOBALS['USER']['id'];
        $tickets = LotteryHelper::getMyTickets($userId);

        $riel = LotteryHelper::getRielInfo($userId);

        // 🆕 v3.0 — Añadir moneda y precio display a cada ticket
        if (is_array($tickets)) {
            foreach ($tickets as &$t) {
                // La moneda_pagada = moneda del riel actual (metodo_retiro está bloqueado)
                $t['moneda_pagada_label'] = $riel['moneda'];

                // El precio_pagado ya es el que pagó (base o ×2 según riel)
                // Para mostrar el premio: el Helper guarda premio_ganado en BASE
                // y lo multiplica al entregar. Mostramos el premio que recibió:
                $premioBase = isset($t['premio_ganado']) ? (int)$t['premio_ganado'] : 0;
                if ($premioBase > 0) {
                    $t['premio_ganado_display'] = $riel['isIntl']
                        ? ($premioBase * $riel['multiplier'])
                        : $premioBase;
                } else {
                    $t['premio_ganado_display'] = 0;
                }
            }
            unset($t);
        }

        $ganadores = 0;
        if (is_array($tickets)) {
            foreach ($tickets as $t) {
                if (!empty($t['premio_ganado']) && $t['premio_ganado'] > 0) {
                    $ganadores++;
                }
            }
        }

        $assign = array_merge([
            'tickets'      => $tickets,
            'hay_tickets'  => count($tickets) > 0,
            'ganadores'    => $ganadores,
        ], $this->addRielVars($userId));

        $this->assign($assign);

        $this->display('page.lottery.mytickets.tpl');
    }

    /**
     * Historial de sorteos
     */
    private function historial()
    {
        $userId = (int)$GLOBALS['USER']['id'];

        // 🆕 v3.0 — Pasar $userId
        $sorteos = LotteryHelper::getDraws(20, 0, $userId);

        $assign = array_merge([
            'sorteos'      => $sorteos,
            'hay_sorteos'  => count($sorteos) > 0,
        ], $this->addRielVars($userId));

        $this->assign($assign);

        $this->display('page.lottery.history.tpl');
    }

    private function generateToken()
    {
        if (!isset($_SESSION['lot_token'])) {
            $_SESSION['lot_token'] = bin2hex(random_bytes(16));
        }
        return $_SESSION['lot_token'];
    }

    private function validateToken($token)
    {
        return isset($_SESSION['lot_token'])
            && hash_equals($_SESSION['lot_token'], $token);
    }
}