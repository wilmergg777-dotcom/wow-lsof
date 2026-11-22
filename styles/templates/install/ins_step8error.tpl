{include file="ins_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Installer Step 8 Error
   Prefijo: .astroins_step8err_
   ═══════════════════════════════════════════════ */

.astroins_step8err_wrap {
    padding: 12px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Panel principal ─── */
.astroins_step8err_box {
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

/* ─── Bloque de error ─── */
.astroins_step8err_box .fatalerror {
    padding: 14px 18px;
    border-radius: 8px;
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0 0 18px 0;
    background: rgba(255, 68, 136, 0.08);
    border: 1px solid rgba(255, 68, 136, 0.25);
    border-left: 3px solid #ff4488;
    color: #c8d6e5;
    display: block;
}
.astroins_step8err_box .fatalerror p {
    margin: 0;
    color: #c8d6e5;
    font-size: 13.5px;
    line-height: 1.7;
}

/* ─── Contenedor de acciones ─── */
.astroins_step8err_actions {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 12px 0 4px;
    border-top: 1px solid #1e3a5f;
    margin-top: 6px;
}

.astroins_step8err_actions a {
    text-decoration: none;
    display: inline-block;
}

/* ─── Botón Volver ─── */
.astroins_step8err_actions button {
    background: linear-gradient(180deg, #3a1e2a 0%, #5a2a3a 100%) !important;
    border: 1px solid #ff4488 !important;
    border-radius: 6px !important;
    color: #ff88aa !important;
    padding: 10px 32px !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.2);
}
.astroins_step8err_actions button:hover {
    background: linear-gradient(180deg, #5a2a3a 0%, #7a3a4a 100%) !important;
    color: #ffffff !important;
    box-shadow: 0 0 18px rgba(255, 68, 136, 0.6);
    transform: translateY(-1px);
}
.astroins_step8err_actions button:active {
    transform: translateY(0);
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_step8err_box {
        padding: 16px 18px;
        border-radius: 8px;
    }
    .astroins_step8err_box .fatalerror {
        padding: 12px 14px;
        font-size: 12.5px;
    }
    .astroins_step8err_actions button {
        width: 100%;
        box-sizing: border-box;
    }
    .astroins_step8err_actions a {
        width: 100%;
    }
}
</style>

<tr>
    <td colspan="2">
        <div class="installcontent astroins_step8err_wrap">

            <div id="main" class="left astroins_step8err_box">

                {* ─── Mensaje de error ─── *}
                <div class="fatalerror">
                    <p>{$message}</p>
                </div>

                {* ─── Botón Volver con datos preservados ─── *}
                <div class="astroins_step8err_actions">
                    <a href="index.php?mode=install&step=7&amp;username={$username}&amp;email={$mail}">
                        <button>{$LNG.back}</button>
                    </a>
                </div>

            </div>

        </div>
    </td>
</tr>

{include file="ins_footer.tpl"}