{include file="main.header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Layout Popup (ventanas emergentes)
   Prefijo: .astrolaypp_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px (section) / 8px (inputs, botones)
     - Variables --bg-card / --accent-cyan unificadas
     - include y block name="content" intactos
   ═══════════════════════════════════════════════ */

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

/* Wrapper del popup — compacto, sin márgenes de página */
.astrolaypp_wrap {
    padding: 0;
    margin: 0;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
    color: var(--text-main);
    background: transparent;
}

.astrolaypp_section {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 14px 18px;
    color: var(--text-main);
    font-size: 12.5px;
    line-height: 1.6;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    box-sizing: border-box;
}

/* ═══ Tipografía dentro del popup ═══ */
.astrolaypp_section h1,
.astrolaypp_section h2,
.astrolaypp_section h3 {
    color: var(--accent-cyan);
    margin: 0 0 10px;
    letter-spacing: 0.5px;
}

.astrolaypp_section h1 {
    font-size: 15px;
    text-transform: uppercase;
    border-bottom: 1px solid var(--border-color);
    padding-bottom: 6px;
    letter-spacing: 1px;
}

.astrolaypp_section h2 { font-size: 13.5px; }
.astrolaypp_section h3 { font-size: 12.5px; }

.astrolaypp_section p {
    color: var(--text-main);
    line-height: 1.6;
    margin: 0 0 10px;
}

.astrolaypp_section a {
    color: var(--accent-cyan);
    text-decoration: none;
    transition: 0.2s ease;
}

.astrolaypp_section a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* ═══ Tablas dentro del popup ═══ */
.astrolaypp_section table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11.5px;
    color: var(--text-main);
}

.astrolaypp_section table th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    padding: 5px 8px;
    text-align: left;
    font-weight: normal;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrolaypp_section table td {
    padding: 5px 8px;
    border-bottom: 1px solid var(--border-color);
}

.astrolaypp_section table tr:hover {
    background: rgba(0, 224, 255, 0.04);
}

/* ═══ Inputs / Forms dentro del popup ═══ */
.astrolaypp_section input[type="text"],
.astrolaypp_section input[type="password"],
.astrolaypp_section input[type="email"],
.astrolaypp_section input[type="number"],
.astrolaypp_section select,
.astrolaypp_section textarea {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 5px 8px;
    font-size: 11.5px;
    transition: 0.25s ease;
    box-sizing: border-box;
    max-width: 100%;
}

.astrolaypp_section input:focus,
.astrolaypp_section select:focus,
.astrolaypp_section textarea:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astrolaypp_section textarea {
    width: 100%;
    resize: vertical;
    font-family: inherit;
}

/* ═══ Botones dentro del popup ═══ */
.astrolaypp_section button,
.astrolaypp_section input[type="submit"],
.astrolaypp_section input[type="button"],
.astrolaypp_section input[type="reset"] {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    padding: 5px 16px;
    font-size: 11.5px;
    font-weight: 600;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 0 3px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrolaypp_section button:hover,
.astrolaypp_section input[type="submit"]:hover,
.astrolaypp_section input[type="button"]:hover,
.astrolaypp_section input[type="reset"]:hover {
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}

.astrolaypp_section button:active,
.astrolaypp_section input[type="submit"]:active,
.astrolaypp_section input[type="button"]:active,
.astrolaypp_section input[type="reset"]:active {
    transform: translateY(0);
}

/* Reset button (gris) */
.astrolaypp_section input[type="reset"] {
    background: linear-gradient(180deg, #444 0%, #666 100%);
    border-color: #888;
}
.astrolaypp_section input[type="reset"]:hover {
    box-shadow: 0 0 12px rgba(150, 150, 150, 0.35);
}

/* ═══ Separadores ═══ */
.astrolaypp_section hr {
    border: none;
    border-top: 1px solid var(--border-color);
    margin: 12px 0;
}

/* ═══ Responsive (popups pequeños) ═══ */
@media (max-width: 600px) {
    .astrolaypp_section {
        padding: 10px 12px;
        font-size: 12px;
    }
    .astrolaypp_section h1 { font-size: 14px; }
}
</style>

<div class="astrolaypp_wrap">
    <section class="astrolaypp_section">
        {block name="content"}{/block}
    </section>
</div>

{include file="main.footer.tpl"}