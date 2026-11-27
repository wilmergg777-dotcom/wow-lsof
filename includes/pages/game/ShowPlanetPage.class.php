<?php

/**
 * AstroIO - Sistema Planetario
 * ShowPlanetPage.class.php
 *
 * Controlador del módulo Planetario.
 * URL: game.php?page=planet
 *
 * AstroIO-FIX v3.8 (2026-10-13):
 *  - Detección de `has_moon`: si el planeta ya tiene luna,
 *    se pasa al template y el botón "Crear Luna" se oculta.
 *
 * AstroIO v4.0 (2026-10-30) - DUAL RIEL:
 *  - Detecta si el jugador es CUP (NTX-20) o QVAPAY (UNTX-20).
 *  - Pasa al template $moneda, $moneda_fiat, $es_internacional, $saldo_actual.
 *  - Pasa precios YA CALCULADOS (base × 2 si QVAPAY) para que el template
 *    NUNCA multiplique y NUNCA muestre la moneda del otro riel.
 *  - Mensajes de éxito con la moneda dinámica.
 *  - Eliminada la variable legacy $user_ntx20 (hardcodeaba NTX-20).
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

require_once ROOT_PATH.'includes/classes/PlanetHelper.class.php';

class ShowPlanetPage extends AbstractGamePage
{
    public $requireModule = MODULE_PLANET;
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER, $PLANET, $LNG;

        $userId   = (int) $USER['id'];
        $planetId = (int) $PLANET['id'];

        $message = '';
        $error   = '';

        // ==========================================
        // 🆕 v4.0 — DETECTAR RIEL DEL JUGADOR
        // ==========================================
        $isIntl      = PlanetHelper::isIntl($userId);
        $moneda      = $isIntl ? 'UNTX-20' : 'NTX-20';
        $monedaFiat  = $isIntl ? 'USD'     : 'CUP';
        $saldoActual = $isIntl ? (int) ($USER['untx20'] ?? 0) : (int) ($USER['ntx20'] ?? 0);

        // ==========================================
        // PROCESAR ACCIONES (POST)
        // ==========================================
        if (!empty($_POST)) {
            $mode = HTTP::_GP('mode', '');

            try {
                switch ($mode) {
                    case 'buyBuilder':
                        $price = PlanetHelper::buyBuilder($userId, $planetId);
                        $message = 'Droide Constructor clonado con exito (-'.number_format($price).' '.$moneda.').';
                        break;

                    case 'buyEngineer':
                        $price = PlanetHelper::buyEngineer($userId, $planetId);
                        $message = 'Droide Ingeniero clonado con exito (-'.number_format($price).' '.$moneda.').';
                        break;

                    case 'createMoon':
                        $diameter = PlanetHelper::createMoon($userId, $planetId);
                        $message = 'Luna creada con exito. Diametro: '.number_format($diameter).'.';
                        break;

                    case 'increaseFields':
                        $amount = (int) HTTP::_GP('amount', 0);
                        $cost   = PlanetHelper::increaseFields($userId, $planetId, $amount);
                        $message = '+'.$amount.' campos anadidos (-'.number_format($cost).' MO).';
                        break;

                    case 'increaseDiameter':
                        $amount = (int) HTTP::_GP('amount', 0);
                        $cost   = PlanetHelper::increaseDiameter($userId, $planetId, $amount);
                        $message = '+'.$amount.' diametro anadido (-'.number_format($cost).' MO).';
                        break;

                    case 'teleport':
                        $g = (int) HTTP::_GP('galaxy', 1);
                        $s = (int) HTTP::_GP('system', 1);
                        $p = (int) HTTP::_GP('planet', 1);
                        PlanetHelper::teleport($userId, $planetId, $g, $s, $p);
                        $message = 'Planeta teletransportado a ['.$g.':'.$s.':'.$p.'].';
                        break;

                    case 'rename':
                        $newName   = HTTP::_GP('new_name', '');
                        $finalName = PlanetHelper::rename($userId, $planetId, $newName);
                        $message   = 'Planeta renombrado a "'.$finalName.'".';
                        break;

                    case 'generateName':
                        header('Content-Type: application/json');
                        echo json_encode(['name' => PlanetHelper::generateName()]);
                        exit;

                    case 'abandon':
                        PlanetHelper::abandon($userId, $planetId);
                        HTTP::redirectTo('game.php?page=overview');
                        exit;
                }
            } catch (Exception $e) {
                $error = $e->getMessage();
            }

            // 🆕 v4.0 — Refrescar saldo tras acción exitosa
            // (El Helper ya actualizó $GLOBALS['USER'], pero re-leemos por seguridad)
            if (empty($error)) {
                $saldoActual = $isIntl ? (int) ($USER['untx20'] ?? 0) : (int) ($USER['ntx20'] ?? 0);
            }
        }

        // ==========================================
        // CARGAR DATOS ACTUALES
        // ==========================================
        $planet = PlanetHelper::getPlanet($planetId);

        // ==========================================
        // v3.8 — Detectar si el planeta YA tiene luna
        // ==========================================
        $hasMoon = false;
        if ((int) $planet['planet_type'] === 1) {
            $db = Database::get();
            $moonCheck = $db->selectSingle(
                "SELECT id FROM `".DB_PREFIX."planets` 
                 WHERE galaxy = :g AND system = :s AND planet = :p 
                   AND planet_type = '3'",
                [
                    ':g' => $planet['galaxy'],
                    ':s' => $planet['system'],
                    ':p' => $planet['planet']
                ]
            );
            $hasMoon = !empty($moonCheck);
        }

        // ==========================================
        // PRECIOS BASE (siempre en CUP / NTX-20)
        // ==========================================
        $nextBuilderLevel  = (int) $planet['droids_builder'] + 1;
        $nextEngineerLevel = (int) $planet['droids_engineer'] + 1;

        $builderPriceBase  = ($nextBuilderLevel  <= PlanetHelper::BUILDER_MAX)  ? (int) PlanetHelper::BUILDER_PRICES[$nextBuilderLevel]  : null;
        $engineerPriceBase = ($nextEngineerLevel <= PlanetHelper::ENGINEER_MAX) ? (int) PlanetHelper::ENGINEER_PRICES[$nextEngineerLevel] : null;
        $moonPriceBase     = (int) PlanetHelper::MOON_PRICE_NTX;

        // 🆕 v4.0 — PRECIOS FINALES (×2 si QVAPAY)
        $mult               = $isIntl ? (int) PlanetHelper::UNTX_MULTIPLIER : 1;
        $builderPriceFinal  = ($builderPriceBase  !== null) ? (int) ($builderPriceBase  * $mult) : null;
        $engineerPriceFinal = ($engineerPriceBase !== null) ? (int) ($engineerPriceBase * $mult) : null;
        $moonPriceFinal     = (int) ($moonPriceBase * $mult);

        // Cooldowns
        $teleportCd = max(0, PlanetHelper::TELEPORT_COOLDOWN - (TIMESTAMP - (int) $planet['last_teleport']));
        $renameCd   = max(0, PlanetHelper::RENAME_COOLDOWN   - (TIMESTAMP - (int) $planet['last_rename']));

        // Colas actuales
        $buildQueues = PlanetHelper::getBuildQueues($planet);
        $techQueues  = PlanetHelper::getTechQueues($planet);

        $this->assign([
            // Datos del planeta
            'planet_name'      => $planet['name'],
            'planet_id'        => $planetId,
            'planet_type'      => (int) $planet['planet_type'],
            'planet_galaxy'    => $planet['galaxy'],
            'planet_system'    => $planet['system'],
            'planet_planet'    => $planet['planet'],
            'planet_diameter'  => (int) $planet['diameter'],
            'planet_fields'    => (int) $planet['field_max'],

            // v3.8 — ¿Ya tiene luna?
            'has_moon'         => $hasMoon,

            // 🆕 v4.0 — DUAL RIEL (variables canónicas)
            'moneda'           => $moneda,           // 'NTX-20' | 'UNTX-20'
            'moneda_fiat'      => $monedaFiat,       // 'CUP' | 'USD'
            'es_internacional' => $isIntl,           // bool
            'saldo_actual'     => $saldoActual,      // int — saldo en la moneda del riel

            // Recursos del jugador (MO — sin cambios)
            'user_mo'          => (int) $USER['darkmatter'],

            // Droides
            'droid_builder'    => (int) $planet['droids_builder'],
            'droid_engineer'   => (int) $planet['droids_engineer'],
            'builder_max'      => PlanetHelper::BUILDER_MAX,
            'engineer_max'     => PlanetHelper::ENGINEER_MAX,
            'builder_price'    => $builderPriceFinal,   // ⚠️ YA multiplicado por ×2 si QVAPAY
            'engineer_price'   => $engineerPriceFinal,  // ⚠️ YA multiplicado por ×2 si QVAPAY
            'build_queues'     => $buildQueues,
            'tech_queues'      => $techQueues,

            // Precios MO (sin cambios — MO no se ve afectado por el riel)
            'moon_price'       => $moonPriceFinal,      // ⚠️ YA multiplicado por ×2 si QVAPAY
            'field_price'      => PlanetHelper::FIELD_PRICE_MO,
            'diameter_price'   => PlanetHelper::DIAMETER_PRICE_MO,
            'teleport_price'   => PlanetHelper::TELEPORT_PRICE_MO,
            'field_max'        => PlanetHelper::FIELD_MAX,
            'diameter_max'     => PlanetHelper::DIAMETER_MAX,

            // Cooldowns
            'teleport_cd'      => $teleportCd,
            'rename_cd'        => $renameCd,

            // Mensajes
            'message'          => $message,
            'error'            => $error,
        ]);

        $this->display('page.planet.default.tpl');
    }
}