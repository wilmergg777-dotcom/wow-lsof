{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/install/ins_acc.tpl === *}
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
   AstroIO v2.2 — Installer Admin Account
   Prefijo: .astroins_acc_
   ═══════════════════════════════════════════════ */

.astroins_acc_wrap {
    padding: 12px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Cabecera h2 ─── */
.astroins_acc_header {
    color: #00ccff;
    font-size: 15px;
    font-weight: 700;
    margin: 0 0 10px 0;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}

.astroins_acc_desc {
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
    margin: 0 0 16px 0;
}

/* ─── Tabla del formulario ─── */
.astroins_acc_table {
    width: 100%;
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #1e3a5f;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
    border-collapse: collapse;
    overflow: hidden;
    margin-top: 8px;
}

.astroins_acc_table tr > td {
    padding: 12px 16px !important;
    border-bottom: 1px solid rgba(0, 204, 255, 0.08);
    color: #c8d6e5;
    font-size: 12.5px;
    vertical-align: middle;
}

.astroins_acc_table tr:last-child > td,
.astroins_acc_table tr.noborder > td {
    border-bottom: none;
}

.astroins_acc_table tr:hover > td {
    background: rgba(0, 204, 255, 0.04);
}

/* ─── Columna de etiqueta ─── */
.astroins_acc_table tr > td.left {
    text-align: left;
    color: #00ccff;
    font-weight: 600;
    width: 45%;
    letter-spacing: 0.3px;
}

.astroins_acc_table tr > td.left p {
    margin: 0 0 4px 0;
    color: #00ccff;
    font-size: 12.5px;
    font-weight: 600;
}

.astroins_acc_table tr > td.left p.desc {
    color: #8899aa;
    font-size: 11.5px;
    font-weight: 400;
    font-style: italic;
    margin: 0;
}

/* ─── Inputs ─── */
.astroins_acc_table input[type="text"],
.astroins_acc_table input[type="password"] {
    width: 100%;
    max-width: 360px;
    background: rgba(15, 22, 36, 0.95) !important;
    border: 1px solid #1e3a5f !important;
    border-radius: 6px !important;
    color: #c8d6e5 !important;
    padding: 8px 12px !important;
    font-size: 12px !important;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif !important;
    outline: none;
    transition: 0.25s ease;
    box-sizing: border-box;
}

.astroins_acc_table input[type="text"]:focus,
.astroins_acc_table input[type="password"]:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
    color: #00e0ff !important;
}

.astroins_acc_table input[type="text"]:hover,
.astroins_acc_table input[type="password"]:hover {
    border-color: rgba(0, 204, 255, 0.5);
}

/* ─── Fila del submit ─── */
.astroins_acc_table tr.noborder > td.astroins_acc_submit_cell {
    padding: 16px !important;
    text-align: right;
    border-top: 1px solid #1e3a5f;
    background: rgba(0, 204, 255, 0.03);
}

/* ─── Botón continuar ─── */
.astroins_acc_submitbtn {
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
.astroins_acc_submitbtn:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}
.astroins_acc_submitbtn:active {
    transform: translateY(0);
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_acc_table tr > td {
        padding: 10px 12px !important;
        font-size: 12px;
    }
    .astroins_acc_table tr > td.left {
        width: auto;
        font-size: 11.5px;
    }
    .astroins_acc_table input[type="text"],
    .astroins_acc_table input[type="password"] {
        max-width: 100%;
    }
    .astroins_acc_table tr.noborder > td.astroins_acc_submit_cell {
        text-align: center;
    }
    .astroins_acc_submitbtn {
        width: 100%;
        box-sizing: border-box;
    }
}
</style>

<tr>
    <td class="left">
        <div class="installcontent astroins_acc_wrap">

            <h2 class="astroins_acc_header">{$LNG.step4_head}</h2>
            <p class="astroins_acc_desc">{$LNG.step4_desc}</p>

            <form action="index.php?mode=install&step=8" method="post">
                <input type="hidden" name="post" value="1">

                <table class="req astroins_acc_table">
                    {* ─── Nombre de administrador ─── *}
                    <tr>
                        <td class="transparent left"><p>{$LNG.step4_admin_name}</p><p class="desc">{$LNG.step4_admin_name_desc}</p></td>
                        <td class="transparent"><input type="text" name="username" value="{$name}" size="30"></td>
                    </tr>

                    {* ─── Contraseña de administrador ─── *}
                    <tr>
                        <td class="transparent left"><p>{$LNG.step4_admin_pass}</p><p class="desc">{$LNG.step4_admin_pass_desc}</p></td>
                        <td class="transparent"><input type="password" name="password" value="{$password}" size="30"></td>
                    </tr>

                    {* ─── Email de administrador ─── *}
                    <tr>
                        <td class="transparent left"><p>{$LNG.step4_admin_mail}</p></td>
                        <td class="transparent"><input type="text" name="email" value="{$mail}" size="30"></td>
                    </tr>

                    {* ─── Botón continuar ─── *}
                    <tr class="noborder">
                        <td colspan="2" class="transparent astroins_acc_submit_cell">
                            <input type="submit" name="next" class="astroins_acc_submitbtn" value="{$LNG.continue}">
                        </td>
                    </tr>
                </table>
            </form>

        </div>
    </td>
</tr>

{include file="ins_footer.tpl"}