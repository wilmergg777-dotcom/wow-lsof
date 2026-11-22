{block name="title" prepend}{$LNG.lm_resources}{/block}
{block name="content"}

{* ============================================================
   ASTROIO RESOURCES v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrores_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-paneles 10px)
     - Tabla con borde cyan sutil + hover
     - Selects y botón calcular con radius 8px + glow
     - Wrapper padding 15px
     - Todos los IDs, names, class y Smarty intactos
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
.astrores_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrores_panel {
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

/* ====== Título de sección ====== */
.astrores_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
}

/* ====== Tabla ====== */
.astrores_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrores_table_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrores_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* Cabecera */
.astrores_table thead tr {
    background: linear-gradient(135deg, #004488, #0077cc);
}
.astrores_table thead th {
    padding: 4px 4px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: center;
    color: #ffffff;
    border-bottom: 1px solid #00ccff;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astrores_table thead th:first-child {
    text-align: left;
    padding-left: 8px;
}

/* Filas */
.astrores_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrores_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrores_table tbody td {
    padding: 3px 4px;
    text-align: center;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.2;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astrores_table tbody td:first-child {
    text-align: left;
    padding-left: 8px;
    color: var(--text-muted);
    font-weight: 600;
    font-size: 10px;
}

/* Anchos fijos por columna */
.astrores_table th:nth-child(1), .astrores_table td:nth-child(1) { width: 150px; }
.astrores_table th:nth-child(2), .astrores_table td:nth-child(2) { width: 80px;  }
.astrores_table th:nth-child(3), .astrores_table td:nth-child(3) { width: 80px;  }
.astrores_table th:nth-child(4), .astrores_table td:nth-child(4) { width: 80px;  }
.astrores_table th:nth-child(5), .astrores_table td:nth-child(5) { width: 80px;  }
.astrores_table th:nth-child(6), .astrores_table td:nth-child(6) { width: 60px;  }

/* ====== Valores con colores ====== */
.astrores_val_pos { color: #66ff99 !important; font-family: 'Courier New', monospace; font-weight: 700; }
.astrores_val_neg { color: #ff4488 !important; font-family: 'Courier New', monospace; font-weight: 700; }
.astrores_val_neu { color: #cbd5e1 !important; font-family: 'Courier New', monospace; font-weight: 700; }

/* ====== Filas especiales ====== */
.astrores_table tbody tr.astrores_row_basic td {
    background: rgba(0, 204, 255, 0.05);
    color: #00e0ff;
    font-weight: 700;
}
.astrores_table tbody tr.astrores_row_basic td:first-child { color: #00e0ff; }
.astrores_table tbody tr.astrores_row_basic td:not(:first-child) {
    color: #00e0ff;
    font-family: 'Courier New', monospace;
}

.astrores_table tbody tr.astrores_row_bonus {
    background: rgba(255, 170, 51, 0.06);
}
.astrores_table tbody tr.astrores_row_bonus td:first-child { color: #ffaa33; }

.astrores_table tbody tr.astrores_row_storage {
    background: rgba(102, 255, 153, 0.05);
}
.astrores_table tbody tr.astrores_row_storage td:first-child { color: #66ff99; }
.astrores_table tbody tr.astrores_row_storage td span {
    color: #66ff99 !important;
    font-family: 'Courier New', monospace;
    font-weight: 700;
}

.astrores_table tbody tr.astrores_row_sum {
    background: rgba(0, 204, 255, 0.08);
    border-top: 1px solid rgba(0, 204, 255, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
}
.astrores_table tbody tr.astrores_row_sum td:first-child {
    color: #00e0ff;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}

.astrores_table tbody tr.astrores_row_daily td:first-child { color: #aa44ff; }
.astrores_table tbody tr.astrores_row_weekly td:first-child { color: #cc66ff; }

/* ====== Select del nivel ====== */
.astrores_select {
    padding: 3px 5px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 6px;
    color: #ffffff;
    font-weight: 700;
    font-size: 10px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    transition: 0.25s ease;
    width: 100%;
    max-width: 55px;
}
.astrores_select:hover,
.astrores_select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrores_select option {
    background: #0f1624;
    color: #ffffff;
}

/* ====== Botón calcular ====== */
.astrores_calc_btn {
    display: inline-block;
    padding: 4px 12px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
    border-radius: 6px;
    color: #ffffff;
    font-weight: 700;
    font-size: 10px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.3px;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
    white-space: nowrap;
}
.astrores_calc_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}
.astrores_calc_btn:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrores_wrap { padding: 10px; }
    .astrores_panel { padding: 12px; max-width: 100%; }
    .astrores_table { font-size: 10px; table-layout: auto; }
    .astrores_table thead th { padding: 3px 3px; font-size: 9.5px; }
    .astrores_table tbody td { padding: 2px 3px; }
    .astrores_calc_btn { padding: 3px 8px; font-size: 9.5px; }
}
</style>

<div class="astrores_wrap">

	<div class="astrores_panel">

		<span class="astrores_section_title">📊 {$header}</span>

		<form action="?page=resources" method="post">
			<input type="hidden" name="mode" value="send">

			<div class="astrores_table_wrap">
			<table class="astrores_table">
				<thead>
					<tr>
						<th>&nbsp;</th>
						<th>{$LNG.tech.901}</th>
						<th>{$LNG.tech.902}</th>
						<th>{$LNG.tech.903}</th>
						<th>{$LNG.tech.911}</th>
						<th>&nbsp;</th>
					</tr>
				</thead>
				<tbody>

					{* ============ PRODUCCIÓN BASE ============ *}
					<tr class="astrores_row_basic">
						<td>{$LNG.rs_basic_income}</td>
						<td>{$basicProduction.901|number}</td>
						<td>{$basicProduction.902|number}</td>
						<td>{$basicProduction.903|number}</td>
						<td>{$basicProduction.911|number}</td>
						<td>&nbsp;</td>
					</tr>

					{* ============ LISTA DE PRODUCCIÓN ============ *}
					{foreach $productionList as $productionID => $productionRow}
					<tr>
						<td>
							{$LNG.tech.$productionID}
							({if $productionID > 200}{$LNG.rs_amount}{else}{$LNG.rs_lvl}{/if} {$productionRow.elementLevel})
						</td>
						<td>
							<span class="{if $productionRow.production.901 > 0}astrores_val_pos{elseif $productionRow.production.901 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$productionRow.production.901|number}
							</span>
						</td>
						<td>
							<span class="{if $productionRow.production.902 > 0}astrores_val_pos{elseif $productionRow.production.902 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$productionRow.production.902|number}
							</span>
						</td>
						<td>
							<span class="{if $productionRow.production.903 > 0}astrores_val_pos{elseif $productionRow.production.903 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$productionRow.production.903|number}
							</span>
						</td>
						<td>
							<span class="{if $productionRow.production.911 > 0}astrores_val_pos{elseif $productionRow.production.911 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$productionRow.production.911|number}
							</span>
						</td>
						<td>
							{html_options name="prod[`$productionID`]" options=$prodSelector selected=$productionRow.prodLevel class="astrores_select"}
						</td>
					</tr>
					{/foreach}

					{* ============ BONUS ============ *}
					<tr class="astrores_row_bonus">
						<td>{$LNG.rs_ress_bonus}</td>
						<td>
							<span class="{if $bonusProduction.901 > 0}astrores_val_pos{elseif $bonusProduction.901 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$bonusProduction.901|number}
							</span>
						</td>
						<td>
							<span class="{if $bonusProduction.902 > 0}astrores_val_pos{elseif $bonusProduction.902 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$bonusProduction.902|number}
							</span>
						</td>
						<td>
							<span class="{if $bonusProduction.903 > 0}astrores_val_pos{elseif $bonusProduction.903 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$bonusProduction.903|number}
							</span>
						</td>
						<td>
							<span class="{if $bonusProduction.911 > 0}astrores_val_pos{elseif $bonusProduction.911 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$bonusProduction.911|number}
							</span>
						</td>
						<td>
							<input value="{$LNG.rs_calculate}" type="submit" class="astrores_calc_btn">
						</td>
					</tr>

					{* ============ CAPACIDAD DE ALMACENES ============ *}
					<tr class="astrores_row_storage">
						<td>{$LNG.rs_storage_capacity}</td>
						<td><span>{$storage.901}</span></td>
						<td><span>{$storage.902}</span></td>
						<td><span>{$storage.903}</span></td>
						<td>-</td>
						<td>&nbsp;</td>
					</tr>

					{* ============ TOTAL ============ *}
					<tr class="astrores_row_sum">
						<td>{$LNG.rs_sum}:</td>
						<td>
							<span class="{if $totalProduction.901 > 0}astrores_val_pos{elseif $totalProduction.901 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$totalProduction.901|number}
							</span>
						</td>
						<td>
							<span class="{if $totalProduction.902 > 0}astrores_val_pos{elseif $totalProduction.902 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$totalProduction.902|number}
							</span>
						</td>
						<td>
							<span class="{if $totalProduction.903 > 0}astrores_val_pos{elseif $totalProduction.903 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$totalProduction.903|number}
							</span>
						</td>
						<td>
							<span class="{if $totalProduction.911 > 0}astrores_val_pos{elseif $totalProduction.911 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$totalProduction.911|number}
							</span>
						</td>
						<td>&nbsp;</td>
					</tr>

					{* ============ PRODUCCIÓN DIARIA ============ *}
					<tr class="astrores_row_daily">
						<td>{$LNG.rs_daily}</td>
						<td>
							<span class="{if $dailyProduction.901 > 0}astrores_val_pos{elseif $dailyProduction.901 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$dailyProduction.901|number}
							</span>
						</td>
						<td>
							<span class="{if $dailyProduction.902 > 0}astrores_val_pos{elseif $dailyProduction.902 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$dailyProduction.902|number}
							</span>
						</td>
						<td>
							<span class="{if $dailyProduction.903 > 0}astrores_val_pos{elseif $dailyProduction.903 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$dailyProduction.903|number}
							</span>
						</td>
						<td>
							<span class="{if $dailyProduction.911 > 0}astrores_val_pos{elseif $dailyProduction.911 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$dailyProduction.911|number}
							</span>
						</td>
						<td>&nbsp;</td>
					</tr>

					{* ============ PRODUCCIÓN SEMANAL ============ *}
					<tr class="astrores_row_weekly">
						<td>{$LNG.rs_weekly}</td>
						<td>
							<span class="{if $weeklyProduction.901 > 0}astrores_val_pos{elseif $weeklyProduction.901 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$weeklyProduction.901|number}
							</span>
						</td>
						<td>
							<span class="{if $weeklyProduction.902 > 0}astrores_val_pos{elseif $weeklyProduction.902 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$weeklyProduction.902|number}
							</span>
						</td>
						<td>
							<span class="{if $weeklyProduction.903 > 0}astrores_val_pos{elseif $weeklyProduction.903 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$weeklyProduction.903|number}
							</span>
						</td>
						<td>
							<span class="{if $weeklyProduction.911 > 0}astrores_val_pos{elseif $weeklyProduction.911 < 0}astrores_val_neg{else}astrores_val_neu{/if}">
								{$weeklyProduction.911|number}
							</span>
						</td>
						<td>&nbsp;</td>
					</tr>

				</tbody>
			</table>
			</div>

		</form>

	</div>

</div>

{/block}