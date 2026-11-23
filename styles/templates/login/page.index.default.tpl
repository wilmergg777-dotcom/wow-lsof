{block name="title" prepend}{$LNG.siteTitleIndex}{/block}
{block name="content"}
{* ============================================================
   ASTROIO v4.0 — LOGIN estilo Ultimate XNOVA (foto 2)
   Copiado/adaptado de https://github.com/ultimateXnova/ultimateXnova
   (solo la parte del login: fondo fijo, navbar translúcida, tarjetas
   glass monoespaciadas, inputs claros, hover amarillo, footer fijo)
   CONSERVA TODO lo del login viejo:
     - Barra de estado de TODOS los universos (marcada en rojo en la foto 1)
     - Selector de universo (multi-universo, POST real a index)
     - Usuario + contraseña + recuperar contraseña (si $mailEnable)
     - Registro, Discord, Facebook, $loginInfo, noticias, error de login
   Overrides SCOPE: body#index — NO afecta a news/rules/screens/etc.
   ============================================================ *}
{literal}
<style>
/* ═══════════════════════════════════════════════════════════
   ULTIMATE XNOVA LOGIN — estilos base (de su login/main.css)
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
body#index h1 { color: #fff; font-size: 22px; margin: 0 0 16px; text-align: left; letter-spacing: 1px; }
body#index a { color: #aaa; text-decoration: none; transition: 0.15s ease; }
body#index a:hover { color: #fff; text-shadow: none; }

/* ═══ NAVBAR translúcida (como la de Ultimate XNOVA) ═══ */
body#index nav.navbar {
    background: rgba(0, 0, 0, 0.5) !important;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: none !important;
    box-shadow: none !important;
    border-radius: 0 !important;
    font-family: 'Courier New', Courier, monospace !important;
    min-height: 56px !important;
}
body#index nav.navbar .navbar-brand {
    color: #ffffff !important;
    font-size: 22px !important;
    font-weight: 700 !important;
    letter-spacing: 3px !important;
    text-transform: uppercase !important;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.8) !important;
    font-family: 'Courier New', Courier, monospace !important;
}
body#index nav.navbar .navbar-brand:hover { color: #ffe493 !important; text-shadow: 0 0 16px rgba(255, 228, 147, 0.6) !important; }
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
body#index #content {
    max-width: none;
    margin: 0;
    padding: 0;
    background: transparent;
    font-family: 'Courier New', Courier, monospace;
}
body#index .astrolay_box_out,
body#index .astrolay_box_inner { background: transparent !important; border: none !important; box-shadow: none !important; border-radius: 0 !important; display: block !important; overflow: visible !important; }
body#index .astrolay_box_out tr,
body#index .astrolay_box_out td,
body#index .astrolay_box_inner tr,
body#index .astrolay_box_inner td { display: block !important; background: transparent !important; border: none !important; box-shadow: none !important; }
body#index tr.box-out-header, body#index tr.box-out-footer,
body#index tr.box-inner-header, body#index tr.box-inner-footer,
body#index td.box-out-content-left, body#index td.box-out-content-right,
body#index td.box-inner-content-left, body#index td.box-inner-content-right { display: none !important; }
body#index td.box-inner-content-center { padding: 0 !important; }

/* ═══ ESCENARIO CENTRAL (foto 2: dos tarjetas flotantes) ═══ */
.uxn_stage {
    min-height: calc(100vh - 170px);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 120px 16px 40px;
    box-sizing: border-box;
}
.uxn_grid {
    display: flex;
    gap: 28px;
    justify-content: center;
    align-items: stretch;
    flex-wrap: wrap;
    width: 100%;
    max-width: 820px;
}
.uxn_card {
    background: rgba(8, 10, 14, 0.62);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-radius: 10px;
    padding: 26px 24px;
    box-shadow: 0 14px 44px rgba(0, 0, 0, 0.55);
    box-sizing: border-box;
    color: #e8e8e8;
    text-align: center;
}
.uxn_card_desc { flex: 1 1 300px; max-width: 340px; display: flex; flex-direction: column; }
.uxn_card_login { flex: 1 1 300px; max-width: 340px; text-align: left; }
.uxn_card_desc p.uxn_text { color: #f2f2f2; font-size: 14px; line-height: 1.55; margin: 0 0 18px; font-weight: 700; }
.uxn_card_desc .uxn_btns { margin-top: auto; display: flex; flex-direction: column; gap: 10px; }

/* ═══ BOTONES estilo Ultimate XNOVA ═══ */
.uxn_btn {
    display: block;
    width: 100%;
    box-sizing: border-box;
    background: rgba(28, 30, 34, 0.9);
    border: 1px solid #5a5a5a;
    color: #ffffff !important;
    padding: 11px 14px;
    font-family: 'Courier New', Courier, monospace;
    font-size: 14px;
    font-weight: 700;
    letter-spacing: 1px;
    cursor: pointer;
    text-align: center;
    transition: background-color 0.15s ease;
    text-shadow: none;
    text-decoration: none !important;
}
.uxn_btn:hover { background-color: #6c6c6c !important; color: #fff !important; }

/* ═══ FORMULARIO (inputs claros como la foto 2) ═══ */
.uxn_label { display: flex; justify-content: space-between; align-items: baseline; color: #e8e8e8; font-size: 13px; margin: 0 0 6px; font-weight: 700; }
.uxn_label .uxn_lost { color: #ffe493 !important; font-size: 11px; }
.uxn_label .uxn_lost:hover { color: #ffffff !important; }
.uxn_input {
    width: 100%;
    box-sizing: border-box;
    background: #f5f5f5;
    border: 1px solid #c9c9c9;
    border-radius: 3px;
    color: #444;
    padding: 11px 12px;
    font-family: 'Courier New', Courier, monospace;
    font-size: 14px;
    outline: none;
    margin-bottom: 14px;
    text-shadow: none;
    transition: border-color 0.15s ease, box-shadow 0.15s ease;
}
.uxn_input:focus { border-color: #ffe493; box-shadow: 0 0 0 2px rgba(255, 228, 147, 0.35); background: #ffffff; }
.uxn_input::placeholder { color: #8a8a8a; }
select.uxn_input { cursor: pointer; }
select.uxn_input option { background: #101418; color: #f2f2f2; font-family: 'Courier New', Courier, monospace; }
.uxn_uni_label { color: #e8e8e8; font-size: 12px; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 6px; display: block; text-align: left; font-weight: 700; }

/* ═══ Alerta de error de login ═══ */
.uxn_alert { background: rgba(140, 22, 22, 0.85); border: 1px solid #ff8080; color: #ffffff; border-radius: 4px; padding: 9px 12px; font-size: 13px; margin-bottom: 14px; }

/* ═══ Botón Discord (conservado, tonos XNOVA) ═══ */
.uxn_discord { display: flex; align-items: center; justify-content: center; gap: 9px; width: 100%; box-sizing: border-box; margin-top: 4px; padding: 10px 14px; background: rgba(28, 30, 34, 0.9); border: 1px solid #5a5a5a; color: #fff !important; border-radius: 0; font-size: 14px; font-weight: 700; letter-spacing: 1px; text-decoration: none !important; transition: background-color 0.15s ease; }
.uxn_discord:hover { background-color: #5865F2 !important; border-color: #5865F2; }
.uxn_discord svg { width: 18px; height: 18px; fill: #ffffff; flex-shrink: 0; }

/* ═══ ESTADO DE UNIVERSOS (lo marcado en rojo — foto 1) ═══ */
.uxn_status {
    max-width: 820px;
    margin: 8px auto 0;
    background: rgba(8, 10, 14, 0.62);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-radius: 10px;
    padding: 6px 22px;
    box-shadow: 0 14px 44px rgba(0, 0, 0, 0.55);
    box-sizing: border-box;
}
.uxn_status_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
    padding: 16px 0;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    flex-wrap: wrap;
}
.uxn_status_row:last-child { border-bottom: none; }
.uxn_scol { flex: 1 1 90px; display: flex; flex-direction: column; align-items: center; gap: 6px; min-width: 80px; }
.uxn_slabel { font-size: 10px; color: #9a9a9a; font-weight: 700; text-transform: uppercase; letter-spacing: 2px; }
.uxn_sval { font-size: 15px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.uxn_green { color: #35ff8f; }
.uxn_red { color: #ff5252; }
.uxn_cyan { color: #59d6ff; }
.uxn_purple { color: #d946ef; }
.uxn_dot { width: 8px; height: 8px; border-radius: 50%; }
.uxn_dot_green { background: #35ff8f; box-shadow: 0 0 8px #35ff8f; animation: uxn_pulse 1.5s infinite; }
.uxn_dot_red { background: #ff5252; box-shadow: 0 0 8px #ff5252; }
@keyframes uxn_pulse { 0% { transform: scale(0.95); } 70% { transform: scale(1.1); box-shadow: 0 0 0 6px rgba(53, 255, 143, 0); } 100% { transform: scale(0.95); } }
.uxn_age_box {
    background: rgba(0, 0, 0, 0.55);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 5px;
    padding: 8px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-width: 64px;
}
.uxn_age_box span { font-size: 24px; font-weight: 700; color: #ffffff; line-height: 1; }
.uxn_age_box small { font-size: 9px; color: #9a9a9a; font-weight: 700; letter-spacing: 2px; margin-top: 4px; }

/* ═══ NOTICIAS (conservadas, mismo estilo glass) ═══ */
.uxn_news {
    max-width: 820px;
    margin: 24px auto 0;
    background: rgba(8, 10, 14, 0.62);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-radius: 10px;
    padding: 20px 24px;
    box-shadow: 0 14px 44px rgba(0, 0, 0, 0.55);
    box-sizing: border-box;
    text-align: left;
    color: #e8e8e8;
}
.uxn_news h2 { color: #fff; font-size: 16px; margin: 0 0 12px; letter-spacing: 2px; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,.12); padding-bottom: 10px; }
.uxn_news_title { color: #ffe493; font-size: 15px; margin: 0 0 10px; font-weight: 700; }
.uxn_news_text { color: #d9d9d9; font-size: 13px; line-height: 1.6; margin: 0; white-space: pre-wrap; max-height: 320px; overflow-y: auto; padding-right: 6px; }
.uxn_news_text::-webkit-scrollbar { width: 8px; }
.uxn_news_text::-webkit-scrollbar-track { background: rgba(255,255,255,.05); }
.uxn_news_text::-webkit-scrollbar-thumb { background: #6c6c6c; border-radius: 4px; }
.uxn_news_empty { color: #9a9a9a; font-style: italic; text-align: center; padding: 24px 0; margin: 0; }
.uxn_news_foot { text-align: right; margin-top: 12px; }
.uxn_news_foot a { color: #ffe493 !important; font-size: 12px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; }
.uxn_news_foot a:hover { color: #ffffff !important; }

/* ═══ FOOTER (conservado, fondo transparente estilo XNOVA) ═══ */
body#index .astrofoot_wrap { background: transparent; border-top: 1px solid rgba(255, 255, 255, 0.12); max-width: 100%; font-family: 'Courier New', Courier, monospace; color: #9a9a9a; padding-bottom: 26px; }
body#index .astrofoot_copy a { color: #ffe493 !important; }
body#index .astrofoot_copy { color: #9a9a9a; }

/* ═══ ║║ RESPONSIVE ═══ */
@media (max-width: 760px) {
    .uxn_stage { padding: 96px 10px 30px; min-height: auto; }
    .uxn_grid { gap: 18px; }
    .uxn_card_desc, .uxn_card_login { max-width: 100%; flex: 1 1 100%; }
    .uxn_status { margin: 8px 10px 0; padding: 4px 16px; }
    .uxn_news { margin: 18px 10px 0; padding: 16px 16px; }
    .uxn_scol { flex: 1 1 40%; }
    .uxn_age_box { min-width: 56px; }
    body#index nav.navbar .navbar-brand { font-size: 17px !important; letter-spacing: 2px !important; }
}
</style>
{/literal}

<div class="uxn_stage">
    <div class="uxn_grid">

        <!-- ═══ TARJETA IZQUIERDA: descripción (como la de Ultimate XNOVA) ═══ -->
        <div class="uxn_card uxn_card_desc">
            <p class="uxn_text">{$descText}</p>
            <div class="uxn_btns">
                <a class="uxn_btn" href="index.php?page=register">{$LNG.buttonRegister}</a>
                <a class="uxn_btn" href="index.php?page=screens">{$LNG.buttonScreenshot}</a>
            </div>
        </div>

        <!-- ═══ TARJETA DERECHA: Iniciar Sesión (como la de Ultimate XNOVA) ═══ -->
        <div class="uxn_card uxn_card_login">
            <h1>{$LNG.loginHeader}</h1>

            {if !empty($code)}
            <div class="uxn_alert">{$code}</div>
            {/if}

            <!-- FORMULARIO DE CAMBIO DE UNIVERSO (funcional, como en el login viejo) -->
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

            <!-- FORMULARIO REAL DE 2MOONS (conservado intacto) -->
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

            <p style="text-align:center; margin:14px 0 0; font-size:11px; color:#9a9a9a;">{$loginInfo}</p>
        </div>

    </div>
</div>

<!-- ═══ ESTADO DE TODOS LOS UNIVERSOS (lo marcado en rojo — foto 1) ═══ -->
<div class="uxn_status">
    {foreach $allUniversesStats as $uniStats}
    <div class="uxn_status_row">
        <!-- ESTADO -->
        <div class="uxn_scol">
            <span class="uxn_slabel">ESTADO</span>
            {if isset($uniStats.isOnline) && $uniStats.isOnline === false}
                <span class="uxn_sval uxn_red"><span class="uxn_dot uxn_dot_red"></span> OFFLINE</span>
            {else}
                <span class="uxn_sval uxn_green"><span class="uxn_dot uxn_dot_green"></span> EN LÍNEA</span>
            {/if}
        </div>
        <!-- ONLINE -->
        <div class="uxn_scol">
            <span class="uxn_slabel">ONLINE</span>
            <span class="uxn_sval uxn_cyan">{$uniStats.usersOnline|default:0}</span>
        </div>
        <!-- ÚLTIMAS 24H -->
        <div class="uxn_scol">
            <span class="uxn_slabel">ÚLTIMAS 24H</span>
            <span class="uxn_sval uxn_cyan">{$uniStats.users24h|default:0}</span>
        </div>
        <!-- UNIVERSO -->
        <div class="uxn_scol">
            <span class="uxn_slabel">UNIVERSO</span>
            <span class="uxn_sval uxn_purple">{$uniStats.name|default:'Andrómeda'}</span>
        </div>
        <!-- EDAD DEL UNIVERSO -->
        <div class="uxn_scol">
            <span class="uxn_slabel">EDAD DEL UNIVERSO</span>
            <div class="uxn_age_box"><span>{$uniStats.age|default:1}</span><small>DÍAS</small></div>
        </div>
    </div>
    {/foreach}
</div>

<!-- ═══ NOTICIAS (conservadas) ═══ -->
<div class="uxn_news">
    <h2>{$LNG.siteTitleNews}</h2>
    {foreach $newsList as $newsRow}
        <h3 class="uxn_news_title">{$newsRow.title}</h3>
        <p class="uxn_news_text">{$newsRow.text}</p>
    {foreachelse}
        <p class="uxn_news_empty">{$LNG.news_does_not_exist}</p>
    {/foreach}
    <div class="uxn_news_foot">
        <a href="index.php?page=news">Ver Todas las Noticias</a>
    </div>
</div>

{/block}