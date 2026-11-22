<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{$adm_cp_title} &bull; {$game_name}</title>
<link rel="shortcut icon" href="./favicon.ico" type="image/x-icon">
<script type="text/javascript">
if (top.location != self.location) top.location = self.location;
</script>
<style>
/* ══════════════════════════════════════════════════════════════════
   ASTROIO ADMIN SHELL v3.3 — Layout responsive del panel admin
   ================================================================
   Reemplaza el <frameset> original (cols="217,*" / rows="84,*") por
   un layout real de barra superior + menú lateral + contenido.
   COMPATIBILIDAD 100% PRESERVADA:
     - iframe name="Hauptframe"  → target de TODOS los enlaces del menú
     - iframe name="rightFrame"  → recargado por el selector de universos
     - iframe name="topFrame"    → recargado por ?reload=t (overall_footer)
   El alto de la barra superior se ajusta automáticamente al contenido
   (mismo origen, medición segura) para que nada quede cortado en móvil.
   ══════════════════════════════════════════════════════════════════ */
:root {
	--astroadms-menu-w:   217px;
	--astroadms-topnav-h: 84px;
	--astroadms-border:   rgba(0, 224, 255, 0.2);
	--astroadms-bg:       #060a14;
}

html, body {
	margin: 0;
	padding: 0;
	height: 100%;
	width: 100%;
	overflow: hidden;
	background: var(--astroadms-bg);
	font-family: 'Segoe UI', Tahoma, Verdana, sans-serif;
}

/* ====== Barra superior (topFrame) ====== */
#astroadms_topbar {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	height: var(--astroadms-topnav-h);
	display: flex;
	align-items: stretch;
	background: rgba(15, 23, 42, 0.75);
	border-bottom: 1px solid var(--astroadms-border);
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
	z-index: 50;
	box-sizing: border-box;
}

/* Botón hamburguesa: solo móvil */
#astroadms_burger {
	display: none;
	width: 46px;
	border: none;
	background: rgba(0, 68, 136, 0.85);
	color: #00e0ff;
	font-size: 22px;
	cursor: pointer;
	border-radius: 8px;
	margin: 8px 0 8px 8px;
	flex: 0 0 46px;
	line-height: 1;
}
#astroadms_burger:active { background: rgba(0, 102, 204, 0.95); }

#topFrame {
	flex: 1 1 auto;
	border: 0;
	width: 100%;
	height: 100%;
	background: transparent;
}

/* ====== Menú lateral (rightFrame) ====== */
#rightFrame {
	position: fixed;
	top: var(--astroadms-topnav-h);
	left: 0;
	width: var(--astroadms-menu-w);
	height: calc(100% - var(--astroadms-topnav-h));
	border: 0;
	border-right: 1px solid var(--astroadms-border);
	background: rgba(15, 23, 42, 0.92);
	z-index: 40;
	transform: none;
	transition: none;
}

/* ====== Contenido (Hauptframe) ====== */
#mainFrame {
	position: fixed;
	top: var(--astroadms-topnav-h);
	left: var(--astroadms-menu-w);
	width: calc(100% - var(--astroadms-menu-w));
	height: calc(100% - var(--astroadms-topnav-h));
	border: 0;
	background: transparent;
	z-index: 1;
}

/* Overlay del drawer móvil */
#astroadms_overlay {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.65);
	z-index: 90;
}

/* ══════════════ MÓVIL (≤ 768px) ══════════════ */
@media screen and (max-width: 768px) {
	#astroadms_burger { display: block; }

	/* La barra superior toma el alto REAL medido por JS */
	#astroadms_topbar { height: var(--astroadms-topnav-h, 118px); }

	/* Menú → drawer deslizante sobre el contenido */
	#rightFrame {
		top: 0;
		left: 0;
		width: min(80vw, 300px);
		height: 100vh;
		transform: translateX(-105%);
		transition: transform 0.25s ease;
		box-shadow: 6px 0 24px rgba(0, 0, 0, 0.6);
		z-index: 100;
	}
	body.astroadms-open #rightFrame { transform: translateX(0); }

	#astroadms_overlay[style], body.astroadms-open #astroadms_overlay { display: block; }

	/* Contenido ocupa TODO el ancho, debajo de la barra */
	#mainFrame {
		left: 0;
		top: var(--astroadms-topnav-h, 118px);
		width: 100%;
		height: calc(100% - var(--astroadms-topnav-h, 118px));
	}
}
</style>
</head>
<body>

	<div id="astroadms_topbar">
		<button id="astroadms_burger" type="button" aria-label="Abrir menú de administración">&#9776;</button>
		<iframe src="admin.php?page=topnav" name="topFrame" id="topFrame" title="Barra de administración"
			scrolling="no" onload="astroioFitTopnav(this)"></iframe>
	</div>

	<iframe src="admin.php?page=menu" name="rightFrame" id="rightFrame" title="Menú de administración"></iframe>

	<div id="astroadms_overlay"></div>

	<iframe src="admin.php?page=overview" name="Hauptframe" id="mainFrame" title="Panel"></iframe>

	<script type="text/javascript">
	/* ══════════════════════════════════════════════════════════════
	   ASTROIO ADMIN SHELL v3.3 — JS del layout
	   - astroioFitTopnav: ajusta el alto de la barra al contenido real
	     (evita contenido cortado en móvil; sin cambios en escritorio)
	   - astroioOpenMenu / astroioCloseMenu: drawer móvil. La función
	     astroioCloseMenu la llama el propio menú (ShowMenuPage) al
	     pulsar un enlace, para cerrar el drawer automáticamente.
	   ══════════════════════════════════════════════════════════════ */
	function astroioFitTopnav(f) {
		try {
			var h = f.contentDocument.body.scrollHeight;
			if (h && h > 40) {
				f.style.height = h + 'px';
				document.documentElement.style.setProperty('--astroadms-topnav-h', h + 'px');
			}
		} catch (e) { /* silencioso */ }
	}

	function astroioMenuOpen()  { document.body.classList.add('astroadms-open'); }
	function astroioCloseMenu() { document.body.classList.remove('astroadms-open'); }

	(function () {
		var burger  = document.getElementById('astroadms_burger');
		var overlay = document.getElementById('astroadms_overlay');

		burger.addEventListener('click', function () {
			document.body.classList.toggle('astroadms-open');
		});
		overlay.addEventListener('click', astroioCloseMenu);
	})();
	</script>

</body>
</html>
