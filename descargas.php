<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Descarga el Cliente - AstroIO</title>

    <!-- ═══════════════════════════════════════════════════════════════
         ESTILO = MISMO QUE EL LAUNCHER OFICIAL DE PC (v2.4.13):
         fondo oscuro #0A0F1A, tarjeta #131A2A con borde #223050 y
         esquinas redondeadas, cian #00E0FF para la acción principal,
         verde #00CC66 para QvaPay, gris azulado #8FA0B8 para textos
         secundarios y botones redondeados. Misma tipografía (Segoe UI).
         Los enlaces y la estructura NO cambian: solo el diseño.
         ═══════════════════════════════════════════════════════════════ -->
    <style>
        body {
            background-color: #0A0F1A;
            background-image: radial-gradient(1200px 600px at 50% -10%, rgba(0, 224, 255, 0.07), transparent 60%);
            color: #CFE2FF;
            font-family: 'Segoe UI', system-ui, Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 1000px;
            margin: 50px auto;
            background: #131A2A;
            padding: 40px 32px;
            border-radius: 16px;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.5);
            border: 1px solid #223050;
        }

        .logo {
            width: 96px;
            height: 96px;
            display: block;
            margin: 0 auto 10px;
        }

        h1, h2, h3 {
            text-align: center;
            color: #FFFFFF;
            text-transform: uppercase;
            letter-spacing: 1.5px;
        }

        h1 { font-size: 2rem; margin: 6px 0 8px; }

        .subtitle {
            text-align: center;
            color: #8FA0B8;
            margin-bottom: 30px;
            font-size: 1.05rem;
        }

        .web-play-container {
            text-align: center;
            margin-bottom: 40px;
        }

        /* Botón principal, IGUAL que los botones cian del launcher */
        .btn-web {
            display: inline-block;
            padding: 14px 40px;
            background: #00E0FF;
            color: #04121F;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.1rem;
            border-radius: 10px;
            transition: filter 0.2s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-web:hover { filter: brightness(1.12); }

        .download-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 40px;
        }

        /* Tarjetas de descarga, IGUAL que la tarjeta del launcher */
        .download-card {
            background: #0F1626;
            border: 1px solid #223050;
            padding: 22px;
            border-radius: 14px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: border 0.2s ease;
        }

        .download-card:hover { border-color: #00E0FF; }

        .download-card h3 {
            margin-top: 0;
            font-size: 1.2rem;
            color: #00E0FF;
            margin-bottom: 15px;
        }

        .changelog {
            font-size: 0.85rem;
            color: #8FA0B8;
            line-height: 1.55;
            margin-bottom: 20px;
        }

        .changelog p { margin: 5px 0; }
        .changelog strong { color: #CFE2FF; }
        .changelog ul { margin: 5px 0 10px 20px; padding: 0; }

        .warning-text {
            color: #FBBF24;
            font-weight: 600;
            font-size: 0.8rem;
            margin-top: 10px;
            border-top: 1px dashed #2A3A5A;
            padding-top: 10px;
        }

        /* Botón de descarga: cian sólido redondeado (estilo launcher) */
        .download-btn {
            display: block;
            text-align: center;
            padding: 12px;
            background: #00E0FF;
            border: 0;
            color: #04121F;
            text-decoration: none;
            font-weight: 700;
            border-radius: 10px;
            transition: filter 0.2s ease;
            margin-top: auto;
        }

        .download-btn:hover { filter: brightness(1.12); }

        /* QvaPay: verde (el color de "Continuar"/acción segura del launcher) */
        .qvapay-section {
            background: rgba(0, 204, 102, 0.06);
            border: 1px solid #223050;
            padding: 25px;
            border-radius: 14px;
            margin-bottom: 40px;
            text-align: center;
        }

        .qvapay-section h3 { color: #00CC66; }

        .qvapay-btn {
            display: inline-block;
            padding: 12px 30px;
            background: #00CC66;
            color: #04121F;
            text-decoration: none;
            font-weight: 700;
            border-radius: 10px;
            margin: 15px 0;
            transition: filter 0.2s ease;
        }

        .qvapay-btn:hover { filter: brightness(1.12); }

        .ref-link {
            color: #00E0FF;
            font-weight: 600;
            word-break: break-all;
        }

        .requirements-title {
            text-align: left;
            border-bottom: 1px solid #223050;
            padding-bottom: 10px;
            margin-bottom: 20px;
            font-size: 1.3rem;
        }

        .requirements-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            font-size: 0.9rem;
            color: #8FA0B8;
        }

        .requirements-grid strong {
            color: #FFFFFF;
            display: block;
            margin-top: 15px;
            margin-bottom: 5px;
            font-size: 1.05rem;
        }

        .requirements-grid ul {
            margin: 0;
            padding-left: 20px;
            line-height: 1.6;
        }

        /* Pie estilo launcher */
        .pie {
            color: #44547A;
            font-size: 11px;
            text-align: center;
            margin-top: 10px;
        }

        @media (max-width: 768px) {
            .container { margin: 16px auto; padding: 24px 18px; }
            .download-grid, .requirements-grid {
                grid-template-columns: 1fr;
                gap: 16px;
            }
        }
    </style>
</head>
<body>

    <div class="container">
        <img class="logo" src="favicon.ico" alt="AstroIO">
        <h1>Descarga AstroIO</h1>
        <p class="subtitle">Elige cómo quieres conquistar la galaxia</p>

        <div class="web-play-container">
            <a href="index.php" class="btn-web">🌐 Jugar Directo en el Navegador</a>
            <p style="color: #64748B; font-size: 0.85rem; margin-top: 10px;">No necesitas descargar nada, juega al instante.</p>
        </div>

        <div class="download-grid">
            <!-- Opción PC -->
            <div class="download-card">
                <h3>💻 Launcher (PC)</h3>

                <div class="changelog">
                    <p>🚀 <strong>¡NUEVA ACTUALIZACIÓN! — Launcher v2.4.13</strong></p>
                    <p>⚙️ Versión: 2.4.13 (build 10)</p>
                    <p>🤖 Sistema: Windows</p>
                    <p>📱 Compatible: W7, W8, W8.1, W10 y W11</p>
                    <p>🛂 Desarrollo: @Holows</p>
                    <p>♻️ <strong>Errores corregidos:</strong></p>
                    <ul>
                        <li>Reconexión automática: ya no hay que dar a Reintentar varias veces.</li>
                        <li>“Sin conexión” desaparece con el servidor online.</li>
                    </ul>
                    <p class="warning-text">👀 Aviso importante: Por favor, eviten compartir este contenido. Este trabajo se hace exclusivamente para nuestra comunidad.</p>
                </div>

                <!-- Descarga SIEMPRE la versión publicada en /launcher/ (version.json) -->
                <a href="launcher/AstroIO-Launcher-windows.exe" class="download-btn" download>Descargar para Windows</a>
            </div>

            <!-- Opción Android APK -->
            <div class="download-card">
                <h3>📱 APK (Android)</h3>

                <div class="changelog">
                    <p>🚀 <strong>¡NUEVA ACTUALIZACIÓN! — APK v2.4.6</strong></p>
                    <p>⚙️ Versión: 2.4.6 (versionCode 8)</p>
                    <p>🤖 Sistema: Android</p>
                    <p>📱 Compatible: Android 5.0+</p>
                    <p>🛂 Desarrollo: @Holows</p>
                    <p>♻️ <strong>Errores corregidos:</strong></p>
                    <ul>
                        <li>Reconexión automática: la app entra sola cuando vuelve la señal.</li>
                        <li>Reintento silencioso si el juego no carga a la primera.</li>
                    </ul>
                    <p class="warning-text">👀 Aviso importante: Por favor, eviten compartir este contenido. Este trabajo se hace exclusivamente para nuestra comunidad.</p>
                </div>

                <!-- Descarga SIEMPRE la versión publicada en /apk/ (version.json) -->
                <a href="apk/AstroIO.apk" class="download-btn" download>Descargar APK</a>
            </div>
        </div>

        <div class="qvapay-section">
            <h3>💳 Recargas y Pagos con QvaPay</h3>
            <p>Descarga la aplicación oficial de QvaPay para gestionar tus fondos, comprar recursos o adquirir mejoras en AstroIO de forma segura.</p>

            <a href="https://www.qvapay.com/app" target="_blank" class="qvapay-btn">Descargar App de QvaPay</a>

            <p style="font-size: 0.9rem; margin-top: 15px; color: #CFE2FF;">
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
                    <li>200 MB RAM (1 GB recomendado)</li>
                    <li>Espacio libre de 500 MB</li>
                    <li>No requiere tarjeta SD</li>
                </ul>
            </div>
        </div>

        <div class="pie">AstroIO · Lanzador oficial del juego</div>
    </div>

</body>
</html>
