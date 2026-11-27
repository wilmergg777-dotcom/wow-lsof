{block name="title" prepend}{$LNG.lm_fleettrader}{/block}
{block name="content"}

{* ============================================================
   ASTROIO FLEET DEALER v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astroft_
   FIX v3.0:
     - Fondo semi-transparente con backdrop-filter
     - Bordes redondeados 12px
     - Hover con glow dorado
     - Todos los IDs y JS intactos
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
.astroft_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Contenedor principal ====== */
.astroft_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 720px;
    margin: 0 auto;
}

/* ====== Cabecera con imagen + selector ====== */
.astroft_header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(255, 170, 51, 0.2);
    margin-bottom: 15px;
    flex-wrap: wrap;
}

.astroft_img_box {
    width: 90px;
    height: 90px;
    border-radius: 10px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 170, 51, 0.4);
    box-shadow: 0 0 15px rgba(255, 170, 51, 0.15) inset;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    flex-shrink: 0;
}
.astroft_img_box img {
    max-width: 100%;
    max-height: 100%;
    display: block;
    border-radius: 6px;
}

.astroft_select_box {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
    min-width: 220px;
}
.astroft_select_label {
    color: #ffaa33;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
}
.astroft_select {
    width: 100%;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 170, 51, 0.5);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 12px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    transition: 0.25s ease;
    appearance: none;
    background-image: linear-gradient(45deg, transparent 50%, #ffaa33 50%),
                      linear-gradient(135deg, #ffaa33 50%, transparent 50%);
    background-position: calc(100% - 16px) center, calc(100% - 11px) center;
    background-size: 5px 5px, 5px 5px;
    background-repeat: no-repeat;
    padding-right: 30px;
}
.astroft_select:hover,
.astroft_select:focus {
    border-color: #ffcc66;
    box-shadow: 0 0 12px rgba(255, 170, 51, 0.5);
    transform: translateY(-1px);
}
.astroft_select option {
    background: #0f1624;
    color: #ffffff;
    padding: 6px;
}

/* ====== Título del comerciante ====== */
.astroft_title {
    color: #ffaa33;
    font-weight: 800;
    font-size: 18px;
    text-align: center;
    letter-spacing: 1px;
    text-shadow: 0 2px 10px rgba(255, 170, 51, 0.5);
    padding: 4px 0 4px 0;
    margin: 0;
}
.astroft_subtitle {
    color: var(--text-muted);
    font-size: 11px;
    text-align: center;
    margin-bottom: 15px;
    letter-spacing: 0.3px;
    font-style: italic;
}

/* ====== Sección de campos ====== */
.astroft_section {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.astroft_section:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astroft_section_label {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    margin-bottom: 8px;
    display: block;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    padding-bottom: 6px;
}

/* Fila con input + botón max */
.astroft_input_row {
    display: flex;
    gap: 8px;
    align-items: stretch;
    max-width: 100%;
}
.astroft_input {
    flex-grow: 1;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 13px;
    outline: none;
    transition: 0.25s ease;
    text-align: center;
    min-width: 0;
}
.astroft_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astroft_max_btn {
    padding: 10px 18px;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 102, 204, 0.9));
    border: 1px solid rgba(0, 204, 255, 0.6);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    transition: 0.25s ease;
    white-space: nowrap;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    text-transform: uppercase;
}
.astroft_max_btn:hover {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 153, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 204, 255, 0.6);
    transform: translateY(-2px);
}
.astroft_max_btn:active {
    transform: translateY(0);
}

/* ====== Valores de recursos ====== */
.astroft_values {
    display: flex;
    flex-wrap: wrap;
    gap: 8px 12px;
    font-size: 12px;
    padding: 4px 0;
}
.astroft_values .astroft_val_item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-weight: 600;
    background: rgba(0, 0, 0, 0.3);
    padding: 5px 10px;
    border-radius: 6px;
    border: 1px solid rgba(255, 255, 255, 0.06);
    transition: 0.2s ease;
}
.astroft_values .astroft_val_item:hover {
    background: rgba(0, 0, 0, 0.5);
    border-color: rgba(0, 204, 255, 0.3);
}
.astroft_values .astroft_val_item span {
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
}

/* Colores por recurso */
.res_901_text { color: #c8d6e5 !important; }
.res_902_text { color: #88ddff !important; }
.res_903_text { color: #aaff88 !important; }
.res_921_text { color: #aa44ff !important; }

/* ====== Botón de envío principal ====== */
.astroft_submit_row {
    text-align: center;
    padding-top: 8px;
}
.astroft_submit {
    display: inline-block;
    padding: 12px 40px;
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(170, 68, 255, 0.9));
    border: 1px solid #cc66ff;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 12px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.8px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 4px 15px rgba(119, 0, 204, 0.5);
    text-transform: uppercase;
}
.astroft_submit:hover {
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.95), rgba(204, 102, 255, 0.95));
    box-shadow: 0 0 22px rgba(170, 68, 255, 0.7), 0 4px 15px rgba(119, 0, 204, 0.5);
    transform: translateY(-2px);
}
.astroft_submit:active {
    transform: translateY(0);
}

/* ====== Info de la tasa de cambio ====== */
.astroft_charge {
    text-align: center;
    padding: 10px 0 0 0;
    margin-top: 10px;
    border-top: 1px solid rgba(255, 170, 51, 0.2);
    color: #ffaa33;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.5px;
}
.astroft_charge b {
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-size: 14px;
    text-shadow: 0 0 10px rgba(255, 170, 51, 0.5);
}

/* ====== Título del trader (h2 original) ====== */
#traderHead {
    color: #ffaa33;
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 0.8px;
    margin: 0 0 8px 0;
    padding: 0;
    text-align: center;
    text-shadow: 0 1px 4px rgba(0, 0, 0, 0.6);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astroft_header { justify-content: center; text-align: center; }
    .astroft_img_box { margin: 0 auto; }
    .astroft_select_box { min-width: 100%; }
    .astroft_input_row { flex-direction: column; }
    .astroft_max_btn { width: 100%; }
    .astroft_submit { width: 100%; padding: 12px 20px; }
    .astroft_values { justify-content: center; }
    .astroft_panel { max-width: 100%; padding: 12px; }
}
</style>

<div class="astroft_wrap">

	<form action="game.php?page=fleetDealer" method="post">
		<input type="hidden" name="mode" value="send">

		<div class="astroft_panel">

			{* ===== Cabecera: imagen + selector de nave ===== *}
			<div class="astroft_header">

				<div class="astroft_img_box">
					<img id="img" alt="" data-src="{$dpath}gebaeude/" src="">
				</div>

				<div class="astroft_select_box">
					<label class="astroft_select_label" for="shipID">{$LNG.ft_head}</label>
					<select name="shipID" id="shipID" class="astroft_select" onchange="updateVars()">
						{foreach $shipIDs as $shipID}
						<option value="{$shipID}">{$LNG.tech.$shipID}</option>
						{/foreach}
					</select>
				</div>

			</div>

			{* ===== Título del comerciante ===== *}
			<h2 id="traderHead" class="astroft_title"></h2>
			<div class="astroft_subtitle">{$LNG.ft_head}</div>

			{* ===== Cantidad de naves a vender ===== *}
			<div class="astroft_section">
				<span class="astroft_section_label">{$LNG.ft_count}</span>
				<div class="astroft_input_row">
					<input type="text"
					       id="count"
					       name="count"
					       class="astroft_input"
					       onkeyup="Total();"
					       autocomplete="off">
					<button type="button"
					        class="astroft_max_btn"
					        onclick="MaxShips();return false;">
						{$LNG.ft_max}
					</button>
				</div>
			</div>

			{* ===== Valores unitarios por nave ===== *}
			<div class="astroft_section">
				<span class="astroft_section_label">{$LNG.ft_charge}</span>
				<div class="astroft_values">
					<div class="astroft_val_item">
						{$LNG.tech.901}: <span class="res_901_text" id="metal">0</span>
					</div>
					<div class="astroft_val_item">
						{$LNG.tech.902}: <span class="res_902_text" id="crystal">0</span>
					</div>
					<div class="astroft_val_item">
						{$LNG.tech.903}: <span class="res_903_text" id="deuterium">0</span>
					</div>
					<div class="astroft_val_item">
						{$LNG.tech.921}: <span class="res_921_text" id="darkmatter">0</span>
					</div>
				</div>
			</div>

			{* ===== Totales (cantidad × valor unitario) ===== *}
			<div class="astroft_section">
				<span class="astroft_section_label">{$LNG.ft_total}</span>
				<div class="astroft_values">
					<div class="astroft_val_item">
						{$LNG.tech.901}: <span class="res_901_text" id="total_metal">0</span>
					</div>
					<div class="astroft_val_item">
						{$LNG.tech.902}: <span class="res_902_text" id="total_crystal">0</span>
					</div>
					<div class="astroft_val_item">
						{$LNG.tech.903}: <span class="res_903_text" id="total_deuterium">0</span>
					</div>
					<div class="astroft_val_item">
						{$LNG.tech.921}: <span class="res_921_text" id="total_darkmatter">0</span>
					</div>
				</div>
			</div>

			{* ===== Botón de envío ===== *}
			<div class="astroft_submit_row">
				<input type="submit" class="astroft_submit" value="{$LNG.ft_absenden}">
			</div>

			{* ===== Tasa de cambio ===== *}
			<div class="astroft_charge">
				{$LNG.ft_charge}: <b>{$Charge}%</b>
			</div>

		</div>
	</form>

</div>

{/block}

{block name="script" append}
<script src="scripts/game/fleettrader.js"></script>
<script>
var CostInfo = {$CostInfos|json};
var Charge = {$Charge};
$(function(){
    updateVars();
});
</script>
{/block}