{block name="content"}
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