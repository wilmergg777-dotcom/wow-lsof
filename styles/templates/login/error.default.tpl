{block name="title" prepend}{$LNG.fcm_info}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/error.default.tpl === *}



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

/* ═══ Tarjeta nextgen (idéntica a las del índice) ═══ */
.astroerr_panel, .panel-default.astroerr_panel {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border);
    border-radius: 15px;
    box-shadow: 0 0 40px rgba(0, 0, 0, 0.75);
    overflow: hidden;
}
.astroerr_section_title, .panel-heading.astroerr_heading, .astroerr_heading {
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
.astroerr_wrap {
    font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}

.astroerr_wrap { max-width: 620px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; }
.astroerr_body { padding: 22px 24px; color: #e2e8f0; font-size: 14px; line-height: 1.7; }
.astroerr_table { width: 100%; border-collapse: collapse; margin: 0; }
.astroerr_table tr > td { padding: 0; color: #e2e8f0; vertical-align: top; }
.astroerr_message {
    color: #e2e8f0; font-size: 15px; line-height: 1.7; margin: 0 0 16px;
    padding: 14px 18px;
    background: rgba(217, 70, 239, 0.06);
    border: 1px solid var(--nx-border);
    border-left: 3px solid var(--nx-purple);
    border-radius: 10px;
}
.astroerr_message p { margin: 0; }
.astroerr_buttons {
    display: flex; flex-wrap: wrap; gap: 10px; margin-top: 16px;
    padding-top: 16px; border-top: 1px solid var(--nx-border); justify-content: flex-start;
}
.astroerr_buttons a { text-decoration: none; display: inline-block; }
.astroerr_buttons .btn, .astroerr_buttons button {
    display: inline-block; padding: 10px 24px;
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    color: #ffffff !important;
    border: 1px solid rgba(89, 214, 255, 0.55) !important;
    border-radius: 8px;
    font-family: 'Rajdhani', sans-serif; font-size: 13px; font-weight: 700;
    cursor: pointer; transition: .2s ease;
    text-transform: uppercase; letter-spacing: 1.5px; text-shadow: none;
}
.astroerr_buttons .btn:hover, .astroerr_buttons button:hover {
    background: linear-gradient(180deg, #0077e6 0%, #00aaff 100%) !important;
    box-shadow: 0 6px 24px rgba(0, 136, 255, 0.6);
    transform: translateY(-1px); color: #ffffff !important;
}
.astroerr_buttons .btn:active, .astroerr_buttons button:active { transform: translateY(0); }

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astroerr_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astroerr_panel { border-radius: 12px; }
    .astroerr_body { padding: 16px 14px !important; }
    .astroerr_actions { text-align: center !important; }
    .astroerr_actions .btn, .astroerr_btn_register, .astroerr_btn_submit { width: 100%; }
}
</style>
{/literal}

<div class="container astroerr_wrap">
    <div class="panel panel-default astroerr_panel">
        <div class="panel-heading astroerr_heading">{$LNG.fcm_info}</div>
        <div class="panel-body astroerr_body">
            <table class="table519 astroerr_table">
                <tr>
                    <td>
                        <p class="astroerr_message">{$message}</p>
                        {if !empty($redirectButtons)}
                        <p class="astroerr_buttons">
                            {foreach $redirectButtons as $button}
                                <a href="{$button.url}"><button class="btn btn-default">{$button.label}</button></a>
                            {/foreach}
                        </p>
                        {/if}
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>

{/block}