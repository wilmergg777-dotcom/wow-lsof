{* ============================================================
   ASTROIO v8.0 &mdash; LOGIN ULTIMATE (clon de los archivos reales de
   https://github.com/ultimateXnova/ultimateXnova, tema nextgen)
   styles/templates/login/main.header.tpl
   Bootstrap 5 + UIKit + fuentes Rajdhani/Space Mono + login.css
   + capas .login-background (misma imagen animada de la nave).
   Meta y scripts propios del juego conservados.
   ============================================================ *}
<!DOCTYPE html>
<!--[if lt IE 7 ]> <html lang="{$lang}" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="{$lang}" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="{$lang}" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="{$lang}" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="{$lang}" class="no-js"> <!--<![endif]-->
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	{assign var="REV" value="1.0.0.8" nocache}

	<!-- Bootstrap 5 (igual que ultimateXnova) -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
	<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js" integrity="sha384-IQsoLXl5PILFhosVNubq5LC7Qb9DXgDA9i+tQ8Zj3iwWAwPtgFTxbJ8NT4GN1R8p" crossorigin="anonymous"></script>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.min.js" integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF" crossorigin="anonymous"></script>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.3/font/bootstrap-icons.css">

	<!-- NG Fonts + Libraries + CSS (copiados de ultimateXnova, tema nextgen) -->
	<link rel="stylesheet" href="styles/theme/gow/ultimate/css/fonts.css">
	<link rel="stylesheet" href="styles/theme/gow/ultimate/css/uikit.min.css">
	<link rel="stylesheet" href="styles/theme/gow/ultimate/css/login.css">
	<link rel="stylesheet" href="styles/theme/gow/ultimate/css/style.css">

	<link rel="shortcut icon" href="./favicon.ico" type="image/x-icon">
	<title>{block name="title"} - {$gameName}{/block}</title>
	<meta name="generator" content="2Moons {$VERSION}">
	<meta name="keywords" content="AstroIO, XNova, 2Moons, Space, Browsergame, Estrategia espacial, Servidor privado">
	<meta name="description" content="AstroIO &mdash; Juego de estrategia espacial en tiempo real. Construye tu imperio, gestiona recursos, investiga tecnolog&iacute;as, forja alianzas y conquista la galaxia.">
	<meta name="theme-color" content="#000000">

	<!--[if lt IE 9]>
	<script src="scripts/base/html5.js"></script>
	<![endif]-->
	<script src="scripts/base/jquery.js"></script>
	<script src="scripts/base/jquery.cookie.js"></script>
	<script src="scripts/base/jquery.fancybox.js?v={$REV}"></script>
	<script src="scripts/login/main.js"></script>
	<script>{if isset($code)}var loginError = {$code|json};{/if}</script>
	{block name="script"}{/block}

	<style>
	/* El style.css de ultimate pide img/background/mars.webp que no usamos:
	   el fondo real del login son las capas .login-background */
	html { background-image: none !important; background: #000 !important; }
	</style>
</head>
<body id="{$smarty.get.page|default:'overview'|escape}" class="{$bodyclass} login">
	<div class="login-background">
		<div class="bg-1"></div>
		<div class="bg-2"></div>
		<div class="bg-3"></div>
	</div>
<div id="page">