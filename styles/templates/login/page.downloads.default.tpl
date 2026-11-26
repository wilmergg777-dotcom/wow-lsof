{block name="title" prepend}Descargas - AstroIO{/block}
{block name="content"}
{* ═════════════════════════════════════════════════════════════════
   PÁGINA DE DESCARGAS (PORTADA / LOGIN) — AstroIO
   ═════════════════════════════════════════════════════════════════
   Esta página le muestra al visitante TODAS las formas de jugar:

     1) Jugar directo en el navegador (sin instalar nada)
     2) Launcher para Windows — SETUP recomendado (instala todo:
        ventana propia con WebView2, imágenes del juego dentro para
        que no gasten datos, accesos directos y desinstalador).
        También se ofrece el launcher portable sin instalar.
     3) Launcher para Linux — se instala con instalar-linux.sh
        (copia el juego a ~/.local/bin, pone el icono y crea las
        entradas "AstroIO" y "AstroIO - Borrar datos" en el menú)
     4) APK para Android (se auto-actualiza igual que la APK móvil)

   NOTAS DE MANTENIMIENTO (leer antes de editar):
   - ✅ Las versiones y URLs salen DIRECTO de apk/version.json: esta
     página las recibe de ShowDownloadsPage.class.php
     (includes/pages/login/), que lee el JSON en cada render — IGUAL
     que la página de descargas del juego (ShowDescargasPage +
     styles/templates/game/page.descargas.default.tpl). Las dos
     trabajan a la par: al subir versión nueva NO hay que tocar
     nada aquí, el workflow regenera version.json y las dos
     páginas muestran lo publicado.
   - El Setup y los launchers llevan DENTRO las imágenes del juego
     (~130 MB): por eso pesan eso y por eso NO gastan datos al jugar.
   - Los colores del tema: naranja #ff5e00, cian #00e0ff,
     verde #4aff88 / #10b981, fondo de tarjeta rgba(10,15,25,.9).
   ═════════════════════════════════════════════════════════════════ *}

{* El CSS va dentro de {literal} para que Smarty no interprete
   las llaves { } del código de estilos. *}
{literal}
<style>
/* ═══════════════ CONTENEDOR GENERAL ═══════════════ */
.dl-page {
    max-width: 1050px;
    margin: 20px auto;
    padding: 10px;
}

/* Títulos: blanco, en mayúsculas, con espaciado de letras */
.dl-page h1,
.dl-page h2,
.dl-page h3 {
    text-align: center;
    color: #ffffff;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.dl-page h1 {
    font-size: 2.2rem;
    margin-bottom: 8px;
}

/* Subtítulo bajo el título principal */
.dl-subtitle {
    text-align: center;
    color: #94a3b8;
    margin-bottom: 25px;
    font-size: 1.1rem;
}

/* ═══════════════ BOTÓN "JUGAR EN EL NAVEGADOR" ═══════════════
   Verde con brillo: es la vía más rápida para probar el juego. */
.dl-web {
    text-align: center;
    margin-bottom: 35px;
}

.dl-btn-web {
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

.dl-btn-web:hover {
    background: #059669;
    box-shadow: 0 0 25px rgba(16, 185, 129, 0.8);
    transform: translateY(-2px);
}

.dl-web small {
    display: block;
    margin-top: 10px;
    color: #64748b;
    font-size: 0.85rem;
}

/* ═══════════════ TARJETAS DE DESCARGA ═══════════════
   Rejilla responsive: 3 columnas en PC, 1 columna en móvil. */
.dl-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
}

.dl-card {
    position: relative;                 /* para el badge "Recomendado" */
    background: rgba(10, 15, 25, 0.9);
    border: 1px solid #ff5e00;
    padding: 20px;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: box-shadow 0.3s, border 0.3s;
}

.dl-card:hover {
    box-shadow: 0 0 20px rgba(255, 94, 0, 0.3);
}

/* Tarjeta destacada (borde y brillo verdes + badge flotante) */
.dl-card.dl-reco {
    border: 2px solid #4aff88;
    box-shadow: 0 0 18px rgba(74, 255, 136, 0.25);
}

.dl-badge {
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

.dl-card h3 {
    margin-top: 0;
    font-size: 1.25rem;
    color: #00e0ff;
    margin-bottom: 14px;
}

/* Texto informativo dentro de cada tarjeta */
.dl-info {
    font-size: 0.9rem;
    color: #cbd5e1;
    line-height: 1.6;
    margin-bottom: 16px;
}

.dl-info p { margin: 4px 0; }

.dl-info strong { color: #f8fafc; }

.dl-info ul {
    margin: 6px 0;
    padding-left: 20px;
    color: #94a3b8;
}

/* Aviso amarillo al pie de la tarjeta */
.dl-aviso {
    color: #fbbf24;
    font-size: 0.8rem;
    border-top: 1px dashed #475569;
    padding-top: 10px;
    margin-top: 10px;
}

/* Botón de descarga de cada tarjeta */
.dl-btn {
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

.dl-btn:hover {
    background: #2e3a4e;
    border-color: #ff5e00;
    color: #fff;
    box-shadow: 0 0 15px rgba(255, 94, 0, 0.4);
}

/* Botón secundario (menos importante, ej. launcher portable) */
.dl-btn-sec {
    display: block;
    text-align: center;
    padding: 9px;
    margin-top: 8px;
    background: transparent;
    border: 1px dashed #475569;
    color: #94a3b8;
    text-decoration: none;
    font-size: 0.85rem;
    border-radius: 4px;
    transition: all 0.3s ease;
}

.dl-btn-sec:hover {
    border-color: #00e0ff;
    color: #00e0ff;
}

/* Pasos numerados para la instalación en Linux */
.dl-pasos {
    counter-reset: paso;
    list-style: none;
    padding-left: 0;
    margin: 8px 0;
}

.dl-pasos li {
    counter-increment: paso;
    margin: 7px 0;
    padding-left: 34px;
    position: relative;
    color: #cbd5e1;
    font-size: 0.88rem;
    line-height: 1.5;
}

/* El número del paso va en un circulito cian */
.dl-pasos li::before {
    content: counter(paso);
    position: absolute;
    left: 0;
    top: 0;
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: #00e0ff;
    color: #0b1120;
    font-weight: bold;
    font-size: 0.8rem;
    text-align: center;
    line-height: 22px;
}

.dl-pasos code {
    background: rgba(0, 224, 255, 0.08);
    border: 1px solid rgba(0, 224, 255, 0.3);
    border-radius: 4px;
    padding: 1px 6px;
    color: #00e0ff;
    font-size: 0.82rem;
    word-break: break-all;
}

/* ═══════════════ BLOQUE QVAPAY ═══════════════ */
.dl-qvapay {
    background: rgba(0, 224, 255, 0.05);
    border: 1px solid #00e0ff;
    padding: 25px;
    border-radius: 8px;
    margin-bottom: 40px;
    text-align: center;
}

.dl-qvapay h3 { color: #00e0ff; }

.dl-qvapay p {
    color: #cbd5e1;
    margin: 8px 0;
}

.dl-qvapay-btn {
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

.dl-qvapay-btn:hover { background: #7dd3fc; }

/* Enlace de referido destacado */
.dl-ref {
    color: #fbbf24;
    font-weight: bold;
    word-break: break-all;
}

/* ═══════════════ REQUISITOS MÍNIMOS ═══════════════ */
.dl-req-title {
    text-align: center;
    border-bottom: 1px solid #ff5e00;
    padding-bottom: 10px;
    margin-bottom: 20px;
    font-size: 1.4rem;
    color: #00e0ff;
}

.dl-req-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 30px;
    font-size: 0.9rem;
    color: #94a3b8;
}

.dl-req-grid strong {
    color: #f8fafc;
    display: block;
    margin-bottom: 6px;
    font-size: 1.05rem;
}

.dl-req-grid ul {
    margin: 0;
    padding-left: 20px;
    line-height: 1.7;
}

/* ═══════════════ NOTA FINAL ═══════════════ */
.dl-nota-final {
    margin-top: 30px;
    text-align: center;
    color: #94a3b8;
    font-size: 0.9rem;
    background: rgba(0, 224, 255, 0.05);
    border: 1px solid rgba(0, 224, 255, 0.35);
    border-radius: 8px;
    padding: 15px 20px;
    line-height: 1.6;
}

/* ═══════════════ MÓVIL ═══════════════
   En pantallas pequeñas todo baja a una sola columna. */
@media (max-width: 640px) {
    .dl-page h1 { font-size: 1.7rem; }
    .dl-btn-web { padding: 13px 24px; font-size: 1.05rem; }
}
</style>
{/literal}

<div class="dl-page">
    <h1>Descarga AstroIO</h1>
    <p class="dl-subtitle">
        Conquista la galaxia desde donde quieras: navegador, PC o móvil
    </p>

    {* ─── 1) JUGAR DIRECTO (sin instalar nada) ─── *}
    <div class="dl-web">
        <a href="index.php" class="dl-btn-web">🌐 Jugar directo en el navegador</a>
        <small>Sin descargar nada: crea tu cuenta y juega al instante.</small>
    </div>

    <div class="dl-grid">

        {* ─── 2) WINDOWS: SETUP RECOMENDADO ───
           El Setup es la forma completa de instalar en Windows:
           copia el juego, instala el componente de ventana
           (WebView2) si falta, crea los accesos directos en
           Escritorio y menú Inicio, y añade "Borrar datos" y
           "Desinstalar". Lleva las imágenes del juego dentro. *}
        <div class="dl-card dl-reco">
            <span class="dl-badge">⭐ Recomendado en Windows</span>
            <h3>💻 Windows — Instalador</h3>
            <div class="dl-info">
                <p><strong>Instalador completo del juego</strong> (Setup).</p>
                <p>⚙️ Versión: <strong>v{$winVersion}</strong>{if $setupSize} &middot; Tamaño: {$setupSize}{else} &middot; Tamaño: ~136 MB{/if}</p>
                <p>🖥️ Compatible: Windows 10 y 11 (64 bits)</p>
                <p>🗒 Qué hace al instalarlo:</p>
                <ul>
                    <li>Abre el juego en <strong>ventana propia</strong> (sin navegador).</li>
                    <li>Lleva las <strong>imágenes del juego dentro</strong>: no gastan datos.</li>
                    <li>Crea accesos directos en Escritorio y menú Inicio.</li>
                    <li>Añade <strong>"AstroIO - Borrar datos"</strong> (sesión, caché y ajustes) y <strong>"Desinstalar AstroIO"</strong>.</li>
                </ul>
                <p class="dl-aviso">
                    👀 La primera vez puede salir el aviso azul de SmartScreen
                    ("Windows protegió tu PC"): pulsa <strong>Más información
                    → Ejecutar de todas formas</strong>. Es normal porque el
                    instalador no está firmado con certificado de pago.
                </p>
            </div>
            <a href="{$setupUrl}" class="dl-btn" download>Descargar instalador (Setup)</a>
            <a href="{$winUrl}" class="dl-btn-sec" download>Alternativa: launcher portable sin instalar{if $winSize} ({$winSize}){else} (132 MB){/if}</a>
        </div>

        {* ─── 3) LINUX: BINARIO + INSTALADOR ───
           En Linux se descargan DOS archivos a la MISMA carpeta y
           se ejecuta instalar-linux.sh: él solo copia el juego a
           ~/.local/bin, instala el icono y crea las entradas del
           menú de aplicaciones. Sin permisos de administrador. *}
        <div class="dl-card">
            <h3>🐧 Linux (64 bits)</h3>
            <div class="dl-info">
                <p><strong>Launcher oficial de AstroIO</strong>.</p>
                <p>⚙️ Versión: <strong>v{$linuxVersion}</strong>{if $linuxSize} &middot; Tamaño: {$linuxSize}{else} &middot; Tamaño: ~131 MB{/if}</p>
                <p>🗒 Instalación en 3 pasos:</p>
                <ol class="dl-pasos">
                    <li>Descarga <strong>los 2 archivos</strong> a la misma carpeta (ej. Descargas).</li>
                    <li>Abre una terminal en esa carpeta.</li>
                    <li>Ejecuta <code>bash instalar-linux.sh</code></li>
                </ol>
                <p>Después abre <strong>"AstroIO"</strong> en el menú de aplicaciones (categoría Juegos), con ventana propia, imágenes dentro y su entrada <strong>"Borrar datos"</strong>.</p>
                <p class="dl-aviso">
                    No hace falta dar permisos de administrador: se instala
                    por usuario. El launcher se auto-actualiza al abrirse.
                </p>
            </div>
            <a href="{$linuxUrl}" class="dl-btn" download>1) Descargar el juego (Linux)</a>
            <a href="{$linuxShUrl}" class="dl-btn-sec" download>2) Descargar instalar-linux.sh{if $linuxShSize} ({$linuxShSize}){/if}</a>
        </div>

        {* ─── 4) ANDROID: APK ─── *}
        <div class="dl-card">
            <h3>📱 Android (APK)</h3>
            <div class="dl-info">
                <p><strong>Juego completo en tu teléfono o tablet.</strong></p>
                <p>⚙️ Versión: <strong>v{$apkVersion}</strong>{if $apkSize} &middot; Tamaño: {$apkSize}{else} &middot; Tamaño: ~131 MB{/if}</p>
                <p>📱 Compatible: Android 7.0 o superior</p>
                <p>🗒 Se actualiza sola: al abrirse comprueba si hay versión
                   nueva y la instala sin que hagas nada.</p>
                <p class="dl-aviso">
                    👀 Si el teléfono pide activar "instalar apps de orígenes
                    desconocidos", actívalo solo para instalar esta app.
                </p>
            </div>
            <a href="{$apkUrl}" class="dl-btn" download>Descargar APK</a>
        </div>

    </div>

    {* ─── BLOQUE QVAPAY (recargas y pagos) ─── *}
    <div class="dl-qvapay">
        <h3>💳 Recargas y Pagos con QvaPay</h3>
        <p>
            Descarga la aplicación oficial de QvaPay para gestionar tus
            fondos, comprar recursos o adquirir mejoras en AstroIO de forma segura.
        </p>
        <a href="https://www.qvapay.com/app" target="_blank" rel="noopener" class="dl-qvapay-btn">Descargar App de QvaPay</a>
        <p>
            <strong>¡Importante!</strong> Regístrate usando nuestro enlace
            oficial para apoyar a AstroIO y recibir beneficios exclusivos:<br>
            <a href="https://www.qvapay.com/register/AstroIO" target="_blank" rel="noopener" class="dl-ref">https://www.qvapay.com/register/AstroIO</a>
        </p>
    </div>

    {* ─── REQUISITOS MÍNIMOS ─── *}
    <h2 class="dl-req-title">Requisitos mínimos del sistema</h2>

    <div class="dl-req-grid">
        <div>
            <strong>Windows (instalador / launcher)</strong>
            <ul>
                <li>Windows 10 u 11 (64 bits)</li>
                <li>Procesador Intel/AMD de doble núcleo</li>
                <li>2 GB de RAM recomendados</li>
                <li>~400 MB de espacio libre</li>
                <li>Conexión a internet estable</li>
            </ul>
        </div>
        <div>
            <strong>Linux (launcher)</strong>
            <ul>
                <li>Distribución 64 bits con glibc moderna</li>
                <li>Chromium, Chrome, Edge o Brave instalado</li>
                <li>2 GB de RAM recomendados</li>
                <li>~400 MB de espacio libre</li>
                <li>Conexión a internet estable</li>
            </ul>
        </div>
        <div>
            <strong>Android (APK)</strong>
            <ul>
                <li>Android 7.0 o superior</li>
                <li>Procesador ARM de 64 bits</li>
                <li>2 GB de RAM recomendados</li>
                <li>Espacio libre de 500 MB</li>
                <li>Conexión a internet estable</li>
            </ul>
        </div>
    </div>

    <div class="dl-nota-final">
        Todos los lanzadores y la APK <strong>se auto-actualizan solos</strong>:
        al abrirse comprueban la versión y descargan la nueva si existe.
        Los instaladores de PC ya traen las imágenes del juego dentro,
        así que <strong>jugar no gasta datos de imágenes</strong>.
        Descarga SIEMPRE desde esta página oficial del juego.
    </div>
</div>
{/block}
