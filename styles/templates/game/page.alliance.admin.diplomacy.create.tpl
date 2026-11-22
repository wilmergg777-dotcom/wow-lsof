{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}

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