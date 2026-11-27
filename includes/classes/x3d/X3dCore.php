<?php

/**
 * XNOVA3D — NÚCLEO de servicios 3D (helpers compartidos).
 *
 * Aquí SOLO vive lo que todos los módulos usan:
 *   · dpath()        → ruta real del tema (imágenes del juego)
 *   · imgElemento()  → imagen real de un elemento (gebaeude/{id}.gif)
 *   · costos()       → reduce un precio de BuildFunctions a metal/cristal/deuterio
 *   · esquinas()     → cabecera común: planeta actual + recursos + usuario
 *
 * Los MÓDULOS viven en su propio archivo (misma carpeta):
 *   X3dBase.php    → BASE (edificios del planeta)
 *   X3dHangar.php  → NAVES y defensas
 *   X3dLab.php     → INVESTIGACIÓN
 *   X3dImperio.php → IMPERIO (planetas del jugador)
 *   X3dFlotas.php  → FLOTAS en vuelo
 *
 * Regla modular: para corregir un módulo toca SOLO su archivo.
 */

class X3dCore
{
	/** dpath real del tema (imágenes del juego) */
	public static function dpath()
	{
		global $THEME;
		return ($THEME && method_exists($THEME, 'getTheme')) ? $THEME->getTheme() : './styles/theme/gow/';
	}

	/** imagen real de un elemento (edificio / investigación / nave / defensa) */
	public static function imgElemento($id)
	{
		return self::dpath() . 'gebaeude/' . (int)$id . '.gif';
	}

	/** mapa de costos reducido a lo que el HUD muestra */
	public static function costos($precio)
	{
		global $resource;
		$out = array('metal' => 0, 'cristal' => 0, 'deuterio' => 0);
		if (isset($precio[$resource[901]])) $out['metal']    = (int)$precio[$resource[901]];
		if (isset($precio[$resource[902]])) $out['cristal']  = (int)$precio[$resource[902]];
		if (isset($precio[$resource[903]])) $out['deuterio'] = (int)$precio[$resource[903]];
		return $out;
	}

	/** cabecera común: planeta actual + recursos + usuario (los "recursos del HUD") */
	public static function esquinas()
	{
		global $PLANET, $USER;

		return array(
			'dpath' => self::dpath(),
			'usuario' => array(
				'nombre' => (string)$USER['username'],
				'dm'     => (int)$USER['darkmatter'],
			),
			'planeta' => array(
				'id'     => (int)$PLANET['id'],
				'nombre' => (string)$PLANET['name'],
				'tipo'   => (int)$PLANET['planet_type'],
				'coords' => (int)$PLANET['galaxy'] . ':' . (int)$PLANET['system'] . ':' . (int)$PLANET['planet'],
				'img'    => (string)$PLANET['image'],
				'imgUrl' => self::dpath() . 'planeten/' . $PLANET['image'] . '.jpg',
				'campos' => array('usados' => (int)$PLANET['field_current'], 'max' => (int)CalculateMaxPlanetFields($PLANET)),
			),
			'recursos' => array(
				'metal'    => array('val' => floor($PLANET['metal']),    'max' => (int)$PLANET['metal_max']),
				'cristal'  => array('val' => floor($PLANET['crystal']),  'max' => (int)$PLANET['crystal_max']),
				'deuterio' => array('val' => floor($PLANET['deuterium']), 'max' => (int)$PLANET['deuterium_max']),
			),
			'energia' => array(
				'usado' => (int)$PLANET['energy'],
				'max'   => (int)$PLANET['energy_max'],
			),
		);
	}
}
