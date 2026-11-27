{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliancetalent.default.tpl === *}
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


{* ============================================================
 * ARBOL DE TALENTOS DE ALIANZA - AstroIO v2.0 (DUAL RIEL)
 * Prefijo CSS: .astrotalent_
 *
 * v2.0 (2026-10-30) - DUAL RIEL:
 *  - Badge de saldo del jugador con {$moneda}
 *  - Seccion Reset usa {$reset_cost_user_fmt} {$moneda}
 *  - Boton de reset deshabilitado si !{$can_afford_reset}
 *  - Aviso "Te faltan X {$moneda}" si no alcanza
 *  - Seccion visible solo si {$has_talents}
 *  - Cero hardcodeos de "NTX-20", "UNTX-20", "CUP", "USD"
 *  - Arbol, puntos, bonus e historial SIN CAMBIOS (no tocan moneda)
 * ============================================================ *}

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

.astrotalent_wrap { text-align: center; padding: 15px; box-sizing: border-box; }
.astrotalent_ {
    width: 950px;
    max-width: 100%;
    display: inline-block;
    text-align: left;
    font-family: Verdana, Arial, sans-serif;
    font-size: 11px;
    color: var(--text-main);
}

/* Mensajes flash (glassmorphism) */
.astrotalent_msg_ok {
    background: linear-gradient(180deg, rgba(0, 51, 34, 0.7), rgba(0, 34, 17, 0.7));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #66ff99;
    padding: 10px 14px;
    border-radius: 10px;
    border: 1px solid rgba(102, 255, 153, 0.3);
    border-left: 3px solid #66ff99;
    margin-bottom: 12px;
}
.astrotalent_msg_err {
    background: linear-gradient(180deg, rgba(51, 0, 17, 0.7), rgba(34, 0, 8, 0.7));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #ff4488;
    padding: 10px 14px;
    border-radius: 10px;
    border: 1px solid rgba(255, 68, 136, 0.3);
    border-left: 3px solid #ff4488;
    margin-bottom: 12px;
}

/* 🆕 v2.0 — Badge de saldo del jugador */
.astrotalent_balance_box {
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
.astrotalent_balance_badge {
    color: #66ff99;
    font-size: 12px;
    font-weight: 600;
}
.astrotalent_balance_badge strong {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-size: 14px;
    letter-spacing: 0.5px;
}

/* Botón volver (cyan) */
.astrotalent_back {
    display: inline-block;
    padding: 7px 18px;
    background: linear-gradient(135deg, rgba(0, 119, 204, 0.9), rgba(0, 68, 136, 0.9));
    color: #fff !important;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none !important;
    transition: 0.25s ease;
    margin-bottom: 10px;
}
.astrotalent_back:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 85, 170, 0.95));
    box-shadow: 0 0 14px rgba(0, 204, 255, 0.5);
    color: #fff !important;
    transform: translateY(-2px);
}
.astrotalent_back:active {
    transform: translateY(0);
}

/* Cabecera (acento púrpura) */
.astrotalent_header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(85, 0, 170, 0.9));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(187, 102, 255, 0.4);
    border-radius: 12px;
    padding: 12px 16px;
    margin-bottom: 12px;
    box-shadow: 0 4px 20px rgba(119, 0, 204, 0.4);
}
.astrotalent_header h2 {
    margin: 0;
    color: #fff;
    font-size: 15px;
    text-transform: uppercase;
    text-shadow: 0 2px 6px rgba(0, 0, 0, 0.4);
}
.astrotalent_header .stats {
    display: flex;
    gap: 16px;
}
.astrotalent_header .stat {
    text-align: right;
}
.astrotalent_header .stat .lbl {
    color: rgba(255, 255, 255, 0.7);
    font-size: 9px;
    text-transform: uppercase;
}
.astrotalent_header .stat .val {
    color: #fff;
    font-size: 16px;
    font-weight: bold;
}

/* Progreso de puntos (glassmorphism) */
.astrotalent_progress {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 12px;
    transition: 0.2s ease;
}
.astrotalent_progress:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotalent_progress_bar {
    height: 8px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 4px;
    overflow: hidden;
    margin-top: 6px;
}
.astrotalent_progress_fill {
    height: 100%;
    background: linear-gradient(90deg, #aa44ff, #00e0ff);
    border-radius: 4px;
    transition: 0.5s ease;
}

/* Caja general (glassmorphism) */
.astrotalent_box {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 14px;
    margin-bottom: 12px;
    transition: 0.2s ease;
}
.astrotalent_box:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrotalent_title {
    color: #00e0ff;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 12px;
    letter-spacing: 0.5px;
}

/* Arbol */
.astrotalent_tree { padding: 4px 0; }

.astrotalent_row {
    display: grid;
    grid-template-columns: 90px 1fr 1fr 1fr;
    gap: 10px;
    margin-bottom: 12px;
    align-items: stretch;
}

/* Etiqueta lateral del rango (acento púrpura) */
.astrotalent_row_label {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 8px 4px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-left: 3px solid var(--accent-purple);
    border-radius: 10px;
}
.astrotalent_row_label .rnum {
    color: #cc88ff;
    font-weight: bold;
    font-size: 11px;
}
.astrotalent_row_label .rlvl {
    color: var(--text-muted);
    font-size: 9px;
    margin-top: 2px;
}
.astrotalent_row_label .rcost {
    color: #ffcc44;
    font-size: 9px;
    margin-top: 4px;
    font-family: 'Courier New', monospace;
}

/* Tarjetas de talento (glassmorphism) */
.astrotalent_card {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 8px;
    text-align: center;
    transition: 0.25s ease;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.astrotalent_card .ico {
    font-size: 14px;
    line-height: 1;
    margin-bottom: 6px;
    font-weight: bold;
}
.astrotalent_card .nm {
    font-size: 10px;
    font-weight: bold;
    margin-bottom: 3px;
    color: var(--text-main);
}
.astrotalent_card .ef {
    font-size: 9px;
    color: var(--text-muted);
    line-height: 1.3;
}
.astrotalent_card .ef .v {
    font-weight: bold;
    color: #00e0ff;
}
.astrotalent_card form {
    margin-top: 6px;
}

/* Estados funcionales (mantener colores del original) */
.astrotalent_card.locked {
    opacity: 0.35;
    border-style: dashed;
}
.astrotalent_card.available {
    border-color: #aa44ff;
    box-shadow: 0 0 12px rgba(170, 68, 255, 0.3);
}
.astrotalent_card.available:hover {
    border-color: #cc88ff;
    box-shadow: 0 0 18px rgba(170, 68, 255, 0.5);
    transform: translateY(-2px);
}
.astrotalent_card.selected {
    border-color: #00ff88;
    background: linear-gradient(180deg, rgba(0, 51, 34, 0.7), rgba(0, 26, 17, 0.7));
    box-shadow: 0 0 16px rgba(0, 255, 136, 0.4);
}
.astrotalent_card.selected .nm {
    color: #66ff99;
}

/* Botones */
.astrotalent_btn {
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.9), rgba(119, 0, 204, 0.9));
    color: #fff;
    padding: 6px 14px;
    border: 1px solid #bb66ff;
    border-radius: 8px;
    font-weight: bold;
    font-size: 10px;
    cursor: pointer;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    transition: 0.25s ease;
    font-family: inherit;
}
.astrotalent_btn:hover {
    background: linear-gradient(135deg, rgba(187, 102, 255, 0.95), rgba(136, 0, 221, 0.95));
    box-shadow: 0 0 12px rgba(170, 68, 255, 0.6);
    transform: translateY(-2px);
}
.astrotalent_btn:active {
    transform: translateY(0);
}
.astrotalent_btn_danger {
    background: linear-gradient(135deg, rgba(204, 34, 85, 0.9), rgba(136, 0, 51, 0.9));
    border-color: #ee3377;
}
.astrotalent_btn_danger:hover {
    background: linear-gradient(135deg, rgba(221, 51, 119, 0.95), rgba(153, 0, 68, 0.95));
    box-shadow: 0 0 14px rgba(255, 68, 136, 0.6);
}
.astrotalent_btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    background: #333 !important;
    border-color: #444 !important;
    transform: none !important;
    box-shadow: none !important;
}

/* Bonuses activos (glassmorphism) */
.astrotalent_summary_grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
}
.astrotalent_summary_card {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 8px;
    text-align: center;
    transition: 0.25s ease;
}
.astrotalent_summary_card:hover {
    border-color: rgba(0, 204, 255, 0.4);
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.25);
    transform: translateY(-2px);
}
.astrotalent_summary_card.off {
    opacity: 0.35;
}
.astrotalent_summary_card .lbl {
    font-size: 9px;
    text-transform: uppercase;
    margin-bottom: 3px;
    color: var(--text-muted);
}
.astrotalent_summary_card .v {
    font-size: 15px;
    font-weight: bold;
    color: #fff;
}

/* Reset (glassmorphism) */
.astrotalent_reset {
    background: rgba(136, 0, 51, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(136, 0, 51, 0.6);
    border-radius: 10px;
    padding: 12px;
    text-align: center;
    margin-top: 10px;
}

/* Historial (glassmorphism) */
.astrotalent_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}
.astrotalent_table th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #fff;
    padding: 6px 8px;
    text-align: left;
    border-bottom: 1px solid var(--accent-cyan);
    font-size: 10px;
    text-transform: uppercase;
}
.astrotalent_table td {
    padding: 6px 8px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
}
.astrotalent_table tr:hover td {
    background: rgba(0, 204, 255, 0.05);
}
.astrotalent_table .tag {
    display: inline-block;
    padding: 1px 6px;
    border-radius: 4px;
    font-size: 9px;
    font-weight: bold;
    text-transform: uppercase;
}
.astrotalent_table .tag.points_added {
    background: rgba(0, 51, 34, 0.8);
    color: #66ff99;
}
.astrotalent_table .tag.talent_set {
    background: rgba(0, 51, 85, 0.8);
    color: #66ccff;
}
.astrotalent_table .tag.talents_reset {
    background: rgba(51, 0, 17, 0.8);
    color: #ff4488;
}

/* Responsive */
@media (max-width: 720px) {
    .astrotalent_wrap { padding: 5px; }
    .astrotalent_ { width: 100%; }
    .astrotalent_box { padding: 8px; }

    .astrotalent_row {
        grid-template-columns: 36px 1fr 1fr 1fr !important;
        gap: 4px !important;
        margin-bottom: 8px !important;
    }

    .astrotalent_row_label {
        padding: 4px 1px !important;
    }
    .astrotalent_row_label .rnum { font-size: 9px !important; }
    .astrotalent_row_label .rlvl { font-size: 7px !important; }
    .astrotalent_row_label .rcost { font-size: 7px !important; }

    .astrotalent_card {
        padding: 5px 2px !important;
    }
    .astrotalent_card .ico { font-size: 10px !important; margin-bottom: 2px !important; }
    .astrotalent_card .nm { font-size: 8px !important; margin-bottom: 2px !important; }
    .astrotalent_card .ef { font-size: 7px !important; line-height: 1.1 !important; }

    .astrotalent_btn {
        padding: 3px 2px !important;
        font-size: 7px !important;
        width: 100% !important;
        letter-spacing: 0 !important;
    }

    .astrotalent_card div[style*="font-size:9px"] {
        font-size: 7px !important;
    }

    .astrotalent_summary_grid { grid-template-columns: repeat(2, 1fr); gap: 5px !important; }
    .astrotalent_header { flex-direction: column; gap: 8px; text-align: center; }
    .astrotalent_header .stats { justify-content: center; }
    .astrotalent_header .stat { text-align: center; }
}
</style>

<div class="astrotalent_wrap">
<div class="astrotalent_">

    {* ============ MENSAJES FLASH ============ *}
    {if $msg}
        <div class="{if $msg_type == 'ok'}astrotalent_msg_ok{else}astrotalent_msg_err{/if}">
            {$msg|escape:'html'}
        </div>
    {/if}

    {* ============ BOTON VOLVER ============ *}
    <div style="text-align:left;">
        <a href="game.php?page=alliance" class="astrotalent_back">&lt;- Volver a la Alianza</a>
        <a href="game.php?page=allianceBank" class="astrotalent_back" style="background:linear-gradient(135deg,rgba(34,204,102,0.9),rgba(17,136,51,0.9));border-color:#33dd77;margin-left:8px;">[BANCO] Ir al Banco</a>
    </div>

    {* 🆕 v2.0 — BADGE DE SALDO DEL JUGADOR *}
    <div class="astrotalent_balance_box">
        <span class="astrotalent_balance_badge">
            💲 Tu saldo: <strong>{$saldo_actual|number_format:0:',,':'.'}</strong> {$moneda}
        </span>
    </div>

    {* ============ CABECERA ============ *}
    <div class="astrotalent_header">
        <h2>[ARBOL] Arbol de Talentos - [{$alliance_tag}] {$alliance_name}</h2>
        <div class="stats">
            <div class="stat">
                <div class="lbl">Puntos disponibles</div>
                <div class="val" style="color:#66ff99;">{$available_fmt}</div>
            </div>
            <div class="stat">
                <div class="lbl">Rango</div>
                <div class="val">{$current_rank} / 7</div>
            </div>
        </div>
    </div>

    {* ============ PROGRESO ============ *}
    <div class="astrotalent_progress">
        <div style="display:flex;justify-content:space-between;align-items:center;">
            <span style="color:#94a3b8;font-size:10px;">
                Puntos totales: <b style="color:#00e0ff;">{$total_points_fmt}</b>
                | Gastados: <b style="color:#ffcc44;">{$spent_points_fmt}</b>
                | Tu aporte hoy: <b style="color:#66ff99;">{$daily_used} / {$max_daily}</b>
            </span>
            <span style="color:#94a3b8;font-size:10px;">Progreso al rango 7</span>
        </div>
        <div class="astrotalent_progress_bar">
            <div class="astrotalent_progress_fill" style="width:{if $current_rank > 0}{$current_rank * 14}{else}2{/if}%;"></div>
        </div>
    </div>

    {* ============ BONUSES ACTIVOS ============ *}
    <div class="astrotalent_box">
        <div class="astrotalent_title">* Bonuses actuales de la alianza</div>
        <div class="astrotalent_summary_grid">
            <div class="astrotalent_summary_card {if $active_bonuses.production == 0}off{/if}">
                <div class="lbl">Produccion</div>
                <div class="v" style="color:#66ff99;">+{$active_bonuses.production*100|number_format:2}%</div>
            </div>
            <div class="astrotalent_summary_card {if $active_bonuses.attack == 0}off{/if}">
                <div class="lbl">Ataque</div>
                <div class="v" style="color:#ff6666;">+{$active_bonuses.attack*100|number_format:2}%</div>
            </div>
            <div class="astrotalent_summary_card {if $active_bonuses.defense == 0}off{/if}">
                <div class="lbl">Defensa</div>
                <div class="v" style="color:#66aaff;">+{$active_bonuses.defense*100|number_format:2}%</div>
            </div>
            <div class="astrotalent_summary_card {if $active_bonuses.speed == 0}off{/if}">
                <div class="lbl">Velocidad</div>
                <div class="v" style="color:#ffcc44;">-{$active_bonuses.speed*100|number_format:2}%</div>
            </div>
        </div>

        <div class="astrotalent_summary_grid" style="margin-top:10px;">
            <div class="astrotalent_summary_card {if $active_bonuses.expedition == 0}off{/if}">
                <div class="lbl">Expedicion</div>
                <div class="v" style="color:#88ccff;">+{$active_bonuses.expedition*100|number_format:2}%</div>
            </div>
            <div class="astrotalent_summary_card {if $active_bonuses.research == 0}off{/if}">
                <div class="lbl">Investigacion</div>
                <div class="v" style="color:#cc88ff;">-{$active_bonuses.research*100|number_format:2}%</div>
            </div>
            <div class="astrotalent_summary_card {if $active_bonuses.build == 0}off{/if}">
                <div class="lbl">Construccion</div>
                <div class="v" style="color:#ffaa66;">-{$active_bonuses.build*100|number_format:2}%</div>
            </div>
            <div class="astrotalent_summary_card {if $active_bonuses.expedition_rewards == 0}off{/if}">
                <div class="lbl">Recompensas exp.</div>
                <div class="v" style="color:#ffdd44;">+{$active_bonuses.expedition_rewards*100|number_format:2}%</div>
            </div>
        </div>
    </div>

    {* ============ ARBOL DE TALENTOS ============ *}
    <div class="astrotalent_box">
        <div class="astrotalent_title">Elige 1 de 3 talentos por rango (7 rangos en total)</div>

        <div class="astrotalent_tree">
            {foreach from=$rank_data item=r}
                <div class="astrotalent_row">

                    {* Etiqueta lateral del rango *}
                    <div class="astrotalent_row_label">
                        <div class="rnum">R{$r.num}</div>
                        <div class="rlvl">Nv. {$r.level}</div>
                        <div class="rcost">{$r.cost_fmt} pts</div>
                    </div>

                    {* Las 3 opciones del rango *}
                    {foreach from=$r.options item=o}

                        <div class="astrotalent_card {if $o.selected}selected{elseif !$r.prev_chosen || $total_points < $r.cost}locked{elseif $r.can_choose && $total_points >= $r.cost}available{/if}">

                            {* Icono segun tipo *}
                            <div class="ico">
                                {if $o.type == 'production'}<span style="color:#66ff99;">[PROD]</span>{/if}
                                {if $o.type == 'attack'}<span style="color:#ff6666;">[ATK]</span>{/if}
                                {if $o.type == 'defense'}<span style="color:#66aaff;">[DEF]</span>{/if}
                                {if $o.type == 'speed'}<span style="color:#ffcc44;">[VEL]</span>{/if}
                                {if $o.type == 'expedition'}<span style="color:#88ccff;">[EXP]</span>{/if}
                                {if $o.type == 'research'}<span style="color:#cc88ff;">[INV]</span>{/if}
                                {if $o.type == 'build'}<span style="color:#ffaa66;">[CONS]</span>{/if}
                                {if $o.type == 'economy'}<span style="color:#fbbf24;">[ECO]</span>{/if}
                                {if $o.type == 'war'}<span style="color:#ef4444;">[WAR]</span>{/if}
                                {if $o.type == 'exploration'}<span style="color:#4aff88;">[EXPL]</span>{/if}
                            </div>

                            {* Nombre *}
                            <div class="nm">{$o.name}</div>

                            {* Efecto *}
                            <div class="ef">
                                {if $o.type == 'production'}Produccion <span class="v">+{$o.value*100}%</span>{/if}
                                {if $o.type == 'attack'}Ataque <span class="v">+{$o.value*100}%</span>{/if}
                                {if $o.type == 'defense'}Blindaje <span class="v">+{$o.value*100}%</span>{/if}
                                {if $o.type == 'speed'}Velocidad <span class="v">-{$o.value*100}%</span>{/if}
                                {if $o.type == 'expedition'}Expedicion <span class="v">+{$o.value*100}%</span>{/if}
                                {if $o.type == 'research'}Investigacion <span class="v">-{$o.value*100}%</span>{/if}
                                {if $o.type == 'build'}Construccion <span class="v">-{$o.value*100}%</span>{/if}
                                {if $o.type == 'economy'}
                                    <span style="color:#66ff99;">+25% Produccion</span><br>
                                    <span style="color:#cc88ff;">-20% Investigacion</span><br>
                                    <span style="color:#ffaa66;">-20% Construccion</span>
                                {/if}
                                {if $o.type == 'war'}
                                    <span style="color:#ff6666;">+25% Ataque</span><br>
                                    <span style="color:#66aaff;">+25% Blindaje</span>
                                {/if}
                                {if $o.type == 'exploration'}
                                    <span style="color:#88ccff;">+5% Expedicion</span><br>
                                    <span style="color:#ffcc44;">-10% Velocidad</span><br>
                                    <span style="color:#ffdd44;">+10% Recompensas</span>
                                {/if}
                            </div>

                            {* Boton o estado *}
                            {if $o.selected}
                                <div style="margin-top:6px;color:#66ff99;font-size:9px;font-weight:bold;">OK - ELEGIDO</div>
                            {elseif $is_leader && $r.can_choose && $total_points >= $r.cost}
                                <form method="post" action="game.php?page=allianceTalent&mode=doSetTalent">
                                    <input type="hidden" name="rank" value="{$r.num}">
                                    <input type="hidden" name="talent" value="{$o.key}">
                                    <button type="submit" class="astrotalent_btn">Elegir</button>
                                </form>
                            {elseif !$r.prev_chosen}
                                <div style="margin-top:6px;color:#5a6a7a;font-size:9px;">[X] Bloqueado</div>
                            {elseif $r.chosen && !$o.selected}
                                <div style="margin-top:6px;color:#5a6a7a;font-size:9px;">- No elegido -</div>
                            {elseif !$is_leader}
                                <div style="margin-top:6px;color:#94a3b8;font-size:9px;">Solo el lider</div>
                            {else}
                                <div style="margin-top:6px;color:#ff8888;font-size:9px;">Faltan {$r.cost_fmt} pts</div>
                            {/if}

                        </div>
                    {/foreach}

                </div>
            {/foreach}
        </div>
    </div>

    {* ============ RESET (solo lider) ============ *}
    {if $is_leader && $has_talents}
        <div class="astrotalent_box">
            <div class="astrotalent_title">Resetear talentos</div>
            <div class="astrotalent_reset">

                {* 🆕 v2.0 — Aviso con moneda dinámica *}
                <div style="color:#ff8888;font-size:10px;margin-bottom:10px;">
                    [!] Resetear TODOS los talentos cuesta
                    <b style="color:#ffcc44;">{$reset_cost_user_fmt} {$moneda}</b>
                    de tu cuenta personal.
                    <br>Se perderan todas las elecciones y volveras al rango 0.
                    <br><span style="color:#94a3b8;">
                        Tu saldo: {$saldo_actual|number_format:0:',,':'.'} {$moneda}
                    </span>
                </div>

                {* 🆕 v2.0 — Aviso si no alcanza *}
                {if !$can_afford_reset}
                    <div style="color:#ff4488;font-size:10px;margin-bottom:10px;font-weight:bold;">
                        ✗ No tienes suficiente {$moneda}.
                        Te faltan {$reset_cost_user - $saldo_actual|number_format:0:',,':'.'} {$moneda}.
                    </div>
                {/if}

                <form method="post" action="game.php?page=allianceTalent&mode=doReset" onsubmit="return confirm('¿Seguro que quieres resetear todos los talentos? Se perderan las elecciones.');">
                    {* 🆕 v2.0 — Botón deshabilitado si no alcanza *}
                    <button type="submit" class="astrotalent_btn astrotalent_btn_danger"
                        {if !$can_afford_reset}disabled title="Saldo insuficiente"{/if}>
                        Resetear talentos ({$reset_cost_user_fmt} {$moneda})
                    </button>
                </form>

            </div>
        </div>
    {/if}

    {* ============ HISTORIAL ============ *}
    <div class="astrotalent_box">
        <div class="astrotalent_title">Historial (ultimos 50 movimientos)</div>

        {if $history && $history|@count > 0}
            <table class="astrotalent_table">
                <thead>
                    <tr>
                        <th>Fecha</th>
                        <th>Jugador</th>
                        <th>Accion</th>
                        <th>Puntos</th>
                        <th>Detalle</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$history item=h}
                        <tr>
                            <td>{$h.log_time|date_format:"%d/%m/%Y %H:%M"}</td>
                            <td>{$h.username|default:'-'}</td>
                            <td><span class="tag {$h.action}">{$h.action}</span></td>
                            <td style="font-family:'Courier New',monospace;">{$h.points}</td>
                            <td style="font-size:10px;color:#94a3b8;">{$h.detail|default:'-'}</td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {else}
            <div style="color:#94a3b8;text-align:center;padding:20px;">
                No hay movimientos todavia.
            </div>
        {/if}
    </div>

</div>
</div>

{/block}