{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO TICKET VIEW ADMIN v3.0
   Prefijo: .astrotkva_
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Sub-cajas con borde cyan sutil + hover
     - Inputs/textarea con radius 8px + focus translateY
     - Botones con radius 8px + hover translateY
     - ⚠️ CRÍTICO: overall_header/footer intactos (admin)
     - ⚠️ CRÍTICO: validate[required], ids, name, form action intactos
     - ⚠️ CRÍTICO: onclick reload y checkbox change_status intactos
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

.astrotkva_wrap {
    max-width: 1000px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
}

.astrotkva_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
}

.astrotkva_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    table-layout: fixed;
}

.astrotkva_table tr > th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff;
    padding: 10px 12px;
    font-weight: 700;
    font-size: 11.5px;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    text-align: center;
    border-bottom: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astrotkva_table tr > th:first-child {
    border-radius: 10px 10px 0 0;
}
.astrotkva_table tr > th:last-child {
    border-radius: 10px 10px 0 0;
}

.astrotkva_table tr > th a {
    color: #ffffff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astrotkva_table tr > th a:hover {
    color: #00e0ff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.8);
}

.astrotkva_table tr > td {
    padding: 10px 12px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
    vertical-align: top;
}

.astrotkva_table tr > td.left {
    text-align: left;
}

.astrotkva_table tr > td:first-child {
    color: var(--text-muted);
    font-weight: 600;
}

.astrotkva_table tr > td:last-child {
    color: var(--text-title);
}

/* Bloque de mensaje */
.astrotkva_msg {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-left: 3px solid #00ccff;
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.astrotkva_msg:hover {
    background: rgba(0, 204, 255, 0.06);
    border-left-color: #00e0ff;
    border-color: rgba(0, 204, 255, 0.3);
}

.astrotkva_msg p {
    margin: 0 0 8px 0;
    padding: 0;
    color: var(--text-main);
    font-size: 11.5px;
    line-height: 1.5;
    word-wrap: break-word;
    white-space: pre-wrap;
}
.astrotkva_msg p:last-child {
    margin-bottom: 0;
}

.astrotkva_msg b {
    color: #00e0ff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.4);
}

.astrotkva_msg hr {
    border: none;
    border-top: 1px dashed rgba(0, 204, 255, 0.2);
    margin: 10px 0;
}

/* Separador */
.astrotkva_sep {
    height: 1px;
    background: linear-gradient(to right, transparent, rgba(0, 204, 255, 0.3), transparent);
    margin: 12px 0;
    border: none;
}

/* Label */
.astrotkva_label {
    color: var(--text-main);
    font-weight: 600;
    font-size: 11px;
}

/* Textarea */
.astrotkva_textarea {
    width: 100%;
    min-height: 120px;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: inherit;
    font-size: 11.5px;
    line-height: 1.4;
    outline: none;
    transition: 0.25s ease;
    box-sizing: border-box;
    resize: vertical;
}
.astrotkva_textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* Checkbox */
.astrotkva_checkbox {
    accent-color: #00ccff;
    width: 16px;
    height: 16px;
    cursor: pointer;
    vertical-align: middle;
    filter: drop-shadow(0 0 4px rgba(0, 204, 255, 0.3));
}

/* Botón submit */
.astrotkva_submit {
    display: inline-block;
    padding: 9px 28px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11.5px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.4px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 3px 10px rgba(0, 102, 204, 0.4);
    text-transform: uppercase;
}
.astrotkva_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrotkva_submit:active {
    transform: translateY(0);
}

.astrotkva_submit_row {
    text-align: right;
    padding-top: 10px;
}

/* Responsive */
@media (max-width: 720px) {
    .astrotkva_wrap { padding: 10px; }
    .astrotkva_table tr > td { padding: 8px 10px; }
    .astrotkva_submit { width: 100%; }
    .astrotkva_submit_row { text-align: center; }
}
</style>

<div class="astrotkva_wrap">
<div class="astrotkva_panel">

<form action="admin.php?page=support&mode=send" method="post" id="form">
<input type="hidden" name="id" value="{$ticketID}">
<table class="astrotkva_table" width="70%" cellpadding="2" cellspacing="2">
	{foreach $answerList as $answerID => $answerRow}	
	{if $answerRow@first}
	<tr>
		<th colspan="2"><a href="admin.php?page=support">{$LNG.ti_overview}</a></th>
	</tr>
	<tr>
		<th colspan="2">{$LNG.ti_read} :: {$answerRow.subject}</th>
	</tr>
	{/if}
	<tr>
		<td class="left" colspan="2">
			<div class="astrotkva_msg">
				<p>{if !$answerRow@first}
					<b>{$LNG.ti_subject}: {$answerRow.subject}</b><br>
				{$LNG.ti_responded}: <b>{$answerRow.time}</b> {$LNG.ti_from} <b>{$answerRow.ownerName}</b>
				{/if}
				{if $answerRow@first}
				{$LNG.ti_create}: <b>{$answerRow.time}</b> {$LNG.ti_from} <b>{$answerRow.ownerName}</b>
					<br>{$LNG.ti_category}: {$categoryList[$answerRow.categoryID]}
				{/if}
				</p>
				<hr>
				<p>
					{$answerRow.message}
				</p>
			</div>
		</td>
	</tr>
	{/foreach}
	<tr>
		<th colspan="2">{$LNG.ti_answer}</th>
	</tr>
	<tr>
		<td style="width:30%"><label for="message" class="astrotkva_label">{$LNG.ti_message}</label></td>
		<td style="width:70%"><textarea class="validate[required] astrotkva_textarea" id="message" name="message" row="60" cols="8" style="height:100px;"></textarea></td>
	</tr>
	<tr>
		<td style="width:30%" class="astrotkva_label">{if $ticket_status < 2}{$LNG.ti_close}{else}{$LNG.ti_open}{/if}</td>
		<td style="width:70%"><input type="checkbox" name="change_status" value="1" class="astrotkva_checkbox"></td>
	</tr>	
	<tr>
		<td colspan="2" class="astrotkva_submit_row"><input type="submit" value="{$LNG.ti_submit}" class="astrotkva_submit" onclick="parent.rightFrame.document.location.reload();"></td>
	</tr>
</table>
</form>

</div>
</div>

{include file="overall_footer.tpl"}