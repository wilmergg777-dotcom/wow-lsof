<!DOCTYPE html>
<!--[if lt IE 7 ]> <html lang="{$lang}" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="{$lang}" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="{$lang}" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="{$lang}" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="{$lang}" class="no-js"> <!--<![endif]-->
<head>
	<meta charset="UTF-8">
	<link rel="stylesheet" type="text/css" href="styles/resource/css/login/styles.css">
	<link rel="stylesheet" href="styles/resource/font-awesome/4.5.0/css/font-awesome.min.css" />
	<link rel="stylesheet" type="text/css" href="styles/resource/css/base/jquery.fancybox.css">
	<link rel="shortcut icon" href="./favicon.ico" type="image/x-icon">
	<title>{block name="title"} - {$gameName}{/block}</title>
	<meta name="generator" content="2Moons {$VERSION}">
	<!-- 
		This website is powered by 2Moons {$VERSION}
		2Moons is a free Space Browsergame initially created by Jan-Otto Kröpke and licensed under MIT.
		2Moons is copyright 2009-2017 of Jan-Otto Kröpke. Extensions are copyright of their respective owners.
		Information and contribution at https://github.com/HikeGame/2Moons-1.9/
	-->
	<meta name="keywords" content="AstroIO, XNova, 2Moons, Space, Browsergame, Estrategia espacial, Servidor privado">
	<meta name="description" content="AstroIO — Juego de estrategia espacial en tiempo real. Construye tu imperio, gestiona recursos, investiga tecnologías, forja alianzas y conquista la galaxia.">
	<meta name="viewport" content="width=device-width" /> <!-- Responsive -->

	<!-- ═══ AstroIO: theme-color para navegadores móviles ═══ -->
	<meta name="theme-color" content="#0f1624">

	<!-- New code -->
	<!--<script src="http://code.jquery.com/jquery.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script> -->

	<!--[if lt IE 9]>
	<script src="scripts/base/html5.js"></script>
	<![endif]-->
	<script src="scripts/base/jquery.js"></script>
	<script src="scripts/base/jquery.cookie.js"></script>
	<script src="scripts/base/jquery.fancybox.js?v={$REV}"></script>
	<script src="scripts/login/main.js"></script>
	<script>{if isset($code)}var loginError = {$code|json};{/if}</script>
	{block name="script"}{/block}

	<!-- ═══════════════════════════════════════════════
	     AstroIO v3.0 — Variables globales del tema
	     Compatibilidad con v2.2 (--astroio-*) preservada
	     Disponibles en TODOS los templates del juego
	     Uso: var(--bg-card), var(--accent-cyan), etc.
	     ═══════════════════════════════════════════════ -->
	<style>
	:root {
		/* ═══════════════════════════════════════════
		   v2.2 — Sistema antiguo (PRESERVADO)
		   No tocar: templates v2.2 pueden usarlas
		   ═══════════════════════════════════════════ */
		/* Fondo */
		--astroio-bg-dark:   #0f1624;
		--astroio-bg-mid:    #1a2332;
		--astroio-bg-light:  #1e3a5f;

		/* Acento principal */
		--astroio-cyan:      #00ccff;
		--astroio-cyan-hi:   #00e0ff;

		/* Textos */
		--astroio-text:      #c8d6e5;
		--astroio-text-dim:  #a8b8c8;
		--astroio-text-mute: #7a8ba0;

		/* Estados */
		--astroio-success:   #66ff99;
		--astroio-danger:    #ff4488;
		--astroio-warning:   #ffaa33;
		--astroio-info:      #00e0ff;
		--astroio-purple:    #aa44ff;

		/* Botones */
		--astroio-btn-blue:  linear-gradient(180deg, #0066cc 0%, #0099ff 100%);
		--astroio-btn-green: linear-gradient(180deg, #228833 0%, #66ff99 100%);
		--astroio-btn-red:   linear-gradient(180deg, #cc2244 0%, #ff4488 100%);
		--astroio-btn-orange:linear-gradient(180deg, #aa6600 0%, #ffaa33 100%);
		--astroio-btn-purple:linear-gradient(180deg, #7700cc 0%, #aa44ff 100%);

		/* Sombras */
		--astroio-shadow:    0 4px 14px rgba(0,0,0,0.4);
		--astroio-shadow-lg: 0 8px 24px rgba(0,0,0,0.5);
		--astroio-glow-cyan: 0 0 14px rgba(0,224,255,0.35);
		--astroio-glow-green:0 0 14px rgba(102,255,153,0.5);
		--astroio-glow-red:  0 0 14px rgba(255,68,136,0.5);

		/* Bordes */
		--astroio-radius-sm: 6px;
		--astroio-radius-md: 8px;
		--astroio-radius-lg: 10px;
		--astroio-radius-xl: 12px;

		/* ═══════════════════════════════════════════
		   v3.0 — Sistema nuevo (AÑADIDO)
		   Usar en templates migrados a v3.0
		   ═══════════════════════════════════════════ */
		/* Fondos glassmorphism */
		--bg-dark:       rgba(11, 16, 30, 0.55);
		--bg-card:       rgba(15, 23, 42, 0.75);
		--bg-card-solid: rgba(15, 23, 42, 0.85);
		--bg-inner:      rgba(0, 0, 0, 0.35);

		/* Bordes */
		--border-color:  #1e293b;

		/* Textos */
		--text-main:     #cbd5e1;
		--text-muted:    #94a3b8;
		--text-title:    #ffffff;

		/* Acentos por módulo */
		--accent-blue:   #3b82f6;
		--accent-cyan:   #00e0ff;
		--accent-purple: #8b5cf6;
		--accent-gold:   #fbbf24;
		--accent-green:  #4aff88;
		--accent-red:    #ef4444;
	}
	</style>
</head>
<body id="{$smarty.get.page|default:'overview'|escape}" class="{$bodyclass}">