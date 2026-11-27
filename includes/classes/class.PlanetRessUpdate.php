<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 *
 * ✅ AstroIO v1.0 (Bonos integrados):
 *   - Boosters (potenciadores) en hash + producción
 *   - Razas/Facciones en hash + producción
 *   - VIP Prime en hash + producción
 *   - Arbol de Talentos de Alianza en hash + producción
 *
 * ✅ AstroIO v1.1 (POTENCIADORES - FALLBACK DIRECTO):
 *   - Nuevo método privado getDirectBoosterBonus() que lee DIRECTAMENTE
 *     de `uni1_users_boosters` + `uni1_boosters` (sin depender de BoosterHelper)
 *   - Si BoosterHelper existe → se usa (comportamiento original)
 *   - Si NO existe → se usa el fallback directo
 *   - Aplica para:
 *       ⛏️ Pot. Minero   → booster_type = 'resources'  (+20% recursos)
 *       ⚡ Pot. Energía  → booster_type = 'energy'     (+20% energía)
 *   - Se aplica en DOS lugares:
 *       1) CreateHash()      → invalida caché al cambiar potenciadores
 *       2) ReBuildCache()    → aplica el bonus a la producción real
 *
 * ✅ AstroIO v1.2 (FIX CRÍTICO - Módulo de Ataque):
 *   - BUG: SetNextQueueElementOnTop() crasheaba con "Trying to access
 *     array offset on value of type null" cuando `b_building_id` contenía
 *     datos corruptos o una cola vacía serializada ("a:0:{}").
 *   - EFECTO: al atacar, MissionCaseAttack::TargetEvent() llama a
 *     CalcResource() → BuildingQueue() → SetNextQueueElementOnTop()
 *     y CRASHEABA. Por eso no había combate, ni reporte, ni saqueo.
 *   - FIX: se valida que $CurrentQueue sea un array no vacío y que
 *     $CurrentQueue[0] sea un array antes de acceder. Se hace en DOS
 *     puntos:
 *       1) ANTES del while (validación inicial tras unserialize)
 *       2) AL INICIO de cada iteración del while (guard de seguridad)
 *   - Comportamiento: si la cola es inválida, se limpia a estado vacío
 *     (b_building=0, b_building_id='') y se retorna false sin crashear.
 *
 * ✅ AstroIO v1.3 (COLAS SEPARADAS - NAVES Y DEFENSAS):
 *   - Ahora las NAVES se construyen en `b_hangar_id` / `b_hangar`
 *     y las DEFENSAS/MISILES en `b_defense_id` / `b_defense`.
 *   - ShipyardQueue() procesa AMBAS colas de forma independiente.
 *   - SavePlanetToDB() guarda AMBAS colas en la BD.
 *
 * ✅ AstroIO v1.4 (MÍSTICOS):
 *   - Se integra MisticHelper para aplicar los bonus de producción
 *     de recursos y energía (EARTH, CORRUPT, BENEFIT, VOID).
 */

// ============================================
// ASTROIO - Cargar MisticHelper explicitamente
// ============================================
if (!class_exists('MisticHelper')) {
    $__misticFile = ROOT_PATH . 'includes/classes/MisticHelper.class.php';
    if (file_exists($__misticFile)) {
        require_once $__misticFile;
    }
}
// ============================================

class ResourceUpdate
{

        /**
         * reference of the config object
         * @var Config
         */
        private $config                 = NULL;

        private $isGlobalMode   = NULL;
        private $TIME                   = NULL;
        private $HASH                   = NULL;
        private $ProductionTime = NULL;

        private $PLANET                 = array();
        private $USER                   = array();
        private $Builded                = array();

        private $Build;
        private $Tech;

        function __construct($Build = true, $Tech = true)
        {
                $this->Build    = $Build;
                $this->Tech             = $Tech;
        }

        public function setData($USER, $PLANET)
        {
                $this->USER             = $USER;
                $this->PLANET   = $PLANET;
        }

        public function getData()
        {
                return array($this->USER, $this->PLANET);
        }

        /**
         * 🆕 AstroIO v1.1 - Fallback directo si BoosterHelper no existe
         * ------------------------------------------------------------
         * Lee el valor total de un potenciador activo del jugador,
         * filtrando por su `booster_type`, DIRECTAMENTE de la BD.
         *
         * @param int    $userId  ID del jugador
         * @param string $type    Tipo de booster ('resources', 'energy', etc.)
         * @return int            Valor total del bonus (sin dividir por 100)
         */
        private function getDirectBoosterBonus($userId, $type)
        {
                try {
                        $db = Database::get();
                        $prefix = 'uni1_';
                        if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
                        elseif (defined('PREFIX')) $prefix = PREFIX;

                        $row = $db->selectSingle(
                                "SELECT SUM(b.booster_value) AS total_bonus
                                 FROM `".$prefix."users_boosters` ub
                                 INNER JOIN `".$prefix."boosters` b ON b.booster_id = ub.booster_id
                                 WHERE ub.user_id = :uid 
                                   AND ub.expires_at > :now
                                   AND b.booster_type = :type;",
                                array(
                                        ':uid'  => (int) $userId,
                                        ':now'  => TIMESTAMP,
                                        ':type' => $type,
                                )
                        );
                        return !empty($row['total_bonus']) ? (int) $row['total_bonus'] : 0;
                } catch (Exception $e) {
                        return 0;
                }
        }
        
        public function ReturnVars() {
                if($this->isGlobalMode)
                {
                        $GLOBALS['USER']        = $this->USER;
                        $GLOBALS['PLANET']      = $this->PLANET;
                        return true;
                } else {
                        return array($this->USER, $this->PLANET);
                }
        }
        
        public function CreateHash() {
                global $reslist, $resource;
                $Hash   = array();
                foreach($reslist['prod'] as $ID) {
                        $Hash[] = $this->PLANET[$resource[$ID]];
                        // FIX v2.4.7 — mismo ajuste del porcentaje que en ReBuildCache
                        // para que el hash sea coherente con el cálculo real.
                        $porcentHash    = $this->PLANET[$resource[$ID].'_porcent'];
                        if (empty($porcentHash) || (int)$porcentHash < 1) {
                                $porcentHash = 10;
                        }
                        $Hash[] = $porcentHash;
                }
                
                $ressource      = array_merge(array(), $reslist['resstype'][1], $reslist['resstype'][2]);
                foreach($ressource as $ID) {
                        // 🆕 v2.4.0 — Norium/Germanium no tienen ingreso básico de configuración
                        if ($ID == 932 || $ID == 933) { $Hash[] = 0; continue; }
                        $Hash[] = $this->config->{$resource[$ID].'_basic_income'};
                }
                
                $Hash[] = $this->config->resource_multiplier;
                $Hash[] = $this->config->storage_multiplier;
                $Hash[] = $this->config->energySpeed;
                $Hash[] = $this->USER['factor']['Resource'];
                $Hash[] = $this->USER['factor']['Energy'];
                $Hash[] = $this->PLANET[$resource[22]];
                $Hash[] = $this->PLANET[$resource[23]];
                $Hash[] = $this->PLANET[$resource[24]];
                // 🆕 v2.4.0 — Almacenes de Norio (25) / Germanio (26) en el hash
                $Hash[] = isset($resource[25])  && isset($this->PLANET[$resource[25]])  ? $this->PLANET[$resource[25]]  : 0;
                $Hash[] = isset($resource[26])  && isset($this->PLANET[$resource[26]])  ? $this->PLANET[$resource[26]]  : 0;
                $Hash[] = $this->USER[$resource[131]];
                $Hash[] = $this->USER[$resource[132]];
                $Hash[] = $this->USER[$resource[133]];
                // 🆕 v2.4.0 — Técnicas de procesado de Norium (134) / Germanium (135)
                if (isset($resource[134]) && isset($this->USER[$resource[134]]))
                        $Hash[] = $this->USER[$resource[134]];
                if (isset($resource[135]) && isset($this->USER[$resource[135]]))
                        $Hash[] = $this->USER[$resource[135]];
                // 🆕 v2.4.0 — Taladrador de Norio (234): +0.02% de producción por nave
                if (isset($resource[234]) && isset($this->PLANET[$resource[234]]))
                        $Hash[] = $this->PLANET[$resource[234]];
                
                // ============================================
                // ASTROIO v1.1 - Añadir bonos al hash
                // (potenciadores + razas/facciones + VIP + Arbol de Talentos)
                // ------------------------------------------------------------
                // El hash DEBE incluir los bonus para que cuando un potenciador
                // se active/desactive, la caché se invalide y la producción
                // se recalcule automáticamente en el siguiente request.
                // ============================================
                
                // ⛏️ Pot. Minero (+20% recursos) y ⚡ Pot. Energía (+20% energía)
                if (class_exists('BoosterHelper')) {
                        $Hash[] = BoosterHelper::getBonus($this->USER['id'], 'resources');
                        $Hash[] = BoosterHelper::getBonus($this->USER['id'], 'energy');
                } else {
                        // Fallback directo si BoosterHelper no existe
                        $Hash[] = $this->getDirectBoosterBonus($this->USER['id'], 'resources');
                        $Hash[] = $this->getDirectBoosterBonus($this->USER['id'], 'energy');
                }
                
                if (class_exists('RaceFactionHelper')) {
                        $Hash[] = RaceFactionHelper::getBonus($this->USER['id'], 'bonus_resources');
                        $Hash[] = RaceFactionHelper::getBonus($this->USER['id'], 'bonus_energy');
                        $Hash[] = RaceFactionHelper::getBonus($this->USER['id'], 'bonus_storage');
                }
                
                if (!class_exists('VIPHelper')) {
                        require_once ROOT_PATH . 'includes/classes/VIPHelper.class.php';
                }
                if (class_exists('VIPHelper')) {
                        $Hash[] = VIPHelper::getBonus($this->USER['id'], 'production');
                }

                // NUEVO: Bonus de produccion del Arbol de Talentos de Alianza
                if (!class_exists('AllianceTalentHelper')) {
                        require_once ROOT_PATH . 'includes/classes/AllianceTalentHelper.class.php';
                }
                if (class_exists('AllianceTalentHelper')) {
                        $allyBonuses    = AllianceTalentHelper::getBonusesForUserCached($this->USER['id']);
                        $Hash[]                 = $allyBonuses['production'];
                }

                // ============================================
                // ASTROIO v1.4 - Añadir bonos Místicos al hash
                // ============================================
                if (class_exists('MisticHelper')) {
                        $misticHash = MisticHelper::getBonuses($this->USER['id']);
                        if (!empty($misticHash)) {
                                $Hash[] = json_encode($misticHash);
                        }
                }
                // ============================================
                
                return md5(implode("::", $Hash));
        }
        
        public function CalcResource($USER = NULL, $PLANET = NULL, $SAVE = false, $TIME = NULL, $HASH = true)
        {                       
                $this->isGlobalMode     = !isset($USER, $PLANET) ? true : false;
                $this->USER                     = $this->isGlobalMode ? $GLOBALS['USER'] : $USER;
                $this->PLANET           = $this->isGlobalMode ? $GLOBALS['PLANET'] : $PLANET;
                $this->TIME                     = is_null($TIME) ? TIMESTAMP : $TIME;
                $this->config           = Config::get($this->USER['universe']);
                
                if($this->USER['urlaubs_modus'] == 1)
                        return $this->ReturnVars();
                
                if($this->Build)
                {
                        $this->ShipyardQueue();
                        if($this->Tech == true && $this->USER['b_tech'] != 0 && $this->USER['b_tech'] < $this->TIME)
                                $this->ResearchQueue();
                        if($this->PLANET['b_building'] != 0)
                                $this->BuildingQueue();
                }
                
                $this->UpdateResource($this->TIME, $HASH);
                        
                if($SAVE === true)
                        $this->SavePlanetToDB($this->USER, $this->PLANET);
                        
                return $this->ReturnVars();
        }
        
        public function UpdateResource($TIME, $HASH = false)
        {
                $this->ProductionTime                   = ($TIME - $this->PLANET['last_update']);
                
                if($this->ProductionTime > 0)
                {
                        $this->PLANET['last_update']    = $TIME;
                        if($HASH === false) {
                                $this->ReBuildCache();
                        } else {
                                $this->HASH             = $this->CreateHash();

                                if($this->PLANET['eco_hash'] !== $this->HASH) {
                                        $this->PLANET['eco_hash'] = $this->HASH;
                                        $this->ReBuildCache();
                                }
                        }
                        $this->ExecCalc();
                }
        }
        
        private function ExecCalc()
        {
                if($this->PLANET['planet_type'] == 3)
                        return;
                        
                $MaxMetalStorage                = $this->PLANET['metal_max']     * $this->config->max_overflow;
                $MaxCristalStorage              = $this->PLANET['crystal_max']   * $this->config->max_overflow;
                $MaxDeuteriumStorage    = $this->PLANET['deuterium_max'] * $this->config->max_overflow;
                // 🆕 v2.4.0 — Capacidad máxima de Norium y Germanium
                $MaxNoriumStorage               = $this->PLANET['norium_max']     * $this->config->max_overflow;
                $MaxGermaniumStorage    = $this->PLANET['germanium_max'] * $this->config->max_overflow;

                // ============================================
                // ASTROIO - Guardar recursos ANTES de producir
                // ============================================
                $astroioMetalBefore   = (float)$this->PLANET['metal'];
                $astroioCrystalBefore = (float)$this->PLANET['crystal'];
                $astroioDeutBefore    = (float)$this->PLANET['deuterium'];
                $astroioNoriumBefore  = isset($this->PLANET['norium'])    ? (float)$this->PLANET['norium']    : 0;
                $astroioGermanBefore  = isset($this->PLANET['germanium']) ? (float)$this->PLANET['germanium'] : 0;
                // ============================================
                
                $MetalTheoretical               = $this->ProductionTime * (($this->config->metal_basic_income * $this->config->resource_multiplier) + $this->PLANET['metal_perhour']) / 3600;
                
                if($MetalTheoretical < 0)
                {
                        $this->PLANET['metal']      = max($this->PLANET['metal'] + $MetalTheoretical, 0);
                } 
                elseif ($this->PLANET['metal'] <= $MaxMetalStorage)
                {
                        $this->PLANET['metal']      = min($this->PLANET['metal'] + $MetalTheoretical, $MaxMetalStorage);
                }
                
                $CristalTheoretical     = $this->ProductionTime * (($this->config->crystal_basic_income * $this->config->resource_multiplier) + $this->PLANET['crystal_perhour']) / 3600;
                if ($CristalTheoretical < 0)
                {
                        $this->PLANET['crystal']      = max($this->PLANET['crystal'] + $CristalTheoretical, 0);
                } 
                elseif ($this->PLANET['crystal'] <= $MaxCristalStorage ) 
                {
                        $this->PLANET['crystal']      = min($this->PLANET['crystal'] + $CristalTheoretical, $MaxCristalStorage);
                }
                
                $DeuteriumTheoretical   = $this->ProductionTime * (($this->config->deuterium_basic_income * $this->config->resource_multiplier) + $this->PLANET['deuterium_perhour']) / 3600;
                if ($DeuteriumTheoretical < 0)
                {
                        $this->PLANET['deuterium']    = max($this->PLANET['deuterium'] + $DeuteriumTheoretical, 0);
                } 
                elseif($this->PLANET['deuterium'] <= $MaxDeuteriumStorage) 
                {
                        $this->PLANET['deuterium']    = min($this->PLANET['deuterium'] + $DeuteriumTheoretical, $MaxDeuteriumStorage);
                }
                
                $this->PLANET['metal']          = max($this->PLANET['metal'], 0);
                $this->PLANET['crystal']        = max($this->PLANET['crystal'], 0);
                $this->PLANET['deuterium']      = max($this->PLANET['deuterium'], 0);

                // ============================================
                // 🆕 v2.4.0 — Producción de Norium y Germanium
                // (sin ingreso básico de configuración: solo minas 7/17;
                //  con tope de almacén igual que los recursos clásicos)
                // ============================================
                if (isset($this->PLANET['norium']) && isset($this->PLANET['norium_perhour']))
                {
                        $NoriumTheoretical      = $this->ProductionTime * $this->PLANET['norium_perhour'] / 3600;
                        if($NoriumTheoretical < 0) {
                                $this->PLANET['norium'] = max($this->PLANET['norium'] + $NoriumTheoretical, 0);
                        } elseif ($this->PLANET['norium'] <= $MaxNoriumStorage) {
                                $this->PLANET['norium'] = min($this->PLANET['norium'] + $NoriumTheoretical, $MaxNoriumStorage);
                        }
                        $this->PLANET['norium'] = max($this->PLANET['norium'], 0);
                }

                if (isset($this->PLANET['germanium']) && isset($this->PLANET['germanium_perhour']))
                {
                        $GermaniumTheoretical   = $this->ProductionTime * $this->PLANET['germanium_perhour'] / 3600;
                        if($GermaniumTheoretical < 0) {
                                $this->PLANET['germanium'] = max($this->PLANET['germanium'] + $GermaniumTheoretical, 0);
                        } elseif ($this->PLANET['germanium'] <= $MaxGermaniumStorage) {
                                $this->PLANET['germanium'] = min($this->PLANET['germanium'] + $GermaniumTheoretical, $MaxGermaniumStorage);
                        }
                        $this->PLANET['germanium'] = max($this->PLANET['germanium'], 0);
                }
                // ============================================

                // ============================================
                // ASTROIO - Sumar recursos producidos al evento "get_resources"
                // ============================================
                $astroioMetalDiff   = $this->PLANET['metal']     - $astroioMetalBefore;
                $astroioCrystalDiff = $this->PLANET['crystal']   - $astroioCrystalBefore;
                $astroioDeutDiff    = $this->PLANET['deuterium'] - $astroioDeutBefore;

                $astroioProduced = max(0, $astroioMetalDiff)
                                 + max(0, $astroioCrystalDiff)
                                 + max(0, $astroioDeutDiff)
                                 + max(0, $this->PLANET['norium']   - $astroioNoriumBefore)
                                 + max(0, $this->PLANET['germanium'] - $astroioGermanBefore);

                if ($astroioProduced > 0 && class_exists('EventHelper')) {
                        EventHelper::updateProgress($this->USER['id'], 'get_resources', (int)$astroioProduced);
                }
                // ============================================
        }
        
        public static function getProd($Calculation)
        {
                return 'return '.$Calculation.';';
        }
        
        public static function getNetworkLevel($USER, $PLANET)
        {
                global $resource;

                $researchLevelList      = array($PLANET[$resource[31]]);
                if($USER[$resource[123]] > 0)
                {
                        $sql = 'SELECT '.$resource[31].' FROM %%PLANETS%% WHERE id != :planetId AND id_owner = :userId AND destruyed = 0 ORDER BY '.$resource[31].' DESC LIMIT :limit;';
                        $researchResult = Database::get()->select($sql, array(
                                ':limit'        => (int) $USER[$resource[123]],
                                ':planetId'     => $PLANET['id'],
                                ':userId'       => $USER['id']
                        ));

                        foreach($researchResult as $researchRow)
                        {
                                $researchLevelList[]    = $researchRow[$resource[31]];
                        }
                }
                
                return $researchLevelList;
        }
        
        public function ReBuildCache()
        {
                global $ProdGrid, $resource, $reslist;
                
                if ($this->PLANET['planet_type'] == 3)
                {
                        $this->config->metal_basic_income       = 0;
                        $this->config->crystal_basic_income     = 0;
                        $this->config->deuterium_basic_income   = 0;
                }
                
                $temp   = array(
                        901     => array(
                                'max'   => 0,
                                'plus'  => 0,
                                'minus' => 0,
                        ),
                        902     => array(
                                'max'   => 0,
                                'plus'  => 0,
                                'minus' => 0,
                        ),
                        903     => array(
                                'max'   => 0,
                                'plus'  => 0,
                                'minus' => 0,
                        ),
                        911     => array(
                                'plus'  => 0,
                                'minus' => 0,
                        ),
                        // 🆕 v2.4.0 — Recursos nuevos Norium (932) y Germanium (933)
                        932     => array(
                                'max'   => 0,
                                'plus'  => 0,
                                'minus' => 0,
                        ),
                        933     => array(
                                'max'   => 0,
                                'plus'  => 0,
                                'minus' => 0,
                        )
                );

                $BuildTemp              = $this->PLANET['temp_max'];
                $BuildEnergy    = $this->USER[$resource[113]];

                // 🆕 v2.4.0 — los recursos nuevos participan del mismo bucle de
                // almacenaje y producción (minas 7/17, almacenes 25/26, proc. 134/135).
                // resstype[1] ya incluye 932/933, no hay que añadirlos aquí.
                $ressIDs        = array_merge(array(), $reslist['resstype'][1], $reslist['resstype'][2]);

                foreach($reslist['storage'] as $ProdID)
                {
                        foreach($ressIDs as $ID)
                        {
                                if(!isset($ProdGrid[$ProdID]['storage'][$ID]))
                                        continue;

                                $BuildLevel             = $this->PLANET[$resource[$ProdID]];
                                $temp[$ID]['max']       += round(eval(self::getProd($ProdGrid[$ProdID]['storage'][$ID])));
                        }
                }

                foreach($reslist['prod'] as $ProdID)
                {
                        $BuildLevelFactor       = $this->PLANET[$resource[$ProdID].'_porcent'];
                        // FIX v2.4.7 — Porcentaje de producción a 0:
                        // los planetas creados antes de la migración de Norium/Germanium
                        // quedaron con norium_mine_porcent / germanium_mine_porcent = 0
                        // (DEFAULT '0' de migration_10), lo que anulaba SU producción
                        // Y su consumo de energía (ambos van escalados por el porcentaje).
                        // Nunca es legítimo un porcentaje < 1: se usa 100% (10).
                        if (empty($BuildLevelFactor) || (int)$BuildLevelFactor < 1) {
                                $BuildLevelFactor = 10;
                        }
                        $BuildLevel             = $this->PLANET[$resource[$ProdID]];
                        
                        foreach($ressIDs as $ID) 
                        {
                                if(!isset($ProdGrid[$ProdID]['production'][$ID]))
                                        continue;
                                
                                $Production     = eval(self::getProd($ProdGrid[$ProdID]['production'][$ID]));
                                
                                if($Production > 0) {                                   
                                        $temp[$ID]['plus']      += $Production;
                                } else {
                                        if(in_array($ID, $reslist['resstype'][1]) && $this->PLANET[$resource[$ID]] == 0) {
                                                 continue;
                                        }
                                        
                                        $temp[$ID]['minus']     += $Production;
                                }
                        }
                }

                // ============================================
                // ASTROIO v1.1 - Cargar TODOS los bonos
                // (potenciadores + razas/facciones + VIP + Arbol de Talentos)
                // ------------------------------------------------------------
                // ⛏️ Pot. Minero   → booster_type = 'resources'  (+20% recursos)
                // ⚡ Pot. Energía  → booster_type = 'energy'     (+20% energía)
                // ============================================
                $boosterResources       = 0;
                $boosterEnergy          = 0;
                $raceResources          = 0;
                $raceEnergy                     = 0;
                $raceStorage            = 0;
                $vipResources           = 0;
                $vipEnergy                      = 0;
                $bankResources          = 0;
                
                // ⛏️ Pot. Minero + ⚡ Pot. Energía
                if (class_exists('BoosterHelper')) {
                        $boosterResources       = BoosterHelper::getBonus($this->USER['id'], 'resources') / 100;
                        $boosterEnergy          = BoosterHelper::getBonus($this->USER['id'], 'energy') / 100;
                } else {
                        // Fallback directo si BoosterHelper no existe
                        $boosterResources       = $this->getDirectBoosterBonus($this->USER['id'], 'resources') / 100;
                        $boosterEnergy          = $this->getDirectBoosterBonus($this->USER['id'], 'energy') / 100;
                }
                
                // Razas y Facciones
                if (class_exists('RaceFactionHelper')) {
                        $raceResources          = RaceFactionHelper::getBonus($this->USER['id'], 'bonus_resources') / 100;
                        $raceEnergy                     = RaceFactionHelper::getBonus($this->USER['id'], 'bonus_energy') / 100;
                        $raceStorage            = RaceFactionHelper::getBonus($this->USER['id'], 'bonus_storage') / 100;
                }
                
                // VIP - Bonus de producción
                if (!class_exists('VIPHelper')) {
                        require_once ROOT_PATH . 'includes/classes/VIPHelper.class.php';
                }
                if (class_exists('VIPHelper')) {
                        $vipResources   = VIPHelper::getBonus($this->USER['id'], 'production');
                }

                // NUEVO: Arbol de Talentos de Alianza - Bonus de produccion
                if (!class_exists('AllianceTalentHelper')) {
                        require_once ROOT_PATH . 'includes/classes/AllianceTalentHelper.class.php';
                }
                if (class_exists('AllianceTalentHelper')) {
                        $allyBonuses    = AllianceTalentHelper::getBonusesForUserCached($this->USER['id']);
                        $bankResources  = (float)$allyBonuses['production'];
                }

                                // ============================================
                // ASTROIO v1.5 - Cargar bonos de Místicos
                // ============================================
                $misticGeneralResources = 0;
                $misticEnergy = 0;
                $misticMetal = 0;
                $misticCrystal = 0;
                $misticDeuterium = 0;
                $misticStorage = 0; // 🆕 NUEVO: Almacenamiento Mecric

                if (class_exists('MisticHelper')) {
                        $misticBonuses = MisticHelper::getBonuses($this->USER['id']);
                        $misticGeneralResources = isset($misticBonuses['produccion_recursos']) ? ($misticBonuses['produccion_recursos'] / 100) : 0;
                        $misticEnergy = isset($misticBonuses['produccion_energia']) ? ($misticBonuses['produccion_energia'] / 100) : 0;
                        $misticMetal = isset($misticBonuses['produccion_metal']) ? ($misticBonuses['produccion_metal'] / 100) : 0;
                        $misticCrystal = isset($misticBonuses['produccion_cristal']) ? ($misticBonuses['produccion_cristal'] / 100) : 0;
                        $misticDeuterium = isset($misticBonuses['produccion_deuterio']) ? ($misticBonuses['produccion_deuterio'] / 100) : 0;
                        $misticStorage = isset($misticBonuses['almacenamiento']) ? ($misticBonuses['almacenamiento'] / 100) : 0; // 🆕 NUEVO
                }
                // ============================================
                
                // Suma total de bonos
                $totalResources = $boosterResources + $raceResources + $vipResources + $bankResources;
                $totalEnergy    = $boosterEnergy + $raceEnergy + $vipEnergy;
                // ============================================

                                $this->PLANET['metal_max']                      = $temp[901]['max'] * $this->config->storage_multiplier * (1 + $this->USER['factor']['ResourceStorage'] + $raceStorage + $misticStorage);
                $this->PLANET['crystal_max']            = $temp[902]['max'] * $this->config->storage_multiplier * (1 + $this->USER['factor']['ResourceStorage'] + $raceStorage + $misticStorage);
                $this->PLANET['deuterium_max']          = $temp[903]['max'] * $this->config->storage_multiplier * (1 + $this->USER['factor']['ResourceStorage'] + $raceStorage + $misticStorage);
                // 🆕 v2.4.0 — Almacenaje de Norium y Germanium (almacenes 25/26, mismo patrón)
                $this->PLANET['norium_max']                     = $temp[932]['max'] * $this->config->storage_multiplier * (1 + $this->USER['factor']['ResourceStorage'] + $raceStorage + $misticStorage);
                $this->PLANET['germanium_max']          = $temp[933]['max'] * $this->config->storage_multiplier * (1 + $this->USER['factor']['ResourceStorage'] + $raceStorage + $misticStorage);

                // ============================================
                // ASTROIO - Aplicar bonos a la producción de energía
                // (⚡ Pot. Energía incluido en $totalEnergy)
                // ============================================
                $this->PLANET['energy']                         = round($temp[911]['plus'] * $this->config->energySpeed * (1 + $this->USER['factor']['Energy'] + $totalEnergy + $misticEnergy));
                // ============================================
                
                $this->PLANET['energy_used']            = $temp[911]['minus'] * $this->config->energySpeed;

                // 🆕 v2.4.0 — Taladrador de Norio (234): +0.02% de producción por nave
                // del planeta (factor de planeta, nunca dentro de la fórmula de la mina).
                $drillBonus     = 0.0002 * (float) (isset($resource[234]) && isset($this->PLANET[$resource[234]]) ? $this->PLANET[$resource[234]] : 0);

                if($this->PLANET['energy_used'] == 0) {
                        $this->PLANET['metal_perhour']          = 0;
                        $this->PLANET['crystal_perhour']        = 0;
                        $this->PLANET['deuterium_perhour']      = 0;
                        $this->PLANET['norium_perhour']         = 0;
                        $this->PLANET['germanium_perhour']      = 0;
                } else {
                        $prodLevel      = min(1, $this->PLANET['energy'] / abs($this->PLANET['energy_used']));

                        // ============================================
                        // ASTROIO - Aplicar bonos a la producción de recursos
                        // (⛏️ Pot. Minero incluido en $totalResources)
                        // ============================================
                        $this->PLANET['metal_perhour']          = (($temp[901]['plus'] * (1 + $this->USER['factor']['Resource'] + 0.02 * $this->USER[$resource[131]] + $totalResources + $misticGeneralResources + $misticMetal) * $prodLevel + $temp[901]['minus']) * $this->config->resource_multiplier) * (1 + $drillBonus);
                        $this->PLANET['crystal_perhour']        = (($temp[902]['plus'] * (1 + $this->USER['factor']['Resource'] + 0.02 * $this->USER[$resource[132]] + $totalResources + $misticGeneralResources + $misticCrystal) * $prodLevel + $temp[902]['minus']) * $this->config->resource_multiplier) * (1 + $drillBonus);
                        $this->PLANET['deuterium_perhour']      = (($temp[903]['plus'] * (1 + $this->USER['factor']['Resource'] + 0.02 * $this->USER[$resource[133]] + $totalResources + $misticGeneralResources + $misticDeuterium) * $prodLevel + $temp[903]['minus']) * $this->config->resource_multiplier) * (1 + $drillBonus);
                        // 🆕 v2.4.0 — Producción de Norium (mina 7 + proc. 134) y Germanium (mina 17 + proc. 135):
                        // heredan bonus de razas (bonus_resources), potenciadores, VIP y árbol de talentos igual que los clásicos.
                        $this->PLANET['norium_perhour']         = (($temp[932]['plus'] * (1 + $this->USER['factor']['Resource'] + (isset($resource[134]) && isset($this->USER[$resource[134]]) ? 0.02 * $this->USER[$resource[134]] : 0) + $totalResources + $misticGeneralResources) * $prodLevel + $temp[932]['minus']) * $this->config->resource_multiplier) * (1 + $drillBonus);
                        $this->PLANET['germanium_perhour']      = (($temp[933]['plus'] * (1 + $this->USER['factor']['Resource'] + (isset($resource[135]) && isset($this->USER[$resource[135]]) ? 0.02 * $this->USER[$resource[135]] : 0) + $totalResources + $misticGeneralResources) * $prodLevel + $temp[933]['minus']) * $this->config->resource_multiplier) * (1 + $drillBonus);
                        // ============================================
                }
        }
        
        /**
         * ✅ AstroIO v1.3 - Cola de Astillero separada
         * ------------------------------------------------------------
         * Procesa DOS colas independientes:
         *   - b_hangar_id  / b_hangar   → NAVES (fleet)
         *   - b_defense_id / b_defense  → DEFENSAS y MISILES (defense + missile)
         * Ambas avanzan en paralelo usando el mismo delta de tiempo.
         */
        private function ShipyardQueue()
        {
                global $resource, $reslist;

                // Calculamos el delta de tiempo una sola vez
                $delta  = ($this->TIME - $this->PLANET['last_update']);

                // ----- 1) Cola de NAVES -----
                $this->PLANET['b_hangar']       += $delta;
                $this->processQueue('b_hangar_id', 'b_hangar', $reslist['fleet'], 'build_ships');

                // ----- 2) Cola de DEFENSAS -----
                if (isset($this->PLANET['b_defense']))
                        $this->PLANET['b_defense']      += $delta;
                $this->processQueue('b_defense_id', 'b_defense', array_merge($reslist['defense'], $reslist['missile']), NULL);

                return true;
        }

        /**
         * Procesa una cola genérica (naves o defensas)
         *
         * @param string $queueField  Nombre del campo serializado (b_hangar_id / b_defense_id)
         * @param string $timeField   Nombre del campo contador    (b_hangar / b_defense)
         * @param array  $allowedElements Lista de IDs válidos (fleet o defense+missile)
         * @param string|null $eventName  Nombre del evento a actualizar (o NULL si no aplica)
         */
        private function processQueue($queueField, $timeField, $allowedElements, $eventName = NULL)
        {
                global $resource;

                // Si la columna no existe en el array del planeta, no hay nada que hacer
                if (!array_key_exists($queueField, $this->PLANET))
                        return false;

                $BuildQueue     = (!empty($this->PLANET[$queueField])) ? unserialize($this->PLANET[$queueField]) : array();
                if (!$BuildQueue) {
                        $this->PLANET[$timeField]       = 0;
                        $this->PLANET[$queueField]      = '';
                        return false;
                }

                $BuildArray     = array();
                foreach($BuildQueue as $Item)
                {
                        $AcumTime               = BuildFunctions::getBuildingTime($this->USER, $this->PLANET, $Item[0]);
                        $BuildArray[]   = array($Item[0], $Item[1], $AcumTime);
                }

                $NewQueue       = array();
                $Done           = false;
                foreach($BuildArray as $Item)
                {
                        $Element        = $Item[0];
                        $Count          = $Item[1];

                        if($Done == false) {
                                $BuildTime      = $Item[2];
                                $Element        = (int)$Element;
                                if($BuildTime == 0) {
                                        if(!isset($this->Builded[$Element]))
                                                $this->Builded[$Element] = 0;

                                        $this->Builded[$Element]                        += $Count;
                                        $this->PLANET[$resource[$Element]]      += $Count;
                                        continue;
                                }

                                $Build  = max(min(floor($this->PLANET[$timeField] / $BuildTime), $Count), 0);

                                if($Build == 0) {
                                        $NewQueue[]     = array($Element, $Count);
                                        $Done           = true;
                                        continue;
                                }

                                if(!isset($this->Builded[$Element]))
                                        $this->Builded[$Element] = 0;

                                $this->Builded[$Element]                        += $Build;
                                $this->PLANET[$timeField]                       -= $Build * $BuildTime;
                                $this->PLANET[$resource[$Element]]      += $Build;
                                $Count                                                          -= $Build;

                                // ============================================
                                // ASTROIO - Actualizar progreso del evento
                                // (solo para naves: 'build_ships')
                                // ============================================
                                if ($eventName !== NULL && class_exists('EventHelper') && in_array($Element, $allowedElements)) {
                                        EventHelper::updateProgress($this->USER['id'], $eventName, $Build);
                                }
                                // ============================================

                                if ($Count == 0)
                                        continue;
                                else
                                        $Done   = true;
                        }
                        $NewQueue[]     = array($Element, $Count);
                }
                $this->PLANET[$queueField]      = !empty($NewQueue) ? serialize($NewQueue) : '';

                return true;
        }
        
        private function BuildingQueue() 
        {
                while($this->CheckPlanetBuildingQueue())
                        $this->SetNextQueueElementOnTop();
        }
        
        private function CheckPlanetBuildingQueue()
        {
                global $resource, $reslist;
                
                if (empty($this->PLANET['b_building_id']) || $this->PLANET['b_building'] > $this->TIME)
                        return false;
                
                $CurrentQueue   = unserialize($this->PLANET['b_building_id']);

                // ============================================
                // ASTROIO v1.2 FIX - Validar cola antes de acceder
                // ============================================
                if (!is_array($CurrentQueue) || empty($CurrentQueue) || !isset($CurrentQueue[0]) || !is_array($CurrentQueue[0])) {
                        $this->PLANET['b_building']    = 0;
                        $this->PLANET['b_building_id'] = '';
                        return false;
                }
                // ============================================

                $Element        = $CurrentQueue[0][0];
                $BuildEndTime   = $CurrentQueue[0][3];
                $BuildMode      = $CurrentQueue[0][4];
                
                if(!isset($this->Builded[$Element]))
                        $this->Builded[$Element] = 0;
                
                if ($BuildMode == 'build')
                {
                        $this->PLANET['field_current']          += 1;
                        $this->PLANET[$resource[$Element]]      += 1;
                        $this->Builded[$Element]                        += 1;
                }
                else
                {
                        $this->PLANET['field_current']          -= 1;
                        $this->PLANET[$resource[$Element]]      -= 1;
                        $this->Builded[$Element]                        -= 1;
                }
        

                array_shift($CurrentQueue);
                $OnHash = in_array($Element, $reslist['prod']);
                $this->UpdateResource($BuildEndTime, !$OnHash);                 
                        
                if (count($CurrentQueue) == 0) {
                        $this->PLANET['b_building']     = 0;
                        $this->PLANET['b_building_id']  = '';

                        return false;
                } else {
                        $this->PLANET['b_building_id']  = serialize($CurrentQueue);
                        return true;
                }
        }       

        public function SetNextQueueElementOnTop()
        {
                global $resource, $LNG;

                if (empty($this->PLANET['b_building_id'])) {
                        $this->PLANET['b_building']    = 0;
                        $this->PLANET['b_building_id'] = '';
                        return false;
                }

                $CurrentQueue   = unserialize($this->PLANET['b_building_id']);

                // ============================================
                // ASTROIO v1.2 FIX CRÍTICO - Validar cola ANTES del while
                // ------------------------------------------------------------
                // Este es el punto que crasheaba el módulo de ataque.
                // Cuando el jugador atacado tiene b_building_id = 'a:0:{}'
                // (array vacío serializado) o corrupto, unserialize devuelve
                // [] o false, y luego $CurrentQueue[0] devolvía null.
                // Al acceder $ListIDArray[0] → "Trying to access array offset
                // on value of type null" → Fatal error → TargetEvent abortado.
                // ============================================
                if (!is_array($CurrentQueue) || empty($CurrentQueue) || !isset($CurrentQueue[0]) || !is_array($CurrentQueue[0])) {
                        $this->PLANET['b_building']    = 0;
                        $this->PLANET['b_building_id'] = '';
                        return false;
                }
                // ============================================

                $Loop           = true;

                $BuildEndTime   = 0;
                $NewQueue               = '';

                while ($Loop === true)
                {
                        // ============================================
                        // ASTROIO v1.2 FIX - Guard dentro del while
                        // ------------------------------------------------------------
                        // Por si la cola se corrompe o vacía a mitad de iteración.
                        // ============================================
                        if (!is_array($CurrentQueue) || empty($CurrentQueue) || !isset($CurrentQueue[0]) || !is_array($CurrentQueue[0])) {
                                $this->PLANET['b_building']    = 0;
                                $this->PLANET['b_building_id'] = '';
                                return false;
                        }
                        // ============================================

                        $ListIDArray            = $CurrentQueue[0];
                        $Element                        = $ListIDArray[0];
                        $Level                          = $ListIDArray[1];
                        $BuildMode                      = $ListIDArray[4];
                        $ForDestroy                     = ($BuildMode == 'destroy') ? true : false;
                        $costResources          = BuildFunctions::getElementPrice($this->USER, $this->PLANET, $Element, $ForDestroy, $Level);
                        $BuildTime                      = BuildFunctions::getBuildingTime($this->USER, $this->PLANET, $Element, $costResources);
                        $HaveResources          = BuildFunctions::isElementBuyable($this->USER, $this->PLANET, $Element, $costResources);
                        $BuildEndTime           = $this->PLANET['b_building'] + $BuildTime;
                        $CurrentQueue[0]        = array($Element, $Level, $BuildTime, $BuildEndTime, $BuildMode);
                        $HaveNoMoreLevel        = false;
                                
                        if($ForDestroy && $this->PLANET[$resource[$Element]] == 0) {
                                $HaveResources  = false;
                                $HaveNoMoreLevel = true;
                        }

                        if($HaveResources === true) {
                                if(isset($costResources[901])) { $this->PLANET[$resource[901]]  -= $costResources[901]; }
                                if(isset($costResources[902])) { $this->PLANET[$resource[902]]  -= $costResources[902]; }
                                if(isset($costResources[903])) { $this->PLANET[$resource[903]]  -= $costResources[903]; }
                                if(isset($costResources[921])) { $this->USER[$resource[921]]    -= $costResources[921]; }
                                // 🆕 v2.4.0 — Pago en Norium (932) y Germanium (933)
                                if(isset($costResources[932])) { $this->PLANET['norium']        -= $costResources[932]; }
                                if(isset($costResources[933])) { $this->PLANET['germanium']     -= $costResources[933]; }
                                $NewQueue                       = serialize($CurrentQueue);
                                $Loop                           = false;
                        } else {
                                if($this->USER['hof'] == 1){
                                        if ($HaveNoMoreLevel) {
                                                $Message     = sprintf($LNG['sys_nomore_level'], $LNG['tech'][$Element]);
                                        } else {
                                                if(!isset($costResources[901])) { $costResources[901] = 0; }
                                                if(!isset($costResources[902])) { $costResources[902] = 0; }
                                                if(!isset($costResources[903])) { $costResources[903] = 0; }
                                                
                                                $Message     = sprintf($LNG['sys_notenough_money'], $this->PLANET['name'], $this->PLANET['id'], $this->PLANET['galaxy'], $this->PLANET['system'], $this->PLANET['planet'], $LNG['tech'][$Element], pretty_number ($this->PLANET['metal']), $LNG['tech'][901], pretty_number($this->PLANET['crystal']), $LNG['tech'][902], pretty_number ($this->PLANET['deuterium']), $LNG['tech'][903], pretty_number($costResources[901]), $LNG['tech'][901], pretty_number ($costResources[902]), $LNG['tech'][902], pretty_number ($costResources[903]), $LNG['tech'][903]);
                                        }

                                        PlayerUtil::sendMessage($this->USER['id'], 0,$LNG['sys_buildlist'], 99,
                                                $LNG['sys_buildlist_fail'], $Message, $this->TIME);
                                }

                                array_shift($CurrentQueue);
                                        
                                if (count($CurrentQueue) == 0) {
                                        $BuildEndTime  = 0;
                                        $NewQueue      = '';
                                        $Loop          = false;
                                } else {
                                        $BaseTime                       = $BuildEndTime - $BuildTime;
                                        $NewQueue                       = array();
                                        foreach($CurrentQueue as $ListIDArray)
                                        {
                                                $ListIDArray[2]         = BuildFunctions::getBuildingTime($this->USER, $this->PLANET, $ListIDArray[0], NULL, $ListIDArray[4] == 'destroy');
                                                $BaseTime                       += $ListIDArray[2];
                                                $ListIDArray[3]         = $BaseTime;
                                                $NewQueue[]                     = $ListIDArray;
                                        }
                                        $CurrentQueue   = $NewQueue;
                                }
                        }
                }
                        
                $this->PLANET['b_building']    = $BuildEndTime;
                $this->PLANET['b_building_id'] = $NewQueue;

                return true;
        }
                
        private function ResearchQueue()
        {
                while($this->CheckUserTechQueue())
                        $this->SetNextQueueTechOnTop();
        }
        
        private function CheckUserTechQueue()
        {
                global $resource;
                
                if (empty($this->USER['b_tech_id']) || $this->USER['b_tech'] > $this->TIME)
                        return false;
                
                if(!isset($this->Builded[$this->USER['b_tech_id']]))
                        $this->Builded[$this->USER['b_tech_id']]        = 0;
                        
                $this->Builded[$this->USER['b_tech_id']]                        += 1;
                $this->USER[$resource[$this->USER['b_tech_id']]]        += 1;

                // ============================================
                // ASTROIO - Actualizar progreso del evento "Investigar tecnologías"
                // ============================================
                if (class_exists('EventHelper')) {
                        EventHelper::updateProgress($this->USER['id'], 'research_techs', 1);
                }
                // ============================================

                $CurrentQueue   = unserialize($this->USER['b_tech_queue']);
                array_shift($CurrentQueue);             
                
                $this->USER['b_tech_id']                = 0;
                if (count($CurrentQueue) == 0) {
                        $this->USER['b_tech']                   = 0;
                        $this->USER['b_tech_id']                = 0;
                        $this->USER['b_tech_planet']    = 0;
                        $this->USER['b_tech_queue']             = '';
                        return false;
                } else {
                        $this->USER['b_tech_queue']     = serialize(array_values($CurrentQueue));
                        return true;
                }
        }       
        
        public function SetNextQueueTechOnTop()
        {
                global $resource, $LNG;

                if (empty($this->USER['b_tech_queue'])) {
                        $this->USER['b_tech']                   = 0;
                        $this->USER['b_tech_id']                = 0;
                        $this->USER['b_tech_planet']    = 0;
                        $this->USER['b_tech_queue']             = '';
                        return false;
                }

                $CurrentQueue   = unserialize($this->USER['b_tech_queue']);

                // ============================================
                // ASTROIO v1.2 FIX - Validar cola de techs ANTES del while
                // (mismo bug que la cola de edificios)
                // ============================================
                if (!is_array($CurrentQueue) || empty($CurrentQueue) || !isset($CurrentQueue[0]) || !is_array($CurrentQueue[0])) {
                        $this->USER['b_tech']                   = 0;
                        $this->USER['b_tech_id']                = 0;
                        $this->USER['b_tech_planet']    = 0;
                        $this->USER['b_tech_queue']             = '';
                        return false;
                }
                // ============================================

                $Loop           = true;
                while ($Loop == true)
                {
                        // ============================================
                        // ASTROIO v1.2 FIX - Guard dentro del while
                        // ============================================
                        if (!is_array($CurrentQueue) || empty($CurrentQueue) || !isset($CurrentQueue[0]) || !is_array($CurrentQueue[0])) {
                                $this->USER['b_tech']                   = 0;
                                $this->USER['b_tech_id']                = 0;
                                $this->USER['b_tech_planet']    = 0;
                                $this->USER['b_tech_queue']             = '';
                                return false;
                        }
                        // ============================================

                        $ListIDArray        = $CurrentQueue[0];
                        $isAnotherPlanet        = $ListIDArray[4] != $this->PLANET['id'];
                        if($isAnotherPlanet)
                        {
                                $sql    = 'SELECT * FROM %%PLANETS%% WHERE id = :planetId;';
                                $PLANET = Database::get()->selectSingle($sql, array(
                                        ':planetId'     => $ListIDArray[4],
                                ));

                                $RPLANET                = new ResourceUpdate(true, false);
                                list(, $PLANET) = $RPLANET->CalcResource($this->USER, $PLANET, false, $this->USER['b_tech']);
                        }
                        else
                        {
                                $PLANET = $this->PLANET;
                        }

                        $PLANET[$resource[31].'_inter'] = self::getNetworkLevel($this->USER, $PLANET);
                        
                        $Element            = $ListIDArray[0];
                        $Level              = $ListIDArray[1];
                        $costResources          = BuildFunctions::getElementPrice($this->USER, $PLANET, $Element, false, $Level);
                        $BuildTime                      = BuildFunctions::getBuildingTime($this->USER, $PLANET, $Element, $costResources);
                        $HaveResources          = BuildFunctions::isElementBuyable($this->USER, $PLANET, $Element, $costResources);
                        $BuildEndTime       = $this->USER['b_tech'] + $BuildTime;
                        $CurrentQueue[0]        = array($Element, $Level, $BuildTime, $BuildEndTime, $PLANET['id']);
                        
                        if($HaveResources == true) {
                                if(isset($costResources[901])) { $PLANET[$resource[901]]                -= $costResources[901]; }
                                if(isset($costResources[902])) { $PLANET[$resource[902]]                -= $costResources[902]; }
                                if(isset($costResources[903])) { $PLANET[$resource[903]]                -= $costResources[903]; }
                                if(isset($costResources[921])) { $this->USER[$resource[921]]    -= $costResources[921]; }
                                // 🆕 v2.4.0 — Pago en Norium (932) y Germanium (933)
                                if(isset($costResources[932])) { $PLANET['norium']              -= $costResources[932]; }
                                if(isset($costResources[933])) { $PLANET['germanium']   -= $costResources[933]; }
                                $this->USER['b_tech_id']                = $Element;
                                $this->USER['b_tech']                   = $BuildEndTime;
                                $this->USER['b_tech_planet']    = $PLANET['id'];
                                $this->USER['b_tech_queue']     = serialize($CurrentQueue);

                                $Loop                                   = false;
                        } else {
                                if($this->USER['hof'] == 1){
                                        if(!isset($costResources[901])) { $costResources[901] = 0; }
                                        if(!isset($costResources[902])) { $costResources[902] = 0; }
                                        if(!isset($costResources[903])) { $costResources[903] = 0; }
                                        
                                        $Message     = sprintf($LNG['sys_notenough_money'], $PLANET['name'], $PLANET['id'], $PLANET['galaxy'], $PLANET['system'], $PLANET['planet'], $LNG['tech'][$Element], pretty_number ($PLANET['metal']), $LNG['tech'][901], pretty_number($PLANET['crystal']), $LNG['tech'][902], pretty_number ($PLANET['deuterium']), $LNG['tech'][903], pretty_number($costResources[901]), $LNG['tech'][901], pretty_number ($costResources[902]), $LNG['tech'][902], pretty_number($costResources[903]), $LNG['tech'][903]);
                                        PlayerUtil::sendMessage($this->USER['id'], 0,$LNG['sys_techlist'], 99, $LNG['sys_buildlist_fail'], $Message, $this->TIME);
                                }

                                array_shift($CurrentQueue);
                                        
                                if (count($CurrentQueue) == 0) {
                                        $this->USER['b_tech']                   = 0;
                                        $this->USER['b_tech_id']                = 0;
                                        $this->USER['b_tech_planet']    = 0;
                                        $this->USER['b_tech_queue']             = '';
                                        
                                        $Loop                                   = false;
                                } else {
                                        $BaseTime                                               = $BuildEndTime - $BuildTime;
                                        $NewQueue                                               = array();
                                        foreach($CurrentQueue as $ListIDArray)
                                        {
                                                $ListIDArray[2]                         = BuildFunctions::getBuildingTime($this->USER, $PLANET, $ListIDArray[0]);
                                                $BaseTime                                       += $ListIDArray[2];
                                                $ListIDArray[3]                         = $BaseTime;
                                                $NewQueue[]                                     = $ListIDArray;
                                        }
                                        $CurrentQueue                                   = $NewQueue;
                                }
                        }
                                
                        if($isAnotherPlanet)
                        {
                                $RPLANET->SavePlanetToDB($this->USER, $PLANET);
                                $RPLANET                = NULL;
                                unset($RPLANET);
                        }
                        else
                        {
                                $this->PLANET   = $PLANET;
                        }
                }

                return true;
        }
        
        public function SavePlanetToDB($USER = NULL, $PLANET = NULL)
        {
                global $resource, $reslist;
                
                if(is_null($USER))
                        global $USER;
                        
                if(is_null($PLANET))
                        global $PLANET;

                $buildQueries   = array();

                $params = array(
                        ':userId'                               => $USER['id'],
                        ':planetId'                             => $PLANET['id'],
                        ':metal'                                => $PLANET['metal'],
                        ':crystal'                              => $PLANET['crystal'],
                        ':deuterium'                    => $PLANET['deuterium'],
                        // 🆕 v2.4.0 — Norium y Germanium (recursos, tope y producción por hora)
                        ':norium'                               => isset($PLANET['norium'])          ? $PLANET['norium']          : 0,
                        ':germanium'                    => isset($PLANET['germanium'])       ? $PLANET['germanium']       : 0,
                        ':noriumMax'                    => isset($PLANET['norium_max'])      ? $PLANET['norium_max']      : 0,
                        ':germaniumMax'                 => isset($PLANET['germanium_max'])   ? $PLANET['germanium_max']   : 0,
                        ':noriumPerhour'                => isset($PLANET['norium_perhour'])  ? $PLANET['norium_perhour']  : 0,
                        ':germaniumPerhour'             => isset($PLANET['germanium_perhour']) ? $PLANET['germanium_perhour'] : 0,
                        ':ecoHash'                              => $PLANET['eco_hash'],
                        ':lastUpdateTime'               => $PLANET['last_update'],
                        ':b_building'                   => $PLANET['b_building'],
                        ':b_building_id'                => $PLANET['b_building_id'],
                        ':field_current'                => $PLANET['field_current'],
                        ':b_hangar_id'                  => $PLANET['b_hangar_id'],
                        ':b_defense_id'                 => isset($PLANET['b_defense_id']) ? $PLANET['b_defense_id'] : '',
                        ':metal_perhour'                => $PLANET['metal_perhour'],
                        ':crystal_perhour'              => $PLANET['crystal_perhour'],
                        ':deuterium_perhour'    => $PLANET['deuterium_perhour'],
                        ':metal_max'                    => $PLANET['metal_max'],
                        ':crystal_max'                  => $PLANET['crystal_max'],
                        ':deuterium_max'                => $PLANET['deuterium_max'],
                        ':energy_used'                  => $PLANET['energy_used'],
                        ':energy'                               => $PLANET['energy'],
                        ':b_hangar'                             => $PLANET['b_hangar'],
                        ':b_defense'                    => isset($PLANET['b_defense']) ? $PLANET['b_defense'] : 0,
                        ':darkmatter'                   => $USER['darkmatter'],
                        ':b_tech'                               => $USER['b_tech'],
                        ':b_tech_id'                    => $USER['b_tech_id'],
                        ':b_tech_planet'                => $USER['b_tech_planet'],
                        ':b_tech_queue'                 => $USER['b_tech_queue']
                );

                if (!empty($this->Builded))
                {
                        foreach($this->Builded as $Element => $Count)
                        {
                                $Element        = (int) $Element;
                                
                                if(empty($resource[$Element]) || empty($Count)) {
                                        continue;
                                }
                                
                                if(in_array($Element, $reslist['one']))
                                {
                                        $buildQueries[]                                         = ', p.'.$resource[$Element].' = :'.$resource[$Element];
                                        $params[':'.$resource[$Element]]        = '1';
                                }
                                elseif(isset($PLANET[$resource[$Element]]))
                                {
                                        $buildQueries[]                                         = ', p.'.$resource[$Element].' = p.'.$resource[$Element].' + :'.$resource[$Element];
                                        $params[':'.$resource[$Element]]        = floatToString($Count);
                                }
                                elseif(isset($USER[$resource[$Element]]))
                                {
                                        $buildQueries[]                                         = ', u.'.$resource[$Element].' = u.'.$resource[$Element].' + :'.$resource[$Element];
                                        $params[':'.$resource[$Element]]        = floatToString($Count);
                                }
                        }
                }

                $sql = 'UPDATE %%PLANETS%% as p,%%USERS%% as u SET
                p.metal                         = :metal,
                p.crystal                       = :crystal,
                p.deuterium                     = :deuterium,
                -- 🆕 v2.4.0 — Norium y Germanium
                p.norium                        = :norium,
                p.germanium                     = :germanium,
                p.norium_max            = :noriumMax,
                p.germanium_max         = :germaniumMax,
                p.norium_perhour        = :noriumPerhour,
                p.germanium_perhour     = :germaniumPerhour,
                p.eco_hash                      = :ecoHash,
                p.last_update           = :lastUpdateTime,
                p.b_building            = :b_building,
                p.b_building_id         = :b_building_id,
                p.field_current         = :field_current,
                p.b_hangar_id           = :b_hangar_id,
                p.b_defense_id          = :b_defense_id,
                p.metal_perhour         = :metal_perhour,
                p.crystal_perhour       = :crystal_perhour,
                p.deuterium_perhour     = :deuterium_perhour,
                p.metal_max                     = :metal_max,
                p.crystal_max           = :crystal_max,
                p.deuterium_max         = :deuterium_max,
                p.energy_used           = :energy_used,
                p.energy                        = :energy,
                p.b_hangar                      = :b_hangar,
                p.b_defense                     = :b_defense,
                u.darkmatter            = :darkmatter,
                u.b_tech                        = :b_tech,
                u.b_tech_id                     = :b_tech_id,
                u.b_tech_planet         = :b_tech_planet,
                u.b_tech_queue          = :b_tech_queue
                '.implode("\n", $buildQueries).'
                WHERE p.id = :planetId AND u.id = :userId;';

                Database::get()->update($sql, $params);

                $this->Builded  = array();

                return array($USER, $PLANET);
        }
}
?>