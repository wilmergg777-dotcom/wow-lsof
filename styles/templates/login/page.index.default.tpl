{block name="title" prepend}{$LNG.siteTitleIndex}{/block}
{block name="content"}
{* ============================================================
   ASTROIO v8.0 — ÍNDICE clon EXACTO del page.index.default.tpl
   de ultimateXnova (tema nextgen): tarjeta descripción flotando
   a la izquierda + tarjeta Iniciar Sesión a la derecha, botones
   bg-dark, inputs blancos bootstrap, tipografía Space Mono.
   SE CONSERVA del juego (funcionalidad real):
     - Barra de estado de universos (lo marcado en rojo, foto 1)
     - Formulario 2Moons (username/password POST a index.php?page=login)
     - Selector de universo cuando el servidor es multiuniverso
     - Recuperar contraseña, Discord login, Facebook, alerta de error
   ============================================================ *}
{literal}
<style>
/* Barra de estado de universos (requisito guardado de la foto 1) */
.uxn_statusbar {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 9px 18px;
    margin-bottom: 30px;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 34px;
    flex-wrap: wrap;
    font-family: "Space Mono", monospace;
    color: #fff;
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
/* Alerta de error de login */
.alert-astrio { background: rgba(83, 6, 6, 0.65); border: 1px solid rgba(255,255,255,0.15); color: #fff; border-radius: 8px; padding: 8px 12px; font-size: 13px; margin: 0 0 10px; }
/* Selector de universo (solo multiuniverso) */
.uxn_uni_label { color: #f2f2f2; font-size: 12px; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 6px; display: block; text-align: left; font-weight: 700; }
@media (max-width: 760px) {
    .uxn_statusbar { gap: 14px; padding: 8px 10px; }
    .uxn_uni + .uxn_uni { border-left: none; padding-left: 0; border-top: 1px solid rgba(255,255,255,.14); padding-top: 8px; }
    .uxn_uni { gap: 10px; }
}
</style>
{/literal}

<div class="uk-container uk-clearfix" style="padding-top:10px;">

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

<!-- ═══ TARJETA IZQUIERDA: descripción (clon ultimate) ═══ -->
<div style="max-width:300px;" class="box-border description-container dark-blur-bg box-shadow-large">
	{if !empty($descText)}{$descText}{else}AstroIO es un juego de estrategia espacial en tiempo real donde cada decisión cuenta. Construye tu imperio, gestiona recursos, alianzas e investiga tecnologías, forja alianzas y conquista la galaxia. Aquí la estrategia lo es todo. Solo necesitas un navegador para jugar.{/if}
	<a class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" href="index.php?page=register">{$LNG.buttonRegister}</a>
	<a class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" href="index.php?page=screens">{$LNG.buttonScreenshot|default:'Imágenes del juego'}</a>
</div>

<!-- ═══ TARJETA DERECHA: Iniciar Sesión (clon ultimate + funcionalidad del juego) ═══ -->
<div style="max-width:300px;" class="box-border login-container dark-blur-bg box-shadow-large">

			<h1 class="login-heading">{$LNG.loginHeader}</h1>

			{if !empty($code)}
			<div class="alert-astrio">{$code}</div>
			{/if}

			<form id="login" name="login" action="index.php?page=login" data-action="index.php?page=login" method="post">
				<div class="d-flex flex-column form-group">

					{if $isMultiUniverse}
					<label class="uxn_uni_label" for="universe">Selecciona tu universo</label>
					<select class="form-select my-2 w-100 changeAction" name="uni" id="universe">
						{if !empty($universeSelect)}
							{foreach $universeSelect as $uniID => $uniName}
								<option value="{$uniID}" {if isset($UNI) && $uniID == $UNI}selected{/if}>{$uniName}</option>
							{/foreach}
						{else}
							<option value="1" selected>Universo 1</option>
						{/if}
					</select>
					{/if}

					<input class="form-control fs-6 my-2 w-100" id="username" type="text" name="username" placeholder="{$LNG.loginUsername}">
					<input class="form-control fs-6 my-2 w-100" id="password" type="password" name="password" placeholder="{$LNG.loginPassword}">

					<button id="loginButton" class="hover-bg-color-grey btn bg-dark text-white w-100 my-2" type="submit">{$LNG.loginButton}</button>

				</div>
			</form>

			{if $mailEnable}
				<a class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" href="index.php?page=lostPassword">{$LNG.buttonLostPassword}</a>
			{/if}

			{if $discordEnable}
				<a href="index.php?page=ExternalAuth&method=discord" class="hover-bg-color-grey btn btn-block w-100 bg-dark text-white my-2 fs-6" style="display:flex; align-items:center; justify-content:center; gap:8px;">
					<img src="styles/theme/gow/ultimate/img/social/discord-mark-white.svg" width="18px" alt=""> Entrar con Discord
				</a>
			{/if}

			{if $facebookEnable}
				<a href="#" data-href="index.php?page=externalAuth&method=facebook" class="fb_login" style="display:block; margin-top:12px;">
					<img src="styles/resource/images/facebook/fb-connect-large.png" alt="Facebook" style="max-width:100%;">
				</a>
			{/if}

			<p class="info" style="text-align:center; margin:12px 0 0;">{$loginInfo}</p>

</div>

<div class="uk-clearfix"></div>
</div>

{/block}
