<!DOCTYPE html>

<!--[if lt IE 7 ]> <html lang="{$lang}" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="{$lang}" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="{$lang}" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="{$lang}" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="{$lang}" class="no-js"> <!--<![endif]-->
<head>
	<title>{$title}</title>
	<meta name="generator" content="2Moons {$VERSION}">
	<!-- 
		This website is powered by 2Moons {$VERSION}
		2Moons is a free Space Browsergame initially created by Jan Kröpke and licensed under GNU/GPL.
		2Moons is copyright 2009-2013 of Jan Kröpke. Extensions are copyright of their respective owners.
		Information and contribution at http://2moons.cc/
	-->
	{if !empty($goto)}
	<meta http-equiv="refresh" content="{$gotoinsec};URL={$goto}">
	{/if}
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<!-- ✅ FIX ASTROIO - responsive móvil -->
	<style>
	@media screen and (max-width: 1024px) {
		html, body {
			background-color: #1a0a00 !important;
			background-image: url('./styles/theme/gow/img/bkd_page.jpg') !important;
			background-size: cover !important;
			background-repeat: no-repeat !important;
			background-attachment: fixed !important;
			background-position: center top !important;
			min-height: 100vh !important;
			height: auto !important;
		}
		#content, .content, #page, .page, #wrapper, .wrapper, #container, .container {
			background: transparent !important;
			background-color: transparent !important;
		}
		#menu, .menu, #left, .left, #left_menu, .left_menu, .sidebar {
			height: fit-content !important;
			min-height: 0 !important;
			background: transparent !important;
			background-color: transparent !important;
			padding-bottom: 0 !important;
			margin-bottom: 0 !important;
		}
	}
	</style>
	<!-- ✅ FIN FIX ASTROIO -->

	<!-- CSS individuales (optimización de CSS combinado eliminada) -->
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/boilerplate.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/ingame/main.css?v={$REV}">
	{if $smarty.const.MODE == 'ADMIN'}
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/admin/main.css?v={$REV}">
	{/if}
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/jquery.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/jquery.fancybox.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/validationEngine.jquery.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/theme/gow/ingame.css?v={$REV}">
	<link rel="shortcut icon" href="./favicon.ico" type="image/x-icon">

	<!-- ══════════════════════════════════════════════════════════════
	     ASTROIO ADMIN v3.0.1 — Estilos globales del panel admin
	     Prefijo: .astroadm_
	     Acento: 🔷 Cyan (#00e0ff)
	     FIX v3.0.1:
	       - Overlay oscuro sobre la imagen del fondo (mejor contraste)
	       - Contenedores con backdrop semitransparente (legibilidad)
	       - Inputs, botones y enlaces con reglas GLOBALES
	       - Text-shadow global para mejor lectura
	     - Preserva 100% los IDs, clases y JS originales
	     ══════════════════════════════════════════════════════════════ -->
	<style>
	/* ====== Variables globales ====== */
	:root {
		--bg-dark:       rgba(11, 16, 30, 0.55);
		--bg-card:       rgba(15, 23, 42, 0.85);
		--bg-card-solid: rgba(15, 23, 42, 0.92);
		--bg-inner:      rgba(0, 0, 0, 0.45);
		--border-color:  #1e293b;
		--text-main:     #cbd5e1;
		--text-muted:    #94a3b8;
		--text-title:    #ffffff;
		--accent-blue:   #3b82f6;
		--accent-cyan:   #00e0ff;
		--accent-purple: #8b5cf6;
		--accent-gold:   #fbbf24;
		--accent-green:  #4aff88;
		--accent-red:    #ef4444;
	}

	/* ====== Fondo general del admin ======
	   La imagen se mantiene visible pero con un OVERLAY OSCURO encima
	   para que el contenido sea perfectamente legible. */
	html, body {
		background-color: #060a14 !important;
		background-image:
			linear-gradient(180deg, rgba(6, 10, 20, 0.72), rgba(6, 10, 20, 0.88)),
			url('./styles/theme/gow/img/bkd_page.jpg') !important;
		background-size: cover, cover !important;
		background-repeat: no-repeat, no-repeat !important;
		background-attachment: fixed, fixed !important;
		background-position: center top, center top !important;
		min-height: 100vh;
		color: var(--text-main);
		font-family: 'Segoe UI', Tahoma, Verdana, sans-serif;
	}

	/* ====== Wrapper principal del contenido admin ======
	   Fondo semitransparente + blur para que todo
	   el contenido se lea bien sobre la imagen. */
	body > div:not(#tooltip),
	body > form,
	body > table,
	#content,
	.content,
	#page,
	.page,
	#wrapper,
	.wrapper,
	#container,
	.container {
		background: rgba(15, 23, 42, 0.55);
		backdrop-filter: blur(4px);
		-webkit-backdrop-filter: blur(4px);
	}

	/* ====== Tablas admin (genérico) ====== */
	table.table,
	table.tablebg,
	table.admin_table,
	table.list,
	table.tablesorter {
		background: var(--bg-card);
		backdrop-filter: blur(6px);
		-webkit-backdrop-filter: blur(6px);
		border: 1px solid var(--border-color);
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
		overflow: hidden;
	}

	table.table tr th,
	table.tablebg tr th,
	table.admin_table tr th,
	table.list tr th,
	table.tablesorter thead tr th {
		background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 119, 204, 0.9)) !important;
		backdrop-filter: blur(6px);
		-webkit-backdrop-filter: blur(6px);
		color: #ffffff !important;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.8px;
		border-bottom: 1px solid var(--accent-cyan);
		text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
	}

	table.table tr td,
	table.tablebg tr td,
	table.admin_table tr td,
	table.list tr td {
		border-bottom: 1px solid rgba(30, 41, 59, 0.6);
		color: var(--text-main);
	}

	table.table tr:hover td,
	table.tablebg tr:hover td,
	table.admin_table tr:hover td,
	table.list tr:hover td,
	table.tablesorter tbody tr:hover td {
		background: rgba(0, 204, 255, 0.08) !important;
	}

	/* ====== Inputs, textarea y select admin (GLOBAL) ====== */
	input[type="text"],
	input[type="number"],
	input[type="password"],
	input[type="email"],
	textarea,
	select {
		background: rgba(0, 0, 0, 0.55) !important;
		border: 1px solid rgba(0, 224, 255, 0.3) !important;
		border-radius: 6px !important;
		color: #ffffff !important;
		padding: 6px 10px !important;
		font-family: inherit !important;
		outline: none !important;
		transition: 0.25s ease !important;
	}

	input[type="text"]:focus,
	input[type="number"]:focus,
	input[type="password"]:focus,
	input[type="email"]:focus,
	textarea:focus,
	select:focus {
		border-color: var(--accent-cyan) !important;
		box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
		background: rgba(0, 0, 0, 0.75) !important;
	}

	/* ====== Botones admin (GLOBAL) ====== */
	input[type="submit"],
	input[type="button"],
	button {
		background: linear-gradient(135deg, rgba(0, 68, 136, 0.95), rgba(0, 153, 255, 0.95)) !important;
		border: 1px solid rgba(0, 224, 255, 0.5) !important;
		border-radius: 8px !important;
		color: #ffffff !important;
		padding: 7px 16px !important;
		font-weight: 700 !important;
		font-size: 11px !important;
		text-transform: uppercase !important;
		letter-spacing: 0.6px !important;
		cursor: pointer !important;
		transition: 0.25s ease !important;
		text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
	}

	input[type="submit"]:hover,
	input[type="button"]:hover,
	button:hover {
		background: linear-gradient(135deg, rgba(0, 102, 204, 0.98), rgba(0, 224, 255, 0.98)) !important;
		box-shadow: 0 0 16px rgba(0, 224, 255, 0.6) !important;
		transform: translateY(-2px);
	}

	/* ====== Enlaces admin ====== */
	#content a,
	.content a,
	#page a,
	.page a {
		color: var(--accent-cyan);
		text-decoration: none;
		transition: 0.2s ease;
	}

	#content a:hover,
	.content a:hover,
	#page a:hover,
	.page a:hover {
		color: #ffffff;
		text-shadow: 0 0 8px rgba(0, 224, 255, 0.6);
	}

	/* ====== Títulos admin ====== */
	h1, h2, h3 {
		color: var(--text-title);
		text-shadow: 0 2px 8px rgba(0, 0, 0, 0.7), 0 0 15px rgba(0, 224, 255, 0.3);
		letter-spacing: 0.5px;
	}

	/* ====== Texto general admin (mejor legibilidad sobre imagen) ====== */
	body, p, span, div, td, th, label, b, strong, i, em {
		text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
	}

	/* ====== Cajas de info/error/éxito ====== */
	.alert,
	.message,
	.info,
	.error,
	.success {
		background: rgba(15, 23, 42, 0.85) !important;
		backdrop-filter: blur(6px);
		-webkit-backdrop-filter: blur(6px);
		border: 1px solid var(--border-color);
		border-radius: 10px;
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
		color: var(--text-main);
	}

	/* ====== jQuery UI dialogs admin ====== */
	.ui-dialog {
		background: rgba(15, 23, 42, 0.95) !important;
		backdrop-filter: blur(8px);
		-webkit-backdrop-filter: blur(8px);
		border: 1px solid rgba(0, 224, 255, 0.4) !important;
		border-radius: 12px !important;
		box-shadow: 0 8px 30px rgba(0, 0, 0, 0.7) !important;
	}
	.ui-dialog .ui-dialog-titlebar {
		background: linear-gradient(135deg, rgba(0, 68, 136, 0.95), rgba(0, 119, 204, 0.95)) !important;
		border: none !important;
		border-bottom: 1px solid var(--accent-cyan) !important;
		border-radius: 12px 12px 0 0 !important;
		color: #ffffff !important;
	}
	.ui-dialog .ui-dialog-content {
		color: var(--text-main) !important;
		background: transparent !important;
	}
	.ui-dialog .ui-dialog-buttonpane {
		background: rgba(0, 0, 0, 0.35) !important;
		border-top: 1px solid rgba(30, 41, 59, 0.6) !important;
	}

	/* ====== Tooltip ====== */
	#tooltip.tip,
	.tip {
		background: rgba(15, 23, 42, 0.98) !important;
		backdrop-filter: blur(6px);
		-webkit-backdrop-filter: blur(6px);
		border: 1px solid rgba(0, 224, 255, 0.4) !important;
		border-radius: 8px !important;
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.6) !important;
		color: var(--text-main) !important;
	}

	/* ====== Scrollbar admin ====== */
	::-webkit-scrollbar {
		width: 10px;
		height: 10px;
	}
	::-webkit-scrollbar-track {
		background: rgba(0, 0, 0, 0.3);
	}
	::-webkit-scrollbar-thumb {
		background: linear-gradient(180deg, rgba(0, 102, 204, 0.8), rgba(0, 224, 255, 0.6));
		border-radius: 6px;
		border: 2px solid rgba(0, 0, 0, 0.3);
	}
	::-webkit-scrollbar-thumb:hover {
		background: linear-gradient(180deg, rgba(0, 153, 255, 0.95), rgba(0, 224, 255, 0.9));
	}

	/* ====== Preservar TinyMCE intacto ====== */
	.mce-tinymce,
	.mce-panel,
	.mce-toolbar-grp,
	.mce-edit-area {
		background: inherit !important;
	}

	/* ====== Preservar tablesorter ====== */
	.tablesorter thead tr th {
		cursor: pointer;
	}
	.tablesorter thead tr th:hover {
		background: linear-gradient(135deg, rgba(0, 102, 204, 0.98), rgba(0, 153, 255, 0.98)) !important;
	}

	/* ====== Responsive admin (v3.3) ======
	   Antes: solo radios y botones a 10px (inutilizables en móvil).
	   Ahora: tablas desplazables, inputs a 16px (evita el zoom de iOS),
	   botones táctiles de 40px y diálogos que caben en pantalla. */
	@media (max-width: 768px) {
		table.table,
		table.tablebg,
		table.admin_table,
		table.list {
			border-radius: 8px;
		}
		#content, .content, #page, .page {
			width: 100% !important;
			padding: 6px !important;
			box-sizing: border-box !important;
		}
		table.table, table.tablebg, table.admin_table, table.list {
			display: block !important;
			width: 100% !important;
			overflow-x: auto !important;
			-webkit-overflow-scrolling: touch !important;
		}
		input[type="text"], input[type="password"], input[type="number"],
		input[type="email"], input[type="date"], input[type="time"], input[type="url"] {
			width: 100% !important;
			max-width: 100% !important;
			box-sizing: border-box !important;
			font-size: 16px !important;
			min-height: 38px !important;
		}
		select, textarea {
			max-width: 100% !important;
			font-size: 16px !important;
		}
		input[type="submit"],
		input[type="button"],
		button {
			padding: 9px 14px !important;
			font-size: 13px !important;
			min-height: 40px !important;
		}
		.ui-dialog {
			max-width: 94vw !important;
		}
		.astroadmtn_title { font-size: 15px !important; letter-spacing: 1px !important; }
	}

	/* ====== Fix responsive móvil (no pisar el original) ====== */
	@media screen and (max-width: 1024px) {
		html, body {
			background-image: url('./styles/theme/gow/img/bkd_page.jpg') !important;
			background-size: cover !important;
			background-color: #1a0a00 !important;
		}
	}
	</style>
	<!-- ✅ FIN ASTROIO ADMIN v3.0.1 -->

	<script type="text/javascript">
	var ServerTimezoneOffset = {$Offset};
	var serverTime 	= new Date({$date.0}, {$date.1 - 1}, {$date.2}, {$date.3}, {$date.4}, {$date.5});
	var xsize 	= screen.width;
	var ysize 	= screen.height;
	var breite	= 720;
	var hoehe	= 300;
	var xpos	= (xsize-breite) / 2;
	var ypos	= (ysize-hoehe) / 2;
	var Ready		= "{$LNG.ready}";
	var Skin		= "{$dpath}";
	var Lang		= "{$lang}";
	var head_info	= "{$LNG.fcm_info}";
	var days 		= {$LNG.week_day|json|default:'[]'} 
	var months 		= {$LNG.months|json|default:'[]'} ;
	var tdformat	= "{$LNG.js_tdformat}";
	function openEdit(id, type) {
		var editlist = window.open("?page=qeditor&edit="+type+"&id="+id, "edit", "scrollbars=yes,statusbar=no,toolbar=no,location=no,directories=no,resizable=no,menubar=no,width=850,height=600,screenX="+((xsize-600)/2)+",screenY="+((ysize-850)/2)+",top="+((ysize-600)/2)+",left="+((xsize-850)/2));
		editlist.focus();
	}
	</script> 
	<script type="text/javascript" src="./scripts/base/jquery.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.ui.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.cookie.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.fancybox.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.validationEngine.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/l18n/validationEngine/jquery.validationEngine-{$lang}.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/tooltip.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/game/base.js?v={$REV}"></script>
	{foreach item=scriptname from=$scripts}
	<script type="text/javascript" src="./scripts/game/{$scriptname}.js?v={$REV}"></script>
	{/foreach}
	<script type="text/javascript">
	$(function() {
		{$execscript}
	});
	</script>
</head>
<body id="{$smarty.get.page|default:'overview'|escape}" class="{$bodyclass}">
	<div id="tooltip" class="tip"></div>

	<!-- ✅ RADAR GLOBAL LA CUEVA PIRATA -->
	<script type="text/javascript">
	$(document).ready(function() {
		// Solo preguntar si NO estamos ya en la página de la partida
		if (window.location.href.indexOf('page=cuevaPartida') === -1) {
			setInterval(function() {
				$.post('game.php?page=cuevaAjax', { accion: 'check_estado_global' }, function(res) {
					if (res.status === 'jugando' && res.sala_id) {
						// Redirigir automáticamente al tablero
						window.location.href = 'game.php?page=cuevaPartida&sala=' + res.sala_id;
					}
				});
			}, 5000); // Consulta cada 5 segundos
		}
	});
	</script>
	<!-- ✅ FIN RADAR GLOBAL -->