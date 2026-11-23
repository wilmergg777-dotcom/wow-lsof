{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.lottery.default.tpl === *}
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
   LOTERÍA — AstroIO v3.1 (DUAL RIEL)
   Glassmorphism + Acento Cyan/Púrpura + Dorado (Jackpot)
   Prefijo: .astrolot_
   v3.1 (2026-10-30):
     - Badge de saldo del jugador con {$moneda}
     - Jackpot, precios y premios usan los campos *_display
       (ya ajustados ×2 si QVAPAY desde el Helper)
     - Cero hardcodeos de "NTX-20"
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

.astrolot_wrap { max-width: 1100px; margin: 0 auto; text-align: center; }

/* 🆕 v3.1 — Badge de saldo del jugador */
.astrolot_balance_box {
    text-align: center;
    margin-bottom: 12px;
    padding: 8px 14px;
    background: rgba(0, 40, 20, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px;
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.2);
}
.astrolot_balance_badge {
    color: #66ff99;
    font-size: 12px;
    font-weight: 600;
}
.astrolot_balance_badge strong {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-size: 14px;
    letter-spacing: 0.5px;
}

/* ============ CABECERA PÚRPURA/CYAN ============ */
.astrolot_header {
    background: linear-gradient(135deg, rgba(74, 20, 140, 0.85) 0%, rgba(0, 188, 212, 0.75) 100%);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-radius: 12px;
    padding: 16px 20px;
    border: 1px solid var(--border-color);
    border-bottom: 2px solid var(--accent-cyan);
    color: #fff;
    margin-bottom: 14px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: space-between;
    align-items: center;
    text-align: left;
    flex-wrap: wrap;
    gap: 14px;
}
.astrolot_header_left { flex: 1; min-width: 220px; }
.astrolot_title {
    font-size: 22px;
    font-weight: bold;
    margin-bottom: 4px;
    letter-spacing: 1px;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.5), 0 0 20px rgba(0, 224, 255, 0.3);
}
.astrolot_subtitle {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.85);
    margin-bottom: 10px;
    letter-spacing: 0.5px;
}
.astrolot_cd_wrap {
    display: flex;
    gap: 6px;
    margin-top: 8px;
}
.astrolot_cd_box {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 255, 255, 0.4);
    border-radius: 8px;
    padding: 6px 10px;
    min-width: 48px;
    text-align: center;
}
.astrolot_cd_num {
    font-size: 20px;
    font-weight: bold;
    color: #fff;
    line-height: 1;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}
.astrolot_cd_label {
    font-size: 8px;
    text-transform: uppercase;
    color: rgba(255, 255, 255, 0.75);
    margin-top: 3px;
    letter-spacing: 1px;
}
.astrolot_header_right {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-radius: 10px;
    padding: 10px 18px;
    border: 1px solid rgba(251, 191, 36, 0.5);
    text-align: center;
    min-width: 160px;
}
.astrolot_jackpot_lbl {
    font-size: 9px;
    text-transform: uppercase;
    color: #ffeeaa;
    letter-spacing: 1.5px;
    margin-bottom: 4px;
}
.astrolot_jackpot_num {
    font-size: 28px;
    font-weight: bold;
    color: var(--accent-gold);
    text-shadow: 0 0 20px rgba(251, 191, 36, 0.6);
    font-family: 'Courier New', monospace;
    line-height: 1;
}
.astrolot_jackpot_cur {
    font-size: 11px;
    color: #ffeeaa;
    margin-top: 2px;
}
.astrolot_jackpot_tickets {
    font-size: 9px;
    color: rgba(255, 255, 255, 0.75);
    margin-top: 6px;
}

/* ============ GRID PRINCIPAL ============ */
.astrolot_main {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 14px;
    margin-bottom: 14px;
}

/* ============ PANEL ============ */
.astrolot_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 14px 16px;
    text-align: left;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astrolot_panel_title {
    text-transform: uppercase;
    color: var(--accent-cyan);
    font-size: 13px;
    font-weight: bold;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 12px;
    letter-spacing: 0.5px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.astrolot_auto_btn {
    background: rgba(0, 224, 255, 0.12);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.4);
    color: var(--accent-cyan);
    padding: 3px 10px;
    border-radius: 6px;
    font-size: 10px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: none;
    letter-spacing: 0;
    font-family: inherit;
}
.astrolot_auto_btn:hover {
    background: rgba(0, 224, 255, 0.25);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
    transform: translateY(-1px);
}

/* ============ NÚMEROS ELEGIDOS ============ */
.astrolot_elegidos_wrap {
    text-align: center;
    margin-bottom: 14px;
}
.astrolot_elegidos_lbl {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 6px;
}
.astrolot_elegidos {
    display: inline-flex;
    gap: 8px;
    flex-wrap: wrap;
    justify-content: center;
    min-height: 44px;
}
.astrolot_elegido {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 44px;
    height: 44px;
    background: linear-gradient(135deg, #0066cc, var(--accent-cyan));
    color: #000;
    border-radius: 8px;
    font-size: 18px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transition: all 0.25s ease;
}
.astrolot_elegido.vacio {
    background: rgba(0, 224, 255, 0.08);
    border: 2px dashed rgba(0, 224, 255, 0.3);
    color: #4a5568;
    box-shadow: none;
}

/* ============ GRID DE NÚMEROS ============ */
.astrolot_grid {
    display: grid;
    grid-template-columns: repeat(10, 1fr);
    gap: 5px;
    margin: 12px 0;
}
.astrolot_num {
    background: rgba(30, 41, 59, 0.6);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    padding: 9px 0;
    text-align: center;
    color: var(--text-main);
    cursor: pointer;
    transition: all 0.25s ease;
    font-weight: bold;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    user-select: none;
}
.astrolot_num:hover {
    border-color: var(--accent-cyan);
    color: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
    transform: translateY(-1px);
}
.astrolot_num.selected {
    background: linear-gradient(135deg, #0066cc, var(--accent-cyan));
    color: #000;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.6);
}
.astrolot_num.disabled {
    opacity: 0.4;
    cursor: not-allowed;
}

/* ============ BOTÓN COMPRAR ============ */
.astrolot_btn_buy {
    background: linear-gradient(135deg, #aa6600 0%, #fbbf24 100%);
    color: #1a1000;
    border: 1px solid var(--accent-gold);
    padding: 14px 30px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 15px;
    cursor: pointer;
    width: 100%;
    transition: all 0.25s ease;
    letter-spacing: 1px;
    font-family: inherit;
    margin-top: 8px;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.astrolot_btn_buy:hover:not(:disabled) {
    box-shadow: 0 0 24px rgba(251, 191, 36, 0.6);
    transform: translateY(-2px);
    background: linear-gradient(135deg, #fbbf24 0%, #fde047 100%);
}
.astrolot_btn_buy:disabled {
    background: rgba(30, 41, 59, 0.85);
    border-color: var(--border-color);
    color: var(--text-muted);
    cursor: not-allowed;
    text-shadow: none;
}
.astrolot_btn_buy_ico {
    margin-right: 6px;
}

/* ============ INFO TICKETS ============ */
.astrolot_info_bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 10px;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    font-size: 11px;
    color: var(--text-main);
    flex-wrap: wrap;
    gap: 8px;
}
.astrolot_info_bar b { color: var(--text-title); }
.astrolot_info_bar .ok { color: var(--accent-green); }
.astrolot_info_bar .warn { color: var(--accent-gold); }
.astrolot_info_bar .err { color: var(--accent-red); }

/* ============ TABLA DE PREMIOS (LATERAL) ============ */
.astrolot_prizes_table {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-bottom: 14px;
}
.astrolot_prize_row {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px 12px;
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.astrolot_prize_row.jackpot { background: rgba(251, 191, 36, 0.08); border-left: 3px solid var(--accent-gold); }
.astrolot_prize_row.p3 { border-left: 3px solid var(--accent-green); }
.astrolot_prize_row.p2 { border-left: 3px solid var(--accent-cyan); }

.astrolot_prize_top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
}
.astrolot_balls {
    display: flex;
    gap: 3px;
    flex-shrink: 0;
}
.astrolot_ball {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    display: inline-block;
}
.astrolot_ball.gold { background: var(--accent-gold); box-shadow: 0 0 6px rgba(251, 191, 36, 0.5); }
.astrolot_ball.green { background: var(--accent-green); box-shadow: 0 0 6px rgba(74, 255, 136, 0.5); }
.astrolot_ball.cyan { background: var(--accent-cyan); box-shadow: 0 0 6px rgba(0, 224, 255, 0.5); }
.astrolot_ball.grey { background: #4a5568; }

.astrolot_prize_val {
    font-size: 13px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    color: var(--accent-gold);
    text-align: right;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}
.astrolot_prize_val.green { color: var(--accent-green); text-shadow: 0 0 8px rgba(74, 255, 136, 0.3); }
.astrolot_prize_val.cyan { color: var(--accent-cyan); text-shadow: 0 0 8px rgba(0, 224, 255, 0.3); }

.astrolot_prize_bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 10px;
    color: var(--text-muted);
    font-family: 'Courier New', monospace;
}
.astrolot_prize_pct {
    display: inline-block;
    padding: 2px 6px;
    border-radius: 4px;
    font-weight: bold;
    font-size: 10px;
}
.astrolot_prize_pct.gold  { background: rgba(251, 191, 36, 0.15); color: var(--accent-gold); }
.astrolot_prize_pct.green { background: rgba(74, 255, 136, 0.15); color: var(--accent-green); }
.astrolot_prize_pct.cyan  { background: rgba(0, 224, 255, 0.15);   color: var(--accent-cyan); }

/* ============ INFO PORCENTAJES ============ */
.astrolot_pct_info {
    background: rgba(0, 224, 255, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 12px;
    font-size: 10px;
    color: #aaddff;
    line-height: 1.6;
}
.astrolot_pct_info b { color: var(--text-title); }

/* ============ CÓMO JUGAR ============ */
.astrolot_howto {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px 12px;
    font-size: 10.5px;
    color: var(--text-main);
    line-height: 1.7;
}
.astrolot_howto ol {
    margin: 6px 0 0 0;
    padding-left: 20px;
}
.astrolot_howto li {
    margin-bottom: 3px;
}
.astrolot_howto .vip_note {
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    color: #ffeeaa;
    font-size: 10px;
}

/* ============ MENSAJES ============ */
.astrolot_msg {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-size: 11.5px;
    text-align: left;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astrolot_msg.success { background: rgba(74, 255, 136, 0.10); border-left: 3px solid var(--accent-green); color: var(--accent-green); }
.astrolot_msg.error { background: rgba(239, 68, 68, 0.10); border-left: 3px solid var(--accent-red); color: var(--accent-red); }
.astrolot_msg.info { background: rgba(0, 224, 255, 0.10); border-left: 3px solid var(--accent-cyan); color: var(--accent-cyan); }

/* ============ SIN SORTEO ============ */
.astrolot_empty {
    color: var(--text-muted);
    font-size: 12px;
    text-align: center;
    padding: 40px 20px;
    font-style: italic;
}

/* ============ RESULTADO ANTERIOR ============ */
.astrolot_prev {
    background: linear-gradient(135deg, rgba(26, 16, 0, 0.85), rgba(42, 26, 0, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(251, 191, 36, 0.3);
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 14px;
    text-align: left;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}
.astrolot_prev_title {
    font-size: 11px;
    text-transform: uppercase;
    color: var(--accent-gold);
    letter-spacing: 1px;
    margin-bottom: 8px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}
.astrolot_prev_nums {
    display: flex;
    gap: 6px;
    margin-bottom: 8px;
    flex-wrap: wrap;
}
.astrolot_prev_num {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    background: linear-gradient(135deg, #aa6600, var(--accent-gold));
    color: #000;
    border-radius: 6px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    font-size: 13px;
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}
.astrolot_prev_info {
    font-size: 11px;
    color: var(--text-main);
}
.astrolot_prev_info b { color: var(--text-title); }

/* ============ NAVEGACIÓN ============ */
.astrolot_nav {
    margin-bottom: 12px;
    text-align: left;
}
.astrolot_nav a {
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 11px;
    margin-right: 14px;
    padding: 4px 10px;
    border-radius: 6px;
    transition: all 0.25s ease;
    border: 1px solid transparent;
}
.astrolot_nav a:hover {
    background: rgba(0, 224, 255, 0.1);
    border-color: rgba(0, 224, 255, 0.4);
    text-decoration: none;
    transform: translateY(-1px);
}
.astrolot_nav a.active {
    background: rgba(0, 224, 255, 0.15);
    color: var(--accent-cyan);
    border-color: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}

@media (max-width: 900px) {
    .astrolot_main { grid-template-columns: 1fr; }
    .astrolot_header { flex-direction: column; align-items: stretch; }
    .astrolot_header_right { text-align: center; }
    .astrolot_grid { grid-template-columns: repeat(6, 1fr); }
}
@media (max-width: 480px) {
    .astrolot_grid { grid-template-columns: repeat(5, 1fr); }
    .astrolot_cd_num { font-size: 16px; }
}
</style>

<div class="astrolot_wrap">

    {* 🆕 v3.1 — BADGE DE SALDO DEL JUGADOR *}
    <div class="astrolot_balance_box">
        <span class="astrolot_balance_badge">
            💲 Tu saldo: <strong>{$saldo_actual|number_format:0:',,':'.'}</strong> {$moneda}
        </span>
    </div>

    {if $msg}
    <div class="astrolot_msg {$msg_type}">{$msg}</div>
    {/if}

    <div class="astrolot_nav">
        <a href="game.php?page=lottery" class="active">Lotería</a>
        <a href="game.php?page=lottery&mode=myTickets">Mis Tickets</a>
        <a href="game.php?page=lottery&mode=history">Historial</a>
    </div>

    {if $hay_sorteo}

    {* ============ CABECERA ============ *}
    <div class="astrolot_header">
        <div class="astrolot_header_left">
            <div class="astrolot_title">🎫 Lotería Galáctica</div>
            <div class="astrolot_subtitle">Sorteo #{$draw.numero_sorteo} — Próximo sorteo en:</div>
            <div class="astrolot_cd_wrap">
                <div class="astrolot_cd_box">
                    <div class="astrolot_cd_num" id="lot_d">--</div>
                    <div class="astrolot_cd_label">Días</div>
                </div>
                <div class="astrolot_cd_box">
                    <div class="astrolot_cd_num" id="lot_h">--</div>
                    <div class="astrolot_cd_label">Hrs</div>
                </div>
                <div class="astrolot_cd_box">
                    <div class="astrolot_cd_num" id="lot_m">--</div>
                    <div class="astrolot_cd_label">Min</div>
                </div>
                <div class="astrolot_cd_box">
                    <div class="astrolot_cd_num" id="lot_s">--</div>
                    <div class="astrolot_cd_label">Seg</div>
                </div>
            </div>
        </div>

        {* 🆕 v3.1 — Jackpot con moneda del riel *}
        <div class="astrolot_header_right">
            <div class="astrolot_jackpot_lbl">🏆 Jackpot Acumulado</div>
            <div class="astrolot_jackpot_num">{$draw.jackpot_display_fmt|default:'0'}</div>
            <div class="astrolot_jackpot_cur">{$draw.moneda_label|default:$moneda}</div>
            <div class="astrolot_jackpot_tickets">🎟️ {$draw.tickets_vendidos} tickets vendidos</div>
        </div>
    </div>

    {* ============ GRID PRINCIPAL ============ *}
    <div class="astrolot_main">

        {* ============ COLUMNA IZQUIERDA: ELEGIR NÚMEROS ============ *}
        <div class="astrolot_panel">
            <div class="astrolot_panel_title">
                <span>🎯 Elige tus Coordenadas ({$config.numeros_a_elegir|default:0} de {$config.rango_max|default:0})</span>
                <button type="button" class="astrolot_auto_btn" id="astrolot_auto">🎲 Auto</button>
            </div>

            <div class="astrolot_elegidos_wrap">
                <div class="astrolot_elegidos_lbl">Tus números:</div>
                <div class="astrolot_elegidos" id="astrolot_elegidos"></div>
            </div>

            <div class="astrolot_grid" id="astrolot_grid">
                {for $i=1 to $config.rango_max|default:0}
                <div class="astrolot_num" data-num="{$i}">{$i}</div>
                {/for}
            </div>

            <form method="POST" action="game.php?page=lottery&mode=buy" id="astrolot_form">
                <input type="hidden" name="token" value="{$token}">
                <div id="astrolot_numeros_inputs"></div>

                {* 🆕 v3.1 — Precio real del jugador (con VIP + ×2 si QVAPAY) *}
                <button type="submit" class="astrolot_btn_buy" id="astrolot_btn_buy" disabled>
                    <span class="astrolot_btn_buy_ico">🎟️</span> COMPRAR TICKET — {$precio_real|default:0|number_format:0:',,':'.'} {$moneda}
                </button>
            </form>

            <div class="astrolot_info_bar">
                <span>🎟️ <b id="astrolot_count">0</b>/{$config.numeros_a_elegir|default:0} números</span>
                <span>💰 Costo: <b>{$precio_real|default:0|number_format:0:',,':'.'} {$moneda}</b></span>
                <span>💎 Tu saldo: <b class="{if $mi_saldo >= $precio_real}ok{else}err{/if}">{$mi_saldo|number_format:0:',,':'.'}</b> {$moneda}</span>
                <span>🎫 Tickets: <b>{$mis_tickets_count}</b>/{$config.max_tickets_por_jugador|default:0}</span>
            </div>
        </div>

        {* ============ COLUMNA DERECHA: PREMIOS + CÓMO JUGAR ============ *}
        <div>
            <div class="astrolot_panel" style="margin-bottom:12px;">
                <div class="astrolot_panel_title">🏆 Tabla de Premios</div>

                <div class="astrolot_pct_info">
                    Los porcentajes del ticket se ajustan segun el <b>jackpot actual</b>.
                    <br>Jackpot actual: <b>{$draw.jackpot_display_fmt|default:'0'} {$draw.moneda_label|default:$moneda}</b>
                </div>

                <div class="astrolot_prizes_table">
                    {* Jackpot *}
                    <div class="astrolot_prize_row jackpot">
                        <div class="astrolot_prize_top">
                            <div class="astrolot_balls">
                                {for $i=1 to $config.numeros_a_elegir|default:0}
                                <span class="astrolot_ball gold"></span>
                                {/for}
                            </div>
                            <div class="astrolot_prize_val astrolot_prize_jackpot">
                                {$draw.jackpot_display_fmt|default:'0'}
                            </div>
                        </div>
                        <div class="astrolot_prize_bottom">
                            <span>JACKPOT ({$config.numeros_a_elegir|default:0} aciertos)</span>
                            <span class="astrolot_prize_pct gold">{$draw.pct_jackpot_aplicado|default:70}%</span>
                        </div>
                    </div>

                    {* 3 aciertos *}
                    <div class="astrolot_prize_row p3">
                        <div class="astrolot_prize_top">
                            <div class="astrolot_balls">
                                {for $i=1 to ($config.numeros_a_elegir|default:0) - 1}
                                <span class="astrolot_ball green"></span>
                                {/for}
                                <span class="astrolot_ball grey"></span>
                            </div>
                            <div class="astrolot_prize_val green">
                                {$draw.pozo3_display|default:0|number_format:0:',,':'.'}
                            </div>
                        </div>
                        <div class="astrolot_prize_bottom">
                            <span>{($config.numeros_a_elegir|default:0) - 1} aciertos · Repartido</span>
                            <span class="astrolot_prize_pct green">{$draw.pct_3_aplicado|default:20}%</span>
                        </div>
                    </div>

                    {* 2 aciertos *}
                    <div class="astrolot_prize_row p2">
                        <div class="astrolot_prize_top">
                            <div class="astrolot_balls">
                                {for $i=1 to ($config.numeros_a_elegir|default:0) - 2}
                                <span class="astrolot_ball cyan"></span>
                                {/for}
                                {for $i=1 to 2}
                                <span class="astrolot_ball grey"></span>
                                {/for}
                            </div>
                            <div class="astrolot_prize_val cyan">
                                {$draw.pozo2_display|default:0|number_format:0:',,':'.'}
                            </div>
                        </div>
                        <div class="astrolot_prize_bottom">
                            <span>{($config.numeros_a_elegir|default:0) - 2} aciertos · Repartido</span>
                            <span class="astrolot_prize_pct cyan">{$draw.pct_2_aplicado|default:10}%</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="astrolot_panel">
                <div class="astrolot_panel_title">📖 ¿Cómo Jugar?</div>
                <div class="astrolot_howto">
                    <ol>
                        <li>Elegí <b>{$config.numeros_a_elegir|default:0} números</b> del 1 al {$config.rango_max|default:0}</li>
                        <li>Comprá tu ticket con <b>{$moneda}</b></li>
                        <li>Esperá el sorteo</li>
                        <li>Si nadie acierta el jackpot, <b>crece</b> para el próximo</li>
                    </ol>
                    {if $config.descuento_vip|default:0 > 0}
                    <div class="vip_note">⭐ VIP obtiene <b>{$config.descuento_vip}% descuento</b> en tickets</div>
                    {/if}
                </div>
            </div>
        </div>
    </div>

    {* ============ RESULTADO ANTERIOR ============ *}
    {if $hay_anterior}
    <div class="astrolot_prev">
        <div class="astrolot_prev_title">🎰 Último Sorteo — #{$sorteo_anterior.numero_sorteo}</div>
        <div class="astrolot_prev_nums">
            {foreach $sorteo_anterior.numeros_sorteados_arr as $num}
            <span class="astrolot_prev_num">{$num}</span>
            {/foreach}
        </div>
        <div class="astrolot_prev_info">
            {if $sorteo_anterior.ganador_jackpot_id}
                🏆 Jackpot: <b>{$sorteo_anterior.jackpot_display|default:0|number_format:0:',,':'.'} {$sorteo_anterior.moneda_label|default:$moneda}</b> — Ganador ID: <b>#{$sorteo_anterior.ganador_jackpot_id}</b>
            {else}
                {math equation="x * y" x=$sorteo_anterior.jackpot_rollover|default:0 y=$multiplier|default:1 assign="rollover_disp"}
                🎰 Jackpot no fue ganado — acumulado: <b>{$rollover_disp|number_format:0:',,':'.'} {$moneda}</b>
            {/if}
        </div>
    </div>
    {/if}

    {* ============ SCRIPT (solo si hay sorteo) ============ *}
    <script>
    (function() {
        var MAX_NUMEROS = {$config.numeros_a_elegir|default:0};
        var RANGO_MAX   = {$config.rango_max|default:0};
        var seleccionados = [];

        var grid = document.getElementById('astrolot_grid');
        var elegidosWrap = document.getElementById('astrolot_elegidos');
        var form = document.getElementById('astrolot_form');
        var inputsWrap = document.getElementById('astrolot_numeros_inputs');
        var btnBuy = document.getElementById('astrolot_btn_buy');
        var countEl = document.getElementById('astrolot_count');
        var btnAuto = document.getElementById('astrolot_auto');

        if (!grid) return;

        grid.querySelectorAll('.astrolot_num').forEach(function(el) {
            el.addEventListener('click', function() {
                var num = parseInt(el.getAttribute('data-num'), 10);
                var idx = seleccionados.indexOf(num);

                if (idx >= 0) {
                    seleccionados.splice(idx, 1);
                } else {
                    if (seleccionados.length >= MAX_NUMEROS) return;
                    seleccionados.push(num);
                }
                render();
            });
        });

        if (btnAuto) {
            btnAuto.addEventListener('click', function() {
                seleccionados = [];
                while (seleccionados.length < MAX_NUMEROS) {
                    var n = Math.floor(Math.random() * RANGO_MAX) + 1;
                    if (seleccionados.indexOf(n) === -1) seleccionados.push(n);
                }
                seleccionados.sort(function(a, b) { return a - b; });
                render();
            });
        }

        function render() {
            grid.querySelectorAll('.astrolot_num').forEach(function(el) {
                var num = parseInt(el.getAttribute('data-num'), 10);
                if (seleccionados.indexOf(num) >= 0) {
                    el.classList.add('selected');
                } else {
                    el.classList.remove('selected');
                }
            });

            var html = '';
            for (var i = 0; i < MAX_NUMEROS; i++) {
                if (seleccionados[i] !== undefined) {
                    var pad = seleccionados[i] < 10 ? '0' + seleccionados[i] : seleccionados[i];
                    html += '<div class="astrolot_elegido">' + pad + '</div>';
                } else {
                    html += '<div class="astrolot_elegido vacio">--</div>';
                }
            }
            elegidosWrap.innerHTML = html;

            var inputs = '';
            seleccionados.forEach(function(n) {
                inputs += '<input type="hidden" name="numeros[]" value="' + n + '">';
            });
            inputsWrap.innerHTML = inputs;

            countEl.textContent = seleccionados.length;
            btnBuy.disabled = (seleccionados.length !== MAX_NUMEROS);
        }

        render();

        var FIN = {$draw.fecha_sorteo|default:0};
        if (FIN > 0) {
            function tick() {
                var ahora = Math.floor(Date.now() / 1000);
                var rest = FIN - ahora;
                if (rest < 0) rest = 0;

                var d = Math.floor(rest / 86400);
                var h = Math.floor((rest % 86400) / 3600);
                var m = Math.floor((rest % 3600) / 60);
                var s = rest % 60;

                var pad = function(x) { return x < 10 ? '0' + x : x; };

                var elD = document.getElementById('lot_d');
                var elH = document.getElementById('lot_h');
                var elM = document.getElementById('lot_m');
                var elS = document.getElementById('lot_s');

                if (elD) elD.textContent = pad(d);
                if (elH) elH.textContent = pad(h);
                if (elM) elM.textContent = pad(m);
                if (elS) elS.textContent = pad(s);
            }
            tick();
            setInterval(tick, 1000);
        }
    })();
    </script>

    {else}

    {* ============ SIN SORTEO ACTIVO ============ *}
    <div class="astrolot_panel">
        <div class="astrolot_empty">
            🎫 No hay un sorteo activo en este momento.<br>
            <small>El administrador creará uno pronto.</small>
        </div>
    </div>

    {/if}

</div>

{/block}