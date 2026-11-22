{include file="ins_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Installer Intro
   Prefijo: .astroins_intro_
   ═══════════════════════════════════════════════ */

.astroins_intro_wrap {
    padding: 12px 0;
}

/* ─── Selector de idioma ─── */
.astroins_intro_lang {
    text-align: right;
    margin: 0 0 16px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
    font-size: 12px;
    color: #c8d6e5;
}
.astroins_intro_lang_label {
    color: #00ccff;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-size: 11px;
}
.astroins_intro_lang_select {
    background: rgba(15, 22, 36, 0.95) !important;
    border: 1px solid #1e3a5f !important;
    border-radius: 6px !important;
    color: #c8d6e5 !important;
    padding: 6px 10px !important;
    font-size: 12px !important;
    outline: none;
    cursor: pointer;
    transition: 0.25s ease;
}
.astroins_intro_lang_select:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
}

/* ─── Panel del intro ─── */
.astroins_intro_panel {
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #1e3a5f;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
    overflow: hidden;
    margin-bottom: 18px;
}
.astroins_intro_heading {
    background: linear-gradient(180deg, #004488 0%, #0077cc 100%);
    border-bottom: 1px solid #00ccff;
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 10px 16px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
}
.astroins_intro_body {
    padding: 20px 24px;
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Título h2 ─── */
.astroins_intro_body h2 {
    color: #00ccff;
    font-size: 15px;
    font-weight: 700;
    margin: 0 0 12px 0;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}

/* ─── Párrafos ─── */
.astroins_intro_body p {
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
    margin: 0 0 14px 0;
}

/* ─── Botón continuar ─── */
.astroins_intro_btn {
    display: inline-block;
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 6px !important;
    color: #ffffff !important;
    padding: 10px 28px !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
    text-decoration: none;
    margin-top: 6px;
}
.astroins_intro_btn:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
    color: #ffffff !important;
}
.astroins_intro_btn:active {
    transform: translateY(0);
}
.astroins_intro_btn_wrap {
    margin-top: 12px;
    padding-top: 14px;
    border-top: 1px solid #1e3a5f;
}

/* ─── Cabecera del upgrade (th) ─── */
.astroins_intro_upgrade_th {
    background: linear-gradient(180deg, #004488 0%, #0077cc 100%) !important;
    border-bottom: 1px solid #00ccff !important;
    color: #ffffff !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    padding: 10px 16px !important;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-align: left;
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_intro_body {
        padding: 16px 14px;
    }
    .astroins_intro_lang {
        text-align: center;
    }
    .astroins_intro_btn {
        display: block;
        text-align: center;
        width: 100%;
        box-sizing: border-box;
    }
}
</style>

<tr>
    <td colspan="2">
        <div class="installcontent astroins_intro_wrap">

            {* ─── Selector de idioma ─── *}
            <div id="lang" class="astroins_intro_lang" align="right">
                <span class="astroins_intro_lang_label">{$LNG.intro_lang}:</span>&nbsp;
                <select id="lang"
                        name="lang"
                        class="astroins_intro_lang_select"
                        onchange="document.location = '?lang='+$(this).val();">
                    {html_options options=$Selector selected=$lang}
                </select>
            </div>

            {* ─── Panel: Bienvenida ─── *}
            <div id="main" class="astroins_intro_panel" align="left">
                <div class="astroins_intro_heading">{$LNG.intro_welcome}</div>
                <div class="astroins_intro_body">
                    <h2>{$LNG.intro_welcome}</h2>
                    <p>{$LNG.intro_text}</p>

                    <div class="astroins_intro_btn_wrap">
                        <a href="index.php?mode=install&amp;step=2">
                            <button class="astroins_intro_btn" style="cursor: pointer;">{$LNG.continue}</button>
                        </a>
                    </div>
                </div>
            </div>

        </div>
    </td>
</tr>

{if $canUpgrade}
<tr>
    <th colspan="3" class="astroins_intro_upgrade_th">{$LNG.menu_upgrade}</th>
</tr>
<tr>
    <td colspan="2">
        <div class="installcontent astroins_intro_wrap">

            {* ─── Panel: Upgrade ─── *}
            <div id="main" class="astroins_intro_panel" align="left">
                <div class="astroins_intro_heading">{$LNG.menu_upgrade}</div>
                <div class="astroins_intro_body">
                    <h2>{$LNG.intro_upgrade_head}</h2>
                    <p>{$LNG.intro_upgrade_text}</p>

                    <div class="astroins_intro_btn_wrap">
                        <a href="index.php?mode=upgrade">
                            <button class="astroins_intro_btn" style="cursor: pointer;">{$LNG.continueUpgrade}</button>
                        </a>
                    </div>
                </div>
            </div>

        </div>
    </td>
</tr>
{/if}

{include file="ins_footer.tpl"}