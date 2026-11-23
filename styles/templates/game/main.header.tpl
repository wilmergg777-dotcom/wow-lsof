<!DOCTYPE html>

<!--[if lt IE 7 ]> <html lang="{$lang}" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="{$lang}" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="{$lang}" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="{$lang}" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="{$lang}" class="no-js"> <!--<![endif]-->
<head>
	<title>{block name="title"} - {$uni_name} - {$game_name}{/block}</title>
	<meta name="generator" content="2Moons {$VERSION}">
	<!-- 
		This website is powered by 2Moons {$VERSION}
		2Moons is a free Space Browsergame initially created by Jan Kröpke and licensed under GNU/GPL.
		2Moons is copyright 2009-2018 of Jan Kröpke. Extensions are copyright of their respective owners.
		Information and contribution at http://2moons.de/
	-->
	{if !empty($goto)}
	<meta http-equiv="refresh" content="{$gotoinsec};URL={$goto}">
	{/if}
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="theme-color" content="#0f1624">

	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/boilerplate.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/ingame/main.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/ingame/all.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/jquery.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/jquery.fancybox.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="./styles/resource/css/base/validationEngine.jquery.css?v={$REV}">
	<link rel="stylesheet" type="text/css" href="{$dpath}ingame.css?v={$REV}">
	<link rel="shortcut icon" href="./favicon.ico" type="image/x-icon">

	<!-- ═══════════════════════════════════════════════
	     AstroIO v3.0 — Variables globales del tema
	     Disponibles en TODOS los templates del juego
	     Uso: var(--bg-card), var(--accent-cyan), etc.
	     Compatibilidad v2.2 (--astroio-*) preservada
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

	/* ═══════════════════════════════════════════════
	   AstroIO v3.0 — Override de jQuery UI Dialog
	   Aplica a TODOS los popups del sistema:
	   - INFORMACIÓN / SYS_FORWARD
	   - Confirmaciones (sí/no)
	   - Alertas de error / éxito
	   - Cualquier .ui-dialog generado por JS
	   ═══════════════════════════════════════════════ */

	/* ─── Contenedor del diálogo ─── */
	.ui-dialog {
		background: var(--bg-card) !important;
		backdrop-filter: blur(8px) !important;
		-webkit-backdrop-filter: blur(8px) !important;
		border: 2px solid rgba(0, 224, 255, 0.4) !important;
		border-radius: 14px !important;
		box-shadow:
			0 8px 30px rgba(0, 0, 0, 0.6),
			0 0 40px rgba(0, 224, 255, 0.1) !important;
		padding: 0 !important;
		overflow: hidden !important;
		color: #cbd5e1 !important;
		font-family: 'Segoe UI', Roboto, sans-serif !important;
	}

	/* ─── Barra de título (INFORMACIÓN) ─── */
	.ui-dialog .ui-dialog-titlebar {
		background: linear-gradient(135deg, #0a5a8c, #00a8e0) !important;
		border: none !important;
		border-radius: 12px 12px 0 0 !important;
		padding: 10px 16px !important;
		color: #ffffff !important;
		font-weight: 700 !important;
		font-size: 13px !important;
		letter-spacing: 1px !important;
		text-transform: uppercase !important;
		text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5), 0 0 10px rgba(0, 224, 255, 0.4) !important;
		position: relative !important;
	}

	.ui-dialog .ui-dialog-title {
		color: #ffffff !important;
		font-weight: 700 !important;
		font-size: 12px !important;
	}

	/* Botón de cerrar (X) */
	.ui-dialog .ui-dialog-titlebar-close {
		background: rgba(0, 0, 0, 0.3) !important;
		border: 1px solid rgba(255, 255, 255, 0.3) !important;
		border-radius: 4px !important;
		width: 20px !important;
		height: 20px !important;
		top: 50% !important;
		margin-top: -10px !important;
		right: 10px !important;
		opacity: 0.8 !important;
	}
	.ui-dialog .ui-dialog-titlebar-close:hover {
		background: rgba(239, 68, 68, 0.5) !important;
		border-color: #ef4444 !important;
		opacity: 1 !important;
	}

	/* ─── Contenido del diálogo ─── */
	.ui-dialog .ui-dialog-content {
		background: transparent !important;
		color: #cbd5e1 !important;
		padding: 18px 22px !important;
		font-size: 12.5px !important;
		line-height: 1.6 !important;
		border: none !important;
	}

	.ui-dialog .ui-dialog-content p {
		color: #cbd5e1 !important;
		margin: 0 0 10px !important;
		line-height: 1.6 !important;
	}

	.ui-dialog .ui-dialog-content a {
		color: #00e0ff !important;
		text-decoration: none !important;
	}
	.ui-dialog .ui-dialog-content a:hover {
		color: #ffffff !important;
		text-shadow: 0 0 10px rgba(0, 224, 255, 0.7) !important;
	}

	/* ─── Área de botones (SYS_FORWARD) ─── */
	.ui-dialog .ui-dialog-buttonpane {
		background: rgba(0, 0, 0, 0.3) !important;
		border-top: 1px solid rgba(0, 224, 255, 0.15) !important;
		padding: 12px 18px !important;
		margin: 0 !important;
		border-radius: 0 0 12px 12px !important;
	}

	.ui-dialog .ui-dialog-buttonpane button,
	.ui-dialog .ui-button,
	.ui-dialog .ui-dialog-buttonpane .ui-button {
		background: linear-gradient(135deg, #0066cc 0%, #00a8e0 100%) !important;
		color: #ffffff !important;
		border: 1px solid #00e0ff !important;
		border-radius: 8px !important;
		padding: 7px 20px !important;
		font-size: 11.5px !important;
		font-weight: 700 !important;
		font-family: inherit !important;
		letter-spacing: 0.5px !important;
		text-transform: uppercase !important;
		text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
		cursor: pointer !important;
		transition: 0.25s ease !important;
		box-shadow: 0 4px 12px rgba(0, 224, 255, 0.25) !important;
		margin: 0 4px !important;
	}

	.ui-dialog .ui-dialog-buttonpane button:hover,
	.ui-dialog .ui-button:hover,
	.ui-dialog .ui-dialog-buttonpane .ui-button:hover {
		background: linear-gradient(135deg, #00a8e0 0%, #00e0ff 100%) !important;
		box-shadow: 0 0 22px rgba(0, 224, 255, 0.6), 0 4px 12px rgba(0, 224, 255, 0.3) !important;
		transform: translateY(-2px) !important;
	}

	.ui-dialog .ui-dialog-buttonpane button:active {
		transform: translateY(0) !important;
	}

	/* ─── Overlay (fondo oscuro detrás del popup) ─── */
	.ui-widget-overlay {
		background: rgba(0, 0, 0, 0.65) !important;
		backdrop-filter: blur(4px) !important;
		-webkit-backdrop-filter: blur(4px) !important;
	}

	/* ─── Responsive ─── */
	@media (max-width: 720px) {
		.ui-dialog {
			max-width: 95vw !important;
			margin: 0 auto !important;
		}
		.ui-dialog .ui-dialog-titlebar {
			font-size: 12px !important;
			padding: 8px 12px !important;
		}
		.ui-dialog .ui-dialog-content {
			padding: 12px 14px !important;
			font-size: 12px !important;
		}
		.ui-dialog .ui-dialog-buttonpane {
			padding: 10px 12px !important;
		}
		/* Reducir padding interno del popup al mínimo */
		.ui-dialog .ui-dialog-content {
			padding: 4px !important;
		}
		/* Quitar padding lateral del contenedor de la tabla */
		.ui-dialog .ui-dialog-content > * {
			margin: 0 !important;
		}
	}
	</style>

	<script type="text/javascript">
	var ServerTimezoneOffset = {$Offset};
	var serverTime 	= new Date({$date.0}, {$date.1 - 1}, {$date.2}, {$date.3}, {$date.4}, {$date.5});
	var startTime	= serverTime.getTime();
	var localTime 	= serverTime;
	var localTS 	= startTime;
	var Gamename	= document.title;
	var Ready		= "{$LNG.ready}";
	var Skin		= "{$dpath}";
	var Lang		= "{$lang}";
	var head_info	= "{$LNG.fcm_info}";
	var auth		= {$authlevel|default:'0'};
	var days 		= {$LNG.week_day|json|default:'[]'} 
	var months 		= {$LNG.months|json|default:'[]'} ;
	var tdformat	= "{$LNG.js_tdformat}";
	var queryString	= "{$queryString|escape:'javascript'}";
	var isPlayerCardActive	= "{$isPlayerCardActive|json}";

	setInterval(function() {
		serverTime.setSeconds(serverTime.getSeconds()+1);
	}, 1000);
	</script>
	<script type="text/javascript" src="./scripts/base/jquery.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.ui.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.cookie.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.fancybox.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/jquery.validationEngine.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/l18n/validationEngine/jquery.validationEngine-{$lang}.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/base/tooltip.js?v={$REV}"></script>
	<script type="text/javascript" src="./scripts/game/base.js?v=20260924a"></script>
	{foreach item=scriptname from=$scripts}
	<script type="text/javascript" src="./scripts/game/{$scriptname}.js?v={$REV}"></script>
	{/foreach}
	{block name="script"}{/block}
	<script type="text/javascript">
	$(function() {
		{$execscript}
	});
	</script>
	<script type="text/javascript">
	document.addEventListener('DOMContentLoaded', function() {
		var toggleBtn  = document.getElementById('astroio-mobile-toggle');
		var toggleWrap = document.getElementById('astroio-menu-toggle-wrap');
		var leftmenu   = document.getElementById('leftmenu');
		var header     = document.getElementById('header');

		if (!toggleBtn || !leftmenu) return;

		function isMobile() {
			return window.matchMedia('(max-width: 768px)').matches;
		}

		function setMenu(open) {
			document.body.classList.toggle('astroio-menu-open', open);
			if (isMobile()) {
				leftmenu.style.setProperty('display', open ? 'block' : 'none', 'important');
			} else {
				leftmenu.style.removeProperty('display');
			}
			if (toggleWrap && header) {
				if (open && isMobile()) {
					// Mover el botón debajo del menú
					leftmenu.parentNode.insertBefore(toggleWrap, leftmenu.nextSibling);
				} else {
					// Devolver el botón DESPUÉS de las alertas (no entre header y alertas)
					var alertsRow = document.getElementById('astroio-mobile-alerts');
					if (alertsRow && alertsRow.parentNode) {
						alertsRow.parentNode.insertBefore(toggleWrap, alertsRow.nextSibling);
					} else {
						header.parentNode.insertBefore(toggleWrap, header.nextSibling);
					}
				}
			}
		}

		// Estado inicial: cerrado en móvil
		if (isMobile()) {
			leftmenu.style.setProperty('display', 'none', 'important');
		}

		toggleBtn.addEventListener('click', function(e) {
			e.preventDefault();
			setMenu(!document.body.classList.contains('astroio-menu-open'));
		});

		// Cerrar al pulsar un enlace del menú
		leftmenu.addEventListener('click', function(e) {
			var a = e.target.closest('a');
			if (a && !String(a.href).startsWith('javascript:')) {
				setMenu(false);
			}
		});

		// Reajustar al cambiar de tamaño
		window.addEventListener('resize', function() {
			if (!isMobile()) {
				leftmenu.style.removeProperty('display');
				document.body.classList.remove('astroio-menu-open');
			} else {
				leftmenu.style.setProperty('display',
					document.body.classList.contains('astroio-menu-open') ? 'block' : 'none',
					'important');
			}
		});
	});
	</script>
	{* ═══ ASTROIO v7.1 — selector de diseño Fotos/Clásico (global) ═══ *}
	<script src="scripts/game/aio-design.js?v=71"></script>
</head>

<body id="{$smarty.get.page|default:'overview'|escape}" class="{$bodyclass}">
	<div id="tooltip" class="tip"></div>