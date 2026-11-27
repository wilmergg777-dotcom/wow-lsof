{block name="title" prepend}{$LNG.ti_create_head} - {$LNG.lm_support}{/block}
{block name="content"}

{* ============================================================
   ASTROIO TICKET CREATE v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrotkc_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Inputs/selects/textarea con radius 8px + focus translateY
     - Botón submit con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: validate[required], ids, name, jQuery Validation Engine intactos
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
.astrotkc_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrotkc_panel {
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

/* ====== Título de sección ====== */
.astrotkc_section_title {
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

/* ====== Info de creación (glassmorphism) ====== */
.astrotkc_info {
    background: rgba(0, 204, 255, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.2);
    border-left: 3px solid #00ccff;
    border-radius: 10px;
    padding: 10px 14px;
    margin-bottom: 12px;
    color: var(--text-main);
    font-size: 10.5px;
    line-height: 1.5;
}
.astrotkc_info p {
    margin: 0 0 6px 0;
    padding: 0;
}
.astrotkc_info p:last-child { margin-bottom: 0; }

/* ====== Formulario ====== */
.astrotkc_form_row {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    margin-bottom: 10px;
}
.astrotkc_label {
    color: var(--text-main);
    font-weight: 600;
    font-size: 11px;
    width: 30%;
    padding-top: 8px;
    flex-shrink: 0;
}
.astrotkc_field {
    flex-grow: 1;
    min-width: 0;
}

/* Inputs, selects y textarea */
.astrotkc_input,
.astrotkc_select,
.astrotkc_textarea {
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
.astrotkc_input:focus,
.astrotkc_select:focus,
.astrotkc_textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrotkc_select {
    cursor: pointer;
    font-weight: 700;
}
.astrotkc_select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}
.astrotkc_textarea {
    min-height: 120px;
    resize: vertical;
    font-family: inherit;
}

/* ====== Botón submit ====== */
.astrotkc_submit_row {
    text-align: right;
    padding-top: 10px;
    margin-top: 10px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}
.astrotkc_submit {
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
.astrotkc_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrotkc_submit:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrotkc_wrap { padding: 10px; }
    .astrotkc_panel { padding: 12px; max-width: 100%; }
    .astrotkc_form_row { flex-direction: column; gap: 6px; }
    .astrotkc_label { width: 100%; padding-top: 0; }
    .astrotkc_submit { width: 100%; padding: 10px 20px; }
    .astrotkc_submit_row { text-align: center; }
}
</style>

<div class="astrotkc_wrap">

	<div class="astrotkc_panel">

		<span class="astrotkc_section_title">🎫 {$LNG.ti_create_head}</span>

		<form action="game.php?page=ticket&mode=send" method="post" id="form">
			<input type="hidden" name="id" value="0">

			{* ============ INFO DE CREACIÓN ============ *}
			<div class="astrotkc_info">
				{$LNG.ti_create_info}
			</div>

			{* ============ CATEGORÍA ============ *}
			<div class="astrotkc_form_row">
				<label for="category" class="astrotkc_label">{$LNG.ti_category}</label>
				<div class="astrotkc_field">
					<select id="category" name="category" class="astrotkc_select">
						{html_options options=$categoryList}
					</select>
				</div>
			</div>

			{* ============ ASUNTO ============ *}
			<div class="astrotkc_form_row">
				<label for="subject" class="astrotkc_label">{$LNG.ti_subject}</label>
				<div class="astrotkc_field">
					<input class="validate[required] astrotkc_input" type="text" id="subject" name="subject" size="40" maxlength="255">
				</div>
			</div>

			{* ============ MENSAJE ============ *}
			<div class="astrotkc_form_row">
				<label for="message" class="astrotkc_label">{$LNG.ti_message}</label>
				<div class="astrotkc_field">
					<textarea class="validate[required] astrotkc_textarea" id="message" name="message" row="60" cols="8" style="height:100px;"></textarea>
				</div>
			</div>

			{* ============ BOTÓN SUBMIT ============ *}
			<div class="astrotkc_submit_row">
				<input type="submit" value="{$LNG.ti_submit}" class="astrotkc_submit">
			</div>

		</form>

	</div>

</div>

{/block}

{block name="script" append}
<script>
$(document).ready(function() {
	$("#form").validationEngine('attach');
});
</script>
{/block}