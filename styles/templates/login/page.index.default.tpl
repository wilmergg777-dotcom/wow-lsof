{block name="title" prepend}{$LNG.siteTitleIndex}{/block}
{block name="content"}
{* ============================================================
   ASTROIO v4.1 — CLON EXACTO del índice de Ultimate XNOVA
   (https://game.ultimatexnova.de — misma imagen de fondo, mismas
   tarjetas, nav con icono Discord + Language, footer fijo abajo)
   ÚNICOS CAMBIOS respecto al clon (lo que se conserva del login viejo):
     - BARRA DE ESTADO DE UNIVERSOS ARRIBA (lo marcado en rojo, foto 1)
     - Selector de universo + Recuperar contraseña + Entrar con Discord
       + Imágenes del juego + alerta de error (funcionalidad real 2Moons)
   Overrides SCOPE: body#index — NO afecta a news/rules/screens/etc.
   ============================================================ *}
{literal}
<style>
/* ═══════════════════════════════════════════════════════════
   FONDO + BASE (clon de styles/resource/css/login/main.css de XNOVA)
   ═══════════════════════════════════════════════════════════ */
body#index {
    background: url(styles/resource/images/login/background.jpg) no-repeat fixed center center #0d0d0d;
    background-size: cover;
    color: #FFFFFF;
    font-family: 'Courier New', Courier, monospace;
    font-size: 16px;
    text-align: center;
    overflow-y: scroll;
}
body#index * { font-size: 14px; line-height: 1.3em; }
body#index a { color: #aaa; text-decoration: none; transition: 0.15s ease; }
body#index a:hover { color: #fff; text-shadow: none; }

/* ═══ NAVBAR translúcida (clon exacto de la foto) ═══ */
body#index nav.navbar {
    background: rgba(0, 0, 0, 0.5) !important;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: none !important;
    box-shadow: none !important;
    border-radius: 0 !important;
    font-family: 'Courier New', Courier, monospace !important;
    min-height: 54px !important;
}
body#index nav.navbar .navbar-brand {
    color: #ffffff !important;
    font-size: 22px !important;
    font-weight: 700 !important;
    letter-spacing: 4px !important;
    text-transform: uppercase !important;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.8) !important;
    font-family: 'Courier New', Courier, monospace !important;
}
body#index nav.navbar .navbar-brand:hover { color: #ffe493 !important; }
body#index nav.navbar .nav > li > a {
    color: #aaaaaa !important;
    font-weight: 700 !important;
    text-transform: uppercase !important;
    letter-spacing: 1px !important;
    font-size: 12px !important;
    background: transparent !important;
    text-shadow: 0 1px 4px rgba(0, 0, 0, 0.8) !important;
    font-family: 'Courier New', Courier, monospace !important;
}
body#index nav.navbar .nav > li > a:hover,
body#index nav.navbar .nav > li > a:focus { color: #ffe493 !important; background: transparent !important; }
body#index nav.navbar .navbar-toggle { background: rgba(0,0,0,0.5) !important; border: 1px solid #555 !important; }
body#index nav.navbar .navbar-toggle .icon-bar { background-color: #aaa !important; }

/* ═══ Quitar la caja "ÍNDICE" del layout (solo en esta página) ═══ */
body#index #content { max-width: none; margin: 0; padding: 0; background: transparent; font-family: 'Courier New', Courier, monospace; }
body#index .astrolay_box_out,
body#index .astrolay_box_inner { background: transparent !important; border: none !important; box-shadow: none !important; border-radius: 0 !important; display: block !important; overflow: visible !important; }
body#index .astrolay_box_out tr, body#index .astrolay_box_out td,
body#index .astrolay_box_inner tr, body#index .astrolay_box_inner td { display: block !important; background: transparent !important; border: none !important; box-shadow: none !important; }
body#index tr.box-out-header, body#index tr.box-out-footer,
body#index tr.box-inner-header, body#index tr.box-inner-footer,
body#index td.box-out-content-left, body#index td.box-out-content-right,
body#index td.box-inner-content-left, body#index td.box-inner-content-right { display: none !important; }
body#index td.box-inner-content-center { padding: 0 !important; }

/* ═══ BARRA DE ESTADO DE UNIVERSOS — ARRIBA (foto 1, lo rojo) ═══ */
.uxn_statusbar {
    margin-top: 54px;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    padding: 9px 18px;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 34px;
    flex-wrap: wrap;
    font-family: 'Courier New', Courier, monospace;
}
.uxn_uni { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; justify-content: center; }
.uxn_uni + .uxn_uni { border-left: 1px solid rgba(255, 255, 255, 0.14); padding-left: 34px; }
.uxn_stat { display: flex; flex-direction: column; align-items: center; gap: 3px; min-width: 58px; }
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

/* ═══ DISCORD ICONO + LANGUAGE (esquina derecha del nav, como la foto) ═══ */
.uxn_topright {
    position: fixed;
    top: 9px;
    right: 56px;
    z-index: 1040;
    display: flex;
    align-items: center;
    gap: 14px;
}
.uxn_navdc svg { width: 26px; height: 26px; fill: #ffffff; display: block; filter: drop-shadow(0 1px 4px rgba(0,0,0,.8)); }
.uxn_navdc:hover svg { fill: #ffe493; }
.uxn_langwrap select {
    appearance: none;
    -webkit-appearance: none;
    background: rgba(90, 96, 105, 0.95) url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='10' height='6' viewBox='0 0 10 6'><path d='M0 0l5 6 5-6z' fill='%23ffffff'/></svg>") no-repeat right 10px center;
    color: #ffffff;
    border: 1px solid rgba(255, 255, 255, 0.25);
    border-radius: 4px;
    padding: 7px 26px 7px 12px;
    font-family: 'Courier New', Courier, monospace;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    outline: none;
    text-shadow: 0 1px 3px rgba(0,0,0,.5);
}
.uxn_langwrap select option { background: #2b2f36; color: #fff; font-family: 'Courier New', Courier, monospace; }

/* ═══ ESCENARIO CENTRAL (dos tarjetas como la foto) ═══ */
.uxn_stage {
    min-height: calc(100vh - 210px);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 34px 16px 84px;
    box-sizing: border-box;
}
.uxn_grid { display: flex; gap: 40px; justify-content: center; align-items: flex-start; flex-wrap: wrap; }
.uxn_card {
    background: rgba(8, 10, 14, 0.62);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-radius: 10px;
    padding: 24px 22px;
    box-shadow: 0 14px 44px rgba(0, 0, 0, 0.55);
    box-sizing: border-box;
    color: #f2f2f2;
    text-align: center;
}
.uxn_card_desc { width: 300px; display: flex; flex-direction: column; }
.uxn_card_login { width: 300px; text-align: left; }
.uxn_card_login h1 { font-size: 20px; color: #ffffff; margin: 0 0 16px; text-align: left; font-weight: 700; letter-spacing: 1px; }
.uxn_card_desc p.uxn_text { color: #ffffff; font-size: 14px; font-weight: 700; line-height: 1.5; margin: 0 0 20px; }
.uxn_card_desc .uxn_btns { margin-top: auto; display: flex; flex-direction: column; gap: 12px; }

/* ═══ BOTONES (clon: gris oscuro con borde, hover gris) ═══ */
.uxn_btn {
    display: block; width: 100%; box-sizing: border-box;
    background: rgba(30, 33, 38, 0.92);
    border: 1px solid #4a4d52; color: #ffffff !important;
    padding: 10px 14px;
    font-family: 'Courier New', Courier, monospace;
    font-size: 14px; font-weight: 700; letter-spacing: 1px;
    cursor: pointer; text-align: center;
    transition: background-color 0.15s ease;
    text-shadow: none; text-decoration: none !important;
}
.uxn_btn:hover { background-color: #6c6c6c !important; color: #fff !important; }

/* ═══ FORMULARIO (inputs claros como la foto) ═══ */
.uxn_label { display: flex; justify-content: space-between; align-items: baseline; gap: 10px; width: 100%; color: #f2f2f2; font-size: 13px; margin: 0 0 6px; font-weight: 700; }
.uxn_label .uxn_lost { color: #ffe493 !important; font-size: 10.5px; white-space: nowrap; }
.uxn_label .uxn_lost:hover { color: #ffffff !important; }
.uxn_input {
    width: 100%; box-sizing: border-box;
    background: #ffffff;
    border: 1px solid #c9c9c9;
    border-radius: 3px;
    color: #555; padding: 10px 12px;
    font-family: 'Courier New', Courier, monospace;
    font-size: 14px; outline: none;
    margin-bottom: 13px;
    text-shadow: none;
    transition: border-color 0.15s ease, box-shadow 0.15s ease;
}
.uxn_input:focus { border-color: #ffe493; box-shadow: 0 0 0 2px rgba(255, 228, 147, 0.35); }
.uxn_input::placeholder { color: #999; }
select.uxn_input { cursor: pointer; }
select.uxn_input option { background: #ffffff; color: #444; font-family: 'Courier New', Courier, monospace; }
.uxn_uni_label { color: #f2f2f2; font-size: 12px; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 6px; display: block; text-align: left; font-weight: 700; }
.uxn_alert { background: rgba(140, 22, 22, 0.85); border: 1px solid #ff8080; color: #ffffff; border-radius: 4px; padding: 9px 12px; font-size: 13px; margin-bottom: 14px; }
.uxn_info { text-align: center; margin: 13px 0 0; font-size: 11px; color: #9a9a9a; }

/* ═══ Discord login (conservado) ═══ */
.uxn_discord { display: flex; align-items: center; justify-content: center; gap: 9px; width: 100%; box-sizing: border-box; margin-top: 4px; padding: 10px 14px; background: rgba(30, 33, 38, 0.92); border: 1px solid #4a4d52; color: #fff !important; font-size: 14px; font-weight: 700; letter-spacing: 1px; text-decoration: none !important; transition: background-color 0.15s ease; }
.uxn_discord:hover { background-color: #5865F2 !important; border-color: #5865F2; }
.uxn_discord svg { width: 18px; height: 18px; fill: #ffffff; flex-shrink: 0; }

/* ═══ FOOTER FIJO (clon: "ultimateXnova 1.8.1.1 | Designed by Pfahli | Contactar") ═══ */
.uxn_footer {
    position: fixed;
    bottom: 0; left: 0; right: 0;
    z-index: 1030;
    background: rgba(0, 0, 0, 0.45);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    padding: 8px 16px;
    text-align: left;
    font-family: 'Courier New', Courier, monospace;
    font-size: 13px;
    color: #e8e8e8;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 6px;
    text-shadow: 0 1px 3px rgba(0,0,0,.8);
}
.uxn_footer a { color: #59d6ff; }
.uxn_footer a:hover { color: #ffffff; }
body#index .astrofoot_wrap { display: none !important; }

/* ═══ RESPONSIVE ═══ */
@media (max-width: 1000px) {
    /* Discord + Language dejan de flotar y pasan a flujo, bajo la navbar */
    .uxn_topright { position: static; margin-top: 54px; justify-content: flex-end; padding: 8px 12px 0; }
    .uxn_statusbar { margin-top: 0; }
}
@media (max-width: 760px) {
    .uxn_statusbar { gap: 14px; padding: 8px 10px; }
    .uxn_uni + .uxn_uni { border-left: none; padding-left: 0; border-top: 1px solid rgba(255,255,255,.14); padding-top: 8px; }
    .uxn_uni { gap: 10px; }
    .uxn_stage { min-height: auto; padding: 26px 10px 90px; }
    .uxn_grid { gap: 18px; }
    .uxn_card_desc, .uxn_card_login { width: 100%; max-width: 340px; }
    body#index nav.navbar .navbar-brand { font-size: 17px !important; letter-spacing: 2px !important; }
}
</style>
{/literal}

<!-- ═══ ICONO DISCORD + LANGUAGE en el nav (como la foto) ═══ -->
<div class="uxn_topright">
    <a class="uxn_navdc" href="https://discord.gg/bDMjbKSw9j" target="_blank" rel="noopener noreferrer" title="Discord">
        <svg viewBox="0 0 127.14 96.36" xmlns="http://www.w3.org/2000/svg">
            <path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/>
        </svg>
    </a>
    <div class="uxn_langwrap">
        <form action="index.php" method="get" id="langform">
            <select name="lang" onchange="this.form.submit();" title="Language">
                {foreach $languages as $langID}
                    <option value="{$langID}" {if $langID == $lang}selected{/if}>{$langID|strtoupper}</option>
                {/foreach}
            </select>
        </form>
    </div>
</div>

<!-- ═══ BARRA DE ESTADO DE UNIVERSOS — ARRIBA (lo rojo de la foto 1) ═══ -->
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

<!-- ═══ ESCENARIO: clon exacto de las dos tarjetas de la foto ═══ -->
<div class="uxn_stage">
    <div class="uxn_grid">

        <!-- TARJETA IZQUIERDA (clon: descripción + Regístrate Ahora!) -->
        <div class="uxn_card uxn_card_desc">
            <p class="uxn_text">{$descText}</p>
            <div class="uxn_btns">
                <a class="uxn_btn" href="index.php?page=register">{$LNG.buttonRegister}</a>
                <a class="uxn_btn" href="index.php?page=screens">{$LNG.buttonScreenshot}</a>
            </div>
        </div>

        <!-- TARJETA DERECHA (clon: Iniciar Sesión + tus campos conservados) -->
        <div class="uxn_card uxn_card_login">
            <h1>{$LNG.loginHeader}</h1>

            {if !empty($code)}
            <div class="uxn_alert">{$code}</div>
            {/if}

            <!-- Selector de universo (conservado, funcional) -->
            <form action="index.php?page=index" method="post" id="universe-form">
                <label class="uxn_uni_label" for="universe">Selecciona tu universo</label>
                <select name="uni" id="universe" class="changeAction uxn_input" onchange="this.form.submit();">
                    {if !empty($universeSelect)}
                        {foreach $universeSelect as $uniID => $uniName}
                            <option value="{$uniID}" {if isset($UNI) && $uniID == $UNI}selected{elseif !isset($UNI) && $uniID == 1}selected{/if}>{$uniName}</option>
                        {/foreach}
                    {else}
                        <option value="1" selected>Andrómeda</option>
                    {/if}
                </select>
            </form>

            <!-- Formulario real de 2Moons (conservado intacto) -->
            <form id="login" name="login" action="index.php?page=login" data-action="index.php?page=login" method="post">
                <label class="uxn_label" for="username">{$LNG.loginUsername}</label>
                <input class="uxn_input" type="text" name="username" id="username" placeholder="{$LNG.loginUsername}">

                <div class="uxn_label">
                    <label for="password">{$LNG.loginPassword}</label>
                    {if $mailEnable}
                        <a href="index.php?page=lostPassword" class="uxn_lost">{$LNG.buttonLostPassword}</a>
                    {/if}
                </div>
                <input class="uxn_input" type="password" name="password" id="password" placeholder="{$LNG.loginPassword}">

                <button type="submit" class="uxn_btn">{$LNG.loginButton}</button>
            </form>

            <!-- Facebook Login (conservado) -->
            {if $facebookEnable}
                <a href="#" data-href="index.php?page=externalAuth&method=facebook" class="fb_login" style="display:block; margin-top:12px;">
                    <img src="styles/resource/images/facebook/fb-connect-large.png" alt="Facebook" style="max-width:100%;">
                </a>
            {/if}

            <!-- Discord Login (conservado) -->
            {if $discordEnable}
                <a href="index.php?page=ExternalAuth&method=discord" class="uxn_discord" style="margin-top:12px;">
                    <svg viewBox="0 0 127.14 96.36" xmlns="http://www.w3.org/2000/svg">
                        <path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/>
                    </svg>
                    Entrar con Discord
                </a>
            {/if}

            <p class="uxn_info">{$loginInfo}</p>
        </div>

    </div>
</div>

<!-- ═══ FOOTER FIJO (clon exacto del pie de la foto) ═══ -->
<div class="uxn_footer">
    <span>AstroIO {$VERSION} | Conquista el universo, construye tu imperio | <a href="index.php?page=disclamer">Contactar</a></span>
    <span>
        <a href="https://t.me/+FwdrSAJU5rA5Yzcx" target="_blank" rel="noopener noreferrer">Telegram</a> &nbsp;·&nbsp;
        <a href="https://discord.gg/bDMjbKSw9j" target="_blank" rel="noopener noreferrer">Discord</a>
    </span>
</div>

{/block}