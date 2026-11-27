{block name="title" prepend}{$LNG.lm_buddylist}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BUDDYLIST v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrobud_   (aislado, no rompe otros módulos)
   Acento del módulo: 🟢 Verde (#4aff88)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Sub-cajas con borde verde sutil + hover
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: #result_search intacto
     - ⚠️ CRÍTICO: 3 bloques con {if !empty(...)} + 3 {foreach} + {foreachelse} intactos
     - ⚠️ CRÍTICO: Dialog.PM + mode=accept/delete + true/false.png + colores online intactos
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
.astrobud_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrobud_panel {
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

/* ====== Título de sección (acento verde) ====== */
.astrobud_section_title {
    color: #4aff88;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(74, 255, 136, 0.25);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(74, 255, 136, 0.35);
}

/* ====== Contenedor de la tabla ====== */
#result_search {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(74, 255, 136, 0.15);
    background: rgba(0, 0, 0, 0.3);
    text-align: left !important;
    transition: 0.2s ease;
}
#result_search:hover {
    border-color: rgba(74, 255, 136, 0.3);
}

/* ====== Tabla ====== */
.astrobud_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* ====== Cabecera de bloque (Solicitudes / Mis solicitudes / Amigos) ====== */
.astrobud_table tr.astrobud_block_header {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astrobud_table tr.astrobud_block_header th {
    padding: 7px 10px;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    text-align: center;
    color: #4aff88;
    border-top: 2px solid var(--accent-green);
    border-bottom: 1px solid var(--accent-green);
    text-shadow: 0 0 8px rgba(74, 255, 136, 0.5);
}

/* ====== Cabecera de columnas ====== */
.astrobud_table tr.astrobud_col_header {
    background: rgba(0, 0, 0, 0.3);
}
.astrobud_table tr.astrobud_col_header th {
    padding: 5px 8px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: center;
    color: #ffffff;
    border-bottom: 1px solid rgba(74, 255, 136, 0.2);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}

/* ====== Filas de datos ====== */
.astrobud_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(74, 255, 136, 0.06);
    transition: 0.15s ease;
}
.astrobud_table tbody tr:hover {
    background: rgba(74, 255, 136, 0.07);
}
.astrobud_table tbody td {
    padding: 5px 8px;
    color: var(--text-main);
    vertical-align: middle;
    text-align: center;
    line-height: 1.3;
    word-break: break-word;
}
.astrobud_table tbody td:nth-child(4) {
    text-align: left;
    color: var(--text-muted);
    font-style: italic;
}

/* ====== Anchos de columna ====== */
.astrobud_table th:nth-child(1), .astrobud_table td:nth-child(1) { width: 22%; }
.astrobud_table th:nth-child(2), .astrobud_table td:nth-child(2) { width: 18%; }
.astrobud_table th:nth-child(3), .astrobud_table td:nth-child(3) { width: 20%; }
.astrobud_table th:nth-child(4), .astrobud_table td:nth-child(4) { width: 22%; }
.astrobud_table th:nth-child(5), .astrobud_table td:nth-child(5) { width: 18%; }

/* ====== Enlaces ====== */
.astrobud_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrobud_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Link de alianza (púrpura) */
.astrobud_table td:nth-child(2) a {
    color: #aa44ff;
}
.astrobud_table td:nth-child(2) a:hover {
    color: #ffffff;
    text-shadow: 0 0 8px rgba(170, 68, 255, 0.9);
}

/* ====== Botones de acción (imágenes true/false) ====== */
.astrobud_table td:last-child a {
    display: inline-block;
    padding: 3px 5px;
    border-radius: 6px;
    transition: 0.25s ease;
    margin: 0 2px;
    border: 1px solid transparent;
}
.astrobud_table td:last-child img {
    width: 16px;
    height: 16px;
    vertical-align: middle;
    border-radius: 3px;
    transition: 0.25s ease;
    display: block;
}
.astrobud_table td:last-child a:hover {
    background: rgba(74, 255, 136, 0.15);
    border-color: rgba(74, 255, 136, 0.4);
    box-shadow: 0 0 8px rgba(74, 255, 136, 0.5);
    transform: translateY(-2px);
}
.astrobud_table td:last-child a:hover img {
    transform: scale(1.15);
}
.astrobud_table td:last-child a:active {
    transform: translateY(0);
}

/* ====== Estados de conexión ====== */
.astrobud_online {
    color: #66ff99 !important;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.4);
}
.astrobud_recent {
    color: #ffaa33 !important;
    font-weight: 700;
    font-family: 'Courier New', monospace;
}
.astrobud_offline {
    color: #ff4488 !important;
    font-weight: 700;
}

/* ====== Fila vacía ====== */
.astrobud_empty {
    color: var(--text-muted) !important;
    font-style: italic;
    text-align: center !important;
    padding: 10px !important;
    font-size: 10.5px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrobud_wrap { padding: 10px; }
    .astrobud_panel { padding: 12px; max-width: 100%; }
    .astrobud_table { font-size: 10px; table-layout: auto; }
    .astrobud_table tbody td { padding: 4px 5px; }
    .astrobud_table tr.astrobud_col_header th { padding: 4px 5px; font-size: 9.5px; }
}
</style>

<div class="astrobud_wrap">

	<div class="astrobud_panel">

		<span class="astrobud_section_title">👥 {$LNG.bu_buddy_list}</span>

		<div id="result_search">
		<table class="astrobud_table">
			<tbody>

				{* ============ SOLICITUDES RECIBIDAS ============ *}
				{if !empty($otherRequestList)}
				<tr class="astrobud_block_header">
					<th colspan="5">📨 {$LNG.bu_requests}</th>
				</tr>
				<tr class="astrobud_col_header">
					<th>{$LNG.bu_player}</th>
					<th>{$LNG.bu_alliance}</th>
					<th>{$LNG.bu_coords}</th>
					<th>{$LNG.bu_text}</th>
					<th>{$LNG.bu_action}</th>
				</tr>
				{foreach $otherRequestList as $otherRequestID => $otherRequestRow}
				<tr>
					<td><a href="#" onclick="return Dialog.PM({$otherRequestRow.id});">{$otherRequestRow.username}</a></td>
					<td>{if {$otherRequestRow.ally_name}}<a href="game.php?page=alliance&amp;mode=info&amp;id={$otherRequestRow.ally_id}">{$otherRequestRow.ally_name}</a>{else}-{/if}</td>
					<td><a href="game.php?page=galaxy&amp;galaxy={$otherRequestRow.galaxy}&amp;system={$otherRequestRow.system}">[{$otherRequestRow.galaxy}:{$otherRequestRow.system}:{$otherRequestRow.planet}]</a></td>
					<td>{$otherRequestRow.text}</td>
					<td>
						<a href="game.php?page=buddyList&amp;mode=accept&amp;id={$otherRequestID}">
							<img src="styles/resource/images/true.png" alt="{$LNG.bu_accept}" title="{$LNG.bu_accept}">
						</a>
						<a href="game.php?page=buddyList&amp;mode=delete&amp;id={$otherRequestID}">
							<img src="styles/resource/images/false.png" alt="{$LNG.bu_decline}" title="{$LNG.bu_decline}">
						</a>
					</td>
				</tr>
				{foreachelse}
				<tr><td colspan="5" class="astrobud_empty">{$LNG.bu_no_request}</td></tr>
				{/foreach}
				{/if}

				{* ============ MIS SOLICITUDES ENVIADAS ============ *}
				{if !empty($myRequestList)}
				<tr class="astrobud_block_header">
					<th colspan="5">📤 {$LNG.bu_my_requests}</th>
				</tr>
				<tr class="astrobud_col_header">
					<th>{$LNG.bu_player}</th>
					<th>{$LNG.bu_alliance}</th>
					<th>{$LNG.bu_coords}</th>
					<th>{$LNG.bu_text}</th>
					<th>{$LNG.bu_action}</th>
				</tr>
				{foreach $myRequestList as $myRequestID => $myRequestRow}
				<tr>
					<td><a href="#" onclick="return Dialog.PM({$myRequestRow.id});">{$myRequestRow.username}</a></td>
					<td>{if {$myRequestRow.ally_name}}<a href="game.php?page=alliance&amp;mode=info&amp;id={$myRequestRow.ally_id}">{$myRequestRow.ally_name}</a>{else}-{/if}</td>
					<td><a href="game.php?page=galaxy&amp;galaxy={$myRequestRow.galaxy}&amp;system={$myRequestRow.system}">[{$myRequestRow.galaxy}:{$myRequestRow.system}:{$myRequestRow.planet}]</a></td>
					<td>{$myRequestRow.text}</td>
					<td>
						<a href="game.php?page=buddyList&amp;mode=delete&amp;id={$myRequestID}">
							<img src="styles/resource/images/false.png" alt="{$LNG.bu_cancel_request}" title="{$LNG.bu_cancel_request}">
						</a>
					</td>
				</tr>
				{foreachelse}
				<tr><td colspan="5" class="astrobud_empty">{$LNG.bu_no_request}</td></tr>
				{/foreach}
				{/if}

				{* ============ LISTA DE AMIGOS ============ *}
				<tr class="astrobud_block_header">
					<th colspan="5">👥 {$LNG.bu_partners}</th>
				</tr>
				<tr class="astrobud_col_header">
					<th>{$LNG.bu_player}</th>
					<th>{$LNG.bu_alliance}</th>
					<th>{$LNG.bu_coords}</th>
					<th>{$LNG.bu_online}</th>
					<th>{$LNG.bu_action}</th>
				</tr>
				{foreach $myBuddyList as $myBuddyID => $myBuddyRow}
				<tr>
					<td><a href="#" onclick="return Dialog.PM({$myBuddyRow.id});">{$myBuddyRow.username}</a></td>
					<td>{if {$myBuddyRow.ally_name}}<a href="game.php?page=alliance&amp;mode=info&amp;id={$myBuddyRow.ally_id}">{$myBuddyRow.ally_name}</a>{else}-{/if}</td>
					<td><a href="game.php?page=galaxy&amp;galaxy={$myBuddyRow.galaxy}&amp;system={$myBuddyRow.system}">[{$myBuddyRow.galaxy}:{$myBuddyRow.system}:{$myBuddyRow.planet}]</a></td>
					<td>
					{if $myBuddyRow.onlinetime < 4}
					<span class="astrobud_online">{$LNG.bu_connected}</span>
					{elseif $myBuddyRow.onlinetime >= 4 && $myBuddyRow.onlinetime <= 15}
					<span class="astrobud_recent">{$myBuddyRow.onlinetime} {$LNG.bu_minutes}</span>
					{else}
					<span class="astrobud_offline">{$LNG.bu_disconnected}</span>
					{/if}
					</td>
					<td>
						<a href="game.php?page=buddyList&amp;mode=delete&amp;id={$myBuddyID}">
							<img src="styles/resource/images/false.png" alt="{$LNG.bu_delete}" title="{$LNG.bu_delete}">
						</a>
					</td>
				</tr>
				{foreachelse}
				<tr><td colspan="5" class="astrobud_empty">{$LNG.bu_no_buddys}</td></tr>
				{/foreach}

			</tbody>
		</table>
		</div>

	</div>

</div>

{/block}