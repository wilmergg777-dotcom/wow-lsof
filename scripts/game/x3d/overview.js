/**
 * XNOVA3D — MÓDULO RESUMEN (la vista principal del juego)
 * ========================================================
 * Escena inicial del escritorio 3D: TU planeta con su IMAGEN REAL
 * (planeten/{img}.jpg), la luna en órbita, la producción por hora,
 * las colas reales (edificios / investigación / naves) y las flotas
 * en vuelo con sus naves (gebaeude/{id}.gif).
 *
 * Acciones reales: los accesos rápidos saltan a los otros módulos
 * del escritorio (base / hangar / lab / flotas / imperio) con X.irA.
 *
 * Este archivo SOLO toca el RESUMEN. Para corregir otro módulo,
 * edita su propio archivo (x3d/base.js, x3d/hangar.js, ...).
 */
(function () {
	'use strict';
	var X = window.X3D;
	if (!X || !window.THREE) return;

	/* ---------- acciones propias del módulo ---------- */
	var misAcciones = {
		irConstruir: function () { X.irA('base'); },
		irNaves:     function () { X.irA('hangar'); },
		irLab:       function () { X.irA('lab'); },
		irFlotas:    function () { X.irA('flotas'); },
		irImperio:   function () { X.irA('imperio'); }
	};

	/* ---------- detalle del planeta (lo que muestra el panel derecho) ---------- */
	function detallePlanetaResumen(d) {
		var p = d.planeta;
		var esq = d.esquinas;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + X.esc(p.imgUrl) + '" alt="" onerror="this.remove()">' + X.esc(p.nombre.toUpperCase()) + '</div>' +
			X.kv('Tipo', X.esc(p.tipoNombre)) +
			X.kv('Coordenadas', '[' + X.esc(p.coords) + ']') +
			X.kv('Diámetro', X.fmt(p.diametro) + ' km') +
			X.kv('Temperatura', X.fmt(p.tempMin) + ' °C a ' + X.fmt(p.tempMax) + ' °C') +
			X.kv('Campos ocupados', p.campos.usados + ' / ' + p.campos.max) +
			'<div class="kv" style="margin-top:10px"><span>PRODUCCIÓN / HORA</span><b></b></div>' +
			X.kv('⛏️ Metal', '+' + X.fmtCorto(d.produccion.metal), 'ok') +
			X.kv('💎 Cristal', '+' + X.fmtCorto(d.produccion.cristal), 'ok') +
			X.kv('⛽ Deuterio', '+' + X.fmtCorto(d.produccion.deuterio), 'ok') +
			X.kv('⚡ Energía', X.fmt(esq.energia.max) + ' (' + X.fmt(esq.energia.usado) + ')') +
			X.kv('⚓ Slots de flota', d.slots.usados + ' / ' + d.slots.max) +
			'<div class="acciones">' +
			'<button class="btn-x pri" data-accion="irConstruir">🪐 Construir</button>' +
			'<button class="btn-x" data-accion="irNaves">🚀 Naves</button>' +
			'<button class="btn-x" data-accion="irLab">🔬 Investigar</button>' +
			'<button class="btn-x" data-accion="irFlotas">⚓ Flotas</button>' +
			'<button class="btn-x" data-accion="irImperio">🛰 Imperio</button>' +
			'</div>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- detalle de la luna ---------- */
	function detalleLuna(l) {
		var html = '<div class="x3d_dt-titulo">🌑 ' + X.esc(l.nombre.toUpperCase()) + '</div>' +
			X.kv('Tipo', 'Luna') +
			X.kv('Diámetro', X.fmt(l.diametro) + ' km') +
			'<div class="acciones"><button class="btn-x" data-accion="irImperio">🛰 Ver en el Imperio</button></div>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- detalle de una cola ---------- */
	function detalleCola(zona, d) {
		var titulo = { construccion: '🪐 COLA DE EDIFICIOS', investigacion: '🔬 COLA DE INVESTIGACIÓN', naves: '🚀 COLA DE NAVES' }[zona] || 'COLA';
		var items = (d.colas && d.colas[zona]) || [];
		var html = '<div class="x3d_dt-titulo">' + titulo + '</div>';
		if (!items.length) {
			html += '<p class="nota">Sin órdenes en curso.</p>';
		} else {
			for (var i = 0; i < items.length; i++) {
				var it = items[i];
				html += '<div class="x3d_dt-titulo" style="margin-top:6px"><img class="x3d_det-img" src="' + X.esc(it.img) + '" alt="" onerror="this.remove()">' + X.esc(it.nombre) + (it.nivel ? ' ' + it.nivel : '') + (it.cantidad ? ' ×' + X.fmt(it.cantidad) : '') + '</div>' +
					'<span data-seg="' + (it.restante || 0) + '">' + X.segAHms(it.restante || 0) + '</span>';
			}
		}
		var destino = { construccion: 'irConstruir', investigacion: 'irLab', naves: 'irNaves' }[zona] || 'irConstruir';
		var texto = { construccion: '🪐 Ir a Construir', investigacion: '🔬 Ir a Investigación', naves: '🚀 Ir a Naves' }[zona] || 'Ir';
		html += '<div class="acciones"><button class="btn-x pri" data-accion="' + destino + '">' + texto + '</button></div>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- detalle de una flota en vuelo ---------- */
	function detalleFlota(f) {
		var html = '<div class="x3d_dt-titulo">⚓ ' + X.esc(f.misionNombre) + (f.volviendo ? ' (REGRESANDO)' : '') + '</div>' +
			X.kv('Origen', X.esc(f.origen)) +
			X.kv('Destino', X.esc(f.destino)) +
			X.kv((f.volviendo ? 'Regresa en' : 'Llega en'), '<span data-seg="' + (f.volviendo ? f.regreso : f.llegada) + '">' + X.segAHms(f.volviendo ? f.regreso : f.llegada) + '</span>') +
			X.kv('Naves', X.fmt(f.totalNaves));
		for (var i = 0; i < f.naves.length && i < 6; i++) {
			html += '<div class="kv"><span><img class="x3d_det-img" src="' + X.esc(f.naves[i].img) + '" alt="" onerror="this.remove()" style="height:20px">' + X.esc(f.naves[i].nombre) + '</span><b>×' + X.fmt(f.naves[i].cantidad) + '</b></div>';
		}
		html += '<div class="acciones"><button class="btn-x pri" data-accion="irFlotas">⚓ Ver en Flotas</button></div>';
		X.pintarDetalle(html, misAcciones);
	}

	/* ---------- construcción de la escena ---------- */
	function construirResumen(d) {
		var g = new THREE.Group();
		var p = d.planeta;

		// planeta con la IMAGEN REAL del juego
		var planeta = new THREE.Mesh(
			new THREE.SphereGeometry(3.1, 48, 32),
			new THREE.MeshStandardMaterial({ color: 0x3a4a66, roughness: 0.8 })
		);
		X.texturaReal(p.imgUrl, planeta, true);
		g.add(planeta);
		X.estado.rayTargets.push(planeta);
		planeta.userData = { tipo: 'planetaResumen' };

		// atmósfera sutil (carcasa)
		var atm = new THREE.Mesh(
			new THREE.SphereGeometry(3.4, 32, 24),
			new THREE.MeshBasicMaterial({ color: 0x4a9eff, transparent: true, opacity: 0.13, side: THREE.BackSide })
		);
		g.add(atm);

		// luna en órbita (la rotación del grupo la hace girar alrededor)
		if (d.luna) {
			var luna = new THREE.Mesh(
				new THREE.SphereGeometry(0.75, 24, 18),
				new THREE.MeshStandardMaterial({ color: 0x8a8a8a, roughness: 0.95 })
			);
			X.texturaReal(d.luna.imgUrl, luna, true);
			luna.position.set(6.8, 1.1, -2.2);
			g.add(luna);
			X.estado.rayTargets.push(luna);
			luna.userData = { tipo: 'lunaResumen' };

			var etL = X.etiqueta(d.luna.nombre, '#9fb4cc', 0.62);
			etL.position.set(6.8, 2.1, -2.2);
			g.add(etL);
		}

		// satélites de colas reales (edificios / investigación / naves)
		var zonas = ['construccion', 'investigacion', 'naves'];
		for (var i = 0; i < zonas.length; i++) {
			var zona = zonas[i];
			var items = (d.colas && d.colas[zona]) || [];
			if (!items.length) continue;
			var it = items[0];
			var ang = (i / zonas.length) * Math.PI * 2 + 0.6;
			var x = Math.cos(ang) * 5.3, z = Math.sin(ang) * 5.3;

			// MODELO 3D REAL del primer elemento de cada cola
			var modelo;
			if (zona === 'construccion' && X.modeloEdificio) modelo = X.modeloEdificio(it.id, it.nombre, 0.9);
			else if (zona === 'investigacion' && X.modeloInvestigacion) modelo = X.modeloInvestigacion(it.id, it.nombre, 0.9);
			else if (zona === 'naves' && X.modeloNave) modelo = X.modeloNave(it.id, it.nombre, 0.7);
			else modelo = X.spriteElemento(it.img, 1.7);
			modelo.position.set(x, 0.45, z);
			modelo.rotation.y = -ang;
			modelo.userData = { tipo: 'colaResumen', zona: zona };
			g.add(modelo);
			X.estado.rayTargets.push(modelo);

			var txt = it.nombre + (it.nivel ? ' ' + it.nivel : '') + (it.cantidad ? ' ×' + it.cantidad : '');
			var et = X.etiqueta(txt + ' · ' + X.segAHms(it.restante || 0), '#7dd3fc', 0.62);
			et.position.set(x, 2.0, z);
			g.add(et);
		}

		// flotas en vuelo: nave 3D real girando en órbita (alTick)
		var flotas = (d.flotas || []).slice(0, 6);
		for (var j = 0; j < flotas.length; j++) {
			var f = flotas[j];
			if (!f.naves || !f.naves.length) continue;

			// portador: nave + etiqueta, animado en el ciclo de animación
			var portador = new THREE.Group();
			var nave = (X.modeloNave)
				? X.modeloNave(f.naves[0].id, f.naves[0].nombre, 0.85)
				: X.spriteElemento(f.naves[0].img, 1.6);
			nave.rotation.y = Math.PI; // el modelo mira a -z; alinear al vuelo
			portador.add(nave);

			var etF = X.etiqueta(f.misionNombre + ' → ' + f.destino.split(' ')[0] + ' · ' + X.segAHms(f.volviendo ? f.regreso : f.llegada), f.volviendo ? '#ffb347' : '#35ff8f', 0.58);
			etF.position.y = 1.35;
			portador.add(etF);

			portador.userData = { tipo: 'flotaResumen', item: f };
			g.add(portador);
			X.estado.rayTargets.push(portador);

			var vuelo = {
				a0: (j / 6) * Math.PI * 2 + 2.2,
				r: 7.6 + (j % 2) * 0.7,
				y: 1.4 + (j % 3) * 0.5,
				vel: (f.volviendo ? -0.16 : 0.22) + (j % 3) * 0.03,
				fase: j * 1.7
			};
			portador.position.set(Math.cos(vuelo.a0) * vuelo.r, vuelo.y, Math.sin(vuelo.a0) * vuelo.r);

			X.alTick(function (portador, vuelo) {
				return function (dt, t) {
					var a = vuelo.a0 + t * vuelo.vel;
					var px = Math.cos(a) * vuelo.r, pz = Math.sin(a) * vuelo.r;
					var py = vuelo.y + Math.sin(t * 1.6 + vuelo.fase) * 0.15;
					portador.position.set(px, py, pz);
					// morro hacia la tangente de la órbita
					portador.lookAt(Math.cos(a + 0.12 * (vuelo.vel > 0 ? 1 : -1)) * vuelo.r, py, Math.sin(a + 0.12 * (vuelo.vel > 0 ? 1 : -1)) * vuelo.r);
				};
			}(portador, vuelo));
		}

		// anillos guía (suelo de la escena)
		for (var r = 0; r < 2; r++) {
			var RADIO = r === 0 ? 5.3 : 7.6;
			var circ = [];
			for (var a = 0; a <= 96; a++) {
				var t = (a / 96) * Math.PI * 2;
				circ.push(new THREE.Vector3(Math.cos(t) * RADIO, 0, Math.sin(t) * RADIO));
			}
			g.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints(circ),
				new THREE.LineBasicMaterial({ color: 0x1e3a5f, transparent: true, opacity: 0.5 })));
		}

		X.estado.grupo = g;
		X.escena.add(g);
		X.camara.position.set(0, 9, 15);
		X.controls.target.set(0, 0, 0);

		// panel derecho inicial: el resumen del planeta
		detallePlanetaResumen(d);

		// tira inferior: las tres colas con cuenta atrás en vivo
		var colaItems = [];
		var zonas2 = ['construccion', 'investigacion', 'naves'];
		for (var k = 0; k < zonas2.length; k++) {
			var zs = zonas2[k];
			var items2 = (d.colas && d.colas[zs]) || [];
			for (var m = 0; m < items2.length; m++) {
				var q = items2[m];
				colaItems.push({
					nombre: q.nombre,
					nivel: (q.destruir ? '↓' : '↑') + (q.nivel || ''),
					img: q.img,
					cantidad: q.cantidad || 0,
					restante: q.restante || 0
				});
			}
		}
		X.pintarCola(colaItems.length ? colaItems : null, 'Sin órdenes en curso — todo tranquilo en ' + X.esc(p.nombre));
	}

	/* ---------- clic en la escena ---------- */
	function alClic(u) {
		var d = X.estado.datos;
		if (!d) return;
		if (u.tipo === 'planetaResumen') detallePlanetaResumen(d);
		else if (u.tipo === 'lunaResumen' && d.luna) detalleLuna(d.luna);
		else if (u.tipo === 'colaResumen') detalleCola(u.zona, d);
		else if (u.tipo === 'flotaResumen' && u.item) detalleFlota(u.item);
	}

	X.registrar('resumen', { construir: construirResumen, alClic: alClic });
})();
