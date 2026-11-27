<?php

/**
 * XNOVA3D (rama xnova3d) — ROUTER del servicio del ESCRITORIO 3D.
 *
 * Cada módulo vive en su PROPIO archivo (includes/classes/x3d/):
 *   X3dCore.php    → helpers compartidos (dpath, imágenes, costos, esquinas)
 *   X3dBase.php    → BASE (edificios)
 *   X3dHangar.php  → NAVES y defensas
 *   X3dLab.php     → INVESTIGACIÓN
 *   X3dImperio.php → IMPERIO
 *   X3dFlotas.php  → FLOTAS en vuelo
 *
 * Este archivo solo ENRUTA: la página (game.php?page=x3d&mode=fetch&modo=...)
 * y la API (api/index.php?r=x3d&modo=...) llaman a X3dService::todo($modo)
 * y no necesitan cambios cuando corriges un módulo.
 *
 * TODO sale del MISMO juego: tablas reales, costos/tiempos con BuildFunctions
 * (los mismos cálculos que las páginas clásicas) e imágenes REALES del tema.
 */

require_once(__DIR__ . '/../class.BuildFunctions.php');
require_once(__DIR__ . '/../class.FleetFunctions.php');
require_once(__DIR__ . '/x3d/X3dCore.php');
require_once(__DIR__ . '/x3d/X3dBase.php');
require_once(__DIR__ . '/x3d/X3dHangar.php');
require_once(__DIR__ . '/x3d/X3dLab.php');
require_once(__DIR__ . '/x3d/X3dImperio.php');
require_once(__DIR__ . '/x3d/X3dFlotas.php');

class X3dService
{
	/** dpath real del tema (delega en el núcleo) */
	public static function dpath()
	{
		return X3dCore::dpath();
	}

	/** cabecera común (delega en el núcleo) */
	public static function esquinas()
	{
		return X3dCore::esquinas();
	}

	/** router del fetch / API: un módulo = una clase = un archivo */
	public static function todo($modo)
	{
		switch ($modo) {
			case 'hangar':  return X3dHangar::hangar();
			case 'lab':     return X3dLab::lab();
			case 'imperio': return X3dImperio::imperio();
			case 'flotas':  return X3dFlotas::flotas();
			default:        return X3dBase::base();
		}
	}
}
