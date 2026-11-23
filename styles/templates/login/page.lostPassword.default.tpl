{block name="title" prepend}{$LNG.siteTitleLostPassword}{/block}
{block name="content"}
{* === ASTROIO v3.1 - Recuperar Contraseña (Estilo oscuro, borde naranja) === *}
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
/* ✅ FIX: Corregido el error de sintaxis del doble corchete */
@media (max-width:760px) { body { padding:6px; overflow-x:auto; } table { font-size:11px; } table th, table td { padding:5px 7px; } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.1 — Recuperar Contraseña
   ✅ FIX: Eliminada la barra azul superior.
   ✅ FIX: Borde naranja, fondo oscuro y inputs blancos.
   ═══════════════════════════════════════════════ */

:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(10, 15, 25, 0.9); /* Fondo oscuro igual al index */
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #ff5e00; /* Borde naranja */
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --accent-cyan:   #00e0ff;
}

.astrolost_wrap {
    max-width: 700px;
    margin: 40px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astrolost_panel {
    background: var(--bg-card) !important;
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    border: 1px solid var(--border-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9) !important;
    overflow: hidden;
}

/* ✅ FIX: Ocultar la barra azul de "RECUPERAR CONTRASEÑA" */
.astrolost_heading {
    display: none !important;
}

.astrolost_body {
    padding: 30px 40px;
    color: #e2e8f0 !important;
}

/* Info descriptiva arriba */
.astrolost_info {
    background: rgba(0, 224, 255, 0.05) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-left: 3px solid var(--accent-cyan) !important;
    border-radius: 8px;
    padding: 12px 16px;
    margin-bottom: 20px;
    font-size: 13px;
    line-height: 1.6;
    color: #e2e8f0 !important;
}
.astrolost_info p {
    margin: 0;
}

/* ═══ Form group ═══ */
.astrolost_group {
    margin-bottom: 16px;
}

.astrolost_group label {
    display: block;
    color: #94a3b8 !important;
    font-size: 12px;
    margin-bottom: 6px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
}

/* Inputs blancos con letra negra */
.astrolost_group input[type="text"],
.astrolost_group input[type="email"],
.astrolost_group select {
    width: 100%;
    box-sizing: border-box;
    background: #ffffff !important;
    color: #000000 !important;
    border: 1px solid rgba(255, 255, 255, 0.2) !important;
    border-radius: 6px;
    padding: 12px 14px;
    font-size: 14px;
    transition: 0.25s ease;
}

.astrolost_group input:focus,
.astrolost_group select:focus {
    outline: none;
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
}

.astrolost_group select option {
    background: #0f1624 !important;
    color: #ffffff !important;
}

/* ═══ Captcha ═══ */
.astrolost_captcha_row {
    margin-bottom: 16px;
    padding: 12px;
    background: rgba(0, 224, 255, 0.05) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-radius: 6px;
}
.astrolost_captcha_row label {
    display: block;
    color: #94a3b8 !important;
    font-size: 12px;
    margin-bottom: 8px;
    text-transform: uppercase;
    font-weight: 600;
}
.astrolost_captcha_row .captchaButtons {
    margin: 0;
}
.astrolost_captcha_row .g-recaptcha {
    margin-top: 6px;
}

/* ═══ Botón submit ═══ */
.astrolost_actions {
    text-align: right;
    padding-top: 15px;
    border-top: 1px solid rgba(255, 255, 255, 0.1) !important;
    margin-top: 10px;
}

.astrolost_btn_submit {
    display: inline-block;
    padding: 12px 30px;
    background: #222c3c !important;
    color: #ffffff !important;
    border: 1px solid #444 !important;
    border-radius: 6px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astrolost_btn_submit:hover {
    background: #2e3a4e !important;
    border-color: var(--border-color) !important;
    box-shadow: 0 0 18px rgba(255, 94, 0, 0.4) !important;
    transform: translateY(-2px);
}
.astrolost_btn_submit:active {
    transform: translateY(0);
}

@media (max-width: 768px) {
    .astrolost_wrap {
        margin-top: 20px;
        padding: 0 6px;
    }
    .astrolost_body {
        padding: 20px 15px;
    }
    .astrolost_actions {
        text-align: center;
    }
    .astrolost_btn_submit {
        width: 100%;
    }
}
</style>

<div class="container astrolost_wrap">
    <div class="row">
        <div class="col-lg-12">
            <div class="panel panel-default astrolost_panel">
                <div class="panel-heading astrolost_heading">{$LNG.siteTitleLostPassword}</div>
                <div class="panel-body astrolost_body">

                    <div class="astrolost_info">
                        <p>{$LNG.passwordInfo}</p>
                    </div>

                    <form action="index.php?page=lostPassword" method="post" data-action="index.php?page=lostPassword">
                        <input type="hidden" value="send" name="mode">
                        <div class="form-group astrolost_group">
                            <label for="universe">{$LNG.universe}</label>
                            <select name="uni" id="universe" class="form-control changeAction">{html_options options=$universeSelect selected=$UNI}</select>
                        </div>
                        <div class="form-group astrolost_group">
                            <label for="username">{$LNG.passwordUsername}</label>
                            <input type="text" class="form-control" name="username" id="username" placeholder="{$LNG.passwordUsername}">
                        </div>
                        <div class="form-group astrolost_group">
                            <label for="mail">{$LNG.passwordMail}</label>
                            <input type="email" class="form-control" name="mail" id="mail" placeholder="{$LNG.passwordMail}">
                        </div>
                        {if $recaptchaEnable}
                            <div class="formRow astrolost_captcha_row" id="captchaRow">
                                <div>
                                    <label>{$LNG.registerCaptcha}<p class="captchaButtons"></p></label>
                                    <div class="g-recaptcha" data-sitekey="{$recaptchaPublicKey}"></div>
                                </div>
                                <div class="clear"></div>
                            </div>
                        {/if}
                        <div class="astrolost_actions">
                            <button type="submit" class="btn btn-danger astrolost_btn_submit">{$LNG.passwordSubmit}</button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

{/block}
{block name="script" append}
{if $recaptchaEnable}
<script type="text/javascript" src="https://www.google.com/recaptcha/api.js?hl={$lang}"></script>
{/if}
{/block}