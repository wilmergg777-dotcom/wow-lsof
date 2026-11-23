{include file="main.header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.1 — Layout Popup (ventanas emergentes)
   ✅ FIX: Borde naranja, fondo oscuro igual al index.
   ✅ FIX: Código limpiado y unificado.
   ═══════════════════════════════════════════════ */

:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(10, 15, 25, 0.9); /* Fondo oscuro igual al index */
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #ff5e00; /* Borde naranja */
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-cyan:   #00e0ff;
}

/* Wrapper del popup — compacto, sin márgenes de página */
.astrolaypp_wrap {
    padding: 10px;
    margin: 0;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
    color: var(--text-main);
    background: transparent;
}

.astrolaypp_section {
    background: var(--bg-card) !important;
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    border: 1px solid var(--border-color) !important;
    border-radius: 12px;
    padding: 25px 30px;
    color: var(--text-main);
    font-size: 13.5px;
    line-height: 1.6;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9) !important;
    box-sizing: border-box;
}

/* ═══ Tipografía dentro del popup ═══ */
.astrolaypp_section h1,
.astrolaypp_section h2,
.astrolaypp_section h3 {
    color: var(--accent-cyan) !important;
    margin: 0 0 12px;
    letter-spacing: 0.5px;
}

.astrolaypp_section h1 {
    font-size: 16px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(255, 94, 0, 0.4) !important;
    padding-bottom: 8px;
    letter-spacing: 1px;
}

.astrolaypp_section h2 { font-size: 14.5px; }
.astrolaypp_section h3 { font-size: 13px; }

.astrolaypp_section p {
    color: #e2e8f0 !important;
    line-height: 1.6;
    margin: 0 0 12px;
}

.astrolaypp_section a {
    color: var(--accent-cyan) !important;
    text-decoration: none;
    transition: 0.2s ease;
}

.astrolaypp_section a:hover {
    color: #ffffff !important;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* ═══ Tablas dentro del popup ═══ */
.astrolaypp_section table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
    color: var(--text-main);
}

.astrolaypp_section table th {
    background: rgba(0, 0, 0, 0.6) !important;
    border-bottom: 1px solid var(--border-color) !important;
    color: #00e0ff !important;
    padding: 8px 10px;
    text-align: left;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 11px;
    letter-spacing: 0.5px;
}

.astrolaypp_section table td {
    padding: 8px 10px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05) !important;
}

.astrolaypp_section table tr:hover {
    background: rgba(255, 94, 0, 0.05) !important;
}

/* ═══ Inputs / Forms dentro del popup ═══ */
.astrolaypp_section input[type="text"],
.astrolaypp_section input[type="password"],
.astrolaypp_section input[type="email"],
.astrolaypp_section input[type="number"],
.astrolaypp_section select,
.astrolaypp_section textarea {
    background: #ffffff !important;
    color: #000000 !important;
    border: 1px solid rgba(255, 255, 255, 0.2) !important;
    border-radius: 6px;
    padding: 10px 12px;
    font-size: 13px;
    transition: 0.25s ease;
    box-sizing: border-box;
    max-width: 100%;
}

.astrolaypp_section input:focus,
.astrolaypp_section select:focus,
.astrolaypp_section textarea:focus {
    outline: none;
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
}

.astrolaypp_section textarea {
    width: 100%;
    resize: vertical;
    font-family: inherit;
}

/* ═══ Botones dentro del popup ═══ */
.astrolaypp_section button,
.astrolaypp_section input[type="submit"],
.astrolaypp_section input[type="button"] {
    background: #222c3c !important;
    color: #ffffff !important;
    border: 1px solid #444 !important;
    border-radius: 6px;
    padding: 10px 20px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 0 5px 0 0;
}
.astrolaypp_section button:hover,
.astrolaypp_section input[type="submit"]:hover,
.astrolaypp_section input[type="button"]:hover {
    background: #2e3a4e !important;
    border-color: var(--border-color) !important;
    box-shadow: 0 0 18px rgba(255, 94, 0, 0.4) !important;
    transform: translateY(-2px);
}

.astrolaypp_section button:active,
.astrolaypp_section input[type="submit"]:active,
.astrolaypp_section input[type="button"]:active {
    transform: translateY(0);
}

/* Botón de reset */
.astrolaypp_section input[type="reset"] {
    background: #111 !important;
    color: #ccc !important;
    border: 1px solid #333 !important;
    border-radius: 6px;
    padding: 10px 20px;
    font-size: 13px;
    cursor: pointer;
    transition: 0.25s ease;
}
.astrolaypp_section input[type="reset"]:hover {
    background: #222 !important;
    border-color: #555 !important;
}

/* ═══ Separadores ═══ */
.astrolaypp_section hr {
    border: none;
    border-top: 1px solid rgba(255, 94, 0, 0.3) !important;
    margin: 15px 0;
}

/* ═══ Responsive (popups pequeños) ═══ */
@media (max-width: 600px) {
    .astrolaypp_wrap { padding: 5px; }
    .astrolaypp_section {
        padding: 20px 15px;
        font-size: 13px;
    }
    .astrolaypp_section h1 { font-size: 15px; }
}
</style>

<div class="astrolaypp_wrap">
    <section class="astrolaypp_section">
        {block name="content"}
        {* El contenido de la ventana emergente se inyecta aquí *}
        {/block}
    </section>
</div>

{include file="main.footer.tpl"}