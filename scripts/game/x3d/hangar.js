/**
 * XNOVA3D — MÓDULO HANGAR (naves y defensas)
 * ===========================================
 * Escena: dos anillos con las naves y defensas REALES (gebaeude/{id}.gif)
 * + el hangar real (edificio 21) en el centro.
 * Acciones reales: construir (POST fmenge a shipyard) y cancelar pedidos.
 *
 * Este archivo SOLO toca el HANGAR.
 */
(function () {
	'use strict';
	var X = window.X3D;
	if (!X || !window.THREE) return;

	/* ---------- detalle de una nave / defensa ---------- */
	function detalleNave(item, zona) {
		var esq = X.estado.datos.esquinas;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + X.esc(item.img) + '" alt="" onerror="this.remove()">' + X.esc(item.nombre.toUpperCase()) + '</div>' +
			X.kv(zona === 'fleet' ? 'En el hangar' : 'En el planeta', X.fmt(item.tengo)) +
			X.costoHTML(item.costo, esq) +
			X.kv('Tiempo por unidad', X.segAHms(item.segundos)) +
			X.kv('Máx. construible', X.fmt(item.maxConstruible), item.maxConstruible > 0 ? 'ok' : 'mal') +
			'<div class="acciones">' +
			'<input class="x3d_qty" id="x3d_qty_nave" type="number" min="1" value="' + Math.max(1, Math.min(item.maxConstruible, 10)) + '">' +
			'<button class="btn-x pri" id="x3d_btn_nave" data-id="' + item.id + '">🚀 Construir</button>' +
			'</div>' +
			'<p class="nota">La orden va al módulo clásico de naves/defensas (mismo servidor y BD).</p>';
		X.pintarDetalle(html, null);
		var b = document.getElementById('x3d_btn_nave');
		if (b) b.addEventListener('click', function () {
			var qty = parseInt(document.getElementById('x3d_qty_nave').value, 10) || 0;
			if (qty <= 0) { X.toast('⚠️ Indica una cantidad', true); return; }
			X.construirNaves(zona, item.id, qty, item.nombre);
		});
	}

	/* ---------- construcción de la escena ---------- */
	function construirHangar(d) {
		var g = new THREE.Group();

		function anillo(lista, radio, zona) {
			var n = lista.length || 1;
			for (var i = 0; i < lista.length; i++) {
				var e = lista[i];
				var ang = (i / n) * Math.PI * 2;
				var x = Math.cos(ang) * radio, z = Math.sin(ang) * radio;
				// MODELO 3D REAL (fábrica por nombre/id; sprite solo como reserva)
				var modelo;
				if (zona === 'fleet' && X.modeloNave) modelo = X.modeloNave(e.id, e.nombre, 0.9);
				else if (zona === 'defense' && X.modeloDefensa) modelo = X.modeloDefensa(e.id, e.nombre, 0.9);
				else modelo = X.spriteElemento(e.img, 1.7);
				modelo.position.set(x, 0.45, z);
				modelo.rotation.y = -ang;
				modelo.userData = { tipo: 'nave', item: e, zona: zona };
				g.add(modelo);
				X.estado.rayTargets.push(modelo);
				var et = X.etiqueta(e.nombre + ' ×' + X.fmtCorto(e.tengo), zona === 'fleet' ? '#7dd3fc' : '#c084fc', 0.55);
				et.position.set(x, 1.8, z);
				g.add(et);
			}
			var circ = [];
			for (var a = 0; a <= 96; a++) {
				var t = (a / 96) * Math.PI * 2;
				circ.push(new THREE.Vector3(Math.cos(t) * radio, 0, Math.sin(t) * radio));
			}
			g.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints(circ),
				new THREE.LineBasicMaterial({ color: zona === 'fleet' ? 0x1e3a5f : 0x3b1e5f, transparent: true, opacity: 0.6 })));
		}

		anillo(d.naves || [], 4.6, 'fleet');
		anillo(d.defensas || [], 7.6, 'defense');

		// hangar central: fábrica 3D real (edificio 21)
		var centro = (X.modeloEdificio)
			? X.modeloEdificio(21, 'Hangar', 1.6)
			: X.spriteElemento(X.DPATH + 'gebaeude/21.gif', 2.6);
		centro.position.set(0, 0.2, 0);
		g.add(centro);

		X.estado.grupo = g;
		X.escena.add(g);
		X.camara.position.set(0, 12, 15);
		X.controls.target.set(0, 0, 0);

		// colas reales de naves y defensas con cancelar por pedido
		var qn = (d.colaNaves && d.colaNaves.items || []).map(function (c) {
			return { nombre: c.nombre, cantidad: c.cantidad, img: c.img, restante: c.segUnidad * c.cantidad, cancelIdx: c.idx, zona: 'fleet' };
		});
		var qd = (d.colaDefensas && d.colaDefensas.items || []).map(function (c) {
			return { nombre: c.nombre, cantidad: c.cantidad, img: c.img, restante: c.segUnidad * c.cantidad, cancelIdx: c.idx, zona: 'defense' };
		});
		X.pintarCola(qn.concat(qd), 'Sin naves ni defensas en producción', function (item) {
			X.cancelarHangar(item.zona, item.cancelIdx);
		});
	}

	/* ---------- clic en la escena ---------- */
	function alClic(u) {
		if (u.tipo === 'nave') detalleNave(u.item, u.zona);
	}

	X.registrar('hangar', { construir: construirHangar, alClic: alClic });
})();
