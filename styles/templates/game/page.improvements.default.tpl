{block name="content"}
<style>
:root {
    --bg-dark:         rgba(11, 16, 30, 0.55);
    --bg-dark-strong:  rgba(11, 16, 30, 0.80);
    --bg-card:         rgba(15, 23, 42, 0.75);
    --bg-card-hover:   rgba(30, 41, 59, 0.85);
    --bg-inner:        rgba(0, 0, 0, 0.35);
    --border-color:    #1e293b;
    --border-glow:     #3b82f6;
    --text-main:       #cbd5e1;
    --text-muted:      #94a3b8;
    --text-title:      #ffffff;
    --accent-blue:     #3b82f6;
    --accent-cyan:     #00e0ff;
    --accent-purple:   #8b5cf6;
    --accent-gold:     #fbbf24;
    --accent-green:    #4aff88;
    --accent-red:      #ef4444;
}

.astroimp_container {
    max-width: 1000px;
    margin: 0 auto;
    padding: 15px;
    color: var(--text-main);
    font-size: 11px;
    text-align: center;
}

.astroimp_title {
    display: block;
    text-transform: uppercase;
    color: var(--accent-gold);
    border-bottom: 1px solid rgba(251, 191, 36, 0.3);
    padding: 12px 18px;
    margin-bottom: 16px;
    font-size: 14px;
    letter-spacing: 1.2px;
    font-weight: 700;
    text-align: left;
    border-radius: 10px;
    background: linear-gradient(135deg, rgba(120, 53, 15, 0.55), rgba(180, 83, 9, 0.55));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
}
.astroimp_back {
    float: right;
    color: var(--accent-gold);
    text-decoration: none;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    transition: all 0.2s ease;
}
.astroimp_back:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.9);
}
.astroimp_info_btn {
    display: inline-block;
    margin-left: 10px;
    padding: 3px 8px;
    background: rgba(0, 224, 255, 0.1);
    border: 1px solid rgba(0, 224, 255, 0.4);
    border-radius: 4px;
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 10px;
    font-weight: 700;
    text-transform: none;
    transition: all 0.2s ease;
}
.astroimp_info_btn:hover {
    background: rgba(0, 224, 255, 0.3);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    color: #fff;
}

/* ── MODAL DE INFORMACIÓN ── */
.astroimp_modal {
    display: none;
    position: fixed;
    z-index: 9999;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.75);
    backdrop-filter: blur(5px);
    -webkit-backdrop-filter: blur(5px);
}
.astroimp_modal_content {
    background: linear-gradient(135deg, #0f172a, #1e293b);
    margin: 8% auto;
    padding: 20px 25px;
    border: 1px solid var(--accent-gold);
    border-radius: 12px;
    width: 85%;
    max-width: 600px;
    text-align: left;
    box-shadow: 0 0 40px rgba(251, 191, 36, 0.4);
    color: var(--text-main);
    animation: modalFadeIn 0.3s ease;
}
@keyframes modalFadeIn {
    from { opacity: 0; transform: translateY(-20px); }
    to { opacity: 1; transform: translateY(0); }
}
.astroimp_modal_close {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
    transition: color 0.2s;
}
.astroimp_modal_close:hover {
    color: var(--accent-red);
}
.astroimp_modal_content h2 {
    margin-top: 0;
    color: var(--accent-gold);
    font-size: 16px;
    border-bottom: 1px solid rgba(251, 191, 36, 0.3);
    padding-bottom: 10px;
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astroimp_modal_list {
    list-style: none;
    padding: 0;
    margin: 15px 0 0 0;
}
.astroimp_modal_list li {
    margin-bottom: 12px;
    font-size: 12px;
    line-height: 1.5;
    border-bottom: 1px solid rgba(255,255,255,0.08);
    padding-bottom: 8px;
    color: #cbd5e1;
}
.astroimp_modal_list li:last-child {
    border-bottom: none;
}
.astroimp_modal_list li strong {
    color: var(--accent-gold);
    display: block;
    margin-bottom: 4px;
    font-size: 13px;
}

/* ── MENSAJES DE ÉXITO / ERROR ── */
.astroimp_msg_success {
    display: block;
    background: rgba(74, 255, 136, 0.12);
    border: 1px solid rgba(74, 255, 136, 0.4);
    border-left: 4px solid var(--accent-green);
    color: var(--accent-green);
    padding: 10px 14px;
    border-radius: 10px;
    margin-bottom: 12px;
    font-weight: 700;
    font-size: 11px;
    text-align: center;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    box-shadow: 0 0 20px rgba(74, 255, 136, 0.15);
}
.astroimp_msg_error {
    display: block;
    background: rgba(239, 68, 68, 0.12);
    border: 1px solid rgba(239, 68, 68, 0.4);
    border-left: 4px solid var(--accent-red);
    color: #ff6b6b;
    padding: 10px 14px;
    border-radius: 10px;
    margin-bottom: 12px;
    font-weight: 700;
    font-size: 11px;
    text-align: center;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    box-shadow: 0 0 20px rgba(239, 68, 68, 0.15);
}

/* ── TABS ── */
.astroimp_tabs {
    display: inline-block;
    margin-bottom: 18px;
}
.astroimp_tabs a {
    display: inline-block;
    padding: 9px 18px;
    margin: 0 4px;
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.85), rgba(15, 23, 42, 0.85));
    color: var(--accent-gold);
    text-decoration: none;
    border-radius: 8px;
    border: 1px solid var(--border-color);
    transition: all 0.2s ease;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astroimp_tabs a:hover {
    background: linear-gradient(135deg, rgba(180, 83, 9, 0.85), rgba(120, 53, 15, 0.85));
    color: #ffffff;
    border-color: var(--accent-gold);
    box-shadow: 0 0 15px rgba(251, 191, 36, 0.4);
    transform: translateY(-1px);
}
.astroimp_tabs a.active {
    background: linear-gradient(135deg, var(--accent-gold), #d97706);
    color: #0f1624;
    border-color: #fde047;
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.6);
    font-weight: 800;
}

/* ── BOTONES DE FILTRO (COMPRAR) ── */
.astroimp_filters {
    display: inline-block;
    margin-bottom: 15px;
}
.astroimp_filters a {
    display: inline-block;
    padding: 7px 16px;
    margin: 0 4px;
    background: rgba(30, 41, 59, 0.85);
    color: var(--accent-cyan);
    text-decoration: none;
    border-radius: 6px;
    border: 1px solid var(--border-color);
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    transition: all 0.2s ease;
}
.astroimp_filters a:hover {
    background: rgba(0, 224, 255, 0.2);
    border-color: var(--accent-cyan);
    color: #fff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}
.astroimp_filters a.active {
    background: var(--accent-cyan);
    color: #0f1624;
    border-color: #ffffff;
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.6);
    font-weight: 800;
}

/* ── CABECERA ── */
.astroimp_header_unit {
    display: block;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-left: 4px solid var(--accent-gold);
    border-radius: 12px;
    padding: 12px;
    margin: 0 auto 18px auto;
    max-width: 640px;
    text-align: left;
    box-sizing: border-box;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astroimp_header_row {
    display: block;
    overflow: hidden;
}
.astroimp_header_img {
    float: left;
    width: 68px;
    height: 68px;
    background: var(--bg-inner);
    border-radius: 10px;
    border: 1px solid rgba(251, 191, 36, 0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    margin-right: 12px;
    box-shadow: 0 0 15px rgba(251, 191, 36, 0.15);
}
.astroimp_header_img img {
    max-width: 60px;
    max-height: 60px;
    display: block;
}
.astroimp_header_info {
    display: block;
    overflow: hidden;
    padding-top: 4px;
}
.astroimp_header_name {
    display: block;
    color: var(--accent-gold);
    font-size: 13px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    margin-bottom: 8px;
    text-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
}
.astroimp_header_select {
    display: block;
    width: 100%;
    padding: 7px 10px;
    background: var(--bg-inner);
    color: var(--text-main);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    font-size: 11px;
    cursor: pointer;
    box-sizing: border-box;
    transition: all 0.2s ease;
}
.astroimp_header_select:focus {
    outline: none;
    border-color: var(--accent-gold);
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
}
.astroimp_header_select optgroup {
    background: #0a0f1a;
    color: var(--accent-gold);
    font-weight: bold;
}
.astroimp_header_select option {
    background: #0a0f1a;
    color: var(--text-main);
}

/* ── TÍTULOS DE SECCIÓN ── */
.astroimp_section_title {
    display: block;
    text-transform: uppercase;
    color: var(--accent-gold);
    font-size: 11px;
    letter-spacing: 1.2px;
    margin: 18px 0 12px 0;
    padding: 10px 15px;
    border-left: 4px solid var(--accent-gold);
    background: linear-gradient(135deg, rgba(120, 53, 15, 0.55), rgba(180, 83, 9, 0.55));
    border-radius: 8px;
    font-weight: 700;
    text-align: left;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
}

/* ══════════════════════════════════════════════
   ── LAYOUT RADIAL (CRUZ) DE RANURAS ──
   ══════════════════════════════════════════════ */
.astroimp_equip_layout {
    position: relative;
    width: 100%;
    max-width: 560px;
    height: 420px;
    margin: 0 auto 22px auto;
    background: rgba(15, 23, 42, 0.55);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

/* La nave/defensa en el centro (CUADRADO) */
.astroimp_ship_center {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 130px;
    height: 130px;
    border-radius: 12px;
    border: 1px solid rgba(251, 191, 36, 0.5);
    background: linear-gradient(135deg, rgba(120, 53, 15, 0.55), rgba(15, 23, 42, 0.85));
    display: flex;
    justify-content: center;
    align-items: center;
    box-shadow:
        0 0 25px rgba(251, 191, 36, 0.35),
        inset 0 0 15px rgba(251, 191, 36, 0.1);
    z-index: 2;
    padding: 8px;
    box-sizing: border-box;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astroimp_ship_center img {
    max-width: 100%;
    max-height: 100%;
    width: auto;
    height: auto;
    display: block;
    border-radius: 6px;
}

/* Las 4 ranuras alrededor (cruz) */
.astroimp_slot {
    position: absolute;
    width: 110px;
    height: 110px;
    border: 1px solid var(--border-color);
    border-radius: 12px;
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    padding: 6px;
    box-sizing: border-box;
    transition: all 0.25s ease;
    z-index: 1;
    font-size: 9px;
    line-height: 1.2;
    overflow: hidden;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
}
.astroimp_slot.filled {
    border-color: var(--accent-gold);
    background: linear-gradient(135deg, rgba(120, 53, 15, 0.75), rgba(15, 23, 42, 0.85));
    box-shadow:
        0 0 20px rgba(251, 191, 36, 0.45),
        inset 0 0 15px rgba(251, 191, 36, 0.08);
}
.astroimp_slot.empty {
    border-style: dashed;
    border-color: #334455;
    color: var(--text-muted);
}
.astroimp_slot.empty:hover {
    border-style: solid;
    border-color: var(--accent-gold);
    box-shadow: 0 0 18px rgba(251, 191, 36, 0.4);
    background: rgba(251, 191, 36, 0.08);
    transform: scale(1.03);
}
.astroimp_slot .slot_label {
    position: absolute;
    top: 4px;
    left: 6px;
    font-size: 8px;
    color: var(--accent-gold);
    text-transform: uppercase;
    letter-spacing: 0.6px;
    font-weight: 800;
}
.astroimp_slot .slot_icon {
    font-size: 18px;
    display: block;
    margin-bottom: 2px;
    line-height: 1;
}
.astroimp_slot .slot_chain {
    display: block;
    color: var(--accent-gold);
    font-weight: 800;
    font-size: 9px;
    margin-bottom: 1px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100%;
}
.astroimp_slot .slot_lvl {
    display: block;
    color: var(--accent-cyan);
    font-size: 9px;
    font-weight: 700;
    margin-bottom: 2px;
}
.astroimp_slot .slot_spec {
    display: block;
    color: var(--accent-green);
    font-size: 9px;
    font-weight: 800;
    margin-bottom: 4px;
}
.astroimp_slot .slot_remove {
    display: inline-block;
    padding: 3px 8px;
    background: linear-gradient(135deg, rgba(239, 68, 68, 0.85), rgba(153, 27, 27, 0.85));
    border: 1px solid var(--accent-red);
    border-radius: 6px;
    color: #ffffff !important;
    text-decoration: none;
    font-size: 8px;
    font-weight: 800;
    text-transform: uppercase;
    text-shadow: 0 1px 2px rgba(0,0,0,0.4);
    transition: all 0.2s ease;
}
.astroimp_slot .slot_remove:hover {
    background: linear-gradient(135deg, var(--accent-red), #dc2626);
    box-shadow: 0 0 15px rgba(239, 68, 68, 0.7);
    transform: translateY(-1px);
}
.astroimp_slot .slot_empty_txt {
    color: var(--text-muted);
    font-style: italic;
    font-size: 10px;
}

/* Posiciones en cruz */
.astroimp_slot_top    { top: 20px;   left: 50%; transform: translateX(-50%); }
.astroimp_slot_bottom { bottom: 20px; left: 50%; transform: translateX(-50%); }
.astroimp_slot_left   { left: 20px;  top: 50%;  transform: translateY(-50%); }
.astroimp_slot_right  { right: 20px; top: 50%;  transform: translateY(-50%); }

/* ── CATEGORÍA (Nave / Defensa) ── */
.cat_badge {
    display: block;
    font-size: 8px;
    font-weight: 800;
    letter-spacing: 0.5px;
    padding: 2px 6px;
    border-radius: 4px;
    margin-bottom: 1px;
    text-transform: uppercase;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.cat_ship {
    color: var(--accent-green);
    background: rgba(74, 255, 136, 0.12);
    border: 1px solid rgba(74, 255, 136, 0.35);
    box-shadow: 0 0 8px rgba(74, 255, 136, 0.15);
}
.cat_defense {
    color: var(--accent-cyan);
    background: rgba(0, 224, 255, 0.12);
    border: 1px solid rgba(0, 224, 255, 0.35);
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.15);
}

/* ── INVENTARIO GRID ── */
.astroimp_inv_grid {
    display: inline-block;
    margin: 0 auto;
    max-width: 720px;
}
.astroimp_inv_cell {
    display: inline-flex !important; /* Cambiamos a flex para controlar la altura */
    flex-direction: column !important;
    align-items: center !important;
    width: 115px; 
    height: 165px; 
    margin: 4px;
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 6px 4px 30px 4px !important; /* 30px abajo para los botones */
    text-align: center;
    vertical-align: top;
    font-size: 8px;
    color: var(--text-main);
    position: relative;
    overflow: hidden;
    box-sizing: border-box;
    transition: all 0.2s ease;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.4);
}

.astroimp_inv_cell.empty {
    background: rgba(11, 16, 30, 0.55);
    border-style: dashed;
    border-color: #334455;
    color: #556677;
    height: 155px;
    padding-bottom: 4px !important; /* Las vacías no llevan botones */
}
.astroimp_inv_cell:hover {
    border-color: var(--accent-gold);
    box-shadow: 0 0 15px rgba(251, 191, 36, 0.35);
    transform: translateY(-2px);
}
.astroimp_inv_cell.empty:hover {
    transform: none;
    border-color: #334455;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.4);
}
.astroimp_inv_cell .icon {
    display: block;
    font-size: 16px;
    margin-bottom: 2px;
    line-height: 1;
}
.astroimp_inv_cell .icon {
    display: block;
    font-size: 14px !important; /* Icono un poco más pequeño */
    margin-bottom: 0 !important;
    line-height: 1;
}

.astroimp_inv_cell .name,
.astroimp_inv_cell .lvl,
.astroimp_inv_cell .spec,
.astroimp_inv_cell .qty,
.astroimp_inv_cell .cat_badge {
    white-space: normal !important; /* Permite que el texto baje de línea */
    display: flex !important;
    flex-direction: column !important; /* Fuerza a que sea uno debajo del otro */
    justify-content: center !important; /* Los centra en el espacio vacío */
    align-items: center !important;
    flex-grow: 1 !important; /* Ocupa todo el espacio vertical disponible */
    font-size: 8.5px !important;
    line-height: 1.3 !important;
    text-align: center !important;
    width: 100% !important;
    margin: 2px 0 !important;
    color: var(--accent-green) !important;
    font-weight: 800 !important;
}

.astroimp_inv_cell form {
    display: grid !important;
    grid-template-columns: repeat(4, 1fr) !important; /* Fuerza las 4 columnas */
    gap: 1px !important; /* Separación mínima */
    width: 100% !important;
    margin: 0 !important;
    padding: 0 2px !important;
    position: absolute !important;
    bottom: 4px !important;
    left: 0 !important;
    box-sizing: border-box !important;
}

.astroimp_inv_cell .slot_btn {
    display: block !important;
    width: 100% !important;
    height: 16px !important; /* Forzamos una altura pequeña */
    padding: 0 !important; /* Eliminamos cualquier padding del tema base */
    margin: 0 !important;
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.85), rgba(15, 23, 42, 0.85)) !important;
    color: var(--accent-gold) !important;
    border: 1px solid var(--border-color) !important;
    border-radius: 3px !important;
    font-size: 7px !important; /* Letra mini */
    font-weight: 800 !important;
    line-height: 14px !important; /* Centra el texto verticalmente */
    cursor: pointer !important;
    text-decoration: none !important;
    transition: all 0.15s ease !important;
    text-align: center !important;
    box-sizing: border-box !important;
    min-width: 0 !important; /* Crucial: impide que el botón se desborde */
}
.astroimp_inv_cell .slot_btn:hover {
    background: linear-gradient(135deg, var(--accent-gold), #d97706);
    color: #0f1624;
    border-color: #fde047;
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.6);
}

/* ── STATS ── */
.astroimp_stats {
    display: inline-block;
    width: 100%;
    max-width: 520px;
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-left: 4px solid var(--accent-green);
    border-radius: 12px;
    padding: 14px;
    margin-top: 18px;
    text-align: left;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astroimp_stats h3 {
    margin: 0 0 12px 0;
    color: var(--accent-green);
    font-size: 12px;
    text-transform: uppercase;
    text-align: center;
    letter-spacing: 1.2px;
    font-weight: 800;
    border-bottom: 1px solid rgba(74, 255, 136, 0.2);
    padding-bottom: 8px;
    text-shadow: 0 0 10px rgba(74, 255, 136, 0.3);
}
.astroimp_stats p {
    margin: 6px 0;
    font-size: 11px;
    padding-left: 30px;
    color: var(--text-main);
}
.astroimp_stats p strong {
    color: var(--accent-gold);
}

/* ── COMPRAR / VENDER ── */
.astroimp_shop,
.astroimp_sell {
    display: inline-block;
    width: 100%;
    text-align: center;
}
.shop-item,
.sell-item {
    display: inline-block;
    width: 250px;
    margin: 5px;
    padding: 12px;
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    text-align: left;
    vertical-align: top;
    font-size: 10px;
    transition: all 0.25s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
}
.shop-item:hover,
.sell-item:hover {
    border-color: var(--accent-gold);
    box-shadow:
        0 8px 25px rgba(251, 191, 36, 0.25),
        0 4px 15px rgba(0, 0, 0, 0.5);
    transform: translateY(-3px);
}
.shop-item span,
.sell-item span {
    display: block;
    margin-bottom: 5px;
    color: var(--text-main);
    line-height: 1.4;
}
.shop-item .shop-spec,
.sell-item .sell-spec {
    color: var(--accent-green);
    font-weight: 800;
    font-size: 10px;
}
.shop-item .price,
.sell-item .price {
    color: var(--accent-gold);
    font-weight: 800;
    font-size: 11px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}
.shop-item button,
.sell-item button {
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.85), rgba(15, 23, 42, 0.85));
    color: var(--accent-gold);
    border: 1px solid var(--border-color);
    padding: 7px 14px;
    border-radius: 8px;
    cursor: pointer;
    font-size: 10px;
    font-weight: 800;
    text-transform: uppercase;
    margin-top: 6px;
    transition: all 0.2s ease;
    letter-spacing: 0.5px;
}
.shop-item button:hover,
.sell-item button:hover {
    background: linear-gradient(135deg, var(--accent-gold), #d97706);
    color: #0f1624;
    border-color: #fde047;
    box-shadow: 0 0 15px rgba(251, 191, 36, 0.5);
    transform: translateY(-1px);
}
.sell-item input[type=number] {
    width: 55px;
    padding: 5px;
    border-radius: 6px;
    border: 1px solid var(--border-color);
    background: var(--bg-inner);
    color: #fff;
    font-size: 10px;
    margin-top: 4px;
}
.sell-item input[type=number]:focus {
    outline: none;
    border-color: var(--accent-gold);
    box-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}
.astroimp_empty {
    color: var(--text-muted);
    font-style: italic;
    padding: 30px;
    display: block;
    text-align: center;
    font-size: 12px;
}
.astroimp_info {
    display: inline-block;
    margin: 6px 0 12px 0;
    padding: 8px 14px;
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(251, 191, 36, 0.3);
    border-radius: 8px;
    font-size: 11px;
    color: var(--accent-gold);
    font-weight: 700;
}
@media (max-width: 720px) {
    /* 1. Grid de 2 columnas exactas (ni muy grandes ni muy pequeños) */
    .astroimp_inv_grid {
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important;
        gap: 8px !important;
        width: 100% !important;
        padding: 0 5px !important;
    }

    /* 2. Tarjeta adaptada para 2 columnas */
    .astroimp_inv_cell {
        width: calc(50% - 8px) !important; /* Ocupa la mitad de la pantalla menos el gap */
        max-width: 160px !important; /* Evita que se estire demasiado en tablets */
        height: 170px !important; /* Altura fija para que todas se vean iguales */
        padding: 8px 4px 30px 4px !important; /* 30px abajo para los botones */
        margin: 0 !important;
        display: flex !important;
        flex-direction: column !important;
        align-items: center !important;
        box-sizing: border-box !important;
    }

    /* 3. Ocultar las vacías para que no estorben */
    .astroimp_inv_cell.empty {
        display: none !important;
    }

    /* 4. Nombre e Icono compactos */
    .astroimp_inv_cell .icon {
        font-size: 16px !important;
        margin-bottom: 2px !important;
    }
    .astroimp_inv_cell .name {
        font-size: 8px !important;
        width: 100% !important;
        text-align: center !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
    }

    /* 5. ¡LA MAGIA! Aquí hacemos que los stats se apilen */
    .astroimp_inv_cell .spec {
        white-space: normal !important; /* Permite que el texto baje de línea */
        display: flex !important;
        flex-direction: column !important; /* Fuerza a que sea uno debajo del otro */
        justify-content: center !important; /* Los centra en el espacio vacío */
        align-items: center !important;
        flex-grow: 1 !important; /* Ocupa todo el espacio vertical disponible */
        font-size: 8.5px !important;
        line-height: 1.3 !important;
        text-align: center !important;
        width: 100% !important;
        margin: 2px 0 !important;
        color: var(--accent-green) !important;
        font-weight: 800 !important;
    }

    /* 6. Achicar el nivel y cantidad para que no quiten espacio */
    .astroimp_inv_cell .lvl,
    .astroimp_inv_cell .qty {
        font-size: 8px !important;
        margin-bottom: 1px !important;
    }

    /* 7. Los botones R1-R4 anclados al fondo */
    .astroimp_inv_cell form {
        display: grid !important;
        grid-template-columns: repeat(4, 1fr) !important;
        gap: 1px !important;
        width: 100% !important;
        padding: 0 2px !important;
        position: absolute !important;
        bottom: 6px !important;
        left: 0 !important;
        box-sizing: border-box !important;
        margin: 0 !important;
    }
    
    .astroimp_inv_cell .slot_btn {
        height: 18px !important;
        line-height: 16px !important;
        font-size: 8px !important;
        padding: 0 !important;
        width: 100% !important;
    }
	
    /* 1. Convertir el contenedor en Grid solo en móvil */
    .astroimp_equip_layout {
        display: grid !important;
        grid-template-columns: 1fr auto 1fr !important;
        grid-template-rows: auto auto auto !important;
        gap: 8px !important;
        padding: 15px 5px !important;
        height: auto !important; /* Deja que la altura se adapte al contenido */
        min-height: 320px !important;
        max-width: 100% !important;
    }

    /* 2. La nave central: anular posición absoluta y usar Grid */
    .astroimp_ship_center {
        position: relative !important;
        top: auto !important;
        left: auto !important;
        transform: none !important;
        grid-column: 2 !important;
        grid-row: 2 !important;
        width: 85px !important;
        height: 85px !important;
        margin: 0 auto !important;
    }

    /* 3. Las ranuras (R1-R4): anular absolutos y usar Grid */
    .astroimp_slot {
        position: relative !important;
        top: auto !important;
        left: auto !important;
        right: auto !important;
        bottom: auto !important;
        transform: none !important;
        width: 85px !important;
        height: 85px !important;
        padding: 4px !important;
        margin: 0 auto !important;
    }

    /* 4. Asignar cada ranura a su celda en la cuadrícula */
    .astroimp_slot_top    { grid-column: 2 !important; grid-row: 1 !important; }
    .astroimp_slot_bottom { grid-column: 2 !important; grid-row: 3 !important; }
    .astroimp_slot_left   { grid-column: 1 !important; grid-row: 2 !important; }
    .astroimp_slot_right  { grid-column: 3 !important; grid-row: 2 !important; }

    /* 5. Achicar un poquito las letras dentro de las ranuras para que quepan */
    .astroimp_slot .slot_label { font-size: 7px !important; top: 2px !important; left: 4px !important; }
    .astroimp_slot .slot_icon { font-size: 14px !important; margin-bottom: 0 !important; }
    .astroimp_slot .slot_chain { font-size: 7.5px !important; margin-bottom: 0 !important; }
    .astroimp_slot .slot_lvl { font-size: 7.5px !important; margin-bottom: 0 !important; }
    .astroimp_slot .slot_spec { font-size: 7.5px !important; margin-bottom: 2px !important; }
    .astroimp_slot .slot_remove { font-size: 7px !important; padding: 2px 4px !important; }

	    /* ====== COMPRAR Y VENDER (1x2 EN MÓVIL) ====== */
    
    /* 1. Filtros (Todas, Naves, Defensas) adaptables */
    .astroimp_filters {
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important;
        gap: 4px !important;
        width: 100% !important;
        padding: 0 5px !important;
        margin-bottom: 12px !important;
    }
    .astroimp_filters a {
        flex: 1 1 auto !important;
        margin: 0 !important;
        padding: 6px 8px !important;
        font-size: 9px !important;
        text-align: center !important;
    }

    /* 2. Contenedores de tienda y venta */
    .astroimp_shop,
    .astroimp_sell {
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important;
        gap: 8px !important;
        width: 100% !important;
        padding: 0 5px !important;
        box-sizing: border-box !important;
    }

    /* 3. Tarjetas de ítems (2 columnas exactas) */
    .shop-item,
    .sell-item {
        width: calc(50% - 8px) !important; /* Ocupa la mitad menos el gap */
        max-width: 170px !important; /* Evita que se estiren de más */
        margin: 0 !important; /* Quitamos el margen fijo de escritorio */
        padding: 8px 6px !important;
        display: flex !important;
        flex-direction: column !important;
        box-sizing: border-box !important;
        text-align: center !important; /* Centramos el texto */
    }

    /* 4. Achicar textos internos de las tarjetas */
    .shop-item span,
    .sell-item span {
        font-size: 8.5px !important;
        line-height: 1.2 !important;
        margin-bottom: 3px !important;
    }

    /* 5. Botones de acción a lo ancho de la tarjeta */
    .shop-item button,
    .sell-item button {
        width: 100% !important;
        padding: 6px 0 !important;
        font-size: 8.5px !important;
        margin-top: auto !important; /* Empuja el botón al fondo de la tarjeta */
        box-sizing: border-box !important;
    }

    /* 6. Input de cantidad en Vender */
    .sell-item input[type="number"] {
        width: 100% !important;
        max-width: 60px !important;
        margin: 4px auto !important;
        padding: 4px !important;
        font-size: 10px !important;
        text-align: center !important;
    }
	
}
</style>

<div class="astroimp_container">

    <div class="astroimp_title">
        🔧 MEJORAS &mdash; {$unit_name}
        <a href="javascript:void(0);" onclick="document.getElementById('infoModal').style.display='block';" class="astroimp_info_btn">❓ Información</a>
        <a href="game.php?page=hangar" class="astroimp_back">← Volver al Hangar</a>
    </div>

    {* ── MENSAJES DE ÉXITO / ERROR ── *}
    {if $msg_success}
        <div class="astroimp_msg_success">{$msg_success}</div>
    {/if}
    {if $msg_error}
        <div class="astroimp_msg_error">{$msg_error}</div>
    {/if}

    <div class="astroimp_tabs">
        <a href="game.php?page=improvements&unit_id={$unit_id}&tab=equipar" class="{if $tab == 'equipar'}active{/if}">🔧 Equipar</a>
        <a href="game.php?page=improvements&unit_id={$unit_id}&tab=comprar" class="{if $tab == 'comprar'}active{/if}">🛒 Comprar</a>
        <a href="game.php?page=improvements&unit_id={$unit_id}&tab=vender" class="{if $tab == 'vender'}active{/if}">💰 Vender</a>
    </div>

    {if $tab == 'equipar'}

        <!-- ── CABECERA: IMAGEN + DROPDOWN ── -->
        <div class="astroimp_header_unit">
            <div class="astroimp_header_row">
                <div class="astroimp_header_img">
                    <img src="styles/theme/gow/gebaeude/{$unit_id}.gif" alt="{$unit_name}" onerror="this.style.display='none';">
                </div>
                <div class="astroimp_header_info">
                    <span class="astroimp_header_name">
                        {$unit_name}
                        <span class="cat_badge {if $category == 'ship'}cat_ship{else}cat_defense{/if}" style="display:inline-block;margin-left:8px;">
                            {if $category == 'ship'}🚀 NAVE{else}🛡️ DEFENSA{/if}
                        </span>
                    </span>
                    <select class="astroimp_header_select" onchange="if(this.value) window.location.href='game.php?page=improvements&unit_id='+this.value;">
                        <option value="">-- Seleccionar unidad --</option>
                        <optgroup label="🚀 Naves">
                            {foreach $selector as $s}
                                {if $s.cat == 'ship'}
                                    <option value="{$s.id}" {if $s.id == $unit_id}selected{/if}>{$s.name}</option>
                                {/if}
                            {/foreach}
                        </optgroup>
                        <optgroup label="🛡️ Defensas">
                            {foreach $selector as $s}
                                {if $s.cat == 'defense'}
                                    <option value="{$s.id}" {if $s.id == $unit_id}selected{/if}>{$s.name}</option>
                                {/if}
                            {/foreach}
                        </optgroup>
                    </select>
                </div>
            </div>
        </div>

        <!-- ══════════════════════════════════════════════
             ── 4 RANURAS EN CRUZ (NAVE AL CENTRO) ──
             ══════════════════════════════════════════════ -->
        <div class="astroimp_section_title">🔧 Ranuras de mejora ({$unit_name})</div>
        <div class="astroimp_equip_layout">

            {* Ranura 1 - ARRIBA *}
            <div class="astroimp_slot {if $equipped[1]}filled{else}empty{/if} astroimp_slot_top">
                <span class="slot_label">R1</span>
                {if $equipped[1]}
                    <span class="slot_icon">{$equipped[1].icon_display}</span>
                    <span class="slot_chain">{$equipped[1].chain_name}</span>
                    <span class="slot_lvl">Nv {$equipped[1].level}</span>
                    <span class="slot_spec">{$equipped[1].spec}</span>
                    <a href="game.php?page=improvements&mode=doUnequip&unit_id={$unit_id}&slot=1" class="slot_remove">❌ Quitar</a>
                {else}
                    <span class="slot_empty_txt">[Vacía]</span>
                {/if}
            </div>

            {* Ranura 2 - DERECHA *}
            <div class="astroimp_slot {if $equipped[2]}filled{else}empty{/if} astroimp_slot_right">
                <span class="slot_label">R2</span>
                {if $equipped[2]}
                    <span class="slot_icon">{$equipped[2].icon_display}</span>
                    <span class="slot_chain">{$equipped[2].chain_name}</span>
                    <span class="slot_lvl">Nv {$equipped[2].level}</span>
                    <span class="slot_spec">{$equipped[2].spec}</span>
                    <a href="game.php?page=improvements&mode=doUnequip&unit_id={$unit_id}&slot=2" class="slot_remove">❌ Quitar</a>
                {else}
                    <span class="slot_empty_txt">[Vacía]</span>
                {/if}
            </div>

            {* Ranura 3 - ABAJO *}
            <div class="astroimp_slot {if $equipped[3]}filled{else}empty{/if} astroimp_slot_bottom">
                <span class="slot_label">R3</span>
                {if $equipped[3]}
                    <span class="slot_icon">{$equipped[3].icon_display}</span>
                    <span class="slot_chain">{$equipped[3].chain_name}</span>
                    <span class="slot_lvl">Nv {$equipped[3].level}</span>
                    <span class="slot_spec">{$equipped[3].spec}</span>
                    <a href="game.php?page=improvements&mode=doUnequip&unit_id={$unit_id}&slot=3" class="slot_remove">❌ Quitar</a>
                {else}
                    <span class="slot_empty_txt">[Vacía]</span>
                {/if}
            </div>

            {* Ranura 4 - IZQUIERDA *}
            <div class="astroimp_slot {if $equipped[4]}filled{else}empty{/if} astroimp_slot_left">
                <span class="slot_label">R4</span>
                {if $equipped[4]}
                    <span class="slot_icon">{$equipped[4].icon_display}</span>
                    <span class="slot_chain">{$equipped[4].chain_name}</span>
                    <span class="slot_lvl">Nv {$equipped[4].level}</span>
                    <span class="slot_spec">{$equipped[4].spec}</span>
                    <a href="game.php?page=improvements&mode=doUnequip&unit_id={$unit_id}&slot=4" class="slot_remove">❌ Quitar</a>
                {else}
                    <span class="slot_empty_txt">[Vacía]</span>
                {/if}
            </div>

            {* Centro: La nave/defensa (CUADRADO) *}
            <div class="astroimp_ship_center">
                <img src="styles/theme/gow/gebaeude/{$unit_id}.gif" alt="{$unit_name}" onerror="this.style.display='none';">
            </div>

        </div>

        <!-- ── INVENTARIO GRID 6x5 ── -->
        <div class="astroimp_section_title">📦 Inventario &mdash; {$inv_slots}/30 espacios (clic en R1-R4 para equipar)</div>
        <div class="astroimp_inv_grid">
            {assign var="cellCount" value=0}
            {foreach $inventory as $inv}
                <div class="astroimp_inv_cell" title="{$inv.chain_name} - Nivel {$inv.level} - {$inv.spec}">
                    <span class="icon">{$inv.icon_display}</span>
                    <span class="name">{$inv.chain_name}</span>
                    <span class="lvl">Nv {$inv.level}{if $inv.is_penalized} (P){/if}</span>
                    <span class="cat_badge {if $inv.category == 'ship'}cat_ship{else}cat_defense{/if}">
                        {if $inv.category == 'ship'}🚀 NAVE{else}🛡️ DEF{/if}
                    </span>
                    <span class="spec">{$inv.spec}</span>
                    <span class="qty">x{$inv.quantity}</span>
                    <form method="post" action="game.php?page=improvements&mode=doEquip">
                        <input type="hidden" name="unit_id" value="{$unit_id}">
                        <input type="hidden" name="item_id" value="{$inv.item_id}">
                        <button type="submit" name="slot" value="1" class="slot_btn" title="Equipar en Ranura 1">R1</button>
                        <button type="submit" name="slot" value="2" class="slot_btn" title="Equipar en Ranura 2">R2</button>
                        <button type="submit" name="slot" value="3" class="slot_btn" title="Equipar en Ranura 3">R3</button>
                        <button type="submit" name="slot" value="4" class="slot_btn" title="Equipar en Ranura 4">R4</button>
                    </form>
                </div>
                {assign var="cellCount" value=$cellCount+1}
            {/foreach}
            {* Rellenar los espacios vacios hasta 30 *}
            {for $i=$cellCount to 29}
                <div class="astroimp_inv_cell empty">
                    <span class="icon">—</span>
                    <span class="name">Vacio</span>
                </div>
            {/for}
        </div>

        <!-- ── BONIFICACIONES ── -->
        <div class="astroimp_stats">
            <h3>⚡ Bonificaciones Activas ({$unit_name})</h3>
            <p>⚔️ Ataque: x{$bonuses.ataque|number_format:2}</p>
            <p>🛡️ Defensa: x{$bonuses.defensa|number_format:2}</p>
            <p>🔵 Escudo: x{$bonuses.escudo|number_format:2}</p>
            <p>💨 Motriz: x{$bonuses.motriz|number_format:2}</p>
            <p>📦 Logistica: x{$bonuses.logistica|number_format:2}</p>
            <p>🔄 Cadencia: x{$bonuses.cadencia|number_format:2}</p>
            <p>🎯 Precisión: x{$bonuses.precision|number_format:2}</p>
        </div>

    {/if}

    {if $tab == 'comprar'}
        <!-- ── FILTROS DE COMPRA ── -->
        <div class="astroimp_filters">
            <a href="game.php?page=improvements&tab=comprar&filter=all" class="{if $filter == 'all'}active{/if}">🌐 Todas</a>
            <a href="game.php?page=improvements&tab=comprar&filter=ship" class="{if $filter == 'ship'}active{/if}">🚀 Naves</a>
            <a href="game.php?page=improvements&tab=comprar&filter=defense" class="{if $filter == 'defense'}active{/if}">🛡️ Defensas</a>
        </div>

        <div class="astroimp_shop">
            {foreach $catalog as $item}
                <div class="shop-item">
                    <span>{$item.icon_display} <strong>{$item.chain_name}</strong></span>
                    <span style="color:#fbbf24;">Nivel {$item.level} ({$item.type})</span>
                    <span class="cat_badge {if $item.category == 'ship'}cat_ship{else}cat_defense{/if}" style="display:inline-block;">
                        {if $item.category == 'ship'}🚀 NAVE{else}🛡️ DEFENSA{/if}
                    </span>
                    <span class="shop-spec">{$item.spec}</span>
                    <span class="price">🌌 {$item.price|number_format}</span>
                    <form method="post" action="game.php?page=improvements&mode=doBuy" style="margin-top:6px;">
                        <input type="hidden" name="item_id" value="{$item.id}">
                        <button type="submit">🛒 Comprar</button>
                    </form>
                </div>
            {/foreach}
        </div>
    {/if}

    {if $tab == 'vender'}
        <div class="astroimp_sell">
            {if $inventory|@count == 0}
                <div class="astroimp_empty">No tienes mejoras para vender.</div>
            {else}
                {foreach $inventory as $inv}
                    <div class="sell-item">
                        <span>{$inv.icon_display} <strong>{$inv.chain_name}</strong></span>
                        <span>Nivel {$inv.level} x{$inv.quantity}</span>
                        <span class="cat_badge {if $inv.category == 'ship'}cat_ship{else}cat_defense{/if}" style="display:inline-block;">
                            {if $inv.category == 'ship'}🚀 NAVE{else}🛡️ DEFENSA{/if}
                        </span>
                        <span class="sell-spec">{$inv.spec}</span>
                        {if $inv.is_penalized}<span style="color:#ef4444;font-weight:800;">[PENALIZADA]</span>{/if}
                        {if $inv.level < 7 && $inv.quantity >= 3}
                            <form method="post" action="game.php?page=improvements&mode=doFuse" style="margin-top:6px;">
                                <input type="hidden" name="item_id" value="{$inv.item_id}">
                                <button type="submit">🔄 Fusionar 3 → 1</button>
                            </form>
                        {/if}
                        <form method="post" action="game.php?page=improvements&mode=doSell" style="margin-top:6px;">
                            <input type="hidden" name="item_id" value="{$inv.item_id}">
                            <input type="number" name="quantity" value="1" min="1" max="{$inv.quantity}">
                            <button type="submit">💰 Vender</button>
                        </form>
                    </div>
                {/foreach}
            {/if}
        </div>
    {/if}

</div>

<!-- ── MODAL DE INFORMACIÓN ── -->
<div id="infoModal" class="astroimp_modal">
    <div class="astroimp_modal_content">
        <span class="astroimp_modal_close" onclick="document.getElementById('infoModal').style.display='none';">&times;</span>
        <h2>📖 Guía de Estadísticas de Mejoras</h2>
        <ul class="astroimp_modal_list">
            <li>
                <strong>⚔️ Ataque</strong>
                Aumenta el daño base de las armas de tus naves y defensas. Cuanto mayor sea este porcentaje, más daño infligirás al enemigo en cada ronda.
            </li>
            <li>
                <strong>🛡️ Defensa (Blindaje)</strong>
                Refuerza la estructura de tus unidades. Reduce la cantidad de daño que reciben tus naves y defensas cuando el escudo ya ha sido superado.
            </li>
            <li>
                <strong>🔵 Escudo</strong>
                Aumenta la capacidad de tus escudos. Absorben el daño de los impactos enemigos antes de que afecten al blindaje de la unidad.
            </li>
            <li>
                <strong>💨 Motriz (Velocidad)</strong>
                Mejora los motores de tus naves. Reduce significativamente el tiempo de vuelo de tus flotas en todas las misiones.
            </li>
            <li>
                <strong>📦 Logística (Capacidad de Carga)</strong>
                Amplía la bodega de carga de tus naves. Permite transportar más recursos (metal, cristal, deuterio) en cada viaje.
            </li>
            <li>
                <strong>🔄 Cadencia</strong>
                Aumenta la velocidad de recarga de las armas. Otorga la probabilidad de realizar <b>disparos adicionales</b> (disparo doble) en la misma ronda de combate.
            </li>
            <li>
                <strong>🎯 Precisión</strong>
                Mejora la puntería de los artilleros. Aumenta la probabilidad de penetrar las defensas y reduce el desperdicio de daño contra escudos enemigos.
            </li>
        </ul>
    </div>
</div>

{/block}