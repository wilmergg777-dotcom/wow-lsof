{block name="title" prepend}{$LNG.siteTitleBanList}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BAN LIST (site) v3.1 — Estilo Xnova (glassmorphism)
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
    --accent-cyan:   #00e0ff;
    --accent-red:    #ef4444;
}

/* ====== Wrapper ====== */
.astrobans_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
    text-align: center;
}

/* ====== Panel principal ====== */
.astrobans_panel {
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

/* ====== Título ====== */
.astrobans_section_title {
    color: #ff4488;
    font-weight: 700;
    font-size: 15px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(255, 94, 0, 0.4) !important; /* Línea naranja */
    padding-bottom: 10px;
    margin-bottom: 20px;
    display: block;
    text-shadow: 0 0 10px rgba(239, 68, 68, 0.4);
}

/* ====== Selector de universo ====== */
.astrobans_uni_row {
    margin-bottom: 15px;
}
.astrobans_uni_row select {
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
.astrobans_uni_row select:hover,
.astrobans_uni_row select:focus {
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
}
.astrobans_uni_row select option {
    background: #0f1624 !important;
    color: #ffffff !important;
    padding: 4px;
}

/* ====== Tabla ====== */
.astrobans_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    background: rgba(0, 0, 0, 0.5) !important;
    transition: 0.2s ease;
}
.astrobans_table_wrap:hover {
    border-color: var(--border-color) !important;
}
.astrobans_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 13px;
}

/* Cabecera */
.astrobans_table thead tr {
    background: rgba(0, 0, 0, 0.6) !important;
}
.astrobans_table thead th {
    padding: 12px 10px;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.5px;
    text-align: center;
    color: #00e0ff !important;
    border-bottom: 1px solid var(--border-color) !important;
    white-space: nowrap;
}

/* Filas */
.astrobans_table tbody tr {
    background: transparent !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05) !important;
    transition: 0.15s ease;
}
.astrobans_table tbody tr:hover {
    background: rgba(255, 94, 0, 0.05) !important; /* Hover naranja tenue */
}
.astrobans_table tbody td {
    padding: 10px;
    color: var(--text-main) !important;
    vertical-align: middle;
    text-align: center;
    line-height: 1.4;
    word-break: break-word;
}
.astrobans_table tbody td:nth-child(4) {
    color: #00e0ff !important;
    font-weight: 700;
}
.astrobans_table tbody td:nth-child(5) {
    color: #ffaa33 !important;
    font-style: italic;
    text-align: left;
}

/* Enlaces */
.astrobans_table a {
    color: #00e0ff !important;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrobans_table a:hover {
    color: #ffffff !important;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Fila de contador */
.astrobans_count {
    background: rgba(239, 68, 68, 0.1) !important;
    color: #ff4488 !important;
    font-weight: 700;
    text-align: center !important;
    padding: 12px !important;
    font-size: 12px;
    letter-spacing: 0.3px;
}
.astrobans_empty {
    color: var(--text-muted) !important;
    font-style: italic;
    text-align: center !important;
    padding: 20px !important;
    font-size: 13px;
}

/* ====== Paginación ====== */
.astrobans_pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 4px;
    padding: 12px;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-radius: 10px;
    margin-top: 20px;
    flex-wrap: wrap;
    font-size: 12px;
    color: var(--text-muted) !important;
    font-weight: 600;
    transition: 0.2s ease;
}
.astrobans_pagination a {
    color: #00e0ff !important;
    text-decoration: none;
    padding: 6px 12px;
    border-radius: 6px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    transition: 0.25s ease;
    border: 1px solid rgba(0, 204, 255, 0.2) !important;
}
.astrobans_pagination a:hover {
    background: rgba(255, 94, 0, 0.15) !important;
    border-color: var(--border-color) !important;
    color: #ffffff !important;
    transform: translateY(-2px);
}
.astrobans_pagination a:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 768px) {
    .astrobans_wrap { padding: 10px; }
    .astrobans_panel { padding: 20px 15px; }
    .astrobans_table { font-size: 11.5px; table-layout: auto; }
    .astrobans_table thead th { padding: 8px 5px; font-size: 11px; }
    .astrobans_table tbody td { padding: 8px 5px; }
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
					<a href="#" onclick="false;" style="background:#222c3c;border-color:#ff5e00;color:#fff;box-shadow:0 0 10px rgba(255,94,0,0.4);">{$site}</a>
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