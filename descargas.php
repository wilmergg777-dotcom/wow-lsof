<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Descarga el Cliente - AstroIO</title>
    
    <style>
        body {
            background: url('https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=2070&auto=format&fit=crop') no-repeat center center fixed; 
            background-size: cover;
            background-color: #0b1120; 
            color: #e2e8f0; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 1000px;
            margin: 50px auto;
            background: rgba(15, 23, 42, 0.9); 
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.7);
            border: 1px solid #1e293b;
        }

        h1, h2, h3 {
            text-align: center;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        h1 { font-size: 2.2rem; margin-bottom: 10px; }
        
        .subtitle {
            text-align: center;
            color: #94a3b8;
            margin-bottom: 30px;
            font-size: 1.1rem;
        }

        .web-play-container {
            text-align: center;
            margin-bottom: 40px;
        }

        .btn-web {
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

        .btn-web:hover {
            background: #059669;
            box-shadow: 0 0 25px rgba(16, 185, 129, 0.8);
            transform: translateY(-2px);
        }

        .download-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 40px;
        }

        .download-card {
            background: rgba(30, 41, 59, 0.7);
            border: 1px solid #334155;
            padding: 20px;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: border 0.3s;
        }

        .download-card:hover {
            border-color: #38bdf8;
        }

        .download-card h3 {
            margin-top: 0;
            font-size: 1.3rem;
            color: #38bdf8;
            margin-bottom: 15px;
        }

        .changelog {
            font-size: 0.85rem;
            color: #cbd5e1;
            line-height: 1.5;
            margin-bottom: 20px;
        }
        
        .changelog p { margin: 5px 0; }
        .changelog ul { margin: 5px 0 10px 20px; padding: 0; }

        .warning-text {
            color: #fbbf24;
            font-weight: bold;
            font-size: 0.8rem;
            margin-top: 10px;
            border-top: 1px dashed #475569;
            padding-top: 10px;
        }

        .download-btn {
            display: block;
            text-align: center;
            padding: 12px;
            background: transparent;
            border: 1px solid #38bdf8;
            color: #38bdf8;
            text-decoration: none;
            font-weight: bold;
            border-radius: 4px;
            transition: all 0.3s ease;
            margin-top: auto;
        }

        .download-btn:hover {
            background: #38bdf8;
            color: #0b1120;
            box-shadow: 0 0 15px rgba(56, 189, 248, 0.5);
        }

        .qvapay-section {
            background: rgba(56, 189, 248, 0.1);
            border: 1px solid #38bdf8;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 40px;
            text-align: center;
        }

        .qvapay-section h3 { color: #38bdf8; }
        
        .qvapay-btn {
            display: inline-block;
            padding: 12px 30px;
            background: #38bdf8;
            color: #0b1120;
            text-decoration: none;
            font-weight: bold;
            border-radius: 4px;
            margin: 15px 0;
            transition: background 0.3s;
        }

        .qvapay-btn:hover { background: #7dd3fc; }

        .ref-link {
            color: #fbbf24; 
            font-weight: bold;
            word-break: break-all;
        }

        .requirements-title {
            text-align: left;
            border-bottom: 1px solid #334155;
            padding-bottom: 10px;
            margin-bottom: 20px;
            font-size: 1.5rem;
        }

        .requirements-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            font-size: 0.9rem;
            color: #94a3b8;
        }

        .requirements-grid strong {
            color: #f8fafc;
            display: block;
            margin-top: 15px;
            margin-bottom: 5px;
            font-size: 1.1rem;
        }

        .requirements-grid ul {
            margin: 0;
            padding-left: 20px;
            line-height: 1.6;
        }

        @media (max-width: 768px) {
            .download-grid, .requirements-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

    <div class="container">
        <h1>Descarga AstroIO</h1>
        <p class="subtitle">Elige cómo quieres conquistar la galaxia</p>

        <div class="web-play-container">
            <a href="index.php" class="btn-web">🌐 Jugar Directo en el Navegador</a>
            <p style="color: #64748b; font-size: 0.85rem; margin-top: 10px;">No necesitas descargar nada, juega al instante.</p>
        </div>

        <div class="download-grid">
            <!-- Opción PC -->
            <div class="download-card">
                <h3>💻 Launcher (PC)</h3>
                
                <div class="changelog">
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
                    <p class="warning-text">👀 Aviso importante: Por favor, eviten compartir este contenido. Este trabajo se hace exclusivamente para nuestra comunidad.</p>
                </div>

                <!-- RUTA CORREGIDA PARA EL LAUNCHER -->
                <a href="styles/theme/gow/descarga/LauncherAstroIO.exe" class="download-btn" download>Descargar para Windows</a>
            </div>
            
            <!-- Opción Android APK -->
            <div class="download-card">
                <h3>📱 APK (Android)</h3>
                
                <div class="changelog">
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
                    <p class="warning-text">👀 Aviso importante: Por favor, eviten compartir este contenido. Este trabajo se hace exclusivamente para nuestra comunidad.</p>
                </div>

                <!-- RUTA CORREGIDA PARA EL APK -->
                <a href="styles/theme/gow/descarga/AstroIO.apk" class="download-btn" download>Descargar APK</a>
            </div>
        </div>

        <div class="qvapay-section">
            <h3>💳 Recargas y Pagos con QvaPay</h3>
            <p>Descarga la aplicación oficial de QvaPay para gestionar tus fondos, comprar recursos o adquirir mejoras en AstroIO de forma segura.</p>
            
            <a href="https://www.qvapay.com/app" target="_blank" class="qvapay-btn">Descargar App de QvaPay</a>
            
            <p style="font-size: 0.9rem; margin-top: 15px; color: #cbd5e1;">
                <strong>¡Importante!</strong> Regístrate usando nuestro enlace oficial para apoyar a AstroIO y recibir beneficios exclusivos:<br>
                <a href="https://www.qvapay.com/register/AstroIO" target="_blank" class="ref-link">https://www.qvapay.com/register/AstroIO</a>
            </p>
        </div>

        <h2 class="requirements-title">Requisitos Mínimos del Sistema</h2>

        <div class="requirements-grid">
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
                    <li>200 MN RAM (1 GB recomendado)</li>
                    <li>Espacio libre de 500 MB</li>
                    <li>No requiere tarjeta SD</li>
                </ul>
            </div>
        </div>
    </div>

</body>
</html>