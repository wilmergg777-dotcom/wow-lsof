{block name="title" prepend}{$LNG.lm_fleet}{/block}
{block name="content"}

{* ============================================================
   ASTROIO FLEET STEP 3 v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrofs3_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-paneles 10px)
     - Sub-paneles con borde cyan sutil + hover
     - Banner de éxito con glassmorphism
     - Wrapper padding 15px
     - Todos los IDs, names, foreach y Smarty intactos
   ============================================================ *}

<style>
/* ====== Variables globales ====== */
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

/* ====== Wrapper ====== */
.astrofs3_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrofs3_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 620px;
    margin: 0 auto;
}

/* ====== Banner de éxito ====== */
.astrofs3_success {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 8px 14px;
    background: linear-gradient(135deg, rgba(102, 255, 153, 0.15), rgba(102, 255, 153, 0.05));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(102, 255, 153, 0.5);
    border-radius: 10px;
    color: #66ff99;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    text-shadow: 0 0 10px rgba(102, 255, 153, 0.55);
    box-shadow: 0 0 16px rgba(102, 255, 153, 0.15);
    margin-bottom: 12px;
    text-align: center;
}
.astrofs3_success .astrofs3_icon {
    font-size: 16px;
    line-height: 1;
    filter: drop-shadow(0 0 4px rgba(102, 255, 153, 0.8));
}

/* ====== Título de sección ====== */
.astrofs3_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 10.5px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin: 10px 0 6px 0;
    display: block;
}
.astrofs3_section_title:first-of-type { margin-top: 0; }

/* ====== Tabla de datos ====== */
.astrofs3_table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 3px;
    table-layout: fixed;
}
.astrofs3_table td {
    padding: 4px 8px;
    vertical-align: middle;
    color: var(--text-main);
    font-size: 11px;
    line-height: 1.2;
}
.astrofs3_table td:first-child {
    color: var(--text-muted);
    font-weight: 600;
    width: 50%;
}
.astrofs3_table td:last-child {
    color: var(--text-title);
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 11px;
    text-align: right;
}
.astrofs3_table tr {
    background: rgba(0, 0, 0, 0.3);
    border-radius: 6px;
    transition: 0.2s ease;
}
.astrofs3_table tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrofs3_table tr:hover td:last-child {
    color: #00e0ff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.5);
}

/* ====== Fila de la misión (destacada) ====== */
.astrofs3_mission_row td:last-child {
    color: #ffaa33 !important;
    text-shadow: 0 0 8px rgba(255, 170, 51, 0.5);
    font-weight: 800;
}

/* ====== Fila de origen/destino ====== */
.astrofs3_route_row td:last-child {
    color: #00e0ff !important;
    font-family: inherit !important;
    font-size: 11px !important;
}

/* ====== Lista de naves ====== */
.astrofs3_ships_box {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(102, 255, 153, 0.2);
    border-radius: 10px;
    padding: 8px 12px;
    margin-top: 4px;
    transition: 0.2s ease;
}
.astrofs3_ships_box:hover {
    border-color: rgba(102, 255, 153, 0.4);
}
.astrofs3_ship_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 3px 6px;
    border-bottom: 1px dashed rgba(102, 255, 153, 0.1);
    font-size: 11px;
    transition: 0.15s ease;
}
.astrofs3_ship_row:last-child { border-bottom: none; }
.astrofs3_ship_row:hover {
    background: rgba(102, 255, 153, 0.06);
    border-radius: 6px;
}
.astrofs3_ship_name {
    color: var(--text-main);
    font-weight: 600;
}
.astrofs3_ship_count {
    color: #66ff99;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.35);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrofs3_wrap { padding: 10px; }
    .astrofs3_panel { padding: 12px; max-width: 100%; }
    .astrofs3_table td { padding: 3px 6px; font-size: 10.5px; }
    .astrofs3_table td:first-child { width: 45%; }
    .astrofs3_success { font-size: 10.5px; padding: 6px 10px; }
}
</style>

<div class="astrofs3_wrap">

	<div class="astrofs3_panel">

		{* ============ BANNER DE ÉXITO ============ *}
		<div class="astrofs3_success">
			<span class="astrofs3_icon">✅</span>
			<span>{$LNG.fl_fleet_sended}</span>
		</div>
		{if !empty($multi_exped_count)}
		<div class="astrofs3_success" style="border-color:rgba(0,204,255,0.5); color:#00e0ff;">
			<span class="astrofs3_icon">🌌</span>
			<span>
				{$multi_exped_count} flotas enviadas · {$multi_exped_parts_str}
			</span>
		</div>
		{/if}

		{* ============ DATOS DE LA MISIÓN ============ *}
		<span class="astrofs3_section_title">🛰 {$LNG.fl_mission}</span>
		<table class="astrofs3_table">
			<tr class="astrofs3_mission_row">
				<td>{$LNG.fl_mission}</td>
				<td>{$LNG["type_mission_{$targetMission}"]}</td>
			</tr>
			<tr>
				<td>{$LNG.fl_distance}</td>
				<td>{$distance|number}</td>
			</tr>
			<tr>
				<td>{$LNG.fl_fleet_speed}</td>
				<td>{$MaxFleetSpeed|number}</td>
			</tr>
			<tr>
				<td>{$LNG.fl_fuel_consumption}</td>
				<td>{$consumption|number}</td>
			</tr>
		</table>

		{* ============ RUTA ============ *}
		<span class="astrofs3_section_title">📍 {$LNG.fl_from} → {$LNG.fl_destiny}</span>
		<table class="astrofs3_table">
			<tr class="astrofs3_route_row">
				<td>{$LNG.fl_from}</td>
				<td>{$from}</td>
			</tr>
			<tr class="astrofs3_route_row">
				<td>{$LNG.fl_destiny}</td>
				<td>{$destination}</td>
			</tr>
		</table>

		{* ============ TIEMPOS ============ *}
		<span class="astrofs3_section_title">⏱ {$LNG.fl_arrival_time} / {$LNG.fl_return_time}</span>
		<table class="astrofs3_table">
			<tr>
				<td>{$LNG.fl_arrival_time}</td>
				<td>{$fleetStartTime}</td>
			</tr>
			<tr>
				<td>{$LNG.fl_return_time}</td>
				<td>{$fleetEndTime}</td>
			</tr>
		</table>

		{* ============ LISTA DE NAVES ============ *}
		<span class="astrofs3_section_title">🚀 {$LNG.fl_fleet}</span>
		<div class="astrofs3_ships_box">
			{foreach $FleetList as $ShipID => $ShipCount}
			<div class="astrofs3_ship_row">
				<span class="astrofs3_ship_name">{if isset($LNG.tech[$ShipID])}{$LNG.tech[$ShipID]}{else}{$ShipID}{/if}</span>
				<span class="astrofs3_ship_count">{$ShipCount|number}</span>
			</div>
			{/foreach}
		</div>

	</div>

</div>

{/block}