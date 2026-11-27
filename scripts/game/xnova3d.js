/**
 * XNOVA3D (rama xnova3d) — ESCRITORIO 3D COMPLETO
 * ================================================
 * Todo el juego en una app 3D con las IMÁGENES REALES del proyecto
 * (styles/theme/gow/gebaeude + planeten), no gráficos hechos por código:
 *   - BASE:  tu planeta real + edificios reales (como Overview/Buildings)
 *   - NAVES: hangar (Shipyard, naves + defensas)
 *   - INVESTIGACIÓN: laboratorio (Research)
 *   - IMPERIO: tus planetas y lunas (Imperium)
 *   - FLOTAS: tus flotas en vuelo
 *   - MÓDULOS: todos los módulos del juego abren como paneles dentro del 3D
 * Datos: game.php?page=x3d&mode=fetch&modo=base|hangar|lab|imperio|flotas
 * Acciones: POST reales a las páginas clásicas (el servidor aplica las reglas).
 */
(function () {
	'use strict';

	var D0 = window.X3D_DATA || {};
	var DPATH = window.X3D_DPATH || D0.dpath || './styles/theme/gow/';

	function $(id) { return document.getElementById(id); }
	function esc(s) {
		return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
			return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
		});
	}
	function fmt(n) { return Math.round(Number(n) || 0).toLocaleString('es-ES'); }
	function fmtCorto(n) {
		n = Number(n) || 0;
		if (n >= 1e9) return (n / 1e9).toFixed(1) + 'G';
		if (n >= 1e6) return (n / 1e6).toFixed(1) + 'M';
		if (n >= 1e3) return (n / 1e3).toFixed(1) + 'k';
		return String(Math.round(n));
	}
	function segAHms(seg) {
		seg = Math.max(0, Math.round(seg));
		var h = Math.floor(seg / 3600), m = Math.floor((seg % 3600) / 60), s = seg % 60;
		if (h > 0) return h + 'h ' + (m < 10 ? '0' : '') + m + 'm';
		if (m > 0) return m + 'm ' + (s < 10 ? '0' : '') + s + 's';
		return s + 's';
	}
	function toast(html, mal) {
		var caja = $('x3d_toasts');
		var el = document.createElement('div');
		el.className = 'x3d_toast' + (mal ? ' mal' : '');
		el.innerHTML = html;
		caja.appendChild(el);
		setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 3400);
	}
	function mostrarCarga(txt) {
		var c = $('x3d_carga');
		c.style.display = 'flex';
		c.querySelector('div:last-child').textContent = txt || 'CARGANDO XNOVA 3D…';
	}
	function ocultarCarga() { $('x3d_carga').style.display = 'none'; }

	if (!window.THREE) {
		$('x3d_carga').innerHTML = '<div style="color:#ff4488;letter-spacing:1px">ERROR: falta scripts/game/three.min.js</div>';
		return;
	}

	/* ================= THREE: contenedor común ================= */
	var cont = $('x3d_canvas');
	var renderer = new THREE.WebGLRenderer({ antialias: true });
	renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
	cont.appendChild(renderer.domElement);

	var escena = new THREE.Scene();
	escena.background = new THREE.Color(0x05080f);

	var camara = new THREE.PerspectiveCamera(55, 1, 0.1, 600);
	camara.position.set(0, 8, 15);

	var controls = new THREE.OrbitControls(camara, renderer.domElement);
	controls.enableDamping = true;
	controls.dampingFactor = 0.08;
	controls.minDistance = 4;
	controls.maxDistance = 90;

	escena.add(new THREE.AmbientLight(0x8fa3bf, 1.15));
	var luzSol = new THREE.PointLight(0xffdd88, 1.5, 400);
	luzSol.position.set(30, 22, 18);
	escena.add(luzSol);

	function redimensionar() {
		var w = cont.clientWidth, h = cont.clientHeight;
		if (w === 0 || h === 0) return;
		renderer.setSize(w, h);
		camara.aspect = w / h;
		camara.updateProjectionMatrix();
	}
	window.addEventListener('resize', redimensionar);

	// campo de estrellas
	(function campoEstrellas() {
		var pts = [];
		for (var i = 0; i < 900; i++) {
			var r = 120 + Math.random() * 160;
			var th = Math.random() * Math.PI * 2, ph = Math.acos(2 * Math.random() - 1);
			pts.push(new THREE.Vector3(r * Math.sin(ph) * Math.cos(th), r * Math.sin(ph) * Math.sin(th) * 0.6, r * Math.cos(ph)));
		}
		escena.add(new THREE.Points(
			new THREE.BufferGeometry().setFromPoints(pts),
			new THREE.PointsMaterial({ color: 0x9fb6d8, size: 0.55, sizeAttenuation: true, transparent: true, opacity: 0.8 })
		));
	})();

	/* ================= texturas REALES del juego (caché) ================= */
	var texLoader = new THREE.TextureLoader();
	texLoader.setCrossOrigin('anonymous');
	var texCache = {}, texFila = [];
	function texPoner(url, tx) {
		texCache[url] = tx;
		texFila.push(url);
		if (texFila.length > 60) {
			var viejo = texFila.shift();
			if (texCache[viejo]) { texCache[viejo].dispose(); delete texCache[viejo]; }
		}
	}
	function aplicarTex(obj, tx, comoBump) {
		if (!obj.parent && !obj.isSprite) return;
		obj.material.map = tx;
		obj.material.color.setHex(0xffffff);
		if (comoBump && obj.material.bumpMap !== undefined) {
			obj.material.bumpMap = tx; obj.material.bumpScale = 0.02;
		}
		obj.material.needsUpdate = true;
	}
	function texturaReal(url, obj, comoBump) {
		try {
			if (texCache[url]) { aplicarTex(obj, texCache[url], comoBump); return; }
			texLoader.load(url, function (tx) { texPoner(url, tx); aplicarTex(obj, tx, comoBump); }, undefined, function () { /* mantiene color */ });
		} catch (e) { /* sin textura: color */ }
	}

	/* etiqueta de texto (UI de la escena, no imagen del juego) */
	function etiqueta(texto, color, alto) {
		alto = alto || 1.1;
		var cv = document.createElement('canvas'); cv.width = 512; cv.height = 128;
		var c = cv.getContext('2d');
		c.font = '700 34px "Segoe UI", Arial, sans-serif';
		c.textAlign = 'center'; c.textBaseline = 'middle';
		c.shadowColor = 'rgba(0,0,0,0.95)'; c.shadowBlur = 8;
		c.fillStyle = color;
		c.fillText(texto, 256, 64);
		var sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(cv), transparent: true, depthWrite: false }));
		sp.scale.set(alto * 4, alto, 1);
		return sp;
	}

	/* sprite de elemento con su IMAGEN REAL (gebaeude/{id}.gif) */
	function spriteElemento(url, escala) {
		var sp = new THREE.Sprite(new THREE.SpriteMaterial({ color: 0x3a4a66, transparent: true, depthWrite: false }));
		sp.scale.set(escala, escala, 1);
		texturaReal(url, sp);
		return sp;
	}

	/* ================= estado ================= */
	var estado = { escena: 'base', datos: null, sel: null, grupo: null, rayTargets: [] };

	function limpiarEscena() {
		if (!estado.grupo) return;
		estado.grupo.traverse(function (o) {
			if (o.geometry) o.geometry.dispose();
			if (o.material) {
				if (o.material.map && o.material.map.isCanvasTexture) o.material.map.dispose();
				o.material.dispose();
			}
		});
		escena.remove(estado.grupo);
		estado.grupo = null;
		estado.rayTargets = [];
		estado.sel = null;
	}

	/* ================= datos ================= */
	function pintarRecursos(esq) {
		if (!esq) return;
		$('x3d_planeta_txt').textContent = esq.planeta.nombre + ' [' + esq.planeta.coords + '] · campos ' + esq.planeta.campos.usados + '/' + esq.planeta.campos.max;
		$('x3d_r_metal').textContent = fmtCorto(esq.recursos.metal.val);
		$('x3d_r_metal_max').textContent = ' / ' + fmtCorto(esq.recursos.metal.max);
		$('x3d_r_cristal').textContent = fmtCorto(esq.recursos.cristal.val);
		$('x3d_r_cristal_max').textContent = ' / ' + fmtCorto(esq.recursos.cristal.max);
		$('x3d_r_deuterio').textContent = fmtCorto(esq.recursos.deuterio.val);
		$('x3d_r_deuterio_max').textContent = ' / ' + fmtCorto(esq.recursos.deuterio.max);
		$('x3d_r_energia').textContent = fmt(esq.energia.max) + ' (' + fmt(esq.energia.usado) + ')';
		$('x3d_r_dm').textContent = fmtCorto(esq.usuario.dm);
	}

	function cargarDatos(modo, cb) {
		mostrarCarga('CARGANDO ' + modo.toUpperCase() + '…');
		jQuery.getJSON('game.php?page=x3d&mode=fetch&modo=' + modo, function (d) {
			estado.datos = d;
			pintarRecursos(d.esquinas);
			cb(d);
			ocultarCarga();
		}).fail(function () {
			ocultarCarga();
			toast('⚠️ No se pudieron cargar los datos de <b>' + esc(modo) + '</b>', true);
		});
	}

	/* recuento de recursos para saber si algo es alcanzable (para pintar ok/mal) */
	function hayPara(costo, esq) {
		if (!esq) return true;
		return costo.metal <= esq.recursos.metal.val && costo.cristal <= esq.recursos.cristal.val && costo.deuterio <= esq.recursos.deuterio.val;
	}

	/* ================= ACCIONES (POST reales al juego clásico) ================= */
	function postJuego(url, params, luego) {
		var cuerpo = new URLSearchParams();
		Object.keys(params).forEach(function (k) { cuerpo.append(k, params[k]); });
		fetch(url, { method: 'POST', body: cuerpo, credentials: 'same-origin' })
			.then(function () { return luego(); })
			.catch(function () { toast('⚠️ Error de red al enviar la orden', true); });
	}

	/* ================= DETALLE (panel derecho) ================= */
	function kv(span, val, cls) {
		return '<div class="kv"><span>' + span + '</span><b class="' + (cls || '') + '">' + val + '</b></div>';
	}
	function costoHTML(costo, esq) {
		var ok = hayPara(costo, esq);
		var cls = ok ? 'ok' : 'mal';
		return kv('⛏️ Metal', fmt(costo.metal), cls) + kv('💎 Cristal', fmt(costo.cristal), cls) + kv('⛽ Deuterio', fmt(costo.deuterio), cls);
	}
	function pintarDetalle(html) {
		$('x3d_det').innerHTML = html;
		$('x3d_det').querySelectorAll('[data-accion]').forEach(function (b) {
			b.addEventListener('click', function () { acciones[b.dataset.accion](b.dataset); });
		});
	}
	var acciones = {
		edificioMejorar: function (d) {
			toast('🏗️ Orden enviada: <b>' + esc(d.nombre) + '</b>');
			postJuego('game.php?page=buildings', { cmd: 'insert', building: d.id }, function () { recargarEscena(); });
		},
		edificioDestruir: function (d) {
			toast('💥 Orden enviada: demoler <b>' + esc(d.nombre) + '</b>');
			postJuego('game.php?page=buildings', { cmd: 'destroy', building: d.id }, function () { recargarEscena(); });
		},
		edificioCancelar: function () {
			toast('✋ Cancelando la orden de construcción…');
			postJuego('game.php?page=buildings', { cmd: 'cancel', building: 0 }, function () { recargarEscena(); });
		},
		techMejorar: function (d) {
			toast('🔬 Orden enviada: <b>' + esc(d.nombre) + '</b>');
			postJuego('game.php?page=research', { cmd: 'insert', element: d.id }, function () { recargarEscena(); });
		},
		techCancelar: function () {
			toast('✋ Cancelando investigación…');
			postJuego('game.php?page=research', { cmd: 'cancel', element: 0 }, function () { recargarEscena(); });
		},
		imperioIr: function (d) {
			window.location.href = 'game.php?page=overview&cp=' + d.pid;
		},
		abrirFlotas: function () {
			abrirPanel('game.php?page=fleetTable', '⚓ FLOTA');
		},
		abrirUrl: function (d) {
			abrirPanel(d.url, d.titulo);
		}
	};

	/* la construcción de naves necesita fmenge[id]=cantidad (array POST) */
	function construirNaves(zona, id, cantidad, nombre) {
		var cuerpo = new URLSearchParams();
		cuerpo.append('fmenge[' + id + ']', cantidad);
		toast('🚀 Orden enviada: <b>' + fmt(cantidad) + ' × ' + esc(nombre) + '</b>');
		fetch('game.php?page=shipyard&mode=' + zona, { method: 'POST', body: cuerpo, credentials: 'same-origin' })
			.then(function () { recargarEscena(); })
			.catch(function () { toast('⚠️ Error de red al enviar la orden', true); });
	}
	/* cancelar un pedido del hangar (auftr[]=idx) */
	function cancelarHangar(zona, idx) {
		var cuerpo = new URLSearchParams();
		cuerpo.append('auftr[]', idx);
		toast('✋ Cancelando pedido del hangar…');
		fetch('game.php?page=shipyard&mode=' + zona + '&action=delete', { method: 'POST', body: cuerpo, credentials: 'same-origin' })
			.then(function () { recargarEscena(); })
			.catch(function () { toast('⚠️ Error de red', true); });
	}

	/* ================= COLA (tira inferior) ================= */
	function pintarCola(items, etiquetaVacia) {
		var caja = $('x3d_cola');
		if (!items || !items.length) {
			caja.innerHTML = '<span class="x3d_cola-vacia">' + etiquetaVacia + '</span>';
			return;
		}
		var html = '';
		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			html += '<div class="x3d_cola-item">' +
				(it.img ? '<img src="' + it.img + '" alt="" onerror="this.style.display=\'none\'">' : '') +
				'<span class="n">' + esc(it.nombre) + (it.nivel ? ' ' + it.nivel : '') + (it.cantidad ? ' ×' + fmt(it.cantidad) : '') + '</span>' +
				(it.restante != null ? '<span class="t" data-seg="' + it.restante + '">' + segAHms(it.restante) + '</span>' : '') +
				(it.cancelIdx != null ? '<button class="cancelar" title="Cancelar" data-ci="' + it.cancelIdx + '" data-zona="' + esc(it.zona) + '">✕</button>' : '') +
				'</div>';
		}
		caja.innerHTML = html;
		caja.querySelectorAll('.cancelar').forEach(function (b) {
			// idx -1 = cancelar cola de edificios (se enlaza en construirBase)
			if (parseInt(b.dataset.ci, 10) !== -1) {
				b.addEventListener('click', function () { cancelarHangar(b.dataset.zona, parseInt(b.dataset.ci, 10)); });
			}
		});
		iniciarCuentas();
	}
	var cuentas = [];
	function iniciarCuentas() {
		cuentas.forEach(function (t) { clearInterval(t); });
		cuentas = [];
		document.querySelectorAll('#x3d_cola [data-seg], #x3d_det [data-seg]').forEach(function (el) {
			var seg = parseInt(el.dataset.seg, 10);
			if (isNaN(seg)) return;
			var t = setInterval(function () {
				seg -= 1;
				if (seg <= 0) { el.textContent = '✔'; clearInterval(t); return; }
				el.textContent = segAHms(seg);
			}, 1000);
			cuentas.push(t);
		});
	}

	/* ================= ESCENAS 3D ================= */

	/* ---- BASE: planeta real + edificios reales en anillos ---- */
	function construirBase(d) {
		var g = new THREE.Group();
		var p = d.esquinas.planeta;

		// planeta con la IMAGEN REAL del juego
		var planeta = new THREE.Mesh(
			new THREE.SphereGeometry(2.6, 48, 32),
			new THREE.MeshStandardMaterial({ color: 0x3a4a66, roughness: 0.8 })
		);
		texturaReal(p.imgUrl, planeta, true);
		g.add(planeta);
		estado.rayTargets.push(planeta);
		planeta.userData = { tipo: 'planetaBase' };

		// atmósfera sutil
		var atm = new THREE.Mesh(
			new THREE.SphereGeometry(2.85, 32, 24),
			new THREE.MeshBasicMaterial({ color: 0x4a9eff, transparent: true, opacity: 0.12, side: THREE.BackSide })
		);
		g.add(atm);

		// edificios reales en dos anillos alrededor del planeta
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

			var sp = spriteElemento(e.img, 1.9);
			sp.position.set(x, 0.9 + (anillo % 2) * 0.3, z);
			sp.userData = { tipo: 'edificio', item: e };
			g.add(sp);
			estado.rayTargets.push(sp);

			var et = etiqueta(e.nombre + ' ' + e.nivel, e.comprable ? '#7dd3fc' : '#64748b', 0.62);
			et.position.set(x, 2.15 + (anillo % 2) * 0.3, z);
			sp.userData._etq = et;
			g.add(et);

			// pedestal (suelo, no imagen del juego)
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

		estado.grupo = g;
		escena.add(g);
		camara.position.set(0, 9, 14);
		controls.target.set(0, 0, 0);

		pintarCola(d.cola && d.cola.length ? d.cola.map(function (c, ix) {
			return { nombre: c.nombre, nivel: (c.destruir ? '↓' : '↑') + c.nivel, img: c.img, restante: c.restante, cancelIdx: ix === 0 ? -1 : null };
		}) : null, 'Sin construcción en curso — clic en un edificio para mejorar');

		// botón cancelar de la cola
		var c0 = $('x3d_cola').querySelector('.cancelar');
		if (c0) c0.addEventListener('click', function () { acciones.edificioCancelar(); });
	}

	/* detalle BASE */
	function detalleBase(item) {
		var d = estado.datos;
		var esq = d.esquinas;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + esc(item.img) + '" alt="" onerror="this.remove()">' + esc(item.nombre.toUpperCase()) + '</div>' +
			kv('Nivel actual', item.nivel) +
			costoHTML(item.costo, esq) +
			kv('Tiempo', segAHms(item.segundos)) +
			(item.comprable ? kv('Recursos', 'Suficientes', 'ok') : kv('Recursos', 'Insuficientes', 'mal')) +
			'<div class="acciones">' +
			'<button class="btn-x pri" data-accion="edificioMejorar" data-id="' + item.id + '" data-nombre="' + esc(item.nombre) + '" ' + (item.comprable ? '' : '') + '>🏗️ Mejorar a ' + (item.nivel + 1) + '</button>' +
			(item.destruible ? '<button class="btn-x" data-accion="edificioDestruir" data-id="' + item.id + '" data-nombre="' + esc(item.nombre) + '">💥 Demoler</button>' : '') +
			'</div>' +
			'<div class="kv" style="margin-top:8px"><span>Demoler devuelve</span><b style="color:#64748b">' + fmtCorto(item.destruirCosto.metal) + ' M · ' + fmtCorto(item.destruirCosto.cristal) + ' C · ' + fmtCorto(item.destruirCosto.deuterio) + ' D</b></div>' +
			'<p class="nota">La orden se envía al módulo clásico de edificios: el servidor aplica las reglas reales del juego.</p>';
		pintarDetalle(html);
	}

	function detallePlanetaBase() {
		var p = estado.datos.esquinas.planeta;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + DPATH + 'planeten/small/s_' + esc(p.img) + '.jpg" alt="" onerror="this.remove()">TU PLANETA</div>' +
			kv('Nombre', esc(p.nombre)) +
			kv('Coordenadas', '[' + esc(p.coords) + ']') +
			kv('Campos ocupados', p.campos.usados + ' / ' + p.campos.max) +
			'<div class="acciones"><button class="btn-x" data-accion="imperioIr" data-pid="' + p.id + '">🛰 Ver en el Imperio</button></div>';
		pintarDetalle(html);
	}

	/* ---- HANGAR: naves y defensas con sus imágenes reales ---- */
	function construirHangar(d) {
		var g = new THREE.Group();
		var estadoQ = [];

		function anillo(lista, radio, zona, colorEtiqueta) {
			var n = lista.length || 1;
			for (var i = 0; i < lista.length; i++) {
				var e = lista[i];
				var ang = (i / n) * Math.PI * 2;
				var x = Math.cos(ang) * radio, z = Math.sin(ang) * radio;
				var sp = spriteElemento(e.img, 1.7);
				sp.position.set(x, 0.85, z);
				sp.userData = { tipo: 'nave', item: e, zona: zona };
				g.add(sp);
				estado.rayTargets.push(sp);
				var et = etiqueta(e.nombre + ' ×' + fmtCorto(e.tengo), colorEtiqueta, 0.55);
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
				new THREE.LineBasicMaterial({ color: colorEtiqueta === '#7dd3fc' ? 0x1e3a5f : 0x3b1e5f, transparent: true, opacity: 0.6 })));
		}

		anillo(d.naves || [], 4.6, 'fleet', '#7dd3fc');
		anillo(d.defensas || [], 7.6, 'defense', '#c084fc');

		// hangar central (edificio 21 real)
		var centro = spriteElemento(DPATH + 'gebaeude/21.gif', 2.6);
		centro.position.set(0, 1.6, 0);
		g.add(centro);

		estado.grupo = g;
		escena.add(g);
		camara.position.set(0, 12, 15);
		controls.target.set(0, 0, 0);

		var qn = (d.colaNaves && d.colaNaves.items || []).map(function (c) {
			return { nombre: c.nombre, cantidad: c.cantidad, img: c.img, restante: c.segUnidad * c.cantidad, cancelIdx: c.idx, zona: 'fleet' };
		});
		var qd = (d.colaDefensas && d.colaDefensas.items || []).map(function (c) {
			return { nombre: c.nombre, cantidad: c.cantidad, img: c.img, restante: c.segUnidad * c.cantidad, cancelIdx: c.idx, zona: 'defense' };
		});
		pintarCola(qn.concat(qd), 'Sin naves ni defensas en producción');
	}

	function detalleNave(item, zona) {
		var d = estado.datos;
		var esq = d.esquinas;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + esc(item.img) + '" alt="" onerror="this.remove()">' + esc(item.nombre.toUpperCase()) + '</div>' +
			kv(zona === 'fleet' ? 'En el hangar' : 'En el planeta', fmt(item.tengo)) +
			costoHTML(item.costo, esq) +
			kv('Tiempo por unidad', segAHms(item.segundos)) +
			kv('Máx. construible', fmt(item.maxConstruible), item.maxConstruible > 0 ? 'ok' : 'mal') +
			'<div class="acciones">' +
			'<input class="x3d_qty" id="x3d_qty_nave" type="number" min="1" value="' + Math.max(1, Math.min(item.maxConstruible, 10)) + '">' +
			'<button class="btn-x pri" data-accion="naveConstruir" data-id="' + item.id + '" data-nombre="' + esc(item.nombre) + '" data-zona="' + zona + '">🚀 Construir</button>' +
			'</div>' +
			'<p class="nota">La orden va al módulo clásico de naves/defensas (mismo servidor y BD).</p>';
		pintarDetalle(html);
		var b = $('x3d_det').querySelector('[data-accion="naveConstruir"]');
		if (b) b.addEventListener('click', function () {
			var qty = parseInt($('x3d_qty_nave').value, 10) || 0;
			if (qty <= 0) { toast('⚠️ Indica una cantidad', true); return; }
			construirNaves(zona, item.id, qty, item.nombre);
		});
	}

	/* ---- LABORATORIO: investigaciones con imágenes reales ---- */
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

			// pad (aro de energía, suelo)
			var pad = new THREE.Mesh(
				new THREE.TorusGeometry(1.15, 0.07, 10, 36),
				new THREE.MeshBasicMaterial({ color: t.comprable ? 0x00e0ff : 0x3b4a66 })
			);
			pad.rotation.x = Math.PI / 2;
			pad.position.set(x, -0.55, z);
			g.add(pad);

			var sp = spriteElemento(t.img, 1.6);
			sp.position.set(x, 0.55, z);
			sp.userData = { tipo: 'tech', item: t };
			g.add(sp);
			estado.rayTargets.push(sp);

			var et = etiqueta(t.nombre + ' ' + t.nivel, t.comprable ? '#7dd3fc' : '#64748b', 0.52);
			et.position.set(x, 1.5, z);
			g.add(et);
		}

		// laboratorio central real (edificio 31)
		var centro = spriteElemento(DPATH + 'gebaeude/31.gif', 2.4);
		centro.position.set(0, 1.8, -(Math.ceil(techs.length / porFila)) * 3.4 - 1.5);
		g.add(centro);

		estado.grupo = g;
		escena.add(g);
		camara.position.set(0, 10, 15);
		controls.target.set(0, 0, 0);

		pintarCola(d.cola && d.cola.length ? d.cola.map(function (c) {
			return { nombre: c.nombre, nivel: c.nivel, img: c.img, restante: c.restante };
		}) : null, d.enOtroPlaneta ? 'Investigando en otro planeta' : 'Sin investigación en curso');
	}

	function detalleTech(item) {
		var d = estado.datos;
		var esq = d.esquinas;
		var ocupado = d.cola && d.cola.length > 0;
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + esc(item.img) + '" alt="" onerror="this.remove()">' + esc(item.nombre.toUpperCase()) + '</div>' +
			kv('Nivel actual', item.nivel) +
			costoHTML(item.costo, esq) +
			kv('Tiempo', segAHms(item.segundos)) +
			(item.comprable ? kv('Requisitos', 'Cumplidos', 'ok') : kv('Requisitos', 'Pendientes', 'mal')) +
			(d.enOtroPlaneta ? kv('⚠️ Laboratorio ocupado', 'Investigando en otro planeta', 'mal') : '') +
			'<div class="acciones">' +
			'<button class="btn-x pri" data-accion="techMejorar" data-id="' + item.id + '" data-nombre="' + esc(item.nombre) + '" ' + (ocupado ? 'disabled' : '') + '>🔬 Investigar ' + (item.nivel + 1) + '</button>' +
			(ocupado && d.cola[0] ? '<button class="btn-x" data-accion="techCancelar">✕ Cancelar actual</button>' : '') +
			'</div>' +
			'<p class="nota">La orden va al módulo clásico de investigación.</p>';
		pintarDetalle(html);
	}

	/* ---- IMPERIO: todos tus planetas con texturas reales ---- */
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
			texturaReal(p.imgUrl, m, true);
			m.userData = { tipo: 'imperio', item: p };
			g.add(m);
			estado.rayTargets.push(m);

			var et = etiqueta(p.nombre + ' [' + p.coords + ']', esLuna ? '#a78bfa' : '#7dd3fc', esLuna ? 0.5 : 0.72);
			et.position.set(x, esLuna ? 0.9 : 2.6, 0);
			g.add(et);
		}
		if (!lista.length) {
			var v = etiqueta('Sin planetas', '#64748b', 1.4);
			g.add(v);
		}
		estado.grupo = g;
		escena.add(g);
		camara.position.set(0, 12, Math.max(16, lista.length * 3.4));
		controls.target.set(0, 0, 0);
		pintarCola(null, 'Tus mundos: ' + lista.length + ' — clic en uno para verlo');
	}

	function detalleImperio(p) {
		var html = '<div class="x3d_dt-titulo"><img class="x3d_det-img" src="' + esc(p.imgUrl) + '" alt="" onerror="this.remove()">' + esc(p.nombre.toUpperCase()) + '</div>' +
			kv('Tipo', p.tipo === 3 ? '🌙 Luna' : '🪐 Planeta') +
			kv('Coordenadas', '[' + esc(p.coords) + ']') +
			kv('Diámetro', fmt(p.diametro) + ' km') +
			kv('Campos', p.campos.usados + ' / ' + p.campos.max) +
			kv('⛏️ Metal', fmtCorto(p.recursos.metal)) +
			kv('💎 Cristal', fmtCorto(p.recursos.cristal)) +
			kv('⛽ Deuterio', fmtCorto(p.recursos.deuterio)) +
			kv('Minas', 'M ' + p.minas.metal + ' · C ' + p.minas.cristal + ' · D ' + p.minas.deuterio) +
			kv('Hangar / Lab', p.minas.hangar + ' / ' + p.minas.laboratorio) +
			'<div class="acciones"><button class="btn-x pri" data-accion="imperioIr" data-pid="' + p.id + '">🛰 Ir a este mundo</button></div>';
		pintarDetalle(html);
	}

	/* ---- FLOTAS: tus flotas en vuelo con imágenes reales ---- */
	function construirFlotas(d) {
		var g = new THREE.Group();
		var flotas = d.flotas || [];
		var n = flotas.length || 1;
		for (var i = 0; i < flotas.length; i++) {
			var f = flotas[i];
			var ang = (i / n) * Math.PI * 2;
			var x = Math.cos(ang) * 6.5, z = Math.sin(ang) * 6.5;
			var img = (f.naves && f.naves[0]) ? f.naves[0].img : DPATH + 'gebaeude/203.gif';
			var sp = spriteElemento(img, 1.7);
			sp.position.set(x, 0.7, z);
			sp.userData = { tipo: 'flota', item: f };
			g.add(sp);
			estado.rayTargets.push(sp);
			var et = etiqueta(f.misionNombre + (f.volviendo ? ' ↩' : ' →') + ' ' + f.destino, f.volviendo ? '#a78bfa' : '#7dd3fc', 0.55);
			et.position.set(x, 1.85, z);
			g.add(et);

			// estela orbital
			var circ = [];
			for (var a = 0; a <= 64; a++) {
				var t = (a / 64) * Math.PI * 2;
				circ.push(new THREE.Vector3(Math.cos(t) * 6.5, 0.7, Math.sin(t) * 6.5));
			}
			if (i === 0) {
				g.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints(circ),
					new THREE.LineBasicMaterial({ color: 0x1e3a5f, transparent: true, opacity: 0.6 })));
			}
		}
		if (!flotas.length) {
			var v = etiqueta('No hay flotas en vuelo', '#64748b', 1.3);
			g.add(v);
		}
		estado.grupo = g;
		escena.add(g);
		camara.position.set(0, 10, 14);
		controls.target.set(0, 0, 0);

		pintarCola(flotas.map(function (f) {
			return { nombre: f.misionNombre + ' → ' + f.destino, img: (f.naves && f.naves[0]) ? f.naves[0].img : '', restante: f.volviendo ? f.regreso : f.llegada };
		}), 'Slots: ' + (d.slots ? d.slots.usados + '/' + d.slots.max : '0') + ' — sin flotas en vuelo');
	}

	function detalleFlota(f) {
		var html = '<div class="x3d_dt-titulo">' + (f.volviendo ? '↩ VOLVIENDO' : '→ EN VUELO') + ' · ' + esc(f.misionNombre.toUpperCase()) + '</div>' +
			kv('Origen', esc(f.origen)) +
			kv('Destino', esc(f.destino)) +
			kv(f.volviendo ? 'Regresa en' : 'Llega en', segAHms(f.volviendo ? f.regreso : f.llegada)) +
			kv('Naves totales', fmt(f.totalNaves));
		for (var i = 0; i < Math.min(f.naves.length, 8); i++) {
			var nv = f.naves[i];
			html += '<div class="kv"><span>' + esc(nv.nombre) + '</span><b>×' + fmt(nv.cantidad) + '</b></div>';
		}
		html += '<div class="acciones"><button class="btn-x pri" data-accion="abrirFlotas">⚓ Abrir gestión de flotas</button></div>';
		pintarDetalle(html);
	}

	/* ================= clic en la escena (raycast) ================= */
	var raycaster = new THREE.Raycaster();
	var puntero = new THREE.Vector2();
	var ultimoClic = 0;
	renderer.domElement.addEventListener('pointerdown', function (ev) {
		var ahora = Date.now();
		if (ahora - ultimoClic < 250) return; // evitar disparo tras arrastre
		ultimoClic = ahora;
		var r = renderer.domElement.getBoundingClientRect();
		puntero.x = ((ev.clientX - r.left) / r.width) * 2 - 1;
		puntero.y = -((ev.clientY - r.top) / r.height) * 2 + 1;
		raycaster.setFromCamera(puntero, camara);
		var hits = raycaster.intersectObjects(estado.rayTargets, false);
		if (!hits.length) return;
		var u = hits[0].object.userData;
		if (u.tipo === 'edificio') detalleBase(u.item);
		else if (u.tipo === 'planetaBase') detallePlanetaBase();
		else if (u.tipo === 'nave') detalleNave(u.item, u.zona);
		else if (u.tipo === 'tech') detalleTech(u.item);
		else if (u.tipo === 'imperio') detalleImperio(u.item);
		else if (u.tipo === 'flota') detalleFlota(u.item);
	});

	/* ================= ciclo ================= */
	var reloj = new THREE.Clock();
	function animar() {
		requestAnimationFrame(animar);
		var dt = reloj.getDelta();
		var t = reloj.elapsedTime;
		if (estado.grupo) {
			estado.grupo.rotation.y += dt * 0.02;
			// pulso de los pads del laboratorio
			estado.grupo.traverse(function (o) {
				if (o.geometry && o.geometry.type === 'TorusGeometry' && o.material.color) {
					o.material.opacity = 0.75 + Math.sin(t * 2 + o.position.x) * 0.2;
				}
			});
		}
		controls.update();
		renderer.render(escena, camara);
	}

	function recargarEscena() {
		cargarDatos(estado.escena, constructores[estado.escena]);
	}

	var constructores = { base: construirBase, hangar: construirHangar, lab: construirLab, imperio: construirImperio, flotas: construirFlotas };

	/* ================= dock y módulos ================= */
	document.querySelectorAll('#x3d_dock button[data-esc]').forEach(function (b) {
		b.addEventListener('click', function () {
			document.querySelectorAll('#x3d_dock button[data-esc]').forEach(function (o) { o.classList.remove('activo'); });
			b.classList.add('activo');
			var escenaNueva = b.dataset.esc;
			estado.escena = escenaNueva;
			limpiarEscena();
			cargarDatos(escenaNueva, constructores[escenaNueva]);
		});
	});

	function abrirPanel(url, titulo) {
		$('x3d_panel_tit').textContent = titulo || 'MÓDULO CLÁSICO';
		$('x3d_iframe').src = url;
		$('x3d_panel').classList.remove('x3d_oculto');
	}
	$('x3d_panel_cerrar').addEventListener('click', function () {
		$('x3d_panel').classList.add('x3d_oculto');
		$('x3d_iframe').src = 'about:blank';
	});
	$('x3d_btn_mods').addEventListener('click', function () {
		$('x3d_mods').classList.remove('x3d_oculto');
	});
	$('x3d_mods_cerrar').addEventListener('click', function () {
		$('x3d_mods').classList.add('x3d_oculto');
	});
	document.querySelectorAll('#x3d_mods .x3d_mod').forEach(function (b) {
		b.addEventListener('click', function () {
			$('x3d_mods').classList.add('x3d_oculto');
			abrirPanel(b.dataset.url, b.textContent.trim());
		});
	});

	/* ================= arranque ================= */
	redimensionar();
	animar();
	cargarDatos('base', construirBase);
})();
