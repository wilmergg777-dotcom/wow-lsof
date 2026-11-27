{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.messages.view.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
#content h1, #content h2, #content h3, #content h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
#content a { color:#00e0ff; text-decoration:none; transition:.2s ease }
#content a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
#content table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
#content table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
#content table tr:hover td { background:rgba(0,224,255,.04) }
#content input[type=text], #content input[type=password], #content input[type=email], #content input[type=number], #content input[type=date], #content select, #content textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
#content input[type=text]:focus, #content input[type=password]:focus, #content input[type=email]:focus, #content input[type=number]:focus, #content select:focus, #content textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
#content textarea { width:100%; resize:vertical; font-family:inherit }
#content button, #content input[type=submit], #content input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content button:hover, #content input[type=submit]:hover, #content input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
#content button:active, #content input[type=submit]:active, #content input[type=button]:active { transform:translateY(0) }
#content input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
#content select option { background:#0f172a; color:#cbd5e1 }
#content .globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { #content { padding:6px; overflow-x:auto } #content table { font-size:11px } #content table th, #content table td { padding:5px 7px } }
</style>
{/literal}

<style>
/* ============================================================
   🛡️ ARREGLO DEFINITIVO VISUAL PARA EL REPORTE DE ESPIONAJE
   ============================================================ */
.spyRaport {
    font-size: 11px !important;
    color: #cbd5e1 !important;
    width: 100% !important;
    display: block !important;
}
.spyRaportHead {
    font-size: 13px !important;
    font-weight: bold !important;
    padding: 10px 0 !important;
    text-align: left !important;
    border-bottom: 1px solid rgba(255,255,255,0.1) !important;
    margin-bottom: 10px !important;
}
.spyRaportHead a { color: #00e0ff !important; text-decoration: none !important; }

.spyRaportContainer {
    display: block !important;
    margin-bottom: 15px !important;
    background: rgba(0,0,0,0.2) !important;
    border: 1px solid rgba(255,255,255,0.05) !important;
    border-radius: 6px !important;
    padding: 10px !important;
}
.spyRaportContainerHead {
    font-size: 12px !important;
    font-weight: bold !important;
    padding: 5px 10px !important;
    margin: -10px -10px 10px -10px !important;
    background: rgba(255,255,255,0.05) !important;
    border-bottom: 1px solid rgba(255,255,255,0.1) !important;
    border-radius: 6px 6px 0 0 !important;
    text-align: center !important;
    text-transform: uppercase !important;
    color: #fff !important;
}

.spyRaportContainerRow {
    display: flex !important;
    flex-wrap: wrap !important;
    padding: 4px 0 !important;
    border-bottom: 1px dotted rgba(255,255,255,0.1) !important;
    align-items: center !important;
    margin: 0 !important;
    clear: both !important;
}
.spyRaportContainerRow:last-child {
    border-bottom: none !important;
}

.spyRaportContainerCell {
    width: 50% !important;
    box-sizing: border-box !important;
    font-size: 11px !important;
    line-height: 1.3 !important;
    padding: 2px 5px !important;
    display: block !important;
    float: none !important;
    margin: 0 !important;
}
/* Nombres (izquierda) */
.spyRaportContainerCell:nth-child(odd) {
    text-align: left !important;
    color: #e2e8f0 !important;
}
/* Cantidades (derecha) */
.spyRaportContainerCell:nth-child(even) {
    text-align: right !important;
    color: #00e0ff !important;
    font-weight: bold !important;
    font-family: 'Courier New', monospace !important;
}

.spyRaportFooter {
    margin-top: 10px !important;
    padding-top: 10px !important;
    border-top: 1px solid rgba(255,255,255,0.1) !important;
    text-align: center !important;
    font-size: 11px !important;
    margin-bottom: 0 !important; /* 🔥 Quita margen inferior */
    padding-bottom: 0 !important; /* 🔥 Quita relleno inferior */
}
.spyRaportFooter a {
    display: inline-block !important;
    margin: 4px !important;
    padding: 6px 16px !important;
    background: rgba(0, 224, 255, 0.1) !important;
    border: 1px solid rgba(0, 224, 255, 0.4) !important;
    border-radius: 4px !important;
    color: #00e0ff !important;
    text-decoration: none !important;
    font-weight: bold !important;
    transition: all 0.2s ease !important;
}
.spyRaportFooter a:hover {
    background: rgba(0, 224, 255, 0.3) !important;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5) !important;
    color: #fff !important;
}

/* ============================================================
   🔥 ELIMINAR ESPACIO VACÍO AL FINAL DEL MENSAJE
   ============================================================ */
.msg-reader-body {
    padding-bottom: 0 !important;
    margin-bottom: 0 !important;
    min-height: 0 !important;
}
.msg-reader-body > div:last-child {
    margin-bottom: 0 !important;
    padding-bottom: 0 !important;
}
</style>

{* ============================================================
   MESSAGES VIEW — Lista limpia para el nuevo diseño
   Solo genera los .msg-item que se inyectan en #message_list
   ============================================================ *}

{foreach $MessageList as $Message}
<div class="msg-item{if $MessID != 999 && $Message.unread == 1} unread{/if}"
     onclick="Message.openMessage(
        '{$Message.id}',
        $(this).find('.msg-item-subject').text(),
        $(this).find('.msg-item-sender').text(),
        $(this).find('.msg-item-date').text()
     );">
    <div class="msg-avatar">{$Message.from|substr:0:1}</div>
    <div class="msg-item-body">
        <div class="msg-item-sender">{$Message.from}</div>
        <div class="msg-item-subject">{$Message.subject|strip_tags}</div>
    </div>
    <div class="msg-item-date">{$Message.time}</div>
    
    <!-- 🛡️ CORREGIDO: Añadido escape:'html' para que las etiquetas del reporte no rompan el diseño de la lista -->
    <div id="msg-content-{$Message.id}" style="display:none;">{$Message.text|escape:'html'}</div>
</div>
{foreachelse}
<div class="msg-empty" style="height:100%;">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 7l9 6 9-6M3 7v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2z"/></svg>
    <p>Sin mensajes</p>
</div>
{/foreach}

{if $maxPage > 1}
<div style="padding:10px;text-align:center;font-size:11px;color:#94a3b8;border-top:1px solid rgba(0,212,255,0.1);">
    <span>Página:</span>
    {if $page != 1}<a href="#" onclick="Message.getMessages({$MessID}, {$page - 1});return false;" style="color:#00e0ff;text-decoration:none;padding:0 4px;">&laquo;</a>{/if}
    {for $site=1 to $maxPage}<a href="#" onclick="Message.getMessages({$MessID}, {$site});return false;" style="color:{if $site == $page}#fff{else}#00e0ff{/if};text-decoration:none;padding:0 4px;">{if $site == $page}<b>[{$site}]</b>{else}[{$site}]{/if}</a>{/for}
    {if $page != $maxPage}<a href="#" onclick="Message.getMessages({$MessID}, {$maxPage});return false;" style="color:#00e0ff;text-decoration:none;padding:0 4px;">&raquo;</a>{/if}
</div>
{/if}
{/block}