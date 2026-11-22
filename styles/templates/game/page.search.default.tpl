{block name="title" prepend}{$LNG.lm_search}{/block}
{block name="content"}

{* ============================================================
   ASTROIO SEARCH v3.0 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrosrch_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Inputs/selects/btn con radius 8px + focus translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: #loading, #type, #searchtext, #result_search intactos
     - ⚠️ CRÍTICO: html_options con class="astrosrch_select" intacto
     - ⚠️ CRÍTICO: botón type="button" sin onclick (JS externo) intacto
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
.astrosrch_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrosrch_panel {
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
.astrosrch_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    gap: 6px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}
#loading {
    color: #ffaa33 !important;
    font-size: 10px;
    font-weight: 600;
    font-style: italic;
}

/* ====== Barra de búsqueda ====== */
.astrosrch_bar {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    margin-bottom: 10px;
    flex-wrap: wrap;
    transition: 0.2s ease;
}
.astrosrch_bar:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

/* Selector de tipo */
.astrosrch_select {
    padding: 7px 28px 7px 12px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    transition: 0.25s ease;
    appearance: none;
    background-image: linear-gradient(45deg, transparent 50%, #00ccff 50%),
                      linear-gradient(135deg, #00ccff 50%, transparent 50%);
    background-position: calc(100% - 14px) center, calc(100% - 9px) center;
    background-size: 5px 5px, 5px 5px;
    background-repeat: no-repeat;
    min-width: 130px;
}
.astrosrch_select:hover,
.astrosrch_select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrosrch_select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}

/* Input de búsqueda */
.astrosrch_input {
    flex-grow: 1;
    min-width: 180px;
    padding: 8px 14px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: inherit;
    font-size: 11.5px;
    font-weight: 600;
    outline: none;
    transition: 0.25s ease;
    box-sizing: border-box;
}
.astrosrch_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrosrch_input::placeholder {
    color: #667788;
    font-style: italic;
}

/* Botón buscar */
.astrosrch_btn {
    display: inline-block;
    padding: 8px 22px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9) 0%, rgba(0, 153, 255, 0.9) 100%);
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
    white-space: nowrap;
}
.astrosrch_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95) 0%, rgba(0, 204, 255, 0.95) 100%);
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrosrch_btn:active {
    transform: translateY(0);
}

/* ====== Contenedor de resultados (AJAX) ====== */
#result_search {
    min-height: 40px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    background: rgba(0, 0, 0, 0.2);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    padding: 10px 12px;
    overflow-x: auto;
    transition: 0.2s ease;
}
#result_search:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrosrch_wrap { padding: 10px; }
    .astrosrch_panel { padding: 12px; max-width: 100%; }
    .astrosrch_bar { flex-direction: column; align-items: stretch; gap: 6px; }
    .astrosrch_select,
    .astrosrch_input,
    .astrosrch_btn { width: 100%; min-width: 0; }
}
</style>

<div class="astrosrch_wrap">

	<div class="astrosrch_panel">

		<span class="astrosrch_section_title">
			🔍 {$LNG.sh_search_in_the_universe}
			<span id="loading" style="display:none;">{$LNG.sh_loading}</span>
		</span>

		{* ============ BARRA DE BÚSQUEDA ============ *}
		<div class="astrosrch_bar">
			{html_options options=$modeSelector name="type" id="type" class="astrosrch_select"}
			<input type="text" name="searchtext" id="searchtext" class="astrosrch_input" placeholder="{$LNG.sh_search_in_the_universe}...">
			<input type="button" value="{$LNG.sh_search}" class="astrosrch_btn">
		</div>

		{* ============ CONTENEDOR DE RESULTADOS (AJAX) ============ *}
		<div id="result_search"></div>

	</div>

</div>

{/block}