{block name="title" prepend}{$LNG.lm_buildings}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BUILDINGS v3.8 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrobd_    (aislado, no rompe otros módulos)
   FIX v3.8:
     - Se agregó el estilo CSS para los modales (Tema Cyan).
     - Las tablas que inyecta el AJAX ahora tienen fondo oscuro.
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
.astrobd_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Cabecera del panel (título + botón planetario) ====== */
.astrobd_panel_header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 10px 15px;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    margin-bottom: 15px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astrobd_panel_title {
    color: #ffffff;
    font-weight: 800;
    font-size: 16px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    display: inline-flex;
    align-items: center;
    gap: 10px;
    margin: 0;
}
.astrobd_panel_title::before {
    content: "🏗";
    font-size: 20px;
    filter: drop-shadow(0 0 8px rgba(0, 224, 255, 0.6));
}

/* Botón Planetario */
.astrobd_planetario_btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid rgba(0, 224, 255, 0.5);
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.4px;
    text-decoration: none;
    text-transform: uppercase;
    box-shadow: 0 2px 10px rgba(0, 102, 204, 0.5);
    transition: 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    white-space: nowrap;
}
.astrobd_planetario_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.75), 0 2px 10px rgba(0, 102, 204, 0.55);
    transform: translateY(-1px);
    color: #ffffff;
}
.astrobd_planetario_btn .astrobd_planetario_icon {
    font-size: 14px;
    line-height: 1;
}

/* ====== Cola de producción ====== */
.astrobd_queue {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 12px 15px;
    margin: 0 auto 15px auto;
    color: var(--text-main);
}
.astrobd_queue_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 10px;
    display: flex;
    align-items: center;
    gap: 8px;
}
.astrobd_queue table { width: 100%; border-collapse: collapse; font-size: 11px; }
.astrobd_queue tr { background: rgba(0, 0, 0, 0.25); border-bottom: 1px solid rgba(0, 204, 255, 0.08); }
.astrobd_queue tr:hover { background: rgba(0, 204, 255, 0.08); }
.astrobd_queue td { padding: 6px 8px; color: var(--text-main); vertical-align: middle; }
.astrobd_queue .astrobd_q_name { color: #00e0ff; font-weight: 700; font-size: 12px; }
.astrobd_queue .timer { color: #66ff99 !important; font-weight: 700; font-family: 'Courier New', monospace; font-size: 11px; }

/* Barra de progreso */
#progressbar {
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.3) !important;
    border-radius: 6px !important;
    height: 10px !important;
    overflow: hidden !important;
    margin-top: 6px !important;
}
#progressbar > div, #progressbar .progressbar-inner {
    background: linear-gradient(90deg, #0066cc, #00ccff) !important;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.7) !important;
    height: 100% !important;
}
#time { color: #00e0ff !important; font-weight: 700 !important; font-family: 'Courier New', monospace !important; font-size: 11px; }

/* Botón cancelar cola */
.build_submit.onlist {
    background: linear-gradient(135deg, rgba(170, 0, 68, 0.9), rgba(204, 34, 102, 0.9)) !important;
    border: 1px solid #ff4488 !important;
    color: #ffffff !important;
    border-radius: 6px !important;
    font-weight: 700 !important;
    font-size: 10px !important;
    padding: 4px 10px !important;
    cursor: pointer !important;
    transition: 0.25s ease !important;
    font-family: inherit !important;
}
.build_submit.onlist:hover {
    background: linear-gradient(135deg, rgba(204, 34, 102, 0.95), rgba(255, 68, 136, 0.95)) !important;
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.7) !important;
}

/* ====== Panel grid ====== */
.astrobd_panel {
    background: transparent;
    padding: 0;
    color: var(--text-main);
    max-width: 1400px;
    margin: 0 auto;
}

/* ====== Grid de tarjetas — 3 columnas ====== */
.astrobd_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 15px;
    width: 100%;
}
@media (max-width: 1200px) { .astrobd_grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 720px)  { .astrobd_grid { grid-template-columns: repeat(2, 1fr); gap: 8px; } }

/* ====== Tarjeta individual (estilo Xnova moderno) ====== */
.astrobd_card {
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
.astrobd_card:hover {
    border-color: rgba(0, 224, 255, 0.6);
    box-shadow: 0 8px 30px rgba(0, 224, 255, 0.25), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: translateY(-4px);
}

/* ====== Imagen grande (estilo Xnova) ====== */
.astrobd_card_img {
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
.astrobd_card_img::after {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(to top,
        rgba(10, 16, 24, 0.95) 0%,
        rgba(10, 16, 24, 0.75) 35%,
        rgba(10, 16, 24, 0.15) 70%,
        transparent 100%);
    pointer-events: none;
}

/* Nivel arriba a la derecha */
.astrobd_card_lvl_badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(0, 0, 0, 0.75);
    border: 1px solid rgba(0, 224, 255, 0.5);
    border-radius: 6px;
    padding: 3px 10px;
    font-size: 11px;
    font-weight: 700;
    color: #00e0ff;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    z-index: 2;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.3);
}

/* Overlay inferior con nombre */
.astrobd_card_overlay {
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
.astrobd_card_title {
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
.astrobd_card_title:hover {
    color: #00e0ff;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 1), 0 0 15px rgba(0, 224, 255, 0.9);
}
.astrobd_card_lvl {
    color: #cbd5e1;
    font-size: 11px;
    font-weight: 600;
    text-shadow: 0 1px 4px rgba(0, 0, 0, 1);
}

/* Botón basura flotante */
.astrobd_trash {
    position: absolute;
    top: 10px;
    right: 80px;
    width: 26px;
    height: 26px;
    border-radius: 6px;
    background: rgba(20, 5, 12, 0.85);
    border: 1px solid rgba(255, 68, 136, 0.6);
    color: #ff4488;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 700;
    text-decoration: none;
    transition: 0.25s ease;
    z-index: 3;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astrobd_trash:hover {
    background: rgba(255, 68, 136, 0.35);
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.8);
    color: #ffffff;
    transform: scale(1.1);
}

/* ====== Cuerpo ====== */
.astrobd_card_body {
    padding: 12px 15px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex-grow: 1;
}

/* Grid de stats tipo Xnova: 2 columnas */
.astrobd_stats_grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 6px;
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 8px;
    padding: 8px 10px;
}
.astrobd_stat_col {
    display: flex;
    flex-direction: column;
    gap: 3px;
}
.astrobd_stat_row {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 11px;
    color: var(--text-main);
}
.astrobd_stat_row .astrobd_stat_label {
    color: var(--text-muted);
    font-weight: 600;
    font-size: 10px;
}
.astrobd_stat_row .astrobd_stat_value {
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
    color: #66ff99;
    margin-left: auto;
}
.astrobd_stat_row .astrobd_stat_value.positive { color: #66ff99; }
.astrobd_stat_row .astrobd_stat_value.negative { color: #ff4488; }
.astrobd_stat_row .astrobd_stat_icon {
    font-size: 12px;
    line-height: 1;
    filter: drop-shadow(0 0 3px rgba(255, 255, 255, 0.3));
}

/* Fila de tiempo */
.astrobd_time_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 11px;
    color: var(--text-muted);
    padding: 4px 0;
    gap: 10px;
}
.astrobd_time_row .astrobd_val {
    color: #00e0ff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 65%;
    text-align: right;
}

/* ====== Fila de costos — GRID DE 3 COLUMNAS AJUSTADO ====== */
.astrobd_costs {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 6px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 8px;
    padding: 6px 8px;
}
.astrobd_cost {
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
.astrobd_cost.no { color: #ff4488; }
.astrobd_cost .astrobd_cost_icon {
    font-size: 12px;
    line-height: 1;
    display: inline-block;
    filter: drop-shadow(0 0 3px rgba(255, 255, 255, 0.3));
    flex-shrink: 0;
}
.astrobd_cost .astrobd_cost_value {
    font-family: 'Courier New', monospace;
    font-size: 11px;
    overflow: hidden;
    text-overflow: ellipsis;
    min-width: 0;
    flex: 1;
}

/* Energía */
.astrobd_energy {
    font-size: 10px;
    color: var(--text-main);
    padding: 4px 8px;
    background: rgba(0, 0, 0, 0.25);
    border-left: 3px solid #00ccff;
    border-radius: 4px;
    line-height: 1.4;
}

/* ====== Footer con botón ====== */
.astrobd_card_footer {
    padding: 0 15px 15px 15px;
}
.astrobd_form { margin: 0; }

.astrobd_btn {
    display: block;
    width: 100%;
    box-sizing: border-box;
    padding: 10px 12px;
    border: 1px solid rgba(0, 224, 255, 0.4);
    border-radius: 8px;
    font-weight: 700;
    font-size: 11px;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    color: #ffffff;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    box-shadow: 0 2px 10px rgba(0, 102, 204, 0.4);
    transition: 0.25s ease;
    font-family: inherit;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    text-transform: uppercase;
}
.astrobd_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.7), 0 2px 10px rgba(0, 102, 204, 0.5);
    transform: translateY(-2px);
}
.astrobd_btn.disabled {
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
    cursor: not-allowed;
    box-shadow: none;
}
.astrobd_btn.disabled:hover { transform: none; box-shadow: none; }

/* ====== Responsive ====== */
@media (max-width: 1200px) {
    .astrobd_card_img { height: 160px; }
}

/* ============================================================
   ASTROIO v3.8 — ESTILO MODAL NATIVO (TEMA EDIFICIOS - CYAN)
   ============================================================ */
.ui-dialog {
    background: rgba(15, 23, 42, 0.95) !important;
    backdrop-filter: blur(10px) !important;
    -webkit-backdrop-filter: blur(10px) !important;
    border: 1px solid rgba(0, 224, 255, 0.5) !important; /* Borde Cyan */
    border-radius: 12px !important;
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.8) !important;
    padding: 0 !important;
    overflow: hidden;
}
.ui-dialog-titlebar {
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.9)) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.3) !important;
    border-radius: 12px 12px 0 0 !important;
    color: #00e0ff !important; /* Texto Cyan */
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
/* Fix para Tablas inyectadas dentro del Modal */
.ui-dialog-content table {
    width: 100% !important;
    border-collapse: collapse !important;
    background: transparent !important;
    margin-top: 5px;
}
.ui-dialog-content th,
.ui-dialog-content td {
    border: 1px solid rgba(0, 224, 255, 0.2) !important;
    padding: 6px 10px !important;
    color: #cbd5e1 !important;
    background: rgba(0, 0, 0, 0.2) !important;
    font-size: 12px;
}
.ui-dialog-content th {
    color: #00e0ff !important;
    background: rgba(15, 23, 42, 0.8) !important;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 11px;
}
.ui-dialog-content img {
    border-radius: 6px;
    border: 1px solid rgba(0, 224, 255, 0.4);
    max-width: 100%;
    height: auto;
}
.ui-dialog-content p,
.ui-dialog-content span {
    color: #cbd5e1 !important;
}

@media (max-width: 720px) {
    .astrobd_wrap { padding: 8px !important; }
    .astrobd_panel { padding: 0 !important; }
    .astrobd_panel_header { padding: 8px 10px !important; margin-bottom: 10px !important; }
    .astrobd_panel_title { font-size: 13px !important; }
    .astrobd_planetario_btn { padding: 5px 10px !important; font-size: 10px !important; }
    .astrobd_queue { padding: 8px 10px !important; margin-bottom: 10px !important; }
    .astrobd_card_img { height: 100px !important; }
    .astrobd_card_lvl_badge { top: 6px !important; right: 6px !important; padding: 2px 7px !important; font-size: 9px !important; }
    .astrobd_trash { top: 6px !important; right: 56px !important; width: 22px !important; height: 22px !important; font-size: 11px !important; }
    .astrobd_card_overlay { padding: 8px 10px !important; gap: 2px !important; }
    .astrobd_card_title { font-size: 12px !important; line-height: 1.15 !important; }
    .astrobd_card_lvl { font-size: 9px !important; }
    .astrobd_card_body { padding: 8px !important; gap: 5px !important; }
    .astrobd_stats_grid { padding: 5px 6px !important; gap: 3px !important; }
    .astrobd_stat_row { font-size: 9px !important; }
    .astrobd_stat_row .astrobd_stat_label { font-size: 8px !important; }
    .astrobd_stat_row .astrobd_stat_value { font-size: 9px !important; }
    .astrobd_time_row { font-size: 9px !important; padding: 2px 0 !important; gap: 4px !important; }
    .astrobd_time_row .astrobd_val { font-size: 10px !important; max-width: 70% !important; }
    .astrobd_costs { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; gap: 3px !important; padding: 5px 6px !important; }
    .astrobd_cost { font-size: 9px !important; gap: 2px !important; }
    .astrobd_cost .astrobd_cost_icon { font-size: 10px !important; }
    .astrobd_cost .astrobd_cost_value { font-size: 9px !important; }
    .astrobd_energy { font-size: 9px !important; padding: 3px 6px !important; }
    .astrobd_card_footer { padding: 0 8px 8px 8px !important; }
    /* ====== COLA DE PRODUCCIÓN MÓVIL (SÚPER COMPACTA) ====== */
    .astrobd_queue { 
        padding: 6px !important; 
        margin-bottom: 10px !important; 
    }
    .astrobd_queue_title { 
        font-size: 10px !important; 
        padding-bottom: 2px !important; 
        margin-bottom: 6px !important; 
    }
    
    .astrobd_queue table { 
        display: block; 
        width: 100%; 
        border-spacing: 0 4px; /* Menos espacio entre filas */
    }
    .astrobd_queue tbody { 
        display: block; 
        width: 100%; 
    }
    .astrobd_queue tr {
        display: block;
        background: rgba(0, 0, 0, 0.3);
        border: 1px solid rgba(0, 224, 255, 0.1);
        border-radius: 6px;
        padding: 6px 8px; /* Espaciado interno mínimo */
    }
    .astrobd_queue td {
        display: block;
        width: 100% !important;
        padding: 0 !important;
        border: none !important;
        margin: 0 !important;
    }
    
    /* Nombre y Barra */
    .astrobd_queue .astrobd_q_name { 
        font-size: 11px !important; 
        margin-bottom: 4px !important; 
    }
    .astrobd_queue #progressbar { 
        height: 3px !important; /* Barra muy fina */
        margin: 4px 0 !important; 
    }
    
    /* Fila inferior (Tiempo + Botón) */
    .astrobd_queue td:last-child {
        display: flex !important;
        flex-wrap: wrap;
        justify-content: space-between;
        align-items: center;
        margin-top: 4px !important;
        padding-top: 4px !important;
        border-top: 1px solid rgba(255, 255, 255, 0.05) !important;
    }
    
    .astrobd_queue td:last-child br { 
        display: none; 
    }
    
    /* Tiempo en vivo */
    .astrobd_queue #time { 
        font-size: 11px !important; 
        line-height: 1 !important;
        margin: 0 !important;
    }
    
    /* Botón de Cancelar - Aplanado al máximo */
    .astrobd_queue form { 
        margin: 0 !important; 
        padding: 0 !important; 
        display: flex;
    }
    .astrobd_queue .build_submit.onlist { 
        padding: 2px 8px !important; 
        font-size: 9px !important; 
        line-height: 1.2 !important; /* Fuerza a que el texto no haga el botón alto */
        height: auto !important; /* Quita cualquier altura fija */
        min-height: 0 !important;
        border-radius: 4px !important;
        /* Estilo más limpio: solo borde rojo en lugar de fondo sólido */
        background: transparent !important;
        border: 1px solid rgba(255, 68, 136, 0.6) !important;
        color: #ff4488 !important;
        box-shadow: none !important;
    }
    
    /* Fecha final */
    .astrobd_queue .timer {
        width: 100% !important;
        text-align: right !important;
        font-size: 8px !important;
        color: #64748b !important;
        margin: 2px 0 0 0 !important;
        line-height: 1 !important;
        display: block !important;
    }
}

</style>

<div class="astrobd_wrap">

	{* ================== COLA DE PRODUCCIÓN ================== *}
	{if !empty($Queue)}
	<div class="astrobd_queue">
		<span class="astrobd_queue_title">⏳ {$LNG.sys_buildlist}</span>
		<table>
			{foreach $Queue as $List}
			{$ID = $List.element}
			<tr>
				<td style="width:70%;" class="astrobd_q_name">
					{$List@iteration}. {$LNG.tech.{$ID}} {$List.level}{if $List.destroy} {$LNG.bd_dismantle}{/if}
					{if $List@first}
					<div id="progressbar" data-time="{$List.resttime}"></div>
					{/if}
				</td>
				<td>
					{if $List@first}
					<div id="time" data-time="{$List.time}"></div>
					<form action="game.php?page=buildings" method="post" class="build_form" style="display:inline;">
						<input type="hidden" name="cmd" value="cancel">
						<button type="submit" class="build_submit onlist">{$LNG.bd_cancel}</button>
					</form>
					{else}
					<form action="game.php?page=buildings" method="post" class="build_form" style="display:inline;">
						<input type="hidden" name="cmd" value="remove">
						<input type="hidden" name="listid" value="{$List@iteration}">
						<button type="submit" class="build_submit onlist">{$LNG.bd_cancel}</button>
					</form>
					{/if}
					<br><span class="timer" data-time="{$List.endtime}">{$List.display}</span>
				</td>
			</tr>
			{/foreach}
		</table>
	</div>
	{/if}

	{* ================== PANEL CON GRID ================== *}
	<div class="astrobd_panel">

		{* ---- Cabecera con título + botón Planetario ---- *}
		<div class="astrobd_panel_header">
			<span class="astrobd_panel_title">Edificios</span>
			<a href="game.php?page=planet" class="astrobd_planetario_btn" title="Abrir Planetario">
				<span class="astrobd_planetario_icon">🪐</span>
				<span>Planetario</span>
			</a>
		</div>

		<div class="astrobd_grid">
		{foreach $BuildInfoList as $ID => $Element}
			<div class="astrobd_card">

				{* ---- Imagen grande + título superpuesto ---- *}
				<div class="astrobd_card_img"
				     style="background-image:url('{$dpath}gebaeude/{$ID}.gif');"
				     onclick="return Dialog.info({$ID})">

					{* Badge de nivel arriba a la derecha *}
					{if $Element.level > 0}
					<span class="astrobd_card_lvl_badge">Nv {$Element.level}</span>
					{/if}

					{* Botón basura flotante (destruir) *}
					{if $Element.level > 0 && $ID != 43 && ($ID != 44 || $HaveMissiles)}
					<a class="astrobd_trash tooltip_sticky" href="#"
					   onclick="event.stopPropagation(); return false;"
					   data-tooltip-content="<table style='width:300px'><tr><th colspan='2'>{$LNG.bd_price_for_destroy} {$LNG.tech.{$ID}} {$Element.level}</th></tr>{foreach $Element.destroyResources as $ResType => $ResCount}<tr><td>{$LNG.tech.{$ResType}}</td><td><span style='color:lime'>{$ResCount|number}</span></td></tr>{/foreach}<tr><td>{$LNG.bd_destroy_time}</td><td>{$Element.destroyTime|time}</td></tr><tr><td colspan='2'><form action='game.php?page=buildings' method='post' class='build_form'><input type='hidden' name='cmd' value='destroy'><input type='hidden' name='building' value='{$ID}'><button type='submit' class='build_submit onlist'>{$LNG.bd_dismantle}</button></form></td></tr></table>">✖</a>
					{/if}

					<div class="astrobd_card_overlay">
						<a class="astrobd_card_title tooltip"
						   data-tooltip-content="<div style='max-width:220px;'>{$LNG.shortDescription.{$ID}|replace:'&quot;':'&#39;'}<br><br>{$LNG.bd_remaining}<br>{foreach $Element.costOverflow as $ResType => $ResCount}{$LNG.tech.{$ResType}}: <b>{$ResCount|number}</b><br>{/foreach}</div>"
						   href="#" onclick="return Dialog.info({$ID})">
							{$LNG.tech.{$ID}}
						</a>
						<span class="astrobd_card_lvl">
							{if $Element.level > 0}
								{$LNG.bd_lvl} {$Element.level}{if $Element.maxLevel != 255}/{$Element.maxLevel}{/if}
							{else}
								{$LNG.ov_free}
							{/if}
						</span>
					</div>
				</div>

				{* ---- Cuerpo: tiempo, costos, energía ---- *}
				<div class="astrobd_card_body">

					{* Fila de tiempo — FIX: cálculo manual sin |time roto *}
					<div class="astrobd_time_row">
						<span>{$LNG.fgf_time}</span>
						<span class="astrobd_val" title="{$Element.elementTime} segundos">
							{assign var="totalSecs" value=$Element.elementTime}
							{math equation="floor(s/86400)" s=$totalSecs assign="tDays"}
							{math equation="floor((s%86400)/3600)" s=$totalSecs assign="tHours"}
							{math equation="floor((s%3600)/60)" s=$totalSecs assign="tMinutes"}
							{math equation="floor(s%60)" s=$totalSecs assign="tSecs"}
							{if $tDays > 0}{$tDays}d {/if}{$tHours|string_format:"%02d"}h {$tMinutes|string_format:"%02d"}m {$tSecs|string_format:"%02d"}s
						</span>
					</div>

					{* Grid de costos — números ACORTADOS + tooltip con número completo *}
					<div class="astrobd_costs">
						{foreach $Element.costResources as $RessID => $RessAmount}
						{assign var="fullAmount" value=$RessAmount|number}
						<div class="astrobd_cost {if $Element.costOverflow[$RessID] == 0}ok{else}no{/if}"
						     title="{$LNG.tech.{$RessID}}: {$fullAmount}">
							<span class="astrobd_cost_icon">{if $RessID == 901}🔩{elseif $RessID == 902}💎{elseif $RessID == 903}⚗️{elseif $RessID == 911}⚡{elseif $RessID == 921}🌌{elseif $RessID == 922}💰{else}▪️{/if}</span>
							<span class="astrobd_cost_value">{shortly_number($RessAmount)}</span>
						</div>
						{/foreach}
					</div>

					{* Energía *}
					{if !empty($Element.infoEnergy)}
					<div class="astrobd_energy">{$Element.infoEnergy}</div>
					{/if}

				</div>

				{* ---- Footer: botón principal ---- *}
				<div class="astrobd_card_footer">
					{if $Element.maxLevel == $Element.levelToBuild}
						<span class="astrobd_btn disabled">{$LNG.bd_maxlevel}</span>
					{elseif ($isBusy.research && ($ID == 6 || $ID == 31)) || ($isBusy.shipyard && ($ID == 15 || $ID == 21))}
						<span class="astrobd_btn disabled">{$LNG.bd_working}</span>
					{elseif !$RoomIsOk}
						<span class="astrobd_btn disabled">{$LNG.bd_no_more_fields}</span>
					{elseif $CanBuildElement && $Element.buyable}
						<form action="game.php?page=buildings" method="post" class="astrobd_form">
							<input type="hidden" name="cmd" value="insert">
							<input type="hidden" name="building" value="{$ID}">
							<button type="submit" class="astrobd_btn">
								{if $Element.level == 0}{$LNG.bd_build}{else}{$LNG.bd_build_next_level} {$Element.levelToBuild + 1}{/if}
							</button>
						</form>
					{else}
						<span class="astrobd_btn disabled">
							{if $Element.level == 0}{$LNG.bd_build}{else}{$LNG.bd_build_next_level} {$Element.levelToBuild + 1}{/if}
						</span>
					{/if}
				</div>

			</div>
		{/foreach}
		</div>

	</div>

</div>

{/block}