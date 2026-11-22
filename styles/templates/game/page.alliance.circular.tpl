{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Mensaje Circular (Popup)
   Prefijo: .astroalci_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism)
     - Inputs/textarea con radius 8px + focus translateY
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: content_page_popup, title_popup, content_popup intactos (fancybox)
     - ⚠️ CRÍTICO: #cntChars, onkeyup, check(), $.fancybox.close() intactos
   ═══════════════════════════════════════════════ *}

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

.astroalci_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalci_panel {
    display: inline-block;
    text-align: left;
    width: 100%;
    max-width: 620px;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    font-size: 11px;
    color: var(--text-main);
    box-sizing: border-box;
}

.astroalci_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalci_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
}

.astroalci_table tr > td {
    padding: 6px 8px;
    vertical-align: top;
    color: var(--text-main);
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
}

.astroalci_table tr > td:first-child {
    width: 40%;
    color: var(--text-muted);
    padding-top: 10px;
}

.astroalci_table tr > td:last-child {
    width: 60%;
}

/* Selects generados por html_options */
.astroalci_table select {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 5px 8px;
    font-size: 10.5px;
    font-family: inherit;
    font-weight: 700;
    width: 100%;
    max-width: 260px;
    transition: 0.25s ease;
    cursor: pointer;
    outline: none;
}
.astroalci_table select:hover,
.astroalci_table select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astroalci_table select option {
    background: #0f1624;
    color: #ffffff;
}

/* Input de asunto */
.astroalci_table input[type="text"] {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 6px 10px;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    width: 100%;
    box-sizing: border-box;
    transition: 0.25s ease;
    outline: none;
}
.astroalci_table input[type="text"]:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* Textarea */
.astroalci_table textarea {
    width: 100%;
    box-sizing: border-box;
    height: 180px;
    padding: 8px 10px;
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    font-size: 11px;
    font-family: inherit;
    resize: vertical;
    transition: 0.25s ease;
    outline: none;
}
.astroalci_table textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
}

/* Contador de caracteres */
#cntChars {
    color: #00e0ff;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.4);
}

/* Fila de botones */
.astroalci_actions {
    text-align: center;
    padding-top: 12px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
    margin-top: 10px;
}

.astroalci_btn {
    display: inline-block;
    padding: 8px 20px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
    transition: 0.25s ease;
    margin: 0 4px;
    letter-spacing: 0.4px;
    text-transform: uppercase;
    font-family: inherit;
}
.astroalci_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astroalci_btn:active {
    transform: translateY(0);
}

.astroalci_btn--reset {
    background: linear-gradient(135deg, rgba(68, 68, 68, 0.9), rgba(102, 102, 102, 0.9));
    border-color: #888888;
}
.astroalci_btn--reset:hover {
    background: linear-gradient(135deg, rgba(102, 102, 102, 0.95), rgba(136, 136, 136, 0.95));
    box-shadow: 0 0 12px rgba(150, 150, 150, 0.4);
}

@media (max-width: 480px) {
    .astroalci_wrap { padding: 10px; }
    .astroalci_panel { padding: 12px; }
    .astroalci_table tr > td:first-child { width: 35%; }
    .astroalci_table tr > td:last-child  { width: 65%; }
    .astroalci_table textarea { height: 130px; }
    .astroalci_btn { width: 100%; margin: 4px 0; }
}
</style>

<div class="content_page_popup">
    <div class="title_popup">
        {$LNG.al_circular_send_ciruclar}
    </div>

    <div class="content_popup">
        <div class="astroalci_wrap">
        <div class="astroalci_panel">

            <div class="astroalci_title">{$LNG.al_circular_send_ciruclar}</div>

            <form name="message" id="message">
                <table class="astroalci_table">
                    <tr>
                        <td>{$LNG.al_receiver}</td>
                        <td>
                            {html_options name=rankID options=$RangeList}
                        </td>
                    </tr>
                    <tr>
                        <td>{$LNG.mg_subject}</td>
                        <td><input type="text" name="subject" id="subject" size="40" maxlength="40" value="{$LNG.mg_no_subject}"></td>
                    </tr>
                    <tr>
                        <td>{$LNG.al_message} (<span id="cntChars">0</span> / 5000 {$LNG.al_characters})</td>
                        <td>
                            <textarea name="text" cols="60" rows="10" onkeyup="$('#cntChars').text($(this).val().length);"></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div class="astroalci_actions">
                                <input class="astroalci_btn astroalci_btn--reset" type="reset" value="{$LNG.al_circular_reset}">
                                <input class="astroalci_btn" type="button" onClick="return check();" name="button" value="{$LNG.al_circular_send_submit}">
                            </div>
                        </td>
                    </tr>
                </table>
            </form>

        </div>
        </div>
    </div>
</div>

{/block}
{block name="script" append}
<script type="text/javascript">
function check(){
	if(document.message.text.value == '') {
		alert('{$LNG.mg_empty_text}');
		return false;
	} else {
		$.post('game.php?page=alliance&mode=circular&action=send&ajax=1', $('#message').serialize(), function(data){
			data = $.parseJSON(data);
			alert(data.message);
			if(!data.error) {
				parent.$.fancybox.close();
			}
		});
		return true;
	}
}
</script>
{/block}