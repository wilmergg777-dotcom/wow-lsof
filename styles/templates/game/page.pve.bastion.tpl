{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pve.bastion.tpl === *}
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
/* ═══════════════════════════════════════════════════════════
   PvE — Bastión Asediado
   AstroIO v4.0 — Glassmorphism + Acento Cyan/Azul + Dual-Riel
   Prefijo: .pveBastion / .bastion*
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

.pveBastionWrap {
    max-width: 1000px;
    margin: 0 auto;
    padding: 16px;
    color: var(--text-main);
    font-family: 'Segoe UI', Roboto, sans-serif;
    font-size: 13px;
}

.pveBastionWrap h1 {
    color: #66ccff;
    text-align: center;
    font-size: 22px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(50, 150, 255, 0.6);
    letter-spacing: 1px;
}

/* ─── v4.0 — BADGE DE SALDO ────────────────────────────── */
.bastionBalanceBar {
    display: flex;
    justify-content: center;
    margin-bottom: 18px;
}

.bastionBalanceBadge {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 10px 22px;
    background: rgba(0, 0, 0, 0.55);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-radius: 14px;
    font-family: 'Courier New', monospace;
    transition: all 0.25s ease;
}
.bastionBalanceBadge:hover { transform: translateY(-1px); }

.bastionBalanceBadge.cup {
    border: 1px solid rgba(251, 191, 36, 0.6);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
    color: #ffee88;
}
.bastionBalanceBadge.cup:hover {
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.5);
}

.bastionBalanceBadge.qvapay {
    border: 1px solid rgba(0, 224, 255, 0.6);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.25);
    color: #88ffff;
}
.bastionBalanceBadge.qvapay:hover {
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.5);
}

.bastionBalanceLabel {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.bastionBalanceValue {
    font-size: 17px;
    font-weight: bold;
    letter-spacing: 0.5px;
}

.bastionBalanceCurrency {
    font-size: 12px;
    opacity: 0.9;
    font-weight: bold;
    letter-spacing: 0.5px;
}

/* ─── Tabs ─────────────────────────────────────────────── */
.bastionTabs {
    display: flex;
    gap: 8px;
    justify-content: center;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.bastionTab {
    padding: 10px 18px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    color: #66ccff;
    background: rgba(50, 150, 255, 0.15);
    border: 1px solid rgba(100, 200, 255, 0.5);
    transition: all 0.25s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.bastionTab:hover {
    background: rgba(50, 150, 255, 0.3);
    color: #fff;
    transform: translateY(-2px);
    box-shadow: 0 0 14px rgba(50, 150, 255, 0.4);
}

.bastionTab.active {
    background: linear-gradient(135deg, #1a7fd4, #44aaff);
    color: #fff;
    border-color: #44aaff;
    box-shadow: 0 4px 14px rgba(50, 150, 255, 0.5);
}

/* ─── Cards ────────────────────────────────────────────── */
.bastionCard {
    background: linear-gradient(160deg, rgba(10, 30, 60, 0.75), rgba(5, 15, 30, 0.75));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(50, 150, 255, 0.5);
    border-radius: 14px;
    padding: 18px;
    margin-bottom: 16px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: 0.25s ease;
}
.bastionCard:hover {
    border-color: rgba(50, 150, 255, 0.7);
    box-shadow: 0 8px 30px rgba(50, 150, 255, 0.2), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.bastionCard.registration {
    background: linear-gradient(160deg, rgba(10, 40, 60, 0.75), rgba(20, 60, 90, 0.75));
    border-color: rgba(0, 200, 255, 0.5);
}

.bastionCard h2 {
    margin: 0 0 12px 0;
    font-size: 15px;
    color: #99ddff;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    text-shadow: 0 0 8px rgba(50, 150, 255, 0.3);
}

/* ─── Badge de estado ──────────────────────────────────── */
.bastionStatus {
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: bold;
    white-space: nowrap;
}

.bastionStatus.scheduled {
    background: rgba(148, 163, 184, 0.3);
    color: #cccccc;
    border: 1px solid rgba(180, 180, 180, 0.5);
}

.bastionStatus.registration {
    background: rgba(0, 224, 255, 0.25);
    color: #88ddff;
    border: 1px solid rgba(0, 224, 255, 0.6);
}

.bastionStatus.active {
    background: rgba(74, 255, 136, 0.25);
    color: #88ffbb;
    border: 1px solid rgba(74, 255, 136, 0.6);
    animation: bastionPulse 1.4s infinite;
}

.bastionStatus.finished {
    background: rgba(100, 150, 255, 0.25);
    color: #99bbff;
    border: 1px solid rgba(150, 200, 255, 0.6);
}

.bastionStatus.cancelled {
    background: rgba(251, 191, 36, 0.25);
    color: #ffaa66;
    border: 1px solid rgba(251, 191, 36, 0.6);
}

@keyframes bastionPulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50%      { opacity: 0.65; transform: scale(1.03); }
}

/* ─── Grid de datos ────────────────────────────────────── */
.bastionGrid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 10px;
    margin-bottom: 14px;
}

.bastionGridItem {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px 12px;
}

.bastionGridLabel {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.bastionGridValue {
    font-size: 14px;
    color: #ffee88;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}

.bastionGridValue.cup    { color: #ffee88; }
.bastionGridValue.qvapay { color: #88ffff; text-shadow: 0 0 8px rgba(0, 224, 255, 0.3); }
.bastionGridValue.mine   { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.3); }

/* ─── Countdown box ────────────────────────────────────── */
.bastionCountdown {
    text-align: center;
    padding: 18px 10px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    margin: 14px 0;
}

.bastionCountdownLabel {
    font-size: 11px;
    color: var(--text-muted);
    letter-spacing: 1.5px;
    text-transform: uppercase;
    margin-bottom: 8px;
}

.bastionCountdownValue {
    font-size: 32px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    color: #ffee88;
    line-height: 1.1;
    text-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}

/* ─── Botones grandes ──────────────────────────────────── */
.bastionBtnBig {
    display: block;
    width: 100%;
    max-width: 400px;
    margin: 16px auto 0;
    padding: 16px 24px;
    background: linear-gradient(135deg, #1565c0, #42a5f5);
    color: #fff;
    border: 1px solid #42a5f5;
    border-radius: 10px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    text-align: center;
    box-shadow: 0 6px 20px rgba(50, 150, 255, 0.5);
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    letter-spacing: 0.5px;
}

.bastionBtnBig:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 26px rgba(80, 180, 255, 0.7);
    background: linear-gradient(135deg, #42a5f5, #64b5f6);
}

.bastionBtnBig.green {
    background: linear-gradient(135deg, #228833, #4aff88);
    border-color: var(--accent-green);
    box-shadow: 0 6px 20px rgba(74, 255, 136, 0.5);
}

.bastionBtnBig.green:hover {
    box-shadow: 0 8px 26px rgba(74, 255, 136, 0.7);
    background: linear-gradient(135deg, #4aff88, #86ffb8);
    color: #1a1000;
}

/* ─── HP bar ───────────────────────────────────────────── */
.bastionHpBar {
    height: 16px;
    background: rgba(0, 0, 0, 0.6);
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid rgba(50, 150, 255, 0.4);
    margin: 6px 0;
}

.bastionHpFill {
    height: 100%;
    background: linear-gradient(90deg, #228833, #44ddaa, #88ffcc);
    transition: width 0.5s ease;
    box-shadow: 0 0 10px rgba(74, 255, 136, 0.4) inset;
}

.bastionHpFill.low {
    background: linear-gradient(90deg, #aa2200, #ff8833, #ffcc44);
    box-shadow: 0 0 10px rgba(239, 68, 68, 0.5) inset;
}

/* ─── Tabla ranking ────────────────────────────────────── */
.bastionTable {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
    margin-top: 8px;
}

.bastionTable thead th {
    padding: 8px 6px;
    text-align: left;
    color: #99ddff;
    font-size: 10px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid rgba(50, 150, 255, 0.3);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.bastionTable tbody td {
    padding: 8px 6px;
    border-bottom: 1px solid var(--border-color);
    color: var(--text-main);
}

.bastionTable tbody tr:hover {
    background: rgba(50, 150, 255, 0.06);
}

.bastionTable tbody tr.my-ally {
    background: rgba(251, 191, 36, 0.08);
    border-left: 3px solid var(--accent-gold);
}

.bastionTable tbody tr.breached-row {
    opacity: 0.5;
}

.bastionTable .center { text-align: center; }
.bastionTable .right  { text-align: right; }

.bastionTable .pos {
    color: var(--accent-gold);
    font-weight: bold;
    font-size: 14px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

.bastionTable .score {
    color: #ffee88;
    font-family: 'Courier New', monospace;
}

.bastionTable .pct {
    color: #88ffbb;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.3);
}

/* ─── Fases ────────────────────────────────────────────── */
.phase-badge {
    display: inline-block;
    padding: 3px 9px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: bold;
}

.phase-1 { background: rgba(74, 255, 136, 0.2); color: #88ffbb; border: 1px solid var(--accent-green); }
.phase-2 { background: rgba(251, 191, 36, 0.2); color: #ffee88; border: 1px solid var(--accent-gold); }
.phase-3 { background: rgba(251, 191, 36, 0.2); color: #ffaa66; border: 1px solid var(--accent-gold); }
.phase-4 { background: rgba(239, 68, 68, 0.25); color: #ff8888; border: 1px solid var(--accent-red); }

/* ─── Flash ────────────────────────────────────────────── */
.bastionFlash {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 13px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.bastionFlash.success {
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: #88ffbb;
}

.bastionFlash.error {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: #ffbbbb;
}

.bastionFlash.info {
    background: rgba(0, 224, 255, 0.15);
    border: 1px solid rgba(0, 224, 255, 0.5);
    color: #88ddff;
}

/* ─── Coord box ────────────────────────────────────────── */
.bastionCoords {
    display: inline-block;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 2px solid var(--accent-gold);
    border-radius: 8px;
    padding: 8px 16px;
    font-size: 20px;
    color: var(--accent-gold);
    font-weight: bold;
    font-family: 'Courier New', monospace;
    letter-spacing: 2px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.5);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
}

/* ─── Waves box ────────────────────────────────────────── */
.wavesList {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px;
    margin-top: 8px;
}

.waveRow {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 6px 10px;
    border-bottom: 1px dashed rgba(255, 255, 255, 0.08);
    font-size: 11px;
}

.waveRow:last-child {
    border-bottom: none;
}

.waveRow .waveNum {
    color: var(--accent-gold);
    font-weight: bold;
    font-family: 'Courier New', monospace;
}

.waveRow .wavePhase {
    color: #99ddff;
    margin: 0 10px;
}

.waveRow .waveTime {
    color: #ffaa66;
    font-family: 'Courier New', monospace;
    font-weight: bold;
}

.waveRow.boss {
    background: rgba(239, 68, 68, 0.08);
    border-left: 3px solid var(--accent-red);
}

/* ─── Empty state ──────────────────────────────────────── */
.bastionEmpty {
    text-align: center;
    color: var(--text-muted);
    padding: 40px 20px;
    font-size: 13px;
}

.bastionEmpty .big {
    font-size: 40px;
    display: block;
    margin-bottom: 12px;
    opacity: 0.5;
}

/* ─── Logros badges ────────────────────────────────────── */
.achvBadge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: bold;
    margin: 2px;
    background: rgba(50, 150, 255, 0.15);
    border: 1px solid rgba(100, 200, 255, 0.5);
    color: #99ddff;
}

@media (max-width: 720px) {
    /* Wrap padding global */
    .pveBastionWrap { padding: 12px; }

    /* Tabs → grid 2×N + huérfano full-width */
    .bastionTabs {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 10px !important;
        margin-bottom: 15px !important;
    }
    .bastionTab {
        padding: 8px 4px !important;
        font-size: 10px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
    }
    .bastionTab:last-child:nth-child(odd) {
        grid-column: 1 / -1 !important;
    }

    /* Balance badge */
    .bastionBalanceBar { flex-direction: column !important; gap: 8px; }
    .bastionBalanceBadge {
        width: 100% !important;
        max-width: 100% !important;
        padding: 11px 10px !important;
        justify-content: center !important;
        box-sizing: border-box !important;
    }

    /* Grid de datos → 1 columna */
    .bastionGrid { grid-template-columns: 1fr !important; }

    /* Countdown / coords / botón */
    .bastionCountdownValue { font-size: 26px !important; }
    .bastionCoords { font-size: 16px !important; letter-spacing: 1px !important; }
    .bastionBtnBig {
        max-width: 100% !important;
        padding: 14px 16px !important;
        box-sizing: border-box !important;
    }

    /* Waves + headers de card */
    .waveRow { flex-wrap: wrap !important; gap: 4px !important; }
    .bastionCard h2 { flex-wrap: wrap !important; }

    /* ═══ TABLAS → TARJETAS ═══ */
    .bastionTable {
        border-collapse: separate !important;
        border-spacing: 0 !important;
        margin-top: 10px !important;
    }
    .bastionTable thead { display: none !important; }
    .bastionTable,
    .bastionTable tbody,
    .bastionTable tbody tr,
    .bastionTable tbody td {
        display: block !important;
        width: 100% !important;
        box-sizing: border-box !important;
    }
    .bastionTable tbody tr {
        background: rgba(0, 0, 0, 0.35) !important;
        border: 1px solid rgba(50, 150, 255, 0.35) !important;
        border-radius: 10px !important;
        padding: 12px !important;
        margin-bottom: 10px !important;
    }
    .bastionTable tbody tr.my-ally {
        background: rgba(251, 191, 36, 0.1) !important;
        border-color: rgba(251, 191, 36, 0.5) !important;
        border-left: 4px solid var(--accent-gold) !important;
    }
    .bastionTable tbody tr.breached-row { opacity: 0.55 !important; }
    .bastionTable tbody tr:hover { background: rgba(0, 0, 0, 0.45) !important; }
    .bastionTable tbody tr.my-ally:hover { background: rgba(251, 191, 36, 0.15) !important; }
    .bastionTable tbody td {
        padding: 0 !important;
        border: none !important;
        font-size: 12px !important;
        text-align: left !important;
    }

    /* Ranking: pos + nombre arriba, datos en grid */
    .bastionTable.ranking tbody tr {
        display: grid !important;
        grid-template-columns: auto 1fr auto;
        grid-template-areas:
            "pos name status"
            "score pirate members"
            "pct pct pct";
        gap: 6px 10px !important;
    }
    .bastionTable.ranking tbody td:nth-child(1) {
        grid-area: pos;
        justify-self: end;
        font-size: 16px !important;
    }
    .bastionTable.ranking tbody td:nth-child(1)::before {
        content: "#";
        opacity: 0.7;
        margin-right: 1px;
    }
    .bastionTable.ranking tbody td:nth-child(2) { grid-area: name; font-weight: bold; }
    .bastionTable.ranking tbody td:nth-child(3) { grid-area: score; }
    .bastionTable.ranking tbody td:nth-child(4) { grid-area: pirate; }
    .bastionTable.ranking tbody td:nth-child(5) { grid-area: pct; }
    .bastionTable.ranking tbody td:nth-child(6) { grid-area: members; }
    .bastionTable.ranking tbody td:nth-child(7) {
        grid-area: status;
        text-align: right !important;
        font-size: 11px !important;
    }
    .bastionTable.ranking tbody td:nth-child(7)::before {
        content: "— ";
        color: #8899aa;
    }

    /* Contribución: jugador arriba, 2×2 datos */
    .bastionTable.contrib tbody tr {
        display: grid !important;
        grid-template-columns: 1fr 1fr;
        grid-template-areas:
            "player player"
            "sent lost"
            "killed killed";
        gap: 6px 10px !important;
    }
    .bastionTable.contrib tbody td:nth-child(1) { grid-area: player; font-weight: bold; }
    .bastionTable.contrib tbody td:nth-child(2) { grid-area: sent; }
    .bastionTable.contrib tbody td:nth-child(3) { grid-area: lost; }
    .bastionTable.contrib tbody td:nth-child(4) { grid-area: killed; }

    /* Labels dinámicos */
    .bastionTable.ranking tbody td:nth-child(3)::before,
    .bastionTable.ranking tbody td:nth-child(4)::before,
    .bastionTable.ranking tbody td:nth-child(5)::before,
    .bastionTable.ranking tbody td:nth-child(6)::before,
    .bastionTable.contrib tbody td:nth-child(2)::before,
    .bastionTable.contrib tbody td:nth-child(3)::before,
    .bastionTable.contrib tbody td:nth-child(4)::before {
        content: attr(data-label) ": ";
        color: #99ddff;
        font-size: 10px;
        text-transform: uppercase;
        font-weight: bold;
        margin-right: 4px;
    }
}
</style>

<div class="pveBastionWrap">

    <h1>⚓ Bastión Asediado</h1>

    {* ─── v4.0 — BADGE DE SALDO ─── *}
    {if isset($moneda) && isset($saldo_actual)}
        <div class="bastionBalanceBar">
            <div class="bastionBalanceBadge {if $es_internacional}qvapay{else}cup{/if}">
                <span class="bastionBalanceLabel">💰 Saldo:</span>
                <span class="bastionBalanceValue">{$saldo_actual|number_format}</span>
                <span class="bastionBalanceCurrency">{$moneda}</span>
            </div>
        </div>
    {/if}

    {* ─── TABS ─── *}
    <div class="bastionTabs">
        <a href="game.php?page=pve" class="bastionTab">🏠 Panel Principal</a>
        <a href="game.php?page=pve&mode=empire" class="bastionTab">🏛️ Imperio Caído</a>
        <a href="game.php?page=pve&mode=achievements" class="bastionTab">🏆 Logros</a>
        <a href="game.php?page=pve&mode=boss" class="bastionTab">🌌 Torneo del Devorador</a>
        <a href="game.php?page=pve&mode=bastion" class="bastionTab active">⚓ Bastión Asediado</a>
    </div>

    {* ─── FLASH MESSAGES ─── *}
    {if $bastionResult}
        <div class="bastionFlash success">
            ✅ {$bastionResult.message|escape:'html'}
        </div>
    {/if}

    {if $bastionError}
        <div class="bastionFlash error">
            ❌ {$bastionError|escape:'html'}
        </div>
    {/if}

    {* ─── SI NO HAY EVENTO ─── *}
    {if !$pve_bastion.event}
        <div class="bastionCard">
            <div class="bastionEmpty">
                <span class="big">⚓</span>
                <strong style="color:#99ddff;font-size:16px;">No hay ningún Bastión activo ahora mismo</strong>
                <br><br>
                El Bastión Asediado es un evento por alianzas donde defendéis un planeta fortaleza contra oleadas piratas.
                <br>
                Cuando se programe el próximo evento, aparecerá aquí.
                <br><br>
                <span style="font-size:11px;color:#667788;">
                    Mantente atento a las notificaciones.
                </span>
            </div>
        </div>
    {else}

        {assign var=event value=$pve_bastion.event}
        {assign var=pp    value=$pve_bastion.pool_preview}

        {* ─── CARD DEL EVENTO ─── *}
        <div class="bastionCard">
            <h2>
                <span>⚓ {$event.bastion_name|escape:'html'}</span>
                <span class="bastionStatus {$event.status}">
                    {if $event.status == 'scheduled'}⏰ Programado
                    {elseif $event.status == 'registration'}📝 Registro Abierto
                    {elseif $event.status == 'active'}🛡️ ACTIVO
                    {elseif $event.status == 'finished'}🏁 Finalizado
                    {elseif $event.status == 'cancelled'}🛑 Cancelado
                    {/if}
                </span>
            </h2>

            <div class="bastionGrid">
                <div class="bastionGridItem">
                    <div class="bastionGridLabel">Modo de entrada</div>
                    <div class="bastionGridValue">
                        {if $event.entry_mode == 'paid'}💰 Pago{else}🆓 Gratis{/if}
                    </div>
                </div>
                <div class="bastionGridItem">
                    <div class="bastionGridLabel">Premio</div>
                    <div class="bastionGridValue">
                        {if $event.prize_type == 'ntx'}💎 NTX-20
                        {elseif $event.prize_type == 'metal'}🔩 Metal
                        {elseif $event.prize_type == 'crystal'}💠 Cristal
                        {elseif $event.prize_type == 'deuterium'}⚗️ Deuterio
                        {elseif $event.prize_type == 'dark_matter'}🌑 Mat. Oscura
                        {elseif $event.prize_type == 'mixed'}🎁 Mixto
                        {else}{$event.prize_type|upper}{/if}
                    </div>
                </div>
                <div class="bastionGridItem">
                    <div class="bastionGridLabel">Duración</div>
                    <div class="bastionGridValue">{$event.duration_hours|default:48}h</div>
                </div>
                <div class="bastionGridItem">
                    <div class="bastionGridLabel">Alianzas</div>
                    <div class="bastionGridValue">min {$event.min_alliances|default:2} / max {$event.max_alliances|default:20}</div>
                </div>
            </div>

            {* ─── v4.0 — POOLS / PREMIOS DUALES ─── *}
            {if $event.entry_mode == 'paid'}

                <div class="bastionGrid" style="margin-top:4px;">
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">💰 Pool NTX-20 (CUP)</div>
                        <div class="bastionGridValue cup">{$pp.pool_ntx20|default:0|number_format}</div>
                    </div>
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">💰 Pool UNTX-20 (QVAPAY)</div>
                        <div class="bastionGridValue qvapay">{$pp.pool_untx20|default:0|number_format}</div>
                    </div>
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">💎 Premio NTX-20 (CUP)</div>
                        <div class="bastionGridValue cup">{$pp.prize_ntx20|default:0|number_format}</div>
                    </div>
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">💎 Premio UNTX-20 (QVAPAY)</div>
                        <div class="bastionGridValue qvapay">{$pp.prize_untx20|default:0|number_format}</div>
                    </div>
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">📊 Fee del proyecto</div>
                        <div class="bastionGridValue">{$pp.fee_pct|default:5}%</div>
                    </div>
                </div>

                <div class="bastionGrid" style="margin-top:4px;">
                    <div class="bastionGridItem" style="grid-column: 1 / -1; background: rgba(74,255,136,0.08); border-color: rgba(74,255,136,0.4);">
                        <div class="bastionGridLabel">🎯 Tu premio si ganáis (riel {$pp.my_currency|default:$moneda}):</div>
                        <div class="bastionGridValue mine">
                            {$pp.my_prize|default:0|number_format} {$pp.my_currency|default:$moneda}
                            <span style="font-size:10px;color:#8899aa;font-weight:normal;margin-left:8px;">
                                (pool {$pp.my_pool|default:0|number_format} − fee {$pp.my_fee|default:0|number_format})
                            </span>
                        </div>
                    </div>
                </div>

            {else}

                {if $pp.my_prize > 0}
                    <div class="bastionGrid" style="margin-top:4px;">
                        <div class="bastionGridItem" style="grid-column: 1 / -1; background: rgba(74,255,136,0.08); border-color: rgba(74,255,136,0.4);">
                            <div class="bastionGridLabel">🎁 Tu premio si ganáis (riel {$pp.my_currency|default:$moneda}):</div>
                            <div class="bastionGridValue mine">
                                {$pp.my_prize|default:0|number_format} {$pp.my_currency|default:$moneda}
                            </div>
                        </div>
                    </div>
                {/if}

                {if $event.prize_metal > 0 || $event.prize_crystal > 0 || $event.prize_deuterium > 0 || $event.prize_dark_matter > 0}
                    <div class="bastionGrid" style="margin-top:4px;">
                        {if $event.prize_metal > 0}
                            <div class="bastionGridItem">
                                <div class="bastionGridLabel">🔩 Metal</div>
                                <div class="bastionGridValue">{$event.prize_metal|number_format}</div>
                            </div>
                        {/if}
                        {if $event.prize_crystal > 0}
                            <div class="bastionGridItem">
                                <div class="bastionGridLabel">💠 Cristal</div>
                                <div class="bastionGridValue">{$event.prize_crystal|number_format}</div>
                            </div>
                        {/if}
                        {if $event.prize_deuterium > 0}
                            <div class="bastionGridItem">
                                <div class="bastionGridLabel">⚗️ Deuterio</div>
                                <div class="bastionGridValue">{$event.prize_deuterium|number_format}</div>
                            </div>
                        {/if}
                        {if $event.prize_dark_matter > 0}
                            <div class="bastionGridItem">
                                <div class="bastionGridLabel">🌑 Materia Oscura</div>
                                <div class="bastionGridValue">{$event.prize_dark_matter|number_format}</div>
                            </div>
                        {/if}
                    </div>
                {/if}

            {/if}

            {* ─── COUNTDOWN ─── *}
            {if $event.status == 'scheduled'}
                <div class="bastionCountdown" id="bastionCountdown">
                    <div class="bastionCountdownLabel">⏱️ El evento comienza en:</div>
                    <div class="bastionCountdownValue" id="bastionCountdownValue">--</div>
                </div>
            {elseif $event.status == 'registration'}
                <div class="bastionCountdown" id="bastionCountdown">
                    <div class="bastionCountdownLabel">📝 El registro cierra en:</div>
                    <div class="bastionCountdownValue" id="bastionCountdownValue">--</div>
                </div>
            {elseif $event.status == 'active'}
                <div class="bastionCountdown" id="bastionCountdown">
                    <div class="bastionCountdownLabel">🛡️ El evento termina en:</div>
                    <div class="bastionCountdownValue" id="bastionCountdownValue">--</div>
                </div>
            {/if}

            {* Fechas exactas *}
            <div style="font-size:11px;color:#8899aa;text-align:center;margin-top:10px;">
                ⏰ Registro: {$event.registration_start|date_format:"%d/%m/%Y %H:%M"} → {$event.registration_end|date_format:"%d/%m/%Y %H:%M"}<br>
                🛡️ Asedio: {$event.start_time|date_format:"%d/%m/%Y %H:%M"} → {$event.end_time|date_format:"%d/%m/%Y %H:%M"}
            </div>
        </div>

        {* ─── INSCRIPCIÓN ─── *}
        {if $event.status == 'registration'}

            {if $pve_bastion.my_ally_id == 0}
                <div class="bastionCard registration">
                    <h2>📝 Inscripción</h2>
                    <div class="bastionEmpty">
                        ⚠️ <strong>Debes pertenecer a una alianza</strong> para participar.
                        <br><br>
                        Únete a una alianza para poder inscribirte en el evento.
                    </div>
                </div>
            {elseif $pve_bastion.my_registration}
                <div class="bastionCard registration">
                    <h2>✅ Tu alianza está inscrita</h2>
                    <div style="text-align:center;padding:14px;">
                        <span style="color:#88ffbb;font-size:15px;font-weight:bold;">
                            [{if $pve_bastion.my_ally_tag}{$pve_bastion.my_ally_tag}{else}?{/if}] {$pve_bastion.my_ally_name}
                        </span>
                        <br><br>
                        <span style="color:#8899aa;font-size:12px;">
                            Esperando a que empiece el asedio. Serás notificado con las coordenadas del Bastión.
                        </span>
                    </div>
                </div>
            {elseif $pve_bastion.can_register}
                <div class="bastionCard registration">
                    <h2>📝 Inscribe tu alianza</h2>
                    <div style="text-align:center;padding:10px 0;">
                        <p style="color:#aabbcc;margin-bottom:16px;">
                            Como <strong style="color:#ffcc33;">líder</strong> de tu alianza, puedes inscribirla en el evento.
                            <br>

                            {* v4.0 — Coste dual-riel *}
                            {if $event.entry_mode == 'paid'}
                                {if $pp.entry_cost_real > 0}
                                    <span style="color:#ffee88;">
                                        💰 Coste en tu riel (<strong>{$pp.entry_cost_currency|default:$moneda}</strong>):
                                        <strong>{$pp.entry_cost_real|number_format}</strong>
                                    </span>
                                    <br>
                                    <span style="font-size:10px;color:#8899aa;">
                                        (Base NTX-20: {$pp.entry_cost_base|default:0|number_format})
                                    </span>
                                {else}
                                    <span style="color:#ffee88;">💰 Coste: <strong>{$event.entry_cost_ntx|default:50} NTX-20</strong> (base)</span>
                                {/if}
                            {else}
                                <span style="color:#88ffbb;">🆓 Inscripción gratuita</span>
                            {/if}
                        </p>

                        <form method="POST" action="game.php?page=pve&mode=registerBastion">
                            <button type="submit" class="bastionBtnBig">
                                📝 Inscribir mi alianza
                            </button>
                        </form>
                    </div>
                </div>
            {else}
                <div class="bastionCard registration">
                    <h2>📝 Inscripción</h2>
                    <div class="bastionEmpty">
                        ℹ️ Solo el <strong>líder</strong> de la alianza puede inscribirla en el evento.
                        <br><br>
                        <span style="font-size:11px;color:#667788;">
                            Pide a tu líder que la inscriba antes de que cierre el registro.
                        </span>
                    </div>
                </div>
            {/if}
        {/if}

        {* ─── BASTIÓN ACTIVO DE MI ALIANZA ─── *}
        {if $event.status == 'active'}

            {if $pve_bastion.my_active_ghost}
                {assign var=g value=$pve_bastion.my_active_ghost}
                {assign var=hpPct value=0}
                {if $g.hp_max > 0}
                    {assign var=hpPct value=($g.hp_current / $g.hp_max * 100)|round:1}
                {/if}

                <div class="bastionCard">
                    <h2>
                        <span>⚓ Vuestro Bastión</span>
                        <span class="phase-badge phase-{$g.phase|default:1}">
                            {if $g.phase == 1}I — CALMA
                            {elseif $g.phase == 2}II — OLEADA
                            {elseif $g.phase == 3}III — ASEDIO
                            {elseif $g.phase == 4}IV — INFIERNO
                            {/if}
                        </span>
                    </h2>

                    <div style="text-align:center;padding:16px 0;">
                        <div class="bastionGridLabel">📍 Coordenadas del Bastión</div>
                        <div class="bastionCoords">
                            [{$g.galaxy}:{$g.system}:{$g.planet}]
                        </div>
                    </div>

                    <div style="margin-top:14px;">
                        <div style="display:flex;justify-content:space-between;font-size:11px;color:#8899aa;margin-bottom:4px;">
                            <span>💚 HP del Bastión</span>
                            <span><strong style="color:#88ffbb;">{$g.hp_current|number_format}</strong> / {$g.hp_max|number_format} ({$hpPct}%)</span>
                        </div>
                        <div class="bastionHpBar">
                            <div class="bastionHpFill{if $hpPct < 30} low{/if}" style="width:{$hpPct}%;"></div>
                        </div>
                    </div>

                    {if $pve_bastion.pending_waves|@count > 0}
                        <div style="margin-top:16px;">
                            <div style="font-size:11px;color:#ff8888;font-weight:bold;margin-bottom:6px;">
                                ⚠️ OLEADAS PIRATAS EN CAMINO ({$pve_bastion.pending_waves|@count})
                            </div>
                            <div class="wavesList">
                                {foreach $pve_bastion.pending_waves as $w}
                                    <div class="waveRow{if $w.is_boss_wave} boss{/if}">
                                        <span class="waveNum">#{if $w.wave_number}{$w.wave_number}{else}?{/if}</span>
                                        <span class="wavePhase">
                                            {if $w.phase == 'calm'}CALMA
                                            {elseif $w.phase == 'surge'}OLEADA
                                            {elseif $w.phase == 'siege'}ASEDIO
                                            {elseif $w.phase == 'hell'}INFIERNO
                                            {else}{$w.phase|upper}{/if}
                                            {if $w.is_boss_wave} · 💀 JEFE{/if}
                                        </span>
                                        <span class="waveTime" data-arrival="{$w.arrival_time}">
                                            en {$w.arrival_time}
                                        </span>
                                    </div>
                                {/foreach}
                            </div>
                        </div>
                    {/if}

                    {if $pve_bastion.can_reinforce}
                        <a href="game.php?page=pve&mode=reinforcePrepare" class="bastionBtnBig green">
                            🚀 ENVIAR REFUERZOS AL BASTIÓN
                        </a>
                    {else}
                        <div style="text-align:center;color:#8899aa;font-size:12px;margin-top:14px;">
                            ⚠️ No puedes enviar refuerzos en este momento.
                        </div>
                    {/if}
                </div>
            {elseif $pve_bastion.my_registration}
                {if $pve_bastion.my_registration.status == 'lost'}
                    <div class="bastionCard">
                        <h2>💥 Bastión Caído</h2>
                        <div class="bastionEmpty">
                            Vuestro Bastión ha sido superado por los piratas.
                            <br><br>
                            Quedáis fuera del torneo, pero podéis seguir viendo el ranking de las demás alianzas.
                        </div>
                    </div>
                {else}
                    <div class="bastionCard">
                        <h2>♻️ Preparando despliegue</h2>
                        <div class="bastionEmpty">
                            Vuestro Bastión está siendo desplegado.
                            <br><br>
                            Recibirás un mensaje con las coordenadas cuando esté listo.
                        </div>
                    </div>
                {/if}
            {/if}
        {/if}

        {* ─── RANKING EN VIVO ─── *}
        <div class="bastionCard">
            <h2>
                <span>🏆 Ranking de Alianzas</span>
                <span style="font-size:10px;color:#8899aa;font-weight:normal;">
                    (Actualización automática cada 10s)
                </span>
            </h2>

            {if $pve_bastion.ranking|@count > 0}
                <table class="bastionTable ranking">
					<thead>
						<tr>
							<th class="center" style="width:40px;">#</th>
							<th>Alianza</th>
							<th class="center">Score</th>
							<th class="center">Piratas</th>
							<th class="center">% HP</th>
							<th class="center">👥</th>
							<th class="center">Estado</th>
						</tr>
					</thead>
                    <tbody>
                        {foreach $pve_bastion.ranking as $idx => $r}
                            {assign var=rowClass value=""}
                            {if $r.ally_id == $pve_bastion.my_ally_id}
                                {assign var=rowClass value="my-ally"}
                            {elseif $r.status == 'lost'}
                                {assign var=rowClass value="breached-row"}
                            {/if}
                            <tr class="{$rowClass}">
                                <td class="center pos">{$idx+1}</td>
                                <td>
                                    <span style="color:#99ddff;font-weight:bold;">
                                        [{if $r.ally_tag}{$r.ally_tag}{else}?{/if}]
                                    </span>
                                    {if $r.ally_name}{$r.ally_name|escape:'html'}{else}Alianza #{$r.ally_id}{/if}
                                    {if $r.ally_id == $pve_bastion.my_ally_id}
                                        <span style="color:#ffcc33;font-size:10px;">← Tu alianza</span>
                                    {/if}
                                </td>
                                <td class="center score" data-label="Score">{$r.score_total|default:0|number_format}</td>
								<td class="center" data-label="Piratas" style="font-size:10px;color:#aabbcc;">
									☠️ {$r.pirates_killed|default:0|number_format}
									{if $r.boss_pirates_killed > 0}· 💀 {$r.boss_pirates_killed}{/if}
								</td>
								<td class="center pct" data-label="% HP">{$r.pct_hp_preserved|default:0}%</td>
								<td class="center" data-label="Miembros" style="color:#88ddff;">{$r.members_at_spawn|default:0}</td>
                                <td class="center">
                                    {if $r.status == 'winner'}<span style="color:#ffcc33;font-weight:bold;">🏆 Ganador</span>
                                    {elseif $r.status == 'lost'}<span style="color:#ff8888;">💥 Caído</span>
                                    {elseif $r.status == 'active'}<span style="color:#88ffbb;">🛡️ Defendiendo</span>
                                    {elseif $r.status == 'registered'}<span style="color:#88ddff;">📝 Inscrita</span>
                                    {else}{$r.status}{/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div class="bastionEmpty">
                    Aún no hay alianzas inscritas en este evento.
                </div>
            {/if}
        </div>

        {* ─── CONTRIBUCIÓN INTERNA DE MI ALIANZA ─── *}
        {if $event.status == 'active' && $pve_bastion.my_registration && $pve_bastion.my_ally_contrib|@count > 0}
            <div class="bastionCard">
                <h2>👥 Contribución de tu alianza</h2>
                <table class="bastionTable contrib">
					<thead>
						<tr>
							<th>Jugador</th>
							<th class="center">Naves enviadas</th>
							<th class="center">Naves perdidas</th>
							<th class="center">Piratas eliminados</th>
						</tr>
					</thead>
                    <tbody>
                        {foreach $pve_bastion.my_ally_contrib as $c}
                            <tr>
                                <td style="color:#88ddff;">{$c.username|escape:'html'}</td>
                                <td class="center score" data-label="Naves enviadas">{$c.ships_sent|default:0|number_format}</td>
								<td class="center" data-label="Naves perdidas" style="color:#ff8888;">{$c.ships_lost|default:0|number_format}</td>
								<td class="center" data-label="Piratas eliminados" style="color:#ffee88;">{$c.pirates_killed|default:0|number_format}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {/if}

        {* ─── INFORMACIÓN ALIANZA ─── *}
        {if $pve_bastion.my_registration}
            <div class="bastionCard">
                <h2>📊 Resumen de tu alianza</h2>
                <div class="bastionGrid">
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">Score total</div>
                        <div class="bastionGridValue">{$pve_bastion.my_registration.score_total|default:0|number_format}</div>
                    </div>
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">Piratas eliminados</div>
                        <div class="bastionGridValue">{$pve_bastion.my_registration.pirates_killed|default:0|number_format}</div>
                    </div>
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">% HP preservado</div>
                        <div class="bastionGridValue">{$pve_bastion.my_registration.pct_hp_preserved|default:0}%</div>
                    </div>
                    <div class="bastionGridItem">
                        <div class="bastionGridLabel">Refuerzos enviados</div>
                        <div class="bastionGridValue">{$pve_bastion.my_registration.reinforcement_attacks|default:0}</div>
                    </div>
                </div>
            </div>
        {/if}

    {/if}

    {* ─── INFO AL PIE ─── *}
    <p style="text-align:center;font-size:11px;color:#8899aa;margin-top:20px;">
        🚧 Bastión Asediado — AstroIO v4.0 · Dual-Riel NTX-20 / UNTX-20 · Evento por alianzas
    </p>
</div>

{* ═══════════════════════════════════════════════════════════
 * JAVASCRIPT — Countdown + oleadas + AJAX ranking
 * ═══════════════════════════════════════════════════════════ *}
{if $pve_bastion.event}

    {assign var=jsEndTime value=0}
    {if $pve_bastion.event.status == 'scheduled'}
        {assign var=jsEndTime value=$pve_bastion.event.registration_start|default:0}
    {elseif $pve_bastion.event.status == 'registration'}
        {assign var=jsEndTime value=$pve_bastion.event.registration_end|default:0}
    {elseif $pve_bastion.event.status == 'active'}
        {assign var=jsEndTime value=$pve_bastion.event.end_time|default:0}
    {/if}

    {assign var=jsEventId value=$pve_bastion.event.id|default:0}
    {assign var=jsEventStatus value=$pve_bastion.event.status|default:''}

{literal}
<script type="text/javascript">
(function() {
    // ─── Countdown ───
    var countdownEl = document.getElementById('bastionCountdownValue');

    if (countdownEl) {
        var endTime = {/literal}{$jsEndTime}{literal};

        function pad(n) { return (n < 10 ? '0' : '') + n; }

        function fmt(sec) {
            if (sec <= 0) return '¡Ahora!';
            var d = Math.floor(sec / 86400);
            var h = Math.floor((sec % 86400) / 3600);
            var m = Math.floor((sec % 3600) / 60);
            var s = sec % 60;

            if (d > 0) return d + 'd ' + pad(h) + 'h ' + pad(m) + 'm';
            if (h > 0) return pad(h) + 'h ' + pad(m) + 'm ' + pad(s) + 's';
            return pad(m) + 'm ' + pad(s) + 's';
        }

        function tick() {
            var now = Math.floor(Date.now() / 1000);
            var rem = endTime - now;
            countdownEl.textContent = fmt(rem);
            if (rem < 3600) countdownEl.style.color = '#ff8888';
            else if (rem < 86400) countdownEl.style.color = '#ffee88';
        }

        tick();
        setInterval(tick, 1000);
    }

    // ─── Countdowns de oleadas pendientes ───
    document.querySelectorAll('.waveTime').forEach(function(el) {
        var arrival = parseInt(el.getAttribute('data-arrival') || '0', 10);
        if (arrival <= 0) return;

        function updateWaveTime() {
            var now = Math.floor(Date.now() / 1000);
            var rem = arrival - now;
            if (rem <= 0) {
                el.textContent = '¡Inminente!';
                el.style.color = '#ff4444';
                return;
            }
            var m = Math.floor(rem / 60);
            var s = rem % 60;
            el.textContent = 'en ' + m + 'm ' + (s < 10 ? '0' : '') + s + 's';
        }

        updateWaveTime();
        setInterval(updateWaveTime, 1000);
    });

    // ─── AJAX: Ranking en vivo ───
    var eventId = {/literal}{$jsEventId}{literal};
    var eventStatus = '{/literal}{$jsEventStatus}{literal}';

    if (eventId > 0 && eventStatus === 'active') {
        setInterval(function() {
            if (!document.hidden) {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', 'game.php?page=pve&mode=bastionRankingJson&event_id=' + eventId, true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            if (data && data.ok) {
                                // Hook reservado: actualización DOM futura
                            }
                        } catch (e) {}
                    }
                };
                xhr.send();
            }
        }, 10000);
    }
})();
</script>
{/literal}

{/if}

{/block}