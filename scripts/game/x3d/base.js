/**
 * XNOVA3D — MÓDULO BASE (edificios del planeta)
 * ==============================================
 * Escena: tu planeta con su IMAGEN REAL (planeten/{img}.jpg) + los
 * edificios reales (gebaeude/{id}.gif) en anillos con pedestales.
 * Acciones reales: mejorar / demoler / cancelar (POST a buildings).
 *
 * Este archivo SOLO toca la BASE. Para corregir otro módulo,
 * edita su propio archivo (x3d/hangar.js, x3d/lab.js, ...).
 */
(function () {
	'use strict';
	var X = window.X3D;
	if (!X || !window.THREE) return;

	/* ---------- acciones propias del módulo ---------- */
	var misAcciones = {
		edificioMejorar: function (d) {
			X.toast('🏗️ Orden enviada: <b>' + X.esc(d.nombre) + '</b>');
			X.postJuego('game.php?page=buildings', { cmd: 'insert', building: d.id }, function () { X.recargarEscena(); });
		},
		edificioDestruir: function (d) {
			X.toast('💥 Orden enviada: demoler <b>' + X.esc(d.nombre) + '</b>');
			X.postJuego('game.php?page=buildings', { cmd: 'destroy', building: d.id }, function () { X.recargarEscena(); });
		},
		edificioCancelar: function () {
			X.toast('✋ Cancelando la orden de construcción…');
			X.postJuego('game.php?page=buildings', { cmd: 'cancel', building: 0 }, function () { X.recargarEscena(); });
		},
		imperioIr: function (d) { X.imperioIr(d.pid); }
	};

	/* ---------- detalle de un edificio ---------- */
	function detalleBase(item) {
		var esq = X.estado.datos.esquinas;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + X.esc(item.img) + '" alt="" onerror="this.remove()">' + X.esc(item.nombre.toUpperCase()) + '</div>' +
			X.kv('Nivel actual', item.nivel) +
			X.costoHTML(item.costo, esq) +
			X.kv('Tiempo', X.segAHms(item.segundos)) +
			(item.comprable ? X.kv('Recursos', 'Suficientes', 'ok') : X.kv('Recursos', 'Insuficientes', 'mal')) +
			'<div class="acciones">' +
			'<button class="btn-x pri" data-accion="edificioMejorar" data-id="' + item.id + '" data-nombre="' + X.esc(item.nombre) + '">🏗️ Mejorar a ' + (item.nivel + 1) + '</button>' +
			(item.destruible ? '<button class="btn-x" data-accion="edificioDestruir" data-id="' + item.id + '" data-nombre="' + X.esc(item.nombre) + '">💥 Demoler</button>' : '') +
			'</div>' +
			'<div class="kv" style="margin-top:8px"><span>Demoler devuelve</span><b style="color:#64748b">' + X.fmtCorto(item.destruirCosto.metal) + ' M · ' + X.fmtCorto(item.destruirCosto.cristal) + ' C · ' + X.fmtCorto(item.destruirCosto.deuterio) + ' D</b></div>' +
			'<p class="nota">La orden se envía al módulo clásico de edificios: el servidor aplica las reglas reales del juego.</p>';
		X.pintarDetalle(html, misAcciones);
	}

	function detallePlanetaBase() {
		var p = X.estado.datos.esquinas.planeta;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + X.DPATH + 'planeten/small/s_' + X.esc(p.img) + '.jpg" alt="" onerror="this.remove()">TU PLANETA</div>' +
			X.kv('Nombre', X.esc(p.nombre)) +
			X.kv('Coordenadas', '[' + X.esc(p.coords) + ']') +
			X.kv('Campos ocupados', p.campos.usados + ' / ' + p.campos.max) +
			'<div class="acciones"><button class="btn-x" data-accion="imperioIr" data-pid="' + p.id + '">🛰 Ver en el Imperio</button></div>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- construcción de la escena ---------- */
	function construirBase(d) {
		var g = new THREE.Group();
		var p = d.esquinas.planeta;

		// planeta con la IMAGEN REAL del juego
		var planeta = new THREE.Mesh(
			new THREE.SphereGeometry(2.6, 48, 32),
			new THREE.MeshStandardMaterial({ color: 0x3a4a66, roughness: 0.8 })
		);
		X.texturaReal(p.imgUrl, planeta, true);
		g.add(planeta);
		X.estado.rayTargets.push(planeta);
		planeta.userData = { tipo: 'planetaBase' };

		// atmósfera sutil (carcasa)
		var atm = new THREE.Mesh(
			new THREE.SphereGeometry(2.85, 32, 24),
			new THREE.MeshBasicMaterial({ color: 0x4a9eff, transparent: true, opacity: 0.12, side: THREE.BackSide })
		);
		g.add(atm);

		// edificios reales en anillos alrededor del planeta
		var edificios = d.edificios || [];
		var RADIO = 5.2;
		var porAnillo = Math.min(10, Math.max(6, Math.ceil(edificios.length / 2)));
		for (var i = 0; i < edificios.length; i++) {
			var e = edificios[i];
			var anillo = Math.floor(i / porAnillo);
			var posIn = i % porAnillo;
			var totalIn = Math.min(porAnillo, edificios.length - anillo * porAnillo);
			var ang = (posIn / totalIn) * Math.PI * 2 + anillo * 0.35;
			var r = RADIO + anillo * 2.3;
			var x = Math.cos(ang) * r, z = Math.sin(ang) * r;

			var sp = X.spriteElemento(e.img, 1.9);
			sp.position.set(x, 0.9 + (anillo % 2) * 0.3, z);
			sp.userData = { tipo: 'edificio', item: e };
			g.add(sp);
			X.estado.rayTargets.push(sp);

			var et = X.etiqueta(e.nombre + ' ' + e.nivel, e.comprable ? '#7dd3fc' : '#64748b', 0.62);
			et.position.set(x, 2.15 + (anillo % 2) * 0.3, z);
			g.add(et);

			// pedestal (suelo de la escena, no imagen del juego)
			var ped = new THREE.Mesh(
				new THREE.CylinderGeometry(0.55, 0.75, 0.22, 18),
				new THREE.MeshStandardMaterial({ color: 0x16233c, roughness: 0.9 })
			);
			ped.position.set(x, -0.05, z);
			g.add(ped);
		}

		// anillo guía
		var circ = [];
		for (var a = 0; a <= 96; a++) {
			var t = (a / 96) * Math.PI * 2;
			circ.push(new THREE.Vector3(Math.cos(t) * RADIO, 0, Math.sin(t) * RADIO));
		}
		g.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints(circ),
			new THREE.LineBasicMaterial({ color: 0x1e3a5f, transparent: true, opacity: 0.6 })));

		X.estado.grupo = g;
		X.escena.add(g);
		X.camara.position.set(0, 9, 14);
		X.controls.target.set(0, 0, 0);

		// cola de construcción con cancelar (solo la orden activa)
		X.pintarCola(d.cola && d.cola.length ? d.cola.map(function (c) {
			return { nombre: c.nombre, nivel: (c.destruir ? '↓' : '↑') + c.nivel, img: c.img, restante: c.restante, cancelIdx: c.cancelIdx != null ? c.cancelIdx : 0 };
		}) : null, 'Sin construcción en curso — clic en un edificio para mejorar', function () {
			misAcciones.edificioCancelar();
		});
	}

	/* ---------- clic en la escena ---------- */
	function alClic(u) {
		if (u.tipo === 'edificio') detalleBase(u.item);
		else if (u.tipo === 'planetaBase') detallePlanetaBase();
	}

	X.registrar('base', { construir: construirBase, alClic: alClic });
})();
