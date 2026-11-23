{block name="title" prepend}{$LNG.siteTitleBattleHall}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BATTLE HALL (site) v3.1 — Estilo Xnova (glassmorphism)
   ✅ FIX: Fondo oscuro, borde naranja y tabla adaptada.
   ============================================================ *}

<style>
/* ====== Variables globales ====== */
:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(10, 15, 25, 0.9); /* Fondo oscuro igual al index */
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #ff5e00; /* Borde naranja */
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-blue:   #3b82f6;
    --accent-cyan:   #00e0ff;
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
    background: var(--bg-card) !important;
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    border: 1px solid var(--border-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9) !important;
    padding: 25px 35px;
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
    font-size: 15px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(255, 94, 0, 0.4) !important; /* Línea naranja */
    padding-bottom: 10px;
    margin-bottom: 20px;
    display: block;
    text-shadow: 0 0 10px rgba(255, 170, 51, 0.35);
}

/* ====== Selector de universo (multi) ====== */
.astrotkbs_uni_row {
    margin-bottom: 15px;
}
.astrotkbs_uni_row select {
    padding: 10px 14px;
    background: #ffffff !important;
    border: 1px solid rgba(255, 255, 255, 0.2) !important;
    border-radius: 6px;
    color: #333333 !important;
    font-weight: 700;
    font-size: 13px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    transition: 0.25s ease;
    min-width: 200px;
}
.astrotkbs_uni_row select:hover,
.astrotkbs_uni_row select:focus {
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
}
.astrotkbs_uni_row select option {
    background: #0f1624 !important;
    color: #ffffff !important;
    padding: 4px;
}

/* ====== Tabla ====== */
.astrotkbs_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    background: rgba(0, 0, 0, 0.5) !important;
    transition: 0.2s ease;
}
.astrotkbs_table_wrap:hover {
    border-color: var(--border-color) !important;
}
.astrotkbs_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 13px;
}

/* Cabecera */
.astrotkbs_table thead tr {
    background: rgba(0, 0, 0, 0.6) !important;
}
.astrotkbs_table thead th {
    padding: 12px 10px;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.5px;
    text-align: left;
    color: #00e0ff !important;
    border-bottom: 1px solid var(--border-color) !important;
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
    background: transparent !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05) !important;
    transition: 0.15s ease;
}
.astrotkbs_table tbody tr:hover {
    background: rgba(255, 94, 0, 0.05) !important; /* Hover naranja tenue */
}
.astrotkbs_table tbody td {
    padding: 10px;
    color: var(--text-main) !important;
    vertical-align: middle;
    line-height: 1.4;
    word-break: break-word;
}

/* Columna posición */
.astrotkbs_table tbody td:first-child {
    text-align: center;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: var(--text-muted) !important;
}

/* Columna unidades */
.astrotkbs_table tbody td:last-child {
    text-align: right;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #4aff88 !important;
}

/* Colores ganador/perdedor */
.astrotkbs_winner { color: #66ff99 !important; font-weight: 700; }
.astrotkbs_loser { color: #ff4488 !important; font-weight: 700; }
.astrotkbs_vs { color: var(--text-muted) !important; font-weight: 700; padding: 0 8px; font-size: 11px; }

/* ====== Leyenda inferior ====== */
.astrotkbs_legend {
    text-align: center;
    padding: 12px;
    background: rgba(0, 0, 0, 0.5) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-radius: 10px;
    margin-top: 20px;
    color: var(--text-muted) !important;
    font-size: 12px;
    font-weight: 600;
    transition: 0.2s ease;
}
.astrotkbs_legend span {
    font-weight: 700;
    margin: 0 4px;
}

/* ====== Responsive ====== */
@media (max-width: 768px) {
    .astrotkbs_wrap { padding: 10px; }
    .astrotkbs_panel { padding: 20px 15px; }
    .astrotkbs_table { font-size: 11.5px; table-layout: auto; }
    .astrotkbs_table thead th { padding: 8px 5px; font-size: 11px; }
    .astrotkbs_table tbody td { padding: 8px 5px; }
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