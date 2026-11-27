{block name="title" prepend}{$LNG.lm_faq}{/block}
{block name="content"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO FAQ (default) v3.0 — Estilo Xnova (glassmorphism)
   Prefijo: .astrofaq_
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado vía overrides !important (core .content_page / .title)
     - Estilos extendidos para h2, ul, li, a del índice
     - ⚠️ CRÍTICO: {foreach $LNG.questions} + {if is_numeric($questionID)} intactos
     - ⚠️ CRÍTICO: href categoryID/questionID + class="left" intactos
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
    font-size: 11px !important;
    overflow: hidden !important;
}

.content_page table td {
    padding: 18px 24px !important;
    color: var(--text-main) !important;
    vertical-align: top !important;
}

.content_page table td.left {
    text-align: left !important;
}

/* ====== H2 (Título de categoría: Consejos, Info Avanzada, etc.) ====== */
.content_page table h2 {
    color: var(--accent-cyan) !important;
    font-weight: 700 !important;
    font-size: 14px !important;
    letter-spacing: 0.8px !important;
    text-transform: uppercase !important;
    margin: 16px 0 10px 0 !important;
    padding-bottom: 6px !important;
    border-bottom: 1px solid rgba(0, 204, 255, 0.25) !important;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.4) !important;
}
.content_page table h2:first-child {
    margin-top: 0 !important;
}

/* ====== Listas (ul) ====== */
.content_page table ul {
    list-style: none !important;
    padding: 0 !important;
    margin: 0 0 12px 0 !important;
}

/* ====== Items de lista (li) ====== */
.content_page table li {
    margin: 0 !important;
    padding: 0 !important;
}

/* ====== Enlaces (preguntas) ====== */
.content_page table ul a {
    display: block !important;
    padding: 8px 14px !important;
    background: rgba(0, 0, 0, 0.3) !important;
    backdrop-filter: blur(4px) !important;
    -webkit-backdrop-filter: blur(4px) !important;
    border: 1px solid rgba(0, 204, 255, 0.15) !important;
    border-radius: 8px !important;
    color: var(--text-main) !important;
    text-decoration: none !important;
    font-weight: 600 !important;
    font-size: 12px !important;
    margin-bottom: 6px !important;
    transition: 0.25s ease !important;
    position: relative !important;
    overflow: hidden !important;
}

.content_page table ul a::before {
    content: '' !important;
    position: absolute !important;
    left: 0 !important;
    top: 0 !important;
    height: 100% !important;
    width: 3px !important;
    background: var(--accent-cyan) !important;
    transform: scaleY(0) !important;
    transform-origin: center !important;
    transition: transform 0.25s ease !important;
}

.content_page table ul a:hover {
    background: rgba(0, 204, 255, 0.1) !important;
    border-color: rgba(0, 204, 255, 0.5) !important;
    color: #ffffff !important;
    transform: translateX(4px) !important;
    box-shadow: 0 3px 10px rgba(0, 224, 255, 0.3) !important;
    padding-left: 18px !important;
}

.content_page table ul a:hover::before {
    transform: scaleY(1) !important;
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .content_page { padding: 10px; }
    .content_page table td { padding: 14px 16px !important; }
    .content_page table h2 { font-size: 13px !important; }
    .content_page table ul a { font-size: 11px !important; padding: 7px 12px !important; }
}
</style>

<div class="content_page">
	<div class="title">
		{$LNG.faq_overview}
	</div>

	<div>
		<table style="width: 100%;">
			<tr>
				<td class="left">{foreach $LNG.questions as $categoryID => $categoryRow}<h2>{$categoryRow.category}</h2>
				<ul>
				{foreach $categoryRow as $questionID => $questionRow}
				{if is_numeric($questionID)}
					<li><a href="game.php?page=questions&amp;mode=single&amp;categoryID={$categoryID}&amp;questionID={$questionID}">{$questionRow.title}</a></li>
				{/if}
				{/foreach}
				</ul>
				{/foreach}</td>
			</tr>
		</table>
	</div>
</div>
{/block}