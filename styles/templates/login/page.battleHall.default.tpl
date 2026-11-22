{block name="title" prepend}{$LNG.siteTitleBattleHall}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BATTLE HALL (site) v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrotkbs_   (aislado, no rompe otros módulos)
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Centrado con text-align + inline-block (Regla #14)
     - Selector multi-universo con radius 8px + focus translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: {if $isMultiUniverse}, {html_options}, {if $hallRow.result} intactos
     - ⚠️ CRÍTICO: clases winner/loser/vs, {foreach $hallList} intactas
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

/* ====== Wrapper (centrado por text-align) ====== */
.astrotkbs_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
    text-align: center;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrotkbs_panel {
    display: inline-block;
    text-align: left;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 18px 22px;
    color: var(--text-main);
    width: 900px;
    max-width: 100%;
    vertical-align: top;
    box-sizing: border-box;
}

/* ====== Título (acento dorado) ====== */
.astrotkbs_section_title {
    color: #ffaa33;
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(255, 170, 51, 0.25);
    padding-bottom: 8px;
    margin-bottom: 14px;
    display: block;
    text-shadow: 0 0 10px rgba(255, 170, 51, 0.35);
}

/* ====== Selector de universo (multi) ====== */
.astrotkbs_uni_row {
    margin-bottom: 12px;
}
.astrotkbs_uni_row select {
    padding: 7px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    transition: 0.25s ease;
    min-width: 180px;
}
.astrotkbs_uni_row select:hover,
.astrotkbs_uni_row select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrotkbs_uni_row select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}

/* ====== Tabla ====== */
.astrotkbs_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrotkbs_table_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotkbs_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 11px;
}

/* Cabecera */
.astrotkbs_table thead tr {
    background: linear-gradient(135deg, #004488, #0077cc);
}
.astrotkbs_table thead th {
    padding: 7px 8px;
    font-weight: 700;
    font-size: 10.5px;
    letter-spacing: 0.3px;
    text-align: left;
    color: #ffffff;
    border-bottom: 1px solid #00ccff;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}
.astrotkbs_table thead th.astrotkbs_th_pos {
    width: 60px;
    text-align: center;
}
.astrotkbs_table thead th.astrotkbs_th_date {
    width: 150px;
}
.astrotkbs_table thead th.astrotkbs_th_units {
    width: 110px;
    text-align: right;
}

/* Filas */
.astrotkbs_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrotkbs_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrotkbs_table tbody td {
    padding: 6px 8px;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.3;
    word-break: break-word;
}

/* Columna posición */
.astrotkbs_table tbody td:first-child {
    text-align: center;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: var(--text-muted);
}

/* Columna unidades */
.astrotkbs_table tbody td:last-child {
    text-align: right;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #66ff99;
}

/* Colores ganador/perdedor */
.astrotkbs_winner { color: #66ff99 !important; font-weight: 700; }
.astrotkbs_loser { color: #ff4488 !important; font-weight: 700; }
.astrotkbs_vs { color: var(--text-main); font-weight: 700; padding: 0 6px; }

/* ====== Leyenda inferior ====== */
.astrotkbs_legend {
    text-align: center;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    margin-top: 12px;
    color: var(--text-muted);
    font-size: 10.5px;
    font-weight: 600;
    transition: 0.2s ease;
}
.astrotkbs_legend:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotkbs_legend span {
    font-weight: 700;
    margin: 0 4px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrotkbs_wrap { padding: 10px; }
    .astrotkbs_panel { padding: 14px 16px; }
    .astrotkbs_table { font-size: 10.5px; table-layout: auto; }
    .astrotkbs_table thead th { padding: 5px 5px; font-size: 10px; }
    .astrotkbs_table tbody td { padding: 4px 5px; }
}
</style>

<div class="astrotkbs_wrap">

	<div class="astrotkbs_panel">

		<span class="astrotkbs_section_title">🏆 {$LNG.siteTitleBattleHall}</span>

		{* ============ SELECTOR DE UNIVERSO (si multi-universo) ============ *}
		{if $isMultiUniverse}
		<div class="astrotkbs_uni_row">
			{html_options options=$universeSelect selected=$UNI class="form-control changeUni" id="universe" name="universe"}
		</div>
		{/if}

		{* ============ TABLA DE SALÓN DE LA FAMA ============ *}
		<div class="astrotkbs_table_wrap">
		<table class="astrotkbs_table">
			<thead>
				<tr>
					<th class="astrotkbs_th_pos">{$LNG.tkb_platz}</th>
					<th>{$LNG.tkb_owners}</th>
					<th class="astrotkbs_th_date">{$LNG.tkb_datum}</th>
					<th class="astrotkbs_th_units">{$LNG.tkb_units}</th>
				</tr>
			</thead>
			<tbody>
				{foreach $hallList as $hallRow}
				<tr>
					<td>{$hallRow@iteration}</td>
					<td>
						{if $hallRow.result == "a"}
						<span class="astrotkbs_winner">{$hallRow.attacker}</span><span class="astrotkbs_vs">VS</span><span class="astrotkbs_loser">{$hallRow.defender}</span>
						{elseif $hallRow.result == "r"}
						<span class="astrotkbs_loser">{$hallRow.attacker}</span><span class="astrotkbs_vs">VS</span><span class="astrotkbs_winner">{$hallRow.defender}</span>
						{else}
						{$hallRow.attacker}<span class="astrotkbs_vs">VS</span>{$hallRow.defender}
						{/if}
					</td>
					<td>{$hallRow.time}</td>
					<td>{$hallRow.units|number}</td>
				</tr>
				{/foreach}
			</tbody>
		</table>
		</div>

		{* ============ LEYENDA ============ *}
		<div class="astrotkbs_legend">
			{$LNG.tkb_legende}
			<span class="astrotkbs_winner">{$LNG.tkb_gewinner}</span>
			<span class="astrotkbs_loser">{$LNG.tkb_verlierer}</span>
		</div>

	</div>

</div>

{/block}