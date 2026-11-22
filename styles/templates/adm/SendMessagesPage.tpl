{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO SEND MESSAGES (admin) v3.0
   Prefijo: .astrosm_
   Acento del módulo: 🔵 Azul (#3b82f6)
   FIX v3.0:
     - Patrón fleetDealer aplicado vía overrides !important (admin)
     - Tabla con header azul + hover + radius
     - Inputs/textarea con radius 8px + focus translateY
     - Botón con radius 8px + hover translateY
     - ⚠️ CRÍTICO: overall_header/footer intactos
     - ⚠️ CRÍTICO: id="message"/"subject"/"text"/"cntChars" intactos
     - ⚠️ CRÍTICO: check() + Dialog.alert() + location.reload() intactos
     - ⚠️ CRÍTICO: {html_options name=mode/globalmessagelang} intactos
   ══════════════════════════════════════════════════════════════ *}

<script type="text/javascript">

function check(){
	if($('#text').val().length == 0) {
		Dialog.alert('{$LNG.mg_empty_text}');
		return false;
	} else {
		$.post('admin.php?page=globalmessage&action=send&ajax=1', $('#message').serialize(), function(data) {
			Dialog.alert(data, function() {
				location.reload();
			});
		});
		return true;
	}
}
</script>

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
    max-width: 900px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Título principal del admin (si existe) ====== */
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

/* ====== Tabla del admin ====== */
.content_page table,
.content_page table.table569 {
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

/* Cabeceras de la tabla */
.content_page table th,
.content_page table.table569 th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    color: #ffffff !important;
    padding: 10px 14px !important;
    font-weight: 700 !important;
    font-size: 11.5px !important;
    text-transform: uppercase !important;
    letter-spacing: 0.5px !important;
    text-align: left !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    border-top: 1px solid rgba(30, 41, 59, 0.6) !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
    vertical-align: middle !important;
}

/* Celdas */
.content_page table td,
.content_page table.table569 td {
    padding: 8px 14px !important;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6) !important;
    color: var(--text-main) !important;
    vertical-align: middle !important;
}

/* Primera columna (labels) */
.content_page table td:first-child,
.content_page table.table569 td:first-child {
    color: var(--text-muted) !important;
    font-weight: 600 !important;
    width: 40% !important;
}

/* Filas hover */
.content_page table tr:hover td {
    background: rgba(59, 130, 246, 0.08) !important;
}

/* ====== Inputs (text) ====== */
.content_page table input[type="text"] {
    padding: 7px 12px !important;
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
.content_page table input[type="text"]:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5) !important;
    background: rgba(0, 0, 0, 0.65) !important;
    transform: translateY(-1px) !important;
}

/* ====== Textarea ====== */
.content_page table textarea {
    width: 100% !important;
    box-sizing: border-box !important;
    padding: 8px 12px !important;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-family: inherit !important;
    font-size: 11px !important;
    line-height: 1.4 !important;
    outline: none !important;
    transition: 0.25s ease !important;
    resize: vertical !important;
    min-height: 120px !important;
}
.content_page table textarea:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5) !important;
    background: rgba(0, 0, 0, 0.65) !important;
    transform: translateY(-1px) !important;
}

/* ====== Selects (html_options) ====== */
.content_page table select {
    padding: 7px 12px !important;
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
    background: rgba(0, 0, 0, 0.65) !important;
    transform: translateY(-1px) !important;
}
.content_page table select option {
    background: #0f1624 !important;
    color: #ffffff !important;
    padding: 4px !important;
}

/* ====== Botón submit (type=button) ====== */
.content_page table input[type="submit"],
.content_page table input[type="button"],
.content_page table button {
    padding: 9px 26px !important;
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
.content_page table input[type="submit"]:hover,
.content_page table input[type="button"]:hover,
.content_page table button:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95) 0%, rgba(0, 204, 255, 0.95) 100%) !important;
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5) !important;
    transform: translateY(-2px) !important;
}
.content_page table input[type="submit"]:active,
.content_page table input[type="button"]:active,
.content_page table button:active {
    transform: translateY(0) !important;
}

/* ====== Contador de caracteres ====== */
#cntChars {
    color: #ffaa33 !important;
    font-family: 'Courier New', monospace !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    text-shadow: 0 0 6px rgba(255, 170, 51, 0.4) !important;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .content_page { padding: 10px; }
    .content_page table { font-size: 10px !important; }
    .content_page table th,
    .content_page table td {
        padding: 6px 10px !important;
    }
    .content_page table td:first-child {
        width: auto !important;
    }
    .content_page table input[type="text"],
    .content_page table textarea,
    .content_page table select {
        font-size: 10px !important;
        padding: 6px 10px !important;
    }
    .content_page table select {
        min-width: 0 !important;
        width: 100% !important;
    }
    .content_page table input[type="submit"],
    .content_page table input[type="button"],
    .content_page table button {
        width: 100% !important;
    }
}
</style>

<form name="message" id="message" action="admin.php?page=globalmessage&action=send&ajax=1">
<table class="table569">
		<tr>
            <th colspan="2">{$LNG.ma_send_global_message}</th>
        </tr>
        <tr>
            <td>{$LNG.ma_mode}</td>
            <td>{html_options name=mode options=$modes}</td>
		</tr>
        <tr>
            <td>{$LNG.se_lang}</td>
            <td>{html_options name=globalmessagelang options=$langSelector}</td>
        </tr>
        <tr>
            <td>{$LNG.ma_subject}</td>
            <td><input name="subject" id="subject" size="40" maxlength="40" value="{$LNG.ma_none}" type="text"></td>
        </tr>
		<tr>
            <td>{$LNG.ma_message} (<span id="cntChars">0</span> / 5000 {$LNG.ma_characters})</td>
            <td><textarea name="text" id="text" cols="40" rows="10" onkeyup="$('#cntChars').text($('#text').val().length);"></textarea></td>
        </tr>
        <tr>
            <td colspan="2"><input type="button" onclick="check();" value="{$LNG.button_submit}"></td>
        </tr>
    </table>
</form>
{include file="overall_footer.tpl"}