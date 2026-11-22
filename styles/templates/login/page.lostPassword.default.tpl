{block name="title" prepend}{$LNG.siteTitleLostPassword}{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Recuperar Contraseña
   Prefijo: .astrolost_
   Acento: 🔷 Cyan (#00e0ff) + 🔴 Rojo (botón submit)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px
     - Variables --bg-card / --accent-cyan unificadas
     - Todos los IDs/names/Smarty intactos
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

.astrolost_wrap {
    max-width: 700px;
    margin: 80px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astrolost_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astrolost_heading {
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

.astrolost_body {
    padding: 20px 24px;
    color: var(--text-main);
}

/* Info descriptiva arriba */
.astrolost_info {
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid var(--border-color);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 8px;
    padding: 10px 14px;
    margin-bottom: 18px;
    font-size: 12.5px;
    line-height: 1.6;
    color: var(--text-main);
}
.astrolost_info p {
    margin: 0;
}

/* ═══ Form group ═══ */
.astrolost_group {
    margin-bottom: 14px;
}

.astrolost_group label {
    display: block;
    color: var(--text-muted);
    font-size: 11.5px;
    margin-bottom: 5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
}

.astrolost_group input[type="text"],
.astrolost_group input[type="email"],
.astrolost_group select {
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

.astrolost_group input:focus,
.astrolost_group select:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astrolost_group select option {
    background: #0f1624;
    color: #ffffff;
}

/* ═══ Captcha ═══ */
.astrolost_captcha_row {
    margin-bottom: 14px;
    padding: 12px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid var(--border-color);
    border-radius: 8px;
}
.astrolost_captcha_row label {
    display: block;
    color: var(--text-muted);
    font-size: 11.5px;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
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
    padding-top: 8px;
    border-top: 1px solid var(--border-color);
    margin-top: 8px;
}

.astrolost_btn_submit {
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
.astrolost_btn_submit:hover {
    box-shadow: 0 0 18px rgba(255, 68, 136, 0.6);
    transform: translateY(-2px);
    background: linear-gradient(180deg, #ff4488 0%, #ff6699 100%);
}
.astrolost_btn_submit:active {
    transform: translateY(0);
}

@media (max-width: 768px) {
    .astrolost_wrap {
        margin-top: 70px;
        padding: 0 6px;
    }
    .astrolost_body {
        padding: 16px 14px;
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