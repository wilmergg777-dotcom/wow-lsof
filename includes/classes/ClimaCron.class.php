<?php
/**
 * ============================================================
 * ClimaCron — Rotación y predicción diaria del clima
 * ============================================================
 * Contiene la lógica que se ejecutará desde los scripts de cron:
 *  - rotarTodos():     aplica clima_previsto_id o sortea nuevo clima
 *  - predecirTodos():  sortea clima para mañana (visible al jugador)
 *  - asignarFaltantes(): crea climas para planetas nuevos
 * ============================================================
 */

if (!defined('MODE')) die('Hacking attempt');

class ClimaCron
{
    const LOTE_SIZE = 500;

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

    /* ============================================================
     * ROTACIÓN DIARIA (03:00 UTC)
     * ============================================================ */

    public static function rotarTodos()
    {
        $inicio    = microtime(true);
        $afectados = 0;
        $errores   = 0;

        try {
            // 1. Limpiar huérfanos (planetas destruidos)
            ClimaEngine::limpiarHuerfanos();

            // 2. Obtener todos los planetas/lunas activos
            $prefix   = self::prefix();
            $planetas = self::db()->select(
                "SELECT id FROM `".$prefix."planets` WHERE destruyed = 0"
            );

            if (!is_array($planetas) || empty($planetas)) {
                $duracion = round(microtime(true) - $inicio, 2);
                ClimaEngine::registrarLog('rotacion', 0, $duracion, null, 'Sin planetas activos');
                return ['afectados' => 0, 'errores' => 0, 'duracion' => $duracion];
            }

            // 3. Procesar en lotes para no saturar la BD
            $lotes = array_chunk($planetas, self::LOTE_SIZE);
            foreach ($lotes as $lote) {
                foreach ($lote as $p) {
                    try {
                        ClimaEngine::aplicarPrediccion((int)$p['id']);
                        $afectados++;
                    } catch (Exception $e) {
                        $errores++;
                    }
                }
            }

            // 4. Registrar en el log
            $duracion = round(microtime(true) - $inicio, 2);
            ClimaEngine::registrarLog(
                'rotacion',
                $afectados,
                $duracion,
                null,
                'Rotación completa. Errores: '.$errores
            );

            return ['afectados' => $afectados, 'errores' => $errores, 'duracion' => $duracion];

        } catch (Exception $e) {
            $duracion = round(microtime(true) - $inicio, 2);
            ClimaEngine::registrarLog('rotacion', $afectados, $duracion, null, 'ERROR: '.$e->getMessage());
            return ['afectados' => $afectados, 'errores' => 1, 'duracion' => $duracion, 'error' => $e->getMessage()];
        }
    }

    /* ============================================================
     * PREDICCIÓN (21:00 UTC)
     * ============================================================ */

    public static function predecirTodos()
    {
        $inicio    = microtime(true);
        $afectados = 0;
        $errores   = 0;

        try {
            // Buscar solo los que no tengan predicción aún
            $prefix   = self::prefix();
            $planetas = self::db()->select(
                "SELECT cp.planeta_id
                 FROM `".$prefix."clima_planeta` cp
                 INNER JOIN `".$prefix."planets` p ON p.id = cp.planeta_id
                 WHERE p.destruyed = 0
                   AND cp.clima_previsto_id IS NULL"
            );

            if (!is_array($planetas) || empty($planetas)) {
                $duracion = round(microtime(true) - $inicio, 2);
                ClimaEngine::registrarLog('prediccion', 0, $duracion, null, 'Sin planetas para predecir');
                return ['afectados' => 0, 'errores' => 0, 'duracion' => $duracion];
            }

            // Procesar en lotes
            $lotes = array_chunk($planetas, self::LOTE_SIZE);
            foreach ($lotes as $lote) {
                foreach ($lote as $p) {
                    try {
                        ClimaEngine::predecirClimaPlaneta((int)$p['planeta_id']);
                        $afectados++;
                    } catch (Exception $e) {
                        $errores++;
                    }
                }
            }

            $duracion = round(microtime(true) - $inicio, 2);
            ClimaEngine::registrarLog(
                'prediccion',
                $afectados,
                $duracion,
                null,
                'Predicción completa. Errores: '.$errores
            );

            return ['afectados' => $afectados, 'errores' => $errores, 'duracion' => $duracion];

        } catch (Exception $e) {
            $duracion = round(microtime(true) - $inicio, 2);
            ClimaEngine::registrarLog('prediccion', $afectados, $duracion, null, 'ERROR: '.$e->getMessage());
            return ['afectados' => $afectados, 'errores' => 1, 'duracion' => $duracion, 'error' => $e->getMessage()];
        }
    }

    /* ============================================================
     * ASIGNAR FALTANTES (para planetas nuevos)
     * ============================================================ */

    public static function asignarFaltantes()
    {
        $prefix   = self::prefix();
        $planetas = self::db()->select(
            "SELECT p.id
             FROM `".$prefix."planets` p
             LEFT JOIN `".$prefix."clima_planeta` cp ON cp.planeta_id = p.id
             WHERE p.destruyed = 0
               AND cp.planeta_id IS NULL"
        );

        $total = 0;
        if (is_array($planetas)) {
            foreach ($planetas as $p) {
                try {
                    ClimaEngine::asignarClimaPlaneta((int)$p['id']);
                    $total++;
                } catch (Exception $e) {
                    // silencioso
                }
            }
        }
        return $total;
    }
}