/**
 * XNOVA3D — MÓDULO IMPERIO (todos tus mundos)
 * ============================================
 * Escena: tus planetas y lunas como esferas con sus TEXTURAS REALES
 * (planeten/{img}.jpg). Clic → resumen real y botón "Ir a este mundo"
 * (cambio de planeta por el Overview clásico).
 *
 * Este archivo SOLO toca el IMPERIO.
 */
(function () {
	'use strict';
	var X = window.X3D;
	if (!X || !window.THREE) return;

	/* ---------- acciones propias del módulo ---------- */
	var misAcciones = {
		imperioIr: function (d) { X.imperioIr(d.pid); }
	};

	/* ---------- detalle de un mundo ---------- */
	function detalleImperio(p) {
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + X.esc(p.imgUrl) + '" alt="" onerror="this.remove()">' + X.esc(p.nombre.toUpperCase()) + '</div>' +
			X.kv('Tipo', p.tipo === 3 ? '🌙 Luna' : '🪐 Planeta') +
			X.kv('Coordenadas', '[' + X.esc(p.coords) + ']') +
			X.kv('Diámetro', X.fmt(p.diametro) + ' km') +
			X.kv('Campos', p.campos.usados + ' / ' + p.campos.max) +
			X.kv('⛏️ Metal', X.fmtCorto(p.recursos.metal)) +
			X.kv('💎 Cristal', X.fmtCorto(p.recursos.cristal)) +
			X.kv('⛽ Deuterio', X.fmtCorto(p.recursos.deuterio)) +
			X.kv('Minas', 'M ' + p.minas.metal + ' · C ' + p.minas.cristal + ' · D ' + p.minas.deuterio) +
			X.kv('Hangar / Lab', p.minas.hangar + ' / ' + p.minas.laboratorio) +
			'<div class="acciones"><button class="btn-x pri" data-accion="imperioIr" data-pid="' + p.id + '">🛰 Ir a este mundo</button></div>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- construcción de la escena ---------- */
	function construirImperio(d) {
		var g = new THREE.Group();
		var lista = d.planetas || [];
		var sep = 5.4;
		var x0 = -((lista.length - 1) * sep) / 2;
		for (var i = 0; i < lista.length; i++) {
			var p = lista[i];
			var x = x0 + i * sep;
			var esLuna = p.tipo === 3;
			var m = new THREE.Mesh(
				new THREE.SphereGeometry(esLuna ? 0.9 : 2.0, 36, 24),
				new THREE.MeshStandardMaterial({ color: 0x3a4a66, roughness: 0.8 })
			);
			m.position.set(x, esLuna ? -0.6 : 0, 0);
			X.texturaReal(p.imgUrl, m, true);
			m.userData = { tipo: 'imperio', item: p };
			g.add(m);
			X.estado.rayTargets.push(m);

			var et = X.etiqueta(p.nombre + ' [' + p.coords + ']', esLuna ? '#a78bfa' : '#7dd3fc', esLuna ? 0.5 : 0.72);
			et.position.set(x, esLuna ? 0.9 : 2.6, 0);
			g.add(et);
		}
		if (!lista.length) {
			g.add(X.etiqueta('Sin planetas', '#64748b', 1.4));
		}
		X.estado.grupo = g;
		X.escena.add(g);
		X.camara.position.set(0, 12, Math.max(16, lista.length * 3.4));
		X.controls.target.set(0, 0, 0);
		X.pintarCola(null, 'Tus mundos: ' + lista.length + ' — clic en uno para verlo');
	}

	/* ---------- clic en la escena ---------- */
	function alClic(u) {
		if (u.tipo === 'imperio') detalleImperio(u.item);
	}

	X.registrar('imperio', { construir: construirImperio, alClic: alClic });
})();
