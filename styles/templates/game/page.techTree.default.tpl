{block name="title" prepend}{$LNG.lm_technology}{/block}
{block name="content"}

{* ============================================================
   ASTROIO TECHTREE v3.7 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrotech_   (aislado, no rompe otros módulos)
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.7:
     - Se restauró Dialog.info() para mostrar las tablas de estadísticas.
     - El modal ahora acepta el contenido AJAX original (edificios, naves, defensas).
     - Se añadieron reglas CSS para que las tablas dentro del modal se vean oscuras.
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
.astrotech_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrotech_panel {
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

/* ====== Título de sección (acento púrpura) ====== */
.astrotech_section_title {
    color: #aa44ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(170, 68, 255, 0.25);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(170, 68, 255, 0.35);
}

/* ====== Contenedor de la tabla ====== */
#result_search {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(170, 68, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    text-align: left !important;
    transition: 0.2s ease;
}
#result_search:hover {
    border-color: rgba(170, 68, 255, 0.3);
}

/* ====== Tabla ====== */
.astrotech_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* ====== Cabeceras de categoría (Recursos, Edificios, etc.) ====== */
.astrotech_table tr.astrotech_cat {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astrotech_table tr.astrotech_cat th {
    padding: 6px 10px;
    font-weight: 700;
    font-size: 10.5px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    text-align: center;
    color: #ffffff;
    border-top: 2px solid var(--accent-purple);
    border-bottom: 1px solid var(--accent-purple);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astrotech_table tr.astrotech_cat th:first-child {
    text-align: left;
    padding-left: 12px;
    color: #cc88ff;
}
.astrotech_table tr.astrotech_cat th:last-child {
    text-align: left;
    padding-left: 12px;
}

/* ====== Filas de tecnologías ====== */
.astrotech_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(170, 68, 255, 0.06);
    transition: 0.15s ease;
}
.astrotech_table tbody tr:hover {
    background: rgba(170, 68, 255, 0.07);
}
.astrotech_table tbody td {
    padding: 5px 8px;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.3;
    word-break: break-word;
}

/* Columna imagen */
.astrotech_table tbody td:first-child {
    width: 55px;
    text-align: center;
}

/* Columna nombre */
.astrotech_table tbody td:nth-child(2) {
    width: 28%;
}

/* Columna requisitos */
.astrotech_table tbody td:nth-child(3) {
    width: auto;
    text-align: left;
    padding-left: 12px;
}

/* ====== Imagen del elemento ====== */
.astrotech_table tbody td:first-child a {
    display: inline-block;
}
.astrotech_table tbody td:first-child img {
    width: 40px;
    height: 40px;
    border-radius: 6px;
    border: 1px solid rgba(170, 68, 255, 0.3);
    transition: 0.25s ease;
    display: block;
}
.astrotech_table tbody td:first-child a:hover img {
    border-color: #aa44ff;
    box-shadow: 0 0 12px rgba(170, 68, 255, 0.55);
    transform: scale(1.08);
}

/* ====== Nombre del elemento ====== */
.astrotech_table tbody td:nth-child(2) a {
    color: #aa44ff;
    text-decoration: none;
    font-weight: 700;
    font-size: 11px;
    transition: 0.15s ease;
}
.astrotech_table tbody td:nth-child(2) a:hover {
    color: #ffffff;
    text-shadow: 0 0 8px rgba(170, 68, 255, 0.95);
}

/* ====== Requisitos ====== */
.astrotech_table tbody td:nth-child(3) a {
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
    display: inline-block;
}
.astrotech_table tbody td:nth-child(3) a span {
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 10px;
}
.astrotech_table tbody td:nth-child(3) a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.9);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrotech_wrap { padding: 10px; }
    .astrotech_panel { padding: 12px; max-width: 100%; }
    .astrotech_table { font-size: 10px; }
    .astrotech_table tbody td { padding: 4px 5px; }
    .astrotech_table tbody td:first-child { width: 45px; }
    .astrotech_table tbody td:first-child img { width: 32px; height: 32px; }
    .astrotech_table tr.astrotech_cat th { padding: 5px 8px; font-size: 10px; }
}

/* ============================================================
   ASTROIO v3.7 — ESTILO MODAL NATIVO (AJAX)
   ============================================================ */
.ui-dialog {
    background: rgba(15, 23, 42, 0.95) !important;
    backdrop-filter: blur(10px) !important;
    -webkit-backdrop-filter: blur(10px) !important;
    border: 1px solid rgba(139, 92, 246, 0.6) !important;
    border-radius: 12px !important;
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.8) !important;
    padding: 0 !important;
    overflow: hidden;
}
.ui-dialog-titlebar {
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.9)) !important;
    border-bottom: 1px solid rgba(139, 92, 246, 0.4) !important;
    border-radius: 12px 12px 0 0 !important;
    color: #cc88ff !important;
    font-weight: 700;
    padding: 10px 15px !important;
}
.ui-dialog-titlebar-close {
    background: transparent !important;
    border: none !important;
    color: #94a3b8 !important;
}
.ui-dialog-titlebar-close:hover {
    color: #ef4444 !important;
}
.ui-dialog-content {
    background: transparent !important;
    color: #cbd5e1 !important;
    padding: 15px !important;
    font-size: 13px;
    line-height: 1.6;
}

/* ====== Fix para las Tablas que inyecta AJAX dentro del Modal ====== */
.ui-dialog-content table {
    width: 100% !important;
    border-collapse: collapse !important;
    background: transparent !important;
    margin-top: 5px;
}
.ui-dialog-content th,
.ui-dialog-content td {
    border: 1px solid rgba(139, 92, 246, 0.25) !important;
    padding: 6px 10px !important;
    color: #cbd5e1 !important;
    background: rgba(0, 0, 0, 0.2) !important;
    font-size: 12px;
}
.ui-dialog-content th {
    color: #cc88ff !important;
    background: rgba(15, 23, 42, 0.8) !important;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 11px;
}
.ui-dialog-content img {
    border-radius: 6px;
    border: 1px solid rgba(139, 92, 246, 0.4);
    max-width: 100%;
    height: auto;
}
.ui-dialog-content p, 
.ui-dialog-content span {
    color: #cbd5e1 !important;
}
/* ============================================================ */
</style>

<div class="astrotech_wrap">

	<div class="astrotech_panel">

		<span class="astrotech_section_title">🧪 {$LNG.lm_technology}</span>

		<div id="result_search">
			<table class="astrotech_table">
				<tbody>
				{foreach $TechTreeList as $elementID => $requireList}
					{if !is_array($requireList)}
					<tr class="astrotech_cat">
						<th colspan="2">{$LNG.tech.$requireList}</th>
						<th>{$LNG.tt_requirements}</th>
					</tr>
					{else}
					<tr>
						<td>
							<a href="#" onclick="return Dialog.info({$elementID})">
								<img src="{$dpath}gebaeude/{$elementID}.{if $elementID >=600 && $elementID <= 699}jpg{else}gif{/if}" alt="">
							</a>
						</td>
						<td>
							<a href="#" onclick="return Dialog.info({$elementID})">{$LNG.tech.$elementID}</a>
						</td>
						<td>
							{if $requireList}
								{foreach $requireList as $requireID => $NeedLevel}
									<a href="#" onclick="return Dialog.info({$elementID})"><span style="color:{if $NeedLevel.own < $NeedLevel.count}#ff4488{else}#66ff99{/if};">{$LNG.tech.$requireID} ({$LNG.tt_lvl} {min($NeedLevel.count, $NeedLevel.own)}/{$NeedLevel.count})</span></a>{if !$NeedLevel@last}<br>{/if}
								{/foreach}
							{/if}
						</td>
					</tr>
					{/if}
				{/foreach}
				</tbody>
			</table>
		</div>

	</div>

</div>

{/block}