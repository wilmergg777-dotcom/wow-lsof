{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.admin.diplomacy.create.tpl === *}
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
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Alianza · Admin · Crear Diplomacia (Popup)
   Prefijo: .astroaldc_
   ═══════════════════════════════════════════════ */

.astroaldc_wrap {
    text-align: center; padding: 8px 0;
}

.astroaldc_panel {
    display: inline-block; text-align: left;
    width: 100%; max-width: 620px;
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #1e3a5f; border-radius: 8px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.4);
    padding: 10px 14px; font-size: 11px; color: #c8d6e5;
    box-sizing: border-box;
}

.astroaldc_title {
    text-transform: uppercase; color: #00e0ff;
    font-size: 11.5px; letter-spacing: 1px;
    border-bottom: 1px solid #1e3a5f;
    padding-bottom: 6px; margin-bottom: 12px;
}

.astroaldc_table {
    width: 100%; border-collapse: collapse;
    font-size: 10.5px;
}

.astroaldc_table tr > td {
    padding: 5px 6px; vertical-align: top;
    color: #c8d6e5;
}

.astroaldc_table tr > td:first-child {
    width: 40%; color: #a8b8c8;
}

.astroaldc_table tr > td:last-child {
    width: 60%;
}

/* Selects generados por html_options */
.astroaldc_table select {
    background: #0f1624; color: #c8d6e5;
    border: 1px solid #1e3a5f; border-radius: 4px;
    padding: 3px 6px; font-size: 10.5px;
    width: 100%; max-width: 260px;
    transition: 0.2s ease;
}
.astroaldc_table select:focus {
    outline: none; border-color: #00ccff;
    box-shadow: 0 0 8px rgba(0,224,255,0.4);
}

/* Textarea */
.astroaldc_table textarea {
    width: 100%; box-sizing: border-box;
    height: 175px; padding: 6px 8px;
    background: #0f1624; color: #c8d6e5;
    border: 1px solid #1e3a5f; border-radius: 6px;
    font-size: 11px; font-family: inherit;
    resize: vertical; transition: 0.2s ease;
}
.astroaldc_table textarea:focus {
    outline: none; border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0,224,255,0.4);
}

/* Contador de caracteres */
#cntChars { color: #00e0ff; font-weight: 500; }

/* Fila de botones */
.astroaldc_actions {
    text-align: center; padding-top: 10px;
    border-top: 1px solid #1e3a5f;
    margin-top: 8px;
}

.astroaldc_btn {
    display: inline-block; padding: 5px 16px;
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%);
    color: #fff; border: 1px solid #00ccff;
    border-radius: 6px; font-size: 10.5px;
    cursor: pointer; text-decoration: none;
    transition: 0.2s ease; margin: 0 4px;
}
.astroaldc_btn:hover {
    box-shadow: 0 0 12px rgba(0,224,255,0.35);
    transform: translateY(-1px);
}

.astroaldc_btn--reset {
    background: linear-gradient(180deg, #444 0%, #666 100%);
    border-color: #888;
}
.astroaldc_btn--reset:hover {
    box-shadow: 0 0 12px rgba(150,150,150,0.35);
}

@media (max-width: 480px) {
    .astroaldc_panel { padding: 8px; }
    .astroaldc_table tr > td:first-child { width: 35%; }
    .astroaldc_table tr > td:last-child  { width: 65%; }
    .astroaldc_table textarea { height: 130px; }
}
</style>

<div class="content_page_popup">
    <div class="title_popup">
        {$LNG.al_circular_send_ciruclar}
    </div>

    <div class="content_popup">
        <div class="astroaldc_wrap">
        <div class="astroaldc_panel">

            <div class="astroaldc_title">{$LNG.al_circular_send_ciruclar}</div>

            <form name="message" id="message">
                <table class="astroaldc_table">
                <tr>
                    <td>{$LNG.al_diplo_ally}</td>
                    <td>{html_options name="ally_id" values=$IdList output=$AllyList}</td>
                </tr>
                <tr>
                    <td>{$LNG.al_diplo_level_des}</td>
                    <td>{html_options name="level" values=range(1,6) output=$LNG.al_diplo_level selected=$diploMode}</td>
                </tr>
                <tr>
                    <td>{$LNG.al_diplo_text}<br>(<span id="cntChars">0</span> / 5000 {$LNG.al_characters})</td>
                    <td>
                        <textarea name="text" cols="60" rows="10" onkeyup="$('#cntChars').text($(this).val().length);"></textarea>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <div class="astroaldc_actions">
                            <input class="astroaldc_btn astroaldc_btn--reset" type="reset" value="{$LNG.al_circular_reset}">
                            <input class="astroaldc_btn" type="button" onclick="return check();" value="{$LNG.al_circular_send_submit}">
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
		$.getJSON('game.php?page=alliance&mode=admin&action=diplomacyCreateProcessor&ajax=1&'+$('#message').serialize(), function(data) {
			alert(data.message);
			if(!data.error) {
				parent.location.reload();
			}
		});
		return true;
	}
}

$(function() {	
	$('#name').autocomplete({
		source: "game.php?page=search&mode=autocomplete&type=allyname",
		minLength: 0,
		select: function(event, ui) {
			$(event.target).val(ui.item.label.replace(/<\/?b>/gim, ''));
			return false;
		}
	});
});
</script>
{/block}