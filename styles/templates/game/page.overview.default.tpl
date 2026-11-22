{block name="title" prepend}{$LNG.lm_overview}{/block}
{block name="script" append}{/block}
{block name="content"}

<style>
/* ============================================================== */
/* ============ ASTROIO - OVERVIEW ESTILO XNOVA MODERNO ========= */
/* ============================================================== */

:root {
    --bg-dark: rgba(11, 16, 30, 0.55);
    --bg-dark-strong: rgba(11, 16, 30, 0.80);
    --bg-card: rgba(15, 23, 42, 0.75);
    --bg-card-hover: rgba(30, 41, 59, 0.85);
    --bg-inner: rgba(0, 0, 0, 0.35);
    --border-color: #1e293b;
    --border-glow: #3b82f6;
    --text-main: #cbd5e1;
    --text-muted: #94a3b8;
    --text-title: #ffffff;
    --accent-blue: #3b82f6;
    --accent-cyan: #00e0ff;
    --accent-purple: #8b5cf6;
    --accent-gold: #fbbf24;
    --accent-green: #4aff88;
    --accent-red: #ef4444;
}

/* ====== FONDO GENERAL ====== */
html, body {
    background-color: transparent !important;
    margin: 0;
    padding: 0;
    min-height: 100%;
}

/* ====== CONTENEDOR PRINCIPAL ====== */
.xnova-wrapper {
    max-width: 1400px;
    margin: 0 auto;
    padding: 15px;
    font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
    color: var(--text-main);
    background-color: rgba(11, 16, 30, 0.55);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-radius: 14px;
}

/* ====== BARRA SUPERIOR ====== */
.xnova-topbar {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 10px 20px;
    margin-bottom: 15px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 10px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4);
    font-size: 11px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-topbar .onligne {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: rgba(74, 255, 136, 0.1);
    border: 1px solid rgba(74, 255, 136, 0.3);
    padding: 4px 12px;
    border-radius: 6px;
    color: var(--accent-green);
}
.xnova-topbar .ticket a {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    padding: 6px 14px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 600;
    font-size: 10px;
    transition: all 0.25s ease;
    box-shadow: 0 2px 8px rgba(0, 102, 204, 0.4);
}
.xnova-topbar .ticket a:hover {
    background: linear-gradient(135deg, #0099ff, #00ccff);
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}

/* ====== HERO BANNER ====== */
.xnova-hero {
    background: linear-gradient(135deg, rgba(15, 23, 42, 0.75), rgba(30, 27, 75, 0.75));
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.6);
    margin-bottom: 15px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-hero::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 0;
    background: radial-gradient(circle at center, rgba(59, 130, 246, 0.2) 0%, transparent 70%);
    pointer-events: none;
}
.xnova-hero h1 {
    font-size: 28px;
    font-weight: 900;
    color: #fff;
    letter-spacing: 5px;
    margin: 0;
    text-shadow: 0 0 30px rgba(0, 224, 255, 0.8);
    position: relative;
    z-index: 1;
}

/* ============================================================== */
/* ============ 🆕 BANNER BOOST FIN DE SEMANA ================== */
/* ============================================================== */
.xb_banner {
    margin: 0 0 15px 0;
    padding: 14px 50px 14px 20px;
    border-radius: 12px;
    font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
    position: relative;
    overflow: hidden;
    transition: all 0.3s ease;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}

.xb_banner[data-phase="countdown"] {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.88), rgba(0, 119, 204, 0.88));
    border: 1px solid rgba(0, 224, 255, 0.6);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5), 0 0 22px rgba(0, 224, 255, 0.35);
}

.xb_banner[data-phase="active"] {
    background: linear-gradient(135deg, rgba(0, 136, 68, 0.88), rgba(0, 204, 102, 0.88));
    border: 1px solid rgba(74, 255, 136, 0.75);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5), 0 0 28px rgba(74, 255, 136, 0.55);
    animation: xb-pulse 2s ease-in-out infinite;
}
@keyframes xb-pulse {
    0%, 100% { box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5), 0 0 28px rgba(74, 255, 136, 0.55); }
    50%      { box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5), 0 0 45px rgba(74, 255, 136, 0.85); }
}

.xb_content {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    position: relative;
    z-index: 2;
    flex-wrap: wrap;
}
.xb_icon {
    font-size: 24px;
    filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.7));
    animation: xb-icon-bounce 1.8s ease-in-out infinite;
}
@keyframes xb-icon-bounce {
    0%, 100% { transform: translateY(0) rotate(0deg); }
    50%      { transform: translateY(-3px) rotate(-8deg); }
}
.xb_text {
    color: #ffffff;
    font-size: 15px;
    font-weight: 800;
    letter-spacing: 1.3px;
    text-transform: uppercase;
    text-shadow: 0 2px 6px rgba(0, 0, 0, 0.9);
}
.xb_banner[data-phase="active"] .xb_text {
    animation: xb-text-glow 1.5s ease-in-out infinite;
}
@keyframes xb-text-glow {
    0%, 100% { text-shadow: 0 2px 6px rgba(0, 0, 0, 0.9); }
    50%      { text-shadow: 0 2px 6px rgba(0, 0, 0, 0.9), 0 0 22px rgba(74, 255, 136, 1); }
}

#xb_timer {
    font-family: 'Courier New', monospace;
    font-weight: 900;
    color: #ffffff;
    background: rgba(0, 0, 0, 0.45);
    padding: 3px 12px;
    border-radius: 6px;
    margin-left: 6px;
    display: inline-block;
    border: 1px solid rgba(255, 255, 255, 0.35);
    letter-spacing: 1px;
    min-width: 110px;
    text-align: center;
}

.xb_close {
    position: absolute;
    top: 50%;
    right: 14px;
    transform: translateY(-50%);
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 255, 255, 0.4);
    color: #ffffff;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    cursor: pointer;
    font-size: 13px;
    line-height: 1;
    padding: 0;
    font-weight: bold;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 3;
    font-family: inherit;
}
.xb_close:hover {
    background: rgba(255, 0, 0, 0.65);
    border-color: #ff4444;
    transform: translateY(-50%) scale(1.15) rotate(90deg);
    box-shadow: 0 0 12px rgba(255, 68, 68, 0.8);
}

@media (max-width: 700px) {
    .xb_banner { padding: 12px 45px 12px 12px; }
    .xb_text   { font-size: 12px; letter-spacing: 0.8px; }
    .xb_icon   { font-size: 18px; }
    #xb_timer  { font-size: 12px; padding: 2px 8px; min-width: 90px; }
}

/* ====== DISEÑO DE 2 COLUMNAS ====== */
.xnova-layout {
    display: flex;
    gap: 15px;
}
.xnova-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 15px;
    min-width: 0;
}
.xnova-sidebar {
    width: 340px;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
    gap: 15px;
}

/* ====== TARJETAS GENÉRICAS ====== */
.xnova-card {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: transform 0.2s ease, border-color 0.2s ease;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-card:hover {
    border-color: rgba(59, 130, 246, 0.5);
}
.xnova-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 10px;
    margin-bottom: 10px;
    border-bottom: 1px solid var(--border-color);
    font-size: 12px;
    font-weight: 700;
    color: var(--text-title);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.xnova-card-header span.icon {
    color: var(--accent-cyan);
    margin-right: 8px;
}

/* ============================================================ */
/* ====== RADAR TÁCTICO COMPACTO (OVERVIEW) =================== */
/* ============================================================ */
.fleet-card {
    background: rgba(0, 0, 0, 0.2);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    margin-bottom: 6px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    overflow: visible;
    position: relative;
}

.fleet-card.is-attack { border-left: 3px solid var(--accent-red); }
.fleet-card.is-incoming { border-left: 3px solid var(--accent-red); background: rgba(239, 68, 68, 0.08); }
.fleet-card.is-espionage { border-left: 3px solid var(--accent-gold); }
.fleet-card.is-deploy { border-left: 3px solid var(--accent-blue); }
.fleet-card.is-transport { border-left: 3px solid var(--accent-green); }
.fleet-card.is-expedition { border-left: 3px solid var(--accent-cyan); }

.fleet-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 3px 8px;
    background: rgba(0,0,0,0.3);
    border-bottom: 1px solid rgba(255,255,255,0.03);
    font-size: 9px;
    font-weight: 700;
    text-transform: uppercase;
}

.is-attack .fleet-mission { color: var(--accent-red); text-shadow: 0 0 5px var(--accent-red); }
.is-incoming .fleet-mission { color: var(--accent-red); text-shadow: 0 0 5px var(--accent-red); font-weight: 900; }
.is-espionage .fleet-mission { color: var(--accent-gold); text-shadow: 0 0 5px var(--accent-gold); }
.is-deploy .fleet-mission { color: var(--accent-blue); text-shadow: 0 0 5px var(--accent-blue); }
.is-transport .fleet-mission { color: var(--accent-green); text-shadow: 0 0 5px var(--accent-green); }
.is-expedition .fleet-mission { color: var(--accent-cyan); text-shadow: 0 0 5px var(--accent-cyan); }

.fleet-radar { 
    padding: 4px 10px; 
    display: flex; 
    align-items: center; 
    justify-content: space-between; 
    position: relative; 
    height: 40px;
}
.planet-node { 
    display: flex; 
    flex-direction: column; 
    align-items: center; 
    justify-content: center; 
    z-index: 2; 
    text-align: center; 
    width: 70px; 
}
.planet-icon { font-size: 16px; line-height: 1; margin-bottom: 0px; filter: drop-shadow(0 0 5px rgba(255,255,255,0.2)); }
.planet-name { font-size: 7px; font-weight: bold; color: #fff; text-transform: uppercase; white-space: nowrap; }
.planet-coords { font-size: 8px; color: var(--text-muted); font-family: 'Courier New', monospace; margin-top: 0px; }

.radar-track-container { flex: 1; position: relative; height: 100%; margin: 0 5px; display: flex; align-items: center; }
.radar-line { position: absolute; top: 50%; left: 0; width: 100%; height: 1px; background-image: linear-gradient(to right, var(--border-color) 50%, transparent 50%); background-size: 6px 100%; z-index: 1; transform: translateY(-50%); }

.center-node { position: absolute; left: 50%; top: 50%; transform: translate(-50%, -50%); z-index: 2; cursor: help; }
.center-node .planet-name { color: #fff; }

.end-node { position: absolute; right: 0; top: 50%; transform: translateY(-50%); z-index: 2; opacity: 0.5; }

.traveler-container { position: absolute; top: 50%; left: 3%; transform: translate(-50%, -50%); display: flex; flex-direction: column; align-items: center; z-index: 3; transition: left 1s linear; cursor: help; }
.traveler-ship { font-size: 18px; line-height: 1; filter: drop-shadow(0 0 5px rgba(255,255,255,0.8)); }
.is-incoming .traveler-ship { filter: drop-shadow(0 0 8px var(--accent-red)); }
.is-expedition .traveler-ship { filter: drop-shadow(0 0 8px var(--accent-cyan)); }
.is-attack .traveler-ship { filter: drop-shadow(0 0 8px var(--accent-red)); }
.traveler-timer { margin-top: 1px; font-size: 8px; font-weight: bold; color: var(--accent-gold); background: rgba(0,0,0,0.9); padding: 0px 4px; border-radius: 3px; border: 1px solid rgba(255, 184, 0, 0.5); white-space: nowrap; font-family: 'Courier New', monospace; }

/* ====== TOOLTIP PERSONALIZADO (Desglose) ====== */
.hud-tooltip {
    position: absolute;
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-bottom: 10px;
    background: rgba(15, 23, 42, 0.95);
    border: 1px solid var(--accent-cyan);
    border-radius: 6px;
    padding: 8px 10px;
    width: 190px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8), 0 0 10px rgba(0, 224, 255, 0.2);
    opacity: 0;
    visibility: hidden;
    transition: all 0.2s ease-in-out;
    z-index: 100;
    pointer-events: none;
    font-size: 10px;
    color: var(--text-main);
    text-align: left;
}
.hud-tooltip::after {
    content: '';
    position: absolute;
    top: 100%;
    left: 50%;
    margin-left: -6px;
    border-width: 6px;
    border-style: solid;
    border-color: var(--accent-cyan) transparent transparent transparent;
}
.traveler-container:hover .hud-tooltip {
    opacity: 1;
    visibility: visible;
    margin-bottom: 6px;
}
.tooltip-title {
    font-weight: bold;
    color: var(--accent-cyan);
    border-bottom: 1px solid var(--border-color);
    padding-bottom: 3px;
    margin-bottom: 4px;
    text-transform: uppercase;
    font-size: 9px;
    letter-spacing: 0.5px;
}
.tooltip-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 2px;
}
.tooltip-row span:last-child {
    font-family: 'Courier New', monospace;
    font-weight: bold;
    color: #fff;
}
.tooltip-section-title {
    color: var(--accent-gold);
    margin-top: 6px;
    margin-bottom: 3px;
    font-weight: bold;
    font-size: 9px;
}

/* ====== TARJETA DEL PLANETA ====== */
.xnova-planet-card {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 15px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    position: relative;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    gap: 15px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-planet-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid var(--border-color);
    padding-bottom: 12px;
}
.xnova-planet-header .title-group {
    display: flex;
    align-items: center;
    gap: 12px;
}
.xnova-planet-header .title-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    border-radius: 8px;
    background: rgba(0, 224, 255, 0.1);
    color: var(--accent-cyan);
    border: 1px solid var(--accent-cyan);
    font-size: 16px;
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.2);
}
.xnova-planet-header .title-text {
    font-size: 18px;
    font-weight: 800;
    color: #fff;
    letter-spacing: 0.5px;
}
.xnova-planet-header .edit-btn {
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 10px;
    font-weight: 700;
    background: rgba(0, 224, 255, 0.1);
    padding: 4px 10px;
    border-radius: 6px;
    border: 1px solid rgba(0, 224, 255, 0.4);
    transition: all 0.2s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-left: 10px;
}
.xnova-planet-header .edit-btn:hover {
    background: rgba(0, 224, 255, 0.2);
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.5);
}
.xnova-planet-header .action-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid rgba(0, 224, 255, 0.4);
    color: var(--accent-cyan);
    padding: 5px 10px;
    border-radius: 6px;
    font-size: 10px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    text-decoration: none;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.1);
}
.xnova-planet-body {
    display: flex;
    gap: 20px;
    align-items: flex-start;
}
.xnova-planet-image {
    width: 180px;
    height: 180px;
    border-radius: 12px;
    background-size: cover;
    background-position: center;
    border: 2px solid rgba(0, 224, 255, 0.4);
    box-shadow: 0 0 25px rgba(0, 224, 255, 0.2);
    flex-shrink: 0;
    position: relative;
}
.xnova-planet-image .planet-badge {
    position: absolute;
    bottom: 10px;
    left: 10px;
    background: rgba(0, 0, 0, 0.8);
    border: 1px solid rgba(0, 224, 255, 0.5);
    border-radius: 6px;
    padding: 3px 10px;
    font-size: 10px;
    font-weight: 700;
    color: var(--accent-cyan);
    text-transform: uppercase;
    letter-spacing: 1px;
}
.xnova-planet-stats {
    flex: 1;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}
.xnova-stat-item {
    display: flex;
    align-items: center;
    gap: 12px;
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 10px;
    padding: 12px;
    transition: all 0.2s ease;
}
.xnova-stat-item:hover {
    background: rgba(0, 0, 0, 0.5);
    border-color: rgba(0, 224, 255, 0.3);
}
.xnova-stat-item .icon {
    font-size: 20px;
    color: var(--accent-cyan);
    width: 26px;
    text-align: center;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
}
.xnova-stat-item .info {
    display: flex;
    flex-direction: column;
    flex: 1;
}
.xnova-stat-item .label {
    font-size: 9px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 600;
}
.xnova-stat-item .value {
    font-size: 13px;
    font-weight: 700;
    color: #fff;
    margin-top: 4px;
}
.xnova-stat-item .value a {
    color: var(--accent-cyan);
    text-decoration: none;
}

/* ============================================================== */
/* ============ 🆕 ASTROIO v6.5 - BLOQUE DE CLIMA ============== */
/* ============================================================== */
.xnova-clima-block {
    background: linear-gradient(135deg, rgba(15, 30, 50, 0.9), rgba(8, 20, 35, 0.95));
    border: 1px solid rgba(0, 224, 255, 0.35);
    border-radius: 12px;
    padding: 14px 16px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(0, 224, 255, 0.05);
    display: flex;
    flex-direction: column;
    gap: 10px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-clima-header {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 11px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--accent-cyan);
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 6px;
}
.xnova-clima-section {
    display: flex;
    align-items: center;
    gap: 14px;
    flex-wrap: wrap;
}
.xnova-clima-emoji {
    font-size: 34px;
    line-height: 1;
    filter: drop-shadow(0 0 10px rgba(0, 224, 255, 0.5));
    flex-shrink: 0;
}
.xnova-clima-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 3px;
    min-width: 0;
}
.xnova-clima-name {
    font-size: 14px;
    font-weight: 800;
    color: #ffffff;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
    letter-spacing: 0.5px;
}
.xnova-clima-desc {
    font-size: 11px;
    color: var(--text-muted);
    font-style: italic;
    line-height: 1.3;
}
.xnova-clima-factors {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-top: 4px;
}
.xnova-clima-factor {
    display: inline-flex;
    align-items: center;
    gap: 3px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 6px;
    padding: 2px 8px;
    font-size: 10px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    color: #fff;
}
.xnova-clima-factor.positive { color: var(--accent-green); border-color: rgba(74, 255, 136, 0.4); }
.xnova-clima-factor.negative { color: var(--accent-red); border-color: rgba(239, 68, 68, 0.4); }
.xnova-clima-factor.neutral { color: var(--text-muted); }
.xnova-clima-predict {
    display: flex;
    align-items: center;
    gap: 8px;
    padding-top: 8px;
    border-top: 1px dashed rgba(0, 224, 255, 0.2);
    font-size: 11px;
    color: var(--text-muted);
}
.xnova-clima-predict b {
    color: var(--accent-gold);
}
.xnova-clima-predict .pred-emoji {
    font-size: 18px;
    line-height: 1;
    filter: drop-shadow(0 0 6px rgba(255, 204, 0, 0.4));
}
.xnova-clima-alert {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.3px;
}
.xnova-clima-alert.danger {
    background: rgba(239, 68, 68, 0.12);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: #ff8f8f;
}
.xnova-clima-alert.success {
    background: rgba(74, 255, 136, 0.1);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: #88ffaa;
}

@media (max-width: 700px) {
    .xnova-clima-block { padding: 10px 12px; gap: 8px; }
    .xnova-clima-emoji { font-size: 26px; }
    .xnova-clima-name { font-size: 12px; }
    .xnova-clima-desc { font-size: 10px; }
    .xnova-clima-factor { font-size: 9px; padding: 1px 6px; }
}

/* ====== GRID DE ACCIONES ====== */
.xnova-action-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
}
.xnova-action-card {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
    transition: all 0.25s ease;
    display: flex;
    flex-direction: column;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-action-card:hover {
    border-color: var(--accent-cyan);
    transform: translateY(-4px);
    box-shadow: 0 8px 25px rgba(0, 224, 255, 0.2);
}
.xnova-action-image {
    height: 80px;
    background-size: cover;
    background-position: center;
    position: relative;
    border-bottom: 1px solid var(--border-color);
    background-color: rgba(11, 16, 30, 0.75);
}
.xnova-action-image::after {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(to top, rgba(15, 23, 42, 0.85), transparent);
}
.xnova-action-content {
    padding: 10px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    flex: 1;
}
.xnova-action-title {
    font-size: 12px;
    font-weight: 700;
    color: #fff;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.xnova-action-status {
    font-size: 10px;
    color: var(--text-muted);
    min-height: 28px;
}
.xnova-action-status b {
    color: var(--accent-gold);
}
.xnova-action-btn {
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.85), rgba(15, 23, 42, 0.85));
    border: 1px solid var(--border-color);
    color: var(--accent-cyan);
    padding: 7px;
    border-radius: 6px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    cursor: pointer;
    transition: all 0.2s;
    text-align: center;
    text-decoration: none;
    display: block;
    margin-top: auto;
}
.xnova-action-btn:hover {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.4);
}

/* ====== ESTILOS PARA WIDGETS ====== */
.xnova-main .ov_pve_section,
.xnova-main .ov_pvp_section,
.xnova-main .ov_raffles_section,
.xnova-main .ov_lottery_section,
.xnova-main .ov_events_section {
    margin-top: 0;
}

.xnova-main .ov_events_title,
.xnova-main .ov_raffles_title,
.xnova-main .ov_lottery_title,
.xnova-main .ov_pve_title,
.xnova-main .ov_pvp_title {
    padding: 10px 15px !important;
    border-radius: 10px !important;
    font-weight: 700 !important;
    font-size: 12px !important;
    letter-spacing: 1px !important;
    text-transform: uppercase !important;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5) !important;
    margin-bottom: 10px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    border-left: 4px solid var(--accent-blue) !important;
    background: linear-gradient(135deg, rgba(15, 23, 42, 0.85), rgba(30, 41, 59, 0.85)) !important;
    color: #ffffff !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-main .ov_pve_title { border-left-color: var(--accent-purple) !important; background: linear-gradient(135deg, rgba(46, 16, 101, 0.85), rgba(30, 27, 75, 0.85)) !important; }
.xnova-main .ov_pvp_title { border-left-color: var(--accent-red) !important; background: linear-gradient(135deg, rgba(74, 13, 13, 0.85), rgba(26, 35, 50, 0.85)) !important; }
.xnova-main .ov_events_title { border-left-color: var(--accent-cyan) !important; background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important; }
.xnova-main .ov_raffles_title { border-left-color: var(--accent-cyan) !important; background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important; }
.xnova-main .ov_lottery_title { border-left-color: var(--accent-gold) !important; background: linear-gradient(135deg, rgba(74, 20, 140, 0.85), rgba(0, 119, 204, 0.85)) !important; }
.xnova-sidebar .boosters_title { border-left-color: var(--accent-gold) !important; background: linear-gradient(135deg, rgba(74, 20, 140, 0.85), rgba(0, 119, 204, 0.85)) !important; padding: 8px 12px !important; font-size: 11px !important; margin-bottom: 8px !important; }

.xnova-main .ov_events_all, .xnova-main .ov_raffles_all, .xnova-main .ov_lottery_all, .xnova-main .ov_pve_all, .xnova-main .ov_pvp_all {
    font-size: 10px !important; font-weight: 600 !important; text-decoration: none !important; transition: all 0.25s ease !important; color: var(--accent-cyan) !important;
}
.xnova-main .ov_events_all:hover, .xnova-main .ov_raffles_all:hover, .xnova-main .ov_lottery_all:hover, .xnova-main .ov_pve_all:hover, .xnova-main .ov_pvp_all:hover {
    color: #ffffff !important; text-shadow: 0 0 8px rgba(0, 224, 255, 0.8) !important;
}

.xnova-main .ov_events_grid, .xnova-main .ov_raffles_grid, .xnova-main .ov_lottery_grid, .xnova-main .ov_pve_grid, .xnova-main .ov_pvp_grid {
    display: flex !important; flex-wrap: wrap !important; gap: 10px !important; background: transparent !important; border: none !important; padding: 0 !important;
}

.xnova-user-card {
    background: repeating-linear-gradient(
        -45deg,
        rgba(11, 16, 30, 0.70),
        rgba(11, 16, 30, 0.70) 10px,
        rgba(14, 22, 40, 0.70) 10px,
        rgba(14, 22, 40, 0.70) 20px
    );
    border: 1px solid rgba(0, 224, 255, 0.3);
    border-radius: 12px;
    padding: 15px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(0, 224, 255, 0.05);
    margin-bottom: 12px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-user-card .uc-header {
    font-size: 14px;
    font-weight: 700;
    color: #fff;
    letter-spacing: 0.5px;
    padding-bottom: 10px;
    margin-bottom: 10px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}
.xnova-user-card .uc-stats {
    display: flex;
    flex-direction: column;
    gap: 8px;
}
.xnova-user-card .uc-stat-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 12px;
}
.xnova-user-card .uc-stat-row .lbl {
    color: var(--text-muted);
    font-weight: 500;
}
.xnova-user-card .uc-stat-row .val {
    color: #fff;
    font-weight: 700;
}
.xnova-user-card .uc-stat-row .val.cyan {
    color: var(--accent-cyan);
}

.xnova-sidebar .boosters_section { margin-top: 0; }
.xnova-sidebar .boosters_grid {
    display: grid !important;
    grid-template-columns: repeat(2, 1fr) !important;
    gap: 8px !important;
}

.xnova-sidebar .booster_card {
    min-width: 0 !important;
    flex-direction: column !important;
    align-items: flex-start !important;
    padding: 10px !important;
    background: var(--bg-card) !important;
    border: 1px solid var(--border-color) !important;
    border-radius: 10px !important;
    box-shadow: 0 4px 15px rgba(0,0,0,0.4) !important;
    min-height: 85px !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    transition: all 0.3s ease !important;
}

.xnova-sidebar .booster_card.active {
    border: 1px solid #fbbf24 !important;
    border-left: 4px solid #fde047 !important;
    background: linear-gradient(135deg, rgba(120, 53, 15, 0.75), rgba(180, 83, 9, 0.75)) !important;
    box-shadow:
        0 0 20px rgba(251, 191, 36, 0.55),
        0 0 35px rgba(251, 191, 36, 0.25),
        inset 0 0 20px rgba(251, 191, 36, 0.15) !important;
    animation: booster-active-glow 2s ease-in-out infinite;
}
@keyframes booster-active-glow {
    0%, 100% {
        box-shadow:
            0 0 20px rgba(251, 191, 36, 0.55),
            0 0 35px rgba(251, 191, 36, 0.25),
            inset 0 0 20px rgba(251, 191, 36, 0.15);
    }
    50% {
        box-shadow:
            0 0 28px rgba(251, 191, 36, 0.85),
            0 0 45px rgba(251, 191, 36, 0.45),
            inset 0 0 25px rgba(251, 191, 36, 0.25);
    }
}
.xnova-sidebar .booster_card.active .booster_icon {
    filter: drop-shadow(0 0 10px rgba(251, 191, 36, 1)) !important;
    animation: booster-icon-pulse 1.5s ease-in-out infinite;
}
@keyframes booster-icon-pulse {
    0%, 100% { transform: scale(1); filter: drop-shadow(0 0 10px rgba(251, 191, 36, 1)); }
    50%      { transform: scale(1.1); filter: drop-shadow(0 0 16px rgba(253, 224, 71, 1)); }
}
.xnova-sidebar .booster_card.active .booster_name {
    color: #fef08a !important;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.9) !important;
    font-weight: 800 !important;
}
.xnova-sidebar .booster_card.active .booster_bonus {
    color: #fde047 !important;
    text-shadow: 0 0 12px rgba(251, 191, 36, 1) !important;
    font-weight: 800 !important;
    font-size: 14px !important;
}
.xnova-sidebar .booster_card.active .state_active {
    background: rgba(251, 191, 36, 0.3) !important;
    color: #fef3c7 !important;
    border: 1px solid #fbbf24 !important;
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.6) !important;
    font-weight: 800 !important;
}

.xnova-sidebar .booster_card.inactive {
    border-left: 4px solid #2a3441 !important;
    opacity: 0.75 !important;
    background: var(--bg-card) !important;
    box-shadow: 0 4px 15px rgba(0,0,0,0.4) !important;
}
.xnova-sidebar .booster_card.inactive .booster_icon { filter: grayscale(60%) opacity(0.65) !important; }
.xnova-sidebar .booster_card.inactive .booster_name { color: #94a3b8 !important; font-weight: 600 !important; }
.xnova-sidebar .booster_card.inactive .booster_bonus { color: #64748b !important; font-weight: 600 !important; }
.xnova-sidebar .booster_card.inactive .state_inactive {
    background: rgba(120, 120, 120, 0.15) !important;
    color: #94a3b8 !important;
    border: 1px solid #2a3441 !important;
    font-weight: 600 !important;
}

.xnova-sidebar .booster_icon { font-size: 20px !important; margin-bottom: 4px !important; }
.xnova-sidebar .booster_name { font-size: 11px !important; font-weight: 700 !important; color: #fff !important; white-space: normal !important; line-height: 1.2 !important; margin-bottom: 3px !important; }
.xnova-sidebar .booster_bonus { font-size: 13px !important; font-weight: 700 !important; color: var(--accent-gold) !important; font-family: 'Courier New', monospace !important; }
.xnova-sidebar .booster_state { text-align: left !important; margin-top: 6px !important; width: 100%; }
.xnova-sidebar .state_active { font-size: 9px !important; padding: 2px 5px !important; }
.xnova-sidebar .state_inactive { font-size: 9px !important; padding: 2px 5px !important; }

.xnova-main .ov_ev_card, .xnova-main .ov_raf_card, .xnova-main .ov_lot_card, .xnova-main .ov_pve_card, .xnova-main .ov_pvp_card {
    background: var(--bg-card) !important;
    border: 1px solid var(--border-color) !important;
    border-radius: 10px !important;
    padding: 10px !important;
    text-decoration: none !important;
    display: flex !important;
    flex-direction: column !important;
    gap: 6px !important;
    transition: all 0.25s ease !important;
    position: relative !important;
    flex: 1 1 0 !important;
    min-width: 180px !important;
    box-shadow: 0 4px 15px rgba(0,0,0,0.4) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.xnova-main .ov_ev_card:hover, .xnova-main .ov_raf_card:hover, .xnova-main .ov_lot_card:hover, .xnova-main .ov_pve_card:hover, .xnova-main .ov_pvp_card:hover {
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 6px 20px rgba(0, 224, 255, 0.25) !important;
    transform: translateY(-3px) !important;
}

.xnova-main .ov_ev_card.ov_ev_daily  { border-left: 4px solid var(--accent-blue) !important; }
.xnova-main .ov_ev_card.ov_ev_weekly { border-left: 4px solid var(--accent-purple) !important; }
.xnova-main .ov_ev_card.ov_ev_elite  { border-left: 4px solid var(--accent-gold) !important; }
.xnova-main .ov_raf_card { border-left: 4px solid var(--accent-cyan) !important; }
.xnova-main .ov_raf_card.ov_raf_warn { border-left-color: var(--accent-gold) !important; }
.xnova-main .ov_raf_card.ov_raf_danger { border-left-color: var(--accent-red) !important; }
.xnova-main .ov_lot_card { border-left: 4px solid var(--accent-gold) !important; }
.xnova-main .ov_pve_card.ov_pve_crisis  { border-left: 4px solid var(--accent-purple) !important; }
.xnova-main .ov_pve_card.ov_pve_empire  { border-left: 4px solid var(--accent-gold) !important; }
.xnova-main .ov_pve_card.ov_pve_rewards { border-left: 4px solid var(--accent-green) !important; }
.xnova-main .ov_pve_card.ov_pve_boss    { border-left: 4px solid var(--accent-blue) !important; }
.xnova-main .ov_pvp_card.ov_pvp_arenas      { border-left: 4px solid var(--accent-red) !important; }
.xnova-main .ov_pvp_card.ov_pvp_tournament  { border-left: 4px solid var(--accent-gold) !important; }
.xnova-main .ov_pvp_card.ov_pvp_myarena     { border-left: 4px solid var(--accent-blue) !important; }
.xnova-main .ov_pvp_card.ov_pvp_stats       { border-left: 4px solid var(--accent-green) !important; }

.xnova-main .ov_pve_card.state-active, .xnova-main .ov_pvp_card.state-active {
    box-shadow: 0 0 20px rgba(239, 68, 68, 0.4) !important;
    border-color: var(--accent-red) !important;
    animation: pulse-active 2s infinite;
}
@keyframes pulse-active {
    0% { box-shadow: 0 0 15px rgba(239, 68, 68, 0.3); }
    50% { box-shadow: 0 0 25px rgba(239, 68, 68, 0.7); }
    100% { box-shadow: 0 0 15px rgba(239, 68, 68, 0.3); }
}

.xnova-main .ov_ev_header, .xnova-main .ov_raf_header, .xnova-main .ov_lot_header, .xnova-main .ov_pve_header, .xnova-main .ov_pvp_header {
    display: flex !important; align-items: center !important; gap: 8px !important; min-width: 0 !important;
}
.xnova-main .ov_ev_icon, .xnova-main .ov_raf_icon, .xnova-main .ov_lot_icon, .xnova-main .ov_pve_icon, .xnova-main .ov_pvp_icon {
    display: inline-flex !important; align-items: center !important; justify-content: center !important;
    width: 28px !important; height: 28px !important; border-radius: 8px !important; font-size: 14px !important; flex-shrink: 0 !important;
    border: 1px solid var(--border-color) !important;
    background: rgba(255,255,255,0.05) !important;
}
.xnova-main .ov_ev_icon { color: var(--accent-cyan); border-color: var(--accent-cyan); background: rgba(0, 224, 255, 0.1); }
.xnova-main .ov_raf_icon { color: var(--accent-cyan); border-color: var(--accent-cyan); background: rgba(0, 224, 255, 0.1); }
.xnova-main .ov_lot_icon { color: var(--accent-gold); border-color: var(--accent-gold); background: rgba(255, 204, 0, 0.1); }
.xnova-main .ov_pve_icon { color: var(--accent-purple); border-color: var(--accent-purple); background: rgba(170, 50, 255, 0.1); }
.xnova-main .ov_pvp_icon { color: var(--accent-red); border-color: var(--accent-red); background: rgba(255, 50, 50, 0.1); }

.xnova-main .ov_ev_name, .xnova-main .ov_raf_name, .xnova-main .ov_lot_name, .xnova-main .ov_pve_name, .xnova-main .ov_pvp_name {
    font-size: 10px !important; font-weight: 700 !important; color: #ffffff !important; white-space: nowrap !important; overflow: hidden !important; text-overflow: ellipsis !important; flex: 1 !important; min-width: 0 !important;
}

.xnova-main .ov_ev_progress_bar, .xnova-main .ov_raf_progress_bar, .xnova-main .ov_lot_progress_bar {
    height: 5px !important; background: rgba(0, 0, 0, 0.6) !important; border-radius: 3px !important; overflow: hidden !important; border: 1px solid rgba(255, 255, 255, 0.1) !important;
}
.xnova-main .ov_ev_progress_fill, .xnova-main .ov_raf_progress_fill, .xnova-main .ov_lot_progress_fill {
    height: 100% !important; transition: width 0.4s ease !important;
    box-shadow: 0 0 8px rgba(255, 255, 255, 0.3) inset !important;
}
.xnova-main .ov_ev_progress_fill { background: linear-gradient(90deg, #0066cc, #00ccff) !important; }
.xnova-main .ov_ev_progress_fill.complete { background: linear-gradient(90deg, #008844, #66ff99) !important; }
.xnova-main .ov_raf_progress_fill { background: linear-gradient(90deg, #008888, #00ffdd) !important; }
.xnova-main .ov_lot_progress_fill { background: linear-gradient(90deg, #aa7700, #ffcc00) !important; }

.xnova-main .ov_ev_footer, .xnova-main .ov_raf_footer, .xnova-main .ov_lot_footer, .xnova-main .ov_pve_footer, .xnova-main .ov_pvp_footer {
    display: flex !important; justify-content: space-between !important; align-items: center !important; font-size: 9px !important; font-family: 'Courier New', monospace !important; gap: 8px !important; margin-top: 4px;
}
.xnova-main .ov_ev_progress, .xnova-main .ov_raf_time, .xnova-main .ov_lot_time, .xnova-main .ov_pve_time, .xnova-main .ov_pvp_time { color: var(--text-muted) !important; font-weight: 700 !important; }
.xnova-main .ov_ev_reward, .xnova-main .ov_raf_price, .xnova-main .ov_lot_price, .xnova-main .ov_pve_status, .xnova-main .ov_pvp_status { color: var(--accent-gold) !important; font-weight: 700 !important; white-space: nowrap !important; overflow: hidden !important; text-overflow: ellipsis !important; max-width: 55% !important; }
.xnova-main .ov_raf_time.warn, .xnova-main .ov_lot_time.warn, .xnova-main .ov_pve_time.warn, .xnova-main .ov_pvp_time.warn { color: var(--accent-gold) !important; }
.xnova-main .ov_raf_time.danger, .xnova-main .ov_lot_time.danger, .xnova-main .ov_pve_time.danger, .xnova-main .ov_pvp_time.danger { color: var(--accent-red) !important; animation: pulse-text 1.5s infinite; }
.xnova-main .ov_pve_time.off, .xnova-main .ov_pvp_time.off { color: var(--text-muted) !important; }
@keyframes pulse-text { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
.xnova-main .ov_pve_status.highlight, .xnova-main .ov_pvp_status.highlight { color: var(--accent-green) !important; text-shadow: 0 0 8px rgba(74, 255, 136, 0.5) !important; }

/* ====== RESPONSIVE ====== */
@media (max-width: 1100px) {
    .xnova-layout { flex-direction: column; }
    .xnova-sidebar { width: 100%; display: grid; grid-template-columns: 1fr 1fr; }
    .xnova-action-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 700px) {
    .xnova-planet-body { flex-direction: column; align-items: stretch !important; gap: 12px !important; }
    .xnova-planet-image { width: 100% !important; height: 140px !important; }
    .xnova-planet-stats { grid-template-columns: repeat(2, 1fr) !important; width: 100% !important; gap: 6px !important; }
    .xnova-stat-item { padding: 8px !important; gap: 6px !important; }
    .xnova-stat-item .icon { font-size: 15px !important; width: 18px !important; }
    .xnova-stat-item .label { font-size: 8px !important; letter-spacing: 0.5px !important; }
    .xnova-stat-item .value { font-size: 10px !important; margin-top: 2px !important; }
    .xnova-sidebar { grid-template-columns: 1fr; }
    .xnova-action-grid { grid-template-columns: 1fr; }
    .xnova-main .ov_ev_card, .xnova-main .ov_raf_card, .xnova-main .ov_lot_card, .xnova-main .ov_pve_card, .xnova-main .ov_pvp_card { min-width: 100%; }
    .xnova-sidebar .boosters_grid { grid-template-columns: 1fr !important; }

    .xnova-sidebar {
        display: flex !important;
        flex-direction: column !important;
        gap: 8px !important;
        width: 100% !important;
    }
    .xnova-user-card {
        box-sizing: border-box !important;
        width: 100% !important;
        max-width: 100% !important;
    }
    .xnova-sidebar .boosters_section { width: 100% !important; align-self: flex-start !important; }

    .xnova-action-grid { grid-template-columns: repeat(2, 1fr) !important; gap: 8px !important; }
    .xnova-action-image { height: 55px !important; }
    .xnova-action-content { padding: 7px !important; gap: 4px !important; }
    .xnova-action-title { font-size: 10px !important; letter-spacing: 0.3px !important; }
    .xnova-action-status { font-size: 8px !important; min-height: 22px !important; }
    .xnova-action-btn { font-size: 8px !important; padding: 6px 4px !important; }

    .xnova-planet-card { padding: 10px !important; gap: 10px !important; }
    .xnova-planet-header { padding-bottom: 8px !important; }
    .xnova-planet-header .title-icon { width: 26px !important; height: 26px !important; font-size: 13px !important; }
    .xnova-planet-header .title-text { font-size: 14px !important; }
    .xnova-planet-header .edit-btn { font-size: 8px !important; padding: 3px 6px !important; margin-left: 4px !important; }
    .xnova-planet-header .action-btn { font-size: 9px !important; padding: 4px 7px !important; }

    .xnova-main .ov_events_grid,
    .xnova-main .ov_raffles_grid,
    .xnova-main .ov_lottery_grid,
    .xnova-main .ov_pve_grid,
    .xnova-main .ov_pvp_grid {
        display: grid !important;
        grid-template-columns: repeat(2, 1fr) !important;
        gap: 6px !important;
    }
    .xnova-main .ov_ev_card,
    .xnova-main .ov_raf_card,
    .xnova-main .ov_lot_card,
    .xnova-main .ov_pve_card,
    .xnova-main .ov_pvp_card {
        min-width: 0 !important; max-width: none !important; flex: none !important;
        padding: 7px !important; gap: 4px !important;
    }

    .xnova-user-card { padding: 10px !important; margin-bottom: 8px !important; }
    .xnova-user-card .uc-header { font-size: 12px !important; padding-bottom: 6px !important; margin-bottom: 6px !important; }
    .xnova-user-card .uc-stat-row { font-size: 10px !important; }

    .xnova-sidebar .boosters_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 5px !important; }
    .xnova-sidebar .booster_card { min-height: 70px !important; padding: 7px !important; }
    .xnova-sidebar .booster_icon { font-size: 16px !important; }
    .xnova-sidebar .booster_name { font-size: 9px !important; }
    .xnova-sidebar .booster_bonus { font-size: 11px !important; }

    .xnova-wrapper { padding: 8px !important; border-radius: 10px !important; }

    /* Radar en móvil */
    .fleet-radar { padding: 5px 2px; height: 35px; }
    .planet-icon { font-size: 14px; }
    .traveler-ship { font-size: 16px; }
    .planet-name { font-size: 6px; }
    .planet-coords { font-size: 7px; }
    .traveler-timer { font-size: 7px; padding: 0px 2px; margin-top: 0px; }
}
</style>

<div class="xnova-wrapper">

    <!-- ================= BARRA SUPERIOR ================= -->
    <div class="xnova-topbar">
        <div class="onligne">
            <i class="fas fa-user"></i> {$LNG.ov_online_user} : <span style="font-weight: bold; color: lime;">{$onlineUser + $AdminsOnline|@count|number}</span>
        </div>
        <span><i class="fas fa-users"></i> {$LNG.ov_admins_online} : {foreach $AdminsOnline as $ID => $Name}{if !$Name@first}&nbsp;&bull;&nbsp;{/if}<a href="#" onclick="return Dialog.PM({$ID})">{$Name}</a>{foreachelse}{$LNG.ov_no_admins_online}{/foreach}</span>
        <div class="ticket">
            <a href="game.php?page=ticket"><i class="fas fa-ticket-alt"></i> {$LNG.ov_ticket}</a>
        </div>
    </div>

    <!-- ================= HERO BANNER ================= -->
    <div class="xnova-hero">
        <h1>XNOVA AstroIO</h1>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * 🆕 ASTROIO - BANNER BOOST FIN DE SEMANA
     * ═══════════════════════════════════════════════════════════ *}
    {if isset($weekend_boost) && $weekend_boost.show == 1}
    <div class="xb_banner"
         id="xb_banner"
         data-phase="{$weekend_boost.phase}"
         data-seconds="{$weekend_boost.seconds_left}"
         data-multiplier="{$weekend_boost.multiplier}">
        <div class="xb_content">
            <span class="xb_icon">🎉</span>
            <span class="xb_text">
                {if $weekend_boost.phase == 'active'}
                    Boost Activo ×{$weekend_boost.multiplier} &mdash; Termina en: <span id="xb_timer">--</span>
                {else}
                    Boost Fin de Semana en: <span id="xb_timer">--</span>
                {/if}
            </span>
        </div>
        <button type="button" class="xb_close" onclick="xbDismiss(); return false;" title="Cerrar">✖</button>
    </div>
    {/if}

    <!-- ================= LAYOUT DE 2 COLUMNAS ================= -->
    <div class="xnova-layout">

        <!-- ================= COLUMNA PRINCIPAL ================= -->
        <div class="xnova-main">

            <!-- TARJETA DEL PLANETA PRINCIPAL -->
            <div class="xnova-planet-card">
                <div class="xnova-planet-header">
                    <div class="title-group">
                        <div class="title-icon"><i class="fas fa-globe"></i></div>
                        <div class="title-text">Planeta Principal</div>
                        <a href="#" onclick="return Dialog.PlanetAction();" class="edit-btn">Cambiar Nombre/Eliminar</a>
                    </div>
                    <a href="game.php?page=galaxy&amp;galaxy={$galaxy}&amp;system={$system}" class="action-btn"><i class="fas fa-map-marker-alt"></i> [{$galaxy}:{$system}:{$planet}]</a>
                </div>

                <div class="xnova-planet-body">
                    <div class="xnova-planet-image" style="background-image: url({$dpath}planeten/{$planetimage}.jpg);">
                        <div class="planet-badge">{$LNG["type_planet_{$planet_type}"]}</div>
                    </div>
                    
                    <div class="xnova-planet-stats">
                        <div class="xnova-stat-item">
                            <div class="icon"><i class="fas fa-ruler-combined"></i></div>
                            <div class="info">
                                <span class="label">{$LNG.ov_diameter}</span>
                                <span class="value">{$planet_diameter} {$LNG.ov_distance_unit}</span>
                            </div>
                        </div>
                        <div class="xnova-stat-item">
                            <div class="icon"><i class="fas fa-layer-group"></i></div>
                            <div class="info">
                                <span class="label">Campos</span>
                                <span class="value"><a href="#">{$planet_field_current}</a> / <a href="#">{$planet_field_max}</a></span>
                            </div>
                        </div>
                        <div class="xnova-stat-item">
                            <div class="icon"><i class="fas fa-thermometer-half"></i></div>
                            <div class="info">
                                <span class="label">{$LNG.ov_temperature}</span>
                                <span class="value">{$planet_temp_min}°C a {$planet_temp_max}°C</span>
                            </div>
                        </div>
                        <div class="xnova-stat-item">
                            <div class="icon"><i class="fas fa-map-marker-alt"></i></div>
                            <div class="info">
                                <span class="label">{$LNG.ov_position}</span>
                                <span class="value"><a href="game.php?page=galaxy&amp;galaxy={$galaxy}&amp;system={$system}">[{$galaxy}:{$system}:{$planet}]</a></span>
                            </div>
                        </div>
                    </div>
                </div>

                {* ═══════════════════════════════════════════════════════════
                 * 🆕 ASTROIO v6.5 - BLOQUE DE CLIMA
                 * Muestra el clima actual y la predicción del planeta y la luna.
                 * 🆕 ASTROIO v6.6 - BUFF CLIMÁTICO (Añadido al final del bloque)
                 * ═══════════════════════════════════════════════════════════ *}
                {if isset($clima_planeta) && $clima_planeta}
                <div class="xnova-clima-block">
                    <div class="xnova-clima-header">
                        🌦️ Clima del Planeta
                    </div>

                    {* ─── Clima actual del planeta ─── *}
                    <div class="xnova-clima-section">
                        {assign var="cp_emoji" value="❓"}
                        {if $clima_planeta.clave == 'despejado'}{assign var="cp_emoji" value="☀️"}
                        {elseif $clima_planeta.clave == 'brisa_solar'}{assign var="cp_emoji" value="🌤️"}
                        {elseif $clima_planeta.clave == 'viento_estelar'}{assign var="cp_emoji" value="🍃"}
                        {elseif $clima_planeta.clave == 'cristalino'}{assign var="cp_emoji" value="✨"}
                        {elseif $clima_planeta.clave == 'niebla'}{assign var="cp_emoji" value="🌫️"}
                        {elseif $clima_planeta.clave == 'tormenta_solar'}{assign var="cp_emoji" value="⚡"}
                        {elseif $clima_planeta.clave == 'meteoros'}{assign var="cp_emoji" value="☄️"}
                        {elseif $clima_planeta.clave == 'nebulosa'}{assign var="cp_emoji" value="💰"}
                        {elseif $clima_planeta.clave == 'plasma'}{assign var="cp_emoji" value="🌌"}
                        {elseif $clima_planeta.clave == 'eclipse'}{assign var="cp_emoji" value="🌓"}
                        {elseif $clima_planeta.clave == 'campo_mag'}{assign var="cp_emoji" value="🌀"}
                        {elseif $clima_planeta.clave == 'aurora'}{assign var="cp_emoji" value="🌈"}
                        {elseif $clima_planeta.clave == 'agujero'}{assign var="cp_emoji" value="🕳️"}
                        {elseif $clima_planeta.clave == 'singularidad'}{assign var="cp_emoji" value="⚫"}
                        {/if}
                        <div class="xnova-clima-emoji">{$cp_emoji}</div>
                        <div class="xnova-clima-info">
                            <div class="xnova-clima-name">{$clima_planeta.nombre}</div>
                            <div class="xnova-clima-desc">"{$clima_planeta.descripcion}"</div>
                            <div class="xnova-clima-factors">
                                <span class="xnova-clima-factor {if $clima_planeta.factor_ataque > 1}positive{elseif $clima_planeta.factor_ataque < 1}negative{else}neutral{/if}">
                                    ⚔️ {if $clima_planeta.factor_ataque > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_ataque format="%d"}%
                                </span>
                                <span class="xnova-clima-factor {if $clima_planeta.factor_defensa > 1}positive{elseif $clima_planeta.factor_defensa < 1}negative{else}neutral{/if}">
                                    🛡️ {if $clima_planeta.factor_defensa > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_defensa format="%d"}%
                                </span>
                                <span class="xnova-clima-factor {if $clima_planeta.factor_bajas > 1}negative{elseif $clima_planeta.factor_bajas < 1}positive{else}neutral{/if}">
                                    💀 {if $clima_planeta.factor_bajas > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_bajas format="%d"}%
                                </span>
                                <span class="xnova-clima-factor {if $clima_planeta.factor_botin > 1}positive{elseif $clima_planeta.factor_botin < 1}negative{else}neutral{/if}">
                                    💰 {if $clima_planeta.factor_botin > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_botin format="%d"}%
                                </span>
                            </div>
                        </div>
                    </div>

                    {* ─── Predicción para mañana ─── *}
                    {if isset($clima_planeta_previsto) && $clima_planeta_previsto}
                    <div class="xnova-clima-predict">
                        {assign var="cpp_emoji" value="❓"}
                        {if $clima_planeta_previsto.clave == 'despejado'}{assign var="cpp_emoji" value="☀️"}
                        {elseif $clima_planeta_previsto.clave == 'brisa_solar'}{assign var="cpp_emoji" value="🌤️"}
                        {elseif $clima_planeta_previsto.clave == 'viento_estelar'}{assign var="cpp_emoji" value="🍃"}
                        {elseif $clima_planeta_previsto.clave == 'cristalino'}{assign var="cpp_emoji" value="✨"}
                        {elseif $clima_planeta_previsto.clave == 'niebla'}{assign var="cpp_emoji" value="🌫️"}
                        {elseif $clima_planeta_previsto.clave == 'tormenta_solar'}{assign var="cpp_emoji" value="⚡"}
                        {elseif $clima_planeta_previsto.clave == 'meteoros'}{assign var="cpp_emoji" value="☄️"}
                        {elseif $clima_planeta_previsto.clave == 'nebulosa'}{assign var="cpp_emoji" value="💰"}
                        {elseif $clima_planeta_previsto.clave == 'plasma'}{assign var="cpp_emoji" value="🌌"}
                        {elseif $clima_planeta_previsto.clave == 'eclipse'}{assign var="cpp_emoji" value="🌓"}
                        {elseif $clima_planeta_previsto.clave == 'campo_mag'}{assign var="cpp_emoji" value="🌀"}
                        {elseif $clima_planeta_previsto.clave == 'aurora'}{assign var="cpp_emoji" value="🌈"}
                        {elseif $clima_planeta_previsto.clave == 'agujero'}{assign var="cpp_emoji" value="🕳️"}
                        {elseif $clima_planeta_previsto.clave == 'singularidad'}{assign var="cpp_emoji" value="⚫"}
                        {/if}
                        <span class="pred-emoji">{$cpp_emoji}</span>
                        <span><b>🔮 Mañana:</b> {$clima_planeta_previsto.nombre}</span>
                    </div>
                    {/if}

                    {* ─── Aviso si el clima es malo para defender ─── *}
                    {if $clima_planeta.factor_defensa < 1}
                    <div class="xnova-clima-alert danger">
                        ⚠️ Tu defensa está debilitada hoy. Refuerza o haz fleetsave.
                    </div>
                    {elseif $clima_planeta.factor_defensa > 1}
                    <div class="xnova-clima-alert success">
                        ✅ Tu defensa está reforzada hoy. Buen día para resistir ataques.
                    </div>
                    {/if}

                    {* ─── Clima de la Luna (si existe) ─── *}
                    {if isset($clima_luna) && $clima_luna}
                    <div class="xnova-clima-section" style="border-top: 1px dashed rgba(0,224,255,0.2); padding-top: 10px; margin-top: 4px;">
                        {assign var="cl_emoji" value="❓"}
                        {if $clima_luna.clave == 'despejado'}{assign var="cl_emoji" value="☀️"}
                        {elseif $clima_luna.clave == 'brisa_solar'}{assign var="cl_emoji" value="🌤️"}
                        {elseif $clima_luna.clave == 'viento_estelar'}{assign var="cl_emoji" value="🍃"}
                        {elseif $clima_luna.clave == 'cristalino'}{assign var="cl_emoji" value="✨"}
                        {elseif $clima_luna.clave == 'niebla'}{assign var="cl_emoji" value="🌫️"}
                        {elseif $clima_luna.clave == 'tormenta_solar'}{assign var="cl_emoji" value="⚡"}
                        {elseif $clima_luna.clave == 'meteoros'}{assign var="cl_emoji" value="☄️"}
                        {elseif $clima_luna.clave == 'nebulosa'}{assign var="cl_emoji" value="💰"}
                        {elseif $clima_luna.clave == 'plasma'}{assign var="cl_emoji" value="🌌"}
                        {elseif $clima_luna.clave == 'eclipse'}{assign var="cl_emoji" value="🌓"}
                        {elseif $clima_luna.clave == 'campo_mag'}{assign var="cl_emoji" value="🌀"}
                        {elseif $clima_luna.clave == 'aurora'}{assign var="cl_emoji" value="🌈"}
                        {elseif $clima_luna.clave == 'agujero'}{assign var="cl_emoji" value="🕳️"}
                        {elseif $clima_luna.clave == 'singularidad'}{assign var="cl_emoji" value="⚫"}
                        {/if}
                        <div class="xnova-clima-emoji" style="font-size: 28px;">{$cl_emoji}</div>
                        <div class="xnova-clima-info">
                            <div class="xnova-clima-name">🌑 Luna: {$clima_luna.nombre}</div>
                            <div class="xnova-clima-desc">"{$clima_luna.descripcion}"</div>
                            {if isset($clima_luna_previsto) && $clima_luna_previsto}
                                {assign var="clp_emoji" value="❓"}
                                {if $clima_luna_previsto.clave == 'despejado'}{assign var="clp_emoji" value="☀️"}
                                {elseif $clima_luna_previsto.clave == 'brisa_solar'}{assign var="clp_emoji" value="🌤️"}
                                {elseif $clima_luna_previsto.clave == 'viento_estelar'}{assign var="clp_emoji" value="🍃"}
                                {elseif $clima_luna_previsto.clave == 'cristalino'}{assign var="clp_emoji" value="✨"}
                                {elseif $clima_luna_previsto.clave == 'niebla'}{assign var="clp_emoji" value="🌫️"}
                                {elseif $clima_luna_previsto.clave == 'tormenta_solar'}{assign var="clp_emoji" value="⚡"}
                                {elseif $clima_luna_previsto.clave == 'meteoros'}{assign var="clp_emoji" value="☄️"}
                                {elseif $clima_luna_previsto.clave == 'nebulosa'}{assign var="clp_emoji" value="💰"}
                                {elseif $clima_luna_previsto.clave == 'plasma'}{assign var="clp_emoji" value="🌌"}
                                {elseif $clima_luna_previsto.clave == 'eclipse'}{assign var="clp_emoji" value="🌓"}
                                {elseif $clima_luna_previsto.clave == 'campo_mag'}{assign var="clp_emoji" value="🌀"}
                                {elseif $clima_luna_previsto.clave == 'aurora'}{assign var="clp_emoji" value="🌈"}
                                {elseif $clima_luna_previsto.clave == 'agujero'}{assign var="clp_emoji" value="🕳️"}
                                {elseif $clima_luna_previsto.clave == 'singularidad'}{assign var="clp_emoji" value="⚫"}
                                {/if}
                                <div class="xnova-clima-predict" style="padding-top: 4px;">
                                    <span class="pred-emoji">{$clp_emoji}</span>
                                    <span><b>🔮 Mañana:</b> {$clima_luna_previsto.nombre}</span>
                                </div>
                            {/if}
                        </div>
                    </div>
                    {/if}

                    {* 🆕 ASTROIO v6.6 - BUFF CLIMÁTICO ACTIVO *}
                    {if isset($buff_activo) && $buff_activo}
                    <div class="xnova-clima-buff-box" style="margin-top: 10px; padding: 10px; background: rgba(74, 255, 136, 0.1); border: 1px solid rgba(74, 255, 136, 0.4); border-radius: 8px; box-shadow: inset 0 0 10px rgba(74, 255, 136, 0.05); display: flex; align-items: center; justify-content: space-between;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span style="font-size: 24px; filter: drop-shadow(0 0 8px rgba(74, 255, 136, 0.8));">
                                {if $buff_activo.buff_type == 'estabilizador_menor'}🌤️
                                {elseif $buff_activo.buff_type == 'estabilizador_mayor'}🌈
                                {elseif $buff_activo.buff_type == 'dominio'}⚡
                                {else}✨{/if}
                            </span>
                            <div>
                                <div style="font-size: 13px; font-weight: 800; color: #4aff88; text-shadow: 0 0 8px rgba(74, 255, 136, 0.5); text-transform: uppercase;">⚡ Buff Climático Activo</div>
                                <div style="font-size: 11px; color: #fff;">{$buff_nombre_legible}</div>
                            </div>
                        </div>
                        <div style="text-align: right;">
                            <div style="font-size: 9px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px;">Tiempo restante</div>
                            <div id="ov_buff_timer" style="font-size: 16px; font-weight: 900; font-family: 'Courier New', monospace; color: #4aff88;" data-expires="{$buff_activo.expires_at}">
                                {$buff_horas_restantes}h {$buff_minutos_restantes}m
                            </div>
                        </div>
                    </div>
                    {/if}

                </div>
                {/if}
            </div>

            <!-- GRID DE 4 ACCIONES -->
            <div class="xnova-action-grid">
                <div class="xnova-action-card">
                    <div class="xnova-action-image" style="background-image: url('./styles/theme/gow/img/overview_buildings.jpg');"></div>
                    <div class="xnova-action-content">
                        <div class="xnova-action-title">{$LNG.ov_list_title_build}</div>
                        <div class="xnova-action-status">
                            {if $buildInfo.buildings}
                                {$LNG.tech[$buildInfo.buildings['id']]} <b>({$buildInfo.buildings['level']})</b><br>
                                <span class="timer" data-time="{$buildInfo.buildings['timeleft']}">{$buildInfo.buildings['starttime']}</span>
                            {else}
                                {$LNG.ov_free}
                            {/if}
                        </div>
                        <a href="game.php?page=buildings" class="xnova-action-btn">Descubrir →</a>
                    </div>
                </div>

                <div class="xnova-action-card">
                    <div class="xnova-action-image" style="background-image: url('./styles/theme/gow/img/overview_research.jpg');"></div>
                    <div class="xnova-action-content">
                        <div class="xnova-action-title">Investigaciones</div>
                        <div class="xnova-action-status">
                            {if $buildInfo.tech}
                                {$LNG.tech[$buildInfo.tech['id']]} <b>({$buildInfo.tech['level']})</b><br>
                                <span class="timer" data-time="{$buildInfo.tech['timeleft']}">{$buildInfo.tech['starttime']}</span>
                            {else}
                                {$LNG.ov_free}
                            {/if}
                        </div>
                        <a href="game.php?page=research" class="xnova-action-btn">Investigar →</a>
                    </div>
                </div>

                <div class="xnova-action-card">
                    <div class="xnova-action-image" style="background-image: url('./styles/theme/gow/img/overview_hangar.jpg');"></div>
                    <div class="xnova-action-content">
                        <div class="xnova-action-title">Flota</div>
                        <div class="xnova-action-status">
                            {if $buildInfo.fleet}
                                {$LNG.tech[$buildInfo.fleet['id']]} <b>({$buildInfo.fleet['level']})</b><br>
                                <span class="timer" data-time="{$buildInfo.fleet['timeleft']}">{$buildInfo.fleet['starttime']}</span>
                            {else}
                                {$LNG.ov_free}
                            {/if}
                        </div>
                        <a href="game.php?page=shipyard" class="xnova-action-btn">Descubrir →</a>
                    </div>
                </div>

                <div class="xnova-action-card">
                    <div class="xnova-action-image" style="background-image: url('./styles/theme/gow/img/overview_defense.jpg');"></div>
                    <div class="xnova-action-content">
                        <div class="xnova-action-title">Defensa</div>
                        <div class="xnova-action-status">
                            {if $buildInfo.defense}
                                {$LNG.tech[$buildInfo.defense['id']]} <b>({$buildInfo.defense['level']})</b><br>
                                <span class="timer" data-time="{$buildInfo.defense['timeleft']}">{$buildInfo.defense['starttime']}</span>
                            {else}
                                {$LNG.ov_free}
                            {/if}
                        </div>
                        <a href="game.php?page=shipyard&amp;mode=defense" class="xnova-action-btn">Descubrir →</a>
                    </div>
                </div>
            </div>

            {* ============ FLOTAS ACTIVAS (RADAR TÁCTICO) ============ *}
            <div class="xnova-fleet-card" style="padding: 0; background: transparent; border: none; box-shadow: none;">
                <div class="astroftbl_section_title" style="font-size: 12px; margin-bottom: 8px; color: #fff;">🚀 Flotas Activas</div>
                {if $fleets}
                    {foreach $fleets as $index => $fleet}

                        {* Lógica de Misión, Iconos, Colores y Fase *}
                        {assign var="fleetClass" value="is-transport"}
                        {assign var="shipIcon"   value="🚀"}
                        {assign var="destIcon"   value="🪐"}
                        {assign var="fase"       value="IDA"}

                        {if $fleet.is_incoming}
                            {assign var="fleetClass" value="is-incoming"}
                        {/if}

                        {if $fleet.mission == 1 || $fleet.mission == 2 || ($fleet.mission >= 20 && $fleet.mission <= 23)}
                            {assign var="fleetClass" value="is-attack"}
                            {assign var="shipIcon"   value="⚔️"}
                        {elseif $fleet.mission == 15}
                            {assign var="fleetClass" value="is-expedition"}
                            {assign var="shipIcon"   value="🚀"}
                            {assign var="destIcon"   value="🌌"}
                        {elseif $fleet.mission == 8}
                            {assign var="fleetClass" value="is-transport"}
                            {assign var="destIcon"   value="♻️"}
                        {elseif $fleet.mission == 6}
                            {assign var="fleetClass" value="is-espionage"}
                            {assign var="shipIcon"   value="🕵️"}
                        {elseif $fleet.mission == 4}
                            {assign var="fleetClass" value="is-deploy"}
                            {assign var="shipIcon"   value="🛡️"}
                        {/if}

                        {* Si es vuelta, forzamos cohete de retorno *}
                        {if $fleet.state == 1}
                            {assign var="fase"     value="VUELTA"}
                            {assign var="shipIcon" value="🚀"}
                        {/if}

                        {* Icono origen/destino por tipo *}
                        {assign var="startIcon" value="🪐"}
                        {if isset($fleet.start_type) && $fleet.start_type == 3}{assign var="startIcon" value="🌑"}{/if}
                        {if isset($fleet.end_type) && $fleet.end_type == 3}
                            {assign var="destIcon" value="🌑"}
                        {elseif isset($fleet.end_type) && $fleet.end_type == 2}
                            {assign var="destIcon" value="☄️"}
                        {/if}

                        <div class="fleet-card {$fleetClass}">
                            <div class="fleet-header">
                                <div class="fleet-mission">{$fleet.mission_label} ({$fase})</div>
                            </div>
                            <div class="fleet-radar">
                                <div class="planet-node start-node">
                                    <span class="planet-icon">{$startIcon}</span>
                                    <span class="planet-name">Origen</span>
                                    <span class="planet-coords">[{$fleet.startGalaxy}:{$fleet.startSystem}:{$fleet.startPlanet}]</span>
                                </div>
                                <div class="radar-track-container">
                                    <div class="radar-line"></div>
                                    <div class="planet-node center-node">
                                        <span class="planet-icon">{$destIcon}</span>
                                        <span class="planet-name">Destino</span>
                                        <span class="planet-coords">[{$fleet.endGalaxy}:{$fleet.endSystem}:{$fleet.endPlanet}]</span>
                                    </div>
                                    <div class="planet-node end-node">
                                        <span class="planet-icon">{$startIcon}</span>
                                        <span class="planet-name">Retorno</span>
                                        <span class="planet-coords">[{$fleet.startGalaxy}:{$fleet.startSystem}:{$fleet.startPlanet}]</span>
                                    </div>

                                    <div class="traveler-container" id="traveler_{$index}"
                                         data-fleet-id="{$fleet.id}"
                                         data-fleet-total-time="{$fleet.resttime}"
                                         data-fleet-state="{$fleet.state|default:0}">
                                        <div class="traveler-ship">{$shipIcon}</div>
                                        <div class="traveler-timer" id="timer_{$index}">
                                            {pretty_fly_time({$fleet.resttime})}
                                        </div>

                                        <!-- TOOLTIP PERSONALIZADO -->
                                        <div class="hud-tooltip">
                                            <div class="tooltip-title">Información de Flota</div>
                                            
                                            {if isset($fleet.ships_array) && $fleet.ships_array|@count > 0}
                                                {foreach $fleet.ships_array as $shipId => $count}
                                                    {if $count > 0}
                                                        <div class="tooltip-row">
                                                            <span>{$LNG.tech[$shipId]}:</span>
                                                            <span>{$count|number}</span>
                                                        </div>
                                                    {/if}
                                                {/foreach}
                                            {else}
                                                <div class="tooltip-row">
                                                    <span>Total Naves:</span>
                                                    <span>{$fleet.amount|number}</span>
                                                </div>
                                            {/if}

                                            {if isset($fleet.fleet_resource_metal) && ($fleet.fleet_resource_metal > 0 || $fleet.fleet_resource_crystal > 0 || $fleet.fleet_resource_deuterium > 0)}
                                                <div class="tooltip-section-title">Recursos</div>
                                                {if $fleet.fleet_resource_metal > 0}
                                                <div class="tooltip-row"><span>Metal:</span><span style="color:var(--accent-cyan);">{$fleet.fleet_resource_metal|number}</span></div>
                                                {/if}
                                                {if $fleet.fleet_resource_crystal > 0}
                                                <div class="tooltip-row"><span>Cristal:</span><span style="color:var(--accent-cyan);">{$fleet.fleet_resource_crystal|number}</span></div>
                                                {/if}
                                                {if $fleet.fleet_resource_deuterium > 0}
                                                <div class="tooltip-row"><span>Deuterio:</span><span style="color:var(--accent-cyan);">{$fleet.fleet_resource_deuterium|number}</span></div>
                                                {/if}
                                            {/if}
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>
                    {/foreach}
                {else}
                    <div style="text-align: center; color: var(--text-muted); padding: 20px; border: 1px dashed var(--border-color); border-radius: 8px;">
                        [ SIN FLOTAS ACTIVAS ]
                    </div>
                {/if}
            </div>

            {* ═══════════════════════════════════════════════════════════
             * WIDGET PvE
             * ═══════════════════════════════════════════════════════════ *}
            {if isset($pve_widget) && $pve_widget.enabled && $pve_widget.show_widget}
            <div class="ov_pve_section" id="ov_pve_section">
                <div class="ov_pve_title">
                    <span>⚔️ Eventos PvE</span>
                    <a href="game.php?page=pve" class="ov_pve_all">Ver todos →</a>
                </div>
                <div class="ov_pve_grid">
                    {if $pve_widget.crisis_active || $pve_widget.crisis_time > 0}
                    <a href="game.php?page=pve" class="ov_pve_card ov_pve_crisis" id="ov_pve_crisis_card" data-active="{$pve_widget.crisis_active|default:0}" data-time="{$pve_widget.crisis_time|default:0}" data-end="{$pve_widget.crisis_end|default:0}">
                        <div class="ov_pve_header"><span class="ov_pve_icon">🌌</span><span class="ov_pve_name">Crisis de Fin de Mes</span></div>
                        <div class="ov_pve_status" data-role="status">Cargando…</div>
                        <div class="ov_pve_footer"><span class="ov_pve_time off" data-role="time">--</span></div>
                    </a>
                    {/if}
                    {if $pve_widget.boss_active || $pve_widget.boss_time > 0}
                    <a href="game.php?page=pve&mode=boss" class="ov_pve_card ov_pve_boss {if $pve_widget.boss_active}state-active{/if}" id="ov_pve_boss_card" data-active="{$pve_widget.boss_active|default:0}" data-status="{$pve_widget.boss_status|default:''}" data-time="{$pve_widget.boss_time|default:0}" data-end="{$pve_widget.boss_end|default:0}" data-ghosts="{$pve_widget.boss_ghosts|default:0}">
                        <div class="ov_pve_header"><span class="ov_pve_icon">🌌</span><span class="ov_pve_name">Torneo del Devorador</span></div>
                        <div class="ov_pve_status" data-role="status">Cargando…</div>
                        <div class="ov_pve_footer"><span class="ov_pve_time off" data-role="time">--</span></div>
                    </a>
                    {/if}
                    {if $pve_widget.empire_active || $pve_widget.empire_time > 0}
                    <a href="game.php?page=pve&mode=empire" class="ov_pve_card ov_pve_empire" id="ov_pve_empire_card" data-active="{$pve_widget.empire_active|default:0}" data-time="{$pve_widget.empire_time|default:0}" data-end="{$pve_widget.empire_end|default:0}" data-count="{$pve_widget.empire_count|default:0}">
                        <div class="ov_pve_header"><span class="ov_pve_icon">🏛️</span><span class="ov_pve_name">Imperio Caído</span></div>
                        <div class="ov_pve_status" data-role="status">Cargando…</div>
                        <div class="ov_pve_footer"><span class="ov_pve_time off" data-role="time">--</span></div>
                    </a>
                    {/if}
                    {if $pve_widget.pending_rewards > 0}
                    <a href="game.php?page=pve" class="ov_pve_card ov_pve_rewards">
                        <div class="ov_pve_header"><span class="ov_pve_icon">🎁</span><span class="ov_pve_name">Recompensas PvE</span></div>
                        <div class="ov_pve_status highlight">{$pve_widget.pending_rewards} pendiente(s)</div>
                        <div class="ov_pve_footer"><span class="ov_pve_time">Reclamar →</span></div>
                    </a>
                    {/if}
                </div>
            </div>
            {/if}

            {* ═══════════════════════════════════════════════════════════
             * WIDGET PvP
             * ═══════════════════════════════════════════════════════════ *}
            {if isset($pvp_widget) && $pvp_widget.enabled && $pvp_widget.show_widget}
            <div class="ov_pvp_section" id="ov_pvp_section">
                <div class="ov_pvp_title">
                    <span>⚔️ Sistema PvP</span>
                    <a href="game.php?page=pvp" class="ov_pvp_all">Ver todo →</a>
                </div>
                <div class="ov_pvp_grid">
                    {if $pvp_widget.arenas_waiting > 0}
                    <a href="game.php?page=pvp&mode=arenas" class="ov_pvp_card ov_pvp_arenas">
                        <div class="ov_pvp_header"><span class="ov_pvp_icon">🏟️</span><span class="ov_pvp_name">Arenas abiertas</span></div>
                        <div class="ov_pvp_status highlight">{$pvp_widget.arenas_waiting} esperando</div>
                        <div class="ov_pvp_footer"><span class="ov_pvp_time">Unirse →</span></div>
                    </a>
                    {/if}
                    {if $pvp_widget.arenas_active > 0}
                    <a href="game.php?page=pvp&mode=arenas" class="ov_pvp_card ov_pvp_arenas state-active">
                        <div class="ov_pvp_header"><span class="ov_pvp_icon">⚔️</span><span class="ov_pvp_name">Arenas activas</span></div>
                        <div class="ov_pvp_status highlight">{$pvp_widget.arenas_active} en curso</div>
                        <div class="ov_pvp_footer"><span class="ov_pvp_time danger">Ver →</span></div>
                    </a>
                    {/if}
                    {if $pvp_widget.my_arena}
                    <a href="game.php?page=pvp&mode=viewArena&arena_id={$pvp_widget.my_arena.id}" class="ov_pvp_card ov_pvp_myarena" id="ov_pvp_myarena_card" data-end="{$pvp_widget.my_arena.time_left}" data-status="{$pvp_widget.my_arena.status}">
                        <div class="ov_pvp_header"><span class="ov_pvp_icon">🎯</span><span class="ov_pvp_name">Mi arena</span></div>
                        <div class="ov_pvp_status">{$pvp_widget.my_arena.mode_label} · {$pvp_widget.my_arena.players}/{$pvp_widget.my_arena.max}</div>
                        <div class="ov_pvp_footer"><span class="ov_pvp_time" data-role="time">{$pvp_widget.my_arena.time_fmt}</span></div>
                    </a>
                    {/if}
                    {if $pvp_widget.tournament_active === 1}
                    <a href="game.php?page=pvp&mode=tournaments" class="ov_pvp_card ov_pvp_tournament {if $pvp_widget.tournament_status == 'running'}state-active{/if}" id="ov_pvp_tournament_card" data-status="{$pvp_widget.tournament_status}" data-time="{$pvp_widget.tournament_time}">
                        <div class="ov_pvp_header"><span class="ov_pvp_icon">🏆</span><span class="ov_pvp_name">Torneo</span></div>
                        <div class="ov_pvp_status">
                            {if $pvp_widget.tournament_status == 'registration'}Inscripción abierta · {$pvp_widget.tournament_players}/{$pvp_widget.tournament_max}
                            {elseif $pvp_widget.tournament_status == 'running'}En curso · {$pvp_widget.tournament_players} jugadores
                            {else}{$pvp_widget.tournament_status}{/if}
                        </div>
                        <div class="ov_pvp_footer"><span class="ov_pvp_time" data-role="time">--</span></div>
                    </a>
                    {/if}
                    {if $pvp_widget.my_pvp_points > 0 || $pvp_widget.my_pvp_wins > 0}
                    <a href="game.php?page=pvp&mode=profile" class="ov_pvp_card ov_pvp_stats">
                        <div class="ov_pvp_header"><span class="ov_pvp_icon">📊</span><span class="ov_pvp_name">Mis stats PvP</span></div>
                        <div class="ov_pvp_status">{$pvp_widget.my_pvp_points} pts · {$pvp_widget.my_pvp_wins}V/{$pvp_widget.my_pvp_losses}D</div>
                        <div class="ov_pvp_footer"><span class="ov_pvp_time">Logros {$pvp_widget.ach_unlocked}/{$pvp_widget.ach_total} →</span></div>
                    </a>
                    {/if}
                </div>
            </div>
            {/if}

            {* ============ WIDGET EVENTOS ============ *}
            {if $ovEvents && ($ovEvents.daily || $ovEvents.weekly || $ovEvents.elite)}
            <div class="ov_events_section">
                <div class="ov_events_title">
                    <span>🎉 Eventos en Curso</span>
                    <a href="game.php?page=events" class="ov_events_all">Ver todos →</a>
                </div>
                <div class="ov_events_grid">
                    {foreach $ovEvents as $ev}
                        {if $ev}
                        <a href="game.php?page=events" class="ov_ev_card ov_ev_{$ev.event_class}">
                            <div class="ov_ev_header">
                                <span class="ov_ev_icon" style="background: {$ev.event_color}22; color: {$ev.event_color}; border-color: {$ev.event_color};">{$ev.icon_emoji}</span>
                                <span class="ov_ev_name">{$ev.event_name}</span>
                            </div>
                            <div class="ov_ev_progress_bar">
                                <div class="ov_ev_progress_fill{if $ev.is_complete} complete{/if}" style="width:{$ev.progress_pct}%;"></div>
                            </div>
                            <div class="ov_ev_footer">
                                <span class="ov_ev_progress">{$ev.progress_fmt} / {$ev.target_fmt}</span>
                                <span class="ov_ev_reward">{$ev.reward_text}</span>
                            </div>
                        </a>
                        {/if}
                    {/foreach}
                </div>
            </div>
            {/if}

            {* ============ WIDGET RIFAS ============ *}
            {if $raffles_hay}
            <div class="ov_raffles_section">
                <div class="ov_raffles_title">
                    <span>🎰 Rifas Activas {if $raffles_count > 0}<span class="ov_raffles_count">· {$raffles_count}</span>{/if}</span>
                    <a href="game.php?page=raffles" class="ov_raffles_all">Ver todas →</a>
                </div>
                <div class="ov_raffles_grid">
                    {foreach $raffles_widget as $r}
                    <a href="game.php?page=raffles&mode=view&id={$r.id}" class="ov_raf_card">
                        <div class="ov_raf_header"><span class="ov_raf_icon">🎰</span><span class="ov_raf_name">{$r.titulo}</span></div>
                        <div class="ov_raf_prize">🏆 {$r.premio_texto}</div>
                        <div class="ov_raf_progress_bar"><div class="ov_raf_progress_fill" style="width:{$r.pct}%;"></div></div>
                        <div class="ov_raf_footer">
                            <span class="ov_raf_time" data-fin="{$r.fecha_fin}">{$r.tiempo_restante}</span>
                            <span class="ov_raf_price">🎟️ {$r.precio_boleto} {$r.moneda_nombre}</span>
                        </div>
                    </a>
                    {/foreach}
                </div>
            </div>
            {/if}

            {* ============ WIDGET LOTERIA ============ *}
            {if $lottery_hay && $lottery_widget}
            <div class="ov_lottery_section">
                <div class="ov_lottery_title">
                    <span>🎫 Loteria <span class="ov_lottery_num">· Sorteo #{$lottery_widget.numero_sorteo}</span></span>
                    <a href="game.php?page=lottery" class="ov_lottery_all">Ver loteria →</a>
                </div>
                <div class="ov_lottery_grid">
                    <a href="game.php?page=lottery" class="ov_lot_card">
                        <div class="ov_lot_header"><span class="ov_lot_icon">🎫</span><span class="ov_lot_name">Sorteo #{$lottery_widget.numero_sorteo}</span></div>
                        <div class="ov_lot_jackpot">🏆 {$lottery_widget.jackpot_fmt} NTX-20</div>
                        <div class="ov_lot_progress_bar">
                            {assign var=lot_pct value=0}
                            {if $lottery_widget.max_tickets > 0}
                                {assign var=lot_pct value=($lottery_widget.tickets_vendidos / $lottery_widget.max_tickets * 100)|round}
                            {/if}
                            <div class="ov_lot_progress_fill" style="width:{$lot_pct}%;"></div>
                        </div>
                        <div class="ov_lot_footer">
                            <span class="ov_lot_time" data-fin="{$lottery_widget.fecha_sorteo}">{$lottery_widget.tiempo_restante}</span>
                            <span class="ov_lot_price">🎟️ {$lottery_widget.precio_ticket} NTX-20</span>
                        </div>
                    </a>
                </div>
            </div>
            {/if}

            {* ============ NOVEDADES ============ *}
            {if $is_news}
            <div class="xnova-card" style="margin-top: 0;">
                <div class="xnova-card-header">
                    <span><span class="icon">📰</span> {$LNG.ov_news}</span>
                </div>
                <div class="xnova-card-body" style="text-align: left; color: var(--text-main); font-size: 12px; line-height: 1.6;">
                    {$news}
                </div>
            </div>
            {/if}

        </div>

        <!-- ================= COLUMNA DERECHA (SIDEBAR) ================= -->
        <div class="xnova-sidebar">

            {* ============ CARTA DE USUARIO ============ *}
            {assign var="rankInfo_clean" value=$rankInfo|strip_tags|trim}
            {assign var="points_part" value=$rankInfo_clean|regex_replace:'/^([0-9\.,]+).*/':'$1'}
            {assign var="rank_part" value=$rankInfo_clean|regex_replace:'/^[0-9\.,]+\s*/':''}

            <div class="xnova-user-card">
                <div class="uc-header">Carta de Usuario</div>
                
                <div class="uc-stats">
                    <div class="uc-stat-row">
                        <span class="lbl">Rango</span>
                        <span class="val">{$rank_part}</span>
                    </div>
                    <div class="uc-stat-row">
                        <span class="lbl">Puntos</span>
                        <span class="val cyan">{$points_part}</span>
                    </div>
                    <div class="uc-stat-row">
                        <span class="lbl">Flota</span>
                        <span class="val">{if isset($fleet_count)}{$fleet_count|number}{else}0{/if}</span>
                    </div>
                    <div class="uc-stat-row">
                        <span class="lbl">Defensa</span>
                        <span class="val">{if isset($defense_count)}{$defense_count|number}{else}0{/if}</span>
                    </div>
                </div>
            </div>

            {* ============ POTENCIADORES ============ *}
            {if $allBoosters}
            <div class="boosters_section">
                <div class="boosters_title">
                    ⚡ POTENCIADORES {if $activeBoosters > 0}· <span class="active-count">{$activeBoosters} activos</span>{/if}
                </div>
                <div class="boosters_grid">
                    {foreach $allBoosters as $booster}
                        {if $booster.booster_name != 'Bonus VIP Semanal' && $booster.booster_name != 'Bonus VIP Quincenal' && $booster.booster_name != 'Bonus VIP Mensual'}
                        <div class="booster_card {if $booster.active}active{else}inactive{/if}">
                            <div class="booster_icon">{$booster.icon_emoji}</div>
                            <div class="booster_info">
                                <div class="booster_name">{$booster.booster_name}</div>
                                <div class="booster_bonus">+{$booster.booster_value}%</div>
                            </div>
                            <div class="booster_state">
                                {if $booster.active}
                                    <span class="state_active">⏰ {$booster.remaining_str}</span>
                                {else}
                                    <span class="state_inactive">Inactivo</span>
                                {/if}
                            </div>
                        </div>
                        {/if}
                    {/foreach}
                </div>
            </div>
            {/if}

        </div>

    </div>

</div>

<script>
/* ============================================================
 * Cuenta atrás en vivo para Rifas + Lotería
 * ============================================================ */
(function() {
	function actualizarContadores() {
		var ahora = Math.floor(Date.now() / 1000);
		document.querySelectorAll('.ov_raf_time[data-fin]').forEach(function(el) {
			var fin = parseInt(el.getAttribute('data-fin'), 10);
			var restante = fin - ahora;
			if (restante <= 0) { el.textContent = 'SORTEANDO...'; el.className = 'ov_raf_time danger'; return; }
			var d = Math.floor(restante / 86400), h = Math.floor((restante % 86400) / 3600), m = Math.floor((restante % 3600) / 60), s = restante % 60;
			var texto = d > 0 ? d + 'd ' + h + 'h ' + m + 'm' : (h > 0 ? h + 'h ' + m + 'm ' + s + 's' : (m > 0 ? m + 'm ' + s + 's' : s + 's'));
			el.textContent = texto;
			el.className = restante < 21600 ? 'ov_raf_time danger' : (restante < 86400 ? 'ov_raf_time warn' : 'ov_raf_time');
		});
		document.querySelectorAll('.ov_lot_time[data-fin]').forEach(function(el) {
			var fin = parseInt(el.getAttribute('data-fin'), 10);
			var restante = fin - ahora;
			if (restante <= 0) { el.textContent = 'SORTEANDO...'; el.className = 'ov_lot_time danger'; return; }
			var d = Math.floor(restante / 86400), h = Math.floor((restante % 86400) / 3600), m = Math.floor((restante % 3600) / 60), s = restante % 60;
			var texto = d > 0 ? d + 'd ' + h + 'h ' + m + 'm' : (h > 0 ? h + 'h ' + m + 'm ' + s + 's' : (m > 0 ? m + 'm ' + s + 's' : s + 's'));
			el.textContent = texto;
			el.className = restante < 21600 ? 'ov_lot_time danger' : (restante < 86400 ? 'ov_lot_time warn' : 'ov_lot_time');
		});
	}
	actualizarContadores();
	setInterval(actualizarContadores, 1000);
})();

/* PvE */
(function() {
	var crisis = document.getElementById('ov_pve_crisis_card');
	var empire = document.getElementById('ov_pve_empire_card');
	var boss   = document.getElementById('ov_pve_boss_card');
	if (!crisis && !empire && !boss) return;
	function fmt(sec) {
		if (sec <= 0) return '0s';
		var d = Math.floor(sec / 86400), h = Math.floor((sec % 86400) / 3600), m = Math.floor((sec % 3600) / 60), s = sec % 60;
		if (d > 0) return d + 'd ' + h + 'h ' + m + 'm'; if (h > 0) return h + 'h ' + m + 'm ' + s + 's'; if (m > 0) return m + 'm ' + s + 's'; return s + 's';
	}
	function updateCrisis() {
		if (!crisis) return;
		var active = parseInt(crisis.getAttribute('data-active') || '0', 10), time = parseInt(crisis.getAttribute('data-time') || '0', 10), end = parseInt(crisis.getAttribute('data-end') || '0', 10);
		var status = crisis.querySelector('[data-role="status"]'), tEl = crisis.querySelector('[data-role="time"]'), now = Math.floor(Date.now() / 1000);
		if (active === 1) {
			crisis.classList.add('state-active'); status.textContent = '🔴 ACTIVA';
			if (end > 0) { var rem = end - now; if (rem > 0) { tEl.textContent = '⏱ Termina en ' + fmt(rem); tEl.className = 'ov_pve_time danger'; } else { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pve_time warn'; } } else { tEl.textContent = 'En curso'; tEl.className = 'ov_pve_time danger'; } return;
		}
		crisis.classList.remove('state-active');
		if (time > now) { var diff = time - now; if (diff < 3600) { status.textContent = '⚡ Inminente'; tEl.className = 'ov_pve_time danger'; } else if (diff < 86400) { status.textContent = '⏰ Próxima'; tEl.className = 'ov_pve_time warn'; } else { status.textContent = '✅ Programada'; tEl.className = 'ov_pve_time'; } tEl.textContent = 'Empieza en ' + fmt(diff); } else { status.textContent = '— Sin programar'; tEl.textContent = '--'; tEl.className = 'ov_pve_time off'; }
	}
	function updateBoss() {
		if (!boss) return;
		var active = parseInt(boss.getAttribute('data-active') || '0', 10), status = (boss.getAttribute('data-status') || '').trim(), time = parseInt(boss.getAttribute('data-time') || '0', 10), end = parseInt(boss.getAttribute('data-end') || '0', 10), ghosts = parseInt(boss.getAttribute('data-ghosts') || '0', 10);
		var statusE = boss.querySelector('[data-role="status"]'), tEl = boss.querySelector('[data-role="time"]'), now = Math.floor(Date.now() / 1000);
		if (active === 1) { boss.classList.add('state-active'); statusE.textContent = ghosts > 0 ? ('🔴 EN CURSO · ' + ghosts + ' jefe' + (ghosts === 1 ? '' : 's')) : '🔴 EN CURSO'; if (end > 0) { var rem = end - now; if (rem > 0) { tEl.textContent = '⏱ Termina en ' + fmt(rem); tEl.className = 'ov_pve_time danger'; } else { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pve_time warn'; } } else { tEl.textContent = 'Atacar ya →'; tEl.className = 'ov_pve_time danger'; } return; }
		boss.classList.remove('state-active');
		if (status === 'registration') { if (time > now) { var diffReg = time - now; statusE.textContent = '📝 Inscripción abierta'; tEl.textContent = 'Cierra en ' + fmt(diffReg); tEl.className = diffReg < 3600 ? 'ov_pve_time danger' : 'ov_pve_time warn'; } else { statusE.textContent = '📝 Cerrando…'; tEl.textContent = 'Iniciando…'; tEl.className = 'ov_pve_time warn'; } return; }
		if (status === 'scheduled') { if (time > now) { var diffSch = time - now; statusE.textContent = diffSch < 3600 ? '⚡ Inminente' : '✅ Programado'; tEl.textContent = 'Comienza en ' + fmt(diffSch); tEl.className = diffSch < 3600 ? 'ov_pve_time danger' : 'ov_pve_time'; } else { statusE.textContent = '✅ Programado'; tEl.textContent = 'Iniciando…'; tEl.className = 'ov_pve_time warn'; } return; }
		if (time > now) { var diffFut = time - now; statusE.textContent = '✅ Próximo evento'; tEl.textContent = 'Comienza en ' + fmt(diffFut); tEl.className = 'ov_pve_time'; } else { statusE.textContent = '— Sin torneo'; tEl.textContent = '--'; tEl.className = 'ov_pve_time off'; }
	}
	function updateEmpire() {
		if (!empire) return;
		var active = parseInt(empire.getAttribute('data-active') || '0', 10), time = parseInt(empire.getAttribute('data-time') || '0', 10), end = parseInt(empire.getAttribute('data-end') || '0', 10), count = parseInt(empire.getAttribute('data-count') || '0', 10);
		var status = empire.querySelector('[data-role="status"]'), tEl = empire.querySelector('[data-role="time"]'), now = Math.floor(Date.now() / 1000);
		if (active === 1) { empire.classList.add('state-active'); status.textContent = count > 0 ? ('🏛️ ' + count + ' imperio' + (count === 1 ? '' : 's') + ' activo' + (count === 1 ? '' : 's')) : '🏛️ ACTIVO'; if (end > 0) { var rem = end - now; if (rem > 0) { tEl.textContent = '⏱ Termina en ' + fmt(rem); tEl.className = 'ov_pve_time danger'; } else { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pve_time warn'; } } else { tEl.textContent = 'Atacar ya →'; tEl.className = 'ov_pve_time danger'; } return; }
		empire.classList.remove('state-active');
		if (time > now) { var diff = time - now; status.textContent = '⏰ Programado'; tEl.textContent = 'Empieza en ' + fmt(diff); tEl.className = diff < 3600 ? 'ov_pve_time danger' : 'ov_pve_time warn'; } else { status.textContent = '— Sin imperios'; tEl.textContent = '--'; tEl.className = 'ov_pve_time off'; }
	}
	function tickPvE() { updateCrisis(); updateBoss(); updateEmpire(); }
	tickPvE(); setInterval(tickPvE, 1000);
})();

/* PvP */
(function() {
	var myArena = document.getElementById('ov_pvp_myarena_card');
	var tournament = document.getElementById('ov_pvp_tournament_card');
	if (!myArena && !tournament) return;
	function fmt(sec) { if (sec <= 0) return '0s'; var d = Math.floor(sec / 86400), h = Math.floor((sec % 86400) / 3600), m = Math.floor((sec % 3600) / 60), s = sec % 60; if (d > 0) return d + 'd ' + h + 'h ' + m + 'm'; if (h > 0) return h + 'h ' + m + 'm ' + s + 's'; if (m > 0) return m + 'm ' + s + 's'; return s + 's'; }
	function updateMyArena() {
		if (!myArena) return;
		var status = (myArena.getAttribute('data-status') || '').trim(), end = parseInt(myArena.getAttribute('data-end') || '0', 10), tEl = myArena.querySelector('[data-role="time"]');
		if (!tEl) return;
		if (!myArena._startedAt) { myArena._startedAt = Math.floor(Date.now() / 1000); myArena._initialLeft = end; }
		var elapsed = Math.floor(Date.now() / 1000) - myArena._startedAt, remaining = Math.max(0, myArena._initialLeft - elapsed);
		if (remaining <= 0) { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pvp_time warn'; return; }
		tEl.textContent = fmt(remaining);
		if (status === 'active' || status === 'extra_time') { tEl.className = remaining < 3600 ? 'ov_pvp_time danger' : 'ov_pvp_time'; } else if (status === 'waiting') { tEl.className = remaining < 3600 ? 'ov_pvp_time warn' : 'ov_pvp_time'; } else { tEl.className = 'ov_pvp_time off'; }
	}
	function updateTournament() {
		if (!tournament) return;
		var status = (tournament.getAttribute('data-status') || '').trim(), time = parseInt(tournament.getAttribute('data-time') || '0', 10), tEl = tournament.querySelector('[data-role="time"]');
		if (!tEl) return;
		var now = Math.floor(Date.now() / 1000);
		if (status === 'registration') { if (time > now) { var diff = time - now; tEl.textContent = 'Cierra en ' + fmt(diff); tEl.className = diff < 3600 ? 'ov_pvp_time danger' : 'ov_pvp_time warn'; } else { tEl.textContent = 'Cerrando…'; tEl.className = 'ov_pvp_time warn'; } return; }
		if (status === 'running') { tEl.textContent = 'En curso ⚔️'; tEl.className = 'ov_pvp_time danger'; return; }
		tEl.textContent = '--'; tEl.className = 'ov_pvp_time off';
	}
	function tickPvP() { updateMyArena(); updateTournament(); }
	tickPvP(); setInterval(tickPvP, 1000);
})();

/* ============================================================
 * 🆕 BANNER BOOST FIN DE SEMANA
 * ============================================================ */
(function() {
    var banner = document.getElementById('xb_banner');
    if (!banner) return;

    try {
        var dismissedUntil = localStorage.getItem('xb_dismissed_until');
        if (dismissedUntil) {
            var until = parseInt(dismissedUntil, 10);
            if (until > Math.floor(Date.now() / 1000)) {
                banner.style.display = 'none';
                return;
            }
        }
    } catch (e) { }

    var timerEl   = document.getElementById('xb_timer');
    var seconds   = parseInt(banner.getAttribute('data-seconds') || '0', 10);
    var endAt     = Math.floor(Date.now() / 1000) + seconds;
    var reloading = false;

    function fmt(sec) {
        if (sec < 0) sec = 0;
        var d = Math.floor(sec / 86400);
        var h = Math.floor((sec % 86400) / 3600);
        var m = Math.floor((sec % 3600) / 60);
        var s = sec % 60;
        var parts = [];
        if (d > 0) parts.push(d + 'd');
        if (d > 0 || h > 0) parts.push((h < 10 ? '0' : '') + h + 'h');
        parts.push((m < 10 ? '0' : '') + m + 'm');
        parts.push((s < 10 ? '0' : '') + s + 's');
        return parts.join(' ');
    }

    function tick() {
        var left = endAt - Math.floor(Date.now() / 1000);
        if (timerEl) timerEl.textContent = fmt(left);

        if (left <= 0 && !reloading) {
            reloading = true;
            setTimeout(function() {
                try { location.reload(); } catch (e) {}
            }, 1500);
        }
    }

    tick();
    setInterval(tick, 1000);
})();

function xbDismiss() {
    var banner = document.getElementById('xb_banner');
    if (!banner) return;

    try {
        var until = Math.floor(Date.now() / 1000) + 21600;
        localStorage.setItem('xb_dismissed_until', until);
    } catch (e) { }

    banner.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    banner.style.opacity    = '0';
    banner.style.transform  = 'translateY(-10px)';

    setTimeout(function() {
        banner.style.display = 'none';
    }, 300);
}

/* ============================================================
 * 🚀 RADAR DE FLOTAS EN EL OVERVIEW (v4 - ANTI-BUCLE)
 * ------------------------------------------------------------
 * - Usa SOLO 'resttime' (totalTime) para el contador.
 * - Evita desincronización de reloj.
 * - Animación: Ida (3% -> 50%) / Vuelta (50% -> 97%).
 * - Se añade sessionStorage para evitar bucle de recargas si el 
 *   cron se retrasa, mostrando "Procesando..." en rojo.
 * ============================================================ */
(function() {
    var travelers = document.querySelectorAll('.xnova-fleet-card .traveler-container');
    if (travelers.length === 0) return;

    var pageLoadTime = Math.floor(Date.now() / 1000);
    var reloading = false;

    // --- SISTEMA ANTI-BUCLE ---
    function getReloadedList() {
        try { return JSON.parse(sessionStorage.getItem('fleet_reloaded_et') || '[]'); }
        catch (e) { return []; }
    }
    function markReloaded(id) {
        var arr = getReloadedList();
        if (arr.indexOf(id) === -1) {
            arr.push(id);
            try { sessionStorage.setItem('fleet_reloaded_et', JSON.stringify(arr)); } catch (e) {}
        }
    }
    function wasReloaded(id) {
        return getReloadedList().indexOf(id) !== -1;
    }
    // --------------------------

    function updateRadar() {
        if (reloading) return;
        var now = Math.floor(Date.now() / 1000);
        var shouldReload = false;

        travelers.forEach(function(traveler) {
            var totalTime = parseInt(traveler.getAttribute('data-fleet-total-time'), 10);
            var state     = parseInt(traveler.getAttribute('data-fleet-state'), 10);
            var fleetId   = traveler.getAttribute('data-fleet-id');

            var index   = traveler.id.replace('traveler_', '');
            var timerEl = document.getElementById('timer_' + index);

            if (isNaN(totalTime)) return;

            // Usamos un endTime local para evitar desincronización
            var endTime = parseInt(traveler.getAttribute('data-fleet-local-end-time'), 10);
            if (isNaN(endTime) || endTime === 0) {
                endTime = pageLoadTime + totalTime;
                traveler.setAttribute('data-fleet-local-end-time', endTime);
            }

            var left = endTime - now;
            var percent = 3;

            if (totalTime > 0) {
                var progress = (totalTime - left) / totalTime;
                if (state === 0) {
                    percent = 3 + (progress * 47); // IDA: 3% a 50%
                    if (percent < 3)  percent = 3;
                    if (percent > 50) percent = 50;
                } else {
                    percent = 50 + (progress * 47); // VUELTA: 50% a 97%
                    if (percent < 50) percent = 50;
                    if (percent > 97) percent = 97;
                }
            }
            traveler.style.left = percent + '%';

            if (left <= 0) {
                if (!wasReloaded(fleetId)) {
                    // Primera vez que llega a 0: Recargar
                    if (timerEl) timerEl.textContent = '00:00:00';
                    traveler.style.left = (state === 0) ? '50%' : '97%';
                    markReloaded(fleetId);
                    shouldReload = true;
                } else {
                    // Ya recargamos y sigue en 0: Mostrar Procesando...
                    if (timerEl) {
                        timerEl.textContent = 'Procesando...';
                        timerEl.style.color = '#ef4444'; // Color rojo
                        timerEl.style.borderColor = '#ef4444';
                    }
                    traveler.style.left = (state === 0) ? '50%' : '97%';
                }
            } else {
                if (timerEl) {
                    var h = Math.floor(left / 3600);
                    var m = Math.floor((left % 3600) / 60);
                    var s = left % 60;
                    timerEl.textContent = (h < 10 ? '0' : '') + h + ':' +
                                          (m < 10 ? '0' : '') + m + ':' +
                                          (s < 10 ? '0' : '') + s;
                    // Restaurar estilos por si acaso
                    timerEl.style.color = '';
                    timerEl.style.borderColor = '';
                }
            }
        });

        if (shouldReload && !reloading) {
            reloading = true;
            setTimeout(function() { window.location.reload(); }, 1500);
        }
    }

    updateRadar();
    setInterval(updateRadar, 1000);
})();

/* ============================================================
 * 🆕 ASTROIO v6.6 - BUFF CLIMÁTICO (Cuenta atrás)
 * ============================================================ */
(function() {
    var timerEl = document.getElementById('ov_buff_timer');
    if (!timerEl) return;
    var expiresAt = parseInt(timerEl.getAttribute('data-expires'), 10);
    if (isNaN(expiresAt) || expiresAt <= 0) return;
    
    function updateBuffTimer() {
        var now = Math.floor(Date.now() / 1000);
        var diff = expiresAt - now;
        if (diff <= 0) {
            timerEl.textContent = '❌ Expirado';
            timerEl.style.color = '#ef4444';
            timerEl.style.textShadow = '0 0 8px rgba(239, 68, 68, 0.5)';
            return;
        }
        var h = Math.floor(diff / 3600);
        var m = Math.floor((diff % 3600) / 60);
        var s = diff % 60;
        timerEl.textContent = (h < 10 ? '0' : '') + h + 'h ' + (m < 10 ? '0' : '') + m + 'm ' + (s < 10 ? '0' : '') + s + 's';
    }
    updateBuffTimer();
    setInterval(updateBuffTimer, 1000);
})();
</script>

{/block}
{block name="script" append}
    <script src="scripts/game/overview.js"></script>
{/block}