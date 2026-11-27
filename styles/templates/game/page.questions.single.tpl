{block name="title" prepend}{$LNG.lm_faq}{/block}
{block name="content"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO FAQ (single) v3.0 — Estilo Xnova (glassmorphism)
   Prefijo: .astrofaq_
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado vía overrides !important (core .content_page / .title)
     - Estilos extendidos para th, td, a (botón volver)
     - ⚠️ CRÍTICO: {$questionRow.title} + {$questionRow.body} intactos
     - ⚠️ CRÍTICO: href game.php?page=questions intacto
     - ⚠️ CRÍTICO: tr class="title" + td.left intactos
   ══════════════════════════════════════════════════════════════ *}

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

/* ====== Override content_page (admin) ====== */
.content_page {
    color: var(--text-main);
    max-width: 900px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Título principal ====== */
.content_page > .title {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: 1px solid var(--border-color) !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    border-radius: 12px 12px 0 0 !important;
    color: #ffffff !important;
    padding: 12px 16px !important;
    font-weight: 700 !important;
    font-size: 13px !important;
    letter-spacing: 0.8px !important;
    text-transform: uppercase !important;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4), 0 0 10px rgba(0, 224, 255, 0.4) !important;
}

/* ====== Tabla ====== */
.content_page table {
    background: var(--bg-card) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: 1px solid var(--border-color) !important;
    border-top: none !important;
    border-radius: 0 0 12px 12px !important;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    width: 100% !important;
    border-collapse: collapse !important;
    font-size: 12px !important;
    overflow: hidden !important;
}

/* ====== Fila con class="title" (título de la pregunta) ====== */
.content_page table tr.title th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.6), rgba(0, 119, 204, 0.6)) !important;
    color: #ffffff !important;
    font-weight: 800 !important;
    font-size: 14px !important;
    letter-spacing: 0.6px !important;
    padding: 16px 24px !important;
    text-align: left !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.35) !important;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5), 0 0 12px rgba(0, 224, 255, 0.4) !important;
}

/* ====== Celdas de contenido ====== */
.content_page table td {
    padding: 18px 24px !important;
    color: var(--text-main) !important;
    vertical-align: top !important;
    line-height: 1.6 !important;
    font-size: 12px !important;
}

.content_page table td.left {
    text-align: left !important;
}

/* ====== Enlaces internos del body (si los hay) ====== */
.content_page table td a {
    color: var(--accent-cyan) !important;
    text-decoration: none !important;
    font-weight: 600 !important;
    transition: 0.2s ease !important;
    border-bottom: 1px dashed rgba(0, 224, 255, 0.4) !important;
}
.content_page table td a:hover {
    color: #ffffff !important;
    border-bottom-color: var(--accent-cyan) !important;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.6) !important;
}

/* ====== Fila final: botón Volver (último th con <a>) ====== */
.content_page table tr:last-child th {
    background: rgba(0, 0, 0, 0.35) !important;
    border-top: 1px solid rgba(0, 224, 255, 0.2) !important;
    padding: 12px 24px !important;
    text-align: right !important;
}

.content_page table tr:last-child th a {
    display: inline-block !important;
    padding: 8px 20px !important;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 102, 204, 0.9)) !important;
    border: 1px solid rgba(0, 204, 255, 0.6) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    letter-spacing: 0.6px !important;
    text-transform: uppercase !important;
    text-decoration: none !important;
    transition: 0.25s ease !important;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4) !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
}

.content_page table tr:last-child th a:hover {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 153, 255, 0.95)) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6) !important;
    transform: translateY(-2px) !important;
    border-color: var(--accent-cyan) !important;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .content_page { padding: 10px; }
    .content_page table td { padding: 14px 16px !important; font-size: 11px !important; }
    .content_page table tr.title th { font-size: 13px !important; padding: 12px 16px !important; }
    .content_page table tr:last-child th { padding: 10px 16px !important; }
    .content_page table tr:last-child th a { width: 100% !important; text-align: center !important; padding: 10px !important; }
}
</style>

<div class="content_page">
	<div class="title">
		{$LNG.faq_overview}
	</div>

	<div>
		<table style="width: 100%;">
			<tr class="title">
				<th>{$questionRow.title}</th>
			</tr>
			<tr>
				<td class="left">
				{$questionRow.body}
				</td>
			</tr>
			<tr><th><a href="game.php?page=questions">{$LNG.al_back}</a></th>
			</tr>
		</table>
	</div>
</div>
{/block}