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
			var nave0 = (f.naves && f.naves[0]) ? f.naves[0] : null;
			// MODELO 3D REAL volando en órbita (portador nave + etiqueta)
			var portador = new THREE.Group();
			var nave = (X.modeloNave && nave0)
				? X.modeloNave(nave0.id, nave0.nombre, 0.95)
				: X.spriteElemento(nave0 ? nave0.img : X.DPATH + 'gebaeude/203.gif', 1.7);
			nave.rotation.y = Math.PI;
			portador.add(nave);
			var et = X.etiqueta(f.misionNombre + (f.volviendo ? ' ↩' : ' →') + ' ' + f.destino, f.volviendo ? '#a78bfa' : '#7dd3fc', 0.55);
			et.position.y = 1.5;
			portador.add(et);
			portador.userData = { tipo: 'flota', item: f };
			g.add(portador);
			X.estado.rayTargets.push(portador);
			var vuelo = { a0: (i / n) * Math.PI * 2, r: 6.5, y: 0.8, vel: (f.volviendo ? -0.2 : 0.3) + (i % 3) * 0.03, fase: i * 1.9 };
			portador.position.set(Math.cos(vuelo.a0) * vuelo.r, vuelo.y, Math.sin(vuelo.a0) * vuelo.r);
			X.alTick(function (portador, vuelo) {
				return function (dt, t) {
					var a = vuelo.a0 + t * vuelo.vel;
					var px = Math.cos(a) * vuelo.r, pz = Math.sin(a) * vuelo.r;
					var py = vuelo.y + Math.sin(t * 1.5 + vuelo.fase) * 0.15;
					portador.position.set(px, py, pz);
					portador.lookAt(Math.cos(a + 0.12 * (vuelo.vel > 0 ? 1 : -1)) * vuelo.r, py, Math.sin(a + 0.12 * (vuelo.vel > 0 ? 1 : -1)) * vuelo.r);
				};
			}(portador, vuelo));
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
