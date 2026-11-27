/**
 * XNOVA3D (rama xnova3d) — NÚCLEO del escritorio 3D
 * ==================================================
 * Este archivo SOLO contiene la carcasa común de la app:
 *   · renderer / cámara / controles / estrellas / luces
 *   · texturas REALES del juego (caché) y etiquetas
 *   · carga de datos (game.php?page=x3d&mode=fetch&modo=...)
 *   · helpers de UI (detalle, cola, toasts, cuentas atrás)
 *   · acciones POST genéricas al juego clásico
 *   · registro de módulos y ciclo de animación
 *
 * LOS MÓDULOS VIVEN EN SU PROPIO ARCHIVO y se registran:
 *   x3d/base.js     → X3D.registrar('base',    {...})
 *   x3d/hangar.js   → X3D.registrar('hangar',  {...})
 *   x3d/lab.js      → X3D.registrar('lab',     {...})
 *   x3d/imperio.js  → X3D.registrar('imperio', {...})
 *   x3d/flotas.js   → X3D.registrar('flotas',  {...})
 *
 * Regla modular: para corregir una escena toca SOLO su archivo;
 * el núcleo no sabe nada de edificios, naves o investigaciones.
 */
window.X3D = (function () {
	'use strict';

	var D0 = window.X3D_DATA || {};
	var DPATH = window.X3D_DPATH || D0.dpath || './styles/theme/gow/';
	var modulos = {}; // registro de escenas por módulo

	/* ================= helpers de UI ================= */
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
		if (!caja) return;
		var el = document.createElement('div');
		el.className = 'x3d_toast' + (mal ? ' mal' : '');
		el.innerHTML = html;
		caja.appendChild(el);
		setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 3400);
	}
	function mostrarCarga(txt) {
		var c = $('x3d_carga');
		if (!c) return;
		c.style.display = 'flex';
		var d = c.querySelector('div:last-child');
		if (d) d.textContent = txt || 'CARGANDO XNOVA 3D…';
	}
	function ocultarCarga() { var c = $('x3d_carga'); if (c) c.style.display = 'none'; }

	if (!window.THREE) {
		var avisoTHREE = function () {
			var c = document.getElementById('x3d_carga');
			if (c) c.innerHTML = '<div style="color:#ff4488;letter-spacing:1px">ERROR: falta scripts/game/three.min.js</div>';
		};
		if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', avisoTHREE);
		else avisoTHREE();
		return {};
	}

	/* ================= THREE: escena común (SIN tocar el DOM) =================
	   Los scripts del juego se cargan en el HEADER (antes del body): aquí
	   solo se crean la escena, la cámara y las luces. El RENDERER y los
	   CONTROLES necesitan el canvas (#x3d_canvas) y se preparan en
	   prepararDOM(), que arranca cuando la plantilla llama a X3D.iniciar()
	   al final del body. */
	var cont = null, renderer = null, controls = null, listo = false;

	var escena = new THREE.Scene();
	escena.background = new THREE.Color(0x05080f);

	var camara = new THREE.PerspectiveCamera(55, 1, 0.1, 600);
	camara.position.set(0, 8, 15);

	escena.add(new THREE.AmbientLight(0x8fa3bf, 1.15));
	var luzSol = new THREE.PointLight(0xffdd88, 1.5, 400);
	luzSol.position.set(30, 22, 18);
	escena.add(luzSol);

	function redimensionar() {
		if (!renderer || !cont) return;
		var w = cont.clientWidth, h = cont.clientHeight;
		if (w === 0 || h === 0) return;
		renderer.setSize(w, h);
		camara.aspect = w / h;
		camara.updateProjectionMatrix();
	}

	function prepararDOM() {
		if (listo) return;
		listo = true;

		cont = $('x3d_canvas');
		renderer = new THREE.WebGLRenderer({ antialias: true });
		renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
		if (cont) cont.appendChild(renderer.domElement);

		controls = new THREE.OrbitControls(camara, renderer.domElement);
		controls.enableDamping = true;
		controls.dampingFactor = 0.08;
		controls.minDistance = 4;
		controls.maxDistance = 90;

		window.addEventListener('resize', redimensionar);
		redimensionar();

		enlazarRaycast();
	}

	// campo de estrellas (carcasa, común a todas las escenas)
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

	/* ================= estado de la app ================= */
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

	/* ================= datos (fetch JSON del juego) ================= */
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

	/* recuento de recursos para pintar ok/mal en costos */
	function hayPara(costo, esq) {
		if (!esq) return true;
		return costo.metal <= esq.recursos.metal.val && costo.cristal <= esq.recursos.cristal.val && costo.deuterio <= esq.recursos.deuterio.val;
	}

	/* ================= ACCIONES POST (juego clásico) ================= */
	function postJuego(url, params, luego) {
		var cuerpo = new URLSearchParams();
		Object.keys(params).forEach(function (k) { cuerpo.append(k, params[k]); });
		fetch(url, { method: 'POST', body: cuerpo, credentials: 'same-origin' })
			.then(function () { return luego(); })
			.catch(function () { toast('⚠️ Error de red al enviar la orden', true); });
	}

	/* construir naves/defensas: fmenge[id]=cantidad (array POST real) */
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

	/* cambiar de mundo (Overview clásico) */
	function imperioIr(pid) {
		window.location.href = 'game.php?page=overview&cp=' + pid;
	}

	/* abrir un módulo clásico como panel dentro del 3D */
	function abrirPanel(url, titulo) {
		$('x3d_panel_tit').textContent = titulo || 'MÓDULO CLÁSICO';
		$('x3d_iframe').src = url;
		$('x3d_panel').classList.remove('x3d_oculto');
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
	/* pintar el panel + enlazar botones [data-accion] al mapa de acciones
	   del módulo que llama (cada escena define sus propias acciones) */
	function pintarDetalle(html, mapaAcciones) {
		var det = $('x3d_det');
		det.innerHTML = html;
		det.querySelectorAll('[data-accion]').forEach(function (b) {
			var fn = mapaAcciones && mapaAcciones[b.dataset.accion];
			if (fn) b.addEventListener('click', function () { fn(b.dataset); });
		});
	}

	/* ================= COLA (tira inferior) ================= */
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
	/* items: [{nombre, nivel?, cantidad?, img?, restante?, cancelIdx?, zona?}]
	   alCancelar(item): callback del módulo para su botón ✕ (opcional) */
	function pintarCola(items, etiquetaVacia, alCancelar) {
		var caja = $('x3d_cola');
		if (!items || !items.length) {
			caja.innerHTML = '<span class="x3d_cola-vacia">' + etiquetaVacia + '</span>';
			iniciarCuentas();
			return;
		}
		var html = '';
		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			html += '<div class="x3d_cola-item">' +
				(it.img ? '<img src="' + it.img + '" alt="" onerror="this.style.display=\'none\'">' : '') +
				'<span class="n">' + esc(it.nombre) + (it.nivel ? ' ' + it.nivel : '') + (it.cantidad ? ' ×' + fmt(it.cantidad) : '') + '</span>' +
				(it.restante != null ? '<span class="t" data-seg="' + it.restante + '">' + segAHms(it.restante) + '</span>' : '') +
				(it.cancelIdx != null ? '<button class="cancelar" title="Cancelar" data-ci="' + it.cancelIdx + '">✕</button>' : '') +
				'</div>';
		}
		caja.innerHTML = html;
		caja.querySelectorAll('.cancelar').forEach(function (b) {
			if (alCancelar) {
				var idx = parseInt(b.dataset.ci, 10);
				b.addEventListener('click', function () { alCancelar(items[idx] || { cancelIdx: idx }); });
			}
		});
		iniciarCuentas();
	}

	/* ================= registro de módulos ================= */
	function registrar(nombre, modulo) {
		modulos[nombre] = modulo;
	}
	function recargarEscena() {
		var mod = modulos[estado.escena];
		if (mod && mod.construir) cargarDatos(estado.escena, mod.construir);
	}

	/* ================= clic en la escena (raycast → módulo activo) =================
	   Se enlaza en prepararDOM() porque necesita el canvas ya creado. */
	var raycaster = new THREE.Raycaster();
	var puntero = new THREE.Vector2();
	var ultimoClic = 0;
	function enlazarRaycast() {
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
			var mod = modulos[estado.escena];
			if (mod && mod.alClic) mod.alClic(hits[0].object.userData);
		});
	}

	/* ================= ciclo de animación ================= */
	var reloj = new THREE.Clock();
	var animando = false;
	function animar() {
		if (animando) return;
		animando = true;
		(function ciclo() {
			requestAnimationFrame(ciclo);
			var dt = reloj.getDelta();
			var t = reloj.elapsedTime;
			if (estado.grupo) {
				estado.grupo.rotation.y += dt * 0.02;
				estado.grupo.traverse(function (o) {
					if (o.geometry && o.geometry.type === 'TorusGeometry' && o.material.color) {
						o.material.opacity = 0.75 + Math.sin(t * 2 + o.position.x) * 0.2;
					}
				});
			}
			controls.update();
			renderer.render(escena, camara);
		})();
	}

	/* ================= arranque (lo llama la plantilla) ================= */
	function iniciar() {
		prepararDOM();

		document.querySelectorAll('#x3d_dock button[data-esc]').forEach(function (b) {
			b.addEventListener('click', function () {
				document.querySelectorAll('#x3d_dock button[data-esc]').forEach(function (o) { o.classList.remove('activo'); });
				b.classList.add('activo');
				estado.escena = b.dataset.esc;
				limpiarEscena();
				var mod = modulos[estado.escena];
				if (mod && mod.construir) cargarDatos(estado.escena, mod.construir);
				else toast('⚠️ Módulo <b>' + esc(estado.escena) + '</b> no registrado', true);
			});
		});

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

		redimensionar();
		animar();
		var mod = modulos[estado.escena];
		if (mod && mod.construir) cargarDatos(estado.escena, mod.construir);
		else ocultarCarga();
	}

	/* ================= API pública para los módulos ================= */
	return {
		// arranque y registro
		registrar: registrar,
		iniciar: iniciar,
		// THREE (las escenas pueden añadir objetos)
		escena: escena,
		camara: camara,
		controls: controls,
		estado: estado,
		limpiarEscena: limpiarEscena,
		// imágenes reales del juego
		DPATH: DPATH,
		texturaReal: texturaReal,
		etiqueta: etiqueta,
		spriteElemento: spriteElemento,
		// datos y recursos
		cargarDatos: cargarDatos,
		recargarEscena: recargarEscena,
		hayPara: hayPara,
		// UI compartida
		fmt: fmt,
		fmtCorto: fmtCorto,
		segAHms: segAHms,
		esc: esc,
		toast: toast,
		kv: kv,
		costoHTML: costoHTML,
		pintarDetalle: pintarDetalle,
		pintarCola: pintarCola,
		// acciones clásicas reales
		postJuego: postJuego,
		construirNaves: construirNaves,
		cancelarHangar: cancelarHangar,
		imperioIr: imperioIr,
		abrirPanel: abrirPanel
	};
})();
