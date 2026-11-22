<?php
/**
 * WarClimatesHelper - Los 22 climas del sistema de Guerra WAR
 * AstroIO v1.0
 *
 * atk/def/bajas/botin son multiplicadores sobre el combate.
 */

if (!defined('MODE')) { die('Hacking attempt'); }

class WarClimatesHelper
{
    public static $CLIMATES = array(

        'niebla_densa' => array(
            'nombre' => 'Niebla Densisima', 'emoji' => '&#127787;',
            'atk' => 0.70, 'def' => 1.00, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 10,
            'descripcion' => 'Una niebla impenetrable envuelve el campo de batalla, los sensores apenas funcionan.',
        ),
        'tormenta_polvo' => array(
            'nombre' => 'Tormenta de Polvo Electrostatico', 'emoji' => '&#127786;',
            'atk' => 0.75, 'def' => 0.90, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 8,
            'descripcion' => 'Particulas cargadas oscurecen la vision y desestabilizan los escudos.',
        ),
        'lluvia_particulas' => array(
            'nombre' => 'Lluvia de Particulas Cargadas', 'emoji' => '&#127783;',
            'atk' => 0.80, 'def' => 1.00, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 7,
            'descripcion' => 'Una lluvia de iones distorsiona los sistemas de seguimiento.',
        ),
        'nube_gas' => array(
            'nombre' => 'Nube de Gas Ionizado', 'emoji' => '&#127756;',
            'atk' => 0.65, 'def' => 1.00, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 5,
            'descripcion' => 'El gas interestelar dispersa los disparos a larga distancia.',
        ),
        'tormenta_solar' => array(
            'nombre' => 'Tormenta Solar', 'emoji' => '&#9889;',
            'atk' => 1.00, 'def' => 0.70, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 10,
            'descripcion' => 'Oleadas de plasma solar desestabilizan los generadores de escudo.',
        ),
        'erupcion_estelar' => array(
            'nombre' => 'Erupcion Estelar', 'emoji' => '&#9728;',
            'atk' => 1.00, 'def' => 0.65, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 6,
            'descripcion' => 'La estrella expulsa una llamarada que debilita las defensas fijas.',
        ),
        'onda_gravitatoria' => array(
            'nombre' => 'Onda de Choque Gravitatoria', 'emoji' => '&#127754;',
            'atk' => 1.00, 'def' => 0.75, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 7,
            'descripcion' => 'Distorsiones gravitatorias abren brechas en los escudos.',
        ),
        'campo_magnetico' => array(
            'nombre' => 'Campo Magnetico Inestable', 'emoji' => '&#127744;',
            'atk' => 1.00, 'def' => 0.80, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 8,
            'descripcion' => 'Los campos magneticos erraticos desvian los proyectiles defensivos.',
        ),
        'lluvia_meteoros' => array(
            'nombre' => 'Lluvia de Meteoros', 'emoji' => '&#9732;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.30, 'botin' => 1.00, 'peso' => 8,
            'descripcion' => 'Meteoros cruzan el campo de batalla, sembrando caos entre ambas flotas.',
        ),
        'tormenta_fragmentos' => array(
            'nombre' => 'Tormenta de Fragmentos', 'emoji' => '&#127776;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.25, 'botin' => 1.00, 'peso' => 6,
            'descripcion' => 'Una nube de restos metalicos perfora cascos sin distincion.',
        ),
        'explosiones_nova' => array(
            'nombre' => 'Explosiones de Nova', 'emoji' => '&#128165;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.20, 'botin' => 1.00, 'peso' => 5,
            'descripcion' => 'La energia liberada por una estrella moribunda sacude la zona.',
        ),
        'viento_cosmico' => array(
            'nombre' => 'Viento Cosmico Extremo', 'emoji' => '&#127786;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.35, 'botin' => 1.00, 'peso' => 4,
            'descripcion' => 'Rafagas de viento estelar empujan las naves unas contra otras.',
        ),
        'nebulosa_mineral' => array(
            'nombre' => 'Nebulosa Rica en Minerales', 'emoji' => '&#128176;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.00, 'botin' => 1.50, 'peso' => 6,
            'descripcion' => 'La nebulosa esta llena de vetas de mineral, el botin es mas jugoso.',
        ),
        'vortice_energia' => array(
            'nombre' => 'Vortice de Energia', 'emoji' => '&#127744;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 4,
            'descripcion' => 'El vortice drena energia de las naves, necesitaras mas deuterio.',
        ),
        'campo_cristal' => array(
            'nombre' => 'Campo de Asteroides de Cristal', 'emoji' => '&#127775;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.00, 'botin' => 1.30, 'peso' => 5,
            'descripcion' => 'Los asteroides estan compuestos de cristal puro, facil de recolectar.',
        ),
        'campo_asteroides' => array(
            'nombre' => 'Campo de Asteroides Densos', 'emoji' => '&#127807;',
            'atk' => 0.85, 'def' => 1.20, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 8,
            'descripcion' => 'Los asteroides ofrecen refugio, pero dificultan los disparos.',
        ),
        'nube_plasma' => array(
            'nombre' => 'Nube de Plasma', 'emoji' => '&#127756;',
            'atk' => 1.20, 'def' => 0.80, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 7,
            'descripcion' => 'El plasma ionizado potencia los rayos, pero desgasta los escudos.',
        ),
        'eclipse_sol' => array(
            'nombre' => 'Eclipse de Sol', 'emoji' => '&#127763;',
            'atk' => 1.15, 'def' => 0.90, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 6,
            'descripcion' => 'La oscuridad permite maniobras furtivas, pero la defensa se resiente.',
        ),
        'lluvia_estrellas' => array(
            'nombre' => 'Lluvia de Estrellas Fugaces', 'emoji' => '&#127776;',
            'atk' => 1.10, 'def' => 0.90, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 7,
            'descripcion' => 'Un espectaculo celestial inspira a los atacantes, pero desconcentra a los defensores.',
        ),
        'agujero_gusano' => array(
            'nombre' => 'Agujero de Gusano Temporal', 'emoji' => '&#127744;',
            'atk' => 1.00, 'def' => 1.00, 'bajas' => 1.50, 'botin' => 1.00, 'peso' => 2,
            'descripcion' => 'Un agujero de gusano inestable transporta naves fuera de la batalla.',
        ),
        'singularidad' => array(
            'nombre' => 'Singularidad Cercana', 'emoji' => '&#9899;',
            'atk' => 0.50, 'def' => 0.50, 'bajas' => 2.00, 'botin' => 1.00, 'peso' => 1,
            'descripcion' => 'La cercania de un agujero negro afecta a todo, es un caos total.',
        ),
        'aurora_cosmica' => array(
            'nombre' => 'Aurora Cosmica', 'emoji' => '&#127752;',
            'atk' => 1.20, 'def' => 1.20, 'bajas' => 1.00, 'botin' => 1.00, 'peso' => 3,
            'descripcion' => 'La aurora permite una sincronizacion perfecta, todas las naves luchan mejor.',
        ),
    );

    /**
     * Devuelve un clima aleatorio con peso (weighted random).
     */
    public static function random()
    {
        $keys  = array_keys(self::$CLIMATES);
        $pesos = array();
        foreach (self::$CLIMATES as $c) {
            $pesos[] = $c['peso'];
        }
        $total = array_sum($pesos);
        $r     = mt_rand(1, $total);
        $acc   = 0;

        foreach ($keys as $i => $k) {
            $acc += $pesos[$i];
            if ($r <= $acc) return $k;
        }
        return $keys[0];
    }

    /**
     * Devuelve el nombre legible del clima.
     */
    public static function getName($key)
    {
        return isset(self::$CLIMATES[$key]['nombre'])
            ? self::$CLIMATES[$key]['nombre']
            : 'Desconocido';
    }

    /**
     * Devuelve la config completa del clima (con fallback seguro).
     */
    public static function get($key)
    {
        if (isset(self::$CLIMATES[$key])) {
            return self::$CLIMATES[$key];
        }
        return array(
            'nombre'      => 'Desconocido',
            'emoji'       => '?',
            'atk'         => 1.0,
            'def'         => 1.0,
            'bajas'       => 1.0,
            'botin'       => 1.0,
            'peso'        => 0,
            'descripcion' => '',
        );
    }

    /**
     * Devuelve todos los climas (para panel admin o debug).
     */
    public static function all()
    {
        return self::$CLIMATES;
    }
}