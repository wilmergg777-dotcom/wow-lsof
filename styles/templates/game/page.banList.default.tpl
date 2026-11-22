{block name="title" prepend}{$LNG.lm_banned}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BAN LIST v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astroban_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔴 Rojo (#ef4444) — Sanciones/Peligro
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Sub-cajas con borde rojo sutil + hover
     - Paginación con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: #result_search intacto
     - ⚠️ CRÍTICO: {if $banCount} + {foreach $banList} + {for $site=1 to $maxPage} intactos
     - ⚠️ CRÍTICO: href side=X + mailto + colspan=5 + nth-child anchos intactos
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
.astroban_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astroban_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 900px;
    margin: 0 auto;
}

/* ====== Título de sección (acento rojo) ====== */
.astroban_section_title {
    color: #ff4488;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(239, 68, 68, 0.25);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(239, 68, 68, 0.4);
}

/* ====== Contenedor de la tabla ====== */
#result_search {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(239, 68, 68, 0.15);
    background: rgba(0, 0, 0, 0.3);
    text-align: left !important;
    transition: 0.2s ease;
}
#result_search:hover {
    border-color: rgba(239, 68, 68, 0.3);
}

/* ====== Tabla ====== */
.astroban_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* ====== Cabecera de columnas ====== */
.astroban_table tr.astroban_col_header {
    background: linear-gradient(135deg, rgba(120, 20, 40, 0.85), rgba(180, 30, 60, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astroban_table tr.astroban_col_header td {
    padding: 6px 8px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: center;
    color: #ffffff;
    border-bottom: 1px solid var(--accent-red);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}

/* ====== Filas de datos ====== */
.astroban_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(239, 68, 68, 0.06);
    transition: 0.15s ease;
}
.astroban_table tbody tr:hover {
    background: rgba(239, 68, 68, 0.07);
}
.astroban_table tbody td {
    padding: 5px 8px;
    color: var(--text-main);
    vertical-align: middle;
    text-align: center;
    line-height: 1.3;
    word-break: break-word;
}
.astroban_table tbody td:nth-child(4) {
    color: #00e0ff;
    font-weight: 700;
}
.astroban_table tbody td:nth-child(5) {
    color: #ffaa33;
    font-style: italic;
    text-align: left;
}

/* ====== Anchos de columna ====== */
.astroban_table th:nth-child(1), .astroban_table td:nth-child(1) { width: 18%; }
.astroban_table th:nth-child(2), .astroban_table td:nth-child(2) { width: 18%; }
.astroban_table th:nth-child(3), .astroban_table td:nth-child(3) { width: 18%; }
.astroban_table th:nth-child(4), .astroban_table td:nth-child(4) { width: 18%; }
.astroban_table th:nth-child(5), .astroban_table td:nth-child(5) { width: 28%; }

/* ====== Enlaces ====== */
.astroban_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astroban_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* ====== Paginación ====== */
.astroban_pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 4px;
    padding: 8px 10px;
    background: rgba(0, 0, 0, 0.25);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-top: 1px solid rgba(239, 68, 68, 0.15);
    flex-wrap: wrap;
    font-size: 10.5px;
    color: var(--text-muted);
    font-weight: 600;
}
.astroban_pagination a {
    color: #00e0ff;
    text-decoration: none;
    padding: 3px 8px;
    border-radius: 6px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    transition: 0.2s ease;
}
.astroban_pagination a:hover {
    background: rgba(239, 68, 68, 0.15);
    color: #ffffff;
    text-shadow: 0 0 6px rgba(255, 68, 136, 0.9);
    transform: translateY(-1px);
}
.astroban_pagination b {
    color: #ffffff;
    background: linear-gradient(135deg, rgba(180, 30, 60, 0.9), rgba(239, 68, 68, 0.9));
    padding: 3px 8px;
    border-radius: 6px;
    font-family: 'Courier New', monospace;
    box-shadow: 0 0 8px rgba(239, 68, 68, 0.5);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

/* ====== Contador final / Fila vacía ====== */
.astroban_count {
    background: rgba(239, 68, 68, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #ff4488 !important;
    font-weight: 700;
    text-align: center !important;
    padding: 10px !important;
    font-size: 11px;
    letter-spacing: 0.3px;
    border-top: 1px solid rgba(239, 68, 68, 0.2);
    text-shadow: 0 0 6px rgba(239, 68, 68, 0.3);
}
.astroban_empty {
    color: var(--text-muted) !important;
    font-style: italic;
    text-align: center !important;
    padding: 14px !important;
    font-size: 11px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astroban_wrap { padding: 10px; }
    .astroban_panel { padding: 12px; max-width: 100%; }
    .astroban_table { font-size: 10px; table-layout: auto; }
    .astroban_table tbody td { padding: 4px 5px; }
    .astroban_table tr.astroban_col_header td { padding: 5px 5px; font-size: 9.5px; }
}
</style>

<div class="astroban_wrap">

	<div class="astroban_panel">

		<span class="astroban_section_title">🚫 {$LNG.bn_players_banned_list}</span>

		<div id="result_search">
		<table class="astroban_table">
			<tbody>

				{* ============ CABECERA ============ *}
				<tr class="astroban_col_header">
					<td>{$LNG.bn_from}</td>
					<td>{$LNG.bn_until}</td>
					<td>{$LNG.bn_player}</td>
					<td>{$LNG.bn_by}</td>
					<td>{$LNG.bn_reason}</td>
				</tr>

				{* ============ SI HAY BANEADOS ============ *}
				{if $banCount}
				<tr>
					<td colspan="5">
						<div class="astroban_pagination">
							<span>{$LNG.mg_page}:</span>
							{if $page != 1}<a href="game.php?page=banList&amp;side={$page - 1}">&laquo;</a>{/if}
							{for $site=1 to $maxPage}
								<a href="game.php?page=banList&amp;side={$site}">{if $site == $page}<b>[{$site}]</b>{else}[{$site}]{/if}</a>
							{/for}
							{if $page != $maxPage}<a href="game.php?page=banList&amp;side={$page + 1}">&raquo;</a>{/if}
						</div>
					</td>
				</tr>

				{* Lista de baneados *}
				{foreach $banList as $banRow}
				<tr>
					<td>{$banRow.from}</td>
					<td>{$banRow.to}</td>
					<td>{$banRow.player}</td>
					<td><a href="mailto:{$banRow.mail}" title="{$banRow.info}">{$banRow.admin}</a></td>
					<td>{$banRow.theme}</td>
				</tr>
				{/foreach}

				{* Paginación inferior *}
				<tr>
					<td colspan="5">
						<div class="astroban_pagination">
							<span>{$LNG.mg_page}:</span>
							{if $page != 1}<a href="game.php?page=banList&amp;side={$page - 1}">&laquo;</a>{/if}
							{for $site=1 to $maxPage}
								<a href="game.php?page=banList&amp;side={$site}">{if $site == $page}<b>[{$site}]</b>{else}[{$site}]{/if}</a>
							{/for}
							{if $page != $maxPage}<a href="game.php?page=banList&amp;side={$page + 1}">&raquo;</a>{/if}
						</div>
					</td>
				</tr>

				{* Contador *}
				<tr>
					<td colspan="5" class="astroban_count">
						{$LNG.bn_exists}{$banCount|number}{$LNG.bn_players_banned}
					</td>
				</tr>

				{* ============ SI NO HAY BANEADOS ============ *}
				{else}
				<tr>
					<td colspan="5" class="astroban_empty">— {$LNG.bn_no_players_banned} —</td>
				</tr>
				{/if}

			</tbody>
		</table>
		</div>

	</div>

</div>

{/block}