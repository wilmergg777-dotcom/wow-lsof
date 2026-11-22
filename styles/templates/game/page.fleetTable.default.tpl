{block name="title" prepend}{$LNG.lm_fleet}{/block}
{block name="content"}

{* ============================================================
   ASTROIO FLEET TRACKER v10.0 — TACTICAL RADAR (ANTI-BUCLE)
   ============================================================ *}

<style>
/* ====== Variables globales ====== */
:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(15, 23, 42, 0.75);
    --bg-card-solid: rgba(15, 23, 42, 0.95);
    --border-color:  #1e293b;
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --accent-cyan:   #00e0ff;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
    --accent-gold:   #fbbf24;
    --accent-blue:   #3b82f6;
    --font-mono:     'Courier New', Courier, monospace;
}

.astroftbl_wrap { width: 100%; padding: 15px; box-sizing: border-box; font-family: 'Inter', 'Segoe UI', Arial, sans-serif; }
.astroftbl_panel { background: var(--bg-card); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5); padding: 15px; color: var(--text-main); max-width: 1000px; margin: 0 auto 10px auto; }
.astroftbl_section_title { color: var(--accent-cyan); font-weight: 700; font-size: 11px; letter-spacing: 0.6px; text-transform: uppercase; border-bottom: 1px solid rgba(0, 204, 255, 0.2); padding-bottom: 4px; margin-bottom: 8px; display: block; }
.astroftbl_counters { display: flex; justify-content: space-between; align-items: center; gap: 8px; padding: 8px 12px; background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(0, 204, 255, 0.15); border-radius: 10px; margin-bottom: 15px; flex-wrap: wrap; }
.astroftbl_counter { display: flex; align-items: center; gap: 4px; font-size: 11px; color: var(--text-muted); font-weight: 600; }
.astroftbl_counter b { color: var(--accent-cyan); font-family: var(--font-mono); font-size: 12px; text-shadow: 0 0 6px rgba(0, 224, 255, 0.4); }
.astroftbl_counter.astroftbl_exp b { color: var(--accent-green); text-shadow: 0 0 6px rgba(102, 255, 153, 0.4); }

/* ====== RADAR (COMPACTO) ====== */
.fleet-card { background: rgba(0, 0, 0, 0.25); border: 1px solid var(--border-color); border-radius: 8px; margin-bottom: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.3); overflow: visible; position: relative; }

/* 🔥 NUEVOS COLORES DINÁMICOS (AFECTA A BORDE, TEXTO Y NAVE) 🔥 */
.fleet-card.mission-attack { border-left: 4px solid var(--accent-red); }
.fleet-card.mission-attack .fleet-mission { color: var(--accent-red) !important; text-shadow: 0 0 5px var(--accent-red); }
.fleet-card.mission-attack .traveler-ship { filter: drop-shadow(0 0 10px var(--accent-red)); }

.fleet-card.mission-espionage { border-left: 4px solid var(--accent-gold); }
.fleet-card.mission-espionage .fleet-mission { color: var(--accent-gold) !important; text-shadow: 0 0 5px var(--accent-gold); }
.fleet-card.mission-espionage .traveler-ship { filter: drop-shadow(0 0 10px var(--accent-gold)); }

.fleet-card.mission-transport { border-left: 4px solid var(--accent-green); }
.fleet-card.mission-transport .fleet-mission { color: var(--accent-green) !important; text-shadow: 0 0 5px var(--accent-green); }
.fleet-card.mission-transport .traveler-ship { filter: drop-shadow(0 0 10px var(--accent-green)); }

.fleet-card.mission-deploy { border-left: 4px solid var(--accent-blue); }
.fleet-card.mission-deploy .fleet-mission { color: var(--accent-blue) !important; text-shadow: 0 0 5px var(--accent-blue); }
.fleet-card.mission-deploy .traveler-ship { filter: drop-shadow(0 0 10px var(--accent-blue)); }

.fleet-card.mission-expedition { border-left: 4px solid var(--accent-cyan); }
.fleet-card.mission-expedition .fleet-mission { color: var(--accent-cyan) !important; text-shadow: 0 0 5px var(--accent-cyan); }
.fleet-card.mission-expedition .traveler-ship { filter: drop-shadow(0 0 10px var(--accent-cyan)); }

.fleet-card.mission-default { border-left: 4px solid var(--text-muted); }
.fleet-card.mission-default .fleet-mission { color: var(--text-muted) !important; }

.fleet-header { display: flex; justify-content: space-between; align-items: center; padding: 6px 12px; background: rgba(0,0,0,0.4); border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 10px; font-weight: 700; text-transform: uppercase; flex-wrap: wrap; gap: 4px; }

/* ====== BOTONES HUD (VIRAR / SAC) ====== */
.btn-hud { 
    background: transparent; 
    border: 1px solid rgba(255, 255, 255, 0.3); 
    color: #cbd5e1; 
    padding: 3px 8px; 
    font-size: 9px; 
    font-weight: 600; 
    cursor: pointer; 
    border-radius: 4px; 
    text-transform: uppercase; 
    transition: 0.2s ease; 
}
.btn-hud:hover {
    background: rgba(255, 255, 255, 0.1); 
    border-color: #ffffff; 
    color: #ffffff;
}
/* .btn-hud { background: transparent; border: 1px solid var(--text-muted); color: var(--text-muted); padding: 2px 6px; font-size: 8px; font-weight: bold; cursor: pointer; border-radius: 4px; text-transform: uppercase; } */
.btn-hud.danger { border-color: rgba(239, 68, 68, 0.4); color: #ef4444; }
.btn-hud.danger:hover { background: rgba(239, 68, 68, 0.1); border-color: #ef4444; color: #ffffff; box-shadow: 0 0 8px rgba(239, 68, 68, 0.3); }

.btn-hud.purple { border-color: rgba(204, 102, 255, 0.4); color: #cc66ff; }
.btn-hud.purple:hover { background: rgba(204, 102, 255, 0.1); border-color: #cc66ff; color: #ffffff; box-shadow: 0 0 8px rgba(204, 102, 255, 0.3); }

/* 🔥 ALTURA REDUCIDA (MÁS COMPACTO) 🔥 */
.fleet-radar { padding: 2px 15px; display: flex; align-items: center; justify-content: space-between; position: relative; height: 40px; }
.planet-node { display: flex; flex-direction: column; align-items: center; justify-content: center; z-index: 2; text-align: center; width: 80px; }
.planet-icon { font-size: 16px; line-height: 1; margin-bottom: 0px; filter: drop-shadow(0 0 8px rgba(255,255,255,0.2)); }
.planet-name { font-size: 8px; font-weight: bold; color: #fff; text-transform: uppercase; white-space: nowrap; }
.planet-coords { font-size: 7px; color: var(--text-muted); font-family: var(--font-mono); margin-top: 0px; }

.radar-track-container { flex: 1; position: relative; height: 100%; margin: 0 10px; display: flex; align-items: center; }
.radar-line { position: absolute; top: 50%; left: 0; width: 100%; height: 2px; background-image: linear-gradient(to right, var(--border-color) 50%, transparent 50%); background-size: 8px 100%; z-index: 1; transform: translateY(-50%); }

.center-node { position: absolute; left: 50%; top: 50%; transform: translate(-50%, -50%); z-index: 2; cursor: help; }
.center-node .planet-name { color: #fff; }
.center-node .planet-coords { color: var(--text-muted); opacity: 0.9; }

.end-node { position: absolute; right: 0; top: 50%; transform: translateY(-50%); z-index: 2; opacity: 0.5; }

.traveler-container { position: absolute; top: 50%; left: 0%; transform: translate(-50%, -50%); display: flex; flex-direction: column; align-items: center; z-index: 3; transition: left 1s linear; cursor: help; }
.traveler-ship { font-size: 16px; line-height: 1; }

.traveler-timer { margin-top: 0px; font-size: 8px; font-weight: bold; color: var(--accent-gold); background: rgba(0,0,0,0.9); padding: 0px 4px; border-radius: 4px; border: 1px solid rgba(255, 184, 0, 0.5); white-space: nowrap; font-family: var(--font-mono); }

/* ====== TOOLTIP PERSONALIZADO ====== */
.hud-tooltip {
    position: absolute;
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-bottom: 10px;
    background: var(--bg-card-solid);
    border: 1px solid var(--accent-cyan);
    border-radius: 6px;
    padding: 8px 10px;
    width: 200px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8), 0 0 10px rgba(0, 224, 255, 0.2);
    opacity: 0;
    visibility: hidden;
    transition: all 0.2s ease-in-out;
    z-index: 100;
    pointer-events: none;
    font-size: 10px;
    color: var(--text-main);
    text-align: left;
}
.hud-tooltip::after {
    content: '';
    position: absolute;
    top: 100%;
    left: 50%;
    margin-left: -6px;
    border-width: 6px;
    border-style: solid;
    border-color: var(--accent-cyan) transparent transparent transparent;
}
.traveler-container:hover .hud-tooltip,
.center-node:hover .hud-tooltip {
    opacity: 1;
    visibility: visible;
    margin-bottom: 6px;
}
.tooltip-title {
    font-weight: bold;
    color: var(--accent-cyan);
    border-bottom: 1px solid var(--border-color);
    padding-bottom: 3px;
    margin-bottom: 4px;
    text-transform: uppercase;
    font-size: 9px;
    letter-spacing: 0.5px;
}
.tooltip-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 2px;
}
.tooltip-row span:last-child {
    font-family: var(--font-mono);
    font-weight: bold;
    color: #fff;
}
.tooltip-section-title {
    color: var(--accent-gold);
    margin-top: 6px;
    margin-bottom: 3px;
    font-weight: bold;
    font-size: 9px;
}

/* ====== FORMULARIO Y BOTONES ====== */
.astroftbtns_zone { display: flex; gap: 8px; padding: 10px 12px; background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(0, 204, 255, 0.15); border-radius: 10px; margin-top: 10px; margin-bottom: 10px; flex-wrap: wrap; justify-content: center; }
.astroftbtns_btn { 
    display: inline-block; 
    padding: 8px 16px; 
    background: transparent; 
    border: 1px solid rgba(0, 204, 255, 0.4); 
    border-radius: 6px; 
    color: #00ccff; 
    font-weight: 600; 
    font-size: 11px; 
    text-transform: uppercase; 
    text-decoration: none; 
    transition: 0.2s ease; 
    flex: 1; 
    min-width: 130px; 
    text-align: center; 
    letter-spacing: 0.5px;
}
.astroftbtns_btn:hover { 
    background: rgba(0, 204, 255, 0.1); 
    border-color: #00ccff; 
    color: #ffffff;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.3);
}
.astroftbtns_btn.astroftbtns_gold { border-color: rgba(255, 170, 51, 0.4); color: #ffaa33; }
.astroftbtns_btn.astroftbtns_gold:hover { background: rgba(255, 170, 51, 0.1); border-color: #ffaa33; color: #ffffff; box-shadow: 0 0 10px rgba(255, 170, 51, 0.3); }

.astroftbtns_btn.astroftbtns_purple { border-color: rgba(204, 102, 255, 0.4); color: #cc66ff; }
.astroftbtns_btn.astroftbtns_purple:hover { background: rgba(204, 102, 255, 0.1); border-color: #cc66ff; color: #ffffff; box-shadow: 0 0 10px rgba(204, 102, 255, 0.3); }

.astroftbtns_btn.astroftbtns_green { border-color: rgba(74, 255, 136, 0.4); color: #4aff88; }
.astroftbtns_btn.astroftbtns_green:hover { background: rgba(74, 255, 136, 0.1); border-color: #4aff88; color: #ffffff; box-shadow: 0 0 10px rgba(74, 255, 136, 0.3); }

.astroftbl_newmission { background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(0, 204, 255, 0.15); border-radius: 10px; padding: 10px 12px; margin-top: 10px; }
.astroftbl_ships_table { width: 100%; border-collapse: collapse; font-size: 10.5px; }
.astroftbl_ships_table tr.astroftbl_head th { background: rgba(0, 0, 0, 0.3); color: var(--accent-cyan); padding: 5px 6px; font-weight: 700; text-align: left; border-bottom: 1px solid rgba(0, 204, 255, 0.2); }
.astroftbl_ships_table tbody tr { border-bottom: 1px dashed rgba(0, 204, 255, 0.08); }
.astroftbl_ships_table tbody td { padding: 3px 6px; color: var(--text-main); }
.astroftbl_ships_table tbody td a { color: var(--accent-cyan); text-decoration: none; font-weight: 600; }
.astroftbl_ships_table tbody td.astroftbl_shipcount { color: var(--accent-green); font-family: var(--font-mono); font-weight: 700; }
.astroftbl_ship_input { padding: 4px 6px; background: rgba(0, 0, 0, 0.5); border: 1px solid rgba(0, 204, 255, 0.35); border-radius: 8px; color: #ffffff; font-family: var(--font-mono); font-weight: 700; font-size: 10.5px; outline: none; text-align: right; width: 70px; }
.astroftbl_ship_input:focus { border-color: #00ccff; box-shadow: 0 0 12px rgba(0, 204, 255, 0.5); }

/* ====== BOTONES DE ACCIÓN (MAX, SELECCIONAR, ETC) ====== */
.astroftbl_link_btn { 
    display: inline-block;
    padding: 4px 10px; 
    background: transparent;
    border: 1px solid rgba(74, 255, 136, 0.4); 
    border-radius: 4px; 
    color: #4aff88; 
    font-weight: 600; 
    font-size: 8px; 
    text-decoration: none; 
    cursor: pointer; 
    transition: 0.2s ease;
    text-transform: uppercase;
}
.astroftbl_link_btn:hover { 
    background: rgba(74, 255, 136, 0.1); 
    border-color: #4aff88; 
    color: #ffffff;
    box-shadow: 0 0 8px rgba(74, 255, 136, 0.3);
}
.astroftbl_link_btn.red {
    border-color: rgba(255, 68, 136, 0.4); 
    color: #ff4488; 
}
.astroftbl_link_btn.red:hover { 
    background: rgba(255, 68, 136, 0.1); 
    border-color: #ff4488; 
    color: #ffffff;
    box-shadow: 0 0 8px rgba(255, 68, 136, 0.3);
}
.astroftbl_submit_row { text-align: center; padding-top: 8px; margin-top: 8px; border-top: 1px solid rgba(0, 204, 255, 0.15); }
/* ====== BOTÓN CONTINUAR ====== */
.astroftbl_submit { 
    display: inline-block; 
    padding: 10px 32px; 
    background: transparent; 
    border: 1px solid rgba(0, 204, 255, 0.4); 
    border-radius: 6px; 
    color: #00ccff; 
    font-weight: 600; 
    font-size: 12px; 
    cursor: pointer; 
    text-transform: uppercase; 
    transition: 0.2s ease; 
    letter-spacing: 0.5px;
}
.astroftbl_submit:hover { 
    background: rgba(0, 204, 255, 0.1); 
    border-color: #00ccff; 
    color: #ffffff; 
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.3);
}

.astroftbl_bonus { background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(255, 170, 51, 0.25); border-radius: 10px; padding: 10px 12px; margin-top: 10px; }
.astroftbl_bonus_title { color: var(--accent-gold); font-weight: 700; font-size: 11px; text-transform: uppercase; border-bottom: 1px solid rgba(255, 170, 51, 0.2); padding-bottom: 4px; margin-bottom: 6px; display: block; }
.astroftbl_bonus_table { width: 100%; border-collapse: collapse; font-size: 10.5px; }
.astroftbl_bonus_table th { color: var(--text-main); padding: 4px 6px; text-align: center; background: rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(255, 170, 51, 0.15); }
.astroftbl_bonus_table td { color: var(--accent-green); font-weight: 700; font-family: var(--font-mono); padding: 4px 6px; text-align: center; border-bottom: 1px dashed rgba(255, 170, 51, 0.08); }

/* ============================================================ */
/* ====== RESPONSIVE (MÓVIL) ================================== */
/* ============================================================ */
@media (max-width: 720px) {
    .fleet-radar { padding: 2px 5px; height: 35px; }
    .planet-icon { font-size: 14px; }
    .traveler-ship { font-size: 14px; }
    .planet-name { font-size: 6px; }
    .planet-coords { font-size: 6px; }
    .traveler-timer { font-size: 7px; padding: 0px 3px; margin-top: 0px; }
    
    .astroftbtns_zone { display: grid !important; grid-template-columns: 1fr 1fr !important; gap: 4px !important; padding: 6px !important; }
    .astroftbtns_btn { padding: 5px 2px !important; font-size: 8.5px !important; line-height: 1.1 !important; min-width: 0 !important; letter-spacing: 0 !important; }
    
    .astroftbl_submit { padding: 8px 20px !important; font-size: 10px !important; width: 100% !important; max-width: 250px !important; margin: 0 auto !important; display: block !important; }
    
    .astroftbl_ships_table th, .astroftbl_ships_table td { padding: 2px 4px !important; font-size: 9px !important; }
    .astroftbl_ship_input { width: 50px !important; padding: 2px 4px !important; font-size: 10px !important; }
	.fleet-header .btn-hud {
        padding: 3px 6px !important;
        font-size: 8px !important;
        height: auto !important;
        min-height: 0 !important;
        line-height: 1.1 !important;
        margin: 0 !important;
        box-sizing: border-box !important;
        display: inline-block !important;
        vertical-align: middle !important;
    }
}
</style>

<div class="astroftbl_wrap">
	<div class="astroftbl_panel">
		<span class="astroftbl_section_title">🛰 {$LNG.lm_fleet} — RADAR TÁCTICO</span>

		<div class="astroftbl_counters">
			<div class="astroftbl_counter">🚀 {$LNG.fl_fleets} <b>{$activeFleetSlots} / {$maxFleetSlots}</b></div>
			<div class="astroftbl_counter astroftbl_exp">🔭 {$LNG.fl_expeditions} <b>{$activeExpedition} / {$maxExpedition}</b></div>
		</div>

		{foreach name=FlyingFleets item=FlyingFleetRow from=$FlyingFleetList}
			{assign var="missionColorClass" value="mission-default"}
			{assign var="shipIcon" value="🚀"} {* Misión normal y Transporte *}
			
			{* Lógica de Iconos y Colores Personalizados *}
			{if $FlyingFleetRow.is_incoming}
				{assign var="missionColorClass" value="mission-attack"}
			{elseif $FlyingFleetRow.mission == 15}
				{assign var="missionColorClass" value="mission-expedition"}
				{assign var="shipIcon" value="🚀"} {* Expedición *}
			{elseif $FlyingFleetRow.mission == 3}
				{assign var="missionColorClass" value="mission-transport"}
				{assign var="shipIcon" value="🚀"} {* Transporte *}
			{elseif $FlyingFleetRow.mission == 6}
				{assign var="missionColorClass" value="mission-espionage"}
				{assign var="shipIcon" value="🕵️"} {* Espionaje *}
			{elseif $FlyingFleetRow.mission == 4}
				{assign var="missionColorClass" value="mission-deploy"}
				{assign var="shipIcon" value="🛡️"} {* Despliegue *}
			{elseif $FlyingFleetRow.mission == 1 || $FlyingFleetRow.mission == 2 || ($FlyingFleetRow.mission >= 20 && $FlyingFleetRow.mission <= 23)}
				{assign var="missionColorClass" value="mission-attack"}
				{assign var="shipIcon" value="⚔️"} {* Ataque *}
			{/if}

			{* Si es vuelta, forzamos el icono de cohete *}
			{if $FlyingFleetRow.state == 1}
				{assign var="fase" value="VUELTA"}
				{assign var="shipIcon" value="🚀"} {* Regreso *}
			{else}
				{assign var="fase" value="IDA"}
			{/if}

			{assign var="startIcon" value="🪐"}
			{if isset($FlyingFleetRow.start_type) && $FlyingFleetRow.start_type == 3}{assign var="startIcon" value="🌑"}{/if}

			{assign var="destIcon" value="🪐"}
			{if $FlyingFleetRow.mission == 15}
				{assign var="destIcon" value="🌌"} {* Destino Expedición *}
			{elseif $FlyingFleetRow.mission == 8}
				{assign var="destIcon" value="♻️"}
			{elseif isset($FlyingFleetRow.end_type) && $FlyingFleetRow.end_type == 3}
				{assign var="destIcon" value="🌑"}
			{elseif isset($FlyingFleetRow.end_type) && $FlyingFleetRow.end_type == 2}
				{assign var="destIcon" value="☄️"}
			{/if}

			<div class="fleet-card {$missionColorClass}">
				<div class="fleet-header">
					{* 🔥 AQUÍ APLICAMOS EL COLOR DINÁMICO 🔥 *}
					<div class="fleet-mission">{$FlyingFleetRow.mission_label} ({$fase})</div>
					<div>
						{if !$isVacation && $FlyingFleetRow.state != 1 && !$FlyingFleetRow.is_incoming}
							<form action="game.php?page=fleetTable&amp;action=sendfleetback" method="post" style="display:inline;">
								<input name="fleetID" value="{$FlyingFleetRow.id}" type="hidden">
								<button type="submit" class="btn-hud danger">VIRAR</button>
							</form>
							{if $FlyingFleetRow.mission == 1}
							<form action="game.php?page=fleetTable&amp;action=acs" method="post" style="display:inline;">
								<input name="fleetID" value="{$FlyingFleetRow.id}" type="hidden">
								<button type="submit" class="btn-hud purple">SAC</button>
							</form>
							{/if}
						{/if}
					</div>
				</div>

				<div class="fleet-radar">
					<div class="planet-node start-node">
						<span class="planet-icon">{$startIcon}</span>
						<span class="planet-name">Origen</span>
						<span class="planet-coords">[{$FlyingFleetRow.startGalaxy}:{$FlyingFleetRow.startSystem}:{$FlyingFleetRow.startPlanet}]</span>
					</div>

					<div class="radar-track-container">
						<div class="radar-line"></div>
						
						<div class="planet-node center-node">
							<span class="planet-icon">{$destIcon}</span>
							<span class="planet-name">Destino</span>
							<span class="planet-coords">[{$FlyingFleetRow.endGalaxy}:{$FlyingFleetRow.endSystem}:{$FlyingFleetRow.endPlanet}]</span>
						</div>

						<div class="planet-node end-node">
							<span class="planet-icon">{$startIcon}</span>
							<span class="planet-name">Retorno</span>
							<span class="planet-coords">[{$FlyingFleetRow.startGalaxy}:{$FlyingFleetRow.startSystem}:{$FlyingFleetRow.startPlanet}]</span>
						</div>

						<div class="traveler-container" id="traveler_{$smarty.foreach.FlyingFleets.iteration}"
							 data-fleet-id="{$FlyingFleetRow.id}"
							 data-fleet-end-time="{$FlyingFleetRow.returntime}" 
							 data-fleet-total-time="{$FlyingFleetRow.resttime}"
							 data-fleet-state="{$FlyingFleetRow.state}">
							
							<div class="traveler-ship">{$shipIcon}</div>
							<div class="traveler-timer" id="timer_{$smarty.foreach.FlyingFleets.iteration}">
								{pretty_fly_time({$FlyingFleetRow.resttime})}
							</div>

							<!-- TOOLTIP PERSONALIZADO (Desglose) -->
							<div class="hud-tooltip">
								<div class="tooltip-title">Información de Flota</div>
								
								{* AQUÍ SE MUESTRA EL DESGLOSE DE NAVES *}
								{if isset($FlyingFleetRow.ships_array) && $FlyingFleetRow.ships_array|@count > 0}
									{foreach $FlyingFleetRow.ships_array as $shipId => $count}
										{if $count > 0}
											<div class="tooltip-row">
												<span>{$LNG.tech[$shipId]}:</span>
												<span>{$count|number}</span>
											</div>
										{/if}
									{/foreach}
								{else}
									<div class="tooltip-row">
										<span>Total Naves:</span>
										<span>{$FlyingFleetRow.amount|number}</span>
									</div>
								{/if}

								{* RECURSOS *}
								{if isset($FlyingFleetRow.fleet_resource_metal) && ($FlyingFleetRow.fleet_resource_metal > 0 || $FlyingFleetRow.fleet_resource_crystal > 0 || $FlyingFleetRow.fleet_resource_deuterium > 0)}
									<div class="tooltip-section-title">Recursos</div>
									{if $FlyingFleetRow.fleet_resource_metal > 0}
									<div class="tooltip-row"><span>Metal:</span><span style="color:var(--accent-cyan);">{$FlyingFleetRow.fleet_resource_metal|number}</span></div>
									{/if}
									{if $FlyingFleetRow.fleet_resource_crystal > 0}
									<div class="tooltip-row"><span>Cristal:</span><span style="color:var(--accent-cyan);">{$FlyingFleetRow.fleet_resource_crystal|number}</span></div>
									{/if}
									{if $FlyingFleetRow.fleet_resource_deuterium > 0}
									<div class="tooltip-row"><span>Deuterio:</span><span style="color:var(--accent-cyan);">{$FlyingFleetRow.fleet_resource_deuterium|number}</span></div>
									{/if}
								{/if}
							</div>

						</div>
					</div>
				</div>
			</div>
		{foreachelse}
			<div style="text-align: center; color: var(--text-muted); padding: 30px; border: 1px dashed var(--border-color); border-radius: 8px;">
				[ NO HAY FLOTAS EN VUELO ]
			</div>
		{/foreach}

		<div class="astroftbtns_zone">
			<a href="game.php?page=fleettools&amp;tab=reunir-flotas" class="astroftbtns_btn">🚀 Reunir Flotas</a>
			<a href="game.php?page=fleettools&amp;tab=reunir-recursos" class="astroftbtns_btn astroftbtns_gold">📦 Reunir Recursos</a>
			<a href="game.php?page=fleettools&amp;tab=distribuir" class="astroftbtns_btn astroftbtns_purple">🔄 Distribuir</a>
			<a href="game.php?page=fleettools&amp;tab=multi-exped" class="astroftbtns_btn astroftbtns_green">🌌 Multi-Exped</a>
		</div>

		<form action="?page=fleetStep1" method="post">
			<input type="hidden" name="galaxy" value="{$targetGalaxy}">
			<input type="hidden" name="system" value="{$targetSystem}">
			<input type="hidden" name="planet" value="{$targetPlanet}">
			<input type="hidden" name="type" value="{$targetType}">
			<input type="hidden" name="target_mission" value="{$targetMission}">

			<div class="astroftbl_newmission">
				<span class="astroftbl_section_title">🚀 {$LNG.fl_new_mission_title}</span>

				{if count($FleetsOnPlanet) > 0}
				<table class="astroftbl_ships_table">
					<tr class="astroftbl_head">
						<th>{$LNG.fl_ship_type}</th>
						<th>{$LNG.fl_ship_available}</th>
						<th>-</th>
						<th>-</th>
					</tr>
					{foreach $FleetsOnPlanet as $FleetRow}
					{assign var="shipId" value=$FleetRow.id}
					{assign var="shipName" value=$LNG.tech[$shipId]}
					<tr>
						<td>{$shipName}</td>
						<td id="ship{$shipId}_value" class="astroftbl_shipcount">{$FleetRow.count|number}</td>
						{if $FleetRow.speed != 0}
						<td><a href="javascript:maxShip('ship{$shipId}');" class="astroftbl_link_btn">{$LNG.fl_max}</a></td>
						<td><input name="ship{$shipId}" id="ship{$shipId}_input" size="10" value="0" class="astroftbl_ship_input"></td>
						{else}
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						{/if}
					</tr>
					{/foreach}
					<tr>
						<td colspan="2"><a href="javascript:noShips();" class="astroftbl_link_btn red">{$LNG.fl_remove_all_ships}</a></td>
						<td colspan="2" style="text-align: right;"><a href="javascript:maxShips();" class="astroftbl_link_btn">{$LNG.fl_select_all_ships}</a></td>
					</tr>
				</table>
				{else}
				<div style="color: #ef4444; text-align: center; padding: 10px;">⚠ {$LNG.fl_no_ships}</div>
				{/if}

				{if $maxFleetSlots != $activeFleetSlots}
				<div class="astroftbl_submit_row">
					<input type="submit" value="{$LNG.fl_continue}" class="astroftbl_submit">
				</div>
				{/if}
			</div>
		</form>

		<div class="astroftbl_bonus">
			<span class="astroftbl_bonus_title">⚔ {$LNG.fl_bonus}</span>
			<table class="astroftbl_bonus_table">
				<tr>
					<th>{$LNG.fl_bonus_attack}</th>
					<th>{$LNG.fl_bonus_defensive}</th>
					<th>{$LNG.fl_bonus_shield}</th>
				</tr>
				<tr>
					<td>+{$bonusAttack} %</td>
					<td>+{$bonusDefensive} %</td>
					<td>+{$bonusShield} %</td>
				</tr>
				<tr>
					<th>{$LNG.tech.115}</th>
					<th>{$LNG.tech.117}</th>
					<th>{$LNG.tech.118}</th>
				</tr>
				<tr>
					<td>+{$bonusCombustion} %</td>
					<td>+{$bonusImpulse} %</td>
					<td>+{$bonusHyperspace} %</td>
				</tr>
			</table>
		</div>
	</div>
</div>

{/block}

{block name="script" append}
<script src="scripts/game/fleetTable.js"></script>

{literal}
<script>
document.addEventListener("DOMContentLoaded", function() {
    var travelers = document.querySelectorAll('.traveler-container');
    if (travelers.length === 0) return;

    var pageLoadTime = Math.floor(Date.now() / 1000);
    var reloading = false;

    // --- SISTEMA ANTI-BUCLE ---
    function getReloadedList() {
        try { return JSON.parse(sessionStorage.getItem('fleet_reloaded_et') || '[]'); }
        catch (e) { return []; }
    }
    function markReloaded(id) {
        var arr = getReloadedList();
        if (arr.indexOf(id) === -1) {
            arr.push(id);
            try { sessionStorage.setItem('fleet_reloaded_et', JSON.stringify(arr)); } catch (e) {}
        }
    }
    function wasReloaded(id) {
        return getReloadedList().indexOf(id) !== -1;
    }
    // --------------------------

    function updateRadar() {
        if (reloading) return;
        var now = Math.floor(Date.now() / 1000);
        var shouldReload = false;

        travelers.forEach(function(traveler) {
            var endTime = parseInt(traveler.getAttribute('data-fleet-end-time'), 10);
            var totalTime = parseInt(traveler.getAttribute('data-fleet-total-time'), 10);
            var state = parseInt(traveler.getAttribute('data-fleet-state'), 10);
            var fleetId = traveler.getAttribute('data-fleet-id');
            
            var index = traveler.id.replace('traveler_', '');
            var timerEl = document.getElementById('timer_' + index);

            if (isNaN(endTime) || endTime === 0) {
                if (!isNaN(totalTime) && totalTime > 0) {
                    endTime = pageLoadTime + totalTime;
                    traveler.setAttribute('data-fleet-end-time', endTime);
                } else {
                    return;
                }
            }

            var left = endTime - now;
            var percent = 0;
            
            if (!isNaN(totalTime) && totalTime > 0) {
                var progress = (totalTime - left) / totalTime;
                if (state === 0) {
                    percent = 3 + (progress * 47);
                    if (percent < 3) percent = 3;
                    if (percent > 50) percent = 50;
                } else {
                    percent = 50 + (progress * 47);
                    if (percent < 50) percent = 50;
                    if (percent > 97) percent = 97;
                }
            }

            traveler.style.left = percent + '%';

            if (left <= 0) {
                if (!wasReloaded(fleetId)) {
                    // Primera vez que llega a 0: Recargar
                    if (timerEl) timerEl.textContent = '00:00:00';
                    traveler.style.left = (state === 0) ? '50%' : '97%';
                    markReloaded(fleetId);
                    shouldReload = true;
                } else {
                    // Ya recargamos y sigue en 0: Mostrar Procesando...
                    if (timerEl) {
                        timerEl.textContent = 'Procesando...';
                        timerEl.style.color = '#ef4444'; // Color rojo
                        timerEl.style.borderColor = '#ef4444';
                    }
                    traveler.style.left = (state === 0) ? '50%' : '97%';
                }
            } else {
                if (timerEl) {
                    var h = Math.floor(left / 3600);
                    var m = Math.floor((left % 3600) / 60);
                    var s = left % 60;
                    timerEl.textContent = (h < 10 ? '0' : '') + h + ':' + (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
                    // Restaurar estilos por si acaso
                    timerEl.style.color = '';
                    timerEl.style.borderColor = '';
                }
            }
        });

        if (shouldReload && !reloading) {
            reloading = true;
            setTimeout(function() { window.location.reload(); }, 1500);
        }
    }

    updateRadar();
    setInterval(updateRadar, 1000);
});
</script>
{/literal}
{/block}