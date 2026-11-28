/**
 * XNOVA3D — FÁBRICA DE MODELOS 3D REALES (geometria.js)
 * ======================================================
 * Los dibujos del juego (gebaeude/{id}.gif) son la IDEA; aquí se
 * construyen como OBJETOS 3D DE VERDAD: cascos con volumen, torres,
 * ruedas que giran, núcleos que pulsan, motores con brillo.
 * NADA de imágenes planas: el sprite (spriteElemento) queda solo como
 * reserva si este archivo no carga.
 *
 * Clasificación por NOMBRE (los nombres reales de $LNG['tech']) con
 * respaldo por ID estándar y genéricos variados por hash.
 * API para los módulos:
 *   X3D.modeloEdificio(id, nombre, escala)  → THREE.Group
 *   X3D.modeloNave(id, nombre, escala)      → THREE.Group
 *   X3D.modeloInvestigacion(id, nombre, esc)→ THREE.Group
 *   X3D.modeloDefensa(id, nombre, escala)   → THREE.Group
 * Los modelos se registran sobre X3D (cargado antes que los módulos).
 */
(function () {
	'use strict';
	var X = window.X3D;
	if (!X || !window.THREE) return;

	/* ================= materiales compartidos ================= */
	var M = {
		metal:   new THREE.MeshStandardMaterial({ color: 0x9fb2c8, metalness: 0.85, roughness: 0.35 }),
		oscura:  new THREE.MeshStandardMaterial({ color: 0x2b3a52, metalness: 0.7,  roughness: 0.5 }),
		piedra:  new THREE.MeshStandardMaterial({ color: 0x51607a, metalness: 0.3,  roughness: 0.85 }),
		cian:    new THREE.MeshStandardMaterial({ color: 0x0f2a44, emissive: 0x35d5ff, emissiveIntensity: 0.9, roughness: 0.4 }),
		naranja: new THREE.MeshStandardMaterial({ color: 0x3a1f0d, emissive: 0xff8c2a, emissiveIntensity: 1.0 }),
		verde:   new THREE.MeshStandardMaterial({ color: 0x0d2a1a, emissive: 0x35ff8f, emissiveIntensity: 0.9 }),
		violeta: new THREE.MeshStandardMaterial({ color: 0x2a1040, emissive: 0xa78bfa, emissiveIntensity: 0.9 }),
		cristal: new THREE.MeshStandardMaterial({ color: 0x7fd8ff, emissive: 0x49c9ff, emissiveIntensity: 0.55, metalness: 0.2, roughness: 0.15, transparent: true, opacity: 0.85 }),
		agua:    new THREE.MeshStandardMaterial({ color: 0x1450aa, emissive: 0x0a2f77, emissiveIntensity: 0.45, metalness: 0.3, roughness: 0.25 }),
		panel:   new THREE.MeshStandardMaterial({ color: 0x1c3c66, emissive: 0x1f6fd6, emissiveIntensity: 0.5, metalness: 0.6, roughness: 0.3, side: THREE.DoubleSide })
	};

	/* ============ primitivas cortas (todo en unidades ~1) ============ */
	function box(w, h, d, m)      { return new THREE.Mesh(new THREE.BoxGeometry(w, h, d), m || M.metal); }
	function cyl(rt, rb, h, m, s) { return new THREE.Mesh(new THREE.CylinderGeometry(rt, rb, h, s || 18), m || M.metal); }
	function cone(r, h, m, s)     { return new THREE.Mesh(new THREE.ConeGeometry(r, h, s || 16), m || M.metal); }
	function sph(r, m, s)         { return new THREE.Mesh(new THREE.SphereGeometry(r, s || 20, 14), m || M.metal); }
	function tor(r, tub, m)       { return new THREE.Mesh(new THREE.TorusGeometry(r, tub, 10, 32), m || M.metal); }
	function plaza(d)             { var p = cyl(d, d * 1.08, 0.12, M.oscura, 26); return p; } // plataforma

	/* engloba todo el grupo en una caja invisible para el clic (raycast) */
	function hitbox(g, radio) {
		var hb = sph(radio, new THREE.MeshBasicMaterial({ visible: false }), 8);
		hb.position.y = radio * 0.85;
		g.add(hb);
		return g;
	}

	function variar(id) { // variación determinista por id (genéricos distintos)
		return ((id * 2654435761) % 100) / 100;
	}

	/* ================= EDIFICIOS ================= */

	// mina con dos torres y rueda que gira (idea: gebaeude/1.gif)
	function minaMetal() {
		var g = new THREE.Group();
		g.add(plaza(1.35));
		var base = box(1.5, 0.28, 1.0, M.oscura); base.position.y = 0.3; g.add(base);
		for (var i = -1; i <= 1; i += 2) {
			var torre = cyl(0.09, 0.14, 1.25, M.metal); torre.position.set(i * 0.5, 0.95, 0); torre.rotation.z = i * 0.12; g.add(torre);
			var rueda = tor(0.34, 0.05, M.naranja); rueda.position.set(i * 0.66, 1.55, 0.25); rueda.rotation.y = Math.PI / 2; g.add(rueda);
			X.alTick(function (dt, t) { rueda.rotation.x += dt * 2.2; });
		}
		var cinta = box(1.15, 0.1, 0.3, M.oscura); cinta.position.set(0, 0.62, 0.55); g.add(cinta);
		var pila = new THREE.Mesh(new THREE.DodecahedronGeometry(0.3), M.piedra); pila.position.set(0.45, 0.5, 0.62); g.add(pila);
		return hitbox(g, 1.05);
	}

	// racimo de cristales luminosos (idea: gebaeude/2.gif)
	function minaCristal() {
		var g = new THREE.Group();
		g.add(plaza(1.3));
		var roca = cyl(0.8, 1.0, 0.35, M.piedra, 20); roca.position.y = 0.2; g.add(roca);
		var tilts = [[0, 0.9, 0], [0.45, 0.55, 0.18], [-0.42, 0.6, -0.15], [0.12, 0.4, 0.42], [-0.15, 0.35, -0.4]];
		for (var i = 0; i < tilts.length; i++) {
			var h = 0.55 + (i === 0 ? 0.75 : 0.3 * variar(i + 3));
			var c = cone(0.16 + 0.1 * variar(i + 7), h, M.cristal, 6);
			c.position.set(tilts[i][0], 0.35 + h / 2, tilts[i][2]);
			c.rotation.set(tilts[i][1] * 0.4, 0, i % 2 ? 0.35 : -0.35);
			g.add(c);
		}
		return hitbox(g, 1.0);
	}

	// sintetizador con tanques y tubos (idea: gebaeude/3.gif)
	function sinteDeuterio() {
		var g = new THREE.Group();
		g.add(plaza(1.3));
		var lag = cyl(1.05, 1.1, 0.06, M.agua, 24); lag.position.y = 0.08; g.add(lag);
		for (var i = 0; i < 3; i++) {
			var x = (i - 1) * 0.62;
			var tanque = cyl(0.3, 0.3, 0.95, M.metal, 20); tanque.position.set(x, 0.62, 0); g.add(tanque);
			var cúp = sph(0.3, M.cian); cúp.scale.y = 0.7; cúp.position.set(x, 1.16, 0); g.add(cúp);
			var nivel = cyl(0.24, 0.24, 0.5, M.agua, 16); nivel.position.set(x, 0.5, 0); g.add(nivel);
			var tubo = cyl(0.06, 0.06, 1.25, M.oscura, 10); tubo.rotation.z = Math.PI / 2; tubo.position.set(x, 0.95, 0.3); g.add(tubo);
		}
		return hitbox(g, 1.0);
	}

	// campo de paneles inclinados (idea: gebaeude/4.gif)
	function plantaSolar() {
		var g = new THREE.Group();
		g.add(plaza(1.4));
		for (var f = 0; f < 2; f++) {
			for (var c = 0; c < 3; c++) {
				var palo = cyl(0.05, 0.05, 0.42, M.oscura, 8); palo.position.set((c - 1) * 0.72, 0.36, (f - 0.5) * 0.7); g.add(palo);
				var panel = box(0.62, 0.04, 0.5, M.panel); panel.position.set((c - 1) * 0.72, 0.62, (f - 0.5) * 0.7); panel.rotation.x = -0.5; g.add(panel);
			}
		}
		var torre = cyl(0.07, 0.09, 1.05, M.metal, 10); torre.position.set(-0.85, 0.62, -0.55); g.add(torre);
		var foco = sph(0.12, M.verde); foco.position.set(-0.85, 1.2, -0.55); g.add(foco);
		return hitbox(g, 1.1);
	}

	// reactor de fusión con núcleo pulsante (idea: gebaeude/5.gif)
	function fusion() {
		var g = new THREE.Group();
		g.add(plaza(1.2));
		var pedestal = cyl(0.55, 0.75, 0.5, M.oscura, 20); pedestal.position.y = 0.4; g.add(pedestal);
		var nucleo = sph(0.42, M.naranja, 26); nucleo.position.y = 1.25; g.add(nucleo);
		var a1 = tor(0.62, 0.07, M.metal); a1.position.y = 1.25; g.add(a1);
		var a2 = tor(0.62, 0.07, M.metal); a2.position.y = 1.25; a2.rotation.y = Math.PI / 2; g.add(a2);
		X.alTick(function (dt, t) {
			var p = 0.9 + Math.sin(t * 3.2) * 0.35;
			a1.rotation.x += dt * 1.4; a2.rotation.z += dt * 1.1;
			nucleo.material.emissiveIntensity = p;
			nucleo.scale.setScalar(1 + Math.sin(t * 3.2) * 0.05);
		});
		return hitbox(g, 0.95);
	}

	// fábrica / hangar: nave industrial con brazo (idea: gebaeude/6 y 7.gif)
	function fabrica() {
		var g = new THREE.Group();
		g.add(plaza(1.4));
		var nave = box(1.5, 0.75, 1.0, M.metal); nave.position.y = 0.52; g.add(nave);
		var techo = cyl(0.5, 0.5, 1.5, M.oscura, 22); techo.rotation.z = Math.PI / 2; techo.position.y = 0.9; g.add(techo);
		var puerta = box(0.45, 0.5, 0.06, M.cian); puerta.position.set(0, 0.4, 0.52); g.add(puerta);
		var riel = box(1.2, 0.08, 0.08, M.oscura); riel.position.set(0, 1.28, 0.32); g.add(riel);
		var brazo = cyl(0.05, 0.05, 0.5, M.metal, 8); brazo.position.set(0, 1.1, 0.32);
		var garra = box(0.16, 0.16, 0.16, M.naranja); garra.position.y = -0.3; brazo.add(garra);
		g.add(brazo);
		X.alTick(function (dt, t) { brazo.rotation.z = Math.sin(t * 0.9) * 0.5; });
		return hitbox(g, 1.05);
	}

	// laboratorio: cúpula + antena (idea: gebaeude/31.gif)
	function laboratorio() {
		var g = new THREE.Group();
		g.add(plaza(1.25));
		var cuerpo = cyl(0.55, 0.65, 0.6, M.metal, 22); cuerpo.position.y = 0.45; g.add(cuerpo);
		var cupula = new THREE.Mesh(new THREE.SphereGeometry(0.55, 24, 14, 0, Math.PI * 2, 0, Math.PI / 2), M.cristal); cupula.position.y = 0.75; g.add(cupula);
		var antena = cyl(0.045, 0.045, 0.85, M.metal, 8); antena.position.set(0.32, 1.35, 0); g.add(antena);
		var baliza = sph(0.09, M.cian); baliza.position.set(0.32, 1.8, 0); g.add(baliza);
		X.alTick(function (dt, t) { baliza.material.emissiveIntensity = 0.6 + Math.sin(t * 4) * 0.4; });
		return hitbox(g, 0.95);
	}

	// almacén de silos (idea: gebaeude/8-10.gif)
	function almacen() {
		var g = new THREE.Group();
		g.add(plaza(1.3));
		for (var i = 0; i < 3; i++) {
			var x = (i - 1) * 0.66;
			var silo = cyl(0.34, 0.34, 1.0, M.metal, 18); silo.position.set(x, 0.62, 0); g.add(silo);
			var tapa = sph(0.34, M.oscura); tapa.scale.y = 0.5; tapa.position.set(x, 1.12, 0); g.add(tapa);
			var anillo = tor(0.36, 0.035, M.cian); anillo.rotation.x = Math.PI / 2; anillo.position.set(x, 0.42, 0); g.add(anillo);
		}
		return hitbox(g, 1.0);
	}

	// plataforma circular + torre (terraformer / base lunar / deposito)
	function plataforma() {
		var g = new THREE.Group();
		g.add(plaza(1.45));
		var anillo = tor(0.95, 0.08, M.metal); anillo.rotation.x = Math.PI / 2; anillo.position.y = 0.16; g.add(anillo);
		var torre = cyl(0.14, 0.2, 1.1, M.metal, 14); torre.position.y = 0.66; g.add(torre);
		var disco = cyl(0.34, 0.2, 0.16, M.cian, 18); disco.position.y = 1.28; g.add(disco);
		return hitbox(g, 1.05);
	}

	// silo de misiles (idea: gebaeude/44.gif)
	function siloMisiles() {
		var g = new THREE.Group();
		g.add(plaza(1.1));
		var fosa = box(1.0, 0.3, 1.0, M.oscura); fosa.position.y = 0.2; g.add(fosa);
		var misil = cyl(0.14, 0.14, 0.9, M.metal, 14); misil.position.y = 0.72; g.add(misil);
		var punta = cone(0.14, 0.3, M.naranja, 14); punta.position.y = 1.3; g.add(punta);
		var tapa = box(0.9, 0.06, 0.6, M.metal); tapa.position.set(0, 0.36, 0.5); tapa.rotation.x = 0.35; g.add(tapa);
		return hitbox(g, 0.85);
	}

	// falange: gran radar (idea: gebaeude/42.gif)
	function falange() {
		var g = new THREE.Group();
		g.add(plaza(1.2));
		var pie = cyl(0.3, 0.42, 0.7, M.oscura, 16); pie.position.y = 0.5; g.add(pie);
		var plato = new THREE.Mesh(new THREE.SphereGeometry(0.55, 20, 12, 0, Math.PI * 2, 0, Math.PI / 2.4), M.metal);
		plato.rotation.x = Math.PI / 1.9; plato.position.y = 1.15; g.add(plato);
		var nucleo = sph(0.16, M.cian); nucleo.position.set(0, 1.3, 0.35); g.add(nucleo);
		X.alTick(function (dt, t) { plato.rotation.y += dt * 0.6; });
		return hitbox(g, 0.95);
	}

	// puerta de salto: gran anillo (idea: gebaeude/43.gif)
	function puertaSalto() {
		var g = new THREE.Group();
		g.add(plaza(1.3));
		var anillo = tor(0.85, 0.16, M.metal, 40); anillo.position.y = 1.25; g.add(anillo);
		var vortice = cyl(0.6, 0.6, 0.05, M.violeta, 28); vortice.rotation.x = Math.PI / 2; vortice.position.y = 1.25; g.add(vortice);
		for (var i = 0; i < 4; i++) {
			var pilar = cyl(0.1, 0.14, 0.5, M.metal, 10);
			var a = (i / 4) * Math.PI * 2;
			pilar.position.set(Math.cos(a) * 0.95, 0.3, Math.sin(a) * 0.95); g.add(pilar);
		}
		X.alTick(function (dt, t) { vortice.material.emissiveIntensity = 0.7 + Math.sin(t * 2.4) * 0.3; });
		return hitbox(g, 1.0);
	}

	// torre genérica variada (cualquier otro edificio)
	function generico(id) {
		var g = new THREE.Group();
		g.add(plaza(1.2));
		var v = variar(id);
		var b1 = box(0.8, 0.5 + v * 0.3, 0.8, M.metal); b1.position.y = 0.4; g.add(b1);
		var b2 = box(0.5, 0.4, 0.5, M.oscura); b2.position.y = 0.88; b2.rotation.y = v * 1.2; g.add(b2);
		var pico = cone(0.18, 0.5, M.cian, 8); pico.position.y = 1.3; g.add(pico);
		return hitbox(g, 0.95);
	}

	function modeloEdificio(id, nombre, escala) {
		var n = String(nombre || '').toLowerCase();
		var g;
		if (n.indexOf('metal') >= 0 && n.indexOf('mina') >= 0) g = minaMetal();
		else if (n.indexOf('cristal') >= 0 && n.indexOf('mina') >= 0) g = minaCristal();
		else if (n.indexOf('deuter') >= 0 || n.indexOf('sintet') >= 0) g = sinteDeuterio();
		else if (n.indexOf('solar') >= 0 || n.indexOf('panel') >= 0) g = plantaSolar();
		else if (n.indexOf('fusion') >= 0 || n.indexOf('fusión') >= 0) g = fusion();
		else if (n.indexOf('laborat') >= 0) g = laboratorio();
		else if (n.indexOf('hangar') >= 0 || n.indexOf('astillero') >= 0 || n.indexOf('robo') >= 0 || n.indexOf('fábrica') >= 0 || n.indexOf('fabrica') >= 0) g = fabrica();
		else if (n.indexOf('almac') >= 0 || n.indexOf('depó') >= 0 || n.indexOf('deposito') >= 0 || n.indexOf('contened') >= 0) g = almacen();
		else if (n.indexOf('misil') >= 0) g = siloMisiles();
		else if (n.indexOf('falange') >= 0 || n.indexOf('sensor') >= 0) g = falange();
		else if (n.indexOf('salto') >= 0) g = puertaSalto();
		else if (n.indexOf('terra') >= 0 || n.indexOf('base lunar') >= 0 || n.indexOf('cuna') >= 0) g = plataforma();
		else g = porIdEdificio(id);
		g.scale.setScalar(escala || 1);
		return g;
	}
	function porIdEdificio(id) {
		id = Number(id) || 0;
		if (id === 1) return minaMetal();
		if (id === 2) return minaCristal();
		if (id === 3) return sinteDeuterio();
		if (id === 4) return plantaSolar();
		if (id === 5) return fusion();
		if (id === 6 || id === 7 || id === 21 || id === 15) return fabrica();
		if (id === 31 || id === 12) return laboratorio();
		if (id >= 8 && id <= 10) return almacen();
		if (id === 44) return siloMisiles();
		if (id === 42) return falange();
		if (id === 43) return puertaSalto();
		if (id === 33 || id === 41 || id === 34 || id === 11) return plataforma();
		return generico(id);
	}

	/* ================= NAVES (todas con motor encendido) ================= */

	function motor(x, y, z, color, r) {
		var m = sph(r || 0.09, color === 'verde' ? M.verde : color === 'violeta' ? M.violeta : M.naranja, 12);
		m.position.set(x, y, z);
		var chispa = cone(0.06, 0.22, m.material, 10); chispa.rotation.x = -Math.PI / 2; chispa.position.set(x, y, z + 0.16);
		var g = new THREE.Group(); g.add(m); g.add(chispa);
		return g;
	}

	// carga: casco cúbico + contenedores (idea: gebaeude/202-203.gif)
	function carga(grande) {
		var g = new THREE.Group();
		var s = grande ? 1.45 : 1.0;
		var casco = box(0.62 * s, 0.4 * s, 1.15 * s, M.metal); g.add(casco);
		var cabina = box(0.4, 0.22, 0.3, M.oscura); cabina.position.set(0, 0.3 * s, -0.5 * s); g.add(cabina);
		for (var i = 0; i < (grande ? 3 : 2); i++) {
			var cont = box(0.34 * s, 0.3 * s, 0.34 * s, M.cian); cont.position.set(0, -0.05, -0.15 * s + i * 0.4 * s); g.add(cont);
		}
		g.add(motor(0.22 * s, 0, 0.62 * s, 'naranja', 0.1 * s));
		g.add(motor(-0.22 * s, 0, 0.62 * s, 'naranja', 0.1 * s));
		return hitbox(g, 0.75 * s);
	}

	// cazador: dardo con alas (idea: gebaeude/204-205.gif)
	function cazador(pesado) {
		var g = new THREE.Group();
		var s = pesado ? 1.35 : 1.0;
		var morro = cone(0.16 * s, 0.85 * s, M.metal, 14); morro.rotation.x = -Math.PI / 2; morro.position.z = -0.25 * s; g.add(morro);
		var cuerpo = cyl(0.14 * s, 0.18 * s, 0.5 * s, M.metal, 14); cuerpo.rotation.x = Math.PI / 2; cuerpo.position.z = 0.3 * s; g.add(cuerpo);
		for (var i = -1; i <= 1; i += 2) {
			var ala = box(0.6 * s, 0.035, 0.34 * s, M.oscura); ala.position.set(i * 0.34 * s, 0, 0.35 * s); ala.rotation.z = i * 0.3; g.add(ala);
			if (pesado) {
				var can = cyl(0.035, 0.035, 0.5 * s, M.metal, 8); can.rotation.x = Math.PI / 2; can.position.set(i * 0.24 * s, -0.05, 0.1); g.add(can);
			}
			g.add(motor(i * 0.14 * s, 0, 0.62 * s, pesado ? 'verde' : 'naranja', 0.08 * s));
		}
		return hitbox(g, 0.6 * s);
	}

	// crucero / nave de batalla: casco alargado (idea: gebaeude/206-207.gif)
	function crucero(grande) {
		var g = new THREE.Group();
		var s = grande ? 1.5 : 1.15;
		var casco = cyl(0.16 * s, 0.26 * s, 1.5 * s, M.metal, 16); casco.rotation.x = Math.PI / 2; g.add(casco);
		var puente = sph(0.22 * s, M.oscura, 14); puente.scale.set(1, 0.7, 1.4); puente.position.y = 0.2 * s; puente.position.z = -0.5 * s; g.add(puente);
		for (var i = -1; i <= 1; i += 2) {
			var pod = cyl(0.1 * s, 0.1 * s, 0.6 * s, M.oscura, 10); pod.rotation.x = Math.PI / 2; pod.position.set(i * 0.32 * s, -0.08 * s, 0.2 * s); g.add(pod);
			var torreta = cyl(0.06 * s, 0.09 * s, 0.14 * s, M.metal, 10); torreta.position.set(i * 0.2 * s, 0.18 * s, -0.2 * s); g.add(torreta);
			g.add(motor(i * 0.18 * s, -0.08 * s, 0.85 * s, 'verde', 0.09 * s));
		}
		return hitbox(g, 0.8 * s);
	}

	// colonizador: módulos y patas (idea: gebaeude/208.gif)
	function colonizador() {
		var g = new THREE.Group();
		var casco = box(0.7, 0.45, 1.1, M.metal); g.add(casco);
		var domo = sph(0.3, M.cian, 18); domo.scale.y = 0.75; domo.position.y = 0.35; g.add(domo);
		for (var i = -1; i <= 1; i += 2) {
			var pata = cyl(0.05, 0.05, 0.5, M.oscura, 8); pata.rotation.z = i * 0.5; pata.position.set(i * 0.45, -0.35, 0.3); g.add(pata);
		}
		g.add(motor(0, -0.1, 0.62, 'naranja', 0.12));
		return hitbox(g, 0.8);
	}

	// reciclador: caja con anillo gigante (idea: gebaeude/209.gif)
	function reciclador() {
		var g = new THREE.Group();
		var caja = box(0.5, 0.4, 0.8, M.metal); g.add(caja);
		var anillo = tor(0.55, 0.07, M.oscura); anillo.rotation.y = Math.PI / 2; g.add(anillo);
		X.alTick(function (dt) { anillo.rotation.x += dt * 1.1; });
		g.add(motor(0, 0, 0.5, 'verde', 0.1));
		return hitbox(g, 0.75);
	}

	// sonda: esfera + plato (idea: gebaeude/210.gif)
	function sonda() {
		var g = new THREE.Group();
		var cuerpo = sph(0.26, M.metal, 18); g.add(cuerpo);
		var plato = cone(0.3, 0.18, M.oscura, 18); plato.rotation.x = Math.PI / 2; plato.position.z = 0.1; g.add(plato);
		var antena = cyl(0.02, 0.02, 0.45, M.metal, 6); antena.rotation.x = Math.PI / 2; antena.position.z = -0.45; g.add(antena);
		g.add(motor(0, 0, 0.3, 'violeta', 0.07));
		return hitbox(g, 0.5);
	}

	// bombardero: casco grueso (idea: gebaeude/211.gif)
	function bombardero() {
		var g = new THREE.Group();
		var casco = sph(0.4, M.metal, 18); casco.scale.set(0.9, 0.55, 1.6); g.add(casco);
		var bahia = box(0.4, 0.16, 0.5, M.oscura); bahia.position.y = -0.25; g.add(bahia);
		for (var i = -1; i <= 1; i += 2) {
			var ala = box(0.5, 0.04, 0.4, M.oscura); ala.position.set(i * 0.5, 0, 0.15); ala.rotation.z = i * 0.25; g.add(ala);
			g.add(motor(i * 0.3, 0, 0.62, 'verde', 0.11));
		}
		return hitbox(g, 0.75);
	}

	// satélite solar: estrella de paneles (idea: gebaeude/212.gif)
	function sateliteSolar() {
		var g = new THREE.Group();
		var nucleo = sph(0.2, M.naranja, 14); g.add(nucleo);
		for (var i = 0; i < 4; i++) {
			var panel = box(0.85, 0.03, 0.3, M.panel);
			panel.rotation.z = (i / 4) * Math.PI * 2 + Math.PI / 4;
			panel.rotation.y = Math.PI / 4;
			panel.position.set(Math.cos(i * Math.PI / 2) * 0.35, Math.sin(i * Math.PI / 2) * 0.35, 0);
			panel.rotation.x = Math.PI / 2.4;
			g.add(panel);
		}
		X.alTick(function (dt) { g.rotation.z += dt * 0.5; });
		return hitbox(g, 0.6);
	}

	// destructor: espina con pinchos (idea: gebaeude/213.gif)
	function destructor() {
		var g = new THREE.Group();
		var espina = cyl(0.12, 0.2, 1.9, M.metal, 12); espina.rotation.x = Math.PI / 2; g.add(espina);
		var proa = cone(0.2, 0.55, M.oscura, 12); proa.rotation.x = -Math.PI / 2; proa.position.z = -1.15; g.add(proa);
		for (var i = 0; i < 4; i++) {
			var a = (i / 4) * Math.PI * 2;
			var pincho = cone(0.07, 0.5, M.metal, 8);
			pincho.rotation.x = a + Math.PI / 2; pincho.position.set(Math.cos(a) * 0.22, Math.sin(a) * 0.22, 0.3); g.add(pincho);
		}
		g.add(motor(0, 0, 1.05, 'violeta', 0.14));
		return hitbox(g, 0.85);
	}

	// estrella de la muerte: esfera + cañón (idea: gebaeude/214.gif)
	function estrella() {
		var g = new THREE.Group();
		var bola = sph(0.75, M.oscura, 30); g.add(bola);
		var banda = tor(0.76, 0.035, M.metal); banda.rotation.x = 0.4; g.add(banda);
		var plato = cyl(0.3, 0.34, 0.08, M.cian, 22); plato.rotation.x = Math.PI / 2.2; plato.position.set(0.35, 0.35, 0.55); g.add(plato);
		X.alTick(function (dt, t) { plato.material.emissiveIntensity = 0.8 + Math.sin(t * 2.8) * 0.35; });
		return hitbox(g, 0.95);
	}

	// acorazado: puente alto + cañones (idea: gebaeude/215.gif)
	function acorazado() {
		var g = new THREE.Group();
		var casco = cyl(0.14, 0.22, 1.35, M.metal, 14); casco.rotation.x = Math.PI / 2; g.add(casco);
		var puente = box(0.3, 0.3, 0.35, M.oscura); puente.position.y = 0.25; puente.position.z = -0.4; g.add(puente);
		for (var i = -1; i <= 1; i += 2) {
			var can = cyl(0.05, 0.05, 0.55, M.metal, 8); can.rotation.x = Math.PI / 2; can.position.set(i * 0.18, 0.12, -0.85); g.add(can);
			g.add(motor(i * 0.15, -0.05, 0.78, 'naranja', 0.1));
		}
		return hitbox(g, 0.8);
	}

	function genericoNave(id) {
		var g = new THREE.Group();
		var v = variar(id);
		var casco = cone(0.22 + v * 0.1, 1.0, M.metal, 12); casco.rotation.x = -Math.PI / 2; g.add(casco);
		var cola = box(0.35, 0.06, 0.3, M.oscura); cola.position.z = 0.45; g.add(cola);
		g.add(motor(0, 0, 0.55, 'verde', 0.09));
		return hitbox(g, 0.6);
	}

	function modeloNave(id, nombre, escala) {
		var n = String(nombre || '').toLowerCase();
		var g;
		if (n.indexOf('peque') >= 0 && n.indexOf('carga') >= 0) g = carga(false);
		else if (n.indexOf('grande') >= 0 || (n.indexOf('carga') >= 0 && n.indexOf('g') >= 0)) g = carga(true);
		else if (n.indexOf('cazador') >= 0 && n.indexOf('ligero') >= 0) g = cazador(false);
		else if (n.indexOf('cazador') >= 0) g = cazador(true);
		else if (n.indexOf('crucero') >= 0) g = crucero(false);
		else if (n.indexOf('batalla') >= 0 || n.indexOf('acoraz') >= 0) g = crucero(true);
		else if (n.indexOf('coloniz') >= 0) g = colonizador();
		else if (n.indexOf('recicl') >= 0) g = reciclador();
		else if (n.indexOf('sonda') >= 0 || n.indexOf('espion') >= 0) g = sonda();
		else if (n.indexOf('bombard') >= 0) g = bombardero();
		else if (n.indexOf('satélite') >= 0 || n.indexOf('satelite') >= 0) g = sateliteSolar();
		else if (n.indexOf('destructor') >= 0) g = destructor();
		else if (n.indexOf('estrella') >= 0 || n.indexOf('muerte') >= 0) g = estrella();
		else g = porIdNave(id);
		g.scale.setScalar(escala || 1);
		return g;
	}
	function porIdNave(id) {
		id = Number(id) || 0;
		if (id === 202) return carga(false);
		if (id === 203) return carga(true);
		if (id === 204) return cazador(false);
		if (id === 205) return cazador(true);
		if (id === 206) return crucero(false);
		if (id === 207) return crucero(true);
		if (id === 208) return colonizador();
		if (id === 209) return reciclador();
		if (id === 210) return sonda();
		if (id === 211) return bombardero();
		if (id === 212) return sateliteSolar();
		if (id === 213) return destructor();
		if (id === 214) return estrella();
		if (id === 215) return acorazado();
		return genericoNave(id);
	}

	/* ================= INVESTIGACIONES (artefacto en pedestal) ================= */

	function pedestal(m) {
		var g = new THREE.Group();
		g.add(plaza(0.9));
		var p = cyl(0.3, 0.4, 0.5, m || M.oscura, 14); p.position.y = 0.35; g.add(p);
		return g;
	}

	function invEnergia() { // bobina tesla
		var g = pedestal();
		for (var i = 0; i < 3; i++) {
			var a = tor(0.16 + i * 0.06, 0.035, M.cian); a.rotation.x = Math.PI / 2; a.position.y = 0.75 + i * 0.18; g.add(a);
		}
		var esfera = sph(0.14, M.cian); esfera.position.y = 1.3; g.add(esfera);
		X.alTick(function (dt, t) { esfera.material.emissiveIntensity = 0.7 + Math.sin(t * 5) * 0.4; });
		return hitbox(g, 0.7);
	}

	function invMotor() { // cono de propulsión en prueba
		var g = pedestal();
		var chorro = cone(0.22, 0.7, M.verde, 14); chorro.rotation.x = Math.PI; chorro.position.y = 1.05; g.add(chorro);
		var tobera = cyl(0.26, 0.18, 0.25, M.metal, 14); tobera.position.y = 0.72; g.add(tobera);
		X.alTick(function (dt, t) { chorro.scale.setScalar(1 + Math.sin(t * 6) * 0.12); });
		return hitbox(g, 0.7);
	}

	function invArma() { // cañón giratorio
		var g = pedestal();
		var poste = cyl(0.07, 0.09, 0.45, M.oscura, 10); poste.position.y = 0.75; g.add(poste);
		var can = cyl(0.05, 0.05, 0.55, M.metal, 8); can.rotation.x = Math.PI / 2.3; can.position.set(0, 1.0, -0.15);
		g.add(can);
		X.alTick(function (dt, t) { g.rotation.y = Math.sin(t * 0.8) * 0.8; });
		return hitbox(g, 0.7);
	}

	function invEscudo() { // cúpula de energía
		var g = pedestal();
		var domo = new THREE.Mesh(new THREE.SphereGeometry(0.42, 20, 14, 0, Math.PI * 2, 0, Math.PI / 2), M.cristal);
		domo.position.y = 0.6; g.add(domo);
		X.alTick(function (dt, t) { domo.material.opacity = 0.6 + Math.sin(t * 2.2) * 0.2; });
		return hitbox(g, 0.7);
	}

	function invRed() { // nodos en órbita
		var g = pedestal();
		var nucleo = sph(0.16, M.violeta); nucleo.position.y = 1.0; g.add(nucleo);
		var satelites = [];
		for (var i = 0; i < 3; i++) {
			var s = sph(0.06, M.cian, 8); s.userData = { a: (i / 3) * Math.PI * 2 }; g.add(s); satelites.push(s);
		}
		X.alTick(function (dt, t) {
			for (var i = 0; i < satelites.length; i++) {
				var a = satelites[i].userData.a + t * 1.3;
				satelites[i].position.set(Math.cos(a) * 0.4, 1.0 + Math.sin(a * 2) * 0.08, Math.sin(a) * 0.4);
			}
		});
		return hitbox(g, 0.7);
	}

	function invEspia() { // mini plato radar
		var g = pedestal();
		var plato = cone(0.3, 0.16, M.metal, 16); plato.rotation.x = Math.PI / 2.4; plato.position.y = 0.85; g.add(plato);
		X.alTick(function (dt) { plato.rotation.y += dt * 1.2; });
		return hitbox(g, 0.7);
	}

	function invGenerica(id) { // artefacto flotante
		var g = pedestal();
		var v = variar(id);
		var ar = new THREE.Mesh(new THREE.OctahedronGeometry(0.24 + v * 0.08), M.cristal); ar.position.y = 1.05; g.add(ar);
		var aro = tor(0.36, 0.025, M.cian); aro.rotation.x = Math.PI / 2.3; aro.position.y = 1.05; g.add(aro);
		X.alTick(function (dt, t) { ar.rotation.y += dt * 1.6; ar.position.y = 1.05 + Math.sin(t * 2) * 0.06; aro.rotation.z += dt * 0.7; });
		return hitbox(g, 0.7);
	}

	function modeloInvestigacion(id, nombre, escala) {
		var n = String(nombre || '').toLowerCase();
		var g;
		if (n.indexOf('energ') >= 0) g = invEnergia();
		else if (n.indexOf('motor') >= 0 || n.indexOf('propul') >= 0 || n.indexOf('combus') >= 0 || n.indexOf('ion') >= 0 || n.indexOf('plasma') >= 0) g = invMotor();
		else if (n.indexOf('arma') >= 0 || n.indexOf('láser') >= 0 || n.indexOf('laser') >= 0 || n.indexOf('blaster') >= 0 || n.indexOf('cañ') >= 0) g = invArma();
		else if (n.indexOf('escudo') >= 0 || n.indexOf('blindaje') >= 0 || n.indexOf('armadura') >= 0) g = invEscudo();
		else if (n.indexOf('red') >= 0 || n.indexOf('comput') >= 0 || n.indexOf('astro') >= 0 || n.indexOf('red de') >= 0) g = invRed();
		else if (n.indexOf('espion') >= 0 || n.indexOf('sonda') >= 0) g = invEspia();
		else g = invGenerica(Number(id) || 0);
		g.scale.setScalar(escala || 1);
		return g;
	}

	/* ================= DEFENSAS ================= */

	function defLanzamisiles() {
		var g = new THREE.Group();
		g.add(plaza(0.85));
		var base = box(0.6, 0.3, 0.6, M.oscura); base.position.y = 0.3; g.add(base);
		for (var i = 0; i < 2; i++) {
			var tubo = cyl(0.08, 0.08, 0.6, M.metal, 10); tubo.rotation.x = Math.PI / 2.6;
			tubo.position.set((i - 0.5) * 0.18, 0.55, -0.1); g.add(tubo);
			var misil = cyl(0.045, 0.045, 0.5, M.naranja, 8); misil.rotation.x = Math.PI / 2.6;
			misil.position.set((i - 0.5) * 0.18, 0.6, -0.14); g.add(misil);
		}
		return hitbox(g, 0.65);
	}

	function defCanion(colorMat) {
		var g = new THREE.Group();
		g.add(plaza(0.85));
		var base = cyl(0.26, 0.34, 0.3, M.oscura, 14); base.position.y = 0.3; g.add(base);
		var torreta = sph(0.2, M.metal, 12); torreta.position.y = 0.55; g.add(torreta);
		var can = cyl(0.05, 0.07, 0.7, colorMat || M.metal, 10); can.rotation.x = Math.PI / 2.2; can.position.set(0, 0.62, -0.25); g.add(can);
		X.alTick(function (dt, t) { g.rotation.y = Math.sin(t * 0.7) * 0.9; });
		return hitbox(g, 0.65);
	}

	function defGauss() {
		var g = new THREE.Group();
		g.add(plaza(0.85));
		var base = cyl(0.3, 0.4, 0.35, M.oscura, 16); base.position.y = 0.32; g.add(base);
		var can = cyl(0.05, 0.05, 0.9, M.metal, 10); can.rotation.x = Math.PI / 2.4; can.position.set(0, 0.75, -0.3); g.add(can);
		for (var i = 0; i < 3; i++) {
			var bob = tor(0.11, 0.03, M.cian); bob.rotation.x = Math.PI / 2.4;
			bob.position.set(0, 0.9 - i * 0.14, -0.14 - i * 0.13); g.add(bob);
		}
		X.alTick(function (dt, t) {
			for (var i = 0; i < g.children.length; i++) {
				var c = g.children[i];
				if (c.geometry && c.geometry.type === 'TorusGeometry') c.material.emissiveIntensity = 0.7 + Math.sin(t * 3 + i) * 0.4;
			}
		});
		return hitbox(g, 0.7);
	}

	function defPlasma() {
		var g = new THREE.Group();
		g.add(plaza(0.85));
		var base = cyl(0.24, 0.32, 0.4, M.oscura, 14); base.position.y = 0.35; g.add(base);
		var cont = new THREE.Mesh(new THREE.SphereGeometry(0.3, 18, 12), M.violeta); cont.position.y = 0.9; g.add(cont);
		var jaula = tor(0.3, 0.04, M.metal); jaula.rotation.x = Math.PI / 2.3; jaula.position.y = 0.9; g.add(jaula);
		X.alTick(function (dt, t) { cont.material.emissiveIntensity = 0.8 + Math.sin(t * 2.6) * 0.35; jaula.rotation.y += dt * 0.8; });
		return hitbox(g, 0.65);
	}

	function defCupula(grande) {
		var g = new THREE.Group();
		var s = grande ? 1.5 : 1.0;
		g.add(plaza(0.9 * s));
		var emisor = cyl(0.12, 0.16, 0.5, M.metal, 10); emisor.position.y = 0.4; g.add(emisor);
		var domo = new THREE.Mesh(new THREE.SphereGeometry(0.55 * s, 20, 14, 0, Math.PI * 2, 0, Math.PI / 2), M.cristal);
		domo.position.y = 0.62; g.add(domo);
		X.alTick(function (dt, t) { domo.material.opacity = 0.5 + Math.sin(t * 1.8) * 0.18; });
		return hitbox(g, 0.7 * s);
	}

	function modeloDefensa(id, nombre, escala) {
		var n = String(nombre || '').toLowerCase();
		var g;
		if (n.indexOf('lanzamisiles') >= 0 || n.indexOf('misil') >= 0) g = defLanzamisiles();
		else if (n.indexOf('gauss') >= 0) g = defGauss();
		else if (n.indexOf('plasma') >= 0) g = defPlasma();
		else if (n.indexOf('cúpula') >= 0 && n.indexOf('peque') >= 0) g = defCupula(false);
		else if (n.indexOf('cúpula') >= 0) g = defCupula(true);
		else if (n.indexOf('láser') >= 0 || n.indexOf('laser') >= 0) g = defCanion(M.naranja);
		else if (n.indexOf('ión') >= 0 || n.indexOf('ion') >= 0) g = defCanion(M.cian);
		else g = defCanion(M.metal);
		g.scale.setScalar(escala || 1);
		return g;
	}

	/* ================= registro sobre X3D ================= */
	X.modeloEdificio = modeloEdificio;
	X.modeloNave = modeloNave;
	X.modeloInvestigacion = modeloInvestigacion;
	X.modeloDefensa = modeloDefensa;
})();
