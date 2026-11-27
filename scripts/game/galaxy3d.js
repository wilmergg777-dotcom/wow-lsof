/**
 * ASTROIO — GALAXIA 3D (cliente 3D del Xnova tradicional) — rama xnova3d
 * -----------------------------------------------------------------------
 * La página de galaxia pasa a ser un visor 3D a pantalla completa.
 * El cliente 3D consume la MISMA base de datos que el juego clásico:
 *  - Datos: window.ASTRO_G3D (inyectado por page.galaxy.default.tpl desde
 *    ShowGalaxyPage::show()).
 *  - Navegación sin recargar por la API JSON del juego:
 *      game.php?page=galaxy&mode=fetch&galaxy=G&system=S
 *    (cobra deuterio igual que la vista clásica).
 *  - Acciones REALES usando las funciones estándar del juego:
 *      doit(missionID, planetID)   -> fleetAjax (scripts/game/galaxy.js):
 *                                   6 = espionaje, 8 = reciclar escombros
 *      doitAst(g, s, p)            -> fleetAjax: 32 = reciclar asteroide
 *      ?page=fleetTable&...target_mission=N -> flujo real de flotas:
 *                                   1 atacar, 3 transportar, 4 desplegar,
 *                                   5 retener, 7 COLONIZAR, 9 destruir luna,
 *                                   15 expedición, 32 asteroide
 *      Dialog.Playercard / Dialog.PM / Dialog.Buddy / OpenPopup (base.js)
 * Reglas visuales aprobadas en la maqueta (v3):
 *  - Dos tablas por defecto: GALAXIA 1-16 (posiciones del sistema) y
 *    PUNTUACIÓN (top del universo por puntos del juego). En móvil, pestañas.
 *  - Botón ♻ Reciclar SOLO si la posición tiene escombros (o asteroide 32).
 *  - Botón 🚀 Colonizar SOLO en posiciones libres (sin asteroides).
 *  - 🌙 Destruir luna SOLO si hay luna.
 */
(function () {
	'use strict';

	/* El fork carga los scripts del juego en el <head> (main.header.tpl),
	   antes de que exista el HUD. Todo el motor se inicializa en DOM ready. */
	function iniciar() {

	if (!window.THREE) {
		var cg = document.getElementById('ag3d_carga');
		if (cg) cg.innerHTML = '<div style="color:#ff4488;letter-spacing:1px">ERROR: falta scripts/game/three.min.js</div>';
		return;
	}
	if (!window.ASTRO_G3D) {
		var cg2 = document.getElementById('ag3d_carga');
		if (cg2) cg2.innerHTML = '<div style="color:#ff4488;letter-spacing:1px">ERROR: faltan datos de la galaxia (ASTRO_G3D)</div>';
		return;
	}

	var D0 = window.ASTRO_G3D;
	var MAX_G = parseInt(D0.maxGalaxy, 10) || 1;
	var MAX_S = parseInt(D0.maxSystem, 10) || 1;
	var MAX_P = parseInt(D0.maxPlanets, 10) || 15;
	var HOME = { g: parseInt(D0.curGalaxy, 10), s: parseInt(D0.curSystem, 10), p: parseInt(D0.curPlanet, 10) };
	var DPATH = (D0.dpath || 'styles/themes/gow/').replace(/\/?$/, '/');

	/* ================= ESTADOS / COLORES ================= */
	var CLASES = {
		banned: '#ff4488', vacation: '#ffaa33', longinactive: '#667788',
		inactive: '#8899aa', strong: '#ff4488', noob: '#66ff99'
	};
	function colorDe(f) {
		if (f.own) return '#4a9eff';
		var cl = f.ucl || [];
		for (var i = 0; i < cl.length; i++) if (CLASES[cl[i]]) return CLASES[cl[i]];
		return '#c9d6e8';
	}
	function nombreEstado(f) {
		if (f.own) return 'Propio';
		var cl = f.ucl || [];
		for (var i = 0; i < cl.length; i++) {
			if (D0.short && D0.short[cl[i]]) return D0.short[cl[i]];
			return cl[i];
		}
		return 'Ocupado';
	}
	var CLIMA_EMOJI = {
		despejado: '☀️', brisa_solar: '🌤️', viento_estelar: '🍃', cristalino: '✨',
		niebla: '🌫️', tormenta_solar: '⚡', meteoros: '☄️', nebulosa: '💰',
		plasma: '🌌', eclipse: '🌓', campo_mag: '🌀', aurora: '🌈',
		agujero: '🕳️', singularidad: '⚫'
	};
	function climaEmoji(c) { return CLIMA_EMOJI[c] || '🌦️'; }

	/* ================= UTILIDADES ================= */
	function mulberry32(a) {
		return function () {
			a |= 0; a = a + 0x6D2B79F5 | 0;
			var t = Math.imul(a ^ a >>> 15, 1 | a);
			t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
			return ((t ^ t >>> 14) >>> 0) / 4294967296;
		};
	}
	function fmt(n) { return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.'); }
	function fmtCorto(n) { if (n >= 1e6) return (n / 1e6).toFixed(1).replace('.0', '') + 'M'; if (n >= 1e4) return Math.round(n / 1e3) + 'K'; return fmt(n); }
	function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function (m) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[m]; }); }
	function toast(msg) {
		var box = document.getElementById('ag3d_toasts');
		if (!box) return;
		var el = document.createElement('div');
		el.className = 'ag3d_toast'; el.innerHTML = msg;
		box.appendChild(el);
		setTimeout(function () { el.classList.add('visible'); }, 10);
		setTimeout(function () { el.classList.remove('visible'); setTimeout(function () { el.remove(); }, 350); }, 2600);
	}
	function $(id) { return document.getElementById(id); }

	/* ================= ESTADO GLOBAL ================= */
	var estado = {
		g: parseInt(D0.galaxy, 10), s: parseInt(D0.system, 10),
		filas: D0.rows || [],
		sel: null,
		orden: 'pos',
		construido: null,
		focus: null,
		seguir: 0,
		score: D0.score || [],
		scoreMe: D0.scoreMe || { rank: 0, pts: 0 },
		me: D0.me || { pts: 0, rank: 0 },
		cargando: false
	};

	/* ================= ESCENA 3D ================= */
	var cont = $('ag3d_canvas');
	var escena = new THREE.Scene();
	escena.fog = new THREE.FogExp2(0x0a101e, 0.0022);
	var camara = new THREE.PerspectiveCamera(55, cont.clientWidth / Math.max(cont.clientHeight, 1), 0.1, 3000);
	camara.position.set(0, 26, 46);
	var controles = new THREE.OrbitControls(camara, cont);
	controles.enableDamping = true;
	controles.dampingFactor = 0.08;
	controles.minDistance = 12;
	controles.maxDistance = 170;
	controles.maxPolarAngle = Math.PI * 0.52;
	controles.enablePan = false;
	controles.addEventListener('start', function () { estado.seguir = 0; estado.focus = null; });

	var renderer = new THREE.WebGLRenderer({ antialias: true });
	renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
	renderer.setSize(cont.clientWidth, cont.clientHeight);
	cont.appendChild(renderer.domElement);

	escena.add(new THREE.AmbientLight(0x3a4a66, 1.0));
	var luzSol = new THREE.PointLight(0xffdd88, 1.6, 260);
	escena.add(luzSol);

	(function estrellas() {
		var n = 2600, pos = new Float32Array(n * 3);
		for (var i = 0; i < n * 3; i += 3) {
			pos[i] = (Math.random() - 0.5) * 900;
			pos[i + 1] = (Math.random() - 0.5) * 500;
			pos[i + 2] = (Math.random() - 0.5) * 900;
		}
		var geo = new THREE.BufferGeometry();
		geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
		escena.add(new THREE.Points(geo, new THREE.PointsMaterial({ color: 0xaec4e8, size: 0.6, transparent: true, opacity: 0.75 })));
	})();

	var sol = new THREE.Mesh(new THREE.SphereGeometry(3.1, 28, 22), new THREE.MeshBasicMaterial({ color: 0xffc766 }));
	escena.add(sol);

	function glow(hex, size) {
		var cv = document.createElement('canvas'); cv.width = cv.height = 64;
		var c = cv.getContext('2d');
		var h = hex.replace('#', '');
		var rgb = parseInt(h.slice(0, 2), 16) + ',' + parseInt(h.slice(2, 4), 16) + ',' + parseInt(h.slice(4, 6), 16);
		var rg = c.createRadialGradient(32, 32, 2, 32, 32, 30);
		rg.addColorStop(0, 'rgba(' + rgb + ',0.85)');
		rg.addColorStop(0.4, 'rgba(' + rgb + ',0.28)');
		rg.addColorStop(1, 'rgba(' + rgb + ',0)');
		c.fillStyle = rg; c.fillRect(0, 0, 64, 64);
		var sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(cv), transparent: true, depthWrite: false, blending: THREE.AdditiveBlending }));
		sp.scale.set(size, size, 1);
		return sp;
	}
	var corona = glow('#ffb347', 22);
	escena.add(corona);
	var nucleo = glow('#fff3d0', 7);
	escena.add(nucleo);

	function etiqueta(texto, color, escala) {
		var cv = document.createElement('canvas'); cv.width = 512; cv.height = 96;
		var c = cv.getContext('2d');
		var sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(cv), transparent: true, depthWrite: false }));
		sp.scale.set(escala * 5.3, escala, 1);
		redibujarEtiqueta(sp, texto, color);
		return sp;
	}
	function redibujarEtiqueta(sp, texto, color) {
		var cv = sp.material.map.image;
		var c = cv.getContext('2d');
		c.clearRect(0, 0, cv.width, cv.height);
		c.font = '700 34px "Segoe UI", Arial, sans-serif';
		c.textAlign = 'center'; c.textBaseline = 'middle';
		c.shadowColor = 'rgba(0,0,0,0.95)'; c.shadowBlur = 8;
		c.fillStyle = color;
		c.fillText(texto, 256, 48);
		sp.material.map.needsUpdate = true;
	}

	function texPlaneta(cA, cB, seed) {
		var cv = document.createElement('canvas'); cv.width = cv.height = 128;
		var c = cv.getContext('2d');
		var rng = mulberry32(seed);
		c.fillStyle = cB; c.fillRect(0, 0, 128, 128);
		for (var i = 0; i < 30; i++) {
			c.fillStyle = rng() < 0.5 ? cA : cB;
			c.globalAlpha = 0.22 + rng() * 0.4;
			c.fillRect(0, rng() * 128, 128, 3 + rng() * 15);
		}
		c.globalAlpha = 1;
		var g = c.createRadialGradient(46, 46, 8, 64, 64, 74);
		g.addColorStop(0, 'rgba(255,255,255,0.28)');
		g.addColorStop(0.55, 'rgba(0,0,0,0)');
		g.addColorStop(1, 'rgba(0,0,0,0.6)');
		c.fillStyle = g; c.fillRect(0, 0, 128, 128);
		return new THREE.CanvasTexture(cv);
	}

	// textura real del planeta según su imagen del juego (fallback: procedural)
	var texLoader = new THREE.TextureLoader();
	texLoader.setCrossOrigin('anonymous');
	function texturaReal(url, malla, procedural) {
		try {
			texLoader.load(url, function (tx) {
				if (malla.parent) { malla.material.map = tx; malla.material.needsUpdate = true; }
			}, undefined, function () { /* mantiene la procedural */ });
		} catch (e) { /* procedural */ }
	}

	var radioOrb = function (p) { return 8 + (p - 1) * 1.65; };
	var grupoSistema = null, objetivoSprites = [], rayTargets = [];

	// órbitas 1..MAX_P + anillo de espacio profundo (pos MAX_P+1, expediciones)
	for (var po = 1; po <= MAX_P; po++) {
		var ptsO = [];
		for (var a = 0; a <= 96; a++) {
			var angO = (a / 96) * Math.PI * 2;
			ptsO.push(new THREE.Vector3(Math.cos(angO) * radioOrb(po), 0, Math.sin(angO) * radioOrb(po)));
		}
		escena.add(new THREE.Line(
			new THREE.BufferGeometry().setFromPoints(ptsO),
			new THREE.LineBasicMaterial({ color: 0x1e3a5f, transparent: true, opacity: 0.5 })
		));
	}
	(function anilloProfundo() {
		var r = radioOrb(MAX_P) + 6, ptsD = [];
		for (var i = 0; i <= 128; i++) {
			var ang2 = (i / 128) * Math.PI * 2;
			ptsD.push(new THREE.Vector3(Math.cos(ang2) * r, 0, Math.sin(ang2) * r));
		}
		var lin = new THREE.Line(
			new THREE.BufferGeometry().setFromPoints(ptsD),
			new THREE.LineDashedMaterial({ color: 0x5b6b8c, dashSize: 1.4, gapSize: 1.0, transparent: true, opacity: 0.75 })
		);
		lin.computeLineDistances();
		escena.add(lin);
		var sp = etiqueta('🛰 ESPACIO PROFUNDO · EXPEDICIONES (' + (MAX_P + 1) + ')', '#b06cff', 2.2);
		sp.position.set(0, 3.2, r);
		sp.userData = { tipo: 'profundo' };
		escena.add(sp);
		objetivoSprites.push(sp);
	})();

	var selRing = new THREE.Mesh(
		new THREE.TorusGeometry(1.4, 0.05, 8, 44),
		new THREE.MeshBasicMaterial({ color: 0x00e0ff })
	);
	selRing.rotation.x = Math.PI / 2;
	selRing.visible = false;
	escena.add(selRing);
	var selLabel = etiqueta('', '#00e0ff', 1.6);
	selLabel.visible = false;
	escena.add(selLabel);

	/* ---------- construcción del sistema (datos reales) ---------- */
	function limpiar() {
		if (!grupoSistema) return;
		grupoSistema.traverse(function (o) {
			if (o.geometry) o.geometry.dispose();
			if (o.material) {
				if (o.material.map) o.material.map.dispose();
				o.material.dispose();
			}
		});
		escena.remove(grupoSistema);
		grupoSistema = null;
	}

	function colorTrio(hex) {
		var h = hex.replace('#', '');
		return [hex, '#' + h.slice(0, 4) + Math.round(parseInt(h.slice(4, 6), 16) * 0.25).toString(16)];
	}

	function construir() {
		limpiar();
		grupoSistema = new THREE.Group();
		objetivoSprites = [];
		rayTargets = [];
		var rng = mulberry32(estado.g * 3571 + estado.s * 101);
		for (var k = 0; k < estado.filas.length; k++) {
			var f = estado.filas[k];
			if (f.t === 'd') continue; // espacio profundo ya dibujado
			var ang = rng() * Math.PI * 2;
			var rOrb = radioOrb(f.pos);
			var grupoOrb = new THREE.Group();
			grupoOrb.userData = { fila: f, ang0: ang, rOrb: rOrb, vel: 0.05 / (0.7 + f.pos * 0.08) };
			grupoOrb.position.set(Math.cos(ang) * rOrb, 0, Math.sin(ang) * rOrb);
			grupoSistema.add(grupoOrb);
			f._grupo = grupoOrb;

			if (f.t === 'p') {
				var col = colorDe(f);
				var diaF = 8000 + ((estado.g * 7919 + estado.s * 104729 + f.pos * 137) % 11000);
				var radio = 0.45 + (diaF / 16800) * 0.75;
				var malla = new THREE.Mesh(
					new THREE.SphereGeometry(radio, 20, 16),
					new THREE.MeshStandardMaterial({ map: texPlaneta(colorTrio(col)[0], '#22314a', estado.s * 61 + f.pos), roughness: 0.85, metalness: 0.05 })
				);
				malla.userData = { tipo: 'planeta', pos: f.pos };
				grupoOrb.add(malla);
				rayTargets.push(malla);
				f._malla = malla; f._radio = radio;
				if (f.img) texturaReal(DPATH + 'planeten/small/s_' + f.img + '.jpg', malla);

				if (f.own) {
					var anilloPropio = new THREE.Mesh(
						new THREE.TorusGeometry(radio + 0.3, 0.045, 8, 40),
						new THREE.MeshBasicMaterial({ color: 0x4a9eff })
					);
					anilloPropio.rotation.x = Math.PI / 2;
					grupoOrb.add(anilloPropio);
				}
				if (f.inc === 'a') { // ataque entrante: anillo rojo pulsante + ⚔
					grupoOrb.add(anilloAlerta(radio, 0xff4488));
					var etqA = etiqueta('⚔', '#ff4488', 0.9);
					etqA.position.y = radio + 1.4;
					grupoOrb.add(etqA);
					f._pulso = grupoOrb.children[grupoOrb.children.length - 2];
				}
				if (f.luna) {
					var luna = new THREE.Mesh(
						new THREE.SphereGeometry(radio * 0.24, 12, 10),
						new THREE.MeshStandardMaterial({ color: 0xb8bcc4, roughness: 0.95 })
					);
					luna.userData = { tipo: 'luna', pos: f.pos };
					luna.userData.radioL = radio * 2.1;
					grupoOrb.add(luna);
					rayTargets.push(luna);
					f._lunaMalla = luna;
					texturaReal(DPATH + 'planeten/mond.jpg', luna);
				}
				if (f.deb) { // escombros: partículas naranjas
					grupoOrb.add(campoEscombros(rng, radio));
					var chispa = glow('#ffaa33', 3);
					grupoOrb.add(chispa);
				}
				if (f.ast) { // asteroide del sistema AsteroidHelper
					grupoOrb.add(mallaAsteroide(radio, rng));
				}
			} else if (f.t === 'r') { // ruinas
				var ruina = new THREE.Mesh(
					new THREE.SphereGeometry(0.42, 12, 10),
					new THREE.MeshStandardMaterial({ color: 0x6b7280, roughness: 1 })
				);
				ruina.scale.set(1.15, 0.5, 0.9);
				ruina.userData = { tipo: 'ruinas', pos: f.pos };
				grupoOrb.add(ruina);
				rayTargets.push(ruina);
				var cala = etiqueta('💀', '#94a3b8', 0.8);
				cala.position.y = 1.0;
				grupoOrb.add(cala);
				if (f.ast) grupoOrb.add(mallaAsteroide(0.42, rng));
			} else if (f.t === 'e' && f.ast) { // posición libre con asteroide
				var ast2 = mallaAsteroide(0.34, rng);
				ast2.userData = { tipo: 'asteroide', pos: f.pos };
				grupoOrb.add(ast2);
				rayTargets.push(ast2);
			}
		}
		escena.add(grupoSistema);
		estado.construido = estado.g + ':' + estado.s;
		pintarTabla();
		pintarScore();
		$('ag3d_tit_sistema').textContent = estado.g + ':' + estado.s;
		$('ag3d_in_g').value = estado.g;
		$('ag3d_in_s').value = estado.s;
		try {
			window.history.replaceState(null, '', 'game.php?page=galaxy&galaxy=' + estado.g + '&system=' + estado.s);
		} catch (e) { /* sin history API */ }
	}

	function anilloAlerta(radio, color) {
		var pul = new THREE.Mesh(
			new THREE.TorusGeometry(radio + 0.55, 0.06, 8, 40),
			new THREE.MeshBasicMaterial({ color: color })
		);
		pul.rotation.x = Math.PI / 2;
		return pul;
	}
	function campoEscombros(rng, radio) {
		var polvo = [];
		for (var d = 0; d < 46; d++) {
			var th = (d / 46) * Math.PI * 2;
			polvo.push(new THREE.Vector3(Math.cos(th) * (radio + 0.8 + rng() * 0.5), (rng() - 0.5) * 0.18, Math.sin(th) * (radio + 0.8 + rng() * 0.5)));
		}
		return new THREE.Points(
			new THREE.BufferGeometry().setFromPoints(polvo),
			new THREE.PointsMaterial({ color: 0xffaa33, size: 0.075, transparent: true, opacity: 0.9 })
		);
	}
	function mallaAsteroide(radioRef, rng) {
		var ast = new THREE.Mesh(
			new THREE.DodecahedronGeometry(Math.max(radioRef * 0.32, 0.3)),
			new THREE.MeshStandardMaterial({ color: 0xb08050, roughness: 1 })
		);
		ast.scale.set(1, 0.7, 0.85);
		ast.position.set(radioRef + 1.9, 0.2, 0);
		return ast;
	}

	/* ---------- animación ---------- */
	var reloj = new THREE.Clock();
	var primeraCarga = true;
	function animar() {
		requestAnimationFrame(animar);
		var dt = Math.min(reloj.getDelta(), 0.1);
		var t = reloj.elapsedTime;

		if (grupoSistema) {
			for (var k = 0; k < estado.filas.length; k++) {
				var f = estado.filas[k];
				if (!f._grupo) continue;
				var gu = f._grupo.userData;
				gu.ang0 += gu.vel * dt;
				f._grupo.position.set(Math.cos(gu.ang0) * gu.rOrb, 0, Math.sin(gu.ang0) * gu.rOrb);
				if (f._malla) { f._malla.rotation.y += 0.3 * dt; }
				if (f._lunaMalla) {
					var al = t * 0.9 + f.pos;
					f._lunaMalla.position.set(Math.cos(al) * f._lunaMalla.userData.radioL, f._radio * 0.55, Math.sin(al) * f._lunaMalla.userData.radioL);
				}
				if (f._pulso) { var s = 1 + 0.14 * Math.sin(t * 5); f._pulso.scale.set(s, s, 1); }
			}
		}
		var pc = 0.78 + 0.18 * Math.sin(t * 2.1);
		corona.material.opacity = pc;

		if (estado.sel && estado.sel._grupo && reloj.elapsedTime < (estado.seguir || 0)) {
			var pSel = new THREE.Vector3();
			estado.sel._grupo.getWorldPosition(pSel);
			pSel.y = 0.4;
			controles.target.lerp(pSel, 1 - Math.exp(-3.2 * dt));
		}
		if (estado.focus) {
			var kk = 1 - Math.exp(-3.5 * dt);
			controles.target.lerp(estado.focus.pos, kk);
			var dir = camara.position.clone().sub(controles.target);
			var dist = dir.length();
			var nueva = dist + (estado.focus.dist - dist) * kk;
			camara.position.copy(controles.target).add(dir.normalize().multiplyScalar(nueva));
			if (Math.abs(dist - estado.focus.dist) < 0.15) estado.focus = null;
		}
		controles.update();
		renderer.render(escena, camara);

		if (primeraCarga) {
			primeraCarga = false;
			setTimeout(function () {
				var c = $('ag3d_carga');
				if (c) { c.style.opacity = '0'; setTimeout(function () { if (c.parentNode) c.remove(); }, 550); }
			}, 350);
		}
	}

	/* ---------- selección ---------- */
	function seleccionar(pos) {
		var f = null;
		for (var i = 0; i < estado.filas.length; i++) if (estado.filas[i].pos === pos) f = estado.filas[i];
		if (!f) return;
		estado.sel = f;
		if (f._grupo) {
			if (selRing.parent) selRing.parent.remove(selRing);
			f._grupo.add(selRing);
			var rr = (f._radio || 0.45) + 0.35;
			selRing.scale.setScalar(rr / 1.4);
			selRing.visible = true;
			if (selLabel.parent) selLabel.parent.remove(selLabel);
			f._grupo.add(selLabel);
			var txt = f.t === 'd' ? '🛰 ESPACIO PROFUNDO' : f.t === 'r' ? '💀 Ruinas' : f.t === 'e' ? '🚀 Posición libre' : (f.name + ' · ' + f.uname);
			redibujarEtiqueta(selLabel, txt, f.t === 'd' ? '#b06cff' : colorDe(f));
			selLabel.position.set(0, (f._radio || 0.5) + 1.7, 0);
			selLabel.visible = true;
			estado.focus = { pos: f._grupo.position.clone().setY(0.4), dist: 16 };
			estado.seguir = reloj.elapsedTime + 2.8;
		}
		pintarTabla();
		pintarDetalle();
		if (window.matchMedia && matchMedia('(max-width: 900px)').matches) appEl.classList.add('det-open');
	}

	/* ---------- picking ---------- */
	var ray = new THREE.Raycaster(), mouseV = new THREE.Vector2(), downXY = null;
	renderer.domElement.addEventListener('pointerdown', function (e) { downXY = { x: e.clientX, y: e.clientY }; });
	renderer.domElement.addEventListener('pointerup', function (e) {
		if (!downXY) return;
		var dx = e.clientX - downXY.x, dy = e.clientY - downXY.y;
		downXY = null;
		if (dx * dx + dy * dy > 36) return; // fue arrastre de cámara
		var rect = renderer.domElement.getBoundingClientRect();
		mouseV.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
		mouseV.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;
		ray.setFromCamera(mouseV, camara);
		var hits = ray.intersectObjects(rayTargets.concat(objetivoSprites), false);
		if (hits.length) {
			var u = hits[0].object.userData;
			if (u.tipo === 'profundo') seleccionar(MAX_P + 1);
			else if (u.pos) seleccionar(u.pos);
		}
	});

	/* ================= TABLA 1: POSICIONES 1-16 ================= */
	function filaHTML(f, sel) {
		var cls = 'fila' + (f.own ? ' propio' : '') + (sel ? ' sel' : '') + (f.t === 'e' ? ' vacia' : '');
		if (f.t === 'd') {
			return '<tr class="' + cls + '" data-pos="' + f.pos + '">' +
				'<td class="pos">' + f.pos + '</td><td>🛰 <b style="color:#b06cff">Espacio Profundo</b></td>' +
				'<td style="color:#8fa3bf">Expediciones</td><td class="pts">—</td><td class="rk">—</td></tr>';
		}
		if (f.t === 'r') {
			return '<tr class="' + cls + '" data-pos="' + f.pos + '">' +
				'<td class="pos">' + f.pos + '</td><td>💀 <span style="color:#6b7280">Ruinas</span>' + (f.ast ? ' <span class="ico" title="Asteroide">☄️</span>' : '') + '</td>' +
				'<td style="color:#475569">—</td><td class="pts">—</td><td class="rk">—</td></tr>';
		}
		if (f.t === 'e') {
			return '<tr class="' + cls + '" data-pos="' + f.pos + '" title="Posición libre — clic para colonizar">' +
				'<td class="pos">' + f.pos + '</td><td>' + (f.ast ? '☄️ <span style="color:#b08050">Asteroides</span>' : '🚀 <span style="color:#4aff88">Libre · colonizable</span>') + '</td>' +
				'<td style="color:#475569">—</td><td class="pts">—</td><td class="rk">—</td></tr>';
		}
		var col = colorDe(f);
		var icos = (f.luna ? '<span class="ico" title="Luna">🌙</span>' : '') +
			(f.deb ? '<span class="ico" title="Escombros">♻️</span>' : '') +
			(f.ast ? '<span class="ico" title="Asteroide">☄️</span>' : '') +
			(f.inc === 'a' ? '<span class="ico" title="¡Ataque entrante!">⚔️</span>' : '') +
			(f.inc === 's' ? '<span class="ico" title="Espionaje entrante">👁️</span>' : '') +
			(f.inc === 't' ? '<span class="ico" title="Transporte entrante">📦</span>' : '') +
			(f.depo ? '<span class="ico" title="Depósito de alianza">🏦</span>' : '') +
			(f.clima ? '<span class="ico" title="Clima: ' + esc(f.clima.n) + '">' + climaEmoji(f.clima.c) + '</span>' : '');
		var dot = '<span class="dot" style="background:' + col + ';color:' + col + '" title="' + esc(nombreEstado(f)) + '"></span>';
		var tu = f.own ? '<span class="tu-chip">TÚ</span>' : '';
		var al = f.ally ? ' <span class="tag-ally">[' + esc(f.ally.tag) + ']</span>' : '';
		return '<tr class="' + cls + '" data-pos="' + f.pos + '" title="' + esc(nombreEstado(f)) + '">' +
			'<td class="pos">' + f.pos + '</td>' +
			'<td>' + dot + '<b>' + esc(f.name) + '</b>' + icos + '</td>' +
			'<td><span style="color:' + col + '">' + esc(f.uname) + '</span>' + al + tu + '</td>' +
			'<td class="pts" title="' + fmt(f.pts) + ' puntos · ' + esc(f.act || '') + '">' + fmtCorto(f.pts) + '</td>' +
			'<td class="rk">#' + (f.rank || '-') + '</td></tr>';
	}
	function pintarTabla() {
		var filas = estado.filas.slice();
		if (estado.orden === 'pts') {
			filas.sort(function (a, b) {
				var pa = a.t === 'p' ? a.pts : -1, pb = b.t === 'p' ? b.pts : -1;
				if (a.t === 'd') pa = -2; if (b.t === 'd') pb = -2;
				return pb - pa;
			});
		}
		var html = '';
		for (var i = 0; i < filas.length; i++) {
			html += filaHTML(filas[i], estado.sel && estado.sel.pos === filas[i].pos);
		}
		var tb = $('ag3d_tbody');
		tb.innerHTML = html;
		tb.querySelectorAll('tr[data-pos]').forEach(function (tr) {
			tr.addEventListener('click', function () { seleccionar(parseInt(tr.dataset.pos, 10)); });
		});
	}

	/* ================= TABLA 2: PUNTUACIÓN (top del universo) ================= */
	function pintarScore() {
		var html = '';
		estado.score.forEach(function (t) {
			html += '<tr class="fila" data-g="' + t.g + '" data-s="' + t.s + '" data-p="' + t.p + '" data-n="' + esc(t.uname) + '" title="Ir a [' + t.g + ':' + t.s + ':' + t.p + ']">' +
				'<td class="pos">#' + t.rank + '</td>' +
				'<td><span style="color:#ffa0a0">' + esc(t.uname) + '</span></td>' +
				'<td><span class="tag-ally">' + (t.ally ? '[' + esc(t.ally) + ']' : '—') + '</span></td>' +
				'<td class="pts" title="' + fmt(t.pts) + ' puntos">' + fmtCorto(t.pts) + '</td></tr>';
		});
		html += '<tr class="fila propio" id="ag3d_fila_yo" title="Ir a tu planeta [' + HOME.g + ':' + HOME.s + ':' + HOME.p + ']">' +
			'<td class="pos">#' + (estado.scoreMe.rank || '-') + '</td>' +
			'<td><span style="color:#4a9eff">' + esc(D0.meName || 'Tú') + '</span><span class="tu-chip">TÚ</span></td>' +
			'<td><span class="tag-ally">' + (D0.meAlly ? '[' + esc(D0.meAlly) + ']' : '—') + '</span></td>' +
			'<td class="pts" title="' + fmt(estado.scoreMe.pts) + ' puntos">' + fmtCorto(estado.scoreMe.pts) + '</td></tr>';
		var tbS = $('ag3d_score_tbody');
		tbS.innerHTML = html;
		tbS.querySelectorAll('tr').forEach(function (tr) {
			tr.addEventListener('click', function () {
				if (tr.id === 'ag3d_fila_yo') { irHome(); return; }
				var g = parseInt(tr.dataset.g, 10), s = parseInt(tr.dataset.s, 10), p = parseInt(tr.dataset.p, 10);
				var nombre = tr.dataset.n;
				if (g === estado.g && s === estado.s) { seleccionar(p); return; }
				irA(g, s, p);
				toast('🏆 <b>' + esc(nombre) + '</b> → [' + g + ':' + s + ':' + p + ']');
			});
		});
	}

	/* ================= PANEL DETALLE (acciones reales del juego) ================= */
	function urlFleet(pos, mission, type) {
		return 'game.php?page=fleetTable&galaxy=' + estado.g + '&system=' + estado.s + '&planet=' + pos + '&planettype=' + (type || 1) + '&target_mission=' + mission;
	}
	function pintarDetalle() {
		var f = estado.sel;
		var caja = $('ag3d_detbody');
		if (!f) {
			caja.innerHTML = '<div class="ag3d_pt-titulo">OBJETIVO</div><p class="ag3d_nota">Haz clic en un planeta de la galaxia 3D o en una fila del panel de posiciones.</p>';
			return;
		}
		var coords = '[' + estado.g + ':' + estado.s + ':' + f.pos + ']';
		var html = '<div class="ag3d_pt-titulo">OBJETIVO <span class="mono">' + coords + '</span></div>';
		if (f.t === 'd') {
			html += '<div class="kv"><span>Zona</span><b style="color:#b06cff">Espacio Profundo</b></div>' +
				'<div class="kv"><span>Tipo</span><b>Expediciones (misión 15)</b></div>' +
				'<div class="acciones"><button class="btn-accion acc-exped" data-url="' + urlFleet(f.pos, 15) + '">🛰 Expedir</button></div>';
		} else if (f.t === 'r') {
			html += '<div class="kv"><span>Estado</span><b style="color:#6b7280">Ruinas</b></div>' +
				'<div class="kv"><span>Descripción</span><b>Planeta destruido</b></div>' +
				(f.ast ? '<div class="acciones"><button class="btn-accion acc-recic" data-doitast="1">♻️ Reciclar asteroide</button></div>' : '');
		} else if (f.t === 'e') {
			html += '<div class="kv"><span>Estado</span><b style="color:#475569">Posición libre</b></div>' +
				'<div class="kv"><span>Colonizable</span><b style="color:#4aff88">' + (f.ast ? 'No · solo reciclable' : 'Sí · pos ' + f.pos) + '</b></div>' +
				(f.ast ? '<div class="kv"><span style="color:#b08050">☄️ Campo de asteroides</span><b>Reciclable</b></div>' : '') +
				'<div class="acciones">' +
				(f.ast ? '<button class="btn-accion acc-recic" data-doitast="1">♻️ Reciclar asteroide</button>'
					: '<button class="btn-accion acc-colon" data-url="' + urlFleet(f.pos, 7) + '">🚀 Colonizar</button>') +
				'</div>';
		} else {
			var col = colorDe(f);
			var ms = f.ms || [];
			function puede(m) { return ms.indexOf(m) !== -1; }
			html += '<div class="kv"><span>Planeta</span><b>' + esc(f.name) + '</b></div>' +
				'<div class="kv"><span>Jugador</span><span class="est" style="color:' + col + '">' + esc(f.uname) +
				(f.ally ? ' <span class="tag-ally">[' + esc(f.ally.tag) + ']</span>' : '') + (f.own ? ' <span class="tu-chip">TÚ</span>' : '') + '</span></div>' +
				'<div class="kv"><span>Estado</span><b class="est" style="color:' + col + '">' + esc(nombreEstado(f)) + '</b></div>' +
				'<div class="kv"><span>Puntos</span><b style="color:#fbbf24">' + fmt(f.pts) + ' · #' + (f.rank || '-') + '</b></div>' +
				(f.act ? '<div class="kv"><span>Actividad</span><b>🕒 ' + esc(f.act) + '</b></div>' : '') +
				(f.clima ? '<div class="kv"><span>Clima</span><b style="color:#00e0ff">' + climaEmoji(f.clima.c) + ' ' + esc(f.clima.n) + '</b></div>' : '') +
				(f.deb ? '<div class="kv"><span>♻️ Escombros</span><b style="color:#ffaa33">' + fmtCorto(f.deb.m) + ' M · ' + fmtCorto(f.deb.c) + ' C</b></div>' : '') +
				(f.luna ? '<div class="kv"><span>🌙 Luna</span><b>' + fmt(f.luna.dia) + ' km</b></div>' : '') +
				(f.inc === 'a' ? '<div class="kv"><span style="color:#ff4488">⚔️ ¡Ataque entrante!</span><b style="color:#ff4488">Defiende</b></div>' : '') +
				(f.inc === 's' ? '<div class="kv"><span style="color:#ffaa33">👁️ Espionaje entrante</span><b style="color:#ffaa33">—</b></div>' : '') +
				(f.inc === 't' ? '<div class="kv"><span style="color:#4a9eff">📦 Transporte entrante</span><b style="color:#4a9eff">—</b></div>' : '');

			var btns = '';
			if (f.own) {
				btns = '<button class="btn-accion acc-gestion" data-url="game.php?page=overview">🛠 Gestionar</button>' +
					'<button class="btn-accion acc-gestion" data-url="game.php?page=fleetTable">🚀 Flotas</button>';
			} else {
				if (puede(6)) btns += '<button class="btn-accion acc-espia" data-doit="6" data-pid="' + f.pid + '">🕵 Espiar</button>';
				if (puede(1)) btns += '<button class="btn-accion acc-ataca" data-url="' + urlFleet(f.pos, 1) + '">⚔ Atacar</button>';
				if (puede(3)) btns += '<button class="btn-accion acc-trans" data-url="' + urlFleet(f.pos, 3) + '">📦 Transportar</button>';
				if (puede(5)) btns += '<button class="btn-accion acc-trans" data-url="' + urlFleet(f.pos, 5) + '">🛡 Retener</button>';
				if (puede(4)) btns += '<button class="btn-accion acc-trans" data-url="' + urlFleet(f.pos, 4) + '">↔ Desplegar</button>';
				if (f.deb && puede(8)) btns += '<button class="btn-accion acc-recic" data-doit="8" data-pid="' + f.pid + '">♻ Reciclar</button>';
				if (f.ast) btns += '<button class="btn-accion acc-recic" data-doitast="1">☄️ Reciclar asteroide</button>';
				if (f.luna && puede(9)) btns += '<button class="btn-accion acc-ataca" data-url="' + urlFleet(f.pos, 9, 3) + '">🌙 Destruir luna</button>';
				if (puede(10)) btns += '<button class="btn-accion acc-ataca" data-url="game.php?page=galaxy&amp;action=sendMissle&amp;galaxy=' + estado.g + '&amp;system=' + estado.s + '&amp;planet=' + f.pos + '&amp;type=1">🚀 Misiles</button>';
				if (f.phx) btns += '<button class="btn-accion acc-espia" data-popup="game.php?page=phalanx&amp;galaxy=' + estado.g + '&amp;system=' + estado.s + '&amp;planet=' + f.pos + '&amp;planettype=1">🎯 Phalanx</button>';
				if (f.actBtns && f.actBtns.msg) btns += '<button class="btn-accion acc-gestion" data-dlg="pm" data-uid="' + f.uid + '">✉ Mensaje</button>';
				if (f.actBtns && f.actBtns.bud) btns += '<button class="btn-accion acc-gestion" data-dlg="buddy" data-uid="' + f.uid + '">🤝 Amigo</button>';
			}
			if (btns) html += '<div class="acciones">' + btns + '</div>';
			if (!f.own && f.uid) {
				html += '<p class="ag3d_nota"><a href="#" data-dlg="pc" data-uid="' + f.uid + '">👤 Ver ficha del jugador</a>' +
					' · <a href="game.php?page=statistics&amp;who=1&amp;start=' + (f.rank || 1) + '">📊 Ver en estadísticas</a>' +
					(f.ally && f.ally.id ? ' · <a href="game.php?page=alliance&amp;mode=info&amp;id=' + f.ally.id + '">🛡 Alianza</a>' : '') + '</p>';
			}
		}
		caja.innerHTML = html;
		caja.querySelectorAll('[data-doit]').forEach(function (b) {
			b.addEventListener('click', function () {
				if (typeof window.doit === 'function') window.doit(parseInt(b.dataset.doit, 10), parseInt(b.dataset.pid, 10));
				else toast('Falta scripts/game/galaxy.js', false);
			});
		});
		caja.querySelectorAll('[data-doitast]').forEach(function (b) {
			b.addEventListener('click', function () {
				if (typeof window.doitAst === 'function') window.doitAst(estado.g, estado.s, estado.sel.pos);
				else toast('Falta scripts/game/galaxy.js', false);
			});
		});
		caja.querySelectorAll('[data-url]').forEach(function (b) {
			b.addEventListener('click', function () { window.location.href = b.dataset.url; });
		});
		caja.querySelectorAll('[data-popup]').forEach(function (b) {
			b.addEventListener('click', function (ev) {
				ev.preventDefault();
				if (typeof window.OpenPopup === 'function') window.OpenPopup(b.dataset.popup, '', 640, 510);
				else window.open(b.dataset.popup, 'phalanx', 'width=640,height=510');
			});
		});
		caja.querySelectorAll('[data-dlg]').forEach(function (b) {
			b.addEventListener('click', function (ev) {
				ev.preventDefault();
				var uid = parseInt(b.dataset.uid, 10);
				var k = b.dataset.dlg;
				if (k === 'pm' && window.Dialog && Dialog.PM) Dialog.PM(uid);
				else if (k === 'buddy' && window.Dialog && Dialog.Buddy) Dialog.Buddy(uid);
				else if (k === 'pc' && window.Dialog && Dialog.Playercard) Dialog.Playercard(uid);
				else toast('Diálogo no disponible en este tema', false);
			});
		});
	}

	/* ================= NAVEGACIÓN POR LA API (fetch JSON) ================= */
	function resetCamara() {
		camara.position.set(0, 26, 46);
		controles.target.set(0, 0, 0);
		estado.focus = null;
	}
	function irA(g, s, selPos) {
		if (estado.cargando) return;
		g = Math.min(MAX_G, Math.max(1, parseInt(g, 10) || estado.g));
		s = Math.min(MAX_S, Math.max(1, parseInt(s, 10) || estado.s));
		if (g === estado.g && s === estado.s) {
			if (selPos) seleccionar(selPos);
			return;
		}
		estado.cargando = true;
		toast('📡 Sistema <b>' + g + ':' + s + '</b>…');
		jQuery.getJSON('game.php?page=galaxy&mode=fetch&galaxy=' + g + '&system=' + s, function (d) {
			estado.cargando = false;
			if (!d || d.ok !== true) {
				toast((d && d.err ? d.err : 'Error al consultar la galaxia') + ' — volviendo a [' + estado.g + ':' + estado.s + ']', false);
				return;
			}
			estado.g = parseInt(d.galaxy, 10); estado.s = parseInt(d.system, 10);
			estado.filas = d.rows || [];
			if (d.score) estado.score = d.score;
			if (d.scoreMe) estado.scoreMe = d.scoreMe;
			estado.sel = null;
			selRing.visible = false;
			construir();
			resetCamara();
			pintarDetalle();
			if (selPos) seleccionar(selPos);
		}).fail(function () {
			estado.cargando = false;
			toast('Error de conexión con la galaxia', false);
		});
	}
	function ir() { irA($('ag3d_in_g').value, $('ag3d_in_s').value); }
	function pasoSistema(d) {
		var g = estado.g, s = estado.s + d;
		if (s > MAX_S) { s = 1; g = g >= MAX_G ? 1 : g + 1; }
		if (s < 1) { s = MAX_S; g = g <= 1 ? MAX_G : g - 1; }
		irA(g, s);
	}
	function pasoGalaxia(d) {
		var g = estado.g + d;
		if (g > MAX_G) g = 1;
		if (g < 1) g = MAX_G;
		irA(g, estado.s);
	}
	function irHome() {
		if (estado.g === HOME.g && estado.s === HOME.s) {
			var posPropia = HOME.p;
			for (var i = 0; i < estado.filas.length; i++) if (estado.filas[i].own) posPropia = estado.filas[i].pos;
			seleccionar(posPropia);
			toast('🏠 Tu planeta <b>[' + HOME.g + ':' + HOME.s + ':' + posPropia + ']</b>');
			return;
		}
		irA(HOME.g, HOME.s, HOME.p);
		toast('🏠 Volviendo a tu planeta <b>[' + HOME.g + ':' + HOME.s + ':' + HOME.p + ']</b>');
	}

	var appEl = $('ag3d_app');
	$('ag3d_gm').addEventListener('click', function () { pasoGalaxia(-1); });
	$('ag3d_gp').addEventListener('click', function () { pasoGalaxia(1); });
	$('ag3d_sm').addEventListener('click', function () { pasoSistema(-1); });
	$('ag3d_sp').addEventListener('click', function () { pasoSistema(1); });
	$('ag3d_ir').addEventListener('click', ir);
	$('ag3d_in_s').addEventListener('keydown', function (e) { if (e.key === 'Enter') ir(); });
	$('ag3d_in_g').addEventListener('keydown', function (e) { if (e.key === 'Enter') ir(); });
	$('ag3d_home').addEventListener('click', irHome);
	// selector de vista: saltar a la tabla clásica conservando galaxia:sistema
	$('ag3d_clasico').addEventListener('click', function () {
		window.location.href = 'game.php?page=galaxy&vista=clasico&galaxy=' + estado.g + '&system=' + estado.s;
	});
	$('ag3d_ord_pos').addEventListener('click', function () {
		estado.orden = 'pos';
		this.classList.add('activo'); $('ag3d_ord_pts').classList.remove('activo');
		pintarTabla();
	});
	$('ag3d_ord_pts').addEventListener('click', function () {
		estado.orden = 'pts';
		this.classList.add('activo'); $('ag3d_ord_pos').classList.remove('activo');
		pintarTabla();
	});
	// móvil: pestañas para cambiar entre la tabla de galaxia y la de puntuación
	$('ag3d_tab_gal').addEventListener('click', function () {
		appEl.classList.remove('score-mv');
		this.classList.add('activo'); $('ag3d_tab_score').classList.remove('activo');
	});
	$('ag3d_tab_score').addEventListener('click', function () {
		appEl.classList.add('score-mv');
		this.classList.add('activo'); $('ag3d_tab_gal').classList.remove('activo');
	});
	$('ag3d_tgl_pos').addEventListener('click', function () { appEl.classList.toggle('pos-off'); });
	$('ag3d_tgl_det').addEventListener('click', function () { appEl.classList.toggle('det-open'); });
	$('ag3d_back').addEventListener('click', function () { appEl.classList.remove('det-open'); });

	window.addEventListener('keydown', function (e) {
		var tag = (document.activeElement && document.activeElement.tagName) || '';
		if (tag === 'INPUT' || tag === 'TEXTAREA') return;
		if (e.key === 'ArrowLeft') pasoSistema(-1);
		else if (e.key === 'ArrowRight') pasoSistema(1);
		else if (e.key === 'ArrowUp') { e.preventDefault(); pasoGalaxia(-1); }
		else if (e.key === 'ArrowDown') { e.preventDefault(); pasoGalaxia(1); }
	});

	window.addEventListener('resize', function () {
		var w = cont.clientWidth, h = Math.max(cont.clientHeight, 1);
		camara.aspect = w / h;
		camara.updateProjectionMatrix();
		renderer.setSize(w, h);
	});

	/* ================= ARRANQUE ================= */
	construir();
	pintarDetalle();
	pintarScore();
	animar();
	(function () {
		var posPropia = HOME.p;
		for (var i = 0; i < estado.filas.length; i++) if (estado.filas[i].own) posPropia = estado.filas[i].pos;
		seleccionar(posPropia);
	})();
	if (window.matchMedia && matchMedia('(max-width: 900px)').matches) appEl.classList.remove('det-open');

	}

	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', iniciar);
	} else {
		iniciar();
	}

})();
