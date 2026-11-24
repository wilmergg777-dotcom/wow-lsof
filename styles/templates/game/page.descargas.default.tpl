{block name="title" prepend}Descargas - AstroIO{/block}
{block name="content"}
{literal}
<style>
/* ===== PÁGINA DE DESCARGAS DENTRO DEL JUEGO (tema AstroIO) ===== */
.dsc-container {
    max-width: 1050px;
    margin: 15px auto;
    padding: 10px;
}

.dsc-container h1 {
    text-align: center;
    color: #ffffff;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-size: 2rem;
    margin-bottom: 6px;
}

.dsc-subtitle {
    text-align: center;
    color: #94a3b8;
    margin-bottom: 25px;
    font-size: 1.05rem;
}

.dsc-subtitle strong {
    color: #4aff88;
}

.dsc-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 35px;
}

.dsc-card {
    position: relative;
    background: rgba(10, 15, 25, 0.9);
    border: 1px solid #ff5e00;
    padding: 20px;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: box-shadow 0.3s, border 0.3s;
}

.dsc-card:hover {
    box-shadow: 0 0 20px rgba(255, 94, 0, 0.3);
}

.dsc-card.dsc-reco {
    border: 2px solid #4aff88;
    box-shadow: 0 0 18px rgba(74, 255, 136, 0.25);
}

.dsc-badge {
    position: absolute;
    top: -12px;
    left: 50%;
    transform: translateX(-50%);
    background: #4aff88;
    color: #0b1120;
    font-weight: bold;
    font-size: 0.75rem;
    padding: 3px 12px;
    border-radius: 12px;
    white-space: nowrap;
}

.dsc-card h3 {
    margin-top: 0;
    font-size: 1.3rem;
    color: #00e0ff;
    margin-bottom: 12px;
    text-align: center;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.dsc-info {
    font-size: 0.9rem;
    color: #cbd5e1;
    line-height: 1.6;
    margin-bottom: 18px;
}

.dsc-info p { margin: 4px 0; }

.dsc-info strong { color: #f8fafc; }

.dsc-aviso {
    color: #fbbf24;
    font-size: 0.8rem;
    border-top: 1px dashed #475569;
    padding-top: 10px;
    margin-top: 10px;
}

.dsc-btn {
    display: block;
    text-align: center;
    padding: 13px;
    background: #222c3c;
    border: 1px solid #444;
    color: #00e0ff;
    text-decoration: none;
    font-weight: bold;
    font-size: 1.05rem;
    border-radius: 4px;
    transition: all 0.3s ease;
    margin-top: auto;
}

.dsc-btn:hover {
    background: #2e3a4e;
    border-color: #ff5e00;
    color: #fff;
    box-shadow: 0 0 15px rgba(255, 94, 0, 0.4);
}

.dsc-btn-web {
    text-align: center;
    margin-bottom: 35px;
}

.dsc-btn-web a {
    display: inline-block;
    padding: 12px 35px;
    background: #10b981;
    color: #ffffff;
    text-decoration: none;
    font-weight: bold;
    font-size: 1.05rem;
    border-radius: 5px;
    transition: all 0.3s ease;
    text-transform: uppercase;
    box-shadow: 0 0 15px rgba(16, 185, 129, 0.4);
}

.dsc-btn-web a:hover {
    background: #059669;
    box-shadow: 0 0 25px rgba(16, 185, 129, 0.8);
}

.dsc-btn-web p {
    color: #64748b;
    font-size: 0.85rem;
    margin-top: 10px;
}

.dsc-req-title {
    text-align: center;
    border-bottom: 1px solid #ff5e00;
    padding-bottom: 10px;
    margin-bottom: 20px;
    font-size: 1.4rem;
    color: #00e0ff;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.dsc-req-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 30px;
    font-size: 0.9rem;
    color: #94a3b8;
}

.dsc-req-grid strong {
    color: #f8fafc;
    display: block;
    margin-bottom: 6px;
    font-size: 1.05rem;
}

.dsc-req-grid ul {
    margin: 0;
    padding-left: 20px;
    line-height: 1.7;
}

.dsc-nota-final {
    margin-top: 30px;
    text-align: center;
    color: #94a3b8;
    font-size: 0.9rem;
    background: rgba(0, 224, 255, 0.05);
    border: 1px solid rgba(0, 224, 255, 0.35);
    border-radius: 8px;
    padding: 15px 20px;
}
</style>
{/literal}

<div class="dsc-container">
    <h1>Descarga AstroIO</h1>
    <p class="dsc-subtitle">
        Versión actual: <strong>v{$versionName}</strong> &mdash; elige tu plataforma
    </p>

    <div class="dsc-grid">
        <!-- ══════════ APK ANDROID ══════════ -->
        <div class="dsc-card {if $device == 'android'}dsc-reco{/if}">
            {if $device == 'android'}<span class="dsc-badge">Recomendado para tu móvil</span>{/if}
            <h3>APK (Android)</h3>
            <div class="dsc-info">
                <p><strong>Juego completo en tu teléfono o tablet.</strong></p>
                <p>Versión: v{$versionName}</p>
                {if $apkSize}<p>Tamaño: {$apkSize}</p>{/if}
                <p>Compatible: Android 7.0 o superior</p>
                <p class="dsc-aviso">
                    Al instalarla, el teléfono puede pedirte activar
                    "instalar apps de orígenes desconocidos". Actívalo solo
                    para esta app e instala con confianza.
                </p>
            </div>
            <a href="{$apkUrl}" class="dsc-btn" download>Descargar APK</a>
        </div>

        <!-- ══════════ LAUNCHER WINDOWS ══════════ -->
        <div class="dsc-card {if $device == 'windows'}dsc-reco{/if}">
            {if $device == 'windows'}<span class="dsc-badge">Recomendado para tu PC</span>{/if}
            <h3>Launcher (Windows)</h3>
            <div class="dsc-info">
                <p><strong>Abre el juego como una app de escritorio,</strong> sin navegador.</p>
                <p>Versión: v{$versionName}</p>
                {if $winSize}<p>Tamaño: {$winSize}</p>{/if}
                <p>Compatible: Windows 7, 8, 8.1, 10 y 11</p>
                <p class="dsc-aviso">
                    Se actualiza solo: cada vez que hay versión nueva, el
                    launcher descarga e instala la actualización al abrirlo.
                </p>
            </div>
            <a href="{$winUrl}" class="dsc-btn" download>Descargar para Windows</a>
        </div>

        <!-- ══════════ LAUNCHER LINUX ══════════ -->
        <div class="dsc-card {if $device == 'linux'}dsc-reco{/if}">
            {if $device == 'linux'}<span class="dsc-badge">Recomendado para tu PC</span>{/if}
            <h3>Launcher (Linux)</h3>
            <div class="dsc-info">
                <p><strong>Abre el juego como una app de escritorio,</strong> sin navegador.</p>
                <p>Versión: v{$versionName}</p>
                {if $linuxSize}<p>Tamaño: {$linuxSize}</p>{/if}
                <p>Compatible: la mayoría de distribuciones Linux (64 bits)</p>
                <p class="dsc-aviso">
                    Después de descargarlo, dale permiso de ejecución:
                    clic derecho &rarr; Propiedades &rarr; Permitir ejecutar,
                    o en una terminal: <strong>chmod +x AstroIO-Launcher-linux</strong>
                </p>
            </div>
            <a href="{$linuxUrl}" class="dsc-btn" download>Descargar para Linux</a>
        </div>
    </div>

    <div class="dsc-btn-web">
        <a href="game.php?page=overview">Jugar directo en el navegador</a>
        <p>Sin descargar nada: entra y juega al instante desde cualquier dispositivo.</p>
    </div>

    <h2 class="dsc-req-title">Requisitos mínimos</h2>

    <div class="dsc-req-grid">
        <div>
            <strong>Android (APK)</strong>
            <ul>
                <li>Android 7.0 o superior</li>
                <li>2 GB de RAM recomendados</li>
                <li>Espacio libre: 500 MB</li>
                <li>Conexión a internet estable</li>
            </ul>
        </div>
        <div>
            <strong>Windows (Launcher)</strong>
            <ul>
                <li>Windows 7 o superior (64 bits)</li>
                <li>2 GB de RAM recomendados</li>
                <li>Conexión a internet estable</li>
            </ul>
        </div>
        <div>
            <strong>Linux (Launcher)</strong>
            <ul>
                <li>Distribución 64 bits con glibc moderna</li>
                <li>2 GB de RAM recomendados</li>
                <li>Conexión a internet estable</li>
            </ul>
        </div>
    </div>

    <div class="dsc-nota-final">
        La APK y los launchers se actualizan automáticamente: cuando sale una
        versión nueva, la app te avisa y se actualiza sola al abrirla.
        Descarga SIEMPRE desde esta página oficial del juego.
    </div>
</div>
{/block}
