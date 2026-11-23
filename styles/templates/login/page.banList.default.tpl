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

{literal}
<style>
/* ═══ ASTROIO v8.1 — reskin nextgen (tokens del índice v8.0) ═══ */
:root {
    --nx-muted:  #9a9a9a;
    --nx-cyan:   #59d6ff;
    --nx-green:  #35ff8f;
    --nx-red:    #ff5252;
    --nx-purple: #d946ef;
    --nx-gold:   #fbbf24;
    --nx-border: rgba(255, 255, 255, 0.1);
}

/* ═══ Tarjeta nextgen (idéntica a las del índice) ═══ */
.astrobans_panel, .panel-default.astrobans_panel {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border);
    border-radius: 15px;
    box-shadow: 0 0 40px rgba(0, 0, 0, 0.75);
    overflow: hidden;
}
.astrobans_section_title, .panel-heading.astrobans_heading, .astrobans_heading {
    display: block;
    background: transparent;
    color: #ffffff;
    font-family: 'Space Mono', monospace;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
    padding: 16px 20px;
    border-bottom: 1px solid var(--nx-border);
    text-shadow: none;
}
.astrobans_wrap {
    font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}

.astrobans_wrap { max-width: 860px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; }
.astrobans_uni_row { padding: 12px 16px; border-bottom: 1px solid var(--nx-border); }
.astrobans_uni_row select { max-width: 260px; }
.astrobans_table_wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }
.astrobans_table { width: 100%; border-collapse: collapse; font-size: 12.5px; min-width: 520px; }
.astrobans_table thead th {
    padding: 9px 10px; background: rgba(255,255,255,.05);
    color: var(--nx-muted);
    font-family: 'Space Mono', monospace; font-size: 10px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 1.5px;
    border-bottom: 1px solid var(--nx-border); text-align: left; white-space: nowrap; text-shadow: none;
}
.astrobans_table tbody td {
    padding: 8px 10px; color: #e2e8f0; vertical-align: middle; text-align: left;
    line-height: 1.4; word-break: break-word;
    border-bottom: 1px solid rgba(255,255,255,.06);
}
.astrobans_table tbody tr:hover { background: rgba(255,255,255,.04); }
.astrobans_table tbody td:nth-child(4) { color: var(--nx-cyan); font-weight: 700; }
.astrobans_table tbody td:nth-child(5) { color: var(--nx-gold); font-style: italic; }
.astrobans_table a { color: var(--nx-cyan); text-decoration: none; font-weight: 600; transition: .15s ease; }
.astrobans_table a:hover { color: #ffffff; }
.astrobans_count {
    background: rgba(53,255,143,.06); color: var(--nx-green) !important;
    font-family: 'Space Mono', monospace; font-size: 11px; font-weight: 700;
    text-align: center !important; padding: 10px !important; letter-spacing: 1px;
}
.astrobans_empty {
    color: var(--nx-muted) !important; font-style: italic;
    text-align: center !important; padding: 16px !important; font-size: 12px;
}
/* Paginación */
.astrobans_pagination {
    display: flex; justify-content: center; align-items: center; gap: 5px;
    padding: 12px; background: rgba(255,255,255,.03);
    border: 1px solid var(--nx-border); border-radius: 10px;
    margin: 14px 16px 16px; flex-wrap: wrap;
    font-family: 'Space Mono', monospace; font-size: 11px; color: var(--nx-muted); font-weight: 600;
}
.astrobans_pagination a {
    color: var(--nx-cyan); text-decoration: none; padding: 5px 12px;
    border-radius: 6px; font-weight: 700; transition: .2s ease;
    border: 1px solid rgba(255,255,255,.12);
}
.astrobans_pagination a:hover {
    background: rgba(89,214,255,.1); border-color: var(--nx-cyan);
    color: #ffffff; transform: translateY(-1px);
}
.astrobans_pagination a:active { transform: translateY(0); }

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astrobans_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astrobans_panel { border-radius: 12px; }
    .astrobans_body { padding: 16px 14px !important; }
    .astrobans_actions { text-align: center !important; }
    .astrobans_actions .btn, .astrobans_btn_register, .astrobans_btn_submit { width: 100%; }
}
</style>
{/literal}

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