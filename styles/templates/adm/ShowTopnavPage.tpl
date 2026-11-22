{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO ADMIN TOPNAV v3.2 — Barra superior del panel admin
   Prefijo: .astroadmtn_
   Acento: 🔷 Cyan (#00e0ff)
   NUEVO v3.2:
     - Botones CENTRADOS debajo del título "PANEL DE ADMINISTRACIÓN"
     - Botón "REINICIAR UNIVERSO" rojo pulsante antes de SALIR
     - Doble confirmación por JS (escribir REINICIAR + confirm final)
   ══════════════════════════════════════════════════════════════ *}

<style>
:root {
	--bg-dark:       rgba(11, 16, 30, 0.55);
	--bg-card:       rgba(15, 23, 42, 0.75);
	--bg-card-solid: rgba(15, 23, 42, 0.85);
	--bg-inner:      rgba(0, 0, 0, 0.35);
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

/* ====== Contenedor general de la barra ====== */
.astroadmtn_wrap {
	width: 100%;
	padding: 10px 14px 12px 14px;
	box-sizing: border-box;
	background: rgba(15, 23, 42, 0.75);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border-bottom: 1px solid rgba(0, 224, 255, 0.25);
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
	color: var(--text-main);
	font-family: 'Segoe UI', Tahoma, Verdana, sans-serif;
	text-align: center;
}

/* ====== Título principal ====== */
.astroadmtn_title {
	font-size: 22px;
	font-weight: 800;
	font-variant: small-caps;
	text-align: center;
	width: 100%;
	color: var(--text-title);
	letter-spacing: 2px;
	text-shadow:
		0 2px 8px rgba(0, 0, 0, 0.7),
		0 0 20px rgba(0, 224, 255, 0.5);
	padding: 4px 0 10px 0;
	margin: 0;
}

/* ══════════════════════════════════════════════════════════════
   Fila de controles (select + botones) — AHORA CENTRADA
   ══════════════════════════════════════════════════════════════ */
.astroadmtn_row {
	display: flex;
	align-items: center;
	justify-content: center;   /* ← CAMBIO: antes flex-end */
	gap: 8px;
	flex-wrap: wrap;
	margin: 0 auto;
	max-width: 100%;
}

/* ====== Select de universo ====== */
#universe {
	background: rgba(0, 0, 0, 0.5) !important;
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	border: 1px solid rgba(0, 224, 255, 0.4) !important;
	border-radius: 8px !important;
	color: #ffffff !important;
	padding: 6px 12px !important;
	font-weight: 700 !important;
	font-size: 11px !important;
	font-family: inherit !important;
	cursor: pointer !important;
	outline: none !important;
	transition: 0.25s ease !important;
	appearance: none;
	background-image:
		linear-gradient(45deg, transparent 50%, var(--accent-cyan) 50%),
		linear-gradient(135deg, var(--accent-cyan) 50%, transparent 50%) !important;
	background-position:
		calc(100% - 16px) center,
		calc(100% - 11px) center !important;
	background-size: 5px 5px, 5px 5px !important;
	background-repeat: no-repeat !important;
	padding-right: 30px !important;
}
#universe:hover,
#universe:focus {
	border-color: var(--accent-cyan) !important;
	box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
	transform: translateY(-1px);
}
#universe option {
	background: #0f1624;
	color: #ffffff;
	padding: 6px;
}

/* ====== Botones de navegación (.topn) ====== */
.topn {
	display: inline-block;
	background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	border: 1px solid rgba(0, 224, 255, 0.4) !important;
	border-radius: 8px !important;
	color: #ffffff !important;
	padding: 6px 14px !important;
	font-weight: 700 !important;
	font-size: 11px !important;
	text-decoration: none !important;
	text-transform: uppercase !important;
	letter-spacing: 0.6px !important;
	text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
	transition: 0.25s ease !important;
	white-space: nowrap;
}
.topn:hover {
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 224, 255, 0.95)) !important;
	box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 4px 12px rgba(0, 0, 0, 0.5) !important;
	color: #ffffff !important;
	transform: translateY(-2px);
}

/* ====== Botón de logout (.out) ====== */
.out {
	display: inline-block;
	background: linear-gradient(135deg, rgba(136, 0, 34, 0.9), rgba(204, 0, 51, 0.9)) !important;
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	border: 1px solid rgba(239, 68, 68, 0.5) !important;
	border-radius: 8px !important;
	color: #ffffff !important;
	padding: 6px 14px !important;
	font-weight: 700 !important;
	font-size: 11px !important;
	text-decoration: none !important;
	text-transform: uppercase !important;
	letter-spacing: 0.6px !important;
	text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
	transition: 0.25s ease !important;
	white-space: nowrap;
}
.out:hover {
	background: linear-gradient(135deg, rgba(204, 0, 51, 0.95), rgba(239, 68, 68, 0.95)) !important;
	box-shadow: 0 0 16px rgba(239, 68, 68, 0.6), 0 4px 12px rgba(0, 0, 0, 0.5) !important;
	color: #ffffff !important;
	transform: translateY(-2px);
}

/* ══════════════════════════════════════════════════════════════
   NUEVO v3.1 — Botón "REINICIAR UNIVERSO" rojo pulsante
   ══════════════════════════════════════════════════════════════ */
.reset-universe-btn {
	display: inline-block;
	background: linear-gradient(135deg, rgba(180, 0, 0, 0.95), rgba(255, 40, 40, 0.95)) !important;
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	border: 1px solid rgba(255, 100, 100, 0.7) !important;
	border-radius: 8px !important;
	color: #ffffff !important;
	padding: 6px 14px !important;
	font-weight: 800 !important;
	font-size: 11px !important;
	text-decoration: none !important;
	text-transform: uppercase !important;
	letter-spacing: 0.8px !important;
	text-shadow: 0 1px 3px rgba(0, 0, 0, 0.7);
	transition: 0.25s ease !important;
	white-space: nowrap;
	cursor: pointer;
	position: relative;
	animation: reset-pulse 2s infinite;
}

.reset-universe-btn:hover {
	background: linear-gradient(135deg, rgba(255, 40, 40, 0.98), rgba(255, 80, 80, 0.98)) !important;
	box-shadow: 0 0 22px rgba(255, 50, 50, 0.9), 0 4px 12px rgba(0, 0, 0, 0.6) !important;
	color: #ffffff !important;
	transform: translateY(-2px) scale(1.04);
}

.reset-universe-btn:active {
	transform: translateY(0) scale(0.98);
}

/* Animación pulsante roja */
@keyframes reset-pulse {
	0%, 100% {
		box-shadow:
			0 0 8px rgba(255, 50, 50, 0.6),
			0 0 16px rgba(255, 50, 50, 0.3),
			0 2px 6px rgba(0, 0, 0, 0.5);
	}
	50% {
		box-shadow:
			0 0 16px rgba(255, 50, 50, 1),
			0 0 28px rgba(255, 50, 50, 0.6),
			0 2px 6px rgba(0, 0, 0, 0.5);
	}
}

/* ====== Responsive ======
   v3.3: la barra superior vive en un iframe con alto automático
   (ShowIndexPage), así que puede envolver sin cortarse. Botones
   táctiles legibles en vez de los 10px anteriores. */
@media (max-width: 900px) {
	.astroadmtn_wrap { padding: 8px 10px 10px 10px; }
	.astroadmtn_title { font-size: 16px; letter-spacing: 1px; padding-bottom: 8px; }
	.astroadmtn_row { justify-content: center; gap: 6px; }
	.topn, .out, .reset-universe-btn {
		padding: 9px 12px !important;
		font-size: 12px !important;
		min-height: 38px !important;
		display: inline-flex !important;
		align-items: center !important;
		white-space: normal !important;
		text-align: center !important;
	}
	#universe {
		font-size: 13px !important;
		min-height: 38px !important;
	}
}
</style>

<div class="astroadmtn_wrap">

	<div class="astroadmtn_title">{$adm_cp_title}</div>

	<div class="astroadmtn_row">

		{if $authlevel == $smarty.const.AUTH_ADM}
		<select id="universe">
		{html_options options=$AvailableUnis selected=$UNI}
		</select>
		{/if}

		<a href="admin.php?page=overview" target="Hauptframe" class="topn">{$adm_cp_index}</a>

		{if $authlevel == $smarty.const.AUTH_ADM}
		<a href="?page=universe&amp;sid={$sid}" target="Hauptframe" class="topn">{$mu_universe}</a>
		<a href="?page=rights&amp;mode=rights&amp;sid={$sid}" target="Hauptframe" class="topn">{$mu_moderation_page}</a>
		<a href="?page=rights&amp;mode=users&amp;sid={$sid}" target="Hauptframe" class="topn">{$ad_authlevel_title}</a>
		{/if}

		{if $id == 1}
		<a href="?page=reset&amp;sid={$sid}" target="Hauptframe" class="topn">{$re_reset_universe}</a>
		{/if}

		{* ═══════════════════════════════════════════════════════════
		   NUEVO v3.1 — BOTÓN "REINICIAR UNIVERSO" rojo pulsante
		   Solo visible para admin nivel 3 (AUTH_ADM)
		   ═══════════════════════════════════════════════════════════ *}
		{if $authlevel == $smarty.const.AUTH_ADM}
		<a href="javascript:void(0);"
		   onclick="astroioResetUniverse();"
		   class="reset-universe-btn"
		   title="⚠ REINICIAR UNIVERSO — Borra TODOS los datos de juego. Esta acción NO se puede deshacer.">
			⚠ REINICIAR UNIVERSO
		</a>
		{/if}

		<a href="javascript:top.location.href='game.php';" target="_top" class="out">{$adm_cp_logout}</a>

	</div>

</div>

<script>
/* ═══════════════════════════════════════════════════════════════
   ASTROIO ADMIN v3.2 — Doble confirmación para REINICIAR UNIVERSO
   ═══════════════════════════════════════════════════════════════ */
function astroioResetUniverse() {

	// ─── Paso 1: Primera advertencia ───
	var paso1 = confirm(
		'⚠⚠⚠  ATENCIÓN  ⚠⚠⚠\n\n' +
		'Vas a REINICIAR EL UNIVERSO.\n\n' +
		'Esto BORRARÁ TODOS los datos de juego:\n' +
		'  • Usuarios (excepto admins)\n' +
		'  • Planetas y lunas\n' +
		'  • Flotas en vuelo\n' +
		'  • Alianzas\n' +
		'  • Investigaciones y edificios\n' +
		'  • Mensajes y reportes\n' +
		'  • Puntuaciones y rankings\n\n' +
		'❌ ESTA ACCIÓN NO SE PUEDE DESHACER ❌\n\n' +
		'¿Quieres continuar?'
	);

	if (!paso1) {
		return false;
	}

	// ─── Paso 2: Escribir la palabra REINICIAR ───
	var paso2 = prompt(
		'⚠ CONFIRMACIÓN FINAL ⚠\n\n' +
		'Para confirmar que quieres BORRAR TODO, escribe la palabra:\n\n' +
		'        REINICIAR\n\n' +
		'(en mayúsculas, sin espacios)'
	);

	if (paso2 === null) {
		return false;
	}

	if (paso2.trim().toUpperCase() !== 'REINICIAR') {
		alert('❌ Palabra incorrecta. La acción ha sido CANCELADA.\n\nEscribiste: "' + paso2 + '"\nEsperado: "REINICIAR"');
		return false;
	}

	// ─── Paso 3: Última advertencia ───
	var paso3 = confirm(
		'🔴 ÚLTIMA OPORTUNIDAD 🔴\n\n' +
		'Has escrito "REINICIAR" correctamente.\n\n' +
		'Si pulsas ACEPTAR, el universo será BORRADO AHORA MISMO.\n\n' +
		'¿Estás 100% SEGURO?'
	);

	if (!paso3) {
		alert('✅ Acción cancelada. El universo está a salvo.');
		return false;
	}

	// ─── Ejecutar: redirigir al endpoint de reset ───
	var url = '?page=reset&sid={$sid}&confirm=1&t=' + Date.now();

	if (window.parent && window.parent.frames && window.parent.frames['Hauptframe']) {
		window.parent.frames['Hauptframe'].location.href = url;
	} else {
		window.location.href = url;
	}

	alert('⏳ Ejecutando reinicio del universo...\n\nSe te redirigirá a la página de reset. Sigue las instrucciones de ahí para completarlo.');
}

$(function() {
	$('#universe').on('change', function(e) {
		parent.frames['Hauptframe'].location.href = parent.frames['Hauptframe'].location.href+'&uni='+$(this).val();
		parent.frames['rightFrame'].location.reload();
	});
});
</script>
{include file="overall_footer.tpl"}