{block name="title" prepend}{$LNG.lm_support}{/block}
{block name="content"}

{* ============================================================
   ASTROIO TICKET v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrotk_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Tabla con borde cyan sutil + hover
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - foreach, if, links, colspan, clases funcionales intactos
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
.astrotk_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrotk_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 720px;
    margin: 0 auto;
}

/* ====== Título de sección ====== */
.astrotk_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
}

/* ====== Barra superior (Nuevo Ticket) ====== */
.astrotk_topbar {
    text-align: center;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.astrotk_topbar:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotk_new_btn {
    display: inline-block;
    padding: 7px 20px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #ffffff !important;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.4px;
    text-decoration: none;
    transition: 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astrotk_new_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astrotk_new_btn:active {
    transform: translateY(0);
}

/* ====== Tabla de tickets ====== */
.astrotk_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrotk_table_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotk_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* Cabecera */
.astrotk_table thead tr {
    background: linear-gradient(135deg, #004488, #0077cc);
}
.astrotk_table thead th {
    padding: 5px 5px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: center;
    color: #ffffff;
    border-bottom: 1px solid #00ccff;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astrotk_table thead th:first-child {
    text-align: left;
    padding-left: 8px;
}

/* Filas */
.astrotk_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrotk_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrotk_table tbody tr:hover td {
    color: #ffffff;
}
.astrotk_table tbody td {
    padding: 5px 6px;
    text-align: center;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.2;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astrotk_table tbody td:first-child {
    text-align: left;
    padding-left: 8px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #00e0ff;
    width: 60px;
}

/* Enlaces dentro de la tabla */
.astrotk_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrotk_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Anchos de columna */
.astrotk_table th:nth-child(1), .astrotk_table td:nth-child(1) { width: 60px;  }
.astrotk_table th:nth-child(2), .astrotk_table td:nth-child(2) { width: 320px; }
.astrotk_table th:nth-child(3), .astrotk_table td:nth-child(3) { width: 80px;  }
.astrotk_table th:nth-child(4), .astrotk_table td:nth-child(4) { width: 130px; }
.astrotk_table th:nth-child(5), .astrotk_table td:nth-child(5) { width: 100px; }

/* ====== Estados ====== */
.astrotk_status {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 6px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
}
.astrotk_status_open {
    color: #66ff99 !important;
    background: rgba(102, 255, 153, 0.1);
    border: 1px solid rgba(102, 255, 153, 0.35);
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.4);
}
.astrotk_status_answer {
    color: #ffaa33 !important;
    background: rgba(255, 170, 51, 0.1);
    border: 1px solid rgba(255, 170, 51, 0.35);
    text-shadow: 0 0 6px rgba(255, 170, 51, 0.4);
}
.astrotk_status_closed {
    color: #ff4488 !important;
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.35);
    text-shadow: 0 0 6px rgba(255, 68, 136, 0.4);
}

/* ====== Fila vacía (si no hay tickets) ====== */
.astrotk_empty {
    color: var(--text-muted) !important;
    font-style: italic;
    text-align: center !important;
    padding: 14px !important;
    font-size: 11px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrotk_wrap { padding: 10px; }
    .astrotk_panel { padding: 12px; max-width: 100%; }
    .astrotk_table { font-size: 10px; table-layout: auto; }
    .astrotk_table thead th { padding: 4px 3px; font-size: 9.5px; }
    .astrotk_table tbody td { padding: 4px 4px; }
    .astrotk_new_btn { padding: 6px 14px; font-size: 10.5px; }
}
</style>

<div class="astrotk_wrap">

	<div class="astrotk_panel">

		<span class="astrotk_section_title">🎫 {$LNG.ti_header}</span>

		{* ============ BOTÓN NUEVO TICKET ============ *}
		<div class="astrotk_topbar">
			<a href="game.php?page=ticket&amp;mode=create" class="astrotk_new_btn">➕ {$LNG.ti_new}</a>
		</div>

		{* ============ TABLA DE TICKETS ============ *}
		<div class="astrotk_table_wrap">
		<table class="astrotk_table">
			<thead>
				<tr>
					<th>{$LNG.ti_id}</th>
					<th>{$LNG.ti_subject}</th>
					<th>{$LNG.ti_answers}</th>
					<th>{$LNG.ti_date}</th>
					<th>{$LNG.ti_status}</th>
				</tr>
			</thead>
			<tbody>
			{foreach $ticketList as $TicketID => $TicketInfo}
			<tr>
				<td>
					<a href="game.php?page=ticket&amp;mode=view&amp;id={$TicketID}">#{$TicketID}</a>
				</td>
				<td>
					<a href="game.php?page=ticket&amp;mode=view&amp;id={$TicketID}">{$TicketInfo.subject}</a>
				</td>
				<td>{$TicketInfo.answer - 1}</td>
				<td>{$TicketInfo.time}</td>
				<td>
					{if $TicketInfo.status == 0}
						<span class="astrotk_status astrotk_status_open">{$LNG.ti_status_open}</span>
					{elseif $TicketInfo.status == 1}
						<span class="astrotk_status astrotk_status_answer">{$LNG.ti_status_answer}</span>
					{else}
						<span class="astrotk_status astrotk_status_closed">{$LNG.ti_status_closed}</span>
					{/if}
				</td>
			</tr>
			{foreachelse}
			<tr>
				<td colspan="5" class="astrotk_empty">{$LNG.ti_not_exist|replace:'#%d':''|default:'No hay tickets'}</td>
			</tr>
			{/foreach}
			</tbody>
		</table>
		</div>

	</div>

</div>

{/block}