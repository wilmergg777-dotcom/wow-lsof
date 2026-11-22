<?php
/**
 * ============================================================
 * ClimaEngine — Sistema de Clima de Combate v1.3
 * ============================================================
 * Motor central del sistema de clima:
 *  - getCatalogoActivo():        catálogo de climas activos (cache en request)
 *  - getCatalogoCompleto():      todos los climas (admin)
 *  - getClimaInfo($id):          info de un clima por ID
 *  - getClimaPorClave($clave):   info de un clima por clave ('despejado', ...)
 *  - sortearClimaId():           selección aleatoria ponderada por `peso`
 *  - getClimaPlaneta($pid):      clima actual de un planeta/luna (lazy fallback)
 *  - getFactoresPlaneta($pid):   4 factores listos para el motor de combate
 *  - getFactoresPorClimaId($id): factores por ID de clima (para flotas con clima fijado)
 *  - asignarClimaPlaneta($pid, $cid): asigna un clima (aleatorio o forzado)
 *  - getPrediccionPlaneta($pid): clima previsto para mañana
 *  - predecirClimaPlaneta($pid): sortea y guarda la predicción
 *  - aplicarPrediccion($pid):    aplica clima_previsto_id como actual (o sortea)
 *  - forzarClima($pid, $cid, $admin): fuerza clima (solo admin)
 *  - validarFactores($f):        valida rangos (0.00-3.00, bajas <= 1.25)
 *  - fmtPct($factor):            +X% / -X% / ±0%
 *  - getEstadisticasGlobales():  cuántos planetas por clima
 *  - registrarLog(...):          inserta en uni1_clima_log
 *  - limpiarHuerfanos():         borra climas de planetas destruidos
 *  - resetCache():               limpia caché en memoria (para tests)
 *
 * v1.2 — BUFF CLIMÁTICO (cofres):
 *  - getActiveBuff($uid):        buff activo del jugador (o null)
 *  - setActiveBuff(...):         activa un buff (24h por defecto)
 *  - removeExpiredBuffs():       borra buffs caducados (para cron)
 *  - applyBuff($f, $buff):       aplica buff a los 4 factores (solo negativos)
 *  - getFactoresConBuff($cid,$bid): atajo clima+buff en una llamada
 *  - getBuffIdFromType($tipo):   'estabilizador_menor' -> 1, etc.
 *  - getTypeFromBuffId($bid):    1 -> 'estabilizador_menor', etc.
 *  - getBuffInfo($bid):          ['clave'=>..., 'nombre'=>...]
 *  - contarBuffActivos():        total de buffs activos (stats admin)
 *
 * v1.3 — FIX DIRECCIÓN BAJAS + clima_id EN FACTORES:
 *  - applyBuff() ahora trata factor_bajas con la dirección correcta:
 *    en el motor de combate los supervivientes se DIVIDEN por factor_bajas,
 *    por lo que la penalización de bajas es factor_bajas > 1.00 (MÁS bajas).
 *    Menor: reduce la penalización a la mitad | Mayor: la neutraliza |
 *    Dominio: la convierte en bonus (menos bajas).
 *    Los bonus (factor_bajas < 1.00) NO se tocan.
 *  - getFactoresPlaneta() y getFactoresPorClimaId() devuelven también 'clima_id',
 *    para que los reportes de flotas antiguas (sin clima fijado al lanzar)
 *    guarden el clima real en %%RW%% en vez de NULL.
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

class ClimaEngine
{
    const FACTOR_BAJAS_MAX = 1.25;
    const FACTOR_MIN       = 0.00;
    const FACTOR_MAX       = 3.00;
    const CLIMA_NEUTRO     = 'despejado';

    // Buffs climáticos
    const BUFF_MENOR   = 1;
    const BUFF_MAYOR   = 2;
    const BUFF_DOMINIO = 3;
    const BUFF_DURACION_DEFAULT = 24; // horas

    private static $cachePlaneta      = [];
    private static $cacheCatalogo     = null;
    private static $cacheCatalogoPesos = null;

    /* ============================================================
     * UTILIDADES
     * ============================================================ */

    private static function prefix()
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    private static function db()
    {
        return Database::get();
    }

    private static function now()
    {
        return defined('TIMESTAMP') ? (int)TIMESTAMP : time();
    }

    /* ============================================================
     * CATÁLOGO
     * ============================================================ */

    public static function getCatalogoActivo()
    {
        if (self::$cacheCatalogo !== null) {
            return self::$cacheCatalogo;
        }

        $prefix = self::prefix();
        $rows = self::db()->select(
            "SELECT * FROM `".$prefix."climas` WHERE activo = 1 ORDER BY id ASC"
        );

        self::$cacheCatalogo      = [];
        self::$cacheCatalogoPesos = [];
        $totalPeso = 0;

        if (is_array($rows)) {
            foreach ($rows as $row) {
                $id = (int)$row['id'];
                self::$cacheCatalogo[$id] = $row;
                $totalPeso += max(0, (int)$row['peso']);
                self::$cacheCatalogoPesos[] = [$id, $totalPeso];
            }
        }

        return self::$cacheCatalogo;
    }

    public static function getCatalogoCompleto()
    {
        $prefix = self::prefix();
        return self::db()->select(
            "SELECT * FROM `".$prefix."climas` ORDER BY id ASC"
        );
    }

    public static function getClimaInfo($climaId)
    {
        $climaId = (int)$climaId;
        if ($climaId <= 0) return null;

        $catalogo = self::getCatalogoActivo();
        if (isset($catalogo[$climaId])) {
            return $catalogo[$climaId];
        }

        $prefix = self::prefix();
        return self::db()->selectSingle(
            "SELECT * FROM `".$prefix."climas` WHERE id = :id",
            [':id' => $climaId]
        );
    }

    public static function getClimaPorClave($clave)
    {
        $prefix = self::prefix();
        return self::db()->selectSingle(
            "SELECT * FROM `".$prefix."climas` WHERE clave = :c",
            [':c' => $clave]
        );
    }

    /* ============================================================
     * SORTEO ALEATORIO PONDERADO
     * ============================================================ */

    public static function sortearClimaId()
    {
        self::getCatalogoActivo();

        if (empty(self::$cacheCatalogoPesos)) {
            $neutro = self::getClimaPorClave(self::CLIMA_NEUTRO);
            return $neutro ? (int)$neutro['id'] : null;
        }

        $totalPeso = end(self::$cacheCatalogoPesos)[1];
        if ($totalPeso <= 0) {
            $neutro = self::getClimaPorClave(self::CLIMA_NEUTRO);
            return $neutro ? (int)$neutro['id'] : null;
        }

        $r = random_int(1, $totalPeso);
        foreach (self::$cacheCatalogoPesos as $item) {
            list($id, $acum) = $item;
            if ($r <= $acum) {
                return $id;
            }
        }

        return self::$cacheCatalogoPesos[0][0];
    }

    /* ============================================================
     * CLIMA POR PLANETA
     * ============================================================ */

    public static function getClimaPlaneta($planetaId)
    {
        $planetaId = (int)$planetaId;
        if ($planetaId <= 0) return null;

        if (isset(self::$cachePlaneta[$planetaId])) {
            return self::$cachePlaneta[$planetaId];
        }

        $prefix = self::prefix();

        $row = self::db()->selectSingle(
            "SELECT cp.planeta_id, cp.clima_id, cp.clima_previsto_id,
                    cp.fecha_asignacion, cp.fecha_expiracion, cp.fecha_prediccion,
                    c.id AS clima_ref_id, c.clave, c.nombre, c.descripcion,
                    c.factor_ataque, c.factor_defensa, c.factor_bajas, c.factor_botin,
                    c.peso, c.categoria, c.activo
             FROM `".$prefix."clima_planeta` cp
             INNER JOIN `".$prefix."climas` c ON c.id = cp.clima_id
             WHERE cp.planeta_id = :pid
               AND cp.fecha_expiracion > NOW()
               AND c.activo = 1
             LIMIT 1",
            [':pid' => $planetaId]
        );

        if ($row) {
            self::$cachePlaneta[$planetaId] = $row;
            return $row;
        }

        return self::asignarClimaPlaneta($planetaId);
    }

    public static function getFactoresPlaneta($planetaId)
    {
        $clima = self::getClimaPlaneta($planetaId);

        if (!$clima) {
            return [
                'clave'          => 'neutro',
                'nombre'         => 'Sin clima',
                'descripcion'    => '',
                'clima_id'       => 0,
                'factor_ataque'  => 1.00,
                'factor_defensa' => 1.00,
                'factor_bajas'   => 1.00,
                'factor_botin'   => 1.00,
            ];
        }

        return [
            'clave'          => $clima['clave'],
            'nombre'         => $clima['nombre'],
            'descripcion'    => $clima['descripcion'],
            'clima_id'       => isset($clima['clima_ref_id'])
                                ? (int)$clima['clima_ref_id']
                                : (isset($clima['id']) ? (int)$clima['id'] : 0),
            'factor_ataque'  => (float)$clima['factor_ataque'],
            'factor_defensa' => (float)$clima['factor_defensa'],
            'factor_bajas'   => (float)$clima['factor_bajas'],
            'factor_botin'   => (float)$clima['factor_botin'],
        ];
    }

    public static function getFactoresPorClimaId($climaId)
    {
        $clima = self::getClimaInfo($climaId);

        if (!$clima) {
            return [
                'clave'          => 'neutro',
                'nombre'         => 'Sin clima',
                'descripcion'    => '',
                'clima_id'       => 0,
                'factor_ataque'  => 1.00,
                'factor_defensa' => 1.00,
                'factor_bajas'   => 1.00,
                'factor_botin'   => 1.00,
            ];
        }

        return [
            'clave'          => $clima['clave'],
            'nombre'         => $clima['nombre'],
            'descripcion'    => $clima['descripcion'],
            'clima_id'       => isset($clima['id']) ? (int)$clima['id'] : (int)$climaId,
            'factor_ataque'  => (float)$clima['factor_ataque'],
            'factor_defensa' => (float)$clima['factor_defensa'],
            'factor_bajas'   => (float)$clima['factor_bajas'],
            'factor_botin'   => (float)$clima['factor_botin'],
        ];
    }

    public static function asignarClimaPlaneta($planetaId, $climaIdForzado = null)
    {
        $planetaId = (int)$planetaId;
        if ($planetaId <= 0) return null;

        $climaId = $climaIdForzado ? (int)$climaIdForzado : self::sortearClimaId();
        if (!$climaId) {
            $neutro = self::getClimaPorClave(self::CLIMA_NEUTRO);
            if (!$neutro) return null;
            $climaId = (int)$neutro['id'];
        }

        $clima = self::getClimaInfo($climaId);
        if (!$clima || (int)$clima['activo'] !== 1) {
            $neutro = self::getClimaPorClave(self::CLIMA_NEUTRO);
            if (!$neutro) return null;
            $climaId = (int)$neutro['id'];
            $clima   = $neutro;
        }

        $prefix = self::prefix();

        self::db()->insert(
            "INSERT INTO `".$prefix."clima_planeta`
                (planeta_id, clima_id, fecha_asignacion, fecha_expiracion)
             VALUES (:pid, :cid, NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR))
             ON DUPLICATE KEY UPDATE
                clima_id           = VALUES(clima_id),
                fecha_asignacion   = VALUES(fecha_asignacion),
                fecha_expiracion   = VALUES(fecha_expiracion),
                clima_previsto_id  = NULL,
                fecha_prediccion   = NULL",
            [':pid' => $planetaId, ':cid' => $climaId]
        );

        $clima['planeta_id']       = $planetaId;
        $clima['fecha_expiracion'] = date('Y-m-d H:i:s', self::now() + 86400);
        self::$cachePlaneta[$planetaId] = $clima;

        return $clima;
    }

    /* ============================================================
     * PREDICCIÓN
     * ============================================================ */

    public static function getPrediccionPlaneta($planetaId)
    {
        $planetaId = (int)$planetaId;
        if ($planetaId <= 0) return null;

        $prefix = self::prefix();
        return self::db()->selectSingle(
            "SELECT c.*, cp.fecha_prediccion
             FROM `".$prefix."clima_planeta` cp
             INNER JOIN `".$prefix."climas` c ON c.id = cp.clima_previsto_id
             WHERE cp.planeta_id = :pid
               AND cp.clima_previsto_id IS NOT NULL
               AND c.activo = 1
             LIMIT 1",
            [':pid' => $planetaId]
        );
    }

    public static function predecirClimaPlaneta($planetaId)
    {
        $planetaId = (int)$planetaId;
        if ($planetaId <= 0) return null;

        $climaId = self::sortearClimaId();
        if (!$climaId) return null;

        $clima = self::getClimaInfo($climaId);
        if (!$clima) return null;

        $prefix = self::prefix();

        // Si el planeta no tiene clima actual, asignar uno neutro primero
        $actual = self::db()->selectSingle(
            "SELECT clima_id FROM `".$prefix."clima_planeta` WHERE planeta_id = :pid",
            [':pid' => $planetaId]
        );

        if ($actual) {
            self::db()->insert(
                "INSERT INTO `".$prefix."clima_planeta`
                    (planeta_id, clima_id, clima_previsto_id, fecha_asignacion, fecha_expiracion, fecha_prediccion)
                 VALUES (:pid, :cid_actual, :cid_prev, NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR), NOW())
                 ON DUPLICATE KEY UPDATE
                    clima_previsto_id = IF(clima_previsto_id IS NULL, VALUES(clima_previsto_id), clima_previsto_id),
                    fecha_prediccion  = IF(fecha_prediccion  IS NULL, VALUES(fecha_prediccion),  fecha_prediccion)",
                [
                    ':pid'        => $planetaId,
                    ':cid_actual' => (int)$actual['clima_id'],
                    ':cid_prev'   => $climaId,
                ]
            );
        } else {
            // Crear fila nueva con clima actual aleatorio + predicción
            $climaActualId = self::sortearClimaId();
            if (!$climaActualId) $climaActualId = $climaId;

            self::db()->insert(
                "INSERT INTO `".$prefix."clima_planeta`
                    (planeta_id, clima_id, clima_previsto_id, fecha_asignacion, fecha_expiracion, fecha_prediccion)
                 VALUES (:pid, :cid_actual, :cid_prev, NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR), NOW())
                 ON DUPLICATE KEY UPDATE
                    clima_previsto_id = IF(clima_previsto_id IS NULL, VALUES(clima_previsto_id), clima_previsto_id),
                    fecha_prediccion  = IF(fecha_prediccion  IS NULL, VALUES(fecha_prediccion),  fecha_prediccion)",
                [
                    ':pid'        => $planetaId,
                    ':cid_actual' => $climaActualId,
                    ':cid_prev'   => $climaId,
                ]
            );
        }

        return $clima;
    }

    public static function aplicarPrediccion($planetaId)
    {
        $planetaId = (int)$planetaId;
        if ($planetaId <= 0) return null;

        $prefix = self::prefix();

        $row = self::db()->selectSingle(
            "SELECT cp.clima_previsto_id, c.activo
             FROM `".$prefix."clima_planeta` cp
             INNER JOIN `".$prefix."climas` c ON c.id = cp.clima_previsto_id
             WHERE cp.planeta_id = :pid
               AND cp.clima_previsto_id IS NOT NULL
             LIMIT 1",
            [':pid' => $planetaId]
        );

        if ($row && (int)$row['activo'] === 1) {
            return self::asignarClimaPlaneta($planetaId, (int)$row['clima_previsto_id']);
        }

        return self::asignarClimaPlaneta($planetaId);
    }

    /* ============================================================
     * FORZADO (ADMIN)
     * ============================================================ */

    public static function forzarClima($planetaId, $climaId, $adminId)
    {
        $clima = self::asignarClimaPlaneta($planetaId, $climaId);
        if (!$clima) return null;

        self::registrarLog(
            'forzado_admin',
            1,
            0,
            (int)$adminId,
            'Planeta '.$planetaId.' forzado a clima '.$climaId
        );

        return $clima;
    }

    /* ============================================================
     * VALIDACIÓN
     * ============================================================ */

    public static function validarFactores($factores)
    {
        foreach (['factor_ataque', 'factor_defensa', 'factor_bajas', 'factor_botin'] as $key) {
            if (!isset($factores[$key])) return false;
            $v = (float)$factores[$key];
            if ($v < self::FACTOR_MIN || $v > self::FACTOR_MAX) return false;
        }
        if ((float)$factores['factor_bajas'] > self::FACTOR_BAJAS_MAX) return false;
        return true;
    }

    /* ============================================================
     * FORMATO
     * ============================================================ */

    public static function fmtPct($factor)
    {
        $pct = (int)round(((float)$factor - 1.00) * 100);
        if ($pct > 0) return '+'.$pct.'%';
        if ($pct < 0) return $pct.'%';
        return '±0%';
    }

    /* ============================================================
     * ESTADÍSTICAS (ADMIN)
     * ============================================================ */

    public static function getEstadisticasGlobales()
    {
        $prefix = self::prefix();
        $rows = self::db()->select(
            "SELECT c.clave, COUNT(cp.planeta_id) AS total
             FROM `".$prefix."climas` c
             LEFT JOIN `".$prefix."clima_planeta` cp ON cp.clima_id = c.id
             GROUP BY c.clave
             ORDER BY total DESC"
        );

        $out = [];
        if (is_array($rows)) {
            foreach ($rows as $row) {
                $out[$row['clave']] = (int)$row['total'];
            }
        }
        return $out;
    }

    /* ============================================================
     * LOG
     * ============================================================ */

    public static function registrarLog($tipo, $afectados, $duracion, $adminId = null, $detalle = null)
    {
        $prefix = self::prefix();
        try {
            self::db()->insert(
                "INSERT INTO `".$prefix."clima_log`
                    (tipo, planetas_afectados, duracion_segundos, admin_id, detalle)
                 VALUES (:t, :a, :d, :adm, :det)",
                [
                    ':t'   => $tipo,
                    ':a'   => (int)$afectados,
                    ':d'   => (float)$duracion,
                    ':adm' => $adminId ? (int)$adminId : null,
                    ':det' => $detalle,
                ]
            );
            return true;
        } catch (Exception $e) {
            return false;
        }
    }

    /* ============================================================
     * LIMPIEZA
     * ============================================================ */

    public static function limpiarHuerfanos()
    {
        $prefix = self::prefix();

        $count = self::db()->selectSingle(
            "SELECT COUNT(*) AS c FROM `".$prefix."clima_planeta` cp
             LEFT JOIN `".$prefix."planets` p ON p.id = cp.planeta_id
             WHERE p.id IS NULL OR p.destruyed = 1"
        );
        $before = $count ? (int)$count['c'] : 0;

        if ($before > 0) {
            self::db()->delete(
                "DELETE cp FROM `".$prefix."clima_planeta` cp
                 LEFT JOIN `".$prefix."planets` p ON p.id = cp.planeta_id
                 WHERE p.id IS NULL OR p.destruyed = 1"
            );
        }

        return $before;
    }

    /* ============================================================
     * RESET CACHÉ (para tests)
     * ============================================================ */

    public static function resetCache()
    {
        self::$cachePlaneta       = [];
        self::$cacheCatalogo      = null;
        self::$cacheCatalogoPesos = null;
    }

    /* ============================================================
     * BUFF CLIMÁTICO (v1.2)
     * ============================================================ */

    /**
     * Convierte el tipo de buff a su ID numérico.
     * @return int 1=menor, 2=mayor, 3=dominio, 0=inválido
     */
    public static function getBuffIdFromType($type)
    {
        switch ((string)$type) {
            case 'estabilizador_menor': return self::BUFF_MENOR;
            case 'estabilizador_mayor': return self::BUFF_MAYOR;
            case 'dominio':             return self::BUFF_DOMINIO;
        }
        return 0;
    }

    /**
     * Convierte el ID numérico de buff a su clave.
     * @return string|null
     */
    public static function getTypeFromBuffId($buffId)
    {
        switch ((int)$buffId) {
            case self::BUFF_MENOR:   return 'estabilizador_menor';
            case self::BUFF_MAYOR:   return 'estabilizador_mayor';
            case self::BUFF_DOMINIO: return 'dominio';
        }
        return null;
    }

    /**
     * Devuelve información del buff por su ID (clave + nombre legible).
     * Sin emojis: los emojis viven en los .tpl.
     * @return array|null ['clave' => string, 'nombre' => string]
     */
    public static function getBuffInfo($buffId)
    {
        $map = [
            self::BUFF_MENOR   => ['clave' => 'estabilizador_menor', 'nombre' => 'Estabilizador Menor'],
            self::BUFF_MAYOR   => ['clave' => 'estabilizador_mayor', 'nombre' => 'Estabilizador Mayor'],
            self::BUFF_DOMINIO => ['clave' => 'dominio',             'nombre' => 'Dominio Climático'],
        ];
        $buffId = (int)$buffId;
        return isset($map[$buffId]) ? $map[$buffId] : null;
    }

    /**
     * Devuelve el buff activo del jugador o null si no tiene / ha expirado.
     *
     * @param int $userId
     * @return array|null [
     *   'buff_type'      => string,
     *   'buff_id'        => int,
     *   'activated_from' => string,
     *   'expires_at'     => int,
     *   'created_at'     => int,
     *   'segundos_restantes' => int,
     * ]
     */
    public static function getActiveBuff($userId)
    {
        $userId = (int)$userId;
        if ($userId <= 0) return null;

        $prefix = self::prefix();
        $now    = self::now();

        $row = self::db()->selectSingle(
            "SELECT buff_type, activated_from, expires_at, created_at
             FROM `".$prefix."users_clima_buff`
             WHERE user_id = :uid
               AND expires_at > :now
             LIMIT 1",
            [':uid' => $userId, ':now' => $now]
        );

        if (!$row) return null;

        $buffId = self::getBuffIdFromType($row['buff_type']);
        if ($buffId <= 0) return null;

        return [
            'buff_type'          => (string)$row['buff_type'],
            'buff_id'            => $buffId,
            'activated_from'     => (string)$row['activated_from'],
            'expires_at'         => (int)$row['expires_at'],
            'created_at'         => (int)$row['created_at'],
            'segundos_restantes' => max(0, (int)$row['expires_at'] - $now),
        ];
    }

    /**
     * Activa un buff para el jugador. Si ya tenía uno, lo reemplaza.
     *
     * @param int    $userId
     * @param string $buffType  'estabilizador_menor' | 'estabilizador_mayor' | 'dominio'
     * @param int    $duracionHoras  (default 24)
     * @param string $source    'expedition' | 'shop' | 'market' | 'admin' | 'unknown'
     * @return bool
     */
    public static function setActiveBuff($userId, $buffType, $duracionHoras = self::BUFF_DURACION_DEFAULT, $source = 'unknown')
    {
        $userId = (int)$userId;
        if ($userId <= 0) return false;

        if (self::getBuffIdFromType($buffType) <= 0) return false;

        $duracionHoras = (int)$duracionHoras;
        if ($duracionHoras <= 0) $duracionHoras = self::BUFF_DURACION_DEFAULT;
        if ($duracionHoras > 168) $duracionHoras = 168; // tope: 7 días

        $now     = self::now();
        $expires = $now + ($duracionHoras * 3600);
        $prefix  = self::prefix();

        try {
            self::db()->insert(
                "INSERT INTO `".$prefix."users_clima_buff`
                    (user_id, buff_type, activated_from, expires_at, created_at)
                 VALUES (:uid, :bt, :src, :exp, :now)
                 ON DUPLICATE KEY UPDATE
                    buff_type      = VALUES(buff_type),
                    activated_from = VALUES(activated_from),
                    expires_at     = VALUES(expires_at),
                    created_at     = VALUES(created_at)",
                [
                    ':uid' => $userId,
                    ':bt'  => $buffType,
                    ':src' => (string)$source,
                    ':exp' => $expires,
                    ':now' => $now,
                ]
            );
            return true;
        } catch (Exception $e) {
            return false;
        }
    }

    /**
     * Aplica el buff a los 4 factores del clima.
     * SOLO toca las PENALIZACIONES. Los bonus se quedan igual.
     * Dirección correcta por factor:
     *  - factor_ataque / factor_defensa / factor_botin: penalización es factor < 1.00.
     *  - factor_bajas: penalización es factor > 1.00 (más bajas), porque en el motor
     *    de combate los supervivientes se DIVIDEN por factor_bajas.
     *
     * @param array     $factores  ['factor_ataque'=>..., 'factor_defensa'=>..., 'factor_bajas'=>..., 'factor_botin'=>...]
     * @param array|int $buff      Puede ser el array de getActiveBuff() o un buff_id (int)
     * @return array Los 4 factores modificados
     */
    public static function applyBuff(array $factores, $buff)
    {
        // Extraer buff_id de lo que venga
        $buffId = 0;
        if (is_array($buff)) {
            $buffId = isset($buff['buff_id']) ? (int)$buff['buff_id'] : 0;
        } elseif (is_numeric($buff)) {
            $buffId = (int)$buff;
        }

        if ($buffId <= 0) return $factores;

        $keys = ['factor_ataque', 'factor_defensa', 'factor_bajas', 'factor_botin'];

        foreach ($keys as $key) {
            if (!isset($factores[$key])) continue;
            $f = (float)$factores[$key];

            if ($key === 'factor_bajas') {
                // ==================================================
                // BAJAS: dirección INVERTIDA respecto a los otros 3.
                // factor_bajas > 1.00 = MÁS bajas (penalización real)
                // factor_bajas < 1.00 = MENOS bajas (bonus, no se toca)
                // ==================================================
                if ($f <= 1.00) continue;

                switch ($buffId) {
                    case self::BUFF_MENOR:
                        // Reduce la penalización a la mitad (1.20 -> 1.10)
                        $factores[$key] = 1.00 + (($f - 1.00) * 0.5);
                        break;

                    case self::BUFF_MAYOR:
                        // Neutraliza: deja en 1.00
                        $factores[$key] = 1.00;
                        break;

                    case self::BUFF_DOMINIO:
                        // Convierte la penalización en bonus (1.20 -> 0.90)
                        $factores[$key] = 1.00 - (($f - 1.00) * 0.5);
                        break;
                }
            } else {
                // ==================================================
                // ATAQUE / DEFENSA / BOTÍN:
                // factor < 1.00 = penalización, factor >= 1.00 = bonus
                // ==================================================
                if ($f >= 1.00) continue;

                switch ($buffId) {
                    case self::BUFF_MENOR:
                        // Reduce la penalización a la mitad (0.80 -> 0.90)
                        $factores[$key] = 1.00 - ((1.00 - $f) * 0.5);
                        break;

                    case self::BUFF_MAYOR:
                        // Neutraliza: deja en 1.00
                        $factores[$key] = 1.00;
                        break;

                    case self::BUFF_DOMINIO:
                        // Convierte la penalización en bonus (0.80 -> 1.10)
                        $factores[$key] = 1.00 + ((1.00 - $f) * 0.5);
                        break;
                }
            }

            // Redondeo a 2 decimales (consistente con DECIMAL(4,2))
            $factores[$key] = round((float)$factores[$key], 2);
        }

        return $factores;
    }

    /**
     * Atajo: carga los factores de un clima y les aplica el buff.
     *
     * @param int $climaId
     * @param int|array $buff  buff_id (int) o array de getActiveBuff()
     * @return array
     */
    public static function getFactoresConBuff($climaId, $buff)
    {
        $factores = self::getFactoresPorClimaId($climaId);
        return self::applyBuff($factores, $buff);
    }

    /**
     * Borra los buffs caducados de la tabla. Para el cron.
     * @return int Número de buffs borrados
     */
    public static function removeExpiredBuffs()
    {
        $prefix = self::prefix();
        $now    = self::now();

        try {
            $count = self::db()->selectSingle(
                "SELECT COUNT(*) AS c FROM `".$prefix."users_clima_buff` WHERE expires_at <= :now",
                [':now' => $now]
            );
            $before = $count ? (int)$count['c'] : 0;

            if ($before > 0) {
                self::db()->delete(
                    "DELETE FROM `".$prefix."users_clima_buff` WHERE expires_at <= :now",
                    [':now' => $now]
                );
            }

            return $before;
        } catch (Exception $e) {
            return 0;
        }
    }

    /**
     * Cuenta los buffs activos (para el panel admin).
     * @return array ['total' => int, 'menor' => int, 'mayor' => int, 'dominio' => int]
     */
    public static function contarBuffActivos()
    {
        $prefix = self::prefix();
        $now    = self::now();

        $out = ['total' => 0, 'menor' => 0, 'mayor' => 0, 'dominio' => 0];

        try {
            $rows = self::db()->select(
                "SELECT buff_type, COUNT(*) AS total
                 FROM `".$prefix."users_clima_buff`
                 WHERE expires_at > :now
                 GROUP BY buff_type",
                [':now' => $now]
            );

            if (is_array($rows)) {
                foreach ($rows as $row) {
                    $t = (int)$row['total'];
                    $out['total'] += $t;
                    switch ((string)$row['buff_type']) {
                        case 'estabilizador_menor': $out['menor']   = $t; break;
                        case 'estabilizador_mayor': $out['mayor']   = $t; break;
                        case 'dominio':             $out['dominio'] = $t; break;
                    }
                }
            }
        } catch (Exception $e) {
            // tabla no existe -> devuelve ceros
        }

        return $out;
    }
}