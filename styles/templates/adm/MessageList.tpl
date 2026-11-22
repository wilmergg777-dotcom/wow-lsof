{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO MESSAGE LIST (admin) v3.0
   Prefijo: .astroml_
   Acento del módulo: 🔵 Azul (#3b82f6)
   FIX v3.0:
     - Patrón fleetDealer aplicado vía overrides !important (admin con clases core)
     - Tablas con header azul + hover + radius
     - Inputs con radius 8px + focus translateY
     - ⚠️ CRÍTICO: overall_header/footer intactos
     - ⚠️ CRÍTICO: id="form"/"side"/"sender"/"receiver"/"dateStart*"/"dateEnd*" intactos
     - ⚠️ CRÍTICO: data-messageID + class="toggle" + id="contentID*" + gotoPage() intactos
     - ⚠️ CRÍTICO: colspan dinámico {if $Selected == 100}6{else}5{/if} intacto
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

/* ====== Override content_page (admin) ====== */
.content_page {
    color: var(--text-main);
    max-width: 1300px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Título principal del admin ====== */
.content_page > .title {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: 1px solid var(--border-color) !important;
    border-bottom: 1px solid var(--accent-blue) !important;
    border-radius: 12px 12px 0 0 !important;
    color: #ffffff !important;
    padding: 12px 16px !important;
    font-weight: 700 !important;
    font-size: 13px !important;
    letter-spacing: 0.8px !important;
    text-transform: uppercase !important;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4), 0 0 10px rgba(59, 130, 246, 0.4) !important;
}

/* ====== Tablas del admin ====== */
.content_page table {
    background: var(--bg-card) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: 1px solid var(--border-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    width: 100% !important;
    border-collapse: separate !important;
    border-spacing: 0 !important;
    margin-bottom: 15px !important;
    font-size: 11px !important;
    overflow: hidden !important;
    table-layout: auto !important;
}

/* Cabeceras de las tablas */
.content_page table th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    color: #ffffff !important;
    padding: 8px 12px !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    text-transform: uppercase !important;
    letter-spacing: 0.5px !important;
    text-align: left !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    border-top: 1px solid rgba(30, 41, 59, 0.6) !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
    vertical-align: middle !important;
}

/* Celdas */
.content_page table td {
    padding: 6px 12px !important;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6) !important;
    color: var(--text-main) !important;
    vertical-align: middle !important;
}

/* Filas hover */
.content_page table tr:hover td {
    background: rgba(59, 130, 246, 0.08) !important;
    color: #ffffff !important;
}

/* Centrado y alineación */
.content_page table .center {
    text-align: center !important;
}
.content_page table .right {
    text-align: right !important;
}
.content_page table .left {
    text-align: left !important;
}

/* ====== Inputs (text) ====== */
.content_page table input[type="text"],
.content_page table input[type="number"] {
    padding: 6px 10px !important;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-family: 'Courier New', monospace !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    outline: none !important;
    transition: 0.25s ease !important;
    box-sizing: border-box !important;
}
.content_page table input[type="text"]:focus,
.content_page table input[type="number"]:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5) !important;
    background: rgba(0, 0, 0, 0.65) !important;
    transform: translateY(-1px) !important;
}

/* ====== Selects (html_options) ====== */
.content_page table select {
    padding: 6px 10px !important;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-family: inherit !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    outline: none !important;
    cursor: pointer !important;
    transition: 0.25s ease !important;
    min-width: 200px !important;
}
.content_page table select:hover,
.content_page table select:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5) !important;
    transform: translateY(-1px) !important;
}
.content_page table select option {
    background: #0f1624 !important;
    color: #ffffff !important;
    padding: 4px !important;
}

/* ====== Botón submit ====== */
.content_page table input[type="submit"] {
    padding: 8px 22px !important;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9) 0%, rgba(0, 153, 255, 0.9) 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    cursor: pointer !important;
    transition: 0.25s ease !important;
    letter-spacing: 0.4px !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
    text-transform: uppercase !important;
    font-family: inherit !important;
    box-shadow: 0 3px 10px rgba(0, 102, 204, 0.4) !important;
}
.content_page table input[type="submit"]:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95) 0%, rgba(0, 204, 255, 0.95) 100%) !important;
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5) !important;
    transform: translateY(-2px) !important;
}
.content_page table input[type="submit"]:active {
    transform: translateY(0) !important;
}

/* ====== Enlaces (toggle / paginación) ====== */
.content_page table a {
    color: #00e0ff !important;
    text-decoration: none !important;
    font-weight: 600 !important;
    transition: 0.2s ease !important;
    display: inline-block !important;
}
.content_page table a:hover {
    color: #ffffff !important;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.8) !important;
    transform: translateY(-1px) !important;
}

/* Paginación activa (orange por default, lo dejamos visible) */
.content_page table a span[style*="color:orange"] {
    text-shadow: 0 0 8px rgba(255, 165, 0, 0.7) !important;
}

/* Imágenes dentro de tablas (tooltip deleted) */
.content_page table img {
    vertical-align: middle !important;
    filter: drop-shadow(0 0 3px rgba(59, 130, 246, 0.4)) !important;
    transition: 0.2s ease !important;
}
.content_page table img:hover {
    filter: drop-shadow(0 0 8px rgba(59, 130, 246, 0.8)) !important;
}

/* ====== Filas de contenido (toggle body) ====== */
.content_page table tr[id^="contentID"] {
    background: rgba(0, 0, 0, 0.35) !important;
}
.content_page table tr[id^="contentID"] td {
    background: rgba(0, 0, 0, 0.35) !important;
    color: var(--text-main) !important;
    font-size: 11px !important;
    line-height: 1.4 !important;
    border-top: 1px solid rgba(0, 204, 255, 0.15) !important;
    word-wrap: break-word !important;
    word-break: break-word !important;
}

/* Reset del color de enlaces dentro del contentID (texto del mensaje) */
.content_page table tr[id^="contentID"] td * {
    color: inherit !important;
}
.content_page table tr[id^="contentID"] td a {
    color: #00e0ff !important;
}

/* ====== Fila de paginación (fondo diferente) ====== */
.content_page table tr:has(td.right) {
    background: rgba(0, 0, 0, 0.25) !important;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .content_page { padding: 10px; }
    .content_page table { font-size: 10px !important; }
    .content_page table th,
    .content_page table td {
        padding: 5px 8px !important;
    }
    .content_page table input[type="text"],
    .content_page table input[type="number"] {
        font-size: 10px !important;
        padding: 5px 8px !important;
    }
    .content_page table select {
        min-width: 0 !important;
        width: 100% !important;
    }
    .content_page table input[type="submit"] {
        width: 100% !important;
    }
}
</style>

<form action="admin.php?page=messagelist" method="post" id="form">
<input type="hidden" name="side" value="{$page}" id="side">
<table width="90%">   
	<tr>
		<th colspan="5">{$LNG.ml_message_list}</th>
	</tr>
	<tr>
		<td style="width:15%">{$LNG.ml_type}</td>
		<td style="width:35%">{html_options options=$categories selected=$type name="type"}</td>
		<td style="width:15%">{$LNG.ml_date_range}</td>
		<td style="width:17.5%"><input value="{$dateStart.day|default:''}" type="text" id="dateStartDay" name="dateStart[day]" style="width:25px" maxlength="2" placeholder="dd">.<input value="{$dateStart.month|default:''}" type="text" id="dateStartMonth" name="dateStart[month]" style="width:25px" maxlength="2" placeholder="mm">.<input value="{$dateStart.year|default:''}" type="text" id="dateStartYear" name="dateStart[year]" style="width:35px" maxlength="4" placeholder="yyyy"></td>
		<td style="width:17.5%"><input value="{$dateEnd.day|default:''}" type="text" id="dateEndDay" name="dateEnd[day]" style="width:25px" maxlength="2" placeholder="dd">.<input value="{$dateEnd.month|default:''}" type="text" id="dateEndMonth" name="dateEnd[month]" style="width:25px" maxlength="2" placeholder="mm">.<input value="{$dateEnd.year|default:''}" type="text" id="dateEndYear" name="dateEnd[year]" style="width:35px" maxlength="4" placeholder="yyyy"></td>
	</tr>
	<tr>
		<td style="width:15%"><label for="sender">{$LNG.ml_sender}</label></td>
		<td style="width:35%"><input type="text" id="sender" name="sender" value="{$sender}" length="11"></td>
		<td style="width:15%"><label for="receiver">{$LNG.ml_receiver}</label></td>
		<td style="width:35%" colspan="2"><input type="text" id="receiver" name="receiver" value="{$receiver}" length="11"></td>
	</tr>
	<tr>
		<th colspan="5" class="center">
			<input type="submit" value="{$LNG.ml_type_submit}">
		</th>
	</tr>
</table>
<table width="90%">  	
	<tr>
		<th colspan="{if $Selected == 100}6{else}5{/if}">{$LNG.ml_message_list}</th>
	</tr>
	<tr style="height: 20px;">
		<td class="right" colspan="{if $Selected == 100}6{else}5{/if}">{$LNG.mg_page}: {if $page != 1}<a href="#" onclick="gotoPage({$page - 1});return false;">&laquo;</a> {/if}{for $site=1 to $maxPage}<a href="#" onclick="gotoPage({$site});return false;">{if $site == $page}<span style="color:orange"><b>[{$site}]</b></span>{else}[{$site}]{/if}</a>{if $site != $maxPage} {/if}{/for}{if $page != $maxPage} <a href="#" onclick="gotoPage({$page + 1});return false;">&raquo;</a>{/if}</td>
	</tr>
	<tr>
		<th style="width:4%">{$LNG.ml_id}</th>
		{if $Selected == 100}<th>{$LNG.ml_type}</th>{/if}
		<th style="width:15%">{$LNG.ml_date}</th>
		<th>{$LNG.ml_sender}</th>
		<th>{$LNG.ml_receiver}</th>
		<th>{$LNG.ml_subject}</th>
	</tr>
	{foreach $messageList as $messageID => $messageRow}
	<tr data-messageID="{$messageID}">
		<td><a href="#" class="toggle">{$messageID}</a></td>
		{if $Selected == 100}<td><a href="#" class="toggle">{$LNG.mg_type[$messageRow.type]}</a></td>{/if}
		<td><a href="#" class="toggle">{$messageRow.time}</a></td>
		<td><a href="#" class="toggle">{$messageRow.sender}</a></td>
		<td><a href="#" class="toggle">{$messageRow.receiver}</a></td>
		<td><a href="#" class="toggle">{$messageRow.subject}{if $messageRow.deleted}&nbsp;<img src="./styles/resource/images/admin/i.gif" width="16" height="16" alt="" class="tooltip" data-tooltip-content="{$LNG.ml_deleted}">{/if}</a></td>
	</tr>
	<tr id="contentID{$messageID}" style="display:none;">
		<td class="left" colspan="{if $Selected == 100}6{else}5{/if}" style="padding:5px 8px;">{$messageRow.text}</td>
	</tr>
	{/foreach}
</table>
</form>
<script src="scripts/admin/messageList.js"></script>
{include file="overall_footer.tpl"}