{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO TICKET CREATE ADMIN v3.0
   Prefijo: .astrotkca_
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism)
     - Inputs/selects/textarea con radius 8px + focus translateY
     - Botón submit con radius 8px + hover translateY
     - ⚠️ CRÍTICO: overall_header/footer intactos (admin)
     - ⚠️ CRÍTICO: validate[required], ids, name, form action intactos
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

.astrotkca_wrap {
    max-width: 900px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
}

.astrotkca_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
}

.astrotkca_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    table-layout: fixed;
}

.astrotkca_table tr > th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff;
    padding: 10px 12px;
    font-weight: 700;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    text-align: left;
    border-bottom: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    border-radius: 10px 10px 0 0;
}

.astrotkca_table tr > td {
    padding: 10px 12px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
    vertical-align: middle;
}

.astrotkca_table tr > td.left {
    text-align: left;
    color: var(--text-main);
}

.astrotkca_table tr > td:first-child {
    color: var(--text-muted);
    font-weight: 600;
}

.astrotkca_table tr > td:last-child {
    color: var(--text-title);
}

.astrotkca_table label {
    color: var(--text-main);
    font-weight: 600;
    font-size: 11px;
}

/* Inputs, selects y textarea */
.astrotkca_input,
.astrotkca_select,
.astrotkca_textarea {
    width: 100%;
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
}
.astrotkca_input:focus,
.astrotkca_select:focus,
.astrotkca_textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrotkca_select {
    cursor: pointer;
    font-weight: 700;
}
.astrotkca_select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}
.astrotkca_textarea {
    min-height: 120px;
    resize: vertical;
    font-family: inherit;
}

/* Botón submit */
.astrotkca_submit {
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
.astrotkca_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrotkca_submit:active {
    transform: translateY(0);
}

/* Responsive */
@media (max-width: 720px) {
    .astrotkca_wrap { padding: 10px; }
    .astrotkca_table tr > td { padding: 8px 10px; }
    .astrotkca_submit { width: 100%; }
}
</style>

<div class="astrotkca_wrap">
<div class="astrotkca_panel">

<form action="admin.php?page=support&amp;mode=send" method="post" id="form">
<input type="hidden" name="id" value="0">
<table class="astrotkca_table">
	<tr>
		<th colspan="2">{$LNG.ti_create_head}</th>
	</tr>
	<tr>
		<td colspan="2" class="left">{$LNG.ti_create_info}</td>
	</tr>
	<tr>
		<td style="width:30%"><label for="category">{$LNG.ti_category}</label></td>
		<td style="width:70%"><select id="category" name="category" class="astrotkca_select">{html_options options=$categoryList}</select></td>
	</tr>
	<tr>
		<td><label for="subject">{$LNG.ti_subject}</label></td>
		<td><input class="validate[required] astrotkca_input" type="text" id="subject" name="subject" size="40" maxlength="255"></td>
	</tr>
	<tr>
		<td><label for="message">{$LNG.ti_message}</label></td>
		<td><textarea class="validate[required] astrotkca_textarea" id="message" name="message" row="60" cols="8" style="height:100px;"></textarea></td>
	</tr>
	<tr>
		<td colspan="2"><input type="submit" value="{$LNG.ti_submit}" class="astrotkca_submit"></td>
	</tr>
</table>
</form>

</div>
</div>

{include file="overall_footer.tpl"}