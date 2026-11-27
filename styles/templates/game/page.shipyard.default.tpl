{block name="title" prepend}{if $mode == "defense"}{$LNG.lm_defenses}{else}{$LNG.lm_shipshard}{/if}{/block}
{block name="content"}

{* ============================================================
   ASTROIO SHIPYARD v3.1 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astross_    (aislado, no rompe otros módulos)
   FIX v3.1:
     - Texto de la cola movido a la lista desplegable (recuadro amarillo)
     - Conteo regresivo ahora muestra el tiempo TOTAL de la cola
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
.astross_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Aviso: hangar en construcción ====== */
.astross_warn {
    background: rgba(255, 68, 136, 0.12);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 68, 136, 0.5);
    border-left: 4px solid #ff4488;
    border-radius: 10px;
    padding: 12px 18px;
    margin: 0 auto 15px auto;
    color: #ff6b8a;
    font-weight: 700;
    font-size: 12px;
    text-align: center;
    letter-spacing: 0.3px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4), 0 0 20px rgba(255, 68, 136, 0.15);
}

/* ====== Título de sección ====== */
.astross_section_title {
    color: #66ff99;
    font-weight: 800;
    font-size: 14px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(102, 255, 153, 0.25);
    padding-bottom: 8px;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 10px;
}

/* ====== Cola de construcción ====== */
.astross_queue {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 12px 15px;
    margin: 0 auto 15px auto;
    color: var(--text-main);
}
.astross_queue_title {
    color: #66ff99;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(102, 255, 153, 0.25);
    padding-bottom: 6px;
    margin-bottom: 10px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.astross_queue_title #timeleft {
    color: #66ff99;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
}
.astross_queue_warning {
    color: #dd8800;
    font-size: 11px;
    margin-bottom: 8px;
    font-weight: 600;
}
.astross_queue select#auftr {
    width: 100%;
    min-height: 100px;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(102, 255, 153, 0.3) !important;
    border-radius: 8px !important;
    color: #c8d6e5 !important;
    padding: 6px !important;
    font-family: 'Courier New', monospace !important;
    font-size: 11px !important;
    outline: none !important;
}
.astross_queue select#auftr option {
    background: #0f1624;
    color: #c8d6e5;
    padding: 4px;
}
.astross_queue select#auftr option:hover,
.astross_queue select#auftr option:checked {
    background: rgba(102, 255, 153, 0.2);
    color: #ffffff;
}

/* Botón de cancelar selección */
.astross_cancel_btn {
    display: inline-block;
    margin-top: 8px;
    padding: 6px 16px;
    background: linear-gradient(135deg, rgba(170, 0, 68, 0.9), rgba(204, 34, 102, 0.9));
    border: 1px solid #ff4488;
    border-radius: 6px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.4px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
    font-family: inherit;
}
.astross_cancel_btn:hover {
    background: linear-gradient(135deg, rgba(204, 34, 102, 0.95), rgba(255, 68, 136, 0.95));
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.7);
    transform: translateY(-1px);
}
.astross_queue #bx.z {
    display: none;
}

/* ====== Panel grid ====== */
.astross_panel {
    background: transparent;
    padding: 0;
    color: var(--text-main);
    max-width: 1400px;
    margin: 0 auto;
}

/* ====== GRID DE TARJETAS — 3 columnas ====== */
.astross_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 15px;
    width: 100%;
}
@media (max-width: 1200px) { .astross_grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 720px)  { .astross_grid { grid-template-columns: repeat(2, 1fr); gap: 8px; } }

/* ====== Tarjeta individual (estilo Xnova moderno) ====== */
.astross_card {
    position: relative;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
    transition: 0.3s ease;
    display: flex;
    flex-direction: column;
}
.astross_card:hover {
    border-color: rgba(102, 255, 153, 0.7);
    box-shadow: 0 8px 30px rgba(102, 255, 153, 0.25), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: translateY(-4px);
}

/* ====== Imagen grande (estilo Xnova) ====== */
.astross_card_img {
    position: relative;
    width: 100%;
    height: 180px;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-color: #0a1018;
    cursor: pointer;
    overflow: hidden;
}
.astross_card_img::after {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(to top,
        rgba(10, 16, 24, 0.95) 0%,
        rgba(10, 16, 24, 0.75) 35%,
        rgba(10, 16, 24, 0.15) 70%,
        transparent 100%);
    pointer-events: none;
}

/* Badge de cantidad disponible arriba a la derecha */
.astross_card_avail_badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(0, 0, 0, 0.75);
    border: 1px solid rgba(102, 255, 153, 0.5);
    border-radius: 6px;
    padding: 3px 10px;
    font-size: 11px;
    font-weight: 700;
    color: #66ff99;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    z-index: 2;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    box-shadow: 0 0 12px rgba(102, 255, 153, 0.3);
}

/* Overlay inferior con nombre */
.astross_card_overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    padding: 15px;
    display: flex;
    flex-direction: column;
    gap: 3px;
    z-index: 2;
    pointer-events: none;
}
.astross_card_title {
    color: #ffffff;
    font-weight: 800;
    font-size: 16px;
    text-decoration: none;
    line-height: 1.2;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 1), 0 0 20px rgba(0, 0, 0, 0.8);
    letter-spacing: 0.3px;
    pointer-events: auto;
    transition: 0.2s ease;
}
.astross_card_title:hover {
    color: #66ff99;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 1), 0 0 15px rgba(102, 255, 153, 0.9);
}
.astross_card_avail {
    color: #cbd5e1;
    font-size: 11px;
    font-weight: 600;
    text-shadow: 0 1px 4px rgba(0, 0, 0, 1);
}
.astross_card_avail b {
    color: #00e0ff;
}

/* ====== Cuerpo ====== */
.astross_card_body {
    padding: 12px 15px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex-grow: 1;
}

/* Fila de tiempo */
.astross_time_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 11px;
    color: var(--text-muted);
    padding: 4px 0;
    gap: 10px;
}
.astross_time_row .astross_val {
    color: #66ff99;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
    text-shadow: 0 0 8px rgba(102, 255, 153, 0.4);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 65%;
    text-align: right;
}

/* ====== Fila de costos — GRID DE 3 COLUMNAS AJUSTADO ====== */
.astross_costs {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 6px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 8px;
    padding: 6px 8px;
}
.astross_cost {
    display: flex;
    align-items: center;
    gap: 3px;
    font-size: 11px;
    color: #66ff99;
    font-weight: 700;
    justify-content: flex-start;
    min-width: 0;
    overflow: hidden;
    white-space: nowrap;
    cursor: help;
}
.astross_cost.no { color: #ff4488; }
.astross_cost .astross_cost_icon {
    font-size: 12px;
    line-height: 1;
    display: inline-block;
    filter: drop-shadow(0 0 3px rgba(255, 255, 255, 0.3));
    flex-shrink: 0;
}
.astross_cost .astross_cost_value {
    font-family: 'Courier New', monospace;
    font-size: 11px;
    overflow: hidden;
    text-overflow: ellipsis;
    min-width: 0;
    flex: 1;
}

/* Fila de máximo */
.astross_max {
    font-size: 10px;
    color: var(--text-main);
    padding: 4px 8px;
    background: rgba(0, 0, 0, 0.25);
    border-left: 3px solid #66ff99;
    border-radius: 4px;
    line-height: 1.4;
}
.astross_max b {
    color: #66ff99;
    font-family: 'Courier New', monospace;
}

/* ====== Footer: input + botones ====== */
.astross_card_footer {
    padding: 0 15px 15px 15px;
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.astross_input_row {
    display: flex;
    gap: 6px;
    align-items: stretch;
}
.astross_input {
    flex-grow: 1;
    padding: 6px 8px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 6px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
    outline: none;
    transition: 0.2s ease;
    text-align: center;
    min-width: 0;
}
.astross_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.55);
}
.astross_max_btn {
    padding: 6px 12px;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 102, 204, 0.9));
    border: 1px solid rgba(0, 204, 255, 0.5);
    border-radius: 6px;
    color: #ffffff;
    font-weight: 700;
    font-size: 10px;
    cursor: pointer;
    transition: 0.25s ease;
    white-space: nowrap;
    letter-spacing: 0.3px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
    font-family: inherit;
    text-transform: uppercase;
}
.astross_max_btn:hover {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 153, 255, 0.95));
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.6);
    transform: translateY(-1px);
}

.astross_btn {
    display: block;
    width: 100%;
    box-sizing: border-box;
    padding: 8px 12px;
    border: 1px solid rgba(102, 255, 153, 0.4);
    border-radius: 6px;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    color: #ffffff;
    background: linear-gradient(135deg, rgba(0, 102, 68, 0.9), rgba(0, 170, 102, 0.9));
    box-shadow: 0 2px 10px rgba(0, 102, 68, 0.4);
    transition: 0.25s ease;
    font-family: inherit;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    text-transform: uppercase;
}
.astross_btn:hover {
    background: linear-gradient(135deg, rgba(0, 170, 102, 0.95), rgba(0, 221, 136, 0.95));
    box-shadow: 0 0 16px rgba(102, 255, 153, 0.6), 0 2px 10px rgba(0, 102, 68, 0.5);
    transform: translateY(-2px);
}
.astross_btn.disabled {
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
    cursor: not-allowed;
    box-shadow: none;
}
.astross_btn.disabled:hover { transform: none; box-shadow: none; }

/* ====== Botón de Mejoras ====== */
.astross_improve_btn {
    display: block;
    width: 100%;
    box-sizing: border-box;
    padding: 8px 12px;
    border: 1px solid rgba(170, 68, 255, 0.5);
    border-radius: 6px;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    color: #dd99ff;
    background: linear-gradient(135deg, rgba(42, 10, 77, 0.9), rgba(74, 16, 128, 0.9));
    box-shadow: 0 2px 10px rgba(102, 0, 153, 0.4);
    transition: 0.25s ease;
    font-family: inherit;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
}
.astross_improve_btn:hover {
    background: linear-gradient(135deg, rgba(74, 16, 128, 0.95), rgba(119, 0, 204, 0.95));
    color: #ffffff;
    border-color: #cc88ff;
    box-shadow: 0 0 18px rgba(170, 68, 255, 0.7), 0 2px 10px rgba(102, 0, 153, 0.5);
    transform: translateY(-2px);
}

/* ====== Botón superior "Construir naves" ====== */
.astross_topbar {
    display: flex;
    justify-content: center;
    padding: 0 0 15px 0;
}
.astross_submit_all {
    display: inline-block;
    padding: 10px 32px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 12px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 4px 15px rgba(0, 102, 204, 0.5);
    text-transform: uppercase;
}
.astross_submit_all:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.7), 0 4px 15px rgba(0, 102, 204, 0.6);
    transform: translateY(-2px);
}

/* ====== Responsive ====== */
@media (max-width: 1200px) {
    .astross_card_img { height: 160px; }
}


@media (max-width: 720px) {
    .astross_wrap { padding: 8px !important; }
    .astross_panel { padding: 0 !important; }
    .astross_warn { padding: 8px 10px !important; font-size: 10px !important; }
    .astross_section_title { font-size: 12px !important; padding-bottom: 6px !important; margin-bottom: 8px !important; }
    .astross_queue { padding: 8px 10px !important; margin-bottom: 10px !important; }
    .astross_queue_title { font-size: 11px !important; }
    .astross_queue select#auftr { min-height: 70px !important; font-size: 10px !important; }
    .astross_submit_all { padding: 8px 18px !important; font-size: 11px !important; }
    .astross_card_img { height: 95px !important; }
    .astross_card_avail_badge { top: 6px !important; right: 6px !important; padding: 2px 7px !important; font-size: 9px !important; }
    .astross_card_overlay { padding: 7px 9px !important; gap: 2px !important; }
    .astross_card_title { font-size: 11px !important; }
    .astross_card_avail { font-size: 9px !important; }
    .astross_card_body { padding: 7px !important; gap: 4px !important; }
    .astross_time_row { font-size: 9px !important; padding: 2px 0 !important; }
    .astross_time_row .astross_val { font-size: 10px !important; max-width: 68% !important; }
    .astross_costs { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; gap: 3px !important; padding: 4px 5px !important; }
    .astross_cost { font-size: 9px !important; gap: 2px !important; }
    .astross_cost .astross_cost_icon { font-size: 10px !important; }
    .astross_cost .astross_cost_value { font-size: 9px !important; }
    .astross_max { font-size: 9px !important; padding: 3px 5px !important; }
    .astross_card_footer { padding: 0 7px 7px 7px !important; gap: 4px !important; }
    .astross_input_row { gap: 4px !important; }
    .astross_input { font-size: 10px !important; padding: 5px 6px !important; }
    .astross_max_btn { font-size: 9px !important; padding: 5px 8px !important; }
    .astross_btn { font-size: 9px !important; padding: 7px 5px !important; }
    .astross_improve_btn { font-size: 9px !important; padding: 6px 5px !important; }
}

</style>

<div class="astross_wrap">

	{* ============ Aviso: hangar en construcción ============ *}
	{if !$NotBuilding}
	<div class="astross_warn">⚠ {$LNG.bd_building_shipyard}</div>
	{/if}

	{* ================== COLA DE CONSTRUCCIÓN ================== *}
	{if !empty($BuildList)}
	<div class="astross_queue">
		<div class="astross_queue_title">
			<span>🏗 {$LNG.bd_operating}</span>
			{* El recuadro azul (tiempo total) se queda acá arriba *}
			<span id="timeleft"></span>
		</div>

		<form action="game.php?page=shipyard&amp;mode={$mode}" method="post">
			<input type="hidden" name="action" value="delete">

			<div class="astross_queue_warning">{$LNG.bd_cancel_warning}</div>
			{* El recuadro amarillo es este select. El JS va a poner el texto acá adentro *}
			<select name="auftr[]" id="auftr" size="10" multiple>
				<option>&nbsp;</option>
			</select>
			<br>
			<input type="submit" value="{$LNG.bd_cancel_send}" class="astross_cancel_btn">
		</form>
	</div>
	{/if}

	{* ================== FORMULARIO PRINCIPAL ================== *}
	<form action="game.php?page=shipyard&amp;mode={$mode}" method="post">

		{* Botón superior: construir todas las naves seleccionadas *}
		{if $NotBuilding}
		<div class="astross_topbar">
			<input type="submit" value="{$LNG.bd_build_ships}" class="astross_submit_all">
		</div>
		{/if}

		{* ================== PANEL CON GRID ================== *}
		<div class="astross_panel">

			<span class="astross_section_title">
				{if $mode == "defense"}🛡 {$LNG.lm_defenses}{else}🚀 {$LNG.lm_shipshard}{/if}
			</span>

			{* ============ GRID DE NAVES / DEFENSAS ============ *}
			<div class="astross_grid">
			{foreach $elementList as $ID => $Element}
				<div class="astross_card">

					{* ---- Imagen + título superpuesto ---- *}
					<div class="astross_card_img"
					     style="background-image:url('{$dpath}gebaeude/{$ID}.gif');"
					     onclick="return Dialog.info({$ID})">

						{* Badge de cantidad disponible *}
						{if $Element.available != 0}
						<span class="astross_card_avail_badge">{$Element.available|number}</span>
						{/if}

						<div class="astross_card_overlay">
							<a class="astross_card_title tooltip"
							   data-tooltip-content="<div style='max-width:220px;'>{$LNG.shortDescription.{$ID}|replace:'&quot;':'&#39;'}<br><br>{$LNG.bd_remaining}<br>{foreach $Element.costOverflow as $ResType => $ResCount}{$LNG.tech.{$ResType}}: <b>{$ResCount|number}</b><br>{/foreach}</div>"
							   href="#" onclick="return Dialog.info({$ID})">
								{$LNG.tech.{$ID}}
							</a>
							<span class="astross_card_avail" id="val_{$ID}">
								{if $Element.available != 0}
									{$LNG.bd_available} <b>{$Element.available|number}</b>
								{/if}
							</span>
						</div>
					</div>

					{* ---- Cuerpo: tiempo, costos, máximo ---- *}
					<div class="astross_card_body">

						{* Fila de tiempo — cálculo manual sin |time roto *}
						<div class="astross_time_row">
							<span>{$LNG.fgf_time}</span>
							<span class="astross_val" title="{$Element.elementTime} segundos">
								{assign var="totalSecs" value=$Element.elementTime}
								{math equation="floor(s/86400)" s=$totalSecs assign="tDays"}
								{math equation="floor((s%86400)/3600)" s=$totalSecs assign="tHours"}
								{math equation="floor((s%3600)/60)" s=$totalSecs assign="tMinutes"}
								{math equation="floor(s%60)" s=$totalSecs assign="tSecs"}
								{if $tDays > 0}{$tDays}d {/if}{$tHours|string_format:"%02d"}h {$tMinutes|string_format:"%02d"}m {$tSecs|string_format:"%02d"}s
							</span>
						</div>

						{* Grid de costos — números ACORTADOS + tooltip con número completo *}
						<div class="astross_costs">
							{foreach $Element.costResources as $RessID => $RessAmount}
							{assign var="fullAmount" value=$RessAmount|number}
							<div class="astross_cost {if $Element.costOverflow[$RessID] == 0}ok{else}no{/if}"
							     title="{$LNG.tech.{$RessID}}: {$fullAmount}">
								<span class="astross_cost_icon">{if $RessID == 901}🔩{elseif $RessID == 902}💎{elseif $RessID == 903}⚗️{elseif $RessID == 911}⚡{elseif $RessID == 921}🌌{elseif $RessID == 922}💰{else}▪️{/if}</span>
								<span class="astross_cost_value">{shortly_number($RessAmount)}</span>
							</div>
							{/foreach}
						</div>

						<div class="astross_max">
							{$LNG.bd_max_ships_long}: <b>{$Element.maxBuildable|number}</b>
						</div>

					</div>

					{* ---- Footer: input + botón Max + submit + mejoras ---- *}
					<div class="astross_card_footer">

						{if $Element.AlreadyBuild}
							<span class="astross_btn disabled">{$LNG.bd_protection_shield_only_one}</span>

						{elseif $NotBuilding && $Element.buyable}
							<div class="astross_input_row">
								<input type="text"
								       class="astross_input"
								       name="fmenge[{$ID}]"
								       id="input_{$ID}"
								       value="0"
								       tabindex="{$Element@iteration}"
								<input type="button"
								       class="astross_max_btn"
								       value="{$LNG.bd_max_ships}"
								       onclick="$('#input_{$ID}').val('{$Element.maxBuildable}')">
							</div>

						{else}
							<span class="astross_btn disabled">
								{$LNG.bd_build_ships}
							</span>
						{/if}

						{* ============ BOTÓN DE MEJORAS (siempre visible) ============ *}
						<a href="game.php?page=improvements&amp;unit_id={$ID}" class="astross_improve_btn">
							🔧 {$LNG.improvements_btn|default:'MEJORA'}
						</a>

					</div>

				</div>
			{/foreach}
			</div>

		</div>

	</form>

</div>

{/block}

{block name="script" append}
<script type="text/javascript">
data			= {$BuildList|json};
bd_operating	= '{$LNG.bd_operating}';
bd_available	= '{$LNG.bd_available}';
</script>
{if !empty($BuildList)}
<script src="scripts/base/bcmath.js"></script>
<script src="scripts/game/shipyard.js"></script>
<script type="text/javascript">
$(function() {
    ShipyardInit();
});
</script>
{/if}
{/block}