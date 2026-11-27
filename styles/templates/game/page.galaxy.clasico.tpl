{* ============================================================
   VISTA CLÁSICA (rama xnova3d) — la tabla original del juego,
   restaurada para que el jugador escoja entorno: clásico o 3D.
   Misma instalación y misma base de datos; solo cambia la vista.
   Botón "🌐 GALAXIA 3D" en la barra de navegación para cambiar.
   ============================================================ *}
{block name="title" prepend}{$LNG.lm_galaxy}{/block}
{block name="content"}

{* ============================================================
   ASTROIO GALAXY v3.1 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrogx_
   v3.1 — Sistema de Clima integrado:
          - Indicador de emoji junto al nombre del planeta.
          - Tooltip del planeta y luna muestran el clima completo.
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
.astrogx_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrogx_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 720px;
    margin: 0 auto;
}

/* ====== Título de sección ====== */
.astrogx_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
}

/* ====== Barra de navegación (galaxy/system) ====== */
.astrogx_nav {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    margin-bottom: 10px;
    font-size: 10.5px;
    color: var(--text-muted);
    font-weight: 600;
    transition: 0.2s ease;
}
.astrogx_nav:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrogx_nav_g { display: flex; align-items: center; gap: 3px; }
.astrogx_nav_btn {
    padding: 4px 8px;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 102, 204, 0.9));
    border: 1px solid rgba(0, 204, 255, 0.4);
    border-radius: 6px;
    color: #fff;
    font-weight: 700;
    font-size: 10px;
    cursor: pointer;
    font-family: inherit;
    min-width: 24px;
    line-height: 1.2;
    transition: 0.25s ease;
}
.astrogx_nav_btn:hover {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 153, 255, 0.95));
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.5);
    transform: translateY(-1px);
}
.astrogx_nav_in {
    width: 40px;
    padding: 4px 5px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 6px;
    color: #fff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 11px;
    outline: none;
    text-align: center;
    transition: 0.25s ease;
}
.astrogx_nav_in:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrogx_show {
    padding: 5px 14px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #fff;
    font-weight: 700;
    font-size: 10.5px;
    cursor: pointer;
    font-family: inherit;
    transition: 0.25s ease;
    letter-spacing: 0.3px;
}
.astrogx_show:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.55);
    transform: translateY(-2px);
}

/* ====== Tabla Galaxia ====== */
.astrogx_table_wrap {
    overflow-x: auto;
    border-radius: 10px;
    border: 1px solid rgba(0, 204, 255, 0.15);
    background: rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrogx_table_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrogx_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 10.5px;
}

/* Cabecera */
.astrogx_table thead tr {
    background: linear-gradient(135deg, #004488, #0077cc);
}
.astrogx_table thead th {
    padding: 4px 3px;
    font-weight: 700;
    font-size: 10px;
    letter-spacing: 0.3px;
    text-align: center;
    color: #ffffff;
    border-bottom: 1px solid #00ccff;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astrogx_table thead th.astrogx_th_title {
    font-size: 11px;
    letter-spacing: 0.6px;
    padding: 5px 6px;
    background: linear-gradient(135deg, #003366, #005599);
    color: #00e0ff;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}

/* Filas */
.astrogx_table tbody tr {
    background: rgba(0, 0, 0, 0.2);
    border-bottom: 1px solid rgba(0, 204, 255, 0.06);
    transition: 0.15s ease;
}
.astrogx_table tbody tr:hover {
    background: rgba(0, 204, 255, 0.07);
}
.astrogx_table tbody tr:hover td {
    color: #ffffff;
}
.astrogx_table tbody td {
    padding: 3px 3px;
    text-align: center;
    color: var(--text-main);
    vertical-align: middle;
    line-height: 1.2;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astrogx_table a {
    color: #00e0ff;
    text-decoration: none;
    font-weight: 600;
    transition: 0.15s ease;
}
.astrogx_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.8);
}
.astrogx_table td:first-child {
    font-family: 'Courier New', monospace;
    font-weight: 700;
    color: var(--text-muted);
    font-size: 10px;
}

/* Imágenes */
.astrogx_table img {
    display: inline-block;
    vertical-align: middle;
    border-radius: 3px;
    border: 1px solid rgba(0, 204, 255, 0.2);
    transition: 0.15s ease;
}
.astrogx_table a:hover img {
    border-color: #00ccff;
    box-shadow: 0 0 6px rgba(0, 224, 255, 0.5);
}
.astrogx_table td i {
    font-size: 12px !important;
}

/* ====== Icono de asteroide ====== */
.astrogx_ast_icon {
    display: inline-block;
    vertical-align: middle;
    border-radius: 3px;
    border: 1px solid rgba(255, 170, 51, 0.4);
    transition: 0.15s ease;
}
.astrogx_ast_icon:hover {
    border-color: #ffaa33;
    box-shadow: 0 0 10px rgba(255, 170, 51, 0.7);
}

/* ====== Icono de Clima (NUEVO) ====== */
.astroclima_icon {
    display: inline-block;
    font-size: 13px;
    line-height: 1;
    margin: 0 2px;
    vertical-align: middle;
    cursor: help;
    filter: drop-shadow(0 0 3px rgba(0, 204, 255, 0.5));
    transition: 0.15s ease;
}
.astroclima_icon:hover {
    transform: scale(1.4);
    filter: drop-shadow(0 0 6px rgba(0, 224, 255, 0.9));
}

/* ====== Anchos fijos por columna ====== */
.astrogx_table th:nth-child(1), .astrogx_table td:nth-child(1) { width: 28px;  }
.astrogx_table th:nth-child(2), .astrogx_table td:nth-child(2) { width: 36px;  }
.astrogx_table th:nth-child(3), .astrogx_table td:nth-child(3) { width: 140px; }
.astrogx_table th:nth-child(4), .astrogx_table td:nth-child(4) { width: 36px;  }
.astrogx_table th:nth-child(5), .astrogx_table td:nth-child(5) { width: 36px;  }
.astrogx_table th:nth-child(6), .astrogx_table td:nth-child(6) { width: 115px; }
.astrogx_table th:nth-child(7), .astrogx_table td:nth-child(7) { width: 60px;  }
.astrogx_table th:nth-child(8), .astrogx_table td:nth-child(8) { width: 80px;  }

/* ====== Clases de estados de usuario ====== */
.galaxy-username {
    font-weight: 700;
    color: #00e0ff;
}
.galaxy-short {
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 9px;
    padding: 0 1px;
}
.galaxy-username-vacation { color: #ffaa33 !important; }
.galaxy-username-banned { color: #ff4488 !important; }
.galaxy-username-inactive { color: #8899aa !important; }
.galaxy-username-longinactive { color: #667788 !important; }
.galaxy-username-strong { color: #ff4488 !important; }
.galaxy-username-noob { color: #66ff99 !important; }
.galaxy-username-own { color: #66ff99 !important; }
.galaxy-username-buddy { color: #00e0ff !important; }
.galaxy-username-admin { color: #ffaa33 !important; }
.galaxy-username-ally { color: #aa44ff !important; }

.galaxy-alliance {
    color: #aa44ff;
    font-weight: 700;
    font-size: 10px;
}
.galaxy-alliance-own { color: #66ff99 !important; }
.galaxy-alliance-ally { color: #aa44ff !important; }
.galaxy-alliance-war { color: #ff4488 !important; }
.galaxy-alliance-pact { color: #00e0ff !important; }

.textForBlind { display: none; }

/* ====== ASTROIO v3.2: Leyenda completa (siempre visible) ====== */
.astrogx_legend {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    margin-top: 10px;
    transition: 0.2s ease;
}
.astrogx_legend:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrogx_legend_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.5px;
    display: block;
    margin-bottom: 8px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astrogx_legend_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 5px 12px;
}
.astrogx_legend_item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 10.5px;
    color: var(--text-main);
    line-height: 1.3;
}
.astrogx_legend_item i { color: #00e0ff; font-size: 12px; width: 12px; text-align: center; }
.astrogx_leg_dot {
    width: 11px;
    height: 11px;
    min-width: 11px;
    border-radius: 50%;
    display: inline-block;
    box-shadow: 0 0 6px rgba(0, 0, 0, 0.6);
    border: 1px solid rgba(255, 255, 255, 0.25);
}
.astrogx_legend_sub {
    margin-top: 8px;
    padding-top: 6px;
    border-top: 1px solid rgba(0, 204, 255, 0.12);
    font-size: 10px;
    color: var(--text-muted);
    letter-spacing: 0.3px;
}

/* ====== ASTROIO v3.2: Toast de acciones (reciclaje automático) ====== */
#astrogx_toast {
    position: fixed;
    bottom: 18px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 99999;
    padding: 10px 18px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 700;
    color: #ffffff;
    background: rgba(190, 30, 45, 0.94);
    border: 1px solid rgba(255, 120, 130, 0.7);
    box-shadow: 0 6px 24px rgba(0, 0, 0, 0.65);
    max-width: 82vw;
    text-align: center;
    display: none;
}
#astrogx_toast.ok {
    background: rgba(16, 110, 70, 0.95);
    border-color: rgba(120, 255, 170, 0.7);
}

/* ====== ASTROIO v3.2: Iconos de escombros/asteroide clicable ====== */
.astrogx_clickable {
    cursor: pointer;
    display: inline-block;
}
.astrogx_clickable:active {
    transform: scale(0.9);
}

/* ====== ASTROIO v3.2: Barra de estado superior ====== */
.astrogx_strip {
    display: flex;
    justify-content: center;
    gap: 16px;
    flex-wrap: wrap;
    padding: 6px 10px;
    margin-bottom: 10px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    font-size: 10.5px;
    color: var(--text-muted);
    font-weight: 600;
}
.astrogx_strip span { display: inline-flex; align-items: center; gap: 4px; }
.astrogx_strip i { color: #00e0ff; font-size: 12px; }
.astrogx_strip b { color: #66ff99; font-family: 'Courier New', monospace; }

.astrogx_action_icon { margin-left: 3px; }

/* ====== Formulario misiles ====== */
.astrogx_mis {
    background: rgba(255, 68, 136, 0.06);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 68, 136, 0.4);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 10px;
    font-size: 10.5px;
    transition: 0.2s ease;
}
.astrogx_mis:hover {
    border-color: rgba(255, 68, 136, 0.6);
}
.astrogx_mis table { width: 100%; border-collapse: collapse; }
.astrogx_mis th {
    padding: 4px 6px;
    background: linear-gradient(135deg, #770022, #aa0044);
    color: #ffffff;
    font-weight: 700;
    font-size: 10.5px;
    border-bottom: 1px solid #ff4488;
    letter-spacing: 0.3px;
}
.astrogx_mis td {
    padding: 4px 6px;
    color: var(--text-main);
    border-bottom: 1px solid rgba(255, 68, 136, 0.1);
}
.astrogx_mis input[type="text"] {
    padding: 3px 6px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(255, 68, 136, 0.4);
    border-radius: 6px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 10.5px;
    outline: none;
    width: 50px;
    transition: 0.25s ease;
}
.astrogx_mis input[type="text"]:focus {
    border-color: #ff4488;
    box-shadow: 0 0 10px rgba(255, 68, 136, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrogx_mis select {
    padding: 3px 8px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(255, 68, 136, 0.4);
    border-radius: 6px;
    color: #ffffff;
    font-size: 10.5px;
    font-weight: 600;
    outline: none;
    cursor: pointer;
    transition: 0.25s ease;
}
.astrogx_mis select:hover,
.astrogx_mis select:focus {
    border-color: #ff4488;
    box-shadow: 0 0 10px rgba(255, 68, 136, 0.5);
}
.astrogx_mis input[type="submit"] {
    padding: 6px 18px;
    background: linear-gradient(135deg, rgba(170, 0, 68, 0.9), rgba(204, 34, 102, 0.9));
    border: 1px solid #ff4488;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 700;
    font-size: 10.5px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.3px;
    font-family: inherit;
}
.astrogx_mis input[type="submit"]:hover {
    background: linear-gradient(135deg, rgba(204, 34, 102, 0.95), rgba(255, 68, 136, 0.95));
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.55);
    transform: translateY(-2px);
}

/* ====== Footer de la tabla (leyenda + stats) ====== */
.astrogx_table tr.astrogx_foot td {
    background: rgba(0, 0, 0, 0.3);
    color: var(--text-muted);
    font-size: 10px;
    padding: 4px 5px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
    white-space: normal;
    text-align: center;
}
.astrogx_table tr.astrogx_foot a {
    color: #00e0ff;
    font-weight: 700;
}

#missiles, #slots, #elementID210, #elementID209, #elementID219 {
    color: #66ff99;
    font-family: 'Courier New', monospace;
    font-weight: 700;
}

#fleetstatusrow th {
    background: linear-gradient(135deg, #006644, #00aa66);
    color: #ffffff;
    text-align: center;
    font-size: 10.5px;
    padding: 5px 6px;
    letter-spacing: 0.4px;
    border-bottom: 1px solid #00dd88;
}

/* ============================================================
   ASTROIO - ALERTAS VISUALES DE FLOTAS ENTRANTES
   ============================================================ */

/* 1. Planeta oscuro (usuario inactivo) */
.astrogx_table tbody tr.darkened td {
    opacity: 0.35;
    filter: grayscale(85%);
    transition: all 0.3s ease;
}
.astrogx_table tbody tr.darkened:hover td {
    opacity: 0.7;
    filter: grayscale(30%);
}

/* 2. Parpadeo ROJO (Ataque / Misiles) */
.astrogx_table tbody tr.blink_red {
    animation: astrogx_parpadeoRojo 1s infinite;
    border-top: 1px solid #ff0000 !important;
    border-bottom: 1px solid #ff0000 !important;
}
@keyframes astrogx_parpadeoRojo {
    0%   { background-color: rgba(255, 0, 0, 0.55); box-shadow: inset 0 0 15px rgba(255, 0, 0, 0.8); }
    50%  { background-color: rgba(255, 0, 0, 0.00); box-shadow: none; }
    100% { background-color: rgba(255, 0, 0, 0.55); box-shadow: inset 0 0 15px rgba(255, 0, 0, 0.8); }
}
.astrogx_table tbody tr.blink_red td {
    color: #ffffff !important;
    font-weight: 700;
    text-shadow: 0 0 5px #ff0000;
}

/* 3. Parpadeo AMARILLO (Espionaje) */
.astrogx_table tbody tr.blink_yellow {
    animation: astrogx_parpadeoAmarillo 1s infinite;
    border-top: 1px solid #ffcc00 !important;
    border-bottom: 1px solid #ffcc00 !important;
}
@keyframes astrogx_parpadeoAmarillo {
    0%   { background-color: rgba(255, 204, 0, 0.55); box-shadow: inset 0 0 15px rgba(255, 204, 0, 0.8); }
    50%  { background-color: rgba(255, 204, 0, 0.00); box-shadow: none; }
    100% { background-color: rgba(255, 204, 0, 0.55); box-shadow: inset 0 0 15px rgba(255, 204, 0, 0.8); }
}
.astrogx_table tbody tr.blink_yellow td {
    color: #ffffff !important;
    font-weight: 700;
    text-shadow: 0 0 5px #ffcc00;
}

/* 4. Parpadeo AZUL (Transporte / Despliegue) */
.astrogx_table tbody tr.blink_blue {
    animation: astrogx_parpadeoAzul 1s infinite;
    border-top: 1px solid #0088ff !important;
    border-bottom: 1px solid #0088ff !important;
}
@keyframes astrogx_parpadeoAzul {
    0%   { background-color: rgba(0, 136, 255, 0.55); box-shadow: inset 0 0 15px rgba(0, 136, 255, 0.8); }
    50%  { background-color: rgba(0, 136, 255, 0.00); box-shadow: none; }
    100% { background-color: rgba(0, 136, 255, 0.55); box-shadow: inset 0 0 15px rgba(0, 136, 255, 0.8); }
}
.astrogx_table tbody tr.blink_blue td {
    color: #ffffff !important;
    font-weight: 700;
    text-shadow: 0 0 5px #0088ff;
}

/* ====== Responsive Móvil Extremo (Todo en 1 pantalla) ====== */
@media (max-width: 720px) {
    .astrogx_wrap { padding: 5px !important; }
    .astrogx_panel { padding: 8px !important; max-width: 100% !important; }
    
    .astrogx_nav { 
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 6px !important; 
        padding: 6px !important; 
        width: 100% !important;
        box-sizing: border-box !important;
        align-items: center !important;
        justify-items: center !important;
    }
    
    .astrogx_nav_g {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 2px !important;
        width: 100% !important;
    }

    .astrogx_nav_g:nth-child(3) {
        grid-column: 1 / -1 !important; 
        margin-top: 4px !important;
    }

    .astrogx_nav_g span {
        display: none !important;
    }

    .astrogx_nav_in { 
        width: 100% !important;
        max-width: 40px !important;
        height: 22px !important; 
        font-size: 11px !important; 
        padding: 0 !important;
        text-align: center !important;
        box-sizing: border-box !important;
        border-radius: 4px !important;
    }
    
    .astrogx_nav_btn { 
        height: 22px !important;
        padding: 0 5px !important; 
        font-size: 11px !important; 
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        border-radius: 4px !important;
    }
    
    .astrogx_show { 
        height: 26px !important;
        width: 100% !important;
        max-width: 200px !important;
        padding: 0 10px !important; 
        font-size: 11px !important;
        font-weight: 700 !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        border-radius: 6px !important;
    }

    .astrogx_table th:nth-child(7), 
    .astrogx_table td:nth-child(7) {
        display: none !important;
    }

    .astrogx_table_wrap {
        overflow-x: hidden !important; 
    }

    .astrogx_table {
        font-size: 8px !important;
        table-layout: fixed !important;
        width: 100% !important;
    }

    .astrogx_table th:nth-child(1), .astrogx_table td:nth-child(1) { width: 6% !important; }
    .astrogx_table th:nth-child(2), .astrogx_table td:nth-child(2) { width: 8% !important; }
    .astrogx_table th:nth-child(3), .astrogx_table td:nth-child(3) { width: 28% !important; white-space: normal !important; word-break: break-all !important; line-height: 1.1 !important; }
    .astrogx_table th:nth-child(4), .astrogx_table td:nth-child(4) { width: 8% !important; }
    .astrogx_table th:nth-child(5), .astrogx_table td:nth-child(5) { width: 8% !important; }
    .astrogx_table th:nth-child(6), .astrogx_table td:nth-child(6) { width: 26% !important; white-space: normal !important; word-break: break-all !important; line-height: 1.1 !important; }
    .astrogx_table th:nth-child(8), .astrogx_table td:nth-child(8) { width: 16% !important; }

    .astrogx_table thead th { padding: 2px 1px !important; font-size: 7.5px !important; white-space: normal !important; line-height: 1.1 !important; }
    .astrogx_table tbody td { padding: 2px 1px !important; font-size: 8px !important; }

    .astrogx_table tbody img { height: 16px !important; width: 16px !important; }
    .astrogx_ast_icon { height: 14px !important; width: 14px !important; }

    .astrogx_table td i { font-size: 10px !important; }
    
    .galaxy-username { 
        display: inline-block; 
        max-width: 100%; 
        overflow: hidden; 
        text-overflow: ellipsis; 
        white-space: nowrap; 
        vertical-align: middle;
    }

    /* Clima en móvil: lo hacemos más pequeño */
    .astroclima_icon {
        font-size: 10px !important;
        margin: 0 1px !important;
    }
}
</style>

<div class="astrogx_wrap">

        <div class="astrogx_panel">

                <span class="astrogx_section_title">🌌 {$LNG.lm_galaxy}</span>

                {* ============ BARRA DE NAVEGACIÓN ============ *}
                <form action="?page=galaxy" method="post" id="galaxy_form">
                        <input type="hidden" id="auto" value="dr">

                        <div class="astrogx_nav">
                                <div class="astrogx_nav_g">
                                        <span>{$LNG.gl_galaxy}</span>
                                        <input type="button" name="galaxyLeft" value="&lt;-" onclick="galaxy_submit('galaxyLeft')" class="astrogx_nav_btn">
                                        <input type="text" name="galaxy" value="{$galaxy}" size="5" maxlength="3" tabindex="1" class="astrogx_nav_in">
                                        <input type="button" name="galaxyRight" value="-&gt;" onclick="galaxy_submit('galaxyRight')" class="astrogx_nav_btn">
                                </div>

                                <div class="astrogx_nav_g">
                                        <span>{$LNG.gl_solar_system}</span>
                                        <input type="button" name="systemLeft" value="&lt;-" onclick="galaxy_submit('systemLeft')" class="astrogx_nav_btn">
                                        <input type="text" name="system" value="{$system}" size="5" maxlength="3" tabindex="2" class="astrogx_nav_in">
                                        <input type="button" name="systemRight" value="-&gt;" onclick="galaxy_submit('systemRight')" class="astrogx_nav_btn">
                                </div>

                                <div class="astrogx_nav_g">
                                        <input type="submit" value="{$LNG.gl_show}" class="astrogx_show">
                                </div>

                                {* ============ GALAXIA 3D (xnova3d): cambiar al visor 3D conservando G:S ============ *}
                                <div class="astrogx_nav_g">
                                        <input type="button" value="🌐 GALAXIA 3D" class="astrogx_show" style="background:linear-gradient(135deg,#004488,#00aaff);border-color:#00ccff;" onclick="location.href='?page=galaxy&vista=3d&galaxy='+document.getElementById('galaxy_form').galaxy.value+'&system='+document.getElementById('galaxy_form').system.value">
                                </div>
                        </div>
                </form>

                {* ============ ASTROIO v3.2: BARRA DE ESTADO (contadoras vivas) ============ *}
                <div class="astrogx_strip">
                        <span><i class="fas fa-eye"></i> <b id="elementID210">{$spyprobes|number}</b> {$LNG.gl_avaible_spyprobes}</span>
                        <span><i class="fas fa-recycle"></i> <b id="elementID209">{$recyclers|number}</b> {$LNG.gl_avaible_recyclers}</span>
                        <span><i class="fas fa-recycle" style="color:#ffaa33"></i> <b id="elementID219">{$grecyclers|number}</b> {$LNG.gl_avaible_grecyclers}</span>
                        <span><i class="fas fa-ship"></i> <b id="slots">{$maxfleetcount}</b>/{$fleetmax} {$LNG.gl_fleets}</span>
                        <span><i class="fas fa-bomb"></i> <b id="missiles">{$currentmip|number}</b> {$LNG.gl_avaible_missiles}</span>
                </div>

                {* ============ FORMULARIO DE MISILES (si aplica) ============ *}
                {if $action == 'sendMissle'}
                <div class="astrogx_mis">
                        <form action="?page=fleetMissile" method="post">
                                <input type="hidden" name="galaxy" value="{$galaxy}">
                                <input type="hidden" name="system" value="{$system}">
                                <input type="hidden" name="planet" value="{$planet}">
                                <input type="hidden" name="type" value="{$type}">
                                <table class="table569">
                                        <tr>
                                                <th colspan="2">🚀 {$LNG.gl_missil_launch} [{$galaxy}:{$system}:{$planet}]</th>
                                        </tr>
                                        <tr>
                                                <td>{$missile_count} <input type="text" name="SendMI" size="2" maxlength="7"></td>
                                                <td>{$LNG.gl_objective}: 
                                                        {html_options name=Target options=$missileSelector}
                                                </td>
                                        </tr>
                                        <tr>
                                                <th colspan="2" style="text-align:center;">
                                                        <input type="submit" value="{$LNG.gl_missil_launch_action}">
                                                </th>
                                        </tr>
                                </table>
                        </form>
                </div>
                {/if}

                {* ============ TABLA DE GALAXIA ============ *}
                <div class="astrogx_table_wrap">
                <table class="astrogx_table">
                        <thead>
                                <tr>
                                        <th colspan="8" class="astrogx_th_title">{$LNG.gl_solar_system} {$galaxy}:{$system}</th>
                                </tr>
                                <tr>
                                        <th style="white-space: nowrap">{$LNG.gl_pos}</th>
                                        <th style="white-space: nowrap">{$LNG.gl_planet}</th>
                                        <th style="white-space: nowrap">{$LNG.gl_name_activity}</th>
                                        <th style="white-space: nowrap">{$LNG.gl_moon}</th>
                                        <th style="white-space: nowrap">{$LNG.gl_debris}</th>
                                        <th style="white-space: nowrap">{$LNG.gl_player_estate}</th>
                                        <th style="white-space: nowrap">{$LNG.gl_alliance}</th>
                                        <th style="white-space: nowrap">{$LNG.gl_actions}</th>
                                </tr>
                        </thead>
                        <tbody>
                        {for $planet=1 to $max_planets}

                        {* ===== ASTROIO: Cálculo de la clase de alerta de la fila ===== *}
                        {assign var="ck_planet" value="`$galaxy`:`$system`:`$planet`:1"}
                        {assign var="ck_moon"   value="`$galaxy`:`$system`:`$planet`:3"}
                        {assign var="row_class" value=""}
                        {if isset($GalaxyRows[$planet]) && $GalaxyRows[$planet] !== false}
                                {if isset($incomingFleets.attack[$ck_planet]) || isset($incomingFleets.attack[$ck_moon])}
                                        {assign var="row_class" value="blink_red"}
                                {elseif isset($incomingFleets.spy[$ck_planet]) || isset($incomingFleets.spy[$ck_moon])}
                                        {assign var="row_class" value="blink_yellow"}
                                {elseif isset($incomingFleets.transport[$ck_planet]) || isset($incomingFleets.transport[$ck_moon])}
                                        {assign var="row_class" value="blink_blue"}
                                {elseif !empty($GalaxyRows[$planet].user.class)}
                                        {if $GalaxyRows[$planet].user.class.0 == 'inactive' || $GalaxyRows[$planet].user.class.0 == 'longinactive'}
                                                {assign var="row_class" value="darkened"}
                                        {/if}
                                {/if}
                        {/if}
                        {* ===== FIN ASTROIO ===== *}

                        <tr class="{$row_class}">
                        {if !isset($GalaxyRows[$planet])}
                                <td>
                                        <a href="?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=7">{$planet}</a>
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td style="white-space: nowrap;">
                                        {if $asteroids && isset($asteroids[$planet])}
                                        <a class="tooltip_sticky astrogx_clickable" data-tooltip-content="<table style='width:280px'><tr><th colspan='2'>Asteroide [{$galaxy}:{$system}:{$planet}]</th></tr><tr><td style='width:80px'><img src='{$dpath}planeten/small/s_asteroid.jpg' height='75'></td><td>♻️ <b>Reciclaje automático</b>: envía los recicladores al instante.<br><br><a href='javascript:void(0);' onclick='doitAst({$galaxy},{$system},{$planet});'>Reciclar asteroide (automático)</a><br><a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=32'>Enviar desde la base de flota</a></td></tr></table>" onclick="doitAst({$galaxy},{$system},{$planet});">
                                                <img class="astrogx_ast_icon" src="{$dpath}planeten/small/s_asteroid.jpg" height="18" width="18" alt="Asteroide">
                                        </a>
                                        {/if}
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                        {elseif $GalaxyRows[$planet] === false}
                                <td>
                                        {$planet}
                                </td>
                                <td></td>
                                <td style="white-space: nowrap;">💀 {$LNG.gl_ruins}</td>
                                <td></td>
                                <td style="white-space: nowrap;">
                                        {if $asteroids && isset($asteroids[$planet])}
                                        <a class="tooltip_sticky astrogx_clickable" data-tooltip-content="<table style='width:280px'><tr><th colspan='2'>Asteroide [{$galaxy}:{$system}:{$planet}]</th></tr><tr><td style='width:80px'><img src='{$dpath}planeten/small/s_asteroid.jpg' height='75'></td><td>♻️ <b>Reciclaje automático</b>: envía los recicladores al instante.<br><br><a href='javascript:void(0);' onclick='doitAst({$galaxy},{$system},{$planet});'>Reciclar asteroide (automático)</a><br><a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=32'>Enviar desde la base de flota</a></td></tr></table>" onclick="doitAst({$galaxy},{$system},{$planet});">
                                                <img class="astrogx_ast_icon" src="{$dpath}planeten/small/s_asteroid.jpg" height="18" width="18" alt="Asteroide">
                                        </a>
                                        {/if}
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                        {else}
                                <td>
                                        {$planet}
                                </td>
                                {$currentPlanet = $GalaxyRows[$planet]}
                                
                                {* ============ CELDA PLANETA (con tooltip de clima) ============ *}
                                <td>
                                        {assign var="clima_planeta" value=""}
                                        {if isset($climasGalaxy[$currentPlanet.planet.id])}
                                                {assign var="clima_planeta" value=$climasGalaxy[$currentPlanet.planet.id]}
                                        {/if}
                                        
                                        <a class="tooltip_sticky" data-tooltip-content="<table style='width:220px'><tr><th colspan='2'>{$LNG.gl_planet} {$currentPlanet.planet.name} [{$galaxy}:{$system}:{$planet}]</th></tr><tr><td style='width:80px'><img src='{$dpath}planeten/small/s_{$currentPlanet.planet.image}.jpg' height='75' width='75'></td><td>{if $currentPlanet.missions.6}<a href='javascript:doit(6,{$currentPlanet.planet.id});'>{$LNG["type_mission_6"]}</a><br><br>{/if}{if $currentPlanet.planet.phalanx}<a href='javascript:OpenPopup(&quot;?page=phalanx&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&quot;, &quot;&quot;, 640, 510);'>{$LNG.gl_phalanx}</a><br>{/if}{if $currentPlanet.missions.1}<a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=1'>{$LNG["type_mission_1"]}</a><br>{/if}{if $currentPlanet.missions.5}<a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=5'>{$LNG["type_mission_5"]}</a><br>{/if}{if $currentPlanet.missions.4}<a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=4'>{$LNG["type_mission_4"]}</a><br>{/if}{if $currentPlanet.missions.3}<a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=3'>{$LNG["type_mission_3"]}</a><br>{/if}{if $currentPlanet.missions.10}<a href='?page=galaxy&amp;action=sendMissle&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}'>{$LNG["type_mission_10"]}</a><br>{/if}{if $clima_planeta}<br><b>🌦️ {$clima_planeta.nombre}</b><br><i style='font-size:10px'>{$clima_planeta.descripcion}</i>{/if}</td></tr></table>">
                                                <img src="{$dpath}planeten/small/s_{$currentPlanet.planet.image}.jpg" height="24" width="24" alt="">
                                        </a>
                                </td>
                                
                                {* ============ CELDA NOMBRE (con emoji de clima) ============ *}
                                <td style="white-space: nowrap;">
                                        {$currentPlanet.planet.name}
                                        
                                        {* ASTROIO v3.2: Depósito de Alianza disponible *}
                                        {if $currentPlanet.planet.ally_deposit}
                                        <span class="astroclima_icon tooltip" data-tooltip-content="🏦 {$LNG.gl_leg_allydepot}">🏦</span>
                                        {/if}
                                        
                                        {* ASTROIO: Indicador de clima junto al nombre *}
                                        {if $clima_planeta}
                                                {assign var="clima_emoji" value="❓"}
                                                {if $clima_planeta.clave == 'despejado'}{assign var="clima_emoji" value="☀️"}
                                                {elseif $clima_planeta.clave == 'brisa_solar'}{assign var="clima_emoji" value="🌤️"}
                                                {elseif $clima_planeta.clave == 'viento_estelar'}{assign var="clima_emoji" value="🍃"}
                                                {elseif $clima_planeta.clave == 'cristalino'}{assign var="clima_emoji" value="✨"}
                                                {elseif $clima_planeta.clave == 'niebla'}{assign var="clima_emoji" value="🌫️"}
                                                {elseif $clima_planeta.clave == 'tormenta_solar'}{assign var="clima_emoji" value="⚡"}
                                                {elseif $clima_planeta.clave == 'meteoros'}{assign var="clima_emoji" value="☄️"}
                                                {elseif $clima_planeta.clave == 'nebulosa'}{assign var="clima_emoji" value="💰"}
                                                {elseif $clima_planeta.clave == 'plasma'}{assign var="clima_emoji" value="🌌"}
                                                {elseif $clima_planeta.clave == 'eclipse'}{assign var="clima_emoji" value="🌓"}
                                                {elseif $clima_planeta.clave == 'campo_mag'}{assign var="clima_emoji" value="🌀"}
                                                {elseif $clima_planeta.clave == 'aurora'}{assign var="clima_emoji" value="🌈"}
                                                {elseif $clima_planeta.clave == 'agujero'}{assign var="clima_emoji" value="🕳️"}
                                                {elseif $clima_planeta.clave == 'singularidad'}{assign var="clima_emoji" value="⚫"}
                                                {/if}
                                                <span class="astroclima_icon tooltip_sticky" data-tooltip-content="<b>🌦️ {$clima_planeta.nombre}</b><br><i>{$clima_planeta.descripcion}</i><br><br><b>Ataque:</b> {if $clima_planeta.factor_ataque > 1}+{/if}{math equation='round((x-1)*100)' x=$clima_planeta.factor_ataque}%<br><b>Defensa:</b> {if $clima_planeta.factor_defensa > 1}+{/if}{math equation='round((x-1)*100)' x=$clima_planeta.factor_defensa}%<br><b>Bajas:</b> {if $clima_planeta.factor_bajas > 1}+{/if}{math equation='round((x-1)*100)' x=$clima_planeta.factor_bajas}%<br><b>Botín:</b> {if $clima_planeta.factor_botin > 1}+{/if}{math equation='round((x-1)*100)' x=$clima_planeta.factor_botin}%">{$clima_emoji}</span>
                                        {/if}
                                        
                                        {$currentPlanet.lastActivity}
                                </td>
                                
                                {* ============ CELDA LUNA (con tooltip de clima) ============ *}
                                <td style="white-space: nowrap;">
                                        {if $currentPlanet.moon}
                                        {assign var="clima_luna" value=""}
                                        {if isset($climasGalaxy[$currentPlanet.moon.id])}
                                                {assign var="clima_luna" value=$climasGalaxy[$currentPlanet.moon.id]}
                                        {/if}
                                        
                                        <a class="tooltip_sticky" data-tooltip-content="<table style='width:240px'><tr><th colspan='2'>{$LNG.gl_moon} {$currentPlanet.moon.name} [{$galaxy}:{$system}:{$planet}]</th></tr><tr><td style='width:80px'><img src='{$dpath}planeten/mond.jpg' height='75' width='75'></td><td><table style='width:100%'><tr><th colspan='2'>{$LNG.gl_features}</th></tr><tr><td>{$LNG.gl_diameter}</td><td>{$currentPlanet.moon.diameter|number}</td></tr><tr><td>{$LNG.gl_temperature}</td><td>{$currentPlanet.moon.temp_min}</td></tr>{if $clima_luna}<tr><th colspan='2'>🌦️ Clima</th></tr><tr><td colspan='2'><b>{$clima_luna.nombre}</b><br><i style='font-size:10px'>{$clima_luna.descripcion}</i><br>Ataque: {if $clima_luna.factor_ataque > 1}+{/if}{math equation='round((x-1)*100)' x=$clima_luna.factor_ataque}%<br>Defensa: {if $clima_luna.factor_defensa > 1}+{/if}{math equation='round((x-1)*100)' x=$clima_luna.factor_defensa}%</td></tr>{/if}<tr><th colspan=2>{$LNG.gl_actions}</th></tr><tr><td colspan='2'>{if $currentPlanet.missions.1}<a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=3&amp;target_mission=1'>{$LNG["type_mission_1"]}</a><br>{/if}{if $currentPlanet.missions.3}<a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=3&amp;target_mission=3'>{$LNG["type_mission_3"]}</a>{/if}{if $currentPlanet.missions.3}<br><a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=3&amp;target_mission=4'>{$LNG["type_mission_4"]}</a>{/if}{if $currentPlanet.missions.5}<br><a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=3&amp;target_mission=5'>{$LNG["type_mission_5"]}</a>{/if}{if $currentPlanet.missions.6}<br><a href='javascript:doit(6,{$currentPlanet.moon.id});'>{$LNG["type_mission_6"]}</a>{/if}{if $currentPlanet.missions.9}<br><br><a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=3&amp;target_mission=9'>{$LNG["type_mission_9"]}</a><br>{/if}{if $currentPlanet.missions.10}<a href='?page=galaxy&amp;action=sendMissle&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;type=3'>{$LNG["type_mission_10"]}</a><br>{/if}</td></tr></table></td></tr></table>">
                                                <img src="{$dpath}planeten/small/s_mond.jpg" height="18" width="18" alt="{$currentPlanet.moon.name}">
                                        </a>
                                        {/if}
                                </td>
                                
                                {* ============ CELDA ESCOMBROS ============ *}
                                <td style="white-space: nowrap;">
                                {if $asteroids && isset($asteroids[$planet])}
                                        <a class="tooltip_sticky astrogx_clickable" data-tooltip-content="<table style='width:280px'><tr><th colspan='2'>Asteroide [{$galaxy}:{$system}:{$planet}]</th></tr><tr><td style='width:80px'><img src='{$dpath}planeten/small/s_asteroid.jpg' height='75'></td><td>♻️ <b>Reciclaje automático</b>: envía los recicladores al instante.<br><br><a href='javascript:void(0);' onclick='doitAst({$galaxy},{$system},{$planet});'>Reciclar asteroide (automático)</a><br><a href='?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1&amp;target_mission=32'>Enviar desde la base de flota</a></td></tr></table>" onclick="doitAst({$galaxy},{$system},{$planet});">
                                                <img class="astrogx_ast_icon" src="{$dpath}planeten/small/s_asteroid.jpg" height="18" width="18" alt="Asteroide">
                                        </a>
                                {/if}
                                {if $currentPlanet.debris}
                                        <a class="tooltip_sticky astrogx_clickable" data-tooltip-content="<table style='width:240px'><tr><th colspan='2'>{$LNG.gl_debris_field} [{$galaxy}:{$system}:{$planet}]</th></tr><tr><td style='width:80px'><img src='{$dpath}planeten/debris.jpg' height='75' style='width:75'></td><td><table style='width:100%'><tr><th colspan='2'>{$LNG.gl_resources}:</th></tr><tr><td>{$LNG.tech.901}: </td><td>{$currentPlanet.debris.metal|number}</td></tr><tr><td>{$LNG.tech.902}: </td><td>{$currentPlanet.debris.crystal|number}</td></tr>{if $currentPlanet.missions.8}<tr><th colspan='2'>{$LNG.gl_actions}</th></tr><tr><td colspan='2'>♻️ <b>Reciclaje automático</b>: los recicladores salen al instante.<br><br><a href='javascript:void(0);' onclick='doit(8, {$currentPlanet.planet.id});'>Reciclar escombros (automático)</a></td></tr>{/if}</table></td></tr></table>" onclick="doit(8, {$currentPlanet.planet.id});">
                                        <img src="{$dpath}planeten/debris.jpg" height="18" width="18" alt="{$LNG.gl_debris_field}">
                                        </a>
                                {/if}
                                </td>
                                
                                {* ============ CELDA JUGADOR ============ *}
                                <td>
                                        <a class="tooltip_sticky" data-tooltip-content="<table style='width:240px'><tr><th colspan='2'>{$currentPlanet.user.playerrank}</th></tr><tr>{if !$currentPlanet.ownPlanet}{if $currentPlanet.user.isBuddy}<tr><td><a href='#' onclick='return Dialog.Buddy({$currentPlanet.user.id})'>{$LNG.gl_buddy_request}</a></td></tr>{/if}<tr><td><a href='#' onclick='return Dialog.Playercard({$currentPlanet.user.id});'>{$LNG.gl_playercard}</a></td></tr>{/if}<tr><td><a href='?page=statistics&amp;who=1&amp;start={$currentPlanet.user.rank}'>{$LNG.gl_see_on_stats}</a></td></tr></table>">
                                                <span class="{foreach $currentPlanet.user.class as $class}{if !$class@first} {/if}galaxy-username-{$class}{/foreach} galaxy-username">{$currentPlanet.user.username}</span>

                                                {if !empty($currentPlanet.user.class)}
                                                <span>(</span>{foreach $currentPlanet.user.class as $class}{if !$class@first}&nbsp;{/if}<span class="galaxy-short-{$class} galaxy-short">{$ShortStatus.$class}</span>{/foreach}<span>)</span>
                                                {/if}
                                        </a>
                                </td>
                                
                                {* ============ CELDA ALIANZA ============ *}
                                <td style="white-space: nowrap;">
                                        {if $currentPlanet.alliance}
                                        <a class="tooltip_sticky" data-tooltip-content="<table style='width:240px'><tr><th>{$LNG.gl_alliance} {$currentPlanet.alliance.name} {$currentPlanet.alliance.member}</th></tr><td><table><tr><td><a href='?page=alliance&amp;mode=info&amp;id={$currentPlanet.alliance.id}'>{$LNG.gl_alliance_page}</a></td></tr><tr><td><a href='?page=statistics&amp;start={$currentPlanet.alliance.rank}&amp;who=2'>{$LNG.gl_see_on_stats}</a></td></tr>{if $currentPlanet.alliance.web}<tr><td><a href='{$currentPlanet.alliance.web}' target='allyweb'>{$LNG.gl_alliance_web_page}</td></tr>{/if}</table></td></table>">
                                                <span class="{foreach $currentPlanet.alliance.class as $class}{if !$class@first} {/if}galaxy-alliance-{$class}{/foreach} galaxy-alliance">{$currentPlanet.alliance.tag}</span>
                                        </a>
                                        {else}-{/if}
                                </td>
                                
                                {* ============ CELDA ACCIONES ============ *}
                                <td style="white-space: nowrap;">
                                        {if $currentPlanet.action}
                                                {if $currentPlanet.action.esp}
                                                <a href="javascript:doit(6,{$currentPlanet.planet.id},{$spyShips|json|escape:'html'})">
                                                        <i class="far fa-eye-slash" title="{$LNG.gl_spy}"></i>
                                                </a>{/if}
                                                {if $currentPlanet.action.message}
                                                <a href="#" onclick="return Dialog.PM({$currentPlanet.user.id})">
                                                        <i class="far fa-envelope" title="{$LNG.write_message}"></i>
                                                </a>{/if}
                                                {if $currentPlanet.action.buddy}
                                                <a href="#" onclick="return Dialog.Buddy({$currentPlanet.user.id})">
                                                        <i class="far fa-handshake" title="{$LNG.gl_buddy_request}"></i>
                                                </a>{/if}
                                                {if $currentPlanet.action.missle}<a href="?page=galaxy&amp;action=sendMissle&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;type=1">
                                                        <i class="far fa-rocket" title="{$LNG.gl_missile_attack}"></i>
                                                </a>{/if}
                                        {else}-{/if}
                                        {if $currentPlanet.planet.phalanx}<a class="astrogx_action_icon" href="#" onclick="OpenPopup('?page=phalanx&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$planet}&amp;planettype=1','',640,510);return false;"><i class="fas fa-crosshairs" title="{$LNG.gl_phalanx}" style="color:#00e0ff"></i></a>{/if}
                                </td>
                        {/if}
                        </tr>
                        {/for}
                        <tr>
                                <td>{$max_planets + 1}</td>
                                <td colspan="7"><a href="?page=fleetTable&amp;galaxy={$galaxy}&amp;system={$system}&amp;planet={$max_planets + 1}&amp;planettype=1&amp;target_mission=15">{$LNG.gl_out_space}</a></td>
                        </tr>
                        <tr class="astrogx_foot">
                                <td colspan="8">({$planetcount})</td>
                        </tr>
                        <tr style="display: none;" id="fleetstatusrow">
                                <th colspan="8">{$LNG.cff_fleet_target}</th>
                        </tr>
                        </tbody>
                </table>
                </div>

                {* ============ ASTROIO v3.2: LEYENDA COMPLETA (siempre visible) ============ *}
                <div class="astrogx_legend">
                        <span class="astrogx_legend_title">📖 {$LNG.gl_legend}</span>
                        <div class="astrogx_legend_grid">
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#66ff99"></span>{$LNG.gl_leg_own}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#00e0ff"></span>{$LNG.gl_leg_occupied}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#556677"></span>{$LNG.gl_leg_empty}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#c8d2dc"></span>{$LNG.gl_leg_moon}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#ffaa33"></span>{$LNG.gl_leg_debris}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#8899ff"></span>{$LNG.gl_leg_deepspace}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#2ecc71"></span>{$LNG.gl_leg_protected}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#ef4444"></span>{$LNG.gl_leg_attackable}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#fbbf24"></span>{$LNG.gl_leg_allydepot}</div>
                                <div class="astrogx_legend_item"><span class="astrogx_leg_dot" style="background:#6b7280">💀</span>{$LNG.gl_leg_ruins}</div>
                                <div class="astrogx_legend_item"><i class="fas fa-crosshairs"></i>{$LNG.gl_leg_phalanx}</div>
                        </div>
                        <div class="astrogx_legend_sub">
                                <b>F</b> {$LNG.gl_strong_player} &nbsp;·&nbsp; <b>D</b> {$LNG.gl_week_player} &nbsp;·&nbsp; <b>V</b> {$LNG.gl_vacation} &nbsp;·&nbsp; <b>B</b> {$LNG.gl_banned} &nbsp;·&nbsp; <b>i</b> {$LNG.gl_inactive_seven} &nbsp;·&nbsp; <b>I</b> {$LNG.gl_inactive_twentyeight}
                        </div>
                </div>

        </div>

</div>

<script type="text/javascript">
        status_ok               = '{$LNG.gl_ajax_status_ok}';
        status_fail             = '{$LNG.gl_ajax_status_fail}';
        MaxFleetSetting = {$settings_fleetactions};
</script>
{/block}
