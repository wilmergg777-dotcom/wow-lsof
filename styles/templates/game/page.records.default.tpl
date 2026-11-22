{block name="title" prepend}{$LNG.lm_records}{/block}
{block name="content"}

{* ============================================================
   ASTROIO RECORDS v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrerc_   (aislado, no rompe otros módulos)
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Bloque headers con gradiente cyan + glassmorphism
     - Tabla con borde cyan sutil + hover
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: 4 bloques (tech.0/100/200/400) intactos
     - ⚠️ CRÍTICO: {if !empty($elementRow)} + {foreach $elementRow} + {$user.userID} intactos
     - ⚠️ CRÍTICO: onclick Dialog.Playercard + {$elementRow[0].level|number} intactos
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
.astrerc_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrerc_panel {
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

/* ====== Título de sección (acento dorado) ====== */
.astrerc_section_title {
    color: #ffaa33;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(255, 170, 51, 0.25);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(255, 170, 51, 0.3);
}

/* ====== Tabla ====== */
.astrerc_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrerc_table_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrerc_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* Cabecera de cada bloque (tech.0, tech.100, etc.) */
.astrerc_table tr.astrerc_block_header {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astrerc_table tr.astrerc_block_header th {
    padding: 6px 8px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: left;
    color: #ffffff;
    border-bottom: 1px solid var(--accent-cyan);
    border-top: 1px solid rgba(0, 204, 255, 0.2);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}
.astrerc_table tr.astrerc_block_header th:last-child {
    text-align: center;
}

/* Filas de datos */
.astrerc_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrerc_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrerc_table tbody td {
    padding: 5px 8px;
    color: var(--text-main);
    vertical-align: top;
    line-height: 1.3;
    word-break: break-word;
}
.astrerc_table tbody td:first-child {
    color: var(--text-muted);
    font-weight: 600;
    width: 30%;
}
.astrerc_table tbody td:last-child {
    text-align: center;
    color: #66ff99;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    width: 15%;
}

/* Anchos por columna */
.astrerc_table th:nth-child(1), .astrerc_table td:nth-child(1) { width: 30%; }
.astrerc_table th:nth-child(2), .astrerc_table td:nth-child(2) { width: 55%; }
.astrerc_table th:nth-child(3), .astrerc_table td:nth-child(3) { width: 15%; }

/* Enlaces de jugadores */
.astrerc_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
    display: inline-block;
    padding: 0 2px;
}
.astrerc_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrerc_wrap { padding: 10px; }
    .astrerc_panel { padding: 12px; max-width: 100%; }
    .astrerc_table { font-size: 10px; }
    .astrerc_table tbody td { padding: 4px 5px; }
    .astrerc_table tr.astrerc_block_header th { padding: 5px 5px; font-size: 9.5px; }
}
</style>

<div class="astrerc_wrap">

	<div class="astrerc_panel">

		<span class="astrerc_section_title">🏆 {$LNG.rec_last_update_on}: {$update}</span>

		<div class="astrerc_table_wrap">
		<table class="astrerc_table">
			<tbody>

				{* ============ BLOQUE 1: EDIFICIOS (tech.0) ============ *}
				<tr class="astrerc_block_header">
					<th>{$LNG.tech.0}</th>
					<th>{$LNG.rec_players}</th>
					<th>{$LNG.rec_level}</th>
				</tr>
				{foreach $buildList as $elementID => $elementRow}
				<tr>
					<td>{$LNG.tech.{$elementID}}</td>
					{if !empty($elementRow)}
					<td>{foreach $elementRow as $user}<a href='#' onclick='return Dialog.Playercard({$user.userID});'>{$user.username}</a>{if !$user@last}<br>{/if}{/foreach}</td>
					<td>{$elementRow[0].level|number}</td>
					{else}
					<td>-</td>
					<td>-</td>
					{/if}
				</tr>
				{/foreach}

				{* ============ BLOQUE 2: INVESTIGACIONES (tech.100) ============ *}
				<tr class="astrerc_block_header">
					<th>{$LNG.tech.100}</th>
					<th>{$LNG.rec_players}</th>
					<th>{$LNG.rec_level}</th>
				</tr>
				{foreach $researchList as $elementID => $elementRow}
				<tr>
					<td>{$LNG.tech.{$elementID}}</td>
					{if !empty($elementRow)}
					<td>{foreach $elementRow as $user}<a href='#' onclick='return Dialog.Playercard({$user.userID});'>{$user.username}</a>{if !$user@last}<br>{/if}{/foreach}</td>
					<td>{$elementRow[0].level|number}</td>
					{else}
					<td>-</td>
					<td>-</td>
					{/if}
				</tr>
				{/foreach}

				{* ============ BLOQUE 3: NAVES (tech.200) ============ *}
				<tr class="astrerc_block_header">
					<th>{$LNG.tech.200}</th>
					<th>{$LNG.rec_players}</th>
					<th>{$LNG.rec_count}</th>
				</tr>
				{foreach $fleetList as $elementID => $elementRow}
				<tr>
					<td>{$LNG.tech.{$elementID}}</td>
					{if !empty($elementRow)}
					<td>{foreach $elementRow as $user}<a href='#' onclick='return Dialog.Playercard({$user.userID});'>{$user.username}</a>{if !$user@last}<br>{/if}{/foreach}</td>
					<td>{$elementRow[0].level|number}</td>
					{else}
					<td>-</td>
					<td>-</td>
					{/if}
				</tr>
				{/foreach}

				{* ============ BLOQUE 4: DEFENSAS (tech.400) ============ *}
				<tr class="astrerc_block_header">
					<th>{$LNG.tech.400}</th>
					<th>{$LNG.rec_players}</th>
					<th>{$LNG.rec_count}</th>
				</tr>
				{foreach $defenseList as $elementID => $elementRow}
				<tr>
					<td>{$LNG.tech.{$elementID}}</td>
					{if !empty($elementRow)}
					<td>{foreach $elementRow as $user}<a href='#' onclick='return Dialog.Playercard({$user.userID});'>{$user.username}</a>{if !$user@last}<br>{/if}{/foreach}</td>
					<td>{$elementRow[0].level|number}</td>
					{else}
					<td>-</td>
					<td>-</td>
					{/if}
				</tr>
				{/foreach}

			</tbody>
		</table>
		</div>

	</div>

</div>

{/block}