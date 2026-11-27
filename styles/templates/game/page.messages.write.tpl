{block name="title" prepend}{$LNG.write_message}{/block}
{block name="content"}

{* ============================================================
   ASTROIO MESSAGES WRITE v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astromw_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔵 Azul (#3b82f6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Inputs/textarea con radius 8px + focus translateY
     - Botón con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: form name="message" id="message" intacto
     - ⚠️ CRÍTICO: #cntChars, #subject, #text, #submit + onkeyup + onClick intactos
     - ⚠️ CRÍTICO: {block name="script"} con check() + fancybox.close() intacto
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
.astromw_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astromw_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
}

/* ====== Título ====== */
.astromw_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}

/* ====== Filas del formulario ====== */
.astromw_row {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    margin-bottom: 8px;
}
.astromw_label {
    color: var(--text-main);
    font-weight: 600;
    font-size: 11px;
    width: 25%;
    padding-top: 8px;
    flex-shrink: 0;
    line-height: 1.3;
}
.astromw_field {
    flex-grow: 1;
    min-width: 0;
}

/* Contador de caracteres */
.astromw_counter {
    color: #ffaa33;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 10px;
    text-shadow: 0 0 6px rgba(255, 170, 51, 0.4);
}
.astromw_counter_max {
    color: var(--text-muted);
    font-size: 10px;
}

/* ====== Inputs / textarea ====== */
.astromw_input,
.astromw_textarea {
    width: 100%;
    padding: 7px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: inherit;
    font-size: 11px;
    line-height: 1.3;
    outline: none;
    transition: 0.25s ease;
    box-sizing: border-box;
}
.astromw_input:focus,
.astromw_textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astromw_textarea {
    min-height: 120px;
    resize: vertical;
    font-family: inherit;
}

/* ====== Botón submit ====== */
.astromw_submit_row {
    text-align: right;
    padding-top: 10px;
    margin-top: 8px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}
.astromw_submit_btn {
    display: inline-block;
    padding: 8px 26px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9) 0%, rgba(0, 153, 255, 0.9) 100%);
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.4px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 3px 10px rgba(0, 102, 204, 0.4);
    text-transform: uppercase;
}
.astromw_submit_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95) 0%, rgba(0, 204, 255, 0.95) 100%);
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astromw_submit_btn:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astromw_wrap { padding: 10px; }
    .astromw_panel { padding: 12px; }
    .astromw_row { flex-direction: column; gap: 6px; }
    .astromw_label { width: 100%; padding-top: 0; }
    .astromw_submit_btn { width: 100%; padding: 10px 16px; }
    .astromw_submit_row { text-align: center; }
}
</style>

<div class="astromw_wrap">

	<div class="astromw_panel">

		<span class="astromw_section_title">✉ {$LNG.mg_send_new}</span>

		<form name="message" id="message" action="">

			{* ============ DESTINATARIO ============ *}
			<div class="astromw_row">
				<label class="astromw_label">{$LNG.mg_send_to}</label>
				<div class="astromw_field">
					<input type="text" name="to" size="40" value="{$OwnerRecord.username} [{$OwnerRecord.galaxy}:{$OwnerRecord.system}:{$OwnerRecord.planet}]" class="astromw_input">
				</div>
			</div>

			{* ============ ASUNTO ============ *}
			<div class="astromw_row">
				<label class="astromw_label">{$LNG.mg_subject}</label>
				<div class="astromw_field">
					<input type="text" name="subject" id="subject" size="40" maxlength="40" value="{if !empty($subject)}{$subject}{else}{$LNG.mg_no_subject}{/if}" class="astromw_input">
				</div>
			</div>

			{* ============ MENSAJE ============ *}
			<div class="astromw_row">
				<label class="astromw_label">
					{$LNG.mg_message}<br>
					(<span class="astromw_counter" id="cntChars">0</span><span class="astromw_counter_max">&nbsp;/&nbsp;5.000&nbsp;{$LNG.mg_characters}</span>)
				</label>
				<div class="astromw_field">
					<textarea name="text" id="text" cols="40" rows="10" onkeyup="$('#cntChars').text($(this).val().length);" class="astromw_textarea"></textarea>
				</div>
			</div>

			{* ============ BOTÓN ENVIAR ============ *}
			<div class="astromw_submit_row">
				<input id="submit" type="button" onClick="check();" name="button" value="{$LNG.mg_send}" class="astromw_submit_btn">
			</div>

		</form>

	</div>

</div>

{/block}

{block name="script" append}
<script type="text/javascript">
function check(){
	if($('#text').val().length == 0) {
		alert('{$LNG.mg_empty_text}');
		return false;
	} else {
		$('submit').attr('disabled','disabled');
		$.post('game.php?page=messages&mode=send&id={$id}&ajax=1', $('#message').serialize(), function(data) {
			alert(data);
			parent.$.fancybox.close();
			return true;
		}, 'json');
	}
}
</script>
{/block}