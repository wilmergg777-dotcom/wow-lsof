{block name="title" prepend}{$LNG.fcm_info}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/error.default.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
#content h1, #content h2, #content h3, #content h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
#content a { color:#00e0ff; text-decoration:none; transition:.2s ease }
#content a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
#content table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
#content table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
#content table tr:hover td { background:rgba(0,224,255,.04) }
#content input[type=text], #content input[type=password], #content input[type=email], #content input[type=number], #content input[type=date], #content select, #content textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
#content input[type=text]:focus, #content input[type=password]:focus, #content input[type=email]:focus, #content input[type=number]:focus, #content select:focus, #content textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
#content textarea { width:100%; resize:vertical; font-family:inherit }
#content button, #content input[type=submit], #content input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content button:hover, #content input[type=submit]:hover, #content input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
#content button:active, #content input[type=submit]:active, #content input[type=button]:active { transform:translateY(0) }
#content input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
#content select option { background:#0f172a; color:#cbd5e1 }
#content .globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { #content { padding:6px; overflow-x:auto } #content table { font-size:11px } #content table th, #content table td { padding:5px 7px } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Página de Error / Mensaje
   Prefijo: .astroerr_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - Variables --bg-card / --accent-cyan unificadas
     - border-radius 14px (panel) / 12px (header)
     - Borde cyan con glow
     - Botones con gradiente cyan + hover translateY
     - box-sizing global
     - breakpoints 720px
     - TODO el Smarty preservado al 100%
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

/* ─── RESET GLOBAL ─── */
.astroerr_wrap,
.astroerr_wrap *,
.astroerr_wrap *::before,
.astroerr_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ─── */
.astroerr_wrap {
    max-width: 600px;
    margin: 60px auto 20px;
    padding: 0 10px;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

/* ─── PANEL PRINCIPAL ─── */
.astroerr_panel {
    background: var(--bg-card);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 2px solid rgba(0, 224, 255, 0.4);
    border-radius: 14px;
    box-shadow:
        0 8px 30px rgba(0, 0, 0, 0.6),
        0 0 40px rgba(0, 224, 255, 0.08),
        inset 0 0 20px rgba(0, 224, 255, 0.03);
    overflow: hidden;
}

/* ─── HEADER DEL PANEL ─── */
.astroerr_heading {
    background: linear-gradient(135deg, #0a5a8c 0%, #00a8e0 100%);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    font-size: 13px;
    font-weight: 800;
    padding: 14px 18px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-align: center;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5), 0 0 10px rgba(0, 224, 255, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}

/* ─── CUERPO DEL PANEL ─── */
.astroerr_body {
    padding: 20px 24px;
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.7;
}

/* ─── TABLA (estructura preservada) ─── */
.astroerr_table {
    width: 100%;
    border-collapse: collapse;
    margin: 0;
    table-layout: fixed;
}

.astroerr_table tr > td {
    padding: 0;
    color: var(--text-main);
    vertical-align: top;
}

/* ─── MENSAJE ─── */
.astroerr_message {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 600;
    line-height: 1.7;
    margin: 0 0 16px;
    padding: 16px 18px;
    background: rgba(0, 224, 255, 0.04);
    border: 1px solid var(--border-color);
    border-left: 4px solid var(--accent-cyan);
    border-radius: 8px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    box-shadow: inset 0 0 20px rgba(0, 224, 255, 0.03);
    text-align: center;
}

.astroerr_message p {
    margin: 0;
}

/* ─── BOTONES DE REDIRECCIÓN ─── */
.astroerr_buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 14px;
    padding-top: 14px;
    border-top: 1px solid var(--border-color);
    justify-content: center;
}

.astroerr_buttons a {
    text-decoration: none;
    display: inline-block;
}

.astroerr_buttons .btn,
.astroerr_buttons button {
    display: inline-block;
    padding: 9px 24px;
    background: linear-gradient(135deg, #0066cc 0%, #00a8e0 100%);
    color: #ffffff !important;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 4px 12px rgba(0, 224, 255, 0.25);
}

.astroerr_buttons .btn:hover,
.astroerr_buttons button:hover {
    box-shadow: 0 0 22px rgba(0, 224, 255, 0.6), 0 4px 12px rgba(0, 224, 255, 0.3);
    transform: translateY(-2px);
    background: linear-gradient(135deg, #00a8e0 0%, #00e0ff 100%);
    color: #ffffff !important;
}

.astroerr_buttons .btn:active,
.astroerr_buttons button:active {
    transform: translateY(0);
}

/* ─── RESPONSIVE ─── */
@media (max-width: 720px) {
    .astroerr_wrap {
        margin-top: 50px;
        padding: 0 6px;
        max-width: 100%;
    }
    .astroerr_heading {
        font-size: 11px;
        padding: 10px 14px;
        letter-spacing: 1px;
    }
    .astroerr_body {
        padding: 16px 14px;
    }
    .astroerr_message {
        padding: 12px 14px;
        font-size: 13px;
    }
    .astroerr_buttons {
        justify-content: center;
    }
    .astroerr_buttons .btn,
    .astroerr_buttons button {
        width: 100%;
        text-align: center;
        padding: 10px 18px;
    }
}
</style>

<div class="container astroerr_wrap">
    <div class="panel panel-default astroerr_panel">
        <div class="panel-heading astroerr_heading">⚠️ AVISO DEL SISTEMA</div>
        <div class="panel-body astroerr_body">
            <table class="table519 astroerr_table">
                <tr>
                    <td>
                        <p class="astroerr_message">{$message}</p>
                        {if !empty($redirectButtons)}
                        <p class="astroerr_buttons">
                            {foreach $redirectButtons as $button}
                                <a href="{$button.url}"><button class="btn btn-default">{$button.label}</button></a>
                            {/foreach}
                        </p>
                        {/if}
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>

{/block}