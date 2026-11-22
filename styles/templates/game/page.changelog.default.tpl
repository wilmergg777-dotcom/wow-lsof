{block name="title" prepend}{$LNG.lm_changelog}{/block}
{block name="content"}
{* ============================================================
   ASTROIO - Changelog con estilo moderno v3.0
   Glassmorphism + cyan
   ============================================================ *}

<style>
/* ============================================================== */
/* ============ ASTROIO - CHANGELOG ESTILO v3.0 ================= */
/* ============ Glassmorphism + acento cyan (#00e0ff) =========== */
/* ============================================================== */

:root {
	--bg-dark:      rgba(11, 16, 30, 0.55);
	--bg-card:      rgba(15, 23, 42, 0.75);
	--bg-card-hover:rgba(30, 41, 59, 0.85);
	--bg-inner:     rgba(0, 0, 0, 0.35);
	--border-color: #1e293b;
	--text-main:    #cbd5e1;
	--text-muted:   #94a3b8;
	--text-title:   #ffffff;
	--accent-blue:  #3b82f6;
	--accent-cyan:  #00e0ff;
	--accent-purple:#8b5cf6;
	--accent-gold:  #fbbf24;
	--accent-green: #4aff88;
	--accent-red:   #ef4444;
}

.content_page {
	padding: 10px !important;
}

/* ---------- Título de la página — Glassmorphism ---------- */
.content_page > .title {
	background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.75)) !important;
	backdrop-filter: blur(6px) !important;
	-webkit-backdrop-filter: blur(6px) !important;
	border: 1px solid rgba(0, 224, 255, 0.4) !important;
	border-left: 4px solid var(--accent-cyan) !important;
	border-radius: 12px !important;
	padding: 14px 20px !important;
	margin-bottom: 18px !important;
	text-align: center !important;
	color: #ffffff !important;
	font-size: 22px !important;
	font-weight: 800 !important;
	letter-spacing: 2px !important;
	text-transform: uppercase !important;
	text-shadow: 0 2px 8px rgba(0, 0, 0, 0.7), 0 0 20px rgba(0, 224, 255, 0.5) !important;
	box-shadow: 0 6px 24px rgba(0, 0, 0, 0.5), 0 0 30px rgba(0, 224, 255, 0.15) !important;
	position: relative !important;
	overflow: hidden !important;
}

.content_page > .title::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 2px;
	background: linear-gradient(90deg, transparent, #00e0ff, transparent);
}

/* ---------- Contenedor del changelog — Glassmorphism ---------- */
.content_page > div:has(> table) {
	background: var(--bg-card) !important;
	backdrop-filter: blur(6px) !important;
	-webkit-backdrop-filter: blur(6px) !important;
	border: 1px solid var(--border-color) !important;
	border-radius: 12px !important;
	padding: 20px 25px !important;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
	color: var(--text-main) !important;
	font-family: 'Segoe UI', Roboto, sans-serif !important;
	font-size: 13px !important;
	line-height: 1.6 !important;
}

.content_page > div > table {
	width: 100% !important;
	border-collapse: collapse !important;
	background: transparent !important;
}

.content_page > div > table td {
	padding: 0 !important;
	color: var(--text-main) !important;
	background: transparent !important;
}

/* ---------- Contenido HTML del changelog ---------- */

/* H3 — Títulos de versión */
.content_page > div > table td h3 {
	background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.75)) !important;
	backdrop-filter: blur(6px) !important;
	-webkit-backdrop-filter: blur(6px) !important;
	color: #ffffff !important;
	padding: 12px 18px !important;
	border-radius: 10px !important;
	margin: 24px 0 14px 0 !important;
	font-size: 15px !important;
	font-weight: 800 !important;
	letter-spacing: 1px !important;
	border: 1px solid rgba(0, 224, 255, 0.4) !important;
	border-left: 4px solid var(--accent-cyan) !important;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5), 0 0 18px rgba(0, 224, 255, 0.15) !important;
	text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5) !important;
}

/* Primera versión (la actual) — verde */
.content_page > div > table td h3:first-child {
	margin-top: 0 !important;
	background: linear-gradient(135deg, rgba(0, 100, 40, 0.85), rgba(0, 150, 70, 0.75)) !important;
	border-left-color: var(--accent-green) !important;
	border-color: rgba(74, 255, 136, 0.4) !important;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5), 0 0 20px rgba(74, 255, 136, 0.25) !important;
}

.content_page > div > table td h3 em {
	color: #ffeeaa !important;
	font-style: normal !important;
	font-weight: 800 !important;
}

/* Párrafos */
.content_page > div > table td p {
	color: var(--text-main) !important;
	margin: 8px 0 !important;
	font-size: 13px !important;
	line-height: 1.6 !important;
}

.content_page > div > table td p strong {
	color: var(--accent-cyan) !important;
	font-weight: 700 !important;
	text-shadow: 0 0 8px rgba(0, 224, 255, 0.4) !important;
}

/* Secciones [Nombre] : */
.content_page > div > table td p em {
	color: var(--accent-green) !important;
	font-style: normal !important;
	font-weight: 700 !important;
	background: rgba(74, 255, 136, 0.08) !important;
	padding: 3px 10px !important;
	border-radius: 6px !important;
	border-left: 3px solid var(--accent-green) !important;
	display: inline-block !important;
	font-size: 12px !important;
	letter-spacing: 0.5px !important;
	box-shadow: 0 0 12px rgba(74, 255, 136, 0.15) !important;
}

/* Listas */
.content_page > div > table td ul {
	list-style: none !important;
	margin: 8px 0 16px 0 !important;
	padding: 0 !important;
}

.content_page > div > table td ul li {
	padding: 7px 12px 7px 26px !important;
	font-size: 12.5px !important;
	color: var(--text-main) !important;
	line-height: 1.55 !important;
	position: relative !important;
	border-radius: 0 6px 6px 0 !important;
	border-left: 2px solid rgba(0, 224, 255, 0.25) !important;
	background: rgba(0, 0, 0, 0.2) !important;
	transition: all 0.2s ease !important;
	margin: 4px 0 !important;
}

.content_page > div > table td ul li:hover {
	background: rgba(0, 224, 255, 0.06) !important;
	border-left-color: var(--accent-cyan) !important;
	transform: translateX(3px) !important;
}

.content_page > div > table td ul li::before {
	content: '▸' !important;
	position: absolute !important;
	left: 10px !important;
	color: var(--accent-cyan) !important;
	font-weight: bold !important;
	text-shadow: 0 0 6px rgba(0, 224, 255, 0.6) !important;
}

/* Sub-listas anidadas (•) */
.content_page > div > table td ul ul {
	margin: 6px 0 6px 20px !important;
}

.content_page > div > table td ul ul li {
	background: rgba(0, 0, 0, 0.15) !important;
	border-left: 2px solid rgba(139, 92, 246, 0.3) !important;
	color: var(--text-muted) !important;
	font-size: 12px !important;
	padding: 5px 12px 5px 22px !important;
}

.content_page > div > table td ul ul li::before {
	content: '•' !important;
	color: var(--accent-purple) !important;
	font-size: 14px !important;
	line-height: 1.4 !important;
	text-shadow: 0 0 6px rgba(139, 92, 246, 0.5) !important;
}

.content_page > div > table td ul ul li:hover {
	background: rgba(139, 92, 246, 0.06) !important;
	border-left-color: rgba(139, 92, 246, 0.6) !important;
}

/* Negritas dentro de listas */
.content_page > div > table td ul li strong {
	color: #ffffff !important;
	font-weight: 700 !important;
	text-shadow: 0 0 8px rgba(0, 224, 255, 0.3) !important;
}

/* Código inline (backticks) */
.content_page > div > table td code {
	color: var(--accent-cyan) !important;
	background: rgba(0, 0, 0, 0.5) !important;
	padding: 2px 7px !important;
	border-radius: 4px !important;
	font-family: 'Courier New', monospace !important;
	font-size: 11.5px !important;
	font-weight: 700 !important;
	border: 1px solid rgba(0, 224, 255, 0.3) !important;
}

/* Separadores --- */
.content_page > div > table td hr {
	border: none !important;
	height: 1px !important;
	background: linear-gradient(90deg, transparent, rgba(0, 224, 255, 0.4), transparent) !important;
	margin: 28px 0 !important;
}

/* Enlaces */
.content_page > div > table td a {
	color: var(--accent-cyan) !important;
	text-decoration: none !important;
	transition: all 0.25s ease !important;
}

.content_page > div > table td a:hover {
	color: #ffffff !important;
	text-shadow: 0 0 10px rgba(0, 224, 255, 0.8) !important;
}

/* Scrollbar */
.content_page > div > table td::-webkit-scrollbar {
	width: 8px;
}
.content_page > div > table td::-webkit-scrollbar-track {
	background: rgba(0, 0, 0, 0.3);
	border-radius: 4px;
}
.content_page > div > table td::-webkit-scrollbar-thumb {
	background: linear-gradient(180deg, #0066cc, #00ccff);
	border-radius: 4px;
}
.content_page > div > table td::-webkit-scrollbar-thumb:hover {
	background: linear-gradient(180deg, #00ccff, #00e0ff);
}

/* Responsive */
@media (max-width: 700px) {
	.content_page > .title { font-size: 18px !important; padding: 12px 14px !important; }
	.content_page > div > table td h3 { font-size: 13px !important; padding: 10px 14px !important; }
	.content_page > div > table td ul li { font-size: 11.5px !important; }
}
</style>

<div class="content_page">
	<div class="title">
		{$LNG.lm_changelog}
	</div>

	<div>
		<table style="width: 100%;">
			<tr>
				<td class="left" style="padding: 0 10px">{$ChangelogList}</td>
			</tr>
		</table>
	</div>
</div>
{/block}