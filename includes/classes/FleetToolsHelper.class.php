<?php
/**
 * AstroIO v2.6 - FleetToolsHelper
 * Herramientas de Flota: Reunir Flotas, Reunir Recursos,
 * Distribuir Recursos, Multi-Expediciones
 *
 * Compatible con 2Moons 2.0.git (PDO moderno) - AstroIO fork
 *
 * IMPORTANTE: Excluye naves que no pueden volar (solar_satelit)
 * para evitar "Division by zero" en FleetFunctions::GetFleetConsumption()
 *
 * NUEVO: Acepta $velocidad como parametro (1-10) para recalcular
 * tiempo y consumo cuando el jugador cambia el selector.
 *
 * NUEVO: Metodo getPlanetasParaReunirRecursos() para la pestana
 * "Reunir Recursos" - solo usa naves 202, 203, 217.
 *
 * NUEVO: Metodo getInfoParaDistribuir() para la pestana
 * "Distribuir Recursos" - devuelve datos del origen + destinos.
 *
 * NUEVO: Metodo getInfoParaMultiExpediciones() para la pestana
 * "Multi-Expediciones" - devuelve naves disponibles, slots y
 * calculo de tiempo/consumo base por expedicion.
 *
 * NUEVO: getInfoParaMultiExpediciones() ahora devuelve tambien:
 *   - naves_data      (speed + consumption por nave, para JS)
 *   - distancia       (distancia al slot 16)
 *   - game_speed      (factor de velocidad del server)
 *   - min_fleet_time  (constante MIN_FLEET_TIME del juego)
 */
if (!defined('MODE')) exit;

class FleetToolsHelper
{
    private static function prefix()
    {
        if (defined('DB_PREFIX')) {
            return DB_PREFIX;
        }
        if (method_exists('Database', 'get') && method_exists(Database::get(), 'getPrefix')) {
            return Database::get()->getPrefix();
        }
        if (isset($GLOBALS['database']['tableprefix'])) {
            return $GLOBALS['database']['tableprefix'];
        }
        return 'uni1_';
    }

    private static function db()
    {
        return Database::get();
    }

    public static function getShipColumns()
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
            219 => 'giga_recykler',
            220 => 'dm_ship',
        );
    }

    public static function getCargoShips()
	{
		global $pricelist;
		
		// Usamos $pricelist para obtener la capacidad real de la BD del juego
		$caps = array(
			202 => isset($pricelist[202]['capacity']) ? (int)$pricelist[202]['capacity'] : 5000,
			203 => isset($pricelist[203]['capacity']) ? (int)$pricelist[203]['capacity'] : 25000,
			217 => isset($pricelist[217]['capacity']) ? (int)$pricelist[217]['capacity'] : 25000, // El 25000 es el fallback real
		);

		return array(
			202 => array('column' => 'small_ship_cargo', 'capacity' => $caps[202]),
			203 => array('column' => 'big_ship_cargo',   'capacity' => $caps[203]),
			217 => array('column' => 'ev_transporter',   'capacity' => $caps[217]),
		);
	}

    public static function getShipsByType($planet, $type = 'cargo')
    {
        $cargo = array('small_ship_cargo', 'big_ship_cargo');
        $exped = array('small_ship_cargo', 'big_ship_cargo', 'giga_recykler');
        $wars  = array('light_hunter', 'heavy_hunter', 'crusher', 'battle_ship',
                       'bomber_ship', 'destructor', 'dearth_star', 'battleship',
                       'giga_recykler', 'dm_ship');

        $allowed = array();
        if ($type === 'cargo')   $allowed = $cargo;
        if ($type === 'exped')   $allowed = $exped;
        if ($type === 'warship') $allowed = $wars;
        if ($type === 'all')     $allowed = array_unique(array_merge($cargo, $exped, $wars));

        $result = array();
        foreach ($allowed as $ship) {
            if (isset($planet[$ship]) && $planet[$ship] > 0) {
                $result[$ship] = (int)$planet[$ship];
            }
        }
        return $result;
    }

    public static function getShipCapacity($shipId)
    {
        global $pricelist;
        if (isset($pricelist[$shipId]['capacity'])) {
            return (int)$pricelist[$shipId]['capacity'];
        }
        $caps = array(202 => 5000, 203 => 25000, 217 => 5000, 219 => 80000);
        return isset($caps[$shipId]) ? $caps[$shipId] : 0;
    }

    public static function calcularCapacidad($ships)
    {
        $total = 0;
        foreach ($ships as $shipId => $qty) {
            $total += self::getShipCapacity($shipId) * (int)$qty;
        }
        return $total;
    }

    public static function getPlanetasConRecursos($userId)
    {
        $prefix = self::prefix();
        $db = self::db();
        $sql = "SELECT `id`, `name`, `galaxy`, `system`, `planet`, `metal`, `crystal`, `deuterium`, `id_luna` FROM `".$prefix."planets` WHERE `id_owner` = :uid AND `planet_type` = 1 ORDER BY `galaxy`, `system`, `planet`";
        return $db->select($sql, array(':uid' => $userId));
    }

    public static function getOtrosPlanetas($userId, $excludePlanetId = 0)
    {
        $prefix = self::prefix();
        $db = self::db();
        $sql = "SELECT `id`, `name`, `galaxy`, `system`, `planet`, `metal`, `crystal`, `deuterium`, `id_luna` FROM `".$prefix."planets` WHERE `id_owner` = :uid AND `planet_type` = 1 AND `id` != :exclude ORDER BY `galaxy`, `system`, `planet`";
        return $db->select($sql, array(':uid' => $userId, ':exclude' => $excludePlanetId));
    }

    public static function getPlanetasConNavesYTiempo($userId, $origenPlanetId, $USER, $velocidad = 10)
    {
        $prefix = self::prefix();
        $db = self::db();

        $velocidad = (int)$velocidad;
        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }

        $sqlDest = "SELECT `id`, `name`, `galaxy`, `system`, `planet` FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid";
        $destino = $db->selectSingle($sqlDest, array(':pid' => $origenPlanetId, ':uid' => $userId));
        if (empty($destino)) {
            return array();
        }

        // 🔥 FIX: Buscar en planetas Y lunas (sin planet_type = 1)
        $sql = "SELECT * FROM `".$prefix."planets` WHERE `id_owner` = :uid AND `id` != :origen ORDER BY `galaxy`, `system`, `planet`";
        $planetas = $db->select($sql, array(':uid' => $userId, ':origen' => $origenPlanetId));

        if (empty($planetas)) {
            return array();
        }

        global $resource, $reslist, $pricelist;
        $gameSpeed = FleetFunctions::GetGameSpeedFactor();

        $resultado = array();
        foreach ($planetas as $p) {
            $naves = array();
            $navesPorId = array();
            $tieneNaves = false;

            // 🔥 FIX: Iterar dinámicamente sobre TODAS las naves del juego
            foreach ($reslist['fleet'] as $shipId) {
                $col = isset($resource[$shipId]) ? $resource[$shipId] : '';
                
                // Solo si la columna existe, hay cantidad y la nave tiene motor
                if (!empty($col) && isset($p[$col]) && $p[$col] > 0) {
                    if (isset($pricelist[$shipId]['speed']) && $pricelist[$shipId]['speed'] > 0) {
                        $naves[$col] = (int)$p[$col];
                        $navesPorId[$shipId] = (int)$p[$col];
                        $tieneNaves = true;
                    }
                }
            }

            if (!$tieneNaves || empty($navesPorId)) {
                continue;
            }

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

            $start  = array($p['galaxy'], $p['system'], $p['planet']);
            $target = array($destino['galaxy'], $destino['system'], $destino['planet']);
            $distance = FleetFunctions::GetTargetDistance($start, $target);

            $duration  = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distance, $gameSpeed, $USER);
            $tiempoViaje = (int)ceil($duration);
            $tiempoStr   = self::formatTime($tiempoViaje);

            $consumo = 0;
            if (!empty($navesPorId) && $tiempoViaje > 0) {
                $checkDiv = ($tiempoViaje * $gameSpeed) - 10;
                if ($checkDiv > 0) {
                    $consumo = (int)FleetFunctions::GetFleetConsumption(
                        $navesPorId, $tiempoViaje, $distance, $USER, $gameSpeed
                    );
                }
            }

            $deuterioPlaneta = (int)$p['deuterium'];
            $tieneSuficiente = ($deuterioPlaneta >= $consumo);
            $falta = $tieneSuficiente ? 0 : ($consumo - $deuterioPlaneta);

            $resultado[] = array(
                'id'              => $p['id'],
                'name'            => $p['name'],
                'galaxy'          => $p['galaxy'],
                'system'          => $p['system'],
                'planet'          => $p['planet'],
                'naves'           => $naves,
                'naves_por_id'    => $navesPorId,
                'total_naves'     => array_sum($naves),
                'deuterio'        => $deuterioPlaneta,
                'consumo'         => $consumo,
                'tiene_suficiente'=> $tieneSuficiente,
                'falta'           => $falta,
                'tiempo'          => $tiempoViaje,
                'tiempo_str'      => $tiempoStr,
            );
        }

        return $resultado;
    }

    public static function getPlanetasParaReunirRecursos($userId, $destinoPlanetId, $USER, $velocidad = 10)
    {
        $prefix = self::prefix();
        $db = self::db();

        $velocidad = (int)$velocidad;
        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }

        $sqlDest = "SELECT `id`, `name`, `galaxy`, `system`, `planet` FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid";
        $destino = $db->selectSingle($sqlDest, array(':pid' => $destinoPlanetId, ':uid' => $userId));
        if (empty($destino)) {
            return array();
        }

        $sql = "SELECT `id`, `name`, `galaxy`, `system`, `planet`, `planet_type`, `metal`, `crystal`, `deuterium`, `small_ship_cargo`, `big_ship_cargo`, `ev_transporter` FROM `".$prefix."planets` WHERE `id_owner` = :uid AND `planet_type` = 1 ORDER BY `galaxy`, `system`, `planet`";
        $planetas = $db->select($sql, array(':uid' => $userId));

        if (empty($planetas)) {
            return array();
        }

        $cargoShips = self::getCargoShips();
        $gameSpeed = FleetFunctions::GetGameSpeedFactor();

        $resultado = array();
        foreach ($planetas as $p) {
            $esDestino = ($p['id'] == $destinoPlanetId);

            $metal    = (int)$p['metal'];
            $crystal  = (int)$p['crystal'];
            $deuterium = (int)$p['deuterium'];
            $totalRecursos = $metal + $crystal + $deuterium;

            $navesCarga = array();
            $navesPorId = array();
            $capacidadTotal = 0;

            foreach ($cargoShips as $shipId => $info) {
                $col = $info['column'];
                $qty = isset($p[$col]) ? (int)$p[$col] : 0;
                if ($qty > 0) {
                    $navesCarga[$col] = $qty;
                    $navesPorId[$shipId] = $qty;
                    $capacidadTotal += $info['capacity'] * $qty;
                }
            }
            $totalNavesCarga = array_sum($navesCarga);

            $cargaMetal = 0;
            $cargaCrystal = 0;
            $cargaDeut = 0;

            if (!$esDestino && $totalRecursos > 0 && $capacidadTotal > 0) {
                if ($capacidadTotal >= $totalRecursos) {
                    $cargaMetal = $metal;
                    $cargaCrystal = $crystal;
                    $cargaDeut = $deuterium;
                } else {
                    $cargaMetal = (int)floor($metal * 0.5);
                    $cargaCrystal = (int)floor($crystal * 0.5);
                    $cargaDeut = (int)floor($deuterium * 0.5);
                    $cargaTotal = $cargaMetal + $cargaCrystal + $cargaDeut;

                    if ($cargaTotal < $capacidadTotal) {
                        $sobra = $capacidadTotal - $cargaTotal;
                        $restoMetal = $metal - $cargaMetal;
                        $restoCrystal = $crystal - $cargaCrystal;
                        $restoDeut = $deuterium - $cargaDeut;
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
            }

            $tiempoViaje = 0;
            $tiempoStr = '-';
            $consumo = 0;

            if (!$esDestino && !empty($navesPorId) && $capacidadTotal > 0) {
                $maxFleetSpeed = 0;
                foreach ($navesPorId as $shipId => $qty) {
                    $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
                    if ($speed > 0) {
                        if ($maxFleetSpeed === 0 || $speed < $maxFleetSpeed) {
                            $maxFleetSpeed = $speed;
                        }
                    }
                }

                if ($maxFleetSpeed > 0) {
                    $start = array($p['galaxy'], $p['system'], $p['planet']);
                    $target = array($destino['galaxy'], $destino['system'], $destino['planet']);
                    $distance = FleetFunctions::GetTargetDistance($start, $target);

                    $duration = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distance, $gameSpeed, $USER);
                    $tiempoViaje = (int)ceil($duration);
                    if ($tiempoViaje < 1) {
                        $tiempoViaje = 1;
                    }
                    $tiempoStr = self::formatTime($tiempoViaje);

                    $checkDiv = ($tiempoViaje * $gameSpeed) - 10;
                    if ($checkDiv > 0) {
                        $consumo = (int)FleetFunctions::GetFleetConsumption(
                            $navesPorId, $tiempoViaje, $distance, $USER, $gameSpeed
                        );
                    }
                }
            }

            $tieneSuficiente = ($deuterium >= $consumo);
            $falta = $tieneSuficiente ? 0 : ($consumo - $deuterium);

            $resultado[] = array(
                'id'                 => $p['id'],
                'name'               => $p['name'],
                'galaxy'             => $p['galaxy'],
                'system'             => $p['system'],
                'planet'             => $p['planet'],
                'metal'              => $metal,
                'crystal'            => $crystal,
                'deuterium'          => $deuterium,
                'small_ship_cargo'   => isset($navesCarga['small_ship_cargo']) ? $navesCarga['small_ship_cargo'] : 0,
                'big_ship_cargo'     => isset($navesCarga['big_ship_cargo']) ? $navesCarga['big_ship_cargo'] : 0,
                'ev_transporter'     => isset($navesCarga['ev_transporter']) ? $navesCarga['ev_transporter'] : 0,
                'naves_por_id'       => $navesPorId,
                'total_naves_carga'  => $totalNavesCarga,
                'capacidad_total'    => $capacidadTotal,
                'carga_metal'        => $cargaMetal,
                'carga_crystal'      => $cargaCrystal,
                'carga_deuterium'    => $cargaDeut,
                'carga_total'        => $cargaMetal + $cargaCrystal + $cargaDeut,
                'tiempo'             => $tiempoViaje,
                'tiempo_str'         => $tiempoStr,
                'consumo'            => $consumo,
                'tiene_suficiente'   => $tieneSuficiente,
                'falta'              => $falta,
                'es_destino'         => $esDestino,
            );
        }

        return $resultado;
    }

    public static function getInfoParaDistribuir($userId, $origenPlanetId, $USER, $velocidad = 10)
    {
        $prefix = self::prefix();
        $db = self::db();

        $velocidad = (int)$velocidad;
        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }

        $resultado = array(
            'origen'   => null,
            'destinos' => array(),
        );

        $sqlOrigen = "SELECT `id`, `name`, `galaxy`, `system`, `planet`, `metal`, `crystal`, `deuterium`, `small_ship_cargo`, `big_ship_cargo`, `ev_transporter` FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid";
        $origen = $db->selectSingle($sqlOrigen, array(':pid' => $origenPlanetId, ':uid' => $userId));
        if (empty($origen)) {
            return $resultado;
        }

        $cargoShips = self::getCargoShips();
        $navesCarga = array();
        $navesPorId = array();
        $capacidadTotal = 0;

        foreach ($cargoShips as $shipId => $info) {
            $col = $info['column'];
            $qty = isset($origen[$col]) ? (int)$origen[$col] : 0;
            if ($qty > 0) {
                $navesCarga[$col] = $qty;
                $navesPorId[$shipId] = $qty;
                $capacidadTotal += $info['capacity'] * $qty;
            }
        }

        $resultado['origen'] = array(
            'id'                => (int)$origen['id'],
            'name'              => $origen['name'],
            'galaxy'            => (int)$origen['galaxy'],
            'system'            => (int)$origen['system'],
            'planet'            => (int)$origen['planet'],
            'metal'             => (int)$origen['metal'],
            'crystal'           => (int)$origen['crystal'],
            'deuterium'         => (int)$origen['deuterium'],
            'small_ship_cargo'  => isset($navesCarga['small_ship_cargo']) ? $navesCarga['small_ship_cargo'] : 0,
            'big_ship_cargo'    => isset($navesCarga['big_ship_cargo']) ? $navesCarga['big_ship_cargo'] : 0,
            'ev_transporter'    => isset($navesCarga['ev_transporter']) ? $navesCarga['ev_transporter'] : 0,
            'naves_por_id'      => $navesPorId,
            'total_naves'       => array_sum($navesCarga),
            'capacidad_total'   => $capacidadTotal,
        );
		        // Añadir datos de las naves para que JS pueda calcular el consumo real
        $resultado['origen']['naves_data'] = array();
        $shipInfo = FleetFunctions::GetFleetShipInfo($navesPorId, $USER);
        foreach ($shipInfo as $sid => $data) {
            $resultado['origen']['naves_data'][$sid] = array(
                'speed'       => (float)$data['speed'],
                'consumption' => (float)$data['consumption'],
                'capacity'    => (float)self::getShipCapacity($sid)
            );
        }

        if (empty($navesPorId) || $capacidadTotal <= 0) {
            return $resultado;
        }

        $sql = "SELECT `id`, `name`, `galaxy`, `system`, `planet`, `planet_type` FROM `".$prefix."planets` WHERE `id_owner` = :uid AND `planet_type` = 1 AND `id` != :origen ORDER BY `galaxy`, `system`, `planet`";
        $planetas = $db->select($sql, array(':uid' => $userId, ':origen' => $origenPlanetId));

        if (empty($planetas)) {
            return $resultado;
        }

        $gameSpeed = FleetFunctions::GetGameSpeedFactor();

        $maxFleetSpeed = 0;
        foreach ($navesPorId as $shipId => $qty) {
            $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
            if ($speed > 0) {
                if ($maxFleetSpeed === 0 || $speed < $maxFleetSpeed) {
                    $maxFleetSpeed = $speed;
                }
            }
        }

        foreach ($planetas as $p) {
            $distancia = 0;
            $tiempoViaje = 0;
            $tiempoStr = '-';
            $consumo = 0;

            if ($maxFleetSpeed > 0) {
                $start  = array($origen['galaxy'], $origen['system'], $origen['planet']);
                $target = array($p['galaxy'], $p['system'], $p['planet']);
                $distancia = FleetFunctions::GetTargetDistance($start, $target);

                $duration = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distancia, $gameSpeed, $USER);
                $tiempoViaje = (int)ceil($duration);
                if ($tiempoViaje < 1) {
                    $tiempoViaje = 1;
                }
                $tiempoStr = self::formatTime($tiempoViaje);

                $checkDiv = ($tiempoViaje * $gameSpeed) - 10;
                if ($checkDiv > 0) {
                    $consumo = (int)FleetFunctions::GetFleetConsumption(
                        $navesPorId, $tiempoViaje, $distancia, $USER, $gameSpeed
                    );
                }
            }

            $resultado['destinos'][] = array(
                'id'          => (int)$p['id'],
                'name'        => $p['name'],
                'galaxy'      => (int)$p['galaxy'],
                'system'      => (int)$p['system'],
                'planet'      => (int)$p['planet'],
                'distancia'   => $distancia,
                'tiempo'      => $tiempoViaje,
                'tiempo_str'  => $tiempoStr,
                'consumo'     => $consumo,
            );
        }

        return $resultado;
    }

    /**
     * Obtiene info del planeta actual para la pestana "Multi-Expediciones".
     *
     * Devuelve:
     *   - slots_libres        Slots de expedicion disponibles
     *   - slots_max           Slots maximos (segun tech de expedicion)
     *   - expedition_tech     Nivel de la tecnologia de expedicion
     *   - naves_disponibles   Array con [columna => cantidad] de naves voladoras
     *   - naves_por_id        Array con [ID => cantidad] de naves voladoras
     *   - total_naves         Total de naves voladoras
     *   - tiempo_base         Tiempo de viaje hasta slot 16 (con TODAS las naves)
     *   - tiempo_base_str     "H:MM:SS"
     *   - consumo_base        Consumo por expedicion (con TODAS las naves)
     *   - naves_data          Array [ID => ['speed' => X, 'consumption' => Y]]
     *   - distancia           Distancia al slot 16
     *   - game_speed          Factor de velocidad del server
     *   - min_fleet_time      Constante MIN_FLEET_TIME del juego
     *
     * @param int   $userId       ID del jugador
     * @param int   $planetId     ID del planeta actual (origen)
     * @param array $USER         Datos del jugador
     * @param int   $velocidad    Velocidad de vuelo (1-10)
     * @return array
     */
    public static function getInfoParaMultiExpediciones($userId, $planetId, $USER, $velocidad = 10)
    {
        global $pricelist;

        $prefix = self::prefix();
        $db = self::db();

        $velocidad = (int)$velocidad;
        if ($velocidad < 1 || $velocidad > 10) {
            $velocidad = 10;
        }

        $resultado = array(
            'slots_libres'      => 0,
            'slots_max'         => 0,
            'expedition_tech'   => 0,
            'naves_disponibles' => array(),
            'naves_por_id'      => array(),
            'total_naves'       => 0,
            'tiempo_base'       => 0,
            'tiempo_base_str'   => '-',
            'consumo_base'      => 0,
            'naves_data'        => array(),
            'distancia'         => 0,
            'game_speed'        => 1,
            'min_fleet_time'    => 1,
			'stay_selector'     => array(),
			'stay_selected'     => 1,
        );

        // Datos del planeta actual
        $sql = "SELECT * FROM `".$prefix."planets` WHERE `id` = :pid AND `id_owner` = :uid AND `planet_type` = 1";
        $origen = $db->selectSingle($sql, array(':pid' => $planetId, ':uid' => $userId));
        if (empty($origen)) {
            return $resultado;
        }

        // Nivel de tecnologia de expedicion (ID 124)
        $expeditionTech = 0;
        if (isset($USER['expedition_tech'])) {
            $expeditionTech = (int)$USER['expedition_tech'];
        }

        // Slots de expedicion (incluye bonus VIP +1/+2)
		$maxSlots = (int) FleetFunctions::getExpeditionLimit($USER);

        // Contar slots usados actualmente
                $sqlUsed = "SELECT COUNT(*) AS total FROM `".$prefix."fleets` WHERE `fleet_owner` = :uid AND `fleet_mission` = 15";
        $used = $db->selectSingle($sqlUsed, array(':uid' => $userId));
        $usedSlots = !empty($used) ? (int)$used['total'] : 0;

        $slotsLibres = max(0, $maxSlots - $usedSlots);

        // 🔥 FIX: Iterar dinámicamente sobre TODAS las naves del juego
        global $resource, $reslist, $pricelist;
        
        $navesDisponibles = array();
        $navesPorId = array();
        $totalNaves = 0;

        foreach ($reslist['fleet'] as $shipId) {
            $col = isset($resource[$shipId]) ? $resource[$shipId] : '';
            
            if (!empty($col) && isset($origen[$col]) && $origen[$col] > 0) {
                if (isset($pricelist[$shipId]['speed']) && $pricelist[$shipId]['speed'] > 0) {
                    $qty = (int)$origen[$col];
                    $navesDisponibles[$col] = $qty;
                    $navesPorId[$shipId] = $qty;
                    $totalNaves += $qty;
                }
            }
        }

        // Tiempo y consumo base (con TODAS las naves)
        $tiempoViaje = 0;
        $tiempoStr = '-';
        $consumo = 0;
        $distancia = 0;

        if (!empty($navesPorId)) {
            $maxFleetSpeed = 0;
            foreach ($navesPorId as $shipId => $qty) {
                $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
                if ($speed > 0) {
                    if ($maxFleetSpeed === 0 || $speed < $maxFleetSpeed) {
                        $maxFleetSpeed = $speed;
                    }
                }
            }

            if ($maxFleetSpeed > 0) {
                $gameSpeed = FleetFunctions::GetGameSpeedFactor();

                // Expedicion va al slot 16 (max_planets + 1)
                $start  = array($origen['galaxy'], $origen['system'], $origen['planet']);
                $target = array($origen['galaxy'], $origen['system'], 16);
                $distancia = FleetFunctions::GetTargetDistance($start, $target);

                $duration = FleetFunctions::GetMissionDuration($velocidad, $maxFleetSpeed, $distancia, $gameSpeed, $USER);
                $tiempoViaje = (int)ceil($duration);
                if ($tiempoViaje < 1) {
                    $tiempoViaje = 1;
                }
                $tiempoStr = self::formatTime($tiempoViaje);

                $checkDiv = ($tiempoViaje * $gameSpeed) - 10;
                if ($checkDiv > 0) {
                    $consumo = (int)FleetFunctions::GetFleetConsumption(
                        $navesPorId, $tiempoViaje, $distancia, $USER, $gameSpeed
                    );
                }
            }
        }

        // ==========================================
        // DATOS PARA JAVASCRIPT (recalculo en vivo)
        // ==========================================

        // Speed y consumption por nave
        $navesData = array();
        foreach ($navesPorId as $shipId => $qty) {
            if ($qty <= 0) {
                continue;
            }

            // Speed real con tech del jugador
            $speed = FleetFunctions::GetFleetMaxSpeed($shipId, $USER);
            if ($speed <= 0) {
                continue;
            }

            // Consumo base
            $shipConsumption = 0;
            if (isset($pricelist[$shipId]['consumption'])) {
                $shipConsumption = (int)$pricelist[$shipId]['consumption'];

                // Ajustes por motor mejorado
                if ($shipId == 202 && isset($USER['impulse_motor_tech']) && (int)$USER['impulse_motor_tech'] >= 5) {
                    if (isset($pricelist[$shipId]['consumption2'])) {
                        $shipConsumption = (int)$pricelist[$shipId]['consumption2'];
                    }
                }
                if ($shipId == 211 && isset($USER['hyperspace_motor_tech']) && (int)$USER['hyperspace_motor_tech'] >= 8) {
                    if (isset($pricelist[$shipId]['consumption2'])) {
                        $shipConsumption = (int)$pricelist[$shipId]['consumption2'];
                    }
                }
            }

            $navesData[$shipId] = array(
                'speed'       => (float)$speed,
                'consumption' => (float)$shipConsumption,
            );
        }

        // Game speed
        $gameSpeed = 1;
        if (class_exists('FleetFunctions')) {
            $gameSpeed = (float)FleetFunctions::GetGameSpeedFactor();
            if ($gameSpeed <= 0) {
                $gameSpeed = 1;
            }
        }

        // MIN_FLEET_TIME
        $minFleetTime = 1;
        if (defined('MIN_FLEET_TIME')) {
            $minFleetTime = (int)MIN_FLEET_TIME;
        }

        // Setear resultados
        $resultado['slots_libres']      = $slotsLibres;
        $resultado['slots_max']         = $maxSlots;
        $resultado['expedition_tech']   = $expeditionTech;
        $resultado['naves_disponibles'] = $navesDisponibles;
        $resultado['naves_por_id']      = $navesPorId;
        $resultado['total_naves']       = $totalNaves;
        $resultado['tiempo_base']       = $tiempoViaje;
        $resultado['tiempo_base_str']   = $tiempoStr;
        $resultado['consumo_base']      = $consumo;
        $resultado['naves_data']        = $navesData;
        $resultado['distancia']         = $distancia;
        $resultado['game_speed']        = $gameSpeed;
        $resultado['min_fleet_time']    = $minFleetTime;
		
		$resultado['stay_selector'] = FleetFunctions::GetExpeditionStayBlock($USER);
		$resultado['stay_selected'] = 1;
				
        return $resultado;
    }

    public static function formatTime($seconds)
    {
        $seconds = (int)$seconds;
        $h = floor($seconds / 3600);
        $m = floor(($seconds % 3600) / 60);
        $s = $seconds % 60;
        return sprintf('%d:%02d:%02d', $h, $m, $s);
    }

    public static function getSlotsExpedicionLibres($userId, $expeditionTech = 0)
    {
        global $USER;
		$maxSlots = (int) FleetFunctions::getExpeditionLimit($USER);
        $prefix = self::prefix();
        $db = self::db();

                $sql = "SELECT COUNT(*) AS total FROM `".$prefix."fleets` WHERE `fleet_owner` = :uid AND `fleet_mission` = 15";
        $used = $db->selectSingle($sql, array(':uid' => $userId));

        $usedCount = !empty($used) ? (int)$used['total'] : 0;
        return max(0, $maxSlots - $usedCount);
    }

    public static function getPlanetasConFlotas($userId)
    {
        $prefix = self::prefix();
        $db = self::db();
        $sql = "SELECT DISTINCT p.`id`, p.`name`, p.`galaxy`, p.`system`, p.`planet` FROM `".$prefix."planets` p INNER JOIN `".$prefix."fleets` f ON f.`fleet_start_id` = p.`id` WHERE p.`id_owner` = :uid AND f.`fleet_owner` = :uid AND f.`fleet_mess` = 0";
        return $db->select($sql, array(':uid' => $userId));
    }

    public static function log($userId, $action, $detalle = '')
    {
        $prefix = self::prefix();
        $db = self::db();
        $sql = "INSERT INTO `".$prefix."fleettools_log` (`user_id`, `action`, `detalle`, `ip`, `fecha`) VALUES (:uid, :action, :detalle, :ip, :now)";
        $db->insert($sql, array(
            ':uid'     => $userId,
            ':action'  => $action,
            ':detalle' => $detalle,
            ':ip'      => isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : '',
            ':now'     => time(),
        ));
    }

    public static function guardarFavorito($userId, $name, $galaxy, $system, $planet, $type = 1)
    {
        $prefix = self::prefix();
        $db = self::db();
        $sql = "INSERT INTO `".$prefix."users_coord_favorites` (`user_id`, `name`, `galaxy`, `system`, `planet`, `type`, `created_at`) VALUES (:uid, :name, :g, :s, :p, :t, :now)";
        return $db->insert($sql, array(
            ':uid' => $userId, ':name' => $name,
            ':g' => $galaxy, ':s' => $system, ':p' => $planet,
            ':t' => $type, ':now' => time()
        ));
    }

    public static function getFavoritos($userId)
    {
        $prefix = self::prefix();
        $db = self::db();
        $sql = "SELECT * FROM `".$prefix."users_coord_favorites` WHERE `user_id` = :uid ORDER BY `name` ASC";
        return $db->select($sql, array(':uid' => $userId));
    }

    public static function eliminarFavorito($userId, $id)
    {
        $prefix = self::prefix();
        $db = self::db();
        $sql = "DELETE FROM `".$prefix."users_coord_favorites` WHERE `id` = :id AND `user_id` = :uid";
        return $db->delete($sql, array(':id' => $id, ':uid' => $userId));
    }
}