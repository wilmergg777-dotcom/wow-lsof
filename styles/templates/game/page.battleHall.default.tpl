{block name="title" prepend}{$LNG.lm_topkb}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BATTLE HALL v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrotkb_   (aislado, no rompe otros módulos)
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Tabla con borde cyan sutil + hover
     - Links de ordenación preservados con sus estilos dinámicos
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: links order=date/units, clases winner/loser/vs, {if $row.result} intactos
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
.astrotkb_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrotkb_panel {
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
.astrotkb_section_title {
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

/* ====== Banner de felicitación ====== */
.astrotkb_banner {
    text-align: center;
    padding: 10px 14px;
    background: linear-gradient(135deg, rgba(255, 170, 51, 0.12), rgba(255, 170, 51, 0.04));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 170, 51, 0.35);
    border-radius: 10px;
    margin-bottom: 12px;
    color: #ffaa33;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.3px;
    text-shadow: 0 0 8px rgba(255, 170, 51, 0.3);
}

/* ====== Tabla ====== */
.astrotkb_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrotkb_table_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotkb_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* Cabecera */
.astrotkb_table thead tr {
    background: linear-gradient(135deg, #004488, #0077cc);
}
.astrotkb_table thead th {
    padding: 6px 6px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: left;
    color: #ffffff;
    border-bottom: 1px solid #00ccff;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}
.astrotkb_table thead th.astrotkb_th_pos {
    width: 50px;
    text-align: center;
}
.astrotkb_table thead th.astrotkb_th_date {
    width: 130px;
}
.astrotkb_table thead th.astrotkb_th_units {
    width: 100px;
    text-align: right;
}

/* Enlaces de ordenación en cabecera */
.astrotkb_table thead th a {
    color: #ffffff;
    text-decoration: none;
    font-weight: 700;
    transition: 0.15s ease;
}
.astrotkb_table thead th a:hover {
    color: #00e0ff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Filas */
.astrotkb_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrotkb_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrotkb_table tbody td {
    padding: 5px 6px;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.3;
    word-break: break-word;
}

/* Columna posición */
.astrotkb_table tbody td:first-child {
    text-align: center;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: var(--text-muted);
}

/* Columna unidades */
.astrotkb_table tbody td:last-child {
    text-align: right;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #66ff99;
}

/* Enlaces */
.astrotkb_table tbody a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrotkb_table tbody a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Colores de ganador/perdedor */
.astrotkb_winner { color: #66ff99 !important; font-weight: 700; }
.astrotkb_loser { color: #ff4488 !important; font-weight: 700; }
.astrotkb_vs { color: var(--text-muted); font-weight: 700; padding: 0 4px; }

/* ====== Fila de leyenda ====== */
.astrotkb_table tbody tr.astrotkb_legend td {
    background: rgba(0, 0, 0, 0.3);
    color: var(--text-muted);
    font-size: 10px;
    padding: 8px 10px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
    text-align: center;
    font-weight: 600;
}
.astrotkb_table tbody tr.astrotkb_legend td span {
    font-weight: 700;
    margin: 0 4px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrotkb_wrap { padding: 10px; }
    .astrotkb_panel { padding: 12px; max-width: 100%; }
    .astrotkb_table { font-size: 10px; table-layout: auto; }
    .astrotkb_table thead th { padding: 5px 4px; font-size: 9.5px; }
    .astrotkb_table tbody td { padding: 4px 4px; }
}
</style>

<div class="astrotkb_wrap">

	<div class="astrotkb_panel">

		<span class="astrotkb_section_title">🏆 {$LNG.tkb_top}</span>

		<div class="astrotkb_banner">🎉 {$LNG.tkb_gratz}</div>

		<div class="astrotkb_table_wrap">
		<table class="astrotkb_table">
			<thead>
				<tr>
					<th class="astrotkb_th_pos">{$LNG.tkb_platz}</th>
					<th>{$LNG.tkb_owners}</th>
					<th class="astrotkb_th_date">
						<a href="game.php?page=battleHall&order=date&sort={if $sort == "ASC"}DESC{else}ASC{/if}"{if $order == "date"} style="text-shadow:0 0 8px #00e0ff;color:#00e0ff;"{/if}>{$LNG.tkb_datum}</a>
					</th>
					<th class="astrotkb_th_units">
						<a href="game.php?page=battleHall&order=units&sort={if $sort == "ASC"}DESC{else}ASC{/if}"{if $order == "units"} style="text-shadow:0 0 8px #00e0ff;color:#00e0ff;"{/if}>{$LNG.tkb_units}</a>
					</th>
				</tr>
			</thead>
			<tbody>
				{foreach $TopKBList as $row}
				<tr>
					<td>{$row@iteration}</td>
					<td>
						<a href="game.php?page=raport&amp;mode=battlehall&amp;raport={$row.rid}" target="_blank">
						{if $row.result == "a"}
						<span class="astrotkb_winner">{$row.attacker}</span><span class="astrotkb_vs">VS</span><span class="astrotkb_loser">{$row.defender}</span>
						{elseif $row.result == "r"}
						<span class="astrotkb_loser">{$row.attacker}</span><span class="astrotkb_vs">VS</span><span class="astrotkb_winner">{$row.defender}</span>
						{else}
						{$row.attacker}<span class="astrotkb_vs">VS</span>{$row.defender}
						{/if}
						</a>
					</td>
					<td>{$row.date}</td>
					<td>{$row.units|number}</td>
				</tr>
				{/foreach}
				<tr class="astrotkb_legend">
					<td colspan="4">
						{$LNG.tkb_legende}
						<span class="astrotkb_winner">{$LNG.tkb_gewinner}</span>
						<span class="astrotkb_loser">{$LNG.tkb_verlierer}</span>
					</td>
				</tr>
			</tbody>
		</table>
		</div>

	</div>

</div>

{/block}