<?php
/**
 * La Cueva Pirata - Controlador del Mercado (Hub)
 * URL: game.php?page=cueva
 * AstroIO 2026
 */

if (!defined('MODE')) { die('Hacking attempt'); }

// --- Cargar el Helper manualmente ---
require_once 'includes/classes/CuevaHelper.class.php';

class ShowCuevaPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER, $LNG;

        $db = Database::get();
        $p  = DB_PREFIX;

        // ============================================================
        // DETECTAR RIEL Y SALDOS DEL JUGADOR
        // ============================================================
        $user = $db->selectSingle(
            "SELECT id, username, ntx20, untx20, darkmatter, metodo_retiro
             FROM `{$p}users` WHERE id = :uid LIMIT 1",
            [':uid' => $USER['id']]
        );
        
        if (!$user) {
            $this->printMessage('Usuario invalido', 'Error', 'game.php?page=overview');
            return;
        }

        $riel = CuevaHelper::detectarRiel($user);

        // Saldo del riel del jugador (NTX o UNTX)
        $saldoRiel = ($riel['metodo'] === 'QVAPAY')
            ? (int)$user['untx20']
            : (int)$user['ntx20'];

        // Saldo de recursos
        $saldoDarkmatter = (int)$user['darkmatter'];

        // ============================================================
        // ASIGNAR VARIABLES AL TEMPLATE DEL HUB
        // ============================================================
        $this->tplObj->assign_vars([
            'player_id'        => (int)$USER['id'],
            'player_name'      => $user['username'],
            'moneda_riel'      => $riel['etiqueta'],       
            'saldo_riel'       => $saldoRiel,
            'saldo_darkmatter' => $saldoDarkmatter,
        ]);

        $this->display('page.cueva.hub.tpl');
    }
}
?>