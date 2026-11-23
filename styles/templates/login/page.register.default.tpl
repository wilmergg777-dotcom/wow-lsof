{block name="title" prepend}{$LNG.siteTitleRegister}{/block}
{block name="content"}
{* === ASTROIO v3.2 - Página de Registro (Fondo oscuro forzado, texto visible) === *}
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
@media (max-width:760px) { body { padding:6px; overflow-x:auto; } table { font-size:11px; } table th, table td { padding:5px 7px; } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.2 — Página de Registro
   ✅ FIX: Fondo oscuro sólido (!important) para que no sea transparente.
   ✅ FIX: Textos y etiquetas forzados a color claro para que se lean.
   ✅ FIX: Inputs con fondo blanco y letra oscura.
   ═══════════════════════════════════════════════ */

:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(10, 15, 25, 0.95); /* Fondo casi 100% opaco */
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #ff5e00; /* Borde naranja */
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --accent-cyan:   #00e0ff;
    --accent-red:    #ef4444;
}

.astroreg_wrap {
    max-width: 700px;
    margin: 40px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

/* Fondo oscuro forzado y borde naranja */
.astroreg_panel {
    background: var(--bg-card) !important; /* Fuerza el fondo oscuro */
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    border: 1px solid var(--border-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9) !important;
    overflow: hidden;
}

/* Ocultar la barra azul de "REGISTRO" */
.astroreg_heading {
    display: none !important; 
}

.astroreg_body {
    padding: 30px 40px;
    color: #e2e8f0 !important; /* Fuerza color claro de texto */
}

/* ═══ Form group ═══ */
.astroreg_group {
    margin-bottom: 16px;
}

.astroreg_group label {
    display: block;
    color: #94a3b8 !important; /* Gris claro para que se lea sobre el fondo oscuro */
    font-size: 12px;
    margin-bottom: 6px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
}

/* Inputs blancos con letra negra para que resalten */
.astroreg_group input[type="text"],
.astroreg_group input[type="password"],
.astroreg_group input[type="email"],
.astroreg_group select {
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

.astroreg_group input:focus,
.astroreg_group select:focus {
    outline: none;
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5) !important;
}

.astroreg_group select option {
    background: #0f1624 !important;
    color: #ffffff !important;
}

/* ═══ Descripciones (inputDesc) ═══ */
.astroreg_inputdesc {
    display: block;
    color: #64748b !important;
    font-size: 11px;
    margin-top: 5px;
    line-height: 1.4;
    font-style: italic;
}
.astroreg_inputdesc small {
    font-size: 11px;
    color: #64748b !important;
}

/* ═══ Errores (los llena el JS) ═══ */
.astroreg_error {
    display: block;
    color: #ff4488;
    font-size: 12px;
    margin-top: 5px;
    font-weight: 600;
    min-height: 0;
}
.astroreg_error:empty {
    display: none;
}
.astroreg_error:not(:empty)::before {
    content: '⚠ ';
    color: #ff4488;
}

.astroreg_group input.astroreg_invalid,
.astroreg_group select.astroreg_invalid {
    border-color: #ff4488 !important;
    box-shadow: 0 0 10px rgba(255, 68, 136, 0.4) !important;
}

/* ═══ Checkbox Rules ═══ */
.astroreg_checkbox {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 12px;
    background: rgba(0, 224, 255, 0.05) !important; /* Fondo ligeramente azul */
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-radius: 6px;
    margin-bottom: 20px;
    font-size: 13px;
    line-height: 1.5;
    color: #e2e8f0 !important; /* Texto claro */
}
.astroreg_checkbox input[type="checkbox"] {
    appearance: none;
    -webkit-appearance: none;
    width: 18px;
    height: 18px;
    flex-shrink: 0;
    margin-top: 1px;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(255, 255, 255, 0.3) !important;
    border-radius: 4px;
    cursor: pointer;
    position: relative;
    transition: 0.2s ease;
}
.astroreg_checkbox input[type="checkbox"]:hover {
    border-color: var(--accent-cyan) !important;
}
.astroreg_checkbox input[type="checkbox"]:checked {
    background: var(--accent-cyan) !important;
    border-color: var(--accent-cyan) !important;
}
.astroreg_checkbox input[type="checkbox"]:checked::after {
    content: '✓';
    position: absolute;
    top: -1px; left: 3px;
    color: #000000 !important;
    font-size: 13px;
    font-weight: bold;
}
.astroreg_checkbox a {
    color: var(--accent-cyan) !important;
    text-decoration: none;
}
.astroreg_checkbox a:hover {
    color: #ffffff !important;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* ═══ Captcha ═══ */
.astroreg_captcha_row {
    margin-bottom: 16px;
    padding: 12px;
    background: rgba(0, 224, 255, 0.05) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-radius: 6px;
}
.astroreg_captcha_row label {
    display: block;
    color: #94a3b8 !important;
    font-size: 12px;
    margin-bottom: 8px;
    text-transform: uppercase;
    font-weight: 600;
}
.astroreg_captcha_row .g-recaptcha {
    margin-top: 6px;
}

/* ═══ Botón submit ═══ */
.astroreg_actions {
    text-align: right;
    padding-top: 15px;
    border-top: 1px solid rgba(255, 255, 255, 0.1) !important;
    margin-top: 10px;
}

.astroreg_btn_register {
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
.astroreg_btn_register:hover {
    background: #2e3a4e !important;
    border-color: var(--border-color) !important;
    box-shadow: 0 0 18px rgba(255, 94, 0, 0.4) !important;
    transform: translateY(-2px);
}
.astroreg_btn_register:active {
    transform: translateY(0);
}

@media (max-width: 768px) {
    .astroreg_wrap {
        margin-top: 20px;
        padding: 0 6px;
    }
    .astroreg_body {
        padding: 20px 15px;
    }
    .astroreg_actions {
        text-align: center;
    }
    .astroreg_btn_register {
        width: 100%;
    }
}
</style>

<div class="container astroreg_wrap">
    <div class="row">
        <div class="col-lg-12">
            <div class="panel panel-default astroreg_panel">
                <div class="panel-heading astroreg_heading">{$LNG.siteTitleRegister}</div>
                <div class="panel-body astroreg_body">
                    <form id="registerForm" method="post" action="index.php?page=register" data-action="index.php?page=register">
                        <input type="hidden" value="send" name="mode">
                        <input type="hidden" value="{$externalAuth.account}" name="externalAuth[account]">
                        <input type="hidden" value="{$externalAuth.method}" name="externalAuth[method]">
                        <div class="form-group astroreg_group">
                            <label for="universe">{$LNG.chose_a_uni}</label>
                            <select name="uni" id="universe" class="form-control changeAction">{html_options options=$universeSelect selected=$UNI}</select>
                            {if !empty($error.uni)}<span class="error errorUni astroreg_error"></span>{/if}
                        </div>
                        <div class="form-group astroreg_group">
                            <label for="username">{$LNG.registerUsername}</label>
                            <input type="text" class="form-control" name="username" id="username" placeholder="{$LNG.registerUsername}">
                            {if !empty($error.username)}<span class="error errorUsername astroreg_error"></span>{/if}
                            <span class="inputDesc astroreg_inputdesc"><small>{$LNG.registerUsernameDesc}</small></span>
                        </div>
                        <div class="form-group astroreg_group">
                            <label for="password">{$LNG.registerPassword}</label>
                            <input type="password" class="form-control" name="password" id="password" placeholder="{$LNG.registerPassword}">
                            {if !empty($error.password)}<span class="error errorPassword astroreg_error"></span>{/if}
                            <span class="inputDesc astroreg_inputdesc"><small>{$LNG.registerPasswordDesc}</small></span>
                        </div>
                        <div class="form-group astroreg_group">
                            <label for="passwordReplay">{$LNG.registerPasswordReplay}</label>
                            <input type="password" class="form-control" name="passwordReplay" id="passwordReplay" placeholder="{$LNG.registerPasswordReplay}">
                            {if !empty($error.passwordReplay)}<span class="error errorPasswordReplay astroreg_error"></span>{/if}
                            <span class="inputDesc astroreg_inputdesc"><small>{$LNG.registerPasswordReplayDesc}</small></span>
                        </div>
                        <div class="form-group astroreg_group">
                            <label for="email">{$LNG.registerEmail}</label>
                            <input type="email" class="form-control" name="email" id="email" placeholder="{$LNG.registerEmail}">
                            {if !empty($error.password)}<span class="error errorEmail astroreg_error"></span>{/if}
                            <span class="inputDesc astroreg_inputdesc"><small>{$LNG.registerEmailDesc}</small></span>
                        </div>
                        <div class="form-group astroreg_group">
                            <label for="emailReplay">{$LNG.registerEmailReplay}</label>
                            <input type="email" class="form-control" name="emailReplay" id="emailReplay" placeholder="{$LNG.registerEmailReplay}">
                            {if !empty($error.emailReplay)}<span class="error errorEmailReplay astroreg_error"></span>{/if}
                            <span class="inputDesc astroreg_inputdesc"><small>{$LNG.registerEmailReplayDesc}</small></span>
                        </div>
                        {* ✅ v6.0 — PAÍS OBLIGATORIO: su código viaja a users.country
                           y la tabla de puntuación muestra la bandera del jugador *}
                        <div class="form-group astroreg_group">
                            <label for="country">País *</label>
                            <select name="country" id="country" class="form-control" required>{html_options options=$countries selected=$selectedCountry}</select>
                            <span class="inputDesc astroreg_inputdesc">
                                <small>Elegí tu país: la bandera aparecerá junto a tu nombre en la tabla de puntuación.</small>
                            </span>
                        </div>
                        {if count($languages) > 1}
                            <div class="form-group astroreg_group">
                                <label for="language">{$LNG.registerLanguage}</label>
                                <select name="lang" id="language" class="form-control">{html_options options=$languages selected=$lang}</select>
                                {if !empty($error.language)}<span class="error errorLanguage astroreg_error"></span>{/if}
                            </div>
                        {/if}
                        {* 🆕 CAMPO CÓDIGO DE REFERIDO (OPCIONAL) — v5.0 *}
                        <div class="form-group astroreg_group">
                            <label for="referral_code">{$LNG.registerReferralCode|default:"Código de Referido (opcional)"}</label>
                            <input type="text" class="form-control" name="referral_code" id="referral_code"
                                   placeholder="Ej: 4AF1013C" maxlength="8" autocomplete="off"
                                   style="text-transform: uppercase;">
                            {if !empty($error.referral_code)}<span class="error errorReferralCode astroreg_error"></span>{/if}
                            <span class="inputDesc astroreg_inputdesc">
                                <small>{$LNG.registerReferralCodeDesc|default:"Si tenés un código de referido, ingresalo (8 caracteres). Si no, dejalo vacío."}</small>
                            </span>
                        </div>
                        {if $recaptchaEnable}
                            <div class="rowForm astroreg_captcha_row" id="captchaRow">
                                <div>
                                    <label>{$LNG.registerCaptcha}</label>
                                    <!--<span class="inputDesc">{$LNG.registerCaptchaDesc}</span>-->
                                    <div class="g-recaptcha" data-sitekey="{$recaptchaPublicKey}"></div>
                                </div>
                            </div>
                        {/if}
                        <div class="form-group checkbox astroreg_checkbox">
                            <input type="checkbox" name="rules" id="rules" value="1"> {$registerRulesDesc}
                            {if !empty($error.rules)}<span class="error errorRules astroreg_error"></span>{/if}
                        </div>
                        <div class="astroreg_actions">
                            <button type="submit" class="btn btn-danger astroreg_btn_register">{$LNG.buttonRegister}</button>
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
<script type="text/javascript" src="scripts/login/register.js"></script>
{/block}