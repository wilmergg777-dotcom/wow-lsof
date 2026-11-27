{include file="ins_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO INSTALLER ERROR MESSAGE BODY v3.0
   Prefijo: .astroerr_install_
   Acento del módulo: 🔵 Azul (#3b82f6) — Installer
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 12px)
     - Sub-cajas con borde cyan sutil + hover
     - Wrapper padding consistente
     - ⚠️ CRÍTICO: ins_header/ins_footer intactos (installer)
     - ⚠️ CRÍTICO: #lang + #main + onchange + html_options intactos
     - ⚠️ CRÍTICO: {$fcm_info} + {$mes} + {$Selector} + {$lang} intactos
   ══════════════════════════════════════════════════════════════ *}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Installer Error Message
   Prefijo: .astroerr_install_
   Contexto: instalador (ins_header + ins_footer)
   ═══════════════════════════════════════════════ */

/* ====== Variables globales ====== */
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

/* ═══ Selector de idioma ═══ */
.astroerr_install_lang {
    margin: 0 0 16px 0;
    font-family: 'Segoe UI', Roboto, sans-serif;
    font-size: 12px;
    color: var(--text-main);
}

.astroerr_install_lang_label {
    color: #00ccff;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-size: 11px;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.35);
}

.astroerr_install_lang_select {
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    padding: 7px 12px !important;
    font-size: 12px !important;
    font-family: inherit !important;
    font-weight: 700 !important;
    outline: none;
    cursor: pointer;
    transition: 0.25s ease;
}
.astroerr_install_lang_select:hover,
.astroerr_install_lang_select:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65) !important;
    transform: translateY(-1px);
}
.astroerr_install_lang_select option {
    background: #0f1624 !important;
    color: #ffffff !important;
    padding: 4px !important;
}

/* ═══ Contenedor principal ═══ */
.astroerr_install_main {
    max-width: 700px;
    margin: 0 auto;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

/* ═══ Panel (glassmorphism) ═══ */
.astroerr_install_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

/* ═══ Header del panel ═══ */
.astroerr_install_heading {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 12px 18px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4), 0 0 10px rgba(59, 130, 246, 0.4);
}

/* ═══ Body ═══ */
.astroerr_install_body {
    padding: 20px 24px;
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.7;
}

/* ═══ Mensaje (sub-caja con borde-left cyan) ═══ */
.astroerr_install_message {
    color: var(--text-main);
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0;
    padding: 14px 18px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.2);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 10px;
    transition: 0.2s ease;
}
.astroerr_install_message:hover {
    border-color: rgba(0, 204, 255, 0.4);
    background: rgba(0, 0, 0, 0.4);
}

/* ═══ Responsive ═══ */
@media (max-width: 768px) {
    .astroerr_install_main {
        padding: 0 10px;
    }
    .astroerr_install_heading {
        font-size: 11px;
        padding: 10px 14px;
    }
    .astroerr_install_body {
        padding: 16px 14px;
    }
    .astroerr_install_message {
        padding: 12px 14px;
        font-size: 12.5px;
    }
    .astroerr_install_lang {
        text-align: center !important;
    }
}
</style>

<tr>
    <td colspan="2">
        <div class="installcontent">

            {* ─── Selector de idioma (arriba a la derecha) ─── *}
            <div id="lang" class="astroerr_install_lang" align="right">
                <span class="astroerr_install_lang_label">{$LNG.intro_lang}:</span>&nbsp;
                <select id="lang"
                        name="lang"
                        class="astroerr_install_lang_select"
                        onchange="document.location = '?lang='+$(this).val();">
                    {html_options options=$Selector selected=$lang}
                </select>
            </div>

            {* ─── Caja de mensaje / error ─── *}
            <div id="main" class="astroerr_install_main" align="left">
                <div class="astroerr_install_panel">
                    <div class="astroerr_install_heading">{$fcm_info}</div>
                    <div class="astroerr_install_body">
                        <p class="astroerr_install_message">{$mes}</p>
                    </div>
                </div>
            </div>

        </div>
    </td>
</tr>
{include file="ins_footer.tpl"}