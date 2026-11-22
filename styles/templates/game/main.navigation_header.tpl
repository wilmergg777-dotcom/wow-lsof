<style>
/* ===== BARRA SUPERIOR ASTROIO (SEMI-TRANSPARENTE) ===== */
#main_header {
	background: rgba(11, 16, 30, 0.72) !important;
	backdrop-filter: blur(6px) !important;
	-webkit-backdrop-filter: blur(6px) !important;
	border-bottom: 2px solid #00ccff !important;
	padding: 5px 10px !important;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.5) !important;
	display: flex !important;
	align-items: center !important;
	justify-content: space-between !important;
	font-family: 'Segoe UI', Roboto, sans-serif !important;
}

/* ===== LISTAS IZQUIERDA Y DERECHA ===== */
#main_header .main_list_left ul,
#main_header .main_list_right ul {
	display: flex !important;
	align-items: center !important;
	margin: 0 !important;
	padding: 0 !important;
	list-style: none !important;
	gap: 3px !important;
}

#main_header .main_list_left li,
#main_header .main_list_right li {
	margin: 0 !important;
	padding: 0 !important;
}

/* ===== ENLACES E ICONOS ===== */
#main_header .main_list_left a,
#main_header .main_list_right a {
	color: #66ccff !important;
	font-size: 14px !important;
	transition: all 0.25s ease !important;
	text-decoration: none !important;
	padding: 5px 8px !important;
	border-radius: 6px !important;
	display: inline-block !important;
	line-height: 1 !important;
	border: 1px solid transparent !important;
}

#main_header .main_list_left a:hover,
#main_header .main_list_right a:hover {
	color: #00e0ff !important;
	background: rgba(0, 200, 255, 0.15) !important;
	box-shadow: 0 0 12px rgba(0, 200, 255, 0.3) !important;
	border-color: rgba(0, 200, 255, 0.35) !important;
	transform: translateY(-2px) !important;
}

/* ===== BOTÓN DE VERSIÓN (V2.1) ===== */
#main_header .main_list_left a[href*="changelog"] {
	background: linear-gradient(135deg, rgba(0, 136, 68, 0.85), rgba(0, 204, 102, 0.85)) !important;
	color: #fff !important;
	font-weight: 700 !important;
	padding: 4px 10px !important;
	border-radius: 6px !important;
	font-size: 11px !important;
	border: 1px solid #00ff88 !important;
	text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
	backdrop-filter: blur(4px) !important;
	-webkit-backdrop-filter: blur(4px) !important;
}

#main_header .main_list_left a[href*="changelog"]:hover {
	background: linear-gradient(135deg, rgba(0, 204, 102, 0.95), rgba(0, 255, 136, 0.95)) !important;
	box-shadow: 0 0 14px rgba(0, 255, 136, 0.6) !important;
	color: #fff !important;
}

/* ===== BOTÓN LOGOUT (ROJO) ===== */
#main_header a[href*="logout"] {
	color: #ff6688 !important;
}

#main_header a[href*="logout"]:hover {
	color: #ff4488 !important;
	background: rgba(255, 68, 136, 0.15) !important;
	box-shadow: 0 0 12px rgba(255, 68, 136, 0.4) !important;
	border-color: rgba(255, 68, 136, 0.45) !important;
}

/* ===== SELECTOR DE PLANETA ===== */
#main_header #planetSelectorWrapper {
	display: inline-flex !important;
	align-items: center !important;
}

#main_header #planetSelector {
	background: rgba(0, 0, 0, 0.5) !important;
	backdrop-filter: blur(4px) !important;
	-webkit-backdrop-filter: blur(4px) !important;
	border: 1px solid #00ccff !important;
	color: #00e0ff !important;
	padding: 5px 10px !important;
	border-radius: 6px !important;
	font-weight: 600 !important;
	font-size: 12px !important;
	transition: all 0.25s ease !important;
	cursor: pointer !important;
	font-family: 'Segoe UI', Roboto, sans-serif !important;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4) !important;
}

#main_header #planetSelector:hover,
#main_header #planetSelector:focus {
	background: rgba(0, 200, 255, 0.20) !important;
	box-shadow: 0 0 14px rgba(0, 200, 255, 0.5) !important;
	outline: none !important;
	color: #00ffff !important;
}

#main_header #planetSelector option {
	background: #0f1624 !important;
	color: #00e0ff !important;
}

/* ===== FLECHAS DE NAVEGACIÓN DE PLANETA ===== */
#main_header > a[href*="cp="] {
	color: #00e0ff !important;
	transition: all 0.2s ease !important;
	text-decoration: none !important;
}

#main_header > a[href*="cp="]:hover {
	color: #66ffff !important;
	text-shadow: 0 0 12px rgba(0, 224, 255, 0.7) !important;
}

#main_header > a[href*="cp="] i {
	font-size: 20px !important;
	margin: 5px !important;
	vertical-align: sub !important;
}

/* ===== NOTIFICACIÓN DE MENSAJES ===== */
#newmes {
	background: linear-gradient(135deg, rgba(170, 0, 68, 0.95), rgba(255, 34, 102, 0.95)) !important;
	color: #fff !important;
	font-weight: 700 !important;
	padding: 1px 6px !important;
	border-radius: 10px !important;
	font-size: 10px !important;
	box-shadow: 0 0 8px rgba(255, 34, 102, 0.6) !important;
	margin-left: 3px !important;
	animation: pulseMsg 2s infinite !important;
}

@keyframes pulseMsg {
	0%, 100% { transform: scale(1); }
	50% { transform: scale(1.1); }
}

/* ===== 🆕 ICONO PVP EN HEADER (MOVIDO A LA DERECHA) ===== */
#main_header .header_pvp_icon {
	color: #ff4444 !important;
	position: relative !important;
	display: inline-flex !important;
	align-items: center !important;
	gap: 4px !important;
	padding: 5px 8px !important;
	border-radius: 6px !important;
	border: 1px solid rgba(255, 68, 68, 0.3) !important; /* Borde rojo sutil */
	background: rgba(255, 68, 68, 0.1) !important; /* Fondo rojo sutil */
	transition: all 0.25s ease !important;
	text-decoration: none !important;
}

#main_header .header_pvp_icon:hover {
	color: #ffffff !important;
	background: rgba(255, 50, 50, 0.3) !important;
	box-shadow: 0 0 12px rgba(255, 50, 50, 0.6) !important;
	border-color: #ff4444 !important;
	transform: translateY(-2px) !important;
}

#main_header .header_pvp_badge {
	display: inline-block;
	margin-left: 3px;
	padding: 1px 5px;
	border-radius: 8px;
	font-family: 'Courier New', monospace;
	font-size: 9px;
	font-weight: 700;
	letter-spacing: 0;
	vertical-align: middle;
	line-height: 1.2;
	transition: all 0.3s ease;
}

#main_header .header_pvp_badge.state-far {
	background: rgba(0, 200, 100, 0.18);
	color: #88ffbb;
	border: 1px solid rgba(0, 255, 130, 0.4);
}

#main_header .header_pvp_badge.state-soon {
	background: rgba(255, 200, 0, 0.20);
	color: #ffee88;
	border: 1px solid rgba(255, 220, 50, 0.55);
	animation: astroio_pvp_hdr_pulse 1.5s infinite;
}

#main_header .header_pvp_badge.state-active {
	background: rgba(255, 50, 50, 0.25);
	color: #ffbbbb;
	border: 1px solid rgba(255, 80, 80, 0.65);
	font-weight: 900;
	animation: astroio_pvp_hdr_pulse 0.9s infinite;
}

#main_header .header_pvp_badge.state-off {
	display: none;
}

@keyframes astroio_pvp_hdr_pulse {
	0%, 100% { opacity: 1; transform: scale(1); }
	50%      { opacity: 0.65; transform: scale(1.08); }
}

/* ============================================================
   ASTROIO — Mini Torneos (nuevo icono en header)
   Mismo estilo visual que el resto de iconos del header,
   pero con acento dorado para distinguirlo.
   ============================================================ */
#main_header .header_tourney_icon {
	color: #ffcc66 !important;
	position: relative !important;
	display: inline-flex !important;
	align-items: center !important;
	gap: 4px !important;
	padding: 5px 8px !important;
	border-radius: 6px !important;
	border: 1px solid transparent !important;
	transition: all 0.25s ease !important;
	text-decoration: none !important;
}

#main_header .header_tourney_icon:hover {
	color: #ffe0a0 !important;
	background: rgba(255, 180, 0, 0.15) !important;
	box-shadow: 0 0 12px rgba(255, 200, 50, 0.5) !important;
	border-color: rgba(255, 200, 50, 0.5) !important;
	transform: translateY(-2px) !important;
}

#main_header .header_tourney_icon i {
	font-size: 14px !important;
	line-height: 1 !important;
}
/* ============================================================ */

/* ============================================================
   🆕 ASTROIO — Botón de Descargas en el Header
   ============================================================ */
#main_header .header_download_icon {
	color: #00e0ff !important;
	display: inline-flex !important;
	align-items: center !important;
	padding: 5px 8px !important;
	border-radius: 6px !important;
	border: 1px solid transparent !important;
	transition: all 0.25s ease !important;
	text-decoration: none !important;
}
#main_header .header_download_icon:hover {
	color: #ffffff !important;
	background: rgba(0, 224, 255, 0.2) !important;
	box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
	border-color: rgba(0, 224, 255, 0.5) !important;
	transform: translateY(-2px) !important;
}
/* ============================================================ */

/* ═══════════════════════════════════════════════════════════
   ASTROIO — Botón MENÚ RÁPIDO + responsive móvil (v2 limpio)
   ═══════════════════════════════════════════════════════════ */

/* En escritorio ocultamos el botón píldora */
#astroio-nav-toggle-wrap { display: none !important; }

@media screen and (max-width: 768px) {

    /* ── Barra superior en flex ── */
    #main_header {
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important;
        align-items: center !important;
        gap: 4px !important;
        padding: 6px 8px !important;
    }

    /* ── Flechas + selector en una fila ── */
    #main_header > a[href*="cp="]:nth-of-type(1) {
        order: 1 !important;
        flex: 0 0 auto !important;
        min-width: 34px !important;
    }
    #main_header #planetSelectorWrapper {
        order: 2 !important;
        flex: 1 1 auto !important;
        max-width: calc(100% - 100px) !important;
        display: flex !important;
        justify-content: center !important;
        margin: 0 !important;
    }
    #main_header > a[href*="cp="]:nth-of-type(2) {
        order: 3 !important;
        flex: 0 0 auto !important;
        min-width: 34px !important;
    }
    #main_header #planetSelector {
        width: 100% !important;
        font-size: 13px !important;
        padding: 7px 10px !important;
        text-align: center !important;
        text-align-last: center !important;
        -moz-text-align-last: center !important;
    }
    #main_header > a[href*="cp="] i {
        font-size: 24px !important;
        margin: 0 !important;
        vertical-align: middle !important;
    }

    /* ── Botón píldora (toggle iconos) ── */
    #astroio-nav-toggle-wrap {
        display: inline-flex !important;
        order: 4 !important;
        flex: 0 0 auto !important;
        position: relative !important;
    }
    #astroio-nav-toggle {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 6px 12px !important;
        background: rgba(11, 16, 30, 0.7) !important;
        color: #00e0ff !important;
        border: 1px solid rgba(0, 224, 255, 0.4) !important;
        border-radius: 50px !important;
        font-size: 11px !important;
        font-weight: 700 !important;
        letter-spacing: 0.5px !important;
        cursor: pointer !important;
        white-space: nowrap !important;
    }
    #astroio-nav-toggle .astroio-nav-icon {
        display: inline-block !important;
        font-size: 12px !important;
        transition: transform 0.25s ease !important;
    }
    #astroio-nav-toggle.is-open .astroio-nav-icon {
        transform: rotate(180deg) !important;
    }
    #astroio-nav-toggle-wrap .astroio-nav-badge {
        position: absolute !important;
        top: -6px !important;
        right: -8px !important;
        background: #dc3545 !important;
        color: #fff !important;
        font-size: 10px !important;
        font-weight: 700 !important;
        padding: 2px 6px !important;
        border-radius: 10px !important;
        min-width: 16px !important;
        text-align: center !important;
        z-index: 20 !important;
    }

    /* ── Listas de iconos (se despliegan a todo el ancho) ── */
    #main_header .main_list_left  {
        order: 5 !important;
        flex: 1 1 100% !important;
        width: 100% !important;
        float: none !important;
        text-align: center !important;
    }
    #main_header .main_list_right {
        order: 6 !important;
        flex: 1 1 100% !important;
        width: 100% !important;
        float: none !important;
        text-align: center !important;
    }
    #main_header .main_list_left ul,
    #main_header .main_list_right ul {
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important;
        gap: 2px !important;
        padding: 0 !important;
        margin: 0 !important;
    }
    #main_header .main_list_left li,
    #main_header .main_list_right li {
        display: inline-block !important;
        margin: 0 !important;
    }
    #main_header .main_list_left a,
    #main_header .main_list_right a {
        font-size: 12px !important;
        padding: 5px 7px !important;
        min-width: 22px !important;
        min-height: 22px !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
    }
    #main_header .main_list_left a[href*="changelog"] {
        font-size: 10px !important;
        padding: 5px 8px !important;
    }

    /* ── Ocultar listas cuando el header está colapsado ── */
    #main_header.astroio-nav-collapsed .main_list_left,
    #main_header.astroio-nav-collapsed .main_list_right {
        display: none !important;
    }
}

</style>

<div id="main_header">
	<!-- ═══ BOTÓN MENÚ RÁPIDO (fuera, arriba) ═══ -->
	<div id="astroio-nav-toggle-wrap">
		<button id="astroio-nav-toggle" type="button" aria-label="Mostrar u ocultar menú rápido">
			<span class="astroio-nav-icon">▼</span>
		</button>
		{if $new_message > 0}
			<span class="astroio-nav-badge">{$new_message}</span>
		{/if}
	</div>
	<!-- ═══════════════════════════════════════ -->
	<div class="main_list_left">
		<ul>
			<li><a href="game.php?page=changelog" style="color: lime; font-weight: bold;">V2.3</a></li>
			<li><a href="game.php?page=overview"><i class="fas fa-home"></i></a></li>
			{if isModuleAvailable($smarty.const.MODULE_IMPERIUM)}<li><a href="game.php?page=imperium"><i class="fas fa-globe"></i></a></li>{/if}
			{if isModuleAvailable($smarty.const.MODULE_STATISTICS)}<li><a href="game.php?page=statistics"><i class="fas fa-chart-pie"></i></a></li>{/if}
			{if isModuleAvailable($smarty.const.MODULE_BATTLEHALL)}<li><a href="game.php?page=battleHall"><i class="fas fa-crosshairs"></i></a></li>{/if}
			{if isModuleAvailable($smarty.const.MODULE_RECORDS)}<li><a href="game.php?page=records"><i class="fas fa-chess-queen"></i></a></li>{/if}
			<li><a href="game.php?page=bugreport"><i class="fas fa-bug"></i></a></li>
			{if isModuleAvailable($smarty.const.MODULE_SEARCH)}<li><a href="game.php?page=search"><i class="fas fa-search"></i></a></li>{/if}
			{if isModuleAvailable($smarty.const.MODULE_MESSAGES)}<li><a href="game.php?page=messages"><i class="fas fa-envelope"></i>{nocache}{if $new_message > 0}<span id="newmes"> <span id="newmesnum">{if $new_message > 99}99+{else}{$new_message}{/if}</span></span>{/if}{/nocache}</a></li>{/if}

			{* ============================================================
			   ASTROIO — Mini Torneos (nuevo icono en header)
			   Solo se muestra si el módulo está activo en admin
			   ============================================================ *}
			{if isModuleAvailable($smarty.const.MODULE_TOURNEY)}
			<li>
				<a href="game.php?page=tourney" class="header_tourney_icon" title="Mini Torneos">
					<i class="fas fa-trophy"></i>
				</a>
			</li>
			{/if}
			{* ============================================================ *}
			
		</ul>
	</div>

	<a href="?cp={$previousPlanet}"><i class="fas fa-caret-left" style="font-size: 20px; margin: 5px; vertical-align: sub;"></i></a>
	<span id="planetSelectorWrapper">
        <label for="planetSelector"></label>
		<select id="planetSelector">
			{html_options options=$PlanetSelect selected=$current_pid}
		</select>
	</span>
	<a href="?cp={$nextPlanet}"><i class="fas fa-caret-right" style="font-size: 20px; margin: 5px; vertical-align: sub;"></i></a>

	<div class="main_list_right">
		<ul>
			{* 🆕 ICONO PVP CON COUNTDOWN (MOVIDO AQUÍ) *}
			{if isModuleAvailable($smarty.const.MODULE_PVP)}
				{assign var="pvpHArenaActive"      value=0}
				{assign var="pvpHArenaWaiting"     value=0}
				{assign var="pvpHTournamentActive" value=0}
				{assign var="pvpHTournamentStatus" value=''}
				{assign var="pvpHTournamentTime"   value=0}
				{if isset($pvp) && is_array($pvp)}
					{if isset($pvp.arenas_active)}{assign var="pvpHArenaActive"  value=$pvp.arenas_active}{/if}
					{if isset($pvp.arenas_waiting)}{assign var="pvpHArenaWaiting" value=$pvp.arenas_waiting}{/if}
					{if isset($pvp.tournament_active)}{assign var="pvpHTournamentActive" value=$pvp.tournament_active}{/if}
					{if isset($pvp.tournament_status)}{assign var="pvpHTournamentStatus" value=$pvp.tournament_status}{/if}
					{if isset($pvp.tournament_time)}{assign var="pvpHTournamentTime"   value=$pvp.tournament_time}{/if}
				{/if}
				<li>
					<a href="game.php?page=pvp"
					   class="header_pvp_icon"
					   id="header_pvp_link"
					   title="Sistema PvP"
					   data-arena-active="{$pvpHArenaActive}"
					   data-arena-waiting="{$pvpHArenaWaiting}"
					   data-tournament-active="{$pvpHTournamentActive}"
					   data-tournament-status="{$pvpHTournamentStatus}"
					   data-tournament-time="{$pvpHTournamentTime}">
						<span style="font-size:14px;">⚔️</span> {* 🆕 Icono de 2 espadas cruzadas *}
						<span class="header_pvp_badge state-off" id="header_pvp_badge"></span>
					</a>
				</li>
			{/if}
			{* ============================================ *}
			{if isModuleAvailable($smarty.const.MODULE_TECHTREE)}<li><a href="game.php?page=techtree"><i class="fas fa-flask"></i></a></li>{/if}
			{if isModuleAvailable($smarty.const.MODULE_BUDDYLIST)}<li><a href="game.php?page=buddyList"><i class="fas fa-user-circle"></i></a></li>{/if}
			{if isModuleAvailable($smarty.const.MODULE_BANLIST)}<li><a href="game.php?page=banList"><i class="fas fa-user-times"></i></a></li>{/if}
			{if isModuleAvailable($smarty.const.MODULE_CHAT)}<li><a href="game.php?page=chat"><i class="fas fa-comments"></i></a></li>{/if}
			<li><a href="game.php?page=questions"><i class="fas fa-book"></i></a></li>
			<li><a href="game.php?page=settings"><i class="fas fa-wrench"></i></a></li>
			
			<!-- ✅ NUEVO BOTÓN DE DESCARGAS EN EL HEADER -->
			<li>
				<a href="descargas.php" class="header_download_icon" title="Descargar Cliente (PC / APK)">
					📥
				</a>
			</li>
			
			<li><a href="game.php?page=logout" style="color: red;"><i class="fas fa-power-off"></i></a></li>
		</ul>
	</div>
	<div class="clear"></div>
</div>

<script>
/* ═══════════════════════════════════════════════════════════
   Toggle del menú rápido (ocultar/mostrar iconos)
   ═══════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', function() {
    var btn = document.getElementById('astroio-nav-toggle');
    var hdr = document.getElementById('main_header');
    if (!btn || !hdr) return;

    // Estado inicial: colapsado (iconos ocultos en móvil)
    hdr.classList.add('astroio-nav-collapsed');

    btn.addEventListener('click', function() {
        hdr.classList.toggle('astroio-nav-collapsed');
        btn.classList.toggle('is-open');
    });
});

/* Countdown PvP en header (sin cambios) */
(function() {
    var link  = document.getElementById('header_pvp_link');
    var badge = document.getElementById('header_pvp_badge');
    if (!link || !badge) return;

    var arenaActive      = parseInt(link.getAttribute('data-arena-active')      || '0', 10);
    var arenaWaiting     = parseInt(link.getAttribute('data-arena-waiting')     || '0', 10);
    var tournamentActive = parseInt(link.getAttribute('data-tournament-active') || '0', 10);
    var tournamentStatus = (link.getAttribute('data-tournament-status') || '').trim();
    var tournamentTime   = parseInt(link.getAttribute('data-tournament-time')   || '0', 10);

    function formatCountdown(s) {
        if (s <= 0) return '0s';
        var d = Math.floor(s/86400), h = Math.floor((s%86400)/3600),
            m = Math.floor((s%3600)/60), sc = s%60;
        if (d > 0) return d+'d '+h+'h';
        if (h > 0) return h+'h '+m+'m';
        if (m > 0) return m+'m '+sc+'s';
        return sc+'s';
    }
    function setBadge(t, c) { badge.textContent = t; badge.className = 'header_pvp_badge ' + c; }

    function upd() {
        var now = Math.floor(Date.now() / 1000);
        if (tournamentActive === 1 && tournamentStatus === 'running') { setBadge('🏆','state-active'); return; }
        if (tournamentActive === 1 && tournamentStatus === 'registration') {
            setBadge(tournamentTime > now ? '🏆 '+formatCountdown(tournamentTime-now) : '🏆', 'state-soon'); return;
        }
        if (arenaActive > 0)  { setBadge('⚔️ '+arenaActive, 'state-active'); return; }
        if (arenaWaiting > 0) { setBadge('🏟️ '+arenaWaiting, 'state-far');    return; }
        setBadge('','state-off');
    }
    setInterval(upd, 1000); upd();
})();
</script>