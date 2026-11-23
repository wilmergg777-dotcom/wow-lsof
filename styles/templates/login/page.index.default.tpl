{block name="title" prepend}{$LNG.siteTitleIndex}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.index.default.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Página de Inicio (Login/Index)
   FIX: Contador PHP + Scroll en Noticias + Multi-Universo
   ═══════════════════════════════════════════════ */
:root {
    --bg-card:       rgba(15, 23, 42, 0.75);
    --border-color:  #1e2d42;
    --text-main:     #cbd5e1;
    --text-muted:    #8b9eb3;
    --accent-cyan:   #00e0ff;
    --accent-green:  #10b981;
    --accent-red:    #ef4444;
}

.astroidx_wrap { padding: 10px 0; max-width: 1100px; margin: 0 auto; font-family: 'Segoe UI', Roboto, sans-serif; }

/* ═══ BARRA DE ESTADÍSTICAS DEL SERVIDOR ═══ */
.server-status-bar {
    display: flex; 
    flex-direction: column; 
    gap: 10px;
    background: rgba(13, 22, 37, 0.6); border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px; padding: 15px 25px; margin-bottom: 20px;
    backdrop-filter: blur(8px); box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
}
.status-row {
    display: flex; justify-content: space-between; align-items: center;
    padding-bottom: 10px; margin-bottom: 10px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
.status-row:last-child { border-bottom: none; padding-bottom: 0; margin-bottom: 0; }

.status-item {
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    flex: 1; border-right: 1px solid rgba(255, 255, 255, 0.05); padding: 0 10px;
}
.status-item:last-child { border-right: none; }
.status-label { font-size: 10px; color: #8b9eb3; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; }
.status-value { font-size: 16px; font-weight: bold; display: flex; align-items: center; gap: 8px; }
.text-green { color: #00ff88; text-shadow: 0 0 10px rgba(0, 255, 136, 0.4); }
.text-red { color: #ef4444; text-shadow: 0 0 10px rgba(239, 68, 68, 0.4); }
.text-cyan { color: #00e5ff; text-shadow: 0 0 10px rgba(0, 229, 255, 0.4); }
.text-purple { color: #d946ef; text-shadow: 0 0 10px rgba(217, 70, 239, 0.4); }
.dot { width: 8px; height: 8px; border-radius: 50%; }
.dot-green { background-color: #00ff88; box-shadow: 0 0 8px #00ff88; animation: pulse 1.5s infinite; }
.dot-red { background-color: #ef4444; box-shadow: 0 0 8px #ef4444; }
@keyframes pulse { 0% { transform: scale(0.95); } 70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(0, 255, 136, 0); } 100% { transform: scale(0.95); } }

/* Ajustes para el contador de días */
.timer-group { flex: 1.2; align-items: flex-end; }
.timer-container { display: flex; gap: 6px; margin-top: 2px; justify-content: flex-end; }
.time-box { 
    background: rgba(0, 0, 0, 0.4); 
    border: 1px solid rgba(255, 255, 255, 0.1); 
    border-radius: 6px; 
    padding: 8px 24px; 
    display: flex; 
    flex-direction: column; 
    align-items: center; 
    min-width: 80px; 
}
.time-box span { font-size: 24px; font-weight: bold; color: #00ff88; line-height: 1; }
.time-box small { font-size: 10px; color: #64748b; font-weight: bold; letter-spacing: 0.5px; margin-top: 4px; }

/* ═══ HERO (Bienvenida) ═══ */
.astroidx_hero {
    background: var(--bg-card); backdrop-filter: blur(6px);
    border: 1px solid var(--border-color); border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5); padding: 24px 32px; text-align: center;
    color: var(--text-main); margin-bottom: 20px;
}
.astroidx_hero h1 { color: var(--accent-cyan); font-size: 36px; margin: 0 0 14px; letter-spacing: 1px; font-weight: 700; text-shadow: 0 0 24px rgba(0, 224, 255, 0.4); }
.astroidx_hero p { color: var(--text-main); font-size: 14px; line-height: 1.7; max-width: 800px; margin: 0 auto 16px; }
.astroidx_btn { display: inline-block; padding: 10px 28px; background: linear-gradient(180deg, #228833 0%, #66ff99 100%); color: #0f1624; border: 1px solid var(--accent-green); border-radius: 8px; font-size: 13px; font-weight: 700; text-decoration: none; transition: 0.25s ease; text-transform: uppercase; letter-spacing: 1px; }
.astroidx_btn:hover { box-shadow: 0 0 20px rgba(102, 255, 153, 0.6); transform: translateY(-2px); color: #0f1624; }

/* ═══ CONTENEDOR 2 COLUMNAS ═══ */
.astroidx_container { 
    display: flex; 
    gap: 20px; 
    flex-wrap: wrap; 
    justify-content: center; 
    align-items: flex-start; /* Evita que el login se estire hacia abajo */
}
.astroidx_col { flex: 1 1 480px; min-width: 300px; max-width: 540px; }

/* ═══ PANEL NOTICIAS ═══ */
.astroidx_panel { background: var(--bg-card); backdrop-filter: blur(6px); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5); overflow: hidden; color: var(--text-main); height: auto; display: flex; flex-direction: column; }
.astroidx_panel_heading { background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)); border-bottom: 1px solid var(--accent-cyan); color: #ffffff; font-size: 12px; font-weight: 700; padding: 10px 16px; text-transform: uppercase; letter-spacing: 1.5px; text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4); }

/* Scroll solo en la noticia */
.astroidx_panel_body { padding: 16px; flex-grow: 1; }
.news-body {
    max-height: 420px; /* Altura máxima de la caja de noticias */
    overflow-y: auto;  /* Barra de scroll vertical */
}
/* Estilo del scroll para que se vea bonito */
.news-body::-webkit-scrollbar { width: 8px; }
.news-body::-webkit-scrollbar-track { background: rgba(0, 0, 0, 0.2); border-radius: 4px; }
.news-body::-webkit-scrollbar-thumb { background: #00bcd4; border-radius: 4px; }
.news-body::-webkit-scrollbar-thumb:hover { background: #00e0ff; }

.astroidx_news_title { color: var(--accent-cyan); font-size: 18px; margin: 0 0 10px; padding-bottom: 8px; border-bottom: 1px solid var(--border-color); letter-spacing: 0.5px; }
.astroidx_news_text { color: var(--text-main); font-size: 13px; line-height: 1.7; margin: 0; white-space: pre-wrap; }
.astroidx_news_empty { color: var(--text-muted); font-size: 15px; font-style: italic; text-align: center; padding: 30px 0; }
.astroidx_news_footer { text-align: right; padding: 10px 16px; border-top: 1px solid var(--border-color); background: rgba(0,0,0,0.1); }
.astroidx_btn_success { display: inline-block; padding: 6px 18px; background: linear-gradient(180deg, #228833 0%, #66ff99 100%); color: #0f1624; border: 1px solid var(--accent-green); border-radius: 6px; font-size: 11px; font-weight: 700; cursor: pointer; text-decoration: none; transition: 0.25s ease; text-transform: uppercase; letter-spacing: 0.5px; }
.astroidx_btn_success:hover { box-shadow: 0 0 16px rgba(102, 255, 153, 0.5); transform: translateY(-1px); color: #0f1624; }

/* ═══ LOGIN ESTILO OSCURO ═══ */
.xnova-login-card {
    background-color: #0d1625; border: 1px solid #1e2d42;
    border-radius: 12px; padding: 30px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.6);
    color: #ffffff; box-sizing: border-box; height: auto; /* Ya no se estira */
    display: flex; flex-direction: column;
}
.login-logo { text-align: center; margin-bottom: 20px; }
.login-logo p { font-size: 12px; color: #8b9eb3; margin: 0; }

/* ═══ BARRA DE SELECCIÓN DE UNIVERSO ═══ */
.server-selector { 
    display: flex; justify-content: space-between; align-items: center; 
    background-color: #0a101b; border: 1px solid #1e2d42; 
    border-radius: 8px; padding: 10px 15px; margin-bottom: 20px; 
}
.server-info { display: flex; align-items: center; gap: 8px; }
.server-dot { width: 8px; height: 8px; background-color: #00bcd4; border-radius: 50%; box-shadow: 0 0 8px #00bcd4; }
.server-label-text { font-size: 11px; color: #8b9eb3; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; }

.universe-select-wrapper { width: 60%; }
.universe-select-wrapper select {
    width: 100%; background-color: transparent; color: #00bcd4; border: 1px solid #1e2d42;
    border-radius: 6px; padding: 8px 10px; font-size: 13px; font-weight: bold;
    outline: none; cursor: pointer; appearance: none;
    background-image: url('data:image/svg+xml;utf8,<svg fill="%2300bcd4" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/><path d="M0 0h24v24H0z" fill="none"/></svg>');
    background-repeat: no-repeat; background-position-x: 95%; background-position-y: 50%;
}
.universe-select-wrapper select:focus { border-color: #00bcd4; }
.universe-select-wrapper select option { background-color: #0d1625; color: #fff; padding: 10px; }

.input-group { margin-bottom: 15px; }
.input-group label { display: block; font-size: 12px; color: #8b9eb3; margin-bottom: 6px; }
.label-row { display: flex; justify-content: space-between; align-items: center; }
.forgot-link { font-size: 11px; color: #00bcd4; text-decoration: none; }
.forgot-link:hover { text-decoration: underline; }

/* ═══ SOLUCIÓN DEFINITIVA ICONOS ═══ */
.input-icon-wrapper { position: relative !important; display: block !important; width: 100% !important; }
.input-icon-wrapper .icon { position: absolute !important; left: 15px !important; top: 50% !important; transform: translateY(-50%) !important; color: #64748b !important; font-size: 16px !important; z-index: 10 !important; pointer-events: none !important; }
.input-icon-wrapper input { width: 100% !important; background-color: #e2e8f0 !important; border: none !important; border-radius: 6px !important; padding: 12px 12px 12px 45px !important; font-size: 14px !important; color: #1e293b !important; outline: none !important; box-sizing: border-box !important; height: 45px !important; }
.input-icon-wrapper input:focus { box-shadow: 0 0 0 2px #00bcd4 !important; }

.btn-login-submit { width: 100%; background-color: #00bcd4; color: #ffffff; border: none; border-radius: 6px; padding: 14px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 10px; transition: background-color 0.3s; }
.btn-login-submit:hover { background-color: #00acc1; }
.login-footer { text-align: center; margin-top: auto; padding-top: 20px; font-size: 12px; color: #8b9eb3; }
.login-footer a { color: #ffffff; text-decoration: none; font-weight: bold; }
.login-footer a:hover { color: #00bcd4; }

/* ═══ BOTÓN DISCORD ═══ */
.astroidx_discord_login { display: flex; align-items: center; justify-content: center; gap: 8px; width: 100%; box-sizing: border-box; margin-top: 15px; padding: 10px 16px; background: linear-gradient(180deg, #4752c4 0%, #5865F2 100%); color: #ffffff; border: 1px solid #7983f5; border-radius: 8px; font-size: 13px; font-weight: 700; text-decoration: none; transition: 0.25s ease; letter-spacing: 0.5px; text-transform: uppercase; box-shadow: 0 4px 12px rgba(88, 101, 242, 0.3); }
.astroidx_discord_login:hover { box-shadow: 0 0 22px rgba(88, 101, 242, 0.7); transform: translateY(-2px); color: #ffffff; background: linear-gradient(180deg, #5865F2 0%, #7983f5 100%); }
.astroidx_discord_login svg { width: 20px; height: 20px; fill: #ffffff; flex-shrink: 0; }

/* ═══ RESPONSIVE ═══ */
@media (max-width: 768px) {
    .server-status-bar { flex-wrap: wrap; gap: 15px; justify-content: center; }
    .status-row { flex-wrap: wrap; gap: 15px; }
    .status-item { border-right: none; flex: 1 1 40%; }
    .timer-group { flex: 1 1 100%; align-items: center; }
    .astroidx_col { flex: 1 1 100%; }
    .astroidx_hero h1 { font-size: 26px; }
    .universe-select-wrapper { width: 100%; margin-top: 10px; }
    .server-selector { flex-direction: column; align-items: flex-start; }
}
</style>

<div class="astroidx_wrap">

    <!-- ═══ BARRA DE ESTADÍSTICAS (TODOS LOS UNIVERSOS) ═══ -->
    <div class="server-status-bar">
        {foreach $allUniversesStats as $uniStats}
        <div class="status-row">
            <!-- ESTADO DEL SERVIDOR -->
            <div class="status-item">
                <span class="status-label">ESTADO</span>
                {if isset($uniStats.isOnline) && $uniStats.isOnline === false}
                    <span class="status-value text-red"><span class="dot dot-red"></span> OFFLINE</span>
                {else}
                    <span class="status-value text-green"><span class="dot dot-green"></span> EN LÍNEA</span>
                {/if}
            </div>

            <!-- JUGADORES ONLINE -->
            <div class="status-item">
                <span class="status-label">ONLINE</span>
                <span class="status-value text-cyan">{$uniStats.usersOnline|default:0}</span>
            </div>

            <!-- JUGADORES ÚLTIMAS 24H -->
            <div class="status-item">
                <span class="status-label">ÚLTIMAS 24H</span>
                <span class="status-value text-cyan">{$uniStats.users24h|default:0}</span>
            </div>

            <!-- NOMBRE DEL UNIVERSO -->
            <div class="status-item">
                <span class="status-label">UNIVERSO</span>
                <span class="status-value text-purple">{$uniStats.name|default:'Némesis'}</span>
            </div>

            <!-- CONTADOR DE DÍAS (DIRECTO DESDE PHP) -->
            <div class="status-item timer-group">
                <span class="status-label">EDAD DEL UNIVERSO</span>
                <div class="timer-container">
                    <div class="time-box"><span>{$uniStats.age|default:1}</span><small>DÍAS</small></div>
                </div>
            </div>
        </div>
        {/foreach}
    </div>

    <!-- ═══ HERO (Bienvenida) ═══ -->
    <div class="astroidx_hero">
        <h1>{$descHeader}</h1>
        <p>{$descText}</p>
        <p style="text-align: center;">
            <a class="astroidx_btn" href="index.php?page=screens">{$LNG.buttonScreenshot}</a>
        </p>
    </div>

    <!-- ═══ CONTENEDOR 2 COLUMNAS ═══ -->
    <div class="astroidx_container">

        <!-- COLUMNA IZQUIERDA: NOTICIAS -->
        <div class="astroidx_col">
            <div class="astroidx_panel">
                <div class="astroidx_panel_heading">{$LNG.siteTitleNews}</div>
                
                <div class="astroidx_panel_body news-body">
                    {foreach $newsList as $newsRow}
                        <h1 class="astroidx_news_title">{$newsRow.title}</h1>
                        <p class="astroidx_news_text">{$newsRow.text}</p>
                    {foreachelse}
                        <h3 class="astroidx_news_empty">{$LNG.news_does_not_exist}</h3>
                    {/foreach}
                </div>
                
                <div class="astroidx_news_footer">
                    <a href="index.php?page=news" class="astroidx_btn_success">Ver Todas las Noticias</a>
                </div>
            </div>
        </div>

        <!-- COLUMNA DERECHA: LOGIN OSCURO -->
        <div class="astroidx_col">
            <div class="xnova-login-card">
                
                <div class="login-logo">
                    <p>Conquista el universo, construye tu imperio</p>
                </div>

                <!-- FORMULARIO DE CAMBIO DE UNIVERSO -->
                <form action="index.php?page=index" method="post" id="universe-form">
                    <div class="server-selector">
                        <div class="server-info">
                            <span class="server-dot"></span>
                            <span class="server-label-text">Selecciona tu universo</span>
                        </div>
                        <div class="universe-select-wrapper">
                            <select name="uni" id="universe" class="changeAction" onchange="this.form.submit();">
                                {if !empty($universeSelect)}
                                    {foreach $universeSelect as $uniID => $uniName}
                                        <option value="{$uniID}" {if isset($UNI) && $uniID == $UNI}selected{elseif !isset($UNI) && $uniID == 1}selected{/if}>{$uniName}</option>
                                    {/foreach}
                                {else}
                                    <option value="1" selected>Andrómeda</option>
                                {/if}
                            </select>
                        </div>
                    </div>
                </form>

                <!-- FORMULARIO REAL DE 2MOONS -->
                <form id="login" name="login" action="index.php?page=login" data-action="index.php?page=login" method="post">
                    
                    <!-- CAMPO USUARIO -->
                    <div class="input-group">
                        <label for="username">{$LNG.loginUsername}</label>
                        <div class="input-icon-wrapper">
                            <i class="fa fa-user icon"></i>
                            <input type="text" name="username" id="username" placeholder="{$LNG.loginUsername}">
                        </div>
                    </div>

                    <!-- CAMPO CONTRASEÑA -->
                    <div class="input-group">
                        <div class="label-row">
                            <label for="password">{$LNG.loginPassword}</label>
                            {if $mailEnable}
                                <a href="index.php?page=lostPassword" class="forgot-link">{$LNG.buttonLostPassword}</a>
                            {/if}
                        </div>
                        <div class="input-icon-wrapper">
                            <i class="fa fa-lock icon"></i>
                            <input type="password" name="password" id="password" placeholder="{$LNG.loginPassword}">
                        </div>
                    </div>

                    <button type="submit" class="btn-login-submit">{$LNG.loginButton}</button>
                </form>

                <!-- Facebook Login -->
                {if $facebookEnable}
                    <a href="#" data-href="index.php?page=externalAuth&method=facebook" class="fb_login" style="display:block; text-align:center; margin-top:10px;">
                        <img src="styles/resource/images/facebook/fb-connect-large.png" alt="Facebook">
                    </a>
                {/if}

                <!-- Discord Login -->
                {if $discordEnable}
                    <a href="index.php?page=ExternalAuth&method=discord" class="astroidx_discord_login">
                        <svg viewBox="0 0 127.14 96.36" xmlns="http://www.w3.org/2000/svg">
                            <path d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/>
                        </svg>
                        Entrar con Discord
                    </a>
                {/if}

                <div class="login-footer">
                    <a href="index.php?page=register">{$LNG.buttonRegister}</a>
                    <br><br>
                    <span class="small astroidx_login-info">{$loginInfo}</span>
                </div>

            </div>
        </div>

    </div>

</div>

{/block}