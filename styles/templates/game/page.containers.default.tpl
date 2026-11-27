{extends file="layout.full.tpl"}

{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.containers.default.tpl === *}
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

{* AstroIO - Página de Contenedores v5.0 *}

<style>
/* ═══════════════════════════════════════════════════════════
   CONTENEDORES — AstroIO v5.0
   v4.0 (2026-11-02):
     - Nuevo sistema de drops por producción/hora
     - Stat "Bonus Minas" → reemplazado por "Tope drop"
     - Probabilidades actualizadas (52.00 / 24.80 / 16.23 / 6.98)
     - Nota informativa del sistema de drops
     - .cn_info_box añadido para explicar el sistema
   v5.0 (2026-11-08):
     - BUFF CLIMÁTICO: banner "Buff Activo" con cuenta atrás en vivo (JS)
     - 3 cofres climáticos (Menor / Mayor / Dominio)
     - POST activate_climate_minor / _major / _dominion
     - Timer JS: se actualiza cada segundo, recarga al llegar a 0
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

.cn_wrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 20px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
}
.cn_title {
    font-size: 26px;
    color: var(--accent-gold);
    text-shadow: 0 0 12px rgba(251, 191, 36, 0.6);
    margin-bottom: 6px;
    letter-spacing: 1px;
}
.cn_subtitle {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 20px;
}

/* ===== BUFF ACTIVO (v5.0) ===== */
.cn_buff_banner {
    background: linear-gradient(135deg, rgba(20, 40, 60, 0.9), rgba(10, 25, 45, 0.9));
    border: 2px solid var(--accent-cyan);
    border-radius: 14px;
    padding: 18px 22px;
    margin-bottom: 24px;
    box-shadow: 0 0 30px rgba(0, 224, 255, 0.35), 0 4px 20px rgba(0, 0, 0, 0.4);
    display: flex;
    align-items: center;
    gap: 18px;
    position: relative;
    overflow: hidden;
}
.cn_buff_banner::before {
    content: '';
    position: absolute;
    top: 0; left: -100%;
    width: 100%; height: 100%;
    background: linear-gradient(90deg, transparent, rgba(0, 224, 255, 0.08), transparent);
    animation: buffShine 4s ease-in-out infinite;
}
@keyframes buffShine {
    0%   { left: -100%; }
    50%  { left: 100%; }
    100% { left: 100%; }
}
.cn_buff_icon {
    font-size: 52px;
    line-height: 1;
    filter: drop-shadow(0 0 15px rgba(0, 224, 255, 0.7));
    flex-shrink: 0;
}
.cn_buff_info {
    flex: 1;
    text-align: left;
}
.cn_buff_title {
    font-size: 12px;
    color: var(--accent-cyan);
    text-transform: uppercase;
    letter-spacing: 2px;
    font-weight: 700;
    margin-bottom: 4px;
}
.cn_buff_name {
    font-size: 20px;
    color: var(--text-title);
    font-weight: 700;
    letter-spacing: 1px;
    margin-bottom: 4px;
}
.cn_buff_desc {
    font-size: 12px;
    color: var(--text-muted);
    line-height: 1.4;
}
.cn_buff_timer {
    text-align: right;
    min-width: 140px;
    flex-shrink: 0;
}
.cn_buff_timer_label {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1.5px;
    margin-bottom: 4px;
}
.cn_buff_timer_value {
    font-size: 24px;
    color: var(--accent-green);
    font-weight: 700;
    font-family: 'Courier New', monospace;
    letter-spacing: 1px;
    text-shadow: 0 0 12px rgba(74, 255, 136, 0.5);
}
.cn_buff_timer_value.urgent {
    color: var(--accent-red);
    text-shadow: 0 0 12px rgba(239, 68, 68, 0.6);
    animation: timerPulse 1s ease-in-out infinite;
}
@keyframes timerPulse {
    0%, 100% { opacity: 1; }
    50%      { opacity: 0.6; }
}

/* ===== ESTADÍSTICAS ===== */
.cn_stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-bottom: 24px;
}
.cn_stat {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 16px;
    text-align: center;
    transition: all 0.25s ease;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.cn_stat:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.35), 0 4px 20px rgba(0, 0, 0, 0.35);
    transform: translateY(-2px);
}
.cn_stat .stat_icon {
    font-size: 28px;
    margin-bottom: 6px;
    display: block;
    line-height: 1;
}
.cn_stat .stat_value {
    font-size: 26px;
    font-weight: 700;
    color: var(--accent-cyan);
    font-family: 'Courier New', monospace;
    letter-spacing: 1px;
    margin-bottom: 4px;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}
.cn_stat .stat_label {
    font-size: 11px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
}
.cn_stat.boxes .stat_value { color: var(--accent-gold); text-shadow: 0 0 10px rgba(251, 191, 36, 0.4); }
.cn_stat.opened .stat_value { color: var(--accent-green); text-shadow: 0 0 10px rgba(74, 255, 136, 0.4); }
.cn_stat.ntx .stat_value { color: var(--accent-green); text-shadow: 0 0 10px rgba(74, 255, 136, 0.4); }
.cn_stat.drop .stat_value { color: var(--accent-purple); text-shadow: 0 0 10px rgba(139, 92, 246, 0.4); }

/* ===== MENSAJES ===== */
.cn_msg {
    padding: 14px 18px;
    border-radius: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    border-left: 4px solid;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.cn_msg.success { background: rgba(74, 255, 136, 0.12); border-color: var(--accent-green); color: var(--accent-green); }
.cn_msg.error   { background: rgba(239, 68, 68, 0.12); border-color: var(--accent-red); color: var(--accent-red); }
.cn_msg.info    { background: rgba(0, 224, 255, 0.10); border-color: var(--accent-cyan); color: var(--accent-cyan); }

/* ===== INFO BOX — Explica el sistema ===== */
.cn_info_box {
    background: rgba(0, 224, 255, 0.06);
    border: 1px solid rgba(0, 224, 255, 0.25);
    border-left: 4px solid var(--accent-cyan);
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 20px;
    font-size: 12px;
    color: var(--text-main);
    line-height: 1.6;
}
.cn_info_box strong { color: var(--accent-cyan); }
.cn_info_box .info_title {
    font-size: 13px;
    color: var(--accent-cyan);
    font-weight: 700;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
    display: block;
}

/* ===== REWARD MOSTRADA ===== */
.cn_reward {
    background: linear-gradient(135deg, rgba(26, 10, 46, 0.85), rgba(42, 16, 80, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid var(--accent-purple);
    border-radius: 14px;
    padding: 24px;
    text-align: center;
    margin-bottom: 24px;
    box-shadow: 0 0 40px rgba(139, 92, 246, 0.5), 0 4px 20px rgba(0, 0, 0, 0.4);
    animation: rewardPop 0.6s ease;
}
@keyframes rewardPop {
    0%   { transform: scale(0.7); opacity: 0; }
    60%  { transform: scale(1.05); opacity: 1; }
    100% { transform: scale(1); opacity: 1; }
}
.cn_reward .rw_title {
    font-size: 14px;
    color: var(--accent-purple);
    text-transform: uppercase;
    letter-spacing: 2px;
    margin-bottom: 8px;
    font-weight: 700;
}
.cn_reward .rw_icon {
    font-size: 64px;
    margin: 10px 0;
    display: block;
    filter: drop-shadow(0 0 20px rgba(0, 224, 255, 0.7));
    line-height: 1;
}
.cn_reward .rw_name {
    font-size: 22px;
    color: var(--text-title);
    font-weight: 700;
    letter-spacing: 1px;
    margin-bottom: 4px;
    text-shadow: 0 0 10px rgba(255, 255, 255, 0.3);
}
.cn_reward .rw_value {
    font-size: 18px;
    color: var(--accent-green);
    font-family: 'Courier New', monospace;
    font-weight: 700;
    letter-spacing: 1px;
    text-shadow: 0 0 10px rgba(74, 255, 136, 0.4);
}
.cn_reward .rw_rarity {
    display: inline-block;
    margin-top: 10px;
    padding: 3px 12px;
    border-radius: 6px;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-weight: 700;
}
.rw_rarity.common    { background: rgba(150, 150, 150, 0.2); color: #cccccc; border: 1px solid #999; }
.rw_rarity.rare      { background: rgba(59, 130, 246, 0.15); color: #66bbff; border: 1px solid var(--accent-blue); }
.rw_rarity.epic      { background: rgba(139, 92, 246, 0.15); color: #cc88ff; border: 1px solid var(--accent-purple); }
.rw_rarity.mythic    { background: rgba(255, 102, 0, 0.15);  color: #ffaa66; border: 1px solid #ff6600; }

/* ===== GRID DE 4 CAJAS ===== */
.cn_boxes_grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    margin-bottom: 24px;
}
.cn_box_container {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(251, 191, 36, 0.3);
    border-radius: 16px;
    padding: 24px 20px;
    text-align: center;
    transition: all 0.3s ease;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
    display: flex;
    flex-direction: column;
    align-items: center;
}
.cn_box_container:hover {
    border-color: var(--accent-gold);
    box-shadow: 0 0 30px rgba(251, 191, 36, 0.35), 0 4px 20px rgba(0, 0, 0, 0.4);
}
.cn_box_container.type-generic { border-color: rgba(0, 224, 255, 0.35); }
.cn_box_container.type-generic:hover { border-color: var(--accent-cyan); box-shadow: 0 0 30px rgba(0, 224, 255, 0.4), 0 4px 20px rgba(0, 0, 0, 0.4); }
.cn_box_container.type-generic .cn_box_title { color: var(--accent-cyan); }
.cn_box_container.type-common { border-color: rgba(0, 224, 255, 0.35); }
.cn_box_container.type-common:hover { border-color: var(--accent-cyan); box-shadow: 0 0 30px rgba(0, 224, 255, 0.4), 0 4px 20px rgba(0, 0, 0, 0.4); }
.cn_box_container.type-common .cn_box_title { color: var(--accent-cyan); }
.cn_box_container.type-rare { border-color: rgba(139, 92, 246, 0.35); }
.cn_box_container.type-rare:hover { border-color: var(--accent-purple); box-shadow: 0 0 30px rgba(139, 92, 246, 0.5), 0 4px 20px rgba(0, 0, 0, 0.4); }
.cn_box_container.type-rare .cn_box_title { color: #cc88ff; }
.cn_box_container.type-legendary { border-color: rgba(251, 191, 36, 0.5); }
.cn_box_container.type-legendary:hover { border-color: var(--accent-gold); box-shadow: 0 0 30px rgba(251, 191, 36, 0.6), 0 4px 20px rgba(0, 0, 0, 0.4); }
.cn_box_container.type-legendary .cn_box_title { color: var(--accent-gold); }

/* ===== v5.0 — 3 CAJAS CLIMÁTICAS ===== */
.cn_climate_section_title {
    font-size: 16px;
    color: var(--accent-cyan);
    text-transform: uppercase;
    letter-spacing: 2px;
    margin: 8px 0 14px 0;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
    display: flex;
    align-items: center;
    gap: 10px;
}
.cn_climate_section_title::after {
    content: '';
    flex: 1;
    height: 1px;
    background: linear-gradient(90deg, var(--accent-cyan), transparent);
}
.cn_climate_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
    margin-bottom: 24px;
}
.cn_climate_container {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(148, 163, 184, 0.3);
    border-radius: 14px;
    padding: 20px 14px;
    text-align: center;
    transition: all 0.3s ease;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
    display: flex;
    flex-direction: column;
    align-items: center;
}
.cn_climate_container.type-minor {
    border-color: rgba(74, 255, 136, 0.35);
}
.cn_climate_container.type-minor:hover {
    border-color: var(--accent-green);
    box-shadow: 0 0 30px rgba(74, 255, 136, 0.35), 0 4px 20px rgba(0, 0, 0, 0.4);
}
.cn_climate_container.type-minor .cn_box_title { color: var(--accent-green); }
.cn_climate_container.type-minor .cn_climate_btn {
    background: linear-gradient(135deg, #1a6633 0%, #4aff88 100%);
    color: #001a08;
    border-color: var(--accent-green);
}
.cn_climate_container.type-minor .cn_climate_btn:hover:not(:disabled) {
    background: linear-gradient(135deg, #4aff88 0%, #88ffbb 100%);
    box-shadow: 0 0 25px rgba(74, 255, 136, 0.7);
}
.cn_climate_container.type-major {
    border-color: rgba(0, 224, 255, 0.35);
}
.cn_climate_container.type-major:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 30px rgba(0, 224, 255, 0.4), 0 4px 20px rgba(0, 0, 0, 0.4);
}
.cn_climate_container.type-major .cn_box_title { color: var(--accent-cyan); }
.cn_climate_container.type-major .cn_climate_btn {
    background: linear-gradient(135deg, #0066cc 0%, #00e0ff 100%);
    color: #001a22;
    border-color: var(--accent-cyan);
}
.cn_climate_container.type-major .cn_climate_btn:hover:not(:disabled) {
    background: linear-gradient(135deg, #00e0ff 0%, #66ffff 100%);
    box-shadow: 0 0 25px rgba(0, 224, 255, 0.7);
}
.cn_climate_container.type-dominion {
    border-color: rgba(139, 92, 246, 0.4);
}
.cn_climate_container.type-dominion:hover {
    border-color: var(--accent-purple);
    box-shadow: 0 0 30px rgba(139, 92, 246, 0.5), 0 4px 20px rgba(0, 0, 0, 0.4);
}
.cn_climate_container.type-dominion .cn_box_title { color: #cc88ff; }
.cn_climate_container.type-dominion .cn_climate_btn {
    background: linear-gradient(135deg, #7700cc 0%, #cc88ff 100%);
    color: #ffffff;
    border-color: var(--accent-purple);
}
.cn_climate_container.type-dominion .cn_climate_btn:hover:not(:disabled) {
    background: linear-gradient(135deg, #cc88ff 0%, #e0b3ff 100%);
    box-shadow: 0 0 25px rgba(139, 92, 246, 0.7);
}

.cn_climate_icon {
    font-size: 52px;
    display: block;
    margin-bottom: 10px;
    line-height: 1;
    animation: boxFloat 3s ease-in-out infinite;
    filter: drop-shadow(0 0 18px rgba(0, 224, 255, 0.5));
}
.cn_climate_icon.disabled {
    filter: grayscale(100%) opacity(0.35);
    animation: none;
}
.cn_climate_effect {
    font-size: 11px;
    color: var(--text-muted);
    margin: 6px 0 10px 0;
    line-height: 1.4;
    min-height: 34px;
}
.cn_climate_effect strong { color: var(--text-main); }
.cn_climate_count {
    font-size: 22px;
    color: var(--text-title);
    font-weight: 700;
    font-family: 'Courier New', monospace;
    margin-bottom: 10px;
    text-shadow: 0 0 10px rgba(255, 255, 255, 0.3);
}
.cn_climate_btn {
    padding: 10px 14px;
    border: 1px solid;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 900;
    letter-spacing: 1px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: uppercase;
    font-family: inherit;
    width: 100%;
}
.cn_climate_btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    background: rgba(30, 41, 59, 0.85) !important;
    border-color: var(--border-color) !important;
    color: var(--text-muted) !important;
    box-shadow: none !important;
    transform: none !important;
}
.cn_climate_note {
    font-size: 10px;
    color: var(--text-muted);
    margin-top: 8px;
    line-height: 1.4;
    font-style: italic;
}

/* ===== Rates ===== */
.cn_rates {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 24px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.cn_rates h3 {
    font-size: 14px;
    color: var(--accent-cyan);
    margin: 0 0 12px 0;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.cn_rates_grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
}
.cn_rate_card {
    text-align: center;
    padding: 10px;
    border-radius: 8px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.cn_rate_card .rate_label {
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 4px;
}
.cn_rate_card .rate_pct {
    font-size: 18px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
}
.cn_rate_card .rate_sub {
    font-size: 9px;
    color: var(--text-muted);
    margin-top: 3px;
    letter-spacing: 0.5px;
}
.cn_rate_card.common { border: 1px solid rgba(150, 150, 150, 0.4); }
.cn_rate_card.common .rate_label, .cn_rate_card.common .rate_pct { color: #cccccc; }
.cn_rate_card.rare   { border: 1px solid rgba(59, 130, 246, 0.4); }
.cn_rate_card.rare   .rate_label, .cn_rate_card.rare .rate_pct   { color: #66bbff; }
.cn_rate_card.epic   { border: 1px solid rgba(139, 92, 246, 0.4); }
.cn_rate_card.epic   .rate_label, .cn_rate_card.epic .rate_pct   { color: #cc88ff; }
.cn_rate_card.mythic { border: 1px solid rgba(255, 102, 0, 0.4); }
.cn_rate_card.mythic .rate_label, .cn_rate_card.mythic .rate_pct { color: #ffaa66; }

.cn_history {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.cn_history h3 {
    font-size: 14px;
    color: var(--accent-cyan);
    margin: 0 0 12px 0;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.cn_hist_row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 12px;
    margin-bottom: 6px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-radius: 6px;
    border-left: 3px solid var(--accent-cyan);
    font-size: 12px;
    transition: all 0.2s ease;
}
.cn_hist_row:hover {
    background: rgba(0, 224, 255, 0.08);
    transform: translateX(3px);
}
.cn_hist_row.rarity-common    { border-left-color: #999; }
.cn_hist_row.rarity-rare      { border-left-color: var(--accent-blue); }
.cn_hist_row.rarity-epic      { border-left-color: var(--accent-purple); }
.cn_hist_row.rarity-mythic    { border-left-color: #ff6600; }

.cn_hist_row .hist_icon { font-size: 16px; margin-right: 8px; }
.cn_hist_row .hist_name { flex: 1; color: var(--text-main); }
.cn_hist_row .hist_value { color: var(--accent-green); font-weight: 700; font-family: 'Courier New', monospace; margin-right: 10px; }
.cn_hist_row .hist_date { color: var(--text-muted); font-size: 10px; }

.cn_empty {
    text-align: center;
    padding: 30px;
    color: var(--text-muted);
    font-style: italic;
    font-size: 13px;
}

@media (max-width: 700px) {
    .cn_wrap { padding: 8px !important; }
    .cn_title { font-size: 20px !important; }
    .cn_subtitle { font-size: 11px !important; margin-bottom: 15px !important; }
    .cn_stats { grid-template-columns: repeat(4, 1fr) !important; gap: 4px !important; margin-bottom: 15px !important; }
    .cn_stat { padding: 6px 2px !important; border-radius: 8px !important; }
    .cn_stat .stat_icon { font-size: 16px !important; margin-bottom: 2px !important; }
    .cn_stat .stat_value { font-size: 13px !important; margin-bottom: 2px !important; }
    .cn_stat .stat_label { font-size: 8px !important; letter-spacing: 0 !important; line-height: 1.1 !important; }
    .cn_boxes_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 8px !important; margin-bottom: 15px !important; }
    .cn_box_container { padding: 12px 6px !important; border-radius: 10px !important; }
    .cn_box_icon { font-size: 40px !important; margin-bottom: 6px !important; }
    .cn_box_title { font-size: 11px !important; line-height: 1.1 !important; }
    .cn_box_mult { font-size: 8px !important; padding: 1px 6px !important; margin-bottom: 4px !important; }
    .cn_box_count { font-size: 20px !important; margin-bottom: 8px !important; }
    .cn_open_btn { font-size: 9px !important; padding: 8px 2px !important; letter-spacing: 0 !important; white-space: normal !important; line-height: 1.2 !important; }
    /* v5.0 — Cofres climáticos en móvil */
    .cn_climate_grid { grid-template-columns: 1fr !important; gap: 8px !important; }
    .cn_climate_container { padding: 14px 10px !important; }
    .cn_climate_icon { font-size: 40px !important; }
    .cn_climate_effect { font-size: 10px !important; min-height: auto !important; }
    .cn_climate_count { font-size: 18px !important; }
    .cn_climate_btn { font-size: 10px !important; padding: 8px 6px !important; }
    .cn_climate_section_title { font-size: 13px !important; }
    /* Buff banner en móvil */
    .cn_buff_banner { flex-direction: column !important; text-align: center !important; padding: 14px !important; gap: 10px !important; }
    .cn_buff_icon { font-size: 42px !important; }
    .cn_buff_info { text-align: center !important; }
    .cn_buff_name { font-size: 16px !important; }
    .cn_buff_timer { text-align: center !important; min-width: auto !important; }
    .cn_buff_timer_value { font-size: 20px !important; }
    /* Rates */
    .cn_rates_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 5px !important; }
    .cn_rate_card { padding: 6px !important; }
    .cn_rate_card .rate_label { font-size: 9px !important; }
    .cn_rate_card .rate_pct { font-size: 14px !important; }
    .cn_rate_card .rate_sub { font-size: 8px !important; }
    .cn_hist_row { flex-wrap: wrap !important; gap: 4px !important; padding: 6px !important; }
    .cn_hist_row .hist_name { font-size: 10px !important; flex: 1 1 100% !important; margin-top: 2px; }
    .cn_hist_row .hist_value { font-size: 11px !important; }
    .cn_info_box { font-size: 11px !important; padding: 10px 12px !important; }
}
</style>

<div class="cn_wrap">

    <div class="cn_title">📦 Contenedores</div>
    <div class="cn_subtitle">Abre tus cajas para obtener recompensas aleatorias. ¡Cada apertura es gratis!</div>

    {* ============ v5.0 — BANNER BUFF ACTIVO ============ *}
    {if $activeBuff && $buffSegundosRestantes > 0}
        <div class="cn_buff_banner" id="cnBuffBanner">
            <div class="cn_buff_icon">
                {if $activeBuff.buff_type == 'estabilizador_menor'}🌤️
                {elseif $activeBuff.buff_type == 'estabilizador_mayor'}🌈
                {elseif $activeBuff.buff_type == 'dominio'}⚡
                {else}✨{/if}
            </div>
            <div class="cn_buff_info">
                <div class="cn_buff_title">⚡ Buff Climático Activo</div>
                <div class="cn_buff_name">{$buffNombreLegible}</div>
                <div class="cn_buff_desc">
                    {if $activeBuff.buff_type == 'estabilizador_menor'}
                        Reduce a la mitad los factores negativos del clima.
                    {elseif $activeBuff.buff_type == 'estabilizador_mayor'}
                        Neutraliza todos los factores negativos del clima.
                    {elseif $activeBuff.buff_type == 'dominio'}
                        Convierte los factores negativos en positivos.
                    {else}
                        Efecto climático activo.
                    {/if}
                </div>
            </div>
            <div class="cn_buff_timer">
                <div class="cn_buff_timer_label">Tiempo restante</div>
                <div class="cn_buff_timer_value" id="cnBuffTimer"
                     data-expires="{$activeBuff.expires_at}"
                     data-now="{"now"|date_format:"%s"}">
                    --h --m --s
                </div>
            </div>
        </div>
    {/if}

    {* ============ ESTADÍSTICAS ============ *}
    <div class="cn_stats">
        <div class="cn_stat boxes">
            <span class="stat_icon">📦</span>
            <div class="stat_value">{$containersCount}</div>
            <div class="stat_label">Contenedores</div>
        </div>
        <div class="cn_stat opened">
            <span class="stat_icon">✅</span>
            <div class="stat_value">{$containersOpened}</div>
            <div class="stat_label">Abiertos</div>
        </div>

        {* v4.0 — Moneda DINÁMICA (NTX-20 o UNTX-20 según riel) *}
        <div class="cn_stat ntx">
            <span class="stat_icon">💲</span>
            <div class="stat_value">{$saldo_actual|number_format:0:',,':'.'}</div>
            <div class="stat_label">{$moneda}</div>
        </div>

        {* v4.0 — Reemplaza "Bonus Minas" por "Tope drop/hora" *}
        <div class="cn_stat drop">
            <span class="stat_icon">⏱️</span>
            <div class="stat_value">1h</div>
            <div class="stat_label">Tope Drop</div>
        </div>
    </div>

    {* ============ INFO DEL SISTEMA ============ *}
    <div class="cn_info_box">
        <span class="info_title">ℹ️ Sistema de recompensas (v2.0)</span>
        Los recursos (metal, cristal, deuterio) se calculan según tu <strong>producción por hora</strong> del planeta actual:
        <strong>20–40%</strong> en comunes, <strong>40–60%</strong> en raros, <strong>60–80%</strong> en épicos y <strong>80–100%</strong> en míticos.
        El multiplicador del cofre (x1 / x2 / x5 / x7) se aplica después.
        La materia oscura se entrega entre 250 y 2.500 por cofre.
        Las naves, defensas y potenciadores tienen valores fijos.
    </div>

    {* ============ MENSAJE ============ *}
    {if $message}
        <div class="cn_msg {$msgType}">{$message}</div>
    {/if}

    {* ============ RECOMPENSA ============ *}
    {if $reward}
        <div class="cn_reward">
            <div class="rw_title">🎉 ¡Has obtenido!</div>
            <span class="rw_icon">{$reward.icon}</span>
            <div class="rw_name">{$reward.name}</div>
            <div class="rw_value">+ {$reward.value}</div>
            <span class="rw_rarity {$reward.rarity}">{$reward.rarity}</span>
        </div>
    {/if}

    {* ============ 4 CAJAS DE APERTURA ============ *}
    <div class="cn_boxes_grid">

        {* ─────── CAJA 1: CONTENEDOR GENÉRICO ─────── *}
        <div class="cn_box_container type-generic">
            <span class="cn_box_icon{if $containersCount <= 0} disabled{/if}">📦</span>
            <div class="cn_box_title">Contenedor Genérico</div>
            <div class="cn_box_mult">Multiplicador x1</div>
            <div class="cn_box_count">{$containersCount}</div>

            <form method="post" action="game.php?page=containers" style="display:block;width:100%;">
                <input type="hidden" name="action" value="open">
                <button type="submit" class="cn_open_btn" {if $containersCount <= 0}disabled{/if}>
                    🎁 Abrir Contenedor
                </button>
            </form>
        </div>

        {* ─────── CAJA 2: COFRE COMÚN ─────── *}
        <div class="cn_box_container type-common">
            <span class="cn_box_icon{if $boxCommon <= 0} disabled{/if}">📦</span>
            <div class="cn_box_title">Cofre Común</div>
            <div class="cn_box_mult">Multiplicador x2</div>
            <div class="cn_box_count">{$boxCommon}</div>

            <form method="post" action="game.php?page=containers" style="display:block;width:100%;">
                <input type="hidden" name="action" value="open_common">
                <button type="submit" class="cn_open_btn" {if $boxCommon <= 0}disabled{/if}>
                    📦 Abrir Cofre Común
                </button>
            </form>
        </div>

        {* ─────── CAJA 3: COFRE RARO ─────── *}
        <div class="cn_box_container type-rare">
            <span class="cn_box_icon{if $boxRare <= 0} disabled{/if}">💎</span>
            <div class="cn_box_title">Cofre Raro</div>
            <div class="cn_box_mult">Multiplicador x5</div>
            <div class="cn_box_count">{$boxRare}</div>

            <form method="post" action="game.php?page=containers" style="display:block;width:100%;">
                <input type="hidden" name="action" value="open_rare">
                <button type="submit" class="cn_open_btn" {if $boxRare <= 0}disabled{/if}>
                    💎 Abrir Cofre Raro
                </button>
            </form>
        </div>

        {* ─────── CAJA 4: COFRE LEGENDARIO ─────── *}
        <div class="cn_box_container type-legendary">
            <span class="cn_box_icon{if $boxLegendary <= 0} disabled{/if}">👑</span>
            <div class="cn_box_title">Cofre Legendario</div>
            <div class="cn_box_mult">Multiplicador x7</div>
            <div class="cn_box_count">{$boxLegendary}</div>

            <form method="post" action="game.php?page=containers" style="display:block;width:100%;">
                <input type="hidden" name="action" value="open_legendary">
                <button type="submit" class="cn_open_btn" {if $boxLegendary <= 0}disabled{/if}>
                    👑 Abrir Cofre Legendario
                </button>
            </form>
        </div>

    </div>

    {* ============ v5.0 — COFRES CLIMÁTICOS ============ *}
    <div class="cn_climate_section_title">🌦️ Cofres Climáticos</div>

    <div class="cn_info_box" style="margin-bottom:14px;">
        <span class="info_title">⚡ ¿Qué hacen estos cofres?</span>
        Activan un <strong>buff de 24 horas</strong> que modifica los factores del clima en tus combates PvP.
        Solo <strong>1 buff activo por jugador</strong>: si activas otro, reemplaza al anterior.
        <strong>El buff se fija al lanzar la flota</strong> (si expira en vuelo, se sigue aplicando).
    </div>

    <div class="cn_climate_grid">

        {* ─────── COFRE CLIMÁTICO MENOR ─────── *}
        <div class="cn_climate_container type-minor">
            <span class="cn_climate_icon{if $boxClimateMinor <= 0} disabled{/if}">🌤️</span>
            <div class="cn_box_title">Estabilizador Menor</div>
            <div class="cn_climate_effect">
                Reduce a la mitad los <strong>factores negativos</strong> del clima.
            </div>
            <div class="cn_climate_count">{$boxClimateMinor}</div>

            <form method="post" action="game.php?page=containers" style="display:block;width:100%;">
                <input type="hidden" name="action" value="activate_climate_minor">
                <button type="submit" class="cn_climate_btn" {if $boxClimateMinor <= 0}disabled{/if}>
                    🌤️ Activar
                </button>
            </form>
        </div>

        {* ─────── COFRE CLIMÁTICO MAYOR ─────── *}
        <div class="cn_climate_container type-major">
            <span class="cn_climate_icon{if $boxClimateMajor <= 0} disabled{/if}">🌈</span>
            <div class="cn_box_title">Estabilizador Mayor</div>
            <div class="cn_climate_effect">
                <strong>Neutraliza</strong> todos los factores negativos del clima.
            </div>
            <div class="cn_climate_count">{$boxClimateMajor}</div>

            <form method="post" action="game.php?page=containers" style="display:block;width:100%;">
                <input type="hidden" name="action" value="activate_climate_major">
                <button type="submit" class="cn_climate_btn" {if $boxClimateMajor <= 0}disabled{/if}>
                    🌈 Activar
                </button>
            </form>
        </div>

        {* ─────── COFRE CLIMÁTICO DOMINIO ─────── *}
        <div class="cn_climate_container type-dominion">
            <span class="cn_climate_icon{if $boxClimateDominion <= 0} disabled{/if}">⚡</span>
            <div class="cn_box_title">Dominio Climático</div>
            <div class="cn_climate_effect">
                <strong>Convierte</strong> los negativos en positivos (+15%).
            </div>
            <div class="cn_climate_count">{$boxClimateDominion}</div>

            <form method="post" action="game.php?page=containers" style="display:block;width:100%;">
                <input type="hidden" name="action" value="activate_climate_dominion">
                <button type="submit" class="cn_climate_btn" {if $boxClimateDominion <= 0}disabled{/if}>
                    ⚡ Activar
                </button>
            </form>
        </div>

    </div>

    {* ============ PROBABILIDADES (ACTUALIZADAS) ============ *}
    <div class="cn_rates">
        <h3>🎲 Probabilidades por rareza</h3>
        <div class="cn_rates_grid">
            <div class="cn_rate_card common">
                <div class="rate_label">Común</div>
                <div class="rate_pct">52.00%</div>
                <div class="rate_sub">20–40% prod/h</div>
            </div>
            <div class="cn_rate_card rare">
                <div class="rate_label">Raro</div>
                <div class="rate_pct">24.80%</div>
                <div class="rate_sub">40–60% prod/h</div>
            </div>
            <div class="cn_rate_card epic">
                <div class="rate_label">Épico</div>
                <div class="rate_pct">16.23%</div>
                <div class="rate_sub">60–80% prod/h</div>
            </div>
            <div class="cn_rate_card mythic">
                <div class="rate_label">Mítico</div>
                <div class="rate_pct">6.98%</div>
                <div class="rate_sub">80–100% prod/h</div>
            </div>
        </div>
    </div>

    {* ============ HISTORIAL ============ *}
    <div class="cn_history">
        <h3>📜 Últimas aperturas</h3>

        {if $history}
            {foreach $history as $h}
                <div class="cn_hist_row rarity-{$h.loot_rarity}">
                    <span class="hist_icon">{$h.loot_icon}</span>
                    <span class="hist_name">{$h.loot_name}</span>
                    <span class="hist_value">+{$h.loot_value}</span>
                    <span class="hist_date">{$h.opened_at|date_format:"%d/%m %H:%M"}</span>
                </div>
            {/foreach}
        {else}
            <div class="cn_empty">Aún no has abierto ningún contenedor.</div>
        {/if}
    </div>

</div>

{* ============ v5.0 — TIMER JS DEL BUFF ============ *}
<script>
(function() {
    var timerEl = document.getElementById('cnBuffTimer');
    if (!timerEl) return;

    var expiresAt = parseInt(timerEl.getAttribute('data-expires'), 10);
    if (isNaN(expiresAt) || expiresAt <= 0) return;

    // El "now" del servidor llega como timestamp Unix.
    // Calculamos el desfase para que la cuenta atrás sea consistente
    // aunque el reloj del navegador no esté sincronizado.
    var serverNow = parseInt(timerEl.getAttribute('data-now'), 10);
    if (isNaN(serverNow) || serverNow <= 0) {
        serverNow = Math.floor(Date.now() / 1000);
    }
    var clientNow = Math.floor(Date.now() / 1000);
    var clockOffset = serverNow - clientNow; // segundos que hay que sumar al reloj del cliente

    function pad(n) {
        return n < 10 ? '0' + n : '' + n;
    }

    function updateTimer() {
        var now = Math.floor(Date.now() / 1000) + clockOffset;
        var diff = expiresAt - now;

        if (diff <= 0) {
            timerEl.textContent = '❌ Expirado';
            timerEl.classList.add('urgent');
            // Recargar para que PHP actualice el estado (quitar el banner)
            setTimeout(function() { window.location.reload(); }, 1500);
            return;
        }

        var h = Math.floor(diff / 3600);
        var m = Math.floor((diff % 3600) / 60);
        var s = diff % 60;

        timerEl.textContent = pad(h) + 'h ' + pad(m) + 'm ' + pad(s) + 's';

        // Últimos 5 minutos → urgente (parpadea en rojo)
        if (diff <= 300) {
            timerEl.classList.add('urgent');
        } else {
            timerEl.classList.remove('urgent');
        }
    }

    updateTimer();
    setInterval(updateTimer, 1000);
})();
</script>

{/block}