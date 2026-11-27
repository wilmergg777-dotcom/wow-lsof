{block name="title" prepend}{$LNG.lm_statistics}{/block}
{block name="content"}

{* ============================================================
   ASTROIO STATISTICS v3.2 — Colores Fuerte (Rojo) y Débil (Verde)
   Prefijo CSS: .astrostat_
   FIX v3.2:
     - Fuerte ahora es Rojo (#ff4444) para coincidir con la lógica visual.
     - Débil ahora es Verde (#66ff99).
     - Se mantienen las clases y la estructura intacta.
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
.astrostat_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrostat_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 900px;
    margin: 0 auto;
}

/* ====== Título de sección ====== */
.astrostat_section_title {
    color: #ffaa33;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(255, 170, 51, 0.25);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(255, 170, 51, 0.3);
}

/* ====== Formulario de filtros ====== */
.astrostat_form {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    margin-bottom: 10px;
    transition: 0.2s ease;
}
.astrostat_form:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

.astrostat_filter {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 10.5px;
    color: var(--text-main);
    font-weight: 600;
}
.astrostat_filter label {
    color: var(--text-muted);
    font-weight: 700;
    letter-spacing: 0.3px;
}

/* Selects */
.astrostat_select {
    padding: 5px 24px 5px 10px;
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
    background-position: calc(100% - 12px) center, calc(100% - 7px) center;
    background-size: 5px 5px, 5px 5px;
    background-repeat: no-repeat;
    min-width: 90px;
}
.astrostat_select:hover,
.astrostat_select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrostat_select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}

/* ====== Contenedor de la tabla de resultados ====== */
.astrostat_results {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    padding: 4px;
    transition: 0.2s ease;
}
.astrostat_results:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

/* ====== Estilos para las sub-tablas incluidas ====== */
.astrostat_results table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
    table-layout: fixed;
}

/* ============================================================ */
/* ====== Cabecera - SIN fondo azul, alineada con datos ====== */
/* ============================================================ */
.astrostat_results table thead tr,
.astrostat_results table tr.title,
.astrostat_results table tr:first-child {
    background: rgba(0, 0, 0, 0.35);
}
.astrostat_results table thead th,
.astrostat_results table tr.title th,
.astrostat_results table tr:first-child th {
    padding: 6px 6px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: left;
    color: #00e0ff;
    border-bottom: 1px solid rgba(0, 204, 255, 0.4);
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.4);
    white-space: nowrap;
    vertical-align: middle;
}

/* ============================================================ */
/* ====== CABECERAS: ANCHOS Y ESPACIADO POR COLUMNA ========= */
/* ============================================================ */

/* ─── Columna 1: POSICIÓN ─── */
.astrostat_results table thead th:nth-child(1),
.astrostat_results table tr.title th:nth-child(1),
.astrostat_results table tr:first-child th:nth-child(1) {
    text-align: center;
    width: 70px;
    padding-left: 15px;
    padding-right: 15px;
}

/* ─── Columna 2: JUGADOR ─── */
.astrostat_results table thead th:nth-child(2),
.astrostat_results table tr.title th:nth-child(2),
.astrostat_results table tr:first-child th:nth-child(2) {
    text-align: left;
    width: auto;
    padding-left: 20px;
    padding-right: 20px;
}

/* ─── Columna 3: ENVIAR ─── */
.astrostat_results table thead th:nth-child(3),
.astrostat_results table tr.title th:nth-child(3),
.astrostat_results table tr:first-child th:nth-child(3) {
    text-align: center;
    width: 90px;
    padding-left: 25px;
    padding-right: 25px;
}

/* ─── Columna 4: ALIANZA ─── */
.astrostat_results table thead th:nth-child(4),
.astrostat_results table tr.title th:nth-child(4),
.astrostat_results table tr:first-child th:nth-child(4) {
    text-align: left;
    width: 170px;
    padding-left: 40px;
    padding-right: 20px;
}

/* ─── Columna 5: PUNTOS ─── */
.astrostat_results table thead th:nth-child(5),
.astrostat_results table tr.title th:nth-child(5),
.astrostat_results table tr:first-child th:nth-child(5) {
    text-align: right;
    width: 120px;
    padding-left: 20px;
    padding-right: 15px;
}

/* Filas */
.astrostat_results table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrostat_results table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrostat_results table tbody td {
    padding: 4px 6px;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.3;
    word-break: break-word;
}

/* ============================================================ */
/* ====== BODY: ANCHOS Y ESPACIADO POR COLUMNA ============== */
/* ============================================================ */

/* ─── Columna 1: POSICIÓN ─── */
.astrostat_results table tbody td:nth-child(1) {
    text-align: center;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #ffaa33;
    width: 70px;
    padding-left: 15px;
    padding-right: 15px;
}

/* ─── Columna 2: JUGADOR ─── */
.astrostat_results table tbody td:nth-child(2) {
    text-align: left;
    width: auto;
    padding-left: 20px;
    padding-right: 20px;
}

/* ─── Columna 3: ENVIAR ─── */
.astrostat_results table tbody td:nth-child(3) {
    text-align: center;
    width: 90px;
    padding-left: 25px;
    padding-right: 25px;
}

/* ─── Columna 4: ALIANZA ─── */
.astrostat_results table tbody td:nth-child(4) {
    text-align: left;
    width: 170px;
    padding-left: 40px;
    padding-right: 20px;
}

/* ─── Columna 5: PUNTOS ─── */
.astrostat_results table tbody td:nth-child(5) {
    text-align: right;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: #66ff99;
    width: 120px;
    padding-left: 20px;
    padding-right: 15px;
}

/* Enlaces genéricos */
.astrostat_results table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrostat_results table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* Flechas de movimiento de rango */
.astrostat_results .up,
.astrostat_results .true {
    color: #66ff99 !important;
    font-weight: 700;
}
.astrostat_results .down,
.astrostat_results .false {
    color: #ff4488 !important;
    font-weight: 700;
}

/* ============================================================ */
/* ====== ⭐ Marca VIP ======================================== */
/* ============================================================ */
.astrostat_vip_star {
    display: inline-block;
    margin-left: 5px;
    font-size: 13px;
    color: #ffcc00;
    cursor: help;
    text-shadow: 0 0 6px rgba(255, 204, 0, 0.8);
    animation: astrostat_vip_glow 1.6s ease-in-out infinite alternate;
    vertical-align: middle;
    line-height: 1;
}
@keyframes astrostat_vip_glow {
    from { text-shadow: 0 0 4px rgba(255, 204, 0, 0.6); filter: brightness(0.95); }
    to   { text-shadow: 0 0 12px rgba(255, 204, 0, 1); filter: brightness(1.15); }
}

/* ============================================================ */
/* ====== ✉️ Botón Enviar mensaje ============================ */
/* ============================================================ */
.astrostat_pm_btn {
    display: inline-block;
    font-size: 16px;
    color: #00e0ff;
    text-decoration: none;
    cursor: pointer;
    transition: 0.2s ease;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.5);
    vertical-align: middle;
    line-height: 1;
}
.astrostat_pm_btn:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 1);
    transform: scale(1.15);
}

/* ════════════════════════════════════════════════════════════ */
/* ═══ COLORES POR RELACIÓN DIPLOMÁTICA ══════════════════════ */
/* ════════════════════════════════════════════════════════════ */

/* 🟢 Yo mismo (verde lima brillante) */
.astrostat_results table tbody td:nth-child(2) a.rel_yo {
    color: #66ff99 !important;
    font-weight: 800;
    text-shadow: 0 0 8px rgba(102, 255, 153, 0.5);
}

/* 🟢 Mi alianza (verde) */
.astrostat_results table tbody td:nth-child(2) a.rel_misma_alianza {
    color: #33ff88 !important;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(51, 255, 136, 0.4);
}

/* 🔵 Amigo (cyan) */
.astrostat_results table tbody td:nth-child(2) a.rel_amigo {
    color: #00e0ff !important;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.4);
}

/* 🔴 Guerra (rojo) */
.astrostat_results table tbody td:nth-child(2) a.rel_guerra {
    color: #ff4444 !important;
    font-weight: 800;
    text-shadow: 0 0 8px rgba(255, 68, 68, 0.6);
}

/* 🟡 No agresión / NAP (dorado) */
.astrostat_results table tbody td:nth-child(2) a.rel_nap {
    color: #ffcc00 !important;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(255, 204, 0, 0.5);
}

/* ⚪ Neutral (blanco) */
.astrostat_results table tbody td:nth-child(2) a.rel_default {
    color: #ffffff !important;
    font-weight: 600;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
}

/* 🔴 FUERTE (F) - Rojo puro */
.astrostat_results table tbody td:nth-child(2) a.rel_fuerte {
    color: #ff4444 !important;
    font-weight: 800;
    text-shadow: 0 0 8px rgba(255, 68, 68, 0.6);
}

/* 🟢 DÉBIL (D) - Verde puro */
.astrostat_results table tbody td:nth-child(2) a.rel_debil {
    color: #66ff99 !important;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.5);
}

/* Hover universal: siempre ilumina en cyan */
.astrostat_results table tbody td:nth-child(2) a:hover {
    color: #00ffff !important;
    text-shadow: 0 0 10px rgba(0, 255, 255, 1) !important;
}

/* ─── Leyenda de colores ─── */
.astrostat_legend {
    display: flex;
    flex-wrap: wrap;
    gap: 14px;
    padding: 10px 12px;
    margin-top: 10px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    font-size: 10.5px;
    justify-content: center;
    align-items: center;
    transition: 0.2s ease;
}
.astrostat_legend:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrostat_legend_item {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    color: var(--text-main);
    font-weight: 600;
}
.astrostat_legend_dot {
    display: inline-block;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    box-shadow: 0 0 6px currentColor;
}
.astrostat_legend_dot.yo      { background: #66ff99; color: #66ff99; }
.astrostat_legend_dot.misma   { background: #33ff88; color: #33ff88; }
.astrostat_legend_dot.amigo   { background: #00e0ff; color: #00e0ff; }
.astrostat_legend_dot.guerra  { background: #ff4444; color: #ff4444; }
.astrostat_legend_dot.nap     { background: #ffcc00; color: #ffcc00; }
.astrostat_legend_dot.default { background: #ffffff; color: #ffffff; }
.astrostat_legend_dot.fuerte  { background: #ff4444; color: #ff4444; }
.astrostat_legend_dot.debil   { background: #66ff99; color: #66ff99; }

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrostat_wrap { padding: 10px; }
    .astrostat_panel { padding: 12px; max-width: 100%; }
    .astrostat_form { flex-direction: column; align-items: stretch; }
    .astrostat_filter { justify-content: space-between; }
    .astrostat_select { width: 100%; }
    .astrostat_results table { font-size: 10px; }
    .astrostat_results table tbody td { padding: 3px 4px; }
    .astrostat_vip_star { font-size: 12px; }
    .astrostat_pm_btn { font-size: 14px; }
    .astrostat_legend { gap: 8px; font-size: 9.5px; }

    .astrostat_results table thead th:nth-child(4),
    .astrostat_results table tbody td:nth-child(4) {
        padding-left: 15px;
        width: 110px;
    }
    .astrostat_results table thead th:nth-child(3),
    .astrostat_results table tbody td:nth-child(3) {
        width: 55px;
        padding-left: 8px;
        padding-right: 8px;
    }
    .astrostat_results table thead th:nth-child(2),
    .astrostat_results table tbody td:nth-child(2) {
        padding-left: 10px;
        padding-right: 10px;
    }
}
</style>

<div class="astrostat_wrap">

	<div class="astrostat_panel">

		<span class="astrostat_section_title">
			📊 {$LNG.st_statistics} ({$LNG.st_updated}: {$stat_date})
		</span>

		{* ============ FORMULARIO DE FILTROS ============ *}
		<form name="stats" id="stats" method="post" action="">

			<div class="astrostat_form">

				<div class="astrostat_filter">
					<label for="who">{$LNG.st_show}</label>
					<select name="who" id="who" onchange="$('#stats').submit();" class="astrostat_select">
						{html_options options=$Selectors.who selected=$who}
					</select>
				</div>

				<div class="astrostat_filter">
					<label for="type">{$LNG.st_per}</label>
					<select name="type" id="type" onchange="$('#stats').submit();" class="astrostat_select">
						{html_options options=$Selectors.type selected=$type}
					</select>
				</div>

				<div class="astrostat_filter">
					<label for="range">{$LNG.st_in_the_positions}</label>
					<select name="range" id="range" onchange="$('#stats').submit();" class="astrostat_select">
						{html_options options=$Selectors.range selected=$range}
					</select>
				</div>

			</div>

		</form>

		{* ============ TABLA DE RESULTADOS ============ *}
		<div class="astrostat_results">

			{if $who == 1}
				{include file="shared.statistics.playerTable.tpl"}
			{elseif $who == 2}
				{include file="shared.statistics.allianceTable.tpl"}
			{/if}

		</div>

		{* ============ LEYENDA DE COLORES (solo jugadores) ============ *}
		{if $who == 1}
		<div class="astrostat_legend">
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot yo"></span> Yo</span>
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot misma"></span> Mi alianza</span>
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot amigo"></span> Amigo</span>
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot guerra"></span> Guerra</span>
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot nap"></span> No agresión</span>
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot default"></span> Neutral</span>
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot fuerte"></span> Fuerte (F)</span>
			<span class="astrostat_legend_item"><span class="astrostat_legend_dot debil"></span> Débil (D)</span>
		</div>
		{/if}

	</div>

</div>

{/block}