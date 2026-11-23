{block name="title" prepend}{$LNG.siteTitleLostPassword}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.lostPassword.default.tpl === *}



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

.astrolost_wrap { max-width: 480px; margin: 20px auto 40px; padding: 0 12px; box-sizing: border-box; }

/* ═══ Tarjeta nextgen (idéntica a las del índice) ═══ */
.astrolost_panel, .panel-default.astrolost_panel {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border);
    border-radius: 15px;
    box-shadow: 0 0 40px rgba(0, 0, 0, 0.75);
    overflow: hidden;
}
.astrolost_section_title, .panel-heading.astrolost_heading, .astrolost_heading {
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
.astrolost_wrap {
    font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}

/* ═══ Etiquetas mono (como las .uxn_lab del índice) ═══ */
.astrolost_group label, .astroreg_captcha_row label, .astrolost_captcha_row label {
    color: var(--nx-muted);
    font-family: 'Space Mono', monospace;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    margin-bottom: 6px;
}
/* ═══ Inputs blancos (como los del índice) ═══ */
.astrolost_group .form-control, .form-control.form-control {
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
.astrolost_group .form-control:focus, .form-control:focus {
    outline: none;
    background: #ffffff;
    color: #111827;
    border-color: var(--nx-cyan);
    box-shadow: 0 0 0 3px rgba(89, 214, 255, 0.25);
}
select.form-control option { background: #0b1020; color: #ffffff; font-weight: 600; }
.astrolost_group .form-control::placeholder, .form-control::placeholder { color: #6b7280; opacity: 1; }

/* Descripciones de campo */
.astrolost_inputdesc { color: var(--nx-muted); font-size: 11px; font-style: normal; margin-top: 4px; letter-spacing: .3px; }

/* Errores de validación */
.astrolost_error, .error { color: var(--nx-red); font-family: 'Space Mono', monospace; font-size: 11px; }

/* ═══ Botones (como los .bg-dark del índice) ═══ */
.astrolost_panel .btn.bg-dark, .btn-danger.astrolost_btn_register, .btn-danger.astrolost_btn_submit {
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
.astrolost_panel .btn.bg-dark:hover, .btn-danger.astrolost_btn_register:hover, .btn-danger.astrolost_btn_submit:hover {
    background: #0a0f1c;
    border-color: var(--nx-cyan);
    box-shadow: 0 0 18px rgba(89, 214, 255, 0.35);
    transform: translateY(-1px);
    color: #ffffff;
}
/* CTA principal con gradiente azul */
.astrolost_btn_register, .astrolost_btn_submit {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    border: 1px solid rgba(89, 214, 255, 0.55) !important;
    box-shadow: 0 4px 18px rgba(0, 102, 204, 0.45);
}
.astrolost_btn_register:hover, .astrolost_btn_submit:hover {
    background: linear-gradient(180deg, #0077e6 0%, #00aaff 100%) !important;
    box-shadow: 0 6px 24px rgba(0, 136, 255, 0.6);
}

.astrolost_body { padding: 20px 22px; color: #e2e8f0; }
.astrolost_group { margin-bottom: 14px; }
.astrolost_group input[type="text"], .astrolost_group input[type="email"],
.astrolost_group select {
    background: #ffffff; color: #111827; border: 1px solid rgba(255,255,255,.3);
    border-radius: 8px; padding: 8px 12px; font-size: 14px; font-weight: 600;
    font-family: 'Rajdhani', sans-serif; min-height: 40px; box-sizing: border-box; width: 100%;
}
.astrolost_group input:focus, .astrolost_group select:focus {
    outline: none; border-color: var(--nx-cyan);
    box-shadow: 0 0 0 3px rgba(89,214,255,.25); transform: none;
}
.astrolost_group input::placeholder { color: #6b7280; opacity: 1; }
/* Info descriptiva */
.astrolost_info {
    background: rgba(89, 214, 255, 0.06);
    border: 1px solid var(--nx-border);
    border-left: 3px solid var(--nx-cyan);
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 18px;
    font-size: 13.5px;
    line-height: 1.6;
    color: #e2e8f0;
}
.astrolost_info p { margin: 0; }
/* Captcha */
.astrolost_captcha_row {
    margin-bottom: 14px; padding: 14px;
    background: rgba(255,255,255,.04); border: 1px solid var(--nx-border); border-radius: 10px;
}
.astrolost_captcha_row .captchaButtons { margin: 0; }
/* Acciones + volver */
.astrolost_actions {
    text-align: right; padding-top: 14px;
    border-top: 1px solid var(--nx-border); margin-top: 8px;
}
.astrolost_btn_submit { display: inline-block; padding: 11px 30px; font-size: 13px; letter-spacing: 2px; }
.astrolost_body a { color: var(--nx-cyan); text-decoration: none; }
.astrolost_body a:hover { color: #ffffff; }

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astrolost_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astrolost_panel { border-radius: 12px; }
    .astrolost_body { padding: 16px 14px !important; }
    .astrolost_actions { text-align: center !important; }
    .astrolost_actions .btn, .astrolost_btn_register, .astrolost_btn_submit { width: 100%; }
}
</style>
{/literal}

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