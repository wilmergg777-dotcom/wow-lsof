<style>
/* ===== MENÚ LATERAL MODERNO ASTROIO (SEMI-TRANSPARENTE) ===== */
#leftmenu {
        background: rgba(11, 16, 30, 0.72);
        backdrop-filter: blur(6px);
        -webkit-backdrop-filter: blur(6px);
        border-radius: 10px;
        padding: 0;
        margin: 6px;
        box-shadow: 0 6px 18px rgba(0, 0, 0, 0.5);
        overflow: hidden;
        font-family: 'Segoe UI', Roboto, sans-serif;
        border: 1px solid rgba(0, 200, 255, 0.2);
}

#leftmenu .menu_header {
        background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
        border-bottom: 2px solid #00ccff;
        color: #cbd5e1;
        padding: 10px 12px;
        font-size: 11px;
        font-weight: 600;
        border-radius: 10px 10px 0 0;
}

#leftmenu .menu_header .user_row {
        font-size: 12px;
        margin-bottom: 6px;
        font-weight: 600;
        color: #94a3b8;
}

#leftmenu .menu_header .user_row span {
        color: #00e0ff;
        font-weight: 700;
        text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}

#leftmenu .menu_header .stats_row {
        display: flex;
        flex-direction: column;
        gap: 3px;
        font-size: 10px;
        font-weight: 500;
}

#leftmenu .menu_header .stat_item {
        color: #94a3b8;
        display: flex;
        align-items: center;
        justify-content: space-between;
}

#leftmenu .menu_header .stat_item.green {
        color: #4aff88;
}

#leftmenu .menu_header .stat_item .value {
        color: #00e0ff;
        font-family: 'Courier New', monospace;
        font-weight: 700;
}

#leftmenu .menu_header .stat_item.green .value {
        color: #4aff88;
}

#leftmenu .menu_header .copy_row {
        font-size: 9px;
        color: #475569;
        margin-top: 8px;
        padding-top: 6px;
        border-top: 1px solid rgba(255, 255, 255, 0.05);
        text-align: center;
}

#leftmenu .alerts_row {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 3px;
        padding: 5px 6px;
        background: rgba(0, 0, 0, 0.35);
        border-top: 1px solid rgba(255, 200, 50, 0.20);
        border-bottom: 1px solid rgba(255, 200, 50, 0.20);
}

#leftmenu .alert_btn {
        display: flex;
        align-items: center;
        justify-content: center;
        height: 24px;
        border-radius: 5px;
        font-size: 12px;
        border: 1px solid;
        box-sizing: border-box;
        user-select: none;
        position: relative;
        transition: all 0.25s ease;
}

#leftmenu .alert_btn.off {
        background: rgba(60, 70, 90, 0.20);
        border-color: rgba(90, 110, 140, 0.30);
        opacity: 0.45;
        filter: grayscale(80%);
}

#leftmenu .alert_btn.attack.active {
        background: rgba(255, 0, 0, 0.25);
        border-color: #ff0000;
        animation: astroio_alert_red 1s infinite;
}

@keyframes astroio_alert_red {
        0%, 100% {
                background: rgba(255, 0, 0, 0.55);
                box-shadow: 0 0 10px rgba(255, 0, 0, 0.9);
        }
        50% {
                background: rgba(255, 0, 0, 0.05);
                box-shadow: none;
        }
}

#leftmenu .alert_btn.spy.active {
        background: rgba(255, 204, 0, 0.25);
        border-color: #ffcc00;
        animation: astroio_alert_yellow 1s infinite;
}

@keyframes astroio_alert_yellow {
        0%, 100% {
                background: rgba(255, 204, 0, 0.55);
                box-shadow: 0 0 10px rgba(255, 204, 0, 0.85);
        }
        50% {
                background: rgba(255, 204, 0, 0.05);
                box-shadow: none;
        }
}

#leftmenu .alert_btn.transport.active {
        background: rgba(0, 136, 255, 0.25);
        border-color: #0088ff;
        animation: astroio_alert_blue 1s infinite;
}

@keyframes astroio_alert_blue {
        0%, 100% {
                background: rgba(0, 136, 255, 0.55);
                box-shadow: 0 0 10px rgba(0, 136, 255, 0.85);
        }
        50% {
                background: rgba(0, 136, 255, 0.05);
                box-shadow: none;
        }
}

#leftmenu .menu_tabs {
        display: flex;
        gap: 3px;
        padding: 4px;
        background: rgba(0, 0, 0, 0.3);
        border-bottom: 1px solid rgba(0, 200, 255, 0.15);
}

#leftmenu .menu_tab_btn {
        flex: 1;
        padding: 4px 3px;
        text-align: center;
        border-radius: 6px;
        font-size: 9px;
        font-weight: 700;
        cursor: pointer;
        user-select: none;
        transition: all 0.25s ease;
        border: 1px solid transparent;
        letter-spacing: 0.4px;
}

#leftmenu .menu_tab_btn.nom {
        background: rgba(0, 150, 255, 0.15);
        color: #66ccff;
        border-color: rgba(0, 200, 255, 0.3);
}

#leftmenu .menu_tab_btn.nom.active,
#leftmenu .menu_tab_btn.nom:hover {
        background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
        color: #fff;
        box-shadow: 0 3px 8px rgba(0, 150, 255, 0.4);
        border-color: #00ccff;
}

#leftmenu .menu_tab_btn.mop {
        background: rgba(150, 0, 255, 0.15);
        color: #cc88ff;
        border-color: rgba(180, 100, 255, 0.3);
}

#leftmenu .menu_tab_btn.mop.active,
#leftmenu .menu_tab_btn.mop:hover {
        background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(170, 68, 255, 0.9));
        color: #fff;
        box-shadow: 0 3px 8px rgba(150, 0, 255, 0.4);
        border-color: #cc88ff;
}

#leftmenu .tab_content {
        padding: 4px;
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 3px;
}

#leftmenu .tab_content.hidden {
        display: none;
}

#leftmenu .tab_content a {
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        padding: 3px 2px;
        color: #66ccff !important;
        text-decoration: none;
        border-radius: 4px;
        font-weight: 600;
        font-size: 8px;
        background: rgba(0, 150, 255, 0.12);
        border: 1px solid rgba(0, 200, 255, 0.25);
        transition: all 0.25s ease;
        letter-spacing: 0.3px;
        min-height: 22px;
        line-height: 1.1;
        position: relative;
        overflow: hidden;
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
}

#leftmenu .tab_content a::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        height: 100%;
        width: 3px;
        background: #00ccff;
        transform: scaleY(0);
        transition: transform 0.25s ease;
}

#leftmenu .tab_content a:hover {
        background: rgba(0, 200, 255, 0.25);
        color: #00e0ff !important;
        transform: translateY(-2px);
        box-shadow: 0 3px 10px rgba(0, 200, 255, 0.35);
        border-color: #00ccff;
}

#leftmenu .tab_content a:hover::before {
        transform: scaleY(1);
}

#leftmenu .tab_content.mop a {
        color: #cc88ff !important;
        background: rgba(150, 0, 255, 0.12);
        border: 1px solid rgba(180, 100, 255, 0.25);
}

#leftmenu .tab_content.mop a::before {
        background: #cc88ff;
}

#leftmenu .tab_content.mop a:hover {
        background: rgba(150, 0, 255, 0.25);
        color: #dd99ff !important;
        box-shadow: 0 3px 10px rgba(150, 0, 255, 0.35);
        border-color: #cc88ff;
}

#leftmenu .tab_content.mop a.wallet_mop_btn {
        color: #66ffaa !important;
        background: rgba(0, 255, 130, 0.12);
        border: 1px solid rgba(0, 255, 130, 0.4);
        font-weight: 800;
        letter-spacing: 0.5px;
}

#leftmenu .tab_content.mop a.wallet_mop_btn::before {
        background: #00ff88;
}

#leftmenu .tab_content.mop a.wallet_mop_btn:hover {
        background: rgba(0, 255, 130, 0.28);
        color: #aaffcc !important;
        border-color: #00ff88;
        box-shadow: 0 3px 10px rgba(0, 255, 130, 0.55);
}

#leftmenu .tab_content.mop a.raffle_mop_btn {
        color: #66ffee !important;
        background: rgba(0, 255, 220, 0.12);
        border: 1px solid rgba(0, 255, 220, 0.4);
        font-weight: 800;
        letter-spacing: 0.5px;
}

#leftmenu .tab_content.mop a.raffle_mop_btn::before {
        background: #00ffdd;
}

#leftmenu .tab_content.mop a.raffle_mop_btn:hover {
        background: rgba(0, 255, 220, 0.28);
        color: #aaffee !important;
        border-color: #00ffdd;
        box-shadow: 0 3px 10px rgba(0, 255, 220, 0.6);
}

#leftmenu .tab_content.mop a.lottery_mop_btn {
        color: #ffdd88 !important;
        background: rgba(255, 200, 0, 0.12);
        border: 1px solid rgba(255, 200, 0, 0.4);
        font-weight: 800;
        letter-spacing: 0.5px;
}

#leftmenu .tab_content.mop a.lottery_mop_btn::before {
        background: #ffcc00;
}

#leftmenu .tab_content.mop a.lottery_mop_btn:hover {
        background: rgba(255, 200, 0, 0.28);
        color: #ffeeaa !important;
        border-color: #ffcc00;
        box-shadow: 0 3px 10px rgba(255, 200, 0, 0.6);
}

#leftmenu .tab_content.mop a.tasks_mop_btn {
        color: #88ccff !important;
        background: rgba(0, 150, 255, 0.12);
        border: 1px solid rgba(0, 180, 255, 0.4);
        font-weight: 800;
        letter-spacing: 0.5px;
}

#leftmenu .tab_content.mop a.tasks_mop_btn::before {
        background: #00aaff;
}

#leftmenu .tab_content.mop a.tasks_mop_btn:hover {
        background: rgba(0, 180, 255, 0.28);
        color: #aaddff !important;
        border-color: #00aaff;
        box-shadow: 0 3px 10px rgba(0, 170, 255, 0.6);
}

/* ============================================================
   ASTROIO — Mini Torneos (nuevo botón MOP)
   ============================================================ */
#leftmenu .tab_content.mop a.tourney_mop_btn {
        color: #ffcc66 !important;
        background: linear-gradient(135deg, rgba(255, 180, 0, 0.15), rgba(255, 120, 0, 0.15));
        border: 1px solid rgba(255, 200, 50, 0.55);
        font-weight: 800;
        letter-spacing: 0.5px;
        text-shadow: 0 0 6px rgba(255, 200, 50, 0.4);
}

#leftmenu .tab_content.mop a.tourney_mop_btn::before {
        background: linear-gradient(180deg, #ffdd88, #ff9900);
}

#leftmenu .tab_content.mop a.tourney_mop_btn:hover {
        background: linear-gradient(135deg, rgba(255, 200, 50, 0.35), rgba(255, 130, 0, 0.35));
        color: #fff5cc !important;
        border-color: #ffcc00;
        box-shadow: 0 3px 12px rgba(255, 200, 50, 0.7);
        text-shadow: 0 0 10px rgba(255, 220, 100, 0.9);
}
/* ============================================================ */

/* ============================================================
   ASTROIO — La Cueva Pirata (nuevo botón MOP)
   ============================================================ */
#leftmenu .tab_content.mop a.cueva_mop_btn {
        color: #ffd700 !important; /* Dorado Pirata */
        background: linear-gradient(135deg, rgba(80, 20, 20, 0.4), rgba(30, 10, 10, 0.4));
        border: 1px solid rgba(255, 215, 0, 0.5);
        font-weight: 800;
        letter-spacing: 0.5px;
        text-shadow: 0 0 6px rgba(255, 215, 0, 0.6);
}

#leftmenu .tab_content.mop a.cueva_mop_btn::before {
        background: linear-gradient(180deg, #ffd700, #b8860b);
}

#leftmenu .tab_content.mop a.cueva_mop_btn:hover {
        background: linear-gradient(135deg, rgba(255, 215, 0, 0.3), rgba(80, 20, 20, 0.6));
        color: #ffffff !important;
        border-color: #ffd700;
        box-shadow: 0 3px 12px rgba(255, 215, 0, 0.6);
        text-shadow: 0 0 10px rgba(255, 255, 255, 0.8);
}
/* ============================================================ */

#leftmenu .tab_content.mop a.pve_mop_btn {
        color: #dd99ff !important;
        background: rgba(170, 50, 255, 0.15);
        border: 1px solid rgba(200, 100, 255, 0.5);
        font-weight: 800;
        letter-spacing: 0.5px;
        position: relative;
        overflow: visible;
}

#leftmenu .tab_content.mop a.pve_mop_btn::before {
        background: #bb44ff;
}

#leftmenu .tab_content.mop a.pve_mop_btn:hover {
        background: rgba(170, 50, 255, 0.32);
        color: #ffffff !important;
        border-color: #cc66ff;
        box-shadow: 0 3px 10px rgba(170, 50, 255, 0.65);
}

#leftmenu .pve_countdown_badge {
        display: inline-block;
        margin-left: 4px;
        padding: 1px 4px;
        border-radius: 6px;
        font-family: 'Courier New', monospace;
        font-size: 7px;
        font-weight: 700;
        letter-spacing: 0;
        vertical-align: middle;
        line-height: 1.2;
        transition: all 0.3s ease;
}

#leftmenu .pve_countdown_badge.state-far {
        background: rgba(0, 200, 100, 0.18);
        color: #88ffbb;
        border: 1px solid rgba(0, 255, 130, 0.4);
}

#leftmenu .pve_countdown_badge.state-soon {
        background: rgba(255, 200, 0, 0.20);
        color: #ffee88;
        border: 1px solid rgba(255, 220, 50, 0.55);
        animation: astroio_pve_pulse 1.5s infinite;
}

#leftmenu .pve_countdown_badge.state-active {
        background: rgba(255, 50, 50, 0.25);
        color: #ffbbbb;
        border: 1px solid rgba(255, 80, 80, 0.65);
        font-weight: 900;
        animation: astroio_pve_pulse 0.9s infinite;
}

#leftmenu .pve_countdown_badge.state-off {
        background: rgba(120, 120, 120, 0.15);
        color: #99aabb;
        border: 1px solid rgba(120, 120, 120, 0.35);
}

#leftmenu .pve_countdown_badge.state-boss {
        background: rgba(200, 50, 255, 0.28);
        color: #ffbbff;
        border: 1px solid rgba(255, 100, 255, 0.7);
        font-weight: 900;
        animation: astroio_pve_pulse 1.0s infinite;
}

#leftmenu .pve_countdown_badge.state-boss-soon {
        background: rgba(255, 150, 255, 0.22);
        color: #ffccff;
        border: 1px solid rgba(255, 150, 255, 0.6);
        animation: astroio_pve_pulse 1.2s infinite;
}

#leftmenu .pve_countdown_badge.state-boss-running {
        background: rgba(200, 50, 255, 0.35);
        color: #ffddff;
        border: 1px solid rgba(255, 100, 255, 0.85);
        font-weight: 900;
        animation: astroio_pve_pulse 0.8s infinite;
}

@keyframes astroio_pve_pulse {
        0%, 100% { opacity: 1; transform: scale(1); }
        50%      { opacity: 0.65; transform: scale(1.06); }
}

#leftmenu .tab_content.mop a.pvp_mop_btn {
        color: #ff8888 !important;
        background: rgba(255, 50, 50, 0.15);
        border: 1px solid rgba(255, 80, 80, 0.5);
        font-weight: 800;
        letter-spacing: 0.5px;
        position: relative;
        overflow: visible;
}

#leftmenu .tab_content.mop a.pvp_mop_btn::before {
        background: #ff4444;
}

#leftmenu .tab_content.mop a.pvp_mop_btn:hover {
        background: rgba(255, 50, 50, 0.32);
        color: #ffffff !important;
        border-color: #ff6666;
        box-shadow: 0 3px 10px rgba(255, 50, 50, 0.7);
}

#leftmenu .pvp_countdown_badge {
        display: inline-block;
        margin-left: 4px;
        padding: 1px 4px;
        border-radius: 6px;
        font-family: 'Courier New', monospace;
        font-size: 7px;
        font-weight: 700;
        letter-spacing: 0;
        vertical-align: middle;
        line-height: 1.2;
        transition: all 0.3s ease;
}

#leftmenu .pvp_countdown_badge.state-far {
        background: rgba(0, 200, 100, 0.18);
        color: #88ffbb;
        border: 1px solid rgba(0, 255, 130, 0.4);
}

#leftmenu .pvp_countdown_badge.state-soon {
        background: rgba(255, 200, 0, 0.20);
        color: #ffee88;
        border: 1px solid rgba(255, 220, 50, 0.55);
        animation: astroio_pvp_pulse 1.5s infinite;
}

#leftmenu .pvp_countdown_badge.state-active {
        background: rgba(255, 50, 50, 0.25);
        color: #ffbbbb;
        border: 1px solid rgba(255, 80, 80, 0.65);
        font-weight: 900;
        animation: astroio_pvp_pulse 0.9s infinite;
}

#leftmenu .pvp_countdown_badge.state-off {
        background: rgba(120, 120, 120, 0.15);
        color: #99aabb;
        border: 1px solid rgba(120, 120, 120, 0.35);
}

@keyframes astroio_pvp_pulse {
        0%, 100% { opacity: 1; transform: scale(1); }
        50%      { opacity: 0.65; transform: scale(1.06); }
}

#leftmenu .tab_content.mop a.war_mop_btn {
        color: #ff8888 !important;
        background: rgba(200, 0, 0, 0.15);
        border: 1px solid rgba(255, 68, 68, 0.5);
        font-weight: 800;
        letter-spacing: 0.5px;
}

#leftmenu .tab_content.mop a.war_mop_btn::before {
        background: #ff4444;
}

#leftmenu .tab_content.mop a.war_mop_btn:hover {
        background: rgba(220, 0, 0, 0.32);
        color: #ffcccc !important;
        border-color: #ff4444;
        box-shadow: 0 3px 10px rgba(255, 68, 68, 0.6);
}

#leftmenu .tab_content.mop a.minijuegotopo_mop_btn {
        color: #dde5ee !important;
        background: linear-gradient(135deg, rgba(180, 190, 205, 0.15), rgba(140, 150, 165, 0.15));
        border: 1px solid rgba(200, 210, 225, 0.55);
        font-weight: 800;
        letter-spacing: 0.5px;
        text-shadow: 0 0 6px rgba(200, 215, 235, 0.4);
}

#leftmenu .tab_content.mop a.minijuegotopo_mop_btn::before {
        background: linear-gradient(180deg, #e8eef6, #a8b5c5);
}

/* ============================================================
   ASTROIO — Minijuego Navidad (nuevo botón MOP)
   ============================================================ */
#leftmenu .tab_content.mop a.minijuegonavidad_mop_btn {
        color: #ffdd88 !important;
        background: linear-gradient(135deg, rgba(200, 30, 30, 0.2), rgba(150, 20, 20, 0.2));
        border: 1px solid rgba(255, 200, 50, 0.55);
        font-weight: 800;
        letter-spacing: 0.5px;
        text-shadow: 0 0 6px rgba(255, 200, 50, 0.4);
}

#leftmenu .tab_content.mop a.minijuegonavidad_mop_btn::before {
        background: linear-gradient(180deg, #ffdd88, #cc2222);
}

#leftmenu .tab_content.mop a.minijuegonavidad_mop_btn:hover {
        background: linear-gradient(135deg, rgba(255, 200, 50, 0.35), rgba(200, 30, 30, 0.35));
        color: #fff5cc !important;
        border-color: #ffcc00;
        box-shadow: 0 3px 12px rgba(255, 200, 50, 0.7);
        text-shadow: 0 0 10px rgba(255, 220, 100, 0.9);
}
/* ============================================================ */

#leftmenu .menu_content_full {
        padding: 6px;
        border-top: 1px solid rgba(255, 255, 255, 0.08);
        background: rgba(0, 0, 0, 0.15);
        
        /* 🆕 Convertimos el contenedor en una cuadrícula de 2 columnas (1x2) */
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 6px !important; 
        width: 100% !important;
        box-sizing: border-box !important;
}

#leftmenu .menu_content_full a {
        /* 🆕 Centrado y estirado */
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
        width: 100% !important;
        box-sizing: border-box !important;
        
        padding: 6px 4px !important;
        color: #66ff99 !important;
        text-decoration: none;
        border-radius: 6px;
        font-weight: 600;
        font-size: 9px !important;
        line-height: 1.2 !important;
        background: rgba(0, 255, 100, 0.10);
        border: 1px solid rgba(0, 255, 100, 0.25);
        transition: all 0.25s ease;
        letter-spacing: 0.4px;
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
        
        /* Quitamos los márgenes que rompen la cuadrícula */
        margin-bottom: 0 !important; 
}

/* Hacemos que el botón de Administración ocupe las 2 columnas si está solo */
#leftmenu .menu_content_full a[href*="admin.php"] {
        grid-column: 1 / -1 !important;
}

#leftmenu .menu_content_full a {
        display: block;
        padding: 3px 5px;
        color: #66ff99 !important;
        text-decoration: none;
        border-radius: 4px;
        font-weight: 600;
        font-size: 8px;
        text-align: center;
        background: rgba(0, 255, 100, 0.10);
        border: 1px solid rgba(0, 255, 100, 0.25);
        transition: all 0.25s ease;
        letter-spacing: 0.4px;
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
}

#leftmenu .menu_content_full a:hover {
        background: rgba(0, 255, 100, 0.25);
        box-shadow: 0 0 12px rgba(0, 255, 100, 0.45);
        border-color: rgba(0, 255, 100, 0.6);
}

#leftmenu .menu_content_full a.vip_btn {
        color: #ff99bb !important;
        background: rgba(255, 68, 136, 0.12);
        border: 1px solid rgba(255, 68, 136, 0.4);
        margin-bottom: 3px;
        font-weight: 800;
        letter-spacing: 0.5px;
}
#leftmenu .menu_content_full a.vip_btn:hover {
        color: #ffffff !important;
        background: linear-gradient(135deg, rgba(255, 68, 136, 0.9), rgba(255, 136, 170, 0.9));
        box-shadow: 0 0 14px rgba(255, 68, 136, 0.7);
        border-color: #ff88aa;
        transform: translateY(-1px);
}

#leftmenu .menu_content_full a.shop_btn {
        color: #ffdd88 !important;
        background: linear-gradient(135deg, rgba(0, 170, 255, 0.12), rgba(255, 200, 0, 0.12));
        border: 1px solid rgba(255, 200, 0, 0.5);
        margin-bottom: 3px;
        font-weight: 800;
        letter-spacing: 0.5px;
        position: relative;
}
#leftmenu .menu_content_full a.shop_btn:hover {
        color: #1a1000 !important;
        background: linear-gradient(135deg, rgba(0, 204, 255, 0.95), rgba(255, 204, 0, 0.95));
        box-shadow: 0 0 16px rgba(255, 200, 0, 0.8);
        border-color: #ffdd88;
        transform: translateY(-1px);
}

#leftmenu .menu_content_full a.market_btn {
        color: #ffdd88 !important;
        background: rgba(255, 170, 51, 0.12);
        border: 1px solid rgba(255, 170, 51, 0.4);
        margin-bottom: 3px;
        font-weight: 800;
        letter-spacing: 0.5px;
}
#leftmenu .menu_content_full a.market_btn:hover {
        color: #1a1000 !important;
        background: linear-gradient(135deg, rgba(255, 170, 51, 0.95), rgba(255, 204, 102, 0.95));
        box-shadow: 0 0 14px rgba(255, 170, 51, 0.7);
        border-color: #ffcc66;
        transform: translateY(-1px);
}

#leftmenu .menu_content_full a.adminwallet_btn {
        color: #66ddff !important;
        background: rgba(0, 170, 255, 0.12);
        border: 1px solid rgba(0, 170, 255, 0.45);
        margin-bottom: 3px;
        font-weight: 800;
        letter-spacing: 0.5px;
        position: relative;
}
#leftmenu .menu_content_full a.adminwallet_btn:hover {
        color: #ffffff !important;
        background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
        box-shadow: 0 0 14px rgba(0, 204, 255, 0.8);
        border-color: #66ddff;
        transform: translateY(-1px);
}

#leftmenu .menu_content_full a.adminwallet_btn .adminwallet_badge_icon {
        display: none;
        margin-left: 4px;
        color: #ffaa33;
        font-weight: bold;
        animation: astroio_pulse_warn 2s infinite;
}
#leftmenu .menu_content_full a.adminwallet_btn.sin_datos .adminwallet_badge_icon {
        display: inline;
}
@keyframes astroio_pulse_warn {
        0%, 100% { opacity: 1; }
        50%      { opacity: 0.35; }
}

#leftmenu .menu_content_full a.referral_btn {
        color: #cc88ff !important;
        background: rgba(150, 0, 255, 0.12);
        border: 1px solid rgba(180, 100, 255, 0.45);
        margin-bottom: 3px;
        font-weight: 800;
        letter-spacing: 0.5px;
}
#leftmenu .menu_content_full a.referral_btn:hover {
        color: #ffffff !important;
        background: linear-gradient(135deg, rgba(119, 0, 204, 0.95), rgba(170, 68, 255, 0.95));
        box-shadow: 0 0 14px rgba(170, 68, 255, 0.8);
        border-color: #cc88ff;
        transform: translateY(-1px);
}

#leftmenu .menu_content_full a.battlepass_btn {
        color: #ffaa88 !important;
        background: rgba(255, 68, 34, 0.12);
        border: 1px solid rgba(255, 100, 50, 0.45);
        margin-bottom: 3px;
        font-weight: 800;
        letter-spacing: 0.5px;
        position: relative;
}
#leftmenu .menu_content_full a.battlepass_btn:hover {
        color: #ffffff !important;
        background: linear-gradient(135deg, rgba(204, 34, 0, 0.95), rgba(255, 102, 51, 0.95));
        box-shadow: 0 0 14px rgba(255, 100, 50, 0.8);
        border-color: #ff8844;
        transform: translateY(-1px);
}
#leftmenu .menu_content_full a.battlepass_btn::after {
        content: '⚔️';
        margin-left: 5px;
        font-size: 9px;
        animation: astroio_bp_pulse 2s infinite;
        display: inline-block;
}
@keyframes astroio_bp_pulse {
        0%, 100% { transform: scale(1); opacity: 1; }
        50%      { transform: scale(1.2); opacity: 0.7; }
}

#leftmenu .tab_content.mop a.bugreport_mop_btn {
        color: #ffbb66 !important;
        background: rgba(255, 150, 0, 0.12);
        border: 1px solid rgba(255, 150, 0, 0.45);
        font-weight: 800;
        letter-spacing: 0.5px;
}

#leftmenu .tab_content.mop a.bugreport_mop_btn::before {
        background: #ffaa33;
}

#leftmenu .tab_content.mop a.bugreport_mop_btn:hover {
        background: rgba(255, 150, 0, 0.28);
        color: #ffdd99 !important;
        border-color: #ffaa33;
        box-shadow: 0 3px 10px rgba(255, 170, 51, 0.6);
}

/* 🆕 DESCARGAS: botón del menú lateral (APK + launchers) */
#leftmenu .tab_content.mop a.descargas_mop_btn {
        color: #66ddff !important;
        background: rgba(0, 200, 255, 0.12);
        border: 1px solid rgba(0, 200, 255, 0.45);
        font-weight: 800;
        letter-spacing: 0.5px;
}

#leftmenu .tab_content.mop a.descargas_mop_btn::before {
        background: #00ccff;
}

#leftmenu .tab_content.mop a.descargas_mop_btn:hover {
        background: rgba(0, 200, 255, 0.28);
        color: #bbf0ff !important;
        border-color: #00ccff;
        box-shadow: 0 3px 10px rgba(0, 204, 255, 0.6);
}

#leftmenu .ally_section {
        border-top: 1px solid rgba(0, 200, 255, 0.15);
        padding: 5px 4px;
        background: rgba(0, 0, 0, 0.25);
}

#leftmenu .ally_title {
        background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 119, 204, 0.9));
        color: #fff;
        padding: 4px 6px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 9px;
        text-align: center;
        margin-bottom: 3px;
        border-left: 3px solid #00e0ff;
        letter-spacing: 0.4px;
}

#leftmenu .ally_member {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 3px 4px;
        margin: 1px 0;
        border-radius: 4px;
        font-size: 8px;
        transition: all 0.2s ease;
        cursor: pointer;
}

#leftmenu .ally_member.online {
        background: rgba(0, 255, 100, 0.10);
        border-left: 3px solid #00ff88;
}

#leftmenu .ally_member.offline {
        background: rgba(100, 100, 100, 0.10);
        border-left: 3px solid #556677;
}

#leftmenu .ally_member:hover {
        transform: translateX(3px);
}

#leftmenu .ally_member .name {
        color: #c8d6e5;
        font-weight: 500;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        max-width: 100px;
}

#leftmenu .ally_member.online .name {
        color: #ffffff;
        font-weight: 600;
}

#leftmenu .ally_member.offline .name {
        color: #8899aa;
}

#leftmenu .ally_member .status_dot {
        font-size: 7px;
        margin-right: 3px;
}

#leftmenu .ally_member .time {
        font-size: 7px;
        font-family: 'Courier New', monospace;
        color: #66ff99;
}

#leftmenu .ally_member .time.offline_time {
        color: #8899aa;
        font-style: italic;
}

.content_page #contentPlanet {
        height: 250px !important;
        min-height: 250px !important;
        max-height: 250px !important;
        overflow: hidden !important;
}

.content_page #contentPlanet #listDetailPlanet {
        position: absolute !important;
        right: 20px !important;
        top: 60px !important;
}

/* ============================================================
   ASTROIO — En móvil: ocultar alertas y panel de usuario
   dentro del #leftmenu (ya están en el topnav móvil)
   ============================================================ */
@media (max-width: 768px) {
    #leftmenu .menu_header,
    #leftmenu .alerts_row {
        display: none !important;
    }
}

</style>

<div id="leftmenu">

        <div class="menu_header">
                <div class="user_row">
                        👤 {$LNG.mn_username} : <span>{$username}</span>
                </div>
                <div class="stats_row">
                        <div class="stat_item green">
                                🟢 Últimas 24h: <span class="value">{$onlineCount}/{$totalCount}</span>
                        </div>
                        <div class="stat_item">
                                🕐 Hora: <span class="value">{$servertime}</span>
                        </div>
                </div>
                <div class="copy_row">
                        © Copyright AstroIO 2026
                </div>
        </div>

        <div class="alerts_row">
                <div class="alert_btn attack {if !empty($globalAlerts.attack)}active{else}off{/if}"
                     title="Ataque{if !empty($globalAlerts.attack)} ({count($globalAlerts.attack)}){/if}">⚔️</div>
                <div class="alert_btn spy {if !empty($globalAlerts.spy)}active{else}off{/if}"
                     title="Espionaje{if !empty($globalAlerts.spy)} ({count($globalAlerts.spy)}){/if}">🕵️</div>
                <div class="alert_btn transport {if !empty($globalAlerts.transport)}active{else}off{/if}"
                     title="Transporte{if !empty($globalAlerts.transport)} ({count($globalAlerts.transport)}){/if}">📥</div>
        </div>

        <div class="menu_tabs">
                <div class="menu_tab_btn nom active" id="tabBtnNOM" onclick="astroio_switchTab('nom')">👑 MC1</div>
                <div class="menu_tab_btn mop" id="tabBtnMOP" onclick="astroio_switchTab('mop')">🛸 MOP</div>
        </div>

        <div class="tab_content" id="tabNOM">
                {if isModuleAvailable($smarty.const.MODULE_BUILDING)}<a href="game.php?page=buildings">🏗️ {$LNG.lm_buildings}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_RESEARCH)}<a href="game.php?page=research">🔬 {$LNG.lm_research}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_SHIPYARD_FLEET)}<a href="game.php?page=shipyard&amp;mode=fleet">🚀 {$LNG.lm_shipshard}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_SHIPYARD_DEFENSIVE)}<a href="game.php?page=shipyard&amp;mode=defense">🛡️ {$LNG.lm_defenses}</a>{/if}
                
                {* 🆕 FIX: Cambiado || por && para que desaparezca si Oficiales está off *}
                {if isModuleAvailable($smarty.const.MODULE_OFFICIER) && isModuleAvailable($smarty.const.MODULE_DMEXTRAS)}
                        <a href="game.php?page=officier">🎖️ {$LNG.lm_officiers}</a>
                {/if}
                
                {if isModuleAvailable($smarty.const.MODULE_FLEET_TRADER)}<a href="game.php?page=fleetDealer">🏪 {$LNG.lm_fleettrader}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_RESOURCE_TRADER)}<a href="game.php?page=resourceTrader">💱 Comerciante</a>{/if}
                
                {* 🆕 FIX: Cambiado MODULE_TRADER por MODULE_FLEET_TABLE para la Flota *}
                {if isModuleAvailable($smarty.const.MODULE_FLEET_TABLE)}
                        <a href="game.php?page=fleetTable">⚓️ {$LNG.lm_fleet}</a>
                {/if}
                
                {if isModuleAvailable($smarty.const.MODULE_RESSOURCE_LIST)}<a href="game.php?page=resources">💎 {$LNG.lm_resources}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_GALAXY)}<a href="game.php?page=galaxy">🧭 {$LNG.lm_galaxy}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_ALLIANCE)}<a href="game.php?page=alliance">🏰 {$LNG.lm_alliance}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_SUPPORT)}<a href="game.php?page=ticket">🛠️ {$LNG.lm_support}</a>{/if}
                <a href="index.php?page=rules" target="rules">📜 {$LNG.lm_rules}</a>
                {if isModuleAvailable($smarty.const.MODULE_SIMULATOR)}<a href="game.php?page=battleSimulator">💥 {$LNG.lm_battlesim}</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_NOTICE)}<a href="javascript:OpenPopup('?page=notes', 'notes', 720, 300);">📝 {$LNG.lm_notes}</a>{/if}
                <div class="clear"></div>
        </div>

        <div class="tab_content mop hidden" id="tabMOP">
                {if isModuleAvailable($smarty.const.MODULE_RACES)}<a href="game.php?page=race">🧬 Raza</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_FACTIONS)}<a href="game.php?page=faction">⚜️ Facción</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_CONTAINERS)}<a href="game.php?page=containers">📦 Contenedores</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_EVENTS)}<a href="game.php?page=events">✨ Eventos</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_TASKS)}<a href="game.php?page=tasks" class="tasks_mop_btn">🎯 Tareas</a>{/if}

                {* ============================================================
                   ASTROIO — Mini Torneos (CONDICIÓN AÑADIDA)
                   ============================================================ *}
                {if isModuleAvailable($smarty.const.MODULE_TOURNEY)}<a href="game.php?page=tourney" class="tourney_mop_btn">🏆 Mini Torneos</a>{/if}
                {* ============================================================ *}

                {* ============================================================
                   ASTROIO — La Cueva Pirata (Minijuegos)
                   ============================================================ *}
                {if isModuleAvailable($smarty.const.MODULE_CUEVA)}<a href="game.php?page=cueva" class="cueva_mop_btn">🏴‍☠️ La Cueva Pirata</a>{/if}
                {* ============================================================ *}

                {if isModuleAvailable($smarty.const.MODULE_WALLET)}<a href="game.php?page=wallet" class="wallet_mop_btn">🏛️ Banco</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_RAFFLES)}<a href="game.php?page=raffles" class="raffle_mop_btn">🎰 Rifas</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_LOTTERY)}<a href="game.php?page=lottery" class="lottery_mop_btn">🎫 Lotería</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_MINIJUEGOTOPO)}<a href="game.php?page=minijuegotopo" class="minijuegotopo_mop_btn">🐹 Golpea al Topo</a>{/if}

                {* ============================================================
                   ASTROIO — Minijuego Navidad (NUEVO BOTÓN MOP)
                   ============================================================ *}
                {if isModuleAvailable($smarty.const.MODULE_MINIJUEGONAVIDAD)}<a href="game.php?page=minijuegonavidad" class="minijuegonavidad_mop_btn">🎄 Memoria Navideña</a>{/if}
                {* ============================================================ *}

                {if isModuleAvailable($smarty.const.MODULE_PVE)}
                        {assign var="pveCrisisTime"    value=0}
                        {assign var="pveCrisisActive"  value=0}
                        {assign var="pveEmpireTime"    value=0}
                        {assign var="pveEmpireActive"  value=0}
                        {assign var="pveBossTime"      value=0}
                        {assign var="pveBossEndTime"   value=0}
                        {assign var="pveBossActive"    value=0}
                        {assign var="pveBossStatus"    value='idle'}
                        {assign var="pveAnyActive"     value=0}
                        {if isset($pve) && is_array($pve)}
                                {if isset($pve.crisis_next_time)}{assign var="pveCrisisTime"    value=$pve.crisis_next_time}{/if}
                                {if isset($pve.crisis_active)}{assign var="pveCrisisActive"  value=$pve.crisis_active}{/if}
                                {if isset($pve.empire_next_time)}{assign var="pveEmpireTime"    value=$pve.empire_next_time}{/if}
                                {if isset($pve.empire_active)}{assign var="pveEmpireActive"  value=$pve.empire_active}{/if}
                                {if isset($pve.boss_next_time)}{assign var="pveBossTime"      value=$pve.boss_next_time}{/if}
                                {if isset($pve.boss_end_time)}{assign var="pveBossEndTime"   value=$pve.boss_end_time}{/if}
                                {if isset($pve.boss_active)}{assign var="pveBossActive"    value=$pve.boss_active}{/if}
                                {if isset($pve.boss_status)}{assign var="pveBossStatus"    value=$pve.boss_status}{/if}
                                {if isset($pve.any_active)}{assign var="pveAnyActive"     value=$pve.any_active}{/if}
                        {/if}
                        <a href="game.php?page=pve"
                           class="pve_mop_btn"
                           id="pve_mop_link"
                           data-crisis-time="{$pveCrisisTime}"
                           data-crisis-active="{$pveCrisisActive}"
                           data-empire-time="{$pveEmpireTime}"
                           data-empire-active="{$pveEmpireActive}"
                           data-boss-time="{$pveBossTime}"
                           data-boss-end-time="{$pveBossEndTime}"
                           data-boss-active="{$pveBossActive}"
                           data-boss-status="{$pveBossStatus}"
                           data-any-active="{$pveAnyActive}">
                                ⚔️ Eventos PvE
                                <span class="pve_countdown_badge state-off" id="pve_mop_badge">--</span>
                        </a>
                {/if}

                {if isModuleAvailable($smarty.const.MODULE_PVP)}
                        {assign var="pvpArenaActive"      value=0}
                        {assign var="pvpArenaWaiting"     value=0}
                        {assign var="pvpTournamentActive" value=0}
                        {assign var="pvpTournamentStatus" value=''}
                        {assign var="pvpTournamentTime"   value=0}
                        {if isset($pvp) && is_array($pvp)}
                                {if isset($pvp.arenas_active)}{assign var="pvpArenaActive"  value=$pvp.arenas_active}{/if}
                                {if isset($pvp.arenas_waiting)}{assign var="pvpArenaWaiting" value=$pvp.arenas_waiting}{/if}
                                {if isset($pvp.tournament_active)}{assign var="pvpTournamentActive" value=$pvp.tournament_active}{/if}
                                {if isset($pvp.tournament_status)}{assign var="pvpTournamentStatus" value=$pvp.tournament_status}{/if}
                                {if isset($pvp.tournament_time)}{assign var="pvpTournamentTime"   value=$pvp.tournament_time}{/if}
                        {/if}
                        <a href="game.php?page=pvp"
                           class="pvp_mop_btn"
                           id="pvp_mop_link"
                           data-arena-active="{$pvpArenaActive}"
                           data-arena-waiting="{$pvpArenaWaiting}"
                           data-tournament-active="{$pvpTournamentActive}"
                           data-tournament-status="{$pvpTournamentStatus}"
                           data-tournament-time="{$pvpTournamentTime}">
                                ⚔️ PvP
                                <span class="pvp_countdown_badge state-off" id="pvp_mop_badge">--</span>
                        </a>
                {/if}

                {if isModuleAvailable($smarty.const.MODULE_WAR)}<a href="game.php?page=war" class="war_mop_btn">🔥 Guerra WAR</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_BUGREPORT)}<a href="game.php?page=bugreport&mode=new" class="bugreport_mop_btn">🐛 Reportar Bug</a>{/if}
                <a href="game.php?page=descargas" class="descargas_mop_btn">📥 Descargas</a>

                <div class="clear"></div>
        </div>

        <div class="menu_content_full">
                {if isModuleAvailable($smarty.const.MODULE_MARKET)}<a href="game.php?page=market" class="market_btn">🛒 Mercado</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_VIP)}<a href="game.php?page=vip" class="vip_btn">🌟 VIP Prime</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_SHOP)}<a href="game.php?page=shop" class="shop_btn">🛍️ Tienda NTX-20</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_BATTLEPASS)}<a href="game.php?page=battlepass" class="battlepass_btn">🏆 Pase de Batalla</a>{/if}
                {if isModuleAvailable($smarty.const.MODULE_REFERRAL)}<a href="game.php?page=referral" class="referral_btn">🔗 Referidos</a>{/if}
                {if $authlevel >= 2}
                        <a href="game.php?page=walletadmin" class="adminwallet_btn" id="adminwallet_btn_link">
                                💼 Admin Wallet
                                <span class="adminwallet_badge_icon" id="adminwallet_badge">⚠️</span>
                        </a>
                {/if}
                {if $authlevel > 0}<a href="./admin.php">{$LNG.lm_administration}</a>{/if}
        </div>

        {if $allyName && $allyMembersList}
        <div class="ally_section">
                <div class="ally_title">
                        🏰 [{$allyTag}] {$allyName}
                </div>
                {foreach $allyMembersList as $member}
                        <div class="ally_member {if $member.online}online{else}offline{/if}">
                                <span class="name">
                                        <span class="status_dot">{if $member.online}🟢{else}⚫{/if}</span>
                                        {$member.username}
                                </span>
                                <span class="time {if !$member.online}offline_time{/if}">{$member.lastSeen|default:'-'}</span>
                        </div>
                {/foreach}
        </div>
        {/if}

</div>

<script>
function astroio_switchTab(tab) {
        var tabNOM = document.getElementById('tabNOM');
        var tabMOP = document.getElementById('tabMOP');
        var btnNOM = document.getElementById('tabBtnNOM');
        var btnMOP = document.getElementById('tabBtnMOP');

        if (tab === 'nom') {
                tabNOM.classList.remove('hidden');
                tabMOP.classList.add('hidden');
                btnNOM.classList.add('active');
                btnMOP.classList.remove('active');
        } else {
                tabNOM.classList.add('hidden');
                tabMOP.classList.remove('hidden');
                btnNOM.classList.remove('active');
                btnMOP.classList.add('active');
        }
}

/* ═══════════════════════════════════════════════════════════
 * ASTROIO — Aviso visual: Admin sin datos bancarios
 * ═══════════════════════════════════════════════════════════ */
(function() {
        var badge = document.getElementById('adminwallet_badge');
        var link  = document.getElementById('adminwallet_btn_link');
        if (!badge || !link) return;

        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'game.php?page=walletadmin&mode=checkBankData', true);
        xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                                var data = JSON.parse(xhr.responseText);
                                if (data && data.has_data === false) {
                                        link.classList.add('sin_datos');
                                        badge.style.display = 'inline';
                                } else {
                                        link.classList.remove('sin_datos');
                                        badge.style.display = 'none';
                                }
                        } catch (e) {}
                }
        };
        xhr.send();
})();

/* ═══════════════════════════════════════════════════════════
 * ASTROIO v1.5 — Cuenta regresiva de Eventos PvE en el MOP
 * ═══════════════════════════════════════════════════════════ */
(function() {
        var link  = document.getElementById('pve_mop_link');
        var badge = document.getElementById('pve_mop_badge');
        if (!link || !badge) return;

        var crisisTime    = parseInt(link.getAttribute('data-crisis-time')    || '0', 10);
        var crisisActive  = parseInt(link.getAttribute('data-crisis-active')  || '0', 10);
        var empireTime    = parseInt(link.getAttribute('data-empire-time')    || '0', 10);
        var empireActive  = parseInt(link.getAttribute('data-empire-active')  || '0', 10);
        var bossTime      = parseInt(link.getAttribute('data-boss-time')      || '0', 10);
        var bossEndTime   = parseInt(link.getAttribute('data-boss-end-time')  || '0', 10);
        var bossActive    = parseInt(link.getAttribute('data-boss-active')    || '0', 10);
        var bossStatus    = (link.getAttribute('data-boss-status') || 'idle').trim();
        var anyActive     = parseInt(link.getAttribute('data-any-active')     || '0', 10);

        function formatCountdown(seconds) {
                if (seconds <= 0) return '0s';
                var d = Math.floor(seconds / 86400);
                var h = Math.floor((seconds % 86400) / 3600);
                var m = Math.floor((seconds % 3600) / 60);
                var s = seconds % 60;
                if (d > 0)  return d + 'd ' + h + 'h';
                if (h > 0)  return h + 'h ' + m + 'm';
                if (m > 0)  return m + 'm ' + s + 's';
                return s + 's';
        }

        function setBadge(text, stateClass) {
                badge.textContent = text;
                badge.className = 'pve_countdown_badge ' + stateClass;
        }

        function updatePVEBadge() {
                var now = Math.floor(Date.now() / 1000);

                if (crisisActive === 1) { setBadge('🔴 ACTIVA', 'state-active'); return; }
                if (crisisTime > now) {
                        var diff = crisisTime - now;
                        if (diff < 86400) setBadge('⏰ ' + formatCountdown(diff), 'state-soon');
                        else setBadge(formatCountdown(diff), 'state-far');
                        return;
                }
                if (bossActive === 1) {
                        if (bossEndTime > now) {
                                var diffEnd = bossEndTime - now;
                                if (diffEnd < 86400) setBadge('🌌 ' + formatCountdown(diffEnd), 'state-boss-running');
                                else setBadge('🌌 ' + formatCountdown(diffEnd), 'state-boss');
                        } else setBadge('🌌 Finalizando', 'state-boss');
                        return;
                }
                if (bossStatus === 'registration') {
                        if (bossTime > now) setBadge('🌌 ' + formatCountdown(bossTime - now), 'state-boss-soon');
                        else setBadge('🌌 Registro', 'state-boss-soon');
                        return;
                }
                if (bossStatus === 'scheduled' && bossTime > now) {
                        var diffSch = bossTime - now;
                        if (diffSch < 86400) setBadge('🌌 ' + formatCountdown(diffSch), 'state-boss-soon');
                        else setBadge('🌌 ' + formatCountdown(diffSch), 'state-far');
                        return;
                }
                if (empireActive === 1) { setBadge('🏛️ ACTIVO', 'state-active'); return; }
                if (empireTime > now) { setBadge(formatCountdown(empireTime - now), 'state-far'); return; }
                setBadge('Sin activar', 'state-off');
        }

        setInterval(updatePVEBadge, 1000);
        updatePVEBadge();
})();

/* ═══════════════════════════════════════════════════════════
 * ASTROIO — Cuenta regresiva del Sistema PvP en el MOP
 * ═══════════════════════════════════════════════════════════ */
(function() {
        var link  = document.getElementById('pvp_mop_link');
        var badge = document.getElementById('pvp_mop_badge');
        if (!link || !badge) return;

        var arenaActive      = parseInt(link.getAttribute('data-arena-active')      || '0', 10);
        var arenaWaiting     = parseInt(link.getAttribute('data-arena-waiting')     || '0', 10);
        var tournamentActive = parseInt(link.getAttribute('data-tournament-active') || '0', 10);
        var tournamentStatus = (link.getAttribute('data-tournament-status') || '').trim();
        var tournamentTime   = parseInt(link.getAttribute('data-tournament-time')   || '0', 10);

        function formatCountdown(seconds) {
                if (seconds <= 0) return '0s';
                var d = Math.floor(seconds / 86400);
                var h = Math.floor((seconds % 86400) / 3600);
                var m = Math.floor((seconds % 3600) / 60);
                var s = seconds % 60;
                if (d > 0)  return d + 'd ' + h + 'h';
                if (h > 0)  return h + 'h ' + m + 'm';
                if (m > 0)  return m + 'm ' + s + 's';
                return s + 's';
        }

        function setBadge(text, stateClass) {
                badge.textContent = text;
                badge.className = 'pvp_countdown_badge ' + stateClass;
        }

        function updatePVPBadge() {
                var now = Math.floor(Date.now() / 1000);
                if (tournamentActive === 1 && tournamentStatus === 'running') {
                        setBadge('🏆 EN CURSO', 'state-active'); return;
                }
                if (tournamentActive === 1 && tournamentStatus === 'registration') {
                        if (tournamentTime > now) setBadge('🏆 ' + formatCountdown(tournamentTime - now), 'state-soon');
                        else setBadge('🏆 Inscripción', 'state-soon');
                        return;
                }
                if (arenaActive > 0) { setBadge('⚔️ ' + arenaActive + ' activas', 'state-active'); return; }
                if (arenaWaiting > 0) { setBadge('🏟️ ' + arenaWaiting + ' abiertas', 'state-far'); return; }
                setBadge('Sin actividad', 'state-off');
        }

        setInterval(updatePVPBadge, 1000);
        updatePVPBadge();
})();

/* ═══════════════════════════════════════════════════════════
 * ASTROIO — RADAR GLOBAL LA CUEVA PIRATA
 * Redirige al jugador al tablero si tiene una partida activa
 * ═══════════════════════════════════════════════════════════ */
(function() {
    // Solo preguntar si NO estamos ya en la página de la partida
    if (window.location.href.indexOf('page=cuevaPartida') === -1) {
        setInterval(function() {
            $.post('game.php?page=cuevaAjax', { accion: 'check_estado_global' }, function(res) {
                if (res.status === 'jugando' && res.sala_id) {
                    // Redirigir automáticamente al tablero
                    window.location.href = 'game.php?page=cuevaPartida&sala=' + res.sala_id;
                }
            });
        }, 5000); // Consulta cada 5 segundos
    }
})();
/* ═══════════════════════════════════════════════════════════ */
</script>