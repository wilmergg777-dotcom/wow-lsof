{include file="ins_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Installer Step 4 (DB test result)
   Prefijo: .astroins_step4_
   ═══════════════════════════════════════════════ */

.astroins_step4_wrap {
    padding: 12px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Caja del mensaje ─── */
.astroins_step4_box {
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

/* ─── Mensaje (dentro de .noerror o .fatalerror) ─── */
.astroins_step4_box .noerror,
.astroins_step4_box .fatalerror {
    padding: 14px 18px;
    border-radius: 8px;
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0 0 18px 0;
    display: block;
}

.astroins_step4_box .noerror {
    background: rgba(102, 255, 153, 0.08);
    border: 1px solid rgba(102, 255, 153, 0.25);
    border-left: 3px solid #66ff99;
    color: #c8d6e5;
}

.astroins_step4_box .fatalerror {
    background: rgba(255, 68, 136, 0.08);
    border: 1px solid rgba(255, 68, 136, 0.25);
    border-left: 3px solid #ff4488;
    color: #c8d6e5;
}

.astroins_step4_box .noerror p,
.astroins_step4_box .fatalerror p {
    margin: 0;
    color: #c8d6e5;
    font-size: 13.5px;
    line-height: 1.7;
}

/* ─── Contenedor de botones ─── */
.astroins_step4_actions {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 12px;
    padding: 8px 0 4px;
}

.astroins_step4_actions a {
    text-decoration: none;
    display: inline-block;
}

/* ─── Botón (todos) ─── */
.astroins_step4_actions button {
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
.astroins_step4_actions button:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}
.astroins_step4_actions button:active {
    transform: translateY(0);
}

/* ─── Botón "Volver" (contexto error) ─── */
.astroins_step4_actions .astroins_step4_back_btn {
    background: linear-gradient(180deg, #3a1e2a 0%, #5a2a3a 100%) !important;
    border: 1px solid #ff4488 !important;
    color: #ff88aa !important;
}
.astroins_step4_actions .astroins_step4_back_btn:hover {
    background: linear-gradient(180deg, #5a2a3a 0%, #7a3a4a 100%) !important;
    box-shadow: 0 0 18px rgba(255, 68, 136, 0.5) !important;
    color: #ffffff !important;
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_step4_box {
        padding: 16px 18px;
        border-radius: 8px;
    }
    .astroins_step4_box .noerror,
    .astroins_step4_box .fatalerror {
        padding: 12px 14px;
        font-size: 12.5px;
    }
    .astroins_step4_actions {
        flex-direction: column;
    }
    .astroins_step4_actions button {
        width: 100%;
        box-sizing: border-box;
    }
    .astroins_step4_actions a {
        width: 100%;
    }
}
</style>

<tr>
    <td colspan="2">
        <div class="installcontent astroins_step4_wrap">

            {nocache}
            <div id="main" class="left astroins_step4_box">

                {* ─── Mensaje (verde si OK, rojo si error) ─── *}
                <div class="{$class}">
                    <p>{$message}</p>
                </div>

                {* ─── Botones condicionales ─── *}
                {if $class == 'noerror'}
                    {* ─── Caso OK: mostrar "Continuar" ─── *}
                    <div class="astroins_step4_actions">
                        <a href="index.php?mode=install&step=5">
                            <button>{$LNG.continue}</button>
                        </a>
                    </div>
                {else}
                    {* ─── Caso error: mostrar "Volver" con datos de conexión ─── *}
                    <div class="astroins_step4_actions">
                        {nocache}
                        <a href="index.php?mode=install&step=3&amp;host={$host}&amp;port={$port}&amp;user={$user}&amp;dbname={$dbname}&amp;prefix={$prefix}">
                        {/nocache}
                            <button class="astroins_step4_back_btn">{$LNG.back}</button>
                        </a>
                    </div>
                {/if}

            </div>
            {/nocache}

        </div>
    </td>
</tr>

{include file="ins_footer.tpl"}