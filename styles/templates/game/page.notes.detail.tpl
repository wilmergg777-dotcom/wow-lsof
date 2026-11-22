{block name="title" prepend}{$LNG.lm_notes}{/block}
{block name="content"}

{* ============================================================
   ASTROIO NOTES DETAIL v2.1 — Estilo FleetTable compacto
   Prefijo CSS: .astrontd_   (aislado, no rompe otros módulos)
   ============================================================ *}

<style>
/* ====== Wrapper ====== */
.astrontd_wrap { width: 100%; padding: 0; box-sizing: border-box; }

/* ====== Panel principal ====== */
.astrontd_panel {
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid rgba(0, 204, 255, 0.25);
    border-radius: 10px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    padding: 10px 14px;
    color: #c8d6e5;
    max-width: 720px;
    margin: 0 auto;
}

/* ====== Título de sección ====== */
.astrontd_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}

/* ====== Filas del formulario ====== */
.astrontd_row {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    margin-bottom: 8px;
}
.astrontd_label {
    color: #c8d6e5;
    font-weight: 600;
    font-size: 11px;
    width: 22%;
    padding-top: 6px;
    flex-shrink: 0;
}
.astrontd_label a {
    color: #66ff99;
    text-decoration: none;
    font-weight: 700;
    font-size: 10.5px;
    padding: 3px 10px;
    border: 1px solid rgba(102, 255, 153, 0.35);
    border-radius: 4px;
    background: rgba(102, 255, 153, 0.05);
    transition: 0.2s ease;
    display: inline-block;
    margin-top: 2px;
}
.astrontd_label a:hover {
    background: rgba(102, 255, 153, 0.2);
    box-shadow: 0 0 8px rgba(102, 255, 153, 0.4);
    color: #ffffff;
}
.astrontd_field {
    flex-grow: 1;
    min-width: 0;
}

/* Contador de caracteres */
.astrontd_counter {
    color: #ffaa33;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 10.5px;
    margin-left: 4px;
}
.astrontd_counter_max {
    color: #8899aa;
    font-size: 10.5px;
}

/* ====== Inputs / Select / Textarea ====== */
.astrontd_input,
.astrontd_select,
.astrontd_textarea {
    width: 100%;
    padding: 6px 10px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 6px;
    color: #ffffff;
    font-family: inherit;
    font-size: 11.5px;
    line-height: 1.4;
    outline: none;
    transition: 0.2s ease;
    box-sizing: border-box;
}
.astrontd_input:focus,
.astrontd_select:focus,
.astrontd_textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.55);
}
.astrontd_select {
    cursor: pointer;
    font-weight: 700;
    max-width: 200px;
}
.astrontd_select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}
.astrontd_textarea {
    min-height: 100px;
    resize: vertical;
    font-family: inherit;
}

/* ====== Botones footer ====== */
.astrontd_footer {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    padding-top: 10px;
    margin-top: 10px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}
.astrontd_save_btn {
    display: inline-block;
    padding: 6px 26px;
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    border: 1px solid #00ccff;
    border-radius: 6px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11.5px;
    cursor: pointer;
    transition: 0.2s ease;
    letter-spacing: 0.4px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 3px 10px rgba(0, 102, 204, 0.4);
    text-transform: uppercase;
}
.astrontd_save_btn:hover {
    background: linear-gradient(135deg, #0099ff 0%, #00ccff 100%);
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-1px);
}
.astrontd_reset_btn {
    display: inline-block;
    padding: 6px 22px;
    background: rgba(255, 170, 51, 0.08);
    border: 1px solid rgba(255, 170, 51, 0.4);
    border-radius: 6px;
    color: #ffaa33;
    font-weight: 700;
    font-size: 11.5px;
    cursor: pointer;
    transition: 0.2s ease;
    letter-spacing: 0.4px;
    font-family: inherit;
    text-transform: uppercase;
}
.astrontd_reset_btn:hover {
    background: rgba(255, 170, 51, 0.2);
    box-shadow: 0 0 12px rgba(255, 170, 51, 0.5);
    color: #ffffff;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrontd_panel { padding: 8px 10px; max-width: 100%; }
    .astrontd_row { flex-direction: column; gap: 4px; }
    .astrontd_label { width: 100%; padding-top: 0; }
    .astrontd_save_btn,
    .astrontd_reset_btn {
        width: 100%;
        padding: 6px 16px;
    }
    .astrontd_footer { flex-direction: column-reverse; }
    .astrontd_select { max-width: 100%; }
}
</style>

<div class="astrontd_wrap">

	<div class="astrontd_panel">

		<span class="astrontd_section_title">
			{if $noteDetail.id == 0}📝 {$LNG.nt_create_note}{else}✏ {$LNG.nt_edit_note}{/if}
		</span>

		<form action="?page=notes&amp;mode=insert" method="post">
			<input type="hidden" name="id" value="{$noteDetail.id}">

			{* ============ PRIORIDAD ============ *}
			<div class="astrontd_row">
				<label for="priority" class="astrontd_label">{$LNG.nt_priority}</label>
				<div class="astrontd_field">
					{html_options id=priority name=priority options=$PriorityList selected=$noteDetail.priority class="astrontd_select"}
				</div>
			</div>

			{* ============ ASUNTO ============ *}
			<div class="astrontd_row">
				<label for="title" class="astrontd_label">{$LNG.nt_subject_note}</label>
				<div class="astrontd_field">
					<input type="text" id="title" name="title" size="30" maxlength="30" value="{$noteDetail.title}" class="astrontd_input">
				</div>
			</div>

			{* ============ NOTA (TEXTO) ============ *}
			<div class="astrontd_row">
				<label for="text" class="astrontd_label">
					{$LNG.nt_note}
					<span class="astrontd_counter" id="cntChars">0</span><span class="astrontd_counter_max">&nbsp;/&nbsp;5.000&nbsp;{$LNG.nt_characters}</span>
				</label>
				<div class="astrontd_field">
					<textarea name="text" id="text" cols="60" rows="10" onkeyup="$('#cntChars').text($(this).val().length);" class="astrontd_textarea">{$noteDetail.text}</textarea>
				</div>
			</div>

			{* ============ FOOTER: VOLVER + RESET + GUARDAR ============ *}
			<div class="astrontd_footer">
				<div style="flex-grow:1; align-self:center;">
					<a href="game.php?page=notes" class="astrontd_label" style="padding:0;">
						<span style="display:inline-block;color:#66ff99;text-decoration:none;font-weight:700;font-size:10.5px;padding:3px 10px;border:1px solid rgba(102,255,153,0.35);border-radius:4px;background:rgba(102,255,153,0.05);">← {$LNG.nt_back}</span>
					</a>
				</div>
				<input type="reset" value="{$LNG.nt_reset}" class="astrontd_reset_btn">
				<input type="submit" value="{$LNG.nt_save}" class="astrontd_save_btn">
			</div>

		</form>

	</div>

</div>

{/block}