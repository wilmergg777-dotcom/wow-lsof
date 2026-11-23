{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.admin.transfer.tpl === *}
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


{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Admin · Transferir
   Prefijo: .astroalat_
   Acento del módulo: 🟡 Dorado (#fbbf24)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Tabla con hover dorado
     - Select con radius 8px + focus translateY
     - Botón con radius 8px + hover translateY
     - Wrapper padding 15px
     - form, select, html_options, colspan, links, Smarty intactos
   ═══════════════════════════════════════════════ *}

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

.astroalat_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalat_panel {
    display: inline-block;
    text-align: left;
    width: 700px;
    max-width: 100%;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    font-size: 11px;
    color: var(--text-main);
}

.astroalat_title {
    text-transform: uppercase;
    color: #ffaa33;
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(251, 191, 36, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

.astroalat_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
    color: var(--text-main);
}

.astroalat_table tr > td {
    padding: 8px 10px;
    vertical-align: middle;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
}

.astroalat_table tr > td:first-child {
    width: 30%;
    color: var(--text-muted);
    font-weight: 600;
}

.astroalat_table tr > td:nth-child(2) {
    width: 50%;
}

.astroalat_table tr > td:last-child {
    width: 20%;
    text-align: right;
}

.astroalat_table tr:hover {
    background: rgba(251, 191, 36, 0.06);
}

/* Select (html_options) */
.astroalat_table select {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 7px 10px;
    font-size: 11px;
    font-family: inherit;
    font-weight: 700;
    width: 100%;
    max-width: 320px;
    transition: 0.25s ease;
    outline: none;
    cursor: pointer;
}
.astroalat_table select:hover,
.astroalat_table select:focus {
    border-color: #ffaa33;
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astroalat_table select option {
    background: #0f1624;
    color: #cbd5e1;
    padding: 4px;
}

/* Botón submit */
.astroalat_btn {
    display: inline-block;
    padding: 7px 20px;
    background: linear-gradient(135deg, rgba(170, 102, 0, 0.9), rgba(255, 170, 51, 0.9));
    color: #0f1624;
    border: 1px solid #ffaa33;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    font-family: inherit;
}
.astroalat_btn:hover {
    background: linear-gradient(135deg, rgba(255, 170, 51, 0.95), rgba(255, 204, 102, 0.95));
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.6);
    transform: translateY(-2px);
}
.astroalat_btn:active {
    transform: translateY(0);
}

/* Fila "Volver" */
.astroalat_table tr > th[colspan="3"] {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-top: 1px solid var(--accent-cyan);
    border-bottom: none;
    text-align: center;
    padding: 10px;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astroalat_table tr > th[colspan="3"] a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalat_table tr > th[colspan="3"] a:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7);
}

/* Responsive */
@media (max-width: 480px) {
    .astroalat_wrap { padding: 10px; }
    .astroalat_panel { padding: 12px; }
    .astroalat_table { font-size: 10px; }
    .astroalat_table tr > td:first-child { width: 40%; }
    .astroalat_table tr > td:nth-child(2) { width: 60%; }
    .astroalat_table tr > td:last-child {
        display: block;
        text-align: center;
        padding-top: 6px;
    }
    .astroalat_btn { width: 100%; }
}
</style>

<div class="astroalat_wrap">
<div class="astroalat_panel">

    <div class="astroalat_title">{$LNG.al_transfer_alliance}</div>

    <form action="game.php?page=alliance&amp;mode=admin&amp;action=transfer" method="post">
        <table class="table519 astroalat_table">
            <tr>
                <td>{$LNG.al_transfer_to}:</td>
                <td>{html_options name=newleader options=$transferUserList}</td>
                <td><input class="astroalat_btn" type="submit" value="{$LNG.al_transfer_submit}"></td>
            </tr>
            <tr>
                <th colspan="3"><a href="game.php?page=alliance&amp;mode=admin">{$LNG.al_back}</a></th>
            </tr>
        </table>
    </form>

</div>
</div>

{/block}