{block name="content"}

{* ============================================================
   ASTROIO SEARCH RESULT v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrosrchr_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (tabla glassmorphism, header cyan)
     - Iconos con hover translateY + glow
     - ⚠️ CRÍTICO: id="resulttable" intacto (usado por JS)
     - ⚠️ CRÍTICO: onclick Dialog.Playercard/PM/Buddy + href intactos
     - ⚠️ CRÍTICO: {if $searchRow.allyname} + {foreach $searchList} intactos
   ============================================================ *}

<style>
/* ====== Tabla de resultados ====== */
.astrosrchr_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    overflow: hidden;
}

/* Cabecera */
.astrosrchr_table thead tr {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astrosrchr_table thead th {
    padding: 6px 8px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: left;
    color: #ffffff;
    border-bottom: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}
.astrosrchr_table thead th.astrosrchr_th_icons {
    width: 70px;
    text-align: center;
}
.astrosrchr_table thead th.astrosrchr_th_pos {
    width: 70px;
    text-align: center;
}

/* Filas */
.astrosrchr_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrosrchr_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrosrchr_table tbody td {
    padding: 5px 8px;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.3;
    word-break: break-word;
}
.astrosrchr_table tbody td.astrosrchr_td_icons {
    text-align: center;
    white-space: nowrap;
}
.astrosrchr_table tbody td.astrosrchr_td_pos {
    text-align: center;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #66ff99;
}

/* Enlaces */
.astrosrchr_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrosrchr_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Iconos PM y Buddy */
.astrosrchr_table .astrosrchr_icon {
    display: inline-block;
    padding: 3px 8px;
    margin: 0 2px;
    border-radius: 6px;
    transition: 0.25s ease;
    color: #66ff99;
    font-size: 13px;
    border: 1px solid transparent;
}
.astrosrchr_table .astrosrchr_icon:hover {
    background: rgba(102, 255, 153, 0.15);
    color: #ffffff;
    text-shadow: 0 0 8px rgba(102, 255, 153, 0.9);
    border-color: rgba(102, 255, 153, 0.4);
    transform: translateY(-2px);
}
.astrosrchr_table .astrosrchr_icon:active {
    transform: translateY(0);
}

/* Alianza */
.astrosrchr_table .astrosrchr_ally {
    color: #aa44ff;
    font-weight: 700;
}
.astrosrchr_table .astrosrchr_ally:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(170, 68, 255, 0.9);
}

/* Coordenadas */
.astrosrchr_table .astrosrchr_coord {
    color: #00e0ff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
}

/* ====== Fila vacía ====== */
.astrosrchr_empty {
    color: var(--text-muted) !important;
    font-style: italic;
    text-align: center !important;
    padding: 14px !important;
    font-size: 11px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrosrchr_table { font-size: 10px; table-layout: auto; }
    .astrosrchr_table thead th { padding: 5px 5px; font-size: 9.5px; }
    .astrosrchr_table tbody td { padding: 4px 5px; }
}
</style>

<table class="astrosrchr_table" id="resulttable">
	<thead>
		<tr>
			<th>{$LNG.sh_name}</th>
			<th class="astrosrchr_th_icons">&nbsp;</th>
			<th>{$LNG.sh_alliance}</th>
			<th>{$LNG.sh_planet}</th>
			<th>{$LNG.sh_coords}</th>
			<th class="astrosrchr_th_pos">{$LNG.sh_position}</th>
		</tr>
	</thead>
	<tbody>
	{foreach $searchList as $searchRow}
	<tr>
		<td>
			<a href="#" onclick="return Dialog.Playercard({$searchRow.userid});">{$searchRow.username}</a>
		</td>
		<td class="astrosrchr_td_icons">
			<a href="#" class="astrosrchr_icon" onclick="return Dialog.PM({$searchRow.userid});" title="{$LNG.sh_write_message}">
				<i class="far fa-envelope"></i>
			</a>
			<a href="#" class="astrosrchr_icon" onclick="return Dialog.Buddy({$searchRow.userid});" title="{$LNG.sh_buddy_request}">
				<i class="far fa-handshake"></i>
			</a>
		</td>
		<td>
			{if $searchRow.allyname}
				<a href="game.php?page=alliance&amp;mode=info&amp;id={$searchRow.allyid}" class="astrosrchr_ally">{$searchRow.allyname}</a>
			{else}
				<span style="color:#667788;">-</span>
			{/if}
		</td>
		<td>{$searchRow.planetname}</td>
		<td>
			<a href="game.php?page=galaxy&amp;galaxy={$searchRow.galaxy}&amp;system={$searchRow.system}" class="astrosrchr_coord">[{$searchRow.galaxy}:{$searchRow.system}:{$searchRow.planet}]</a>
		</td>
		<td class="astrosrchr_td_pos">{$searchRow.rank}</td>
	</tr>
	{foreachelse}
	<tr>
		<td colspan="6" class="astrosrchr_empty">— {$LNG.sh_search_in_the_universe} —</td>
	</tr>
	{/foreach}
	</tbody>
</table>

{/block}