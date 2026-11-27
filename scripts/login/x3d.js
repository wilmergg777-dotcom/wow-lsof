/**
 * XNOVA/AstroIO — LOGIN 3D (scripts/login/x3d.js)
 * ------------------------------------------------------------------
 * Escena 3D de la puerta de acceso: campo de estrellas + planeta
 * héroe con textura REAL del tema (styles/theme/gow/planeten/),
 * luna en órbita y planetas lejanos. Todo decorativo: el canvas va
 * DETRÁS del formulario y nunca captura eventos (pointer-events: none).
 *
 * Seguridad de fallos:
 *  - Si no hay WebGL o el canvas no existe -> el fondo clásico CSS
 *    (.login-background) sigue visible. El login NUNCA se rompe.
 *  - Si una textura no carga -> color base del planeta.
 *  - Pausa total cuando la pestaña está oculta (batería).
 */
(function () {
	'use strict';

	var canvas = document.getElementById('login3d-canvas');
	if (!canvas || typeof THREE === 'undefined') return;

	/* ---------- contexto WebGL (fallback elegante) ---------- */
	try {
		var testCtx = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
		if (!testCtx) throw new Error('sin WebGL');
	} catch (e) {
		canvas.style.display = 'none';
		return;
	}

	var basePath = 'styles/theme/gow/planeten/';
	var reduceMotion = false;
	try {
		reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
	} catch (e) {}

	var renderer;
	try {
		renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true, alpha: true });
	} catch (e) {
		canvas.style.display = 'none';
		return;
	}
	renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
	renderer.setClearColor(0x000000, 0); // transparente: deja ver el fondo CSS detrás

	var scene = new THREE.Scene();
	var camera = new THREE.PerspectiveCamera(55, 1, 0.1, 400);
	camera.position.set(0, 0.4, 9);

	/* ---------- luces ---------- */
	scene.add(new THREE.AmbientLight(0x334466, 0.9));
	var sol = new THREE.DirectionalLight(0xfff2df, 1.15);
	sol.position.set(-6, 3, 5);
	scene.add(sol);
	var relleno = new THREE.DirectionalLight(0x4488ff, 0.25);
	relleno.position.set(6, -2, 4);
	scene.add(relleno);

	/* ---------- helpers ---------- */
	function textura(nombre, colorFallback) {
		var mat = new THREE.MeshLambertMaterial({ color: colorFallback || 0x888888 });
		var tex = new THREE.TextureLoader().load(basePath + nombre, function () {
			mat.color = new THREE.Color(0xffffff); // al cargar, color natural
		});
		// Three r128: encoding sRGB para que la textura se vea con su color real
		if (THREE.sRGBEncoding !== undefined) tex.encoding = THREE.sRGBEncoding;
		tex.wrapS = THREE.RepeatWrapping;
		mat.map = tex;
		return mat;
	}

	function puntoRedondo() {
		var c = document.createElement('canvas');
		c.width = c.height = 64;
		var g = c.getContext('2d');
		var rad = g.createRadialGradient(32, 32, 0, 32, 32, 32);
		rad.addColorStop(0, 'rgba(255,255,255,1)');
		rad.addColorStop(0.4, 'rgba(255,255,255,0.8)');
		rad.addColorStop(1, 'rgba(255,255,255,0)');
		g.fillStyle = rad;
		g.fillRect(0, 0, 64, 64);
		var t = new THREE.CanvasTexture(c);
		return t;
	}

	/* ---------- campo de estrellas (2 capas) ---------- */
	function crearEstrellas(cantidad, radio, tamano, opacidad) {
		var geo = new THREE.BufferGeometry();
		var pos = new Float32Array(cantidad * 3);
		for (var i = 0; i < cantidad; i++) {
			// esfera hueca alrededor de la cámara
			var r = radio * (0.55 + Math.random() * 0.45);
			var th = Math.random() * Math.PI * 2;
			var ph = Math.acos(2 * Math.random() - 1);
			pos[i * 3] = r * Math.sin(ph) * Math.cos(th);
			pos[i * 3 + 1] = r * Math.sin(ph) * Math.sin(th) * 0.7;
			pos[i * 3 + 2] = -Math.abs(r * Math.cos(ph)) - 2; // siempre detrás
		}
		geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
		var mat = new THREE.PointsMaterial({
			size: tamano,
			map: puntoRedondo(),
			transparent: true,
			opacity: opacidad,
			depthWrite: false,
			sizeAttenuation: true
		});
		var p = new THREE.Points(geo, mat);
		scene.add(p);
		return p;
	}
	var estrellas = crearEstrellas(2600, 60, 0.55, 0.9);
	var estrellasCercanas = crearEstrellas(500, 34, 0.95, 1.0);

	/* ---------- planeta héroe (textura real) ---------- */
	var planeta = new THREE.Mesh(
		new THREE.SphereGeometry(2.35, 64, 64),
		textura('normaltempplanet03.jpg', 0x3a6ea5)
	);
	planeta.position.set(3.1, -0.5, 0);
	planeta.rotation.z = 0.18; // inclinación axial
	scene.add(planeta);

	/* atmósfera (borde aditivo) */
	var atmosfera = new THREE.Mesh(
		new THREE.SphereGeometry(2.52, 48, 48),
		new THREE.MeshBasicMaterial({
			color: 0x66aaff, transparent: true, opacity: 0.16,
			side: THREE.BackSide, blending: THREE.AdditiveBlending, depthWrite: false
		})
	);
	atmosfera.position.copy(planeta.position);
	scene.add(atmosfera);

	/* ---------- luna en órbita ---------- */
	var luna = new THREE.Mesh(
		new THREE.SphereGeometry(0.42, 32, 32),
		textura('mond.jpg', 0x999999)
	);
	scene.add(luna);
	var lunaAng = 0;

	/* ---------- planetas lejanos ---------- */
	var gasa = new THREE.Mesh(
		new THREE.SphereGeometry(1.5, 48, 48),
		textura('gasplanet05.jpg', 0xb08a55)
	);
	gasa.position.set(-6.5, -2.6, -7);
	scene.add(gasa);

	var hielo = new THREE.Mesh(
		new THREE.SphereGeometry(0.9, 40, 40),
		textura('eisplanet08.jpg', 0xaad4e8)
	);
	hielo.position.set(-3.4, 2.8, -9);
	scene.add(hielo);

	/* ---------- nebulosas sutiles (sprites) ---------- */
	function spriteNebula(color, x, y, z, escala, op) {
		var c = document.createElement('canvas');
		c.width = c.height = 256;
		var g = c.getContext('2d');
		var rad = g.createRadialGradient(128, 128, 10, 128, 128, 128);
		rad.addColorStop(0, color);
		rad.addColorStop(1, 'rgba(0,0,0,0)');
		g.fillStyle = rad;
		g.fillRect(0, 0, 256, 256);
		var sp = new THREE.Sprite(new THREE.SpriteMaterial({
			map: new THREE.CanvasTexture(c),
			transparent: true, opacity: op,
			blending: THREE.AdditiveBlending, depthWrite: false
		}));
		sp.position.set(x, y, z);
		sp.scale.set(escala, escala, 1);
		scene.add(sp);
		return sp;
	}
	spriteNebula('rgba(255,94,0,0.85)', -7, 2.5, -16, 26, 0.20);
	spriteNebula('rgba(80,120,255,0.9)', 7, 3, -18, 30, 0.16);
	spriteNebula('rgba(180,60,255,0.8)', 0, -4, -20, 22, 0.12);

	/* ---------- parallax de cámara ---------- */
	var ratonX = 0, ratonY = 0;
	document.addEventListener('mousemove', function (e) {
		ratonX = (e.clientX / window.innerWidth - 0.5) * 2;
		ratonY = (e.clientY / window.innerHeight - 0.5) * 2;
	}, { passive: true });

	/* ---------- resize ---------- */
	function redimensionar() {
		var w = window.innerWidth, h = window.innerHeight;
		renderer.setSize(w, h, false);
		camera.aspect = w / h;
		camera.updateProjectionMatrix();
	}
	window.addEventListener('resize', redimensionar);
	redimensionar();

	/* ---------- bucle (pausa si la pestaña está oculta) ---------- */
	var visible = !document.hidden;
	document.addEventListener('visibilitychange', function () {
		visible = !document.hidden;
		if (visible) reloj.then = performance.now();
	});

	var reloj = { then: performance.now() };
	function animar(ahora) {
		requestAnimationFrame(animar);
		if (!visible) return;
		var dt = Math.min((ahora - reloj.then) / 1000, 0.05);
		reloj.then = ahora;

		if (!reduceMotion) {
			planeta.rotation.y += 0.045 * dt;
			gasa.rotation.y += 0.02 * dt;
			hielo.rotation.y += 0.03 * dt;
			lunaAng += 0.25 * dt;
			luna.position.set(
				planeta.position.x + Math.cos(lunaAng) * 4.1,
				planeta.position.y + Math.sin(lunaAng * 0.6) * 0.9,
				planeta.position.z + Math.sin(lunaAng) * 4.1
			);
			estrellas.rotation.y += 0.004 * dt;
			estrellasCercanas.rotation.y -= 0.006 * dt;
		}

		// cámara: deriva suave + parallax del ratón
		var objetivoX = ratonX * 0.55;
		var objetivoY = 0.4 + ratonY * 0.35;
		camera.position.x += (objetivoX - camera.position.x) * 0.03;
		camera.position.y += (objetivoY - camera.position.y) * 0.03;
		camera.lookAt(0.4, 0, 0);

		renderer.render(scene, camera);
	}
	requestAnimationFrame(animar);
})();
