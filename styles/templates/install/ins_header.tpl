<!DOCTYPE html>

<!--[if lt IE 7 ]> <html lang="{$lang}" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="{$lang}" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="{$lang}" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="{$lang}" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="{$lang}" class="no-js"> <!--<![endif]-->
<head>
	<title>{$title}</title>
	<meta name="generator" content="2Moons">
	<!-- 
		This website is powered by 2Moons
		2Moons is a free Space Browsergame initially created by Jan-Otto Kröpke and licensed under MIT.
		2Moons is copyright 2009-2016 of Jan-Otto Kröpke. Extensions are copyright of their respective owners.
		Information and contribution at https://github.com/jkroepke/2Moons/
	-->
	{if !empty($goto)}
	<meta http-equiv="refresh" content="{$gotoinsec};URL={$goto}">
	{/if}
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" type="text/css" href="../styles/resource/css/base/boilerplate.css">
	<link rel="stylesheet" type="text/css" href="../styles/resource/css/ingame/main.css">
	<link rel="stylesheet" type="text/css" href="../styles/resource/css/install/main.css">
	<link rel="stylesheet" type="text/css" href="../styles/resource/css/base/jquery.css">
	<link rel="stylesheet" type="text/css" href="../styles/resource/css/base/jquery.fancybox.css">
	<link rel="stylesheet" type="text/css" href="../styles/resource/css/base/validationEngine.jquery.css">
	<link rel="stylesheet" type="text/css" href="../styles/theme/gow/formate.css">
	<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon">
	<script type="text/javascript" src="../scripts/base/jquery.js"></script>
	<script type="text/javascript" src="../scripts/base/jquery.ui.js"></script>
	<script type="text/javascript" src="../scripts/base/jquery.cookie.js"></script>
	<script type="text/javascript" src="../scripts/base/jquery.fancybox.js"></script>
	<script type="text/javascript" src="../scripts/base/jquery.validationEngine.js"></script>
	<script type="text/javascript" src="../scripts/l18n/validationEngine/jquery.validationEngine-{$lang}.js"></script>
	<script type="text/javascript" src="../scripts/base/tooltip.js"></script>
	<script type="text/javascript" src="../scripts/game/base.js"></script>
	{foreach item=scriptname from=$scripts}
	<script type="text/javascript" src="../scripts/game/{$scriptname}.js"></script>
	{/foreach}
	{block name="script"}{/block}
	<script type="text/javascript">
	$(function() {
		{$execscript}
	});
	</script>

	{* ═══════════════════════════════════════════════════════════
	   ASTROIO OVERRIDE — Installer Header v1.0
	   Pisa los estilos del instalador de 2Moons
	   Paleta canónica: #0f1624 → #1a2332 / #1e3a5f / #00ccff
	   ═══════════════════════════════════════════════════════════ *}
	<style>
	/* ─── Base ─── */
	html, body {
		background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%) !important;
		color: #c8d6e5 !important;
		font-family: 'Segoe UI', Roboto, Arial, sans-serif !important;
		font-size: 12.5px;
		margin: 0;
		padding: 0;
		min-height: 100vh;
	}

	body > div:first-child,
	body > div {
		background: transparent !important;
	}

	/* ─── Enlaces ─── */
	a, a:link, a:visited {
		color: #00ccff !important;
		text-decoration: none;
		transition: 0.25s ease;
	}
	a:hover {
		color: #00e0ff !important;
		text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
	}

	/* ─── Tabla principal del instalador (960px) ─── */
	table[width="960"] {
		background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%) !important;
		border: 1px solid #1e3a5f !important;
		border-radius: 10px !important;
		box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5) !important;
		overflow: hidden;
		margin: 20px auto !important;
		width: 960px !important;
		max-width: 96vw;
		border-collapse: collapse;
	}

	/* ─── Cabecera del instalador (th) ─── */
	table[width="960"] > tbody > tr > th,
	table[width="960"] th {
		background: linear-gradient(180deg, #004488 0%, #0077cc 100%) !important;
		border-bottom: 1px solid #00ccff !important;
		color: #ffffff !important;
		font-size: 12px !important;
		font-weight: 700 !important;
		padding: 10px 16px !important;
		text-transform: uppercase;
		letter-spacing: 1.5px;
		text-align: left;
	}

	/* ─── Celdas del instalador ─── */
	table[width="960"] td {
		color: #c8d6e5 !important;
		font-size: 12.5px;
		line-height: 1.7;
		padding: 12px 16px !important;
	}

	/* ─── Contenido del instalador ─── */
	.installcontent {
		color: #c8d6e5 !important;
	}

	/* ─── Headings del instalador ─── */
	.installcontent h1,
	.installcontent h2,
	.installcontent h3 {
		color: #00ccff !important;
		text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
		font-weight: 700;
		letter-spacing: 1px;
	}

	/* ─── Selector de idioma (instalador) ─── */
	#lang {
		color: #c8d6e5 !important;
	}
	#lang select {
		background: rgba(15, 22, 36, 0.95) !important;
		border: 1px solid #1e3a5f !important;
		border-radius: 6px !important;
		color: #c8d6e5 !important;
		padding: 5px 10px !important;
		font-size: 12px !important;
		outline: none;
	}
	#lang select:focus {
		border-color: #00ccff !important;
		box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
	}

	/* ─── Inputs / Selects / Textareas ─── */
	input[type="text"],
	input[type="password"],
	input[type="email"],
	input[type="number"],
	select,
	textarea {
		background: rgba(15, 22, 36, 0.95) !important;
		border: 1px solid #1e3a5f !important;
		border-radius: 6px !important;
		color: #c8d6e5 !important;
		padding: 7px 10px !important;
		font-size: 12px !important;
		font-family: 'Segoe UI', Roboto, Arial, sans-serif !important;
		outline: none;
		transition: 0.25s ease;
	}
	input[type="text"]:focus,
	input[type="password"]:focus,
	input[type="email"]:focus,
	input[type="number"]:focus,
	select:focus,
	textarea:focus {
		border-color: #00ccff !important;
		box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
	}

	/* ─── Checkboxes / Radios ─── */
	input[type="checkbox"],
	input[type="radio"] {
		accent-color: #00ccff;
		cursor: pointer;
	}

	/* ─── Botones ─── */
	input[type="submit"],
	input[type="button"],
	input[type="reset"],
	button,
	.btn,
	.button {
		background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
		border: 1px solid #00ccff !important;
		border-radius: 6px !important;
		color: #ffffff !important;
		padding: 9px 24px !important;
		font-size: 12px !important;
		font-weight: 700 !important;
		cursor: pointer;
		text-transform: uppercase;
		letter-spacing: 1px;
		transition: 0.25s ease;
		text-shadow: none;
	}
	input[type="submit"]:hover,
	input[type="button"]:hover,
	input[type="reset"]:hover,
	button:hover,
	.btn:hover,
	.button:hover {
		background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
		box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
		transform: translateY(-1px);
	}
	input[type="submit"]:active,
	input[type="button"]:active,
	button:active {
		transform: translateY(0);
	}

	/* ─── Tablas internas del instalador ─── */
	.installcontent table,
	table:not([width="960"]) {
		background: rgba(15, 22, 36, 0.4) !important;
		border-collapse: collapse;
		border: 1px solid #1e3a5f !important;
		border-radius: 6px;
		overflow: hidden;
	}
	.installcontent table th,
	table:not([width="960"]) th {
		background: linear-gradient(180deg, #004488 0%, #0077cc 100%) !important;
		color: #ffffff !important;
		border-bottom: 1px solid #00ccff !important;
		padding: 8px 12px !important;
		font-size: 11px !important;
		text-transform: uppercase;
		letter-spacing: 1px;
	}
	.installcontent table td,
	table:not([width="960"]) td {
		color: #c8d6e5 !important;
		border-bottom: 1px solid rgba(0, 204, 255, 0.08) !important;
		padding: 8px 12px !important;
		font-size: 12px !important;
	}

	/* ─── Mensajes OK / error (los que ya existen en el instalador) ─── */
	.ok, .yes, .success {
		color: #66ff99 !important;
	}
	.no, .error, .fatalerror {
		color: #ff4488 !important;
	}

	/* ─── Tooltip ─── */
	#tooltip,
	.tip {
		background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%) !important;
		border: 1px solid #00ccff !important;
		border-radius: 6px !important;
		color: #c8d6e5 !important;
		box-shadow: 0 4px 14px rgba(0, 0, 0, 0.5);
		font-size: 12px;
		padding: 8px 12px;
	}

	/* ─── Scroll horizontal para tablas anchas (responsive) ─── */
	table[width="960"] {
		overflow-x: auto;
		display: block;
	}
	@media (min-width: 1000px) {
		table[width="960"] {
			display: table;
		}
	}

	/* ─── Responsive ─── */
	@media (max-width: 768px) {
		table[width="960"] {
			width: 100% !important;
			margin: 10px auto !important;
			border-radius: 6px !important;
		}
		table[width="960"] th,
		table[width="960"] td {
			padding: 8px 10px !important;
			font-size: 11.5px !important;
		}
	}
	</style>
</head>
<body id="step{if isset($smarty.get.step)}{$smarty.get.step|escape|default:'intro'}{else}intro{/if}">
<div id="tooltip" class="tip"></div>
<div><p>&nbsp;</p></div>
<table width="960">
<tr>
	<th colspan="3">{$header}</th>
</tr>