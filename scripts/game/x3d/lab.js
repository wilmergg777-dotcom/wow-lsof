/**
 * XNOVA3D — MÓDULO INVESTIGACIÓN (laboratorio)
 * =============================================
 * Escena: pads de energía con las investigaciones REALES (gebaeude/{id}.gif)
 * + el laboratorio real (edificio 31).
 * Acciones reales: investigar / cancelar (POST a research).
 *
 * Este archivo SOLO toca la INVESTIGACIÓN.
 */
(function () {
	'use strict';
	var X = window.X3D;
	if (!X || !window.THREE) return;

	/* ---------- acciones propias del módulo ---------- */
	var misAcciones = {
		techMejorar: function (d) {
			X.toast('🔬 Orden enviada: <b>' + X.esc(d.nombre) + '</b>');
			X.postJuego('game.php?page=research', { cmd: 'insert', element: d.id }, function () { X.recargarEscena(); });
		},
		techCancelar: function () {
			X.toast('✋ Cancelando investigación…');
			X.postJuego('game.php?page=research', { cmd: 'cancel', element: 0 }, function () { X.recargarEscena(); });
		}
	};

	/* ---------- detalle de una investigación ---------- */
	function detalleTech(item) {
		var d = X.estado.datos;
		var esq = d.esquinas;
		var ocupado = d.cola && d.cola.length > 0;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + X.esc(item.img) + '" alt="" onerror="this.remove()">' + X.esc(item.nombre.toUpperCase()) + '</div>' +
			X.kv('Nivel actual', item.nivel) +
			X.costoHTML(item.costo, esq) +
			X.kv('Tiempo', X.segAHms(item.segundos)) +
			(item.comprable ? X.kv('Requisitos', 'Cumplidos', 'ok') : X.kv('Requisitos', 'Pendientes', 'mal')) +
			(d.enOtroPlaneta ? X.kv('⚠️ Laboratorio ocupado', 'Investigando en otro planeta', 'mal') : '') +
			'<div class="acciones">' +
			'<button class="btn-x pri" data-accion="techMejorar" data-id="' + item.id + '" data-nombre="' + X.esc(item.nombre) + '" ' + (ocupado ? 'disabled' : '') + '>🔬 Investigar ' + (item.nivel + 1) + '</button>' +
			(ocupado && d.cola[0] ? '<button class="btn-x" data-accion="techCancelar">✕ Cancelar actual</button>' : '') +
			'</div>' +
			'<p class="nota">La orden va al módulo clásico de investigación.</p>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- construcción de la escena ---------- */
	function construirLab(d) {
		var g = new THREE.Group();
		var techs = d.techs || [];
		var porFila = 8;
		for (var i = 0; i < techs.length; i++) {
			var t = techs[i];
			var fila = Math.floor(i / porFila);
			var col = i % porFila;
			var totalFila = Math.min(porFila, techs.length - fila * porFila);
			var x = (col - (totalFila - 1) / 2) * 3.2;
			var z = fila * 3.4 - (Math.ceil(techs.length / porFila) - 1) * 1.7;

			// pad de energía (aro, suelo de la escena)
			var pad = new THREE.Mesh(
				new THREE.TorusGeometry(1.15, 0.07, 10, 36),
				new THREE.MeshBasicMaterial({ color: t.comprable ? 0x00e0ff : 0x3b4a66, transparent: true, opacity: 0.8 })
			);
			pad.rotation.x = Math.PI / 2;
			pad.position.set(x, -0.55, z);
			g.add(pad);

			var sp = X.spriteElemento(t.img, 1.6);
			sp.position.set(x, 0.55, z);
			sp.userData = { tipo: 'tech', item: t };
			g.add(sp);
			X.estado.rayTargets.push(sp);

			var et = X.etiqueta(t.nombre + ' ' + t.nivel, t.comprable ? '#7dd3fc' : '#64748b', 0.52);
			et.position.set(x, 1.5, z);
			g.add(et);
		}

		// laboratorio central real (edificio 31 del juego)
		var centro = X.spriteElemento(X.DPATH + 'gebaeude/31.gif', 2.4);
		centro.position.set(0, 1.8, -(Math.ceil(techs.length / porFila)) * 3.4 - 1.5);
		g.add(centro);

		X.estado.grupo = g;
		X.escena.add(g);
		X.camara.position.set(0, 10, 15);
		X.controls.target.set(0, 0, 0);

		X.pintarCola(d.cola && d.cola.length ? d.cola.map(function (c) {
			return { nombre: c.nombre, nivel: c.nivel, img: c.img, restante: c.restante };
		}) : null, d.enOtroPlaneta ? 'Investigando en otro planeta' : 'Sin investigación en curso');
	}

	/* ---------- clic en la escena ---------- */
	function alClic(u) {
		if (u.tipo === 'tech') detalleTech(u.item);
	}

	X.registrar('lab', { construir: construirLab, alClic: alClic });
})();
