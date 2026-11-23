{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/pvpAdminPage.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}

{include file="overall_header.tpl"}

<style>
/* ═══════════════════════════════════════════════════════════
   AstroIO — Panel Admin PvP
   v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: pvpAdmin*

   FIX v3.1:
     - Añadidos boxes de desglose por riel en stats
     - Tablas de arenas/torneos muestran pool_ntx20 y pool_untx20
     - Textos de "NTX-20" hardcodeado reemplazados por "su riel"
     - Form de refund ahora es "saldo" (auto-detecta riel)
     - Labels de precios clarifican que son BASE NTX-20
   ═══════════════════════════════════════════════════════════ */

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

/* ─── RESET GLOBAL ──────────────────────────────────────── */
.pvpAdminWrap *,
.pvpAdminWrap *::before,
.pvpAdminWrap *::after {
    box-sizing: border-box;
}

/* ─── FONDO DEL BODY ADMIN ──────────────────────────────── */
body#menu {
    background: linear-gradient(180deg, #1a0d0d 0%, #1a2332 100%) !important;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.pvpAdminWrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 12px;
    color: #c8d6e5;
    font-family: 'Segoe UI', Roboto, sans-serif;
    font-size: 12px;
}

.pvpAdminWrap h1 {
    color: #ff8888;
    font-size: 18px;
    margin: 0 0 6px 0;
    text-shadow: 0 0 12px rgba(239, 68, 68, 0.5);
    letter-spacing: 0.5px;
}

.pvpAdminWrap .pvpSub {
    color: #8899aa;
    font-size: 11px;
    margin-bottom: 12px;
}

/* ─── PESTAÑAS ──────────────────────────────────────────── */
.pvpTabs {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(255, 50, 50, 0.2);
}

.pvpTab {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 6px 12px;
    font-size: 11px;
    font-weight: 600;
    border-radius: 6px;
    text-decoration: none;
    color: #8899aa;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(120, 120, 120, 0.2);
    transition: all 0.2s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.pvpTab:hover {
    color: #ffffff;
    background: rgba(255, 80, 80, 0.1);
    border-color: rgba(255, 100, 100, 0.4);
    transform: translateY(-1px);
}

.pvpTab.active {
    color: #ffffff;
    background: linear-gradient(135deg, #cc2222, #ff6666);
    border-color: #ff6666;
    box-shadow: 0 0 12px rgba(255, 50, 50, 0.4);
}

.pvpTab.tab-yellow.active {
    background: linear-gradient(135deg, #cc9900, #ffcc33);
    color: #111;
    border-color: #ffdd88;
    box-shadow: 0 0 12px rgba(255, 200, 50, 0.4);
}

.pvpTab.tab-blue.active {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 200, 255, 0.4);
}

.pvpTab.tab-green.active {
    background: linear-gradient(135deg, #008844, #00cc66);
    border-color: #66ff99;
    box-shadow: 0 0 12px rgba(0, 200, 100, 0.4);
}

.pvpTab.tab-cyan.active {
    background: linear-gradient(135deg, #008888, #00dddd);
    border-color: #88ffff;
    box-shadow: 0 0 12px rgba(0, 200, 200, 0.4);
}

/* ─── TARJETAS ──────────────────────────────────────────── */
.pvpCard {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 80, 80, 0.25);
    border-radius: 8px;
    padding: 12px 14px;
    margin-bottom: 10px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.pvpCard.red    { border-color: rgba(255, 80, 80, 0.35); }
.pvpCard.yellow { border-color: rgba(255, 200, 50, 0.35); }
.pvpCard.blue   { border-color: rgba(0, 200, 255, 0.35); }
.pvpCard.green  { border-color: rgba(0, 200, 100, 0.35); }
.pvpCard.cyan   { border-color: rgba(0, 220, 220, 0.35); }

.pvpCard h2 {
    font-size: 13px;
    margin: 0 0 10px 0;
    padding-bottom: 6px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.pvpCard h2.red    { color: #ff8888; }
.pvpCard h2.yellow { color: #ffdd88; }
.pvpCard h2.blue   { color: #88ddff; }
.pvpCard h2.green  { color: #88ffbb; }
.pvpCard h2.cyan   { color: #88ffff; }

/* ─── STATS GRID ────────────────────────────────────────── */
.pvpStatsGrid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 8px;
    margin-bottom: 12px;
}

.pvpStatBox {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 80, 80, 0.3);
    border-radius: 6px;
    padding: 10px;
    text-align: center;
    transition: 0.25s ease;
    min-width: 0;
    overflow: hidden;
}
.pvpStatBox:hover {
    transform: translateY(-2px);
}

.pvpStatBox.red    { border-color: rgba(255, 80, 80, 0.35); }
.pvpStatBox.yellow { border-color: rgba(255, 200, 50, 0.35); }
.pvpStatBox.green  { border-color: rgba(0, 255, 130, 0.35); }
.pvpStatBox.blue   { border-color: rgba(0, 200, 255, 0.35); }
.pvpStatBox.cyan   { border-color: rgba(0, 220, 220, 0.35); }

.pvpStatLabel {
    font-size: 10px;
    color: #8899aa;
    margin-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.pvpStatValue {
    font-size: 18px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.pvpStatBox.red    .pvpStatValue { color: #ff8888; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.pvpStatBox.yellow .pvpStatValue { color: #ffdd88; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4); }
.pvpStatBox.green  .pvpStatValue { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.4); }
.pvpStatBox.blue   .pvpStatValue { color: #88ddff; text-shadow: 0 0 8px rgba(100, 200, 255, 0.4); }
.pvpStatBox.cyan   .pvpStatValue { color: #88ffff; text-shadow: 0 0 8px rgba(136, 255, 255, 0.4); }

/* ─── INPUTS ────────────────────────────────────────────── */
.pvpInput {
    width: 100%;
    margin-top: 4px;
    padding: 6px 8px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(255, 80, 80, 0.3);
    color: #ffffff;
    border-radius: 5px;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    box-sizing: border-box;
    outline: none;
    transition: 0.25s ease;
}

.pvpInput.yellow { border-color: rgba(255, 200, 50, 0.4); }
.pvpInput.blue   { border-color: rgba(0, 200, 255, 0.4); }
.pvpInput.green  { border-color: rgba(0, 200, 100, 0.4); }

.pvpInput:focus {
    outline: none;
    border-color: #ff6666;
    box-shadow: 0 0 8px rgba(255, 80, 80, 0.4);
    background: rgba(0, 0, 0, 0.65);
}

.pvpLabel {
    font-size: 11px;
    color: #aabbcc;
    display: block;
}

/* ─── GRIDS ─────────────────────────────────────────────── */
.pvpGrid2 { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; }
.pvpGrid3 { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; }
.pvpGrid4 { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 8px; }

/* ─── BOTONES ───────────────────────────────────────────── */
.pvpBtn {
    display: inline-block;
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    font-size: 12px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    text-align: center;
    transition: all 0.2s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.pvpBtn.red {
    background: linear-gradient(135deg, #cc2222, #ff6666);
    color: #fff;
    box-shadow: 0 3px 10px rgba(255, 50, 50, 0.4);
}
.pvpBtn.red:hover { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(255, 50, 50, 0.6); }

.pvpBtn.yellow {
    background: linear-gradient(135deg, #cc9900, #ffcc33);
    color: #1a1a1a;
    box-shadow: 0 3px 10px rgba(255, 200, 50, 0.4);
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.pvpBtn.yellow:hover { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(255, 200, 50, 0.6); }

.pvpBtn.blue {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    box-shadow: 0 3px 10px rgba(0, 170, 255, 0.4);
}
.pvpBtn.blue:hover { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(0, 170, 255, 0.6); }

.pvpBtn.green {
    background: linear-gradient(135deg, #008844, #00cc66);
    color: #fff;
    box-shadow: 0 3px 10px rgba(0, 200, 100, 0.4);
}
.pvpBtn.green:hover { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(0, 200, 100, 0.6); }

.pvpBtn.cyan {
    background: linear-gradient(135deg, #008888, #00dddd);
    color: #fff;
    box-shadow: 0 3px 10px rgba(0, 200, 200, 0.4);
}
.pvpBtn.cyan:hover { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(0, 220, 220, 0.6); }

.pvpBtn.small { padding: 4px 10px; font-size: 10px; }
.pvpBtn.ghost {
    background: rgba(255, 255, 255, 0.05);
    color: #8899aa;
    border: 1px solid rgba(120, 120, 120, 0.3);
}
.pvpBtn.ghost:hover { color: #fff; border-color: #fff; }

/* ─── TABLAS ────────────────────────────────────────────── */
.pvpTable {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    table-layout: fixed;
}

.pvpTable thead th {
    padding: 6px 8px;
    text-align: left;
    color: #ff8888;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid rgba(255, 80, 80, 0.25);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.pvpTable thead.yellow th { color: #ffdd88; border-bottom-color: rgba(255, 200, 50, 0.3); }
.pvpTable thead.green th  { color: #88ffbb; border-bottom-color: rgba(0, 200, 100, 0.3); }

.pvpTable tbody td {
    padding: 6px 8px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.04);
    color: #c8d6e5;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.pvpTable tbody tr {
    transition: 0.2s ease;
}
.pvpTable tbody tr:hover { background: rgba(255, 80, 80, 0.04); }

.pvpTable .center { text-align: center; }
.pvpTable .right  { text-align: right; }

/* ─── BADGES ────────────────────────────────────────────── */
.pvpBadge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.3px;
    white-space: nowrap;
}

.pvpBadge.red    { background: rgba(255, 50, 50, 0.25); color: #ff8888; border: 1px solid rgba(255, 80, 80, 0.5); }
.pvpBadge.yellow { background: rgba(255, 200, 50, 0.25); color: #ffee88; border: 1px solid rgba(255, 200, 50, 0.5); }
.pvpBadge.green  { background: rgba(0, 200, 100, 0.2); color: #88ffbb; border: 1px solid rgba(0, 255, 130, 0.5); }
.pvpBadge.blue   { background: rgba(0, 200, 255, 0.2); color: #88ddff; border: 1px solid rgba(0, 200, 255, 0.5); }

/* ─── MENSAJES FLASH ────────────────────────────────────── */
.pvpFlash {
    padding: 10px 14px;
    margin-bottom: 12px;
    border-radius: 8px;
    font-size: 12px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.pvpFlash.success { background: rgba(0, 200, 100, 0.15); border: 1px solid rgba(0, 255, 130, 0.5); color: #88ffbb; }
.pvpFlash.error   { background: rgba(255, 50, 50, 0.15); border: 1px solid rgba(255, 80, 80, 0.5); color: #ffbbbb; }
.pvpFlash.info    { background: rgba(0, 200, 255, 0.15); border: 1px solid rgba(0, 200, 255, 0.5); color: #88ddff; }

/* ─── ACCIONES CARD ─────────────────────────────────────── */
.pvpActionCard {
    background: linear-gradient(135deg, rgba(60, 15, 15, 0.5), rgba(40, 20, 20, 0.5));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 80, 80, 0.35);
    border-left: 3px solid #ff4444;
    border-radius: 8px;
    padding: 14px 16px;
    margin-bottom: 10px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.pvpActionCard h2 {
    color: #ff8888;
    font-size: 13px;
    margin: 0 0 10px 0;
    padding-bottom: 6px;
    border-bottom: 1px solid rgba(255, 80, 80, 0.2);
}

.pvpActionCard p {
    font-size: 11px;
    color: #aabbcc;
    margin-bottom: 10px;
    line-height: 1.6;
}

/* ─── UTILIDADES ────────────────────────────────────────── */
.pvpToggle_label {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 10px;
    border-radius: 6px;
    cursor: pointer;
    transition: 0.25s ease;
}
.pvpToggle_label.red {
    background: rgba(255, 50, 50, 0.05);
    border: 1px solid rgba(255, 100, 100, 0.25);
}
.pvpToggle_label.red:hover {
    background: rgba(255, 50, 50, 0.12);
}
.pvpToggle_label.yellow {
    background: rgba(255, 200, 50, 0.05);
    border: 1px solid rgba(255, 200, 50, 0.25);
}
.pvpToggle_label.yellow:hover {
    background: rgba(255, 200, 50, 0.12);
}

.pvpToggle_label input[type="checkbox"] {
    width: 16px;
    height: 16px;
    cursor: pointer;
}

.pvpToggle_label .pvpToggle_red    { color: #ff8888; font-weight: bold; font-size: 12px; }
.pvpToggle_label .pvpToggle_yellow { color: #ffdd88; font-weight: bold; font-size: 12px; }

.pvpSection_title {
    font-size: 12px;
    margin: 10px 0 6px;
    padding-bottom: 4px;
}
.pvpSection_title.red    { color: #ff8888; border-bottom: 1px solid rgba(255, 80, 80, 0.3); }
.pvpSection_title.yellow { color: #ffdd88; border-bottom: 1px solid rgba(255, 200, 50, 0.3); }

.pvpCenter { text-align: center; }
.pvpCenter_actions {
    text-align: center;
    margin-top: 12px;
}
.pvpEmpty {
    text-align: center;
    color: #8899aa;
    padding: 20px;
    font-style: italic;
}

.pvpFooter {
    text-align: center;
    font-size: 10px;
    color: #8899aa;
    margin-top: 16px;
}

/* Acciones dentro de cards (botones agrupados) */
.pvpActions_row {
    display: flex;
    gap: 8px;
    justify-content: center;
    flex-wrap: wrap;
    margin-top: 10px;
}

/* Info block */
.pvpInfoBlock {
    text-align: center;
    padding: 10px 0;
    font-size: 11px;
    color: #aabbcc;
}
.pvpInfoBlock b { color: #ffdd88; }

/* Info links */
.pvpInfoLinks p {
    line-height: 1.8;
    margin: 0;
}
.pvpInfoLinks a {
    color: #88ddff;
    text-decoration: none;
}
.pvpInfoLinks a:hover {
    color: #ffffff;
    text-decoration: underline;
}
.pvpInfoLinks .label { color: #88ffbb; }

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .pvpGrid4 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}

@media (max-width: 720px) {
    .pvpAdminWrap {
        padding: 8px;
    }
    .pvpAdminWrap h1 {
        font-size: 15px;
    }
    .pvpGrid2,
    .pvpGrid3,
    .pvpGrid4 {
        grid-template-columns: 1fr;
    }
    .pvpStatsGrid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 6px;
    }
    .pvpStatValue {
        font-size: 14px;
    }
    .pvpTab {
        font-size: 10px;
        padding: 5px 9px;
    }
    .pvpCard {
        padding: 10px;
    }
    .pvpBtn {
        font-size: 11px;
        padding: 7px 12px;
    }
    .pvpBtn.small {
        font-size: 9px;
        padding: 3px 8px;
    }
    .pvpTable {
        font-size: 10px;
    }
    .pvpTable thead th,
    .pvpTable tbody td {
        padding: 5px 4px;
    }
}
</style>

<div class="pvpAdminWrap">
    <h1>⚔️ PANEL ADMIN — SISTEMA PvP</h1>
    <p class="pvpSub">
        Gestiona arenas, torneos, precios y recompensas del sistema PvP.
        Los cambios se aplican inmediatamente.
        💲 <b>Los precios se guardan en BASE NTX-20</b>: los jugadores QVAPAY pagan ×2 en UNTX-20.
    </p>

    {* FLASH MESSAGE *}
    {if $message != ''}
        <div class="pvpFlash {if $msgType == 'success'}success{elseif $msgType == 'error'}error{else}info{/if}">
            {$message}
        </div>
    {/if}

    {* PESTAÑAS *}
    <div class="pvpTabs">
        <a href="admin.php?page=pvpadmin&tab=dashboard"
           class="pvpTab {if $active_tab == 'dashboard'}active{/if}">📊 Dashboard</a>
        <a href="admin.php?page=pvpadmin&tab=arenas"
           class="pvpTab tab-blue {if $active_tab == 'arenas'}active{/if}">🏟️ Arenas</a>
        <a href="admin.php?page=pvpadmin&tab=tournaments"
           class="pvpTab tab-yellow {if $active_tab == 'tournaments'}active{/if}">🏆 Torneos</a>
        <a href="admin.php?page=pvpadmin&tab=history"
           class="pvpTab tab-green {if $active_tab == 'history'}active{/if}">📜 Historial</a>
        <a href="admin.php?page=pvpadmin&tab=actions"
           class="pvpTab tab-cyan {if $active_tab == 'actions'}active{/if}">🧹 Acciones</a>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * PESTAÑA: DASHBOARD
     * ═══════════════════════════════════════════════════════════ *}
    {if $active_tab == 'dashboard'}

        <div class="pvpStatsGrid">
            <div class="pvpStatBox red">
                <div class="pvpStatLabel">🏟️ Arenas esperando</div>
                <div class="pvpStatValue">{$stats.arenas_waiting}</div>
            </div>
            <div class="pvpStatBox red">
                <div class="pvpStatLabel">⚔️ Arenas activas</div>
                <div class="pvpStatValue">{$stats.arenas_active}</div>
            </div>
            <div class="pvpStatBox green">
                <div class="pvpStatLabel">✅ Arenas finalizadas</div>
                <div class="pvpStatValue">{$stats.arenas_finished}</div>
            </div>
            <div class="pvpStatBox yellow">
                <div class="pvpStatLabel">🏆 Torneos activos</div>
                <div class="pvpStatValue">{$stats.tournaments_active}</div>
            </div>
            <div class="pvpStatBox green">
                <div class="pvpStatLabel">🏆 Torneos finalizados</div>
                <div class="pvpStatValue">{$stats.tournaments_finished}</div>
            </div>
            <div class="pvpStatBox blue">
                <div class="pvpStatLabel">👥 Jugadores en arenas</div>
                <div class="pvpStatValue">{$stats.players_in_arenas}</div>
            </div>
        </div>

        {* 🆕 Botes separados por riel *}
        <div class="pvpStatsGrid">
            <div class="pvpStatBox yellow">
                <div class="pvpStatLabel">💲 Bote Arenas NTX-20</div>
                <div class="pvpStatValue">{$stats.prize_pool_arenas_ntx20|number_format}</div>
            </div>
            <div class="pvpStatBox cyan">
                <div class="pvpStatLabel">💲 Bote Arenas UNTX-20</div>
                <div class="pvpStatValue">{$stats.prize_pool_arenas_untx20|number_format}</div>
            </div>
            <div class="pvpStatBox yellow">
                <div class="pvpStatLabel">💲 Bote Torneos NTX-20</div>
                <div class="pvpStatValue">{$stats.prize_pool_tourneys_ntx20|number_format}</div>
            </div>
            <div class="pvpStatBox cyan">
                <div class="pvpStatLabel">💲 Bote Torneos UNTX-20</div>
                <div class="pvpStatValue">{$stats.prize_pool_tourneys_untx20|number_format}</div>
            </div>
        </div>

        <div class="pvpCard red">
            <h2 class="red">⚙️ Configuración Global del Sistema PvP</h2>

            <p style="font-size:10px;color:#8899aa;margin-bottom:10px;font-style:italic;">
                💡 Todos los precios se guardan en <b style="color:#ffdd88;">BASE NTX-20</b>.
                Los jugadores QVAPAY pagan automáticamente el doble en UNTX-20.
            </p>

            <form method="POST" action="admin.php?page=pvpadmin&mode=saveConfig&tab=dashboard">

                {* Toggles de activación *}
                <div class="pvpGrid2" style="margin-bottom: 12px;">
                    <label class="pvpToggle_label red">
                        <input type="checkbox" name="arena_enabled" value="1" {if $config.arena_enabled}checked{/if}>
                        <span class="pvpToggle_red">🏟️ Arenas habilitadas</span>
                    </label>
                    <label class="pvpToggle_label yellow">
                        <input type="checkbox" name="tournament_enabled" value="1" {if $config.tournament_enabled}checked{/if}>
                        <span class="pvpToggle_yellow">🏆 Torneos habilitados</span>
                    </label>
                </div>

                <h3 class="pvpSection_title red">
                    💰 Precios de Arenas (BASE NTX-20)
                </h3>
                <div class="pvpGrid4" style="margin-bottom:12px;">
                    <label class="pvpLabel">🎯 1v1 Mínimo (base)
                        <input type="number" name="arena_1v1_min" min="0" value="{$config.arena_1v1_min|default:10}" class="pvpInput">
                    </label>
                    <label class="pvpLabel">🎯 1v1 Máximo (base)
                        <input type="number" name="arena_1v1_max" min="0" value="{$config.arena_1v1_max|default:10000}" class="pvpInput">
                    </label>
                    <label class="pvpLabel">⚔️ Precio 2v2 (base)
                        <input type="number" name="arena_2v2_price" min="0" value="{$config.arena_2v2_price|default:50}" class="pvpInput">
                    </label>
                    <label class="pvpLabel">⚔️ Precio 3v3 (base)
                        <input type="number" name="arena_3v3_price" min="0" value="{$config.arena_3v3_price|default:100}" class="pvpInput">
                    </label>
                </div>

                <h3 class="pvpSection_title red">
                    ⏱️ Tiempos de Arenas
                </h3>
                <div class="pvpGrid4" style="margin-bottom:12px;">
                    <label class="pvpLabel">⌛ Expiración (h)
                        <input type="number" name="arena_expire_hours" min="1" max="168" value="{$config.arena_expire_hours|default:24}" class="pvpInput">
                    </label>
                    <label class="pvpLabel">⏱️ Duración (h)
                        <input type="number" name="arena_duration_hours" min="1" max="168" value="{$config.arena_duration_hours|default:48}" class="pvpInput">
                    </label>
                    <label class="pvpLabel">⚡ Extra empate (h)
                        <input type="number" name="arena_extra_hours" min="1" max="24" value="{$config.arena_extra_hours|default:5}" class="pvpInput">
                    </label>
                    <label class="pvpLabel">🎁 Reclamar en (días)
                        <input type="number" name="arena_claim_days" min="1" max="30" value="{$config.arena_claim_days|default:4}" class="pvpInput">
                    </label>
                </div>

                <h3 class="pvpSection_title yellow">
                    🏆 Configuración de Torneos
                </h3>
                <div class="pvpGrid4" style="margin-bottom:12px;">
                    <label class="pvpLabel">💸 Comisión % (destruido)
                        <input type="number" name="tournament_commission" min="0" max="100" value="{$config.tournament_commission|default:5}" class="pvpInput yellow">
                    </label>
                </div>

                <div class="pvpCenter_actions">
                    <button type="submit" class="pvpBtn red">💾 Guardar Configuración</button>
                </div>
            </form>
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════════
     * PESTAÑA: ARENAS
     * ═══════════════════════════════════════════════════════════ *}
    {if $active_tab == 'arenas'}

        <div class="pvpCard blue">
            <h2 class="blue">
                🏟️ Arenas Activas / En Espera
                <span class="pvpBadge blue" style="margin-left:6px;">{$arenas|@count}</span>
            </h2>

            {if $arenas|@count > 0}
                <table class="pvpTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Creador</th>
                            <th class="center">Modo</th>
                            <th class="center">Estado</th>
                            <th class="center">Jugadores</th>
                            <th class="right">Bote NTX</th>
                            <th class="right">Bote UNTX</th>
                            <th class="center">Creada</th>
                            <th class="center">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $arenas as $a}
                            <tr>
                                <td>#{$a.id}</td>
                                <td style="color:#ffdd88;font-weight:bold;">{$a.creator_name|default:'—'}</td>
                                <td class="center">
                                    <span class="pvpBadge red">{$a.mode_label}</span>
                                </td>
                                <td class="center">{$a.status_label}</td>
                                <td class="center">
                                    <span style="color:#88ffbb;font-weight:bold;">{$a.player_count}</span>
                                    <span style="color:#8899aa;">/ {$a.max_players}</span>
                                </td>
                                <td class="right" style="color:#ffdd88;font-weight:bold;">{$a.pool_ntx20_fmt}</td>
                                <td class="right" style="color:#88ddff;font-weight:bold;">{$a.pool_untx20_fmt}</td>
                                <td class="center" style="font-size:10px;color:#8899aa;">{$a.created_fmt}</td>
                                <td class="center">
                                    <a href="admin.php?page=pvpadmin&mode=cancelArena&id={$a.id}&tab=arenas"
                                       class="pvpBtn small red"
                                       onclick="return confirm('⚠️ ¿Cancelar arena #{$a.id}?\n\nSe devolverá la entrada a TODOS los participantes en su riel.');">
                                        🛑 Cancelar
                                    </a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <p class="pvpEmpty">
                    No hay arenas activas en este momento.
                </p>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════════
     * PESTAÑA: TORNEOS
     * ═══════════════════════════════════════════════════════════ *}
    {if $active_tab == 'tournaments'}

        {* --- Torneo activo --- *}
        {if $active_tournament}

            <div class="pvpCard yellow">
                <h2 class="yellow">
                    🏆 Torneo Activo #{$active_tournament.id}
                    <span class="pvpBadge yellow" style="margin-left:6px;">
                        {if $active_tournament.status == 'registration'}Inscripción{else}En Curso{/if}
                    </span>
                </h2>

                <div class="pvpGrid4" style="margin-bottom:10px;">
                    <div>
                        <div style="font-size:10px;color:#8899aa;">Tipo</div>
                        <div style="color:#ffdd88;font-weight:bold;font-size:14px;">{$active_tournament.type|upper}</div>
                    </div>
                    <div>
                        <div style="font-size:10px;color:#8899aa;">Modo</div>
                        <div style="color:#ffdd88;font-weight:bold;font-size:14px;">
                            {if $active_tournament.mode == 'double_elimination'}Doble{else}Simple{/if}
                        </div>
                    </div>
                    <div>
                        <div style="font-size:10px;color:#8899aa;">Jugadores</div>
                        <div style="color:#88ffbb;font-weight:bold;font-size:14px;">
                            {$active_tournament.current_players}/{$active_tournament.max_players}
                        </div>
                    </div>
                    <div>
                        <div style="font-size:10px;color:#8899aa;">Bote NTX-20</div>
                        <div style="color:#ffdd88;font-weight:bold;font-size:14px;">{$active_tournament.pool_ntx20_fmt}</div>
                    </div>
                    <div>
                        <div style="font-size:10px;color:#8899aa;">Bote UNTX-20</div>
                        <div style="color:#88ddff;font-weight:bold;font-size:14px;">{$active_tournament.pool_untx20_fmt}</div>
                    </div>
                </div>

                <div class="pvpInfoBlock">
                    Inscripciones cierran: <b>{$active_tournament.reg_ends_fmt}</b><br>
                    Entrada 1v1 (base): <b>{$active_tournament.entry_fee_fmt} NTX-20</b>
                    · Entrada Alianza (base): <b>{$active_tournament.afee_fmt} NTX-20</b>
                </div>

                <div class="pvpActions_row">
                    {if $active_tournament.status == 'registration'}
                        <a href="admin.php?page=pvpadmin&mode=forceCloseRegistration&id={$active_tournament.id}&tab=tournaments"
                           class="pvpBtn small blue"
                           onclick="return confirm('⚡ ¿Forzar cierre de inscripciones AHORA?\n\nSe generará el bracket con los jugadores actuales.');">
                            ⚡ Forzar Cierre
                        </a>
                    {/if}
                    <a href="admin.php?page=pvpadmin&mode=cancelTournament&id={$active_tournament.id}&reason=Cancelado+por+admin&tab=tournaments"
                       class="pvpBtn small red"
                       onclick="return confirm('⚠️ ¿Cancelar torneo #{$active_tournament.id}?\n\nSe devolverá la entrada a TODOS los inscritos en su riel.');">
                        🛑 Cancelar Torneo
                    </a>
                </div>
            </div>

            {* --- Jugadores inscritos --- *}
            {if $active_tournament_players|@count > 0}
                <div class="pvpCard yellow">
                    <h2 class="yellow">
                        👥 Jugadores Inscritos
                        <span class="pvpBadge yellow" style="margin-left:6px;">{$active_tournament_players|@count}</span>
                    </h2>

                    <table class="pvpTable">
                        <thead class="yellow">
                            <tr>
                                <th>ID</th>
                                <th>Jugador / Alianza</th>
                                <th class="center">Fuente</th>
                                <th class="center">Estado</th>
                                <th class="center">Acción</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $active_tournament_players as $p}
                                <tr>
                                    <td>#{$p.id}</td>
                                    <td>
                                        {if $p.is_alliance == 1}
                                            <span style="color:#88ddff;">🛡️ [{$p.ally_tag}] {$p.ally_name}</span>
                                        {else}
                                            <span style="color:#ffdd88;">⚔️ {$p.username}</span>
                                        {/if}
                                    </td>
                                    <td class="center" style="font-size:10px;">
                                        {if $p.payment_source == 'bank'}<span class="pvpBadge blue">🏦 Banco</span>
                                        {elseif $p.payment_source == 'user'}<span class="pvpBadge yellow">👤 Cuenta</span>
                                        {else}<span style="color:#667788;">—</span>{/if}
                                    </td>
                                    <td class="center">
                                        {if $p.eliminated == 1}
                                            <span class="pvpBadge red">❌ Eliminado</span>
                                        {elseif $p.final_position > 0}
                                            <span class="pvpBadge green">🏆 #{$p.final_position}</span>
                                        {else}
                                            <span class="pvpBadge green">✅ Activo</span>
                                        {/if}
                                    </td>
                                    <td class="center">
                                        {if $p.eliminated == 0}
                                            <a href="admin.php?page=pvpadmin&mode=disqualifyPlayer&tournament_id={$active_tournament.id}&player_id={$p.id}&reason=Descalificado+por+admin&tab=tournaments"
                                               class="pvpBtn small red"
                                               onclick="return confirm('🚫 ¿Descalificar a este jugador?\n\nNO se le devolverá la entrada.');">
                                                🚫 Descalificar
                                            </a>
                                        {/if}
                                    </td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
            {/if}

        {else}

            <div class="pvpCard yellow">
                <h2 class="yellow">➕ Crear Nuevo Torneo</h2>
                <p style="color:#aabbcc;font-size:11px;margin-bottom:12px;">
                    No hay ningún torneo activo. Puedes crear uno nuevo aquí.<br>
                    💡 Los precios son <b style="color:#ffdd88;">BASE NTX-20</b>. Los jugadores QVAPAY pagan ×2 en UNTX-20.
                </p>

                <form method="POST" action="admin.php?page=pvpadmin&mode=createTournament&tab=tournaments">
                    <div class="pvpGrid3" style="margin-bottom:12px;">
                        <label class="pvpLabel">🎯 Tipo
                            <select name="type" class="pvpInput yellow">
                                <option value="1v1">1v1 Individual</option>
                                <option value="alliance">Alianza</option>
                            </select>
                        </label>
                        <label class="pvpLabel">⚙️ Modo
                            <select name="tmode" class="pvpInput yellow">
                                <option value="single">Eliminación Simple</option>
                                <option value="double_elimination">Doble Oportunidad</option>
                            </select>
                        </label>
                        <label class="pvpLabel">👥 Máx. Jugadores
                            <select name="max_players" class="pvpInput yellow">
                                <option value="8">8</option>
                                <option value="16">16</option>
                                <option value="32">32</option>
                            </select>
                        </label>
                    </div>

                    <div class="pvpGrid4" style="margin-bottom:12px;">
                        <label class="pvpLabel">💎 Entrada 1v1 (base NTX-20)
                            <input type="number" name="entry_fee" min="0" value="100" class="pvpInput yellow">
                        </label>
                        <label class="pvpLabel">🛡️ Entrada Alianza (base NTX-20)
                            <input type="number" name="alliance_entry_fee" min="0" value="500" class="pvpInput yellow">
                        </label>
                        <label class="pvpLabel">⏱️ Duración ronda (h)
                            <input type="number" name="round_hours" min="24" max="48" value="24" class="pvpInput yellow">
                        </label>
                        <label class="pvpLabel">📅 Ventana inscripción (h)
                            <input type="number" name="registration_hours" min="1" max="168" value="24" class="pvpInput yellow">
                        </label>
                    </div>

                    <div class="pvpGrid4" style="margin-bottom:12px;">
                        <label class="pvpLabel">💸 Comisión %
                            <input type="number" name="commission" min="0" max="100" value="{$config.tournament_commission|default:5}" class="pvpInput yellow">
                        </label>
                        <label class="pvpLabel">🥇 1º puesto %
                            <input type="number" name="w1" min="0" max="100" value="70" class="pvpInput yellow">
                        </label>
                        <label class="pvpLabel">🥈 2º puesto %
                            <input type="number" name="w2" min="0" max="100" value="20" class="pvpInput yellow">
                        </label>
                        <label class="pvpLabel">🥉 3º puesto %
                            <input type="number" name="w3" min="0" max="100" value="10" class="pvpInput yellow">
                        </label>
                    </div>

                    <div class="pvpCenter">
                        <button type="submit" class="pvpBtn yellow">➕ Crear Torneo</button>
                    </div>
                </form>
            </div>

        {/if}

    {/if}

    {* ═══════════════════════════════════════════════════════════
     * PESTAÑA: HISTORIAL
     * ═══════════════════════════════════════════════════════════ *}
    {if $active_tab == 'history'}

        <div class="pvpCard green">
            <h2 class="green">🏟️ Arenas Recientes (finalizadas / canceladas)</h2>

            {if $history_arenas|@count > 0}
                <table class="pvpTable">
                    <thead class="green">
                        <tr>
                            <th>ID</th>
                            <th>Creador</th>
                            <th class="center">Modo</th>
                            <th class="center">Estado</th>
                            <th class="right">Bote NTX</th>
                            <th class="right">Bote UNTX</th>
                            <th class="center">Ganador</th>
                            <th class="center">Finalizó</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $history_arenas as $a}
                            <tr>
                                <td>#{$a.id}</td>
                                <td>{$a.creator_name|default:'—'}</td>
                                <td class="center"><span class="pvpBadge red">{$a.mode_label}</span></td>
                                <td class="center">{$a.status_label}</td>
                                <td class="right" style="color:#ffdd88;">{$a.pool_ntx20_fmt}</td>
                                <td class="right" style="color:#88ddff;">{$a.pool_untx20_fmt}</td>
                                <td class="center">
                                    {if $a.status == 'finished'}
                                        <span class="pvpBadge green">Equipo {$a.winner_team}</span>
                                    {else}
                                        <span style="color:#8899aa;">—</span>
                                    {/if}
                                </td>
                                <td class="center" style="font-size:10px;color:#8899aa;">{$a.finished_fmt}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <p class="pvpEmpty">
                    No hay arenas finalizadas todavía.
                </p>
            {/if}
        </div>

        <div class="pvpCard yellow">
            <h2 class="yellow">🏆 Torneos Recientes</h2>

            {if $recent_tournaments|@count > 0}
                <table class="pvpTable">
                    <thead class="yellow">
                        <tr>
                            <th>ID</th>
                            <th class="center">Tipo</th>
                            <th class="center">Modo</th>
                            <th class="center">Estado</th>
                            <th class="center">Jugadores</th>
                            <th class="right">Bote NTX</th>
                            <th class="right">Bote UNTX</th>
                            <th class="center">Finalizó</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $recent_tournaments as $t}
                            <tr>
                                <td>#{$t.id}</td>
                                <td class="center">{$t.type}</td>
                                <td class="center">
                                    {if $t.mode == 'double_elimination'}Doble{else}Simple{/if}
                                </td>
                                <td class="center">{$t.status_label}</td>
                                <td class="center" style="color:#88ffbb;">{$t.current_players}/{$t.max_players}</td>
                                <td class="right" style="color:#ffdd88;">{$t.pool_ntx20_fmt}</td>
                                <td class="right" style="color:#88ddff;">{$t.pool_untx20_fmt}</td>
                                <td class="center" style="font-size:10px;color:#8899aa;">{$t.finished_fmt}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <p class="pvpEmpty">
                    No hay torneos finalizados todavía.
                </p>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════════
     * PESTAÑA: ACCIONES
     * ═══════════════════════════════════════════════════════════ *}
    {if $active_tab == 'actions'}

        <div class="pvpActionCard">
            <h2>🧹 Forzar Cron PvP</h2>
            <p>
                Ejecuta manualmente el cron PvP sin esperar al ciclo automático de 5 minutos.<br>
                Procesa: arenas expiradas · arenas activas · cierres de inscripción · resolución de rondas · notificaciones.
            </p>
            <div class="pvpCenter">
                <a href="admin.php?page=pvpadmin&mode=forceCron&tab=actions"
                   class="pvpBtn cyan"
                   onclick="return confirm('⚙️ ¿Ejecutar el cron PvP AHORA?');">
                    ⚙️ Ejecutar Cron Ahora
                </a>
            </div>
        </div>

        <div class="pvpActionCard">
            <h2>💎 Devolver Saldo a un Jugador</h2>
            <p>
                Devuelve manualmente saldo a un jugador (por ejemplo, si hubo un bug o una cancelación manual).<br>
                💡 El sistema <b>detecta automáticamente el riel del jugador</b>:
                si es CUP se acredita en <b>NTX-20</b>, si es QVAPAY en <b>UNTX-20</b>.<br>
                Esta acción queda registrada en el log PvP.
            </p>

            <form method="POST" action="admin.php?page=pvpadmin&mode=refundUser&tab=actions"
                  onsubmit="return confirm('💎 ¿Confirmar devolución de saldo?');">
                <div class="pvpGrid3" style="margin-bottom:10px;">
                    <label class="pvpLabel">🆔 ID del jugador
                        <input type="number" name="user_id" min="1" required class="pvpInput">
                    </label>
                    <label class="pvpLabel">💎 Cantidad (en su moneda)
                        <input type="number" name="amount" min="1" required class="pvpInput">
                    </label>
                    <label class="pvpLabel">📝 Motivo
                        <input type="text" name="reason" value="Devolución manual" class="pvpInput">
                    </label>
                </div>
                <div class="pvpCenter">
                    <button type="submit" class="pvpBtn yellow">💎 Devolver Saldo</button>
                </div>
            </form>
        </div>

        <div class="pvpActionCard">
            <h2>🔧 Información</h2>
            <div class="pvpInfoLinks">
                <p>
                    <span class="label">✅ Configuración:</span> <a href="admin.php?page=pvpadmin&tab=dashboard">Dashboard</a><br>
                    <span class="label">🏟️ Arenas activas:</span> <a href="admin.php?page=pvpadmin&tab=arenas">Arenas</a><br>
                    <span class="label">🏆 Torneos:</span> <a href="admin.php?page=pvpadmin&tab=tournaments">Torneos</a><br>
                    <span class="label">📜 Historial:</span> <a href="admin.php?page=pvpadmin&tab=history">Historial</a>
                </p>
            </div>
        </div>

    {/if}

    <p class="pvpFooter">
        🚧 Panel Admin PvP — AstroIO v2.0 · Doble Riel (NTX-20 / UNTX-20)
    </p>
</div>

{include file="overall_footer.tpl"}