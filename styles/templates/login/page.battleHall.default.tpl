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
.astrotkbs_panel, .panel-default.astrotkbs_panel {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border);
    border-radius: 15px;
    box-shadow: 0 0 40px rgba(0, 0, 0, 0.75);
    overflow: hidden;
}
.astrotkbs_section_title, .panel-heading.astrotkbs_heading, .astrotkbs_heading {
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
.astrotkbs_wrap {
    font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}

.astrotkbs_wrap { max-width: 860px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; }
.astrotkbs_uni_row { padding: 12px 16px; border-bottom: 1px solid var(--nx-border); }
.astrotkbs_uni_row select { max-width: 260px; }
.astrotkbs_table_wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }
.astrotkbs_table { width: 100%; border-collapse: collapse; font-size: 13px; min-width: 520px; }
.astrotkbs_table thead th {
    padding: 9px 10px; background: rgba(255,255,255,.05); color: var(--nx-muted);
    font-family: 'Space Mono', monospace; font-size: 10px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 1.5px;
    border-bottom: 1px solid var(--nx-border); text-align: left; white-space: nowrap; text-shadow: none;
}
.astrotkbs_table tbody td {
    padding: 9px 10px; color: #e2e8f0; border-bottom: 1px solid rgba(255,255,255,.06);
    vertical-align: middle; line-height: 1.4;
}
.astrotkbs_table tbody tr:hover { background: rgba(255,255,255,.04); }
.astrotkbs_winner { color: var(--nx-green); font-weight: 700; }
.astrotkbs_loser { color: var(--nx-red); font-weight: 700; }
.astrotkbs_vs {
    color: var(--nx-purple); font-family: 'Space Mono', monospace; font-size: 10px;
    font-weight: 700; letter-spacing: 1px; padding: 0 6px;
}
.astrotkbs_legend {
    display: flex; justify-content: center; gap: 18px; flex-wrap: wrap;
    padding: 12px; margin: 0 16px 16px;
    background: rgba(255,255,255,.03); border: 1px solid var(--nx-border); border-radius: 10px;
    font-family: 'Space Mono', monospace; font-size: 11px; letter-spacing: 1px; text-transform: uppercase;
}

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astrotkbs_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astrotkbs_panel { border-radius: 12px; }
    .astrotkbs_body { padding: 16px 14px !important; }
    .astrotkbs_actions { text-align: center !important; }
    .astrotkbs_actions .btn, .astrotkbs_btn_register, .astrotkbs_btn_submit { width: 100%; }
}
</style>
{/literal}

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