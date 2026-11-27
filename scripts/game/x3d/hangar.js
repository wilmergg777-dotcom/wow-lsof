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
				var sp = X.spriteElemento(e.img, 1.7);
				sp.position.set(x, 0.85, z);
				sp.userData = { tipo: 'nave', item: e, zona: zona };
				g.add(sp);
				X.estado.rayTargets.push(sp);
				var et = X.etiqueta(e.nombre + ' ×' + X.fmtCorto(e.tengo), zona === 'fleet' ? '#7dd3fc' : '#c084fc', 0.55);
				et.position.set(x, 1.95, z);
				g.add(et);
				var ped = new THREE.Mesh(
					new THREE.CylinderGeometry(0.5, 0.68, 0.18, 16),
					new THREE.MeshStandardMaterial({ color: 0x16233c, roughness: 0.9 })
				);
				ped.position.set(x, -0.04, z);
				g.add(ped);
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

		// hangar central (edificio 21 real del juego)
		var centro = X.spriteElemento(X.DPATH + 'gebaeude/21.gif', 2.6);
		centro.position.set(0, 1.6, 0);
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
