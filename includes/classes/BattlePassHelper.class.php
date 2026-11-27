<?php
/**
 * BattlePassHelper — Sistema de Pase de Batalla
 * AstroIO v1.9.1 — Temporadas de 32 dias con 60 niveles + Doble Riel
 *
 * Caracteristicas:
 *   - 60 niveles con curva: Facil (1-15) -> Medio (16-30) -> Dificil (31-60)
 *   - Monedas ganadas al reclamar eventos (diario/semanal/elite)
 *   - Carril Normal + Carril VIP (cualquier VIP activo)
 *   - Recompensas individuales por jugador (cofres aleatorios)
 *   - Filtrado de naves/defensas por requisitos CON ALTERNATIVAS JUSTAS
 *   - Reinicio automatico cada 32 dias (768h)
 *   - v1.9: Doble riel — Si el jugador es QVAPAY, las recompensas de
 *     NTX-20 se entregan como UNTX-20 y con el DOBLE (x2) de cantidad.
 *
 * Cambios v1.8 (FASE 6 — ENTREGA EN EL PLANETA ACTIVO):
 *   - NEW: getPlanetaActivo() lee uni1_users.id_planet para saber en qué
 *     planeta está el jugador AHORA MISMO.
 *   - FIX: entregarRecompensa() ahora usa getPlanetaActivo().
 *
 * Cambios v1.9:
 *   - NEW: getPlayerMethod() detecta si el jugador es 'CUP' o 'QVAPAY'.
 *   - NEW: entregarRecompensa() para 'ntx20' y 'cofre_final_vip' ahora
 *     entrega UNTX-20 (x2) si el método es QVAPAY.
 *
 * Cambios v1.9.1 (FIX REAL — ENTREGA EN EL PLANETA ACTIVO):
 *   - FIX: getPlanetaActivo() usaba uni1_users.id_planet, que es el
 *     planeta HOME (fijo, nunca cambia al cambiar de planeta).
 *     Ahora usa $GLOBALS['PLANET']['id'] (planeta activo real),
 *     que common.php carga desde la sesión en cada petición INGAME.
 *   - FALLBACK: si no hay contexto de juego (cron, admin), se mantiene
 *     el comportamiento anterior (leer id_planet de la BD).
 */

if (!defined('MODE')) die('Hacking attempt');

class BattlePassHelper
{
    /* ============================================================
     * CONSTANTES — CONFIGURACION GENERAL
     * ============================================================ */
    const NUM_NIVELES       = 60;
    const DIAS_TEMPORADA    = 32;
    const SEGUNDOS_RESET    = 2764800; // 32 dias x 24h x 3600s
    const MONEDAS_DIARIO    = [3, 5];
    const MONEDAS_SEMANAL   = [5, 8];
    const MONEDAS_ELITE     = [8, 12];

    /* ============================================================
     * CONSTANTES — NTX-20 (BASE)
     * ============================================================ */
    const NTX_NORMAL_FIJOS = [];
    const NTX_N60_NORMAL   = 0;

    const NTX_VIP_FIJOS = [
        10 => 10,
        30 => 15
    ];
    const NTX_N60_VIP = 25;

    /* ============================================================
     * CONSTANTES — COFRES
     * ============================================================ */
    const COFRES_NORMALES = 4;
    const COFRES_VIP      = 7;

    /* ============================================================
     * CONSTANTES — PROBABILIDADES DE COFRES
     * ============================================================ */
    const PROB_COFRE_NORMAL = [
        'nave'     => 55,
        'defensa'  => 30,
        'recursos' => 15
    ];
    const PROB_COFRE_VIP = [
        'nave'     => 45,
        'defensa'  => 30,
        'recursos' => 25
    ];

    /* ============================================================
     * MARCA DE INSTALACION AUTOMATICA DEL SQL
     * ============================================================ */
    const LOCK_FILE = 'bp_fallback_installed.lock';

    /* ============================================================
     * MAPEO DE NAVES — ID => Columna
     * ============================================================ */
    private static $NAVES = [
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
        216 => 'lune_noir',
        217 => 'ev_transporter',
        218 => 'star_crasher',
        219 => 'giga_recykler',
        220 => 'dm_ship'
    ];

    /* ============================================================
     * MAPEO DE DEFENSAS — ID => Columna
     * ============================================================ */
    private static $DEFENSAS = [
        401 => 'misil_launcher',
        402 => 'small_laser',
        403 => 'big_laser',
        404 => 'gauss_canyon',
        405 => 'ionic_canyon',
        406 => 'buster_canyon',
        407 => 'small_protection_shield',
        408 => 'big_protection_shield',
        409 => 'planet_protector',
        410 => 'graviton_canyon',
        411 => 'orbital_station'
    ];

    /* ============================================================
     * NOMBRES LEGIBLES DE NAVES
     * ============================================================ */
    public static $NOMBRES_NAVES = [
        'small_ship_cargo' => 'Carguero Pequeño',
        'big_ship_cargo'   => 'Carguero Grande',
        'light_hunter'     => 'Cazador Ligero',
        'heavy_hunter'     => 'Cazador Pesado',
        'crusher'          => 'Crucero',
        'battle_ship'      => 'Nave de Batalla',
        'colonizer'        => 'Colonizador',
        'recycler'         => 'Reciclador',
        'spy_sonde'        => 'Sonda de Espionaje',
        'bomber_ship'      => 'Bombardero',
        'solar_satelit'    => 'Satélite Solar',
        'destructor'       => 'Destructor',
        'dearth_star'      => 'Estrella de la Muerte',
        'battleship'       => 'Acorazado',
        'lune_noir'        => 'Luna Negra',
        'ev_transporter'   => 'Transporte Evolucionado',
        'star_crasher'     => 'Rompeestrellas',
        'giga_recykler'    => 'Giga Reciclador',
        'dm_ship'          => 'Nave de Materia Oscura',
    ];

    /* ============================================================
     * NOMBRES LEGIBLES DE DEFENSAS
     * ============================================================ */
    public static $NOMBRES_DEFENSAS = [
        'misil_launcher'          => 'Lanzamisiles',
        'small_laser'             => 'Láser Pequeño',
        'big_laser'               => 'Láser Grande',
        'gauss_canyon'            => 'Cañón Gauss',
        'ionic_canyon'            => 'Cañón Iónico',
        'buster_canyon'           => 'Cañón de Plasma',
        'small_protection_shield' => 'Cúpula Pequeña',
        'big_protection_shield'   => 'Cúpula Grande',
        'planet_protector'        => 'Protector Planetario',
        'graviton_canyon'         => 'Cañón de Gravitones',
        'orbital_station'         => 'Estación Orbital',
    ];

    /* ============================================================
     * NAVES POR CATEGORIA
     * ============================================================ */
    private static $NAVES_BASICAS = [
        'small_ship_cargo', 'big_ship_cargo', 'light_hunter',
        'heavy_hunter', 'spy_sonde'
    ];
    private static $NAVES_MEDIANAS = [
        'crusher', 'battle_ship', 'recycler', 'bomber_ship', 'battleship'
    ];
    private static $NAVES_PODEROSAS = [
        'destructor', 'dearth_star', 'lune_noir', 'star_crasher'
    ];

    /* ============================================================
     * DEFENSAS POR CATEGORIA
     * ============================================================ */
    private static $DEFENSAS_BASICAS = [
        'misil_launcher', 'small_laser', 'big_laser'
    ];
    private static $DEFENSAS_MEDIANAS = [
        'gauss_canyon', 'ionic_canyon', 'buster_canyon'
    ];
    private static $DEFENSAS_PODEROSAS = [
        'small_protection_shield', 'big_protection_shield',
        'planet_protector', 'graviton_canyon'
    ];

    /* ============================================================
     * TABLA DE COSTES FALLBACK
     * ============================================================ */
    private static $PRECIOS_FALLBACK = [
        202 => ['metal' => 2000,    'crystal' => 2000,    'deuterium' => 0],
        203 => ['metal' => 6000,    'crystal' => 6000,    'deuterium' => 0],
        204 => ['metal' => 3000,    'crystal' => 1000,    'deuterium' => 0],
        205 => ['metal' => 6000,    'crystal' => 4000,    'deuterium' => 0],
        206 => ['metal' => 20000,   'crystal' => 7000,    'deuterium' => 2000],
        207 => ['metal' => 45000,   'crystal' => 15000,   'deuterium' => 0],
        208 => ['metal' => 10000,   'crystal' => 20000,   'deuterium' => 10000],
        209 => ['metal' => 10000,   'crystal' => 6000,    'deuterium' => 2000],
        210 => ['metal' => 0,       'crystal' => 1000,    'deuterium' => 0],
        211 => ['metal' => 50000,   'crystal' => 25000,   'deuterium' => 15000],
        212 => ['metal' => 0,       'crystal' => 2000,    'deuterium' => 500],
        213 => ['metal' => 60000,   'crystal' => 50000,   'deuterium' => 15000],
        214 => ['metal' => 5000000, 'crystal' => 4000000, 'deuterium' => 1000000],
        215 => ['metal' => 30000,   'crystal' => 40000,   'deuterium' => 15000],
        216 => ['metal' => 1000000, 'crystal' => 500000,  'deuterium' => 500000],
        217 => ['metal' => 50000,   'crystal' => 50000,   'deuterium' => 25000],
        218 => ['metal' => 1000000, 'crystal' => 750000,  'deuterium' => 250000],
        219 => ['metal' => 100000,  'crystal' => 100000,  'deuterium' => 50000],
        220 => ['metal' => 500000,  'crystal' => 500000,  'deuterium' => 500000],
        401 => ['metal' => 2000,    'crystal' => 0,       'deuterium' => 0],
        402 => ['metal' => 1500,    'crystal' => 500,     'deuterium' => 0],
        403 => ['metal' => 6000,    'crystal' => 2000,    'deuterium' => 0],
        404 => ['metal' => 20000,   'crystal' => 15000,   'deuterium' => 2000],
        405 => ['metal' => 5000,    'crystal' => 3000,    'deuterium' => 0],
        406 => ['metal' => 50000,   'crystal' => 50000,   'deuterium' => 0],
        407 => ['metal' => 10000,   'crystal' => 10000,   'deuterium' => 0],
        408 => ['metal' => 50000,   'crystal' => 50000,   'deuterium' => 0],
        409 => ['metal' => 200000,  'crystal' => 200000,  'deuterium' => 100000],
        410 => ['metal' => 500000,  'crystal' => 500000,  'deuterium' => 0],
        411 => ['metal' => 1000000, 'crystal' => 500000,  'deuterium' => 500000],
    ];

    /* ============================================================
     * AUTO-SQL: COMPROBAR SI EXISTEN LAS COLUMNAS
     * ============================================================ */
    private static function fallbackColumnsExist()
    {
        $db = self::db();
        $prefix = self::prefix();

        try {
            $cols = $db->select(
                "SHOW COLUMNS FROM ".$prefix."bp_config WHERE Field LIKE 'bp_fallback_%'"
            );

            if (!is_array($cols)) return false;

            $encontradas = [];
            foreach ($cols as $c) {
                if (isset($c['Field'])) $encontradas[] = $c['Field'];
            }

            $necesarias = [
                'bp_fallback_enabled',
                'bp_fallback_mode',
                'bp_fallback_factor',
                'bp_fallback_round',
                'bp_fallback_none'
            ];

            foreach ($necesarias as $n) {
                if (!in_array($n, $encontradas)) return false;
            }

            return true;
        } catch (Exception $e) {
            error_log('[AstroIO BP] Error fallbackColumnsExist: ' . $e->getMessage());
            return false;
        }
    }

    /* ============================================================
     * AUTO-SQL: CREAR COLUMNAS SI NO EXISTEN
     * ============================================================ */
    private static function ensureFallbackColumns()
    {
        $cacheDir = self::getCacheDir();
        if ($cacheDir === '') {
            self::ejecutarAlterFallback();
            return;
        }

        $lockFile = $cacheDir . DIRECTORY_SEPARATOR . self::LOCK_FILE;

        if (file_exists($lockFile)) {
            return;
        }

        if (self::fallbackColumnsExist()) {
            @file_put_contents($lockFile, 'ok ' . date('Y-m-d H:i:s'));
            return;
        }

        $ok = self::ejecutarAlterFallback();

        if ($ok) {
            @file_put_contents($lockFile, 'installed ' . date('Y-m-d H:i:s'));
        } else {
            error_log('[AstroIO BP] No se pudieron crear las columnas bp_fallback_*. '
                    . 'El Helper funcionara con defaults en memoria. '
                    . 'Si quieres persistencia, ejecuta manualmente el ALTER TABLE.');
            @file_put_contents($lockFile, 'failed ' . date('Y-m-d H:i:s'));
        }
    }

    /* ============================================================
     * EJECUTAR EL ALTER TABLE (auto-SQL)
     * ============================================================ */
    private static function ejecutarAlterFallback()
    {
        $db = self::db();
        $prefix = self::prefix();

        $sql = "ALTER TABLE `".$prefix."bp_config`
                  ADD COLUMN `bp_fallback_enabled` TINYINT(1)   NOT NULL DEFAULT 1,
                  ADD COLUMN `bp_fallback_mode`    VARCHAR(10)  NOT NULL DEFAULT 'best',
                  ADD COLUMN `bp_fallback_factor`  DECIMAL(3,2) NOT NULL DEFAULT 1.00,
                  ADD COLUMN `bp_fallback_round`   VARCHAR(5)   NOT NULL DEFAULT 'up',
                  ADD COLUMN `bp_fallback_none`    VARCHAR(10)  NOT NULL DEFAULT 'res'";

        try {
            $db->query($sql);
            error_log('[AstroIO BP] ALTER TABLE bp_config ejecutado OK (auto-SQL v1.7).');
            return true;
        } catch (Exception $e) {
            $msg = $e->getMessage();
            if (stripos($msg, 'Duplicate column') !== false
             || stripos($msg, 'already exists') !== false) {
                error_log('[AstroIO BP] Columnas bp_fallback_* ya existian (race).');
                return true;
            }
            error_log('[AstroIO BP] Error ALTER TABLE bp_config: ' . $msg);
            return false;
        }
    }

    /* ============================================================
     * OBTENER DIRECTORIO DE CACHE
     * ============================================================ */
    private static function getCacheDir()
    {
        if (defined('ROOT_PATH')) {
            $dir = rtrim(ROOT_PATH, '/\\') . DIRECTORY_SEPARATOR . 'cache';
            if (is_dir($dir) && is_writable($dir)) return $dir;
        }

        $dir = dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'cache';
        $dir = realpath($dir);
        if ($dir !== false && is_dir($dir) && is_writable($dir)) return $dir;

        $dir = 'C:' . DIRECTORY_SEPARATOR . 'xampp' . DIRECTORY_SEPARATOR . 'htdocs'
             . DIRECTORY_SEPARATOR . '2Moons' . DIRECTORY_SEPARATOR . 'cache';
        if (is_dir($dir) && is_writable($dir)) return $dir;

        return '';
    }

    /* ============================================================
     * TABLA DE COSTES POR NIVEL
     * ============================================================ */
    public static function getCoste($nivel)
    {
        $nivel = (int)$nivel;
        if ($nivel < 1 || $nivel > self::NUM_NIVELES) return 0;

        if ($nivel <= 5) return 2;
        if ($nivel <= 10) return 3;
        if ($nivel <= 15) return 5;
        if ($nivel <= 20) return 8;
        if ($nivel <= 25) return 12;
        if ($nivel <= 30) return 16;
        if ($nivel <= 35) return 20;
        if ($nivel <= 40) return 25;
        if ($nivel <= 45) return 30;
        if ($nivel <= 50) return 40;
        if ($nivel <= 55) return 50;
        return 60;
    }

    /* ============================================================
     * NOMBRE LEGIBLE DE UNA COLUMNA (nave o defensa)
     * ============================================================ */
    public static function nombreLegible($columna, $tipo = null)
    {
        if ($tipo === 'nave' || $tipo === null) {
            if (isset(self::$NOMBRES_NAVES[$columna])) {
                return self::$NOMBRES_NAVES[$columna];
            }
        }
        if ($tipo === 'defensa' || $tipo === null) {
            if (isset(self::$NOMBRES_DEFENSAS[$columna])) {
                return self::$NOMBRES_DEFENSAS[$columna];
            }
        }
        return $columna;
    }

    /* ============================================================
     * PREFIJO DE TABLAS
     * ============================================================ */
    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /* ============================================================
     * INSTANCIA DE LA BD
     * ============================================================ */
    private static function db()
    {
        return Database::get();
    }

    /* ============================================================
     * TIMESTAMP ACTUAL
     * ============================================================ */
    private static function now()
    {
        return defined('TIMESTAMP') ? TIMESTAMP : time();
    }

    /* ============================================================
     * v1.9 — DETECTAR MÉTODO DE PAGO DEL JUGADOR
     * ============================================================ */
    public static function getPlayerMethod($userId)
    {
        $db = self::db();
        $prefix = self::prefix();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT metodo_retiro FROM ".$prefix."users WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );

        return ($row && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
    }

    /* ============================================================
     * v1.9 — ETIQUETA DE MONEDA SEGÚN MÉTODO
     * ============================================================ */
    public static function getCurrencyLabel($method)
    {
        return ($method === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';
    }

    /* ============================================================
     * DETECTAR VIP ACTIVO
     * ============================================================ */
    public static function esVipActivo($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT vip_id FROM ".self::prefix()."users_vip
             WHERE user_id = :uid 
               AND vip_active = 1 
               AND vip_end > :now
             LIMIT 1",
            [':uid' => $userId, ':now' => self::now()]
        );

        return !empty($row);
    }

    /* ============================================================
     * v1.9.1 — OBTENER PLANETA ACTIVO DEL JUGADOR (FIX REAL)
     * ============================================================
     * Antes (v1.8): leía uni1_users.id_planet, que es el planeta
     * HOME (fijo, nunca cambia al cambiar de planeta).
     * Ahora: usa $GLOBALS['PLANET']['id'] (planeta activo real),
     * que common.php carga desde la sesión en cada petición INGAME.
     * Fallback: si no hay contexto de juego (cron, admin), se
     * mantiene el comportamiento anterior (leer id_planet).
     * ============================================================ */
    public static function getPlanetaActivo($userId)
    {
        $db = self::db();
        $userId = (int)$userId;
        $prefix = self::prefix();

        // ── 1. PRIORIDAD: planeta activo del contexto de juego ──
        //    Solo si pertenece al mismo jugador (evita usar el
        //    planeta del admin cuando consulta a otro jugador).
        if (isset($GLOBALS['PLANET']['id'])
            && isset($GLOBALS['PLANET']['id_owner'])
            && (int)$GLOBALS['PLANET']['id_owner'] === $userId
            && (int)$GLOBALS['PLANET']['id'] > 0
            && isset($GLOBALS['PLANET']['destruyed'])
            && (int)$GLOBALS['PLANET']['destruyed'] === 0
        ) {
            // Planeta normal → usarlo directamente
            if ((int)$GLOBALS['PLANET']['planet_type'] === 1) {
                return (int)$GLOBALS['PLANET']['id'];
            }

            // Luna → buscar planeta padre por coordenadas
            if ((int)$GLOBALS['PLANET']['planet_type'] === 3) {
                $parent = $db->selectSingle(
                    "SELECT id FROM ".$prefix."planets 
                     WHERE id_owner = :uid 
                       AND galaxy = :g AND system = :s AND planet = :p 
                       AND planet_type = 1 
                       AND destruyed = 0 
                     LIMIT 1",
                    [
                        ':uid' => $userId,
                        ':g'   => (int)$GLOBALS['PLANET']['galaxy'],
                        ':s'   => (int)$GLOBALS['PLANET']['system'],
                        ':p'   => (int)$GLOBALS['PLANET']['planet']
                    ]
                );
                if (!empty($parent)) {
                    return (int)$parent['id'];
                }
                // Si no encuentra padre, cae al fallback de abajo
            }
        }

        // ── 2. Fallback: leer id_planet de la BD (home) ──
        //    Solo si no hay contexto de juego o el planeta actual
        //    no pertenece al usuario.
        $userRow = $db->selectSingle(
            "SELECT id_planet FROM ".$prefix."users WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );

        $idPlanet = $userRow ? (int)$userRow['id_planet'] : 0;

        if ($idPlanet > 0) {
            $planet = $db->selectSingle(
                "SELECT id, planet_type, galaxy, system, planet, destruyed 
                 FROM ".$prefix."planets 
                 WHERE id = :pid AND id_owner = :uid LIMIT 1",
                [':pid' => $idPlanet, ':uid' => $userId]
            );

            if (!empty($planet) && (int)$planet['destruyed'] === 0) {
                if ((int)$planet['planet_type'] === 1) {
                    return (int)$planet['id'];
                }
                if ((int)$planet['planet_type'] === 3) {
                    $parent = $db->selectSingle(
                        "SELECT id FROM ".$prefix."planets 
                         WHERE id_owner = :uid 
                           AND galaxy = :g AND system = :s AND planet = :p 
                           AND planet_type = 1 
                           AND destruyed = 0 
                         LIMIT 1",
                        [
                            ':uid' => $userId,
                            ':g'   => (int)$planet['galaxy'],
                            ':s'   => (int)$planet['system'],
                            ':p'   => (int)$planet['planet']
                        ]
                    );
                    if (!empty($parent)) {
                        return (int)$parent['id'];
                    }
                }
            }
        }

        // ── 3. Ultimo recurso: planeta principal ──
        return self::getPlanetaPrincipal($userId);
    }

    /* ============================================================
     * OBTENER PLANETA PRINCIPAL (fallback seguro)
     * ============================================================ */
    public static function getPlanetaPrincipal($userId)
    {
        $db = self::db();
        $userId = (int)$userId;

        $row = $db->selectSingle(
            "SELECT id FROM ".self::prefix()."planets
             WHERE id_owner = :uid 
               AND planet_type = 1 
               AND destruyed = 0
             ORDER BY id ASC 
             LIMIT 1",
            [':uid' => $userId]
        );

        return $row ? (int)$row['id'] : 0;
    }

    /* ============================================================
     * LOG DE ENTREGA (auditoria)
     * ============================================================ */
    private static function logEntrega($userId, $source, $detalle = '')
    {
        $db = self::db();
        $prefix = self::prefix();
        $userId = (int)$userId;

        $sourceFinal = $detalle !== '' ? ($source . ':' . $detalle) : $source;

        try {
            $db->insert(
                "INSERT INTO ".$prefix."bp_log 
                 (user_id, coins, source, fecha)
                 VALUES (:uid, 0, :src, :now)",
                [
                    ':uid' => $userId,
                    ':src' => substr($sourceFinal, 0, 255),
                    ':now' => self::now()
                ]
            );
        } catch (Exception $e) {
            error_log('[AstroIO BP] Error logEntrega: ' . $e->getMessage());
        }
    }

    /* ============================================================
     * PRECIO DE UN ELEMENTO (nave/defensa)
     * ============================================================ */
    private static function getPrecioElemento($id)
    {
        $id = (int)$id;

        if (isset($GLOBALS['pricelist'][$id])) {
            $p = $GLOBALS['pricelist'][$id];
            if (isset($p['metal']) && isset($p['crystal']) && isset($p['deuterium'])) {
                return $p;
            }
        }

        if (isset(self::$PRECIOS_FALLBACK[$id])) {
            return self::$PRECIOS_FALLBACK[$id];
        }

        error_log('[AstroIO BP] No se encontro precio para elemento ID=' . $id);
        return null;
    }

    /* ============================================================
     * VALOR TOTAL DE UN ELEMENTO (metal+cristal+deut)
     * ============================================================ */
    private static function getValorElemento($id, $cantidad = 1)
    {
        $precio = self::getPrecioElemento($id);
        if (!$precio) return 0;
        $unidad = (int)$precio['metal'] + (int)$precio['crystal'] + (int)$precio['deuterium'];
        return $unidad * max(1, (int)$cantidad);
    }

    /* ============================================================
     * CANTIDAD JUSTA (redondeo configurable)
     * ============================================================ */
    private static function redondear($valor, $modo)
    {
        if ($modo === 'down') return (int)floor($valor);
        return (int)ceil($valor);
    }

    /* ============================================================
     * CONFIGURACION DEL FALLBACK
     * ============================================================ */
    private static function getFallbackConfig()
    {
        $config = self::getConfig();
        return [
            'enabled' => isset($config['bp_fallback_enabled']) ? (int)$config['bp_fallback_enabled'] : 1,
            'mode'    => isset($config['bp_fallback_mode'])    ? (string)$config['bp_fallback_mode']     : 'best',
            'factor'  => isset($config['bp_fallback_factor'])  ? (float)$config['bp_fallback_factor']    : 1.0,
            'round'   => isset($config['bp_fallback_round'])   ? (string)$config['bp_fallback_round']    : 'up',
            'none'    => isset($config['bp_fallback_none'])    ? (string)$config['bp_fallback_none']     : 'res',
        ];
    }

    /* ============================================================
     * ENTREGAR RECURSOS EQUIVALENTES (50% metal / 30% cristal / 20% deut)
     * ============================================================ */
    private static function entregarRecursosEquivalentes($userId, $planetaId, $valorTotal, $tipoOriginal, $columnaOriginal, $cantidadOriginal)
    {
        if ($valorTotal <= 0) {
            return ['success' => false, 'message' => 'No se pudo calcular el valor de la recompensa.'];
        }

        $db = self::db();
        $prefix = self::prefix();

        $metal   = (int)($valorTotal * 0.50);
        $crystal = (int)($valorTotal * 0.30);
        $deut    = (int)($valorTotal * 0.20);

        $affected = $db->update(
            "UPDATE ".$prefix."planets 
             SET metal     = metal     + :m,
                 crystal   = crystal   + :c,
                 deuterium = deuterium + :d
             WHERE id = :pid",
            [':m' => $metal, ':c' => $crystal, ':d' => $deut, ':pid' => $planetaId]
        );

        if ($affected === false) {
            return ['success' => false, 'message' => 'No se pudieron depositar los recursos.'];
        }

        self::logEntrega(
            $userId,
            'entrega_recurso_eq',
            $tipoOriginal . ':' . $columnaOriginal . ':' . $cantidadOriginal
            . ':metal' . $metal . ':crystal' . $crystal . ':deut' . $deut
        );

        return [
            'success' => true,
            'message' => '+' . number_format($metal) . ' Metal, +'
                       . number_format($crystal) . ' Cristal, +'
                       . number_format($deut) . ' Deuterio (valor equivalente)'
        ];
    }

    /* ============================================================
     * OBTENER DATOS DEL JUGADOR EN EL PASE
     * ============================================================ */
    public static function getUsuario($userId)
    {
        $db = self::db();
        $userId = (int)$userId;
        $prefix = self::prefix();

        $row = $db->selectSingle(
            "SELECT * FROM ".$prefix."bp_users WHERE user_id = :uid LIMIT 1",
            [':uid' => $userId]
        );

        if (!$row) {
            $nivelesData = self::generarNiveles();
            $claimedNormal = json_encode(array_fill(0, self::NUM_NIVELES, false));
            $claimedVip    = json_encode(array_fill(0, self::NUM_NIVELES, false));

            $db->insert(
                "INSERT INTO ".$prefix."bp_users 
                 (user_id, current_level, current_coins, total_coins,
                  claimed_normal, claimed_vip, levels_data, last_update)
                 VALUES (:uid, 0, 0, 0, :cn, :cv, :ld, :now)",
                [
                    ':uid' => $userId,
                    ':cn'  => $claimedNormal,
                    ':cv'  => $claimedVip,
                    ':ld'  => json_encode($nivelesData),
                    ':now' => self::now()
                ]
            );

            $row = $db->selectSingle(
                "SELECT * FROM ".$prefix."bp_users WHERE user_id = :uid LIMIT 1",
                [':uid' => $userId]
            );
        }

        $row['levels_data']    = json_decode($row['levels_data'], true);
        $row['claimed_normal'] = json_decode($row['claimed_normal'], true);
        $row['claimed_vip']    = json_decode($row['claimed_vip'], true);

        $levelsOk = is_array($row['levels_data']) 
                 && count($row['levels_data']) === self::NUM_NIVELES;

        if (!$levelsOk) {
            error_log('[AstroIO BP] REGENERANDO levels_data para user_id=' 
                      . $userId . ' a las ' . date('Y-m-d H:i:s')
                      . ' (count=' . (is_array($row['levels_data']) 
                                      ? count($row['levels_data']) : 'null') . ')');

            $nuevosNiveles = self::generarNiveles();
            $db->update(
                "UPDATE ".$prefix."bp_users 
                 SET levels_data = :ld 
                 WHERE user_id = :uid",
                [':ld' => json_encode($nuevosNiveles), ':uid' => $userId]
            );
            $row['levels_data'] = $nuevosNiveles;
        }

        $cnOk = is_array($row['claimed_normal']) 
             && count($row['claimed_normal']) === self::NUM_NIVELES;

        if (!$cnOk) {
            error_log('[AstroIO BP] REGENERANDO claimed_normal para user_id=' 
                      . $userId);
            $row['claimed_normal'] = array_fill(0, self::NUM_NIVELES, false);
            $db->update(
                "UPDATE ".$prefix."bp_users 
                 SET claimed_normal = :cn 
                 WHERE user_id = :uid",
                [':cn' => json_encode($row['claimed_normal']), ':uid' => $userId]
            );
        }

        $cvOk = is_array($row['claimed_vip']) 
             && count($row['claimed_vip']) === self::NUM_NIVELES;

        if (!$cvOk) {
            error_log('[AstroIO BP] REGENERANDO claimed_vip para user_id=' 
                      . $userId);
            $row['claimed_vip'] = array_fill(0, self::NUM_NIVELES, false);
            $db->update(
                "UPDATE ".$prefix."bp_users 
                 SET claimed_vip = :cv 
                 WHERE user_id = :uid",
                [':cv' => json_encode($row['claimed_vip']), ':uid' => $userId]
            );
        }

        return $row;
    }

    /* ============================================================
     * GENERAR LOS 60 NIVELES
     * ============================================================ */
    public static function generarNiveles()
    {
        $niveles = [];

        for ($n = 1; $n <= self::NUM_NIVELES; $n++) {
            $niveles[$n] = [
                'nivel'              => $n,
                'normal_reward'      => self::generarRecompensaNormal($n),
                'vip_reward'         => self::generarRecompensaVip($n),
                'es_cofre_normal'    => false,
                'es_cofre_vip'       => false
            ];
        }

        $excluidosNormal = array_keys(self::NTX_NORMAL_FIJOS);
        $excluidosNormal[] = self::NUM_NIVELES;
        $candidatos = array_values(array_diff(range(1, self::NUM_NIVELES), $excluidosNormal));
        shuffle($candidatos);
        $cofresNormales = array_slice($candidatos, 0, self::COFRES_NORMALES);
        foreach ($cofresNormales as $n) {
            $niveles[$n]['es_cofre_normal'] = true;
            $niveles[$n]['normal_reward']   = null;
        }

        $excluidosVip = array_keys(self::NTX_VIP_FIJOS);
        $excluidosVip[] = self::NUM_NIVELES;
        $candidatosVip = array_values(array_diff(range(1, self::NUM_NIVELES), $excluidosVip));
        shuffle($candidatosVip);
        $cofresVip = array_slice($candidatosVip, 0, self::COFRES_VIP - 1);
        $cofresVip[] = self::NUM_NIVELES;

        foreach ($cofresVip as $n) {
            $niveles[$n]['es_cofre_vip'] = true;
            $niveles[$n]['vip_reward']   = null;
        }

        return $niveles;
    }

    /* ============================================================
     * GENERAR RECOMPENSA DE NIVEL NORMAL
     * ============================================================ */
    private static function generarRecompensaNormal($nivel)
    {
        $roll = rand(1, 100);
        if ($roll <= 40) {
            $nave = self::$NAVES_BASICAS[array_rand(self::$NAVES_BASICAS)];
            return ['tipo' => 'nave', 'columna' => $nave, 'cantidad' => rand(2, 8)];
        } elseif ($roll <= 70) {
            $def = self::$DEFENSAS_BASICAS[array_rand(self::$DEFENSAS_BASICAS)];
            return ['tipo' => 'defensa', 'columna' => $def, 'cantidad' => rand(3, 10)];
        } else {
            return self::generarRecompensaRecursos($nivel);
        }
    }

    /* ============================================================
     * GENERAR RECOMPENSA DE NIVEL VIP
     * ============================================================ */
    private static function generarRecompensaVip($nivel)
    {
        if (isset(self::NTX_VIP_FIJOS[$nivel])) {
            return [
                'tipo'     => 'ntx20',
                'cantidad' => self::NTX_VIP_FIJOS[$nivel]
            ];
        }

        if ($nivel == self::NUM_NIVELES) {
            return ['tipo' => 'ntx20', 'cantidad' => self::NTX_N60_VIP];
        }

        $roll = rand(1, 100);
        if ($roll <= 40) {
            $nave = self::$NAVES_MEDIANAS[array_rand(self::$NAVES_MEDIANAS)];
            return ['tipo' => 'nave', 'columna' => $nave, 'cantidad' => rand(2, 6)];
        } elseif ($roll <= 70) {
            $def = self::$DEFENSAS_MEDIANAS[array_rand(self::$DEFENSAS_MEDIANAS)];
            return ['tipo' => 'defensa', 'columna' => $def, 'cantidad' => rand(2, 6)];
        } else {
            return self::generarRecompensaRecursos($nivel, true);
        }
    }

    /* ============================================================
     * GENERAR RECOMPENSA DE RECURSOS SEGUN NIVEL
     * ============================================================ */
    private static function generarRecompensaRecursos($nivel, $vip = false)
    {
        if ($nivel <= 15) {
            $rango = ['metal' => [5000, 15000], 'crystal' => [2500, 8000], 'deuterium' => [1000, 3000]];
        } elseif ($nivel <= 30) {
            $rango = ['metal' => [15000, 30000], 'crystal' => [8000, 15000], 'deuterium' => [3000, 6000]];
        } elseif ($nivel <= 45) {
            $rango = ['metal' => [30000, 60000], 'crystal' => [15000, 30000], 'deuterium' => [6000, 12000]];
        } else {
            $rango = ['metal' => [50000, 100000], 'crystal' => [25000, 50000], 'deuterium' => [10000, 20000]];
        }

        $tipos = array_keys($rango);
        $tipo  = $tipos[array_rand($tipos)];
        $min   = $rango[$tipo][0];
        $max   = $rango[$tipo][1];

        if ($vip) {
            $min = (int)($min * 1.5);
            $max = (int)($max * 1.5);
        }

        return [
            'tipo'     => 'recurso',
            'recurso'  => $tipo,
            'cantidad' => rand($min, $max)
        ];
    }

    /* ============================================================
     * AÑADIR MONEDAS AL JUGADOR
     * ============================================================ */
    public static function addCoins($userId, $cantidad, $source = 'evento')
    {
        $db = self::db();
        $userId = (int)$userId;
        $cantidad = (int)$cantidad;

        if ($cantidad <= 0) return false;

        $user = self::getUsuario($userId);

        $nuevasMonedas = (int)$user['current_coins'] + $cantidad;
        $nuevoTotal    = (int)$user['total_coins'] + $cantidad;
        $nivelActual   = (int)$user['current_level'];

        while ($nivelActual < self::NUM_NIVELES) {
            $coste = self::getCoste($nivelActual + 1);
            if ($nuevasMonedas >= $coste) {
                $nuevasMonedas -= $coste;
                $nivelActual++;
            } else {
                break;
            }
        }

        $db->update(
            "UPDATE ".self::prefix()."bp_users 
             SET current_level = :lvl,
                 current_coins = :cc,
                 total_coins = :tc,
                 last_update = :now
             WHERE user_id = :uid",
            [
                ':lvl' => $nivelActual,
                ':cc'  => $nuevasMonedas,
                ':tc'  => $nuevoTotal,
                ':now' => self::now(),
                ':uid' => $userId
            ]
        );

        $db->insert(
            "INSERT INTO ".self::prefix()."bp_log 
             (user_id, coins, source, fecha)
             VALUES (:uid, :c, :s, :now)",
            [
                ':uid' => $userId,
                ':c'   => $cantidad,
                ':s'   => $source,
                ':now' => self::now()
            ]
        );

        return true;
    }

    /* ============================================================
     * RECLAMAR RECOMPENSA DE UN NIVEL
     * ============================================================ */
    public static function reclamar($userId, $nivel, $carril)
    {
        $db = self::db();
        $userId = (int)$userId;
        $nivel  = (int)$nivel;
        $carril = $carril === 'vip' ? 'vip' : 'normal';
        $prefix = self::prefix();

        if ($nivel < 1 || $nivel > self::NUM_NIVELES) {
            return ['success' => false, 'message' => 'Nivel invalido.'];
        }

        $user = self::getUsuario($userId);

        if ((int)$user['current_level'] < $nivel) {
            return ['success' => false, 'message' => 'Aun no has alcanzado este nivel.'];
        }

        if ($carril === 'vip' && !self::esVipActivo($userId)) {
            return ['success' => false, 'message' => 'Necesitas VIP activo para reclamar este carril.'];
        }

        $claimedKey = $carril === 'vip' ? 'claimed_vip' : 'claimed_normal';
        if (!empty($user[$claimedKey][$nivel - 1])) {
            return ['success' => false, 'message' => 'Ya reclamaste esta recompensa.'];
        }

        $niveles = $user['levels_data'];
        if (!isset($niveles[$nivel])) {
            return ['success' => false, 'message' => 'Nivel no encontrado.'];
        }

        $nivelData = $niveles[$nivel];
        $esCofre   = $carril === 'vip' ? $nivelData['es_cofre_vip'] : $nivelData['es_cofre_normal'];

        if ($esCofre) {
            $recompensa = self::generarRecompensaCofre($carril, $nivel);
        } else {
            $recompensa = $carril === 'vip' ? $nivelData['vip_reward'] : $nivelData['normal_reward'];
        }

        if (!$recompensa) {
            return ['success' => false, 'message' => 'Recompensa no definida.'];
        }

        // ── ATOMIC CLAIM ──────────────────────────────────────
        $oldJson = json_encode($user[$claimedKey]);

        $newClaimed = $user[$claimedKey];
        $newClaimed[$nivel - 1] = true;
        $newJson = json_encode($newClaimed);

        $affected = $db->update(
            "UPDATE ".$prefix."bp_users 
             SET ".$claimedKey." = :new,
                 last_update = :now
             WHERE user_id = :uid
               AND ".$claimedKey." = :old",
            [
                ':new' => $newJson,
                ':old' => $oldJson,
                ':now' => self::now(),
                ':uid' => $userId
            ]
        );

        if ($affected == 0) {
            return ['success' => false, 'message' => 'Ya reclamaste esta recompensa.'];
        }

        // ── Entregar recompensa ───────────────────────────────
        $result = self::entregarRecompensa($userId, $recompensa);

        if (empty($result['success'])) {
            $db->update(
                "UPDATE ".$prefix."bp_users 
                 SET ".$claimedKey." = :old
                 WHERE user_id = :uid",
                [':old' => $oldJson, ':uid' => $userId]
            );
            return $result;
        }

        return [
            'success' => true,
            'message' => $result['message']
        ];
    }

    /* ============================================================
     * GENERAR RECOMPENSA DE COFRE
     * ============================================================ */
    private static function generarRecompensaCofre($carril, $nivel)
    {
        if ($carril === 'vip' && $nivel == self::NUM_NIVELES) {
            return [
                'tipo'     => 'cofre_final_vip',
                'ntx20'    => self::NTX_N60_VIP,
                'nave'     => self::$NAVES_PODEROSAS[array_rand(self::$NAVES_PODEROSAS)]
            ];
        }

        $probs = $carril === 'vip' ? self::PROB_COFRE_VIP : self::PROB_COFRE_NORMAL;

        $roll = rand(1, 100);
        $acumulado = 0;

        foreach ($probs as $tipo => $prob) {
            $acumulado += $prob;
            if ($roll <= $acumulado) {
                switch ($tipo) {
                    case 'nave':
                        $pool = $carril === 'vip' ? self::$NAVES_MEDIANAS : self::$NAVES_BASICAS;
                        return ['tipo' => 'nave', 'columna' => $pool[array_rand($pool)], 'cantidad' => rand(2, 8)];
                    case 'defensa':
                        $pool = $carril === 'vip' ? self::$DEFENSAS_MEDIANAS : self::$DEFENSAS_BASICAS;
                        return ['tipo' => 'defensa', 'columna' => $pool[array_rand($pool)], 'cantidad' => rand(2, 8)];
                    case 'recursos':
                        return self::generarRecompensaRecursos($nivel, $carril === 'vip');
                }
            }
        }

        return self::generarRecompensaRecursos($nivel);
    }

    /* ============================================================
     * v1.9 — ENTREGAR RECOMPENSA AL JUGADOR (doble riel)
     * ============================================================ */
    public static function entregarRecompensa($userId, $recompensa)
    {
        $db = self::db();
        $userId = (int)$userId;
        $prefix = self::prefix();

        // v1.8/v1.9.1: usar el planeta donde está el jugador, no el principal
        $planetaId = self::getPlanetaActivo($userId);

        if ($planetaId === 0) {
            return ['success' => false, 'message' => 'No tienes planeta activo.'];
        }

        $tipo = $recompensa['tipo'] ?? '';

        // v1.9: Detectar método de pago y moneda
        $method = self::getPlayerMethod($userId);
        $currencyLabel = self::getCurrencyLabel($method);
        $isInternational = ($method === 'QVAPAY');

        switch ($tipo) {
            case 'ntx20':
                $cantidadBase = (int)$recompensa['cantidad'];
                $cantidadFinal = $isInternational ? ($cantidadBase * 2) : $cantidadBase;
                $columna = $isInternational ? 'untx20' : 'ntx20';

                $db->update(
                    "UPDATE ".$prefix."users 
                     SET ".$columna." = ".$columna." + :c 
                     WHERE id = :uid",
                    [':c' => $cantidadFinal, ':uid' => $userId]
                );
                self::logEntrega($userId, 'entrega_' . $columna, $cantidadFinal);
                return ['success' => true, 'message' => '+' . $cantidadFinal . ' ' . $currencyLabel];

            case 'recurso':
                $recurso = $recompensa['recurso'];
                $cant = (int)$recompensa['cantidad'];
                $permitidos = ['metal', 'crystal', 'deuterium'];
                if (!in_array($recurso, $permitidos)) {
                    return ['success' => false, 'message' => 'Recurso invalido.'];
                }
                $nombresRecurso = [
                    'metal'     => 'Metal',
                    'crystal'   => 'Cristal',
                    'deuterium' => 'Deuterio'
                ];
                $nombreRec = $nombresRecurso[$recurso] ?? ucfirst($recurso);
                $db->update(
                    "UPDATE ".$prefix."planets 
                     SET ".$recurso." = ".$recurso." + :c 
                     WHERE id = :pid",
                    [':c' => $cant, ':pid' => $planetaId]
                );
                self::logEntrega($userId, 'entrega_recurso', $recurso . ':' . $cant);
                return ['success' => true, 'message' => '+' . number_format($cant) . ' ' . $nombreRec];

            case 'nave':
                return self::entregarNave($userId, $planetaId, $recompensa['columna'], (int)$recompensa['cantidad']);

            case 'defensa':
                return self::entregarDefensa($userId, $planetaId, $recompensa['columna'], (int)$recompensa['cantidad']);

            case 'cofre_final_vip':
                $cantBase = (int)$recompensa['ntx20'];
                $cantFinal = $isInternational ? ($cantBase * 2) : $cantBase;
                $col = $isInternational ? 'untx20' : 'ntx20';

                $db->update(
                    "UPDATE ".$prefix."users 
                     SET ".$col." = ".$col." + :c 
                     WHERE id = :uid",
                    [':c' => $cantFinal, ':uid' => $userId]
                );
                self::logEntrega($userId, 'entrega_' . $col, $cantFinal);
                $naveResult = self::entregarNave($userId, $planetaId, $recompensa['nave'], 1);
                return [
                    'success' => true,
                    'message' => '+' . $cantFinal . ' ' . $currencyLabel . ' + ' . $naveResult['message']
                ];
        }

        return ['success' => false, 'message' => 'Tipo de recompensa desconocido.'];
    }

    /* ============================================================
     * ENTREGAR NAVE (conversion JUSTA por valor)
     * ============================================================ */
    private static function entregarNave($userId, $planetaId, $columna, $cantidad)
    {
        $db = self::db();
        $prefix = self::prefix();

        $naveId = array_search($columna, self::$NAVES);
        if ($naveId === false) {
            return ['success' => false, 'message' => 'Nave no valida: ' . $columna];
        }

        if (self::cumpleRequisitos($userId, $planetaId, $naveId)) {
            $affected = $db->update(
                "UPDATE ".$prefix."planets 
                 SET ".$columna." = ".$columna." + :c 
                 WHERE id = :pid",
                [':c' => $cantidad, ':pid' => $planetaId]
            );

            if ($affected === false || (int)$affected === 0) {
                return [
                    'success' => false,
                    'message' => 'No se pudo depositar la nave (columna: ' . $columna . ').'
                ];
            }

            $nombre = self::nombreLegible($columna, 'nave');
            self::logEntrega($userId, 'entrega_nave', $columna . ':' . $cantidad);
            return ['success' => true, 'message' => '+' . $cantidad . ' ' . $nombre];
        }

        $valorOriginal = self::getValorElemento($naveId, $cantidad);
        $config = self::getFallbackConfig();

        if ($valorOriginal <= 0) {
            $alt = self::buscarAlternativaNave($userId, $planetaId, $columna, 0, $config);
            if ($alt === null) {
                return self::entregarRecursosEquivalentes($userId, $planetaId, 0, 'nave', $columna, $cantidad);
            }
            $cantidadJusta = $cantidad;
            $columnaFinal  = $alt['columna'];
            $naveIdFinal   = $alt['nave_id'];
        } else {
            $alt = self::buscarAlternativaNave($userId, $planetaId, $columna, $valorOriginal, $config);

            if ($alt === null) {
                return self::entregarRecursosEquivalentes(
                    $userId, $planetaId, $valorOriginal, 'nave', $columna, $cantidad
                );
            }

            $cantidadJusta = $alt['cantidad'];
            $columnaFinal  = $alt['columna'];
            $naveIdFinal   = $alt['nave_id'];
        }

        if ($cantidadJusta < 1) $cantidadJusta = 1;

        $affected = $db->update(
            "UPDATE ".$prefix."planets 
             SET ".$columnaFinal." = ".$columnaFinal." + :c 
             WHERE id = :pid",
            [':c' => $cantidadJusta, ':pid' => $planetaId]
        );

        if ($affected === false || (int)$affected === 0) {
            return [
                'success' => false,
                'message' => 'No se pudo depositar la nave (columna: ' . $columnaFinal . ').'
            ];
        }

        $nombreOriginal = self::nombreLegible($columna, 'nave');
        $nombreFinal    = self::nombreLegible($columnaFinal, 'nave');
        $valorFinal     = self::getValorElemento($naveIdFinal, $cantidadJusta);

        self::logEntrega(
            $userId,
            'entrega_nave_alt',
            $columna . '->' . $columnaFinal . ':' . $cantidad . '->' . $cantidadJusta
            . ':val' . $valorOriginal . '->' . $valorFinal
        );

        return [
            'success' => true,
            'message' => '+' . $cantidadJusta . ' ' . $nombreFinal
                       . ' (sustituye a ' . $cantidad . ' ' . $nombreOriginal
                       . ' por requisitos, valor equivalente)'
        ];
    }

    /* ============================================================
     * ENTREGAR DEFENSA (conversion JUSTA por valor)
     * ============================================================ */
    private static function entregarDefensa($userId, $planetaId, $columna, $cantidad)
    {
        $db = self::db();
        $prefix = self::prefix();

        $defId = array_search($columna, self::$DEFENSAS);
        if ($defId === false) {
            return ['success' => false, 'message' => 'Defensa no valida: ' . $columna];
        }

        if (self::cumpleRequisitos($userId, $planetaId, $defId)) {
            $affected = $db->update(
                "UPDATE ".$prefix."planets 
                 SET ".$columna." = ".$columna." + :c 
                 WHERE id = :pid",
                [':c' => $cantidad, ':pid' => $planetaId]
            );

            if ($affected === false || (int)$affected === 0) {
                return [
                    'success' => false,
                    'message' => 'No se pudo depositar la defensa (columna: ' . $columna . ').'
                ];
            }

            $nombre = self::nombreLegible($columna, 'defensa');
            self::logEntrega($userId, 'entrega_defensa', $columna . ':' . $cantidad);
            return ['success' => true, 'message' => '+' . $cantidad . ' ' . $nombre];
        }

        $valorOriginal = self::getValorElemento($defId, $cantidad);
        $config = self::getFallbackConfig();

        if ($valorOriginal <= 0) {
            $alt = self::buscarAlternativaDefensa($userId, $planetaId, $columna, 0, $config);
            if ($alt === null) {
                return self::entregarRecursosEquivalentes($userId, $planetaId, 0, 'defensa', $columna, $cantidad);
            }
            $cantidadJusta = $cantidad;
            $columnaFinal  = $alt['columna'];
            $defIdFinal    = $alt['def_id'];
        } else {
            $alt = self::buscarAlternativaDefensa($userId, $planetaId, $columna, $valorOriginal, $config);

            if ($alt === null) {
                return self::entregarRecursosEquivalentes(
                    $userId, $planetaId, $valorOriginal, 'defensa', $columna, $cantidad
                );
            }

            $cantidadJusta = $alt['cantidad'];
            $columnaFinal  = $alt['columna'];
            $defIdFinal    = $alt['def_id'];
        }

        if ($cantidadJusta < 1) $cantidadJusta = 1;

        $affected = $db->update(
            "UPDATE ".$prefix."planets 
             SET ".$columnaFinal." = ".$columnaFinal." + :c 
             WHERE id = :pid",
            [':c' => $cantidadJusta, ':pid' => $planetaId]
        );

        if ($affected === false || (int)$affected === 0) {
            return [
                'success' => false,
                'message' => 'No se pudo depositar la defensa (columna: ' . $columnaFinal . ').'
            ];
        }

        $nombreOriginal = self::nombreLegible($columna, 'defensa');
        $nombreFinal    = self::nombreLegible($columnaFinal, 'defensa');
        $valorFinal     = self::getValorElemento($defIdFinal, $cantidadJusta);

        self::logEntrega(
            $userId,
            'entrega_defensa_alt',
            $columna . '->' . $columnaFinal . ':' . $cantidad . '->' . $cantidadJusta
            . ':val' . $valorOriginal . '->' . $valorFinal
        );

        return [
            'success' => true,
            'message' => '+' . $cantidadJusta . ' ' . $nombreFinal
                       . ' (sustituye a ' . $cantidad . ' ' . $nombreOriginal
                       . ' por requisitos, valor equivalente)'
        ];
    }

    /* ============================================================
     * BUSCAR ALTERNATIVA DE NAVE (por VALOR)
     * ============================================================ */
    private static function buscarAlternativaNave($userId, $planetaId, $columnaOriginal, $valorOriginal, $config)
    {
        $categoria = self::getCategoriaNave($columnaOriginal);

        $orden = [];
        if ($categoria === 'poderosa') {
            $orden = [self::$NAVES_PODEROSAS, self::$NAVES_MEDIANAS, self::$NAVES_BASICAS];
        } elseif ($categoria === 'mediana') {
            $orden = [self::$NAVES_MEDIANAS, self::$NAVES_BASICAS];
        } else {
            $orden = [self::$NAVES_BASICAS];
        }

        $nombreOriginal = self::nombreLegible($columnaOriginal, 'nave');
        $factor  = max(0.0, (float)$config['factor']);
        $round   = $config['round'];
        $target  = $valorOriginal > 0 ? ($valorOriginal * $factor) : 0;

        foreach ($orden as $idx => $pool) {
            $candidatos = [];
            foreach ($pool as $columna) {
                if ($columna === $columnaOriginal) continue;
                $naveId = array_search($columna, self::$NAVES);
                if ($naveId === false) continue;
                if (!self::cumpleRequisitos($userId, $planetaId, $naveId)) continue;

                $valorUnidad = self::getValorElemento($naveId, 1);
                if ($valorUnidad <= 0) continue;

                $candidatos[] = [
                    'columna'     => $columna,
                    'nave_id'     => $naveId,
                    'valor_unidad'=> $valorUnidad,
                ];
            }

            if (empty($candidatos)) continue;

            usort($candidatos, function ($a, $b) {
                if ($a['valor_unidad'] == $b['valor_unidad']) return 0;
                return ($a['valor_unidad'] < $b['valor_unidad']) ? 1 : -1;
            });

            $motivo = ($idx === 0)
                ? $nombreOriginal . ' no disponible'
                : $nombreOriginal . ' no disponible, alternativa basica';

            if ($config['mode'] !== 'closest') {
                $best = $candidatos[0];
                $cantidad = $target > 0
                    ? self::redondear($target / $best['valor_unidad'], $round)
                    : 1;
                if ($cantidad < 1) $cantidad = 1;
                return [
                    'columna'     => $best['columna'],
                    'nave_id'     => $best['nave_id'],
                    'cantidad'    => $cantidad,
                    'valor_final' => $cantidad * $best['valor_unidad'],
                    'motivo'      => $motivo,
                ];
            }

            $bestCand = null;
            $bestDiff = PHP_INT_MAX;
            foreach ($candidatos as $cand) {
                $cantidad = $target > 0
                    ? self::redondear($target / $cand['valor_unidad'], $round)
                    : 1;
                if ($cantidad < 1) $cantidad = 1;
                $valorFinal = $cantidad * $cand['valor_unidad'];
                $diff = abs($valorFinal - $target);
                if ($diff < $bestDiff) {
                    $bestDiff = $diff;
                    $bestCand = [
                        'columna'     => $cand['columna'],
                        'nave_id'     => $cand['nave_id'],
                        'cantidad'    => $cantidad,
                        'valor_final' => $valorFinal,
                        'motivo'      => $motivo,
                    ];
                }
            }
            if ($bestCand !== null) return $bestCand;
        }

        return null;
    }

    /* ============================================================
     * BUSCAR ALTERNATIVA DE DEFENSA (por VALOR)
     * ============================================================ */
    private static function buscarAlternativaDefensa($userId, $planetaId, $columnaOriginal, $valorOriginal, $config)
    {
        $categoria = self::getCategoriaDefensa($columnaOriginal);

        $orden = [];
        if ($categoria === 'poderosa') {
            $orden = [self::$DEFENSAS_PODEROSAS, self::$DEFENSAS_MEDIANAS, self::$DEFENSAS_BASICAS];
        } elseif ($categoria === 'mediana') {
            $orden = [self::$DEFENSAS_MEDIANAS, self::$DEFENSAS_BASICAS];
        } else {
            $orden = [self::$DEFENSAS_BASICAS];
        }

        $nombreOriginal = self::nombreLegible($columnaOriginal, 'defensa');
        $factor  = max(0.0, (float)$config['factor']);
        $round   = $config['round'];
        $target  = $valorOriginal > 0 ? ($valorOriginal * $factor) : 0;

        foreach ($orden as $idx => $pool) {
            $candidatos = [];
            foreach ($pool as $columna) {
                if ($columna === $columnaOriginal) continue;
                $defId = array_search($columna, self::$DEFENSAS);
                if ($defId === false) continue;
                if (!self::cumpleRequisitos($userId, $planetaId, $defId)) continue;

                $valorUnidad = self::getValorElemento($defId, 1);
                if ($valorUnidad <= 0) continue;

                $candidatos[] = [
                    'columna'     => $columna,
                    'def_id'      => $defId,
                    'valor_unidad'=> $valorUnidad,
                ];
            }

            if (empty($candidatos)) continue;

            usort($candidatos, function ($a, $b) {
                if ($a['valor_unidad'] == $b['valor_unidad']) return 0;
                return ($a['valor_unidad'] < $b['valor_unidad']) ? 1 : -1;
            });

            $motivo = ($idx === 0)
                ? $nombreOriginal . ' no disponible'
                : $nombreOriginal . ' no disponible, alternativa basica';

            if ($config['mode'] !== 'closest') {
                $best = $candidatos[0];
                $cantidad = $target > 0
                    ? self::redondear($target / $best['valor_unidad'], $round)
                    : 1;
                if ($cantidad < 1) $cantidad = 1;
                return [
                    'columna'     => $best['columna'],
                    'def_id'      => $best['def_id'],
                    'cantidad'    => $cantidad,
                    'valor_final' => $cantidad * $best['valor_unidad'],
                    'motivo'      => $motivo,
                ];
            }

            $bestCand = null;
            $bestDiff = PHP_INT_MAX;
            foreach ($candidatos as $cand) {
                $cantidad = $target > 0
                    ? self::redondear($target / $cand['valor_unidad'], $round)
                    : 1;
                if ($cantidad < 1) $cantidad = 1;
                $valorFinal = $cantidad * $cand['valor_unidad'];
                $diff = abs($valorFinal - $target);
                if ($diff < $bestDiff) {
                    $bestDiff = $diff;
                    $bestCand = [
                        'columna'     => $cand['columna'],
                        'def_id'      => $cand['def_id'],
                        'cantidad'    => $cantidad,
                        'valor_final' => $valorFinal,
                        'motivo'      => $motivo,
                    ];
                }
            }
            if ($bestCand !== null) return $bestCand;
        }

        return null;
    }

    /* ============================================================
     * CATEGORIA DE UNA NAVE
     * ============================================================ */
    private static function getCategoriaNave($columna)
    {
        if (in_array($columna, self::$NAVES_PODEROSAS)) return 'poderosa';
        if (in_array($columna, self::$NAVES_MEDIANAS))  return 'mediana';
        if (in_array($columna, self::$NAVES_BASICAS))   return 'basica';
        return 'basica';
    }

    /* ============================================================
     * CATEGORIA DE UNA DEFENSA
     * ============================================================ */
    private static function getCategoriaDefensa($columna)
    {
        if (in_array($columna, self::$DEFENSAS_PODEROSAS)) return 'poderosa';
        if (in_array($columna, self::$DEFENSAS_MEDIANAS))  return 'mediana';
        if (in_array($columna, self::$DEFENSAS_BASICAS))   return 'basica';
        return 'basica';
    }

    /* ============================================================
     * VERIFICAR SI CUMPLE REQUISITOS
     * ============================================================ */
    private static function cumpleRequisitos($userId, $planetaId, $elementId)
    {
        $db = self::db();
        $prefix = self::prefix();

        $requisitos = $db->select(
            "SELECT requireID, requireLevel 
             FROM ".$prefix."vars_requriements 
             WHERE elementID = :eid",
            [':eid' => (int)$elementId]
        );

        if (!$requisitos || !is_array($requisitos)) return true;

        foreach ($requisitos as $req) {
            $requireId = (int)$req['requireID'];
            $nivelReq  = (int)$req['requireLevel'];

            $columna = self::getIdToColumna($requireId);
            if (!$columna) continue;

            if (self::esColumnaDePlaneta($columna)) {
                $row = $db->selectSingle(
                    "SELECT ".$columna." AS nivel 
                     FROM ".$prefix."planets 
                     WHERE id = :pid",
                    [':pid' => $planetaId]
                );
                if ($row && (int)$row['nivel'] >= $nivelReq) continue;
                return false;
            }

            if (self::esColumnaDeUsuario($columna)) {
                $row = $db->selectSingle(
                    "SELECT ".$columna." AS nivel 
                     FROM ".$prefix."users 
                     WHERE id = :uid",
                    [':uid' => $userId]
                );
                if ($row && (int)$row['nivel'] >= $nivelReq) continue;
                return false;
            }
        }

        return true;
    }

    /* ============================================================
     * MAPEO ID => COLUMNA (para requisitos)
     * ============================================================ */
    private static function getIdToColumna($id)
    {
        $id = (int)$id;
        $edificios = [
            1 => 'metal_mine', 2 => 'crystal_mine', 3 => 'deuterium_sintetizer',
            4 => 'solar_plant', 12 => 'fusion_plant', 14 => 'robot_factory',
            15 => 'nano_factory', 21 => 'hangar', 22 => 'metal_store',
            23 => 'crystal_store', 24 => 'deuterium_store', 31 => 'laboratory',
            33 => 'terraformer', 34 => 'ally_deposit', 41 => 'mondbasis',
            42 => 'phalanx', 43 => 'sprungtor', 44 => 'silo'
        ];
        $investigaciones = [
            106 => 'spy_tech', 108 => 'computer_tech', 109 => 'military_tech',
            110 => 'defence_tech', 111 => 'shield_tech', 113 => 'energy_tech',
            114 => 'hyperspace_tech', 115 => 'combustion_tech',
            117 => 'impulse_motor_tech', 118 => 'hyperspace_motor_tech',
            120 => 'laser_tech', 121 => 'ionic_tech', 122 => 'buster_tech',
            123 => 'intergalactic_tech', 124 => 'expedition_tech',
            131 => 'metal_proc_tech', 132 => 'crystal_proc_tech',
            133 => 'deuterium_proc_tech', 199 => 'graviton_tech'
        ];

        if (isset($edificios[$id])) return $edificios[$id];
        if (isset($investigaciones[$id])) return $investigaciones[$id];
        return null;
    }

    private static function esColumnaDePlaneta($columna)
    {
        $cols = [
            'metal_mine', 'crystal_mine', 'deuterium_sintetizer', 'solar_plant',
            'fusion_plant', 'robot_factory', 'nano_factory', 'hangar',
            'metal_store', 'crystal_store', 'deuterium_store', 'laboratory',
            'terraformer', 'ally_deposit', 'mondbasis', 'phalanx',
            'sprungtor', 'silo'
        ];
        return in_array($columna, $cols);
    }

    private static function esColumnaDeUsuario($columna)
    {
        $cols = [
            'spy_tech', 'computer_tech', 'military_tech', 'defence_tech',
            'shield_tech', 'energy_tech', 'hyperspace_tech', 'combustion_tech',
            'impulse_motor_tech', 'hyperspace_motor_tech', 'laser_tech',
            'ionic_tech', 'buster_tech', 'intergalactic_tech', 'expedition_tech',
            'metal_proc_tech', 'crystal_proc_tech', 'deuterium_proc_tech',
            'graviton_tech'
        ];
        return in_array($columna, $cols);
    }

    /* ============================================================
     * OBTENER CONFIGURACION
     * ============================================================ */
    public static function getConfig()
    {
        self::ensureFallbackColumns();

        $db = self::db();
        $prefix = self::prefix();

        $row = $db->selectSingle(
            "SELECT * FROM ".$prefix."bp_config ORDER BY id ASC LIMIT 1"
        );

        if (!$row) {
            $db->insert(
                "INSERT INTO ".$prefix."bp_config (last_reset, season_name)
                 VALUES (:now, 'Temporada 1')",
                [':now' => self::now()]
            );
            return [
                'id'          => 1,
                'last_reset'  => self::now(),
                'season_name' => 'Temporada 1'
            ];
        }

        return $row;
    }

    /* ============================================================
     * VERIFICAR REINICIO (32 dias)
     * ============================================================ */
    public static function verificarReinicio()
    {
        $db = self::db();
        $prefix = self::prefix();
        $config = self::getConfig();

        $lastReset = (int)$config['last_reset'];
        $ahora = self::now();

        if (($ahora - $lastReset) < self::SEGUNDOS_RESET) {
            return false;
        }

        $db->query("DELETE FROM ".$prefix."bp_users");

        $nuevoNumero = self::extraerNumeroTemporada($config['season_name']) + 1;
        $db->update(
            "UPDATE ".$prefix."bp_config 
             SET last_reset = :now,
                 season_name = :name
             WHERE id = :id",
            [
                ':now'  => $ahora,
                ':name' => 'Temporada ' . $nuevoNumero,
                ':id'   => $config['id']
            ]
        );

        return true;
    }

    private static function extraerNumeroTemporada($nombre)
    {
        if (preg_match('/\d+/', $nombre, $m)) {
            return (int)$m[0];
        }
        return 1;
    }

    /* ============================================================
     * TIEMPO RESTANTE PARA EL REINICIO
     * ============================================================ */
    public static function getTiempoRestante()
    {
        $config = self::getConfig();
        $lastReset = (int)$config['last_reset'];
        $ahora = self::now();
        $restante = ($lastReset + self::SEGUNDOS_RESET) - $ahora;

        if ($restante < 0) $restante = 0;

        $dias  = floor($restante / 86400);
        $horas = floor(($restante % 86400) / 3600);
        $mins  = floor(($restante % 3600) / 60);

        return [
            'segundos' => $restante,
            'dias'     => $dias,
            'horas'    => $horas,
            'mins'     => $mins,
            'texto'    => $dias . 'd ' . $horas . 'h ' . $mins . 'm'
        ];
    }

    /* ============================================================
     * DAR MONEDAS POR EVENTO
     * ============================================================ */
    public static function darMonedasPorEvento($userId, $tipoEvento)
    {
        switch ($tipoEvento) {
            case 'daily':
                $cantidad = rand(self::MONEDAS_DIARIO[0], self::MONEDAS_DIARIO[1]);
                break;
            case 'weekly':
                $cantidad = rand(self::MONEDAS_SEMANAL[0], self::MONEDAS_SEMANAL[1]);
                break;
            case 'elite':
                $cantidad = rand(self::MONEDAS_ELITE[0], self::MONEDAS_ELITE[1]);
                break;
            default:
                return 0;
        }

        self::addCoins($userId, $cantidad, 'evento_' . $tipoEvento);
        return $cantidad;
    }
}