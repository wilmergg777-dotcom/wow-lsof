<?php
/**
 * WarCombatHelper - Simulacion de combate del sistema de Guerra WAR
 * AstroIO v1.0
 *
 * Simula un combate entre dos alianzas (Atacante vs Defensor).
 * Aplica:
 *   - Clima aleatorio (WarClimatesHelper)
 *   - Bonuses del Banco de Alianza: ATAQUE y DEFENSA (AllianceBankHelper)
 *
 * Devuelve:
 *   - rondas (array con cada ronda)
 *   - resultado ('victoria_atacante' | 'victoria_defensor' | 'empate')
 *   - supervivientes de cada bando
 *   - bajas totales de cada bando
 *   - bonuses aplicados (para el informe)
 *
 * Notas del fork:
 *  - No usa calculateAttack.php (simulacion propia)
 *  - Usa los pesos de WarHelper::$PESOS_NAVES y $PESOS_DEFENSAS
 *  - Compatible con PHP 8.2
 */

if (!defined('MODE')) { die('Hacking attempt'); }

require_once 'includes/classes/WarHelper.class.php';
require_once 'includes/classes/WarClimatesHelper.class.php';
require_once 'includes/classes/AllianceBankHelper.class.php';

class WarCombatHelper
{
    // ============ CONFIGURACION ============
    const MAX_RONDAS = 10;

    // ============================================================
    // PUNTO DE ENTRADA
    // ============================================================

    /**
     * Simula un combate completo entre dos alianzas.
     *
     * @param array  $navesA   Naves del atacante    [columna => cantidad]
     * @param array  $defA     Defensas del atacante [columna => cantidad]
     * @param array  $navesD   Naves del defensor
     * @param array  $defD     Defensas del defensor
     * @param string $climaKey Key del clima (WarClimatesHelper)
     * @param int    $allyIdA  ID de la alianza atacante
     * @param int    $allyIdD  ID de la alianza defensora
     *
     * @return array
     */
    public static function simulate($navesA, $defA, $navesD, $defD, $climaKey, $allyIdA, $allyIdD)
    {
        // ------------------------------------------------------
        // 1) Cargar bonuses del BANCO DE ALIANZA
        // ------------------------------------------------------
        $bonusA = self::getBankBonuses($allyIdA);
        $bonusD = self::getBankBonuses($allyIdD);

        $atkBonusA = $bonusA['attack'];
        $defBonusA = $bonusA['defense'];
        $atkBonusD = $bonusD['attack'];
        $defBonusD = $bonusD['defense'];

        // Convertir porcentaje -> multiplicador (13 -> 1.13)
        $multAtkA = 1 + ($atkBonusA / 100);
        $multDefA = 1 + ($defBonusA / 100);
        $multAtkD = 1 + ($atkBonusD / 100);
        $multDefD = 1 + ($defBonusD / 100);

        // ------------------------------------------------------
        // 2) Cargar el clima (WarClimatesHelper)
        // ------------------------------------------------------
        $clima = WarClimatesHelper::get($climaKey);

        $climaAtk = isset($clima['atk'])   ? (float)$clima['atk']   : 1.0;
        $climaDef = isset($clima['def'])   ? (float)$clima['def']   : 1.0;
        $climaBajas = isset($clima['bajas']) ? (float)$clima['bajas'] : 1.0;

        // ------------------------------------------------------
        // 3) Limpiar unidades (quitar ceros)
        // ------------------------------------------------------
        $navesA = self::limpiar($navesA);
        $defA   = self::limpiar($defA);
        $navesD = self::limpiar($navesD);
        $defD   = self::limpiar($defD);

        // Guardar copia original para calcular bajas totales
        $origNavesA = $navesA;
        $origDefA   = $defA;
        $origNavesD = $navesD;
        $origDefD   = $defD;

        // ------------------------------------------------------
        // 4) Loop de rondas
        // ------------------------------------------------------
        $rondas = array();
        $resultado = 'empate';
        $ronda = 1;

        while ($ronda <= self::MAX_RONDAS) {

            // --- Poder de cada bando ---
            $poderA = self::calcularPoder(
                $navesA, $defA,
                $multAtkA * $climaAtk,
                $multDefA * $climaDef
            );

            $poderD = self::calcularPoder(
                $navesD, $defD,
                $multAtkD * $climaAtk,
                $multDefD * $climaDef
            );

            $totalA = self::totalUnidades($navesA, $defA);
            $totalD = self::totalUnidades($navesD, $defD);

            // --- Fin del combate ---
            if ($totalA <= 0 && $totalD <= 0) {
                $resultado = 'empate';
                break;
            }
            if ($totalA <= 0) { $resultado = 'victoria_defensor'; break; }
            if ($totalD <= 0) { $resultado = 'victoria_atacante'; break; }

            // --- Calcular bajas de la ronda ---
            $poderTotal = $poderA + $poderD;
            if ($poderTotal <= 0) { break; }

            // El que tiene MENOS poder pierde mas
            $diff = abs($poderA - $poderD) / $poderTotal;
            $perdidaPerdedor = 0.10 + ($diff * 0.50);   // 10% a 60%
            $perdidaGanador  = $perdidaPerdedor * 0.30; // 30% del perdedor

            // Aplicar factor de bajas por clima
            $perdidaPerdedor *= $climaBajas;
            $perdidaGanador  *= $climaBajas;

            if ($poderA > $poderD) {
                $bajasA = (int)round($perdidaGanador  * $totalA);
                $bajasD = (int)round($perdidaPerdedor * $totalD);
            } elseif ($poderD > $poderA) {
                $bajasA = (int)round($perdidaPerdedor * $totalA);
                $bajasD = (int)round($perdidaGanador  * $totalD);
            } else {
                // Empate de poder en la ronda -> bajas iguales
                $bajasA = (int)round(0.10 * $totalA * $climaBajas);
                $bajasD = (int)round(0.10 * $totalD * $climaBajas);
            }

            // No puede morir mas de lo que hay
            $bajasA = min($bajasA, $totalA);
            $bajasD = min($bajasD, $totalD);

            // Al menos 1 baja si hay poder enemigo
            if ($totalA > 0 && $bajasA === 0 && $poderD > 0) { $bajasA = 1; }
            if ($totalD > 0 && $bajasD === 0 && $poderA > 0) { $bajasD = 1; }

            // Distribuir bajas proporcionalmente
            $propA = $totalA > 0 ? ($bajasA / $totalA) : 0;
            $propD = $totalD > 0 ? ($bajasD / $totalD) : 0;

            $bajasANaves = self::distribuirBajas($navesA, $propA);
            $bajasADef   = self::distribuirBajas($defA,   $propA);
            $bajasDNaves = self::distribuirBajas($navesD, $propD);
            $bajasDDef   = self::distribuirBajas($defD,   $propD);

            // Registrar la ronda
            $rondas[] = array(
                'ronda'      => $ronda,
                'poderA'     => $poderA,
                'poderD'     => $poderD,
                'bajasA'     => array_merge($bajasANaves, $bajasADef),
                'bajasD'     => array_merge($bajasDNaves, $bajasDDef),
                'totalA'     => $totalA,
                'totalD'     => $totalD,
            );

            // Aplicar bajas
            $navesA = self::restarBajas($navesA, $bajasANaves);
            $defA   = self::restarBajas($defA,   $bajasADef);
            $navesD = self::restarBajas($navesD, $bajasDNaves);
            $defD   = self::restarBajas($defD,   $bajasDDef);

            // Ver si alguien se quedo sin nada
            $poderAFinal = self::calcularPoder($navesA, $defA, $multAtkA, $multDefA);
            $poderDFinal = self::calcularPoder($navesD, $defD, $multAtkD, $multDefD);

            if ($poderAFinal <= 0 && $poderDFinal <= 0) {
                $resultado = 'empate'; break;
            }
            if ($poderAFinal <= 0) { $resultado = 'victoria_defensor'; break; }
            if ($poderDFinal <= 0) { $resultado = 'victoria_atacante'; break; }

            $ronda++;
        }

        // ------------------------------------------------------
        // 5) Si llegamos al limite de rondas sin victoria clara
        // ------------------------------------------------------
        if ($ronda > self::MAX_RONDAS && $resultado === 'empate') {
            $poderAFinal = self::calcularPoder($navesA, $defA, $multAtkA, $multDefA);
            $poderDFinal = self::calcularPoder($navesD, $defD, $multAtkD, $multDefD);

            if ($poderAFinal > $poderDFinal)      $resultado = 'victoria_atacante';
            elseif ($poderDFinal > $poderAFinal)  $resultado = 'victoria_defensor';
            else                                  $resultado = 'empate';
        }

        // ------------------------------------------------------
        // 6) Calcular bajas totales
        // ------------------------------------------------------
        $bajasTotalesA = self::calcularBajasTotales($origNavesA, $origDefA, $navesA, $defA);
        $bajasTotalesD = self::calcularBajasTotales($origNavesD, $origDefD, $navesD, $defD);

        // ------------------------------------------------------
        // 7) Devolver resultado completo
        // ------------------------------------------------------
        return array(
            'rondas'              => $rondas,
            'resultado'           => $resultado,
            'rondas_totales'      => count($rondas),
            'supervivientesA'     => array_merge($navesA, $defA),
            'supervivientesD'     => array_merge($navesD, $defD),
            'bajas_totales_atacante' => $bajasTotalesA,
            'bajas_totales_defensor' => $bajasTotalesD,
            'clima_key'           => $climaKey,
            'clima_nombre'        => isset($clima['nombre']) ? $clima['nombre'] : '',
            'bonusAplicados'      => array(
                'atacante' => array(
                    'attack'  => $atkBonusA,
                    'defense' => $defBonusA,
                ),
                'defensor' => array(
                    'attack'  => $atkBonusD,
                    'defense' => $defBonusD,
                ),
            ),
        );
    }

    // ============================================================
    // HELPERS INTERNOS
    // ============================================================

    /**
     * Carga los bonuses activos del banco de una alianza.
     * Devuelve siempre array con 'attack' y 'defense' (0 si no hay).
     */
    private static function getBankBonuses($allyId)
    {
        $allyId = (int)$allyId;
        if ($allyId <= 0) {
            return array('attack' => 0, 'defense' => 0);
        }

        try {
            if (!class_exists('AllianceBankHelper')) {
                return array('attack' => 0, 'defense' => 0);
            }
            $bonus = AllianceBankHelper::getActiveBonuses($allyId);
            if (!is_array($bonus)) {
                return array('attack' => 0, 'defense' => 0);
            }
            return array(
                'attack'  => isset($bonus['attack'])  ? (int)$bonus['attack']  : 0,
                'defense' => isset($bonus['defense']) ? (int)$bonus['defense'] : 0,
            );
        } catch (Exception $e) {
            return array('attack' => 0, 'defense' => 0);
        }
    }

    /**
     * Calcula el poder total de un bando (naves + defensas).
     * Aplica multiplicador de ataque y defensa.
     */
    private static function calcularPoder($naves, $defensas, $multAtk, $multDef)
    {
        $poder = 0;

        // Naves (peso de WarHelper)
        foreach ($naves as $id => $cant) {
            $cant = (int)$cant;
            if ($cant <= 0) continue;
            $peso = isset(WarHelper::$PESOS_NAVES[$id]) ? WarHelper::$PESOS_NAVES[$id] : 0;
            $poder += $peso * $cant;
        }

        // Defensas (peso de WarHelper)
        foreach ($defensas as $id => $cant) {
            $cant = (int)$cant;
            if ($cant <= 0) continue;
            $peso = isset(WarHelper::$PESOS_DEFENSAS[$id]) ? WarHelper::$PESOS_DEFENSAS[$id] : 0;
            $poder += $peso * $cant;
        }

        // Aplicar multiplicadores (ataque + defensa promediados)
        $multTotal = ($multAtk + $multDef) / 2;
        $poder = (int)round($poder * $multTotal);

        return $poder;
    }

    /**
     * Cuenta el total de unidades (naves + defensas).
     */
    private static function totalUnidades($naves, $defensas)
    {
        $total = 0;
        foreach ($naves as $c)    { $total += (int)$c; }
        foreach ($defensas as $c) { $total += (int)$c; }
        return $total;
    }

    /**
     * Limpia el array (quita ceros).
     */
    private static function limpiar($arr)
    {
        if (!is_array($arr)) return array();
        $out = array();
        foreach ($arr as $k => $v) {
            $v = (int)$v;
            if ($v > 0) $out[$k] = $v;
        }
        return $out;
    }

    /**
     * Distribuye bajas proporcionalmente entre las unidades.
     * Devuelve [unidad => cantidad_perdida].
     */
    private static function distribuirBajas($unidades, $proporcion)
    {
        $bajas = array();
        if (!is_array($unidades) || $proporcion <= 0) {
            return $bajas;
        }

        foreach ($unidades as $id => $cant) {
            $cant = (int)$cant;
            if ($cant <= 0) continue;

            $perdidas = (int)round($cant * $proporcion);
            if ($perdidas > 0) {
                $bajas[$id] = min($perdidas, $cant);
            }
        }

        // Garantizar al menos 1 baja si la proporcion > 0 y hay unidades
        $totalBajas = array_sum($bajas);
        if ($totalBajas === 0 && $proporcion > 0) {
            foreach ($unidades as $id => $cant) {
                if ((int)$cant > 0) {
                    $bajas[$id] = 1;
                    break;
                }
            }
        }

        return $bajas;
    }

    /**
     * Resta las bajas a las unidades.
     */
    private static function restarBajas($unidades, $bajas)
    {
        if (!is_array($unidades)) return array();
        foreach ($bajas as $id => $cant) {
            if (isset($unidades[$id])) {
                $unidades[$id] = max(0, (int)$unidades[$id] - (int)$cant);
                if ($unidades[$id] === 0) {
                    unset($unidades[$id]);
                }
            }
        }
        return $unidades;
    }

    /**
     * Calcula las bajas totales comparando origen vs supervivientes.
     */
    private static function calcularBajasTotales($origNaves, $origDef, $naves, $def)
    {
        $bajas = array();

        foreach ($origNaves as $id => $cant) {
            $final = isset($naves[$id]) ? (int)$naves[$id] : 0;
            $perdidas = (int)$cant - $final;
            if ($perdidas > 0) {
                $bajas[$id] = $perdidas;
            }
        }
        foreach ($origDef as $id => $cant) {
            $final = isset($def[$id]) ? (int)$def[$id] : 0;
            $perdidas = (int)$cant - $final;
            if ($perdidas > 0) {
                $bajas[$id] = $perdidas;
            }
        }

        return $bajas;
    }
}