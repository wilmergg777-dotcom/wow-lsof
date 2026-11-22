{block name="title" prepend}{$LNG.siteTitleBanList}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BAN LIST (site) v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrobans_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔴 Rojo (#ef4444) — Sanciones/Peligro
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Centrado con text-align + inline-block (Regla #14)
     - Selector de universo con radius 8px + focus translateY
     - Paginación con radius 6px + hover translateY
     - ⚠️ CRÍTICO: {if $isMultiUniverse} + {html_options} + {if $banCount} intactos
     - ⚠️ CRÍTICO: {foreach $banList} + {for $site=1 to $maxPage} + hrefs intactos
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

/* ====== Wrapper (centrado por text-align — Regla #14) ====== */
.astrobans_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
    text-align: center;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrobans_panel {
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

/* ====== Título (acento rojo) ====== */
.astrobans_section_title {
    color: #ff4488;
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(239, 68, 68, 0.25);
    padding-bottom: 8px;
    margin-bottom: 14px;
    display: block;
    text-shadow: 0 0 10px rgba(239, 68, 68, 0.4);
}

/* ====== Selector de universo ====== */
.astrobans_uni_row {
    margin-bottom: 12px;
}
.astrobans_uni_row select {
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
.astrobans_uni_row select:hover,
.astrobans_uni_row select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrobans_uni_row select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}

/* ====== Tabla ====== */
.astrobans_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(239, 68, 68, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrobans_table_wrap:hover {
    border-color: rgba(239, 68, 68, 0.3);
}
.astrobans_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 11px;
}

/* Cabecera */
.astrobans_table thead tr {
    background: linear-gradient(135deg, rgba(120, 20, 40, 0.85), rgba(180, 30, 60, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astrobans_table thead th {
    padding: 7px 8px;
    font-weight: 700;
    font-size: 10.5px;
    letter-spacing: 0.3px;
    text-align: center;
    color: #ffffff;
    border-bottom: 1px solid var(--accent-red);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}

/* Filas */
.astrobans_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(239, 68, 68, 0.06);
    transition: 0.15s ease;
}
.astrobans_table tbody tr:hover {
    background: rgba(239, 68, 68, 0.07);
}
.astrobans_table tbody td {
    padding: 6px 8px;
    color: var(--text-main);
    vertical-align: middle;
    text-align: center;
    line-height: 1.3;
    word-break: break-word;
}
.astrobans_table tbody td:nth-child(4) {
    color: #00e0ff;
    font-weight: 700;
}
.astrobans_table tbody td:nth-child(5) {
    color: #ffaa33;
    font-style: italic;
    text-align: left;
}

/* Enlaces */
.astrobans_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrobans_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Fila de contador */
.astrobans_count {
    background: rgba(239, 68, 68, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #ff4488 !important;
    font-weight: 700;
    text-align: center !important;
    padding: 10px !important;
    font-size: 11px;
    letter-spacing: 0.3px;
    text-shadow: 0 0 6px rgba(239, 68, 68, 0.3);
}
.astrobans_empty {
    color: var(--text-muted) !important;
    font-style: italic;
    text-align: center !important;
    padding: 14px !important;
    font-size: 11px;
}

/* ====== Paginación ====== */
.astrobans_pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 4px;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.25);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(239, 68, 68, 0.15);
    border-radius: 10px;
    margin-top: 12px;
    flex-wrap: wrap;
    font-size: 11px;
    color: var(--text-muted);
    font-weight: 600;
    transition: 0.2s ease;
}
.astrobans_pagination:hover {
    border-color: rgba(239, 68, 68, 0.3);
}
.astrobans_pagination a {
    color: #00e0ff;
    text-decoration: none;
    padding: 4px 12px;
    border-radius: 6px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    transition: 0.25s ease;
    border: 1px solid rgba(0, 204, 255, 0.2);
}
.astrobans_pagination a:hover {
    background: rgba(239, 68, 68, 0.15);
    border-color: rgba(239, 68, 68, 0.5);
    color: #ffffff;
    text-shadow: 0 0 6px rgba(255, 68, 136, 0.9);
    transform: translateY(-2px);
}
.astrobans_pagination a:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrobans_wrap { padding: 10px; }
    .astrobans_panel { padding: 14px 16px; }
    .astrobans_table { font-size: 10.5px; table-layout: auto; }
    .astrobans_table thead th { padding: 5px 5px; font-size: 10px; }
    .astrobans_table tbody td { padding: 5px 5px; }
}
</style>

<div class="astrobans_wrap">

	<div class="astrobans_panel">

		<span class="astrobans_section_title">🚫 {$LNG.bn_players_banned_list}</span>

		{* ============ SELECTOR DE UNIVERSO ============ *}
		{if $isMultiUniverse}
		<div class="astrobans_uni_row">
			{html_options options=$universeSelect selected=$UNI class="form-control changeUni" id="universe" name="universe"}
		</div>
		{/if}

		{* ============ TABLA ============ *}
		<div class="astrobans_table_wrap">
		<table class="astrobans_table">
			<thead>
				<tr>
					<th>{$LNG.bn_from}</th>
					<th>{$LNG.bn_until}</th>
					<th>{$LNG.bn_player}</th>
					<th>{$LNG.bn_by}</th>
					<th>{$LNG.bn_reason}</th>
				</tr>
			</thead>
			<tbody>
				{if $banCount}
					{foreach $banList as $banRow}
					<tr>
						<td>{$banRow.from}</td>
						<td>{$banRow.to}</td>
						<td>{$banRow.player}</td>
						<td><a href="mailto:{$banRow.mail}" title="{$banRow.info}">{$banRow.admin}</a></td>
						<td>{$banRow.theme}</td>
					</tr>
					{/foreach}
					<tr>
						<td colspan="5" class="astrobans_count">{$LNG.bn_exists}{$banCount|number}{$LNG.bn_players_banned}</td>
					</tr>
				{else}
					<tr>
						<td colspan="5" class="astrobans_empty">— {$LNG.bn_no_players_banned} —</td>
					</tr>
				{/if}
			</tbody>
		</table>
		</div>

		{* ============ PAGINACIÓN ============ *}
		{if $banCount}
		<div class="astrobans_pagination">
			{if $page != 1}
				<a href="index.php?page=banList&amp;side={$page - 1}">◀ Prev</a>
			{/if}
			{for $site=1 to $maxPage}
				{if $site == $page}
					<a href="#" onclick="false;" style="background:linear-gradient(135deg,#0066cc,#0099ff);color:#fff;box-shadow:0 0 10px rgba(0,224,255,0.4);">{$site}</a>
				{else}
					<a href="index.php?page=banList&amp;side={$site}">{$site}</a>
				{/if}
			{/for}
			{if $page != $maxPage}
				<a href="index.php?page=banList&amp;side={$page + 1}">Next ▶</a>
			{/if}
		</div>
		{/if}

	</div>

</div>

{/block}