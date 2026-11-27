<?php
/**
 * ShowRafflesPage.class.php
 * Pagina del jugador - Sistema de Rifas
 * AstroIO v3.0 (DUAL RIEL)
 *
 * v3.0 (2026-10-30) - DUAL RIEL:
 *  - Detecta el riel del jugador (CUP / QVAPAY) en todas las vistas.
 *  - Pasa al template: $moneda, $moneda_fiat, $es_internacional, $saldo_actual.
 *  - Pasa $userId a getActive/getFinished/getById para que ajusten
 *    el precio_boleto_real y premio_texto segun el riel.
 *  - verRifa(): compara $miSaldo contra $raffle['precio_boleto_real']
 *    (ya ajustado al riel) en lugar del precio base.
 *  - comprarBoleto(): mensaje de exito robusto (acepta 'NTX-20'/'ntx20').
 *  - misBoletos(): añade 'moneda_pagada_label' a cada ticket.
 *  - NOTA: El Helper RaffleHelper v3.0 ya devuelve los precios ajustados
 *    y los premios con la moneda correcta.
 */

if (!defined('MODE')) {
    exit;
}

require_once 'includes/classes/RaffleHelper.class.php';

class ShowRafflesPage extends AbstractGamePage
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
            case 'view':        $this->verRifa();        break;
            case 'comprar':     $this->comprarBoleto();  break;
            case 'misBoletos':  $this->misBoletos();     break;
            default:            $this->listaSorteos();   break;
        }
    }

    /**
     * 🆕 v3.0 — Añade las variables canónicas del riel al array de assign.
     */
    private function addRielVars($userId)
    {
        $riel = RaffleHelper::getRielInfo($userId);
        return [
            'moneda'           => $riel['moneda'],           // 'NTX-20' | 'UNTX-20'
            'moneda_fiat'      => $riel['monedaFiat'],       // 'CUP' | 'USD'
            'es_internacional' => $riel['isIntl'],
            'saldo_actual'     => $riel['saldo'],            // int
            'multiplier'       => $riel['multiplier'],       // 1 | 2
        ];
    }

    /**
     * Lista de rifas activas + finalizadas
     */
    private function listaSorteos()
    {
        $userId = (int)$GLOBALS['USER']['id'];

        // 🆕 v3.0 — Pasar $userId para que ajuste precio_boleto_real
        $rafflesActivas     = RaffleHelper::getActive(50, 0, $userId);
        $rafflesFinalizadas = RaffleHelper::getFinished(20, 0, $userId);

        $assign = array_merge([
            'raffles_activas'     => $rafflesActivas,
            'raffles_finalizadas' => $rafflesFinalizadas,
            'hay_activas'         => count($rafflesActivas) > 0,
            'hay_finalizadas'     => count($rafflesFinalizadas) > 0,
            'msg'                 => isset($_SESSION['raffle_msg']) ? $_SESSION['raffle_msg'] : '',
            'msg_type'            => isset($_SESSION['raffle_msg_type']) ? $_SESSION['raffle_msg_type'] : 'info',
        ], $this->addRielVars($userId));

        $this->assign($assign);

        unset($_SESSION['raffle_msg']);
        unset($_SESSION['raffle_msg_type']);

        $this->display('page.raffles.default.tpl');
    }

    /**
     * Ver detalle de una rifa
     */
    private function verRifa()
    {
        $raffleId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($raffleId <= 0) {
            $this->redirectTo('game.php?page=raffles');
            return;
        }

        $userId = (int)$GLOBALS['USER']['id'];

        // 🆕 v3.0 — Pasar $userId para que ajuste precios y textos
        $raffle = RaffleHelper::getById($raffleId, $userId);
        if (!$raffle) {
            $_SESSION['raffle_msg'] = 'La rifa no existe';
            $_SESSION['raffle_msg_type'] = 'error';
            $this->redirectTo('game.php?page=raffles');
            return;
        }

        $miBoleto = RaffleHelper::hasTicket($raffleId, $userId);
        $miSaldo  = RaffleHelper::getSaldoJugador($userId, $raffle['moneda']);

        // 🆕 v3.0 — Comparar contra precio_boleto_real (ya ajustado al riel)
        $precioReal = isset($raffle['precio_boleto_real'])
            ? (int)$raffle['precio_boleto_real']
            : (int)$raffle['precio_boleto'];

        $puedeComprar = ($raffle['estado'] === 'activo')
                     && ($raffle['fecha_fin'] > time())
                     && ($raffle['boletos_vendidos'] < $raffle['max_boletos'])
                     && (!$miBoleto)
                     && ($miSaldo >= $precioReal);

        $tickets = RaffleHelper::getTicketsByRaffle($raffleId);

        // Los premios ya incluyen 'ganador_username' desde el Helper v2.5
        $ganadores = [];
        if (is_array($raffle['premios'])) {
            foreach ($raffle['premios'] as $premio) {
                if (!empty($premio['ganador_id'])) {
                    $ganadores[] = $premio;
                }
            }
        }

        // ✅ v4.0 — Agrupar premios por LUGAR: varios premios del mismo
        // lugar se muestran juntos (todos pertenecen al mismo ganador).
        $porLugar = [];
        if (is_array($raffle['premios'])) {
            foreach ($raffle['premios'] as $premio) {
                $lugar = ((int)$premio['lugar'] > 0) ? (int)$premio['lugar'] : (int)$premio['orden'];
                $porLugar[$lugar][] = $premio;
            }
        }
        ksort($porLugar);
        $premiosPorLugar = [];
        $ganadoresPorLugar = [];
        foreach ($porLugar as $lugar => $premiosLugar) {
            $first = $premiosLugar[0];
            $textos = [];
            foreach ($premiosLugar as $pl) {
                $textos[] = $pl['texto'];
            }
            $grupo = [
                'lugar'            => $lugar,
                'cantidad_premios' => count($premiosLugar),
                'textos'           => $textos,
                'ganador_id'       => isset($first['ganador_id']) ? $first['ganador_id'] : 0,
                'ganador_username' => isset($first['ganador_username']) ? $first['ganador_username'] : '',
                'boleto_ganador'   => isset($first['boleto_ganador']) ? $first['boleto_ganador'] : 0,
            ];
            $premiosPorLugar[] = $grupo;
            if ($grupo['ganador_id']) {
                $ganadoresPorLugar[] = $grupo;
            }
        }

        $assign = array_merge([
            'raffle'            => $raffle,
            'raffle_premios'    => $raffle['premios'],
            'raffle_premios_por_lugar' => $premiosPorLugar,   // ✅ v4.0
            'raffle_ganadores_por_lugar' => $ganadoresPorLugar, // ✅ v4.0
            'raffle_ganadores'  => $ganadores,
            'raffle_tickets'    => $tickets,
            'hay_ganadores'     => count($ganadores) > 0,
            'mi_boleto'         => $miBoleto,
            'mi_saldo'          => $miSaldo,
            'puede_comprar'     => $puedeComprar,
            'precio_real'       => $precioReal,          // 🆕 v3.0 — precio ajustado
            'msg'               => isset($_SESSION['raffle_msg']) ? $_SESSION['raffle_msg'] : '',
            'msg_type'          => isset($_SESSION['raffle_msg_type']) ? $_SESSION['raffle_msg_type'] : 'info',
            'token'             => $this->generateToken(),
            'time_now'          => time(),
        ], $this->addRielVars($userId));

        $this->assign($assign);

        unset($_SESSION['raffle_msg']);
        unset($_SESSION['raffle_msg_type']);

        $this->display('page.raffles.view.tpl');
    }

    /**
     * Comprar boleto (POST)
     */
    private function comprarBoleto()
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirectTo('game.php?page=raffles');
            return;
        }

        if (!$this->validateToken(isset($_POST['token']) ? $_POST['token'] : '')) {
            $_SESSION['raffle_msg'] = 'Token invalido, intenta de nuevo';
            $_SESSION['raffle_msg_type'] = 'error';
            $this->redirectTo('game.php?page=raffles');
            return;
        }

        $raffleId = isset($_POST['id']) ? (int)$_POST['id'] : 0;
        $userId   = (int)$GLOBALS['USER']['id'];
        $ip       = isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null;

        $result = RaffleHelper::buyTicket($raffleId, $userId, $ip);

        if ($result['ok']) {
            // 🆕 v3.0 — Manejo robusto del label de moneda
            // El Helper puede devolver:
            //   - 'NTX-20' / 'UNTX-20' (label listo si moneda era ntx20)
            //   - 'metal' / 'crystal' / 'deuterium' / 'darkmatter' (código)
            $monedaStr = isset($result['moneda']) ? (string)$result['moneda'] : 'ntx20';

            if (in_array($monedaStr, ['NTX-20', 'UNTX-20'], true)) {
                $monedaLabel = $monedaStr;
            } else {
                $info = RaffleHelper::getMonedaInfo($monedaStr, $userId);
                $monedaLabel = $info['nombre'];
            }

            $_SESSION['raffle_msg'] = 'Compraste el boleto #' . $result['boleto']
                                    . ' por ' . number_format((int)$result['precio'])
                                    . ' ' . $monedaLabel;
            $_SESSION['raffle_msg_type'] = 'success';
        } else {
            $_SESSION['raffle_msg'] = $result['msg'];
            $_SESSION['raffle_msg_type'] = 'error';
        }

        $this->redirectTo('game.php?page=raffles&mode=view&id=' . $raffleId);
    }

    /**
     * Mis boletos
     */
    private function misBoletos()
    {
        $userId  = (int)$GLOBALS['USER']['id'];
        $tickets = RaffleHelper::getTicketsByUser($userId);

        // 🆕 v3.0 — Añadir label de moneda a cada ticket
        // 'moneda_pagada' puede ser: 'metal', 'crystal', 'deuterium',
        // 'darkmatter', 'ntx20', 'untx20'
        $mapMoneda = [
            'metal'      => 'Metal',
            'crystal'    => 'Cristal',
            'deuterium'  => 'Deuterio',
            'darkmatter' => 'Materia Oscura',
            'ntx20'      => 'NTX-20',
            'untx20'     => 'UNTX-20',
        ];

        if (is_array($tickets)) {
            foreach ($tickets as &$t) {
                $mp = isset($t['moneda_pagada']) ? (string)$t['moneda_pagada'] : '';
                $t['moneda_pagada_label'] = isset($mapMoneda[$mp]) ? $mapMoneda[$mp] : $mp;
            }
            unset($t);
        }

        $assign = array_merge([
            'tickets'     => $tickets,
            'hay_tickets' => (is_array($tickets) && count($tickets) > 0),
        ], $this->addRielVars($userId));

        $this->assign($assign);

        $this->display('page.raffles.misboletos.tpl');
    }

    /**
     * Generar token anti-CSRF
     */
    private function generateToken()
    {
        if (!isset($_SESSION['raffle_token'])) {
            $_SESSION['raffle_token'] = bin2hex(random_bytes(16));
        }
        return $_SESSION['raffle_token'];
    }

    /**
     * Validar token anti-CSRF
     */
    private function validateToken($token)
    {
        return isset($_SESSION['raffle_token'])
            && hash_equals($_SESSION['raffle_token'], $token);
    }
}