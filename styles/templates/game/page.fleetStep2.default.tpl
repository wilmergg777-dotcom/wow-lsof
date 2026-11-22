{block name="title" prepend}{$LNG.lm_fleet}{/block}
{block name="content"}

{* ============================================================
   ASTROIO FLEET STEP 2 v3.2 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrofs2_   (aislado, no rompe otros módulos)
   v3.1: Añadido bloque de clima del objetivo (ClimaEngine)
   v3.2: Añadido bloque de buff activo del atacante (ClimaEngine)
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
.astrofs2_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrofs2_panel {
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

/* ====== Título ====== */
.astrofs2_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.6px;
    text-align: center;
    padding: 4px 0 8px 0;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    margin-bottom: 10px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}

/* ============================================================== */
/* ====== 🆕 ASTROIO v3.1 - BLOQUE DE CLIMA DEL OBJETIVO ======= */
/* ============================================================== */
.astrofs2_clima_box {
    background: linear-gradient(135deg, rgba(15, 30, 50, 0.9), rgba(8, 20, 35, 0.95));
    border: 1px solid rgba(0, 224, 255, 0.35);
    border-radius: 10px;
    padding: 12px 14px;
    margin-bottom: 12px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(0, 224, 255, 0.05);
    transition: 0.2s ease;
}
.astrofs2_clima_box:hover {
    border-color: rgba(0, 224, 255, 0.55);
}
.astrofs2_clima_header {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 10.5px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--accent-cyan);
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 8px;
}
.astrofs2_clima_main {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
}
.astrofs2_clima_emoji {
    font-size: 30px;
    line-height: 1;
    filter: drop-shadow(0 0 10px rgba(0, 224, 255, 0.5));
    flex-shrink: 0;
}
.astrofs2_clima_info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 3px;
    min-width: 0;
}
.astrofs2_clima_name {
    font-size: 13px;
    font-weight: 800;
    color: #ffffff;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
    letter-spacing: 0.5px;
}
.astrofs2_clima_desc {
    font-size: 10.5px;
    color: var(--text-muted);
    font-style: italic;
    line-height: 1.3;
}
.astrofs2_clima_factors {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
    margin-top: 4px;
}
.astrofs2_clima_factor {
    display: inline-flex;
    align-items: center;
    gap: 3px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 6px;
    padding: 2px 7px;
    font-size: 9.5px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    color: #fff;
}
.astrofs2_clima_factor.positive { color: var(--accent-green); border-color: rgba(74, 255, 136, 0.4); }
.astrofs2_clima_factor.negative { color: var(--accent-red); border-color: rgba(239, 68, 68, 0.4); }
.astrofs2_clima_factor.neutral { color: var(--text-muted); }
.astrofs2_clima_predict {
    display: flex;
    align-items: center;
    gap: 8px;
    padding-top: 6px;
    margin-top: 6px;
    border-top: 1px dashed rgba(0, 224, 255, 0.2);
    font-size: 10.5px;
    color: var(--text-muted);
}
.astrofs2_clima_predict b {
    color: var(--accent-gold);
}
.astrofs2_clima_predict .pred-emoji {
    font-size: 16px;
    line-height: 1;
    filter: drop-shadow(0 0 6px rgba(255, 204, 0, 0.4));
}
.astrofs2_clima_alert {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 7px 11px;
    margin-top: 8px;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: 700;
    letter-spacing: 0.3px;
}
.astrofs2_clima_alert.danger {
    background: rgba(239, 68, 68, 0.12);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: #ff8f8f;
}
.astrofs2_clima_alert.success {
    background: rgba(74, 255, 136, 0.1);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: #88ffaa;
}

/* ============================================================== */
/* ====== 🆕 ASTROIO v3.2 - BLOQUE DE BUFF ACTIVO DEL ATACANTE = */
/* ============================================================== */
.astrofs2_buff_box {
    background: linear-gradient(135deg, rgba(15, 45, 25, 0.9), rgba(8, 30, 15, 0.95));
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px;
    padding: 10px 14px;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(74, 255, 136, 0.08);
}
.astrofs2_buff_info {
    display: flex;
    align-items: center;
    gap: 10px;
    min-width: 0;
}
.astrofs2_buff_icon {
    font-size: 26px;
    line-height: 1;
    filter: drop-shadow(0 0 10px rgba(74, 255, 136, 0.8));
    flex-shrink: 0;
}
.astrofs2_buff_texts {
    display: flex;
    flex-direction: column;
    gap: 2px;
    min-width: 0;
}
.astrofs2_buff_title {
    font-size: 10.5px;
    color: var(--accent-green);
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-shadow: 0 0 8px rgba(74, 255, 136, 0.5);
}
.astrofs2_buff_name {
    font-size: 13px;
    color: #ffffff;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(255, 255, 255, 0.3);
}
.astrofs2_buff_timer {
    text-align: right;
    flex-shrink: 0;
}
.astrofs2_buff_timer_lbl {
    font-size: 9px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astrofs2_buff_timer_val {
    font-size: 14px;
    color: var(--accent-green);
    font-family: 'Courier New', monospace;
    font-weight: 800;
    text-shadow: 0 0 8px rgba(74, 255, 136, 0.5);
}

/* ====== Grid 2 columnas ====== */
.astrofs2_grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-bottom: 10px;
}
@media (max-width: 720px) {
    .astrofs2_grid { grid-template-columns: 1fr; }
}

/* ====== Sub-panel (columna) ====== */
.astrofs2_box {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    transition: 0.2s ease;
}
.astrofs2_box:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrofs2_box_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 10.5px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    padding-bottom: 5px;
    margin-bottom: 8px;
    display: block;
}

/* ====== Misiones (radios) ====== */
.astrofs2_mission_list {
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.astrofs2_mission_item {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 3px 6px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.12);
    border-radius: 8px;
    transition: 0.25s ease;
    cursor: pointer;
}
.astrofs2_mission_item:hover {
    border-color: rgba(0, 204, 255, 0.4);
    background: rgba(0, 204, 255, 0.06);
    transform: translateY(-1px);
}
.astrofs2_mission_item input[type="radio"] {
    accent-color: #00ccff;
    width: 13px;
    height: 13px;
    cursor: pointer;
    flex-shrink: 0;
    margin: 0;
}
.astrofs2_mission_item label {
    color: var(--text-main);
    font-weight: 600;
    font-size: 11px;
    cursor: pointer;
    flex-grow: 1;
    line-height: 1.2;
}
.astrofs2_mission_item input[type="radio"]:checked + label {
    color: #00e0ff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.5);
}
.astrofs2_mission_warn {
    color: #dd8800;
    font-size: 9.5px;
    font-weight: 600;
    padding: 2px 0 0 20px;
    line-height: 1.3;
}

/* ====== Recursos ====== */
.astrofs2_resource_row {
    display: flex;
    align-items: center;
    gap: 5px;
    margin-bottom: 4px;
    padding: 1px 0;
}
.astrofs2_resource_label {
    color: var(--text-main);
    font-weight: 600;
    font-size: 10.5px;
    min-width: 55px;
    flex-shrink: 0;
}
.astrofs2_max_btn {
    color: #66ff99;
    font-weight: 700;
    font-size: 9.5px;
    text-decoration: none;
    padding: 2px 6px;
    border: 1px solid rgba(102, 255, 153, 0.35);
    border-radius: 6px;
    background: rgba(102, 255, 153, 0.05);
    transition: 0.25s ease;
    cursor: pointer;
    flex-shrink: 0;
}
.astrofs2_max_btn:hover {
    background: rgba(102, 255, 153, 0.2);
    box-shadow: 0 0 8px rgba(102, 255, 153, 0.4);
    color: #ffffff;
}
.astrofs2_input {
    flex-grow: 1;
    padding: 4px 6px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 10.5px;
    outline: none;
    transition: 0.25s ease;
    text-align: right;
    min-width: 0;
}
.astrofs2_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* Fila info (restante / consumo) */
.astrofs2_info_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 3px 2px;
    font-size: 10.5px;
    color: var(--text-muted);
    border-top: 1px dashed rgba(0, 204, 255, 0.1);
    margin-top: 4px;
}
.astrofs2_info_row .astrofs2_val {
    color: #66ff99;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
}
.astrofs2_info_row .astrofs2_val.consumption {
    color: #ffaa33;
}

.astrofs2_allres_btn {
    display: inline-block;
    color: #00e0ff;
    font-weight: 700;
    font-size: 10px;
    text-decoration: none;
    padding: 3px 8px;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 6px;
    background: rgba(0, 204, 255, 0.05);
    transition: 0.25s ease;
    cursor: pointer;
    margin-top: 4px;
}
.astrofs2_allres_btn:hover {
    background: rgba(0, 204, 255, 0.15);
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
    color: #ffffff;
    transform: translateY(-1px);
}

/* ====== Selector de tiempo de espera ====== */
.astrofs2_stay_box {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.astrofs2_stay_box:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrofs2_stay_box .astrofs2_box_title {
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
}
.astrofs2_select {
    padding: 4px 8px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 10.5px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    transition: 0.25s ease;
    width: 100%;
    max-width: 220px;
}
.astrofs2_select:focus,
.astrofs2_select:hover {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    transform: translateY(-1px);
}
.astrofs2_select option {
    background: #0f1624;
    color: #ffffff;
}

/* ====== Botón continuar ====== */
.astrofs2_submit_row {
    text-align: center;
    padding-top: 8px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
    margin-top: 6px;
}
.astrofs2_submit {
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
    box-shadow: 0 3px 10px rgba(0, 102, 204, 0.4);
    text-transform: uppercase;
}
.astrofs2_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrofs2_submit:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrofs2_wrap { padding: 10px; }
    .astrofs2_panel { padding: 12px; max-width: 100%; }
    .astrofs2_submit { width: 100%; padding: 10px 20px; }
    .astrofs2_resource_label { min-width: 50px; font-size: 10px; }
    .astrofs2_clima_emoji { font-size: 24px; }
    .astrofs2_clima_name { font-size: 11px; }
    .astrofs2_clima_desc { font-size: 10px; }
    .astrofs2_clima_factor { font-size: 9px; padding: 1px 5px; }
    .astrofs2_buff_box { padding: 8px 10px; flex-wrap: wrap; }
    .astrofs2_buff_icon { font-size: 22px; }
    .astrofs2_buff_timer { width: 100%; text-align: left; }
}
</style>

<div class="astrofs2_wrap">

	<div class="astrofs2_panel">

		{* ============ TÍTULO CON DESTINO ============ *}
		<div class="astrofs2_title">
			🎯 {$galaxy}:{$system}:{$planet} — {$LNG["type_planet_{$type}"]}
		</div>

		{* ═══════════════════════════════════════════════════════════
		 * 🆕 ASTROIO v3.1 - BLOQUE DE CLIMA DEL OBJETIVO
		 * Muestra el clima actual y la predicción para que el jugador
		 * decida si atacar, saquear o esperar a mañana.
		 * ═══════════════════════════════════════════════════════════ *}
		{if isset($clima_objetivo) && $clima_objetivo}
		<div class="astrofs2_clima_box">
			<div class="astrofs2_clima_header">
				🌦️ Clima del objetivo
			</div>

			<div class="astrofs2_clima_main">
				{assign var="co_emoji" value="❓"}
				{if $clima_objetivo.clave == 'despejado'}{assign var="co_emoji" value="☀️"}
				{elseif $clima_objetivo.clave == 'brisa_solar'}{assign var="co_emoji" value="🌤️"}
				{elseif $clima_objetivo.clave == 'viento_estelar'}{assign var="co_emoji" value="🍃"}
				{elseif $clima_objetivo.clave == 'cristalino'}{assign var="co_emoji" value="✨"}
				{elseif $clima_objetivo.clave == 'niebla'}{assign var="co_emoji" value="🌫️"}
				{elseif $clima_objetivo.clave == 'tormenta_solar'}{assign var="co_emoji" value="⚡"}
				{elseif $clima_objetivo.clave == 'meteoros'}{assign var="co_emoji" value="☄️"}
				{elseif $clima_objetivo.clave == 'nebulosa'}{assign var="co_emoji" value="💰"}
				{elseif $clima_objetivo.clave == 'plasma'}{assign var="co_emoji" value="🌌"}
				{elseif $clima_objetivo.clave == 'eclipse'}{assign var="co_emoji" value="🌓"}
				{elseif $clima_objetivo.clave == 'campo_mag'}{assign var="co_emoji" value="🌀"}
				{elseif $clima_objetivo.clave == 'aurora'}{assign var="co_emoji" value="🌈"}
				{elseif $clima_objetivo.clave == 'agujero'}{assign var="co_emoji" value="🕳️"}
				{elseif $clima_objetivo.clave == 'singularidad'}{assign var="co_emoji" value="⚫"}
				{/if}
				<div class="astrofs2_clima_emoji">{$co_emoji}</div>
				<div class="astrofs2_clima_info">
					<div class="astrofs2_clima_name">{$clima_objetivo.nombre}</div>
					<div class="astrofs2_clima_desc">"{$clima_objetivo.descripcion}"</div>
					<div class="astrofs2_clima_factors">
						<span class="astrofs2_clima_factor {if $clima_objetivo.factor_ataque > 1}positive{elseif $clima_objetivo.factor_ataque < 1}negative{else}neutral{/if}">
							⚔️ {if $clima_objetivo.factor_ataque > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_objetivo.factor_ataque format="%d"}%
						</span>
						<span class="astrofs2_clima_factor {if $clima_objetivo.factor_defensa > 1}positive{elseif $clima_objetivo.factor_defensa < 1}negative{else}neutral{/if}">
							🛡️ {if $clima_objetivo.factor_defensa > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_objetivo.factor_defensa format="%d"}%
						</span>
						<span class="astrofs2_clima_factor {if $clima_objetivo.factor_bajas > 1}negative{elseif $clima_objetivo.factor_bajas < 1}positive{else}neutral{/if}">
							💀 {if $clima_objetivo.factor_bajas > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_objetivo.factor_bajas format="%d"}%
						</span>
						<span class="astrofs2_clima_factor {if $clima_objetivo.factor_botin > 1}positive{elseif $clima_objetivo.factor_botin < 1}negative{else}neutral{/if}">
							💰 {if $clima_objetivo.factor_botin > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_objetivo.factor_botin format="%d"}%
						</span>
					</div>
				</div>
			</div>

			{* ─── Predicción para mañana ─── *}
			{if isset($clima_previsto) && $clima_previsto}
			<div class="astrofs2_clima_predict">
				{assign var="cp_emoji" value="❓"}
				{if $clima_previsto.clave == 'despejado'}{assign var="cp_emoji" value="☀️"}
				{elseif $clima_previsto.clave == 'brisa_solar'}{assign var="cp_emoji" value="🌤️"}
				{elseif $clima_previsto.clave == 'viento_estelar'}{assign var="cp_emoji" value="🍃"}
				{elseif $clima_previsto.clave == 'cristalino'}{assign var="cp_emoji" value="✨"}
				{elseif $clima_previsto.clave == 'niebla'}{assign var="cp_emoji" value="🌫️"}
				{elseif $clima_previsto.clave == 'tormenta_solar'}{assign var="cp_emoji" value="⚡"}
				{elseif $clima_previsto.clave == 'meteoros'}{assign var="cp_emoji" value="☄️"}
				{elseif $clima_previsto.clave == 'nebulosa'}{assign var="cp_emoji" value="💰"}
				{elseif $clima_previsto.clave == 'plasma'}{assign var="cp_emoji" value="🌌"}
				{elseif $clima_previsto.clave == 'eclipse'}{assign var="cp_emoji" value="🌓"}
				{elseif $clima_previsto.clave == 'campo_mag'}{assign var="cp_emoji" value="🌀"}
				{elseif $clima_previsto.clave == 'aurora'}{assign var="cp_emoji" value="🌈"}
				{elseif $clima_previsto.clave == 'agujero'}{assign var="cp_emoji" value="🕳️"}
				{elseif $clima_previsto.clave == 'singularidad'}{assign var="cp_emoji" value="⚫"}
				{/if}
				<span class="pred-emoji">{$cp_emoji}</span>
				<span><b>🔮 Mañana:</b> {$clima_previsto.nombre}</span>
			</div>
			{/if}

			{* ─── Avisos tácticos ─── *}
			{if $clima_objetivo.factor_ataque < 1}
			<div class="astrofs2_clima_alert danger">
				⚠️ Tu ataque está debilitado hoy. Considera esperar a mañana.
			</div>
			{elseif $clima_objetivo.factor_defensa < 1}
			<div class="astrofs2_clima_alert success">
				✅ Las defensas enemigas están debilitadas. Buen momento para atacar.
			</div>
			{elseif $clima_objetivo.factor_botin > 1}
			<div class="astrofs2_clima_alert success">
				💰 El botín está aumentado. Buen momento para saquear.
			</div>
			{/if}
		</div>
		{/if}

		{* 🆕 ASTROIO v3.2 - BUFF CLIMÁTICO ACTIVO DEL ATACANTE *}
		{if isset($buff_activo) && $buff_activo}
		<div class="astrofs2_buff_box">
			<div class="astrofs2_buff_info">
				<div class="astrofs2_buff_icon">
					{if $buff_activo.buff_type == 'estabilizador_menor'}🌤️
					{elseif $buff_activo.buff_type == 'estabilizador_mayor'}🌈
					{elseif $buff_activo.buff_type == 'dominio'}⚡
					{else}✨{/if}
				</div>
				<div class="astrofs2_buff_texts">
					<div class="astrofs2_buff_title">⚡ Buff Climático Activo</div>
					<div class="astrofs2_buff_name">
						{if $buff_activo.buff_type == 'estabilizador_menor'}Estabilizador Menor
						{elseif $buff_activo.buff_type == 'estabilizador_mayor'}Estabilizador Mayor
						{elseif $buff_activo.buff_type == 'dominio'}Dominio Climático
						{else}{$buff_activo.buff_type}{/if}
					</div>
				</div>
			</div>
			<div class="astrofs2_buff_timer">
				<div class="astrofs2_buff_timer_lbl">Se aplicará al combate ·</div>
				<div class="astrofs2_buff_timer_val" id="fs2_buff_timer" data-expires="{$buff_activo.expires_at}">
					--
				</div>
			</div>
		</div>
		{/if}

		<form action="game.php?page=fleetStep3" method="post">
			<input type="hidden" name="token" value="{$token}">

			{* ============ GRID 2 COLUMNAS ============ *}
			<div class="astrofs2_grid">

				{* ---- COLUMNA IZQUIERDA: MISIÓN ---- *}
				<div class="astrofs2_box">
					<span class="astrofs2_box_title">🛰 {$LNG.fl_mission}</span>

					<div class="astrofs2_mission_list">
						{foreach $MissionSelector as $MissionID}
						<div class="astrofs2_mission_item">
							<input id="radio_{$MissionID}" type="radio" name="mission" value="{$MissionID}" {if $mission == $MissionID}checked="checked"{/if}>
							<label for="radio_{$MissionID}">{$LNG["type_mission_{$MissionID}"]}</label>
						</div>
						{if $MissionID == 15}
						<div class="astrofs2_mission_warn">⚠ {$LNG.fl_expedition_alert_message}</div>
						{/if}
						{if $MissionID == 11}
						<div class="astrofs2_mission_warn">⚠ {$fl_dm_alert_message}</div>
						{/if}
						{/foreach}
					</div>
				</div>

				{* ---- COLUMNA DERECHA: RECURSOS ---- *}
				<div class="astrofs2_box">
					<span class="astrofs2_box_title">📦 {$LNG.fl_resources}</span>

					{* Metal *}
					<div class="astrofs2_resource_row">
						<span class="astrofs2_resource_label">{$LNG.tech.901}</span>
						<a href="javascript:maxResource('metal');" class="astrofs2_max_btn">{$LNG.fl_max}</a>
						<input name="metal" id="metal" size="10" onchange="calculateTransportCapacity();" type="text" class="astrofs2_input">
					</div>

					{* Cristal *}
					<div class="astrofs2_resource_row">
						<span class="astrofs2_resource_label">{$LNG.tech.902}</span>
						<a href="javascript:maxResource('crystal');" class="astrofs2_max_btn">{$LNG.fl_max}</a>
						<input name="crystal" id="crystal" size="10" onchange="calculateTransportCapacity();" type="text" class="astrofs2_input">
					</div>

					{* Deuterio *}
					<div class="astrofs2_resource_row">
						<span class="astrofs2_resource_label">{$LNG.tech.903}</span>
						<a href="javascript:maxResource('deuterium');" class="astrofs2_max_btn">{$LNG.fl_max}</a>
						<input name="deuterium" id="deuterium" size="10" onchange="calculateTransportCapacity();" type="text" class="astrofs2_input">
					</div>

					{* Recursos restantes *}
					<div class="astrofs2_info_row">
						<span>{$LNG.fl_resources_left}</span>
						<span class="astrofs2_val" id="remainingresources">-</span>
					</div>

					{* Consumo de combustible *}
					<div class="astrofs2_info_row">
						<span>{$LNG.fl_fuel_consumption}</span>
						<span class="astrofs2_val consumption" id="consumption">{$consumption}</span>
					</div>

					{* Botón "todos los recursos" *}
					<div style="text-align: center; margin-top: 6px;">
						<a href="javascript:maxResources()" class="astrofs2_allres_btn">{$LNG.fl_all_resources}</a>
					</div>
				</div>

			</div>

			{* ============ SELECTOR TIEMPO DE ESPERA (si aplica) ============ *}
			{if $StaySelector}
			<div class="astrofs2_stay_box">
				<span class="astrofs2_box_title">⏱ {$LNG.fl_hold_time}</span>
				{html_options name=staytime options=$StaySelector class="astrofs2_select"}
				<span style="color:#8899aa;font-size:10.5px;margin-left:6px;">{$LNG.fl_hours}</span>
			</div>
			{/if}

			{* ============ BOTÓN CONTINUAR ============ *}
			<div class="astrofs2_submit_row">
				<input value="{$LNG.fl_continue}" type="submit" class="astrofs2_submit">
			</div>

		</form>

	</div>

</div>

<script type="text/javascript">
data	= {$fleetdata|json};
</script>

{* 🆕 ASTROIO v3.2 — Timer del buff climático activo *}
<script type="text/javascript">
(function() {
    var timerEl = document.getElementById('fs2_buff_timer');
    if (!timerEl) return;
    var expiresAt = parseInt(timerEl.getAttribute('data-expires'), 10);
    if (isNaN(expiresAt) || expiresAt <= 0) return;

    function updateBuffTimer() {
        var now = Math.floor(Date.now() / 1000);
        var diff = expiresAt - now;
        if (diff <= 0) {
            timerEl.textContent = '❌ Expirado';
            timerEl.style.color = '#ef4444';
            return;
        }
        var h = Math.floor(diff / 3600);
        var m = Math.floor((diff % 3600) / 60);
        var s = diff % 60;
        timerEl.textContent = (h < 10 ? '0' : '') + h + 'h ' +
                              (m < 10 ? '0' : '') + m + 'm ' +
                              (s < 10 ? '0' : '') + s + 's';
    }
    updateBuffTimer();
    setInterval(updateBuffTimer, 1000);
})();
</script>

{/block}