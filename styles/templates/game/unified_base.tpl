{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/unified_base.tpl === *}
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

<link rel="stylesheet" type="text/css" href="styles/resource/css/ingame/unified.css">
<script src="styles/resource/js/unified.js"></script>

<div id="unified-module-wrapper">
    
    <!-- Encabezado del módulo -->
    <div class="ub-header">
        <h1>Centro de Mando</h1>
        <p>Gestiona tu imperio desde un solo lugar</p>
    </div>

    <!-- Menú de Pestañas (Tabs) -->
    <div class="ub-tabs-header">
        <button class="ub-tab-btn active buildings" onclick="openUbTab('ub-tab-buildings', 'buildings')">
            🏗️ Edificios
        </button>
        <button class="ub-tab-btn research" onclick="openUbTab('ub-tab-research', 'research')">
            🔬 Investigaciones
        </button>
        <button class="ub-tab-btn shipyard" onclick="openUbTab('ub-tab-shipyard', 'shipyard')">
            🚀 Hangar
        </button>
        <button class="ub-tab-btn defense" onclick="openUbTab('ub-tab-defense', 'defense')">
            🛡️ Defensas
        </button>
    </div>

    <!-- ========================================== -->
    <!-- 1. PESTAÑA EDIFICIOS (AHORA ES UN MAPA)    -->
    <!-- ========================================== -->
    <div class="ub-tab-content active" id="ub-tab-buildings">
        
        <!-- Este es el "Mapa" donde irán los edificios -->
        <div class="ub-map-container">
            
            <!-- Edificio 1 (Mina de Metal) -->
            <!-- Usamos style="top: X%; left: Y%;" para ubicarlo en el mapa -->
            <div class="ub-map-node" style="top: 20%; left: 15%;" onclick="alert('¡Has hecho clic en la Mina de Metal!')">
                <div class="ub-map-timer">⏱️ 125d 10h</div>
                <div class="ub-map-icon">🏭</div>
                <div class="ub-map-label">
                    <span class="ub-map-name">Mina de metal</span>
                    <span class="ub-map-level">Nv. 19</span>
                </div>
            </div>

            <!-- Edificio 2 (Planta de Energía) -->
            <div class="ub-map-node" style="top: 55%; left: 40%;" onclick="alert('¡Planta de Energía!')">
                <div class="ub-map-icon">⚡</div>
                <div class="ub-map-label">
                    <span class="ub-map-name">Planta de energía</span>
                    <span class="ub-map-level">Nv. 18</span>
                </div>
            </div>

            <!-- Edificio 3 (Almacén) -->
            <div class="ub-map-node" style="top: 25%; left: 70%;" onclick="alert('¡Almacén!')">
                <div class="ub-map-icon">📦</div>
                <div class="ub-map-label">
                    <span class="ub-map-name">Almacén de metal</span>
                    <span class="ub-map-level">Nv. 15</span>
                </div>
            </div>

            <!-- Edificio 4 (Laboratorio) -->
            <div class="ub-map-node" style="top: 75%; left: 20%;" onclick="alert('¡Laboratorio!')">
                <div class="ub-map-icon">🧪</div>
                <div class="ub-map-label">
                    <span class="ub-map-name">Laboratorio</span>
                    <span class="ub-map-level">Nv. 10</span>
                </div>
            </div>

        </div>
    </div>

    <!-- 2. PESTAÑA INVESTIGACIONES -->
    <div class="ub-tab-content" id="ub-tab-research">
        <h2 class="ub-section-title">Laboratorio de Investigación</h2>
        <div class="ub-grid">
            <div class="ub-card purple">
                <div class="ub-card-image">🔬</div>
                <div class="ub-level-badge">Nv. 4</div>
                <div class="ub-card-content">
                    <div class="ub-card-title">Tecnología de espionaje</div>
                    <div class="ub-card-time">⏱️ Tiempo: 02h 46m</div>
                    <button class="ub-btn purple-btn">Investigar Nv. 5</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 3. PESTAÑA HANGAR -->
    <div class="ub-tab-content" id="ub-tab-shipyard">
        <h2 class="ub-section-title">Hangar de Construcción</h2>
        <div class="ub-grid">
            <div class="ub-card green">
                <div class="ub-card-image">🚀</div>
                <div class="ub-level-badge">Disp: 0</div>
                <div class="ub-card-content">
                    <div class="ub-card-title">Crucero</div>
                    <button class="ub-btn green-btn">Construir 1</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 4. PESTAÑA DEFENSAS -->
    <div class="ub-tab-content" id="ub-tab-defense">
        <h2 class="ub-section-title">Sistemas Defensivos</h2>
        <div class="ub-grid">
            <div class="ub-card red">
                <div class="ub-card-image">🛡️</div>
                <div class="ub-level-badge">Disp: 15</div>
                <div class="ub-card-content">
                    <div class="ub-card-title">Láser pequeño</div>
                    <button class="ub-btn red-btn">Construir 1</button>
                </div>
            </div>
        </div>
    </div>

</div>
{/block}