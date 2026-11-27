{block name="title" prepend}{$LNG.ti_read} - {$LNG.lm_support}{/block}
{block name="content"}

{* ============================================================
   ASTROIO TICKET VIEW v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrotkv_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Mensajes con borde-left cyan + hover
     - Textarea con radius 8px + focus translateY
     - Botón submit con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: validate[required], ids, name, form action intactos
     - ⚠️ CRÍTICO: jQuery Validation Engine intacto
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
.astrotkv_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrotkv_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 720px;
    margin: 0 auto;
}

/* ====== Título del ticket ====== */
.astrotkv_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 12px;
    display: block;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}

/* ====== Mensaje individual (glassmorphism) ====== */
.astrotkv_msg {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-left: 3px solid #00ccff;
    border-radius: 10px;
    padding: 10px 14px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.astrotkv_msg:hover {
    background: rgba(0, 204, 255, 0.06);
    border-left-color: #00e0ff;
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotkv_msg_head {
    color: var(--text-muted);
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 0.3px;
    padding-bottom: 6px;
    border-bottom: 1px dashed rgba(0, 204, 255, 0.15);
    margin-bottom: 8px;
}
.astrotkv_msg_head b {
    color: #00e0ff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.4);
}
.astrotkv_msg_category {
    color: #ffaa33;
    font-weight: 600;
    font-size: 10px;
    display: inline-block;
    margin-top: 4px;
    padding: 2px 8px;
    background: rgba(255, 170, 51, 0.08);
    border: 1px solid rgba(255, 170, 51, 0.25);
    border-radius: 6px;
    text-shadow: 0 0 6px rgba(255, 170, 51, 0.3);
}
.astrotkv_msg_body {
    color: var(--text-main);
    font-size: 11.5px;
    line-height: 1.5;
    padding: 2px 0;
    word-wrap: break-word;
    white-space: pre-wrap;
}

/* ====== Formulario de respuesta ====== */
.astrotkv_reply_header {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin: 14px 0 10px 0;
    display: block;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}
.astrotkv_reply_label {
    color: var(--text-main);
    font-weight: 600;
    font-size: 11px;
    display: block;
    margin-bottom: 6px;
}
.astrotkv_textarea {
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
.astrotkv_textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astrotkv_submit_row {
    text-align: right;
    padding-top: 10px;
    margin-top: 8px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}
.astrotkv_submit {
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
.astrotkv_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrotkv_submit:active {
    transform: translateY(0);
}

/* ====== Si el ticket está cerrado ====== */
.astrotkv_closed_msg {
    background: rgba(255, 68, 136, 0.06);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 68, 136, 0.35);
    border-radius: 10px;
    padding: 10px 14px;
    color: #ff4488;
    font-size: 11px;
    font-weight: 600;
    text-align: center;
    margin-top: 10px;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrotkv_wrap { padding: 10px; }
    .astrotkv_panel { padding: 12px; max-width: 100%; }
    .astrotkv_msg { padding: 8px 10px; }
    .astrotkv_msg_body { font-size: 11px; }
    .astrotkv_submit { width: 100%; padding: 10px 20px; }
    .astrotkv_submit_row { text-align: center; }
}
</style>

<div class="astrotkv_wrap">

	<form action="game.php?page=ticket&mode=send" method="post" id="form">
		<input type="hidden" name="id" value="{$ticketID}">

		<div class="astrotkv_panel">

			{* ============ TÍTULO DEL TICKET ============ *}
			{foreach $answerList as $answerID => $answerRow}
				{if $answerRow@first}
					<span class="astrotkv_title">🎫 {$LNG.ti_read} : {$answerRow.subject}</span>
				{/if}
			{/foreach}

			{* ============ LISTA DE MENSAJES ============ *}
			{foreach $answerList as $answerID => $answerRow}
			<div class="astrotkv_msg">

				{* Cabecera del mensaje *}
				<div class="astrotkv_msg_head">
					📅 {$LNG.ti_msgtime} <b>{$answerRow.time}</b> &nbsp;·&nbsp; 👤 {$LNG.ti_from} <b>{$answerRow.ownerName}</b>

					{if $answerRow@first}
						<br>
						<span class="astrotkv_msg_category">{$LNG.ti_category}: {$categoryList[$answerRow.categoryID]}</span>
					{/if}
				</div>

				{* Cuerpo del mensaje *}
				<div class="astrotkv_msg_body">{$answerRow.message}</div>

			</div>
			{/foreach}

			{* ============ FORMULARIO DE RESPUESTA (si no está cerrado) ============ *}
			{if $status < 2}
			<span class="astrotkv_reply_header">💬 {$LNG.ti_answer}</span>

			<label for="message" class="astrotkv_reply_label">{$LNG.ti_message}</label>
			<textarea class="validate[required] astrotkv_textarea" id="message" name="message" rows="60" cols="8" style="height:100px;"></textarea>

			<div class="astrotkv_submit_row">
				<input type="submit" value="{$LNG.ti_submit}" class="astrotkv_submit">
			</div>
			{/if}

		</div>

	</form>

</div>

{/block}

{block name="script" append}
<script>
$(document).ready(function() {
	$("#form").validationEngine('attach');
});
</script>
{/block}