{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pve.acsSetup.tpl === *}
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
   PvE — Crear Ataque ACS
   AstroIO v4.0 — Glassmorphism + Acento Cyan + Dual-Riel
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

.astropve_wrap {
    padding: 20px;
    color: var(--text-main);
}

.astropve_title {
    color: #dd99ff;
    text-align: center;
    font-size: 24px;
    margin-bottom: 10px;
    text-shadow: 0 0 14px rgba(139, 92, 246, 0.6);
    letter-spacing: 1px;
}

.astropve_subtitle {
    text-align: center;
    color: var(--text-muted);
    margin-bottom: 30px;
    font-size: 12px;
    line-height: 1.8;
}
.astropve_subtitle .warn { color: #ffdd88; }

/* ─── v4.0 — BADGE DE SALDO ────────────────────────────── */
.astropve_balance_bar {
    max-width: 900px;
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
.astropve_balance_badge:hover { transform: translateY(-1px); }

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
    display: inline-block;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropve_tab:hover {
    transform: translateY(-2px);
}

.astropve_tab.main {
    background: rgba(139, 92, 246, 0.15);
    color: #dd99ff;
    border: 1px solid rgba(139, 92, 246, 0.5);
}
.astropve_tab.main:hover {
    background: rgba(139, 92, 246, 0.25);
    box-shadow: 0 0 14px rgba(139, 92, 246, 0.4);
}

.astropve_tab.empire {
    background: linear-gradient(135deg, #cc5500, #ff8822);
    color: #fff;
    border: 1px solid #ff8822;
    box-shadow: 0 4px 14px rgba(255, 136, 34, 0.5);
}
.astropve_tab.empire:hover {
    box-shadow: 0 6px 20px rgba(255, 136, 34, 0.7);
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

/* ─── CARD OBJETIVO ────────────────────────────────────── */
.astropve_target {
    max-width: 900px;
    margin: 0 auto 25px;
    padding: 18px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(251, 191, 36, 0.5);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astropve_target_row {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    flex-wrap: wrap;
    gap: 12px;
}
.astropve_target_label {
    font-size: 10px;
    color: var(--text-muted);
    letter-spacing: 1px;
    text-transform: uppercase;
    margin-bottom: 4px;
}
.astropve_target_name {
    font-size: 18px;
    font-weight: bold;
    color: #ffdd88;
    margin-bottom: 4px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}
.astropve_target_coords {
    font-size: 11px;
    color: #aabbcc;
}
.astropve_target_coords .faction {
    color: #ffaa66;
    font-weight: bold;
}
.astropve_target_id {
    text-align: right;
}
.astropve_target_id_val {
    font-size: 14px;
    font-weight: bold;
    color: #88ddff;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}

/* ─── SECCIONES DEL FORM ──────────────────────────────── */
.astropve_section {
    max-width: 900px;
    margin: 0 auto 20px;
    padding: 18px;
    border-radius: 12px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}
.astropve_section.visibility {
    background: rgba(0, 200, 255, 0.05);
    border: 1px solid rgba(0, 200, 255, 0.35);
}
.astropve_section.ally {
    background: rgba(251, 191, 36, 0.05);
    border: 1px solid rgba(251, 191, 36, 0.35);
}
.astropve_section.invite {
    background: rgba(204, 136, 255, 0.05);
    border: 1px solid rgba(204, 136, 255, 0.35);
}
.astropve_section.deadline {
    background: rgba(0, 200, 100, 0.05);
    border: 1px solid rgba(0, 200, 100, 0.35);
}

.astropve_section_title {
    font-size: 15px;
    margin-bottom: 15px;
    text-shadow: 0 0 8px rgba(0, 0, 0, 0.4);
}
.astropve_section.visibility .astropve_section_title { color: #88ddff; }
.astropve_section.ally .astropve_section_title       { color: #ffdd88; }
.astropve_section.invite .astropve_section_title     { color: #cc88ff; }
.astropve_section.deadline .astropve_section_title   { color: #88ffbb; }

.astropve_section_desc {
    font-size: 11px;
    color: var(--text-muted);
    margin-bottom: 15px;
    line-height: 1.6;
}

/* ─── OPCIONES DE VISIBILIDAD ─────────────────────────── */
.astropve_options {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.astropve_option {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 14px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.25s ease;
}
.astropve_option input[type="radio"] {
    margin-top: 3px;
    cursor: pointer;
    accent-color: var(--accent-cyan);
}
.astropve_option.public { border: 2px solid rgba(74, 255, 136, 0.3); }
.astropve_option.public:hover {
    border-color: rgba(74, 255, 136, 0.7);
    transform: translateY(-2px);
    box-shadow: 0 4px 14px rgba(74, 255, 136, 0.2);
}
.astropve_option.ally { border: 2px solid rgba(251, 191, 36, 0.3); }
.astropve_option.ally:hover {
    border-color: rgba(251, 191, 36, 0.7);
    transform: translateY(-2px);
    box-shadow: 0 4px 14px rgba(251, 191, 36, 0.2);
}
.astropve_option.invite { border: 2px solid rgba(204, 136, 255, 0.3); }
.astropve_option.invite:hover {
    border-color: rgba(204, 136, 255, 0.7);
    transform: translateY(-2px);
    box-shadow: 0 4px 14px rgba(204, 136, 255, 0.2);
}

.astropve_option_content { flex: 1; }
.astropve_option_name {
    font-size: 14px;
    font-weight: bold;
    margin-bottom: 4px;
}
.astropve_option.public .astropve_option_name { color: #88ffbb; }
.astropve_option.ally .astropve_option_name   { color: #ffdd88; }
.astropve_option.invite .astropve_option_name { color: #cc88ff; }

.astropve_option_desc {
    font-size: 11px;
    color: #aabbcc;
    line-height: 1.6;
}
.astropve_option_desc b { color: var(--text-muted); }

/* ─── SELECT ───────────────────────────────────────────── */
.astropve_label {
    font-size: 12px;
    color: #aabbcc;
    display: block;
    margin-bottom: 8px;
}
.astropve_select {
    width: 100%;
    padding: 10px;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    color: #fff;
    border-radius: 6px;
    font-size: 13px;
    font-family: inherit;
    transition: 0.25s ease;
    box-sizing: border-box;
}
.astropve_select:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
    transform: translateY(-1px);
}
.astropve_section.ally .astropve_select {
    border-color: rgba(251, 191, 36, 0.5);
}
.astropve_section.ally .astropve_select:focus {
    border-color: var(--accent-gold);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}
.astropve_section.deadline .astropve_select {
    border-color: rgba(74, 255, 136, 0.5);
}
.astropve_section.deadline .astropve_select:focus {
    border-color: var(--accent-green);
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.4);
}
.astropve_select option,
.astropve_select optgroup {
    background: #0f1624;
    color: #fff;
}

/* ─── INPUT SEARCH ─────────────────────────────────────── */
.astropve_input {
    width: 100%;
    padding: 10px;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    color: #fff;
    border-radius: 6px;
    font-size: 13px;
    font-family: inherit;
    margin-bottom: 12px;
    box-sizing: border-box;
    transition: 0.25s ease;
}
.astropve_input:focus {
    outline: none;
    border-color: var(--accent-purple);
    box-shadow: 0 0 14px rgba(139, 92, 246, 0.4);
    transform: translateY(-1px);
}
.astropve_input::placeholder {
    color: #667788;
    font-style: italic;
}

/* ─── LISTA DE USUARIOS ────────────────────────────────── */
.astropve_users_list {
    max-height: 300px;
    overflow-y: auto;
    padding: 4px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
}
.astropve_user_row {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 12px;
    font-size: 12px;
    color: #aabbcc;
    border-bottom: 1px solid rgba(204, 136, 255, 0.1);
    cursor: pointer;
    transition: background 0.2s ease;
}
.astropve_user_row:last-child {
    border-bottom: none;
}
.astropve_user_row:hover {
    background: rgba(204, 136, 255, 0.08);
}
.astropve_user_row input[type="checkbox"] {
    cursor: pointer;
    width: 16px;
    height: 16px;
    accent-color: var(--accent-purple);
}
.astropve_user_name {
    flex: 1;
    color: var(--text-main);
    font-weight: 600;
}
.astropve_user_points {
    font-size: 10px;
    color: var(--text-muted);
    font-family: 'Courier New', monospace;
}

/* ─── HINT ─────────────────────────────────────────────── */
.astropve_hint {
    font-size: 10px;
    color: var(--text-muted);
    margin-top: 8px;
    line-height: 1.5;
}

/* ─── BOTONES ──────────────────────────────────────────── */
.astropve_actions {
    display: flex;
    gap: 12px;
    justify-content: center;
    flex-wrap: wrap;
    margin-top: 25px;
}

.astropve_btn {
    padding: 12px 32px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    display: inline-block;
    text-align: center;
}

.astropve_btn.cancel {
    background: rgba(148, 163, 184, 0.2);
    color: #aabbcc;
    border: 1px solid rgba(148, 163, 184, 0.5);
}
.astropve_btn.cancel:hover {
    background: rgba(148, 163, 184, 0.35);
    color: #fff;
    transform: translateY(-2px);
    box-shadow: 0 0 14px rgba(148, 163, 184, 0.3);
}

.astropve_btn.submit {
    padding: 12px 40px;
    background: linear-gradient(135deg, #0066cc, #00aaff);
    color: #fff;
    border: 1px solid var(--accent-cyan);
    box-shadow: 0 4px 14px rgba(0, 170, 255, 0.5);
    font-size: 14px;
}
.astropve_btn.submit:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 170, 255, 0.7);
    background: linear-gradient(135deg, #0099ff, #00ccff);
}

/* ─── INFO BOX ─────────────────────────────────────────── */
.astropve_info {
    max-width: 900px;
    margin: 30px auto 0;
    padding: 15px 20px;
    background: rgba(0, 224, 255, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.25);
    border-radius: 10px;
}
.astropve_info_title {
    font-size: 12px;
    color: #88ddff;
    font-weight: bold;
    margin-bottom: 8px;
}
.astropve_info_body {
    font-size: 11px;
    color: #aabbcc;
    line-height: 1.8;
}
.astropve_info_body b { color: #88ddff; }

.astropve_footer {
    text-align: center;
    font-size: 11px;
    color: var(--text-muted);
    margin-top: 30px;
}

/* ─── RESPONSIVE ───────────────────────────────────────── */
@media (max-width: 720px) {
    /* Wrap padding global */
    .astropve_wrap { padding: 12px; }

    /* Tabs → grid 2×N + huérfano full-width */
    .astropve_tabs {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 10px !important;
        margin-bottom: 15px !important;
    }
    .astropve_tab {
        min-width: 0 !important;
        max-width: 100% !important;
        width: 100% !important;
        padding: 8px 4px !important;
        font-size: 10px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
    }
    .astropve_tab:last-child:nth-child(odd) {
        grid-column: 1 / -1 !important;
    }

    /* Balance badge */
    .astropve_balance_bar { flex-direction: column !important; gap: 8px; }
    .astropve_balance_badge {
        width: 100% !important;
        max-width: 100% !important;
        padding: 11px 10px !important;
        justify-content: center !important;
        box-sizing: border-box !important;
    }

    /* Card del imperio objetivo */
    .astropve_target_row { flex-direction: column !important; }
    .astropve_target_id { text-align: left !important; }

    /* Opciones de visibilidad */
    .astropve_option { padding: 12px 10px !important; gap: 10px !important; }

    /* Botones de acción → apilados full-width */
    .astropve_actions { flex-direction: column !important; gap: 10px !important; }
    .astropve_btn,
    .astropve_btn.submit {
        width: 100% !important;
        box-sizing: border-box !important;
        padding: 14px 16px !important;
    }
}
</style>

<div class="astropve_wrap">
    <h1 class="astropve_title">🤝 CREAR ATAQUE ACS</h1>

    {* ─── v4.0 — BADGE DE SALDO ─── *}
    {if isset($moneda) && isset($saldo_actual)}
        <div class="astropve_balance_bar">
            <div class="astropve_balance_badge {if $es_internacional}qvapay{else}cup{/if}">
                <span class="astropve_balance_label">💰 Saldo:</span>
                <span class="astropve_balance_value">{$saldo_actual|number_format}</span>
                <span class="astropve_balance_currency">{$moneda}</span>
            </div>
        </div>
    {/if}

    <p class="astropve_subtitle">
        Configura las opciones del ACS antes de seleccionar tus naves.<br>
        <b class="warn">Después serás redirigido al sistema nativo de flotas para enviar tu ataque.</b>
    </p>

    {* ═══════════════════════════════════════════════════════════
     * MENÚ PESTAÑAS
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_tabs">
        <a href="game.php?page=pve" class="astropve_tab main">
            🏠 Panel Principal
        </a>
        <a href="game.php?page=pve&mode=empire" class="astropve_tab empire">
            🏛️ Imperio Caído
        </a>
        <a href="game.php?page=pve&mode=boss" class="astropve_tab boss">
            🌌 Torneo del Devorador
        </a>
        <a href="game.php?page=pve&mode=bastion" class="astropve_tab bastion">
            ⚓ Bastión Asediado
        </a>
        <a href="game.php?page=pve&mode=achievements" class="astropve_tab achievements">
            🏆 Logros
        </a>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * CARD DEL IMPERIO OBJETIVO
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_target">
        <div class="astropve_target_row">
            <div>
                <div class="astropve_target_label">🎯 Objetivo del Ataque ACS</div>
                <div class="astropve_target_name">🏛️ {$empire.name}</div>
                <div class="astropve_target_coords">
                    📍 [{$empire.galaxy}:{$empire.system}:{$empire.planet}] • Facción: <b class="faction">{$empire.faction_name}</b>
                </div>
            </div>
            <div class="astropve_target_id">
                <div class="astropve_target_label">ID del imperio</div>
                <div class="astropve_target_id_val">#{$empire.id}</div>
            </div>
        </div>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * FORMULARIO DE CONFIGURACIÓN ACS
     * ═══════════════════════════════════════════════════════════ *}
    <form method="POST" action="game.php?page=pve&mode=createAcsPve" id="acs_setup_form">

        <input type="hidden" name="empire_id" value="{$empire.id}">

        {* ─── TIPO DE VISIBILIDAD ─── *}
        <div class="astropve_section visibility">
            <h2 class="astropve_section_title">🌐 Visibilidad del ACS</h2>
            <p class="astropve_section_desc">Elige quién puede unirse a tu ataque:</p>

            <div class="astropve_options">

                {* Opción PÚBLICO *}
                <label class="astropve_option public">
                    <input type="radio" name="acs_visibility" value="public" id="vis_public" checked
                           onchange="astroioToggleAcsOptions('public');">
                    <div class="astropve_option_content">
                        <div class="astropve_option_name">🌍 Público</div>
                        <div class="astropve_option_desc">
                            Cualquier jugador puede ver y unirse a tu ACS.<br>
                            <b>Ideal para ataques masivos sin coordinación previa.</b>
                        </div>
                    </div>
                </label>

                {* Opción ALIANZA *}
                <label class="astropve_option ally">
                    <input type="radio" name="acs_visibility" value="ally" id="vis_ally"
                           onchange="astroioToggleAcsOptions('ally');">
                    <div class="astropve_option_content">
                        <div class="astropve_option_name">🏰 Alianza</div>
                        <div class="astropve_option_desc">
                            Todos los miembros de la alianza seleccionada recibirán una invitación interna.<br>
                            <b>Solo ellos podrán unirse al ACS.</b>
                        </div>
                    </div>
                </label>

                {* Opción INVITADOS *}
                <label class="astropve_option invite">
                    <input type="radio" name="acs_visibility" value="invite" id="vis_invite"
                           onchange="astroioToggleAcsOptions('invite');">
                    <div class="astropve_option_content">
                        <div class="astropve_option_name">👥 Invitados</div>
                        <div class="astropve_option_desc">
                            Elige manualmente qué jugadores recibirán la invitación.<br>
                            <b>Solo ellos podrán unirse al ACS.</b>
                        </div>
                    </div>
                </label>

            </div>
        </div>

        {* ─── OPCIÓN ALIANZA (solo si visibility=ally) ─── *}
        <div id="acs_ally_box" class="astropve_section ally" style="display: none;">
            <h2 class="astropve_section_title">🏰 Seleccionar alianza</h2>

            <label class="astropve_label">Elige la alianza que quieres invitar:</label>

            <select name="acs_ally_id" id="acs_ally_id" class="astropve_select">
                <option value="0">— Selecciona una alianza —</option>
                {if $myAllyId > 0}
                    <optgroup label="⭐ Tu alianza">
                        <option value="{$myAllyId}">[{$myAllyTag}] {$myAllyName} (automática)</option>
                    </optgroup>
                {/if}
                <optgroup label="Otras alianzas">
                    {foreach $allAlliances as $ally}
                        {if $ally.id != $myAllyId}
                            <option value="{$ally.id}">[{$ally.tag}] {$ally.name} — {$ally.members} miembros</option>
                        {/if}
                    {/foreach}
                </optgroup>
            </select>

            <div class="astropve_hint">
                ℹ️ Todos los miembros de la alianza seleccionada recibirán una invitación interna. Solo ellos podrán unirse al ACS.
            </div>
        </div>

        {* ─── OPCIÓN INVITADOS (solo si visibility=invite) ─── *}
        <div id="acs_invite_box" class="astropve_section invite" style="display: none;">
            <h2 class="astropve_section_title">👥 Seleccionar jugadores</h2>

            <label class="astropve_label">Busca y marca los jugadores a invitar:</label>

            <input type="text" id="acs_user_search"
                   placeholder="🔍 Escribe un nombre para filtrar..."
                   onkeyup="astroioFilterUsers();"
                   class="astropve_input">

            <div id="acs_users_list" class="astropve_users_list">
                {foreach $allUsers as $usr}
                    <label class="astropve_user_row acs-user-row" data-name="{$usr.name|lower}">
                        <input type="checkbox" name="acs_users[]" value="{$usr.id}">
                        <span class="astropve_user_name">{$usr.name}</span>
                        <span class="astropve_user_points">
                            {$usr.points|number_format} pts
                        </span>
                    </label>
                {/foreach}
            </div>

            <div class="astropve_hint">
                ℹ️ Solo los jugadores marcados recibirán la invitación privada al ACS.
            </div>
        </div>

        {* ─── DEADLINE ─── *}
        <div class="astropve_section deadline">
            <h2 class="astropve_section_title">⏱️ Tiempo límite para unirse</h2>

            <p class="astropve_section_desc">
                Después de este tiempo, nadie más podrá unirse al ACS.
            </p>

            <select name="acs_deadline_minutes" class="astropve_select">
                <option value="15">⚡ 15 minutos</option>
                <option value="30">⏱️ 30 minutos</option>
                <option value="60" selected>🕐 1 hora</option>
                <option value="120">🕑 2 horas</option>
                <option value="360">🕕 6 horas</option>
                <option value="720">🕛 12 horas</option>
            </select>
        </div>

        {* ─── BOTONES ─── *}
        <div class="astropve_actions">
            <a href="game.php?page=pve&mode=empire" class="astropve_btn cancel">
                ❌ Cancelar
            </a>

            <button type="submit"
                    onclick="return astroioConfirmAcs();"
                    class="astropve_btn submit">
                🚀 Crear ACS y continuar
            </button>
        </div>

    </form>

    {* ═══════════════════════════════════════════════════════════
     * INFORMACIÓN
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_info">
        <div class="astropve_info_title">💡 ¿Qué pasa después?</div>
        <div class="astropve_info_body">
            1. Se creará el ACS con la visibilidad que hayas elegido.<br>
            2. Serás redirigido a la <b>pantalla nativa de flotas de XNova</b>.<br>
            3. Allí elegirás tus naves, velocidad y confirmarás el ataque.<br>
            4. Los invitados recibirán un mensaje interno con el enlace para unirse.<br>
            5. Cuando llegue la última flota, se resolverá el combate.
        </div>
    </div>

    <p class="astropve_footer">
        🚧 Módulo ACS — AstroIO v4.0 · Dual-Riel NTX-20 / UNTX-20
    </p>
</div>

{* ═══════════════════════════════════════════════════════════
 * JAVASCRIPT
 * ═══════════════════════════════════════════════════════════ *}
{literal}
<script type="text/javascript">
// Toggle entre opciones de visibilidad (public/ally/invite)
function astroioToggleAcsOptions(type) {
    var allyBox   = document.getElementById('acs_ally_box');
    var inviteBox = document.getElementById('acs_invite_box');

    if (allyBox)   allyBox.style.display   = (type === 'ally')   ? 'block' : 'none';
    if (inviteBox) inviteBox.style.display = (type === 'invite') ? 'block' : 'none';
}

// Filtrar usuarios por nombre
function astroioFilterUsers() {
    var searchInput = document.getElementById('acs_user_search');
    if (!searchInput) return;

    var query = searchInput.value.toLowerCase().trim();
    var rows  = document.querySelectorAll('.acs-user-row');

    for (var i = 0; i < rows.length; i++) {
        var name = rows[i].getAttribute('data-name') || '';
        rows[i].style.display = (name.indexOf(query) !== -1) ? 'flex' : 'none';
    }
}

// Confirmar antes de crear el ACS
function astroioConfirmAcs() {
    // Detectar qué visibility está seleccionada
    var visibility = 'public';
    if (document.getElementById('vis_ally')   && document.getElementById('vis_ally').checked)   visibility = 'ally';
    if (document.getElementById('vis_invite') && document.getElementById('vis_invite').checked) visibility = 'invite';

    // Validar según el tipo
    if (visibility === 'ally') {
        var allySelect = document.getElementById('acs_ally_id');
        if (allySelect && parseInt(allySelect.value || '0') <= 0) {
            alert('❌ Debes seleccionar una alianza para invitar.');
            return false;
        }
    }

    if (visibility === 'invite') {
        var checkboxes = document.querySelectorAll('input[name="acs_users[]"]:checked');
        if (checkboxes.length <= 0) {
            alert('❌ Debes seleccionar al menos 1 jugador para invitar.');
            return false;
        }
    }

    // Confirmar
    var msg = '🤝 ¿Crear el ACS con visibilidad "';
    if (visibility === 'public') msg += 'Público';
    if (visibility === 'ally')   msg += 'Alianza';
    if (visibility === 'invite') msg += 'Invitados';
    msg += '"?\n\nDespués serás redirigido a la pantalla de selección de naves.';

    return confirm(msg);
}

// Auto-ejecutar: si la página carga con visibility=ally o invite ya marcada (por si se recarga)
(function() {
    var allyRadio   = document.getElementById('vis_ally');
    var inviteRadio = document.getElementById('vis_invite');

    if (allyRadio && allyRadio.checked)     astroioToggleAcsOptions('ally');
    if (inviteRadio && inviteRadio.checked) astroioToggleAcsOptions('invite');
})();
</script>
{/literal}

{/block}