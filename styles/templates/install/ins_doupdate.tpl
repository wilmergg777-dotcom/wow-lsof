{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/install/ins_doupdate.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}

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