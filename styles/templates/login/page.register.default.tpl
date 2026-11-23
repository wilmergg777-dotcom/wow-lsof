{block name="title" prepend}{$LNG.siteTitleRegister}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.register.default.tpl === *}



{literal}
<style>
/* ═══ ASTROIO v8.1 — reskin nextgen (tokens del índice v8.0) ═══ */
:root {
    --nx-muted:  #9a9a9a;
    --nx-cyan:   #59d6ff;
    --nx-green:  #35ff8f;
    --nx-red:    #ff5252;
    --nx-purple: #d946ef;
    --nx-gold:   #fbbf24;
    --nx-border: rgba(255, 255, 255, 0.1);
}

.astroreg_wrap { max-width: 480px; margin: 20px auto 40px; padding: 0 12px; box-sizing: border-box; }

/* ═══ Tarjeta nextgen (idéntica a las del índice) ═══ */
.astroreg_panel, .panel-default.astroreg_panel {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border);
    border-radius: 15px;
    box-shadow: 0 0 40px rgba(0, 0, 0, 0.75);
    overflow: hidden;
}
.astroreg_section_title, .panel-heading.astroreg_heading, .astroreg_heading {
    display: block;
    background: transparent;
    color: #ffffff;
    font-family: 'Space Mono', monospace;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
    padding: 16px 20px;
    border-bottom: 1px solid var(--nx-border);
    text-shadow: none;
}
.astroreg_wrap {
    font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}

/* ═══ Etiquetas mono (como las .uxn_lab del índice) ═══ */
.astroreg_group label, .astroreg_captcha_row label, .astrolost_captcha_row label {
    color: var(--nx-muted);
    font-family: 'Space Mono', monospace;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    margin-bottom: 6px;
}
/* ═══ Inputs blancos (como los del índice) ═══ */
.astroreg_group .form-control, .form-control.form-control {
    background: #ffffff;
    color: #111827;
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    min-height: 40px;
    font-family: 'Rajdhani', sans-serif;
    font-size: 14px;
    font-weight: 600;
    padding: 8px 12px;
    box-shadow: none;
}
.astroreg_group .form-control:focus, .form-control:focus {
    outline: none;
    background: #ffffff;
    color: #111827;
    border-color: var(--nx-cyan);
    box-shadow: 0 0 0 3px rgba(89, 214, 255, 0.25);
}
select.form-control option { background: #0b1020; color: #ffffff; font-weight: 600; }
.astroreg_group .form-control::placeholder, .form-control::placeholder { color: #6b7280; opacity: 1; }

/* Descripciones de campo */
.astroreg_inputdesc { color: var(--nx-muted); font-size: 11px; font-style: normal; margin-top: 4px; letter-spacing: .3px; }

/* Errores de validación */
.astroreg_error, .error { color: var(--nx-red); font-family: 'Space Mono', monospace; font-size: 11px; }

/* ═══ Botones (como los .bg-dark del índice) ═══ */
.astroreg_panel .btn.bg-dark, .btn-danger.astroreg_btn_register, .btn-danger.astroreg_btn_submit {
    background: #0a0f1c;
    border: 1px solid rgba(255, 255, 255, 0.18);
    color: #ffffff;
    font-family: 'Rajdhani', sans-serif;
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    border-radius: 8px;
    padding: 10px 18px;
    transition: .2s ease;
    text-shadow: none;
}
.astroreg_panel .btn.bg-dark:hover, .btn-danger.astroreg_btn_register:hover, .btn-danger.astroreg_btn_submit:hover {
    background: #0a0f1c;
    border-color: var(--nx-cyan);
    box-shadow: 0 0 18px rgba(89, 214, 255, 0.35);
    transform: translateY(-1px);
    color: #ffffff;
}
/* CTA principal con gradiente azul */
.astroreg_btn_register, .astroreg_btn_submit {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    border: 1px solid rgba(89, 214, 255, 0.55) !important;
    box-shadow: 0 4px 18px rgba(0, 102, 204, 0.45);
}
.astroreg_btn_register:hover, .astroreg_btn_submit:hover {
    background: linear-gradient(180deg, #0077e6 0%, #00aaff 100%) !important;
    box-shadow: 0 6px 24px rgba(0, 136, 255, 0.6);
}

/* Cuerpo y grupos */
.astroreg_body { padding: 20px 22px; color: #e2e8f0; }
.astroreg_group { margin-bottom: 14px; }
.astroreg_group input[type="text"], .astroreg_group input[type="password"],
.astroreg_group input[type="email"], .astroreg_group select {
    background: #ffffff; color: #111827; border: 1px solid rgba(255,255,255,.3);
    border-radius: 8px; padding: 8px 12px; font-size: 14px; font-weight: 600;
    font-family: 'Rajdhani', sans-serif; min-height: 40px; box-sizing: border-box; width: 100%;
}
.astroreg_group input:focus, .astroreg_group select:focus {
    outline: none; border-color: var(--nx-cyan);
    box-shadow: 0 0 0 3px rgba(89,214,255,.25); transform: none;
}
select option { background: #0b1020; color: #fff; }
.astroreg_group input::placeholder { color: #6b7280; opacity: 1; }
/* Captcha */
.astroreg_captcha_row {
    margin-bottom: 14px; padding: 14px;
    background: rgba(255,255,255,.04); border: 1px solid var(--nx-border); border-radius: 10px;
}
/* Checkbox de reglas */
.astroreg_checkbox {
    display: flex; align-items: flex-start; gap: 10px;
    padding: 12px 14px; background: rgba(255,255,255,.04);
    border: 1px solid var(--nx-border); border-radius: 10px;
    margin-bottom: 16px; font-size: 13px; line-height: 1.5; color: #e2e8f0;
}
.astroreg_checkbox a { color: var(--nx-cyan); text-decoration: none; }
.astroreg_checkbox a:hover { color: #ffffff; }
.astroreg_checkbox input[type="checkbox"] {
    appearance: none; -webkit-appearance: none;
    width: 18px; height: 18px; flex-shrink: 0; margin-top: 2px;
    background: rgba(0,0,0,.5); border: 1px solid rgba(255,255,255,.3);
    border-radius: 4px; cursor: pointer; position: relative; transition: .2s ease;
}
.astroreg_checkbox input[type="checkbox"]:checked {
    background: linear-gradient(180deg, #0066cc, #0099ff);
    border-color: var(--nx-cyan);
}
.astroreg_checkbox input[type="checkbox"]:checked::after {
    content: '✓'; position: absolute; top: -2px; left: 3px;
    color: #fff; font-size: 13px; font-weight: bold;
}
/* Acciones */
.astroreg_actions {
    text-align: right; padding-top: 14px;
    border-top: 1px solid var(--nx-border); margin-top: 8px;
}
.astroreg_btn_register { display: inline-block; padding: 11px 30px; font-size: 13px; letter-spacing: 2px; }
/* Enlaces generales */
.astroreg_body a { color: var(--nx-cyan); text-decoration: none; }
.astroreg_body a:hover { color: #ffffff; }

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astroreg_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astroreg_panel { border-radius: 12px; }
    .astroreg_body { padding: 16px 14px !important; }
    .astroreg_actions { text-align: center !important; }
    .astroreg_actions .btn, .astroreg_btn_register, .astroreg_btn_submit { width: 100%; }
}
</style>
{/literal}

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
                        {* NOTA: sin pattern HTML5 (daba problemas en algunos navegadores).
                           La validación real la hace el servidor con preg_match. *}
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