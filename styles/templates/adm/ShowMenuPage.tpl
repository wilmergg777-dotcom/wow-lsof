<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Menú de Administración</title>
</head>
<body id="menu">
<style>
/* ============================================================== */
/* ====== ASTROIO ADMIN MENU v3.0 — Estilo glassmorphism ======== */
/* ============================================================== */
/* Prefijo: .astroadmm_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Fondo semi-transparente con backdrop-filter (glassmorphism)
     - Deja ver la imagen espacial del tema gow detrás
     - Hover con glow cyan
     - Todos los IDs, href, target, allowedTo y onClick intactos
   ============================================================== */

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

/* ============ Fondo del body (frame del menú) ============ */
body#menu {
	background: transparent !important;
	margin: 0 !important;
	padding: 0 !important;
	min-height: 100vh !important;
	color: var(--text-main) !important;
}

/* ============ Contenedor del menú lateral ============ */
#leftmenu {
	background: rgba(15, 23, 42, 0.75) !important;
	backdrop-filter: blur(6px) !important;
	-webkit-backdrop-filter: blur(6px) !important;
	padding: 0 !important;
	margin: 0 !important;
	min-height: 100vh !important;
	width: 220px !important;
	border-right: 1px solid rgba(0, 224, 255, 0.2) !important;
	box-shadow: 4px 0 20px rgba(0, 0, 0, 0.5) !important;
}

#leftmenu ul#menu {
	list-style: none !important;
	margin: 0 !important;
	padding: 6px !important;
	background: transparent !important;
	display: block !important;
}

#leftmenu ul#menu li {
	margin: 1px 0 !important;
	padding: 0 !important;
	background: transparent !important;
	border: none !important;
	list-style: none !important;
	background-image: none !important;
	display: block !important;
	width: 100% !important;
}

/* ============ OCULTAR ELEMENTOS DECORATIVOS ============ */
#leftmenu ul#menu li[style*="menu-top"],
#leftmenu ul#menu li[style*="menu-foot"] {
	display: none !important;
}

/* ============ CATEGORÍAS (subtítulos) ============ */
#leftmenu ul#menu li > a[href="javascript:void(0);"] {
	display: block !important;
	background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
	backdrop-filter: blur(6px) !important;
	-webkit-backdrop-filter: blur(6px) !important;
	border-radius: 8px !important;
	padding: 6px 8px !important;
	margin: 8px 0 3px 0 !important;
	border-left: 4px solid var(--accent-cyan) !important;
	text-align: center !important;
	font-weight: 700 !important;
	font-size: 10px !important;
	text-transform: uppercase !important;
	letter-spacing: 0.8px !important;
	text-decoration: none !important;
	color: #ffffff !important;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5) !important;
	transition: all 0.25s ease !important;
	line-height: 1.1 !important;
	box-sizing: border-box !important;
	width: 100% !important;
}

#leftmenu ul#menu li > a[href="javascript:void(0);"] span {
	color: #ffffff !important;
	font-weight: 700 !important;
	font-size: 10px !important;
	text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5) !important;
}

#leftmenu ul#menu li > a[href="javascript:void(0);"]:hover {
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 153, 255, 0.95)) !important;
	box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 4px 12px rgba(0, 0, 0, 0.5) !important;
	border-left-color: var(--accent-cyan) !important;
	transform: translateY(-1px) !important;
}

/* ============ ENLACES NORMALES ============ */
#leftmenu ul#menu li > a:not([href="javascript:void(0);"]) {
	display: block !important;
	background: rgba(0, 0, 0, 0.35) !important;
	backdrop-filter: blur(4px) !important;
	-webkit-backdrop-filter: blur(4px) !important;
	color: var(--accent-cyan) !important;
	border: 1px solid rgba(0, 224, 255, 0.2) !important;
	border-radius: 8px !important;
	padding: 6px 10px !important;
	font-size: 10px !important;
	font-weight: 600 !important;
	text-decoration: none !important;
	text-align: left !important;
	letter-spacing: 0.1px !important;
	transition: all 0.25s ease !important;
	position: relative !important;
	overflow: hidden !important;
	line-height: 1.2 !important;
	word-wrap: break-word !important;
	overflow-wrap: break-word !important;
	word-break: break-word !important;
	box-sizing: border-box !important;
	width: 100% !important;
	min-height: 0 !important;
}

/* Línea cyan lateral animada */
#leftmenu ul#menu li > a:not([href="javascript:void(0);"])::before {
	content: '' !important;
	position: absolute !important;
	left: 0 !important;
	top: 0 !important;
	height: 100% !important;
	width: 3px !important;
	background: var(--accent-cyan) !important;
	transform: scaleY(0) !important;
	transition: transform 0.25s ease !important;
	box-shadow: 0 0 8px rgba(0, 224, 255, 0.6) !important;
}

#leftmenu ul#menu li > a:not([href="javascript:void(0);"]):hover {
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9)) !important;
	color: #ffffff !important;
	border-color: var(--accent-cyan) !important;
	box-shadow: 0 0 14px rgba(0, 224, 255, 0.5), 0 2px 8px rgba(0, 0, 0, 0.5) !important;
	z-index: 10 !important;
	transform: translateY(-1px) !important;
	text-shadow: 0 0 8px rgba(0, 224, 255, 0.6) !important;
}

#leftmenu ul#menu li > a:not([href="javascript:void(0);"]):hover::before {
	transform: scaleY(1) !important;
}

/* ============ Scrollbar ============ */
#leftmenu::-webkit-scrollbar {
	width: 6px;
}
#leftmenu::-webkit-scrollbar-track {
	background: rgba(0, 0, 0, 0.3);
}
#leftmenu::-webkit-scrollbar-thumb {
	background: linear-gradient(180deg, rgba(0, 102, 204, 0.8), rgba(0, 224, 255, 0.6));
	border-radius: 3px;
}
#leftmenu::-webkit-scrollbar-thumb:hover {
	background: linear-gradient(180deg, rgba(0, 224, 255, 0.9), rgba(0, 224, 255, 1));
}
</style>

<div id="leftmenu">
	<ul id="menu">
		<li style="background-image: url('./styles/theme/gow/img/menu-top.png');height:100px;"></li>
		<li><a href="javascript:void(0);"><span style="color:lime">{$LNG.mu_general}</span></a></li>
		{if allowedTo('ShowInformationPage')}<li><a href="?page=infos" target="Hauptframe">{$LNG.mu_game_info}</a></li>{/if}
		{if allowedTo('ShowConfigBasicPage')}<li><a href="?page=config" target="Hauptframe">{$LNG.mu_settings}</a></li>{/if}
		{if allowedTo('ShowConfigUniPage')}<li><a href="?page=configuni" target="Hauptframe">{$LNG.mu_unisettings}</a></li>{/if}
		<li><a href="?page=weekendboost" target="Hauptframe">🎉 Boost Fin de Semana</a></li>
		{if allowedTo('ShowConfigModsPage')}<li><a href="?page=configmods" target="Hauptframe">{$LNG.mu_mods_settings}</a></li>{/if}
		{if allowedTo('ShowChatConfigPage')}<li><a href="?page=chat" target="Hauptframe">{$LNG.mu_chat}</a></li>{/if}
		{if allowedTo('ShowTeamspeakPage')}<li><a href="?page=teamspeak" target="Hauptframe">{$LNG.mu_ts_options}</a></li>{/if}
		{if allowedTo('ShowFacebookPage')}<li><a href="?page=facebook" target="Hauptframe">{$LNG.mu_fb_options}</a></li>{/if}
		{if allowedTo('ShowModulePage')}<li><a href="?page=module" target="Hauptframe">{$LNG.mu_module}</a></li>{/if}
		{if allowedTo('ShowDisclamerPage')}<li><a href="?page=disclamer" target="Hauptframe">{$LNG.mu_disclaimer}</a></li>{/if}
		{if allowedTo('ShowStatsPage')}<li><a href="?page=statsconf" target="Hauptframe">{$LNG.mu_stats_options}</a></li>{/if}
		{* if allowedTo('ShowVertifyPage')}<li><a href="?page=vertify" target="Hauptframe">{$LNG.mu_vertify}</a></li>{/if *}
		{if allowedTo('ShowCronjobPage')}<li><a href="?page=cronjob" target="Hauptframe">{$LNG.mu_cronjob}</a></li>{/if}
		{if allowedTo('ShowDumpPage')}<li><a href="?page=dump" target="Hauptframe">{$LNG.mu_dump}</a></li>{/if}
		<li><a href="javascript:void(0);"><span style="color:lime">{$LNG.mu_users_settings}</span></a></li>
		{if allowedTo('ShowCreatorPage')}<li><a href="?page=create" target="Hauptframe">{$LNG.new_creator_title}</a></li>{/if}
		{if allowedTo('ShowAccountEditorPage')}<li><a href="?page=accounteditor" target="Hauptframe">{$LNG.mu_add_delete_resources}</a></li>{/if}
		{if allowedTo('ShowBanPage')}<li><a href="?page=bans" target="Hauptframe">{$LNG.mu_ban_options}</a></li>{/if}
		{if allowedTo('ShowGiveawayPage')}<li><a href="?page=giveaway" target="Hauptframe">{$LNG.mu_giveaway}</a></li>{/if}
		{if allowedTo('ShowBoostersAdminPage')}<li><a href="?page=boosters" target="Hauptframe">⚡ Potenciadores</a></li>{/if}
		{if allowedTo('ShowEventsAdminPage')}<li><a href="?page=events" target="Hauptframe">🎉 Eventos</a></li>{/if}
		{if allowedTo('ShowMarketAdminPage')}<li><a href="?page=market" target="Hauptframe">🛒 Mercado</a></li>{/if}
		{if allowedTo('ShowGamesAdminPage')}<li><a href="?page=gamesadmin" target="Hauptframe">🎰 Sorteos y Rifas</a></li>{/if}
		<li><a href="?page=bugreportadmin" target="Hauptframe">🐛 Reportes de Bug</a></li>
		<li><a href="?page=improvementsadmin" target="Hauptframe">🏆 Temporadas de Mejoras</a></li>
		<li><a href="?page=pveadmin" target="Hauptframe">⚔️ Sistema PvE</a></li>
		<li><a href="?page=pvpadmin" target="Hauptframe">⚔️ Sistema PvP</a></li>
		<li><a href="?page=shopadmin" target="Hauptframe">🛒 Tienda NTX-20</a></li>
		<li><a href="?page=ntx20admin" target="Hauptframe">📊 Auditoría NTX-20</a></li>
		<li><a href="?page=tourneyadmin" target="Hauptframe">🏆 Mini Torneos</a></li>
		<li><a href="?page=climas" target="Hauptframe">🌦️ Sistema de Clima</a></li>
		<li><a href="?page=referral_rewards" target="Hauptframe">🎁 Recompensas de Referidos</a></li>
		<li><a href="?page=cloneuniverse" target="Hauptframe">🌌 Clonar Universo</a></li>
		<li><a href="javascript:void(0);"><span style="color:lime">{$LNG.mu_observation}</span></a></li>
		{if allowedTo('ShowSearchPage')}<li><a href="?page=search&amp;search=online&amp;minimize=on" target="Hauptframe">{$LNG.mu_connected}</a></li>{/if}
		{if allowedTo('ShowSupportPage')}<li><a href="?page=support" target="Hauptframe">{$LNG.mu_support}{if $supportticks != 0} ({$supportticks}){/if}</a></li>{/if}
		{if allowedTo('ShowActivePage')}<li><a href="?page=active" target="Hauptframe">{$LNG.mu_vaild_users}</a></li>{/if}
		{if allowedTo('ShowSearchPage')}<li><a href="?page=search&amp;search=p_connect&amp;minimize=on" target="Hauptframe">{$LNG.mu_active_planets}</a></li>{/if}
		{if allowedTo('ShowFlyingFleetPage')}<li><a href="?page=fleets" target="Hauptframe">{$LNG.mu_flying_fleets}</a></li>{/if}
		{if allowedTo('ShowNewsPage')}<li><a href="?page=news" target="Hauptframe">{$LNG.mu_news}</a></li>{/if}
		{if allowedTo('ShowSearchPage')}<li><a href="?page=search&amp;search=users&amp;minimize=on" target="Hauptframe">{$LNG.mu_user_list}</a></li>{/if}
		{if allowedTo('ShowSearchPage')}<li><a href="?page=search&amp;search=planet&amp;minimize=on" target="Hauptframe">{$LNG.mu_planet_list}</a></li>{/if}
		{if allowedTo('ShowSearchPage')}<li><a href="?page=search&amp;search=moon&amp;minimize=on" target="Hauptframe">{$LNG.mu_moon_list}</a></li>{/if}
		{if allowedTo('ShowMessageListPage')}<li><a href="?page=messagelist" target="Hauptframe">{$LNG.mu_mess_list}</a></li>{/if}
		{if allowedTo('ShowAccountDataPage')}<li><a href="?page=accountdata" target="Hauptframe">{$LNG.mu_info_account_page}</a></li>{/if}
		{if allowedTo('ShowSearchPage')}<li><a href="?page=search" target="Hauptframe">{$LNG.mu_search_page}</a></li>{/if}
		{if allowedTo('ShowMultiIPPage')}<li><a href="?page=multiips" target="Hauptframe">{$LNG.mu_multiip_page}</a></li>{/if}
		<li><a href="javascript:void(0);"><span style="color:lime">{$LNG.mu_tools}</span></a></li>
		{if allowedTo('ShowLogPage')}<li><a href="?page=log" target="Hauptframe">{$LNG.mu_logs}</a></li>{/if}
		{if allowedTo('ShowSendMessagesPage')}<li><a href="?page=globalmessage" target="Hauptframe">{$LNG.mu_global_message}</a></li>{/if}
		{if allowedTo('ShowPassEncripterPage')}<li><a href="?page=password" target="Hauptframe">{$LNG.mu_md5_encripter}</a></li>{/if}
		{if allowedTo('ShowStatUpdatePage')}<li><a href="?page=statsupdate" target="Hauptframe" onClick=" return confirm('{$LNG.mu_mpu_confirmation}');">{$LNG.mu_manual_points_update}</a></li>{/if}
		{if allowedTo('ShowClearCachePage')}<li><a href="?page=clearcache" target="Hauptframe">{$LNG.mu_clear_cache}</a></li>{/if}
		<li style="background-image: url('./styles/theme/gow/img/menu-foot.png');height:30px;"></li>
	</ul>
</div>
</body>
</html>