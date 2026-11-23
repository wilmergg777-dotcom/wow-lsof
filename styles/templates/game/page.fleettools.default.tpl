{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.fleettools.default.tpl === *}
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
.astroft_container {
    max-width: 900px; /* Reducimos el ancho máximo para que no se estire */
    margin: 0 auto;
    padding: 0 10px;
    box-sizing: border-box;
}
.astroft_container * {
    box-sizing: border-box; /* Crucial para que los inputs no desborden */
}
.astroft_title {
    padding: 4px 14px;
    font-size: 12px;
    margin-bottom: 8px;
}
.astroft_tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 14px;
    flex-wrap: wrap;
}
.astroft_tab {
    flex: 1;
    min-width: 140px;
    padding: 8px 10px;
    background: rgba(15, 23, 42, 0.5);
    border: 1px solid rgba(255, 255, 255, 0.05);
    border-radius: 8px;
    color: #94a3b8;
    text-align: center;
    text-decoration: none;
    font-size: 10px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    transition: 0.2s ease;
}
.astroft_tab:hover {
    background: rgba(0, 204, 255, 0.1);
    border-color: rgba(0, 204, 255, 0.3);
    color: #00e0ff;
}
.astroft_tab.active {
    background: #00ccff;
    color: #0f1624;
    border-color: #00ccff;
    font-weight: 800;
}
.astroft_panel {
    background: rgba(15, 23, 42, 0.85);
    border: 1px solid rgba(255, 255, 255, 0.05);
    border-radius: 10px;
    padding: 12px;
    margin-bottom: 10px;
    color: #cbd5e1;
    font-size: 12px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(8px);
}
.astroft_panel h3 {
    color: #ffffff;
    margin: 0 0 10px 0;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    padding-bottom: 8px;
}
.astroft_panel p {
    margin: 6px 0;
}
.astroft_btn {
    display: inline-block;
    padding: 8px 20px;
    background: transparent;
    border: 1px solid rgba(0, 204, 255, 0.4);
    border-radius: 6px;
    color: #00ccff;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    text-decoration: none;
    cursor: pointer;
    transition: 0.2s ease;
    letter-spacing: 0.5px;
    font-family: inherit;
}
.astroft_btn:hover {
    background: rgba(0, 204, 255, 0.1);
    border-color: #00ccff;
    color: #ffffff;
    box-shadow: 0 0 10px rgba(0, 204, 255, 0.3);
}
.astroft_btn.gold {
    border-color: rgba(255, 170, 51, 0.4);
    color: #ffaa33;
}
.astroft_btn.gold:hover {
    background: rgba(255, 170, 51, 0.1);
    border-color: #ffaa33;
    color: #ffffff;
    box-shadow: 0 0 10px rgba(255, 170, 51, 0.3);
}
.astroft_btn.red {
    border-color: rgba(255, 68, 136, 0.4);
    color: #ff4488;
}
.astroft_btn.red:hover {
    background: rgba(255, 68, 136, 0.1);
    border-color: #ff4488;
    color: #ffffff;
    box-shadow: 0 0 10px rgba(255, 68, 136, 0.3);
}
.astroft_empty {
    color: #ff4488;
    font-size: 11px;
    text-align: center;
    padding: 20px;
    font-weight: bold;
}
.astroft_planet_row {
    background: rgba(0,204,255,0.05);
    border: 1px solid #00ccff33;
    border-radius: 6px;
    padding: 10px 14px;
    margin-bottom: 6px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
    cursor: pointer;
}
.astroft_planet_row:hover {
    background: rgba(0,204,255,0.1);
    border-color: #00ccff;
}
.astroft_planet_name {
    color: #00e0ff;
    font-weight: bold;
}
.astroft_res {
    font-size: 10px;
    color: #c8d6e5;
}
.astroft_res span {
    margin-right: 10px;
}
.astroft_label {
    display: inline-block;
    margin-right: 15px;
    cursor: pointer;
    padding: 4px 0;
}
.astroft_input {
    background: #0a0f18;
    border: 1px solid #00ccff33;
    border-radius: 4px;
    color: #c8d6e5;
    padding: 6px 10px;
    font-size: 11px;
}
.astroft_destino_badge {
    display: block;
    padding: 8px 12px;
    background: rgba(0, 204, 255, 0.05);
    border-left: 3px solid #00ccff;
    border-radius: 4px;
    color: #00ccff;
    font-weight: 600;
    font-size: 12px;
    margin: 8px 0 12px 0;
    letter-spacing: 0.5px;
}

/* ====== Tabla estilo "Nueva Misión" ====== */
.astroft_fleet_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    margin-top: 10px;
	
}
.astroft_fleet_table thead tr {
    background: transparent;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
.astroft_fleet_table thead th {
    color: #94a3b8;
    font-weight: 500;
    font-size: 10px;
    text-align: center;
    padding: 6px 8px;
    text-transform: uppercase;
    white-space: nowrap; /* Evita que los títulos se bajen de línea */
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
.astroft_fleet_table tbody tr {
    border-bottom: 1px solid rgba(255, 255, 255, 0.03);
    transition: 0.15s ease;
}
.astroft_fleet_table tbody tr:hover {
    background: rgba(255, 255, 255, 0.02);
}
.astroft_fleet_table tbody tr.astroft_insuf {
    background: rgba(255,68,136,0.08);
}
.astroft_fleet_table tbody tr.astroft_insuf:hover {
    background: rgba(255,68,136,0.15);
}
.astroft_fleet_table tbody tr.astroft_destino {
    background: rgba(102,255,153,0.08);
    border-left: 3px solid #66ff99;
}
.astroft_fleet_table tbody td {
    padding: 8px;
    text-align: center;
    color: #cbd5e1;
    vertical-align: middle;
    white-space: nowrap; /* Evita que los números se amontonen */
    border-bottom: 1px solid rgba(255, 255, 255, 0.03);
}
/* Contenedor para hacer las tablas scrolleables en móvil sin romper la página */
.astroft_table_wrapper {
    width: 100%;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
}
.astroft_fleet_table tbody td.astroft_col_left {
    text-align: left;
}
.astroft_fleet_table tbody td.astroft_col_name {
    color: #00e0ff;
    font-weight: bold;
}
.astroft_fleet_table tbody td.astroft_col_coords {
    color: #c8d6e5;
    font-family: 'Courier New', monospace;
    font-size: 10.5px;
}
.astroft_fleet_table tbody td.astroft_col_naves {
    color: #00e0ff;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astroft_fleet_table tbody td.astroft_col_deut {
    color: #66ff99;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astroft_fleet_table tbody td.astroft_col_deut.astroft_insuf {
    color: #ff4488;
    text-shadow: 0 0 6px rgba(255,68,136,0.5);
}
.astroft_fleet_table tbody td.astroft_col_cons {
    color: #ffaa33;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astroft_fleet_table tbody td.astroft_col_cons.astroft_insuf {
    color: #ff4488;
    text-shadow: 0 0 6px rgba(255,68,136,0.5);
}
.astroft_fleet_table tbody td.astroft_col_time {
    color: #66ff99;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 5px rgba(102,255,153,0.3);
}
.astroft_fleet_table tbody td.astroft_col_metal {
    color: #ffcc66;
    font-family: 'Courier New', monospace;
    font-weight: bold;
}
.astroft_fleet_table tbody td.astroft_col_crystal {
    color: #66ccff;
    font-family: 'Courier New', monospace;
    font-weight: bold;
}
.astroft_fleet_table tbody td.astroft_col_recibe {
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: bold;
    font-size: 10px;
    line-height: 1.4;
}
.astroft_fleet_table input[type="checkbox"] {
    transform: scale(1.15);
    cursor: pointer;
}
.astroft_tooltip_link {
    color: #00e0ff;
    text-decoration: none;
    font-weight: bold;
    cursor: help;
    border-bottom: 1px dotted #00e0ff;
    padding-bottom: 1px;
}
.astroft_tooltip_link:hover {
    color: #ffffff;
    text-shadow: 0 0 6px rgba(0,224,255,0.8);
}
.astroft_warn_icon {
    color: #ff4488;
    font-weight: bold;
    margin-left: 4px;
}
.astroft_totales {
    background: rgba(0,204,255,0.05);
    border: 1px solid rgba(0,204,255,0.25);
    border-radius: 6px;
    padding: 8px 14px;
    margin-top: 10px;
    text-align: center;
    color: #c8d6e5;
    font-size: 11px;
}
.astroft_totales b {
    color: #00e0ff;
    font-family: 'Courier New', monospace;
}
.astroft_totales .astroft_tot_deut {
    color: #ffaa33;
    font-family: 'Courier New', monospace;
}
.astroft_totales .astroft_tot_metal {
    color: #ffcc66;
    font-family: 'Courier New', monospace;
}
.astroft_totales .astroft_tot_crystal {
    color: #66ccff;
    font-family: 'Courier New', monospace;
}
.astroft_submit_row {
    text-align: center;
    padding-top: 12px;
    margin-top: 12px;
    border-top: 1px solid rgba(0,204,255,0.15);
}
.astroft_destino_label {
    color: #66ff99;
    font-weight: bold;
    font-size: 11px;
}
.astroft_dist_info {
    background: rgba(0,204,255,0.08);
    border: 1px solid rgba(0,204,255,0.25);
    border-radius: 6px;
    padding: 10px 14px;
    margin-bottom: 12px;
    color: #c8d6e5;
    font-size: 11px;
    line-height: 1.7;
}
.astroft_dist_info strong {
    color: #00e0ff;
}
.astroft_recursos_inputs {
    background: rgba(0,0,0,0.25);
    border: 1px solid rgba(0,204,255,0.15);
    border-radius: 6px;
    padding: 10px 14px;
    margin: 10px 0;
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
    align-items: center;
}
.astroft_recursos_inputs label {
    color: #00e0ff;
    font-weight: bold;
    margin-right: 6px;
}
.astroft_recursos_inputs input {
    background: #0a0f18;
    border: 1px solid #00ccff33;
    border-radius: 4px;
    color: #ffffff;
    padding: 6px 10px;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    font-weight: bold;
    width: 130px;
    outline: none;
    transition: 0.2s ease;
}
.astroft_recursos_inputs input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 8px rgba(0,204,255,0.5);
}
/* Ajustamos las columnas para que no empujen el ancho 
.astroft_fleet_table th:nth-child(1) { width: 40%; text-align: left; padding-left: 10px; }
.astroft_fleet_table th:nth-child(2) { width: 20%; }
.astroft_fleet_table th:nth-child(3) { width: 20%; }
.astroft_fleet_table th:nth-child(4) { width: 20%; } */
/* ====== Multi-Expediciones ====== */
.astroft_exped_info {
    background: transparent;
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 8px;
    padding: 12px 16px;
    margin-bottom: 16px;
    color: #94a3b8;
    font-size: 12px;
    line-height: 1.6;
}
.astroft_exped_info strong {
    color: #ffffff;
}
.astroft_exped_info .astroft_exped_alert {
    color: #ff4488;
    font-weight: bold;
}
.astroft_exped_options {
    background: rgba(0, 0, 0, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.03);
    border-radius: 8px;
    padding: 10px 12px;
    margin: 10px 0;
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    align-items: center;
}
.astroft_exped_options label {
    color: #94a3b8;
    font-weight: 500;
    margin-right: 4px;
    font-size: 10px;
}
.astroft_exped_options input[type="number"] {
    background: #0a0f18;
    border: 1px solid #00ccff33;
    border-radius: 4px;
    color: #ffffff;
    padding: 6px 10px;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    font-weight: bold;
    width: 90px;
    outline: none;
    transition: 0.2s ease;
}
.astroft_exped_options input[type="number"]:focus {
    border-color: #00ccff;
    box-shadow: 0 0 8px rgba(0,204,255,0.5);
}
.astroft_select, .astroft_ship_input {
    background: #0b101e;
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 6px;
    color: #ffffff;
    padding: 5px 8px;
    font-size: 10px;
    font-family: 'Courier New', monospace;
    font-weight: 600;
    outline: none;
    transition: 0.2s ease;
    height: 28px;
    width: 60px; /* Quitamos el !important para que se adapte */
    text-align: center;
    -moz-appearance: textfield;
    appearance: textfield;
}
/* Ocultar flechitas en Chrome, Safari, Edge y Opera */
.astroft_ship_input::-webkit-outer-spin-button,
.astroft_ship_input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}
.astroft_select:focus, .astroft_ship_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 0 2px rgba(0, 204, 255, 0.2);
}
.astroft_max_btn {
    display: inline-block;
    padding: 4px 10px;
    background: transparent;
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 4px;
    color: #cbd5e1;
    font-weight: 600;
    font-size: 10px;
    cursor: pointer;
    text-transform: uppercase;
    transition: 0.2s ease;
    font-family: inherit;
}
.astroft_max_btn:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #ffffff;
    border-color: #ffffff;
}
.astroft_link_btn {
    display: inline-block;
    padding: 6px 16px;
    background: transparent;
    border: 1px solid rgba(102, 255, 153, 0.3);
    border-radius: 4px;
    color: #66ff99;
    font-weight: 600;
    font-size: 11px;
    cursor: pointer;
    transition: 0.2s ease;
    font-family: inherit;
}
.astroft_link_btn:hover {
    background: rgba(102, 255, 153, 0.1);
}
.astroft_link_btn.red {
    border-color: rgba(255, 68, 136, 0.3);
    color: #ff4488;
}
.astroft_link_btn.red:hover {
    background: rgba(255, 68, 136, 0.1);
}
.astroft_ship_disponible {
    color: #66ff99;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astroft_exped_totales {
    background: #0b101e;
    border-radius: 8px;
    padding: 10px 14px;
    margin-top: 10px;
    color: #94a3b8;
    font-size: 11px;
    line-height: 1.6;
}
.astroft_exped_totales strong, .astroft_exped_totales span {
    color: #ffffff;
    float: right;
}
/* Hacemos que el texto y el valor se alineen perfectamente */
.astroft_exped_totales div {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    padding: 2px 0;
}
.astroft_exped_totales div:last-child {
    border-bottom: none;
}
.astroft_exped_totales .astroft_tot_deut {
    color: #ffaa33;
    font-family: 'Courier New', monospace;
    font-weight: bold;
}
.astroft_exped_totales .astroft_tot_time {
    color: #66ff99;
    font-family: 'Courier New', monospace;
    font-weight: bold;
}

/* ====== VIP REQUERIDO ====== */
.astroft_vip_required {
    text-align: center;
    padding: 40px 20px;
    background: linear-gradient(180deg, #1a0f24, #2a1a33);
    border: 1px solid rgba(255,68,136,0.3);
    border-radius: 8px;
}
.astroft_vip_required .astroft_vip_title {
    font-size: 16px;
    font-weight: bold;
    color: #ff4488;
    text-shadow: 0 0 14px rgba(255,68,136,0.6);
    margin-bottom: 14px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
}
.astroft_vip_required .astroft_vip_desc {
    font-size: 11.5px;
    color: #c8d6e5;
    margin-bottom: 8px;
    line-height: 1.7;
}
.astroft_vip_required .astroft_vip_desc strong {
    color: #ffcc66;
}
.astroft_vip_required .astroft_vip_btn_wrap {
    margin-top: 20px;
}
.astroft_vip_btn {
    display: inline-block;
    padding: 12px 32px;
    background: linear-gradient(180deg, #ff4488, #ff88aa);
    border: 1px solid #ff88aa;
    border-radius: 6px;
    color: #fff;
    font-weight: bold;
    font-size: 12px;
    text-transform: uppercase;
    text-decoration: none;
    letter-spacing: 0.5px;
    transition: 0.2s ease;
    text-shadow: 0 1px 2px rgba(0,0,0,0.4);
    box-shadow: 0 4px 14px rgba(255,68,136,0.4);
}
.astroft_vip_btn:hover {
    box-shadow: 0 0 20px rgba(255,68,136,0.8);
    transform: translateY(-1px);
}
@media (max-width: 720px) {
    /* Botones más pequeños en móvil */
    .astroft_max_btn {
        padding: 4px 8px !important;
        font-size: 9px !important;
    }
    .astroft_link_btn {
        padding: 4px 8px !important;
        font-size: 9px !important;
        width: auto !important;
    }
    /* Ajustar celdas en móvil */
    .astroft_fleet_table thead th,
    .astroft_fleet_table tbody td {
        padding: 6px 4px !important;
        font-size: 10px !important;
    }
}
</style>

<div class="astroft_container">

    <div class="astroft_title">🛠️ HERRAMIENTAS DE FLOTA</div>

    <div class="astroft_tabs">
        <a href="game.php?page=fleettools&tab=dashboard" class="astroft_tab {if $tab_active=='dashboard'}active{/if}">📊 Dashboard</a>
        <a href="game.php?page=fleettools&tab=reunir-flotas" class="astroft_tab {if $tab_active=='reunir-flotas'}active{/if}">🚀 Reunir Flotas</a>
        <a href="game.php?page=fleettools&tab=reunir-recursos" class="astroft_tab {if $tab_active=='reunir-recursos'}active{/if}">📦 Reunir Recursos</a>
        <a href="game.php?page=fleettools&tab=distribuir" class="astroft_tab {if $tab_active=='distribuir'}active{/if}">🔄 Distribuir</a>
        <a href="game.php?page=fleettools&tab=multi-exped" class="astroft_tab {if $tab_active=='multi-exped'}active{/if}">🌌 Multi-Exped</a>
    </div>

    {* ============================================ *}
    {* TAB: DASHBOARD                                *}
    {* ============================================ *}
    {if $tab_active == 'dashboard'}
        <div class="astroft_panel">
            <h3>📊 Resumen</h3>
            <p>Planeta actual: <strong>{$planeta_actual.name}</strong> [{$planeta_actual.galaxy}:{$planeta_actual.system}:{$planeta_actual.planet}]</p>
            <p>Slots de expedición libres: <strong>{$slots_libres}</strong></p>
            <p>Planetas tuyos: <strong>{$todos_planetas|count}</strong></p>
            <p>Coordenadas favoritas: <strong>{$favoritos|count}</strong></p>
        </div>

        {if $todos_planetas}
        <div class="astroft_panel">
            <h3>💎 Recursos de tus planetas</h3>
            {foreach $todos_planetas as $p}
                <div class="astroft_planet_row">
                    <span>
                        <span class="astroft_planet_name">{$p.name}</span>
                        [{$p.galaxy}:{$p.system}:{$p.planet}]
                    </span>
                    <span class="astroft_res">
                        <span>🔩 {$p.metal|number_format:0:',':'.'}</span>
                        <span>💎 {$p.crystal|number_format:0:',':'.'}</span>
                        <span>⚗️ {$p.deuterium|number_format:0:',':'.'}</span>
                    </span>
                </div>
            {/foreach}
        </div>
        {/if}   
		 
    {/if}

    {* ============================================ *}
    {* TAB: REUNIR FLOTAS                            *}
    {* ============================================ *}
    {if $tab_active == 'reunir-flotas'}
        <div class="astroft_panel">
            <h3>🚀 Reunir Flotas</h3>
            <p>Todas las flotas de los planetas seleccionados se enviarán al planeta donde estás ubicado.</p>

            <div class="astroft_destino_badge">
                📍 DESTINO: {$planeta_actual.name} [{$planeta_actual.galaxy}:{$planeta_actual.system}:{$planeta_actual.planet}]
            </div>

            <form method="post" action="game.php?page=fleettools&mode=reunirFlotas">
                <label>Velocidad:</label>
                <select name="velocidad" class="astroft_select" onchange="astroftCambiarVelocidad(this.value)">
                    <option value="10" {if $velocidad_actual==10}selected{/if}>100%</option>
                    <option value="9"  {if $velocidad_actual==9}selected{/if}>90%</option>
                    <option value="8"  {if $velocidad_actual==8}selected{/if}>80%</option>
                    <option value="7"  {if $velocidad_actual==7}selected{/if}>70%</option>
                    <option value="6"  {if $velocidad_actual==6}selected{/if}>60%</option>
                    <option value="5"  {if $velocidad_actual==5}selected{/if}>50%</option>
                    <option value="4"  {if $velocidad_actual==4}selected{/if}>40%</option>
                    <option value="3"  {if $velocidad_actual==3}selected{/if}>30%</option>
                    <option value="2"  {if $velocidad_actual==2}selected{/if}>20%</option>
                    <option value="1"  {if $velocidad_actual==1}selected{/if}>10%</option>
                </select>
                <br><br>

                <button type="button" class="astroft_btn" onclick="astroftMarcarTodo('flotas', true)">Marcar Todo</button>
                <button type="button" class="astroft_btn red" onclick="astroftMarcarTodo('flotas', false)">Desmarcar Todo</button>
                <br><br>

                {if $planetas_naves}
					<div class="astroft_table_wrapper">
						<table class="astroft_fleet_table">
							<thead>
								<tr>
									<th style="width:40px;">&nbsp;</th>
									<th>Planeta</th>
									<th>Coords</th>
									<th>Naves</th>
									<th>⚗️ Deuterio</th>
									<th>⚗️ Consumo</th>
									<th>Tiempo</th>
								</tr>
							</thead>
							<tbody>
								{foreach $planetas_naves as $p}
									<tr class="{if !$p.tiene_suficiente}astroft_insuf{/if}">
										<td>
											<input type="checkbox" name="planetas[]" value="{$p.id}" class="astroft_chk_flotas">
										</td>
										<td class="astroft_col_left astroft_col_name">{$p.name}</td>
										<td class="astroft_col_coords">[{$p.galaxy}:{$p.system}:{$p.planet}]</td>
										<td class="astroft_col_naves">
											<a class="astroft_tooltip_link tooltip_sticky" data-tooltip-content="<table width='100%'><tr><th colspan='2' style='text-align:center;'>Naves en {$p.name}</th></tr>{foreach $p.naves_por_id as $shipId => $qty}<tr><td class='transparent'>{$LNG.tech.{$shipId}}:</td><td class='transparent'>{$qty}</td></tr>{/foreach}<tr><td class='transparent'><b>TOTAL:</b></td><td class='transparent'><b>{$p.total_naves}</b></td></tr></table>">{$p.total_naves} ⓘ</a>
										</td>
										<td class="astroft_col_deut {if !$p.tiene_suficiente}astroft_insuf{/if}">
											⚗️{$p.deuterio|number_format:0:',':'.'}
											{if !$p.tiene_suficiente}
												<span class="astroft_warn_icon" title="Falta {$p.falta|number_format:0:',':'.'} deuterio">⚠️</span>
											{/if}
										</td>
										<td class="astroft_col_cons {if !$p.tiene_suficiente}astroft_insuf{/if}">
											⚗️{$p.consumo|number_format:0:',':'.'}
										</td>
										<td class="astroft_col_time">⏱️ {$p.tiempo_str}</td>
									</tr>
								{/foreach}
							</tbody>
						</table>
					</div>
                    <div class="astroft_totales">
                        Total: <b>{$total_planetas_naves}</b> planetas ·
                        <b>{$total_naves_global}</b> naves ·
                        Consumo total: <span class="astroft_tot_deut">⚗️ {$total_consumo_global|number_format:0:',':'.'}</span>
                    </div>
                {else}
                    <div class="astroft_empty">No hay planetas con naves disponibles</div>
                {/if}

                <div class="astroft_submit_row">
                    <button type="submit" class="astroft_btn">🚀 Reunir Todas las Flotas</button>
                </div>
            </form>
        </div>
    {/if}

    {* ============================================ *}
    {* TAB: REUNIR RECURSOS                          *}
    {* ============================================ *}
    {if $tab_active == 'reunir-recursos'}
        <div class="astroft_panel">
            <h3>📦 Reunir Recursos</h3>
            <p>Todos los recursos de los planetas seleccionados se enviarán al planeta donde estás ubicado.</p>

            <div class="astroft_destino_badge">
                📍 DESTINO: {$planeta_actual.name} [{$planeta_actual.galaxy}:{$planeta_actual.system}:{$planeta_actual.planet}]
            </div>

            <form method="post" action="game.php?page=fleettools&mode=reunirRecursos">
                <label>Velocidad:</label>
                <select name="velocidad" class="astroft_select" onchange="astroftCambiarVelocidad(this.value)">
                    <option value="10" {if $velocidad_actual==10}selected{/if}>100%</option>
                    <option value="9"  {if $velocidad_actual==9}selected{/if}>90%</option>
                    <option value="8"  {if $velocidad_actual==8}selected{/if}>80%</option>
                    <option value="7"  {if $velocidad_actual==7}selected{/if}>70%</option>
                    <option value="6"  {if $velocidad_actual==6}selected{/if}>60%</option>
                    <option value="5"  {if $velocidad_actual==5}selected{/if}>50%</option>
                    <option value="4"  {if $velocidad_actual==4}selected{/if}>40%</option>
                    <option value="3"  {if $velocidad_actual==3}selected{/if}>30%</option>
                    <option value="2"  {if $velocidad_actual==2}selected{/if}>20%</option>
                    <option value="1"  {if $velocidad_actual==1}selected{/if}>10%</option>
                </select>
                <br><br>

                <button type="button" class="astroft_btn" onclick="astroftMarcarTodo('recursos', true)">Marcar Todo</button>
                <button type="button" class="astroft_btn red" onclick="astroftMarcarTodo('recursos', false)">Desmarcar Todo</button>
                <br><br>

                {if $planetas_recursos}
					<div class="astroft_table_wrapper">
						<table class="astroft_fleet_table">
							<thead>
								<tr>
									<th style="width:40px;">&nbsp;</th>
									<th>Planeta</th>
									<th>Coords</th>
									<th>🔩 Metal</th>
									<th>💎 Cristal</th>
									<th>⚗️ Deuterio</th>
									<th>🚚 Naves</th>
									<th>⏱️ Tiempo</th>
									<th>⚗️ Consumo</th>
								</tr>
							</thead>
							<tbody>
								{foreach $planetas_recursos as $p}
									{if $p.es_destino}
										<tr class="astroft_destino">
											<td>
												<span class="astroft_destino_label" title="Este es tu planeta actual (destino)">📍</span>
											</td>
											<td class="astroft_col_left astroft_col_name">{$p.name}</td>
											<td class="astroft_col_coords">[{$p.galaxy}:{$p.system}:{$p.planet}]</td>
											<td class="astroft_col_metal">🔩 {$p.metal|number_format:0:',':'.'}</td>
											<td class="astroft_col_crystal">💎 {$p.crystal|number_format:0:',':'.'}</td>
											<td class="astroft_col_deut">⚗️ {$p.deuterium|number_format:0:',':'.'}</td>
											<td class="astroft_col_naves">
												<a class="astroft_tooltip_link tooltip_sticky" data-tooltip-content="<table width='100%'><tr><th colspan='2' style='text-align:center;'>Naves de carga en {$p.name}</th></tr><tr><td class='transparent'>Nave pequeña de carga:</td><td class='transparent'>{$p.small_ship_cargo}</td></tr><tr><td class='transparent'>Nave grande de carga:</td><td class='transparent'>{$p.big_ship_cargo}</td></tr><tr><td class='transparent'>Transporte Espacial:</td><td class='transparent'>{$p.ev_transporter}</td></tr><tr><td class='transparent'><b>TOTAL:</b></td><td class='transparent'><b>{$p.total_naves_carga}</b></td></tr><tr><td class='transparent'>Capacidad:</td><td class='transparent'>{$p.capacidad_total|number_format:0:',':'.'}</td></tr></table>">{$p.total_naves_carga} ⓘ</a>
											</td>
											<td class="astroft_col_time">—</td>
											<td class="astroft_col_cons">—</td>
										</tr>
									{else}
										<tr class="{if !$p.tiene_suficiente}astroft_insuf{/if}">
											<td>
												<input type="checkbox" name="planetas[]" value="{$p.id}" class="astroft_chk_recursos" data-metal="{$p.carga_metal}" data-crystal="{$p.carga_crystal}" data-deut="{$p.carga_deuterium}" data-naves="{$p.total_naves_carga}" data-consumo="{$p.consumo}">
											</td>
											<td class="astroft_col_left astroft_col_name">{$p.name}</td>
											<td class="astroft_col_coords">[{$p.galaxy}:{$p.system}:{$p.planet}]</td>
											<td class="astroft_col_metal">🔩 {$p.metal|number_format:0:',':'.'}</td>
											<td class="astroft_col_crystal">💎 {$p.crystal|number_format:0:',':'.'}</td>
											<td class="astroft_col_deut {if !$p.tiene_suficiente}astroft_insuf{/if}">
												⚗️ {$p.deuterium|number_format:0:',':'.'}
												{if !$p.tiene_suficiente}
													<span class="astroft_warn_icon" title="Falta {$p.falta|number_format:0:',':'.'} deuterio">⚠️</span>
												{/if}
											</td>
											<td class="astroft_col_naves">
												<a class="astroft_tooltip_link tooltip_sticky" data-tooltip-content="<table width='100%'><tr><th colspan='2' style='text-align:center;'>Naves de carga en {$p.name}</th></tr><tr><td class='transparent'>Nave pequeña de carga:</td><td class='transparent'>{$p.small_ship_cargo}</td></tr><tr><td class='transparent'>Nave grande de carga:</td><td class='transparent'>{$p.big_ship_cargo}</td></tr><tr><td class='transparent'>Transporte Espacial:</td><td class='transparent'>{$p.ev_transporter}</td></tr><tr><td class='transparent'><b>TOTAL:</b></td><td class='transparent'><b>{$p.total_naves_carga}</b></td></tr><tr><td class='transparent'>Capacidad:</td><td class='transparent'>{$p.capacidad_total|number_format:0:',':'.'}</td></tr></table>">{$p.total_naves_carga} ⓘ</a>
											</td>
											<td class="astroft_col_time">⏱️ {$p.tiempo_str}</td>
											<td class="astroft_col_cons {if !$p.tiene_suficiente}astroft_insuf{/if}">
												⚗️{$p.consumo|number_format:0:',':'.'}
											</td>
										</tr>
									{/if}
								{/foreach}
							</tbody>
						</table>
					</div>
                    <div class="astroft_totales" id="astroft_totales_recursos">
                        Total: <b>{$total_planetas_rec}</b> planetas ·
                        🔩 <span class="astroft_tot_metal">{$total_rec_metal|number_format:0:',':'.'}</span> ·
                        💎 <span class="astroft_tot_crystal">{$total_rec_crystal|number_format:0:',':'.'}</span> ·
                        ⚗️ <span class="astroft_tot_deut">{$total_rec_deut|number_format:0:',':'.'}</span> ·
                        <b>{$total_rec_naves}</b> naves ·
                        Consumo: <span class="astroft_tot_deut">⚗️ {$total_rec_consumo|number_format:0:',':'.'}</span>
                    </div>
                {else}
                    <div class="astroft_empty">No hay planetas adecuados</div>
                {/if}

                <div class="astroft_submit_row">
                    <button type="submit" class="astroft_btn gold">📦 Reunir Todos los Recursos</button>
                </div>
            </form>
        </div>
    {/if}

    {* ============================================ *}
    {* TAB: DISTRIBUIR RECURSOS                      *}
    {* ============================================ *}
    {if $tab_active == 'distribuir'}
        <div class="astroft_panel">
            <h3>🔄 Distribuir Recursos</h3>
            <p>Distribuye recursos desde este planeta hacia los planetas seleccionados.</p>

            {if $distribuir_info.origen && $distribuir_info.destinos}
                <div class="astroft_destino_badge">
                    📍 ORIGEN: {$planeta_actual.name} [{$planeta_actual.galaxy}:{$planeta_actual.system}:{$planeta_actual.planet}]
                </div>

                <div class="astroft_dist_info">
                    <p><strong>💰 Recursos disponibles:</strong></p>
                    <p>
                        🔩 Metal: <strong>{$distribuir_info.origen.metal|number_format:0:',':'.'}</strong> ·
                        💎 Cristal: <strong>{$distribuir_info.origen.crystal|number_format:0:',':'.'}</strong> ·
                        ⚗️ Deuterio: <strong>{$distribuir_info.origen.deuterium|number_format:0:',':'.'}</strong>
                    </p>
                    <p><strong>🚚 Naves de carga disponibles:</strong></p>
                    <p>
                        🚚 Nave pequeña: <strong>{$distribuir_info.origen.small_ship_cargo}</strong> ·
                        🚛 Nave grande: <strong>{$distribuir_info.origen.big_ship_cargo}</strong> ·
                        📦 Transporte: <strong>{$distribuir_info.origen.ev_transporter}</strong>
                    </p>
                    <p>📦 Capacidad total de carga: <strong>{$distribuir_info.origen.capacidad_total|number_format:0:',':'.'}</strong></p>
                </div>

                <form method="post" action="game.php?page=fleettools&mode=distribuirRecursos">
                    <label>Velocidad:</label>
                    <select name="velocidad" class="astroft_select" onchange="astroftCambiarVelocidad(this.value)">
                        <option value="10" {if $velocidad_actual==10}selected{/if}>100%</option>
                        <option value="9"  {if $velocidad_actual==9}selected{/if}>90%</option>
                        <option value="8"  {if $velocidad_actual==8}selected{/if}>80%</option>
                        <option value="7"  {if $velocidad_actual==7}selected{/if}>70%</option>
                        <option value="6"  {if $velocidad_actual==6}selected{/if}>60%</option>
                        <option value="5"  {if $velocidad_actual==5}selected{/if}>50%</option>
                        <option value="4"  {if $velocidad_actual==4}selected{/if}>40%</option>
                        <option value="3"  {if $velocidad_actual==3}selected{/if}>30%</option>
                        <option value="2"  {if $velocidad_actual==2}selected{/if}>20%</option>
                        <option value="1"  {if $velocidad_actual==1}selected{/if}>10%</option>
                    </select>

                    <label style="margin-left:20px;">Misión:</label>
                    <select name="mision" class="astroft_select">
                        <option value="3">Transportar (ida y vuelta)</option>
                        <option value="4">Desplegar (solo ida)</option>
                    </select>
                    <br><br>

                    <div class="astroft_recursos_inputs" style="flex-wrap: wrap; justify-content: center; gap: 15px;">
                        <div>
                            <label>🔩 Metal:</label>
                            <input type="number" name="metal" id="astroft_metal" value="0" min="0" oninput="astroftActualizarRecibe()">
                        </div>
                        <div>
                            <label>💎 Cristal:</label>
                            <input type="number" name="crystal" id="astroft_crystal" value="0" min="0" oninput="astroftActualizarRecibe()">
                        </div>
                        <div>
                            <label>⚗️ Deuterio:</label>
                            <input type="number" name="deuterium" id="astroft_deuterium" value="0" min="0" oninput="astroftActualizarRecibe()">
                        </div>
                        <div style="width: 100%; text-align: center; margin-top: 10px;">
                            <button type="button" class="astroft_btn" onclick="astroftCapacidadCarga()">Capacidad de carga</button>
                        </div>
                    </div>

                    <button type="button" class="astroft_btn" onclick="astroftMarcarTodo('dist', true)">Marcar Todo</button>
                    <button type="button" class="astroft_btn red" onclick="astroftMarcarTodo('dist', false)">Desmarcar Todo</button>
                    <br><br>

					<div class="astroft_table_wrapper">
						<table class="astroft_fleet_table">
							<thead>
								<tr>
									<th style="width:40px;">&nbsp;</th>
									<th>Planeta</th>
									<th>Coords</th>
									<th>📦 Recibe</th>
									<th>⏱️ Tiempo</th>
									<th>⚗️ Consumo</th>
								</tr>
							</thead>
							<tbody>
								{foreach $distribuir_info.destinos as $d}
									<tr>
										<td>
											<input type="checkbox" name="planetas[]" value="{$d.id}" class="astroft_chk_dist" data-tiempo="{$d.tiempo}" data-consumo="{$d.consumo}" data-distancia="{$d.distancia|default:0}">
										</td>
										<td class="astroft_col_left astroft_col_name">{$d.name}</td>
										<td class="astroft_col_coords">[{$d.galaxy}:{$d.system}:{$d.planet}]</td>
										<td class="astroft_col_recibe">—</td>
										<td class="astroft_col_time">⏱️ {$d.tiempo_str}</td>
										<td class="astroft_col_cons">⚗️{$d.consumo|number_format:0:',':'.'}</td>
									</tr>
								{/foreach}
							</tbody>
						</table>
					</div>
                    <div class="astroft_totales" id="astroft_totales_dist">
                        Total: <b>0</b> planetas · 🔩 <span class="astroft_tot_metal">0</span> · 💎 <span class="astroft_tot_crystal">0</span> · ⚗️ <span class="astroft_tot_deut">0</span> · Consumo: <span class="astroft_tot_deut">⚗️ 0</span>
                    </div>

                    <div class="astroft_submit_row">
                        <button type="submit" class="astroft_btn">🔄 Distribuir Recursos</button>
                    </div>
                </form>
            {else}
                <div class="astroft_empty">No tienes naves de carga suficientes o no tienes otros planetas</div>
            {/if}
        </div>
    {/if}

    {* ============================================ *}
    {* TAB: MULTI-EXPEDICIONES                       *}
    {* ============================================ *}
    {if $tab_active == 'multi-exped'}
        <div class="astroft_panel">
            <h3>🌌 Multi-Expediciones</h3>

            {if !$vip_activo}
                {* ════════ BLOQUE VIP REQUERIDO ════════ *}
                <div class="astroft_vip_required">
                    <div class="astroft_vip_title">🌟 MÓDULO EXCLUSIVO VIP 🌟</div>
                    <p class="astroft_vip_desc">
                        Para usar <strong>Multi-Expediciones</strong> necesitas tener una <strong>suscripción VIP activa</strong>.
                    </p>
                    <p class="astroft_vip_desc">
                        Con VIP puedes enviar <strong>múltiples expediciones a la vez</strong> con un solo clic,<br>
                        ahorrando tiempo y maximizando tus ganancias.
                    </p>
                    <div class="astroft_vip_btn_wrap">
                        <a href="game.php?page=vip" class="astroft_vip_btn">💎 Ver Packs VIP</a>
                    </div>
                </div>
            {else}
                {* ════════ INTERFAZ NORMAL ════════ *}
                <p>Envía múltiples misiones de expedición con un solo clic. Las naves se reparten automáticamente entre las expediciones.</p>

                <div class="astroft_destino_badge">
                    📍 ORIGEN: {$planeta_actual.name} [{$planeta_actual.galaxy}:{$planeta_actual.system}:{$planeta_actual.planet}]
                </div>

                {if $multi_exped_info.slots_libres > 0}

                    <div class="astroft_exped_info">
                        <p><strong>🛰️ Slots de expedición:</strong></p>
                        <p>
                            Disponibles: <strong>{$multi_exped_info.slots_libres}</strong> /
                            Máximo: <strong>{$multi_exped_info.slots_max}</strong>
                            · Tecnología de expedición: <strong>Nivel {$multi_exped_info.expedition_tech}</strong>
                        </p>
                    </div>

                    <form method="post" action="game.php?page=fleettools&mode=multiExpediciones" id="astroft_exped_form">
                        <div class="astroft_exped_options">
                            <div>
                                <label>⚡ Velocidad:</label>
                                <select name="velocidad" class="astroft_select" onchange="astroftCambiarVelocidad(this.value)">
                                    <option value="10" {if $velocidad_actual==10}selected{/if}>100%</option>
                                    <option value="9"  {if $velocidad_actual==9}selected{/if}>90%</option>
                                    <option value="8"  {if $velocidad_actual==8}selected{/if}>80%</option>
                                    <option value="7"  {if $velocidad_actual==7}selected{/if}>70%</option>
                                    <option value="6"  {if $velocidad_actual==6}selected{/if}>60%</option>
                                    <option value="5"  {if $velocidad_actual==5}selected{/if}>50%</option>
                                    <option value="4"  {if $velocidad_actual==4}selected{/if}>40%</option>
                                    <option value="3"  {if $velocidad_actual==3}selected{/if}>30%</option>
                                    <option value="2"  {if $velocidad_actual==2}selected{/if}>20%</option>
                                    <option value="1"  {if $velocidad_actual==1}selected{/if}>10%</option>
                                </select>
                            </div>
                            <div>
								<label>🔢 Cantidad de expediciones:</label>
								<select name="cantidad" id="astroft_exped_cantidad" class="astroft_select" onchange="astroftRecalcularExped()" style="width: 80px; text-align: center;">
									{for $i=1 to $multi_exped_info.slots_libres}
										<option value="{$i}" {if $i == $multi_exped_info.slots_libres}selected{/if}>{$i}</option>
									{/for}
								</select>
								<span style="color:#66ff99; font-size:7.5px; font-weight:bold; margin-left:6px;">(máx: {$multi_exped_info.slots_libres})</span>
							</div>
                            <div>
								<label>⏰ Tiempo de estacionamiento:</label>
								{html_options name=estacionamiento options=$multi_exped_info.stay_selector selected=$multi_exped_info.stay_selected class="astroft_select"}
								<span style="color:#8899aa; font-size:10.5px; margin-left:6px;">{$LNG.fl_hours}</span>
							</div>
                        </div>

                        <h3 style="color:#00ccff; margin-top:16px;">🚀 NAVES TOTALES A REPARTIR ENTRE EXPEDICIONES</h3>
						
						<div class="astroft_table_wrapper">
                        <table class="astroft_fleet_table">
                            <thead>
                                <tr>
                                    <th style="text-align:left;">Tipo de nave</th>
                                    <th>Disponibles</th>
                                    <th>-</th>
                                    <th>-</th>
                                </tr>
                            </thead>
                            <tbody>
                                {* ===== NAVES DE CARGA ===== *}
                                {if $multi_exped_info.naves_disponibles.small_ship_cargo|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Nave pequeña de carga</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.small_ship_cargo}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship202', {$multi_exped_info.naves_disponibles.small_ship_cargo})">max</button></td>
                                        <td><input type="number" name="ship202" id="ship202" data-ship-id="202" value="0" min="0" max="{$multi_exped_info.naves_disponibles.small_ship_cargo}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}
                                {if $multi_exped_info.naves_disponibles.big_ship_cargo|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Nave grande de carga</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.big_ship_cargo}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship203', {$multi_exped_info.naves_disponibles.big_ship_cargo})">max</button></td>
                                        <td><input type="number" name="ship203" id="ship203" data-ship-id="203" value="0" min="0" max="{$multi_exped_info.naves_disponibles.big_ship_cargo}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== CAZADORES ===== *}
                                {if $multi_exped_info.naves_disponibles.light_hunter|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Cazador ligero</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.light_hunter}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship204', {$multi_exped_info.naves_disponibles.light_hunter})">max</button></td>
                                        <td><input type="number" name="ship204" id="ship204" data-ship-id="204" value="0" min="0" max="{$multi_exped_info.naves_disponibles.light_hunter}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}
                                {if $multi_exped_info.naves_disponibles.heavy_hunter|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Cazador pesado</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.heavy_hunter}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship205', {$multi_exped_info.naves_disponibles.heavy_hunter})">max</button></td>
                                        <td><input type="number" name="ship205" id="ship205" data-ship-id="205" value="0" min="0" max="{$multi_exped_info.naves_disponibles.heavy_hunter}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== CRUCERO ===== *}
                                {if $multi_exped_info.naves_disponibles.crusher|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Crucero</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.crusher}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship206', {$multi_exped_info.naves_disponibles.crusher})">max</button></td>
                                        <td><input type="number" name="ship206" id="ship206" data-ship-id="206" value="0" min="0" max="{$multi_exped_info.naves_disponibles.crusher}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== ACORAZADO ===== *}
                                {if $multi_exped_info.naves_disponibles.battle_ship|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Nave de batalla</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.battle_ship}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship207', {$multi_exped_info.naves_disponibles.battle_ship})">max</button></td>
                                        <td><input type="number" name="ship207" id="ship207" data-ship-id="207" value="0" min="0" max="{$multi_exped_info.naves_disponibles.battle_ship}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== COLONIZADOR ===== *}
                                {if $multi_exped_info.naves_disponibles.colonizer|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Colonizador</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.colonizer}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship208', {$multi_exped_info.naves_disponibles.colonizer})">max</button></td>
                                        <td><input type="number" name="ship208" id="ship208" data-ship-id="208" value="0" min="0" max="{$multi_exped_info.naves_disponibles.colonizer}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== RECICLADOR ===== *}
                                {if $multi_exped_info.naves_disponibles.recycler|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Reciclador</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.recycler}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship209', {$multi_exped_info.naves_disponibles.recycler})">max</button></td>
                                        <td><input type="number" name="ship209" id="ship209" data-ship-id="209" value="0" min="0" max="{$multi_exped_info.naves_disponibles.recycler}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== SONDA ===== *}
                                {if $multi_exped_info.naves_disponibles.spy_sonde|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Sonda de espionaje</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.spy_sonde}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship210', {$multi_exped_info.naves_disponibles.spy_sonde})">max</button></td>
                                        <td><input type="number" name="ship210" id="ship210" data-ship-id="210" value="0" min="0" max="{$multi_exped_info.naves_disponibles.spy_sonde}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== BOMBARDERO ===== *}
                                {if $multi_exped_info.naves_disponibles.bomber_ship|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Bombardero</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.bomber_ship}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship211', {$multi_exped_info.naves_disponibles.bomber_ship})">max</button></td>
                                        <td><input type="number" name="ship211" id="ship211" data-ship-id="211" value="0" min="0" max="{$multi_exped_info.naves_disponibles.bomber_ship}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== DESTRUCTOR ===== *}
                                {if $multi_exped_info.naves_disponibles.destructor|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Destructor</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.destructor}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship213', {$multi_exped_info.naves_disponibles.destructor})">max</button></td>
                                        <td><input type="number" name="ship213" id="ship213" data-ship-id="213" value="0" min="0" max="{$multi_exped_info.naves_disponibles.destructor}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== ESTRELLA DE LA MUERTE ===== *}
                                {if $multi_exped_info.naves_disponibles.dearth_star|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Estrella de la muerte</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.dearth_star}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship214', {$multi_exped_info.naves_disponibles.dearth_star})">max</button></td>
                                        <td><input type="number" name="ship214" id="ship214" data-ship-id="214" value="0" min="0" max="{$multi_exped_info.naves_disponibles.dearth_star}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== ACORAZADO (BATTLESHIP) ===== *}
                                {if $multi_exped_info.naves_disponibles.battleship|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Acorazado</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.battleship}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship215', {$multi_exped_info.naves_disponibles.battleship})">max</button></td>
                                        <td><input type="number" name="ship215" id="ship215" data-ship-id="215" value="0" min="0" max="{$multi_exped_info.naves_disponibles.battleship}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== RECICLADOR GIGANTE ===== *}
                                {if $multi_exped_info.naves_disponibles.giga_recykler|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Reciclador gigante</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.giga_recykler}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship219', {$multi_exped_info.naves_disponibles.giga_recykler})">max</button></td>
                                        <td><input type="number" name="ship219" id="ship219" data-ship-id="219" value="0" min="0" max="{$multi_exped_info.naves_disponibles.giga_recykler}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                {* ===== NAVE DE MATERIA OSCURA ===== *}
                                {if $multi_exped_info.naves_disponibles.dm_ship|default:0 > 0}
                                    <tr>
                                        <td class="astroft_col_left">Nave de materia oscura</td>
                                        <td class="astroft_ship_disponible">{$multi_exped_info.naves_disponibles.dm_ship}</td>
                                        <td><button type="button" class="astroft_max_btn" onclick="astroftMaxNave('ship220', {$multi_exped_info.naves_disponibles.dm_ship})">max</button></td>
                                        <td><input type="number" name="ship220" id="ship220" data-ship-id="220" value="0" min="0" max="{$multi_exped_info.naves_disponibles.dm_ship}" class="astroft_ship_input" oninput="astroftRecalcularExped()"></td>
                                    </tr>
                                {/if}

                                <tr>
                                    <td colspan="2" style="text-align:left;">
                                        <button type="button" class="astroft_link_btn red" onclick="astroftNingunaNave()">Ninguna nave</button>
                                    </td>
                                    <td colspan="2" style="text-align:right;">
                                        <button type="button" class="astroft_link_btn" onclick="astroftTodasLasNaves()">Todas las naves</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
						</div>
                        <div class="astroft_exped_totales" id="astroft_exped_totales">
							⏱️ Tiempo por expedición: <span class="astroft_tot_time" id="astroft_exped_time">—</span><br>
							🚀 Naves por expedición: <strong id="astroft_exped_naves_dist">—</strong><br>
							⚗️ Consumo por expedición: <span class="astroft_tot_deut" id="astroft_exped_consumo_por">0</span><br>
							🔢 Expediciones a enviar: <strong id="astroft_exped_cantidad_show">{$multi_exped_info.slots_libres}</strong><br>
							⚗️ Consumo total: <span class="astroft_tot_deut" id="astroft_exped_consumo_total">0</span>
						</div>

                        <div class="astroft_submit_row">
                            <button type="submit" class="astroft_btn">🌌 Enviar Expediciones</button>
                        </div>
                    </form>

                {else}
                    <div class="astroft_empty">
                        ⚠️ No tienes slots de expedición disponibles.<br>
                        Necesitas investigar <strong>Astrofísica</strong> o esperar a que vuelvan tus flotas actuales.
                    </div>
                {/if}
            {/if}
        </div>
    {/if}

</div>

<script>
// ============================================================
// DATOS EXPORTADOS DESDE PHP
// ============================================================
var ASTROFT_SHIPS           = {$multi_exped_info.naves_data|json_encode};
var ASTROFT_DISTANCE        = {$multi_exped_info.distancia|default:0};
var ASTROFT_GAME_SPEED      = {$multi_exped_info.game_speed|default:1};
var ASTROFT_VELOCIDAD       = {$velocidad_actual|default:10};
var ASTROFT_MIN_FLEET_TIME  = {$multi_exped_info.min_fleet_time|default:1};
var ASTROFT_SLOTS_MAX       = {$multi_exped_info.slots_libres|default:0};
var ASTROFT_DIST_SHIPS  = {$distribuir_info.origen.naves_data|json_encode|default:'{}'};
var ASTROFT_PLANET_M    = {$distribuir_info.origen.metal|default:0};
var ASTROFT_PLANET_C    = {$distribuir_info.origen.crystal|default:0};
var ASTROFT_PLANET_D    = {$distribuir_info.origen.deuterium|default:0};

// ============================================================
// MARCAR TODO
// ============================================================
function astroftMarcarTodo(grupo, estado) {
    var cls = 'astroft_chk_flotas';
    if (grupo === 'recursos') cls = 'astroft_chk_recursos';
    if (grupo === 'dist')     cls = 'astroft_chk_dist';

    var checks = document.querySelectorAll('.' + cls);
    for (var i = 0; i < checks.length; i++) {
        checks[i].checked = estado;
    }
    astroftActualizarTotales();
    astroftActualizarTotalesRecursos();
    astroftActualizarRecibe();
}

// ============================================================
// MULTI-EXPEDICIONES - Naves
// ============================================================
function astroftMaxNave(fieldId, maximo) {
    var el = document.getElementById(fieldId);
    if (el) {
        el.value = maximo;
        astroftRecalcularExped();
    }
}

function astroftNingunaNave() {
    var inputs = document.querySelectorAll('.astroft_ship_input');
    for (var i = 0; i < inputs.length; i++) {
        inputs[i].value = 0;
    }
    astroftRecalcularExped();
}

function astroftTodasLasNaves() {
    var inputs = document.querySelectorAll('.astroft_ship_input');
    for (var i = 0; i < inputs.length; i++) {
        var max = parseInt(inputs[i].getAttribute('max'), 10) || 0;
        inputs[i].value = max;
    }
    astroftRecalcularExped();
}

// ============================================================
// CALCULO EN JS - Tiempo y Consumo (Multi-Expediciones)
// ============================================================
function astroftRecalcularExped() {
    var inputs = document.querySelectorAll('.astroft_ship_input');
    var navesSeleccionadas = {};
    var maxFleetSpeed = 0;
    var totalNaves = 0;

    for (var i = 0; i < inputs.length; i++) {
        var shipId = parseInt(inputs[i].getAttribute('data-ship-id'), 10);
        var qty = parseInt(inputs[i].value, 10) || 0;
        if (qty > 0 && ASTROFT_SHIPS[shipId]) {
            navesSeleccionadas[shipId] = qty;
            var spd = parseFloat(ASTROFT_SHIPS[shipId].speed) || 0;
            if (spd > 0 && (maxFleetSpeed === 0 || spd < maxFleetSpeed)) {
                maxFleetSpeed = spd;
            }
            totalNaves += qty;
        }
    }

    var timeEl    = document.getElementById('astroft_exped_time');
    var consEl    = document.getElementById('astroft_exped_consumo_por');
    var distEl    = document.getElementById('astroft_exped_naves_dist');
    var cantShow  = document.getElementById('astroft_exped_cantidad_show');

    if (maxFleetSpeed === 0 || totalNaves === 0) {
        if (timeEl) timeEl.innerHTML = '—';
        if (consEl) consEl.innerHTML = '0';
        if (distEl) distEl.innerHTML = '—';
        window._astroftConsumoTotal = 0;
        astroftActualizarTotalesExped();
        return;
    }

    // Cantidad deseada (respetando slots)
    var cantidadEl = document.getElementById('astroft_exped_cantidad');
    var cantidad = cantidadEl ? (parseInt(cantidadEl.value, 10) || 1) : 1;
    if (cantidad < 1) cantidad = 1;
    if (ASTROFT_SLOTS_MAX > 0 && cantidad > ASTROFT_SLOTS_MAX) {
        cantidad = ASTROFT_SLOTS_MAX;
        if (cantidadEl) cantidadEl.value = cantidad;
    }

    // c2: limitar al mínimo de naves por tipo
    for (var sid in navesSeleccionadas) {
        if (navesSeleccionadas.hasOwnProperty(sid)) {
            if (navesSeleccionadas[sid] < cantidad) cantidad = navesSeleccionadas[sid];
        }
    }
    if (cantidad < 1) cantidad = 1;

    // Reparto con residuo
    var partes = astroftDividirNaves(navesSeleccionadas, cantidad);

    // Tiempo con maxFleetSpeed global
    var tiempoSegundos = astroftCalcularTiempo(maxFleetSpeed);
    var tiempoStr = astroftFormatTime(tiempoSegundos);

    // Consumo por parte + suma total
    var consumoPor = 0;
    var consumoTotal = 0;
    for (var i = 0; i < partes.length; i++) {
        var c = astroftCalcularConsumo(partes[i], tiempoSegundos, maxFleetSpeed);
        consumoTotal += c;
        if (i === 0) consumoPor = c;
    }

    // Naves por expedición (mostrar todos los recuentos)
    var distArr = [];
    for (var i = 0; i < partes.length; i++) {
        var t = 0;
        for (var s in partes[i]) if (partes[i].hasOwnProperty(s)) t += partes[i][s];
        distArr.push(t);
    }

    if (timeEl) timeEl.innerHTML = tiempoStr;
    if (consEl) consEl.innerHTML = consumoPor.toLocaleString('es-ES');
    if (distEl) distEl.innerHTML = distArr.join(' / ');
    if (cantShow) cantShow.innerHTML = cantidad;

    window._astroftConsumoTotal = consumoTotal;
    astroftActualizarTotalesExped();
}

function astroftDividirNaves(naves, cantidad) {
    var resultado = [];
    for (var i = 0; i < cantidad; i++) resultado[i] = {};
    for (var shipId in naves) {
        if (!naves.hasOwnProperty(shipId)) continue;
        var qty = naves[shipId];
        var porParte = Math.floor(qty / cantidad);
        var residuo = qty - (porParte * cantidad);
        for (var i = 0; i < cantidad; i++) {
            var q = porParte + (i < residuo ? 1 : 0);
            if (q > 0) resultado[i][shipId] = q;
        }
    }
    return resultado;
}

function astroftCalcularTiempo(maxFleetSpeed) {
    if (maxFleetSpeed <= 0 || ASTROFT_DISTANCE <= 0 || ASTROFT_GAME_SPEED <= 0) {
        return 0;
    }

    var speedFactor = (3500 / (ASTROFT_VELOCIDAD * 0.1));
    speedFactor *= Math.sqrt(ASTROFT_DISTANCE * 10 / maxFleetSpeed);
    speedFactor += 10;
    speedFactor /= ASTROFT_GAME_SPEED;

    var duration = Math.max(speedFactor, ASTROFT_MIN_FLEET_TIME);
    return Math.ceil(duration);
}

function astroftCalcularConsumo(naves, duracion, maxFleetSpeed) {
    var consumo = 0;
    var checkDiv = (duracion * ASTROFT_GAME_SPEED) - 10;
    if (checkDiv <= 0) return 0;

    for (var shipId in naves) {
        if (!naves.hasOwnProperty(shipId)) continue;
        var qty = naves[shipId];
        var shipData = ASTROFT_SHIPS[shipId];
        if (!shipData) continue;

        var shipSpeed = parseFloat(shipData.speed) || 1;
        var shipCons = parseFloat(shipData.consumption) || 0;

        if (shipSpeed <= 0 || shipCons <= 0) continue;

        var spd = 35000 / (duracion * ASTROFT_GAME_SPEED - 10) * Math.sqrt(ASTROFT_DISTANCE * 10 / shipSpeed);
        var basicConsumption = shipCons * qty;
        consumo += basicConsumption * ASTROFT_DISTANCE / 35000 * Math.pow((spd / 10) + 1, 2);
    }

    return Math.round(consumo) + 1;
}

function astroftFormatTime(segundos) {
    segundos = parseInt(segundos, 10);
    var h = Math.floor(segundos / 3600);
    var m = Math.floor((segundos % 3600) / 60);
    var s = segundos % 60;
    return h + ':' + (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
}

// ============================================================
// TOTALES DE MULTI-EXPEDICIONES
// ============================================================
function astroftActualizarTotalesExped() {
    var cantidadEl = document.getElementById('astroft_exped_cantidad');
    var cantidad = cantidadEl ? (parseInt(cantidadEl.value, 10) || 1) : 1;
    if (cantidad < 1) cantidad = 1;
    if (ASTROFT_SLOTS_MAX > 0 && cantidad > ASTROFT_SLOTS_MAX) {
        cantidad = ASTROFT_SLOTS_MAX;
        if (cantidadEl) cantidadEl.value = cantidad;
    }

    var cantShow = document.getElementById('astroft_exped_cantidad_show');
    if (cantShow) cantShow.innerHTML = cantidad;

    var consumoTotal = window._astroftConsumoTotal || 0;
    var totalEl = document.getElementById('astroft_exped_consumo_total');
    if (totalEl) totalEl.innerHTML = consumoTotal.toLocaleString('es-ES');
}

// ============================================================
// CAMBIAR VELOCIDAD (recarga con ?vel=X)
// ============================================================
function astroftCambiarVelocidad(nuevaVelocidad) {
    var elM = document.getElementById('astroft_metal');
    var elC = document.getElementById('astroft_crystal');
    var elD = document.getElementById('astroft_deuterium');
    if (elM) sessionStorage.setItem('astroft_dist_metal', elM.value);
    if (elC) sessionStorage.setItem('astroft_dist_crystal', elC.value);
    if (elD) sessionStorage.setItem('astroft_dist_deuterium', elD.value);

    var url = new URL(window.location.href);
    url.searchParams.set('vel', nuevaVelocidad);
    window.location.href = url.toString();
}

// ============================================================
// TOTALES - Reunir Flotas
// ============================================================
function astroftActualizarTotales() {
    var checks = document.querySelectorAll('.astroft_chk_flotas');
    var planetas = 0;
    var naves = 0;
    var consumo = 0;

    for (var i = 0; i < checks.length; i++) {
        if (checks[i].checked) {
            planetas++;
            var row = checks[i].closest('tr');
            if (row) {
                var navesCell = row.querySelector('.astroft_col_naves');
                var consCell  = row.querySelector('.astroft_col_cons');
                if (navesCell) {
                    var n = navesCell.textContent.replace(/[^0-9]/g, '');
                    naves += parseInt(n, 10) || 0;
                }
                if (consCell) {
                    var c = consCell.textContent.replace(/[^0-9]/g, '');
                    consumo += parseInt(c, 10) || 0;
                }
            }
        }
    }

    var navesStr   = naves.toLocaleString('es-ES');
    var consumoStr = consumo.toLocaleString('es-ES');

    var totalDiv = document.querySelector('.astroft_totales');
    if (totalDiv && document.querySelector('.astroft_chk_flotas')) {
        totalDiv.innerHTML = 'Total: <b>' + planetas + '</b> planetas · <b>' + navesStr + '</b> naves · Consumo total: <span class="astroft_tot_deut">⚗️ ' + consumoStr + '</span>';
    }
}

// ============================================================
// TOTALES - Reunir Recursos
// ============================================================
function astroftActualizarTotalesRecursos() {
    var checks = document.querySelectorAll('.astroft_chk_recursos');
    var planetas = 0;
    var metal = 0;
    var crystal = 0;
    var deut = 0;
    var naves = 0;
    var consumo = 0;

    for (var i = 0; i < checks.length; i++) {
        if (checks[i].checked) {
            planetas++;
            metal   += parseInt(checks[i].getAttribute('data-metal'), 10) || 0;
            crystal += parseInt(checks[i].getAttribute('data-crystal'), 10) || 0;
            deut    += parseInt(checks[i].getAttribute('data-deut'), 10) || 0;
            naves   += parseInt(checks[i].getAttribute('data-naves'), 10) || 0;
            consumo += parseInt(checks[i].getAttribute('data-consumo'), 10) || 0;
        }
    }

    var metalStr   = metal.toLocaleString('es-ES');
    var crystalStr = crystal.toLocaleString('es-ES');
    var deutStr    = deut.toLocaleString('es-ES');
    var consumoStr = consumo.toLocaleString('es-ES');

    var totalDiv = document.getElementById('astroft_totales_recursos');
    if (totalDiv) {
        totalDiv.innerHTML = 'Total: <b>' + planetas + '</b> planetas · ' +
            '🔩 <span class="astroft_tot_metal">' + metalStr + '</span> · ' +
            '💎 <span class="astroft_tot_crystal">' + crystalStr + '</span> · ' +
            '⚗️ <span class="astroft_tot_deut">' + deutStr + '</span> · ' +
            '<b>' + naves + '</b> naves · ' +
            'Consumo: <span class="astroft_tot_deut">⚗️ ' + consumoStr + '</span>';
    }
}

// ============================================================
// TOTALES - Distribuir Recursos
// ============================================================
function astroftGetRequiredShips(capNeeded) {
    var ships = {};
    var caps = { 203: 25000, 217: 25000, 202: 5000 };
    var order = [203, 217, 202]; // Prioridad A
    
    var avail = {
        202: parseInt(document.querySelector('input[name="small_ship_cargo"]') ? 0 : 0), // Usaremos los datos de PHP
        203: 0, 217: 0
    };
    
    // Obtenemos disponibilidad real desde el HTML (si no hay inputs, usamos el origen de PHP)
    var avail203 = parseInt("{$distribuir_info.origen.big_ship_cargo|default:0}");
    var avail217 = parseInt("{$distribuir_info.origen.ev_transporter|default:0}");
    var avail202 = parseInt("{$distribuir_info.origen.small_ship_cargo|default:0}");
    var available = { 202: avail202, 203: avail203, 217: avail217 };
    
    for (var i = 0; i < order.length; i++) {
        var sid = order[i];
        if (capNeeded > 0 && available[sid] > 0) {
            var c = caps[sid];
            var need = Math.ceil(capNeeded / c);
            var use = Math.min(need, available[sid]);
            ships[sid] = use;
            capNeeded -= (use * c);
        }
    }
    return ships;
}

function astroftGetMaxSpeed(ships) {
    var maxSpeed = 0;
    for (var sid in ships) {
        if (!ships.hasOwnProperty(sid) || ships[sid] <= 0) continue;
        var spd = ASTROFT_DIST_SHIPS[sid] ? parseFloat(ASTROFT_DIST_SHIPS[sid].speed) : 0;
        if (spd > 0 && (maxSpeed === 0 || spd < maxSpeed)) maxSpeed = spd;
    }
    return maxSpeed;
}

function astroftCalcTime(distance, maxSpeed) {
    if (maxSpeed <= 0 || distance <= 0 || ASTROFT_GAME_SPEED <= 0) return 0;
    var speedFactor = (3500 / (ASTROFT_VELOCIDAD * 0.1));
    speedFactor *= Math.sqrt(distance * 10 / maxSpeed);
    speedFactor += 10;
    speedFactor /= ASTROFT_GAME_SPEED;
    var duration = Math.max(speedFactor, ASTROFT_MIN_FLEET_TIME);
    return Math.ceil(duration);
}

function astroftCalcFuel(ships, duration, distance, maxSpeed) {
    var fuel = 0;
    var checkDiv = (duration * ASTROFT_GAME_SPEED) - 10;
    if (checkDiv <= 0) return 0;
    for (var sid in ships) {
        if (!ships.hasOwnProperty(sid) || ships[sid] <= 0) continue;
        var data = ASTROFT_DIST_SHIPS[sid];
        if (!data) continue;
        var spd = 35000 / (duration * ASTROFT_GAME_SPEED - 10) * Math.sqrt(distance * 10 / data.speed);
        fuel += (data.consumption * ships[sid]) * distance / 35000 * Math.pow((spd / 10) + 1, 2);
    }
    return Math.round(fuel) + 1;
}

function astroftActualizarRecibe() {
    var elM = document.getElementById('astroft_metal');
    var elC = document.getElementById('astroft_crystal');
    var elD = document.getElementById('astroft_deuterium');
    if (!elM || !elC || !elD) return;

    var metal = parseInt(elM.value, 10) || 0;
    var crystal = parseInt(elC.value, 10) || 0;
    var deut = parseInt(elD.value, 10) || 0;
    var totalRes = metal + crystal + deut;

    var checks = document.querySelectorAll('.astroft_chk_dist');
    var numMarcados = 0;
    for (var i = 0; i < checks.length; i++) if (checks[i].checked) numMarcados++;

    // Limpiar filas
    for (var i = 0; i < checks.length; i++) {
        var row = checks[i].closest('tr');
        row.querySelector('.astroft_col_recibe').innerHTML = '—';
        row.querySelector('.astroft_col_time').innerHTML = '—';
        row.querySelector('.astroft_col_cons').innerHTML = '—';
    }

    if (numMarcados === 0 || totalRes === 0) {
        window._astroftDistFuel = 0;
        astroftActualizarTotalesDist();
        return;
    }

    var totalShips = astroftGetRequiredShips(totalRes);
    var shipsPerDest = [];
    for (var i = 0; i < numMarcados; i++) shipsPerDest[i] = {};
    
    for (var sid in totalShips) {
        if (!totalShips.hasOwnProperty(sid)) continue;
        var per = Math.floor(totalShips[sid] / numMarcados);
        var rest = totalShips[sid] - (per * numMarcados);
        for (var i = 0; i < numMarcados; i++) {
            shipsPerDest[i][sid] = per + (i < rest ? 1 : 0);
        }
    }

    var mPer = Math.floor(metal / numMarcados), mRest = metal - (mPer * numMarcados);
    var cPer = Math.floor(crystal / numMarcados), cRest = crystal - (cPer * numMarcados);
    var dPer = Math.floor(deut / numMarcados), dRest = deut - (dPer * numMarcados);

    var idx = 0, totalFuel = 0;

    for (var i = 0; i < checks.length; i++) {
        if (!checks[i].checked) continue;
        var row = checks[i].closest('tr');
        
        var mF = mPer + (idx < mRest ? 1 : 0);
        var cF = cPer + (idx < cRest ? 1 : 0);
        var dF = dPer + (idx < dRest ? 1 : 0);
        row.querySelector('.astroft_col_recibe').innerHTML = '🔩 ' + mF.toLocaleString() + '<br>💎 ' + cF.toLocaleString() + '<br>⚗️ ' + dF.toLocaleString();

        var distance = parseFloat(checks[i].getAttribute('data-distancia')) || 0;
        var ships = shipsPerDest[idx];
        var hasShips = false;
        for (var s in ships) if (ships[s] > 0) hasShips = true;

        if (hasShips && distance > 0) {
            var maxSpeed = astroftGetMaxSpeed(ships);
            var duration = astroftCalcTime(distance, maxSpeed);
            var fuel = astroftCalcFuel(ships, duration, distance, maxSpeed);
            
            row.querySelector('.astroft_col_time').innerHTML = '⏱️ ' + astroftFormatTime(duration);
            row.querySelector('.astroft_col_cons').innerHTML = '⚗️ ' + fuel.toLocaleString();
            totalFuel += fuel;
        }
        idx++;
    }

    window._astroftDistFuel = totalFuel;
    astroftActualizarTotalesDist();
}

function astroftActualizarTotalesDist() {
    var checks = document.querySelectorAll('.astroft_chk_dist');
    var planetas = 0;
    for (var i = 0; i < checks.length; i++) if (checks[i].checked) planetas++;

    var elM = document.getElementById('astroft_metal');
    var elC = document.getElementById('astroft_crystal');
    var elD = document.getElementById('astroft_deuterium');

    var metal = elM ? (parseInt(elM.value, 10) || 0) : 0;
    var crystal = elC ? (parseInt(elC.value, 10) || 0) : 0;
    var deut = elD ? (parseInt(elD.value, 10) || 0) : 0;
    var consumo = window._astroftDistFuel || 0;

    var totalDiv = document.getElementById('astroft_totales_dist');
    if (totalDiv) {
        totalDiv.innerHTML = 'Total: <b>' + planetas + '</b> planetas · ' +
            '🔩 <span class="astroft_tot_metal">' + metal.toLocaleString() + '</span> · ' +
            '💎 <span class="astroft_tot_crystal">' + crystal.toLocaleString() + '</span> · ' +
            '⚗️ <span class="astroft_tot_deut">' + deut.toLocaleString() + '</span> · ' +
            'Consumo: <span class="astroft_tot_deut">⚗️ ' + consumo.toLocaleString() + '</span>';
    }
}

function astroftCapacidadCarga() {
    var elM = document.getElementById('astroft_metal');
    var elC = document.getElementById('astroft_crystal');
    var elD = document.getElementById('astroft_deuterium');
    
    if (!elM || !elC || !elD) return;

    // Obtenemos cuántas naves tienes disponibles de cada tipo
    var avail202 = parseInt("{$distribuir_info.origen.small_ship_cargo|default:0}");
    var avail203 = parseInt("{$distribuir_info.origen.big_ship_cargo|default:0}");
    var avail217 = parseInt("{$distribuir_info.origen.ev_transporter|default:0}");

    // Capacidades por defecto por si el Helper falla
    var caps = { 202: 5000, 203: 25000, 217: 25000 };

    // Calculamos la capacidad real de cada nave
    var cap202 = avail202 * (ASTROFT_DIST_SHIPS[202] && ASTROFT_DIST_SHIPS[202].capacity ? ASTROFT_DIST_SHIPS[202].capacity : caps[202]);
    var cap203 = avail203 * (ASTROFT_DIST_SHIPS[203] && ASTROFT_DIST_SHIPS[203].capacity ? ASTROFT_DIST_SHIPS[203].capacity : caps[203]);
    var cap217 = avail217 * (ASTROFT_DIST_SHIPS[217] && ASTROFT_DIST_SHIPS[217].capacity ? ASTROFT_DIST_SHIPS[217].capacity : caps[217]);

    var totalCap = cap202 + cap203 + cap217;

    // Dividimos la capacidad en 3 partes iguales (1/3 para metal, 1/3 cristal, 1/3 deut)
    var perM = Math.floor(totalCap / 3);
    var perC = Math.floor(totalCap / 3);
    var perD = totalCap - perM - perC;

    // Asignamos los valores sin superar lo que hay en el planeta
    elM.value = Math.min(ASTROFT_PLANET_M, perM);
    elC.value = Math.min(ASTROFT_PLANET_C, perC);
    elD.value = Math.min(ASTROFT_PLANET_D, perD);

    // Recalculamos el consumo y el reparto
    astroftActualizarRecibe();
}

// ============================================================
// INIT
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    // Restaurar inputs
    var elM = document.getElementById('astroft_metal');
    var elC = document.getElementById('astroft_crystal');
    var elD = document.getElementById('astroft_deuterium');
    if (elM) {
        var vM = sessionStorage.getItem('astroft_dist_metal');
        if (vM !== null) { elM.value = vM; sessionStorage.removeItem('astroft_dist_metal'); }
    }
    if (elC) {
        var vC = sessionStorage.getItem('astroft_dist_crystal');
        if (vC !== null) { elC.value = vC; sessionStorage.removeItem('astroft_dist_crystal'); }
    }
    if (elD) {
        var vD = sessionStorage.getItem('astroft_dist_deuterium');
        if (vD !== null) { elD.value = vD; sessionStorage.removeItem('astroft_dist_deuterium'); }
    }

    // Checkboxes
    var checksFlotas = document.querySelectorAll('.astroft_chk_flotas');
    for (var i = 0; i < checksFlotas.length; i++) {
        checksFlotas[i].addEventListener('change', astroftActualizarTotales);
    }

    var checksRecursos = document.querySelectorAll('.astroft_chk_recursos');
    for (var i = 0; i < checksRecursos.length; i++) {
        checksRecursos[i].addEventListener('change', astroftActualizarTotalesRecursos);
    }

    var checksDist = document.querySelectorAll('.astroft_chk_dist');
    for (var i = 0; i < checksDist.length; i++) {
        checksDist[i].addEventListener('change', astroftActualizarRecibe);
    }

    astroftActualizarTotales();
    astroftActualizarTotalesRecursos();
    astroftActualizarRecibe();

    // Inicializar expedición
    if (document.querySelector('.astroft_ship_input')) {
        astroftRecalcularExped();
    }
});
</script>

{/block}