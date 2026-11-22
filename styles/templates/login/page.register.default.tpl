{block name="title" prepend}{$LNG.siteTitleRegister}{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Página de Registro
   Prefijo: .astroreg_
   Acento: 🔷 Cyan (#00e0ff) + 🔴 Rojo (botón submit)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px
     - Variables --bg-card / --accent-cyan unificadas
     - Todos los IDs/names/Smarty intactos
     - register.js sigue funcionando (mismos selectores .error, .form-control)
   ═══════════════════════════════════════════════ */

:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(15, 23, 42, 0.75);
    --bg-card-solid: rgba(15, 23, 42, 0.85);
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #1e293b;
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-blue:   #3b82f6;
    --accent-cyan:   #00e0ff;
    --accent-purple: #8b5cf6;
    --accent-gold:   #fbbf24;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
}

.astroreg_wrap {
    max-width: 700px;
    margin: 80px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astroreg_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astroreg_heading {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 10px 16px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
}

.astroreg_body {
    padding: 20px 24px;
    color: var(--text-main);
}

/* ═══ Form group ═══ */
.astroreg_group {
    margin-bottom: 14px;
}

.astroreg_group label {
    display: block;
    color: var(--text-muted);
    font-size: 11.5px;
    margin-bottom: 5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
}

.astroreg_group input[type="text"],
.astroreg_group input[type="password"],
.astroreg_group input[type="email"],
.astroreg_group select {
    width: 100%;
    box-sizing: border-box;
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 8px 10px;
    font-size: 12.5px;
    transition: 0.25s ease;
}

.astroreg_group input:focus,
.astroreg_group select:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astroreg_group select option {
    background: #0f1624;
    color: #ffffff;
}

/* ═══ Descripciones (inputDesc) ═══ */
.astroreg_inputdesc {
    display: block;
    color: var(--text-muted);
    font-size: 10.5px;
    margin-top: 4px;
    line-height: 1.4;
    font-style: italic;
}
.astroreg_inputdesc small {
    font-size: 10.5px;
    color: var(--text-muted);
}

/* ═══ Errores (los llena el JS) ═══ */
.astroreg_error {
    display: block;
    color: #ff4488;
    font-size: 11px;
    margin-top: 4px;
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

/* Estado de input inválido cuando hay error */
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
    padding: 10px 12px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 12px;
    line-height: 1.5;
    color: var(--text-main);
}
.astroreg_checkbox input[type="checkbox"] {
    appearance: none;
    -webkit-appearance: none;
    width: 18px;
    height: 18px;
    flex-shrink: 0;
    margin-top: 1px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid var(--border-color);
    border-radius: 4px;
    cursor: pointer;
    position: relative;
    transition: 0.2s ease;
}
.astroreg_checkbox input[type="checkbox"]:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astroreg_checkbox input[type="checkbox"]:checked {
    background: linear-gradient(180deg, #0066cc, #0099ff);
    border-color: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.6);
}
.astroreg_checkbox input[type="checkbox"]:checked::after {
    content: '✓';
    position: absolute;
    top: -1px; left: 3px;
    color: #ffffff;
    font-size: 13px;
    font-weight: bold;
}
.astroreg_checkbox a {
    color: var(--accent-cyan);
    text-decoration: none;
    transition: 0.2s ease;
}
.astroreg_checkbox a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* ═══ Captcha ═══ */
.astroreg_captcha_row {
    margin-bottom: 14px;
    padding: 12px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid var(--border-color);
    border-radius: 8px;
}
.astroreg_captcha_row label {
    display: block;
    color: var(--text-muted);
    font-size: 11.5px;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
}
.astroreg_captcha_row .g-recaptcha {
    margin-top: 6px;
}

/* ═══ Botón submit ═══ */
.astroreg_actions {
    text-align: right;
    padding-top: 8px;
    border-top: 1px solid var(--border-color);
    margin-top: 8px;
}

.astroreg_btn_register {
    display: inline-block;
    padding: 10px 28px;
    background: linear-gradient(180deg, #cc2244 0%, #ff4488 100%);
    color: #ffffff;
    border: 1px solid #ff4488;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroreg_btn_register:hover {
    box-shadow: 0 0 18px rgba(255, 68, 136, 0.6);
    transform: translateY(-2px);
    background: linear-gradient(180deg, #ff4488 0%, #ff6699 100%);
}
.astroreg_btn_register:active {
    transform: translateY(0);
}

@media (max-width: 768px) {
    .astroreg_wrap {
        margin-top: 70px;
        padding: 0 6px;
    }
    .astroreg_body {
        padding: 16px 14px;
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