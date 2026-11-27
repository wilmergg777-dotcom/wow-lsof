{block name="title" prepend}{$LNG.lm_officiers}{/block}
{block name="content"}

{* ============================================================
   ASTROIO OFFICIERS v4.3 — Estilo Xnova moderno + Doble Riel
   Prefijo CSS: .astroofc_
   FIX v4.3:
     - Móvil: 2 columnas por fila (Oficiales y Místicos).
     - Místicos: Precio y Botón apilados verticalmente.
   ============================================================ *}

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

/* ====== Wrapper ====== */
.astroofc_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal (glassmorphism) ====== */
.astroofc_main_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 1400px;
    margin: 0 auto 15px auto;
}

/* ====== Header ====== */
.astroofc_header {
    text-align: center;
    color: #ffaa33;
    font-size: 22px;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    padding: 4px 0 6px 0;
    text-shadow: 0 0 12px rgba(255, 170, 51, 0.5), 0 0 24px rgba(255, 170, 51, 0.25);
    font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
}

.astroofc_subtitle {
    text-align: center;
    color: var(--text-muted);
    font-size: 12px;
    font-style: italic;
    padding-bottom: 4px;
    letter-spacing: 0.3px;
}

/* ====== Saldo dinámico ====== */
.astroofc_balance_box {
    text-align: center;
    margin: 10px 0 4px 0;
}

.astroofc_balance_badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 18px;
    background: rgba(0, 40, 20, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px;
    font-size: 14px;
    font-weight: 700;
    color: var(--accent-green);
    box-shadow: 0 0 16px rgba(74, 255, 136, 0.25);
}

.astroofc_balance_badge strong {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-size: 16px;
    letter-spacing: 0.5px;
}

.astroofc_divider {
    height: 1px;
    background: linear-gradient(90deg, transparent 0%, rgba(0, 204, 255, 0.3) 20%, rgba(0, 204, 255, 0.5) 50%, rgba(0, 204, 255, 0.3) 80%, transparent 100%);
    margin: 8px 0 16px 0;
}

/* ============================================================
   PESTAÑAS
   ============================================================ */
.astroofc_tabs {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-bottom: 18px;
    padding-bottom: 14px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.1);
}

.astroofc_tab {
    flex: 1 1 0;
    max-width: 280px;
    background: rgba(15, 22, 36, 0.6);
    border: 1px solid rgba(0, 204, 255, 0.2);
    border-radius: 8px;
    padding: 10px 18px;
    color: #7a8a9a;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: inherit;
    text-transform: uppercase;
    letter-spacing: 1px;
    outline: none;
    text-align: center;
}

.astroofc_tab:hover {
    color: #00ccff;
    border-color: rgba(0, 204, 255, 0.5);
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.25);
    transform: translateY(-1px);
}

.astroofc_tab.astroofc_tab_active[data-tab="dm"] {
    background: linear-gradient(135deg, rgba(90, 0, 153, 0.9), rgba(170, 68, 255, 0.9));
    border-color: #cc66ff;
    color: #ffffff;
    box-shadow: 0 0 16px rgba(170, 68, 255, 0.55), inset 0 1px 0 rgba(255, 255, 255, 0.2);
    text-shadow: 0 0 8px rgba(255, 255, 255, 0.7);
}

.astroofc_tab.astroofc_tab_active[data-tab="mistic"] {
    background: linear-gradient(135deg, rgba(109, 40, 217, 0.9), rgba(139, 92, 246, 0.9));
    border-color: #a78bfa;
    color: #ffffff;
    box-shadow: 0 0 16px rgba(139, 92, 246, 0.55), inset 0 1px 0 rgba(255, 255, 255, 0.2);
    text-shadow: 0 0 8px rgba(255, 255, 255, 0.7);
}

.astroofc_tab.astroofc_tab_active[data-tab="offi"] {
    background: linear-gradient(135deg, rgba(170, 85, 0, 0.9), rgba(255, 170, 51, 0.9));
    border-color: #ffcc66;
    color: #ffffff;
    box-shadow: 0 0 16px rgba(255, 170, 51, 0.55), inset 0 1px 0 rgba(255, 255, 255, 0.2);
    text-shadow: 0 0 8px rgba(255, 255, 255, 0.7);
}

.astroofc_tab_content { display: none; }
.astroofc_tab_content.astroofc_tab_content_active {
    display: block;
    animation: astroofc_fadeIn 0.3s ease;
}

@keyframes astroofc_fadeIn {
    from { opacity: 0; transform: translateY(6px); }
    to   { opacity: 1; transform: translateY(0); }
}

/* ============================================================
   HEADER DE SECCIÓN
   ============================================================ */
.astroofc_section_header {
    color: #ffdd66;
    font-size: 14px;
    font-weight: 800;
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 6px 0 4px 0;
    margin-bottom: 12px;
    border-bottom: 1px solid rgba(255, 221, 102, 0.2);
    text-shadow: 0 0 10px rgba(255, 221, 102, 0.4);
}

.astroofc_section_header.astroofc_dm_header {
    color: #cc88ff;
    border-bottom-color: rgba(204, 136, 255, 0.25);
    text-shadow: 0 0 10px rgba(204, 136, 255, 0.5);
}

.astroofc_section_header.astroofc_mistic_header {
    color: #a78bfa;
    border-bottom-color: rgba(167, 139, 250, 0.25);
    text-shadow: 0 0 10px rgba(167, 139, 250, 0.5);
}

/* ============================================================
   GRIDS (ESCRITORIO)
   ============================================================ */
.astroofc_grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 15px;
    width: 100%;
}

.astroofc_mistic_grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); 
    gap: 12px;
    width: 100%;
}

/* ============================================================
   MÍSTICOS - ESTILO HORIZONTAL MINIMALISTA (ESCRITORIO)
   ============================================================ */
.astroofc_card.astroofc_mistic {
    display: flex;
    flex-direction: row;
    align-items: stretch;
    background: var(--bg-card);
    border: 1px solid #3b0764;
    border-radius: 10px;
    padding: 10px;
    gap: 12px;
    transition: 0.2s ease;
}
.astroofc_card.astroofc_mistic:hover {
    border-color: #8b5cf6;
    box-shadow: 0 4px 15px rgba(139, 92, 246, 0.2);
}

.astroofc_mistic_icon {
    width: 75px;
    height: 75px;
    flex-shrink: 0;
    background: #0a1018;
    border: 1px solid rgba(255, 255, 255, 0.05);
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 36px;
    position: relative;
}

.astroofc_mistic_lvl {
    position: absolute;
    bottom: -6px;
    right: -6px;
    background: #1e1e2d;
    border: 1px solid #8b5cf6;
    color: #d8b4fe;
    font-size: 9px;
    font-weight: 700;
    padding: 1px 5px;
    border-radius: 4px;
}

.astroofc_mistic_content {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    flex-grow: 1;
    min-width: 0;
}

.astroofc_mistic_name {
    color: #ffffff;
    font-weight: 800;
    font-size: 13px;
    text-transform: uppercase;
    margin-bottom: 4px;
}

.astroofc_mistic_buffs {
    font-size: 10.5px;
    line-height: 1.4;
    color: #cbd5e1;
    margin-bottom: 6px;
}
.astroofc_mistic_buffs span {
    display: block;
}
.astroofc_mistic_buffs .buff-pos { color: #4aff88; }
.astroofc_mistic_buffs .buff-neg { color: #ef4444; }

/* AQUI ESTÁ EL ARREGLO DEL PRECIO Y EL BOTÓN */
.astroofc_mistic_footer {
    display: flex;
    flex-direction: column; /* Apila precio arriba y botón abajo */
    gap: 6px;
    border-top: 1px solid rgba(255, 255, 255, 0.05);
    padding-top: 6px;
    margin-top: auto;
}

.astroofc_mistic_cost {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 4px;
    font-size: 12px;
    font-weight: 700;
    color: #66ff99;
    font-family: 'Courier New', monospace;
}

.astroofc_mistic_btn {
    width: 100%; /* Ocupa todo el ancho */
    background: transparent;
    border: 1px solid rgba(139, 92, 246, 0.5);
    color: #a78bfa;
    padding: 6px 12px;
    font-size: 10px;
    font-weight: 600;
    border-radius: 4px;
    cursor: pointer;
    text-transform: uppercase;
    transition: 0.2s;
    font-family: inherit;
    text-align: center;
}
.astroofc_mistic_btn:hover {
    background: rgba(139, 92, 246, 0.15);
    border-color: #a78bfa;
    color: #ffffff;
}
.astroofc_mistic_btn:disabled {
    border-color: rgba(255, 255, 255, 0.1);
    color: #7a8a9a;
    cursor: not-allowed;
    background: transparent;
}

/* ====== Tarjeta Estándar (Oficiales) ====== */
.astroofc_card {
    position: relative;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
    transition: 0.3s ease;
    display: flex;
    flex-direction: column;
}
.astroofc_card:hover {
    border-color: rgba(255, 170, 51, 0.7);
    box-shadow: 0 8px 30px rgba(255, 170, 51, 0.3), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: translateY(-4px);
}
.astroofc_card.astroofc_dm { border-color: var(--border-color); }
.astroofc_card.astroofc_dm:hover {
    border-color: rgba(170, 68, 255, 0.7);
    box-shadow: 0 8px 30px rgba(170, 68, 255, 0.3), 0 4px 20px rgba(0, 0, 0, 0.5);
}

/* ====== Imagen grande (estilo Xnova) ====== */
.astroofc_card_img {
    position: relative;
    width: 100%;
    height: 180px;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-color: #0a1018;
    cursor: pointer;
    overflow: hidden;
}
.astroofc_card_img::after {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(to top, rgba(10, 16, 24, 0.95) 0%, rgba(10, 16, 24, 0.75) 35%, rgba(10, 16, 24, 0.15) 70%, transparent 100%);
    pointer-events: none;
}

.astroofc_card_lvl_badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(0, 0, 0, 0.75);
    border: 1px solid rgba(255, 170, 51, 0.6);
    border-radius: 6px;
    padding: 3px 10px;
    font-size: 11px;
    font-weight: 700;
    color: #ffaa33;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    z-index: 2;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    box-shadow: 0 0 12px rgba(255, 170, 51, 0.4);
}
.astroofc_card.astroofc_dm .astroofc_card_lvl_badge {
    border-color: rgba(170, 68, 255, 0.6);
    color: #cc88ff;
    box-shadow: 0 0 12px rgba(170, 68, 255, 0.4);
}

.astroofc_card_overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    padding: 15px;
    display: flex;
    flex-direction: column;
    gap: 3px;
    z-index: 2;
    pointer-events: none;
}
.astroofc_card_title {
    color: #ffffff;
    font-weight: 800;
    font-size: 16px;
    text-decoration: none;
    line-height: 1.2;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 1), 0 0 20px rgba(0, 0, 0, 0.8);
    letter-spacing: 0.3px;
    pointer-events: auto;
    transition: 0.2s ease;
}
.astroofc_card_title:hover {
    color: #ffaa33;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 1), 0 0 15px rgba(255, 170, 51, 0.9);
}
.astroofc_card.astroofc_dm .astroofc_card_title:hover {
    color: #cc88ff;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 1), 0 0 15px rgba(170, 68, 255, 0.9);
}
.astroofc_card_lvl {
    color: #cbd5e1;
    font-size: 11px;
    font-weight: 600;
    text-shadow: 0 1px 4px rgba(0, 0, 0, 1);
}

/* ====== Cuerpo (Oficiales) ====== */
.astroofc_card_body {
    padding: 12px 15px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex-grow: 1;
}

/* ====== Costos ====== */
.astroofc_costs {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 6px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 8px;
    padding: 6px 8px;
}
.astroofc_cost {
    display: flex;
    align-items: center;
    gap: 3px;
    font-size: 11px;
    color: #66ff99;
    font-weight: 700;
    justify-content: flex-start;
    min-width: 0;
    overflow: hidden;
    white-space: nowrap;
    cursor: help;
}
.astroofc_cost.no { color: #ff4488; }
.astroofc_cost .astroofc_cost_icon {
    font-size: 12px;
    line-height: 1;
    display: inline-block;
    filter: drop-shadow(0 0 3px rgba(255, 255, 255, 0.3));
    flex-shrink: 0;
}
.astroofc_cost .astroofc_cost_value {
    font-family: 'Courier New', monospace;
    font-size: 11px;
    overflow: hidden;
    text-overflow: ellipsis;
    min-width: 0;
    flex: 1;
}
.astroofc_cost .astroofc_cost_label {
    color: #88ddff;
    font-size: 9px;
    font-weight: 700;
    opacity: 0.9;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    flex-shrink: 0;
}

.astroofc_bonus_box {
    background: rgba(0, 0, 0, 0.3);
    border-left: 3px solid #ffaa33;
    border-radius: 4px;
    padding: 6px 10px;
    font-size: 11px;
    color: #c8d6e5;
    line-height: 1.5;
}
.astroofc_card.astroofc_dm .astroofc_bonus_box { border-left-color: #aa44ff; }
.astroofc_bonus_box p { margin: 0; padding: 0; }

.astroofc_active_box {
    background: rgba(102, 255, 153, 0.08);
    border: 1px solid rgba(102, 255, 153, 0.35);
    border-radius: 4px;
    padding: 5px 10px;
    font-size: 11px;
    color: #66ff99;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 4px;
    flex-wrap: wrap;
}
.astroofc_card.astroofc_dm .astroofc_active_box {
    background: rgba(170, 68, 255, 0.1);
    border-color: rgba(170, 68, 255, 0.4);
    color: #cc66ff;
}
.astroofc_active_timer {
    color: #ffaa33;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
}
.astroofc_card.astroofc_dm .astroofc_active_timer { color: #cc66ff; }

.astroofc_time_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 11px;
    color: var(--text-muted);
    padding: 4px 0;
    gap: 10px;
}
.astroofc_time_row .astroofc_val {
    color: #ffaa33;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
    text-shadow: 0 0 8px rgba(255, 170, 51, 0.4);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 65%;
    text-align: right;
}
.astroofc_card.astroofc_dm .astroofc_time_row .astroofc_val {
    color: #cc88ff;
    text-shadow: 0 0 8px rgba(170, 68, 255, 0.4);
}

.astroofc_card_footer {
    padding: 0 15px 15px 15px;
}
.astroofc_form { margin: 0; }
.astroofc_btn {
    display: block;
    width: 100%;
    box-sizing: border-box;
    padding: 10px 12px;
    border: 1px solid rgba(102, 255, 153, 0.4);
    border-radius: 8px;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    color: #ffffff;
    background: linear-gradient(135deg, rgba(0, 102, 68, 0.9), rgba(0, 170, 102, 0.9));
    box-shadow: 0 2px 10px rgba(0, 102, 68, 0.4);
    transition: 0.25s ease;
    font-family: inherit;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    text-transform: uppercase;
}
.astroofc_btn:hover {
    background: linear-gradient(135deg, rgba(0, 170, 102, 0.95), rgba(0, 221, 136, 0.95));
    box-shadow: 0 0 18px rgba(102, 255, 153, 0.6), 0 2px 10px rgba(0, 102, 68, 0.5);
    transform: translateY(-2px);
}
.astroofc_card.astroofc_dm .astroofc_btn {
    background: linear-gradient(135deg, rgba(90, 0, 153, 0.9), rgba(170, 68, 255, 0.9));
    border-color: rgba(170, 68, 255, 0.5);
    box-shadow: 0 2px 10px rgba(119, 0, 204, 0.45);
}
.astroofc_card.astroofc_dm .astroofc_btn:hover {
    background: linear-gradient(135deg, rgba(136, 0, 221, 0.95), rgba(204, 102, 255, 0.95));
    box-shadow: 0 0 18px rgba(170, 68, 255, 0.7), 0 2px 10px rgba(119, 0, 204, 0.5);
}

.astroofc_btn.disabled {
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
    cursor: not-allowed;
    box-shadow: none;
}
.astroofc_btn.disabled:hover { transform: none; box-shadow: none; }

.astroofc_no_money {
    display: block;
    width: 100%;
    box-sizing: border-box;
    padding: 10px 12px;
    border: 1px dashed rgba(255, 68, 136, 0.5);
    border-radius: 8px;
    font-weight: 700;
    font-size: 11px;
    text-align: center;
    color: #ff4488;
    background: rgba(255, 68, 136, 0.08);
    font-family: inherit;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}
.astroofc_card.astroofc_dm .astroofc_no_money {
    border-color: rgba(255, 170, 51, 0.5);
    color: #ffaa33;
    background: rgba(255, 170, 51, 0.08);
}

.astroofc_active_label {
    display: block;
    width: 100%;
    box-sizing: border-box;
    padding: 10px 12px;
    border: 1px solid rgba(170, 68, 255, 0.55);
    border-radius: 8px;
    font-weight: 800;
    font-size: 11px;
    text-align: center;
    color: #cc88ff;
    background: linear-gradient(135deg, rgba(90, 0, 153, 0.35), rgba(170, 68, 255, 0.35));
    font-family: inherit;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-shadow: 0 0 8px rgba(204, 136, 255, 0.7);
    box-shadow: 0 0 14px rgba(170, 68, 255, 0.35), inset 0 1px 0 rgba(255, 255, 255, 0.1);
    animation: astroofc_pulseActive 2s ease-in-out infinite;
}

@keyframes astroofc_pulseActive {
    0%, 100% { box-shadow: 0 0 14px rgba(170, 68, 255, 0.35), inset 0 1px 0 rgba(255, 255, 255, 0.1); }
    50% { box-shadow: 0 0 22px rgba(170, 68, 255, 0.65), inset 0 1px 0 rgba(255, 255, 255, 0.1); }
}

.astroofc_empty {
    text-align: center;
    padding: 40px 20px;
    color: #7a8a9a;
    font-size: 13px;
    font-style: italic;
}

.astroofc_footer_note {
    text-align: center;
    color: #7a8a9a;
    font-size: 11.5px;
    font-style: italic;
    padding-top: 14px;
    margin-top: 14px;
    border-top: 1px solid rgba(0, 204, 255, 0.1);
}

/* ============================================================
   RESPONSIVE (MÓVIL) - 2 COLUMNAS EXACTAS
   ============================================================ */
@media (max-width: 720px) {
    /* ============================================
       GENERAL Y PANEL
       ============================================ */
    .astroofc_wrap { padding: 8px !important; }
    .astroofc_main_panel { padding: 8px !important; }
    .astroofc_header { font-size: 16px !important; }
    
    /* Pestañas */
    .astroofc_tabs { gap: 4px !important; margin-bottom: 12px !important; padding-bottom: 10px !important; }
    .astroofc_tab { padding: 6px 8px !important; font-size: 9px !important; letter-spacing: 0.5px !important; }

    /* ============================================
       GRILLAS (2 COLUMNAS EN MÓVIL PARA TODOS)
       ============================================ */
    .astroofc_grid {
        grid-template-columns: repeat(2, 1fr) !important;
        gap: 8px !important;
    }
    .astroofc_mistic_grid {
        grid-template-columns: repeat(2, 1fr) !important;
        gap: 12px !important; /* 🆕 Subimos de 8px a 12px para que se note la separación */
    }

    /* ============================================
       TARJETAS: OFICIALES Y TIENDA DE BONUS
       ============================================ */
    .astroofc_card_img { height: 100px !important; }
    .astroofc_card_title { font-size: 12px !important; line-height: 1.15 !important; }
    .astroofc_card_lvl_badge { top: 6px !important; right: 6px !important; padding: 2px 7px !important; font-size: 9px !important; }
    .astroofc_card_overlay { padding: 8px 10px !important; gap: 2px !important; }
    .astroofc_card_lvl { font-size: 9px !important; }
    .astroofc_card_body { padding: 8px !important; gap: 5px !important; }
    .astroofc_costs { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; gap: 3px !important; padding: 5px 6px !important; }
    .astroofc_cost { font-size: 9px !important; gap: 2px !important; }
    .astroofc_cost .astroofc_cost_icon { font-size: 10px !important; }
    .astroofc_cost .astroofc_cost_value { font-size: 9px !important; }
    .astroofc_bonus_box { padding: 4px 6px !important; font-size: 9px !important; line-height: 1.3 !important; }
    .astroofc_active_box { padding: 3px 5px !important; font-size: 9px !important; }
    .astroofc_active_timer { font-size: 10px !important; }
    .astroofc_time_row { font-size: 9px !important; padding: 2px 0 !important; gap: 4px !important; }
    .astroofc_time_row .astroofc_val { font-size: 10px !important; max-width: 70% !important; }
    .astroofc_card_footer { padding: 0 8px 8px 8px !important; }
    .astroofc_btn, .astroofc_no_money, .astroofc_active_label { font-size: 9px !important; padding: 7px 5px !important; letter-spacing: 0.2px !important; }

    /* ============================================
       TARJETAS: MÍSTICOS (DISEÑO VERTICAL COMPACTO)
       ============================================ */
    .astroofc_card.astroofc_mistic {
        flex-direction: column !important;
        padding: 8px !important;
        gap: 4px !important;
        align-items: center !important;
        text-align: center !important;
        justify-content: space-between !important; /* Empuja el botón al fondo */
	}

    /* Icono */
    .astroofc_mistic_icon {
        width: 50px !important;
        height: 50px !important;
        font-size: 24px !important;
    }

    /* Nombre */
    .astroofc_mistic_name { 
        font-size: 10px !important; 
        margin-bottom: 2px !important;
    }

    /* Contenido de bonos */
    .astroofc_mistic_content {
        flex-grow: 1 !important; /* Esto hace que ocupe todo el espacio sobrante */
        display: flex !important;
        flex-direction: column !important;
        justify-content: flex-start !important;
        width: 100% !important;
    }

    /* Textos de los bonos juntos y compactos */
    .astroofc_mistic_buffs {
        font-size: 8.5px !important;
        line-height: 1.2 !important;
        margin-bottom: 2px !important;
    }
    .astroofc_mistic_buffs span {
        display: block !important;
        margin-bottom: 1px !important;
        word-break: break-word !important; /* Evita que textos largos rompan la tarjeta */
    }
    /* Porcentaje en línea con el texto */
    .astroofc_mistic_buffs .buff-pos,
    .astroofc_mistic_buffs .buff-neg {
        display: inline !important;
        margin-right: 2px !important;
    }

    /* Footer (Precio y Botón) al fondo */
    .astroofc_mistic_footer {
        margin-top: auto !important; /* Esto empuja el botón siempre al fondo */
        padding-top: 4px !important;
        gap: 4px !important;
        width: 100% !important;
        border-top: 1px solid rgba(255, 255, 255, 0.05) !important;
    }

    .astroofc_mistic_cost {
        font-size: 9.5px !important;
        margin-bottom: 2px !important;
        justify-content: center !important;
    }

    /* Botones de místicos finos y uniformes */
    .astroofc_mistic_btn {
        height: 22px !important; 
        padding: 0 !important; 
        font-size: 8px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        line-height: 1 !important;
        width: 100% !important;
    }
}

/* ============================================================
   MODAL PERSONALIZADO
   ============================================================ */
.ui-dialog {
    background: rgba(15, 23, 42, 0.95) !important;
    backdrop-filter: blur(10px) !important;
    -webkit-backdrop-filter: blur(10px) !important;
    border: 1px solid rgba(251, 191, 36, 0.5) !important;
    border-radius: 12px !important;
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.8) !important;
    padding: 0 !important;
    overflow: hidden;
}
.ui-dialog-titlebar {
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.9)) !important;
    border-bottom: 1px solid rgba(251, 191, 36, 0.3) !important;
    border-radius: 12px 12px 0 0 !important;
    color: #fbbf24 !important;
    font-weight: 700;
    padding: 10px 15px !important;
}
.ui-dialog-titlebar-close {
    background: transparent !important;
    border: none !important;
    color: #94a3b8 !important;
}
.ui-dialog-titlebar-close:hover {
    color: #ef4444 !important;
}
.ui-dialog-content {
    background: transparent !important;
    color: #cbd5e1 !important;
    padding: 15px !important;
    font-size: 13px;
    line-height: 1.6;
}
.ui-dialog-content .astroofc_modal_content {
    color: #cbd5e1;
}
.ui-dialog-buttonpane {
    background: rgba(15, 23, 42, 0.9) !important;
    border-top: 1px solid rgba(251, 191, 36, 0.2) !important;
    padding: 10px !important;
}
.ui-dialog-buttonpane button {
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.9)) !important;
    border: 1px solid rgba(251, 191, 36, 0.5) !important;
    color: #fbbf24 !important;
    font-weight: 700;
    border-radius: 6px !important;
    padding: 6px 15px !important;
    cursor: pointer;
    transition: 0.2s;
}
.ui-dialog-buttonpane button:hover {
    background: rgba(251, 191, 36, 0.2) !important;
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}
</style>

<div class="astroofc_wrap">

    <div class="astroofc_main_panel">

        {* ===== HEADER ===== *}
        <div class="astroofc_header">⭐ {$LNG.lm_officiers} ⭐</div>
        <div class="astroofc_subtitle">Recluta oficiales permanentes y compra bonos temporales con 💲</div>

        {* ===== SALDO DINÁMICO ===== *}
        <div class="astroofc_balance_box">
            <span class="astroofc_balance_badge">
                💲 Tu saldo: <strong>{$ntx_actual|number_format}</strong> {$moneda}
            </span>
        </div>

        <div class="astroofc_divider"></div>

        {* ===== PESTAÑAS ===== *}
        <div class="astroofc_tabs">
            <button type="button" class="astroofc_tab" data-tab="dm">
                💲 Tienda de Bonus
            </button>
            <button type="button" class="astroofc_tab" data-tab="mistic">
                🔮 Místicos
            </button>
            <button type="button" class="astroofc_tab astroofc_tab_active" data-tab="offi">
                🎖 {$LNG.of_offi}
            </button>
        </div>

        {* ============================================================
           TAB 1 — TIENDA DE BONUS
           ============================================================ *}
        <div class="astroofc_tab_content" id="astroofc_tab_dm">
            {if !empty($darkmatterList)}

                <div class="astroofc_section_header astroofc_dm_header">💲 Tienda de Bonus</div>

                <div class="astroofc_grid">
                    {foreach $darkmatterList as $ID => $Element}
                    <div class="astroofc_card astroofc_dm">

                        <div id="astroofc_desc_{$ID}" style="display:none;">
                            <p style="margin: 0 0 10px 0; font-size: 13px; color: #cbd5e1;">
                                Los bonos temporales otorgan ventajas pasivas a tu imperio durante un tiempo limitado.
                            </p>
                            {if !empty($Element.elementBonus)}
                            <div style="background: rgba(0, 0, 0, 0.3); border-left: 3px solid #aa44ff; padding: 10px; border-radius: 4px;">
                                <strong style="color: #cc88ff; display: block; margin-bottom: 5px; font-size: 14px;">Efectos de este bono:</strong>
                                {foreach $Element.elementBonus as $BonusName => $Bonus}
                                    <div style="margin-bottom: 4px; font-size: 13px;">
                                        <span style="color: #4aff88; font-weight: 700;">
                                            {if $Bonus[0] < 0}-{else}+{/if}{if $Bonus[1] == 0}{abs($Bonus[0] * 100)}%{else}{$Bonus[0]}{/if}
                                        </span>
                                        <span style="color: #cbd5e1;">{$LNG.bonus.$BonusName}</span>
                                    </div>
                                {/foreach}
                            </div>
                            {/if}
                            <p style="margin: 10px 0 0 0; font-size: 11px; color: #94a3b8; font-style: italic;">
                                Duración: 24 horas reales.
                            </p>
                        </div>

                        <div class="astroofc_card_img"
                             style="background-image:url('{$dpath}gebaeude/{$ID}.gif');"
                             onclick="return astroofcShowInfo({$ID}, '{$LNG.tech.{$ID}|escape:'javascript'}');">
                            <div class="astroofc_card_overlay">
                                <a class="astroofc_card_title" href="#" onclick="return astroofcShowInfo({$ID}, '{$LNG.tech.{$ID}|escape:'javascript'}');">
                                    {$LNG.tech.{$ID}}
                                </a>
                            </div>
                        </div>

                        <div class="astroofc_card_body">
                            <div class="astroofc_costs">
                                {foreach $Element.costResources as $RessID => $RessAmount}
                                {assign var="fullAmount" value=$RessAmount|number}
                                <div class="astroofc_cost {if $Element.costOverflow[$RessID] == 0}ok{else}no{/if}"
									title="{if $RessID == 931}{$moneda}{else}{$LNG.tech.{$RessID}}{/if}: {$fullAmount}">
                                    <span class="astroofc_cost_icon">{if $RessID == 901}🔩{elseif $RessID == 902}💎{elseif $RessID == 903}⚗️{elseif $RessID == 911}⚡{elseif $RessID == 921}🌌{elseif $RessID == 931}💲{else}▪️{/if}</span>
                                    <span class="astroofc_cost_value">{shortly_number($RessAmount)}</span>
                                    {if $RessID == 921 || $RessID == 931}<span class="astroofc_cost_label">{if $RessID == 921}MO{else}{$moneda}{/if}</span>{/if}
                                </div>
                                {/foreach}
                            </div>

                            {if !empty($Element.elementBonus)}
                            <div class="astroofc_bonus_box">
                                {foreach $Element.elementBonus as $BonusName => $Bonus}{if $Bonus@iteration % 3 === 1}<p>{/if}{if $Bonus[0] < 0}-{else}+{/if}{if $Bonus[1] == 0}{abs($Bonus[0] * 100)}%{else}{$Bonus[0]}{/if} {$LNG.bonus.$BonusName}{if $Bonus@iteration % 3 === 0 || $Bonus@last}</p>{else}&nbsp;{/if}{/foreach}
                            </div>
                            {/if}

                            {if $Element.timeLeft > 0}
                            <div class="astroofc_active_box">
                                {$LNG.of_still}
                                <span class="astroofc_active_timer" id="time_{$ID}">-</span>
                                {$LNG.of_active}
                            </div>
                            {/if}

                            <div class="astroofc_time_row">
                                <span>⏱ {$LNG.in_dest_durati}</span>
                                <span class="astroofc_val" title="{$Element.time} segundos">
                                    {assign var="totalSecs" value=$Element.time}
                                    {math equation="floor(s/86400)" s=$totalSecs assign="tDays"}
                                    {math equation="floor((s%86400)/3600)" s=$totalSecs assign="tHours"}
                                    {math equation="floor((s%3600)/60)" s=$totalSecs assign="tMinutes"}
                                    {math equation="floor(s%60)" s=$totalSecs assign="tSecs"}
                                    {if $tDays > 0}{$tDays}d {/if}{$tHours|string_format:"%02d"}h {$tMinutes|string_format:"%02d"}m {$tSecs|string_format:"%02d"}s
                                </span>
                            </div>
                        </div>

                        <div class="astroofc_card_footer">
                            {if $Element.is_active}
                                <span class="astroofc_active_label">⏱ {$LNG.of_active}</span>
                            {else}
                                {if $Element.buyable}
                                <form action="game.php?page=officier" method="post" class="astroofc_form">
                                    <input type="hidden" name="id" value="{$ID}">
                                    <button type="submit" class="astroofc_btn">{$LNG.of_recruit}</button>
                                </form>
                                {else}
                                <span class="astroofc_no_money">💲 Sin saldo suficiente</span>
                                {/if}
                            {/if}
                        </div>

                    </div>
                    {/foreach}
                </div>

            {else}
                <div class="astroofc_empty">No hay bonos disponibles.</div>
            {/if}
        </div>

        {* ============================================================
           TAB 2 — MÍSTICOS (BUCLE DINÁMICO)
           ============================================================ *}
        <div class="astroofc_tab_content" id="astroofc_tab_mistic">
            <div class="astroofc_section_header astroofc_mistic_header">🔮 Elementos Místicos</div>
            
            <div class="astroofc_mistic_grid">
                
                {foreach $misticList as $ID => $item}
                <div class="astroofc_card astroofc_mistic">
                    
                    <div class="astroofc_mistic_icon">
                        {if $item.name == 'FIRE'}🛕{elseif $item.name == 'WATER'}⚙️{elseif $item.name == 'EARTH'}🪨{elseif $item.name == 'MECRIC'}🔨{elseif $item.name == 'CHAOS'}🔻{elseif $item.name == 'MAGIC'}⚒️{elseif $item.name == 'ENERGY'}🌀{elseif $item.name == 'MIND'}🧠{elseif $item.name == 'NATURE'}🛡️{elseif $item.name == 'DESTRICT'}🔺{elseif $item.name == 'HOLY'}⚜️{elseif $item.name == 'CORRUPT'}⭕{elseif $item.name == 'BENEFIT'}🥚{elseif $item.name == 'VOID'}🕳️{elseif $item.name == 'ELEMENTAL'}🌪️{else}🔮{/if}
                        <div class="astroofc_mistic_lvl">{$item.level}/10</div>
                    </div>

                    <div class="astroofc_mistic_content">
                        <div class="astroofc_mistic_name">{$item.name}</div>
                        
                        <div class="astroofc_mistic_buffs">
                            {foreach $item.bonus as $stat_name => $stat_value}
                                <span>
                                    <span class="{if $stat_value > 0}buff-pos{else}buff-neg{/if}">
                                        {if $stat_value > 0}+{/if}{$stat_value}%
                                    </span> 
                                    {$stat_name|replace:'_':' '|capitalize}
                                </span>
                            {/foreach}
                        </div>

                        <div class="astroofc_mistic_footer">
                            {if $item.is_max}
                                <div class="astroofc_mistic_cost">MAX</div>
                                <button type="button" class="astroofc_mistic_btn" disabled>NIVEL MÁXIMO</button>
                            {else}
                                <div class="astroofc_mistic_cost">
                                    <span>{$item.currencyNext}</span>
                                    <span>{$item.costNext|number}</span>
                                </div>
                                <form action="game.php?page=officier" method="post" class="astroofc_form" style="margin:0;">
                                    <input type="hidden" name="action" value="buy_mistic">
                                    <input type="hidden" name="item_id" value="{$ID}">
                                    <button type="submit" class="astroofc_mistic_btn">Reclutar</button>
                                </form>
                            {/if}
                        </div>
                    </div>
                    
                </div>
                {/foreach}

            </div>
        </div>

        {* ============================================================
           TAB 3 — OFICIALES REGULARES
           ============================================================ *}
        <div class="astroofc_tab_content astroofc_tab_content_active" id="astroofc_tab_offi">
            {if !empty($officierList)}

                <div class="astroofc_section_header">🎖 {$LNG.of_offi}</div>

                <div class="astroofc_grid">
                    {foreach $officierList as $ID => $Element}
                    <div class="astroofc_card">

                        <div id="astroofc_desc_{$ID}" style="display:none;">{$LNG.longDescription.{$ID}}</div>

                        <div class="astroofc_card_img"
                             style="background-image:url('{$dpath}gebaeude/{$ID}.jpg');"
                             onclick="return astroofcShowInfo({$ID}, '{$LNG.tech.{$ID}|escape:'javascript'}');">

                            {if $Element.level > 0}
                            <span class="astroofc_card_lvl_badge">{$LNG.of_lvl} {$Element.level}</span>
                            {/if}

                            <div class="astroofc_card_overlay">
                                <a class="astroofc_card_title" href="#" onclick="return astroofcShowInfo({$ID}, '{$LNG.tech.{$ID}|escape:'javascript'}');">
                                    {$LNG.tech.{$ID}}
                                </a>
                                <span class="astroofc_card_lvl">
                                    {$LNG.of_lvl} {$Element.level}/{$Element.maxLevel}
                                </span>
                            </div>
                        </div>

                        <div class="astroofc_card_body">
                            <div class="astroofc_costs">
                                {foreach $Element.costResources as $RessID => $RessAmount}
                                {assign var="fullAmount" value=$RessAmount|number}
                                <div class="astroofc_cost {if $Element.costOverflow[$RessID] == 0}ok{else}no{/if}"
                                     title="{$LNG.tech.{$RessID}}: {$fullAmount}">
                                    <span class="astroofc_cost_icon">{if $RessID == 901}🔩{elseif $RessID == 902}💎{elseif $RessID == 903}⚗️{elseif $RessID == 911}⚡{elseif $RessID == 921}🌌{elseif $RessID == 931}💲{else}▪️{/if}</span>
                                    <span class="astroofc_cost_value">{shortly_number($RessAmount)}</span>
                                    {if $RessID == 921 || $RessID == 931}<span class="astroofc_cost_label">{if $RessID == 921}MO{else}{$moneda}{/if}</span>{/if}
                                </div>
                                {/foreach}
                            </div>

                            {if !empty($Element.elementBonus)}
                            <div class="astroofc_bonus_box">
                                {foreach $Element.elementBonus as $BonusName => $Bonus}{if $Bonus@iteration % 3 === 1}<p>{/if}{if $Bonus[0] < 0}-{else}+{/if}{if $Bonus[1] == 0}{abs($Bonus[0] * 100)}%{else}{$Bonus[0]}{/if} {$LNG.bonus.$BonusName}{if $Bonus@iteration % 3 === 0 || $Bonus@last}</p>{else}&nbsp;{/if}{/foreach}
                            </div>
                            {/if}
                        </div>

                        <div class="astroofc_card_footer">
                            {if $Element.maxLevel <= $Element.level}
                            <span class="astroofc_btn disabled">{$LNG.bd_maxlevel}</span>
                            {elseif $Element.buyable}
                            <form action="game.php?page=officier" method="post" class="astroofc_form">
                                <input type="hidden" name="id" value="{$ID}">
                                <button type="submit" class="astroofc_btn">{$LNG.of_recruit}</button>
                            </form>
                            {else}
                            <span class="astroofc_btn disabled">{$LNG.of_recruit}</span>
                            {/if}
                        </div>

                    </div>
                    {/foreach}
                </div>

            {else}
                <div class="astroofc_empty">
                    No hay oficiales disponibles.<br>
                    <small style="opacity:0.7;">Investiga las tecnologías necesarias para desbloquearlos.</small>
                </div>
            {/if}
        </div>

        <div class="astroofc_footer_note">
            ✦ Los bonos temporales duran 24 horas reales ✦
        </div>

    </div>

</div>

{/block}

{block name="script"}
<script src="scripts/game/officier.js"></script>
<script>
(function() {
    'use strict';

    function astroofcInitTabs() {
        var tabs = document.querySelectorAll('.astroofc_tab');
        var contents = document.querySelectorAll('.astroofc_tab_content');

        if (!tabs.length || !contents.length) return;

        for (var i = 0; i < tabs.length; i++) {
            tabs[i].onclick = function(e) {
                e.preventDefault();
                var target = this.getAttribute('data-tab');
                if (!target) return;

                for (var j = 0; j < tabs.length; j++) {
                    tabs[j].classList.remove('astroofc_tab_active');
                }
                for (var k = 0; k < contents.length; k++) {
                    contents[k].classList.remove('astroofc_tab_content_active');
                }

                this.classList.add('astroofc_tab_active');
                var content = document.getElementById('astroofc_tab_' + target);
                if (content) content.classList.add('astroofc_tab_content_active');
            };
        }
    }

    window.astroofcShowInfo = function(id, title) {
        var descElement = document.getElementById('astroofc_desc_' + id);
        if (!descElement) {
            console.error('No se encontró la descripción para el ID: ' + id);
            return false;
        }
        
        var description = descElement.innerHTML;
        
        var modalHtml = '<div id="astroofc_info_modal" title="' + title + '">' +
                        '<div class="astroofc_modal_content">' + description + '</div>' +
                        '</div>';
        
        $('#astroofc_info_modal').remove();
        
        var $modal = $(modalHtml).appendTo('body');
        
        $modal.dialog({
            modal: true,
            width: 450,
            maxHeight: 600,
            resizable: false,
            close: function() {
                $(this).dialog('destroy').remove();
            },
            buttons: {
                "Cerrar": function() {
                    $(this).dialog('close');
                }
            }
        });
        
        return false;
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', astroofcInitTabs);
    } else {
        astroofcInitTabs();
    }
})();
</script>
{/block}