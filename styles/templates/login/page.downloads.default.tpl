{block name="title" prepend}Descargas - AstroIO{/block}
{block name="content"}
{literal}
<style>
/* Estilos de la página de descargas (adaptados al tema oscuro) */
.astro-dl-container {
    max-width: 1000px;
    margin: 20px auto;
    padding: 10px;
}

h1, h2, h3 {
    text-align: center;
    color: #ffffff;
    text-transform: uppercase;
    letter-spacing: 1px;
}

h1 { font-size: 2.2rem; margin-bottom: 10px; }

.astro-dl-subtitle {
    text-align: center;
    color: #94a3b8;
    margin-bottom: 30px;
    font-size: 1.1rem;
}

.astro-dl-web {
    text-align: center;
    margin-bottom: 40px;
}

.astro-dl-btn-web {
    display: inline-block;
    padding: 15px 40px;
    background: #10b981; 
    color: #ffffff;
    text-decoration: none;
    font-weight: bold;
    font-size: 1.2rem;
    border-radius: 5px;
    transition: all 0.3s ease;
    text-transform: uppercase;
    box-shadow: 0 0 15px rgba(16, 185, 129, 0.4);
}

.astro-dl-btn-web:hover {
    background: #059669;
    box-shadow: 0 0 25px rgba(16, 185, 129, 0.8);
    transform: translateY(-2px);
}

.astro-dl-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 40px;
}

.astro-dl-card {
    background: rgba(10, 15, 25, 0.9);
    border: 1px solid #ff5e00; /* Borde naranja */
    padding: 20px;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: border 0.3s;
}

.astro-dl-card:hover {
    box-shadow: 0 0 20px rgba(255, 94, 0, 0.3);
}

.astro-dl-card h3 {
    margin-top: 0;
    font-size: 1.3rem;
    color: #00e0ff;
    margin-bottom: 15px;
}

.astro-dl-changelog {
    font-size: 0.85rem;
    color: #cbd5e1;
    line-height: 1.5;
    margin-bottom: 20px;
}

.astro-dl-changelog p { margin: 5px 0; }
.astro-dl-changelog ul { margin: 5px 0 10px 20px; padding: 0; }

.astro-dl-warning {
    color: #fbbf24;
    font-weight: bold;
    font-size: 0.8rem;
    margin-top: 10px;
    border-top: 1px dashed #475569;
    padding-top: 10px;
}

.astro-dl-btn {
    display: block;
    text-align: center;
    padding: 12px;
    background: #222c3c;
    border: 1px solid #444;
    color: #00e0ff;
    text-decoration: none;
    font-weight: bold;
    border-radius: 4px;
    transition: all 0.3s ease;
    margin-top: auto;
}

.astro-dl-btn:hover {
    background: #2e3a4e;
    border-color: #ff5e00;
    color: #fff;
    box-shadow: 0 0 15px rgba(255, 94, 0, 0.4);
}

.astro-dl-qvapay {
    background: rgba(0, 224, 255, 0.05);
    border: 1px solid #00e0ff;
    padding: 25px;
    border-radius: 8px;
    margin-bottom: 40px;
    text-align: center;
}

.astro-dl-qvapay h3 { color: #00e0ff; }

.astro-dl-qvapay-btn {
    display: inline-block;
    padding: 12px 30px;
    background: #00e0ff;
    color: #0b1120;
    text-decoration: none;
    font-weight: bold;
    border-radius: 4px;
    margin: 15px 0;
    transition: background 0.3s;
}

.astro-dl-qvapay-btn:hover { background: #7dd3fc; }

.astro-dl-ref {
    color: #fbbf24; 
    font-weight: bold;
    word-break: break-all;
}

.astro-dl-req-title {
    text-align: left;
    border-bottom: 1px solid #ff5e00;
    padding-bottom: 10px;
    margin-bottom: 20px;
    font-size: 1.5rem;
    color: #00e0ff;
}

.astro-dl-req-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 40px;
    font-size: 0.9rem;
    color: #94a3b8;
}

.astro-dl-req-grid strong {
    color: #f8fafc;
    display: block;
    margin-top: 15px;
    margin-bottom: 5px;
    font-size: 1.1rem;
}

.astro-dl-req-grid ul {
    margin: 0;
    padding-left: 20px;
    line-height: 1.6;
}

@media (max-width: 768px) {
    .astro-dl-grid, .astro-dl-req-grid {
        grid-template-columns: 1fr;
    }
}
</style>
{/literal}

<div class="astro-dl-container">
    <h1>Descarga AstroIO</h1>
    <p class="astro-dl-subtitle">Elige cómo quieres conquistar la galaxia</p>

    <div class="astro-dl-web">
        <a href="index.php" class="astro-dl-btn-web">🌐 Jugar Directo en el Navegador</a>
        <p style="color: #64748b; font-size: 0.85rem; margin-top: 10px;">No necesitas descargar nada, juega al instante.</p>
    </div>

    <div class="astro-dl-grid">
        <!-- Opción PC -->
        <div class="astro-dl-card">
            <h3>💻 Launcher (PC)</h3>
            
            <div class="astro-dl-changelog">
                <p>🚀 <strong>¡NUEVA ACTUALIZACIÓN! — AstroIO v3.14</strong></p>
                <p>⚙️ Versión: v3.14</p>
                <p>🤖 Sistema: Windows</p>
                <p>📱 Compatible: W7, W8, W8.1, W10 y W11</p>
                <p>🛂 Desarrollo: @Holows</p>
                <p>🗒 Nota: Modo BETA, todavía en desarrollo.</p>
                <p>♻️ <strong>Errores corregidos:</strong></p>
                <ul>
                    <li>Reanudación de la interfaz.</li>
                    <li>Correcciones mínimas.</li>
                </ul>
                <p class="astro-dl-warning">👀 Aviso importante: Por favor, eviten compartir este contenido. Este trabajo se hace exclusivamente para nuestra comunidad.</p>
            </div>

            <a href="styles/theme/gow/descarga/LauncherAstroIO.exe" class="astro-dl-btn" download>Descargar para Windows</a>
        </div>
        
        <!-- Opción Android APK -->
        <div class="astro-dl-card">
            <h3>📱 APK (Android)</h3>
            
            <div class="astro-dl-changelog">
                <p>🚀 <strong>¡NUEVA ACTUALIZACIÓN! — AstroIO v3.14</strong></p>
                <p>⚙️ Versión: v3.14</p>
                <p>🤖 Sistema: Android</p>
                <p>📱 Compatible: Android 5.0+</p>
                <p>🛂 Desarrollo: @Holows</p>
                <p>🗒 Nota: Modo BETA, todavía en desarrollo.</p>
                <p>♻️ <strong>Errores corregidos:</strong></p>
                <ul>
                    <li>Reanudación de la interfaz móvil.</li>
                    <li>Correcciones mínimas.</li>
                </ul>
                <p class="astro-dl-warning">👀 Aviso importante: Por favor, eviten compartir este contenido. Este trabajo se hace exclusivamente para nuestra comunidad.</p>
            </div>

            <a href="styles/theme/gow/descarga/AstroIO.apk" class="astro-dl-btn" download>Descargar APK</a>
        </div>
    </div>

    <div class="astro-dl-qvapay">
        <h3>💳 Recargas y Pagos con QvaPay</h3>
        <p>Descarga la aplicación oficial de QvaPay para gestionar tus fondos, comprar recursos o adquirir mejoras en AstroIO de forma segura.</p>
        
        <a href="https://www.qvapay.com/app" target="_blank" class="astro-dl-qvapay-btn">Descargar App de QvaPay</a>
        
        <p style="font-size: 0.9rem; margin-top: 15px; color: #cbd5e1;">
            <strong>¡Importante!</strong> Regístrate usando nuestro enlace oficial para apoyar a AstroIO y recibir beneficios exclusivos:<br>
            <a href="https://www.qvapay.com/register/AstroIO" target="_blank" class="astro-dl-ref">https://www.qvapay.com/register/AstroIO</a>
        </p>
    </div>

    <h2 class="astro-dl-req-title">Requisitos Mínimos del Sistema</h2>

    <div class="astro-dl-req-grid">
        <div>
            <strong>Windows (Launcher)</strong>
            <ul>
                <li>Windows XP o superior</li>
                <li>Procesador Intel/AMD de doble núcleo</li>
                <li>500 MB RAM (1 GB recomendado)</li>
                <li>Conexión a internet estable</li>
            </ul>
        </div>

        <div>
            <strong>Android (APK)</strong>
            <ul>
                <li>Android 5.0 o superior</li>
                <li>Procesador ARM de 64 bits</li>
                <li>200 MB RAM (1 GB recomendado)</li>
                <li>Espacio libre de 500 MB</li>
                <li>No requiere tarjeta SD</li>
            </ul>
        </div>
    </div>
</div>
{/block}