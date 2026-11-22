{include file="ins_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Installer Upgrade Result (ins_doupdate)
   Prefijo: .astroins_doupd_
   ═══════════════════════════════════════════════ */

.astroins_doupd_wrap {
    padding: 12px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Panel principal ─── */
.astroins_doupd_box {
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

/* ─── Mensaje de éxito ─── */
.astroins_doupd_success {
    padding: 14px 18px;
    background: rgba(102, 255, 153, 0.08);
    border: 1px solid rgba(102, 255, 153, 0.25);
    border-left: 3px solid #66ff99;
    border-radius: 6px;
    color: #c8d6e5;
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0 0 18px 0;
}
.astroins_doupd_success p {
    margin: 0;
    color: #c8d6e5;
}

/* ─── Mensaje neutro (nada que hacer) ─── */
.astroins_doupd_info {
    padding: 14px 18px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid #1e3a5f;
    border-left: 3px solid #00ccff;
    border-radius: 6px;
    color: #c8d6e5;
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0 0 18px 0;
}
.astroins_doupd_info p {
    margin: 0;
    color: #c8d6e5;
}

/* ─── Contenedor de acciones ─── */
.astroins_doupd_actions {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    padding: 12px 0 4px;
    border-top: 1px solid #1e3a5f;
    margin-top: 6px;
}

.astroins_doupd_actions a {
    text-decoration: none;
    display: inline-block;
}

/* ─── Botón Volver ─── */
.astroins_doupd_actions button {
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
.astroins_doupd_actions button:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}
.astroins_doupd_actions button:active {
    transform: translateY(0);
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_doupd_box {
        padding: 16px 18px;
        border-radius: 8px;
    }
    .astroins_doupd_success,
    .astroins_doupd_info {
        padding: 12px 14px;
        font-size: 12.5px;
    }
    .astroins_doupd_actions {
        justify-content: stretch;
    }
    .astroins_doupd_actions button {
        width: 100%;
        box-sizing: border-box;
    }
    .astroins_doupd_actions a {
        width: 100%;
    }
}
</style>

<tr>
    <td colspan="2">
        <div id="main" class="astroins_doupd_wrap" align="left">

            <div class="astroins_doupd_box">

                {if $update}
                    {* ═══ Caso: upgrade ejecutado con éxito ═══ *}
                    <div class="astroins_doupd_success">
                        <p>{sprintf($LNG.upgrade_success,$revision)}</p>
                    </div>
                {else}
                    {* ═══ Caso: no había nada que actualizar ═══ *}
                    <div class="astroins_doupd_info">
                        <p>{sprintf($LNG.upgrade_nothingtodo,$revision)}</p>
                    </div>
                {/if}

                {* ─── Botón Volver al inicio ─── *}
                <div class="astroins_doupd_actions">
                    <a href="../index.php">
                        <button>{$LNG.upgrade_back}</button>
                    </a>
                </div>

            </div>

        </div>
    </td>
</tr>

{include file="ins_footer.tpl"}