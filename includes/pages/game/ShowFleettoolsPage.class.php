<?php
/**
 * AstroIO v2.7 - ShowFleetToolsPage
 * Controlador de Herramientas de Flota
 *
 * NUEVO: Lee $_GET['vel'] para la velocidad de vuelo (1-10)
 * y la pasa al Helper para recalcular tiempo y consumo.
 *
 * NUEVO: reunirFlotas() ahora ENVÍA las flotas de verdad usando
 * FleetFunctions::sendFleet(). Los planetas sin suficiente deuterio
 * se saltan y sus naves se quedan en el planeta.
 *
 * NUEVO: reunirRecursos() ahora ENVÍA las naves de carga (202, 203, 217)
 * con los recursos al planeta actual.
 *
 * NUEVO: distribuirRecursos() ahora ENVÍA los recursos desde el planeta
 * actual a los planetas marcados.
 *
 * NUEVO: multiExpediciones() ahora ENVÍA X flotas a expedición (slot 16)
 * con las MISMAS naves en cada una. El consumo es por expedición.
 *
 * CORREGIDO: multiExpediciones() ya NO resta las naves manualmente.
 * sendFleet() las resta automáticamente. Solo restamos el deuterio.
 *
 * NUEVO: Verificacion de VIP activo para Multi-Expediciones.
 *
 * v2.7 (VIP SLOTS FIX):
 *  - show() y multiExpediciones() ahora usan
 *    FleetFunctions::getExpeditionLimit($USER) para calcular los slots
 *    de expedición, que YA incluye el bonus VIP (+1 o +2 según pack).
 *  - Antes se usaba floor(sqrt(tech124)) puro, ignorando el VIP.
 *  - El template ahora muestra los slots con VIP incluido.
 */
if (!defined('MODE')) exit;

require_once 'includes/classes/FleetToolsHelper.class.php';
require_once 'includes/classes/class.FleetFunctions.php';

class ShowFleetToolsPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER, $PLANET, $LNG;

        $tab = isset($_GET['tab']) ? $_GET['tab'] : 'dashboard';
        $validTabs = array('dashboard', 'reunir-flotas', 'reunir-recursos', 'distribuir', 'multi-exped');
        if (!in_array($tab, $validTabs)) {
            $tab = 'dashboard';
        }

        // Leer velocidad desde URL (default 10 = 100%)
        $velocidadActual = isset($_GET['vel']) ? (int)$_GET['vel'] : 10;
        if ($velocidadActual < 1 || $velocidadActual > 10) {
            $velocidadActual = 10;
        }

        // Datos comunes
        $navesCarga    = FleetToolsHelper::getShipsByType($PLANET, 'cargo');
        $navesExped    = FleetToolsHelper::getShipsByType($PLANET, 'exped');
        $todosPlanetas = FleetToolsHelper::getPlanetasConRecursos($USER['id']);
        $otrosPlanetas = FleetToolsHelper::getOtrosPlanetas($USER['id'], $PLANET['id']);

        // Planetas con naves desglosadas + tiempo + consumo (para Reunir Flotas)
        $planetasNaves = FleetToolsHelper::getPlanetasConNavesYTiempo(
            $USER['id'],
            $PLANET['id'],
            $USER,
            $velocidadActual
        );

        // Planetas con recursos + naves de carga + tiempo + consumo (para Reunir Recursos)
        $planetasRecursos = FleetToolsHelper::getPlanetasParaReunirRecursos(
            $USER['id'],
            $PLANET['id'],
            $USER,
            $velocidadActual
        );

        // Info para Distribuir Recursos (origen + destinos con tiempo y consumo)
        $distribuirInfo = FleetToolsHelper::getInfoParaDistribuir(
            $USER['id'],
            $PLANET['id'],
            $USER,
            $velocidadActual
        );

        // Info para Multi-Expediciones (slots + naves + tiempo/consumo base)
        $multiExpedInfo = FleetToolsHelper::getInfoParaMultiExpediciones(
            $USER['id'],
            $PLANET['id'],
            $USER,
            $velocidadActual
        );

        // ==========================================
        // VERIFICAR VIP ACTIVO (para Multi-Expediciones)
        // ==========================================
        $prefixVip = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
        $dbVip = Database::get();

        $vipActivo = false;
        try {
            $sqlVip = "SELECT `vip_active`, `vip_end` FROM `".$prefixVip."users_vip` WHERE `user_id` = :uid LIMIT 1";
            $vipData = $dbVip->selectSingle($sqlVip, array(':uid' => $USER['id']));

            if (!empty($vipData) && (int)$vipData['vip_active'] === 1 && (int)$vipData['vip_end'] > TIMESTAMP) {
                $vipActivo = true;
            }
        } catch (Exception $e) {
            // Si la tabla no existe, dejamos vip_activo = false
            $vipActivo = false;
        }

        // Totales Reunir Flotas
        $totalPlanetasNaves  = 0;
        $totalNavesGlobal    = 0;
        $totalConsumoGlobal  = 0;
        foreach ($planetasNaves as $pRow) {
            $totalPlanetasNaves++;
            $totalNavesGlobal   += (int)$pRow['total_naves'];
            $totalConsumoGlobal += (int)$pRow['consumo'];
        }

        // Totales Reunir Recursos
        $totalPlanetasRec    = 0;
        $totalRecMetal       = 0;
        $totalRecCrystal     = 0;
        $totalRecDeut        = 0;
        $totalRecNaves       = 0;
        $totalRecConsumo     = 0;
        foreach ($planetasRecursos as $pRow) {
            if ($pRow['es_destino']) {
                continue;
            }
            $totalPlanetasRec++;
            $totalRecMetal   += (int)$pRow['carga_metal'];
            $totalRecCrystal += (int)$pRow['carga_crystal'];
            $totalRecDeut    += (int)$pRow['carga_deuterium'];
            $totalRecNaves   += (int)$pRow['total_naves_carga'];
            $totalRecConsumo += (int)$pRow['consumo'];
        }

        // ============================================
        // ASTROIO v2.7 - Slots de expedicion CON VIP incluido
        // getExpeditionLimit() ya suma el bonus VIP (+1 o +2)
        // ============================================
        $maxSlotsShow = (int) FleetFunctions::getExpeditionLimit($USER);

        $dbShow   = Database::get();
        $usedShow = $dbShow->selectSingle(
            "SELECT COUNT(*) AS total FROM `".DB_PREFIX."fleets`
             WHERE `fleet_owner` = :uid AND `fleet_mission` = 15 AND `fleet_mess` = 0",
            array(':uid' => $USER['id'])
        );
        $usedSlotsShow = !empty($usedShow) ? (int)$usedShow['total'] : 0;
        $slotsLibres   = max(0, $maxSlotsShow - $usedSlotsShow);

        // Sobreescribir multi_exped_info para que el template muestre los valores con VIP
        if (is_array($multiExpedInfo)) {
            $multiExpedInfo['slots_max']    = $maxSlotsShow;
            $multiExpedInfo['slots_libres'] = $slotsLibres;
        }
        // ============================================
        // FIN ASTROIO v2.7
        // ============================================

        $favoritos     = FleetToolsHelper::getFavoritos($USER['id']);

        $this->assign(array(
            'tab_active'           => $tab,
            'naves_carga'          => $navesCarga,
            'naves_exped'          => $navesExped,
            'todos_planetas'       => $todosPlanetas,
            'otros_planetas'       => $otrosPlanetas,
            'planetas_naves'       => $planetasNaves,
            'total_planetas_naves' => $totalPlanetasNaves,
            'total_naves_global'   => $totalNavesGlobal,
            'total_consumo_global' => $totalConsumoGlobal,
            'planetas_recursos'    => $planetasRecursos,
            'total_planetas_rec'   => $totalPlanetasRec,
            'total_rec_metal'      => $totalRecMetal,
            'total_rec_crystal'    => $totalRecCrystal,
            'total_rec_deut'       => $totalRecDeut,
            'total_rec_naves'      => $totalRecNaves,
            'total_rec_consumo'    => $totalRecConsumo,
            'distribuir_info'      => $distribuirInfo,
            'multi_exped_info'     => $multiExpedInfo,
            'velocidad_actual'     => $velocidadActual,
            'slots_libres'         => $slotsLibres,
            'favoritos'            => $favoritos,
            'vip_activo'           => $vipActivo,
            'planeta_actual'       => array(
                'id'     => $PLANET['id'],
                'galaxy' => $PLANET['galaxy'],
                'system' => $PLANET['system'],
                'planet' => $PLANET['planet'],
                'name'   => $PLANET['name'],
            ),
        ));

        $this->display('page.fleettools.default.tpl');
    }

    // =====================================================
    // REUNIR FLOTAS
    // =====================================================

    public function reunirFlotas()
    {
        global $USER, $PLANET, $resource;

        $planetas  = isset($_POST['planetas']) ? (array)$_POST['planetas'] : array();
        $velocidad = isset($_POST['velocidad']) ? (int)$_POST['velocidad'] : 10;

        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }

        if (empty($planetas)) {
            $this->redirectTo('game.php?page=fleettools&tab=reunir-flotas&error=no_planetas');
            return;
        }

        $prefix = DB_PREFIX;
        $db     = Database::get();

        $destino = array(
            'id'     => (int)$PLANET['id'],
            'owner'  => (int)$USER['id'],
            'galaxy' => (int)$PLANET['galaxy'],
            'system' => (int)$PLANET['system'],
            'planet' => (int)$PLANET['planet'],
            'type'   => 1,
        );

        $flyableShipIds = array(202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 213, 214, 215, 219, 220);

        $shipColumns = array(
            'small_ship_cargo', 'big_ship_cargo', 'light_hunter', 'heavy_hunter',
            'crusher', 'battle_ship', 'colonizer', 'recycler', 'spy_sonde',
            'bomber_ship', 'solar_satelit', 'destructor', 'dearth_star',
            'battleship', 'giga_recykler', 'dm_ship'
        );

        $shipIdByColumn = array();
        foreach (FleetToolsHelper::getShipColumns() as $shipId => $col) {
            $shipIdByColumn[$col] = $shipId;
        }

        $gameSpeed = FleetFunctions::GetGameSpeedFactor();

        $enviadas = 0;
        $saltadas = 0;

        foreach ($planetas as $planetaId) {
            $planetaId = (int)$planetaId;
            if ($planetaId <= 0 || $planetaId === $destino['id']) {
                continue;
            }

            $sql = "SELECT * FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid AND `planet_type` = 1";
            $origen = $db->selectSingle($sql, array(':pid' => $planetaId, ':uid' => $USER['id']));
            if (empty($origen)) {
                continue;
            }

            $navesVoladoras = array();
            foreach ($shipColumns as $col) {
                if (!isset($origen[$col]) || $origen[$col] <= 0) {
                    continue;
                }
                $shipId = isset($shipIdByColumn[$col]) ? $shipIdByColumn[$col] : 0;
                if ($shipId > 0 && in_array($shipId, $flyableShipIds)) {
                    $navesVoladoras[$shipId] = (int)$origen[$col];
                }
            }

            if (empty($navesVoladoras)) {
                continue;
            }

            $maxFleetSpeed = 0;
            foreach ($navesVoladoras as $shipId => $qty) {
                $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
                if ($speed > 0) {
                    if ($maxFleetSpeed === 0 || $speed < $maxFleetSpeed) {
                        $maxFleetSpeed = $speed;
                    }
                }
            }

            if ($maxFleetSpeed <= 0) {
                continue;
            }

            $start  = array($origen['galaxy'], $origen['system'], $origen['planet']);
            $target = array($destino['galaxy'], $destino['system'], $destino['planet']);
            $distance = FleetFunctions::GetTargetDistance($start, $target);

            $duration  = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distance, $gameSpeed, $USER);
            $duracion  = (int)ceil($duration);
            if ($duracion < 1) {
                $duracion = 1;
            }

            $consumo = 0;
            $checkDiv = ($duracion * $gameSpeed) - 10;
            if ($checkDiv > 0) {
                $consumo = (int)FleetFunctions::GetFleetConsumption(
                    $navesVoladoras,
                    $duracion,
                    $distance,
                    $USER,
                    $gameSpeed
                );
            }

            $deuterioPlaneta = (int)$origen['deuterium'];
            if ($deuterioPlaneta < $consumo) {
                $saltadas++;
                continue;
            }

            if ($consumo > 0) {
                $sql = "UPDATE `".$prefix."planets` SET `deuterium` = `deuterium` - :cons WHERE `id` = :pid";
                $db->update($sql, array(':cons' => $consumo, ':pid' => $planetaId));
            }

            $now          = TIMESTAMP;
            $fleetStart   = $now + $duracion;
            $fleetStay    = $now + $duracion;
            $fleetEnd     = $now + $duracion;

            FleetFunctions::sendFleet(
                $navesVoladoras,
                4,
                $USER['id'],
                $origen['id'], $origen['galaxy'], $origen['system'], $origen['planet'], 1,
                $USER['id'],
                $destino['id'], $destino['galaxy'], $destino['system'], $destino['planet'], 1,
                array(901 => 0, 902 => 0, 903 => 0),
                $fleetStart, $fleetStay, $fleetEnd, 0, 0
            );

            $enviadas++;
        }

        FleetToolsHelper::log(
            $USER['id'],
            'reunir_flotas',
            'enviadas=' . $enviadas . ' | saltadas=' . $saltadas . ' | planetas=' . json_encode($planetas)
        );

        if ($enviadas > 0) {
            $this->redirectTo('game.php?page=fleettools&tab=reunir-flotas&success=ok&enviadas=' . $enviadas . '&saltadas=' . $saltadas);
        } else {
            $this->redirectTo('game.php?page=fleettools&tab=reunir-flotas&error=no_enviadas&saltadas=' . $saltadas);
        }
    }

    // =====================================================
    // REUNIR RECURSOS
    // =====================================================

    public function reunirRecursos()
    {
        global $USER, $PLANET, $resource;

        $planetas  = isset($_POST['planetas']) ? (array)$_POST['planetas'] : array();
        $velocidad = isset($_POST['velocidad']) ? (int)$_POST['velocidad'] : 10;

        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }

        if (empty($planetas)) {
            $this->redirectTo('game.php?page=fleettools&tab=reunir-recursos&error=no_planetas');
            return;
        }

        $prefix = DB_PREFIX;
        $db = Database::get();

        $destino = array(
            'id'     => (int)$PLANET['id'],
            'galaxy' => (int)$PLANET['galaxy'],
            'system' => (int)$PLANET['system'],
            'planet' => (int)$PLANET['planet'],
        );

        $cargoShips = FleetToolsHelper::getCargoShips();
        $gameSpeed = FleetFunctions::GetGameSpeedFactor();

        $enviadas = 0;
        $saltadas = 0;

        foreach ($planetas as $planetaId) {
            $planetaId = (int)$planetaId;
            if ($planetaId <= 0 || $planetaId === $destino['id']) {
                continue;
            }

            $sql = "SELECT * FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid AND `planet_type` = 1";
            $origen = $db->selectSingle($sql, array(':pid' => $planetaId, ':uid' => $USER['id']));
            if (empty($origen)) {
                continue;
            }

            $navesPorId = array();
            $capacidadTotal = 0;
            foreach ($cargoShips as $shipId => $info) {
                $col = $info['column'];
                $qty = isset($origen[$col]) ? (int)$origen[$col] : 0;
                if ($qty > 0) {
                    $navesPorId[$shipId] = $qty;
                    $capacidadTotal += $info['capacity'] * $qty;
                }
            }

            if (empty($navesPorId) || $capacidadTotal <= 0) {
                continue;
            }

            $metal = (int)$origen['metal'];
            $crystal = (int)$origen['crystal'];
            $deuterium = (int)$origen['deuterium'];

            $maxFleetSpeed = 0;
            foreach ($navesPorId as $shipId => $qty) {
                $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
                if ($speed > 0) {
                    if ($maxFleetSpeed === 0 || $speed < $maxFleetSpeed) {
                        $maxFleetSpeed = $speed;
                    }
                }
            }
            if ($maxFleetSpeed <= 0) {
                continue;
            }

            $start  = array($origen['galaxy'], $origen['system'], $origen['planet']);
            $target = array($destino['galaxy'], $destino['system'], $destino['planet']);
            $distance = FleetFunctions::GetTargetDistance($start, $target);

            $duration = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distance, $gameSpeed, $USER);
            $duracion = (int)ceil($duration);
            if ($duracion < 1) {
                $duracion = 1;
            }

            $consumo = 0;
            $checkDiv = ($duracion * $gameSpeed) - 10;
            if ($checkDiv > 0) {
                $consumo = (int)FleetFunctions::GetFleetConsumption(
                    $navesPorId,
                    $duracion,
                    $distance,
                    $USER,
                    $gameSpeed
                );
            }

            if ($deuterium < $consumo) {
                $saltadas++;
                continue;
            }

            $deutParaCarga = $deuterium - $consumo;
            if ($deutParaCarga < 0) {
                $deutParaCarga = 0;
            }

            $totalRecursos = $metal + $crystal + $deutParaCarga;

            if ($totalRecursos <= 0) {
                $saltadas++;
                continue;
            }

            $cargaMetal = 0;
            $cargaCrystal = 0;
            $cargaDeut = 0;

            if ($capacidadTotal >= $totalRecursos) {
                $cargaMetal = $metal;
                $cargaCrystal = $crystal;
                $cargaDeut = $deutParaCarga;
            } else {
                $cargaMetal = (int)floor($metal * 0.5);
                $cargaCrystal = (int)floor($crystal * 0.5);
                $cargaDeut = (int)floor($deutParaCarga * 0.5);
                $cargaTotal = $cargaMetal + $cargaCrystal + $cargaDeut;

                if ($cargaTotal < $capacidadTotal) {
                    $sobra = $capacidadTotal - $cargaTotal;
                    $restoMetal = $metal - $cargaMetal;
                    $restoCrystal = $crystal - $cargaCrystal;
                    $restoDeut = $deutParaCarga - $cargaDeut;
                    $restoTotal = $restoMetal + $restoCrystal + $restoDeut;

                    if ($restoTotal > 0) {
                        $factor = $sobra / $restoTotal;
                        $cargaMetal += (int)floor($restoMetal * $factor);
                        $cargaCrystal += (int)floor($restoCrystal * $factor);
                        $cargaDeut += (int)floor($restoDeut * $factor);
                    }
                } elseif ($cargaTotal > $capacidadTotal) {
                    $factor = $capacidadTotal / $cargaTotal;
                    $cargaMetal = (int)floor($cargaMetal * $factor);
                    $cargaCrystal = (int)floor($cargaCrystal * $factor);
                    $cargaDeut = (int)floor($cargaDeut * $factor);
                }
            }

            if ($cargaMetal > $metal) $cargaMetal = $metal;
            if ($cargaCrystal > $crystal) $cargaCrystal = $crystal;
            if ($cargaDeut > $deutParaCarga) $cargaDeut = $deutParaCarga;

            $deuterioTotalARestar = $consumo + $cargaDeut;

            $sql = "UPDATE `".$prefix."planets` SET `metal` = `metal` - :m, `crystal` = `crystal` - :c, `deuterium` = `deuterium` - :d WHERE `id` = :pid";
            $db->update($sql, array(
                ':m'   => $cargaMetal,
                ':c'   => $cargaCrystal,
                ':d'   => $deuterioTotalARestar,
                ':pid' => $planetaId
            ));

            $now = TIMESTAMP;
            $fleetStart = $now + $duracion;
            $fleetStay  = $now + $duracion;
            $fleetEnd   = $now + $duracion;

            FleetFunctions::sendFleet(
                $navesPorId,
                3,
                $USER['id'],
                $origen['id'], $origen['galaxy'], $origen['system'], $origen['planet'], 1,
                $USER['id'],
                $destino['id'], $destino['galaxy'], $destino['system'], $destino['planet'], 1,
                array(901 => $cargaMetal, 902 => $cargaCrystal, 903 => $cargaDeut),
                $fleetStart, $fleetStay, $fleetEnd, 0, 0
            );

            $enviadas++;
        }

        FleetToolsHelper::log(
            $USER['id'],
            'reunir_recursos',
            'enviadas=' . $enviadas . ' | saltadas=' . $saltadas . ' | destino=' . $destino['id'] . ' | planetas=' . json_encode($planetas)
        );

        if ($enviadas > 0) {
            $this->redirectTo('game.php?page=fleettools&tab=reunir-recursos&success=ok&enviadas=' . $enviadas . '&saltadas=' . $saltadas);
        } else {
            $this->redirectTo('game.php?page=fleettools&tab=reunir-recursos&error=no_enviadas&saltadas=' . $saltadas);
        }
    }

    // =====================================================
    // DISTRIBUIR RECURSOS
    // =====================================================

    public function distribuirRecursos()
    {
        global $USER, $PLANET, $resource;

        $planetas  = isset($_POST['planetas']) ? (array)$_POST['planetas'] : array();
        $velocidad = isset($_POST['velocidad']) ? (int)$_POST['velocidad'] : 10;
        $metal     = isset($_POST['metal'])     ? (int)$_POST['metal']     : 0;
        $crystal   = isset($_POST['crystal'])   ? (int)$_POST['crystal']   : 0;
        $deuterium = isset($_POST['deuterium']) ? (int)$_POST['deuterium'] : 0;
        $mision    = isset($_POST['mision'])    ? (int)$_POST['mision']    : 3;

        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }
        if ($mision != 3 && $mision != 4) {
            $mision = 3;
        }
        if ($metal < 0)     $metal = 0;
        if ($crystal < 0)   $crystal = 0;
        if ($deuterium < 0) $deuterium = 0;

        $totalDistribuir = $metal + $crystal + $deuterium;

        if (empty($planetas)) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=no_planetas');
            return;
        }
        if ($totalDistribuir <= 0) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=no_recursos');
            return;
        }

        $prefix = DB_PREFIX;
        $db = Database::get();

        $sql = "SELECT * FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid AND `planet_type` = 1";
        $origen = $db->selectSingle($sql, array(':pid' => $PLANET['id'], ':uid' => $USER['id']));
        if (empty($origen)) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=no_origen');
            return;
        }

        if ($metal > $origen['metal'] || $crystal > $origen['crystal'] || $deuterium > $origen['deuterium']) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=not_enough_resources');
            return;
        }

        $cargoShips = FleetToolsHelper::getCargoShips();
        $navesPorId = array();
        $capacidadTotal = 0;
        foreach ($cargoShips as $shipId => $info) {
            $col = $info['column'];
            $qty = isset($origen[$col]) ? (int)$origen[$col] : 0;
            if ($qty > 0) {
                $navesPorId[$shipId] = $qty;
                $capacidadTotal += $info['capacity'] * $qty;
            }
        }

        if (empty($navesPorId) || $capacidadTotal <= 0) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=no_ships');
            return;
        }

        if ($totalDistribuir > $capacidadTotal) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=not_enough_capacity');
            return;
        }

        $destinos = array();
        foreach ($planetas as $destinoId) {
            $destinoId = (int)$destinoId;
            if ($destinoId > 0 && $destinoId != $PLANET['id'] && !in_array($destinoId, $destinos)) {
                $destinos[] = $destinoId;
            }
        }

        if (empty($destinos)) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=no_valid_destinos');
            return;
        }

        $numDestinos = count($destinos);

        $factor = $totalDistribuir / $capacidadTotal;
        if ($factor >= 1) {
            $navesUsar = $navesPorId;
        } else {
            $navesUsar = array();
            foreach ($navesPorId as $shipId => $qty) {
                $qtyUsar = (int)floor($qty * $factor);
                if ($qtyUsar > 0) {
                    $navesUsar[$shipId] = $qtyUsar;
                }
            }
            if (empty($navesUsar)) {
                foreach ($navesPorId as $shipId => $qty) {
                    $navesUsar[$shipId] = 1;
                    break;
                }
            }
        }

        $metalPorDestino   = (int)floor($metal / $numDestinos);
        $crystalPorDestino = (int)floor($crystal / $numDestinos);
        $deutPorDestino    = (int)floor($deuterium / $numDestinos);

        $metalResto   = $metal - ($metalPorDestino * $numDestinos);
        $crystalResto = $crystal - ($crystalPorDestino * $numDestinos);
        $deutResto    = $deuterium - ($deutPorDestino * $numDestinos);

        $navesPorDestino = array();
        for ($i = 0; $i < $numDestinos; $i++) {
            $navesPorDestino[$i] = array();
        }
        foreach ($navesUsar as $shipId => $qty) {
            $perPlanet = (int)floor($qty / $numDestinos);
            $resto = $qty - ($perPlanet * $numDestinos);
            for ($i = 0; $i < $numDestinos; $i++) {
                $navesPorDestino[$i][$shipId] = $perPlanet;
            }
            for ($i = 0; $i < $resto; $i++) {
                $navesPorDestino[$i][$shipId]++;
            }
        }

        $gameSpeed = FleetFunctions::GetGameSpeedFactor();
        $deuterioOrigen = (int)$origen['deuterium'];

        $enviadas = 0;
        $saltadas = 0;
        $consumoTotal = 0;

        foreach ($destinos as $index => $destinoId) {
            $sql = "SELECT `id`, `name`, `galaxy`, `system`, `planet` FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid AND `planet_type` = 1";
            $destino = $db->selectSingle($sql, array(':pid' => $destinoId, ':uid' => $USER['id']));
            if (empty($destino)) {
                $saltadas++;
                continue;
            }

            $mD = $metalPorDestino   + ($index < $metalResto   ? 1 : 0);
            $cD = $crystalPorDestino + ($index < $crystalResto ? 1 : 0);
            $dD = $deutPorDestino    + ($index < $deutResto    ? 1 : 0);

            $navesDestino = array();
            foreach ($navesPorDestino[$index] as $shipId => $qty) {
                if ($qty > 0) {
                    $navesDestino[$shipId] = $qty;
                }
            }

            if (empty($navesDestino)) {
                $saltadas++;
                continue;
            }

            $maxFleetSpeed = 0;
            foreach ($navesDestino as $shipId => $qty) {
                $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
                if ($speed > 0) {
                    if ($maxFleetSpeed === 0 || $speed < $maxFleetSpeed) {
                        $maxFleetSpeed = $speed;
                    }
                }
            }

            if ($maxFleetSpeed <= 0) {
                $saltadas++;
                continue;
            }

            $start  = array($origen['galaxy'], $origen['system'], $origen['planet']);
            $target = array($destino['galaxy'], $destino['system'], $destino['planet']);
            $distance = FleetFunctions::GetTargetDistance($start, $target);

            $duration = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distance, $gameSpeed, $USER);
            $duracion = (int)ceil($duration);
            if ($duracion < 1) {
                $duracion = 1;
            }

            $consumo = 0;
            $checkDiv = ($duracion * $gameSpeed) - 10;
            if ($checkDiv > 0) {
                $consumo = (int)FleetFunctions::GetFleetConsumption(
                    $navesDestino, $duracion, $distance, $USER, $gameSpeed
                );
            }

            if ($mision == 3) {
                $consumo = $consumo * 2;
            }

            if ($deuterioOrigen < ($consumoTotal + $consumo)) {
                $saltadas++;
                continue;
            }

            $now = TIMESTAMP;
            $fleetStart = $now + $duracion;
            $fleetStay  = $now + $duracion;
            $fleetEnd   = $now + $duracion;

            FleetFunctions::sendFleet(
                $navesDestino,
                $mision,
                $USER['id'],
                $origen['id'], $origen['galaxy'], $origen['system'], $origen['planet'], 1,
                $USER['id'],
                $destino['id'], $destino['galaxy'], $destino['system'], $destino['planet'], 1,
                array(901 => $mD, 902 => $cD, 903 => $dD),
                $fleetStart, $fleetStay, $fleetEnd, 0, 0
            );

            $consumoTotal += $consumo;
            $enviadas++;
        }

        $deuterioTotalARestar = $deuterium + $consumoTotal;

        $sql = "UPDATE `".$prefix."planets` SET `metal` = `metal` - :m, `crystal` = `crystal` - :c, `deuterium` = `deuterium` - :d WHERE `id` = :pid";
        $db->update($sql, array(
            ':m'   => $metal,
            ':c'   => $crystal,
            ':d'   => $deuterioTotalARestar,
            ':pid' => $PLANET['id']
        ));

        FleetToolsHelper::log(
            $USER['id'],
            'distribuir_recursos',
            'enviadas=' . $enviadas . ' | saltadas=' . $saltadas . ' | mision=' . $mision . ' | planetas=' . json_encode($destinos)
        );

        if ($enviadas > 0) {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&success=ok&enviadas=' . $enviadas . '&saltadas=' . $saltadas);
        } else {
            $this->redirectTo('game.php?page=fleettools&tab=distribuir&error=no_enviadas&saltadas=' . $saltadas);
        }
    }

    // =====================================================
    // MULTI-EXPEDICIONES
    // =====================================================

    /**
     * MULTI-EXPEDICIONES - Envia X flotas a expedicion (slot 16) con las
     * MISMAS naves en cada una.
     *
     * REGLAS:
     * - Requiere VIP activo
     * - Las naves se seleccionan como en el Hangar (input por nave)
     * - Las naves se repiten en cada expedicion (no se dividen)
     * - Cantidad de expediciones limitada por slots disponibles (CON VIP)
     * - El consumo se multiplica por cantidad de expediciones
     * - Mision 15 (expedicion)
     * - Destino: mismo sistema, slot 16
     *
     * IMPORTANTE:
     * - Solo restamos el deuterio manualmente (consumo total)
     * - Las naves las resta sendFleet() automaticamente
     * - v2.7: slots calculados con FleetFunctions::getExpeditionLimit($USER)
     *        (incluye bonus VIP: +1 Semanal/Quincenal, +2 Mensual)
     */
    public function multiExpediciones()
    {
        global $USER, $PLANET, $resource;

        $velocidad     = isset($_POST['velocidad'])       ? (int)$_POST['velocidad']       : 10;
        $cantidad      = isset($_POST['cantidad'])        ? (int)$_POST['cantidad']        : 1;
        $estacionar    = isset($_POST['estacionamiento']) ? (int)$_POST['estacionamiento'] : 1;

        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }
        if ($cantidad < 1) {
            $cantidad = 1;
        }
        if ($estacionar < 0) {
            $estacionar = 0;
        }

        $prefix = DB_PREFIX;
        $db = Database::get();

        // ==========================================
        // VERIFICAR VIP ACTIVO
        // ==========================================
        $vipActivo = false;
        try {
            $sqlVip = "SELECT `vip_active`, `vip_end` FROM `".$prefix."users_vip` WHERE `user_id` = :uid LIMIT 1";
            $vipData = $db->selectSingle($sqlVip, array(':uid' => $USER['id']));

            if (!empty($vipData) && (int)$vipData['vip_active'] === 1 && (int)$vipData['vip_end'] > TIMESTAMP) {
                $vipActivo = true;
            }
        } catch (Exception $e) {
            $vipActivo = false;
        }

        if (!$vipActivo) {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=vip_required');
            return;
        }

        // Datos del planeta origen
        $sql = "SELECT * FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid AND `planet_type` = 1";
        $origen = $db->selectSingle($sql, array(':pid' => $PLANET['id'], ':uid' => $USER['id']));
        if (empty($origen)) {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=no_origen');
            return;
        }

        // ============================================
        // ASTROIO v2.7 - Slots de expedicion CON VIP incluido
        // getExpeditionLimit() ya suma el bonus VIP (+1 o +2)
        // ============================================
        $maxSlots = (int) FleetFunctions::getExpeditionLimit($USER);
        // ============================================
        // FIN ASTROIO v2.7
        // ============================================

        $sqlUsed = "SELECT COUNT(*) AS total FROM `".$prefix."fleets` WHERE `fleet_owner` = :uid AND `fleet_mission` = 15 AND `fleet_mess` = 0";
        $used = $db->selectSingle($sqlUsed, array(':uid' => $USER['id']));
        $usedSlots = !empty($used) ? (int)$used['total'] : 0;

        $slotsLibres = max(0, $maxSlots - $usedSlots);

        // Si no hay slots disponibles -> error
        if ($slotsLibres <= 0) {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=no_slots');
            return;
        }

        // Si la cantidad excede los slots -> ajustar a slots
        if ($cantidad > $slotsLibres) {
            $cantidad = $slotsLibres;
        }

        // Naves voladoras
        $flyableShipIds = array(202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 213, 214, 215, 219, 220);

        // Recoger naves seleccionadas
        $navesEnviar = array();
        $totalNaves = 0;

        foreach ($flyableShipIds as $shipId) {
            $field = 'ship' . $shipId;
            $qty = isset($_POST[$field]) ? (int)$_POST[$field] : 0;

            if ($qty <= 0) {
                continue;
            }

            // Buscar columna
            $col = '';
            foreach (FleetToolsHelper::getShipColumns() as $id => $c) {
                if ($id == $shipId) {
                    $col = $c;
                    break;
                }
            }

            if (empty($col)) {
                continue;
            }

            $disponible = isset($origen[$col]) ? (int)$origen[$col] : 0;
            if ($disponible <= 0) {
                continue;
            }

            // Limitar al disponible
            if ($qty > $disponible) {
                $qty = $disponible;
            }

            $navesEnviar[$shipId] = $qty;
            $totalNaves += $qty;
        }

        // Si no hay naves seleccionadas -> error
        if (empty($navesEnviar) || $totalNaves <= 0) {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=no_ships');
            return;
        }

        // Calcular velocidad mas lenta
        $maxFleetSpeed = 0;
        foreach ($navesEnviar as $shipId => $qty) {
            $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
            if ($speed > 0) {
                if ($maxFleetSpeed === 0 || $speed < $maxFleetSpeed) {
                    $maxFleetSpeed = $speed;
                }
            }
        }

        if ($maxFleetSpeed <= 0) {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=no_speed');
            return;
        }

        // Distancia hasta slot 16 (mismo sistema)
        $start  = array($origen['galaxy'], $origen['system'], $origen['planet']);
        $target = array($origen['galaxy'], $origen['system'], 16);
        $distance = FleetFunctions::GetTargetDistance($start, $target);

        $gameSpeed = FleetFunctions::GetGameSpeedFactor();

        // Tiempo por expedicion
        $duration = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distance, $gameSpeed, $USER);
        $duracion = (int)ceil($duration);
        if ($duracion < 1) {
            $duracion = 1;
        }

        // Consumo por expedicion
        $consumoPorExpedicion = 0;
        $checkDiv = ($duracion * $gameSpeed) - 10;
        if ($checkDiv > 0) {
            $consumoPorExpedicion = (int)FleetFunctions::GetFleetConsumption(
                $navesEnviar, $duracion, $distance, $USER, $gameSpeed
            );
        }

        // Consumo total = consumo x cantidad de expediciones
        $consumoTotal = $consumoPorExpedicion * $cantidad;

        // Verificar deuterio
        $deuterioPlaneta = (int)$origen['deuterium'];
        if ($deuterioPlaneta < $consumoTotal) {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=not_enough_deut');
            return;
        }

        // Verificar naves x cantidad
        $navesTotalNecesarias = array();
        foreach ($navesEnviar as $shipId => $qty) {
            $navesTotalNecesarias[$shipId] = $qty * $cantidad;
        }

        foreach ($navesTotalNecesarias as $shipId => $qtyTotal) {
            $col = '';
            foreach (FleetToolsHelper::getShipColumns() as $id => $c) {
                if ($id == $shipId) {
                    $col = $c;
                    break;
                }
            }
            if (empty($col)) {
                continue;
            }
            $disponible = isset($origen[$col]) ? (int)$origen[$col] : 0;
            if ($disponible < $qtyTotal) {
                $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=not_enough_ships');
                return;
            }
        }

        // ==========================================
        // RESTAR SOLO EL DEUTERIO
        // Las naves las resta sendFleet() automaticamente
        // ==========================================
        $sql = "UPDATE `".$prefix."planets` SET `deuterium` = `deuterium` - :deut WHERE `id` = :pid";
        $db->update($sql, array(':deut' => $consumoTotal, ':pid' => $PLANET['id']));

        // Tiempos
        $now = TIMESTAMP;
        $fleetStart = $now + $duracion;
        $fleetStay  = $now + $duracion + ($estacionar * 3600);
        $fleetEnd   = $fleetStay + $duracion;

        // Enviar X flotas (sendFleet resta las naves del planeta automaticamente)
        $enviadas = 0;
        for ($i = 0; $i < $cantidad; $i++) {
            FleetFunctions::sendFleet(
                $navesEnviar,
                15,
                $USER['id'],
                $origen['id'], $origen['galaxy'], $origen['system'], $origen['planet'], 1,
                0,
                0,
                $origen['galaxy'],
                $origen['system'],
                16,
                1,
                array(901 => 0, 902 => 0, 903 => 0),
                $fleetStart, $fleetStay, $fleetEnd, 0, 0
            );
            $enviadas++;
        }

        FleetToolsHelper::log(
            $USER['id'],
            'multi_exped',
            'enviadas=' . $enviadas . ' | naves=' . $totalNaves . ' | consumo_total=' . $consumoTotal . ' | velocidad=' . $velocidad
        );

        if ($enviadas > 0) {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&success=ok&enviadas=' . $enviadas);
        } else {
            $this->redirectTo('game.php?page=fleettools&tab=multi-exped&error=no_enviadas');
        }
    }

    // =====================================================
    // FAVORITOS
    // =====================================================

    public function guardarFavorito()
    {
        global $USER;

        $name   = isset($_POST['name'])   ? trim($_POST['name']) : '';
        $galaxy = isset($_POST['galaxy']) ? (int)$_POST['galaxy'] : 0;
        $system = isset($_POST['system']) ? (int)$_POST['system'] : 0;
        $planet = isset($_POST['planet']) ? (int)$_POST['planet'] : 0;
        $type   = isset($_POST['type'])   ? (int)$_POST['type']   : 1;

        if ($name !== '' && $galaxy > 0 && $system > 0 && $planet > 0) {
            FleetToolsHelper::guardarFavorito($USER['id'], $name, $galaxy, $system, $planet, $type);
        }
        $this->redirectTo('game.php?page=fleettools&success=fav_saved');
    }

    public function eliminarFavorito()
    {
        global $USER;

        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($id > 0) {
            FleetToolsHelper::eliminarFavorito($USER['id'], $id);
        }
        $this->redirectTo('game.php?page=fleettools&success=fav_deleted');
    }
}