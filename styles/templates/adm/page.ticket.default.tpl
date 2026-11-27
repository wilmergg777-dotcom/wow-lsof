{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO TICKET ADMIN v3.0 — Lista de tickets (admin)
   Prefijo: .astrotka_
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Tabla con header cyan + hover
     - Estados con badges
     - ⚠️ CRÍTICO: overall_header/footer intactos (admin)
     - ⚠️ CRÍTICO: estructura <table> original preservada
     - ⚠️ CRÍTICO: los 2 foreach + 2 if (status < 2, status == 2) intactos
     - ⚠️ CRÍTICO: href a admin.php?page=support intactos
   ══════════════════════════════════════════════════════════════ *}

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

/* Contenedor wrapper (envuelve la tabla original) */
.astrotka_wrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
}

/* Tabla */
.astrotka_table {
    width: 100% !important;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 11px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astrotka_table th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff;
    padding: 8px 10px;
    font-weight: 700;
    font-size: 10.5px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    text-align: center;
    border-bottom: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrotka_table th.astrotka_section {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    border-bottom: 1px solid var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    padding: 10px 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astrotka_table td {
    padding: 7px 10px;
    text-align: center;
    color: var(--text-main);
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    vertical-align: middle;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.astrotka_table tbody tr:hover td {
    background: rgba(0, 204, 255, 0.07);
    color: #ffffff;
}

.astrotka_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrotka_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Celdas especiales */
.astrotka_id {
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #00e0ff;
}
.astrotka_username {
    color: #88ccff;
}
.astrotka_answers {
    font-family: 'Courier New', monospace;
    color: var(--text-muted);
}
.astrotka_date {
    font-family: 'Courier New', monospace;
    font-size: 10.5px;
    color: var(--text-muted);
}

/* Estados (badges) */
.astrotka_status {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 6px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
}
.astrotka_status_open {
    color: #66ff99 !important;
    background: rgba(102, 255, 153, 0.1);
    border: 1px solid rgba(102, 255, 153, 0.35);
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.4);
}
.astrotka_status_answer {
    color: #ffaa33 !important;
    background: rgba(255, 170, 51, 0.1);
    border: 1px solid rgba(255, 170, 51, 0.35);
    text-shadow: 0 0 6px rgba(255, 170, 51, 0.4);
}
.astrotka_status_closed {
    color: #ff4488 !important;
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.35);
    text-shadow: 0 0 6px rgba(255, 68, 136, 0.4);
}

/* Responsive */
@media (max-width: 720px) {
    .astrotka_wrap { padding: 10px; }
    .astrotka_table { font-size: 10px; table-layout: auto; }
    .astrotka_table th { padding: 6px 5px; font-size: 9.5px; }
    .astrotka_table td { padding: 5px 6px; }
}
</style>

<div class="astrotka_wrap">
<table class="astrotka_table" width="70%" cellpadding="2" cellspacing="2">
	<tr>
		<th colspan="6" class="astrotka_section">{$LNG.ti_header}</th>
	</tr>
	<tr>
		<th style="width:10%">{$LNG.ti_id}</th>
		<th style="width:10%">{$LNG.ti_username}</th>
		<th style="width:40%">{$LNG.ti_subject}</th>
		<th style="width:10%">{$LNG.ti_answers}</th>
		<th style="width:15%">{$LNG.ti_date}</th>
		<th style="width:15%">{$LNG.ti_status}</th>
	</tr>
	{foreach $ticketList as $TicketID => $TicketInfo}	
	{if $TicketInfo.status < 2}
	<tr>
		<td class="astrotka_id"><a href="admin.php?page=support&amp;mode=view&amp;id={$TicketID}">#{$TicketID}</a></td>
		<td class="astrotka_username"><a href="admin.php?page=support&amp;mode=view&amp;id={$TicketID}">{$TicketInfo.username}</a></td>
		<td><a href="admin.php?page=support&amp;mode=view&amp;id={$TicketID}">{$TicketInfo.subject}</a></td>
		<td class="astrotka_answers">{$TicketInfo.answer - 1}</td>
		<td class="astrotka_date">{$TicketInfo.time}</td>
		<td>{if $TicketInfo.status == 0}<span class="astrotka_status astrotka_status_open">{$LNG.ti_status_open}</span>{elseif $TicketInfo.status == 1}<span class="astrotka_status astrotka_status_answer">{$LNG.ti_status_answer}</span>{/if}</td>
	</tr>
	{/if}
	{/foreach}
	<tr>
		<th colspan="6" class="astrotka_section">{$LNG.ti_status_closed}</th>
	</tr>
	<tr>
		<th style="width:10%">{$LNG.ti_id}</th>
		<th style="width:10%">{$LNG.ti_username}</th>
		<th style="width:40%">{$LNG.ti_subject}</th>
		<th style="width:10%">{$LNG.ti_answers}</th>
		<th style="width:15%">{$LNG.ti_date}</th>
		<th style="width:15%">{$LNG.ti_status}</th>
	</tr>
	{foreach $ticketList as $TicketID => $TicketInfo}	
	{if $TicketInfo.status == 2}
	<tr>
		<td class="astrotka_id"><a href="admin.php?page=support&amp;mode=view&amp;id={$TicketID}">#{$TicketID}</a></td>
		<td class="astrotka_username"><a href="admin.php?page=support&amp;mode=view&amp;id={$TicketID}">{$TicketInfo.username}</a></td>
		<td><a href="admin.php?page=support&amp;mode=view&amp;id={$TicketID}">{$TicketInfo.subject}</a></td>
		<td class="astrotka_answers">{$TicketInfo.answer - 1}</td>
		<td class="astrotka_date">{$TicketInfo.time}</td>
		<td><span class="astrotka_status astrotka_status_closed">{$LNG.ti_status_closed}</span></td>
	</tr>
	{/if}
	{/foreach}
</table>
</div>

{include file="overall_footer.tpl"}