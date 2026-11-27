<style>
/* ============================================
   ASTROIO - TOP BAR DE RECURSOS (v2.5 SEMI-TRANSPARENTE)
   ============================================ */
/* === Ocultar panel usuario y alertas en escritorio === */
	#astroio-mobile-profile,
	#astroio-mobile-alerts {
		display: none;
	}
/* ====================== */
#astroio-menu-toggle-wrap { display: none !important; }
#header {
    background: rgba(11, 16, 30, 0.72);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 2px solid #00ccff;
    padding: 8px 12px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.5);
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 14px;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

/* ===== RECURSOS (Metal, Cristal, Deuterio, Energía) ===== */
#header .res-box {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(0,0,0,0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0,204,255,0.25);
    border-radius: 8px;
    padding: 5px 12px;
    transition: all 0.25s ease;
    flex-shrink: 0;
    min-width: 200px;
    position: relative;
    overflow: hidden;
    margin-right: 4px;
}

#header .res-box:hover {
    border-color: #00e0ff;
    box-shadow: 0 0 16px rgba(0,224,255,0.35);
    background: rgba(0,204,255,0.15);
}

#header .res-box.metal {
    border-color: rgba(255,170,51,0.4);
}
#header .res-box.metal:hover {
    border-color: #ffaa33;
    box-shadow: 0 0 16px rgba(255,170,51,0.4);
}

#header .res-box.crystal {
    border-color: rgba(0,204,255,0.4);
}
#header .res-box.crystal:hover {
    border-color: #00ccff;
    box-shadow: 0 0 16px rgba(0,204,255,0.4);
}

#header .res-box.deuterium {
    border-color: rgba(102,255,153,0.4);
}
#header .res-box.deuterium:hover {
    border-color: #66ff99;
    box-shadow: 0 0 16px rgba(102,255,153,0.4);
}

#header .res-box.energy {
    border-color: rgba(255,221,51,0.4);
}
#header .res-box.energy:hover {
    border-color: #ffdd33;
    box-shadow: 0 0 16px rgba(255,221,51,0.4);
}

/* Icono emoji del recurso */
#header .res-icon {
    font-size: 18px;
    line-height: 1;
    flex-shrink: 0;
    filter: drop-shadow(0 0 4px rgba(255,255,255,0.3));
}

/* Valores (actual / máximo) */
#header .res-values {
    display: flex;
    align-items: baseline;
    gap: 3px;
    font-family: 'Courier New', monospace;
    font-size: 11px;
    font-weight: 700;
    white-space: nowrap;
    flex: 1;
}

#header .res-current {
    color: #ffffff;
    text-shadow: 0 1px 2px rgba(0,0,0,0.8);
}

#header .res-current.negative {
    color: #ff4488;
}

#header .res-max {
    color: #8aa0b5;
    font-size: 10px;
    font-weight: 600;
}

/* Botón de comerciar (solo en metal/cristal/deuterio) */
#header .res-trade {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 20px;
    height: 20px;
    flex-shrink: 0;
}

#header .res-trade a {
    color: #66ccff !important;
    font-size: 12px;
    transition: all 0.25s ease;
    text-decoration: none;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    border-radius: 4px;
    border: 1px solid transparent;
}

#header .res-trade a:hover {
    color: #00e0ff !important;
    background: rgba(0,204,255,0.15);
    border-color: rgba(0,204,255,0.4);
    box-shadow: 0 0 10px rgba(0,224,255,0.4);
}

/* Barra de progreso fina (abajo del todo) */
#header .res-bar {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 2px;
    background: rgba(0,0,0,0.5);
    overflow: hidden;
}

#header .res-bar-fill {
    height: 100%;
    width: 0%;
    transition: width 0.5s ease;
    background: linear-gradient(90deg, #0066cc, #00ccff);
    box-shadow: 0 0 4px rgba(0,204,255,0.8);
}

#header .res-box.metal .res-bar-fill {
    background: linear-gradient(90deg, #aa6600, #ffaa33);
    box-shadow: 0 0 4px rgba(255,170,51,0.8);
}

#header .res-box.crystal .res-bar-fill {
    background: linear-gradient(90deg, #0066aa, #33ccff);
    box-shadow: 0 0 4px rgba(51,204,255,0.8);
}

#header .res-box.deuterium .res-bar-fill {
    background: linear-gradient(90deg, #006633, #33ff88);
    box-shadow: 0 0 4px rgba(51,255,136,0.8);
}

#header .res-box.energy .res-bar-fill {
    background: linear-gradient(90deg, #aa8800, #ffdd33);
    box-shadow: 0 0 4px rgba(255,221,51,0.8);
}

/* ===== NTX-20 ===== */
#header .heder_res_ntx {
    display: flex;
    align-items: center;
    gap: 8px;
    background: linear-gradient(135deg, rgba(0,26,10,0.85), rgba(0,51,24,0.85));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0,255,136,0.5);
    border-radius: 10px;
    padding: 6px 16px;
    transition: all 0.25s ease;
    flex-shrink: 0;
    margin-right: 6px;
}

#header .heder_res_ntx:hover {
    border-color: #00ff88;
    box-shadow: 0 0 20px rgba(0,255,136,0.5);
    transform: translateY(-1px);
}

#header .heder_res_ntx .ntx-icon {
    font-size: 18px;
    line-height: 1;
    filter: drop-shadow(0 0 5px rgba(0,255,136,0.8));
}

#header .heder_res_ntx .res_current {
    color: #66ff99;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 12px;
    letter-spacing: 0.5px;
    padding-right: 4px;
}

/* ===== CONTENEDORES / COFRES ===== */
#header .heder_res_containers {
    display: flex;
    align-items: center;
    gap: 8px;
    background: linear-gradient(135deg, rgba(26,16,0,0.85), rgba(51,31,0,0.85));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255,204,0,0.5);
    border-radius: 10px;
    padding: 6px 16px;
    transition: all 0.25s ease;
    flex-shrink: 0;
    margin-right: 6px;
}

#header .heder_res_containers:hover {
    border-color: #ffcc00;
    box-shadow: 0 0 20px rgba(255,204,0,0.5);
    transform: translateY(-1px);
}

#header .heder_res_containers .cont-icon {
    font-size: 16px;
    filter: drop-shadow(0 0 5px rgba(255,204,0,0.8));
}

#header .heder_res_containers .res_current {
    color: #ffdd55;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 12px;
    letter-spacing: 0.5px;
    padding-right: 4px;
}

/* ===== MATERIA OSCURA (921) — SEMI-TRANSPARENTE ===== */
#header .heder_res_921 {
    display: flex;
    align-items: center;
    gap: 8px;
    background: linear-gradient(135deg, rgba(26,10,46,0.85) 0%, rgba(42,16,80,0.85) 50%, rgba(26,10,46,0.85) 100%);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(170,68,255,0.5);
    border-radius: 10px;
    padding: 6px 16px;
    transition: all 0.3s ease;
    flex-shrink: 0;
    margin-left: auto;
    position: relative;
    overflow: hidden;
    box-shadow: 0 0 12px rgba(170,68,255,0.2), inset 0 0 20px rgba(170,68,255,0.1);
}

/* Efecto de brillo interno */
#header .heder_res_921::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(170,68,255,0.15), transparent);
    transition: left 0.6s ease;
}

#header .heder_res_921:hover::before {
    left: 100%;
}

#header .heder_res_921:hover {
    border-color: #cc88ff;
    box-shadow: 0 0 24px rgba(170,68,255,0.7), inset 0 0 30px rgba(170,68,255,0.2);
    transform: translateY(-1px);
}

#header .heder_res_921 .dark-icon {
    font-size: 20px;
    line-height: 1;
    filter: drop-shadow(0 0 8px rgba(170,68,255,1));
    animation: pulseDark 3s ease-in-out infinite;
}

@keyframes pulseDark {
    0%, 100% { filter: drop-shadow(0 0 8px rgba(170,68,255,1)); }
    50%      { filter: drop-shadow(0 0 14px rgba(204,136,255,1)); }
}

#header .heder_res_921 .res_current {
    color: #dd99ff;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 13px;
    letter-spacing: 0.8px;
    text-shadow: 0 0 8px rgba(170,68,255,0.7);
    padding-right: 4px;
}

/* ===== AVISO DE ADMIN TEMPORAL (SEMI-TRANSPARENTE) ===== */
.infobox {
    background: rgba(255, 200, 0, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 200, 0, 0.4);
    border-left: 4px solid #ffcc00;
    color: #ffdd88;
    padding: 8px 14px;
    margin: 6px 12px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 600;
    box-shadow: 0 2px 8px rgba(0,0,0,0.3), 0 0 12px rgba(255,200,0,0.15);
    text-align: center;
}

.infobox a {
    color: #ffeeaa !important;
    text-decoration: underline;
    font-weight: 700;
}

.infobox a:hover {
    color: #ffffff !important;
    text-shadow: 0 0 8px rgba(255,204,0,0.8);
}

/* ===== RESPONSIVE ===== */
@media (max-width: 1200px) {
    #header {
        gap: 10px;
    }
    #header .res-box {
        min-width: 170px;
    }
}

@media (max-width: 900px) {
    #header {
        gap: 8px;
        padding: 6px 8px;
    }
    #header .res-box {
        min-width: 140px;
        padding: 4px 8px;
        margin-right: 2px;
    }
    #header .res-values {
        font-size: 10px;
    }
    #header .res-max {
        font-size: 9px;
    }
    #header .res-icon {
        font-size: 15px;
    }
    #header .heder_res_921 {
        padding: 5px 12px;
    }
    #header .heder_res_921 .res_current {
        font-size: 11px;
    }
}

/* ═══ RESPONSIVE MÓVIL — Grid 6 col + botón gota ═══ */
@media (max-width: 768px) {
	/* ===== PERFIL USUARIO (solo móvil) ===== */
    #astroio-mobile-profile {
        display: flex !important;
        flex-wrap: wrap;
        align-items: center;
        justify-content: center;
        gap: 12px;
        padding: 6px 10px;
        background: rgba(11, 16, 30, 0.92);
        backdrop-filter: blur(6px);
        -webkit-backdrop-filter: blur(6px);
        border-bottom: 1px solid rgba(0, 204, 255, 0.2);
        font-family: 'Segoe UI', Roboto, sans-serif;
        font-size: 11px;
    }
    #astroio-mobile-profile .user {
        color: #00e0ff;
        font-weight: 700;
    }
    #astroio-mobile-profile .stats {
        color: #88ffbb;
        font-weight: 600;
    }
    #astroio-mobile-profile .time {
        color: #a8b8c8;
        font-family: 'Courier New', monospace;
        font-weight: 700;
    }
    /* ===== FIN PERFIL USUARIO ===== */
	
    #header {
        display: grid !important;
        grid-template-columns: repeat(6, minmax(0, 1fr)) !important;
        gap: 4px !important;
        padding: 1px 3px !important;
        max-width: 480px !important;
        margin: 0 auto !important;
        justify-items: center !important;
        align-items: stretch !important;
    }
    #header .res-box {
        grid-column: span 3 !important;
        min-width: 0 !important;
        width: 100% !important;
        max-width: 170px !important;
        margin: 0 !important;
        padding: 1px 2px !important;
        min-height: 26px !important;
    }
    #header .heder_res_ntx,
    #header .heder_res_containers,
    #header .heder_res_921 {
        grid-column: span 2 !important;
        justify-self: center !important;
        min-width: 0 !important;
        width: 100% !important;
        max-width: 100px !important;
        margin: 0 !important;
        padding: 2px 4px !important;
        min-height: 26px !important;
        gap: 4px !important;
    }
    #header .res-values { font-size: 10px !important; }
    #header .res-icon   { font-size: 15px !important; }

	/* === ALERTAS A TODO EL ANCHO === */
    #astroio-mobile-alerts {
        display: grid !important;
        grid-template-columns: 1fr 1fr 1fr !important;
        width: 100% !important;
        background: rgba(11, 16, 30, 0.95) !important;
        border-bottom: 1px solid rgba(0, 204, 255, 0.2) !important;
        padding: 0 !important;
        margin: 0 !important;
        box-sizing: border-box !important;
    }
    #astroio-mobile-alerts .alert_btn {
        height: 40px !important;
        font-size: 18px !important;
        background: rgba(0,0,0,0.4) !important;
        border-right: 1px solid rgba(255,255,255,0.05) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        border-radius: 0 !important;
        margin: 0 !important;
        transition: all 0.25s ease !important;
    }
    #astroio-mobile-alerts .alert_btn:last-child { border-right: none !important; }
    
    /* Animaciones de alerta */
    #astroio-mobile-alerts .alert_btn.off {
        opacity: 0.3 !important;
        filter: grayscale(100%) !important;
    }
    #astroio-mobile-alerts .alert_btn.attack.active {
        background: rgba(255, 0, 0, 0.3) !important;
        animation: astroio_alert_red 1s infinite !important;
    }
    #astroio-mobile-alerts .alert_btn.spy.active {
        background: rgba(255, 204, 0, 0.3) !important;
        animation: astroio_alert_yellow 1s infinite !important;
    }
    #astroio-mobile-alerts .alert_btn.transport.active {
        background: rgba(0, 136, 255, 0.3) !important;
        animation: astroio_alert_blue 1s infinite !important;
    }
    @keyframes astroio_alert_red { 0%, 100% { background: rgba(255, 0, 0, 0.55); } 50% { background: rgba(255, 0, 0, 0.05); } }
    @keyframes astroio_alert_yellow { 0%, 100% { background: rgba(255, 204, 0, 0.55); } 50% { background: rgba(255, 204, 0, 0.05); } }
    @keyframes astroio_alert_blue { 0%, 100% { background: rgba(0, 136, 255, 0.55); } 50% { background: rgba(0, 136, 255, 0.05); } }
	/* ======================================== */
	/* ==BOTÓN MENU== */
    #astroio-menu-toggle-wrap {
        display: flex !important;
        justify-content: center !important;
        align-items: center !important;
        width: 100% !important;
        text-align: center !important;
        margin: 4px 0 -12px 0 !important;
        padding: 0 !important;
    }
    #astroio-mobile-toggle {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        width: 46px !important;
        height: 36px !important;
        margin: -4px auto -5px auto !important;
        padding: 8px 0 0 0 !important;
        background: rgba(11, 16, 30, 0.85) !important;
        backdrop-filter: auto !important;
        -webkit-backdrop-filter: blur(6px) !important;
        color: #00e0ff !important;
        cursor: pointer !important;
        clip-path: polygon(0% 0%, 100% 0%, 100% 48%, 96% 62%, 88% 76%, 76% 88%, 62% 96%, 50% 100%, 38% 96%, 24% 88%, 12% 76%, 4% 62%, 0% 48%) !important;
        font-size: 14px !important;
        box-shadow: none !important;
        box-sizing: border-box !important;
        position: sticky !important;
        bottom: 10px !important;
        z-index: 100 !important;
    }
    #astroio-mobile-toggle .astroio-toggle-icon {
        display: inline-block !important;
        font-size: 15px !important;
        margin-top: 1px !important;
        transition: transform 0.25s ease !important;
    }
    body.astroio-menu-open #astroio-mobile-toggle .astroio-toggle-icon {
        transform: rotate(180deg) !important;
    }
}

</style>
<!-- PERFIL USUARIO -->
	<div id="astroio-mobile-profile">
		<span class="user">👤 {$username}</span>
		<span class="stats">🟢 24h: {$onlineCount}/{$totalCount}</span>
		<span class="time">🕐 {$servertime}</span>
	</div>

<div id="header">

	{* ===== 1) METAL, CRISTAL, DEUTERIO, ENERGÍA ===== *}
	{foreach $resourceTable as $resourceID => $resourceData}
	{if $resourceID != 921}
		{* Definir clase, icono y color según el recurso *}
		{if $resourceID == 901}
			{assign var="resClass" value="metal"}
			{assign var="resIcon" value="🔩"}
			{assign var="resTradeParam" value="metal"}
		{elseif $resourceID == 902}
			{assign var="resClass" value="crystal"}
			{assign var="resIcon" value="💎"}
			{assign var="resTradeParam" value="crystal"}
		{elseif $resourceID == 903}
			{assign var="resClass" value="deuterium"}
			{assign var="resIcon" value="⚗️"}
			{assign var="resTradeParam" value="deuterium"}
		{elseif $resourceID == 932}  {* 🆕 v2.4.0 — Norium *}
			{assign var="resClass" value="norium"}
			{assign var="resIcon" value="🛢️"}
			{assign var="resTradeParam" value="norium"}
		{elseif $resourceID == 933}  {* 🆕 v2.4.0 — Germanium *}
			{assign var="resClass" value="germanium"}
			{assign var="resIcon" value="💠"}
			{assign var="resTradeParam" value="germanium"}
		{elseif $resourceID == 911}
			{assign var="resClass" value="energy"}
			{assign var="resIcon" value="⚡"}
			{assign var="resTradeParam" value=""}
		{else}
			{assign var="resClass" value=""}
			{assign var="resIcon" value="📦"}
			{assign var="resTradeParam" value=""}
		{/if}

		<div class="res-box {$resClass}" data-tooltip-content="{$LNG.tech.$resourceID}">
			{* Icono emoji *}
			<span class="res-icon">{$resIcon}</span>

			{* Valores actual / máximo *}
			<span class="res-values">
				{if !isset($resourceData.current)}
					{$resourceData.current = $resourceData.max + $resourceData.used}
					<span class="res-current{if $resourceData.current < 0} negative{/if}">
						{shortly_number($resourceData.current)}
					</span>
					<span class="res-max">/ {shortly_number($resourceData.max)}</span>
				{else}
					<span class="res-current" id="current_{$resourceData.name}" data-real="{$resourceData.current}">
						{shortly_number($resourceData.current)}
					</span>
					{if isset($resourceData.max)}
						<span class="res-max">/ <span id="max_{$resourceData.name}" data-real="{$resourceData.max}">{shortly_number($resourceData.max)}</span></span>
					{/if}
				{/if}
			</span>

			{* Botón de comerciar (solo si no es energía) — v2.3: apunta al ResourceTrader nuevo *}
			{if $resourceID != 911 && $resTradeParam}
				{if isModuleAvailable($smarty.const.MODULE_RESOURCE_TRADER)}
				<span class="res-trade">
					<a href="game.php?page=resourceTrader&amp;dar={$resTradeParam}" title="Comerciar"><i class="fas fa-arrows-alt-h"></i></a>
				</span>
				{/if}
			{/if}

			{* Barra de progreso fina (oculta visualmente pero funcional para el JS) *}
			<div class="res-bar">
				<div class="res-bar-fill bar_{$resourceID}" style="width: 0%;"></div>
			</div>
		</div>
	{/if}
	{/foreach}

	{* ===== 2) NTX-20 / UNTX-20 (Doble Riel) ===== *}
	{if isset($metodo_retiro) && $metodo_retiro == 'QVAPAY'}
		<!-- SISTEMA INTERNACIONAL -->
		<div class="heder_res_ntx tooltip" data-tooltip-content="UNTX-20<br>Saldo Internacional (QUSD)">
			<span class="ntx-icon">💲</span>
			<span class="res_current">{$untx20|default:0}</span>
		</div>
	{else}
		<!-- SISTEMA NACIONAL (Por defecto) -->
		<div class="heder_res_ntx tooltip" data-tooltip-content="NTX-20<br>Criptomoneda de AstroIO">
			<span class="ntx-icon">💲</span>
			<span class="res_current">{$ntx20|default:0}</span>
		</div>
	{/if}

	{* ===== 3) CONTENEDORES ===== *}
	{* ✅ FIX v2.5: ahora lee $containers (que es la SUMA de las 4 cajas)
	   La variable $containers la calcula AbstractGamePage.class.php
	   sumando: genérico + común + raro + legendario *}
	<div class="heder_res_containers tooltip" data-tooltip-content="Contenedores<br>Ábrelos para conseguir recompensas">
		<span class="cont-icon">🎁</span>
		<span class="res_current">{$containers|default:0}</span>
	</div>

	{* ===== 4) MATERIA OSCURA (al final) ===== *}
	{foreach $resourceTable as $resourceID => $resourceData}
	{if $resourceID == 921}
	<div class="heder_res_921 tooltip" data-tooltip-content="{$LNG.tech.$resourceID}">
		<span class="dark-icon">🌌</span>
		<span class="res_current" id="current_{$resourceData.name}" data-real="{$resourceData.current}">
			{shortly_number($resourceData.current)}
		</span>
	</div>
	{/if}
	{/foreach}

	<div class="clear"></div>

	{if !$vmode}
	<script type="text/javascript">
	var viewShortlyNumber	= {$shortlyNumber|json};
	var vacation			= {$vmode};
	$(function() {
	{foreach $resourceTable as $resourceID => $resourceData}
	{if isset($resourceData.production)}
		resourceTicker({
			available: {$resourceData.current|json},
			limit: [0, {$resourceData.max|json}],
			production: {$resourceData.production|json},
			valueElem: "current_{$resourceData.name}",
			valuePoursent: "bar_{$resourceID}"
		}, true);
	{/if}
	{/foreach}
	});
	</script>
	<script src="scripts/game/topnav.js"></script>
	{if $hasGate}<script src="scripts/game/gate.js"></script>{/if}
	{/if}
</div>
	<!-- ALERTAS (Full Width) -->
	<div id="astroio-mobile-alerts">
		<div class="alert_btn attack {if !empty($globalAlerts.attack)}active{else}off{/if}" title="Ataque">⚔️</div>
		<div class="alert_btn spy {if !empty($globalAlerts.spy)}active{else}off{/if}" title="Espionaje">🕵️</div>
		<div class="alert_btn transport {if !empty($globalAlerts.transport)}active{else}off{/if}" title="Transporte">📥</div>
	</div>
	<!-------------------------->
	<!-- BOTON MENU -->
	<div id="astroio-menu-toggle-wrap">
		<button id="astroio-mobile-toggle" type="button" aria-label="Abrir menú">
			<span class="astroio-toggle-icon">▼</span>
		</button>
	</div>
	<!---------------->
	{if $closed}
	<div class="infobox">{$LNG.ov_closed}</div>
	{elseif $delete}
	<div class="infobox">{$delete}</div>
	{elseif $vacation}
	<div class="infobox">{$LNG.ov_vacation_mode} {$vacation}</div>
	{/if}