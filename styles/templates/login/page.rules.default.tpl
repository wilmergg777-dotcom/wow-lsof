{block name="title" prepend}{$LNG.siteTitleRules}{/block}
{block name="content"}

{* ============================================================
   ASTROIO RULES v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrorl_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Centrado con text-align + inline-block (Regla #14)
     - Contenido dinámico {$rules} con estilos extendidos
     - Wrapper padding 15px
     - block name="content", {$LNG}, {$rules} intactos
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

/* ====== Wrapper (centrado por text-align) ====== */
.astrorl_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
    text-align: center;
}

/* ====== Panel principal (glassmorphism) ====== */
.astrorl_panel {
    display: inline-block;
    text-align: left;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 18px 24px;
    color: var(--text-main);
    width: 900px;
    max-width: 100%;
    vertical-align: top;
    box-sizing: border-box;
}

/* ====== Título de sección ====== */
.astrorl_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.25);
    padding-bottom: 8px;
    margin-bottom: 14px;
    display: block;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}

/* ====== Contenido dinámico {$rules} ====== */
.astrorl_content {
    color: var(--text-main);
    font-size: 12.5px;
    line-height: 1.6;
    word-wrap: break-word;
}

/* Encabezados dentro del contenido */
.astrorl_content h1,
.astrorl_content h2,
.astrorl_content h3,
.astrorl_content h4,
.astrorl_content h5,
.astrorl_content h6 {
    color: #00e0ff;
    font-weight: 700;
    letter-spacing: 0.4px;
    margin: 16px 0 8px 0;
    padding-bottom: 4px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.25);
}
.astrorl_content h1 { font-size: 18px; }
.astrorl_content h2 { font-size: 16px; }
.astrorl_content h3 { font-size: 14px; }
.astrorl_content h4 { font-size: 13px; }
.astrorl_content h5,
.astrorl_content h6 { font-size: 12px; }

/* Párrafos */
.astrorl_content p {
    margin: 0 0 10px 0;
}

/* Enlaces */
.astrorl_content a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.2s ease;
}
.astrorl_content a:hover {
    color: #ffffff;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.8);
    text-decoration: underline;
}

/* Listas */
.astrorl_content ul,
.astrorl_content ol {
    margin: 8px 0 12px 0;
    padding-left: 24px;
}
.astrorl_content li {
    margin-bottom: 4px;
    color: var(--text-main);
}
.astrorl_content ul li::marker {
    color: #00ccff;
}
.astrorl_content ol li::marker {
    color: #00ccff;
    font-weight: 700;
}

/* Negritas y énfasis */
.astrorl_content strong,
.astrorl_content b {
    color: var(--text-title);
    font-weight: 700;
}
.astrorl_content em,
.astrorl_content i {
    color: #ffaa33;
    font-style: italic;
}

/* Código inline */
.astrorl_content code {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.25);
    border-radius: 4px;
    padding: 2px 8px;
    font-family: 'Courier New', monospace;
    font-size: 11.5px;
    color: #66ff99;
}

/* Tablas dentro del contenido */
.astrorl_content table {
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0;
    font-size: 11.5px;
    border-radius: 10px;
    overflow: hidden;
}
.astrorl_content table th {
    padding: 6px 10px;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    text-align: left;
    border-bottom: 1px solid var(--accent-cyan);
    letter-spacing: 0.3px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astrorl_content table td {
    padding: 5px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
}
.astrorl_content table tr:hover td {
    background: rgba(0, 204, 255, 0.06);
}

/* Citas */
.astrorl_content blockquote {
    border-left: 3px solid #00ccff;
    background: rgba(0, 204, 255, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    margin: 10px 0;
    padding: 10px 16px;
    border-radius: 0 10px 10px 0;
    color: var(--text-main);
    font-style: italic;
}

/* Separadores */
.astrorl_content hr {
    border: none;
    border-top: 1px solid rgba(0, 204, 255, 0.2);
    margin: 16px 0;
}

/* Imágenes */
.astrorl_content img {
    max-width: 100%;
    height: auto;
    border-radius: 8px;
    border: 1px solid rgba(0, 204, 255, 0.2);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astrorl_wrap { padding: 10px; }
    .astrorl_panel { padding: 14px 16px; }
    .astrorl_content { font-size: 11.5px; }
    .astrorl_content h1 { font-size: 16px; }
    .astrorl_content h2 { font-size: 14px; }
    .astrorl_content h3 { font-size: 13px; }
}
</style>

<div class="astrorl_wrap">

	<div class="astrorl_panel">

		<span class="astrorl_section_title">📜 {$LNG.siteTitleRules}</span>

		<div class="astrorl_content">
			{$rules}
		</div>

	</div>

</div>

{/block}