<?php

/**
 * XNOVA3D (rama xnova3d) — ESCRITORIO 3D completo.
 *
 * El juego entero dentro de un app 3D:
 *   - Escenas 3D reales con las IMÁGENES DEL JUEGO (no gráficos por código):
 *       base    -> tu planeta (planeten/{img}.jpg) + edificios (gebaeude/{id}.gif)
 *       hangar  -> naves y defensas (gebaeude/{id}.gif)
 *       lab     -> investigaciones (gebaeude/{id}.gif)
 *       imperio -> tus planetas y lunas (planeten/{img}.jpg)
 *       flotas  -> flotas en vuelo (naves gebaeude/{id}.gif)
 *   - Dock de MÓDULOS: TODOS los módulos clásicos del juego abren dentro de
 *     la app 3D como paneles (iframe) — nada se queda sin pasar a 3D.
 *   - GALAXIA 3D: salta al visor de galaxia (page=galaxy&vista=3d).
 *
 * Datos: X3dService (misma BD que el cliente clásico).
 * Acciones: POST reales a las páginas clásicas (buildings / research /
 * shipyard) — el servidor aplica las reglas, el 3D solo muestra.
 */

class ShowX3dPage extends AbstractGamePage
{
	public static $requireModule = 0; // accesible desde cualquier cuenta

	public function show()
	{
		global $LNG, $PLANET;

	/**
	 * CARGA MODULAR: el núcleo (x3d/core.js) y UN ARCHIVO POR MÓDULO.
	 * Añadir un módulo nuevo = crear x3d/mimodulo.js que llame a
	 * X3D.registrar('mimodulo', {...}) y cargarlo aquí.
	 */
	$this->tplObj->loadscript('three.min.js');
	$this->tplObj->loadscript('OrbitControls.js');
	$this->tplObj->loadscript('x3d/core.js');
	$this->tplObj->loadscript('x3d/base.js');
	$this->tplObj->loadscript('x3d/hangar.js');
	$this->tplObj->loadscript('x3d/lab.js');
	$this->tplObj->loadscript('x3d/imperio.js');
	$this->tplObj->loadscript('x3d/flotas.js');

		$this->assign(array(
			'x3d'    => X3dService::esquinas(), // el tpl lo pasa con |json
			'dpath'  => X3dService::dpath(),
			'pgName' => 'xnova3d',
		));

		$this->display('page.x3d.tpl');
	}

	/** API JSON AJAX del escritorio 3D */
	public function fetch()
	{
		$modo = HTTP::_GP('modo', 'base');
		$permitidos = array('base', 'hangar', 'lab', 'imperio', 'flotas');
		if (!in_array($modo, $permitidos)) {
			$modo = 'base';
		}
		$this->sendJSON(X3dService::todo($modo));
	}
}
