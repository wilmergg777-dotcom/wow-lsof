<?php
/**
 * WeekendBoostHelper.class.php
 * -------------------------------------------------------------------
 * AstroIO 2026 - Boost Automático de Fin de Semana (v3 CORREGIDO)
 * -------------------------------------------------------------------
 * Cambios v2:
 *   - Usa INFORMATION_SCHEMA.COLUMNS (no SHOW COLUMNS)
 *   - Nombres REALES de columnas: game_speed, fleet_speed,
 *     resource_multiplier, storage_multiplier, halt_speed, energySpeed
 *   - Respeta la conversión ×2500 de game_speed y fleet_speed
 *   - Mapeo confirmado con ShowConfigUniPage.php / ConfigBodyUni.tpl
 *
 * Cambios v3 (FIX CRÍTICO):
 *   - ✅ FIX bug de DESACTIVACIÓN AUTOMÁTICA
 *   - El sistema ya NO se queda atascado cuando se desactiva desde el panel
 *   - Detecta el "estado zombie": enabled=0 PERO is_weekend_active=1
 *   - Cuando eso ocurre, revierte las velocidades a NORMAL automáticamente
 *   - Antes: `if (!$c['enabled'] && !$force) return false;` cortaba antes
 *     de revertir → el cron nunca desactivaba → había que forzar manual
 *   - Ahora: si enabled=0 pero quedó en weekend, se revierte solo
 * -------------------------------------------------------------------
 */

if (!defined('INSIDE') && !defined('MODE')) {
    die('Hacking attempt');
}

class WeekendBoostHelper
{
    // ═══════════════════════════════════════════════════════════════
    // MAPEO: nombre_lógico => [columna_real, factor_conversion]
    //
    // factor_conversion:
    //   1    → valor directo (se guarda tal cual)
    //   2500 → valor × 2500 (como en game_speed y fleet_speed)
    // ═══════════════════════════════════════════════════════════════
    const CFG_COLUMNS = [
        'game_speed'        => ['col' => 'game_speed',           'factor' => 2500],
        'fleet_speed'       => ['col' => 'fleet_speed',          'factor' => 2500],
        'production_speed'  => ['col' => 'resource_multiplier',  'factor' => 1],
        'storage_speed'     => ['col' => 'storage_multiplier',   'factor' => 1],
        'expedition_factor' => ['col' => 'halt_speed',           'factor' => 1],
        'energy_factor'     => ['col' => 'energySpeed',          'factor' => 1],
    ];

    // Nombres amigables para el panel admin
    const LABELS = [
        'game_speed'        => 'Velocidad general',
        'fleet_speed'       => 'Velocidad de las flotas',
        'production_speed'  => 'Velocidad de producción',
        'storage_speed'     => 'se_storage_producion_speed',
        'expedition_factor' => 'Factor-Expedición',
        'energy_factor'     => 'Factor-Energía',
    ];

    // Cache en memoria
    private static $configCache  = null;
    private static $columnsCache = null;

    // ═══════════════════════════════════════════════════════════════
    // Atajos
    // ═══════════════════════════════════════════════════════════════
    private static function db()
    {
        return Database::get();
    }

    private static function now()
    {
        return defined('TIMESTAMP') ? TIMESTAMP : time();
    }

    // ═══════════════════════════════════════════════════════════════
    // CONFIG
    // ═══════════════════════════════════════════════════════════════
    public static function getConfig($forceReload = false)
    {
        if (self::$configCache !== null && !$forceReload) {
            return self::$configCache;
        }
        $row = self::db()->selectSingle(
            "SELECT * FROM %%WEEKEND_BOOST%% WHERE id = 1"
        );
        self::$configCache = $row;
        return $row;
    }

    public static function saveConfig(array $d)
    {
        self::db()->update(
            "UPDATE %%WEEKEND_BOOST%% SET
                enabled                   = :enabled,
                start_day                 = :sd,
                start_hour                = :sh,
                end_day                   = :ed,
                end_hour                  = :eh,
                normal_game_speed         = :n_game,
                normal_fleet_speed        = :n_fleet,
                normal_production_speed   = :n_prod,
                normal_storage_speed      = :n_storage,
                normal_expedition_factor  = :n_exp,
                normal_energy_factor      = :n_energy,
                weekend_game_speed        = :w_game,
                weekend_fleet_speed       = :w_fleet,
                weekend_production_speed  = :w_prod,
                weekend_storage_speed     = :w_storage,
                weekend_expedition_factor = :w_exp,
                weekend_energy_factor     = :w_energy
             WHERE id = 1",
            [
                ':enabled'   => isset($d['enabled']) ? (int) $d['enabled'] : 0,
                ':sd'        => (int)   $d['start_day'],
                ':sh'        => (int)   $d['start_hour'],
                ':ed'        => (int)   $d['end_day'],
                ':eh'        => (int)   $d['end_hour'],
                ':n_game'    => (float) $d['normal_game_speed'],
                ':n_fleet'   => (float) $d['normal_fleet_speed'],
                ':n_prod'    => (float) $d['normal_production_speed'],
                ':n_storage' => (float) $d['normal_storage_speed'],
                ':n_exp'     => (float) $d['normal_expedition_factor'],
                ':n_energy'  => (float) $d['normal_energy_factor'],
                ':w_game'    => (float) $d['weekend_game_speed'],
                ':w_fleet'   => (float) $d['weekend_fleet_speed'],
                ':w_prod'    => (float) $d['weekend_production_speed'],
                ':w_storage' => (float) $d['weekend_storage_speed'],
                ':w_exp'     => (float) $d['weekend_expedition_factor'],
                ':w_energy'  => (float) $d['weekend_energy_factor'],
            ]
        );
        self::$configCache = null;
    }

    // ═══════════════════════════════════════════════════════════════
    // DETECCIÓN DE FIN DE SEMANA
    // ═══════════════════════════════════════════════════════════════
    public static function isWeekendNow($c = null)
    {
        if ($c === null) $c = self::getConfig();
        if (empty($c) || !$c['enabled']) return false;

        $now  = self::now();
        $day  = (int) date('w', $now);
        $hour = (int) date('G', $now);

        $sd = (int) $c['start_day'];
        $sh = (int) $c['start_hour'];
        $ed = (int) $c['end_day'];
        $eh = (int) $c['end_hour'];

        if ($sd <= $ed) {
            if ($day < $sd || $day > $ed)    return false;
            if ($day === $sd && $hour < $sh) return false;
            if ($day === $ed && $hour > $eh) return false;
            return true;
        }
        if ($day >= $sd || $day <= $ed) {
            if ($day === $sd && $hour < $sh) return false;
            if ($day === $ed && $hour > $eh) return false;
            return true;
        }
        return false;
    }

    public static function getNextChangeTime($c = null)
    {
        if ($c === null) $c = self::getConfig();
        if (empty($c) || !$c['enabled']) return 0;

        $now    = self::now();
        $active = self::isWeekendNow($c);
        $targetDay  = $active ? (int) $c['end_day']   : (int) $c['start_day'];
        $targetHour = $active ? (int) $c['end_hour']  : (int) $c['start_hour'];

        for ($i = 0; $i <= 7; $i++) {
            $ts = strtotime("+$i days", $now);
            if ((int) date('w', $ts) === $targetDay) {
                return strtotime(date('Y-m-d', $ts) . sprintf(' %02d:00:00', $targetHour));
            }
        }
        return 0;
    }

    public static function getNextChangeAction($c = null)
    {
        if ($c === null) $c = self::getConfig();
        return self::isWeekendNow($c) ? 'deactivate' : 'activate';
    }

    // ═══════════════════════════════════════════════════════════════
    // APLICACIÓN
    // ═══════════════════════════════════════════════════════════════
    public static function checkAndApply($force = false)
    {
        $c = self::getConfig(true);
        if (empty($c)) return false;

        $db = self::db();

        $db->update(
            "UPDATE %%WEEKEND_BOOST%% SET last_check = :t WHERE id = 1",
            [':t' => self::now()]
        );

        // ───────────────────────────────────────────────────────────
        // ✅ FIX v3: Lógica de desactivación automática
        // ───────────────────────────────────────────────────────────
        // Antes:
        //   if (!$c['enabled'] && !$force) return false;
        //   → Cortaba antes de revertir si estaba desactivado
        //   → Bug: el sistema se quedaba atascado en weekend
        //
        // Ahora:
        //   1. Si enabled=0 y ya está en normal → no hay nada que hacer
        //   2. Si enabled=0 y quedó en weekend (zombie) → revertir
        //   3. Si enabled=1 → lógica normal (activar/desactivar por fecha)
        // ───────────────────────────────────────────────────────────
        $isEnabled = ((int) $c['enabled'] === 1);
        $current   = (int) $c['is_weekend_active'];

        if (!$isEnabled) {
            // Sistema DESACTIVADO
            if ($current === 0 && !$force) {
                // Ya está en normal → no hay nada que hacer
                return false;
            }
            // Quedó en weekend (zombie) o se forzó → aplicar NORMAL
            $should = 0;
        } else {
            // Sistema ACTIVO → lógica normal
            $should = self::isWeekendNow($c) ? 1 : 0;

            if ($should === $current && !$force) {
                // No cambió el estado → no hay nada que hacer
                return false;
            }
        }

        $src = $should ? 'weekend' : 'normal';

        $realCols = self::getRealColumns();
        if (empty($realCols)) {
            self::log("ERROR: no se pudieron leer columnas de uni1_config");
            return false;
        }

        $map    = self::CFG_COLUMNS;
        $setSql = [];
        $params = [];

        foreach ($map as $logicalKey => $info) {
            $realCol = $info['col'];
            $factor  = $info['factor'];

            if (!in_array($realCol, $realCols, true)) {
                self::log("WARN: columna '$realCol' no existe en uni1_config, ignorada");
                continue;
            }

            $logicalValue = $c["{$src}_$logicalKey"];
            $dbValue      = $logicalValue * $factor;

            $setSql[]                 = "`$realCol` = :$logicalKey";
            $params[":$logicalKey"]   = $dbValue;
        }

        if (empty($setSql)) {
            self::log("ERROR: ninguna columna válida para actualizar");
            return false;
        }

        $sql = "UPDATE %%CONFIG%% SET " . implode(', ', $setSql) . " WHERE uni = 1";

        try {
            $db->update($sql, $params);
        } catch (Exception $e) {
            self::log("ERROR SQL: " . $e->getMessage());
            return false;
        }

        $db->update(
            "UPDATE %%WEEKEND_BOOST%% 
             SET is_weekend_active = :a, last_change = :t 
             WHERE id = 1",
            [':a' => $should, ':t' => self::now()]
        );

        self::log("Cambio a " . ($should ? 'FIN DE SEMANA' : 'NORMAL') 
                 . " | game={$c["{$src}_game_speed"]} fleet={$c["{$src}_fleet_speed"]}"
                 . " | enabled=" . (int) $c['enabled']
                 . " | zombie_revert=" . (!$isEnabled && $current === 1 ? 'SI' : 'NO'));

        self::$configCache = null;
        return true;
    }

    public static function forceState($target)
    {
        $c = self::getConfig(true);
        if (empty($c)) return false;

        $target   = $target ? 1 : 0;
        $src      = $target ? 'weekend' : 'normal';
        $realCols = self::getRealColumns();
        if (empty($realCols)) return false;

        $map    = self::CFG_COLUMNS;
        $setSql = [];
        $params = [];

        foreach ($map as $logicalKey => $info) {
            $realCol = $info['col'];
            $factor  = $info['factor'];
            if (!in_array($realCol, $realCols, true)) continue;

            $logicalValue = $c["{$src}_$logicalKey"];
            $dbValue      = $logicalValue * $factor;

            $setSql[]               = "`$realCol` = :$logicalKey";
            $params[":$logicalKey"] = $dbValue;
        }

        if (empty($setSql)) return false;

        try {
            self::db()->update(
                "UPDATE %%CONFIG%% SET " . implode(', ', $setSql) . " WHERE uni = 1",
                $params
            );
            self::db()->update(
                "UPDATE %%WEEKEND_BOOST%% 
                 SET is_weekend_active = :a, last_change = :t 
                 WHERE id = 1",
                [':a' => $target, ':t' => self::now()]
            );
        } catch (Exception $e) {
            self::log("ERROR forceState: " . $e->getMessage());
            return false;
        }

        self::log("FORZADO manual a " . ($target ? 'FIN DE SEMANA' : 'NORMAL'));
        self::$configCache = null;
        return true;
    }

    // ═══════════════════════════════════════════════════════════════
    // LECTURA DE VALORES ACTUALES
    // ═══════════════════════════════════════════════════════════════
    public static function getCurrentConfigValues()
    {
        $realCols = self::getRealColumns();
        if (empty($realCols)) return [];

        $map  = self::CFG_COLUMNS;
        $cols = [];

        foreach ($map as $info) {
            if (in_array($info['col'], $realCols, true)) {
                $cols[] = "`{$info['col']}`";
            }
        }

        if (empty($cols)) return [];

        $row = self::db()->selectSingle(
            "SELECT " . implode(', ', $cols) . " FROM %%CONFIG%% WHERE uni = 1"
        );
        return $row ?: [];
    }

    /**
     * Devuelve la lista REAL de columnas de uni1_config
     * ✅ USA INFORMATION_SCHEMA (NO SHOW COLUMNS, que no sustituye %%CONFIG%%)
     */
    public static function getRealColumns()
    {
        if (self::$columnsCache !== null) {
            return self::$columnsCache;
        }

        try {
            // Detectar el nombre de la BD activa
            $dbName = self::db()->selectSingle("SELECT DATABASE() AS db");
            $dbName = isset($dbName['db']) ? $dbName['db'] : 'xnova_nuevo1';

            $rows = self::db()->select(
                "SELECT COLUMN_NAME 
                 FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE TABLE_SCHEMA = :dbname 
                   AND TABLE_NAME = :tablename",
                [
                    ':dbname'    => $dbName,
                    ':tablename' => 'uni1_config',
                ]
            );
        } catch (Exception $e) {
            self::log("ERROR INFORMATION_SCHEMA: " . $e->getMessage());
            return [];
        }

        $cols = [];
        foreach ($rows as $r) {
            if (isset($r['COLUMN_NAME'])) $cols[] = $r['COLUMN_NAME'];
        }

        self::$columnsCache = $cols;
        return $cols;
    }

    // ═══════════════════════════════════════════════════════════════
    // DIAGNÓSTICO
    // ═══════════════════════════════════════════════════════════════
    public static function diagnose()
    {
        $realCols = self::getRealColumns();
        $map      = self::CFG_COLUMNS;
        $actuales = self::getCurrentConfigValues();
        $now      = self::now();

        $result = [
            'now'           => $now,
            'now_formatted' => date('Y-m-d H:i:s', $now),
            'day_of_week'   => (int) date('w', $now),
            'day_name'      => self::dayName((int) date('w', $now)),
            'hour'          => (int) date('G', $now),
            'timezone'      => date_default_timezone_get(),
            'columns'       => [],
        ];

        foreach ($map as $logicalKey => $info) {
            $realCol = $info['col'];
            $exists  = in_array($realCol, $realCols, true);
            $result['columns'][] = [
                'logical'       => $logicalKey,
                'real'          => $realCol,
                'label'         => isset(self::LABELS[$logicalKey]) ? self::LABELS[$logicalKey] : $logicalKey,
                'exists'        => $exists,
                'current_value' => $exists && isset($actuales[$realCol]) ? $actuales[$realCol] : null,
                'factor'        => $info['factor'],
            ];
        }

        return $result;
    }

    // ═══════════════════════════════════════════════════════════════
    // UTILIDADES
    // ═══════════════════════════════════════════════════════════════
    public static function dayName($d)
    {
        $names = [0=>'Domingo', 1=>'Lunes', 2=>'Martes', 3=>'Miércoles',
                  4=>'Jueves', 5=>'Viernes', 6=>'Sábado'];
        return isset($names[$d]) ? $names[$d] : '?';
    }

    public static function dayNameShort($d)
    {
        $names = [0=>'Dom', 1=>'Lun', 2=>'Mar', 3=>'Mié', 4=>'Jue', 5=>'Vie', 6=>'Sáb'];
        return isset($names[$d]) ? $names[$d] : '?';
    }

    private static function log($msg)
    {
        try {
            $file = ROOT_PATH . 'includes/weekend_boost.log';
            @file_put_contents(
                $file,
                '[' . date('Y-m-d H:i:s') . '] ' . $msg . PHP_EOL,
                FILE_APPEND
            );
        } catch (Exception $e) {}
    }
}