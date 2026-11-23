{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pve.default.tpl === *}
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
   PvE — Panel Principal
   AstroIO v5.0 — Glassmorphism + Acento Púrpura + Dual-Riel
   Prefijo: .astropve_
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

/* ─── WRAPPER ──────────────────────────────────────────── */
.astropve_wrap {
    padding: 20px;
    color: var(--text-main);
}

.astropve_title {
    color: var(--accent-purple);
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(139, 92, 246, 0.6);
    letter-spacing: 1px;
}

.astropve_subtitle {
    text-align: center;
    color: var(--text-muted);
    margin-bottom: 30px;
    font-size: 12px;
}

/* ─── v5.0 — BADGE DE SALDO ────────────────────────────── */
.astropve_balance_bar {
    max-width: 1100px;
    margin: 0 auto 18px;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.astropve_balance_badge {
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
.astropve_balance_badge:hover {
    transform: translateY(-1px);
}

.astropve_balance_badge.cup {
    border: 1px solid rgba(251, 191, 36, 0.6);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
    color: #ffee88;
}
.astropve_balance_badge.cup:hover {
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.5);
}

.astropve_balance_badge.qvapay {
    border: 1px solid rgba(0, 224, 255, 0.6);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.25);
    color: #88ffff;
}
.astropve_balance_badge.qvapay:hover {
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.5);
}

.astropve_balance_label {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astropve_balance_value {
    font-size: 17px;
    font-weight: bold;
    letter-spacing: 0.5px;
}

.astropve_balance_currency {
    font-size: 12px;
    opacity: 0.9;
    font-weight: bold;
    letter-spacing: 0.5px;
}

/* ─── TABS ─────────────────────────────────────────────── */
.astropve_tabs {
    max-width: 1100px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropve_tab {
    flex: 1;
    min-width: 160px;
    max-width: 220px;
    padding: 12px 18px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
    text-decoration: none;
    transition: all 0.25s ease;
    position: relative;
    display: inline-block;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropve_tab:hover {
    transform: translateY(-2px);
}

/* Variantes de tabs */
.astropve_tab.main {
    background: linear-gradient(135deg, #8b5cf6, #a78bfa);
    color: #fff;
    border: 1px solid var(--accent-purple);
    box-shadow: 0 4px 14px rgba(139, 92, 246, 0.5);
}
.astropve_tab.main:hover {
    box-shadow: 0 6px 20px rgba(139, 92, 246, 0.7);
}

.astropve_tab.empire {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropve_tab.empire:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropve_tab.boss {
    background: rgba(80, 180, 255, 0.15);
    color: #88ccff;
    border: 1px solid rgba(80, 180, 255, 0.5);
}
.astropve_tab.boss:hover {
    background: rgba(80, 180, 255, 0.25);
    box-shadow: 0 0 14px rgba(80, 180, 255, 0.4);
}

.astropve_tab.bastion {
    background: rgba(50, 150, 255, 0.15);
    color: #99ddff;
    border: 1px solid rgba(50, 150, 255, 0.5);
}
.astropve_tab.bastion:hover {
    background: rgba(50, 150, 255, 0.25);
    box-shadow: 0 0 14px rgba(50, 150, 255, 0.4);
}

.astropve_tab.achievements {
    background: rgba(251, 191, 36, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(251, 191, 36, 0.5);
}
.astropve_tab.achievements:hover {
    background: rgba(251, 191, 36, 0.25);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}

/* Badge rojo en las tabs (contador) */
.astropve_tab_badge {
    position: absolute;
    top: -6px;
    right: -6px;
    display: inline-block;
    padding: 2px 7px;
    background: var(--accent-red);
    color: #fff;
    border-radius: 10px;
    font-size: 10px;
    font-weight: bold;
    box-shadow: 0 0 8px rgba(239, 68, 68, 0.8);
    animation: astropveCardPulse 1.4s infinite;
}

/* ─── MENSAJES DE RESULTADO ────────────────────────────── */
.astropve_msg {
    max-width: 900px;
    margin: 0 auto 20px;
    padding: 15px 20px;
    border-radius: 10px;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropve_msg.success {
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: #88ffbb;
}
.astropve_msg.warning {
    background: rgba(251, 191, 36, 0.15);
    border: 1px solid rgba(251, 191, 36, 0.5);
    color: #ffee88;
}
.astropve_msg_sub {
    font-size: 11px;
    color: #88ddff;
}
.astropve_msg_ntx {
    color: #ffee88;
    font-weight: bold;
}
.astropve_msg_res_title {
    color: #aabbcc;
    font-size: 12px;
}
.astropve_msg_metal   { color: #ffcc88; }
.astropve_msg_crystal { color: #88ddff; }
.astropve_msg_deut    { color: #aaffaa; }

/* ─── ESTADO DE EVENTOS ───────────────────────────────── */
.astropve_events_wrap {
    max-width: 1100px;
    margin: 0 auto 25px;
}
.astropve_events_title {
    color: #bb88ff;
    font-size: 16px;
    margin-bottom: 15px;
    text-align: center;
    text-shadow: 0 0 10px rgba(139, 92, 246, 0.4);
    letter-spacing: 0.5px;
}
.astropve_events_grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    gap: 12px;
    align-items: stretch;
}

/* ─── CARDS DE ESTADO ─────────────────────────────────── */
.astropve_card {
    border-radius: 14px;
    padding: 12px;
    position: relative;
    overflow: hidden;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
    transition: 0.25s ease;
}
.astropve_card:hover {
    transform: translateY(-2px);
}

.astropve_card.crisis {
    background: linear-gradient(160deg, rgba(30, 15, 60, 0.85) 0%, rgba(50, 20, 90, 0.85) 100%);
    border: 2px solid rgba(139, 92, 246, 0.5);
}
.astropve_card.crisis:hover {
    box-shadow: 0 8px 30px rgba(139, 92, 246, 0.5);
}

.astropve_card.boss {
    background: linear-gradient(160deg, rgba(10, 30, 60, 0.85) 0%, rgba(20, 60, 110, 0.85) 100%);
    border: 2px solid rgba(80, 180, 255, 0.5);
}
.astropve_card.boss:hover {
    box-shadow: 0 8px 30px rgba(80, 180, 255, 0.5);
}

.astropve_card.bastion {
    background: linear-gradient(160deg, rgba(10, 30, 60, 0.85) 0%, rgba(20, 60, 90, 0.85) 100%);
    border: 2px solid rgba(50, 150, 255, 0.5);
}
.astropve_card.bastion:hover {
    box-shadow: 0 8px 30px rgba(50, 150, 255, 0.5);
}

.astropve_card.empire {
    background: linear-gradient(160deg, rgba(60, 30, 10, 0.85) 0%, rgba(90, 45, 15, 0.85) 100%);
    border: 2px solid rgba(255, 150, 50, 0.5);
}
.astropve_card.empire:hover {
    box-shadow: 0 8px 30px rgba(255, 150, 50, 0.5);
}

.astropve_card_title {
    font-size: 12px;
    font-weight: bold;
    line-height: 1.2;
    margin-bottom: 8px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropve_card.crisis .astropve_card_title  { color: #dd99ff; }
.astropve_card.boss .astropve_card_title    { color: #88ccff; }
.astropve_card.bastion .astropve_card_title { color: #99ddff; }
.astropve_card.empire .astropve_card_title  { color: #ffaa66; }

.astropve_card_badge {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 10px;
    font-size: 9px;
    font-weight: bold;
    background: rgba(120, 120, 120, 0.3);
    color: var(--text-muted);
    white-space: nowrap;
    margin-bottom: 10px;
}

.astropve_card_countdown_box {
    text-align: center;
    padding: 10px 4px;
    background: rgba(0, 0, 0, 0.35);
    border-radius: 10px;
    margin-bottom: 8px;
}
.astropve_card_label {
    font-size: 8px;
    color: var(--text-muted);
    margin-bottom: 4px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}
.astropve_card_countdown {
    font-size: 16px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    color: #667788;
    line-height: 1.1;
    word-break: break-word;
}

.astropve_card_extra {
    margin-top: 6px;
    font-size: 8px;
    color: #aabbcc;
    text-align: center;
}

.astropve_card_progress_head {
    display: flex;
    justify-content: space-between;
    font-size: 8px;
    color: var(--text-muted);
    margin-bottom: 3px;
}
.astropve_card_progress_wrap {
    height: 5px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 3px;
    overflow: hidden;
}
.astropve_card.crisis .astropve_card_progress_wrap  { border: 1px solid rgba(139, 92, 246, 0.3); }
.astropve_card.boss .astropve_card_progress_wrap    { border: 1px solid rgba(80, 180, 255, 0.3); }
.astropve_card.bastion .astropve_card_progress_wrap { border: 1px solid rgba(50, 150, 255, 0.3); }
.astropve_card.empire .astropve_card_progress_wrap  { border: 1px solid rgba(255, 150, 50, 0.3); }

.astropve_card_progress_bar {
    height: 100%;
    width: 0%;
    transition: width 1s linear;
}
.astropve_card.crisis .astropve_card_progress_bar  { background: linear-gradient(90deg, #ef4444, #fbbf24); }
.astropve_card.boss .astropve_card_progress_bar    { background: linear-gradient(90deg, #2288ff, #88ddff); }
.astropve_card.bastion .astropve_card_progress_bar { background: linear-gradient(90deg, #228833, #4aff88); }
.astropve_card.empire .astropve_card_progress_bar  { background: linear-gradient(90deg, #fbbf24, #fde047); }

/* ─── PANEL DE RECOMPENSAS ─────────────────────────────── */
.astropve_rewards {
    max-width: 900px;
    margin: 0 auto;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(251, 191, 36, 0.4);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astropve_rewards_title {
    color: #ffdd88;
    font-size: 16px;
    margin-bottom: 15px;
}
.astropve_rewards_count {
    display: inline-block;
    margin-left: 8px;
    padding: 2px 10px;
    background: rgba(251, 191, 36, 0.25);
    border: 1px solid rgba(251, 191, 36, 0.6);
    border-radius: 10px;
    font-size: 11px;
    color: #ffee88;
}

.astropve_totals_box {
    margin-bottom: 16px;
    padding: 10px 14px;
    background: rgba(251, 191, 36, 0.06);
    border-left: 3px solid var(--accent-gold);
    border-radius: 6px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropve_totals_label {
    font-size: 11px;
    color: var(--text-muted);
    margin-bottom: 6px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}
.astropve_totals_values {
    font-size: 13px;
    line-height: 1.6;
}
.astropve_totals_ntx       { color: #ffee88; font-weight: bold; }
.astropve_totals_metal     { color: #ffcc88; }
.astropve_totals_crystal   { color: #88ddff; }
.astropve_totals_deuterium { color: #aaffaa; }

.astropve_rewards_table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 20px;
}
.astropve_rewards_table thead tr {
    border-bottom: 1px solid rgba(251, 191, 36, 0.3);
}
.astropve_rewards_table th {
    padding: 8px;
    color: #ffdd88;
    font-size: 11px;
}
.astropve_rewards_table th.left   { text-align: left; }
.astropve_rewards_table th.center { text-align: center; }
.astropve_rewards_table tbody tr {
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}
.astropve_rewards_table tbody tr:hover {
    background: rgba(251, 191, 36, 0.04);
}
.astropve_rewards_table td {
    padding: 10px 8px;
    color: var(--text-main);
    font-size: 12px;
}
.astropve_rewards_table td.center { text-align: center; }
.astropve_rewards_table td.event_name { color: var(--text-main); }
.astropve_rewards_table td.waves      { color: #aabbcc; }

.astropve_reward_ntx  { color: #ffee88; font-weight: bold; }
.astropve_reward_res  { color: #88ffbb; }
.astropve_reward_ship { color: #ffaa88; }
.astropve_reward_def  { color: #88ddff; }
.astropve_reward_fb   { color: #ffdd88; }

.astropve_btn_claim {
    padding: 12px 40px;
    background: linear-gradient(135deg, #8b5cf6, #a78bfa);
    color: #fff;
    border: 1px solid var(--accent-purple);
    border-radius: 8px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(139, 92, 246, 0.5);
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    letter-spacing: 0.5px;
}
.astropve_btn_claim:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(139, 92, 246, 0.7);
    background: linear-gradient(135deg, #a78bfa, #c4b5fd);
}

.astropve_empty {
    text-align: center;
    color: var(--text-muted);
    font-size: 13px;
    padding: 20px 0;
}
.astropve_empty_sub {
    font-size: 11px;
    color: #667788;
}

.astropve_footer {
    text-align: center;
    font-size: 11px;
    color: var(--text-muted);
    margin-top: 30px;
}

/* ─── ANIMACIÓN PULSE ──────────────────────────────────── */
@keyframes astropveCardPulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50%      { opacity: 0.7; transform: scale(1.05); }
}

/* ─── RESPONSIVE ───────────────────────────────────────── */
@media (max-width: 900px) {
    .astropve_events_grid { 
        grid-template-columns: repeat(2, 1fr); 
    }
}

@media (max-width: 600px) {
    /* 1x2 para eventos en móvil */
    .astropve_events_grid { 
        grid-template-columns: repeat(2, 1fr) !important; 
        gap: 8px !important;
    }
    
    /* Ajustes de tamaño para que quepan 2 en la tarjeta de evento */
    .astropve_card { padding: 10px; }
    .astropve_card_title { font-size: 11px; }
    .astropve_card_countdown_box { padding: 8px 2px; }
    .astropve_card_countdown { font-size: 14px; }

    /* 2 botones (Tabs) por fila en móvil */
    .astropve_tabs {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 10px !important; /* Más espacio entre ellos */
        margin-bottom: 15px !important;
    }
    .astropve_tab {
        min-width: 0 !important;
        max-width: 100% !important;
        width: 100% !important;
        padding: 6px 3px !important; /* Un poco más de altura y menos a los lados */
        font-size: 9px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
    }
	/* Hace que el botón huérfano (Logros) ocupe todo el ancho */
	.astropve_tab:last-child:nth-child(odd) {
        grid-column: 1 / -1 !important;
	}
    /* Ajuste para el badge de saldo para que no se desborde */
    .astropve_balance_bar {
        display: flex !important;
        gap: 8px;
    }
    .astropve_balance_badge {
		max-width: 100% !important;
        width: 100% !important;
		padding: 11px 10px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
    }
	    /* ═══════════════════════════════════════════════════════
     * FIX MÓVIL — Tabla de recompensas → tarjetas apiladas
     * ═══════════════════════════════════════════════════════ */
    .astropve_rewards {
        padding: 12px !important;
    }
    .astropve_rewards_title {
        font-size: 14px !important;
        margin-bottom: 10px !important;
    }
    .astropve_rewards_count {
        padding: 2px 6px !important;
        font-size: 10px !important;
    }

    /* Reset del layout de tabla */
    .astropve_rewards_table,
    .astropve_rewards_table thead,
    .astropve_rewards_table tbody,
    .astropve_rewards_table tr,
    .astropve_rewards_table td {
        display: block !important;
        width: 100% !important;
        box-sizing: border-box !important;
    }

    /* Ocultar cabecera (los labels vienen del data-label) */
    .astropve_rewards_table thead {
        display: none !important;
    }

    /* Cada fila = tarjeta */
    .astropve_rewards_table tbody tr {
        background: rgba(0, 0, 0, 0.35) !important;
        border: 1px solid rgba(251, 191, 36, 0.35) !important;
        border-radius: 10px !important;
        margin-bottom: 10px !important;
        padding: 10px 12px !important;
    }
    .astropve_rewards_table tbody tr:hover {
        background: rgba(0, 0, 0, 0.45) !important;
    }

    /* Cada celda = línea con label */
    .astropve_rewards_table td {
        padding: 6px 0 !important;
        border-bottom: 1px solid rgba(255, 255, 255, 0.06) !important;
        font-size: 12px !important;
        text-align: left !important;
    }
    .astropve_rewards_table td.center {
        text-align: left !important;
    }
    .astropve_rewards_table td:first-child {
        padding-top: 0 !important;
    }
    .astropve_rewards_table td:last-child {
        border-bottom: none !important;
        padding-bottom: 0 !important;
    }

    /* Label dinámico desde data-label */
    .astropve_rewards_table td::before {
        content: attr(data-label) ": ";
        display: inline-block;
        font-weight: bold !important;
        color: #ffdd88 !important;
        font-size: 10px !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
        margin-right: 6px !important;
        min-width: 75px !important;
    }

    /* Evitar desbordes de strings largos en recompensas */
    .astropve_reward_ntx,
    .astropve_reward_res,
    .astropve_reward_fb {
        word-break: break-word !important;
        overflow-wrap: anywhere !important;
    }

    /* Botón Reclamar Todo full-width */
    .astropve_btn_claim {
        width: 100% !important;
        padding: 12px 16px !important;
        box-sizing: border-box !important;
    }
}
</style>

<div class="astropve_wrap">

    <h1 class="astropve_title">⚔️ SISTEMA PvE — AstroIO</h1>

    {* ═══════════════════════════════════════════════════════════
     * v5.0 — BADGE DE SALDO (moneda del jugador)
     * ═══════════════════════════════════════════════════════════ *}
    {if isset($moneda) && isset($saldo_actual)}
        <div class="astropve_balance_bar">
            <div class="astropve_balance_badge {if $es_internacional}qvapay{else}cup{/if}">
                <span class="astropve_balance_label">💰 Saldo:</span>
                <span class="astropve_balance_value">{$saldo_actual|number_format}</span>
                <span class="astropve_balance_currency">{$moneda}</span>
            </div>
        </div>
    {/if}

    {* ═══════════════════════════════════════════════════════════
     * MENÚ DE PESTAÑAS
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_tabs">
        <a href="game.php?page=pve" class="astropve_tab main">
            🏠 Panel Principal
        </a>
        <a href="game.php?page=pve&mode=empire" class="astropve_tab empire">
            🏛️ Imperio Caído
            {if $empiresCount > 0}
                <span class="astropve_tab_badge">{$empiresCount}</span>
            {/if}
        </a>
        <a href="game.php?page=pve&mode=boss" class="astropve_tab boss">
            🌌 Torneo del Devorador
            {if isset($boss_state) && $boss_state.active}
                <span class="astropve_tab_badge">!</span>
            {/if}
        </a>
        <a href="game.php?page=pve&mode=bastion" class="astropve_tab bastion">
            ⚓ Bastión Asediado
            {if isset($bastion_state) && $bastion_state.active}
                <span class="astropve_tab_badge">!</span>
            {/if}
        </a>
        <a href="game.php?page=pve&mode=achievements" class="astropve_tab achievements">
            🏆 Logros
        </a>
    </div>

    <p class="astropve_subtitle">
        Bienvenido al módulo PvE. Aquí se mostrarán los eventos de Crisis de Fin de Mes, el Imperio Caído, el Torneo del Devorador y el Bastión Asediado.
    </p>

    {* ═══════════════════════════════════════════════════════════
     * MENSAJES DE RESULTADO (claim)
     * v5.0 — Moneda dinámica según riel del jugador
     * ═══════════════════════════════════════════════════════════ *}
    {if isset($smarty.get.claim)}
        {if $smarty.get.claim == 'success'}
            {assign var=claimNtx       value=$smarty.get.ntx|default:0}
            {assign var=claimMetal     value=$smarty.get.metal|default:0}
            {assign var=claimCrystal   value=$smarty.get.crystal|default:0}
            {assign var=claimDeuterium value=$smarty.get.deuterium|default:0}
            {assign var=claimCount     value=$smarty.get.n|default:0}

            <div class="astropve_msg success">
                🎉 ¡Recompensas reclamadas con éxito!
                <br>
                <span class="astropve_msg_sub">
                    ({$claimCount} recompensa{if $claimCount != 1}s{/if} procesada{if $claimCount != 1}s{/if})
                </span>

                {if $claimNtx > 0}
                    <br><b class="astropve_msg_ntx">+{$claimNtx|number_format} {$moneda|default:'NTX-20'}</b> añadidos a tu cuenta.
                {/if}

                {if $claimMetal > 0 || $claimCrystal > 0 || $claimDeuterium > 0}
                    <br>
                    <span class="astropve_msg_res_title">Recursos añadidos a tu planeta principal:</span>
                    <br>
                    {if $claimMetal > 0}
                        <span class="astropve_msg_metal">🔩 {$claimMetal|number_format} metal</span>
                    {/if}
                    {if $claimCrystal > 0}
                        {if $claimMetal > 0} · {/if}
                        <span class="astropve_msg_crystal">💎 {$claimCrystal|number_format} cristal</span>
                    {/if}
                    {if $claimDeuterium > 0}
                        {if $claimMetal > 0 || $claimCrystal > 0} · {/if}
                        <span class="astropve_msg_deut">⚗️ {$claimDeuterium|number_format} deuterio</span>
                    {/if}
                {/if}
            </div>
        {elseif $smarty.get.claim == 'none'}
            <div class="astropve_msg warning">
                ℹ️ No había recompensas pendientes para reclamar.
            </div>
        {/if}
    {/if}

    {* ═══════════════════════════════════════════════════════════
     * ESTADO DE EVENTOS (con countdown en vivo)
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_events_wrap">
        <h2 class="astropve_events_title">
            📊 ESTADO DE EVENTOS
        </h2>

        <div class="astropve_events_grid">

            {* CARD CRISIS *}
            <div id="pve_crisis_card" class="astropve_card crisis"
                 data-enabled="{$crisis_state.enabled|default:0}"
                 data-active="{$crisis_state.active|default:0}"
                 data-next-time="{$crisis_state.next_time|default:0}"
                 data-end-time="{$crisis_state.end_time|default:0}"
                 data-label-start="⏱️ Empieza en:"
                 data-label-active="⏱️ Termina en:">

                <div class="astropve_card_title">🌌 CRISIS DE FIN DE MES</div>
                <div id="pve_crisis_status_badge" class="astropve_card_badge">—</div>

                <div class="astropve_card_countdown_box">
                    <div id="pve_crisis_label" class="astropve_card_label">Cargando...</div>
                    <div id="pve_crisis_countdown" class="astropve_card_countdown">--</div>
                </div>

                <div id="pve_crisis_progress_wrap" style="display: none;">
                    <div class="astropve_card_progress_head">
                        <span>Prog.</span>
                        <span id="pve_crisis_progress_text">0%</span>
                    </div>
                    <div class="astropve_card_progress_wrap">
                        <div id="pve_crisis_progress_bar" class="astropve_card_progress_bar"></div>
                    </div>
                </div>

                <div id="pve_crisis_extra" class="astropve_card_extra">
                    {if !$crisis_state.enabled}⚪ Desactivado{/if}
                </div>
            </div>

            {* CARD TORNEO DEL DEVORADOR *}
            <div id="pve_boss_card" class="astropve_card boss"
                 data-enabled="{$boss_state.enabled|default:0}"
                 data-active="{$boss_state.active|default:0}"
                 data-next-time="{$boss_state.next_time|default:0}"
                 data-end-time="{$boss_state.end_time|default:0}"
                 data-status="{$boss_state.status|default:'idle'}"
                 data-label-start="⏱️ Comienza en:"
                 data-label-active="⏱️ Termina en:">

                <div class="astropve_card_title">🌌 TORNEO DEL DEVORADOR</div>
                <div id="pve_boss_status_badge" class="astropve_card_badge">—</div>

                <div class="astropve_card_countdown_box">
                    <div id="pve_boss_label" class="astropve_card_label">Cargando...</div>
                    <div id="pve_boss_countdown" class="astropve_card_countdown">--</div>
                </div>

                <div id="pve_boss_progress_wrap" style="display: none;">
                    <div class="astropve_card_progress_head">
                        <span>Prog.</span>
                        <span id="pve_boss_progress_text">0%</span>
                    </div>
                    <div class="astropve_card_progress_wrap">
                        <div id="pve_boss_progress_bar" class="astropve_card_progress_bar"></div>
                    </div>
                </div>

                <div id="pve_boss_extra" class="astropve_card_extra">
                    {if !$boss_state.enabled}⚪ Desactivado{elseif !$boss_state.active && $boss_state.next_time == 0}🌌 Sin torneo{/if}
                </div>
            </div>

            {* CARD BASTIÓN ASEDIADO *}
            <div id="pve_bastion_card" class="astropve_card bastion"
                 data-enabled="{$bastion_state.enabled|default:0}"
                 data-active="{$bastion_state.active|default:0}"
                 data-next-time="{$bastion_state.next_time|default:0}"
                 data-end-time="{$bastion_state.end_time|default:0}"
                 data-status="{$bastion_state.status|default:'idle'}"
                 data-label-start="⏱️ Comienza en:"
                 data-label-active="⏱️ Termina en:">

                <div class="astropve_card_title">⚓ BASTIÓN ASEDIADO</div>
                <div id="pve_bastion_status_badge" class="astropve_card_badge">—</div>

                <div class="astropve_card_countdown_box">
                    <div id="pve_bastion_label" class="astropve_card_label">Cargando...</div>
                    <div id="pve_bastion_countdown" class="astropve_card_countdown">--</div>
                </div>

                <div id="pve_bastion_progress_wrap" style="display: none;">
                    <div class="astropve_card_progress_head">
                        <span>Prog.</span>
                        <span id="pve_bastion_progress_text">0%</span>
                    </div>
                    <div class="astropve_card_progress_wrap">
                        <div id="pve_bastion_progress_bar" class="astropve_card_progress_bar"></div>
                    </div>
                </div>

                <div id="pve_bastion_extra" class="astropve_card_extra">
                    {if !$bastion_state.enabled}⚪ Desactivado{elseif !$bastion_state.active && $bastion_state.next_time == 0}⚓ Sin bastión{/if}
                </div>
            </div>

            {* CARD IMPERIO *}
            <div id="pve_empire_card" class="astropve_card empire"
                 data-enabled="{$empire_state.enabled|default:0}"
                 data-active="{$empire_state.active|default:0}"
                 data-next-time="{$empire_state.next_time|default:0}"
                 data-end-time="{$empire_state.end_time|default:0}"
                 data-label-start="⏱️ Empieza en:"
                 data-label-active="⏱️ Termina en:">

                <div class="astropve_card_title">🏛️ IMPERIO CAÍDO</div>
                <div id="pve_empire_status_badge" class="astropve_card_badge">—</div>

                <div class="astropve_card_countdown_box">
                    <div id="pve_empire_label" class="astropve_card_label">Cargando...</div>
                    <div id="pve_empire_countdown" class="astropve_card_countdown">--</div>
                </div>

                <div id="pve_empire_progress_wrap" style="display: none;">
                    <div class="astropve_card_progress_head">
                        <span>Prog.</span>
                        <span id="pve_empire_progress_text">0%</span>
                    </div>
                    <div class="astropve_card_progress_wrap">
                        <div id="pve_empire_progress_bar" class="astropve_card_progress_bar"></div>
                    </div>
                </div>

                <div id="pve_empire_extra" class="astropve_card_extra">
                    {if !$empire_state.enabled}⚪ Desactivado{/if}
                </div>
            </div>

        </div>
    </div>

    {* --------------------------------------------------------------
     *  FIN DE LA PARTE 1 — continúa en la PARTE 2 con:
     *    - Sección de Recompensas Pendientes (tabla + botón claim)
     *    - Footer
     *    - Bloque {literal} con el JS countdown
     *    - Cierre {/block}
     * -------------------------------------------------------------- *}
	     {* ═══════════════════════════════════════════════════════════
     * RECOMPENSAS PENDIENTES
     * v5.0 — Moneda dinámica según riel del jugador
     *        · $pendingTotals.ntx       = REAL (base ×2 si QVAPAY)
     *        · $pendingTotals.ntx_base  = BASE (referencia)
     *        · $pendingTotals.moneda    = 'NTX-20' | 'UNTX-20'
     *        · $r.amount_real           = REAL
     *        · $r.moneda                = 'NTX-20' | 'UNTX-20'
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_rewards">
        <h2 class="astropve_rewards_title">
            🎁 Recompensas Pendientes
            {if $pendingCount > 0}
                <span class="astropve_rewards_count">{$pendingCount}</span>
            {/if}
        </h2>

        {* Resumen de totales pendientes *}
        {if $pendingCount > 0 && isset($pendingTotals)}
            {assign var=ptMoneda   value=$pendingTotals.moneda|default:$moneda|default:'NTX-20'}
            {assign var=ptNtxReal  value=$pendingTotals.ntx|default:0}

            <div class="astropve_totals_box">
                <div class="astropve_totals_label">Total pendiente:</div>
                <div class="astropve_totals_values">
                    {if $ptNtxReal > 0}
                        <span class="astropve_totals_ntx">💎 {$ptNtxReal|number_format} {$ptMoneda}</span>
                    {/if}
                    {if $pendingTotals.metal > 0}
                        {if $ptNtxReal > 0} · {/if}
                        <span class="astropve_totals_metal">🔩 {$pendingTotals.metal|number_format} metal</span>
                    {/if}
                    {if $pendingTotals.crystal > 0}
                        {if $ptNtxReal > 0 || $pendingTotals.metal > 0} · {/if}
                        <span class="astropve_totals_crystal">💎 {$pendingTotals.crystal|number_format} cristal</span>
                    {/if}
                    {if $pendingTotals.deuterium > 0}
                        {if $ptNtxReal > 0 || $pendingTotals.metal > 0 || $pendingTotals.crystal > 0} · {/if}
                        <span class="astropve_totals_deuterium">⚗️ {$pendingTotals.deuterium|number_format} deuterio</span>
                    {/if}
                </div>
            </div>
        {/if}

        {if $rewards|@count > 0}
            <table class="astropve_rewards_table">
				<thead>
					<tr>
						<th class="left">Evento</th>
						<th class="center">Oleadas</th>
						<th class="center">Recompensa</th>
					</tr>
				</thead>
				<tbody>
					{foreach $rewards as $r}
						{assign var=rNtxReal  value=$r.amount_real|default:($r.amount|default:0)}
						{assign var=rMoneda   value=$r.moneda|default:$moneda|default:'NTX-20'}

						<tr>
							<td class="event_name" data-label="Evento">
								{if $r.event_type == 'crisis'}
									🌌 Crisis #{$r.event_id}
								{elseif $r.event_type == 'empire'}
									🏛️ Imperio #{$r.event_id}
								{elseif $r.event_type == 'boss'}
									🌌 Torneo #{$r.event_id}
								{elseif $r.event_type == 'bastion'}
									⚓ Bastión #{$r.event_id}
								{else}
									🎯 {$r.event_type} #{$r.event_id}
								{/if}
							</td>
							<td class="center waves" data-label="Oleadas">
								{if $r.event_type == 'crisis'}
									{$r.waves_survived}
								{else}
									-
								{/if}
							</td>
							<td class="center" data-label="Recompensa">

								{if $r.reward_type == 'ntx'}
									<span class="astropve_reward_ntx">+{$rNtxReal|number_format} {$rMoneda}</span>

								{elseif $r.reward_type == 'resources'}
									<span class="astropve_reward_res">
										{if $r.metal > 0}
											🔩 {$r.metal|number_format}
										{/if}
										{if $r.crystal > 0}
											{if $r.metal > 0} · {/if}
											💎 {$r.crystal|number_format}
										{/if}
										{if $r.deuterium > 0}
											{if $r.metal > 0 || $r.crystal > 0} · {/if}
											⚗️ {$r.deuterium|number_format}
										{/if}
									</span>

								{elseif $r.reward_type == 'ships'}
									<span class="astropve_reward_ship">🚀 Naves</span>

								{elseif $r.reward_type == 'defenses'}
									<span class="astropve_reward_def">🛡️ Defensas</span>

								{else}
									<span class="astropve_reward_fb">+{$r.amount|default:0|number_format} {$r.reward_type}</span>

								{/if}

							</td>
						</tr>
					{/foreach}
				</tbody>
			</table>

            <form method="POST" action="game.php?page=pve&mode=claimRewards" style="text-align: center;">
                <button type="submit" class="astropve_btn_claim">
                    🎁 Reclamar Todo ({$pendingCount})
                </button>
            </form>
        {else}
            <p class="astropve_empty">
                No tienes recompensas pendientes.
                <br>
                <span class="astropve_empty_sub">
                    Sobrevive a las Crisis de Fin de Mes, ataca a los Imperios Caídos, participa en el Torneo del Devorador y defiende tu Bastión Asediado para ganar recompensas.
                </span>
            </p>
        {/if}
    </div>

    <p class="astropve_footer">
        🚧 Módulo en construcción — Fase 4 en progreso
    </p>
</div>

{literal}
<script type="text/javascript">
(function() {
    function formatCountdown(seconds) {
        if (seconds <= 0) return '0s';

        var days    = Math.floor(seconds / 86400);
        var hours   = Math.floor((seconds % 86400) / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        var secs    = seconds % 60;

        var parts = [];
        if (days > 0) {
            parts.push(days + 'd');
            parts.push(pad2(hours) + 'h');
            parts.push(pad2(minutes) + 'm');
        } else if (hours > 0) {
            parts.push(pad2(hours) + 'h');
            parts.push(pad2(minutes) + 'm');
            parts.push(pad2(secs) + 's');
        } else {
            parts.push(pad2(minutes) + 'm');
            parts.push(pad2(secs) + 's');
        }

        return parts.join(' ');
    }

    function pad2(n) {
        return (n < 10 ? '0' : '') + n;
    }

    function updateCard(cardId, prefix) {
        var card = document.getElementById(cardId);
        if (!card) return;

        var enabled  = parseInt(card.getAttribute('data-enabled')  || '0', 10);
        var active   = parseInt(card.getAttribute('data-active')   || '0', 10);
        var nextTime = parseInt(card.getAttribute('data-next-time')|| '0', 10);
        var endTime  = parseInt(card.getAttribute('data-end-time') || '0', 10);

        var labelStartText  = card.getAttribute('data-label-start')  || '⏱️ Empieza en:';
        var labelActiveText = card.getAttribute('data-label-active') || '⏱️ Termina en:';

        var badge        = document.getElementById(prefix + '_status_badge');
        var countdown    = document.getElementById(prefix + '_countdown');
        var label        = document.getElementById(prefix + '_label');
        var progressWrap = document.getElementById(prefix + '_progress_wrap');
        var progressBar  = document.getElementById(prefix + '_progress_bar');
        var progressText = document.getElementById(prefix + '_progress_text');

        var now = Math.floor(Date.now() / 1000);

        if (enabled === 0) {
            if (badge) {
                badge.textContent = '⚪ Desactivado';
                badge.style.background = 'rgba(120, 120, 120, 0.3)';
                badge.style.color = '#8899aa';
            }
            if (countdown) {
                countdown.textContent = '--';
                countdown.style.color = '#667788';
            }
            if (label) label.textContent = 'Evento desactivado';
            if (progressWrap) progressWrap.style.display = 'none';
            return;
        }

        if (active === 1 && endTime > 0) {
            var remaining = endTime - now;

            if (badge) {
                badge.textContent = '🔴 ACTIVO';
                badge.style.background = 'rgba(255, 50, 50, 0.25)';
                badge.style.color = '#ff8888';
                badge.style.animation = 'astropveCardPulse 1.2s infinite';
            }

            if (remaining > 0) {
                if (countdown) {
                    countdown.textContent = formatCountdown(remaining);
                    countdown.style.color = '#ff8888';
                }
                if (label) label.textContent = labelActiveText;
            } else {
                if (countdown) {
                    countdown.textContent = 'Finalizando...';
                    countdown.style.color = '#ffaa66';
                }
                if (label) label.textContent = '⏱️ Fin del evento';
            }

            if (progressWrap && nextTime > 0 && endTime > nextTime) {
                progressWrap.style.display = 'block';
                var total     = endTime - nextTime;
                var elapsed   = now - nextTime;
                var pct       = Math.min(100, Math.max(0, (elapsed / total) * 100));
                if (progressBar)  progressBar.style.width = pct.toFixed(1) + '%';
                if (progressText) progressText.textContent = pct.toFixed(0) + '%';
            }

            return;
        }

        if (nextTime > 0) {
            var diff = nextTime - now;

            if (diff > 0) {
                if (diff < 3600) {
                    if (badge) {
                        badge.textContent = '⚡ Inminente';
                        badge.style.background = 'rgba(255, 50, 50, 0.25)';
                        badge.style.color = '#ff8888';
                        badge.style.animation = 'astropveCardPulse 1.2s infinite';
                    }
                    if (countdown) countdown.style.color = '#ff8888';
                } else if (diff < 86400) {
                    if (badge) {
                        badge.textContent = '⏰ Próximo';
                        badge.style.background = 'rgba(255, 200, 0, 0.25)';
                        badge.style.color = '#ffee88';
                        badge.style.animation = 'astropveCardPulse 2s infinite';
                    }
                    if (countdown) countdown.style.color = '#ffee88';
                } else {
                    if (badge) {
                        badge.textContent = '✅ Programado';
                        badge.style.background = 'rgba(0, 200, 100, 0.25)';
                        badge.style.color = '#88ffbb';
                        badge.style.animation = 'none';
                    }
                    if (countdown) countdown.style.color = '#88ffbb';
                }

                if (countdown) countdown.textContent = formatCountdown(diff);
                if (label) label.textContent = labelStartText;
                if (progressWrap) progressWrap.style.display = 'none';
            } else {
                if (countdown) {
                    countdown.textContent = '¡Ahora!';
                    countdown.style.color = '#ff4444';
                }
                if (label) label.textContent = '⏱️ El evento comienza';
            }
            return;
        }

        if (badge) {
            badge.textContent = '— Sin programar';
            badge.style.background = 'rgba(120, 120, 120, 0.3)';
            badge.style.color = '#8899aa';
            badge.style.animation = 'none';
        }
        if (countdown) {
            countdown.textContent = '--';
            countdown.style.color = '#667788';
        }
        if (label) label.textContent = 'Sin programación';
        if (progressWrap) progressWrap.style.display = 'none';
    }

    function tick() {
        updateCard('pve_crisis_card',  'pve_crisis');
        updateCard('pve_boss_card',    'pve_boss');
        updateCard('pve_bastion_card', 'pve_bastion');
        updateCard('pve_empire_card',  'pve_empire');
    }

    tick();
    setInterval(tick, 1000);
})();
</script>
{/literal}

{/block}