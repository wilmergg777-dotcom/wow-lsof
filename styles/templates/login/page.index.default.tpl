{block name="title" prepend}{$LNG.siteTitleIndex}{/block}
{block name="content"}
{* ============================================================
   ASTROIO v9.6 — DESTRUCCIÓN DEL RECUADRO BLANCO CENTRAL
   - Cajas grandes y separadas a los lados.
   - Eliminado el fondo blanco del contenedor central.
   ============================================================ *}
{literal}
<style>
/* =================================================================
   1. DESTRUCCIÓN TOTAL DE FONDOS BLANCOS EN EL CENTRO
   ================================================================= */
body, html, #content, .content, .uk-container, section, .astrolay_box_out, .astrolay_box_inner, .box-out-content-center, .box-inner-content-center {
    background: transparent !important;
    background-color: transparent !important;
    border: none !important;
    box-shadow: none !important;
    background-image: none !important;
}

/* 2. Barra de estado (Tus datos) */
.uxn_statusbar {
    background: rgba(10, 15, 25, 0.85) !important;
    backdrop-filter: blur(10px);
    border: 1px solid #ff5e00 !important;
    border-radius: 12px;
    padding: 12px 20px;
    margin: 0 auto 50px auto;
    max-width: 800px;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 30px;
    flex-wrap: wrap;
    font-family: "Space Mono", monospace;
    color: #fff;
    box-shadow: 0 4px 15px rgba(0,0,0,0.5) !important;
}
.uxn_uni { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; justify-content: center; }
.uxn_stat { display: flex; flex-direction: column; align-items: center; gap: 3px; min-width: 60px; }
.uxn_lab { font-size: 9px; color: #9a9a9a; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px; }
.uxn_val { font-size: 14px; font-weight: 700; display: flex; align-items: center; gap: 6px; }
.uxn_green { color: #35ff8f; }
.uxn_red { color: #ff5252; }
.uxn_cyan { color: #59d6ff; }
.uxn_purple { color: #d946ef; }
.uxn_dot { width: 8px; height: 8px; border-radius: 50%; }
.uxn_dot_green { background: #35ff8f; box-shadow: 0 0 8px #35ff8f; animation: uxn_pulse 1.5s infinite; }
.uxn_dot_red { background: #ff5252; box-shadow: 0 0 8px #ff5252; }
@keyframes uxn_pulse { 0% { transform: scale(0.95); } 70% { transform: scale(1.1); box-shadow: 0 0 0 6px rgba(53,255,143,0); } 100% { transform: scale(0.95); } }
.uxn_age { display: flex; align-items: baseline; gap: 5px; }
.uxn_age b { font-size: 20px; color: #fff; line-height: 1; }
.uxn_age small { font-size: 9px; color: #9a9a9a; letter-spacing: 1.5px; font-weight: 700; }

/* 3. CONTENEDOR CLAVE: Separación a los extremos */
.uxn_flex_container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: nowrap;
    width: 100%;
    max-width: 1350px;
    margin: 0 auto;
    padding: 0 20px;
    box-sizing: border-box;
}

/* 4. Estilos de las cajas (Grandes y con fondo oscuro) */
.uxn_flex_container .box-border {
    background: rgba(10, 15, 25, 0.9) !important;
    border: 1px solid #ff5e00 !important;
    border-radius: 12px !important;
    box-shadow: 0 10px 30px rgba(0,0,0,0.8) !important;
    padding: 35px 40px !important;
    width: 100%;
    max-width: 400px;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

/* Ajustes de texto y botones */
.uxn_flex_container p {
    font-size: 15px !important;
    line-height: 1.6 !important;
    color: #e0e0e0 !important;
    margin-bottom: 25px !important;
    text-align: center;
}

.uxn_flex_container .btn {
    font-size: 15px !important;
    padding: 14px !important;
    border-radius: 6px !important;
    background: #222c3c !important;
    border: 1px solid #444 !important;
    transition: 0.3s ease !important;
}
.uxn_flex_container .btn:hover {
    background: #2e3a4e !important;
    border-color: #ff5e00 !important;
}

.uxn_flex_container .form-control, .uxn_flex_container .form-select {
    font-size: 15px !important;
    padding: 14px 16px !important;
    border-radius: 6px !important;
    background: #fff !important;
    color: #333 !important;
}

.uxn_flex_container h1 {
    font-size: 22px !important;
    margin-bottom: 25px !important;
    text-align: center;
    color: #fff !important;
}

.alert-astrio { background: rgba(83, 6, 6, 0.65); border: 1px solid rgba(255,255,255,0.15); color: #fff; border-radius: 8px; padding: 10px; font-size: 13px; margin: 0 0 15px; }
.uxn_uni_label { color: #f2f2f2; font-size: 13px; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 8px; display: block; text-align: left; font-weight: 700; }

/* En móviles, se apilan en el centro */
@media (max-width: 1000px) {
    .uxn_flex_container {
        flex-direction: column;
        justify-content: center;
        gap: 30px;
    }
    .uxn_flex_container .box-border {
        max-width: 100%;
    }
}
</style>

<script>
// 5. FRANCOTIRADOR JAVASCRIPT: Elimina cualquier recuadro blanco residual
document.addEventListener("DOMContentLoaded", function() {
    // Buscamos todos los elementos que puedan tener fondo blanco
    var elements = document.querySelectorAll('div, section, table, td');
    
    elements.forEach(function(el) {
        // Obtenemos el color de fondo computado
        var bgColor = window.getComputedStyle(el).backgroundColor;
        
        // Si el fondo es blanco o un gris muy claro (rgb(255,255,255) o similar)
        if (bgColor === 'rgb(255, 255, 255)' || bgColor === 'rgba(255, 255, 255, 1)' || bgColor === 'rgb(240, 240, 240)') {
            // Lo destruimos
            el.style.setProperty('background', 'transparent', 'important');
            el.style.setProperty('background-color', 'transparent', 'important');
            el.style.setProperty('border', 'none', 'important');
            el.style.setProperty('box-shadow', 'none', 'important');
        }
    });
});
</script>
{/literal}

<!-- Contenedor principal -->
<div class="uk-container uk-clearfix" style="padding-top:20px; background: transparent !important; border: none !important; box-shadow: none !important;">

<!-- ═══ BARRA DE ESTADO DE UNIVERSOS ═══ -->
<div class="uxn_statusbar">
    {foreach $allUniversesStats as $uniStats}
    <div class="uxn_uni">
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

<!-- ═══ CONTENEDOR DE LAS DOS CAJAS ═══ -->
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

                <input class="form-control fs-6 my-2 w-100" style="margin-bottom: 15px;" id="username" type="text" name="username" placeholder="{$LNG.loginUsername}">
                <input class="form-control fs-6 my-2 w-100" style="margin-bottom: 25px;" id="password" type="password" name="password" placeholder="{$LNG.loginPassword}">

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

        <p class="info" style="text-align:center; margin:15px 0 0; font-size:13px; color:#9a9a9a;">{$loginInfo}</p>
    </div>

</div>

<div class="uk-clearfix"></div>
</div>

{/block}