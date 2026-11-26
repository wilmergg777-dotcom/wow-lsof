{* Eliminado {extends file="layout.normal.tpl"} para que use el layout del juego (menú y recursos) *}
{block name="content"}
{literal}
<style>
/* ═══════════════════════════════════════════════════════════
   ASTROIO v2.4.11 — PÁGINA DE DESCARGAS
   Estilo unificado (look Banco de Alianza: vidrio navy + cian)
   Usa los componentes .aui_* de astroio-ui.css

   ✅ Las versiones y URLs salen DIRECTO de apk/version.json
      (ShowDescargasPage las asigna, igual que la página del login)
   ═══════════════════════════════════════════════════════════ */
body#descargas #content { color:#cbd5e1; }

.dsc_wrap { max-width: 1050px; margin: 0 auto; padding: 4px 6px 24px; }

/* ── TARJETAS DE DESCARGA ── */
.dsc_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 14px;
    margin-bottom: 20px;
}
.dsc-card {
    position: relative;
    background: linear-gradient(160deg, rgba(15,23,42,.75), rgba(9,14,26,.85));
    border: 1px solid rgba(30,41,59,.9);
    padding: 20px;
    border-radius: 13px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: transform .18s ease, border-color .18s ease, box-shadow .18s ease;
}
.dsc-card:hover {
    transform: translateY(-3px);
    border-color: rgba(0,224,255,.4);
    box-shadow: 0 8px 22px rgba(0,0,0,.4);
}
.dsc-card.dsc-reco {
    border: 2px solid rgba(102,255,153,.55);
    box-shadow: 0 0 18px rgba(102,255,153,.18);
}
.dsc-badge {
    position: absolute;
    top: -12px;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(17,136,51,.95);
    border: 1px solid rgba(102,255,153,.5);
    color: #8affb4;
    font-weight: 700;
    font-size: 0.72rem;
    padding: 3px 12px;
    border-radius: 999px;
    white-space: nowrap;
}
.dsc-card h3 {
    margin-top: 0;
    font-size: 1.1rem;
    color: #fff;
    margin-bottom: 12px;
    text-align: center;
    text-transform: uppercase;
    letter-spacing: 1px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    text-shadow: 0 1px 3px rgba(0,0,0,.6);
}
.dsc-card h3 i { color: #00e0ff; font-size: 1.2rem; }
.dsc-info {
    font-size: 0.9rem;
    color: #cbd5e1;
    line-height: 1.6;
    margin-bottom: 18px;
}
.dsc-info p { margin: 4px 0; }
.dsc-info strong { color: #f8fafc; }
.dsc-info ul {
    margin: 6px 0;
    padding-left: 18px;
    color: #94a3b8;
}
.dsc-aviso {
    color: #ffcc44;
    font-size: 0.78rem;
    border-top: 1px dashed rgba(30,41,59,.9);
    padding-top: 10px;
    margin-top: 10px;
}

/* ── BOTONES DE DESCARGA (estilo Banco) ── */
.dsc-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    text-align: center;
    padding: 12px;
    background: linear-gradient(135deg, rgba(0,90,160,.95), rgba(0,140,220,.9));
    border: 1px solid rgba(0,224,255,.45);
    color: #fff;
    text-decoration: none;
    font-weight: 800;
    font-size: 0.95rem;
    letter-spacing: .6px;
    text-transform: uppercase;
    border-radius: 10px;
    transition: all .2s ease;
    margin-top: auto;
}
.dsc-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 16px rgba(0,140,220,.4);
    color: #fff;
}

/* Botón secundario: alternativa menos importante (launcher portable
   o instalar-linux.sh). Mismo lenguaje visual, más discreto. */
.dsc-btn-sec {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    text-align: center;
    padding: 10px;
    margin-top: 8px;
    background: transparent;
    border: 1px dashed rgba(0,224,255,.45);
    color: #8fd8ff;
    text-decoration: none;
    font-size: 0.85rem;
    border-radius: 10px;
    transition: all .2s ease;
}
.dsc-btn-sec:hover {
    border-color: rgba(0,224,255,.9);
    color: #fff;
}

/* ── PASOS NUMERADOS (instalación Linux) ── */
.dsc-pasos {
    counter-reset: paso;
    list-style: none;
    padding-left: 0;
    margin: 8px 0;
}
.dsc-pasos li {
    counter-increment: paso;
    margin: 7px 0;
    padding-left: 34px;
    position: relative;
    color: #cbd5e1;
    font-size: 0.88rem;
    line-height: 1.5;
}
.dsc-pasos li::before {
    content: counter(paso);
    position: absolute;
    left: 0;
    top: 0;
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: rgba(0,224,255,.9);
    color: #04121f;
    font-weight: 700;
    font-size: 0.8rem;
    text-align: center;
    line-height: 22px;
}
.dsc-pasos code {
    background: rgba(0,224,255,.08);
    border: 1px solid rgba(0,224,255,.3);
    border-radius: 4px;
    padding: 1px 6px;
    color: #00e0ff;
    font-size: 0.82rem;
    word-break: break-all;
}

/* ── BOTÓN JUGAR EN NAVEGADOR ── */
.dsc-btn-web { text-align: center; margin-bottom: 24px; }
.dsc-btn-web a {
    display: inline-flex;
    align-items: center;
    gap: 9px;
    padding: 12px 32px;
    background: linear-gradient(135deg, rgba(17,136,51,.95), rgba(34,204,102,.9));
    border: 1px solid rgba(102,255,153,.5);
    color: #fff;
    text-decoration: none;
    font-weight: 800;
    font-size: 0.95rem;
    letter-spacing: .6px;
    text-transform: uppercase;
    border-radius: 10px;
    transition: all .2s ease;
    box-shadow: 0 4px 14px rgba(34,204,102,.3);
}
.dsc-btn-web a:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 18px rgba(34,204,102,.45);
    color: #fff;
}
.dsc-btn-web p {
    color: #64748b;
    font-size: 0.85rem;
    margin-top: 10px;
}

/* ── REQUISITOS ── */
.dsc_req_box {
    background: linear-gradient(170deg, rgba(11,20,36,.8), rgba(7,13,25,.88));
    border: 1px solid rgba(30,41,59,.95);
    border-radius: 14px;
    padding: 18px 20px;
    box-shadow: 0 6px 20px rgba(0,0,0,.35);
}
.dsc_req_title {
    font-size: 13px;
    font-weight: 800;
    color: #fff;
    letter-spacing: .5px;
    margin-bottom: 14px;
    display: flex;
    align-items: center;
    gap: 8px;
    border-bottom: 1px solid rgba(0,224,255,.22);
    padding-bottom: 10px;
}
.dsc_req_title i { color: #00e0ff; }
.dsc-req-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 24px;
    font-size: 0.88rem;
    color: #94a3b8;
}
.dsc-req-grid strong {
    color: #00e0ff;
    display: flex;
    align-items: center;
    gap: 7px;
    margin-bottom: 8px;
    font-size: 0.95rem;
}
.dsc-req-grid ul {
    margin: 0;
    padding-left: 18px;
    line-height: 1.7;
}

/* ── NOTA FINAL ── */
.dsc-nota-final {
    margin-top: 18px;
    padding: 11px 15px;
    border-radius: 11px;
    font-size: 11.5px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 9px;
    background: rgba(0,68,136,.16);
    border: 1px solid rgba(0,224,255,.4);
    color: #a8e6ff;
}

@media (max-width: 760px) {
    .dsc_grid { grid-template-columns: 1fr; }
    .dsc-req-grid { grid-template-columns: 1fr; gap: 14px; }
}
</style>
{/literal}

<div class="dsc_wrap">

    {* ══════════ HERO (estilo unificado Banco) ══════════ *}
    <div class="aui_hero">
        <div class="aui_hero_row">
            <div class="aui_hero_icon"><i class="fas fa-download"></i></div>
            <div class="aui_hero_title">
                <h2>DESCARGA ASTROIO</h2>
                <div class="sub">Versi&oacute;n del juego: <b>v{$apkVersion}</b> &mdash; elige tu plataforma</div>
                <div class="aui_chips">
                    {if $device == 'android'}
                        <span class="aui_chip green"><i class="fab fa-android"></i> Detectado: <b>m&oacute;vil Android</b></span>
                    {elseif $device == 'windows'}
                        <span class="aui_chip green"><i class="fab fa-windows"></i> Detectado: <b>PC Windows</b></span>
                    {elseif $device == 'linux'}
                        <span class="aui_chip green"><i class="fab fa-linux"></i> Detectado: <b>PC Linux</b></span>
                    {else}
                        <span class="aui_chip"><i class="fas fa-globe"></i> Dispositivo: <b>otro</b></span>
                    {/if}
                    <span class="aui_chip"><i class="fas fa-sync-alt"></i> <b>Auto-actualizable</b></span>
                </div>
            </div>
        </div>
    </div>

    <div class="dsc_grid">
        <!-- ══════════ APK ANDROID ══════════ -->
        <div class="dsc-card {if $device == 'android'}dsc-reco{/if}">
            {if $device == 'android'}<span class="dsc-badge"><i class="fas fa-check-circle"></i> Recomendado para tu m&oacute;vil</span>{/if}
            <h3><i class="fab fa-android"></i> APK (Android)</h3>
            <div class="dsc-info">
                <p><strong>Juego completo en tu tel&eacute;fono o tablet.</strong></p>
                <p>Versi&oacute;n: <strong>v{$apkVersion}</strong>{if $apkSize} &middot; Tama&ntilde;o: {$apkSize}{/if}</p>
                <p>Compatible: Android 7.0 o superior</p>
                <p>Se actualiza sola: al abrirse comprueba si hay versi&oacute;n
                   nueva y la instala sin que hagas nada.</p>
                <p class="dsc-aviso">
                    Al instalarla, el tel&eacute;fono puede pedirte activar
                    "instalar apps de or&iacute;genes desconocidos". Act&iacute;valo solo
                    para esta app e instala con confianza.
                </p>
            </div>
            <a href="{$apkUrl}" class="dsc-btn" download><i class="fas fa-download"></i> Descargar APK</a>
        </div>

        <!-- ══════════ WINDOWS: SETUP RECOMENDADO + PORTABLE ══════════
             El Setup es la forma completa de instalar en Windows: copia el
             juego, instala el componente de ventana (WebView2) si falta,
             crea los accesos directos y a&ntilde;ade "Borrar datos" y
             "Desinstalar". Lleva las im&aacute;genes del juego dentro.
             El launcher portable es la alternativa sin instalar nada. -->
        <div class="dsc-card {if $device == 'windows'}dsc-reco{/if}">
            {if $device == 'windows'}<span class="dsc-badge"><i class="fas fa-check-circle"></i> Recomendado para tu PC</span>{/if}
            <h3><i class="fab fa-windows"></i> Windows — Instalador</h3>
            <div class="dsc-info">
                <p><strong>Instalador completo del juego</strong> (Setup).</p>
                <p>Versi&oacute;n: <strong>v{$winVersion}</strong>{if $setupSize} &middot; Tama&ntilde;o: {$setupSize}{/if}</p>
                <p>Compatible: Windows 10 y 11 (64 bits)</p>
                <p>Qu&eacute; hace al instalarlo:</p>
                <ul>
                    <li>Abre el juego en <strong>ventana propia</strong> (sin navegador).</li>
                    <li>Lleva las <strong>im&aacute;genes del juego dentro</strong>: no gastan datos.</li>
                    <li>Crea accesos directos en Escritorio y men&uacute; Inicio.</li>
                    <li>A&ntilde;ade <strong>"AstroIO - Borrar datos"</strong> (sesi&oacute;n, cach&eacute; y ajustes) y <strong>"Desinstalar AstroIO"</strong>.</li>
                </ul>
                <p class="dsc-aviso">
                    👀 La primera vez puede salir el aviso azul de SmartScreen
                    ("Windows protegi&oacute; tu PC"): pulsa <strong>M&aacute;s informaci&oacute;n
                    &rarr; Ejecutar de todas formas</strong>. Es normal porque el
                    instalador no est&aacute; firmado con certificado de pago.
                </p>
            </div>
            <a href="{$setupUrl}" class="dsc-btn" download><i class="fas fa-download"></i> Descargar instalador (Setup)</a>
            <a href="{$winUrl}" class="dsc-btn-sec" download><i class="fas fa-file-archive"></i> Alternativa: launcher portable sin instalar{if $winSize} ({$winSize}){/if}</a>
        </div>

        <!-- ══════════ LINUX: BINARIO + INSTALADOR ══════════
             En Linux se descargan DOS archivos a la MISMA carpeta y se
             ejecuta instalar-linux.sh: &eacute;l solo copia el juego a
             ~/.local/bin, instala el icono y crea las entradas del men&uacute;
             de aplicaciones. Sin permisos de administrador. -->
        <div class="dsc-card {if $device == 'linux'}dsc-reco{/if}">
            {if $device == 'linux'}<span class="dsc-badge"><i class="fas fa-check-circle"></i> Recomendado para tu PC</span>{/if}
            <h3><i class="fab fa-linux"></i> Linux (64 bits)</h3>
            <div class="dsc-info">
                <p><strong>Launcher oficial de AstroIO</strong>.</p>
                <p>Versi&oacute;n: <strong>v{$linuxVersion}</strong>{if $linuxSize} &middot; Tama&ntilde;o: {$linuxSize}{/if}</p>
                <p>Instalaci&oacute;n en 3 pasos:</p>
                <ol class="dsc-pasos">
                    <li>Descarga <strong>los 2 archivos</strong> a la misma carpeta (ej. Descargas).</li>
                    <li>Abre una terminal en esa carpeta.</li>
                    <li>Ejecuta <code>bash instalar-linux.sh</code></li>
                </ol>
                <p>Despu&eacute;s abre <strong>"AstroIO"</strong> en el men&uacute; de aplicaciones (categor&iacute;a Juegos), con ventana propia, im&aacute;genes dentro y su entrada <strong>"Borrar datos"</strong>.</p>
                <p class="dsc-aviso">
                    No hace falta dar permisos de administrador: se instala
                    por usuario. El launcher se auto-actualiza al abrirse.
                </p>
            </div>
            <a href="{$linuxUrl}" class="dsc-btn" download><i class="fas fa-download"></i> 1) Descargar el juego (Linux)</a>
            <a href="{$linuxShUrl}" class="dsc-btn-sec" download><i class="fas fa-terminal"></i> 2) Descargar instalar-linux.sh{if $linuxShSize} ({$linuxShSize}){/if}</a>
        </div>
    </div>

    <div class="dsc-btn-web">
        <a href="game.php?page=overview"><i class="fas fa-play-circle"></i> Jugar directo en el navegador</a>
        <p>Sin descargar nada: entra y juega al instante desde cualquier dispositivo.</p>
    </div>

    <div class="dsc_req_box">
        <div class="dsc_req_title"><i class="fas fa-info-circle"></i> Requisitos m&iacute;nimos</div>
        <div class="dsc-req-grid">
            <div>
                <strong><i class="fab fa-android"></i> Android (APK)</strong>
                <ul>
                    <li>Android 7.0 o superior</li>
                    <li>2 GB de RAM recomendados</li>
                    <li>Espacio libre: 500 MB</li>
                    <li>Conexi&oacute;n a internet estable</li>
                </ul>
            </div>
            <div>
                <strong><i class="fab fa-windows"></i> Windows (instalador / launcher)</strong>
                <ul>
                    <li>Windows 10 u 11 (64 bits)</li>
                    <li>Procesador Intel/AMD de doble n&uacute;cleo</li>
                    <li>2 GB de RAM recomendados</li>
                    <li>~400 MB de espacio libre</li>
                    <li>Conexi&oacute;n a internet estable</li>
                </ul>
            </div>
            <div>
                <strong><i class="fab fa-linux"></i> Linux (launcher)</strong>
                <ul>
                    <li>Distribuci&oacute;n 64 bits con glibc moderna</li>
                    <li>Chromium, Chrome, Edge o Brave instalado</li>
                    <li>2 GB de RAM recomendados</li>
                    <li>~400 MB de espacio libre</li>
                    <li>Conexi&oacute;n a internet estable</li>
                </ul>
            </div>
        </div>
    </div>

    <div class="dsc-nota-final">
        <i class="fas fa-sync-alt"></i>
        <span>La APK y los launchers se actualizan autom&aacute;ticamente: cuando sale una
        versi&oacute;n nueva, la app te avisa (Continuar / Actualizar con barra de progreso)
        y se actualiza sola al abrirla. Los instaladores de PC ya traen las
        im&aacute;genes del juego dentro, as&iacute; que jugar no gasta datos de im&aacute;genes.
        Descarga SIEMPRE desde esta p&aacute;gina oficial del juego.</span>
    </div>
</div>
{/block}
