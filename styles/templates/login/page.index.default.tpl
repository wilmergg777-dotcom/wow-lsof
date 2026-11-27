{block name="title" prepend}{$LNG.siteTitleIndex}{/block}
{block name="content"}
{* ============================================================
   ASTROIO v10 — LOGIN 3D (puerta de acceso al juego)
   - Escena 3D real con Three.js (scripts/login/x3d.js): estrellas,
     planeta héroe con textura real del tema, luna y planetas lejanos.
   - TODO lo funcional se conserva tal cual:
       * form#login (action + data-action) y select .changeAction
       * inputs username/password y botón #loginButton
       * alerta de error, recuperar contraseña, Discord, Facebook
       * barra de estado por universo (estado/online/24h/edad)
       * botones Registro e Imágenes del juego
   - Si no hay WebGL, el fondo clásico (.login-background) sigue visible.
   ============================================================ *}
{literal}
<style>
/* ── Capas: fondo CSS (respaldo) < canvas 3D < contenido ── */
.login-background { position: fixed; inset: 0; z-index: -1 !important; }
#login3d-canvas {
    position: fixed; inset: 0; width: 100%; height: 100%;
    z-index: 0; display: block; pointer-events: none;
}
#index #page { position: relative; z-index: 1; }
#index #content, #index .box-out, #index .box-inner,
#index td.box-out-content-center, #index td.box-inner-content-center {
    background: transparent !important;
    background-color: transparent !important;
    border: none !important;
    box-shadow: none !important;
}

/* ── Tipografía y colores de identidad ── */
#index .uxn-x3d { font-family: "Space Mono", monospace; }

/* ── Barra de estado de universos (chips HUD) ── */
.uxn-x3d .uxn_statusbar {
    display: flex; justify-content: center; align-items: stretch;
    gap: 14px; flex-wrap: wrap;
    margin: 0 auto 34px auto; padding: 0; max-width: 1350px;
}
.uxn-x3d .uxn_chip {
    position: relative;
    background: rgba(8, 13, 24, 0.72);
    border: 1px solid rgba(255, 94, 0, 0.45);
    border-radius: 14px;
    padding: 12px 18px 10px;
    display: flex; gap: 18px; align-items: center; flex-wrap: wrap;
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    box-shadow: 0 8px 28px rgba(0, 0, 0, 0.55), inset 0 1px 0 rgba(255,255,255,0.06);
    animation: uxn-aparecer 0.7s ease both;
}
.uxn-x3d .uxn_chip::before {
    content: ""; position: absolute; left: 10px; right: 10px; top: 0;
    height: 2px; border-radius: 2px;
    background: linear-gradient(90deg, transparent, rgba(255,94,0,0.85), transparent);
}
.uxn-x3d .uxn_stat { display: flex; flex-direction: column; align-items: center; gap: 3px; min-width: 58px; }
.uxn-x3d .uxn_lab { font-size: 9px; color: #8fa0b5; font-weight: 700; text-transform: uppercase; letter-spacing: 1.6px; }
.uxn-x3d .uxn_val { font-size: 14px; font-weight: 700; display: flex; align-items: center; gap: 6px; }
.uxn-x3d .uxn_green { color: #35ff8f; }
.uxn-x3d .uxn_red { color: #ff5252; }
.uxn-x3d .uxn_cyan { color: #59d6ff; }
.uxn-x3d .uxn_purple { color: #d946ef; }
.uxn-x3d .uxn_dot { width: 8px; height: 8px; border-radius: 50%; }
.uxn-x3d .uxn_dot_green { background: #35ff8f; box-shadow: 0 0 8px #35ff8f; animation: uxn-pulso 1.6s infinite; }
.uxn-x3d .uxn_dot_red { background: #ff5252; box-shadow: 0 0 8px #ff5252; }
.uxn-x3d .uxn_age { display: flex; align-items: baseline; gap: 5px; }
.uxn-x3d .uxn_age b { font-size: 20px; color: #fff; line-height: 1; }
.uxn-x3d .uxn_age small { font-size: 9px; color: #8fa0b5; letter-spacing: 1.6px; font-weight: 700; }

/* ── Contenedor de las dos tarjetas ── */
.uxn-x3d .uxn_flex_container {
    display: flex; justify-content: space-between; align-items: center;
    flex-wrap: nowrap; width: 100%; max-width: 1350px;
    margin: 0 auto; padding: 0 20px; box-sizing: border-box;
}
.uxn-x3d .uxn_flex_container .box-border {
    position: relative;
    background: rgba(8, 13, 24, 0.74);
    border: 1px solid rgba(255, 94, 0, 0.55) !important;
    border-radius: 16px !important;
    padding: 34px 38px !important;
    width: 100%; max-width: 410px;
    display: flex; flex-direction: column; justify-content: center;
    backdrop-filter: blur(14px);
    -webkit-backdrop-filter: blur(14px);
    box-shadow: 0 14px 44px rgba(0, 0, 0, 0.65), inset 0 1px 0 rgba(255,255,255,0.07);
    animation: uxn-aparecer 0.8s ease both;
}
.uxn-x3d .uxn_flex_container .box-border:nth-child(1) { animation-delay: 0.08s; }
.uxn-x3d .uxn_flex_container .box-border:nth-child(2) { animation-delay: 0.2s; }
/* esquinas estilo cabina */
.uxn-x3d .box-border::before, .uxn-x3d .box-border::after {
    content: ""; position: absolute; width: 26px; height: 26px;
    border: 2px solid #ff5e00; opacity: 0.9;
}
.uxn-x3d .box-border::before { top: -2px; left: -2px; border-right: none; border-bottom: none; border-radius: 16px 0 0 0; }
.uxn-x3d .box-border::after { bottom: -2px; right: -2px; border-left: none; border-top: none; border-radius: 0 0 16px 0; }

.uxn-x3d .uxn_flex_container p {
    font-size: 15px !important; line-height: 1.65 !important;
    color: #dbe4ef !important; margin-bottom: 24px !important; text-align: center;
}
.uxn-x3d .uxn_flex_container h1 {
    font-family: "Rajdhani", sans-serif;
    font-size: 24px !important; margin-bottom: 22px !important; text-align: center;
    color: #fff !important; text-transform: uppercase; letter-spacing: 3px;
}
.uxn-x3d .uxn_flex_container h1::after {
    content: ""; display: block; width: 70px; height: 2px; margin: 10px auto 0;
    background: linear-gradient(90deg, transparent, #ff5e00, transparent);
}

/* botones: mismos .btn, glow naranja al pasar */
.uxn-x3d .uxn_flex_container .btn {
    font-size: 15px !important; padding: 13px !important;
    border-radius: 8px !important;
    background: rgba(34, 44, 60, 0.9) !important;
    border: 1px solid rgba(255,255,255,0.16) !important;
    transition: all 0.3s ease !important;
}
.uxn-x3d .uxn_flex_container .btn:hover {
    background: rgba(46, 58, 78, 0.95) !important;
    border-color: #ff5e00 !important;
    box-shadow: 0 0 18px rgba(255, 94, 0, 0.35);
    transform: translateY(-1px);
}
.uxn-x3d #loginButton {
    background: linear-gradient(135deg, #7a2d00, #b34800) !important;
    border: 1px solid #ff5e00 !important;
    font-family: "Rajdhani", sans-serif; font-weight: 700; letter-spacing: 2px;
    text-transform: uppercase;
}
.uxn-x3d #loginButton:hover { box-shadow: 0 0 26px rgba(255, 94, 0, 0.55) !important; }

/* campos: blancos para legibilidad sobre la escena */
.uxn-x3d .uxn_flex_container .form-control, .uxn-x3d .uxn_flex_container .form-select {
    font-size: 15px !important; padding: 13px 16px !important;
    border-radius: 8px !important;
    background: rgba(255, 255, 255, 0.94) !important;
    color: #26303d !important;
    border: 1px solid rgba(255,255,255,0.3);
}
.uxn-x3d .uxn_flex_container .form-control:focus, .uxn-x3d .uxn_flex_container .form-select:focus {
    border-color: #ff5e00 !important;
    box-shadow: 0 0 0 3px rgba(255, 94, 0, 0.25) !important;
    outline: none;
}
.uxn-x3d .uxn_uni_label { color: #cfd8e3; font-size: 13px; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 6px; display: block; text-align: left; font-weight: 700; }
.uxn-x3d .alert-astrio { background: rgba(83, 6, 6, 0.7); border: 1px solid rgba(255,82,82,0.5); color: #ffd9d9; border-radius: 8px; padding: 10px 12px; font-size: 13px; margin: 0 0 15px; }
.uxn-x3d .info { text-align: center; margin: 15px 0 0; font-size: 13px; color: #8fa0b5; }
.uxn-x3d .info a { color: #00e0ff; text-decoration: none; }

/* animaciones */
@keyframes uxn-aparecer { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: none; } }
@keyframes uxn-pulso { 0% { transform: scale(0.95); } 70% { transform: scale(1.12); box-shadow: 0 0 0 6px rgba(53,255,143,0); } 100% { transform: scale(0.95); } }
@media (prefers-reduced-motion: reduce) {
    .uxn-x3d .uxn_chip, .uxn-x3d .box-border { animation: none; }
}

/* móviles: apilar centrado */
@media (max-width: 1000px) {
    .uxn-x3d .uxn_flex_container { flex-direction: column; justify-content: center; gap: 26px; }
    .uxn-x3d .uxn_flex_container .box-border { max-width: 100%; }
    .uxn-x3d .uxn_statusbar { padding: 0 10px; }
}
</style>
{/literal}

<!-- Canvas de la escena 3D (decorativo, detrás de todo el contenido) -->
<canvas id="login3d-canvas"></canvas>

<!-- Contenedor principal -->
<div class="uk-container uk-clearfix uxn-x3d" style="padding-top:24px;">

    <!-- ═══ BARRA DE ESTADO DE UNIVERSOS ═══ -->
    <div class="uxn_statusbar">
        {foreach $allUniversesStats as $uniStats}
        <div class="uxn_chip">
            <div class="uxn_stat">
                <span class="uxn_lab">ESTADO</span>
                {if isset($uniStats.isOnline) && $uniStats.isOnline === false}
                    <span class="uxn_val uxn_red"><span class="uxn_dot uxn_dot_red"></span> OFFLINE</span>
                {else}
                    <span class="uxn_val uxn_green"><span class="uxn_dot uxn_dot_green"></span> EN LÍNEA</span>
                {/if}
            </div>
            <div class="uxn_stat">
                <span class="uxn_lab">UNIVERSO</span>
                <span class="uxn_val uxn_purple">{$uniStats.name|default:'Andrómeda'}</span>
            </div>
            <div class="uxn_stat">
                <span class="uxn_lab">ONLINE</span>
                <span class="uxn_val uxn_cyan">{$uniStats.usersOnline|default:0}</span>
            </div>
            <div class="uxn_stat">
                <span class="uxn_lab">ÚLTIMAS 24H</span>
                <span class="uxn_val uxn_cyan">{$uniStats.users24h|default:0}</span>
            </div>
            <div class="uxn_stat">
                <span class="uxn_lab">EDAD DEL UNIVERSO</span>
                <div class="uxn_age"><b>{$uniStats.age|default:1}</b><small>DÍAS</small></div>
            </div>
        </div>
        {/foreach}
    </div>

    <!-- ═══ CONTENEDOR DE LAS DOS TARJETAS ═══ -->
    <div class="uxn_flex_container">

        <!-- TARJETA IZQUIERDA: Descripción y Registro -->
        <div class="box-border">
            {if !empty($descText)}
                <p>{$descText}</p>
            {else}
                <p>AstroIO es un juego de estrategia espacial en tiempo real donde cada decisión cuenta. Construye tu imperio, gestiona recursos, investiga tecnologías, forja alianzas y conquista la galaxia. Aquí la estrategia lo es todo. Solo necesitas un navegador para jugar.</p>
            {/if}

            <a class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" style="margin-bottom: 15px;" href="index.php?page=register">{$LNG.buttonRegister}</a>
            <a class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" href="index.php?page=screens">{$LNG.buttonScreenshot|default:'Imágenes del juego'}</a>
        </div>

        <!-- TARJETA DERECHA: Iniciar Sesión -->
        <div class="box-border">
            <h1>{$LNG.loginHeader}</h1>

            {if !empty($code)}
            <div class="alert-astrio">{$code}</div>
            {/if}

            <form id="login" name="login" action="index.php?page=login" data-action="index.php?page=login" method="post">
                <div class="d-flex flex-column form-group">

                    {if $isMultiUniverse}
                    <label class="uxn_uni_label" for="universe">Selecciona tu universo</label>
                    <select class="form-select my-2 w-100 changeAction" name="uni" id="universe" style="margin-bottom: 15px;">
                        {if !empty($universeSelect)}
                            {foreach $universeSelect as $uniID => $uniName}
                                <option value="{$uniID}" {if isset($UNI) && $uniID == $UNI}selected{/if}>{$uniName}</option>
                            {/foreach}
                        {else}
                            <option value="1" selected>Universo 1</option>
                        {/if}
                    </select>
                    {/if}

                    <input class="form-control fs-6 my-2 w-100" style="margin-bottom: 15px;" id="username" type="text" name="username" placeholder="{$LNG.loginUsername}" autocomplete="username">
                    <input class="form-control fs-6 my-2 w-100" style="margin-bottom: 25px;" id="password" type="password" name="password" placeholder="{$LNG.loginPassword}" autocomplete="current-password">

                    <button id="loginButton" class="hover-bg-color-grey btn bg-dark text-white w-100 my-2 fs-6" type="submit">{$LNG.loginButton}</button>

                </div>
            </form>

            {if $mailEnable}
                <a class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" style="margin-top: 15px;" href="index.php?page=lostPassword">{$LNG.buttonLostPassword}</a>
            {/if}

            {if $discordEnable}
                <a href="index.php?page=ExternalAuth&method=discord" class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" style="display:flex; align-items:center; justify-content:center; gap:8px; margin-top: 15px;">
                    <img src="styles/theme/gow/ultimate/img/social/discord-mark-white.svg" width="20px" alt=""> Entrar con Discord
                </a>
            {/if}

            {if $facebookEnable}
                <a href="#" data-href="index.php?page=externalAuth&method=facebook" class="fb_login" style="display:block; margin-top:15px; text-align:center;">
                    <img src="styles/resource/images/facebook/fb-connect-large.png" alt="Facebook" style="max-width:100%;">
                </a>
            {/if}

            <p class="info">{$loginInfo}</p>
        </div>

    </div>

    <div class="uk-clearfix" style="height: 40px;"></div>
</div>

<!-- Escena 3D: librería del proyecto + módulo propio del login -->
<script src="scripts/game/three.min.js?v={$REV}"></script>
<script src="scripts/login/x3d.js?v={$REV}"></script>

{/block}
