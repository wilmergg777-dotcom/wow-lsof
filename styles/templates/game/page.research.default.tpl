{block name="title" prepend}{$LNG.lm_research}{/block}
{block name="content"}

{* ============================================================
   ASTROIO RESEARCH v3.2 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrorc_    (aislado, no rompe otros módulos)
   FIX v3.2:
     - Números acortados con shortly_number() → "14.4Q"
     - Tooltip con número completo al hover
     - Grid de costos ajustado para que quepan 3 recursos
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
.astrorc_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Aviso laboratorio en construcción ====== */
.astrorc_warn {
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

/* ====== Cabecera del panel ====== */
.astrorc_panel_header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 10px 15px;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    margin-bottom: 15px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astrorc_panel_title {
    color: #ffffff;
    font-weight: 800;
    font-size: 16px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    display: inline-flex;
    align-items: center;
    gap: 10px;
    margin: 0;
}
.astrorc_panel_title::before {
    content: "🧪";
    font-size: 20px;
    filter: drop-shadow(0 0 8px rgba(170, 68, 255, 0.7));
}

/* Botón Planetario dentro del panel */
.astrorc_planetario_btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(170, 68, 255, 0.9));
    border: 1px solid rgba(170, 68, 255, 0.5);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.4px;
    text-decoration: none;
    text-transform: uppercase;
    box-shadow: 0 2px 10px rgba(119, 0, 204, 0.5);
    transition: 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}
.astrorc_planetario_btn:hover {
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.95), rgba(204, 102, 255, 0.95));
    box-shadow: 0 0 18px rgba(170, 68, 255, 0.75), 0 2px 10px rgba(119, 0, 204, 0.55);
    transform: translateY(-1px);
    color: #ffffff;
}
.astrorc_planetario_btn .astrorc_planetario_icon {
    font-size: 14px;
    line-height: 1;
}

/* ====== Cola de producción ====== */
.astrorc_queue {
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
.astrorc_queue table { width: 100%; border-collapse: collapse; font-size: 11px; }
.astrorc_queue tr { background: rgba(0, 0, 0, 0.25); border-bottom: 1px solid rgba(170, 68, 255, 0.1); }
.astrorc_queue tr:hover { background: rgba(170, 68, 255, 0.08); }
.astrorc_queue td { padding: 6px 8px; color: var(--text-main); vertical-align: middle; }
.astrorc_queue .astrorc_q_name { color: #aa44ff; font-weight: 700; font-size: 12px; }
.astrorc_queue .timer { color: #66ff99 !important; font-weight: 700; font-family: 'Courier New', monospace; font-size: 11px; }

/* Título de sección de la cola */
.astrorc_section_title {
    color: #aa44ff;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(170, 68, 255, 0.25);
    padding-bottom: 6px;
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    gap: 8px;
}

/* Barra de progreso */
#progressbar {
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(170, 68, 255, 0.35) !important;
    border-radius: 6px !important;
    height: 10px !important;
    overflow: hidden !important;
    margin-top: 6px !important;
}
#progressbar > div, #progressbar .progressbar-inner {
    background: linear-gradient(90deg, #7700cc, #aa44ff) !important;
    box-shadow: 0 0 10px rgba(170, 68, 255, 0.7) !important;
    height: 100% !important;
}
#time { color: #aa44ff !important; font-weight: 700 !important; font-family: 'Courier New', monospace !important; font-size: 11px; }

/* Botón cancelar cola */
.build_submit.onlist {
    background: linear-gradient(135deg, rgba(170, 0, 68, 0.9), rgba(204, 34, 102, 0.9)) !important;
    border: 1px solid #ff4488 !important;
    color: #ffffff !important;
    border-radius: 6px !important;
    font-weight: 700 !important;
    font-size: 10px !important;
    padding: 4px 10px !important;
    cursor: pointer !important;
    transition: 0.25s ease !important;
    font-family: inherit !important;
}
.build_submit.onlist:hover {
    background: linear-gradient(135deg, rgba(204, 34, 102, 0.95), rgba(255, 68, 136, 0.95)) !important;
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.7) !important;
}

/* ====== Panel grid ====== */
.astrorc_panel {
    background: transparent;
    padding: 0;
    color: var(--text-main);
    max-width: 1400px;
    margin: 0 auto;
}

/* ====== Grid de tarjetas — 3 columnas ====== */
.astrorc_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 15px;
    width: 100%;
}
@media (max-width: 1200px) { .astrorc_grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 720px)  { .astrorc_grid { grid-template-columns: repeat(2, 1fr); gap: 8px; } }

/* ====== Tarjeta individual (estilo Xnova moderno) ====== */
.astrorc_card {
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
.astrorc_card:hover {
    border-color: rgba(170, 68, 255, 0.7);
    box-shadow: 0 8px 30px rgba(170, 68, 255, 0.3), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: translateY(-4px);
}

/* ====== Imagen grande (estilo Xnova) ====== */
.astrorc_card_img {
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
.astrorc_card_img::after {
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

/* Badge de nivel arriba a la derecha */
.astrorc_card_lvl_badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(0, 0, 0, 0.75);
    border: 1px solid rgba(170, 68, 255, 0.6);
    border-radius: 6px;
    padding: 3px 10px;
    font-size: 11px;
    font-weight: 700;
    color: #cc88ff;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    z-index: 2;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    box-shadow: 0 0 12px rgba(170, 68, 255, 0.4);
}

/* Overlay inferior con nombre */
.astrorc_card_overlay {
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
.astrorc_card_title {
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
.astrorc_card_title:hover {
    color: #cc88ff;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 1), 0 0 15px rgba(170, 68, 255, 0.9);
}
.astrorc_card_lvl {
    color: #cbd5e1;
    font-size: 11px;
    font-weight: 600;
    text-shadow: 0 1px 4px rgba(0, 0, 0, 1);
}

/* ====== Cuerpo ====== */
.astrorc_card_body {
    padding: 12px 15px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex-grow: 1;
}

/* Fila de tiempo */
.astrorc_time_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 11px;
    color: var(--text-muted);
    padding: 4px 0;
    gap: 10px;
}
.astrorc_time_row .astrorc_val {
    color: #cc88ff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
    text-shadow: 0 0 8px rgba(170, 68, 255, 0.4);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 65%;
    text-align: right;
}

/* ====== Fila de costos — GRID DE 3 COLUMNAS AJUSTADO ====== */
.astrorc_costs {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 6px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 8px;
    padding: 6px 8px;
}
.astrorc_cost {
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
.astrorc_cost.no { color: #ff4488; }
.astrorc_cost .astrorc_cost_icon {
    font-size: 12px;
    line-height: 1;
    display: inline-block;
    filter: drop-shadow(0 0 3px rgba(255, 255, 255, 0.3));
    flex-shrink: 0;
}
.astrorc_cost .astrorc_cost_value {
    font-family: 'Courier New', monospace;
    font-size: 11px;
    overflow: hidden;
    text-overflow: ellipsis;
    min-width: 0;
    flex: 1;
}

/* ====== Footer con botón ====== */
.astrorc_card_footer {
    padding: 0 15px 15px 15px;
}
.astrorc_form { margin: 0; }

.astrorc_btn {
    display: block;
    width: 100%;
    box-sizing: border-box;
    padding: 10px 12px;
    border: 1px solid rgba(170, 68, 255, 0.5);
    border-radius: 8px;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    color: #ffffff;
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(170, 68, 255, 0.9));
    box-shadow: 0 2px 10px rgba(119, 0, 204, 0.4);
    transition: 0.25s ease;
    font-family: inherit;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    text-transform: uppercase;
}
.astrorc_btn:hover {
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.95), rgba(204, 102, 255, 0.95));
    box-shadow: 0 0 18px rgba(170, 68, 255, 0.75), 0 2px 10px rgba(119, 0, 204, 0.5);
    transform: translateY(-2px);
}
.astrorc_btn.disabled {
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
    cursor: not-allowed;
    box-shadow: none;
}
.astrorc_btn.disabled:hover { transform: none; box-shadow: none; }

/* ====== Responsive ====== */
@media (max-width: 1200px) {
    .astrorc_card_img { height: 160px; }
}
@media (max-width: 720px) {
    /* --- Estilos generales de la vista móvil --- */
    .astrorc_wrap { padding: 8px !important; }
    .astrorc_panel { padding: 8px 0 !important; }
    .astrorc_panel_header { padding: 8px 10px !important; margin-bottom: 10px !important; }
    .astrorc_panel_title { font-size: 13px !important; }
    .astrorc_planetario_btn { padding: 5px 10px !important; font-size: 10px !important; }
    .astrorc_warn { padding: 8px 10px !important; font-size: 10px !important; }
    
    /* --- Tarjetas de investigación --- */
    .astrorc_card_img { height: 100px !important; }
    .astrorc_card_lvl_badge { top: 6px !important; right: 6px !important; padding: 2px 7px !important; font-size: 9px !important; }
    .astrorc_card_overlay { padding: 8px 10px !important; gap: 2px !important; }
    .astrorc_card_title { font-size: 12px !important; }
    .astrorc_card_lvl { font-size: 9px !important; }
    .astrorc_card_body { padding: 8px !important; gap: 5px !important; }
    .astrorc_time_row { font-size: 9px !important; padding: 2px 0 !important; }
    .astrorc_time_row .astrorc_val { font-size: 10px !important; max-width: 70% !important; }
    .astrorc_costs { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; gap: 3px !important; padding: 5px 6px !important; }
    .astrorc_cost { font-size: 9px !important; gap: 2px !important; }
    .astrorc_cost .astrorc_cost_icon { font-size: 10px !important; }
    .astrorc_cost .astrorc_cost_value { font-size: 9px !important; }
    .astrorc_card_footer { padding: 0 8px 8px 8px !important; }
    .astrorc_btn { font-size: 9px !important; padding: 7px 6px !important; letter-spacing: 0.2px !important; }

    /* ====== COLA DE INVESTIGACIÓN MÓVIL (SÚPER COMPACTA) ====== */
    .astrorc_queue { 
        padding: 6px !important; 
        margin-bottom: 10px !important; 
    }
    .astrorc_section_title { 
        font-size: 10px !important; 
        padding-bottom: 2px !important; 
        margin-bottom: 6px !important; 
    }
    
    /* Transformar tabla en tarjetas */
    .astrorc_queue table { 
        display: block !important; 
        width: 100% !important; 
        border-spacing: 0 4px !important; 
    }
    .astrorc_queue tbody { 
        display: block !important; 
        width: 100% !important; 
    }
    .astrorc_queue tr {
        display: block !important;
        background: rgba(0, 0, 0, 0.3) !important;
        border: 1px solid rgba(170, 68, 255, 0.2) !important;
        border-radius: 6px !important;
        padding: 6px 8px !important;
    }
    .astrorc_queue td {
        display: block !important;
        width: 100% !important;
        padding: 0 !important;
        border: none !important;
        margin: 0 !important;
    }
    
    /* Nombre de la tecnología y barra */
    .astrorc_queue .astrorc_q_name { 
        font-size: 11px !important; 
        margin-bottom: 4px !important; 
        color: #cc88ff !important; 
    }
    .astrorc_queue #progressbar { 
        height: 3px !important; 
        margin: 4px 0 !important; 
        border: 1px solid rgba(170, 68, 255, 0.35) !important;
    }
    
    /* Fila inferior (Tiempo + Botón) */
    .astrorc_queue td:last-child {
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: space-between !important;
        align-items: center !important;
        margin-top: 4px !important;
        padding-top: 4px !important;
        border-top: 1px solid rgba(255, 255, 255, 0.05) !important;
    }
    
    .astrorc_queue td:last-child br { 
        display: none !important; 
    }
    
    /* Tiempo en vivo */
    .astrorc_queue #time { 
        font-size: 11px !important; 
        line-height: 1 !important;
        margin: 0 !important;
        color: #cc88ff !important; 
    }
    
    /* Botón de Cancelar de la cola (Aplanado) */
    .astrorc_queue td:last-child form { 
        margin: 0 !important; 
        padding: 0 !important; 
        display: flex !important;
    }
    .astrorc_queue td:last-child .build_submit.onlist { 
        padding: 2px 8px !important; 
        font-size: 9px !important; 
        line-height: 1.2 !important;
        height: auto !important;
        min-height: 0 !important;
        border-radius: 4px !important;
        background: transparent !important;
        border: 1px solid rgba(255, 68, 136, 0.6) !important;
        color: #ff4488 !important;
        box-shadow: none !important;
    }
    
    /* Fecha final */
    .astrorc_queue .timer {
        width: 100% !important;
        text-align: right !important;
        font-size: 8px !important;
        color: #64748b !important;
        margin: 2px 0 0 0 !important;
        line-height: 1 !important;
        display: block !important;
    }
	    /* ==========================================
       QUITAR ESTILO DE BOTÓN AL NOMBRE DE LA INVESTIGACIÓN
       ========================================== */
    .astrorc_queue .astrorc_q_name form {
        display: inline !important;
    }
    .astrorc_queue .astrorc_q_name button.build_submit.onlist {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        color: #cc88ff !important; /* Mismo color que el resto del nombre */
        padding: 0 !important;
        margin: 0 !important;
        font-size: 11px !important;
        font-weight: 700 !important;
        line-height: 1.2 !important;
        text-align: left !important;
        display: inline !important;
        width: auto !important;
        height: auto !important;
        min-height: 0 !important;
        cursor: pointer !important;
    }
    
    /* Efecto sutil al pasar el dedo o el mouse */
    .astrorc_queue .astrorc_q_name button.build_submit.onlist:active,
    .astrorc_queue .astrorc_q_name button.build_submit.onlist:hover {
        text-decoration: underline;
        color: #ffffff !important;
        background: transparent !important;
    }
}

</style>

<div class="astrorc_wrap">

	{* ============ Aviso: laboratorio en construcción ============ *}
	{if $IsLabinBuild}
	<div class="astrorc_warn">⚠ {$LNG.bd_building_lab}</div>
	{/if}

	{* ================== COLA DE INVESTIGACIÓN ================== *}
	{if !empty($Queue)}
	<div class="astrorc_queue">
		<span class="astrorc_section_title">🧪 {$LNG.sys_techlist}</span>
		<table>
			{foreach $Queue as $List}
			{$ID = $List.element}
			{if isset($ResearchList[$List.element])}
			{$CQueue = $ResearchList[$List.element]}
			{/if}
			<tr>
				<td style="width:70%;" class="astrorc_q_name">
					{$List@iteration}. 
					{if isset($CQueue) && $CQueue.maxLevel != $CQueue.level && !$IsFullQueue && $CQueue.buyable}
					<form action="game.php?page=research" method="post" class="build_form" style="display:inline;">
						<input type="hidden" name="cmd" value="insert">
						<input type="hidden" name="tech" value="{$ID}">
						<button type="submit" class="build_submit onlist">{$LNG.tech.{$ID}} {$List.level}{if !empty($List.planet)} @ {$List.planet}{/if}</button>
					</form>
					{else}
					{$LNG.tech.{$ID}} {$List.level}{if !empty($List.planet)} @ {$List.planet}{/if}
					{/if}
					{if $List@first}
					<div id="progressbar" data-time="{$List.resttime}"></div>
					{/if}
				</td>
				<td>
					{if $List@first}
					<div id="time" data-time="{$List.time}"></div>
					<form action="game.php?page=research" method="post" class="build_form" style="display:inline;">
						<input type="hidden" name="cmd" value="cancel">
						<button type="submit" class="build_submit onlist">{$LNG.bd_cancel}</button>
					</form>
					{else}
					<form action="game.php?page=research" method="post" class="build_form" style="display:inline;">
						<input type="hidden" name="cmd" value="remove">
						<input type="hidden" name="listid" value="{$List@iteration}">
						<button type="submit" class="build_submit onlist">{$LNG.bd_cancel}</button>
					</form>
					{/if}
					<br><span class="timer" data-time="{$List.endtime}">{$List.display}</span>
				</td>
			</tr>
			{/foreach}
		</table>
	</div>
	{/if}

	{* ================== PANEL CON GRID ================== *}
	<div class="astrorc_panel">

		{* ---- Cabecera con título + botón Planetario ---- *}
		<div class="astrorc_panel_header">
			<span class="astrorc_panel_title">Investigaciones</span>
			<a href="game.php?page=planet" class="astrorc_planetario_btn" title="Abrir Planetario">
				<span class="astrorc_planetario_icon">🪐</span>
				<span>Planetario</span>
			</a>
		</div>

		<div class="astrorc_grid">
		{foreach $ResearchList as $ID => $Element}
			<div class="astrorc_card">

				{* ---- Imagen grande + título superpuesto ---- *}
				<div class="astrorc_card_img"
				     style="background-image:url('{$dpath}gebaeude/{$ID}.gif');"
				     onclick="return Dialog.info({$ID})">

					{* Badge de nivel arriba a la derecha *}
					{if $Element.level > 0}
					<span class="astrorc_card_lvl_badge">Nv {$Element.level}</span>
					{/if}

					<div class="astrorc_card_overlay">
						<a class="astrorc_card_title tooltip"
						   data-tooltip-content="<div style='max-width:220px;'>{$LNG.shortDescription.{$ID}|replace:'&quot;':'&#39;'}<br><br>{$LNG.bd_remaining}<br>{foreach $Element.costOverflow as $ResType => $ResCount}{$LNG.tech.{$ResType}}: <b>{$ResCount|number}</b><br>{/foreach}</div>"
						   href="#" onclick="return Dialog.info({$ID})">
							{$LNG.tech.{$ID}}
						</a>
						<span class="astrorc_card_lvl">
							{if $Element.level > 0}
								{$LNG.bd_lvl} {$Element.level}{if $Element.maxLevel != 255}/{$Element.maxLevel}{/if}
							{else}
								{$LNG.ov_free}
							{/if}
						</span>
					</div>
				</div>

				{* ---- Cuerpo: tiempo + costos ---- *}
				<div class="astrorc_card_body">

					{* Fila de tiempo — cálculo manual sin modificador |time roto *}
					<div class="astrorc_time_row">
						<span>{$LNG.fgf_time}</span>
						<span class="astrorc_val" title="{$Element.elementTime} segundos">
							{assign var="totalSecs" value=$Element.elementTime}
							{math equation="floor(s/86400)" s=$totalSecs assign="tDays"}
							{math equation="floor((s%86400)/3600)" s=$totalSecs assign="tHours"}
							{math equation="floor((s%3600)/60)" s=$totalSecs assign="tMinutes"}
							{math equation="floor(s%60)" s=$totalSecs assign="tSecs"}
							{if $tDays > 0}{$tDays}d {/if}{$tHours|string_format:"%02d"}h {$tMinutes|string_format:"%02d"}m {$tSecs|string_format:"%02d"}s
						</span>
					</div>

					{* Fila de costos — números ACORTADOS + tooltip con número completo *}
					<div class="astrorc_costs">
						{foreach $Element.costResources as $RessID => $RessAmount}
						{assign var="fullAmount" value=$RessAmount|number}
						<div class="astrorc_cost {if $Element.costOverflow[$RessID] == 0}ok{else}no{/if}"
						     title="{$LNG.tech.{$RessID}}: {$fullAmount}">
							<span class="astrorc_cost_icon">{if $RessID == 901}🔩{elseif $RessID == 902}💎{elseif $RessID == 903}⚗️{elseif $RessID == 911}⚡{elseif $RessID == 921}🌌{elseif $RessID == 922}💰{else}▪️{/if}</span>
							<span class="astrorc_cost_value">{shortly_number($RessAmount)}</span>
						</div>
						{/foreach}
					</div>

				</div>

				{* ---- Footer: botón principal ---- *}
				<div class="astrorc_card_footer">
					{if $Element.maxLevel == $Element.levelToBuild}
						<span class="astrorc_btn disabled">{$LNG.bd_maxlevel}</span>
					{elseif $IsLabinBuild || $IsFullQueue || !$Element.buyable}
						<span class="astrorc_btn disabled">
							{if $Element.level == 0}{$LNG.bd_tech}{else}{$LNG.bd_tech_next_level} {$Element.levelToBuild + 1}{/if}
						</span>
					{else}
						<form action="game.php?page=research" method="post" class="astrorc_form">
							<input type="hidden" name="cmd" value="insert">
							<input type="hidden" name="tech" value="{$ID}">
							<button type="submit" class="astrorc_btn">
								{if $Element.level == 0}{$LNG.bd_tech}{else}{$LNG.bd_tech_next_level} {$Element.levelToBuild + 1}{/if}
							</button>
						</form>
					{/if}
				</div>

			</div>
		{/foreach}
		</div>

	</div>

</div>

{/block}

{block name="script" append}
    {if !empty($Queue)}
        <script src="scripts/game/research.js"></script>
    {/if}
{/block}