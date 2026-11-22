<?php
/**
 *  AstroIO - Página de Contenedores
 *  Archivo: includes/pages/game/ShowContainersPage.class.php
 *  URL:     game.php?page=containers
 *
 *  Reglas:
 *   - Abrir contenedor es GRATIS
 *   - Solo se consume 1 caja por apertura
 *   - Recompensas aleatorias según tabla uni1_container_loot
 *   - Los BOOSTERS caen según rareza y se aplican automáticamente (24h)
 *
 * v1.7:
 *   - Factor minas: 0.10 + (suma_minas / 250), cap 0.60x
 *
 * v1.8 (DUAL RIEL - 2026-10-30):
 *   - Detecta el riel del jugador (CUP / QVAPAY).
 *   - Pasa al template: $moneda, $moneda_fiat, $es_internacional, $saldo_actual.
 *   - El stat "NTX-20" del template ahora muestra la moneda correcta.
 *   - NO cobra NTX-20 (abrir es gratis) - solo corrige el stat cosmético.
 *   - El case 'ntx20' del drop es código muerto (item 19 ya eliminado).
 *
 * v2.0 (DROP POR PRODUCCIÓN/HORA - 2026-11-02):
 *   - ELIMINADO el factor de minas (getMineFactor).
 *   - Recursos (metal/crystal/deuterium): prod/hora × (tier% / 100) × mult_cofre.
 *   - Tier% hardcodeado: común 20-40, raro 40-60, épico 60-80, mítico 80-100.
 *   - Tope natural: 1 hora de producción en el valor base (antes del cofre).
 *   - Materia Oscura: rango fijo 250-2500 × mult_cofre.
 *   - Naves/Defensas: rango fijo loot_value_min..max × mult_cofre (sin prod/h).
 *   - Fallback metal: prod/hora_metal × 0.20 × mult_cofre (antes era 50k-200k).
 *   - Bug 0.48%: re-roll defensivo entre tier común si el dado cae fuera de rango.
 *   - NO hay multiplicador VIP explícito: el VIP ya va dentro de prod/hora
 *     (lo aplica class.PlanetRessUpdate.php → ver DOCUMENTO_VIP_v2.1.md).
 *   - Guard: si no hay planeta activo, NO se consume cofre.
 *
 * v2.1 (BUFF CLIMÁTICO - 2026-11-08):
 *   - Añadida sección "Cofres Climáticos" (menor/mayor/dominio).
 *   - 3 acciones POST: activate_climate_minor/major/dominion.
 *   - Al activar: consume 1 cofre, activa buff 24h con ClimaEngine::setActiveBuff().
 *   - Carga el buff activo actual con ClimaEngine::getActiveBuff() y su tiempo restante.
 *   - Pasa al template: boxClimateMinor/Major/Dominion, activeBuff, buffSegundosRestantes.
 *   - Solo 1 buff activo por jugador (si activa otro, reemplaza al anterior).
 */

// ============================================
// ASTROIO - Cargar ClimaEngine si no está
// ============================================
if (!class_exists('ClimaEngine')) {
    $__climaFile = (defined('ROOT_PATH') ? ROOT_PATH : '') . 'includes/classes/ClimaEngine.class.php';
    if (file_exists($__climaFile)) {
        require_once $__climaFile;
    }
}
// ============================================

class ShowContainersPage extends AbstractGamePage
{
    function __construct()
    {
        parent::__construct();
    }

    /**
     * Prefijo de las tablas
     */
    private function getPrefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /**
     * 🆕 v1.8 — Detecta el método de pago del jugador ('CUP' o 'QVAPAY').
     */
    private function getPlayerMethod($userId)
    {
        $db = Database::get();
        $prefix = $this->getPrefix();
        try {
            $row = $db->selectSingle(
                "SELECT metodo_retiro FROM `".$prefix."users` WHERE id = :uid LIMIT 1;",
                array(':uid' => (int)$userId)
            );
            return ($row && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
        } catch (Exception $e) {
            return 'CUP';
        }
    }

    /**
     * Mapa de IDs de naves/defensas → nombre REAL de columna en uni1_planets
     */
    private function getUnitColumn($id)
    {
        $map = array(
            202 => 'small_ship_cargo', 203 => 'big_ship_cargo',
            204 => 'light_hunter',     205 => 'heavy_hunter',
            206 => 'crusher',          207 => 'battle_ship',
            208 => 'colonizer',        209 => 'recycler',
            210 => 'spy_sonde',        211 => 'bomber_ship',
            212 => 'solar_satelit',    213 => 'destructor',
            214 => 'dearth_star',      215 => 'battleship',
            216 => 'lune_noir',        217 => 'ev_transporter',
            218 => 'star_crasher',     219 => 'giga_recykler',
            220 => 'dm_ship',          221 => 'star_titan',
            222 => 'war_colossus',     223 => 'elite_battleship',
            224 => 'heavy_frigate',
            401 => 'misil_launcher',   402 => 'small_laser',
            403 => 'big_laser',        404 => 'gauss_canyon',
            405 => 'ionic_canyon',     406 => 'buster_canyon',
            407 => 'small_protection_shield', 408 => 'big_protection_shield',
            409 => 'planet_protector', 410 => 'graviton_canyon',
            411 => 'orbital_station',  412 => 'rail_turret',
            413 => 'antimatter_canyon',414 => 'star_bastion',
            415 => 'deflector_shield',
            502 => 'interplanetary_misil', 503 => 'interceptor_misil',
            504 => 'antimatter_misil',     505 => 'advanced_interceptor_misil',
        );
        return isset($map[$id]) ? $map[$id] : null;
    }

    /**
     * Mapa de códigos de texto → emoji
     */
    private function getIconEmoji($icon)
    {
        $map = array(
            'EXP' => '🧭', 'MO' => '💎', 'PRO' => '⛏️', 'SPY' => '🔍',
            'ENE' => '⚡', 'M'  => '⛏️', 'C'  => '💎', 'D'  => '⚗️',
            'DM'  => '💜', 'S'  => '🚀', 'NTX' => '💲',
        );
        return isset($map[$icon]) ? $map[$icon] : '🎁';
    }

    /**
     * Mapa de IDs de REQUISITOS → columna REAL en BD
     */
    private function getRequirementColumn($id)
    {
        $map = array(
            1 => 'metal_mine', 2 => 'crystal_mine', 3 => 'deuterium_sintetizer',
            4 => 'solar_plant', 6 => 'university', 12 => 'fusion_plant',
            14 => 'robot_factory', 15 => 'nano_factory', 21 => 'hangar',
            22 => 'metal_store', 23 => 'crystal_store', 24 => 'deuterium_store',
            31 => 'laboratory', 33 => 'terraformer', 34 => 'ally_deposit',
            41 => 'mondbasis', 42 => 'phalanx', 43 => 'sprungtor', 44 => 'silo',
            106 => 'spy_tech', 108 => 'computer_tech', 109 => 'military_tech',
            110 => 'defence_tech', 111 => 'shield_tech', 113 => 'energy_tech',
            114 => 'hyperspace_tech', 115 => 'combustion_tech',
            117 => 'impulse_motor_tech', 118 => 'hyperspace_motor_tech',
            120 => 'laser_tech', 121 => 'ionic_tech', 122 => 'buster_tech',
            123 => 'intergalactic_tech', 124 => 'expedition_tech',
            131 => 'metal_proc_tech', 132 => 'crystal_proc_tech',
            133 => 'deuterium_proc_tech', 199 => 'graviton_tech',
        );
        return isset($map[$id]) ? $map[$id] : null;
    }

    private function isUnitUnlocked($USER, $PLANET, $unitId)
    {
        global $db;

        if (function_exists('isTechnologieAccessible')) {
            return (bool) isTechnologieAccessible($USER, $PLANET, $unitId);
        }

        $prefix = $this->getPrefix();
        $reqs = $db->select(
            "SELECT requireID, requireLevel
             FROM `".$prefix."vars_requriements`
             WHERE elementID = :eid;",
            array(':eid' => $unitId)
        );

        if (!is_array($reqs) || empty($reqs)) return true;

        foreach ($reqs as $req) {
            $reqId  = (int)$req['requireID'];
            $reqLvl = (int)$req['requireLevel'];

            $col = $this->getUnitColumn($reqId);
            if ($col === null) $col = $this->getRequirementColumn($reqId);
            if ($col === null) continue;

            $current = 0;
            if (isset($PLANET[$col]))      $current = (int)$PLANET[$col];
            elseif (isset($USER[$col]))    $current = (int)$USER[$col];
            else {
                $row = $db->selectSingle(
                    "SELECT `".$col."` AS lvl FROM `".$prefix."planets` WHERE id = :pid;",
                    array(':pid' => $PLANET['id'])
                );
                if ($row && isset($row['lvl'])) $current = (int)$row['lvl'];
                else {
                    $row2 = $db->selectSingle(
                        "SELECT `".$col."` AS lvl FROM `".$prefix."users` WHERE id = :uid;",
                        array(':uid' => $USER['id'])
                    );
                    if ($row2 && isset($row2['lvl'])) $current = (int)$row2['lvl'];
                }
            }

            if ($current < $reqLvl) return false;
        }

        return true;
    }

    private function applyBooster($userId, $boosterId, $prefix)
    {
        global $db;

        if ($boosterId <= 0) return null;

        $booster = $db->selectSingle(
            "SELECT * FROM `".$prefix."boosters` WHERE booster_id = :bid;",
            array(':bid' => $boosterId)
        );

        if (!$booster) return null;

        $duration = isset($booster['booster_duration']) && (int)$booster['booster_duration'] > 0
            ? (int)$booster['booster_duration']
            : 86400;

        $expiresAt = TIMESTAMP + $duration;

        $existing = $db->selectSingle(
            "SELECT id FROM `".$prefix."users_boosters` 
             WHERE user_id = :uid AND booster_id = :bid AND expires_at > :now;",
            array(':uid' => $userId, ':bid' => $boosterId, ':now' => TIMESTAMP)
        );

        if ($existing) {
            $db->update(
                "UPDATE `".$prefix."users_boosters` 
                 SET expires_at = :exp, applied_at = :app
                 WHERE id = :id;",
                array(
                    ':exp' => $expiresAt,
                    ':app' => TIMESTAMP,
                    ':id'  => $existing['id']
                )
            );
        } else {
            $db->insert(
                "INSERT INTO `".$prefix."users_boosters` 
                 (user_id, booster_id, expires_at, applied_at)
                 VALUES (:uid, :bid, :exp, :app);",
                array(
                    ':uid' => $userId,
                    ':bid' => $boosterId,
                    ':exp' => $expiresAt,
                    ':app' => TIMESTAMP
                )
            );
        }

        if (class_exists('BoosterHelper')) {
            BoosterHelper::clearCache($userId);
        }

        return $booster;
    }

    private function filterValidLoots($loots, $USER, $PLANET, $prefix)
    {
        global $db;
        $valid = array();

        foreach ($loots as $loot) {
            $type = $loot['loot_type'];

            if ($type === 'ship' || $type === 'defense') {
                $unitId = (int)$loot['loot_extra_id'];
                if (!$this->isUnitUnlocked($USER, $PLANET, $unitId)) continue;
            }

            if ($type === 'booster') {
                $boosterId = (int)$loot['loot_extra_id'];
                if ($boosterId <= 0) continue;
                $exists = $db->selectSingle(
                    "SELECT booster_id FROM `".$prefix."boosters` WHERE booster_id = :bid;",
                    array(':bid' => $boosterId)
                );
                if (!$exists) continue;
            }

            $valid[] = $loot;
        }

        return $valid;
    }

    // ═══════════════════════════════════════════════════════════════════
    // v2.0 — HELPERS NUEVOS
    // ═══════════════════════════════════════════════════════════════════

    /**
     * v2.0 — % de producción/hora según el tier del ítem.
     * Aplica SOLO a metal/crystal/deuterium. NO a MO, naves, defensas, boosters.
     *
     * Tiers: common / rare / epic / mythic
     * Retorna [pct_min, pct_max] como enteros.
     */
    private function getTierPercentages($tier)
    {
        $map = array(
            'common' => array(20, 40),
            'rare'   => array(40, 60),
            'epic'   => array(60, 80),
            'mythic' => array(80, 100),
        );
        return isset($map[$tier]) ? $map[$tier] : array(20, 40); // default → common
    }

    /**
     * v2.0 — Lee producción/hora del planeta activo.
     * Intenta primero $PLANET['X_perhour']; si no está, query a BD.
     * El valor YA INCLUYE el bonus VIP (lo aplica class.PlanetRessUpdate.php).
     *
     * @param array  $PLANET  Array global del planeta
     * @param string $type    'metal' | 'crystal' | 'deuterium'
     * @return int            Producción/hora (0 si no hay planeta o no hay dato)
     */
    private function getHourlyProduction($PLANET, $type)
    {
        if (!in_array($type, array('metal', 'crystal', 'deuterium'))) return 0;
        if (empty($PLANET) || empty($PLANET['id'])) return 0;

        $col = $type . '_perhour';

        // 1) Ya está en $PLANET (caso normal)
        if (isset($PLANET[$col])) {
            return (int)$PLANET[$col];
        }

        // 2) Fallback: leer de BD y cachear en $PLANET
        global $db;
        $prefix = $this->getPrefix();
        try {
            $row = $db->selectSingle(
                "SELECT `".$col."` AS prod FROM `".$prefix."planets` WHERE id = :pid;",
                array(':pid' => (int)$PLANET['id'])
            );
            if ($row && isset($row['prod'])) {
                $PLANET[$col] = (int)$row['prod'];
                return (int)$row['prod'];
            }
        } catch (Exception $e) {
            // silencioso
        }
        return 0;
    }

    // ═══════════════════════════════════════════════════════════════════
    // v2.0 — getMineFactor() ELIMINADO
    // (el nuevo sistema se basa en producción/hora, no en niveles de minas)
    // ═══════════════════════════════════════════════════════════════════

    /**
     * v2.1 — Mapa de cofres climáticos: acción → [columna, buff_type, nombre legible]
     */
    private function getClimateBoxConfig()
    {
        return array(
            'activate_climate_minor'    => array(
                'col'  => 'box_climate_minor',
                'type' => 'estabilizador_menor',
                'name' => 'Cofre Climático Menor',
            ),
            'activate_climate_major'    => array(
                'col'  => 'box_climate_major',
                'type' => 'estabilizador_mayor',
                'name' => 'Cofre Climático Mayor',
            ),
            'activate_climate_dominion' => array(
                'col'  => 'box_climate_dominion',
                'type' => 'dominio',
                'name' => 'Cofre Climático Legendario',
            ),
        );
    }

    public function show()
    {
        global $USER, $LNG, $db, $PLANET;

        $prefix = $this->getPrefix();

        $action  = HTTP::_GP('action', '');
        $message = '';
        $msgType = 'info';
        $reward  = null;

        // ============================================
        // 🆕 v1.8 — DETECCIÓN DE RIEL DEL JUGADOR
        // ============================================
        $userId     = (int)$USER['id'];
        $isIntl     = ($this->getPlayerMethod($userId) === 'QVAPAY');
        $moneda     = $isIntl ? 'UNTX-20' : 'NTX-20';
        $monedaFiat = $isIntl ? 'USD'     : 'CUP';
        $saldoActual = $isIntl ? (int)($USER['untx20'] ?? 0) : (int)($USER['ntx20'] ?? 0);

        // ============================================
        // CONFIGURACIÓN DE CADA TIPO DE CAJA
        // ============================================
        $boxConfig = array(
            'open'           => array('table' => 'users',         'col' => 'containers',    'mult' => 1, 'label' => 'Contenedor'),
            'open_common'    => array('table' => 'users_market',  'col' => 'box_common',    'mult' => 2, 'label' => 'Cofre Común'),
            'open_rare'      => array('table' => 'users_market',  'col' => 'box_rare',      'mult' => 5, 'label' => 'Cofre Raro'),
            'open_legendary' => array('table' => 'users_market',  'col' => 'box_legendary', 'mult' => 7, 'label' => 'Cofre Legendario'),
        );

        // ============================================
        // 🆕 v2.1 — PROCESAR ACTIVACIÓN DE BUFF CLIMÁTICO
        // ============================================
        $climateBoxConfig = $this->getClimateBoxConfig();

        if (isset($climateBoxConfig[$action])) {
            $cfg  = $climateBoxConfig[$action];
            $col  = $cfg['col'];
            $type = $cfg['type'];
            $name = $cfg['name'];

            // Leer contador del cofre
            $row = $db->selectSingle(
                "SELECT `".$col."` AS cnt FROM `".$prefix."users_market` WHERE user_id = :uid;",
                array(':uid' => $userId)
            );
            $currentCount = $row ? (int)$row['cnt'] : 0;

            if ($currentCount <= 0) {
                $message = '❌ No tienes '.$name.' para activar.';
                $msgType = 'error';
            }
            else if (!class_exists('ClimaEngine')) {
                $message = '❌ Error interno: motor de clima no disponible.';
                $msgType = 'error';
            }
            else {
                // Activar buff (24h por defecto)
                $ok = ClimaEngine::setActiveBuff($userId, $type, 24, 'shop');

                if (!$ok) {
                    $message = '❌ No se pudo activar el buff climático. Inténtalo de nuevo.';
                    $msgType = 'error';
                }
                else {
                    // Decrementar contador del cofre (mínimo 0)
                    $db->update(
                        "UPDATE `".$prefix."users_market` SET `".$col."` = GREATEST(0, `".$col."` - 1) WHERE user_id = :uid;",
                        array(':uid' => $userId)
                    );

                    $buffInfo = ClimaEngine::getBuffInfo(ClimaEngine::getBuffIdFromType($type));
                    $buffName = $buffInfo ? $buffInfo['nombre'] : $name;

                    $message = '✅ ¡'.$name.' activado! Tienes "'.$buffName.'" durante 24 horas.';
                    $msgType = 'success';
                }
            }
        }

        // ============================================
        // PROCESAR APERTURA
        // ============================================

        // 🆕 v2.0 — Guard: sin planeta activo, NO se consume cofre
        if (isset($boxConfig[$action]) && (empty($PLANET) || empty($PLANET['id']))) {
            $message = '❌ No puedes abrir cofres sin un planeta activo.';
            $msgType = 'error';
        }
        elseif (isset($boxConfig[$action])) {

            $cfg   = $boxConfig[$action];
            $table = $cfg['table'];
            $col   = $cfg['col'];
            $mult  = $cfg['mult'];
            $label = $cfg['label'];

            if ($table === 'users') {
                $row = $db->selectSingle(
                    "SELECT `".$col."` AS cnt FROM `".$prefix."users` WHERE id = :uid;",
                    array(':uid' => $USER['id'])
                );
                $currentCount = $row ? (int)$row['cnt'] : 0;
            } else {
                $row = $db->selectSingle(
                    "SELECT `".$col."` AS cnt FROM `".$prefix."users_market` WHERE user_id = :uid;",
                    array(':uid' => $USER['id'])
                );
                $currentCount = $row ? (int)$row['cnt'] : 0;
            }

            if ($currentCount <= 0) {
                $message = '❌ No tienes '.$label.' para abrir.';
                $msgType = 'error';
            }
            else {
                $allLoots = $db->select("SELECT * FROM `".$prefix."container_loot` ORDER BY loot_id ASC;");

                if (empty($allLoots)) {
                    $message = '❌ Error: no hay recompensas configuradas.';
                    $msgType = 'error';
                }
                else {
                    $loots = $this->filterValidLoots($allLoots, $USER, $PLANET, $prefix);

                    if (empty($loots)) {
                        // 🆕 v2.0 — Fallback: prod/hora_metal × 0.20 × mult_cofre
                        $fallbackMetal = (int)($this->getHourlyProduction($PLANET, 'metal') * 0.20 * $mult);

                        $db->update(
                            "UPDATE `".$prefix."planets` SET metal = metal + :val WHERE id = :pid;",
                            array(':val' => $fallbackMetal, ':pid' => $PLANET['id'])
                        );
                        $PLANET['metal'] += $fallbackMetal;

                        $reward = array(
                            'name'   => 'Recursos (respaldo)',
                            'icon'   => '⛏️',
                            'rarity' => 'common',
                            'type'   => 'metal',
                            'value'  => $fallbackMetal,
                        );

                        $message = '✅ ¡'.$label.' abierto! (recompensa de respaldo)';
                        $msgType = 'success';

                        if ($table === 'users') {
                            $db->update(
                                "UPDATE `".$prefix."users` SET
                                    containers = containers - 1,
                                    containers_opened = containers_opened + 1
                                 WHERE id = :uid;",
                                array(':uid' => $USER['id'])
                            );
                            $USER['containers']        -= 1;
                            $USER['containers_opened'] += 1;
                        } else {
                            $db->update(
                                "UPDATE `".$prefix."users_market` SET
                                    `".$col."` = GREATEST(0, `".$col."` - 1)
                                 WHERE user_id = :uid;",
                                array(':uid' => $USER['id'])
                            );
                        }

                        $db->insert(
                            "INSERT INTO `".$prefix."container_history`
                             (user_id, loot_id, loot_value, opened_at)
                             VALUES (:uid, :lid, :val, :time);",
                            array(
                                ':uid'  => $USER['id'],
                                ':lid'  => 0,
                                ':val'  => $fallbackMetal,
                                ':time' => TIMESTAMP
                            )
                        );
                    }
                    else {
                        $roll = mt_rand(1, 10000) / 100;
                        $accumulated = 0;
                        $winner = null;

                        foreach ($loots as $loot) {
                            $accumulated += (float)$loot['loot_chance'];
                            if ($roll <= $accumulated) { $winner = $loot; break; }
                        }

                        // 🆕 v2.0 — Fix bug 0.48%: re-roll defensivo entre tier común
                        // (en vez de devolver end($loots) y regalar el último ítem de la lista)
                        if ($winner === null) {
                            $commons = array();
                            foreach ($loots as $l) {
                                if (isset($l['loot_rarity']) && $l['loot_rarity'] === 'common') {
                                    $commons[] = $l;
                                }
                            }
                            if (!empty($commons)) {
                                $winner = $commons[array_rand($commons)];
                            } else {
                                $winner = end($loots); // último recurso (no debería pasar)
                            }
                        }

                        $reward = array(
                            'name'   => $winner['loot_name'],
                            'icon'   => $this->getIconEmoji($winner['loot_icon']),
                            'rarity' => $winner['loot_rarity'],
                            'type'   => $winner['loot_type'],
                            'value'  => 0,
                        );

                        if ($winner['loot_type'] === 'booster') {
                            $boosterId = (int)$winner['loot_extra_id'];
                            $booster   = $this->applyBooster($USER['id'], $boosterId, $prefix);

                            if ($booster) {
                                $reward['value']    = (int)$booster['booster_value'];
                                $reward['icon']     = $this->getIconEmoji($booster['booster_icon']);
                                $reward['name']     = 'Potenciador: '.$booster['booster_name'];
                                $reward['duration'] = '24h';
                                $message = '🎁 ¡'.$label.' abierto! Has obtenido un POTENCIADOR.';
                                $msgType = 'success';
                            } else {
                                // 🆕 v2.0 — Fallback: prod/hora_metal × 0.20 × mult_cofre
                                $fallbackMetal = (int)($this->getHourlyProduction($PLANET, 'metal') * 0.20 * $mult);

                                $db->update(
                                    "UPDATE `".$prefix."planets` SET metal = metal + :val WHERE id = :pid;",
                                    array(':val' => $fallbackMetal, ':pid' => $PLANET['id'])
                                );
                                $PLANET['metal'] += $fallbackMetal;

                                $reward['name']  = 'Recursos (potenciador no disponible)';
                                $reward['icon']  = '⛏️';
                                $reward['type']  = 'metal';
                                $reward['value'] = $fallbackMetal;

                                $message = '✅ ¡'.$label.' abierto! (recompensa de respaldo)';
                                $msgType = 'success';
                            }
                        }
                        else {
                            // ═══════════════════════════════════════════════════════════════
                            // v2.0 — CÁLCULO DEL VALOR DEL DROP
                            // ═══════════════════════════════════════════════════════════════
                            $lootType   = $winner['loot_type'];
                            $lootRarity = isset($winner['loot_rarity']) ? $winner['loot_rarity'] : 'common';

                            if (in_array($lootType, array('metal', 'crystal', 'deuterium'))) {
                                // Recursos: prod/hora × (tier% / 100) × mult_cofre
                                // Tope natural: 1 hora de producción en el valor base.
                                $pctRange = $this->getTierPercentages($lootRarity);
                                $pct      = mt_rand($pctRange[0], $pctRange[1]);
                                $prod     = $this->getHourlyProduction($PLANET, $lootType);
                                $value    = (int)($prod * ($pct / 100) * $mult);
                            }
                            elseif ($lootType === 'darkmatter') {
                                // MO: rango fijo 250-2500 × mult_cofre
                                $value = (int)(mt_rand(250, 2500) * $mult);
                            }
                            elseif (in_array($lootType, array('ship', 'defense', 'ntx20'))) {
                                // Naves/Defensas/(ntx20 dead code): rango fijo × mult_cofre
                                $value = (int)(mt_rand((int)$winner['loot_value_min'], (int)$winner['loot_value_max']) * $mult);
                            }
                            else {
                                // Tipo desconocido: fallback al comportamiento clásico
                                $value = (int)(mt_rand((int)$winner['loot_value_min'], (int)$winner['loot_value_max']) * $mult);
                            }

                            $reward['value'] = $value;

                            switch ($lootType) {
                                case 'metal':
                                    $db->update("UPDATE `".$prefix."planets` SET metal = metal + :val WHERE id = :pid;",
                                        array(':val' => $value, ':pid' => $PLANET['id']));
                                    $PLANET['metal'] += $value;
                                    break;

                                case 'crystal':
                                    $db->update("UPDATE `".$prefix."planets` SET crystal = crystal + :val WHERE id = :pid;",
                                        array(':val' => $value, ':pid' => $PLANET['id']));
                                    $PLANET['crystal'] += $value;
                                    break;

                                case 'deuterium':
                                    $db->update("UPDATE `".$prefix."planets` SET deuterium = deuterium + :val WHERE id = :pid;",
                                        array(':val' => $value, ':pid' => $PLANET['id']));
                                    $PLANET['deuterium'] += $value;
                                    break;

                                case 'darkmatter':
                                    $db->update("UPDATE `".$prefix."users` SET darkmatter = darkmatter + :val WHERE id = :uid;",
                                        array(':val' => $value, ':uid' => $USER['id']));
                                    $USER['darkmatter'] += $value;
                                    break;

                                // ⚠️ Código muerto: item 19 ya eliminado. Si por alguna razón
                                // aparece, se entrega en la columna del riel del jugador.
                                case 'ntx20':
                                    $colNtx = $isIntl ? 'untx20' : 'ntx20';
                                    $db->update("UPDATE `".$prefix."users` SET `".$colNtx."` = `".$colNtx."` + :val WHERE id = :uid;",
                                        array(':val' => $value, ':uid' => $USER['id']));
                                    $USER[$colNtx] += $value;
                                    break;

                                case 'ship':
                                case 'defense':
                                    $unitId = (int)$winner['loot_extra_id'];
                                    $column = $this->getUnitColumn($unitId);

                                    if ($column !== null) {
                                        $db->update(
                                            "UPDATE `".$prefix."planets` SET `".$column."` = `".$column."` + :val WHERE id = :pid;",
                                            array(':val' => $value, ':pid' => $PLANET['id'])
                                        );
                                        if (isset($PLANET[$column])) $PLANET[$column] += $value;
                                    }
                                    break;
                            }

                            $message = '✅ ¡'.$label.' abierto!';
                            $msgType = 'success';
                        }

                        if ($msgType === 'success') {
                            if ($table === 'users') {
                                $db->update(
                                    "UPDATE `".$prefix."users` SET
                                        containers = containers - 1,
                                        containers_opened = containers_opened + 1
                                     WHERE id = :uid;",
                                    array(':uid' => $USER['id'])
                                );
                                $USER['containers']        -= 1;
                                $USER['containers_opened'] += 1;
                            } else {
                                $db->update(
                                    "UPDATE `".$prefix."users_market` SET
                                        `".$col."` = GREATEST(0, `".$col."` - 1)
                                     WHERE user_id = :uid;",
                                    array(':uid' => $USER['id'])
                                );
                            }

                            $db->insert(
                                "INSERT INTO `".$prefix."container_history`
                                 (user_id, loot_id, loot_value, opened_at)
                                 VALUES (:uid, :lid, :val, :time);",
                                array(
                                    ':uid'  => $USER['id'],
                                    ':lid'  => $winner['loot_id'],
                                    ':val'  => $reward['value'],
                                    ':time' => TIMESTAMP
                                )
                            );
                        }
                    }
                }
            }
        }

        // ============================================
        // CARGAR DATOS PARA LA VISTA
        // ============================================
        $currentContainers = isset($USER['containers']) ? (int)$USER['containers'] : 0;
        $openedCount       = isset($USER['containers_opened']) ? (int)$USER['containers_opened'] : 0;
        $currentNtx        = isset($USER['ntx20']) ? (int)$USER['ntx20'] : 0;

        $marketRow = $db->selectSingle(
            "SELECT box_common, box_rare, box_legendary,
                    box_climate_minor, box_climate_major, box_climate_dominion
             FROM `".$prefix."users_market`
             WHERE user_id = :uid;",
            array(':uid' => $USER['id'])
        );

        $boxCommon    = $marketRow ? (int)$marketRow['box_common']    : 0;
        $boxRare      = $marketRow ? (int)$marketRow['box_rare']      : 0;
        $boxLegendary = $marketRow ? (int)$marketRow['box_legendary'] : 0;

        // 🆕 v2.1 — Cofres climáticos
        $boxClimateMinor    = $marketRow ? (int)$marketRow['box_climate_minor']    : 0;
        $boxClimateMajor    = $marketRow ? (int)$marketRow['box_climate_major']    : 0;
        $boxClimateDominion = $marketRow ? (int)$marketRow['box_climate_dominion'] : 0;

        // 🆕 v2.1 — Buff climático activo
        $activeBuff = null;
        if (class_exists('ClimaEngine')) {
            $activeBuff = ClimaEngine::getActiveBuff($userId);
        }

        $buffSegundosRestantes = 0;
        $buffHorasRestantes    = 0;
        $buffMinutosRestantes  = 0;
        $buffNombreLegible     = '';
        if (!empty($activeBuff) && isset($activeBuff['segundos_restantes'])) {
            $buffSegundosRestantes = (int)$activeBuff['segundos_restantes'];
            $buffHorasRestantes    = (int)floor($buffSegundosRestantes / 3600);
            $buffMinutosRestantes  = (int)floor(($buffSegundosRestantes % 3600) / 60);
            $buffInfo              = ClimaEngine::getBuffInfo($activeBuff['buff_id']);
            $buffNombreLegible     = $buffInfo ? $buffInfo['nombre'] : $activeBuff['buff_type'];
        }

        $history = $db->select(
            "SELECT h.*, l.loot_name, l.loot_icon, l.loot_rarity
             FROM `".$prefix."container_history` h
             LEFT JOIN `".$prefix."container_loot` l ON l.loot_id = h.loot_id
             WHERE h.user_id = :uid
             ORDER BY h.opened_at DESC
             LIMIT 10;",
            array(':uid' => $USER['id'])
        );

        if (!is_array($history)) $history = array();

        foreach ($history as &$h) {
            $h['loot_icon_emoji'] = $this->getIconEmoji($h['loot_icon']);
        }
        unset($h);

        $this->assign(array(
            'containersCount'  => $currentContainers,
            'containersOpened' => $openedCount,
            'currentNtx'       => $currentNtx,

            // 🆕 v1.8 — DUAL RIEL (variables canónicas)
            'moneda'           => $moneda,
            'moneda_fiat'      => $monedaFiat,
            'es_internacional' => $isIntl,
            'saldo_actual'     => $saldoActual,

            'boxCommon'        => $boxCommon,
            'boxRare'          => $boxRare,
            'boxLegendary'     => $boxLegendary,

            // 🆕 v2.1 — Cofres climáticos
            'boxClimateMinor'    => $boxClimateMinor,
            'boxClimateMajor'    => $boxClimateMajor,
            'boxClimateDominion' => $boxClimateDominion,

            // 🆕 v2.1 — Buff climático activo
            'activeBuff'           => $activeBuff,
            'buffSegundosRestantes' => $buffSegundosRestantes,
            'buffHorasRestantes'    => $buffHorasRestantes,
            'buffMinutosRestantes'  => $buffMinutosRestantes,
            'buffNombreLegible'     => $buffNombreLegible,

            // 🆕 v2.0 — Factor minas DEPRECATED (ya no se usa en el cálculo).
            // Se mantiene la key por compatibilidad con el template v3.5.
            'factorMinas'      => 1.0,

            // 🆕 v2.0 — Tabla de % por tier (por si el template quiere mostrarla)
            'tierPcts'         => array(
                'common' => array(20, 40),
                'rare'   => array(40, 60),
                'epic'   => array(60, 80),
                'mythic' => array(80, 100),
            ),

            'history'          => $history,
            'reward'           => $reward,
            'message'          => $message,
            'msgType'          => $msgType,
            'pageTitle'        => 'Contenedores',
        ));

        $this->display('page.containers.default.tpl');
    }
}