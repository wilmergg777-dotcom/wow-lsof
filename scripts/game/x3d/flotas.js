/**
 * XNOVA3D — MÓDULO FLOTAS (flotas en vuelo)
 * ==========================================
 * Escena: tus flotas en vuelo con la IMAGEN REAL de su nave principal,
 * misiones y cuentas atrás reales de uni1_fleets.
 * Acción: abrir la gestión de flotas clásica como panel dentro del 3D.
 *
 * Este archivo SOLO toca las FLOTAS.
 */
(function () {
	'use strict';
	var X = window.X3D;
	if (!X || !window.THREE) return;

	/* ---------- acciones propias del módulo ---------- */
	var misAcciones = {
		abrirFlotas: function () { X.abrirPanel('game.php?page=fleetTable', '⚓ FLOTA'); }
	};

	/* ---------- detalle de una flota ---------- */
	function detalleFlota(f) {
		var html = '<div class="x3d_dt-titulo">' + (f.volviendo ? '↩ VOLVIENDO' : '→ EN VUELO') + ' · ' + X.esc(f.misionNombre.toUpperCase()) + '</div>' +
			X.kv('Origen', X.esc(f.origen)) +
			X.kv('Destino', X.esc(f.destino)) +
			X.kv(f.volviendo ? 'Regresa en' : 'Llega en', X.segAHms(f.volviendo ? f.regreso : f.llegada)) +
			X.kv('Naves totales', X.fmt(f.totalNaves));
		for (var i = 0; i < Math.min(f.naves.length, 8); i++) {
			var nv = f.naves[i];
			html += X.kv(X.esc(nv.nombre), '×' + X.fmt(nv.cantidad));
		}
		html += '<div class="acciones"><button class="btn-x pri" data-accion="abrirFlotas">⚓ Abrir gestión de flotas</button></div>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- construcción de la escena ---------- */
	function construirFlotas(d) {
		var g = new THREE.Group();
		var flotas = d.flotas || [];
		var n = flotas.length || 1;
		for (var i = 0; i < flotas.length; i++) {
			var f = flotas[i];
			var ang = (i / n) * Math.PI * 2;
			var x = Math.cos(ang) * 6.5, z = Math.sin(ang) * 6.5;
			var img = (f.naves && f.naves[0]) ? f.naves[0].img : X.DPATH + 'gebaeude/203.gif';
			var sp = X.spriteElemento(img, 1.7);
			sp.position.set(x, 0.7, z);
			sp.userData = { tipo: 'flota', item: f };
			g.add(sp);
			X.estado.rayTargets.push(sp);
			var et = X.etiqueta(f.misionNombre + (f.volviendo ? ' ↩' : ' →') + ' ' + f.destino, f.volviendo ? '#a78bfa' : '#7dd3fc', 0.55);
			et.position.set(x, 1.85, z);
			g.add(et);
		}
		if (!flotas.length) {
			g.add(X.etiqueta('No hay flotas en vuelo', '#64748b', 1.3));
		}

		// órbita guía
		var circ = [];
		for (var a = 0; a <= 96; a++) {
			var t = (a / 96) * Math.PI * 2;
			circ.push(new THREE.Vector3(Math.cos(t) * 6.5, 0.7, Math.sin(t) * 6.5));
		}
		g.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints(circ),
			new THREE.LineBasicMaterial({ color: 0x1e3a5f, transparent: true, opacity: 0.6 })));

		X.estado.grupo = g;
		X.escena.add(g);
		X.camara.position.set(0, 10, 14);
		X.controls.target.set(0, 0, 0);

		X.pintarCola(flotas.map(function (f) {
			return { nombre: f.misionNombre + ' → ' + f.destino, img: (f.naves && f.naves[0]) ? f.naves[0].img : '', restante: f.volviendo ? f.regreso : f.llegada };
		}), 'Slots: ' + (d.slots ? d.slots.usados + '/' + d.slots.max : '0') + ' — sin flotas en vuelo');
	}

	/* ---------- clic en la escena ---------- */
	function alClic(u) {
		if (u.tipo === 'flota') detalleFlota(u.item);
	}

	X.registrar('flotas', { construir: construirFlotas, alClic: alClic });
})();
