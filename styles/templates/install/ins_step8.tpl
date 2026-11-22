{include file="ins_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Installer Step 8 (Finish)
   Prefijo: .astroins_step8_
   ═══════════════════════════════════════════════ */

.astroins_step8_wrap {
    padding: 12px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Panel principal ─── */
.astroins_step8_box {
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #1e3a5f;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
    padding: 22px 26px;
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
    margin: 0 auto;
    max-width: 700px;
}

/* ─── Títulos h2 ─── */
.astroins_step8_header {
    color: #00ccff;
    font-size: 15px;
    font-weight: 700;
    margin: 0 0 10px 0;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}

/* ─── Separación entre bloques ─── */
.astroins_step8_block_ok {
    margin-bottom: 22px;
    padding-bottom: 18px;
    border-bottom: 1px solid #1e3a5f;
}

/* ─── Mensaje de éxito ─── */
.astroins_step8_success {
    margin: 0 0 12px 0;
    padding: 12px 16px;
    background: rgba(102, 255, 153, 0.08);
    border: 1px solid rgba(102, 255, 153, 0.25);
    border-left: 3px solid #66ff99;
    border-radius: 6px;
    color: #c8d6e5;
    font-size: 13.5px;
    line-height: 1.7;
}
.astroins_step8_success p {
    margin: 0;
    color: #c8d6e5;
}

/* ─── Mensaje adicional ─── */
.astroins_step8_info {
    margin: 0 0 18px 0;
    padding: 12px 16px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid #1e3a5f;
    border-left: 3px solid #00ccff;
    border-radius: 6px;
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
}
.astroins_step8_info p {
    margin: 0;
    color: #c8d6e5;
}

/* ─── Contenedor de acciones ─── */
.astroins_step8_actions {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 12px 0 4px;
    border-top: 1px solid #1e3a5f;
    margin-top: 6px;
}

.astroins_step8_actions a {
    text-decoration: none;
    display: inline-block;
}

/* ─── Botón Login ─── */
.astroins_step8_actions button {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 6px !important;
    color: #ffffff !important;
    padding: 10px 32px !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.2);
}
.astroins_step8_actions button:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}
.astroins_step8_actions button:active {
    transform: translateY(0);
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_step8_box {
        padding: 16px 18px;
        border-radius: 8px;
    }
    .astroins_step8_success,
    .astroins_step8_info {
        padding: 10px 12px;
        font-size: 12.5px;
    }
    .astroins_step8_actions button {
        width: 100%;
        box-sizing: border-box;
    }
    .astroins_step8_actions a {
        width: 100%;
    }
}
</style>

<tr>
    <td colspan="2">
        <div class="installcontent astroins_step8_wrap">

            <div id="main" class="left astroins_step8_box">

                {* ═══ Bloque 1: Confirmación de instalación ═══ *}
                <div class="astroins_step8_block_ok">
                    <h2 class="astroins_step8_header">{$LNG.step6_head}</h2>
                    <div class="astroins_step8_success">
                        <p>{$LNG.step6_desc}</p>
                    </div>
                </div>

                {* ═══ Bloque 2: Info adicional ═══ *}
                <h2 class="astroins_step8_header">{$LNG.step6_info_head}</h2>
                <div class="astroins_step8_info">
                    <p>{$LNG.step6_info_additional}</p>
                </div>

                {* ═══ Bloque 3: Botón Login ═══ *}
                <div class="astroins_step8_actions">
                    <a href="../admin.php">
                        <button>{$LNG.login}</button>
                    </a>
                </div>

            </div>

        </div>
    </td>
</tr>

{include file="ins_footer.tpl"}